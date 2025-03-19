import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

/// Motivasyon alıntıları ve aktivite önerileri getiren servis
///
/// Bu servis, API'lardan alıntılar ve aktivite önerileri getirir.
/// İnternet bağlantısı yoksa, yerel olarak saklanan verileri kullanır.
class InspirationService {
  // Constructorlar sınıfın başında
  InspirationService._internal() {
    _loadCachedData();
  }
  
  // Singleton pattern
  factory InspirationService() => _instance;
  
  static final InspirationService _instance = InspirationService._internal();
  
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    contentType: 'application/json',
  ));
  
  final ConnectivityService _connectivityService = ConnectivityService();
  final _logger = Logger('InspirationService');
  
  // Yerel olarak saklanan önceden alınmış alıntılar
  List<Map<String, String>> _cachedQuotes = [];
  
  // Yerel olarak saklanan önceden alınmış aktiviteler
  List<Map<String, dynamic>> _cachedActivities = [];
  
  // Önbelleğe alınmış verileri yükle
  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Alıntıları yükle
    final quotesJson = prefs.getString('cached_quotes');
    if (quotesJson != null) {
      try {
        final List<dynamic> decoded = _parseCachedJson(quotesJson);
        _cachedQuotes = decoded
            .map((item) => {
                  'text': item['text'] as String,
                  'author': item['author'] as String,
                })
            .toList();
      } on Exception catch (e) {
        _logger.warning('Alıntılar yüklenirken hata: $e');
        _setDefaultQuotes();
      }
    } else {
      _setDefaultQuotes();
    }
    
    // Aktiviteleri yükle
    final activitiesJson = prefs.getString('cached_activities');
    if (activitiesJson != null) {
      try {
        final List<dynamic> decoded = _parseCachedJson(activitiesJson);
        _cachedActivities = decoded
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } on Exception catch (e) {
        _logger.warning('Aktiviteler yüklenirken hata: $e');
        _setDefaultActivities();
      }
    } else {
      _setDefaultActivities();
    }
  }
  
  // JSON parse etme yardımcı metodu
  List<dynamic> _parseCachedJson(String json) {
    // Format: [{\\\\\\\"key\\\\\\\":\\\\\\\"value\\\\\\\"}, {\\\\\\\"key\\\\\\\":\\\\\\\"value\\\\\\\"}]
    if (json.startsWith('[') && json.endsWith(']')) {
      return customJsonDecode(json);
    }
    return [];
  }
  
  // Basit JSON parser (bağımlılık azaltmak için)
  List<dynamic> customJsonDecode(String json) {
    try {
      // jsonDecode kullan (dio.decoder kaldırıldı)
      return jsonDecode(json) as List<dynamic>;
    } on Exception catch (e) {
      _logger.warning('JSON parse error: $e');
      return [];
    }
  }
  
  // Varsayılan alıntıları ayarla
  void _setDefaultQuotes() {
    _cachedQuotes = [
      {
        'text': 'Bugünün işini yarına bırakma.',
        'author': 'Benjamin Franklin',
      },
      {
        'text': 'Başarı hazırlık ile fırsat buluştuğunda ortaya çıkar.',
        'author': 'Zig Ziglar',
      },
      {
        'text': 'Küçük adımlar, büyük değişimlere yol açar.',
        'author': 'ZenVivaTodo',
      },
      {
        'text': 'İyi alışkanlıklar, büyük sonuçlar doğurur.',
        'author': 'Aristotle',
      },
      {
        'text': 'Her başarı bir hayalle başlar.',
        'author': 'Walt Disney',
      },
    ];
  }
  
  // Varsayılan aktiviteleri ayarla
  void _setDefaultActivities() {
    _cachedActivities = [
      {
        'activity': '15 dakika meditasyon yap',
        'type': 'rahatlatıcı',
        'participants': 1,
      },
      {
        'activity': '10 dakika boyunca stretching egzersizleri yap',
        'type': 'fiziksel',
        'participants': 1,
      },
      {
        'activity': 'Su içme hatırlatıcısı kur',
        'type': 'sağlık',
        'participants': 1,
      },
      {
        'activity': 'Bir arkadaşına mektup yaz',
        'type': 'sosyal',
        'participants': 2,
      },
      {
        'activity': 'Yeni bir yemek tarifi dene',
        'type': 'yemek',
        'participants': 1,
      },
    ];
  }
  
  // Rastgele motivasyon alıntısı getir
  Future<Map<String, String>> getRandomQuote() async {
    // İnternet bağlantısı varsa API'dan alıntı getir
    if (_connectivityService.hasConnection) {
      try {
        final response = await _dio.get('https://api.quotable.io/random');
        
        if (response.statusCode == 200) {
          final quote = {
            'text': response.data['content'] as String,
            'author': response.data['author'] as String,
          };
          
          // Yeni alıntıyı önbelleğe ekle (en fazla 20 alıntı sakla)
          _cachedQuotes.add(quote);
          if (_cachedQuotes.length > 20) {
            _cachedQuotes.removeAt(0);
          }
          
          // Önbelleği kaydet
          _saveCachedQuotes();
          
          return quote;
        }
      } on Exception catch (e) {
        _logger.warning('Alıntı alınırken hata: $e');
      }
    }
    
    // API'dan alınamadıysa, önbellekten rastgele bir alıntı getir
    if (_cachedQuotes.isNotEmpty) {
      return _cachedQuotes[Random().nextInt(_cachedQuotes.length)];
    }
    
    // Hiçbir alıntı yoksa varsayılan bir alıntı döndür
    return {
      'text': 'Bugün yapacağın küçük ilerlemeler, yarınını şekillendirir.',
      'author': 'ZenVivaTodo',
    };
  }
  
  // Rastgele aktivite önerisi getir
  Future<Map<String, dynamic>> getRandomActivity() async {
    // İnternet bağlantısı varsa API'dan aktivite getir
    if (_connectivityService.hasConnection) {
      try {
        final response = await _dio.get('https://www.boredapi.com/api/activity');
        
        if (response.statusCode == 200) {
          final activity = response.data as Map<String, dynamic>;
          
          // Türkçe tip ekle
          activity['typeTr'] = _translateActivityType(activity['type'] as String);
          
          // Yeni aktiviteyi önbelleğe ekle (en fazla 20 aktivite sakla)
          _cachedActivities.add(activity);
          if (_cachedActivities.length > 20) {
            _cachedActivities.removeAt(0);
          }
          
          // Önbelleği kaydet
          _saveCachedActivities();
          
          return activity;
        }
      } on Exception catch (e) {
        _logger.warning('Aktivite alınırken hata: $e');
      }
    }
    
    // API'dan alınamadıysa, önbellekten rastgele bir aktivite getir
    if (_cachedActivities.isNotEmpty) {
      return _cachedActivities[Random().nextInt(_cachedActivities.length)];
    }
    
    // Hiçbir aktivite yoksa varsayılan bir aktivite döndür
    return {
      'activity': 'Bugün için 3 tane küçük hedef belirle',
      'type': 'productivity',
      'typeTr': 'üretkenlik',
      'participants': 1,
    };
  }
  
  // Tüm alıntıları temizle
  Future<void> clearCachedQuotes() async {
    _cachedQuotes = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_quotes');
  }
  
  // Tüm aktiviteleri temizle
  Future<void> clearCachedActivities() async {
    _cachedActivities = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_activities');
  }
  
  // Önbelleğe alınmış alıntıları kaydet
  Future<void> _saveCachedQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    // JSON encode kullanarak direk dönüştür
    await prefs.setString('cached_quotes', jsonEncode(_cachedQuotes));
  }
  
  // Önbelleğe alınmış aktiviteleri kaydet
  Future<void> _saveCachedActivities() async {
    final prefs = await SharedPreferences.getInstance();
    // JSON encode kullanarak direk dönüştür
    await prefs.setString('cached_activities', jsonEncode(_cachedActivities));
  }
  
  // Aktivite tipini çevir
  String _translateActivityType(String type) {
    switch (type.toLowerCase()) {
      case 'education':
        return 'eğitim';
      case 'recreational':
        return 'eğlence';
      case 'social':
        return 'sosyal';
      case 'diy':
        return 'kendin yap';
      case 'charity':
        return 'yardım';
      case 'cooking':
        return 'yemek';
      case 'relaxation':
        return 'rahatlama';
      case 'music':
        return 'müzik';
      case 'busywork':
        return 'rutin iş';
      default:
        return type;
    }
  }
  
  // Dio getter
  Dio get dio => _dio;
}