import '../models/category.dart';
import 'database_helper.dart';

class CategoryService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<bool> addCategory(Category category) async {
    try {
      int categoryId = await _databaseHelper.insertCategory(category);
      return categoryId > 0;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  Future<List<Category>> getCategories(int userId) async {
    try {
      return await _databaseHelper.getCategories(userId);
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      int result = await _databaseHelper.updateCategory(category);
      return result > 0;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      int result = await _databaseHelper.deleteCategory(categoryId);
      return result > 0;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }
}
