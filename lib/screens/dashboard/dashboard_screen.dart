import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Düzeltme 1: Import sıralaması düzeltildi
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../services/auth_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/habit_service.dart';
import '../../services/task_service.dart';
import '../../widgets/connection_status_bar.dart';
import '../../widgets/inspiration_card.dart';
import '../categories/categories_screen.dart';
import '../habits/habits_screen.dart';
import '../profile/profile_screen.dart';
import '../tasks/active_tasks_screen.dart';
import '../tasks/completed_tasks_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.userId,
  });
  
  final int userId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late final TaskService _taskService;
  late final HabitService _habitService;
  String _username = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService();
    _habitService = HabitService();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().getUserById(widget.userId);
      if (user != null) {
        setState(() {
          _username = user.username;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      debugPrint('User loading error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final screens = [
      ActiveTasksScreen(userId: widget.userId),
      CompletedTasksScreen(userId: widget.userId),
      HabitsScreen(userId: widget.userId),
      CategoriesScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? '${AppTexts.welcome} $_username'
              : _getAppBarTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              connectivityProvider.isOnlineMode ? Icons.cloud_done : Icons.cloud_off,
              color: connectivityProvider.isOnlineMode
                  ? connectivityProvider.hasConnection
                      ? Colors.green
                      : Colors.orange
                  : Colors.grey,
            ),
            onPressed: () {
              connectivityProvider.toggleOnlineMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    connectivityProvider.isOnlineMode
                        ? 'Çevrimiçi mod aktif'
                        : 'Çevrimdışı mod aktif',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: connectivityProvider.isOnlineMode
                ? 'Çevrimiçi mod aktif'
                : 'Çevrimdışı mod aktif',
          ),
        ],
      ),
      body: Column(
        children: [
          // Bağlantı durumu gösterge çubuğu
          if (!connectivityProvider.hasConnection)
            const ConnectionStatusBar(),
          
          // Ana içerik
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _currentIndex == 0
                    ? _buildHomeScreen()
                    : screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Tamamlananlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            activeIcon: Icon(Icons.repeat_on),
            label: 'Alışkanlıklar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Kategoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: _currentIndex <= 2
          ? FloatingActionButton(
              onPressed: () {
                switch (_currentIndex) {
                  case 0:
                  case 1:
                    Navigator.pushNamed(context, '/add_task');
                    break;
                  case 2:
                    Navigator.pushNamed(context, '/add_habit');
                    break;
                }
              },
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHomeScreen() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // İlham verici alıntı kartı
        const InspirationCard(),
        
        const SizedBox(height: 24),
        
        // Bugün görevler
        _buildSectionHeader('Bugünkü Görevler', Icons.today),
        FutureBuilder(
          future: _taskService.getTodayTasks(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Görevler yüklenirken hata oluştu',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }
            
            final tasks = snapshot.data ?? [];
            
            if (tasks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text('Bugün için görev bulunmuyor'),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length > 5 ? 5 : tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  leading: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.isCompleted ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(task.time ?? 'Tüm gün'),
                  trailing: Icon(
                    Icons.circle,
                    color: _getPriorityColor(task.priorityValue),
                    size: 12,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_task',
                      arguments: task.id,
                    );
                  },
                );
              },
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Yaklaşan görevler
        _buildSectionHeader('Yaklaşan Görevler', Icons.event),
        FutureBuilder(
          future: _taskService.getUpcomingTasks(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Görevler yüklenirken hata oluştu',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }
            
            final tasks = snapshot.data ?? [];
            
            if (tasks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text('Yaklaşan görev bulunmuyor'),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length > 3 ? 3 : tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(task.title),
                  subtitle: Text(task.date),
                  trailing: Icon(
                    Icons.circle,
                    color: _getPriorityColor(task.priorityValue),
                    size: 12,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_task',
                      arguments: task.id,
                    );
                  },
                );
              },
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Alışkanlıklar
        _buildSectionHeader('Alışkanlıklar', Icons.repeat),
        FutureBuilder<List<dynamic>>(  // Düzeltme 2: Generic tip belirlendi
          future: _habitService.getDashboardHabits(
            userId: widget.userId, 
            date: DateTime.now().toString(),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Alışkanlıklar yüklenirken hata oluştu',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }
            
            final habits = snapshot.data ?? [];
            
            if (habits.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text('Panoda gösterilecek alışkanlık bulunmuyor'),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return ListTile(
                  leading: const Icon(Icons.repeat),
                  title: Text(habit.title),
                  subtitle: Text('${habit.currentStreak} gün seri'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/habit_details',
                      arguments: habit.id,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 1:
        return 'Tamamlanan Görevler';
      case 2:
        return 'Alışkanlıklar';
      case 3:
        return 'Kategoriler';
      case 4:
        return 'Profil';
      default:
        return AppTexts.appName;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}