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
- **Çevrimiçi/Çevrimdışı Mod**: İnternet bağlantısı olmadığında bile çalışır
- **Veri Senkronizasyonu**: Çevrimdışı yapılan değişiklikler internet bağlantısı sağlandığında otomatik senkronize olur
- **Motivasyon Alıntıları**: İlham verici günlük alıntılar
- **Aktivite Önerileri**: Farklı kategorilerde aktivite önerileri

## Kurulum

1. Flutter SDK'yı yükleyin (https://flutter.dev/docs/get-started/install)
2. Projeyi klonlayın: `git clone https://github.com/eemreuysal/zenvivatodo.git`
3. Bağımlılıkları yükleyin: `flutter pub get`
4. Gerekli kodu oluşturun: `flutter pub run build_runner build --delete-conflicting-outputs`
5. Uygulamayı çalıştırın: `flutter run`

## Son Güncellemeler (Mart 2025)

- **Flutter 3.29 Uyumluluğu**: En son Flutter sürümü 3.29 ile uyumlu olarak güncellendi
- **Impeller Render Engine**: iOS ve Android için Impeller render engine desteği eklendi
- **Dart 3.7 Formatter**: Yeni Dart 3.7 formatter stili ve wildcard değişken desteği eklendi
- **Çevrimiçi/Çevrimdışı Senkronizasyon**: API servisleri ve çevrimiçi veri senkronizasyonu eklendi
- **İlham Verici İçerik**: Günlük motivasyon alıntıları ve aktivite önerileri eklendi
- **Bağlantı Yönetimi**: İnternet bağlantısı durumu ve çevrimiçi/çevrimdışı mod seçeneği eklendi
- **JSON Serializable Entegrasyonu**: API iletişimi için model sınıfları Json serialization desteği ile güncellendi
- **Güvenlik İyileştirmeleri**: Şifre hashleme algoritmalarında daha güçlü bir hashleme yöntemi kullanılmaya başlandı
- **Veritabanı Optimizasyonu**: Performans iyileştirmeleri ve indekslemeler eklendi
- **Hata Yönetimi**: Bildirim servisi ve veritabanı işlemlerinde daha iyi hata yönetimi
- **SQL Enjeksiyon Koruması**: Tüm sorgulamalar güvenli şekilde parametrize edildi
- **Bellek Optimizasyonu**: Büyük listelerde ve veritabanı sorgularında daha verimli işlemler

## Teknik Özellikler

- **Flutter 3.29 desteği** (Mart 2025 güncellemesi)
- **Impeller Render Engine** ile gelişmiş performans ve görsel tutarlılık
- Android API 23+ (Android 6.0 Marshmallow ve üzeri) desteği
- Modern Dart 3.7 kodlama uygulamaları (null safety, super parameters, wildcard variables)
- ProGuard entegrasyonu ile optimize edilmiş APK boyutu
- Veritabanı indekslemesi ile yüksek performans
- JSON serializable ile model sınıfları
- Dio HTTP istemcisi ile API iletişimi
- Çevrimiçi/çevrimdışı senkronizasyon

## Kullanılan Teknolojiler

- **Flutter**: UI geliştirme (3.29+)
- **Dart**: Programlama dili (3.7+)
- **Impeller**: Render engine 
- **SQLite**: Yerel veritabanı desteği
- **Provider**: Durum yönetimi
- **Shared Preferences**: Kullanıcı tercihleri depolama
- **Flutter Local Notifications**: Görev bildirimleri için
- **Dio**: API istekleri
- **JSON Serializable**: JSON veri dönüşümü
- **Connectivity Plus**: İnternet bağlantısı kontrolü

## Çevrimiçi/Çevrimdışı Mod

Uygulama hem çevrimiçi hem de çevrimdışı modda çalışabilir:

1. **Çevrimiçi Mod**: İnternet bağlantısı varken verileri API ile senkronize eder
2. **Çevrimdışı Mod**: İnternet bağlantısı olmadığında yerel veritabanını kullanır
3. **Arka Plan Senkronizasyonu**: Bağlantı tekrar sağlandığında otomatik olarak verileri senkronize eder
4. **Manuel Çevrimiçi/Çevrimdışı Geçiş**: Kullanıcı tercih ettiği modu seçebilir

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

- Kodlar modern Dart 3.7 yazım kurallarına göre düzenlenmiştir
- 'super parameters' kullanılarak constructor'lar optimize edilmiştir
- Wildcard değişkenler (`_`) kullanımı Dart 3.7 ile uyumlu şekilde güncellenmiştir
- Lint kuralları sıkı tutularak kod kalitesi yüksek tutulmuştur
- Proje tüm modern Android sürümlerinde çalışacak şekilde yapılandırılmıştır
- Impeller render engine desteği hem Android hem iOS platformlarında etkinleştirilmiştir
- Veritabanı sorguları optimize edilmiş ve SQL enjeksiyon saldırılarına karşı korunmalıdır
- JSON serialization için build_runner kullanılmıştır

### Build Runner Kullanımı

JSON serializable ile oluşturulan model sınıfları için gerekli kodu oluşturmak için:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

veya sürekli izleme modu için:

```
flutter pub run build_runner watch --delete-conflicting-outputs
```

## İletişim

Herhangi bir soru veya öneriniz için lütfen eemreuysal@gmail.com adresine e-posta gönderin.
