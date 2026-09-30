# Fizik denetimi (v0.40.2)

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
   - Bütün denemeler tek bir fizik karesinin içinde yapılır. Başka hiçbir şey kıpırdamaz; oyuncunun yeri ve hızı
     sonunda geri konur, bölge tetikleri ve bölüm betiği bir şey görmez. Evre başına yaklaşık 1500 deneme, yarım saniye.

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

