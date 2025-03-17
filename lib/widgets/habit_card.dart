import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggleCompletion;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggleCompletion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final habitColor = Color(habit.colorCode);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black26,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompleted 
            ? BorderSide(color: habitColor.withOpacity(0.5), width: 1.5) 
            : BorderSide.none,
      ),
      // Animasyon eklendi
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tamamlandı işareti
                    Semantics(
                      label: isCompleted 
                          ? 'Tamamlandı, işareti kaldırmak için dokunun' 
                          : 'Tamamlanmadı, tamamlamak için dokunun',
                      child: InkWell(
                        onTap: onToggleCompletion,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8, top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? habitColor : Colors.transparent,
                            border: Border.all(
                              color: isCompleted ? habitColor : colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    
                    // Başlık ve alışkanlık bilgisi
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık
                          Text(
                            habit.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? colorScheme.onSurface.withOpacity(0.6)
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          // Açıklama
                          if (habit.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              habit.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                decoration: isCompleted
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
                    
                    // Alışkanlık göstergesi
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: habitColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Alt bilgiler
                Row(
                  children: [
                    // Sıklık etiketi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: habitColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getFrequencyIcon(),
                            size: 12,
                            color: habitColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            habit.frequency.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: habitColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Zincir (Streak) göstergesi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 12,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak} gün',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Hedef
                    Text(
                      'Hedef: ${habit.targetDays} gün',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                // İlerleme çubuğu
                if (habit.targetDays > 0) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: habit.completionRate.clamp(0.0, 1.0),
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(habitColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Sıklık tipine göre ikon seçimi
  IconData _getFrequencyIcon() => switch (habit.frequency) {
    HabitFrequency.daily => Icons.calendar_today,
    HabitFrequency.weekly => Icons.view_week,
    HabitFrequency.monthly => Icons.calendar_month,
    HabitFrequency.custom => Icons.calendar_view_day,
  };
}

/// Hero animasyonlu geçiş için alışkanlık kartı
class HabitHeroCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;

  const HabitHeroCard({
    super.key,
    required this.habit,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final uniqueTag = 'habit-${habit.id}';
    
    return Hero(
      tag: uniqueTag,
      child: Material(
        type: MaterialType.transparency,
        child: HabitCard(
          habit: habit,
          isCompleted: isCompleted,
          onToggleCompletion: () {}, // Hero geçişi için boş fonksiyonlar
          onTap: () {},
        ),
      ),
    );
  }
}