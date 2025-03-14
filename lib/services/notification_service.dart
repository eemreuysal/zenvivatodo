import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:rxdart/rxdart.dart';
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();
  
  NotificationService._internal();

  Future<void> initNotification() async {
    // Time zone setup
    await _configureLocalTimeZone();
    
    // Initialize flutter_local_notifications
    const AndroidInitializationSettings initializationSettingsAndroid = 
      AndroidInitializationSettings('app_icon'); // drawable/app_icon.png'deki ikonu kullanır
      
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permission
    await requestPermissions();
  }

  void _onNotificationTap(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('Notification payload: $payload');
      onNotificationClick.add(payload);
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> requestPermissions() async {
    // iOS izinlerini iste
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
    // Android izinlerini iste (Android 13+ için)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String taskId,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'task_channel', // channel id
      'Görev Hatırlatıcıları', // channel name
      channelDescription: 'Görev zamanından 5 dakika önce hatırlatma',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(
        badgeNumber: 1,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: taskId,
    );
  }

  // Schedule notification 5 minutes before task time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String taskId,
  }) async {
    // Subtract 5 minutes from the task time
    final tz.TZDateTime notificationTime = tz.TZDateTime.from(
      scheduledDate.subtract(const Duration(minutes: 5)),
      tz.local,
    );
    
    // Only schedule if it's in the future
    if (notificationTime.isAfter(tz.TZDateTime.now(tz.local))) {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'task_channel',
        'Görev Hatırlatıcıları',
        channelDescription: 'Görev zamanından 5 dakika önce hatırlatma',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(
          badgeNumber: 1,
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        notificationTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: taskId,
      );
    }
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
          
          await scheduleNotification(
            id: task.id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: 'Görev Hatırlatıcısı: ${task.title}',
            body: 'Göreviniz 5 dakika içinde başlayacak!',
            scheduledDate: taskDateTime,
            taskId: task.id.toString(),
          );
        }
      } catch (e) {
        debugPrint('Bildirim zamanlama hatası: $e');
      }
    }
  }

  // Cancel a notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Dispose method
  void dispose() {
    // Close any streams
    onNotificationClick.close();
  }
}