# G22 rapor — Bizans meydanı bölündü: saray avlusu ve kançılarya ~430 m içeride, surda Giustiniani ve kapı

Dal `wip/saray22` (taban `wip/ist2-birlesik` 618521d7 = 6dec6901 + görev yazısı). Kanıt `docs/_kanit_saray22/`.
Sahibe en iyi üç kare: `kare/sahip_1_43o_drone70_romanos_once_ust_sonra_alt.jpg` (sahibin bakışı, önce üst / sonra alt),
`kare/sahip_2_v2_saray_avlusu_imparator.jpg`, `kare/sahip_3_v2_ucus_iki_parca.jpg`.

## Özet

- Romanos Kapısı'nın ardında artık yalnız **sur parçası** var: iç sur (yeni kesim / eski kutu), kapı, Giustiniani'nin
  iskelesi ve masası, nöbetçiler, meşaleler, yeni **nöbet ve ikmal yeri** (taş ocak, kazan sehpası, sabit su fıçısı,
  sandık, çuval, kütük, kalkanlar, iki nöbetçi ve sandık taşıyan işçi; Dressing modelleri ve hub'ın malzemesi, kutu yok).
- **İç mahalle** (saray avlusu + İmparator + konsey + mangala, kançılarya 7 oda / 7 kâtip / Nihat cameo, meydan + çeşme +
  tezgâhlar + tabelalar, cadde evleri, Niko ve kayığı, zindan hücresi, kubbeli batı kilisesi, dolgu evler) hub yerelinde
  `SurHub.SARAY_OFS = (−400, dy, 130)`'da; iç düzen bugünküyle aynı (iç grubun yereli = bugünkü hub yereli).
  dy dünyaya göre: v2 −7,53 (arazi 6,56 − hub kökeni 14,09), eski dünya `SiegeField.saray_y()` ≈ +5,65.
- Bölme çizgisi yerel **x 18** (`ByzCity.BOLME_X`; kançılaryanın doğu duvarı x 14, alınlığı 14,7: x 14 dar geliyordu).
  İç dikdörtgen `IC_RECT` x −46…18, z −48…22; sur parçası `SUR_RECT` x 18…38 (yeni surda …32,5).
- Anahtar bölüm başına: `ByzCity.BOLUNEN` = 6, 7, 10h, 12b, 13, 23, 24. `--saray-eski` hepsini eski bileşik düzene
  döndürür (bölünmemiş yol çalışır durumda: kod yolları korunuyor). İç ağırlıklı bölümlerde (`IC_MERKEZ` 6, 7, 13, 23, 24)
  ByzCity kökü `_ready` sonunda −ofs ötelenir; 10h ve 12b ötelemesiz (sur çerçevesi).

## Hedef maddeleri

| Madde | Durum | Not |
|---|---|---|
| 1. Bölünme (tek çerçeve, iki kök) | TAMAM | `saray_kok`, `_k` kurulum kökü (bütün `Props.*(self…)`, `add_child`, `_house`, `_fbox`, `_trunk`, `_wall`, `_chi_rho`), `ic_global`/`sur_global`/`ofs()`/`saray_konum`, `_kur_bolunmus`, `_dress_bolunmus`, nöbet yeri |
| 1. Deniz kapısı bloğu, Haliç suru + 4 kule | TAMAM | bölünmüşte kurulmuyor; caddenin güney ucu açık sokak ağzı |
| 1. `_build_fill` çek-sonra-at | TAMAM | ev kararı bölünmemiş dikdörtgenle; sur parçasına düşen ev bütün rng çekimleriyle atılır (geçici düğüm + aynı rng'li ikinci Dressing) |
| 1. Servi, Dressing.auto iki alan | TAMAM | `Dressing.auto` `"kok"` seçeneği; iç mahalle tohum 453 / 10 yürüyen (bugünkü), sur parçası tohum 454 / 4 yürüyen |
| 2. v2 oyun alanı "saray", hub alanı sur parçasına | TAMAM | `IstSehir.oyun_alanlari` [sur, meydan, saray] (saray SONDA); IstBaglama `hub_alan` aynı |
| 2. v2 düzleme | TAMAM | `IstGeo.duzle` merkez hub_xf·(ofs + IC merkezi), r 50, geçiş 14, y = taban − 0,12 |
| 2. `hub_sehir` + `hub_saray` | TAMAM | tek ByzCity, katman başına bir kez kurulur, iki tutucuya dağıtılır; `KURULUM_ATLAMA_YOK`, `_saray_dondur`, `silinecek_mi` iki alan |
| 2. `_saray_yolu` | TAMAM | hub dizinle (ar[0]); yol iç mahallenin doğu-batı caddesinin sokak ağzına; G21'in alan içi meydan/zemin_ek/ağaç/kuyu kaldırıldı |
| 2. Eski dünya FAR_REGIONS, far_hub iki pişirme, SiegeField düzlük | TAMAM | sur parçası z −2,3'ü kesmeye devam ediyor (SiegeField ikinci iç sur kurmuyor) |
| 2. Eski dünya kısa yol bağlantısı | YAPILMADI | CityPlan'a dokunulmadı; mahalle düzlüğe oturuyor, ROAD ~86 m doğuda |
| 2. Kalabalık azalmaz | TAMAM (ölçüm aşağıda) | iç mahallede bugünkü halk + Dressing yürüyenleri; sur parçasına 4 yürüyen + nöbet yeri |
| 3. Bölüm akışları | TAMAM | aşağıda bölüm bölüm |
| 4. 43o kareleri iki yol, v2 uçuşu | TAMAM | `kare/43o_*`, `kare/v2_uzak7/` |

## Bölüm başına değişen akış

- **6b** (ötelenmiş): martı kovalamacası iç meydanda başlar; 6 tünek ve sabırlar aynen (`PERCHES`, `PATIENCE` dokunulmadı).
  Tünek 0–3 iç mahallede, 4 = sur yolundaki **sabit su fıçısı** (`ByzCity.FICI_POS` + 1,27; kodla kuruluyor, Dressing
  ürünü değil), 5 = Giustiniani'nin masası. **3→4 geçişinde kararma**: `D6B_T_CHASE_4` "Surlara gidiyor!" çalarken martı
  sura doğru yükselir, uçuş bitince kararma, martı fıçıda, oyuncu fıçıya ~11 m'de; sabır kararma açılınca başlar
  (yakalasa da kaçırsa da). Leblebiyle iç mahallede yakalanırsa `_permit_done` sonrası kararma → Giustiniani'nin yanı.
  Giustiniani bitince ("İmparator'a git") kararma → saray avlusunun kenarı; İmparator bitince kararma → kapının şehir
  yanı (Niko yanında). `_process_space`, kançılarya çıkış eşiği, `VISTA_3` hedefi (gerçek sur kulesi), `byzyuru` botu
  (iki alan), `_auto_chase_step`, `_gull_leave` hedefleri çerçeveye göre. Replik metni/sesi değişmedi.
- **7b** (ötelenmiş): izler — kançılarya, saray, hücre iç mahallede; "walls" ve "outside" `city.sur_global` ile surda.
  Rapor kapısı START+(0,0,2,6) iç mahallede. `_auto_stand_near` zemini tanığın kendi y'sinde arar. Uçuşta iki alan serbest.
- **10h** (ötelemesiz): kapıdan giriş ve kaftan kapıda. **`D10H_L_04` "Bak, saray. Kaftanını düzelt." artık kararmadan
  sonra avlunun kenarında çalar** (çaldığı an değişti). Gece: kararma altında Niko kapının nöbet yerine, oyuncu sur
  parçasında doğu-batı caddesinin ağzına; üç iş ve çıkış aynı alanda, ek kararma yok.
- **12b**: İmparator `city`'nin altına alınır (konum tweeni sur çerçevesinde); iki grup da kurulur.
- **13 =city**, **23**, **24 (ilk yarı)** (ötelenmiş): yerel sabitler aynen; 23'te konsey düğümleri `saray_kok`'ta aranır.
- Her yerleştirmeden sonra `ByzCity.alan_gecis(p)`: v2 arazi çarpışması yeni yerde (`carpisma_yenile`) + karanlıkta 1 sn.

## Değişen dosyalar (taban 618521d7'e göre)

- `scripts/level/byz_city.gd`: bölünme sabitleri/yardımcılar 47–160, `_ready` 162–262 (bölünmüş kurulum, öteleme),
  `saray_rect`/`_kur_bolunmus`/`_dress_bolunmus`/`_build_nobet` 263–375, `far_hub` iki pişirme 380–455, `_build_ground`
  bölünmüş levhalar, `_build_street` Deniz kapısı, `_build_small_skyline` kilise/kök, `_cypress_list`, `_plant_cypresses`/
  `_plant_in`, `_build_fill` çek-sonra-at ve Haliç suru; geri kalan satırlar `self`→`_k` mekanik değişimi.
- `scripts/level/dressing.gd:1052–1232` `auto` `"kok"` seçeneği (`_ground` y_min).
- `scripts/level/siege_field.gd:183–235` `SARAY_DUZ`, `saray_y`, `_saray_d`, `_city_ham`, `city_ground`.
- `scripts/world/world1453.gd:118–122, 270–280` `FAR_REGIONS` iki dikdörtgen.
- `scripts/world/ist/sehir.gd:377, 1496` (hub_saray listelerde), `:2048–2066` düzleme + iki öğe, `:2228–2330`
  `_make_hub`/`_make_hub_saray`/`_hub_parca_al`/`_hub_bolunmus_kur`/`_hub_ayikla`, `:2633–2660` `oyun_alanlari`, `saray_alani`.
- `scripts/world/ist/baglama.gd:49` `TEMIZ_BOL`, `:387–420` keep birleştirme/temizlik, `:466–476` hub_alan/_oyun,
  `:496` `_saray_dondur`, `:536–600` `_sil_alan2`, `silinecek_mi`, `KURULUM_ATLAMA_YOK`.
- `scripts/world/ist/sokak.gd:640–685` `_saray_yolu`.
- `scripts/chapter6.gd`, `chapter7.gd`, `chapter10h.gd`, `chapter12b.gd`, `chapter23.gd` (yalnız yerleşim ve geçişler).
- Testler: `tests/_ist/tasima10_kare.gd:113`, `tur14_bolum_kare.gd:115`, `tasima12_kare.gd:97–137` (iç mahalle, nöbet
  yeri, uzak saray), `tests/city_audit.gd:49–55` (bölünmüş + "saray" dikdörtgeni), yeni `tests/_ist/saray22_eski_liste.txt`.
- `sur_set_hub.gd`, `geo.gd`, `hayat_yakin.gd`, `wall_rear.gd`, `city_plan.gd`, `chapter43o.gd`: değişmedi.

## Testler (ham çıktılar `testler/`)

- Ayrıştırma: PARSECHECK PASS scripts=370.
- **Sözleşme altılısı birebir aynı** (`testler/denetim_1.txt`): SURSOZLESME PASS kalem=13 kesim=8 · SUROYUN nokta=519
  havada=0 gomuk=0 katida=0 · WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0 · ESYATEST PASS · HALICSONDA OZET carp=661
  karma=3854034809 · MARMARASONDA OZET carp=1837 karma=2250736444.
- **Hub bölümlerinin bütün çeşitleri ×2** (`--max-fps 20`; 6 byz/byzmistake/byzfail/byzclimb/byzgive, 7 tea/lost/form/
  wall/wallkeep/byz/byzniko/byzcell/fez, 10h ""/shame/save/save1/honest/open/pass, 12b ""/lie/year/d2/d3, 13 city,
  23 ""/creative/pass/singed/letter/osm, 24 ""/late/niko/niko_slow/eclipse): **76/76 AUTOTEST PASS**, VISAUDIT, WALKTHRU,
  HELDAUDIT, ARMAUDIT, GORUNMEZZEMIN, ALETAUDIT, DONUKAUDIT, ESYAAUDIT (dusme/havada/gomuk/tikama/sinir), JOURNEY,
  YUKLEMEAUDIT_KESIN, SCRIPT ERROR satırı **0** (`hub_kosu1.txt`, `hub_kosu2.txt`; yalnız YUKLEMEAUDIT_ADAY bilgi satırları).
- **Dünya bölümleri ×1** (6, 7, 8y, 9, 10, 10b, 10z, 11, 13, 16, 24o, 25 osm, 31o, 43o): 14/14 PASS, denetim satırı 0.
- **`--eski-dunya` hub yolu** (bölüm başına tek çeşit: 6 byz, 7 byz, 10h save, 12b, 13 city, 23, 24): 7/7 PASS (`ozet_e.txt`).
- Ayrı koşular: CITYCHECK 24 PASS (oyuncunun noktası artık saray mahallesi: sivil 12 / 23 / 22), CITYCHECK 31o PASS
  (14 / 14 / 20); STREETCHECK, FLIGHTCHECK, WORLDCHECK (regions=13), WALKCHECK, MAPCHECK PASS; menu_return 26 ve 20o
  PASS; ZFIGHT 0 (6, 7, 10h, 12b, 13, 23, 24 — ilk koşuda 10h/12b/23/24'te uzak zemin levhası ile döşeme aynı yan
  düzlemdeydi, levhalar 0,3 m içeri çekildi, ikinci koşu 0: `zf.txt`).
- Harita `tools/map_bake` ile yeniden pişirildi: çıktı bayt bayt aynı (eski dünyanın harita dokusu değişmedi), commit yok.

## Yükleme süresi (load_time, ayrı koşular; önce = taban kopyası)

| Bölüm | Önce total ms | Sonra total ms |
|---|---|---|
| 24 | 44 555 | 39 461 |
| 23 | 42 145 | 39 640 |
| 10h | 53 375 | 39 522 |
| 6 (6a açılışı) | 9 421 | 9 286 |

Artış yok. Dürüst not: "önce" 24/23 koşuları paralel kare çekimiyle aynı anda koştu (CPU paylaşımı), 10h/6 tek başına;
farkın bir kısmı ölçüm gürültüsü. Bölünmüş kurulum bugünkü kurucuları aynı sayıda çağırıyor (tek ByzCity).

## Kareler (`kare/`, tam boy)

- 43o sahibin bakışı ve saray mahallesi, iki yol (taze süreç `taze_*`, önce v2 kurulmuş süreç `v2_*`): `43o_*_once_ust_sonra_alt.jpg`,
  tek tek `once/`, `sonra/`.
- v2: `v2_23/` (06 avlu + İmparator, 07 kançılarya kapısı, 08 meydan + çeşme, 09 nöbet yeri, 10 sokak ağzı, 02 kapı,
  05 tepeden), `v2_uzak7/` (7a uçuşu: 03 uzak saray, 04 iki parça aynı karede), `v2_10h/c10h_01_huzur.png` (saraya varış),
  `v2_6/` (6b sur tarafı: fıçı, Giustiniani'nin masası, kapı).
- Sahibe: `sahip_1_43o_drone70_romanos_once_ust_sonra_alt.jpg`, `sahip_2_v2_saray_avlusu_imparator.jpg`,
  `sahip_3_v2_ucus_iki_parca.jpg`.

## Rng ve sabitler (dürüst)

- CityPlan meydan/ana yol listeleri ve `WallRear.depth/in_band` dokunulmadı; WORLDCHECK aynı. Ama eski dünyada keep
  dikdörtgenleri değişti (hub alanı → sur parçası + saray): SiegeField servi döngüsü ve `WallRear._ok` sonraki çekimleri
  kaydırır (görev yazısı madde 18). CityPlan etkilenmez.
- `CityPlan.MARKETS` (−120, −400): iç mahallenin dünya dikdörtgeni z −482,3…−418,3; pazar 18 m kuzeyde, alana düşmüyor.
- ByzCity'nin genel rng'si: iç evler aynı (çek-sonra-at); Deniz kapısı ve Haliç suru kurulmadığı için Props önbelleği
  daha az ısınır (görüntüye etkisi gözlenmedi).
- v2'de sokak önbellek imzası oyun alanlarını içerir: ilk koşu soğuk kurulur (bir kez tek süreçle ısıtıldı).

## Hâlâ kötü olanlar

- **v2'de eski hub alanı büyük ölçüde boş çayır** (05_tepeden, uzak7/04): G21 şeridinin bu bölgedeki dokusu seyrek ve
  hub düzlemesi (r 48) sur kesiminin zemini değişmesin diye bilerek aynı bırakıldı. Bostan/bağ yoğunluğu ayrı iş.
- **İç mahallenin v2 oyun alanı eksen hizalı** (`_rect_xf`): hub 161,9° dönük olduğu için dikdörtgenin köşelerinde
  ~10 m'lik boş toprak üçgenleri kalıyor (uzak7/03). Çevre yolu bu sınırdan geçiyor.
- **Eski dünyada mahalleye yol yok**: ROAD ~86 m doğuda; CityPlan'a dokunmadan bağlantı yapılmadı. Mahalle 26 m büyütülmüş
  düzlükte, 30 m'lik şevle araziye iniyor.
- Sur parçasının döşemesi şeritte keskin kenarlı bir taş dikdörtgen (kenarı zeminle aynı hizada; basamak gerekmiyor).
- 6b'de 3→4 geçişi kararmayla: martının ~430 m'lik uçuşu görünmüyor (görev yazısının kararı).
- `D10H_L_04` artık kapıda değil avluda çalıyor; kapıdaki sahnede "Bak, saray" repliği yok (bilinçli).
- `IstSehir` bölünmüş hub öğeleri `--eskisur` yolunda bölünmez (eski kutu surda hub v2'de başka yerde).
- Fazlar görev yazısındaki sırayla ayrı ayrı kaydedilmedi: A ve B'nin kodu birlikte ilerledi, ara kayıtlarda anahtar
  (`BOLUNEN`) kapalıyken bölümler eski yerde oynadı; anahtar açıldıktan sonraki bütün testler yukarıda.
