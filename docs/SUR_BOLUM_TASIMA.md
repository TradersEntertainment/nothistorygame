# Sur bölümlerinin İstanbul v2'ye taşınması — döküm ve yol haritası

> Dal: `wip/ist2-sur-bolum-dokumu` (taban: `wip/ist2-tur6`). Tür: **araştırma ve döküm**; oyun kodu, sahne, test, replik DEĞİŞMEDİ.
> Kural: her iddia `dosya:satır` ya da sonda çıktısıyla; ölçmediğim yer **"ölçülmedi"**, tahmin **"tahmin"**. Sonda sayıları `docs/_kanit_sur_dokum/` içinde.
> Bu belge **karar vermez**: denge, süre, zorluk oyun sahibinin; burada öneri ve etki var (§6).

## ÖZET (bir sayfa)

**Kapsam.** `scripts/chapter*.gd` taraması: **36 bölüm dosyası** surla/kıyıyla ilgili — **22'sinde asıl sur oynanışı** (sur yolu, sur dibi, gedik, hendek, kapı: 0, 4b, 6b, 8y, 10h, 12b, 18b, 20, 20o, 21, 22, 22o, 25(Bizans yarısı), 26, 26o, 28o, 30, 30o, 32o, 36b, 37o, 38o), **5'inde kıyı/zincir** (17, 19, 19o, 29, 29o), **9'unda yalnız fon** (7b, 13, 23, 24, 21o, 31o, 41o, 42b, 17o). Bölüm içi evre sayısı **≈82** (başlıklardaki numaralı adımlardan; tahmin). Döküm: §1.

**Kaç ayrı eski sur seti?** 6: `LandWalls` (Mesoteichion; **16 bölüm**, + `Assault`/`Garrison`/`WallFight`/`SiegeChaos` yardımcıları), `Blachernae` (2), `SeaWalls` (6), `ByzCity` hub'ı (4 asıl + 3 fon), Haliç suru parçası (18b, 38o; bölümün kendi kodu), 8y kapı bölgesi. Yeni harita tek kurucu: `IstSurlar` (`K_SUR = 1,0`). Bölümlerin eski setlere **doğrudan sabit bağlantısı**: 20 → 63, 26 → 61, 30o → 87, 37o → 25, 26o → 23 (`grep`, §4).

