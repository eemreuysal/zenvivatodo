import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_texts.dart';
import '../../models/habit.dart';
import '../../models/habit_log.dart';
import '../../services/habit_service.dart';
import '../../widgets/habit_heatmap.dart';
import 'add_habit_screen.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;
  final int userId;

  const HabitDetailsScreen({
    super.key,
    required this.habit,
    required this.userId,
  });

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  final HabitService _habitService = HabitService();
  List<HabitLog> _recentLogs = [];
  double _completionRate = 0.0;
  bool _isLoading = true;
  bool _todayCompleted = false;
  String _todayDate = '';

  @override
  void initState() {
    super.initState();
    _todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Son 30 günlük kayıtları getir
      final logs = await _habitService.getRecentHabitLogs(widget.habit.id!);
      
      // Tamamlanma oranını hesapla
      final completionRate = await _habitService.calculateCompletionRate(widget.habit.id!);
      
      // Bugün tamamlanmış mı kontrol et
      final todayLogs = logs.where((log) => log.date == _todayDate).toList();
      final todayCompleted = todayLogs.isNotEmpty && todayLogs.first.completed;
      
      if (mounted) {
        setState(() {
          _recentLogs = logs;
          _completionRate = completionRate;
          _todayCompleted = todayCompleted;
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

  Future<void> _toggleTodayCompletion() async {
    try {
      final success = await _habitService.toggleHabitCompletion(
        widget.habit.id!,
        _todayDate,
        !_todayCompleted,
      );
      
      if (!mounted) return; // Asenkron işlemden sonra mounted kontrolü ekledik
      
      if (success) {
        // Kullanılmayan değişkeni kaldırdık
        setState(() {
          _todayCompleted = !_todayCompleted;
        });
        
        _loadData(); // Verileri yenile
      } else {
        _showErrorSnackBar('Durum güncellenirken bir hata oluştu');
      }
    } catch (e) {
      if (!mounted) return; // Asenkron işlemden sonra mounted kontrolü ekledik
      _showErrorSnackBar('Durum güncellenirken bir hata oluştu');
    }
  }

  void _navigateToEditHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHabitScreen(
          userId: widget.userId,
          habit: widget.habit,
        ),
      ),
    );
    
    if (!mounted) return; // Asenkron işlemden sonra mounted kontrolü eklendi
    
    if (result == true) {
      // Sayfayı kapatmadan önce güncelleme sinyali
      Navigator.pop(context, true);
    }
  }

  void _showDeleteConfirmation() {
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
                  text: widget.habit.title,
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
                _deleteHabit();
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

  Future<void> _deleteHabit() async {
    try {
      final success = await _habitService.deleteHabit(widget.habit.id!);
      
      if (!mounted) return;
      
      if (success) {
        Navigator.pop(context, true); // Güncelleme sinyali ile geri dön
      } else {
        _showErrorSnackBar('Alışkanlık silinirken bir hata oluştu');
      }
    } catch (e) {
      if (!mounted) return; // Asenkron işlemden sonra mounted kontrolü ekledik
      _showErrorSnackBar('Alışkanlık silinirken bir hata oluştu');
    }
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
    final theme = Theme.of(context);
    final habitColor = Color(widget.habit.colorCode);
    final formattedCompletionRate = (_completionRate * 100).toStringAsFixed(0);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditHabit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Özet Kart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: habitColor,
                                radius: 24,
                                child: const Icon(
                                  Icons.repeat,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.habit.title,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (widget.habit.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.habit.description,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn(
                                'Mevcut Zincir',
                                '${widget.habit.currentStreak} gün',
                              ),
                              _buildStatColumn(
                                'En Uzun Zincir',
                                '${widget.habit.longestStreak} gün',
                              ),
                              _buildStatColumn(
                                'Tamamlanma',
                                '%$formattedCompletionRate',
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Bugün için tamamla butonu
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _toggleTodayCompletion,
                              icon: Icon(
                                _todayCompleted
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                              ),
                              label: Text(
                                _todayCompleted
                                    ? 'Bugün Tamamlandı'
                                    : 'Bugün Tamamla',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _todayCompleted
                                    ? Colors.green
                                    : habitColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Alışkanlık İlerlemesi
                  Text(
                    'İlerleme',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hedef: ${widget.habit.targetDays} gün',
                            style: theme.textTheme.titleSmall,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: widget.habit.currentStreak / widget.habit.targetDays,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(habitColor),
                              minHeight: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // İlerleme yüzdesi
                          Text(
                            '${((widget.habit.currentStreak / widget.habit.targetDays) * 100).toStringAsFixed(0)}% tamamlandı',
                            style: theme.textTheme.bodyMedium,
                          ),
                          
                          if (widget.habit.currentStreak > 0) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Arka arkaya ${widget.habit.currentStreak} gündür devam ediyor!',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: habitColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Alışkanlık Detayları
                  Text(
                    'Detaylar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Tekrarlama',
                            _getFrequencyText(widget.habit),
                            Icons.repeat,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            'Başlangıç',
                            DateFormat('d MMMM yyyy', 'tr_TR')
                                .format(DateTime.parse(widget.habit.startDate)),
                            Icons.calendar_today,
                          ),
                          if (widget.habit.reminderTime != null) ...[
                            const Divider(),
                            _buildDetailRow(
                              'Hatırlatıcı',
                              widget.habit.reminderTime!,
                              Icons.alarm,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Isı Haritası
                  Text(
                    'Aktivite Haritası',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  HabitHeatmap(
                    logs: _recentLogs,
                    color: habitColor,
                    days: 30,
                    onDayTap: (date) async {
                      final dateObj = DateTime.parse(date);
                      final today = DateTime.now();
                      final isToday = DateUtils.isSameDay(dateObj, today);
                      final isPast = dateObj.isBefore(today) && !isToday;
                      
                      if (isToday || isPast) {
                        // Bugün veya geçmiş için tamamlama durumunu değiştir
                        final currentLogs = _recentLogs.where((log) => log.date == date).toList();
                        final currentStatus = currentLogs.isNotEmpty && currentLogs.first.completed;
                        
                        await _habitService.toggleHabitCompletion(
                          widget.habit.id!,
                          date,
                          !currentStatus,
                        );
                        
                        if (!mounted) return; // Asenkron işlemden sonra mounted kontrolü ekledik
                        _loadData(); // Verileri yenile
                      }
                    },
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: title == 'Mevcut Zincir' && widget.habit.currentStreak > 0
                ? Color(widget.habit.colorCode)
                : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFrequencyText(Habit habit) {
    switch (habit.frequency) {
      case 'daily':
        return 'Her gün';
      case 'weekly':
        if (habit.frequencyDays != null && habit.frequencyDays!.isNotEmpty) {
          final days = habit.frequencyDays!.split(',')
              .map((day) => _getWeekdayName(int.parse(day)))
              .join(', ');
          return 'Haftada: $days';
        }
        return 'Haftada bir';
      case 'monthly':
        return 'Ayda bir (Ayın ${DateTime.parse(habit.startDate).day}. günü)';
      default:
        return 'Özel';
    }
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Pazartesi';
      case 2: return 'Salı';
      case 3: return 'Çarşamba';
      case 4: return 'Perşembe';
      case 5: return 'Cuma';
      case 6: return 'Cumartesi';
      case 7: return 'Pazar';
      default: return '';
    }
  }
}
