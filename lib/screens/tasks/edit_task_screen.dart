import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../models/category.dart';
import '../../models/priority.dart';
import '../../models/task.dart';
import '../../services/category_service.dart';
import '../../services/task_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/date_picker.dart';
import '../../widgets/time_picker.dart';

class EditTaskScreen extends StatefulWidget {

  const EditTaskScreen({
    super.key,
    required this.userId,
    required this.task,
    required this.categories,
  });
  final int userId;
  final Task task;
  final List<Category> categories;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  Category? _selectedCategory;
  late Priority _selectedPriority;
  bool _isLoading = false;

  final TaskService _taskService = TaskService();
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _selectedDate = DateTime.parse(widget.task.date);

    if (widget.task.time != null) {
      final timeParts = widget.task.time!.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    _categories = widget.categories;

    if (widget.task.categoryId != null) {
      _selectedCategory = _categories.firstWhere(
        (c) => c.id == widget.task.categoryId,
        orElse: () => _categories.isNotEmpty
            ? _categories.first
            : Category(name: 'Kategori Yok', color: Colors.grey.value),
      );
    } else {
      _selectedCategory = _categories.isNotEmpty
          ? _categories.first
          : Category(name: 'Kategori Yok', color: Colors.grey.value);
    }

    _selectedPriority = PriorityExtension.fromValue(widget.task.priority.value);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedTask = Task(
          id: widget.task.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
          time: _selectedTime != null
              ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
              : null,
          isCompleted: widget.task.isCompleted,
          categoryId: _selectedCategory?.id,
          priority: _selectedPriority.value, // Burada .value kullanarak TaskPriority yerine int kullanıyoruz
          userId: widget.userId,
        );

        final success = await _taskService.updateTask(updatedTask);

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppTexts.taskUpdated),
              backgroundColor: AppColors.successColor,
            ),
          );
          Navigator.pop(context);
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Görev güncellenirken bir hata oluştu.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on Exception catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev güncellenirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController categoryNameController =
        TextEditingController();
    const Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.addCategory),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryNameController,
                decoration: const InputDecoration(
                  labelText: AppTexts.categoryName,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (categoryNameController.text.isNotEmpty) {
                  Navigator.pop(dialogContext);

                  final category = Category(
                    name: categoryNameController.text.trim(),
                    color: selectedColor.value,
                    userId: widget.userId,
                  );

                  try {
                    final success = await _categoryService.addCategory(
                      category,
                    );

                    if (!mounted) return;

                    if (success) {
                      // Reload categories
                      final updatedCategories =
                          await _categoryService.getCategories(widget.userId);

                      if (!mounted) return;

                      setState(() {
                        _categories = updatedCategories;
                        _selectedCategory = _categories.firstWhere(
                          (c) => c.name == category.name,
                          orElse: () => _categories.first,
                        );
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(AppTexts.categoryAdded),
                          backgroundColor: AppColors.successColor,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Kategori eklenirken bir hata oluştu.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } on Exception catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Kategori eklenirken bir hata oluştu: $e',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(AppTexts.save),
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
      appBar: AppBar(
        title: const Text(AppTexts.editTask),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Title
                const Text(
                  'Başlık',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Görev başlığını girin',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppTexts.requiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Açıklama',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Görev açıklamasını girin',
                  maxLines: 3,
                  maxLength: 200,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppTexts.requiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Due date
                const Text(
                  'Bitiş Tarihi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DatePickerWidget(
                  selectedDate: _selectedDate,
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Due time (optional)
                const Text(
                  'Bitiş Saati',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TimePickerWidget(
                  selectedTime: _selectedTime,
                  onTimeChanged: (time) {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _showAddCategoryDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.inputDecorationTheme.enabledBorder
                              ?.borderSide.color ??
                          Colors.grey.withAlpha(76),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: theme.inputDecorationTheme.fillColor,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Category>(
                      isExpanded: true,
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(category.color & 0xFFFFFFFF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Priority
                const Text(
                  'Öncelik',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriorityButton(
                        Priority.low,
                        AppColors.lowPriorityColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityButton(
                        Priority.medium,
                        AppColors.mediumPriorityColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityButton(
                        Priority.high,
                        AppColors.highPriorityColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save and cancel buttons
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: [
                      CustomButton(text: AppTexts.save, onPressed: _updateTask),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: AppTexts.cancel,
                        onPressed: () => Navigator.pop(context),
                        isOutlined: true,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityButton(Priority priority, Color color) {
    final bool isSelected = _selectedPriority == priority;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Text(
            priority.name,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}