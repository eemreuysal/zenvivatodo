import 'dart:async';
import 'dart:io';

// Flutter paketleri
import 'package:flutter/foundation.dart' hide Category;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Proje içi importlar
import '../models/category.dart';
import '../models/task.dart';
import '../models/user.dart';

// Singleton pattern kullanılarak veritabanı işlemlerini yönetir
class DatabaseHelper {
  // Constructor en üste alındı
  DatabaseHelper._internal();
  
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  // Veritabanı sürümü - şema değişikliklerinde artırılmalı
  static const int _databaseVersion = 4;

  // Veritabanı bağlantısını al veya oluştur
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Veritabanını başlat
  Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'zenviva.db');
    
    return await openDatabase(
      path,
      version: _databaseVersion, 
      onCreate: _onCreate, 
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }
  
  // Veritabanı yapılandırması - foreign key desteğini etkinleştirme
  Future<void> _onConfigure(Database db) async {
    // Foreign key kısıtlamalarını etkinleştir
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Veritabanı oluşturma
  Future<void> _onCreate(Database db, int version) async {
    // Kullanıcılar tablosu
    await db.execute('''\
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        last_login TEXT
      )
    ''');

    // Kategoriler tablosu
    await db.execute('''\
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        userId INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Görevler tablosu
    await db.execute('''\
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        time TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        categoryId INTEGER,
        priority INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        uniqueId TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(categoryId) REFERENCES categories(id) ON DELETE SET NULL,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Alışkanlıklar tablosu
    await db.execute('''\
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
        showInDashboard INTEGER NOT NULL DEFAULT 0,
        userId INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Alışkanlık kayıtları tablosu
    await db.execute('''\
      CREATE TABLE habit_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(habitId) REFERENCES habits(id) ON DELETE CASCADE
      )
    ''');

    // Görev etiketleri tablosu (yeni) - birden fazla etiket ekleyebilmek için
    await db.execute('''\
      CREATE TABLE task_tags(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL DEFAULT 0xFF9E9E9E,
        userId INTEGER NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Görev-etiket ilişki tablosu (yeni)
    await db.execute('''\
      CREATE TABLE task_tag_relations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        tagId INTEGER NOT NULL,
        FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE,
        FOREIGN KEY(tagId) REFERENCES task_tags(id) ON DELETE CASCADE
      )
    ''');

    // Varsayılan kategorileri ekle
    await db.insert(
      'categories',
      const Category(name: 'İş', color: 0xFF1565C0, userId: null).toMap(),
    );
    await db.insert(
      'categories',
      const Category(
        name: 'Kişisel Gelişim',
        color: 0xFF673AB7,
        userId: null,
      ).toMap(),
    );
    await db.insert(
      'categories',
      const Category(name: 'Sağlık', color: 0xFF4CAF50, userId: null).toMap(),
    );
  }

  // Veritabanı güncelleme - sürüm değiştikçe çalışır
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Her sürüm değişikliği için kontrol
    if (oldVersion < 2) {
      // Alışkanlıklar tablosu
      await db.execute('''\
        CREATE TABLE IF NOT EXISTS habits(
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
          FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');

      // Alışkanlık kayıtları tablosu
      await db.execute('''\
        CREATE TABLE IF NOT EXISTS habit_logs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habitId INTEGER NOT NULL,
          date TEXT NOT NULL,
          completed INTEGER NOT NULL DEFAULT 0,
          notes TEXT,
          FOREIGN KEY(habitId) REFERENCES habits(id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 3) {
      // Dashboard gösterme kolonu ekle
      await db.execute(
          'ALTER TABLE habits ADD COLUMN showInDashboard INTEGER NOT NULL DEFAULT 0');
    }
    
    if (oldVersion < 4) {
      // Yeni sütunlar ekle
      
      // users tablosuna son giriş tarihi
      try {
        await db.execute('ALTER TABLE users ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP');
        await db.execute('ALTER TABLE users ADD COLUMN last_login TEXT');
      } on DatabaseException catch (e) {
        debugPrint('Users tablosu güncellenemedi: $e');
      }
      
      // tasks tablosuna oluşturma ve güncelleme tarihi ekle
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN uniqueId TEXT');
        await db.execute('ALTER TABLE tasks ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP');
        await db.execute('ALTER TABLE tasks ADD COLUMN updated_at TEXT DEFAULT CURRENT_TIMESTAMP');
      } on DatabaseException catch (e) {
        debugPrint('Tasks tablosu güncellenemedi: $e');
      }
      
      // habits tablosuna oluşturma ve güncelleme tarihi ekle
      try {
        await db.execute('ALTER TABLE habits ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP');
        await db.execute('ALTER TABLE habits ADD COLUMN updated_at TEXT DEFAULT CURRENT_TIMESTAMP');
      } on DatabaseException catch (e) {
        debugPrint('Habits tablosu güncellenemedi: $e');
      }
      
      // categories tablosuna oluşturma tarihi ekle
      try {
        await db.execute('ALTER TABLE categories ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP');
      } on DatabaseException catch (e) {
        debugPrint('Categories tablosu güncellenemedi: $e');
      }
      
      // habit_logs tablosuna oluşturma tarihi ekle
      try {
        await db.execute('ALTER TABLE habit_logs ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP');
      } on DatabaseException catch (e) {
        debugPrint('Habit_logs tablosu güncellenemedi: $e');
      }
      
      // Görev etiketleri tablosu (yeni)
      try {
        await db.execute('''\
          CREATE TABLE IF NOT EXISTS task_tags(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            color INTEGER NOT NULL DEFAULT 0xFF9E9E9E,
            userId INTEGER NOT NULL,
            FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');

        // Görev-etiket ilişki tablosu (yeni)
        await db.execute('''\
          CREATE TABLE IF NOT EXISTS task_tag_relations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            taskId INTEGER NOT NULL,
            tagId INTEGER NOT NULL,
            FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE,
            FOREIGN KEY(tagId) REFERENCES task_tags(id) ON DELETE CASCADE
          )
        ''');
      } on DatabaseException catch (e) {
        debugPrint('Etiket tabloları oluşturulamadı: $e');
      }
    }
  }

  // Kullanıcı metodları
  Future<int> insertUser(User user) async {
    final Database db = await database;
    // Giriş zamanını güncelle
    final userMap = user.toMap();
    userMap['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('users', userMap);
  }

  Future<User?> getUser(String username, String password) async {
    final Database db = await database;
    
    // Kullanıcıyı kontrol et
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      // Son giriş zamanını güncelle
      await db.update(
        'users',
        {'last_login': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
      
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
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
    final Database db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final Database db = await database;
    
    // Cascade ile ilişkili tüm kayıtlar otomatik silinecek
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Kategori metodları
  Future<int> insertCategory(Category category) async {
    final Database db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories(int userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'userId IS NULL OR userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<int> updateCategory(Category category) async {
    final Database db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final Database db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Görev metodları
  Future<int> insertTask(Task task) async {
    final Database db = await database;
    final taskMap = task.toMap();
    
    // Oluşturma ve güncelleme tarihlerini ayarla
    final now = DateTime.now().toIso8601String();
    taskMap['created_at'] = now;
    taskMap['updated_at'] = now;
    
    return await db.insert('tasks', taskMap);
  }

  Future<List<Task>> getTasks(
    int userId, {
    String? date,
    bool? isCompleted,
    int? categoryId,
    int? priority,
  }) async {
    final Database db = await database;
    
    final queryBuilder = StringBuffer('SELECT * FROM tasks WHERE userId = ?');
    final whereArgs = <dynamic>[userId];

    if (date != null) {
      queryBuilder.write(' AND date = ?');
      whereArgs.add(date);
    }

    if (isCompleted != null) {
      queryBuilder.write(' AND isCompleted = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }

    if (categoryId != null) {
      queryBuilder.write(' AND categoryId = ?');
      whereArgs.add(categoryId);
    }

    if (priority != null) {
      queryBuilder.write(' AND priority = ?');
      whereArgs.add(priority);
    }
    
    // Varsayılan sıralama - varsayılan olarak tarihe göre
    queryBuilder.write(' ORDER BY date ASC, time ASC');

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      queryBuilder.toString(),
      whereArgs,
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Görev arama fonksiyonu - yeni
  Future<List<Task>> searchTasks(
    int userId, 
    String query, 
    {bool includeCompleted = false}
  ) async {
    final Database db = await database;
    
    final queryBuilder = StringBuffer('''\
      SELECT * FROM tasks 
      WHERE userId = ? AND
      (title LIKE ? OR description LIKE ?)
    ''');
    final whereArgs = <dynamic>[
      userId, 
      '%$query%', 
      '%$query%',
    ];

    if (!includeCompleted) {
      queryBuilder.write(' AND isCompleted = 0');
    }
    
    queryBuilder.write(' ORDER BY date ASC, time ASC');

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      queryBuilder.toString(),
      whereArgs,
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<int> updateTask(Task task) async {
    final Database db = await database;
    final taskMap = task.toMap();
    
    // Güncelleme tarihini ayarla
    taskMap['updated_at'] = DateTime.now().toIso8601String();
    
    return await db.update(
      'tasks',
      taskMap,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    final Database db = await database;
    return await db.update(
      'tasks',
      {
        'isCompleted': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final Database db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Etiket metodları (yeni)
  Future<int> insertTag(Map<String, dynamic> tag) async {
    final Database db = await database;
    return await db.insert('task_tags', tag);
  }
  
  Future<List<Map<String, dynamic>>> getTags(int userId) async {
    final Database db = await database;
    return await db.query(
      'task_tags',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
  
  Future<List<Map<String, dynamic>>> getTaskTags(int taskId) async {
    final Database db = await database;
    return await db.rawQuery('''\
      SELECT t.* FROM task_tags t
      INNER JOIN task_tag_relations r ON t.id = r.tagId
      WHERE r.taskId = ?
    ''', [taskId]);
  }
  
  Future<void> assignTagToTask(int taskId, int tagId) async {
    final Database db = await database;
    await db.insert('task_tag_relations', {
      'taskId': taskId,
      'tagId': tagId,
    });
  }
  
  Future<void> removeTagFromTask(int taskId, int tagId) async {
    final Database db = await database;
    await db.delete(
      'task_tag_relations', 
      where: 'taskId = ? AND tagId = ?',
      whereArgs: [taskId, tagId],
    );
  }

  // Alışkanlık metodları kısmını yukarıdaki değişikliklere uygun şekilde güncelliyorum...
  // Veritabanı işlemleri için daha detaylı hata yönetimi eklenmiştir
  
  // Transaction kullanımı örneği - veritabanı işlemlerini atomik olarak yürütür
  Future<bool> batchUpdateTasks(List<Task> tasks) async {
    final Database db = await database;
    try {
      await db.transaction((txn) async {
        for (var task in tasks) {
          final taskMap = task.toMap();
          taskMap['updated_at'] = DateTime.now().toIso8601String();
          
          await txn.update(
            'tasks',
            taskMap,
            where: 'id = ?',
            whereArgs: [task.id],
          );
        }
      });
      return true;
    } on DatabaseException catch (e) {
      debugPrint('Toplu görev güncelleme hatası: $e');
      return false;
    }
  }
  
  // İstatistik metodları (yeni)
  
  // Kategori bazında görev sayıları
  Future<List<Map<String, dynamic>>> getTaskCountByCategory(int userId) async {
    final Database db = await database;
    return await db.rawQuery('''\
      SELECT c.name, c.color, COUNT(t.id) as taskCount, 
             SUM(CASE WHEN t.isCompleted = 1 THEN 1 ELSE 0 END) as completedCount
      FROM tasks t
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE t.userId = ?
      GROUP BY t.categoryId
    ''', [userId]);
  }
  
  // Günlük tamamlanan görev sayısı - son 7 gün
  Future<List<Map<String, dynamic>>> getCompletedTasksLast7Days(int userId) async {
    final Database db = await database;
    
    // Son 7 günün tarihlerini oluştur
    final dates = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: i));
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    });
    
    // Her tarih için tamamlanan görev sayısını sorgula
    final result = <Map<String, dynamic>>[];
    
    await Future.forEach(dates, (date) async {
      final count = Sqflite.firstIntValue(await db.rawQuery('''\
        SELECT COUNT(*) FROM tasks 
        WHERE userId = ? AND date = ? AND isCompleted = 1
      ''', [userId, date])) ?? 0;
      
      result.add({
        'date': date,
        'count': count,
      });
    });
    
    return result;
  }
  
  // Öncelik bazında görev sayıları
  Future<List<Map<String, dynamic>>> getTaskCountByPriority(int userId) async {
    final Database db = await database;
    return await db.rawQuery('''\
      SELECT priority, COUNT(*) as count
      FROM tasks
      WHERE userId = ?
      GROUP BY priority
    ''', [userId]);
  }
  
  // Alışkanlık metodları (güncellendi)
  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final Database db = await database;
    
    // Oluşturma ve güncelleme tarihlerini ayarla
    final now = DateTime.now().toIso8601String();
    habit['created_at'] = now;
    habit['updated_at'] = now;
    
    return await db.insert('habits', habit);
  }

  Future<List<Map<String, dynamic>>> getHabits(int userId,
      {bool includeArchived = false}) async {
    final Database db = await database;
    String whereClause = 'userId = ?';
    final List<dynamic> whereArgs = [userId];

    if (!includeArchived) {
      whereClause += ' AND isArchived = 0';
    }

    return await db.query(
      'habits',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
  }

  // Dashboard için gösterilecek alışkanlıkları getir
  Future<List<Map<String, dynamic>>> getDashboardHabits(int userId,
      {required String date}) async {
    final Database db = await database;
    return await db.query(
      'habits',
      where: 'userId = ? AND isArchived = 0 AND showInDashboard = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getHabitById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
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
    final Database db = await database;
    
    // Güncelleme tarihini ayarla
    habit['updated_at'] = DateTime.now().toIso8601String();
    
    return await db.update(
      'habits',
      habit,
      where: 'id = ?',
      whereArgs: [habit['id']],
    );
  }

  Future<int> deleteHabit(int id) async {
    final Database db = await database;
    // CASCADE ile ilişkili kayıtlar otomatik silinecek
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> archiveHabit(int id, bool isArchived) async {
    final Database db = await database;
    return await db.update(
      'habits',
      {
        'isArchived': isArchived ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleShowInDashboard(int id, bool showInDashboard) async {
    final Database db = await database;
    return await db.update(
      'habits',
      {
        'showInDashboard': showInDashboard ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Habit Logs methods
  Future<int> insertHabitLog(Map<String, dynamic> log) async {
    final Database db = await database;
    
    // Oluşturma tarihini ayarla
    log['created_at'] = DateTime.now().toIso8601String();
    
    return await db.insert('habit_logs', log);
  }

  Future<List<Map<String, dynamic>>> getHabitLogs(int habitId,
      {String? date}) async {
    final Database db = await database;
    String whereClause = 'habitId = ?';
    final List<dynamic> whereArgs = [habitId];

    if (date != null) {
      whereClause += ' AND date = ?';
      whereArgs.add(date);
    }

    return await db.query(
      'habit_logs',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
  }

  Future<int> toggleHabitCompletion(
      int habitId, String date, bool completed) async {
    final Database db = await database;

    // Check if log exists
    final List<Map<String, dynamic>> logs = await db.query(
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
        'created_at': DateTime.now().toIso8601String(),
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
    final Database db = await database;
    return await db.update(
      'habit_logs',
      log,
      where: 'id = ?',
      whereArgs: [log['id']],
    );
  }

  Future<int> deleteHabitLog(int id) async {
    final Database db = await database;
    return await db.delete('habit_logs', where: 'id = ?', whereArgs: [id]);
  }
}
