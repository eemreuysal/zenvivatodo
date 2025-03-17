import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart';

/// Uygulama içi bildirimlerin yönetiminden sorumlu servis
class NotificationService {
  // Sınıf değişkenleri
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  // Bildirim kanalları için sabit değerler
  static const String _channelId = 'task_reminders';
  static const String _channelName = 'Görev Hatırlatıcıları';
  static const String _channelDesc = 'Görevleriniz için hatırlatmalar';
  
  // Singleton yapısı
  static final NotificationService _instance = NotificationService._internal();
  
  // Constructorlar sınıf üyelerinden önce
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Bildirim servisini başlatır ve gerekli izinleri alır
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
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
      return true;
    } catch (e) {
      debugPrint('Bildirim servisi başlatılamadı: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Bildirim izinlerini isteme
  Future<void> _requestPermissions() async {
    try {
      // Android için özel kanal oluştur (Android 8.0+)
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin = 
          _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          
      if (androidPlugin != null) {
        await androidPlugin.requestPermission();
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId, 
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );
      }

      // iOS için izinler
      final darwinPlugin = 
          _notifications.resolvePlatformSpecificImplementation<DarwinFlutterLocalNotificationsPlugin>();
            
      if (darwinPlugin != null) {
        await darwinPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } on UnsupportedError catch (e) {
      debugPrint('Platform bildirim desteği yok: $e');
    } catch (e) {
      debugPrint('Bildirim izinleri alınamadı: $e');
    }
  }

  /// Bildirime tıklandığında tetiklenen fonksiyon
  void _onNotificationTap(NotificationResponse response) {
    // Payload içeriğine göre uygun ekrana yönlendirme
    if (response.payload != null) {
      debugPrint('Bildirim tıklandı: ${response.payload}');
      // Burada Navigator.push ile uygun ekrana yönlendirme yapılabilir
      // Bu işlemleri başka bir servise veya provider'a taşımak daha iyi olabilir
    }
  }

  /// Görev için bildirim zamanlama
  /// 
  /// [task] parametresi, bildirimi zamanlanacak görevi temsil eder
  /// Görev saatinden 5 dakika önce bildirim planlar
  Future<bool> scheduleTaskReminder(Task task) async {
    if (!_isInitialized) {
      final initialized = await init();
      if (!initialized) return false;
    }
    
    // Task geçerlilik kontrolü
    if (task.id == null || task.time == null || task.time!.isEmpty) {
      debugPrint('Geçersiz görev veya saat bilgisi eksik');
      return false;
    }

    try {
      // Tarih ve saat ayrıştırma
      final dateComponents = task.date.split('-').map(int.parse).toList();
      final timeComponents = task.time!.split(':').map(int.parse).toList();
      
      // Hatalı format kontrolü
      if (dateComponents.length != 3 || timeComponents.length != 2) {
        debugPrint('Tarih veya saat formatı hatalı');
        return false;
      }
      
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
        return false;
      }

      // Bildirimi planla
      await _notifications.zonedSchedule(
        task.id!, // Bildirim ID'si olarak görev ID'sini kullan
        'Görev Hatırlatıcısı', 
        '${task.title} göreviniz 5 dakika içinde başlayacak',
        tz.TZDateTime.from(reminderTime, tz.local),
        NotificationDetails(
          android: const AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
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
      return true;
    } on FormatException catch (e) {
      debugPrint('Tarih veya saat ayrıştırma hatası: $e');
      return false;
    } on Exception catch (e) {
      debugPrint('Bildirim planlama hatası: $e');
      return false;
    }
  }

  /// Bildirimi iptal etme
  /// 
  /// [taskId] parametresi, bildirimi iptal edilecek görevin ID'sini temsil eder
  Future<bool> cancelTaskReminder(int taskId) async {
    try {
      if (!_isInitialized) {
        final initialized = await init();
        if (!initialized) return false;
      }
      
      await _notifications.cancel(taskId);
      debugPrint('Bildirim iptal edildi: $taskId');
      return true;
    } catch (e) {
      debugPrint('Bildirim iptal edilirken hata: $e');
      return false;
    }
  }

  /// Tüm bildirimleri iptal etme
  Future<bool> cancelAllReminders() async {
    try {
      if (!_isInitialized) {
        final initialized = await init();
        if (!initialized) return false;
      }
      
      await _notifications.cancelAll();
      debugPrint('Tüm bildirimler iptal edildi');
      return true;
    } catch (e) {
      debugPrint('Tüm bildirimler iptal edilirken hata: $e');
      return false;
    }
  }
  
  /// Bildirim dialoglari için helper metod
  /// 
  /// [context] için geçerli BuildContext gereklidir
  /// [title] ve [message] dialog içeriğini oluşturur
  Future<void> showNotificationDialog(BuildContext context, String title, String message) async {
    if (context.mounted) {
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
}