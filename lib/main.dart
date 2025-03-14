import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_theme.dart';
import 'constants/app_texts.dart';
import 'screens/splash_screen.dart';
import 'services/reminder_service.dart';

// Global navigaor key to use for showing dialogs from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Turkish locale
  await initializeDateFormatting('tr_TR', null);

  // Initialize reminder service
  ReminderService().initialize();
  
  // Get theme preference
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkMode: isDarkMode),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode;

  ThemeProvider({required bool isDarkMode}) : _isDarkMode = isDarkMode;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData =>
      _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    // Save theme preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // Clean up reminder service when app is closed
    ReminderService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: AppTexts.appName,
          theme: themeProvider.themeData,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey, // Use the global navigator key
          // Add localization support
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr', 'TR'), // Turkish
            Locale('en', 'US'), // English
          ],
          locale: const Locale('tr', 'TR'),
          home: const SplashScreen(),
        );
      },
    );
  }
}
