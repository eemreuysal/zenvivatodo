# Flutter 3.29 ve Dart 3.7 Güncelleme Notları

Bu belge, ZenVivatodo projesinin Flutter 3.29 ve Dart 3.7'ye güncellenmesi sırasında yapılan değişiklikleri içerir.

## Yapılan Güncellemeler

1. **Kullanımdan Kaldırılan Color API'leri Düzeltildi:**
   - `withOpacity()` -> `withValues(opacity: value)`
   - `Color.fromRGBO()` -> `Color.withValues(opacity: value)` veya doğrudan renk kullanımı
   - `color.red`, `color.green`, `color.blue` gibi kullanımlar kaldırıldı

2. **Dio API Değişiklikleri:**
   - `dio.decoder` kullanımı yerine doğrudan `jsonEncode/jsonDecode` kullanıldı
   - `dio.transformer.transformRequest()` yerine `jsonEncode()` kullanıldı

3. **Flutter Local Notifications Güncellemeleri:**
   - `onDidReceiveLocalNotification` parametresi kaldırıldı
   - Android izin isteme yöntemi değişti: `androidPlugin?.requestPermission()`
   - `uiLocalNotificationDateInterpretation` artık gerekli değil

4. **ConnectivityPlus Güncellemeleri:**
   - `ConnectivityResult` tipi için import eklendi
   - Stream ve liste tipleri uyumlu hale getirildi

5. **Dart 3.7 İyileştirmeleri:**
   - Wildcard değişkenler (`_`) için kullanılmayan değişken uyarıları düzeltildi
   - `catch` bloklarında hata tiplerini belirtmek için `on Exception` eklendi
   - Direktif sıralaması düzeltildi (imports sıralama)
   - Trailing commas eklendi

6. **Diğer Değişiklikler:**
   - `print()` yerine `Logger` kullanımı yaygınlaştırıldı
   - Constructor bildirimlerinin sınıf üyelerinden önce olması sağlandı

## Bir Sonraki Adımlar

Projeyi tam olarak çalışır hale getirmek için şu adımları izleyin:

1. **JSON Serileştirme Kodu Oluşturma (Tüm modeller için):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Paketleri Güncelleme:**
   ```bash
   flutter pub upgrade --major-versions
   ```

3. **Testleri Çalıştırma:**
   ```bash
   flutter test
   ```

4. **Uygulamayı Çalıştırma ve Test Etme:**
   ```bash
   flutter run
   ```

## Yeni Flutter 3.29 ve Dart 3.7 Özellikleri

### Flutter 3.29'un Öne Çıkan Özellikleri:
- Impeller artık iOS'ta varsayılan renderer
- Android'de Impeller desteği genişletildi
- Cupertino bileşenlerinde iyileştirmeler
- DevTools güncellemeleri
- Material 3 güncellemeleri

### Dart 3.7'nin Öne Çıkan Özellikleri:
- Wildcard değişkenler (`_`) artık değişken tanımlamaz
- Yeni dart formatter stili (trailing commas)
- Yeni linter kuralları ve hızlı düzeltmeler
- pub.dev için koyu tema desteği
- pub.dev paket indirme sayıları

## Ek Bilgiler

- [Flutter 3.29 Blog Post](https://medium.com/flutter/whats-new-in-flutter-3-29-f90c380c2317)
- [Dart 3.7 Blog Post](https://medium.com/dartlang/announcing-dart-3-7-bf864a1b195c)
- [Flutter Docs](https://docs.flutter.dev/)
