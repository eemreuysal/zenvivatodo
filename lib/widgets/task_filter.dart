import 'package:flutter/material.dart';
import '../constants/app_texts.dart';
import '../constants/app_colors.dart';
import '../models/category.dart';
import '../models/priority.dart';

class TaskFilter extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final int? selectedPriority;
  final Function(int?) onCategoryChanged;
  final Function(int?) onPriorityChanged;

  const TaskFilter({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.selectedPriority,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chipBackground = isDarkMode ? AppColors.darkCardColor : Colors.transparent;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Categories filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text(AppTexts.allCategories),
                  selected: selectedCategoryId == null,
                  onSelected: (_) => onCategoryChanged(null),
                  backgroundColor: chipBackground,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(128),
                    ),
                  ),
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(isDarkMode ? 50 : 26),
                  labelStyle: TextStyle(
                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                  ),
                  checkmarkColor: isDarkMode ? AppColors.darkTextColor : null,
                ),
                const SizedBox(width: 8),
                ...categories.map((category) {
                  final categoryColor = Color(category.color);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: selectedCategoryId == category.id,
                      onSelected: (_) => onCategoryChanged(category.id),
                      backgroundColor: chipBackground,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: categoryColor.withAlpha(128),
                        ),
                      ),
                      selectedColor: categoryColor.withAlpha(isDarkMode ? 50 : 26),
                      labelStyle: TextStyle(
                        color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                      ),
                      checkmarkColor: isDarkMode ? AppColors.darkTextColor : null,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Priorities filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text(AppTexts.allPriorities),
                  selected: selectedPriority == null,
                  onSelected: (_) => onPriorityChanged(null),
                  backgroundColor: chipBackground,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
                    ),
                  ),
                  selectedColor: (isDarkMode ? Colors.grey.shade700 : Colors.grey).withAlpha(isDarkMode ? 100 : 26),
                  labelStyle: TextStyle(
                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                  ),
                  checkmarkColor: isDarkMode ? AppColors.darkTextColor : null,
                ),
                const SizedBox(width: 8),
                _buildPriorityChip(Priority.high, isDarkMode),
                const SizedBox(width: 8),
                _buildPriorityChip(Priority.medium, isDarkMode),
                const SizedBox(width: 8),
                _buildPriorityChip(Priority.low, isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(Priority priority, bool isDarkMode) {
    Color chipColor;
    switch (priority) {
      case Priority.high:
        chipColor = AppColors.highPriorityColor;
        break;
      case Priority.medium:
        chipColor = AppColors.mediumPriorityColor;
        break;
      case Priority.low:
        chipColor = AppColors.lowPriorityColor;
        break;
    }

    return FilterChip(
      label: Text(priority.name),
      selected: selectedPriority == priority.value,
      onSelected: (_) => onPriorityChanged(priority.value),
      backgroundColor: isDarkMode ? AppColors.darkCardColor : Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: chipColor.withAlpha(128))),
      selectedColor: chipColor.withAlpha(isDarkMode ? 70 : 26),
      labelStyle: TextStyle(
        color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
      ),
      checkmarkColor: isDarkMode ? AppColors.darkTextColor : null,
    );
  }
}
