#!/bin/bash

# Flutter paketlerini güncelleme
echo "Flutter paketleri güncelleniyor..."
flutter pub get

# Oluşturulmuş dosyaları temizleme
echo "Önceki oluşturulmuş dosyalar temizleniyor..."
flutter pub run build_runner clean

# JSON serializable için dosyaları oluşturma
echo "Model sınıfları için JSON serializable dosyaları oluşturuluyor..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "İşlem tamamlandı!"
