# ZenViva Todo

Sağlıklı ve Düzenli Bir Yaşam için To-Do Uygulaması

## Özellikler

- **Görev Yönetimi**: Görevleri oluşturma, düzenleme ve silme
- **Kategori Desteği**: Görevleri farklı kategorilere ayırma
- **Öncelik Seviyeleri**: Görevleri önceliklerine göre sınıflandırma
- **Tamamlanmış ve Aktif Görevler**: Görevleri durumlarına göre ayrı ekranlarda görüntüleme
- **Görev Hatırlatmaları**: Görev saatinden 5 dakika önce otomatik bildirim gönderme
- **Türkçe Dil Desteği**: Tamamen Türkçe arayüz
- **Açık/Koyu Tema**: Tercih edilen tema seçeneği
- **Alışkanlık Takibi**: Düzenli alışkanlıkları oluşturma ve takip etme
- **Güvenli Kimlik Doğrulama**: Gelişmiş şifre hashleme ile kullanıcı güvenliği

## Kurulum

1. Flutter SDK'yı yükleyin (https://flutter.dev/docs/get-started/install)
2. Projeyi klonlayın: `git clone https://github.com/eemreuysal/zenvivatodo.git`
3. Bağımlılıkları yükleyin: `flutter pub get`
4. Uygulamayı çalıştırın: `flutter run`

## Son Güncellemeler (Mart 2025)

- **Güvenlik İyileştirmeleri**: Şifre hashleme algoritmalarında daha güçlü bir hashleme yöntemi kullanılmaya başlandı
- **Veritabanı Optimizasyonu**: Performans iyileştirmeleri ve indekslemeler eklendi
- **Hata Yönetimi**: Bildirim servisi ve veritabanı işlemlerinde daha iyi hata yönetimi
- **SQL Enjeksiyon Koruması**: Tüm sorgulamalar güvenli şekilde parametrize edildi
- **Bellek Optimizasyonu**: Büyük listelerde ve veritabanı sorgularında daha verimli işlemler

## Teknik Özellikler

- Flutter 3.19+ desteği
- Android API 23+ (Android 6.0 Marshmallow ve üzeri) desteği
- Modern Dart kodlama uygulamaları (null safety, super parameters)
- ProGuard entegrasyonu ile optimize edilmiş APK boyutu
- Veritabanı indekslemesi ile yüksek performans

## Kullanılan Teknolojiler

- **Flutter**: UI geliştirme
- **SQLite**: Yerel veritabanı desteği
- **Provider**: Durum yönetimi
- **Shared Preferences**: Kullanıcı tercihleri depolama
- **Flutter Local Notifications**: Görev bildirimleri için

## Bildirim Sistemi

Uygulama, görev saatinden 5 dakika önce otomatik olarak bildirim göndermek için yerel bildirim sistemini kullanır. Bildirimleri kullanmak için:

1. Görev eklerken veya düzenlerken, görev saatini belirtin
2. Uygulama otomatik olarak, görev saatinden 5 dakika önce bir bildirim programlayacaktır
3. Görev tamamlandığında veya silindiğinde, ilgili bildirimler otomatik olarak iptal edilir

## Veritabanı Mimarisi

Uygulama yerel SQLite veritabanı kullanmaktadır ve aşağıdaki tablolar bulunur:

- **users**: Kullanıcı hesapları
- **tasks**: Görevler
- **categories**: Görev kategorileri
- **habits**: Alışkanlıklar
- **habit_logs**: Alışkanlık takip kayıtları
- **task_tags**: Görev etiketleri
- **task_tag_relations**: Görev-etiket ilişkileri

Performans optimizasyonu için kritik alanlarda indeksler tanımlanmıştır.

## Geliştiriciler İçin

- Kodlar modern Dart yazım kurallarına göre düzenlenmiştir
- 'super parameters' kullanılarak constructor'lar optimize edilmiştir
- Lint kuralları sıkı tutularak kod kalitesi yüksek tutulmuştur
- Proje tüm modern Android sürümlerinde çalışacak şekilde yapılandırılmıştır
- Veritabanı sorguları optimize edilmiş ve SQL enjeksiyon saldırılarına karşı korunmalıdır

## İletişim

Herhangi bir soru veya öneriniz için lütfen eemreuysal@gmail.com adresine e-posta gönderin.