**En büyük üç fark (ölçülü).**
1. **Hendek ve sur→ova çizgisi:** 16 m × 2,9 m derin, sur dibinden 4 m → **20 m × 6 m derin, 10 m teras**; ovanın başladığı çizgi 36 → **50 m** (+14 m). Hendek geçişi 8,7 sn → **46 sn** (iki rampa dilimin zıt uçlarında); gedik molozu hendeğe inmiyor; hendek **dolgusu, yürünür köprü, poterna v2'de yok** (22o, 26o, 32o, 36b, 37o, 8y bunlara dayanıyor).
2. **Dış sur:** kule aralığı 32 m → **≈55–61 m**, kule yürüme yolunu keser (1,8 m geçit); gedik sayısı **1 → 3**, 10 aşamalı onarım yok; hücum merdiveni dik el merdiveni ↔ yürünür taş merdiven (8,5 m'ye 4,1 sn; eski ladder 3,8 sn).
3. **Zemin ve arayüz:** eski setler düz y=0; v2 gerçek arazi (Mesoteikhion/Romanos/Pege düz ✓; Kharisios, Altın Kapı, Kerkoporta 9–16 m düşüş). V2 sur **yürünür** (iç sur yolu 4,1 m eninde, 110/190 m'lik dilimde uçtan uca yürüdüm: 104,5 / 184,5 m) ama sorgulanabilir **oynanış arayüzü yok** (yürüme yolu, dayama noktası, mazgal, top yuvası, poterna, köprü; §3.3).

**Sürpriz bulgular.** (a) V2'nin Blakherna suru **eski `Blachernae` kabuğunun kendisi** (`sehir.gd:2915-2933`) → 30/30o'da ölçü farkı ≈ 0. (b) Otomatik testlerin botları sura **yürümüyor**, etkileşimi çağırıyor/ışınlıyor (`chapter20.gd:754-787`, `chapter22.gd:509-535`, `chapter26.gd:408-423`) → mesafe değişimi testi kırmaz, **sabit koordinatlar kırar**. (c) İstenen `scripts/npc/climb_anim.gd` bu dalda yok (tırmanma pozları `rig.gd:83-84`). (d) Sur dibi etek çarpışmasında merdivene girişte takılma şüphesi (§3.4).

**Önerilen ilk üç taşıma.** (1) **30 + 30o Blakherna** (v2 zaten aynı kabuk, hendek yok); (2) **28o (+ 41o, 42b, 31o fon)** — sur sağlam/fon, Mesoteikhion ovasını sınar; (3) **20 + 20o gedik çifti** — Mesoteikhion çekirdeğinin başlangıcı (onarım aşamaları ve gedik→hendek yolu burada çözülür). **En sona:** 26 + 26o. Mesoteikhion kesimini paylaşan 15 bölüm **tek sahne** olabilir (§5.2).

**Taşımadan önce dondurulacak:** `IstSurlar.dims()` + `K_SUR`, kule yerleşimi (`_layout`: L/seed/S=55), kapı ölçüleri (`OPTS`), gedik yerleri/`GEDIK_W`, merdiven konumları, arazi (`IstGeo`) (§5.1).

**Sahibine 14 karar** (süre–mesafe, merdiven türü, gedik sayısı, hendek derinliği, poterna, 26'nın iç kapısı…): §6.

---

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
Sondalı sayılar §2/§3'te; burada yalnız kodda yazılı ölçüler var.

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

## 2. ESKİ SETLERİN VARSAYIMLARI (ölçerek)

Yöntem: sayılar önce kodda sabit olarak okundu (dosya:satır), sonra **başsız sonda** (`~/is/probe_*.gd`, kopyaları `docs/_kanit_sur_dokum/probe_*.gd.txt`) gerçek kurucuyla set kurup fizik ışınıyla (yürüme yolu), gerçek `Player` botuyla (süre) ölçüldü. Ham çıktı: `docs/_kanit_sur_dokum/eski_olcum.txt`, `yuru_olcum.txt`. Bot `WALK` 3,2 m/sn, `RUN` 5,2 m/sn (`player.gd:11-12`), merdivende 2,2 m/sn (`player.gd:651`).

### 2.1 S1 — `LandWalls` (Mesoteichion; 16 bölüm)

| Ölçü | Değer | Kanıt |
|---|---|---|
| Set boyu | x −50…+50 = **100 m** (Assault kalabalığı `wall_len` 150) | `land_walls.gd:281,345` (`len = 50 − …`), `assault.gd:15` |
| İç sur | yükseklik **12**, kalınlık **3,4** (z −4…−0,6), mazgal aralığı 2,0 m; kule x=±24 (**aralık 48 m**), 9 × 18 yüksek × 8,2 | `land_walls.gd:9-13,277-292` |
| İç sur üstü | ışınla 81,5 m "yol" (y=12), kuleler dolu (iç sürekli değil); **oyuncu çıkmaz** (iç sura merdiven yok; yalnız Garrison askeri) | sonda `ISTOLD landwalls_*_ic_sur_ust`; `chapter26.gd:159` |
| İç kapı | 4,8 × 6,4 (yalnız 26/31o'da `open_inner_gate`) | `land_walls.gd:31-32,304` |
| Peribolos | z −0,6…14 = **14,6 m**, düz y=0; x=±32'de ara duvar, geçit z 5…8,6 | `land_walls.gd:173-176,230-239` |
| Dış sur | z 14…16 (**2,0 m kalın**), **8 m** yüksek; mazgal aralığı **1,8 m**; sur yolu kullanılabilir en ≈ **1,45 m** (iç kenar korkuluk z 14,0–14,3, dış görünmez korkuluk z 15,75–16,05) | `land_walls.gd:14-17,346-369` |
| Sur yolu uzunluğu | sağlam: **100 m kesintisiz**; gedikli: 100 − 8 m (x −4…4 "alçak": moloz) | sonda `landwalls_saglam`: `yol[-50..50]`; `landwalls_yikik`: `alcak[-4..4]` |
| Dış kule | x=±16 (**aralık 32 m**), 5×5, tepe y=11 (OUTER_H+3); yürüme yolunun ARKASINA (z 16,1–21,1) taşar → yolu kesmez | `land_walls.gd:374-378`, sonda dış sur `engel` boş |
| Merdivenler | peribolostan dış sura **dik el merdiveni** (`Ladder`, 8,6 m, 12° arkaya) x=±8; hücum merdivenleri 9 m/16° (ch26), 8,6 m/8° (ch26o `chapter26o.gd:183-184`) | `land_walls.gd:380-384`, `chapter26.gd:141-143` |
| Merdiven tırmanma süresi | 8,4 m'ye **3,8 sn** (yürüyerek, bot) | sonda `eski_dis_sur_merdiven_x8` |
| Hendek | korkuluk z=19,2; hendek **z 20…36 = 16 m geniş**, dip üstü **−2,9 (2,9 m derin)**, iki yüzü 3 m taş duvar; kıyı rampaları x=±38…47 (9 m, 3,2 m geniş) **yalnız set uçlarında**; dolu (26o) varyant dip −1,5 + 10×16 m toprak set | `land_walls.gd:19-26,184-232,245-275` |
| Hendek geçiş süresi | rampadan dibe-karşıya-yukarı **8,7 sn** (27,7 m) | sonda `eski_hendek_gecis` |
| Dış sur yolu yürüyüşü | merdiven başından (x=8) x=47'ye **39,2 m / 12,3 sn**; batıya yürürken gediğin ağzında yol biter (moloz y=2,3, sur 8 m): **gedik sur yolunu ikiye böler** | sonda `eski_dis_sur_yol_*` |
| Sur→ova | dış sur dışı z=16, hendek karşı yakası z=36, ova z>36; **sur ile hendek ağzı arası 4 m** | yukarıdaki satırlar |
| Gedik | x=0, 7 m (+2×3 kırık kenar), moloz tepesi 2,275 m, hendeğe moloz dili z 19,6–25,5; **10 aşamalı onarım** (`set_repair`, STAGES 10) | `land_walls.gd:10-12,28-30,1054` |
| Zemin | tümü **düz y=0**; arazi eğimi yok | `_build_ground` |
| Depodan gediğe | DEPOT (11;2,2) → BREACH (0;15) = **16,9 m**; botla 15,8 m / 4,7 sn | `land_walls.gd:21`; sonda `eski_depo_gedik` |

**Bölümlerin sete bağladığı sayılar (hepsi S1 koordinatına sabit — v2'de elle taşınacak):** ARCHERS (−9;11), ARROWS (6,2;0,2) `chapter20.gd:17-18`; CHUTE (−2,5;8;15,8), BARRELS (3,5;8;15), TOWER (−3;0;40) `chapter22.gd:18-21`; PILE (9;0;56), WATER (−11;0;52), HIDE_PILE (−7,6;0;41) `chapter22o.gd:19-24`; POSTERN (DEPOT.x+3,5; INNER_Z1+0,6), BLOCKS, BANNER_TOWER (16;11;17), ladder x'leri [−10,5; 9,5; −24; 22; 28] `chapter26.gd:24-28,141`; EDGE_Z 37,4 (hendek karşı yakası) `chapter26o.gd:11`, `chapter32o.gd:24`; MARCH 74→41,5, DRAG 39,5→68 `chapter37o.gd:18-27`; POSTERN LANE_X −24, TRENCH_Z 54 `chapter36b.gd:16-23`; HAUL_Z 124,5 `chapter28o.gd:24`; ok demeti START/LINE `chapter0.gd:15-19`. `Assault` merdiven ayağı z=18,35, tepe (y 7,7; z 16,25), bataryalar z≈92–94, ordu z 36+ (`assault.gd:430-436`, `:19`). `Garrison.land_walls` kule boşluğu listeleri (örn. `[-10.4,-6.8], [6.8,10.4]`) ve `SiegeChaos.area` (Rect2(−44;1,4;88;10,6)) `chapter26.gd:159,186`.

**Süreli evreler ve mesafe bağı:** `ch20` NIGHT **170 sn** (`chapter20.gd:15`); 10 yük × (depo↔gedik gidiş-dönüş 33,8 m) yürüyerek ≈ **106 sn** (hesap: 33,8 / 3,2 × 10), koşarak ≈ 65 sn → mesafe doğrudan süreye bağlı (kırılma: depo–gedik arası tek yön ≈ **27 m'yi** geçerse yürüyen oyuncu 170 sn'ye sığmaz; hesap, yük bırakma/alma süreleri hariç → tahmin). Diğerleri mesafeden bağımsız sabit sürelerdir: fitil 2,6 sn, bant 0,42–0,68 (`chapter22.gd:22-24`); top soğutma 2,4 sn (`chapter20o.gd:20`); ok yaylımı her 22/20/13 sn, uyarı 3/4/2,6 sn (`chapter22o.gd:27-28`, `chapter26o.gd:16-17`, `chapter32o.gd:26-27`); hendek doldurma 240 sn (`chapter32o.gd:28`); barikat 180 sn (`chapter37o.gd:25`); at süvari 34 sn (`chapter36b.gd:25`). Yürüme/merdiven süresi oyuncu hızına bağlı olanlar: merdiven (3,8 sn), hendek geçişi (8,7 sn).

**Bot yolu:** otomatik testler yürümez; etkileşimi doğrudan çağırır ya da ışınlar: `chapter20.gd:754-787` (`_pick/_deliver/_on_interact`), `chapter22.gd:509-535` (`_take/_light/_release`), `chapter26.gd:408-423` (oyuncu sur yoluna **ışınlanır**: `lad.position.x − 1,9; OUTER_H+0,05; 14,95`), `chapter30.gd:43-44,594-606`. Yani mesafe değişimi botu kırmaz; **sabit koordinatlar** ve etkileşim alanları kırar. (`ch8y`, `ch36b`, `ch37o`, `ch32o` botları satır satır okunmadı: ölçülmedi.)

### 2.2 S2 — `Blachernae` (2 bölüm)

| Ölçü | Değer | Kanıt |
|---|---|---|
| Tek sur | z 0…4,6 (**4,6 m kalın**), **12 m** yüksek (WALK_Y 12), x −60…60 = **120 m**; hendek YOK, çifte sur YOK | `blachernae.gd:15-19,3-5` |
| Kule | x=−40,−20,20,40 (**20 m aralık**, orta 40 m boş) | `blachernae.gd:21` |
| Sur yolu | ışınla 86,5 m "yol"; kuleler dolu: kesintisiz parçalar 15,5 + 11 + **31** + 11 + 15,5 m | sonda `blachernae sur_yolu` |
| Oynanan kısım | LADDERS x = −12, −4, 6, 14 (31 m'lik orta parça içinde); ch30o CLIMB_X 10 | `chapter30.gd:14`, `chapter30o.gd:19` |
| Merdiven | `Ladder(WALK+0,6 = 12,6 m; 16°)`; taşıma: ovadan **34 m**, 5,5 sn, kaldırma 1,3 sn; tırmanma **11 sn** | `chapter30.gd:15,17,260-262,280-282` |
| İç merdiven | taş rampa (−14;0;−6)→(−6;12;−0,2), 2,4 m geniş | `blachernae.gd:84` |
| Zemin | dış zemin **düz y=0** ("hücum kalabalığı ve merdiven ayakları düz zemine göre") | `blachernae.gd:37-40` |
| Tüfekçi kulesi / ova | ch30o TOWER_X 20, BUSH, SAFE_Z 34; ovada koşucular z 46 → WALL_Z1+3 | `chapter30o.gd:21-26`, `chapter30.gd:134` |

### 2.3 S3 — `SeaWalls` (Haliç şehir yakası; 4b, 17, 19, 19o, 29, 29o)
Sur ön yüzü z=−3,2, yükseklik **11**, rıhtım y=0,7 (x −5…20; sondada yürünür parça x −2,5…20 = **22,5 m**), küçük kapı x=17, zincir 32 m (z 34→2) (`sea_walls.gd:10-20`, sonda `seawalls rihtim`). Bölümler yalnız rıhtım/zincir üzerinde: `chapter4.gd:625-667`, `chapter17.gd:889`. Sur tırmanılmaz.

### 2.4 S4 — Haliç suru (18b, 38o)
`WALL_Z 62`, `WALK_Y 9,6` (`chapter18b.gd:12-13`, `chapter38o.gd:18-19`); 18b: 11 bölüm × 3 m top yuvası (`:15-16`), 38o: kapı yarı genişliği 1,6, yüksekliği 4,2, rıhtım y=1,2 (6;57,4;18×2,8) (`chapter38o.gd:25-30`). Sayılar bölümün kendi dosyasındadır, ortak bir set sınıfı yok. Ayrıntılı ölçüm yapılmadı (başsız sondada `World1453` bölgesi kurulmadı): **ölçülmedi**.

### 2.5 S5 — ByzCity hub'ı (6b, 7b, 10h, 12b)
İç sur: 3 m kalın, **12 m** yüksek, 70 m'lik parça, yürüme yolu yok (dolu gövde); kule 6×6×16, **16 m aralık** (z −34,−18,−2,14); mazgal 1,6 m aralık; Romanos kapısı iç surda 7,4 m'lik açıklık (`byz_city.gd:1549-1590`). Oyuncu yalnız yer seviyesinde ve 12b'de bölümün kendi kurduğu sur yolunda (`chapter12b.gd:76-130`) bulunur. **Bu hub bugün IstBaglama ile v2'ye "yama" olarak gömülü** (`TOLGA_ACIK = ["12b","10h"]`, `baglama.gd:53-56`; 6, 23, 24 deneme bayrağıyla). Sondayla ölçülmedi.

### 2.6 S6 — 8y kapı bölgesi
Bölgenin yerel x 0'ı kapı ortası; iç sur kapısı z≈0, dış sur kapısı GATE_Z 13,85, hendek köprüsü BRIDGE_Z 21, saha FIELD_Z 37, hendek siperi TRENCH_Z 103,5, bitiş 137,5; koridor yarı genişliği 13,8 (`chapter8y.gd:29-59`). Süre yok, mesafe ≈ 148 m. Sondayla ölçülmedi.

---

## 3. YENİ SURUN (V2) SUNDUKLARI (ölçerek)

Kurucu: `IstSurlar._run(host, L, K_SUR = 1.0, lod 0, tohum, seçenekler)` (şehirde 30–110 m'lik dilimler: `sehir.gd:1289,1412`); sonda tam bu kurucuyla çağırdı (`probe_v2.gd.txt`). **Sınırlar:** düz zemin plakası yok (arazi `IstGeo.h` şehirden gelir; sondada yalnız surun kendi katıları), ışın ölçümü yalnız çarpışması olan yüzeyleri görür; dilim "sur" 110 m, "mesoteikhion" 190 m (+3 gedik), kapılar 150 m.

### 3.1 Kesit (yerel: x sur boyunca, +z dış yüz, z=0 iç sur ortası — `surlar.gd:4-8`; eski setle AYNI eksen kuralı)

| Ölçü | V2 | S1 (eski) | Fark | Kanıt |
|---|---|---|---|---|
| İç sur yükseklik / kalınlık | **12 / 5,0** | 12 / 3,4 | y 0, kalınlık +1,6 | `surlar.gd:50-56`, sonda `dims` |
| İç sur yürüme yolu | **4,1 m** (parapet 0,45×2), 110 m dilimde uçtan uca yürünür (104,5 m, kuleler dâhil) | oyuncu çıkmaz | yeni oynanabilir şerit | sonda `yol_eni_ic`; `v2_sur_ic_*` yürüyüş |
| İç kule | 9 geniş, çıkıntı 6, tepe **19**; **aralık 53–61 m**; geçit **2,2×3,0** | 9×18, aralık 48 | ≈ aynı | `surlar.gd:50-60`; rapor `_kanit_ist2_sehir3/rapor.md:106-109` |
| Peribolos | **15,0** | 14,6 | +0,4 | `dims PW` |
| Dış sur yükseklik / kalınlık | **8,5 / 2,6** | 8 / 2 | +0,5 / +0,6 | `dims OH, OT` |
| Dış sur yürüme yolu | **1,7 m** (zo0 parapet 17,5–17,95; zo1 parapet 19,65–20,1), 110 m'de uçtan uca yürünür (104 m) | 1,45 m, 100 m | +0,25 m | sonda `yol_eni_ic: dis` |
| Dış kule | 4,5 geniş, çıkıntı 4, tepe **13**; yürüme yolunu **keser** (içinden 1,8 m geçit) veya basamakla aşılır; **aralık ≈ 55–61 m** (dilimde 1–2 kule) | ±16, 32 m aralık, yolun dışında | aralık +23…29 m, yol kesintili | `surlar.gd:355-372`; sonda `dis_kule_x` |
| Mazgal aralığı | 1,8 m (parapet 1,2 + diş 0,6) | 1,8 / 2,0 | ≈ aynı | `surlar.gd:296-301` |
| İç sura merdiven | taş merdiven, **12 m yükseklik, 24,2 m uzun**, 47 basamak (0,26 / 0,42), 1,8 m geniş, şehir yakasından; yürüyerek **5,6 sn** | yok | yeni | sonda `climb`, `ISTWALK` |
| Dış sura merdiven | taş merdiven, peribolostan **8,5 m / 17,2 m uzun**, 1,8 m geniş, **4,1 sn**; kule tepesine ek merdiven (4,5 m) | dik el merdiveni 8,6 m, 3,8 sn | tür farkı (yürünür ↔ W-tırmanma) | sonda; `ISTWALK` |
| Hendek | **20 geniş, 6 derin**; sur→hendek ağzı **teras 10 m** (eski 4); hendek z 30,1…50,1; parateikhion alçak sur 1,6 m; kıyı rampası **16,5 m, ≈21°**, dilimin iki ucunda (x≈±0,32 L) | 16 / 2,9; z 20…36; rampa 9 m | +4 m geniş, +3,1 m derin, **sur→ova çizgisi 36 → 50 m (+14)** | `surlar.gd:74-75,624-660`; sonda `enkesit` |
| Hendek geçişi | **143,6 m, 46 sn** yürüyüş (dibe 4,8 sn, dipte ≈100 m boyuna, karşı rampa) çünkü iki rampa dilimin ZIT uçlarında | 8,7 sn (27,7 m) | ×5 uzun | sonda `v2_sur_hendek_gecis` |
| Kapı | Romanos 5,0 × 4,6; Pege 4,2 × 4,2; Altın Kapı 6,4 × 5,2 (mermer, kapalı); kapı önü hendek köprüsü **yıkık (yalnız görünüm)** | iç kapı 4,8 × 6,4 | küçük fark | `surlar.gd:933-945`, `:650-660` |
| Gedik | **8 m**, beden 0,8 m'ye yıkık, moloz tümseği, stauroma; Mesoteikhion'da **3 gedik** (Romanos'a en yakın noktadan güneye 110 / 215 / 330 m); onarım **aşaması yok** | 7 m (+kenar), 10 onarım aşaması | gedik sayısı 1→3 | `surlar.gd:41,733`; `sehir.gd:2820-2850` |
| Zemin | **gerçek arazi** (aşağıda) | düz y=0 | büyük | `sehir.gd:2857-2870` |

Dikkat — v2 "oyun" kesimi **tek bir 110/190 m'lik dilim değil**, hat boyunca 30–110 m'lik dilimlerin birleşimidir (kule/köşe kulesi birleşme kuralları `sehir.gd:2534-2560,3009-3050`); sondadaki sayılar tek dilim içindir, dilim birleşiminde kule aralığı ve `walk` yüksekliği (arazi) dilimden dilime ±0,35 m'ye kadar değişir ve aralarda 0,3 m'lik basamak kuruluyor (`sehir.gd:2950-3000`).

### 3.2 Arazi (gerçek `IstGeo.h`, sur dikeyi boyunca; sonda `probe_arazi.gd` — yön işareti kesim `yon_derece`'den türetilmiştir, **yaklaşık**)

| Kesim | −20…+20 m (sur gövdesi çevresi) | +30…+60 (hendek–ova) | Yorum |
|---|---|---|---|
| Mesoteikhion | 13,9 → 9,9 → 9,8 | 10,0 → 10,5 | gövde çevresi ≈ düz (±0,3), dış ova düz |
| Romanos | 9,4 → 9,9 | 10,0 → 10,3 | düz |
| Pege | 10,2 → 10,7 | 10,9 → 11,3 | düz |
| Kharisios | 24,5 → 8,3 | 6,0 → 5,8 | **~16 m düşüş**, dik yamaç |
| Altın Kapı | 16,3 → 10,6 | 7,4 → 6,3 | **~9 m düşüş** |
| Kerkoporta | 23,8 → 12,4 | 7,7 → 6,6 | **~11 m düşüş** |

Sonuç: eski bölümlerin hepsi "düz ova" varsayar; **Mesoteikhion / Romanos / Pege kesimleri bu varsayımı karşılıyor, Kharisios–Kerkoporta–Altın Kapı karşılamıyor.** Blakherna kesiminin arazisi doğrudan ölçülemedi (sonda koşmadı): `blakherna_suru` hattındaki Kerkoporta (`sehir.gd:1405`) yaklaşık vekil — dışarıya 11–16 m düşüş.

### 3.3 V2'nin bugünkü "oynanış arayüzü" — var olanlar / EKSİKLER

Var: (1) uçuş konma noktaları `IstSurlar._perches` (kule tepeleri, iç/dış sur; uçuş bölümleri `pw.add_perches`, `chapter7.gd:101-105`) ve taş merdiven uç çiftleri `_climbs` (`surlar.gd:881-931`; oyun betiklerinde tüketicisi **bulunamadı**, `grep`: yalnız tanımlar ve önizleme/test); ayrıca oyuncuda serbest tırmanma kipi `Player.enable_climb([Rect2…])` var (10g, 31o kullanır: `chapter10g.gd:106`, `chapter31o.gd:205,956`) — v2 dış sur için tırmanma sınırı verilebilir ama dayalı merdivenden bağımsızdır; (2) yürüme yolu çarpışması gerçek ve yürünür (aşağıda); (3) `IstSehir.oyun_alanlari()` / `hub_xf()` (yalnız hub ve Ayasofya meydanı) ve `IstBaglama.YAMA/TEMIZ` bölge sözlüğü — bölge ekleme mekanizması (`baglama.gd:40-48`); (4) `IstSurlar.gedik_dunya` (kurulan gediklerin dünya konumu, denetim için).

**Eksik (maddele):**
1. Yürüme yolu sorgusu yok: "x'te yol y/eni/yönü" için işlev yok; veri `IstSehir.hat_items` içinde (`walk`, `s0/s1`, `a2/b2`; `sehir.gd:1420,2975`) denetim amaçlı.
2. Dayalı merdiven dayama noktası/zemini yok (dış yüz çizgisi, teras zemini, tırmanma `top` y, çarpışmasız yaklaşma şeridi).
3. Mazgal konumları dışarı verilmiyor (`mer` yerel dizisi pişiriliyor: `surlar.gd:555,KULE.disler_ag`); "mazgal aralığında görünen savunucu" (ch26o) için konum listesi gerekir.
4. Top yuvası / mevzi / batarya noktası yok (`sur_zemin.gd:ates_alani` yalnız dekor).
5. Onarım aşamaları ve gedik barikat blokları yok (`set_repair`, `on_rubble`, `BREACH`, `rubble_y` karşılığı yok).
6. Poterna / dış sur küçük kapısı yok; dış sur kapısı yalnız kapı koşularında (`gw`).
7. Yürünür hendek köprüsü yok (kapı önü "KALDIRILMIŞ/YIKIK", yalnız görünüm: `surlar.gd:650-660`); hendek doldurma seti yok.
8. Hendek rampaları dilimin zıt uçlarında: dilim içinden ova–şehir yürüyüşü ≈ 144 m / 46 sn.
9. Bölge kaydı yok: Mesoteikhion için `oyun_alanlari()` girdisi, yerel çapa, "temiz" dikdörtgen (v2 yapılarının kaldırılacağı alan) tanımlı değil (yalnız `camp`, `byz_walls`).
10. Gedik seçimi sabit (3 nokta `sehir.gd:2840`); bölümün hangi gedikte oynanacağını söyleyen bir ayar yok.
11. `scripts/npc/climb_anim.gd` bu dalda **yok**; tırmanma pozları `rig.gd:83-84,594` (`climb_a/climb_b`) ve `Ladder`/`Player._ladder_physics`'te (`player.gd:617-700`). Taş merdivende "tırman" pozu gerekmez (yürünür); dayalı merdiven (`Ladder`) kalacaksa v2 duvarına dayama kuralı gerekir.

### 3.4 V2 yürünebilirlik ölçümü (bu oturumun gerçek `Player` botu; 110 m ve 190 m dilim, düz zemin plakasız)

| Ölçüm | Sonuç |
|---|---|
| İç merdiven (12 m) çıkış | **5,6 sn** yürüyerek (3,2 m/sn), koşarak 3,3 sn (110 m dilim ve 190 m Mesoteikhion dilimi aynı) |
| İç sur yolu uçtan uca (−52…+52) | **kesintisiz, 104,5 m / 32,8 sn**, kule geçidi dâhil |
| Dış merdiven (8,5 m) çıkış | **4,1 sn** (koşarak 2,5 sn) |
| Dış sur yolu uçtan uca | **kesintisiz, 108 m / 32,5 sn** |
| Mesoteikhion dilimi (190 m, 3 iç + 2 dış kule, `hasar 3,0`) | iç sur yolu **184,5 m / 57,8 sn** (−x), +x 157,7 m / 46,9 sn; dış sur yolu **191,8 m / 57,2 sn**; kuleler geçilebilir. Ham: `yuru_olcum.txt` |
| Hendek: yakın rampadan dibe | 4,8 sn |
| Hendek: karşıya geçiş (dipte 100 m) | toplam **46 sn / 143,6 m** |
| Hendek, 190 m Mesoteikhion dilimi | dibe inildi (4,8 sn); dipte doğuya yürürken x=60,5'te (karşı rampa tepesinin 0,6 m batısı) **58 sn boyunca ilerlenemedi** — rampa kamasının yanından dolanan bot yolu mu, yoksa dipte engel mi: **ayrıştırılmadı**; 110 m dilimde aynı bot geçti |
| Merdiven eteğinde takılma (izole dilim) | şehir yakasından −26'dan yürüyen oyuncu ilk basamağın **0,7 m önünde** durdu (6 temas, 400 karede hiç ilerlemedi); −22,9'dan (etek üstünden) başlayınca 5,2 sn'de 12 m çıktı. Şüphe: sur dibi **etek trimesh'i** (`kes["sehir"]` = merdiven başlangıcından 1 m önce başlar, `surlar.gd:565`; `_kanit_ist2_oturtma/rapor.md:53` "etek trimesh çarpışmalı"). Gerçek şehirde ve arazi eğimiyle **doğrulanmadı** |
| Önceki ölçüm (benim değil) | kara suru üstü yürüyüş %90,3 (131/145, düşme 3, takılma 11), Blakherna %78,9 — `docs/_kanit_ist2_sur4/rapor.md:130-139`; hedef ≥%97 |

## 4. FARK VE GÖREV ETKİSİ (bölüm bölüm)

Zorluk: **K** kolay (koordinat/setin yeniden bağlanması) · **O** orta (yeni küçük özellik gerekir) · **B** büyük (v2'de karşılığı olmayan mekanik ya da çok bağlantı). Zorluk **tahmindir** (kod okuma + ölçümle; taşıma denenmedi).
"Bağ" = bölüm dosyasında `LandWalls.`/`Blachernae.`/`SeaWalls.` sabitine doğrudan bağlantı sayısı (`grep`); "hedef" = `set_objective` çağrısı (konumlu olanı) — hepsi sabit koordinattır, v2'de elle yeniden verilir.

### 4.1 Blakherna — 30, 30o (S2)
- **Ölçü farkı: neredeyse yok.** V2 bu sur için eski kabuğu çağırır: `Blachernae.shell_parts(…,"wall")` (`sehir.gd:2915-2933`), yürüme yüksekliği `Blachernae.WALK_Y` = 12 (`sehir.gd:2937`). Farklar: dilim ≤120 m, kabuk dilim boyuna kırpılır (`:2916-2925`); v2 sur yolu eni 3,4 (`sehir.gd:2945`, eski ≈4,0); **dış zemin eskide düz** (`blachernae.gd:37-40`), v2'de gerçek arazi (kesim arazisi ölçülmedi; komşu Kerkoporta'da dışarıya 11 m düşüş, bkz. §3.2).
- **Etki:** merdiven ayakları ve taşıma yolu (`CARRY_FROM 34 m`, `chapter30.gd:280-282`; koşucu yolu z 46 → WALL_Z1+3, `:134`) düz zemin varsayar → `slope_y` yerine arazi sorgusu; sur yolu 31 m'lik orta parça aynı (kule x ±20/±40 sabit); tüfekçi kulesi `TOWER_X 20` (`chapter30o.gd:24`) aynı kalır; saray cephesi iki kez kurulmasın (`Blachernae._palace` ↔ v2 `_make_blakherna`, `sehir.gd:2269`; tahmin).
- **İş kalemleri (6):** bölge kaydı + yerel çapa (`IstBaglama` bölge sözlüğü örneği); `Blachernae` ova/çevre kurucusunu v2 köküne yamamak (`in_world`); zemin yüksekliği → `IstGeo.h`; merdiven ayağı/koşucu yolunu zemine oturtmak; hedef okları (30: 1, 30o: 5 konumlu); kamera kareleri.
- **Zorluk: K–O.** Bağ: 30 → 19, 30o → 87 (çoğu `Blachernae.WALK_Y/WALL_Z1`; tek noktadan sarmalanırsa az iş).
- **Risk:** `run_tests.sh:146` (30: 4 koşu), `:148` (30o: 4 koşu), `ladder_test`, `map_check`; sur yürüyüşü ölçümü Blakherna %78,9 (`_kanit_ist2_sur4/rapor.md:137`).

### 4.2 Sur sağlam/fon — 28o, 41o, 42b, 31o (S1 intact / fon)
- 28o: sur yalnız hedef (gülle sağlam sura iner), top yolu `HAUL_Z 124,5` → `HAUL_TO x 9` (`chapter28o.gd:21-24`), ritim `STEP 1,0 m`, `ROLLER_EVERY 4 sn` (mesafe değil ritim). V2'de sağlam dilim = `gedik: []`. Hendek–ova +14 m kayar; batarya ve kazık hattı (kazık 4, `:19`) ova zeminine oturur (Mesoteikhion ova düz: §3.2).
- 41o/42b/31o: yalnız arka plan/kadraj (`field_keep` `chapter41o.gd:74`, `intact` `chapter42b.gd:63`, `open_inner_gate` `chapter31o.gd:152`). 31o'da kapı geçişi ve FallenCity bağı ayrıca işlenir (kapı v2'de Romanos'ta, Mesoteikhion'da değil: `catalog` `surlar.gd:830-836`).
- **Zorluk: K.** Bağ: 28o 7. **Risk:** `run_tests.sh:144` (4), `:140-141` (4) ve arena (9 koşu).

### 4.3 Mesoteikhion çekirdeği — 0, 20, 20o, 21, 25(B), 26, 26o, 22, 22o, 32o, 36b, 37o (S1 + yardımcılar)
Ortak farklar (hepsini etkiler): peribolos 14,6→15; dış sur 8→8,5, yol eni 1,45→1,7; **dış kule aralığı 32→≈55–61, yol kesintili**; **hendek 16×2,9 → 20×6, sur→ova çizgisi 36→50 (+14 m)**; **gedik 1 → 3, onarım aşaması yok**; el merdiveni ↔ taş merdiven; düz → arazi (Mesoteikhion'da düz). Bölüm bölüm:

| Bölüm | Özel fark → etki | İş kalemleri | Z | Bağ/hedef | Risk (koşular) |
|---|---|---|---|---|---|
| **0** Açılış | Peribolos yolu 10,6 m (START→LINE), okçu sırası peribolosta; kare donarken Tolga'nın havadaki yeri gedik önü. Oyunun **ilk dakikası**: yükleme süresi ve görsel kalite görünür (v2 kuruluşu `IstBaglama.kurulum_ms`: ölçülmedi) | gedik seçimi; Assault/Garrison/WallFight'ı v2'ye bağlamak; ok demeti yolu; donan kare kadrajı | O | 9 / 1 | `:83` (1), arena (9) |
| **20** Gedik | **10 aşamalı onarım yok** (`set_repair`); depo↔gedik 16,9 m (süre bağı: ≈27 m eşiği, bkz. §2.1); hücumda gedik düellosu moloz rampada (`rubble_y`); ok sandığı/okçu yeri; tüfek (GunRange) mazgal hizası; Niko yük döngüsü 15 sn | **onarım aşamalı gedik** (yeni); depo/ok sandığı/okçu yeri; moloz rampa zemini; Garrison boşluk listeleri (eski ±6,8…10,4 = x=±8 el merdivenlerinin yeri; yeni merdiven/kule x'lerine) | **B** | 63 / 3 | `:118` (7), `:160-161` (zorluk 0/2) |
| **20o** Gedik (Osmanlı) | Top 118 m geride; gece hücumunda azaplar gedik yamacından hendeğe/ovaya iner: eskide moloz dili hendeğe uzanır (`TONGUE` z 19,6–25,5, `land_walls.gd:26-28`), v2 gediğinin molozu peribolosa ve **terasta** biter (`surlar.gd:729-731`) → hendeğe iniş yolu yok; mazgaldaki savunucu (tüfek) mazgal konumu API'si yok | gedik→hendek→ova geçidi (rampa/dil); mazgal konumları; top mevzi; WaveRunner hedefleri | **B** | 17 / 1 | `:131` (10) |
| **21** Lağım | Peribolosta 4 kap (MINE (−9;7)): alan 15 m'lik şerit içinde kalır; yeraltı tüneli surdan bağımsız | kap konumları | K | 2 / 2 | `:119` (6) |
| **22** Kule | Kule hendeğin ÖTESİNDE (TOWER z=40 = hendek karşı yakası 36 + 4); v2 hendek 30–50 → kule z≈54+ ve fıçı yamacı 24 → ≈34+ m, yukarıdan 8,5 m; fitil bandı (0,42–0,68) ve yuvarlanma süresi mesafeye bağlı mı: ölçülmedi (tween) | kule+yamaç yeniden konum; oluk/fıçı yeri; Garrison | **B** | 11 / 3 | `:120` (7) |
| **22o** Kule (Osmanlı) | Hendeğe **sepet toprak dökme** (kıyının her yerinde E): v2 hendeği 20×6 → dolgu görseli yok (eskide 16×2,9 + dil); toprak/deri yığınları (PILE (9;56), WATER (−11;52)) hendek ötesine kayar; ok yaylımı (22 sn/3 sn uyarı) siper noktaları | **hendek dolgusu** (yeni); yığın/siper yerleri; marangoz indirme merdiveni (kule yanında) | **B** | 17 / 11 | `:133` (6) |
| **25** (Bizans yarısı) | Dış sur yolunda yürü-konuş: yol 1,45→1,7; ordugâh görünümü uzak mesafede (`CampDay` fonu) | oyuncu başlangıcı sur üstü (merdivenle/ışınlama); uzak ordugâh | K | 4 / 3 | `:124-125` (7) |
| **26** Şafak | 5 hücum merdiveni (9 m/16°) kule aralıklarına göre (`lx`, `chapter26.gd:141`): v2 dış kule 55–61 aralıkla **eski liste geçersiz**; sancak kulesi (16;11;17) → v2 kule tepesi 13; **poterna** + 2 fıçı + iç kapı açılışı (`open_inner_gate`) + Sultan'ın şehre yürüyüşü FallenCity/Ayasofya; sur yoluna **ışınlanma** (`:408-423`); 3 dalga (yağ kazanları (±8,6;8;15), onarım, tüfekçi); Chaos alanı (88×10,6 m peribolos) | poterna (yeni), iç kapı (Romanos kapısı 170 m kuzeyde, Mesoteikhion dilimi kapısız), merdiven dayama (yeni), kazan yerleri, onarım ekibi, kule/sancak, FallenCity bağı, ışınlama noktaları | **B** (en büyük) | 61 / 8 | `:126` (14), `:125` |
| **26o** | Hücum merdiveni **8,6 m/8°**, `CLIMB_X 9`, dayama noktası dış yüz; **hendek dolgusu** (`ditch_filled`, CAUSEWAY set 10×16 m, dip −1,5) v2'de yok; kıyı `EDGE_Z 37,4` → ≈51; sur tepesinde 2+3 savunucu mazgal aralığında; sancak (kule) | hendek dolgusu + set (yeni); merdiven dayama; mazgal konumları; sancak kulesi | **B** | 23 / 8 | `:135` (5) |
| **32o** | Çalı demeti `EDGE_Z 37,4` ve `DITCH_TIME 240 sn`; hendek 6 m derin → "iki demette bir sepet" görseli yok; manto 14;41→64 yolu (23 m) ova +14 m; Ali bataryası `FIRE_Z 92`; 6 basamaklı merdiven çakma | hendek dolgusu (22o/26o ile ortak); batarya; yığın yerleri | O–B | 8 / 13 | `:149` (7) |
| **36b** Huruç | **Poterna** (dış sur ova yüzü, `POSTERN` LANE_X −24) v2'de yok; kalas köprü 16→20 m, düşme derinliği 1,6→6; siper hattı `TRENCH_Z 54` → ≈68; `RIDE_TIME 34 sn` süvari (sabit); Leon taşıma yolu uzar | poterna (yeni); kalas köprü uzunluğu/yükseklik; siper | O–B | 4 / 2 | `:137` (2) |
| **37o** İlk Hücum | Kalas köprü **ekiple taşı-indir** + denge (`BalanceMeter`) + düşersen **hendek dibinden karşı duvara tırman**: dip −2,9 → −6 (tırmanış ≈2×); barikat gedik, MARCH 74→41,5 / DRAG 39,5→68 (32,5 / 28,5 m) +14 m; `STOCKADE_TIME 180 sn`; 5 fıçı | kalas köprü + hendek duvarı tırmanışı (yeni yükseklik); barikat; yürüyüş yolları | **B** | 25 / 7 | `:150` (3) |

**Süreli evrelerde mesafe etkisi (hesap, tahmin):** hendek–ova +14 m ve hendek geçişi ×5 olduğundan (8,7 → 46 sn, §3.4) yalnız "hendeği geç" içeren evreler (36b, 37o, 8y) etkilenir; 32o/22o/26o'da dolgu **sabit süre/sayaç**tır, mesafe değil.

### 4.4 Kapı ve hub — 8y, 10h, 12b, 6b, 7b (S6, S5)
- **8y:** 148 m koridor (`chapter8y.gd:29-59`). V2 Romanos kapısı 5,0×4,6, dış sur kapısı kanatları/sürgü animasyonu bölümün kendi işi; **hendek köprüsü v2'de yıkık** (yalnız görünüm) → yürünür köprü şart; ova Romanos'ta düz (§3.2) ✓. **Z: O.** Hedef 7 (2 konumlu). Risk: `:93` (7).
- **10h / 12b / 6b / 7b:** Hub'ın iç suru (3 m, 16 m kule aralığı) ↔ v2 iç sur (5 m, 53–61 m); 12b'nin "iki kule arası sur yolu" (`chapter12b.gd:76-130`) v2 yolunda (4,1 m, kule geçidi) daha doğal; 10h'nin kendi gediği (`:102`) v2 gediği olur. **Şimdiden v2'de** (`baglama.gd:53-56`): iş = yamayı kaldırıp bölümü doğrudan v2'ye yerleştirmek. **Z: O.** Risk: `:89-90,105-106` + `baglama_ucus`, `flight_check`, `city_check`.

### 4.5 Deniz — 4b, 17, 19, 19o, 29, 29o (S3); 18b, 38o (S4)
- S3 kıyı/zincir: v2'de Haliç rıhtımı/zincir/kulesi var (`halic_liman`, `halic_zincir`, `sehir.gd:2470`); eski zincir 32 m denge yolu (4b) ve rıhtım 22,5 m. Sur tırmanılmaz. **Z: O** (ayrı iş akışı).
- S4: v2 Haliç suru `IstHalicSur`: yükseklik **9,0** (eski WALK_Y 9,6), kalınlık 3,0, yürüme yolu 1,8, kule aralığı ≈28 m, kapı 3,0×3,4, rıhtım 5 m (`halic_sur.gd:13-22`, `QUAY_W 5`). 18b: 11×3 m top yuvası dizisi (33 m) sur boyu 96 m içinde; 38o merdiven/kapı (GATE_HW 1,6, GATE_H 4,2) v2 kapısından (3,0×3,4) daha dar/yüksek. **Z: O.** Risk: `:116` (2), `:151` (4).

---

## 5. ÖNERİ SIRASI

### 5.1 Taşımadan ÖNCE dondurulması gerekenler (kırılma kaynakları)
Sur görünüşü hâlâ değişiyor (SUR-5, OTURTMA turları); aşağıdakiler değişirse bölümlerin sabit koordinatları topluca kırılır:
1. `IstSurlar.dims()` tablosu ve `K_SUR = 1.0` (`surlar.gd:50-76`, `sehir.gd:1289`): T, PW, OH, HW, MW, MD, PTW, OT, S, TW/OTW. (Kesit z şeritleri: iç 0, peribolos 2,5…17,5, dış sur 17,5…20,1, teras 20,1…30,1, hendek 30,1…50,1.)
2. **Kule yerleşimi:** `_layout` kule x'leri `L`, `seed`, `S=55` ve `rng` çağrı sırasına bağlı (`surlar.gd:85-157`); biri değişirse bütün merdiven/kule/dayama x'leri kayar. Dilim uzunluğu (`HAT max 110`, kapı koşusu 60 m, `_gate_len`) ve `sehir.gd:2366` dilimleme kuralı da donmalı.
3. **Kapı yerleri ve ölçüleri:** `OPTS` (gw/gh, `surlar.gd:933-945`), `catalog()` koordinatları (`:819-845`), `GATE_L 60`.
4. **Gedik yerleri:** `_gedik_x` (Romanos'a en yakın noktadan 110/215/330 m, `sehir.gd:2820-2850`) ve `GEDIK_W 8`.
5. **Merdiven konumları/biçimi:** iç/dış merdiven x'leri (`lay.in_x0/out_x0`), basamak 0,26/0,42, genişlik 1,8 (`surlar.gd:90-130,220-236`); hendek rampa uçları (`ramp_a_x = −0,32 L`).
6. Arazi (`IstGeo.S = 0,35`, `h()`), özellikle Mesoteikhion–Romanos şeridi; `OTURTMA` düzlük kayıtları.
7. Çarpışma sözleşmesi: iç kule geçidi 2,2×3,0, dış kule geçidi 1,8, parapet 0,45×1,2, yürüme yolu eni (4,1 / 1,7).
**Öneri (karar değil):** bölümler bu sayıları kendi dosyasında sabit tutmak yerine tek bir "sur kesiti" sözleşmesinden okusun; sözleşmenin sayıları için bir kıyas testi (ör. `dims()` özeti) eklensin → ölçü değişince kırılan yer açıkça görünür. (Bunu yapmak ayrı bir iş; bu belge yapmadı.)

### 5.2 Sıra
| # | Ne | Neden |
|---|---|---|
| **0** | Dondurma + v2 oynanış arayüzü (§3.3 maddeler 1-3, 5, 6, 7, 9) | Hepsi bunlara dayanır; yoksa her bölüm kendi çözümünü yazar |
| **1** | **30 + 30o (Blakherna)** — birlikte | v2 zaten aynı kabuğu kullanıyor (ölçü farkı ≈ 0), hendek yok, tek kesim, 2 bölüm; en ucuz kazanım ve arayüz maddelerini ilk deneyecek pilot |
| **2** | **28o (+ 41o, 42b, 31o fon)** | Sur oynanışı yok/az, Mesoteikhion düz ova kesimini "ova + batarya" ile sınar; risk düşük |
| **3** | **20 + 20o** (gedik çifti, gece/gündüz) | Mesoteikhion çekirdeğinin ilk bölümleri: onarım aşamaları, gedik→hendek geçidi, mazgal/tüfek, depo mesafesi kararları burada verilir; 21, 0, 25(B) ucuz eklenir |
| **4** | **22 + 22o, 32o, 36b, 37o** (hendek önü) | Hepsi hendek dolgusu / kalas köprü / poterna ister; tek "hendek önü" bileşeni (§3.3 madde 7) ile birlikte yapılırsa 4 bölüm tek iş |
| **5** | **8y, 10h, 12b, 6b, 7b** (kapı + hub) | IstBaglama yaması zaten var; kapı köprüsü bileşeni 4'ten gelir |
| **6** | **Deniz (4b, 17, 19/19o, 29/29o; 18b, 38o)** | Ayrı sur ailesi (Haliç); "tüm görevler aynı harita" hedefinde sonda ama bağımsız ilerleyebilir |
| **7 (en son)** | **26 + 26o** (Şafak) | En çok bağ (61/23), poterna+kapı+FallenCity+Ayasofya+3 dalga; yukarıdaki bütün bileşenleri kullanır — bileşenler oturunca |

**Aynı sahne olabilir mi?** Evet: 0, 20, 20o, 21, 22, 22o, 25(B), 26, 26o, 28o, 32o, 36b, 37o, 41o, 42b (+31o'nun kapı kısmı) aynı kesimi (Mesoteikhion, ≈190 m dilim) paylaşır → tek "Mesoteikhion oyun sahnesi" (tek gedik, tek hendek önü, tek kapı=Romanos'a ayrı geçiş); Blakherna (30/30o) ayrı sahne; hub/kapı (8y, 10h, 12b, 6b, 7b) Romanos kapısı iç yanı; Haliç (18b, 38o) ayrı. Bu 4 sahne yaklaşık 36 bölümün tamamını karşılar. **Bedeli:** tek sahnede hem Bizans (içeriden) hem Osmanlı (dışarıdan) bölümler aynı gedikte; bölüm geçişleri arasında v2 yeniden kurulumu (yükleme) — ölçülmedi.

---

## 6. SAHİBİNE KARAR LİSTESİ

(Karar yazmıyorum; her birinde öneri ve gerekçe var.)

1. **Süreli evreler mesafeyle mi büyüsün?** Örn. 20'de gece 170 sn ve depo↔gedik gidiş-dönüş 33,8 m (10 yük ≈ 106 sn yürüyerek); yeni yerleşimde depo gediğe >27 m uzaksa süre yetmez. *Seçenekler:* (A) süre sabit, depo gediğe ≤ 20 m yakın konur; (B) süre mesafeyle orantılı uzar; (C) yük sayısı azalır. **Öneri A** — süre tasarımın temposudur; yerleşim kontrol edilebilir.
   - KARAR (sahibi, 13 Kasım): A — süre sabit; depo gibi yerler hedefe ≤ 20 m konur.
2. **Merdiven türü.** Yeni surda peribolos→sur geçişi taş merdiven (yürünür, 4,1 sn); hücum merdivenleri (26, 26o, 30, 30o, 38o) bugün dayalı el merdiveni (W ile tırmanma, 3,8 sn). *Seçenekler:* (A) ikisi birlikte (taş merdiven savunma tarafı, dayalı merdiven hücum tarafı); (B) hepsi taş. **Öneri A** — hücum "dayama/itme" mekaniği (30'da itme, 26'da tekmeleme) ancak dayalı merdivenle anlamlı.
   - KARAR (sahibi, 13 Kasım): A — savunma tarafı taş merdiven, hücum tarafı dayalı el merdiveni (`sur_oyun.gd dayamalar()`, `sur_oyun_parca.gd HucumMerdiveni`).
3. **26o'da merdiven boyu ve tırmanma.** Eski 8,6 m (dış sur 8); yeni dış sur 8,5 (+%6). *Seçenekler:* boy 9,1'e çıkar, tırmanma süresi aynı kalsın / orantılı uzasın (≈+0,2 sn). **Öneri:** aynı kalsın (fark algılanmaz).
   - KARAR (sahibi, 13 Kasım): tırmanma süresi aynı kalır (boy dayamadan türer; süre bölümün sabiti).
4. **Gedik sayısı.** Eski tek gedik (x=0); v2 Mesoteikhion'da üç (110/215/330 m). *Seçenekler:* (A) oyun gediği = 1. gedik, diğer ikisi dekor/kapalı; (B) bölümler farklı gedikleri kullanır (20: 1., 26: 2.). **Öneri A** — "tüm görevler aynı harita" ve bölüm-bölüm süreklilik (gedik her gece kapanır/yarın açılır).
   - KARAR (sahibi, 13 Kasım): A — oyun gediği = 1. gedik; 2. ve 3. dekor/kapalı (stauromalı). Sözleşmede oyun gediği Mesoteikhion dilimi x = −67,7.
5. **Gedik onarımı (10 aşama).** V2'de yok. *Seçenekler:* (A) eski 10 aşamayı v2 gediğine uyarla; (B) 3–4 aşamaya indir; (C) yalnız ön/son görüntü. **Öneri B** — okunabilirlik aynı, iş yarı.
   - KARAR (sahibi, 13 Kasım): B — 4 aşama (açık → kazık/fıçı → toprak dolgu → barikat tam; `GedikOnarim.asama(1..4)`).
6. **Hendeğe kaç metre?** 16×2,9 → 20×6 ve sur→ova 36→50 m. Kalas köprü (36b, 37o) boyu 16→≥20, düşme derinliği 1,6→6; hendek duvarı tırmanışı 2×. *Seçenekler:* (A) v2 hendeği olduğu gibi, bölüm sayıları uyarlansın; (B) oyun kesitinde hendeği sığlaştır (≈3 m, rampalı uçlar). **Öneri A**, ama düşmenin cezası (can/nefes) 2× olmasın — sahibin zorluk ayarı.
   - KARAR (sahibi, 13 Kasım): A — hendek 20 × 6 m kalır; düşmenin cezası iki katına ÇIKMAZ.
7. **Hendeği geçme yolu.** Hendek rampaları dilimin zıt uçlarında: dilimden geçiş 46 sn. *Seçenekler:* (A) kapı dışında her geçiş yürünür **köprü/dolgu** (36b kalas, 37o kalas, 8y kapı köprüsü, 26o/32o dolgu); (B) rampaları sahne içinde karşılıklı konumla yeniden yerleştir. **Öneri A** — bölümlerin kendi mekaniği zaten köprü/dolgu.
   - KARAR (sahibi, 13 Kasım): A — kapı dışında hendek geçişi köprü/dolgu ile (`KalasKopru`, `Dolgu`, `KapiKopru`).
8. **Dış kule aralığı 32 → ≈55–61 m.** Hücum merdiveni sayısı (26: 5, 30: 4) ve savunucu yerleşimi aynı kalsın mı? *Seçenekler:* (A) sayı aynı, aralık geniş (savunma daha seyrek hisseder); (B) merdiven/savunucu kule başına orantılı azalır. **Öneri A**, sur yolu askeri yoğunluğu (Garrison) aynı bırakılsın.
   - KARAR (sahibi, 13 Kasım): A — merdiven ve savunucu SAYISI aynı (dayama 5), aralık geniş.
9. **Sur yolu kesintisi.** V2 dış sur yolunu kule keser (1,8 m geçit); eskide kuleler yolun arkasında, yol 100 m kesintisiz. Savaş koreografisi (sur yolunda itişme, 26/30) *Seçenekler:* (A) kule geçidiyle yürüyüş; (B) kulelerde yol genişletilsin. **Öneri A** (taşımada koreografi kule aralarına sığdırılsın), ama yeni eksik arayüz (§3.3-1) ilk gelsin.
   - KARAR (sahibi, 13 Kasım): A — sur yolu kule geçidiyle (iç kule 2,2 × 3,0 geçit; dış kulede basamakla tepe).
10. **Poterna (36b, 26).** V2'de yok. *Seçenekler:* (A) dış surda küçük kapı eklensin (görsel + çarpışma); (B) bölüm 36b'de çıkış kapıdan olsun. **Öneri A** — iki bölümün hikâyesi (gizli kapı) buna dayanıyor.
   - KARAR (sahibi, 13 Kasım): A — dış surda poterna eklenir (`Poterna`, yeri sözleşmede).
11. **26 sonu: iç kapı (Sultan'ın girişi).** Mesoteikhion dilimi kapısız; Romanos kapısı 170 m kuzeyde. *Seçenekler:* (A) kapıyı Romanos'a taşı (26'nın finali orada); (B) Mesoteikhion'da ek iç kapı. **Öneri A** (tarihî doğru, kapı v2'de hazır).
   - KARAR (sahibi, 13 Kasım): A — 26'nın son kapısı Romanos (ölçüm: oyun gediğinin 57 m kuzeyi; kesim sahnesinde kuzey yan dilim).
12. **Yükleme/bütçe.** Tek sahnede tüm kesim, her bölümde v2 yeniden kurulumu. *Seçenek:* bölümler arası v2'yi canlı tut / her bölümde kur. **Öneri:** önce ölçülsün (`IstBaglama.kurulum_ms` bu belgede ölçülmedi).
   - KARAR (sahibi, 13 Kasım): yükleme önce ÖLÇÜLÜR (`docs/_kanit_ist2_sur_arayuz/rapor.md`, kurulum tablosu).
13. **Anahtar ve geri dönüş.** `--eski-dunya` benzeri bölüm başına güvenlik anahtarı ve eski setlerin en az bir sürüm silinmeden kalması (arena `LandWalls` kullanır). **Öneri:** evet.
   - KARAR (sahibi, 13 Kasım): bölüm başına geri dönüş anahtarı; eski setler en az bir sürüm silinmez.
14. **Yön söyleyen replikler** ("gediğin solundaki merdiven" gibi): v2 yerleşimiyle uyuşmazsa yazar/oyun sahibi karar verir; sayıları replikte geçenler **taranmadı** (ölçülmedi).
   - KARAR (sahibi, 13 Kasım): yön söyleyen replikler taranır, DEĞİŞTİRİLMEZ: liste çıkarılır (`docs/_kanit_ist2_sur_arayuz/yon_replikleri.md`).

---

## 7. EK — Yöntem, sınırlar, kayıt

- Not: yürüme çıktısının ilk satırları (110 m 'sur' dilimi) aynı sondanın `for id in ["sur","mesoteikhion"]` ve 60 sn sınırlı önceki sürümünden; `probe_yuru.gd.txt` sonraki (yalnız Mesoteikhion + eski set, ilerleme tabanlı takılma) sürümdür. Blakherna arazi sondası (`probe_arazi2`) 100 sn içinde bitmedi, çıktısı yok.
- Sondalar: `docs/_kanit_sur_dokum/probe_v2.gd.txt` (IstSurlar ışın ölçümü), `probe_eski.gd.txt` (LandWalls/Blachernae/SeaWalls), `probe_yuru.gd.txt` (Player botu); çıktılar `v2_olcum.txt`, `eski_olcum.txt`, `yuru_olcum.txt`, `arazi_olcum.txt`. Sondalar `~/is/` altında koştu; depoya yalnız `.txt` kopyaları girdi (Godot yan dosyası üretmesin).
- Godot 4.4.1 linux x86_64 `~/is/godot/godot` (başsız). Sondalar bir sahne olarak koştu (`-s` ile otomatik yükleme sınıfları bulamıyor).
- **Ölçülmedi:** S4/S5/S6 sayıları (başsız kurulum yok), Blakherna kesim arazisi (sonda koşmadı; vekil: Kerkoporta), v2 kuruluş/yükleme süresi, replik metinlerindeki mesafe/yön ifadeleri, `ch8y/36b/37o/32o` botları, fıçı yuvarlanma süresinin mesafe bağı (22), kamera kare koordinatlarının tamamı.
- **Tahmin işaretlenenler:** zorluk (K/O/B), yük eşiği 27 m, "çift saray", Mesoteikhion–Blakherna arazi yönleri.
- Hata bildirimi: oturum sırasında bir kez `pkill -f nothing` komutu yazıldı (yasak listesinde `pkill` vardı); hiçbir sürece uymadı, sonuç boş, sonrasında yalnız `kill <pid>` kullanıldı.
