# Osmanlı Tarafı · Hikâye Akışı ve Bölüm 32o (v0.1)

Bu belge kuşatmanın **Osmanlı nüshasını** baştan sona tek bir hikâye olarak okur. Kaynak: `Siege.ORDER`
(`scripts/siege.gd`), her bölümün `##` başlığı ve `i18n/strings.csv` replikleri. Tasarım ilkeleri SIEGE.md ve
GAMEPLAY_EPIC.md'deki gibidir: *tarih inatçıdır*, Tolga sonucu değil insanları değiştirir, Kerkoporta rivayeti kullanılmaz.

Oyuncu şikâyeti (özet): *"Çorba dağıtımından direkt savaşa geçtik; hikâye bağı yok, hazırlık anı yok, surlara top
atışı yok; çoğu izlemelik, oynanış az."* Aşağıdaki öneriler bu şikâyete göre **oynanış önce** sıralanmıştır.

Kaynak kısaltmaları: **R** Runciman (*The Fall of Constantinople 1453*), **K** Kritovoulos, **B** Barbaro'nun günlüğü,
**TB** Tursun Bey, **AP** Aşıkpaşazade. Kesin olmayan ya da sonraki anlatılara dayanan ayrıntılar **(rivayet)** diye işaretlidir.

---

## 1. Akış haritası

Osmanlı tarafında oynanan sahne: `Siege.scene_path(id, "O")` → `chapterNo.tscn` varsa o, yoksa ortak `chapterN.tscn`.
Ekrandaki numara = 12 + sıra (Perde III'ün ardından 13'ten başlar). **32o eklendikten sonraki** sıra:
`ORDER = [28, 29, 17, 18, 19, 20, 30, 21, 22, 23, 24, 25, 32, 26, 31, 27]` (31o yapılana kadar atlanır; 27'nin numarası
31o gelince 27 → 28 olur).

| # | İç id | Sahne (Osmanlı) | Tarih (1453) | Tolga ne yapar (fiiller) | Ana olay | Sonuçlar |
|---|---|---|---|---|---|---|
| 13 | 28 | `chapter28o` | 6 ve 11–12 Nisan | kazık taşı/çak, "hey-yap" ritmiyle çek (RowMeter), kütüğü öne taşı, topu elle doldur + nişan (CannonCrew) | Ordu surların önünde; Şahi bataryaya, ilk gülle sağlam sura | 28O.1 top ilk seferde oturdu · 28O.2 kızak kaydı |
| 14 | 29 | `chapter29o` | 20 Nisan | kürek ritmi, kanca at, ipten tırman (düş), tüfek (GunRange) | Dört gemi ablukayı yarar; Sultan atını denize sürer; Baltaoğlu azli | 29O.1 kancalar tuttu · 29O.2 tutmadı |
| 15 | 17 | `chapter17o` | 28 Nisan gecesi | gözle ve göster (E), top doldur/nişan, kova zinciri | Coco'nun kundak baskını; Galata'da ışık; fusta batar | 17O.1 yangın çabuk söndü · 17O.2 kadırganın kıçı yandı |
| 16 | 18 | `chapter18` (ortak sahne, Osmanlı içerik) | Mayıs başı | fıçı yuvarla, halat bağla (zamanlama), kalas döşe | Haliç'in iç ucunda fıçı köprü, üstüne top | 18.1 sağlam · 18.2 eğri ama ayakta |
| 17 | 19 | `chapter19o` | 3 Mayıs gecesi → **23 Mayıs** şafağı | kürek, gözle, söyle/sus seçimi, tüfek, kovalamaca küreği | Sarıklı brigantin zincirden çıkar, 20 gün sonra döner | 19O.1 reise söyledi · 19O.2 sustu |
| 18 | 20 | `chapter20o` | 7 Mayıs, gündüz → gece yarısı | top doldur/nişan (3 atış), namluyu yağla soğut (E basılı), tüfek, gedikte WaveRunner | Urban'ın topu Mesoteichion'da gedik açar; gece hücumu püskürtülür | 20O.1 gedik açıldı · 20O.2 surlar dayandı |
| 19 | 30 | `chapter30o` | 12 Mayıs gece yarısı | merdiveni ekipçe taşı, daya, tırman (taş/kaynar yağ), sur yolunda dövüş, yaralıyı sırtla | Blakherna önüne büyük gece hücumu; İmparator gelir; püskürtülür | 30O.1 tutunuldu · 30O.2 atıldın |
| 20 | 21 | `chapter21o` | 16 Mayıs | kaz (E basılı), destek koy, tünelde düello, dumandan kaç | Novo Brdo'lu madenciler; karşı lağımla karşılaşma, Rum ateşi | 21O.1 dumandan önce çıkıldı · 21O.2 Dragan çekti |
| 21 | 22 | `chapter22o` | 17–19 Mayıs | sepetle toprak taşı, deri çak, kova ile ıslat, "Siper!", kuleden tüfek, kule dibinde düello, ustaları indir | Bir gecede kule; ertesi gece barut fıçılarıyla yanar | 22O.1 herkes indi · 22O.2 Hasan son adamı taşıdı |
| 22 | 23 | `chapter23` (ortak, `osm` dalı) | 21 Mayıs | yalnız diyalog: çeviri seçimi (sapma göstergesi), fotoğraf | İsmail Hamza'nın son teklifi, İmparator'un reddi | 23.1 sadık · 23.2 yaratıcı tercüme |
| 23 | 24 | `chapter24o` | 22 ve 24 Mayıs | çorba kazanı taşı, üç ateşte konuşma seçimi, fotoğraf (kanlı ay), çadır ipini tut (E basılı) | Ay tutulması, ordugâhta korku; fırtına ve dolu | 24O.1 üç ateş sakin · 24O.2 derviş yetişti |
| 24 | 25 | `chapter25` (ortak, Osmanlı dalı) | 27 Mayıs gecesi (+ şimdilik 28 Mayıs gecesi) | şerbet tepsisini götür, nöbetçilere görünmeden dinle (gizlilik), fotoğraf; Hasan'la ateş başı seçimi | Savaş meclisi: Çandarlı / Zağanos; karar: yarın oruç, ertesi şafak hücum | 25.1 meclis sonuna dek · 25.2 sonu kaçtı |
| **25** | **32** | **`chapter32o` (yeni)** | **28 Mayıs** | **demet taşı + siper, basamak çak, merdiven/manto taşı, top doldur + soğut + tüfekçiden saklan, meşaleyle ateş yak, fotoğraf, ateş başı seçimi** | **Son gün: oruç, hazırlık, son bombardıman, ışıklar ve sükût** | **32O.1 / 32O.2 (§4)** |
| 26 | 26 | `chapter26o` | 29 Mayıs, 01.30 → öğleden sonra | su taşı, merdiven taşı, "Siper!", tüfek, merdivenden tırman (taş, yağ), sur yolunda WaveRunner, sancağı kaldır, fotoğraf | Üç dalga; Hasan ve sancak; Sultan Ayasofya'da | 26.1 son kare · 26.2 kare yok / Hasan'ın karesi |
| (27) | 31 | `chapter31o` (**planlı**) | 30 Mayıs–1 Haziran | — | Fethin ertesi; Kayser'in sarayı | — |
| 27 | 27 | `chapter27` (ortak) | 1 Haziran | üç kişiye "kal / git", fotoğraf; Büro'da kapanış | Galata ahitnamesi | 27.1 kalanlar · 27.2 gidenler |

**Not (ekran numarası):** Sonuç düğümlerinin eski adları hâlâ eski numaralarla yazılı (`FLOW_20O_1` = "16O.1 …",
`FLOW_24O_1` = "20O.1 …"). Yeni bölümler (28O, 29O, 30O) numarasız. Hepsini numarasız yapmak ya da `{N}` kullanmak
gerekir; yoksa Osmanlı oyuncusu 18. bölümün şemasında "16O.1" görür.

---

## 2. Kopukluklar

### 2.1 Bölümden bölüme geçişler

