import '../models/task.dart';
import 'database_helper.dart';
import 'package:flutter/foundation.dart';

class TaskService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<bool> addTask(Task task) async {
    try {
      int taskId = await _databaseHelper.insertTask(task);
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
      return result > 0;
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    try {
      int result = await _databaseHelper.deleteTask(taskId);
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      return false;
    }
  }
}
