# İstanbul, Nisan 1453 — şehrin ana planı

Dal: `wip/istanbul`. Bu belge şehri kurmanın kurallarıdır. Önce şehir kurulur, bölümler sonra bu şehrin içine yerleştirilir.
Hedef: Tolga'nın yürüdüğü İstanbul ile Nihat'ın üstünden uçtuğu İstanbul aynı şehir olsun.

Sahibin sözü: "tüm İstanbul tek harita, tüm görevler aynı harita; her şey tam içerik ve kaliteyle haritada oynanacak;
performans için yaratıcı çözümler: uzakken yüklenmez."

Tarih araştırması başka bir oturumda yazılıyor (`wip/istanbul-arastirma`: `docs/ISTANBUL_1453.md`,
`docs/ISTANBUL_YERLER.csv`). Bu sürüm yazılırken o dal henüz yoktu (`git fetch` → "couldn't find remote ref").
Buradaki tarih bilgisi benim bilgime dayanıyor. Araştırma gelince §2 ve §3'teki ayrıntı dizinleri ve dayanak
koordinatları (`CityGeo.ANCHORS`) ona göre düzeltilecek. Yer dizini `CityGeo.load_places` ile doğrudan haritaya düşer.

İçindekiler: §1 ölçek ve dönüşüm · §2 mahalle çizelgesi · §3 bölüm yerleşim tablosu · §4 yapı dili (kit) · §5 oynanış
kuralları · §6 akış ve performans mimarisi · §7 paketler · §8 açık sorular.

---

## 1. Ölçek kararı ve koordinat dönüşümü

### 1.1 Seçenekler

| Seçenek | Şehir boyu (kara surundan burna) | Yürüyerek (5,2 m/sn koşu) | Uçarak (7 m/sn) | Bölgeler yerinde kalır mı | Karar |
|---|---|---|---|---|---|
| A. Gerçek ölçek 1:1 | ~5,5 × 6 km | Romanos → Ayasofya ~5 km: **16 dk** | 12 dk | Hayır: her bölge yeniden konur, 50+ bölüm yeniden sınanır | RET |
| B. Yarım ölçek 1:2 | ~2,8 × 3 km | 8 dk | 6 dk | Hayır | RET |
| **C. Bugünkü sıkıştırılmış harita (≈ 1:3,5), yapılar 1:1** | ~1,4 × 1,7 km | **5 dk** | **4 dk** | **Evet** (14 bölge ve bütün anıtlar yerinde) | **SEÇİLDİ** |

### 1.2 Gerekçe
- **Yapılar ve sokaklar 1:1, aralarındaki boşluk sıkıştırılmış.** 1453'te şehrin içi dolu değildi: kara surlarının
  dibinden Havariyun'a kadar bostanlar, bağlar, açık sarnıçların içinde bahçeler, harabeler ve birbirinden kopuk
  "köy" mahalleleri vardı. Nüfus 40–50 bin civarına düşmüştü. Sıkıştırırken bu boşlukları kısaltıyoruz, yoğun
  çekirdekleri gerçek sıklıkta bırakıyoruz: Mese çarşısı, Haliç iskeleleri, Petrion, Blakherna çevresi ve hub. Oyuncu
  1:1 evlerin arasında yürür, ama Romanos'tan Ayasofya'ya 5 dakikada varır. Gerçekte bu yol bir saat sürer.
- **Bölümler arası yol süresi:** Tolga'nın bölümlerinde yürüme mesafesi hep 20–150 m. Nihat'ın uçuşunda (7, 11)
  bütün şehir 4 dakikada geçilir: yan görevlerin (seyyah, forms, perch) noktaları bugünkü uzaklıkta kalır.
- **Performans:** 1,4 × 1,7 km'lik şehirde 96 m'lik parça ızgarası ~260 parça demek (§6). Bu sayı akışla
  taşınabilir. 1:1'de ~3300 parça olurdu.
- **Yerleri korumak:** `World1453.REGIONS` içindeki 14 bölge ve `LANDMARKS` aynen kalır. Bu dalda başka oturumlar
  da çalışıyor (`wip/tekharita*`); yer değiştirmek onların bütün işini geçersiz kılardı.

### 1.3 Dönüşüm işlevi (`scripts/world/city_geo.gd`, `CityGeo`)
- Gerçek koordinat: Ayasofya (0, 0); e doğuya, n kuzeye, metre. Enlem/boylamdan hesaplanır:
  `e = (boylam − 28,9802) · 111 320 · cos 41,01°`, `n = (enlem − 41,0086) · 111 320` (`CityGeo.ll_to_real`).
- `CityGeo.real_to_world(r)` iki adımda çalışır:
  1. **Afin uyum.** 19 dayanağa en küçük kareler uyumu (`AX`, `AZ`, `T`):
     `x = −0,1343 e − 0,2101 n − 445,6`, `z = −0,3239 e + 0,0972 n − 1553,3`.
     Ölçek √|det| = 0,285, yani gerçeğin ~1/3,5'i. Dünya ekseni aynalı: kuzey ≈ −x, doğu ≈ −z.
  2. **Bükme.** Afin uyumdan sonra dayanaklarda 63–448 m fark kalıyor (en büyüğü Kız Kulesi). Bu fark ince levha
     eğrisiyle (thin plate spline, km cinsinden, `TPS_*` + `ANCHORS[i][3]`) sıfırlanır: dayanak tam yerine düşer
     (ölçülen en büyük hata 5 cm), aradaki noktalar yumuşakça bükülür. İlk denemede Shepard (1/d²) bükmesi kullandım.
     O yöntem dayanakların çevresinde 80 ızgara hücresinde haritayı katlıyordu (iki gerçek nokta aynı dünya noktasına
     düşüyordu). İnce levha eğrisiyle 100 m'lik 5676 noktalık ızgarada katlanma yok. Katsayıları üreten araç:
     `docs/_kanit_istanbul/arac/geo_tps.py`. Dayanak değişirse katsayılar bu araçla yeniden üretilir.
