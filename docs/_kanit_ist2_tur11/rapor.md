# TUR-11 — sur görünüşü: rapor

Dal `wip/ist2-tur11`, taban `wip/ist2-taban11` **2fa8fb35**. ÖNCE = aynı taban (`git archive 2fa8fb35`, depo dışı kopya, aynı içe
aktarma önbelleği), aynı makine, aynı kameralar; xvfb + Mesa llvmpipe, 1280×720 jpg 85.
Klasörler: `once/`, `sonra/` (c25, c21, yakin, saglam), `pafta/` (sol ÖNCE | sağ SONRA, yarım boy), `testler/`.

Kameralar
- Bölüm 25 `--chapter=25 --autotest=kare`: an_01…an_06 (tam boy hepsi; paftada 01, 02, 04, 05, 06).
- Bölüm 21 `--chapter=21 --autotest=kare`: an_01 (Grant, gri dörtgen), an_05 (peribolos).
- YAKIN sahne (yeni) `tests/_ist/tur11_kare.tscn` = tur10_yakin'in aynı kurulumu ve kameraları (y1…y8) + **a1** (Bölüm 25 an_01
  benzeri: dış sur yolu, mazgal açıklığı, göz 1,62 m, FOV 72, ovaya) + **y7** (stauroma fıçıları, sur yolu boyunca) +
  `--olc` (ışınla tuğla ölçümü) + `--saglam` (s1–s3). Gece (`--gece`, Bölüm 20/25 ışığı) ve gündüz.

## 1. Sahibin karesi (Bölüm 25 an_01, "oyuncak gibi surlar") — **TAMAM (diş ve korkuluk) / KISMEN (harpuşta)**

### Tuğla ölçümü (ışınla) ve "iri tuğla"nın kök nedeni
- Sahnedeki tuğla sırası gerçekten **8,4 cm** (hatıl 0,42 m / 5 sıra; ≈4,5 cm tuğla + ≈3,9 cm harç). Ölçü doğru.
- `tur11_kare --olc` (ÖNCE kopyasında, `testler/olc_once.txt`): y1 ve a1 kameralarında ışın, korkuluk tepesinde (y = 9,70 =
  OH + 1,20) hatıl sırasına giriyor: hatıl dünya y'sinde **9,63 … 10,05 m = OH + 1,13 … OH + 1,55**. Yani desen dünya y'sine bağlı
  olduğu için Mesoteikhion'da (OH = 8,5) beş sıralık hatıl **korkuluğun son 7 cm'i + dişin alt 35 cm'ine** düşüyor: göz (OH +
  1,62) hizasının 7–49 cm altında, tam bakış çizgisinde.
- Ekranda: 8,4 cm'lik bir sıra 0,6 m'de (FOV 72–75) ≈ 70–77 px, 1 m'de ≈ 45 px. Bu yakınlıkta gerçek tuğla da bu kadar büyük
  görünür; "üç sıra ≈ 40 cm" algısı, 0,6 m'lik dişin yarısını kaplayan 42 cm'lik kızıl-gri şeritli bant + harcın tuğla kadar kalın
  ve açık olmasından (her sıra iki şerit okunuyor) geliyordu: diş "tuğla kutu" (ÖNCE `once/yakin/gun_y1…`, `gece_y1…`).
- Düzeltme: diş ve korkuluk ince taş örgüye geçti (aşağıda); hatıl yalnız sur gövdesinde (gövdede ölçü ve kuşak aynı). FOV, kamera
  ve korkuluk yüksekliği değişmedi (oynanış/ölçü sözleşmesi).

