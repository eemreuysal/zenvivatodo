import '../models/task.dart';
import 'database_helper.dart';
import 'reminder_service.dart';
import 'package:flutter/foundation.dart';

class TaskService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ReminderService _reminderService = ReminderService();

  Future<bool> addTask(Task task) async {
    try {
      int taskId = await _databaseHelper.insertTask(task);
      
      // Add to reminder service if it has time set
      if (taskId > 0 && task.time != null && task.time!.isNotEmpty) {
        task.id = taskId; // Update task with the generated ID
        _reminderService.addTask(task);
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
      final tasks = await _databaseHelper.getTasks(userId, isCompleted: false);
      
      // Update reminder service with active tasks
      _reminderService.setTasks(tasks);
      
      return tasks;
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
      final tasks = await _databaseHelper.getTasks(
        userId,
        date: date,
        isCompleted: isCompleted,
        categoryId: categoryId,
        priority: priority,
      );
      
      // If we're filtering for active tasks, update the reminder service
      if (isCompleted == false) {
        _reminderService.setTasks(tasks);
      }
      
      return tasks;
    } catch (e) {
      debugPrint('Error getting filtered tasks: $e');
      return [];
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      int result = await _databaseHelper.updateTask(task);
      
      if (result > 0) {
        // Remove old task from reminder service
        if (task.id != null) {
          _reminderService.removeTaskById(task.id!);
        }
        
        // Add updated task to reminder service if it has time
        if (task.time != null && task.time!.isNotEmpty && !task.isCompleted) {
          _reminderService.addTask(task);
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
      
      // If the task is marked as completed, remove it from reminders
      if (result > 0 && isCompleted) {
        _reminderService.removeTaskById(taskId);
      }
      // If task is uncompleted and has time, add back to reminder service
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
            _reminderService.addTask(task);
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
      // Remove from reminder service first
      _reminderService.removeTaskById(taskId);
      
      // Then delete the task
      int result = await _databaseHelper.deleteTask(taskId);
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      return false;
    }
  }
}
