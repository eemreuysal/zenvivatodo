// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskDTO _$TaskDTOFromJson(Map<String, dynamic> json) => TaskDTO(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  date: json['date'] as String,
  time: json['time'] as String?,
  isCompleted: json['is_completed'] as bool? ?? false,
  categoryId: (json['category_id'] as num?)?.toInt(),
  priority: (json['priority'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  uniqueId: json['unique_id'] as String?,
);

Map<String, dynamic> _$TaskDTOToJson(TaskDTO instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'date': instance.date,
  'time': instance.time,
  'is_completed': instance.isCompleted,
  'category_id': instance.categoryId,
  'priority': instance.priority,
  'user_id': instance.userId,
  'unique_id': instance.uniqueId,
};
