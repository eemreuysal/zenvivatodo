# Flutter 3.29 ve Dart 3.7 Güncelleme Kılavuzu

Bu belge, ZenVivatodo projesinin Flutter 3.29 ve Dart 3.7'ye güncellenme sürecinde yapılan değişiklikleri ve yeni özellikleri açıklar.

## Güncelleme İşlemleri

1. **Flutter SDK'yı Güncelleme**
   ```bash
   flutter upgrade
   flutter --version  # Flutter 3.29.x ve Dart 3.7.x sürümlerini göstermelidir
   ```

2. **Proje Bağımlılıklarını Güncelleme**
   ```bash
   flutter pub get
   ```

3. **JSON Serialization Modellerini Yeniden Oluşturma**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Tüm Kodları Yeni Formatter ile Formatlama**
   ```bash
   dart format lib/
   ```

## Eklenen Yeni Özellikler

### 1. Impeller Render Engine

Flutter 3.29 ile Impeller, hem iOS hem de Android platformları için varsayılan render motoru olmuştur. Bu değişiklik şu avantajları sağlar:

- Daha hızlı ve tutarlı animasyonlar
- Gelişmiş render performansı
- UI freezing (donma) sorunlarının azaltılması
- Shader derlemeleri nedeniyle ilk açılışta gecikmelerin azaltılması

**iOS için Impeller yapılandırması:**

`ios/Runner/Info.plist` içerisine aşağıdaki kod eklenmiştir:
```xml
<key>FLTEnableImpeller</key>
<true/>
```

**Android için Impeller yapılandırması:**

`android/app/src/main/AndroidManifest.xml` içerisine aşağıdaki kod eklenmiştir:
```xml
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="true" />
```

### 2. Dart 3.7 Yenilikleri

#### Wildcard Değişkenler

Dart 3.7 ile, `_` adlı parametreler ve yerel değişkenler artık "wildcard" olarak kabul edilir. Bu, aslında bir değişken oluşturmaz ve sadece bir yer tutucu görevi görür. Örneğin:

```dart
// Eski kullanım
future.then((_) {
  print('İşlem tamamlandı');
});

// Yeni kullanım - Birden çok _ kullanabilirsiniz
future.onError((_, _) {
  print('Hata oluştu');
});
```

Kodunuzu kontrol edin ve `_` değişkenlerini kullandığınız yerler varsa, bu değişkenlerin içeriğine erişmiyorsanız herhangi bir değişiklik yapmanıza gerek yoktur. Ancak `_` adlı bir parametreyi veya değişkeni kullanıyorsanız, bu durumda değişkeni başka bir adla yeniden adlandırmanız gerekecektir.

#### Yeni Formatter Stili

Dart 3.7 yeni bir formatter stili getirmiştir. Bu stil, argüman listelerinde sonda virgül (trailing comma) kullanımını otomatik olarak ekler ve daha tutarlı bir format sağlar. Yeni stil aşağıdaki avantajları sunar:

- Daha tutarlı kod formatı
- Daha okunabilir parametre listeleri
- Git diff'lerde daha az satır değişikliği

`analysis_options.yaml` dosyasına sayfa genişliği ayarı eklenmiştir:
```yaml
formatter:
  page_width: 100
```

### 3. Flutter 3.29'daki Yeni Özellikler

Flutter 3.29 ile gelen diğer önemli özellikler:

- **DevTools İyileştirmeleri**: Debugging ve performans analizi için gelişmiş araçlar
- **Material 3 Geliştirmeleri**: Material tasarım komponentleri için iyileştirmeler
- **Web Performans İyileştirmeleri**: Web platformunda daha iyi performans
- **Flutter AI Toolkit Desteği**: Yapay zeka entegrasyonu için toolkit
- **WebAssembly (Wasm) İyileştirmeleri**: Web platformu için gelişmiş destek

## Bilinmesi Gereken Değişiklikler

1. **API Değişiklikleri**:
   - Bazı eski Flutter web API'leri (dart:html, dart:js gibi) kullanımdan kaldırılmaktadır. Bunun yerine `dart:js_interop` ve `package:web` kullanılması önerilir.

2. **ColorAPI Değişiklikleri**:
   - `withOpacity()` -> `withValues(opacity: value)`
   - `Color.fromRGBO()` -> `Color.withValues(opacity: value)` veya doğrudan renk kullanımı
   - `color.red`, `color.green`, `color.blue` gibi kullanımların yerine yeni yöntemler kullanılmalıdır

3. **Flutter Local Notifications Değişiklikleri**:
   - İzin isteme yöntemi güncellenmiştir: `androidPlugin?.requestPermission()`

## Test Etme

Tüm güncellemeler tamamlandıktan sonra, uygulamanın doğru çalıştığından emin olmak için aşağıdaki testleri yapın:

1. **Temel Fonksiyonel Testler**:
   ```bash
   flutter test
   ```

2. **Manuel UI Testleri**:
   - Uygulama ara yüzünü test edin ve animasyonların, geçişlerin eskisinden daha iyi çalıştığını doğrulayın
   - Impeller'ın etkisini görmek için karmaşık UI komponentleri ve animasyonlara sahip sayfalarda performansı kontrol edin

3. **Çevrimiçi/Çevrimdışı Senkronizasyon Testleri**:
   - İnternet bağlantısını keserek çevrimdışı modun çalıştığını doğrulayın
   - Bağlantıyı yeniden sağlayarak senkronizasyonun düzgün çalıştığını kontrol edin

## Sorun Giderme

Güncelleme sırasında aşağıdaki yaygın sorunlarla karşılaşabilirsiniz:

1. **Bağımlılık Sorunları**: Uyumsuz paketler için pub outdated komutunu kullanarak güncel paketleri kontrol edin
   ```bash
   flutter pub outdated
   ```

2. **Derleyici Hataları**: Genellikle API değişiklikleri nedeniyle ortaya çıkar. Hata mesajlarını dikkatlice okuyun ve ilgili dokümantasyona başvurun.

3. **Impeller Sorunları**: Impeller'ın beklendiği gibi çalışmaması durumunda, bunu devre dışı bırakabilirsiniz. Ancak ideal olarak sorunun kaynağını bulmak ve düzeltmek daha iyidir.

## Ek Kaynaklar

- [Flutter 3.29 Blog Gönderisi](https://medium.com/flutter/whats-new-in-flutter-3-29-f90c380c2317)
- [Dart 3.7 Blog Gönderisi](https://medium.com/dartlang/announcing-dart-3-7-bf864a1b195c)
- [Flutter Dokümantasyonu](https://docs.flutter.dev/)
- [Dart Dokümantasyonu](https://dart.dev/guides)
- [Impeller Hakkında Bilgi](https://docs.flutter.dev/perf/impeller)
