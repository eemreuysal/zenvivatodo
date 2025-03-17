import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart';

class NotificationService {
  // Singleton yapısı
  static final NotificationService _instance = NotificationService._internal();
  
  // Sınıf değişkenleri
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  // Constructorlar diğer üyelerden önce
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    // Zaman dilimi verilerini başlat
    tz_data.initializeTimeZones();

    // Bildirim kanalları için Android ayarları
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS bildirim ayarları - daha fazla izin isteme özelliği
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // iOS 10 öncesi için gerekli (modern iOS'ta kullanılmıyor)
        debugPrint('Eski iOS bildirimi alındı: $id, $title, $body, $payload');
      },
    );

    // Tüm platform ayarlarını birleştir
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Bildirimleri başlat
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // İzinleri kontrol et
    await _requestPermissions();

    _isInitialized = true;
  }

  // Bildirim izinlerini iste
  Future<void> _requestPermissions() async {
    // Android için özel kanal oluştur (Android 8.0+)
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = 
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'task_reminders', 
        'Görev Hatırlatıcıları',
        description: 'Görevleriniz için hatırlatmalar',
        importance: Importance.high,
      ));
    }

    // iOS için izinler
    // Darwin eklentisini Flutter 3.29+ uyumlu bir şekilde güncelliyoruz
    try {
      final darwinPlugin = 
          _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
          
      if (darwinPlugin != null) {
        await darwinPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } on UnsupportedError catch (e) {
      debugPrint('iOS bildirimleri için platform desteği yok: $e');
    } catch (e) {
      debugPrint('iOS bildirimleri izin isteme hatası: $e');
    }
  }

  // Bildirime tıklandığında
  void _onNotificationTap(NotificationResponse response) {
    // Payload içeriğine göre uygun ekrana yönlendirme
    if (response.payload != null) {
      debugPrint('Bildirim tıklandı: ${response.payload}');
      // Burada Navigator.push ile uygun ekrana yönlendirme yapılabilir
    }
  }

  // Görev için bildirim zamanla
  Future<void> scheduleTaskReminder(Task task) async {
    if (!_isInitialized) await init();
    
    // Görev zamanı ayarlanmamışsa bildirim oluşturma
    if (task.id == null || task.time == null) return;

    try {
      // Tarih ve saat ayrıştırma
      final dateComponents = task.date.split('-').map(int.parse).toList();
      final timeComponents = task.time!.split(':').map(int.parse).toList();
      
      final scheduledDate = DateTime(
        dateComponents[0], // yıl
        dateComponents[1], // ay
        dateComponents[2], // gün
        timeComponents[0], // saat
        timeComponents[1], // dakika
      );
      
      // Bildirim zamanını, görev zamanından 5 dakika önce olacak şekilde ayarla
      final reminderTime = scheduledDate.subtract(const Duration(minutes: 5));
      
      // Şu andan önceki bildirimler için kontrol
      if (reminderTime.isBefore(DateTime.now())) {
        debugPrint('Bildirim zamanı geçmiş, bildirim oluşturulmadı');
        return;
      }

      // Bildirimi planla
      await _notifications.zonedSchedule(
        task.id!, // Bildirim ID'si olarak görev ID'sini kullan
        'Görev Hatırlatıcısı', 
        '${task.title} göreviniz 5 dakika içinde başlayacak',
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Görev Hatırlatıcıları',
            channelDescription: 'Görevleriniz için hatırlatmalar',
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
        payload: task.id.toString(),
      );
      
      debugPrint('Bildirim planlandı: ${task.id} - ${task.title} için ${reminderTime.toString()}');
    } on FormatException catch (e) {
      debugPrint('Tarih veya saat ayrıştırma hatası: $e');
    } on ArgumentError catch (e) {
      debugPrint('Bildirim argüman hatası: $e');
    } catch (e) {
      debugPrint('Bildirim planlama hatası: $e');
    }
  }

  // Bildirimi iptal et
  Future<void> cancelTaskReminder(int taskId) async {
    if (!_isInitialized) await init();
    
    await _notifications.cancel(taskId);
    debugPrint('Bildirim iptal edildi: $taskId');
  }

  // Tüm bildirimleri iptal et
  Future<void> cancelAllReminders() async {
    if (!_isInitialized) await init();
    
    await _notifications.cancelAll();
    debugPrint('Tüm bildirimler iptal edildi');
  }
  
  // Bildirim dialoglari için helper metod
  Future<void> showNotificationDialog(BuildContext context, String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
