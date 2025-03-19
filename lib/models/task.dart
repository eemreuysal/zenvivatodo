// Task modeli - JSON serializable desteği eklendi
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

// Bu dosya ile ilişkili .g.dart dosyasını dahil et
part 'task.g.dart';

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

// Ana Task sınıfı - Bu sınıf veritabanı ve uygulama için kullanılacak
class Task {
  // Constructor - int olarak priority alır, TaskPriority'ye dönüştürür
  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.time,
    required this.isCompleted,
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
    required this.isCompleted,
    this.categoryId,
    required int priority,
    required this.userId,
    this.uniqueId,
  }) : date =
           '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}',
       time =
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
       priority = TaskPriority.fromValue(priority);

  // Benzersiz ID ile yeni görev oluşturma
  Task.withUniqueId({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.time,
    required this.isCompleted,
    this.categoryId,
    required int priority,
    required this.userId,
  }) : priority = TaskPriority.fromValue(priority),
       uniqueId = const Uuid().v4();

  // Map'ten nesne oluşturma - SQLite veritabanı ile uyumluluk için
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      date: map['date'],
      time: map['time'],
      isCompleted: map['isCompleted'] == 1,
      categoryId: map['categoryId'],
      priority: map['priority'],
      userId: map['userId'],
      uniqueId: map['uniqueId'],
    );
  }

  // Firestore'dan nesne oluşturma
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    
    // data['isCompleted'] tipinde bool? değerini alıyoruz
    // Eğer null ise, varsayılan değer olarak false kullanacağız
    final bool completionStatus = data['isCompleted'] as bool? ?? false;
    
    return Task(
      id: null,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      date: data['date'] as String? ?? '',
      time: data['time'] as String?,
      isCompleted: completionStatus,
      categoryId: data['categoryId'] as int?,
      priority: data['priority'] as int? ?? 1,
      userId: data['userId'] as int? ?? 0,
      uniqueId: doc.id,
    );
  }

  // JSON'dan nesne oluşturma - API ile uyumluluk için
  factory Task.fromJson(Map<String, dynamic> json) {
    return TaskDTO.fromJson(json).toTask();
  }

  // Benzersiz tanımlayıcı - opsiyonel
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

  // Öncelik değerini int olarak döndür
  int get priorityValue => priority.value;

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
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority.value,
      userId: userId ?? this.userId,
      uniqueId: uniqueId ?? this.uniqueId,
    );
  }

  // Veritabanı için Map'e dönüştürme - SQLite ile uyumluluk için
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

  // Firestore için Map'e dönüştürme
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'isCompleted': isCompleted,
      'categoryId': categoryId,
      'priority': priority.value,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // JSON'a dönüştürme - API ile uyumluluk için
  Map<String, dynamic> toJson() {
    return TaskDTO.fromTask(this).toJson();
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

// TaskDTO sınıfı, Task'ın JSON serileştirme için kullanılacak olan kısmı
@JsonSerializable()
class TaskDTO {
  TaskDTO({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.time,
    required this.isCompleted,
    this.categoryId,
    required this.priority,
    required this.userId,
    this.uniqueId,
  });

  factory TaskDTO.fromJson(Map<String, dynamic> json) => _$TaskDTOFromJson(json);

  factory TaskDTO.fromTask(Task task) {
    return TaskDTO(
      id: task.id,
      title: task.title,
      description: task.description,
      date: task.date,
      time: task.time,
      isCompleted: task.isCompleted,
      categoryId: task.categoryId,
      priority: task.priorityValue,
      userId: task.userId,
      uniqueId: task.uniqueId,
    );
  }

  final int? id;
  final String title;
  final String description;
  final String date;
  final String? time;
  final bool isCompleted;
  final int? categoryId;
  final int priority;
  final int userId;
  final String? uniqueId;

  Map<String, dynamic> toJson() => _$TaskDTOToJson(this);

  Task toTask() {
    return Task(
      id: id,
      title: title,
      description: description,
      date: date,
      time: time,
      isCompleted: isCompleted,
      categoryId: categoryId,
      priority: priority,
      userId: userId,
      uniqueId: uniqueId,
    );
  }
}