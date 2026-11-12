# İstanbul, Nisan 1453: şehir kurucusu, ana plan ve ilk örnek mahalle — GELİŞTİRİCİ (Opus)

Önce `docs/_ajan/gorev/_ortak2.md`, `docs/_ajan/gorev/_tek_harita_ortak.md`, `docs/_ajan/tek_harita.md` (mimari) ve
`docs/_ajan/rapor/hava.md` dosyalarını oku ve uy. Dalın: `wip/istanbul`. Kanıt: `docs/_kanit_istanbul/`.
Bu görevde yeni dosya ve gerekiyorsa yeni `class_name` açmak SERBEST (raporda listele).

## Sahibin sözleri (12 Kasım, aynen)
1. "ben şunu anlamıyorum hani kraldan mektup falan alırken oynadığımız istanbul neden nihatla istanbulun üstünden
   uçtuğumuz istanbula benzemiyor tolgayla oynadığımız istanbul nerde?"
2. "kanka bence sen önce 1453 nisanda istanbul nasılmış ona çalış sonra bence bölümleri içine sığdırırız, peter çok
   detaylı istanbul yapmış ya günümüz o promtpları örnek al bunu 1453 nisan yap ve şekiller vs bizim oyna uysun tolganın
   tırmanabileceği içinden düşmeyeceğimiz şekilde falan olsun bizim şu anki tolganın mektup bölümündeki evleri
   kullanabilirsin şekil olarak galiba"
Motto: "tüm İstanbul tek harita, tüm görevler aynı harita; her şey tam içerik ve kaliteyle haritada oynanacak;
performans için yaratıcı çözümler: uzakken yüklenmez."

## Ne demek
Yön değişti: önce ŞEHİR kurulur (Nisan 1453 Konstantinopolis'i, araştırmaya dayalı, oyunun çizgi film üslubunda),
bölümler sonra bu şehrin içine yerleştirilir. Şehrin yapı dili Tolga'nın mektup bölümündeki (Bölüm 12b; hub:
`scripts/level/byz_city.gd` `_house`, `_build_street`, `_build_chancery`, `_build_palace`, `_build_fill`) evlerdir:
taş zemin kat, tuğla şeritler, sıvalı üst kat, ahşap çıkma, kepenk, tente, bayrak ipi. Dünyanın bugünkü Kit evleri
(`CityHouses`) ve tarlaya serpilmiş kutular bu dile çevrilir; iki ayrı şehir görünüşü kalmaz. Ayrıntı yoğunluğu için
örnek: `docs/_ajan/istanbul_prompt.txt` (günümüz İstanbul'u; 1453'te olmayan her şeyi ayıkla: minare, köprü, vapur…).
Tarih araştırmasını başka bir oturum yazıyor: `git fetch origin wip/istanbul-arastirma:refs/remotes/origin/wip/istanbul-arastirma`
ile ara ara al (`docs/ISTANBUL_1453.md`, `docs/ISTANBUL_YERLER.csv`); henüz yoksa kendi bilginle başla, gelince uyarla.

## Teslimler (sırayla; her biri bitince kaydet ve gönder, sonrakine geç)

### 1. `docs/ISTANBUL_PLAN.md` — ana plan (ilk 60–90 dakikada gönder)
- **Ölçek kararı:** World1453 bugün sıkıştırılmış bir harita (`REGIONS`). Gerçek şehir ~5,5 × 6 km. Oyunun ölçeğini
  seç ve gerekçelendir (oyuncu yürüyüş hızı, uçuş hızı, bölümler arası yol süresi, performans); var olan bölgelerin
  yerlerini mümkün olduğunca koru. Gerçek koordinattan (Ayasofya 0,0; doğu/kuzey metre) dünya koordinatına dönüşüm
  işlevi tanımla; yer dizini (CSV) bu işlevle haritaya düşsün.
- **Mahalle çizelgesi:** her mahalle için dünya dikdörtgeni/çokgeni, karakter (sık çarşı, seyrek köy, bostan, harabe,
  manastır çevresi, liman, yabancı tüccar mahallesi, sur dibi), yoğunluk, ana sokak, anıtlar, ayrıntı dizini.
