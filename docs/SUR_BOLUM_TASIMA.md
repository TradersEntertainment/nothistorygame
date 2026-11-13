# Sur bölümlerinin İstanbul v2'ye taşınması — döküm ve yol haritası (ARA KAYIT: yalnız 1. madde)

> Durum: **ara kayıt**. Bu sürümde yalnız §1 (döküm tablosu) ve ölçüm yöntemi var; §2–§6 ve özet sonraki kayıtta.
> Kural: her iddia `dosya:satır` ya da sonda çıktısıyla kanıtlı; okunmayan/ölçülmeyen yer "ölçülmedi" ya da "tahmin" diye işaretli.
> Bu belge karar vermez; öneri ve etki yazar. Oyun kodu, sahne, test, replik DEĞİŞMEDİ.

## 0. Sur setleri (kısa kod; tabloda kullanılır)

| Kod | Set | Dosya / kurucu | Tarihî yer |
|---|---|---|---|
| **S1** | `LandWalls` (kara surları, Mesoteichion kesimi; ±50 m'lik tek dilim) | `scripts/level/land_walls.gd` — `LandWalls.new()` → `_ready` (`land_walls.gd:68-88`: `_build_ground/_inner/_outer/_breach/_depot/_field`) | Lykos vadisi, Mesoteichion (`land_walls.gd:3`) |
| **S1+** | S1'in üstüne bölüm yardımcıları: `Assault` (ova kalabalığı, 8 dekor merdiven, bataryalar), `Garrison.land_walls` (sur yolu askerleri), `WallFight` (yağ kazanı, taşıyıcı, onarım ekibi), `SiegeChaos` | `level/assault.gd`, `level/garrison.gd:57`, `level/wall_fight.gd`, `level/siege_chaos.gd` | S1 koordinatlarına sabit (ör. `assault.gd:430-436`) |
| **S2** | `Blachernae` (tek yüksek sur, hendeksiz, 120 m) | `scripts/level/blachernae.gd` — `Blachernae.new()` | Blakherna sarayı önü (`blachernae.gd:3-5`) |
| **S3** | `SeaWalls` (Haliç şehir yakası: rıhtım, zincir, 11 m deniz suru, küçük kapı) | `scripts/level/sea_walls.gd` — `SeaWalls.new()` | Haliç, şehir yakası (`sea_walls.gd:3`) |
| **S4** | Haliç suru parçası: `World1453.build(... "horn_bridge" / "horn_wall_o")` + bölümün kendi `_build_wall` (`chapter38o.gd:135`) | `chapter18b.gd:86`, `chapter38o.gd:116,135` | Haliç suru (`chapter38o.gd:3-4`) |
| **S5** | `ByzCity` "walls" hub'ı (iç sur, kuleler, Romanos Kapısı, kançılarya; 70 m'lik sur parçası) | `scripts/level/byz_city.gd:36-63,1545` — `ByzCity.new()` | Romanos Kapısı'nın iç yanı (`byz_city.gd:36`) |
| **S6** | `World1453` kara kapısı bölgesi (`LAND_GATES` x=37) + `SiegeField` | `chapter8y.gd:142`; `world/world1453.gd:125` | Kara suru, kapı (`chapter8y.gd:3`) |
| **V2** | **Yeni tek harita:** `IstSurlar` (k = `IstSehir.K_SUR` = 1.0, `sehir.gd:1289`), `IstSurKule`, `IstSurZemin`, `IstSehir` | `scripts/world/ist/surlar.gd`, `sur_kule.gd`, `sur_zemin.gd`, `sehir.gd` | Gerçek koordinatlı hat (`surlar.gd:819-845`) |

## 1. DÖKÜM — surda/sur dibinde/kapıda/hendekte/kulede geçen bölümler ve evreler

