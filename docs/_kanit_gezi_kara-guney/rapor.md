# Gezi denetimi — bölge `kara-guney` — İLK GÖNDERİM (kısmi; son rapor değildir)

## 1. Bölge, kare sayıları, dürüst kapsam
- Bölge (gerçek metre doğu, kuzey): GB (-5250, -1850) · GD (-4650, -1850) · KD (-4650, 50) · KB (-5250, 50). Sur hattı `IstGeo.R_KARA` ilk 10 noktası (Mermer Kule -4875,-1705 → -4889,-47).
- Çekilen: 97 kare (`sur4_kare --set=liste`; liste `liste_hat.txt` 42 kare + `liste_t.txt` 55 kare). Bakılan: 97 kareden **45'i tek tek / 3×3 pafta ile** (pafta_a0,a1,a3 ve pafta_b0..b5 tam), tam boy açılan: 12. Kalan 52 karenin çoğu kamera sur/yapı içinde (bkz. 7).
- Yürüyüş (madde 6), gece (madde 5), 60 m ızgara (madde 2) **YAPILMADI**: bu gönderimde yalnız sur hattı boyunca ~150 m'de bir 5 kare (dış 90 m, dış 45 m, iç 70 m, hava 60 m, hava 20 m) + ilk koşuda 30/60 m dış, 30 m iç. Yürüyüş km = 0.
- Oyun kodu değiştirilmedi (yalnız bu klasör).

## 2. GENEL NOT: 4/10 (kısmi bakışa göre)
Sahibi sur dibine inince ilk sur üstündeki parlak limon-yeşil sekizgen "yosun" disklerine ve kule çatılarındaki düz pembe-mor levhalara kızar. İkincisi, Marmara ucunda beyaz çıplak kutular ve ahşap kafes kule denize uzanıyor, sur kuzeye doğru "düz gri levha" gibi. Üçüncüsü: sur dibi hendek/set yamaları keskin kenarlı düz renk planlar.

## 3. BULGU TABLOSU (no | tür | önem | yer | doğu,kuzey | kare | görünen | kaynak | öneri)
| 1 | KUTU/GÖRSEL | 2 | Mermer Kule yöresi | -4886,-1700 | kare/t00_dis90.jpg | Ekranın üçte biri çıplak beyaz mermer-dokulu dev levha (düz, derzsiz, pahsız); arkada kule altı havada, altında açık mavi dikdörtgen "zemin" | düğüm adı bilinmiyor (sur_4 `surlar_kapi/surlar.gd` kule payandası?) ŞÜPHELİ kaynak | pah+derz+taş dokusu; kule altı kapatılsın |
| 2 | GÖRSEL | 2 | aynı | aynı | kare/t00_dis90.jpg | Parlak kırmızı çubuk/halat çapraz ekranı kesiyor (oyuncak doygunluk, çok uzun) | bilinmiyor (iskele/`surlar.gd:_wedge`?) ŞÜPHELİ | rengi kerpiç/ahşap, uzunluğu kısalt |
| 3 | GÖRSEL | 3 | aynı | aynı | kare/t00_dis90.jpg | Kule dibinde açık mavi (cam gibi) kare zemin, çevresi koyu karo: su/ışık sızması gibi | bilinmiyor | zemin rengi/malzeme |
| 4 | KUTU | 2 | Marmara ucu, sur denize | -4900,-1730 | kare/t00_hava60.jpg | Sur köşesinde beyaz çıplak kutular (denize bakan 3 beyaz blok), iskele/kafes kule ince çizgi gibi denize uzanıyor | bilinmiyor (`marmara*.gd`) | beyaz kutular taş+tuğla; kafes kule ağaç iskele |
| 5 | GÖRSEL | 2 | aynı | aynı | kare/t00_hava60.jpg | Sur dış yüzü düz gri levha, derzler yalnız ince ızgara; ufka kadar tek renk | sur_doku / marmara sur | sur_doku taş bandı |
| 6 | KUTU | 3 | aynı | aynı | kare/t00_hava60.jpg | Pastel küre/küp "çalı"lar (beyaz, mor, nane) yamuk, oyuncak | `bitki*.gd` ŞÜPHELİ | ağaç/çalı dokulu |
| 7 | KUTU | 2 | Altın Kapı önü peribolos | -4860,-1650 | kare/t02_dis90.jpg | Sur üstünde parlak limon-yeşil 8 kenarlı diskler; yorum "solgun ot 5a6236" diyor ama kare parlak | `surlar_ayrinti.gd:126` (SphereMesh 6 seg ve 3 ring) | segment artır, renk gerçekten koyu/söndür |
| 8 | GÖRSEL | 2 | aynı | aynı | kare/t02_dis90.jpg | Parapet bandı moiré/tarak: gri şerit üstünde ince diş deseni (aliasing/z-fight) | `sur_doku.gd` parapet | doku mip/ölçek |
| 9 | ZEMİN | 2 | aynı | aynı | kare/t02_dis90.jpg | Hendek/set yamaları keskin, düz renk faset planlar (yeşil-hardal) | `sur_zemin.gd` ŞÜPHELİ | yumuşak geçiş |
| 10 | KUTU | 1 | sur kuleleri (iç sur) | -4960,-1450 | kare/t04_hava60.jpg | Kuleler düz pembe-mor beşik çatı (levha); "biliniyor" | `surlar.gd:_inner_tower` | kiremit/kurşun; kule çatısı sivri |
| 11 | DÖNEM ŞÜPHELİ | 1 | kıyıya yakın | görünen | kare/t04_hava60.jpg | Sağ üstte iki ince beyaz sivri kule minare gibi (Ayasofya yönü, ufuk) | bilinmiyor | belge: minare yok; kimin/ne olduğu doğrulansın |
| 12 | GÖRSEL | 2 | uzak dış sur kuleleri | -4960,-1450 | kare/t04_hava60.jpg | Soldaki uzak kuleler pembe şeritli çubuk gibi, yakındakilerle farklı renk/kutu (LOD) | uzak sur katmanı | yakın ile aynı palet |
| 13 | GÖRSEL | 3 | sur içi tepe | -4940,-1500 | kare/t01_hava20.jpg | Kule köşesi pah/derzsiz keskin keskin çıplak gri kutu; mazgallar koyu tuğla blok | `surlar.gd:_parapet_x` | pah, aşınma |
| 14 | GÖRSEL | 3 | sur dibi | -4950,-1000 | kare/t05_dis90.jpg | Sur üstünde sarmaşık yeşil küre + merdiven havada gibi (taş üstünde ahşap kafes) | `surlar_ayrinti.gd:100-126` | merdiveni yere/kule dibine bağla |
| 15 | ZEMİN ŞÜPHELİ | 2 | sur dışı hendek | -4900,-1130 | kare/s09_dis30.jpg | İki ochre düz dikey duvar arası kor koridor, taban yeşil; "kesilmiş hendek"; kamera yapı içinde olabilir ŞÜPHELİ | `sur_zemin.gd:moat` | doğrula; eğimli şev |
| 16 | GÖRSEL | 3 | sur dibi iç | -4885,-1634 | kare/s02_ic30.jpg | Duvarda çapraz parlak kırmızı çizgi (şerit çıkıntı), taş eşit renk; dışında kırmızı çatılı ev kutu ufukta | `sur_doku` / `surlar.gd` | çizgi kaldır |

