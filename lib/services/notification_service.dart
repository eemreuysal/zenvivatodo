import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  NotificationService._internal();

  Future<void> initNotification() async {
    // Initialize timezone
    await _configureLocalTimeZone();
    
    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS bildirim ayarları
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
        
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: iosSettings,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    
    // Request permissions
    await requestPermissions();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Timezone set to: $timeZoneName');
    } catch (e) {
      debugPrint('Could not get the local timezone, defaulting to UTC: $e');
      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    }
  }
  
  Future<void> onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
    debugPrint('Notification received: $id, $title, $body, $payload');
    
    // Handle iOS notification when app is in foreground
    if (navigatorKey.currentContext != null && payload != null) {
      _handleNotificationPayload(payload);
    }
  }
  
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;
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
    
    // Convert DateTime to TZDateTime
    tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder_channel',
          'Görev Hatırlatmaları',
          channelDescription: 'Görev zamanı yaklaştığında hatırlatma gönderir',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
    
    debugPrint('Notification scheduled for: $scheduledDate with ID: $id');
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
          final reminderDateTime = taskDateTime.subtract(const Duration(minutes: 5));
          
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
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('Cancelled notification with ID: $id');
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      // iOS için izinleri iste
      final IOSFlutterLocalNotificationsPlugin? iosPlugin = 
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
              
      if (iosPlugin != null) {
        iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      
      // macOS için izinleri iste
      final MacOSFlutterLocalNotificationsPlugin? macOSPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>();
              
      if (macOSPlugin != null) {
        macOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Android 13 (SDK 33) ve üzeri için izin isteme
      if (androidPlugin != null) {
        androidPlugin.requestPermission();
      }
    }
  }

  // Dispose method
  void dispose() {
    // Close any streams
    onNotificationClick.close();
  }
}