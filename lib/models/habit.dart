class Habit {
  int? id;
  String title;
  String description;
  String frequency; // 'daily', 'weekly', 'monthly'
  String? frequencyDays; // "1,3,5,7" (Pazartesi, Çarşamba, Cuma, Pazar)
  String startDate;
  int targetDays;
  int colorCode;
  String? reminderTime;
  bool isArchived;
  int currentStreak;
  int longestStreak;
  bool showInDashboard; // Dashboard'da göster seçeneği
  int userId;

  Habit({
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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'frequency': frequency,
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
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      frequency: map['frequency'],
      frequencyDays: map['frequencyDays'],
      startDate: map['startDate'],
      targetDays: map['targetDays'],
      colorCode: map['colorCode'],
      reminderTime: map['reminderTime'],
      isArchived: map['isArchived'] == 1,
      showInDashboard: map['showInDashboard'] == 1,
      currentStreak: map['currentStreak'],
      longestStreak: map['longestStreak'],
      userId: map['userId'],
    );
  }

  @override
  String toString() {
    return 'Habit{id: $id, title: $title, frequency: $frequency, currentStreak: $currentStreak, showInDashboard: $showInDashboard}';
  }
}