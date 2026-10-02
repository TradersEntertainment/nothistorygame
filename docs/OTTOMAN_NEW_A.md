# Osmanlı Tarafı · Kuşatmadan Önce: dört yeni bölüm (33o–36o) · v0.2

Bu belge `docs/OTTOMAN_STORY.md`'nin devamıdır. Kullanıcıya göre Osmanlı tarafında 5–10 bölüm eksik: nüsha **6 Nisan'da
kazıkla** açılıyor. Hisar, top, yol ve ilk hücum hiç oynanmıyor. Burada bu boşluğu dolduran **dört yeni bölüm** var:
kuşatmadan önceki yıl ve kuşatmanın ilk haftası. Biçim OTTOMAN_STORY §4 ile aynı.

İlkeler aynı: *tarih inatçıdır*, Tolga sonucu değil insanları değiştirir, Kerkoporta rivayeti yok, NPC'ler "Büro"yu
bilmez. Büro'yu yalnız Nihat telsizde anar.

**v0.2: kullanıcının ek şartları.** Her bölüm bunlara göre yazıldı:
1. **Oynanış:**
   - Her bölümde başarısızlığı ve baskısı olan **en az iki gerilimli mekanik** var: tırmanma, top, düello, tüfek,
     kovalamaca, denge, kaçılacak tehlike, kürek yarışı.
   - Taşıma ya yok ya kısa ve bir bükümü var (denge, zamanlama, tehlike).
   - Durarak konuşma (`hud.say`) oyun süresinin **%25'ini geçmez**. Konuşmanın çoğu oyun akarken bark (`hud.bark`).
     Her bölümün konuşan tablosunda **say / bark** sütunu var.
2. **Görsellik:** Her fazın sonunda bir **"Animasyon ve görsel geri bildirim"** listesi var. Oyuncunun gördüğü her şey
   orada yazılı:
   - İp A'dan B'ye gerçekten uzanır ve düğüm görünür.
   - Çıkrık döner. Öküz yürür ve ip gerilir.
   - Aynı işi yapan NPC'ler o işin hareketini yapar.
   - Kırılan şey parçalanır. İsabetin geri bildirimi var.
   - **Zemin ve yükseklik tutarlılığı** her fazda ayrıca belirtildi: geçmişte askerlerin yerin altından çıkması ve
     ipin görünmemesi gibi hatalar oldu.

Kaynak kısaltmaları: **R** Runciman (*The Fall of Constantinople 1453*), **K** Kritovoulos, **B** Barbaro'nun günlüğü,
**D** Doukas, **S** Sphrantzes, **TB** Tursun Bey, **AP** Aşıkpaşazade. Kesin olmayan ya da sonraki anlatılara dayanan
ayrıntılar **(rivayet)** diye işaretlidir. Rakamlar (öküz, adam, menzil, ölü sayısı) kaynağın kendi rakamıdır ve öyle
söylenir.

---

## 0. Seçim, kimlikler, sıra

### 0.1 Seçilen dört bölüm

| İç id | Sahne | Başlık | Tarih | Gerilimli mekanikler |
|---|---|---|---|---|
| **33** | `chapter33o` | Boğazkesen | 31 Ağustos ve 26 Kasım 1452 | İskelede **serbest tırmanış** (çöken kalaslar, yukarıdan düşen kovalar). **Çıkrık ve denge** (sallanan taş). Akıntıya karşı **kürek** (kayalar). **Yuvarlanan gövdede ip merdiven.** Hareketli hedefe **elle top** (75 sn). |
| **34** | `chapter34o` | Tuncun Sesi | Ocak 1453, Edirne | **İki çıkrıkla eş zamanlı kaldırma** (eğim, mandal). **Kaçak gülle kovalamacası.** Buzda **kızaklı çocuk kovalamacası.** **Ateş almayan top** (bekle, yeniden falya, kaç). |
| **35** | `chapter35o` | Edirne Yolu | Şubat–Mart 1453, Trakya | Taşkın derenin üstünde **kirişte denge** (kütükleri sırıkla it). **Hey-yap ve kopan halat.** Yokuşta **fren ipi** (kaçan araba). Gece **ürken öküzleri kovalamak.** |
| **36** | `chapter36o` | İlk Hücum | 18 Nisan 1453 gecesi | **Ok yaylımı ve ateş çömlekleri.** **Kanca at ve çek, yuvarlanan fıçıdan kaç.** **Meşale atışı.** **Moloz yamacında düello** (WaveRunner + Gunner). |

**Neden bu dört:**
- **33** kuşatmanın gerçek başlangıcıdır. Hisar biter, Boğaz kapanır, Rizzo'nun gemisi Urban'ın **ilk** topuyla batar
  (**D**). Urban'ın ipi buradan başlar.
- **34**'te büyük top kalıptan çıkar ve Sultan'ın önünde denenir (**D**). Tolga'nın mesleği ilk kez gerçekten işe
  yarar: kalite kontrol.
- **35** topun iki aylık yolculuğudur (**D**). 28o'daki "Altmış öküz bunu Edirne'den getirdi" cümlesi oynanmış olur.
- **36** barikata ilk büyük gece hücumudur (**B**, **R**). SIEGE.md §1'de "—" olarak duruyordu. 28o ile 29o arasındaki
  boşluğu kapatır. Yeni fiiller getirir: kancayla fıçı indirmek, meşale atmak.

**Seçilmeyenler:**
- **22 Nisan gemilerin karadan yürütülmesi:** Bölüm 2 "Yağlı Kızaklar"da Tolga zaten bu yokuştadır, `Slipway` bu
  sahnenin kendisidir. 17o'nun "önceki bölümde" satırı bunu söylüyor.
- **Therapia, Studios ve Prinkipo:** Üçü de teslim olan ya da yakılan garnizonların öldürülmesiyle biter
  (**K**, **R**). Oynanış merkezine konamaz. 36o'da Nihat bir cümleyle anar.
- **Ordunun gelişi ve otağ (2–5 Nisan):** 28o'nun 6 Nisan kazık fazına çok yakın. 35o'nun sonu ve 28o'nun açılışı
  bunu söyler.
- **Urban'ın dökümünün kendisi:** Fırın ve potalar 10B "Büyük Atış"ta güç çubuğuyla oynanıyor. 34o dökümden
  **sonrasını** oynatır.

### 0.2 Siege.ORDER

```gdscript
const ORDER := [33, 34, 35, 28, 36, 29, 17, 18, 19, 20, 30, 21, 22, 23, 24, 25, 32, 26, 31, 27]
```

- **Yer:** 33, 34 ve 35 28o'dan önce gelir. 36 28 ile 29 arasına girer.
- **Bizans tarafı etkilenmez:** Dördünün de yalnız `chapterNo.tscn` sahnesi vardır. Bizans tarafı onları `_plays()`
  ile atlar.
- **Yorum satırı:** `siege.gd`'deki ORDER yorumuna eklenir: "33 (Ağustos–Kasım 1452, Boğazkesen), 34 (Ocak 1453,
  Edirne), 35 (Şubat–Mart 1453, yol), 36 (18 Nisan, ilk hücum)".
- **Ekran numaraları** `{N}` ile kendiliğinden kayar (Osmanlı): 33o → 13, 34o → 14, 35o → 15, 28o → 16, 36o → 17,
  29o → 18, …, 26o → 30, 27 → 31. Kuşatmadan sonraki 13/14/15 dört numara ileri gider.
- **Sonuç düğümleri:** Yeni bölümlerinkiler **numarasız** yazıldı (OTTOMAN_STORY §1 notu). Eski numaralı düğümlerin
  sorunu dört numara daha büyür.
- **Tarih Defteri:** `Lore.PAGES`'e `"33o": 3, "34o": 3, "35o": 3, "36o": 3` girdileri eklenir.
- **Savaş karnesi:** `Grade.finish("36o")` çağrılır. 36o, "Ayakta" başarımının (`ACH_FLAWLESS`) savaş bölümleri
  listesine eklenir.
- **SIEGE.md §1:**
  - "18 Nisan" satırının "Oyunda" sütunu **Bölüm 36o** olur.
  - Tablonun başına iki satır eklenir: "Nisan–Ağustos 1452: Boğazkesen | 33o" ve "Ocak–Mart 1453: büyük top, deneme
    atışı, yol | 34o, 35o".

### 0.3 Büro önsözü ve 28o'nun değişen açılışı

Osmanlı tarafında ilk bölüm artık 33'tür. `chapter17.gd` `D17_N_FIRST_%d` anahtarını kullandığı için kod değişmez,
yalnız yeni anahtar eklenir. `D17_N_FIRST_28` Osmanlı tarafında artık söylenmez (silinmez, yedekte kalır).

```csv
D17_N_FIRST_33,"Bir düzeltme, Tolga Bey: Osmanlı nüshası çok daha erken açılmış. İlk kayıt Ağustos 1452, Boğaz'ın en dar yerinde bir hisar. Kuşatmaya yedi ay var. Kendinize rastlamazsınız; rastladıklarınız sizi Nisan'da hatırlarsa, formda ona da kutu yok.","One correction, Mr Tolga: the Ottoman copy opens much earlier. First entry: August 1452, a fortress at the narrowest point of the Bosporus. Seven months before the siege. You won't run into yourself; if the people you run into remember you in April, there's no box on the form for that either."
```

**28o'nun açılışı.** Tolga artık topla birlikte gelmiştir. Urban onu "mantolu yabancı" diye değil, kendi kâtibi
diye karşılar. Üç replik değişir, akış aynı kalır:

```csv
D28O_N_01,"Tolga Bey, 6 Nisan. Ordu dün geldi, bugün toprağa giriyor. Top da burada; iki ay yolda ona siz eşlik ettiniz. Şimdi kazık işiniz var.","Mr Tolga, 6 April. The army arrived yesterday, today it digs in. The gun is here too; you escorted it for two months on the road. Now you have stake duty."
D28O_U_01,"Kâtip! Yoldan sağ çıktın demek. Kazıkları siperin arkasına. Benim topum yerine geçtiğinde önünde çit olacak, düzgün olacak.","Clerk! So you survived the road. Stakes behind the rampart. When my gun goes into place there will be a fence in front of it, and it will be straight."
D28O_U_HAUL,"Altmış öküz bunu Edirne'den getirdi, sen de yanındaydın. Son kırk metre bizim. Hey-yap dediğimde hep birlikte! Kütük arkadan çıkınca öne!","Sixty oxen brought this from Edirne, and you walked beside it. The last forty metres are ours. When I say heave, all together! When a roller comes out the back, take it to the front!"
```

`D28O_T_01` ("Usta, bu kazıklar sizin topunuzu mu koruyacak…") olduğu gibi kalır.

### 0.4 Komşu bölümlerin değişen "Önceki bölümde / Sırada" satırları

Bütün satırlar 140 karakterin altındadır (denetlendi).

```csv
UI_RECAP_28O_PREV,"İki ay Trakya yolunda köprü kurdun, çamurdan çektin, yokuşta frenledin. Top surlara beş mil kala bekliyor.","Two months on the Thracian road: you built a bridge, hauled it out of the mud, braked it downhill. The gun waits five miles out."
UI_RECAP_28O_NEXT,"Şahi konuştu. 18 Nisan gecesi: gedikteki barikata kanca ve meşaleyle ilk büyük hücum.","The great gun has spoken. Night of 18 April: the first great assault, with hooks and torches, on the stockade in the breach."
UI_RECAP_29O_PREV,"18 Nisan gecesi barikattan fıçı indirdin, meşale attın; dört saat sonra boru çaldı. Ulak seni donanmaya yolladı.","On 18 April you pulled barrels off the stockade and threw torches; after four hours the horn sounded. A courier sent you to the fleet."
```

`UI_RECAP_29O_NEXT` ve sonrakiler değişmez. 29o'nun "neden denizde" kopukluğu (OTTOMAN_STORY §2.1) böylece kapanır:
36o, Baltaoğlu'na kürekçi toplayan bir ulakla biter (`D36O_RD_01`).

### 0.5 Bütün bölümler için ortak görsel kurallar

Kod yazan için her fazın listesine ek olarak geçerlidir.

**Zemin:**
- Her NPC, kalabalık öğesi (`Crowd`), hayvan, araba, fıçı ve sandık **zemin işleviyle** (`ground_y(x, z)` ya da
  seviyenin `hf`'si) oturtulur. Sabit `y = 0` kullanılmaz.
- Yürüyen her şey her karede zemini yeniden örnekler (yokuş, moloz, hendek, kar).
- `VISAUDIT` satırı her bölümde şunları denetler: ayak ile zemin arası > 0,15 m (havada) ya da < −0,1 m (gömülü)
  olan karakter ve hayvan.

**Doğuş ve kayboluş:**
- Bir NPC görüş alanında **belirmez**: kenardan yürüyerek, bir çadırdan ya da iskeleden çıkarak gelir.
- Gidenler de yürüyerek gider. Görüş dışında silinebilir.

**İp ve zincir:**
- Her ip ve zincir iki uç arasında görünür bir `ImmediateMesh` ya da silindir zinciridir.
- Gevşekken sarkar (katener, orta nokta 0,3–0,6 m aşağıda). Gerginken düzdür ve hafif titrer.
- Bağlanan yerde görünür bir **düğüm** ağı olur (2–3 sarım halkası).
- Kopan ip iki parçaya ayrılır ve kamçı gibi savrulur (0,4 sn).

**İş hareketi:**
- Oyuncuyla aynı işi yapan NPC'ler o işin döngüsünü oynar: çekiç inip kalkar, çeken asker geriye yaslanır, iten
  öne eğilir, çıkrık çeviren kolu döndürür.
- İşin nesnesi de hareket eder: kol döner, ip sarılır.

**İsabet ve kırılma:**
- Kırılan her şey en az 4 parçaya ayrılır, yere düşer ve 6 sn sonra söner: kil, kalas, fıçı, taş.
- Toz bulutu (`Vfx`) ve uygun ses çıkar.
- Oyuncu hasar alınca `Fx.edge` kırmızı ve kamera darbe yönüne yatar (mevcut).

**Su:**
- Suya düşen şey sıçrama yapar ve halka bırakır.
- Yüzenler akıntıyla sürüklenir: kütük, kalas, gülle tozu.

---

## 1. Bölüm 33o — "Boğazkesen" (31 Ağustos ve 26 Kasım 1452)

### 1.1 Tarihî dayanak

- **Hisar.** II. Mehmed 1452 baharında Boğaz'ın en dar yerinde, Anadoluhisarı'nın karşısında bir hisar yaptırdı.
  Yaklaşık dört buçuk ayda, Ağustos sonunda bitti (**K**, **D**, **TB**, **AP**).
  - Bizanslılar ona "Boğazkesen" dedi: Doukas'ta *Laimokopia*, Osmanlı kaynaklarında *Boğazkesen*.
  - Üç büyük kuleyi üç vezir yaptırdı: Çandarlı Halil, Zağanos ve Saruca Paşa. Surları Sultan'ın kendisi yaptırdı.
    Vezirler arasında bir yarış anlatılır (**D**, **K**).
  - Hisarın planının Arapça bir adı yazdığı söylenir: **rivayet**, oyunda kullanılmaz.
  - İskele, çıkrık ve vinç kullanımı dönemin taş yapı tekniğidir. Ayrıntıları **oyun kurgusudur**.
- **Gümrük ve top.** Hisarın dibine kıyıya büyük toplar kondu. Boğaz'dan geçen her gemi yelkenini indirip durmak ve
  geçiş hakkı ödemek zorundaydı (**D**, **R**). Hisarın dizdarı Doukas'a göre Firuz Ağa'dır; emrinde 400 asker vardı.
  - Ceneviz gemisinin ambarındaki saklı sandık **oyun kurgusudur**. Galata Cenevizlilerinin resmen tarafsız kalıp
    şehre gizlice yardım ettiği ise kaynaklarda vardır (**R**).
- **Rizzo'nun gemisi.** 1452 Kasım'ının sonunda Antonio Rizzo'nun Venedik gemisi Karadeniz'den şehre erzak getiriyordu
  (Barbaro ve Venedik kaynakları 26 Kasım der).
  - Gemi yelken indirmedi. Hisarın topundan çıkan tek bir büyük gülle onu batırdı (**D**, **R**).
  - Kaptan ve tayfa kıyıya çıktı ve yakalandı. Dimetoka'da Sultan'ın huzuruna götürüldüler. Tayfa öldürüldü, Rizzo
    kazığa oturtuldu. Doukas'a göre cesetler gömülmeden bırakıldı.
  - Oyun bunu **göstermez**. Nihat bölüm sonunda tek cümleyle söyler.
- **Urban.** Macar (ya da Erdelyli) dökümcü önce hizmetini İmparator'a sundu. İmparator istediği ücreti ve malzemeyi
  karşılayamadı. Urban Sultan'a geçti.
  - Doukas'a göre Urban'ın ilk büyük dökümü **Boğazkesen'e konan ve Rizzo'nun gemisini batıran toptur**. Sultan
    bundan sonra daha büyüğünü istedi (→ 34o).

### 1.2 Yer ve sistemler

**Yeni küçük seviye:** `scripts/level/bogaz.gd` (`Bogaz`). Yaklaşık 400 satır, yalnız 33o kullanır.
- **Yakın kesit:** Halil Paşa'nın deniz kulesi (yarım silindir, 18 m) ve yanındaki perde duvar (12 m).
- **Kule önünde üç katlı ahşap iskele:**
  - Dikmeler, yatay kirişler (1,2 m arayla, tutunulabilir), kalaslar.
  - 1 → 2. kat arası `Ladder`. 2 → 3. kat arasında da merdiven var, bölümde kırılır.
  - 3. katta 12 m'lik altı kalaslı bir yürüme yolu.
- **Kule tepesi:** Dört taşlık bir **yuva** (duvarda boşluk), üstünde ahşap kollu bir **çıkrık** (vinç).
  - Kolun ucunda makara, ipin ucunda taşı tutan kıskaç.
  - Kolu iki işçi döndürür. Çıkrığın tamburu yerde, kulenin dibindedir.
- **Kıyı bataryası:** Rıhtımın üstünde iki top.
  - Küçük top: 17o'daki "orta top" kurulumu (`CannonCrew` pivot/muzzle).
  - Urban'ın büyük topu: 28o'daki Şahi namlusunun küçültülmüşü, toprak set üstünde. Gülle yığını ve barut fıçıları.
- **Su:** `SeaWalls` su düzlemi ve dalga malzemesi. Akıntı güneye doğrudur (+X), kayığa ve yüzen her şeye hız olarak
  eklenir.
  - Akıntıburnu kayaları güneyde, su üstünde 6 kaya ve köpük.
- **Karşı kıyı** (z ~ 600): `OuterWorld` tepeleri, üstünde Anadoluhisarı'nın küçük silueti.
- **Gemiler:** `SeaBattle`'ın karaka kurucusu.
  - Ceneviz gemisi: kırmızı haçlı, yelkenler indirilmiş, ambar ağzı açık. İçinde balya ve fıçılar (katı, yürünür).
  - Rizzo'nun gemisi: Aziz Markos aslanlı kırmızı-altın sancak, yelkenler dolu.
  - SeaBattle'ın karaka işlevi renk ve sancak parametresi almıyorsa `sail_color` / `emblem` eklenir (tek küçük
    değişiklik).
  - Kayık: 17'deki kayık ve `RowMeter` kürekçi animasyonu (`Rig.row_phase`).

**Kullanılan sistemler:**
- `Ladder` ve `player.enable_climb(bounds)`: iskelenin dikdörtgeni; `Traversal` nefesle sınırlı.
- `BalanceMeter`: çıkrıktaki taşın sallanması. 4b'deki zincir dengesinin ibresi; değer = taşın salınım açısı.
- `RowMeter`, `CannonCrew` + `GunDrill`, `TespitCam`, `hud.choose`, `Lore.scatter(self, "33o")`.
- 26o'nun "YUKARIDAN TAŞ!" uyarısı ve iniş noktası: düşen kova ve aletler için.

**Işık:** Ağustos sabahı ve Kasım öğleden sonrası (soğuk, alçak güneş) için iki gündüz ayarı.

**Süre hedefi:** 10–12 dk. Durarak konuşma ≤ 2,5 dk.

### 1.3 Fazlar

#### Faz 1a: İskele (31 Ağustos, sabah)

- **Hedef:** `UI_OBJ33O_CLIMB`
- **Oynanış:**
  - Taşçı Tolga'yı kule tepesindeki çıkrığa işaretçi olarak gönderir.
  - 1 → 2. kat: `Ladder`.
  - 2 → 3. kat: önde tırmanan işçinin altında merdiven **kırılır** (senaryo). İşçi kirişe tutunur ve yana kaçar.
    Tolga **serbest tırmanır**: `enable_climb` açılır, iskele dikmeleri ve kirişleri tırmanılır, 7 m.
  - Halil Paşa'nın kulesinde çalışan ekipten 6–9 sn'de bir **harç kovası ya da keser düşer**. Düşeceği yerde 1,2 sn
    önce kırmızı halka ve "YUKARIDAN!" uyarısı çıkar. Yana kayarsan (A/D) önünden geçer.
  - 3. katta **çatırdayan kalaslar**: Basılan kalas çatırdar ve toz çıkarır. **1,5 sn** sonra düşer. Altı kalası
    durmadan geç.
  - Tepede çıkrığın yanına varınca faz biter.
- **Başarısızlık:**
  - Kova ya da keser isabet ederse −20 can ve tutunma bırakılır.
  - Nefes biterse ya da düşen bir kalasın üstünde kalırsan 2. kata düşersin: −15 can, 1a'nın serbest tırmanışından
    yeniden başlarsın.
  - Süre yok. Düşüş sayısı `scaffold_falls` olarak sayılır.

**Animasyon ve görsel geri bildirim:**
- **Kırılan merdiven:** basamak ortadan ikiye ayrılır (iki parça + kıymık). İşçi kirişe tek elle asılır, ayaklarını
  sallar, yana kayıp öbür dikmeye geçer.
- **Kirişler:** Tutunulan kirişlerde el teması anında küçük toz.
- **Düşen kova:** havada döner, kalasa çarpınca harç sıçrar (gri lekeler kalasta kalır). Keser saplanıp titrer.
- **Çatırdayan kalas:** önce 2 cm çöker. Düşerken döner, yere çarpınca seker. Yerdeki işçiler başlarını kaldırıp
  geriye sıçrar.
- **Çalışan işçiler:** Komşu kulede 6 işçi bant hâlinde çalışır: biri taş uzatır, biri mala sürer, biri çekiçler.
  Hepsi iskele kalasının üstünde durur, yüksekliği kalas üst yüzüdür.
