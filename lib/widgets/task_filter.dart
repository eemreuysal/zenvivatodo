import 'package:flutter/material.dart';
import '../constants/app_texts.dart';
import '../models/category.dart';
import '../models/priority.dart';

class TaskFilter extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final int? selectedPriority;
  final Function(int?) onCategoryChanged;
  final Function(int?) onPriorityChanged;

  const TaskFilter({
    Key? key,
    required this.categories,
    this.selectedCategoryId,
    this.selectedPriority,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: Colors.transparent,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: selectedCategoryId == category.id,
                      onSelected: (_) => onCategoryChanged(category.id),
                      backgroundColor: Colors.transparent,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Color(category.color).withOpacity(0.5),
                        ),
                      ),
                      selectedColor: Color(category.color).withOpacity(0.1),
                    ),
                  );
                }).toList(),
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
                  backgroundColor: Colors.transparent,
                  shape: const StadiumBorder(
                    side: BorderSide(color: Colors.grey),
                  ),
                  selectedColor: Colors.grey.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                _buildPriorityChip(Priority.high),
                const SizedBox(width: 8),
                _buildPriorityChip(Priority.medium),
                const SizedBox(width: 8),
                _buildPriorityChip(Priority.low),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(Priority priority) {
    Color chipColor;
    switch (priority) {
      case Priority.high:
        chipColor = Colors.red;
        break;
      case Priority.medium:
        chipColor = Colors.orange;
        break;
      case Priority.low:
        chipColor = Colors.blue;
        break;
    }

    return FilterChip(
      label: Text(priority.name),
      selected: selectedPriority == priority.value,
      onSelected: (_) => onPriorityChanged(priority.value),
      backgroundColor: Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: chipColor.withOpacity(0.5))),
      selectedColor: chipColor.withOpacity(0.1),
    );
  }
}
