# TAŞIMA 9 — BLAKHERNA: Bölüm 30 (Bizans) ve 30o (Osmanlı) yeni sur dilinde — rapor

Dal `wip/ist2-tasima9`, taban `wip/ist2-taban16` = **fa66841e**. ESKİ = aynı kod `--eskisur` ile (geri dönüş anahtarı: eski
set satır satır eski kod yolundan kurulur), YENİ = anahtarsız. Aynı makine, aynı kameralar; kareler xvfb + Mesa llvmpipe
(yazılımsal GL), 1280×720 jpg 85, hepsine TAM BOY bakıldı. Ekransız testler `--max-fps 20`, tam süzgeç.

Klasörler: `kare/30|30o/eski|yeni/` (tam boy), `pafta/` (sol ESKİ | sağ YENİ, yarım boy, yalnız göz gezdirmek için),
`testler/` (süzülmüş çıktılar; `bolum/` her koşu, `sonda.txt`, `sozlesme.txt`, `kare_*.txt`), `dokum.md` (madde 1).

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | ÖLÇ | **TAMAM** | `dokum.md`: eski setin 47 çarpışma şekli, sur yolu / rampa / zemin ışın ölçümü, 30 ve 30o'nun bütün bağları satır satır |
| 2 | Yeni Blakherna seti | **TAMAM** | Ortak kalem `scripts/world/ist/blak_set.gd` (şehir ve bölüm AYNI ressam), `Blachernae` yeni kip; çarpışma eskiyle birebir (saray hariç: şehirdeki sarayın kendi kutuları), `--eskisur` eski seti aynen kurar |
| 3 | 30 ve 30o bağları | **TAMAM** | Bütün bağlar aynı yerde (çarpışma ve ölçü aynı); düz zemin varsayan NPC/nesne yükseklikleri `Blachernae.zemin_y`'ye; süreler aynı (tablo) |
| 4 | Kare | **TAMAM** | 30 ve 30o: 6'şar ESKİ\|YENİ (açılış, sur yolu yakın, kule, merdiven, saray önü, gece genel) + 2'şer yakın mazgal; `=kare` çeşidi |
| 5 | Test | **TAMAM** | 30 (4 çeşit) ve 30o (4 çeşit) yeni ×3 + eski ×1: **32/32 PASS**, sorun satırı 0; `=yuru` yeni = eski; şehir bölümleri 5/5 PASS; sözleşme üçlüsü + eşya aynı |
| — | Bütçe | **TAMAM** | 16 kameranın hepsinde ilkel ≤ +%4,5, çizim çağrısı 14'ünde eskiden az (2'sinde +%3,8) |
| — | Sözleşme | **AYNI** | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` · `ESYATEST PASS` |

---

## 1. ÖLÇ — **TAMAM**
`dokum.md`. Ölçüm aracı `tests/_ist/tasima9_sonda.tscn` (başsız; `Blachernae`'yi eski ve yeni kipte aynı sahnede sırayla
kurar, çevre dünyası kurulmaz). Eski set: tek sur z 0…4,6, y 12; kuleler x ±20/±40 (8 × 17 × 8, surdan 5,6 m öne taşar);
köşe kuleleri x ±62; sur yolu yürünür parçaları (z 2,3 ve 3,6'da) −60…−44,5 · −35,5…−24,5 · **−15,5…15,5** · 24,5…35,5 ·
44,5…60, kuleler y 17; iç rampa (−14; 0; −6) → (−6; 12; −0,2) **≈ 50° eğim**; dış ve iç zemin düz y 0.

## 2. YENİ BLAKHERNA SETİ — **TAMAM**

**Yol (önerilen yolun bir adım ötesi):** `SurSet` kalıbı (Mesoteikhion'un ayrı oyun kesiti) yerine **Blachernae'nin kendi
çarpışma kutularını aynen tutup görünen ağlarını değiştirdim.** Gerekçe: Blakherna'da ölçü farkı yok (SUR_BOLUM_TASIMA §4.1);
kutular aynı kalınca 30/30o'nun 19 + 87 bağı ve `WallFight`/`WaveRunner`/`WallGuard`/`night_assault` yolları hiç değişmeden
doğru yere düşer, ayrı bir bağdaştırıcı gerekmez. Sonda: **çarpışma farkı 0** (`BLAKSONDA OZET eski_carp=47 yeni_carp=54
fark=0 saray_farki=11`, `testler/sonda.txt`); sur yolu, rampa ve zemin ışın ölçüleri eski = yeni satır satır.

| dosya | değişiklik |
|---|---|
| `scripts/world/ist/blak_set.gd` (yeni) | **Ortak Blakherna kalemi** (çarpışmasız): `sur()` gövde (gömülü temel + kaide + şevli dış yüz, sur taşı gölgelendiricisi: blok + tuğla hatıl) + kuleler (`KULE.ic_kule`) + sur dibi düşmüş taş; `korkuluk_dis()` korkuluk (TUR-11 ince taş örgü, köşe alfası 0,9) + `KULE.disler_ag` dişleri (taş örgü gövde, eşek sırtı harpuşta, 2 cm saçak: TUR-11/12/13), merdivenin çıktığı mazgalda korkuluk açılır (`mazgal_araligi`), bölümün başka merdivenlerinin dayandığı yerde diş kurulmaz; `merdiven()` iç taş merdiven (basamaklı, altı dolu taş kütle, son basamak sur gövdesine girer: havada değil); `zemin()` sur kuşağının zemin dili (`sur_gorunus._levha`: zemin_v2, kuru ot yamaları, sura doğru taş tozu, ot tutamları); `zemin_y()`; `birlestir()` (çizim bütçesi: malzeme × 32 m hücre birleştirme) |
| `scripts/world/ist/sehir.gd` | YALNIZ `_blakherna_wall`: görünüş kısmı `blak_set.sur(…, {"korkuluk": true})` çağrısına taşındı (aynı tohumlar, aynı sıra); tek fark korkuluğun ince taş örgüsü. **Şehir çarpışma dökümü tur 9 ile birebir** (`tests/_ist/tur9_blak.gd`, `testler/tur9_blak_sehir_carpisma.txt`, 17 kutu). `_make_blakherna` değişmedi |
| `scripts/level/blachernae.gd` | `bolum`, `eski_zorla`, `eski` (seçim `SurSet.eski_istendi(bolum)`: `--eskisur` ya da `--eskisur=30,30o`), `dissiz`. Yeni kipte: kabuğun katı kutuları yerinde, görünen kutu ağı gizli ve gövde `wall`/`ground` metası taşır (Unclip/düellocu düşüşü eskisi gibi); sur/kuleler/korkuluk/dişler/merdiven/zemin `blak_set` ile; saray **şehirdeki sarayın kendisi** (`sehir_eser.palace`, bir kez; şehirdeki gibi `gorsel_dil.uyumla` kuralından geçer); köşe kuleleri `ic_kule` (9 × 9, tepe 19); `night_assault`'ta aynı rng dizisiyle siper kutusu → pavez (`Assault.pavez_ag`, TUR-13), kırık merdiven kutusu → direk + basamak (`Dressing`), kule sancağı levhası → kumaş (`kumas.bayrak`). `zemin_y(x, z)` statik sorgu (eski kipte 0). Eski kip: her satır eskisi |
| `scripts/chapter30.gd`, `scripts/chapter30o.gd` | `walls.bolum`; 30'da `walls.dissiz = LADDERS`; NPC/nesne yükseklikleri `zemin_y` (tablo §3); `=kare`, `=yuru` çeşitleri (`_tasima9`); evre süresi satırı `T9SURE` (yalnız autotest) |
| `tests/_ist/tasima9_sonda.*`, `tasima9_bot.gd`, `tasima9_parca.*` (yeni) | ölçüm sondası (eski\|yeni çarpışma farkı, yol/rampa/zemin ışınları, üçgen sayısı), `=kare`/`=yuru` yardımcısı, parça parça kare tanısı |

**Kutu yok:** kutu kule, küp diş, düz tuğla şerit kutusu, havada eğik taş rampa, kutu siper, kutu kırık merdiven, levha
sancak yeni kipte kurulmuyor. Kalan kutular: oyuncunun görmediği çarpışma kutuları (gizli) ve şehirdeki sarayın kendi
kurucusunun parçaları (pencere pervazı, avlu duvarı: şehirde de aynı).

**Havada yok:** merdiven taş kütlesi zemine iner (0,3 m gömülü temel); sur gövdesinin temeli 1,6 m gömülü; kuleler kaideli;
merdiven ayakları, taşıyanlar, koşucular, okların düştüğü yer, çalılar, yaralı, pavezler görünen zemine (`zemin_y`) oturur.

## 3. 30 ve 30o bağları — **TAMAM**

Bağ tablosu (her satır): `dokum.md` §2. Özet:

| bağ | eski | yeni |
|---|---|---|
| sur yolu, `WALK_Y 12`, `WALL_Z0/Z1 0/4,6`, `TOWERS ±20/±40` | kabuk kutuları | **aynı kutular** (sonda fark 0) |
| 30 merdivenler `LADDERS −12, −4, 6, 14`, ayak z 8,19 | y 0 | aynı x/z; y `zemin_y` (±1,6 cm); o x'lerde diş yok (görünüş) |
| 30 koşucular (GunRange) | yol y 0 | aynı yol; `"ground": Blachernae.zemin_y` |
| 30 taşıma / kaldırma / tırmanış | CARRY_FROM 34, CARRY_T 5,5, RAISE_T 1,3, CLIMB_TIME 11, TILT 16° | aynı; taşıyan y `zemin_y` |
| 30 İmparator rampası | (−14; 0; −6) → (−6; 12; −0,2) | aynı (çarpışma rampası aynı; görünüş basamaklı taş merdiven) |
| 30o merdiven CLIMB_X 10, TILT 16° | — | aynı; mazgal aralığı 9,95…10,75'te korkuluk açık |
| 30o taşıma START (10; 0; 40) → PLANT (10; 0; 8) | y `slope_y` = 0 | oyuncu: aynı (çarpışma zemini); taşıyanlar, ok yeri: `zemin_y` |
| 30o tüfekçi kulesi TOWER_X 20, kule merdiveni | kule batı yüzü x 16, tepe 17 | aynı (yeni kule planı pahlı kare: batı yüzü z 2,2…9,75 düz; merdiven z 3,3'te yüze yaslı, kare `30o/yeni/an_02`) |
| 30o çalılar, yaralı, Zağanos, bozgun, Grant, atlayış | y 0 | `zemin_y` |
| `night_assault`, `build_guards`, `live_range`, `quiet_tower` | — | aynı (aynı rng dizisi; görünmez korkuluklar aynı) |

### Süre tablosu (oyun saati, autotest ölçeği; `T9SURE`; eski ×1, yeni ×1 aynı komut — ham: `testler/bolum/`)
| bölüm · çeşit · evre | eski (sn) | yeni (sn) |
|---|---|---|
| 30 · "" · tüfek (koşucular) | 16,17 | 16,13 |
| 30 · "" · merdivenler (taşıma + kaldırma + tırmanış + itme) | 11,22 | 11,29 |
| 30 · lose · merdivenler (iki merdiven tepeye varır) | 20,55 | 20,55 |
| 30 · "" · düello | 8,77 | 9,82 |
| 30o · "" · taşıma (START → PLANT) | 7,57 | 7,53 |
| 30o · "" · tırmanış (taş düşerken dur) | 14,68 | 14,40 |
| 30o · stonehit · tırmanış | 11,40 | 11,70 |
| 30o · "" · kule | 10,87 | 10,93 |
| 30o · "" · sur yolu dövüşü (WaveRunner ×2) | eski 7 koşu: 24,9 · 25,3 · 26,9 · 26,9 · 27,9 · 28,3 · 31,6 (ortanca **26,9**) | yeni 8 koşu: 20,8 · 24,4 · 25,4 · 27,8 · 27,9 · 28,5 · 30,4 · 31,2 (ortanca **27,9**) |

Dövüş süresi rastlantısal (botun vuruşları, düşmanın kenardan atılması). **Atılma:** yeni 17 koşunun 5'inde bir düşman dış
kenardan atıldı (x 7,2…8,8; z 4,1), eski 12 koşunun 1'inde (`e30o_a4`: x 7,9; z 4,0) — aynı yerde, iki sette de. Çarpışma
aynı ve gizli kutular "görünür katı" metası taşıdığı için bir mekanizma farkı bulamadım; oran farkı istatistik olarak
ayrılmıyor (Fisher p ≈ 0,2) ama **izlenmeli** (`testler/30o_dovus_atilma.txt`; "hâlâ kötü" 8).
Yürüyüş (`=yuru`): yeni = eski satır satır (§5).

## 4. KARE — **TAMAM** (her YENİ kareye tek cümle; sol ESKİ | sağ YENİ paftalar `pafta/`)

### Bölüm 30 (`kare/30/…`)
- **an_01 açılış** (oyuncunun doğduğu yer, ovaya): taş örgü dişler ve harpuştalar, korkuluk taş taş; ESKİ'nin tuğla bantlı küp
  dişleri yok — kutu yok, havada yok, korkuluğa oturuyor, Mesoteikhion'la aynı ressam, eskisinden sönük değil.
- **an_02 sur yolu yakın (1,5–6 m)**: korkuluk + harpuştalı dişler, kule pahlı ve şevli, tepe korkuluğunda dişler, sancak
  kumaş; ESKİ'nin düz kırmızı şeritli kutu kulesi gitti — kutu yok, havada yok; sur yolu döşemesi kiremit-kahve ve iri (kötü
  değil ama düz).
- **an_03 kule (2–9 m)**: kule `ic_kule` (silme, ok yarığı, yan kapı oyuğu) sur yolunun üstünde, korkuluğun ve dişlerin
  ardında — kutu yok, havada yok; kulenin yan kapısı karanlık ama çarpışma dolu (girilmez; eskide kapı yoktu: "hâlâ kötü").
- **an_04 merdiven/tırmanış (x 6, mazgaldan aşağı)**: dişi kurulmamış mazgalda tırmanan azabın başı korkuluğun ardında,
  korkuluk taş örgü; ESKİ'de kamera küp dişin içinde kalıyor, tırmanan görünmüyordu — kutu yok, havada yok.
- **an_05 saray önü**: şehirdeki Blakherna Sarayı (üç kat kemerli pencere, revak, kırma çatı, yan kuleler), görsel dil
  kuralından geçmiş (doygunluk tavanı, gri sütunlar), avlu sur kuşağının zemininde — kutu gövde yok, havada yok; "tekfur"
  baklava deseni şehirde de aynı (gece sönük değil, ışıklı pencereler okunuyor).
- **an_06 gece genel**: sur, altı kule ve köşe kuleleri tek ressam; saray şehirdekiyle aynı; ova sur kuşağının zemini
  (ESKİ: düz mavi-gri levha) — kutu yok, havada yok; sağda çevre dünyasının (World1453) eski kara suru kutuları sürüyor
  (kapsam dışı, "hâlâ kötü").
- **an_07 mazgal yakın 0,6 m** (sahibin ölçütü): diş 3 sıra taş örgü + eşek sırtı harpuşta + korkuluk taş sıraları — kutu
  değil; ama gece ay ışığında harpuştanın iki yüzü koyu ve pürüzsüz, yakından "kapak" gibi okunuyor (**kısmen**, ortak
  `disler_ag`; Mesoteikhion'da da aynı).
- **an_08 mazgal aralığından ova**: iki diş arası, harpuştalar; ova, pavezler, ordu — kutu yok, havada yok, iyi.

### Bölüm 30o (`kare/30o/…`)
- **an_01 açılış (START'tan sura)**: sur ve kuleler Mesoteikhion ressamı, ova sur kuşağının zemini, pavezler; ESKİ'nin
  kırmızı şeritli kutu kuleleri gitti — kutu yok, havada yok, merdivenler surun ayağında zemine oturuyor.
- **an_02 sur yolu yakın**: tüfekçi kulesine dayalı kule merdiveni pahlı kule yüzüne yaslı; korkuluk ve dişler taş örgü —
  kutu yok, havada yok.
- **an_03 kule (yerden)**: tüfekçi kulesi şevli, silmeli, tepesi dişli; merdivenler sura dayalı — kutu yok, havada yok.
- **an_04 merdiven (yerden)**: oyuncunun merdiveni (x 10) mazgala kadar, sur taşı blok + hatıl — kutu yok, havada yok,
  ayak zeminde.
- **an_05 saray önü (sur yolundan)**: şehirdeki saray, ön planda meşale — kutu yok, havada yok.
- **an_06 gece genel**: ESKİ ile aynı açı; yeni sur tek ressam, saray yeni — kutu yok, havada yok; sağda çevre dünyasının
  eski kara suru (kapsam dışı).
- **an_07 mazgal yakın 0,6 m**: harpuştalı diş, korkuluk taş örgü (ilk koşuda bu diş kayan nokta birikimiyle atılıyordu:
  düzeltildi, `blak_set._disler` 1 cm pay) — kutu değil; harpuşta koyu (kısmen, yukarıdaki gibi).
- **an_08 merdivenin açıldığı mazgal**: korkuluk mazgal aralığında açık, merdivenin tepesi aralıkta; iki yanda diş — iyi.

Tanı karesi `kare/tani_parca_hepsi.jpg` (parçalar tek başına, dünya yok): ilk YENİ kareler bütün sahne beyaz çıkmıştı
(birleştirmesiz sürüm, ≈ 470 ayrı ağ + yüzlerce saray kutusu); parçalar tek başına doğru çiziliyordu; birleştirmeden sonra
bölümde de temiz (bkz. "hâlâ kötü" 5).

## 5. TEST — **TAMAM**

### Bölüm koşuları (`testler/bolum/*.txt`; 4 süreç aynı anda, hepsi bitti; zaman aşımı 0)
| çeşit | yeni ×3 | eski ×1 (`--eskisur`) |
|---|---|---|
| 30 `""` | PASS ×3 (30.1, gun 3/4, pushed 2) | PASS |
| 30 `lose` | PASS ×3 (30.2, boarders 2) | PASS |
| 30 `bridge_ok` | PASS ×3 (rifle 5) | PASS |
| 30 `bridge_bad` | PASS ×3 (rifle 3) | PASS |
| 30o `""` | PASS ×3 (+4 ek + 1 son koşu) | PASS (+6 ek) |
| 30o `lose` | PASS ×3 (30O.2) | PASS |
| 30o `sprint` | PASS ×3 | PASS (+2 ek) |
| 30o `stonehit` | PASS ×3 | PASS |
Süzgeçteki sorun satırı (SCRIPT ERROR, VISAUDIT, WALKTHRU, HELDAUDIT, ARMAUDIT, WARN_FX/FLY/VOID, ESYAAUDIT dusme/havada/gomuk/
tikama/sinir, HAREKETAUDIT): **0** (bütün koşularda).

### `=yuru` (gerçek Player botu)
| bölüm | yeni | eski |
|---|---|---|
| 30: sur yolu doğu 13,5 m · batı 29,3 m · merdiven başı · rampa iniş 9,6 m | takılma 0, düşme 0 | aynı (satır satır) |
| 30: rampa çıkış | **takılma 1** (rampa ≈ 50°, oyuncu tırmanamaz) | **aynı (takılma 1)** — çarpışma rampası eskiyle aynı; oynanışta oyuncu rampayı kullanmaz (İmparator tween'le çıkar) |
| 30o: ova START → merdiven ayağı 30 m · sur yolu doğu/batı/geri 69,6 m | takılma 0, düşme 0 | aynı (satır satır) |

### Şehirde Blakherna (`grep -l 'Blachernae\|_make_blakherna' scripts/`: sehir.gd, horn_world.gd, chapter30*.gd …) — ×1
43o PASS (uçuş flown 1069) · 44b PASS · 10h PASS · 12b PASS · 8y PASS; sorun satırı 0. Şehir Blakherna çarpışma dökümü
(`tur9_blak.gd`): tur 9 ile birebir (17 kutu). Şehir kareleri: aşağıda "Şehir".

### Mesoteikhion sözleşme üçlüsü + eşya (`testler/sozlesme.txt`)
`SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0
dusme=0` · `ESYATEST PASS` — aynı.

## Bütçe (aynı kamera, 4 karenin ortalaması; `testler/kare_k_*.txt`)
| kamera | 30 çizim eski → yeni | 30 ilkel | 30o çizim eski → yeni | 30o ilkel |
|---|---|---|---|---|
| an_01 açılış | 2064 → 2024 (−%1,9) | 3 554 850 → 3 588 534 (+%0,9) | 3984 → 3972 (−%0,3) | 3 553 282 → 3 650 058 (+%2,7) |
| an_02 sur yolu yakın | 6086 → 6034 (−%0,9) | 7 930 412 → 7 963 518 (+%0,4) | 6040 → 5972 (−%1,1) | 7 858 518 → 7 897 332 (+%0,5) |
| an_03 kule | 5852 → 5782 (−%1,2) | 7 905 419 → 7 934 926 (+%0,4) | 2915 → 2878 (−%1,3) | 3 509 023 → 3 560 054 (+%1,5) |
| an_04 merdiven | 735 → 708 (−%3,7) | 1 127 196 → 1 171 945 (+%4,0) | 2063 → 2045 (−%0,9) | 3 111 152 → 3 118 924 (+%0,2) |
| an_05 saray önü | 1064 → 1104 (+%3,8) | 1 601 312 → 1 636 914 (+%2,2) | 968 → 1005 (+%3,8) | 1 306 488 → 1 364 972 (+%4,5) |
| an_06 gece genel | 2292 → 2266 (−%1,1) | 1 801 377 → 1 860 318 (+%3,3) | 3681 → 3645 (−%1,0) | 2 663 639 → 2 712 622 (+%1,8) |
| an_07 mazgal yakın | 1945 → 1908 (−%1,9) | 3 400 252 → 3 444 233 (+%1,3) | 3027 → 2978 (−%1,6) | 4 201 223 → 4 230 977 (+%0,7) |
| an_08 mazgal | 2475 → 2442 (−%1,3) | 4 590 894 → 4 644 305 (+%1,2) | 2836 → 2786 (−%1,8) | 4 226 106 → 4 268 195 (+%1,0) |

Nasıl: yeni ağlar malzeme × 32 m hücre birleştirildi (`blak_set.birlestir`: sur 25 ağ → hücre başına birkaç, saray 326 kutu →
malzeme başına bir ağ; eski set ≈ 470 ayrı ağ); sarayın 2 m'den küçük parçaları (pencere kemeri, sütun, diş, parmaklık) gölge
düşürmez (gece ay ışığında görünmüyordu; her gölge geçişinde çiziliyordu). Üçgen: Blakherna seti eski 19,6 bin → yeni 43,4 bin
(sonda `BLAKGOR`), gölge düşüren: sur 11,4 bin + saray 5,1 bin.

## Şehir (ortak kalemin şehirdeki görünüşü)
Tur 9'un Blakherna kameraları (`docs/_kanit_ist2_tur9/kam/blak.txt`, `tests/_ist/tur9_kare.tscn`; b4 gece hariç) bu dalın
koduyla: `kare/sehir/`. Karşılaştırma tur 9 SONRA kareleriyle (`docs/_kanit_ist2_tur9/sonra/blak/`; arada tur 10–13'ün
gölgelendirici düzeltmeleri de var, yalnız bu görevin farkı değil). Çarpışma: tur 9 dökümüyle birebir.
- **b3 Haliç ucundan** (Blakherna diliminin açıkta kaldığı yer): kaide ve şev aynı; taş blok kabartmalı, tuğla hatıl soluk ve
  ince (tur 9: düz krem levha üstünde parlak kırmızı şerit) — aynı ressam, **daha iyi**, kutu yok, havada yok.
- **b1 iç yüz**: görünen sur çoğunlukla kara surunun iç suru (aynı hat; tur 9 bulgusu), Blakherna dilimi aynı — **aynı**.
- **b2 saray yanı, h1, h2 havadan**: saray ve sur tur 9'daki gibi; korkuluk değişikliği bu uzaklıkta seçilmiyor — **aynı**.

## Sonraki taşıyana
1. **Ortak kalem:** `blak_set.sur(n, x0, x1, lod, {"tohum_L", "kuleler", "dip_tas", "korkuluk"})`, `korkuluk_dis(n, x0, x1, lod,
   tohum, kes, dissiz)`, `mazgal_araligi(x)`, `kule(n, g, lod)`, `merdiven(n, lo, hi, w, lod)`, `zemin(n, x0, x1, z0, z1, y,
   yuz_z, ad)`, `zemin_y(x, z)`, `birlestir(kök, ad, golge_esik)`. Şehirdeki dilim (`_blakherna_wall`) ve bölüm sahnesi aynı
   işlevleri çağırır: Blakherna'nın görünüşünü burada değiştirmek ikisini birden değiştirir.
2. **Bağlar sabit:** `Blachernae` çarpışma kutuları değişmedi; yeni bir bölüm Blakherna'yı kullanırsa eski sabitleri
   (`WALK_Y`, `WALL_Z0/Z1`, `TOWERS`) doğrudan kullanabilir. Zemin yüksekliği için `slope_y` değil **`zemin_y(x, z)`**
   (görünen yüz ±1,6 cm; oyuncu için çarpışma zemini y 0 kalır).
3. **Merdivenler ve mazgal:** oyuncunun çıktığı merdiven `build_guards(gaps)` ile verilir: görünmez korkulukta açıklık (eskisi
   gibi) + görünüşte mazgal aralığında korkuluk açılır. Oyuncunun çıkmadığı merdivenler `walls.dissiz` (add_child'dan önce):
   tepesi dişe değil korkuluğa yaslanır. Diş dizisi x = −59 + 1,9 k (eski kabukla aynı); kayan nokta birikimi için 1 cm pay.
4. **Gizli kutu = "görünür katı":** yeni kipte kabuğun kutuları gizli ama `wall`/`ground` metası taşır (Unclip.visible_body);
   metasız gizlerseniz düellocu surun içinden düşer (TAŞIMA-8 §26o'daki "atılma" kök nedeni).
5. **Bütçe:** birleştirme hücreli olmalı (tek 130 m'lik ağ her açıda bütün kuleleri ve gölge geçişlerini çiziyordu: ilkel +%9).
6. **Geri dönüş:** `--eskisur`, `--eskisur=30`, `--eskisur=30o` (bölüm adı `walls.bolum`).
7. **Rampa ≈ 50°:** iç taş rampa eskiden beri oyuncunun çıkamayacağı kadar dik (iniş olur). Oynanışta gerek yok; bir bölüm
   oyuncuyu buradan çıkaracaksa çarpışma rampası uzatılmalı (ölçü kararı: sahibin).

## Hâlâ kötü olanlar (dürüst)
1. **Harpuşta yakında (0,6 m) gece koyu ve pürüzsüz**: iki eğik yüz "kapak" gibi okunuyor (30 an_07, 30o an_07). Ortak
   `sur_kule.disler_ag` (Mesoteikhion'da da aynı; dosya bu görevde değiştirilemezdi).
2. **Kule yan kapıları**: `ic_kule` sur yolu hizasında yan yüzlerde karanlık kapı oyuğu çiziyor, ama Blakherna kulesinin
   çarpışması dolu kutu (eskisi gibi): kapıdan girilmiyor. Ya kapısız kule seçeneği (`sur_kule`, başka sahip) ya da kulede
   geçit (çarpışma değişir: sahibin kararı).
3. **Sur yolu döşemesi** (sur taşı gölgelendiricisinin üst yüzü) yakında kiremit-kahve, iri ve düz kesme taş gibi; Mesoteikhion
   yolundan sıcak.
4. **Çevre dünyası** (World1453 surround) x > 62'de eski kara suru kutularıyla sürüyor (30o an_06 sağ, 30 an_06 sol uzak);
   HornWorld'ün uzak Blakherna'sı (`horn_world._blachernae`, başka bölümlerde uzak görünüş) hâlâ eski `shell_parts` kutuları.
5. **Beyaz ekran (kök neden tam bulunamadı)**: birleştirmesiz ilk sürümde bölüm karelerinin hepsi beyazdı (gök hariç); parçalar
   tek başına (`tasima9_parca`) ve parçası kapalı bölüm koşularının dördü de temizdi; birleştirmeden sonra hiçbir karede
   görülmedi (16 + 16 kare, 3 tur). Yazılımsal GL'de yüzlerce ayrı malzeme/ağın derlenmesiyle ilgili olabilir (tahmin).
6. **Saray**: şehirdeki saray kurucusunun kendisi (pencere pervazı ve kat şeritleri `Props.box`; "tekfur" baklava deseni
   yakında dama gibi). Şehirde de aynı; `sehir_eser.gd` bu görevin dosyası değil.
7. **Yürüyüşte rampa çıkışı** takılma 1 (yeni = eski; madde "sonraki taşıyana" 7).
8. **30o sur yolu dövüşünde atılma oranı** yenide 5/17, eskide 1/12 koşu (aynı yer, mekanizma farkı bulunamadı; §3).

## Replik uyumsuzluğu
Yok. Bütün oynanış yerleri (merdivenler, kule, rampa, çalı, ateşler, saray yönü) eski koordinatlarında; "kule", "mazgal",
"merdiven", "meşaleler" replikleri yeni görünüşle de doğru.

## run_tests.sh isteği (EKLEMEDİM)
- `run --chapter=30 --autotest=yuru` ve `run --chapter=30o --autotest=yuru` (son satır `T9YURU OZET`; 30'da rampa çıkışı
  takılma 1 eskiden beri — süzgeç için `bacak=rampa_cik` hariç tutulmalı ya da bacak listeden çıkarılmalı).
- `godot --headless --path . res://tests/_ist/tasima9_sonda.tscn` → `BLAKSONDA OZET … fark=0` (Blakherna çarpışması eski = yeni).
- `godot --headless --path . -s res://tests/_ist/tur9_blak.gd` (şehir Blakherna çarpışma dökümü; tur 9'dan beri istekte).
- `=kare` çeşitleri (30, 30o) yalnız pencereli; pakete değil kanıt koşularına.
