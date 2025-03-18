import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import 'database_helper.dart';
// import 'notification_service.dart'; // Kullanılmayan import kaldırıldı

/// Alışkanlık yönetimi hizmetleri
class HabitService {
  factory HabitService() => _instance;
  HabitService._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // Kullanılmayan _notificationService alanını kaldıralım
  
  // Singleton pattern
  static final HabitService _instance = HabitService._internal();

  /// Alışkanlık oluşturma
  /// 
  /// [habit] nesnesini veritabanına ekler ve başarı durumunu döndürür.
  /// Eğer alışkanlığın hatırlatma zamanı varsa, bildirimleri planlanır.
  Future<bool> createHabit(Habit habit) async {
    try {
      final id = await _dbHelper.insertHabit(habit.toMap());
      
      if (id > 0) {
        // Hatırlatıcı varsa planla
        if (habit.reminderTime != null && habit.reminderTime!.isNotEmpty) {
          // Alışkanlıklarla ilgili bildirimleri planla
          // NOT: Bu kısım bildirim servisi güncellemesi gerektirir
        }
        return true;
      }
      return false;
    } on Exception catch (e) {
      debugPrint('Alışkanlık oluşturma hatası: $e');
      return false;
    }
  }

  /// Tüm alışkanlıkları getirme
  Future<List<Habit>> getHabits(int userId,
      {bool includeArchived = false,}) async {
    try {
      final maps =
          await _dbHelper.getHabits(userId, includeArchived: includeArchived);
      
      // Yeni model sınıfı ile uyumlu hale getirme
      return maps.map((map) => Habit.fromMap(map)).toList();
    } on Exception catch (e) {
      debugPrint('Alışkanlıkları getirme hatası: $e');
      return [];
    }
  }

  /// Dashboard için gösterilecek alışkanlıkları getirme
  /// [userId] - kullanıcı kimliği
  /// [date] - gösterilecek tarih
  Future<List<Habit>> getDashboardHabits({required int userId, required String date}) async {
    try {
      final maps = await _dbHelper.getDashboardHabits(userId, date: date);
      return maps.map((map) => Habit.fromMap(map)).toList();
    } on Exception catch (e) {
      debugPrint('Dashboard alışkanlıklarını getirme hatası: $e');
      return [];
    }
  }

  /// Belirli bir alışkanlığı ID'ye göre getirme
  Future<Habit?> getHabitById(int id) async {
    try {
      final map = await _dbHelper.getHabitById(id);
      if (map != null) {
        return Habit.fromMap(map);
      }
      return null;
    } on Exception catch (e) {
      debugPrint('Alışkanlık getirme hatası: $e');
      return null;
    }
  }

  /// Bugün için geçerli alışkanlıkları getirme
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