- Ters yön için `CityGeo.world_to_real(w)` var: afin tersten başlayıp sayısal Jacobian'lı Newton adımları (ölçülen gidiş-dönüş hatası 0,2 m). `CityGeo.ll_to_world(enlem, boylam)`
  dünya noktasını `World1453.surface_h` yüksekliğinde verir.
- **Yer dizini:** `CityGeo.load_places("res://docs/ISTANBUL_YERLER.csv")` başlığı tanır: `enlem`/`lat` +
  `boylam`/`lon` ya da `dogu_m`/`e` + `kuzey_m`/`n`, ad sütunu `ad`/`name`. Her satır `{ad, real, world, row}` döner.
  Mahalle paketleri anıt ve kilise yerlerini buradan alır; kendi başlarına koordinat uydurmazlar.
- **Dayanaklar (`CityGeo.ANCHORS`):** Ayasofya, Hipodrom, Konstantin Sütunu, Tauri, Havariyun, Pantokrator,
  Pammakaristos, Petrion, Kariye, Blakherna Sarayı, Harisios, Romanos, Pege, Altınkapı, Studios, Eugenius, Galata
  Kulesi, Damalis, Eyüp. Gerçek konumları ±50 m doğrulukta, benim bilgimden. Araştırma dizini gelince güncellenecek.
  Yeni bir bölge eklenirse dayanak olarak da eklenir.
- **Tutarlılık kuralı:** bir yapının dünyadaki yeri tek kaynaktan gelir: `World1453.LANDMARKS` (bugünküler),
  `CityGeo` (yeniler), `CityPlan` (sokaklar). Bir bölüm, bir anıtın yerini kendi sabitinde tekrar yazmaz.

---

## 2. Mahalle çizelgesi

Dünya dikdörtgenleri (x0…x1, z0…z1) şehrin içinde (`World1453.in_city`). Yoğunluk: ev/hektar (gerçek 1453 tahmini
sıkıştırılmış haritaya uyarlanmış). Ana sokak: `CityPlan.MAIN` kaydı. "Ayrıntı dizini" o mahallede bulunması gereken
küçük şeylerdir (paket kabul ölçütü).

| No | Mahalle (1453) | Dünya dikdörtgeni | Karakter | Yoğunluk | Ana sokak | Anıtlar | Ayrıntı dizini |
|---|---|---|---|---|---|---|---|
| M01 | **Romanos / Lykos vadisi (hub)** | x −140…180, z −330…−4 | sur dibi + mahalle çarşısı; kuşatmanın merkezi | 45 | Romanos yolu (ROAD, x 37→−90) | Romanos Kapısı, kançılarya, saray avlusu, üç mahalle kilisesi | barikat, gülle yığını, taş taşıyan halk, nöbetçi ateşi, ekmek fırını, kuyu, çamaşır ipi, sur onarım iskelesi |
| M02 | Blakherna / Kaligaria | x −700…−520, z −220…−4 | saray çevresi, Latin askerleri, Venedik konağı | 40 | Harisios kolu (Mese kuzey) | Blakherna Sarayı, Tekfur cephesi, Anemas zindanı | sarayın bahçe duvarı, ahır, nöbet kulübesi, Venedik bayrağı, kilise çanı (simandron) |
| M03 | Kariye / Harisios | x −560…−380, z −260…−4 | manastır çevresi, seyrek | 20 | Mese kuzey kolu | Kariye (Khora), Aetios sarnıcı (açık, içi bostan) | manastır avlusu, ayazma, bostan sırası, keşiş hücresi, çan |
| M04 | Pempton / Lykos kuzey | x −380…−140, z −330…−4 | bostan, bağ, harabe, dağınık köy | 12 | Pempton yolu (ROAD x −230) | Lykos deresi, terk edilmiş kilise | bağ kütüğü sıraları, kuru taş duvar, harabe kemer, değirmen, kuyu, keçi ağılı |
| M05 | Rhegion / Pege | x 180…480, z −320…−4 | seyrek köy, bağ, manastır | 15 | Rhegion ve Pege yolları | Pege kaynağı (Balıklı), manastır | ayazma, bağ evi, çit, tarla, çoban |
| M06 | Studios / Psamathia | x 400…640, z −380…−4 | büyük manastır, Marmara sur dibi, balıkçı köyü | 25 | Altınkapı yolu | Studios Manastırı, Altınkapı, Marmara kapıları | manastır kütüphanesi, bahçe, balık ağı, kayık kızağı |
| M07 | Mokios / Arkadios | x 0…400, z −700…−320 | bostan ve harabe; Mokios açık sarnıcı | 10 | Mese güney kolu | Arkadios Forumu sütunu, Mokios sarnıcı (çukur bostan) | sarnıç duvarı (10 m), içinde sebze, kuyu çıkrığı |
| M08 | Petrion / Fener | x −700…−520, z −820…−380 | Rum ileri gelenleri, kilise, Haliç kıyısı | 50 | Petrion kapısı yolu | Pammakaristos, Petrion kapısı, Aspar sarnıcı | konak avlusu, şapel, merdivenli yokuş, iskele, tekne |
| M09 | Havariyun / Dördüncü tepe | x −420…−200, z −900…−620 | çarşı yolu, pazar, kilise | 45 | Mese (kuzey) | Havariyun Kilisesi, pazar meydanı | pazar tezgâhı, ahır, han, at arabası, kuyu |
| M10 | Zeyrek / Pantokrator + Bozdoğan | x −620…−380, z −1060…−840 | manastır tepesi, kemer dibi | 35 | Haliç kapısı yolu (z −900) | Pantokrator (üç kilise), Bozdoğan Kemeri | kemer altı yolu, su kanalı, manastır bahçesi |
| M11 | **Haliç iskeleleri: Venedik, Amalfi, Ceneviz, Pisa** | x −700…−600, z −1500…−850 | yabancı tüccar mahallesi, liman, ambar | 60 | Haliç kapıları yolları | iskeleler, Latin kiliseleri, kıyı surları | ambar, vinç, fıçı, balya, gemi halatı, Latin çeşmesi, loca |
| M12 | Mese ve forumlar çarşısı | x −520…−240, z −1360…−980 | sık çarşı, revaklı Mese | 70 | Mese (revaklı) | Tauri Forumu, Konstantin Forumu, Philadelphion | revak, dükkân tentesi, kuyumcu, ekmekçi, kitapçı, tartı |
| M13 | Ayasofya / Augustaion / Hipodrom | x −700…−400, z −1720…−1360 | anıtlar, Büyük Saray harabesi, kilise görevlileri | 30 | Mese'nin başı | Ayasofya, Aya İrini, Hipodrom, Milion, Yerebatan, Büyük Saray (harabe) | harabe sütunu, otlu teras, piskopos konağı, mum satıcısı |
| M14 | Marmara limanları | x −350…250, z −1350…−700 (kıyı şeridi) | liman, balıkçı, tersane | 40 | Marmara kapıları yolları | Kontoskalion, Theodosius (Eleutherios) limanı | kızak, gemi iskeleti, ağ, tuz ambarı |
| M15 | Galata / Pera (Ceneviz) | kuzey kıyı x −1150…−930, z −1450…−1250 | Ceneviz kolonisi, surlu, tarafsız | 60 | (GalataView) | Galata Kulesi, Ceneviz podestà sarayı | Ceneviz bayrağı, ambar, Latin kilisesi |

