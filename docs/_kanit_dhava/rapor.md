# Düzeltme turu: havadan şehir (Z1–Z4) — geliştirici raporu

Dal `wip/duzeltme-hava`. Taban/ÖNCE: `e551de84`. Değişen dosya: yalnız `scripts/world/world1453.gd` (`bake`, `far_aya` ve yardımcılar) ve `scripts/world/horn_world.gd` (yalnız kıyı suru nöbet ateşi). `byz_city.gd` değişmedi. Replik, süre, sayaç, denge, kalabalık, bot yolu değişmedi.

**Yöntem notu (dürüstlük):** kareler oynanış koşusundan değil, kendi ölçüm sondamdan (gerçek `CampDay`/`ByzCity` dünyası, uçuş kamerası, aynı kamera dünya koordinatı; ÖNCE = `e551de84`'ün hava dosyalarının geri alındığı depo-dışı kopya). Bu yüzden dosya adları `sonda_`. Sonda oyun kodunda yok (`tests/_tmp` silindi, `grep` temiz). Çizim/üçgen = `RenderingServer` toplam çizim/ilkel sayacı (RINFO'nun kullandığı; gölge geçişi dahil), her bakışta üç ardışık kare.

## Madde madde

| Madde | Hüküm | Kanıt |
|---|---|---|
| **Z1** hub evleri havadan terrakota kiremit çatılı | **DÜZELDİ** (gündüz/gece; kiremit dokusu yok, düz renk) | `sonda_01`…`04` |
| **Z2** Ayasofya ≤150 m: üçgen ≤ +%8, çizim artmasın | **KISMEN**: üçgen ≤ +%7,7 (`aya_m25` +%6,4, `aya_m60` +%1,5, `band_aya_60…140` −%3,2…+%7,7); ek bakış `aya_low_30` +%8,5. Çizim: +0…+3 (m25 +3, `band_aya_60` +15) → "çizim artmaz" **sağlanmadı** | `sonda_05_*`, tablo |
| **Z3** kıyı suru ateşleri 6 m'den dört yönden | **KISMEN**: Haliç suru 4/4 yön alev seçiliyor (ÖNCE 0/4). Marmara suru: az0 ve az90'dan seçiliyor; az180 ve az270'te kamera büyük beyaz bir yapının (ne olduğunu belirlemedim) yanında/arkasında, ateş görünmüyor | `sonda_09`, `10`, `11` |
| **Z4** rapor | bu belge; ilk raporun "üçgen her bakışta < %8" ve "hub yer/ölçü/renk/doku aynı" cümleleri **geçersiz** (aşağıda doğrusu) | tablolar |

### Z1 — neden ve düzeltme
Denetçinin kestirdiği neden kısmen doğru; iki ayrı hata buldum:
1. `bake(max_tris=300)` prizma değişimini **300 üçgenden büyük her ağa** uyguluyordu (yalnız çatıya değil). Bütün bir ev ağı da AABB prizmasına dönüp **beyaz levha** oluyordu (gece "beyaz eğik düzlem" bu). Şimdi yalnız adında/atasında/ağında "roof" geçen parçalara uygulanıyor (`_roofish`).
2. Çatı rengi `get_active_material(0)`'dan alınıyordu; Kit çatısı iki yüzeyli (0: saçak şeridi, ortalama gri-kahve; 1: kiremit, 1276–1800 üçgen). Şimdi en çok üçgeni olan yüzey; doku ortalaması sRGB, köşe rengi doğrusal okunduğu için `srgb_to_linear().lerp(ham, 0.5)` (tam doğrusal çok koyu kırmızı çıktı: `sonra3` denemesi).
Kalan fark: yerdeki çatıda kiremit dokusu/kabartması var, uzaktakinde düz turuncu-kırmızı; gece tonu yerdekinden biraz daha kırmızı.

### Z2 — ne yapıldı
- Yakın kabuk (17 696 üçgen) ve düz kopya (12 904) **gölge atmaz**; gölgeyi elle kurulu 1 196 üçgenlik vekil atar (`_shadow_proxy`: küre/silindir seyrek ayrıtlı, diğer büyük parçalar sınır kutusu). Sayaçtaki ~114 bin üçgenlik yük (gölge kademeleri + dış çizgi) buradan geldi (kabuğu gizleyince `aya_m25` 595k→589k, kabukla 703k).
- Dokulu yakın kabuk menzili 90 m → 60 m (`AYA_NEAR`). Parça eşiği 0,4 m.
- Gölge biçimi yaklaşık: kubbe seyrek küre, duvarlar kutu; **gölgenin ince ayrıntısı kayboldu** (karelerde ayrıca incelemedim: KANITSIZ).
- Çizim artışının bir kısmı kabuktan bağımsız: kabuğu gizlesem bile `band_aya_60` ÖNCE'den +13 çizim, +%6 üçgen fazla (bölgenin zemin/öteki hava değişiklikleri, benim dosya listem dışı).

