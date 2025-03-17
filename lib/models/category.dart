// Kategori modeli - Modern Dart 3.7 özellikleri kullanılarak güncellendi
import 'package:flutter/material.dart';

/// Görev kategorisi sınıfı
class Category {
  final int? id;
  final String name;
  final int color;
  final int? userId;
  final String? createdAt;

  // Enhanced constructor (Dart 3.0+)
  const Category({
    this.id,
    required this.name,
    required this.color,
    this.userId,
    this.createdAt,
  });

  // Belirli bir renkle oluşturma
  Category.withColor({
    this.id,
    required this.name,
    required Color colorObj,
    this.userId,
    this.createdAt,
  }) : color = colorObj.value;

  // Kopyalama yöntemi (immutability için)
  Category copyWith({
    int? id,
    String? name,
    int? color,
    int? userId,
    String? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Veritabanı için Map'e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'userId': userId,
      'created_at': createdAt,
    };
  }

  // Map'ten nesne oluşturma
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      userId: map['userId'],
      createdAt: map['created_at'],
    );
  }

  // String temsilini oluşturma
  @override
  String toString() {
    return 'Category(id: $id, name: $name, color: $color, userId: $userId)';
  }

  // Eşitlik kontrolü için 
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ color.hashCode ^ userId.hashCode;
  }

  // Color nesnesini alma (Flutter Material entegrasyonu için)
  Color get colorValue => Color(color);
}