(Hepsinin yeri kamera konumundan; kare adı = kanıt. "ŞÜPHELİ" = kare var, kaynak/yargı kesin değil.)

## 4. Tür sayımı
KUTU 4 (1,4,6,10) · GÖRSEL 7 · ZEMİN 2 · DÖNEM 1 (şüpheli) · MANTIK 0 · OYNANIŞ 0 (yürüyüş yapılmadı). **KUTU kalan=4** (bölgenin yalnız bakılan %'si).

## 5. En kötü 12 kare (şimdilik 5)
t00_dis90 (beyaz levha + kırmızı çubuk), t04_hava60 (pembe levha çatılı kuleler), t02_dis90 (limon disk + moiré), t00_hava60 (beyaz kutular), s09_dis30 (keskin hendek duvarları).

## 6. İyi olan karelerim
s01_ic30 (iç sur dibi pazar, taş yol, kişi), t01_ic70 (kuleler+tuğla şeritler), t03_hava60 (şehir üstten, sokak ağı), s02_dis30 (sur dışı eğim + sur süreklilik).

## 7. Bakamadıklarım / sorunlar
- Kamera yapı/sur içine düşen yaklaşık 50 kare (listenin 60 m dış kameraları sur içine düşüyor, karanlık veya ocre iç yüzey): bulgu SAYMADIM; yalnız s09 şüpheli. Gerçek hat/ızgara yerine hat çıkıntısı tahminiydi.
- 60 m ızgara, gece, gerçek oyuncuyla yürüyüş (≥1,2 km), kapıların (Altın Kapı, Ksylokerkos, Pege) tek tek çevresi: YAPILMADI. Ordugâh/hendek dışı 200 m dış yan sadece sur dibi karelerinde.
- RINFO: ham/rinfo.txt; en yüksek 2.86 M üçgen (hava60 kareleri, uçuş bütçesi 3,5 M içinde; yer bütçesi 2,5 M'yi 60 m kareleri aşıyor).
