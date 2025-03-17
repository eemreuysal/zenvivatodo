import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_theme.dart';
import 'constants/app_texts.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

// Global navigaor key to use for showing dialogs from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Flutter widget bağlantılarını başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatlamasını başlat
  await initializeDateFormatting('tr_TR', null);
  
  // Bildirim servisini başlat
  final notificationService = NotificationService();
  await notificationService.init();

  // Tema tercihini al
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode: isDarkMode)),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode;

  // Wildcard değişken kullanımı (Dart 3.7 özelliği)
  ThemeProvider({required bool isDarkMode}) : _isDarkMode = isDarkMode;

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
        );
      },
    );
  }
}