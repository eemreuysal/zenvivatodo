import 'package:flutter/material.dart';

/// Flutter 3.28 sürümünden sonra kullanımdan kaldırılan renk metotları için
/// yardımcı uzantılar
extension ColorExtensions on Color {
  /// withOpacity kullanımdan kaldırıldığı için yerine withAlpha kullanımı
  Color withAlphaValue(double opacity) {
    final int alpha = (opacity * 255).round();
    return withAlpha(alpha);
  }
  
  /// Bileşen değerlerini kullanarak renk oluşturur
  Color withRGBValues({int? red, int? green, int? blue, double? opacity}) {
    final int r = red ?? this.r.toInt();
    final int g = green ?? this.g.toInt();
    final int b = blue ?? this.b.toInt();
    final int a = opacity != null ? (opacity * 255).round() : this.a.toInt();
    
    return Color.fromARGB(a, r, g, b);
  }
}
