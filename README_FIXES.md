# ZenViva Todo - Hata Düzeltmeleri Rehberi

Bu dosya, projede tespit edilen hataları ve çözümlerini içermektedir.

## Temel Sorunlar ve Çözümleri

### 1. JSON Serialization Sorunları

Projedeki en önemli sorunlardan biri, JSON serialization için gerekli `.g.dart` dosyalarının oluşturulmamış olmasıydı. Bu sorunun çözümü için aşağıdaki komutu çalıştırın:

```bash
# Proje klasöründe çalıştırın
flutter pub run build_runner build --delete-conflicting-outputs
```

Bu komut, model sınıflarından `.g.dart` dosyalarını oluşturacaktır.

### 2. Connectivity Servisi Sorunları

`connectivity_plus` paketinin son sürümünde API değişiklikleri olmuştur. Özellikle `onConnectivityChanged` artık bir `ConnectivityResult` yerine `List<ConnectivityResult>` döndürmektedir. Çözüm için:

- `_handleConnectivityChange` metodunu liste tipini işleyecek şekilde güncelleyin
- Gerekli yerlerde `import 'package:connectivity_plus/connectivity_plus.dart';` ekleyin

### 3. Trailing Comma Sorunları

Projedeki lint kurallarına göre, listelerin ve argumentlerin sonunda virgül (trailing comma) olması gerekiyor. Bu hataları düzeltmek için:

- Linter tarafından bildirilen tüm yerlere trailing comma ekleyin

### 4. Deprecation Uyarıları

Flutter'ın son sürümlerinde bazı API'ler kullanımdan kaldırılmıştır, özellikle Color sınıfı ile ilgili olanlar:

- `Color.withOpacity()` yerine `Color.withAlpha()` veya `Color.withValues()` kullanın
- `Color.red`, `Color.green`, `Color.blue` yerine `Color.r`, `Color.g`, `Color.b` kullanın

### 5. Catch Bloklarındaki Sorunlar

- `catch (e)` yerine `on SpecificException catch (e)` kullanılması öneriliyor
- Kullanılmayan `e` parametreleri için `on Exception catch (_)` şeklinde güncelleme yapın

### 6. BuildContext Kullanımı

Asenkron işlemler sonrasında BuildContext kullanımı hatalara neden olabilir:

- Asenkron metotlarda `mounted` kontrolü ekleyin:
```dart
if (mounted) {
  // BuildContext kullanımı
}
```

### 7. Kullanılmayan İmportlar ve Değişkenler

Projede kullanılmayan importlar ve değişkenler temizlenmelidir:

- Linter'ın belirttiği unused import uyarılarını düzeltin
- Kullanılmayan sınıf değişkenlerini kaldırın veya kullanın

## Genel Düzeltme Yaklaşımı

1. Öncelikle JSON serialization sorununu çözün
2. Connectivity servisini güncelleyin
3. Lint kurallarına göre kod formatını düzeltin
4. API kullanımı ile ilgili uyarıları giderin

Bu düzeltmelerden sonra proje hatasız çalışacaktır.
