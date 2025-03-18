# ZenViva Todo Hata Düzeltme Rehberi

Bu rehber, ZenViva Todo projesinde tespit edilen hataları ve çözüm yöntemlerini içermektedir.

## 1. JSON Serializable Hataları

Projede model sınıfları için gerekli JSON serializable dosyaları eksik:

```
Target of URI hasn't been generated: 'package:zenvivatodo/models/task.g.dart'
```

veya 

```
The method 'fromJson' isn't defined for the type 'Task'
```

**Çözüm:**
1. `fix_issues.sh` scriptini çalıştırın:

```bash
chmod +x fix_issues.sh
./fix_issues.sh
```

Bu komut, model sınıflarınızı otomatik olarak tarayacak ve gerekli `.g.dart` dosyalarını oluşturacaktır.

## 2. ConnectivityService Hataları

`connectivity_plus` paketinin güncel versiyonunda, bağlantı durumu sorgulaması bir liste yerine tek bir `ConnectivityResult` döndürür:

```
The argument type 'List<ConnectivityResult>' can't be assigned to the parameter type 'ConnectivityResult'.
```

**Çözüm:**
ConnectivityService sınıfı güncellendi. Ana değişiklikler:
- `_updateConnectionStatusFromList` metodunun yerine `_updateConnectionStatus` kullanılması
- `checkConnectivity()` metodunun artık liste yerine tekil `ConnectivityResult` döndürmesi

## 3. Color API Uyarıları 

Flutter 3.28+ sürümünde `withOpacity` ve renk bileşenleri (red, green, blue, value) gibi API'lar kullanımdan kaldırılmıştır:

```
'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss.
```

**Çözüm:**
1. `lib/utils/color_extensions.dart` dosyası eklendi, bu dosya `withAlphaValue` uzantı metodunu içerir.
2. Eskiden `color.withOpacity(0.4)` yazdığınız yerde `color.withAlphaValue(0.4)` kullanabilirsiniz.

## 4. Exception Handling Sorunları

Hatalı catch blokları:

```
avoid_catches_without_on_clauses
```

**Çözüm:**
Genel exception yakalamak yerine, yakalanacak hata tiplerini belirtmek (örn: `on FormatException catch (e)`) veya en azından `on Exception catch (e)` şeklinde kullanım yapılmalıdır.

## 5. Gereksiz Null İşaretçileri

Bazı yerlerde gereksiz null check operatörleri (!) kullanılmış:

```
Unnecessary use of a null check ('!')
```

**Çözüm:**
Bu hatalar kullanıcı arayüzünde (özellikle dashboard_screen.dart) yer almakta. İlgili değişkenler zaten null olmadığı durumda kullanıldığı için "!" operatörüne gerek yoktur.

## 6. İmport Sıralaması Sorunları

```
directives_ordering
```

**Çözüm:**
İmport direktiflerini düzgün sıralamak gerekir:
1. dart: ile başlayan kütüphaneler
2. package: ile başlayan harici kütüphaneler
3. Rölatif yolla ithal edilen proje dosyaları (../models/ gibi)

## 7. build_runner Komutu

Gerekli düzenlemeleri yaptıktan sonra, JSON serializable için gerekli kodları oluşturmak için:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

Bu düzeltmeleri uyguladıktan sonra, projeyi tekrar derlemeyi ve lint kontrollerini çalıştırmayı unutmayın.
