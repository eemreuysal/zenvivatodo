// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
      time: json['time'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      categoryId: json['categoryId'] as int?,
      priority: json['priority'] as int,
      userId: json['userId'] as int,
      uniqueId: json['uniqueId'] as String?,
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'date': instance.date,
      'time': instance.time,
      'isCompleted': instance.isCompleted,
      'categoryId': instance.categoryId,
      'priority': instance.priorityValue,
      'userId': instance.userId,
      'uniqueId': instance.uniqueId,
    };

TaskDTO _$TaskDTOFromJson(Map<String, dynamic> json) => TaskDTO(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
      time: json['time'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      categoryId: json['categoryId'] as int?,
      priority: json['priority'] as int,
      userId: json['userId'] as int,
      uniqueId: json['uniqueId'] as String?,
    );

Map<String, dynamic> _$TaskDTOToJson(TaskDTO instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'date': instance.date,
      'time': instance.time,
      'isCompleted': instance.isCompleted,
      'categoryId': instance.categoryId,
      'priority': instance.priority,
      'userId': instance.userId,
      'uniqueId': instance.uniqueId,
    };
