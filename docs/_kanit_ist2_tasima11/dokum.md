# TAŞIMA 11 — ÖLÇ VE DÖK (madde 1)

Taban `wip/ist2-taban18` = bb334de7. Ölçüler kodun kendisinden (satır numaraları taban dosyalarına göre) ve sondalardan
(`tests/_ist/tasima11_halic_sonda`, bölüm koşularındaki `T11CIKIS`/`T11ESIK`/`DENIZSET` satırları). Danışmanın verdiği
ölçülerden kodla UYUŞMAYANLAR **kalın** işaretli.

## 1. Sekiz bölümün sur/kıyı bağları

| bölüm | kurucu | kip | sur bağları (sabit / SeaWalls.* / Horn / HornWorld) |
|---|---|---|---|
| 4 (4b dalı: `chain`, `nofez`, `fall`) | `SeaWalls.new()` `chapter4.gd:99` | `in_world` YOK: su, zincir, ±420 m devam, şehir, karşı kıyı dosyanın kendisinde (`sea_walls.gd:38-44`) | `CHAIN_START/END` denge yolu (`chapter4.gd:690-708`, 32 m), rıhtım `QUAY_Y` 0,7 (`:664,740,776`), kapı `GATE_X` 17 (`:666-668,741,860,921`), `WALL_Z` −3,2 (`:775,845`), `walls.niko` (`:628,670-674`), `WATER_Y` (`:993`) |
| 4 (4a dalı: `""`, caught, fez, item, market, next, wet) | `Camp` | — | sur yok (gerileme ×1) |
| 17 | `SeaWalls.new()` `chapter17.gd:132` | `in_world = true` | rıhtım üstü (`:890`, x 1,5; z −1,4), Trevisano (`:898`), `walls.get_children()` ortam (`:987`); su/zincir/devam `HornWorld`'den; `niko.visible = false` |
| 19 | `SeaWalls.new()` ×2 (`:70`, `:525`) | `in_world` | dönüşte `walls.niko` (−10,2; 0,7; −0,7) (`:533`; x −6 kulesinin batı yanı), iki kurulum da `walls.bolum = "19"` |
| 19o | `SeaWalls.new()` `:70` | `in_world` | `walls.get_children()` WorldEnvironment/DirectionalLight3D (`:227,245`) |
| 29, 29o | `SeaWalls.new()` `:63` / `:61` | `in_world` | `SeaBattle.make_day/make_dusk` (`sea_battle.gd:46-75`): ortam ve güneş `walls`'ın DOĞRUDAN çocukları, `walls.lights`, `walls.niko`, `walls.world.set_mode` |
| 18b | `Horn.build(self, 62, …, gap (−20; 20), …, world)` `:85` + bölümün satır arası sur kurulumu `:119-128` | tek harita (`horn_bridge`) | aşağıda §3 |
| 38o | `Horn.build(self, 62, …, gap (−24; 24), …)` `:115` + `_build_wall` `:135-177` | tek harita (`horn_wall_o`) | aşağıda §4 |

Ortak okuyanlar: `unclip.gd:47` (`par is SeaWalls` → görünür katı kuralı), `look.gd:11` (`"SeaWalls": "night"`).

## 2. SeaWalls (`scripts/level/sea_walls.gd`) — çarpışma kutuları (yeni kipte AYNI, gizli + `wall`/`ground` metası)

