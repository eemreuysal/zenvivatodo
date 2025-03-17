import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_helper.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Basit şifre hashlemesi - SHA-256 kullanır
  String _hashPassword(String password) {
    // String birleştirme yerine string interpolasyon kullanma
    final bytes = utf8.encode('$password zenviva_salt'); // Sabit salt eklemek güvenliği artırır
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      // Şifreyi hashle
      final hashedPassword = _hashPassword(password);
      
      User user = User(username: username, email: email, password: hashedPassword);

      int userId = await _databaseHelper.insertUser(user);
      if (userId > 0) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error registering user: $e');
      return false;
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      // Şifreyi hashle
      final hashedPassword = _hashPassword(password);
      
      User? user = await _databaseHelper.getUser(username, hashedPassword);
      if (user != null) {
        await _saveUserSession(user.id!);
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return null;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<void> _saveUserSession(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  Future<User?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      return await _databaseHelper.getUserById(userId);
    }
    return null;
  }

  Future<bool> updateUserProfile(User user) async {
    try {
      // Eğer şifre değiştiriliyorsa, yeni şifreyi hashle
      // Not: Bu, mevcut şifre değiştirme UI'ına bağlıdır
      // Burada user.password'ün zaten hashlenmiş olduğunu varsayıyoruz
      
      int result = await _databaseHelper.updateUser(user);
      return result > 0;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // Şifre değiştirme için özel metot
  Future<bool> changePassword(int userId, String newPassword) async {
    try {
      // Şifreyi hashle
      final hashedPassword = _hashPassword(newPassword);
      
      // Mevcut kullanıcıyı getir
      User? user = await _databaseHelper.getUserById(userId);
      if (user == null) return false;
      
      // Şifreyi güncelle
      user.password = hashedPassword;
      
      int result = await _databaseHelper.updateUser(user);
      return result > 0;
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false;
    }
  }

  Future<bool> deleteUserAccount(int userId) async {
    try {
      await logout();
      int result = await _databaseHelper.deleteUser(userId);
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting user account: $e');
      return false;
    }
  }
}