Notlar:
- M01 ilk örnek mahalledir (§7 P01; durumu `docs/_kanit_istanbul/rapor.md`).
- Açık sarnıçlar (Aetios, Aspar, Mokios) 1453'te içi bahçe olan 10–15 m derin çukurlardı. Kit tipi "sarnıç bostanı"
  (§4) bunun içindir. İçine merdivenle inilir; çevresi korkuluklu olur (düşme yok, §5).
- Minare, cami, köprü, vapur ve Osmanlı kubbesi YOK. Istanbul_prompt.txt'teki günümüz öğelerinin 1453 karşılıkları:
  minare → çan kulesi (kampanil, Latin mahallelerinde) ve simandron; vapur → kadırga, kayık, tekne; Galata Köprüsü →
  yok (Haliç'te zincir ve kayıkla geçiş); tramvay → at arabası; çay ocağı → şarap meyhanesi; simitçi → ekmekçi
  (kulluri halkası); martı aynen kalır; kedi aynen kalır.

---

## 3. Bölüm yerleşim tablosu (1453'te geçen her bölüm)

Kaynak: `tests/run_tests.sh` listesi ve `docs/_ajan/tek_harita.md` §A. "Şimdi" sütunu bugünkü kurucuyu, "Mahalle"
sütunu şehirdeki yeri gösterir. "Gereken" sütunu, bölümü şehrin içine sığdırmak için yapılacak işi söyler.

| Bölüm | Şimdi (kurucu, bölge) | Mahalle | Gereken | Çakışma (aynı yer, farklı zaman/hava) |
|---|---|---|---|---|
| 0, 20, 20o, 21, 22, 22o, 26o, 28o, 32o, 36b, 37o, 41o, 42b | land_walls.gd (+assault, wall_fight, siege_chaos), "landwalls" | M01'in sur şeridi (z −4…+60) | LandWalls `World1453.build` çağırmıyor: sur içi kendi şehri. Sur içi şeridi M01 parçalarından okunmalı (P02) | M01 hub ile aynı kapı. 0 gece, 20 şafak, 26o düşüş günü: parçalar aynı, Dressing sürümü (`era`) farklı |
| 2 | slipway.gd, "slipway" | Kasımpaşa (kuzey kıyı) | yok (şehir dışı) | — |
| 4 (4a ordugâh, 4b kıyı) | camp.gd / sea_walls.gd | ordugâh / M11 ağzı | 4a: G1 paketi (ordugâh birliği); 4b: kıyı suru tek kurucu | 4b = 17/19/29 ile aynı rıhtım |
| 6 (6a ordugâh, 6b Bizans) | camp_day / byz_city "walls" | ordugâh / **M01** | 6b: hub P01'de şehre bağlandı | 6b gündüz, 10h gece, 12b gün batımı, 23/24 kuşatma: aynı hub |
| 7 (7a ordugâh, 7b Bizans, uçuş) | camp_day / byz_city | bütün şehir (havadan) | uçuşta bütün mahalle parçaları uzak katmanda (§6) | — |
| 8y | chapter8y.gd, REGIONS'a çalışırken | M01'in batısı (x 37 kapısı) | bölge kaydını `REGIONS`'a sabit olarak taşımak | M01 kapısı |
| 9, 10, 10b, 10z, 16, 24o, 43o | camp_day "camp" | ordugâh (Maltepe) | şehir dışı; surun ardındaki şehir siluet katmanından | — |
| 10a, 12, 13 (dal) | otag_hall.gd | otağ içi | G2 | — |
| 10g, 27 | galata.gd, "galata" | M15 | G5: Galata evleri kit diliyle | — |
| 10h | byz_city "walls" (gece) | **M01** | P01 ile tamam; gece ışıkları parça başına | 6b |
| 10l, 21o | tünel | M01'in altı (gedik yakını) | G7: giriş ağzı ovada | — |
| 11 (uçuş, gece) | camp_day + WorldFlight | bütün şehir | uçuş konma noktaları her mahallede (§5.6) | 7 |
| 12b | byz_city "walls" (gün batımı) | **M01** | P01 | 6b |
| 17, 19, 19o, 29, 29o | sea_walls.gd, "horn_chain" | M11 ağzı / M13 kuzey kıyısı | G6: kıyı suru tek kurucu | 4b |
| 17o | chapter17o, "springs" | Kasımpaşa | yok | — |
| 18, 18b | horn.gd, "horn_bridge" | Haliç iç kolu | yok | — |
| 23 | byz_city "walls" | **M01** | P01 | 6b |
| 24 | byz_city "walls" + "aya" | **M01** + M13 | P01 (walls), P13 (aya: dolgu evler kit diliyle) | 25, 26 |
| 25, 26 | byz_city "aya" + ayasofya.gd | M13 | P13 | 24, 31o |
| 30, 30o | blachernae.gd, "blachernae" | M02 | P04: sarayın çevresi kit diliyle | — |
| 31o | horn.gd + byz_city "aya" + fallen_city | M13 + Eyüp | P13; yıkık şehir: aynı parçaların `era = "fallen"` sürümü | 24–26 |
| 33o | bogaz.gd | Rumelihisarı (1452) | şehir dışı | — |
| 34o, 35o | edirne / trakya | başka şehir | yok | — |
| 38o | horn.gd + chapter38o, "horn_wall_o" | M08 kıyısı | G6 | 39o |
| 39o | petrion.gd, "petrion" | M08 | P08: Petrion caddesi şehre bağlanır | 38o |

**Çakışma ilkesi:** aynı yerde geçen bölümler aynı parçaları kurar. Zaman ve hava yalnız "dönem" bayrağını değiştirir
(`CityChunks.era`: `"siege"` varsayılan, `"night"`, `"dusk"`, `"fallen"`). Dönem ışıkları, kalabalığı, yıkıntı süslerini
seçer. Ev, sokak ve çatı aynı kalır.

---

## 4. Yapı dili (kit)

Kaynak: mektup bölümünün evleri (`ByzCity._house`, `_build_street`, `_build_chancery`, `_build_palace`, `_build_fill`).
Ortak öğeler: kesme taş zemin kat (tuğla bantlı, "ashlar" deseni), sıvalı üst kat ("plaster", 6 boya), sokağa taşan
ahşap çıkma (cumba, 0,7 m) ve altında payandalar, tuğla dişli korniş, oluklu kiremit beşik çatı (`Kit.roof`; yoksa
prizma), kemerli kepenkli pencereler, kemerli ahşap kapı + basamak, duvar kandili, devşirme mermer (spolia), saksı.
Sokak üstünde bayrak ipi ve çamaşır ipi, dükkânda tente.

Kod: `scripts/world/city_kit.gd` (`CityKit`). Her tip `CityKit.<tip>(emit, params, rng)` biçiminde bir **yayımcıdır**
(`tek_harita.md` §F). Parçaları `emit` ile verir; parçaları yakın katmanda Props, orta katmanda pişirici karşılar
(§6). Çarpışma kutuları geometriden ayrı verilir (`emit.call("solid", …)`) ve her katmanda aynıdır.

Üç ayrıntı katmanı:
- **L0 yakın (< 110 m):** bütün süsler. Pencere kemer tuğlaları, kepenk, saksı, kandil, payanda, baca, spolia.
- **L1 orta (110–450 m):** gövde, çıkma, çatı (Kit çatısı yerine aynı kutuyu dolduran prizma), pencere ve kapı
  boşlukları (koyu dikdörtgen), korniş. Parça başına tek pişmiş ağ: dokulu + düz renk yüzeyi.
- **L2 uzak (> 450 m):** gövde + çatı tek kutu/prizma, köşe rengi. Mahalle başına tek MultiMesh ya da pişmiş ağ.

| Tip | Ölçü aralığı (cephe × derinlik × saçak yüksekliği, m) | L0 | L1 | L2 | Çatıya yol |
|---|---|---|---|---|---|
| sıra ev (`row`) | 4,6–7 × 4,6–6,5 × 5,6–8,0 | `_house`'un bütün öğeleri | gövde, cumba, çatı, boşluklar | kutu + prizma | komşu sundurmadan |
| avlulu ev (`court`) | 10–16 × 10–16 × 5,6–7 (avlu 4–8) | sıra ev kanatları + avlu duvarı, kuyu, asma | kanatlar + avlu | U kutusu | avlu merdiveni (dış taş merdiven) |
| dükkânlı ev (`shop`) | 5–8 × 5–7 × 6–8 | zemin katta kemerli dükkân ağzı, tezgâh, tente | ağız + tente | kutu | tenteden (1,0 m sandık → 2,2 m tente) |
| meyhane (`tavern`) | 7–10 × 6–8 × 5,5–7 | fıçılar, sıra, asma çardak, tabela | çardak | kutu | çardak (2,3 m) |
| atölye (`workshop`) | 6–9 × 5–8 × 4,5–6 | ocak (gece alev), örs, odun yığını | sundurma | kutu | sundurma (2,2 m) |
| ambar (`warehouse`) | 10–18 × 8–12 × 6–9 | büyük kapı, vinç kolu, fıçı ve balya yığını | kapı | kutu | balya yığını (1,0 → 2,0 → 3,0) |
| kule ev (`tower_house`) | 6–8 × 6–8 × 10–14 | mazgal, düz dam korkuluğu | gövde | kutu | iç merdiven yok: dış merdiven, sur dibinde |
| harabe (`ruin`) | 4–12 × 4–10 × 1–6 (kırık) | yarım duvar, kemer, ot, moloz | duvar | — | kırık duvar basamak (≤ 0,6 m adımlar) |
| küçük kilise (`chapel`) | 8–12 × 12–16 × 6 + kubbe 9–11 | haç planı, kasnaklı kubbe, apsis, narteks | aynı kütle | kutu + kubbe | çıkılmaz (kubbe: kayar yüzey; kenar korkuluğu yok) |
| orta kilise (`church`) | 14–22 × 18–28 × 8 + kubbe 13–16 | `HornWorld._church` | aynı | kutu + kubbe | narteks damı (merdivenle) |
| manastır (`monastery`) | 40–80 × 40–80 | avlu, hücre sırası, revak, kilise, çan | aynı | kütle | revak damı |
| çeşme (`fountain`) | 2–4 çap | `_build_street` çeşmesi | sütun + havuz | — | — |
| kuyu (`well`) | 1,2–1,6 çap × 0,9 | ilizli bilezik, çıkrık | bilezik | — | — |
| bostan duvarı (`garden_wall`) | boy serbest × 0,5 × 1,6–2,4 | kuru taş, sarmaşık | duvar | — | duvar üstü (2,0 m'den çıkılabilir, tırmanma kipinde) |
| bağ (`vineyard`) | 20–80 × 20–60 | kazık sırası, asma | sıra şeritler | doku | — |
| mezarlık (`cemetery`) | 15–40 × 15–40 | lahit, haç taşı, servi | servi + taşlar | servi | — |
| sarnıç bostanı (`open_cistern`) | 80–150 × 80–150 × 10–15 derin | iç duvar, merdiven, sebze tarhları | duvar + tarh | çukur | merdiven (iniş) |
| pazar tezgâhı (`stall`) | 1,0 × 2,2 × tente 2,3 | `_build_street` tezgâhı | tezgâh + tente | — | tenteden (tırmanma kipinde) |
| sundurma (`lean_to`) | 2–4 × 1,6–2,5 × 2,1–2,3 | direk, tahta dam | aynı | — | basamak öğesi (§5) |
| sandık/fıçı yığını (`crates`) | 1,0 × 1,0 × 0,95–1,0 | — | — | — | basamak öğesi (§5) |
| dış taş merdiven (`stair`) | genişlik 1,0–1,2, basamak 0,30 × 0,32 | korkuluklu | aynı | — | çatıya ya da düz dama |

Renk aileleri (havadan aynı aile): sıva boyaları `ByzCity._house`/`_build_fill` listesinden (`e8c890`, `d89a78`,
`efe0c4`, `c8a0a0`, `b8c4c0`, `e0b070`, `d8b89a`); kiremit `Kit.roof` dokusu ve uzakta ortalama rengi; taş
"ashlar" `fff4e4`; kepenk `3a6a5a`, `3a5a8a`, `6a3a2a`, `5a6a3a`. Dünyanın `CityHouses` (Quaternius Kit evleri)
mahalle paketleri bittikçe bu dile çevrilir. Çevrilmemiş mahallelerde CityHouses geçici olarak kalır.

---

## 5. Oynanış kuralları (şart)

### 5.1 Oyuncunun yetenekleri (ölçülmüş kod değerleri)
- `scripts/player/player.gd`: `WALK 3,2`, `RUN 5,2` m/sn, `JUMP 3,6` m/sn, `STEP_H 0,42` m. Yerçekimi proje
  varsayılanı 9,8 m/sn² (`project.godot` değiştirmiyor).
- **Zıplama yüksekliği:** h = v²/2g = 3,6²/19,6 = **0,66 m**. Zıplama süresi 2v/g = 0,73 sn.
- **Zıplama uzaklığı (düz):** yürürken 3,2 × 0,73 = **2,35 m**, koşarken 5,2 × 0,73 = **3,8 m**.
- **Basamak:** 0,42 m'ye kadar yürüyerek çıkılır.
- **Tırmanma kipi** (`Traversal`, yalnız `player.enable_climb` olan bölümlerde: 6b, 10g, 24, 31o, 37o, 39o):
  `REACH 2,3` m (ayaktan kenara: tutunup çıkma), `VAULT_MAX 1,1` m (üstünden atlama), havada tutunma
  `REACH − 0,15` + zıplama 0,66 m ≈ **2,8 m**. Duvarda tırmanış: nefes dolu iken ~10 m (`DRAIN_MOVE 0,12`/sn,
  `CLIMB_SPEED 1,2`). `no_climb` işaretli ve görünmez gövdelere tutunulmaz.
- **Gövde:** kapsül yarıçapı 0,3 m (`WALL_GAP 0,36`); karakterler arası `PERSON_R 0,62`.

### 5.2 Ölçü kuralları (bütün kit tipleri)
1. **Kapalı katı cisim.** Her yapının duvar ve çatı çarpışması vardır. Görünen ağ ile çarpışma arasındaki fark
   ≤ 0,15 m. Saçak çıkıntısı çarpışmaya girmez (tırmanan tavana takılmasın, `ByzCity._house` kuralı).
2. **Aralık kuralı.** İki katının arasında **0,9 m'den dar ve girilebilir** aralık olmaz. Ya ≥ 1,4 m sokak/geçit ya
   kapalı (bitişik duvar, ya da ağzı ≤ 0,25 m ve iki uçtan kapalı). 0,9–1,4 m arası yalnız kısa (≤ 4 m) ve iki ucu
   açık geçit olabilir.
3. **Zemin kesintisiz.** Her parçada ızgara zemin yoktur; parçanın kendi döşemesi (`CityChunks` taban levhası) dünya
   zemininin 2–5 cm üstündedir, parçalar arası dikiş ≤ 0,1 m ve aynı yükseklikte (bitişik parçalar ortak kenar
   yüksekliğini `World1453.surface_h`'tan okur).
4. **Çatılar yürünür.** Beşik çatı eğimi ≤ 32° (motorun yürünür eğimi 45°). Çatının çarpışması duvarların hizasında
   biter; sırt 1,6–1,8 m yükselir. Düz damlar korkuluklu (≥ 0,9 m) ya da kenarı ≤ 3 m yükseklikte.
5. **Tırmanma tutarlı.** Alçak öğeler bilerek seçilmiş üç yükseklikte:
   - **0,40 m** (basamak taşı, eşik): yürüyerek.
   - **0,95–1,0 m** (sandık, fıçı, kuyu bileziği): tırmanma kipinde atlanır (≤ 1,1); normal kipte çıkılmaz,
     çünkü zıplama 0,66 m.
   - **2,1–2,3 m** (sundurma, tente, çardak, bostan duvarı): tırmanma kipinde sandıktan ya da yerden tutunup çıkılır
     (≤ 2,3). Normal kipte çıkılmaz.
   - **Saçak 5,6–8 m:** tırmanma kipinde sundurmanın üstünden (2,2 m) duvara tutunulur, 3,4–5,8 m tırmanılır
     (nefes yeter). Normal kipte yalnız dış taş merdivenle.
   - Ara yükseklik yok: 0,66–0,95 m ve 1,1–2,1 m aralığındaki üst yüzeyler kullanılmaz (yarım tutunma olmasın).
     İstisna: 0,66 m'nin altındaki her şey normal kipte çıkılabilir sayılır.
6. **Sokaktan çatıya doğal yol.** Her mahallede en az **beş** yol: (a) dış taş merdiven (normal kip, iki kat),
   (b) sandık → sundurma → saçak (tırmanma kipi), (c) çardak → düz dam, (d) yıkık duvar basamakları (≤ 0,4 m adım),
   (e) sur dibi rampası/merdiveni. Her yol `city_audit`'te sayılır (`roof_paths`).
7. **Çatıdan çatıya.** Komşu çatılar arası boşluk ≤ **1,8 m** (yürüyerek atlanır: 2,35 m'den pay), yükseklik farkı
   ≤ 0,6 m inişte serbest, çıkışta ≤ 0,4 m. Sokak üstünden atlanamayacak aralık ≥ 3,0 m (koşuyla 3,8 m: ana cadde
   11 m, yollar 6 m, ara sokak 3,6 m: ara sokak yalnız koşarak atlanır, bilinçli).
8. **Çıkılamayan yer çıkılamaz görünür:** kubbeler, kilise duvarları (pencere kemeri yok, düz taş), sur yüzü
   (`no_climb` + görünür kesme taş), 2,3 m'den yüksek ve yanında basamak öğesi olmayan duvar.
9. **Uçuş (Nihat) konma noktaları:** her mahallede en az üç düz yüzey ≥ 4 × 4 m (meydan, düz dam, kilise
   narteksi). `World1453.flight_data` perch listesine mahalle paketi ekler.
10. **Kapalı cep yok:** girilebilen her boşluğun (avlu, ara, çıkmaz) çıkışı vardır; avluya merdivenle iniliyorsa
    çıkılır da.

---

## 6. Akış ve performans mimarisi ("uzakken yüklenmez")

### 6.1 Parça ızgarası
- **Parça (chunk):** dünya ızgarasında 96 × 96 m kare. Anahtar `Vector2i(floori(x/96), floori(z/96))`. Şehir ≈ 15 × 18
  = ~260 parça (suda olanlar boş).
- **Sabit tohum:** `seed = hash(Vector3i(i, j, CityChunks.SEED))`. Aynı parça her bölümde, her açılışta aynı.
  Parçanın içeriği yalnız tohuma, `CityPlan` sokaklarına ve mahalle verisine bağlıdır; oyuncunun yerine bağlı değildir.
- **Yerleşim verisi (plan):** parçanın evleri, sokak döşemesi, basamak öğeleri ve anıt boşlukları **düz veri** olarak
  bir kez hesaplanır (`CityChunks.plan(key) -> Array[Dictionary]`, önbellekli). Kurma (L0/L1) bu veriden olur.

### 6.2 Üç katman
| Katman | Uzaklık (parça ortasından) | İçerik | Çarpışma | Çizim |
|---|---|---|---|---|
| L0 yakın | < 150 m (oyuncunun parçası + 8 komşu) | kit yayımcıları Props ile: tam ayrıntı; ışıklar (gece) | evlerin gövde + çatı şekilleri, basamak öğeleri | parça başına ≤ 60 |
| L1 orta | 150–450 m | parçanın L1 yayımcılarından pişmiş tek ağ (`World1453.bake`: doku başına bir yüzey) | **aynı** gövde + çatı kutuları (uçuş ve uzaktan yürüyüş için; StaticBody, tek gövde) | parça başına 2–4 |
| L2 uzak | > 450 m | mahalle başına tek pişmiş siluet ağı (kutu + prizma, köşe rengi) | yok (uçuşun zemini `WorldFlight`) | mahalle başına 1 |

- Geçişler `visibility_range_begin/end` ile ve **örtüşmesiz**: L0 bitişi = L1 başı (hysteresis payı yok; far_aya'daki
  ölü bant hatası dersi, `tek_harita.md` §G). Kurma/boşaltma ayrıca 20 m geride (yaklaşırken 170 m'de kurulur,
  uzaklaşınca 190 m'de boşalır): görünürlük sınırı ile kurulma sınırı ayrı olduğundan birden belirme olmaz.
- Çifte çizim yok: bir evin aynı anda iki katmanı görünmez (begin/end aynı değer). Var olan `CityHouses` ve
  `ByzCity` dolgu evleri, kit parçalarının kapladığı yerde **hiç kurulmaz** (`CityHouses.skip_rects`, §6.5).

### 6.3 Zaman dilimli kurma
- `CityChunks._process`: oyuncunun (ya da kameranın) parçası değişince kuyruk yeniden sıralanır (yakından uzağa).
- Kare başına bütçe **6 ms** (üst sınır 8 ms): bir L0 parçası ~40–80 ev; ev başına kurma ~0,15–0,4 ms
  (`ByzCity._house` ölçüsü, BAKILACAK). Bir parça birkaç karede kurulur: ev ev ilerleyen yayımcı durumu (`_job`).
- L1 pişirme ağırdır (SurfaceTool): yükleme sırasında oyuncunun çevresindeki 450 m içi bir kez pişirilir ve
  `user://city_cache/<anahtar>_<tuz>.res` olarak saklanır (CityHouses önbelleği gibi). Önbellek varsa okuma ~2 ms.
- Yükleme: sahne açılışında yalnız oyuncunun parçası + komşuları L0 (eşzamanlı), gerisi karelere yayılır.
  Hedef: yükleme süresi en çok **+1,5 sn**.

### 6.4 Bütçe
- Yerde: çizim ≤ 900, üçgen ≤ 2,5 M. Uçuşta: bugünkü değeri aşmamak (7a/11 bakış tabloları `tek_harita.md` §G).
- Işıklar: gece L0 parçalarında en çok 6 OmniLight (en yakın kandiller), gerisi emisyonlu küçük yüzey.
- Bellek: L1 önbelleği parça başına ≤ 0,6 MB; 30 parça açık.
- Ölçüm: oyunun `RINFO` satırı + `CHUNKINFO kur=… ms` (parça kurma süresi), ÖNCE ve SONRA aynı replik anında.

### 6.5 Var olan altyapıyla bağlantı
- `World1453.build` → `CityChunks.attach(f)` (tek satır ekleme). `CityChunks` dünyanın (`SiegeField`) çocuğu,
  dünya koordinatında. Bölgenin keep dikdörtgenleri (bölümün oynanış alanı) parçalardan çıkarılır.
- `World1453.FAR_REGIONS` ve `ByzCity.far_hub`: hub'ın kendi yapıları değişmez; hub dışı çevresi parçalardan gelir.
- `CityPlan`: sokak grafiği aynen kalır. Kit evleri `CityPlan` kenarlarının iki yanına dizilir. CityLife sivilleri
  aynı sokaklarda yürür. Mahallenin içinde CityPlan'ın ev listesi (`houses_in`) kit evleriyle değiştirilir.
- `CityHouses.skip_rects` (statik dizi, ekleme): CityHouses kit mahallelerinde ev koymaz.
- `WorldWalk`: kit parçaları kendi çarpışmasıyla gelir (`no_walk`), WorldWalk onları katılaştırmaz (çifte gövde yok).
- `WorldFlight`/`NihatPowers.ensure_flight_solids`: L1 gövdesi uçuşta da katıdır.

---

## 7. Kalan işin paketleri

Kural: her paket yalnız **kendi dosyalarını** yazar. Ortak dosyalara (scripts/world/world1453.gd, city_plan.gd,
city_houses.gd, city_chunks.gd, city_kit.gd) yalnız P00 (bu dal) dokunur. Mahalle paketleri veriyi
`scripts/world/hoods/<ad>.gd` (mahalle tanımı: dikdörtgen, karakter, anıt yerleri, yayımcı seçimleri) ve
`scripts/world/kit/<tip>.gd` (yeni kit tipi) dosyalarında yazar. `CityChunks` mahalleleri `HOODS` dizisinden bulur.
Bu dizi P00 tarafından baştan bütün paketlerle doldurulmuştur; paket yalnız kendi dosyasını doldurur.

| Paket | Kapsam | Dosyalar | Kabul ölçütü | Tahmini iş |
|---|---|---|---|---|
| **P00** altyapı (bu dal) | CityGeo, CityKit (temel tipler), CityChunks (ızgara, katmanlar, akış), city_audit | `city_geo.gd`, `city_kit.gd`, `city_chunks.gd`, `tests/city_audit.*` | M01 kurulu, denetim temiz, testler PASS | bu dalda (durum: rapor) |
| **P01** M01 Romanos/hub | hub'ın çevresi 320 × 326 m | `hoods/m01_romanos.gd` | delik 0, dar aralık 0, kapalı cep 0; 5 çatı yolu; 6b/7b/10h/12b/23/24 PASS | bu dalda (durum: rapor) |
| P02 Sur şeridi (LandWalls) | 0, 20, 21, 22, 26o… sur içi şeridi M01 parçalarından | `land_walls.gd` (sahibi ile), `hoods/m01_romanos.gd` okur | 0/20/26o'da surun arkası M01 ile aynı | 1,5 gün |
| P03 M03 Kariye + Aetios sarnıcı | manastır, sarnıç bostanı | `hoods/m03_khora.gd`, `kit/open_cistern.gd`, `kit/monastery.gd` | sarnıca inilir/çıkılır; denetim temiz | 2 gün |
| P04 M02 Blakherna çevresi | sarayın çevresi, Venedik konağı | `hoods/m02_blachernae.gd` | 30/30o PASS, uçuşta aynı | 1,5 gün |
| P05 M04 + M05 bostan ve köyler | bağ, bostan duvarı, harabe, köy | `hoods/m04_pempton.gd`, `hoods/m05_pege.gd`, `kit/vineyard.gd`, `kit/ruin.gd` | seyrek ama boş değil; yollar CityPlan | 2 gün |
| P06 M06 Studios + Marmara sur dibi | manastır, balıkçı köyü | `hoods/m06_studios.gd` | denetim temiz | 1,5 gün |
| P07 M07 Mokios / Arkadios | sarnıç bostanı, forum sütunu | `hoods/m07_mokios.gd` | sarnıç kit'ini P03'ten kullanır | 1 gün |
| P08 M08 Petrion / Fener | konaklar, yokuş, 39o caddesi | `hoods/m08_petrion.gd`, `petrion.gd` (uzak sürüm `far_*`) | 38o/39o PASS; cadde uçuşta aynı | 2 gün |
| P09 M09 Havariyun pazarı | pazar meydanı, han | `hoods/m09_apostles.gd`, `kit/han.gd` | denetim temiz | 1,5 gün |
| P10 M10 Zeyrek + Bozdoğan | manastır tepesi, kemer altı | `hoods/m10_zeyrek.gd` | kemer altından geçilir | 1,5 gün |
| P11 M11 Haliç iskeleleri | Latin mahalleleri, ambar, vinç | `hoods/m11_quays.gd`, `kit/warehouse.gd` | 4b/17/19 kıyısı ile dikişsiz | 2 gün |
| P12 M12 Mese çarşısı | revaklı Mese, dükkânlar | `hoods/m12_mese.gd`, `kit/portico.gd` | revak altı yürünür; denetim temiz | 2 gün |
| P13 M13 Ayasofya / Hipodrom | aya parçasının dolgu evleri kit diliyle; Büyük Saray harabesi | `hoods/m13_aya.gd`, `byz_city.gd` (`_build_fill` aya kısmı) | 24/25/26/31o PASS; tek sütun kararı (sahip) | 2 gün |
| P14 M14 Marmara limanları | kızak, tersane, balıkçı | `hoods/m14_harbors.gd` | denetim temiz | 1,5 gün |
| P15 M15 Galata (kit diliyle) | GalataView evleri kit diliyle | `hoods/m15_galata.gd`, `galata_view.gd` | 10g/27 PASS | 1,5 gün |

Paketler arası tek bağımlılık: P07 → P03 (sarnıç kit'i). P02, P08, P13, P15 bölüm dosyalarına dokunur; o bölümlerin
sahibi olan oturumlarla (`wip/tekharita*`) sıra gözetilmeli.

---

## 8. Açık sorular (sahibine)
1. Konstantin Sütunu iki yerde (Ayasofya'nın 60 m batısında yerdeki etkileşim; dünyada forumda). Gerçekte forumda.
   Öneri: yerdeki etkileşim forumdaki sütuna taşınsın (P13).
2. Haliç kıyısı x −700'de düz. Gerçekte kıvrık ve iskeleli. Kıyıyı bükmek bölgeleri (horn_chain, petrion, horn_wall_o)
   kaydırır. Öneri: şimdilik düz kalsın; iskeleler kıyıdan dışarı uzansın.
3. Gerçek yoğunluk: 1453'te şehrin batı yarısı çoğunlukla bostan ve köydü. Oyunda "dolu şehir" isteği ile tarih
   çatışırsa öneri: kapılara ve Mese'ye yakın yerler dolu, aradakiler bostan (havadan bakınca yeşil–kiremit desen).
