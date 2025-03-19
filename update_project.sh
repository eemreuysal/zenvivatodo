#!/bin/bash
# ZenVivaTodo Flutter 3.29 ve Dart 3.7 Güncelleme Script'i

# Renk tanımlamaları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}ZenViva Todo Güncelleme İşlemi${NC}"
echo -e "${BLUE}================================${NC}"

# Flutter SDK'yı güncelleme
echo -e "${YELLOW}Flutter SDK güncelleniyor...${NC}"
flutter upgrade
if [ $? -ne 0 ]; then
  echo -e "${RED}Flutter SDK güncellemesinde hata oluştu${NC}"
  exit 1
fi
echo -e "${GREEN}Flutter SDK başarıyla güncellendi${NC}"

# Flutter sürüm ve kanal bilgisi
echo -e "${YELLOW}Flutter sürüm bilgisi:${NC}"
flutter --version

# Dart pub paketi temizleme
echo -e "${YELLOW}Paket önbelleği temizleniyor...${NC}"
flutter pub cache clean
if [ $? -ne 0 ]; then
  echo -e "${RED}Paket önbelleği temizlenirken hata oluştu${NC}"
fi

# Bağımlılıkları yükleme
echo -e "${YELLOW}Bağımlılıklar yükleniyor...${NC}"
flutter pub get
if [ $? -ne 0 ]; then
  echo -e "${RED}Bağımlılıklar yüklenirken hata oluştu${NC}"
  exit 1
fi
echo -e "${GREEN}Bağımlılıklar başarıyla yüklendi${NC}"

# Eskimiş paketleri kontrol etme
echo -e "${YELLOW}Eskimiş paketler kontrol ediliyor...${NC}"
flutter pub outdated

# JSON serialization için kod oluşturma
echo -e "${YELLOW}JSON serialization kodları oluşturuluyor...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs
if [ $? -ne 0 ]; then
  echo -e "${RED}JSON serialization kodları oluşturulurken hata oluştu${NC}"
  exit 1
fi
echo -e "${GREEN}JSON serialization kodları başarıyla oluşturuldu${NC}"

# Kodu formatlama
echo -e "${YELLOW}Kod formatlanıyor...${NC}"
dart format lib/
if [ $? -ne 0 ]; then
  echo -e "${RED}Kod formatlanırken hata oluştu${NC}"
  exit 1
fi
echo -e "${GREEN}Kod başarıyla formatlandı${NC}"

# Kod analizi
echo -e "${YELLOW}Kod analizi yapılıyor...${NC}"
flutter analyze
if [ $? -ne 0 ]; then
  echo -e "${YELLOW}Kod analizinde uyarılar bulundu, lütfen kontrol edin${NC}"
else
  echo -e "${GREEN}Kod analizi başarıyla tamamlandı${NC}"
fi

# Wildcard değişken uyarısı
echo -e "${YELLOW}NOT: Dart 3.7 ile wildcard değişken (_) kullanımı değişti${NC}"
echo -e "${YELLOW}Kodunuzda _ ile tanımlanmış değişkenlere erişiyorsanız,${NC}"
echo -e "${YELLOW}bunları farklı bir isimle yeniden adlandırmanız gerekebilir.${NC}"

echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}ZenViva Todo güncelleme işlemi tamamlandı!${NC}"
echo -e "${BLUE}================================${NC}"

# İsterseniz uygulamayı çalıştırın
read -p "Uygulamayı şimdi çalıştırmak ister misiniz? (e/h): " choice
if [[ "$choice" =~ ^[Ee]$ ]]; then
  echo -e "${YELLOW}Uygulama başlatılıyor...${NC}"
  flutter run
fi
