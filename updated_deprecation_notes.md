# Kaldırılan ve Güncellenen Dosyaların Dökümantasyonu

Bu belge, proje güncellemesi sırasında yapılan değişiklikleri ve kaldırılan dosyaları belgelemektedir.

## Kaldırılan Dosyalar

### 1. pubspec.yaml.bak

- **Neden Kaldırıldı**: Bu dosya, eski bir yedek dosyasıydı ve Dart 2.19.0 referansları içeriyordu. Proje, Dart 3.7 ve Flutter 3.29'u kullandığından artık bu dosyaya ihtiyaç yoktur.

### 2. update_super_params.dart

- **Neden Kaldırıldı**: Bu dosya, Dart 2.17 ile gelen super parameters özelliğini projeye entegre etmek için kullanılan bir yardımcı araçtı. Proje, Dart 3.7'yi kullandığından ve super parameters özelliği zaten yaygın olarak kullanıldığından, bu dosya artık gereksizdi.

## Güncellenen Dosyalar

### 1. recreate_project.md

- **Yapılan Değişiklikler**: 
  - Flutter upgrade komutu eklendi
  - Web klasörünün yeniden oluşturulması için adım eklendi
  - Wasm desteği hakkında bilgi eklendi
  - Yeni Dart formatter kullanımı için komut eklendi

### 2. web/index.html

- **Yapılan Değişiklikler**:
  - WebAssembly desteği için JavaScript yardımcı fonksiyonları eklendi
  - Daha açıklayıcı içerik ve açıklamalar eklendi
  - Sayfa açıklaması Türkçe'ye çevrildi

### 3. lib/constants/app_theme.dart

- **Yapılan Değişiklikler**:
  - Flutter 3.29 ile gelen yeni Material 3 özelliklerini desteklemek için güncellendi
  - Yeni `year2023: false` parametresi eklenerek en son Material 3 stilini kullanacak şekilde ayarlandı
  - Yeni `FadeForwardsPageTransitionsBuilder` kullanılarak Android geçiş animasyonları güncellendi

## Gelecek Güncellemeler İçin Notlar

1. **Cupertino Bileşenleri**: Tüm Cupertino bileşenleri, Flutter 3.29'daki CupertinoNavigationBar ve CupertinoSheetRoute gibi yeni özellikleri kullanacak şekilde güncellenmelidir.

2. **Web Desteği**: Web desteği için, dart:html ve dart:js gibi kullanımdan kaldırılan API'ler yerine dart:js_interop ve package:web kullanılmalıdır.

3. **Dart Formatter**: Projenin Dart 3.7'nin yeni biçimlendirme stilini kullanması için, projenin tamamında `dart format` çalıştırılmalıdır.
