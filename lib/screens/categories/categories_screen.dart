import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../../services/task_service.dart';
import '../../widgets/custom_button.dart';

class CategoriesScreen extends StatefulWidget {
  final int userId;

  const CategoriesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _categoryService = CategoryService();
  final TaskService _taskService = TaskService();

  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _categoryService.getCategories(widget.userId);
      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategoriler yüklenirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCategory(int categoryId) async {
    try {
      // İlk önce bu kategoriye ait görevleri kontrol et
      final tasks = await _taskService.getFilteredTasks(
        widget.userId,
        categoryId: categoryId,
      );

      if (!mounted) return;

      if (tasks.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Bu kategoriye ait görevler bulunduğu için silinemez.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await _categoryService.deleteCategory(categoryId);

      if (!mounted) return;

      if (success) {
        await _loadCategories();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppTexts.categoryDeleted),
            backgroundColor: AppColors.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kategori silinirken bir hata oluştu.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategori silinirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Kategoriyi Sil'),
          content: Text(
            '${category.name} kategorisini silmek istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteCategory(category.id!);
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

  void _showAddCategoryDialog() {
    final TextEditingController categoryNameController =
        TextEditingController();
    // Varsayılan renk seçenekleri
    final List<Color> colorOptions = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    Color selectedColor = colorOptions.first;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setState) {
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
                  const SizedBox(height: 16),
                  const Text(
                    'Renk Seçin',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: colorOptions.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
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
                        color: selectedColor.toARGB32(),
                        userId: widget.userId,
                      );

                      try {
                        final success =
                            await _categoryService.addCategory(category);

                        if (!mounted) return;

                        if (success) {
                          await _loadCategories();

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(AppTexts.categoryAdded),
                              backgroundColor: AppColors.successColor,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Kategori eklenirken bir hata oluştu.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Kategori eklenirken bir hata oluştu: $e'),
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
      },
    );
  }

  void _showEditCategoryDialog(Category category) {
    final TextEditingController categoryNameController =
        TextEditingController(text: category.name);
    // Varsayılan renk seçenekleri
    final List<Color> colorOptions = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    Color selectedColor = Color(category.color);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setState) {
            return AlertDialog(
              title: const Text(AppTexts.editCategory),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: categoryNameController,
                    decoration: const InputDecoration(
                      labelText: AppTexts.categoryName,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Renk Seçin',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: colorOptions.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor.toARGB32() == color.toARGB32()
                                ? Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
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

                      final updatedCategory = Category(
                        id: category.id,
                        name: categoryNameController.text.trim(),
                        color: selectedColor.toARGB32(),
                        userId: category.userId,
                      );

                      try {
                        final success = await _categoryService
                            .updateCategory(updatedCategory);

                        if (!mounted) return;

                        if (success) {
                          await _loadCategories();

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(AppTexts.categoryUpdated),
                              backgroundColor: AppColors.successColor,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Kategori güncellenirken bir hata oluştu.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Kategori güncellenirken bir hata oluştu: $e'),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.categories),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Henüz kategori eklenmemiş',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: AppTexts.addCategory,
                          onPressed: _showAddCategoryDialog,
                          width: 200,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      // Varsayılan kategori kontrolü (userId null ise)
                      final bool isDefaultCategory = category.userId == null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(category.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            category.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: isDefaultCategory
                              ? const Text(
                                  'Varsayılan',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () =>
                                          _showEditCategoryDialog(category),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _showDeleteConfirmation(
                                          context, category),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
