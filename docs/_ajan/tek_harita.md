# Havadan bakış ve tek harita — AŞAMA 1 raporu (ön sürüm: mimari + göç planı)

Depo: /home/user/nothistorygame, karşılaştırma tabanı e551de84. Bu sürüm kod okumasına dayanır (her satır dosya:satırla).
Kare kanıtları (havadan/yerden çiftler) `kare/` altında toplanıyor; kusur listesinin karelere bağlı kısmı (§E) koşular
bittikçe eklenir. Makine çok yüklü (yük ortalaması ~20/4 çekirdek): bir ekranlı kare koşusu 30–60 dk sürüyor.

## A. Tablo: 1453 bölümleri hangi haritayı kuruyor

Sütunlar: bölüm · kurucu (scripts/level/…) · World1453 bölgesi (REGIONS) · dünyadaki yeri · tek haritaya bağlı mı · kendi
başına uydurduğu.

| Bölüm | Kurucu | Bölge | Dünyada yeri | Bağlı | Kendi başına olan |
|---|---|---|---|---|---|
| 0, 20, 20o, 21, 22, 22o, 26o, 28o, 32o, 36b, 37o, 41o, 42b | land_walls.gd (+assault, wall_fight, siege_chaos) → SiegeField | "landwalls" (kimlik) | Romanos kapısı/gedik, x 0, z 0 | EVET | Sur kesiti kendi ayrıntısı (yerinde); 41o/42b talim avlusu SiegeField yüzeyinde |
| 2 | slipway.gd | "slipway" | Kasımpaşa, kızak tepesi (−1051, 15, −930) | EVET | Kızak yolu kendi arazisi (FLAT_Y −6) |
| 3 | bureau.gd | — | Büro (2026, zaman dışı) | HAYIR (gerek yok) | İç mekân |
| 4a | camp.gd (Camp) | — | belirsiz (ordugâh, gece) | **HAYIR** | Ayrı arazi, ayrı çadırlar, "ufukta surlar" kendi çizimi, kendi gökyüzü (Night.environment); CampDay ile aynı ordugâh değil |
| 4b, 17, 19, 19o, 29, 29o | sea_walls.gd (SeaWalls) | "horn_chain" | Haliç ağzı, zincirin şehir ucu (−700, −1.6, −1600) | EVET | Rıhtım + sur kesiti; 29/29o deniz savaşı sea_battle.gd (BAŞKASININ DOSYASI) gemilerini bölge çerçevesinde kurar |
| 6a, 7a, 9, 10, 10b, 10z, 11, 16, 24o, 43o, (13 bir dalı) | camp_day.gd (CampDay, in_world=true) | "camp" | Maltepe, otağ (30, 480); ordugâh yerel +z surlara | EVET | Ordugâh ızgarası (180×180 m) kendi arazisi; dünyanın ovası dışarıda |
| 6b, 7b, 10h, 12b, 13 (dal), 23, 24 | byz_city.gd (ByzCity part "walls") | "byz_walls" | Romanos kapısının içi (5.5, 0, −36.3), x −16…54, z −82…−2 | KISMEN | Hub (cadde, kançılarya, saray avlusu, iç sur, kapı) kendi ev modelleriyle (byz_city.gd:314 `_house`, 1034 `_build_fill`: sıvalı kutu evler 6,6 m ızgarada). Dünyanın şehri (CityPlan + CityHouses, Kit.house) bu dikdörtgenin dışında **başka bir ev dokusu**. Uçuş bölümlerinde (7a, 11) bu dikdörtgende hub değil CityPlan evleri durur. |
| 24 (dal), 25, 26, 31o | byz_city.gd (part "aya") + ayasofya.gd (iç) | "byz_aya" | Ayasofya (−560, −1480) | KISMEN | Ayasofya'nın yer modeli (byz_city.gd:525 `_build_aya_exterior`: gövde ~35 m, kubbe tepesi ~24 m, pembe/tuğla) ile havadaki model (scenery.gd:510 `hagia_merged`: gövde 70×76 m, kubbe tepesi ~54 m, koyu kızıl) **iki ayrı model, iki ayrı ölçü**. Konstantin Sütunu yerde Ayasofya'nın 60 m batısında (byz_city.gd:675, dünya ≈ (−590, −1488)), havada Konstantin Forumu'nda (−470, −1300); aya bölümlerinde forumun revakı sütunsuz kalır (horn_world.gd:284). |
| 10g, 27 | galata.gd (Galata) | "galata" | Kuzey kıyı (−913, −0.4, −1322) | EVET/KISMEN | Rıhtım ve sokak kendi; dünyadaki Galata GalataView (galata_view.gd) |
| 30, 30o | blachernae.gd | "blachernae" | (−640, 0, 0) | KISMEN | Bölümün kendi suru 12 m, 4 kule (±20, ±40) + 2 köşe kulesi, Tekfur cephesi 26×16 m pencereli; dünyanın uzak Blakherna'sı (horn_world.gd:641) **farklı ölçüde kutular**: 16 m sur, 6 kule, 30×22 m pencerisiz kutu |
| 17o | chapter17o.gd | "springs" | Kasımpaşa kıyısı (−920, −1150) | EVET | Batarya |
| 18, 18b | horn.gd (Horn.build) + chapter | "horn_bridge" | Osmanlı köprüsü (−762, −1.6, −90) | EVET | Köprü ve iki kıyı yerel |
| 31o | horn.gd + ByzCity aya + FallenCity | "eyup" + "byz_aya" | Eyüp (−700, 250) | EVET | Fetih sonrası yıkık şehir (fallen_city.gd) kendi ufku |
| 38o | horn.gd + chapter38o (BAŞKASININ) | "horn_wall_o" | Petrion yakını (−762, −560) | EVET | |
| 39o | petrion.gd | "petrion" | Petrion kapısı (−694.5, 0, −650) | EVET | Cadde kendi |
| 8y | chapter8y.gd (BAŞKASININ) | çalışma anında eklenen bölge (REGIONS[REGION] = kapı x 37) | Kara surlarının x 37 kapısı | EVET | REGIONS'u çalışırken değiştiriyor (kayıt arayüzü yok) |
| 10a, 12, 13 (dal) | otag_hall.gd | — | Otağın içi | HAYIR | İç mekân; dünyada otağ (siege_field.gd `_otag`, (30, 480)) var ama kapıdan girilen hücre değil, ayrı sahne |
| 10l, 21o | chapter içi (tünel) | — | Lağım tüneli | HAYIR | Yeraltı iç mekân, kendi ortamı |
| 33o | bogaz.gd | — | Rumelihisarı (1452) | HAYIR | Ayrı coğrafya (Boğaz'ın kuzeyi; World1453'ün dışında) |
| 34o, 17 (ara) | edirne_yard.gd, edirne_palace.gd | — | Edirne | HAYIR (başka şehir) | Meşru: İstanbul değil |
| 35o | thrace_road.gd | — | Trakya yolu | HAYIR (başka yer) | Meşru |
| 1, 3, 5, 8, 14, 15 | bedroom/garage/bureau/hardware_store/street1977 | — | 2026 / 1977 | — | 1453 değil |

