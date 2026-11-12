# İstanbul v2 — HAVADAN gezi denetimi (bölge `havadan`)

Dal `wip/gezi-havadan`; sonda `tests/_ist/gezi_havadan.gd/.tscn` (yalnız test; oyun kodu değişmedi). Taban `wip/ist2-gezi-taban`. Kare: yazılımla çizim (llvmpipe, 1280×720; sürekli uçuş 640×360).

## 1) Bölge, sayılar

- Bölge: bütün şehir havadan. Kamera yelpazesi (gerçek m, doğu/kuzey): doğu -5148…579, kuzey -1740…3484. Dört köşe ≈ (-5148,-1740) Mermer Kule/Marmara · (-5148,3484) Haliç ucu/Blakherna · (579,3484) Galata-Sarayburnu · (579,-1740) Marmara doğu ucu.
- Çekilen kare: **792** (klasör başına: eser=156, halic=330, kara=168, marmara=138). Bakılan kare (paftada açıp incelediğim): **246**. Bakmadığım kareler aşağıda "bakamadıklarım".
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
| H45 | MANTIK | 2 | Galata sur hattı (Haliç içi) | -1270, 2160 | kare/halic_galata_033_asagi_060.jpg | Suyun içinde testere dişi gibi dizilmiş koyu gri üçgen kama kuleleri olan uzun sur hattı kıyıdan uzakta; sayısal: IstGeo.yol('galata_suru') örneklerinin %24'ü suyun içinde (HVD_SU: SU@(-126,1669) … SU@(-811,1587)) | IstGeo.Y_GALATA / galata_sur.gd (hat kıyı çokgeninin dışında) | Galata sur hattını K_GALATA kıyısıyla hizala, suya taşan kısımları kıyıya çek |
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

## 4) Tür başına sayım

```
KUTU 15
ZEMİN 6
BOŞLUK/YAŞAM 4
GÖRSEL 23
PERFORMANS 1
OYNANIŞ 4
DÖNEM 1
GÖRSEL(LOD) 1
MANTIK 1
KUTU kalan=15
```

## 5) En kötü 12 kare
(derleniyor)

## 6) İyi olan 5 kare (korunacaklar)
(derleniyor)

## Performans (RINFO; bütçe uçuş 1 500 çizim / 3,5 M üçgen)

- Ölçülen kare: 804; bütçeyi aşan: 6 halic_galata_023_ileri_030 1640 çizim 3.03 M; eser_08_surlar_y150 1606 çizim 3.69 M; eser_08_surlar_y080 1650 çizim 4.10 M; eser_08_surlar_y040 1592 çizim 4.44 M; eser_08_surlar_y015 1691 çizim 4.31 M; eser_08_surlar_konmaD 1266 çizim 3.64 M
- En yüksek 5 üçgen: eser_08_surlar_y040 1592 çizim 4.44 M; eser_08_surlar_y015 1691 çizim 4.31 M; eser_08_surlar_y080 1650 çizim 4.10 M; eser_08_surlar_y150 1606 çizim 3.69 M; eser_08_surlar_konmaD 1266 çizim 3.64 M

## Sürekli uçuş / LOD
(derleniyor)

## Oyun içi uçuş (Bölüm 11 ve 7, HUD'lu)
(derleniyor)

## 7) Bakamadıklarım
(derleniyor)
