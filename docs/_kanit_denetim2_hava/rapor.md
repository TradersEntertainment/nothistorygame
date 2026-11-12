# Bağımsız denetim (2. tur): havadan şehir düzeltme turu (Z1–Z4)

Denetçi: bağımsız oturum. Dal `wip/denetim2-hava`. Denetlenen: `wip/duzeltme-hava` ucu `1c067c73`.
ÖNCE = `main` `e551de84` (yalnız 12 hava dosyası depo dışı kopyada eski hâline getirildi), ARA = `7ad45f7a` (bu işin
çatallandığı kayıt; kopyada yalnız `world1453.gd` ve `horn_world.gd` ARA'ya döndü), SONRA = `1c067c73`.
Oyun koduna dokunulmadı. Hüküm geliştiricinin paftasına göre değil, kendi koşularıma ve karelerime göre verildi.

## GENEL HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL

- **Z1 (hub çatıları): DOĞRULANDI.** Gece beyaz/kahverengi eğik düzlem gitti, gündüz ve gece çatılar kırmızı-terrakota.
- **Z3 (kıyı sur ateşleri): KISMEN.** Haliç suru 4/4 yönde alev (ÖNCE 0/4). Marmara suru: denetçinin işaretlediği nokta 2/4,
  bir başka Marmara ateşi hâlâ 0/4 (kule çatısının içinde). Yani "dört yönden 6 m'den seçilir" Marmara'da sağlanmıyor.
- **Z2 (Ayasofya bütçesi): YANLIŞ (kısmen iyileşmiş).** ARA'ya göre iyi yönde (üçgen −%12…+%0,6), ama ÖNCE'ye göre benim
  75 ölçümümden 14'ünde üçgen > +%8 (en kötü +%19,5), 10'unda çizim artıyor (en kötü +%40). Geliştirici bunu kısmen kabul etmişti.
- **Z4 (rapor): KISMEN.** Dürüst (Z2 çizim ve Z3 Marmara eksiği yazılmış, eski cümleler geçersiz ilan edilmiş), ama ölçüm
  yalnız 7a ve gece hub'ı; 7b ve Bölüm 11 Ayasofya bakışları ve farklı yönler yok, o yüzden "≤ +%7,7" sonucu tutmuyor.
- Test ve gerileme: 47/47 başsız PASS, `flight_check`/`world_check`/`parse_check` PASS. `city_check` FAIL (31o CityLife
  kare süresi) ama ÖNCE ve ARA kopyalarında da aynı FAIL: bu işten bağımsız. Blakherna, Havariyun, Bozdoğan, sütun, Hipodrom, kara
  suru ve Blakherna ateşleri ARA | SONRA görsel olarak aynı.

### ZORUNLU düzeltme listesi
1. **`scripts/world/world1453.gd:far_aya`** (`AYA_NEAR`, yakın kabuk): ≤ 150 m'de bütün Aya bakışlarında üçgen ÖNCE'ye göre ≤ +%8
   ve çizim ≤ ÖNCE olsun. Şu an ihlaller: `aya_m60_az0` (7a +%19,5 üçgen / +%40,4 çizim; Bölüm 11 +%14,1 / +%17,2),
   `aya_low_30_az0` (7b +%15,1 / +%20,3; 11 +%12,5), `band_aya_60` (7b +%13,6; 7a +%10,0 / +%12,6), `band_aya_70/75` (7b +%10,7 / +%13,1)
   ve ötekiler `perf_tablolari.md`'de (❌ işaretli). Yakın kabuk 60 m içinde tek başına ~36–53 bin üçgen ekliyor (aşağıda, katman
   tablosu). Seçenekler: `AYA_NEAR` 60 → 40–45 m; yakın kabuğun dış çizgisini kapat; yakın kabuk parça eşiği (`min_size` 0,4 hiçbir
   şey silmiyor: yakın kabuk ARA'da da SONRA'da da 17 696 üçgen). Kabul: `perf_tablolari.md` aynı bakışlarda ❌ yok.
