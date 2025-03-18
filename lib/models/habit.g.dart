// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Habit _$HabitFromJson(Map<String, dynamic> json) => Habit(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      frequency: Habit._frequencyFromJson(json['frequency'] as String),
      frequencyDays: json['frequency_days'] as String?,
      startDate: json['start_date'] as String,
      targetDays: (json['target_days'] as num).toInt(),
      colorCode: (json['color_code'] as num).toInt(),
      reminderTime: json['reminder_time'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      showInDashboard: json['show_in_dashboard'] as bool? ?? false,
      userId: (json['user_id'] as num).toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$HabitToJson(Habit instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'frequency': Habit._frequencyToJson(instance.frequency),
      'frequency_days': instance.frequencyDays,
      'start_date': instance.startDate,
      'target_days': instance.targetDays,
      'color_code': instance.colorCode,
      'reminder_time': instance.reminderTime,
      'is_archived': instance.isArchived,
      'current_streak': instance.currentStreak,
      'longest_streak': instance.longestStreak,
      'show_in_dashboard': instance.showInDashboard,
      'user_id': instance.userId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
