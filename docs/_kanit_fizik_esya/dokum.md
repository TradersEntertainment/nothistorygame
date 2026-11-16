# Eşya fiziği — döküm (ölç ve dök)

Taban `wip/fizik-taban4` 9af74b12. Envanter: kurucuların bütün çağrı yerleri tarandı (grep + okuma), sayılar bölüm
koşularındaki `ESYAAUDIT OZET kayit=` satırından (kayda geçen dekor eşyası).

## Kurucular: ne kuruyor, nasıl çiziliyor, çarpışması

| Kurucu | Ne | Çizim | Çarpışma | Karar |
|---|---|---|---|---|
| `dressing.gd crate()` (Kit varken) | Crate_Wooden modeli | **MultiMesh** (Kit.batch, ad başına parça başına bir MMI) | tek başına yok; `crates()` grubun kaplamı kadar ortak kutu | **KAYIT** (`sandik`) |
| `dressing.gd barrel()` (dik, Kit varken) | Barrel / Barrel_Apples modeli | **MultiMesh** | tek başına yok; `barrels()` ortak kutu 1,8×0,9×0,9 | **KAYIT** (`fici`) |
| `dressing.gd barrel(tip=true)` | yatık fıçı | birleşik Dressing ağı (köşe renkli, ayrılamaz) | `barrels()` ortak kutusu | **ENGEL kaydı** (uyanmaz; ortak kutu açılınca kendi kutusu) |
| `dressing.gd crates()/barrels()` | yığın / küme | yukarıdakiler | ortak kutu (grubun kaplamı) | uyanan eşyayla kesişen ortak kutu kapanır, gruptaki uyuyanlara ve engellere kendi kutuları verilir |
| `surlar_ayrinti._barrel` (satır 127 kule önü, 358 `_stauroma` sur yolu) | toprak dolu fıçı | **tek düğüm** MeshInstance3D (TUR-10 karınlı ağ) — normalde `Props.bake_static` ile birleşik ağa katılıyordu | `Props.make_solid` dışbükey kabuk (daraltılmış) | **KAYIT** (`fici`); kayıtlı olana `no_bake` (birleşik ağa katılırsa tek başına uyanamaz) |
| `surlar._gedik` (surlar.gd:989) | gedik önü stauroma fıçıları | tek düğüm | dışbükey | **OYNANIŞ — kayıt YOK** (gedik barikatı) |
| `sur_oyun_parca.gd:613` GedikOnarim aşama 2+ | gedik fıçıları | tek düğüm | dışbükey | **OYNANIŞ — kayıt YOK** (GedikOnarim, sur sözleşmesi) |
| `halic_kit.barrel_stack` ("FicStack") | fıçı yığını | tek düğümler + blok | blok (tırmanılır) | **OYNANIŞ — kayıt YOK** |
| `halic_kit.crate_steps`, `kuzeybati_ortak.crate_steps`, `guneybati_kit.crates`, `galata_ortak.crates` | sandık basamakları | blok | blok | **OYNANIŞ — kayıt YOK** (yol, `add_climb`) |
| `halic_kit.barrel`, `galata_ortak.crates` | — | — | — | hiç çağrılmıyor |
| `kemer_kit.barrel` | **beşik tonoz** (mimari, fıçı değil) | — | — | kapsam dışı |
| `sur_set_sahne._build_depot` / `land_walls` DEPOT | fıçı/kalas istifi, `pile_barrel` etkileşimi | tek düğümler | blok | **OYNANIŞ — kayıt YOK** (taşıma görevi kaynağı) |
| `land_walls.gd:470` barikat aşamaları | barikat fıçıları | — | — | **OYNANIŞ — kayıt YOK** |
| Bölüm 22 `_powder_barrel` | barut fıçıları | — | — | **OYNANIŞ — kayıt YOK** (oluktan bırakılır, görev) |
| Bölüm 18 `"Barrels"`, `"BarrelRoll"`, köprü kalasları | köprü dubaları, yuvarlanan fıçı | — | — | **OYNANIŞ — kayıt YOK** |
| Bölüm 29 interactable "barrel" | güverte | — | — | **OYNANIŞ — kayıt YOK** |
| Bölüm 18:114-158, siege_field barut çadırı, camp_day mutfak (`Props.model("barrel")`) | `dd.cyl` ile çizilmiş fıçılar / tek .glb | birleşik ağ / tek düğüm | ortak kutu / solid_model | **kayıt YOK** (birleşik ağdaki parça tek başına gizlenemez; kurucu listemde değil) — "kalanlar" |
| `amphora`, `basket`, `sack(s)`, `pots`, `bench` (Dressing) | testi, sepet, çuval, saksı, sıra | birleşik ağ | ortak kutu | **kayıt YOK** (yetki yalnız crate/crates/barrel/barrels; birleşik ağda ayrılamaz) — "kalanlar" |

