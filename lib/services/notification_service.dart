import 'dart:io';
import 'package:flutter/material.dart';
// Bildirim paketi geçici olarak kaldırıldı
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/rxdart.dart';
import '../models/task.dart';
import '../widgets/reminder_dialog.dart';
import '../main.dart';
import '../constants/app_texts.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  // Bildirim paketi geçici olarak kaldırıldı
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  NotificationService._internal();

  Future<void> initNotification() async {
    // Initialize timezone
    await _configureLocalTimeZone();

    // Bildirim paketi geçici olarak kaldırıldı
    // Initialize notification settings işlemleri kaldırıldı
    
    debugPrint('Notifications temporarily disabled');
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      // Tarayarak mevcut sistemin zaman dilimini bulmaya çalış
      final String timeZoneName = tz.local.name;
      if (timeZoneName.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('Timezone set to: $timeZoneName');
      } else {
        // Eğer bulunamazsa, cihaz zaman dilimini kullan veya varsayılan UTC
        tz.setLocalLocation(tz.getLocation('Europe/Istanbul')); // Türkiye için varsayılan
        debugPrint('Could not determine local timezone, using default Europe/Istanbul');
      }
    } catch (e) {
      debugPrint('Could not set the local timezone: $e. Using UTC as default.');
      // Eğer hata oluşursa varsayılan olarak UTC kullan
      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    }
  }

  // Bildirim yerine dialog kullanılıyor
  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
      _handleNotificationPayload(payload);
    }
  }

  void _handleNotificationPayload(String payload) {
    onNotificationClick.add(payload);

    // Parse the payload to get task ID
    try {
      final int taskId = int.parse(payload);
      // You can implement logic to fetch the task by ID and show details
      debugPrint('Should open task with ID: $taskId');
    } catch (e) {
      debugPrint('Invalid payload format: $e');
    }
  }

  void showNotificationDialog(Task task) {
    // Dialog still available for foreground notifications
    if (navigatorKey.currentContext != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => ReminderDialog(
          task: task,
          onDismiss: () => Navigator.pop(context),
          onViewTask: () {
            Navigator.pop(context);
            // Burada görev detaylarına yönlendirme yapılabilir
          },
        ),
      );
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    // Skip if scheduled date is in the past
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('Scheduled time is in the past, skipping notification');
      return;
    }

    // Bildirim paketi geçici olarak kaldırıldı
    debugPrint('Would schedule notification: "$title" for $scheduledDate');
  }

  // Schedule notification for a task
  Future<void> scheduleTaskNotification(Task task) async {
    // Only schedule if we have both date and time and the task has an ID
    if (task.id != null && task.time != null && task.time!.isNotEmpty) {
      try {
        // Parse date and time
        List<String> dateParts = task.date.split('-');
        List<String> timeParts = task.time!.split(':');

        if (dateParts.length == 3 && timeParts.length == 2) {
          // Task time
          final taskDateTime = DateTime(
            int.parse(dateParts[0]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[2]), // day
            int.parse(timeParts[0]), // hour
            int.parse(timeParts[1]), // minute
          );

          // Schedule 5 minutes before task time
          final reminderDateTime =
              taskDateTime.subtract(const Duration(minutes: 5));

          debugPrint('Would schedule task reminder: "${task.title}" for $reminderDateTime');
          await scheduleNotification(
            id: task.id!,
            title: AppTexts.taskReminder,
            body: '${task.title} - ${task.time}',
            scheduledDate: reminderDateTime,
            payload: task.id.toString(),
          );
        }
      } catch (e) {
        debugPrint('Bildirim zamanlama hatası: $e');
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    // Bildirim paketi geçici olarak kaldırıldı
    debugPrint('Would cancel notification with ID: $id');
  }

  Future<void> cancelAllNotifications() async {
    // Bildirim paketi geçici olarak kaldırıldı
    debugPrint('Would cancel all notifications');
  }

  Future<void> requestPermissions() async {
    // Bildirim paketi geçici olarak kaldırıldı
    debugPrint('Would request notification permissions');
  }

  // Dispose method
  void dispose() {
    // Close any streams
    onNotificationClick.close();
  }
}