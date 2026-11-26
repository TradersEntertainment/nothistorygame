# G23 — Eski dünyanın kara surları yeni kalemle: envanter ve plan

Taban `dd0f6dd1` (0.99.129), dal `wip/sur23`.

## 1. Eski dünyada kara surunu kuran yollar (kodla)

| Yol | Ne kurar | Nerede |
|---|---|---|
| `SiegeField._wall_extension()` (siege_field.gd:412) | kutu iç sur (z −2,3, 3,4 kalın, 12 yüksek), kutu dış sur (z 15, 2 kalın, 8), kutu kuleler (55 m), korkuluk kutusu z 19,15, kutu hendek z 20–36 (dip −3), peribolos/set zemin kutuları, dişler (MultiMesh), sancak, yara, savunan, nöbet ateşi | `world = true` + `fill_center` (World1453.build) → x −580…700, ortası dâhil (a0 = 0) |
| `SiegeField._gates()` (293) | 7 kapı: kutu kule çiftleri, kemer kutuları, kanat, eşik, hendekte dolgu geçit kutusu | `World1453.LAND_GATES` |
| `SiegeField._ditch_ramps()` (333) | ~80 m'de bir hendek rampası (kama) | aynı |
| `ByzCity.far_hub()` (byz_city.gd:355) → `_kur_bolunmus` → `_build_walls()` (2004) + `_build_gate()` | hub'ın kutu iç suru (yerel x 34 → dünya z −2,3; dünya x −16,5…53,5), 6 kutu kule, süslü kapı (EXIT_POS, dünya x 0), mazgallar; FarHub/FarHubLo'ya pişer, FarHubBody'ye çarpışma | hub'ı kurmayan her eski dünya bölümü (FAR_REGIONS) |
| `HornWorld._blachernae()` (horn_world.gd:856) | kuzey uç: x −702…−578 levha, FarBlachernae (birleşik kule kabukları), kutu Haliç inişi | `world = true` (30/30o dışında da) |
| `Blachernae._join_tower()` (blachernae.gd:255) | 30/30o: köşe kuleleri (yeni BLAK kalemi), x −578 = yerel 62 | 30, 30o |
| `Landmarks1453._golden_gate()` (landmarks1453.gd:510) | Altın Kapı kutu mermer pilonları (x 650, z −9,7) | eski dünya |
| `WallRear` (wall_rear.gd) | sur ardı; `_wall_details`/`_oil_posts`/`_stockade` sura oturur (WALK_Y 8, WALK_Z 14,9; barikat x 1…19, z 15) | `active` + `fill_center` |
| `LandWalls` + `SiegeField` (`fill_center = false`, x ±50 dışı) | eski set | `--eskisur`, arena, ana menü: **KAPSAM DIŞI (K3/K6)** |

`sur_yeni = true` (SurSetSahne) ve IstBaglama (v2: 7, 11, hub 6b/10h/12b/13 şehir/23/24, 8y, 31o v2 evresi) bu yolları KURMAZ.

## 2. Eski dünyayı kuran bölümler (World1453.build → SiegeField, v2 dışı)

`grep "World1453.build|surround|<Kurucu>.new()" scripts/chapter*.gd` ile:

| Bölge | Kurucu | Bölümler | Sur kameraya |
|---|---|---|---|
| camp | CampDay | 6a (6, ordugâh), 9, 10, 10b, 10z, 13 (ordugâh dalı), 16, 24o, 25 (ordugâh evresi), 43o | ordugâhtan 400 m+; 43o drone alçak uçuş (sura 20–60 m), Sultan VIEW1–3 |
| blachernae | Blachernae | 30, 30o | **göz hizası**: kuzey uç x −580 oynanış alanında |
| byz_aya | ByzCity "aya" | 25 (şehir evresi), 26 (Ayasofya evresi), 44b, 31o (eski evre) | şehrin içinden 1,4 km+ |
| petrion | Petrion | 39o | 650 m+ (Haliç kıyısı) |
| horn_bridge | chapter18/18b | 18, 18b | köprüden ~150 m (kuzey uç) |
| horn_wall_o | chapter38o | 38o | 560 m+ |
| eyup | chapter31o | 31o Eyüp evresi | 250 m+ (kuzey uç, ova tarafı) |
| horn_chain | SeaWalls | 4, 17, 19, 19o, 29, 29o | 1,5 km+ |
| galata / springs / slipway | Galata, 17o, Slipway | 10g, 13 (Galata dalı), 27, 17o, 2 | 1,2 km+ (Haliç karşısı) |
| gate8y | 8y | yalnız `--eskisur=8y` | (K6: eski kalır) |

Kesin liste ve her bölümdeki kutu sur düğümleri sonda ile `docs/_kanit_sur23/envanter_sonda.txt`'ye yazılır.

