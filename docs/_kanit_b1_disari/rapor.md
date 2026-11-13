# Bölüm 1 — garajdan dışarı bakınca "dünya yarım" (rapor)

## 1. Bulunan eksikler (ÖNCE taraması)
Sonda: bölümün gerçek `Garage` (outside=true) + Hikmet + oyuncunun kendi kamerası, macenta arka plan, 810 bakış
(kapı boyunca sol/orta/sağ × kapıya 0,4/1,5/3 m × yatay −70…+70° (10° adım) × dikey −25/0/+20° × göz 1,62 ve 1,00 m).
Oyunda çömelme düğmesi olmadığı için eğilmiş göz 1,00 m varsayıldı. Sonda `~/is/` altında, depoya girmez.
Not: sondanın ilk sürümü kendi kamerasıyla ayna duvarının katmanını (oyun başka kameradan siliyor) kaybediyordu;
tarama oyuncunun kamerasıyla yeniden yapıldı, aşağıdaki sayılar ondandır.

1. Karşı apartman tek 40 m'lik levha: üstü, yanı ve arkasındaki 120×60 perde boş/ham (en kötü kare: 170 bin macenta piksel).
2. Yol ve cephe x = ±20 m'de cetvelle kesik (kapının ucundan yola paralel bakınca).
3. Eşikte zemin boşluğu: garaj zemini z=3,0'da bitiyor, kaldırım 3,1'de başlıyor; aşağı bakışta macenta şerit.
4. Garajın kendi dışı: komşu bina yok, üstünde apartman yok, yol garajın yanında bitiyor.
5. Gök düz renk; perde kenarı görünüyor.
6. Kedi iki kutu + iki küre; araba ve branda düz kutu.

## 2. Macenta tablosu (810 bakış)
| | macenta > 0 olan kare |
|---|---|
| ÖNCE | **407 / 810** (en kötü 169 978 piksel) |
| SONRA | **0 / 810** |

Katı ölçüt: saf macenta (R>200, B>200, G<70), kaydedilen JPEG'lerden (`once_macenta_katı.json`, `sonra_macenta_katı.json`).
Sondanın kare-içi gevşek sayımı SONRA'da 89 karede 1–17 piksel gösterdi; hepsini baktım: Rubik küpünün kırmızı/mavi
kenar yumuşatması (bkz. büyütülmüş kırpma), arka plan değil. Gevşek ölçüt ÖNCE'de 422 kare.

## 3. Ne değişti
- `scripts/level/garage.gd:524-558` `_build_outside()`: eski dekor (levha apartman, 70 pencere kutusu, perde, minare, lamba,
  araba, kedi, yol/kaldırım) silindi; `GarageStreet.build(self)` çağrılır. Korunanlar: 4 su birikintisi, sokak lambası
  ışığı, soğuk dolgu ışığı, yağmur (1400) ve sıçrama (260) parçacıkları, geçen araba mantığı ve farı.
- `garage.gd:~588` geçen arabanın iki kutu gövdesi `GarageStreet.passing_car()` ile (yuvarlak gövde) değişti.
- `scripts/level/garage_street.gd` (yeni, ~880 satır): `Batch` (köşe renkli tek ağ üretici: kutu, levha, süperelipsoid, dönel
  gövde, boru, ızgara), `_ground` (yol, kaldırım, ufka kadar zemin, kavşak kolu; satır ~344), `_bldg`/`_buildings` (17 bina:
  balkon, saçak, dükkân kepengi, yazısız tabela, yanık pencere; ~408-525), `_skyline` (iki sıra silüet, 2 cami, 4 minare; ~528),
  `_tree`, `_lamp`, `car` (+`_tarp` branda), `cat`, `_manholes_pots`, `_puddles`, `_sky` (gök kubbesi, bulut gölgelendiricisi),
  `_halos` (lamba hâlesi, ışık havuzu).
