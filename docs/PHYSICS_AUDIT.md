# Fizik denetimi (v0.40.3)

Oyunda görünen dünya ile oyuncunun gerçekten yapabildikleri aynı olmalı:

- Üstünde durulabilen her yer görünür olmalı.
- Görünen her katı nesnenin içinden geçilmemeli.
- Hiçbir yerden dünyanın dışına düşülmemeli.
- Karakterler havada durmamalı, yere ya da nesnelere gömülmemeli.

`tests/phys_audit.gd` bunu her bölümde denetler.

## Nasıl çalışır

    xvfb-run -a godot --path . --resolution 320x180 -s tests/phys_audit.gd -- ÇIKTI_KLASÖRÜ res://scenes/chapterN.tscn VARYANT [EVRE]

Sanal ekran gereklidir. Başsız (`--headless`) modda MultiMesh örneklerinin konumu saklanmaz, hepsi (0,0,0) okunur.
3B çizim kapatılır, bu yüzden kareler ucuzdur.

Bölüm, otomatik testte kendi kendine oynar. Her yeni hedefte (evre) oyun dondurulur ve şu adımlar yapılır:

1. **Taşkın doldurma.** Oyuncunun yerinden 1 m ızgarada ilerlenir.
   - Her adımda oyuncunun kendi kapsülü (r 0,3 m, boy 1,75 m) basamak yüksekliğinde süpürülür.
   - Zemini olmayan komşu hücre, ancak kapsül oraya geçebiliyorsa boşluk (VOID) sayılır. Duvarın ardındaki boşluğa
     düşülmez.
   - Zıplayarak 0,62 m çıkılabilir. Eğimli zeminde (rampa, yamaç) 1 m'de 1,2 m'ye kadar çıkılır; yüzeyin eğimi
     en çok 53° olabilir ve adımın ortasındaki zemin iki ucun arasında olmalıdır (yüksek kutu basamak sayılmaz).
   - Sonuç, oyuncunun o evrede gidebileceği her yerin haritasıdır.
   - Oyuncu yürümüyorsa (kürek çekiyor, sedye taşıyor, oturtulmuş, yüzüyor) erişim ve hedef denetimi yapılmaz.
     Tespit (fotoğraf) hedeflerinde de hedefin yanına gitmek aranmaz.
2. **Görünen dünya.** Sahnedeki görünür, katı görünümlü bütün ağlar üçgenleriyle ayrı bir fizik uzayına kopyalanır.
   - Buna MultiMesh örnekleri de dahildir.
   - Saydam, eklemeli ve uzak katman (LOD) ağları alınmaz.
3. Yürünen her adım ve durulan her hücre bu iki dünyada karşılaştırılır.
4. **Karakterler.** Saniyede bir, ara sahneler ve düellolar da dahil, görünen kameranın 80 m yakınındaki bütün karakterler
   denetlenir. Kameranın kendisi de denetlenir.
