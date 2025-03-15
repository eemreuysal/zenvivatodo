import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import 'database_helper.dart';

class HabitService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Alışkanlık oluşturma
  Future<bool> createHabit(Habit habit) async {
    try {
      final id = await _dbHelper.insertHabit(habit.toMap());
      return id > 0;
    } catch (e) {
      debugPrint('Alışkanlık oluşturma hatası: $e');
      return false;
    }
  }

  // Tüm alışkanlıkları getirme
  Future<List<Habit>> getHabits(int userId, {bool includeArchived = false}) async {
    try {
      final maps = await _dbHelper.getHabits(userId, includeArchived: includeArchived);
      return maps.map((map) => Habit.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Alışkanlıkları getirme hatası: $e');
      return [];
    }
  }

  // Belirli bir alışkanlığı ID'ye göre getirme
  Future<Habit?> getHabitById(int id) async {
    try {
      final map = await _dbHelper.getHabitById(id);
      if (map != null) {
        return Habit.fromMap(map);
      }
      return null;
    } catch (e) {
      debugPrint('Alışkanlık getirme hatası: $e');
      return null;
    }
  }

  // Bugün için geçerli alışkanlıkları getirme
  Future<List<Habit>> getTodayHabits(int userId) async {
    try {
      final allHabits = await getHabits(userId);
      final now = DateTime.now();
      final weekday = now.weekday; // 1 (Pazartesi) - 7 (Pazar)

      // Bugün gerçekleştirilmesi gereken alışkanlıkları filtrele
      return allHabits.where((habit) {
        if (habit.isArchived) return false;

        // Alışkanlığın başlangıç tarihini kontrol et
        final startDate = DateTime.parse(habit.startDate);
        if (now.isBefore(startDate)) return false;

        switch (habit.frequency) {
          case 'daily':
            return true;
          case 'weekly':
            // Haftalık ve belirli günler seçildiyse
            if (habit.frequencyDays != null && habit.frequencyDays!.isNotEmpty) {
              final selectedDays = habit.frequencyDays!.split(',')
                  .map((day) => int.parse(day))
                  .toList();
              return selectedDays.contains(weekday);
            }
            // Haftalık ama belirli gün seçilmediyse (her haftanın bugünü)
            final habitStartWeekday = DateTime.parse(habit.startDate).weekday;
            return weekday == habitStartWeekday;
          case 'monthly':
            // Aylık (ayın aynı günü)
            final habitStartDay = DateTime.parse(habit.startDate).day;
            return now.day == habitStartDay;
          default:
            return false;
        }
      }).toList();
    } catch (e) {
      debugPrint('Bugünkü alışkanlıkları getirme hatası: $e');
      return [];
    }
  }

  // Alışkanlık güncelleme
  Future<bool> updateHabit(Habit habit) async {
    try {
      final rowsAffected = await _dbHelper.updateHabit(habit.toMap());
      return rowsAffected > 0;
    } catch (e) {
      debugPrint('Alışkanlık güncelleme hatası: $e');
      return false;
    }
  }

  // Alışkanlık silme
  Future<bool> deleteHabit(int id) async {
    try {
      final rowsAffected = await _dbHelper.deleteHabit(id);
      return rowsAffected > 0;
    } catch (e) {
      debugPrint('Alışkanlık silme hatası: $e');
      return false;
    }
  }

  // Alışkanlığı arşivleme/aktifleştirme
  Future<bool> toggleArchiveHabit(int id, bool isArchived) async {
    try {
      final rowsAffected = await _dbHelper.archiveHabit(id, isArchived);
      return rowsAffected > 0;
    } catch (e) {
      debugPrint('Alışkanlık arşivleme hatası: $e');
      return false;
    }
  }

  // Bir alışkanlığı belirli bir tarih için tamamla/tamamlamayı geri al
  Future<bool> toggleHabitCompletion(int habitId, String date, bool completed) async {
    try {
      final result = await _dbHelper.toggleHabitCompletion(habitId, date, completed);
      if (result > 0) {
        // Tamamlanma durumunu güncelledikten sonra zinciri güncelle
        await updateHabitStreak(habitId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Alışkanlık tamamlama hatası: $e');
      return false;
    }
  }

  // Alışkanlık kayıtlarını getir
  Future<List<HabitLog>> getHabitLogs(int habitId, {String? date}) async {
    try {
      final maps = await _dbHelper.getHabitLogs(habitId, date: date);
      return maps.map((map) => HabitLog.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Alışkanlık kayıtlarını getirme hatası: $e');
      return [];
    }
  }

  // Son 30 günlük alışkanlık kayıtlarını getir
  Future<List<HabitLog>> getRecentHabitLogs(int habitId, {int days = 30}) async {
    try {
      final now = DateTime.now();
      final allLogs = await getHabitLogs(habitId);
      
      return allLogs.where((log) {
        final logDate = DateTime.parse(log.date);
        final difference = now.difference(logDate).inDays;
        return difference <= days;
      }).toList();
    } catch (e) {
      debugPrint('Son alışkanlık kayıtlarını getirme hatası: $e');
      return [];
    }
  }

  // Mevcut zinciri hesapla ve veritabanını güncelle
  Future<void> updateHabitStreak(int habitId) async {
    try {
      // Alışkanlığı getir
      final habit = await getHabitById(habitId);
      if (habit == null) return;

      // Tüm kayıtları getir ve tarih sırasına göre sırala
      final logs = await getHabitLogs(habitId);
      logs.sort((a, b) => b.date.compareTo(a.date)); // En son tarih en başta

      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      
      // Bugün için alışkanlık gerekliyse kontrol et
      final isTodayRequired = _isDateRequired(now, habit);
      final isTodayCompleted = logs.any((log) => log.date == today && log.completed);
      
      // Bugün gerekliyse ama tamamlanmamışsa, zincir sıfırlanır
      if (isTodayRequired && !isTodayCompleted) {
        if (habit.currentStreak > 0) {
          habit.currentStreak = 0;
          await _dbHelper.updateHabit(habit.toMap());
        }
        return;
      }
      
      // Geriye doğru tüm günleri kontrol et ve kesintisiz tamamlanmış günleri say
      int streak = 0;
      DateTime currentDate = now;
      
      while (true) {
        if (_isDateRequired(currentDate, habit)) {
          final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
          final isCompleted = logs.any((log) => log.date == dateStr && log.completed);
          
          if (isCompleted) {
            streak++;
          } else {
            break; // Zincir kırıldı
          }
        }
        
        // Bir gün geriye git
        currentDate = currentDate.subtract(const Duration(days: 1)); // const eklendi
        
        // Başlangıç tarihinden önceyse çık
        if (currentDate.isBefore(DateTime.parse(habit.startDate))) break;
      }
      
      // Eğer mevcut streak değiştiği veya en uzun streakten büyükse güncelle
      if (streak != habit.currentStreak || streak > habit.longestStreak) {
        habit.currentStreak = streak;
        if (streak > habit.longestStreak) {
          habit.longestStreak = streak;
        }
        await _dbHelper.updateHabit(habit.toMap());
      }
    } catch (e) {
      debugPrint('Zincir güncelleme hatası: $e');
    }
  }

  // Belirli bir tarihte alışkanlığın gerekli olup olmadığını kontrol et
  bool _isDateRequired(DateTime date, Habit habit) {
    final weekday = date.weekday; // 1 (Pazartesi) - 7 (Pazar)
    final habitStartDate = DateTime.parse(habit.startDate);
    
    // Başlangıç tarihinden önce ise gerekli değil
    if (date.isBefore(habitStartDate)) return false;
    
    switch (habit.frequency) {
      case 'daily':
        return true;
      case 'weekly':
        if (habit.frequencyDays != null && habit.frequencyDays!.isNotEmpty) {
          // Belirli günler seçildiyse
          final selectedDays = habit.frequencyDays!.split(',')
              .map((day) => int.parse(day))
              .toList();
          return selectedDays.contains(weekday);
        } else {
          // Belirli gün seçilmediyse (haftanın aynı günü)
          return weekday == habitStartDate.weekday;
        }
      case 'monthly':
        // Ayın aynı günü
        return date.day == habitStartDate.day;
      default:
        return false;
    }
  }

  // Alışkanlığın tamamlanma oranını hesapla (son 30 gün)
  Future<double> calculateCompletionRate(int habitId, {int days = 30}) async {
    try {
      final habit = await getHabitById(habitId);
      if (habit == null) return 0.0;
      
      final now = DateTime.now();
      final startDate = DateTime.parse(habit.startDate);
      
      // Başlangıç tarihi son X günden sonra ise, başlangıç tarihinden itibaren hesapla
      DateTime periodStart;
      if (startDate.isAfter(now.subtract(Duration(days: days)))) {
        periodStart = startDate;
      } else {
        periodStart = now.subtract(Duration(days: days));
      }
      
      int totalRequiredDays = 0;
      int completedDays = 0;
      
      // Tüm günleri kontrol et
      for (var i = 0; i <= now.difference(periodStart).inDays; i++) {
        final currentDate = periodStart.add(Duration(days: i));
        
        if (_isDateRequired(currentDate, habit)) {
          totalRequiredDays++;
          
          final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
          final logs = await getHabitLogs(habitId, date: dateStr);
          
          if (logs.any((log) => log.completed)) {
            completedDays++;
          }
        }
      }
      
      if (totalRequiredDays == 0) return 0.0;
      return completedDays / totalRequiredDays;
    } catch (e) {
      debugPrint('Tamamlanma oranı hesaplama hatası: $e');
      return 0.0;
    }
  }
}
