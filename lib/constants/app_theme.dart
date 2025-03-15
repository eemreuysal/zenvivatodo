import 'package:flutter/material.dart';
import './app_colors.dart';

class AppTheme {
  // Light theme text styles
  static const _lightTextTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.lightTextColor),
    displayMedium: TextStyle(color: AppColors.lightTextColor),
    displaySmall: TextStyle(color: AppColors.lightTextColor),
    headlineLarge: TextStyle(color: AppColors.lightTextColor),
    headlineMedium: TextStyle(color: AppColors.lightTextColor),
    headlineSmall: TextStyle(color: AppColors.lightTextColor),
    titleLarge: TextStyle(color: AppColors.lightTextColor),
    titleMedium: TextStyle(color: AppColors.lightTextColor),
    titleSmall: TextStyle(color: AppColors.lightTextColor),
    bodyLarge: TextStyle(color: AppColors.lightTextColor),
    bodyMedium: TextStyle(color: AppColors.lightTextColor),
    bodySmall: TextStyle(color: AppColors.lightSecondaryTextColor),
    labelLarge: TextStyle(color: AppColors.lightTextColor),
    labelMedium: TextStyle(color: AppColors.lightTextColor),
    labelSmall: TextStyle(color: AppColors.lightSecondaryTextColor),
  );

  // Dark theme text styles
  static const _darkTextTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.darkTextColor),
    displayMedium: TextStyle(color: AppColors.darkTextColor),
    displaySmall: TextStyle(color: AppColors.darkTextColor),
    headlineLarge: TextStyle(color: AppColors.darkTextColor),
    headlineMedium: TextStyle(color: AppColors.darkTextColor),
    headlineSmall: TextStyle(color: AppColors.darkTextColor),
    titleLarge: TextStyle(color: AppColors.darkTextColor),
    titleMedium: TextStyle(color: AppColors.darkTextColor),
    titleSmall: TextStyle(color: AppColors.darkTextColor),
    bodyLarge: TextStyle(color: AppColors.darkTextColor),
    bodyMedium: TextStyle(color: AppColors.darkTextColor),
    bodySmall: TextStyle(color: AppColors.darkSecondaryTextColor),
    labelLarge: TextStyle(color: AppColors.darkTextColor),
    labelMedium: TextStyle(color: AppColors.darkTextColor),
    labelSmall: TextStyle(color: AppColors.darkSecondaryTextColor),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.lightCardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextColor,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardTheme(
      color: AppColors.lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.primaryColor),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        minimumSize: WidgetStatePropertyAll(Size(double.infinity, 50)),
      ),
    ),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.primaryColor),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Color(
              0xBFBDBDBD), // AppColors.lightSecondaryTextColor with alpha 76
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Color(
              0xBFBDBDBD), // AppColors.lightSecondaryTextColor with alpha 76
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
    textTheme: _lightTextTheme,
    // Tarih ve saat seçici için tema ayarları
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white,
      headerBackgroundColor: AppColors.primaryColor,
      headerForegroundColor: Colors.white,
      dayForegroundColor: MaterialStateProperty.all(AppColors.lightTextColor),
      yearForegroundColor: MaterialStateProperty.all(AppColors.lightTextColor),
      todayForegroundColor: MaterialStateProperty.all(AppColors.primaryColor),
      todayBackgroundColor: MaterialStateProperty.all(Colors.transparent),
      dayBackgroundColor: MaterialStateProperty.all(Colors.transparent),
      yearBackgroundColor: MaterialStateProperty.all(Colors.transparent),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: Colors.white,
      hourMinuteTextColor: AppColors.lightTextColor,
      dayPeriodTextColor: AppColors.lightTextColor,
      dialHandColor: AppColors.primaryColor,
      dialBackgroundColor: AppColors.lightBackground,
      hourMinuteColor: AppColors.lightBackground,
      dayPeriodColor: AppColors.lightBackground,
      dialTextColor: AppColors.lightTextColor,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.darkCardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextColor,
      background: AppColors.darkBackground,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkCardColor,
      foregroundColor: AppColors.darkTextColor,
      elevation: 0,
    ),
    cardTheme: const CardTheme(
      color: AppColors.darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.primaryColor),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        minimumSize: WidgetStatePropertyAll(Size(double.infinity, 50)),
      ),
    ),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.primaryColor),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Color(
              0xBF9E9E9E), // AppColors.darkSecondaryTextColor with alpha 76
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Color(
              0xBF9E9E9E), // AppColors.darkSecondaryTextColor with alpha 76
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
    textTheme: _darkTextTheme,
    // Koyu tema için tarih ve saat seçici ayarları
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.darkCardColor,
      headerBackgroundColor: AppColors.primaryColor,
      headerForegroundColor: Colors.white,
      dayForegroundColor: MaterialStateProperty.all(AppColors.darkTextColor),
      yearForegroundColor: MaterialStateProperty.all(AppColors.darkTextColor),
      todayForegroundColor: MaterialStateProperty.all(AppColors.primaryColor),
      todayBackgroundColor: MaterialStateProperty.all(Colors.transparent),
      dayBackgroundColor: MaterialStateProperty.all(Colors.transparent),
      yearBackgroundColor: MaterialStateProperty.all(Colors.transparent),
      surfaceTintColor: AppColors.darkCardColor,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.darkCardColor,
      hourMinuteTextColor: AppColors.darkTextColor,
      dayPeriodTextColor: AppColors.darkTextColor,
      dialHandColor: AppColors.primaryColor,
      dialBackgroundColor: AppColors.darkBackground,
      hourMinuteColor: AppColors.darkBackground,
      dayPeriodColor: AppColors.darkBackground,
      dialTextColor: AppColors.darkTextColor,
      entryModeIconColor: AppColors.darkTextColor,
    ),
  );
}