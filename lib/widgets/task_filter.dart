import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_texts.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../utils/color_extensions.dart';

class TaskFilter extends StatelessWidget {
  const TaskFilter({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.selectedPriority,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
  });
  final List<Category> categories;
  final int? selectedCategoryId;
  final int? selectedPriority;
  final Function(int?) onCategoryChanged;
  final Function(int?) onPriorityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Animasyon etkisi için widget'ı sarmala
    return Animate(
      effects: [
        FadeEffect(
          duration: 300.ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtre başlığı
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Filtrele',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),

            // Kategoriler filtresi
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Tüm kategoriler seçeneği
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text(AppTexts.allCategories),
                      selected: selectedCategoryId == null,
                      onSelected: (_) => onCategoryChanged(null),
                      showCheckmark: false,
                      avatar: selectedCategoryId == null
                          ? Icon(Icons.check, size: 16, color: colorScheme.onPrimaryContainer)
                          : null,
                      labelStyle: TextStyle(
                        color: selectedCategoryId == null
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight:
                            selectedCategoryId == null ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.primaryContainer,
                      side: BorderSide(
                        color: selectedCategoryId == null
                            ? Colors.transparent
                            : colorScheme.outline.withAlphaValue(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),

                  // Diğer kategoriler
                  ...categories.map((category) {
                    final categoryColor = Color(category.color);
                    final isSelected = selectedCategoryId == category.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (_) => onCategoryChanged(category.id),
                        showCheckmark: false,
                        avatar: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: colorScheme.surface,
                        selectedColor: categoryColor,
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : categoryColor.withAlphaValue(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Öncelik filtresi
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Tüm öncelikler seçeneği
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text(AppTexts.allPriorities),
                      selected: selectedPriority == null,
                      onSelected: (_) => onPriorityChanged(null),
                      showCheckmark: false,
                      avatar: selectedPriority == null
                          ? Icon(Icons.check, size: 16, color: colorScheme.onPrimaryContainer)
                          : null,
                      labelStyle: TextStyle(
                        color: selectedPriority == null
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight: selectedPriority == null ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.primaryContainer,
                      side: BorderSide(
                        color: selectedPriority == null
                            ? Colors.transparent
                            : colorScheme.outline.withAlphaValue(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),

                  // Öncelikler
                  _buildPriorityChip(TaskPriority.high, context),
                  _buildPriorityChip(TaskPriority.medium, context),
                  _buildPriorityChip(TaskPriority.low, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedPriority == priority.value;

    // Öncelik rengi
    final priorityColor = switch (priority) {
      TaskPriority.high => Colors.red,
      TaskPriority.medium => Colors.orange,
      TaskPriority.low => Colors.green,
    };

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(priority.label),
        selected: isSelected,
        onSelected: (_) => onPriorityChanged(priority.value),
        showCheckmark: false,
        avatar: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: colorScheme.surface,
        selectedColor: priorityColor,
        side: BorderSide(
          color: isSelected ? Colors.transparent : priorityColor.withAlphaValue(0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
