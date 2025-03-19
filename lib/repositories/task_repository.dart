import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

// Repository interface
abstract class TaskRepository {
  Future<List<Task>> getTasks(int userId);
  Future<Task?> getTask(String id);
  Future<String> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Stream<List<Task>> watchTasks(int userId);
}

// Firestore implementation
class FirestoreTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Koleksiyon referansı
  CollectionReference get _tasks => _firestore.collection('tasks');
  
  @override
  Future<List<Task>> getTasks(int userId) async {
    QuerySnapshot snapshot = await _tasks
        .where('userId', isEqualTo: userId)
        .orderBy('date')
        .orderBy('time')
        .get();
    
    return snapshot.docs
        .map((doc) => Task.fromFirestore(doc))
        .toList();
  }
  
  @override
  Future<Task?> getTask(String id) async {
    DocumentSnapshot doc = await _tasks.doc(id).get();
    
    if (doc.exists) {
      return Task.fromFirestore(doc);
    }
    
    return null;
  }
  
  @override
  Future<String> addTask(Task task) async {
    DocumentReference docRef = await _tasks.add(task.toFirestore());
    return docRef.id;
  }
  
  @override
  Future<void> updateTask(Task task) async {
    if (task.uniqueId == null) {
      throw Exception('Task uniqueId cannot be null for update operation');
    }
    
    await _tasks.doc(task.uniqueId).update({
      ...task.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  @override
  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }
  
  @override
  Stream<List<Task>> watchTasks(int userId) {
    return _tasks
        .where('userId', isEqualTo: userId)
        .orderBy('date')
        .orderBy('time')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }
}

// Hibrit repository (geçiş dönemi için)
class HybridTaskRepository implements TaskRepository {
  final FirestoreTaskRepository _firestoreRepo;
  final SQLiteTaskRepository _sqliteRepo;
  final bool _isOnline;
  
  HybridTaskRepository(this._firestoreRepo, this._sqliteRepo, this._isOnline);
  
  @override
  Future<List<Task>> getTasks(int userId) async {
    if (_isOnline) {
      // Eğer çevrimiçiyse, Firestore'dan al
      final tasks = await _firestoreRepo.getTasks(userId);
      // Yerel veriyi de güncelle
      _syncTasksToLocal(tasks);
      return tasks;
    } else {
      // Çevrimdışıysa, yerel veritabanından al
      return _sqliteRepo.getTasks(userId);
    }
  }

  @override
  Future<Task?> getTask(String id) async {
    if (_isOnline) {
      return _firestoreRepo.getTask(id);
    } else {
      // SQLite'den uniqueId ile görevi al (uniqueId alanı varsa)
      return _sqliteRepo.getTaskByUniqueId(id);
    }
  }

  @override
  Future<String> addTask(Task task) async {
    // Her zaman SQLite'a kaydet
    await _sqliteRepo.addTask(task);
    
    if (_isOnline) {
      // Çevrimiçiyse Firestore'a da kaydet
      return await _firestoreRepo.addTask(task);
    } else {
      // Çevrimdışıysa daha sonra senkronize edilmek üzere beklet
      await _savePendingTask(task, 'add');
      return task.uniqueId ?? '';
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    // Yerel veritabanını güncelle
    await _sqliteRepo.updateTask(task);
    
    if (_isOnline) {
      // Çevrimiçiyse Firestore'u da güncelle
      await _firestoreRepo.updateTask(task);
    } else {
      // Çevrimdışıysa daha sonra senkronize edilmek üzere beklet
      await _savePendingTask(task, 'update');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    // SQLite'deki görevi bul
    final task = await _sqliteRepo.getTaskByUniqueId(id);
    
    if (task != null) {
      // SQLite'den sil
      await _sqliteRepo.deleteTask(task.id!);
    }
    
    if (_isOnline) {
      // Çevrimiçiyse Firestore'dan da sil
      await _firestoreRepo.deleteTask(id);
    } else {
      // Çevrimdışıysa daha sonra senkronize edilmek üzere beklet
      await _savePendingDelete(id);
    }
  }

  @override
  Stream<List<Task>> watchTasks(int userId) {
    if (_isOnline) {
      // Çevrimiçiyse Firestore'dan izle
      return _firestoreRepo.watchTasks(userId);
    } else {
      // Çevrimdışıysa yerel veritabanını izleyecek mekanizma kur
      // Bu örnekte basit bir yöntem kullanıyoruz
      return Stream.fromFuture(_sqliteRepo.getTasks(userId));
    }
  }

  // Yardımcı metotlar
  Future<void> _syncTasksToLocal(List<Task> tasks) async {
    // Firestore'dan gelen görevleri SQLite'a senkronize et
    for (Task task in tasks) {
      if (task.id != null) {
        await _sqliteRepo.updateTask(task);
      } else {
        await _sqliteRepo.addTask(task);
      }
    }
  }

  Future<void> _savePendingTask(Task task, String operation) async {
    // Bekleyen görev değişikliklerini saklama
    // Not: Bu metot bir 'pending_operations' tablosuna kaydetmeli
  }

  Future<void> _savePendingDelete(String id) async {
    // Bekleyen silme işlemlerini saklama
  }
}

// SQLite implementation
class SQLiteTaskRepository implements TaskRepository {
  // SQLite metodlarını burada implemente et
  
  @override
  Future<List<Task>> getTasks(int userId) {
    // Kullanıcının tüm görevlerini SQLite'dan getir
    throw UnimplementedError();
  }
  
  @override
  Future<Task?> getTask(String id) {
    // Belirli bir görevi SQLite'dan getir
    throw UnimplementedError();
  }
  
  Future<Task?> getTaskByUniqueId(String uniqueId) {
    // uniqueId ile görevi SQLite'dan getir
    throw UnimplementedError();
  }
  
  @override
  Future<String> addTask(Task task) {
    // Görevi SQLite'a ekle
    throw UnimplementedError();
  }
  
  @override
  Future<void> updateTask(Task task) {
    // Görevi SQLite'da güncelle
    throw UnimplementedError();
  }
  
  @override
  Future<void> deleteTask(int id) {
    // Görevi SQLite'dan sil
    throw UnimplementedError();
  }
  
  @override
  Future<void> deleteTask(String id) {
    // Uyum için eklendi
    throw UnimplementedError();
  }
  
  @override
  Stream<List<Task>> watchTasks(int userId) {
    // SQLite'da dinleme kavramı yoktur, bu yüzden bir workaround olarak bir Stream döndürüyoruz
    throw UnimplementedError();
  }
}

// Factory to create the right repository
class TaskRepositoryFactory {
  static TaskRepository create({required bool isOnline, required bool useFirestore}) {
    if (!useFirestore) {
      // SQLite'ı tercih ediyorsa sadece SQLite kullan
      return SQLiteTaskRepository();
    }
    
    if (useFirestore) {
      if (isOnline) {
        // Çevrimiçiyse ve Firestore seçildiyse direkt Firestore repository'si döndür
        return FirestoreTaskRepository();
      } else {
        // Çevrimdışıysa ama Firestore seçildiyse, hibrit repository döndür
        return HybridTaskRepository(
          FirestoreTaskRepository(), 
          SQLiteTaskRepository(),
          isOnline
        );
      }
    }
    
    // Varsayılan olarak hibrit dön
    return HybridTaskRepository(
      FirestoreTaskRepository(), 
      SQLiteTaskRepository(),
      isOnline
    );
  }
}
