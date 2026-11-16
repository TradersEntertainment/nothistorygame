# İstanbul v2 — Şehir çatı kuralı

Bu belge, yeni İstanbul'da (IstDunya / IstSehir v2) **çatılardan atlayıp zıplayarak geçilebilen** şehir dokusunun
kurallarıdır. Bundan sonraki her şehir işi (ev, sokak, köprü, ayrıntı) buna uyar. Ölçüler oyuncunun **bugünkü**
hareketinden (gerçek `Player`, ölçüm sondası `tests/_ist/cati_hareket.tscn`; tablo `docs/_kanit_ist2_cati/rapor.md`).

Uygulama: `scripts/world/ist/cati.gd` (`IstCati`) — Ayasofya–Yerebatan–Hipodrom çatı mahallesi. Ev kiti
`scripts/world/ist/evler.gd` (`~dam` eki: düz dam; `c_*` parça tipleri).

---

## 1. Bugünkü hareket (ölçülen; kural KAPALI kipe göre)

`Player.can_climb` şehirde çoğu bölümde **KAPALI**; yalnız 6, 10g, 24, 31o, 37o, 39o'da açık (`Traversal`).

| ölçü | KAPALI | AÇIK (Traversal) | kural (KAPALI) |
|---|---|---|---|
| yerinde zıplama tepesi | 0,68 m | 0,68 m | — |
| yürüyerek çıkılan basamak (`step_up`) | 0,48 m (STEP_H 0,42 + kapsül) | 0,48 m | **basamak ≤ 0,30 m** |
| koşup zıplayarak çıkılan en yüksek kenar | 0,75 m | 2,55 m (kenara tutunup çıkar) | **kenar ≤ 0,40 m** (zıplatmayın) |
| düz zeminde koşarak atlama (aralık) | 4,2 m | 5,9 m (karşı kenara tutunur) | **atlanır aralık ≤ 2,0 m** |
| yürüyerek atlama | 2,6 m | 2,6 m | — |
| aşağı atlama (kot farkı 1,0 m) | 5,2 m | 6,6 m | aşağı inişte ≤ 2,4 m kot, ≤ 2,0 m aralık |
| aşağı atlama (kot farkı 2,4 m) | 6,2 m | — | |
| düşme cezası | yok (sendeleme yok) | 4,0 m üstü sendeleme | — |

Pay: oyuncu bir kenara tam isabetle basmaz; kural ölçülenin yarısı civarı (aralık 2,0 m, kenar 0,40 m). Bot da bu
paylarla, takılmadan geçer. **Merdiven** basamağı 0,30 m rıht / ≥ 0,30 m basamak (ev dış merdiveni); dam üstündeki
serbest merdivenlerde (bakış kulesi) **0,25 m rıht / 0,36 m basamak** — 0,30/0,32'lik dar merdivende `step_up`
kapsülün konumuna göre takılabiliyordu (bot ölçümü).

## 2. Çatı türleri

| tür | kiti | yürünür mü | rota için |
|---|---|---|---|
| **düz dam** (`~dam`) | `evler.gd` `cati="duz"`, döşeme 0,18 m, saçak 0,1 m taşar | evet (düz) | **rota evi bu** |
| az eğimli kiremit (`RISE` 1,7 m, 16–21°) | beşik çatı | evet (≤ 25°), mahyası 1,6 m yukarıda | rota üstünde değil, kenarında |
| teras (`teras`) | düz dam + 1,0 m korkuluk + asma çardağı | evet; korkuluk geçişi keser | bakış yeri / rota ucu |
| kule ev (`mazgal`) | mazgallı dam, 1,0 m dişler | içi evet | rota dışı |

Kurallar:
- Rota üstündeki evin damı **düz** (`~dam`): baca, saman/küp, dış merdiven ve asma dam üstünde **yok** (geçişi keser
  ya da çarpışmasız durur).
- Aynı sıradaki iki dam arasında kot farkı **≤ 0,30 m** ise doğrudan yürünür; **> 0,30 m** ise alçak damın üstünde
  yüksek komşunun duvarına dayanan **dam merdiveni** (`c_merd`, 0,30/0,32).
- Bitişik sıra evlerinin damları arasında boşluk yok (döşemeler 0,1 m taşar, üst üste biner). İki sıranın köşede
  buluştuğu yerde damlar en az 1,0 m boyunca üst üste binmeli (M1b–M2: 2,0 m).

## 3. Köprü öğeleri

| öğe | kiti | ölçü | ne zaman |
|---|---|---|---|
| **kalas köprü** (`c_kalas`) | 0,9 m eninde çakılmış kalas + iki alt kiriş + uçlarda dikme ve halat korkuluk | uçlar damlara 0,4 m biner; eğim ≤ 25°; 5 m'den uzunsa ortada **ayak** (`c_ayak`, yerden) | sokak/geçit üstü, 2–8 m |
| ip/halat | — | (hareket ip üstünde yürümeyi bilmiyor) | SONRAKİ iş |
| tente | dükkânlı evin bez tentesi (2,2 m, `climb_top`) | AÇIK kipte basamak | tırmanma kipi |
| kemer | — | sokak üstü kemerli geçit (sabat) | SONRAKİ iş |
| sokak üstü sundurma | — | kalas + çatı | SONRAKİ iş |

Kalas, iki ucundan da bir dama oturur; **havada asılı köprü yok**. 5 m'yi aşan kalasın altında yerden ayak.

## 4. Çıkış noktaları (sokaktan dama)

