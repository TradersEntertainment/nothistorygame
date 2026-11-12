# GEZİ DENETİMİ — bölge `gece` (bütün şehir + ordugâh, GECE) — İLK GÖNDERİM (ara rapor)

Denetçi: bağımsız gezgin. Oyun kodu değiştirilmedi (yalnız `tests/_ist/gezi_gece.*`, `gezi_gece_kiyi.gd` ve bu klasör). Tüm kareler `gezi_gece.tscn -- gece=1` ile, 1280×720, yazılım GL.

## 1. Bölge, kare sayıları
- Bölge: bütün kara (doğu −7000…+700, kuzey −1900…+3600 gerçek m) ve ordugâh (batı −6600…−5100); sınır dört köşe: (−6600,−1500) (−6600,2700) (700,3600) (700,−1900).
- Izgara: GÖREV 150 m istiyor; 4 çekirdekli yazılım GL'de kare başına ~7–10 sn olduğu için ızgara **420 m** alındı (her düğümde iki yön) — SAPMA. Zorunlu yerler (Mese boyu, Ayasofya/Augustaion, Konstantin, hub, sur üstü/dışı altı nokta, Haliç, Marmara, Galata, ordugâh sekiz yer, havadan sekiz bakış) ayrı satırlar.
- Çekilen kare: ara rapor anında ~150 / planlanan 548 + 31 (kıyı/havadan yeniden). Bakılan (3×3 paftada incelenen): 90. Bakılmayan kareler için yalnız ortanca parlaklık/karanlık oranı (`ham_gece_satirlari.txt`) var; bunlardan bulgu YAZILMADI.
- Atlanan: deniz üzerine düşen düğümler (22 satır `GECE_SU`: Haliç iskeleleri, Marmara limanları, hava_3/5/6); kıyıya kaydırılıp yeniden çekiliyor (`liste_gece_kiyi_hava.txt`).
- Gerçek oyuncuyla yürüyüş (madde 6): bu ara raporda YAPILMADI (bakılmadı).
- Ham kare listesi: `liste_gece_ana.txt`; ham satırlar: `ham_gece_satirlari.txt` (ort=ortalama, medyan=ortanca parlaklık /255, karanlik= <%2 parlaklık oranı, çizim, üçgen).

## 2. GENEL NOT: 3,5 / 10
Sahibi geceyi gezerse ilk olarak ordugâha kızar: çadırlar gece parlayan gri piramitler, zemin kapkara ve ateş neredeyse yok. İkincisi ışık dili tutarsız: bir yanda kapkara cepheler, öbür yanda ay ışığında fosforlu çim, bembeyaz pencere/kemer/sur şeridi. Üçüncüsü kara surunda nöbetçi ve meşale yok.