### Ne yapıldı (ölçü, çarpışma AYNI; sözleşme üçlüsü aynı)
| dosya | değişiklik |
|---|---|
| `sur_doku.gd` (gölgelendirici) | **Köşe alfası işareti** (pişiricide korunur): 0,86–0,95 = ince taş örgü, 0,75–0,86 = harpuşta (< 0,75 döküntü taşı, eskisi gibi). **İnce örgü** (diş + korkuluk): sıra 0,2 m (0,6 m'lik dişte 3 sıra, korkulukta 6), blok 0,30–0,62 m, derz 1,8–2,4 cm (girintili, koyu), blok blok ton (soğuk gri ↔ bal, %10 onarım taşı), aşınmış kenar (2,5–7 cm), %45'inde kırık köşe, gözenek/liken/benek; **tuğla hatılı yok**. **Harpuşta**: tek taş, derzsiz; dane, çukurcuk, sarımsı gri ve koyu liken, üstte yosun, kılcal çatlak; alt yüzü gölgede. **Sahte kabartma**: taş kenarında normal blok kenarına doğru eğilir (örgüde ve sur gövdesinin taş kuşağında, yakında; hatılda yok) → bloklar yastık gibi, derz girintili okunur. Gece payı (`gece`) aynı. |
| `sur_kule.gd disler_ag/_dis_tas` | Diş = **örülmüş gövde** (pahlı altıgen prizma, alfa 0,9) + **ayrı harpuşta** (alfa 0,8): her yandan 2,5–4,5 cm taşkın, 12–16 cm kalın, üst kenarı pahlı (4,5–7,5 cm, yuvarlanmış), sur yoluna eğimli, köşeleri tek tek ±2 cm oynak, yana hafif yatık, tepesi hafif kubbeli; %30'unda bir köşesi kırık. Yıkık diş (%9) harpuştasız, kırık pürüzlü tepe. Kaplama aynı (en, derinlik, boy); çarpışma yok (korkuluk kutusu aynı). 34 üçgen/diş (eski 28), tek ağ. |
| `surlar.gd _parapet_x/_parapet_z` | Korkuluk (lod 0) köşe alfası 0,9 → ince örgü. Kutu ve çarpışma aynı. |

### Her SONRA karesine tek cümle ("oyuncak gibi mi?")
Bölüm 25 (`sonra/c25`, gece; `pafta/c25.jpg`):
- **an_01**: iki diş ve korkuluk 0,2 m'lik taş sıralarıyla örülmüş, derzli, blok blok tonlu; tuğla şeridi yok; dişlerin üstünde ayrı, taşkın, koyu harpuşta; kutu yok, havada yok, korkuluğa oturuyor, ordugâhla aynı gece tonu — **oyuncak değil; harpuşta bu mesafede hâlâ biraz düz levha gibi (kısmen).**
- an_02: sağdaki dişler örgülü, harpuştalı; nöbetçilerle aynı resim — **oyuncak değil.**
- an_04: fıçılar artık sur yolunun zemininde, korkuluğa yaslı, insan beline kadar; aralarında korkuluğa dayalı kazıklar; dişler örgülü — **oyuncak değil** (sağ kenardaki iri koyu kütle dış kule tepesi; değişmedi, gece çok koyu).
- an_03, an_05, an_06: sur gece tonunda; an_06 gedik yanakları değişmedi (koyu) — **değişmedi / iyi.**

YAKIN (`sonra/yakin`, `pafta/yakin_gece.jpg`, `pafta/yakin_gun.jpg`):
- y1 (0,6 m): ÖNCE tuğla bantlı "kutu" + pürüzsüz eğik tepe → SONRA 3 sıra taş blok, kabartmalı kenar, ayrı harpuşta — **oyuncak değil; harpuşta üstü gündüz yeşilimsi gölge (ışık), kenarı cetvele yakın.**
- a1 (an_01 benzeri): aynı — **oyuncak değil.**
- y2 (iç sur korkuluğu 1,5 m): korkuluk ve dişler örgülü; ÖNCE'nin düz gri kama dişleri gitti — **oyuncak değil.**
- y5, y6 (sur yolu boyunca / üstten): dişler harpuştalı sıra; korkuluk taş taş — **oyuncak değil.**
- y4 (sur dibinden 2 m): sur gövdesi aynı desen + taş kenarı kabartması (bloklar yastık gibi) — **oyuncak değil.**
- y7 (stauroma): fıçılar yolda, korkuluğa yaslı, gerçek ölçek — **iyi.**
- y3, y8: değişmedi (y8 gedik fıçıları; taşıma oturumunun aşama parçası).

**Bitti ölçütü**: an_01'de dişler ve korkuluk taş örgü olarak okunuyor; kutu yok. Tepe taşı ayrı taş, ama "levha" izlenimi tam
gitmedi → harpuşta için **KISMEN**.

## 2. Sur yolunda dev fıçılar — **TAMAM**
- Kök neden: `surlar_ayrinti.gd _stauroma` fıçıları **korkuluğun üstüne** (y = OH + 1,2, göz hizası) koyuyordu; arkalarındaki toprak
  yığını ve kalas da korkuluk üstündeydi, kazıkların dibi korkuluğun dışında havadaydı.
- Şimdi: 4 fıçı **sur yolunun zemininde** (y = OH), korkuluğun iç yüzüne yaslı (karın 4–6 cm değer), ölçü fıçı ağının kendisi
  (boy 0,92 m, karın çapı 0,66 m). Toprak yığını/kalas kaldırıldı; 3 kazık fıçıların arasında, dibi yolda, tepesi korkuluğa dayalı.
- Çarpışma: görünen karına daraltılmış dışbükey kabuk (r ≈ 0,29); iç kenarı korkuluktan 0,57 m → 1,7 m'lik sur yolunun ortası
  (0,3 m'lik oyuncu kapsülü) serbest. Sur yolu yürüyüşü **7/7** aynı; Bölüm 25 autotest PASS.
- Kareler: `pafta/c25.jpg` an_04, `sonra/yakin/*_y7_stauroma_sur_yolu.jpg`.

## 3. Bölüm 28o için sağlam sur kipi — **TAMAM**
- Arayüz: `SurOyun.kur(id, {"saglam": true, …})`. Varsayılan `false` = bugünkü gedikli kesim, **birebir aynı** (sözleşme üçlüsü
  aşağıda aynı).
- Uygulama (`sur_oyun.gd`, yalnız ekleme): `saglam_yap()` donmuş kesim satırının **derin kopyasında** gedik listesini boşaltır
  (oyun gediği + dekor gedik + yan dilimlerin dekor gedikleri), gedik yüzünden `dis_yikik` sayılan dış kuleyi sağlam kuleye
  (`dis`) taşır, `gx = NAN`. Kurucu bu kopyayla gediksiz dilim kurar: iç/dış sur, sur yolu, korkuluk ve dişler sürekli, yıkık kule
  yerine sağlam kule (basamaklı tepesi), gedik molozu ve `GedikOnarim` yok. Bütün sorgular aynı kopyadan: `yol("dis")` kesik = 0,
  `gedik()` = {}, `mazgallar("dis")` 71 → 78, `engeller()`/`noktalar()` gediksiz. Donmuş sözleşme dosyası değişmez.
- Yürüyüş `tests/_ist/tur11_saglam_yuru.tscn` (gerçek Player botu, sur_oyun_yuru'nun `_bot`'u):
  `SAGLAMYURU OZET yol=3 tamam=3 takilma=0 dusme=0 kesik=0` — dış sur yolu eski gedik yerinin ve sağlamlaşan kulenin üstünden
  (gx ± 14), iç sur yolu, peribolos eski gedik önü (`testler/tur11_saglam_yuru.txt`).
- Kareler: `sonra/saglam/{gece,gun}_s1…s3`, `pafta/saglam.jpg` (sol: varsayılan kip aynı kamera — gedik; sağ: sağlam kip).
- **Kullanım notu (taşıma 6/7, 28o)**: `var k := SurOyun.kur("mesoteikhion", {"ebeveyn": set, "saglam": true, "kalas": false,
  "dolgu": 0.0})`. `a.gx` NAN, `a.gedik()` boş: bölüm gediğe sabit yazmamalı; gedik x'i gerekiyorsa (ör. 28o'da ilk atışın hedefi)
  `SurOyun.arayuz("mesoteikhion").gx` (varsayılan kipin değeri) kullanılır. `asama` sağlam kipte yok sayılır. Hendek geçişleri
  (kalas, dolgu yeri) sözleşmeden aynen gelir; dolguyu 0 vermek bölümün kararı. `SurSet` bağdaştırıcısına (`sur_set*.gd`, taşıma)
  bu seçeneği geçirmek **taşımaya istek**.

## 4. Kalanlar
| madde | durum | kare / not |
|---|---|---|
| Bölüm 21 an_01 peribolos çıplak zemin (gri dörtgen) | **TAMAM** | Kaynak (`tests/_ist/tur11_zemin_sonda.tscn`): `OyunDilimi/Mesoteikhion/@MeshInstance3D` = pişmiş "dirt" desenli levhalar (60 üçgen: şehir önü, peribolos, temel, teras; Props deseni). Kesimde bu levhalar eteklerle **aynı** `zemin_v2` malzemesine geçti (`surlar.gd _levha_zemin_v2`; köşe rengi toprak ipucu, ölçü/çarpışma aynı). `pafta/c21.jpg`: an_01'de düz gri dörtgen yok, zemin eteğin dokusuyla süreklidir; an_05 peribolos zemini dokulu. Kalan: an_01 sol altta eteğin kenarında çok hafif ton farkı. |
| c5 hendek dış kıyısı düz kenar | **YAPILMADI** | zaman ana maddeye |
| Bölüm 20 an_03 sur dibi bej bant | **YAPILMADI** | — |
| D4 koyu paneller | **YAPILMADI** | — |

## Üç sözleşme denetimi (varsayılan kip; ÖNCE = tur 10 raporundaki taban değerleri)
| denetim | ÖNCE | SONRA |
|---|---|---|
| `tests/_ist/sur_sozlesme.tscn` | `SURSOZLESME PASS kalem=13 kesim=8` | `SURSOZLESME PASS kalem=13 kesim=8` |
| `tests/_ist/sur_oyun_denetim.tscn` | `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` | `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` |
| `tests/_ist/sur_oyun_yuru.tscn` | `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` | `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` |
Sağlam kip ayrıca: `SAGLAMYURU OZET yol=3 tamam=3 takilma=0 dusme=0 kesik=0`.

## Testler (son kod, `--max-fps 20`, tam süzgeç + `SHADER ERROR`)
- `tests/parse_check.tscn` → `PARSECHECK PASS scripts=357`.
- Bölüm autotest (`testler/bolum.txt`): bkz. dosya (her satır: denetim satırı sayısı | AUTOTEST satırı).

## Bütçe (ÖNCE ↔ SONRA, aynı kamera)
| kare | çizim ÖNCE | çizim SONRA | ilkel ÖNCE | ilkel SONRA | Δ ilkel |
|---|---|---|---|---|---|
| c25 an_01 | 3683 | 3681 | 5 668 066 | 5 671 052 | +0,1% |
| c25 an_02 | 2092 | 2090 | 3 274 029 | 3 276 949 | +0,1% |
| c25 an_03 | 3700 | 3692 | 5 676 906 | 5 673 764 | −0,1% |
| c25 an_04 | 2064 | 2068 | 3 269 200 | 3 271 144 | +0,1% |
| c25 an_05 | 598 | 577 | 798 165 | 769 271 | −3,6% |
| c25 an_06 | 1880 | 1911 | 3 040 463 | 3 105 355 | **+2,1%** (çizim +1,6%) |
| c21 an_01 | 349 | 348 | 318 011 | 320 327 | +0,7% |
| c21 an_05 | 2033 | 2004 | 2 647 126 | 2 610 792 | −1,4% |
| yakın gece y1 | 65 | 64 | 255 880 | 258 196 | +0,9% |
| yakın gece a1 | 46 | 46 | 208 834 | 212 280 | +1,7% |
| yakın gece y2 | 164 | 162 | 328 497 | 331 417 | +0,9% |
| yakın gece y5 | 154 | 152 | 323 041 | 325 961 | +0,9% |
| yakın gün y1 | 57 | 56 | 232 436 | 234 752 | +1,0% |
| yakın gün a1 | 45 | 45 | 198 706 | 203 102 | **+2,2%** |
| yakın gün y2 | 168 | 166 | 325 257 | 330 317 | +1,6% |
| yakın gün y6 | 158 | 156 | 331 297 | 334 581 | +1,0% |
Hepsi +%5 içinde. Fıçı düğümü azaldı (toprak yığını + kalas yok: −2 çizim/stauroma). Bölüm 25 kareleri NPC durumundan da etkilenir.
Gölgelendirici maliyeti (örgü dalı + normal eğimi) gerçek GPU'da ölçülmedi.

## Kutu sayımı
- Mazgal dişi: tur 10'da kutu değildi; şimdi gövde + ayrı tepe taşı. Korkuluk gövdesi hâlâ kutu (`_s`, çarpışma/sözleşme ölçüsü),
  yüzü artık ince taş örgü. Yıkık korkuluk kalıntısı (`YikikKorkuluk`) basamaklı kutular (değişmedi). Köşe kulesi (`kose`) dişleri
  hâlâ kutu (bu kesimde yok; şehirde).

## Hâlâ kötü olanlar (dürüst)
- **Harpuşta**: ayrı taş olarak okunuyor ama 0,6 m'de kenarı hâlâ cetvele yakın, gece koyu düz yüz; gündüz gölgede yeşilimsi
  (sahnenin gök ışığı × sıcak taş; ÖNCE'de de vardı).
- Örgü blokları yakında biraz "yastık" (kabartma normali toon ışıkta yumuşak); gündüz gölgede yeşilimsi gri.
- an_04 / s1 sağ kenardaki iri koyu kütle (dış kule tepesi) gece çok koyu, düz yüzlü.
- `tur11_kare` s2 kamerasında gökte duran koyu "T" biçimli iki nesne ve koyu dikdörtgen: **SurOyun kökünün altında değil**
  (sonda: kökün altında bu bölgede küçük görünür nesne yok), iki kipte aynı ekran yerinde → test sahnesine özgü; kaynağı bulunmadı.
- Bölüm 20 an_03 bej bant, c5 hendek kıyısı, D4 paneller: yapılmadı.
- Gerçek GPU'da kare süresi ölçülmedi.

## İstekler
- **Taşımaya istek**: `SurSet` bağdaştırıcısı `"saglam"` seçeneğini `SurOyun.kur`'a geçirsin (28o).
- **run_tests.sh isteği**: `tests/_ist/tur11_saglam_yuru.tscn` (başsız, ≈1 dk).

## Değişen dosyalar
| dosya | ne |
|---|---|
| `scripts/world/ist/sur_doku.gd` | köşe alfası işareti, ince örgü, harpuşta, sahte kabartma |
| `scripts/world/ist/sur_kule.gd` | `_dis_tas`: örülmüş gövde + harpuşta |
| `scripts/world/ist/surlar.gd` | korkuluk işareti; `_levha_zemin_v2` (kesimde dirt levhalar → zemin_v2) |
| `scripts/world/ist/surlar_ayrinti.gd` | `_stauroma` (fıçılar sur yolunda), `_barrel(…, daralt)` |
| `scripts/world/ist/sur_oyun.gd` | yalnız ekleme: `saglam`, `saglam_yap()`, `kur` seçeneği |
| `tests/_ist/tur11_kare.*`, `tur11_saglam_yuru.*`, `tur11_zemin_sonda.*` (yeni) | kare/ölçüm, sağlam yürüyüş, zemin sondası |
Dokunulmayanlar: bölüm dosyaları, `sur_set*`, `GedikOnarim`, `sehir.gd`, `night.gd`, `look.gd`, `project.godot`, sözleşme. Replik,
ses, denge, gizli süre, sayaç değişmedi.