2. **`scripts/world/world1453.gd:far_aya`, düz kopya rengi:** gündüz 62–64 m'de dokulu kırmızı tuğla birden düz somon/şeftali
   renge dönüyor (yerdeki modelde 100 m'de de kırmızı tuğla): düz kopyanın köşe rengi doku ortalamasından koyu-kırmızıya doğru
   kayarak (tuğla dokusunun ortalaması, doğrusal/sRGB dönüşümü `bake` rengiyle aynı yöntemle) ayarlansın. Kabul: pafta 05'te 60 | 65 | 70 m
   karelerinde Ayasofya'nın tonu yerdeki modelden gözle ayırt edilmesin.
3. **`scripts/world/horn_world.gd:_wall_run`** (nöbet ateşi yeri): Marmara suru ateşleri kule yanına/çatısına denk gelince
   görünmüyor: `(−371,5 / 22,1 / −1416,5)` ateşi bir kule gövdesinin kenarına yapışık (6 m'den az0 ve az90 görünür, az180 ve az270'te
   kule gövdesi önünde, bkz. pafta 08–09) ve `(−515,9 / 24,6 / −1605,6)` ateşi bir kulenin kırmızı çatı hacminin içinde (hiçbir
   yönden, 8 m yukarıdan ve 20 m'den de görünmüyor). Kule ayak izi içinde ya da kule çatısı yüksekliğinde kalan ateş noktaları
   atlansın ya da surun serbest bir yerine/çatının üstüne taşınsın. Kabul: `c_marm*` bakışlarında her ateş, kule içinde kalmayan
   dört yönden 6 m'den alev olarak seçilsin.
4. **Rapor (Z4):** Z2 ölçümü Bölüm 11 gece, 7a ve 7b'de, ≥ 3 yönde (`az0/120/240`), `aya_m25`, `aya_m60`, `aya_low_30` ve
   `band_aya_60…140` için ÖNCE | SONRA tablosuyla yeniden verilsin; "≤ +%7,7" cümlesi bu tabloya göre düzeltilsin.

Öneri (zorunlu değil): gündüz kıyı surundaki yeni demir mangallar (0,9×0,55×0,9 m siyah kutu) alevsiz siyah küp gibi duruyor
(pafta 12); gündüz küçük bir kömür/kül dokusu ya da daha küçük boyut düşünülebilir.

## Yöntem ve koşullar
- Makine: 4 çekirdek, llvmpipe; ekranlı koşular `xvfb-run` 960×540, başsız koşular `--max-fps 20`. Bir an en çok 1 ekranlı + 2 başsız.
- Kare aracı: kendi sondam (`tests/_tmp/probe*`, **depoya girmiyor; iş bitince silindi**, `grep` ile doğrulandı). Gerçek bölümü
  açıyor (`--chapter=11`; `--chapter=7`; `--chapter=7 --outcome=6:6b.1` = 7b), HUD'u gizliyor, oyuncuyu ve etkin kamerayı verilen **dünya**
  noktasına koyuyor (`RenderingServer.frame_pre_draw` ile), her bakışta 12 kare ısınıp 5 kare örnekliyor ve `RenderingServer`
  çizim/üçgen sayaçlarını (RINFO'nun kullandığı) yazıyor. Tablolarda her bakış için **5 örneğin en küçüğü** kullanıldı: bazı
  ilk karelerde 1,2–2,8 M üçgenlik tek karelik sıçramalar (akış/gölge ısınması) görüldü; ortanca de, en küçük de aynı sonucu verir
  ama en küçük sıçramayı eler.
- ÖNCE | ARA | SONRA aynı JSON bakışlarla ve aynı kamera konumuyla koşuldu (kare adlarında dizin adı: `o_*` ÖNCE, `a_*` ARA,
  `s_*` SONRA, `g_*` Ayasofya'nın yerdeki modeli = `ByzCity` `part="aya"`, bağımsız sahne; `f_o11`, `p_o11` ÖNCE).
- Bakış kataloğu (dünya koordinatı): Ayasofya merkezi `(−560, 17,6, −1480)`; `aya_m25`/`aya_m60` merkezden 25/60 m, yön 0°/120°/240°
  (yükseklik pad+10/+18); `aya_low_30` 30 m, pad+2, yön 0°/180°; `band_aya_60…140` 5 m adımla, yön 0°, pad+12; hub merkezi `(19, −40)`
  (`hub_m25` 25 m, 3 yön; `hub_st` 90 m yukarıdan; `hub_g` yerden 2 m); yapılar `apost`, `aqued`, `col`, `hippo`, `blach` 25 m. Ateşler: sondanın
  `GlowFlames` alev örneklerinden istenen noktaya en yakını (ÖNCE'de bu düğüm yok: ÖNCE kamerası aynı dünya noktasında, kutu ateşin eski yerinde).
- Haliç ateşleri: 6 nokta (`−700,8/23,5/−612,3` dahil), Marmara: 6 nokta (`−371,9/21/−1416` dahil), her biri 4 yönden (0/90/180/270°) 6 m, 1 m yukarı.

## Madde madde

### Z1: hub evleri havadan terrakota kiremit çatılı mı
| Alt madde | Hüküm | Kanıt |
|---|---|---|
| Bölüm 11 gece, uçuştan hub | **DOĞRULANDI** | pafta 01 (`o_11` ÖNCE: boş tarla; `a_11` ARA: bej/kahverengi soluk çatılar ve büyük beyaz eğik düzlem; `s_11` SONRA: kırmızı çatılar, beyaz düzlem yok). `hub_m25_az120`, `hub_st`. |
| 7a gündüz, uçuştan hub | **DOĞRULANDI** | pafta 02 orta sütun `s_7a`: turuncu-terrakota kiremit çatılar, krem/pembe duvarlar. |
| Yerdeki hub (7b) ile yan yana | **DOĞRULANDI (renk), KISMEN (doku)** | pafta 02 sağ sütun `s_7b` (aynı koordinattan, yerdeki Kit evleri). Çatı piksel ortalaması (turuncu-kırmızı maskeli): `hub_m25_az0` 7a (234,144,92) | 7b (236,151,109); `az120` (247,145,88) | (245,165,118); `az240` (222,123,74) | (223,142,99): aynı terrakota ailesi, uzak sürüm biraz daha doygun (G −7…−20, B −17…−25). Yerdeki çatıda kiremit dokusu ve kabartma var, uzaktakinde düz renk (geliştirici de yazmıştı). Uzak hub'da kişi ve sokak detayı yok (beklenen). |
| Neden: `bake` prizma değişimi | **DOĞRULANDI** (kod okuma ve ARA|SONRA kare farkı) | `_roofish` artık yalnız adı "roof" geçen parçalara uyguluyor; ev ağı beyaz levhaya dönmüyor. |
| Üçgen maliyeti | bilgi | ÖNCE'ye göre hub bakışlarında üçgen −%61…+%7,3, çizim −%7…−%51 (`perf`: Bölüm 11 `hub_st` +%7,3, `hub_g_az180` +%5,9); 7a −%27…−%57; 7b −%43…+%5,4. ARA'ya göre Bölüm 11'de +%7…+%27,5 (ev gövdeleri artık prizmaya çevrilmiyor): Z1'in bedeli, ÖNCE tabanına göre sınır içinde. |

### Z2: Ayasofya ≤ 150 m: bütçe, görünüş, ölü bant
**Bütçe: YANLIŞ.** `perf_tablolari.md`, 3 dünya × 25 bakış (75 ölçüm, 5 örneğin en küçüğü, ÖNCE | SONRA):
- Üçgen > +%8: **14/75**. Çizim artışı (> +%0,5): **10/75**.
- Dünya başına üçgen ihlali: Bölüm 11 gece **5** (`aya_m60_az0` +%14,1, `aya_low_30_az0` +%12,5, `band_aya_95` +%9,9, `band_aya_80` +%8,8, `band_aya_100` +%8,1);
  7a **3** (`aya_m60_az0` +%19,5, `band_aya_60` +%10,0, `band_aya_90` +%8,2); 7b **6** (`aya_low_30_az0` +%15,1 / +%20,3, `band_aya_60` +%13,6, `band_aya_75` +%13,1, `band_aya_70` +%10,7, `aya_m25_az120` +%8,9, `aya_m60_az0` +%8,1).
- Çizim artışı (10 ölçüm): Bölüm 11 `aya_m60_az0` +%17,2, `aya_m60_az120` +%15,1; 7a `aya_m60_az0` +%40,4, `band_aya_60` +%12,6, `aya_m25_az240` +%3,0, `aya_m60_az120` +%1,5; 7b `aya_low_30_az0` +%20,3, `aya_m60_az120` +%11,3, `aya_low_30_az180` +%4,8, `aya_m25_az120` +%2,0.
- İyi taraf: `aya_m25_az0` +%4,8…+%7,6; 105–140 m arası üç dünyada +%4,9…+%7,0 (sabit, sınır içinde); çizim 110 m'den sonra −%25…−%28.
- ARA'ya göre (Bölüm 11, eski protokol): Ayasofya bakışlarında üçgen −%12,3…+%0,6, çizim −%25…+%58 (tek istisna `aya_m60_az120`, çizim +%57,6): bu turun düzeltmesi
  ARA'dan iyi, ÖNCE tabanına yetmiyor.
- Geliştirici raporuyla fark: o `aya_m60` +%1,5, `band_aya_60` +%7,7 yazmış; ben aynı bakışta `az0`'da +%8,1…+%19,5, `az120`'de +%2,9…+%4,8 ölçtüm: bakış yönü
  (az0, merkezden doğuya) ve dünya (7b, 11) farklı; tek yöne bakılınca bütçe tutmuş görünüyor.
- Neden (katman tablosu, 7a, kamera pad+18 m, doğu yönü; `FarAyasofya` yakın kabuk ve `FarAyasofyaLo` düz kopya ayrı ayrı gizlenerek ölçüldü):

| mesafe | hepsi (çizim/üçgen) | yalnız yakın kabuk katkısı | düz kopya katkısı |
|---|---|---|---|
| 54 m | 423 / 762 093 | 3 / 36 480 | 2 / 2 508 |
| 58 m | 482 / 801 381 | 4 / 38 056 | 1 / −6 428 (gürültü) |
| 60 m | 485 / 812 549 | 18 / 53 138 | 1 / −6 940 (gürültü) |
| 62 m | 472 / 776 655 | −2 / 17 536 | 4 / 8 628 |
| 64–72 m | 420–431 / 752 389–763 739 | 1 / 1 196 (gölge vekili) | 1 / 8 520 |

  Yani yakın kabuk ≤ ~62 m'de 36–53 bin üçgen ekliyor (dış çizgiyle), ÖNCE'deki dev kutu ise neredeyse bedavaydı: +%5…+%20 farkın kaynağı bu.
  ARA'daki gölge yükü (gölge kademelerinde yeniden çizim) vekille düşmüş, doğru yönde bir düzeltme.

**Görünüş (yerdeki modelle aynı mı): KISMEN.**
- Şekil ve ayrıntı: ARA ile SONRA aynı (pafta 03: `aya_m25_az120`, `aya_low_30_az0/180`, `aya_m60_az0` gece; pencere, kaburga, payanda, kubbe aynı).
  **Ayrıntı silinerek bütçe tutturulmamış**: yakın kabuk üçgeni ARA'da da SONRA'da da **17 696** (`min_size` 0,4 hiçbir parça silmiyor); düz kopya 12 904 üçgen.
  Kazanç: yakın kabuğun gölge atmaması, gölgeyi 1 196 üçgenlik vekilin atması ve dokulu kabuğun menzili 90 → 60 m.
- Yerdeki modelle (pafta 04, `g_aya` ByzCity `part="aya"`, gündüz) 25–30 m'de yüzey ve tuğla düzeni aynı. `aya_low_30_az180`'de yerdeki modelde narteks kapıları içi sarı ışıklı ve
  içinde iç mekân görünüyor, uzak modelde kapı açıklıkları boş karanlık (iç mekân yok: beklenen, tek kabuk). `aya_m60_*`'da yerdeki sahne çevre evleriyle başka dolgu içeriyor (kapsam dışı).
- Gölge: gece yakın kareler (pafta 03) ARA ile SONRA'da duvar gölgesi aynı. Gündüz üstten ve eğik kareler (pafta 06) pozlama/sis yüzünden gölgeyi seçmeye yetmiyor, ayrıca uçuş formu kareyi kapatıyor: **gölge şekli için gündüz kanıtı yok (KANITSIZ)**, gece kanıtı var.
- **Gündüz renk/doku sıçraması (yeni kusur N3):** pafta 05 (`g_aya` | `s_7a`, 60/65/70/100 m): 60 m'de uzak Ayasofya dokulu kırmızı tuğla (yerdeki gibi), 65 m ve ötesinde düz somon/şeftali. Gece belli belirsiz, gündüz belirgin. ÖNCE'de bu geçiş yoktu (dev kutu); ARA'da 90 m'deydi, şimdi daha yakın olduğu için daha görünür. Zorunlu 2.

**Ölü bant / çifte çizim (60–140 m, 5 m adım): DOĞRULANDI (yok).** 17 adımda (`band_aya_*`) yapı hiç kaybolmadı, çizim ve üçgen eğrisi düzgün (ör. 7a: 907k → 899k → 875k … 856k); 54–72 m arası 1 m adımlı tarama (`scan_*`) ve katman gizleme ölçümü: devir 62–64 m'de, iki katmanın birlikte pahalı çizildiği bir sıçrama yok (60 m'de yakın kabuğun 53k'lık yüksek katkısı geçiş yakınında tek bir ölçüm, çizim artmıyor, kaybolma yok).

### Z3: Haliç ve Marmara kıyı surları nöbet ateşleri dört yönden 6 m'den alev mi
Pafta 07 (Haliç), 08 (Marmara), 09 (Marmara tanı), 12 (gündüz). Bölüm 11 gece:

| Nokta | ÖNCE | SONRA | Hüküm |
|---|---|---|---|
| Haliç suru `−700,8/23,5/−612,3` (`c_coast0`) | 0/4 (merlon blokları arasında kutu bile yok) | **4/4 alev**, demir mangal üstünde, siperlerin üstüne taşıyor | DOĞRULANDI |
| Haliç suru `−700,2/23,7/−1324` (`c_coast3`) | 0/4 | **4/4** | DOĞRULANDI |
| Haliç kule çatısı ateşleri (`c_coast1/2/4/5`: z −774, −994, −1478, −1566) | 4/4 **sarı dikdörtgen kutu** (alev değil) | 4/4 küçük ama seçilen **alev** (kule çatısı kenarı) | DOĞRULANDI (bu iyileşme ilk turdan, ARA'da da var) |
| Marmara suru `−371,9/21/−1416` (`c_marm3`) | 0/4 | **2/4**: az0 ve az90 alev; az180 ve az270'te kamera kule gövdesinin içinde (ateş kulenin yanına yapışık) | **KISMEN** |
| Marmara suru `−420/19/−1480` (`c_marm2`, sur üstü mangal) | 0/4 | **4/4 alev** (pafta 08) | DOĞRULANDI |
| Marmara kule çatısı ateşleri `−444/27,5/−1512` (`c_marm1`), `−268/25/−1282` (`c_marm4`), `−198/24/−1189` (`c_marm5`) | 4/4 sarı kutu | 4/4 küçük alev | DOĞRULANDI (ilk tur) |
| Marmara suru `−516/24,6/−1606` (`c_marm0`) | 0/4 (kule çatısı/gövdesi) | **0/4**: 8 m yukarıdan ve 20 m'den (pafta 09) hiçbir yönden alev yok: ateş kulenin kırmızı çatı hacminin içine gömülü | **YANLIŞ** |

- Tanı (pafta 09): `marm3` ateşi surun ortasında değil, kule gövdesinin yanında; kule arkasından (az180/az270) görünmez. 8 m yukarıdan az0 ve az90'da görünür, az180'de kule çatısı önde. Bu fiziksel bir kapanma, ama "dört yönden seçilsin" şartı bu nokta için sağlanmıyor.
  Geliştirici bu iki yönü "büyük beyaz yapı" diye yazıp araştırmamıştı: o yapı kule gövdesi.
- Gündüz (pafta 12, 7b): ÖNCE'de ne ateş ne mangal var; SONRA'da yeni siyah mangal kutusu duruyor, alev yok (alev geceye ait). Alevsiz siyah küp: küçük kusur N1 (öneri).
- Kıyı surundaki yeni mangal: sur üstünde, siperlerin (hh+1,5) arasında 0,9×0,55×0,9 m kutu; çarpışması yok (`Dressing.box`), uçuş kutusu eklenmedi: `flight_check` PASS.

### Gerileme: öteki ateşler ve yapılar
| Madde | Hüküm | Kare |
|---|---|---|
| Kara suru nöbet ateşi (`−346/13/−1`, `−154/13/−1`; 15 m ve 3 m) | **DOĞRULANDI** (ARA | SONRA aynı alev) | pafta 11 (`fire_land_*`) |
| Blakherna ateşi (`−568/9/15`) ve Blakherna kule çatısı ateşi (`−700/14/−26`) | **DOĞRULANDI** | pafta 11 (`fire_blach_*`, `fire_blachT_*`) |
| Havariyun, Bozdoğan, sütun, Hipodrom, Blakherna sur/pencere (25 m, gece) | **DOĞRULANDI** (ARA \| SONRA görsel olarak aynı; sayaç, eski 3 örnekli protokolle: üçgen −%9,7…+%2,3; çizim −%17…+%0 hariç `blach_m25_az45` çizim +%13,3, yeni protokolde tekrarlanmadı: olası gürültü) | pafta 10 |
| "Tepeden" kareler (`*_top`) | **BAKILMADI** | uçuş formu (kâğıt) kareyi kapattı |

### Z4: rapor
- Ölçüm tablosunda ÖNCE | SONRA üçer örnek: var, ama yalnız 7a (Ayasofya, hub) ve gece hub'ı; 7b, Bölüm 11 Ayasofya ve çok yönlü bakış yok: **KISMEN**.
- Yanlış kalan cümleler: "Z2 üçgen ≤ +%7,7": yalnız dar bir bakış kümesi için doğru, benim 75 ölçümümde 14 ihlal (Zorunlu 4).
- Dürüst bildirilenler benim ölçümlerimle uyuşuyor: Z1 DÜZELDİ (kiremit dokusu yok), Z2 çizim sağlanmadı, Z3 Marmara iki yön görünmüyor, `city_check` ÖNCE'de de FAIL.

## Yeni kusurlar (liste dışı) ve ÖNCE'de var mıydı
| # | Kusur | ÖNCE'de | Kare |
|---|---|---|---|
| N1 | Gündüz kıyı surunda alevsiz siyah mangal küpü | Yok (ateş de yoktu) | 12 |
| N2 | Marmara ateşleri: biri kule içinde (0/4), biri kule yanında (2/4) | Evet (ÖNCE'de de görünmüyordu) | 08, 09 |
| N3 | Ayasofya gündüz 62–64 m'de tuğla dokusu → düz somon renk sıçraması | Hayır (yeni; ARA'da 90 m'deydi) | 05 |
| N4 | Ayasofya ≤ 62 m'de yakın kabuk 36–53 bin üçgen: bütçe taşması | Hayır (yeni) | tablo |

Havada duran / gövdeye giren nesne, eli boş iş yapan kişi, birden beliren kişi, yanlış yöne bakan kişi, çifte gölge: sondanın ~700 karesinde
(yapı ve ateş odaklı; yürüyen kişilere uzun bakılmadı) **görmedim**. Küp gibi ateş: gündüz mangal (N1) dışında yok. Uçuş formu (kâğıt) bazı üst kareleri kapatıyor: oyun yapısı, kusur değil.

## Kurallara uygunluk
- `git diff 7ad45f7a HEAD --stat -- scripts` (bu turun farkı): yalnız `scripts/world/world1453.gd` (+92/−6) ve `scripts/world/horn_world.gd` (+4/−1). `scripts/level/byz_city.gd` değişmedi.
- `git diff e551de84 HEAD` içinde bu iki dosyada replik, sıra, süre, sayaç, kazanma/kaybetme, denge, kalabalık sayısı, bot yolu değişikliği **yok** (eşleşen 6 satır `get_surface_count`/`count` yerel değişkeni). Yeni `class_name` dosyası yok.
- Kanca / susturma yok: `no_audit`, `_ok`, `OS.get_environment`, `print(`, `tests/_tmp`, filtre bu turun farkında yok. `set_meta("no_walk", true)` (`world1453.gd:406` ve `:419`) yeni vekil ve katmanlarda: WorldWalk'un süs ağlarına çarpışma üretmemesi için eski gelenek (gulls/slipway/vfx), denetim susturması değil.
- `OS.get_environment("WORLD_PROF"/"REAR_ACTIVE")` ÖNCE'de de var (bu turun eki değil).
- `git status` (gerçek depo): oyun kodunda değişiklik yok; yalnız `docs/_kanit_denetim2_hava/` yeni. `.import` ve `.uid` dosyaları ile yeniden içe aktarımın değiştirdiği `i18n/*.translation` dosyaları kaydedilmedi (translation dosyaları `git checkout` ile geri alındı). Sonda `tests/_tmp` silindi.

## Testler (başsız, `--max-fps 20`; ham satırlar `testler.txt`)
| Test | Sonuç |
|---|---|
| `parse_check` | `PARSECHECK PASS scripts=248` |
| `flight_check` | `FLIGHTCHECK PASS` |
| `world_check` | `WORLDCHECK PASS regions=13 landmarks=35` |
| 3 (—, tea, confiscate, seal, lie, radio) | 6/6 PASS |
| 4 (—, item, caught, market, chain, nofez, fall, fez, wet) | 9/9 PASS |
| 6 (—, byz) | 2/2 PASS |
| 7 (—, tea, lost, form, wall, wallkeep, byz, byzniko, byzcell, fez) | 10/10 PASS |
| 8, 8y, 9, 10 | 4/4 PASS |
| 11 (—, arrest, escape, persuade, help, helpwall, lost, fired, hikmet, niko) | 10/10 PASS |
| 24, 25, 26, 27, 30, 31o | 6/6 PASS |
| `city_check` | **FAIL** 31o CityLife kare süresi SONRA 4214 µs (ARA 3647, ÖNCE 3738) > 1500 µs; üçünde de aynı FAIL |

Toplam **47/47 `AUTOTEST PASS`**; her koşuda `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`,
`HELDAUDIT`, `LOOKAUDIT backturn`, `JOURNEY_MISS`, `JOURNEY_OVERLAP` sayısı **0**. `city_check` bu işten bağımsız (CityLife, hava dosyalarına bağlı değil; üç sürümde de eşik aşılıyor, SONRA'daki +%13 fark gürültü düzeyinde, hava kodu CityLife'a dokunmuyor).

## Performans tablosu (ÖNCE | SONRA, 5 örneğin en küçüğü)
Ayrıntı: `perf_tablolari.md` (75 Ayasofya ölçümü + 54–72 m taraması). Özet:

| Bakış kümesi | Bölüm 11 gece Δüçgen | 7a gündüz Δüçgen | 7b gündüz Δüçgen | Δçizim (üç dünya) |
|---|---|---|---|---|
| `aya_m25` az0/120/240 | +6,7 / −0,9 / +1,3 | +4,8 / −5,1 / +1,7 | +7,6 / **+8,9** / +0,6 | −32…+3 |
| `aya_m60` az0/120/240 | **+14,1** / +4,3 / +1,6 | **+19,5** / +2,9 / +1,0 | **+8,1** / +4,8 / +1,3 | az0: **+17** / **+40** / −17; az120: **+15** / +1,5 / **+11** |
| `aya_low_30` az0/180 | **+12,5** / +4,4 | −1,1 / +4,2 | **+15,1** / +6,9 | −30…**+20** (7b az0) |
| `band_aya_60…140` (17) | +0,8…+9,9; 105–140 m: +5,3…+5,7 | +3,4…+10,0 | +4,8…+13,6 | çoğu −5…−35; 60 m 7a +12,6 |
| hub (6 bakış) | −61…+7,3 | −57…−27 | −43…+5,4 | −51…+3,6 |

Yükleme süresi: ilk kareye kadar (tek örnek, ekranlı, başka koşularla birlikte, gürültülü): 11: ÖNCE 43,5 s / SONRA 62,6 s; 7a SONRA 38,4 s;
7b SONRA 54,6 s (ÖNCE 7a/7b ölçülmedi): **KANITSIZ**. Kare hızı llvmpipe'ta karşılaştırılamaz.

## BAKILMADI / KANITSIZ
- Ayasofya gölgesinin gündüz şekli (KANITSIZ); `*_top` kareleri (uçuş formu kapattı); yükleme süresi karşılaştırması; kare hızı.
- Ayasofya yer modeli karşılaştırması bağımsız `ByzCity part="aya"` sahnesinden (gündüz); bölüm 24/25/26/31o gerçek oynanışından aynı koordinattan kare alınmadı.
- Bölüm 6, 8, 20 yer ÖNCE | SONRA çizim/üçgen sayısı (bu turun hedefi dışında).
- Ayrı bölüm 4a koşusu yok: gece ordugâhı Bölüm 11 üzerinden.

## Pafta dizini (en çok 12; kare adı `dizin/bakış`: `o_` ÖNCE, `a_` ARA, `s_` SONRA, `g_` yerdeki Ayasofya modeli, `f_`/`p_` ÖNCE)
01 hub gece ÖNCE | ARA | SONRA · 02 hub gündüz ÖNCE 7a | SONRA 7a | yerdeki hub 7b · 03 Ayasofya gece ÖNCE | ARA | SONRA · 04 Ayasofya yer modeli | uzak, gündüz ·
05 katman geçişi 60/65/70/100 m, yer modeli | uzak, gündüz · 06 gölge: yer | ARA | SONRA, gündüz · 07 Haliç ateşleri ÖNCE | SONRA (4 yön) ·
08 Marmara ateşleri ÖNCE | SONRA · 09 Marmara tanı (8 m yukarı, 20 m) · 10 gerileme yapılar ARA | SONRA · 11 gerileme ateş kara suru/Blakherna ARA | SONRA · 12 Haliç gündüz 7b ÖNCE | SONRA.
