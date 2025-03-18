// User modeli - Modern Dart 3.7 özellikleri ve güvenli şifreleme kullanılarak güncellendi
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Uygulama kullanıcısı sınıfı
class User {

  // Enhanced constructor (Dart 3.0+)
  const User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.createdAt,
    this.lastLogin,
  });
  
  // Şifreyi güvenli şekilde hash'leyerek yeni kullanıcı oluştur (kayıt için)
  factory User.withHashedPassword({
    int? id,
    required String username,
    required String email,
    required String plainPassword,
  }) {
    final hashedPassword = _secureHash(plainPassword);
    
    return User(
      id: id,
      username: username,
      email: email,
      password: hashedPassword,
      createdAt: DateTime.now().toIso8601String(),
    );
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
  final int? id;
  final String username;
  final String email;
  final String password; // Artık "salt:hash" formatında saklanıyor
  final String? createdAt;
  final String? lastLogin;
  
  // Daha güvenli şifre hashleme yöntemi
  static String _secureHash(String password) {
    // Rastgele salt (tuz) oluştur
    final Random random = Random.secure();
    final List<int> saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final String salt = base64Encode(saltBytes);
    
    // PBKDF2 benzeri bir yaklaşım - daha fazla iterasyon güvenliği artırır
    String hash = password + salt;
    for (int i = 0; i < 1000; i++) {
      final bytes = utf8.encode(hash);
      hash = sha256.convert(bytes).toString();
    }
    
    // salt:hash formatında döndür
    return '$salt:$hash';
  }

  // Şifre doğrulama yöntemi - yeni formata uygun
  bool verifyPassword(String plainPassword) {
    // Şifre eski formatta mı kontrol et (geçiş süreci için)
    if (!password.contains(':')) {
      // Eski formatta, basit SHA-256 kontrolü yap
      final bytes = utf8.encode(plainPassword);
      final digest = sha256.convert(bytes).toString();
      return digest == password;
    }
    
    // Yeni format (salt:hash)
    final parts = password.split(':');
    if (parts.length != 2) return false;
    
    final salt = parts[0];
    final storedHash = parts[1];
    
    // Aynı algoritma ile kontrol et
    String hash = plainPassword + salt;
    for (int i = 0; i < 1000; i++) {
      final bytes = utf8.encode(hash);
      hash = sha256.convert(bytes).toString();
    }
    
    return hash == storedHash;
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