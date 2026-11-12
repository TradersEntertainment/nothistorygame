# İstanbul v2 — HAVADAN gezi denetimi (bölge `havadan`)

Dal `wip/gezi-havadan`; sonda `tests/_ist/gezi_havadan.gd/.tscn` (yalnız test; oyun kodu değişmedi). Taban `wip/ist2-gezi-taban`. Kare: yazılımla çizim (llvmpipe, 1280×720; sürekli uçuş 640×360).

## 1) Bölge, sayılar

- Bölge: bütün şehir havadan. Kamera yelpazesi (gerçek m, doğu/kuzey): doğu -5969…579, kuzey -2065…3484. Dört köşe ≈ (-5969,-2065) Mermer Kule/Marmara · (-5969,3484) Haliç ucu/Blakherna · (579,3484) Galata-Sarayburnu · (579,-2065) Marmara doğu ucu.
- Çekilen kare: **1154** (klasör başına: eser=288, halic=330, kara=168, marmara=138, mese=36, ordugah=120, oyun11=17, oyun7=17, ucus=40). Bakılan kare (paftada açıp incelediğim): **381**. Bakmadığım kareler aşağıda "bakamadıklarım".
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
| H08 | KUTU | 3 | Ordugâh kenarı (kara surlarının dışı) | -4094, 1962 | kare/kara_018_ileri_030.jpg | Neon yeşil yuvarlak çokgen "oyuncak" ağaç kümeleri, hepsi aynı ton ve boy | scripts/world/ist/bitki.gd:tree_mesh/_agac | Ağaç tonlarını ve boylarını çeşitlendir, gövde ekle |
| H09 | KUTU | 3 | Kara suru iç yanı | -4940, -1520 | kare/kara_001_ileri_030.jpg | Beyaz yumak çalı/bulut öbekleri çimenin üstünde (oyuncak çalı) | scripts/world/ist/bitki.gd:tree_mesh/_agac (add_blob) | Çalı dokusu ve renk çeşitliliği |
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
| H29 | GÖRSEL | 2 | Marmara kıyısı (Arkadius yakını, kıyı sur kuleleri) | -3722, -981 | kare/eser_10_arkadius_y150.jpg | Kıyıda suya bitişik beyaz ve gri dokusuz dikdörtgen bloklar (uzak sur/kule katmanı kutu gibi); yakın katmanda taş şeritli (kalite notu 11'in sürmesi) | marmara_sur.gd (uzak sur pişirmesi, sur_uzak_mat) ŞÜPHELİ-kaynak | Uzak katmana da şeritli taş rengi ve mazgal silueti ver |
| H30 | KUTU | 3 | Markianos Sütunu çevresi | -2641, 819 | kare/eser_11_markianos_y040.jpg | Sütunun yanında kar beyazı yuvarlak çokgen yumaklar (çalı/heykel?) ve alt köşelerde beyaz sivri iğne/koni; oyuncak | scripts/world/ist/bitki.gd:tree_mesh/_agac | Beyaz yumakları çalı dokusuna çevir, iğneleri servi yap |
| H31 | GÖRSEL | 3 | Markianos çevresi | -2722, 738 | kare/eser_11_markianos_y080.jpg | Uzakta somon-pembe düz kubbeler (kutu gibi düz renk) | ŞÜPHELİ (düğüm adı yok) | Kurşun/kiremit kubbe malzemesi |
| H32 | GÖRSEL(LOD) | 2 | Galata Kulesi (uzak-yakın geçişi) | -790, 1651 | kare/eser_13_galata_sur_y150.jpg | 150 m'de Galata Kulesi düz BEYAZ silindir + somon külah; 80 m'de tuğla bantlı koyu kule: belirgin LOD rengi sıçraması (belirme) | galata_kule.gd (uzak katman rengi) | Uzak katmanı yakın katmanın ortalama rengine eşle |
| H33 | GÖRSEL | 2 | Galata sur konma noktası | -396, 1943 | kare/eser_13_galata_sur_konmaK.jpg | Konma noktasında havada duran küçük siyah küp ve üst kenarda koyu/siyah levha; sur gövdesi çevresinde malzemesiz siyah yüzeyler | galata_sur.gd / sehir.gd:perch_marks 'ist_galata_sur' | Konma altlığı dışındaki siyah yüzeyi bul (arka yüz/kare); malzeme ata |
| H34 | GÖRSEL | 2 | Galata deniz suru (Haliç yüzü) | -870, 1315 | kare/eser_14_san_domenico_y150.jpg | Haliç'ten bakışta Galata suru düz gri levha perde; su hattında beyaz dikdörtgen kule blokları (dokusuz, mazgalsız) — uzak sur katmanı hâlâ kutu | galata_sur.gd / sur_doku.gd (uzak katman) ŞÜPHELİ-kaynak | Uzak katman için taş şeritli doku ve mazgal siluetini yakınla aynı yap |
| H35 | GÖRSEL | 2 | Haliç suru (Eugenios kulesi yanı) | -457, 449 | kare/eser_18_halic_eugenios_y150.jpg | Haliç sur hattında bej levha duvar arasında dokusuz beyaz küp bloklar; hat yer yer beyaz kutuyla kesiliyor | halic_sur.gd (uzak/orta katman) ŞÜPHELİ-kaynak | Beyaz blokların malzemesini kontrol et (sur_uzak_mat) |
| H36 | GÖRSEL | 3 | Eugenios kulesi konma noktası | -155, 751 | kare/eser_18_halic_eugenios_konmaD.jpg | Kule çatısı düz somon levha ve ortasından kahverengi direk/kütük çatıyı delip çıkıyor; pencere düz siyah dikdörtgen | halic_kit.gd / halic_sur.gd (Eugenios) ŞÜPHELİ-kaynak | Direği bayrağa çevir ya da çatı içine gömme, pencereye iç derinlik ver |
| H37 | KUTU | 2 | Haliç Venedik mahallesi | -960, 675 | kare/eser_19_halic_venedik_y040.jpg | Somon-pembe düz levha çatılı kutu evler (hepsi aynı doygun ton); sur dibinde beyaz kutu bloklar; yamaçta kahverengi dikdörtgen çerçeve tarhlar | halic_mahalle.gd (çatı rengi) | Çatı palet çeşitliliği ve kiremit dokusu; tarhlar için çit/bitki ekle |
| H38 | KUTU | 2 | Mokios sarnıcı bostanı | -3673, -521 | kare/eser_17_mokios_y040.jpg | Açık sarnıç tabanı düz krem yüzey; üstünde cetvelle dizilmiş kahverengi dikdörtgen tarh kutuları ve yeşil küçük koniler: bostan yerine ızgara maketi | ayrinti_a/b.gd veya forumlar.gd (sarnıç bostanı) ŞÜPHELİ-kaynak | Tarhları düzensiz, farklı boyda ve bitki dokulu yap; zemini toprak rengine çek |
| H39 | KUTU | 3 | Galata Palazzo Comune çevresi | -523, 1526 | kare/eser_15_palazzo_comune_y040.jpg | Kar beyazı çokgen yumaklar ve beyaz sivri koni/iğneler yerde (çalı/servi olmalı); şehir genelinde tekrar ediyor | scripts/world/ist/bitki.gd:tree_mesh/_agac (badem-kiraz çiçekli ağaç, add_blob) — kaynak türü kareden çıkarıldı | Renk/malzemeyi bitki dokusuna bağla; iğneyi servi yap |
| H40 | GÖRSEL | 3 | Eugenios kulesi penceresi | -155, 751 | kare/eser_18_halic_eugenios_konmaK.jpg | Kule pencereleri düz siyah dikdörtgen (içi çizilmemiş delik gibi) | halic_kit.gd ŞÜPHELİ-kaynak | İç gölge/kemerli çerçeve |
| H41 | GÖRSEL | 2 | Ordugâh uzaktan (Topkapı karşısı) | -4948, -392 | kare/kara_006_ileri_120.jpg | 120 m'den çadır denizi çamur/kaya benzeri kahverengi lekeler (çadır dokusu seçilmiyor) ve keskin kenarlı koyu kahverengi yama; ordugâh ateşi/duman yok | ordugah_kanat.gd (lod 2 uzak katman) ŞÜPHELİ-kaynak | Uzak çadır katmanına açık bez rengi ve duman/ateş noktaları |
| H42 | GÖRSEL | 3 | Haliç ötesi ova | -3167, 3478 | kare/kara_027_ileri_120.jpg | Karşı yaka düz parlak yeşil ova, tekrarlayan şerit doku, eş beyaz/kırmızı küpler; tepe/orman/bağ yok (kalite notu 0'a aykırı) | dunya.gd karşı yaka / IstGeo.KOYLER | Doku çeşitliliği, orman tepeleri |
| H43 | GÖRSEL | 3 | Kara suru iç yanı (Tekfur yöresi) | -4862, 233 | kare/kara_009_ileri_120.jpg | Duvarlı avlu yapısı: doygun turuncu çatılar ve beyaz duvar çevreden kopuk parlak; yamalı renk | ŞÜPHELİ (yapı adı bilinmiyor) | Paletle uyumla |
| H44 | GÖRSEL | 1 | Haliç (suyun üstü, sur ucu yanı) | -967, 1758 | kare/halic_galata_044_ileri_030.jpg | Haliç suyunun üstünde, kıyı boyunca açık camgöbeği düz dikdörtgen/üçgen yama: dalgasız, çevre sudan farklı malzeme (su/kıyı hatası); halic_galata_022_ileri_030, _033_ileri_030 (karenin dörtte biri), _010_ileri_030 karelerinde de | dunya.gd:_sea_near/_sea_far ya da halic*.gd su kesimi; düğüm adı çözülemedi (başsız AABB sıfır) | Yamanın hangi ağ/gölgelendirici olduğunu bul; deniz malzemesiyle aynı yap ya da kaldır |
| H45 | MANTIK | 2 | Haliç ortası (Ayvansaray ile Galata arası) | -1270, 2160 | kare/halic_galata_033_asagi_060.jpg | Haliç suyunun ortasında kıyıdan uzakta uzanan, kama (üçgen prizma) payandalı koyu gri sur/set hattı: kare boyunca suyun içinde, iki yana kıyıya bağlanmıyor; kaynağı çözülemedi (ŞÜPHELİ: halic_*.gd'de zincir/set ya da halic_suru dolgusu 'kdolgu_halic_suru_34/35' yakını) | ŞÜPHELİ: halic_sur.gd (kdolgu_halic_suru_*) — düğüm adı doğrulanmadı | Hattın ne olduğunu belirle; zincirse kütük+zincir, set ise kıyıya bağla |
| H46 | GÖRSEL | 2 | Haliç suru (yakın hat) | -1943, 2089 | kare/halic_galata_014_asagi_060.jpg | 60 m'den bile sur kuleleri düz beyaz dikdörtgen kutu (uzak katman rengi); 018 ve 022 karelerinde de, yakın taş kuleyle yan yana beyaz bloklar | halic_sur.gd (uzak katman eşiği çok yakın) ŞÜPHELİ-kaynak | Uzak katmanı yalnız 150 m ötesine ver, taş/şerit dokusunu koru |
| H47 | GÖRSEL | 3 | Haliç suru mazgalları | -1539, 1446 | kare/halic_galata_010_ileri_030.jpg | Kule üst mazgalları kar beyazı küp dizileri (beyaz küpler; biliniyor), kule gövdesi gri levha | surlar.gd:_roof_ring/mazgal (mer) | Mazgalı taş rengine çek |
| H48 | GÖRSEL | 3 | Haliç kıyısı (Perama) | -837, 983 | kare/halic_galata_006_ileri_030.jpg | Yarı saydam görünen nane yeşili çokgen top çalı (oyuncak) rıhtım yanında | bitki.gd:tree_mesh/_agac | Çalı dokusu |
| H49 | GÖRSEL | 3 | Haliç kıyısı | -1539, 1446 | kare/halic_galata_010_asagi_060.jpg | Zeminde beyaz altıgen çerçeve ve beyaz noktalar (kaynağı belirsiz işaret/damga), mahalle yolu ortasında | ŞÜPHELİ (düğüm adı çözülemedi) | Kaynağı bul; oyun içi işaretse gizle |
| H50 | ZEMİN | 3 | Haliç iskelesi meydanı | 24, 761 | kare/halic_galata_002_asagi_060.jpg | Rıhtım meydanı balık kılçığı döşeme yaması keskin, kenarı bıçak çizgisi gibi çimene dayanıyor | halic_liman.gd (rıhtım zemini) ŞÜPHELİ-kaynak | Kenar çakılı toprak geçişi |
| H51 | BOŞLUK/YAŞAM | 2 | Galata surunun kuzey/dış yakası | -935, 1818 | kare/halic_galata_054_ileri_030.jpg | Sur dışı parlak yeşil boş çayır: tek tük nane yeşili ağaç ve minik beyaz küp ev; bağ/bahçe/köy dokusu yok (kalite notu 0b: Galata surlarına kadar dolu olmalı); 036 ve 046 karelerinde de | IstGeo.mahalle (Galata dış kuşak) / dunya.gd karşı yaka | Galata dışına bağ, bahçe, çit ve ev öbekleri ekle |
| H52 | GÖRSEL | 3 | Galata sur dışı yamaç | -678, 1929 | kare/halic_galata_036_ileri_030.jpg | Çayırda sarı-yeşil minik piramit çalılar (düz renkli koni), oyuncak | bitki.gd:tree_mesh/_agac (çalı) | Çalıyı yuvarlak ve dokulu yap |
| H53 | GÖRSEL | 2 | Marmara sur hattı (Samatya/Langa kıyısı) | -3911, -1036 | kare/marmara_004_asagi_060.jpg | 60 m'den bir sur kesimi taş değil, düz beyaz dikdörtgen bloklar sırası (mazgalsız, dokusuz); 010, 013, 016 ve 018 karelerinde de beyaz blok kuleler yan yana taş kulelerle | marmara_sur.gd (uzak katman / sur_uzak_mat) ŞÜPHELİ-kaynak | Uzak katman eşiğini uzaklaştır, uzak katmana taş-tuğla şerit ve mazgal ver |
| H54 | BOŞLUK/YAŞAM | 2 | Marmara kıyısı iç yanı (Eleutherios çevresi) | -3911, -1036 | kare/marmara_004_ileri_030.jpg | Sur ile evler arasında 80 × 60 m kadar çıplak sarımsı çayır; çevresinde beyaz yumak çalılar; yaşam yok (kalite notu 0'a aykırı) | IstGeo.mahalle (kıyı kuşağı yoğunluğu) | Bostan tarhı, bağ, çit ve ev sırası ekle |
| H55 | KUTU | 3 | Marmara kıyısı bostanı | -1243, -619 | kare/marmara_013_asagi_060.jpg | Çayırda iki parlak kırmızı çatılı küp kutu (tezgâh/araba?) ve nane yeşili yarı saydam top çalılar | ayrinti_*.gd (sokak donanımı) ŞÜPHELİ-kaynak | Kutuyu tezgâh/arabaya çevir, çalıları dokula |
| H56 | GÖRSEL | 3 | Marmara kıyısı ufku | -3911, -1036 | kare/marmara_004_ileri_030.jpg | Ufukta kıyı boyunca sıralı beyaz küp bloklar (uzak sur kuleleri) ve soldan sivri beyaz koni; ufuk çizgisi kıyıda tepe yok | marmara_sur.gd | Uzak sura mazgallı silüet |
| H57 | ZEMİN | 2 | Mese ekseni (Konstantin Forumu güneyi) | -1239, 127 | kare/mese_003_asagi_030.jpg | Taş döşeli yol ile çayır arasındaki sınır basamaklı/kademeli (arazi ızgarası kaba), yama kenarları merdiven gibi kare kare; forum diski de çıkıntılı çokgen kenarlı | IstGeo.h / dunya.gd:Arazi vertex rengi (yama kenarı) ve sur_zemin.gd | Zemin yama sınırını ızgaradan bağımsız yumuşak geçişle (dokuda alfa karışımı) çiz |
| H58 | KUTU | 3 | Hipodrom batısı / Mese başı | -230, -30 | kare/mese_000_ileri_030.jpg | Ön planda iki dev nane yeşili yumuşak top ağaç (kısa gövde, aynı ton); solda Hipodrom pisti düz parlak mint | bitki.gd:tree_mesh/_agac | Ağaç boyu ve tonunu çeşitlendir, pisti toprak rengine çek |
| H59 | ZEMİN | 2 | Ordugâh merkezi (Rumeli kanadı güneyi) | -5946, -1230 | kare/ordugah_003_ileri_030.jpg | Çadırların altında koyu kahverengi çokgen çamur yamaları: düz kenarlı, keskin sınırlı, çevredeki yeşil/olive zeminden cetvelle kesilmiş gibi | ordugah_kanat.gd / ordugah_yerleske.gd (zemin yaması) ŞÜPHELİ-kaynak | Yama kenarlarını düzensiz ve yumuşak yap, çiğnenmiş toprak dokusu |
| H60 | ZEMİN | 2 | Ordugâh Anadolu kanadı | -5891, -325 | kare/ordugah_005_asagi_060.jpg | Zemin büyük düz üçgen yüzlere ayrılmış (low-poly facet), olive-bej tek renk kayma; çadır tabanıyla zemin arası bıçak çizgisi | ordugah_kanat.gd / dunya.gd arazi rengi ŞÜPHELİ-kaynak | Zemin dokusu ekle, facet gölgesini yumuşat |
| H61 | KUTU | 2 | Ordugâh (otağ/konak) | -5891, -325 | kare/ordugah_005_ileri_030.jpg | Parlak düz kırmızı dikdörtgen prizma + beyaz levha: dokusuz otağ/mutfak kutusu (ordugah_007_ileri_030 ve ordugah_007_asagi_060'ta küçük kırmızı kulübe) | ordugah_otag.gd / ordugah_yapi.gd ŞÜPHELİ-kaynak | Çadır bezi dokusu, kıvrımlı kumaş çatı, direk ve sancak |
| H62 | KUTU | 3 | Ordugâh çadır denizi | -5779, 48 | kare/ordugah_007_ileri_030.jpg | Çadırların hepsi aynı bej piramit/koni/kutu (yalnız birkaçı koyu kahve); renk ve boy çeşitliliği yok, gündüz ateş/duman yok (biliniyor: ORDUGÂH-5) | ordugah_oba.gd / ordugah_kit.gd | Bez rengi çeşitliliği, kamp ateşi dumanı |
| H63 | KUTU | 3 | Ordugâh Anadolu kanadı | -5830, 350 | kare/ordugah_009_asagi_030.jpg | Yeşil elmas biçimli (düz yüzlü) ağaçlar çadırların arasında, oyuncak | bitki.gd:tree_mesh/_agac (ordugah ağacı) | Ağaç yuvarlak ve dokulu olsun |
| H64 | BOŞLUK/YAŞAM | 2 | Ordugâh güney ucu (Marmara kıyısı) | -5726, -2065 | kare/ordugah_001_ileri_030.jpg | Çadır denizi bitince kıyı yamacı çıplak: yeşil-sarı çayır, tek tük koni ve iki ağaç; kıyıda ağıl/at bağı/yaşam yok | ordugah_kanat.gd (kanat alan kapsamı) | Kıyıya kadar çadır/ağıl/at bağı uzat |
| H65 | GÖRSEL | 2 | Bukoleon/Sergios kıyısı (Marmara) | -693, -822 | kare/eser_24_sergios_y080.jpg | İskele yanında suyun üstünde açık camgöbeği düz yama (Haliç'tekiyle aynı tür su/kıyı hatası); kare sağ altında iskele kütükleriyle iç içe | dunya.gd:_sea_near/_sea_far ya da halic_kit/marmara kıyı yaması; düğüm adı çözülemedi | Su yamasının malzemesini deniz gölgelendiricisine bağla |
| H66 | GÖRSEL | 3 | Büyük Saray konma noktası | 63, -208 | kare/eser_25_buyuk_saray_konmaD.jpg | Konma noktasında karenin %30'u düz krem-beyaz levha ve üstünde küçük parlak yeşil koniler (çimen/ot yerine); saray avlusu yamalı pastel karelerle kaplı | forumlar_yapi.gd / hipodrom_saray (büyük saray) ŞÜPHELİ-kaynak | Avlu döşemesine taş dokusu ver, yeşil konileri ot tutamı yap |
| H67 | KUTU | 2 | Khalke kapısı konma noktası | 54, -199 | kare/eser_26_khalke_y015.jpg | Somon-pembe düz sekizgen kubbe/çatı: tek renk levha; konma karesi (eser_26_khalke_konmaD) üçte biri düz pembe yüzey | IstSehir 'khalke' (hipodrom_saray) | Kiremit/kurşun dokusu ve eğimli kubbe silüeti |
| H68 | KUTU | 3 | Haliç Petrion yakını | -2639, 1973 | kare/eser_20_halic_petrion_y150.jpg | Kamera önünde dev koyu yeşil düz yüzlü koni (servi) gökyüzünü kesiyor; oyuncak servi | bitki.gd:tree_mesh/_agac (servi) | Servi yuvarlak gövde, dokulu |
| H69 | GÖRSEL | 3 | Aya İrini çatısı | -15, 15 | kare/eser_23_aya_irini_y080.jpg | Kubbe/çatı üstünde dokusuz beyaz uzun levha kutular yatıyor (Ayasofya'daki gibi: konma kapağı/pad) | sehir.gd:_pad (Konma_form_*) | Kapağı çatı malzemesine uydur |
| H70 | GÖRSEL | 2 | Khora (Kariye) ve Pammakaristos kiliseleri | -3474, 2486 | kare/eser_30_khora_y015.jpg | Kilise kubbeleri simsiyah-lacivert (öteki kiliselerde açık kurşun mavisi); eser_31_pammakaristos_y015 karesinde de dört kubbe siyah; haç beyaz kalmış | IstSehir 'khora'/'pammakaristos' (MANASTIR avlulu kilise; sehir.gd kubbe malzemesi) ŞÜPHELİ-kaynak | Kubbe malzemesini diğer kiliselerin kurşun malzemesine eşle (yüzey normali/ters yüz olabilir) |
| H71 | KUTU | 3 | Khora/Pammakaristos manastır avlusu | -2863, 2308 | kare/eser_31_pammakaristos_y015.jpg | Avlu duvarı çatısı düz somon-pembe levha; zeminde gri düz döşeme, ağaçlar nane yeşili top | sehir.gd MANASTIR avlu | Kiremit dokusu, avlu çeşitliliği |
| H72 | OYNANIŞ | 3 | Yan görev eserleri konma noktası | -3525, 2435 | kare/eser_30_khora_y040.jpg | flight_data_v2 perches listesinde yer işareti olup konma noktası olmayan eserler: ZINCIR, KHORA, PAMMAKARISTOS, BLAKHERNAI_KILISE, TEKFUR, ANEMAS (HVD_KONMA_YOK); oyuncu bu eserlere konup konuşma/ödül alamaz | sehir.gd:perch_marks (it.has('perch') olmayan kayıtlar) | Her yan görev eserine bir konma noktası ekle ya da görevde konma istenmesin |
| H73 | ZEMİN | 2 | Altın Kapı dış hendeği | -5217, -1914 | kare/eser_35_altin_kapi_y150.jpg | Hendek ve ateş alanı parlak yeşil düz rampa/eğik yüzey olarak çiziliyor, keskin kenarlı; taş kaplı hendek dokusu yok | sur_zemin.gd / surlar.gd:_build_moat | Hendeğe taş kaplama, toprak yığını ve çiğnenmiş doku |
| H74 | GÖRSEL | 3 | Altın Kapı kapısı | -5076, -1773 | kare/eser_35_altin_kapi_y080.jpg | Kapı beyaz düz kutu çerçeve; içinde siyah-kırmızı düz levha: kapı detayı yok | surlar_kapi.gd (altin_kapi) | Mermer kaplama dokusu ve kemer silueti |
| H75 | KUTU | 3 | Tekfur Sarayı kulesi | -3480, 2664 | kare/eser_33_tekfur_y080.jpg | Kule/saray çatısı tek renk mor-kahve levha piramit (biliniyor) | surlar.gd:_inner_tower (cati) | Çatıyı dokulandır |
| H76 | GÖRSEL | 3 | Pege Kapısı konma noktası | -5019, -1107 | kare/eser_36_pege_konmaD.jpg | Sur üstünden bakışta sağ üstte koyu siyah-zeytin devasa mazgal blokları (düz renk dikdörtgen) | surlar.gd:_roof_ring/mazgal | Mazgal bloklarına taş dokusu |
| H77 | MANTIK | 2 | Galata sur dilimleri (Haliç kıyısı) | -870, 1315 | kare/eser_14_san_domenico_y150.jpg | Galata suru 205–213. dilimleri ve köşe dilimleri kıyı çokgeninin dışında, suyun içinde duruyor; karede suyun içinde duran beyaz kutu kuleler/levha sur. Sayısal: HVD_SU galata_suru örneklerinin %24'ü suda; HVD_SUDA eser listesi galata_suru_205…213, kose_galata_suru_510/512 suda | IstSehir.items 'galata_suru_*' (galata_sur.gd hat dilimleri; IstGeo.Y_GALATA) | Galata sur hattını K_GALATA kıyısı içine çek ya da kıyıyı hat boyunca doldur (dolgu) |
| H78 | MANTIK | 3 | Marmara sur dilimleri (kıyı) | -3911, -1036 | kare/marmara_004_asagi_060.jpg | Marmara sur dilimleri marmara_suru_53/116/129/154 ve kdolgu_marmara_suru_1/15/16/23/42 suyun içinde (HVD_SUDA); karede sur suya girmiş kıyı kıvrımında beyaz bloklar | IstSehir.items 'marmara_suru_*' (marmara_sur.gd) | Dilimleri kıyı çokgenine hizala |
| H79 | PERFORMANS | 3 | Haliç kıyı turu | -3053, 3484 | kare/halic_galata_023_ileri_030.jpg | Çizim bütçesini aşan kare: 1640 çizim (bütçe 1500); üçgen 3,03 M (içinde); halic_galata_023_ileri_060 1464 çizim 3,09 M | dunya.gd/sehir.gd (Haliç mahallesi MultiMesh toplama) | Haliç mahalle parçalarını birleştir |
| H80 | BOŞLUK/YAŞAM | 2 | Haliç güney yakası iç yamaç (Neorion–Petrion arası) | -477, 868 | kare/ucus_halic_galata_060_k0150.jpg | Sürekli uçuşta kıyının iç yanında 200 m kadar çıplak yeşil yamaç; üstünde dağınık 3-4 somon-pembe düz çatılı kutu ev; mahalle dokusu ve sokak yok | IstGeo.mahalle (Haliç iç kuşağı) / halic_mahalle.gd | Sıra ev, bahçe ve sokak ekle; pembe kutu evleri palete bağla |
| H81 | GÖRSEL | 2 | Haliç suru (Neorion yakını) | -408, 833 | kare/ucus_halic_galata_060_k0060.jpg | 60 m'den sürekli uçuşta da sur kulesi düz beyaz dikdörtgen blok + gri kutu (uzak katman); suyun kenarında kare kare duruyor | halic_sur.gd (uzak katman) | Uzak katmanı taş dokulu yap |
| H82 | PERFORMANS | 2 | Kara surları boyunca uçuş (ark 612–631 m) | -4859, 0 | kare/ucus_kara_030_k0090.jpg | 18 m/sn uçuşta betik süresi 5 karede 50 ms'yi aştı: 56, 60, 335 (k=72), 157, 153 ms (HVD_UCUS satırları; kare içi betik süresi, çizim hariç); aynı uçuşta en çok 1559 çizim (bütçe 1500), 3,09 M üçgen. 335 ms'de IstSehir kuyruğunda iş var: yeni parça kurulumu takılma yaratıyor | sehir.gd (_process kuyruk: _build/_cell_up) ŞÜPHELİ-işlev | Parça kurulumunu karelere böl; sur dilimi pişirmesini ön-pişir |
| H83 | PERFORMANS | 2 | Ordugâh üstünde uçuş (ark 821–852 m) | -5884, -277 | kare/ucus_ordugah_030_k0060.jpg | Betik süresi 4 karede 50 ms üstü: 278 ms (k=72), 165 (k=91), 90 (k=137), 111 (k=175); IstDunya (isler=0, dunya_us<110 µs) ve IstSehir kuyruğu (0) boş olduğu hâlde takılma: kaynak ordugâh yöneticisi lod geçişi olabilir (ŞÜPHELİ). Kara uçuşunda da aynı kare numarasında (k=72) 335 ms: ilk uçuş saniyesinde tek seferlik iş | ordugah.gd:IstOrdugahYonetici (lod 2→1 kurulumu) ŞÜPHELİ-işlev | Ordugâh parçalarının lod kurulumunu karelere böl ya da açılışta ön-pişir |
| H84 | KUTU | 3 | Konstantin Sütunu (Mese uçuşu) | -667, -14 | kare/ucus_mese_030_k0180.jpg | Sütun başlığı düz beyaz kare levha + küçük altın haç, gövde yalnız ince koyu bantlı pembe-kırmızı silindir; yakından oyuncak sütun | konstantin*.gd (IstSehir 'konstantin') | Kapitel ve heykel kaidesi |
| H85 | GÖRSEL | 2 | Hipodrom pisti (gece, oyun içi Bölüm 11) | — | kare/oyun11_05_eser_hipodrom.jpg | Gece karesinde Hipodrom pisti parlak mint-yeşil tek renk ve gece ışığından bağımsız parlıyor (ışıyan yanlış yüzey); çevre karanlıkken pist gündüz rengiyle duruyor | IstSehir 'hipodrom' (hipodrom*.gd pist malzemesi; unshaded/emisyon?) ŞÜPHELİ-kaynak | Pist malzemesini gece ışığına duyarlı yap, rengi toprak-otlağa çek |
| H86 | PERFORMANS | 1 | Ordugâh üstünde uçuş (oyun içi Bölüm 11, gece) | — | kare/oyun11_02_ordugah_ustu.jpg | HUD'lu oyun karesinde 3994 çizim (bütçe 1500; 2,7 katı), 4113 nesne; 2,04 M üçgen. Kalkış karesi (oyun11_01_kalkis) 2162 çizim / 3,84 M üçgen: uçuş bütçesi (1500 / 3,5 M) iki karede de aşıldı | IstBaglama (v2 ordugâh + bölüm sahnesi birlikte); ordugah_kit.gd:ateslar / çadır MultiMesh | Gece ateş ve çadır çizimlerini topla (MultiMesh), bölüm sahnesini uçuşta gizle |
| H87 | GÖRSEL | 2 | Markianos Sütunu (gece, oyun içi Bölüm 11) | — | kare/oyun11_15_eser_markianos.jpg | Gece karesinde sütun yanındaki beyaz yumak çalılar ve beyaz sivri iğne çevreden çok parlak (ışıyan yanlış yüzey); karanlık sokaklar ortasında kar beyazı | bitki.gd:tree_mesh/_agac (add_blob; gece malzemesi) ŞÜPHELİ-kaynak | Beyaz malzemeyi gece ışığına duyarlı yap |
| H88 | GÖRSEL | 3 | Galata Kulesi (gece, oyun içi Bölüm 11) | — | kare/oyun11_10_eser_galata.jpg | Kule gövdesi karanlıkta kaybolmuş, yalnız koyu kırmızı koni görünüyor: yakın katman gece okunmuyor | galata_kule.gd | Gövdeye gece için pencere ışığı/ay aydınlığı |
| H89 | PERFORMANS | 1 | Ordugâha dönüş (oyun içi Bölüm 11) | — | kare/oyun11_17_eve_donus.jpg | 3570 çizim (bütçe 1500; 2,4 katı), 1,85 M üçgen; 12_eser_surlar 1507 çizim / 3,08 M | IstBaglama / ordugah_kit.gd | Gece ateş/çadır çizimlerini topla |
| H90 | PERFORMANS | 1 | Surlar hub'ı uçuşu (oyun içi Bölüm 7, gündüz) | — | kare/oyun7_02_ordugah_ustu.jpg | HUD'lu oyun karesinde 3756 çizim (bütçe 1500; 2,5 katı); oyun7_01_kalkis 2193 çizim / 3,75 M üçgen; oyun7_17_eve_donus 3573 çizim; oyun7_12_eser_surlar 1711 çizim / 3,40 M; 07_eser_havariyun 1636 çizim. Bölüm 11'le aynı örüntü: ordugâh yönüne bakan karelerde çizim 2,5-2,7 kat | IstBaglama (v2 + bölüm sahnesi birlikte çiziliyor); ordugah_kit.gd/çadır MultiMesh | Uçuşta bölüm sahnesini (CampDay/ByzCity) gizle; ordugâh çadırlarını toplu çiz |
| H91 | KUTU | 2 | Ordugâh kenarı (gündüz, oyun içi Bölüm 7) | — | kare/oyun7_17_eve_donus.jpg | Boş çayırın üstünde kırmızı/somon düz kama ve küp prizmalar (3-4 adet) tek başına duruyor; ne olduğu belli değil, dokusuz | ordugah_yapi.gd / ordugah_kanat.gd (kereste/siper yığını?) ŞÜPHELİ-kaynak | Kereste yığını/siper dokusu ver ya da kaldır |
| H92 | GÖRSEL | 3 | HUD (oyun içi Bölüm 7, Galata dönüşü) | — | kare/oyun7_16_galata_donus.jpg | Uçuş HUD'unda altı hedef için renkli elmas işaretleri ve "görev geride, işarete dön" yazıları üst üste biniyor; 'Bozdoğan Kemeri' etiketiyle çakışıyor | scripts/ui (hedef göstergesi; nihat_powers.gd landmark etiketleri) ŞÜPHELİ-kaynak | Yakın etiketleri birleştir ya da dikey aralığı artır |

## 4) Tür başına sayım

```
KUTU 25
ZEMİN 10
BOŞLUK/YAŞAM 6
GÖRSEL 34
PERFORMANS 7
OYNANIŞ 5
DÖNEM 1
GÖRSEL(LOD) 1
MANTIK 3
KUTU kalan=25
```

## 5) En kötü 12 kare
1. `kare/eser_02_konstantin_konmaK.jpg` (+ _konmaD/_G/_B): konma noktasında ekran %99 siyah; kamera sütun başlığının içinde. KRİTİK.
2. `kare/eser_08_surlar_konmaK.jpg` (+ _D/_G/_B): Romanos kulesinde konma = siyah ekran (kule gövdesinin içi). KRİTİK.
3. `kare/eser_07_blakherna_konmaK.jpg` (+ _D): karenin yarısı dokusuz siyah dikdörtgen kütle.
4. `kare/halic_galata_044_ileri_030.jpg`: Haliç'te kıyı boyunca açık camgöbeği düz su yaması (halic_galata_022/033/010'da da).
5. `kare/halic_galata_033_asagi_060.jpg`: suyun içinde testere dişi kama kuleli sur hattı (+ sayısal: Galata suru %24 suda) ve cam göbeği yama.
6. `kare/eser_01_hipodrom_y080.jpg`: Hipodrom pisti parlak mint düz dikdörtgen, beyaz oval levha, pembe kare yamalar.
7. `kare/kara_000_asagi_030.jpg`: kule çatısı kareyi örten tek renk mor-kahve levha piramit; kırmızı küp/kulübe (kara_001_asagi_030).
8. `kare/eser_30_khora_y015.jpg`: kilise kubbeleri simsiyah-lacivert (Pammakaristos da).
9. `kare/marmara_004_asagi_060.jpg`: Marmara suru bir kesimde düz beyaz dikdörtgen bloklar; sur içinde 80 m çıplak çayır.
10. `kare/kara_006_asagi_060.jpg`: hendek/ateş alanında yeşil ışın şeritleri, keskin kenarlı yamalar.
11. `kare/ordugah_003_ileri_030.jpg`: çadırların altında koyu kahverengi çokgen çamur yamaları, düz kırmızı kutu otağ (ordugah_005_ileri_030).
12. `kare/eser_13_galata_sur_y150.jpg` / `_y080`: Galata Kulesi 150 m'de beyaz düz silindir, 80 m'de tuğla bantlı: LOD rengi sıçraması.

## 6) İyi olan 5 kare (korunacaklar)
1. `kare/eser_04_bozdogan_y040.jpg`: Bozdoğan Kemeri: tuğla-taş şeritli kemerler, silüet 150 m'den bile okunuyor.
2. `kare/mese_001_ileri_030.jpg`: Konstantin Forumu ve Mese: taş döşeli daire, sütun, yürüyen kalabalık, tezgâhlar; şehrin en yaşam dolu karesi.
3. `kare/eser_36_pege_y150.jpg` ve `kare/eser_37_kharisios_y150.jpg`: kara suru dışarıdan: üç hat, kuleler, hendek; sur gerçek boyda okunuyor.
4. `kare/eser_05_zincir_y080.jpg`: Haliç zinciri, kütükler ve çok gemili filo; Galata'ya doğru derinlik.
5. `kare/eser_06_galata_konmaD.jpg`: Galata'dan Haliç'e ve suriçi şehre bakış: filo, zincir, ufukta kubbeler. (Ayrıca eser_00_ayasofya_y150: Ayasofya silüeti.)

## Performans (RINFO; bütçe uçuş 1 500 çizim / 3,5 M üçgen)

- Ölçülen kare: 1092; bütçeyi aşan: 16 halic_galata_023_ileri_030 1640 çizim 3.03 M; eser_35_altin_kapi_y150 1483 çizim 3.86 M; eser_35_altin_kapi_y080 1668 çizim 4.02 M; eser_35_altin_kapi_y040 1721 çizim 4.04 M; eser_35_altin_kapi_y015 1680 çizim 3.96 M; eser_35_altin_kapi_konmaK 1370 çizim 3.96 M; eser_36_pege_y150 1494 çizim 3.89 M; eser_36_pege_y080 1353 çizim 3.62 M; eser_37_kharisios_konmaG 1590 çizim 3.58 M; eser_37_kharisios_konmaB 1523 çizim 3.46 M; eser_38_kerkoporta_konmaG 1797 çizim 3.82 M; eser_08_surlar_y150 1606 çizim 3.69 M
- En yüksek 5 üçgen: eser_08_surlar_y040 1592 çizim 4.44 M; eser_08_surlar_y015 1691 çizim 4.31 M; eser_08_surlar_y080 1650 çizim 4.10 M; eser_35_altin_kapi_y040 1721 çizim 4.04 M; eser_35_altin_kapi_y080 1668 çizim 4.02 M
| tur | yükseklik | bakış | kare | çizim ort/maks | üçgen ort/maks (M) | en ağır kare |
|---|---|---|---|---|---|---|
| halic_galata | 030 m | asagi | 55 | 592 / 1162 | 0.71 / 1.11 | halic_galata_015_asagi_030 |
| halic_galata | 030 m | ileri | 55 | 885 / 1640 | 1.77 / 3.03 | halic_galata_023_ileri_030 |
| halic_galata | 060 m | asagi | 55 | 628 / 1193 | 0.87 / 1.32 | halic_galata_015_asagi_060 |
| halic_galata | 060 m | ileri | 55 | 718 / 1464 | 1.73 / 3.09 | halic_galata_023_ileri_060 |
| halic_galata | 120 m | asagi | 55 | 502 / 1064 | 1.11 / 1.96 | halic_galata_017_asagi_120 |
| halic_galata | 120 m | ileri | 55 | 523 / 1102 | 1.64 / 2.93 | halic_galata_023_ileri_120 |
| kara | 030 m | asagi | 28 | 813 / 1327 | 1.37 / 1.96 | kara_011_asagi_030 |
| kara | 030 m | ileri | 28 | 1115 / 1491 | 2.44 / 3.46 | kara_011_ileri_030 |
| kara | 060 m | asagi | 28 | 877 / 1243 | 1.60 / 2.23 | kara_011_asagi_060 |
| kara | 060 m | ileri | 28 | 970 / 1363 | 2.35 / 3.38 | kara_011_ileri_060 |
| kara | 120 m | asagi | 28 | 759 / 1080 | 1.86 / 2.56 | kara_010_asagi_120 |
| kara | 120 m | ileri | 28 | 716 / 1040 | 2.15 / 2.83 | kara_004_ileri_120 |
| marmara | 030 m | asagi | 23 | 423 / 558 | 0.60 / 0.84 | marmara_005_asagi_030 |
| marmara | 030 m | ileri | 23 | 694 / 1107 | 1.39 / 3.01 | marmara_004_ileri_030 |
| marmara | 060 m | asagi | 23 | 456 / 682 | 0.73 / 1.44 | marmara_005_asagi_060 |
| marmara | 060 m | ileri | 23 | 576 / 984 | 1.35 / 3.01 | marmara_004_ileri_060 |
| marmara | 120 m | asagi | 23 | 365 / 658 | 0.89 / 1.98 | marmara_004_asagi_120 |
| marmara | 120 m | ileri | 23 | 450 / 815 | 1.29 / 2.87 | marmara_004_ileri_120 |
| mese | 030 m | asagi | 6 | 526 / 624 | 1.39 / 1.57 | mese_003_asagi_030 |
| mese | 030 m | ileri | 6 | 727 / 779 | 2.90 / 3.12 | mese_003_ileri_030 |
| mese | 060 m | asagi | 6 | 598 / 670 | 1.54 / 1.77 | mese_003_asagi_060 |
| mese | 060 m | ileri | 6 | 639 / 685 | 2.75 / 2.94 | mese_003_ileri_060 |
| mese | 120 m | asagi | 6 | 539 / 576 | 1.76 / 2.08 | mese_004_asagi_120 |
| mese | 120 m | ileri | 6 | 538 / 588 | 2.60 / 2.77 | mese_003_ileri_120 |
| ordugah | 030 m | asagi | 20 | 377 / 617 | 1.47 / 2.95 | ordugah_018_asagi_030 |
| ordugah | 030 m | ileri | 20 | 647 / 876 | 2.27 / 3.15 | ordugah_017_ileri_030 |
| ordugah | 060 m | asagi | 20 | 512 / 776 | 1.67 / 2.82 | ordugah_017_asagi_060 |
| ordugah | 060 m | ileri | 20 | 688 / 912 | 2.30 / 2.99 | ordugah_017_ileri_060 |
| ordugah | 120 m | asagi | 20 | 686 / 913 | 1.96 / 2.72 | ordugah_017_asagi_120 |
| ordugah | 120 m | ileri | 20 | 648 / 943 | 2.11 / 2.81 | ordugah_015_ileri_120 |

Bütçeyi aşan tur karesi (çizim>1500 ya da üçgen>3,5 M): **1**.

## Sürekli uçuş / LOD
| uçuş | yükseklik | kare | en çok çizim | en çok üçgen (M) | betik ort/maks ms | >50 ms kare | LOD değişimi (örnekleme) | iş kuyruğu>0 kare (örnek) |
|---|---|---|---|---|---|---|---|---|
| halic | 60 m | 250 | 866 | 2.65 | 6.7 / 65.3 | 2 | 2 (/64 örnek) | 6 |
| kara | 30 m | 251 | 1559 | 3.09 | 9.4 / 334.9 | 5 | 0 (/65 örnek) | 4 |
| marmara | 30 m | 250 | 1103 | 2.78 | 5.2 / 34.0 | 0 | 2 (/62 örnek) | 6 |
| mese | 30 m | 250 | 704 | 2.80 | 7.2 / 89.6 | 2 | 2 (/63 örnek) | 6 |
| ordugah | 30 m | 251 | 1058 | 3.10 | 6.2 / 278.5 | 4 | 0 (/65 örnek) | 0 |

## Oyun içi uçuş (Bölüm 11 ve 7, HUD'lu)
`tests/_ist/gezi_havadan.oyun.gd` (baglama_ucus.gd kopyası + `q2` düzeltmesi), gerçek bölüm sahnesi (`scenes/chapter11.tscn` gece, `scenes/chapter7.tscn` gündüz), v2 bağlı (`IstBaglama.aktif()=true`), Nihat uçuşu, HUD'lu kareler (1280×720): her bölümde 17 kare: kalkış, ordugâh/surlar üstü, şehir üstü, 12 yan görev eseri yaklaşması, Galata dönüşü, eve dönüş. Kareler `kare/oyun11_*`, `kare/oyun7_*`; paftalar `pafta_p_oyun11_a/b`, `pafta_p_oyun7_a`.

| kare | B11 çizim / üçgen (M) | B7 çizim / üçgen (M) |
|---|---|---|
| 01_kalkis | 2162 / 3,84 | 2193 / 3,75 |
| 02_ordugah_ustu | **3994** / 2,04 | **3756** / 1,80 |
| 03_sehrin_ustu | 1025 / 2,00 | 1139 / 1,95 |
| 07_eser_havariyun | — | 1636 / 2,63 |
| 12_eser_surlar | 1507 / 3,08 | 1711 / 3,40 |
| 15_eser_markianos | 1238 / 2,79 | 1363 / 2,68 |
| 17_eve_donus | **3570** / 1,85 | **3573** / 1,66 |

- Uçuş bütçesi 1500 çizim / 3,5 M üçgen: **kalkış, ordugâh üstü ve eve dönüş karelerinde aşılıyor** (çizim 2,2–2,7 kat). Ayrıntı: bulgu tablosu PERF satırları.
- Açılışta 20 sn'lik takılma sayacı (`BAGLAMA_TAKILMA acilis_20sn`: B11 149 kareden 149'u > 50 ms, en uzun 3641 ms; B7 en uzun 1107 ms) yazılımla çizimde kare süresini içerdiğinden GPU karşılığı yoktur; yalnız B11 kurulumu (`ISTBAGLAMA … kurulum_ms=35819`) bölüm 7'den (daha kısa) ağır görünüyor.
- HUD'lu karelerde: B11 gece ordugâh ateşleri görünüyor (iyi), gece Hipodrom pisti ve beyaz çalılar ışıyor (bulgu), B7 hedef etiketleri çakışıyor (bulgu).

## 7) Bakamadıklarım
- **Bakılmayan kareler:** çekilen kare sayısının çoğunu paftalara koyup açmadım; açmadığım karelere "baktım" demiyorum. Turlarda her tur için yalnız örneklenmiş indekslerin (ileri_030, aşağı_060, bazılarında ileri_120) paftalarını açtım; `kara_*_ileri_060/ileri_120`, `halic_galata_*_ileri_060/120`, `marmara_*_ileri_120`, `ordugah_*_ileri_120`, çoğu `*_asagi_120` kareleri ve eserlerin `_konmaG/_konmaB` kareleri yalnız otomatik taramadan (siyah/beyaz oranı; `tara.py` mantığı: karenin alt %75'inde parlaklık < %7 ya da > %97 oranı) geçti, gözle açılmadı.
- **Adım 80 dünya m:** görevdeki "40 m'de bir" yerine 80 m (kara, Haliç+Galata), 120 m (Marmara, Mese) ve 160 m (ordugâh) adımı kullandım; yazılımla çizimde (llvmpipe) kare başına ≈2,5–3 sn olduğu için tam 40 m'lik tur (≈ 4 000+ kare) süreye sığmadı. Mese yolu (`IstGeo.yol("mese")`) yalnız ≈700 dünya m; 6 örnek noktası var.
- **Sürekli uçuş:** her uçuşta 75 m ark (≈ 250 kare, sabit dt = 1/60 sn, 18 m/sn) × 5 güzergâh = 1 250 kare; tamamını değil, her 30. kareyi (`kayit=30`) kaydettim; LOD belirme/kaybolmayı kare farkından ölçmedim, yalnız LOD sayaçlarının (`IstDunya.olcum().lod`) örneklemeli değişimini yazdım. Yazılımla çizimde "kare süresi" anlamlı olmadığından 50 ms sayısı **kare içi betik süresiyle** (process_frame → frame_pre_draw) yapıldı; GPU süresi ölçülemedi.
- **Bulut/sis/ufuk:** tur karelerinde ufukta kesik, sis çizgisi ve bulut gözlemi yapıldı (ufuk temiz, sis ince, bulut yok); gece havadan ayrı bölgeye (`gece`) bırakıldı, yalnız oyun içi Bölüm 11 (gece) karelerinde gördüklerimi yazdım.
- **Kod kaynağı:** çoğu bulgu için düğüm adı çözülemedi (başsız çalışmada AABB sıfır; ekranlı `--set=kim` benzeri sonda yazmadım). Kaynağı grep/kodla doğrulanmayanlara ŞÜPHELİ-kaynak yazdım.
- **Bölüm 7:** oyun içi kare koşusu aşağıda "Oyun içi uçuş" başlığında; bölüm 7 koşusu bitmediyse orada yazıldığı gibi.
- **Taban kusuru (bulgu dışı):** `tests/_ist/baglama_ucus.gd:129` taban dalda ayrıştırma hatası veriyor (`var q` iki kez bildirilmiş: "There is already a variable named q"); BAĞLAMA-3 oyun içi uçuş sondası bu hâliyle çalışmıyor. Ben kendi kopyamı (`tests/_ist/gezi_havadan.oyun.gd`, tek fark `q2`) çalıştırdım; ORTAK DOSYA ÖNERİSİ: orijinalde ikinci `var q`'yu `var q2` yapın.
