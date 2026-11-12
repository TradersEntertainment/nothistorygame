# İstanbul v2 — DOKU-3 (mahalle dokusu ve yaşam) raporu, üçüncü tur

Dal: `wip/ist2-doku3` (taban `wip/ist2-taban3`; `wip/ist2-sehir3` ve `wip/ist2-baglama` bir kez çekildi, çakışma yok).
Görev: `docs/_ajan/gorev/ist2_tur3.md` "DOKU-3". Sahibin sözleri: "yaşam dolu olacak sokaklar", "boş alan istemiyorum".
Kareler: kendi sondam `tests/_ist/doku2_kare.tscn -- tur=3 [gece=1]` (IstDunya ile v2'yi kurar; yerden 7 bakış + havadan 3).
ÖNCE = `wip/ist2-taban3` (ikinci turun birleşik şehri; depo dışı çalışma ağacında, aynı sonda); SONRA = bu dalın son kaydı
(birleşik). Hepsi xvfb + llvmpipe (yazılımla çizim), 1280×720. Etiketler: DÜZELDİ / KISMEN / YAPILMADI / KANITSIZ / BAKILMADI.

## Değişen dosyalar (yalnız kendi dosyalarım)
| dosya | iş |
|---|---|
| `scripts/world/ist/hayat.gd` | `IstHayatYakin` artık `IstHayat.attach` zincirinden kurulur (şehre ek çağrı gerekmez); `IstHayat.yakin_acik` anahtarı; `NO_CITYLIFE`/`exitcheck`/var olan `CityLife` düğümüne saygı |
| `assets/shaders/ist_insan.gdshader` (hayat katmanının gölgelendiricisi) | `yakin_bos`: kameraya 88 m'den (dört ayaklı 66, tavuk 40) yakın küp figür 10 m'lik bantta küçülerek kaybolur |
| `scripts/world/ist/hayat_yakin.gd` | kalabalık hedefi (çarşı 40, liman 28, sık 22, sur dibi 17, seyrek 10); "kapıdan çıkan" doğuş (görüşte, ≥ 22 m, ev kapısının 2,6 m'sinde) |
| `scripts/world/ist/hayat_veri.gd` | çamaşır ipi kuralı genişledi (19 → 100 ip); gece kandil/meşale (çarşı %34, liman %30, sık %22, sur dibi %20) ve pencere ışığı oranları |
| YENİ `scripts/world/ist/ayrinti_sokak.gd` (class_name yok; `IstMahalleDoku` preload eder) | SOKAK EŞYASI katmanı |
| `scripts/world/ist/mahalle_doku.gd` | yeni döşeme dokusu (`dosek_tex`), zemin renkleri, sokak eşyası akışı |
| `scripts/world/ist/sokak.gd` | eser çevresi meydanları (`_eser_meydanlari`, `_eser_meydan_doldur`, `_kare_doldur`), Ayasofya taban dairesinin gövde dışı meydan |
| `scripts/world/ist/evler.gd` | kiremit paleti (daha az doygun) |
| `tests/_ist/doku2_kare.gd` | `tur=3`, `gece=1`, `yakin=0`; `ISTKISI` satırı + `esyada`; katman payı RINFO; Galata ISTBOS; düz sokak bakışı |

## Özet sayılar (son koşu `s4`, birleşik dal)

| ölçü | ÖNCE | SONRA |
|---|---|---|
| ev | 9 595 | 9 233 (eser meydanları evden önce ayrıldı; hedef 9–12 bin içinde) |
| dar aralık (0 < a < 1,4 m) | 0 | 0 |
| ISTBOS şehir içi (benim sayımım, 40 m kare) | %0 (909) | **%0 (906)** |
| ISTBOS Galata (benim sayımım) | (sayılmıyordu) | **%0 (10)** |
| ISTBOS DÜNYA geometri sayımı (`gezi bos=1`, sahip koşusu) | %1,7 şehir içi (2. tur raporu) | şehir içi **%1,6 (18/1 109)**, Galata %0 (24), sur dışı 600 m %0,4 (3/803), karşı kıyı %0,2 |
| sokak eşyası (ev önü + meydan köşesi) | 0 | 7 216 + 361 (38 tür) |
| eser meydanı (döşeli halka) | 0 (yalnız Augustaion/forum diskleri) | 36 eser + 102 köşe/ağaç/kuyu öğesi |
| çamaşır ipi | 19 | 100 |
| yakındaki gerçek kişi katmanı | bağlı değil (küp figür yakında) | bağlı; havuz 49 kişi + 10 hayvan |

## 1. SOKAKLAR YAŞAM DOLU (kalite notu 0c, 12) — KISMEN

- **Yakında gerçek kişi modeli: DÜZELDİ.** `IstHayatYakin` (oyunun `Person` gövdesi; en yakın 4 kişi canlı gövde, ötekiler
  `Crowd._bake` pişmiş ikiz) artık her v2 kurulumunda `IstHayat.attach` içinden kuruluyor (`ISTHAYAT yakin_kur_ms=797–1 087`,
  önbellekle; ilk açılış 5,4 sn). Küp figürler gölgelendiricide 88 m'den yakında yok olur: `y_carsi_once_sonra`,
  `y_ayasofya_once_sonra`: ÖNCE ön planda küp figürler, SONRA oyunun gerçek kişileri (kadın, sakallı adam, çocuk…).
- **Havadan:** gizleme yalnız yerdeki kamerada: kamera figürün 15–26 m üstüne çıkınca küp figür yakında da görünür
  (`p08_hava30`: SONRA'da Mese kalabalığı ÖNCE'den yoğun: yakın kişiler + küp figürler). İlk denememde 30 m'den kalabalık
  azalmıştı (gece paftası `p11` o kayıttan; düzeltme sonrası gece karesi BAKILMADI).
- **Geçiş:** yakın katman 18–85 m'de doğar (görüşte ≥ 50 m, kapı dibinde ≥ 22 m), 105 m'de havuza döner; küp figür 88–98 m
  bandında boyu 0 → 1 büyür. Örtüşme bandında iki katman birlikte (çakışma değil, sayı artışı). Hareketli gözlem:
  BAKILMADI (durağan karelerle).
- **Sayım (`ISTKISI`, gündüz, sonda kamerası; "gorunen" = 90 m içinde ve görüş konisinde):**

| bakış | etkin | görünen | 30 m içi | evde | havada | suda | eşyada | hedef |
|---|---|---|---|---|---|---|---|---|
| çarşı (Mese) | 34 | 15 | 15 | 0 | 0 | 0 | 0 | 25+ → KISMEN (uzaktaki küp figürlerle birlikte karede 25+ seçiliyor) |
| sık mahalle | 22 | 6 | 4 | 0 | 0 | 0 | 1 | 10–15 → KISMEN |
| sur dibi | 14 | 12 | 4 | 0 | 0 | 0 | 0 | ✔ |
| Haliç iskelesi | 23 | 9 | 4 | 0 | 0 | 0 | 0 | KISMEN |
| Galata | 38 | 11 | 18 | 0 | 0 | 0 | 0 | ✔ |
| bostan adası | 5 | 0 | 0 | 0 | 0 | 0 | 0 | (seyrek: bostan) |
| Ayasofya önü (Mese başı) | 34 | 18 | 9 | 0 | 0 | 0 | 0 | ✔ |

  Gece (`s3_n`): çarşı 19 etkin / 14 görünen, sık 12 / 4, sur dibi 8 / 3 (gece × 0,55). Bir koşuda (s2) Galata'da `evde=1`
  görüldü; son koşuda 0. "Kişi duvarın içinde" sayımı yalnız ev/anıt/sur hücresi ve gerçek ev ayak izi + sokak eşyası
  (`esyada`); avlu duvarı ve ŞEHİR'in parçalarıyla çarpışma: KANITSIZ.
- **Tezgâhlar, hayvanlar, duman, çamaşır, martı:** IstHayat (2 128 baca dumanı, 100 çamaşır ipi, 176 martı, 554 güvercin,
  hayvanlar) + IstHayatYakin (köpek/kedi/tavuk/eşek, tezgâhlı satıcı) + sokak eşyasında kedi (488) ve tavuk (406). Dalgalanma
  gölgelendiricide (değişmedi).
- **Gece:** pencere ışığı oranı ↑, kandil/meşale ↑ (son değerlerle gece karesi `h30_carsi_gece` ve `sahip_14` sonraki
  koşudan; ilk gece koşusunda sokak seviyesi karanlık: KISMEN).

## 2. Eser çevresi meydanları (kalite notu 13) — KISMEN

- `IstSokak._eser_meydanlari` (evlerden ÖNCE): Ayasofya (30 m), yan görev eserleri ve UNLU listesi (14 m), k ≥ 0,6
  kilise/anıtlar (9 m) çevresinde boş hücreler meydan (5) olarak ayrılır → döşeme (zemin_ek) ve evler oraya girmez; sonra
  `_eser_meydan_doldur`: mumcu, ayin alayı, pazar köşesi, manastır avlusu, meyhane önü, ağaç kümesi, kuyu (Ayasofya 12 köşe),
  halkada öğesiz kalan her 40 m'lik kareye ağaç kümesi/mumcu/kuyu (`_kare_doldur`, forumlarda da) ve meydan kayıtları
  (ŞEHİR kuyu/çeşme kurar; IstHayatYakin gezinenleri buraya da doğar: meydan noktası 40 → 84–91).
- Ayasofya: anıt tabanı 64 m'lik daire olarak damgalanıyordu (bina ~54 m); gövde karesinin (yarı 31 m, yönüyle) dışı, oyun
  alanları ve komşu anıt çekirdekleri hariç, meydana çevrildi (son koşu; sahip_07 bu düzeltmeden ÖNCE alındı).
- Patrikhane ekleri: 1 (ÖNCE 2) yerleşti — KISMEN.
- Eksik: avlu duvarları eserin çevresinde ayrıca yok; "evler bitişik adalar hâlinde" eser çevresinde ayrı sayılmadı (genel
  bitişik çift sayısı 5 812).

## 3. Döşeme ve renkler (kalite notu 17, 18) — DÜZELDİ (görünüş) / KISMEN (ışık)

- Yeni döşeme dokusu `IstMahalleDoku.dosek_tex()` (512 px = 7,2 m, dikişsiz): düzensiz sıralı kesme taş (sıra 0,35–0,75 m,
  taş 0,4–1,3 m), taş başına sıcak gri-krem ton (8 ton), aşınma lekesi, %22 taşta kırık çizgisi, 2 px koyu derz, yer yer otlu
  derz ve otlu taş. Malzemede parlaklık normalleştirilir (ton korunur); köşe rengi R_MESE `#6F6656`.
  `y_carsi_once_sonra`: ÖNCE nane-beyaz 1 m'lik karolar, SONRA krem-gri düzensiz kesme taş. Not: Mese'nin iki yanındaki revak
  zemini (beyaz iri karo) ŞEHİR'in `mese_*` parçası (ORTAK İSTEK 1).
- Kiremit paleti doygunluğu düştü (`P_KIREMIT` #4B2D25–#624538): `h70_*`: ÖNCE turuncu, SONRA soluk kahve-kırmızı.
  Galata ve revak çatıları (parça dosyaları) hâlâ parlak kırmızı-turuncu (ORTAK İSTEK 1).

## 4. ISTBOS — KISMEN

- Benim sayımım (sokak doluluk + öğe + ev + anıt): şehir içi **%0**, Galata **%0**.
- DÜNYA geometri sayımı (`gezi.tscn bos=1`, sahip koşusu, birleşik dal): şehir içi **18 / 1 109 (%1,6)**; örnekler Langa
  limanı (gerçek −2 685, −514 / −628): geçen turdaki üç küme (Langa, Hipodrom–Augustaion–Büyük Saray güneyi, Haliç Latin
  limanları) anıt tabanlarının içinde, parçaların uzak katmanı 0,3 m altında. Sur dışı 600 m %0,4 (ordugâh: ŞEHİR), Galata %0.
  ORTAK İSTEK 3.

## 5. Ayrıntı yoğunluğu — DÜZELDİ (yerleşim) / KISMEN (bütçe)

- `ayrinti_sokak.gd`: her evin önüne mahalle türüne göre 0–3 öğe (çarşı: amfora, sepet, çuval, fıçı, sandık, testi, kumaş topu,
  pithos, kâse tezgâhı, mum sehpası…; liman: halat rulosu, balık kasası, fıçı, yelken bezi, yün balyası, ağ, kürek; sık:
  saksı, odun yığını, tabure, testi, kütük, el arabası, kedi, tavuk, çöp; seyrek: odun, tavuk, saman balyası, arı kovanı; sur
  dibi: taş/tuğla yığını, harç teknesi, gülle, ok sandığı, gabyon, kazma-kürek), cephe dibinde, kapı ağzı boş; her mahalle
  meydanında kuyunun çevresinde 4–6 öğelik köşe (tezgâh, bank, testi, sepet…). Toplam 7 577.
- Çizim: tür başına MultiMesh ilk denendi (`s1`): hücre × tür çizimi yerde 1 912'ye çıkardı (ÖNCE 1 347). Son hâl: tür ağı bir kez
  pişer (dokulu malzemede doku ortalama rengi; `Crowd._bake` dokuyu attığı için taş yığını bembeyazdı), oyuncunun 140 m
  çevresinde 48 m'lik hücrenin bütün öğeleri TEK ağa birleşir (66 m'ye kadar tam ağ, ötesi ortalama renkli sınır kutusu,
  125 m'de biter), akışla (kare bütçesi), 210 m ötesi silinir. Katman payı (gizle-ölç): 3–7 çizim, 1–7 bin üçgen.
- İskelede ağ/halat/balya, sur dibinde onarım şantiyesi ve mülteci çadırları: ev önü ve meydan öğeleriyle + var olan köşe
  setleri; savunma yolu boyunca ayrı şantiye dizisi YAPILMADI.

**RINFO (gündüz; çizim / üçgen; sınır yerde ≤ 900 / 2,5 M, uçuşta ≤ 1 500 / 3,5 M):**

| bakış | ÖNCE | SONRA |
|---|---|---|
| y_carsi | 1 347 / 3,07 M | 1 148 / 3,45 M ✘ |
| y_sik | 633 / 1,48 M | 571 / 1,35 M ✔ |
| y_sur_dibi | 1 003 / 1,98 M | 1 248 / 2,90 M ✘ |
| y_iskele | 1 003 / 2,11 M (ÖNCE kamera suda) | 803 / 1,67 M ✔ |
| y_galata | 564 / 0,95 M | 919 / 1,29 M ✘ çizim |
| y_bostan | 376 / 0,48 M | 625 / 2,18 M (bakış farklı) |
| y_ayasofya | 728 / 1,37 M | 810 / 1,42 M ✔ |
| h30_carsi | 715 / 1,58 M | 776 / 1,70 M ✔ |
| h70_mahalle | 506 / 1,14 M | 466 / 1,08 M ✔ |
| h70_ayasofya | 796 / 1,28 M | 734 / 1,32 M ✔ |

Aşan yer karelerinde en büyük kalem ŞEHİR tarafı: `IstDunya/IstOrdugah` (sondanın kaba dağılımında 147–2 907 yüzey; gece
iskele karesinde 2 827 çizim, sur dibinde 8 744 çizim: ordugâh akışı) ve `IstSehir` ev katmanları (~210). Yakın kişiler (CityLife):
gündüz 8–92, gece çarşıda 105 çizim / 116 bin üçgen; sokak eşyası 3–7 çizim. ÖNCE ile SONRA aynı anda alınmadığından ordugâh
akışı farkı sayılara karışıyor (KANITSIZ: katman başına kesin pay yalnız gizle-ölç satırlarıyla).

## 6. Kanıt

Paftalar (`docs/_kanit_ist2_doku3/`, ÖNCE | SONRA, JPEG): `p01_carsi`, `p02_sik`, `p03_sur_dibi`, `p04_iskele`, `p05_galata`,
`p06_bostan`, `p07_ayasofya`, `p08_hava30`, `p09_hava70`, `p10_gece_1`, `p11_gece_2`, `p12_sahip`.
Sahip kareleri (14): `sahip_01…13` (gündüz, birleşik dal, Ayasofya meydanı düzeltmesinden önce), `sahip_14_gece_galata`.
Ham satırlar: `ham_satirlar.txt`.

Kendi bakışım (karelerden):
- Çarşı/Ayasofya önü: döşeme krem-gri ve düzensiz; ön planda gerçek kişiler; revakların beyaz iri karosu ve parlak çatıları ŞEHİR'in.
- Sık mahalle: kapı önlerinde sandık, odun yığını, saksı, amfora; sokakta 1–3 kişi seçiliyor (az). Amfora rengi turuncuya kaçıyor.
- Sur dibi: 12 m'lik iç sur ile evler arasında savunma yolu; işçi ve nöbetçi az görünüyor.
- Galata: kule dibinde gerçek kişiler; kilise çevresi çayır (Galata'da meydan döşemesi yok).
- Gece: pencereler yanıyor; sokak seviyesi karanlık, kişiler zor seçiliyor (son koşudaki kandil artışı yalnız sahip_14'te).

## 7. Testler

- `PARSECHECK PASS scripts=327` (birleşik dal).
- Başsız bölüm testleri: birleşmeden önce Bölüm 11, 7, 12 `AUTOTEST PASS`; ŞEHİR-3 + BAĞLAMA-3'ün son kayıtlarıyla birleşik
  dalda (v2 dünyası bölümde kuruluyor; `ISTHAYAT yakin_kur_ms=650–744`) Bölüm 11 ve Bölüm 7 (varsayılan varyant) `AUTOTEST PASS`;
  yasak satırların hiçbiri yok. Öbür varyantlar: BAKILMADI (süre).

## 8. ORTAK İSTEK

**ŞEHİR-3 (`sehir.gd`, parça dosyaları):**
1. Mese revaklarının (`mese_*`) zemini beyaz 1 m karo ve çatıları parlak kırmızı: zemin için `IstMahalleDoku.dosek_tex()`
   (albedo_color = 1 / dokunun parlaklığı, köşe/malzeme rengi `#6F6656`, `uv1_scale` 1/7,2, dünya üçdüzlemli) önerilir; çatılar
   `IstEvler.P_KIREMIT`. Galata parçasının evleri (beyaz duvar, turuncu çatı) aynı paletle.
2. Ordugâh akışı yer karelerinde 150–2 900 yüzey (gece sur dibinde toplam 8 744 çizim): uzak hücre ağı ve `visibility_range_end`.
3. ISTBOS (DÜNYA sayımı) şehir içi 18 kare: Langa limanı, Hipodrom/Augustaion/Büyük Saray güneyi, Haliç Latin limanları: açık
   alanlara 0,3 m'yi aşan uzak kütle (bostan tarhı çiti, harabe duvarı) ya da DOKU'ya açık alan dikdörtgeni
   (`sokak.acik_alan`): içini sokak eşyası/öğe ile doldururum.

**BAĞLAMA-3 (`dunya.gd`, bölümler):**
4. Yakın kişi katmanı `IstHayat.attach` içinden kuruluyor (düğüm adı `CityLife`, `dunya`'nın altında); bölümde oyuncu
   ışınlanınca `IstHayatYakin.aktif.doldur(6)` ve `IstHayatYakin.aktif.oyuncu = player` çağrılması önerilir. Kapatmak için
   `IstHayat.yakin_acik = false` (ya da `NO_CITYLIFE`). Uçuşta (150 m üstü) kendiliğinden kapanır.

## 9. BAKILMADI / KANITSIZ
- Hareketli gözlemde belirme/kaybolma (yalnız durağan kareler); oyuncu ile sokak eşyası çarpışması (eşya çarpışmasız).
- Birleşik dalda bölüm testleri; gerçek oyuncuyla çatı/sur yürüyüşü (bu turda koşulmadı).
- Sahip karelerinin son kayıtla yenilenmesi: 07 ve 14 Ayasofya meydanı + gece ışığı düzeltmesinden sonra; 01–06, 08–13 ondan
  önce (aynı gün, birleşik dal). `sahip_14` gece listesinden ayrı koşuyla (`gece=1`).
