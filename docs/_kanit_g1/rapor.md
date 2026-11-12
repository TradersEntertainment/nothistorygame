# G1 — Bölüm 4a'nın gece ordugâhı tek haritada (rapor)

Dal: `wip/tekharita-g1` · taban kaydı `f375da92` · Godot 4.4.1, llvmpipe (yazılımla çizim), 1280×720.
Değişen dosyalar: `scripts/level/camp.gd`, `scripts/chapter4.gd` (1 yer), `scripts/world/world1453.gd` (yalnız ekleme).
`camp_day.gd` değişmedi (gerek kalmadı, aşağıda neden). Kanıt kareleri bu klasörde (`pafta*.jpg`).

## 1. Esir alanının yeri ve gerekçesi

Bölge `camp_pen`: `Transform3D(Basis(UP, π), (-110, -0.3, 240))` (world1453.gd:110). Yerel ↔ dünya: dünya =
(−110 − x, y − 0,3, 240 − z). Oynanış dikdörtgeni (keep) yerel `Rect2(-46,-24,92,80)` = dünya x −156…−64, z 184…264.

- **Ordugâhın ön kenarında**: dünyanın ordugâhı (SiegeField `_camp`, z 152…720) burada başlar; önünde z 121–170 bölükler ve
  topçu ordugâhı, 235 m önünde kara surları. Kapı (yerel +z, kaçış yolu) **surlara bakar**: oyuncu kapıdan surları ve
  şehrin siluetini görür. Yön CampDay ordugâhıyla aynı (yerel +z = dünya −z).
- **Otağa çok yakın değil**: otağ (30, 480) alanın ~280 m kuzeydoğusu; kapıdan çıkanın sağında-arkasında — tabeladaki
  "OTAĞ →" oku bu yöne doğru (eskiden de sağı gösteriyordu, metin değişmedi).
- **CampDay'in ızgarasıyla çakışmaz**: CampDay ızgarası dünya x −60…120, z 308…528; esir alanı x −156…−64, z 184…264.
  CampDay'in kendi çadır/ağaç dağıtımları (yarıçap ≤125/150 m, `Rect2(-300,55,600,300)` ağaç yasağı) bu dikdörtgene
  ulaşmıyor (hesap: en yakın çadır yarıçapı 198 m) → `camp_day.gd`'ye koşul **gerekmedi**; CampDay'in "camp" dünyasında
  alanı boş tutan `World1453.build`'in uzak bölge kaydı (aşağıda).
- **Arazi düz**: 92×80 m'de SiegeField.ground −0,90…+0,40 m (ortalama −0,22); bölge y −0,3. 4a'da BLEND 40 m ile düzlenir;
  öbür bölümlerde düzlenmez, uzak kurucu her parçayı dünyanın görünen yüzeyine oturtur.

## 2. Ne taşındı (dosya:işlev)

