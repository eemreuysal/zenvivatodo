import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_helper.dart';

class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<bool> register(String username, String email, String password) async {
    try {
      User user = User(username: username, email: email, password: password);

      int userId = await _databaseHelper.insertUser(user);
      if (userId > 0) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      User? user = await _databaseHelper.getUser(username, password);
      if (user != null) {
        await _saveUserSession(user.id!);
        return user;
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
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
      int result = await _databaseHelper.updateUser(user);
      return result > 0;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Future<bool> deleteUserAccount(int userId) async {
    try {
      await logout();
      int result = await _databaseHelper.deleteUser(userId);
      return result > 0;
    } catch (e) {
      print('Error deleting user account: $e');
      return false;
    }
  }
}
