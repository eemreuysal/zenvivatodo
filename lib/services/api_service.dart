import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../models/habit.dart';
import '../models/task.dart';
import '../models/user.dart';

/// API istekleri yönetimi için servis sınıfı
/// 
/// REST API ile iletişim kurmak için [Dio] paketini kullanır.
/// HTTP istekleri için, hata yönetimi, yanıt işleme ve veri dönüşümü sağlar.
class ApiService {
  // Constructor'ları sınıf üyelerinden önce yerleştir
  // Singleton pattern
  factory ApiService() => _instance;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: 'application/json',
      // ResponseType.json varsayılan değer olduğu için kaldırıldı
    ));
    
    // İnterceptor ekleyerek tüm istekleri logla
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      // error parametresi varsayılan değer olduğu için kaldırıldı
    ));
  }
  
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;
  final _logger = Logger('ApiService');
  
  // Base URL - gerçek API entegrasyonu için değiştirilmelidir
  final String baseUrl = 'https://api.zenviva.example.com/api';
  
  // Auth token için setter
  set authToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  // Auth header'ı kaldır
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
  
  // Kullanıcı işlemleri
  
  /// Kullanıcı girişi
  Future<User?> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        // Yanıttan token alınır ve header'a eklenir
        final token = response.data['token'] as String;
        authToken = token;
        
        // Kullanıcı bilgilerini dön
        return User.fromJson(response.data['user']);
      }
      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'login');
      return null;
    } on Exception catch (e) {
      _logger.warning('Login error: $e');
      return null;
    }
  }
  
  /// Kullanıcı kaydı
  Future<User?> register(String username, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 201) {
        // Kayıttan sonra otomatik giriş
        return login(username, password);
      }
      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'register');
      return null;
    } on Exception catch (e) {
      _logger.warning('Register error: $e');
      return null;
    }
  }
  
  // Görev işlemleri
  
  /// Kullanıcının tüm görevlerini getir
  Future<List<Task>> getTasks(int userId) async {
    try {
      final response = await _dio.get('/tasks', queryParameters: {
        'userId': userId,
      });
      
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => Task.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      _handleDioError(e, 'getTasks');
      return [];
    } on Exception catch (e) {
      _logger.warning('Get tasks error: $e');
      return [];
    }
  }
  
  /// Belirli bir tarihe göre görevleri getir
  Future<List<Task>> getTasksByDate(int userId, String date) async {
    try {
      final response = await _dio.get('/tasks', queryParameters: {
        'userId': userId,
        'date': date,
      });
      
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => Task.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      _handleDioError(e, 'getTasksByDate');
      return [];
    } on Exception catch (e) {
      _logger.warning('Get tasks by date error: $e');
      return [];
    }
  }
  
  /// Görev oluştur
  Future<Task?> createTask(Task task) async {
    try {
      final response = await _dio.post('/tasks', data: task.toJson());
      
      if (response.statusCode == 201) {
        return Task.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'createTask');
      return null;
    } on Exception catch (e) {
      _logger.warning('Create task error: $e');
      return null;
    }
  }
  
  /// Görev güncelle
  Future<Task?> updateTask(Task task) async {
    if (task.id == null) {
      _logger.warning('Cannot update task without id');
      return null;
    }
    
    try {
      final response = await _dio.put('/tasks/${task.id}', data: task.toJson());
      
      if (response.statusCode == 200) {
        return Task.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'updateTask');
      return null;
    } on Exception catch (e) {
      _logger.warning('Update task error: $e');
      return null;
    }
  }
  
  /// Görev sil
  Future<bool> deleteTask(int taskId) async {
    try {
      final response = await _dio.delete('/tasks/$taskId');
      
      return response.statusCode == 204;
    } on DioException catch (e) {
      _handleDioError(e, 'deleteTask');
      return false;
    } on Exception catch (e) {
      _logger.warning('Delete task error: $e');
      return false;
    }
  }
  
  /// Görev tamamlama durumunu güncelle
  Future<bool> toggleTaskCompletion(int taskId, bool isCompleted) async {
    try {
      final response = await _dio.patch('/tasks/$taskId/complete', data: {
        'isCompleted': isCompleted,
      });
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      _handleDioError(e, 'toggleTaskCompletion');
      return false;
    } on Exception catch (e) {
      _logger.warning('Toggle task completion error: $e');
      return false;
    }
  }
  
  // Alışkanlık işlemleri
  
  /// Kullanıcının tüm alışkanlıklarını getir
  Future<List<Habit>> getHabits(int userId) async {
    try {
      final response = await _dio.get('/habits', queryParameters: {
        'userId': userId,
      });
      
      if (response.statusCode == 200) {
        // Burada Habit modelinizin JSON'dan dönüşüm desteği olmalı 
        // TODO: Habit modeli için fromJson metodu eklenmelidir
        return []; // Şimdilik boş liste dönüyoruz
      }
      return [];
    } on DioException catch (e) {
      _handleDioError(e, 'getHabits');
      return [];
    } on Exception catch (e) {
      _logger.warning('Get habits error: $e');
      return [];
    }
  }
  
  // Motivasyon alıntıları ve görev önerileri
  
  /// Rastgele motivasyon alıntısı getir
  Future<Map<String, String>?> getRandomQuote() async {
    try {
      final response = await _dio.get('https://api.quotable.io/random');
      
      if (response.statusCode == 200) {
        return {
          'text': response.data['content'],
          'author': response.data['author'],
        };
      }
      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'getRandomQuote');
      return null;
    } on Exception catch (e) {
      _logger.warning('Get random quote error: $e');
      return null;
    }
  }
  
  /// Rastgele aktivite önerisi getir
  Future<Map<String, dynamic>?> getRandomActivity() async {
    try {
      final response = await _dio.get('https://www.boredapi.com/api/activity');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'getRandomActivity');
      return null;
    } on Exception catch (e) {
      _logger.warning('Get random activity error: $e');
      return null;
    }
  }
  
  // Hata yönetimi
  void _handleDioError(DioException e, String method) {
    _logger.warning('$method error: ${e.type}');
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        _logger.warning('Timeout error in $method: Connection timed out');
        break;
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        _logger.warning('Bad response in $method: $statusCode - $data');
        break;
        
      case DioExceptionType.cancel:
        _logger.warning('Request was cancelled in $method');
        break;
        
      case DioExceptionType.connectionError:
        _logger.warning('No internet connection in $method');
        break;
        
      case DioExceptionType.badCertificate:
        _logger.warning('Bad certificate in $method');
        break;
        
      case DioExceptionType.unknown:
        _logger.warning('Unknown error in $method: ${e.error}');
        break;
    }
  }
}