Okuma: **Yer** = tarihî yer + kod/replikteki kanıtı. **İş** = oyuncunun yaptığı. "—" = sur oynanışı yok, yalnız fon.
Sondalı sayılar §2/§3'te (henüz bu kayıtta yok); burada yalnız kodda yazılı ölçüler var.

### 1.1 Bizans yolu (Tolga surun içinde / üstünde)

| Bölüm · evre | Yer (kanıt) | Set · kurucu | Oyuncunun işi |
|---|---|---|---|
| **0** Soğuk açılış (29 Mayıs 01.30) | Mesoteichion gedik (`chapter0.gd:2`) | S1+ — `LandWalls.new` `chapter0.gd:50`, `Assault` :77, `Garrison.land_walls` :83, `WallFight` :84 | Ok demetini peribolostan gedikteki okçulara taşı (START (7;0,05;4) → LINE (−0,6;0;11,4), `chapter0.gd:15-19`), top uyarısı, donan kare |
| **4b** İlk Gece (22 Nisan gece) | Haliç deniz suru, kapı; zincir kütükleri (`chapter4.gd:12-14`) | S3 — `SeaWalls.new` `chapter4.gd:99` | Zincir kütüklerinde denge (CHAIN_START→END 32 m, `sea_walls.gd:14-15`), surdan atılanlardan kaç, rıhtım ucundaki kapıda fes kararı (GATE_X 17) |
| **6b** Surların İçi (23 Nisan) | Romanos Kapısı iç yanı, "sur yolu" (`chapter6.gd:10-11`; kapı `ByzCity.HALL_Z0` :285) | S5 — `ByzCity.new` `chapter6.gd:94` | Meydan–pazar–sur yolu boyunca martı kovalamaca; Misafir İzni; kapıdan çıkış |
| **7b** Saha Çalışması (Nihat) | Surlar, kapı izleri (`chapter7.gd:8`, iz `GIUST_POS` :259) | S5 + uçuş için V2 (**şimdiden bağlı**, `IstBaglama.TOLGA`, `baglama.gd:52-56`) | İz tarama (tarayıcı), Nihat uçuşu |
| **8y** Beyaz Havlu (25 Nisan şafak, yalnız 6b yolu) | Kara surunun dünya x=37 kapısı (`chapter8y.gd:3-4`) | S6 — `World1453.build` `chapter8y.gd:142` | İç sur kapısı → peribolos → dış sur kapısı (GATE_Z 13,85) → hendek köprüsü (BRIDGE_Z 21) → ölü bölge (FIELD_Z 37 … TRENCH_Z 103,5) → Osmanlı siperi; toplam z −10 … 137,5 ≈ 148 m yürüyüş (`chapter8y.gd:29-59`); süre yok |
| **10h** Heyet (25 Nisan) | Gedik ("topların surda açtığı yarık") + zincir nöbetçileri + kapı (`chapter10h.gd:11,102,152`) | S5 — `ByzCity.new` :50 | Gediği barikatla/koli bandıyla kapat, kapıdan beyaz bayrakla çık (`ByzCity.EXIT_POS`) |
| **12b** Son Akşam (26 Nisan gün batımı) | Sur yürüme yolu, iki kule arası; kuleye açılan kapı (`chapter12b.gd:62,76-87`) | S5 — `ByzCity.new` :43 | İmparator'la sur yolunda konuşma yürüyüşü; süreli "Yaptığın şey yetecek mi?" |
| **18b** Fıçı Köprü, surdan (Mayıs başı) | Haliç suru üstü (`chapter18b.gd:1-3`) | S4 — `World1453.build "horn_bridge"` :86; WALL_Z 62, WALK_Y 9,6 (:12-13) | Küçük Bizans topu (barut seçimi + GunDrill), geri tepme sur çatlatır; 11 bölüm × 3 m (SECTIONS/SEC_LEN :15-16) |
| **20** Gedik (7 Mayıs gece) | Mesoteichion (`chapter20.gd:1`) | S1+ — `LandWalls.new` :74, `Garrison.land_walls` :114, `WallFight` :117, `Assault` :136 | Depodan malzeme (DEPOT (11;0;2,2)) → gedik (BREACH (0;0;15)) taşı; ok sandığı (ARROWS (6,2;0;0,2)) → okçular (ARCHERS (−9;0;11)); top uyarısında siperin arkası; gece yarısı hücum (ASSAULT_AT 0,52) + gedik düellosu; tüfek (GunRange); **süre: NIGHT 170 sn** (:15) |
| **21** Lağım (16 Mayıs) | Mesoteichion peribolos + toprak altı (`chapter21.gd:1,10`) | S1 (yalnız peribolos) — `LandWalls.new` :88 | Peribolosta 4 su kabı (MINE (−9;0;7)); tünel (TUN (60;−30;0): sur dışı, yeraltı); tercüme |
| **22** Kule (18 Mayıs) | Dış sur tepesi, hendek, Mesoteichion (`chapter22.gd:1,5-6`) | S1+ — `LandWalls.new` :65, `Garrison` :133, `WallFight` :136, `SiegeTower.build` :163 | Dış surun tepesinde 3 fıçı (BARRELS (3,5;8;15)), oluk (CHUTE (−2,5;8;15,8)), fitil (FUSE_TIME 2,6; bant 0,42–0,68), kule hendeğin ötesinde TOWER (−3;0;40) |
| **25** Son Akşam, Bizans yarısı (27 Mayıs gece) | Kara surlarının yürüyüş yolu (`chapter25.gd:392-393`) | S1 — `LandWalls.new` :396, `Garrison` :399 | Dış sur yolunda (−9,2;8;14,9) nöbetçiyle konuş/izle; ordugâhın kandilleri |
| **26** Şafak (29 Mayıs) | Mesoteichion gedik + poterna + iç sur kapısı (`chapter26.gd:1-14,25`) | S1+ — `LandWalls.new` :80, `Assault` :151, `Garrison` :159, `WallFight` :161 | 1. dalga ok demeti taşı (WELL→okçular); kaynar yağ; **ışınlanıp** dış sur yolunda merdivenden çıkan azabı it/tekmele (`chapter26.gd:408-423`); 2. dalga barikat örme (top uyarısı); 3. dalga tüfekçi uyarısı, poterna fıçıları (BLOCKS (12,6;0;3,2),(14,6;0;2,2)), Giustiniani'yi taşı; sonra FallenCity/Ayasofya |
| **36b** Huruç (9 Nisan, şafaktan önce) | Mesoteichion'un önü; dış surun ova yüzünde gizli kapı (`chapter36b.gd:1-12,17`) | S1 — `LandWalls.new` :66, `Garrison` :164 | Poternadan (LANE_X −24) çık → kalas köprüyle hendek (BRIDGE_Y 1,6) → siperdeki kazıcılarla çarpış → 3 siper yak (TRENCH_Z 54) → davullar: dön; Leon'u taşı (RIDE_TIME 34, :25) |
| **42b** Talim (7 Nisan, Bizans) | Mesoteichion ardındaki meydan (`chapter42b.gd:1-5`) | S1 (sağlam, `intact` :63) — **fon** | Talim (PUSH_HOLD 0,8); sur yalnız arka plan/kadraj (YARD_AT (−16;0;−20)) |
| **23, 24, 13** | Hub'ın saray/Ayasofya parçaları | S5 — fon | — (sur oynanışı yok; tahmin: `ByzCity` fon surunu da gösterir) |

