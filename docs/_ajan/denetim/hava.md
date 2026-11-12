# Bağımsız denetim: havadan şehir, ateşler, özel yapılar (tek harita P0)

Denetçi: bağımsız oturum. Dal `wip/denetim-hava` (geliştirici HEAD `ef860ea2` üzerinden), taban `e551de84`.
Oyun koduna dokunulmadı; kendi koşularım ve kendi karelerim. Geliştirici raporuna (`docs/_ajan/rapor/hava.md`) bakıldı ama hüküm onunla değil kendi karelerimle verildi.

## GENEL HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL

İşin özü gerçekten yapılmış: havadan görünen Ayasofya, Blakherna, Havariyun, Bozdoğan Kemeri, Hub (Romanos Kapısı, kançılarya, saray avlusu) artık yerdeki kurucuların ağlarıyla, aynı yerde ve ölçüde duruyor; kara surlarındaki ve Blakherna'daki ateşler küp değil alev; konma, çarpışma ve test paketi sağlam (51/51 PASS). Ama geliştirici raporunda üç iddia kendi ölçümlerimle tutmuyor:

1. "Üçgen artışı ölçtüğüm bütün bakışlarda %8'in altında": **YANLIŞ**. Ayasofya'ya yakın bakışlarda üçgen +%27 (ortanca) ile +%62 (en yüksek), çizim sayısı +%17 ile +%291 arttı (ölçü yöntemi ve tablo aşağıda, `perf_tablolari.md`).
2. "Hub yerdeki modelleriyle görünüyor: yer, ölçü, renk ve doku aynı": **KISMEN**. Yer ve ölçü aynı; ama hub'ın küçük evleri havadan **kiremitsiz, soluk kutular** (gece beyaz eğik düzlemler), yerde terrakota kiremit çatılı Kit evleri. "Özel binalar küp küp" şikâyetinin bir kısmı hub evlerinde sürüyor (4. ve 5. pafta).
3. "Kıyı surlarının nöbet ateşleri alev": **KISMEN**. Kule çatısındaki ateş alev (ÖNCE sarı kutu); ama kıyı surundaki iki ateş noktasında (Haliç suru, Marmara suru) ne ÖNCE'de kutu ne SONRA'da alev seçiliyor.

ZORUNLU düzeltme listesi en altta (Z1–Z4).

## Yöntem ve koşullar

