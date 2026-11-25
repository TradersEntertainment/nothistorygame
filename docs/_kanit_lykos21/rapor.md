# G21 — Lykos şeridi: surun ardı 1453'teki gibi (iki dünyada)

Dal `wip/lykos21`, taban `wip/ist2-birlesik` a09a28ed (0.99.128). Testler `~/is/kopya`'dan (çalışma ağacının eşi),
taban ölçümleri `~/is/once`'den (tabanın eşi). Godot 4.4.1 resmi linux. Kareler 1280 × 720, gündüz, xvfb + opengl3.

## Özet (sahibine)

- **43o'nun gördüğü eski dünyada** surun ardındaki ikinci sıra evler Romanos–Pempton arasında kalktı; yerine bostan,
  bağ, yıkık kilise, boş meydan, ağaç kümeleri ve kopuk köy öbekleri (dağınık ev) geldi. Kare:
  `kare/sahip_1_43o_drone70_romanos_once_ust_sonra_alt.jpg` (üst önce, alt sonra). Surun dibindeki 65–120 m'lik artçı
  bandı (çadırlar, bostan, harabe) olduğu gibi duruyor; derinleşen kısım onun arkası.
- **Sur dibindeki "şehir öbeği" hâlâ duruyor**: o, uzak hub (`ByzCity.far_hub`, dünya x −16,5…53,5). Brif gereği
  dokunulmadı; **G22'de kalkacak**.
- **İstanbul v2'de** (Tolga'nın hub bölümleri, 7/11 uçuşu) Lykos şeridi baştan seyrek: sur dibine yaslı sıra ev yok,
  bostan/bağ/harabe/köy mahallesi/manastır/mezarlık mozaiği, 4 harap kilise, 5 boş meydan, çiftlik evleri.
  Kareler: `sahip_2_v2_serit70m_…`, `sahip_3_v2_harap_kilise_…`.
- Saray avlusu + kançılaryanın yeni yeri seçildi (`SurHub.SARAY_OFS`), v2'de kapıdan oraya yol var, alan boş meydan.

## Hedef maddeleri

| Madde | Durum | Not |
|---|---|---|
| 1. Şeridin sınırı, tek tanım | TAMAM | `IstGeo.serit_agirlik(t, d)` ortak; v2 `IstGeo.lykos_seridi(x, z)`, eski dünya `WallRear.in_serit(x, z, pay)` |
| 2a. `IstGeo.mahalle` şerit kuralı + mozaik | TAMAM | duvar bandından önce; 74 dünya m'lik Voronoi hücre; var olan tur + alt + `"serit": true` |
| 2b. Savunma yolu sıra evi kapalı | TAMAM | yol kalır (322 m şeritte); sıra ev yok, `maxrow 54` de kapalı |
| 2c. Boş meydan | TAMAM | v2'de 5 meydan (döşeme + kuyu/çeşme + 1–3 çiftlik/kulübe/sarmaşıklı duvar) + saray meydanı |
| 2d. Harap kilise | TAMAM | yeni kurucu `kiliseler_harap.gd` (IstKB dili); v2 şeridinde 4 tane; eski dünyada `WallRear._ruin` (15) |
| 2e. Kalabalık azalmaz | TAMAM | `TARGET["serit"] = 22`, `WEIGHT 0,6`; CITYCHECK 24: 14/16/16, 31o: 17/19/20 sivil (eşik 8, gevşetilmedi) |
| 2f. ISTBOS %0 | TAMAM | doku2 kayıt sayımı şehir içi 0/908; şerit 0/66 kare |
| 2g. Ev sayısı | KISMEN | 9156 → 8442 (9 binin altında; brif gereği zorla ev eklenmedi) |
| 3a. SARAY_OFS + `saray_v2()` | TAMAM | yalnız ekleme; SURSOZLESME aynı |
| 3b. v2 yolu + boş alan | TAMAM | `IstSokak._saray_yolu`: 263 m yol, alan 84 × 70 m'de ev 0 |
| 3c. Eski dünya yolu | YAPILMADI (bilerek) | D5: PLAZAS/MAIN'e dokunulmaz; eski dünya SARAY'ı G22'de (aşağıda ölçüm) |
| 3d. CityLife "lykos" pazarı | YAPILMADI (bilerek) | D5: ölü kod (`_temp_graph`), taşınmadı |
| 4. Eski dünya şeridi | TAMAM | CityPlan son-süzgeç + WallRear ayrı rng'li ek geçiş + SiegeField kilise dışlama + `sehir.gd:1117` |

