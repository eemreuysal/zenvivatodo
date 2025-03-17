import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'database_helper.dart';

/// Kullanıcı kimlik doğrulama ve yönetimi hizmetleri
class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Kullanıcı kaydı
  /// 
  /// [username], [email] ve [password] bilgileriyle yeni bir kullanıcı oluşturur.
  /// Başarılı olursa true, başarısız olursa false döner.
  Future<bool> register(String username, String email, String password) async {
    try {
      // User modeli artık şifre hash'leme işlemini kendisi yapıyor
      final user = User.withHashedPassword(
        username: username, 
        email: email, 
        plainPassword: password,
      );

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

  /// Kullanıcı girişi
  /// 
  /// [username] ve [password] ile oturum açmayı dener.
  /// Başarılı olursa User nesnesini, başarısız olursa null döner.
  Future<User?> login(String username, String password) async {
    try {
      // Veritabanında kullanıcıyı bul
      final users = await _databaseHelper.database;
      final result = await users.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      
      if (result.isEmpty) {
        return null;
      }
      
      // Kullanıcı nesnesini oluştur
      final user = User.fromMap(result.first);
      
      // Şifreyi doğrula
      if (user.verifyPassword(password)) {
        // Güncelleme: son giriş zamanını güncelle
        final updatedUser = user.withUpdatedLogin();
        await _databaseHelper.updateUser(updatedUser);
        
        // Oturumu kaydet
        await _saveUserSession(user.id!);
        return updatedUser;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return null;
    }
  }

  /// Kullanıcı çıkışı
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  /// Kullanıcı oturumu kaydetme
  Future<void> _saveUserSession(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  /// Mevcut kullanıcıyı getir
  Future<User?> getCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId != null) {
        return await _databaseHelper.getUserById(userId);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Kullanıcı oturumunun aktif olup olmadığını kontrol et
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Kullanıcı profili güncelleme
  Future<bool> updateUserProfile({
    required int userId,
    String? username,
    String? email,
  }) async {
    try {
      // Mevcut kullanıcıyı getir
      User? user = await _databaseHelper.getUserById(userId);
      if (user == null) return false;
      
      // Değişimleri uygula
      final updatedUser = user.copyWith(
        username: username,
        email: email,
      );
      
      int result = await _databaseHelper.updateUser(updatedUser);
      return result > 0;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  /// Şifre değiştirme
  Future<bool> changePassword({
    required int userId, 
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Mevcut kullanıcıyı getir
      User? user = await _databaseHelper.getUserById(userId);
      if (user == null) return false;
      
      // Mevcut şifreyi doğrula
      if (!user.verifyPassword(currentPassword)) {
        return false;
      }
      
      // Yeni şifreli kullanıcı oluştur
      final updatedUser = User.withHashedPassword(
        id: userId,
        username: user.username,
        email: user.email,
        plainPassword: newPassword,
      );
      
      int result = await _databaseHelper.updateUser(updatedUser);
      return result > 0;
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false;
    }
  }

  /// Kullanıcı hesabını silme
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
  
  /// Test kullanıcısı oluştur
  /// Bu yöntem geliştirme/test için kullanılır
  Future<User?> createTestUser() async {
    try {
      // Önce test kullanıcısının var olup olmadığını kontrol et
      const testUsername = 'test';
      
      // Veritabanında kullanıcıyı ara
      final db = await _databaseHelper.database;
      final result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [testUsername],
      );
      
      // Eğer kullanıcı varsa, onu döndür
      if (result.isNotEmpty) {
        return User.fromMap(result.first);
      }
      
      // Yoksa yeni test kullanıcısı oluştur
      final success = await register(testUsername, 'test@example.com', 'password');
      if (success) {
        return login(testUsername, 'password');
      }
      
      return null;
    } catch (e) {
      debugPrint('Error creating test user: $e');
      return null;
    }
  }
}