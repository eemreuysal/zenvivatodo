// Dart paketi importları
import 'dart:async';
import 'dart:io';

// Flutter paketi importları
import 'package:flutter/foundation.dart' hide Category;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Proje içi importlar - en son olmalı
import '../models/category.dart' as models;
import '../models/task.dart';
import '../models/user.dart';

/// Veritabanı işlemlerini yöneten yardımcı sınıf
/// Singleton pattern kullanılarak veritabanı işlemlerini yönetir
class DatabaseHelper {
  factory DatabaseHelper() => _instance;
  // Constructor'lar sınıfın en üstünde
  DatabaseHelper._internal();  
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Sınıf değişkenleri
  static Database? _database;
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
    await db.execute('''
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
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        userId INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Görevler tablosu - indeksler eklendi
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
        userId INTEGER NOT NULL,
        uniqueId TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(categoryId) REFERENCES categories(id) ON DELETE SET NULL,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    
    // Performans iyileştirmesi: sık kullanılan alanlara index ekle
    await db.execute('CREATE INDEX idx_tasks_userId ON tasks(userId)');
    await db.execute('CREATE INDEX idx_tasks_date ON tasks(date)');
    await db.execute('CREATE INDEX idx_tasks_isCompleted ON tasks(isCompleted)');

    // Alışkanlıklar tablosu - indeksler eklendi
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
        showInDashboard INTEGER NOT NULL DEFAULT 0,
        userId INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    
    // Performans iyileştirmesi: sık kullanılan alanlara index ekle
    await db.execute('CREATE INDEX idx_habits_userId ON habits(userId)');
    await db.execute('CREATE INDEX idx_habits_isArchived ON habits(isArchived)');

    // Alışkanlık kayıtları tablosu - indeksler eklendi
    await db.execute('''
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
    
    // Performans iyileştirmesi: sık kullanılan alanlara index ekle
    await db.execute('CREATE INDEX idx_habit_logs_habitId ON habit_logs(habitId)');
    await db.execute('CREATE INDEX idx_habit_logs_date ON habit_logs(date)');

    // Görev etiketleri tablosu (yeni)
    await db.execute('''
      CREATE TABLE task_tags(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL DEFAULT 0xFF9E9E9E,
        userId INTEGER NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    
    // Performans iyileştirmesi: etiketler için index
    await db.execute('CREATE INDEX idx_task_tags_userId ON task_tags(userId)');

    // Görev-etiket ilişki tablosu (yeni)
    await db.execute('''
      CREATE TABLE task_tag_relations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        tagId INTEGER NOT NULL,
        FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE,
        FOREIGN KEY(tagId) REFERENCES task_tags(id) ON DELETE CASCADE
      )
    ''');
    
    // Etiket ilişkileri için index
    await db.execute('CREATE INDEX idx_task_tag_relations_taskId ON task_tag_relations(taskId)');
    await db.execute('CREATE INDEX idx_task_tag_relations_tagId ON task_tag_relations(tagId)');

    // Varsayılan kategorileri ekle
    await db.insert(
      'categories',
      const models.Category(name: 'İş', color: 0xFF1565C0).toMap(),
    );
    await db.insert(
      'categories',
      const models.Category(
        name: 'Kişisel Gelişim',
        color: 0xFF673AB7,
      ).toMap(),
    );
    await db.insert(
      'categories',
      const models.Category(name: 'Sağlık', color: 0xFF4CAF50).toMap(),
    );
  }

  // Veritabanı güncelleme - sürüm değiştikçe çalışır
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Her sürüm değişikliği için kontrol
    if (oldVersion < 2) {
      // Alışkanlıklar tablosu
      await db.execute('''
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
      await db.execute('''
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
          'ALTER TABLE habits ADD COLUMN showInDashboard INTEGER NOT NULL DEFAULT 0',);
    }
    
    if (oldVersion < 4) {
      // Yeni sütunlar ekleme işlemleri
      await _executeAlterTableSafely(db, 
        'ALTER TABLE users ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP',
      );
      await _executeAlterTableSafely(db, 
        'ALTER TABLE users ADD COLUMN last_login TEXT',
      );
      
      await _executeAlterTableSafely(db, 
        'ALTER TABLE tasks ADD COLUMN uniqueId TEXT',
      );
      await _executeAlterTableSafely(db, 
        'ALTER TABLE tasks ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP',
      );
      await _executeAlterTableSafely(db, 
        'ALTER TABLE tasks ADD COLUMN updated_at TEXT DEFAULT CURRENT_TIMESTAMP',
      );
      
      await _executeAlterTableSafely(db, 
        'ALTER TABLE habits ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP',
      );
      await _executeAlterTableSafely(db, 
        'ALTER TABLE habits ADD COLUMN updated_at TEXT DEFAULT CURRENT_TIMESTAMP',
      );
      
      await _executeAlterTableSafely(db, 
        'ALTER TABLE categories ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP',
      );
      
      await _executeAlterTableSafely(db, 
        'ALTER TABLE habit_logs ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP',
      );
      
      // Görev etiketleri tablosu (yeni)
      await _createTableIfNotExists(db, 'task_tags', '''
        CREATE TABLE task_tags(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          color INTEGER NOT NULL DEFAULT 0xFF9E9E9E,
          userId INTEGER NOT NULL,
          FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');

      // Görev-etiket ilişki tablosu (yeni)
      await _createTableIfNotExists(db, 'task_tag_relations', '''
        CREATE TABLE task_tag_relations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          taskId INTEGER NOT NULL,
          tagId INTEGER NOT NULL,
          FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE,
          FOREIGN KEY(tagId) REFERENCES task_tags(id) ON DELETE CASCADE
        )
      ''');
      
      // Sürüm 4'te yapılan indeks eklemeleri
      await _createIndexIfNotExists(db, 'idx_tasks_userId', 'tasks', 'userId');
      await _createIndexIfNotExists(db, 'idx_tasks_date', 'tasks', 'date');
      await _createIndexIfNotExists(db, 'idx_tasks_isCompleted', 'tasks', 'isCompleted');
      await _createIndexIfNotExists(db, 'idx_habits_userId', 'habits', 'userId');
      await _createIndexIfNotExists(db, 'idx_habits_isArchived', 'habits', 'isArchived');
      await _createIndexIfNotExists(db, 'idx_habit_logs_habitId', 'habit_logs', 'habitId');
      await _createIndexIfNotExists(db, 'idx_habit_logs_date', 'habit_logs', 'date');
      await _createIndexIfNotExists(db, 'idx_task_tags_userId', 'task_tags', 'userId');
      await _createIndexIfNotExists(db, 'idx_task_tag_relations_taskId', 'task_tag_relations', 'taskId');
      await _createIndexIfNotExists(db, 'idx_task_tag_relations_tagId', 'task_tag_relations', 'tagId');
    }
  }
  
  // Güvenli şekilde ALTER TABLE çalıştır (hata olursa devam et)
  Future<void> _executeAlterTableSafely(Database db, String sql) async {
    try {
      await db.execute(sql);
    } on DatabaseException catch (e) {
      debugPrint('Tablo değişikliği hatası: $e');
    }
  }
  
  // Tablo yoksa oluştur
  Future<void> _createTableIfNotExists(Database db, String tableName, String sql) async {
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?", 
        [tableName],
      );
      
      if (tables.isEmpty) {
        await db.execute(sql);
      }
    } on DatabaseException catch (e) {
      debugPrint('Tablo oluşturma hatası: $e');
    }
  }
  
  // İndeks yoksa oluştur
  Future<void> _createIndexIfNotExists(Database db, String indexName, String tableName, String column) async {
    try {
      final indices = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name=?", 
        [indexName],
      );
      
      if (indices.isEmpty) {
        await db.execute('CREATE INDEX $indexName ON $tableName($column)');
      }
    } on DatabaseException catch (e) {
      debugPrint('İndeks oluşturma hatası: $e');
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
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      // Şifreyi doğrula (User sınıfında şifre doğrulama yapılacak)
      final user = User.fromMap(maps.first);
      
      if (user.verifyPassword(password)) {
        // Son giriş zamanını güncelle
        await db.update(
          'users',
          {'last_login': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [user.id],
        );
        
        return user;
      }
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
  Future<int> insertCategory(models.Category category) async {
    final Database db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<models.Category>> getCategories(int userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'userId IS NULL OR userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return models.Category.fromMap(maps[i]);
    });
  }

  Future<int> updateCategory(models.Category category) async {
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
    
    final List<String> whereConditions = ['userId = ?'];
    final List<dynamic> whereArgs = [userId];
    
    if (date != null) {
      whereConditions.add('date = ?');
      whereArgs.add(date);
    }

    if (isCompleted != null) {
      whereConditions.add('isCompleted = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }

    if (categoryId != null) {
      whereConditions.add('categoryId = ?');
      whereArgs.add(categoryId);
    }

    if (priority != null) {
      whereConditions.add('priority = ?');
      whereArgs.add(priority);
    }
    
    final String whereClause = whereConditions.join(' AND ');
    
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date ASC, time ASC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Görev arama fonksiyonu - SQL enjeksiyon riskine karşı iyileştirildi
  Future<List<Task>> searchTasks(
    int userId, 
    String query, 
    {bool includeCompleted = false,}) async {
    final Database db = await database;
    
    // SQL enjeksiyon riskini azaltmak için parametre kullanımı
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? AND (title LIKE ? OR description LIKE ?) AND isCompleted = ?',
      whereArgs: [
        userId, 
        '%$query%', 
        '%$query%',
        (includeCompleted ? 1 : 0),
      ],
      orderBy: 'date ASC, time ASC',
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
    return await db.query(
      'task_tags',
      where: 'id IN (SELECT tagId FROM task_tag_relations WHERE taskId = ?)',
      whereArgs: [taskId],
    );
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
  
  // İstatistik metodları
  
  // Kategori bazında görev sayıları
  Future<List<Map<String, dynamic>>> getTaskCountByCategory(int userId) async {
    final Database db = await database;
    return await db.rawQuery('''
      SELECT c.name, c.color, COUNT(t.id) as taskCount, 
             SUM(CASE WHEN t.isCompleted = 1 THEN 1 ELSE 0 END) as completedCount
      FROM tasks t
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE t.userId = ?
      GROUP BY t.categoryId
    ''', [userId],);
  }
  
  // Günlük tamamlanan görev sayısı - son 7 gün - performans iyileştirmesi
  Future<List<Map<String, dynamic>>> getCompletedTasksLast7Days(int userId) async {
    final Database db = await database;
    
    // Son 7 günün tarihlerini oluştur
    final dates = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: i));
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    });
    
    // Tek bir sorgu ile tamamlanan görev sayılarını al (performans iyileştirmesi)
    final query = '''
      SELECT date, COUNT(*) as count 
      FROM tasks 
      WHERE userId = ? AND date IN (${List.filled(dates.length, '?').join(',')}) AND isCompleted = 1
      GROUP BY date
    ''';
    
    final List<dynamic> args = [userId, ...dates];
    final List<Map<String, dynamic>> results = await db.rawQuery(query, args);
    
    // Tüm günler için sonuçları oluştur, eksik günler 0 sayacak
    final mappedResults = <Map<String, dynamic>>[];
    for (final date in dates) {
      final found = results.firstWhere(
        (r) => r['date'] == date, 
        orElse: () => {'date': date, 'count': 0},
      );
      mappedResults.add(found);
    }
    
    return mappedResults;
  }
  
  // Öncelik bazında görev sayıları
  Future<List<Map<String, dynamic>>> getTaskCountByPriority(int userId) async {
    final Database db = await database;
    return await db.rawQuery('''
      SELECT priority, COUNT(*) as count
      FROM tasks
      WHERE userId = ?
      GROUP BY priority
    ''', [userId],);
  }
  
  // Alışkanlık metodları
  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final Database db = await database;
    
    // Oluşturma ve güncelleme tarihlerini ayarla
    final now = DateTime.now().toIso8601String();
    habit['created_at'] = now;
    habit['updated_at'] = now;
    
    return await db.insert('habits', habit);
  }

  Future<List<Map<String, dynamic>>> getHabits(
    int userId, {
    bool includeArchived = false,
  }) async {
    final Database db = await database;
    return await db.query(
      'habits',
      where: 'userId = ? AND isArchived = ?',
      whereArgs: [userId, includeArchived ? 1 : 0],
      orderBy: 'created_at DESC',
    );
  }

  // Dashboard için gösterilecek alışkanlıkları getir
  Future<List<Map<String, dynamic>>> getDashboardHabits(
    int userId, {
    required String date,
  }) async {
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

  // Habit Logs methods - SQL enjeksiyon önlemi
  Future<int> insertHabitLog(Map<String, dynamic> log) async {
    final Database db = await database;
    
    // Oluşturma tarihini ayarla
    log['created_at'] = DateTime.now().toIso8601String();
    
    return await db.insert('habit_logs', log);
  }

  Future<List<Map<String, dynamic>>> getHabitLogs(
    int habitId, {
    String? date,
  }) async {
    final Database db = await database;
    
    if (date != null) {
      return await db.query(
        'habit_logs',
        where: 'habitId = ? AND date = ?',
        whereArgs: [habitId, date],
        orderBy: 'date DESC',
      );
    } else {
      return await db.query(
        'habit_logs',
        where: 'habitId = ?',
        whereArgs: [habitId],
        orderBy: 'date DESC',
      );
    }
  }

  Future<int> toggleHabitCompletion(
    int habitId, 
    String date, 
    bool completed,
  ) async {
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
  
  /// Veritabanının boyutunu megabayt olarak döndürür.
  /// Performans analizi için kullanılabilir.
  Future<double> getDatabaseSize() async {
    try {
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, 'zenviva.db');
      final File dbFile = File(path);
      
      if (await dbFile.exists()) {
        final int bytes = await dbFile.length();
        return bytes / (1024 * 1024); // MB cinsinden
      }
      return 0.0;
    } on FileSystemException catch (e) {
      debugPrint('Dosya sistemi hatası: $e');
      return 0.0;
    } on Exception catch (e) {
      debugPrint('Veritabanı boyutu alınamadı: $e');
      return 0.0;
    }
  }
  
  /// Veritabanını optimize etmek için VACUUM komutunu çalıştırır.
  /// Uzun süren işlemleri, silinen verileri ve geniş transactionları takiben
  /// veritabanı dosyasının boyutunu küçültmek için kullanılabilir.
  Future<bool> optimizeDatabase() async {
    try {
      final Database db = await database;
      await db.execute('VACUUM');
      return true;
    } on DatabaseException catch (e) {
      debugPrint('Veritabanı optimize edilemedi: $e');
      return false;
    }
  }
}