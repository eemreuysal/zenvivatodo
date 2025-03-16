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

## Kurulum

1. Flutter SDK'yı yükleyin (https://flutter.dev/docs/get-started/install)
2. Projeyi klonlayın: `git clone https://github.com/eemreuysal/zenvivatodo.git`
3. Bağımlılıkları yükleyin: `flutter pub get`
4. Uygulamayı çalıştırın: `flutter run`

## Teknik Özellikler

- Flutter 3.19+ desteği
- Android API 23+ (Android 6.0 Marshmallow ve üzeri) desteği
- Modern Dart kodlama uygulamaları (null safety, super parameters)
- ProGuard entegrasyonu ile optimize edilmiş APK boyutu

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

## Geliştiriciler İçin

- Kodlar modern Dart yazım kurallarına göre düzenlenmiştir
- 'super parameters' kullanılarak constructor'lar optimize edilmiştir
- Lint kuralları sıkı tutularak kod kalitesi yüksek tutulmuştur
- Proje tüm modern Android sürümlerinde çalışacak şekilde yapılandırılmıştır

## İletişim

Herhangi bir soru veya öneriniz için lütfen eemreuysal@gmail.com adresine e-posta gönderin.
