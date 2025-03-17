import 'package:flutter/material.dart';

/// Uygulama renkleri - Material 3 ve Flutter 3.29 uyumlu
class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLightColor = Color(0xFF9D97FF);
  static const Color primaryDarkColor = Color(0xFF4B44CC);

  // Secondary colors
  static const Color secondaryColor = Color(0xFFFF6584);
  static const Color secondaryLightColor = Color(0xFFFF97AB);
  static const Color secondaryDarkColor = Color(0xFFCC3A5D);

  // Background colors
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color darkBackground = Color(0xFF121212);

  // Card colors
  static const Color lightCardColor = Colors.white;
  static const Color darkCardColor = Color(0xFF1E1E1E);

  // Text colors
  static const Color lightTextColor = Color(0xFF2D2D2D);
  static const Color darkTextColor = Color(0xFFF5F5F7);
  static const Color lightSecondaryTextColor = Color(0xFF757575);
  static const Color darkSecondaryTextColor = Color(0xFFBDBDBD);

  // Priority colors
  static const Color lowPriorityColor = Color(0xFF4CAF50); // Green
  static const Color mediumPriorityColor = Color(0xFFFFA726); // Orange
  static const Color highPriorityColor = Color(0xFFE53935); // Red

  // Category default colors
  static const Color workCategoryColor = Color(0xFF1565C0);
  static const Color personalDevCategoryColor = Color(0xFF673AB7);
  static const Color healthCategoryColor = Color(0xFF4CAF50);
  static const Color defaultCategoryColor = Color(0xFF9E9E9E);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Material 3 Light Theme Color Scheme
  static ColorScheme get lightColorScheme => ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: Colors.white,
    primaryContainer: primaryLightColor,
    onPrimaryContainer: Colors.white,
    secondary: secondaryColor,
    onSecondary: Colors.white,
    secondaryContainer: secondaryLightColor,
    onSecondaryContainer: Colors.white,
    tertiary: healthCategoryColor,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFBEECBE),
    onTertiaryContainer: Color(0xFF0A3A0A),
    error: errorColor,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD9),
    onErrorContainer: Color(0xFF410002),
    background: lightBackground,
    onBackground: lightTextColor,
    surface: lightCardColor,
    onSurface: lightTextColor,
    surfaceVariant: Color(0xFFE7E0EC),
    onSurfaceVariant: lightSecondaryTextColor,
    outline: Color(0xFFBDBDBD),
    outlineVariant: Color(0xFFCAC4D0),
    shadow: Colors.black.withOpacity(0.2),
    scrim: Colors.black.withOpacity(0.5),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: primaryLightColor,
    surfaceTint: primaryColor,
  );
  
  // Material 3 Dark Theme Color Scheme
  static ColorScheme get darkColorScheme => ColorScheme(
    brightness: Brightness.dark,
    primary: primaryLightColor,
    onPrimary: Color(0xFF381E73),
    primaryContainer: primaryColor,
    onPrimaryContainer: Colors.white,
    secondary: secondaryLightColor,
    onSecondary: Color(0xFF633B49),
    secondaryContainer: secondaryColor,
    onSecondaryContainer: Colors.white,
    tertiary: Color(0xFF8FDB8F),
    onTertiary: Color(0xFF053505),
    tertiaryContainer: healthCategoryColor,
    onTertiaryContainer: Colors.white,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: errorColor,
    onErrorContainer: Colors.white,
    background: darkBackground,
    onBackground: darkTextColor,
    surface: darkCardColor,
    onSurface: darkTextColor,
    surfaceVariant: Color(0xFF49454F),
    onSurfaceVariant: darkSecondaryTextColor,
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF444249),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE6E0E9),
    onInverseSurface: Color(0xFF1D1B20),
    inversePrimary: primaryDarkColor,
    surfaceTint: primaryLightColor,
  );
}