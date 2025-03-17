// Bu script, projedeki tüm widget sınıflarında super parametre güncellemeleri yapmak için
// bir referans olarak oluşturulmuştur.
//
// Bu dosyayı çalıştırmak yerine, aşağıdaki terminal komutunu kullanabilirsiniz:
//
// find lib -name "*.dart" -type f -exec sed -i '' -e 's/{\\([ ]*\\)Key?\\([ ]*\\)key,/{\\1super.key,/g' {} \\;
//
// Bu komut, tüm dart dosyalarında constructorları otomatik olarak güncelleyecektir.
// 
// İşte elle yapacağınız değişiklik örnekleri:
//
// Eski:
// const MyWidget({Key? key, required this.param}) : super(key: key);
//
// Yeni:
// const MyWidget({super.key, required this.param});
//
// Bu değişiklik, Dart 2.17 ve sonrası için daha modern bir yazım şeklidir ve 
// aynı fonksiyonelliği sürdürür, sadece daha az kod ile.

import 'package:flutter/foundation.dart';

void main() {
  debugPrint('Bu script çalıştırılmak için değil, referans amaçlıdır.');
  debugPrint('Super parameter güncellemeleri için dosyaları manuel olarak düzenleyin veya yukarıdaki terminal komutunu kullanın.');
}