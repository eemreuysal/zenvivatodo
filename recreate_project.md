# Projeyi Yeniden Oluşturma Talimatları

Aşağıdaki adımları izleyerek projeyi temiz bir şekilde yeniden oluşturabilirsiniz:

1. Öncelikle mevcut değişiklikleri `git pull` komutuyla alın.

2. Flutter sürümünüzü en güncel sürüme yükseltin:
```bash
flutter upgrade
```

3. Projeyi temizleyin:
```bash
flutter clean
```

4. Android ve iOS klasörlerini silin:
```bash
rm -rf android/
rm -rf ios/
```

5. Web klasörünü silin (yeni Web Wasm desteği için):
```bash
rm -rf web/
```

6. Flutter platformlarını yeniden oluşturun:
```bash
flutter create --platforms=android,ios,web .
```

7. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

8. Yeni Dart formatter ile kodları formatlayın:
```bash
dart format --output=write .
```

9. Projeyi çalıştırın:
```bash
flutter run
```

Bu adımlar, platformlara özgü klasörleri en güncel Flutter şablonlarıyla yeniden oluşturacak ve Gradle yapılandırma sorunlarını çözecektir.

## Yenilikler ve Değişiklikler

- Android SDK hedefleri güncellendi
- iOS minimum desteği iOS 12'ye yükseltildi
- Web platformu için Wasm desteği eklendi
- Dart formatter, Dart 3.7'nin yeni biçimlendirme stilini kullanacak

## Not

Yeni oluşturulan Android/iOS/Web dosyaları varsayılan yapılandırmalarla gelecektir. Eğer özel yapılandırmalarınız (uygulama kimlikleri, imza dosyaları vb.) varsa, bunları yeniden ayarlamanız gerekebilir.
