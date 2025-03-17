// Priority enum - Modern Dart 3.7 özellikleri kullanılarak güncellendi

/// Görev önceliği enumeration
/// Tüm projede tutarlı olması için TaskPriority ismi kullanılmıştır.
enum TaskPriority {
  low(value: 0, label: 'Düşük'),
  medium(value: 1, label: 'Orta'),
  high(value: 2, label: 'Yüksek');

  const TaskPriority({required this.value, required this.label});
  
  final int value;
  final String label;
  
  /// Öncelik değerinden enum değeri oluşturma
  static TaskPriority fromValue(int value) => switch (value) {
    0 => TaskPriority.low,
    1 => TaskPriority.medium,
    2 => TaskPriority.high,
    _ => TaskPriority.medium,
  };
  
  /// String temsilini döndürme
  @override
  String toString() => label;
  
  /// Öncelik rengini almak için yardımcı metod (eski kodlarla uyumluluk için)
  String getColorName() => switch (this) {
    TaskPriority.low => 'green',
    TaskPriority.medium => 'orange',
    TaskPriority.high => 'red',
  };
}

/// Eski kodlar için uyumluluk sağlayan extension
/// Not: Yeni kodlarda doğrudan TaskPriority enum'ını kullanın
extension PriorityExtension on TaskPriority {
  String get name => label;
  
  // Değer alanına erişim için
  int get value => this.value;
  
  static TaskPriority fromValue(int value) => TaskPriority.fromValue(value);
}

/// Eski Priority enum'u yerine kullanmak için typedef
/// Uyarı: Yeni kodlarda TaskPriority kullanılmalıdır
typedef Priority = TaskPriority;