## 3. Yaklaşım

Yeni dosya `scripts/world/ist/eski_sur.gd` (class_name yok; `preload`). SiegeField `world = true`, `fill_center`,
`--eskisur`/bölüm listede değil → `_wall_extension` yerine `EskiSur.kur(field)`:

- **Kesit (K1):** kalemin yereli dönüşsüz, kesim z 0 → dünya z −1,3 (iç surun şehir yüzü −3,8 = SurHub hizası, hub x 32,5),
  dy 0. İç sur −3,8…1,2 (HW 12), peribolos 15, dış sur 16,2…18,8 (OH 8,5). Teras ve hendek seçmeli (`o["ptw"]`,
  `o["mw"]`; `_layout`'ta yalnız verilince): teras 7, hendek 9 × 6; hendeğin uzak yakası z 35,7 (< 36). `ova_ofs` yok.
- **Dilimler:** x −578…700 düz hat; 7 kapı dilimi (kalemin kapı seçenekleriyle, aynı tohum `1000 + id.hash() % 997`;
  K2: `kapali = false`, `gw ≥ 7` seçmeli kopya, hendek köprüsü yıkığı yerine dolgu geçit) + aradaki ~110 m sur dilimleri.
  Kök adı `SurOyun_eski` (v2 görünüşü ve `sur_doku` gölgelendiricisi; iki kalem olmaz).
- **Uzaklık katmanları (K4/D13):** lod 0 yalnız oynanabilir kameraya ≤ 300 m dilimlerde (bölge keep'ine ve bölüm
  kamerasına göre); öteki dilimler lod 1 (kutu yok, korkuluk/diş silueti) pişmiş; lod 2 yalnız > 300 m'de.
- **Çarpışma (D12):** her dilim (lod'dan bağımsız) tek sade çarpışma: sur, kule, hendek yakaları ve dibi, kapı geçidi,
  rampalar (kalemin `carp_only` kutuları); görseller `no_walk`.
- **Uçlar:** kuzey x −578 Blakherna köşe kulesinin ortasında biter (iç sur kuleye girer; dış sur ve hendek uç bölmesiyle
  kapanır); güney x 700 Marmara kıyısında.
- **Hub (D9):** `ByzCity.far_hub` seçmeli bayrakla (`eski_yeni`) kutu iç suru, kuleleri, mazgalları ve süslü kapıyı
  kurmaz; döşeme iç surun şehir yüzünde biter (yeni hub kipindeki gibi). İç suru SiegeField kesintisiz kurar.
  `_inner_spans` yalnız bölümün KENDİ keep'ini keser (FAR_REGIONS ayrı tutulur).
- **Kapılar (K2):** 7 kapı açık; Altın Kapı ve Ksylokerkos için seçmeli açık kopya. `Landmarks1453._golden_gate`
  yeni kalem kurulunca kurulmaz.
- **Lykos (K5):** dış surda x 1…19 tek açıklık (`gedik_ac` seçmeli); barikat yeni dış sur yüzüne oturur.
- **Rng (D11):** eski `_wall_extension` döngüsü "kuru çekim" olarak aynı sırayla çalışır (kutu kurmadan); savunanlar,
  sancak, ateşler aynı rng çekimleriyle yeni yüksekliklere/z'lere oturur.
- **Sur üstündekiler (D10):** savunanlar dış sur yolu (y 8,5, z 17,5) ve iç sur yolu (y 12, z −1,3); WallRear WALK_Y/Z
  aynı kaynaktan; DroneDefense iç/dış sur ışınları 419,3/400,5; 43o `WALLS_AT` z değeri yeni dış sur.
- **Harita (D14):** `tools/map_bake.gd` yeni z'lerle, harita yeniden pişer.

### Yürüyen/çarpışan parçalar

7 kapı geçidi (iç + dış sur açıklığı, parateikhion geçidi, hendekte dolgu), dilim başına 2 hendek rampası
(yakın ve uzak yaka), iç surun şehir yüzünde taş merdiven, peribolostan dış sura merdiven, dış kule tepe basamakları,
Lykos açıklığı ve barikat. Bugün de yürünen: kapı geçitleri, hendek (rampa), sur önü (teras/ova).

### Ek dosya gerekçeleri

- `scripts/level/wall_rear.gd`: izinli (sur birleşmesi, sur üstü oturtma).
- `scripts/world/ist/surlar.gd`: seçmeli anahtarlar (`ptw`, `mw`, `kopru_yok`, `gedik_ac`); varsayılan aynı.
- `scripts/level/drone_defense.gd`, `scripts/chapter43o.gd`: yalnız sur hizası sabitleri.
- Testler `tests/_ist/sur23_*`.
