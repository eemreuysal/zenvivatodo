// Habit modeli - Modern Dart 3.7 özellikleri ve JSON serializable kullanılarak güncellendi
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

// Bu dosya ile ilişkili .g.dart dosyasını dahil et
part 'habit.g.dart';

/// Alışkanlık sıklığı için enum (Dart 3.7 pattern matching desteği ile)
enum HabitFrequency {
  daily(value: 'daily', label: 'Günlük'),
  weekly(value: 'weekly', label: 'Haftalık'),
  monthly(value: 'monthly', label: 'Aylık'),
  custom(value: 'custom', label: 'Özel');

  const HabitFrequency({required this.value, required this.label});
  final String value;
  final String label;

  // String'ten enum değeri dönüştürme
  static HabitFrequency fromValue(String value) => switch (value) {
    'daily' => HabitFrequency.daily,
    'weekly' => HabitFrequency.weekly,
    'monthly' => HabitFrequency.monthly,
    'custom' => HabitFrequency.custom,
    _ => HabitFrequency.daily, // Varsayılan değer
  };

  // Enum değerini String'e dönüştürme
  @override
  String toString() => value;
}

/// Alışkanlık modeli
@JsonSerializable()
class Habit {
  // Enhanced constructor (Dart 3.0+)
  const Habit({
    this.id,
    required this.title,
    this.description = '',
    required this.frequency,
    this.frequencyDays,
    required this.startDate,
    required this.targetDays,
    required this.colorCode,
    this.reminderTime,
    this.isArchived = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.showInDashboard = false,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // String sıklık ile oluşturma (eski API uyumluluğu için)
  factory Habit.withStringFrequency({
    int? id,
    required String title,
    String description = '',
    required String frequencyStr,
    String? frequencyDays,
    required String startDate,
    required int targetDays,
    required int colorCode,
    String? reminderTime,
    bool isArchived = false,
    int currentStreak = 0,
    int longestStreak = 0,
    bool showInDashboard = false,
    required int userId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Habit(
      id: id,
      title: title,
      description: description,
      frequency: HabitFrequency.fromValue(frequencyStr),
      frequencyDays: frequencyDays,
      startDate: startDate,
      targetDays: targetDays,
      colorCode: colorCode,
      reminderTime: reminderTime,
      isArchived: isArchived,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      showInDashboard: showInDashboard,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Belirli bir renkle oluşturma
  factory Habit.withColor({
    int? id,
    required String title,
    String description = '',
    required HabitFrequency frequency,
    String? frequencyDays,
    required String startDate,
    required int targetDays,
    required Color color,
    String? reminderTime,
    bool isArchived = false,
    int currentStreak = 0,
    int longestStreak = 0,
    bool showInDashboard = false,
    required int userId,
  }) {
    return Habit(
      id: id,
      title: title,
      description: description,
      frequency: frequency,
      frequencyDays: frequencyDays,
      startDate: startDate,
      targetDays: targetDays,
      colorCode: color.toARGB32(),
      reminderTime: reminderTime,
      isArchived: isArchived,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      showInDashboard: showInDashboard,
      userId: userId,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  // Map'ten nesne oluşturma (SQLite uyumluluğu için)
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit.withStringFrequency(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      frequencyStr: map['frequency'],
      frequencyDays: map['frequencyDays'],
      startDate: map['startDate'],
      targetDays: map['targetDays'],
      colorCode: map['colorCode'],
      reminderTime: map['reminderTime'],
      isArchived: map['isArchived'] == 1,
      showInDashboard: map['showInDashboard'] == 1,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      userId: map['userId'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // JSON'dan nesne oluşturma
  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);

  final int? id;
  final String title;
  final String description;

  @JsonKey(toJson: _frequencyToJson, fromJson: _frequencyFromJson)
  final HabitFrequency frequency;

  final String? frequencyDays; // "1,3,5,7" (Pazartesi, Çarşamba, Cuma, Pazar)
  final String startDate;
  final int targetDays;
  final int colorCode;
  final String? reminderTime;
  final bool isArchived;
  final int currentStreak;
  final int longestStreak;
  final bool showInDashboard;
  final int userId;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  // Kopyalama yöntemi (immutability için)
  Habit copyWith({
    int? id,
    String? title,
    String? description,
    HabitFrequency? frequency,
    String? frequencyDays,
    String? startDate,
    int? targetDays,
    int? colorCode,
    String? reminderTime,
    bool? isArchived,
    int? currentStreak,
    int? longestStreak,
    bool? showInDashboard,
    int? userId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      startDate: startDate ?? this.startDate,
      targetDays: targetDays ?? this.targetDays,
      colorCode: colorCode ?? this.colorCode,
      reminderTime: reminderTime ?? this.reminderTime,
      isArchived: isArchived ?? this.isArchived,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      showInDashboard: showInDashboard ?? this.showInDashboard,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Streak güncelleme yöntemleri
  Habit incrementStreak() {
    final newCurrentStreak = currentStreak + 1;
    final newLongestStreak = newCurrentStreak > longestStreak ? newCurrentStreak : longestStreak;

    return copyWith(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  Habit resetStreak() {
    return copyWith(currentStreak: 0, updatedAt: DateTime.now().toIso8601String());
  }

  // Arşiv durumunu değiştirme
  Habit toggleArchived() {
    return copyWith(isArchived: !isArchived, updatedAt: DateTime.now().toIso8601String());
  }

  // Dashboard görünürlüğünü değiştirme
  Habit toggleDashboardVisibility() {
    return copyWith(showInDashboard: !showInDashboard, updatedAt: DateTime.now().toIso8601String());
  }

  // Veritabanı için Map'e dönüştürme (SQLite uyumluluğu için)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'frequency': frequency.value,
      'frequencyDays': frequencyDays,
      'startDate': startDate,
      'targetDays': targetDays,
      'colorCode': colorCode,
      'reminderTime': reminderTime,
      'isArchived': isArchived ? 1 : 0,
      'showInDashboard': showInDashboard ? 1 : 0,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'userId': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // JSON'a dönüştürme metodu
  Map<String, dynamic> toJson() => _$HabitToJson(this);

  // JSON'a HabitFrequency'i dönüştürme
  static String _frequencyToJson(HabitFrequency frequency) => frequency.value;

  // JSON'dan HabitFrequency oluşturma
  static HabitFrequency _frequencyFromJson(String value) => HabitFrequency.fromValue(value);

  // String temsilini oluşturma
  @override
  String toString() {
    return 'Habit{id: $id, title: $title, frequency: ${frequency.label}, currentStreak: $currentStreak, showInDashboard: $showInDashboard}';
  }

  // Eşitlik kontrolü için
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.id == id &&
        other.title == title &&
        other.frequency == frequency &&
        other.startDate == startDate &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ frequency.hashCode ^ startDate.hashCode ^ userId.hashCode;
  }

  // Renk değeri elde etme
  Color get color => Color(colorCode);

  // Tamamlanma oranı hesaplama
  double get completionRate {
    if (targetDays <= 0) return 0.0;
    return currentStreak / targetDays;
  }
}
