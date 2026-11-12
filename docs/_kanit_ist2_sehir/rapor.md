# İstanbul v2 — ŞEHİR raporu (dal `wip/ist2-sehir`)

Tarih: 12 Kasım. Görev: `docs/_ajan/gorev/ist2_sehir.md`. Taban: `wip/istanbul` + on iki parça dalı + `wip/ist2-dunya`.
Kanıt kareleri kendi sondamdan (`tests/_ist/sehir2_kare.tscn`; adlar `tur_<n>_*`, `yer_<n>_*`, `eser_*`).
Bütün kareler yazılımla çizimde (xvfb, llvmpipe). Tur 5 kareleri IstDunya ile (sonda `dunya.gd` varsa onu kurar: arazi,
deniz, gök, ışık dünya dalından; IstDunya `IstSehir.attach_v2`'yi çağırır). Tur 1–4 sondanın kaba arazisiyle. Hüküm etiketleri: TAMAM / KISMEN / YAPILMADI / KANITSIZ / BAKILMADI.

## 0. Özet

- v2 girişi: `IstSehir.attach_v2(dunya, gece)` (`scripts/world/ist/sehir.gd`, dosyanın sonundaki "İSTANBUL v2" bölümü).
  IstDunya (dünya dalı) bunu çağırıyor; birleştirildi.
- Yeni dosyalar: `scripts/world/ist/sokak.gd` (`IstSokak`: sokak grafiği, ev dizilimi, doku), `tests/_ist/sehir2_kare.*`
  (sonda + denetim).
- Eski dünya: `IstSehir.enabled` varsayılanı **false** (eski World1453 eski hâliyle; v2 kendi girişinden açar).
- Ölçek: anıtlar k = 0,5 (`IstGeo.w(e, n)`), evler/sokaklar 1:1, uzun hatlar gerçek uzunluk × 0,5.
- Sayılar (son koşu): **4 003 ev** (2 830 sıra), 638 sokak, 1 199 doku öğesi (bostan/bağ/tarla/bahçe/harabe/99 mahalle
  kilisesi-şapel), 12 meydan (kuyu/çeşme), 452 sur dilimi + köşe kulesi, ~95 anıt kaydı.
- Bütçe (tur 5, IstDunya ile): uçuşta çizim 363–536 / üçgen ≤ 0,66 M; yerde çizim 192–678 / üçgen ≤ 1,22 M (sınırlar
  1 500 / 3,5 M ve 900 / 2,5 M). Tek işin süresi 6 ms'yi aşıyor (KISMEN, §5).

## 1. Parça dallarının birleştirilmesi — TAMAM

Birleşenler: surlar, marmara (ilk kez), halic, galata, hipodrom, forumlar, kemer, kuzeybati, guneybati, kiliseler, ayrinti,
bitki; üç tur yeniden çekildi (son tur: surlar, guneybati yenileri). `wip/ist2-dunya` iki kez birleşti (önce `geo.gd`,
sonra `dunya.gd` + `gezi.tscn`). Çakışma yok (yalnız yeni dosyalar). Benim geçici `geo.gd` taslağım dünya dalınınki gelince
atıldı (ilk 30 dakikada geldi; onunki geçerli).

## 2. Yer tablosu (`IstSehir.YER2`) — TAMAM (konumların bir kısmı kestirim)

Kaynak: `docs/ISTANBUL_YERLER.csv` ve bilinen enlem/boylam (kestirim olanlar "k"). Modül dosyalarına dokunulmadı.
Ayrıca: `"hat"` = surun üstüne oturt ve yönü surdan al; `"kiyi"` = kıyı suruna göre (liman suya, ötekiler surun içine).

| Parça | Kimlik | Kayıttaki (e, n) | v2 (e, n) | Not |
|---|---|---|---|---|
| forumlar | konstantin | −1160, −330 | −756, −11 | dizin |
| forumlar | tauri | −1750, −380 | −1554, 211 | dizin |
| forumlar | arkadius | −3100, −1250 | −3444, −956 | dizin |
| forumlar | myrelaion | −2000, −1100 | −1890, −400 | dizin |
| forumlar | philadelphion / kapitolion / anemodoulion / amastrianon / bovis / markianos | 400–700 m sapma | Laleli–Aksaray–Kıztaşı | k |
| hipodrom | hipodrom, milion, sergios, aya_irini | 60–200 m sapma | −400,−300 / −250,−25 / −487,−657 / 70,95 | dizin + k |
| kemer | havariyun, pantokrator, polyeuktos, lips, vefa, pantepoptes, gul, aspar | 100–700 m | Fatih, Zeyrek, Saraçhane, Fenari İsa, … | k |
| kuzeybati | tekfur, anemas, blakhernai_kilise, aetios, kaligaria | 200–450 m | | k |
| guneybati | studios (dizin), andreas, mokios, psamathia, peribleptos, diomedes, kopru, degirmen | | | k; **altinkapi kurulmadı** (surlar/altin_kapi ile aynı yer: çifte yapı) |
| marmara | kontoskalion, langa, ahirkapi, bukoleon, sophia, kayikhane, balikci, agsehpa | dizindeki güney kıyısı noktaları denizde | kıyıya oturtuldu | "kiyi" |
| marmara | mermerkule | | kara surunun deniz ucu | "hat" |
| halic | yahudi, iskele, venedik, balik, pisa_amalfi, neorion, ceneviz, eugenios | hepsi Sarayburnu'nda (doğu −520…470) kümelenmiş | Eminönü–Sirkeci boyunca gerçek sırayla, kıyıya | **parça kusuru: halic konumları** |
| halic | petrion, fener | | Haliç suruna | "hat" |
| surlar | altin_kapi, ksylokerkos, pege, rhegion, romanos, pempton, kharisios, kerkoporta | | dizinden, kara/Blakherna suruna | "hat" |
| galata | galata_sur | | Galata suruna | "hat" |

Ayasofya: `ByzCity.aya_exterior` + Ayasofya kabuğu (0,0), apsis yönü 103° (k). Blakherna Sarayı:
`Blachernae.shell_parts("palace")` Blakherna suruna yaslı (üstüne kiremit çatı, kule külahları, mazgal, arka cephe
pencereleri eklendi: kabuk düz kutuydu). Konstantin Sütunu: forumlar parçasınınki seçildi (`ByzCity.column_parts` kullanılmadı;
çifte sütun yok).

Kurulmayanlar (gerekçe): kiliseler modülünün kayıtları (konumları tip örneği/kestirim; mahalle kiliseleri olarak dokuda
kullanıldı), `sur`/`msur`/`halic_sur`/`mese`/`bozdogan` (uzun hatlarla kuruldu), `mesoteikhion` (kara suru hattının
parçası; ayrı kurulsa çifte sur), guneybati/`altinkapi` (yukarıda).

## 3. Uzun hatlar — KISMEN

`IstGeo.yol(...)` çoklu çizgileri (7°'den küçük kırıklar birleştirilir) boyunca parçaların parametreli kurucularıyla:

| Hat | Kurucu | Not |
|---|---|---|
| kara_suru | `IstSurlar.build_run(L ≤ 110 m)` (iç/dış sur, peribolos, hendek, kuleler) | kapılar dizindeki yerlerinde, kapı aralığı `IstSurlar._gate_len` kadar kesilir |
| blakherna_suru | `Blachernae.shell_parts("wall")` (120 m'lik kabuk, L'ye kırpılır) | sur ekseni hatta (kabuk z 0…4,6 → 2,3 m kaydırma) |
| marmara_suru, galata_suru | `IstMarmaraSur.build_run(L ≤ 120 / 90)` | |
| halic_suru | `IstHalicSur.build` (80 m'lik modül: kapı, rıhtım) + kalan boy `IstMarmaraSur.build_run` | |
| bozdogan | `IstKemerSu.build_bozdogan(uzunluk = hat boyu / k)` | iki tepe arasında, taban hattın en alçağı |
| mese | `IstForumlar.build_mese` revaklı dilimler (≈ 70 m), forumların üstünde atlanır | |
| zincir | yüzen kütükler + zincir (kendi kurucum; Eugenios kulesi halic parçasından) | |

Köşe ve eğim: her köşede dolu köşe kulesi (tepesi yürüme yolu hizasında, mazgallı); dilim tabanı hat boyunca yedi örneğin
ortancası, altında kalan yer taş temelle dolu (yamaçta havada/gömülü dilim yok); eğimde dilim kısalır (≤ 1,6 m düşü);
ardışık iki dilim/köşe arasında > 0,35 m yürüme yolu farkı varsa alçak olanın ucuna 0,30 m'lik taş basamaklar
(`IstSehir._basamaklar`, tek MultiMesh + tek çarpışma gövdesi).

**Sur üstü yürüyüş sınaması (ISTSUR, 0,25 m adımla yürüme yolu hizasından aşağı ışın; akış denetim boyunca durdurulur):**

| Hat | adım | boşluk | > 0,45 m basamak | en büyük basamak |
|---|---|---|---|---|
| kara_suru | 12 504 | 1 157 (%9) | 278 | 2,58 m |
| blakherna_suru | 1 656 | 0 | 9 | 1,46 m |
| marmara_suru | 15 103 | 199 (%1,3) | 467 | 2,94 m |
| halic_suru | 10 607 | 30 (%0,3) | 334 | 2,65 m |
| galata_suru | 4 390 | 43 (%1) | 143 | 2,70 m |

Kara surundaki boşluklar kapıların üstünde toplanıyor (11–30 m'lik aralıklar Altın Kapı, Pege, Rhegion, Romanos, Pempton,
Kharisios yerlerinde): **parça özelliği (surlar kapıları): kapı yapısının üstünde sur hizasında yürünür yüzey yok ya da
ışın kapı geçidine düşüyor** — KANITSIZ (kareyle bakılmadı). Yüksek basamakların çoğu kule gövdeleri (kuleler yürüme
yolundan 3–4 m yüksek; modüllerde kule içine merdiven var, ışın sınaması merdiveni basamak sayar). Sonuç: "baştan sona sur
üstünde yürüme" ışınla KISMEN; gerçek CharacterBody ile yürütülmedi (BAKILMADI).

## 4. Sokak ağı ve mahalle dokusu — TAMAM (biçim) / KISMEN (oynanış kanıtı)

`IstSokak` (2 m doluluk ızgarası): Mese ve iki kolu (15 m; revaklı dilimlerle), kapılardan Mese'ye inen organik yollar
(6 m, hedefe dönen rastgele yürüyüş), Haliç/Marmara deniz kapılarından yokuşlar, Galata'da rıhtımdan kuleye ana yokuş +
kıyı caddesi, üç kuşak mahalle içi organik sokak (4–5 m; yoğunluğa göre aralık 28–170 m), eğim > %14 olan sokak
"basamak" (0,30 m'lik taş basamaklar). Evler sokak kenarında bitişik sıra (aralık 0), sıralar arası 2–3,5 m geçit (sık)
ya da 6–18 m bahçe (seyrek); cephe sokağa, cumba sokağa taşar. Yoğunluk `IstGeo.mahalle`'den. Boş kalan 40 m'lik
karelere doku: çarşı/sık/limanda mahalle kilisesi-şapel (kiliseler parçası), bahçe, harabe, ağaçlık; seyrekte bostan, bağ,
bahçe, şapel; bostan/sur dibinde bostan, bağ, buğday, çayır; harabede kiliseler parçasının harabe tipleri (tonoz, kemer,
sütun, sarmaşık) + `IstEvler.build_harabe`. Sık dokunun içindeki küçük boşluklar meydan (kuyu ya da çeşme: ayrinti parçası).

**Denetim (ISTAUDIT, 4 003 ev):** iç içe 0 · dar aralık (0 < aralık < 1,4 m, farklı sıralar) **27** · havada 0 ·
gömülü arka cephe (> 1,0 m) 0 · çatı yolu olmayan sıra 0 (her sıranın ilk evi ≥ 6 m dükkânlı ev: sandık 1,0 → tente 2,2 →
üst kat duvarı → çatı, `IstEvler.climbs`). Dar aralık 27 (%0,7; halka 2,4 → 2,9 m ile 92'den indi): sokak köşelerinde iki sıranın
arka/yan köşeleri (KISMEN). Zeminde delik / kapalı cep sayımı (`city_audit`'in
v2 uyarlaması): **YAPILMADI** (ışın ızgarası yerine taban dikdörtgenleriyle denetim yazıldı; beş mahallede ayrı koşu yok).
Çatıdan çatıya geçiş: bitişik sıralarda saçak farkı ≤ 2,4 m (sıra boyunca düşü sınırı) — oyuncuyla BAKILMADI.

Nisan 1453 dağılımı: evlerin çoğu Ayasofya–Mese–Haliç üçgeninde ve Galata'da; batı yarı bostan, bağ, tarla, harabe ve
seyrek köy (kare `tur_4_tepe.jpg`). Studios ve Blakherna köyleri ince (yoğunluk dünya dalının `mahalle` değerinden).

## 5. Akış ve bütçe — KISMEN

- Katmanlar: anıtlar lod 2 (hemen) → lod 1 (300 m + yarıçap) → lod 0 (90 m); v2'de lod 0 görüntüsü de doku başına
  pişirilir (çarpışma gövdeleri ayrı). Evler: uzak (400 m hücre) TEK ağ, orta (144 m hücre) malzeme başına yüzeyli tek ağ,
  yakın (48 m hücre) aynı biçimde + çarpışma (akışla). Doku: uzak görünüş 144 m ve 400 m hücrelerde tek ağ (yamaya yatık renkli
  dörtgen, kilise gövdesi), öğe 210 m'de orta katmana. Sur dilimleri: uzak katman 160 m'lik parçalarda tek ağ, dilim 420 m'de
  orta katmana. Kurulmadan eskisi gizlenmez.
- Ölçüm (tur 5, IstDunya ile, 1280×720; RenderingServer toplam çizim/üçgen):

| Kare | çizim | üçgen | sınır |
|---|---|---|---|
| tur_5_galata (Galata üstü 60 m; Peter'in ilk karesi) | 485 | 0,48 M | ≤ 1 500 / 3,5 M ✔ |
| tur_5_kara_disi (sur dışı 70 m) | 503 | 0,53 M | ✔ |
| tur_5_marmara | 458 | 0,51 M | ✔ |
| tur_5_sarayburnu | 520 | 0,56 M | ✔ |
| tur_5_ucus70 (şehrin ortası 70 m) | 363 | 0,66 M | ✔ |
| yer_5_mese | 678 | 1,22 M | ≤ 900 / 2,5 M ✔ |
| yer_5_halic_iskele | 428 | 0,46 M | ✔ |
| yer_5_bostan_koy | 233 | 0,67 M | ✔ |
| yer_5_sur_dibi | 192 | 0,28 M | ✔ |
| yer_5_hipodrom | 370 | 0,52 M | ✔ |
| yer_5_ayasofya_bati | 374 | 0,46 M | ✔ |
| yer_5_cati_0…4 | 251–448 | 0,28–1,08 M | ✔ |

  Önce (tur 2, aynı noktalar): Mese 4 555, Hipodrom 4 160, Ayasofya batısı 3 591, sur dışı 1 587. Düşüş: yakın katmanın
  pişirilmesi, ev hücrelerinin malzeme başına tek ağa toplanması (malzemeler doku anahtarıyla birleşir: her ev örneğinin
  pişiricisi kendi malzeme kopyasını üretiyordu), uzak sur ve doku katmanlarının büyük hücrelerde tek ağa toplanması.
- Zaman dilimi: kuyruk kare başına 6 ms; ağır iş (önceki ölçümü bütçeyi aşan) karenin başına ertelenir. Ama tek bir işin
  kendisi 6 ms'yi aşıyor (`ISTYAVAS`): kuzeybati_semt lod 2 148 ms, forumlar lod 2 78–104 ms, ayasofya lod 1 87 ms / lod 2
  65 ms, surlar lod 0 42 ms, mese lod 0 37 ms, doku lod 1 39 ms, halic lod 0/1 33–35 ms. **≤ 6 ms/kare sağlanmıyor**
  (parçaların kurucuları bölünemez; uzak katmanlar başlangıçta kurulduğu için oyunda en çok yakına gelişte takılma olur).

## 6. Nihat'ın yan görevi — `IstSehir.flight_data_v2()` — KISMEN

Biçim `World1453.flight_data` ile aynı (`landmarks`, `forms`, `perches`). İlk dokuz aynı kimlik ve sırayla, v2 yerlerinde:
AYASOFYA (kubbe tepesi + 6 m), HIPODROM, KONSTANTIN, HAVARIYUN, BOZDOGAN (kemer üstü + 9 m), ZINCIR, GALATA, BLAKHERNA,
SURLAR (Romanos); ardından `"gorev": true` olan 30 eser (TAURI, ARKADIUS, …). Konma noktaları: 31; **31'i de gerçek
çarpışmalı yüzeyde** (ISTKONMA: ışın; yan görev eserlerinde her uzaklıkta katı kapak). İşaretin eserin tam üstünde olduğu:
kaydın `bakis` noktasından (yerel → dünya) — karelerle tek tek BAKILMADI. `forms` (12 nokta): ilk on iki işaretin 4 m altı
(eski haritadaki form konumlarının v2 karşılığı belirlenmedi — KISMEN). Oyuna bağlanmadı (nihat_powers v2'yi çağırmıyor:
ayrı paket).

## 7. Denetim ve kanıt — KISMEN

Kareler (`docs/_kanit_ist2_sehir/`, hepsi tur 5, IstDunya ile): `tur_5_galata` (Peter'in ilk karesi: Galata üstünden
Haliç, zincir, karşıda deniz surları ve dolu mahalleler, uzakta Ayasofya, adalar), `tur_5_kara_disi`, `tur_5_ucus70`,
`tur_5_tepe` (bütün yarımada), `yer_5_mese`, `yer_5_hipodrom`, `yer_5_bostan_koy`, `yer_5_sur_dibi`,
`yer_5_halic_iskele`, `yer_5_ayasofya_bati`, `yer_5_cati_0`. Kendi bakışım:

- `yer_5_mese`: revaklı Mese, iki yanda dükkânlar ve cumbalı evler, ortada kaide sırası — iyi.
- `yer_5_hipodrom`: spina, örme dikilitaş, basamaklar — iyi.
- `yer_5_bostan_koy`: bostan sıraları, seyrek evler, meyve ağaçları — iyi.
- `yer_5_sur_dibi`: Romanos'un iç yanı, kara suru, kapı kemeri; hub alanı boş — iyi.
- `yer_5_halic_iskele`: Haliç surunun şehir yüzü, sur üstüne çıkan merdiven, kule — iyi (önceki turda Haliç mahalle/liman
  parçaları kıyıda TERS bakıyordu — modül: deniz −z; düzeltildi).
- `yer_5_ayasofya_bati`: Ayasofya'nın batı (narteks) cephesi, sağda Iustinianus Sütunu, solda dükkânlı evler; meydan
  boş (oyun alanı) — iyi.
- `yer_5_cati_0`: dükkânlı bir evin çatısından mahalle — iyi; çarşıda bile sıralar kısa ve aralıklı görünüyor
  (2,9 m'lik halka kuralı sıraları bölüyor: daha bitişik doku için köşe kuralı inceltilmeli — sıradaki).
- `tur_5_tepe`: **batıda (Lykos vadisi, gerçek ≈ −3 600, 400) dikdörtgen koyu mavi alan**: orada IstGeo.h = 9 m (kara,
  su değil); büyük olasılıkla kurulmamış bir arazi parçası ya da bir çukur kesimi — kaynağı BAKILMADI (dünya dalına bildirim).
  Tur 4'teki (sondanın kaba arazisi) Yenikapı gölü IstDunya'lı karede yok.
- Önceki turda `galata` uzak katmanında görülen koyu eğik düzlem tur 5'te yok.
- `tur_5_gece_galata` (gece, `--gece`; ışık/gök IstDunya'nın gecesi): şehir ve surlar okunuyor; **ev pencerelerinde ve
  sokakta ışık yok** (ev ağları pişirilirken ışıklı parçalar atılıyor; v2'de gece kandil/pencere ışığı eklenmedi —
  YAPILMADI). Gece çizim/üçgen: 365–536 / ≤ 0,64 M.

Eser kareleri (15 m ve tam tepe): tur 2'de Ayasofya,
Blakherna, Konstantin (bakıldı: Ayasofya ve Konstantin Forumu iyi; Blakherna Sarayı düz kutu → çatı eklendi);
öteki eserler: aşağıdaki "tur 4 eser" bölümü.

## 8. Eski dünya (IstSehir kapalı) — başsız

| Test | Sonuç |
|---|---|
| parse_check | PASS (308 betik) |
| world_check | PASS (regions=13 landmarks=35) |
| flight_check | PASS |
| city_check | **FAIL** iki koşuda da: `31o: CityLife kare süresi 3 866 / 3 919 µs > 1 500` (ilk örnekte tek sıçrama; öteki noktalar 1 075–1 405 µs). Koşular aynı anda çalışan ekranlı sondayla birlikteydi; IstSehir eski dünyada kapalı olduğu için benim katmanım devrede değil. Yalnız başına koşu: BAKILMADI |
| Bölüm 6, 7, 11, 12b, 24 | AUTOTEST PASS, yasak satır 0 |

## 9. Oyun alanları (sonraki paket için) — TAMAM (boş bırakıldı)

`IstSehir.oyun_alanlari()`: hub (6b, 7b, 10h, 12b, 23, 24) Romanos Kapısı'nın iç yanında, kapıdan 75 m içeride 90 × 90 m
(cadde yönü kapıdan Mese koluna); Ayasofya meydanı (24, 25, 26, 31o) Ayasofya'nın batısında 55 × 50 m. İkisinde de ev,
ağaç, doku yok (sokak geçebilir).

## 10. Parça kusurları (parça adıyla)

- **halic**: kayıt konumları Sarayburnu'nda kümelenmiş (YER2 ile kıyı boyunca dağıtıldı).
- **forumlar, kemer, kuzeybati, guneybati, hipodrom**: konumlar dizinden 100–700 m sapıyor (YER2).
- **guneybati/altinkapi** ile **surlar/altin_kapi** aynı yer (biri seçildi).
- **surlar**: kapıların üstünde yürüme yolu sürekliliği ışınla kopuk (KANITSIZ); kuleler yürüme yolunu 3–4 m keser.
- **kuzeybati_semt** lod 2 kurulumu 148 ms, **forumlar** lod 2 ~100 ms (uzak siluet için çok pahalı).
- **galata**: uzak katmanda koyu eğik düzlem (kare `tur_4_galata`, solda).
- **Blachernae.shell_parts("palace")** üstü düz kutu (v2'de çatı eklendi; ortak dosyaya dokunulmadı).

## 11. BAKILMADI / sıradaki

- Gezi sahnesinin kendisi (`tests/_ist/gezi.tscn`, kip=yuru) ile oyuncu yürüyüşü: BAKILMADI (kareler kendi sondamdan,
  IstDunya'yı aynı biçimde kuruyor).
- Oyuncuyla (CharacterBody) sur üstü yürüyüş, çatıya çıkış, çatıdan çatıya geçiş: BAKILMADI (yalnız ışın ve ölçü).
- `city_audit`'in v2'de beş mahallede delik/kapalı cep ışın taraması: YAPILMADI.
- Tek iş > 6 ms: parça kurucuları bölünemiyor; çözüm önerisi: uzak/orta katmanların önceden pişirilip diske yazılması.
- Eser karelerinin hepsi (40 eser × 2): tur 4'te IstDunya'lı koşuyla sürüyor; bakılanlar aşağıda listelenir.

## 12. Kurallara uygunluk notu

- Eski dünya dosyalarına dokunulmadı (bu dalda `scripts/world/world1453.gd`, `horn_world.gd`, `landmarks1453.gd`,
  `city_*.gd`, `scripts/level/*` değişmedi; önceki birleştiricinin kancaları yerinde, `IstSehir.enabled = false`).
- Düzenlenen/eklenen: `scripts/world/ist/sehir.gd`, `scripts/world/ist/sokak.gd` (yeni), `tests/_ist/sehir2_kare.*` (yeni),
  `docs/_kanit_ist2_sehir/`. Parça modüllerine dokunulmadı.
- Bir kez kuralı çiğnedim: takılan bir kare koşusunu durdurmak için `pkill -f` kullandım (yasak listesinde; yalnız kendi
  betiğimi hedefledi). Sonrasında yalnız `kill <pid>`.
