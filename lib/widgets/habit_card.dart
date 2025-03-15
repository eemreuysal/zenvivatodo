import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggleCompletion;
  final VoidCallback onTap;

  const HabitCard({
    Key? key,
    required this.habit,
    required this.isCompleted,
    required this.onToggleCompletion,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final habitColor = Color(habit.colorCode);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Tamamlanma durumu göstergesi
                  InkWell(
                    onTap: onToggleCompletion,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: habitColor,
                          width: 2,
                        ),
                        color: isCompleted ? habitColor : Colors.transparent,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Başlık
                  Expanded(
                    child: Row(
                      children: [
                        // Alışkanlık ikonu
                        CircleAvatar(
                          backgroundColor: isDarkMode 
                              ? habitColor.withAlpha(51) // 0.2 * 255 = 51
                              : habitColor.withAlpha(25), // 0.1 * 255 = 25
                          radius: 16,
                          child: Icon(
                            Icons.repeat,
                            size: 18,
                            color: habitColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // Alışkanlık başlığı
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              if (habit.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  habit.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Alışkanlık bilgileri
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Zincir (streak) bilgisi
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: habitColor.withAlpha(25), // 0.1 * 255 = 25
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: habitColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              habit.currentStreak.toString(),
                              style: TextStyle(
                                color: habitColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Frekans bilgisi
                      Text(
                        _getFrequencyText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withAlpha(153), // 0.6 * 255 = 153
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getFrequencyText() {
    switch (habit.frequency) {
      case 'daily':
        return 'Her Gün';
      case 'weekly':
        return 'Haftalık';
      case 'monthly':
        return 'Aylık';
      default:
        return '';
    }
  }
}