5. **Çoğaltılmış nesneler.** Erişilen alanın 40 m çevresindeki her örneğin (çadır, sandık, kaya, asker kopyası) altına
   bakılır. Görünen dünya bu örneklerin çevresinde (8 m'lik kareler) yeniden kurulur. Alt ucu zeminin altında olan
   (çakılı kazık, yarı gömülü taş) havada sayılmaz; ok, mızrak gibi ince uzun nesnelere bakılmaz.
6. **Yürüyen bot.** Oyuncunun gerçek gövdesi (aynı kapsül, `CharacterBody3D.move_and_slide`, en çok 45° eğim, 10 cm
   yere yapışma) taşkının bulduğu yerlerde denenir:
   - **Durma:** ayak izi tümüyle zeminde olan hücrelere bırakılır ve 0,4 s kendi haline bırakılır. Kayıyor, düşüyor ya
     da itiliyorsa orada durulamaz. Eğimli zeminler önce denenir.
   - **Yürüme:** taşkının geçtiği adımlar (önce basamaklı ve eğimli olanlar) yürünür; gerekirse zıplanır. Yolda iki
     zeminin de 1 m altına düşülüyorsa zeminden geçiliyordur. Düz ya da alçak adımda varılamıyorsa gövde takılıyordur.
     Bot oyuncunun basamak çıkışını (`Player.step_up`) da kullanır; alçak bir adıma yalnız zıplayarak çıkılıyorsa
     JUMPNEED yazılır.
   - Bütün denemeler tek bir fizik karesinin içinde yapılır. Başka hiçbir şey kıpırdamaz; oyuncunun yeri ve hızı
     sonunda geri konur, bölge tetikleri ve bölüm betiği bir şey görmez. Evre başına yaklaşık 1500 deneme, yarım saniye.

7. **Etkileşim alanları (E).** Açık her etkileşim alanına, gidilebilen bir yerden E ışınının boyu (2,4 m) içinde
   uzanılabiliyor mu. Otomatik test etkileşimi doğrudan çağırır; eşyalar katı yapılınca önü kapanan alanı görmez.
8. **Uçuş (Nihat, Bölüm 3, 7, 11).** Uçuş menzilindeki (saha kapısından 150 m, yerden 70 m) iri, katı görünümlü basit
   ağların (kutu, silindir, küre, prizma; en az 0,8 m, 6 m³) ortası fizikte boş mu: boşsa içinden uçulur.

Bölüm, oyunun açılışındaki gibi önceki bölümlerin varsayılanlarıyla (çanta, bayraklar, kuşatma
tarafı) yüklenir: yoksa bazı bölümlerin otomatik testi ilerleyemez.

Godot, bir ışın üçgenin arkasına çarptığında normali ışına doğru çevirir. "Nesnenin içinde mi" ve "zeminin altında mı"
sınamaları bu yüzden yüzün gerçek normalini üçgenin köşelerinden hesaplar.

## Bulgu türleri

| Tür | Anlamı |
|-----|--------|
| GHOST | Görünen bir nesnenin içinden yürünüyor (çarpışması yok) |
| SINK | Görünen zemin fizik zemininden yüksek: ayak nesneye gömülüyor |
| AIR | Fizik zemini var, görünen zemin yok: havada durulan yer |
| IWALL | Görünmez duvar: fizik engelliyor, orada görünen bir şey yok |
| VOID | Zemin biter: oyuncu dünyanın dışına düşer |
| DROP | 3 m'den büyük düşüş |
| SPAWN / STUCK | Oyuncu bir katının içinde başlıyor / hiçbir yöne adım atamıyor |
| TARGET | Hedef işaretinin 3 m yakınına yürünemiyor |
| FLOAT / VFLOAT | Karakter havada / yalnız görünmez bir zemin üstünde |
| VSUNK / CLIP / INSOLID | Karakterin ayağı nesnede / gövdesi görünen bir ağın içinde / katının içinde |
| OVERLAP | İki kişi iç içe (at ile insan dahil) |
| CROWD | Yürünebilir yerde, içinden geçilen donmuş kalabalık kopyası |
| MMFLOAT | Çoğaltılmış nesne ya da kalabalık havada |
| CAMCLIP | Kamera bir ağın içinde |
| SLIDE | Yürüyen bot: durulamayan yer (gövde kayıyor, düşüyor ya da itiliyor) |
| WALKFALL | Yürüyen bot: yürürken zeminden düşülüyor |
| WALKBLOCK | Yürüyen bot: taşkına göre geçilen düz ya da alçak adımda gövde takılıyor |
| JUMPNEED | Yürüyen bot: 12–45 cm'lik adıma yürüyerek çıkılamıyor, zıplamak gerekiyor |
| NOREACH | Etkileşim alanına gidilebilen hiçbir yerden uzanılamıyor |
| FLYGHOST | Uçuş menzilinde, içinden uçulan (çarpışması olmayan) iri nesne |

## Çıktılar

- Her evre için üstten bir harita PNG'si. Renkler:
  - yeşil: yürünebilir
  - sarı: GHOST
  - mor: SINK
  - camgöbeği: AIR
  - pembe: IWALL
  - kırmızı: VOID
  - turuncu: DROP
  - beyaz: SLIDE, WALKBLOCK
  - koyu kırmızı: WALKFALL
  - mavi kare: oyuncu
- Her tür ve grup (ağ, gövde ya da karakter) için bir `PHYS` satırı. Satırda sayı, en büyük değer, alan, örnek ve
  oyuncuya en yakın uzaklık (`d`) bulunur.
- Sahne başına bir JSON dosyası.

Bir bölüm, bir tetik çizgisiyle bitiyorsa taşkın o çizgide durur. Örneğin Bölüm 4'te `z > 9.5` kaçıştır. Bu çizgiler
betikteki `BOUNDS` tablosunda tutulur.

## İlk taramada bulunanlar ve düzeltilenler

Tarama 60 bölüm ve varyantta yapıldı. Bu bölümdeki bölüm numaraları dosya numaralarıdır (kuşatmada ekrandaki numara
dört eksiktir: dosya 26 = ekranda 22).

**Dünyanın dışına düşme**

- **Fetihten sonra şehir (Bölüm 26).**
  - Sorun: Evlerin arkasına ve son evin yanından dolanılıyordu. Oradan uzak çatıların içinden geçilip zeminin
    kenarından düşülüyordu.
  - Düzeltme: Evlerin arkasına ve caddenin sonuna tam genişlikte sınır kondu.
- **Donanım dükkânı sokağı (Bölüm 8).**
  - Sorun: Sokağın iki ucundan dünyanın dışına yüründü. Karşı apartmanların içinden geçildi.
  - Düzeltme: Apartmanlar katı yapıldı ve sokak sınırlandı.
- **Kara surları (Bölüm 25).**
  - Sorun: Sur yolunun gedik ucundan kırık kenarın görünmez üstüne çıkılıyor, gediğe atlanıyor, peribolosa iniliyordu.
    Oradan sura geri çıkılamıyordu.
  - Düzeltme: Yolun ucuna sınır kondu.
- **Esir kampı (Bölüm 4).**
  - Sorun: Kapıdan çıkıp yana dönünce kaçış çizgisi geçilmeden bütün ordugâh dolaşılıyor, dünyanın kenarına gidiliyordu.
  - Düzeltme: Kapının dışındaki şerit nöbetçilerin yanından ileri yönlendirildi.

**İçinden geçilen nesneler**

- Gündüz ordugâhı (Bölüm 6, 7, 9, 10, 16, 24o, 25):
  - Uzak çadırlar, köşkler ve at sıraları.
  - Kamp eşyaları: saman, sandık, araba, cephane sandığı, kazan.
  - Padişah'ın otağı ve mutfak tezgâhı.
  - Donmuş kalabalık kopyaları.

  `Scenery.scatter(…, solid)` ve `Crowd.place(…, solid)` artık her örneğe çarpışma kutusu koyuyor.
- Bizans şehri:
  - Surun burçları.
  - Servi ağaçları (gövde).
  - Kançılarya masaları.
  - Giustiniani'nin masası ve İmparator'un tahtı.
- Kara surları:
  - Depo yığınları: fıçı istifi, toprak yığını, sepetler, kalaslar.
  - Urban'ın topu, kızağı, sepet siperleri ve barut fıçıları. Namlunun kutusu nişanla birlikte döner. Gülle yolu topun
    kendi parçalarına takılmaz.
  - Gediğin barikatı: fıçılar, sepetler, tabya, kütük perde, kazıklar. Aşama aşama görünürken çarpışması da açılır.

**Gedik (Bölüm 0, 20, 22, 26 ve fragman)**

- Sorun: Yürünen rampa görünmezdi. Ayak, üstündeki basamaklı moloz katmanlarına 0,3–0,5 m gömülüyordu.
- Düzeltmeler:
  - Rampa görünür yapıldı.
  - Katmanlar katı ve eksene hizalı yapıldı; üstleri `rubble_y` ile birebir.
  - Yamacın üstündeki taşlar ve kirişler yüzeye oturtuldu.
  - Savunucular, Giustiniani'nin taşıyıcıları, tüfekçi ve İmparator gediğin yüzeyine oturtuldu. Eskiden tabyanın içinde
    ya da havada duruyorlardı.

**Karakterler**

- Düellocular yürürken ve geri çekilirken duvarların, barikatın ve surun içine giriyordu. Artık adım atmadan önce
  kapsül süpürülüyor.
- Hücum dalgalarındaki saldıranlar ve kaynar yağla tutuşup kaçanlar hendeğin üstünde havada yürüyordu. Artık hendeğe
  iniyorlar.
- İkona alayı (Bölüm 24):
  - Caddedeki tezgâh arabasının içinden geçiyordu. Ana caddeye araba ve tezgâh artık konmuyor.
  - Çeşmenin havuzuna giriyordu. Viraj genişletildi.

## İkinci tur

Denetim aracı düzeltildikten sonra 60 koşu yeniden tarandı. Bulunan ve düzeltilenler:

**Kök nedenler (birden çok bölümü etkileyen)**

- **Görünen arazi ile yükseklik fonksiyonu farklıydı.** Arazi ağı 2–25 m'lik üçgenlerle çiziliyor, nesneler ise
  gürültülü yükseklik fonksiyonuna konuyordu. Tepelerde çadır, kaya, ağaç ve asker 1,5 m'ye kadar havada kalıyor ya
  da toprağa gömülüyordu.
  - Düzeltme: `LowPoly.surface_y` arazinin görünen üçgen yüzeyini verir. Gündüz ordugâhı (`CampDay.height`) ve
    kızak yolu (`Slipway.surface_h`) nesneleri buna oturtur.
- **Ordugâhın düz alanının kenarında ayak toprağa gömülüyordu (0,4 m).** Yükselti bir sonraki ızgara köşesine kadar
  üçgenle yayılıyordu. Düz alan artık ızgara çizgilerine kadar uzanır.
- **Otomatik eşya yerleşimi (Dressing), çoğaltılmış nesnelerin yaklaşık çarpışma kutularının üstünü zemin sanıyordu.**
  Araba, çuval ve askerler yığınların ve çadırların üstünde 0,7–1 m havada duruyordu. Yaklaşık kutular artık zemin
  sayılmaz.
- **Çadırlar kutu yerine kendi biçimleriyle katıdır** (dışbükey kabuk). Kutu yuvarlak çadırın kenarlarında içine
  yürütüyor, köşelerinde görünmez duvar oluyordu.

**Kara surları ve gedik (Bölüm 0, 20, 22, 26 ve Osmanlı tarafı)**

- Hendeğe dökülen moloz dili ters eğimliydi: dışa doğru yükselip hendeğin ortasında 1,4 m havada bitiyordu. Fatih'in
  maiyeti bunun içinden geçiyordu. Dil artık katmanların ucundan hendeğin dibine iner; korkuluk gediğin önünde
  yıkıktır.
- `rubble_y` surun dışında da (hendeğin ve ovanın üstünde) tepe yüksekliğini veriyordu. Artık rampa yalnız surun
  iç yarısındadır.
- Fatih'in atı ve maiyeti, gediğin dış basamaklarına 0,8 m gömülüyor, iç yamacın üstünde 1 m havada yürüyordu. Artık
  gerçek zemine basarlar.
- Hücum edenler karşı duvarın içinden eğik iniyordu. Artık duvarın kenarından hendeğe atlarlar.
- Osmanlı ordusunun yan bloklarının ilk sırası hendeğin üstünde, dibinin 2,9 m üstünde duruyordu. Bloklar hendeğin
  ardına alındı.
- Sur yolunun iç kenarında alçak korkuluk: Bölüm 25'te gece yürürken 8 m aşağı peribolosa düşülüyordu. Merdiven
  başlarında açıklık vardır.
- Bölüm 0'da arka şeritte koşanlar depoyu, toprak yığınını ve fıçıları içinden geçerek kesiyordu.

**Gündüz ordugâhı**

- Şahi topunun kızağı ve namlusu, gülle yığını, barut fıçıları; mutfağın kazanları ve çuvalları; tercümanın masası;
  meydandaki bayrak direği ve tabela direkleri; tavuk avlusunun çiti artık katıdır.

**Öbür bölümler**

- İkona alayı (Bölüm 24): sedyenin sırıkları taşıyıcı keşişlerin göğsünden geçiyordu. Sırıklar omuz yüksekliğine
  alındı; keşişler ve Tolga sırığı sağ omzunda taşır. Alayın dış sırası virajda son evin köşesini sıyırmaz.
- Brigantin (Bölüm 19): küpeşteden (0,6 m) zıplayıp çarpışması olmayan denize atlanıyordu.
- Köprü (Bölüm 18): fıçı ve kalas yığınları ile top; Osmanlı gece işi (Bölüm 22o): hasır siperler, sepet yığını ve su
  fıçısı artık katıdır.
- Fetihten sonra şehir: yağmacılar caddenin kenarındaki enkazın içinden yürüyordu.
- Kızak yolu (Bölüm 2): ırgat askerleri yamaçta havada duruyordu.

## Üçüncü tur (v0.40.3)

Denetime dört şey eklendi: yürüyen bot, zıplamayı gerektiren alçak basamaklar (JUMPNEED), etkileşim alanlarına
erişim (NOREACH) ve Nihat'ın uçuşu (FLYGHOST). Sonra 60 koşu yeniden tarandı. Bölüm numaraları yine dosya
numaralarıdır.

**Oyuncunun hareketi**

- **Basamak çıkışı.** Oyuncu zıplamadan yalnız ~9 cm'lik pürüze çıkabiliyordu: 15 cm'lik moloz basamağı, eşik,
  kaldırım ve 40 cm'lik kilise basamağı için her seferinde zıplamak gerekiyordu. Bot sekiz bölümde 28 yer buldu:
  Ayasofya'nın giriş basamakları, gediğin moloz basamakları, ordugâhta otağın zemini ve halılar.
  - `Player.step_up`: önü alçak bir basamakla kapanınca (en çok 42 cm) gövde basamağa çıkar, kamera yumuşakça
    yetişir.
  - Üstte tavan varsa daha alçak kalkışla denenir (alçak kapının eşiği).
  - Duvar, 60 cm'lik sandık ve 50°'lik rampa yine geçilmez.
  - Uçurum kenarındaki alçak engelin (küpeşte, iskele kenarı) üstünden yürüyerek aşılmaz: basamağın 0,5 m ötesinde,
    1,2 m içinde zemin yoksa çıkılmaz. Zıplayarak yine aşılır.
  - Tavuk boyunda (Bölüm 16) basamak oranla alçalır.
  - Sonuç: 28 yerden 1'i kaldı (ordugâhta yuvarlak bir çuval; zıplayınca çıkılıyor).
- **Katının içinde kalmak.** Ara sahneden çıkınca ya da ışınlanınca gövde bir katının içindeyse en yakın boş yere
  (en çok 3 m) alınır (`Player._unstick`).
- **Fırtına (dosya 24o).**
  - Sorun: Oyuncu, ordugâhın manzara çadırlarından birinin kenarının içinde başlıyordu. Taşkın hiçbir yere
    gidemiyordu. Üç çadır kazığının ikisine hiç, birine ancak 3,4 m'den uzanılabiliyordu (E ışını 2,4 m).
  - Düzeltme: Ordugâhın derin manzarası, bölümün kendi kurduğu yere (`CampDay.extra_avoid`) çadır, eşya ve ağaç
    koymuyor. Artık 6462 hücreye gidiliyor ve üç kazığa da uzanılıyor.

**Nihat'ın uçuşu (Bölüm 3, 7, 11)**

- Uçuş menzili ordugâhta 1300 m, şehirde 800 m.
- Sorun: Evlerin üst katları, çatılar, kubbeler, kuleler ve uzak şehir silueti çarpışmasızdı. Uçan Nihat üst katın
  içinden geçiyor, çatının içine iniyordu. Bölüm 7'de ordugâhta 341, şehirde 280 iri nesne vardı.
- Düzeltmeler:
  - `NihatPowers.ensure_flight_solids`: uçuş başlayınca, yürüme yüksekliğinin üstündeki (en alttaki zeminden 2 m
    yukarıda başlayan) iri, katı görünümlü basit ağlara kendi biçiminde çarpışma ekler. Yerdekilere dokunulmaz:
    yürüyüş değişmez.
  - Uzak manzara (`far_scenery`: Konstantinopolis silueti, ordugâhın önündeki kara surları ve zemini, karşı kıyıda
    Galata) yere otursa da katı olur. Oraya yürüyerek varılmaz.
  - Şehirdeki servilerin tepesi katı.
- Sonuç: ordugâhta 341 → 0, şehirde 280 → 8 (uzaktaki kilise avlularının servileri).

**Etkileşim alanları**

- Bölüm 3, kostüm deposu: fes rafının "bak" alanı tezgâhın ardındaydı; ışının 0,5 m ötesinde kalıyordu. Alan
  tezgâha doğru uzatıldı.

**İçinden geçilen nesneler (katı yapıldı)**

- **Otomatik eşya yerleşimi (Dressing).** Eşya işlevleri çarpışma kutusunu kendi konumlarını (p) eklemeden
  veriyordu. Kaydırılarak konan eşyanın kutusu başka yerde kalıyor, eşyanın içinden yürünüyor, boş yerde görünmez
  bir kutuya çarpılıyordu:
  - at sırası (bütün atların kutusu aynı noktadaydı),
  - güvercinli bank (kutu 1,4 m ötede),
  - mızrak sehpası, saman balyası, sandık yığınları (kızak yolundakiler dahil).

  Hazır modelli atların (Kit) hiç çarpışması yoktu.
- Galata: yatık şarap fıçıları ve fıçı yığınları.

- Ayasofya: açık kapı kanatları, sentronon basamakları, kiborionun sütunları, ambonun merdivenleri ve sütunları,
  kandil sehpası ve mumluk.
- Kara surları: gediğin kırık kenarındaki taş sıraları, çekirdek ve yarım taşlar; kapı kanatları; ok sandığı;
  sancak direkleri; devrilen fıçılar (devrildikten sonra, yattıkları yerde).
- Gündüz ordugâhı: köşk direkleri, döküm kalıbı ve körük, fener direkleri, otağ direkleri, nişan tahtası ve
  ayakları, sadak, kazan ve fıçı modelleri, mektup taburesi. Kamp eşyasının her türü kendi biçiminde (saman ve sandık
  kutu; araba, sandık ve kazan dışbükey kabuk). Kayalar.
- Gece ordugâhı: meşale direkleri ve kamp ateşleri.
- Dosya 17o: top kundağı, tekerlekler, barut fıçıları ve gülleler.
- Arşiv (10a): duvar rafları ve kâtip kürsüleri. Dökümhane (10b): ocak, pota direkleri ve kalıplar.
- Köprü (18): kalas yığınları, sıra, fıçılar, katran kazanı, iskele direkleri ve korkulukları, askerler.
- Büro (7): kapı kasası ve kanadı. Garaj: Zamanator'un bobin sütunları ve koliler. Maden ağzı (9): ağız,
  dikmeler ve toprak yığınları. Dosya 26o: su fıçıları ve merdiven yığını. Bizans sarayı: taht salonunun sütunları.
  Ocak ve sancak direği (Dressing). Keçi ağılının samanı.

**Karakterler**

- Düellocular gediğin görünmez üst duvarında takılıyordu. O duvar artık yalnız oyuncuyu durdurur.
- Surun dışındaki zemin: `LandWalls.outside_y` önce katmanı, yoksa hendeğe dökülen dili, yoksa seti ya da hendek
  dibini verir. Eskiden dilin 1–3 m üstünde havada kalınıyordu (moloz taşları, saldıranlar).
- Ayasofya (dosya 25): cemaatten biri ambonun arka merdiveninin, biri soleanın (ambondan templona giden parapetli
  yol) içinde, biri de içerideki dua eden kadının üstünde duruyordu.
- Dosya 17o: kova zincirindeki askerler iskelenin ayak izinde yerde durup kalasın içinden yükseliyordu. Artık
  iskelenin başına koşup kalasa basarlar.
- Gediğin iç yamacındaki moloz taşları ayak bileği hizasına gömüldü: üstünden geçen savunucu, taşıyıcı ve düellocu
  taşın içine 0,2–0,3 m gömülü görünüyordu.

**Denetim aracı**

- Bütün denetim tek bir fizik karesinde yapılır. Otomatik testte replikler ve geçişler kare başına ilerlediği için
  denetim sürerken bölüm ilerliyor, denetlenen sahne değişiyordu (dosya 25'te surlar denetim sürerken siliniyordu).
- Karakter bulgularında kişinin paltosu, şapkası ve işi yazılır (düğüm adı her koşuda değişir).
- SPAWN oyuncunun gerçek kapsülüyle bakar. Taşkın başladığı hücreden çıkamıyorsa STUCK yazılır.

**Sayılar**

60 koşu; oyuncunun 40 m yakınındaki bulgular. "v0.40.2", ikinci turun sonundaki taramadır.

| Tür | v0.40.2 | v0.40.3 |
|-----|--------:|--------:|
| GHOST (içinden yürünen) | 1574 | 429 |
| SINK (ayak gömülü) | 172 | 24 |
| AIR (havada durulan) | 263 | 95 |
| VOID (dünyanın dışına düşme; kalanı su) | 64 | 36 |
| CLIP / VSUNK / FLOAT (karakterler) | 185 / 231 / 169 | 93 / 153 / 99 |
| MMFLOAT | 84 | 72 |
| SLIDE / WALKFALL / WALKBLOCK | 7 / 4 / 2 | 0 / 0 / 0 |
| SPAWN / TARGET | 1 / 3 | 0 / 0 |
| JUMPNEED (yeni) | – | 16 |
| NOREACH (yeni) | – | 2 |
| FLYGHOST (yeni; bütün uzaklıklar) | 600'den çok | 8 |

- IWALL 2392'den 2588'e çıktı: katı yapılan eşyaların üstüne çıkılabildiği için sınır duvarlarına daha çok yerden
  değiliyor. Hepsi bilinçli sınırlardır (Dressing'in yaklaşık kutuları, sur yolunun korkulukları).
- Kalan 16 JUMPNEED, bölüm başına 1–3 yer: yuvarlak çuval, eğimli kabuk. Zıplayınca çıkılıyor.
- Kalan 2 NOREACH, Bölüm 22 ve 25'te (dosya numarası) kullanılmayan gedik alanıdır (oyuncu surun üstündedir).
- Kalan 8 FLYGHOST, uzaktaki (160–570 m) kilise avlularının servileri ve bir çatı parçasıdır.
- Karakter bulguları (CLIP, VSUNK, FLOAT) her koşuda biraz değişir: yürüyenler, düellocular ve kaçışanlar rastgele
  yerlerde denetlenir.
- Uçuş çarpışmaları bölüm başında kurulur (ordugâhta 0,1–0,2 s, açılış kararması sürerken).
