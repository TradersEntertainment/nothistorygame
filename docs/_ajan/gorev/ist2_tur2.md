# İstanbul v2 — İKİNCİ TUR görevleri (üç Opus oturumu)

Hepsi önce şunları okur ve uyar: `docs/_ajan/gorev/_ist2_ortak.md` (özellikle sondaki "İKİNCİ TUR" bölümü),
`docs/_ajan/gorev/ist2_kalite_notlari.md` (yöneticinin kare incelemesi: bağlayıcı), `docs/_ajan/gorev/_ortak2.md`
(kurulum, yasaklar, izin kutusu), `docs/_ajan/gorev/_istanbul_ortak.md` (oynanış kuralları, Nihat'ın yan görevi),
birinci turun raporları: `docs/_kanit_ist2_dunya/rapor.md`, `docs/_kanit_ist2_sehir/rapor.md`.
Şehir BUGÜN bitecek. Karelerine kendin bak; her turda kanıt karelerini yenile; yönetici sahibine gösterecek.

## DÜNYA-2 (dal `wip/ist2-dunya2`; dosyalar: `geo.gd`, `dunya.gd`, `tests/_ist/gezi.*`; kanıt `docs/_kanit_ist2_dunya2/`)
1. İLK 20 DAKİKA: `IstGeo.S = 0,3`; bütün tablolar (kıyı çokgenleri, yollar, yer dizini, arazi ızgarası, `mahalle`)
   gerçek koordinattan S ile türesin (önceden çarpılmış tablo kalmasın). Gönder (öbür iki oturum bekliyor).
2. `mahalle(x,z)`: kalite notu 0b: yoğunluk yeniden dağıtılır; surların iç yüzüne kadar yerleşik doku; bostan/bağ/
   harabe/manastır adaları dokunun içinde (≤ ~120 × 120 m); açık sarnıç bostanları, Hipodrom, Büyük Saray harabesi
   ayrı tür. Galata da surlarına kadar dolu. Sur dışı kuşak "ordugah"/"kir" türleriyle; karşı kıyılar "koy"/"bag"/
   "orman" türleriyle (boş değil).
3. Kusurlar: tam tepeden batıdaki dikdörtgen koyu mavi alan (Lykos vadisi; arazi parçası kurulmamış ya da çukur
   kesimi) düzelsin; kıyı çizgisi basamaklı görünmesin (kıyıda arazi ağı çokgeni izlesin ya da ızgara sıklaşsın);
   zemin dokusu tek renk yeşil olmasın (toprak, taşlık, çiçekli çayır, sürülmüş tarla lekeleri; `mahalle` türüne göre).
4. Karşı kıyılar ve ufuk dolu: Galata'nın arkası bağ/bahçe, Üsküdar ve Kadıköy köyleri, Eyüp, Boğaz köyleri, ormanlık
   tepeler, tarlalar (ucuz: uzak katman tek ağ + MultiMesh ağaç/ev); Kız Kulesi adacığı (1453 biçimi: küçük kale).
5. `ISTBOS` sayımı için yardımcı: `IstGeo.kare40(x,z)` kimliği + gezi sahnesinde `bos=1` kipi (40 m'lik karelerde
   hiçbir öğe/ev/ağaç/yapı yoksa "boş"): şehir içi %0, sur dışı 600 m kuşak ≤ %5, karşı kıyıların görünen yamaçları
   ≤ %15 olana dek öbür oturumlara rapor ver (tablo: bölge → boş kare sayısı, örnek koordinatlar).
6. Gezi sahnesi: sabit "sahip kareleri" listesi (her turda aynı 14 bakış: tam tepe; Galata üstünden yarımada; kara
   surlarının dışından 30 m ve 70 m; Romanos'un iç yanından Ayasofya yönüne yerden; Mese'de yürüyüş; Ayasofya
   meydanı; Hipodrom; bir Haliç iskelesi; bir sur dibi mahallesi; bir bostan adası; Marmara'dan; Sarayburnu açığından;
   gece Galata'dan) → `docs/_kanit_ist2_dunya2/sahip_<n>_<ad>.jpg`. Güneş açısı ve pus: şehir canlı, sıcak, okunur.
7. Sonra: uçuş bölümlerini (7, 11) v2'ye bağlama DÖKÜMÜ (birinci tur görevindeki tanım); uygulama ayrı pakette.

## ŞEHİR-2 — yerleşim (dal `wip/ist2-sehir2`; dosyalar: `sehir.gd` + yeni yardımcılar, `tests/_ist/sehir2_kare.*`;
## kanıt `docs/_kanit_ist2_sehir2/`)
1. S = 0,3'e uyum: `YER2` yerleşimi, çakışma çözümü (öncelik ve komşuluk sırası; geniş alanlılar k = 0,3–0,4), hiçbir
   eser atılmaz; yan görev eserlerinin her biri tanınır ve çevresi dolu.
2. Surların kesiti 1:1 (k = 1,0), uzunluk hat boyunca; kapılar yerlerinde; sur üstü yürüme yolu kesintisiz (kapı
   üstü dâhil: kapı yapısının üstünden geçiş ya da iki yanda merdiven); gerçek CharacterBody ile baştan sona yürüyüş
   sınaması. Sur dışından 30 m ve 70 m'den bakışta üçlü hat ve kuleler ufku kesmeli.
3. Yeni parçaları bağla: `IstOrdugah.attach`, `IstGemiler.attach`, `IstHayat.attach` (dalları çek; yoksa atla, sonraki
   turda yine dene). Ordugâh sur dışını doldursun (çadır denizi otağdan Marmara'ya ve Haliç'e), gemiler suyu.
4. Ufuk ve anıt okunurluğu (kalite notu 3): Galata'dan bakışta Ayasofya, Hipodrom dikilitaşları, sütunlar, Bozdoğan,
   Havariyun, Pantokrator kubbeleri seçilsin (kurşun kubbe rengi, uzak katman biçimi/rengi, ev çatılarının üstünde).
5. Zaman dilimi (kalite notu 8): tek iş ≤ 6 ms hedefi; ağır parçaların lod 1/2'si başlangıçta arka planda/ön-pişirme,
   lod 0 alt parçalara bölünerek; `ISTYAVAS` tablosu ÖNCE | SONRA.
6. Denetimler (kalite notu 9): zeminde delik/kapalı cep ışın ızgarası v2'de beş mahallede; çatıdan çatıya geçiş ve
   çatı yolu gerçek oyuncuyla beş yerde; eser başına 15 m ve tam tepe kare paftası yenilenir.
7. `flight_data_v2`: işaretler eserlerin tam üstünde (kareyle tek tek), `forms` noktaları anlamlı yerlerde.
8. Oyun alanları (hub: Romanos'un iç yanı; Ayasofya meydanı) boş bırakılmaya devam; S = 0,3'teki yerlerini raporla.

## DOKU-2 — mahalle dokusu (dal `wip/ist2-doku2`; dosyalar: `sokak.gd`, `evler.gd` + yeni yardımcılar;
## kanıt `docs/_kanit_ist2_doku2/`)
1. Kalite notu 0, 0b, 2, 6, 7: şehir sura kadar dolu; havadan sokak/ada okunur; SOKAK ZEMİNİ görünür (Mese ve
   forumlar taş döşeme, ana yollar kaldırım taşı, ara sokaklar sıkışmış toprak, yokuşta basamak; zeminle z-çakışması
   yok, araziye oturur); adalar: bitişik sıra evler + avlu duvarı + iç bahçe/ağaç/kuyu; sur dibinde surun iç yüzüne
   yaslı sıralar (arada 4–6 m savunma yolu); köşe kuralı incelsin (sıralar kısa ve aralıklı kalmasın).
2. Ev çeşitliliği (mektup bölümünün ev dili korunarak; `docs/ISTANBUL_GORUNUS.md` gelince paleti ondan al): çoğu 1–2
   katlı (4–6,5 m); 3 katlı yalnız çarşıda ve Latin mahallelerinde; duvar: taş-tuğla şeritli / kireç badana / açık
   sıva tonları / ahşap çıkma; çatı: Bizans kiremidi tonları (kırmızı-kahve, soluk), yer yer düz dam ve teras,
   sundurma, baca; yoksul kulübe, dükkânlı ev, avlulu konak, han, fırın, demirci, ambar tipleri; harap/terk edilmiş
   ev (1453). Uzak/orta/yakın katman renkleri AYNI (uzakta beyaza dönmesin).
3. Boş alan yok: ev olmayan her 40 m'lik karede `IstBitki` yamaları (çiçekte meyve bahçesi, bağ, bostan, buğday,
   çayır + kır çiçeği), bahçe duvarı/çit/patika, harabe ve şapel (`IstKiliseler` tipleri), mezarlık, kuyu, ağıl ve
   sürü, tek çiftlik evi, `IstAyrinti` köşe grupları (pazar köşesi, fırın önü, demirci, balıkçı iskelesi, sur onarım
   şantiyesi, mülteci çadırları). `ISTBOS` sayımı şehir içinde 0.
4. Meydanlar ve çarşılar: Ayasofya çevresi (Augustaion döşemesi, patrikhane ek yapıları, mumcular), forum meydanları,
   iskele önleri, kapı önleri; her birinde ayrıntı grupları.
5. Oynanış: her ev kapalı katı; bitişik aralık 0 ya da ≥ 1,4 m (dar aralık 0 hedef; şu an 27); her adada sokaktan
   çatıya yol; çatıdan çatıya geçiş; avlu çukur değil (çıkışı var); yamaçta taban oturur.
6. Bütçe: hedef ~6–9 bin ev (S = 0,3 alanında dolu görünüm); uçuşta toplam ≤ 1 500 çizim / 3,5 M üçgen, yerde ≤ 900 /
   2,5 M (ölç, tablo).
