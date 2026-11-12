# İstanbul v2 — DOKU-2 (mahalle dokusu) raporu, ikinci tur

Dal: `wip/ist2-doku2` (taban `wip/ist2-taban2`; `wip/ist2-dunya2`, `wip/ist2-sehir2`, `wip/istanbul-gorunus` birleştirildi).
Görev: `docs/_ajan/gorev/ist2_tur2.md` "DOKU-2"; sayılar `_ist2_ortak.md` "SON AYAR" (S = 0,35; hedef 9–12 bin ev).
Dosyalar: `scripts/world/ist/sokak.gd` (IstSokak), `scripts/world/ist/evler.gd` (IstEvler), YENİ `scripts/world/ist/mahalle_doku.gd`
(IstMahalleDoku), YENİ sonda `tests/_ist/doku2_kare.*`. Başka dosyaya dokunulmadı.
Kareler: kendi sondam (`tests/_ist/doku2_kare.tscn`, IstDunya ile v2'yi kurar, aynı bakışlar gerçek koordinatla). ÖNCE = birinci
turun şehri (bu dalın açılış kaydı, S = 0,5); SONRA = son birleşik dal (S = 0,35). Hepsi xvfb + llvmpipe, 1280×720.
Hüküm etiketleri: DÜZELDİ / KISMEN / YAPILMADI / KANITSIZ / BAKILMADI.

## 0. Özet sayılar (son koşu, birleşik dal, S = 0,35)

| ölçü | ÖNCE (birinci tur, S 0,5) | SONRA |
|---|---|---|
| ev | 3 984 | **9 595** (hedef 9–12 bin) |
| sıra (ada kenarı) | 2 813 | 3 851 (sıra başına 2,5 ev; ÖNCE 1,4) |
| bitişik ev çifti (aralık 0) | 1 171 | 5 956 |
| dar aralık (0 < a < 1,4 m, ev tabanları arası en kısa uzaklık, bütün çiftler) | 4 | **0** |
| sokaktan çatıya yolu olan sıra | (yalnız dükkânlı ilk ev; sayılmadı) | **3 851 / 3 851 (%100)** |
| ISTBOS şehir içi (benim sayımım: ev/doku/öğe/avlu/anıt; oyun alanları hariç) | %0,6 | **%0** (909 kare) |
| avlu (duvarlı iç bahçe) | 0 | 1 137 |
| sokak | 630 | 1 096 (+ 51 savunma yolu parçası) |
| mahalle kilisesi/şapel yeri | 76 | 32 ayrılmış yer + doku kiliseleri |
| bahçe ağacı / tarh (blok içleri) | 0 | 1 999 ağaç + tarhlar |

Şehir içi doluluk (2 m ızgara): ev %23,1 · yol %20,3 · avlu %4,9 · doku %1,8 · anıt/sur %12,3 · serbest %37,6 (serbest
hücrelerin büyük kısmı blok içi bahçe: ağaç/tarh serpiştirmesiyle dolu; ISTBOS'ta boş kare yok).

Tip dağılımı: sıra ev 3 570 · dükkânlı 2 158 · teras (düz dam, dış merdiven) 1 446 · yoksul kulübe 1 698 · demirci 183 ·
fırın 176 · harap/terk edilmiş 198 · kule ev (sur dibi) 67 · Latin evi 50 · konak 36 · ambar 11 · han 2 (+ patrikhane 2).
Kat: 1 katlı 6 895 · 2 katlı 2 567 · 3 katlı 133 (yalnız çarşı ve Latin mahalleleri).

## 1. Kalite notu 0, 0b, 2, 6, 7 — şehir sura kadar dolu, sokak zemini, adalar, sur dibi

| madde | hüküm | ayrıntı / kare |
|---|---|---|
| Şehir sura kadar dolu | DÜZELDİ | `tur1_sur_dibi30`, `tur1_tepe_batı`: batı yarı (ÖNCE çayır) sıra evler, avlular, bahçelerle dolu; adalar (bostan/bağ/harabe/manastır, dünya dalının `alt` alanından) dokunun içinde |
| Havadan sokak/ada okunur | DÜZELDİ | `tur1_tepe_mahalle`, `tur1_tepe_batı` (260–300 m tam tepe): sokak ağı açık toprak/taş zemin, adalar kırmızı-kahve çatı blokları |
| SOKAK ZEMİNİ görünür | DÜZELDİ | IstMahalleDoku: yol/ev/avlu/meydan hücreleri üzerinde yürüyen kareler (marching squares) ile tek parça zemin. Mese, forumlar, Augustaion, mahalle meydanları: iri kesme taş döşeme (`flagstone`); kapı yolları: kaldırım taşı; ara sokaklar, savunma yolu: sıkıştırılmış toprak (kuru/çamurlu lekeler, yumuşak gürültü); avlu: açık toprak. `tur1_sokak`, `tur1_hava30` |
| Yokuşta basamak | KISMEN | eğim > %14 sokaklar "basamak" türünde (65 adet); taş basamakları ŞEHİR çiziyor (`sehir.gd`, değişmedi); zemin altta toprak |
| Zeminle z-çakışması yok, araziye oturur | DÜZELDİ (ölçüyle) | zemin köşe yüksekliği = max(IstGeo.h, arazi ağının 6/12/24 m'lik iki köşegen bölünmesinin yüksekliği) + 6 cm: hiçbir arazi ayrıntı düzeyinde gömülmez; aynı köşeyi paylaşan kareler tek ağ (iki sokak üst üste çizilmez). Karelerde titreme görülmedi (durağan kare; hareketli gözlem BAKILMADI) |
| Adalar: bitişik sıra + avlu duvarı + iç bahçe/ağaç/kuyu | DÜZELDİ | sıranın arkasında avlu (sık dokuda 2,4 m, seyrekte 1,0 m taş duvar, kapak taşı, 1,6 m kapı ağzı; içte ağaç + kuyu/çardak/kümes/çamaşır ipi/odun yığını). Blok içinde kalan boş yerlere (çevresi 6 m boşsa, geçit tıkanmaz) meyve ağacı/servi ya da sebze tarhı/çalı. `tur1_hava30`, `tur1_cati` |
| Sur dibinde surun iç yüzüne yaslı sıralar, arada 4–6 m savunma yolu | DÜZELDİ | sur bandı iç yüzden 1 m ötesinden yeniden açılır (köşe kuleleri kapalı kalır); iç yüzden 3 m içeride 4 m'lik savunma yolu; sıra cepheleri yola. Kara surunda (k = 1: iç yüz hattan 2,5 m) yol + ev cephesi arası ≈ 5,9 m. `tur1_sur_dibi_yer` (solda 12 m'lik iç sur, sağda sıra evler) |
| Köşe kuralı incelsin (sıralar kısa ve aralıklı kalmasın) | DÜZELDİ | 2,9 m'lik ızgara halkası kaldırıldı; yerine KESİN kural: her ev tabanı başka sıraların evleriyle ya bitişik (iç içe değil) ya ≥ 1,4 m (döndürülmüş dikdörtgenler arası en kısa uzaklık). Sıralar komşu sıraya bitişik sürebilir (%70), değilse 1,6–3,6 m geçit. Ev derinliği arkadaki boş derinliğe göre seçilir (arkada ≥ 1,4 m geçit). Sıra başına ev 1,4 → 2,5 |

## 2. Ev çeşitliliği — DÜZELDİ (görünüş) / KISMEN (bazı tipler az)

- Palet `docs/ISTANBUL_GORUNUS.md` §2'den: kireçtaşı gri-krem, kirli krem sıva, kirli kireç badana, sıvasız kerpiç/moloz,
  tuğla kuşak, yaşlı ahşap, kiremit kızıl-kahve / soluk / yosunlu, düz dam toprak. Pembe sıva ve parlak turuncu çatı YOK.
  Sahne ışığı (dünya dalı: sıcak güneş) renkleri ≈ (1,33; 1,35; 1,07) kat yükseltiyor (karelerden piksel ölçüsü); palet
  görünen renk hedefle ×0,82 verildi.
- Duvar biçimleri (tohumdan): taş-tuğla şeritli (opus mixtum: taş zemin + ince tuğla kuşaklar), kireç badana, açık sıva
  tonları, ahşap çıkmalı (üst katta dikme ve kuşak), sıvasız moloz/kerpiç (yoksul).
- Çatı: kiremit beşik (6 ton), yosun/soluk kiremit lekeleri (tona yakın), düz dam, teras (1,0 m korkuluk + asma çardağı),
  sundurma (2,2 m), baca (%45 + fırın/demirci), harap çatı (çökük köşe, kirişler; çarpışma kapalı).
- Tipler: sıra ev, dükkânlı ev (tezgâh + bez tente), kule ev (mazgallı, sur dibi), yoksul kulübe (2,2 m saçak, alçak
  kapı), avlulu konak (bifora pencereler, sundurma), han (kemerli revak ağızları), fırın (dam üstünde kubbeli fırın, odun),
  demirci (açık atölye, ocak, örs), ambar ve Latin evi (kemerli depo kapıları, 3 kat), harap/terk edilmiş ev (tahta
  çakılı kapı/pencere, dökülmüş sıva, ot). Han 2 + patrikhane 2: az (KISMEN).
- Kat: çoğu 1–2 katlı (saçak 3,4 / 5,8 m); 3 katlı (8,4 m) yalnız çarşıda ve Latin mahallelerinde (Haliç kıyısı
  gerçek doğu −1250…−200 ve Galata). Sıra boyunca kat farkı ≤ 1.
- **Uzak/orta/yakın renkleri AYNI:** dokulu yüzeyin malzeme rengi = palet rengi / dokunun ortalama rengi (`IstEvler._dk`);
  uzak katman (lod 2, düz renk) palet rengini doğrudan kullanır. `tur1_hava70`: yakındaki ve 1 km ötedeki evler aynı
  tonda (ÖNCE'de uzak evler beyazlaşıyordu). DÜZELDİ.

## 3. Boş alan yok — DÜZELDİ (benim sayımım) / KANITSIZ (dünya dalının geometri sayımı, aşağıda)

- Evsiz 40 m'lik karelere: IstBitki yamaları (bostan, bağ, buğday, bahçe/meyve; dünya dalının `alt` alanına göre), yama
  kenarında bahçe duvarı ya da çit (sokak yanı açık), yanında kuyu / bağ kulübesi / ağıl; harabe (kiliseler parçasının
  tipleri), manastır (`alt = manastir`), mezarlık; yine boş kalan karede kuyu, ağıl ve sürü (çit halkası, koyun/keçi,
  saman), çiftlik evi, ağaç kümesi, şapel ve IstAyrinti köşe grupları (fırın önü, demirci, dokumacı-boyacı, bostan köşesi,
  sur onarım şantiyesi, mülteci çadırları). Bloğun içinde kalan serbest yerlerde bahçe ağacı/tarh.
- Benim ISTBOS sayımım (sondada; ev, doku yaması, öğe, avlu, anıt tabanı; Romanos ve Ayasofya oyun alanları hariç):
  **909 karede 0 boş**.
- Dünya dalının geometri sayımı (`gezi.tscn bos=1`, zeminden ≥ 0,3 m yükselen geometri): sonuç aşağıda (§7, "gezi").

## 4. Meydanlar ve çarşılar — KISMEN

- Ayasofya çevresi: Augustaion ve Ayasofya çevresi taş döşeme (zemin diskleri), patrikhane ek yapıları (güneyde, Ayasofya'ya
  bakan konak/han: 2 yapı yerleşebildi), mumcular (tezgâh + mum sehpası + tente), ayin alayı hazırlığı, pazar köşesi,
  manastır avlusu köşeleri (boş hücreye sığanlar). Ayasofya'nın batısındaki oyun alanı boş bırakıldı.
- Forum meydanları (Konstantin, Tauri, Arkadius, Bovis, Amastrianon, Philadelphion): döşeme + pazar/ayin/meyhane köşeleri.
- Kapı önleri: kara kapılarında sur onarım şantiyesi, deniz kapılarında balıkçı iskelesi, öbürlerinde pazar köşesi +
  kaldırım diski. Mahalle meydanları (40): taş döşeme + kuyu/çeşme (ŞEHİR kurar).
- Eksik: iskele önlerinin kendine özgü ayrıntısı Haliç liman parçalarına bağlı (benim dokum yalnız kapı yokuşunun başında).

## 5. Oynanış — DÜZELDİ (yapı kuralları ve sayım) / BAKILMADI (gerçek oyuncu)

- Her ev kapalı katı: gövde, üst kat, çatı (eğimli çatıda dışbükey kama; düz dam/teras kutusu + korkuluk), tente,
  sundurma, sıra, dış merdiven çarpışmalı (`IstEvler.shapes`, görüntüyle aynı plandan: `IstEvler.plan`).
- Bitişik aralık 0 ya da ≥ 1,4 m: **dar aralık 0** (bütün ev çiftleri, en kısa uzaklık; ÖNCE 4, birinci tur raporunda 14–27).
  Avlu duvarları da aynı kuralla (avlu dikdörtgeni öbür sıralara ya bitişik ya ≥ 1,4 m).
- Her adada (sırada) sokaktan çatıya yol: **%100** (3 851 sıra). Yollar: dükkânlı ev sandık 1,0 → tente 2,2 → saçak;
  sundurmalı ev sıra 1,0 → sundurma 2,2 → saçak; teras ve kule evde dış taş merdiven (0,30 m basamak) dama; kulübede saçak
  2,2 m (sundurma gibi tutunulur). Dış merdiven her zaman sıranın DIŞ ucunda (sıra içinde 1,0 m pay; komşu eve girmez).
- Çatıdan çatıya: sıra içinde bitişik evler, kat farkı ≤ 1 (saçak farkı ≤ 2,4 m), sıra boyunca düşü ≤ 2,4 m.
- Avlu çukur değil: zemin arazi, kapı ağzı 1,6 m (sol, sağ ya da arka duvarda); avlu ile karşısındaki yapı arasında ≥ 1,4 m.
- Yamaçta taban oturur: sıranın arka köşeleri cephe tabanından en çok 1,0 m yüksek, sıra boyunca düşü ≤ 2,4 m; alçak
  köşelerde ŞEHİR'in taş kaidesi.
- **Gerçek oyuncuyla sokaktan dama (KISMEN):** sonda `oyuncu=1` kipi (`scripts/player/player.gd`, CharacterBody3D) beş teras
  evin dış merdiveninin dibinden ileri yürür. Bulunan ve düzeltilen üç kusur: (1) basamak derinliği 0,28 m'ydi (kapsül
  basamağa basamıyordu) → evin bütün derinliğine yayıldı (0,45–0,8 m); (2) merdivenin alt ucu evin arkasındaydı (arka
  komşu bitişikse sokaktan ulaşılamıyordu) → sokak cephesinden başlar, arkaya çıkar; açık yanda 1,0 m taş korkuluk;
  (3) düz damın 10 cm'lik yan saçağı merdivende başa çarpıyordu → merdiven yanında saçak yok, teras korkuluğu içeride.
  Son koşu: **1/5 PASS** (Haliç kıyısı, gerçek 435, 697: 3,6 m çıkıp dama ulaştı); kara surunun dibindeki üç evde (gerçek
  −4 990, −820 / −4 987, −1 029 / −3 597, −239) oyuncu merdivenin 2,4 m'sinde duruyor (çarpışma listesinde yalnız zemin;
  adsız bir parça gövdesinin üstünde: sur/kapı ayrıntısının merdivenle çakışması olası — KANITSIZ); bir evde (−2 265, −617)
  ilk basamakta (sokak evin tabanından alçak: ilk basamak > 0,42 m). Satırlar: `DOKU2 cati_sina …`.
- Çatıdan çatıya geçiş gerçek oyuncuyla: BAKILMADI (ŞEHİR-2'nin sondasında "oyun denetimi … çatıdan çatıya" var).

## 6. Bütçe — KISMEN (benim katmanım içinde; toplam yer sınırı ordugâh yüzünden aşılıyor)

RINFO (RenderingServer toplam; son koşu, birleşik dal; sınır uçuşta ≤ 1 500 / 3,5 M, yerde ≤ 900 / 2,5 M):

| kare | ÖNCE çizim / üçgen | SONRA çizim / üçgen | sınır |
|---|---|---|---|
| hava70 (70 m) | 330 / 0,61 M | 534 / 1,12 M | ✔ |
| hava30 (30 m) | 302 / 0,76 M | 516 / 1,26 M | ✔ |
| tepe (2 300 m tam tepe) | 533 / 0,46 M | **1 621** / 2,25 M | ✘ çizim (ordugâh 405, gemiler 118: §8) |
| tepe_mahalle (260 m) | 200 / 0,41 M | 517 / 1,37 M | ✔ |
| tepe_batı (300 m) | 32 / 0,06 M | 457 / 1,61 M | ✔ |
| sokak (yer) | 354 / 0,97 M | 526 / 1,32 M | ✔ |
| sokak_bati (yer) | 250 / 0,48 M | **1 113 / 3,0 M** | ✘ |
| cati (çatıdan) | 376 / 0,82 M | 607 / 1,55 M | ✔ (yer sınırıyla) |
| sur_dibi30 (30 m) | 109 / 0,27 M | 647 / 1,35 M | ✔ |
| sur_dibi_yer (yer) | 474 / 0,56 M | **1 123** / 2,31 M | ✘ çizim |

Çizim dağılımı (sondanın kaba sayımı, kameranın önünde ve görünürlük aralığında yüzey): aşan yer karelerinde en büyük kalem
`IstDunya/IstOrdugah` (sur_dibi_yer 448, sokak 529 (önceki koşu), tepe 405), `IstGemiler` 59–122; IstSehir ev katmanları
116–220; benim katmanım (IstMahalleDoku: zemin + avlu duvarı + ağaç + öğe hücreleri) 40–170. Ordugâh ve gemiler ŞEHİR-2'nin
bağladığı parçalar (ORTAK İSTEK 5). Benim katmanımda: zemin 384 m hücre başına 2 yüzey (22 hücre), avlu duvarı/ağaç/tarh
192 m hücre başına tek ağ, öğeler 64 m hücre başına tek pişmiş ağ (orta katman tek yüzey).

Kurulum süresi (açılışta bir kez): IstSokak.build 4,4 sn (sokak ağı 1,4 sn), IstMahalleDoku 3,7 sn (zemin 2,5 sn, avlu
0,6 sn, öğe 0,55 sn). Akış: öğe hücreleri kare başına ≤ 4 ms (en az bir iş); avlu çarpışması 150 m çevrede.

## 7. Birleştirme ve DÜNYA-2 sayımı

- `wip/ist2-dunya2` (S = 0,35, yeni `mahalle` + `alt`, kare40, gezi bos=1), `wip/ist2-sehir2` (k değerleri, sur k = 1,0,
  ordugâh/gemiler/hayat), `wip/istanbul-gorunus` üç kez çekildi, çakışma yok.
- Öğelerin uzak katmanı (380 m ötesi; 384 m hücre başına tek ağ: duvar/çit, ağıl çiti, kuyu, tezgâh, şapel/manastır kütlesi)
  eklendi: havadan da "boş alan yok".
- DÜNYA-2'nin geometri sayımı (`gezi.tscn liste=tests/_ist/gezi_sahip.txt bos=1`; zeminden ≥ 0,3 m yükselen geometri, o
  anda kurulu olan): **şehir içi 1 109 karede 19 boş (%1,7)** (DÜNYA-2'nin ilk ölçümünde %5,5); Galata %0; sur dışı 600 m %0,4;
  karşı kıyılar %0,2. Kalan 19 kare üç kümede ve HEPSİ anıt tabanlarının içinde (DOKU-2 oraya ev/öğe koymaz): Langa limanı
  (gerçek e −2 685…−2 457, n −628…−514), Hipodrom–Augustaion–Büyük Saray güneyi (e −343…0, n −343…0), Haliç Latin
  limanları (e −1 000…−460, n 690…910) + Romanos oyun alanı (−4 628, 742; kasıtlı boş). Parçaların uzak katmanı orada
  0,3 m'nin altında (havuz/arena/rıhtım) → ORTAK İSTEK 7. Sahip karelerinin RINFO'su (aynı koşu): tam tepe 1 083 / 1,77 M,
  Galata 755 / 2,13 M, sur dışı 30 m 992 / 2,66 M, Romanos iç yanı 824 / 2,63 M, Mese 723 / 1,55 M, Ayasofya meydanı 707 /
  1,28 M, Hipodrom 399 / 0,78 M, Haliç iskelesi 799 / 1,93 M, sur dibi mahallesi 1 034 / 1,91 M, bostan adası 446 / 1,58 M,
  Marmara'dan 1 507 / 2,76 M, Sarayburnu açığı 1 134 / 2,27 M.

## 8. ORTAK İSTEK

**ŞEHİR-2 (`sehir.gd`):**
1. Anıt tabanları: `sokak.build(foot, …)`'a giden `foot` sınır çemberi (r + 4). Bozdoğan (r 158 m) ve zincir (r 129 m) koca
   mahalleleri boşaltıyordu. DOKU-2 şimdilik `IstSehir.active.items`'tan (salt okunur) döndürülmüş dikdörtgen kuruyor
   (`IstSokak._taban_kayitlardan`: gerçek ölçü × k + 6 m; Bozdoğan hat boyunca 16 m şerit; zincir atlanır). İstek: kayıt
   alanları (`id`, `pos`, `yaw`, `k`, `r`, `data.gercek_olcu`, `hat`) adlarıyla kalsın; ya da `foot`'u şu biçimde verin:
   ```gdscript
   foot.append({"c": Vector2(p.x, p.z), "yaw": float(it["yaw"]), "boy": Vector2(go.x, go.z) * k + Vector2(12, 12)})
   ```
2. Doku katmanını açıkça bağlamak isterseniz `sokak.build(...)`'dan sonra `IstMahalleDoku.attach(self, sokak, gece)`
   (şu an `IstSokak.build` sonunda kendiliğinden bağlanıyor; ikinci çağrı etkisiz).
3. Ev kaidesi rengi `_mesh_for("kaide")` `Color("d8ccb8")` yeni paletle açık kalıyor: `IstEvler.P_TAS[0]` önerilir; sokak
   basamağı `Color("b8ae9c")` → `IstEvler.P_TAS[1]`.
4. Uzak doku katmanında kilise rengi `Color("c88a6a")` ve mahalle kiliselerinin parlak kırmızı çatıları paletin dışında
   (`#8E4631`–`#A5543A` / kurşun gri `#6E7276` önerilir).
5. Bütçe: yer karelerinde toplam çizim 1 087–1 103 (sınır 900); en büyük kalem `IstOrdugah` (400–530 yüzey) ve `IstGemiler`
   (60–120). Ordugâh için 400 m'den sonra uzak tek ağ ya da `visibility_range_end`.
6. Gece pencere ışığı `dm.y > IstEvler.GF + 0.5` koşuluyla; kulübe (2,2 m) ve 1 katlılar (3,4 m) zaten dışarıda — uygun.
7. ISTBOS (DÜNYA-2 geometri sayımı) şehir içinde kalan 19 kare anıt tabanlarının içinde: Langa limanı, Hipodrom arenası /
   Augustaion / Büyük Saray terasları, Haliç Latin limanları. Bu yapıların lod 2'si (uzak) ve açık alanları zeminden
   0,3 m'nin altında. Öneri: açık alanlara (arena, havuz kenarı, saray terasları) uzak katmanda da görünen bostan/ot/harabe
   kütleleri ya da DOKU-2'ye "açık alan" dikdörtgenleri (`sokak.acik_alan.append(Rect2)`; DOKU-2 içini IstBitki yamaları ve
   öğelerle doldurur).

**DÜNYA-2:** yok (yeni `mahalle` türleri ve `alt` kullanıldı: `sarnic` → bostan, `saray`/`hipodrom` → harabe, `sik` < 0,75
→ orta yoğunluk).

## 9. BAKILMADI / KANITSIZ

- Gerçek oyuncu ile dama çıkış 1/5 (§5); çatıdan çatıya geçiş ve avludan çıkış oyuncuyla BAKILMADI (kurallar ve sayımla).
- Sıranın ilk basamağı ile sokak arasındaki yükseklik farkı (yamaçta > 0,42 m olabilir): ölçülmedi.
- Zeminin hareketli kamerada titremesi (z-çakışması): durağan karelerde yok; hareketli gözlem BAKILMADI.
- Gece karesi: BAKILMADI (gece ışıklarını ŞEHİR kuruyor; ev yerleri değişti, koşul aynı).
- Eski dünya (World1453) ile bölüm testleri: IstEvler'in eski örnekleri (v < 7) aynı ölçüde kaldı; eski dünyada IstSehir
  kapalı. Başsız bölüm koşusu bu turda YAPILMADI (yalnız `parse_check` PASS, 322 betik).
- Han ve patrikhane yapıları az (sığdıkları yerde); iskele önleri ayrıntısı Haliç liman parçasına bağlı.

## Kareler (ÖNCE | SONRA, `docs/_kanit_ist2_doku2/`)

`tur1_hava70`, `tur1_hava30`, `tur1_tepe`, `tur1_tepe_mahalle`, `tur1_tepe_batı`, `tur1_sokak`, `tur1_sokak_bati`, `tur1_cati`,
`tur1_sur_dibi30`, `tur1_sur_dibi_yer` (`_once_sonra.jpg`). Kendi bakışım:
- hava70/hava30: ÖNCE serpiştirilmiş pembe evler ve çayır; SONRA bitişik sıralar, taş döşeli Mese, toprak sokaklar, avlu
  duvarları, erguvan/servi; uzak evler yakınlarla aynı tonda.
- tepe_mahalle/tepe_batı: sokak ağı ve adalar okunuyor; batı yarı (ÖNCE neredeyse boş) dolu.
- sokak/sokak_bati: yerden toprak sokak, taş-tuğla şeritli cepheler, dükkân tenteleri; uzakta sıra evler.
- cati: çatıdan bakışta kiremit tonları, düz damlar, bacalar; komşu çatılar bitişik.
- sur_dibi30 / sur_dibi_yer: kara surunun iç yüzüne kadar mahalle; 12 m'lik iç sur ile sıra evler arasında savunma yolu.
- Kusur gözlemi: dükkânlı evlerin ön tezgâhları sokak taşının üstünde; birkaç bahçe ağacı avlu duvarına yakın (geçit
  ≥ 1,4 m kuralı ağaç gövdesi için 2 m'lik hücre payıyla); kulübe sayısı (1 698) dar bloklarda yüksek.
