import 'dart:async';
import 'dart:convert';
// İmport sıralaması düzeltildi - directives_ordering
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Kullanılmayan import kaldırıldı: '../models/habit.dart'
import '../models/task.dart';
import 'api_service.dart';
import 'connectivity_service.dart';
import 'database_helper.dart';

/// Çevrimiçi ve çevrimdışı veri senkronizasyonu yapan servis
///
/// Bu servis, kullanıcının çevrimdışı durumda yaptığı değişiklikleri
/// takip eder ve internet bağlantısı tekrar kurulduğunda
/// bu değişiklikleri sunucuyla senkronize eder.
class SyncService {
  // Constructor'ı sınıfın başına taşıdık - sort_constructors_first
  // Singleton pattern
  factory SyncService() => _instance;
  
  SyncService._internal() {
    // İnternet bağlantısı değişikliklerini dinle
    _connectivityService.connectionStream.listen(_handleConnectivityChange);
    
    // Bekleyen işlemleri yükle
    _loadPendingOperations();
  }
  
  static final SyncService _instance = SyncService._internal();
  
  // Logger tanımla
  final _logger = Logger('SyncService');
  
  // Servisler
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  // Senkronizasyon zamanı için timer
  Timer? _syncTimer;
  
  // Lokal işlemlerin kuyruğu
  List<Map<String, dynamic>> _pendingOperations = [];
  
  // Kullanıcı ID
  int? _userId;
  
  // Servisi başlat
  Future<void> initialize(int userId) async {
    _userId = userId;
    await _loadPendingOperations();
    startPeriodicSync();
  }
  