**camp.gd** (4a'nın yerel koordinatları, kazıklar, kapı, siperler, nöbetçiler, kaçış çizgisi, süreler AYNEN):
- `_ready`: kendi gökyüzü/sur/ufuk yerine `Night.environment` (dünyanın gece bölümlerinin ortamı; sis 0,014 → 0,007,
  surlar ve siluet seçilsin) + `_build_world` → `World1453.build(self, "camp_pen", [KEEP], true)` (gece kipi).
- Kaldırılan sahte dünya: 180×230 m kendi arazisi, `Scenery.camp` 260 çadır, 90 sahte ateş küresi, `Scenery.hills`,
  "ufukta surlar" (kutu sur + 18 kule + meşale küresi). Yerine dünyanın ordugâhı, surları, şehri.
- `_build_ground`: yalnız esir alanının çiğnenmiş zemini (`PATCH` 44×50 m, kenarı dünyanın çayır rengine döner) +
  oynanış alanı kadar çarpışma zemini; zemin ayrıntısı (`_ground_wear`) aynı, dışarıda dünyanın yüzeyine oturur.
- `_build_pen/_build_market/_build_gate`: aynı (yakın ayrıntı tam kalite). Kapı ateşi/meşale/kamp ateşi `_fire`.
- `_build_camp`: aynı rastgele dizi (34 çadır, 7 ateş ve başındaki 3'er kişi, 16 eşya yığını); bölge dışına (KEEP)
  taşan çadır konmaz (orası dünyanın çadır ızgarası); 25 çadır kalır. Kalabalık sayısı: ateş başı kişiler ve nöbetçiler aynı.
- `far_pen` (statik, `ByzCity.far_hub` kalıbı) + `_build_far`: aynı kurucular uzak sürümde: insan/ışık/yazı yok,
  her parça dünyanın arazisine oturur, `Props.bake_static` ile birleşik ağ (uzaklık ucu 1500 m), ateşler
  `Flame.scatter_flames/glows` (çoklu ağ; dünyanın gece/gündüz kipini izler: SiegeField `_night`).
- Performans (yalnız bölümün kendisinde; dünyanın dosyalarına dokunmadan, kurulduktan sonra):
  `_bake_near` (esir alanının durağan ayrıntısı aynı malzeme gruplarıyla birleşik ağ: görüntü aynı, yüzlerce çizim
  birkaç), `_occluders` (kazık çit örtücüsü), `_build_world` (dünya ilk kareden sonra, kart/karartma altında kurulur),
  `_thin_world`/`_range`/`_near_first` (gece sisinde: küçük parçalar 140 m, orta 450 m; ordugâh kalabalığı gölgesiz,
  tam model 70 m'de siluete, siluet 120 m'de biter; surdaki PoseCrew 200 m; çadır/ağaç katmanlarında örnekler
  uzaklığa göre sıralanıp 210 m içi çizilir; geniş ağlar ay gölgesine girmez).

**chapter4.gd:1047–1052** `_act_end`: kamp silinmez, gizlenip durdurulur (dünyanın sur arkası zamanlayıcıları silinmiş
düğüme dokunmasın: aksi hâlde 38 "Lambda capture … freed" satırı).

## 3. Ortak dosyaya eklenen satırlar (world1453.gd, yalnız ekleme; var olan imza değişmedi)

| Satır | Ne |
|---|---|
| 108–110 | `REGIONS["camp_pen"]` kaydı |
| 113–116 | `const FAR_REGIONS := {"camp_pen": Rect2(-46,-24,92,80)}` |
| 129 | `BLEND` sözlüğüne `"camp_pen": 40.0` girdisi |
| 235 | `build` içinde: `keep.append_array(far_keep(region_name, keep))` (flat_rects'ten SONRA: uzak alan düzlenmez) |
| 251 | `build` içinde: `build_far(f, region_name)` |
| 263–360 | yeni statik işlevler: `far_keep`, `build_far` (match: `"camp_pen": Camp.far_pen(...)`), `clear_rect` |

`clear_rect` gerekçesi: SiegeField `_camp` çadır/ağaç/ateş dağıtırken `keep`'e bakmıyor (siege_field.gd:1093 avoid
listesi). Ordugâhın içindeki bir dikdörtgeni boşaltmak için dünyanın kendi `WorldWalk.hide_inst` kuralıyla örnekleri
gizler, çarpışma şekillerini kapatır, Dressing ateş kutularının üçgenlerini atar; 0,8 m'den alçak yer örtüsü kalır.

## 4. "Aynı yer" çiftleri (sonda: `tests/_tmp/g1_sonda.gd`, geçici, depoya girmedi)

Aynı DÜNYA koordinatlarından serbest kamera; kare üstünde koordinatlar.
- `pafta07_ayni_yer_yerden.jpg`: (−110, 1.3, 226)'dan surlara (−110, 8, 0) ve otağa (30, 8, 480): 4a (gece) | 11 (gece,
  uçuş bölümünün dünyası) | 7a (gündüz).
- `pafta08_ayni_yer_havadan.jpg`: (−80, 40, 200)'den alana (−110, 0, 243): 4a | 11 | 7a.
- `pafta09_ayni_yer_uzak.jpg`: (0, 160, 40)'tan (Romanos kapısının üstü) alana.
Sonuç: kazık çit, esir çadırı, tezgâhların renkli tenteleri, sandıklar, atlar, çevredeki çadırların yeri ve dünyanın
çadır dizilişi üç bölümde aynı. Fark (beklenen): uzak sürümde insanlar ve ışıklar yok; 11'de ateşler yanar, 7a'da
(gündüz) yanmaz.

## 5. ÖNCE|SONRA (aynı koşu, aynı replik anı; ÖNCE = `f375da92` ayrı çalışma kopyasında)

`pafta01`…`pafta05`: açılış (D4A_T_01), nöbetçi (D4A_T_04, D4A_HA_END), kaçış (D4A_T_END1, D4A_T_OTAG), yakalanma
(`caught`: D4A_HU_CAUGHT, D4A_K_DISHES), Perde I kapanışı. `pafta06`: aynı kamera pozlarında (sonda) ÖNCE|SONRA.

## 6. RINFO ve yükleme

**a) Aynı kamera pozu, üçer örnek** (sonda pozları, oyuncu kamerası, HUD gizli; ÖNCE `poz/once`, SONRA `poz/sonra_son3`;
kaynak: `RenderingServer` çizim/üçgen, `Viewport` vis/shadow). Sınır: çizim ≤ max(900, ÖNCE×1,1); üçgen ≤ max(2,5 M, ÖNCE×1,1).

