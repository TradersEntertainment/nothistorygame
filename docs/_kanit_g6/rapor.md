# G6 — Haliç kıyı surları tek kurucuda: rapor

Dal `wip/tekharita-g6`, taban `3c9e7977` (wip/0.99.119). Godot 4.4.1, bu makine (4 çekirdek, llvmpipe).
Kanıt: bu klasördeki 8 pafta (p01–p08). "sonda_" kareleri serbest kamera sondasıyla (depoya girmeyen geçici sahne,
`tests/_g6/`, git dışı) aynı dünya koordinatından çekildi; her karenin üstünde kamera ve bakış noktası (dünya) yazılı.
ÖNCE kareleri ve koşuları tabanın ayrı bir kopyasında (git worktree, `3c9e7977`) alındı; SONRA bu dalda.

**Önemli not (arayüz):** `_tek_harita_ortak.md` ve `tek_harita.md §F`'de anlatılan `World1453.bake`, `FAR_REGIONS`,
`Flame.from_glow_boxes`, `Blachernae.shell_parts`, `ByzCity.far_hub` bu dalda (ve `origin/wip/0.99.119`'da) **yok**
(`grep` boş). İmzaları değiştirmemek ve ana makinedeki sürümle çakışmamak için ortak dosyaya bu arayüzü eklemedim:
pişiriciyi kendi dosyama (`SeaWalls.bake_parts`) koydum; uzak sürüm, kıyı surunu kuran işlevin içinde aynı yayımcıdan
kuruluyor (aşağıda). `world1453.gd`'ye dokunulmadı.

## 1. Ölçüm (ÖNCE): bölümün suru ile dünyanın aynı koordinattaki suru

Dünya y'si (deniz −1,6). "Dünya" = World1453/HornWorld'ün bölge aktif değilken (uçuş 7/11, öteki bölümler) kurduğu sur.
Kareler: p01, p02 (zincir), p03, p04 (Petrion), p05 (38o) — üst satırlar.

| | Zincir rıhtımı (horn_chain: 4b, 17, 19, 19o, 29, 29o) bölüm / dünya | Petrion (39o) bölüm / dünya | 38o (horn_wall_o, Horn.build) bölüm / dünya |
|---|---|---|---|
| Sur ekseni (x), kalınlık | −694,8 (dış yüz −696,8), 4 m / −700 (dış yüz −701,5), 3 m → **4,7 m kayık** | −700, 3 m / −700, 3 m | −698,5 (dış yüz −700), 3 m / −700, 3 m → 1,5 m kayık |
| Sur tepesi | 10,1 (rıhtımdan 11 m) / max(10, zemin+5) = 16–18, bölge aktifken bölgeye yakın 10'a iner → **bölüme göre değişiyor** | 9,6 / 23,3 (zemin 18,3+5) | 8,0 / 17–23 |
| Kule | 6×6,5 m, tepe 15,1; z −1622, −1606, −1570, −1542 (16/36/28 m ara) / 8×8 m, tepe sur+3…6 (rastgele), 44 m ızgara: z −1566, −1610, −1654 → **hiçbiri çakışmıyor** | yok / z −686, −598 (−642 bölgenin keep'inde atlanıyor) | 7×7, tepe 12,4–15,4, 45±4 m (tohum 3801) / 8×8, 44 m ızgara |
| Kapı | geçit z −1588 (3,6×3 m) + süslü deniz kapısı z −1583 / **yok** (40 m'lik parçanın ortası) | z −650, 4×4,6 m açıklık / iki ayak + kemer bloğu (40 m'lik parça), açıklık tepenin içinde | yok (bölümün kendi orta parçası ±24) / yok |
| Mazgal | 0,8×0,9×0,6, 1,6 m ara, ön yüzün 0,85 m içi / 1,2×1×1, 3,5 m ara, dış kenarda | yok / aynı (dünya) | 1,2×1,1×0,6, 2,5 m / dünya |
| Renk, desen | c9b89a/bfae90, "ashlar" (taş+tuğla dokusu), 3 tuğla hatıl (3 m ara) / cdbd9e koyulaştırılmış, **desensiz** (Dressing köşe rengi), 2 kalın hatıl | cdbd9e ashlar, hatılsız / dünya | cdbd9e ashlar / dünya |
| Rıhtım | taş rıhtım 25×3,2 m, üstü −0,9 / yok (yerine 29 m'lik arazi ızgarasının yamacı) | — | — |
| Eugenius (zincir kulesi) | **yok** / r 7, boy 22 silindir (−690, −1525) | — | — |
| Dikiş | iki uçta dünya suru 6–8 m geride biter; kuzeyde 4,7 m kayık, güneyde boşluk + yükseklik basamağı (p02 üst) | kanatlar 9,6 m, iki yanda dünyanın 10–23 m'lik suru 6–14 m boşlukla (p03 üst orta) | kuzeyde 8 m Horn suru yanında 10 m'lik krem kutu (p05 üst sol) |

## 2. Ne yapıldı (dosya:işlev)

Tek kurucu: **`scripts/level/sea_walls.gd` `SeaWalls.horn_wall_parts(emit, only, skip, ease, fixed_top)`** (sea_walls.gd:502).
Haliç'in şehir yakasının bütün suru (Blakherna köşesi z 40 → zincir rıhtımı → köşe → şehrin burnu) dünya
koordinatında, yayımcı `emit(tür, boyut, dönüşüm, renk, desen, katı)` ile. Ölçüler bölümün (17) ayrıntılı surundan alındı:
kalınlık 3 (zincir dilimi 4), kule 6 m (ön yüzden 2,05 m taşar), tepesi komşu surun 5 m üstü, 3 m arayla tuğla hatıl,
1,6 m arayla sabit ızgarada mazgal, kule tepesinde 4 köşe dişi, mazgal deliği, ateş; renk/desen bölümünkü (ashlar).
- Koşular (`_runs`, sea_walls.gd:416): (1) x −700 boyunca, kuleler 44 m ızgara (z 18−44k), her kapının iki yanında
  (±12 m) kule; kapılar Petrion (z −650, eşik y 0, 4×4,6 m) ve `HORN_GATE_Z`'nin beşi (eşik ham zeminde);
  (2) zincir rıhtımı z −1520…−1660: bölümün kuleleri aynen (z −1542, −1570, −1606, −1622), geçit z −1588 (3,6×3 m,
  eşik taşı), başta iki sur çizgisini bağlayan kule, sonda köşe kulesi, rıhtım gövdesi, Eugenius (−690, −1525; yer işareti
  değişmedi), süslü kapının uzak sürümü (bölümde ayrıntılısı var); (3) köşeden burna, 60 m'de kule.
- **Sur tepesi bölgeden bağımsız** (`_seg_top`, `_raw_surf`): dünyanın HAM görünen yüzeyinden (bölümlerin düzlediği
  alanlar sayılmaz) iki yanın 5 m üstü, en az 10 m; kule aralığı başına sabit. Önceden dünya, aktif bölgenin keep'ine
  yaklaşınca suru alçaltıyordu: aynı sur her bölümde başka yükseklikteydi. Şimdi her bölümde aynı (§1'deki değerler:
  zincir 15,2–18,5; Petrion 23,3–23,6; 38o çevresi 10–23).
- **Bölüm** `SeaWalls.build_span(host, bölge, fixed_top)` (sea_walls.gd:647): yalnız kendi dilimini (`SPANS`:
  horn_chain z −1660…−1520, petrion −670…−630) bölge dönüşümünün tersiyle yerel koordinatta, Props ile katı ve desenli
  kurar. `SeaWalls._build_wall` (sea_walls.gd:142) ve `_build_quay` (rıhtım gövdesi kurucuya taşındı),
  `Petrion._gate` (petrion.gd) bunu çağırır. 4b dünyanın dışında (kendi suyu/şehri; Niko surun tepesinde): aynı kurucu,
  tepe eski yükseklikte sabit (`fixed_top`). Niko'nun yeri ve sur üstü meşaleler `wall_top(x)` ile yeni tepeye.
- **Dünya** `HornWorld._horn_walls` (horn_world.gd:448–483): aynı yayımcıyı çağırır; aktif bölge benim dilimimse onu
  atlar (bölüm kuruyor), Horn.build'li bölgelerde (18, 18b, 31o, 38o) keep'in z aralığını atlar ve komşu suru Horn'un
  tepesine (8,0) indirir (eski davranış, yalnız o bölgeler aktifken). Aktif olmayan her dilim (zincir rıhtımı, Petrion
  kapısı) dünyada **bölümle aynı parçalardan** durur: uzak sürüm = aynı kurucu.
- **Pişirici** `SeaWalls.bake_parts` (sea_walls.gd:696): parçalar 240 m'lik parça × desen başına tek MeshInstance3D
  (köşe rengi, bölümdekiyle aynı üçlü düzlem "ashlar" dokusu, dış çizgi korunur); mazgallar tek MultiMesh; çarpışma
  WorldWalk'un üçgenlerinden (eskisi gibi), uçuş için `flight_boxes` (sur ve kule kutuları).
- Dikiş: bölümün dilimi ile dünyanın parçası aynı kule aralığından ve aynı tepe değerinden kesildiği için uç uca, aynı
  düzlemde, aynı yükseklikte birleşir; dilim sınırı kule ortasına ya da düz sur ortasına düşer (üst üste binen iki sur yok).
- Düzeltilen kendi hatam (kanıtlı): `Props.solid` gövdeyi kökte ekleyip sonra taşıyınca fizik sunucusunda kökte görünmez
  kutu kalıyordu (39o'da 6/6 varyantta `VISAUDIT wall key=D39O_N_01 at=(0, 1.7, 3.4)`; çarpışan: kapı kulesi gövdesi,
  kutu (0,0,0)'da). Gövde artık dönüşümüyle birlikte ağaca giriyor; satır kayboldu (aşağıdaki test listesi).
- Petrion zemininin kapı ucu 0,1 m kısaldı (surun dış yüzüyle aynı düzlemde titreme olmasın; çarpışma farkı surun içinde).

Değişmeyenler: oynanış alanlarının yerel koordinatları, rıhtım gövdesi, geçit (3 m), kuleler (yer, taban ölçüsü),
Petrion kapı açıklığı (4×4,6), cadde, evler, replikler, akış, botun yolu (testler aynı sonuçlarla geçti).
Görünüşte değişen: bölümlerdeki surlar artık dünyanınkiyle aynı yükseklikte (17/19/29'da rıhtımdan 16–19 m,
39o'da caddeden 23 m) ve kapının iki yanında kule (39o).

## 3. Ortak dosyalara eklenen satırlar
- `scripts/world/horn_world.gd:448–483` — yalnız `_horn_walls` işlevinin gövdesi (kaba Dressing kutuları + iki
  `_wall_run` çağrısı + Eugenius → tek kurucu çağrısı ve pişirme). `_wall_run`, `_wall_top` Marmara suru için duruyor;
  dosyanın başka yeri değişmedi.
- `scripts/world/world1453.gd`: değişiklik yok.

## 4. "Aynı yer" çiftleri (kareler)
- Zincir rıhtımı (−694, −1592): p01 — sol bölüm içi yerden (rıhtım, geçit, süslü kapı), orta bölüm içi havadan, sağ
  sonda_ uçuş dünyası (bölge "camp", 7/11 ile aynı kurulum) havadan. SONRA: sur, kuleler, hatıllar, desen, kule yerleri
  iki dünyada aynı; uçuş dünyasında sudan bakınca rıhtım, geçit ve süslü kapı da duruyor (sonda karesi
  world_zincir_yer, paftada yok). Dikişler p02.
- Petrion (−700, −650): p03 (caddeden kapı, denizden bölüm içi, denizden uçuş dünyası), p04 (havadan iki dünya).
- 38o (−699, −560): p05 (kuzey/güney dikiş, havadan).
- Oynanış, aynı replik anı: p06 (17: D17_TR_01, D17_TR_THANKS), p07 (39o: D39O_N_01, D39O_N_END — oyuncu caddeye
  bakıyor, kapı sırtında: kapı görünüşü yalnız p03'te, sonda), p08 (29: D29_N_01, D29_C_SHORE; sur gemilerin ardında).

Kendi karelerime bakış: havada duran/gömülü/küp kalan sur parçası görmedim; titreme (aynı düzlem) Petrion zemininde
vardı, giderildi (KANITSIZ: yakın karede titreme görünmüyordu, düzlem hesabından düzeltildi). Kalanlar §7'de.

## 5. Testler (SONRA; hepsi bu dalın son kodu, başsız, `--max-fps 20`)
54 koşu, **54 AUTOTEST PASS**; `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`,
`WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_MISS`, `JOURNEY_OVERLAP`, `TIMEOUT` satırı **yok**.
- 4: "", item, caught, market, chain, nofez, fall, fez, wet, next (10)
- 17: "", two, fall, nophoto, chain, ship_ok, ship_bad, lost, edirne_policy, edirne_none, osm, route, edirne_legend (13)
- 19: "", flee, tezkire, saved, ship_ok, ship_bad, ship_ok_flee, captive18 (8) · 19o: "", silent, hooks_ok, hooks_bad (4)
- 29: "", lose · 29o: "", lose · 38o: "", lose, hooks_ok, hooks_bad · 39o: "", late, tezkire, pass, sailor_ok, sailor_bad
- birer kez: 7, 11, 18, 17o, 31o
- `PARSECHECK PASS scripts=247`, `WORLDCHECK PASS regions=13 landmarks=35`, `CITYCHECK PASS`, `FLIGHTCHECK PASS`
  (`FLIGHTCHECK camp landmarks=9 forms=12 perches=3`, `FLIGHTCHECK walls landmarks=9 forms=12 perches=3`).
- Ekranlı oynanış koşuları (PACE, 17/29/39o, ÖNCE ve SONRA): hepsi AUTOTEST PASS. 17'nin ikisinde de (ÖNCE dahil)
  aynı satır: `VISAUDIT sunk scene=chapter17.tscn who=Person/... spk=SPK_VLAD feet=(2984.8, 0.0, -3.5)` — Edirne sarayı
  (EdirnePalace), benim değişikliğimle ilgisiz, tabanda da var; başsız takımda çıkmıyor.

## 6. Performans
RINFO (`--hitchaudit`, ekranlı PACE koşusu, 1280×720), replik başladıktan sonraki üç örnek, çizim / üçgen:

| Bölüm, replik | ÖNCE | SONRA | Fark |
|---|---|---|---|
| 17 D17_TR_01 (rıhtım) | 1400/1239/1213 · 1038k/1040k/1040k | 1404/1241/1222 · 1056k/1057k/1058k | çizim +%0,3–0,7, üçgen +%1,7 |
| 17 D17_TR_THANKS | 8277/8148/8133 · 7792k/7793k/7789k | 8270/8288/8291 · 7830k/7829k/7831k | çizim ≤ +%1,9, üçgen +%0,5 |
| 39o D39O_N_01 | 6638/6618/6117 · 7265k/7298k/6942k | 6643/6633/6124 · 7293k/7328k/6972k | çizim +%0,1–0,2, üçgen +%0,4 |
| 29 D29_N_01 | 5619/5515/6380 · 6441k/6437k/7477k | 5712/5479/5562 · 6493k/6489k/6493k | aynı evre: 5515→5479, 6437k→6489k (+%0,8); 3. örnek evre kayması (ÖNCE 6380/7477k ↔ SONRA sonraki örnek 6418/7529k, +%0,6/+%0,7) |

Bu bölümlerin bugünkü değerleri zaten 900 çizim / 2,5 M üçgenin üstünde (taban); artış her evrede %2'nin altında (sınır +%10).

Kurulum süresi (bölgenin sahneye eklenmesi = bölümün `_ready`'si + `World1453.build`, sonra ilk kare; başsız, ms,
dönüşümlü üçer koşu). Not: `tests/load_time.tscn` bu bölümlerde ready≈0 ölçüyor (kurulum ertelenmiş), o yüzden
`SeaWalls`/`Petrion`/dünyayı doğrudan kuran geçici bir ölçüm sahnesi kullanıldı.

| | ÖNCE (3 koşu) | SONRA (3 koşu) | Fark |
|---|---|---|---|
| Zincir (SeaWalls in_world: 17/19/29) | 5409/5346/5275 + ilk kare 181/186/169 | 5204/5328/5260 + 178/177/182 | −79 ms (gürültü içinde) |
| Petrion (39o) | 3601/3506/3507 + 109/150/110 | 3422/3613/3452 + 114/110/102 | −42 ms |
| Dünya, bölge "camp" (7/11 uçuş tabanı) | 3311/3338/3423 + 65/69/69 | 3473/3515/3333 + 63/72/75 | +83 ms |

## 7. Açık kalanlar
1. **Arazi, uzak sürümde bölümün zeminini gömüyor (AÇIK).** Dünyanın şehir zemini (SiegeField.city_ground) surun hemen
   arkasında 11–18 m yüksekte ve 29 m'lik ızgarayla çiziliyor; düzleme yalnız aktif bölgenin keep'inde yapılıyor. Bu yüzden
   bölge aktif değilken (uçuş 7/11, öteki bölümler) Petrion kapısının açıklığı (y 0…4,6) ve caddesi tepenin içinde kalır;
   zincir rıhtımının önünde surun dibine yaslanan yamaç vardır. Sur, kule, kapı kulesi, tepe, desen ve yerleşim aynı;
   zemin hizasındaki ayrıntılar (rıhtım, eşik) uçuşta yalnız kısmen görünür (havadan p01 sağ alt: surun önünde yamaç; p03 sağ alt:
   Petrion kapısının açıklığı yamacın ardında, görünmüyor). Çözüm ortak dosyalarda (öneri 1).
2. Bölümlerin keep kenarında arazi yığını (17 kuzey ucu, 38o güney ucu: p02 sol, p05 orta): aktif bölgenin düzlenen
   dikdörtgeni ile 29 m'lik ızgara arasındaki rampa; sur değil arazi (SiegeField). Öneri 1 ile birlikte çözülür.
3. 38o: Horn.build'in suru (horn.gd, başkasının) tek kurucuya bağlı değil; ekseni 1,5 m içeride, tepe 8,0, kule
   aralığı rastgele. Dünya o bölüm aktifken komşu suru 8,0'a indiriyor (dikiş p05 SONRA). Öneri 2.
4. 4b dünyanın dışında (kendi Haliç'i, şehri): aynı kurucu, ama tepe sabit 10,1 (Niko surda yürüyor).
5. `HornWorld._horn_shore` (benim işlevim değil) iskele/merdiven kaçınma listesini eski 44 m kule ızgarasından
   hesaplıyor; yeni kapı kuleleri (±12 m) bu listede yok. Görsel çakışma görmedim (BAKILMADI: bütün kıyı boyunca
   tek tek bakılmadı). Öneri 3.
6. Gece ateşleri: tek kurucu kule tepesinde "torch" yayımlıyor; dünyada `Dressing.glow` (kutu) — `Flame.from_glow_boxes`
   bu dalda yok, gelince otomatik aleve çevrilir.

## 8. Ortak dosyalar için öneriler (uygulanmadı)
1. Uzak bölgelerde zemin (FAR_REGIONS + bölge başına düzlük yüksekliği). `world1453.gd`:
   ```gdscript
   const FAR_FLAT := {"horn_chain": [Rect2(-60.0, -60.0, 140.0, 56.0), -0.9], "petrion": [Rect2(-20.5, -72.0, 41.0, 79.0), 0.0]}
   # build(): keep'i kurmadan önce, aktif olmayan her kayıt için
   for k in FAR_FLAT:
       if k != region_name:
           SiegeField.far_flats.append([world_rect(region(k), FAR_FLAT[k][0]), FAR_FLAT[k][1]])
   ```
   `siege_field.gd` `city_ground`: `for f in far_flats: if f[0].has_point(...): return f[1]` (rampa `flat_mix` gibi).
   Petrion caddesinin uzak sürümü (evler, kilise) `Petrion.far_*` ile aynı yere konabilir.
2. `horn.gd` `_sea_wall` (18, 18b, 31o, 38o): kendi duvarı yerine
   `SeaWalls.horn_wall_parts(emit, Vector2(z0, z1))` (z0/z1: keep'in dünya z aralığı) ve emit'i `SeaWalls.build_span`
   gibi Props'a bağlamak; bunun için `build_span`'a `only: Vector2` alan bir eş eklemek yeter (SPANS kaydı gerekmez).
   O zaman `LEGACY_TOP`/`ease` kalkar.
3. `horn_world.gd` `_horn_shore`: kule/kapı z'lerini `SeaWalls._runs()`'tan okumak (tek kaynak).
