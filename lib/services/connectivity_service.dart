import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// İnternet bağlantısı durumunu takip eden servis sınıfı
///
/// Uygulama genelinde internet bağlantısının durumunu takip eder,
/// bağlantı değişikliklerini Stream üzerinden yayınlar ve gerekli
/// bildirimleri gösterir.
class ConnectivityService {
  // Constructor'ları düzgün şekilde yerleştirme
  // Singleton pattern
  factory ConnectivityService() => _instance;
  
  ConnectivityService._internal() {
    // Başlangıç durumunu al
    _initConnectivity();
    
    // Bağlantı değişikliklerini dinle
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }
  
  static final ConnectivityService _instance = ConnectivityService._internal();
  
  // Logger tanımla
  final _logger = Logger('ConnectivityService');
  
  // Connectivity instance
  final Connectivity _connectivity = Connectivity();
  
  // Connection stream controller - ConnectivityResult tipinde streami yayınlar
  final StreamController<ConnectivityResult> _connectionStatusController =
      StreamController<ConnectivityResult>.broadcast();
  
  // Bağlantı durumu stream'i
  Stream<ConnectivityResult> get connectionStream => _connectionStatusController.stream;
  
  // Son bağlantı durumu
  ConnectivityResult _lastResult = ConnectivityResult.none;
  ConnectivityResult get lastResult => _lastResult;
  
  // Bağlantı var mı?
  bool get hasConnection => _lastResult != ConnectivityResult.none;
  
  // Başlangıç durumunu kontrol et
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } on Exception catch (e) {
      _logger.warning('Connectivity check error: $e');
      _updateConnectionStatus(ConnectivityResult.none);
    }
  }
  
  // Connectivity API'deki değişiklik: onConnectivityChanged artık bir List<ConnectivityResult> döndürüyor
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _updateConnectionStatus(ConnectivityResult.none);
    } else {
      // Liste boş değilse, mobil veya WiFi varsa bağlantı var demektir
      final hasMobileOrWifi = results.contains(ConnectivityResult.mobile) || 
                             results.contains(ConnectivityResult.wifi) ||
                             results.contains(ConnectivityResult.ethernet);
                             
      // Bağlantı durumunu güncelle
      _updateConnectionStatus(hasMobileOrWifi ? 
        (results.contains(ConnectivityResult.wifi) ? ConnectivityResult.wifi : ConnectivityResult.mobile) :
        ConnectivityResult.none);
    }
  }
  
  // Bağlantı durumunu güncelle - tek bir ConnectivityResult parametresi alır
  void _updateConnectionStatus(ConnectivityResult result) {
    _logger.info('Connectivity changed: $result');
    _lastResult = result;
    _connectionStatusController.add(result);
  }
  
  // Mevcut bağlantı durumunu kontrol et
  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    
    // Sonuç artık bir liste, ilk sonucu kullan veya bağlantı yoksa none döndür
    if (results.isNotEmpty) {
      final hasMobileOrWifi = results.contains(ConnectivityResult.mobile) || 
                             results.contains(ConnectivityResult.wifi) ||
                             results.contains(ConnectivityResult.ethernet);
                             
      // Bağlantı durumunu güncelle
      final result = hasMobileOrWifi ? 
          (results.contains(ConnectivityResult.wifi) ? ConnectivityResult.wifi : ConnectivityResult.mobile) :
          ConnectivityResult.none;
          
      _updateConnectionStatus(result);
      return result != ConnectivityResult.none;
    } else {
      _updateConnectionStatus(ConnectivityResult.none);
      return false;
    }
  }
  
  // Bağlantı durumu snackbar'ı göster
  static void showConnectivitySnackBar(BuildContext context, ConnectivityResult result) {
    final hasConnection = result != ConnectivityResult.none;
    
    final message = hasConnection
        ? 'İnternet bağlantısı kuruldu'
        : 'İnternet bağlantısı yok! Veriler çevrimdışı kaydedilecek.';
        
    final color = hasConnection ? Colors.green : Colors.red;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: const EdgeInsets.all(8.0),
      ),
    );
  }
  
  // Servis kapatılırken stream controller'ı kapat
  void dispose() {
    _connectionStatusController.close();
  }
}

/// İnternet bağlantısına duyarlı Widget
///
/// Bu widget, internet bağlantısını takip eder ve bağlantı durumuna
/// göre farklı UI'lar gösterir.
class ConnectivityWidget extends StatelessWidget {
  // Constructor'ı sınıfın başına taşıdık - sort_constructors_first
  const ConnectivityWidget({
    super.key,
    required this.connected,
    required this.disconnected,
  });
  
  final Widget connected;
  final Widget disconnected;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: ConnectivityService().connectionStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data != ConnectivityResult.none;
        
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isConnected ? connected : disconnected,
        );
      },
    );
  }
}