| Evre (poz, yerel) | ÖNCE çizim | SONRA çizim | Sınır | ÖNCE üçgen (k) | SONRA üçgen (k) | Sınır | Durum |
|---|---|---|---|---|---|---|---|
| açılış (−3.7,0,−3.4) | 1270 / 1274 / 741 | 706 / 706 / 365 | 1401 | 1698 / 1697 / 974 | 1949 / 1950 / 1023 | 2500 | geçer |
| nöbetçi (−2.2,0,1.3) | 2888 ×3 | 1968 / 1552 / 1557 | 3177 | 2173 ×3 | 4247 / 2453 / 2453 | 2500 | çizim geçer; üçgen ilk örnekte 4,2 M (tek karelik sıçrama, sonraki ikisi 2,45 M) |
| yakalanma (0,0,4.2) | 2247 ×3 | 1744 / 1744 / 1741 | 2472 | 1797 ×3 | 2540 / 2539 / 2537 | 2500 | çizim geçer; üçgen **+%1,6 AŞIYOR** |
| kaçış (0,0,10.5) | 1800 / 1800 / 1802 | 1978 / 1970 / 1971 | 1980 | 1843 ×3 | 2793 / 2792 / 2792 | 2500 | çizim sınırda geçer; üçgen **+%12 AŞIYOR** |
| otağ tabelası (2.4,0,11) | 1630 ×3 | 1671 / 1671 / 1665 | 1793 | 1812 ×3 | 2599 / 2599 / 2598 | 2500 | çizim geçer; üçgen **+%4 AŞIYOR** |
| surlara bakış (0,0,11) | 1785 ×3 | 1957 / 1958 / 1959 | 1964 | 1856 ×3 | 2792 / 2791 / 2792 | 2500 | çizim sınırda geçer; üçgen **+%12 AŞIYOR** |

Gölge geçişi her evrede ÖNCE'nin altında (ör. kaçış 941k → 649k, açılış 470k → 131k).

