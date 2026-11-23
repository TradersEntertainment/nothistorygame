# TAŞIMA 12 — 8y "havada asker" + surun fonda göründüğü bölümler — rapor

Dal `wip/ist2-tasima12`, taban `wip/ist2-taban19` = **a38ad405**. ESKİ = aynı kod `--eskisur=<bölüm>` ile, YENİ = anahtarsız.
Godot 4.4.1 resmi (`~/is/godot`); testler `--max-fps 20`, tam süzgeç (k.sh), 4 süreç aynı anda; kareler xvfb + llvmpipe,
1280×720 jpg 85, hepsine TAM BOY bakıldı (arayüz katmanları çekimde gizli). Kare aracı `tests/_ist/tasima12_kare.tscn`
(Taşıma 10'unkinin üstüne). Klasörler: `kare/<bölüm>/eski|yeni/`, `testler/bolum/` (süzülmüş koşu satırları),
`testler/gunluk_8y_*` (8y kök neden günlüğü), `testler/kare_butce_1.txt`, `testler/uzak_hub.txt`, `durum.md`.

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 0 | **8y havada asker** | **TAMAM** | Kök neden ızgara DEĞİL: `Stage.station`'ın `plant_feet` döngüsü çömelme pozunda kökü 0,18 m kaldırıyordu (iki sette de). Düzeltildi; geçici anahtar kalktı: 8y varsayılan YENİ, `--eskisur=8y` eski. 8y ×3 (24 koşu) + `=yuru` PASS, denetim 0 |
| 1 | **13, 23, 24** | **TAMAM** | `SurHub.BOLUMLER` += 13, 23, 24; `IstBaglama.TOLGA` += 13; üçü v2'de yeni surla (`ISTBAGLAMA bolge=byz_walls … SURHUB kur`). 24'te Ayasofya yarısından önce `IstBaglama.birak()`. Kareler 5'er (cadde, kapı, ufuk, iç mekân, tepeden) |
| 2 | **Uzak hub** | **TAMAM** | v2'de (7a, 11 uçuşu) uzak hub `SurHub.hub_v2`'de (oynanan hub'la aynı yer ve yön: ölçüldü, yaw 161,9), kutu iç sur/kuleler/Romanos kemeri KURULMUYOR (v2'nin kendi dilimleri). Eski dünyada (`World1453 far_hub`) değişmedi (orada bütün kara suru eski) |
| 3 | **31o** | **TAMAM** | `SurSetSahne` (Mesoteikhion, `romanos_kanat`), `open_inner_gate`; ev evresi ve kare kipi tek işlevden (`_sur_kur`); cadde Romanos iç kapısının şehir yanında. 4 çeşit ×2 + eski PASS. 4 kare (biri kapı 1,5–2,5 m) |
| 4 | **41o, 42b** | **TAMAM** | 41o gedikli kip (onarım 3), meydan `YARD_AT + ova_ofs`; 42b SAĞLAM kip, meydan `YARD_AT + sehir_ofs(0)` (kesimin engelleriyle çakışma 0, ölçüldü). ×2 + eski PASS; 2'şer kare |
| 5 | **21o, 17o** | **TAMAM (ölçüm)** | 21o: `LandWalls`/`World1453`/sur yok (kod taraması boş, kare: tünel) → **taşınacak bir şey yok**. 17o: karşı kıyıda eski kutu şehir surları (`Scenery.city_walls` + eski dünya `springs`) → "görünüşe istek" |
| 6 | **10h moloz** | **TAMAM** | Yeni dalda soluk yuvarlak toplar yerine tek ağ: köşeli koyu taş (80), tuğla kırığı (34), toz lekesi; `--eskisur=10h` kodu satır satır aynı (eski dal dokunulmadı) |
| — | Sözleşme | bkz. "Doğrulama" | |

## 0. 8y kök neden (DÜZELTMELER 1–3)

**Günlük** (`chapter8y.gd _t12_ayak_gunluk`, o askerin ayağının altındaki BÜTÜN çarpışma yüzeyleri; `testler/gunluk_8y_*`):

| Set | An | Kök y | Ayak altı yüzeyler (y; Unclip.standable / denetçi) | `_gy` | `floor_y` | Taban (FK) − zemin |
|---|---|---|---|---|---|---|
| YENİ | 0,3 sn | −3,065 | OvaZemini HeightMap −3,076 (✓/✓) | −3,066 | −3,076 | sol −0,120 · sağ **−0,179** |
| YENİ | 2 sn | **−2,885** (+0,18) | OvaZemini −3,076 | −3,066 | −3,076 | sol +0,059 · sağ 0,000 |
| YENİ | rapor | −2,885 | AraziCarpisma HeightMap −3,066 (✓/✗) · OvaZemini −3,076 (✓/✓) | | −3,066 | |
| ESKİ | 0,3 sn | −0,030 | görünmez Box −0,030 (✗/✗) | −0,030 | NAN | |
| ESKİ | 2 sn | **0,150** (+0,18) | WalkSolids Concave −0,030 (✓/✗) · Box −0,030 | −0,030 | −0,030 | |

- İki ızgara arasındaki fark bu noktada **0,010 m** (OvaZemini bilerek −0,01), 0,18 değil; `T10_8Y zemin_denetim` de ≤ 0,04.
- Kök, zemin değişmeden **iki sette de** 0,18 kalkıyor; `Unclip.rest_settle` değil (zemin farkı < 0,05 → dokunmaz).
- Kaldıran: `Stage.station(…, {"ground": gy})` canlı figür için her 0,5 sn `Stage.plant_feet(w, ground, 0.25)` çalıştırır
  (`stage.gd:803-810`): kişinin en alçak FK tabanını zemine koyacak kadar KÖKÜ kaydırır. "crouch" pozunda (`rig.gd:96,720`)
  sağ taban kökün 0,179 m altında → kök +0,18. Ayak IK'sı aynı anda dışarıdan kök yazıldığını görüp kapanır
  (`ayak.gd _kok_denet` → meta `ayak_kok_dis`: denetim satırındaki meta bu). ESKİ sette denetçi görünür/"ground" zemin
  bulamadığı için satır yazmıyordu (WalkSolids görünmez, kutu görünmez) — kusur oradaydı, görünmüyordu.
- **Çözüm (bölümün kendi dosyasında, `chapter8y.gd _build_lines`):** halatçı istasyonu yer çağrısız kurulur, y elle
  `_gy`'den (kök zeminde). `plant_feet` döngüsü yok → IK açık kalır, tabanları zemine o koyar (yakında). İki sette aynı.
  `unclip.gd`, `hud.gd`, `stage.gd` DEĞİŞMEDİ; `OvaZemini` ve "ground" metası yerinde; eşik/muafiyet yok.
- Sonra: YENİ ×3 rapor anında kök −3,066 = `_gy`, denetim 0 (24/24). Karede (`kare/8y/yeni/08_halatci_yakin`,
  `09_halatci_yan`): çömelen askerin dizi ve ayağı toprağa basıyor, halat kangalı yanında yerde; havada değil.
- **Kabul eşiği / ayak–görünen yer:** ovada kişiler `_gy` = OvaZemini ızgarası (v2 arazisinin 1 m örneği − 0,01) üstünde;
  v2 çarpışmasıyla fark ≤ 0,04 (`T10_8Y zemin_denetim`), görünen v2 ağının yakın hücresi 6 m olduğundan görünen yüzeyle
  fark bu ölçekte birkaç cm; eşik 0,15 (denetçininki) altında. Ayrı "dikdörtgende v2 çarpışmasını kapat" çözümü gerekmedi.
- Geçici anahtar kalktı: `SurHub.yeni8y()` artık `--yenisur=8y` istemiyor (8y varsayılan yeni, `--eskisur=8y` eski).

## Bağ tablosu (eski → yeni)

| Bölüm | Bağ | Eski | Yeni |
|---|---|---|---|
| 8y | halatçı istasyonu | `Stage.station(…, {"ground": gy})` | y elle, yer çağrısız (`plant_feet` yok) |
| 13 (şehir dalı), 23, 24 | hub | eski dünya, kutu iç sur + süslü Romanos kapısı | v2, yeni surun Romanos kesimi (`SurHub`, Taşıma 10 hub'ı) |
| 13 | v2'ye geçiş | `TOLGA`'da yoktu | `TOLGA` += "13" (yalnız `place == "city"` ByzCity kurar; kamp/Galata dalları değişmez) |
| 24 | Ayasofya yarısı (`_to_ayasofya`) | — | önce `IstBaglama.birak()` (ilk yarının v2 durağan durumu: aktif bölge, dönüşüm, harita) |
| uzak hub (v2) | yer | `_hub_kapi_v2` (eski yöntem) / `hub_xf` eski yer, yaw 0 | `SurHub.hub_v2()` (`IstBaglama.donusum("byz_walls")`, `IstSehir.hub_xf`) |
| uzak hub (v2) | sur | `ByzCity._build_walls` (kutu iç sur, kuleler, kemer) | kurulmaz; `_build_giust_yeri`; döşeme iç surun şehir yüzünde biter (`sur_yeni = true`) |
| 31o | sur | `LandWalls` ×2 (ev evresi :152, kare kipi :1565) | `_sur_kur()` (tek işlev): `SurSetSahne` + `romanos_kanat` + `open_inner_gate` |
| 31o | cadde/ev/saçak/tellal/Lore/kamera sayıları | eski çerçeve | AYNI: set `−sehir_ofs(romanos x)` = (57,3; 0; 2,0) kayar (26'nın `city.yer` kaydırmasının tersi; geometri aynı, mutlak sayılar tek yerde). `FallenCity` (`fallen_city.gd`) DEĞİŞMEDİ |
| 41o | sur | `LandWalls` gedikli, onarım 3 | `SurSetSahne` (`SurSet.sec("41o")`), onarım 3 |
| 41o | meydan | (−72; surf; 134) | `YARD_AT + ova_ofs` (y `SiegeField.surf + ova_ofs.y`); `field_keep` eski ova koordinatında |
| 42b | sur | `LandWalls` `intact` | `SurSet.sec("42b", false, "mesoteikhion", true)` SAĞLAM + `intact` |
| 42b | meydan | (−16; 0; −20) | `+ sehir_ofs(0)` = (0; 0; −2); kesim engelleriyle çakışma 0 (`T12_42B`) |
| 10h | gedik molozu (yeni dal) | 11 koyu + 9 soluk `Props.ball` | `_moloz_yeni`: tek ağ, köşeli taş/tuğla/toz (`GedikMoloz`, çarpışmasız) |

Aşama geçişi (31o): `T12_31O asama=eyup surset_etkin_temiz=true`, `asama=aya … true` (her koşuda).

## Kareler (ESKİ | YENİ; tek cümle)

| Kare | Yeni |
|---|---|
| 8y/08 halatçı yakın, 09 yan | Çömelen asker dizi/ayağı toprağa basıyor, kangal yerde; kutu yok, havada yok; aynı ressam (kamera yakın: kadrajın üstünde başlığı). |
| 8y/10 batarya | Batarya, gülle yığını, halatçı; zemine oturmuş. (Gülle yığınındaki soluk toplar bölümün eski süsü — dokunulmadı.) |
| 23/01, 24/01, 13/01 caddeden sur | Pazarın ardında yeni surun kapı kulesi ve mazgallı iç sur; eskisinin pencereli kutu kuleleri yok; aynı ressam. |
| 23/02, 24/02, 13/02 kapı şehir yanı | Yeni iç kapı: tuğla kemer, açık kanat, koridor, nöbetçiler ve meşaleler; eskisinin süslü kutu kapısı yok; kişiler döşemede. |
| 23/03, 24/03, 13/03 ufuk | Çatıların üstünden ufka yeni sur hattı ve ova. |
| 23/04, 24/04, 13/04 iç mekân | Saray avlusu / İmparator (bölümün iç mekânı) değişmedi; önde bölümün kendi beyaz saksı kutusu (önceden var). |
| 23/05, 24/05, 13/05 tepeden | Hub v2'de kesimin gerçek yerinde, sur kesintisiz, ova ve ordugâh ötede. |
| 31o/01 caddeden kapı | Yanık caddenin ucunda Romanos iç kapısı (kemer, açık kanatlar, koridor ucunda dış kapı); eskisinin düz beyaz kutu kapısı yok. |
| 31o/02 kapı yakın (1,5–2,5 m) | Açık kanatlar, tonozlu geçit, koridor ve dış kapı; yakında oyuncak değil (kanat tahtası sade: görünüşe istek). |
| 31o/03 cadde | Cadde, Kadri, kuyruk, yanık evler — aynı (sayılar değişmedi). |
| 41o/01–02 | Talim meydanı ovada; ötede yeni sur sisli fonda; meydan zeminde, havada yok. |
| 42b/01–02 | Meydanın ardında SAĞLAM yeni sur, kule ve merdiven; iskele ve kukla zeminde; eskisinin kutu suru yok. |
| 10h/01–02 gedik | Koyu köşeli taş ve kiremit tuğla kırığı yığını sura yaslı, toz lekesi; yuvarlak soluk "kaya" yok; parça havada yok. |
| uzak/01–02 (7a, v2) | Uzak hub surun içinde, sur v2'nin kendisi; eskide (`--eskisur=hub`) kutu kuleler ve süslü kemer v2 surunun önüne biniyor. |
| 17o/01–02 | Karşı kıyıda eski kutu şehir surları (eski dünya + `Scenery.city_walls`): taşınmadı → görünüşe istek. |
| 21o/01–02 | Tünel; sur yok. |

Sahibine: `kare/sahip_1_31o_kapi.jpg`, `sahip_2_uzak_hub.jpg`, `sahip_3_42b_meydan.jpg`, `sahip_4_23_kapi.jpg`.

## Çeşit tablosu

Hepsi BİTTİ (zaman aşımı 0, `rc=0`), 4 süreç aynı anda; satırlar `testler/bolum/*.txt`. Ortalama koşu ≈ 70 sn (4 süreçle).

| Bölüm | Çeşitler | Yeni 1 | Yeni 2 | (Yeni 3) | Eski | Denetim |
|---|---|---|---|---|---|---|
| 8y | "", warn, dep, opened, honest, hikmet, sinerji, next | 8/8 | 8/8 | 8/8 | 8/8 | 0 · `=yuru` takılma 0, düşme 0 (182,6 m) |
| 23 | "", creative, pass, singed, letter, osm | 6/6 | 6/6 | | 6/6 | 0 |
| 24 | "", late, niko, niko_slow, eclipse | 5/5 | 5/5 | | 5/5 | 0 |
| 13 | "", miss, wrong, depot, together, stay, w4, meclis, kitchen, city, next, wrong_next, gidak | 13/13 | 13/13 | | 13/13 | 0 |
| 31o | "", late, petrion_ok, petrion_bad | 4/4 | 4/4 | | 4/4 | 0 |
| 41o | "", lose | 2/2 | 2/2 | | 2/2 | 0 |
| 42b | "", lose | 2/2 | 2/2 | | 2/2 | 0 |
| 10h | "", shame, save, save1, honest, open, pass, next | 8/8 | 8/8 | | 8/8 | 0 |
| 10h `=yuru` | | PASS | PASS | | PASS | takılma 0 · **VISAUDIT overlap ×3** (eski sette de aynı, aşağıda) |
| Bağımlılar ×1 | 0, 6, 7, 10, 11, 12, 12b, 20, 26, 28o, 30, 37o, 43o, 44b | 14/14 PASS | | | | 0 |

Sözleşme (son kod): `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` ·
`WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` · `ESYATEST PASS` · `T8DTEKME PASS` (26o) · `PARSECHECK PASS scripts=368`.

**10h `=yuru` overlap (Taşıma 10'dan, ESKİ sette de):** heyet kişileri (Lütfi, elçi, Theodoros) `_build`'de (0; 0; 0)'da kurulur,
yerlerine `_place_audience` koyar; o yalnız `_run`'da çağrılır, Taşıma 10'un `=yuru` çeşidi onu atlar → üçü üst üste.
`run_tests.sh`'te bu çeşit yok; düzeltmesi (`_tasima10_yuru` başında `_place_audience()`) bu görevin `chapter10h.gd` payı
("yalnız gedik dekoru") dışında: YAPILMADI, sonraki taşıyana.

## Bütçe (tek kare; ESKİ | YENİ çizim / ilkel; sınır yeni ≤ eski + %5)

| Kare | Eski | Yeni | |
|---|---|---|---|
| 13/01–05 | 7883/8,85M · 4092/8,26M · 6339/8,88M · 2951/4,85M · 6051/3,49M | 3672/2,83M · 872/1,86M · 2477/2,22M · 1940/3,73M · 4841/2,56M | ✓ hepsi |
| 23/01,02,05 | 7405/9,02M · 3870/7,40M · 5257/3,69M | 3736/2,93M · 1106/2,07M · 5795/3,05M | ✓ ✓ **✗ 05 çizim +%10** (v2 ordugâhı/şehri tepeden) |
| 23/03, 04 | 7689/7,95M · 2746/5,99M | 4050/2,77M · 2759/5,03M | ✓ ✓ (+%0,5) |
| 24/01–05 | 8857/10,3M · 3719/7,80M · 9123/8,89M · 1782/4,25M · 5459/3,72M | 5114/4,13M · 1002/2,03M · 5624/4,00M · 2370/5,44M · 6174/3,18M | ✓ ✓ ✓ **✗ 04 +%33/+%28** · **✗ 05 çizim +%13** |
| 31o/01–04 | 2580/5,00M · 3337/5,40M · 3078/5,08M · 3123/2,49M | 1041/2,28M · 1142/2,76M · 1475/1,18M · 2144/1,86M | ✓ hepsi |
| 41o/01–02 | 2355/2,66M · 3702/3,90M | 955/1,37M · 2511/3,14M | ✓ ✓ |
| 42b/01–02 | 2396/5,82M · 3153/5,85M | 1070/2,04M · 1657/2,41M | ✓ ✓ |
| 10h/01 | 811/1,47M | 886/1,55M | **✗ çizim +%9** (aynı kod yolu; moloz tek ağ = +1 çizim; fark v2 akışının o andaki durumu) |
| uzak/01–02 | 997/2,40M · 768/1,56M | 1001/2,45M · 760/1,54M | ✓ ✓ |
| 8y/01–10 | 3046/5,93 · 3312/4,56 · 4294/6,03 · 4552/6,38 · 2011/2,19 · 2266/3,91 · 2410/2,62 · 1842/2,92 · 2551/2,54 · 3504/4,87 | 2390/2,09 · 2175/2,23 · 2422/2,58 · 2127/2,74 · 2258/3,41 · 1799/3,08 · 2557/1,99 · 1112/2,16 · 2350/3,27 · 1517/2,52 | 05 ✗ (+%12/+%56), 07 ✗ çizim +%6, 09 ✗ ilkel +%29 (eski dünya → v2 ovası; Taşıma 10'daki gibi), öbürleri ✓ |

## Sonraki taşıyana
1. Hub bölümleri artık 6, 7, 10h, 12b, 13, 23, 24 (`SurHub.BOLUMLER`); hepsi v2'de. Yeni bir hub bölümü: `BOLUMLER` ve `IstBaglama.TOLGA`.
2. Hub'dan başka dünyaya geçen bölüm (24'ün Ayasofya yarısı) geçişten önce `IstBaglama.birak()` çağırmalı.
3. `SurHub.uzak_yeni()`: uzak hub (IstSehir `hub_sehir`) kararı; `--eskisur=<sahne bölümü>` ya da `--eskisur=hub`.
   Bilinen: 7 `BOLUMLER`'de olduğu için 7'de `--eskisur=hub` yalnız uzak hub'ın SURUNU eskiye alır, yeri `hub_v2` kalır
   (karşılaştırma karesi `uzak/eski` böyle); tam eski için `--eskisur=7`.
4. `Stage.station(…, {"ground": …})` canlı "crouch"/"kneel" figürde kökü kaldırır (plant_feet + FK taban); ova gibi
   görünür zeminde denetçi yakalar. Bölümde yer çağrısız kurup y'yi elle vermek yeterli (8y kalıbı).
5. 31o kalıbı: bölümün mutlak sayıları çoksa set `−sehir_ofs(romanos x)` kaydırılabilir (FallenCity ve bölüm aynı çerçevede kalır).

## Hâlâ kötü olanlar (dürüst)
1. **17o** karşı kıyıda eski kutu şehir surları (eski dünya `springs` + `Scenery.city_walls`); düzeltme `horn_world.gd`/eski
   dünya — bu görevin dosyası değil (görünüşe istek).
2. **Bütçe**: 23/05, 24/04, 24/05, 10h/01 ve 8y'nin 3 karesi +%5'i aşıyor (v2 dünyası; tepeden kareler).
3. **Uzak hub, v2'nin bağımsız kurulumunda** (IstBaglama'sız gezi/test): `IstSehir` öğeyi yaw 0 ile koyar (`sehir.gd:1999`,
   benim işlevlerim dışında); oyunda her zaman `IstBaglama._hub_dondur` döndürür (ölçüldü: yaw 161,9 = hub_v2).
4. **8y halatçısı uzakta (> 28 m, IK LOD dışı)** FK pozunda sağ taban 0,18 m toprağa gömük çizilir (çömelme pozunun kendi
   kusuru, `rig.gd` — kimsenin değiştirmediği dosya); yakında IK düzeltir.
5. **42b meydanı** kesimin düz şehir önü levhasında; çevresinde ev yok (eski sette de boştu).
6. 31o ve 26'da `open_inner_gate` kanadı sade tahta (görünüşe istek, Taşıma 10'dan beri).
7. 10h `=yuru` (test çeşidi) heyet kişileri üst üste (`VISAUDIT overlap`, eski sette de): bu görevin payı dışında, yukarıda.

## Görünüşe istek
1. **17o**: Haliç'in karşı kıyısındaki şehir surları eski kutu (`HornWorld` uzak katmanı / `Scenery.city_walls`) — kare `kare/17o/eski/01_karsi_kiyi_sur.jpg`.
2. Kapı kanadı (KapiKanat / yan kapı kanadı) yakından düz tahta — `kare/31o/yeni/02_kapi_yakin.jpg`.
3. "crouch" pozunun FK tabanı kökün 0,12–0,18 m altında (`rig.gd:96,720`; IK kapalıyken gömük) — `kare/8y/yeni/09_halatci_yan.jpg`.

## Replik uyumsuzluğu
- 23, 24, 13: hub replikleri sur ayrıntısına değinmiyor — uyumlu.
- 31o "Aziz Romanos Kapısı'ndan şehre": yeni sette kapı gerçekten Romanos'ta — uyumlu (eskide Mesoteikhion'daki kutu kapıydı).
- 41o "uzakta, ovanın ucunda surlar", 42b "iç surun ardındaki meydan": uyumlu.
- 10h `UI_OBJ10H_GEDIK` "surda açtığı yarığı kapat": sur gövdesinde yarık yok, dibinde moloz (Taşıma 10'dan beri hafif uyumsuz).

## run_tests.sh isteği (kendim eklemedim)
- `run --chapter=8y --autotest=yuru` (≈ 1 dk; `T9YURU OZET … takilma=0 dusme=0`).
- 13'ün `=city` çeşidi zaten listede; yeni sette v2 dünyası kurulduğu için bu koşu ≈ 2 dk.

## Değişen dosyalar
`scripts/chapter8y.gd`, `chapter10h.gd` (yalnız yeni dalın gedik dekoru), `chapter24.gd` (`birak`), `chapter31o.gd`,
`chapter41o.gd`, `chapter42b.gd`, `scripts/world/ist/sur_set_hub.gd` (BOLUMLER, `uzak_yeni`, `yeni8y`),
`scripts/world/ist/baglama.gd` (TOLGA += 13; `donusum` uzak hub), `scripts/world/ist/sehir.gd` (yalnız `_make_hub`, `hub_xf`),
`tests/_ist/tasima12_kare.*` (yeni). `chapter13.gd`, `chapter23.gd`, `chapter17o.gd`, `chapter21o.gd`, `byz_city.gd`,
`fallen_city.gd`, `dunya.gd`, `world1453.gd` DEĞİŞMEDİ.
