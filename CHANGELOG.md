# ZenVivaTodo Değişiklik Günlüğü

Tüm önemli değişiklikler bu dosyada belgelenecektir.

## 1.1.0 - Mart 2025

### Eklenenler
- **API Servisi**: Dio HTTP istemcisi ile uzak sunuculara bağlanma desteği
- **JSON Serializable**: Model sınıfları için JSON serileştirme ve dönüştürme desteği
- **Çevrimiçi/Çevrimdışı Mod**: Kullanıcılar çevrimiçi veya çevrimdışı çalışmayı seçebilir
- **Veri Senkronizasyonu**: Çevrimdışı yapılan değişiklikler çevrimiçi olunca senkronize edilir
- **Bağlantı İzleme**: Internet bağlantısı durumunu görselleştiren bileşenler
- **Motivasyon İçeriği**: Günlük alıntılar ve aktivite önerileri
- **Bağlantı Durumu Göstergesi**: Internet bağlantı durumunu gösteren gösterge ve bildirimler

### Değiştirilenler
- **Model Sınıfları**: Tüm model sınıfları JSON serializable ile güncellendi
- **Dashboard Ekranı**: Çevrimiçi/çevrimdışı durum göstergeleri ve motivasyon içeriği eklendi
- **Veritabanı Servisi**: API servisiyle çalışacak şekilde güncellendi
- **README**: Yeni özelliklerin tanıtımı ve build_runner kurulum adımları eklendi

### Düzeltmeler
- Veritabanı sorgularında SQL enjeksiyon koruması iyileştirildi
- Veritabanı indekslemesi ile performans optimizasyonu yapıldı

## 1.0.0 - Ocak 2025

- İlk resmi sürüm