| öğe | kiti | KAPALI | AÇIK |
|---|---|---|---|
| **dış taş merdiven** (`c_dmerdL/R`) | evin yan duvarı boyunca cepheden arkaya; açık yanda 1,0 m taş korkuluk; dipte sokağa üç ek basamak (−0,02/−0,32/−0,62); tepede çift derin **sahanlık** | evet | evet |
| **dar geçit merdiveni** (`c_dmerd0`) | iki evin arasındaki 1,1 m geçidi dolduran korkuluksuz merdiven; sahanlığı iki dama birden açılır | evet | evet |
| sandık/fıçı yığını + sundurma | `evler.gd` (1,0 m sandık → 2,2 m sundurma) | hayır | evet |
| asma kameriye | — | — | SONRAKİ iş |
| alçak sundurma (2,2 m) | `evler.gd` `_sundurma` | hayır | evet |

Kurallar:
- Merdiven duvardan **0,12 m açıkta** (dam döşemesinin 0,1 m'lik saçağı merdivenin üstüne binmesin; bot ilk sürümde
  sahanlıktan dama çıkamıyordu).
- Son basamak çift derin sahanlık (dama yana adım atılan yer).
- Arazi çarpışması `IstGeo.h`'ten ≤ 0,6 m alçak olabilir (düzlenmiş meydan kıyısı): dip basamakları bunu karşılar.

## 5. İniş noktaları

| öğe | kiti | not |
|---|---|---|
| **saman yığını** (`c_saman`) | yuvarlak, yere basık iki top (kutu değil); silindir çarpışma | köprü altına, merdiven yanına |
| tente | dükkân tentesi; `soft_landing` metası olan gövdede yaylanır (yalnız AÇIK kipte `Traversal._land`) | |
| avlu | sıra arkasındaki avlular (`IstMahalleDoku`) | |
| merdivenle iniş | her dış merdiven iki yönlü | KAPALI kipte asıl iniş yolu |

## 6. Yüksek bakış noktaları

- **bakış kulesi** (`c_kule`): düz damın arka yarısında 3,2 × 3,2 m taş köşk, 3,0 m; üstte 1,0 m korkuluk (merdiven
  yanında 1,8 m ağız), tuğla şerit ve korniş (sur/ev diliyle aynı). Merdiven 12 basamak (0,25/0,36), 1,6 m eninde.
- Rota çizgisi (cepheden 1,5 m içeride) kule ve merdiveninin dışında kalır.
- **Nisan 1453: Ayasofya'da minare YOK**; bakış noktası minare değil, dam üstü köşk ya da kule.

## 7. Yasaklar

- **Eğimde kayıp sıkışma**: rota damı düz; kiremit (≤ 25°) rota dışında. İki kiremit damın arasındaki oluğa düşülüp
  sıkışılacak dar boşluk bırakılmaz.
- **İki ev arasında görünmez boşluk**: bitişik evlerin damları üst üste biner; köşe buluşmalarında ≥ 1,0 m bindirme.
  Görünmeyen çarpışma (görünüşte dolu, çarpışmada boş ya da tersi) yok: parçaların ağı ve şekli aynı plandan
  (`build_parca` / `shapes_parca`).
- **Çatıda havada nesne**: dam üstündeki her şey döşemeye oturur; kalasın iki ucu damda, uzunsa ayağı yerde.
- Sokak (doluluk 1), başka ev (2), avlu (6), oyun alanı (meydan, hub) üstüne rota evi konmaz (`IstCati._sigmaz`);
  NPC'ler sokakta yürür.
- Rotanın evleriyle çakışan ağaç, doku yaması ve meydan kuyusu kurulmaz; rastgele sayı sırası değişmez (şehrin geri
  kalanı aynı kalır).
- Kutu yasağı: saman, ağaç, canlı kutudan yapılmaz.

## 8. Ölçü özeti (yeni çatı işi için kontrol listesi)

1. Basamak ≤ 0,30 m; serbest dam merdiveni 0,25/0,36.
2. Atlanacak aralık ≤ 2,0 m (KAPALI), değilse kalas.
3. Kenar (zıplayarak) ≤ 0,40 m; daha yüksekse merdiven.
4. Kalas eğimi ≤ 25°, uzunluk ≤ 8 m, 5 m üstü ayaklı.
5. Merdiven duvardan 0,12 m açıkta, tepede sahanlık.
6. Bot sınaması: `tests/_ist/cati_sehir.tscn -- --is=bot` (hücre çarpışması yüklendikten ve arazi çarpışması
   `carpisma_yenile` ile yenilendikten sonra yürür) → `CATIBOT OZET … takilma=0 dusme=0 sikisma=0`.

## 9. "Hareket şunu yapabilseydi" (SONRAKİ iş)

- **Kenara tutunup çıkma** KAPALI kipte de (bugün yalnız 6 bölümde): saçak 2,2–3,4 m'lik evler ve sundurmalar
  doğrudan rota olur; dış merdiven sayısı azalır.
- **Daha uzun koşu atlaması** (koşu ivmesi, 3–4 m aralık güvenle): kalas sayısı yarıya iner.
- **Kayma** (kiremit damdan oluğa kontrollü kayış): kiremit çatılar da rota olur (bugün yalnız düz dam).
- **İp/halat üstünde yürüme** ve **ipe tutunup karşıya geçme**: sokak üstü çamaşır ipleri, gemi halatları.
- **Duvar koşusu** (kısa yatay): iki ev arası dar geçitler.
- **Yuvarlanarak iniş** (yüksekten düşüşte sendelemesiz): saman/tente dışındaki inişler.
- **Kenarda durma uyarısı** (otomatik kenar tutunma): dam kenarından istemeden düşme biter.
- **Bakış noktası senkronu** (kuleye çıkınca harita/uçuş konma noktası açılır).
