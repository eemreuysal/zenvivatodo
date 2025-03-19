#!/bin/bash
# Dart 3.7 wildcard değişken kontrolü için yardımcı script

# Renk tanımlamaları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Dart 3.7 Wildcard Değişken Kontrolü${NC}"
echo -e "${BLUE}====================================${NC}"
echo -e "${YELLOW}Dart 3.7'de _ adlı değişkenler artık 'wildcard' olarak değerlendirilir${NC}"
echo -e "${YELLOW}ve erişilemez. Bu script, projenizdeki potansiyel sorunları bulmaya yardımcı olur.${NC}"
echo -e ""

# lib dizinindeki tüm Dart dosyalarını ara
echo -e "${YELLOW}Tek başına _ parametresi kullanan dosyalar kontrol ediliyor...${NC}"
SINGLE_UNDERSCORES=$(grep -r "\b_\b" --include="*.dart" lib/)

if [ -z "$SINGLE_UNDERSCORES" ]; then
  echo -e "${GREEN}Tek başına _ parametresi bulunamadı.${NC}"
else
  echo -e "${RED}Potansiyel sorun: Tek başına _ parametresi bulunan dosyalar:${NC}"
  echo "$SINGLE_UNDERSCORES"
  echo -e ""
fi

# _ parametresine erişen yerleri kontrol et
echo -e "${YELLOW}_ parametresine erişen dosyalar kontrol ediliyor...${NC}"
UNDERSCORES_ACCESS=$(grep -r "\b_\.[a-zA-Z]" --include="*.dart" lib/)

if [ -z "$UNDERSCORES_ACCESS" ]; then
  echo -e "${GREEN}_ parametresine erişen kod bulunamadı.${NC}"
else
  echo -e "${RED}Potansiyel sorun: _ parametresine erişen dosyalar:${NC}"
  echo "$UNDERSCORES_ACCESS"
  echo -e ""
fi

# Callback'lerde _ parametresi kontrolü
echo -e "${YELLOW}Callback fonksiyonlarında _ parametresi kontrol ediliyor...${NC}"
CALLBACK_UNDERSCORES=$(grep -r "=>\s*{" --include="*.dart" lib/ | grep -E "\(_\)")

if [ -z "$CALLBACK_UNDERSCORES" ]; then
  echo -e "${GREEN}Callback'lerde _ parametresi kullanımında potansiyel sorun bulunamadı.${NC}"
else
  echo -e "${YELLOW}İncelenmesi gereken callback'ler (sorun olmayabilir):${NC}"
  echo "$CALLBACK_UNDERSCORES"
  echo -e ""
fi

# Özellikle dikkate alınması gereken yaygın callback'ler
echo -e "${YELLOW}Yaygın callback kalıpları kontrol ediliyor...${NC}"
COMMON_CALLBACKS=$(grep -r -E "(then|forEach|map|onError)\s*\(\s*_\s*\)" --include="*.dart" lib/)

if [ -z "$COMMON_CALLBACKS" ]; then
  echo -e "${GREEN}Yaygın callback'lerde _ parametresi kullanımında sorun bulunamadı.${NC}"
else
  echo -e "${RED}Potansiyel sorun: Yaygın callback'lerde _ parametresi:${NC}"
  echo "$COMMON_CALLBACKS"
  echo -e ""
fi

# Genel Değerlendirme
echo -e "${BLUE}====================================${NC}"
echo -e "${YELLOW}Değerlendirme:${NC}"
echo -e "${YELLOW}1. Eğer _ parametresi sadece bir yer tutucu (placeholder) olarak kullanılıyorsa,${NC}"
echo -e "${YELLOW}   muhtemelen sorun olmayacaktır.${NC}"
echo -e "${YELLOW}2. Eğer _ parametresine erişim yapıyorsanız, değişkeni başka bir isim ile değiştirin.${NC}"
echo -e "${YELLOW}3. Aşağıdaki örnek gibi kod bölümleri Dart 3.7'de çalışmayacaktır:${NC}"
echo -e ""
echo -e "${RED}someList.forEach((_) {${NC}"
echo -e "${RED}  print(_); // HATA! _ bir değişken değil${NC}"
echo -e "${RED}});${NC}"
echo -e ""
echo -e "${GREEN}Düzeltilmiş versiyon:${NC}"
echo -e "${GREEN}someList.forEach((item) {${NC}"
echo -e "${GREEN}  print(item); // Çalışacaktır${NC}"
echo -e "${GREEN}});${NC}"
echo -e ""
echo -e "${BLUE}====================================${NC}"
echo -e "${GREEN}Kontrol tamamlandı.${NC}"
