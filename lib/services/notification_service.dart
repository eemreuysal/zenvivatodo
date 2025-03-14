import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:rxdart/rxdart.dart';
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();
  
  NotificationService._internal();

  Future<void> initNotification() async {
    // Time zone setup
    await _configureLocalTimeZone();
    
    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      // null means using the default app icon
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'task_reminder_channel',
          channelName: 'Görev Hatırlatıcıları',
          channelDescription: 'Görev zamanından 5 dakika önce hatırlatma',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          locked: false,
          enableVibration: true,
        )
      ],
    );

    // Listen to notification events
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    // Request permission
    await requestPermissions();
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification created: ${receivedNotification.id}');
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification displayed: ${receivedNotification.id}');
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('Notification dismissed: ${receivedAction.id}');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('Notification action received: ${receivedAction.id}');
    
    // We can add the task ID to the stream here
    if (receivedAction.payload != null && 
        receivedAction.payload!.containsKey('taskId')) {
      final taskId = receivedAction.payload!['taskId'];
      // Since this is a static method, we need a different approach
      // We'll handle this in the main app when necessary
      debugPrint('Task ID from notification: $taskId');
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> requestPermissions() async {
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String taskId,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'task_reminder_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: {'taskId': taskId},
      ),
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
    final DateTime notificationTime = scheduledDate.subtract(const Duration(minutes: 5));
    
    // Only schedule if it's in the future
    if (notificationTime.isAfter(DateTime.now())) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'task_reminder_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          payload: {'taskId': taskId},
        ),
        schedule: NotificationCalendar.fromDate(date: notificationTime),
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
    await AwesomeNotifications().cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Dispose (compatible with 0.8.3 version)
  void dispose() {
    // In 0.8.3 we don't need to explicitly close sinks
  }
}
