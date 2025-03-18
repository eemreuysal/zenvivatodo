import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../main.dart'; // NavigatorKey için
import '../models/task.dart';

/// Uygulama içi bildirimlerin yönetiminden sorumlu servis
class NotificationService {
  
  // Constructorlar sınıf üyelerinden önce (lint kuralı: sort_constructors_first)
  // Singleton yapısı
  NotificationService._internal();
  factory NotificationService() => _instance;
  
  // Sınıf değişkenleri
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final _logger = Logger('NotificationService');
  bool _isInitialized = false;
  
  // Bildirim kanalları için sabit değerler
  static const String _channelId = 'task_reminders';
  static const String _channelName = 'Görev Hatırlatıcıları';
  static const String _channelDesc = 'Görevleriniz için hatırlatmalar';
  
  // Kanal grup tanımı (Android 8+ için önerilir)
  static const String _groupId = 'zenviva_todo_group';
  static const String _groupName = 'ZenViva Todo Bildirimleri';
  static final NotificationService _instance = NotificationService._internal();

  /// Bildirim servisini başlatır ve gerekli izinleri alır
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      // Zaman dilimi verilerini başlat
      tz_data.initializeTimeZones();

      // Bildirim kanalları için Android ayarları
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS bildirim ayarları - daha güncel iOS sürümleri için
      final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        // onDidReceiveLocalNotification kaldırıldı - artık kullanılmıyor
        requestAlertPermission: false, // _requestPermissions'da isteyeceğiz
        requestBadgePermission: false,
        requestSoundPermission: false,
        // Redundant default değeri kaldırıldı
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
    } on Exception catch (e) {
      _logger.severe('Bildirim servisi başlatılamadı: $e');
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
        // Android için izin alma - API değişti, AndroidFlutterLocalNotificationsPlugin için
        // requestPermissions metodu kullanılmalı
        final permissionGranted = await androidPlugin.requestPermissions();
        _logger.info('Android bildirim izni: $permissionGranted');
        
        // Bildirim kanalı oluştur
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId, 
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
            groupId: _groupId,
          ),
        );
        
        // Bildirim grubu oluştur - gruplanmış bildirimler için
        await androidPlugin.createNotificationChannelGroup(
          const AndroidNotificationChannelGroup(
            _groupId,
            _groupName,
          ),
        );
      }

      // iOS için izinler
      // Modern Dart 3.7 API kullanımı - platform özel yöntemler için güvenli tip kontrolleri
      final darwinPlugin = 
          _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
      // iOS izinlerini iste
      if (darwinPlugin != null) {
        await darwinPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true, // Kritik bildirimler için (Focus Mode durumunda bile bildirim gösterme)
        );
      }
    } on PlatformException catch (e) {
      // Platform-specifik hatalar için uygun şekilde işleyin
      _logger.warning('Platform izin desteği yok: $e');
    } on Exception catch (e) {
      _logger.warning('Bildirim izinleri alınamadı: $e');
    }
  }

  /// Bildirime tıklandığında tetiklenen fonksiyon
  void _onNotificationTap(NotificationResponse response) {
    // Payload içeriğine göre uygun ekrana yönlendirme
    if (response.payload != null) {
      _logger.info('Bildirim tıklandı: ${response.payload}');
      
      // Bildirim payload'ından görev ID'sini ayıkla
      final taskId = int.tryParse(response.payload!);
      
      if (taskId != null && navigatorKey.currentContext != null) {
        // Görev detay sayfasına yönlendir
        // Bu kısmı düzeltmek için TaskDetail ekranını gerektiriyor
        /*
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(taskId: taskId),
          ),
        );
        */
      }
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
      _logger.warning('Geçersiz görev veya saat bilgisi eksik');
      return false;
    }

    try {
      // Tarih ve saat ayrıştırma
      final dateComponents = task.date.split('-').map(int.parse).toList();
      final timeComponents = task.time!.split(':').map(int.parse).toList();
      
      // Hatalı format kontrolü
      if (dateComponents.length != 3 || timeComponents.length != 2) {
        _logger.warning('Tarih veya saat formatı hatalı');
        return false;
      }
      
      final scheduledDate = DateTime(
        dateComponents[0], // yıl
        dateComponents[1], // ay
        dateComponents[2], // gün
        timeComponents[0], // saat
        timeComponents[1], // dakika
      );
      
      // Bildirim zamanları oluştur - ikili bildirim sistemi
      final reminderTime = scheduledDate.subtract(const Duration(minutes: 5));
      final exactTime = scheduledDate;
      
      // Şu andan önceki bildirimler için kontrol
      if (reminderTime.isBefore(DateTime.now())) {
        _logger.info('Bildirim zamanı geçmiş, bildirim oluşturulmadı');
        return false;
      }

      // 5 dakika öncesi hatırlatma
      await _scheduleNotification(
        id: task.id!,
        title: 'Görev Hatırlatıcısı', 
        body: '${task.title} göreviniz 5 dakika içinde başlayacak',
        scheduledTime: reminderTime,
        payload: task.id.toString(),
      );
      
      // Tam zamanında hatırlatma
      await _scheduleNotification(
        id: task.id! + 100000, // İlk bildirimle çakışmasın diye farklı ID
        title: 'Görev Zamanı', 
        body: '${task.title} görevi için planlanan zaman geldi',
        scheduledTime: exactTime,
        payload: task.id.toString(),
        useFullScreenIntent: true, // Tam ekran bildirim (önemli görevler için)
      );
      
      _logger.info('Bildirim planlandı: ${task.id} - ${task.title} için ${reminderTime.toString()}');
      return true;
    } on FormatException catch (e) {
      _logger.warning('Tarih veya saat ayrıştırma hatası: $e');
      return false;
    } on Exception catch (e) {
      _logger.warning('Bildirim planlama hatası: $e');
      return false;
    }
  }
  
  /// Bildirimi planlayan yardımcı metod
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
    bool useFullScreenIntent = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      groupKey: _groupId,
      fullScreenIntent: useFullScreenIntent,
      category: AndroidNotificationCategory.reminder,
      actions: [
        const AndroidNotificationAction(
          'complete',
          'Tamamlandı olarak işaretle',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          'Ertele',
          showsUserInterface: true,
        ),
      ],
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'reminder',
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      id,
      title, 
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation parametre artık gerekli değil
      payload: payload,
    );
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
      
      // Ana hatırlatıcı bildirimi iptal et
      await _notifications.cancel(taskId);
      // Tam zaman bildirimi de iptal et
      await _notifications.cancel(taskId + 100000);
      
      _logger.info('Bildirim iptal edildi: $taskId');
      return true;
    } on Exception catch (e) {
      _logger.warning('Bildirim iptal edilirken hata: $e');
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
      _logger.info('Tüm bildirimler iptal edildi');
      return true;
    } on Exception catch (e) {
      _logger.warning('Tüm bildirimler iptal edilirken hata: $e');
      return false;
    }
  }
  
  /// Acil bildirim gösterme (anlık)
  Future<bool> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        final initialized = await init();
        if (!initialized) return false;
      }
      
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        groupKey: _groupId,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      
      return true;
    } on Exception catch (e) {
      _logger.warning('Anlık bildirim gösterilirken hata: $e');
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

  /// Bildirim izinlerini kontrol et
  Future<bool> areNotificationsEnabled() async {
    try {
      if (!_isInitialized) {
        final initialized = await init();
        if (!initialized) return false;
      }
      
      // Android için izin kontrolü
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin = 
          _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          
      if (androidPlugin != null) {
        final areEnabled = await androidPlugin.areNotificationsEnabled();
        return areEnabled ?? false;
      }
      
      // iOS için izin kontrolü buraya eklenebilir
      
      return true;
    } on Exception catch (e) {
      _logger.warning('Bildirim izinleri kontrol edilirken hata: $e');
      return false;
    }
  }
}