        // Alışkanlık sıklığını kontrol et
        switch (habit.frequency) {
          case HabitFrequency.daily:
            return true;
            
          case HabitFrequency.weekly:
            // Haftalık ve belirli günler seçildiyse
            if (habit.frequencyDays != null && habit.frequencyDays!.isNotEmpty) {
              final selectedDays = habit.frequencyDays!
                  .split(',')
                  .map((day) => int.parse(day))
                  .toList();
              return selectedDays.contains(weekday);
            }
            // Haftalık ama belirli gün seçilmediyse (her haftanın bugünü)
            final habitStartWeekday = DateTime.parse(habit.startDate).weekday;
            return weekday == habitStartWeekday;
            
          case HabitFrequency.monthly:
            // Aylık (ayın aynı günü)
            final habitStartDay = DateTime.parse(habit.startDate).day;
            return now.day == habitStartDay;
            
          case HabitFrequency.custom:
            // Özel sıklık (serbest tanımlı)
            if (habit.frequencyDays != null && habit.frequencyDays!.isNotEmpty) {
              final selectedDays = habit.frequencyDays!
                  .split(',')
                  .map((day) => int.parse(day))
                  .toList();
              return selectedDays.contains(weekday);
            }
            return false;
        }
      }).toList();
    } on Exception catch (e) {
      debugPrint('Bugünkü alışkanlıkları getirme hatası: $e');
      return [];
    }
  }

  /// Alışkanlık güncelleme
  Future<bool> updateHabit(Habit habit) async {
    try {
      // Mevcut alışkanlık üzerinde işlem yapmıyoruz, değişkeni kaldıralım
      final rowsAffected = await _dbHelper.updateHabit(habit.toMap());
      
      // Bildirimlerle ilgili güncelleme işlemleri (ileri aşama)
      
      return rowsAffected > 0;
    } on Exception catch (e) {
      debugPrint('Alışkanlık güncelleme hatası: $e');
      return false;
    }
  }

  /// Alışkanlık silme
  Future<bool> deleteHabit(int id) async {
    try {
      // Bildirimleri temizle (ileri aşama)
      
      final rowsAffected = await _dbHelper.deleteHabit(id);
      return rowsAffected > 0;
    } on Exception catch (e) {
      debugPrint('Alışkanlık silme hatası: $e');
      return false;
    }
  }

  /// Alışkanlığı arşivleme/aktifleştirme
  Future<bool> toggleArchiveHabit(int id, bool isArchived) async {
    try {
      final habit = await getHabitById(id);
      if (habit == null) return false;
      
      // Yeni modeli kullanarak immutable olarak güncelleme
      final updatedHabit = habit.toggleArchived();
      
      final rowsAffected = await _dbHelper.updateHabit(updatedHabit.toMap());
      return rowsAffected > 0;
    } on Exception catch (e) {
      debugPrint('Alışkanlık arşivleme hatası: $e');
      return false;
    }
  }

  /// Alışkanlığın dashboard'da gösterilmesini ayarlama
  Future<bool> toggleShowInDashboard(int id, bool showInDashboard) async {
    try {
      final habit = await getHabitById(id);
      if (habit == null) return false;
      
      // Yeni modeli kullanarak immutable olarak güncelleme
      final updatedHabit = habit.toggleDashboardVisibility();
      
      final rowsAffected = await _dbHelper.updateHabit(updatedHabit.toMap());
      return rowsAffected > 0;
    } on Exception catch (e) {
      debugPrint('Dashboard gösterme ayarı hatası: $e');
      return false;
    }
  }

  /// Bir alışkanlığı belirli bir tarih için tamamla/tamamlamayı geri al
  Future<bool> toggleHabitCompletion(
      int habitId, String date, bool completed,) async {
    try {
      final result =
          await _dbHelper.toggleHabitCompletion(habitId, date, completed);
      if (result > 0) {
        // Tamamlanma durumunu güncelledikten sonra zinciri güncelle
        await updateHabitStreak(habitId);
        return true;
      }
      return false;
    } on Exception catch (e) {
      debugPrint('Alışkanlık tamamlama hatası: $e');
      return false;
    }
  }

  /// Alışkanlık kayıtlarını getir
  Future<List<HabitLog>> getHabitLogs(int habitId, {String? date}) async {
    try {
      final maps = await _dbHelper.getHabitLogs(habitId, date: date);
      return maps.map((map) => HabitLog.fromMap(map)).toList();
    } on Exception catch (e) {
      debugPrint('Alışkanlık kayıtlarını getirme hatası: $e');
      return [];
    }
  }

  /// Son belirli gün sayısına ait alışkanlık kayıtlarını getir
  Future<List<HabitLog>> getRecentHabitLogs(int habitId,
      {int days = 30,}) async {
    try {
      final now = DateTime.now();
      final allLogs = await getHabitLogs(habitId);
      
      return allLogs.where((log) {
        try {
          final logDate = DateTime.parse(log.date);
          final difference = now.difference(logDate).inDays;
          return difference <= days;
        } catch (_) {
          return false;
        }
      }).toList();
    } on Exception catch (e) {
      debugPrint('Son alışkanlık kayıtlarını getirme hatası: $e');
      return [];
    }
  }

  /// Mevcut zinciri hesapla ve veritabanını güncelle - iyileştirilmiş versiyon
  Future<void> updateHabitStreak(int habitId) async {
    try {
      // Alışkanlığı ve son 60 günlük kayıtları getir
      final habitObj = await getHabitById(habitId);
      if (habitObj == null) return;

      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      
      // Başlangıç tarihini DateTime olarak elde et
      DateTime startDate;
      try {
        startDate = DateTime.parse(habitObj.startDate);
      } on FormatException catch (e) {
        debugPrint('Geçersiz başlangıç tarihi: ${habitObj.startDate}');
        return;
      }
      
      // Son 60 günlük kayıtları tarihe göre azalan sırayla getir
      final logs = await getRecentHabitLogs(habitId, days: 60);
      logs.sort((a, b) => b.date.compareTo(a.date)); // En son tarih en başta
      
      // Kayıtları hızlı arama için Map'e dönüştür
      final completedDates = <String, bool>{};
      for (final log in logs) {
        if (log.completed) {
          completedDates[log.date] = true;
        }
      }

      // Bugün için alışkanlık gerekliyse kontrol et
      final isTodayRequired = _isDateRequired(now, habitObj);
      final isTodayCompleted = completedDates.containsKey(today);

      // Bugün gerekliyse ama tamamlanmamışsa, zincir sıfırlanır
      if (isTodayRequired && !isTodayCompleted) {
        if (habitObj.currentStreak > 0) {
          // Yeni model sınıfı ile immutable güncelleme
          final updatedHabit = habitObj.resetStreak();
          await _dbHelper.updateHabit(updatedHabit.toMap());
        }
        return;
      }

      // Geriye doğru tüm günleri kontrol et ve kesintisiz tamamlanmış günleri say
      int streak = 0;
      DateTime currentDate = now;
      
      // Maksimum 180 gün geriye git veya başlangıç tarihine kadar
      for (int i = 0; i < 180; i++) {
        // Başlangıç tarihinden önceyse çık
        if (currentDate.isBefore(startDate)) break;
        
        if (_isDateRequired(currentDate, habitObj)) {
          final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
          final isCompleted = completedDates.containsKey(dateStr);

          if (isCompleted) {
            streak++;
          } else {
            break; // Zincir kırıldı
          }
        }

        // Bir gün geriye git
        currentDate = currentDate.subtract(const Duration(days: 1));
      }

      // Eğer mevcut streak değiştiği veya en uzun streakten büyükse güncelle
      if (streak != habitObj.currentStreak || streak > habitObj.longestStreak) {
        final updatedStreak = streak;
        final updatedLongestStreak = streak > habitObj.longestStreak 
            ? streak 
            : habitObj.longestStreak;
        
        // Yeni model sınıfı ile immutable güncelleme
        final updatedHabit = habitObj.copyWith(
          currentStreak: updatedStreak,
          longestStreak: updatedLongestStreak,
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        await _dbHelper.updateHabit(updatedHabit.toMap());
      }
    } on Exception catch (e) {
      debugPrint('Zincir güncelleme hatası: $e');
    }
  }

  /// Belirli bir tarihte alışkanlığın gerekli olup olmadığını kontrol et
  bool _isDateRequired(DateTime date, Habit habit) {
    final weekday = date.weekday; // 1 (Pazartesi) - 7 (Pazar)
    
    DateTime habitStartDate;
    try {
      habitStartDate = DateTime.parse(habit.startDate);
    } on FormatException catch (e) {
      debugPrint('Geçersiz başlangıç tarihi: ${habit.startDate}');
      return false;
    }

    // Başlangıç tarihinden önce ise gerekli değil
    if (date.isBefore(habitStartDate)) return false;

    // Enum switch pattern matching (Dart 3.7)
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return true;
        
      case HabitFrequency.weekly:
        if (habit.frequencyDays != null && habit.frequencyDays!.isNotEmpty) {
          // Belirli günler seçildiyse
          final selectedDays = habit.frequencyDays!
              .split(',')
              .map((day) => int.parse(day))
              .toList();
          return selectedDays.contains(weekday);
        } else {
          // Belirli gün seçilmediyse (haftanın aynı günü)
          return weekday == habitStartDate.weekday;
        }
        
      case HabitFrequency.monthly:
        // Ayın aynı günü
        return date.day == habitStartDate.day;
        
      case HabitFrequency.custom:
        // Özel sıklıkta belirli günler seçildiyse
        if (habit.frequencyDays != null && habit.frequencyDays!.isNotEmpty) {
          final selectedDays = habit.frequencyDays!
              .split(',')
              .map((day) => int.parse(day))
              .toList();
          return selectedDays.contains(weekday);
        }
        return false;
    }
  }

  /// Alışkanlığın tamamlanma oranını hesapla - optimizasyonlu
  Future<double> calculateCompletionRate(int habitId, {int days = 30}) async {
    try {
      final habit = await getHabitById(habitId);
      if (habit == null) return 0.0;

      final now = DateTime.now();
      
      DateTime startDate;
      try {
        startDate = DateTime.parse(habit.startDate);
      } on FormatException catch (e) {
        debugPrint('Geçersiz başlangıç tarihi: ${habit.startDate}');
        return 0.0;
      }

      // Başlangıç tarihi son X günden sonra ise, başlangıç tarihinden itibaren hesapla
      DateTime periodStart;
      if (startDate.isAfter(now.subtract(Duration(days: days)))) {
        periodStart = startDate;
      } else {
        periodStart = now.subtract(Duration(days: days));
      }

      // Tüm kayıtları tek seferde getir ve hızlı arama için Map'e dönüştür
      final logs = await getHabitLogs(habitId);
      final completedDates = <String, bool>{};
      for (final log in logs) {
        if (log.completed) {
          completedDates[log.date] = true;
        }
      }

      int totalRequiredDays = 0;
      int completedDays = 0;

      // Tüm günleri kontrol et
      final totalDays = now.difference(periodStart).inDays;
      for (var i = 0; i <= totalDays; i++) {
        final currentDate = periodStart.add(Duration(days: i));

        if (_isDateRequired(currentDate, habit)) {
          totalRequiredDays++;

          final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
          if (completedDates.containsKey(dateStr)) {
            completedDays++;
          }
        }
      }

      if (totalRequiredDays == 0) return 0.0;
      return completedDays / totalRequiredDays;
    } on Exception catch (e) {
      debugPrint('Tamamlanma oranı hesaplama hatası: $e');
      return 0.0;
    }
  }

  /// Belirli bir tarihteki alışkanlığın tamamlanma durumunu kontrol et
  Future<bool> isHabitCompletedOnDate(int habitId, String date) async {
    try {
      // Tarih formatını kontrol et
      if (date.isEmpty) {
        debugPrint('Geçersiz tarih formatı: Boş string');
        return false;
      }
      
      try {
        // Tarihin geçerli formatta olduğunu doğrula
        DateFormat('yyyy-MM-dd').parse(date);
      } on FormatException catch (e) {
        debugPrint('Geçersiz tarih formatı: $date');
        return false;
      }
      
      // Log kayıtlarını doğrudan HabitLog modeli olarak al
      final logs = await getHabitLogs(habitId, date: date);
      return logs.isNotEmpty && logs.first.completed;
    } on Exception catch (e) {
      debugPrint('Alışkanlık tamamlanma kontrolü hatası: $e');
      return false;
    }
  }
  
  /// Alışkanlık için not ekle veya güncelle
  Future<bool> addHabitNote(int habitId, String date, String note) async {
    try {
      final logs = await getHabitLogs(habitId, date: date);
      
      if (logs.isEmpty) {
        // Yeni log oluştur
        final newLog = HabitLog(
          habitId: habitId,
          date: date,
          notes: note,
        );
        
        final result = await _dbHelper.insertHabitLog(newLog.toMap());
        return result > 0;
      } else {
        // Mevcut logu güncelle
        final existingLog = logs.first;
        final updatedLog = existingLog.withNotes(note);
        
        final result = await _dbHelper.updateHabitLog(updatedLog.toMap());
        return result > 0;
      }
    } on Exception catch (e) {
      debugPrint('Alışkanlık not ekleme hatası: $e');
      return false;
    }
  }
  
  /// Özel tarih formatı
  String formatDateForDisplay(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('d MMMM yyyy', 'tr_TR').format(dateTime);
    } on FormatException catch (e) {
      return date;
    }
  }
  
  /// Dönem bazında tamamlama istatistikleri (yeni)
  Future<Map<String, double>> getCompletionStatsByPeriod(int habitId) async {
    final results = <String, double>{};
    
    try {
      // Son 7 gün
      results['last7days'] = await calculateCompletionRate(habitId, days: 7);
      
      // Son 30 gün
      results['last30days'] = await calculateCompletionRate(habitId);
      
      // Son 90 gün
      results['last90days'] = await calculateCompletionRate(habitId, days: 90);
      
      // Tüm zamanlar
      final habit = await getHabitById(habitId);
      if (habit != null) {
        try {
          final startDate = DateTime.parse(habit.startDate);
          final now = DateTime.now();
          final totalDays = now.difference(startDate).inDays;
          
          results['allTime'] = await calculateCompletionRate(habitId, days: totalDays);
        } on FormatException catch (e) {
          results['allTime'] = 0.0;
        }
      } else {
        results['allTime'] = 0.0;
      }
    } on Exception catch (e) {
      debugPrint('İstatistik hesaplama hatası: $e');
    }
    
    return results;
  }
}