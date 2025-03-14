import '../models/task.dart';
import 'database_helper.dart';
import 'notification_service.dart';
import 'package:flutter/foundation.dart';

class TaskService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  Future<bool> addTask(Task task) async {
    try {
      int taskId = await _databaseHelper.insertTask(task);
      
      // Create notification for the task if it has time set
      if (taskId > 0 && task.time != null && task.time!.isNotEmpty) {
        task.id = taskId; // Update task with the generated ID
        await _notificationService.scheduleTaskNotification(task);
      }
      
      return taskId > 0;
    } catch (e) {
      debugPrint('Error adding task: $e');
      return false;
    }
  }

  Future<List<Task>> getTasksByDate(int userId, String date) async {
    try {
      return await _databaseHelper.getTasks(userId, date: date);
    } catch (e) {
      debugPrint('Error getting tasks by date: $e');
      return [];
    }
  }

  Future<List<Task>> getActiveTasks(int userId) async {
    try {
      return await _databaseHelper.getTasks(userId, isCompleted: false);
    } catch (e) {
      debugPrint('Error getting active tasks: $e');
      return [];
    }
  }

  Future<List<Task>> getCompletedTasks(int userId) async {
    try {
      return await _databaseHelper.getTasks(userId, isCompleted: true);
    } catch (e) {
      debugPrint('Error getting completed tasks: $e');
      return [];
    }
  }

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

  Future<bool> updateTask(Task task) async {
    try {
      int result = await _databaseHelper.updateTask(task);
      
      if (result > 0) {
        // Cancel existing notification
        if (task.id != null) {
          await _notificationService.cancelNotification(task.id!);
        }
        
        // Schedule new notification if the task has time
        if (task.time != null && task.time!.isNotEmpty && !task.isCompleted) {
          await _notificationService.scheduleTaskNotification(task);
        }
      }
      
      return result > 0;
    } catch (e) {
      debugPrint('Error updating task: $e');
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(int taskId, bool isCompleted) async {
    try {
      int result = await _databaseHelper.toggleTaskCompletion(
        taskId,
        isCompleted,
      );
      
      // If the task is marked as completed, cancel its notification
      if (result > 0 && isCompleted) {
        await _notificationService.cancelNotification(taskId);
      }
      // If task is uncompleted and has time, reschedule notification
      else if (result > 0 && !isCompleted) {
        // Get the task to check if it has time
        List<Map<String, dynamic>> maps = await _databaseHelper.database.then(
          (db) => db.query(
            'tasks',
            where: 'id = ?',
            whereArgs: [taskId],
          ),
        );
        
        if (maps.isNotEmpty) {
          Task task = Task.fromMap(maps.first);
          if (task.time != null && task.time!.isNotEmpty) {
            await _notificationService.scheduleTaskNotification(task);
          }
        }
      }
      
      return result > 0;
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    try {
      // Cancel the notification first
      await _notificationService.cancelNotification(taskId);
      
      // Then delete the task
      int result = await _databaseHelper.deleteTask(taskId);
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      return false;
    }
  }
}
