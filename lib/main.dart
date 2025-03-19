import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_texts.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';
import 'services/inspiration_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';

// Global navigator key to use for showing dialogs from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Flutter widget bağlantılarını başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatlamasını başlat
  await initializeDateFormatting('tr_TR');
  
  // Bildirim servisini başlat
  final notificationService = NotificationService();
  await notificationService.init();
  
  // Connectivity servisini başlat
  final connectivityService = ConnectivityService();
  await connectivityService.checkConnection();

  // API servisini başlat - bu servisi kullanacaksanız kaldırmayın
  // ignore: unused_local_variable
  final apiService = ApiService();
  
  // Inspiration servisini başlat - bu servisi kullanacaksanız kaldırmayın
  // ignore: unused_local_variable
  final inspirationService = InspirationService();
  
  // Tema tercihini al
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  // Çevrimiçi modu al
  final isOnlineMode = prefs.getBool('isOnlineMode') ?? true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode: isDarkMode)),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider(
          hasConnection: connectivityService.hasConnection,
          isOnlineMode: isOnlineMode,
        )),
      ],
      child: const MyApp(),
    ),
  );
}

// Tema sağlayıcısı
class ThemeProvider with ChangeNotifier {
  // Wildcard değişken kullanımı (Dart 3.7 özelliği)
  ThemeProvider({required bool isDarkMode}) : _isDarkMode = isDarkMode;
  bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;

  // Property pattern kullanımı (Dart 3.7 özelliği)
  ThemeData get themeData => switch (_isDarkMode) {
    true => AppTheme.darkTheme,
    false => AppTheme.lightTheme,
  };

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    // Tema tercihini kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }
}

// Bağlantı durumu sağlayıcısı
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
      
      // Bağlantı kurulduysa ve çevrimiçi mod aktifse, senkronizasyonu başlat
      if (_hasConnection && _isOnlineMode) {
        _syncData();
      }
    }
  }
  
  // Çevrimiçi modu değiştir
  Future<void> toggleOnlineMode() async {
    _isOnlineMode = !_isOnlineMode;
    
    // Tercihi kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnlineMode', _isOnlineMode);
    
    // Bildiri yap
    notifyListeners();
    
    // Çevrimiçi moda geçildiyse ve bağlantı varsa, senkronizasyonu başlat
    if (_isOnlineMode && _hasConnection) {
      _syncData();
    }
  }
  
  // Senkronizasyonu başlat (kullanıcı ID'si gerekiyor)
  Future<void> _syncData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    
    if (userId != null) {
      await SyncService().syncAll(userId);
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) {
        // Google Fonts entegrasyonu
        final textTheme = GoogleFonts.montserratTextTheme(
          themeProvider.isDarkMode 
              ? ThemeData.dark().textTheme 
              : ThemeData.light().textTheme,
        );
        
        final updatedTheme = themeProvider.themeData.copyWith(
          textTheme: textTheme,
        );
        
        return MaterialApp(
          title: AppTexts.appName,
          theme: updatedTheme,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          // Erişilebilirlik seçenekleri
          shortcuts: {
            ...WidgetsApp.defaultShortcuts,
            // Özel kısayollar eklenebilir
          },
          // Lokalizasyon desteği
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr', 'TR'), // Türkçe
            Locale('en', 'US'), // İngilizce
          ],
          locale: const Locale('tr', 'TR'),
          home: const SplashScreen(),
          builder: (context, child) {
            // İnternet bağlantısı değişikliklerini izle ve bildir
            return Consumer<ConnectivityProvider>(
              builder: (context, connectivity, _) {
                return child!;
              },
            );
          },
        );
      },
    );
  }
  
  @override
  void dispose() {
    // Servisleri kapat
    SyncService().dispose();
    super.dispose();
  }
}