# TAŞIMA 10 — 1. ÖLÇ VE DÖK

Kaynak: kod okuması (dosya:satır taban f962b002) + sonda `tests/_ist/tasima10_sonda.tscn` (çıktı `testler/sonda.txt`).
Bütün koordinatlar bölümün yerel çerçevesinde (hub: ByzCity yereli; 8y: bölge yereli, x 0 = kapı ortası, +z ova).

## 0. Setler

| Set | Eski | Yeni |
|---|---|---|
| Hub (6b, 7b, 10h, 12b) | `ByzCity._build_walls` (`byz_city.gd:1545-1612`): iç sur x 34 (3 m kalın, 12 m yüksek, 70 m), kuleler 6×16×6 (z −34, −18, −2, 14), mazgallar küp, Romanos açıklığı `gz` (World1453.LAND_GATES'ten, ≈ −31,5), süslü "çıkış" kapısı `_build_gate` (EXIT_POS z 5,5: mermer ayak, kemer, kutu sancak, karanlık geçit ve ışık kutusu — geçit YOK, kapı sura çizili). v2'de (IstBaglama, 7b/10h/12b) bu kutu sur v2'nin kara surunun üstüne oturur (hub_x: hub x 34 ↔ v2 iç sur, hub z −31,5 ↔ v2 Romanos) | `SurHub` (`scripts/world/ist/sur_set_hub.gd`): yeni surun **"romanos" kesimi** (`SurOyun.kur("romanos")`, şehirdeki Romanos kapı koşusunun aynısı: L 60, tohum, `IstSurlar.OPTS["romanos"]`) hub çerçevesine; v2'de hub kesimin GERÇEK yerine oturur, şehrin "romanos" dilimi kaldırılır |
| 8y | `World1453.build(self, "gate8y", KEEP)` (`chapter8y.gd:142`): eski dünyanın kutu kara surları (SiegeField `_wall_extension`, `_gates`) + bölümün kendi kutu kapı kanatları, sürgü, dolgu geçit | (bkz. rapor) |

## 1. Yeni kesimin ölçüleri ("romanos", sonda)

| Ölçü | Kesim yereli | Hub yereli (SurHub.M) |
|---|---|---|
| İç sur | zi0 −2,5 … zi1 2,5 (5 m), sur yolu HW 12, en 4,1 | şehir yüzü x 32,5 (eskiyle aynı), peribolos yüzü 37,5; yol y 12,12, orta x 35,0 |
| İç kuleler (kapı kuleleri) | x ±10,15, en 13,5, peribolosa taşma 8,4; tepe HT 19 | z −11,4…2,1 ve 8,9…22,4; tepe y 19,12 |
| Kule geçidi (sur yolu) | 2,2 × 3,0 (`KULE_GECIT_IC`) | kulenin −z yüzü z −11,4 = 12b'nin "kuleye açılan kapı"sı |
| Kapı | gw 5,0, gh 4,6, koridor (peribolostan kapalı) | z 5,5 (EXIT_POS), iç eşik (31,0; 0; 5,5) |
| Dış sur | zo0 17,5 … zo1 20,1, OH 8,5 | x 52,5 … 55,1 |
| Teras / hendek / ova | teras y −3,673; hendek zm0 30,1 … zm1 50,1, dip −9,55; ova y −3,573 | hendek x 65,1 … 85,1; ova x > 85,1, y −3,45 |
| Kapı köprüsü | kopru_yakin z 34,6 → kopru_uzak 45,6 (y −3,553) | x 69,6 → 80,6 |
| Dış kademe dy | −3,553 | |

## 2. Bağlar (bölüm bölüm)

### 12b — Son Akşam (`chapter12b.gd`)
| Bağ | Eski | Not |
|---|---|---|
| `WALL_TOP` | (33,3; 12,05; −11,2) | oyuncu (yerçekimsiz) |
| `EMP_AT` | (34,75; 12,0; −8,6) | İmparator mazgala bakar |
| `SPH_AT` | (33,4; 12,0; −6,4) | Sfrancis |
| `DOOR` | (33,4; 12,0; −5,2) | kuleye açılan kapı (kutu siyah levha + top yarım) |
| Mazgallar | x 35,3, z −14,6…−5,2 (1,5 m) | bölümün kutu dişleri |
| Sancak | (34; 16,9; −2) kule tepesi | kutu levha |
| Meşaleler | (32,75; 12; −14,2 / −7,4 / −5,8) | iç kenar |
| Nöbetçiler | (33,9; 12; −14,2), kule tepeleri (34,6; 16; −18 / −1,2) | |
| Meşale yürüyüşü sınırı | x 32,3…34,9, z −14,9…−5,7 | `_light_torches_yourself` |
| Ordugâh görünümü | zemin kutusu 420×360 (y −0,08), hendek kutusu x 44, dış sur kutusu x 50 (+ 6 kutu kule), çit x 62, tabya kutuları x 66, çadırlar x 72…300, ateşler x 66…280, otağ x 170 | hepsi y 0 |
| Süreli evre | `hud.choose(…, 12.0, pick)` "Yaptığın şey yetecek mi?" | 12 sn — DEĞİŞMEZ |
| Bot yolu | autotest: meşalelere ışınlanır (`player.global_position = Vector3(33,4; y; meşale z)`) | |

### 10h — Heyet (`chapter10h.gd`)
| Bağ | Eski | Not |
|---|---|---|
| `BREACH` | (32,4; 0; −26,0) | iç surun şehir yüzünde "yarık" (kutu kırık levhalar, tuğla kutuları, moloz topları), kazık, fıçı, barikat (`_stockade`), etkileşim "gedik", meşale |
| Çıkış | `ByzCity.EXIT_POS` (33; 0; 5,5) "exit" etkileşimi; heyet kapıda `EXIT_POS + (−3; 0; 0)` | |
| Gece doğuşu | `ByzCity.START` | |
| Süre | yok (gece serbest) | |
| Bot | `_auto_night`: `_task(id)` doğrudan (yürümez) | |

### 6b — Surların İçi (`chapter6.gd`)
| Bağ | Eski | Not |
|---|---|---|
| Martı tünekleri `PERCHES` | çeşme, tente, çamaşır ipi, tabela, **sur yolundaki su fıçısı (16,5; 1,27; −11)**, Giustiniani'nin masası (24,6; 0,84; −12,4) | "sur yolu" = surun dibindeki yer seviyesindeki yol (x 14…32); sur üstüne çıkılmaz |
| Ortam sesi | `p.x > 14` → amb_wall_day | |
| Çıkış | `EXIT_POS`; beyaz bayrak (kutu levha) `door + (−2; 2,4; 2,05)`; oyuncu `door + (−2,6; 0; 0)`, Niko `door + (−1,4; 0; −1,1)` | |
| Süre | martı tüneklerinde sabır süreleri (16/14 sn) — mesafeden bağımsız | |
| Bot | `_auto_6b`: ışınlanır/etkileşim | |

### 7b — Saha Çalışması (`chapter7.gd`)
| Bağ | Eski | Not |
|---|---|---|
| İz "walls" | `GIUST_POS + (−3,5; 0; 2,5)` | |
| İz "outside" | `EXIT_POS + (−2,4; 0; 1,4)` | kapının şehir yanı |
| Uçuş | v2 (IstBaglama, bolum 7) | hub v2'de |

### 8y — Beyaz Havlu (`chapter8y.gd`)
| Bağ | Eski | Not |
|---|---|---|
| Bölge | dünya x 37 (`World1453.LAND_GATES`), `REGIONS["gate8y"]` | eski dünya (kutu) |
| `START` | (0; 0; −10) | şehir içi |
| İç sur kapısı | z ≈ 0 (dünyanın iç suru z −2,3; kutu) | |
| `GATE_TRIGGER_Z` | 8,4 | nöbetçi evresi |
| Dış kapı `GATE_Z` / `HINGE_X` | 13,85 / ±3,45; sürgü `BAR_AT` (0; 1,55; 13,62) | bölümün kutu kanatları |
| Köprü `BRIDGE_Z` | 21 (dolgu geçit 7 × 16,6, z 20…36,5) | |
| Ova `FIELD_Z` | 37 | |
| Engeller `BARRIERS`, `PATH`, `HALT_Z` | z 54 / 72 / 90, 76 | |
| Siper `TRENCH_Z` | 103,5; Hasan/Hüseyin z 109 | |
| Bitiş `END_Z` | 137,5; pazar z 141; ordugâh `CAMP_Z0` 162 | |
| Koridor yarı eni `LANE_HALF` | 13,8 | |
| Yürüyüş | z −10 → 137,5 ≈ 148 m | süre yok |
