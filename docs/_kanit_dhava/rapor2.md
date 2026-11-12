# Havadan şehir düzeltme turu, 2. (son) tur — geliştirici raporu

Dal `wip/duzeltme-hava`. Girdi: `wip/denetim2-hava` denetim raporu (KÜÇÜK DÜZELTMELERLE KABUL, ZORUNLU 1–4).
Dokunulan dosyalar yalnız `scripts/world/world1453.gd` ve `scripts/world/horn_world.gd` (`byz_city.gd` bu turda değişmedi).
Ham veri: `olcum_tablolari2.md` (3 dünya, ÖNCE | ARA | SONRA), `aya_payi_eslesik.txt`, `testler2.txt`, `kontroller2.txt`.

## ÖZET (dürüst)

| Madde | Durum |
|---|---|
| [Z3] Marmara ateşleri (2/4 ve 0/4 olanlar) | **DÜZELDİ** (kare kanıtlı): iki ateş de dört yönden 6 m'den alev; kule çatısı ateşleri de dört yönde alev |
| [Z2] Ayasofya ≤ 150 m, üçgen ≤ +%8 ve çizim ≤ ÖNCE, bütün bakışlarda | **YAPILAMADI (harfiyen)**; Ayasofya'nın kendi payı küçüldü ve ölçüldü, kalan fazlalık Ayasofya dışı (aşağıda) |
| [Z2] düz kopya rengi (gündüz tuğla → somon sıçraması) | **DÜZELDİ** (kare kanıtlı; küçük ton farkı kaldı) |
| [Z4] ÖNCE \| ARA \| SONRA ölçümleri, 7a, 7b, Bölüm 11, dört yön | **YAPILDI** (`olcum_tablolari2.md`); eski "≤ +%7,7" cümlesi geçersiz |
| Testler | 47/47 `AUTOTEST PASS`, yasak satır 0; `parse_check`, `flight_check`, `world_check` PASS; `city_check` FAIL (önceden de var, aşağıda) |

## Yöntem ve koşullar
- Makine 4 çekirdek, llvmpipe; ekranlı koşular `xvfb-run` 960×540, başsız `--max-fps 20`. Kendi sondam (`tests/_tmp/probe.gd`, geçici otoload; **depoya girmedi**,
  `project.godot`'a eklenen satır da kaydedilmedi). Gerçek bölüm açılıyor (`--chapter=11`, `--chapter=7`, 7b = `--chapter=7 --outcome=6:6b.1`), HUD gizli,
  oyuncu ve etkin kamera HornWorld yerel noktasına konuyor (`frame_pre_draw`), her bakışta 12 kare ısınma + 5 örnekten **en küçüğü** (RenderingServer toplam ilkel/çizim).
- ÖNCE = `1c067c73` üstünde 10 hava dosyası (`byz_city`, `blachernae`, `galata_view`, `horn`, `city_plan`, `horn_world`, `landmarks1453`, `world1453`, `world_flight`, `flame`)
  `e551de84`'e döndürülmüş kopya (`flame.gd`'ye bölüm 7'nin çağırdığı `Flame.from_glow_boxes` için ARA sürümü bırakıldı: ÖNCE'de bu işlev yok, bölüm 7 açılmıyordu).
  ARA = `1c067c73` (bu turun başındaki uç). SONRA = bu dalın ucu.
- Bakış: Ayasofya merkezi `(−560; 17,6; −1480)`, kamera merkezden `(cos az, sin az)` yönünde; `aya_m25` (pad+10), `aya_m60` (pad+18), `aya_low_30` (pad+2), `band_aya_60…140` 5 m adım (pad+12); **dört yön az0/90/180/270** (az0 = doğu). Bölüm 11 gece için 80 bakış, 7a ve 7b için 32 bakış (m25, m60, low_30 + band 60/70/75/100/140): bölüm 7 koşuları llvmpipe'ta 30+ dakika sürdüğü için azaltıldı.

## [Z2] Ayasofya yakın kabuk (`world1453.gd`)