| parça | kod | ölçü |
|---|---|---|
| rıhtım | `_build_quay` `:93-96` | x −5…20 (boy 25), z −3,2…0, y −1,0…**0,7** (`QUAY_Y`) |
| sur gövdesi (iki parça) | `_build_wall` `:152-154` | x −60…10,2 ve 13,8…80; z −7,2…−3,2 (4,0 kalın; ön yüz `WALL_Z` −3,2); y **−1,3…11,7** (su 0'ın 1,3 m altı) |
| x 12 geçidi | `:149-158` | yarı en 1,8 (x 10,2…13,8); **lento kutusu y 3,7…11,7** (`over` = 11 − 5 + 2 = 8 m) → gerçek açıklık eşik 0,68 … **3,7 (3,0 m)**, danışmanın "yükseklik 5,0"ı `gh` değişkeni, kutu değil |
| x 12 eşiği | `:159` | 3,6 × 0,4 × 4,4, üst y 0,68 |
| kuleler | `:173-175` | x −22, −6, 30, 58; 6,0 × 16,0 × 6,5; z −7,65…**−1,15**; y 0,7…16,7 (**suyun 0,7 m üstünde başlıyordu: x −22, 30, 58 kuleleri havada**; yeni görünüşte temel −3,0'a iner) |
| x 17 süslü kapı | `_build_gate` `:292-339` | yarı en 1,15, kanat boyu 2,7, kör duvara yapışık; çarpışmasız (yalnız `interactable` alanı + meşale direği) |
| dişler | `:164-171` | 0,8 × 0,9 × 0,6; x −60 + 1,6 k; z merkez −4,05 (yüzden 0,85 geride); çarpışmasız |
| Niko | `:47` | (4,8; 11,7; −3,45): dişlerin önündeki 0,55 m'lik kenarda |
| zincir | `_build_chain` `:83-90` (yalnız 4b) | kütükler `CHAIN_START`→`END` 2,3 m arayla (merkez y 0,33); bağlama babası (0,9; 0,45; 1,6) — DEĞİŞMEDİ |
| meşaleler | `:179-184` | kule tepeleri (tx + 2,2; 16,7; −1,6) ve sur üstü (x −12, 12, 22, 44; 11,7; −3,4) — `Night.torch` direği katı; yerleri aynı |
| devam (4b) | `_build_extension` `:190-241` | x −420…−60 ve 80…420, aynı kesit; kuleler rng 4223 dizisiyle (yeni kipte aynı dizi, aynı yerler) |

## 3. 18b (`scripts/chapter18b.gd`) — sur satır arası (`:119-128` taban)

| parça | ölçü (doğrulandı) |
|---|---|
| gövde | 40 × 9,6 × 3,0, merkez z 63,5 → z 62–65; **dış yüz z 62,00** |
| yol taşı | 40 × 0,3 × 4,0, merkez (0; 9,47; 61,5) → z 59,5–63,5, y 9,32–9,62 (2,5 m konsol) |
| dişler | 16 × (1,2 × 1,1 × 0,5), x −19 + 2,5 k, z 59,45–59,95, çarpışmasız |
| görünmez korkuluk | 40 × 1,1 × 0,3, z 59,45–59,75 (merkez 59,6), `no_climb` |
| kuleler | 6,2 × 14,6 × 6,2, x ±17, z 58,9–65,1 |
| top | (−0,25; 9,6; 60,6); mazgal boşluğu x −0,9…0,4 (dişler −1,5 ve 1,0'da) |
| çatlak işaretleri | `_crack_mark` (`:241-245`): gun + (0; −0,55; 1,05) ± (0,6; 0,2) → x −0,85…0,35, y 8,85–9,25, **z 61,65** (yol taşının ALTINDA, konsol boşluğunda) |
| `SECTIONS 11 × SEC_LEN 3` | FIÇI KÖPRÜ (`:96-104`, z 2–35): **SUR_BOLUM_TASIMA §1/§2.4'teki "11 × 3 m top yuvası" YANLIŞ** — dokunulmadı |
| Horn devamı | `Horn._sea_wall` (`horn.gd:85-128`): gövde z 62–65, y −1…9,6 (yalnız `Props.box`, çarpışmasız), dişler x a+1 + 2,5 k, z 62,3; kuleler 7 × 7 rng dizisiyle; tek haritada E = 220 (`WORLD_E`): bütün devam ≤ 220 m |

## 4. 38o (`scripts/chapter38o.gd`, `_build_wall` `:135-177` taban)

| parça | ölçü (doğrulandı) |
|---|---|
| gövde | 4,0 kalın, merkez z 62 → z 60–64; **dış yüz z 60,00**; x −24…13,4 ve 16,6…24; tepe 9,6 |
| deniz kapısı | `GATE_X` 15, `GATE_HW` 1,6 (x 13,4…16,6), lento y **5,4** (`QUAY_Y` 1,2 + `GATE_H` 4,2) … 9,6; eşik kutusu üst 1,18 |
| kapı engeli | görünmez, z 60,1 (`WALL_Z − 1,9`), EXITCHECK'te yok |
| yol taşı | 48 × 0,3 × 4,38, merkez (0; 9,47; 61,79) → z 59,6–63,98 (0,4 m konsol), y 9,32–9,62 |
| dişler | 19 × (1,2 × 1,1 × 0,5), x −22,5 + 2,5 k, z 59,6–60,1, çarpışmasız (`Props.box`) |
| kuleler | 6,2 × 14,6 × 6,2, x ±21, z 58,9–65,1 |
| kanatlar | 1,5 × 4,0 × 0,12, menteşe x 13,5 ve 16,5, z 59,75 |
| rıhtım | `QUAY` (6; 57,4; 18 × 2,8) → x 6…24, z 57,4…60,2 (gövdeyle 0,2 m iç içe), y −1,0…1,2 |
| babalar | (13; 1,2; 58,4) ve (20; 1,2; 58,4), `make_solid` silindir |
| kazan | `fight.add_cauldron((ROW_TO.x − 0,6; 9,6; WALL_Z − 1,3))` = (−6,6; 9,6; 60,7) |
| savunucular | `_guard_spots`: x = round((x + 21,25)/2,5)·2,5 − 21,25 (diş arası), z 60,6; merdiven ağzı (|x + 6| < 2,6) boş |
| merdiven | `_ladder_phase` (`:705-710`): ayak `galley.to_global((0; DECK; −9,4))`, tepe (ayak.x; **10,0**; 59,7); ayak x = `ROW_TO.x` −6 |
| `top_exit` | `ladder.gd:63-65`: tepeden 0,7 m geri + 0,1 → y ≈ 10,2 (yol 9,62: oyuncu 0,6 m düşüyordu) |
| `top_exit` çağrıları | `player.gd:833` (oyuncu çıkışı), `chapter38o.gd:628` tayfa aşması (`top_exit() − 0,1`), `:1029` 40 sn yedeği, `:1059` boru dönüşü (`_explore` `var top := ladder.top_exit()`), `:1918-1919` kare çekimi (`_run_shots`) |
| Horn devamı | `Horn.build(self, 62, …, gap (−24; 24))` → devamın dış yüzü **z 62** (bölüm kesiminin 60'ı değil): ±24'teki 2 m'lik basamak x ±21 kulelerinin (17,9…24,1) arkasında kalır |

## 5. HornWorld (`scripts/world/horn_world.gd`)

`HornWorld` her `World1453` dünyasında kurulur (`siege_field.gd:121`); `_horn_walls` (`:535`) Haliç kıyısı (HORN_S_X boyunca)
ve burun, `_marmara_walls` (`:667`) Marmara kıyısı; ikisi de `_wall_run` (`:451`): 40 m'lik (oynanış alanı yanında 8 m'lik)
parçalar, `Dressing.box` gövde (3 × (hh+3) × parça), iki kırmızı tuğla şerit kutusu, saçılmış kutu diş (`Scenery.scatter`),
44–60 m arayla 8 × 8 kutu kule + 4 kutu diş + kırmızı kutu tepe; `_wall_top` bölüm kesiminin (keep) 10–70 m yanında tepeyi
eski yüksekliğe (h) indirir. `flight_boxes` uçuş (WorldFlight) kaba kutuları. `keep` bölgenin oynanış dikdörtgenleri.

## 6. v2 (şehir) karşılıkları

| eski | v2 |
|---|---|
| SeaWalls / Haliç suru kesimi | `IstHalicSur` (`halic_sur.gd`): yalnız tam 96 m'lik Haliç hat dilimleri (`sehir.gd:2901-2903`); öteki Haliç dilimleri `IstMarmaraSur.build_run` (BU görevin dosyası değil) |
| ölçüler | `dims(1,0)`: L 96, H 9,0, T 3,0, TW 7, TD 7, TH 5; kuleler x ±0,44 L, ±0,15 L; ana kapı x 0 (3,0 × 3,4), yan kapı x −0,29 L (2,0 × 2,6); yürüme yolu 1,8 (iki korkuluk 0,5 + 0,5); rıhtım 5 m, üst 0,4, dip −1,6; kulelerde sur yolu koridoru (z ±0,9, 2,4 m) ve şehir yüzünden kule merdiveni |
| deniz surları gölgelendiricisi | `sur_doku.gd` tur 1 (deniz: kaba gri, moloz yaması, hatıl 3,4 m'de bir, dipte yosun 4 m'ye dek); şehir `_sur_tas` ile "ashlar" yüzeyleri çevirir |
| zincir | `halic_zincir` (`sehir.gd`), 4b'nin denge yolu kendi kütükleri (dokunulmadı) |
| çarpışma dökümü | `tasima11_halic_sonda`: 661 şekil, karma 3854034809 (eski = yeni, bkz. rapor) |