**b) Oynanış koşusu (`--autotest`, ekranlı, `--hitchaudit`, RINFO 2 sn'de bir; replik anına hizalı)**

| An | ÖNCE çizim / üçgen | SONRA çizim / üçgen |
|---|---|---|
| D4A_T_01 öncesi (çadır önü) | 1169 / 871k · 1111 / 977k | 593 / 1024k · 692 / 998k |
| D4A_T_03–T_04 (sinsice) | 3403 / 1953k · 3337 / 1954k | 2282 / 2502k |
| D4A_HA_END–T_OTAG (kaçış) | 2091 / 1037k · 2084 / 1612k · 1875 / 1842k | 838 / 1242k · 2094 / 2467k · 1929 / 2621k |
| caught: D4A_HA_STOP…HU_TO_KITCHEN | 3058–3511 / 2.00–2.30M | 1822–2289 / 2.53–2.61M |
| Perde kapanışı | 770–943 / 214–219k | 761–934 / 213–218k |

**c) Yükleme** (sonda: sahne değişiminden ilk çizilen kareye; `WORLDMS`: dünyanın kurulduğu kare)

| | ÖNCE | SONRA |
|---|---|---|
| sahne açılışı → ilk kare | 3580 ms | 2295 ms (2100–2360, 6 koşu) |
| → dünya hazır | — (dünya yok) | 9296 ms (9218–10165) |

Dünya ilk kareden sonra, bölüm kartı ve karartma ekrandayken tek karede kuruluyor (World1453.build/SiegeField.build
eşzamanlı; ~7 sn). İlk kare +1,5 sn sınırının içinde; ancak oyuncu kartı ~6 sn daha uzun görür: **AÇIK** (bkz. §8).

## 7. Testler (son kod; başsız `--max-fps 20`)

- `parse_check` PASS (247 betik) · `world_check` PASS (regions=14 landmarks=35) · `city_check` PASS · `flight_check` PASS.
- Bölüm 4: `""`, `item`, `caught`, `market`, `chain`, `nofez`, `fall`, `fez`, `wet`, `next` → **10/10 PASS**.
- 6 (`""`, `byz`), 7 (`""`, tea, lost, form, wall, wallkeep, byz, byzniko, byzcell, fez), 9, 10, 11 (`""`, arrest, escape,
  persuade, help, helpwall, lost, fired, hikmet, niko), 16, 24o, 43o → **27/27 PASS**.
- Yasaklı satırlar (SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT,
  HELDAUDIT, JOURNEY_MISS, JOURNEY_OVERLAP): hiçbir koşuda **0**.
- Diğer hata satırları (aynen):
  - Bölüm 4 `next`: `ERROR: Lambda capture at index 0 was freed. Passed "null" instead.` ×4 (bölüm 5'e geçişte; dünyanın
    `rear_life.gd:292/635/646/714` zamanlayıcıları). **Taban ch4'te de var**: `""` ×6, `next` ×9 (f375da92, aynı komut).
    SONRA `""` ×0.
  - Bütün koşularda çıkışta `ERROR: Pages in use exist at exit in PagedAllocator: N7Variant5Pools12BucketMediumE`
    (tabanda da var).
  - 10, 11, 16 vb.'de çıkışta bir ek satır: `ERROR: 1 resources still in use at exit (run with --verbose for details).`
    Tabanda (10, 11 lost, 16) yok → yeni; çıkış sızıntısı, oyun sırasında etkisi yok; kaynağı **BAKILMADI**.