### 1.2 Osmanlı yolu (Tolga surun önünde / dışında)

| Bölüm · evre | Yer (kanıt) | Set · kurucu | Oyuncunun işi |
|---|---|---|---|
| **20o** Gedik (7 Mayıs gündüz) | Mesoteichion; Urban'ın topu (`chapter20o.gd:1-5`); top CANNON (9;1,5;118) (`land_walls.gd:23`) | S1+ — `LandWalls.new` :72, `Garrison` :119, `WallFight` :121 | Büyük topu doldur/nişan (CannonCrew+GunDrill), namluyu soğut (COOL_TIME 2,4 sn, 3 atış); gece yarısı: tüfekle mazgaldakilere, azaplarla gediğe (WaveRunner) |
| **21o** Lağım | Toprak altı | — (LandWalls kullanmaz; `chapter21o.gd` taramasında `LandWalls` yok) | Kaz/destek; sur dışı |
| **22o** Kule (17–19 Mayıs) | Hendeğin önü; sur dibi (`chapter22o.gd:1-8`) | S1+ — `LandWalls.new` :110, `Garrison` :192 | Hendeğe 3 sepet toprak, 3 deri, kule hendeğin kıyısında TOWER (−3;0;40); PILE (9;0;56), WATER (−11;0;52); ok yağmuru "Siper!" (VOLLEY_EVERY 22, WARN 3); kule yanarken merdivenden marangoz indir (FIRE_TIME 26) |
| **26o** Şafak (29 Mayıs) | Hendek kıyısı, dış sur merdiveni (`chapter26o.gd:1-6`) | S1+ — `LandWalls.new` :62 (hendek dolgusu `ditch_filled`), `Assault` :141, `WallFight` :87 | Saka: fıçıdan 3 bölüğe su (O_WATER (9;0;50)); merdiven yığınından (O_LADDERS (−11;0;51)) kıyıya 3 merdiven; **dış sura tırman** (CLIMB_X 9, TILT 8°); taş düşerken dur; sur yolunda 2+3 savunucu, tüfek; sancak (EDGE_Z 37,4) |
| **28o** İlk Atış (6, 11–12 Nisan) | Surların önü, Urban bataryası; sur sağlam (`chapter28o.gd:1-9`) | S1 (`intact` — sağlam dış sur) — `LandWalls.new` :92 | Kazık çak (4); Şahi kızağı HAUL_Z 124,5 → HAUL_TO x 9 çek (ritim, STEP 1,0 m, ROLLER_EVERY 4 sn); ilk atış (sağlam sura) |
| **32o** Son Gün (28 Mayıs) | Lykos vadisi, hendeğin önü (`chapter32o.gd:1-9`) | S1+ — `LandWalls.new` :117, `Assault` :232, `Garrison` :236 | Şafak yürüyüşü; hendeğe çalı demeti (BUNDLES 6, PILE (−9;0;54), EARTH (9;0;54), EDGE_Z 37,4; süre DITCH_TIME 240 sn); merdivene basamak çak (RUNGS 6); manto it (14;0;64 → 14;0;41); Ali bataryası 3 atış (FIRE_Z 92); akşam ateşleri; "Sükût" |
| **37o** İlk Hücum (18 Nisan gece) | Dış surun yıkılan yerindeki barikat (`chapter37o.gd:1-4`) | S1+ — `LandWalls.new` :111, `Assault` :164 | Batarya zili; hasır kalkan; **kalas köprü** (MARCH (−9;0;74→41,5), hendek EDGE_Z 37); barikatta 5 fıçıya kanca (BARRELS 5, STOCKADE_TIME 180 sn); geri sürükleme DRAG 39,5→68 |
| **41o** Talim (17 Nisan) | Ordugâh talim meydanı; ovanın ucunda surlar (`chapter41o.gd:1-6`) | S1 (fon, `field_keep` :74) | — (YARD_AT (−72;0;134)); sur yalnız görünüm |
| **31o** Cuma (30 Mayıs–1 Haziran) | Aziz Romanos iç kapısı (fetihten sonra), FallenCity (`chapter31o.gd:1-8`) | S1 — `LandWalls.new` :152, :1565 + `open_inner_gate` | Sur oynanışı **yok**: kapıdan şehre; ev/kiriş/iskele sahneleri FallenCity'de (tahmin: yalnız kapı ve sur dibi fon) |
| **30o** Blakherna (12 Mayıs gece) | Saray önündeki tek sur (`chapter30o.gd:1-3`) | S2 — `Blachernae.new` :85, `WallFight` :335 | Merdiveni ekiple sura taşı (START (10;0;40) → PLANT (10;0;8)); **sura tırman** (CLIMB_X 10, TILT 16°); sur yolunda dövüş (WaveRunner×2, kuleden tüfekçi TOWER_X 20); geri çekilme borusu: muhafızlar CHASE_SPEED 1,9 ile yürür, merdivenden panik inişi; yaralı azabı ateşlere taşı (SAFE_Z 34) |