- Dış dünya artık: iki yöne ±56 m yol ve kaldırım; uçlarda yolu kapatan binalar, sağda kavşak ve kuzeye giden kol (T-sonu
  binası); karşıda 7 farklı boyda apartman, aralarında 3 aralık (2'sinde ağaç); garajın iki yanında komşu binalar ve garajın üstünde
  apartman katları; park etmiş 4 araç; kaldırımda saksı/rögar; ıslak yoldaki pencere yansımaları; dome gök (macenta testinde de
  geometri olarak kapalı).
- Kapı/engel, kepenk, garajın içi, replik, akış değişmedi. Yalnız `garage.gd` ve yeni `garage_street.gd`.
- `outside` yalnız `chapter1.gd:31`'de true; `Garage.new()` kullanan 3, 5, 8, 13, 15, 16 `outside=false` (kapalı hâl) ve etkilenmez.

## 4. Bütçe (aynı 4 bakış, 6 kare ortalaması, `RenderingServer` kare bilgisi)
| bakış | çizim çağrısı ÖNCE → SONRA | üçgen ÖNCE → SONRA |
|---|---|---|
| A orta, 1,5 m, düz | 219 → 105 (−52%) | 173 766 → 189 700 (**+9,2%**) |
| B sol, 0,4 m, −50° | 149 → 121 (−19%) | 178 076 → 190 430 (+6,9%) |
| C sağ, 3 m, +30° | 969 → 764 (−21%) | 606 478 → 636 942 (+5,0%) |
| D eğilmiş sağ, −30°, aşağı | 330 → 307 (−7%) | 287 442 → 292 762 (+1,9%) |

Işık sayısı aynı (yeni ışık eklenmedi), yağmur 1400/260 aynı. Üçgen sayısı kare başına dünya bölgelerine (16 m) ayrılmış ağlarla
kısıldı; ağırlık dış hatlı (iki geçişli) yalnız Şahin, kedi, lamba. A bakışı sınıra yakın (+9,2%).

## 5. Kutu sayımı
Canlı/yuvarlak şeyde kutu: **0** (ÖNCE: kedi 2 kutu+2 küre, Şahin 8 kutu, geçen araba 2 kutu, lamba başlığı/kolu kutu).
Kedi: elipsoid gövde/baş/but, dönel bacak, koni kulak, boru kuyruk, parlayan gözler. Araba: süperelipsoid yuvarlak gövde,
eğimli cam kesitli kabin, dönel tekerlek, davlumbaz, sarkan kıvrımlı branda. Lamba: dönel gövde, boru kol, süperelipsoid başlık.
Ağaç, saksı, rögar: dönel/elipsoid. Kutu kalanlar: bina gövdesi/saçak/balkon/korkuluk, yol-kaldırım-bordür levhaları
(`garage_street.gd`'de 17 `.box(` bina/silüet, 6 `Props.box` zemin).

## 6. Testler (`--max-fps 20`)
Bölüm 1 çeşitleri `--autotest`, `=kick`, `=red` her biri ×2; Bölüm 3, 5, 8, 13, 15, 16 varsayılan; `parse_check`; `zfight_check`.
Sonuç (`testler.txt`): hepsi `AUTOTEST PASS`; `SCRIPT ERROR`, `VISAUDIT`, `WALKTHRU`, `HELDAUDIT`, `WARN_FX_STUCK`,
`WARN_FLY_ITEM`, `WARN_VOID_TELEPORT` satırı yok (12 koşu: 1 ×2, kick ×2, red ×2, 3, 5, 8, 13, 15, 16); `PARSECHECK PASS scripts=252`;
`ZFIGHT` satırı 0.

## 6b. Kanıt dosyaları
- `ciftler/`: 12 ÖNCE|SONRA çifti (1280×720 jpg, kalite 85) + `pafta_once_sonra.jpg`.
- `yakin/`: kedi, araba (ön/yan/arka), geçen araba, lamba, cephe, sokak sol/sağ, gök (sonda kamerası dışarıda; ÖNCE'si de var).
- `oynanis/`: `PACE=1 --autotest` ekranlı koşudan garaj evresi 4 kare (replik altyazılı). Bot Hikmet'e baktığı için sokak
  yalnız 3. ve 4. karede kapıdan görünür (4: araba, branda, kedi, yağmur, bina).
- `butce_*.txt`, `*_macenta_katı.json`, `*_tarama_ham.txt`, `ara_kayit/` (ilk 30 dk kaydı).

## 6c. Her SONRA karesi için bir cümle (ciftler/NN_*_sonra.jpg; hiçbirinde kesik kenar/macenta yok, kutu gibi duran canlı yok)
01 çömelmiş, yukarı bakış: farklı boyda üç apartman, balkon/yanık pencere, ağaç ve gök dolu. 02 sola bakış: bina sırası, tabela ve park etmiş
araba yola kadar sürüyor. 03 aşağı/sağ: kaldırım, yol, brandalı Şahin ve cadde sonu kapanıyor. 04 eşikte aşağı: zemin şeridi yok, kaldırım
yola bağlanıyor. 05 sağ uçta sola: yol boyunca uzayan sıra, park araç, kenar yok. 06 çömelmiş aşağı: eşik, kaldırım, karşı cephe tam.
07 yukarı-sola: kepenk altından sokak, araba ve cephe tam. 08 kapı önü: yol, Şahin, apartman sırası eksiksiz. 09 3 m yukarı: sokak kepenk
altından tam görünür. 10 3 m: aynı, Şahin ve binalar yerinde. 11 düz: yol, lamba direği, karşı sıra tam. 12 sol uçtan yola paralel: yol
sürüyor, apartmanlar sıralanıyor, uç kesik değil.


## 7. Kendi karelerime bakınca hâlâ kötü olanlar (dürüst)
- Islak yol yansıması zayıf: pencere çizgileri karanlık yolda neredeyse seçilmiyor; asıl parlaklık lamba havuzundan.
- Cepheler tekrar ediyor (aynı pencere kalıbı), yalnız renk/boy/balkon değişiyor; yüzeylerde doku yok, düz renk.
- Bulutlar loş; gök koyu mavi-mor, gerçek "şehir ışığı vurmuş bulut" daha belirgin olabilirdi.
- Ağaçlar koyu, yuvarlak bloklar; yakından çok sade.
- Yakın çekimde Şahin tekerlekleri 14 kenarlı, kedinin kulağı/ayakları çokgen; garajdan (8+ m) görünmez.
- Yağmur yalnız sokağın ön 24×13 m'sinde (parçacık sayısı aynı kalsın diye genişletilmedi): uzak binalarda yağmur yok.
- A bakışında üçgen +9,2%: sınırın altında ama az pay var.
- Mimari yan duvarlar (kavşak kolu) pencere almıyor, düz.
- Oyunda çömelme yok; eğilmiş göz 1,00 m varsayımdır.
