import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit_log.dart';

/// Alışkanlıkların tamamlanma durumunu gösteren ısı haritası takvimi
class HabitHeatmap extends StatelessWidget {
  // Constructor moved to top of class
  const HabitHeatmap({
    super.key,
    required this.logs,
    required this.color,
    this.days = 30,
    this.onDayTap,
  });

  final List<HabitLog> logs;
  final Color color;
  final int days;
  final Function(String)? onDayTap;

  @override
  Widget build(BuildContext context) {
    // Son 'days' günlük tarih ve tamamlanma durumu haritasını hazırla
    final now = DateTime.now();
    final Map<String, bool> completedMap = {};

    // Verileri tarih formatında dictionary'e doldur
    for (var log in logs) {
      completedMap[log.date] = log.completed;
    }

    // Son X gün için bir liste oluştur (bugün dahil)
    final List<DateTime> datesList = List.generate(
      days,
      (index) => now.subtract(Duration(days: days - 1 - index)),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son $days Gün',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                _buildLegend(context),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: datesList.length,
              itemBuilder: (context, index) {
                final date = datesList[index];
                final dateStr = DateFormat('yyyy-MM-dd').format(date);
                final isCompleted = completedMap[dateStr] ?? false;
                final dayNumber = date.day;
                final isToday = DateUtils.isSameDay(date, now);

                return _buildDayCell(
                  context,
                  dayNumber,
                  dateStr,
                  isCompleted,
                  isToday,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    int dayNumber,
    String dateStr,
    bool isCompleted,
    bool isToday,
  ) {
    final baseColor = color;
    final completedColor = baseColor;
    // Double -> int dönüşümü ile Color.fromARGB kullanımı düzeltildi
    final notCompletedColor = Color.fromARGB(
      26, 
      baseColor.red, 
      baseColor.green, 
      baseColor.blue,
    );
    final todayBorderColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onDayTap != null ? () => onDayTap!(dateStr) : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted ? completedColor : notCompletedColor,
          borderRadius: BorderRadius.circular(4),
          border:
              isToday ? Border.all(color: todayBorderColor, width: 2) : null,
        ),
        child: Center(
          child: Text(
            dayNumber.toString(),
            style: TextStyle(
              color: isCompleted ? Colors.white : Colors.black54,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            // Double -> int dönüşümü ile Color.fromARGB kullanımı düzeltildi
            color: Color.fromARGB(
              26, 
              color.red, 
              color.green, 
              color.blue,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        const Text('Tamamlanmadı'),
        const SizedBox(width: 8),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        const Text('Tamamlandı'),
      ],
    );
  }
}