- **Bölüm yerleşim tablosu:** 1453'te geçen HER bölüm (`tests/run_tests.sh` listesi) → şehirdeki yeri; bugün hangi
  kurucuda; sığdırmak için ne gerekli; çakışan bölümler (aynı yer, farklı zaman/hava).
- **Yapı dili (kit):** mektup bölümünün evlerinden türetilmiş parametreli tipler: sıra ev, avlulu ev, dükkânlı ev,
  meyhane, atölye, ambar, kule ev, harabe, küçük/orta kilise, manastır, çeşme, kuyu, bostan duvarı, bağ, mezarlık,
  sarnıç bostanı, pazar tezgâhı… Her tip için ölçü aralığı ve üç ayrıntı katmanı.
- **Oynanış kuralları (şart):** her yapı KAPALI katı cisim (duvar + çatı çarpışması); oyuncu hiçbir yerde içine
  düşemez, sıkışamaz: iki katı arasında 0,9 m'den dar ve girilebilir aralık olmaz (ya ≥ 1,4 m sokak ya kapalı);
  zemin kesintisiz (delik yok); çatılar yürünür; tırmanma tutarlı: `scripts/player/player.gd` içindeki zıplama
  (`JUMP`), basamak (`STEP_H`) ve varsa tırmanma değerlerinden oyuncunun çıkabileceği yüksekliği HESAPLA ve kit
  parçalarını (sandık, alçak sundurma, merdiven, saçak) buna göre boyutlandır: her mahallede sokaktan çatıya en az
  bir doğal yol; çatıdan çatıya atlanabilir aralıklar; çıkılamayacak yer inandırıcı biçimde çıkılamaz (yarım tutunma
  yok). Uçuş (Nihat) için konma noktaları.
- **Akış / performans mimarisi ("uzakken yüklenmez"):** parça ızgarası (ör. 96 m), üç katman (yakın: tam ayrıntı +
  çarpışma; orta: pişmiş tek ağ + sade çarpışma; uzak: siluet), mesafeyle kurma/boşaltma (zaman dilimli, kare başına
  ≤ 8 ms; takılma yok), parça başına sabit tohum (her seferinde aynı şehir), bellek ve çizim bütçesi (yerde çizim
  ≤ 900, üçgen ≤ 2,5 M; uçuşta bugünkü değeri aşma), yükleme süresi ≤ +1,5 sn. Var olan altyapıyı kullan:
  `World1453.bake`, `FAR_REGIONS`, `CityPlan` sokak grafiği, `WorldWalk` zaman dilimli kurulum.
- **Kalan işin paketlere bölünmesi:** birbirinden bağımsız 10–15 paket (mahalle ya da tema), her biri için dosyalar,
  kabul ölçütü, tahmini iş. Bu paketler ayrı makinelere dağıtılacak; dosya çakışması olmayacak biçimde böl.

### 2. Şehir denetimi: `tests/city_audit.tscn` (+ betiği)
Bir dünya dikdörtgeni için otomatik sınar ve satır basar (`CITYAUDIT …`): zeminde delik (ışın ızgarası, 0,5 m),
girilebilir dar aralık (< 0,9 m), kapalı cep (oyuncunun girip çıkamayacağı), havada duran yapı (taban–zemin > 5 cm),
zemine gömülü kapı, iç içe yapı, sokağı kapatan yapı, görünür ağ var ama çarpışma yok, çarpışma var ama görünür ağ
yok, sokaktan çatıya yol sayısı. Bugünkü hub ve bugünkü dünya şehri üzerinde çalıştır: çıkan sayılar "ÖNCE"dir.

