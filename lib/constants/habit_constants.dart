import 'package:flutter/material.dart';

/// Alışkanlıklarla ilgili sabit değerler
class HabitConstants {
  // Frekans seçenekleri
  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';

  // Haftanın günleri (1: Pazartesi, 7: Pazar)
  static const Map<int, String> weekdays = {
    1: 'Pazartesi',
    2: 'Salı',
    3: 'Çarşamba',
    4: 'Perşembe',
    5: 'Cuma',
    6: 'Cumartesi',
    7: 'Pazar',
  };

  // Varsayılan alışkanlık renkleri
  static const List<Color> colors = [
    Color(0xFF1565C0), // Mavi
    Color(0xFF4CAF50), // Yeşil
    Color(0xFFF44336), // Kırmızı
    Color(0xFF9C27B0), // Mor
    Color(0xFFFF9800), // Turuncu
    Color(0xFF00BCD4), // Turkuaz
    Color(0xFFFFEB3B), // Sarı
    Color(0xFF795548), // Kahverengi
  ];

  // Alışkanlık ikonları
  static const Map<String, IconData> icons = {
    'sports': Icons.fitness_center,
    'meditation': Icons.self_improvement,
    'water': Icons.water_drop,
    'reading': Icons.menu_book,
    'study': Icons.school,
    'write': Icons.edit_note,
    'walk': Icons.directions_walk,
    'sleep': Icons.bedtime,
    'eat': Icons.restaurant,
    'coding': Icons.code,
    'pill': Icons.medication,
    'cycling': Icons.pedal_bike,
    'default': Icons.repeat,
  };

  // Alışkanlık kategorileri
  static const List<String> categories = [
    'Sağlık',
    'Fitness',
    'Zihinsel Sağlık',
    'Kişisel Gelişim',
    'Üretkenlik',
    'Diğer',
  ];

  // Başarı mesajları
  static const Map<int, String> achievementMessages = {
    3: 'Harika! 3 günlük zincir oluşturdun.',
    7: 'Bir haftayı tamamladın! Harika gidiyorsun.',
    14: 'İki hafta oldu! Tutarlılığın etkileyici.',
    21: 'Üç hafta! Artık bir alışkanlık oluşmaya başlıyor.',
    30: 'Bir ay! Kendini kutlamalısın.',
    60: 'İki ay! Muhteşem bir iş çıkarıyorsun.',
    90: 'Üç ay! Olağanüstü bir başarı.',
    180: 'Altı ay! Gerçek bir kararlılık örneği.',
    365: 'Bir yıl! İnanılmaz bir başarı. Harikasın!',
  };

  // Hedef gün seçenekleri
  static const List<int> targetDayOptions = [
    7, 14, 21, 30, 60, 90, 180, 365
  ];
}
