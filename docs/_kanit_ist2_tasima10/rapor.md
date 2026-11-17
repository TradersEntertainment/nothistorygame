# TAŞIMA 10 — KAPI VE ŞEHİR İÇİ SUR: Bölüm 12b, 8y, 10h, 6b (+ 7b fon) yeni surda — rapor

Dal `wip/ist2-tasima10`, taban `wip/ist2-taban17` = **f962b002**. ESKİ = aynı kod `--eskisur=<bölüm>` ile (eski kod yolu satır
satır), YENİ = anahtarsız. Godot 4.4.1 resmi; testler `--max-fps 20`, tam süzgeç; kareler xvfb + Mesa llvmpipe, 1280×720 jpg 85,
hepsine TAM BOY bakıldı. Klasörler: `kare/<bölüm>/eski|yeni/`, `testler/` (süzülmüş satırlar; `bolum/` her koşu, `yuru/`,
`kare_*.txt` bütçe satırları, `sonda.txt`, `sozlesme.txt`), `dokum.md` (madde 1).

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | ÖLÇ VE DÖK | **TAMAM** | `dokum.md`: beş bölümün bağları, romanos kesiminin ölçüleri (sonda), süreli evreler, bot yolları |
| 2 | **12b** | **TAMAM** | İmparator'la sur yolu yeni iç surun sur yolunda (y 12,12, 4,1 m en), "kuleye açılan kapı" = Romanos'un güney kapı kulesinin sur yolu geçidi (2,2 × 3,0); süreli soru 12 sn aynı; kutu mazgal/kapı/sancak/dış sur/hendek kalktı |
| 3 | **8y** | **TAMAM** (1 bilinen denetim satırı, aşağıda) | v2'de Romanos'un gerçek yeri; iç kapı (açık kanatlar) → 5 m'lik koridor → dış kapı (`KapiKanat`, nöbetçi açar) → 3,4 m inen rampa → **yürünür** köprü (`KapiKopru` "saglam") → ova (v2 arazisi) → ölü bölge → siper; yürüyüş z −10 → 137,5 aynı (bot 176,3 → 182,6 m) |
| 4 | **10h** | **KISMEN** | Çıkış = Romanos iç kapısı ✓; gedik **v2 oyun gediği DEĞİL** (iç surun şehir yüzünde, eski yerinde; kutu yarık levhaları kalktı, taş yığını): v2'nin oyun gediği dış surda, şehir yanından erişim yok (aşağıda "sahibine") |
| 5 | **6b** | **TAMAM** | Meydan/pazar aynı; "sur yolu" (surun dibindeki yol) yeni iç surun dibinde; kapıdan çıkış Romanos iç kapısı; beyaz bayrak kumaş. 6b artık v2 dünyasında (eski dünyanın kutu surları kesimi çevirmesin) |
| 6 | **7b fon** | **TAMAM** | Hub yeni surla (v2, Nihat uçuşu aynı); 11 çeşit ×2 PASS, eski ×1; 4 kare çifti `kare/7b` |
| — | Geri dönüş | **TAMAM** | `--eskisur` / `--eskisur=12b,10h,6,7,8y`: eski kutu sur ve eski yerleşim satır satır (44 çeşit eski ×1 PASS) |
| — | Sözleşme | **AYNI** | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` · `ESYATEST PASS` |
| — | Bütçe | **KISMEN** | 34 kameranın 30'unda yeni ≤ eski + %5; 4'ü aşıyor (8y'de dünya değişti: eski dünya → v2; 12b'de bir kamera). Tablo aşağıda |

## Ortak bağdaştırıcı: `scripts/world/ist/sur_set_hub.gd` (yeni; class_name yok, `preload`)

- **Kesim:** yeni surun `"romanos"` kesimi (`SurOyun.kur`, aynı kurucu `IstSurlar._run`, şehirdeki Romanos kapı koşusunun
  AYNISI: L 60, aynı tohum, `IstSurlar.OPTS["romanos"]`). Yan dilimler ve uzak katman KURULMAZ: v2'de komşu dilimler şehrin.
- **Hub çerçevesi** (`SurHub.M`): kesim +z → hub +x (dış), kesim +x → hub −z; kapı ortası → hub z 5,5 (`ByzCity.EXIT_POS`);
  iç surun şehir yüzü (zi0) → hub x 32,5 (eski iç surun şehir yüzü); peribolos toprağı → hub y 0.
- **v2 yeri** (`SurHub.hub_v2` = `a.xf · M⁻¹`): hub, kesimin GERÇEK dünya yerine oturur (`IstBaglama.donusum("byz_walls")` yeni
  kipte bunu döner). Şehrin "romanos" kapı dilimi `_temizle`'de kalkar, yerine oynanır kesim kurulur; şehrin kara suru dilimleri
  artık KALIR (eskiden hub'ın kutu suru örttüğü için temizlenip 30 m boşluk bırakıyordu — kare `12b/yeni/07`).
- **8y çerçevesi** (`SurHub.M8`): dönüşsüz (8y yereli zaten +z ova, z 0 iç sur), y +0,12. `IstBaglama` yeni bölge `"gate8y"`.
- **Kapı parçaları:** `SurOyun.kur` seçeneği **`"kapi_parca"`** (yalnız EKLEME; varsayılan kurulum bit bit aynı): parçasız (şehir
  aynısı) kurulumda da kapı koşusunun kanatları `KapiKanat` (4 kanat: iç ve dış kapı), köprü `KapiKopru` olur.
- **Karar:** `SurHub.yeni(bölüm)` = bölüm ∈ {6, 7, 10h, 12b} ve `--eskisur` istenmemiş; 8y `SurHub.yeni8y()`. ByzCity ve
  IstBaglama aynı karardan okur (`SurHub.sahnede()` → `IstBaglama.sahne_bolumu()`). 13, 23, 24 ve uzak hub (`far_hub`) ESKİ.

## Bağ tablosu (eski → yeni)

### Hub (ByzCity, `byz_city.gd`) — 6b, 7b, 10h, 12b
| Bağ | Eski | Yeni | Nasıl |
|---|---|---|---|
| İç sur | kutu 3 × 12 × 70 m, x 34 | kesim iç suru 5 m (x 32,5…37,5), HW 12 | `_build_walls_yeni` → `SurHub.kur` |
| Kuleler | 6 × 16 × 6 kutu, z −34/−18/−2/14 | kapı kuleleri z −11,4…2,1 ve 8,9…22,4 (en 13,5, tepe y 19,12); ötesi şehrin dilimleri | kesim |
| Mazgallar | küp | kesimin korkuluk ve dişleri | kesim |
| Romanos açıklığı | `gz` ≈ −31,5 (dünya kapısı) + süslü sahte kapı z 5,5 | gerçek kapı z 5,5 (gw 5,0, gh 4,6), koridor, açık kanatlar | kesim + `KapiKanat` |
| Çıkış etkileşimi "exit" | (31,6; 1,7; 5,5) | aynı | |
| Kapı nöbetçileri/meşaleler | (30,3; 0; 5,5 ± 2,7) / (31,1; 0; 5,5 ± 3,2) | (29,5; 0; 5,5 ± 3,3) / (30,5; 0; 5,5 ± 3,9) | açılan kanatların dışında |
| Giustiniani iskelesi, masası, sandıkları, kendisi | `_build_walls` içinde | aynı yer (`_build_giust_yeri`) | |
| Döşeme | 90 × 80, x −45…45 | x −45…32,5 (iç surun şehir yüzünde biter) | `_build_ground` |
| Süs/yürüyen halk alanı | x −44…44 | x −44…29 (eteğin önü) | `Dressing.auto` drect (byzclimb VISAUDIT kök nedeni) |
| World1453/IstBaglama keep | Rect2(−46, −48, 84, 70) | Rect2(−46, −48, 78,5, 70) | |
| v2 arazi yaması | hub düzü 62…260 m (ovayı da düzlüyordu) | yalnız iç surun şehir yanı; dışı gerçek arazi | `baglama.gd` yama |
| v2 yerleşimi | hub x 34 ↔ v2 iç sur, z −31,5 ↔ v2 Romanos | kesimin gerçek yeri (`hub_v2`) | `donusum` |

### 12b (`chapter12b.gd`)
| Bağ | Eski | Yeni | Nasıl |
|---|---|---|---|
| `DOOR` (kuleye açılan kapı) | (33,4; 12,0; −5,2) kutu siyah levha | (35,0; 12,12; −11,4) kule geçidi | `_yeni_yerler`: kapı kulesinin −z yüzü |
| `WALL_TOP`, `EMP_AT`, `SPH_AT` | (33,3; 12,05; −11,2), (34,75; 12; −8,6), (33,4; 12; −6,4) | + OFS (1,6; 0,12; −6,2) | kapıya göre aynı yer |
| Meşaleler | (32,75; 12; −14,2/−7,4/−5,8) | (33,55; 12,12; z + OFS.z) | iç kenar |
| Meşale yürüyüş sınırı | x 32,3…34,9, z −14,9…−5,7 | x 33,25…36,75, z −21,1…−11,9 | `YOL` |
| Sancak | kutu levha, kule tepesi | kumaş (`kumas.bayrak`), kapı kulesinin tepesi | |
| Nöbetçiler | sur yolu + iki kule tepesi | sur yolu + iki kapı kulesinin tepesi (y 19,12) | |
| Mazgal kutuları, kule kapısı levhası | bölüm kurar | kurulmaz (kesimin) | |
| Ordugâh görünümü | zemin kutusu, hendek/dış sur/kule kutuları, çit x 62 | kutular yok (kesimin hendeği, dış suru); çit/tabya/çadır/ateş/otağ/tepeler aynı tohumla ova başı + 3 m'den (dx 26,1), v2 arazisinin üstüne; tabya kutusu → toprak yığın | `_build_camp_view_yeni` |
| Bakış hedefleri (90; y; z) | | + OFS | |

### 8y (`chapter8y.gd`)
| Bağ | Eski | Yeni |
|---|---|---|
| Dünya | eski World1453 (kutu surlar) | IstBaglama "gate8y": v2, kesim gerçek yerde |
| İç sur / kapı | dünyanın kutu suru z −4…−0,6 | kesim zi0 −2,5…2,5, kanatlar açık |
| Peribolos | 13 m, görünmez sınırlar x ±6,5 | Romanos koridoru (5 m, kesimin duvarları) |
| `GATE_Z` / `HINGE_X` | 13,85 / 3,45 (bölümün kutu kanatları) | 18,09 / 2,5 (`KapiKanat`'ın dış kanatları; bölümün açısı ve nöbetçinin tutamağı aynı) |
| `BAR_AT` / `BAR_DOWN` / sürgü boyu | (0; 1,55; 13,62) / (−4,6; 2,72; 12,45) / 5,6 | (0; 1,55; 17,58) / (−2,28; 2,72; 15,49) / 4,6 |
| `GUARD_AT`, `NIKO_GATE`, nöbetçinin sürgü yolu | (−2,6; 9,6), (2,2; 9,8), (−0,9; 12,6) → (−3,95; 11,95) | (−1,6; 13,84), (1,6; 14,04), (−0,9; 16,84) → (−1,9; 16,09) |
| `GATE_TRIGGER_Z` | 8,4 | 12,64 |
| `BRIDGE_Z` / köprü | 21 / dolgu geçit (bölümün kutuları) | 30,6 / `KapiKopru` (30,1…50,1, y −3,41) |
| Rampa | yok (düz) | dış kapıdan terasa 3,4 m (kesimin toprak rampası) |
| `FIELD_Z` | 37 | 51,1 |
| Ova zemini | düz görünmez döşeme y −0,03 | v2 arazisi (−3,63…−2,46) + görünmez yükseklik haritası (1 m ızgara; v2 çarpışmasıyla fark ≤ 0,04 m: `T10_8Y zemin_denetim`) |
| Ölü bölge, siper, hatlar (`BARRIERS`, `PATH`, `HALT_Z`, `TRENCH_Z` 103,5, `END_Z` 137,5…) | | aynı z (yükseklik `_gy`) |
| Gözcü/okçular | dış sur y 8,8 (basamak kutusu) | dış sur yolu y 8,62, korkuluğun ardı (basamak yok) |
| Batarya döşemesi | `_gy(BATTERY)` | en alçak köşeye (eğimli ovada havada kalmaz) |

### 10h (`chapter10h.gd`)
| Bağ | Eski | Yeni |
|---|---|---|
| `BREACH` | (32,4; 0; −26) iç surun şehir yüzü | aynı yer (yeni surda şehrin kara suru diliminin şehir yüzü) |
| Gedik dekoru | koyu kutu "yarık" levhaları + tuğla kutuları + moloz | kutular yok; koyu taş moloz yığını; barikat ve etkileşim aynı |
| Çıkış | `EXIT_POS` sahte kapı | Romanos iç kapısı (aynı nokta) |

### 6b / 7b
| Bağ | Eski | Yeni |
|---|---|---|
| Dünya (6b) | eski World1453 | v2 (IstBaglama; `SurHub.yeni("6")`) |
| Martı tünekleri, sur yolundaki fıçı, Giustiniani masası | | aynı |
| Beyaz bayrak (6b) | kutu levha | kumaş |
| 7b izleri "walls", "outside" | | aynı |

## Süre / mesafe tablosu

| Bölüm | Ölçü | Eski | Yeni | Not |
|---|---|---|---|---|
| 12b | süreli soru `hud.choose(…, 12.0)` | 12 sn | 12 sn | DEĞİŞMEDİ |
| 12b | `=yuru` sur yolu (3 meşale, kapı önü, yol başı) | 19,6 m / 17,0 sn, **takılma 1** (2,6 m'lik yolda nöbetçi) | 18,6 m / 6,3 sn, takılma 0 | sur yolu 4,1 m |
| 12b | meşale yürüyüş alanı | 2,6 × 9,2 m | 3,5 × 9,2 m | |
| 8y | `=yuru` bütün koridor (gerçek bot) | 176,3 m / 55,5 sn | 182,6 m / 57,5 sn | +6,3 m (sınır ±20) · takılma 0, düşme 0 |
| 8y | oyuncu yolu z | −10 → 137,5 | −10 → 137,5 | aynı |
| 8y | `SURE8Y` (otomatik test, gerçek saat) | 13–16 sn | 23–29 sn | makine süresi (v2 dünyasının kare süresi), oyun süresi değil; süre yok |
| 10h | `=yuru` doğuş → gedik → Giustiniani → kapı | 98,0 m / 31,5 sn | 97,8 m / 31,4 sn | takılma 0 |
| 6b | `=byzyuru` cadde → çamaşır ipi → meydan → tabela → sur yolu fıçısı → Giustiniani → kapı | 68,7 m / 21,9 sn | 68,7 m / 21,9 sn | takılma 0 (pazar tezgâhları arasında bot iki sette de dolanamıyor: ölçüden çıkarıldı) |

## Kareler (ESKİ | YENİ; `kare/<bölüm>/eski|yeni/<ad>.jpg`, aynı kod `tests/_ist/tasima10_kare.tscn`, aynı anlamdaki bakış)

| Bölüm/kare | Yeni (tek cümle: kutu, havada, zemin, aynı ressam, sönük mü) |
|---|---|
| 12b/01 surda imparator | Yeni iç sur yolunda İmparator ve Sfrancis, arkada kapı kulesi ve geçidi, solda mazgallar ve ordugâh; kutu yok, herkes sur yoluna basıyor, yeni ressam; eskisinin beyaz küp mazgallarından çok daha iyi. |
| 12b/02 mazgal yakın (≈1 m) | Diş ve korkuluk taşları eşek sırtı harpuştayla, aradan ordugâh; yakında oyuncak gibi değil; havada yok. |
| 12b/03 kule kapısı | Kapı kulesi, tuğla hatıllı, sur yolu geçidi gerçek açıklık; Sfrancis geçidin önünde; iyi. |
| 12b/04 surdan ordugâh | Mazgal arasından alt dış sur ve ovada çadırlar, otağ, batan güneş; çadırlar ve ateşler arazide; eskisiyle aynı zenginlikte. |
| 12b/05 caddeden sur | Pazar ve evlerin ardında yeni sur ve kule; eskisinde kutu sur; aynı ressam. |
| 12b/06 kapı şehir yanı | Kapının şehir yanı (kemer, açık kanat, nöbetçi, meşale) — kamera bir evin saçağına yakın (kadrajın solunu ev örtüyor), iki sette aynı. |
| 12b/07 dışarıdan sur | Ovadan Romanos kapısı, iki kapı kulesi, yürünür köprü, sur sürekli (güney boşluğu kapandı); aynı ressam. |
| 12b/08 tepeden | Hub, iç sur, peribolos, dış sur, hendek; sur kesintisiz. |
| 8y/01 şehirden iç kapı | Açık iç kapı kanatları, koridor, sonunda kapalı dış kapı ve nöbetçi; kutu yok; eskisinden çok daha iyi. |
| 8y/02 koridor dış kapı | Koridorun taş duvarları, kemer, kapalı dış kapı ve sürgü; yakın, iyi. |
| 8y/03 kanat yakın (≈1 m) | Kanat tahtaları ve demir kuşaklar; yakında düz (ahşap dokusu sade) — eskisi de aynı sadelikte. |
| 8y/04 köprü | Korkuluklu ahşap köprü, hendek, ötede siper ve ordugâh; havada yok, köprü yürünür. |
| 8y/05 ovadan sur | Ölü bölgeden kapı, gözcüler sur yolunda, kuleler; önde siper kalkanları; iyi. |
| 8y/06 dış kapı yakın | Rampadan dış kapının kemeri ve sur taşı; yakın, havada yok. |
| 8y/07 tepeden | Koridor, rampa, köprü, ova. |
| 10h/01 gedik | Yeni surun şehir yüzünde taş moloz, dikmeler, fıçılar, meşale; kutu yarık yok; **gedik sur gövdesinde görünmüyor** (yalnız dibinde moloz). |
| 10h/02 gedik yakın | Moloz ve dikme yakından; havada yok. |
| 10h/03 kapı şehir yanı | Kapı ve nöbetçiler (12b/06 ile aynı kadraj kusuru). |
| 10h/04 caddeden sur | Yeni sur ve kule; aynı ressam. |
| 6b/01 sur yolu fıçı | Surun dibindeki yoldan yeni iç sur, kapı kulesinin şehir kapısı, Giustiniani'nin masası; önde servi (kamera yakın); iyi. |
| 6b/02 Giustiniani masası | İskele ve masa yeni surun önünde; iyi. |
| 6b/03 kapı yakın | Açık iç kanatlar, koridor, dış kapı açık, ötede ova; iyi. |
| 6b/04 caddeden sur | Yeni sur ve kule. |
| 7b/01 iz sur | Giustiniani'nin izinden yeni iç sur ve iskele; havada yok, aynı ressam. |
| 7b/02 iz kapı | Kapının şehir yanındaki izden açık iç kanatlar, koridor, açık dış kapı, ova; kutu yok. |
| 7b/03 caddeden sur | Caddeden yeni sur ve kule. |
| 7b/04 tepeden | Hub iç surun önünde, kapı kuleleri, sur sürekli (eskisinde kutu sur ve kapının güneyinde boşluk). |

## Çeşit tablosu (yeni ×2 + eski ×1; `testler/bolum/`)

| Bölüm | Çeşitler | Yeni 1 | Yeni 2 | Eski | Denetim (yeni) |
|---|---|---|---|---|---|
| 12b | "", d2, d3, lie, next, year | 6/6 | 6/6 | 6/6 | 0 |
| 10h | "", honest, next, open, pass, save, save1, shame | 8/8 | 8/8 | 8/8 | 0 |
| 8y | "", dep, hikmet, honest, next, opened, sinerji, warn | 8/8 | 8/8 | 8/8 | **1 satır her koşuda** (`VISAUDIT float Station_coil_rope`, aşağıda) |
| 6 | "", b, byz, byzclimb, byzfail, byzgive, byzmistake, c, letter, next, y | 11/11 | 11/11 | 11/11 | 0 (1. turda byzclimb 1 → kök neden düzeltildi, 2. tur 0) |
| 7 | "", byz, byzcell, byzniko, fez, form, lost, next, tea, wall, wallkeep | 11/11 | 11/11 | 11/11 | 0 |
| `=yuru` | 12b, 8y, 10h, 6 (`byzyuru`) | takılma 0, düşme 0 | | 12b eski takılma 1 | |
| Bağımlılar ×1 | 0, 10, 11, 12, 13, 20, 23, 24, 25, 26, 28o, 30, 37o, 43o, 44b | 15/15 PASS | | | 0 |

Hepsi BİTTİ (zaman aşımı 0; 2–4 süreç aynı anda).

## Bütçe (`T10KARE … cizim ilkel`, tek kare; ESKİ | YENİ; sınır yeni ≤ eski + %5)

| Kare | Eski çizim / ilkel | Yeni çizim / ilkel | Sınır |
|---|---|---|---|
| 12b/01 | 5462 / 6,07 M | 5115 / 5,92 M | ✓ |
| 12b/02 | 5776 / 5,55 M | 5895 / 5,20 M | ✓ (+%2 çizim) |
| 12b/03 | 4420 / 6,18 M | 4153 / 6,16 M | ✓ |
| 12b/04 | 5412 / 4,60 M | 5816 / 4,48 M | **✗ çizim +%7,5** (alt dış sur ve kesimin parçaları kadrajda; eski kadrajda hendek/dış sur tek kutu) |
| 12b/05 | 10204 / 6,00 M | 9333 / 5,80 M | ✓ |
| 12b/06 | 5199 / 4,77 M | 4856 / 4,45 M | ✓ |
| 12b/07 | 7118 / 3,63 M | 6425 / 3,61 M | ✓ |
| 12b/08 | 6740 / 2,35 M | 5979 / 2,16 M | ✓ |
| 8y/01 | 4179 / 11,01 M | 3225 / 5,44 M | ✓ |
| 8y/02 | 3751 / 7,24 M | 2734 / 4,73 M | ✓ |
| 8y/03 | 5168 / 9,77 M | 3027 / 5,28 M | ✓ |
| 8y/04 | 4675 / 6,47 M | 2094 / 3,42 M | ✓ |
| 8y/05 | 2244 / 2,35 M | 2204 / 3,27 M | **✗ ilkel +%39** (eski: eski dünyanın düz ovası; yeni: v2 ovası, ordugâhı ve şehri — dünya değişti, sur değil) |
| 8y/06 | 2312 / 4,28 M | 1894 / 4,70 M | **✗ ilkel +%10** (aynı neden) |
| 8y/07 | 2372 / 2,58 M | 2517 / 1,80 M | **✗ çizim +%6** (aynı neden) |
| 10h/01–04 | 2335/4,55 · 2326/4,38 · 2212/4,76 · 5477/5,43 | 2183/4,32 · 2139/4,12 · 1792/4,40 · 4860/5,23 | ✓ ✓ ✓ ✓ |
| 6b/01–04 | 5295/8,65 · 4407/8,36 · 2617/4,47 · 7238/8,90 | 2203/3,73 · 1425/3,13 · 1071/3,16 · 4597/5,08 | ✓ ✓ ✓ ✓ (6b eski dünya → v2) |
| 7b/01–04 | 1100/1,65 · 883/1,53 · 4624/3,45 · 5494/2,86 | 835/1,54 · 682/1,53 · 4207/3,28 · 5129/2,92 | ✓ ✓ ✓ ✓ (04 ilkel +%2) |

## Sonraki taşıyana
1. **Hub'ı yeni sura bağlamak:** `const SurHub := preload("res://scripts/world/ist/sur_set_hub.gd")`; bölüm kimliğini
   `SurHub.BOLUMLER`'e ekle (13, 23, 24 hâlâ eski). ByzCity kararı sahneden okur (`SurHub.sahnede()`); hub'a bağlı sabit sayı
   yazma: `SurHub.ic_kuleler()`, `ic_yol_y/x()`, `kapi()`, `h(kesim_yereli)`.
2. **v2'de hub yeri değişti** (yeni kipte): kesimin gerçek yeri. Eski kipte (`--eskisur`) eski yer. Uçuş bölümlerinde (7) hub
   aynı karardan kurulur.
3. **`SurOyun.kur(…, {"kapi_parca": true})`**: parçasız kesimde kapı kanatları (`parca["kapi_kanat"]`, 4 kanat: 0–1 iç, 2–3
   dış) ve köprü (`parca["kapi_kopru"]`). Kanatlar kesim +z'ye (geçidin içine) 95° açılır (`ac`); bölüm kendi açısını
   `mente.rotation.y` ile verebilir (8y: −z'ye, nöbetçinin çektiği yöne).
4. **v2 şehrinin sur dilimleri `IstSehir.items` içinde**: bölge temizliği (`_temizle`) onları da siler; yeni kipte
   `hat == "kara_suru"` korunur.
5. **8y ovası eğimli** (±0,6 m): düz görünmez döşeme kullanma; yükseklik haritası (`_ova_zemini`) ve `_gy` aynı ızgarayı okur.
6. **`T10_8Y zemin_denetim`** satırı: görünmez zemin ile v2 çarpışması arasındaki en büyük fark (≤ 0,04 m).

## Hâlâ kötü olanlar (dürüst)
1. **10h gediği v2 oyun gediği değil** (KISMEN): v2'nin oyun gediği (Mesoteikhion 1. gedik, Romanos'tan 57 m güneyde, hub z
   ≈ −51,7) DIŞ surda; Romanos koridoru peribolostan kapalı, iç surda poterna yok → şehir yanından erişilmiyor. Gedik eski
   yerinde, iç surun şehir yüzünde (sur gövdesinde yarık görünmüyor, yalnız dibinde moloz ve barikat). Sahibine: (A) hub'a
   Mesoteikhion kesimi + iç poterna (26'nın `ic_poterna`'sı), 10h yolu ≈ +20 m; (B) gediği iç surda bırak (bugünkü).
2. **8y `VISAUDIT float Station_coil_rope`** (her yeni koşuda 1 satır, PASS): batarya yanındaki çömelmiş ip saran asker
   doğuştan 1–5 sn sonra kökü 0,18 m yukarı çıkıyor (`ayak_kok_dis`); **eski sette de aynı** (`--eskisur=8y`: lp 0,1796,
   ölçüldü) ama eski dünyanın kaba arazi çarpışması (WalkSolids) denetimi örtüyordu; yeni sette görünmez zemin arazinin
   tam yüksekliğinde (fark ≤ 0,04) olduğundan denetim yakalıyor. Kökü kaldıran sistem bulunamadı (Unclip.settle autotest'te
   kapalı, itme xz'yi de değiştirirdi; batarya döşemesi düzeltildi, değişmedi). Ortak kod (`Stage.station` "coil_rope" /
   çömelme / Ayak) bu görevin dosyası değil.
3. **Bütçe 4 kamerada +%5'i aşıyor** (8y'de dünya değişti; 12b/04 +%7,5 çizim).
4. **Kapı şehir yanı kamerası** (12b/06, 10h/03) evin saçağına yakın (iki sette aynı kadraj).
5. **Kapı kanatları**: hub'da iç ve dış kapı açık (eskinin "çıkış" süsü de açık kanatlıydı); kuşatma gerçekliğinde kapalı
   olabilir — sahibinin tercihi.
6. **12b ordugâh görünümü**: 12b'nin kendi çadırları v2'nin ordugâhıyla aynı ovada (iki ordugâh üst üste görünebilir; 04
   karesinde sorun görülmedi).
7. **13, 23, 24 ve uzak hub** hâlâ eski kutu surla (kapsam dışı).

## Görünüşe istek
1. Hub'da Romanos iç kapısının şehir yüzünde kemer ve kanatlar iyi; kapının iki yanındaki etek uçları (taşıma 8'in istek 3'ü)
   bu kadrajlarda görülmedi.
2. Kapı kanadı yakından (8y/03) düz: tahta dokusu sade (`IstSurlarKapi.C_WOOD`, `KapiKanat`).

## Replik uyumsuzluğu
- `D10H_N_K` / `_ALT` "(Surun üstünden) … Gedik niye parlıyor?": Niko surun üstünde — yeni surda gedik iç surun dibinde, Niko
  iç surun yolunda olabilir: uyumlu.
- `UI_OBJ10H_GEDIK` "topların surda açtığı yarığı kapat": yeni surda sur gövdesinde yarık görünmüyor (yalnız dibinde moloz) —
  **hafif uyumsuz** (madde "hâlâ kötü" 1).
- 12b "iki kule arası sur yolu, kuleye açılan kapı": yeni surda kapı kulesinin geçidi — uyumlu.
- 8y "iç sur kapısı → peribolos → dış sur kapısı → hendek köprüsü": yeni surda peribolos Romanos koridoru (5 m, duvarlı) — uyumlu.

## run_tests.sh isteği (kendim eklemedim)
- `run --chapter=12b --autotest=yuru`, `run --chapter=8y --autotest=yuru`, `run --chapter=10h --autotest=yuru`,
  `run --chapter=6 --autotest=byzyuru` (her biri ≈ 1 dk; satır `T9YURU OZET … takilma=0 dusme=0`).
- `res://tests/_ist/tasima10_sonda.tscn` (romanos kesimi ölçüleri ve kapı ekseni ışınları; başsız, ≈ 20 sn).

## Değişen dosyalar
- `scripts/world/ist/sur_set_hub.gd` (yeni), `scripts/world/ist/sur_oyun.gd` (EKLEME: `kapi_parca`)
- `scripts/world/ist/baglama.gd` (hub ve 8y yamaları: yeni yerleşim, `gate8y` bölgesi, yama sınırı, temizlik)
- `scripts/level/byz_city.gd` (yeni sur kipi; meydan/pazar/ev aynı; döşeme ve süs alanı iç surun önünde biter)
- `scripts/chapter12b.gd`, `chapter8y.gd`, `chapter10h.gd`, `chapter6.gd` (yeni kip + `=yuru`); `chapter7.gd` değişmedi
- `tests/_ist/tasima10_sonda.*`, `tasima10_kare.*` (yeni)
- Güvenlik anahtarı: v2 kapalıyken (`--eski-dunya`) hub ve 8y eski surda (`SurHub.yeni` v2'yi şart koşar; 12b ile ölçüldü, PASS)
- `world1453.gd` DEĞİŞMEDİ (8y'nin yönlendirmesi `IstBaglama.istek` içinden).