  // Periyodik senkronizasyonu başlat
  void startPeriodicSync() {
    // Her 15 dakikada bir senkronize et
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (_connectivityService.hasConnection && _userId != null) {
        syncAll(_userId!);
      }
    });
  }
  
  // Periyodik senkronizasyonu durdur
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
  
  // Bağlantı değişikliklerini dinle - ConnectivityResult parametre tipini belirtiyoruz
  void _handleConnectivityChange(ConnectivityResult result) {
    if (_connectivityService.hasConnection && _userId != null) {
      _logger.info('İnternet bağlantısı kuruldu, senkronizasyon başlatılıyor...');
      syncAll(_userId!);
    }
  }
  
  // Bekleyen işlemleri yükle
  Future<void> _loadPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingJson = prefs.getString('pending_operations');
    
    if (pendingJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(pendingJson);
        _pendingOperations = decoded.cast<Map<String, dynamic>>();
      } on FormatException catch (e) {
        _logger.warning('Bekleyen işlemler yüklenirken format hatası: $e');
        _pendingOperations = [];
      } on Exception catch (e) {
        _logger.severe('Bekleyen işlemler yüklenirken beklenmeyen hata: $e');
        _pendingOperations = [];
      }
    } else {
      _pendingOperations = [];
    }
    
    _logger.info('${_pendingOperations.length} adet bekleyen işlem yüklendi');
  }
  
  // Bekleyen işlemleri kaydet
  Future<void> _savePendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_operations', jsonEncode(_pendingOperations));
  }
  
  // İşlem ekle
  Future<void> addOperation(String type, String action, Map<String, dynamic> data) async {
    _pendingOperations.add({
      'id': const Uuid().v4(),
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,        // 'task', 'habit', etc.
      'action': action,    // 'create', 'update', 'delete', etc.
      'data': data,
    });
    
    await _savePendingOperations();
    
    // Bağlantı varsa hemen senkronizasyon dene
    if (_connectivityService.hasConnection && _userId != null) {
      syncAll(_userId!);
    }
  }
  
  // Tüm veriyi senkronize et
  Future<void> syncAll(int userId) async {
    if (!_connectivityService.hasConnection) {
      _logger.info('İnternet bağlantısı yok, senkronizasyon iptal edildi');
      return;
    }
    
    try {
      _logger.info('Senkronizasyon başlatılıyor...');
      
      // Önce bekleyen işlemleri işle
      await _processPendingOperations();
      
      // Görevleri senkronize et
      await _syncTasks(userId);
      
      // Alışkanlıkları senkronize et
      await _syncHabits(userId);
      
      // Son senkronizasyon zamanını kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_time', DateTime.now().toIso8601String());
      
      _logger.info('Senkronizasyon tamamlandı');
    } on TimeoutException catch (e) {
      _logger.warning('Senkronizasyon zaman aşımı: $e');
    } on Exception catch (e) {
      _logger.severe('Senkronizasyon hatası: $e');
    }
  }
  
  // Bekleyen işlemleri işle
  Future<void> _processPendingOperations() async {
    if (_pendingOperations.isEmpty) {
      return;
    }
    
    _logger.info('${_pendingOperations.length} adet bekleyen işlem işleniyor...');
    
    // İşlenecek işlemlerin kopyasını al (işlem sırasında liste değişebilir)
    final operations = List<Map<String, dynamic>>.from(_pendingOperations);
    
    for (final operation in operations) {
      try {
        final type = operation['type'] as String;
        final action = operation['action'] as String;
        final data = operation['data'] as Map<String, dynamic>;
        
        bool success = false;
        
        // İşlem tipine göre uygun metodu çağır
        switch (type) {
          case 'task':
            success = await _processTaskOperation(action, data);
            break;
          case 'habit':
            success = await _processHabitOperation(action, data);
            break;
          default:
            _logger.warning('Bilinmeyen işlem tipi: $type');
            break;
        }
        
        // Başarılı olan işlemi listeden kaldır
        if (success) {
          _pendingOperations.removeWhere((op) => op['id'] == operation['id']);
        }
      } on FormatException catch (e) {
        _logger.warning('İşlem verisi format hatası: $e');
      } on Exception catch (e) {
        _logger.warning('İşlem işlenirken hata: $e');
      }
    }
    
    // Güncellenmiş listeyi kaydet
    await _savePendingOperations();
  }
  
  // Görev işlemlerini işle
  Future<bool> _processTaskOperation(String action, Map<String, dynamic> data) async {
    try {
      switch (action) {
        case 'create':
          final task = Task.fromMap(data);
          final createdTask = await _apiService.createTask(task);
          return createdTask != null;
          
        case 'update':
          final task = Task.fromMap(data);
          final updatedTask = await _apiService.updateTask(task);
          return updatedTask != null;
          
        case 'delete':
          final taskId = data['id'] as int;
          return await _apiService.deleteTask(taskId);
          
        case 'toggle_completion':
          final taskId = data['id'] as int;
          final isCompleted = data['isCompleted'] as bool;
          return await _apiService.toggleTaskCompletion(taskId, isCompleted);
          
        default:
          _logger.warning('Bilinmeyen görev işlemi: $action');
          return false;
      }
    } on ArgumentError catch (e) {
      // ArgumentError'u özel olarak yakalamak için on clause kullandık
      _logger.warning('Görev işlemi işlenirken hata: $e');
      return false;
    } on Exception catch (e) {
      _logger.warning('Görev işlemi beklenmeyen hata: $e');
      return false;
    }
  }
  
  // Alışkanlık işlemlerini işle
  Future<bool> _processHabitOperation(String action, Map<String, dynamic> data) async {
    // Burada alışkanlık işlemleri işlenecek
    // TODO: Alışkanlık işlemlerini ekle
    return false;
  }
  
  // Görevleri senkronize et
  Future<void> _syncTasks(int userId) async {
    try {
      // Çevrimiçi görevleri getir
      final onlineTasks = await _apiService.getTasks(userId);
      
      // Yerel görevleri getir
      final localTasks = await _dbHelper.getTasks(userId);
      
      // Her iki yönde veri birleştirme ve çakışma çözümlemesi..
      // Burada basit bir örnek, daha karmaşık bir mantık gerekebilir
      
      // 1. Çevrimiçi görevleri lokale kaydet (uniqueId'ye göre eşleştir)
      for (final onlineTask in onlineTasks) {
        // Yerel eşleşme bul
        final localMatch = localTasks.firstWhere(
          (local) => local.uniqueId == onlineTask.uniqueId,
          orElse: () => onlineTask,
        );
        
        // Yerel kayıt yoksa veya çevrimiçi daha yeniyse, lokale kaydet
        // NOT: Burada gerçek bir tarih karşılaştırması yapılmalı
        if (localMatch.id == null) {
          await _dbHelper.insertTask(onlineTask);
        } 
        // Var olan kaydı güncelle
        else {
          await _dbHelper.updateTask(onlineTask);
        }
      }
      
      // 2. Çevrimiçi'de olmayan ancak lokalde olan görevleri sunucuya gönder
      for (final localTask in localTasks) {
        // uniqueId yoksa, yerel kayıt henüz sunucuya gönderilmemiş
        if (localTask.uniqueId == null) {
          // Yeni bir uniqueId ile görev oluştur
          final taskWithId = localTask.copyWith(
            uniqueId: const Uuid().v4(),
          );
          
          // Sunucuya gönder
          final createdTask = await _apiService.createTask(taskWithId);
          
          // Başarılı olduysa yerel kaydı güncelle
          if (createdTask != null) {
            await _dbHelper.updateTask(createdTask);
          }
          // Başarısız olduysa, bekleyen işlemlere ekle
          else {
            await addOperation('task', 'create', taskWithId.toMap());
          }
        }
        // uniqueId var, ancak çevrimiçi görevler arasında bu ID yok
        else if (!onlineTasks.any((online) => online.uniqueId == localTask.uniqueId)) {
          // Sunucuya gönder
          final createdTask = await _apiService.createTask(localTask);
          
          // Başarısız olduysa, bekleyen işlemlere ekle
          if (createdTask == null) {
            await addOperation('task', 'create', localTask.toMap());
          }
        }
      }
      
    } on TimeoutException catch (e) {
      _logger.warning('Görev senkronizasyonu zaman aşımı: $e');
    } on Exception catch (e) {
      _logger.severe('Görev senkronizasyonu hatası: $e');
    }
  }
  
  // Alışkanlıkları senkronize et
  Future<void> _syncHabits(int userId) async {
    // Benzer şekilde alışkanlıkları senkronize et
    // TODO: Alışkanlık senkronizasyonunu ekle
  }
  
  // Senkronizasyon zamanını al
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString('last_sync_time');
    
    if (lastSyncString != null) {
      try {
        return DateTime.parse(lastSyncString);
      } on FormatException catch (e) {
        _logger.warning('Son senkronizasyon zamanı ayrıştırma hatası: $e');
      }
    }
    
    return null;
  }
  
  // Servisi kapat
  void dispose() {
    stopPeriodicSync();
  }
}