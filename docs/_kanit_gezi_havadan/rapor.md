# İstanbul v2 — HAVADAN gezi denetimi (bölge `havadan`)

Dal `wip/gezi-havadan`; sonda `tests/_ist/gezi_havadan.gd/.tscn` (yalnız test; oyun kodu değişmedi). Taban `wip/ist2-gezi-taban`. Kare: yazılımla çizim (llvmpipe, 1280×720; sürekli uçuş 640×360).

## 1) Bölge, sayılar

- Bölge: bütün şehir havadan. Kamera yelpazesi (gerçek m, doğu/kuzey): doğu -5148…-3, kuzey -1705…3478. Dört köşe ≈ (-5148,-1705) Mermer Kule/Marmara · (-5148,3478) Haliç ucu/Blakherna · (-3,3478) Galata-Sarayburnu · (-3,-1705) Marmara doğu ucu.
- Çekilen kare: **264** (klasör başına: eser=96, kara=168). Bakılan kare (paftada açıp incelediğim): **112**. Bakmadığım kareler aşağıda "bakamadıklarım".
- Yöntem: dört tur (kara surları boyu, Marmara kıyısı, Haliç+Galata, Mese) ve ordugâh üstü: 30/60/120 m, ileri (−12°) + aşağı (−45°); adım **80 dünya m** (görevdeki 40 m yerine; yazılımla çizimde kare başına ≈3 sn, süre yetmedi). Eserler: flight_data_v2 yer işaretlerinin tamamı (39 landmark + 34 konma
), 150/80/40/15 m yaklaşma + konma noktasından 4 yön. Sürekli uçuş: 18 m/sn, sabit dt=1/60 sn, 640×360.
- Yürüyüş km: bu bölgede yürüyüş yok (yalnız uçuş).

## 2) **GENEL NOT: 5/10 (ara rapor).** Sahibi havadan bakınca ilk olarak sur kulelerinin dev, tek renk mor-kahve levha çatılarına ve sur dibindeki çıplak yeşil çayıra kızar. Konma noktalarından üçünde (Konstantin Sütunu, Romanos kulesi, Blakherna) kamera gövdenin içinde kalıp ekran siyah çıkıyor: oyuncunun inince göreceği ilk şey siyah ekran. Şehrin geneli, Ayasofya/Hipodrom/Bozdoğan gibi eserler 150 m'den iyi tanınıyor; yakından zemin yamaları ve oyuncak ağaç/çalılar bozuyor.

## 3) BULGU TABLOSU