- **Zemin:** Kule dibindeki kalabalık eğimli kıyıdadır. `Bogaz.ground_y` ile oturur. Taş yığınları ve harç teknesi de
  aynı işlevle.

#### Faz 1b: Çıkrık (31 Ağustos, öğleye doğru)

- **Hedef:** `UI_OBJ33O_CRANE`
- **Oynanış:**
  - Aşağıda iki işçi çıkrığı çevirir. Taş sallanarak yükselir.
  - Tolga kulenin tepesinde **kılavuz ipini** tutar: A/D ipi çeker ya da salar. `BalanceMeter` taşın salınımını
    gösterir.
  - Rüzgâr 3–5 sn'de bir iter. Ayrıca iki sert **bora** olayı var: sancak çırpınır, 1 sn önce uyarı gelir.
  - Taş yuvanın üstüne gelince ibre yeşildeyken **E: "İndir!"**.
  - **Dört taş.** Ezana kadar **4 dk** var. Sağ üstte üç kulenin ilerleme simgesi dolar. Halil'in ve Zağanos'un
    ekipleri yarışır (yalnız görüntü).
- **Başarısızlık:**
  - İbre kırmızıdayken indirilen taş **duvara çarpar**: köşe kırılır, taş geri salınır, 6 sn kayıp.
  - Taş üç kez çarparsa kıskaç açılır ve taş düşer. Aşağıdakiler kaçar. Yeni taş gelir, 15 sn kayıp.
  - Süre biterse kalan taşları ustalar koyar.
  - Sayaç: konan taş ve çarpma.

**Animasyon ve görsel geri bildirim:**
- **Çıkrık:** Kolun tamburu her çevirmede döner, ip tambura sarılır (sarım kalınlığı artar).
- **Çeviren işçiler:** İki işçi kolu çevirme döngüsünde: gövde öne-arka, kollar dairesel.
- **Kılavuz ipi:** Taştan Tolga'nın eline uzanan ikinci bir ip. Çekince gerilir, salınca sarkar.
- **Taş:** Kıskaç taşın iki yanındaki oyuklara geçer (görünür). Taş salınırken ip açısı salınımla aynıdır.
- **Çarpma:** taş köşesi 3 parça ve toz olur, duvarda açık renkli çentik kalır.
- **İndirme:** Ustalar harç sürer (mala hareketi, gri yatak görünür). Taş yuvaya otururken harç kenarlardan taşar.
  Usta tokmakla iki kez vurur.
- **Rakip kuleler:** İskelelerinde aynı çıkrık döngüsü, taş yükselir ve iner (yalnız görüntü, döngüde).

#### Faz 2: Gümrük (Kasım 1452, sabah; "Kasım 1452 · gümrük" kartı)

- **Hedefler:** `UI_OBJ33O_ROW`, `UI_OBJ33O_BOARD`, `UI_OBJ33O_HOLD`
- **Oynanış:**
  - **(a) Akıntıya karşı kürek.** Ceneviz gemisi yelkeni indirmiş, demirsiz sürükleniyor. Gümrük kayığında `RowMeter`,
    120 m, **60 sn**.
    - Ritim kaçınca akıntı kayığı güneye kaydırır (kayma oku).
    - 40 m'den fazla kayarsan **Akıntıburnu kayaları**: köpük ve "KAYA!" uyarısı çıkar. Sancak küreğiyle sağa çekmek
      için iki iyi vuruş gerekir, yoksa çarpma: kayık döner, 10 sn kayıp.
    - 60 sn'de yetişemezsen Firuz uyarı için surdan boş barut atar (komik, `D33O_FZ_LATE`) ve süre sıfırlanır.
  - **(b) Bordada ip merdiven.** Gemi 4 sn'de bir yalpa yapar. Yalpanın tepesinde ip merdiven bordadan açılır, 1 sn
    önce "Dalga!" uyarısı çıkar.
    - Uyarıda W'yi bırakıp tutunursan sallanırsın ama kalırsın.
    - Tırmanmaya devam edersen elin kayar ve **suya düşersin**: 5 sn soğuk su, kayığa tırmanma, yeniden.
    - Merdiven 6 m.
  - **(c) Ambar.** Beyanda dört kalem var: balık, kenevir, bal, şarap. Ambarda **beşinci** bir şey saklı.
    - **40 sn** içinde ambarda dolaş. Fıçı ve balyalara bakıp E ile gözle (her biri 1 sn).
    - Kenevir balyalarından biri hafif: E ile kaldırılır, altında arbalet okları dolu bir sandık.
    - Davul sesi süreyi sayar.
    - Bulunca kaptan "hediye" uzatır: **seçim** (`UI_C33O_REFUSE` / `UI_C33O_TAKE`).
    - Bulunamazsa davul biter, Firuz çağırır (`D33O_FZ_DRUM`). Seçim yine gelir, ama hediye "çabukluk için"dir.
- **Sonuç:**
  - `GameState.flags["toll_hidden"] = true/false`
  - `GameState.flags["toll_gift"] = "refuse"/"take"`
  - İkisi dosya notunda bir cümleyi değiştirir. Tarih aynıdır, sandık Galata'ya gider ya da gitmez; oyun bunu
    söylemez.

**Animasyon ve görsel geri bildirim:**
- **Kürek:** İki kürekçi ve Tolga aynı evrede çeker. Kürek ağzı suya girerken sıçrama, ritim kaçınca şapırtı (büyük
  sıçrama).
  - Kayığın arkasında iz (köpük şeridi). Akıntı yönünde suyun yüzünde kayan köpük lekeleri.
- **Kayaya çarpma:** kayık 90° döner, gövdeden kıymık çıkar, kürekçi küreği bırakıp kayayı itme hareketi yapar.
- **İp merdiven:** iki halat ve tahta basamaklar. Yalpada bordadan 0,6 m açılır ve geri çarpar.
- **Suya düşüş:** sıçrama ve halka. Tolga'nın kayığa tırmanma hareketi (kol kenarda, bacak üstte).
- **Ambar:** loş, ambar ağzından ışık sütunu ve tozlar. Kaldırılan balya Tolga'nın kollarında havada durur, sandığın
  kapağı aralık.
- **Mühür:** Tolga'nın elinde mühür, kâğıda inince kırmızı damga.
- **Gemi tayfası:** güvertede halat sarar, fıçı yuvarlar. Hepsi güverte yüksekliğinde, `SeaBattle.CARRACK_DECK`.
  Gemi yalpalarken birlikte sallanırlar: geminin çocuğu olarak kurulurlar, dünyaya değil.

#### Faz 3: Uyarı atışı (26 Kasım 1452, öğleden sonra; "26 Kasım 1452" kartı)

- **Hedef:** `UI_OBJ33O_WARN`
- **Oynanış:**
  - Kuzeyden Rizzo'nun gemisi gelir: yelkenler dolu, akıntı ve rüzgârla 5 m/sn.
  - Firuz uyarı atışı ister. Tolga küçük topu **elle doldurur** (`CannonCrew`: barut, tapa, gülle, tokmak, nişan,
    ateş).
  - Hedef suda, geminin **burnunun 25–60 m önünde** hareket eden bir halka. GunDrill'in nişan yayı düşüş noktasını
    gösterir.
  - Gemi bataryanın önündeki koridoru **75 sn**'de geçer.
- **Sonuç:**
  - Gülle halkaya düşerse `warn = "ok"`.
  - Gemiye değerse `warn = "hit"` (Firuz kızar).
  - Başka yere düşerse ya da süre biterse `warn = "miss"`. Süre biterse Firuz kendisi atar.
  - Gemi her durumda yelken indirmez (tarih).

