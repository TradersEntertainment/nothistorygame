# G2 — Otağın içi (Bölüm 10a, 12, 13) tek haritada · rapor

Dal: `wip/tekharita-g2` · taban (ÖNCE): `f375da92` · makine: 4 çekirdek, Godot 4.4.1, gl_compatibility (llvmpipe, xvfb).

## 0. Özet

- Salon (`OtagHall`) artık World1453'ün **"otag"** bölgesinde duruyor: salonun yereli = dünyadaki otağın yeri
  (dünya (30, 0, 480), kapı yerel +z = dünya −z, yani ordugâhın yolu ve surlar). Bölge dönüşümü `World1453.REGIONS["otag"]`;
  CampDay'deki otağın (kamp yereli (0, −62)) yeriyle birebir aynı (pişiricinin çıktısı: `otag(hall 0) in camp local = (0, 0, −62)`).
- Kapıdan / aralık perdeden bakınca **gerçek ordugâh** görünüyor: yol sancakları, top ve kazan, tezgâhlar, atlar, çadır
  sıraları, ağaçlar. Bu görüntü elle çizilmedi: **aynı kurucuların** (CampDay in_world + World1453 "camp": SiegeField,
  HornWorld, Landmarks) çıktısından kapı yarım düzlemi kırpılıp tek ağa **pişirildi** (`tests/otag_door_bake.gd` →
  `assets/data/otag_door_day.scn`). Işık (güneş, gök ortamı), sis ve pozlama sahnedeki gerçek düğümlerden okunup köşe
  rengine yazıldı; malzeme ışıksız. Kalabalık (insan, asker, bölük, yürüyen, hayvan sınıfları, Crowd ikizleri) yok.
- İçerideyken **dünya kurulmuyor**: yalnız kapının önündeki dilim, 7 parça (yakın ve orta bant × 3 açı dilimi + uzak) +
  gök yarım kubbesi. Kapı açıklığı kameranın görüş konisinde değilse dilim **hiç çizilmiyor** (`_door_view_cull`).
- Salonun kendi geometrisi, oynanış alanı, botun yolu, replik ve akış **değişmedi**. Tek görsel değişiklik: kapının
  ardındaki düz açık renk perde (`_outside_card`) dilim yüklenince gizleniyor.
