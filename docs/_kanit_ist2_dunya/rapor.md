# İstanbul v2 — DÜNYA (coğrafya, arazi, deniz, ufuk, gezi sahnesi): rapor

Dal: `wip/ist2-dunya` (taban `wip/istanbul`; `wip/ist2-sehir` üç kez birleştirildi). Görev: `docs/_ajan/gorev/ist2_dunya.md`.

## Durum özeti

| # | Teslim | Durum |
|---|--------|-------|
| 1 | `scripts/world/ist/geo.gd` (`IstGeo`, dondurulmuş imzalar + `h_ham`, `bolge`, `cizgi_uzak`, `duzle`, `duzle_temizle`) | TAMAM (ilk gönderim ~50. dakikada; 30 dakika hedefi KAÇTI) |
| 1a | Kıyı (OSM'den, dolgular geri alınmış) | TAMAM / Marmara sur hattı KESTİRİM |
| 1b | Arazi (yedi tepe, Lykos, Galata, Çamlıca …) | TAMAM (yükseklikler kestirim) |
| 1c | Yollar (11 hat) | TAMAM; Mese kolları ve Lykos elle (kestirim) |
| 1d | `mahalle(x,z)` | TAMAM (kural tabanlı; yoğunluk sınırları sert) |
| 2 | `scripts/world/ist/dunya.gd` (`IstDunya.build`) | TAMAM |
| 3 | `tests/_ist/gezi.tscn` (kare listesi, serbest uçuş, yürüyen oyuncu, başsız yürüme sınaması) | TAMAM |
| 4 | `IstSehir.attach_v2` bağlantısı, birleşik kareler | TAMAM (bağlı); arazi–yapı uyumu KISMEN bakıldı |
| 5 | Performans | TAMAM (ölçümler aşağıda) |
| 6 | Uçuş bölümleri dökümü (7, 11) | KISMEN (aşağıda; uygulama yok) |

## 1. Kıyı verisinin kaynağı ve doğruluğu

- **Kaynak:** OpenStreetMap ilçe sınırları (Nominatim `polygon_geojson`, 12 Kasım 2026): Fatih, Beyoğlu, Eyüpsultan, Beşiktaş,
  Şişli, Kâğıthane, Zeytinburnu, Bakırköy, Sarıyer, Bayrampaşa, Gaziosmanpaşa, Esenler, Güngören, Bahçelievler, Bağcılar,
  Sultangazi, Küçükçekmece (Avrupa); Üsküdar, Kadıköy, Beykoz, Ataşehir, Ümraniye, Maltepe (Asya). Kıyıdaki ilçe sınırı bugünkü
  kıyıdır; Fatih'in batı sınırı kara surlarının hattıdır (kara suru buradan alındı: 6,27 km gerçek, dünyada 3,13 km).
  Overpass erişilemedi (bağlantı kesildi); Natural Earth bu ölçek için kaba.
- **1453 kıyısı = sur hattı:** dolgular geri alındı: bütün kıyılar 60 m geri çekildi; yarımadanın Marmara yüzü +40 m; Eminönü–
  Sarayburnu +130 m; Harem–Haydarpaşa +160 m; Karaköy–Tophane +70 m. Mermer Kule → Kumkapı arası (Yedikule, Samatya,
  Yenikapı dolgusu) **elle çizilmiş sur hattı** (KESTİRİM, ±100 m). Kontoskalion havuzu küçük girinti olarak açıldı; Langa
  (Eleutherios) dolmuş liman = kara (bostan). Kız Kulesi adacığı (28 m yarıçap) eklendi.
- **Nokta sayıları (dünyadaki çokgenler):** yarımada 235, Galata ≥ 60 (22 m'de bir sıklaştırıldı), Anadolu 223, Trakya 253;
  kara suru 52 nokta.
- **Doğruluk:** OSM sınırı birkaç metre; dolgu geri alma ±50–150 m (kestirim); Marmara sur hattı ±100 m. Yan yana kroki:
  `pafta/01_kroki_karsilastirma.jpg` (kırmızı bugünkü kıyı, dolgu 1453).
- **Bilinen sapmalar:** Sarayburnu burnu küt (1453'te Akropolis burnu daha sivri olabilir); Haliç'in kuzey kıyısı (Kasımpaşa,
  Hasköy) bugünkü kıyının 60 m gerisi (gerçek 1453 kıyısı BAKILMADI); Haliç'in ucu (Kâğıthane/Alibeyköy) dere yatağı olarak
  yalnız yükseklikte (ayrı su yolu yok).
- **CSV kapıları:** `docs/ISTANBUL_YERLER.csv` deniz suru kapılarının koordinatları denizin 300–1800 m içine düşüyor (CSV
  kestirimi bozuk). `IstGeo.yerler()` kapıları kendi hattına (Haliç suru / Marmara suru / kara suru) oturtur; özgün değer
  `e_csv`, `n_csv`, sapma `not` alanında. Kapıların SIRASI korunur, konumu KESTİRİM.

Üretici betikler (Python, depoda): `tests/_ist/geo_veri_kiyi.py` (kıyı), `tests/_ist/geo_veri_uret.py` (ızgara + yollar + GDScript
sabitleri), `tests/_ist/geo_veri_yerler.py` (CSV), `tests/_ist/geo_veri.gd` (ham → `assets/ist2/arazi_h.res` RF,
`arazi_b.res` L8). Izgara 1201 × 1001, 10 m dünya hücresi (gerçek 20 m), kapsam gerçek e −12…+12 km, n −9…+11 km.

## 2. Tepe / vadi çizelgesi (gerçek yükseklik; dünyada × 0,5)

| Ad | Gerçek (e, n) m | Hedef | Not |
|----|-----------------|-------|-----|
| 1. tepe Sarayburnu / Topkapı | (250, 250) | 40 m | Ayasofya çevresi ~35 m |
| 2. Çemberlitaş | (−740, 0) | 50 m | Konstantin Forumu |
| 3. Beyazıt / Süleymaniye | (−1360, 520) | 60 m | |
| 4. Fatih / Havariyun | (−2450, 1150) | 60 m | |
| 5. Sultanselim | (−2600, 1850) | 60 m | Aspar sarnıcı yanı |
| 6. Edirnekapı | (−3700, 2300) | 70 m | en yüksek |
| 7. Kocamustafapaşa / Xerolophos | (−3400, −480) | 60 m | Arkadius sütunu |
| Sırt | tepeleri bağlar | −6 m | Gauss kesit σ 330 m |
| Lykos vadisi | (−4200, 950) → (−2230, −900) | 38 → 2 m | sur önünde 38–45 m, Langa'da kıyı |
| Galata tepesi | (−512, 1889) | 60 m | kule tepede |
| Pera sırtı | (500, 3300) | 85 m | |
| Okmeydanı / Eyüp sırtı | (−1500, 4200) / (−3880, 5160) | 90 / 80 m | |
| Kasımpaşa, Kâğıthane, Alibeyköy dereleri | | 3–4 m | vadi |
| Anadolu: Üsküdar → Çamlıca | (7470, 2050) | 40 → 260 m | |
| Trakya yaylası (sur dışı) | | 55–60 m | hafif dalgalı kuşatma ovası |

Kıyıda yumuşak iniş (yarımada 220 m, Galata 120 m, diğer 260 m rampa; kıyı +1,6 m gerçek); deniz tabanı −3 m'den başlar,
uzaklıkla −70 m'ye iner (dünyada −35). `h(x,z)`: ızgara + çift doğrusal, **0,95 µs/çağrı** (`tests/_ist/geo_sina.gd`, 200 bin
çağrı); `duzle` kaydı varsa 64 m hücre tablosundan ek bakış. `mahalle`: 18,9 µs/çağrı (IstDunya 20 m önbellekle kullanır).

## 3. IstDunya

- **Arazi:** çekirdek 7 × 6 parça (768 m; dünya x −3072…+2304, z −3072…+1536), ayrıntı 6 / 12 / 24 / 48 m hücre (uzaklık
  < 150 / 700 / 1900 m + yükseklik payı, 40 m gecikme payı); dış halka 64 m hücre, 4 ağ (veri sınırına kadar). Tümü denizin
  altındaki dörtgenler atlanır; parça kenarında 3 m etek (çatlak örtüsü). Kurma evreleri (yükseklik, normal + renk, dizin,
  ağ) satır satır, kare başına bütçe 5 ms (`IstDunya.butce_us`).
- **Doku:** `Nature.ground_material()` (ground.gdshader) + köşe rengi: çayır / kuru çayır / toprak / çiğnenmiş toprak /
  taşlık (eğim) / kıyı kumu; şehir içinde mahalle yoğunluğuna göre çiğnenmiş toprak, bostan koyu yeşil, harabe taşlık; kara
  surlarının önü çiğnenmiş toprak şerit; Anadolu ve Trakya biraz kuru.
- **Deniz:** var olan `assets/shaders/water.gdshader` (yeniden yazılmadı): kameranın çevresinde 1200 m dalgalı yakın parça
  (10 m), çevresinde 4 düz uzak dikdörtgen (dalgasız, parıltısız). `ripple` 0,07 (uzakta harelenme vardı).
- **Gök:** ProceduralSky + `SkyBody` güneş (gündüz) / ay (gece), ByzCity üslubu. **Sis:** `Look.apply_env` en az 0,002/m
  pus koyuyordu (km ölçeğinde süt beyazı); `WorldEnvironment` üstüne `fog_cap` (gündüz 0,00012, gece 0,00025) ve gece için
  `look=night` işareti. Compatibility çizicisinde derinlik sisi görünmedi (üstel sis kullanıldı).
- **Uzak ufuk:** kerterizle yaylar (Trakya, iki yakada Boğaz sırtları, Kayışdağı/Anadolu tepeleri, Aydos, çok soluk Samanlı
  dağları) + Adalar (8 ada, gerçek yer ve yükseklik). Tek ağ.
- **Çarpışma:** izlenen düğümün (oyuncu/kamera) çevresinde `HeightMapShape3D` 160 × 160 hücre, 2 m (320 m kare); 70 m
  uzaklaşınca zaman dilimli yenilenir; `carpisma_yenile(p)` ışınlama sonrası. Görünen ağ ile fark (yürüme sınaması): 0,00 m.
- **Su yakalayıcı:** izlenen CharacterBody3D denizde y < −0,9 olursa en yakın kıyıya (sarmal arama) çıkarılır.
- **Kuşatma ovası:** sur dışı Trakya yaylası 55–60 m, hafif dalgalı; sur önünde 120 m düz şerit (`mahalle` "sur önü").
- **attach_v2:** `IstDunya.build` sonunda `IstSehir.attach_v2(dunya, gece)` (yöntem varsa); `IstDunya.sehir_bagla = false`
  ile yalnız arazi.

## 4. Ölçümler (xvfb + llvmpipe, 1280 × 720)

Kurulum (ilk kare, arazi + deniz + gök + ufuk + çarpışma): **178–308 ms** (≤ 2 sn).

Arazi + deniz + ufuk (`dunya_tris`/`dunya_draws` = IstDunya'nın görünür bütün ağları; `cizim`/`ucgen` = karedeki toplam):

| Kare | yalnız dünya (sehir=0): çizim / üçgen | IstDunya ağları: draws / tris | kare_us (arazi işi) |
|------|------|------|------|
| tepe 3000 m | 47 / 72 136 | 48 / 91 052 | 136 |
| 60 m batı | 22 / 134 300 | 48 / 176 950 | 157 |
| sur dışı 35 m | 42 / 153 594 | 48 / 168 058 | 139 |
| Galata 30 m | 21 / 97 112 | 48 / 176 980 | 190 |
| yürürken (oyuncu, 10 örnek) | 19–20 / 131–139 bin | 48 / 189–206 bin | 112–164 |

Hedefler: uçuşta ≤ 120 çizim, ≤ 400 bin üçgen → en çok 48 ağ, 206 bin üçgen: TAMAM. Yürürken ≤ 60 çizim → 20: TAMAM.
Kare başına iş ≤ 6 ms: oyun bütçesi 5 ms (ölçülen iş yokken 0,1–0,3 ms). Yürüme sınaması
(`kip=yuru_sina`): `YURU sonuc yol=130 m alt_dusme=0 yerde_en_buyuk_fark=0.00`, `YURU yakalayici … PASS`.

Şehirle birlikte (sehir=1) toplam çizim 870–3600, üçgen 370–614 bin: şehir tarafının (attach_v2) yükü; arazi payı yukarıdaki
gibi. Bu ŞEHİR oturumunun bütçesi (ORTAK DOSYA ÖNERİSİ değil, bilgi).

## 5. Bilinen kusurlar

- Mahalle türü sınırları (bostan / sık) zemin renginde sert kenar yapıyor (20 m önbellek hücresi; yumuşatma yok).
- Sarayburnu burnu küt; Haliç'in kuzey kıyısı bugünkü kıyıdan türetildi.
- Gündüz zemin dokusu (ground.gdshader) uzaktan sarımsı-soluk; renk ayarı göz kararı.
- Uzak ufuk yayları düşük çokgen; yakından (Adalar'a uçulursa) kaba.
- Gece: ay ışığı ve sis lacivert; şehrin ışıkları (fener, pencere) BAKILMADI (şehir tarafı).
- `duzle` kaydından sonra `IstDunya.yenile(alan)` çağrılmazsa önceden kurulmuş parçalar eski yükseklikte kalır (şehir
  oturumu kayıtları kurulumdan önce yaparsa sorun yok).
- `ISTANBUL_YERLER.csv` içe aktarılınca Godot `docs/ISTANBUL_YERLER.*.translation` üretiyor (kaydedilmedi).

## 6. BAKILMADI

- Arazi–yapı uyumu (havada/gömülü yapı, suya taşan sur) birleşik karelerde yalnız göz kararı (6 kare); sistemli denetim yok.
- Serbest uçuş kipinin elle denenmesi (ekransız ortam).
- `parse_check` dışındaki eski dünya testleri (`world_check`, `flight_check`, `city_check`, Bölüm 6/7/11/12b/24): bu dalda
  eski dünya dosyalarına dokunulmadı; koşturulmadı.
- Gerçek 1453 Haliç kuzey kıyısı, Galata surlarının tam hattı (elle 10 noktalı çokgen; KESTİRİM).

## 7. Sıradaki: uçuş bölümleri (7 ve 11) için döküm (UYGULAMA YOK)

Eski dünyada uçuşun kullandığı noktalar `World1453.flight_data` (`scripts/world/world1453.gd`) ve `World1453.LANDMARKS`
anahtarlarıdır; `scripts/world/world_flight.gd` Galata kulesi (`galata_tower`) ve sütun (`column`) noktalarını, bölümler
(`scripts/chapter7.gd`, `scripts/chapter11.gd`) `flight_data`'nın `landmarks / forms / perches` dizilerini kullanır. Şehir
oturumu `IstSehir.flight_data_v2` yazdı. V2 karşılıkları (gerçek e, n → `IstGeo.w(e, n)`):

| Eski anahtar | Kullanım | v2 gerçek (e, n) | Not |
|---|---|---|---|
| ayasofya | AYASOFYA işareti, form 1, konma "aya" | (0, 0) | kubbe tepesi: parçanın `perches` |
| hippodrome | HIPODROM, form 4 | (−378, −289) | |
| column | KONSTANTIN, form 2, konma "column" | (−756, −11) | |
| apostles | HAVARIYUN, form 6 | (−2394, 1156) | |
| aqueduct_a/b | BOZDOGAN, form 5 | `IstGeo.yol("bozdogan")` uçları | orta nokta |
| chain_s / chain_n | ZINCIR | `IstGeo.yol("zincir")` | |
| galata_tower | GALATA, form 3, konma "galata" | (−512, 1889) | |
| blachernae | BLAKHERNA, form 7 | (−3402, 3436) | |
| romanos | SURLAR, form 11 | kara surunda Topkapı (`yerler()` "Topkapı") | |
| eugenius | form 8 | `yol("zincir")[0]` | |
| galata_center | form 9 | (−504, 2046) | |
| damalis | form 10 | Kız Kulesi (2010, 1390) | |
| uskudar | form 12 | (2900, 1900) | |
| başlangıç / ordugâh | bölüm başı | Sultan'ın otağı (−4789, 1101) sur dışı | ovada düz |

Yükseklik tavanı (70 m) v2'de yarımada en yüksek noktası 35 m + yapılar: yeterli. Bölüm 7/11'in sınır kutuları (World1453
ölçeğinde ~1,4 × 1,7 km) v2'de 2,6 × 2,8 km olur: sınırlar `IstGeo.kiyi("yarimada")` çevresi + 300 m.

## Paftalar (`pafta/`)

Liste aşağıda; hepsi `tests/_ist/gezi.tscn` ile alındı (sonda değil, gerçek dünya kurulumu).

| Pafta | İçerik |
|---|---|
| 01_kroki_karsilastirma | sol: kroki (kırmızı = bugünkü OSM kıyısı, dolgu = 1453 kıyısı, surlar/Mese/Lykos/Bozdoğan/zincir); sağ: aynı çerçeve, oyundaki arazi tam tepeden |
| 02_tepe_sehirli | 3000 m'den bütün yarımada, şehir (attach_v2) ile |
| 03_60m_dort_yon | yarımadanın ortasından (Lykos üstü) 60 m'de kuzey / doğu / güney / batı |
| 04_sarayburnu | Sarayburnu ve Marmara deniz surları |
| 05_halic_agzi | Haliç ağzı, Galata surları ve zincir hattı |
| 06_galata_ilk_kare | Galata kulesi üstünden Haliç'in ötesine (Peter'in "ilk kare"si) |
| 07_kara_surlari_disi | sur dışı kuşatma ovasından kara surlarına |
| 08_gece | gece: Galata'dan ve 900 m'den |
| 09_yalniz_arazi_gunduz_gece | şehirsiz arazi: Galata'dan ve 900 m'den, gündüz / gece |
| 10_yedikule_kiyi | Yedikule önü Marmara kıyısı (elle çizilen sur hattının birleşimi) |

Kare ölçümleri (RINFO, şehirli): tepe 1656 çizim / 479 bin üçgen; 60 m dört yön 867–3631 / 370–614 bin; Sarayburnu 1153 / 423 bin;
Haliç ağzı 1423 / 504 bin; Galata 1344 / 417 bin; sur dışı 1557 / 546 bin; gece 923–1116 / 398–406 bin. Bunların içinde
IstDunya'nın payı her karede 48 ağ, 91–177 bin üçgen.