Oynanış eşyasının hiçbiri kayda geçmez (kayıt yalnız dekor kurucularında). Uyanan dekor eşyası bir etkileşim alanının
(`Props.interactable`, katman 2: kapı, merdiven, yük yığını, görev yeri) üstünde donarsa alanın dışına itilir. (İlk sürümde
oynanış düğümlerini adlarıyla bütün ağaçta arıyordum: sahne başında 235 ms'lik kare; kaldırıldı.)

## Bölümler: kayda geçen dekor eşyası (oyuncunun yanına gidebildiği küçük eşyalar)

| Bölüm | Dünya kurucusu | Kayıt (koşu) | Nerede | Not |
|---|---|---|---|---|
| 0 | SurSetSahne (SurOyun + SiegeField) | 69 | sur yolu stauroma fıçıları (uzak) | Savrulanlar (kalkan, ok demeti, askerler) zaman durdurmasının donmuş karesinde KASITLI havada; dünya hiç devam etmiyor (geri sarılıp garaja dönülüyor) → fizik verilmedi |
| 6 (6a) | CampDay `auto("camp")` | 102 | ordugâh kenar kümeleri (sandık, fıçı) | mutfak fıçıları `Props.model` → kayıt yok |
| 6 (6b) | ByzCity `auto("byz")` + payanda dibi | 214 | şehir kenar kümeleri | |
| 8y | World1453 "gate8y" + kendi barikatları | 104 | World1453 rıhtım/depo kümeleri | kendi Dressing'inde fıçı/sandık yok (gabion, perde = oynanış) |
| 17o | World1453 + kendi Dressing `_c_crates/_c_barrels/_c_barrel_pile` | 130 | kenar donatısı | |
| 18, 18b | World1453 "horn_bridge" + kendi Dressing | 96 | World1453 kümeleri (oyun alanından yüzlerce m uzakta) | bölümün kendi fıçıları `dd.cyl` (birleşik) → kayıt yok |
| 20 | SurSetSahne | 85 | 16 ordugâh (siege_field kampı, z≈150) + ~69 sur yolu stauroma fıçısı (dış sur yolu, y≈8,6) | gedik ve depo fıçıları oynanış → kayıt yok |
| 26 | LandWalls + SiegeField | 96 (varsayılan çeşitte 233: World1453 de kuruluyor) | sur içi meydan kümeleri (ör. 9,0.4,−49), ordugâh | barikat ve depo oynanış → kayıt yok |
| 28o | SurSetSahne | 89 | Bölüm 20 ile aynı (ordugâh + sur yolu) | |
| 29 | SeaWalls | 96 | | güverte fıçısı oynanış |

## Düşen / atılan eşya yerleri (madde 4)

| Yer | Ne | Karar |
|---|---|---|
| Bölüm 20 `_fall_load` (top oyuncuyu devirince elden fırlayan yük: fıçı/kalas/toprak) | düz `global_position:y` tween'i | **GÖVDEYE ÇEVRİLDİ** (`EsyaFizik.dusur`; süreler, ses, 3 sn sonra silinme aynı) |
| Bölüm 6 `_scatter_chickpeas` (elden atılan leblebi) | iki parçalı yay tween'i | **GÖVDEYE ÇEVRİLDİ** (`tane`: aynı yere aynı sürede atılır, seker, yuvarlanır; 6,4 sn sonra silinme aynı) |
| Bölüm 0 patlama donma karesi (kalkan, ok demeti, askerler) | donmuş karede elle konum | **DOKUNULMADI**: zaman durdurma şakası; dünya devam etmiyor |
| `battle_extras.gd:520` düşen askerin kalkanı | tween | **İSTEK** (dosya bende değil) |
| Bölüm 22 barut fıçısı oluktan | görev yolu tween'i | **DOKUNULMADI** (oynanış, görev zamanlaması) |
| Bölüm 18 köprü kalasları | görev | **DOKUNULMADI** (oynanış) |
| Bölüm 29 taş atma, assault.gd mancınık taşı | elle balistik | **DOKUNULMADI** (oynanış/kişiye isabet hesabı) |
| Bölüm 26 kâğıtlar, taş kırıntıları, Bölüm 44b batan levha/varil | süzülme / batma | kapsam dışı (kâğıt süzülür, su) |