| no | tür | önem | yer adı | doğu, kuzey | kare dosyası | ne görünüyor | kaynak | öneri |
|---|---|---|---|---|---|---|---|---|
| H01 | KUTU | 2 | Kara surları kule çatıları (güney yarı) | -4875, -1705 | kare/kara_000_asagi_030.jpg | Kule çatısı tek renk mor-kahve devasa piramit levha; kare yarısını örtüyor, yukarıdan "kutu + levha çatı" (biliniyor, yine de uçuşta en baskın nesne) | scripts/world/ist/surlar.gd:_inner_tower (cati) | Çatıyı küçült/eğimli kiremit dokusu ve saçak kıvrımı; ya da kulelerin çoğunu açık platform yap |
| H02 | KUTU | 2 | Kara surları sur üstü | -4940, -1520 | kare/kara_001_asagi_030.jpg | Sur yürüme yolunda düz kırmızı KÜP (dokusuz kutu), yanında kırmızı levha çatılı kulübe | surlar_ayrinti.gd (sur üstü ayrıntı; düğüm adı doğrulanmadı) ŞÜPHELİ-kaynak | Kutuyu kiremitli eğik çatılı nöbet kulübesine çevir ya da kaldır |
| H03 | KUTU | 3 | Kara surları kule platformu | -5017, -1069 | kare/kara_003_asagi_030.jpg | Kule platformunda kırmızı çatılı kutu kulübe ve yere yatık duran kırmızı bayrak levhası | surlar_ayrinti.gd:_flag | Bayrak direğe asılı kıvrımlı kumaş olsun |
| H04 | ZEMİN | 2 | Kara suru dışı hendek/ateş alanı | -4948, -392 | kare/kara_006_asagi_060.jpg | Zeminde açık yeşil yelpaze/ışın şeritleri (üst sol): dokuda ışın gibi uzanan artefakt | sur_zemin.gd (hendek/ateş alanı zemin) ŞÜPHELİ-kaynak | Zemin renk gürültüsü yönlü değil, yumuşak lekeli olsun |
| H05 | ZEMİN | 2 | Kara suru iç yanı (Topkapı güneyi) | -5017, -1069 | kare/kara_003_asagi_030.jpg | Sağda keskin kenarlı çokgen kum rengi yama (cetvelle kesilmiş), yeşil zeminle bıçak çizgisi | sur_zemin.gd / ayrinti_sokak.gd (yama) ŞÜPHELİ-kaynak | Yama kenarlarını yumuşat, toprak yola dönüştür |
| H06 | BOŞLUK/YAŞAM | 2 | Kara suru iç yüzü (sur dibi) | -4940, -1520 | kare/kara_001_asagi_030.jpg | Sur iç yüzünde 60-100 m genişliğinde çıplak parlak yeşil çayır, tek tük çalı; notlar 0b'ye (sura kadar dolu) aykırı | IstGeo.mahalle / evler.gd (sur dibi yoğunluğu) | Sur dibi kuşağına sıra ev + bostan tarhı ekle |
| H07 | BOŞLUK/YAŞAM | 2 | Kara suru iç yüzü | -4981, -618 | kare/kara_005_asagi_060.jpg | Sağ yarıda tek renk sarımsı çayır alanı (80 m kadar), ev yok | IstGeo.mahalle | Bostan/bağ adası ekle |
| H08 | KUTU | 3 | Ordugâh kenarı (kara surlarının dışı) | -4094, 1962 | kare/kara_018_ileri_030.jpg | Neon yeşil yuvarlak çokgen "oyuncak" ağaç kümeleri, hepsi aynı ton ve boy | bitki.gd / ordugah (ağaç) ŞÜPHELİ-kaynak | Ağaç tonlarını ve boylarını çeşitlendir, gövde ekle |
| H09 | KUTU | 3 | Kara suru iç yanı | -4940, -1520 | kare/kara_001_ileri_030.jpg | Beyaz yumak çalı/bulut öbekleri çimenin üstünde (oyuncak çalı) | bitki.gd ŞÜPHELİ-kaynak | Çalı dokusu ve renk çeşitliliği |
| H10 | GÖRSEL | 2 | Haliç karşı yakası (kuzey kıyı) | -3448, 2951 | kare/kara_024_ileri_030.jpg | Karşı kıyı düz parlak çim yüzeyi + dağınık beyaz/kırmızı minik küp evler; tepe, orman, bağ yok | dunya.gd:uzak karsi kiyi (karsi_sayim) / IstGeo.KOYLER | Karşı yakaya ormanlık tepe, bağ dokusu, köy öbekleri |
| H11 | ZEMİN | 3 | Kara suru dışı ateş alanı | -4094, 1962 | kare/kara_018_asagi_060.jpg | Zeminde simetrik koyu oval çukur dizileri (yapay damga) | sur_zemin.gd / ordugah_cephe.gd (siper/çukur) ŞÜPHELİ-kaynak | Düzensiz yerleşim, çevresinde toprak yığını |
| H12 | GÖRSEL | 3 | Kara surları Haliç ucu | -3448, 2951 | kare/kara_024_asagi_060.jpg | Yamaçta yarı saydam görünen beyaz küp/levha nesneler | ŞÜPHELİ (düğüm adı bulunamadı) | Sur_kim ile kaynağı bul |
| H13 | KUTU | 3 | Kara surları iç yanı | -4875, -1705 | kare/kara_000_asagi_030.jpg | Açık yeşil (mint) düz levha çatılı küçük kutu evler: kiremit değil, oyuncak | evler.gd (çatı rengi) ŞÜPHELİ-kaynak | Çatı renk paletinden mint'i çıkar |
| H14 | KUTU | 3 | Kara suru kule platformları | -4832, 904 | kare/kara_012_ileri_030.jpg | Kule üstü zemini iki tonlu satranç karosu (düz renkli kare yamalar) | surlar.gd:_inner_tower (platform döşemesi) | Taş derz dokusu / kırık plaka |
| H15 | PERFORMANS | 3 | Kara suru Topkapı çevresi | -4886, 682 | kare/kara_011_ileri_030.jpg | Bütçe sınırında: 1365 çizim, 3,46 M üçgen (uçuş bütçesi 1500/3,5 M); kara_011_ileri_060 3,38 M; kara_012_ileri_030 3,19 M | dunya.gd/sehir.gd LOD | Üçgen payını LOD ile düşür |
| H16 | OYNANIŞ | 1 | Konstantin Sütunu konma noktası | -756, -11 | kare/eser_02_konstantin_konmaK.jpg | Konma noktasından (göz +1,7 m) dört yöne (K,D,G,B) bakış kareleri neredeyse tamamen simsiyah (ortalama parlaklık %6); kamera sütun başlığı gövdesinin içinde, yalnız sağ üstte küçük gökyüzü çizgisi | IstSehir.flight_data_v2 perches 'ist_konstantin' (sehir.gd:perch_marks; tepe_nokta/_pad) — kaynak ham kod okunarak doğrulanmadı | Konma Q'yu başlığın üst yüzeyine al (haç ve küre 1,7 m'den alçak kalsın) ya da başlığı oyuncunun boyunun üstünde oyuk bırakma |
| H17 | KUTU | 2 | Hipodrom pisti | -532, -433 | kare/eser_01_hipodrom_y080.jpg | Pist parlak mint yeşil tek renk düz dikdörtgen; üstünde bej/pembe kare yamalar ve uçta düz beyaz oval levha (150 m'de belirgin); 1453'te harap toprak/ot olmalı | IstSehir 'hipodrom' (hipodrom*.gd / forumlar_yapi.gd) ŞÜPHELİ-kaynak | Pisti toprak-ot dokusuna çevir, beyaz oval yama yerine sphendone taş yığını |
| H18 | KUTU | 3 | Hipodrom sphendone | -673, -575 | kare/eser_01_hipodrom_y150.jpg | Güney ucunda dokusuz beyaz oval disk (yassı levha) pist zemininde | IstSehir 'hipodrom' | Taş döşeme dokusu ver |
| H19 | DÖNEM | 2 | Ayasofya yanı (konma noktasından kuzeye) | -3, -15 | kare/eser_00_ayasofya_konmaK.jpg | Kubbe konma noktasından kuzeyde dokusuz beyaz dikdörtgen prizma bir direk yükseliyor (minare silüeti); Ayasofya'nın yanında 1453'te minare olmamalı. ŞÜPHELİ: kaynağı belirsiz (sütun mu, işaret mi) | ŞÜPHELİ (düğüm adı: Ayasofya çevresi; sehir.gd Augustaion/Justinianus sütunu?) | Sütunsa mermer/porfir dokusu ve başlık ver; değilse kaldır |
| H20 | GÖRSEL | 3 | Ayasofya kubbesi üstü | -3, -15 | kare/eser_00_ayasofya_konmaD.jpg | Kubbe yüzeyinde yatay dokusuz beyaz dikdörtgen levhalar (çatı üstünde duran tahta gibi) | sehir.gd:_pad (konma kapakları) ŞÜPHELİ-kaynak | Kapağı yüzeye göm ya da kurşun şerit dokusu |
| H21 | ZEMİN | 3 | Konstantin Forumu | -918, -173 | kare/eser_02_konstantin_y080.jpg | Forum meydanı keskin kenarlı gri daire disk (damga) yeşil/toprak zemin üstünde | forumlar.gd (forum zemini) | Kenarı yumuşat, taş döşemeyi toprağa karıştır |
| H22 | KUTU | 3 | Konstantin Sütunu başlığı | -786, -41 | kare/eser_02_konstantin_y015.jpg | Sütun tepesi beyaz düz kare levha ve üstünde küçük altın haç; tabana benzer kutu başlık | IstSehir 'konstantin' (konstantin*.gd) | Başlığa silindirik kapitel ve heykel kaidesi ekle |
| H23 | ZEMİN | 3 | Havariyun çevresi | -2621, 1129 | kare/eser_03_havariyun_y040.jpg | Kilise çevresinde keskin kenarlı yeşil çokgen çayır yaması ve toprak yol şeritleri (yama kenarı bıçak gibi) | IstGeo.mahalle / ayrinti_sokak.gd | Yama kenarlarına çalı/duvar ekle |
| H24 | OYNANIŞ | 2 | Bozdoğan Kemeri konma noktası | -2030, 865 | kare/eser_04_bozdogan_konmaK.jpg | Konma noktası su kanalının içinde: dört yönde 1-2 m'de taş duvar, ufuk görünmüyor; oyuncu inince dar koridorda kalıyor | sehir.gd:perch_marks 'ist_bozdogan' (kemer üstü) | Konmayı kanal yanındaki geniş tepe şeridine al |
| H25 | OYNANIŞ | 1 | Romanos (Topkapı) kapısı kulesi konma noktası | -4800, 1023 | kare/eser_08_surlar_konmaK.jpg | Konma noktasından dört yöne bakış kareleri tam siyah (yalnız kenar çizgileri): kamera sur kulesinin gövdesi içinde; oyuncu inince ekran kararır | IstSehir.flight_data_v2 perches 'ist_romanos' (surlar.gd:_perches / perch_marks) | Konmayı kule üst yürüme platformuna, gövde dışına al; Q'nun 1,7 m üstü boş olsun |
| H26 | OYNANIŞ | 2 | Blakherna konma noktası | -3243, 3307 | kare/eser_07_blakherna_konmaK.jpg | Dört yöne bakışta karenin ortasında dokusuz siyah dikdörtgen kütle (kamera bir siyah yüzeyin hemen yanı/içinde); ufuk yarı örtülü | IstSehir.flight_data_v2 perches 'ist_blakherna' | Konma noktasını açık teras üstüne taşı, çevresinde siyah/malzemesiz ağ var mı bak |
| H27 | GÖRSEL | 2 | Romanos (Topkapı) iç yanı | -4926, 815 | kare/eser_08_surlar_y040.jpg | Sur dibinde çatılar doygun turuncu-sarı, pembe kutu ev; öteki mahalle renklerinden kopuk, oyuncak görünüm | evler.gd / ayrinti_sokak.gd (çatı renk paleti) ŞÜPHELİ-kaynak | Çatı renklerini mahalle paletine bağla, doygunluğu düşür |
| H28 | GÖRSEL | 3 | Galata ve Haliç karşısı (eser yaklaşması) | -807, 1589 | kare/eser_06_galata_y150.jpg | Galata'dan bakışta kuzey yaka düz parlak çimen, serpiştirilmiş beyaz kutu evler; Boğaz tepeleri ve bağ yok | dunya.gd (uzak karşı yaka) | Tepe/ağaç/bağ dokusu ekle |

## 4) Tür başına sayım

```
KUTU 10
ZEMİN 5
BOŞLUK/YAŞAM 2
GÖRSEL 5
PERFORMANS 1
OYNANIŞ 4
DÖNEM 1
KUTU kalan=10
```

## 5) En kötü 12 kare
(derleniyor)

## 6) İyi olan 5 kare (korunacaklar)
(derleniyor)

## Performans (RINFO; bütçe uçuş 1 500 çizim / 3,5 M üçgen)

- Ölçülen kare: 276; bütçeyi aşan: 5 eser_08_surlar_y150 1606 çizim 3.69 M; eser_08_surlar_y080 1650 çizim 4.10 M; eser_08_surlar_y040 1592 çizim 4.44 M; eser_08_surlar_y015 1691 çizim 4.31 M; eser_08_surlar_konmaD 1266 çizim 3.64 M
- En yüksek 5 üçgen: eser_08_surlar_y040 1592 çizim 4.44 M; eser_08_surlar_y015 1691 çizim 4.31 M; eser_08_surlar_y080 1650 çizim 4.10 M; eser_08_surlar_y150 1606 çizim 3.69 M; eser_08_surlar_konmaD 1266 çizim 3.64 M

## Sürekli uçuş / LOD
(derleniyor)

## Oyun içi uçuş (Bölüm 11 ve 7, HUD'lu)
(derleniyor)

## 7) Bakamadıklarım
(derleniyor)
