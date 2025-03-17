// User modeli - Modern Dart 3.7 özellikleri kullanılarak güncellendi
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Uygulama kullanıcısı sınıfı
class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? createdAt;
  final String? lastLogin;

  // Enhanced constructor (Dart 3.0+)
  const User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.createdAt,
    this.lastLogin,
  });
  
  // Şifreyi hash'leyerek yeni kullanıcı oluştur (kayıt için)
  factory User.withHashedPassword({
    int? id,
    required String username,
    required String email,
    required String plainPassword,
  }) {
    final hashedPassword = _hashPassword(plainPassword);
    
    return User(
      id: id,
      username: username,
      email: email,
      password: hashedPassword,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
  
  // Şifreleri hash'leme yöntemi
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Şifreyi UTF-8'e dönüştür
    final digest = sha256.convert(bytes); // SHA-256 hash değerini al
    return digest.toString();
  }

  // Şifre doğrulama yöntemi
  bool verifyPassword(String plainPassword) {
    final hashedInput = _hashPassword(plainPassword);
    return hashedInput == password;
  }

  // Kopyalama yöntemi (immutability için)
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? createdAt,
    String? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Son giriş güncellemesi
  User withUpdatedLogin() {
    return copyWith(lastLogin: DateTime.now().toIso8601String());
  }

  // Veritabanı için Map'e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'created_at': createdAt,
      'last_login': lastLogin,
    };
  }

  // Map'ten nesne oluşturma
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      createdAt: map['created_at'],
      lastLogin: map['last_login'],
    );
  }

  // String temsilini oluşturma
  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email)';
  }

  // Eşitlik kontrolü için 
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;
}