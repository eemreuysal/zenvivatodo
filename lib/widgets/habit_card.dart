import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'package:intl/intl.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isToday;
  final bool isCompleted;
  final Function(bool) onToggle;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCard({
    Key? key,
    required this.habit,
    this.isToday = false,
    this.isCompleted = false,
    required this.onToggle,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitColor = Color(habit.colorCode);
    final double progress = habit.targetDays > 0 
      ? habit.currentStreak / habit.targetDays 
      : 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: habitColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve işlem bölümü
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              title: Text(
                habit.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _getFrequencyText(habit),
                style: theme.textTheme.bodySmall,
              ),
              leading: CircleAvatar(
                backgroundColor: habitColor,
                child: Icon(
                  Icons.repeat,
                  color: Colors.white,
                ),
              ),
              trailing: isToday
                  ? Checkbox(
                      value: isCompleted,
                      onChanged: (value) => onToggle(value ?? false),
                      activeColor: habitColor,
                    )
                  : null,
            ),

            // Açıklama (varsa)
            if (habit.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  habit.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // İlerleme bölümü
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mevcut zincir: ${habit.currentStreak} gün',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Hedef: ${habit.targetDays} gün',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // İlerleme çubuğu
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(habitColor),
                  minHeight: 8,
                ),
              ),
            ),

            // İşlem butonları (düzenle, sil)
            if (onEdit != null || onDelete != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Düzenle',
                        visualDensity: VisualDensity.compact,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: onDelete,
                        tooltip: 'Sil',
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getFrequencyText(Habit habit) {
    final startDate = DateFormat('dd MMMM yyyy', 'tr_TR')
        .format(DateTime.parse(habit.startDate));
    
    switch (habit.frequency) {
      case 'daily':
        return 'Her gün · Başlangıç: $startDate';
      case 'weekly':
        if (habit.frequencyDays != null && habit.frequencyDays!.isNotEmpty) {
          final days = habit.frequencyDays!.split(',')
              .map((day) => _getWeekdayName(int.parse(day)))
              .join(', ');
          return 'Haftada birkaç kez: $days · Başlangıç: $startDate';
        }
        return 'Haftada bir · Başlangıç: $startDate';
      case 'monthly':
        return 'Ayda bir · Başlangıç: $startDate';
      default:
        return 'Özel · Başlangıç: $startDate';
    }
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Pazartesi';
      case 2: return 'Salı';
      case 3: return 'Çarşamba';
      case 4: return 'Perşembe';
      case 5: return 'Cuma';
      case 6: return 'Cumartesi';
      case 7: return 'Pazar';
      default: return '';
    }
  }
}
