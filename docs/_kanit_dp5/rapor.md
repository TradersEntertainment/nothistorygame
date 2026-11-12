# P5 düzeltme turu raporu (GELİŞTİRİCİ) — dal wip/yardimci-p5

Denetçi kararı: KÜÇÜK DÜZELTMELERLE KABUL. Paftalar: `docs/_kanit_dp5/pafta_*.jpg` (ÖNCE sol | SONRA sağ, ekranlı oynanış koşusu, aynı replik anı/anahtar).

## Maddeler
| # | Madde | Ne yapıldı | Durum |
|---|---|---|---|
| 1 | `docs/_kanit_p5/rapor.md` yanlış cümleler | Testler bölümü düzeltildi (d8c44121): "ekranlı AUTOTEST FAIL" yanlıştı (denetimde ekranlı PASS); VISAUDIT CityLife paketten gelmiyor (özgün 1/20, son kod 1/20, `city_life.gd:1210`); "özgünde 0/9" örneklem küçüklüğüydü. | DÜZELDİ |
| 2 | 32o U_END +%9,9 üçgen / +174 çizim | `chapter32o.gd`: mantoyu iten askerler özgün yere döndü (`Vector3(sx*1.6,0,1.0)`); `_battery_ground()` MultiMesh'leri batarya evresine kadar gizli (`_battery_mms`, `_guns()` açar). Son ölçüm (`once32` vs `sonra32c`, 41 ortak an): üçgen en kötü +%7,3 (U_END), hiçbir an >%8; ortanca çizim −60. U_END çizim +267, H_01 +507 (aynı anlarda ÖNCE↔ÖNCE tek başına ±1000 çizim oynuyor: CityLife yayaları + düello kamerası). | KISMEN: üçgen ≤%8 sağlandı; U_END çizimin "artmaz" şartı gürültü içinde KANITLANAMADI |
| 3 | 42b H_LADDER_1 çizim/üçgen | Sabit kadrajda üçgen +%6,0/−%3,2 (≤%8), çizim +11/+135 (gürültü içinde); sabit sahneli anlarda çizim −170…−195. Düello/bitiş anlarında ÖNCE↔ÖNCE bile +%34 oynadığı için artış KANITLANAMADI; dekor birleştirme kapsamı genişletilmedi. Pafta 03, 04. | KANITLANAMADI (kod değişmedi) |
| 4a | 41o `_hold_pot` (su kabı) | Oynanış karesinde seçilmiyor. | DURUYOR, KANITSIZ |
| 4b | 32o `_shoulder_grip` (demet) | Oynanış karesinde seçilmiyor. | DURUYOR, KANITSIZ |
| 4c | 32o `_gun_hands` | Kepçeci kısmen seçiliyor (`k/cift/yamak_t0590_t0506.jpg`, pafta 10); manivelacı/gülleci büyük topta oyuncu bakışında namlu ardında kalıyor. | KISMEN; manivelacı/gülleci KANITSIZ |
| 4d | 20o top tayfası | Pafta 05, 06. | KISMEN |

## Testler
- P5 bütün bölüm testleri bütün varyantlarıyla iki tur: 48/48 PASS. Yasak satır: yalnız tur 1 42b std'de 1 `VISAUDIT overlap CityLife` (paketten gelmiyor). 42b std ek 4 koşu (tur 3–6): 4/4 PASS, yasak satır 0. `parse_check` PASS (247).
- Yasak satır grep: SCRIPT ERROR, WARN_*, WALKTHRU, ARMAUDIT, HELDAUDIT, LOOKAUDIT backturn, JOURNEY_* = 0.

## Performans (ekranlı RINFO, ortak anlar, ÖNCE→SONRA)
| Bölüm | Ortak an | Çizim ortanca | Üçgen en kötü | >%8 an |
|---|---|---|---|---|
| 41o | 43 | −133 (artan an 0) | +%2,65 | 0 |
| 20o | 17 | −110 (artan 2: T_DUEL +1110, N_NIGHT +1077 — düello/gece, gürültü bölgesi) | +%4,48 | 0 |
| 32o | 41 | −60 (artan 11, en kötü H_01 +507, U_END +267) | +%7,32 | 0 |
| 42b | bkz. önceki tur | kare altı | ≤ +%6,0 | 0 |

## ORTAK DOSYA ÖNERİSİ (uygulanmadı)
- `scripts/combat/cannon_crew.gd` `_crew_spots()`: kepçe `m - fwd*0.3 + side*1.85`, gülle `m - fwd*1.0 - side*1.15`, manivela `bp - fwd*2.1 + side*0.25` büyük topta oyuncu bakışında namlu ardında; tayfayı oyuncu tarafına almak 4c'yi görünür kılar.
- Önceki raporun land_walls / Nature önerileri geçerli.
- İsteğe bağlı: `chapter32o.gd _push_grip` döngülü Tween sızıntısı (zorunlu değil, uygulanmadı).

## YAPILAMAYAN
32o U_END çizim artmama kanıtı; 42b düello/bitiş anı bütçe kanıtı; 41o su kabı, 32o demet tutuşu, manivelacı/gülleci görünürlüğü.

## BAKILMADI
Gece evreleri, çekicin kirişe inişi, 42b okçu okları, düello anları.

## Temizlik
Geçici kancalar (`DSHOT`, `HIDECITY`, `PROBEUEND`, `_hk_`) depoda yok (grep boş); `hud.gd` değişmedi. Değişen kod: yalnız `scripts/chapter32o.gd`.
