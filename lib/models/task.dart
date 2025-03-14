class Task {
  int? id;
  String title;
  String description;
  String date;
  String? time;
  bool isCompleted;
  int? categoryId;
  int priority;
  int userId;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.time,
    this.isCompleted = false,
    this.categoryId,
    required this.priority,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'isCompleted': isCompleted ? 1 : 0,
      'categoryId': categoryId,
      'priority': priority,
      'userId': userId,
    };
  }

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
    );
  }
}