## Ölçümler (gündüz, 7a dünyası; ÖNCE | SONRA, üç ardışık kare)
| bakış | ÖNCE çizim (3 örnek) | SONRA çizim (3 örnek) | ÖNCE üçgen k (3 örnek) | SONRA üçgen k (3 örnek) | Δçizim | Δüçgen (ortanca) |
|---|---|---|---|---|---|---|
| hub_m25 | 6927 / 6923 / 6923 | 6614 / 6604 / 6610 | 6033 / 6021 / 6021 | 6257 / 6238 / 6254 | -4.5% | +3.9% |
| hub_st | 2325 / 2289 / 2277 | 1724 / 1730 / 1724 | 2840 / 2825 / 2780 | 2938 / 2977 / 2944 | -24.7% | +4.2% |
| aya_m25 | 237 / 237 / 237 | 240 / 240 / 240 | 595 / 595 / 595 | 633 / 633 / 633 | +1.3% | +6.4% |
| aya_m60 | 295 / 295 / 295 | 302 / 302 / 302 | 770 / 770 / 770 | 781 / 781 / 781 | +2.4% | +1.5% |
| band_aya_60 | 237 / 237 / 237 | 252 / 252 / 252 | 594 / 594 / 594 | 640 / 640 / 640 | +6.3% | +7.7% |
| band_aya_70 | 294 / 294 / 294 | 280 / 280 / 280 | 742 / 742 / 742 | 718 / 718 / 718 | -4.8% | -3.2% |
| band_aya_80 | 307 / 307 / 307 | 307 / 307 / 307 | 777 / 777 / 777 | 788 / 788 / 788 | +0.0% | +1.4% |
| band_aya_90 | 342 / 342 / 342 | 347 / 347 / 347 | 820 / 820 / 820 | 835 / 835 / 835 | +1.5% | +1.7% |
| band_aya_100 | 328 / 328 / 328 | 329 / 329 / 329 | 782 / 782 / 782 | 797 / 797 / 797 | +0.3% | +1.9% |
| band_aya_110 | 350 / 350 / 350 | 351 / 351 / 351 | 756 / 756 / 756 | 771 / 771 / 771 | +0.3% | +2.0% |
| band_aya_120 | 350 / 350 / 350 | 350 / 350 / 350 | 749 / 749 / 749 | 763 / 763 / 763 | +0.0% | +1.9% |
| band_aya_130 | 341 / 341 / 341 | 342 / 342 / 342 | 725 / 725 / 725 | 742 / 742 / 742 | +0.3% | +2.3% |
| band_aya_140 | 345 / 345 / 345 | 345 / 345 / 345 | 684 / 684 / 684 | 699 / 699 / 699 | +0.0% | +2.1% |
| aya_low_30 | 222 / 222 / 222 | 227 / 227 / 227 | 489 / 489 / 489 | 530 / 530 / 530 | +2.3% | +8.5% |

## Gece (Bölüm 11 dünyası) hub

| bakış | ÖNCE çizim (3 örnek) | SONRA çizim (3 örnek) | ÖNCE üçgen k (3 örnek) | SONRA üçgen k (3 örnek) | Δçizim | Δüçgen (ortanca) |
|---|---|---|---|---|---|---|
| hub_m25 | 7216 / 7200 / 7206 | 6885 / 6883 / 6885 | 5801 / 5769 / 5781 | 6108 / 6099 / 6106 | -4.5% | +5.6% |
| hub_st | 2116 / 2027 / 2116 | 1672 / 1651 / 1655 | 2628 / 2478 / 2627 | 2788 / 2756 / 2775 | -21.8% | +5.6% |

Hub'da çizim −%4…−%25 (ÖNCE'de hub yoktu; tarla), üçgen +%3,9…+%5,6: hub görevi kapsamında sınır içinde. Not: tablo ÖNCE'ye göredir; yalnız Ayasofya ve hub bakışlarını ölçtüm. **Bölüm 6, 8, 20, 24–27, 30, 31o yer bakışları ve Blakherna/Hipodrom/Galata için ÖNCE|SONRA ölçmedim: BAKILMADI.** Kare hızı karşılaştırılamadı (llvmpipe).

## Testler (başsız, `--max-fps 20`; her koşuda SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, LOOKAUDIT backturn, JOURNEY_* = 0)
- **47/47 `AUTOTEST PASS`**: 3 (6 varyant), 4 (9), 6 (—, byz), 7 (10), 8, 8y, 9, 10, 11 (10), 24, 25, 26, 27, 30, 31o. Ham satırlar bu klasörde `testler.txt`.
- `parse_check` PASS (248), `flight_check` PASS, `world_check` PASS (13 bölge, 35 yer işareti).
- `city_check` **FAIL**: 31o CityLife kare süresi eşiği (SONRA 3811–4011 µs, 24'te bir koşuda 1508 µs > 1500). **ÖNCE kopyasında da aynı 31o FAIL (4354 µs)** → bu işten bağımsız, mevcut/zamanlama gürültüsü; çözmedim.
- Komşu bölüm koşuları: listedeki bütün bölümler yukarıda.

## Yapılmayanlar / açık
- Z2 çizim sayısı ÖNCE'nin altına inmedi (+0…+3 yakın, `band_aya_60` +15; bunun ~+13'ü kabuktan bağımsız).
- Z3 Marmara iki yönde görünmüyor (engelleyen yapıyı araştırmadım).
- Oynanış koşusundan ÖNCE|SONRA kare çifti yok (yalnız sonda kareleri).
- Hub çatıları kiremit dokusuz.
- Ayasofya gölgesinin kare doğrulaması yok.
- ORTAK DOSYA ÖNERİSİ: yok.

## Pafta dizini
01–02 hub gece ÖNCE|SONRA · 03–04 hub gündüz ÖNCE|SONRA(7a uzak)|7b yerdeki hub · 05 Ayasofya (aya_m25, aya_low_30, band_aya_60, band_aya_90) ÖNCE|SONRA · 09 Haliç suru 4 yön (ÖNCE|SONRA) · 10–11 Marmara suru 4 yön (ÖNCE|SONRA).