### Ne yapıldı (görünüş yerdeki modelle aynı; ayrıntı silinmedi)
1. `far_aya` (`world1453.gd:386` ve sonrası), `_merge_flat_grid` (`:486`): kurşun çatı ızgarası (0,5 m'lik kare hücreler, 4 312 üçgen) aynı alanı kaplayan büyük dikdörtgenlere birleştirildi (şekil ve kubbe delikleri aynı). Ölçüm: yakın kabuk ayrıntı seviyesiyle zaten sadeleşiyordu, kare başı sayaçta bu tek başına fark yaratmadı (**sayaç etkisi KANITSIZ/ihmal edilebilir**); ağ üçgen sayısı yine de düştü.
2. `_outer_half` (`:440`): duvara yaslı yassı küreler (pencere/kapı kemerleri, perçinler; 71 adet, 80 üçgen) için **bina merkezine bakan, duvarın içine gömülü yarı** atıldı (`aya_c`, `:408`). Dışarıdan görünüş aynı: pafta `p2_01` ARA | SONRA aynı.
3. `AYA_NEAR` 60 → **50 m** (`:380`): yakın/uzak geçişi daha yakın; geçiş bandı 5 m adımlı taramada (60–140 m) ölü bant yok (bkz. tablolar: yapı hiçbir adımda kaybolmadı, çifte çizim sıçraması yok). 54–72 m katman gizleme ölçümü bu turda yinelenmedi: **geçiş 50 m'de yeniden taranmadı (KANITSIZ)**, 40–54 m renk karelerinde (aşağıda) her iki katman da göründü.

### Ölçüm: Ayasofya'nın kendi payı (aynı bakışta göster/gizle, `aya_payi_eslesik.txt`)
`FarAyasofya` (üç katman) aynı bakışta gizlenip gösterilerek ölçüldü (gürültü ayıklanır):

| mesafe | ARA payı (üçgen) | SONRA payı (üçgen) | çizim payı SONRA |
|---|---|---|---|
| ≤ 35 m (`aya_m25`, `aya_low_30`) | ≈ +31…+40 bin | **≈ +23…+26 bin** (Bölüm 11: 23,4…25,7 bin; 7a: 16,2…26,8 bin) | +2…+16 |
| 60–140 m (`band_aya_*` az0) | ≈ +8,5…+9,9 bin | **≈ +7,7…+10 bin** | +1…+2 |

Yani Ayasofya'nın katkısı yakında ≈ %3–4, uzakta ≈ %1 üçgen, çizimde birkaç çağrı: **tek başına ÖNCE'ye göre +%8'in içinde**. (ÖNCE'nin kendi Ayasofya modeli de sayılıyor; onun payı ayrı ölçülmedi: KANITSIZ.)

### Ölçüm: ham ÖNCE | SONRA (bütün sapmalar dahil), `olcum_tablolari2.md`
Ham karşılaştırmada ÖNCE'ye göre +%8 üçgen ya da çizim artışı olan bakış sayısı (SONRA; ARA parantezde):

| dünya | bakış | üçgen > +%8 | çizim artışı |
|---|---|---|---|
| Bölüm 11 gece, hepsi | 80 | 21 (22) | 24 (27) |
| az0 | 20 | 3 (4) | 1 (1) |
| az270 | 20 | 0 (0) | 1 (0) |
| az90 | 20 | 11 (9) | 13 (13) |
| az180 | 20 | 7 (9) | 9 (13) |
| 7a gündüz, hepsi | 32 | 8 (10) | 17 (18) |
| 7b gündüz, hepsi | 32 | 7 (8) | 11 (11) |