**Animasyon ve görsel geri bildirim:**
- **Doldurma adımları:** torba namluya kayar, toz çıkar, tokmak içeri girip çıkar (CannonCrew'da var).
- **Atış:** namlu ağzında alev, duman halkası, top 0,4 m geri teper ve yerine itilir (iki topçu iter).
- **Halka:** suda yarı saydam kırmızı daire, gemiyle birlikte kayar.
- **Düşüş:** halkaya düşen güllede 6 m'lik su sütunu, sprey geminin baş tarafını ıslatır (pruva ıslak doku).
  Iskada küçük sıçrama.
- **Rizzo'nun gemisi:** güvertede tayfa koşar, biri pruvada yumruk sallar. Kaptan kıç kasarasında Rizzo'dur (`Person`,
  şapkalı).

#### Faz 4: Büyük top (hemen ardından)

- **Hedefler:** `UI_OBJ33O_BIG`, `UI_OBJ33O_PHOTO`
- **Oynanış:**
  - Urban'ın topu. Gülleyi iki işçi sırık-sedyeyle taşır.
  - Tolga **tokmak** (ritim, 3 iyi vuruş) ve **nişan** yapar. Hedef hareket eden gövde, 180 m. `CannonCrew._predict`
    yayı geminin 2 sn sonraki yerine öne nişan almayı öğretir.
  - Fitili Urban yakar. "Arkadan çekil!" uyarısıyla **2 sn** içinde topun arkasındaki kırmızı alandan çık. Top 1,5 m
    geri teper. **Tek atış.**
  - Gemi yan yatıp batarken **tespit karesi**: yatan direk ve arkada deniz kulesi. Hedef direk tepesi, pencere 20 sn.
- **Sonuç:**
  - İsabet → gövdede delik, gemi yan yatar.
  - Iska → yan topu Urban ateşler ve vurur (tarih). `big = true/false`.
  - Geri tepme alanında kalırsan −30 can ve yere düşersin. Kare yine çekilebilir.
  - Kare kaçarsa dosyada not (`UI_SIEGE_NO_PHOTO`).

**Animasyon ve görsel geri bildirim:**
- **İsabet:** gövdede kırık kalaslar dışarı açılır (8 parça), su fışkırır. Gemi 6 sn'de 25° yatar, yelkenler suya
  değer, direk yavaşça iner, tayfa suya atlar (sıçramalar). Sandal indirilir.
- **Geri tepme:** top kızağı toprak sette iz bırakır. Arkadaki işçiler kenara sıçrar. Duman 4 sn bataryayı örter.
- **Batış:** gövde su yüzeyinin altına iner, enkaz (fıçı, kalas, çuval) yüzeyde kalır ve akıntıyla sürüklenir.

#### Faz 5: Kıyı (akşamüstü)

- **Oynanış:** Kısa ve yürünebilen bir sahne.
  - Tayfanın sandalı rıhtıma çıkar, askerler onları alır. Uzakta, arkaları dönük; gösterilmez, yürüyüp giderler.
  - Tolga rıhtımda gümrük defterini kapatır.
  - Nihat'ın kaydı. Urban Tolga'yı Edirne'ye çağırır.

**Animasyon ve görsel geri bildirim:**
- **Sandal:** kürekle gelir, burnu kumda durur, tayfa iner.
- **Askerler ve tayfa:** yan yana rıhtımın yokuşundan yürüyerek çıkar ve sırtın ardında kaybolur (`ground_y`).

#### Sonuçlar

| Kod | Koşul | Şema |
|---|---|---|
| **33O.1** Uyarı yerinde, gülle bordada | `warn == "ok"` **ve** `big` | `FLOW_33O_1` |
| **33O.2** Tunç ikinci kez konuştu | aksi hâlde | `FLOW_33O_2` |

Tarih ikisinde de aynıdır. Fark Firuz'un ve Urban'ın repliklerinde, dosya notunda ve 34o'daki ilk Urban repliğindedir
(`D34O_U_01` / `D34O_U_01_ALT`).

**Otomatik test:** `--chapter=33 --autotest[=wide|fall]`
- **Varsayılan (33O.1):** Bot serbest tırmanır (kova uyarısında yana kayar). Dört taşı yeşilde indirir. Akıntıda
  ritmi tutar. Yalpada durur. Sandığı bulur ve reddeder. Halkaya atar, büyük topla vurur, geri tepmeden kaçar, kareyi
  çeker.
- **`=wide` (33O.2):** Uyarı gemiye değer, büyük top ıskalar. Satırlar: `WARN hit`, `BIG miss`.
- **`=fall`:** Bot bir kalasın üstünde bekler (düşer). Yalpada tırmanmaya devam eder (suya düşer). Taşı kırmızıda
  indirir (çarpar). Denetimler: `scaffold_falls >= 1`, `water_falls >= 1`, `crane_hits >= 1`, bölüm yine biter.
- **`VISAUDIT`:** Rizzo gemisinin ve kayığın su çizgisi, iskeledeki işçilerin kalasa basması, rıhtım yürüyüşü.

**Akış şeması** (`UI_FLOW33O_TITLE`):
`FLOW33O_SCAFFOLD` → `FLOW33O_CRANE` → `FLOW33O_TOLL` → `FLOW33O_WARN` → `FLOW33O_BIG` → {`33O.1`, `33O.2`}.
Altında `UI_CH33O_STATS` ve `Siege.recap(…, "NEXT")`.

**Başarım önerisi:** `ACH_OSM_TOLL` "Gümrük Memuru": saklı sandığı bul, hediyeyi reddet, uyarıyı halkaya düşür.

### 1.4 Konuşanlar

**Yeni anahtarlar:**

| Anahtar | tr / en | Ses |
|---|---|---|
| `SPK_MASON` | Taşçı Ustası / Master Mason | Altmışlık, tozlu, sabırlı. Kısa cümlelerle konuşur, taşı insan gibi anlatır. 34o'da gülle yontan taşçı da bu anahtarı kullanır (başka kişi, aynı meslek). |
| `SPK_FIRUZ` | Dizdar Firuz Ağa / Firuz Agha, Warden | Hisarın komutanı. Kuralcı, gür sesli, kısa emirler verir. Kendi kuralına gurur duyar. |
| `SPK_RIZZO` | Kaptan Antonio Rizzo / Captain Antonio Rizzo | Uzaktan, rüzgârın içinden bağırır. Kibirli değil, inatçıdır: şehre erzak götürüyordur. |

**Mevcut anahtarlar:** `SPK_NIHAT`, `SPK_TOLGA`, `SPK_SOLDIER` (iskele işçisi), `SPK_ZAGANOS`, `SPK_HALIL`,
`SPK_FATIH`, `SPK_ROWER`, `SPK_GENOESE`, `SPK_URBAN`.

**Koşullu replikler:**
- Seçimden sonra yalnız bir çift söylenir: `REFUSE` ya da `TAKE`.
- `D33O_T_FIFTH` / `D33O_G_BRIBE` yalnız sandık bulunursa söylenir; bulunmazsa `D33O_FZ_DRUM` + `D33O_G_HASTE`.
- Uyarı sonucuna göre `D33O_FZ_WARN_OK` / `_HIT` / `_MISS`.
- Büyük top: `D33O_U_HIT` ya da (`D33O_U_MISS` + `D33O_U_SECOND`).
- Bitiş: `D33O_U_END_OK` (33O.1) ya da `D33O_U_END_BAD` (33O.2).

**Durarak söylenenler (say):** `N_01`, `T_01`, `M_01`, `T_02`, `M_02` (açılış, ~40 sn); `FZ_01`, `T_05` (Kasım
kartı, ~15 sn); seçim çifti; `N_END`, `T_END`, `U_END_*` (kapanış, ~30 sn). Toplam ≈ 2 dk. **Geri kalan hepsi
bark**, oyun akarken söylenir. Tabloda 61 anahtar var; dallar ve olay bark'ları yüzünden bir oynayışta ≈ 40–45'i duyulur.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D33O_N_01` | SPK_NIHAT | say |
| `D33O_T_01` | SPK_TOLGA | say |
| `D33O_M_01` | SPK_MASON | say |
| `D33O_T_02` | SPK_TOLGA | say |
| `D33O_M_02` | SPK_MASON | say |
| `D33O_S_LADDER` | SPK_SOLDIER | bark |
| `D33O_T_CLIMB` | SPK_TOLGA | bark |
| `D33O_S_ABOVE` | SPK_SOLDIER | bark |
| `D33O_T_PLANK` | SPK_TOLGA | bark |
| `D33O_M_FALL` | SPK_MASON | bark |
| `D33O_Z_01` | SPK_ZAGANOS | bark |
| `D33O_H_01` | SPK_HALIL | bark |
| `D33O_T_03` | SPK_TOLGA | bark |
| `D33O_T_WIND` | SPK_TOLGA | bark |
| `D33O_M_STONE_1` | SPK_MASON | bark |
| `D33O_M_STONE_BAD` | SPK_MASON | bark |
| `D33O_T_STONE` | SPK_TOLGA | bark |
| `D33O_M_DROP` | SPK_MASON | bark |
| `D33O_M_DONE` | SPK_MASON | bark |
| `D33O_M_DONE_LATE` | SPK_MASON | bark |
| `D33O_F_01` | SPK_FATIH | bark |
| `D33O_T_04` | SPK_TOLGA | bark |
| `D33O_FZ_01` | SPK_FIRUZ | say |
| `D33O_T_05` | SPK_TOLGA | say |
| `D33O_R_01` | SPK_ROWER | bark |
| `D33O_R_ROCKS` | SPK_ROWER | bark |
| `D33O_FZ_LATE` | SPK_FIRUZ | bark |
| `D33O_G_ROLL` | SPK_GENOESE | bark |
| `D33O_T_WATER` | SPK_TOLGA | bark |
| `D33O_G_01` | SPK_GENOESE | bark |
| `D33O_T_FIFTH` | SPK_TOLGA | bark |
| `D33O_G_BRIBE` | SPK_GENOESE | say |
| `D33O_FZ_DRUM` | SPK_FIRUZ | bark |
| `D33O_G_HASTE` | SPK_GENOESE | say |
| `D33O_T_REFUSE` | SPK_TOLGA | say |
| `D33O_G_REFUSE` | SPK_GENOESE | say |
| `D33O_T_TAKE` | SPK_TOLGA | say |
| `D33O_N_TAKE` | SPK_NIHAT | bark |
| `D33O_FZ_SHIP` | SPK_FIRUZ | bark |
| `D33O_RZ_01` | SPK_RIZZO | bark |
| `D33O_FZ_WARN` | SPK_FIRUZ | bark |
| `D33O_T_WARN` | SPK_TOLGA | bark |
| `D33O_FZ_WARN_OK` | SPK_FIRUZ | bark |
| `D33O_FZ_WARN_HIT` | SPK_FIRUZ | bark |
| `D33O_FZ_WARN_MISS` | SPK_FIRUZ | bark |
| `D33O_RZ_02` | SPK_RIZZO | bark |
| `D33O_FZ_BIG` | SPK_FIRUZ | bark |
| `D33O_U_01` | SPK_URBAN | bark |
| `D33O_T_URBAN` | SPK_TOLGA | bark |
| `D33O_U_BACK` | SPK_URBAN | bark |
| `D33O_U_HIT` | SPK_URBAN | bark |
| `D33O_U_MISS` | SPK_URBAN | bark |
| `D33O_U_SECOND` | SPK_URBAN | bark |
| `D33O_T_SINK` | SPK_TOLGA | bark |
| `D33O_N_PHOTO` | SPK_NIHAT | bark |
| `D33O_FZ_BOAT` | SPK_FIRUZ | bark |
| `D33O_T_BOAT` | SPK_TOLGA | bark |
| `D33O_N_END` | SPK_NIHAT | say |
| `D33O_T_END` | SPK_TOLGA | say |
| `D33O_U_END_OK` | SPK_URBAN | say |
| `D33O_U_END_BAD` | SPK_URBAN | say |

### 1.5 Metinler

```csv
UI_CH33O_TITLE,BÖLÜM {N} — BOĞAZKESEN,CHAPTER {N} — THE THROAT-CUTTER
UI_CH33O_SUB,"31 Ağustos 1452 · Boğaziçi, Rumeli kıyısı · yeni hisar","31 August 1452 · The Bosporus, European shore · the new fortress"
UI_CH33O_TOLL,"Kasım 1452 · gümrük","November 1452 · the toll"
UI_CH33O_RIZZO,"26 Kasım 1452 · kuzeyden bir yelken","26 November 1452 · a sail from the north"
UI_FLOW33O_TITLE,AKIŞ ŞEMASI — BÖLÜM {N}: BOĞAZKESEN,FLOWCHART — CHAPTER {N}: THE THROAT-CUTTER
SPK_MASON,Taşçı Ustası,Master Mason
SPK_FIRUZ,Dizdar Firuz Ağa,"Firuz Agha, Warden"
SPK_RIZZO,Kaptan Antonio Rizzo,Captain Antonio Rizzo
UI_OBJ33O_CLIMB,İskeleden kulenin tepesine çık: çıkrığa,Climb the scaffold to the top of the tower: to the crane
UI_OBJ33O_CRANE,"Taşı yuvaya indir: kılavuz ipiyle salınımı tut (A/D), yeşilde E · %d/%d","Lower the stone into its gap: steady the swing with the guide rope (A/D), E on green · %d/%d"
UI_OBJ33O_ROW,Kürek çek (ibre yeşildeyken Space) · akıntıya karşı Ceneviz gemisine,Row (Space when the needle is green) · against the current to the Genoese ship
UI_OBJ33O_BOARD,İp merdivenden güverteye çık · dalgada dur,Climb the rope ladder to the deck · hold still on the roll
UI_OBJ33O_HOLD,"Ambarı gözle: beyanda dört kalem, ambarda beş · %d sn","Inspect the hold: four items declared, five in the hold · %d s"
UI_OBJ33O_WARN,"Uyarı atışı: topu doldur, geminin burnunun önüne at · %d sn","Warning shot: load the gun, put it in front of the ship's bow · %d s"
UI_OBJ33O_BIG,"Büyük top: tokmakla sıkıştır, gövdeye nişan al","The great gun: ram it home, aim at the hull"
UI_OBJ33O_PHOTO,Tespit et: yatan direk ve kule,Record: the falling mast and the tower
UI_HINT33O_ABOVE,YUKARIDAN! Yana kay!,FROM ABOVE! Move aside!
UI_HINT33O_PLANK,Kalas çatırdıyor! Durma!,The plank is cracking! Keep moving!
UI_HINT33O_GUST,BORA! Kılavuz ipini tut!,GUST! Hold the guide rope!
UI_HINT33O_ROCKS,KAYA! Sağa çek!,ROCKS! Pull to starboard!
UI_HINT33O_ROLL,DALGA! Dur ve tutun!,ROLL! Stop and hold on!
UI_HINT33O_RECOIL,Arkadan çekil! Top geri tepecek!,Get clear behind! The gun will recoil!
UI_PROMPT33O_LOWER,E: İndir!,E: Lower!
UI_PROMPT33O_CARGO,E: yükü gözle,E: inspect the cargo
UI_PROMPT33O_LIFT,E: balyayı kaldır,E: lift the bale
UI_C33O_REFUSE,Yazıyorum: beş kalem. Şarap almıyorum.,I'm writing it down: five items. No wine for me.
UI_C33O_TAKE,Şişeyi al. Defterde bir satır eksik kalsın.,Take the bottle. Let the ledger be one line short.
FLOW33O_SCAFFOLD,İskelede serbest tırmanış,A free climb on the scaffold
FLOW33O_CRANE,Kulenin son taşları (31 Ağustos),The tower's last stones (31 August)
FLOW33O_TOLL,"Gümrük: yelken indir, beyan et","The toll: lower your sail, declare your cargo"
FLOW33O_WARN,Rizzo'nun gemisine uyarı atışı,A warning shot at Rizzo's ship
FLOW33O_BIG,Urban'ın topu konuşur,Urban's gun speaks
FLOW_33O_1,"Uyarı yerinde, gülle bordada","Warning on the mark, ball in the hull"
FLOW_33O_2,Tunç ikinci kez konuştu,The bronze had to speak twice
UI_CH33O_STATS,Taş: %d/%d   ·   Düşüş: %d   ·   Uyarı: %s   ·   Büyük top: %s   ·   Dosya: %d/%d sayfa,Stones: %d/%d   ·   Falls: %d   ·   Warning: %s   ·   Great gun: %s   ·   File: %d/%d pages
UI_CH33O_WARN_OK,yerinde,on the mark
UI_CH33O_WARN_HIT,gemiye,into the ship
UI_CH33O_WARN_MISS,boşa,wasted
UI_CH33O_BIG_HIT,isabet,hit
UI_CH33O_BIG_MISS,ıska,miss
SIEGE_DATE_33,Ağustos–Kasım 1452,August–November 1452
SIEGE_EV_33,"Boğaz'ın en dar yerinde Boğazkesen hisarı dört buçuk ayda biter. Kasım'da yelken indirmeyen bir Venedik gemisi hisarın topuyla batırılır.","The fortress of Boğazkesen is finished in four and a half months at the narrowest point of the Bosporus. In November a Venetian ship that will not lower its sails is sunk by the fortress's gun."
SIEGE_NOTE_33O_1,"Kulenin son taşı, gümrük beyanı, uyarı atışı: hepsi usulüne uygun. Gemi yine de durmadı. Hasar: tam. Beyan: yok. Kuşatma burada, bir gümrük kapısında başladı. — T.","The tower's last stone, a toll declaration, a warning shot: all by the book. The ship didn't stop anyway. Damage: total. Declaration: none. The siege began here, at a toll gate. — T."
SIEGE_NOTE_33O_2,"Uyarı atışı uyarı olmadı, benim gülle de gemiyi bulmadı; Urban'ın ikinci topu buldu. Sonuç aynı. Not: Boğaz'da ikinci şans yok, ama ikinci top var. — T.","My warning shot wasn't much of a warning and my ball missed; Urban's second gun didn't. Same result. Note: there are no second chances on the Bosporus, but there is a second gun. — T."
LORE_33O_1_T,Boğazkesen,The Throat-Cutter
LORE_33O_1,"Sultan II. Mehmed 1452 baharında Boğaz'ın en dar yerinde, karşı kıyıdaki eski hisarın tam karşısına bir kale yaptırdı. Üç büyük kuleyi üç vezir, Çandarlı Halil, Zağanos ve Saruca Paşa yaptırdı; iş dört buçuk ayda bitti. Bizanslılar kaleye 'boğaz kesen' dediler.","In the spring of 1452 Sultan Mehmed II built a castle at the narrowest point of the Bosporus, right across from the older fortress on the Asian shore. Its three great towers were raised by three viziers, Çandarlı Halil, Zaganos and Saruja Pasha; the work was done in four and a half months. The Byzantines called it the throat-cutter."
LORE_33O_2_T,Yelken indir,Lower your sail
LORE_33O_2,"Hisarın dibine, kıyıya büyük toplar kondu. Karadeniz'den inen ya da çıkan her gemi yelkenini indirip durmak ve geçiş hakkını ödemek zorundaydı. Şehrin Karadeniz'den gelen tahılı artık Sultan'ın izniyle geçiyordu.","Large guns were set on the shore below the fortress. Every ship coming down from the Black Sea or going up to it had to lower its sails, stop and pay the toll. The grain the city received from the Black Sea now passed only with the Sultan's leave."
LORE_33O_3_T,Urban'ın ilk topu,Urban's first gun
LORE_33O_3,"Dökümcü Urban hizmetini önce İmparator'a sundu; istediği ücret ve malzeme karşılanamadı. Sultan'a geçti. Doukas'a göre Urban'ın Sultan için döktüğü ilk büyük top hisara kondu ve Kasım 1452'de Antonio Rizzo'nun Venedik gemisini tek gülleyle batırdı.","The founder Urban first offered his services to the Emperor, who could not meet his wages or supply his materials. He went over to the Sultan. According to Doukas, the first great gun Urban cast for the Sultan was set up at the fortress, and in November 1452 it sank Antonio Rizzo's Venetian ship with a single ball."
```

Replikler:

```csv
D33O_N_01,"Tolga Bey, 31 Ağustos 1452. Kuşatmaya yedi ay var. Dosyanın ilk sayfası bir inşaat: Boğaz'ın en dar yerinde bir hisar, bugün bitiyor.","Mr Tolga, 31 August 1452. Seven months until the siege. The file's first page is a building site: a fortress at the narrowest point of the Bosporus, finished today."
D33O_T_01,"Kuşatmanın dosyası inşaat ruhsatıyla mı açılıyor? Bizde de öyledir; önce bina, sonra hasar.","The siege file opens with a building permit? Same in our line of work: first the building, then the damage."
D33O_M_01,"Kâtip misin? Kalemi kulağına tak. Akşam ezanına kadar bu kule kapanacak; bana tepede bir göz lazım.","You're a clerk? Tuck your pen behind your ear. This tower closes before the evening call to prayer, and I need an eye up top."
D33O_T_02,"Usta, ben gümrük için geldim. ...Gümrük Kasım'da. Tamam. Tepeye çıkıyorum.","Master, I'm here for the customs. ...Customs starts in November. Fine. I'm going up."
D33O_M_02,"Tepede çıkrık var; taşları o kaldırır. Sen kılavuz ipini tutarsın. Taş sallanmadan 'indir' dersin. Sallanırken dersen duvar kırılır, taş da.","There's a crane up top; it lifts the stones. You hold the guide rope. When the stone stops swinging, you say lower. Say it while it swings and you break the wall, and the stone."
D33O_S_LADDER,"Merdiven gitti! Kâtip, dikmelere tutun, iskeleden tırman!","The ladder's gone! Clerk, grab the poles, climb the scaffold!"
D33O_T_CLIMB,"Serbest tırmanış. Sertifikam yok. Sigortam da yok. Tırmanıyorum.","Free climbing. No certificate. No insurance either. Climbing."
D33O_S_ABOVE,"Aşağıdakiler! Kova gidiyor!","Look out below! Bucket coming down!"
D33O_T_PLANK,"Kalas çatırdıyor. Ben durmazsam o da durmaz.","The plank is cracking. If I don't stop, neither will it."
D33O_M_FALL,"Düştün mü? Alt kat tuttu. Yeniden çık; çıkrık bekliyor.","Fell, did you? The floor below caught you. Up again; the crane is waiting."
D33O_Z_01,"Usta! Halil Paşa'nın kulesi bizden iki sıra önde. Bu tepe ondan geri kalırsa sen de duyarsın, ben de.","Master! Halil Pasha's tower is two courses ahead of us. If this hill falls behind his, you'll hear about it, and so will I."
D33O_H_01,"Zağanos acele eder. Benim kulem denize bakar. Deniz acele etmez, ama her şeyi sonunda o alır.","Zaganos is always in a hurry. My tower looks at the sea. The sea never hurries, but in the end it takes everything."
D33O_T_03,"İki vezir, iki kule, bir yarış. Bizde buna bütçe dönemi denir.","Two viziers, two towers, one race. Where I work we call that budget season."
D33O_T_WIND,"Rüzgâr! Taş sallanıyor, ben sallanıyorum. Birimiz durmalı.","Wind! The stone's swinging and so am I. One of us has to stop."
D33O_M_STONE_1,"Oturdu. Taş da insan gibidir; yerini bulunca susar.","It's set. A stone is like a man; once it finds its place, it goes quiet."
D33O_M_STONE_BAD,"Duvara çarptı! Kaldır, bir daha. Bu duvara yüz yıl sonra da biri bakacak.","It hit the wall! Lift it, again. Someone will still be looking at this wall in a hundred years."
D33O_T_STONE,"Beş yüz yılı geçer, usta. Biletle gezecekler.","More than five hundred, master. They'll buy tickets to walk round it."
D33O_M_DROP,"Kıskaç açıldı! Kaçın aşağıda! ...Kimse yok. Yeni taş!","The tongs opened! Clear below! ...Nobody hurt. New stone!"
D33O_M_DONE,"Kule kapandı! Halil Paşa'nınkinden önce. Bunu kimseye söyleme; Zağanos Paşa'ya ben söylerim.","The tower is closed! Before Halil Pasha's. Don't tell anyone; I'll tell Zaganos Pasha myself."
D33O_M_DONE_LATE,"Ezan okundu. Son taşları ustalar koydu. Üç kule aynı gün kapandı; Sultan böyle istemişti.","There's the call to prayer. The masters set the last stones. All three towers closed the same day; that's how the Sultan wanted it."
D33O_F_01,"Bu hisarın adı Boğazkesen. Bu sudan bundan sonra kim geçerse önce bize sorar.","This fortress is called the Throat-Cutter. From now on, whoever passes on this water asks us first."
D33O_T_04,"Boğaz'ın en dar yeri. Karşıda öbür hisar. Ortadan geçen her gemi iki kalenin arasından geçecek. Gümrük kapısı, ama toplu.","The narrowest point of the Bosporus. The other fortress across the water. Every ship will pass between two castles. A toll gate, with guns."
D33O_FZ_01,"Kâtip! Dizdar Firuz Ağa benim. Kural basit: Karadeniz'den inen de çıkan da yelkeni indirir, kayığımız yanaşır, mal yazılır, hak alınır. İndirmeyene top konuşur.","Clerk! I am Firuz Agha, warden of this fortress. The rule is simple: up from the Black Sea or down, you lower your sail, our boat comes alongside, the cargo is written down, the toll is taken. Whoever won't lower, the gun talks to."
D33O_T_05,"Yelken indir, beyan et, prim öde. Ağam, siz sigortacılığı icat etmişsiniz.","Lower your sail, declare, pay the premium. Agha, you've invented insurance."
D33O_R_01,"Akıntı güneye çeker, kâtip. Ritmi kaçırırsan bizi Galata'ya kadar götürür.","The current pulls south, clerk. Lose the rhythm and it'll carry us all the way to Galata."
D33O_R_ROCKS,"Kayalar! Akıntıburnu! Sağa çek, kâtip, sağa!","Rocks! The Current Point! Pull right, clerk, right!"
D33O_FZ_LATE,"Kayık nerede kaldı? Topçu, boş barut! Uyansınlar!","Where's that boat got to? Gunner, a blank charge! Wake them up!"
D33O_G_ROLL,"Dalga geliyor, tutunun! Merdivende durun!","A swell's coming, hold on! Stay still on the ladder!"
D33O_T_WATER,"Kasım'da Boğaz. Haliç'ten de soğuk. Bunu not ediyorum.","The Bosporus in November. Colder than the Golden Horn. I'm making a note."
D33O_G_01,"Buyurun! Tuzlu balık, kenevir, bal, şarap. Dört kalem, efendim, yazın gitsin.","Welcome aboard! Salt fish, hemp, honey, wine. Four items, sir; write them down and off we go."
D33O_T_FIFTH,"Bu balya hafif. Altında bir sandık. İçinde arbalet okları. Beyanda yok.","This bale is light. There's a crate underneath. Crossbow bolts inside. Not on the declaration."
D33O_G_BRIBE,"Onlar... Galata'ya. Ticaret, efendim, yalnız ticaret. Şu şarap da sizin için; defterde bir satır eksik olsa kimse fark etmez.","Those... are for Galata. Trade, sir, nothing but trade. And this wine is for you; if the ledger were one line short, nobody would notice."
D33O_FZ_DRUM,"Kâtip! Davul bitti, gemi bekletilmez! Mühürle, in!","Clerk! The drum's done, a ship isn't kept waiting! Stamp it and come down!"
D33O_G_HASTE,"Hızlı bir gümrükçü. Hızlıya hediye yakışır; şu şarap sizin.","A quick customs man. Quickness deserves a gift; this wine is yours."
D33O_T_REFUSE,"Beyan eksiksiz. Hediye beyanda yok, bende de yok.","The declaration is complete. There's no gift on it, and none on me."
D33O_G_REFUSE,"Dürüst bir gümrükçü. Cenova'da anlatsam inanmazlar.","An honest customs man. Nobody in Genoa will believe me."
D33O_T_TAKE,"Bir satır eksik, bir şişe fazla. Bizim sektörde buna tolerans denir.","One line short, one bottle extra. In my line of work we call that tolerance."
D33O_N_TAKE,"Tolga Bey, bir satırı silmek tarihi değiştirmez. Ama Büro o şişeyi kayda geçirir.","Mr Tolga, deleting a line doesn't change history. But the Bureau does record that bottle."
D33O_FZ_SHIP,"Kuzeyden bir yelken! Venedik sancağı. Yelkenler dolu... İndirmiyor!","A sail from the north! Venetian colours. Sails full... He's not lowering!"
D33O_RZ_01,"Venedik gemisi! Konstantinopolis'e erzak! Kimseye yelken indirmeyiz!","Venetian ship! Provisions for Constantinople! We lower our sails to no one!"
D33O_FZ_WARN,"Uyarı atışı! Kâtip, küçük topa! Gemiye değil, burnunun önüne. Görsünler, duysunlar.","Warning shot! Clerk, to the small gun! Not at the ship, in front of its bow. Let them see it and hear it."
D33O_T_WARN,"Burnunun önüne. Bir hasar tespit uzmanından ilk kez kaza çıkarması isteniyor.","In front of the bow. For the first time someone's asking a claims assessor to cause an accident."
D33O_FZ_WARN_OK,"Tam önüne! Su burnuna kadar sıçradı. Şimdi indirir.","Right in front! The spray reached the bow. Now he'll lower."
D33O_FZ_WARN_HIT,"Gemiye değdi! Uyarı dedim, kâtip! Uyarı!","You hit the ship! I said a warning, clerk! A warning!"
D33O_FZ_WARN_MISS,"Uzağa düştü. Görmediler bile.","Way off. They didn't even see it."
D33O_RZ_02,"Rüzgâr bizim, akıntı bizim! Yelkenler kalsın!","The wind is ours, the current is ours! Keep the sails up!"
D33O_FZ_BIG,"İndirmiyor. Venedik inadı... Usta! Büyük topa!","He won't lower. Venetian stubbornness... Master! The great gun!"
D33O_U_01,"Sen, kâtip! Tokmağı al. Gülle ağır, top sabırsız. Geminin durduğu yere değil, gideceği yere bak.","You, clerk! Take the rammer. The ball is heavy, the gun impatient. Don't look where the ship is; look where it's going."
D33O_T_URBAN,"Usta Urban. ...Daha tanışmadık, değil mi? Tanışmadık. Tokmak bende.","Master Urban. ...We haven't met yet, have we? We haven't. I've got the rammer."
D33O_U_BACK,"Arkadan çekil! Tunç geri teper, kemik geri tepmez!","Get clear behind! Bronze recoils; bones don't!"
D33O_U_HIT,"Bordada! Tek gülle! Gemi su alıyor!","In the hull! One ball! She's taking water!"
D33O_U_MISS,"Kıçının arkasına! Akıntı hızlı. Yan top, ateş!","Behind her stern! The current is fast. Next gun, fire!"
D33O_U_SECOND,"İşte! İkinci tunç konuştu. Gemi yatıyor.","There! The second bronze has spoken. She's heeling over."
D33O_T_SINK,"Direk yatıyor, arkada kule. Bu kareyi istemezdim ama çekiyorum.","The mast is going over, the tower behind it. I didn't want this shot, but I'm taking it."
D33O_N_PHOTO,Kaydedildi.,Recorded.
D33O_FZ_BOAT,"Sandalla kıyıya çıkıyorlar. Hepsini tutun! Sultan'ın huzuruna gidecekler.","They're coming ashore in the boat. Take them all! They'll go before the Sultan."
D33O_T_BOAT,"Suda boğulan yok. Bunun iyi bir şey olması lazım. Neden öyle gelmiyor?","No one drowned. That ought to be a good thing. Why doesn't it feel like one?"
D33O_N_END,"Kaydedildi, Tolga Bey. Kaynaklar devamını yazar: Kaptan Rizzo ve tayfası Dimetoka'da Sultan'ın huzuruna çıkarıldı ve öldürüldü. Haber şehre de Venedik'e de ulaştı. Kuşatma bu suyun üstünde başladı.","Recorded, Mr Tolga. The sources tell the rest: Captain Rizzo and his crew were brought before the Sultan at Didymoteicho and put to death. The news reached the city and Venice. The siege began on this water."
D33O_T_END,"Gümrük defterine ne yazayım? Venedik gemisi, yük: erzak. Beyan: yok. Hasar: tam.","What do I write in the toll ledger? Venetian ship, cargo: provisions. Declaration: none. Damage: total."
D33O_U_END_OK,"Bu top iyi konuştu, kâtip, sen de iyi dinledin. Sultan daha büyüğünü isteyecek. Kışın Edirne'ye gel; orada sana iş var.","This gun spoke well, clerk, and you listened well. The Sultan will want a bigger one. Come to Edirne in the winter; there's work for you there."
D33O_U_END_BAD,"Gemiye ikinci top yetişti. Olsun. Sultan daha büyüğünü isteyecek; bir gülle yetsin diye. Kışın Edirne'ye gel, kâtip.","The second gun caught the ship. Never mind. The Sultan will want a bigger one, so that one ball is enough. Come to Edirne in the winter, clerk."
```

```csv
UI_RECAP_33O_PREV,"Büro'da Form Z-1453/GT'yi imzaladın, Osmanlı nüshasını seçtin. Nihat seni kuşatmadan yedi ay önceye bıraktı.","At the Bureau you signed Form Z-1453/TW and took the Ottoman copy. Nihat dropped you seven months before the siege."
UI_RECAP_33O_NEXT,"Ocak 1453, Edirne: Urban'ın büyük topu kalıbından çıkıyor. Sultan deneme atışını görmeye gelecek.","January 1453, Edirne: Urban's great gun comes out of its mould. The Sultan will come to watch the test shot."
```

---

## 2. Bölüm 34o — "Tuncun Sesi" (Ocak 1453, Edirne)

### 2.1 Tarihî dayanak

- **Döküm.** Sultan Urban'dan surları yıkacak bir top istedi. Doukas'a göre Urban şunu söyledi: "Babil'in surlarını
  bile toz eder." Top Edirne'de yaklaşık üç ayda döküldü (**D**).
  - Kritovoulos dökümü ayrıntılı anlatır: kilden kalıp ve öz yapılır, demir ve kirişlerle sarılıp toprağa gömülür.
    Tuğla fırınlarda bakır ve kalay körükle eritilip kalıba akıtılır.
  - Kalıp soğuyunca kırılıp top çıkarılır. Çukurdan çıkarmak için çıkrık ve kaldıraç kullanılması işin gereğidir;
    ayrıntıları **oyun kurgusudur**.
- **Gülleler.** Kritovoulos'a göre taş gülleler Karadeniz kıyısından getirilen sert taştan yontuldu. Ölçüleri namluya
  göre ayarlanırdı. Çember kalıpla kontrol **oyun kurgusudur**, işin mantığına dayanır.
- **Deneme atışı.** Ocak 1453'te top Edirne'de, Sultan'ın yeni sarayının kapısının önünde denendi (**D**).
  - Bir gün önce tellallar şehirde dolaşıp halkı uyardı: ses beklenmedik gelip insanları, özellikle gebe kadınları
    korkutmasın.
  - Doukas'a göre ses on mil öteden duyuldu. Gülle bir mil öteye düştü ve toprağa bir kulaç gömüldü. Rakamlar
    Doukas'ındır.
  - Fitilin ateş almaması (hangfire) dönem toplarının bilinen bir tehlikesidir. Bu atışta olduğu **oyun kurgusudur**.
- **Şahi adı:** Osmanlı geleneğinde büyük toplara verilen ad. Oyun 28o'dan beri bu adı kullanıyor.
- **Urban'ın ücreti:** Sultan'ın Urban'a istediğinden fazlasını verdiği yazılır (**D**). Kesin oran kaynaktan kaynağa
  değişir, oyunda sayı söylenmez.
- **Edirne manzarası:** 1447'de bitmiş Üç Şerefeli Cami'nin minareleri ve yapımı süren yeni saray (Sarayiçi), Tunca
  kıyısında.

### 2.2 Yer ve sistemler

**Yeni küçük seviye:** `scripts/level/edirne_yard.gd` (`EdirneYard`). Yaklaşık 450 satır. Karlı bir Tunca kıyısı.
- **Döküm çukuru:** 4 m derin, kenarları kütükle desteklenmiş. İçinde kil gömlekli, yarı gömülü dev namlu.
  - Kil, kırıldıkça ayrılan 12 parça düğümden oluşur. Altındaki tunç ağı parlar.
  - Çukurun üstünde iki ayaklı kalın kirişten bir **A çatısı**. İki ucunda birer **çıkrık** (tambur + dört kollu
    el çarkı + mandal dişlisi). Zincirler namlunun ön ve arka kuşağına iner.
- **Fırınlar ve kömür:** İki tuğla fırın (soğumuş, hafif dumanlı), kömür yığınları.
- **Gülle oluğu:** 20 m eğik ahşap oluk (taşçı tezgâhından çember kalıba). Çemberin yanında "kabul" arabası ve
  "geri" yığını.
  - Oluğun dibinden kar örtülü bir yamaç işçilerin ateşine iner. Kaçak gülle buradan yuvarlanır.
- **Atış sahası:** Topun önünde kazık ve ip güvenlik hattı. Hattın önünde kar örtülü tarla ve kızak kayılan bir
  yamaç; dipte buz tutmuş bir su birikintisi.
  - 380 m ötede bir tepede kırmızı bezli direk (hedef).
- **Arka plan:** Ufukta Edirne. Üç Şerefeli'nin dört minaresi (biri üç şerefeli), kubbeler, saray duvarları, kiremit
  çatılar (`OuterWorld` köy kümeleri, büyük `towns` yarıçapı). Tunca'nın su düzlemi (kenarlarda buz).
- **Kar:** Zemin malzemesi beyaz-gri, ayak izleri (decal, yürüyenlerin arkasında 20 sn). Hafif kar `GPUParticles3D`.
  Ağaçlar çıplak (`Nature`).

**Kullanılan sistemler:**
- 32o'nun basamak zamanlaması (tokmak: işaret yeşildeyken E).
- `RowMeter` (çıkrık ritmi). `BalanceMeter` (namlunun eğimi; buzda kayma).
- `Walker` ve `Person` (kalabalık, kızaklı çocuklar), `Crowd.civilian` (uzak halk), `Horse` + `Person` (Sultan ve
  maiyeti, 29o'daki yol üstü yürüyüş).
- `CannonCrew` + `GunDrill`. Gülle adımı **makara** ile yapılır: CannonCrew'a adım adı ve süresi parametresi
  eklenir ("E basılı tut: makarayla indir", 2,5 sn). Varsayılan davranış değişmez.
- `Fx.slowmo` + `Fx.fov_punch` (atış), `TespitCam`, `Lore.scatter(self, "34o")`.

**Süre hedefi:** 10–12 dk. Durarak konuşma ≤ 2,5 dk.

### 2.3 Fazlar

#### Faz 1a: Kalıbı kır (sabah)

- **Hedef:** `UI_OBJ34O_BREAK`
- **Oynanış:**
  - Tahta tokmakla namlunun üstündeki kil gömleğe **8 darbe**. İşaret yeşil banttayken E. Bant her darbede biraz
    daralır.
  - **40 sn.** İki işçi öbür yandan da vurur.
- **Başarısızlık:**
  - Kırmızıda vurmak tunca değer: **çentik** (`D34O_U_HIT_BAD`), darbe sayılmaz.
  - Süre dolarsa kalan kili işçiler kırar.
  - Çentik ≥ 3 ise Urban'ın son repliği değişir (`D34O_U_END_NICK`).

**Animasyon ve görsel geri bildirim:**
- **Tokmak:** başın üstüne kalkar ve iner. İsabette kil parçası (0,3–0,6 m) kopar, çukura yuvarlanır. Kopan yerde
  tunç parlar, buhar tüter (iç sıcaklık).
- **Çentik:** tunçta parlak bir çizik decal'i, metal sesi, Urban'ın yüz buruşturma hareketi.
- **İşçiler:** öbür yanda tokmak döngüsüyle vurur, onların darbesinde de parça kopar.
- **Zemin:** Çukurun kenarındaki işçiler toprak setin üstündedir (`EdirneYard.ground_y`, çukur kenarı eğimi dahil).

#### Faz 1b: Çukurdan kaldır (sabah)

- **Hedefler:** `UI_OBJ34O_CRANK`, `UI_OBJ34O_PAWL`
- **Oynanış:**
  - Tolga soldaki çıkrıkta, ustabaşı sağdaki. `RowMeter` gibi ibre: yeşilde Space = bir çevirme.
  - Ustabaşı kendi ritminde çevirir (1,1 sn'de bir, ara sıra hızlanır).
  - Üstte bir `BalanceMeter` namlunun **eğimini** gösterir: iki tarafın yükselme farkı. Hedef: iki ucu birlikte
    kaldırmak. Ustabaşının önüne geçersen ya da geri kalırsan ibre kayar.
  - **Mandal:** Her 3 iyi çevirmeden sonra mandalı E ile dişliye indir (1,5 sn içinde).
  - **3 m** yükselince namlu kızağa indirilir.
  - **90 sn.**
- **Başarısızlık:**
  - Eğim kırmızıda 1 sn kalırsa yüksek taraftaki zincir **kayar**: namlu 0,5 m düşer, çukura toz ve kil yağar,
    işçiler geri sıçrar.
  - Mandalı indirmeden kırmızıda çevirirsen tambur geri boşalır (−0,5 m).
  - Süre dolarsa ustalar kaldırır.
  - Sayaç: kayma.

**Animasyon ve görsel geri bildirim:**
- **Çıkrıklar:** el çarkının dört kolu görünür biçimde döner. Tolga'nın ve ustabaşının gövdesi çevirme döngüsünde.
  Tambura zincir sarılır (halkalar tek tek, sarım kalınlaşır).
- **Mandal:** iner ve dişliye oturur, "tık". Boşalınca kol hızla ters döner, işçiler kollarını çeker.
- **Zincirler:** A çatısındaki makaralardan geçip namlunun kuşağına iner. Yükte düz ve titrek, kayınca bir anlığına
  gevşer ve şaklar.
- **Namlu:** yükselirken iki ucunun yüksekliği eğim ibresiyle birebir. Kızağa inerken kızağın kirişleri 2 cm çöker.
- **Zemin:** Kızak ve çıkrık ayakları karda oturur, ayakların çevresinde kar yığılır.

#### Faz 2: Gülle oluğu (öğle)

- **Hedef:** `UI_OBJ34O_BALL`
- **Oynanış:**
  - Taşçı **sekiz gülleyi** oluktan arka arkaya yuvarlar. Her gülle çember kalıbın önündeki takozda durur ve
    **5 sn** bekler.
  - **E = kabul** (işçiler arabaya yuvarlar), **F = geri** (geri yığınına).
  - İkisi kusurlu:
    - Biri **büyük**: çember kalıba yaslanınca halkadan taşar, yakından bakınca görülür.
    - Birinde **kılcal çatlak**: ince koyu çizgi, yalnız 2 m içinden görünür.
  - **Kaçak gülle:** Karar verilmeden 5 sn dolarsa gülle takozu atlar ve yamaçtan **işçilerin ateşine** yuvarlanır.
    Oyuncu koşup önüne geçer, yanından takozu atar (E, 2 m içinde, gülle hızlanmadan 4 sn). Ayrıca 4. gülle senaryo
    gereği her durumda takozu atlar.
- **Başarısızlık:**
  - Kaçak gülleye yetişemezsen gülle ateşe çarpar: kıvılcım, işçiler kaçar, ateş dağılır.
  - Gülle oyuncuya çarparsa −20 can ve yere düşersin.
  - **Büyük gülle kabul edilirse** faz 4'te sıkışır: tokmak 6 iyi vuruş ister (`D34O_U_JAM`).
  - **Çatlak gülle kabul edilirse** dosyaya not düşer (`D34O_M_WRONG`). Atışta kullanılmaz.
  - Sayaç: doğru karar / 8 ve durdurulan kaçak.

**Animasyon ve görsel geri bildirim:**
- **Gülleler:** oluktan yuvarlanırken döner (doku dönüşü görünür), oluk tahtası titrer. Takoza çarpınca durur.
- **Kabul:** iki işçi gülleyi kalaslarla arabaya yuvarlar, araba yaylanır.
- **Geri:** taşçı keskiyle başına geçer, keski-çekiç döngüsü, taş tozu.
- **Kaçak gülle:** karda iz bırakır, hızlanır, tümsekte seker. Takozla durunca kar püskürür.
- **Ateş:** ateş başındaki işçiler oturur, `sit_ground` pozu yerde. Çarpma olursa kalkıp kaçarlar.
- **Zemin:** Oluk, araba ve yığınlar eğimli kar zeminde `ground_y` ile. Güllenin yolu da her karede zemine bastırılır;
  havada uçmaz, kara gömülmez.

#### Faz 3: Tellal ve kızaklar (öğleden sonra)

- **Hedef:** `UI_OBJ34O_CROWD`
- **Oynanış:**
  - Tellal hattın önünde yürüyerek duyurur. Urban'ın kum saati **90 sn**.
  - Tehlike konisinde **altı kişi** var:
    - Dört yetişkin (`Walker`): sepetli kadın, yaşlı adam, odun taşıyan arabacı, köpeğini arayan çırak. Yaklaş ve E:
      "İpin arkasına!" Kişi ipin ardına yürür.
    - İki **kızaklı çocuk**: yamaçtan aşağı kayar, alttaki buz birikintisine varınca yeniden yukarı çıkar. Yamacın
      dibinde **önlerini kes**: kızak 2 m içinden geçerken E, kızak durur, çocuk ipin arkasına yürür.
  - Buzlu birikintiye basan oyuncuda `BalanceMeter` açılır (A/D, 3 sn kayma).
- **Başarısızlık:**
  - Buzda düşersen 3 sn yerde kalırsın, kızak geçip gider.
  - Süre biterse kalanları muhafızlar götürür, Urban bekler (`D34O_U_LATE`).
  - Sayaç: Tolga'nın çıkardığı / 6. Sonuca etkisi yok, dosya notunda görünür.

**Animasyon ve görsel geri bildirim:**
- **Tellal:** yürürken davulcu yanında davul vurur (tokmak döngüsü).
- **Ip ve kazıklar:** güvenlik ipi kazıklar arasında sarkık uzanır, rüzgârda hafif sallanır.
- **Kızaklar:** çocuk kızakta oturur, yamaçta kar püskürterek kayar. Durdurulunca kızak yan döner. Çocuk kalkıp
  karları silker ve ipe doğru koşar.
- **Buz:** birikintinin üstü parlak. Kayan oyuncuda kollar açılır (kamera hafif yatar). Düşüşte kar sıçrar.
- **Kalabalık:** ipin arkasında `Crowd.civilian`. Yürüyenler kar zeminde iz bırakır. Ip arkasına geçen her kişi
  kalabalığa yürüyerek katılır.
- **Zemin:** Yamaç ve birikinti aynı yüzey işlevinden gelir.

#### Faz 4: Deneme atışı (ikindi)

- **Hedefler:** `UI_OBJ34O_LOAD`, `UI_OBJ34O_HANG`, `UI_OBJ34O_PRIME`, `UI_OBJ34O_PHOTO`
- **Oynanış:**
  - Sultan atla gelir, maiyetiyle ipin önünde durur. Kısa bark diyaloğu (Sultan ve Urban, Tolga doldururken).
  - **Doldurma:** barut torbaları (3 kez), tapa, **makara** (E basılı, gülle iner), tokmak (3 iyi vuruş, büyük gülle
    kabul edildiyse 6), nişan.
  - **Nişan:** Hedef 380 m ötedeki direk. Nişan yayı yalnız ilk 120 m'yi gösterir. Oyuncu yüksekliği Urban'ın tahta
    cetveline göre ayarlar ("üç parmak" ipucu).
  - **Ateş almadı (senaryo).** Urban fitili yakar, falya fışırdar ve **söner**. Namlu ağzından ince duman tüter.
    - **Bekle:** Duman bitene kadar topun 4 m içine girme (8–12 sn, rastgele).
    - Erken girersen falya **öksürür**: kıvılcım fışkırır, −25 can, geri savrulursun, bekleme baştan başlar.
  - **Yeniden falya:** Duman bitince topa koş, falyaya taze barut koy (E basılı 2 sn). Sonra **4 sn** içinde ipin
    arkasına kaç; Urban yakar.
    - İpin önünde kalırsan atışın basıncı seni yere düşürür (−30 can, kulak çınlaması efekti 4 sn).
  - **Tespit:** dumanın içinden Sultan ve at. Hedef Sultan'ın başı, pencere atıştan sonraki 15 sn.
- **Sonuç:** Gülle direğin 25 m içine düşerse `hit = true`, değilse kısa düşer.

**Animasyon ve görsel geri bildirim:**
- **Makara:** üç ayaklı kaldıraçtan ip, gülle ip kıskacında. Oyuncu E'yi tuttukça makara döner, gülle namlunun
  ağzına iner ve içeri kayar.
- **Söner fitil:** fitil kıvılcımı yanar, falya deliğinde kısa alev, sonra yalnız ince duman sütunu.
- **Bekleme:** ekranda sayaç yok; duman sütunu görünür biçimde incelir ve kesilir.
- **Öksürme:** falyadan 1 m'lik kıvılcım, Tolga'nın savrulma animasyonu.
- **Atış:** ağır çekim 0,4×, görüş darbesi, büyük alev ve duman. Top 2 m geri teper ve kızağın kütükleri döner. Kar
  yakın dallardan düşer, kalabalık eğilir, at şaha kalkmaz ama başını sallar.
- **Düşüş:** direğin dibinde toprak ve kar sütunu, 1,5 m'lik krater decal'i. Kısa atışta karda uzun bir iz.
- **Sultan ve maiyet:** atlar ve yürüyen muhafızlar kar zeminde (`Horse` ayak yüksekliği zemin örneğiyle; 29o'da
  bunun için zemin işlevi verilmişti).

#### Sonuçlar

| Kod | Koşul | Şema |
|---|---|---|
| **34O.1** Gülle işarete gömüldü | `hit` | `FLOW_34O_1` |
| **34O.2** Gülle karda kısa düştü | aksi hâlde | `FLOW_34O_2` |

Tarih aynıdır: top çalışır, Sultan onu İstanbul'a götürmeyi emreder.

**Otomatik test:** `--chapter=34 --autotest[=bad]`
- **Varsayılan (34O.1):** Bot 8 darbeyi yeşilde vurur. Çıkrığı ustabaşıyla eş çevirir, mandalı indirir. 8/8 doğru
  karar verir, 4. güllenin kaçışını durdurur. Çocukların önünü keser. Dumanın bitmesini bekler. Falyadan sonra ipin
  arkasına koşar. Direği vurur, fotoğrafı çeker.
- **`=bad` (34O.2):** Bot bütün gülleleri kabul eder (sıkışma yolu). Çıkrıkta öne geçer (en az 1 kayma). Dumanda
  erken yaklaşır (öksürme). Kısa nişan alır. Denetimler: `JAM 1`, `CHAIN_SLIP >= 1`, `HANG_SPARK >= 1`,
  `SHOT short`.
- **`VISAUDIT`:** Sultan'ın atı, kalabalık, kızaklar ve yuvarlanan gülle kar zeminine oturmalı.

**Akış şeması** (`UI_FLOW34O_TITLE`):
`FLOW34O_MOULD` → `FLOW34O_LIFT` → `FLOW34O_BALLS` → `FLOW34O_HERALD` → `FLOW34O_SHOT` → {`34O.1`, `34O.2`}.

**Başarım önerisi:** `ACH_OSM_QC` "Kalite Kontrol": sekiz gülle, sekiz doğru karar, hiç kaçak yok.

### 2.4 Konuşanlar

**Yeni anahtar:**

| Anahtar | tr / en | Ses |
|---|---|---|
| `SPK_WOMAN` | Edirneli kadın / Woman of Edirne | Orta yaşlı, sepetli. Meraklı, korkmuyor, sorgulayıcı. Kuru bir halk mizahı var. |

**Mevcut anahtarlar:** `SPK_NIHAT`, `SPK_TOLGA`, `SPK_URBAN`, `SPK_SOLDIER` (çıkrık ustabaşı), `SPK_MASON` (33o'da
eklendi; burada gülle yontan başka bir taşçı), `SPK_HERALD`, `SPK_TOWNSMAN` (yaşlı Edirneli; "Kentli" her şehir için
genel), `SPK_FATIH`.

**Koşullu replikler:**
- `D34O_U_01_ALT` 33O.2 yolunda `D34O_U_01`'in yerine geçer.
- `D34O_T_SULTAN` yalnız Bölüm 12 oynandıysa (`chapter_outcomes.has(12)`) söylenir, yoksa `_ALT`.
- `D34O_U_END_NICK` çentik ≥ 3 ise `D34O_U_END`'in yerine geçer.
- Diğerleri olay bark'larıdır.

**Durarak söylenenler (say):** `N_01`, `T_01`, `U_01`/`_ALT`, `U_02` (açılış, ~40 sn); `N_END`, `U_END`/`_NICK`
(kapanış, ~25 sn). Toplam ≈ 1 dk 10 sn. Sultan ve Urban'ın konuşması bile doldurma sürerken bark olarak geçer. Tabloda 53 anahtar var; dallar ve olay bark'ları yüzünden bir oynayışta ≈ 40'ı duyulur.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D34O_N_01` | SPK_NIHAT | say |
| `D34O_T_01` | SPK_TOLGA | say |
| `D34O_U_01` | SPK_URBAN | say |
| `D34O_U_01_ALT` | SPK_URBAN | say |
| `D34O_U_02` | SPK_URBAN | say |
| `D34O_U_HIT_OK` | SPK_URBAN | bark |
| `D34O_U_HIT_BAD` | SPK_URBAN | bark |
| `D34O_T_02` | SPK_TOLGA | bark |
| `D34O_S_CRANK` | SPK_SOLDIER | bark |
| `D34O_U_TILT` | SPK_URBAN | bark |
| `D34O_U_PAWL` | SPK_URBAN | bark |
| `D34O_U_SLIP` | SPK_URBAN | bark |
| `D34O_U_LIFTED` | SPK_URBAN | bark |
| `D34O_T_REVEAL` | SPK_TOLGA | bark |
| `D34O_M_01` | SPK_MASON | bark |
| `D34O_T_03` | SPK_TOLGA | bark |
| `D34O_M_BIG` | SPK_MASON | bark |
| `D34O_M_CRACK` | SPK_MASON | bark |
| `D34O_M_GOOD` | SPK_MASON | bark |
| `D34O_M_WRONG` | SPK_MASON | bark |
| `D34O_M_RUN` | SPK_MASON | bark |
| `D34O_T_RUN` | SPK_TOLGA | bark |
| `D34O_M_STOP` | SPK_MASON | bark |
| `D34O_M_DONE` | SPK_MASON | bark |
| `D34O_HR_01` | SPK_HERALD | bark |
| `D34O_HR_02` | SPK_HERALD | bark |
| `D34O_W_01` | SPK_WOMAN | bark |
| `D34O_T_W1` | SPK_TOLGA | bark |
| `D34O_W_02` | SPK_WOMAN | bark |
| `D34O_TW_01` | SPK_TOWNSMAN | bark |
| `D34O_T_KIDS` | SPK_TOLGA | bark |
| `D34O_T_ICE` | SPK_TOLGA | bark |
| `D34O_T_CROWD_OK` | SPK_TOLGA | bark |
| `D34O_U_LATE` | SPK_URBAN | bark |
| `D34O_F_01` | SPK_FATIH | bark |
| `D34O_U_F1` | SPK_URBAN | bark |
| `D34O_F_02` | SPK_FATIH | bark |
| `D34O_U_F2` | SPK_URBAN | bark |
| `D34O_T_SULTAN` | SPK_TOLGA | bark |
| `D34O_T_SULTAN_ALT` | SPK_TOLGA | bark |
| `D34O_U_JAM` | SPK_URBAN | bark |
| `D34O_U_HANG` | SPK_URBAN | bark |
| `D34O_T_HANG` | SPK_TOLGA | bark |
| `D34O_U_SPARK` | SPK_URBAN | bark |
| `D34O_U_PRIME` | SPK_URBAN | bark |
| `D34O_U_BLAST` | SPK_URBAN | bark |
| `D34O_U_HIT` | SPK_URBAN | bark |
| `D34O_U_SHORT` | SPK_URBAN | bark |
| `D34O_F_03` | SPK_FATIH | bark |
| `D34O_T_PHOTO` | SPK_TOLGA | bark |
| `D34O_N_END` | SPK_NIHAT | say |
| `D34O_U_END` | SPK_URBAN | say |
| `D34O_U_END_NICK` | SPK_URBAN | say |

### 2.5 Metinler

```csv
UI_CH34O_TITLE,BÖLÜM {N} — TUNCUN SESİ,CHAPTER {N} — THE VOICE OF BRONZE
UI_CH34O_SUB,"Ocak 1453 · Edirne, Tunca kıyısı · Urban'ın döküm yeri","January 1453 · Edirne, on the Tundzha · Urban's foundry"
UI_CH34O_SHOT,"Aynı gün, ikindi · deneme atışı","The same day, mid-afternoon · the test shot"
UI_FLOW34O_TITLE,AKIŞ ŞEMASI — BÖLÜM {N}: TUNCUN SESİ,FLOWCHART — CHAPTER {N}: THE VOICE OF BRONZE
SPK_WOMAN,Edirneli kadın,Woman of Edirne
UI_OBJ34O_BREAK,"Kil kalıbı tokmakla kır (işaret yeşildeyken E) · %d/%d","Break the clay mould with the mallet (E while the marker is green) · %d/%d"
UI_OBJ34O_CRANK,"Çıkrığı ustabaşıyla birlikte çevir (Space, yeşilde) · namluyu düz tut · %d/%d m","Turn the windlass together with the foreman (Space, on green) · keep the barrel level · %d/%d m"
UI_OBJ34O_PAWL,Mandalı indir (E)!,Drop the pawl (E)!
UI_OBJ34O_BALL,Gülleyi çemberle ölç: E kabul · F geri · %d/%d,Gauge the ball against the ring: E accept · F reject · %d/%d
UI_OBJ34O_RUNAWAY,Kaçak gülle! Önüne geç ve takozu at (E),Runaway ball! Get in front of it and throw the chock (E)
UI_OBJ34O_CROWD,Tehlike alanındakileri ipin arkasına al · %d/%d · %d sn,Get the people in the danger zone behind the rope · %d/%d · %d s
UI_OBJ34O_LOAD,"Topu doldur: barut, tapa, makara, tokmak, nişan","Load the gun: powder, wad, hoist, rammer, aim"
UI_OBJ34O_HANG,Ateş almadı! Duman bitene kadar topa yaklaşma,Misfire! Keep away from the gun until the smoke stops
UI_OBJ34O_PRIME,"Falyaya taze barut koy (E basılı), sonra ipin arkasına koş","Prime the touch-hole (hold E), then run behind the rope"
UI_OBJ34O_PHOTO,Tespit et: dumanın içinde Sultan,Record: the Sultan in the smoke
UI_PROMPT34O_STRIKE,E: vur (işaret yeşildeyken),E: strike (when the marker is green)
UI_PROMPT34O_ACCEPT,E: kabul · F: geri,E: accept · F: reject
UI_PROMPT34O_CHOCK,E: takozu at,E: throw the chock
UI_PROMPT34O_SHOO,E: İpin arkasına!,E: Behind the rope!
UI_PROMPT34O_SLED,E: kızağı durdur,E: stop the sled
UI_PROMPT34O_HOIST,E basılı: gülleyi makarayla indir,Hold E: lower the ball with the hoist
UI_PROMPT34O_PRIME,E basılı: falyaya barut,Hold E: prime the touch-hole
FLOW34O_MOULD,Kil kalıp kırıldı,The clay mould is broken
FLOW34O_LIFT,İki çıkrıkla çukurdan,Out of the pit on two windlasses
FLOW34O_BALLS,Gülleler çemberden geçti,The balls go through the ring
FLOW34O_HERALD,Tellal ve kızaklar,The herald and the sleds
FLOW34O_SHOT,"Ateş almayan top, sonra atış","A misfire, then the shot"
FLOW_34O_1,Gülle işarete gömüldü,The ball buried itself at the mark
FLOW_34O_2,Gülle karda kısa düştü,The ball fell short in the snow
UI_CH34O_STATS,Çentik: %d   ·   Zincir kayması: %d   ·   Gülle kararı: %d/%d   ·   Kalabalık: %d/%d   ·   Atış: %s   ·   Dosya: %d/%d sayfa,Nicks: %d   ·   Chain slips: %d   ·   Ball calls: %d/%d   ·   Crowd: %d/%d   ·   Shot: %s   ·   File: %d/%d pages
UI_CH34O_HIT,işarette,on the mark
UI_CH34O_SHORT,kısa,short
SIEGE_DATE_34,Ocak 1453,January 1453
SIEGE_EV_34,"Urban'ın Edirne'de döktüğü büyük top Sultan'ın sarayının önünde denenir. Tellallar halkı önceden uyarır; ses kilometrelerce öteden duyulur.","The great gun Urban cast at Edirne is tested before the Sultan's palace. Heralds warn the people beforehand; the sound is heard for miles."
SIEGE_NOTE_34O_1,"Kalıp kırıldı, top çukurdan çıktı, gülleler ölçüldü, kalabalık ipin arkasındaydı. Top bir kez ateş almadı, ikincisinde aldı. Gülle işarete gömüldü. Ekspertiz raporu: ürün çalışıyor. Ne yazık ki. — T.","The mould was broken, the gun lifted out, the balls gauged, the crowd behind the rope. It misfired once and fired the second time. The ball buried itself at the mark. Assessor's report: the product works. Unfortunately. — T."
SIEGE_NOTE_34O_2,"Kalıp kırıldı, gülleler ölçüldü. Top bir kez ateş almadı. Gülle kısa düştü ama ses düşmedi; bütün Edirne duydu. Ekspertiz raporu: menzil eksik, gürültü fazla. — T.","The mould was broken, the balls gauged. It misfired once. The ball fell short but the sound didn't; all Edirne heard it. Assessor's report: range insufficient, noise excessive. — T."
LORE_34O_1_T,Kilden kalıp,A mould of clay
LORE_34O_1,"Kritovoulos topların dökümünü şöyle anlatır: kilden bir kalıp ve öz yapılır, demir ve kirişlerle sarılıp toprağa gömülür; tuğla fırınlarda bakır ve kalay körükle eritilir ve kalıba akıtılır. Soğuyunca kalıp kırılır ve tunç ortaya çıkar.","Kritovoulos describes how the guns were cast: a mould and a core are made of clay, bound with iron and timber and buried in earth; copper and tin are melted in brick furnaces with bellows and run into the mould. Once it cools, the mould is broken and the bronze appears."
LORE_34O_2_T,Babil'in surları,The walls of Babylon
LORE_34O_2,"Doukas'a göre Sultan Urban'a surları yıkacak bir top dökebilir mi diye sordu; Urban, Babil'in surlarını bile toz edebileceğini söyledi. Ocak 1453'te top Edirne'de denendi. Tellallar halkı uyardı. Doukas sesin on mil öteden duyulduğunu, güllenin bir mil öteye düşüp toprağa bir kulaç gömüldüğünü yazar.","According to Doukas, the Sultan asked Urban whether he could cast a gun to bring down the walls; Urban said it could turn even the walls of Babylon to dust. In January 1453 it was tested at Edirne. Heralds warned the people. Doukas writes that the sound was heard ten miles away and that the ball fell a mile off and sank a fathom into the ground."
LORE_34O_3_T,Taş gülleler,Stone balls
LORE_34O_3,"Büyük topların güllesi demir değil, yontulmuş taştı. Kritovoulos'a göre taş Karadeniz kıyısından getirildi. Her gülle namluya göre ölçülürdü; fazla büyüğü sıkışır, çatlağı atışta dağılırdı.","The great guns fired not iron balls but dressed stone. According to Kritovoulos the stone was brought from the Black Sea coast. Every ball was sized to its barrel; one too big would jam, a cracked one would shatter when fired."
```

Replikler:

```csv
D34O_N_01,"Tolga Bey, Ocak 1453, Edirne. Tunca'nın kıyısı karla kaplı. Urban'ın büyük topu üç ayda döküldü; bugün kalıbından çıkıyor, ikindi vakti Sultan'ın önünde konuşacak.","Mr Tolga, January 1453, Edirne. The banks of the Tundzha are under snow. Urban's great gun took three months to cast; today it comes out of its mould, and by mid-afternoon it speaks before the Sultan."
D34O_T_01,"Ocak, kar, açık hava, dev bir top. Formda kış lastiği kutucuğu var mı?","January, snow, open air, a giant gun. Is there a box on the form for winter tyres?"
D34O_U_01,"Kâtip! Boğaz'dan sağ geldin. Bak: toprağın altında benim en büyük çocuğum. Kil gömleğini bugün çıkaracağız.","Clerk! You made it from the Bosporus. Look: under this earth lies my biggest child. Today we take off its coat of clay."
D34O_U_01_ALT,"Kâtip! Boğaz'daki gemiyi ikinci top batırmıştı, hatırlıyor musun? Bu çocuk için ikinci top olmayacak. Kil gömleğini çıkarıyoruz.","Clerk! At the Bosporus it took a second gun to sink that ship, remember? For this child there will be no second gun. We take off its coat of clay."
D34O_U_02,"Önce kili kır, yumuşak vur; tunca vurursan tunç sana küser. Sonra çukurdan kaldıracağız: iki çıkrık, iki adam, bir top. Biri öne geçerse top yan yatar, zincir kayar.","First break the clay, strike soft; hit the bronze and the bronze will hold it against you. Then we lift it out: two windlasses, two men, one gun. If one of you gets ahead, the gun tilts and the chain slips."
D34O_U_HIT_OK,"İyi. Kil dökülüyor, tunç parlıyor.","Good. The clay falls away, the bronze shines."
D34O_U_HIT_BAD,"Ah! Tunca değdin! Bir çentik. Topun da insanın da çentiği kalır.","Ah! You hit the bronze! A nick. Guns and men both keep their nicks."
D34O_T_02,"Kalıbı kırarak teslim almak. Bizim sektörde hasarlı mal teslim alınmaz; burada hasarsız alınamıyor.","Taking delivery by breaking the packaging. In my line of work you never accept damaged goods; here you can't get them undamaged."
D34O_S_CRANK,"Benimle çevir, kâtip! Öne geçme, geri kalma!","Turn with me, clerk! Don't get ahead, don't fall behind!"
D34O_U_TILT,"Yan yatıyor! Yavaş! Zincir kayacak!","It's tilting! Slowly! The chain's going to slip!"
D34O_U_PAWL,"Mandal! Mandalı indir, yoksa tambur geri boşalır!","The pawl! Drop the pawl or the drum runs back!"
D34O_U_SLIP,"Kaydı! Herkes geri! ...Kimseye bir şey olmadı. Baştan, yavaş.","It slipped! Everyone back! ...No one's hurt. From the top, slowly."
D34O_U_LIFTED,"Havada! Şimdi kızağa... yavaş... yerinde. Sultan buna Şahi diyecek. Ben çocuğum diyorum.","It's up! Now onto the sled... slowly... in place. The Sultan will call it the Shahi. I call it my child."
D34O_T_REVEAL,"Namluya eğilip seslendim. Yankı geri gelmedi. Belki hâlâ gidiyordur.","I leaned into the barrel and called out. The echo didn't come back. Maybe it's still going."
D34O_M_01,"Gülleler geliyor, kâtip! Çemberden geçen top için, geçmeyen geri. Çatlağa da bak. Durdurup bekletme; gülle beklemez, yuvarlanır.","Balls coming, clerk! Whatever passes the ring goes to the gun, whatever doesn't goes back. Watch for cracks too. Don't keep them waiting; a ball doesn't wait, it rolls."
D34O_T_03,"Kalite kontrol. Sonunda kendi işimi yapıyorum.","Quality control. At last, my actual job."
D34O_M_BIG,"Çembere takıldı. Büyük. Namluda sıkışır.","It catches on the ring. Too big. It'd jam in the barrel."
D34O_M_CRACK,"Çatlak. Kılcal ama çatlak. İyi gördün.","Cracked. Hairline, but cracked. Good eye."
D34O_M_GOOD,"Temiz. Arabaya.","Clean. Onto the cart."
D34O_M_WRONG,"Onu kabul ettin ha? Usta görmesin.","You passed that one? Don't let the master see."
D34O_M_RUN,"Kaçtı! Gülle kaçtı! Ateşe gidiyor! Takozu at, kâtip!","It's loose! The ball's loose! It's heading for the fire! Throw the chock, clerk!"
D34O_T_RUN,"Yarım ton taş, buzlu yokuş, bir sigortacı. Hangisi önce durur, göreceğiz.","Half a tonne of stone, an icy slope, one insurance man. We'll see which stops first."
D34O_M_STOP,"Durdu! Takoz tuttu. Ateştekiler sana bir kâse çorba borçlu.","It's stopped! The chock held. The men at the fire owe you a bowl of soup."
D34O_M_DONE,"Sekiz gülle, sekiz karar. Kâtiplerin en işe yarayanı sen çıktın.","Eight balls, eight calls. You're the most useful clerk I've ever met."
D34O_HR_01,"Duyduk duymadık demeyin! Sultan'ın topu bugün konuşacak! Gürültüden korkmayın, ipin önüne geçmeyin!","Hear ye, and say not you did not hear! The Sultan's gun speaks today! Be not afraid of the noise, and do not cross the rope!"
D34O_HR_02,"Gebe olan, hasta olan, yaşlı olan içeri girsin! Gök gürlemesi değildir, toptur!","Let those with child, the sick and the old stay indoors! It is not thunder, it is the gun!"
D34O_W_01,"Kâtip efendi, bu top Edirne'yi mi vuracak, İstanbul'u mu?","Master clerk, is this gun going to hit Edirne, or Istanbul?"
D34O_T_W1,"Bugün sadece karşıdaki tepeyi, teyze. İpin arkasına, lütfen.","Today only the hill over there, auntie. Behind the rope, please."
D34O_W_02,"Tepe ne yaptı ki?","And what did the hill ever do?"
D34O_TW_01,"Ben Murad Han'ın toplarını da gördüm. Hiçbiri bunun yarısı kadar değildi.","I saw Sultan Murad's guns too. None of them was half this size."
D34O_T_KIDS,"Çocuklar! Kızakla ipin önüne değil! Benim kızaklarla ilgili kötü anılarım var.","Children! Not in front of the rope with that sled! I have bad memories involving sleds."
D34O_T_ICE,"Buz! Buz da kötü anılarım arasına giriyor.","Ice! Ice is joining my bad memories too."
D34O_T_CROWD_OK,"Herkes ipin arkasında. Sahada şimdi tek risk benim.","Everyone's behind the rope. The only risk left on the field is me."
D34O_U_LATE,"Kalabalık hâlâ önde! Muhafızlar, çekin şunları! Top bekler, Sultan beklemez.","The crowd's still in front! Guards, move them back! The gun can wait, the Sultan won't."
D34O_F_01,"Usta Urban. Bunun gibisini Bizans'a da sunmuştun, değil mi?","Master Urban. You offered something like this to Byzantium as well, didn't you?"
D34O_U_F1,"Sundum, Sultanım. Ücretimi veremediler, tuncumu alamadılar. Siz istediğimden fazlasını verdiniz.","I did, my Sultan. They couldn't pay my wages or buy my bronze. You gave me more than I asked."
D34O_F_02,"Bana surları yıkacak bir top demiştin.","You promised me a gun that would bring down walls."
D34O_U_F2,"Babil'in surlarını bile, Sultanım. Bugün o tepeyi göreceksiniz, baharda surları.","Even the walls of Babylon, my Sultan. Today you'll see that hill; in the spring, the walls."
D34O_T_SULTAN,"Üç ay sonra otağında karşısında duracağım. O bunu bilmiyor. Ben de tam bilmiyorum aslında.","In three months I'll stand before him in his tent. He doesn't know that. To be honest, neither do I, quite."
D34O_T_SULTAN_ALT,"Yirmi yaşında. Atın üstünde dimdik. Bu topu dünyada ilk dinleyecek kişi o.","Twenty years old. Straight as a spear on his horse. He'll be the first person in the world to hear this gun."
D34O_U_JAM,"Sıkıştı! Bu gülleyi kim geçirdi? ...Ben söylemeyeyim, sen bil. Tokmağa yüklen!","It's jammed! Who passed this ball? ...I won't say; you know. Lean on that rammer!"
D34O_U_HANG,"Ateş almadı! Yaklaşma! İçeride için için yanıyor olabilir. Duman bitene kadar bekle.","It didn't fire! Stay back! It may be smouldering inside. Wait until the smoke stops."
D34O_T_HANG,"Bizim sektörde buna gizli hasar denir. Beklemeyi biliyorum. Bekliyorum.","In my line of work we call this latent damage. I know how to wait. I'm waiting."
D34O_U_SPARK,"Geri! Kıvılcım! Sana bekle dedim!","Back! Sparks! I told you to wait!"
D34O_U_PRIME,"Duman bitti. Falyaya taze barut, sonra ipin arkasına koş! Ben yakıyorum!","The smoke's stopped. Fresh powder in the touch-hole, then run behind the rope! I'm lighting it!"
D34O_U_BLAST,"Kâtip! Sağır mı oldun, yanık mı? ...İkisi de biraz. Kalk.","Clerk! Deaf or burnt? ...A bit of both. Get up."
D34O_U_HIT,"Direğin dibine! Toprağa gömüldü! Kulaç kulaç gömüldü!","At the foot of the post! It buried itself! Fathoms deep!"
D34O_U_SHORT,"Kısa düştü, kara gömüldü. Olsun. Ses yeter; bütün Edirne duydu.","Short, it buried itself in the snow. Never mind. The sound is enough; all Edirne heard it."
D34O_F_03,"Bunu İstanbul'a götür, usta. Yol uzun, kış uzun.","Take it to Istanbul, master. The road is long, and so is the winter."
D34O_T_PHOTO,"Duman, at, Sultan. Kar bile bir an yağmayı unuttu.","Smoke, horse, Sultan. Even the snow forgot to fall for a moment."
D34O_N_END,"Kaydedildi. Doukas sesin on mil öteden duyulduğunu, güllenin bir mil öteye düşüp toprağa bir kulaç gömüldüğünü yazar. Rakamlar Doukas'ın. Kulak çınlamanız sizin.","Recorded. Doukas writes that the sound was heard ten miles away and the ball fell a mile off and sank a fathom into the ground. The numbers are Doukas's. The ringing in your ears is yours."
D34O_U_END,"Şimdi en zor iş: bu çocuk Edirne'den İstanbul'a yürüyecek. Kâtip, gün say, yol yaz. İki ay sürer.","Now the hardest part: this child has to walk from Edirne to Istanbul. Clerk, count the days, write down the road. It'll take two months."
D34O_U_END_NICK,"Üç çentik. Topun yüzünde senin imzan var, kâtip. Şimdi bu çocuk İstanbul'a yürüyecek; sen de yanında.","Three nicks. Your signature is on this gun's face, clerk. Now this child walks to Istanbul, and you walk beside it."
```

```csv
UI_RECAP_34O_PREV,"Boğazkesen'in son taşlarını koydun; Kasım'da yelken indirmeyen Venedik gemisi Urban'ın topuyla battı.","You set the last stones of the Throat-Cutter; in November a Venetian ship that wouldn't lower sail was sunk by Urban's gun."
UI_RECAP_34O_NEXT,"Top Edirne'de konuştu. Şubat–Mart: altmış öküz, yüzlerce adam ve iki aylık yol, İstanbul'a.","The gun has spoken at Edirne. February–March: sixty oxen, hundreds of men and two months on the road to Istanbul."
```

---

## 3. Bölüm 35o — "Edirne Yolu" (Şubat–Mart 1453, Trakya)

### 3.1 Tarihî dayanak

- **Konvoy.** Doukas'a göre top Şubat başında Edirne'den yola çıktı.
  - Otuz araba birbirine bağlandı, altmış öküz çekti.
  - Topun iki yanında iki yüz adam yürüdü; yolda dengede kalsın diye.
  - Önden elli dülger ve iki yüz işçi gidiyordu: dereler üstüne ahşap köprüler kurup yolu düzelttiler.
  - Top iki ayda şehrin yaklaşık beş mil yakınına vardı.
- **Karaca Bey.** Rumeli Beylerbeyi Karaca Bey önceden gönderildi ve Trakya'daki Bizans kalelerini aldı:
  Karadeniz kıyısında Mesembria, Anchialos ve Vizye kolayca düştü. Selymbria (Silivri) ve Epibatos direndi ve kuşatma
  boyunca dayandı (**R**). Oyun Karaca Bey'i yalnız yoldan geçen bir atlı olarak gösterir.
- **Sultan:** 23 Mart'ta Edirne'den çıktı, 5 Nisan'da surların önündeydi (**R**). 28o ertesi gün açılır.
- **Kurgu olan ayrıntılar:** Taşkın dere, kütükler, kopan halat, yokuştaki fren kazıkları, kurt sesine ürken öküzler.
  Doukas yalnız adam, öküz, araba ve köprü sayısını verir; bunların hepsi **oyun kurgusudur**, dönemin ağır nakliye
  pratiğine dayanır.

### 3.2 Yer ve sistemler

**Yeni küçük seviye:** `scripts/level/thrace_road.gd` (`ThraceRoad`). Yaklaşık 450 satır. Sırtlar arasından inen
300 m'lik bir yol parçası:
- **Dere ve köprü:** Taşkın dere: 14 m genişlik, hızlı akıntı, köpük, kahverengi su.
  - Yarım kalmış ahşap köprü: dört sehpa kurulu, üstünde iki uzun **kiriş** (0,35 m genişlik, yürünür). Kalas
    yuvaları boş.
  - Dere boyunca yukarıdan kütük ve dal gelir: 60 m yukarıdan doğar, akıntıyla iner, köprüden sonra kaybolur.
- **Çamur:** Karşı kıyıda çamurlu bir düzlük. Teker izleri, su birikintileri.
- **İniş:** 70 m'lik yokuş, eğim ~12°. Yol kenarında iki **fren kazığı**: kalın meşe direk, halat sarılı. Yolun iki
  yanında yan hendek.
- **Konak:** Yokuşun dibinde gece konağı. Ateşler, öküz sıraları (kazığa bağlı), çadırlar. Kenarında çalılık ve koru.
- **Ufuk:** `OuterWorld` ile tarla lekeleri, köyler, uzak sırtlar. İlk bahar: çimen yer yer yeşil, ağaçlar çıplak.

**Konvoy:**
- 28o'nun Şahi namlusu ve kızağı (`chapter28o.gd` kızak kurucusu). Bu kurucu ortak bir statik işleve taşınır, iki
  bölüm aynı topu görür.
- Namlunun altında birbirine bağlı **altı görünür araba** (otuzu temsil eder): tekerlekler, dingiller.
- Önde **çift çift öküz**: `Slipway._ox` statik yapılır ve bacak yürüyüşü eklenir. Yakında 12 canlı öküz, uzakta
  `MultiMesh` sıra. Boyunduruklar, çanlar.
- Yanlarda halat tutan iki sıra adam (`Crowd.ottoman`, `arm: ""`; yakında canlı `Soldier`, çekme pozu).

**Kullanılan sistemler:**
- 18'in halat bağlama zamanlaması (iki vuruş, E). `BalanceMeter` (kirişte denge; fren ipi; öküz ipi).
- 28o'nun "hey-yap" çekişi (`RowMeter`, Space). 26o'nun düşen taş uyarısının mantığı (kopan halat için kamçı alanı).
- `Night.campfire/torch`, `TespitCam`, `Lore.scatter(self, "35o")`.

**Süre hedefi:** 10–12 dk. Durarak konuşma ≤ 2 dk.

### 3.3 Fazlar

#### Faz 1: Taşkın (sabah)

- **Hedefler:** `UI_OBJ35O_LASH`, `UI_OBJ35O_LOG`
- **Oynanış:**
  - Tolga köprünün **kirişinin üstündedir**; her adımda `BalanceMeter` açıktır. Su altta 2 m, akıntının sesi
    yüksek.
  - Dülgerler kalasları kıyıdan **kızakla iterek** köprünün ucuna sürer. Tolga her kalası sehpaya **iki bağla**
    bağlar (18'deki zamanlama: işaret yeşildeyken E, iki kez). Sonra kalasın üstüne bir adım ilerler.
  - **Altı kalas**, **4 dk**. Öküz çanları yaklaşır (ses yükselir).
  - **Kütükler:** 8–12 sn'de bir dere yukarısından kütük ya da dal yığını gelir. 3 sn önce sıçrama ve "KÜTÜK!" uyarısı
    çıkar. Sehpanın önündeki yeşil halkaya girdiğinde **sırıkla it** (E).
- **Başarısızlık:**
  - Kaçan bağ = gevşek kalas (sarı işaret). Dülger uyarır. Oyuncu geri dönüp yeniden bağlayabilir (E).
  - Kaçan kütük sehpaya çarpar: köprü sarsılır, ibre sert itilir, **en son bağlanan kalasın bir bağı çözülür**.
  - Kirişten düşen oyuncu **dereye** düşer: akıntı 15 m sürükler. Kıyıdan uzatılan ipe E ile tutunursun, −15 can,
    8 sn kayıp.
  - Süre biterse dülgerler kalan kalasları gevşek döşer.
  - Konvoy geçerken gevşek kalas başına bir gıcırtı. **≥ 2 gevşek kalas** → bir teker kalasları döndürüp dereye iner
    (`D35O_D_BREAK`). Faz 2 bir demet fazla ve 1 kaymayla başlar.

**Animasyon ve görsel geri bildirim:**
- **Kalas:** kızakta kayar (sürtünme tozu), uç kısmı sehpanın üstüne oturur.
- **Bağ:** her E'de ip sehpanın direğine **görünür biçimde sarılır** (sarım halkaları). İki sarım ve bir **düğüm**
  ağı. Gevşek bağda halkalar sarkık ve kalas hafif oynar (0,5 Hz).
- **Kütükler:** suda dönerek akar, köpük ve dalga bırakır. İtilen kütük yön değiştirir, sehpanın yanından geçer.
  Çarpan kütük sehpayı titretir (kamera sarsıntısı), dökülen talaş suya düşer.
- **Dülgerler:** kıyıda iki kişi kızağı iter (öne eğik, adım döngüsü), biri çekiçle sehpa takozlarını çakar.
- **Suya düşüş:** sıçrama, Tolga suyun yüzünde sürüklenir (yüzme pozu). Kıyıdan atılan ip gerçek bir ip olarak
  uçar, suya düşer. Tutulunca gerilir ve Tolga çekilir.
- **Zemin:** Kıyıdaki işçiler eğimli çamur kıyıdadır, sehpa ayakları su içindedir. Görünür su çizgisi ve köpük
  halkası.

#### Faz 2: Çamur (öğle)

- **Hedefler:** `UI_OBJ35O_BUNDLE`, `UI_OBJ35O_HEAVE`
- **Oynanış:**
  - Konvoy geçer. Öndeki araba karşı kıyıda çamura oturur ve **yavaşça batar**: çamur göstergesi 30 sn'de dolar,
    dolarsa her çekiş daha az ilerletir.
  - Yol kenarındaki yığından (5 m) **üç demet** (köprü kırıldıysa dört) al, ön tekerin önüne at (E). Demet elde
    %30 yavaş; kısa.
  - Sonra **"hey-yap"**: `RowMeter`, yeşilde Space. İyi çekiş arabayı 1,5 m ilerletir. **12 m.**
  - **Halat gerilimi:** Kırmızıda basılan her çekiş halatın gerilim çubuğunu doldurur. Dolunca **"HALAT!"**: 0,8 sn
    içinde kırmızı kamçı alanından çık.
- **Başarısızlık:**
  - Demet atılmadan çekmek ya da kırmızıda çekmek arabayı 1 m geri kaydırır (**kayma**).
  - Kamçı alanında kalırsan −20 can ve yere düşersin. Halat yeniden bağlanır, 6 sn kayıp.

**Animasyon ve görsel geri bildirim:**
- **Araba:** tekerlek çamura gömülür (tekerin alt üçte biri görünmez, çevresinde çamur halkası). Çekişte teker
  döner, çamur sıçratır.
- **Halatlar:** arabadan öküzlerin boyunduruğuna ve yan sıralardaki adamlara **gergin halatlar**. Hey-yap'ta hepsi
  aynı anda gerilir, adamlar geriye yaslanır, öküzler başını öne indirir ve ayak kazır.
- **Demet:** tekerin önüne atılınca yayılır, ezilince dallar kırılır (çıtırtı, kırık dal parçaları).
- **Kopan halat:** iki parçaya ayrılır, uçları yerde kıvrılır. Adamlar yere düşer ve kalkar.
- **Zemin:** Adam sıraları ve öküzler çamur ve kıyı eğiminde `ThraceRoad.ground_y` ile. Ayakları çamura 5 cm gömülür
  (bilerek, çamur decal'iyle), yerin altından görünmez.

#### Faz 3: Yokuş (ikindi; "Aynı gün, ikindi" kartı)

- **Hedefler:** `UI_OBJ35O_BRAKE`, `UI_OBJ35O_POST`
- **Oynanış:**
  - Yokuşun başı. Fren halatı kazığa sarılı, ucu Tolga'nın elinde.
  - **`BalanceMeter`**: ibre arabanın hızıdır. **E basılı = sık** (ibre sola, yavaşlar), **bırak = gevşet**
    (ibre sağa).
  - Teker izleri ve tümsekler 3–5 sn'de bir ibreyi sağa iter.
  - Karaca Bey yoldan atla geçer (bark). Atının ürkmesi ibreyi bir kez sert iter.
  - Yokuşun yarısında halat **ikinci kazığa** aktarılır: Urban "Aktar!" der, oyuncu 6 m yürüyüp E'ye basar, **6 sn**
    içinde. Bu arada ibre kendi başına sağa kayar.
  - **75 sn.**
- **Başarısızlık:**
  - Kırmızı sağda ≥ 1 sn = araba kaçar: adamlar halata asılır, araba **yan hendeğe** kayar (**kayma**), konvoy durur,
    15 sn çıkarma sahnesi.
  - Kırmızı solda ≥ 1,5 sn = halat gerilir, öküzler böğürür. İlki uyarıdır, ikincide halat kopar (yine kayma).
  - Yokuşun sonunda sayaç kapanır: kayma = faz 2 + faz 3.

**Animasyon ve görsel geri bildirim:**
- **Kazık:** halat kazığa üç tur sarılı. Sıkınca sarımlar kazığın kabuğunu ezer, kazıktan **duman ve talaş** çıkar
  (sürtünme). Gevşetince halat kazıkta kayar.
- **Halat:** kazıktan arabanın arka dingiline uzanan gergin ip. Gerilim arttıkça titreşim artar.
- **Öküzler:** yokuş aşağı geriye yaslanarak yürür (bacaklar öne kilitli). Böğürmede baş kalkar.
- **Kaçış:** arabanın tekerleri hızlanır, iki yandaki adamlar halatla birlikte sürüklenir (ayaklar kayar). Araba
  hendeğe kayınca 10° yatar, namlu kızakta kaymaz (bağlı; zincirler görünür).
- **Aktarma:** Tolga halatı omzuna alır, ikinci kazığa yürür, üç tur sarar (el hareketi).
- **Zemin:** Yokuşta her araba tekerleği ve her öküz ayağı yol yüzeyinde. Arabalar yokuşun eğimine göre eğilir.
  `VISAUDIT` bunu yokuş boyunca denetler.

#### Faz 4: Gece konağı (gece)

- **Hedefler:** `UI_OBJ35O_OXEN`, `UI_OBJ35O_PHOTO`
- **Oynanış:**
  - Ateşler yanar, öküzler kazıklara bağlıdır. Koruda **kurt uluması** duyulur.
  - **Üç öküz** (Sarıkız, Karabaş, Benekli) ipini koparıp **kaçar**: biri ateşe, biri çadırlara, biri koruya.
  - Her birini **kovala**: sürüklenen ipin ucu yerde. 1,5 m içinde E ile ipi yakala.
  - Sonra **tut**: `BalanceMeter`, ibre ipin gerilimi. Ortada tutarsan öküz yavaşlar ve 4 sn'de durur. Durunca adını
    söyle (E: `D35O_T_CALM`), öküz sakinleşir.
  - **2 dk.** Arabacı Durmuş birini kendisi yakalar, oyuncu öbür üçünü yakalar.
  - Sonra **tespit karesi**: meşaleler arasında kızaktaki top, önünde yatan öküzler. Hedef namlunun ağzı; serbest,
    süre yok.
  - Urban'ın gün sayımı ve Nihat'ın kaydı.
- **Başarısızlık:**
  - İbre sağda kırmızı (fazla gevşek): öküz ipi çeker, elden çıkar, yeniden yakalarsın.
  - İbre solda kırmızı (fazla sert): yüzüstü çamura sürüklenirsin, 3 sn, −10 can.
  - Süre biterse arabacılar kalanları yakalar.
  - Sayaç: yakalanan öküz / 3.

**Animasyon ve görsel geri bildirim:**
- **Kopan ip:** kazıkta ipin yarısı kalır, öbür yarısı öküzün boynundan sürüklenir; yerde iz bırakır.
- **Öküzler:** kaçarken dörtnala değil, ağır tırıs. Baş aşağı, çanlar yüksek sesle çalar. Ateşe koşan öküz kıvılcım
  saçar, çadıra koşan çadır ipini koparır (çadır yana yatar).
- **Tutma:** ip öküzün boynundan Tolga'nın eline gerilir. Tolga geriye yaslanır, ayakları çamurda kayar (iz). Öküz
  durunca başını sallar, burnundan buhar çıkar (soğuk gece).
- **Sakinleşme:** Tolga elini öküzün boynuna koyar, öküz başını indirir.
- **Fotoğraf:** öküzler yatar (yatış pozu, `Slipway._ox`'a eklenir), meşalelerin ışığı namluda titrer.
- **Zemin:** Konak hafif eğimli. Ateş halkasındaki oturanlar (`sit_ground`) ve yatan öküzler yere oturur.

#### Sonuçlar

| Kod | Koşul | Şema |
|---|---|---|
| **35O.1** Top yokuşu kaymadan indi | toplam kayma ≤ 1 **ve** köprü kırılmadı | `FLOW_35O_1` |
| **35O.2** Top bir gün geç kaldı | aksi hâlde | `FLOW_35O_2` |

Tarih aynıdır: top Nisan başında surların önündedir. Fark dosya notunda ve `D35O_U_END_*`'dadır. Öküz sayısı
istatistik satırında ve bir bark'ta görünür.

**Otomatik test:** `--chapter=35 --autotest[=slip]`
- **Varsayılan (35O.1):** Bot 6 kalası iki bağla bağlar, gelen her kütüğü iter. 3 demet atar, 8 iyi çekiş yapar
  (kırmızı yok). İbreyi ortada tutar, kazığı 4 sn'de aktarır. Üç öküzü yakalar, kareyi çeker.
- **`=slip` (35O.2):** Bot iki kalası tek bağla bırakır ve bir kütüğü kaçırır (köprü kırılır). Kirişten bir kez
  düşer. Kırmızıda çeker (halat kopar). Kazık aktarmasında 8 sn bekler (kayma). Denetimler: `BRIDGE broke`,
  `SWEPT >= 1`, `ROPE_SNAP >= 1`, `SLIPS >= 2`.
- **`VISAUDIT`:** Öküzler, araba tekerlekleri ve ip tutan adamlar yol yüzeyine oturmalı (yokuşta ve çamurda da).
  Slipway'deki "ırgat askerleri yamaçta havada" hatası tekrarlanmasın. Her ipin iki ucu tanımlı ve görünür olmalı
  (`ROPECHECK`: uzunluğu 0 ya da ucu `INF` olan ip satır basar).

**Akış şeması** (`UI_FLOW35O_TITLE`):
`FLOW35O_BRIDGE` → `FLOW35O_MUD` → `FLOW35O_SLOPE` → `FLOW35O_CAMP` → {`35O.1`, `35O.2`}.

**Başarım önerisi:** `ACH_OSM_ROAD` "Yol Kâtibi": köprüde hiç gevşek kalas yok, dereye hiç düşmedin, yokuşta hiç
kırmızı yok.

### 3.4 Konuşanlar

**Yeni anahtarlar:**

| Anahtar | tr / en | Ses |
|---|---|---|
| `SPK_DULGER` | Dülgerbaşı İlyas / İlyas, Master Carpenter | Kırk yaşında, hızlı konuşan, sürekli ölçen ustabaşı. Her şeyi "bunun üstünden tunç geçer mi" diye tartar. |
| `SPK_DROVER` | Arabacı Durmuş / Durmuş the Drover | Yaşlı, yavaş, öküzlerle konuşur gibi insanlarla da konuşur. Altmış öküzün adını bilir. |
| `SPK_KARACA` | Karaca Bey / Karaja Bey | Rumeli Beylerbeyi, atlı. Kısa, emir veren, aceleci. İki replik. |

**Mevcut anahtarlar:** `SPK_NIHAT`, `SPK_TOLGA`, `SPK_URBAN`.

**Koşullu replikler:**
- `D35O_D_CREAK` yalnız 1 gevşek kalasta, `D35O_D_BREAK` ≥ 2'de söylenir.
- `D35O_U_SLOPE_OK` / `D35O_U_SLIDE` ve `D35O_U_END_OK` / `_BAD` sonuca göre seçilir.
- Diğerleri olay bark'larıdır.

**Durarak söylenenler (say):** `N_01`, `T_01`, `D_01` (açılış, ~35 sn); `U_SLOPE`, `T_SLOPE` (yokuş başı, ~12 sn);
`U_DAY`, `T_DAY`, `U_END_*`, `N_END`, `T_END` (kapanış, ~40 sn). Toplam ≈ 1,5 dk.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D35O_N_01` | SPK_NIHAT | say |
| `D35O_T_01` | SPK_TOLGA | say |
| `D35O_D_01` | SPK_DULGER | say |
| `D35O_D_LASH_OK` | SPK_DULGER | bark |
| `D35O_D_LASH_BAD` | SPK_DULGER | bark |
| `D35O_D_LOG` | SPK_DULGER | bark |
| `D35O_T_LOG` | SPK_TOLGA | bark |
| `D35O_D_HITLOG` | SPK_DULGER | bark |
| `D35O_T_SWEPT` | SPK_TOLGA | bark |
| `D35O_T_BRIDGE` | SPK_TOLGA | bark |
| `D35O_DR_01` | SPK_DROVER | bark |
| `D35O_D_CREAK` | SPK_DULGER | bark |
| `D35O_D_BREAK` | SPK_DULGER | bark |
| `D35O_U_01` | SPK_URBAN | bark |
| `D35O_T_MUD` | SPK_TOLGA | bark |
| `D35O_U_HEAVE` | SPK_URBAN | bark |
| `D35O_U_SLIP` | SPK_URBAN | bark |
| `D35O_U_ROPE` | SPK_URBAN | bark |
| `D35O_U_SNAP` | SPK_URBAN | bark |
| `D35O_T_SNAP` | SPK_TOLGA | bark |
| `D35O_U_FREE` | SPK_URBAN | bark |
| `D35O_U_SLOPE` | SPK_URBAN | say |
| `D35O_T_SLOPE` | SPK_TOLGA | say |
| `D35O_K_01` | SPK_KARACA | bark |
| `D35O_U_K1` | SPK_URBAN | bark |
| `D35O_K_02` | SPK_KARACA | bark |
| `D35O_U_POST` | SPK_URBAN | bark |
| `D35O_U_RUN` | SPK_URBAN | bark |
| `D35O_U_TIGHT` | SPK_URBAN | bark |
| `D35O_U_SLIDE` | SPK_URBAN | bark |
| `D35O_U_SLOPE_OK` | SPK_URBAN | bark |
| `D35O_DR_SPOOK` | SPK_DROVER | bark |
| `D35O_T_CALM` | SPK_TOLGA | bark |
| `D35O_DR_GOT` | SPK_DROVER | bark |
| `D35O_T_MUDFALL` | SPK_TOLGA | bark |
| `D35O_DR_03` | SPK_DROVER | bark |
| `D35O_T_PHOTO` | SPK_TOLGA | bark |
| `D35O_U_DAY` | SPK_URBAN | say |
| `D35O_T_DAY` | SPK_TOLGA | say |
| `D35O_U_END_OK` | SPK_URBAN | say |
| `D35O_U_END_BAD` | SPK_URBAN | say |
| `D35O_N_END` | SPK_NIHAT | say |
| `D35O_T_END` | SPK_TOLGA | say |

### 3.5 Metinler

```csv
UI_CH35O_TITLE,BÖLÜM {N} — EDİRNE YOLU,CHAPTER {N} — THE EDIRNE ROAD
UI_CH35O_SUB,"Mart 1453 · Trakya, taşkın bir derenin kıyısı · konvoyun önü","March 1453 · Thrace, the bank of a flooded stream · the head of the convoy"
UI_CH35O_SLOPE,"Aynı gün, ikindi · yokuş","The same day, mid-afternoon · the descent"
UI_CH35O_NIGHT,"Gece · yokuşun dibinde konak","Night · the halt at the foot of the hill"
UI_FLOW35O_TITLE,AKIŞ ŞEMASI — BÖLÜM {N}: EDİRNE YOLU,FLOWCHART — CHAPTER {N}: THE EDIRNE ROAD
SPK_DULGER,Dülgerbaşı İlyas,"İlyas, Master Carpenter"
SPK_DROVER,Arabacı Durmuş,Durmuş the Drover
SPK_KARACA,Karaca Bey,Karaja Bey
UI_OBJ35O_LASH,"Kirişte dengede kal, kalası sehpaya bağla (yeşilde E, iki kez) · %d/%d","Keep your balance on the beam, lash the plank to the trestle (E on green, twice) · %d/%d"
UI_OBJ35O_LOG,Kütük geliyor! Halkaya girince sırıkla it (E),Log coming! Push it off with the pole when it reaches the ring (E)
UI_OBJ35O_BUNDLE,Tekerin önüne çalı demeti at · %d/%d · araba batıyor,Throw a brushwood bundle in front of the wheel · %d/%d · the wagon is sinking
UI_OBJ35O_HEAVE,"Hey-yap! Çek (ibre yeşildeyken Space) · %d/%d m","Heave! Pull (Space when the needle is green) · %d/%d m"
UI_OBJ35O_BRAKE,Fren ipi: E basılı sık · bırak gevşet · ibreyi ortada tut,Brake rope: hold E to tighten · release to slacken · keep the needle centred
UI_OBJ35O_POST,İpi ikinci kazığa aktar (E) · %d sn,Move the rope to the second post (E) · %d s
UI_OBJ35O_OXEN,"Kaçan öküzü yakala ve tut: ipin ucuna E, ibreyi ortada tut · %d/%d","Catch the runaway ox and hold it: E on the rope's end, keep the needle centred · %d/%d"
UI_OBJ35O_PHOTO,Tespit et: meşaleler arasında top,Record: the gun among the torches
UI_HINT35O_LOG,KÜTÜK!,LOG!
UI_HINT35O_SNAP,HALAT! Kamçı alanından çık!,ROPE! Get out of the whip's path!
UI_PROMPT35O_LASH,E: bağla,E: lash it
UI_PROMPT35O_PUSH,E: sırıkla it,E: push it off with the pole
UI_PROMPT35O_GRAB,E: ipe tutun,E: grab the rope
UI_PROMPT35O_BUNDLE,E: demet al,E: take a bundle
UI_PROMPT35O_WHEEL,E: tekerin önüne at,E: throw it in front of the wheel
UI_PROMPT35O_POST,E: ipi kazığa sar,E: wrap the rope round the post
UI_PROMPT35O_OX,E: ipin ucunu yakala,E: grab the end of the rope
FLOW35O_BRIDGE,Taşkın derede köprü,A bridge over the flooded stream
FLOW35O_MUD,Çamurdan hey-yap,Heaving out of the mud
FLOW35O_SLOPE,Yokuşta fren ipi,The brake rope on the descent
FLOW35O_CAMP,Gece: kaçan öküzler,Night: the runaway oxen
FLOW_35O_1,Top yokuşu kaymadan indi,The gun came down the slope without slipping
FLOW_35O_2,Top bir gün geç kaldı,The gun lost a day
UI_CH35O_STATS,Gevşek kalas: %d   ·   Dereye düşüş: %d   ·   Kayma: %d   ·   Öküz: %d/%d   ·   Dosya: %d/%d sayfa,Loose planks: %d   ·   Swept away: %d   ·   Slips: %d   ·   Oxen: %d/%d   ·   File: %d/%d pages
SIEGE_DATE_35,Şubat–Mart 1453,February–March 1453
SIEGE_EV_35,"Büyük top Edirne'den İstanbul'a iki ayda taşınır: otuz araba, altmış öküz, yanında iki yüz adam; önde köprü kuran ve yol düzelten dülgerler ve işçiler.","The great gun is moved from Edirne to Istanbul in two months: thirty wagons, sixty oxen, two hundred men walking beside it; ahead of it carpenters and labourers building bridges and levelling the road."
SIEGE_NOTE_35O_1,"Bir köprü, bir çamur, bir yokuş, üç kaçak öküz. Top kaymadı. Nakliye sigortası olsa hasarsızlık indirimi alırdık. — T.","One bridge, one mud hole, one hill, three runaway oxen. The gun didn't slip. If this were cargo insurance we'd get a no-claims discount. — T."
SIEGE_NOTE_35O_2,"Bir köprü, bir çamur, bir yokuş, bir hendek. Top bir gün kaybetti, kimse bir şey kaybetmedi. Not: nakliyede en pahalı şey zamandır. — T.","One bridge, one mud hole, one hill, one ditch. The gun lost a day; nobody lost anything else. Note: in haulage the most expensive thing is time. — T."
LORE_35O_1_T,Otuz araba,Thirty wagons
LORE_35O_1,"Doukas'a göre büyük top Şubat başında Edirne'den çıktı. Birbirine bağlı otuz arabayı altmış öküz çekti; topun iki yanında dengede tutmak için iki yüz adam yürüdü. Önden giden elli dülger ve iki yüz işçi derelere ahşap köprüler kurdu, yolu düzeltti. Top iki ayda şehrin beş mil yakınına vardı.","According to Doukas the great gun left Edirne at the beginning of February. Sixty oxen drew thirty wagons lashed together; two hundred men walked on either side to keep it steady. Fifty carpenters and two hundred labourers went ahead, building wooden bridges over streams and levelling the road. In two months the gun reached a point five miles from the city."
LORE_35O_2_T,Karaca Bey'in seferi,Karaja Bey's campaign
LORE_35O_2,"Rumeli Beylerbeyi Karaca Bey önden gönderildi ve Trakya'daki Bizans kalelerini aldı: Karadeniz kıyısında Mesembria, Anchialos ve Vize kolayca düştü. Silivri (Selymbria) ve Epibatos kapılarını kapadı ve kuşatma boyunca dayandı.","Karaja Bey, governor of Rumelia, was sent ahead and took the Byzantine strongholds of Thrace: on the Black Sea coast Mesembria and Anchialos fell easily, and so did Vizye. Selymbria (Silivri) and Epibatos shut their gates and held out through the siege."
LORE_35O_3_T,Ordu yürüyor,The army marches
LORE_35O_3,"Sultan 23 Mart'ta Edirne'den çıktı. Rumeli ve Anadolu askeri, yeniçeriler, topçular ve ikmal kolları Nisan'ın ilk günlerinde surların önünde toplandı. 5 Nisan'da Sultan oradaydı; ertesi gün ordu yerine geçti.","The Sultan left Edirne on 23 March. The troops of Rumelia and Anatolia, the Janissaries, the gunners and the supply columns gathered before the walls in the first days of April. On 5 April the Sultan was there; the next day the army took up its positions."
```

Replikler:

```csv
D35O_N_01,"Tolga Bey, Mart başı 1453, Trakya. Top bir aydır yolda. Önünde elli dülger ve iki yüz işçi köprü kurup yol düzeltiyor, yanında iki yüz adam yürüyor, önünde altmış öküz.","Mr Tolga, early March 1453, Thrace. The gun has been on the road for a month. Ahead of it fifty carpenters and two hundred labourers build bridges and level the road; two hundred men walk beside it; sixty oxen pull in front."
D35O_T_01,"Bir top için beş yüz kişilik konvoy. Bizim şirket servis aracı için bu kadar uğraşmazdı.","A five-hundred-man convoy for one gun. My company wouldn't go to this much trouble for the staff minibus."
D35O_D_01,"Yol kâtibi! Dere taştı, köprü yarım. Kalasları biz iteriz; sen kirişte durup her birini iki bağla bağlarsın. Yukarıdan kütük gelirse sırıkla it. Çanlar yaklaşmadan bitmeli.","Road clerk! The stream's flooded, the bridge is half done. We push the planks out; you stand on the beam and lash each one twice. If a log comes down, push it off with the pole. It has to be done before the bells get here."
D35O_D_LASH_OK,"Sıkı. Bunun üstünden tunç geçer.","Tight. Bronze can cross that."
D35O_D_LASH_BAD,"Gevşek! Bağ kayarsa kalas döner, teker düşer. Dön, bir daha bağla.","Loose! If the lashing slips the plank turns and the wheel goes through. Go back and lash it again."
D35O_D_LOG,"Kütük geliyor! Sırık!","Log coming! The pole!"
D35O_T_LOG,"Sırıkla kütük itmek. Bunu hiçbir işe alım sınavında sormadılar.","Fending off logs with a pole. No job interview ever asked me about this."
D35O_D_HITLOG,"Sehpaya çarptı! Son bağ gevşedi, yeniden bağla!","It hit the trestle! The last lashing's loose, tie it again!"
D35O_T_SWEPT,"Dere beni aldı. İpe tutundum. Dere beni bıraktı. Sırayla.","The stream took me. I grabbed the rope. The stream let me go. In that order."
D35O_T_BRIDGE,"Altı kalas, bir dere. Hayatımın ilk köprüsü. İçimden bir ses son olmayacak diyor.","Six planks, one stream. The first bridge of my life. Something tells me it won't be the last."
D35O_DR_01,"Çekil kâtip, öküzler geliyor! Hooo, Sarıkız, yavaş! Köprü bu, ahır değil!","Out of the way, clerk, the oxen are coming! Whoa, Sarıkız, easy! It's a bridge, not a barn!"
D35O_D_CREAK,"Bir kalas gıcırdadı... Teker geçti. Bir daha geçmez ama.","One plank creaked... The wheel got over. It won't a second time, though."
D35O_D_BREAK,"Kalas döndü! Teker dereye! Herkes ipe! Kâtip, senin bağın mıydı o?","The plank turned! Wheel in the stream! Everyone on the ropes! Clerk, was that one of your lashings?"
D35O_U_01,"Öndeki araba çamura oturdu, batıyor! Kâtip, demetleri tekerin önüne! Sonra hep birlikte: hey-yap!","The lead wagon's stuck in the mud, and it's sinking! Clerk, bundles in front of the wheel! Then all together: heave!"
D35O_T_MUD,"Mart, Trakya, çamur. Hiçbir belgesel bu kısmı çekmiyor.","March, Thrace, mud. No documentary ever films this part."
D35O_U_HEAVE,"Hey-yap! Bir daha! Bu tunç sizi bekler, siz onu bekletmeyin!","Heave! Again! This bronze waits for you; don't you keep it waiting!"
D35O_U_SLIP,"Geri kaydı! Demetsiz çekilmez!","It slid back! Don't pull without the bundles!"
D35O_U_ROPE,"Halat gerildi! Bir daha zamansız çekerseniz kopar!","The rope's at its limit! Pull out of time once more and it snaps!"
D35O_U_SNAP,"HALAT! Yana!","ROPE! Aside!"
D35O_T_SNAP,"Halat başımın üstünden geçti. Saçımın bir kısmını da götürdü galiba.","The rope went right over my head. I think it took some of my hair with it."
D35O_U_FREE,"Çıktı! Yürüyor! Altmış öküz, iki yüz adam ve bir kâtip!","It's out! It's moving! Sixty oxen, two hundred men and one clerk!"
D35O_U_SLOPE,"Yokuş! Kâtip, fren ipi sende, kazığa sarılı. Çok gevşetirsen araba öküzleri ezer, çok sıkarsan ip kopar.","The descent! Clerk, the brake rope is yours, it's wrapped round the post. Slacken too much and the wagon runs over the oxen; pull too hard and the rope snaps."
D35O_T_SLOPE,"Yani tam ortası. Hayatım boyunca benden hep tam ortasını istediler.","So, right in the middle. All my life people have asked me for right in the middle."
D35O_K_01,"Usta Urban! Silivri kapılarını kapadı, Epibatos da. Biz yolu açık tutuyoruz, sen topu yürüt.","Master Urban! Selymbria has shut its gates, and Epibatos too. We keep the road open; you keep the gun moving."
D35O_U_K1,"Yol açık olsun, Karaca Bey, ben yürütürüm. Şu yokuşu da siz düzeltseydiniz keşke.","Keep the road open, Karaja Bey, and I'll keep it moving. I only wish you'd levelled that hill as well."
D35O_K_02,"Yokuş Allah'ın, düz yol bizim. Yokuşu sen halledeceksin.","The hill is God's, the flat road is ours. The hill is your problem."
D35O_U_POST,"İkinci kazık! İpi aktar, çabuk!","The second post! Move the rope, quick!"
D35O_U_RUN,"Kaçıyor! Sık! Sık!","She's running! Tighten! Tighten!"
D35O_U_TIGHT,"Fazla sıktın! Öküzler böğürüyor! Biraz sal!","Too tight! The oxen are bellowing! Let it out a little!"
D35O_U_SLIDE,"Kaydı... yan hendeğe. Sabaha kadar çıkarırız. Bir gün kaybettik.","She slid... into the side ditch. We'll have her out by morning. We've lost a day."
D35O_U_SLOPE_OK,"Aşağıda! Tek kayma yok. Kâtip, bunu Sultan'a ben anlatacağım, sen yazacaksın.","At the bottom! Not a single slip. Clerk, I'll tell the Sultan, you'll write it down."
D35O_DR_SPOOK,"Kurt! Sarıkız ipi kopardı, Karabaş da, Benekli de! Kâtip, ipin ucunu yakala; çekme, tut!","Wolves! Sarıkız has broken her rope, and Karabaş, and Benekli! Clerk, grab the end of the rope; don't pull, hold!"
D35O_T_CALM,"Sarıkız. Sarıkız, dur. Bak, ben de korkuyorum.","Sarıkız. Sarıkız, stop. Look, I'm scared too."
D35O_DR_GOT,"Tuttun! Adını söyle, adını! Adını duyunca durur.","You've got her! Say her name, her name! She stops when she hears it."
D35O_T_MUDFALL,"Yüzüstü çamurdayım. Öküz ayakta. Durum tespiti: öküz kazandı.","I'm face down in the mud. The ox is standing. Assessment: the ox won."
D35O_DR_03,"Adını bilmediğin hayvan senin için durmaz, kâtip. Altmışının da adını bilirim.","An animal won't stop for you if you don't know its name, clerk. I know all sixty."
D35O_T_PHOTO,"Meşale ışığında top. Kızağın üstünde, öküzlerin arasında. Bu kare sigortaya gitmez, müzeye gider.","The gun by torchlight. On its sled among the oxen. This shot doesn't go to an insurer; it goes to a museum."
D35O_U_DAY,"Kâtip, defterine yaz: yolda kırk birinci gün. Köprü sayısı belli değil, çamur sonsuz.","Clerk, put it in your ledger: day forty-one on the road. Number of bridges unknown, mud infinite."
D35O_T_DAY,"Yazdım. Altına bir not ekledim: usta yorgun, top değil.","Written. I added a note underneath: master tired, gun not."
D35O_U_END_OK,"Nisan başında surların önündeyiz. Sultan gelmeden topun yatağı hazır olacak.","By early April we're before the walls. The gun's bed will be ready before the Sultan arrives."
D35O_U_END_BAD,"Bir gün kaybettik ama topu kaybetmedik. Nisan başında yine surların önündeyiz.","We lost a day but we didn't lose the gun. We'll still be before the walls in early April."
D35O_N_END,"Kaydedildi. Kaynaklara göre top iki ayda surların beş mil yakınına vardı. Sultan 23 Mart'ta Edirne'den çıkacak, 5 Nisan'da ordu surların önünde olacak. Sıradaki kayıt: siper ve kazık.","Recorded. According to the sources the gun reached five miles from the walls in two months. The Sultan leaves Edirne on 23 March, and on 5 April the army will be before the walls. Next entry: rampart and stakes."
D35O_T_END,"Bu kadar emek bir duvarı yıkmak için. Bizim şirkette buna yatırım derdik.","All this effort to knock down one wall. At my company we'd call this an investment."
```

```csv
UI_RECAP_35O_PREV,"Edirne'de topu çukurdan kaldırdın, gülleleri ölçtün, ateş almayan topu yeniden doldurdun; top Sultan'ın önünde konuştu.","At Edirne you lifted the gun from its pit, gauged the balls and re-primed a misfire; the gun spoke before the Sultan."
UI_RECAP_35O_NEXT,"Top surların önünde. 6 Nisan: ordu toprağa giriyor; 11 Nisan'da topu bataryasına çekeceğiz.","The gun is before the walls. 6 April: the army digs in; on 11 April we haul the gun into its battery."
```

---

## 4. Bölüm 36o — "İlk Hücum" (18 Nisan 1453 gecesi)

### 4.1 Tarihî dayanak

- **Gedik ve barikat.** Bombardımanın ilk haftasında Lykos vadisinde (Mesoteichion) dış sur yer yer çöktü.
  Giustiniani'nin adamları yıkılan yerlere barikat (stockade) ördü: kazıklar, kalaslar, çalı, toprak dolu fıçılar,
  üstünde ıslak deriler (**R**, **B**). Oyunda bu barikat `LandWalls` gedik molozunun üstündeki mevcut barikattır
  (`set_repair`).
- **18 Nisan.** Güneş battıktan yaklaşık iki saat sonra Sultan Mesoteichion'daki barikata ilk büyük hücumu emretti
  (**B**, **R**).
  - Okçular, ağır piyade ve yeniçeriler davul ve borularla geldi. Meşalelerle barikatı yakmaya, kancalarla fıçıları
    indirmeye, merdivenlerle tırmanmaya çalıştılar.
  - Yer dar olduğu için sayılarının faydası olmadı. Dört saat sonra çekildiler.
  - Barbaro saldıranlardan yaklaşık 200 kişinin öldüğünü, savunanlardan hiç kimsenin ölmediğini yazar. Rakam abartılı
    olabilir (**R** de çekinceyle aktarır). Nihat "Barbaro yazar" diyerek söyler.
- **Bağlam:** Aynı günlerde Sultan surların dışında kalan küçük Bizans kalelerini (Therapia, Studios) aldırdı,
  Baltaoğlu Prens Adaları'nı (Prinkipo) aldı (**K**, **R**). Oyun bunları göstermez, Nihat tek cümleyle anar
  (`D36O_N_01`). 20 Nisan'da deniz savaşı gelir (29o).
- **Kerkoporta yok.** Ölüm gösterilmez. Düşen saldıranlar `StoryDuel.make` kuralıyla teslim olur ya da geri çekilir.

### 4.2 Yer ve sistemler

**Yeni seviye yok.**
- **Harita:** `LandWalls` (gedik + barikat, varsayılan; `intact = false`) + `SiegeField` (`near_works`, gece). 20o ve
  32o ile aynı Lykos kesiti. `Night.environment`, ay yok; meşale ve ateş ışığı.
- **Assault:** `Assault.build()` ordu bloklarıyla. Merdiven ve dalga kalabalığı **seyrek** (ilk hücum: dalga
  yoğunluğu 0,4; yeni parametre ya da `build_calm()` + tek koşan dalga).
- **WallFight:** Barikatın arkasında kova taşıyan ve su döken savunucular. Kazanlar (yağ değil **su**: `pour` su
  rengiyle). Taşıyıcılar `add_carriers` ile.

**Kullanılan sistemler:**
- 32o'nun mantolu ok yaylımı (`Assault.volley`, siperde değilsen −30 can).
- 29o'nun kanca atışı (`_throw`, hedef işareti küpeşte yerine fıçı çemberi).
- `RowMeter` "çek" ritmi.
- Meşale atışı: kanca atışının aynısı (yay, `Vfx.fire`). `SiegeTower.burn`'deki alev büyütme mantığı barikatın üç
  kesitine uyarlanır.
- `Gunner` (barikatın tepesinde), `WaveRunner` (moloz tepesinde), `StoryDuel`, `TespitCam`, `Grade.finish("36o")`,
  `Lore.scatter(self, "36o")`.
- `Audio.intensity` 1 → 3 → 0, `Fx.slowmo` (fıçı yuvarlanırken), `Audio.stinger("warn")`.

**Barikat düzeni (yeni, bölüm içinde):**
- Barikatın üstünde **5 fıçı**: `LandWalls` barikat aşamasının en üst sırası, her fıçı ayrı düğüm.
- Barikatın ova yüzünde **3 kalas kesiti** (sol, orta, sağ). Her kesitin üstü ıslak deriyle kaplı.
- Fıçı indirilince arkasındaki kesitin derisi sıyrılır, kalas **açığa çıkar** (meşale tutar). Açık kesitin söndürme
  süresi 8 sn'den 12 sn'ye çıkar.

**Süre hedefi:** 10–12 dk. Durarak konuşma ≤ 1,5 dk.

### 4.3 Fazlar

#### Faz 0: Batarya (akşam)

- **Oynanış:** Urban'ın bataryasında kısa açılış, yürürken. Yeniçeri çavuşu Tolga'ya **kancalı sırık** ve sırtına
  bağlı **meşale demeti** verir (E). Davullar başlar.

**Animasyon ve görsel geri bildirim:**
- **Çavuş:** sırığı iki elle uzatır, Tolga alır. Sırık elde, meşale demeti sırtta görünür.
- **Bölük:** sıraya girer (yürüyerek gelir, belirmez).
- **Davul:** davulcu tokmak döngüsünde.

#### Faz 1: Ölü bölge (güneş batışı + 2 saat)

- **Hedefler:** `UI_OBJ36O_CROSS`, `UI_OBJ36O_COVER`
- **Oynanış:**
  - Siperden hendek kıyısına **90 m**, bölükle birlikte.
  - Surdan **ok yaylımı** 10–14 sn'de bir (32o kuralı): "Ok!" uyarısından 2 sn içinde **mantonun** arkasında değilsen
    −30 can. Ölü bölgede dört manto var.
  - Savunucuların fırlattığı **ateş çömlekleri** yerde yanar: alan aydınlanır ve 6 sn yürünmez (içinde −10 can/sn).
  - Hendek henüz dolu değil. Kıyıdaki **köprü merdivenini** geç: yatay `Ladder`, 8 m, dar. Ortasında bir yaylım gelir;
    merdivende siper yok, hızlı geç.
- **Başarısızlık:** Can biterse yere düşersin. Çavuş kaldırır (`D36O_J_DOWN`), mantonun arkasında 40 canla
  kalkarsın. Sayaç: yenen ok.

**Animasyon ve görsel geri bildirim:**
- **Oklar:** havada görünen yay ve gölge, yere ve mantoya saplanır, titrer. Mantonun arkasında durana oklar perdeye
  saplanır (görünür birikim).
- **Ateş çömleği:** dönerek uçar, kırılır (çömlek parçaları), alev halkası ve duman.
- **Bölük:** koşarken kalkanlarını başlarına kaldırır. İsabet alan geri çekilip oturur (ölüm yok).
- **Köprü merdiveni:** hendeğin iki kıyısına dayalı, basamaklar üstte. Basınca hafifçe esner.
- **Zemin:** Ölü bölgedeki gülle çukurlarına inen askerler çukur dibinde yürür (`SiegeField` zemini). Mantoların
  tekerlekleri yerdedir.

#### Faz 2: Kanca (gece)

- **Hedefler:** `UI_OBJ36O_HOOK`, `UI_OBJ36O_PULL`
- **Oynanış:**
  - Moloz yamacının dibinde. Barikatın tepesindeki fıçılardan birinin **çemberine nişan al ve kancayı at** (E).
    Menzil 4–9 m.
  - Takılırsa **çek**: `RowMeter`, iki yoldaşla. **4 iyi çekiş** fıçıyı devirir.
  - Fıçı molozdan **yuvarlanır**: 1,5 sn ağır çekim, yolu yerde çizgiyle gösterilir. **Kaç!**
  - Savunucular ipi içeri çeker: **iki kötü çekiş** (kırmızı) sırığı kaybettirir. Yeni sırık 6 m gerideki yığından
    alınır.
  - Barikatın tepesinde bir **tüfekçi** (`Gunner`) nişan alır: yana kay ya da mantoya geç.
  - **Hedef: 3 fıçı, 2 dk 30 sn.**
- **Başarısızlık:**
  - Yuvarlanan fıçının 2 m içinde kalırsan −25 can ve yere düşersin.
  - Sırık kaybı zaman kaybettirir.
  - Sayaç: indirilen fıçı (0–5).

**Animasyon ve görsel geri bildirim:**
- **Kanca:** havada dönerek uçar, arkasından ip açılır (ip sarmalı Tolga'nın elinden çözülür). Çembere takılınca
  "tık" ve ip gerilir. Iskada kanca barikata çarpar, molozdan kayıp düşer.
- **Çekiş:** üç adam aynı anda geriye yaslanır, ayakları molozda kayar. Fıçı her iyi çekişte 10 cm öne kayar,
  yerinden oynar.
- **Savunucunun çekişi:** barikatın üstünde bir savunucu ipi tutar, öbürü baltayla vurur. Kesilen ip iki parça
  olup düşer.
- **Devrilme:** fıçı barikattan devrilir, yamaçta yuvarlanırken toprak saçar. Molozun dibinde tahtaları kırılır:
  çemberler yuvarlanır, toprak yığılır. Arkasındaki deri kesiti yırtılır, kalas görünür.
- **Tüfekçi:** fitil parlar, duman ve patlama (mevcut `Gunner`).
- **Zemin:** Fıçının yolu molozun katı katmanlarını izler, havada uçmaz. Oyuncu ve yoldaşlar moloz katmanlarında durur
  (20o'daki katı moloz dili).

#### Faz 3: Meşale (hemen ardından)

- **Hedefler:** `UI_OBJ36O_TORCH`, `UI_OBJ36O_PHOTO`
- **Oynanış:**
  - Çavuş meşaleleri tutuşturur. Tolga **4 meşale** atar (E; yay, 6–12 m).
  - Açık kalas kesitine düşen meşale kesiti tutuşturur. Savunucular kovayla 8 sn'de (açık kesitte 12 sn'de) söndürür.
  - **İki kesit aynı anda yanarsa** "yanıyor" eşiği aşılır: alevler büyür, savunucular deri ve toprakla gelir.
    Sonunda söndürürler (tarih), ama sayaç yazılır.
  - Bu sırada savunucular **taş** atar: 26o'nun "YUKARIDAN TAŞ!" kuralı, molozun dibinde. İndiği halkadan çık.
  - Fazın ortasında Giustiniani barikatın tepesine çıkar ve bağırır. **Tespit karesi:** meşale ışığında miğferi.
    Hedef baş, pencere 15 sn.
- **Başarısızlık:**
  - Taş isabet ederse −20 can.
  - Meşaleler bitince faz biter. Sayaç: aynı anda yanan en çok kesit (0–3).

**Animasyon ve görsel geri bildirim:**
- **Meşale:** dönerek uçar, alev izi bırakır. Deride söner (buhar ve cızırtı), açık kalasa saplanırsa önce küçük
  alev, sonra 2 sn'de kesit boyu ateş.
- **Söndürme:** savunucular kovayla gelir, suyu atar (su yayı). Alevler küçülür, buhar çıkar. Deri taşıyanlar deriyi
  ateşin üstüne örter.
- **İki kesit yanınca:** ışık turuncuya döner, gölgeler uzar, barikatın üstündekiler geri çekilir.
- **Giustiniani:** miğferli, zırhlı (`Person`). Barikatın tepesine çıkar, kolunu kaldırıp bağırır, 4 sn durur.
- **Taşlar:** düşerken döner, yerde seker ve toz kaldırır.

#### Faz 4: Moloz (gece yarısına doğru)

- **Hedef:** `UI_OBJ36O_FIGHT`
- **Oynanış:**
  - Bölük moloz yamacına çıkar. **`WaveRunner`**: 1. dalga 2 Cenevizli, 2. dalga 2 savunucu (aynı anda en çok 2).
    Yanında 1 yeniçeri. Barikatın tepesinde `Gunner`.
  - Fıçı indirilen kesitlerin önü daha alçaktır, dövüş orada geçer.
  - **90 sn.**
- **Sonuç:** Kaybedilirse Tolga molozdan yuvarlanır (`D36O_T_LOST`). Kazanılırsa da tarih aynıdır: boru çalar.

**Animasyon ve görsel geri bildirim:**
- **Düello:** mevcut sistem (parry altın kenar, tekme, bitirici).
- **Teslim olanlar:** geri sürünüp barikatın ardına çekilir, yok olmaz.
- **Arka plan:** barikatın arkasında onarım ekibi çalışmayı sürdürür (`WallFight.add_builders`): kazık çakar, toprak
  taşır.

#### Faz 5: Geri çekilme (gece yarısından sonra)

- **Hedef:** `UI_OBJ36O_BACK`
- **Oynanış:**
  - "Geri!" borusu. Ölü bölgeyi geri geç: 60 m, **iki yaylım**, mantolar.
  - Siperde ulak Tolga'yı bulur (29o'ya bağ). Nihat'ın kaydı.

**Animasyon ve görsel geri bildirim:**
- **Borazan:** borazancı boruyu kaldırır.
- **Bölük:** geri koşar, iki asker bir yaralıyı kollarından tutup taşır.
- **Ulak:** atla gelir, atın ayakları zeminde, durunca toz kalkar.

#### Sonuçlar

| Kod | Koşul | Şema |
|---|---|---|
| **36O.1** Barikat tutuştu, fıçılar indi | indirilen fıçı ≥ 2 **ve** aynı anda yanan kesit ≥ 2 | `FLOW_36O_1` |
| **36O.2** Barikat bütün kaldı | aksi hâlde | `FLOW_36O_2` |

Tarih ikisinde de aynıdır: hücum püskürtülür. Fark Urban'ın son repliğinde (`D36O_U_END_OK` / `_BAD`) ve dosya
notundadır. Dövüş sonucu bölümün sonucunu bozmaz; savaş karnesine gider.

**Otomatik test:** `--chapter=36 --autotest[=weak|lose]`
- **Varsayılan (36O.1):** Bot yaylımda mantoya geçer, ateş çömleği alanından kaçar. 3 fıçı indirir, yuvarlanan
  fıçıdan kaçar. İki kesiti birlikte tutuşturur, taştan kaçar. Dövüşü kazanır (`duel.god`), kareyi çeker.
- **`=weak` (36O.2):** Bot 1 fıçıda durur, meşaleleri deriye atar. Denetim: `BARRELS 1`, `BURN 1`.
- **`=lose`:** Bot düelloda savunmasız durur, tüfekçiden ve fıçıdan kaçmaz. Denetimler: `player.downs >= 1`,
  kaybedilmiş düello, `BARREL_HIT >= 1`. Sonuç yine 36O.1/2 kuralına göre.
- **`VISAUDIT`:** Fıçı yuvarlanma yolu, kalabalığın ve düellocuların moloz yüzeyine oturması. 20o'daki "moloz dili
  görüntüden ibaret" hatası tekrarlanmasın: dövüş alanı `LandWalls`'ın katı katmanlarıdır. Her kanca ipinin iki ucu
  görünür olmalı (`ROPECHECK`).

**Akış şeması** (`UI_FLOW36O_TITLE`):
`FLOW36O_CROSS` → `FLOW36O_HOOKS` → `FLOW36O_TORCH` → `FLOW36O_FIGHT` → `FLOW36O_HORN` → {`36O.1`, `36O.2`}.
Altında `Grade.finish("36o")` ve `UI_CH36O_STATS`.

**Başarım önerisi:** `ACH_OSM_HOOK` "Fıçı Avcısı": beş fıçının beşini indir.

### 4.4 Konuşanlar

**Yeni anahtar yok.** Kullanılanlar: `SPK_NIHAT`, `SPK_TOLGA`, `SPK_URBAN`, `SPK_JANISSARY` (bölüğün çavuşu; 32o'daki
"Sükût!" diyen yeniçeri değil, aynı genel anahtar), `SPK_DEFENDER`, `SPK_GIUST`, `SPK_RIDER`.

Giustiniani'nin repliği Osmanlı tarafından duyulan bir bağırıştır. Altyazı Türkçe çevirisidir; isteğe bağlı olarak
seslendirmede İtalyanca okunabilir.

**Koşullu replikler:**
- `D36O_T_WON` / `D36O_T_LOST` dövüşe göre seçilir.
- `D36O_U_END_OK` / `_BAD` sonuca göre seçilir.
- Diğerleri olay bark'larıdır.

**Durarak söylenenler (say):** `N_01`, `U_01`, `T_01` (açılış, ~35 sn); `U_END_*`, `RD_01`, `T_RIDER`, `N_END`
(kapanış, ~40 sn). Toplam ≈ 1 dk 15 sn.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D36O_N_01` | SPK_NIHAT | say |
| `D36O_U_01` | SPK_URBAN | say |
| `D36O_T_01` | SPK_TOLGA | say |
| `D36O_J_01` | SPK_JANISSARY | bark |
| `D36O_T_02` | SPK_TOLGA | bark |
| `D36O_J_VOLLEY` | SPK_JANISSARY | bark |
| `D36O_J_SAFE` | SPK_JANISSARY | bark |
| `D36O_T_HIT` | SPK_TOLGA | bark |
| `D36O_J_DOWN` | SPK_JANISSARY | bark |
| `D36O_T_DITCH` | SPK_TOLGA | bark |
| `D36O_J_HOOK` | SPK_JANISSARY | bark |
| `D36O_J_PULL` | SPK_JANISSARY | bark |
| `D36O_J_BARREL` | SPK_JANISSARY | bark |
| `D36O_T_DODGE` | SPK_TOLGA | bark |
| `D36O_J_CUT` | SPK_JANISSARY | bark |
| `D36O_D_01` | SPK_DEFENDER | bark |
| `D36O_J_TORCH` | SPK_JANISSARY | bark |
| `D36O_T_TORCH` | SPK_TOLGA | bark |
| `D36O_D_WATER` | SPK_DEFENDER | bark |
| `D36O_D_STONE` | SPK_DEFENDER | bark |
| `D36O_J_BURN` | SPK_JANISSARY | bark |
| `D36O_J_OUT` | SPK_JANISSARY | bark |
| `D36O_GU_01` | SPK_GIUST | bark |
| `D36O_T_GIUST` | SPK_TOLGA | bark |
| `D36O_N_PHOTO` | SPK_NIHAT | bark |
| `D36O_J_FIGHT` | SPK_JANISSARY | bark |
| `D36O_T_FIGHT` | SPK_TOLGA | bark |
| `D36O_T_WON` | SPK_TOLGA | bark |
| `D36O_T_LOST` | SPK_TOLGA | bark |
| `D36O_J_HORN` | SPK_JANISSARY | bark |
| `D36O_T_RETREAT` | SPK_TOLGA | bark |
| `D36O_U_END_OK` | SPK_URBAN | say |
| `D36O_U_END_BAD` | SPK_URBAN | say |
| `D36O_RD_01` | SPK_RIDER | say |
| `D36O_T_RIDER` | SPK_TOLGA | say |
| `D36O_N_END` | SPK_NIHAT | say |

### 4.5 Metinler

```csv
UI_CH36O_TITLE,BÖLÜM {N} — İLK HÜCUM,CHAPTER {N} — THE FIRST ASSAULT
UI_CH36O_SUB,"18 Nisan 1453 · Mesoteichion, gedikteki barikat · gece","18 April 1453 · The Mesoteichion, the stockade in the breach · night"
UI_FLOW36O_TITLE,AKIŞ ŞEMASI — BÖLÜM {N}: İLK HÜCUM,FLOWCHART — CHAPTER {N}: THE FIRST ASSAULT
UI_OBJ36O_CROSS,Bölükle ölü bölgeyi geç: hendeğin kıyısına,Cross the dead ground with your company: to the edge of the moat
UI_OBJ36O_COVER,Ok! Mantonun arkasına geç,Arrows! Get behind a mantlet
UI_OBJ36O_HOOK,Barikatın fıçısına kanca at (E) · indirilen %d/%d · %d sn,Throw the hook at a barrel on the stockade (E) · pulled down %d/%d · %d s
UI_OBJ36O_PULL,"Çek! (ibre yeşildeyken Space) · %d/4","Pull! (Space when the needle is green) · %d/4"
UI_OBJ36O_TORCH,Meşaleyi açık kalasa at (E) · meşale %d/%d,Throw the torch at the bare timber (E) · torch %d/%d
UI_OBJ36O_PHOTO,Tespit et: barikatın tepesinde Giustiniani,Record: Giustiniani on top of the stockade
UI_OBJ36O_FIGHT,Moloz yamacında tutun,Hold on the slope of rubble
UI_OBJ36O_BACK,Geri çekil: siperin arkasına,Fall back: behind the rampart
UI_HINT36O_ROLL,FIÇI GELİYOR! Yoldan çekil!,BARREL COMING! Get out of the way!
UI_HINT36O_FIREPOT,ATEŞ ÇÖMLEĞİ!,FIREPOT!
UI_PROMPT36O_POLE,E: kancalı sırığı al,E: take a hook pole
UI_PROMPT36O_THROW,E: kancayı at (fıçının çemberine),E: throw the hook (at the barrel's hoop)
UI_PROMPT36O_TORCH,E: meşaleyi at,E: throw the torch
FLOW36O_CROSS,Ölü bölge ve mantolar,The dead ground and the mantlets
FLOW36O_HOOKS,Kancayla fıçılar,Barrels on the hook
FLOW36O_TORCH,Meşaleler ve ıslak deri,Torches and wet hides
FLOW36O_FIGHT,Moloz yamacında dövüş,The fight on the rubble
FLOW36O_HORN,Dört saat sonra boru,The horn after four hours
FLOW_36O_1,"Barikat tutuştu, fıçılar indi","The stockade caught fire, the barrels came down"
FLOW_36O_2,Barikat bütün kaldı,The stockade stayed whole
UI_CH36O_STATS,Fıçı: %d/%d   ·   Aynı anda yanan: %d/3   ·   Ok: %d   ·   Dosya: %d/%d sayfa,Barrels: %d/%d   ·   Burning at once: %d/3   ·   Arrows: %d   ·   File: %d/%d pages
SIEGE_DATE_36,"18 Nisan 1453, gece","18 April 1453, night"
SIEGE_EV_36,"Mesoteichion'daki gediğe örülen barikata ilk büyük gece hücumu: meşaleler, kancalar, merdivenler. Dört saat sonra saldıranlar çekilir; barikat ayakta kalır.","The first great night assault on the stockade built across the breach in the Mesoteichion: torches, hooks, ladders. After four hours the attackers withdraw; the stockade stands."
SIEGE_NOTE_36O_1,"Kancayla fıçı indirdim, meşale attım, iki yer birden yandı. Islak deri hepsini söndürdü. Barikat ayakta. Not: karşı taraf da işini biliyor. — T.","I pulled barrels down with a hook and threw torches; two places burned at once. Wet hides put it all out. The stockade stands. Note: the other side knows its job too. — T."
SIEGE_NOTE_36O_2,"Kanca tutmadı, meşale tutuşturmadı. Dört saat sonra herkes başladığı yere döndü. Barikat bir şey olmamış gibi duruyor. — T.","The hook wouldn't hold, the torch wouldn't catch. After four hours everyone went back where they started. The stockade stands as if nothing happened. — T."
LORE_36O_1_T,Barikat,The stockade
LORE_36O_1,"Toplar dış surda gedik açtıkça Giustiniani'nin adamları geceleri yıkılan yeri kapattı: kazıklar, kalaslar, çalı, toprak dolu fıçılar, üstünde ıslak deriler. Taş gülle toprağa gömüldü, ahşap esnedi; barikat taş surdan daha zor yıkılıyordu.","As the guns opened breaches in the outer wall, Giustiniani's men closed them at night: stakes, planks, brushwood, barrels filled with earth, wet hides on top. Stone balls buried themselves in the earth and the timber gave; the stockade was harder to bring down than stone."
LORE_36O_2_T,18 Nisan gecesi,The night of 18 April
LORE_36O_2,"Güneş battıktan iki saat sonra Sultan Lykos vadisindeki barikata ilk büyük hücumu emretti. Saldıranlar meşalelerle barikatı yakmaya, kancalarla fıçıları indirmeye, merdivenlerle tırmanmaya çalıştı; yer dardı. Dört saat sonra çekildiler. Barbaro saldıranlardan iki yüz kişinin öldüğünü, savunanlardan kimsenin ölmediğini yazar; rakam abartılı olabilir.","Two hours after sunset the Sultan ordered the first great assault on the stockade in the Lycus valley. The attackers tried to burn it with torches, pull its barrels down with hooks and climb it with ladders; the space was narrow. After four hours they withdrew. Barbaro writes that two hundred attackers died and not one defender; the figure may be exaggerated."
LORE_36O_3_T,Mesoteichion,The Mesoteichion
LORE_36O_3,"Kara surlarının ortası, Lykos deresinin vadiye girdiği yer. Surlar burada alçakta kalıyordu ve ordunun en güçlü topları, Urban'ınki dahil, bu kesime çevrildi. Kuşatmanın en ağır çarpışmaları burada geçti.","The middle of the land walls, where the Lycus stream enters the valley. Here the walls stood low, and the army's strongest guns, Urban's among them, were turned on this stretch. The heaviest fighting of the siege took place here."
```

Replikler:

```csv
D36O_N_01,"Tolga Bey, 18 Nisan, akşam. Surlar bir haftadır dövülüyor; Mesoteichion'da dış sur yer yer çöktü, gediğe barikat örüldü. Bu hafta dışarıdaki küçük kaleler de alındı; onların kaydı ayrı ve kısa. Bu gece ilk büyük hücum.","Mr Tolga, 18 April, evening. The walls have been pounded for a week; in the Mesoteichion the outer wall has collapsed in places and a stockade has been built across the breach. The small castles outside were taken this week too; their entry is separate, and short. Tonight, the first great assault."
D36O_U_01,"Kâtip! Bir hafta dövdük, gedik açıldı, onlar da fıçıyla toprakla kapadı. Bu gece yeniçeriler gidiyor. Sen kancayı taşırsın, ben buradan bakarım.","Clerk! A week of pounding, the breach is open, and they've plugged it with barrels and earth. Tonight the Janissaries go in. You carry a hook; I watch from here."
D36O_T_01,"Usta, kanca taşımak sözleşmede... Sözleşmede pek bir şey yok zaten.","Master, carrying hooks isn't in my contract... Not much is in my contract, to be fair."
D36O_J_01,"Kâtip! Sırık sende, meşale sırtında. Ölü bölgeyi geç; ok gelirse mantoya. Fıçıları kancayla indireceğiz, kalaslarını yakacağız.","Clerk! The pole's yours, the torches on your back. Cross the dead ground; if arrows come, get behind a mantlet. We pull the barrels down with hooks and burn the timber."
D36O_T_02,"Kanca, meşale, gece. Sigortada buna kasıt unsuru denir.","Hooks, torches, darkness. In insurance we call this intent."
D36O_J_VOLLEY,"Ok! Mantoya!","Arrows! Behind the mantlet!"
D36O_J_SAFE,"Geçti! İleri!","It's passed! Forward!"
D36O_T_HIT,"Omzum! Gece de nişan alıyorlar. Fazla mesai.","My shoulder! They aim in the dark too. Overtime."
D36O_J_DOWN,"Kâtip! Kalk! Mantonun arkasına çekin onu!","Clerk! Up! Drag him behind the mantlet!"
D36O_T_DITCH,"Hendek dolu değil. Merdiveni köprü yaptılar. Merdiven yatay durunca da korkutucuymuş.","The moat isn't filled. They've laid a ladder across as a bridge. Turns out a ladder is frightening lying down too."
D36O_J_HOOK,"Fıçılar tepede. Kancayı çembere at, takılınca hep birlikte çek!","The barrels are on top. Throw the hook at a hoop; when it catches, pull together!"
D36O_J_PULL,"Çek! Çek! Hey!","Pull! Pull! Heave!"
D36O_J_BARREL,"Devrildi! Çekil, yuvarlanıyor!","Over it goes! Get clear, it's rolling!"
D36O_T_DODGE,"Toprak dolu bir fıçı yanımdan geçti. Hayatımın en ağır hasar dosyası olabilirdi.","A barrel full of earth just rolled past me. That could have been the heaviest claim of my life."
D36O_J_CUT,"Sırığı içeri çektiler! Yığından yenisini al!","They've pulled the pole in! Get another from the pile!"
D36O_D_01,"Kancalar! İpleri kesin! Toprak dökün!","Hooks! Cut the ropes! Throw earth down!"
D36O_J_TORCH,"Kalaslar açıkta! Meşaleleri at! İki yer birden yanarsa söndüremezler!","The timber is bare! Throw the torches! If two places burn at once they can't put it out!"
D36O_T_TORCH,"Meşale atıyorum. Kasko poliçesinin hiçbir maddesinde kendimi bu kadar suçlu hissetmemiştim.","I'm throwing torches. No clause in any car policy has ever made me feel this guilty."
D36O_D_WATER,"Su! Derileri ıslatın! Ateşe su!","Water! Wet the hides! Water on the fire!"
D36O_D_STONE,"Taş! Aşağıdakilere taş!","Stones! Stones on the men below!"
D36O_J_BURN,"Yanıyor! İki yerden birden yanıyor!","It's burning! Burning in two places at once!"
D36O_J_OUT,"Söndürdüler. Islak deri, toprak, kova... Bunlar her şeyi düşünmüş.","They've put it out. Wet hides, earth, buckets... They've thought of everything."
D36O_GU_01,"Fıçılar yerinde kalsın! Ateşe su! Kimse barikattan inmesin!","Keep the barrels in place! Water on the fire! No one leaves the stockade!"
D36O_T_GIUST,"Barikatın tepesinde miğferli biri. Herkes ona bakıyor, o da hepimize. Giustiniani bu olmalı.","A man in a helmet on top of the stockade. Everyone's looking at him, and he's looking at all of us. That must be Giustiniani."
D36O_N_PHOTO,"Kaydedildi. Kaynaklara göre o gece barikatı Giustiniani'nin adamları tuttu.","Recorded. According to the sources, Giustiniani's men held the stockade that night."
D36O_J_FIGHT,"Moloza çıkıyoruz! Kâtip, arkamda kal; kalkanlıya tekme, kılıcı sonra!","Up onto the rubble! Clerk, stay behind me; kick the shield first, sword after!"
D36O_T_FIGHT,"Molozun tepesi dar. Herkes de oraya çıkmak istiyor.","The top of the rubble is narrow. And everyone wants to be up there."
D36O_T_WON,"Tuttuk. Bir süre. Bir süre tutmak da tutmaktır, değil mi?","We held. For a while. Holding for a while still counts, doesn't it?"
D36O_T_LOST,"Molozdan aşağı yuvarlandım. Barikat bende değil, ben barikatın dibindeyim.","I rolled down the rubble. I didn't get the stockade; I got the bottom of it."
D36O_J_HORN,"Boru! Geri! Yaralıları alın, sırıkları bırakın!","The horn! Fall back! Take the wounded, leave the poles!"
D36O_T_RETREAT,"Dört saat. Dört saat sonra herkes başladığı yere döndü. Barikat yine orada.","Four hours. After four hours everyone is back where they started. The stockade is still there."
D36O_U_END_OK,"Fıçıları indirmişsin, kalasları tutuşturmuşsun. Onlar söndürdü, sabaha yine örerler. Ben de sabah yine konuşurum.","You pulled barrels down and set the timber alight. They put it out, and by morning they'll build it again. And in the morning I'll talk again."
D36O_U_END_BAD,"Barikat toprak. Toprağa gülle gömülür, meşale söner. Olsun. Toprağın da bir sabrı var, benim de.","The stockade is earth. Balls bury themselves in earth and torches go out. Never mind. Earth has its patience, and so do I."
D36O_RD_01,"Topçu kâtibi sen misin? Baltaoğlu Bey'in kadırgalarına kürekçi lazım. Çifte Sütunlar'a, şimdi!","Are you the gunners' clerk? Baltaoğlu Bey's galleys need oarsmen. To the Double Columns, now!"
D36O_T_RIDER,"İlk hücumdan çıktım, şimdi denize mi? ...Yüzme biliyorum. Biliyorum, değil mi?","I've just come out of the first assault, and now it's the sea? ...I can swim. I can, can't I?"
D36O_N_END,"Kaydedildi. 18 Nisan gecesi: dört saat, barikat tuttu. Barbaro saldıranlardan iki yüz kişinin öldüğünü, savunanlardan kimsenin ölmediğini yazar; rakam abartılı olabilir. Sıradaki kayıt: 20 Nisan, deniz.","Recorded. The night of 18 April: four hours, and the stockade held. Barbaro writes that two hundred attackers died and not one defender; the figure may be exaggerated. Next entry: 20 April, the sea."
```

```csv
UI_RECAP_36O_PREV,"Siperin önüne kazık çaktın, Şahi'yi kütüklerle bataryaya çektin; 12 Nisan'da ilk gülle sağlam sura indi.","You planted stakes before the rampart and hauled the great gun into its battery; on 12 April the first ball struck the sound wall."
UI_RECAP_36O_NEXT,"Barikat sabaha yine ayakta. 20 Nisan, Haliç'in ağzı: Baltaoğlu'nun kadırgasında dört yüksek gemiye karşı.","By morning the stockade is up again. 20 April, the mouth of the Horn: on Baltaoğlu's galley against four tall ships."
```

`D36O_RD_01`'deki "Çifte Sütunlar" Diplokionion'dur (bugünkü Beşiktaş). Baltaoğlu'nun donanmasının demir yeridir;
29o'da Sultan atını bu kıyıdan denize sürer (**R**).

---

## 5. Akış: yeni Osmanlı başlangıcı

| # | İç id | Sahne | Tarih | Gerilim | Sonuçlar |
|---|---|---|---|---|---|
| 13 | 33 | `chapter33o` (yeni) | 31 Ağustos ve 26 Kasım 1452 | serbest tırmanış + çöken kalas, çıkrık dengesi, akıntı ve kayalar, yalpalı ip merdiven, 75 sn top | 33O.1 / 33O.2 |
| 14 | 34 | `chapter34o` (yeni) | Ocak 1453 | çift çıkrık + mandal, kaçak gülle, buzda kızak kovalamaca, ateş almayan top | 34O.1 / 34O.2 |
| 15 | 35 | `chapter35o` (yeni) | Şubat–Mart 1453 | kirişte denge + kütükler, kopan halat, fren ipi, kaçan öküzler | 35O.1 / 35O.2 |
| 16 | 28 | `chapter28o` | 6 ve 11–12 Nisan | (değişmedi; açılışta 3 replik) | 28O.1 / 28O.2 |
| 17 | 36 | `chapter36o` (yeni) | 18 Nisan gecesi | ok ve ateş çömleği, kanca + yuvarlanan fıçı, meşale + taş, düello + tüfekçi | 36O.1 / 36O.2 |
| 18 | 29 | `chapter29o` | 20 Nisan | (değişmedi) | 29O.1 / 29O.2 |
| … | | | | OTTOMAN_STORY §1'deki sıra, numaralar +4 | |

**Hikâye bağları:**
- **Urban'ın ipi:** 33o ilk top → 34o büyük top → 35o yol → 28o batarya → 36o barikat → 20o gedik.
  - "Kâtip" hitabı ve "Tunç sabır ister" 28o'dan önce kurulmuş olur.
  - 20o'daki `D20O_U_01` ("Kazanı patlatan, sonra kaçan adam… Yoksa başkası mıydı?") Bölüm 6a'ya gönderme yapar ve
    olduğu gibi kalabilir: Urban, Tolga'yı hem kâtibi hem de garip bir yabancı olarak hatırlar.
- **Halil ve Zağanos:** 33o'daki kule yarışı, 25'teki meclis karşıtlığının (barış / hücum) tohumudur.
- **Tellal:** 34o'daki tellal ile 32o'daki tellal aynı anahtardır. İlk ve son duyuru aynı sesle yapılır.
- **Kanca:** 29o'da Baltaoğlu'nun kancaları, 36o'da barikatın kancaları. 36o'nun ulağı Tolga'yı doğrudan kadırgaya
  gönderir.
- **Büro hiç anılmaz:** NPC'ler Tolga'ya "kâtip", "yol kâtibi", "topçu kâtibi" der. "Büro" kelimesi yalnız Nihat'ın
  telsizinde geçer.

**Durarak konuşma payı (tahmini):**

| Bölüm | Toplam süre | Durarak konuşma | Pay |
|---|---|---|---|
| 33o | ~11 dk | ~2 dk | %18 |
| 34o | ~11 dk | ~1 dk 10 sn | %11 |
| 35o | ~11 dk | ~1,5 dk | %14 |
| 36o | ~11 dk | ~1 dk 15 sn | %11 |

**Seslendirme listesi:** Yeni replikler `docs/voice/NEW_V0550.txt`'ye eklenir (sürüm numarası yapımcının):
`D33O_`, `D34O_`, `D35O_`, `D36O_` önekli bütün replikler, `D17_N_FIRST_33` ve değişen `D28O_N_01`, `D28O_U_01`,
`D28O_U_HAUL`.