| Geçiş | Kopukluk | Öneri (oynanış önce) |
|---|---|---|
| Büro → 28o | Büro önsözü `D17_N_FIRST_28` "İlk kayıt **11 Nisan**" diyor, bölüm **6 Nisan**'da açılıyor (`D28O_N_01`). Ayrıca 6 ve 20 Nisan, Tolga'nın kendi hikâyesindeki gelişinden (22 Nisan) önce: kimse bunu açıklamıyor. | `D17_N_FIRST_28`'i "6 Nisan" yap. Nihat bir cümle eklesin: "Sizin ilk gelişinizden iki hafta önce. Kendinize rastlamazsınız, merak etmeyin." |
| 28o → 29o | Topçu kâtibi bir gecede Baltaoğlu'nun kadırgasında kürekçi. Neden denizde? | 29o başında Urban "kâtibi" donanmaya ödünç verir (tek replik, ya da 28o'nun sonunda bir ulak çağırır). |
| 29o → 17o | 20 → 28 Nisan arasında **22 Nisan gemilerin karadan indirilmesi** var (Bölüm 2'de Tolga oradaydı). Osmanlı nüshası bunu anmıyor; 17o'da donanma birden Haliç'in içinde. | 17o'nun önceki-bölüm satırı bunu söyler (§3). 17o açılışında Topçubaşı Ali'ye bir replik: "Gemileri tepeden aşırdık, şimdi korumak bize kaldı." |
| 17o → 18 | Ortak 18'in girişi `D18_N_01` "Bu kayıt Osmanlı tarafında" diyor: Osmanlı oyuncusu zaten bir aydır orada. | Osmanlı dalı için `D18O_N_01` (Usta Mahmud'a Topçubaşı Ali'nin gönderdiği yamak). |
| 18 → 19o → 20o | **Takvim geri gidiyor**: 19o 23 Mayıs'ta biter, 20o 7 Mayıs'ta açılır. | Seçenek A (önerilen): 19o'nun dönüş kovalamacasını (23 Mayıs) 24o'nun ortasına taşı: 22 Mayıs ayı → 23 Mayıs şafağı Haliç ağzında kovalama → 24 Mayıs fırtınası. Seçenek B: §3'teki satırlar takvim atlamasını açıkça söyler ("Takvimi geri saralım: 7 Mayıs"). |
| 20o → 30o | 20o'da Tolga Urban'ın topçusu, 30o'da Zağanos Paşa'nın merdivencisi; Lykos'tan Blakherna'ya geçişin sebebi yok. | 20o sonunda Urban: "Zağanos Paşa adam istiyor, sen hafifsin" (29o'daki "sen hafifsin" esprisini sürdürür). |
| 30o → 21o | Yaralı azap (30o) ve Zağanos'un adamları kayboluyor; 21o'da Zağanos Tolga'yı tanımıyor gibi konuşuyor ("Büro'nun kâtibiymiş"). | Zağanos'un ilk repliğine 30o'ya gönderme: "Blakherna'da yaralıyı getiren kâtip sen misin? Bu sefer surun altına." Yaralı azap 32o'da geri gelir (§4). |
| 21o → 22o | Hasan kendini yeniden tanıtıyor ("Ben Hasan"), oysa Perde I'de (4a) bir Hasan nöbetçiydi. Aynı kişi mi? Belirsiz. | Karar verilmeli. Aynıysa: "Ordugâhtaki esir kâtip! Kaçmıştın, döndün mü?" Değilse 4a'daki nöbetçiye başka ad. |
| 22o → 23 | Ordugâhtan saraya; Tolga Osmanlı heyetiyle geliyor ama sarayın memuru `D23_TH_01` ona "Frenk… sen iki dili de konuşuyorsun" diye görev veriyor, sanki Bizans tarafındaymış gibi. | Osmanlı dalına `D23O_TH_01`: "Bizim tercüman hasta. Elçinin kâtibi iki dili biliyormuş; o çevirsin, kelimesi kelimesine." |
| 23 → 24o | Sorun yok (21 → 22 Mayıs). 23 neredeyse tamamen izlemelik (aşağıda). | — |
| 24o → 25 | Kadri `D24O_K_LOST_0` "yarından sonra aşçı yamağı" diyor, 25 bunu kullanıyor: **iyi bağ**. Ama 25'in açılışı `D25_N_01` "Önce ordugâh… sonra şehir: yarın akşam" diyor; Osmanlı tanığı şehre hiç gitmiyor. | Osmanlı dalı için `D25O_N_01` (§4.7'de metni var). |
| 25 → 26o | **Kullanıcının şikâyeti tam burada.** 27 Mayıs gecesi meclis ve aynı bölümde 28 Mayıs gecesi ateş başı; 28 Mayıs'ın **gündüzü yok**: hendeğin doldurulması, merdivenler, son bombardıman, Sultan'ın hatları dolaşması, ışıklar. 26o doğrudan hücumla açılıyor ve `LandWalls.ditch_filled = true` ile dolu bir hendek gösteriyor; o hendeği kimin doldurduğu hiç oynanmadı. | **Bölüm 32o** (§4). 25'in Osmanlı dalı 27 Mayıs'ta biter, ateş başı sahnesi 32o'ya taşınır. |
| 25 ↔ 26o | Çelişki: 25'te Hasan'la 28 Mayıs gecesi ateş başında oturuluyor, 26o'da Hasan `D26O_H_01` "Kule gecesinden beri görmedim seni" diyor. | `D26O_H_01`'i 32o'daki seçime göre üç varyantla değiştir (§4.7). |
| 26o "son sayfa" | `D25O_N_END` "Yarın son sayfa", `D26O_N_01` "son sayfa"; ardından 27 (ve planlı 31o) geliyor. | "kuşatmanın son gecesi" (§4.7). |
| 26o → 27 | 27'deki tanıdıklar (Spinola, noter, balıkçı) **Bölüm 10G**'den; Osmanlı yolundaki oyuncu onlarla hiç tanışmamış olabilir. | 10G oynanmadıysa ilk karşılaşma replikleri ("Seni tanımıyorum ama fesin Türk, sözün Frenk…"). |

### 2.2 Tolga'nın rolü ve neden orada olduğu

Tolga her bölümde başka bir iş yapıyor (topçu kâtibi, kürekçi, topçu yamağı, köprü yamağı, devriye kürekçisi, Urban'ın
ekibi, merdivenci, lağımcı, Hasan'ın sepetçisi, elçinin tercümanı, aşçı yamağı, saka). Bu tek başına kötü değil; ordu
gerçekten böyle çalışır. Kötü olan, **işe nasıl girdiğinin** hiç gösterilmemesi: her bölüm Nihat'ın telsiziyle açılıyor,
bir NPC Tolga'yı "Büro'nun kâtibi" diye tanıyor. 1453'te kimsenin "Büro"yu bilmemesi gerekir (21o, 22o, 17o).

**Öneri:** Tolga'ya ordugâhta tutarlı bir örtü: **ruznâmeci (ordunun günlük defterini tutan kâtip)**. Bölüm 12'deki
huzurdan sonra eline bir **tezkire** verilir (eşya gösterme sistemi var). Her bölümün ilk NPC'si tezkireyi görür ve onu
işe koşar ("Defterini sonra yazarsın, önce şu kazığı çak"). Böylece "kâtip" hitabı her bölümde anlam kazanır ve
Hasar Tespit fotoğrafı da hikâyenin içinde bir iş olur.

### 2.3 Açılıp kapanmayan karakter ipleri

| İp | Nerede açılıyor | Durum | Öneri |
|---|---|---|---|
| Usta Urban | 28o, 20o | 7 Mayıs'tan sonra yok | 32o'da Topçubaşı Ali anar; büyük top komşu bataryada konuşur. (Urban'ın sonu kaynaklarda belirsiz; ölümü **rivayet**, gösterilmez.) |
| Topçubaşı Ali | 17o | Bir kez görünüp kayboluyor | **32o'da geri gelir** (faz 3). |
| Usta Mahmud (köprücü) | 18 | Kayboluyor | **32o'da merdiven ustası** (faz 2). |
| Devriye reisi | 19o | Kapanıyor (iyi) | — |
| Dragan | 21o | Kayboluyor | 26o'da bir bark: "Dragan'ın lağımı burada çökmüştü." |
| Yaralı azap | 30o | Kayboluyor | **32o'da hendek bölükbaşı** (faz 1); düşerse Tolga'yı o taşır. |
| Üç marangoz | 22o | 26o'da anılıyor (iyi) | **32o'da görünür**; 26o'daki "bu gece merdiven çaktılar" repliği böylece oynanmış olur. |
| Aşçıbaşı Kadri | 24o, 25 | 26o'da yok | 32o'da sabah ve iftar. |
| Hasan | 22o, 25, 26o | 25 ile 26o arasında çelişki | 32o gecesi + 26o varyantları. |
| Zağanos Paşa | 21o, 30o, 25, 27 | Tutarlı | 32o'da yok: 28 Mayıs'ta onun bölgesi Haliç/köprü tarafıydı (**R**); Lykos'a sokmak tarihî olarak zayıf. |

### 2.4 İzlemelik ağırlıklı bölümler

| Bölüm | Oynanış/diyalog dengesi | Sorun |
|---|---|---|
| 23 Elçi | Neredeyse yalnız diyalog ve seçim | Osmanlı tarafında tek fiziksel iş yok. |
| 25 Son Akşam | Tepsi yürüyüşü + kısa gizlilik + fotoğraf + uzun meclis ve ateş başı | Meclis dinlemek tasarım olarak iyi; tepsi taşımak düz yürüyüş. |
| 24o Alametler | Çorba = yürüyüp seçim yapmak; ip = E basılı | İki fazın ikisi de "yürü, bas". |
| 19o Devriye | Kürek + seçim + tüfek | Seçim sahnesi uzun; denge iyi. |
| 18 Köprü | Ritim işleri, tehlike yok | Gerilim yok; karşı kıyı hiç ateş etmiyor (18b'de Bizans ateş ediyor!). |
| 26o, 20o, 22o, 30o, 29o, 28o, 21o | Oynanış ağırlıklı | İyi. |

**Top ateşi boşluğu:** Oyuncu sura en son **7 Mayıs**'ta (20o) top atıyor; sonraki yedi bölümde bombardıman yalnız uzak
ses. Oysa toplar 48 gün susmadı. 32o'nun 3. fazı bunu kapatır; ayrıca 21o, 22o, 24o ve 25'te `SiegeField.bombard = true`
ile arka planda bataryalar ateş etmeli (yalnız görüntü ve ses).

---

## 3. "Önceki bölümde / Sırada" satırları

Kurallar: `Siege.recap()` anahtarı sahne adından kurar (`chapter26o` → `26O`, `chapter25` → `25`) ve yalnız Osmanlı
tarafında gösterir; ortak sahnelerin (18, 23, 25, 27) satırları Bizans oyuncusuna görünmez. Başlıklar ("Önceki bölümde:",
"Sırada:") `UI_RECAP_PREV_HEAD` / `UI_RECAP_NEXT_HEAD`'den gelir; satırlar ön ek içermez. Her satır en çok 140 karakter
(denetlendi). 19o'nun sonundaki takvim atlaması 19O_NEXT ve 20O_PREV'de açıkça söylenir. **31O satırları planlıdır**
(sahne yok, şimdilik gösterilmez); 26O_NEXT ve 27_PREV şimdiki sıraya (31o'suz) göre yazıldı.

```csv
UI_RECAP_28O_PREV,"Büro'da Form Z-1453/GT'yi imzaladın, Osmanlı nüshasını seçtin. Nihat seni kuşatmanın ilk gününe bıraktı.",At the Bureau you signed Form Z-1453/TW and took the Ottoman copy. Nihat dropped you on the siege's first day.
UI_RECAP_28O_NEXT,"20 Nisan, Haliç'in ağzı: Baltaoğlu'nun kadırgasında dört yüksek gemiye karşı kürek ve kanca.","20 April, the mouth of the Horn: oars and grappling hooks on Baltaoğlu's galley against four tall ships."
UI_RECAP_29O_PREV,"Urban'ın siperine kazık çaktın, Şahi'yi kütükler üstünde bataryaya çektin ve ilk gülleyi sura indirdin.","You planted stakes at Urban's rampart, hauled the great gun into its battery on rollers and put the first ball into the wall."
UI_RECAP_29O_NEXT,"Dört gemi zincirden girdi, Baltaoğlu azledildi. 28 Nisan gecesi: Haliç kıyısındaki toplar, Venedik baskını.",Four ships got in behind the chain; Baltaoğlu was dismissed. Night of 28 April: the shore guns and a Venetian raid.
UI_RECAP_17O_PREV,"20 Nisan'da kancalar bordaya yetmedi, Sultan atını denize sürdü. 22 Nisan'da donanma karadan Haliç'e indirildi.",On 20 April the hooks couldn't reach the decks and the Sultan rode into the sea. On 22 April the fleet was dragged overland into the Horn.
UI_RECAP_17O_NEXT,Coco'nun baskını battı. Mayıs başı: Haliç'in iç ucunda fıçıların üstüne top taşıyan bir köprü kuracağız.,Coco's raid has sunk. Early May: at the head of the Horn we build a bridge on barrels that will carry a gun.
UI_RECAP_18_PREV,"28 Nisan gecesi kıyı toplarıyla Coco'nun fustasını batırdın, yanan kadırgayı kova zinciriyle söndürdün.","On the night of 28 April the shore guns sank Coco's fusta, and you put out a burning galley with a bucket chain."
UI_RECAP_18_NEXT,Köprünün üstünde top var. 3 Mayıs gecesi: Hamza Bey'in devriye kayığıyla zincirin önünde nöbet.,There's a gun on the bridge now. Night of 3 May: on watch before the chain in one of Hamza Bey's patrol boats.
UI_RECAP_19O_PREV,Fıçıları ikişer bağlayıp Haliç'in iç ucuna köprü kurdun; Usta Mahmud'un topu köprünün üstüne çekildi.,You lashed barrels in pairs into a bridge across the head of the Horn; Master Mahmud's gun was hauled onto it.
UI_RECAP_19O_NEXT,"Brigantin içeride, donanma haberi yok. Takvimi geri saralım: 7 Mayıs, Urban'ın büyük topuyla Mesoteichion.","The brigantine is home with no fleet behind it. Back up the calendar: 7 May, Urban's great gun against the Mesoteichion."
UI_RECAP_20O_PREV,3 Mayıs gecesi sarıklı brigantini gördün; yirmi gün sonra döndüğünde kovaladın ama zincire yetişemedin.,On 3 May you saw the brigantine in turbans slip out; twenty days later you chased it home and missed it at the chain.
UI_RECAP_20O_NEXT,Gedik her gece yeniden örülüyor. 12 Mayıs gece yarısı: Zağanos Paşa'nın merdivenleriyle Blakherna suruna.,"The breach is rebuilt every night. Midnight, 12 May: Zaganos Pasha's ladders against the wall at Blachernae."
UI_RECAP_30O_PREV,"7 Mayıs'ta Urban'ın topuyla dış surda gedik açtın, namluyu yağla soğuttun; gece gediğe hücum püskürtüldü.",On 7 May you opened a breach with Urban's gun and cooled the barrel with oil; that night's assault on it was thrown back.
UI_RECAP_30O_NEXT,"Surun üstünden olmadı. 16 Mayıs: Novo Brdo'lu madencilerle surun altına, lağıma iniyoruz.","Over the wall didn't work. 16 May: down under it, into the mine with the miners from Novo Brdo."
UI_RECAP_21O_PREV,12 Mayıs gecesi Blakherna'da merdivenle sura çıktın; boru çalınca yaralı bir azabı sırtında geri getirdin.,On 12 May you climbed the wall at Blachernae; when the horn sounded you carried a wounded azap back on your back.
UI_RECAP_21O_NEXT,Lağım ateşle kapandı. 17 Mayıs gecesi: yeniçeri Hasan'la hendeğin önüne bir gecede kule kuracağız.,The mine was closed with fire. Night of 17 May: with the Janissary Hasan we raise a tower before the moat in one night.
UI_RECAP_22O_PREV,"16 Mayıs'ta Dragan'la surun altını kazdın; karşı lağımla yüz yüze geldin, Rum ateşinin dumanından kaçtın.","On 16 May you dug under the wall with Dragan, came face to face with the countermine and outran the smoke."
UI_RECAP_22O_NEXT,"Kule yandı, ustalar indi. 21 Mayıs: İsmail Hamza'nın heyetiyle Blakherna'ya, son teslim teklifine.",The tower burned; the carpenters got down. 21 May: with Ismail Hamza's embassy to Blachernae and the last offer.
UI_RECAP_23_PREV,"Hasan'la bir gecede kule kurdun; ertesi gece barut fıçıları kuleyi yaktı, üç ustayı merdivenden indirdiniz.",You and Hasan raised a tower in one night; the next night powder barrels burned it and you got three carpenters down.
UI_RECAP_23_NEXT,Teklif reddedildi. 22 Mayıs gecesi ordugâhta ay tutulacak; Aşçıbaşı Kadri'nin çorbası ateş başlarına.,The offer was refused. On the night of 22 May the moon goes dark over the camp; Head Cook Kadri's soup goes round the fires.
UI_RECAP_24O_PREV,21 Mayıs'ta İsmail Hamza'nın tercümanıydın. İmparator teklifi reddetti: şehri vermek kimsenin elinde değil.,On 21 May you interpreted for Ismail Hamza. The Emperor refused: giving up the city is in no one's power.
UI_RECAP_24O_NEXT,Alametler geçti. 27 Mayıs gecesi otağda savaş meclisi toplanıyor; şerbet tepsisi senin elinde.,The omens have passed. On the night of 27 May the war council meets in the Sultan's tent; you carry the sherbet.
UI_RECAP_25_PREV,22 Mayıs'ta kanlı ayın altında ateş başlarına çorba ve söz taşıdın; 24 Mayıs fırtınasında mutfak çadırlarını tuttun.,Under the blood moon of 22 May you took soup and words to the fires; in the storm of 24 May you held the kitchen tents.
UI_RECAP_25_NEXT,"Karar verildi: yarın oruç ve hazırlık, ertesi şafak hücum. 28 Mayıs: hendeği dolduracak, son gülleleri atacağız.","The decision is made: tomorrow fasting and preparation, the dawn after, the assault. 28 May: fill the moat, fire the last shots."
UI_RECAP_32O_PREV,"27 Mayıs gecesi otağın arkasında meclisi dinledin: Çandarlı barıştan, Zağanos hücumdan yana. Sultan: hücum.","On 27 May you listened behind the Sultan's tent: Çandarlı for peace, Zaganos for the assault. The Sultan chose the assault."
UI_RECAP_32O_NEXT,"Ateşler kısıldı, ordu sustu. Gece 01.30, son hücum: sakasın. Hasan'a verdiğin sözün vakti geldi.","The fires are low, the army is silent. 1:30 a.m., the final assault: you carry the water. Time to keep your word to Hasan."
UI_RECAP_26O_PREV,"28 Mayıs'ta hendeğe çalı demeti taşıdın, merdiven çaktın, barikatı dövdün; gece Hasan'la son ateşin başındaydın.","On 28 May you carried brushwood to the moat, nailed ladders and shelled the stockade; that night you sat with Hasan at the last fire."
UI_RECAP_26O_NEXT,"Şehir düştü. 1 Haziran, Galata: Ceneviz kasabası kapılarını açtı; Zağanos Paşa ahitnameyi okuyacak.","The city has fallen. 1 June, Galata: the Genoese town has opened its gates; Zaganos Pasha will read the charter."
UI_RECAP_31O_PREV,29 Mayıs şafağında su ve merdiven taşıdın; Hasan sancağı burca dikti. Öğleden sonra Sultan Ayasofya'ya girdi.,At dawn on 29 May you carried water and ladders; Hasan planted the banner on the tower. That afternoon the Sultan entered Hagia Sophia.
UI_RECAP_31O_NEXT,"1 Haziran, Galata: Ceneviz kasabası kapılarını açtı; Zağanos Paşa ahitnameyi okuyacak.","1 June, Galata: the Genoese town has opened its gates; Zaganos Pasha will read the charter."
UI_RECAP_27_PREV,"29 Mayıs'ta Hasan'a su verdin, o sancağı burca dikti. Şehir düştü; Sultan öğleden sonra Ayasofya'ya girdi.",On 29 May you gave Hasan water and he planted the banner on the tower. The city fell; that afternoon the Sultan entered Hagia Sophia.
UI_RECAP_27_NEXT,"Dosya kapanıyor. Büro seni 26 Nisan öğlesine, kendi hikâyenin kaldığı yere geri bırakacak.","The file is closing. The Bureau will drop you back at noon on 26 April, where your own story left off."
```

31o yapıldığında bu iki satır yukarıdakilerin yerine geçer (planlı):

```csv
UI_RECAP_26O_NEXT,"Şehir düştü. 30 Mayıs: fethin ertesinde yıkık sokaklarda, esirlerin ve yaralıların arasında; Sultan Kayser'in sarayında.","The city has fallen. 30 May: the morning after, in ruined streets among captives and wounded; the Sultan at the Emperor's palace."
UI_RECAP_27_PREV,Fethin ertesinde yıkık şehirde yaralılara su taşıdın; Sultan harap Kayser sarayında bir beyit okudu (rivayet).,After the conquest you carried water to the wounded; in the Emperor's ruined palace the Sultan recited a couplet (tradition).
```

---

## 4. Yeni bölüm 32o — "Son Gün" (28 Mayıs 1453)

### 4.1 Tarihî dayanak

- **Karar ve gün:** 26/27 Mayıs meclisinden sonra Sultan, 28 Mayıs'ı oruç, dua ve dinlenme günü, ertesi şafağı hücum
  günü ilan etti (**R**, **K**, **B**). (Kaynakların çoğu meclisi 26 Mayıs'a koyar; oyun 27 Mayıs gecesini kullanıyor,
  savunulabilir.)
- **Tellallar:** Ordugâhta hücum ilan edildi, ödüller vaat edildi; sura ilk çıkana yüksek rütbe ve dirlik sözü verildi
  (**R**, **K**). Kaynaklar şehrin kılıçla alınması hâlinde malın askere bırakılacağının da duyurulduğunu yazar; bölüm
  bunu tellala söyletmez (ton), dosya notunda da yer vermez.
- **Hazırlık:** Hendek çalı demeti, toprak ve taşla dolduruldu; merdivenler ve tekerlekli siperler (mantolar) ileri
  getirildi; toplar gün boyu surları dövdü (**R**, **B**). Barbaro merdivenlerin sayısını iki bine kadar çıkarır (abartılı
  olabilir).
- **Sultan:** Hatları atla dolaştı, komutanlara düzen ve itaat üzerine konuştu (**K**'nin aktardığı nutuk; sözler
  Kritovoulos'un kurgusudur, öz olarak alınır).
- **Işıklar ve sükût:** Hücumdan önceki gecelerde ordugâh ateş ve meşalelerle aydınlandı, tekbir sesleri surlara ulaştı;
  surdakiler kampın yandığını sandı (**B**, **R**). 28 Mayıs gecesi ordu sustu ve karanlıkta yerine geçti; şehirde çanlar
  çalıyor, halk kiliselerde ve surlarda dua ediyordu (**R**). Bölüm ikisini sırayla verir: akşam ışık ve tekbir, gece
  yarısına doğru sükût. (Işıkların tam olarak hangi gecelere düştüğü kaynaklarda tartışmalıdır; bölüm 28 Mayıs akşamını seçer.)
- **Kerkoporta** rivayeti yok. **Ulubatlı Hasan**'ın ayrıntıları 26o'daki gibi saygıyla, kahramanlık abartısı olmadan.

### 4.2 Yer ve sistemler

- **Harita:** `LandWalls` + `SiegeField` (20o ve 26o ile aynı Lykos kesiti, Mesoteichion önü). Gün ışığı fazlarında
  `make_day()`, akşam `make_dawn(t)` tersine (alacakaranlık), gece `Night.environment`. Ordugâh tarafı: `SiegeField` siperi
  (z ~112), ölü bölge (z 36–95), hendek (z ~20). Hendeğin dolumu kademeli bir yığın ağıyla gösterilir; bölüm sonunda
  `LandWalls.ditch_filled = true` yazılır ki 26o aynı hendeği görsün.
- **Kullanılan sistemler:** taşıma ve "Siper!" döngüsü (22o `_take/_drop_carry/_covered/_volley_tick`, `Assault.volley`),
  zamanlamalı E (18'deki halat bağlama), ekipçe merdiven taşıma (30o), `CannonCrew` + `GunDrill` + yağla soğutma (20o
  `_setup_gun_crew/_cool_step`), `Gunner` (surdaki tüfekçi), `SiegeField.hide_panel` (manto), `Night.campfire/torch`,
  `Horse` + `Person` (Sultan ve maiyeti; 29o'daki `SeaBattle.ride_in` gibi bir yol üstünde yürüyüş), `TespitCam`,
  `hud.choose`, `Lore.scatter(self, "32o")` (3 sayfa), `Grade.finish("32o")` (tüfekçi ve ok sayaçları için).
- **Süre hedefi:** 10–12 dk; diyalog ≤ 3 dk.

### 4.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 0. Tellal | Şafak | `UI_OBJ32O_WALK` | Kadri'nin kapalı mutfağından siperin önüne **yürürken** tellal bağırır (bark, yürüyüş durmaz). Arka planda ordu oruçlu: ateş yok, sessiz hazırlık. | — |
| 1. Hendek | Sabah | `UI_OBJ32O_BUNDLE`, `UI_OBJ32O_DROP`, `UI_OBJ32O_EARTH`, `UI_OBJ32O_COVER` | Yığından **çalı demeti** (sırtta: %30 yavaş), ölü bölgeyi geç, hendek kıyısında E ile at. **Sekiz demet**; her iki demetten sonra bir **toprak sepeti** zorunlu (sıra 20'deki gibi önemli: toprak dökülmezse bir sonraki demet sayılmaz, azap uyarır). Surdan 10–14 sn'de bir ok yaylımı: "Ok!" uyarısından 2 sn içinde mantonun ya da sepet siperin arkasında değilsen −30 can (22o kuralı). Mantolar ölü bölgede üç noktada; biri faz 2'de ileri itilecek olan. Yan bölükler de taşır (Crowd/BattleExtras "osm"). | Süre 4 dk. Sayaç: teslim edilen demet, yenen ok. Can biterse yere düşülür, azap Tolga'yı taşır (`D32O_AZ_DOWN`), elindeki demet kaybolur. |
| 2. Merdiven ve manto | Öğle | `UI_OBJ32O_RUNG`, `UI_OBJ32O_LADDER`, `UI_OBJ32O_MANTLET` | Usta Mahmud'un tezgâhı (siperin ardı). (a) Bir merdivene **6 basamak**: çivi işareti yeşilken E (18'deki halat zamanlaması; ıska = basamağı sök, yeniden). (b) Bitmiş iki merdiveni **ekipçe** (30o'daki taşıma) hendek kıyısındaki yığına taşı; yolda bir yaylım (ekip çömelir, sen de siper al). (c) **Manto it**: W basılı, tekerlekli perde yavaş ilerler; arkasında kaldığın sürece oklar perdeye saplanır. İşarete varınca kalır ve **26o'da yerinde durur** (26o'nun su fazında siper olarak kullanılır). | Başarısızlık yok; eğri basamak sayısı 26o'da bir bark'a döner. |
| 3. Son gülleler | İkindi → akşamüstü | `UI_OBJ32O_LOAD`, `UI_OBJ32O_COOL` | Topçubaşı Ali'nin bataryası. **3 atış** `CannonCrew` ile, hedef gedikteki **barikat** (`LandWalls.set_repair` aşaması; her isabette bir aşama geri, `impact()` tozu). Atışlar arasında **namluyu yağla soğut** (E basılı, 20o); soğuturken surdaki **tüfekçi** (`Gunner.spawn`) nişan alır: sepet siperin arkasına geç ya da yana kay. `walls.field.bombard = true`: bütün hat döver, büyük top komşu bataryada. | 2+ isabet = barikat yarıldı. Soğutmadan doldurursan çatlak (20o: "Tunç sabır ister"). |
| 4a. İftar ve ateşler | Gün batımı | `UI_OBJ32O_IFTAR`, `UI_OBJ32O_FIRES` | Kadri'nin kazanı: oruç açılır (E: hurma ve su; kısa). Kadri **meşale** verir. Siper boyunca **6 ateş/meşale** yak (E); rüzgârda meşale söner, Kadri'nin kazanının ateşinden yeniden yakılır (kısa geri dönüş). Süre: Sultan'ın atının hattın başına varması (~90 sn). Her yanan ateşle tekbir sesi büyür (`Audio.intensity` yerine ordugâh kalabalık sesi). | Hepsi yanmazsa yan bölük yakar; tek fark bir replik. |
| 4b. Sultan | Gece | `UI_OBJ32O_PHOTO` | Sultan ve maiyeti atlı olarak ateşlerin önünden geçer (`Horse`, yürüyen muhafızlar). Bir askerin yol aç uyarısı. Sultan iki cümle söyler (bark, oyuncu durmaz). **Tespit karesi:** ateşlerin arasında Sultan (`TespitCam`, hedef atın üstünde; yalnız geçtiği 20 sn içinde). | Kare kaçarsa dosyada fotoğraf yerine not. |
| 4c. Sükût ve Hasan | Gece yarısı | `UI_OBJ32O_HASAN` | Yeniçeri çavuşu "Sükût!" der: ateşler kısılır (ışıklar söner, ses düşer, yalnız uzaktan çan). Tolga sessiz ordunun arasından Hasan'ın ateşine yürür. Kısa sahne, **3 seçenekli** `hud.choose` (leblebi / su sözü / sus). Seçim `GameState.flags["hasan_night"]` = `leb` / `water` / `sit` olarak yazılır ve 26o'nun ilk Hasan repliğini seçer. | — |

**Sonuçlar**

| Kod | Koşul | Şema | 26o'ya etkisi |
|---|---|---|---|
| **32O.1** Hendek doldu, barikat yarıldı | teslim edilen demet ≥ 6/8 **ve** top isabeti ≥ 2/3 | `FLOW_32O_1` | Normal 26o. |
| **32O.2** Hendek yarım kaldı, gece azaplar bitirdi | aksi hâlde | `FLOW_32O_2` | 26o'nun 1. dalgasında azap bark'ı `D26O_AZ_LATE`; hendek yamaçlarına birkaç dağınık demet. Tarih aynı. |

`--autotest[=late]` (varsayılan 32O.1; `=late`: bot 4 demette durur, 1 isabet).

**Akış şeması** (`UI_FLOW32O_TITLE`): `FLOW32O_HERALD` → `FLOW32O_DITCH` → `FLOW32O_LADDER` → `FLOW32O_GUNS` →
`FLOW32O_LIGHTS` → `FLOW32O_SILENCE` → {`32O.1`, `32O.2`}. Altında `Grade.finish("32o")` ve `UI_CH32O_STATS`.

### 4.4 Replik sırası (konuşanlar)

Konuşanlar mevcut `SPK_` anahtarlarıdır; tek yeni anahtar `SPK_HERALD` (Tellal). Azap 30o'daki yaralıdır (`SPK_AZAP`),
usta Bölüm 18'in Usta Mahmud'udur (`SPK_USTA`), topçu 17o'nun Topçubaşı Ali'sidir (`SPK_TOPCU`), marangoz `SPK_SOLDIER`.
Koşullu replikler: `D32O_S_CARP_LIMP` yalnız 22O.2'de (yoksa `D32O_S_CARP`); `D32O_T_SULTAN` yalnız Bölüm 12 oynandıysa
(`chapter_outcomes.has(12)`), yoksa `_ALT`; `D32O_AZ_HALF` yalnız 32O.2 yolunda; `D32O_AZ_DOWN`, `D32O_T_HIT_*`,
`D32O_U_RUNG_*`, `D32O_TP_HIT/MISS/COOL/GUNNER`, `D32O_T_FIRE_*` olay bark'larıdır. Faz 4c'de seçime göre yalnız bir çift
(`LEB` / `WATER` / `SIT`) söylenir.

| Anahtar | Konuşan |
|---|---|
| `D32O_N_01` | SPK_NIHAT |
| `D32O_K_01` | SPK_KADRI |
| `D32O_T_01` | SPK_TOLGA |
| `D32O_TL_01` | SPK_HERALD |
| `D32O_TL_02` | SPK_HERALD |
| `D32O_TL_03` | SPK_HERALD |
| `D32O_T_02` | SPK_TOLGA |
| `D32O_AZ_01` | SPK_AZAP |
| `D32O_AZ_02` | SPK_AZAP |
| `D32O_T_03` | SPK_TOLGA |
| `D32O_AZ_B1` | SPK_AZAP |
| `D32O_AZ_B3` | SPK_AZAP |
| `D32O_AZ_EARTH` | SPK_AZAP |
| `D32O_AZ_B6` | SPK_AZAP |
| `D32O_AZ_VOLLEY` | SPK_AZAP |
| `D32O_AZ_SAFE` | SPK_AZAP |
| `D32O_T_HIT_1` | SPK_TOLGA |
| `D32O_T_HIT_2` | SPK_TOLGA |
| `D32O_AZ_DOWN` | SPK_AZAP |
| `D32O_T_DITCH` | SPK_TOLGA |
| `D32O_AZ_HALF` | SPK_AZAP |
| `D32O_N_DITCH` | SPK_NIHAT |
| `D32O_U_01` | SPK_USTA |
| `D32O_T_U1` | SPK_TOLGA |
| `D32O_U_02` | SPK_USTA |
| `D32O_U_RUNG_OK` | SPK_USTA |
| `D32O_U_RUNG_BAD` | SPK_USTA |
| `D32O_S_CARP` | SPK_SOLDIER |
| `D32O_S_CARP_LIMP` | SPK_SOLDIER |
| `D32O_U_CARRY` | SPK_USTA |
| `D32O_U_MANTLET` | SPK_USTA |
| `D32O_T_MANTLET` | SPK_TOLGA |
| `D32O_U_END` | SPK_USTA |
| `D32O_TP_01` | SPK_TOPCU |
| `D32O_T_TP1` | SPK_TOLGA |
| `D32O_TP_02` | SPK_TOPCU |
| `D32O_TP_URBAN` | SPK_TOPCU |
| `D32O_TP_HIT_1` | SPK_TOPCU |
| `D32O_TP_HIT_2` | SPK_TOPCU |
| `D32O_TP_MISS` | SPK_TOPCU |
| `D32O_TP_COOL` | SPK_TOPCU |
| `D32O_TP_GUNNER` | SPK_TOPCU |
| `D32O_TP_END_OK` | SPK_TOPCU |
| `D32O_TP_END_BAD` | SPK_TOPCU |
| `D32O_T_GUNS` | SPK_TOLGA |
| `D32O_K_IFTAR` | SPK_KADRI |
| `D32O_T_IFTAR` | SPK_TOLGA |
| `D32O_TL_04` | SPK_HERALD |
| `D32O_T_FIRE_1` | SPK_TOLGA |
| `D32O_T_FIRE_3` | SPK_TOLGA |
| `D32O_T_FIRE_6` | SPK_TOLGA |
| `D32O_N_LIGHTS` | SPK_NIHAT |
| `D32O_S_SULTAN` | SPK_SOLDIER |
| `D32O_F_01` | SPK_FATIH |
| `D32O_F_02` | SPK_FATIH |
| `D32O_T_SULTAN` | SPK_TOLGA |
| `D32O_T_SULTAN_ALT` | SPK_TOLGA |
| `D32O_N_PHOTO` | SPK_NIHAT |
| `D32O_J_SILENCE` | SPK_JANISSARY |
| `D32O_N_SILENCE` | SPK_NIHAT |
| `D32O_H_01` | SPK_HASAN |
| `D32O_T_H1` | SPK_TOLGA |
| `D32O_H_02` | SPK_HASAN |
| `D32O_H_03` | SPK_HASAN |
| `D32O_T_LEB` | SPK_TOLGA |
| `D32O_H_LEB` | SPK_HASAN |
| `D32O_T_WATER` | SPK_TOLGA |
| `D32O_H_WATER` | SPK_HASAN |
| `D32O_T_SIT` | SPK_TOLGA |
| `D32O_H_SIT` | SPK_HASAN |
| `D32O_H_04` | SPK_HASAN |
| `D32O_T_END` | SPK_TOLGA |
| `D32O_H_GO` | SPK_HASAN |
| `D32O_N_END` | SPK_NIHAT |

### 4.5 Metinler (strings.csv'ye yapıştırılmaya hazır)

Başlık, hedef, seçim, şema, dosya ve tarih sayfası satırları:

```csv
UI_CH32O_TITLE,BÖLÜM {N} — SON GÜN,CHAPTER {N} — THE LAST DAY
UI_CH32O_SUB,"28 Mayıs 1453 · Lykos vadisi, hendeğin önü · oruç günü","28 May 1453 · The Lycus valley, before the moat · a day of fasting"
UI_FLOW32O_TITLE,AKIŞ ŞEMASI — BÖLÜM {N}: SON GÜN,FLOWCHART — CHAPTER {N}: THE LAST DAY
SPK_HERALD,Tellal,Herald
UI_OBJ32O_WALK,Tellalın ardından hendeğe in: azap bölükbaşını bul,Follow the herald down to the moat: find the azap captain
UI_OBJ32O_BUNDLE,Yığından çalı demeti al · hendek %d/%d,Take a brushwood bundle from the pile · moat %d/%d
UI_OBJ32O_DROP,Demeti hendeğe at (kıyıda E) · %d/%d,Throw the bundle into the moat (E at the edge) · %d/%d
UI_OBJ32O_EARTH,Demetin üstüne bir sepet toprak dök,Tip a basket of earth over the bundles
UI_OBJ32O_COVER,Ok! Mantonun ya da sepet siperin arkasına geç,Arrows! Get behind a mantlet or a gabion
UI_OBJ32O_RUNG,Merdivene basamak çak (işaret yeşildeyken E) · %d/%d,Nail rungs on the ladder (E while the marker is green) · %d/%d
UI_OBJ32O_LADDER,Merdiveni ekiple hendek kıyısındaki yığına taşı · %d/%d,Carry the ladder with your squad to the pile by the moat · %d/%d
UI_OBJ32O_MANTLET,Mantoyu hendeğin kıyısındaki işarete it (W basılı),Push the mantlet to the mark at the edge of the moat (hold W)
UI_OBJ32O_LOAD,Topu doldur ve barikata nişan al (atış %d/%d),Load the gun and aim at the stockade (shot %d/%d)
UI_OBJ32O_COOL,Namluyu zeytinyağıyla soğut (E basılı) · tüfekçiye dikkat,Cool the barrel with olive oil (hold E) · watch the gunner
UI_OBJ32O_IFTAR,Kadri'nin kazanının başına git: oruç açılıyor,Go to Kadri's pot: the fast is being broken
UI_OBJ32O_FIRES,Meşaleyle hattın ateşlerini yak · %d/%d · Sultan gelmeden,Light the fires along the line with your torch · %d/%d · before the Sultan comes
UI_OBJ32O_PHOTO,Tespit et: ateşlerin arasında Sultan,Record: the Sultan among the fires
UI_OBJ32O_HASAN,Hasan'ın ateşine git,Go to Hasan's fire
UI_C32O_LEB,Cebindeki leblebiyi uzat.,Hold out the roasted chickpeas in your pocket.
UI_C32O_WATER,Matarayı uzat: Yarın da getiririm.,Hold out your flask: I'll bring some tomorrow too.
UI_C32O_SIT,Bir şey söyleme. Otur.,Say nothing. Sit.
FLOW32O_HERALD,Tellal: yarın hücum,The herald: the assault is tomorrow
FLOW32O_DITCH,Hendeğe çalı ve toprak,Brushwood and earth in the moat
FLOW32O_LADDER,Merdiven ve manto,Ladders and mantlets
FLOW32O_GUNS,Barikata son gülleler,The last shots at the stockade
FLOW32O_LIGHTS,Ateşler ve Sultan,The fires and the Sultan
FLOW32O_SILENCE,Sükût: Hasan'la ateş başı,Silence: at the fire with Hasan
FLOW_32O_1,"Hendek doldu, barikat yarıldı","Moat filled, stockade split"
FLOW_32O_2,"Hendek yarım kaldı, gece azaplar bitirdi",Moat half done; the azaps finished it at night
UI_CH32O_STATS,Demet: %d/%d   ·   İsabet: %d/%d   ·   Ok: %d   ·   Dosya: %d/%d sayfa,Bundles: %d/%d   ·   Hits: %d/%d   ·   Arrows: %d   ·   File: %d/%d pages
SIEGE_DATE_32,28 Mayıs 1453,28 May 1453
SIEGE_EV_32,"Hücumdan önceki gün: ordu oruç tutar ve dinlenir, ama hendek doldurulur, merdivenler hazırlanır, toplar surları döver. Gece ordugâh ışıklanır, sonra susar.","The day before the assault: the army fasts and rests, yet the moat is filled, ladders made ready and the guns keep pounding the walls. At night the camp is lit, then falls silent."
SIEGE_NOTE_32O_1,"Oruç günü. Hendeğe çalı ve toprak taşındı, merdivenler çakıldı, barikat yarıldı. Gece ateşler yandı, sonra ordu sustu. Hasarın tersi: yol yapıldı. — T.","A day of fasting. Brushwood and earth went into the moat, ladders were nailed, the stockade was split. At night the fires burned, then the army fell silent. The opposite of damage: a road was built. — T."
SIEGE_NOTE_32O_2,"Oruç günü. Hendek yarım kaldı, gece azaplar tamamladı; barikat dayandı. Ateşler yandı, ordu sustu. Not: dinlenme günü diye bir şey yok. — T.","A day of fasting. The moat was half filled and the azaps finished it at night; the stockade held. The fires burned, the army fell silent. Note: there is no such thing as a day of rest. — T."
LORE_32O_1_T,Oruç ve dinlenme günü,A day of fasting and rest
LORE_32O_1,"Hücum kararından sonra Sultan 28 Mayıs'ı oruç, dua ve dinlenme günü ilan etti. Dinlenme askerin içindi; hendekte, bataryalarda ve marangozların yanında iş akşama kadar sürdü.","After the decision to attack, the Sultan declared 28 May a day of fasting, prayer and rest. The rest was for the soldiers; at the moat, in the batteries and among the carpenters work went on until evening."
LORE_32O_2_T,Hendeği doldurmak,Filling the moat
LORE_32O_2,"Kara surlarının önündeki hendek yirmi metreye yakın genişlikteydi. Osmanlılar haftalar boyunca içine çalı demetleri, toprak, taş ve kütük attı; son günlerde iş hızlandı. Savunucular geceleri bir kısmını yakıp temizledi.","The moat in front of the land walls was nearly twenty metres wide. For weeks the Ottomans threw brushwood bundles, earth, stones and logs into it, faster in the last days. At night the defenders burned and cleared some of it."
LORE_32O_3_T,Işıklar ve sükût,The lights and the silence
LORE_32O_3,"Hücumdan önceki gecelerde ordugâh baştan uca ateş ve meşaleyle aydınlandı, tekbir sesleri surlara kadar ulaştı; surdakiler önce kampın yandığını sandı. 28 Mayıs gecesi ise ordu sustu ve karanlıkta yerine geçti. Şehirde çanlar çalıyordu.",On the nights before the assault the camp was lit end to end with fires and torches and the cries of the tekbir reached the walls; the defenders first thought the camp was on fire. On the night of 28 May the army fell silent and took up its positions in the dark. In the city the bells were ringing.
```

Replikler:

```csv
D32O_N_01,"Günaydın Tolga Bey. 28 Mayıs, pazartesi. Kayıtta oruç ve dinlenme günü yazıyor. Altına biri kurşun kalemle kâğıt üstünde diye eklemiş.","Good morning, Mr Tolga. 28 May, a Monday. The record says a day of fasting and rest. Someone has pencilled underneath: on paper."
D32O_K_01,"Yamak! Bugün mutfak kapalı, ordu oruçlu. Sen de hendeğe. Bu benim emrim değil, Sultan'ın.","Kitchen boy! The kitchen's closed today, the army is fasting. You're off to the moat. Not my order, the Sultan's."
D32O_T_01,"Dün şerbet, bugün hendek. Bu ordugâhta terfi aşağı doğru oluyor.","Yesterday sherbet, today the moat. In this camp promotions go downwards."
D32O_TL_01,Duyduk duymadık demeyin! Yarın şafaktan önce karadan ve denizden hücum var!,"Hear ye, and say not you did not hear! Tomorrow before dawn, the assault, by land and by sea!"
D32O_TL_02,"Bugün oruç tutulsun, abdest alınsın, silah bilensin! Akşam ateşler yansın, gece ses kesilsin!","Today let the fast be kept, the ablutions made, the blades sharpened! At evening let the fires burn; at night let every voice be still!"
D32O_TL_03,Sura ilk çıkana dirlik ve rütbe! Sultan'ın sözüdür!,"To the first man on the wall, a fief and rank! The Sultan's word!"
D32O_T_02,Tellal. Bizim şirkette bunun adı herkese giden e-posta. Herkese yanıtla tuşuna basılmaz.,A herald. At my company we call this an all-staff email. You do not press reply-all.
D32O_AZ_01,Kâtip! Blakherna'da beni sırtında taşıyan sen değil miydin? Bacak iyileşmedi ama demet taşımaya yeter.,"Clerk! Weren't you the one who carried me on your back at Blachernae? The leg hasn't healed, but it'll do for bundles."
D32O_AZ_02,"İş basit: yığından demet al, hendeğe at. İki demette bir sepet toprak, yoksa gece yakarlar. Surdan ok gelirse mantonun arkasına.","The job is simple: take a bundle from the pile, throw it in the moat. A basket of earth every two bundles, or they burn it at night. If arrows come from the wall, get behind the mantlet."
D32O_T_03,Sigortada buna zemin iyileştirme denir. Burada prim okla ödeniyor.,In insurance we call this ground improvement. Here the premium is paid in arrows.
D32O_AZ_B1,Bir. Hendek derin; dibini görmesek iyi.,One. The moat is deep; better if we never see the bottom.
D32O_AZ_B3,"Üç! Sağdaki bölük de yetişti, bak. Bütün ova taşıyor.","Three! The company on the right has caught up, look. The whole plain is carrying."
D32O_AZ_EARTH,Toprak! Demetin üstüne toprak; çalı yalnız kalırsa Rum ateşi onu sever.,Earth! Earth on the bundles; brushwood left bare is just what Greek fire loves.
D32O_AZ_B6,Altı. Yarın burada yürüyerek geçeceğiz; ayağımızın altında bu sabah olacak.,Six. Tomorrow we walk across here; this morning will be under our feet.
D32O_AZ_VOLLEY,Ok! Mantoya! Mantonun arkasına!,Arrows! The mantlet! Behind the mantlet!
D32O_AZ_SAFE,"Geçti. Demetini al, yürü.","It's passed. Pick up your bundle, move."
D32O_T_HIT_1,Ah! Demete saplandı. Demete. İyi ki demet büyükmüş.,Ow! It stuck in the bundle. The bundle. Good thing the bundle's big.
D32O_T_HIT_2,Bu sefer omzum. Poliçede iş kazası maddesi... poliçe yok. Tamam.,My shoulder this time. The policy's workplace accident clause... there is no policy. Right.
D32O_AZ_DOWN,"Kâtip! Kalk! Demeti bırak, seni ben taşırım. Sıra bende.","Clerk! Up! Drop the bundle, I'll carry you. My turn."
D32O_T_DITCH,Bir ayda kazdıkları hendek bir sabahta doldu. Hasarın tersine ne denir? Formda kutucuğu yok.,"A moat they dug over months, filled in a morning. What's the opposite of damage? There's no box for it on the form."
D32O_AZ_HALF,"Yarım kaldı. Olsun, gece biz bitiririz. Azap dediğin karanlıkta da taşır.","Half done. Never mind, we'll finish it tonight. An azap carries in the dark too."
D32O_N_DITCH,"Kaydedildi. Kaynaklar hücumdan önce hendeğin çalı, toprak ve taşla doldurulduğunu yazar. Ellerinizdeki dikenler kayda girmez, Tolga Bey.","Recorded. The sources say the moat was filled with brushwood, earth and stones before the assault. The thorns in your hands don't go into the record, Mr Tolga."
D32O_U_01,"Köprünün yamağı! Fıçı bağlamayı öğrenmiştin, şimdi basamak çakmayı öğren. Yarın çok merdiven lazım.",The bridge lad! You learned to lash barrels; now learn to nail rungs. Tomorrow we need a great many ladders.
D32O_T_U1,"Usta, köprüden merdivene. Yatay işten dikey işe geçiyoruz.","Master, from bridges to ladders. We're moving from horizontal work to vertical."
D32O_U_02,Çivi tam ortaya. Basamak oynarsa adam düşer; adam düşerse merdiven kötü ad alır.,Nail dead centre. A loose rung drops a man; a man drops and the ladder gets a bad name.
D32O_U_RUNG_OK,"İyi. Bunu bir yeniçeri taşır, yüzü kızarmaz.",Good. A Janissary can carry that without blushing.
D32O_U_RUNG_BAD,"Eğri! Sök, yeniden çak. Yarın biri bunun üstünde dua edecek.","Crooked! Pull it out, nail it again. Tomorrow someone will be praying on this."
D32O_S_CARP,"Kâtip! Kule gecesinde merdiveni tutan sendin. Bunu da tut bakalım, sağlam mı?","Clerk! You were holding the ladder the night of the tower. Hold this one too, is it sound?"
D32O_S_CARP_LIMP,"Hasan beni sırtında indirdi, sen merdiveni tuttun. Topallıyorum ama çakıyorum.","Hasan carried me down on his back and you held the ladder. I'm limping, but I'm nailing."
D32O_U_CARRY,Dört kişi bir merdiven. Sen öndesin; senin bastığın yere onlar da basar.,"Four men to a ladder. You're in front; where you step, they step."
D32O_U_MANTLET,"Şimdi manto. Tekerlekli perde: hendeğin kıyısına it, orada kalsın. Yarın okçular arkasına girecek.",Now the mantlet. A screen on wheels: push it to the edge of the moat and leave it. Tomorrow the archers get behind it.
D32O_T_MANTLET,"Seyyar siper. Bizim otoparkta da böyle bir şey vardı; adı bariyerdi, ok tutmazdı.",A mobile screen. We had something like this in our car park; it was called a barrier and it didn't stop arrows.
D32O_U_END,"Merdivenler yığında, mantolar yerinde. Gerisi topçunun, sonra Allah'ın.","The ladders are stacked, the mantlets in place. The rest is up to the gunners, then to God."
D32O_TP_01,"Fesli yamak! Haliç'te itfaiyeci olmuştun, hatırladın mı? Bugün yine topçusun.","The lad in the fez! You turned firefighter on the Horn, remember? Today you're a gunner again."
D32O_T_TP1,Topçubaşı! Sizi Haliç'te bırakmıştım. Siz de mi karaya çıktınız?,Master gunner! I left you on the Horn. You've come ashore too?
D32O_TP_02,"Donanma yarın denizden yüklenecek, bizim yerimiz burası. Hedef şu: gedikteki barikat. Gece fıçıyla toprakla örerler, gündüz biz sökeriz.","The fleet attacks from the sea tomorrow; our place is here. The target: the stockade in the breach. They build it with barrels and earth by night, we take it apart by day."
D32O_TP_URBAN,"Usta Urban'ın büyük topu öbür bataryada konuşuyor. Bu onun küçük kardeşi; daha az konuşur, daha çok dinler.",Master Urban's great gun is talking at the next battery. This is its little brother; it talks less and listens more.
D32O_TP_HIT_1,İsabet! Fıçılar dağıldı!,A hit! The barrels are scattered!
D32O_TP_HIT_2,Bir daha! Kalaslar uçuyor! Barikat yarıldı!,Again! The planks are flying! The stockade's split!
D32O_TP_MISS,"Uzun düştü, iç sura gitti. Namluyu bir parmak indir.","Long, it went to the inner wall. Bring the barrel down a finger."
D32O_TP_COOL,Yağ! Namlu kızgın. Urban'ın dersi: tunç sabır ister.,Oil! The barrel's hot. Urban's lesson: bronze wants patience.
D32O_TP_GUNNER,Surda tüfekçi! Namlu soğurken sepet siperin arkasına geç!,"A gunner on the wall! While the barrel cools, get behind the gabions!"
D32O_TP_END_OK,Barikat yarık. Bu gece yine örerler ama ancak yarısını. Yarına yetiştiremezler.,"The stockade's split. They'll rebuild it tonight, but only half. They won't finish by tomorrow."
D32O_TP_END_BAD,Barikat ayakta. Olsun: topçunun bittiği yerde yeniçeri başlar.,"The stockade stands. Never mind: where the gunner stops, the Janissary starts."
D32O_T_GUNS,"Kırk sekiz gündür bu ses. Yarın susacak. Hangisi daha korkunç, bilemiyorum.",Forty-eight days of this sound. Tomorrow it stops. I can't tell which is more frightening.
D32O_K_IFTAR,"Güneş battı! Oruç açılır! Kâtip, bir hurma, bir yudum su. Sonra şu meşaleyi al; bu gece ateş istiyorlar.","The sun is down! Break the fast! Clerk, a date, a sip of water. Then take this torch; tonight they want fire."
D32O_T_IFTAR,"Bütün gün tek lokma yemeden hendek doldurdum. Bunu sigortacıma değil, diyetisyenime anlatmalıyım.","I filled a moat all day without a bite. I should tell my dietitian about this, not my insurer."
D32O_TL_04,"Ateşler yansın! Her çadırın önünde meşale, her bölüğün başında ateş!","Light the fires! A torch before every tent, a fire at the head of every company!"
D32O_T_FIRE_1,Bir. Ateş yakmak kolay iş sanmıştım. Rüzgâr başka düşünüyor.,One. I thought lighting a fire was easy. The wind has other ideas.
D32O_T_FIRE_3,Üç. Karşı surdan bakan biri şimdi ne görüyor acaba?,Three. I wonder what someone on the walls opposite sees right now.
D32O_T_FIRE_6,Altı. Bütün sırt yanıyor. Tekbir sesi ovadan surlara kadar gidiyor.,Six. The whole ridge is burning. The tekbir carries across the plain to the walls.
D32O_N_LIGHTS,"Kaynaklar bu ışıkları yazar Tolga Bey: surdakiler önce ordugâhın yandığını sandı. Şimdi bakın, Sultan geliyor.","The sources describe these lights, Mr Tolga: the men on the walls first thought the camp was on fire. Now look, the Sultan is coming."
D32O_S_SULTAN,Sultan! Hatları dolaşıyor! Yol açın!,The Sultan! He's riding the lines! Make way!
D32O_F_01,"Gaziler! Yarın emirle yürüyün, emirle durun. Düzen bozulursa hücum biter.","Warriors! Tomorrow you advance on the order and halt on the order. If the ranks break, the assault is over."
D32O_F_02,"Bu gece ateşler yansın; sonra ses kesilsin. Yarın sessiz yürüyen, gürültüyle girer.",Let the fires burn tonight; then let all be silent. Whoever marches silently tomorrow will enter with a roar.
D32O_T_SULTAN,Bir ay önce otağında karşısındaydım. Şimdi ateşlerin arasından geçiyor ve beni görmüyor. İyi ki görmüyor.,A month ago I stood before him in his tent. Now he rides between the fires and doesn't see me. Just as well.
D32O_T_SULTAN_ALT,Kaftanı ateşlerin ışığında kırmızı. Yanından geçen at bile susuyor.,His kaftan is red in the firelight. Even the horse beside him is quiet.
D32O_N_PHOTO,Kaydedildi. Sultan objektife bakmadı. Bürokrasi açısından en temiz poz budur.,"Recorded. The Sultan didn't look at the lens. Bureaucratically speaking, that's the cleanest pose there is."
D32O_J_SILENCE,"Sükût! Ateşler kısılsın, ses kesilsin! Herkes bölüğüne!","Silence! Bank the fires, still your voices! Every man to his company!"
D32O_N_SILENCE,"Bütün ordu bir anda sustu, Tolga Bey. Surdakiler şimdi bu sessizliği dinliyor. Hasan sizi bekliyor.","The whole army fell silent at once, Mr Tolga. The men on the walls are listening to that silence now. Hasan is waiting for you."
D32O_H_01,"Gel kâtip, otur. Ateşin dibi sıcak, gerisi soğuk.","Come, clerk, sit. It's warm by the fire, cold everywhere else."
D32O_T_H1,"Hendek doldurdum, merdiven çaktım, top doldurdum. Bugün dinlenme günüydü, değil mi?","I filled a moat, nailed ladders, loaded a gun. Today was the day of rest, wasn't it?"
D32O_H_02,Dinlenme günü savaşın en yorucu günüdür. Yarın yorulmaya vakit yok.,The day of rest is the most tiring day of a war. Tomorrow there's no time to be tired.
D32O_H_03,Yarın biz yeniçeriler son dalgayız. Sancak bende. Son dalga ya girer ya bir daha kalkmaz.,Tomorrow we Janissaries are the last wave. I have the banner. The last wave either gets in or never gets up again.
D32O_T_LEB,"Al. Benim zamanımda bunu maçta yerler. Tribünde, gergin anlarda.","Here. In my time people eat these at football matches. In the stands, in the tense moments."
D32O_H_LEB,"(Bir tane alır.) Tuzlu. Anam da kavururdu. Gergin anlar için, ha? İyi düşünmüşler.","(Takes one.) Salty. My mother used to roast these. For tense moments, eh? Clever people."
D32O_T_WATER,"Su. Oruç açıldı, iç. Yarın da getiririm. Söz.","Water. The fast is over, drink. I'll bring some tomorrow too. I promise."
D32O_H_WATER,(İçer.) Yarın getirirsen yarın da içerim. Anlaştık kâtip; yaz bunu.,"(Drinks.) If you bring it tomorrow, I'll drink it tomorrow. That's a deal, clerk; write it down."
D32O_T_SIT,"(Tolga bir şey söylemez. Ateş çıtırdar. Uzakta, şehirde çanlar.)","(Tolga says nothing. The fire crackles. Far off, bells in the city.)"
D32O_H_SIT,"İyi ki konuşmadın. Bu gece herkes çok konuştu, sonra hepsi birden sustu.","Good thing you didn't talk. Everyone talked too much tonight, then all of them went quiet at once."
D32O_H_04,Duyuyor musun? Şehirde çanlar. Onlar da uyumuyor. Allah hepimize kolaylık versin.,Hear that? Bells in the city. They're not sleeping either. May God make it easy for all of us.
D32O_T_END,"Surun iki yanında iki gece. Birinde çan, birinde sükût. Yarın biri bitecek.","Two nights on either side of the wall. Bells on one, silence on the other. Tomorrow one of them ends."
D32O_H_GO,"Bölüğüm çağırıyor. Şafakta hendeğin kıyısındayım, kâtip. Kovayla gel.","My company's calling. At dawn I'll be on the edge of the moat, clerk. Come with a bucket."
D32O_N_END,"Kaydedildi. 28 Mayıs, Osmanlı nüshası. Gece yarısı geçti. Bir buçukta son hücum; siz sakasınız. Kovanız hazır.","Recorded. 28 May, the Ottoman copy. Midnight has passed. At half past one, the final assault; you're the water carrier. Your bucket is ready."
```

Önceki/sırada satırları (`UI_RECAP_32O_PREV/NEXT`) §3'teki blokta.

### 4.6 Hasar Tespit Dosyası

`Siege.record(32, photo, "SIEGE_NOTE_32O_1" | "SIEGE_NOTE_32O_2")`. Sayfa başlığı `SIEGE_DATE_32` / `SIEGE_EV_32`
(yukarıdaki blokta). Tespit karesi `siege32`: ateşlerin arasında Sultan. Kare kaçarsa fotoğraf yerine 25'teki gibi not.
Başarım önerisi: `ACH_OSM_LASTDAY` (32o'da hiç ok yemeden 8 demet).

### 4.7 Devir: 25 → 32o → 26o

**25'in Osmanlı dalı** (`chapter25.gd` `_run`): `_lights()`'tan sonra `_vigil()` artık çağrılmaz; ateş başı sahnesi
32o'nun 4c fazına taşınır (`D25O_H_*` emekliye ayrılır ya da 32o'da yedek olarak kalır). 25 Osmanlı tarafında 27 Mayıs'ın
meclisiyle ve kandil fotoğrafıyla biter, son replik `D25O_N_HANDOFF`'tur. Açılıştaki `D25_N_01` Osmanlı tarafında
`D25O_N_01` ile değişir. `FLOW25O_VIGIL` düğümü 25'in şemasından kalkar (32o'da `FLOW32O_SILENCE` var). Dosya notları
`SIEGE_NOTE_25O_1/2` yalnız 27 Mayıs'ı anlatacak şekilde güncellenir.

**32o'nun sonu → 26o'nun açılışı:** 32o, Hasan'ın "Şafakta hendeğin kıyısındayım, kâtip. Kovayla gel." repliği ve
Nihat'ın "Bir buçukta son hücum; siz sakasınız. Kovanız hazır." kaydıyla biter. 26o şimdi `D26O_N_01` ("son sayfa…
saka olacaksınız") ve `D26O_T_01` ile açılıyor; saka rolü böylece 32o'da hazırlanmış olur. Değişecekler:
- `D26O_N_01` → "kuşatmanın son gecesi" (aşağıda).
- `D26O_H_01` ("Kule gecesinden beri görmedim seni") → `hasan_night` bayrağına göre `D26O_H_01_WATER` / `_LEB` / `_SIT`.
  `D26O_T_02` ("Hasan… Sen de mi gidiyorsun?") ve `D26O_H_02` olduğu gibi kalır.
- 32O.2 yolunda 1. dalgada `D26O_AZ_LATE`.
- 32o'da itilen manto 26o'nun su fazında siper olarak aynı yerde durur; merdiven yığını 32o'da taşınanlardır.

```csv
D25O_N_01,"Bu akşam tek kayıt var, Tolga Bey: ordugâhta meclis toplanıyor. Siz mutfaktasınız. Sessiz tanık, sessiz yamak.","There's one entry tonight, Mr Tolga: the council meets in the camp. You're in the kitchen. A silent witness, a silent kitchen boy."
D25O_N_HANDOFF,"Kaydedildi. Karar: yarın oruç ve dinlenme. Ordunun dinlenmesi kazma kürek demek, Tolga Bey. Sabah hendekte görüşürüz.","Recorded. The decision: tomorrow, fasting and rest. For an army, rest means picks and shovels, Mr Tolga. See you at the moat in the morning."
SIEGE_NOTE_25O_1,"27 Mayıs: otağda meclis sonuna kadar dinlendi. Çandarlı barış, Zağanos hücum dedi; Sultan hücum dedi. Ordugâh kandillerle aydınlandı. — T.","27 May: the council in the Sultan's tent was heard to the end. Çandarlı said peace, Zaganos said assault; the Sultan said assault. The camp was lit with lamps. — T."
SIEGE_NOTE_25O_2,27 Mayıs: meclisin sonu kaçtı (nöbetçiler). Kararı ordugâhın ışıklarından okudum: hücum. — T.,27 May: I missed the end of the council (the guards). I read the decision in the camp's lights: assault. — T.
D26O_N_01,"Tolga Bey, kuşatmanın son gecesi. Bizans nüshası bu gece surun içinden yazılır, sizinki dışından. Sakasınız. Kimse sakaya ok atmaz derler; derler.","Mr Tolga, the last night of the siege. The Byzantine copy writes it from inside the wall, yours from outside. You carry the water. They say nobody shoots at the water carrier; they say."
D26O_H_01_WATER,Kâtip! Kova elinde. Dün gece söz vermiştin; tuttun.,Clerk! Bucket in hand. You promised last night; you kept it.
D26O_H_01_LEB,"Kâtip! Leblebin bitti, cebimde bir tane kaldı. Gergin an için sakladım.",Clerk! Your chickpeas are gone; I kept one in my pocket. Saved it for the tense moment.
D26O_H_01_SIT,"Kâtip. Dün gece konuşmadın; şimdi de konuşma. Su ver, yeter.","Clerk. You didn't talk last night; don't talk now. Give me water, that's enough."
D26O_AZ_LATE,"Hendeği gece biz bitirdik, kâtip! Yamuk ama dolu. Bas geç!","We finished the moat in the night, clerk! Crooked, but full. Step on it and go!"
```

---

## 5. Osmanlı tarafı için öncelikli iyileştirmeler

Hepsi mevcut sistemlerle yapılabilir (`scripts/combat`, `scripts/level`, `scripts/ui`).

1. **32o Son Gün** (§4). Kullanıcının şikâyetinin doğrudan cevabı: hazırlık, surlara top ateşi, hikâye bağı.
2. **25 Son Akşam, Osmanlı dalı:** ateş başı 32o'ya taşınır (§4.7). Tepsi yürüyüşü **`BalanceMeter`** ile oynanır:
   kalabalık ordugâhta, kandiller arasında şerbet bardakları devrilmeden (Bölüm 4b'deki denge göstergesi). Gizlilik fazına
   ikinci bir dinleme noktası ve nöbetçilerin fener ışığı eklenir: nöbetçinin ışık konisi (`_seen` zaten açıya bakıyor) yere
   çizilir, oyuncu çadır iplerinin gölgesinde bekler.
3. **23 Elçi, Osmanlı dalı:** heyetle **ölü bölgeyi beyaz bayrakla geçmek** (`SiegeField` + `LandWalls`, 30 sn yürüyüş;
   surdaki okçular nişan alır ama atmaz, `Gunner` uyarısı ateşsiz), kapıda **tezkireyi göster** (eşya gösterme), dönüşte
   at üstündeki İsmail Hamza'ya İmparator'un cümlesini **süreli seçimle** aktarma. `D23O_TH_01` (§2.1).
4. **24o Alametler:** çorba kazanı **`BalanceMeter`** ile karanlıkta taşınır (ay karardıkça görüş düşer); fırtınada
   **dolu yaylımı** `Assault.volley` ve 22o'nun "Siper!" kuralıyla (çadır saçağının altı siper sayılır). 19o'nun 23 Mayıs
   kovalamacası buraya taşınabilir (§2.1, seçenek A).
5. **18 Fıçı Köprü:** Haliç surundan küçük top ateşi (18b'nin aynası): Bizans topu dolarken duman görünür, işçiler kalas
   yığınının arkasına geçer (`LandWalls.impact` benzeri su sıçraması); 18b'deki geri tepme anısına bir isabet bir fıçı
   çiftini koparır, Tolga **yeniden bağlar** (mevcut halat zamanlaması). Gerilim ve iki tarafın bağı.
6. **26o Şafak:** açılışa **sessiz yürüyüş**: 32o'daki merdivenlerden birini ekipçe (30o taşıma) karanlıkta hendeğe
   indirmek; konuşma yok, yalnız mehterin başlaması. 32o'da itilen manto su fazında siper.
7. **20o Gedik:** atışlardan önce **sepet siperi onarmak** (`SiegeField.gabion`): gece Bizans okçularının dağıttığı
   iki sepeti toprakla doldur (22o sepet döngüsü), ardından top. Akşam fazında `WallFight` onarım ekibinin gediği ördüğü
   görülür (zaten var) ve 20o'nun sonunda Urban'ın Tolga'yı Zağanos'a göndermesi (§2.1).
8. **17o Kundak:** suya düşen Venedikli denizcileri **kayıkla çekmek** (17'nin Bizans tarafındaki kurtarma döngüsünün
   aynası, `RowMeter`). Tarih notu (saygıyla, gösterilmeden): **B**'ye göre yakalanan denizciler ertesi gün surların önünde
   öldürüldü, şehirde de Osmanlı esirleri öldürüldü; Nihat'ın bir cümleyle anması yeterli.
9. **28o İlk Atış:** 6 Nisan'da kazıklardan önce **siper kazmak** (21o'daki kaz: E basılı, kürek ve sepet); Büro satırı
   düzeltmesi (§2.1).
10. **27 Ahitname, Osmanlı yolu:** 10G'yi görmemiş oyuncu için tanışma replikleri; rıhtımda kalabalıkta bir çocuğu
    annesine götürmek (`Walker`, `Crowd`) gibi küçük bir el işi.
11. **Genel:** (a) Tolga'nın örtüsü (ruznâmeci + tezkire, §2.2). (b) Osmanlı dosya sayfaları için ayrı başlık anahtarları
    (`SIEGE_DATE_20O` "7 Mayıs 1453, gündüz", `SIEGE_EV_20O`, `SIEGE_DATE_24O` "22–24 Mayıs 1453"…); şimdi Osmanlı
    oyuncusu 20o'nun sayfasında "gediğin gece kapatılması" okuyor. `Siege.show_page` tarafa göre `_O` ekli anahtarı
    önce denesin. (c) Eski numaralı sonuç düğümleri (`FLOW_20O_1` = "16O.1 …") numarasız yapılmalı. (d) Arka planda
    sürekli bombardıman (`SiegeField.bombard`) 21o, 22o, 24o, 25'te.
