class HabitLog {
  int? id;
  int habitId;
  String date;
  bool completed;
  String? notes;

  HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date,
      'completed': completed ? 1 : 0,
      'notes': notes,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      habitId: map['habitId'],
      date: map['date'],
      completed: map['completed'] == 1,
      notes: map['notes'],
    );
  }

  @override
  String toString() {
    return 'HabitLog{id: $id, habitId: $habitId, date: $date, completed: $completed}';
  }
}