## 3. BULGU TABLOSU
| no | tür | önem | yer | doğu, kuzey | kare | ne görünüyor | kaynak | öneri |
|---|---|---|---|---|---|---|---|---|
| G01 | GÖRSEL | 2 | Mese kuzey kolu, sur dibi cephe | -3612, 2524 (yük 1.7 m, yön 320°, eğim 0) | kare/mesek_05.jpg | Karenin %77'si siyah (ortanca parlaklık 3,2/255): tek bir bina cephesi hiç ışık/pencere almıyor, oyuncu duvara dönünce yol kayboluyor (medyan 3.2) | sehir.gd:3003 (gece üst kat pencere rastgele %40; zemin kat/yan cepheler ışıksız) ŞÜPHELİ kaynak | Her cepheye en az bir kandil/pencere ya da ay ışığı alt sınırı (ortanca ≥ 12) |
| G02 | ZEMİN | 2 | Mese kuzey kolu, kilise önü | -2450, 1150 (yük 1.7 m, yön 320°, eğim 0) | kare/mesek_02.jpg | Kilise kapkara siluet, önündeki çim ay ışığında bile fosforlu parlak yeşil: çim yapıya göre çok daha parlak, gece rengi yok (medyan 20.3) | zemin/çim gölgelendirici (sur_zemin.gd / mahalle_doku.gd) ŞÜPHELİ | Çimi gece kısılmış sönük yeşile çek; kilise cephesine hafif ay rengi |
| G03 | GÖRSEL | 2 | Mese güney kolu (Marmara'ya inen) | -3795, -830 (yük 1.7 m, yön 231°, eğim 0) | kare/meseg_05.jpg | Açık mavi-beyaz düz levha (kaldırım/duvar) gece kendi kendine parlıyor, üstünde havada ince yeşil çizgi; yamaçta cetvelle kesilmiş kenar (medyan 16.3) | bilinmiyor (kare: meseg_05) KANITSIZ kaynak | Levhaya doku+gece tonu; yeşil şerit nedir, yerine otur |
| G04 | GÖRSEL | 3 | Mese güney kolu | -4259, -1209 (yük 1.7 m, yön 231°, eğim 0) | kare/meseg_06.jpg | Kamera dev bir kapkara kütlenin dibinde (ortanca 3,0): yapı içi/dibi; zifiri (medyan 3.0) | kare: meseg_06 ŞÜPHELİ (kamera yapı içinde olabilir) | Yürüyüş yolundan geçip geçmediğini doğrula |
| G05 | GÖRSEL | 2 | Ayasofya içi (güney yan) | 40, 0 (yük 1.7 m, yön 270°, eğim 0) | kare/ayasofya_1.jpg | Pencereler saf BEYAZ dikdörtgen, çevresi simsiyah; ışık hüzmeleri kubbe içinde asılı kalmış şeritler gibi, kaynağı yok (medyan 15.0) | sehir_eser.gd:_arch (em = 2.2 if gece) + kubbe hüzmesi düğümü ŞÜPHELİ | Pencere emission'ını 0,6 ve sıcak/mavi tona çek; hüzmeyi pencereden çıkan koniye bağla |
| G06 | GÖRSEL | 2 | Ayasofya içi | -42, -40 (yük 1.7 m, yön 0°, eğim 0) | kare/ayasofya_3.jpg | Aynı: bembeyaz pencere sıraları + hüzme şeritleri; zemin ve duvar %69 siyah (medyan 3.0) | aynı | aynı |
| G07 | GÖRSEL | 2 | Augustaion yanı (Ayasofya batı) | -22, 34 (yük 1.7 m, yön 0°, eğim 0) | kare/augustaion_0.jpg | Bembeyaz iki dikdörtgen pencere duvarı tamamen karanlıkta: ışık kaynağı olmayan aydınlık; %74 siyah (medyan 3.0) | sehir_eser.gd:_arch | Pencere parlaklığını düşür, duvara ay/kandil dolgusu |
| G08 | KUTU | 2 | Konstantin Forumu (merkez, sütun kaidesi yöresi) | -756, 19 (yük 1.7 m, yön 180°, eğim 0) | kare/konstantin_0.jpg | Çıplak gri granit levha/kutu 6-8 m: köşeli, dokusu gürültü, üstünde ince beyaz çatı levhası: 'tek kutu' (medyan 34.7) | forumlar_yapi.gd:sutun (kaide) | Kaideyi basamaklı/profilli, pahlı yap |
| G09 | GÖRSEL | 2 | Konstantin Forumu | -726, -11 (yük 1.7 m, yön 270°, eğim 0) | kare/konstantin_1.jpg | Tuğla duvar yüzünde turuncu ışık sızması: dikey beyaz bıçak çizgisi + kaynaksız turuncu halo, sağdaki duvar kapkara ama tuğla ızgarası görünüyor (medyan 14.9) | forumlar_yapi.gd (ışık/kandil) ŞÜPHELİ | Kandili kaynak olarak yerleştir, bıçak çizgisini kaldır |
| G10 | ZEMİN | 3 | Konstantin Forumu havadan 40 m | -756, -60 (yük 40 m, yön 0°, eğim -35) | kare/konstantin_hava.jpg | Döşeme üstünde koyu siyah-gri leke/yamalar (kıvrımlı), sütun gövdesi simsiyah silindir, kaide ve başlık beyaz: gövde ile kaide arası ton uçurumu (medyan 25.2) | forumlar_yapi.gd:sutun ve forum zemin yaması | Gövdeyi porfir koyu erguvan, lekeleri döşemeyle karıştır |
| G11 | GÖRSEL | 2 | Hub (Romanos iç yanı) | -4660, 850 (yük 1.7 m, yön 135°, eğim 0) | kare/hub_1.jpg | Gece olmasına rağmen lavanta-mor ev cephesi ve pastel evler gündüz gibi parlak (ortanca 46,9: en parlak kare); ışık kaynağı yok (medyan 46.9) | hub sahnesi gece ışığı ŞÜPHELİ (hayat_yakin.gd?) | Hub cephelerini gece paletine indir |
| G12 | GÖRSEL | 2 | Hub | -4700, 810 (yük 1.7 m, yön 225°, eğim 0) | kare/hub_2.jpg | Kırmızı-beyaz elmas desenli dev duvar dokusu çok parlak (ışıyan yüzey), yanındaki evlerle ton kopuk (medyan 20.2) | hub cephe dokusu ŞÜPHELİ | Deseni gece kısılmış tona al |
| G13 | GÖRSEL | 3 | Hub | -4740, 850 (yük 1.7 m, yön 315°, eğim 0) | kare/hub_3.jpg | Kamera oda köşesinde: duvar+tavan karanlık, kapı kapkara; zifiri (medyan 12.7) | kare: hub_3 ŞÜPHELİ yapı içi | — |
| G14 | GÖRSEL | 2 | Kara suru dışı, Topkapı yöresi (-5030,1010) | -5030, 1010 (yük 1.7 m, yön 90°, eğim 0) | kare/surdisi_0.jpg | Surun dibinde boydan boya parlak beyaz yatay şerit (sur eteğinde ışıyan bant); çayır zifiri, ateş/meşale yok, uzaktaki çadır beyaz üçgen (medyan 11.9) | sur_zemin.gd / surlar.gd (sur eteği bandı) ŞÜPHELİ | Bandı sur taş rengine, gece kısılmış |
| G15 | GÖRSEL | 2 | Kara suru dışı güney (-5200,-1400) | -5200, -1400 (yük 1.7 m, yön 90°, eğim 0) | kare/surdisi_5.jpg | Surda parlak beyaz kare levha (kule kapısı?) ve beyaz şeritler; çayır tamamen kara: ateşsiz ova (medyan 11.2) | surlar_kapi.gd ŞÜPHELİ | aynı |
| G16 | GÖRSEL | 2 | Sur üstü, Topkapı yöresi | -4970, 300 (yük 14 m, yön 0°, eğim -4) | kare/surustu_2.jpg | Sur duvarı yüzünde açık mavi parlak şerit (hatıl) kendi kendine ışıyor, hendek tabanı kapkara (medyan 14.4) | sur_doku.gd (hatıl şeridi) ŞÜPHELİ | Şerit rengini gece değeriyle çarp |
| G17 | BOŞLUK | 2 | Sur üstü (-4300,1700) | -4180, 1700 (yük 14 m, yön 330°, eğim -4) | kare/surustu_3.jpg | Siyah kule siluetleri; surda tek bir nöbetçi/meşale yok, mazgal üstü sessiz (medyan 8.0) | surlar_ayrinti.gd / hayat (nöbetçi) ŞÜPHELİ | Her kuleye meşale + nöbetçi |
| G18 | GÖRSEL | 2 | Ordugâh batı obası (-5500,-400) | -5500, -400 (yük 1.7 m, yön 45°, eğim 0) | kare/ordugah_oba2_0.jpg | Konik çadırlar açık gri-mavi piramit: gece neredeyse kendi ışığıyla parlıyor, yanlarındaki kapkara çadırlarla ton uçurumu; piramit 4 yüzlü 'kutu-koni' (medyan 31.4) | ordugah_oba.gd:PALET (efe6cc) + çadır ağı ordugah_kit.gd | Çadırı gece rengine indir, oval kesit |
| G19 | KUTU | 2 | Ordugâh obası (-5600,1100) | -5600, 1100 (yük 1.7 m, yön 225°, eğim 0) | kare/ordugah_oba1_1.jpg | Kalın siyah dikey dikdörtgen direk (bayrak/sancak direği) ekranın ortasında; çadır dev çokgen kutu/piramit (medyan 24.4) | ordugah_oba.gd (sancak) / ordugah_kit.gd | Direği ince silindir yap |
| G20 | BOŞLUK | 1 | Ordugâh ön hat (-5080,880) | -5080, 880 (yük 1.7 m, yön 225°, eğim 0) | kare/ordugah_on_hat_1.jpg | Surdan 200 m ötede yalnız TEK ateş var, kamera çevresi zifiri: ordugâh cephe hattı gece ateşsiz/sönük (medyan 13.6) | ordugah_kanat.gd:144 (alev yalnız lod 0 ve üç ocaktan birinde) | Ön hatta sürekli meşale/ocak hattı |
| G21 | BOŞLUK | 2 | Ordugâh Anadolu kanadı (-5400,-1200) | -5400, -1200 (yük 1.7 m, yön 45°, eğim 0) | kare/ordugah_anadolu_0.jpg | Geniş kapkara düz zemin, uzakta bir ocak; kişi sayısı 5-6 beyaz figür sıra halinde (medyan 21.9) | ordugah_kanat.gd | Ocak/meşale sayısını artır |
| G22 | İYİ | 3 | Ordugâh Rumeli kanadı (-5300,2400) | -5300, 2400 (yük 1.7 m, yön 225°, eğim 0) | kare/ordugah_rumeli_1.jpg | (korunacak) ateş başında oturan askerler, ocak parlıyor, sancak ve çadırlar siluet (medyan 20.7) | ordugah_kanat.gd | — |
| G23 | ZEMİN | 1 | Hipodrom havadan 60 m (-300,-400) | -300, -400 (yük 60 m, yön 330°, eğim -30) | kare/hava_4.jpg | Hipodrom zemini NEON açık yeşil, üstünde pembe-gri düzensiz yamalar; gece rengi hiç yok, çevredeki şehirden belirgin parlak (medyan 26.9) | hipodrom_kit.gd (pist zemini) ŞÜPHELİ | Zemini gece toprak-kum rengine çek |
| G24 | GÖRSEL | 2 | Bozdoğan Kemeri havadan (-2400,1500) | -2400, 1500 (yük 60 m, yön 160°, eğim -30) | kare/hava_1.jpg | Kemer bembeyaz parlıyor, çevre çatılar koyu: ışıyan yanlış yüzey (medyan 28.1) | kemer.gd | Kemer taşını gece değeriyle çarp |
| G25 | GÖRSEL | 3 | Mese/Tauri havadan (-2000,100) | -2000, 100 (yük 60 m, yön 70°, eğim -30) | kare/hava_0.jpg | Şehirde bembeyaz çatı yamaları (hayat/gölgelik) ve mor/yeşil toplar parlıyor; geniş koyu boşluk bahçeler (medyan 23.9) | hayat_katman.gd ŞÜPHELİ | Beyaz yamalara gece tonu |
| G26 | GÖRSEL | 2 | Haliç, Perama (-1761,1813) | -1761, 1803 (yük 1.7 m, yön 0°, eğim 0) | kare/halic_perama_a.jpg | Sur/liman duvarı koyu lacivert dikdörtgen kütle, yüzü hiç ayrıntısız: duvar şeritleri çizgi gibi (medyan 7.8) | halic_sur.gd ŞÜPHELİ | Duvar dokusunu gece değerine yükselt |
| G27 | ZEMİN | 2 | Galata dışı, Pera yamaçları (-504,2034) | -504, 2034 (yük 1.7 m, yön 0°, eğim 0) | kare/galata_pera_a.jpg | Geniş yeşil çayır ay ışığında fosforlu; uzaktaki çadır/bina beyaz noktalar, gerçek ışık yok (medyan 20.3) | mahalle_doku.gd (zemin) ŞÜPHELİ | Çayırı gece kısılmış tona |
| G28 | GÖRSEL | 2 | Galata suru yanı (-760,1900) | -760, 1900 (yük 1.7 m, yön 0°, eğim 0) | kare/galata_sur_a.jpg | Tamamen siyah kare (medyan 3,0, %100 karanlık): kamera sur dibinde duvara gömülü ŞÜPHELİ (medyan 3.0) | galata_sur.gd | Oyuncu oraya girebiliyorsa çarpışma/ışık |
| G29 | GÖRSEL | 2 | Kara suru dışı hendek/sur arası (-5000,-440) | -5000, -440 (yük 1.7 m, yön 210°, eğim 0) | kare/izgara_003a.jpg | Tamamen siyah kare; hendek/sur kütlesi içinde ya da dibinde, yol bulunamaz (medyan 3.0) | izgara kare ŞÜPHELİ | Hendek tabanına ay ışığı alt sınırı |
| G30 | GÖRSEL | 3 | Hendek tabanı (-5000,400) | -5000, 400 (yük 1.7 m, yön 350°, eğim 0) | kare/izgara_005a.jpg | Hendek içinde kum tabanı okunuyor, sur kütlesi karanlık; yeşil-sarı kamışlar tek renk: iyi çalışıyor ama ayağı kaldıran ışık yok (medyan 20.0) | hendek (SUR-5 sürüyor) | — |

Kaynak sütunundaki "ŞÜPHELİ"/"KANITSIZ" = düğüm adı (`sur4_kare --set=kim`) çalıştırılmadı, dosya tahminidir. "Biliniyor" listesindekiler (kule kutu+çatı, ordugâh çadırları kulübe, ateş görünmüyor): G18, G19, G20, G21 ile örtüşür.

## 4. Tür sayımı (ara)
{'GÖRSEL': 20, 'ZEMİN': 4, 'KUTU': 2, 'BOŞLUK': 3, 'İYİ': 1}
KUTU kalan = 2 (G08, G19), hedef 0.

## 5. En kötü kareler (ara)
mesek_05, galata_sur_a, izgara_003a (zifiri); hava_4 (neon Hipodrom); ordugah_oba2_0 (parlayan piramit çadırlar); ayasofya_3; hub_2; konstantin_1; surdisi_0; mesek_02.

## 6. İYİ olan kareler (korunacaklar)
mese_04 / mesek_04 (kandil ışığı yolu ve tezgâh), ordugah_rumeli_1 (ateş başı), meseg_01 (çeşme/gölgelik sahnesi), konstantin_hava (şehir ışıkları), hava_2 (şehir pencere ışıkları).

## 7. Bakamadıklarım (ara)
Gerçek oyuncu yürüyüşü; 420 m ızgaranın büyük kısmı (yalnız sayısal ölçüm); düğüm adı/kaynak doğrulaması; Haliç/Marmara/Galata iskeleleri (yeniden çekim sürüyor); ordugâh otağ içi.