- Bir ara sürümde `get_meta("crowd_twin", null)` her çoklu ağ için hata basıyordu (ch4'te ~15 bin satır); düzeltildi
  (`has_meta`), son koşularda yok.

## 8. Açık kalanlar ve öneriler

1. **Üçgen bütçesi** dış evrelerde 2,54–2,79 M (sınır 2,5 M; +%2…+%12). Çizim her evrede sınırda/altında. Kalan yük
   dünyanın çadır katmanları (Scenery.camp: her biri bütün ordugâhı kaplayan tek çoklu ağ) ve yakın kalabalık. Öneri
   (siege_field.gd/scenery.gd, P0): `Scenery.camp` çadırlarını Crowd gibi 64–128 m hücrelere bölüp hücre başına
   `visibility_range_end` (uzak hücrede alçak çadır ağı) → uzak ordugâh her bölümde ucuzlar.
2. **Yükleme**: dünya ~7 sn tek karede kuruluyor. Öneri (siege_field.gd): `_step` yalnız `lite`'ta bekliyor;
   `if (lite or spread) and is_inside_tree(): await get_tree().process_frame` ve `World1453.build` `f.spread = true`
   → kurulum karelere yayılır (WorldWalk 12 ms kalıbı).
3. **keep ve dağıtım**: SiegeField `_camp` (siege_field.gd:1093) çadır/ağaç/ateşi `keep`'e bakmadan dağıtıyor; bu yüzden
   `World1453.clear_rect` eklendi. Öneri: `_camp`'ın `avoid` listesine `keep` eklenirse `clear_rect`'e gerek kalmaz.
4. **Havadan koyu kare**: dünya `keep` içine çim/zemin ayrıntısı koymadığı için esir alanının 92×80 m dikdörtgeni havadan
   çevresinden koyu görünüyor (pafta08; 4a, 11, 7a'da aynı). Çiğnenmiş alan gibi okunuyor; istenirse uzak keep yalnız çit
   + 10 m'ye daraltılabilir (çadırları `clear_rect` zaten boşaltıyor). **AÇIK**.
5. **4a → 4b**: oyunda geçiş yok: 4a ve 4b Bölüm 2'nin sonucuna göre **ayrı dallar** (chapter4.gd:90). Yön/mesafe: esir
   alanı (−110, 240) surların dışında, ordugâhta; 4b'nin rıhtımı ("horn_chain", −700, −1600) Haliç ağzında, ~1,9 km
   kuzeybatıda, surların içinde. Tutarsızlık: Bölüm 4'te `SeaWalls` `in_world` açılmıyor (chapter4.gd:99; 17/19/29'da
   açılıyor) → 4b kendi sahte dünyasında; tek_harita.md §A'daki "4b … horn_chain EVET" bu bölüm için doğru değil.
   Yalnız raporlandı (dosya bu paketin dışında değil ama görev "yalnız raporla" diyor).
6. **Perde I kapanışı** (chapter4.gd `_act_end`, `_vista_city`): Nihat'ın tepesi ve karşıdaki şehir hâlâ kendi çizimi
   (dünyada bir yere bağlı değil). Öneri: tepe Maltepe sırtında (ör. dünya (−60, 18, 420)), bakış esir alanına ve
   surlara; kurulum `World1453.build(vista, "camp_pen", ...)` yerine bölgenin dünyasını gizleyip yeniden göstermek.
7. **Mini harita**: dünya MapView grubuna katıldığından 4a'da sağ altta mini harita beliriyor (pafta01–04). Öbür dünya
   bölümleriyle aynı davranış; istenmiyorsa bölüm bazında kapatılmalı.
8. **Uzak ateşler kutu**: dünyanın ordugâh ateşleri hâlâ `Dressing.glow` kutusu (tek_harita.md §E.1);
   `Flame.from_glow_boxes` bu dalda yok, kullanılamadı.
9. Ortak arayüz (§F: `World1453.bake`, `FAR_REGIONS` işleyişi, `Flame.from_glow_boxes`) bu dalda yoktu: `FAR_REGIONS`,
   `far_keep`, `build_far`, `clear_rect` bu dalda §F'deki biçime uygun olarak eklendi; birleşik ağ için var olan
   `Props.bake_static` kullanıldı. Ana makinedeki P0 gelince `build` içindeki iki satır (235, 251) onun karşılığıyla
   değiştirilmeli; `REGIONS`/`FAR_REGIONS` kaydı ve `"camp_pen": Camp.far_pen(...)` satırı aynen kalır.

## Kanıt dosyaları

`pafta01_acilis` · `pafta02_nobetci` · `pafta03_kacis` · `pafta04_yakalanma` · `pafta05_perde_kapanis` ·
`pafta06_poz_once_sonra` · `pafta07_ayni_yer_yerden` · `pafta08_ayni_yer_havadan` · `pafta09_ayni_yer_uzak`.
Sonda (`tests/_tmp/g1_sonda.gd`) ve koşu betikleri depoya girmedi (iş bitince silindi).
