// Task modeli - Modern Dart 3.7 özellikleri kullanılarak güncellendi
import 'package:uuid/uuid.dart';

// Pattern Matching ve Records kullanılan örnek (Dart 3.7)
enum TaskPriority {
  low(value: 0, label: 'Düşük'),
  medium(value: 1, label: 'Orta'),
  high(value: 2, label: 'Yüksek');

  const TaskPriority({required this.value, required this.label});
  final int value;
  final String label;

  // Değerden enum öğesini döndürme
  static TaskPriority fromValue(int value) => switch (value) {
    0 => TaskPriority.low,
    1 => TaskPriority.medium,
    2 => TaskPriority.high,
    _ => TaskPriority.medium, // Varsayılan 
  };
}

// Task modeli - final kullanımı, okunabilirlik artırıldı, and constructor sadeleştirildi
class Task { // Benzersiz tanımlayıcı - opsiyonel

  // Enhanced constructor with super parameters (Dart 3.0+)
  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.time,
    this.isCompleted = false,
    this.categoryId,
    required int priority,
    required this.userId,
    this.uniqueId,
  }) : priority = TaskPriority.fromValue(priority);

  // Named constructor - biçimlendirilmiş tarih ve saat ile görev oluşturma
  Task.withDateTime({
    this.id,
    required this.title,
    required this.description,
    required DateTime dateTime,
    this.isCompleted = false,
    this.categoryId,
    required int priority,
    required this.userId,
    this.uniqueId,
  })  : date = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}',
        time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        priority = TaskPriority.fromValue(priority);

  // Benzersiz ID ile yeni görev oluşturma
  Task.withUniqueId({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.time,
    this.isCompleted = false,
    this.categoryId,
    required int priority,
    required this.userId,
  })  : priority = TaskPriority.fromValue(priority),
        uniqueId = const Uuid().v4();

  // Map'ten nesne oluşturma
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      time: map['time'],
      isCompleted: map['isCompleted'] == 1,
      categoryId: map['categoryId'],
      priority: map['priority'],
      userId: map['userId'],
      uniqueId: map['uniqueId'],
    );
  }
  final int? id;
  final String title;
  final String description;
  final String date;
  final String? time;
  final bool isCompleted;
  final int? categoryId;
  final TaskPriority priority;
  final int userId;
  final String? uniqueId;

  // Immutability için kopya oluşturma (kopyalama ile yeni nesne)
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    String? time,
    bool? isCompleted,
    int? categoryId,
    int? priority,
    int? userId,
    String? uniqueId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time, // if-null operatörü (??) kullanıldı
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId, // if-null operatörü (??) kullanıldı
      priority: priority ?? this.priority.value,
      userId: userId ?? this.userId,
      uniqueId: uniqueId ?? this.uniqueId,
    );
  }

  // Veritabanı için Map'e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'isCompleted': isCompleted ? 1 : 0,
      'categoryId': categoryId,
      'priority': priority.value,
      'userId': userId,
      'uniqueId': uniqueId,
    };
  }

  // String temsilini oluşturma
  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: ${priority.label}, date: $date, time: $time, completed: $isCompleted)';
  }

  // Eşitlik kontrolü için 
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.date == date &&
        other.time == time &&
        other.isCompleted == isCompleted &&
        other.categoryId == categoryId &&
        other.priority.value == priority.value &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        date.hashCode ^
        time.hashCode ^
        isCompleted.hashCode ^
        categoryId.hashCode ^
        priority.hashCode ^
        userId.hashCode;
  }
}