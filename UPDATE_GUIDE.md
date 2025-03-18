# ZenViva Todo - Güncelleme Rehberi

Bu rehber, ZenViva Todo uygulamasında yapılan güncellemeleri ve çözülen sorunları açıklar.

## Yapılan Güncellemeler

### 1. JSON Serileştirme Sorunları

- `task.dart` dosyasındaki JSON serileştirme sorunları düzeltildi.
- Deprecated olan `ignore` parametresi yerine `includeFromJson: false, includeToJson: false` kullanıldı.
- JSON serileştirme dosyaları oluşturmak için `generate_models.sh` betiği eklendi.

```sh
# JSON serileştirme dosyalarını oluşturmak için:
chmod +x generate_models.sh
./generate_models.sh
```

### 2. ConnectivityPlus API Değişiklikleri

- `connectivity_plus` paketinin güncel API'sine uyum sağlandı.
- `onConnectivityChanged` artık `List<ConnectivityResult>` döndürdüğü için gerekli düzenlemeler yapıldı.
- Bağlantı durumunun tespiti için yeni metotlar eklendi.

### 3. Color API Değişiklikleri

- Deprecated olan `withOpacity` metodu yerine `withValues(alpha: value)` kullanıldı.
- Deprecated olan `value`, `red`, `green`, `blue` özellikleri yerine `.r`, `.g`, `.b` kullanımı için güncellendi.

### 4. Diğer İyileştirmeler

- Sorumluluğu tek bir metoda verilmesi gereken constructorların sıralaması düzeltildi (`sort_constructors_first`).
- Sınıf üyeleri ve metotları daha okunabilir bir şekilde yeniden düzenlendi.
- Hata yakalama blokları için `on` ifadesi ile spesifik hata tipleri belirtildi (`avoid_catches_without_on_clauses`).
- `print` kullanımı yerine `Logger` kullanıldı.
- Import sıralaması düzeltildi (`directives_ordering`).

## İzlenecek Adımlar

1. Kod tabanınıza uyguladığımız değişiklikleri alın.
2. JSON serileştirme dosyalarını oluşturmak için `generate_models.sh` betiğini çalıştırın.
3. Uygulamayı yeniden derleyin ve test edin.

## Not

Flutter 3.27+ sürümünde birçok API değişikliği olduğu için, kütüphanelerin ve Flutter SDK'nın en son sürümlerini kullanmanız önerilir. Bu, gelecekteki güncellemelerin daha sorunsuz ilerlemesini sağlayacaktır.
