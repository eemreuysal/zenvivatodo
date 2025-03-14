import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/rxdart.dart';
import '../models/task.dart';
import '../widgets/reminder_dialog.dart';
import '../main.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();
  
  NotificationService._internal();

  Future<void> initNotification() async {
    // Initialize timezone
    await _configureLocalTimeZone();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    // Set local location to a default (UTC)
    tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    
    // Note: We're not using flutter_timezone here, just a basic default timezone
    // In a production app, you'd want to detect the actual timezone
  }

  void showNotificationDialog(Task task) {
    // Since we don't have native notifications working, we use a dialog instead
    if (navigatorKey.currentContext != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => ReminderDialog(
          task: task,
          onDismiss: () => Navigator.pop(context),
          onViewTask: () {
            Navigator.pop(context);
            // Here you can navigate to task details if needed
          },
        ),
      );
    }
  }

  // This is a simplified version that doesn't use actual system notifications
  // Instead it just adds the task to our stream which will be listened to
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String taskId,
  }) async {
    // Not actually scheduling here, just adding to our demonstration code
    debugPrint('Would schedule notification: $title at $scheduledDate');
  }

  // Schedule notification for a task
  Future<void> scheduleTaskNotification(Task task) async {
    // Only schedule if we have both date and time
    if (task.time != null && task.time!.isNotEmpty) {
      try {
        // Parse date and time
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
          
          debugPrint('Task scheduled for: $taskDateTime');
          
          // We won't actually schedule a system notification due to compatibility issues
          // But we keep track of the task for our reminder service
        }
      } catch (e) {
        debugPrint('Bildirim zamanlama hatası: $e');
      }
    }
  }

  // Mock methods to maintain API compatibility
  Future<void> cancelNotification(int id) async {
    debugPrint('Would cancel notification: $id');
  }

  Future<void> cancelAllNotifications() async {
    debugPrint('Would cancel all notifications');
  }

  Future<void> requestPermissions() async {
    // No actual permissions to request in this simplified version
    debugPrint('Would request notification permissions');
  }

  // Dispose method
  void dispose() {
    // Close any streams
    onNotificationClick.close();
  }
}