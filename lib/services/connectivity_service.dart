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
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  static final ConnectivityService _instance = ConnectivityService._internal();
  
  // Logger tanımla
  final _logger = Logger('ConnectivityService');
  
  // Connectivity instance
  final Connectivity _connectivity = Connectivity();
  
  // Connection stream controller
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
  
  // Connectivity sonucunu işle ve Stream'e ilet
  void _updateConnectionStatus(ConnectivityResult result) {
    _logger.info('Connectivity changed: $result');
    _lastResult = result;
    _connectionStatusController.add(result);
  }
  
  // Mevcut bağlantı durumunu kontrol et
  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      
      // ConnectivityResult değerini kullan
      _updateConnectionStatus(result);
      return result != ConnectivityResult.none;
    } on Exception catch (e) {
      _logger.warning('Connectivity check error: $e');
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

/// Bağlantı durumu sağlayıcısı
/// Bu sınıf main.dart'a taşınması gerekmektedir,
/// ancak uyumlu olabilmesi için burada da tanımlanıyor
class ConnectivityProvider with ChangeNotifier {
  ConnectivityProvider({
    required bool hasConnection,
    required bool isOnlineMode,
  })  : _hasConnection = hasConnection,
        _isOnlineMode = isOnlineMode {
    // Bağlantı değişikliklerini dinle
    ConnectivityService().connectionStream.listen(_updateConnectionStatus);
  }

  bool _hasConnection;
  bool _isOnlineMode;

  bool get hasConnection => _hasConnection;
  bool get isOnlineMode => _isOnlineMode;
  
  // Çevrimiçi işlem yapılabilir mi?
  bool get canPerformOnlineOperations => _hasConnection && _isOnlineMode;

  // Bağlantı durumunu güncelle
  void _updateConnectionStatus(ConnectivityResult result) {
    final previousStatus = _hasConnection;
    _hasConnection = result != ConnectivityResult.none;
    
    // Durum değiştiyse bildiri yap
    if (previousStatus != _hasConnection) {
      notifyListeners();
    }
  }
  
  // Çevrimiçi modu değiştir
  Future<void> toggleOnlineMode() async {
    _isOnlineMode = !_isOnlineMode;
    notifyListeners();
  }
}