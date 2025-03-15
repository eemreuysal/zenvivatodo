import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'zenviva.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        userId INTEGER,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        time TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        categoryId INTEGER,
        priority INTEGER NOT NULL,
        userId INTEGER,
        FOREIGN KEY(categoryId) REFERENCES categories(id),
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');

    // Habits table
    await db.execute('''
      CREATE TABLE habits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        frequency TEXT NOT NULL,
        frequencyDays TEXT,
        startDate TEXT NOT NULL,
        targetDays INTEGER NOT NULL,
        colorCode INTEGER NOT NULL,
        reminderTime TEXT,
        isArchived INTEGER NOT NULL DEFAULT 0,
        currentStreak INTEGER NOT NULL DEFAULT 0,
        longestStreak INTEGER NOT NULL DEFAULT 0,
        userId INTEGER,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');

    // Habit logs table
    await db.execute('''
      CREATE TABLE habit_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY(habitId) REFERENCES habits(id)
      )
    ''');

    // Insert default categories
    await db.insert(
      'categories',
      Category(name: 'İş', color: 0xFF1565C0, userId: null).toMap(),
    );
    await db.insert(
      'categories',
      Category(
        name: 'Kişisel Gelişim',
        color: 0xFF673AB7,
        userId: null,
      ).toMap(),
    );
    await db.insert(
      'categories',
      Category(name: 'Sağlık', color: 0xFF4CAF50, userId: null).toMap(),
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Habits table
      await db.execute('''
        CREATE TABLE habits(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          frequency TEXT NOT NULL,
          frequencyDays TEXT,
          startDate TEXT NOT NULL,
          targetDays INTEGER NOT NULL,
          colorCode INTEGER NOT NULL,
          reminderTime TEXT,
          isArchived INTEGER NOT NULL DEFAULT 0,
          currentStreak INTEGER NOT NULL DEFAULT 0,
          longestStreak INTEGER NOT NULL DEFAULT 0,
          userId INTEGER,
          FOREIGN KEY(userId) REFERENCES users(id)
        )
      ''');

      // Habit logs table
      await db.execute('''
        CREATE TABLE habit_logs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habitId INTEGER NOT NULL,
          date TEXT NOT NULL,
          completed INTEGER NOT NULL DEFAULT 0,
          notes TEXT,
          FOREIGN KEY(habitId) REFERENCES habits(id)
        )
      ''');
    }
  }

  // User methods
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    Database db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    Database db = await database;

    // First delete all user's tasks
    await db.delete('tasks', where: 'userId = ?', whereArgs: [id]);

    // Then delete user's categories
    await db.delete('categories', where: 'userId = ?', whereArgs: [id]);

    // Delete user's habits and habit logs
    List<Map<String, dynamic>> habits = await db.query(
      'habits',
      columns: ['id'],
      where: 'userId = ?',
      whereArgs: [id],
    );
    
    for (var habit in habits) {
      await db.delete('habit_logs', where: 'habitId = ?', whereArgs: [habit['id']]);
    }
    
    await db.delete('habits', where: 'userId = ?', whereArgs: [id]);

    // Finally delete the user
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Category methods
  Future<int> insertCategory(Category category) async {
    Database db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'userId IS NULL OR userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<int> updateCategory(Category category) async {
    Database db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    Database db = await database;

    // Update tasks with this category to have null category
    await db.update(
      'tasks',
      {'categoryId': null},
      where: 'categoryId = ?',
      whereArgs: [id],
    );

    // Then delete the category
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Task methods
  Future<int> insertTask(Task task) async {
    Database db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks(
    int userId, {
    String? date,
    bool? isCompleted,
    int? categoryId,
    int? priority,
  }) async {
    Database db = await database;
    String whereClause = 'userId = ?';
    List<dynamic> whereArgs = [userId];

    if (date != null) {
      whereClause += ' AND date = ?';
      whereArgs.add(date);
    }

    if (isCompleted != null) {
      whereClause += ' AND isCompleted = ?';
      whereArgs.add(isCompleted ? 1 : 0);
    }

    if (categoryId != null) {
      whereClause += ' AND categoryId = ?';
      whereArgs.add(categoryId);
    }

    if (priority != null) {
      whereClause += ' AND priority = ?';
      whereArgs.add(priority);
    }

    List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<int> updateTask(Task task) async {
    Database db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    Database db = await database;
    return await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Habit methods
  Future<int> insertHabit(Map<String, dynamic> habit) async {
    Database db = await database;
    return await db.insert('habits', habit);
  }

  Future<List<Map<String, dynamic>>> getHabits(int userId, {bool includeArchived = false}) async {
    Database db = await database;
    String whereClause = 'userId = ?';
    List<dynamic> whereArgs = [userId];

    if (!includeArchived) {
      whereClause += ' AND isArchived = 0';
    }

    return await db.query(
      'habits',
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  Future<Map<String, dynamic>?> getHabitById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updateHabit(Map<String, dynamic> habit) async {
    Database db = await database;
    return await db.update(
      'habits',
      habit,
      where: 'id = ?',
      whereArgs: [habit['id']],
    );
  }

  Future<int> deleteHabit(int id) async {
    Database db = await database;
    // First delete all habit logs
    await db.delete('habit_logs', where: 'habitId = ?', whereArgs: [id]);
    // Then delete the habit
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> archiveHabit(int id, bool isArchived) async {
    Database db = await database;
    return await db.update(
      'habits',
      {'isArchived': isArchived ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Habit Logs methods
  Future<int> insertHabitLog(Map<String, dynamic> log) async {
    Database db = await database;
    return await db.insert('habit_logs', log);
  }

  Future<List<Map<String, dynamic>>> getHabitLogs(int habitId, {String? date}) async {
    Database db = await database;
    String whereClause = 'habitId = ?';
    List<dynamic> whereArgs = [habitId];

    if (date != null) {
      whereClause += ' AND date = ?';
      whereArgs.add(date);
    }

    return await db.query(
      'habit_logs',
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  Future<int> toggleHabitCompletion(int habitId, String date, bool completed) async {
    Database db = await database;
    
    // Check if log exists
    List<Map<String, dynamic>> logs = await db.query(
      'habit_logs',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, date],
    );
    
    if (logs.isEmpty) {
      // Insert new log
      return await db.insert('habit_logs', {
        'habitId': habitId,
        'date': date,
        'completed': completed ? 1 : 0,
      });
    } else {
      // Update existing log
      return await db.update(
        'habit_logs',
        {'completed': completed ? 1 : 0},
        where: 'habitId = ? AND date = ?',
        whereArgs: [habitId, date],
      );
    }
  }

  Future<int> updateHabitLog(Map<String, dynamic> log) async {
    Database db = await database;
    return await db.update(
      'habit_logs',
      log,
      where: 'id = ?',
      whereArgs: [log['id']],
    );
  }

  Future<int> deleteHabitLog(int id) async {
    Database db = await database;
    return await db.delete('habit_logs', where: 'id = ?', whereArgs: [id]);
  }
}
