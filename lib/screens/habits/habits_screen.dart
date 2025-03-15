import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../models/habit.dart';
import '../../models/habit_log.dart';
import '../../services/habit_service.dart';
import '../../widgets/habit_card.dart';
import 'add_habit_screen.dart';
import 'habit_details_screen.dart';

class HabitsScreen extends StatefulWidget {
  final int userId;

  const HabitsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
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
      Map<int, bool> todayCompletedMap = {};
      
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Veriler yüklenirken bir hata oluştu');
      }
    }
  }

  Future<void> _toggleHabitCompletion(Habit habit, bool completed) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final success = await _habitService.toggleHabitCompletion(
        habit.id!,
        today,
        completed,
      );
      
      if (success) {
        setState(() {
          _todayCompletedMap[habit.id!] = completed;
        });
        
        if (completed) {
          // Alışkanlık tamamlandığında güncel streak değerini kontrol et
          // ve belirli zincir milestone'larında bildirim göster
          final updatedHabit = await _habitService.getHabitById(habit.id!);
          if (updatedHabit != null && updatedHabit.currentStreak > habit.currentStreak) {
            _checkAndShowAchievementMessage(updatedHabit.currentStreak);
          }
        }
      } else {
        _showErrorSnackBar('Durum güncellenirken bir hata oluştu');
      }
    } catch (e) {
      _showErrorSnackBar('Durum güncellenirken bir hata oluştu');
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
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToAddHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHabitScreen(userId: widget.userId),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToHabitDetails(Habit habit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailsScreen(
          habit: habit,
          userId: widget.userId,
        ),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  void _showDeleteConfirmation(Habit habit) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Alışkanlığı Sil'),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              children: [
                const TextSpan(
                  text: 'Bu alışkanlığı silmek istediğinize emin misiniz?\n\n',
                ),
                TextSpan(
                  text: habit.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: '\n\nBu işlem geri alınamaz ve tüm ilerleme kaydınız silinir.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteHabit(habit);
              },
              child: const Text(
                AppTexts.delete,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteHabit(Habit habit) async {
    try {
      final success = await _habitService.deleteHabit(habit.id!);
      
      if (success) {
        _loadData();
        _showSuccessSnackBar('Alışkanlık başarıyla silindi');
      } else {
        _showErrorSnackBar('Alışkanlık silinirken bir hata oluştu');
      }
    } catch (e) {
      _showErrorSnackBar('Alışkanlık silinirken bir hata oluştu');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
          tabs: const [
            Tab(text: 'Bugün'),
            Tab(text: 'Tümü'),
          ],
        ),
      ),
      body: _isLoading
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
        child: const Icon(Icons.add),
        tooltip: 'Yeni Alışkanlık Ekle',
      ),
    );
  }

  Widget _buildTodayTab() {
    if (_todayHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bugün için alışkanlık yok',
              style: TextStyle(fontSize: 18),
            ),
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
          isToday: true,
          isCompleted: isCompleted,
          onToggle: (completed) => _toggleHabitCompletion(habit, completed),
          onTap: () => _navigateToHabitDetails(habit),
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddHabitScreen(
                userId: widget.userId,
                habit: habit,
              ),
            ),
          ).then((result) {
            if (result == true) _loadData();
          }),
          onDelete: () => _showDeleteConfirmation(habit),
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
            const Icon(
              Icons.repeat,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz alışkanlık eklenmemiş',
              style: TextStyle(fontSize: 18),
            ),
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
      itemCount: _allHabits.length,
      itemBuilder: (context, index) {
        final habit = _allHabits[index];
        final isToday = _todayHabits.any((h) => h.id == habit.id);
        final isCompleted = isToday ? (_todayCompletedMap[habit.id] ?? false) : false;
        
        return HabitCard(
          habit: habit,
          isToday: isToday,
          isCompleted: isCompleted,
          onToggle: (completed) => _toggleHabitCompletion(habit, completed),
          onTap: () => _navigateToHabitDetails(habit),
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddHabitScreen(
                userId: widget.userId,
                habit: habit,
              ),
            ),
          ).then((result) {
            if (result == true) _loadData();
          }),
          onDelete: () => _showDeleteConfirmation(habit),
        );
      },
    );
  }
}