- Makine: 4 çekirdek, llvmpipe; ekranlı koşular `xvfb-run` 960x540. Başsız koşular `--max-fps 20`.
- **ÖNCE sürümü**: depo dışında tam kopya (`/tmp/onceki_repo`), yalnız görev dosyasındaki 12 dosya `git checkout e551de84 --` ile geri alındı (`parse_check` o kopyada da PASS). SONRA: depo (`wip/denetim-hava`).
- **Kare aracı**: kendi sondam (`tests/_tmp/denetim_probe.*`, **depoya girmiyor, iş bitince silindi**). Gerçek bölümü açıyor (`--chapter=11`, `--chapter=7`, `--chapter=7 --outcome=6:6b.1`), oyuncunun uçuşunu (`NihatPowers.set_flying`) açıp kamerayı verilen noktaya koyuyor, kare kaydediyor ve `RenderingServer` çizim/üçgen sayaçlarını yazıyor (RINFO'nun kullandığı sayaçlar). ÖNCE ve SONRA aynı JSON'la, aynı kamera konumu ve yönüyle koşuldu; sayılar iki koşuda birebir tutuyor (gürültü yok). El ve form modeli (kamerada duran düğümler) gizli.
- Gece uçuşu: Bölüm 11. Gündüz: Bölüm 7a (ordugâh, `day.world`) ve 7b (şehir, `city.world`).
- Yer-uçuş karşılaştırması için yerdeki bölümlerin gerçek başlangıç konumunu sonda okudu (`startw`), aynı dünya koordinatı Bölüm 11 uçuşunda ÖNCE/SONRA kuruldu.

## Testler (başsız, ham satırlar `ham_testler.txt`)

| Test | Sonuç |
|---|---|
| `parse_check` | `PARSECHECK PASS scripts=248` |
| `tests/flight_check` | `FLIGHTCHECK PASS` (camp ve walls: 9 yer işareti, 12 parça, 3 konma) |
| 3 | PASS |
| 4 (9 varyant: —, item, caught, market, chain, nofez, fall, fez, wet) | 9/9 PASS |
| 6 (—, byz) | 2/2 PASS |
| 7 (—, tea, lost, form, wall, wallkeep, byz, byzniko, byzcell, fez) | 10/10 PASS |
| 8, 8y, 9, 10 | 4/4 PASS |
| 11 (—, arrest, escape, persuade, help, helpwall, lost, fired, hikmet, niko) | 10/10 PASS |
| 17, 17o, 18, 19, 24, 24o, 25, 26, 27, 29, 30, 31o, 32o, 39o, 43o | 15/15 PASS |

Toplam **51/51 `AUTOTEST PASS`**; her koşuda `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `LOOKAUDIT backturn`, `JOURNEY_MISS`, `JOURNEY_OVERLAP` sayısı **0**. (Not: varyantlar için `tests/run_tests.sh` listesindeki adları kullandım. 31o, 32o, 39o, 43o, 6, 8, 20 için yalnız varsayılan yol.)

## Kurallara uygunluk (`git diff e551de84 -- <12 dosya>`)

- 12 dosya: +763 / −153 satır. Replik, süre, sayaç, sonuç, kalabalık sayısı, bot yolu değişikliği **yok**. Bulduğum tek "sayısal" değişiklik `HornWorld._wall_men` y'si (`15.0` → `Blachernae.WALK_Y`): konum, sayı aynı.
- Kanca / susturma: `no_audit`, `_ok`, `OS.get_environment`, `print`, `tests/_tmp` yolu, filtre: **yok**. Yeni `set_meta("no_walk")`, `set_meta("soft")`, `flame_xf` kullanımları var; `no_walk`/`soft` depoda eski gelenek (gulls.gd, slipway.gd, vfx.gd vb.), denetim susturması değil (WorldWalk'un çarpışma üretmediği süs ağları).
- Yeni `class_name` dosyası: 12 dosyada yok (`scripts/player/shadow_body.gd` başka paketin, `class_name` içermiyor).
- `tests/_tmp` boş/yok, geliştiricinin kancası kalmamış.

## Madde madde (görev dosyasındaki 1–8)

### 1) Ateşler
| Alt madde | Hüküm | Kanıt |
|---|---|---|
| Kara surları nöbet ateşi (uzaktan/15 m/3 m/tepeden) | **DOĞRULANDI** | pafta 08, kare `f11_*/fire_land_m15, _m3, _top`. ÖNCE: sarı-turuncu kutu; SONRA: küçük, yuvarlak, yanan alev. Tepeden: turuncu yuvarlak leke (çizgi/kare yok). |
| Blakherna ateşi | **DOĞRULANDI** | pafta 08, `fire_blach_m15, _m3, _top`: ÖNCE sarı dikdörtgen, SONRA alev. |
| Haliç suru, kule çatısı ateşi | **DOĞRULANDI** | pafta 09, `c11_*/c_coast2_az90`: ÖNCE sarı kutu, SONRA alev. |
| Haliç suru (merlon yanı, −700,8/23,5/−612,3) ve Marmara suru (−371,9/21/−1416) ateşi | **YANLIŞ/KANITSIZ: görünmüyor** | pafta 09, `c_coast_az0/90/180/270`, `c_marm_az*`, `fire_coast_m3`, `fire_marm_m3`. Dünya bu noktalarda alev örneği kuruyor (sondayla doğruladım: `GlowFlames` görünür, ölçü 0,28×0,55) ama dört yönden de 6 m'den bakınca ne alev ne kutu seçiliyor; ÖNCE'de de seçilmiyordu (merlon/sandık blokları arasında gömülü). Yani "küp küp" kalmadı ama bu ateşler hâlâ oyuncuya görünmüyor. Z3. |
| Ordugâh ateşi (gece 4a/11), mutfak | **DOĞRULANDI (bozulmadı)** | `f11_*/fire_kitchen_m3`, `fire_camp_*`: ÖNCE ve SONRA aynı görünüm, kazan ateşi canlı alev. Gece ordugâhı yerden bozulmadı (`y25`, `fire_camp_far` ÖNCE|SONRA birebir). Gündüz (7a) mutfak ateşi iki sürümde de seçilmiyor (`f7_*`). |
| "Kameraya dönerken zıplayan alev" | **DOĞRULANDI (sekiz yönde)** | pafta 12, `q11_sonra/q_az000…q_az315` (kule çatısı alevi, 4 m, 45°lik adımla çevresinde dönülerek): her yönden aynı boyut, aynı biçim, aynı yer; sıçrama, kayma, çizgiye dönme yok. Tepeden (`q_top*`) alev "form" modelinin ardında kaldı (kamerada duran ara sahne parçası); `q_mid*` (8 m, 8 m yukarı) yuvarlak küçük alev. Sürekli dönüş sırasındaki kareler arası geçişi kare kare izlemedim; yön yönde sabit olması ve shader'ın sürekli yapısı (`smoothstep` karışımı) birlikte güven veriyor.|
| Alev tepeden çizgi/levha | **DOĞRULANDI** | `fire_land_top`, `fire_blach_top`: yuvarlak turuncu leke; ÖNCE kare kutu. |

### 2) Özel yapılar (havadan, yerle aynı yer/ölçü/renk mi)
| Yapı | Hüküm | Kanıt ve not |
|---|---|---|
| Ayasofya (havadan) | **DOĞRULANDI** (kutu/küre yığını gitti) | pafta 01 `aya_m25/m60`: ÖNCE 70×76 m kızıl kutu + dev mavi küre; SONRA haç planlı, kurşun kubbeli, payandalı model. Çarpışma yüzeyi yerin kendisi (konma testi aşağıda). |
| Ayasofya (yer ↔ hava aynı mı) | **KISMEN KANITLI** | Yer kareleri 24 ve 25 (`y24_sonra`, `y25_sonra/once`): iç mekân, Ayasofya cephesi. 26 ve 31o'da bölüm 150/95 kare içinde Ayasofya'ya varmadı (autotest ağır, kestim): **BAKILMADI**. Aynı kodla kurulan iki modelin aynı ölçüde olması kod düzeyinde kesin (`ByzCity.aya_exterior` tek kurucu); aynı koordinattan karşılaştırmalı kare almadım. |
| Ayasofya ölçüsü inandırıcı mı | **KISMEN** | Yerdeki model 35 m genişlik, kubbe tepesi pad'in 24,2 m üstü (haçla 26,5 m). Çevresine göre (Hipodrom, Havariyun) tutarlı ama gerçek Ayasofya'ya göre küçük; oyuncu "büyük kilise" değil "orta boy kilise" görüyor. Tasarım kararı, hata değil. ÖNCE'de dev gibiydi (kubbe 72,7 m). |
| Blakherna | **DOĞRULANDI** (yer↔hava) | pafta 04 üst sıra: Bölüm 30 yer karesi (`g30_sonra/g_blach`) ile aynı koordinattan Bölüm 11 uçuş karesi (`gy11_sonra/y30_blach`): aynı sur, aynı iki kule, aynı pencere dizisi, aynı desen, aynı ölçü. ÖNCE uçuş karesi (`gy11_once/y30_blach`) o noktada düz yeşil levhanın içinde. Pencereler uçuşta düz sarı şerit, yerde parlak; küçük fark. Saray hâlâ dikdörtgen kütle + pencere dokusu (kutu üslubu): **KISMEN küp**, 02. pafta `blach_m15`. |
| Konstantin Sütunu | **KISMEN** | pafta 07 `col_m25`: ÖNCE düz pembe silindir, SONRA kaide + porfir gövde + altın halkalar. İkinci sütun (yerde Ayasofya'nın 60 m batısı) hâlâ ayrı: aşağıda madde 6. |
| Havariyun | **DOĞRULANDI** | pafta 06 `apost_m25`: ÖNCE iki kutu + beş silindir/top; SONRA haç planlı, beş kubbeli, apsisli. Gövde hâlâ düz duvarlı; "özel bina" için kabul. |
| Bozdoğan Kemeri | **DOĞRULANDI** | pafta 06 `aqued_m25`: ÖNCE toprağa gömülü (görünmüyor), SONRA kemerli galeri açıkta. |
| Hipodrom | **KISMEN** (geliştirici de öyle yazmış) | pafta 07 `hippo_m25`: uzun düz levha + yan duvar; kemer yok denecek kadar az. |
| Büyük Saray | **KISMEN** | pafta 07 `palace_m60/m25`: ÖNCE düz gri kutu, SONRA avlulu, yeşil zeminli, revaklı kütle; hâlâ alçak kutu üslubu. |
| 22 kilise / Galata Kulesi | **KISMEN** | pafta 07 `galata_m25/top`: kule aynı; çevre evleri hâlâ seyrek, beyaz kutulara yakın. |
| Hub (Romanos Kapısı, kançılarya, saray avlusu) yer↔hava | **KISMEN: ölçü/yer DOĞRU, renk YANLIŞ** | Yer ve ölçü: pafta 03 `hub_m25/m15` (ÖNCE: boş tarla, SONRA hub). Yer↔hava (pafta 04: Bölüm 10H, 12B, 23'ün gerçek başlangıç noktasından Bölüm 11'e): kule/duvar/kubbeli kilise aynı yerde. **Ama** hub'ın evlerinin çatıları uçuşta kiremitsiz soluk eğik düzlemler/kutular (gece beyaz); yerde terrakota kiremitli, saçaklı, balkonlu Kit evleri. Pafta 05 gündüz: 7b'nin kendi hub'ı (sağ alt) turuncu kiremitli, 7a/11'deki far hub (öteki üç kare) krem kutular. Yani "özel binalar küp küp" şikâyeti hub evlerinde sürüyor. Z1. |

### 3) Uzaklık katmanları ("ölü bant")
**DOĞRULANDI.** Ayasofya, Blakherna ve hub'a 60–140 m arası 5–10 m adımla yaklaştım (Bölüm 11 gece, pafta 11 ve 12; 7a ve 7b'de de çizim/üçgen kayıtları var). Görsel kontrol yalnız Bölüm 11 gecesinde (7a/7b'de aynı bakışların yalnız sayaçları var). Hiçbir adımda yapı kaybolmadı, birden belirmedi, iki katman üst üste binmedi: Ayasofya 90 m'de dokulu kabuktan düz renkli koparılmış kabuğa geçerken siluet ve renk aynı kalıyor. Hub (300 m'ye kadar dokulu) ve Blakherna için de kesiklik yok. Not: hub'da 100 m civarında üçgen sıçrıyor (3,6 M, 90 ve 110 m'de 1,7 M) ama ÖNCE'de de aynı sıçrama var (90 m: 2,5 M, 100 m: 3,4 M, 110 m: 1,7 M), yani katmandan değil, o bakıştaki gölge/ışık geçişinden; bu işin kusuru değil.

### 4) Zemin
- Ayasofya bölgesi tepeye kaldırıldı (`AYA_Y = 17,6`): **DOĞRULANDI** (kod ve konma testi: ÖNCE kubbe tepesi 72,7 m, SONRA 44,15 m; pad 17,6 m + 26,5 m). Yer: 24 (cephe), 25 (iç mekân) frame dizilerinde zemin, kişiler, eşyalar yerinde; havada duran/gömülü şey görmedim (`y24_sonra`, `y25_sonra`, ÖNCE `y25_once` ile iç mekân birebir aynı). 26 ve 31o: **BAKILMADI** (Ayasofya bölümüne varmadan kestim; başsız testler PASS, `WARN_FLY_ITEM`/`WARN_VOID_TELEPORT`/`WALKTHRU` sıfır).
- Hub'ın kenarında dünya birleşimi: pafta 03 `hub_m15/m25/top` ve 04: basamak/yarık görmedim; hub duvarı ile ova arasındaki ayrım düz. "Yolun ortasında ev"/"iç içe ev": göremedim ama `FAR_REGIONS` yalnız hub için var; hub ile çevre arasında üslup farkı (krem kutu evler ↔ Kit evleri) pafta 03 `hub_m15`te ve pafta 05'te açıkça görünüyor; bir yarık ya da basamak değil. **KISMEN** (basamak/yarık yok; üslup birleşimi açık).

### 5) Uçuşta çarpışma
**DOĞRULANDI.** Sondam gerçek `move_and_slide` ile 12 m/s uçuyor (Bölüm 11): 9 yapıya 80 m'den üç yönden, iki yükseklikte (zeminden 6 ve 18 m) yaklaştım, 360 fizik karesi (~72 m yol). 6 m yükseklikte hiçbir yapının merkezine girilemedi (durma mesafesi Ayasofya'da 17,6/21,8/54 m, Blakherna 17–62 m, Hub 15–31 m, Havariyun 23–77 m, Hipodrom 21–51 m, Saray 15–51 m); 18 m'de alçak yapıların üstünden geçip duvar/kubbeye tırmanıyor (Ayasofya 10–17 m önünde duruyor, kubbeye çıkıyor). Ayasofya kubbesine konma: üç noktada (kubbe merkezi, 3,5 m, 8 m) 14 m yukarıdan inerken yüzeyde kalıyor (`aya_dome`: son y = zemin ölçümü ±0,05 m); ÖNCE kubbe 72,7 m'deydi. Görünmez duvar saptamadım. ÖNCE ve SONRA arasında 54 yaklaşımda yalnız şu farklar var, hepsi beklenen: Ayasofya'da ÖNCE 35–38 m öncesinde duruyordu (dev kutu), SONRA 10–22 m (gerçek model). Galata 18 m/0° yaklaşımında ÖNCE 10,4 m SONRA 37 m (önünde ev katı, kule değil).

### 6) Açık kalanlar (geliştirici de "açık" demişti; ben ölçtüm)
| Konu | Hüküm | Kare |
|---|---|---|
| İki ev üslubu yan yana | **AÇIK, DOĞRULANDI** | pafta 05 (kutu hub evleri ↔ Kit evleri). Ayrıca 7a/11'de hub'ın kendisi 7b'nin hub'ından farklı renkte (Z1). |
| İki Konstantin Sütunu | **KANITSIZ (yer karesi yok)** | Yerdeki sütunu (Ayasofya'nın 60 m batısı) yer karesinde göremedim; dünyadaki sütun forumda, pafta 07 `col_m25`. Geliştirici raporundaki tespit kodla uyumlu (`LANDMARKS["column"]` ile `ev:column`). |
| Galata yoğunluğu | **AÇIK, DOĞRULANDI** | pafta 07 `galata_top, galata_m25`: seyrek (11 m aralıklı) ve hâlâ kutuya yakın evler; ÖNCE ile ev sayısı yakın, biçimi biraz iyi. |
| Ovadaki dikdörtgen renk yamaları | **AÇIK, DOĞRULANDI** | pafta 03 `hub_m15` ve pafta 05: hub yakınında ova üzerinde açık yeşil dikdörtgenler (ÖNCE ve SONRA aynı). Pafta 10 `ovaA_60`: gece koyu; çadır ve düzensiz yamalar, ÖNCE'den farkı yok. |
| Kuzey kıyı çadırları | **DOĞRULANDI** | pafta 10 `kuzeyB_30`: ÖNCE beyaz küp/prizma, SONRA sekizgen keçe çadır; uzaktakiler (`kuzeyA_80`) iki sürümde de küçük, seçilmiyor. |

### 7) Performans (önceki|sonraki, çizim ve üçgen)
RINFO'nun kullandığı çizim ve üçgen sayaçlarını her bakışta ÖNCE|SONRA ölçtüm (yukarıdaki yöntem). 64 bakış × 3 uçuş koşusu (11, 7a, 7b): ham tablolar `perf_tablolari.md`. Özet (ortanca/en yüksek):

| Bölüm | Yapı | bakış | Δüçgen ortanca | Δüçgen en yüksek | Δçizim ortanca | Δçizim en yüksek |
|---|---|---|---|---|---|---|
| 11 gece | Ayasofya | 14 | **+26,8%** | **+56,8%** | +17% | +205% |
| 11 gece | Blakherna | 14 | +4,9% | +10,0% | −16% | +17% |
| 11 gece | Hub | 14 | −2,0% | +7,1% | −24% | −13% |
| 11 gece | Büyük Saray | 3 | +9,6% | +15,1% | −1% | +3% |
| 7a gündüz | Ayasofya | 14 | **+33,9%** | **+57,1%** | +31% | +268% |
| 7a gündüz | Hipodrom | 3 | +3,3% | +13,7% | 0% | +43% |
| 7b gündüz | Ayasofya | 14 | **+33,9%** | **+61,5%** | +19% | +291% |
| 7b gündüz | Blakherna | 14 | +3,3% | +5,7% | −17% | 0% |
| (öteki yapılar) | Havariyun, Bozdoğan, Sütun, Galata, Hipodrom | — | −3,6% … +8,8% | | −26% … 0% | |

- 64 bakıştan üçgen artışı %8'i aşan: 11'de 16, 7a'da 20, 7b'de ~16; hepsi Ayasofya (neredeyse her bakış), Büyük Saray, Blakherna yakını, Hipodrom.
- Çizim: hub ve Havariyun, Bozdoğan, Galata'da düşüyor (−%10…−%33); Ayasofya bakışlarında artıyor (ör. 7b `aya_m60`: 233→633). Görev ölçütü "çizim artmaz, üçgen her evrede en çok +%8" Ayasofya yakınında **sağlanmıyor** (Z2). Geliştirici bu bakışları ya ölçmemiş ya da Ayasofya'yı uzaktan ölçmüş (`aya_far`: +%11 üçgen).
- Yerdeki bölümler (önce|sonra, dört bakışın aralığı): 30: çizim −%1…−%25, üçgen ≤ +%3,8; 10h: çizim −%2…−%12, üçgen −%4…+%1,4; 12b: çizim −%4…−%6, üçgen −%2…−%1; 23: çizim −%16…+%0,7, üçgen ≤ +%3,3; 7b: çizim −%9…+%0,2, üçgen −%3…+%1,8; 25 (ordugâh bölümü): çizim −%6…−%30, üçgen ≤ +%2,4; 24 yalnız SONRA. **Bölüm 6, 8, 20 için ÖNCE|SONRA ölçmedim: BAKILMADI.** Yer bölümlerinde artış yok; ölçtüklerim yeterince iyi.
- Yükleme süresi (bölüm açılışından ilk uçuş karesine, tek örnek, koşular başka yüklerle birlikteydi, gürültülü): 11: 11,90 → 12,27 s (+%3); 7a: 10,04 → 10,53 s (+%5); 7b: 11,45 → 13,47 s (+%18, en gürültülü örnek). Başsız (yükleme tek başına): 11: 7,28 → 7,32 s. Yükleme süresi artışı küçük; 7b için tekrar ölçümsüz kanıt zayıf: **KISMEN KANITLI**.
- Kare hızı: llvmpipe'ta 1–3 fps; kare hızı karşılaştırılamadı (geliştirici de yazmış).

### 8) Testler
Yukarıdaki tablo: 51/51 PASS.

## Liste dışı yeni kusurlar

| # | Kusur | ÖNCE'de var mıydı | Kare |
|---|---|---|---|
| N1 | Hub evlerinin çatıları uçuşta kiremitsiz/soluk (gece beyaz eğik düzlem); yerde kiremitli | Hayır: ÖNCE'de hub yoktu (tarla); yeni | 04, 05 |
| N2 | Kıyı suru iki ateş noktası görünmüyor (Haliç merlon, Marmara) | Evet (ÖNCE'de de kutu seçilmiyordu) | 09 |
| N3 | Ayasofya yakınında bütçe: üçgen +%27…%62, çizim +%17…%291 | Hayır: yeni | tablo, 01 |

Havada duran nesne, gövdeye giren nesne, eli boş iş yapan kişi, birden beliren kişi, yanlış yöne bakan kişi, çifte gölge: uçuş karelerinde (192 ölçüm karesi + ateş/ova/yer karelerinden ~100) **görmedim**; ama bu sonda yürüyen kişileri yakından izlemedi, yalnız yapı ve ateşlere baktı.

## BAKILMADI / KANITSIZ özeti
- Bölüm 26 ve 31o'da Ayasofya yeri/zemin karesi (bot Ayasofya bölümüne varmadan kestim).
- Bölüm 6, 8, 20 ÖNCE|SONRA çizim/üçgen.
- Kameraya sürekli dönerken alevin kareler arası geçişi (yalnız 8 sabit yön kontrol edildi).
- İkinci Konstantin Sütunu'nun yer karesi.
- Yer↔hava aynı noktadan karşılaştırma yalnız Blakherna (30) ve hub (10H, 12B, 23) için; Ayasofya (24/25/26/31o) için kod düzeyinde.
- 4a gece ordugâhı: Bölüm 11'in ordugâhı üzerinden bakıldı (`f11_*`, `y25_*`); "4a" adlı ayrı bölüm koşusu yok.

## ZORUNLU düzeltme listesi

- **Z1 (`scripts/world/world1453.gd:bake`, `scripts/level/byz_city.gd:far_hub`)**: hub evleri havadan yerdeki gibi görünsün: kiremit çatıların rengi/dokusu (olası neden, kodda okudum ama kanıtlamadım: `bake(..., max_tris=300)` 300 üçgenden fazla Kit çatısını kendi kutusunu dolduran prizma beşik çatıya çeviriyor ve rengi `albedo_color × _avg(texture)` ile hesaplıyor; sonuç soluk/beyaz çıkıyor). Beklenen: gündüz ve gece 7b'nin hub'ıyla (pafta 05 sağ alt) aynı terrakota çatılı evler. Kabul karesi: pafta 05 düzeni, aynı koordinattan 7a/11.
- **Z2 (`scripts/world/world1453.gd:far_aya`)**: Ayasofya yakınında (≤ 150 m) üçgen ve çizim bütçesi: `aya_m25`, `aya_m60`, `band_aya_*` bakışlarında üçgen ÖNCE'ye göre en çok +%8, çizim artmasın. Seçenekler: dokulu yakın kabuk ayrıntısını azalt (payanda/pencere/kaburga parçaları `min_size`), `generate_lods` eşikleri, gölge atmayı kapat (`cast_shadow` şu an AÇIK), katman sınırını 90 m'den 60 m'ye indir. Kabul: `perf_tablolari.md` ile aynı bakışlarda ≤ +%8 üçgen, çizim ≤ ÖNCE.
- **Z3 (`scripts/world/world1453.gd` / `horn_world.gd` kıyı suru ateşleri)**: Haliç suru merlonundaki (−700,8/23,5/−612,3) ve Marmara suru (−371,9/21/−1416) nöbet ateşleri merlon/sandık bloklarının üstüne çıksın ya da duvar üstünde görünür yere taşınsın (şu an dört yönden 6 m'den görünmüyor). Kabul: `c_coast_az*`, `c_marm_az*` bakışlarında alev seçilsin.
- **Z4 (rapor)**: `hava.md`'deki "üçgen her bakışta < %8" ve "hub yer, ölçü, renk ve doku aynı" cümleleri düzeltilsin; Z1–Z3 yapılınca yeniden ölçülsün.

ORTAK DOSYA ÖNERİSİ: yok (denetçi olarak koda dokunmadım).

## Pafta dizini
01 Ayasofya | 02 Blakherna | 03 hub (uçuş) | 04 yerden ↔ uçuştan aynı nokta (Blakherna 30, hub 10H/12B/23) | 05 hub ev rengi (7a, 7b, 11) | 06 Havariyun + Bozdoğan | 07 Hipodrom, Büyük Saray, Galata, Sütun | 08 ateş: kara suru + Blakherna | 09 ateş: kıyı surları, mutfak | 10 kuzey çadırlar + ova yamaları | 11 ölü bant: Ayasofya 60–140 m (üst), Blakherna ve hub (alt) | 12 alev, sekiz yönden (kameraya dönerken). (1,2,3,6,7,8,9,10: soldaki ÖNCE, sağdaki SONRA; 4: her sıra yer | uçuş SONRA | uçuş ÖNCE; 11 ve 12 yalnız SONRA.)