- Testler: 26/26 bölüm koşusu PASS, yasaklı satır 0; `parse_check` PASS, `world_check` PASS (bkz. §6).
- Oynanışta RINFO ÖNCE ile aynı (Sultan'a ve yanlara bakış: çizim ve üçgen birebir); dilim yalnız kapı kadrajdayken
  +6 çizim, +228k üçgen. Yükleme: dilim 66–83 ms, salon kurulumu +~80 ms (§5).

## 1. Ne taşındı / eklendi (dosya:işlev)

| Dosya | Ne | Satır |
|---|---|---|
| `scripts/world/world1453.gd` (ORTAK, yalnız ekleme) | `REGIONS["otag"] = Transform3D(Basis(UP, π), (30, 0, 480))` + 2 satır yorum | 103–105 |
| `scripts/level/otag_hall.gd` | `DOOR_VIEW` sabiti, `door_view`, `_outside_card` değişkenleri | 24–28 |
| `scripts/level/otag_hall.gd:_ready` | `_build_door_view()` çağrısı (kurulum; salonun öteki kurucuları aynı sırada) | 35 |
| `scripts/level/otag_hall.gd:_process` | `_door_view_cull()` çağrısı (tek satır) | 44 |
| `scripts/level/otag_hall.gd:_build_tent` | eski "dışarısı" kutusu `_outside_card`'a atanıyor (biçim/yer aynı) | 149 |
| `scripts/level/otag_hall.gd:_build_door_view` (yeni) | pişmiş dilimi yükler, salonun çocuğu yapar (salon nereye konursa kapının ardı aynı ordugâh: 10a'da salon (300, 0, 0)'da) | 167–184 |
| `scripts/level/otag_hall.gd:_door_view_cull` (yeni) | kapı açıklığı kutusu (`DOOR_BOX`) görüş konisi dışındaysa dilim gizli | 187–205 |
| `assets/data/otag_door_day.scn` (yeni, 3,9 MB, ZSTD) | pişmiş dilim: NearL/C/R 33 451 / 31 466 / 25 563 · MidL/C/R 10 223 / 50 359 / 9 610 · Far 67 003 üçgen · Sky ~480 | — |
| `tests/otag_door_bake.gd/.tscn` (yeni, dışa aktarılmaz) | pişirici (bkz. §7 yeniden üretme) | — |
| `tests/sonda_otag.gd/.tscn` (yeni, dışa aktarılmaz) | serbest kamera sondası (kanıt kareleri, `sonda_*`) | — |

`chapter10a.gd`, `chapter12.gd`, `chapter13.gd` **değişmedi**: üçü de `OtagHall.new()` + `add_child` ile kuruyor; dilim
salonun kendi kurulumunda geliyor. Kâtip kalemi / el tutuşu işlevlerine (`page_walk`, `page_present`, `_build_people`,
`_build_throne`) dokunulmadı. Yeni `class_name` yok.

Pişiricinin yöntemi (kısaca): ekranlı koşuda gerçek `CampDay` kurulur (başsız sunucu MultiMesh dönüşümlerini
saklamıyor: `xforms` metası okunur); her MeshInstance/MultiMesh üçgeni salon yereline çevrilir; süzgeçler:
kapı çizgisinin önü (z ≥ 7, kırpma geometrik), salonun ve dünyadaki otağın kabuğu (r < 10,6) dışarıda, ≤ 900 m,
açı ≤ 82° (160 m ötesi ≤ 50°), açısal boyuta göre küçük nesne eleme, oyunun kendi `visibility_range`'i, iç surun
(12 m) görüş çizgisinin altında kalan şehir parçaları atılır. Uzaklığa göre meshoptimizer LOD (`ImporterMesh.generate_lods`).
Gölgelendirme: Compatibility köşe rengini sRGB sayıyor (çıkış sRGB kodlu), toon yayılımı
`smoothstep(−pürüzlülük, pürüzlülük, N·L)`, arka yüzü görünen ince parçalarda normal kapıya çevrilir, arazi
gölgelendiricisinin ortalama etkisi için zemin 0,7 kazanç, gök Godot ProceduralSky eğrisiyle (sky_curve 0,15).

## 2. Ölçü tablosu: iç salon ve dışarıdaki otağ

Yerel: salonun yereli (= "otag" bölgesi); dünyada kapı −z.

| | İç (OtagHall, 10a/12/13) | Dış: CampDay._build_otag (6a, 7a, 9, 10, 11… yerden ve 7a/11 uçuşundan görülen) | Dış: SiegeField._otag (öteki bölgelerden uzakta) |
|---|---|---|---|
| Taban (yarıçap) | **9,0** m (24 pano), zemin levhası 20 × 22 | **7,0** m (16 dilim), çarpışma 7,05 | **7,0** m (16 dilim) |
| Duvar yüksekliği | 5,0 m (altın kuşak 0,4 ve 4,3) | 4,0 m (altın kuşak 3,8, taban kuşağı 0,3) | 5,0 m (altın kuşak 4,2) |
| Çatı | koni 5,0 → 9,0 m (alt r 9,2, üst 0,6), iç astar `c8a060` | koni 4,0 → 7,2 m (alt r 7,4, üst 0,3) + alem direği 9,6, top 9,7, hilal 10,35 | koni 5,0 → 9,5 m (alt r 7,6) + top 10,2 |
| Kapı yönü | yerel +z | kamp yereli +z = dünya −z ✓ | dünya −z ✓ (koyu kapı kutusu c + (0, 1,7, −7)) |
| Kapı ölçüsü | pano aralığı 4,64 m geniş × 5 m (iki yanda perde 1,3–1,9: net 2,6 m + iki yarık) | açıklık çizilmemiş (kapalı silindir); sayeban direkleri x ±1,6, z +9,6; gölgelik 3,6 × 2,8, 3,2 m yüksekte | koyu kutu 3,0 × 3,4 m |
| Direkler | iki altın direk x ±2,6, z −1, 8,4 m (+ top) | ortada alem direği (çatının üstünde) | — |
| Kumaş renkleri | duvar `a82830`/`8a2026` dönüşümlü, altın `d8b040`, pano krem `f0e2c0` + lacivert `223066`/yeşil `1e5a4a` | duvar `b3262d`, çatı `c8323a`, altın `d8b040`/`e0b848`, pano krem `f4e8cc` + lacivert `28366a` | `b3262d`, altın `d8b040` |
| Çevre | — | 8'li küçük çadır halkası r 13 (kapının önündeki yok) | kırmızı zokak 44 × 34 (kapı tarafında 6 m açıklık), 4 yan çadır, 3 tuğ |

**Tutarsızlıklar** (pafta p05): (1) iç salon dıştaki otaktan büyük: yarıçap 9 / 7 (dünyada iç duvar dış kabuğun 2 m
dışında kalır); (2) duvar 5 / 4 m, çatı tepesi 9 / 7,2 m (CampDay); (3) kapı: içeride 4,6 m geniş açıklık, dışarıda
CampDay kabuğunda açıklık yok (yalnız sayeban); (4) direk düzeni: içeride iki yan direk, dışarıda tek orta alem
(iki direk Sultan'ı kapatmasın diye yana alınmış; çatı konisi bunu dışarıdan gizler: küçük sorun); (5) renkler aynı
aile (iç kırmızılar biraz koyu: iç gölge; altın aynı; aplike panolar iki yüzde de var). Kapı yönü üçünde de tutarlı.
Görev gereği içeriye dokunulmadı; dış kabuğu içeriye uydurma önerisi §8'de.

## 3. "Aynı yer" çiftleri (kare üstünde dünya koordinatı)

| Pafta | İçeriden (SONRA, OtagHall + dilim) | Dışarıdan / havadan (gerçek dünya) | Sonuç |
|---|---|---|---|
| `p01_ayni_yer_giris.jpg` | göz dünya (30, 1,6, 472,2), −z'ye bakış | aynı göz, CampDay + World1453 "camp" (9/10/11'in ve 7a/11 uçuşunun dünyası) | Yol sancakları (yeşil sol, kırmızı sağ), top arabası, kazan, tezgâh, atlar, çadır sıraları, ağaçlar aynı yerde, aynı biçimde. Renk ölçümü (aynı piksel bölgesi ortalaması): gök (0,48, 0,71, 0,87) / (0,46, 0,67, 0,86); uzak zemin (0,57, 0,49, 0,36) / (0,60, 0,56, 0,40). Fark: kalabalık bilerek yok; güneş gölgeleri, tekerlek izleri, dumanlar, tabela yazısı ("OTAĞ ↑", Label3D) pişmiyor. |
| `p02_ayni_yer_yanlar.jpg` | girişten ±45° | aynı | Perde aralığından görünen sancak ve çadırlar dışarıdakiyle aynı yerde. |
| `p03_ayni_yer_tele.jpg` | 22° dar açı, dünya (30, 9, −2)'ye (iç sur) | aynı | Surlar yerden göz hizasında ordugâhın ardında kalıyor — **iki karede de** (gerçek dünyada da görünmüyor; dilim bunu doğru yansıtıyor). |
| `p04_disaridan_havadan.jpg` | — | dışarıdan kapıya: göz (30, 1,7, 446); havadan sonda: (16, 38, 410) → otağ | Kapı yolun ucunda, −z (surlar) yönünde: içerideki kapı yönüyle aynı. |
| `p05_olcu_hava.jpg` | aynı kamera (20, 20, 454) → (30, 3, 480), salon yerinde | dünyadaki otağ | Yer aynı, ölçü değil (§2). Sol karedeki kırmızı arka plan salonun kendi ortamı: dilim yalnız kapının önü (havadan bakış oyunda olmuyor). |

Kendi karelerime baktım: eşikte boşluk/titreme yok (salon zemini z 12'ye kadar, dilim zemini altında 5 cm); dilim
salonun içine girmiyor (r < 10,6 kırpılı); sayeban ve dünyadaki otağın kabuğu kapıda görünmüyor; küp gibi kalan,
havada duran bir şey görmedim. Sancakların arka yüzü ilk sürümde karanlıktı, düzeltildi (normal kapıya çevrilir).

## 4. ÖNCE | SONRA (aynı koşu, aynı an)

| Pafta | Koşu | Not |
|---|---|---|
| `p06_kapi_once_sonra.jpg` | sonda, Tolga'nın yerinden kapıya | ÖNCE düz açık renk perde (273 çizim / 140k); SONRA ordugâh (279 / 368k) |
| `p07_b12_acilis.jpg` | `--chapter=12 --shots` `c12_01_otag` | Salon birebir aynı (kapı arkada) |
| `p08_b10a_otag.jpg` | 10a PACE, replik `D10A_N_OTAG_1` | Aynı |
| `p09_b13_otag.jpg` | `--chapter=13 --shots` `c13_02_dugme` | Aynı (otağ dalı yalnız `--shots` kipinde koşuyor, §9) |
| `p10_gorus_yok.jpg` | sonda, Sultan'a ve yana bakış | SONRA 289/140k ve 287/141k = ÖNCE (dilim çizilmiyor) |

## 5. RINFO ve yükleme süresi

Koşu: `PACE=1 RINFO=1 xvfb-run … --chapter=N --autotest --hitchaudit --dialogshots=… --shotevery=1`, ÖNCE dosyaları
`git show f375da92:…` ile geçici olarak yerine konup koşuldu, sonra `git checkout --` ile geri alındı. Replikten
sonraki ilk üç RINFO örneği (çizim / üçgen k):

**Bölüm 12**

| Replik anı | ÖNCE çizim | SONRA çizim | ÖNCE üçgen k | SONRA üçgen k |
|---|---|---|---|---|
| açılış (girişte, kararma) | 643/991/797 | 643/993/800 | 145/472/343 | 145/478/348 |
| D12_F_01_RIGHT | 1043/1043/1043 | 1043/1043/1043 | 145/145/145 | 145/145/145 |
| D12_F_WHO | 738/397/944 | 738/944/944 | 145/144/145 | 145/145/145 |
| D12_F_WHO_C | 948/948/948 | 948/948/948 | 145/145/145 | 145/145/145 |
| D12_F_ITEMS | 792/792/626 | 792/403/626 | 145/145/144 | 145/145/144 |
| D12_F_ITEM_CUBE | 816/816/722 | 816/816/722 | 145/145/145 | 145/145/145 |
| D12_F_CUBE_2 | 626/626/618 | 710/626/618 | 144/144/138 | 144/144/138 |
| D12_F_ITEM_PHONE | 925/925/925 | 925/925/925 | 145/145/145 | 145/145/145 |
| D12_F_CANNON | 818/818/934 | 818/818/399 | 145/145/145 | 145/145/145 |
| D12_F_CANNON_A | 860/860/860 | 860/860/860 | 145/145/145 | 145/145/145 |
| D12_F_KEY | 792/792/399 | 792/399/872 | 145/145/144 | 145/144/145 |
| D12_END_12_1_1 | 634 | 634 | 144 | 144 |
| D12_END_12_1_3 | 826/826/826 | 826/826/826 | 145/145/145 | 145/145/145 |
| D12_F_TEZKIRE | 808/808/808 | 808/808/808 | 145/145/145 | 145/145/145 |
| **en çok** | **1043** | **1043** | **472** | **478** |

(Örneklerin sırası zaman kaymasıyla değişiyor: aynı değer kümeleri; çizim tavanı 900'ü bugün de aşıyor (1043): artmadı.)

**Bölüm 10a** (otağ evresi: D10A_F_2, D10A_F_3)

| Replik anı | ÖNCE çizim | SONRA çizim | ÖNCE üçgen k | SONRA üçgen k |
|---|---|---|---|---|
| açılış | 769/653/909 | 769/653/909 | 87/75/76 | 87/75/76 |
| D10A_N_01 | 580/579/579 | 580/579/579 | 38/38/38 | 38/38/38 |
| D10A_N_FORM_1 | 922/922/922 | 922/922/672 | 109/109/109 | 109/109/108 |
| D10A_N_FORM_2 | 920/920/920 | 920/920/920 | 109/109/109 | 109/109/109 |
| D10A_F_2 (otağ) | 780/778/778 | 780/778/778 | 171/170/170 | 171/170/170 |
| D10A_F_3 (otağ) | 726/718/714 | 726/718/714 | 170/170/170 | 170/170/170 |

**Bölüm 13**: otağ dalı olağan akışta koşmuyor (§9); PACE ölçümü BAKILMADI. `--shots` karesi p09.

**Kapı kadrajdayken (sonda, aynı kamera)**

| Bakış | ÖNCE çizim / üçgen | SONRA çizim / üçgen |
|---|---|---|
| Tolga'nın yerinden kapıya | 273 / 140k | 279 / 368k |
| Girişten kapıya | 8 / 0k | 14 / 228k |
| Girişten ±45° | 50 / 1k | 55 / 219k |
| Sultan'a (oyunda olağan) | 289 / 140k | 289 / 140k |
| Yana (vezirler) | 287 / 141k | 287 / 141k |

Sınır: çizim ≤ 900 ve üçgen ≤ 2,5 M: kapı kadrajdayken en çok 279 / 368k. Oyunda kamera hiç kapıya dönmüyor
(oyuncu salonda donuk; Bölüm 12'de girişte sırtı kapıya): oyun koşularında fark yalnız açılışın kararmasında +6k.
Gerçek ordugâhın aynı noktadan çizimi 8 900 çizim / 7,2 M üçgen (sonda "out").

**Yükleme**

| Ölçü | ÖNCE | SONRA |
|---|---|---|
| Dilimin yüklenmesi (`OTAGDOOR load`, ekranlı) | — | 12: 81–83 ms · 10a: 66–67 ms |
| Salonun kurulumu (sonda, `OtagHall` ekle → hazır) | 148–151 ms | 221–242 ms (+~80 ms) |
| `tests/load_time.tscn --only=chapter12` (3 kez) | 131 / 131 / 132 ms | 189 / 146 / 159 ms |

`load_time` satırında `ready` 1–2 ms görünüyor (salon kurulumu ölçünün dışında kalıyor gibi), dilim süresini yukarıdaki iki
satır gösteriyor. Sınır +1 sn: karşılanıyor. Dilim tek seferde yükleniyor (karelere yayılmıyor): 10a'da kararma kartı
sırasında, 12'de açılış kartı sırasında.

## 6. Testler (SONRA, son kod; ÖNCE koşulmadı çünkü hepsi PASS)

`timeout 600 $G --headless --max-fps 20 --path . -- --chapter=N --autotest[=v]`; sütun "yasak": `SCRIPT ERROR`,
`WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_MISS`,
`JOURNEY_OVERLAP` satır sayısı.

```
PARSECHECK PASS scripts=247
WORLDCHECK PASS regions=14 landmarks=35
10a ""        AUTOTEST PASS chapter=10a  yasak=0
10a refuse    AUTOTEST PASS chapter=10a  yasak=0
10a next      AUTOTEST PASS chapter=17   yasak=0
12 ""         AUTOTEST PASS chapter=12   yasak=0
12 leblebi    AUTOTEST PASS chapter=12   yasak=0
12 twokings   AUTOTEST PASS chapter=12   yasak=0
12 repair     AUTOTEST PASS chapter=12   yasak=0
12 kitchen    AUTOTEST PASS chapter=12   yasak=0   (bilinen FAIL bu dalda çıkmadı)
12 retry      AUTOTEST PASS chapter=12   yasak=0
12 hikmet     AUTOTEST PASS chapter=12   yasak=0
12 nihat      AUTOTEST PASS chapter=12   yasak=0
12 urban      AUTOTEST PASS chapter=12   yasak=0
12 next       AUTOTEST PASS chapter=17   yasak=0
13 ""         AUTOTEST PASS chapter=13   yasak=0
13 miss       AUTOTEST PASS chapter=13   yasak=0
13 wrong      AUTOTEST PASS chapter=13   yasak=0
13 depot      AUTOTEST PASS chapter=13   yasak=0
13 together   AUTOTEST PASS chapter=13   yasak=0
13 stay       AUTOTEST PASS chapter=13   yasak=0
13 w4         AUTOTEST PASS chapter=13   yasak=0
13 meclis     AUTOTEST PASS chapter=13   yasak=0
13 kitchen    AUTOTEST PASS chapter=13   yasak=0
13 city       AUTOTEST PASS chapter=13   yasak=0
13 next       AUTOTEST PASS chapter=14   yasak=0
13 wrong_next AUTOTEST PASS chapter=15   yasak=0
13 gidak      AUTOTEST PASS chapter=16   yasak=0
```
Ekranlı PACE koşuları (12, 10a) ve `--shots` (12, 13) ÖNCE ve SONRA: PASS. `world_check` "otag" bölgesini saymıyor
(sabit listeyle 14 bölge denetliyor).

## 7. Açık kalanlar / sınırlar

- **Pişmiş görüntü durağan**: kalabalık yok (görev gereği), güneş gölgeleri, tekerlek izleri (saydam şeritler),
  duman, Label3D tabela yazısı yok. Bölüm 6'ya özel tüccar/keçi gibi bölüm durumuna bağlı ayrıntılar dilimde yok
  (CampDay varsayılan kurulumu pişirildi).
- **Dünya değişince dilim eskir.** Yeniden üretme:
  `xvfb-run -a -s "-screen 0 1280x720x24" godot --path . res://tests/otag_door_bake.tscn` (≈15 sn; ekranlı şart).
  Öneri §8.3.
- **Gece sürümü yok**: 10a, 12 ve 13'ün otağ evreleri gündüz (`make_night` çağrısı yok). Gece gerekirse aynı pişirici
  `set_mode("night")` sonrası ikinci dosya üretebilir: KANITSIZ (denenmedi).
- **Renk eşleşmesi yaklaşık**: ışık köşe rengine yazıldı; sabitler (zemin 0,7, toon modeli) p01'deki ölçüme göre ayarlandı.
  Yakın zeminde gerçek dünyadaki sayeban gölgesi yok (dilimde gölge pişmiyor): kapının dibindeki zemin gerçeğinden açık.
- Havadan bakışta (oyunda olmayan) dilimin kenarı ve salonun ortam rengi görünür (p05 sol): yalnız kanıt karesi.
- Salonun önü açık (çarpışma yok); oyuncu salonda hep donuk olduğu için dokunmadım (ÖNCE de aynı).
- 10a: salon arşivin 300 m yanında (`OTAG_OFFSET`); dilim salonun çocuğu, arşiv (gizli) dilimin dışında kalıyor (z < 7).

## 8. Ortak dosyalar ve başkasının dosyaları için öneriler (uygulanmadı)

### 8.1 Dış kabuğu içeriye uydurma (SiegeField._otag, `scripts/level/siege_field.gd:1210–1214`)
```gdscript
	# İç salon (OtagHall): yarıçap 9, duvar 5 m, çatı 9 m, kapı 4,6 m (yerel +z = dünya −z)
	d.cyl(9.2, 5.0, c + Vector3(0, 2.5, 0), red.darkened(0.05), Vector3.ZERO, 24)
	d.cyl(9.25, 0.5, c + Vector3(0, 4.3, 0), gold, Vector3.ZERO, 24)
	d.cyl(9.6, 4.2, c + Vector3(0, 7.1, 0), red, Vector3.ZERO, 24, 0.06)
	d.ball(0.5, c + Vector3(0, 9.6, 0), gold)
	d.box(Vector3(4.6, 5.0, 0.2), c + Vector3(0, 2.5, -9.15), Color("2a1a14"))     # kapı açıklığı
```
Zokak (44 × 34) ve yan çadırlar (merkezden ≥ 11,4 m) sığıyor.

### 8.2 CampDay._build_otag (`scripts/level/camp_day.gd:900–960`, görev listemde değil)
Kabuk `Props.cyl(self, 9.2, 5.0, base + (0, 2.5, 0), …, 24)`, çarpışma `wcy.radius = 9.25`, çatı
`Props.cyl(self, 9.6, 4.0, base + (0, 7.0, 0), …, 24, 0.6)`, panolar r 9,22'de 24 adet (içeridekiyle aynı sayı),
kapı `door := base + Vector3(0, 0, 9.2)` (sayeban kapının önünde), 8'li çadır halkası r 13 → 15, kabukta kapı açıklığı
(koyu kutu 4,6 × 5). Dikkat: CampDay bölümlerinde botun otağ yakınındaki yolu (Çandarlı/elçi sahneleri) BAKILMADI;
yol sancakları (z −34…−52, x ±2,8) ve sayeban (x ±1,6) çakışmıyor. Bu değişiklikten sonra dilim yeniden pişirilmeli
(kırpma yarıçapı 10,6 büyük kabuğu dışarıda bırakır; sayeban kapının önünde görünür: doğru).

### 8.3 world_check'e eskime denetimi (öneri)
`tests/world_check.gd`'ye: `otag_door_day.scn`'nin üretildiği CampDay/SiegeField/HornWorld betiklerinin
`FileAccess.get_md5` toplamını sahnenin metasına yazıp denetimde karşılaştırmak; uyuşmazsa
"OTAGDOOR stale: yeniden pişir" uyarısı. (Pişirici bugün metayı yazmıyor.)

### 8.4 Ortak arayüz notu
Bu dalda `World1453.bake`, `FAR_REGIONS`, `Flame.from_glow_boxes` **yok** (§F'deki arayüz henüz bu dala gelmemiş);
dilim bu yüzden kendi pişiricisiyle üretildi. Arayüz geldiğinde pişiricinin `_emit/_put` kısmı `World1453.bake`'e
taşınabilir; yalnız kapı süzgeci ve ışığın köşe rengine yazılması G2'ye özgü kalır.

## 9. Açılış / kapanış tutarlılığı (akış değiştirilmedi)

- **Bölüm 12**: açılışta Tolga kapıda (`ENTRY` (0, 0, 7,8)), perde sesiyle girip `TOLGA_SPOT`'a yürüyor: kapıyla
  tutarlı ✓. Kapanış kararmayla (yürüyerek çıkış yok): nötr.
- **Bölüm 10a**: arşivden kararma + "Otağ" kartıyla doğrudan salonun ortasına (`TOLGA_SPOT`) ışınlanıyor; kapıdan
  girmiyor (kart örtüyor). Çıkış yine kararmayla arşive. Küçük tutarsızlık: girişin kapıdan olduğu görülmüyor.
- **Bölüm 13**: `chapter13.gd:208–242` dal seçiminde `place` yalnız "camp"/"city"/"galata" olabiliyor
  (`GameState.last_place`, `game_state.gd:533`); "camp" ve mutfak dışı her yol CampDay'e gidiyor, otağ dalı (`else`,
  satır 237–242) **olağan akışta erişilemiyor**; salon yalnız `--shots` kipinde (`_run_shots`, satır 1206) kuruluyor.
  Yorumdaki "Tolga 10'da kaldığı yerde (otağda … Fatih'i dinliyordu)" niyetiyle çelişiyor. Akışa dokunmadım.

## 10. Paftalar

`p01_ayni_yer_giris.jpg`, `p02_ayni_yer_yanlar.jpg`, `p03_ayni_yer_tele.jpg`, `p04_disaridan_havadan.jpg`,
`p05_olcu_hava.jpg`, `p06_kapi_once_sonra.jpg`, `p07_b12_acilis.jpg`, `p08_b10a_otag.jpg`, `p09_b13_otag.jpg`,
`p10_gorus_yok.jpg` (10 adet, her biri ≤ 190 KB).
