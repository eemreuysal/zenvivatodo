import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/habit.dart';
import '../../services/habit_service.dart';
import '../../widgets/habit_card.dart';
import 'add_habit_screen.dart';
import 'habit_details_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key, required this.userId});
  final int userId;

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> with SingleTickerProviderStateMixin {
  final HabitService _habitService = HabitService();
  late TabController _tabController;

  List<Habit> _allHabits = [];
  List<Habit> _todayHabits = [];
  Map<int, bool> _todayCompletedMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tüm alışkanlıkları yükle
      final allHabits = await _habitService.getHabits(widget.userId);

      // Bugünkü alışkanlıkları yükle
      final todayHabits = await _habitService.getTodayHabits(widget.userId);

      // Bugün tamamlanmış alışkanlıkları kontrol et
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final Map<int, bool> todayCompletedMap = {};

      for (var habit in todayHabits) {
        if (habit.id != null) {
          final logs = await _habitService.getHabitLogs(habit.id!, date: today);
          todayCompletedMap[habit.id!] = logs.any((log) => log.completed);
        }
      }

      if (mounted) {
        setState(() {
          _allHabits = allHabits;
          _todayHabits = todayHabits;
          _todayCompletedMap = todayCompletedMap;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Veriler yüklenirken bir hata oluştu: $e');
      }
    }
  }

  Future<void> _toggleHabitCompletion(Habit habit) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final currentStatus = _todayCompletedMap[habit.id!] ?? false;

      final success = await _habitService.toggleHabitCompletion(habit.id!, today, !currentStatus);

      if (!mounted) return; // Asenkron işlemden sonra mounted kontrolü

      if (success) {
        setState(() {
          _todayCompletedMap[habit.id!] = !currentStatus;
        });

        if (!currentStatus) {
          // Eğer tamamlanıyorsa (false -> true)
          // Alışkanlık tamamlandığında güncel streak değerini kontrol et
          // ve belirli zincir milestone'larında bildirim göster
          final updatedHabit = await _habitService.getHabitById(habit.id!);

          if (!mounted) return; // Asenkron işlemden sonra mounted kontrolü

          if (updatedHabit != null && updatedHabit.currentStreak > habit.currentStreak) {
            _checkAndShowAchievementMessage(updatedHabit.currentStreak);
          }
        }
      } else {
        _showErrorSnackBar('Durum güncellenirken bir hata oluştu');
      }
    } on Exception catch (e) {
      if (!mounted) return; // Asenkron işlemden sonra mounted kontrolü
      _showErrorSnackBar('Durum güncellenirken bir hata oluştu: $e');
    }
  }

  void _checkAndShowAchievementMessage(int streak) {
    String? message;

    // Milestone'ları kontrol et
    if (streak == 3) {
      message = 'Harika! 3 günlük zincir oluşturdun.';
    } else if (streak == 7) {
      message = 'Bir haftayı tamamladın! Harika gidiyorsun.';
    } else if (streak == 14) {
      message = 'İki hafta oldu! Tutarlılığın etkileyici.';
    } else if (streak == 21) {
      message = 'Üç hafta! Artık bir alışkanlık oluşmaya başlıyor.';
    } else if (streak == 30) {
      message = 'Bir ay! Kendini kutlamalısın.';
    } else if (streak == 60) {
      message = 'İki ay! Muhteşem bir iş çıkarıyorsun.';
    } else if (streak == 90) {
      message = 'Üç ay! Olağanüstü bir başarı.';
    } else if (streak == 180) {
      message = 'Altı ay! Gerçek bir kararlılık örneği.';
    } else if (streak == 365) {
      message = 'Bir yıl! İnanılmaz bir başarı. Harikasın!';
    }

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToAddHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddHabitScreen(userId: widget.userId)),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _navigateToHabitDetails(Habit habit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailsScreen(habit: habit, userId: widget.userId),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışkanlıklar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Bugün'), Tab(text: 'Tümü')],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  // Bugün sekmesi
                  _buildTodayTab(),

                  // Tümü sekmesi
                  _buildAllTab(),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddHabit,
        tooltip: 'Yeni Alışkanlık Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodayTab() {
    if (_todayHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Bugün için alışkanlık yok', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _navigateToAddHabit,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Alışkanlık Ekle'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todayHabits.length,
      itemBuilder: (context, index) {
        final habit = _todayHabits[index];
        final isCompleted = _todayCompletedMap[habit.id] ?? false;

        return HabitCard(
          habit: habit,
          isCompleted: isCompleted,
          onToggleCompletion: () => _toggleHabitCompletion(habit),
          onTap: () => _navigateToHabitDetails(habit),
        );
      },
    );
  }

  Widget _buildAllTab() {
    if (_allHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.repeat, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Henüz alışkanlık eklenmemiş', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _navigateToAddHabit,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Alışkanlık Ekle'),
            ),
          ],
        ),
      );
    }

    // Alışkanlıkları gruplayalım ve sıraya koyalım:
    // 1. Bugün aktif olanlar (tamamlanmamış)
    // 2. Bugün aktif olanlar (tamamlanmış)
    // 3. Bugün aktif olmayanlar

    final List<Habit> sortedHabits = List.from(_allHabits)..sort((a, b) {
      // a'nın bugün olup olmadığını kontrol et
      final aIsToday = _todayHabits.any((h) => h.id == a.id);
      // b'nin bugün olup olmadığını kontrol et
      final bIsToday = _todayHabits.any((h) => h.id == b.id);

      if (aIsToday && !bIsToday) {
        return -1; // a bugün aktif, b değil - a önce gelsin
      } else if (!aIsToday && bIsToday) {
        return 1; // b bugün aktif, a değil - b önce gelsin
      } else if (aIsToday && bIsToday) {
        // Her ikisi de bugün aktif - tamamlanma durumuna göre sırala
        final aCompleted = _todayCompletedMap[a.id] ?? false;
        final bCompleted = _todayCompletedMap[b.id] ?? false;

        if (!aCompleted && bCompleted) {
          return -1; // a tamamlanmamış, b tamamlanmış - a önce gelsin
        } else if (aCompleted && !bCompleted) {
          return 1; // a tamamlanmış, b tamamlanmamış - b önce gelsin
        }
      }

      // Diğer durumlarda isme göre sırala
      return a.title.compareTo(b.title);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedHabits.length,
      itemBuilder: (context, index) {
        final habit = sortedHabits[index];
        final isToday = _todayHabits.any((h) => h.id == habit.id);
        final isCompleted = isToday ? (_todayCompletedMap[habit.id] ?? false) : false;

        return HabitCard(
          habit: habit,
          isCompleted: isCompleted,
          onToggleCompletion: isToday ? () => _toggleHabitCompletion(habit) : () {},
          onTap: () => _navigateToHabitDetails(habit),
        );
      },
    );
  }
}