Özet: **"Tek harita" mimari olarak gerçek** (World1453.build ile 14 bölge aynı dünya koordinatında kuruluyor), ama
(1) her bölgenin *kendi* ayrıntılı yapısı yalnız o bölümde var; başka bölümlerde aynı yerde dünyanın ayrı, kaba bir
modeli çiziliyor (Ayasofya, hub, Blakherna, Galata, sütun); (2) 4a ordugâhı, otağ içi, tünel, Boğazkesen dünyaya
bağlı değil. Oyuncunun "havadaki İstanbul'un yerdekiyle alakası yok" sözü (1)'in sonucu.

## B. World1453'ün bugünkü mimarisi

- **Bölge kaydı**: `World1453.REGIONS` (world1453.gd:77) ad → Transform3D (yerel → dünya). Bölüm kendi alanını yerel
  koordinatta kurar, `World1453.build(parent, bölge, keep_local, gece, blend_local)` (world1453.gd:215) dünyanın
  geri kalanını bölge dönüşümünün tersiyle ekler. `keep`: bölümün oynanış dikdörtgenleri (dünya oraya ev/çadır/ağaç
  koymaz, zemini `flat_y`'ye indirir, `BLEND` ile rampalar). 8y kaydı çalışırken `REGIONS[...] = ...` ile ekliyor.
- **Coğrafya**: tek yükseklik fonksiyonu `ground_h` / görünen yüzey `surface_h` (world1453.gd:173, 186), su
  `is_water`, kıyılar `horn_n_x`, `marmara_x`, `asia_z`.
- **Kurulan katmanlar**: SiegeField (siege_field.gd — sur kuşağı, ova, ordugâh, otağ; BAŞKASININ değil ama listemde yok)
  → HornWorld (horn_world.gd: su, kuzey kıyı + GalataView, şehrin doğu yarısı, kıyı surları, zincir, Blakherna, anıtlar,
  uzak siluet) → WallRear/RearLife (sur arkası) → Landmarks1453 (tarihî yapılar, siluet, gemiler, kıyı ağı).
- **Tek kaynaklar**: `CityPlan` (city_plan.gd: cadde grafiği, meydanlar, ev yerleri; anıt tabanlarını boş bırakır),
  `Landmarks1453.DATA` (yapı listesi), `World1453.LANDMARKS` (yerler). Evler `CityHouses` (Kit.house pişirilip 3 katman:
  yakın 55 m, orta 260 m, uzak kutu; MultiMesh hücreleri 60/400 m).
- **Akış / yükleme**: `WorldWalk` (world_walk.gd) görüntüyü karelere yayarak katılaştırır (12 ms/kare bütçe), suya
  düşmeyi yakalar. `CityLife` oyuncunun çevresinde siviller (akış). `CityStream` (city_stream.gd) yalnız eski panorama
  (CampDay in_world=false) ve ByzCity "all" için — **tek haritada kullanılmıyor**. `ShaderWarmup.after_world`
  gölgelendiricileri yüklemede derler.
- **Uçuş**: `WorldFlight.attach` (world_flight.gd) yalnız 7 ve 11'de: 20 m ızgaralı zemin üçgenleri, su yakalayıcılar,
  Ayasofya/Galata/sütun konma gövdeleri; Dressing'le kurulan kıyı surları için `flight_boxes`. Yapıların çoğu
  `NihatPowers.ensure_flight_solids` (BAŞKASININ: scripts/player) ile ilkel ağlardan katılaşır.
- **Ayrıntı düzeyi**: CityHouses 3 katman; `Landmarks1453.skyline` uzak siluet (SK_NEAR'dan ötesi; yakın model
  `visibility_range_end`); gemiler/kayıklar `visibility_range_end` 1400 m. Özel yapılar için ortak bir LOD yardımcısı yok.
- **Bir bölümün bağlanma örnekleri**: 31o `World1453.build(_stage, "eyup", …)` + `ByzCity(part="aya")` (iki bölge aynı
  sahnede); 38o `Horn.build(...)` sonra `World1453.build(self, "horn_wall_o", keep, true)`; 17o "springs" keep
  dikdörtgeniyle; 18 köprü `horn_bridge` (FLAT_Y/BLEND yok, Horn kendi suyu); 8y REGIONS'a çalışırken yazar.

## C. Hedef mimari önerisi

İlke: **bir yapının tek kurucusu var; yer, biçim, renk her bölümde aynı; uzaklık yalnız ayrıntıyı değiştirir.**

1. **Bölge kaydı (Region)** — `World1453.REGIONS` sabit tabloyu `World1453.register(ad, xf, rect_local, builder)` ile
   genişletmek: her bölge kendi dünya dikdörtgenini ve *uzak kurucusunu* kaydeder. Aktif bölge tam ayrıntıyla kendi
   bölümünde kurulur; **aktif olmayan her kayıtlı bölge** dünyada kendi kurucusunun uzak sürümüyle (birleşik ağ) durur.
   Böylece hub, Ayasofya meydanı, Blakherna, Galata rıhtımı, Petrion caddesi her bölümde aynı yerde aynı biçimdedir.
2. **Ortak kurucu = yayımcı (emitter)**: özel yapı geometrisi `static func X_parts(emit: Callable)` biçiminde tek yerde;
   bölümün kendi sahnesi `emit`'i Props ile (katı, desenli), dünya Dressing ile (birleşik, uzak) karşılar. Bu sürümde
   örnekleri: `Blachernae.shell_parts`, `ByzCity.column_parts` (bkz. §F arayüz).
3. **Mesafeye göre ayrıntı (3 kat)**: yakın (<60 m) bölümün tam modeli ya da hücre akışı; orta (60–400 m) yayımcıdan
   birleşik ağ (tek çizim + dış çizgi); uzak (>400 m) `Landmarks1453.skyline` siluet. Geçiş `visibility_range_*` ile,
   kenar payıyla (popping yok).
4. **Hücre/semt akışı**: şehir 64 m hücrelere bölünür (CityStream'in iş parçacıklı üretimi dünyaya taşınır), yaklaşınca
   tam ayrıntı, uzaklaşınca boşaltılır; kalabalık (CityLife) ve ışıklar (OmniLight) mesafeyle seyrelir; uzakta MultiMesh.
5. **İç mekânlar**: otağ, Ayasofya içi, tünel, kançılarya odaları haritadaki kapıdan girilen ayrı hücre (görünürlük
   sınırı 70 m, Ayasofya.build bunu yapıyor: örnek alınabilir).
6. **Kurulum kareye yayılır** (WorldWalk gibi 12 ms bütçe); yüklemede takılma yok.
7. **Bütçe**: her sahne bugünkü RINFO'sunu aşmaz; öneri tavan: yerde çizim ≤ 900, üçgen ≤ 2,5 M; uçuşta çizim ≤ 1200,
   üçgen ≤ 3,5 M (gl_compatibility, llvmpipe ölçümleri §G'de).

## D. Göç planı (paketler)

**P0 — ortak altyapı (SEN/bu ajan, herkes bekler; scripts/world/*):**
- P0.1 `World1453.register` + aktif olmayan bölgelerin uzak kurucusu (hub, aya, blachernae, galata, petrion).
- P0.2 Yayımcı arayüzü ve birleşik-ağ pişiricisi (Dressing tabanlı) + `visibility_range` yardımcısı.
- P0.3 Ateşler: `Flame.from_glow_boxes` (Dressing.glow kutularını aleve çevirir) + flame.gdshader tepeden bakış.
- P0.4 Özel yapılar tek kurucu: Ayasofya dış kabuğu (byz_city `_build_aya_exterior` → static), Konstantin Sütunu
  (`ByzCity.column_parts`), Blakherna (`Blachernae.shell_parts`).

**Bağımsız göç paketleri** (P0'dan sonra paralel):

| Paket | Bölümler | Dosyalar | Haritadaki yer | Zorluk | Ortak gereksinim | Kabul |
|---|---|---|---|---|---|---|
| G1 Ordugâh birliği | 4a | camp.gd, chapter4.gd | Maltepe ordugâhı ("camp" bölgesinde ayrı bir yerel dikdörtgen: esir alanı) | Orta | P0.1 | 4a'nın esir alanı CampDay'in ordugâhında, havadan 7a/11'deki yerle aynı; testler |
| G2 Otağ içi | 10a, 12, 13 | otag_hall.gd | Otağ (30, 480): kapıdan girilen iç hücre | Orta | P0.1 | Dışarıdan otağın kapısı, içeride aynı otağ; RINFO |
| G3 Hub şehir dokusu | 6b, 7b, 10h, 12b, 23, 24 | byz_city.gd, city_plan.gd | byz_walls | Yüksek | P0.1, P0.2 | Hub'ın sokakları CityPlan grafiğine işlenir; hub evleri = CityHouses türü; havadan/yerden aynı |
| G4 Ayasofya meydanı | 24, 25, 26, 31o | byz_city.gd, ayasofya.gd, landmarks1453.gd | byz_aya | Orta | P0.4 | Tek Ayasofya, tek sütun yeri |
| G5 Galata | 10g, 27 | galata.gd, galata_view.gd | galata | Orta | P0.2 | GalataView = Galata'nın uzak sürümü |
| G6 Kıyı surları | 4b, 17, 19, 29, 38o, 39o | sea_walls.gd, petrion.gd, horn_world.gd | horn_chain, petrion, horn_wall_o | Orta | P0.2 | Kıyı suru tek kurucudan |
| G7 Tünel | 10l, 21o | chapter10l/21o | kara surlarının altı (gedik yakını) | Düşük | P0.1 | Giriş ağzı ovada gerçek yerinde |
| G8 Boğazkesen | 33o | bogaz.gd | World1453 dışı (kuzeyde) | Yüksek | dünyanın Boğaz'ını kuzeye uzatma | İsteğe bağlı |

## E. Kare kanıtlı kusur listesi ve durumu (önem sırası)

Kare dizini: `kare/` (c11o = 11 önce, c11s/p11t = 11 sonra, c7ao/c7as/c7at = 7a önce/sonra, c4o/c4s = 4a gece ordugâhı,
g6/g25/g27/g30 = yerden, c7bs = 7b sonra). Çiftler `cift/` (sol önce, sağ sonra, aynı koşu düzeni, aynı nokta ve açı;
"önce" koşusu dosyalarım e551de84'e geçici döndürülerek alındı: `before.sh`, sahne kurulunca geri konup `cmp` ile doğrulandı).

| # | Önem | Kusur (kare) | Neden (dosya:satır, e551de84) | Düzeltme | Durum |
|---|---|---|---|---|---|
| 1 | YÜKSEK | Askerlerin halkasındaki ateşler sarı/turuncu KUTU (c11o_ring15, c11o_ringtop) | siege_field.gd:974-975, 1117, 561, 1173; wall_rear.gd:247, 826; horn_world.gd:186/416/431 → `Dressing.glow` = emisyonlu kutu | `Flame.from_glow_boxes` (flame.gd): ateş renkli kutuları ağdan söker, aynı yere çoklu ağ alev koyar; World1453.build bütün dünyaya, sea_walls/blachernae/horn kendi köklerine uygular | DÜZELDİ (cift/01, 02, 03, 11_ring15) |
| 2 | YÜKSEK | Alev tepeden bakınca kenarından görünür (dörtgen çizgi) | flame.gdshader:38-42 (yalnız y ekseninde dönen dörtgen) | Bakış dikleştikçe dörtgen kameraya yatar, alevin ortasına taşınır, biçim yuvarlak dil dil ateşe geçer (skip_vertex_transform) | DÜZELDİ (cift/02 tepeden alevler yuvarlak; 4a_ftop/f3/f15 bozulma yok) |
| 3 | YÜKSEK | İki Ayasofya: havada 70×76 m kızıl kutu + mavi küreler (c11o_aya, c7ao_aya) | scenery.gd:510 hagia_merged; yerde byz_city.gd:525 başka model | Yerdeki kabuk `ByzCity.aya_exterior` (tek kurucu) + Ayasofya'nın "exterior" parçaları → `World1453.far_aya` pişirir; 90 m'den öte tek yüzeyli kopya; uzak siluet aynı ölçüde; byz_aya bölgesi tepenin yüzeyine (AYA_Y 17,6) kaldırıldı (eskiden aya bölümlerinde 17 m çukur); meydan her bölümde düz (`World1453.city_ground`) | DÜZELDİ (cift/11_aya, 7a_aya, 11_hipp) |
| 4 | YÜKSEK | Hub (6b/7b'nin caddesi, kançılarya, saray, kapı) uçuşta yok; yerinde tarla (c11o_romanos, p11o_hubtop, c7ao_hubtop) | World1453.build bölgeyi yalnız kendi bölümünde kurar | `World1453.FAR_REGIONS` + `ByzCity.far_hub`: hub'ın kendi kurucuları sahne dışında, pişirilmiş (dokulu ≤300 m, düz >300 m), bölümün çarpışma kutularıyla | DÜZELDİ (cift/11_romanos, 11_hubtop, 7a_hubtop) |
| 5 | ORTA | Bozdoğan Kemeri görünmüyor: toprağa gömülü (c11o_aqued) | horn_world.gd:736-749 tepe mutlak 20 m, zemin 18–22 m | Tepe en yüksek zeminin üstünde (`HornWorld.aqueduct_top`), iki katlı gerçek kemerler (kemer taşları, dolgu, kuşak, kanal) | DÜZELDİ (cift/11_aqued, 7a_aqued) |
| 6 | ORTA | Havariyun kutu haç + silindir + top (c11o_apost) | horn_world.gd:724-734 | Kiremit beşik çatılı haç kolları, hatıllar, iki sıra pencere, pencereli kasnaklı 5 kubbe, apsis, narteks (birleşik ağ) | DÜZELDİ (cift/11_apost, 7a_apost) |
| 7 | ORTA | 22 mahalle kilisesi kutu+silindir+top (c11o_apost sol alt) | horn_world.gd:247-257 | Kapalı Yunan haçı kilise (`HornWorld._church`): beşik çatılar, kasnaklı kubbe, apsis, narteks, pencereler; Props düğümleri yerine birleşik ağ (çizim azaldı) | DÜZELDİ (cift/11_apost) |
| 8 | ORTA | Blakherna uzak görünüşü bölümünkinden farklı ölçüde kutular; saray pencerisiz desenli kutu; dışı düz gri levha (c11o_blach) | horn_world.gd:641-661 | `Blachernae.shell_parts` tek kurucu; dünya aynı parçaları pişirir (dokulu); ışıklı pencereler gece; dış zemin toprak deseni | DÜZELDİ (cift/11_blach, 7a_blach) |
| 9 | ORTA | Konstantin Sütunu düz pembe silindir (c11o_column) | horn_world.gd:285 | Yerdeki sütunun biçimi (`ByzCity.column_parts`: kaide, porfir gövde, altın halkalar); uçuş konma/parça yükseklikleri buna göre | DÜZELDİ (cift/11_column) |
| 10 | ORTA | Hipodrom iki düz kutu duvar | horn_world.gd:276-282 | Dış yüzde iki kat kemer açıklıkları, saçak/kuşak, carceres kapıları ve iki kule, kathisma (kubbeli loca), dikilitaş kaidesi ve piramidion | KISMEN (cift/11_hipp: kathisma ve kapılar seçiliyor; kemerler dış yüzde, bu açıdan az görünür) |
| 11 | ORTA | Büyük Saray dört düz kutu | horn_world.gd:287-291 | Teraslar: kemerli destek duvarı, korkuluk silmesi, bahçe/döşeme | DÜZELDİ (cift/11_aya sağ üst, 7a_aya) |
| 12 | ORTA | Galata evleri pencereli beyaz kutular, rastgele (c11o_galata) | galata_view.gd:30-60 | Dünyada GalataView evleri CityHouses (Kit evleri, üç ayrıntı katmanı: Galata bölümündeki ve şehirdeki evlerle aynı tür); iç içe girmesin diye 11 m aralık | DÜZELDİ (cift/11_galata, 11_galtop, 7a_galata); yerleşim yoğunluğu azaldı (AÇIK not) |
| 13 | DÜŞÜK | Kuzey kıyıda 420 çadır üçgen prizma | horn_world.gd:184 | Yuvarlak keçe gövde + sivri tepe (Night.tent biçimi) | DÜZELDİ (uzak; c11t_blach sol üst) |
| 14 | DÜŞÜK | Ova zemininde dikdörtgen renk yamaları (c11o_ringtop) | siege_field.gd arazi boyası | — | AÇIK (dosya listemde yok) |
| 15 | DÜŞÜK | 7a mutfak ateşleri kazanların altında (kittop karesi çatıya düştü) | — | gece (11) ve 4a kareleri kullanıldı | BAKILAMADI (gündüz ateş tepeden) |

## F. Ortak arayüz (göç paketleri için) — bu sürümde depoda

Üç küçük parça; hepsi scripts/world/world1453.gd (+ bölge kurucusunda bir statik işlev):

1. **Tek kurucu = yayımcı.** Yapının geometrisi bir kez yazılır; bölümün sahnesi ve dünya aynı işlevi çağırır.
   ```gdscript
   # blachernae.gd
   static func shell_parts(emit: Callable, part: String) -> void:
       emit.call("box", Vector3(120, WALL_H, t), Vector3(0, WALL_H * 0.5, z), C_STONE, "ashlar", true, "no_climb")
       ...
   func _wall() -> void:                       # bölümün kendisi: Props (katı, desenli)
       shell_parts(_emit, "wall")
   # horn_world.gd (dünya): aynı parçalar sahne dışında kurulur, sonra pişirilir
   for part in ["wall", "palace", "join"]:
       Blachernae.shell_parts(emit, part)
   World1453.bake(tb.find_children("*", "MeshInstance3D", true, false), tb, Transform3D(Basis.IDENTITY, o), self, "FarBlachernae")
   ```
   Örnekler: `Blachernae.shell_parts`, `ByzCity.column_parts` (emit(tür, boyut, konum, renk, katı)), `ByzCity.aya_exterior(host)`
   (host'a Props ile kurar; bölüm `self`, dünya geçici düğüm verir).
2. **Pişirici** `World1453.bake(list, top, xf, parent, ad, min_size := 0.05, max_tris := 0) -> MeshInstance3D`: Props/Kit
   parçalarını tek MeshInstance3D'ye toplar; düz renkler köşe renginde tek yüzey (Dressing malzemesi), dünya üçlü düzlem
   desenli parçalar doku başına bir yüzey (yerdeki dokunun aynısı); ışıklı/saydam/gölgelendiricili/yazı/insan atılır;
   `max_tris` hazır modeli (Kit çatısı) aynı kutuyu dolduran beşik çatıyla değiştirir; `generate_lods` ile uzak LOD'lar.
3. **Uzak bölge kaydı** `World1453.FAR_REGIONS = {bölge: oynanış dikdörtgeni (yerel)}`: `World1453.build` aktif olmayan her
   kayıtlı bölgenin dünya dikdörtgenini `keep`'e ekler (dünya oraya ev/ağaç/kalabalık koymaz) ve bölgenin uzak kurucusunu
   çağırır (`match` içinde: `"byz_walls": ByzCity.far_hub(f, region(fr))`). Bölümün kendi alanıyla kesişirse kurulmaz.
   Yeni bölge eklemek (göç paketi):
   ```gdscript
   # world1453.gd
   const FAR_REGIONS := {"byz_walls": Rect2(-46, -48, 84, 70), "camp_pen": Rect2(...)}
   ...
       "camp_pen": Camp.far_pen(f, region(fr))     # bölgenin kurucusu: static func far_pen(parent, xf) -> MeshInstance3D
   ```
   `far_*` işlevinin kalıbı `ByzCity.far_hub`: `X.new()` (ağaca eklenmeden), yapı kurucularını çağır, `World1453.bake(...)`,
   çarpışma şekillerini (CollisionShape3D) aynı dönüşümle tek StaticBody'ye kopyala, `queue_free()`.
   Deferred iş (ağaç isteyen) `is_inside_tree()` ile korunur (bkz. `ByzCity._plant_cypresses`).
4. **Arazi düzlüğü**: bölgenin oynanış alanı her bölümde aynı yükseklikte olmalı (`World1453.city_ground` Ayasofya
   meydanını AYA_Y'de düzler; bölge dönüşümünün y'si = o yüzey). Yeni bölge tepedeyse aynı kalıp.
5. **Ateş**: `Dressing.glow(..., Color("ffa030"|"ffa040"|"ffb040"|"ffb050"))` ile kurulan ateşler `Flame.from_glow_boxes(kök)`
   ile alev + haleye çevrilir (World1453.build bunu bütün dünyaya uygular; bölüm kendi Dressing kökü için çağırabilir).

## G. RINFO / testler

Ölçüm: ekranlı (xvfb, llvmpipe), aynı koşu düzeni, her bakışta 5 karenin ortancası (çizim / üçgen, bin). Önce = dosyalarım
e551de84'e geçici döndürülmüş (before.sh).

**Bölüm 11 (gece, uçuş)** p11o → p11v (son kod):

| bakış | çizim önce→sonra | üçgen önce→sonra | Δ üçgen |
|---|---|---|---|
| camp50 | 3952 → 3951 | 3668k → 3658k | −0,3 % |
| ring15 | 2207 → 2173 | 3914k → 3876k | −1,0 % |
| walls | 1490 → 1292 | 1691k → 1701k | +0,6 % |
| city | 1051 → 824 | 1151k → 1176k | +2,2 % |
| aya | 392 → 311 | 623k → 634k | +1,8 % |
| hipp | 435 → 381 | 691k → 706k | +2,2 % |
| column | 737 → 562 | 1022k → 1026k | +0,4 % |
| apost | 1054 → 796 | 1187k → 1223k | +3,0 % |
| aqued | 932 → 708 | 1068k → 1114k | +4,3 % |
| blach | 1067 → 842 | 1097k → 1157k | +5,5 % |
| galata | 288 → 169 | 227k → 235k | +3,5 % |
| romanos | 3596 → 3540 | 5834k → 5958k | +2,1 % |
| galtop | 323 → 209 | 231k → 246k | +6,5 % |
| hubtop | 432 → 441 | 705k → 743k | +5,4 % (çizim +9; p11t'de 425: koşu oynaması, min 424→435) |

**Bölüm 7a (gündüz, uçuş)** c7ao → c7at:

| bakış | çizim | üçgen | Δ üçgen |
|---|---|---|---|
| kit3 (mutfak ateşi, 2,5 m) | 6591 → 6395 | 8340k → 8400k | +0,7 % |
| kit15 | 3741 → 3733 | 4432k → 4432k | 0 |
| kittop | 1749 → 1755 | 2933k → 2931k | 0 (çizim +6, min 1729→1721) |
| camp50 | 4528 → 4534 | 3967k → 3970k | +0,1 % (çizim +6; aynı kodla iki koşu arası oynama 4504–4534) |
| aya | 418 → 338 | 641k → 662k | +3,3 % |
| romanos | 3646 → 3617 | 5919k → 5935k | +0,3 % |
| hubtop | 516 → 464 | 782k → 784k | +0,3 % |
| blach | 1033 → 828 | 1121k → 1192k | +6,3 % |
| apost | 1030 → 774 | 1174k → 1208k | +2,9 % |
| galata | 292 → 160 | 206k → 210k | +1,9 % |
| hipp | 450 → 396 | 734k → 749k | +2,0 % |
| aqued | 916 → 690 | 1050k → 1096k | +4,4 % |

**Bölüm 7b (gündüz, uçuş, hub bölgesi)** c7bo → c7bs: hubtop 5007/2590k → 5007/2589k; romanos 8000/7391k → 7994/7438k
(+0,6 %); aya 455/639k → 375/653k (+2,2 %); camp50 1591/2988k → 1591/2988k; blach 1046/1139k → 831/1192k (+4,7 %);
column 731/1017k → 555/1021k (+0,4 %).

Kare hızı: bu makinede (llvmpipe, yük ortalaması 12–21) ölçülen fps her iki sürümde de 1–2; düşüş görülmedi, anlamlı
bir kare hızı karşılaştırması bu makinede yapılamaz (KANITSIZ). Çizim sayısı uçuş bakışlarının hemen hepsinde azaldı
(Props düğümleri yerine birleşik ağ; ateş kutularının parça ağları yerine tek çoklu ağ).

**Testler (son kodla, başsız):** 48/48 RUNOK, 0 RUNFAIL, 0 SCRIPT ERROR / VISAUDIT / WALKTHRU / ARMAUDIT: 3; 7 (=, byz, byzniko,
tea, form, wall); 11 (=, arrest, escape, persuade, help, helpwall, lost, fired, hikmet, niko); 4 (=, item, caught, market,
chain, nofez, fall, fez, wet); 6 (=, byz); 8; 8y; 9; 10; 24o; 32o; 43o; ek olarak 2, 17, 17o, 18, 19, 24, 25, 26, 27, 29,
30, 31o, 39o. (`tests_final.log`). flight_check PASS, parse_check PASS. Görünürlük payı düzeltmesinden sonra 7, 11, 25
yeniden RUNOK.

## H. Göç paketlerinde benim yaptığım / kalan

- **G3 hub**: YAPILDI: hub'ın uzak görünüşü her tek harita bölümünde gerçek yerinde (ByzCity.far_hub, aynı kurucular,
  çarpışmalı; dünya orada ev/ağaç koymaz). KALDI: hub sokaklarının CityPlan grafiğine bağlanması (CityPlan caddeleri hub
  dikdörtgeninde kesiliyor; hub'ın evleri `_house`/`_build_fill` kutu-sıva evleri, dünyanınkiler Kit evleri: iki ev üslubu
  yan yana); LandWalls bölümlerinde (0, 20…) surun içi LandWalls/SiegeField'in kendi şehri (absf(x)<56) — hub orada yok
  (land_walls.gd başkasının dosyası, World1453.build çağırmıyor).
- **G4 Ayasofya**: YAPILDI: tek Ayasofya modeli (aya_exterior), bölge yüksekliği, meydan düzlüğü, siluet, uçuş konma
  noktası. KALDI: aya parçasının dolgu evleri (_build_fill) dünyada uzak kurulmuyor (yerinde CityPlan evleri); Konstantin
  Sütunu iki yerde (aya parçasında Ayasofya'nın 60 m batısında "ev:column" etkileşimi; dünyada forumda) — biri seçilmeli
  (oynanış etkileşimi yerdeki sütunda).
- **G5 Galata**: YAPILDI: dünyadaki Galata evleri Kit evleri (CityHouses). KALDI: galata.gd'nin rıhtım sırası ve kulesi
  (_build_tower) ile GalataView'in kulesi ayrı kurucular; GalataView'in evleri rastgele serpiliyor (sokak dokusu yok).
- **G6 kıyı surları**: YAPILDI: nöbet ateşleri alev. KALDI: sea_walls.gd'nin sur kesiti ile HornWorld._wall_run ayrı
  kurucular (ölçü/renk farkı), petrion.gd caddesi dünyada uzak kurulmuyor.

## I. "Tek harita" sorusunun cevabı

Önce: koordinat olarak tekti (14 bölge World1453'te gerçek yerinde), ama bir bölgenin ayrıntılı yapısı yalnız o bölümde
vardı; öbür bölümlerde aynı yerde dünyanın ayrı, kaba bir modeli çiziliyordu (Ayasofya iki kat büyük ve başka renkte, hub
yerine tarla, Blakherna başka ölçüde, sütun başka biçimde). Nihat'la havadan görülen şehir, Tolga'nın yürüdüğü şehir değildi.
Şimdi: Ayasofya, hub, Blakherna, Konstantin Sütunu yerdeki kurucularından (aynı yer, ölçü, renk, doku) dünyaya pişiriliyor;
uçuş bölümleriyle yerdeki bölümler bu yapılarda aynı. Hâlâ ayrı olanlar §H'de (ev üslubu, Galata ve kıyı surlarının
ayrı kurucuları, LandWalls'ın iç şehri, 4a ordugâhı, otağ içi).
