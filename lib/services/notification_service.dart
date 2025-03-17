import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rxdart/subjects.dart';

/// Bu servis şu anda devre dışı bırakılmıştır.
/// Bildirimler uygulamanın gelecek sürümünde tekrar eklenecektir.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  // Bildirim paketi geçici olarak kaldırıldı
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject<String?>();

  NotificationService._internal();

  Future<void> initNotification() async {
    debugPrint('NotificationService devre dışı (mock versiyon).');
  }

  // Bildirim yerine dialog kullanılıyor (Bu kısım korundu)
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

  // Dialog gösterme metodu korundu, bu UI ile çalışıyor
  void showNotificationDialog(task) {
    // Bu metot mevcut haliyle kalabilir çünkü UI'da kullanılıyor
    debugPrint('Bildirim diyaloğu gösteriliyor: ${task.title}');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    // Bildirimler devre dışı - mock metot
    debugPrint('Bildirimler devre dışı. Bildirim: "$title" tarih: $scheduledDate');
  }

  // Schedule notification for a task - Mock versiyonu
  Future<void> scheduleTaskNotification(task) async {
    if (task.id != null && task.time != null && task.time!.isNotEmpty) {
      debugPrint('Bildirimler devre dışı. Görev: ${task.title}, Saat: ${task.time}');
    }
  }

  Future<void> cancelNotification(int id) async {
    // Bildirimler devre dışı - mock metot
    debugPrint('Bildirimler devre dışı. İptal edilen bildirim ID: $id');
  }

  Future<void> cancelAllNotifications() async {
    // Bildirimler devre dışı - mock metot
    debugPrint('Bildirimler devre dışı. Tüm bildirimleri iptal etme çağrısı.');
  }

  Future<void> requestPermissions() async {
    // Bildirimler devre dışı - mock metot
    debugPrint('Bildirimler devre dışı. İzin isteme çağrısı.');
  }

  // Dispose method
  void dispose() {
    // Close any streams
    onNotificationClick.close();
  }
}