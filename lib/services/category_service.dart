import '../models/category.dart';
import 'database_helper.dart';
import 'package:flutter/foundation.dart' hide Category;

class CategoryService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<bool> addCategory(Category category) async {
    try {
      int categoryId = await _databaseHelper.insertCategory(category);
      return categoryId > 0;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    }
  }

  Future<List<Category>> getCategories(int userId) async {
    try {
      return await _databaseHelper.getCategories(userId);
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      int result = await _databaseHelper.updateCategory(category);
      return result > 0;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      int result = await _databaseHelper.deleteCategory(categoryId);
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }
}
