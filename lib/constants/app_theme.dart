import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './app_colors.dart';

/// Flutter 3.29 ve Material 3 ile uyumlu tema sınıfı
class AppTheme {
  // Google Fonts ile metin stilleri oluşturma
  static TextTheme _createTextTheme(TextTheme base, Color textColor, Color secondaryTextColor) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: textColor),
      displayMedium: base.displayMedium?.copyWith(color: textColor),
      displaySmall: base.displaySmall?.copyWith(color: textColor),
      headlineLarge: base.headlineLarge?.copyWith(color: textColor),
      headlineMedium: base.headlineMedium?.copyWith(color: textColor),
      headlineSmall: base.headlineSmall?.copyWith(color: textColor),
      titleLarge: base.titleLarge?.copyWith(color: textColor),
      titleMedium: base.titleMedium?.copyWith(color: textColor),
      titleSmall: base.titleSmall?.copyWith(color: textColor),
      bodyLarge: base.bodyLarge?.copyWith(color: textColor),
      bodyMedium: base.bodyMedium?.copyWith(color: textColor),
      bodySmall: base.bodySmall?.copyWith(color: secondaryTextColor),
      labelLarge: base.labelLarge?.copyWith(color: textColor),
      labelMedium: base.labelMedium?.copyWith(color: textColor),
      labelSmall: base.labelSmall?.copyWith(color: secondaryTextColor),
    );
  }

  // Light (Açık) tema
  static ThemeData get lightTheme {
    // Montserrat font ailesi ile metin teması oluşturma
    final baseTextTheme = GoogleFonts.montserratTextTheme();
    final lightTextTheme = _createTextTheme(
      baseTextTheme,
      AppColors.lightTextColor,
      AppColors.lightSecondaryTextColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.lightColorScheme,
      textTheme: lightTextTheme,
      
      // AppBar teması
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        scrolledUnderElevation: 2,
        shadowColor: Colors.black26,
      ),
      
      // Card teması
      cardTheme: CardTheme(
        color: AppColors.lightCardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      
      // Buton temaları
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(double.infinity, 56),
          textStyle: lightTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Metin butonu teması
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: lightTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outline buton teması
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: BorderSide(color: AppColors.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(double.infinity, 56),
          textStyle: lightTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // İkon buton teması
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),
      
      // Giriş alanı teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lightSecondaryTextColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lightSecondaryTextColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.errorColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.errorColor,
            width: 2,
          ),
        ),
        labelStyle: lightTextTheme.bodyMedium,
        hintStyle: lightTextTheme.bodyMedium?.copyWith(
          color: AppColors.lightSecondaryTextColor.withOpacity(0.7),
        ),
        errorStyle: lightTextTheme.bodySmall?.copyWith(
          color: AppColors.errorColor,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppColors.lightSecondaryTextColor,
        suffixIconColor: AppColors.lightSecondaryTextColor,
      ),
      
      // Tarih ve saat seçicisi temaları
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        headerHeadlineStyle: lightTextTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      
      // Diğer bileşen temaları
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor;
          }
          return null;
        }),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor.withOpacity(0.5);
          }
          return null;
        }),
      ),
      
      // Diğer özellikler
      scaffoldBackgroundColor: AppColors.lightBackground,
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCardColor,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dark (Koyu) tema
  static ThemeData get darkTheme {
    // Montserrat font ailesi ile metin teması oluşturma
    final baseTextTheme = GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme);
    final darkTextTheme = _createTextTheme(
      baseTextTheme,
      AppColors.darkTextColor,
      AppColors.darkSecondaryTextColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.darkColorScheme,
      textTheme: darkTextTheme,
      
      // AppBar teması
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkCardColor,
        foregroundColor: AppColors.darkTextColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        scrolledUnderElevation: 2,
        shadowColor: Colors.black,
      ),
      
      // Card teması
      cardTheme: CardTheme(
        color: AppColors.darkCardColor,
        elevation: 2,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      
      // Buton temaları
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(double.infinity, 56),
          textStyle: darkTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Metin butonu teması
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLightColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: darkTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outline buton teması
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLightColor,
          side: BorderSide(color: AppColors.primaryLightColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(double.infinity, 56),
          textStyle: darkTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Giriş alanı teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkSecondaryTextColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkSecondaryTextColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.errorColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.errorColor,
            width: 2,
          ),
        ),
        labelStyle: darkTextTheme.bodyMedium,
        hintStyle: darkTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkSecondaryTextColor.withOpacity(0.7),
        ),
        errorStyle: darkTextTheme.bodySmall?.copyWith(
          color: AppColors.errorColor,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppColors.darkSecondaryTextColor,
        suffixIconColor: AppColors.darkSecondaryTextColor,
      ),
      
      // Diğer bileşen temaları (tarih seçici, vb.)
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.darkCardColor,
        headerBackgroundColor: AppColors.primaryColor,
        headerForegroundColor: Colors.white,
        dayForegroundColor: MaterialStateProperty.all(AppColors.darkTextColor),
        yearForegroundColor: MaterialStateProperty.all(AppColors.darkTextColor),
        todayForegroundColor: MaterialStateProperty.all(AppColors.primaryLightColor),
        todayBackgroundColor: MaterialStateProperty.all(Colors.transparent),
        dayBackgroundColor: MaterialStateProperty.all(Colors.transparent),
        yearBackgroundColor: MaterialStateProperty.all(Colors.transparent),
        surfaceTintColor: AppColors.darkCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        headerHeadlineStyle: darkTextTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.darkCardColor,
        hourMinuteTextColor: AppColors.darkTextColor,
        dayPeriodTextColor: AppColors.darkTextColor,
        dialHandColor: AppColors.primaryLightColor,
        dialBackgroundColor: AppColors.darkBackground,
        hourMinuteColor: AppColors.darkBackground,
        dayPeriodColor: AppColors.darkBackground,
        dialTextColor: AppColors.darkTextColor,
        entryModeIconColor: AppColors.darkTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLightColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Diğer özellikler
      scaffoldBackgroundColor: AppColors.darkBackground,
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkCardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
        space: 1,
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCardColor,
        contentTextStyle: TextStyle(color: AppColors.darkTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}