### 3. İlk örnek mahalle, gerçekten kurulmuş (asıl kanıt)
Mektup bölümünün çevresi: hub (cadde, kançılarya, saray avlusu, Romanos Kapısı yönü) ve dört yanında en az 300 × 300
m'lik şehir dokusu, yeni yapı diliyle, akış mimarisiyle, dünyadaki gerçek yerinde. Aynı parça hem Tolga'nın yer
bölümlerinden (6b, 7b, 10h, 12b, 23, 24: oynanış, replik, bot yolu, etkileşim DEĞİŞMEDEN) hem Nihat'ın uçuşundan
(11 gece, 7 gündüz) görünür ve AYNIDIR. Hub artık "tarlaya yapıştırılmış yama" gibi durmaz: sokaklar `CityPlan`'a
bağlı, çevre dolu, tek ev üslubu, kiremit/çatı havadan da aynı aileden.
Kanıt:
- Yerden: cadde boyunca yürüyüş kareleri; hub'ın dört ucundan dışarı bakış (kesintisiz şehir).
- Çatı: Tolga'nın sokaktan çatıya çıktığı beş ayrı yol (oyuncuyla, sondayla; kare dizisi) ve çatıdan çatıya geçiş.
- Düşmezlik: `city_audit` sonuçları (delik 0, dar aralık 0, kapalı cep 0) + botun bütün sokaklarda yürüyüşü.
- Havadan: 60 m, 15 m ve tam tepeden; ÖNCE | SONRA; yerdeki mektup anı ile aynı yerin havadan karesi yan yana.
- Uzaklık geçişi: 40–300 m arası 10 kare (birden belirme, ölü bant, çifte çizim yok).
- Performans: 6b, 12b, 23, 24, 11, 7 ÖNCE | SONRA çizim, üçgen, yükleme süresi; parça kurma süresi (ms).
- Testler: 6 (+`byz`), 7 (hepsi), 10h, 12b (hepsi), 23, 24, 25, 11 (hepsi), 8, 9, 20 + `flight_check`, `world_check`,
  `city_check`, `parse_check`.

### 4. Rapor (`docs/_kanit_istanbul/rapor.md`)
Ne kuruldu, ne kalmadı, ölçümler, bilinen kusurlar, paket listesi (plan belgesindeki), ortak dosyalara eklenen her
satır (dosya:satır). Bakamadığını BAKILMADI yaz.

## GÜNCELLEME: şehir BUGÜN bitecek, on iki oturum parça kuruyor (sahibin sözü: "gerekirse çalışan sayısını arttır
## ama bu istanbulu bugün bitir")
Sen ŞEHİR MİMARI ve BİRLEŞTİRİCİSİN. Anıtları ve özel yapıları sen kurma: on iki ayrı oturum şu an paralel olarak
parça (modül) yazıyor. Arayüz dondurulmuş: `docs/_ajan/gorev/_istanbul_ortak.md` (OKU); parça listesi:
`docs/_ajan/gorev/istanbul_parcalar.md`. Dallar: `wip/ist-surlar`, `wip/ist-marmara`, `wip/ist-halic`, `wip/ist-galata`,
`wip/ist-hipodrom`, `wip/ist-forumlar`, `wip/ist-kemer`, `wip/ist-kuzeybati`, `wip/ist-guneybati`, `wip/ist-kiliseler`,
`wip/ist-ayrinti`, `wip/ist-bitki`. Her biri yalnız YENİ dosya yazar (`scripts/world/ist/<ad>*.gd`), yaklaşık 60. dakikada
ilk kaba hâlini gönderir, sonra derinleştirir. Sen:
1. Zamanı şöyle kullan: ilk 60 dakika ana planın ÇEKİRDEĞİ (ölçek ve koordinat dönüşümü, mahalle çizelgesi, bölüm
   yerleşim tablosu: kısa ve kesin; uzun düzyazı yok) + ev kiti (mektup bölümünün evlerinden, tırmanma/düşmezlik
   kurallarıyla; `scripts/world/ist/evler.gd`, aynı arayüz kalıbında: `build_<tip>(host, k, lod)` + tohumlu çeşitleme)
   + parça ızgarası/akış iskeleti (`scripts/world/ist/sehir.gd`: `catalog()` kayıtlarını ölçek dönüşümüyle dünyaya
   yerleştirir, mesafeye göre lod 2 → 1 → 0 kurar/boşaltır, zaman dilimli).
