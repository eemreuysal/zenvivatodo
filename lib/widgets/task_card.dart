import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../models/category.dart';
import '../models/task.dart';

// Modern material design ve Flutter 3.29 özelliklerini kullanan TaskCard
class TaskCard extends StatelessWidget {
  // Constructor moved to top
  const TaskCard({
    super.key,
    required this.task,
    this.category,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final Category? category;
  final VoidCallback onToggleCompletion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // Material 3 tasarım dilini kullanan UI bileşenleri
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Öncelik rengi
    final priorityColor = switch (task.priority) {
      TaskPriority.low => Colors.green,
      TaskPriority.medium => Colors.orange,
      TaskPriority.high => Colors.red,
    };
    
    // Kategori rengi veya varsayılan renk
    final categoryColor = category != null 
        ? Color(category!.color)
        : AppColors.defaultCategoryColor;
    
    // Zaman bilgisi formatı
    final hasTime = task.time != null && task.time!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black26,
      surfaceTintColor: colorScheme.surfaceTint,
      // Material 3 Card şekli
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: task.isCompleted 
            ? BorderSide(color: Colors.green.withARGB(128, Colors.green.red, Colors.green.green, Colors.green.blue), width: 1.5) 
            : BorderSide.none,
      ),
      // Animasyon eklendi - Flutter Animate paketi kullanılarak
      child: Animate(
        effects: [
          FadeEffect(duration: 300.ms),
          SlideEffect(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
            duration: 300.ms,
            curve: Curves.easeOutQuad,
          ),
        ],
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık ve işler
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tamamlandı işareti
                    Semantics(
                      label: task.isCompleted ? 'Tamamlandı, işareti kaldırmak için dokunun' : 'Tamamlanmadı, tamamlamak için dokunun',
                      child: InkWell(
                        onTap: onToggleCompletion,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8, top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.isCompleted ? Colors.green : Colors.transparent,
                            border: Border.all(
                              color: task.isCompleted ? Colors.green : colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: task.isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    
                    // Başlık ve açıklama
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık
                          Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? colorScheme.onSurface.withARGB(153, colorScheme.onSurface.red, colorScheme.onSurface.green, colorScheme.onSurface.blue) // 0.6 opacity
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          // Açıklama (varsa)
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Öncelik göstergesi
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: priorityColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Alt bilgiler
                Row(
                  children: [
                    // Kategori etiketi
                    if (category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withARGB(51, categoryColor.red, categoryColor.green, categoryColor.blue), // 0.2 opacity
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category!.name,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // Tarih ve saat
                    Icon(
                      Icons.event,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    if (hasTime) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.time!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Düzenleme ve silme butonları
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Düzenle',
                      onPressed: onEdit,
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        minimumSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Sil',
                      onPressed: onDelete,
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        minimumSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
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
}

// Hero animasyonlu görev detay kartı - Geçiş animasyonları için
class TaskHeroCard extends StatelessWidget {
  // Constructor moved to top
  const TaskHeroCard({
    super.key,
    required this.task,
    this.category,
  });
  
  final Task task;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final uniqueTag = 'task-${task.id}';
    
    return Hero(
      tag: uniqueTag,
      child: Material(
        type: MaterialType.transparency,
        child: TaskCard(
          task: task,
          category: category,
          onToggleCompletion: () {}, // Hero geçişi için boş fonksiyonlar
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );
  }
}