import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../models/task.dart';
import 'notification_service.dart';

/// Bu servis şu anda kısmen devre dışı bırakılmıştır.
/// Bildirimleri kullanmak yerine yerel diyalog gösterimini kullanıyor.
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;

  // Stream that sends task IDs when they are due (5 minutes before the task time)
  final BehaviorSubject<Task> onTaskReminder = BehaviorSubject<Task>();
  Timer? _checkTimer;
  List<Task> _activeTasks = [];
  final NotificationService _notificationService = NotificationService();

  ReminderService._internal();

  // Initialize the reminder service
  void initialize() {
    debugPrint('ReminderService devre dışı bildirimlerin yerine diyaloglar kullanılıyor.');
    
    // Check for reminders every minute
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForReminders();
    });

    // Listen to the onTaskReminder stream and show notifications
    onTaskReminder.listen((task) {
      // Show dialog notification instead of system notification
      _notificationService.showNotificationDialog(task);
    });
  }

  // Set the list of active tasks
  void setTasks(List<Task> tasks) {
    _activeTasks = List.from(tasks);
    _checkForReminders(); // Check immediately after setting the tasks
  }

  // Check if there are any tasks due for a reminder
  void _checkForReminders() {
    final now = DateTime.now();

    for (var task in _activeTasks) {
      if (!task.isCompleted && task.time != null && task.time!.isNotEmpty) {
        // Parse date and time
        try {
          List<String> dateParts = task.date.split('-');
          List<String> timeParts = task.time!.split(':');

          if (dateParts.length == 3 && timeParts.length == 2) {
            final taskDateTime = DateTime(
              int.parse(dateParts[0]), // year
              int.parse(dateParts[1]), // month
              int.parse(dateParts[2]), // day
              int.parse(timeParts[0]), // hour
              int.parse(timeParts[1]), // minute
            );

            // Calculate the reminder time (5 minutes before task time)
            final reminderTime =
                taskDateTime.subtract(const Duration(minutes: 5));

            // Check if it's time for the reminder
            if (isTimeForReminder(now, reminderTime)) {
              // Add task to the reminder stream
              onTaskReminder.add(task);

              // Mark the task as notified by removing it from active tasks
              _activeTasks.remove(task);
              debugPrint('🔔 Reminder for task: ${task.title}');
            }
          }
        } catch (e) {
          debugPrint('Error parsing task date/time: $e');
        }
      }
    }
  }

  // Check if it's time for the reminder
  bool isTimeForReminder(DateTime now, DateTime reminderTime) {
    // Compare year, month, day, hour, and minute
    return now.year == reminderTime.year &&
        now.month == reminderTime.month &&
        now.day == reminderTime.day &&
        now.hour == reminderTime.hour &&
        now.minute == reminderTime.minute;
  }

  // Add a single task to the active tasks list
  void addTask(Task task) {
    if (!_activeTasks.contains(task)) {
      _activeTasks.add(task);
    }
  }

  // Remove a task from the active tasks list
  void removeTask(Task task) {
    _activeTasks.remove(task);
  }

  // Remove a task by ID
  void removeTaskById(int taskId) {
    _activeTasks.removeWhere((task) => task.id == taskId);
  }

  // Dispose resources
  void dispose() {
    _checkTimer?.cancel();
    onTaskReminder.close();
  }
}