## Şerit tanımı ve oranlar

- **Sınır (sur boyunca):** `t = 0` Romanos (gerçek −4836,7, 889,4), `t = 1` Pempton (−4199,1, 1822,6). Şerit
  `t ∈ [−0,265; 1,177]` (Romanos'un ~300 m güneyi – Pempton'un ~200 m kuzeyi; v2'de kara suru çizgisi boyunca iki kapı
  arası 1212 gerçek m), uçlarda `±0,035` yumuşak geçiş.
- **Derinlik:** iç surun şehir yüzünden `serit_derinlik(t) = 200 + 30 sin(6,3t + 0,5) + 20 sin(15,1t + 2,1)`, 150–250
  dünya m arasında dalgalı; kenarda ±14 m yumuşak. v2'de derinlik kara suru çizgisine uzaklık × S − 9 m (hub'ın iç yüzü
  çizgiden 3,3 m, kök 35,7 m; `lykos21_olc`). Eski dünyada `t = (37 − x) / 267`, derinlik `−2,3 − z`.
- **Mozaik (v2):** 74 dünya m (≈ 210 gerçek m) karmalı Voronoi hücreleri, tuz 33 (60 tuz denendi; alan oranı hedefe en
  yakın ve hub çevresi köy mahallesi). Alan oranları (24 m örnek, şeridin içi): köy mahallesi (seyrek 0,35) %37,
  bostan %27, harabe %13, bağ %8, mezarlık %8, manastır %7.
- **v2 şeridinin içi (önce → sonra; `lykos21_v2`, aynı şerit tanımı tabanda da sayıldı):**

| | önce | sonra |
|---|---|---|
| ev | 640 | 101 |
| avlu | 77 | 42 |
| doku yaması (bostan, bağ, bahçe, harabe, kilise…) | 2 | 21 (harap kilise 4*) |
| öğe (kuyu, ağıl, çiftlik, ağaç kümesi, şapel…) | 11 | 61 |
| meydan | 3 | 5 + saray alanı |
| sokak (m) | 4459 | 3565 (savunma 323, yol 960) |
| ISTBOS (40 m kare) | — | 0 / 66 |

  *Sondanın tür sayımı tek tek kayıt: harap kilise listesi 4 yer (`LYKOS21V2 yer tur=harap_kilise_hepsi`).
- **Eski dünya şeridi (43o, düz yol):** CityPlan şeritte 246 evden 41'ini köy öbeği olarak bıraktı (60 m'lik karmalı
  hücrelerin ~%36'sı, öbek içinde her iki evden biri), 205'i kalktı. WallRear ek geçişi: bostan 15, bağ/meyve 4, yıkık
  kilise 15, boş meydan 2, ağaç kümesi 248, tek ağaç/ot yığını 9 (`LYKOS21 eski_serit`). Surun ardındaki ayakta kutu
  kiliseler şeritte kurulmuyor.

## SARAY_OFS seçimi

- Ölçüm `tests/_ist/lykos21_olc.tscn` (hub yereli x −360…−420, z −120…+200, 10 m adım; 84 × 70 m alanda 9 × 8 örnek).
- Brifin örneği (−390, 0, −13): ortalama y 6,76, komşu örnekler arası en büyük eğim **%7,5**, düzlem eğimi %4,1,
  Lykos çizgisine **58 m** (alanın yarı köşegeni 55 m) — sınırda.
- Seçilen: **`SARAY_OFS = Vector3(−400, 0, 130)`** — Lykos vadisinin kuzey yamacı. v2 dünya (−1239,6; −295,7)
  (gerçek −3542, 845), arazi merkezde y 6,56, alanda ortalama 6,47; en büyük eğim **%2,9**, düzlem %2,1; Lykos çizgisine **84 m**; en yakın kayıtlı yer
  "Lykos vadisi" etiketi 233 m (anıt değil); Mokios sarnıcı ~1 km; şeridin dışında (iç yüzden ~430 m).
- Eski dünya karşılığı (byz_walls dönüşümü): x = 5,5 − 130 = **−124,5**, z = −36,3 − 400 = **−436,3**. Romanos
  yolu (ROAD, x −40 @ z −460) ~86 m doğuda, Pempton yolu ~144 m batıda. CityPlan.MARKETS (40, −470) ~168 m. G22 burada
  kısa bir bağlantı ve düzleme yapacak.
- `sokak.gd` `_build_imza`'ya `sur_set_hub.gd` ve `saray_v2()` eklendi: G22 SARAY_OFS'u değiştirirse önbellek yenilenir.

## Kalabalık

