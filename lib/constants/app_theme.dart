import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
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
    cardTheme: CardTheme(
      color: AppColors.lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(
          AppColors.primaryColor,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.lightSecondaryTextColor.withAlpha(76),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.lightSecondaryTextColor.withAlpha(76),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
    textTheme: const TextTheme(
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
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkCardColor,
      foregroundColor: AppColors.darkTextColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppColors.darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(
          AppColors.primaryColor,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.darkSecondaryTextColor.withAlpha(76),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.darkSecondaryTextColor.withAlpha(76),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
    textTheme: const TextTheme(
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
    ),
  );
}
