import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'constants/app_theme.dart';
import 'constants/app_texts.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Turkish locale
  await initializeDateFormatting('tr_TR', null);

  // Initialize notification service
  await NotificationService().initNotification();
  
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
  final NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    
    // Listen to notification clicks
    _listenToNotificationStream();
  }
  
  void _listenToNotificationStream() {
    _notificationService.onNotificationClick.stream.listen((String? payload) {
      if (payload != null && payload.isNotEmpty) {
        // Handle notification click - opens specific task
        debugPrint('Notification payload: $payload');
        // You can navigate to a specific screen using this payload
        // Navigator.push(context, MaterialPageRoute(builder: (_) => SpecificTaskScreen(taskId: int.parse(payload))));
      }
    });
  }

  @override
  void dispose() {
    AwesomeNotifications().dispose();
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
