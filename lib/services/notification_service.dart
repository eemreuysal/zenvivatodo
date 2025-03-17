import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  NotificationService._internal();

  Future<void> initNotification() async {
    // Initialize timezone
    await _configureLocalTimeZone();

    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS bildirim ayarları
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
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
      // Tarayarak mevcut sistemin zaman dilimini bulmaya çalış
      final String? timeZoneName = tz.local.name;
      if (timeZoneName != null && timeZoneName.isNotEmpty) {
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

    // Bildirim detaylarını belirleme
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_reminder_channel',
      'Görev Hatırlatmaları',
      channelDescription: 'Görev zamanı yaklaştığında hatırlatma gönderir',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('Notification scheduled for: $scheduledDate with ID: $id');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
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
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        // iOS ve macOS için izinleri iste
        final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
        
        if (Platform.isIOS) {
          await plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        } else {
          await plugin.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      } else if (Platform.isAndroid) {
        // Android için bildirim ayarları
        debugPrint('Android bildirimleri hazırlanıyor');
        // Android 13 (API 33+) için bildirim izinleri otomatik olarak işlenir
      }

      debugPrint('Notification permissions requested successfully');
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  // Dispose method
  void dispose() {
    // Close any streams
    onNotificationClick.close();
  }
}