2. Sonra her 30–45 dakikada bir parça dallarını çek (`git fetch origin wip/ist-<ad>:refs/remotes/origin/wip/ist-<ad>`;
   yoksa atla), `git merge` et (yalnız yeni dosyalar, çakışma olmaz), `catalog()` kayıtlarını şehre yerleştir.
   Yerleşim çakışmalarını (iki yapı üst üste, sokağın ortasında yapı, suya düşen yapı, havada/gömülü taban) sen çöz
   (konum/yön düzeltmesi yerleştirme tablosunda; modül dosyasına dokunma, kusurunu raporda modül adıyla yaz).
3. Mahalle dokusu: anıtların arasını ev kiti + `ayrinti` + `bitki` parçalarıyla, mahalle karakterine göre doldur (sık
   çarşı / seyrek köy / bostan / harabe / liman). Nisan 1453: şehrin büyük kısmı seyrek, tarla-bağ-harabe; Mese
   boyunca, Haliç kıyısında ve Ayasofya çevresinde sık.
4. Var olan dünya katmanlarını (CityPlan, CityHouses, Landmarks1453'ün kaba anıtları, HornWorld'ün şehir yarısı)
   yeni şehirle DEĞİŞTİR: aynı yerde iki şehir çizilmesin. Eski kaba anıt, yenisi yerleşince kaldırılır (çifte yapı
   yok). Bölümlerin kendi oynanış alanları (hub, Ayasofya meydanı, Blakherna, Petrion, Galata rıhtımı, sur dibi)
   `keep`/`FAR_REGIONS` düzeniyle aynen korunur ve yeni şehre gömülür.
5. Bugünün kabul ölçütü: Nihat'ın uçuşunda (Bölüm 11 gece, 7 gündüz) surdan Sarayburnu'na, Haliç'ten Marmara'ya ve
   Galata'ya kadar bütün şehir yeni hâliyle, boşluksuz, tanınır anıtlarla; Tolga'nın şehir bölümlerinde (6b, 7b, 10h,
   12b, 23, 24, 25) oynanış aynen çalışırken çevrede aynı şehir; `city_audit` delik/dar aralık/kapalı cep = 0;
   bütçe içinde. Bölümlerin kalanının şehre taşınması sonraki iş (plan belgesinde listele).
6. Her birleştirme turundan sonra testleri koş (aşağıdaki liste) ve `wip/istanbul` dalına gönder; yönetici ara
   durumu sahibine gösterecek. Havadan dört yönden ve tam tepeden kareleri her turda yenile
   (`docs/_kanit_istanbul/tur_<n>_*.jpg`).

7. **Nihat'ın yan görevi** (sahibin sözü: "tüm tarihi eserlere özen nihat hepsinini üstüne uçuo bakma yan görevi vr
   çünkü"): `World1453` içindeki `landmarks` / `forms` / `perches` listeleri ve `LANDMARKS` konumları yeni
   modellerle AYNI yere otursun (işaret eserin tam üstünde, konma noktası gerçek çarpışmalı yüzeyde). Var olan dokuz
   eserin kimlikleri ve sırası değişmesin (kayıtlı oyunlar); parçaların `catalog()` kayıtlarında `"gorev": true`
   olan yeni eserleri listeye EKLE (kimlik büyük harf, görünen ad için `i18n/strings.csv`'ye tr/en satırı ekle;
   var olan satırlara dokunma). Her eserin 15 m üstünden ve tam tepeden karesini kanıta koy; kutu gibi, üstü açık,
   arka cephesi boş eser kalmasın (kusuru parça adıyla raporla).

## Sınırlar
- Bölüm betiklerinde oynanışa (replik, süre, sayaç, sonuç, bot yolu, kalabalık sayısı) dokunma.
- Başka bir oturum `wip/tekharita` dalında ordugâh, otağ, kıyı surları ve tünel göçlerini birleştiriyor:
  `scripts/world/world1453.gd`, `horn_world.gd` içinde var olan satırları yeniden sıralama/biçimlendirme yapma; yalnız
  ekle. Şehir kurucusunu yeni dosyalara yaz (ör. `scripts/world/city_kit.gd`, `city_chunks.gd`).
- Her 60–90 dakikada bir ara kayıt gönder (plan → denetim → mahalle); yönetici ara durumu okuyup sahibine gösterecek.
