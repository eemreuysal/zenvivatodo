# ZenViva Todo Linting Sorunları Çözüm Kılavuzu

Bu doküman, projede bulunan lint uyarıları ve hataları için çözüm önerilerini içermektedir.

## Yapılan Düzeltmeler

Aşağıdaki dosyalarda düzeltmeler yapılmıştır:

1. **splash_screen.dart**
   - `Colors.black.withValues(opacity: 0.2)` → `Colors.black.withAlpha(51)` ile değiştirildi
   - Gereksiz çoklu alt çizgi kullanımı `(_, value, __)` → `(_, value, _)` şeklinde düzeltildi

2. **connectivity_service.dart**
   - Constructor'lar sınıf üyelerinden önce yerleştirildi (sort_constructors_first kuralı)
   - Bağlantı yönetimi sınıfı güncellendi

3. **notification_service.dart**
   - Import sıralaması düzeltildi (directives_ordering kuralı)
   - Gereksiz parametreler (redundant_argument_values) kaldırıldı
   - `requestPermission` metodu yerine doğru API methodu olan `requestPermissions` kullanıldı

4. **api_service.dart**
   - Gereksiz import kaldırıldı (unused_import)
   - Import sıralaması düzeltildi
   - `print` yerine `_logger.warning` kullanıldı
   - Constructor'lar düzgün sıralandı
   - Trailing commas (sonda virgül) eklendi

5. **habit_card.dart**
   - `withValues(opacity: x)` yerine `withAlpha(y)` kullanıldı
   - Opacity değerleri alpha değerlerine dönüştürüldü (0.5 → 128, 0.2 → 51, 0.1 → 26, 0.6 → 153)

6. **Eksik asset dizinleri oluşturuldu**
   - `assets/images/` dizini
   - `assets/icons/` dizini

## Diğer Dosyalarda Yapılması Gereken Düzeltmeler

### 1. Color.withOpacity Kullanımları
Tüm projedeki `Color.withOpacity(x)` kullanımları `Color.withAlpha(y)` ile değiştirilmelidir:

- 0.1 opacity → 26 alpha (255 * 0.1 = 25.5 ≈ 26)
- 0.2 opacity → 51 alpha (255 * 0.2 = 51)
- 0.3 opacity → 77 alpha (255 * 0.3 = 76.5 ≈ 77)
- 0.4 opacity → 102 alpha (255 * 0.4 = 102)
- 0.5 opacity → 128 alpha (255 * 0.5 = 127.5 ≈ 128)
- 0.6 opacity → 153 alpha (255 * 0.6 = 153)
- 0.7 opacity → 179 alpha (255 * 0.7 = 178.5 ≈ 179)
- 0.8 opacity → 204 alpha (255 * 0.8 = 204)
- 0.9 opacity → 230 alpha (255 * 0.9 = 229.5 ≈ 230)

### 2. Color Bileşenleri Erişim
`.red`, `.green`, `.blue` gibi erişimler yerine `.r`, `.g`, `.b` kullanılmalıdır:

```dart
// Eskisi:
final redComponent = myColor.red;

// Yenisi:
final redComponent = myColor.r;
```

### 3. Exception Yönetimi
Catch bloklarının belirli exception'ları belirtmesi gerekiyor:

```dart
// Eskisi:
try {
  // işlem
} catch (e) {
  // hata işleme
}

// Yenisi:
try {
  // işlem
} on FormatException catch (e) {
  // format exception işleme
} on IOException catch (e) {
  // IO exception işleme
} on Exception catch (e) {
  // genel exception işleme
}
```

### 4. Asenkron BuildContext Kullanımı
Asenkron operasyonlardan sonra BuildContext kullanırken mounted kontolü yapılmalıdır:

```dart
// Eskisi:
Future<void> someAsyncFunction() async {
  await someOperation();
  Navigator.of(context).push(...); // Tehlikeli
}

// Yenisi:
Future<void> someAsyncFunction() async {
  await someOperation();
  if (!mounted) return;
  Navigator.of(context).push(...); // Güvenli
}
```

### 5. Trailing Comma Kullanımı
Çok satırlı parametre listeleri, collection'lar, vb. için sonda virgül kullanın:

```dart
// Eskisi:
final list = [
  'item1',
  'item2'
];

// Yenisi:
final list = [
  'item1',
  'item2',
];
```

### 6. Constructor Sıralaması
Constructor'lar sınıfın en başında, diğer üyelerden önce tanımlanmalıdır:

```dart
class MyClass {
  // Önce constructor'lar
  MyClass();
  factory MyClass.fromJson() { ... }
  
  // Sonra değişkenler ve metodlar
  final String name;
  void doSomething() { ... }
}
```

### 7. Print Yerine Logger Kullanımı
Debug amaçlı print yerine logger kullanılmalıdır:

```dart
// Eskisi:
print('Hata oluştu: $e');

// Yenisi:
final _logger = Logger('ServiceName');
_logger.warning('Hata oluştu: $e');
```

Bu kılavuzda belirtilen düzeltmeler, Flutter ve Dart dilinin en güncel best-practice'lerine uygun olup, Dart 3.7+ için optimize edilmiştir.