- `hayat_yakin.gd`: şerit hücreleri `_tur` → `"serit"`; TARGET 22 (sur dibi kadar), WEIGHT 0,6. Şeritte %34 iş başında
  (sur yakınında [< 70 m] işçi/nöbetçi, içeride işçi), %8 kenarda yıkayan/oturan; kalanı yürüyen/sohbet (keşiş, rahip,
  hamal havuzdan).
- CITYCHECK (gevşetilmeden, ayrı koşular): **24 PASS** hedef 19, sivil 14 / 16 / 16; **31o PASS** hedef 19, sivil
  17 / 19 / 20. Tabanda 24'te hedef 20 (D10).

## Değişen dosyalar (dosya:satır, taban a09a28ed'e göre)

- `scripts/world/ist/geo.gd:382-384` şerit kuralı (MAH_OZEL'den sonra, Mese/sur bandından önce); `:421-535` şerit:
  sabitler, `serit_derinlik`, `serit_td`, `lykos_seridi`, `serit_agirlik`, `_serit_ada`.
- `scripts/world/ist/sokak.gd:21` SurHub preload; `:461-462` imza; `:558-560` `_saray_yolu` çağrısı; `:640-702`
  `_saray_yolu`; `:926-929` `_serit`; `:1095-1096` şeritte patika aralığı; `:1167-1168` dolgu sokağı yok;
  `:1319-1338` savunma sıra evi kapalı, ev seyreltme, maxrow; `:1850-1870` boş meydan + harap kilise yeri; `:1926-1928`,
  `:1941-1942` harap kilise seçimi, çiftlik; `:1993-2049` `_yer_ara`, `_harap_kilise_yok`, `_serit_meydan`.
- `scripts/world/ist/hayat_yakin.gd:30-34` TARGET/WEIGHT; `:324-327` `_tur`; `:806-813` şerit rolleri.
- `scripts/world/ist/kiliseler.gd:12-13,47-48` harap kilise dalı (katalog ve IDS değişmedi).
- `scripts/world/ist/kiliseler_harap.gd` (yeni) harap kilise kurucusu.
- `scripts/world/ist/sehir.gd:1117` `in_serit`; `:3343-3346` harap kilise çizimi (k 0,75–1); `:3460-3461` uzak kütle.
- `scripts/world/ist/sur_set_hub.gd:149-161` YALNIZ ekleme: `SARAY_OFS`, `saray_v2()`.
- `scripts/world/wall_rear.gd:27-50` `serit_t/serit_derinlik/in_serit`; `:111` `_serit_fill` çağrısı (en sonda);
  `:689-690` serit kipinde `_rect_ok`; `:694-860` ek geçiş (`_serit_fill`, `_serit_tara`, `_serit_meydan`,
  `_agac_kumesi`, `_kucuk`). `depth()` ve `in_band()` DEĞİŞMEDİ.
- `scripts/world/city_plan.gd:419` son-süzgeç çağrısı (`_place_houses`'tan sonra); `:762-798` `_serit_suz`, `_karma`.
- `scripts/level/siege_field.gd:625-626` şeritte kutu kilise yok (rng çekimlerinden sonra).
- Yeni test/kanıt: `tests/_ist/lykos21_olc.*`, `lykos21_v2.*`, `lykos21_kare.*`, `lykos21_eski_liste.txt`,
  `lykos21_v2_liste.txt`.

## Testler

Çıktılar `testler/`. Sözleşme altılısı (sonra, kopyada):

```
SURSOZLESME PASS kalem=13 kesim=8
SUROYUN nokta=519 havada=0 gomuk=0 katida=0
WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0
ESYATEST PASS
HALICSONDA OZET carp=661 karma=3854034809
MARMARASONDA OZET carp=1837 karma=2250736444
```

- **Ayrıştırma** `parse_check`: PARSECHECK PASS scripts=370.
- **Bölüm testleri** (`--max-fps 20`, 300 sn bekçi, run_tests.sh süzgeci; `testler/bolum_testleri.txt`): **128 koşu,
  128 AUTOTEST PASS**; VISAUDIT, WALKTHRU, HELDAUDIT, GORUNMEZZEMIN, ALETAUDIT, DONUKAUDIT, ESYAAUDIT
  (dusme/havada/gomuk/tikama/sinir), YUKLEMEAUDIT_KESIN, SCRIPT ERROR satırı **0**.
  - Hub: 6 (=byz, =byzmistake, =byzfail, =byzclimb, =byzgive), 7 (=byz, =byzniko, =byzcell, =tea, =lost, =form, =wall,
    =wallkeep, =fez), 10h (7 çeşit), 12b (5), 13 =city, 23 (5 + =osm), 24 (5); 8y (7), 31o (4).
  - Ordugâh/eski dünya: 6 (varsayılan, =b, =c, =y, =letter: 6a yarısı), 7 varsayılan (7a uçuşu), 9 (12), 10 (7), 10b (6),
    10z (4), 11 (10), 13 (9 ordugâh/şehir dalı), 16 (3), 24o (6), 25 (=osm, =osm_caught, =osm_tez), 43o (4).
  - ×2: 24, 31o, 8y, 12b, 10h, 43o, 9, 7, 11 varsayılan çeşitleri ikişer kez (D25); kalanı ×1.
- **CITYCHECK** 24 PASS (14 / 16 / 16 sivil), 31o PASS (17 / 19 / 20) — eşik 8, gevşetilmedi.
- **STREETCHECK PASS** ((e) v2 kalabalığı IstHayatYakin). **FLIGHTCHECK PASS**, **WORLDCHECK PASS** (regions=13
  landmarks=35), **WALKCHECK PASS**, **MAPCHECK PASS**.
- **ZFIGHT**: 6, 7, 8y, 9, 10, 10b, 10z, 10h, 11, 12b, 13, 16, 23, 24, 24o, 25, 31o, 43o sahnelerinde 0 satır.
- **ISTBOS**: `doku2_kare` kayıt sayımı önce 0/907 → sonra 0/907 (şehir içi %0), Galata 0/10; şeridin kendi sayımı
  (`lykos21_v2`, aynı kural) 0/66. `gezi.tscn bos=1` geometri sayımı **koşulmadı** (yalnız pencereli; kare koşuları
  süreyi yedi) — KISMEN.
- **Ev sayısı** `ISTEVLER2`: önce ev=9156 doku=89 meydan=86 → sonra ev=8442 doku=113 meydan=92.
- **Yükleme süresi** (`load_time.tscn`, tek başına, ikişer koşu; ms, `testler/yukleme_suresi.txt`):

| bölüm | önce (1. / 2.) | sonra (1. / 2.) |
|---|---|---|
| chapter24 | 46326 (soğuk önbellek) / 36709 | 35370 / 35741 |
| chapter43o | 8610 / 8982 | 8636 / 7991 |

  Artış yok (43o'da CityPlan süzgeci + WallRear ek geçişi ölçülemeyecek kadar küçük). Önbellek: v2 sokak verisi geo/sokak
  md5'iyle yenilenir; "sonra" koşularından önce tek süreçle ısıtıldı (`lykos21_v2`).

## Hâlâ kötü olanlar (dürüst)

- **43o karesinde Romanos'un hemen ardındaki "şehir öbeği"** (uzak hub) duruyor; G22'de kalkacak. Sahibinin
  şikâyet ettiği "sur dibinde şehir" duygusunun en büyük parçası o.
- **Eski dünya şeridinde çıplak toprak hâlâ fazla**: CityPlan'ın sık sokak ağı (sokak, kenar ve ev payları noktaların
  ~%30'u) 12–18 m'lik bostanların çoğunu sokak aralarına sığdırmıyor; sığmayan yere ağaç kümesi (248) konuyor. 70 m'den
  bakışta bostan/harabe seçiliyor ama ağaç kümeleri küçük ve sisle eriyor. Bostanları küçültmek ya da sokak aralarını
  sokak yönüne hizalı doldurmak sonraki iş.
- **Pişmiş harita** `assets/ui/map1453.png` şeritteki kalkan evleri hâlâ gösteriyor (MAPCHECK yalnız suyu karşılaştırır;
  dosya bu görevin izninde değil). `tools/map_bake.gd` ile yeniden pişirilmeli.
- **Ev sayısı 8442** (sahibinin 0b hedefi 9–12 bin). Şeridin dışı değişmedi; düşüşün ~540'ı şeridin kendisi, kalanı
  tek sıralı rastgele sayının kaymasıyla şehrin başka yerlerinde.
- v2'de şeritteki doku yamalarının çoğu küçük (40 m'lik ızgara, ev/avlu arası); "küçülmüş şehir" okunuyor ama bostanlar
  tek tek büyük tarla gibi değil.
- Şeridin dışından ikinci "dolu şehir" göz hizası karesi (`disari_surdibi`) gezi koşusunda çıkmadı (sıra sonunda süre
  bitti); dışarının doluluğu `v2_disari_sik` ve 70 m karelerinin şerit dışı kısmında görülüyor.
