import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../models/task.dart';
import '../../models/category.dart';
import '../../services/task_service.dart';
import '../../services/category_service.dart';
import '../../services/reminder_service.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_filter.dart';
import '../../widgets/reminder_dialog.dart';
import 'edit_task_screen.dart';

class ActiveTasksScreen extends StatefulWidget {
  final int userId;

  const ActiveTasksScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ActiveTasksScreen> createState() => _ActiveTasksScreenState();
}

class _ActiveTasksScreenState extends State<ActiveTasksScreen> {
  final TaskService _taskService = TaskService();
  final CategoryService _categoryService = CategoryService();
  final ReminderService _reminderService = ReminderService();

  List<Task> _tasks = [];
  List<Category> _categories = [];
  int? _selectedCategoryId;
  int? _selectedPriority;
  bool _isLoading = true;
  StreamSubscription? _reminderSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Listen for task reminders
    _reminderSubscription = _reminderService.onTaskReminder.listen(_showReminderDialog);
  }
  
  @override
  void dispose() {
    _reminderSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load categories
      final categories = await _categoryService.getCategories(widget.userId);

      // Load active tasks
      final tasks = await _taskService.getFilteredTasks(
        widget.userId,
        isCompleted: false,
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
      );

      if (mounted) {
        setState(() {
          _categories = categories;
          _tasks = tasks;
          _isLoading = false;
        });
        
        // Update reminder service with current tasks
        _reminderService.setTasks(tasks);
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

  // Show reminder dialog when a task is about to start
  void _showReminderDialog(Task task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ReminderDialog(
          task: task,
          onDismiss: () {
            Navigator.pop(dialogContext);
          },
          onViewTask: () {
            Navigator.pop(dialogContext);
            _navigateToEditTask(task);
          },
        );
      },
    );
  }

  void _navigateToEditTask(Task task) {
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
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      final success = await _taskService.toggleTaskCompletion(
        task.id!,
        !task.isCompleted,
      );

      if (!mounted) return;

      if (success) {
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görev durumu güncellenirken bir hata oluştu.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev durumu güncellenirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      final success = await _taskService.deleteTask(task.id!);

      if (!mounted) return;

      if (success) {
        // Remove task from reminder service
        _reminderService.removeTaskById(task.id!);
        
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppTexts.taskDeleted),
            backgroundColor: AppColors.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görev silinirken bir hata oluştu.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev silinirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Görevi Sil'),
          content: const Text('Bu görevi silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
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

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (dialogContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text(AppTexts.sortByDate),
                onTap: () {
                  Navigator.pop(dialogContext);
                  // Implement sorting by date
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text(AppTexts.sortByTime),
                onTap: () {
                  Navigator.pop(dialogContext);
                  // Implement sorting by time
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text(AppTexts.sortByPriority),
                onTap: () {
                  Navigator.pop(dialogContext);
                  // Implement sorting by priority
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text(AppTexts.sortByCategory),
                onTap: () {
                  Navigator.pop(dialogContext);
                  // Implement sorting by category
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text(AppTexts.sortByCreation),
                onTap: () {
                  Navigator.pop(dialogContext);
                  // Implement sorting by creation order
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.activeTasks),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortMenu(context),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Filters
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                    child: _tasks.isEmpty
                        ? Center(
                            child: Text(
                              'Aktif görev bulunamadı',
                              style: theme.textTheme.bodyLarge,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final task = _tasks[index];

                              // Find the category for this task
                              final category = task.categoryId != null
                                  ? _categories.firstWhere(
                                      (c) => c.id == task.categoryId,
                                      orElse: () => Category(
                                        name: 'Kategori Yok',
                                        color: Colors.grey.toARGB32(),
                                      ),
                                    )
                                  : null;

                              return TaskCard(
                                task: task,
                                category: category,
                                onToggleCompletion: () =>
                                    _toggleTaskCompletion(task),
                                onEdit: () {
                                  _navigateToEditTask(task);
                                },
                                onDelete: () => _showDeleteConfirmation(
                                  context,
                                  task,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
