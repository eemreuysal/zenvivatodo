#!/bin/bash

# Bu betik, JSON serileştirme dosyalarını oluşturmak için build_runner kullanır

echo "JSON serileştirme dosyaları oluşturuluyor..."
flutter pub run build_runner build --delete-conflicting-outputs
echo "İşlem tamamlandı!"
