// Priority enum - Modern Dart 3.7 özellikleri kullanılarak güncellendi

/// Görev önceliği enumeration
enum Priority {
  low(value: 0, label: 'Düşük'),
  medium(value: 1, label: 'Orta'),
  high(value: 2, label: 'Yüksek');

  const Priority({required this.value, required this.label});
  
  final int value;
  final String label;
  
  /// Öncelik değerinden enum değeri oluşturma
  static Priority fromValue(int value) => switch (value) {
    0 => Priority.low,
    1 => Priority.medium,
    2 => Priority.high,
    _ => Priority.medium,
  };
  
  /// String temsilini döndürme
  @override
  String toString() => label;
  
  /// Öncelik rengini almak için yardımcı metod (eski kodlarla uyumluluk için)
  String getColorName() => switch (this) {
    Priority.low => 'green',
    Priority.medium => 'orange',
    Priority.high => 'red',
  };
}

/// Eski kodlar için uyumluluk sağlayan extension
/// Not: Yeni kodlarda doğrudan Priority enum'ını kullanın
extension PriorityExtension on Priority {
  String get name => label;
  
  int get value => this.value;
  
  static Priority fromValue(int value) => Priority.fromValue(value);
}