Denetçinin işaretlediği bakışlar (az0, SONRA | ARA; ÖNCE'ye göre Δüçgen / Δçizim):
`aya_m60_az0`: 11 +%4,0 / −%13 | 7a +%1,6 / −%17 | 7b +%4,3 / −%9 (ARA 7b +%9,1): **tuttu**.
`aya_low_30_az0`: 11 **+%13,2 / −%1** (ARA +%10,5) | 7a **+%21,7 / +%17** (ARA +%18,1) | 7b **+%11,7** / −%4 (ARA +%8,2): **tutmadı**.
`band_aya_60_az0`: 11 +%0,2 / −%45 | 7a +%7,3 / **+%6** | 7b −%0,4 / −%23: üçgen tuttu, 7a çizim tutmadı. `band_aya_70/75_az0`: +%5…+7,5 üçgen, çizim −%28…−%31 (üç dünyada): **tuttu**.

### Neden harfiyen YAPILAMADI (kanıtlı yorum)
`az90` ve `az180` bakışlarındaki büyük artışlar (ör. 7a `band_aya_70_az90` +%35 üçgen / +%102 çizim) **Ayasofya katmanlarından gelmiyor**: aynı bakışta
Ayasofya gizlenince fark ≈ +%1 (`aya_payi_eslesik.txt`: `band_aya_70_az90` +7,4 bin, +2 çizim). Ekran karesi (ÖNCE | SONRA, `band_aya_70_az90`, 7a) nedeni gösteriyor:
ÖNCE'de bu bakışta kamera **düz turuncu dev bir levhaya** bakıyor, arkasındaki bütün şehir çizilmiyor; SONRA'da levha gitti, arkada gerçek şehir (evler, Hipodrom, uzak yapılar) çiziliyor.
Yani fazlalık, hatalı eski dev kutunun örttüğü gerçek içeriğin artık görünmesi; bu ARA'da da aynı (ARA ≈ SONRA bu bakışlarda). Bunu "bütçeyi tutturmak için" gizlemek ya da kutuyu geri koymak yapılamaz.
`aya_low_30_az0` fazlalığı da (+%11…+22) büyük ölçüde arka plan içeriği: eşli ölçümde Ayasofya payı 23,6 bin (≈ %3).
Yakın kabuğun payını daha da kısmak için kalan seçenekler (dış çizgiyi kapatmak, parça silmek) görünüşü bozar: **yapılmadı**.
Önerim (ORTAK DOSYA ÖNERİSİ, uygulanmadı): Ayasofya içinde gövdeyi saran bir `OccluderInstance3D` kutusu (iç mekân yürünebilir olduğundan kamera içindeyken sorun çıkarabilir, bu yüzden bu turda eklenmedi; `Props.occluder` gibi, kamera dışarıdayken etkin olacak bir betikle).

### Düz kopya rengi (ZORUNLU 2): **DÜZELDİ** (küçük fark kaldı)
`bake(..., flat, lin_avg)` (`world1453.gd:612`, `:694`) ve `_avg_lin` (`:746`): düz kopyada dokulu tuğlanın rengi, sRGB ortalamasının ham hâli yerine **doğrusala çevrilmiş ortalamanın ham sRGB ile yarı yoldaki karışımı** (ilk deneme tam doğrusal: fazla koyu kahve, pafta `p2_03` sağ alt; ham: eski soluk somon). Kare: `p2_03` (46 | 48,5 m yakın kabuk, 51,5 m düz kopya): ton yakın kabuğa yakın, hafif daha kahve; "gözle ayırt edilmesin" ölçütü **tam tutmuyor** (düz kopyada derz çizgisi yok, ton biraz soluk-koyu): **KISMEN**. Bu çekim 7a gündüz bakışında, 60 | 65 | 70 m yerine 46 | 48,5 | 51,5 m'de (geçiş artık 50 m).

## [Z3] Marmara surundaki nöbet ateşleri (`horn_world.gd`): **DÜZELDİ**
- `_wall_run` (`horn_world.gd:~495–515`) ve yeni `_tower_clear` (`:536`): sur ateşi, `_wall_run`'ın kuracağı kulelerin 8×8 m ayak izine en az 6,5 m uzakta olacak biçimde parça içinde kaydırılır (`rng` çağrı sırası değişmedi, yeni rastgelelik yok); hiçbir yer uygun değilse o parçada ateş yok (bu turda hiçbir parça ateşsiz kalmadı: 43 ateş yine 43).
- Kule çatısı ateşi (`:527`): köşe siperlerinin (1,3 m) arkasında kalan alçak küçük alev yerine mangal (0,9 m kutu) üstünde 1 m'lik alev (üstü siperlerin üstüne taşıyor).
- Konum farkları (ARA → SONRA): Marmara `(−371,5/−1416,5)` → `(−367,2/−1410,9)`, `(−515,9/−1605,6)` → `(−521,4/−1612,7)`, `(−130,7/−1101,3)` → `(−134,4/−1106,0)`, `(−227,0/−1227,3)` → `(−226,4/−1226,5)`; Haliç `x −700,2`: z `−1561,2 → −1555,2`, `−1482,1 → −1489,1`, `−1086,7 → −1092,7`, `−770,5 → −762,5`, `−691,4 → −697,4` (diğer ateşler aynı).
- Kare (Bölüm 11 gece; ÖNCE | SONRA; dört yön az0/90/180/270, 6 m, ateşin 1 m üstü): `p2_04`: ÖNCE'de her iki hedef ateş de yok/kule içinde; SONRA'da `(−367/−1410)` **4/4 alev**, `(−521/−1612)` (kule çatısı içinde olan) **4/4 alev**. `p2_06`: ötekilerin (duvar ateşleri 30, 32, 37, 39) **4/4**. `p2_05`: kule çatısı ateşleri (28, 31, 36…) mangal üstünde alev, önceki turda köşe siperi arkasında kalan az90/az270 artık **4/4**.
- Haliç (x −700): ateş kareleri **ARA | SONRA aynı** (`sh_fs` | `sh_fs2` karşılaştırması). Bu sondada Haliç duvar ateşlerinin az0/az180 bakışlarında kamera sur gövdesi/arkasında kalan düz yüzey önünde kalıyor (az90/az270 alev görünüyor); denetçinin ölçümünde 4/4 sayılmıştı ve bu tur o ateşlere (beş tanesi 6–8 m kayan) dokunmadığı için **Haliç sonucu denetçinin 4/4'ünü yineleyemedim, bozulmadığını ARA | SONRA aynılığıyla gösteriyorum (KISMEN KANITSIZ)**; denetçinin kamera konumuyla yineleme gerekir.
- Gündüz alevsiz siyah mangal küpü (öneri N1): yapılmadı (zorunlu değil).

## Testler (başsız, `--max-fps 20`)
`testler2.txt`: **47/47 `AUTOTEST PASS`**, her koşuda `yasak_satir=0` (SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, LOOKAUDIT backturn, JOURNEY_MISS, JOURNEY_OVERLAP).
Kapsam: 3 (6), 4 (9), 6 (— ve byz), 7 (10), 8, 8y, 9, 10, 11 (10), 24, 25, 26, 27, 30, 31o. `kontroller2.txt`: `PARSECHECK PASS scripts=248`, `FLIGHTCHECK PASS`, `WORLDCHECK PASS regions=13 landmarks=35`.
**`city_check`: FAIL** (`31o: CityLife kare süresi 3149 µs > 1500`): bu işten bağımsız, ÖNCE ve ARA'da da aynı FAIL (denetçi raporu: 3738 / 3647 µs); hava kodu CityLife'a dokunmuyor, dokunulmadı.

## Kurallara uygunluk
- Yalnız `scripts/world/world1453.gd` ve `scripts/world/horn_world.gd` değişti (`git diff 1c067c73 HEAD -- scripts`); replik, sıra, süre, sayaç, kazanma/kaybetme, denge, kalabalık sayısı, bot yolu yok; yeni `class_name` yok; denetim susturma yok.
- Sonda (`tests/_tmp`, `project.godot` otoload satırı) depoya girmedi; `.import` ve yeniden üretilen `i18n/*.translation` kaydedilmedi.

## YAPILAMAYAN / KANITSIZ
- Ayasofya ≤ 150 m harfiyen "bütün bakışlarda ≤ +%8 ve çizim ≤ ÖNCE": **yapılamadı** (neden yukarıda); denetçinin protokolüyle birebir yeniden ölçüm yapılmadı, benim bakış kataloğum ve dört yön kullanıldı, sayılar denetçininkinden farklı olabilir.
- 7a ve 7b için 80 yerine 32 bakış (bölüm 7 koşuları çok yavaş).
- ÖNCE'deki Ayasofya modelinin kendi payı ayrı ölçülmedi.
- 50 m geçiş bandında 1 m adımlı ölü bant taraması ve gündüz gölge şekli yinelenmedi.
- Haliç ateşleri için denetçinin 4/4 sonucu yinelenemedi (yukarıda).
- Ekran karelerinin alt kenarındaki beyaz bant sonda kaynaklı (kare yakalama anı), oyun kusuru değil.

## Paftalar (en çok 8; bu turda 6)
`p2_01` Ayasofya `aya_m25` dört yön ÖNCE | ARA | SONRA (gece, Bölüm 11) · `p2_02` `aya_low_30` dört yön ÖNCE | ARA | SONRA · `p2_03` gündüz yakın kabuk (46, 48,5 m) | düz kopya (51,5 m) ve reddedilen ilk deneme ·
`p2_04` Marmara iki hedef ateş ÖNCE | SONRA dört yön · `p2_05` Marmara kule çatısı ateşleri ÖNCE | önceki tur | SONRA · `p2_06` Marmara duvar ateşleri SONRA dört yön.