### 1.3 İki tarafta ortak

| Bölüm · evre | Yer (kanıt) | Set · kurucu | Oyuncunun işi |
|---|---|---|---|
| **30** Blakherna (12 Mayıs gece, Bizans) | Saray önündeki surun yürüyüş yolu (`chapter30.gd:1`) | S2 — `Blachernae.new` :53 | Ovadan merdiven taşıyanlara tüfek (4 koşucu, LADDERS x = −12,−4,6,14; `chapter30.gd:14,128-139`); sura dayanan merdivenleri it (CLIMB_TIME 11 sn, TILT 16°, CARRY_FROM 34 m, CARRY_T 5,5 sn, RAISE_T 1,3 sn); sur yolu kılıç dövüşü; İmparator |
| **17** Kundak (28 Nisan gece) | Haliç, şehir yakası rıhtım (`chapter17.gd:1-6`) | S3 — `SeaWalls.new` :132 | Kayıkla Coco'yu kurtarma (RESCUE_TIME 40); rıhtımda Trevisano (QUAY_Y+0,05) |
| **17o** Kundak (Osmanlı) | Haliç kuzey kıyısı (Pınarlar) | `World1453.build "springs"` :142 — şehir surları **uzak fon** | Kıyı topu (CannonCrew) |
| **19, 19o** Brigantin/Devriye | Haliç ağzı, zincir | S3 — :70/:524, :70 | Gemi/kayık (sur fon) |
| **29, 29o** Zincirin Önü (20 Nisan) | Haliç ağzının dışı | S3 — `SeaWalls.new` :62, :61 + `SeaBattle` | Gemiler arası kanca kes/at (HOOKS 6…); sur yalnız arka plan |
| **38o** Haliç Surları (29 Mayıs) | Haliç suru; merdiven, rıhtım, deniz kapısı (`chapter38o.gd:1-8,18-30`) | S4 — `World1453.build "horn_wall_o"` :116 + yerel `_build_wall` :135, `WallFight` :177 | Fusta ile sura yanaş (ROW_BEATS 20), **merdiven tırman** (OilHazard; WALL_Z 62, WALK_Y 9,6), güvertede ateş (FIRE_TIME 10), rıhtım halat (QUAY (6;57,4;18×2,8), GATE_X 15) |

### 1.4 Sur temalı ama bu kapsamda OLMAYANLAR (kanıt: setleri ayrı)
`chapter1.gd`/`chapter2.gd` yalnız `Assault.arrow_mesh()` kullanır (ok meshi; `chapter1.gd:531`, `chapter2.gd:795`). `chapter33o` (Boğazkesen: Rumeli Hisarı iskelesi, sur değil), `chapter39o` (Petrion mahallesi), `chapter27`/`10g`/`43o` (Galata: Ceneviz kasabası surları, Theodosius hattı değil), `arena.gd` (test arenası, `LandWalls` kullanır; `arena.gd:55`) — taşıma sırasında **S1 silinirse arena de kırılır** (`run_tests.sh` arena koşuları).

*(Ara kayıt sonu — sonraki kayıtta §2–§6, özet ve sonda çıktıları.)*
