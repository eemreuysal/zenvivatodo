import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import 'database_helper.dart';
import 'notification_service.dart';

/// Görev yönetimi hizmetleri
class TaskService {
  factory TaskService() => _instance;
  TaskService._internal();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  
  // Singleton pattern
  static final TaskService _instance = TaskService._internal();

  /// Yeni görev ekleme
  /// 
  /// [task] nesnesini veritabanına ekler ve başarı durumunu döndürür.
  /// Eğer görevin bildirim zamanı varsa, bildirim planlanır.
  Future<bool> addTask(Task task) async {
    try {
      // Benzersiz ID ekleme
      final uniqueId = const Uuid().v4();
      final taskWithId = task.copyWith(uniqueId: uniqueId);
      
      final int taskId = await _databaseHelper.insertTask(taskWithId);
      
      if (taskId > 0) {
        // Göreve ID ekleyerek kopyala (bildirimleri planlamak için)
        final insertedTask = taskWithId.copyWith(id: taskId);
        
        // Eğer görevin zamanı varsa, bildirim planla
        if (insertedTask.time != null && insertedTask.time!.isNotEmpty) {
          await _notificationService.scheduleTaskReminder(insertedTask);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding task: $e');
      return false;
    }
  }

  /// Tarih bazında görevleri getirme
  Future<List<Task>> getTasksByDate(int userId, String date) async {
    try {
      return await _databaseHelper.getTasks(userId, date: date);
    } catch (e) {
      debugPrint('Error getting tasks by date: $e');
      return [];
    }
  }

  /// Tamamlanmamış görevleri getirme
  Future<List<Task>> getActiveTasks(int userId) async {
    try {
      return await _databaseHelper.getTasks(userId, isCompleted: false);
    } catch (e) {
      debugPrint('Error getting active tasks: $e');
      return [];
    }
  }

  /// Tamamlanmış görevleri getirme
  Future<List<Task>> getCompletedTasks(int userId) async {
    try {
      return await _databaseHelper.getTasks(userId, isCompleted: true);
    } catch (e) {
      debugPrint('Error getting completed tasks: $e');
      return [];
    }
  }

  /// Filtrelenmiş görevleri getirme
  Future<List<Task>> getFilteredTasks(
    int userId, {
    String? date,
    bool? isCompleted,
    int? categoryId,
    int? priority,
  }) async {
    try {
      return await _databaseHelper.getTasks(
        userId,
        date: date,
        isCompleted: isCompleted,
        categoryId: categoryId,
        priority: priority,
      );
    } catch (e) {
      debugPrint('Error getting filtered tasks: $e');
      return [];
    }
  }

  /// Görev metni içinde arama yapma (yeni)
  Future<List<Task>> searchTasks(
    int userId, 
    String query, 
    {bool includeCompleted = false,}
  ) async {
    try {
      if (query.trim().isEmpty) {
        return includeCompleted 
            ? await _databaseHelper.getTasks(userId)
            : await _databaseHelper.getTasks(userId, isCompleted: false);
      }
      
      return await _databaseHelper.searchTasks(
        userId, 
        query, 
        includeCompleted: includeCompleted,
      );
    } catch (e) {
      debugPrint('Error searching tasks: $e');
      return [];
    }
  }

  /// Görev güncelleme
  Future<bool> updateTask(Task task) async {
    try {
      // Mevcut görevi al (bildirim kontrolü için)
      final List<Task> existingTasks = await _databaseHelper.getTasks(
        task.userId,
        date: task.date,
      );
      
      final existingTask = existingTasks.firstWhereOrNull(
        (t) => t.id == task.id,
      );
      
      final int result = await _databaseHelper.updateTask(task);
      
      if (result > 0) {
        // Bildirim güncelleme işlemi
        final oldHasTime = existingTask?.time != null && existingTask!.time!.isNotEmpty;
        final newHasTime = task.time != null && task.time!.isNotEmpty;
        
        if (existingTask != null) {
          // Bildirim iptal edilmeli mi?
          if (oldHasTime && !newHasTime) {
            await _notificationService.cancelTaskReminder(task.id!);
          }
          // Bildirim zamanı değişti mi?
          else if (oldHasTime && newHasTime && existingTask.time != task.time) {
            await _notificationService.cancelTaskReminder(task.id!);
            await _notificationService.scheduleTaskReminder(task);
          }
          // Yeni bir bildirim eklenmiş mi?
          else if (!oldHasTime && newHasTime) {
            await _notificationService.scheduleTaskReminder(task);
          }
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating task: $e');
      return false;
    }
  }

  /// Görev tamamlama durumunu değiştirme
  Future<bool> toggleTaskCompletion(int taskId, bool isCompleted) async {
    try {
      final int result = await _databaseHelper.toggleTaskCompletion(
        taskId,
        isCompleted,
      );
      
      if (result > 0) {
        // Görev tamamlandıysa bildirimini iptal et
        if (isCompleted) {
          await _notificationService.cancelTaskReminder(taskId);
        } else {
          // Görev tamamlanmadı olarak işaretlendiyse ve bildirimi varsa tekrar planla
          final tasks = await _databaseHelper.getTasks(0); // userId bilgisi olmadan
          final task = tasks.firstWhereOrNull((t) => t.id == taskId);
          
          if (task != null && task.time != null && task.time!.isNotEmpty) {
            await _notificationService.scheduleTaskReminder(task);
          }
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
      return false;
    }
  }

  /// Görev silme
  Future<bool> deleteTask(int taskId) async {
    try {
      // Önce bildirimi iptal et
      await _notificationService.cancelTaskReminder(taskId);
      
      final int result = await _databaseHelper.deleteTask(taskId);
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      return false;
    }
  }
  
  /// Toplu görev güncelleme (örn. birden fazla görevi tamamlama)
  Future<bool> batchUpdateTasks(List<Task> tasks) async {
    try {
      final result = await _databaseHelper.batchUpdateTasks(tasks);
      
      if (result) {
        // Tamamlanan görevlerin bildirimlerini iptal et
        for (final task in tasks) {
          if (task.isCompleted && task.id != null) {
            await _notificationService.cancelTaskReminder(task.id!);
          }
        }
      }
      
      return result;
    } catch (e) {
      debugPrint('Error batch updating tasks: $e');
      return false;
    }
  }
  
  /// Kategori istatistikleri getirme (yeni)
  Future<List<Map<String, dynamic>>> getTaskStatsByCategory(int userId) async {
    try {
      return await _databaseHelper.getTaskCountByCategory(userId);
    } catch (e) {
      debugPrint('Error getting task stats by category: $e');
      return [];
    }
  }
  
  /// Günlük tamamlanan görev istatistikleri (yeni)
  Future<List<Map<String, dynamic>>> getCompletedTasksLast7Days(int userId) async {
    try {
      return await _databaseHelper.getCompletedTasksLast7Days(userId);
    } catch (e) {
      debugPrint('Error getting completed tasks stats: $e');
      return [];
    }
  }
  
  /// Öncelik istatistikleri getirme (yeni)
  Future<List<Map<String, dynamic>>> getTaskStatsByPriority(int userId) async {
    try {
      return await _databaseHelper.getTaskCountByPriority(userId);
    } catch (e) {
      debugPrint('Error getting task stats by priority: $e');
      return [];
    }
  }
}