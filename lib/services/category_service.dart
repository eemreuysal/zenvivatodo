import 'package:flutter/foundation.dart' hide Category;
import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import 'database_helper.dart';

class CategoryService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<bool> addCategory(Category category) async {
    try {
      final int categoryId = await _databaseHelper.insertCategory(category);
      return categoryId > 0;
    } on DatabaseException catch (e) {
      debugPrint('Veritabanı hatası - kategori eklerken: $e');
      return false;
    } on Exception catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    }
  }

  Future<List<Category>> getCategories(int userId) async {
    try {
      return await _databaseHelper.getCategories(userId);
    } on DatabaseException catch (e) {
      debugPrint('Veritabanı hatası - kategori listesi alınırken: $e');
      return [];
    } on Exception catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      final int result = await _databaseHelper.updateCategory(category);
      return result > 0;
    } on DatabaseException catch (e) {
      debugPrint('Veritabanı hatası - kategori güncellenirken: $e');
      return false;
    } on Exception catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      final int result = await _databaseHelper.deleteCategory(categoryId);
      return result > 0;
    } on DatabaseException catch (e) {
      debugPrint('Veritabanı hatası - kategori silinirken: $e');
      return false;
    } on Exception catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }
}
