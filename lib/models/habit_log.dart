// HabitLog modeli - Modern Dart 3.7 özellikleri kullanılarak güncellendi

/// Alışkanlık takip kaydı sınıfı
class HabitLog {
  // Enhanced constructor (Dart 3.0+)
  const HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.notes,
    this.createdAt,
  });

  // Bugünün tarihiyle oluşturma
  factory HabitLog.forToday({
    int? id,
    required int habitId,
    bool completed = false,
    String? notes,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return HabitLog(
      id: id,
      habitId: habitId,
      date: dateStr,
      completed: completed,
      notes: notes,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  // Belirli bir tarih için oluşturma
  factory HabitLog.forDate({
    int? id,
    required int habitId,
    required DateTime logDate,
    bool completed = false,
    String? notes,
  }) {
    final dateStr =
        '${logDate.year}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}';

    return HabitLog(
      id: id,
      habitId: habitId,
      date: dateStr,
      completed: completed,
      notes: notes,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  // Map'ten nesne oluşturma
  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      habitId: map['habitId'],
      date: map['date'],
      completed: map['completed'] == 1,
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }
  final int? id;
  final int habitId;
  final String date;
  final bool completed;
  final String? notes;
  final String? createdAt;

  // Kopyalama yöntemi (immutability için)
  HabitLog copyWith({
    int? id,
    int? habitId,
    String? date,
    bool? completed,
    String? notes,
    String? createdAt,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Tamamlanma durumunu değiştirme
  HabitLog toggleCompletion() {
    return copyWith(completed: !completed);
  }

  // Not ekleme
  HabitLog withNotes(String newNotes) {
    return copyWith(notes: newNotes);
  }

  // Veritabanı için Map'e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date,
      'completed': completed ? 1 : 0,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  // String temsilini oluşturma
  @override
  String toString() {
    return 'HabitLog{id: $id, habitId: $habitId, date: $date, completed: $completed${notes != null ? ', notes: $notes' : ''}}';
  }

  // Eşitlik kontrolü için
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitLog && other.id == id && other.habitId == habitId && other.date == date;
  }

  @override
  int get hashCode => id.hashCode ^ habitId.hashCode ^ date.hashCode;

  // Tarih nesnesi olarak elde etme
  DateTime get dateAsDateTime {
    final parts = date.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  // Kaydın bugüne ait olup olmadığını kontrol etme
  bool get isToday {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return date == today;
  }
}
