import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../main.dart';
import '../../models/category.dart';
import '../../models/habit.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/habit_service.dart';
import '../../services/inspiration_service.dart';
import '../../services/notification_service.dart';
import '../../services/sync_service.dart';
import '../../services/task_service.dart';
import '../../widgets/connection_status_bar.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/inspiration_card.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_filter.dart';
import '../categories/categories_screen.dart';
import '../habits/habit_details_screen.dart';
import '../habits/habits_screen.dart';
import '../profile/profile_screen.dart';
import '../tasks/active_tasks_screen.dart';
import '../tasks/add_task_screen.dart';
import '../tasks/completed_tasks_screen.dart';
import '../tasks/edit_task_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.userId});
  final int userId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TaskService _taskService = TaskService();
  final CategoryService _categoryService = CategoryService();
  final AuthService _authService = AuthService();
  final HabitService _habitService = HabitService();
  final NotificationService _notificationService = NotificationService();
  final ApiService _apiService = ApiService();
  final SyncService _syncService = SyncService();
  final InspirationService _inspirationService = InspirationService();
  
  // Global key for SnackBar
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  DateTime _selectedDate = DateTime.now();
  List<Task> _activeTasks = [];
  List<Task> _completedTasks = [];
  List<Category> _categories = [];
  List<Habit> _dashboardHabits = [];
  Map<int, bool> _habitCompletionStatus = {};
  User? _currentUser;
  int? _selectedCategoryId;
  int? _selectedPriority;
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  bool _showInspiration = true;
  String _inspirationType = 'quote'; // 'quote' or 'activity'
  DateTime? _lastSyncTime;
  
  // Kaydırma denetleyicisi
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR');
    
    // Bildirim servisini başlat
    _notificationService.init();
    
    // Senkronizasyon servisini başlat
    _syncService.initialize(widget.userId);
    
    // Verileri yükle
    _loadData();
    _loadUserInfo();
    _loadLastSyncTime();
    
    // Internet bağlantısı değişikliklerini dinle
    final connectivityService = ConnectivityService();
    connectivityService.connectionStream.listen(_onConnectivityChanged);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // İnternet bağlantısı değişikliklerini dinle
  void _onConnectivityChanged(dynamic result) {
    // ConnectivityResult tipinde
    if (result != null && mounted) {
      // Bağlantı değişikliğinde bildirim göster
      ConnectivityService.showConnectivitySnackBar(context, result);
      
      // Bağlantı kurulduysa ve çevrimiçi mod aktifse, senkronizasyonu başlat
      final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
      if (connectivityProvider.canPerformOnlineOperations) {
        _syncData();
      }
    }
  }
  
  // Son senkronizasyon zamanını yükle
  Future<void> _loadLastSyncTime() async {
    final time = await _syncService.getLastSyncTime();
    if (mounted) {
      setState(() {
        _lastSyncTime = time;
      });
    }
  }
  
  // Senkronizasyonu başlat
  Future<void> _syncData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      await _syncService.syncAll(widget.userId);
      
      // Veriler güncellendiği için yeniden yükle
      await _loadData();
      
      // Son senkronizasyon zamanını güncelle
      await _loadLastSyncTime();
      
      if (mounted) {
        _showSnackBar(
          'Veriler başarıyla senkronize edildi',
          backgroundColor: AppColors.successColor,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Veri senkronizasyonu sırasında bir hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted && user != null) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  // Helper method to show snackbar safely
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(8),
          duration: const Duration(seconds: 3),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      // Önce çevrimiçi servisi kontrol et
      final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
      if (connectivityProvider.canPerformOnlineOperations) {
        try {
          // API'dan verileri yüklemeyi dene
          final onlineTasks = await _apiService.getTasksByDate(widget.userId, dateStr);
          
          if (onlineTasks.isNotEmpty) {
            // Online veriler başarıyla alındıysa kullan
            final activeTasks = onlineTasks.where((task) => !task.isCompleted).toList();
            final completedTasks = onlineTasks.where((task) => task.isCompleted).toList();
            
            if (mounted) {
              setState(() {
                _activeTasks = activeTasks;
                _completedTasks = completedTasks;
              });
            }
          } else {
            // Online veriler boşsa, yerel veritabanını kullan
            await _loadLocalData(dateStr);
          }
        } catch (e) {
          // API hatası durumunda yerel veritabanını kullan
          debugPrint('API error, falling back to local database: $e');
          await _loadLocalData(dateStr);
        }
      } else {
        // Çevrimdışı modda yerel veritabanını kullan
        await _loadLocalData(dateStr);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Veriler yüklenirken bir hata oluştu: $e');
      }
    }
  }
  
  // Yerel veritabanından verileri yükle
  Future<void> _loadLocalData(String dateStr) async {
    // Load categories
    final categories = await _categoryService.getCategories(widget.userId);

    // Load tasks for the selected date
    final tasks = _isSearching
        ? await _taskService.searchTasks(widget.userId, _searchQuery)
        : await _taskService.getFilteredTasks(
            widget.userId,
            date: dateStr,
            categoryId: _selectedCategoryId,
            priority: _selectedPriority,
          );

    final activeTasks = tasks.where((task) => !task.isCompleted).toList();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    // Load habits for the dashboard
    final dashboardHabits = await _habitService.getDashboardHabits(
      widget.userId,
      date: dateStr,
    );

    // Habit tamamlanma durumlarını kontrol et
    final habitCompletionStatus = <int, bool>{};
    for (var habit in dashboardHabits) {
      if (habit.id != null) {
        final isCompleted = await _habitService.isHabitCompletedOnDate(
          habit.id!,
          dateStr,
        );
        habitCompletionStatus[habit.id!] = isCompleted;
      }
    }

    if (mounted) {
      setState(() {
        _categories = categories;
        _activeTasks = activeTasks;
        _completedTasks = completedTasks;
        _dashboardHabits = dashboardHabits;
        _habitCompletionStatus = habitCompletionStatus;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      // Material 3 uyumlu tarih seçici
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        // Material You tasarımı
        builder: (context, child) {
          if (child == null) return Container();
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme,
            ),
            child: child,
          );
        },
      );

      if (!mounted) return;

      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Tarih seçilirken bir hata oluştu: $e');
      }
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadData();
  }

  // Görev tamamlama durumunu güncelleme
  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      // Çevrimiçi işlem yapılabilir mi kontrol et
      final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
      
      // Yerel veritabanında güncelleme yap
      final success = await _taskService.toggleTaskCompletion(
        task.id!,
        !task.isCompleted,
      );

      if (success) {
        // Görev tamamlandığında bildirimi iptal et
        if (task.isCompleted == false) {
          // Görev yeni tamamlandıysa bildirimini iptal et
          await _notificationService.cancelTaskReminder(task.id!);
        } else {
          // Görev tamamlanmadan geri alındıysa yeniden bildirim planla
          if (task.time != null) {
            await _notificationService.scheduleTaskReminder(task);
          }
        }
        
        // Çevrimiçi güncellenebilir mi?
        if (connectivityProvider.canPerformOnlineOperations) {
          try {
            // API üzerinde güncelleme yap
            await _apiService.toggleTaskCompletion(task.id!, !task.isCompleted);
          } catch (e) {
            // API hatası durumunda senkronizasyon servisine ekle
            await _syncService.addOperation(
              'task', 
              'toggle_completion', 
              {
                'id': task.id!,
                'isCompleted': !task.isCompleted,
              },
            );
          }
        } else {
          // Çevrimdışı modda senkronizasyon servisine ekle
          await _syncService.addOperation(
            'task', 
            'toggle_completion', 
            {
              'id': task.id!,
              'isCompleted': !task.isCompleted,
            },
          );
        }
        
        _loadData();
      } else {
        if (mounted) {
          _showSnackBar('Görev durumu güncellenirken bir hata oluştu.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Görev durumu güncellenirken bir hata oluştu: $e');
      }
    }
  }

  Future<void> _toggleHabitCompletion(Habit habit) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final isCurrentlyCompleted = _habitCompletionStatus[habit.id] ?? false;

      final success = await _habitService.toggleHabitCompletion(
        habit.id!,
        dateStr,
        !isCurrentlyCompleted,
      );

      if (success) {
        // Çevrimiçi işlem durumunu kontrol et
        final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
        if (connectivityProvider.canPerformOnlineOperations) {
          // API işlemi eklenebilir
        } else {
          // Çevrimdışı modda senkronizasyon servisine ekle
          await _syncService.addOperation(
            'habit', 
            'toggle_completion', 
            {
              'habitId': habit.id!,
              'date': dateStr,
              'completed': !isCurrentlyCompleted,
            },
          );
        }
        
        _loadData();
      } else {
        if (mounted) {
          _showSnackBar('Alışkanlık durumu güncellenirken bir hata oluştu.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Alışkanlık durumu güncellenirken bir hata oluştu: $e');
      }
    }
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sürüklenebilir tutaç
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Sıralama Seçenekleri',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildSortOption(
                          context: context,
                          icon: Icons.calendar_today,
                          title: AppTexts.sortByDate,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _activeTasks.sort((a, b) => a.date.compareTo(b.date));
                              _completedTasks.sort((a, b) => a.date.compareTo(b.date));
                            });
                          },
                        ),
                        _buildSortOption(
                          context: context,
                          icon: Icons.access_time,
                          title: AppTexts.sortByTime,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _activeTasks.sort((a, b) {
                                if (a.time == null) return 1;
                                if (b.time == null) return -1;
                                return a.time!.compareTo(b.time!);
                              });
                              _completedTasks.sort((a, b) {
                                if (a.time == null) return 1;
                                if (b.time == null) return -1;
                                return a.time!.compareTo(b.time!);
                              });
                            });
                          },
                        ),
                        _buildSortOption(
                          context: context,
                          icon: Icons.flag,
                          title: AppTexts.sortByPriority,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _activeTasks.sort((a, b) => b.priority.value.compareTo(a.priority.value));
                              _completedTasks.sort((a, b) => b.priority.value.compareTo(a.priority.value));
                            });
                          },
                        ),
                        _buildSortOption(
                          context: context,
                          icon: Icons.category,
                          title: AppTexts.sortByCategory,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _activeTasks.sort((a, b) {
                                if (a.categoryId == null) return 1;
                                if (b.categoryId == null) return -1;
                                return a.categoryId!.compareTo(b.categoryId!);
                              });
                              _completedTasks.sort((a, b) {
                                if (a.categoryId == null) return 1;
                                if (b.categoryId == null) return -1;
                                return a.categoryId!.compareTo(b.categoryId!);
                              });
                            });
                          },
                        ),
                        _buildSortOption(
                          context: context,
                          icon: Icons.sort,
                          title: AppTexts.sortByCreation,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _activeTasks.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
                              _completedTasks.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Sıralama seçeneği satırı
  Widget _buildSortOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sürüklenebilir tutaç
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            _userInitial,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser?.username ?? 'Kullanıcı',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              _currentUser?.email ?? 'email@example.com',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 32),
                  
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildMenuOption(
                          context: context,
                          icon: Icons.task_alt,
                          title: AppTexts.activeTasks,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActiveTasksScreen(userId: widget.userId),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        _buildMenuOption(
                          context: context,
                          icon: Icons.done_all,
                          title: AppTexts.completedTasks,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CompletedTasksScreen(userId: widget.userId),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        _buildMenuOption(
                          context: context,
                          icon: Icons.category,
                          title: AppTexts.categories,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoriesScreen(userId: widget.userId),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        _buildMenuOption(
                          context: context,
                          icon: Icons.repeat,
                          title: AppTexts.habits,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HabitsScreen(userId: widget.userId),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        _buildMenuOption(
                          context: context,
                          icon: Icons.person,
                          title: AppTexts.profile,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileScreen(userId: widget.userId),
                              ),
                            ).then((_) {
                              _loadData();
                              _loadUserInfo();
                            });
                          },
                        ),
                        
                        // Çevrimiçi/Çevrimdışı mod seçeneği
                        Consumer<ConnectivityProvider>(
                          builder: (context, connectivity, _) {
                            return SwitchListTile(
                              secondary: Icon(
                                connectivity.isOnlineMode
                                    ? Icons.cloud_done
                                    : Icons.cloud_off,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                connectivity.isOnlineMode
                                    ? 'Çevrimiçi Mod'
                                    : 'Çevrimdışı Mod',
                              ),
                              subtitle: Text(
                                connectivity.isOnlineMode
                                    ? 'Veriler sunucuyla senkronize edilecek'
                                    : 'Veriler yalnızca yerel olarak saklanacak',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              value: connectivity.isOnlineMode,
                              onChanged: (value) {
                                connectivity.toggleOnlineMode();
                                if (value && connectivity.hasConnection) {
                                  // Çevrimiçi moda geçiş yapıldıysa ve internet bağlantısı varsa, senkronizasyonu başlat
                                  _syncData();
                                }
                                Navigator.pop(context);
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                            );
                          },
                        ),
                        
                        // Tema seçeneği
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return SwitchListTile(
                              secondary: Icon(
                                themeProvider.isDarkMode
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: Theme.of(context).colorScheme.primary,
                                semanticLabel: themeProvider.isDarkMode
                                    ? 'Koyu tema aktif'
                                    : 'Açık tema aktif',
                              ),
                              title: Text(
                                themeProvider.isDarkMode
                                    ? AppTexts.darkTheme
                                    : AppTexts.lightTheme,
                              ),
                              value: themeProvider.isDarkMode,
                              onChanged: (_) {
                                themeProvider.toggleTheme();
                                Navigator.pop(context);
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                            );
                          },
                        ),
                        
                        // Senkronizasyon seçeneği
                        _buildMenuOption(
                          context: context,
                          icon: Icons.sync,
                          title: 'Verileri Senkronize Et',
                          subtitle: _lastSyncTime != null
                              ? 'Son senkronizasyon: ${DateFormat('d MMM HH:mm', 'tr_TR').format(_lastSyncTime!)}'
                              : 'Henüz senkronize edilmedi',
                          onTap: () {
                            Navigator.pop(context);
                            _syncData();
                          },
                        ),
                        
                        // Motivasyon seçeneği
                        SwitchListTile(
                          secondary: Icon(
                            _showInspiration
                                ? Icons.lightbulb
                                : Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: const Text('Motivasyon İçeriği'),
                          subtitle: const Text('Alıntılar ve aktivite önerileri'),
                          value: _showInspiration,
                          onChanged: (value) {
                            setState(() {
                              _showInspiration = value;
                            });
                            Navigator.pop(context);
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Menü seçeneği satırı
  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    try {
      // Yerel veritabanından sil
      final success = await _taskService.deleteTask(task.id!);
      
      if (success) {
        // Bildirimi iptal et
        await _notificationService.cancelTaskReminder(task.id!);
        
        // Çevrimiçi olarak silme işlemi
        final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
        if (connectivityProvider.canPerformOnlineOperations) {
          try {
            // API üzerinden silme işlemi
            await _apiService.deleteTask(task.id!);
          } catch (e) {
            // API hatası durumunda senkronizasyon servisine ekle
            await _syncService.addOperation(
              'task', 
              'delete', 
              {'id': task.id!},
            );
          }
        } else {
          // Çevrimdışı modda senkronizasyon servisine ekle
          await _syncService.addOperation(
            'task', 
            'delete', 
            {'id': task.id!},
          );
        }
        
        _loadData();
        if (mounted) {
          _showSnackBar(
            AppTexts.taskDeleted,
            backgroundColor: AppColors.successColor,
          );
        }
      } else {
        if (mounted) {
          _showSnackBar('Görev silinirken bir hata oluştu.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Görev silinirken bir hata oluştu: $e');
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Görevi Sil'),
          content: const Text('Bu görevi silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTask(task);
              },
              child: Text(
                AppTexts.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
  
  // Arama fonksiyonu
  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }
  
  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
    _loadData();
  }
  
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadData();
  }
  
  // Motivasyon alıntısı tipini değiştir
  void _toggleInspirationType() {
    setState(() {
      _inspirationType = _inspirationType == 'quote' ? 'activity' : 'quote';
    });
  }

  // Get user's first initial, or fallback to user ID if no username available
  String get _userInitial {
    if (_currentUser?.username.isNotEmpty == true) {
      return _currentUser!.username[0].toUpperCase();
    }
    return widget.userId.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dashboard'da gösterilecek aktif alışkanlıkları filtrele
    final activeHabits = _dashboardHabits
        .where((habit) => !(_habitCompletionStatus[habit.id] ?? false))
        .toList();

    // Dashboard'da gösterilecek tamamlanmış alışkanlıkları filtrele
    final completedHabits = _dashboardHabits
        .where((habit) => _habitCompletionStatus[habit.id] ?? false)
        .toList();

    final formattedDate = DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate);

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: [
            // Bağlantı durumu çubuğu
            Consumer<ConnectivityProvider>(
              builder: (context, connectivity, _) {
                return ConnectionStatusBar(
                  showOnlineSwitch: false,
                );
              },
            ),
            
            // Ana içerik
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Veriler yükleniyor',
                      ),
                    )
                  : Column(
                      children: [
                        // App bar
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: colorScheme.primary,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showProfileMenu(context),
                                    child: Semantics(
                                      label: _currentUser != null
                                          ? '${_currentUser!.username} profili'
                                          : 'Kullanıcı profili',
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white24,
                                        child: Text(
                                          _userInitial,
                                          style: TextStyle(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bugün, ${DateFormat('d MMMM', 'tr_TR').format(_selectedDate)}',
                                        style: TextStyle(
                                          color: colorScheme.onPrimary.withOpacity(0.8), 
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppTexts.taskBoard,
                                        style: TextStyle(
                                          color: colorScheme.onPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (_isSearching) ...[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: TextField(
                                          autofocus: true,
                                          onChanged: _performSearch,
                                          style: TextStyle(color: colorScheme.onPrimary),
                                          decoration: InputDecoration(
                                            hintText: 'Görev ara...',
                                            hintStyle: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Aramayı iptal et',
                                      icon: Icon(Icons.close, color: colorScheme.onPrimary),
                                      onPressed: _stopSearch,
                                    ),
                                  ] else ...[
                                    IconButton(
                                      tooltip: 'Ara',
                                      icon: Icon(Icons.search, color: colorScheme.onPrimary),
                                      onPressed: _startSearch,
                                    ),
                                    IconButton(
                                      tooltip: 'Tarih seçin',
                                      icon: Icon(
                                        Icons.calendar_today,
                                        color: colorScheme.onPrimary,
                                        semanticLabel: 'Tarih seçin',
                                      ),
                                      onPressed: () => _selectDate(context),
                                    ),
                                    IconButton(
                                      tooltip: 'Menüyü aç',
                                      icon: Icon(Icons.menu, color: colorScheme.onPrimary, 
                                          semanticLabel: 'Menüyü aç',),
                                      onPressed: () => _showProfileMenu(context),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Date navigation
                        if (!_isSearching)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  tooltip: 'Önceki gün',
                                  onPressed: () => _changeDate(-1),
                                  icon: const Icon(Icons.chevron_left, 
                                      semanticLabel: 'Önceki gün',),
                                ),
                                Semantics(
                                  label: 'Seçili tarih: $formattedDate',
                                  child: GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: Text(
                                      formattedDate,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Sonraki gün',
                                  onPressed: () => _changeDate(1),
                                  icon: const Icon(Icons.chevron_right, 
                                      semanticLabel: 'Sonraki gün',),
                                ),
                              ],
                            ),
                          ),

                        // Motivasyon içeriği
                        if (_showInspiration && !_isSearching)
                          InspirationCard(
                            type: _inspirationType,
                            onRefresh: _toggleInspirationType,
                          ),

                        // Filters
                        if (!_isSearching)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TaskFilter(
                              categories: _categories,
                              selectedCategoryId: _selectedCategoryId,
                              selectedPriority: _selectedPriority,
                              onCategoryChanged: (categoryId) {
                                setState(() {
                                  _selectedCategoryId = categoryId;
                                });
                                _loadData();
                              },
                              onPriorityChanged: (priority) {
                                setState(() {
                                  _selectedPriority = priority;
                                });
                                _loadData();
                              },
                            ),
                          ),

                        // Tasks list
                        Expanded(
                          child: ListView(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              // Active tasks section
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: colorScheme.error,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _isSearching 
                                              ? 'Arama Sonuçları' 
                                              : AppTexts.activeTasks,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      tooltip: 'Sıralama seçenekleri',
                                      icon: const Icon(Icons.sort, 
                                          semanticLabel: 'Sıralama seçenekleri',),
                                      onPressed: () => _showSortMenu(context),
                                    ),
                                  ],
                                ),
                              ),

                              // Aktif görevler ve aktif alışkanlıklar
                              if (_activeTasks.isEmpty && activeHabits.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Semantics(
                                      label: 'Aktif görev veya alışkanlık bulunamadı',
                                      child: Text(
                                        _isSearching
                                            ? 'Arama kriterine uygun görev bulunamadı'
                                            : 'Aktif görev bulunamadı',
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                // Aktif içerikleri animasyonla göster
                                Animate(
                                  effects: const [
                                    FadeEffect(duration: Duration(milliseconds: 300)),
                                    SlideEffect(
                                      begin: Offset(0, 0.1),
                                      end: Offset.zero,
                                      duration: Duration(milliseconds: 300),
                                    ),
                                  ],
                                  child: Column(
                                    children: [
                                      // Aktif görevler
                                      ..._activeTasks.map((task) {
                                        final category = task.categoryId != null
                                            ? _categories.firstWhere(
                                                (c) => c.id == task.categoryId,
                                                orElse: () => const Category(
                                                  name: 'Kategori Yok',
                                                  color: 0xFF9E9E9E,
                                                ),
                                              )
                                            : null;

                                        return TaskCard(
                                          task: task,
                                          category: category,
                                          onToggleCompletion: () =>
                                              _toggleTaskCompletion(task),
                                          onEdit: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => EditTaskScreen(
                                                  userId: widget.userId,
                                                  task: task,
                                                  categories: _categories,
                                                ),
                                              ),
                                            ).then((_) => _loadData());
                                          },
                                          onDelete: () =>
                                              _showDeleteConfirmation(context, task),
                                        );
                                      }),

                                      // Aktif alışkanlıklar
                                      ...activeHabits.map((habit) {
                                        return HabitCard(
                                          habit: habit,
                                          isCompleted: false,
                                          onToggleCompletion: () =>
                                              _toggleHabitCompletion(habit),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => HabitDetailsScreen(
                                                  habit: habit,
                                                  userId: widget.userId,
                                                ),
                                              ),
                                            ).then((_) => _loadData());
                                          },
                                        );
                                      }),
                                    ],
                                  ),
                                ),

                              // Tamamlanmış görevler bölümü (arama sırasında gösterme)
                              if (!_isSearching) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppTexts.completedTasks,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Tamamlanmış görevler ve tamamlanmış alışkanlıklar
                                if (_completedTasks.isEmpty && completedHabits.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Semantics(
                                        label: 'Tamamlanmış görev veya alışkanlık bulunamadı',
                                        child: Text(
                                          'Tamamlanmış görev bulunamadı',
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  // Tamamlanmış içerikleri animasyonla göster
                                  Animate(
                                    effects: const [
                                      FadeEffect(duration: Duration(milliseconds: 300)),
                                      SlideEffect(
                                        begin: Offset(0, 0.1),
                                        end: Offset.zero,
                                        duration: Duration(milliseconds: 300),
                                      ),
                                    ],
                                    child: Column(
                                      children: [
                                        // Tamamlanmış görevler
                                        ..._completedTasks.map((task) {
                                          final category = task.categoryId != null
                                              ? _categories.firstWhere(
                                                  (c) => c.id == task.categoryId,
                                                  orElse: () => const Category(
                                                    name: 'Kategori Yok',
                                                    color: 0xFF9E9E9E,
                                                  ),
                                                )
                                              : null;

                                          return TaskCard(
                                            task: task,
                                            category: category,
                                            onToggleCompletion: () =>
                                                _toggleTaskCompletion(task),
                                            onEdit: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => EditTaskScreen(
                                                    userId: widget.userId,
                                                    task: task,
                                                    categories: _categories,
                                                  ),
                                                ),
                                              ).then((_) => _loadData());
                                            },
                                            onDelete: () =>
                                                _showDeleteConfirmation(context, task),
                                          );
                                        }),

                                        // Tamamlanmış alışkanlıklar
                                        ...completedHabits.map((habit) {
                                          return HabitCard(
                                            habit: habit,
                                            isCompleted: true,
                                            onToggleCompletion: () =>
                                                _toggleHabitCompletion(habit),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => HabitDetailsScreen(
                                                    habit: habit,
                                                    userId: widget.userId,
                                                  ),
                                                ),
                                              ).then((_) => _loadData());
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, child) {
          // Senkronizasyon durumuna göre ek buton
          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Ana buton - Yeni görev ekle
              Semantics(
                label: 'Yeni görev ekle',
                button: true,
                child: FloatingActionButton(
                  tooltip: 'Yeni görev ekle',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTaskScreen(
                          userId: widget.userId,
                          categories: _categories,
                          initialDate: _selectedDate,
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.add),
                ).animate()
                  .scale(duration: 300.ms, curve: Curves.elasticOut),
              ),
              
              // Çevrimiçi-çevrimdışı durumu göster
              if (connectivity.isOnlineMode && connectivity.hasConnection)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primaryContainer,
                        width: 2,
                      ),
                    ),
                  ),
                )
              else if (!connectivity.hasConnection)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primaryContainer,
                        width: 2,
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primaryContainer,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
