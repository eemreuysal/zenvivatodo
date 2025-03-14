import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../models/task.dart';
import '../../models/category.dart';
import '../../services/task_service.dart';
import '../../services/category_service.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_filter.dart';
import '../tasks/add_task_screen.dart';
import '../tasks/edit_task_screen.dart';
import '../tasks/active_tasks_screen.dart';
import '../tasks/completed_tasks_screen.dart';
import '../categories/categories_screen.dart';
import '../profile/profile_screen.dart';
import '../../main.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;

  const DashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TaskService _taskService = TaskService();
  final CategoryService _categoryService = CategoryService();

  DateTime _selectedDate = DateTime.now();
  List<Task> _activeTasks = [];
  List<Task> _completedTasks = [];
  List<Category> _categories = [];
  int? _selectedCategoryId;
  int? _selectedPriority;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load categories
      final categories = await _categoryService.getCategories(widget.userId);

      // Load tasks for the selected date
      final tasks = await _taskService.getFilteredTasks(
        widget.userId,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
      );

      final activeTasks = tasks.where((task) => !task.isCompleted).toList();
      final completedTasks = tasks.where((task) => task.isCompleted).toList();

      if (mounted) {
        setState(() {
          _categories = categories;
          _activeTasks = activeTasks;
          _completedTasks = completedTasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veriler yüklenirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        // Locale kaldırıldı veya düzeltildi
        builder: (context, child) {
          if (child == null) return Container();
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
                onPrimary: Colors.white,
                onSurface: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            child: child,
          );
        },
      );

      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarih seçilirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadData();
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      final success = await _taskService.toggleTaskCompletion(
        task.id!,
        !task.isCompleted,
      );

      if (success) {
        _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Görev durumu güncellenirken bir hata oluştu.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev durumu güncellenirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text(AppTexts.sortByDate),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by date
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text(AppTexts.sortByTime),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by time
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text(AppTexts.sortByPriority),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by priority
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text(AppTexts.sortByCategory),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by category
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text(AppTexts.sortByCreation),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by creation order
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.task_alt),
                title: const Text(AppTexts.activeTasks),
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
              ListTile(
                leading: const Icon(Icons.done_all),
                title: const Text(AppTexts.completedTasks),
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
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text(AppTexts.categories),
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
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text(AppTexts.profile),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(userId: widget.userId),
                    ),
                  ).then((_) => _loadData());
                },
              ),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
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
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteTask(Task task) async {
    try {
      final success = await _taskService.deleteTask(task.id!);
      if (success) {
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppTexts.taskDeleted),
              backgroundColor: AppColors.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Görev silinirken bir hata oluştu.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev silinirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Date and profile section
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.primaryColor,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Text(
                            widget.userId.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bugün, ${DateFormat('d MMMM', 'tr_TR').format(_selectedDate)}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            // Aşağıdaki Text widget'ı sabit içerik kullandığı için const ile tanımlandı
                            const Text(
                              AppTexts.taskBoard,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                          onPressed: () => _selectDate(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => _showProfileMenu(context),
                        ),
                      ],
                    ),
                  ),

                  // Date navigation
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => _changeDate(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Text(
                            DateFormat('d MMMM yyyy', 'tr_TR')
                                .format(_selectedDate),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _changeDate(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),

                  // Filters
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
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppTexts.activeTasks,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.sort),
                                onPressed: () => _showSortMenu(context),
                              ),
                            ],
                          ),
                        ),
                        _activeTasks.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Aktif görev bulunamadı',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              )
                            : Column(
                                children: _activeTasks.map((task) {
                                  final category = task.categoryId != null
                                      ? _categories.firstWhere(
                                          (c) => c.id == task.categoryId,
                                          orElse: () => Category(
                                            name: 'Kategori Yok',
                                            color: const Color(0xFF9E9E9E)
                                                .value,
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
                                }).toList(),
                              ),

                        // Completed tasks section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
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
                        _completedTasks.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Tamamlanmış görev bulunamadı',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              )
                            : Column(
                                children: _completedTasks.map((task) {
                                  final category = task.categoryId != null
                                      ? _categories.firstWhere(
                                          (c) => c.id == task.categoryId,
                                          orElse: () => Category(
                                            name: 'Kategori Yok',
                                            color: const Color(0xFF9E9E9E)
                                                .value,
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
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
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
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
