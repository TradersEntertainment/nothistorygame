# Bizans Aynası · Her Osmanlı bölümüne bir Bizans karşılığı ve co-op bağlantıları (v0.1)

Bu belge kuşatmanın iki nüshasını **aynı olayda yan yana** oynatmak için yazıldı. Hedef, ileride gelecek bir **co-op
kipi**: bir oyuncu Osmanlı nüshasında (`chapterNNo`), öbürü Bizans nüshasında (`chapterNN` / `chapterNNb`) aynı günü,
aynı yerde ya da aynı saatte, **birbirine kenetlenen** görevlerle oynar. Bunun için:

1. Her Osmanlı bölümünün bir Bizans karşılığı olmalı. Karşılığı olmayan dokuz Osmanlı bölümü için burada **dokuz yeni
   Bizans bölümü** var (§3–§11): `33b`, `34b`, `35b`, `28b`, `37b`, `32b`, `38b`, `39b`, `31b`.
2. Var olan ve yeni her çift için bir **co-op bağlantısı** yazıldı: eşzamanlama noktaları, ortak sayaçlar, kimin neyi
   gördüğü, sonuçların nasıl birleştiği (§2 çerçeve, yeni bölümlerin içinde ve §12).

Biçim OTTOMAN_STORY.md §4 ve OTTOMAN_NEW_B.md ile aynıdır: Tarihî dayanak · Yer ve sistemler · Fazlar (+ animasyon ve
görsel geri bildirim) · Sonuçlar · Konuşanlar · Metinler (strings.csv'ye yapıştırılmaya hazır CSV: `anahtar,tr,en`) ·
Co-op bağlantısı.

**İlkeler (değişmedi):** *tarih inatçıdır*; Tolga sonucu değil insanları değiştirir; **Kerkoporta rivayeti kullanılmaz**;
1453'teki hiçbir karakter "Büro"yu bilmez (Büro yalnız Nihat'ın telsizindedir); sonraki anlatılara dayanan ayrıntılar
**(rivayet)** ya da metin içinde "rivayete göre", oyunun kendi yorumu **(kurgu)** diye işaretlidir; şiddet ve yağma
süslenmez, şehrin düşüşü 39o'daki ölçüyle gösterilir (yağma ekranda yok; ölüm ve esaret Nihat'ın tek cümlesiyle söylenir).

**Kullanıcının bu belge için kuralları:**
- Her bölüm **oynanabilir ve heyecanlı**: yalnız diyalogdan ya da düz "al-götür"den oluşan faz yok. Taşıma varsa kısa ve
  bir bükümle (denge, zamanlama, gizlilik, tehlike). OTTOMAN_NEW_B v0.2 kuralı burada da geçerli: her bölümde **gerçek
  başarısızlık durumu olan en az iki gerilimli mekanik**, durdurulan konuşma oyun süresinin **%25'inden az**.
- Her görevin **görünür animasyonu** var: ip gerçekten A'dan B'ye uzanır, düğüm sarımları görünür (OTTOMAN_NEW_A §0.5),
  NPC'ler aynı işi aynı ritimde yapar, kırılan şey parçalanır. **Tırmanma görevleri** (serbest tırmanış, ip, direk,
  çan kulesi, sur yüzü) bilerek çok kullanıldı.
- Zemin kuralı (OTTOMAN_NEW_A §0.5, OTTOMAN_NEW_B "ortak görsel kurallar") bütün yeni bölümler için aynen geçerlidir:
  figüranlar seviyenin `ground_y` / `hf` işleviyle oturur, görüş alanında belirmez, yürüyerek gelir ve gider.

Kaynak kısaltmaları: **R** Runciman (*The Fall of Constantinople 1453*), **B** Barbaro'nun günlüğü, **K** Kritovoulos,
**S** Sphrantzes, **L** Leonardo of Chios (Sakız'lı Leonardo, Papa'ya mektup), **D** Doukas, **TB** Tursun Bey,
**AP** Aşıkpaşazade.

---

## 1. Eşleme tablosu

`Siege.ORDER` OTTOMAN_NEW_A §0.2 + OTTOMAN_NEW_B §0 birleşimiyle (36o, 37o ile değiştirildi; ikisi aynı geceyi anlatır,
yapılan 37o'dur):

```gdscript
const ORDER := [33, 34, 35, 28, 37, 29, 17, 18, 19, 20, 30, 21, 22, 23, 24, 25, 32, 26, 38, 39, 31, 27]
```

| İç id | Osmanlı sahnesi | Bizans karşılığı | Durum | Tarih | Yer | Co-op türü |
|---|---|---|---|---|---|---|
| 33 | `chapter33o` (planlı) Boğazkesen | **`chapter33b` Yelken İndir** | **YENİ** (§3) | 31 Ağustos ve Kasım–26 Kasım 1452 | Boğazkesen önü, Ceneviz gemisi | aynı harita (`Bogaz`) |
| 34 | `chapter34o` (planlı) Tuncun Sesi | **`chapter34b` Uzun Adam** | **YENİ** (§4) | 29 Ocak – Şubat başı 1453 (Osmanlı: Ocak 1453, Edirne) | Haliç rıhtımı, Mesoteichion, hendek | uzak eşleşme |
| 35 | `chapter35o` (planlı) Edirne Yolu | **`chapter35b` Silivri Gözcüleri** | **YENİ** (§5) | Şubat–Mart 1453 | Trakya yolu, Selymbria (Silivri) | aynı harita (`ThraceRoad` genişletilir) |
| 28 | `chapter28o` İlk Atış | **`chapter28b` Yün Balyaları** | **YENİ** (§6) | 6 ve 11–12 Nisan | Mesoteichion, Aziz Romanos kapısı | aynı harita (`LandWalls`) |
| 37 | `chapter37o` İlk Hücum | **`chapter37b` Barikat** | **YENİ** (§7) | 18 Nisan gecesi | Mesoteichion barikatı | aynı harita |
| 29 | `chapter29o` Zincirin Önü | `chapter29` (Cattaneo'nun karakası) | var | 20 Nisan | Haliç ağzının dışı | aynı harita (`SeaBattle`) |
| 17 | `chapter17o` Kundak (kıyı topları) | `chapter17` (Trevisano'nun kadırgası) | var | 28 Nisan gecesi | Haliç | aynı harita (`SeaWalls`) |
| 18 | `chapter18` (ortak sahne, Osmanlı içerik) | `chapter18b` (surdan küçük top) | var | Mayıs başı | Haliç'in iç ucu | aynı harita (`Horn`) |
| 19 | `chapter19o` Devriye | `chapter19` Brigantin | var | 3 Mayıs gecesi → 23 Mayıs | Zincirin ağzı | aynı harita |
| 20 | `chapter20o` Gedik (gündüz top) | `chapter20` Gedik (gece onarım) | var | 7 Mayıs | Mesoteichion | aynı harita |
| 30 | `chapter30o` Blakherna (merdiven) | `chapter30` Blakherna (sur yolu) | var | 12 Mayıs gece yarısı | Blakherna suru | aynı harita (`Blachernae`) |
| 21 | `chapter21o` Lağım (kazı) | `chapter21` Lağım (su kapları, karşı lağım) | var | 16 Mayıs | Mesoteichion, toprağın altı | aynı harita |
| 22 | `chapter22o` Kule (kurmak) | `chapter22` Kule (yakmak) | var | 17–19 Mayıs | Mesoteichion | aynı harita |
| 23 | `chapter23` (ortak, `osm` dalı) | `chapter23` (Bizans dalı) | var (ortak sahne) | 21 Mayıs | Blakherna sarayı | aynı sahne + co-op'a fiziksel ön faz (§12.9) |
| 24 | `chapter24o` Alametler (ordugâh) | `chapter24` Alametler (ikona, sis) | var | 22, 24–25 Mayıs | ordugâh / şehir | uzak eşleşme + ortak fırtına |
| 25 | `chapter25` (Osmanlı dalı, meclis) | `chapter25` (Bizans dalı, ışıklar) | var (ortak sahne) | 27 Mayıs gecesi | otağ / kara surları | uzak eşleşme |
| 32 | `chapter32o` Son Gün | **`chapter32b` Çanlar** | **YENİ** (§8) | 28 Mayıs | Mesoteichion, Aziz Romanos kilisesinin çan kulesi | aynı harita |
| 26 | `chapter26o` Şafak (saka) | `chapter26` Şafak (Giustiniani) | var | 29 Mayıs 01.30 → öğleden sonra | Mesoteichion, Ayasofya | aynı harita |
| 38 | `chapter38o` Haliç Surları (donanma) | **`chapter38b` Zincir** | **YENİ** (§9) | 29 Mayıs 01.30 → öğle | Haliç suru, Petrion kapısı, zincir | aynı harita (`Horn` + `SeaWalls.gate`) |
| 39 | `chapter39o` Emanet | **`chapter39b` Sığınak** | **YENİ** (§10) | 29 Mayıs akşamı → gece | Petrion | aynı harita (`Petrion`) |
| 31 | `chapter31o` (planlı) Cuma | **`chapter31b` Sarnıç** | **YENİ** (§11) | 30 Mayıs – 1 Haziran | yanık ev, sarnıç, Haliç | kısmen aynı harita |
| 27 | `chapter27` (ortak) | `chapter27` (ortak) | var (ortak sahne) | 1 Haziran | Galata | aynı sahne (§12.13) |

**Bizans tarafının uzunluğu:** bugün Bizans nüshası 13 bölüm (17, 18b, 19, 20, 30, 21, 22, 23, 24, 25, 26, 29, 27).
Yeni dokuz bölümle 22 olur; `{N}` numaraları `Siege.fill_number` ile kendiliğinden kayar, kod değişmez (`scene_path`
`chapterNNb.tscn` varsa onu seçer). Tek başına oynayan Bizans oyuncusu için hepsi varsayılan olarak açıktır; yapımcı
isterse 33b–35b'yi `GameState.flags["siege_long"]` ile "uzun nüsha"ya bağlayabilir (OTTOMAN_NEW_A'nın 33o–35o'su için de
aynı bayrak önerilir).

**Kronoloji düzeltmesi (Bizans):** 25'in Bizans dalı 27 Mayıs gecesi (ışıklar) ve 28 Mayıs akşamı (Ayasofya ayini)
diye ikiye bölünür. 32b 28 Mayıs'ın bütün gününü oynattığı için **Ayasofya ayini 32b'nin 4b fazına taşınır** (sahne kodu
`chapter25.gd`'deki Ayasofya aşaması statik bir yardımcıya çıkarılıp yeniden kullanılır); 25'in Bizans dalı 27 Mayıs
gecesinde biter. Bu, Osmanlı tarafında 25'teki ateş başının 32o'ya taşınmasının (OTTOMAN_STORY §2.1) aynısıdır.

---

## 2. Co-op çerçevesi

Bu bölüm bütün çiftler için ortak kuralları verir; her bölümün "Co-op bağlantısı" yalnız kendi olaylarını yazar.

### 2.1 İki Tolga

Co-op'ta iki oyuncu da Tolga'dır: Büro aynı tanığı iki nüshaya birden gönderir. Nihat bunu Büro'da bir formla açıklar
(`D_COOP_N_01..03`, aşağıda). Görsel ayrım: Osmanlı Tolga'sı fesli; Bizans Tolga'sının fesi bir Bizans kukuletasının
altındadır (yalnız kenarı görünür; Niko'nun "fes rengi: kırmızımsı" esprisi sürer). Ekranda öbür oyuncunun adı
"Tolga (Osmanlı nüshası)" / "Tolga (Bizans nüshası)" diye yazılır.

### 2.2 Paradoks mesafesi

İki Tolga birbirine **3 m'den fazla yaklaşırsa** Nihat'ın Paradoks göstergesi (`NihatMeters`, var) saniyede %25 dolar,
ekran kenarı mavi titrer, telsizde cızırtı. %100'de ikisi de 10 m geri "çekilir" (Büro ayırması: 0,4 sn beyaz parlama,
`TimeVortex` küçük girdabı), 5 sn hareketsiz kalır. Bu kural üç işi birden görür:
- **Oyuncular birbiriyle dövüşmez:** aynı gedikte, aynı merdivende olsalar bile aralarında görünmez bir "Büro mesafesi"
  vardır.
- **"Göz göze" anları** her bölümde senaryo gereği 4 m'de kurulur: iki Tolga bir an durur, birer bark söyler
  (`D_COOP_T_MEET_*`), çekilir. Gösterge %60'a sıçrar: hemen ayrılmazlarsa ayırma gelir.
- Ortak kurtarmalarda (31b kiriş, 38b rıhtım, 39b ip) iki oyuncu **aynı nesnenin iki ucunda** durur; uç noktalar
  arası ≥ 3,2 m olacak biçimde yerleştirilir.

### 2.3 Zarar kuralı

- `Duel`, `WaveRunner`, `Handgun`, `GunRange` öbür oyuncunun hayaletini (ghost) hedef listesinden çıkarır; kılıç ve kurşun
  içinden geçer.
- Bir oyuncunun öbürüne **dolaylı** yaşattığı tehlikeler (merdiveni çatalla itmek, uyarı atışının halkası, ok yaylımı
  çağırmak, ip kesmek, gülle düşürmek) her zaman **telgraflıdır** (≥ 1,2 sn uyarı, halka, gölge, ses) ve en çok −30 can
  götürür. Can 0'da bölümün mevcut "yere düşme / kaldırılma" akışı çalışır; ölüm yok.
- Kaynar yağ (`OilHazard`), ateş çömleği, Rum ateşi **hiçbir zaman oyuncu tarafından tetiklenmez**; senaryo (NPC) tetikler.
  Bizans oyuncusu kazanın yanında durabilir ama kolu çeken NPC'dir. Bu, şiddetin oyuncunun eline verilmemesi içindir.

### 2.4 Sahiplik

Paylaşılan her nesnenin bir sahibi vardır; durumunu yalnız sahibi yazar, öbür taraf olay gönderir:
- **Osmanlı sahibi:** merdivenler, kancalar ve ipleri, Osmanlı tekneleri, ordugâh topları, mantolar, hendek demetleri,
  kule (22), lağım tüneli (21).
- **Bizans sahibi:** sur üstündeki her şey (çatallar, kazanlar, mazgal kalkanları, çanlar), barikat fıçıları, kapılar
  ve kapı çubukları, deniz kapısı, Bizans/Venedik/Ceneviz gemileri, kuyular.
- Bir nesne el değiştirebilir (ör. 37'de barikattan sökülen fıçı Osmanlı'ya geçer; `Coop.transfer(id, side)`).

### 2.5 Eşleme türleri

| Tür | Ne demek | Hayalet (öbür Tolga) | Örnek |
|---|---|---|---|
| **Aynı harita** | İki sahne aynı seviye kurucusunu, aynı koordinatlarla kurar (`LandWalls` Lykos kesiti, `Blachernae`, `Horn`, `SeaBattle`, `Petrion`, 21 tüneli, `Bogaz`, `ThraceRoad`) | Görünür; 10 Hz konum + animasyon durumu (`walk`, `run`, `climb`, `row`, `carry`, `crouch`, `pull`, `balance`, `sit`) | 20, 21, 26, 37, 38, 39 |
| **Uzak eşleşme** | Taraflar ayrı yerlerde; aynı saat ve birbirine giden **haber olayları** | Yok; yerine Nihat'ın telsiz köprüsü (`D_COOP_N_BRIDGE_*`) ve haber kartı (ekranın sağ üstünde 4 sn) | 24, 25, 34 |
| **Aynı sahne** | Ortak `chapterNN` iki dalla (23, 25, 27) | Görünür | 23, 27 |

### 2.6 Ortak saat ve eşzamanlama

- `Coop.clock`: iki taraf yüklenince `SYNC_0` olayıyla sıfırlanır (bölüm başlığı kartı bitince).
- Her fazın bir **zaman penceresi** vardır (bölümlerde "saat" sütunu ve co-op tablolarında `t=` değeri). Erken biten
  taraf **oyalanma döngüsüne** girer: donmuş ekran değil, kısa bir yan iş (ör. ok sandığını doldurmak, kürek sapını
  sarmak; E ile, ödülsüz) ve Nihat'ın bir bark'ı. En çok **20 sn**; sonra öbür tarafın eksik olayını gölge (2.7) üretir
  ve iki taraf devam eder.
- Eşzamanlama noktaları belgelerde **⟷** işaretiyle yazılıdır.

### 2.7 Tek kişilik oyun = gölge

Her gelen olayın bir **gölge varsayılanı** vardır (`CoopShadow`): tek kişilik oyunda öbür tarafın olayları bölümün
kendi zamanlamasıyla senaryodan gelir (ör. 37b'de kancayı atan Osmanlı NPC'dir, 32o'da demet avlayan kanca Bizans
NPC'sidir). Böylece **aynı sahne kodu** tek kişilik ve co-op'ta çalışır; co-op yalnız olay kaynağını değiştirir.
`--autotest` botu co-op'ta gölge yerine geçebilir: `--coop=loop` tek süreçte bir tarafı oynatır, öbür tarafın olaylarını
o tarafın autotest botunun zamanlamasıyla üretir.

### 2.8 Sonuçların birleşmesi

- Her taraf kendi sonucunu yazar (`37O.1`, `37B.2` …); tarih iki tarafta aynıdır.
- Ek olarak bir **ortak düğüm** `COOP_<NN>_A` / `COOP_<NN>_B` (iki değer) iki tarafın akış şemasında, kendi sonuçlarının
  altında, ince çizgiyle gösterilir (`FLOW_COOP_<NN>_A/B`). Bayrak: `GameState.flags["coop_<nn>"] = "a" / "b"`.
- **Çift kayıt:** iki oyuncu aynı hedefi ±3 sn içinde tespit ederse dosyanın o sayfasında iki fotoğraf yan yana durur ve
  "ÇİFT KAYIT" damgası basılır (`UI_COOP_DOUBLE`). Başarım önerisi `ACH_COOP_DOUBLE` (10 çift kayıt).
- Co-op'ta 26.3 ("hücum püskürtüldü", `Siege.resolve` → W10/W11/W12) **kapalıdır**: iki nüsha aynı anda tutulurken
  tarih dışı bir dal açılmaz. 26'da uyarı seçeneği yine vardır, Giustiniani'yi kurtarmaz; yalnız bir bark ekler.

### 2.9 Teknik iskelet

- **Yeni autoload** `scripts/autoload/coop.gd` (`Coop`): `active`, `role` ("O"/"B"), `clock`, `emit(ev: String, data :=
  {})`, `on(ev, cb)`, `transfer(id, side)`, `ghost: Node3D`, `meet_check()` (paradoks mesafesi).
- **Ağ:** Steam lobisi (`SteamBridge` var) üzerinden P2P; olaylar güvenilir kanal, hayalet konumu güvenilmez 10 Hz.
  Yerel bölünmüş ekran bu belgenin kapsamında değil.
- **Hayalet:** `Player`'ın görsel modeli + `Rig` animasyon durumları; çarpışmasız; `sight_dodgers` grubunda (konuşma
  görüş hattını kesmez, `Hud.sightline`).
- **Olay adları:** `"<id>.<olay>"`, ör. `"37.hook"`, `"37.cut"`. Her bölümün co-op tablosu olayları, yönü
  (O→B / B→O), veriyi ve etkiyi yazar.
- **Test:** `--chapter=NN --coop=loop[:O|:B]` (tek süreç, öbür taraf bot), `--coop=pair --coop-port=7777` (iki süreç,
  localhost). Çıktı satırları: `COOPEVT <ad> <yön> <t>`, `COOPMEET <t> <mesafe>`, `COOPCHECK PASS|FAIL <sebep>`
  (her olayın en az bir kez gidip geldiği, hiçbir tarafın 20 sn'den fazla beklemediği, iki tarafın aynı tarihî sonla
  bittiği denetlenir).

### 2.10 Co-op'un ortak replikleri

```csv
UI_COOP_DOUBLE,"ÇİFT KAYIT","DOUBLE RECORD"
UI_COOP_GHOST_O,"Tolga (Osmanlı nüshası)","Tolga (Ottoman copy)"
UI_COOP_GHOST_B,"Tolga (Bizans nüshası)","Tolga (Byzantine copy)"
UI_COOP_WAIT,"Öbür nüsha yetişiyor…","The other copy is catching up…"
UI_COOP_PARADOX,"Paradoks! Öbür Tolga'dan uzaklaş","Paradox! Move away from the other Tolga"
D_COOP_N_01,"Tolga Bey, bir aksilik var. Daha doğrusu iki. Büro sizi iki nüshaya birden gönderiyor. Yönetmelik 7/c, ek fıkra: Çift Nüsha Tanıklığı. Formun adı Z-1453/GT-Ç.","Mr Tolga, there's a complication. Two, in fact. The Bureau is sending you to both copies at once. Regulation 7/c, supplementary clause: Dual-Copy Witnessing. The form is Z-1453/TW-D."
D_COOP_T_01,"Yani aynı kuşatmada iki ben. Biri fesli, biri kukuletalı. Hangisi primi öder?","So two of me at the same siege. One in a fez, one in a hood. Which one pays the premium?"
D_COOP_N_02,"İkiniz de. Kural basit: birbirinize üç metreden fazla yaklaşmayın. Yaklaşırsanız göstergem dolar ve Büro sizi ayırır. Ayırma işlemi... hoş değildir.","Both of you. The rule is simple: don't come within three metres of each other. If you do, my meter fills and the Bureau separates you. Separation is... not pleasant."
D_COOP_N_03,"Bir de: birbirinize zarar veremezsiniz. Tarih buna izin vermez, ben de vermem. Birbirinizin işini zorlaştırabilirsiniz; bu kadarı tarihte de vardı.","One more thing: you cannot harm each other. History doesn't allow it, and neither do I. You can make each other's work harder; that much was in history too."
D_COOP_N_PARADOX,"Tolga Bey ve Tolga Bey! Üç metre!","Mr Tolga and Mr Tolga! Three metres!"
D_COOP_N_SPLIT,"Ayırdım. Lütfen tekrarlamayın; form üç nüsha doldurulur.","Separated. Please don't do it again; that form is filled in triplicate."
D_COOP_N_BRIDGE_O,"Öbür nüshadan haber var, Tolga Bey: Osmanlı tarafında şu an iş bitti. Sizinki de bitsin.","News from the other copy, Mr Tolga: on the Ottoman side the job's just been done. Let's finish yours too."
D_COOP_N_BRIDGE_B,"Öbür nüshadan haber var, Tolga Bey: Bizans tarafında şu an iş bitti. Sizinki de bitsin.","News from the other copy, Mr Tolga: on the Byzantine side the job's just been done. Let's finish yours too."
D_COOP_T_MEET_1,"...Bıyığım bu kadar çarpık mı duruyor?","...Is my moustache really that crooked?"
D_COOP_T_MEET_2,"Kendime el sallamak. Sigorta hayatımda yaşamadığım tek şey buydu.","Waving at myself. The one thing my insurance career never prepared me for."
D_COOP_T_MEET_3,"Bakmayın öyle. Ben de sizin kadar şaşkınım.","Don't look at me like that. I'm as confused as you are."
D_COOP_N_WAIT,"Öbür nüsha biraz geride. Bekleyin; tarih iki tarafı aynı anda yazar.","The other copy is a little behind. Wait; history writes both sides at once."
```

---

## 3. Bölüm 33b — "Yelken İndir" (31 Ağustos, Kasım ve 26 Kasım 1452)

### 3.1 Tarihî dayanak

- **Boğazkesen:** Hisar Ağustos 1452'nin sonunda bitti (**K**, **D**). Bundan sonra Boğaz'dan geçen her gemi yelken
  indirip durmak ve geçiş hakkı ödemek zorundaydı; hisarın dibine büyük toplar kondu (**D**, **R**). Dizdar Firuz Ağa
  (**D**).
- **Galata ve Ceneviz gemileri:** Galata Cenevizlileri resmen tarafsızdı, şehre gizlice yardım ettikleri kaynaklarda
  vardır (**R**). Ambardaki saklı sandık 33o'daki ile **aynı kurgudur**; bu bölüm onu sandığı saklayan taraftan oynatır.
- **31 Ağustos'taki geçiş:** hisar biterken bir Ceneviz gemisinin topların yerleşmesinden önce son kez serbestçe geçmesi
  **(kurgu)**.
- **Rizzo:** 26 Kasım 1452'de (Barbaro ve Venedik kaynakları) Antonio Rizzo'nun Venedik gemisi yelken indirmedi; hisarın
  büyük topundan çıkan tek bir gülle onu batırdı (**D**, **R**). Kaptan ve tayfa kıyıya çıkınca yakalandı; akıbetleri
  kötüdür (**D**). Bölüm bunu **göstermez**; Nihat bölüm sonunda tek cümleyle söyler (33o ile aynı ölçü).
- Ceneviz gemisinin direkten bayrakla Rizzo'yu uyarması, geminin sandalının suya düşen denizcileri çekmesi **(kurgu)**:
  tarihi değiştirmez (Rizzo yine durmaz, tayfa yine kıyıda yakalanır), yalnız birkaç kişinin soğuk suda boğulmamasını
  sağlar. "Tolga sonucu değil insanları değiştirir."

### 3.2 Yer ve sistemler

- **Harita:** 33o'nun `Bogaz` seviyesi (`scripts/level/bogaz.gd`, OTTOMAN_NEW_A §1.2) **aynen**: Halil Paşa'nın deniz
  kulesi, kıyı bataryası, akıntı (+X), Akıntıburnu kayaları, karşı kıyı. 33o önce yapılmalıdır.
- **Gemi:** `SeaBattle` karakası, Ceneviz renkleri (kırmızı haç). **Tek yeni parça:** `SeaBattle.rigging(ship)`: ana
  direğin iki yanında **ıskaça ağı** (çarmıh basamakları; `player.enable_climb` alanı, ağ yüzü tutunulur), seren ve altında
  **ayak halatı** (yürünür, 0,25 m), seren üstünde dört **kalçete** (yelken bağı) düğümü, direk tepesinde **çanaklık**
  (1,2 m platform), kıça inen **kıç istinga** (E basılı kayılır). Ağ ve halatlar OTTOMAN_NEW_A §0.5'e göre görünür katener.
- **Ambar:** 33o'nun ambarı (balya, fıçı, bal küpleri, kenevir); üç saklama yeri işaretli: kenevir yığınının arkası, bal
  fıçılarının altı, sintine kapağı.
- **Sandal:** 17'nin kayığı + `RowMeter` kürekçi animasyonu (`Rig.row_phase`).
- **Yeniden kullanılan:** `Traversal` (serbest tırmanış, nefes), `BalanceMeter` (seren, direk, çanaklık), zamanlı tuş (32o
  basamak → kalçete düğümü), `RowMeter`, 17'nin sudan çekme döngüsü (E basılı, dalga anında bırak), 25'in nöbetçi bakış
  konisi (kâtibin feneri), `TespitCam`, `hud.choose`, `Lore.scatter(self, "33b")`.
- **Süre hedefi:** 10–12 dk; durdurulan konuşma ≤ 2 dk.

### 3.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Son serbest geçiş | 31 Ağustos, öğle | `UI_OBJ33B_SHROUD`, `UI_OBJ33B_YARD`, `UI_OBJ33B_GASKET` | Kaptan Bartolomeo topların yerine konmasından önce hisarın önünden **tam yelkenle** geçmek ister. (a) Iskaça ağına **tırman** (9 m, nefes; gemi yalpaladıkça ağ 0,4 m açılıp kapanır). (b) Serene çık, **ayak halatında yürü** (`BalanceMeter`; her ~4 sn yalpa, iki kez sert **bora**: 1 sn önce sancak çırpınır). (c) **Dört kalçeteyi çöz**: işaret yeşilken E (ıska: düğüm sıkışır, 2 sn). Gabya yelkeni düşer, rüzgârla dolar. **3 dk**: gemi hisarın hizasını geçerken sağ üstte kule iskelesinin ilerleme simgesi (33o'nun çıkrığı). | Düşüş: güverteye −20 can, ağa yeniden tırman. Süre biterse lostromo çözer. Sayaç: kalçete /4, düşüş. |
| 2a. Yelken indir | Kasım, sabah ("Kasım 1452 · gümrük" kartı) | `UI_OBJ33B_FURL` | Bu sefer kural var: hisardan **boş atış** (Firuz). Bartolomeo: "İkincisi boş olmaz." **45 sn**: ana yelkeni topla: ağa tırman, serende üç kalçeteyi **bağla** (E basılı → yelken sarılır, işaret yeşilken Space = düğüm). | Süre biterse ikinci atış gerçek gelir: geminin 20 m önüne su sütunu (zarar yok, sarsıntı), `toll_late = true`, dosyada bir cümle. |
| 2b. İp merdiven | Hemen ardından | `UI_OBJ33B_LADDER` | Gümrük kayığı yanaşır (33o'da Osmanlı Tolga'sı kürektedir). Bordadan **ip merdiveni sal**: dalga göstergesi; yalpanın tepesinde (yeşil) E → merdiven kayığın üstüne düzgün iner. Kırmızıda salınırsa merdiven bordaya çarpar, tırmanan kâtip bir an suya batar ("Dalga!"), Firuz gürler. | Sayaç: `ladder_ok`. |
| 2c. Ambar | Ardından, **40 sn** | `UI_OBJ33B_HIDE` | Kâtip fenerle ambarı dolaşır (bakış konisi, yer ışığı). Ceneviz tayfası Tolga'ya arbalet okları dolu **sandığı** uzatır. Sandık ağır (yürüme %50), hızlı taşınırsa gıcırdar (gürültü halkası 3 m; kâtip halkayı duyarsa döner). Üç saklama yerinden birine **koy** (E), kâtip yaklaşırsa başka yere **taşı**. Kâtip kenevir balyasını kaldırırsa ve sandık oradaysa: bulundu. Davul sesi süreyi sayar (33o'daki davul). Sonra kaptan kâtibe "hediye" uzatır: **seçim** `UI_C33B_STOP` (kaptanın kolunu tut) / `UI_C33B_QUIET` (sus). | `toll_hidden_b = true/false`, `toll_gift_b = "stop"/"quiet"`. Tarih aynı. |
| 3a. İşaret | 26 Kasım, öğleden sonra ("26 Kasım 1452" kartı) | `UI_OBJ33B_MAST`, `UI_OBJ33B_SIGNAL` | Ceneviz gemisi geçiş hakkı tartışması yüzünden hisarın altında demirli **(kurgu)**. Kuzeyden Rizzo'nun gemisi tam yelkenle gelir. Bartolomeo: "Uyar onu!" (a) **Ana direğe tırman** (12 m; ağ, sonra direğin kendisi: yalnız tutamak halkaları, nefes çubuğu %30 hızlı). (b) Çanaklıkta iki bayrakla **işaret**: A/D sırayla, işaret yeşilken (RowMeter, 8 vuruş), bu sırada `BalanceMeter` (direk rüzgârla sallanır). Rizzo bağırır, durmaz (tarih). Uyarı atışı Rizzo'nun burnunun önüne düşer (33o faz 3). | İşaret ≥6/8: Rizzo'nun geminin baş tarafında yelkene uzanan bir tayfa görünür, sonra vazgeçer (görüntü); <6: hiç kıpırdamaz. Sonuç değişmez. |
| 3b. Gülle | Hemen ardından | `UI_OBJ33B_PHOTO`, `UI_OBJ33B_SLIDE` | Büyük top. Gemi yan yatar. **Tespit:** çanaklıktan yatan direk ve arkada kule (pencere 20 sn; 33o'nun karesinin aynası). Sonra **kıç istingadan kayarak in**: E basılı, hız çubuğu (`BalanceMeter`): kırmızıda "ip yanığı" −10 can, çok yavaş = sandal sensiz kalkar (−10 sn). | Kare kaçarsa not. |
| 3c. Sandal | Akşamüstüne doğru | `UI_OBJ33B_ROW`, `UI_OBJ33B_PULL` | İki Cenevizliyle geminin sandalı. **Akıntıya karşı RowMeter** 80 m enkaza; yüzen fıçı ve kalaslar akıntıyla iner: "Sol!" / "Sağ!" (A/D, dümenciye söyle) yoksa çarpma (sandal döner, 4 sn). Enkazda **üç denizci**: her birinin **soğuk çubuğu** (75 sn'den geriye). 17'nin döngüsü: E basılı çek, sandal dalgada yükselirken (0,8 sn uyarı) bırak, yoksa el kayar. Üçü de içerideyse sandal kıyıya döner. | Soğuk çubuğu biten denizciyi bir kayalığa tutunmuş halde kıyıdakiler alır (görünmez, Nihat söyler). Sayaç: çekilen /3. |
| 4. Kıyı | Akşam | — | Sandalın burnu kuma oturur. Kıyıda askerler bekler; denizciler iner, yürüyerek sırtın ardında kaybolur (arkaları dönük). Bartolomeo sandalı geri iter. Nihat'ın kaydı (≈ 30 sn, yürünebilir). | — |

**Animasyon ve görsel geri bildirim**
- **Faz 1:** ağ her yalpada bordadan açılır, Tolga'nın elleri ağın halkalarına kilitli (Rig el hedefi); ayak halatı her
  adımda 5 cm sarkar; kalçete çözülünce sarımlar tek tek açılır, yelken bezi önce sarkar sonra "pat" diye dolar; lostromo
  ve iki tayfa öbür serende aynı işi yapar. Hisar tarafında 33o'nun iskelesi ve çıkrığı döngüde çalışır (taş yükselir).
- **Faz 2a:** boş atışta hisarın topundan ağız alevi ve beyaz duman, ses 0,6 sn gecikir (mesafe); sarılan yelken serene
  katlanır, her düğümde ip iki tur sarılır (görünür halka). İkinci atış gelirse pruva önünde 6 m su sütunu, sprey pruvayı
  ıslatır.
- **Faz 2b:** ip merdiven bordadan açılır (iki halat + tahta basamak); iyi salışta kayığın küpeştesine yumuşak düşer,
  kâtip tırmanır; kötüde bordaya "şap" çarpar, kâtip beline kadar suya girer, çıkar, fesini sıkar.
- **Faz 2c:** ambar loş, ambar ağzından ışık sütunu ve toz; fener ışığı balyaların üstünde yürür (koni yerde açık sarı);
  sandık iki elle göğüste, Tolga eğilerek yürür; kaldırılan balyanın altı boşsa kâtip omuz silker. Bulunursa kapak
  açılır, ok demetleri görünür, kâtip mühür defterine bir şey yazar.
- **Faz 3a:** direk tepesinde ufuk çizgisi yatar-kalkar; bayraklar (kırmızı, beyaz) her vuruşta çırpılır; Rizzo'nun gemisi
  geçerken tayfası küpeşteye koşar, Rizzo kıç kasarasında el sallar ("Venezia!"), yelkenlere dokunulmaz.
- **Faz 3b:** isabette gövdeden 8 parça kalas, gemi 6 sn'de 25° yatar, direk iner; Tolga'nın istingadan kayışında halat
  ellerinin arasından akar (sürtünme tozu), kırmızıda eldivensiz ellerden duman tüter (komik değil, kısa).
- **Faz 3c:** kürekler aynı evrede; enkaz akıntıyla döner; sudaki denizcilerin başı ve kolu dalgayla iner kalkar,
  Tolga'nın eli onunkini kavrar (IK); çekilen denizci sandalın dibine yığılır, bir Cenevizli üstüne pelerin atar.
- **Zemin:** gemi tayfası geminin çocuğudur (`SeaBattle.CARRACK_DECK`), gemiyle sallanır; kıyıdaki askerler `Bogaz.ground_y`.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **33B.1** Üç denizci sudan çıktı | çekilen = 3/3 | `FLOW_33B_1` |
| **33B.2** Soğuk su bazılarını geri aldı | aksi hâlde | `FLOW_33B_2` |

Tarih ikisinde aynı. `toll_hidden_b`, `toll_gift_b`, `toll_late` yalnız dosya notunda bir cümleyi değiştirir.
`--autotest[=cold|fall]` (varsayılan 33B.1; `=cold`: bot sandalda iki kez dalgada bırakmaz, bir denizci kaçar; `=fall`:
bot serenden bir kez düşer, ambarda sandığı konide taşır, bulunur). Denetim: `gasket=4`, `pulled>=1`, `VISAUDIT` ip ve
ağ katenerleri, sandal su çizgisi. Akış şeması (`UI_FLOW33B_TITLE`): `FLOW33B_RUN` → `FLOW33B_TOLL` → `FLOW33B_SIGNAL` →
`FLOW33B_BOAT` → {`33B.1`, `33B.2`}.

### 3.4 Konuşanlar

Yeni: `SPK_BARTOLO` (Ceneviz kaptanı Bartolomeo, kurgu), `SPK_CUSTOMS` (Gümrük kâtibi, yalnız tek kişilik oyunda;
co-op'ta kâtip Osmanlı Tolga'sıdır ve konuşmaz, yerine hayalet bark'ları `D_COOP_T_MEET_*`). Var olan / planlı:
`SPK_FIRUZ`, `SPK_RIZZO` (OTTOMAN_NEW_A §1.4), `SPK_GENOESE` (lostromo), `SPK_SAILOR`.
Koşullu: `_GASKET_*`, `_BORA`, `_FALL`, `CU_LAMP`, `CU_FOUND`, `CU_NOTHING`, `BR_ROCK`, `S_LEFT/RIGHT`, `_PULL_*` olay
bark'larıdır; seçimden sonra `STOP` ya da `QUIET` çifti.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D33B_N_01` | SPK_NIHAT | say |
| `D33B_T_01` | SPK_TOLGA | say |
| `D33B_BR_01` | SPK_BARTOLO | say |
| `D33B_T_02` | SPK_TOLGA | say |
| `D33B_BR_02` | SPK_BARTOLO | bark |
| `D33B_GE_BORA` | SPK_GENOESE | bark |
| `D33B_T_YARD` | SPK_TOLGA | bark |
| `D33B_GE_FALL` | SPK_GENOESE | bark |
| `D33B_BR_PASS` | SPK_BARTOLO | bark |
| `D33B_N_NOV` | SPK_NIHAT | say |
| `D33B_FZ_BLANK` | SPK_FIRUZ | bark |
| `D33B_BR_FURL` | SPK_BARTOLO | bark |
| `D33B_BR_LATE` | SPK_BARTOLO | bark |
| `D33B_T_LADDER_OK` | SPK_TOLGA | bark |
| `D33B_FZ_LADDER_BAD` | SPK_FIRUZ | bark |
| `D33B_GE_CRATE` | SPK_GENOESE | bark |
| `D33B_T_CRATE` | SPK_TOLGA | bark |
| `D33B_CU_LAMP` | SPK_CUSTOMS | bark |
| `D33B_CU_FOUND` | SPK_CUSTOMS | bark |
| `D33B_CU_NOTHING` | SPK_CUSTOMS | bark |
| `D33B_BR_GIFT` | SPK_BARTOLO | say |
| `D33B_T_STOP` | SPK_TOLGA | say |
| `D33B_BR_STOP` | SPK_BARTOLO | say |
| `D33B_T_QUIET` | SPK_TOLGA | say |
| `D33B_BR_QUIET` | SPK_BARTOLO | say |
| `D33B_N_26` | SPK_NIHAT | say |
| `D33B_BR_WARN` | SPK_BARTOLO | bark |
| `D33B_T_MAST` | SPK_TOLGA | bark |
| `D33B_RZ_01` | SPK_RIZZO | bark |
| `D33B_T_SIGNAL` | SPK_TOLGA | bark |
| `D33B_RZ_02` | SPK_RIZZO | bark |
| `D33B_N_PHOTO` | SPK_NIHAT | bark |
| `D33B_BR_BOAT` | SPK_BARTOLO | bark |
| `D33B_GE_LEFT` | SPK_GENOESE | bark |
| `D33B_GE_RIGHT` | SPK_GENOESE | bark |
| `D33B_T_PULL_1` | SPK_TOLGA | bark |
| `D33B_S_PULLED` | SPK_SAILOR | bark |
| `D33B_T_PULL_3` | SPK_TOLGA | bark |
| `D33B_BR_SHORE` | SPK_BARTOLO | say |
| `D33B_T_END` | SPK_TOLGA | say |
| `D33B_N_END` | SPK_NIHAT | say |

### 3.5 Metinler

```csv
UI_CH33B_TITLE,"BÖLÜM {N} — YELKEN İNDİR","CHAPTER {N} — STRIKE THE SAIL"
UI_CH33B_SUB,"Ağustos–Kasım 1452 · Boğazkesen'in önü, bir Ceneviz gemisinde","August–November 1452 · Below the Throat-Cutter, aboard a Genoese ship"
UI_FLOW33B_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: YELKEN İNDİR","FLOWCHART — CHAPTER {N}: STRIKE THE SAIL"
SPK_BARTOLO,"Kaptan Bartolomeo","Captain Bartolomeo"
SPK_CUSTOMS,"Gümrük kâtibi","Customs clerk"
UI_OBJ33B_SHROUD,"Iskaça ağına tırman (Space ile tutun)","Climb the shrouds (Space to grip)"
UI_OBJ33B_YARD,"Serende ayak halatından yürü: dengede kal","Walk the footrope along the yard: keep your balance"
UI_OBJ33B_GASKET,"Kalçeteleri çöz (işaret yeşilken E) · %d/%d","Cast off the gaskets (E on the green) · %d/%d"
UI_OBJ33B_FURL,"Yelkeni topla, kalçeteleri bağla (E basılı · yeşilde Space) · %d/%d","Furl the sail and tie the gaskets (hold E · Space on the green) · %d/%d"
UI_OBJ33B_LADDER,"İp merdiveni sal: dalga tepedeyken E","Drop the rope ladder: E at the top of the roll"
UI_OBJ33B_HIDE,"Sandığı fenerin göremeyeceği yere sakla (E: koy / al)","Hide the crate where the lantern won't see it (E: put down / pick up)"
UI_OBJ33B_MAST,"Ana direğe tırman: çanaklığa çık","Climb the mainmast: get up to the top"
UI_OBJ33B_SIGNAL,"Bayraklarla Rizzo'yu uyar (A/D sırayla, yeşilde) · %d/%d","Signal Rizzo with the flags (A/D in turn, on the green) · %d/%d"
UI_OBJ33B_PHOTO,"Tespit et: yan yatan gemi ve arkasında kule","Record: the ship heeling over, the tower behind"
UI_OBJ33B_SLIDE,"Kıç istingadan kayarak in (E basılı · hızı ortada tut)","Slide down the backstay (hold E · keep the speed centred)"
UI_OBJ33B_ROW,"Enkaza kürek çek (yeşilde Space) · A/D: sola / sağa","Row to the wreck (Space on the green) · A/D: left / right"
UI_OBJ33B_PULL,"Suya düşenleri çek (E basılı · dalgada bırak) · %d/%d","Pull them out of the water (hold E · let go on the swell) · %d/%d"
UI_PROMPT33B_CRATE,"E: sandığı al","E: pick up the crate"
UI_PROMPT33B_STASH,"E: sandığı buraya koy","E: put the crate here"
UI_PROMPT33B_LADDER,"E: merdiveni sal","E: drop the ladder"
UI_C33B_STOP,"Kaptanın kolunu tut: 'Gerek yok.'","Take the captain's arm: 'No need.'"
UI_C33B_QUIET,"Bir şey söyleme.","Say nothing."
FLOW33B_RUN,"Hisar biterken son serbest geçiş","The last free passage as the fortress is finished"
FLOW33B_TOLL,"Gümrük: ip merdiven ve saklı sandık","The toll: a rope ladder and a hidden crate"
FLOW33B_SIGNAL,"Direkten Rizzo'ya işaret","Signals to Rizzo from the masthead"
FLOW33B_BOAT,"Sandal: soğuk sudakiler","The boat: the men in the cold water"
FLOW_33B_1,"Üç denizci sudan çıktı","Three sailors out of the water"
FLOW_33B_2,"Soğuk su bazılarını geri aldı","The cold water took some back"
UI_CH33B_STATS,"Kalçete: %d/%d   ·   İşaret: %d/%d   ·   Sudan: %d/%d   ·   Dosya: %d/%d sayfa","Gaskets: %d/%d   ·   Signals: %d/%d   ·   From the water: %d/%d   ·   File: %d/%d pages"
SIEGE_NOTE_33B_1,"Boğazkesen. Yelken açtım, yelken topladım, bayrak salladım. Rizzo durmadı. Sudan üç kişi çektim; kıyıda ne olduğunu yazmıyorum, Nihat yazdı. — T.","The Throat-Cutter. I set sail, struck sail, waved flags. Rizzo didn't stop. I pulled three men out of the water; I'm not writing what happened on the shore. Nihat did. — T."
SIEGE_NOTE_33B_2,"Boğazkesen. Bayrak salladım, Rizzo durmadı. Sudan çekebildiklerimi çektim; hepsini değil. — T.","The Throat-Cutter. I waved flags; Rizzo didn't stop. I pulled out those I could; not all of them. — T."
LORE_33B_1_T,"Boğazkesen'in kuralı","The Throat-Cutter's rule"
LORE_33B_1,"Hisar bittikten sonra Karadeniz'den inen ya da çıkan her gemi yelkenini indirip durmak ve geçiş hakkı ödemek zorundaydı. Kıyıya kurulan büyük toplar Boğaz'ın en dar yerini kapatıyordu.","Once the fortress was finished, every ship coming from or going to the Black Sea had to strike its sails, stop and pay a toll. Great guns set on the shore closed the narrowest point of the Bosporus."
LORE_33B_2_T,"Galata'nın tarafsızlığı","Galata's neutrality"
LORE_33B_2,"Galata'nın Ceneviz kasabası resmen tarafsızdı ve Sultan'la ticaretini sürdürdü. Runciman, Cenevizlilerin bir yandan da şehre gizlice yardım ettiğini, adam ve malzeme geçirdiğini yazar.","The Genoese town of Galata was officially neutral and kept trading with the Sultan. Runciman writes that the Genoese also helped the city in secret, slipping men and supplies across."
LORE_33B_3_T,"Antonio Rizzo","Antonio Rizzo"
LORE_33B_3,"Kasım 1452'nin sonunda Venedikli Antonio Rizzo'nun gemisi Karadeniz'den şehre erzak getiriyordu. Yelken indirmedi; hisarın topundan çıkan tek bir gülle gemiyi batırdı. Kaptan ve tayfa kıyıda yakalandı.","At the end of November 1452 the Venetian Antonio Rizzo's ship was bringing provisions from the Black Sea to the city. It did not strike sail; a single ball from the fortress gun sank it. The captain and crew were taken on the shore."
```

Replikler:

```csv
D33B_N_01,"Tolga Bey, Bizans nüshası da erken açılıyor: 31 Ağustos 1452, Boğaz. Bir Ceneviz gemisindesiniz. Karşıda yeni bir hisar bitiyor. Bugün geçen gemiler son kez soru sorulmadan geçecek.","Mr Tolga, the Byzantine copy opens early too: 31 August 1452, the Bosporus. You're aboard a Genoese ship. Across the water a new fortress is being finished. Ships that pass today will be the last to pass without being questioned."
D33B_T_01,"Gemi. Yüksek direk. Rüzgâr. Kasko poliçemde 'denizcilik faaliyetleri' diye bir istisna vardı, şimdi anlıyorum.","A ship. A tall mast. Wind. My policy had an exclusion for 'maritime activities'. Now I understand why."
D33B_BR_01,"Sen yeni tayfa mısın? Hafifsin, iyi. Çık yukarı, gabya yelkenini aç. Topları daha yerine koymadılar; koymadan geçeceğiz.","You're the new hand? You're light, good. Up you go, loose the topsail. They haven't set their guns yet; we pass before they do."
D33B_T_02,"Yukarı. Ağdan. Tabii. Ağ zaten tırmanmak için yapılmış bir şey, değil mi?","Up. By the net. Of course. A net is made for climbing, isn't it?"
D33B_BR_02,"Ayağın halatta, elin seren de! Rüzgâra yaslanma, rüzgâr seni sevmez!","Feet on the rope, hands on the yard! Don't lean on the wind, the wind doesn't love you!"
D33B_GE_BORA,"Bora geliyor! Tutun!","Here comes the bora! Hold on!"
D33B_T_YARD,"Aşağısı deniz, yukarısı gök, ortası ben. Sigortada buna 'yüksek riskli pozisyon' denir.","Sea below, sky above, me in the middle. Insurance calls this a 'high-risk position'."
D33B_GE_FALL,"Düştü! Kalk, kalk; güverte seni bir kere affeder!","He's down! Up, up; the deck forgives you once!"
D33B_BR_PASS,"Geçtik! Bak kuleye: bir taş daha koydular. Gelecek sefere bu kadar kolay olmayacak.","We're past! Look at the tower: they've put one more stone on it. Next time it won't be this easy."
D33B_N_NOV,"Kasım, Tolga Bey. Toplar yerinde. Artık bu kıyıdan geçen herkes yelken indirir, durur ve öder. Geçmeyi deneyen olursa... bunu birazdan göreceksiniz.","November, Mr Tolga. The guns are in place. Now everyone who passes this shore strikes sail, stops and pays. If anyone tries otherwise... you'll see shortly."
D33B_FZ_BLANK,"(Uzaktan, kıyıdan) Yelken indir! Bu boştu! İkincisi boş olmaz!","(From the shore, far off) Strike your sail! That one was empty! The next one won't be!"
D33B_BR_FURL,"Duydun. Yukarı, topla! Yelken açmak cesaret ister, toplamak akıl.","You heard him. Up and furl it! Setting sail takes courage, striking it takes sense."
D33B_BR_LATE,"Geç kaldık. Gülle pruvanın önüne düştü. Firuz Ağa bunu deftere yazar, bana da ceza yazar.","We were late. The ball fell before the bow. Firuz Agha will write it in his ledger, and write me a fine."
D33B_T_LADDER_OK,"Merdiven tam üstüne düştü. Hoş geldiniz, gümrük. Lütfen ayakkabılarınızı... neyse.","The ladder landed right on him. Welcome, customs. Please wipe your... never mind."
D33B_FZ_LADDER_BAD,"Kâtibimi ıslattınız! Bunu da yazacağım!","You've soaked my clerk! I'll write that down too!"
D33B_GE_CRATE,"(Fısıltı) Kaptan der ki: bu sandık ambarda yok. Yoksa, kimse bulamaz. Anladın?","(Whispering) The captain says: this crate isn't in the hold. If it isn't, nobody finds it. Understand?"
D33B_T_CRATE,"Anladım. Bu sandık yok. Ağır bir yokluk.","Understood. This crate doesn't exist. It's a heavy nonexistence."
D33B_CU_LAMP,"Şurada bir ses geldi... Kim var orada?","There was a noise over there... Who's there?"
D33B_CU_FOUND,"Kenevirin altında kenevir yok. Ok var. Bunu beyanda görmedim.","There's no hemp under the hemp. There are arrows. I didn't see these on the manifest."
D33B_CU_NOTHING,"Balık, kenevir, bal, şarap. Beyan doğru. Davul bitti.","Fish, hemp, honey, wine. The manifest is correct. The drum is done."
D33B_BR_GIFT,"Efendi kâtip, yol uzun, rüzgâr soğuk. Şu küçük kese de... çabukluk için.","Master clerk, the road is long, the wind is cold. And this small purse... for speed."
D33B_T_STOP,"(Kaptanın kolunu tutar) Gerek yok, kaptan. Hesap belli.","(Takes the captain's arm) No need, captain. The account is settled."
D33B_BR_STOP,"Hm. Ceneviz'de kesesini geri koyan kaptana deli derler. Bugün deli olayım.","Hm. In Genoa a captain who puts his purse back is called mad. Let me be mad today."
D33B_T_QUIET,"(Susar.)","(Says nothing.)"
D33B_BR_QUIET,"Gördün mü? Kese her dili konuşur.","See? A purse speaks every language."
D33B_N_26,"26 Kasım, Tolga Bey. Geminiz hesabı yüzünden hisarın altında bekliyor. Kuzeyden bir Venedik gemisi geliyor: Antonio Rizzo. Yelkenleri dolu.","26 November, Mr Tolga. Your ship is waiting below the fortress over its account. A Venetian ship is coming from the north: Antonio Rizzo. Her sails are full."
D33B_BR_WARN,"Delirdi mi o? Yelken indirmiyor! Tolga, direğe! Bayrakları al, uyar onu!","Is he mad? He's not striking sail! Tolga, the mast! Take the flags, warn him!"
D33B_T_MAST,"Bu direk ağdan daha yüksek. Ağdan daha az tutamağı var. Ağdan daha çok fikri var.","This mast is taller than the net. It has fewer handholds than the net. It has more opinions than the net."
D33B_RZ_01,"(Uzaktan) Venezia! Şehre erzak götürüyoruz! Kimse durduramaz!","(Far off) Venezia! We're taking food to the city! No one stops us!"
D33B_T_SIGNAL,"Kırmızı, beyaz, kırmızı! Dur demek! Evrensel 'dur'!","Red, white, red! It means stop! The universal 'stop'!"
D33B_RZ_02,"Gördük! Selam size de!","We see you! Greetings to you too!"
D33B_N_PHOTO,"Şimdi, Tolga Bey. Gemi yatıyor, kule arkada. Bir kare. Bu karenin öbür yüzü Osmanlı nüshasında da var.","Now, Mr Tolga. The ship is heeling, the tower behind. One frame. The other side of this frame is in the Ottoman copy too."
D33B_BR_BOAT,"Sandal! Suda adamlar var, su kasım suyu! Tolga, aşağı, küreğe!","The boat! There are men in the water, and it's November water! Tolga, down, to the oars!"
D33B_GE_LEFT,"Sol! Fıçı geliyor!","Left! Barrel coming!"
D33B_GE_RIGHT,"Sağ! Kalas!","Right! Plank!"
D33B_T_PULL_1,"Elini ver. Elini ver! Tamam. Seni tutuyorum.","Give me your hand. Your hand! Right. I've got you."
D33B_S_PULLED,"(Venedikçe, dişleri takırdayarak) Grazie... grazie...","(In Venetian, teeth chattering) Grazie... grazie..."
D33B_T_PULL_3,"Üç. Sandal dolu. Kimse suda kalmadı.","Three. The boat's full. No one left in the water."
D33B_BR_SHORE,"Kıyıya çıkarmak zorundayız. Hisarın kıyısı, hisarın kuralı. Gemiyi alıkoyarlarsa hepimiz kalırız.","We have to put them ashore. The fortress's shore, the fortress's rule. If they hold our ship, we all stay."
D33B_T_END,"Sudan çıkardım, kıyıya bıraktım. Bu sayfanın geri kalanını ben yazmak istemiyorum.","I got them out of the water and left them on the shore. I don't want to write the rest of this page."
D33B_N_END,"Ben yazarım, Tolga Bey; kısa yazarım. Rizzo ve adamları Sultan'ın huzuruna götürüldü ve öldürüldü. Kaynaklar bunu saklamaz. Bu kıyıdan sonra şehrin denizi daralacak.","I'll write it, Mr Tolga; I'll keep it short. Rizzo and his men were taken before the Sultan and put to death. The sources don't hide it. After this shore the city's sea grows narrower."
```

### 3.6 Co-op bağlantısı (33o ⟷ 33b, aynı harita `Bogaz`)

| t / faz | Olay | Yön | Etki |
|---|---|---|---|
| Faz 1 ⟷ 33o faz 1b | `33.bora` (tohumlu rüzgâr çizelgesi) | ortak | İki bora **aynı anda** gelir: 33o'da taş salınır, 33b'de seren sallanır. Osmanlı çıkrığın tepesinden geçen gemiyi, Bizans serenden kuleyi görür (hayalet görünür, 120 m). |
| Faz 1 sonu | `33.tower_stone` | O→B | Osmanlı'nın koyduğu her taş 33b'nin "kule ilerleme" simgesine işler (yalnız görüntü). |
| Faz 2b ⟷ 33o faz 2a–b | `33.boat_alongside`, `33.ladder` | O→B, B→O | Osmanlı kürekte yetişince (`boat_alongside`) Bizans merdiveni salar; **merdivenin düzgün inmesi Osmanlı'nın ip merdiven tırmanışını kolaylaştırır**: iyi salış = 33o'daki "Dalga!" uyarısı 1 sn erken gelir; kötü salış = Osmanlı bir kez suya düşer (`water_falls +1`, zarar yok). |
| Faz 2c ⟷ 33o faz 2c | `33.inspect(spot)`, `33.crate_move(spot)` | O→B, B→O | **Saklambaç:** Osmanlı Tolga'sı fenerle 40 sn ambarı arar (bakış konisi Bizans'ın ekranında görünür), Bizans sandığı taşır. Osmanlı E ile bir yeri "gözlediğinde" sandık oradaysa bulunur. Bizans sandığı taşırken gürültü halkası Osmanlı'nın ekranında kısa bir "gıcırtı" işareti olur. Paradoks mesafesi burada en çok sınanır: dar ambarda 3 m kuralı ikisini de sıkıştırır. |
| Faz 2c sonu | `33.gift` | ortak | Seçimler birleşir: Bizans `stop` derse kese hiç uzatılmaz (Osmanlı'nın `REFUSE/TAKE` seçimi gelmez, yerine `D33O_G_PUT_AWAY` bark'ı önerilir); `quiet` derse Osmanlı kendi seçimini yapar. |
| Faz 3a ⟷ 33o faz 3 | `33.signal(n)`, `33.warn_shot(pos)` | B→O, O→B | Bizans'ın bayrakları Osmanlı'nın ekranında direk tepesinde görünür. Osmanlı'nın uyarı atışı halkası Bizans'ın ekranında Rizzo'nun önünde düşer. |
| Faz 3b ⟷ 33o faz 4 | `33.sink`, `33.photo` | O→B | Büyük top Osmanlı'nındır; batma anı iki tarafta aynı. İki kare ±3 sn içinde çekilirse **çift kayıt**. |
| Faz 3c–4 ⟷ 33o faz 5 | `33.boat_shore` | B→O | Bizans'ın sandalı 33o'daki "tayfanın sandalı"dır: Osmanlı rıhtımda defterini kaparken sandalın gelişini görür. **Göz göze:** iki Tolga 4 m'de durur (`D_COOP_T_MEET_3`), çekilir. |

**Ortak düğüm:** `COOP_33_A` "Ambar: sandık bulunmadı" / `COOP_33_B` "Ambar: sandık bulundu" (saklambacın sonucu).
Tek kişilik gölge: kâtip NPC'si (`SPK_CUSTOMS`) 33o'daki botun arama sırasıyla dolaşır; 33o'nun gölgesinde sandık
taşıyan Cenevizli NPC'dir.

---

## 4. Bölüm 34b — "Uzun Adam" (29 Ocak – Şubat başı 1453)

### 4.1 Tarihî dayanak

- **Giustiniani'nin gelişi:** Cenevizli Giovanni Giustiniani Longo 29 Ocak 1453'te iki büyük gemiyle (kaynaklarda
  kadırga ya da gemi) ve yaklaşık **700 askerle** şehre geldi (**R**, **S**). Askerlerinin iyi zırhlı olduğu yazılır
  (**R**). İmparator onu kara surlarının savunmasının başına getirdi ve şehir kurtulursa ona Limni adasını vaat etti (**R**).
  Bölümde onun gelişi rüzgârlı bir kış gününe konur: hava **(kurgu)**.
- **Kış onarımları:** Kış boyunca surlar onarıldı, hendek temizlendi, silah toplandı (**R**). Hendeğin içi bentlerle
  bölmelere ayrılmıştı (Theodosius hendeğinin yapısı). Çamur kovası çıkrığı ve kayan yamaç **(kurgu)**, işin gereğidir.
- **Johannes Grant:** kuşatma boyunca karşı lağımları yöneten mühendis (**R**, **B**); Runciman onun Giustiniani'nin
  birlikleriyle geldiğini yazar. Kuleye ip sarkıtıp ölçü alması **(kurgu)**.
- **Edirne'deki deneme atışı** (34o, **D**): şehre bir tüccarın haber getirmesi **(kurgu)**; Urban'ın daha önce hizmetini
  İmparator'a sunduğu ve ücretinin karşılanamadığı ise kaynaklarda vardır (**D**). Bu bölüm 34o'yla **uzak eşleşmedir**:
  iki taraf ayrı şehirlerde, aynı haftada çalışır.

### 4.2 Yer ve sistemler

- **Aşama 1 (Haliç rıhtımı):** `SeaWalls` (Haliç suru, rıhtım, kapı) + `SeaBattle.war_galley` ×2 (Ceneviz renkleri,
  Giustiniani'nin sancağı). Rıhtımda üç demir **baba**, bir **çatal vinç** (iki direk + makara + çıkrık): 33o'nun
  çıkrığı (`Bogaz` içindeki kurucu) statik bir yardımcıya çıkarılır, `Bogaz.crane(parent, pos)`. Kış: 34o'nun kar/sulu
  sepken parçacığı (`GPUParticles3D`), ıslak taş malzemesi, poyraz (+Z'den).
- **Aşama 2 (Mesoteichion):** `LandWalls` + `SiegeField` (`intact = true`, ordu yok, ova boş, sırtlarda ağaçlar). Dış
  surun bir kulesinin dış yüzü `enable_climb` alanı (tuğla bantları ve taş derzleri tutamak); iki tutamak "çürük".
- **Aşama 3 (hendek):** aynı kesit, hendek boş ve çamurlu (`ditch_filled = false`, dip y −3, su birikintileri). Hendeğin
  karşı yamacında (kontrskarp) bir **kova çıkrığı** (34o'nun çıkrığının küçüğü, iki kollu); kısa tahta merdiven.
- **Yeniden kullanılan:** 38o/24o halat-baba gerilimi (E basılı, kırmızıda bırak), `BalanceMeter` (vinç yükü, kule),
  33o'nun "çürük tutamak" mantığı, zamanlı tuş (düğüm), `RowMeter` (çıkrık kolu), 26o'nun "YUKARIDAN" uyarısı (kayan
  yamaç için), `TespitCam`, `hud.choose`, `Lore.scatter(self, "34b")`.
- **Süre hedefi:** 10–11 dk; durdurulan konuşma ≤ 2 dk.

### 4.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1a. Halat | 29 Ocak, öğle, poyraz | `UI_OBJ34B_LINE`, `UI_OBJ34B_WRAP` | İlk gemi rıhtıma yanaşır. Güverteden **atma halatı** fırlatılır: ucundaki düğüm yay çizer, halka içine girdiğinde **E** (0,6 sn pencere). Iska: halat suya düşer, yeniden atılır (−5 sn, gemi 1 m kayar). Tutunca halatı babaya **sar**: E basılı, gerilim çubuğu kırmızıya girince bırak, yeşilde yeniden tut, **3 sarım** (38o). Gemi her ~5 sn poyrazla geri çeker. İkinci gemide bir **sert rüzgâr**: 1 sn önce sancak çırpınır. | Halat koparsa gemi rıhtıma sürtünür (küreklerden ikisi kırılır), yeniden. Sayaç: kopma. |
| 1b. Vinç | Hemen ardından, **3 dk** | `UI_OBJ34B_CRANE` | Giustiniani'nin askerlerinin **zırh sandıkları**. Çıkrığı iki hamal çevirir; Tolga **kılavuz ipini** tutar (A/D), `BalanceMeter` yükün salınımı. Sulu sepken ve rüzgâr 3–5 sn'de bir iter. Sandık arabanın üstüne gelince ibre yeşilde **E: "İndir!"**. **Dört sandık.** | Kırmızıda indirilen sandık arabanın kenarına çarpar, kapağı açılır, miğferler rıhtıma yuvarlanır (−1, sayaç `chest_spill`). |
| 2. Kule | Şubat başı ("Birkaç gün sonra" kartı) | `UI_OBJ34B_CLIMB`, `UI_OBJ34B_KNOT`, `UI_OBJ34B_PHOTO` | Giustiniani ve Grant Mesoteichion'da. Grant'in ölçü ipi lazım. (a) Dış surun yıkık bir kulesinin dış yüzüne **tırman** (10 m, nefes). İki tutamak çürük: elin altında toz ve çatırtı, 0,5 sn içinde başka tutamağa geç, yoksa 3 m kayarsın (−10 can). (b) Tepede ipi mazgala **bağla** (iki düğüm, zamanlı), ucunu at: ip sur yüzünden hendeğin dibine iner, Grant ölçer. (c) **Tespit:** kule tepesinde Giustiniani, önünde boş ova (pencere 30 sn). | Düşüş: kule dibindeki molozun üstüne −20 can, yeniden. |
| 3. Hendek | Aynı hafta, sulu sepken | `UI_OBJ34B_WINCH`, `UI_OBJ34B_SLIDE` | Halk hendeği temizliyor. Tolga kontrskarptaki **kova çıkrığında**: Niko öbür koldadır, iki kol **aynı vuruşta** döner (`RowMeter`, ortak işaret). Kova yukarı çıkınca **E: dök** (araba). **Altı kova.** Her ~20 sn ıslak yamaç **kayar**: "YAMAÇ!" uyarısı 1,5 sn önce (çatlak çizgisi), çıkrığın yanındaki tahta merdivenden yukarı çık; kalırsan dizine kadar çamura gömülürsün: Space'e art arda bas, 4 sn, −10 can, kova dökülür. | Süre 3 dk; biterse kalanları halk çıkarır. Sayaç: kova /6. |
| 4. Haber | Akşam | `UI_OBJ34B_GATE`, `UI_OBJ34B_CHOICE` | Harisios kapısının küçük kanadından Edirne'den gelen Venedikli tüccar girer: büyük top denenmiş (34o'nun sonucuna göre iki varyant). Giustiniani Tolga'ya sorar: hangi kesimi en çok güçlendirmeli? **Seçim** (Mesoteichion / Blakherna / Haliç). Tarihte Giustiniani Mesoteichion'u seçti (**R**); seçim yalnız 28b'deki bir bark'ı değiştirir (`giust_focus`). Seçimden önce kısa bir iş: kapının ağır çubuğunu Niko'yla yerine indir (E basılı + zamanlama, 1a'nın gerilim çubuğu). | — |

**Animasyon ve görsel geri bildirim**
- **Faz 1a:** atma halatının ucundaki düğüm (maymun yumruğu) havada döner, Tolga'nın eline çarpar, halat elden babaya
  sarkık bir eğri; her sarımda babada bir halka belirir; gerilimde halat düzleşip titrer, sulu sepken üstünde boncuklanır.
  Gemide kürekçiler kürekleri içeri çeker (`SeaBattle.row_oars` durma evresi), Giustiniani'nin zırhlı adamları küpeştede
  sıraya girer. Gemi rıhtıma sürtünürse ahşap kıymık ve "gıcırtı".
- **Faz 1b:** çıkrığı çeviren iki hamal kol döngüsünde; ip tambura sarılır; sandık salınırken kılavuz ipi gerilip
  gevşer; indirilen sandık arabaya oturunca araba yaylanır, at kulağını oynatır.
- **Faz 2:** tuğla bantlarda eller (Traversal), çürük tutamakta önce toz, sonra taş parçası düşer ve hendekte seker;
  tepede ip mazgalın taşına iki tur sarılır (görünür halkalar), atılan ip sur yüzü boyunca açılır, Grant aşağıda ipin
  ucunu tutar, düğümleri sayar (parmak hareketi).
- **Faz 3:** çıkrık kolu iki elle döner, Niko karşı kolda aynı evrede; kova çamurdan "şlap" sesiyle kalkar, çamur
  damlar; döküldüğünde araba dolar (yığın büyür). Yamaç kayarken önce kılcal çatlak, sonra çamur dili yavaşça akar; içinde
  kalan ayaklar gömülür (bacaklar çamur hizasında kesilmez: dize kadar batma animasyonu). Hendekte 10 kişi kürek ve
  sepetle çalışır (`Crowd.civilian` + yakında canlı `Person`, iş döngüsü).
- **Faz 4:** kapının küçük kanadı açılır, tüccar katırla girer (katırın yükü sallanır); çubuk iki kişinin omzunda indirilir.
- **Zemin:** hendek dibindeki işçiler `LandWalls.fill_y` (dip y −3), kontrskarp üstündekiler `outside_y`.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **34B.1** Sandıklar sağlam, hendek temiz | `chest_spill == 0` **ve** kova ≥ 5/6 | `FLOW_34B_1` |
| **34B.2** Rıhtımda miğfer yuvarlandı | aksi hâlde | `FLOW_34B_2` |

`--autotest[=spill|mud]` (varsayılan 34B.1; `=spill`: bot bir sandığı kırmızıda indirir; `=mud`: bot yamaç uyarısında
merdivene gitmez). Akış şeması: `FLOW34B_QUAY` → `FLOW34B_CRANE` → `FLOW34B_TOWER` → `FLOW34B_DITCH` → `FLOW34B_NEWS` →
{`34B.1`, `34B.2`}.

### 4.4 Konuşanlar

Yeni: `SPK_MERCHANT` (Venedikli tüccar, Edirne'den gelen). Var olan: `SPK_GIUST`, `SPK_GRANT`, `SPK_NIKO`, `SPK_GENOESE`
(Giustiniani'nin çavuşu). Koşullu: `D34B_ME_SHOT_OK` yalnız 34o'da (ya da gölgede) top ilk seferde ateş aldıysa, yoksa
`D34B_ME_SHOT_HANG`; seçime göre `D34B_G_MESO` / `_BLAK` / `_HORN`.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D34B_N_01` | SPK_NIHAT | say |
| `D34B_T_01` | SPK_TOLGA | say |
| `D34B_GE_LINE` | SPK_GENOESE | bark |
| `D34B_GE_MISS` | SPK_GENOESE | bark |
| `D34B_T_WRAP` | SPK_TOLGA | bark |
| `D34B_GE_SNAP` | SPK_GENOESE | bark |
| `D34B_G_01` | SPK_GIUST | say |
| `D34B_T_G1` | SPK_TOLGA | say |
| `D34B_G_02` | SPK_GIUST | say |
| `D34B_GE_SPILL` | SPK_GENOESE | bark |
| `D34B_T_CRANE` | SPK_TOLGA | bark |
| `D34B_GR_01` | SPK_GRANT | say |
| `D34B_T_CLIMB` | SPK_TOLGA | bark |
| `D34B_GR_ROPE` | SPK_GRANT | bark |
| `D34B_N_PHOTO` | SPK_NIHAT | bark |
| `D34B_G_FIELD` | SPK_GIUST | bark |
| `D34B_NK_01` | SPK_NIKO | say |
| `D34B_T_NK1` | SPK_TOLGA | say |
| `D34B_NK_BEAT` | SPK_NIKO | bark |
| `D34B_NK_SLIDE` | SPK_NIKO | bark |
| `D34B_T_MUD` | SPK_TOLGA | bark |
| `D34B_ME_01` | SPK_MERCHANT | say |
| `D34B_ME_SHOT_OK` | SPK_MERCHANT | say |
| `D34B_ME_SHOT_HANG` | SPK_MERCHANT | say |
| `D34B_G_ASK` | SPK_GIUST | say |
| `D34B_G_MESO` | SPK_GIUST | say |
| `D34B_G_BLAK` | SPK_GIUST | say |
| `D34B_G_HORN` | SPK_GIUST | say |
| `D34B_N_END` | SPK_NIHAT | say |

### 4.5 Metinler

```csv
UI_CH34B_TITLE,"BÖLÜM {N} — UZUN ADAM","CHAPTER {N} — THE TALL MAN"
UI_CH34B_SUB,"29 Ocak – Şubat 1453 · Haliç rıhtımı ve kara surları · kış","29 January – February 1453 · The Horn quay and the land walls · winter"
UI_FLOW34B_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: UZUN ADAM","FLOWCHART — CHAPTER {N}: THE TALL MAN"
SPK_MERCHANT,"Venedikli tüccar","Venetian merchant"
UI_OBJ34B_LINE,"Atma halatını yakala (halka içindeyken E)","Catch the heaving line (E when it's inside the ring)"
UI_OBJ34B_WRAP,"Halatı babaya sar (E basılı · kırmızıda bırak) · %d/%d","Wrap the line round the bollard (hold E · let go on red) · %d/%d"
UI_OBJ34B_CRANE,"Sandığı arabaya indir (A/D kılavuz ipi · yeşilde E) · %d/%d","Lower the chest onto the cart (A/D guide rope · E on the green) · %d/%d"
UI_OBJ34B_CLIMB,"Kulenin dış yüzüne tırman: çürük taşlara dikkat","Climb the tower's outer face: watch for rotten stones"
UI_OBJ34B_KNOT,"Ölçü ipini mazgala bağla (yeşilde E) · %d/%d","Tie the measuring rope to the merlon (E on the green) · %d/%d"
UI_OBJ34B_PHOTO,"Tespit et: kule tepesinde Giustiniani","Record: Giustiniani on top of the tower"
UI_OBJ34B_WINCH,"Çıkrığı Niko'yla aynı ritimde çevir (yeşilde Space) · kova %d/%d","Turn the windlass in time with Niko (Space on the green) · bucket %d/%d"
UI_OBJ34B_SLIDE,"Yamaç kayıyor! Merdivenden yukarı!","The bank is sliding! Up the ladder!"
UI_OBJ34B_GATE,"Kapının çubuğunu Niko'yla indir (E basılı)","Lower the gate bar with Niko (hold E)"
UI_OBJ34B_CHOICE,"Giustiniani soruyor: en çok nereyi güçlendirmeli?","Giustiniani asks: where should the walls be strengthened most?"
UI_C34B_MESO,"Lykos vadisini: Mesoteichion'u.","The Lycus valley: the Mesoteichion."
UI_C34B_BLAK,"Blakherna'yı: orada tek sur var.","Blachernae: there's only one wall there."
UI_C34B_HORN,"Haliç'i: gemiler oradan gelir.","The Horn: that's where ships come."
FLOW34B_QUAY,"Rıhtımda iki gemi","Two ships at the quay"
FLOW34B_CRANE,"Zırh sandıkları","The armour chests"
FLOW34B_TOWER,"Kuleye ip, Grant'e ölçü","A rope from the tower, a measure for Grant"
FLOW34B_DITCH,"Hendekte çamur","Mud in the moat"
FLOW34B_NEWS,"Edirne'den haber","News from Adrianople"
FLOW_34B_1,"Sandıklar sağlam, hendek temiz","The chests intact, the moat cleared"
FLOW_34B_2,"Rıhtımda miğfer yuvarlandı","Helmets rolled across the quay"
UI_CH34B_STATS,"Sandık: %d/%d   ·   Kova: %d/%d   ·   Kayma: %d   ·   Dosya: %d/%d sayfa","Chests: %d/%d   ·   Buckets: %d/%d   ·   Slides: %d   ·   File: %d/%d pages"
SIEGE_DATE_34B,"29 Ocak 1453","29 January 1453"
SIEGE_EV_34B,"Cenevizli Giovanni Giustiniani Longo iki gemi ve yaklaşık yedi yüz askerle gelir. İmparator onu kara surlarının savunmasının başına getirir.","The Genoese Giovanni Giustiniani Longo arrives with two ships and some seven hundred soldiers. The Emperor puts him in charge of defending the land walls."
SIEGE_NOTE_34B_1,"Rıhtıma iki gemi bağladım, dört sandık indirdim, bir kuleye tırmandım, hendekten altı kova çamur çıkardım. Uzun adam geldi. Edirne'de de bir şey denendi. — T.","I tied up two ships, lowered four chests, climbed a tower, hauled six buckets of mud out of the moat. The tall man has arrived. Something was tested in Adrianople too. — T."
SIEGE_NOTE_34B_2,"Uzun adam geldi. Bir sandık rıhtımda açıldı; miğferleri tek tek topladık, birinde ezik var. Hasar: kozmetik. — T.","The tall man has arrived. One chest burst open on the quay; we picked up the helmets one by one, one is dented. Damage: cosmetic. — T."
LORE_34B_1_T,"Giovanni Giustiniani Longo","Giovanni Giustiniani Longo"
LORE_34B_1,"Ceneviz'in tanınmış bir ailesinden gelen Giustiniani, surları savunmada usta bir askerdi. Kendi parasıyla tuttuğu yaklaşık yedi yüz adamla Ocak 1453'ün sonunda geldi; İmparator ona kara surlarının savunmasını verdi.","From a well-known Genoese family, Giustiniani was a soldier skilled in defending walls. He arrived at the end of January 1453 with some seven hundred men raised at his own expense; the Emperor gave him the defence of the land walls."
LORE_34B_2_T,"Kış onarımları","The winter repairs"
LORE_34B_2,"Kuşatmadan önceki kış surlar onarıldı, hendek temizlendi, silah ve erzak toplandı. Theodosius surlarının önündeki hendek bentlerle bölmelere ayrılmıştı.","In the winter before the siege the walls were repaired, the moat was cleared, arms and supplies were gathered. The moat in front of the Theodosian walls was divided into sections by dams."
LORE_34B_3_T,"Urban'ın ilk teklifi","Urban's first offer"
LORE_34B_3,"Doukas'a göre dökümcü Urban hizmetini önce İmparator'a sundu. İmparator istediği ücreti ve malzemeyi karşılayamadı; Urban Sultan'a gitti.","According to Doukas the founder Urban first offered his services to the Emperor. The Emperor could not meet his fee or provide the materials; Urban went to the Sultan."
```

Replikler:

```csv
D34B_N_01,"Tolga Bey, 29 Ocak 1453. Haliç rıhtımı. Poyraz var, sulu sepken var, iki Ceneviz gemisi var. Gemilerden birinde şehrin en önemli konuğu: Giovanni Giustiniani. Siz halattasınız.","Mr Tolga, 29 January 1453. The Horn quay. There's a north wind, there's sleet, there are two Genoese ships. On one of them is the city's most important guest: Giovanni Giustiniani. You're on the rope."
D34B_T_01,"Halat. Baba. Gemi. Kasko poliçesinde 'park hasarı' diye bir madde var; bu onun büyüğü.","Rope. Bollard. Ship. Motor policies have a clause for 'parking damage'; this is the big version."
D34B_GE_LINE,"Halat! Tut!","Line! Catch!"
D34B_GE_MISS,"Suya düştü! Bir daha!","It's in the water! Again!"
D34B_T_WRAP,"Bir tur, iki tur... Gerilince bırak, gevşeyince tut. Faiz gibi.","One turn, two turns... Let go when it's tight, grab it when it's slack. Like interest rates."
D34B_GE_SNAP,"Koptu! Kürekleri içeri!","It's snapped! Oars in!"
D34B_G_01,"Halatı iyi tuttun. Ben Giustiniani. Bu şehrin surları uzun, benim adamlarım az. Bana surları bilen biri lazım.","You held the line well. I'm Giustiniani. This city's walls are long and my men are few. I need someone who knows the walls."
D34B_T_G1,"Surları bilmem. Ama sur sigortası satmayı denedim; çok uzunlar, prim hesabı tutmuyor.","I don't know the walls. But I tried to sell wall insurance once; they're very long, the premium doesn't add up."
D34B_G_02,"O zaman doğru adamsın: uzun olduğunu biliyorsun. Önce sandıklar. Zırhsız asker surda iki gün yaşar.","Then you're the right man: you know they're long. First the chests. A soldier without armour lasts two days on a wall."
D34B_GE_SPILL,"Miğferler! Hepsini topla, birini bile denize kaptırma!","The helmets! Pick them all up, don't let a single one go in the sea!"
D34B_T_CRANE,"Sağa... sola... Bu sandığın içinde birinin kafası var. Yani kafasının olacağı yer.","Right... left... There's someone's head in this chest. Well, where his head is going to be."
D34B_GR_01,"Johannes Grant. Mühendis. Bu kulenin boyunu bilmem lazım; sonra hendeğin derinliğini, sonra toprağın sesini. Önce boy. Yukarı.","Johannes Grant. Engineer. I need to know this tower's height; then the moat's depth, then the sound of the ground. Height first. Up you go."
D34B_T_CLIMB,"Bin yıllık taş. Tutunduğum her yer bana 'ben senden yaşlıyım' diyor.","Thousand-year-old stone. Every handhold is telling me 'I'm older than you'."
D34B_GR_ROPE,"Aşağı at! ...On iki düğüm ve bir karış. İyi. Şimdi hendek.","Throw it down! ...Twelve knots and a span. Good. Now the moat."
D34B_N_PHOTO,"Kule tepesinde uzun adam, önünde boş ova. Üç ay sonra o ova dolacak. Bir kare, Tolga Bey.","The tall man on the tower, the empty plain before him. In three months that plain will be full. One frame, Mr Tolga."
D34B_G_FIELD,"Buradan gelirler. Vadi aşağı iner, sur alçalır. Ben de burada dururum.","They'll come this way. The valley dips, the wall dips with it. And I'll stand here."
D34B_NK_01,"Casus! Yine sen! Fesin kukuletanın altında, ama kırmızımsı rengi tanırım. Gel, çıkrığın öbür kolu boş.","Spy! You again! Your fez is under that hood, but I know that reddish colour. Come on, the other handle of the windlass is free."
D34B_T_NK1,"Niko. Sen de mi buradasın? Tavuk nerede?","Niko. You're here too? Where's the chicken?"
D34B_NK_BEAT,"Birlikte! Ben inerken sen in! Çıkrık iki kişiliktir, evlilik gibi!","Together! You go down when I go down! A windlass is for two, like a marriage!"
D34B_NK_SLIDE,"Yamaç! Merdivene, casus, merdivene!","The bank! The ladder, spy, the ladder!"
D34B_T_MUD,"Dizime kadar çamur. Bu hasar ayakkabı poliçesine girmez.","Mud up to my knees. This isn't covered by any shoe policy."
D34B_ME_01,"Edirne'den geliyorum, efendiler. Yolda bir şey duydum ki anlatmasam olmaz. Sultan'ın Macar ustası bir top dökmüş...","I've come from Adrianople, sirs. I heard something on the road I can't keep to myself. The Sultan's Hungarian master has cast a gun..."
D34B_ME_SHOT_OK,"Denediler. Ses on mil öteden duyulmuş, diyorlar. Gülle bir mil gitmiş, toprağa bir kulaç gömülmüş.","They tried it. They say the sound was heard ten miles off. The ball went a mile and buried itself a fathom deep."
D34B_ME_SHOT_HANG,"Denediler. Önce ateş almamış, herkes nefesini tutmuş; sonra almış. Ses on mil öteden duyulmuş, diyorlar.","They tried it. At first it wouldn't fire, everyone held their breath; then it did. They say the sound was heard ten miles off."
D34B_G_ASK,"Duydun. Sur uzun, adam az, top büyük. Sence nereyi en çok güçlendirmeliyim?","You heard. The wall is long, the men few, the gun big. Where do you think I should strengthen most?"
D34B_G_MESO,"Benim de aklım orada. Vadi. Ben orada dururum.","That's where my mind is too. The valley. I'll stand there."
D34B_G_BLAK,"Orası da zayıf. Ama top vadiye gelir; topu taşıyan yol düzü sever.","That's weak too. But the gun will come to the valley; the road that carries it likes flat ground."
D34B_G_HORN,"Haliç'in zinciri var. Karanın zinciri yok. Ben karada dururum.","The Horn has its chain. The land has none. I'll stand on the land."
D34B_N_END,"Kaydedildi. 29 Ocak, Bizans nüshası. Giustiniani gerçekten Mesoteichion'u seçti, Tolga Bey; sizin cevabınız ne olursa olsun. O gün Edirne'de tunç da konuştu. İki haber aynı hafta yazıldı.","Recorded. 29 January, the Byzantine copy. Giustiniani really did choose the Mesoteichion, Mr Tolga, whatever your answer was. That week in Adrianople the bronze spoke too. Two pieces of news written in the same week."
```

### 4.6 Co-op bağlantısı (34o ⟷ 34b, **uzak eşleşme**)

İki taraf ayrı şehirlerde. Hayalet yok; bağ **ortak saat, ortak ritim ve haber**dir. Nihat iki nüshanın arasında köprüdür.

| t / faz | Olay | Yön | Etki |
|---|---|---|---|
| 34b faz 1b ⟷ 34o faz 1b | `34.crank_beat` (ortak metronom) | ortak | **İki çıkrık aynı anda:** Osmanlı Edirne'de namluyu iki çıkrıkla kaldırır, Bizans rıhtımda sandık indirir. İki tarafın RowMeter'ı aynı metronomla atar; iki oyuncu aynı vuruşta yeşili tutturursa her iki tarafın yükü o vuruşta %20 az salınır ("Büro ritmi", ekranda iki küçük işaret yan yana yanar). Tek kişilikte metronom yalnız kendi tarafında. |
| 34b faz 1 sonu | `34.giust_arrived` | B→O | 34o'da Urban'ın bir bark'ı: `D34O_U_GIUST` ("Cenova'dan uzun bir adam gelmiş diyorlar. Uzun adam surda durur; benim gülle uzun adam seçmez."). |
| 34o faz 4 | `34.trial(result)` | O→B | Deneme atışının sonucu (ilk seferde / ateş almadı) 34b faz 4'teki tüccarın repliğini seçer (`D34B_ME_SHOT_OK` / `_HANG`). Atış anında Bizans oyuncusuna Nihat: `D_COOP_N_BRIDGE_O` ("Edirne'de şu an…"). |
| 34b faz 3 ⟷ 34o faz 3 | `34.slide`, `34.sled` | ortak | Mizah eşi: Bizans çamurda kayarken Osmanlı buzda kızaklı çocukları kovalar; iki tarafın "kayma" sayıları ortak karnede yan yana yazılır. |

**Ortak düğüm:** `COOP_34_A` "İki çıkrık aynı ritimde" (ortak işaret ≥ 10) / `COOP_34_B` "İki çıkrık ayrı ritimde".

---

## 5. Bölüm 35b — "Silivri Gözcüleri" (Mart 1453, Trakya yolu ve Selymbria)

### 5.1 Tarihî dayanak

- **Konvoy:** Doukas'a göre büyük top Şubat başında Edirne'den yola çıktı; otuz araba, altmış öküz, iki yanında iki yüz
  adam, önden köprü kuran elli dülger ve iki yüz işçi; iki ayda şehre beş mil yaklaştı (**D**). 35o'nun dayanağı aynen.
- **Karaca Bey ve Trakya:** Rumeli Beylerbeyi Karaca Bey Trakya'daki Bizans kalelerini aldı; Mesembria, Anchialos ve
  Vizye düştü, **Selymbria (Silivri) ve Epibatos direndi ve kuşatma boyunca dayandı** (**R**). Edirne'den şehre giden ana yol
  Selymbria'nın yakınından geçer.
- **Gözcüler (kurgu):** Selymbria garnizonundan bir gözcü ekibinin konvoyu izleyip sayması, gece kampa sızması ve sabah
  ip merdivenle surdan içeri alınması oyun kurgusudur. Kimse savaşmaz; gözcüler yakalanmamaya çalışır. Raporun hiçbir şeyi
  değiştirmediğini Nihat söyler: şehir topu zaten biliyordu.
- **Kurt yerine gözcü:** 35o faz 4'te öküzleri ürküten kurt ulumasıdır **(kurgu)**; co-op'ta öküzleri Bizans gözcüsünün
  yakınlığı ürkütebilir (aynı kurgu, başka kaynak).

### 5.2 Yer ve sistemler

- **Harita:** 35o'nun `ThraceRoad` seviyesi (`scripts/level/thrace_road.gd`, OTTOMAN_NEW_A §3.2) **genişletilir**:
  - Sırtın üstünde yıkık bir Bizans **gözcü kulesi** (8 m, taş, tepesi yarım; `enable_climb` alanı, iki çürük tutamak).
  - Derenin 80 m aşağısında **geçit**: dereye devrilmiş bir çınar gövdesi (12 m, 0,5 m genişlik, yürünür, ıslak).
    Derenin kütük doğurucusu ortaktır: 35o'nun köprüsünü geçen kütükler 6 sn sonra geçide varır.
  - Yokuşun doğusunda **bağlar**: 6 sıra asma (sıralar görüş keser, `Nature`), sulama hendeği (C ile içinde yürünür).
  - Konağın batı kenarı: çalılık, korunun kenarı; öküz sırası 35o'dakiyle aynı yerde.
  - Kesme sonrası küçük ek: **Selymbria suru** parçası (24 m, `LandWalls` kurucusunun `inner_only` kipiyle tek sur + iki
    burç; arkada çatılar, önde deniz kıyısı).
- **Atlılar:** Karaca Bey'in akıncıları `Horse` + `Person` (35o'daki Karaca Bey modeli), sabit devriye yolları; bakış
  konisi (25'in nöbetçi konisi, atlıda 20 m / 50°).
- **Yeniden kullanılan:** `Traversal`, `BalanceMeter`, `TespitCam` + **sayım kipi** (küçük ek: kadrajdaki hedef grubunun
  görünen üye sayısını sayar ve karede yazar; ör. "öküz: 24"), 25'in gizlilik konileri, 35o'nun kütük uyarısı ("KÜTÜK!"),
  `Night.campfire/torch`, ip (görünür katener, düğümlü), `Lore.scatter(self, "35b")`.
- **Süre hedefi:** 10–12 dk; durdurulan konuşma ≤ 1,5 dk.

### 5.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Gözcü kulesi | Sabah | `UI_OBJ35B_TOWER`, `UI_OBJ35B_COUNT`, `UI_OBJ35B_HIDE` | Gözcü başı Manolis ile sırtta. (a) Yıkık kuleye **tırman** (8 m, nefes, iki çürük tutamak: 0,5 sn içinde başka tutamağa). (b) Tepede **sayım kareleri**: aşağıda derede köprü kuruluyor (35o faz 1: Osmanlı Tolga'sı kirişin üstünde). Üç ayrı kare: **öküzler**, **arabalar**, **adamlar** (her karede sayım kipi en az %70'ini görmeli; 35o'nun kalabalığı uzakta MultiMesh, yakında canlı). (c) Yolda iki atlı kuleye doğru döner: **60 sn**. Ya kuleden in ve çalılığa geç, ya tepede yüzüstü yat (C basılı) ve atlının konisi geçene dek kıpırdama (konide kalan her saniye "şüphe" çubuğu dolar). | Şüphe dolarsa atlı kuleye seslenir, gözcüler kaçar (faz 2'ye geçilir, `seen +1`). Sayaç: kare /3. |
| 2. Geçit | Öğle | `UI_OBJ35B_TRUNK`, `UI_OBJ35B_LOG` | Gözcüler dereyi devrik çınarın üstünden geçmeli. Gövdede **yürü** (`BalanceMeter`, ıslak kabuk: ibre her adımda kayar). Dereden **kütükler** iner (35o'nun köprüsünü geçenler): 3 sn önce "KÜTÜK!" ve sıçrama; kütük gövdeye çarptığında ibre sert itilir; çarpma anında **C basılı** (eğil, gövdeye sarıl) ibrenin itişini yarıya indirir ama 1 sn ilerleyemezsin. Düşersen akıntı 15 m sürükler; Manolis'in uzattığı ipe E. | Düşüş: −15 can, ipten çekilip baştan. Sayaç: düşüş. |
| 3. Bağlar | İkindi | `UI_OBJ35B_VINES` | Yokuşun dibinde konvoy (35o faz 3: fren ipi). Bir atlı gözcüleri görür ve bağlara sürer. **Kovalamaca:** asma sıralarının arasında koş (sıralar atlının görüşünü keser), atlının konisi sıraya döndüğünde **sulama hendeğine** gir (C), geçince çık. Üç tarama. Yakalanırsan atlı yalnız yoldan uzaklaştırır ("Yoldan çekilin!"), kimse yaralanmaz; ama gece kampa daha uzaktan girilir (faz 4 +40 m). | Sayaç: `seen`. |
| 4a. Konak | Gece | `UI_OBJ35B_CAMP`, `UI_OBJ35B_PHOTO` | Kampa **sız**: ateşlerin ışık halkaları (ışıkta görünürlük ×2), iki nöbetçi meşaleyle dolaşır (konileri), öküz sırası. **Gürültü:** koşarsan 4 m'lik halka; öküzlere 6 m'den yakın koşmak öküzleri huzursuz eder (çan sesi, böğürme). Kızaktaki topa 10 m'ye kadar yaklaş: **tespit**: meşaleler arasında namlunun ağzı (35o'nun karesiyle aynı hedef). Sonra geri çekil. | Görülürsen nöbetçi "Kim var orada?" der, korunun içine kaçarsın (kare çekildiyse kalır). |
| 4b. Silivri suru | Şafak öncesi ("Ertesi sabah, Selymbria" kartı) | `UI_OBJ35B_ROPE` | Selymbria kapısı kapalı. Surdan **düğümlü ip** iner (iki asker mazgala bağlar: sarımlar görünür). **Tırman** 8 m: ip her adımda sallanır (`BalanceMeter` küçük), taş ıslak (nefes ×1,3). Gökyüzü ağarıyor: **90 sn** (gök rengi sayacı). Manolis aşağıda bekler, en son o çıkar. | Süre biterse sur nöbetçileri ipi kendileri çeker (Tolga ipe sarılı; komik değil, ağır). Sayaç: kalan sn. |

**Animasyon ve görsel geri bildirim**
- **Faz 1:** kule taşlarında yosun; çürük tutamakta toz ve düşen taş parçası; tepede yüzüstü yatınca kamera yere iner,
  çimen kadrajın önünde titrer; atlının atı kafasını sallar, akıncı bir an durup bakar. Aşağıda dülgerler köprüde çalışır
  (35o'nun iş döngüleri), öküz çanları uzaktan.
- **Faz 2:** ıslak gövdede ayak kaydıkça kabuk parçası düşer; kütük gövdeye "gümm" çarpar, su sıçrar, Tolga'nın iki
  kolu gövdeye sarılır; düşüşte kahverengi su, Manolis'in ipi kıyıdan suya katener, gerilince düzleşir.
- **Faz 3:** asma yaprakları koşarken sallanır; atın nalları çamuru sıçratır; hendeğe girerken Tolga çömelir, su
  bileklerde; atlının gölgesi hendeğin üstünden geçer.
- **Faz 4a:** ateşlerin ışık halkası yerde turuncu; öküzler yatar, biri başını kaldırır (huzursuzluk), çanı tıngırdar;
  namlunun ağzında meşale ışığı; nöbetçi meşaleyi sağa sola sallar.
- **Faz 4b:** ip mazgala iki tur sarılı (görünür halkalar), düğümler 0,5 m arayla; tırmanırken ip sur yüzüne sürtünür
  (toz); şafak ışığı sur yüzünde yavaşça aşağı iner (sayaç görseli).
- **Zemin:** atlar ve gözcüler `ThraceRoad.ground_y`; hendek içinde y −0,6; bağ sıraları zemine oturur.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **35B.1** Rapor tam | sayım karesi 3/3 **ve** top karesi **ve** `seen ≤ 1` | `FLOW_35B_1` |
| **35B.2** Rapor eksik | aksi hâlde | `FLOW_35B_2` |

`--autotest[=seen|fall]` (varsayılan 35B.1; `=seen`: bot kulede konide kalır ve bağlarda hendeğe girmez; `=fall`: bot
gövdede kütük anında eğilmez, düşer). Akış şeması: `FLOW35B_TOWER` → `FLOW35B_FORD` → `FLOW35B_VINES` → `FLOW35B_CAMP` →
`FLOW35B_WALL` → {`35B.1`, `35B.2`}.

### 5.4 Konuşanlar

Yeni: `SPK_MANOLIS` (Selymbria'lı gözcü başı, kurgu). Var olan / planlı: `SPK_KARACA` (35o), `SPK_SOLDIER` (Osmanlı
nöbetçi), `SPK_DEFENDER` (Selymbria surundaki asker).

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D35B_N_01` | SPK_NIHAT | say |
| `D35B_T_01` | SPK_TOLGA | say |
| `D35B_MA_01` | SPK_MANOLIS | say |
| `D35B_T_02` | SPK_TOLGA | say |
| `D35B_MA_COUNT` | SPK_MANOLIS | bark |
| `D35B_T_COUNT` | SPK_TOLGA | bark |
| `D35B_MA_RIDERS` | SPK_MANOLIS | bark |
| `D35B_KA_01` | SPK_KARACA | bark |
| `D35B_MA_FORD` | SPK_MANOLIS | bark |
| `D35B_MA_LOG` | SPK_MANOLIS | bark |
| `D35B_T_LOG` | SPK_TOLGA | bark |
| `D35B_MA_ROPE` | SPK_MANOLIS | bark |
| `D35B_SO_RIDER` | SPK_SOLDIER | bark |
| `D35B_SO_OFF` | SPK_SOLDIER | bark |
| `D35B_MA_VINES` | SPK_MANOLIS | bark |
| `D35B_T_VINES` | SPK_TOLGA | bark |
| `D35B_MA_CAMP` | SPK_MANOLIS | say |
| `D35B_SO_WHO` | SPK_SOLDIER | bark |
| `D35B_T_GUN` | SPK_TOLGA | bark |
| `D35B_N_PHOTO` | SPK_NIHAT | bark |
| `D35B_DF_01` | SPK_DEFENDER | bark |
| `D35B_T_WALL` | SPK_TOLGA | bark |
| `D35B_MA_END` | SPK_MANOLIS | say |
| `D35B_T_END` | SPK_TOLGA | say |
| `D35B_N_END` | SPK_NIHAT | say |

### 5.5 Metinler

```csv
UI_CH35B_TITLE,"BÖLÜM {N} — SİLİVRİ GÖZCÜLERİ","CHAPTER {N} — THE SCOUTS OF SELYMBRIA"
UI_CH35B_SUB,"Mart 1453 · Trakya yolu ve Selymbria surları","March 1453 · The Thracian road and the walls of Selymbria"
UI_FLOW35B_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: SİLİVRİ GÖZCÜLERİ","FLOWCHART — CHAPTER {N}: THE SCOUTS OF SELYMBRIA"
SPK_MANOLIS,"Gözcü başı Manolis","Manolis, chief scout"
UI_OBJ35B_TOWER,"Yıkık kuleye tırman","Climb the ruined tower"
UI_OBJ35B_COUNT,"Say ve kaydet: öküzler, arabalar, adamlar · %d/%d","Count and record: oxen, carts, men · %d/%d"
UI_OBJ35B_HIDE,"Atlılar! Yüzüstü yat (C basılı) ya da in ve çalılığa geç","Riders! Lie flat (hold C) or climb down into the scrub"
UI_OBJ35B_TRUNK,"Devrik çınardan dereyi geç: dengede kal","Cross the stream on the fallen plane tree: keep your balance"
UI_OBJ35B_LOG,"Kütük! Çarpmadan önce gövdeye sarıl (C basılı)","Log! Hug the trunk before it hits (hold C)"
UI_OBJ35B_VINES,"Asmaların arasından kaç · koni dönünce hendeğe gir (C)","Run through the vines · drop into the ditch when the cone turns (C)"
UI_OBJ35B_CAMP,"Kampa sız: ışıktan ve öküzlerden uzak dur","Slip into the camp: keep out of the light and away from the oxen"
UI_OBJ35B_PHOTO,"Tespit et: meşaleler arasında topun ağzı","Record: the gun's mouth among the torches"
UI_OBJ35B_ROPE,"İpten Selymbria suruna tırman · şafağa %d sn","Climb the rope up the wall of Selymbria · %d s to dawn"
UI_PHOTO35B_COUNT,"Sayım: %s %d","Count: %s %d"
FLOW35B_TOWER,"Kuleden sayım","A count from the tower"
FLOW35B_FORD,"Devrik çınar, inen kütükler","The fallen plane tree, the logs coming down"
FLOW35B_VINES,"Bağlarda atlı","A rider in the vineyard"
FLOW35B_CAMP,"Gece kampı","The night camp"
FLOW35B_WALL,"İpten Selymbria'ya","Up the rope into Selymbria"
FLOW_35B_1,"Rapor tam: sayım, top, kimse görmedi","Full report: the count, the gun, no one saw us"
FLOW_35B_2,"Rapor eksik","An incomplete report"
UI_CH35B_STATS,"Sayım: %d/%d   ·   Görülme: %d   ·   Düşüş: %d   ·   Dosya: %d/%d sayfa","Counts: %d/%d   ·   Spotted: %d   ·   Falls: %d   ·   File: %d/%d pages"
SIEGE_DATE_35B,"Mart 1453","March 1453"
SIEGE_EV_35B,"Büyük top Trakya yolunda. Karaca Bey Bizans'ın Trakya kalelerini alır; Selymbria ve Epibatos direnir ve kuşatma boyunca dayanır.","The great gun is on the Thracian road. Karaca Bey takes Byzantium's Thracian castles; Selymbria and Epibatos resist and hold out through the siege."
SIEGE_NOTE_35B_1,"Gözcülük. Öküzleri, arabaları, adamları saydım; topun ağzını meşale ışığında kaydettim. Kimse beni görmedi; ben onları uzun uzun gördüm. — T.","Scouting. I counted the oxen, the carts, the men; I recorded the gun's mouth by torchlight. No one saw me; I saw them for a long time. — T."
SIEGE_NOTE_35B_2,"Gözcülük. Sayım eksik, iki kez görüldüm. Raporun özeti: büyük, yavaş ve geliyor. — T.","Scouting. The count is incomplete, I was spotted twice. Summary of the report: big, slow, and coming. — T."
LORE_35B_1_T,"Selymbria","Selymbria"
LORE_35B_1,"Marmara kıyısındaki Selymbria (Silivri), Trakya'da Bizans'ın elinde kalan birkaç kaleden biriydi. Karaca Bey'in kuvvetleri karşısında direndi; kuşatma boyunca ve şehir düştükten sonra bir süre daha dayandı.","Selymbria (Silivri) on the Sea of Marmara was one of the few castles in Thrace still held by Byzantium. It resisted Karaca Bey's forces and held out through the siege and for a while after the city fell."
LORE_35B_2_T,"Topun yolu","The gun's road"
LORE_35B_2,"Doukas'a göre büyük top otuz araba ve altmış öküzle, iki yanında iki yüz adamla iki ayda yol aldı. Önden giden dülgerler dereler üstüne köprü kurdu.","According to Doukas the great gun travelled for two months on thirty carts drawn by sixty oxen, with two hundred men walking beside it. Carpenters went ahead building bridges over the streams."
LORE_35B_3_T,"Haber ve ses","News and noise"
LORE_35B_3,"Bir kuşatmada haber silah kadar değerliydi; ama bu topun gelişi kimseden saklanmadı. Sultan onu bilerek gösterdi. Gürültüsü gibi şöhreti de önünden gidiyordu.","In a siege news was as valuable as weapons; but this gun's coming was hidden from no one. The Sultan showed it on purpose. Its fame went ahead of it, like its noise."
```

Replikler:

```csv
D35B_N_01,"Tolga Bey, Mart 1453. Trakya. Selymbria hâlâ Bizans'ın; çevresindeki kalelerin çoğu düştü. Bu sabah sizi garnizonun gözcüleriyle yola veriyorum. Görevin adı: saymak.","Mr Tolga, March 1453. Thrace. Selymbria is still Byzantine; most of the castles around it have fallen. This morning I'm sending you out with the garrison's scouts. The job is called: counting."
D35B_T_01,"Saymak. Nihayet bildiğim bir iş. Hasar tespiti de bir çeşit saymaktır.","Counting. At last, a job I know. Damage assessment is a kind of counting too."
D35B_MA_01,"Ben Manolis. Kuleden bakacağız, sayacağız, kimseye görünmeyeceğiz. Kılıç yok. Kılıç çeken gözcü, gözcü değil, cesettir.","I'm Manolis. We look from the tower, we count, we're seen by nobody. No swords. A scout who draws a sword isn't a scout, he's a corpse."
D35B_T_02,"Benim de kılıcım yok. Kalemim var. Bir de mazeretim.","I haven't got a sword either. I've got a pen. And an excuse."
D35B_MA_COUNT,"Say. Öküz, araba, adam. Ben unuturum, sen yazarsın.","Count. Oxen, carts, men. I forget, you write."
D35B_T_COUNT,"Yirmi dört öküz... yirmi altı... durmuyorlar ki sayayım.","Twenty-four oxen... twenty-six... they won't stand still for me to count."
D35B_MA_RIDERS,"Atlılar! Yat. Taş ol. Taş nefes almaz.","Riders! Down. Be a stone. Stones don't breathe."
D35B_KA_01,"(Uzaktan, atın üstünden) Köprüyü öğlene bitirin! Yol beklemez, Sultan hiç beklemez!","(Far off, from the saddle) Finish the bridge by noon! The road won't wait, the Sultan never waits!"
D35B_MA_FORD,"Köprü onların. Bize çınar kaldı. Ayağını gövdenin ortasına bas.","The bridge is theirs. We get the plane tree. Put your feet in the middle of the trunk."
D35B_MA_LOG,"Kütük! Sarıl!","Log! Hold on!"
D35B_T_LOG,"Bu kütük az önce onların köprüsünden kaçtı. Şimdi bana geliyor. Kişisel bir şey olmadığını umuyorum.","That log just escaped from their bridge. Now it's coming for me. I hope it's nothing personal."
D35B_MA_ROPE,"Tut ipi! Çek, çek! Dere de bizim değil artık.","Grab the rope! Pull, pull! Even the stream isn't ours any more."
D35B_SO_RIDER,"Hey! Bağdakiler! Kim var orada?","Hey! You in the vineyard! Who's there?"
D35B_SO_OFF,"Yoldan çekilin! Bu yol bugün Sultan'ın! Köyünüze dönün!","Get off the road! Today this road is the Sultan's! Back to your village!"
D35B_MA_VINES,"Sıranın arkasına! At sırayı göremez, sen atı görürsün.","Behind the row! The horse can't see through the row, but you can see the horse."
D35B_T_VINES,"Hendekteyim. Bileğime kadar su. Bu bağın sahibine teşekkür notu bırakacağım.","I'm in the ditch. Water up to my ankles. I'll leave a thank-you note for whoever owns this vineyard."
D35B_MA_CAMP,"Gece. Ateşlerin halkasına girme. Öküzlere yaklaşma; öküz korkarsa bütün kamp uyanır. Topu gör, sonra geri.","Night. Don't step into the firelight. Don't go near the oxen; if an ox gets scared, the whole camp wakes up. See the gun, then back."
D35B_SO_WHO,"Kim var orada? ...Kurt mu? Kurtsa kurt, insansa ses ver!","Who's there? ...A wolf? If you're a wolf, fine; if you're a man, speak!"
D35B_T_GUN,"İşte. Meşalelerin arasında yatıyor. Uyuyan bir şey gibi; uyandığı gün surlar duyacak.","There it is. Lying between the torches. Like something asleep; the day it wakes, the walls will hear."
D35B_N_PHOTO,"Namlunun ağzı, Tolga Bey. Osmanlı nüshasında bu karenin aynısı var; o kareyi topun yanında yürüyen biri çekiyor.","The mouth of the barrel, Mr Tolga. The Ottoman copy has the same frame; it's taken by someone walking beside the gun."
D35B_DF_01,"(Surdan, fısıltı) Manolis! İp aşağıda! Çabuk, gün doğuyor!","(From the wall, whispering) Manolis! The rope's down! Quick, the sun's coming up!"
D35B_T_WALL,"Düğüm, düğüm, düğüm... Şehre kapıdan değil ipten giriyorum. Bu da bir çeşit giriş, sanırım.","Knot, knot, knot... I'm entering the town by rope, not by the gate. I suppose that's a kind of entrance."
D35B_MA_END,"İçerdeyiz. Raporu İmparator'a bir gemiyle göndeririz. Ne yazacaksın?","We're in. We'll send the report to the Emperor by ship. What will you write?"
D35B_T_END,"Büyük. Yavaş. Geliyor. Rakamları da altına.","Big. Slow. Coming. The figures underneath."
D35B_N_END,"Kaydedildi. Mart 1453, Bizans nüshası. Raporunuz bir şey değiştirmedi, Tolga Bey; şehir topu zaten biliyordu. Ama Selymbria dayandı. Kuşatma boyunca, ve sonrasında bir süre daha.","Recorded. March 1453, the Byzantine copy. Your report changed nothing, Mr Tolga; the city already knew about the gun. But Selymbria held. Through the siege, and for a while after."
```

### 5.6 Co-op bağlantısı (35o ⟷ 35b, aynı harita `ThraceRoad`)

| t / faz | Olay | Yön | Etki |
|---|---|---|---|
| 35b faz 1 ⟷ 35o faz 1 | hayalet | ortak | Bizans kuleden Osmanlı'yı kirişin üstünde görür (hayalet, 140 m); Osmanlı sırtta kuleyi ve tepesindeki karaltıyı görür (kule tepesinde yatan hayalet yalnız ayakta iken görünür). |
| 35b faz 2 ⟷ 35o faz 1 | `35.log(id, hit)` | O→B | **Ortak dere:** 35o'da Osmanlı'nın kaçırdığı **ya da sırıkla itip yolladığı** her kütük 6 sn sonra 35b'nin geçidine varır. Osmanlı ne kadar iyi iterse Bizans'a o kadar çok kütük gelir: Osmanlı'nın başarısı Bizans'ın zorluğudur. Ortak sayaç ekranın üstünde ("dere: 7 kütük"). |
| 35b faz 3 ⟷ 35o faz 3 | `35.runaway`, `35.brake_ok` | O→B | Osmanlı fren ipinde arabayı kaçırırsa (yan hendeğe kayma) yol adamlarla dolar, atlının devriyesi bağlara kayar: 35b'de tarama sayısı 3 → 4. |
| 35b faz 4a ⟷ 35o faz 4 | `35.oxen_spook(id)` | B→O | **Kurt yerine gözcü:** Bizans öküzlere 6 m'den yakın koşarsa o öküz ipini koparır ve 35o'daki kovalamaca başlar (35o'nun kurt uluması co-op'ta çalınmaz; Urban'ın bark'ı `D35O_U_WOLF_ALT`: "Kurt değil bu, kurt ateşe yaklaşmaz… Neyse, yakala!"). Bizans hiç ürkütmezse 35o'da tek öküz (Durmuş'unki) kaçar. |
| 35b faz 4a ⟷ 35o faz 4 sonu | `35.photo` | ortak | Aynı hedef (namlunun ağzı), iki açıdan: ±3 sn → **çift kayıt**. Bizans kampa 10 m'ye kadar yaklaştığı için **göz göze** anı burada kurulur: Osmanlı topun yanında, Bizans çalılıkta, 4 m; ikisi de susar (yalnız `D_COOP_T_MEET_2` fısıltıyla). |

**Ortak düğüm:** `COOP_35_A` "Öküzler gözcüden ürktü" / `COOP_35_B` "Öküzler kurttan ürktü" (Bizans gizli kaldı).

---

## 6. Bölüm 28b — "Yün Balyaları" (6 ve 11–12 Nisan 1453)

### 6.1 Tarihî dayanak

- **Kapılar ve köprüler:** 2 Nisan'da kapılar kapatıldı, Haliç'e zincir gerildi (SIEGE §1). Osmanlı ordusu yaklaşınca
  hendeğin üstündeki köprüler yıkıldı (**R**). Hangi kapının köprüsünün kimce yıkıldığı ayrıntısı **(kurgu)**.
- **6 Nisan:** Ordu surların önünde. İmparator ve Giustiniani en zayıf kesimde, Aziz Romanos kapısının çevresinde
  (Mesoteichion) durdu (**R**).
- **Bombardıman:** Kara surlarının topla dövülmesi oyunda 11–12 Nisan'da başlar (28o ile aynı tarih; **R** ilk günlerde
  küçük topların, sonra büyük topun ateşe başladığını yazar).
- **Balya ve deri perdeler:** Savunucular güllelerin etkisini azaltmak için surlardan yün balyaları ve deri perdeler
  sarkıttı; etkisi azdı (**R**; kuşatma anlatılarında geçer). Tolga'nın ip sandalyesinde sur yüzüne inmesi **(kurgu)**.
- **Savunanların topları:** Savunucuların topları azdı ve geri tepmeleri kendi surlarını sarsıyordu (**R**; 18b'nin
  dayanağı). Bu bölümde küçük top yalnız siper ve kazık hattına atılır.
- **İlk barikat:** Gündüz dövülen yerler geceleri kalas, fıçı ve toprakla kapatıldı; bu iş ilk günden başladı (**R**, **B**).
- 28o'daki Osmanlı nüshası 6 Nisan'da kazık çakar, 11 Nisan'da Şahi'yi bataryaya çeker, ilk gülleyi atar. Bu bölüm aynı
  günlerin surdan görünüşüdür.

### 6.2 Yer ve sistemler

- **Harita:** `LandWalls` + `SiegeField` (28o ile aynı Lykos kesiti), `intact = true` (faz 1–3), gece fazında
  `set_repair(1)` (ilk yarık). Kapının önünde hendeğin üstünde **ahşap köprü** (yeni küçük kurucu: iki ana kiriş, 10
  kalas, iki dikme; her kalas ayrı düğüm, iplerle bağlı; çökebilir). Dış surun bir kulesinde **küçük top** (18b'nin
  kurulumu, barut seçimi), surun yürüyüş yolunda iki **makara kolu** (balya ve ip sandalyesi için; 33o'nun çıkrığından
  küçük), iç surun dibinde ilk barikat için **çatal vinç** (`Bogaz.crane`).
- **Kalabalık:** `Garrison.land_walls` (oyuncunun alanı `skip`), ovada 28o'nun Osmanlı siperi ve kazık işçileri (gölgede
  NPC, co-op'ta Osmanlı Tolga'sı da aralarında).
- **Yeniden kullanılan:** zamanlı tuş (32o basamak → kalas pimi), `RowMeter` (ekipçe çekiş), `Traversal` (hendek
  kontrskarpı), 18b'nin `GunDrill` + barut seçimi, `BalanceMeter` (ip sandalyesi salınımı, vinç yükü), 22o'nun "Siper!"
  kuralı (ok yaylımı), 20'nin "Top!" gözcü uyarısı, `TespitCam`, `Lore.scatter(self, "28b")`.
- **Süre hedefi:** 11 dk; durdurulan konuşma ≤ 2 dk.

### 6.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Köprü | 6 Nisan, sabah | `UI_OBJ28B_PINS`, `UI_OBJ28B_HAUL`, `UI_OBJ28B_PROP` | Osmanlı öncüleri ovada; kapının köprüsü yıkılmalı. **3 dk** (öncülerin sancağı ovada ilerler: görünen sayaç). (a) Kalasların **pimlerini sök**: işaret yeşilken E (6 pim; ıska = pim sıkışır, 2 sn). (b) Sökülen kalası **ekipçe çek**: ip kalasa bağlıdır, RowMeter "hep birlikte" 2 iyi vuruş, kalas kapının içine kayar (4 kalas). (c) Son iş: hendeğin dibine **in** (kontrskarptan serbest tırmanma, 3 m), dikmeyi tokmakla **vur** (E basılı 2 sn) ve köprü çökmeden **3 sn** içinde merdivene koş. Ovadan ok yaylımı: "Ok!" sonrası 2 sn içinde kalkanın ya da kapı kemerinin altına (22o kuralı, −25 can). | Süre biterse Niko ve iki asker son kalasları baltalar (sayaç). Köprü çökerken altında kalırsan −30 can, Niko çeker. |
| 2. Küçük top | 6 Nisan, öğleden sonra | `UI_OBJ28B_POWDER`, `UI_OBJ28B_AIM` | Kuledeki küçük top. Hedef: siperin önüne çakılan **kazık hattı** (insanlar değil; 28o faz 1). Üç atış: her atıştan önce **barut seçimi** (18b: az = sur güvende, menzil kısa; çok = menzil tam, kule çatlar), sonra GunDrill. İsabet: iki üç kazık devrilir, Osmanlı işçileri siperin ardına sıçrar. | `stakes_down` sayılır; `crack` (çok barut) sur kulesinde çatlak bırakır (faz 4'te bir aşama daha fazla onarım). |
| 3a. Balyalar | 11 Nisan | `UI_OBJ28B_BALE`, `UI_OBJ28B_CHAIR` | Şahi'nin bataryaya çekildiği görülüyor (ovada "hey-yap" sesi; 28o faz 2). Giustiniani: topun bakacağı kulenin önüne balya. (a) Yürüyüş yolundaki makara koluyla **balyayı indir** (A/D kılavuz ipi, `BalanceMeter`). (b) Balya sur yüzünün ortasına inince Tolga **ip sandalyesinde** iner (E basılı = sal, bırak = dur); sandalye sur yüzünde sallanır (`BalanceMeter`). Balyanın iki kulpunu sur yüzündeki demir **kancalara bağla** (zamanlı düğüm, iki düğüm). **Dört balya.** Ovadan oklar sandalyeye: "Ok!" uyarısında A/D ile **balyanın arkasına salın** (balya siperdir). | Süre: Şahi bataryaya oturana dek (≈ 3 dk; co-op'ta Osmanlı'nın çekişi belirler). Sayaç: balya /4, ok. |
| 3b. İlk gülle | 12 Nisan | `UI_OBJ28B_COVER`, `UI_OBJ28B_PHOTO` | Gözcü: "Duman!" Bataryanın ağzında duman görünce **2 sn** içinde mazgalın arkasına çömel (C) ya da kulenin içine gir. Gülle gelir: balyalı yere düşerse balya patlar, yün havaya saçılır, taş az çatlar; balyasız yere düşerse taş yarılır. **Tespit:** surdan ilk toz (28o'nun ilk toz karesinin aynası; pencere 15 sn). | Çömelmezsen yere düşersin (−30 can). Kare kaçarsa not. |
| 4. İlk gece | 12 Nisan gecesi | `UI_OBJ28B_CRANE`, `UI_OBJ28B_STAKE` | Dövülen kesimin ardına ilk barikat. Çatal vinçle **toprak dolu fıçıyı kaldır ve yerine indir** (`BalanceMeter`, yeşilde E), sonra önüne iki **kazık çak** (zamanlı E, üç vuruş). **Dört fıçı**, 2,5 dk. Uzak bataryalardan gece atışları: gözcü "Top!" der, 2 sn içinde fıçının arkasına (gölge NPC topçular; co-op'ta Osmanlı 28o'yu bitirmiştir, atışlar senaryodan). | Süre biterse Giustiniani'nin adamları bitirir. Sayaç: fıçı /4. |

**Animasyon ve görsel geri bildirim**
- **Faz 1:** pim çıktığında kalas 2 cm oynar, toz; çekiş ipi kalasın ucundan kapıya katener, gerilince düzleşir; dört asker
  her "hep birlikte"de geriye yaslanır, ayakları taşta kayar; kalas kapı eşiğinden içeri sürtünerek kayar. Dikme vurulunca
  köprünün ortası 10 cm çöker, gıcırdar, sonra kiriş ikiye ayrılır ve hendeğe düşer (kıymık, toz bulutu).
- **Faz 2:** 18b'nin top animasyonu (doldurma adımları, geri tepme, kule taşında toz); kazık isabetinde 2–3 kazık
  yana yatar, siperin ardındaki işçiler eğilir; çok barutta kulenin taşında kılcal çatlak belirir ve kalır.
- **Faz 3a:** makara dönerken ip sarılır; balya sur yüzüne sürtünür; ip sandalyesi (tahta oturak, iki ip) Tolga'nın
  altında yalpalar; düğümde ellerin hareketi (iki tur + ilmek); saplanan oklar balyada kalır (yün kabarır). Ovada Şahi
  kızağın üstünde ilerler, kütükler arkadan öne taşınır (28o'nun döngüsü).
- **Faz 3b:** bataryada beyaz duman, ses 1,2 sn sonra; gülle yay çizer; balya isabetinde **yün bulutu** (beyaz parçacık,
  yavaşça yere iner) ve taşta küçük çentik; balyasız isabette taş parçaları ve büyük toz. Tolga'nın bark'ı ciddidir.
- **Faz 4:** vinç kolunda fıçı sallanır; yerine oturunca toprak kenarından taşar; kazık çakarken tokmak iner, kazık her
  vuruşta 10 cm batar; meşaleler `Night.torch`, ilk barikatın siluetinde 6 kişi çalışır (`WallFight.add_builders`).
- **Zemin:** köprü molozu hendek dibinde (y −3), Osmanlı işçileri `SiegeField.ground`, sur yolundakiler `WALK_Y`.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **28B.1** Köprü zamanında yıkıldı, dört balya asıldı | köprü süre içinde **ve** balya 4/4 | `FLOW_28B_1` |
| **28B.2** Köprüyü Niko baltaladı ya da balyalar eksik | aksi hâlde | `FLOW_28B_2` |

`--autotest[=late|crack]` (varsayılan 28B.1; `=late`: bot pimleri ıskalar, köprüyü Niko yıkar; `=crack`: bot her atışta
çok barut seçer, gece 5 fıçı gerekir). Akış şeması: `FLOW28B_BRIDGE` → `FLOW28B_GUN` → `FLOW28B_BALES` →
`FLOW28B_FIRST` → `FLOW28B_NIGHT` → {`28B.1`, `28B.2`}. `Grade.finish("28b")` (oklar, düşme).

### 6.4 Konuşanlar

Var olan: `SPK_GIUST`, `SPK_NIKO`, `SPK_LOOKOUT` (gözcü), `SPK_DEFENDER`, `SPK_EMPEROR` (tek bark). Koşullu:
`D28B_G_FOCUS_*` 34b'deki seçime göre (`giust_focus`; 34b oynanmadıysa `_MESO`).

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D28B_N_01` | SPK_NIHAT | say |
| `D28B_T_01` | SPK_TOLGA | say |
| `D28B_NK_01` | SPK_NIKO | say |
| `D28B_T_NK1` | SPK_TOLGA | say |
| `D28B_NK_PIN` | SPK_NIKO | bark |
| `D28B_NK_HAUL` | SPK_NIKO | bark |
| `D28B_LK_ARROW` | SPK_LOOKOUT | bark |
| `D28B_T_PROP` | SPK_TOLGA | bark |
| `D28B_NK_RUN` | SPK_NIKO | bark |
| `D28B_NK_AXE` | SPK_NIKO | bark |
| `D28B_DF_GUN` | SPK_DEFENDER | bark |
| `D28B_DF_CRACK` | SPK_DEFENDER | bark |
| `D28B_T_STAKES` | SPK_TOLGA | bark |
| `D28B_G_01` | SPK_GIUST | say |
| `D28B_G_FOCUS_MESO` | SPK_GIUST | say |
| `D28B_G_FOCUS_OTHER` | SPK_GIUST | say |
| `D28B_T_G1` | SPK_TOLGA | say |
| `D28B_G_02` | SPK_GIUST | bark |
| `D28B_T_CHAIR` | SPK_TOLGA | bark |
| `D28B_LK_SMOKE` | SPK_LOOKOUT | bark |
| `D28B_T_FIRST` | SPK_TOLGA | bark |
| `D28B_N_PHOTO` | SPK_NIHAT | bark |
| `D28B_EM_01` | SPK_EMPEROR | bark |
| `D28B_G_NIGHT` | SPK_GIUST | bark |
| `D28B_LK_TOP` | SPK_LOOKOUT | bark |
| `D28B_NK_END` | SPK_NIKO | say |
| `D28B_T_END` | SPK_TOLGA | say |
| `D28B_N_END` | SPK_NIHAT | say |

### 6.5 Metinler

```csv
UI_CH28B_TITLE,"BÖLÜM {N} — YÜN BALYALARI","CHAPTER {N} — BALES OF WOOL"
UI_CH28B_SUB,"6 ve 11–12 Nisan 1453 · Aziz Romanos kapısı, dış sur","6 and 11–12 April 1453 · The Gate of St Romanus, the outer wall"
UI_FLOW28B_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: YÜN BALYALARI","FLOWCHART — CHAPTER {N}: BALES OF WOOL"
UI_OBJ28B_PINS,"Köprünün kalas pimlerini sök (yeşilde E) · %d/%d","Knock out the bridge's plank pins (E on the green) · %d/%d"
UI_OBJ28B_HAUL,"Kalası ekipçe içeri çek (yeşilde Space) · %d/%d","Haul the plank in with your squad (Space on the green) · %d/%d"
UI_OBJ28B_PROP,"Hendeğe in, dikmeyi vur (E basılı), sonra koş!","Down into the moat, knock out the prop (hold E), then run!"
UI_OBJ28B_POWDER,"Barut miktarını seç","Choose the powder charge"
UI_OBJ28B_AIM,"Kazık hattına nişan al (atış %d/%d)","Aim at the line of stakes (shot %d/%d)"
UI_OBJ28B_BALE,"Balyayı sur yüzüne indir (A/D kılavuz · yeşilde E) · %d/%d","Lower the bale down the wall face (A/D guide · E on the green) · %d/%d"
UI_OBJ28B_CHAIR,"İp sandalyesinde in, balyayı kancalara bağla · Ok: balyanın arkasına salın","Go down in the rope chair, tie the bale to the hooks · Arrows: swing behind the bale"
UI_OBJ28B_COVER,"Duman! Mazgalın arkasına çömel (C)","Smoke! Crouch behind the merlon (C)"
UI_OBJ28B_PHOTO,"Tespit et: surdan ilk toz","Record: the first dust from the wall"
UI_OBJ28B_CRANE,"Toprak fıçısını vinçle yerine indir (yeşilde E) · %d/%d","Lower the earth barrel into place with the crane (E on the green) · %d/%d"
UI_OBJ28B_STAKE,"Fıçının önüne kazık çak (yeşilde E)","Drive a stake in front of the barrel (E on the green)"
UI_C28B_LOW,"Az barut: sur güvende, menzil kısa","Light charge: the wall is safe, the range short"
UI_C28B_HIGH,"Çok barut: menzil tam, kule çatlayabilir","Heavy charge: full range, the tower may crack"
FLOW28B_BRIDGE,"Kapının köprüsü yıkıldı","The gate's bridge torn down"
FLOW28B_GUN,"Kuleden kazık hattına","From the tower at the line of stakes"
FLOW28B_BALES,"Sur yüzüne yün balyaları","Bales of wool down the wall face"
FLOW28B_FIRST,"İlk gülle","The first ball"
FLOW28B_NIGHT,"İlk gece, ilk barikat","The first night, the first stockade"
FLOW_28B_1,"Köprü zamanında yıkıldı, balyalar asıldı","The bridge down in time, the bales hung"
FLOW_28B_2,"Köprüyü Niko baltaladı","Niko took his axe to the bridge"
UI_CH28B_STATS,"Pim: %d/%d   ·   Balya: %d/%d   ·   Kazık: %d   ·   Fıçı: %d/%d   ·   Dosya: %d/%d sayfa","Pins: %d/%d   ·   Bales: %d/%d   ·   Stakes: %d   ·   Barrels: %d/%d   ·   File: %d/%d pages"
SIEGE_NOTE_28B_1,"Kapının köprüsünü söktüm, sur yüzüne dört balya astım. İlk gülle balyaya geldi: yün uçtu, taş az çatladı. Gece ilk barikatı ördük. Hasar: başladı. — T.","I dismantled the gate's bridge and hung four bales down the wall. The first ball hit a bale: wool flew, the stone cracked a little. At night we built the first stockade. Damage: it has begun. — T."
SIEGE_NOTE_28B_2,"Köprüyü Niko baltayla bitirdi. Balyalar eksik kaldı; ilk gülle çıplak taşa geldi. Gece ilk barikatı ördük. — T.","Niko finished the bridge with an axe. The bales were too few; the first ball hit bare stone. At night we built the first stockade. — T."
LORE_28B_1_T,"Köprüler","The bridges"
LORE_28B_1,"Kara surlarının önündeki hendeğin üstünde kapılara giden köprüler vardı. Osmanlı ordusu yaklaşınca savunucular köprüleri yıktı; kapılar kapandı ve şehirle ova arasında yalnız hendek ve iki sur kaldı.","Bridges crossed the moat to the gates of the land walls. As the Ottoman army approached the defenders destroyed them; the gates were shut, and between the city and the plain there remained only the moat and the two walls."
LORE_28B_2_T,"Yün ve deri","Wool and leather"
LORE_28B_2,"Savunucular güllelerin darbesini yumuşatmak için surlardan yün balyaları ve deri perdeler sarkıttı. Büyük toplara karşı etkisi azdı; ama başka çare yoktu.","To soften the blows of the cannonballs the defenders hung bales of wool and leather screens from the walls. Against the great guns they did little; but there was no other remedy."
LORE_28B_3_T,"Kendi topları","Their own guns"
LORE_28B_3,"Şehrin de topları vardı ama azdı ve küçüktü. Büyüklerini ateşlemek kendi surlarını sarsıyordu; savunucular toplarını dikkatle, çoğu zaman az barutla kullandı.","The city had guns too, but they were few and small. Firing the larger ones shook their own walls; the defenders used their guns carefully, often with light charges."
```

Replikler:

```csv
D28B_N_01,"Tolga Bey, 6 Nisan 1453. Kapılar dört gündür kapalı, Haliç'te zincir gergin. Bu sabah ordu ovada. Kapının önündeki köprü hâlâ ayakta. Yazık ki köprüler iki yöne de çalışır.","Mr Tolga, 6 April 1453. The gates have been shut for four days, the chain across the Horn is taut. This morning the army is on the plain. The bridge in front of the gate is still standing. Unfortunately bridges work in both directions."
D28B_T_01,"Bir köprüyü sökeceğim. Kariyerimde ilk kez bir şeyi bilerek hasara uğratıyorum. Lütfen kayıtlara 'önleyici' diye geçin.","I'm going to take a bridge apart. The first time in my career I've caused damage on purpose. Please record it as 'preventive'."
D28B_NK_01,"Casus! Sen ne arıyorsun kara surunda? Ben deniz suru adamıyım, beni de buraya yolladılar. Tavuğu kuzenime bıraktım. Kuzenim tavuğu yer mi, onu düşünüyorum.","Spy! What are you doing on the land walls? I'm a sea-wall man myself, they sent me up here too. I left the chicken with my cousin. I keep wondering whether my cousin will eat the chicken."
D28B_T_NK1,"Kuzenin tavuğu yemez, Niko. Kimse Sinerji'yi yiyemez.","Your cousin won't eat the chicken, Niko. Nobody could eat Synergy."
D28B_NK_PIN,"Pimi çıkar, kalası biz çekeriz!","Get the pin out, we'll pull the plank!"
D28B_NK_HAUL,"Hep birlikte! Hep birlikte, casus!","All together! All together, spy!"
D28B_LK_ARROW,"Ok! Kemerin altına!","Arrows! Under the arch!"
D28B_T_PROP,"Bu dikmeyi vurduğumda köprü düşecek. Ben de köprünün altındayım. Bu planın küçük bir eksiği var.","When I knock out this prop the bridge falls. And I'm under the bridge. There's a small flaw in this plan."
D28B_NK_RUN,"Koş! Merdivene! Köprü sana yer açmaz!","Run! The ladder! The bridge won't make room for you!"
D28B_NK_AXE,"Bırak, bırak! Baltanın sırası geldi!","Leave it, leave it! The axe's turn now!"
D28B_DF_GUN,"Az barut, kâtip! Nişan siperin önündeki kazıklara. Kazık devrilirse yarın yeniden çakarlar; biz de bir gün kazanırız.","Light charge, clerk! Aim at the stakes in front of their trench. If a stake falls they plant it again tomorrow; and we win a day."
D28B_DF_CRACK,"Duydun mu? Kule inledi. Bizim top kendi evimizi dövüyor.","Did you hear that? The tower groaned. Our own gun is pounding our own house."
D28B_T_STAKES,"Üç kazık devrildi. Yarın yenisini çakacaklar. Benim işim bunun hep böyle gideceğini kayda geçmek galiba.","Three stakes down. Tomorrow they'll plant new ones. I suppose my job is to record that it will go on like this."
D28B_G_01,"Tolga. Ovaya bak: o kızağın üstündeki şey. Yarın, öbür gün, bu kuleye bakacak. Kulenin önüne yün asacağız.","Tolga. Look at the plain: that thing on the sled. Tomorrow, the day after, it will be looking at this tower. We're going to hang wool in front of the tower."
D28B_G_FOCUS_MESO,"Bana vadiyi söylemiştin. Haklıydın; işte vadi, işte top.","You told me the valley. You were right; here's the valley, here's the gun."
D28B_G_FOCUS_OTHER,"Bana başka yeri söylemiştin. Top seni dinlemedi; vadiye geldi.","You told me somewhere else. The gun didn't listen to you; it came to the valley."
D28B_T_G1,"Yün. Bir topa karşı. Bu, dolu fırtınasına şemsiyeyle çıkmak gibi.","Wool. Against a gun. That's like going out into a hailstorm with an umbrella."
D28B_G_02,"Şemsiye de bir şeydir. Aşağı. Kancalar sur yüzünde, ipler sende.","An umbrella is still something. Down you go. The hooks are on the wall, the ropes are yours."
D28B_T_CHAIR,"İp sandalyesi. Altımda hendek, üstümde Niko. İkisine de güvenmiyorum.","A rope chair. The moat below me, Niko above me. I trust neither."
D28B_LK_SMOKE,"Duman! Bataryada duman! Eğil!","Smoke! Smoke at the battery! Get down!"
D28B_T_FIRST,"...İlk gülle. Yün uçuşuyor. Kimse gülmüyor. Ben de gülmüyorum.","...The first ball. Wool flying everywhere. Nobody's laughing. Neither am I."
D28B_N_PHOTO,"Surdan ilk toz, Tolga Bey. Osmanlı nüshasında bu tozun öbür yüzü var: ovadan bakan biri aynı anı kaydediyor.","The first dust from the wall, Mr Tolga. The Ottoman copy has the other side of this dust: someone on the plain is recording the same moment."
D28B_EM_01,"(Sur yolunda geçerken) Gece dövülen yer sabah ayakta olacak. Her gece.","(Passing along the wall walk) What is battered by day will stand again by morning. Every night."
D28B_G_NIGHT,"Fıçı, toprak, kazık. Bundan sonra her gece bu. Öğren, iyi öğren.","Barrel, earth, stake. From now on, every night. Learn it, learn it well."
D28B_LK_TOP,"Top! Fıçının arkasına!","Gun! Behind the barrel!"
D28B_NK_END,"İlk gece bitti, casus. Kaç gece var daha?","The first night's done, spy. How many more nights?"
D28B_T_END,"Bilmiyorum, Niko. Bilsem de söylemezdim.","I don't know, Niko. And if I did, I wouldn't say."
D28B_N_END,"Kaydedildi. 6 ve 12 Nisan, Bizans nüshası. Kırk sekiz gün, Tolga Bey. Söylememekte haklıydınız.","Recorded. 6 and 12 April, the Byzantine copy. Forty-eight days, Mr Tolga. You were right not to say."
```

### 6.6 Co-op bağlantısı (28o ⟷ 28b, aynı harita)

| t / faz | Olay | Yön | Etki |
|---|---|---|---|
| 28b faz 1 ⟷ 28o faz 1 | `28.bridge_down` | B→O | Köprü yıkılınca Osmanlı'nın ekranında kapının önündeki köprü çöker (toz); Urban bark: `D28O_U_BRIDGE` ("Köprüyü söktüler. İyi. Ben de köprü istemem; ben gedik isterim."). |
| 28b faz 2 ⟷ 28o faz 1 | `28.shot(target_pos, charge)` | B→O | **Bizans'ın atışları Osmanlı'nın tehlikesidir:** 28o'daki "surdan arada bir düşen gülle" co-op'ta Bizans'ın küçük topudur. Atıştan 1,5 sn önce Osmanlı'nın ekranında kule ağzında duman ve yerde düşüş halkası (GunDrill öngörüsü). Halkadaki kazıklar devrilir, Osmanlı yeniden çakar (28o kazık sayısı +1 iş). Oyuncuya isabet yok (§2.3); halkada kalan Osmanlı en çok yere düşer (−25). |
| 28b faz 3a ⟷ 28o faz 2 | `28.haul_progress(p)` | O→B | **Ortak sayaç:** Bizans'ın balya süresi Osmanlı'nın Şahi'yi çekme süresidir. Osmanlı ne kadar iyi çekerse Bizans'a o kadar az zaman kalır. Bizans ekranında ovada kızak ilerler. |
| 28b faz 3b ⟷ 28o faz 3 | `28.aim(pos)`, `28.fire` | O→B | Osmanlı'nın nişan noktası Bizans'ın kulesinde bir hedef halkası olarak görünmez; yalnız atıştan sonra gülle **gerçekten Osmanlı'nın attığı yere** düşer. Bizans'ın astığı balya o noktadaysa "yün bulutu". Osmanlı'nın ilk toz karesi ile Bizans'ın karesi ±3 sn → **çift kayıt**. |
| 28b faz 4 | — | — | Osmanlı bölümü biter; Bizans tek başına devam eder (Osmanlı oyuncusu "oyalanma döngüsü" yerine akış şemasını görür). |

**Ortak düğüm:** `COOP_28_A` "İlk gülle yüne geldi" / `COOP_28_B` "İlk gülle çıplak taşa geldi".

---

## 7. Bölüm 37b — "Barikat" (18 Nisan 1453 gecesi)

### 7.1 Tarihî dayanak

- 37o'nun dayanağı aynen (OTTOMAN_NEW_B §1.1): bombardımanın bir haftasından sonra, 18 Nisan'da gün battıktan yaklaşık
  iki saat sonra Mesoteichion'a ilk büyük hücum; davul, zil, boru; saldıranlar barikatı yakmaya, yıkmaya ve merdiven
  dayamaya çalıştı; cephe dardı, Giustiniani'nin adamları **dört saat** dayandı (**R**, **B**). Barbaro'nun kayıp rakamı
  Venedikli bir kalemindir (**B**).
- **Barikat:** kalas, toprak dolu fıçı, çalı ve toprakla örüldü; toprak dolu fıçılar gülleyi yumuşatıyordu (**R**, **B**).
- **Kanca ve balta:** saldıranların fıçıları kancayla çekmesi 37o'daki gibi **(kurgu)**; savunanın ipi baltayla kesmesi
  aynı kurgunun öbür yüzü.
- **Gedikten çıkış:** savunanların barikatın ardından kısa çıkışlar yapması kuşatma anlatılarında geçer; 37o faz 3b'deki
  üç Cenevizli **(kurgu)**, bu bölümde Tolga onların arkasındadır.
- **Ateş çömlekleri:** savunanların yanıcı karışım ve ateş çömleği attığı yazılır (**B**, **K**). Bu bölümde çömlekleri
  NPC'ler atar; Tolga'nın işi ateşi barikattan uzak tutmaktır (§2.3).
- Tarih iki tarafta aynı: hücum püskürtülür, barikat sabaha yeniden örülür.

### 7.2 Yer ve sistemler

- **Harita:** 37o ile aynı: `LandWalls` + `SiegeField`, gece (`Night.environment`), `intact = false`, barikat
  `set_repair(4)`, `ditch_filled = false`. Oyuncu barikatın **iç** tarafında (z < 14) ve barikatın üst kenarında.
- **Barikat fıçıları:** 37o'nun beş fıçısı (aynı `id`'ler: `stk_0..4`). Her fıçının bir **kaldıraç yuvası** (arkadan
  sokulan sırık) ve kancanın takılacağı çember. Barikatın arkasında bir **sarnıç teknesi** ve kova yığını, bir **çatal
  vinç** (`Bogaz.crane`) ve toprak yığını.
- **Kalabalık:** `Garrison.land_walls` (oyuncunun alanı `skip`), barikatta 8 canlı Ceneviz savunanı (`Soldier`, Ceneviz
  renkleri), `WallFight` (onarım ekibi, `add_builders`).
- **Yeniden kullanılan:** `RowMeter` (kaldıraç ve çekişme), zamanlı tuş (balta), 17o/39o'nun kova zinciri, `Vfx.fire`,
  `WaveRunner.run` (bir dalga, kısa), `Gunner` yerine Osmanlı **okçu yaylımı** (`Assault.volley` ters yönde; "Ok!"
  uyarısı, mazgal/siper kuralı), `Bogaz.crane` + `BalanceMeter`, `TespitCam`, `Lore.scatter(self, "37b")`,
  `Grade.finish("37b")`.
- **Süre hedefi:** 10–12 dk; durdurulan konuşma ≤ 1,5 dk.

### 7.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 0. Barikat | Gün batımı | `UI_OBJ37B_GIUST` | Giustiniani barikatı dolaşır; Tolga'ya **balta** ve bir kova verir (E). Ovadan davul ve zil yaklaşır (37o faz 1'in sesi; co-op'ta Osmanlı'nın gerçek ritmi). | — |
| 1. Ateş | 20.30 | `UI_OBJ37B_BUCKET`, `UI_OBJ37B_DUCK` | Saldıranlar meşale ve yanan çalı demeti atar: barikatın üstünde **yangın noktaları** (her biri 10 sn içinde söndürülmezse kalas tutuşur, `set_repair` bir aşama düşer). Sarnıç teknesinden **kova doldur** (E basılı 1 sn), koş, at (E). Aynı anda **ok yaylımları**: "Ok!" sonrası 2 sn içinde barikatın arkasına çömel (C), yoksa −20 can. **Altı yangın**, 2,5 dk. | Sayaç: söndürülen /6. Can 0 → Niko çeker, 10 sn. |
| 2. Kanca | 22.00 | `UI_OBJ37B_CUT`, `UI_OBJ37B_LEVER` | Kancalar barikatın fıçılarına takılır (gölgede NPC, co-op'ta Osmanlı Tolga'sı). Takılan her kanca için iki yol: (a) **Kes:** ip gerili iken baltayla vur, işaret yeşilken E (iki vuruş = ip kopar). Ip gerili değilse balta kayar. (b) **Dayan:** fıçının arkasındaki yuvaya sırık sok (E), **RowMeter** ile karşı yükle; saldıranların "hey"ine denk gelen iyi vuruş fıçıyı yerinde tutar. Fıçı devrilirse barikatta delik açılır. Tehlike: surdan değil **ovadan** gelen taş ve ok (gölge halka, 1,2 sn). **3 dk.** | Sayaç: fıçı /5 yerinde. |
| 2b. Çıkış | Faz 2 içinde (2. fıçı devrilince) | `UI_OBJ37B_SALLY` | Giustiniani: "Deliği kapatmadan önce temizleyin!" Tolga üç Cenevizlinin arkasında delikten çıkar: **WaveRunner**, bir dalga, 40 sn, beceri 0,4; Tolga'ya kısa kılıç. Sonra **geri ve kapat**: delikten geri gir, Niko'yla yerdeki fıçıyı deliğe **it** (RowMeter, 3 iyi vuruş). | Kaybedilirse Cenevizliler Tolga'yı içeri çeker, delik açık kalır ve faz 2 hemen biter (o ana kadarki fıçılar sayılır). |
| 3. Geri çekilme | 00.30 | `UI_OBJ37B_HOLD` | Ovada boru: saldıranlar çekilir, yaralılarını sürüklerler. Barikattaki bir savunan **ateş çömleği** kaldırır, sürüklenen yaralılara doğru. Tolga yanındadır: **E: "Dur! Çekiliyorlar."** (1,5 sn pencere, her çömlekçi için). Durdurulan çömlekçi çömleği yere bırakır. Durdurulamayan atar (NPC; Tolga'nın eli yok). | Sayaç: `held_pots`. Tarih değişmez; yalnız birkaç kişinin dönüş yolu değişir. |
| 4. Şafağa | 01.00 → şafak | `UI_OBJ37B_CRANE`, `UI_OBJ37B_PHOTO` | Delikler ve yanan yerler onarılır: **çatal vinçle toprak dolu fıçıyı kaldır ve yerine indir** (`BalanceMeter`, yeşilde E; kırmızıda fıçı barikata çarpar, bir aşama geri). Devrilen fıçı sayısı + yanan kalas kadar iş (en az 2, en çok 6). **Tespit:** şafakta yeniden örülmüş barikatın üstünde Giustiniani (37o'nun Giustiniani karesinin aynası; pencere 30 sn). | Süre 3 dk; biterse onarım ekibi bitirir. |

**Animasyon ve görsel geri bildirim**
- **Faz 0:** Giustiniani barikatın üstünde yürür, fıçılara elini koyar; ovadan meşale sırası yaklaşır, zil sesiyle birlikte
  meşalelerin sırası öne kayar.
- **Faz 1:** atılan meşale havada döner, barikata düşünce kalasın üstünde alev (`Vfx.fire`, küçük); kova suyu yay çizer,
  alev söner, buhar ve "tıss"; kova boşken sallanır. Oklar barikatın kalaslarına saplanıp titrer; çömelince Tolga'nın başı
  kalas hizasının altına iner.
- **Faz 2:** kanca çembere takılınca "klank" ve kıvılcım; ip ovaya doğru sarkık eğri, çekişte düzleşir ve titrer; balta
  ipe iner, gerili ipte lif lif açılır, ikinci vuruşta kopar ve iki ucu savrulur (kamçı 0,4 sn); kaldıraçta Tolga ve bir
  Cenevizli sırığa yüklenir (eğilme pozu), fıçı sallanır ama geri oturur; devrilirse fıçı ovaya yuvarlanır, kapağı açılır,
  toprak dökülür, arkadaki kalas düşer (`LandWalls.set_repair` −1).
- **Faz 2b:** delikten çıkarken barikatın kalas kenarına omuz sürtünür; karşılamada kıvılcım; geri çekilirken Cenevizliler
  sırtlarını vermeden geri yürür; fıçıyı iterken iki kişinin ayakları toprağı kazır.
- **Faz 3:** çömlekçinin kolu yukarıda, Tolga'nın eli kolunun üstüne iner; durdurulan çömlekçi çömleği yere koyar ve bir
  an ovaya bakar; ovada iki azap kalkanın üstünde birini sürükler (37o faz 4).
- **Faz 4:** vinç kolunda fıçı sallanır, yerine oturunca toprak taşar; şafakta gök morarır, barikatın siluetinde Giustiniani.
- **Zemin:** savunanlar barikatın iç yüzündeki toprak rampada (`LandWalls.fill_y`), devrilen fıçılar moloz yamacında
  `Assault.ground_y` ile yuvarlanır.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **37B.1** Barikat sabaha bütün | yerinde kalan fıçı ≥ 3/5 **ve** söndürülen ≥ 5/6 | `FLOW_37B_1` |
| **37B.2** Barikat delindi, sabaha yeniden örüldü | aksi hâlde | `FLOW_37B_2` |

`held_pots` dosya notunda bir cümleyi değiştirir. `--autotest[=lose]` (varsayılan 37B.1; `=lose`: bot ipi gevşekken keser,
kaldıraçta geç vurur, çıkışı kaybeder). Akış şeması: `FLOW37B_FIRE` → `FLOW37B_HOOKS` → `FLOW37B_SALLY` →
`FLOW37B_POTS` → `FLOW37B_DAWN` → {`37B.1`, `37B.2`}; altında `Grade.finish("37b")` ve `UI_CH37B_STATS`.

### 7.4 Konuşanlar

Var olan: `SPK_GIUST`, `SPK_NIKO`, `SPK_GENOESE` (Ceneviz savunanı), `SPK_DEFENDER` (çömlekçi). Koşullu: `_FIRE_*`,
`_CUT`, `_SLIP`, `_HOLD_*`, `S_ARROW`, `_POT_*` olay bark'ları; `D37B_T_SALLY_LOST` yalnız 2b kaybedilince.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D37B_N_01` | SPK_NIHAT | say |
| `D37B_T_01` | SPK_TOLGA | say |
| `D37B_G_01` | SPK_GIUST | say |
| `D37B_T_G1` | SPK_TOLGA | say |
| `D37B_NK_01` | SPK_NIKO | bark |
| `D37B_GE_ARROW` | SPK_GENOESE | bark |
| `D37B_NK_FIRE` | SPK_NIKO | bark |
| `D37B_T_FIRE` | SPK_TOLGA | bark |
| `D37B_G_HOOK` | SPK_GIUST | bark |
| `D37B_GE_CUT` | SPK_GENOESE | bark |
| `D37B_GE_SLIP` | SPK_GENOESE | bark |
| `D37B_NK_HOLD` | SPK_NIKO | bark |
| `D37B_T_HOLD` | SPK_TOLGA | bark |
| `D37B_GE_LOST` | SPK_GENOESE | bark |
| `D37B_G_SALLY` | SPK_GIUST | bark |
| `D37B_T_SALLY` | SPK_TOLGA | bark |
| `D37B_T_SALLY_LOST` | SPK_TOLGA | bark |
| `D37B_NK_PUSH` | SPK_NIKO | bark |
| `D37B_G_TENETE` | SPK_GIUST | bark |
| `D37B_DF_POT` | SPK_DEFENDER | bark |
| `D37B_T_STOP` | SPK_TOLGA | bark |
| `D37B_DF_STOPPED` | SPK_DEFENDER | bark |
| `D37B_G_DAWN` | SPK_GIUST | bark |
| `D37B_N_PHOTO` | SPK_NIHAT | bark |
| `D37B_NK_END` | SPK_NIKO | say |
| `D37B_T_END` | SPK_TOLGA | say |
| `D37B_N_END` | SPK_NIHAT | say |

### 7.5 Metinler

```csv
UI_CH37B_TITLE,"BÖLÜM {N} — BARİKAT","CHAPTER {N} — THE STOCKADE"
UI_CH37B_SUB,"18 Nisan 1453 · Mesoteichion, barikatın ardı · gece","18 April 1453 · The Mesoteichion, behind the stockade · night"
UI_FLOW37B_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: BARİKAT","FLOWCHART — CHAPTER {N}: THE STOCKADE"
UI_OBJ37B_GIUST,"Barikatta Giustiniani'yi bul","Find Giustiniani on the stockade"
UI_OBJ37B_BUCKET,"Yangınları söndür: teknede kova doldur (E basılı), at (E) · %d/%d","Put out the fires: fill a bucket at the trough (hold E), throw (E) · %d/%d"
UI_OBJ37B_DUCK,"Ok! Barikatın arkasına çömel (C)","Arrows! Crouch behind the stockade (C)"
UI_OBJ37B_CUT,"Kancanın ipini kes: ip gerginken yeşilde E","Cut the hook's rope: E on the green while it's taut"
UI_OBJ37B_LEVER,"Ya da sırığı sok ve dayan: yeşilde Space · fıçı %d/%d yerinde","Or brace the barrel with the pole: Space on the green · barrels in place %d/%d"
UI_OBJ37B_SALLY,"Delikten çık, Cenevizlilerin yanında dayan; sonra deliği fıçıyla kapat","Go out through the gap, hold beside the Genoese; then plug the gap with a barrel"
UI_OBJ37B_HOLD,"Çekiliyorlar: çömlekçinin kolunu tut (E)","They're pulling back: stop the pot-thrower's arm (E)"
UI_OBJ37B_CRANE,"Toprak fıçısını vinçle yerine indir (yeşilde E) · %d/%d","Lower the earth barrel into place with the crane (E on the green) · %d/%d"
UI_OBJ37B_PHOTO,"Tespit et: şafakta barikatın üstünde Giustiniani","Record: Giustiniani on the stockade at dawn"
UI_PROMPT37B_AXE,"E: baltayı al","E: take the axe"
UI_PROMPT37B_POLE,"E: sırığı sok","E: brace with the pole"
UI_PROMPT37B_STOP,"E: 'Dur! Çekiliyorlar.'","E: 'Stop! They're pulling back.'"
FLOW37B_FIRE,"Barikatta yangınlar","Fires on the stockade"
FLOW37B_HOOKS,"Kancalar, balta ve sırık","Hooks, axe and pole"
FLOW37B_SALLY,"Gedikten çıkış, delik kapandı","A sally from the gap; the gap plugged"
FLOW37B_POTS,"Çekilenlere çömlek atılmasın","No pots on the men pulling back"
FLOW37B_DAWN,"Şafağa kadar onarım","Repairs until dawn"
FLOW_37B_1,"Barikat sabaha bütün","The stockade whole by morning"
FLOW_37B_2,"Barikat delindi, sabaha yeniden örüldü","The stockade was breached, and rebuilt by morning"
UI_CH37B_STATS,"Yangın: %d/%d   ·   Fıçı: %d/%d   ·   Durdurulan çömlek: %d   ·   Dosya: %d/%d sayfa","Fires: %d/%d   ·   Barrels: %d/%d   ·   Pots held: %d   ·   File: %d/%d pages"
SIEGE_NOTE_37B_1,"İlk hücum, öbür taraftan. Yangın söndürdüm, ip kestim, fıçıya yüklendim. Barikat sabaha bütündü. Çekilenlere atılmayan çömlekleri de yazıyorum. — T.","The first assault, from the other side. I put out fires, cut ropes, leaned on barrels. The stockade was whole by morning. I'm also writing down the pots that weren't thrown at the men pulling back. — T."
SIEGE_NOTE_37B_2,"İlk hücum. Fıçılar gitti, delik açıldı, kapattık. Sabaha her şey yerindeydi; yerinde olmayan tek şey uykumuz. — T.","The first assault. Barrels went, a gap opened, we plugged it. By morning everything was back in place; the only thing missing was our sleep. — T."
LORE_37B_1_T,"Dört saat","Four hours"
LORE_37B_1,"18 Nisan gecesi hücum dört saat sürdü. Cephe dardı; barikatın önünde sayı üstünlüğü işe yaramadı. Giustiniani'nin zırhlı adamları gediği tuttu.","On the night of 18 April the assault lasted four hours. The front was narrow; before the stockade numbers counted for little. Giustiniani's armoured men held the breach."
LORE_37B_2_T,"Toprak dolu fıçılar","Earth-filled barrels"
LORE_37B_2,"Barikatın asıl gücü toprak dolu fıçılardı. Gülle onlara gömülür, taşı parçalamaz. Gece sökülen ya da devrilen fıçının yerine sabaha yenisi konurdu.","The stockade's real strength was its earth-filled barrels. A ball would bury itself in them instead of shattering stone. A barrel pulled down at night was replaced by morning."
LORE_37B_3_T,"Ses ve uyku","Noise and sleep"
LORE_37B_3,"Davul, zil ve boru yalnız saldıranlara yürüyüş ritmi vermiyordu; surdakileri uykusuz bırakıyordu. Barbaro bu gürültüyü korkuyla anlatır.","Drums, cymbals and trumpets didn't only give the attackers a marching rhythm; they left the men on the walls without sleep. Barbaro describes the din with dread."
```

Replikler:

```csv
D37B_N_01,"Tolga Bey, 18 Nisan gecesi. Toplar bir haftadır dövüyor; dış surun düştüğü yerde Giustiniani'nin barikatı var. Bu gece ilk büyük hücum geliyor. Siz barikatın içindesiniz.","Mr Tolga, the night of 18 April. The guns have pounded for a week; where the outer wall fell there's Giustiniani's stockade. Tonight the first great assault is coming. You're on the inside of the stockade."
D37B_T_01,"Barikat. Kalas, fıçı, toprak. Benim mesleğimde buna 'geçici çözüm' denir; genelde kalıcı olur.","A stockade. Planks, barrels, earth. In my trade we'd call it a 'temporary solution'; it usually ends up permanent."
D37B_G_01,"Kova ve balta. Ateşe kova, ipe balta. Fıçıyı kaybedersen deliği biz kapatırız; ama kaybetme.","A bucket and an axe. Bucket for fire, axe for rope. Lose a barrel and we'll plug the gap; but don't lose it."
D37B_T_G1,"Kova ve balta. Bütün işim bu iki kelimeye sığdı. İş tanımımı ilk kez anlıyorum.","Bucket and axe. My whole job fits into two words. For the first time I understand my job description."
D37B_NK_01,"Duyuyor musun, casus? Zil. Bütün gece bunu çalacaklar. Ben de bütün gece bunu duyacağım. Bu adaletsiz.","Can you hear it, spy? Cymbals. They'll play that all night. And I'll hear it all night. It's not fair."
D37B_GE_ARROW,"Frecce! Eğil!","Frecce! Get down!"
D37B_NK_FIRE,"Ateş! Kalasın üstünde! Kova, casus!","Fire! On the plank! Bucket, spy!"
D37B_T_FIRE,"Söndü. Yangın sigortası satarken bunu hep yangını görmeden anlatırdım.","It's out. When I sold fire insurance I always described this without ever seeing a fire."
D37B_G_HOOK,"Kanca! Fıçıya kanca taktılar! İp gerilince kes, gevşekken kesemezsin!","A hook! They've hooked a barrel! Cut when the rope's tight, you can't cut it slack!"
D37B_GE_CUT,"Koptu! Bravo!","It's parted! Bravo!"
D37B_GE_SLIP,"Gevşek ip kesilmez! Bekle!","You can't cut a slack rope! Wait!"
D37B_NK_HOLD,"Sırığı sok! Onlar çekerken biz iteriz!","Get the pole in! When they pull, we push!"
D37B_T_HOLD,"Bir ip, iki taraf, bir fıçı. Dünyanın en ciddi halat çekme oyunu.","One rope, two sides, one barrel. The most serious tug of war in the world."
D37B_GE_LOST,"Fıçı gitti! Delik var!","The barrel's gone! There's a gap!"
D37B_G_SALLY,"Deliğin önünü temizleyin, sonra kapatın! Üç kişi benimle! Sen de, kova adamı!","Clear the front of the gap, then close it! Three men with me! You too, bucket man!"
D37B_T_SALLY,"Barikatın dışı. Burası benim sigorta kapsamımın tamamen dışında.","Outside the stockade. This is entirely outside my coverage."
D37B_T_SALLY_LOST,"İçeri çektiler beni. Delik açık kaldı. Gerisini Giustiniani'nin adamları halledecek.","They've pulled me back in. The gap's still open. Giustiniani's men will handle the rest."
D37B_NK_PUSH,"Fıçıyı deliğe! It! It! Bu fıçı benim kuzenimden ağır!","The barrel into the gap! Push! Push! This barrel's heavier than my cousin!"
D37B_G_TENETE,"Tenete! Fıçıların arkasına! Çeksinler, biz yine koyarız!","Tenete! Behind the barrels! Let them pull, we'll put them back!"
D37B_DF_POT,"Çekiliyorlar! Bir çömlek daha, arkalarından!","They're pulling back! One more pot, after them!"
D37B_T_STOP,"Dur! Çekiliyorlar. Yaralılarını taşıyorlar. Bırak gitsinler.","Stop! They're pulling back. They're carrying their wounded. Let them go."
D37B_DF_STOPPED,"...Haklısın. Bu gece yeter.","...You're right. Enough for tonight."
D37B_G_DAWN,"Fıçı, toprak, kazık. Şafağa kadar. Sabah bu barikatı görüp şaşıracaklar.","Barrel, earth, stake. Until dawn. In the morning they'll see this stockade and be amazed."
D37B_N_PHOTO,"Şafak, barikat, uzun adam. Osmanlı nüshasında aynı adamın gece karesi var; sizinki sabahı.","Dawn, the stockade, the tall man. The Ottoman copy has a night frame of the same man; yours is the morning."
D37B_NK_END,"Dört saat, casus. Dört saat zil. Kulağımda hâlâ çalıyor.","Four hours, spy. Four hours of cymbals. They're still ringing in my ears."
D37B_T_END,"Benim de. Ama barikat ayakta. Sabaha herkes yine yerinde.","Mine too. But the stockade's standing. By morning everyone's back in place."
D37B_N_END,"Kaydedildi. 18 Nisan, Bizans nüshası. Barbaro bu gece savunanlardan kimsenin ölmediğini yazar; rakam bir Venedikli kalemden. Ama barikatın sabah yine ayakta olduğunu herkes yazar.","Recorded. 18 April, the Byzantine copy. Barbaro writes that not one defender died tonight; the figure comes from a Venetian pen. But everyone writes that the stockade stood again in the morning."
```

### 7.6 Co-op bağlantısı (37o ⟷ 37b, aynı harita)

| t / faz | Olay | Yön | Etki |
|---|---|---|---|
| 37b faz 0–1 ⟷ 37o faz 1 | `37.beat(good)` | O→B | Osmanlı'nın zil ritmi Bizans'ın ses ortamıdır. Osmanlı'nın her iyi vuruşu Bizans'ta bir **gerilim** işareti doldurur; 10 iyi vuruştan sonra Bizans'ın kova süresi 10 → 8 sn'ye iner ("ses bir silahtı", LORE_37O_3 / LORE_37B_3). Ritim kaçarsa Bizans'ın ekranında meşale sırası düzensizleşir. |
| 37b faz 1 ⟷ 37o faz 2 | `37.volley_b` | B→O | Bizans bir yangını söndürdüğü her seferde barikattaki okçular nişana döner: 37o'da kalas köprüdeki ok sıklığı bir kademe artar (her 2 sn → 1,6 sn, en çok 3 kademe). |
| 37b faz 2 ⟷ 37o faz 3 | `37.hook(barrel)`, `37.pull(beat)`, `37.cut(barrel)`, `37.brace(beat)` | O→B, B→O | **Halat çekme:** Osmanlı'nın kancası takıldığı fıçının sahibi Bizans'tır. İki tarafın RowMeter'ı aynı fıçıda yarışır: Osmanlı'nın iyi vuruşu +1, Bizans'ın iyi kaldıraç vuruşu −1; +3'te fıçı devrilir ve sahibi Osmanlı'ya geçer (`transfer`), −3'te kanca kayar ve düşer. Bizans ip gerginken baltayla keserse Osmanlı'nın ekranında ip kopar (37o'nun "ipi kestiler"i). İki oyuncu birbirini görür (barikatın iki yüzü, 6–8 m; paradoks yok). |
| 37b faz 2b ⟷ 37o faz 3b | `37.sally_start`, `37.sally_end(result)` | B→O | Gedikten çıkış ortaktır: Bizans Cenevizlilerin arkasında, Osmanlı bölükbaşının yanında. Düellolar NPC'lere karşıdır (Bizans azaplarla, Osmanlı Cenevizlilerle); iki Tolga arasındaki 3 m kuralı burada en sıkı: **göz göze** anı senaryolu (Bizans delikten çıkınca 4 m'de, 1 sn, ikisi de kılıcını indirir: `D_COOP_T_MEET_1`). Bizans deliği kapatınca Osmanlı'nın faz 3'ü biter (`sally_end`). |
| 37b faz 3 ⟷ 37o faz 4 | `37.pot(lane)`, `37.pot_held(lane)` | B→O | Osmanlı yaralıyı sürüklerken her ateş çömleği bir şerit seçer. Bizans o şeridin çömlekçisini durdurursa (`pot_held`) Osmanlı'nın yolunda o çömleğin birikintisi **hiç oluşmaz**. Bu bölümün insan bağı budur; ortak düğümü belirler. |
| 37b faz 4 ⟷ 37o sonu | `37.photo` | ortak | 37o'nun karesi gece, 37b'ninki şafak: aynı adam (Giustiniani). İki karenin ikisi de çekilirse dosyada yan yana durur (çift kayıt değil, "gece/sabah" çifti; `UI_COOP_DOUBLE` yerine `UI_COOP_PAIR`). |

```csv
UI_COOP_PAIR,"GECE / SABAH","NIGHT / MORNING"
```

**Ortak düğüm:** `COOP_37_A` "Çekilenlerin yolu açık kaldı" (`pot_held ≥ 2`) / `COOP_37_B` "Çömlekler düştü".

---

## 8. Bölüm 32b — "Çanlar" (28 Mayıs 1453)

### 8.1 Tarihî dayanak

- **Son gün:** 28 Mayıs Osmanlı ordugâhında oruç ve hazırlık günüydü; hendek dolduruldu, merdiven ve mantolar ileri
  getirildi, toplar gün boyu surları dövdü (**R**, **B**; 32o'nun dayanağı). Savunanlar gün boyu barikatı onardı (**R**).
- **Alay ve çanlar:** O gün şehirde ikonalar ve kutsal emanetler surlar boyunca gezdirildi, kiliselerin çanları çalındı;
  halk ve askerler birlikte dua etti (**R**). Bizans kiliselerinde tahta **semantron** da çalınırdı; oyun kulede ikisini
  birden gösterir.
- **İmparator'un konuşması:** İmparator komutanlarını topladı ve onlara konuştu; konuşmanın metni **S** ve **L**'de
  aktarılır, sözler büyük ölçüde yazarların kaleminden çıkmıştır (öz olarak alınır; bölümde yalnız iki bark).
- **Ayasofya:** Akşam Ayasofya'da Rum ve Latinlerin birlikte katıldığı son ayin (**R**). Sahne mevcut Bölüm 25'in Bizans
  dalından buraya taşınır (§1 "kronoloji düzeltmesi").
- **İç surun kapıları:** Gece savunanlar dış sur ile iç sur arasındaki alana (peribolos) geçti; iç surun kapıları
  arkalarından kilitlendi, geri çekilme yolu kapandı (**R**).
- **Sükût:** Gece yarısına doğru Osmanlı ordugâhı sustu; surlardan bu sessizlik duyuldu (**R**). 32o faz 4c'nin öbür yüzü.
- **Kurgu:** hendeğe atılan demetlerin kancayla geri çekilmesi, çan ipinin kopması ve Tolga'nın kuleye tırmanıp ipi
  eklemesi, Niko'nun ateşi.
- Kerkoporta yok. Bu bölümde hücum yok; hücum 26'dadır.

### 8.2 Yer ve sistemler

- **Harita:** `LandWalls` + `SiegeField` (32o ile aynı Lykos kesiti), gündüz `make_day()`, akşam `make_dawn(t)` tersine,
  gece `Night.environment`. 32o'nun hendek dolumu (kademeli demet yığını) **aynı ağ**: Bizans tarafı hendek korkuluğundan
  (parateichion'un önündeki alçak duvar) aşağı bakar.
- **Çan kulesi (yeni küçük kurucu):** iç surun hemen ardında, Aziz Romanos kilisesinin yanında 14 m ahşap-taş kule:
  içeride üç kat **ahşap iskelet** (kirişler tutunulur, `enable_climb`), kırık bir iç merdiven, tepede iki çan (asma
  boyunduruğu) ve bir **semantron** (asılı tahta, tokmakla vurulur). Çanların ipleri kulenin içinden aşağı iner.
- **Barikat:** 37b'nin barikatı ve çatal vinci (`Bogaz.crane`), `set_repair` aşamaları; 32o'nun barikat hedefi aynı nesne.
- **Alay:** `Crowd.civilian` + yakında canlı `Person` (keşişler, papazlar, ikona taşıyanlar: 24'ün ikona sedyesi
  modeli yeniden kullanılır), sur yolu boyunca yürüyüş yolu.
- **Ayasofya:** Bölüm 25'in Bizans dalının Ayasofya aşaması, statik yardımcıya çıkarılmış hâliyle.
- **Kapı:** iç surun bir kapısı, iki kanat, ağır sürgü (yatay kiriş) ve iki halka.
- **Yeniden kullanılan:** iple kanca (29o'nun kanca nişanı, ters yönde aşağı), `RowMeter` (çekiş, çan ritmi, kapı itişi),
  `Traversal`, zamanlı tuş (düğüm), `BalanceMeter` (kule kirişi, vinç), 20'nin "Top!" uyarısı, `Gunner` (mantonun ardındaki
  Osmanlı tüfekçisi), `TespitCam`, `hud.choose`, `Lore.scatter(self, "32b")`, `Grade.finish("32b")`.
- **Süre hedefi:** 12–13 dk; durdurulan konuşma ≤ 2,5 dk (Ayasofya dahil).

### 8.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Demet avı | Sabah | `UI_OBJ32B_HOOK`, `UI_OBJ32B_HAUL`, `UI_OBJ32B_DUCK` | Osmanlılar hendeğe çalı demeti atıyor. Hendek korkuluğunun arkasından ip ucunda **kanca sarkıt**: nişan halkası hendekteki demetin üstündeyken E. Takılırsa **çek** (RowMeter, 3 iyi vuruş; kötü vuruşta demet ipten kayar ve dibe düşer). Çekilen demet korkuluğun arkasına atılır (gece yakılmak üzere). Tehlikeler: mantoların arkasından **ok yaylımı** ("Ok!" → 2 sn içinde korkuluğun dibine çömel) ve bir Osmanlı **tüfekçisi** (`Gunner`; yer değiştir). **4 dk.** | Sayaç: çekilen demet. Can 0 → Niko çeker, 15 sn. |
| 2. Çan ipi | Öğle | `UI_OBJ32B_TOWER`, `UI_OBJ32B_SPLICE` | Akşam alayı için çanlar çalınacak; kulenin büyük çanının ipi boyunduruğun dibinde kopmuş. (a) Kulenin içinde **tırman** (14 m; iç merdivenin yarısı kırık, gerisi kirişlerde serbest tırmanış; bir kiriş çürük: basınca 5 cm çöker, 1 sn içinde öbürüne geç). (b) Tepede boyunduruğun kirişinde **denge** (`BalanceMeter`; aşağıdan top sesleri kuleyi titretir) ve ipi **ekle**: üç zamanlı düğüm (sarım + ilmek). (c) **Semantron'u** bir kez vur (E): ses doğru mu? Keşiş aşağıdan onaylar. | Düşüş: alt kat kirişine −20 can, oradan yeniden. |
| 3. Barikat | İkindi → akşamüstü | `UI_OBJ32B_CRANE`, `UI_OBJ32B_COVER` | Osmanlı'nın son gülleleri barikata (32o faz 3; gölgede üç atış). Gözcü "Duman!" deyince **2 sn** içinde vincin arkasındaki taş siperin ardına geç. Atışların arasında **onar**: çatal vinçle toprak fıçısını kaldır, yerine indir (`BalanceMeter`, yeşilde E), önüne kazık (zamanlı E). Gülle vincin yükü havadayken gelirse fıçı parçalanır. | `repair` sayacı: her yerine konan fıçı +1, her isabet −1. Sonuç ≥ 0: barikat sağlam. |
| 4a. Alay | Gün batımı | `UI_OBJ32B_BELLS`, `UI_OBJ32B_PHOTO` | Alay sur yolunda yürür (ikonalar, mumlar, ilahiler). Tolga kulede iki çanın iplerinde: **RowMeter** ama iki girdi: büyük çan (Space) ve küçük çan (E) sırayla, alayın ilahisinin ritmiyle; **24 vuruş**, alay kulenin önünden geçene dek (≈ 90 sn). **Tespit:** kulenin penceresinden sur yolunda ilerleyen alay (pencere 30 sn). Bu sırada ordugâhta ateşler birer birer yanar (32o faz 4a; ordugâh ışık ve tekbirle dolar). | Kare kaçarsa not. Vuruş ≥ 18: `bells_ok`. |
| 4b. Ayasofya | Akşam | `UI_OBJ32B_CANDLE` | (25'ten taşındı.) Kalabalığın arasında bir mum yak. Fotoğraf yok; dosyaya "Fotoğraf çekilmedi." Bu bölümün tek bilinçli durağı (≤ 75 sn). | — |
| 5a. Kapılar | Gece | `UI_OBJ32B_GATE`, `UI_OBJ32B_BAR` | Savunanlar periboloya geçti. İç surun kapısı **kapanacak**: iki kanadı Niko ve iki askerle **it** (RowMeter "hep birlikte", 4 iyi vuruş; kanat ağır, her kötü vuruşta 10 cm geri açılır), sonra **sürgüyü indir**: iki kişilik, E basılı + zamanlama (gerilim çubuğu, 34b faz 4). | Süre yok; sayaç `gate_beats`. |
| 5b. Niko'nun ateşi | Gece yarısı | `UI_OBJ32B_NIKO` | Ordugâh susar (32o'nun "Sükût!"u; ateşler birer birer söner, ses düşer). Peribolosta Niko'nun küçük ateşi. Kısa sahne, **3 seçenekli** `hud.choose`: incir / söz / sus. Seçim `GameState.flags["niko_night"] = "fig" / "word" / "sit"` olarak yazılır; 26'da (Bizans) Niko'nun tek bark'ını seçer. | — |

**Animasyon ve görsel geri bildirim**
- **Faz 1:** ip korkuluktan hendeğe sarkık eğri; kanca demete gömülünce çalılar çatırdar; çekişte ip düzleşir, Tolga ve
  bir asker geriye yaslanır; demet yukarı gelirken dallar korkuluğa takılır, sonra arkaya atılır (yığın büyür). Hendekte
  32o'nun azapları demet taşır, biri yukarı bakıp el sallar (öfkeli değil, yorgun). Oklar korkuluğa saplanır.
- **Faz 2:** kule içinde toz ışık huzmeleri; kırık merdiven basamakları aşağıda; çürük kiriş çatırdar, toz; tepede çan
  boyunduruğu, kopuk ip ucu rüzgârda sallanır; düğümde sarımlar tek tek (görünür halka); semantron tokmağı iner, tahta
  sallanır.
- **Faz 3:** 32o'nun gülle isabetleri `LandWalls.set_repair` aşamasını düşürür (toz, kıymık); vinç kolunda fıçı salınır;
  yerine oturan fıçının toprağı taşar; kazık her vuruşta batar; isabet anında havadaki fıçı parçalanır (toprak yağmuru).
- **Faz 4a:** çanlar ipin çekişiyle sallanır (boyunduruk döner, dil çana vurur: ses ve hafif kule titreşimi); Tolga'nın
  kolları iki ipte sırayla aşağı; alay mumlarıyla sur yolunda (figüranlar sur yolu y'sinde, ikona sedyesini dört kişi
  taşır, adım eş); ufukta ordugâhın ateşleri birer birer yanar.
- **Faz 5a:** kapı kanatları menteşede gıcırdar, itenler omuz verir; sürgü iki halkaya oturunca "tok" sesi ve toz.
- **Faz 5b:** ateş (`Night.campfire`), Niko bağdaş kurar (zemin y'sinde), tavuğu yok; ordugâh tarafında ışıklar söner,
  uzaktan yalnız rüzgâr; şehirde çanlar (kulede başka biri çalıyor).

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **32B.1** Barikat gece yarısı ayakta, çanlar çaldı | `repair ≥ 0` **ve** `bells_ok` | `FLOW_32B_1` |
| **32B.2** Barikat yarık kaldı | aksi hâlde | `FLOW_32B_2` |

32B.2'de 26'nın 2. dalgasında (Urban'ın topu barikatı yıkar) onarılacak fıçı sayısı +1. Çekilen demet sayısı ≥ 4 ise
26o'da hendek yamacında bir boşluk kalır (yalnız görüntü + bir azap bark'ı). `--autotest[=late]` (varsayılan 32B.1;
`=late`: bot demetleri kaçırır, vinçte geç kalır, çanda 14 vuruş). Akış şeması: `FLOW32B_BUNDLES` → `FLOW32B_ROPE` →
`FLOW32B_REPAIR` → `FLOW32B_BELLS` → `FLOW32B_LITURGY` → `FLOW32B_GATES` → {`32B.1`, `32B.2`}.

### 8.4 Konuşanlar

Var olan: `SPK_NIKO`, `SPK_GIUST`, `SPK_MONK` (Keşiş Makarios; çan kulesinin keşişi), `SPK_LOOKOUT`, `SPK_EMPEROR`,
`SPK_DEFENDER`. Koşullu: faz 5b'de seçime göre yalnız bir çift (`FIG` / `WORD` / `SIT`). `D32B_EM_01/02` yalnız
Tolga İmparator'un güvenini kazandıysa (26'daki koşulun aynısı: Direniş ≥ 1), yoksa `_ALT` tek bark.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D32B_N_01` | SPK_NIHAT | say |
| `D32B_T_01` | SPK_TOLGA | say |
| `D32B_G_01` | SPK_GIUST | say |
| `D32B_NK_HOOK` | SPK_NIKO | bark |
| `D32B_T_HOOK` | SPK_TOLGA | bark |
| `D32B_LK_ARROW` | SPK_LOOKOUT | bark |
| `D32B_NK_GUNNER` | SPK_NIKO | bark |
| `D32B_MK_01` | SPK_MONK | say |
| `D32B_T_MK1` | SPK_TOLGA | say |
| `D32B_MK_ROT` | SPK_MONK | bark |
| `D32B_T_TOP` | SPK_TOLGA | bark |
| `D32B_MK_SEMANTRON` | SPK_MONK | bark |
| `D32B_LK_SMOKE` | SPK_LOOKOUT | bark |
| `D32B_G_REPAIR` | SPK_GIUST | bark |
| `D32B_T_REPAIR` | SPK_TOLGA | bark |
| `D32B_EM_01` | SPK_EMPEROR | bark |
| `D32B_EM_02` | SPK_EMPEROR | bark |
| `D32B_EM_ALT` | SPK_EMPEROR | bark |
| `D32B_MK_BELLS` | SPK_MONK | bark |
| `D32B_T_BELLS` | SPK_TOLGA | bark |
| `D32B_N_PHOTO` | SPK_NIHAT | bark |
| `D32B_N_LITURGY` | SPK_NIHAT | say |
| `D32B_DF_GATE` | SPK_DEFENDER | bark |
| `D32B_NK_GATE` | SPK_NIKO | bark |
| `D32B_T_GATE` | SPK_TOLGA | bark |
| `D32B_N_SILENCE` | SPK_NIHAT | bark |
| `D32B_NK_01` | SPK_NIKO | say |
| `D32B_T_NK1` | SPK_TOLGA | say |
| `D32B_NK_02` | SPK_NIKO | say |
| `D32B_T_FIG` | SPK_TOLGA | say |
| `D32B_NK_FIG` | SPK_NIKO | say |
| `D32B_T_WORD` | SPK_TOLGA | say |
| `D32B_NK_WORD` | SPK_NIKO | say |
| `D32B_T_SIT` | SPK_TOLGA | say |
| `D32B_NK_SIT` | SPK_NIKO | say |
| `D32B_NK_END` | SPK_NIKO | say |
| `D32B_N_END` | SPK_NIHAT | say |

### 8.5 Metinler

```csv
UI_CH32B_TITLE,"BÖLÜM {N} — ÇANLAR","CHAPTER {N} — THE BELLS"
UI_CH32B_SUB,"28 Mayıs 1453 · Mesoteichion ve Aziz Romanos kilisesi · son gün","28 May 1453 · The Mesoteichion and the church of St Romanus · the last day"
UI_FLOW32B_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: ÇANLAR","FLOWCHART — CHAPTER {N}: THE BELLS"
UI_OBJ32B_HOOK,"Kancayı hendekteki bir demete sarkıt (E) · çekilen: %d","Drop the hook onto a bundle in the moat (E) · hauled: %d"
UI_OBJ32B_HAUL,"Demeti yukarı çek: yeşilde Space","Haul the bundle up: Space on the green"
UI_OBJ32B_DUCK,"Ok! Korkuluğun dibine çömel (C)","Arrows! Crouch below the breastwork (C)"
UI_OBJ32B_TOWER,"Çan kulesine tırman: çürük kirişlere dikkat","Climb the bell tower: watch for rotten beams"
UI_OBJ32B_SPLICE,"Kopan çan ipini ekle (yeşilde E) · %d/%d","Splice the broken bell rope (E on the green) · %d/%d"
UI_OBJ32B_CRANE,"Atışların arasında barikatı onar: fıçıyı vinçle indir (yeşilde E)","Repair the stockade between shots: lower the barrel with the crane (E on the green)"
UI_OBJ32B_COVER,"Duman! Taş siperin arkasına","Smoke! Behind the stone shelter"
UI_OBJ32B_BELLS,"Alayla birlikte çanları çal: büyük çan Space, küçük çan E · %d/%d","Ring the bells with the procession: great bell Space, small bell E · %d/%d"
UI_OBJ32B_PHOTO,"Tespit et: sur yolunda alay","Record: the procession on the wall walk"
UI_OBJ32B_CANDLE,"Bir mum yak","Light a candle"
UI_OBJ32B_GATE,"İç surun kapısını kapat: hep birlikte it (yeşilde Space)","Close the inner wall's gate: push together (Space on the green)"
UI_OBJ32B_BAR,"Sürgüyü indir (E basılı · kırmızıda bırak)","Lower the bar (hold E · let go on red)"
UI_OBJ32B_NIKO,"Niko'nun ateşine git","Go to Niko's fire"
UI_C32B_FIG,"Cebindeki inciri uzat.","Hold out the fig in your pocket."
UI_C32B_WORD,"Yarın yanında olacağım.","I'll be beside you tomorrow."
UI_C32B_SIT,"Bir şey söyleme. Otur.","Say nothing. Sit."
FLOW32B_BUNDLES,"Hendekten demet avı","Fishing bundles out of the moat"
FLOW32B_ROPE,"Çan kulesinde kopan ip","A broken rope in the bell tower"
FLOW32B_REPAIR,"Son güllelerin arasında onarım","Repairs between the last shots"
FLOW32B_BELLS,"Alay ve çanlar","The procession and the bells"
FLOW32B_LITURGY,"Ayasofya'da son ayin","The last liturgy in Hagia Sophia"
FLOW32B_GATES,"Kapılar arkamızdan kapandı","The gates shut behind us"
FLOW_32B_1,"Barikat ayakta, çanlar çaldı","The stockade standing, the bells rung"
FLOW_32B_2,"Barikat yarık kaldı","The stockade left split"
UI_CH32B_STATS,"Demet: %d   ·   Onarım: %+d   ·   Çan: %d/%d   ·   Dosya: %d/%d sayfa","Bundles: %d   ·   Repairs: %+d   ·   Bells: %d/%d   ·   File: %d/%d pages"
SIEGE_NOTE_32B_1,"Son gün. Hendekten demet çektim, kuleye tırmanıp çan ipini ekledim, gülleler arasında fıçı indirdim. Akşam çanlar çaldı. Gece kapılar arkamızdan kapandı. — T.","The last day. I hauled bundles out of the moat, climbed the tower and spliced the bell rope, lowered barrels between the shots. In the evening the bells rang. At night the gates closed behind us. — T."
SIEGE_NOTE_32B_2,"Son gün. Barikat gece yarısı yarıktı; sabah ne olacağını biliyorum, yazmıyorum. Çanlar çaldı. — T.","The last day. At midnight the stockade was split; I know what the morning brings, I'm not writing it. The bells rang. — T."
LORE_32B_1_T,"Alay","The procession"
LORE_32B_1,"28 Mayıs'ta ikonalar ve kutsal emanetler surlar boyunca gezdirildi; çanlar çaldı, Rumlar ve Latinler, askerler ve halk birlikte dua etti. Runciman o günü kuşatmanın en sessiz ve en kalabalık günü diye anlatır.","On 28 May icons and relics were carried along the walls; bells rang, and Greeks and Latins, soldiers and townspeople prayed together. Runciman describes it as the quietest and most crowded day of the siege."
LORE_32B_2_T,"Semantron","The semantron"
LORE_32B_2,"Bizans kiliseleri cemaati yalnız çanla değil, asılı bir tahtaya tokmakla vurarak da çağırırdı. Semantron'un sesi kuru ve ritimlidir; manastırlarda bugün de kullanılır.","Byzantine churches called the faithful not only with bells but also by striking a hanging wooden board with a mallet. The semantron's sound is dry and rhythmic; monasteries still use it today."
LORE_32B_3_T,"Kilitlenen kapılar","The locked gates"
LORE_32B_3,"Son gece savunanlar dış surla iç sur arasındaki alana geçti ve iç surun kapıları arkalarından kilitlendi. Geri çekilme yolu yoktu; ya dış sur tutulacaktı ya da hiçbir şey.","On the last night the defenders moved into the space between the outer and inner walls, and the gates of the inner wall were locked behind them. There was no way back; either the outer wall held, or nothing did."
```

Replikler:

```csv
D32B_N_01,"Tolga Bey, 28 Mayıs. Karşı tarafta oruç günü; ama ordu bütün gün hazırlanıyor. Bu tarafta da kimse dinlenmiyor. Bugün çok iş var ve hepsinin sonu yarın.","Mr Tolga, 28 May. Over there it's a day of fasting; but the army will spend all day getting ready. On this side nobody rests either. There's a lot of work today, and all of it ends tomorrow."
D32B_T_01,"Son gün. Benim işimde 'son gün' denince poliçe yenilenir. Burada yenilenmiyor.","The last day. In my line of work 'the last day' means the policy gets renewed. Here it doesn't."
D32B_G_01,"Hendeği dolduruyorlar. Doldursunlar; ama ne kadar yavaş dolarsa o kadar iyi. Kancayı al.","They're filling the moat. Let them; but the slower it fills, the better. Take the hook."
D32B_NK_HOOK,"Takıldı! Çek, casus! Onların demeti bizim ateşimiz olur!","Caught! Pull, spy! Their bundle becomes our firewood!"
D32B_T_HOOK,"Onlar atıyor, ben çekiyorum. Hendekte bir demet alışverişi. Kimse kâr etmiyor.","They throw, I pull. A brushwood trade in the moat. Nobody's making a profit."
D32B_LK_ARROW,"Ok! Korkuluğun dibine!","Arrows! Down below the breastwork!"
D32B_NK_GUNNER,"Mantonun arkasında tüfek! Yer değiştir!","A gun behind the mantlet! Move!"
D32B_MK_01,"Akşam alay geçecek, çanlar çalmalı. Büyük çanın ipi koptu; yukarıda, boyunduruğun dibinde. Ben yaşlıyım. Sen hafifsin.","The procession comes this evening; the bells must ring. The great bell's rope has snapped; up there, at the foot of the yoke. I'm old. You're light."
D32B_T_MK1,"Herkes bana hafif diyor. Bunu bir iltifat olarak almaya başladım.","Everyone keeps calling me light. I'm starting to take it as a compliment."
D32B_MK_ROT,"O kiriş çürük! Öbürüne bas!","That beam's rotten! Step on the other one!"
D32B_T_TOP,"Tepedeyim. Buradan hem ordugâh hem şehir görünüyor. İkisi de aynı şeyi bekliyor.","I'm at the top. From here you can see both the camp and the city. Both are waiting for the same thing."
D32B_MK_SEMANTRON,"Bir kez vur tahtaya! ...Evet. Ses doğru. İp de doğru.","Strike the board once! ...Yes. The sound is right. And so is the rope."
D32B_LK_SMOKE,"Duman! Bataryada duman!","Smoke! Smoke at the battery!"
D32B_G_REPAIR,"Bir gülle, bir fıçı. Onlar bir atarsa biz bir koyarız. Akşama kadar.","One ball, one barrel. They fire one, we put one back. Until evening."
D32B_T_REPAIR,"Hasar ve onarım aynı hızda. Benim mesleğimde buna 'denge' denir. Burada buna 'akşama kadar' deniyor.","Damage and repair at the same speed. In my trade we call that 'equilibrium'. Here they call it 'until evening'."
D32B_EM_01,"(Barikatın yanından geçerken) Sen. Seni tanıyorum. Kâtip. Hâlâ buradasın.","(Passing by the stockade) You. I know you. The clerk. You're still here."
D32B_EM_02,"Burada kalanlara borçluyum. Hepsine. Sana da.","I am in debt to everyone who stayed. To all of them. To you too."
D32B_EM_ALT,"(Barikatın yanından geçerken, askerlere) Burada kalan herkese borçluyum.","(Passing by the stockade, to the soldiers) I am in debt to everyone who has stayed here."
D32B_MK_BELLS,"Alay geliyor! Büyük, küçük, büyük, küçük! İlahiyle birlikte!","The procession's coming! Great, small, great, small! With the hymn!"
D32B_T_BELLS,"Aşağıda alay, yukarıda ben, ufukta ateşler. Çanlar ikisinin de duyabileceği tek ses.","The procession below, me above, the fires on the horizon. The bells are the one sound both sides can hear."
D32B_N_PHOTO,"Sur yolunda alay, Tolga Bey. Osmanlı nüshasında aynı saatte ateşlerin arasında Sultan geçiyor. İki kare, aynı akşam.","The procession on the wall walk, Mr Tolga. In the Ottoman copy, at the same hour, the Sultan is riding past the fires. Two frames, the same evening."
D32B_N_LITURGY,"Ayasofya. Yıllardır ayrı dua eden insanlar bu akşam aynı yerde. Fotoğraf yok, Tolga Bey. Bir mum yeter.","Hagia Sophia. People who have prayed apart for years are in the same place tonight. No photograph, Mr Tolga. A candle is enough."
D32B_DF_GATE,"Kapı! Kapatın! Arkamızda kapı kalmasın!","The gate! Close it! No gate left open behind us!"
D32B_NK_GATE,"İt! Bu kapıyı biz açmadık, biz de kapatırız!","Push! We didn't open this gate, but we'll close it!"
D32B_T_GATE,"Sürgü yerinde. Geri dönüş yolu kapandı. Bunu bir sigortacı olarak hiç önermezdim.","The bar's in place. The way back is shut. As an insurance man I'd never have recommended it."
D32B_N_SILENCE,"Dinleyin, Tolga Bey. Ordugâh sustu.","Listen, Mr Tolga. The camp has gone quiet."
D32B_NK_01,"Casus. Gel, otur. Ateşim küçük ama sıcak. Tavuk yok; kuzende. Kuzen Petrion'da. Annem de orada.","Spy. Come, sit. My fire's small but it's warm. No chicken; it's with my cousin. My cousin's in Petrion. So is my mother."
D32B_T_NK1,"Petrion. Haliç'in kıyısında, değil mi?","Petrion. On the Horn, isn't it?"
D32B_NK_02,"Evet. Yarın ne olursa olsun, onlar orada. Ben buradayım. Sence bu doğru mu?","Yes. Whatever happens tomorrow, they're there. I'm here. Do you think that's right?"
D32B_T_FIG,"(İnciri uzatır) Al. Kuşatmada bile incirimiz var, demiştin.","(Holds out the fig) Here. You said we'd still have figs, even under siege."
D32B_NK_FIG,"Hatırlıyorsun! ...Bunu yarına saklarım. Yarın incir yemek isteyeceğim.","You remember! ...I'll save it for tomorrow. Tomorrow I'll want to eat a fig."
D32B_T_WORD,"Yarın yanında olacağım, Niko. Ne kadar olabilirsem.","I'll be beside you tomorrow, Niko. As much as I can be."
D32B_NK_WORD,"Söz mü? Casus sözü mü, yoksa adam sözü mü? ...Neyse. İkisi de olur.","A promise? A spy's promise or a man's promise? ...Never mind. Either will do."
D32B_T_SIT,"(Susar. Oturur.)","(Says nothing. Sits.)"
D32B_NK_SIT,"İyi. Konuşmayalım. Sessizlik onların tarafında da var; bizim tarafta da olsun.","Good. Let's not talk. There's silence on their side; let there be some on ours too."
D32B_NK_END,"Uyu biraz, casus. Ben nöbetteyim. Ben hep nöbetteyim.","Get some sleep, spy. I'm on watch. I'm always on watch."
D32B_N_END,"Kaydedildi. 28 Mayıs, Bizans nüshası. Yarın son sayfa değil, Tolga Bey; ama yarından sonrası başka bir dosya.","Recorded. 28 May, the Byzantine copy. Tomorrow isn't the last page, Mr Tolga; but what comes after tomorrow is another file."
```

### 8.6 Co-op bağlantısı (32o ⟷ 32b, aynı harita)

| t / faz | Olay | Yön | Etki |
|---|---|---|---|
| 32b faz 1 ⟷ 32o faz 1 | `32.bundle_in(id)`, `32.bundle_out(id)` | O→B, B→O | **Ortak hendek:** Osmanlı'nın attığı her demet hendekte görünür ve Bizans'ın kancasına hedef olur; Bizans'ın çektiği her demet 32o'nun hendek sayacından **düşer** (`8/8` hedefi aynı kalır, Osmanlı yeniden atar). Osmanlı'nın ok yaylımı (32o "Ok!") Bizans'ın surdaki okçularının yaylımıdır; co-op'ta yaylım zamanını Bizans'ın kancası tetikler: Bizans bir demeti çektiği anda korkuluktaki okçular nişana döner (yaylım 3 sn sonra), Osmanlı'ya uyarı gider. Bizans'a gelen oklar da Osmanlı'nın siperindeki okçulardandır (gölge zamanlaması). |
| 32b faz 2 ⟷ 32o faz 2 | `32.mantlet(pos)` | O→B | Kule tepesinden Bizans, Osmanlı'nın ittiği mantoyu görür; mantonun son yeri 32b'nin tüfekçisinin yeridir (Gunner o mantonun arkasında doğar). |
| 32b faz 3 ⟷ 32o faz 3 | `32.smoke`, `32.impact(stage)`, `32.repair(stage)` | O→B, B→O | **Gülle ve onarım:** Osmanlı'nın üç atışı Bizans'ın barikatına gerçek isabettir. Duman anında Bizans'a "Duman!" uyarısı; isabet `LandWalls.set_repair` aşamasını düşürür. Bizans'ın onarımı aşamayı yükseltir ve Osmanlı'nın ekranında **barikatın yeniden büyüdüğü** görünür (32o'nun "2+ isabet = barikat yarıldı" ölçüsü co-op'ta net aşamaya bakar: isabet − onarım ≥ 2). Namluyu soğutma süresi Bizans'ın onarım penceresidir. |
| 32b faz 4a ⟷ 32o faz 4a–b | `32.fire_lit(n)`, `32.bell(beat)`, `32.photo` | ortak | Osmanlı her ateşi yaktığında Bizans'ın ufkunda bir ateş daha belirir; Bizans'ın her iyi çan vuruşu Osmanlı'nın ses ortamına bir çan ekler. İki tespit (Sultan / alay) farklı hedeftir; ikisi de çekilirse dosyada yan yana durur (`UI_COOP_PAIR` yerine `UI_COOP_EVENING`: "AYNI AKŞAM"). |
| 32b faz 5b ⟷ 32o faz 4c | `32.silence` | O→B | Osmanlı'nın faz 4c'si ("Sükût!") başladığı anda Bizans'ın ses ortamında ordugâh susar; Nihat `D32B_N_SILENCE`. Bizans'ın çanları Osmanlı'nın sükûtunda uzaktan duyulan çandır (32o'da zaten var). Hasan'ın ateşi ve Niko'nun ateşi aynı saatte: iki seçim de yazılır, 26/26o'da iki bark'a gider. |

```csv
UI_COOP_EVENING,"AYNI AKŞAM","THE SAME EVENING"
```

**Ortak düğüm:** `COOP_32_A` "Barikat şafağa ayakta girdi" (isabet − onarım ≤ 1) / `COOP_32_B` "Barikat yarık girdi".
Bu düğüm 26/26o'nun 2. dalgasındaki barikat aşamasını iki tarafta da belirler.

---

## 9. Bölüm 38b — "Zincir" (29 Mayıs 1453, 01.30 → öğle)

### 9.1 Tarihî dayanak

- **Haliç surları:** Son hücumda Haliç'e karadan indirilen gemiler Haliç surlarına yanaşıp merdiven dayadı; Haliç surunu
  Venedikliler ve Rumlar tuttu; denizden gelen hücumlar kara surları düşene kadar başarılı olamadı (**R**, **K**).
  Venedikli **Gabriele Trevisano** Haliç surlarının bir kesiminin komutanıydı; şehir düşünce esir düştü (**R**).
  (17'nin Kaptan Trevisano'su.) Savunanların çatal, taş, kaynar yağ ve ateş kullanması kuşatma boyunca anlatılır (**B**, **K**).
- **Sabah:** Kara surlarında sancaklar görülünce Haliç surundaki savunanların çoğu evlerine ve ailelerine koştu (**R**).
  **Petrion** gibi bazı mahalleler direnmeden teslim oldu ve korundu (**R**). Anahtarın papazın evinde olması, Tolga'nın
  damlardan koşması **(kurgu)**.
- **Kaçış:** Venedik kadırgaları (Alvise Diedo) ve Ceneviz gemileri öğleye doğru zincire indi; gemiler tayfasını ve
  kaçabilen sığınmacıları bekledi, alabildiği kadarını aldı (**R**, **B**). **Barbaro'ya göre iki denizci baltayla
  zincirin bağlarını kesti** ve gemiler açığa çıktı; Osmanlı tayfası şehre dağıldığı için peşlerine düşen olmadı (**B**,
  **R**). Barbaro bu gemilerden birindeydi (**B**). Bir Ceneviz gemisinin kovalayan fustanın önüne uyarı atışı yapması
  **(kurgu; 38o'daki kıç topunun öbür yüzü)**.
- **Giritliler:** Haliç'in ağzına yakın üç kulede Giritli denizciler öğleden sonraya kadar direndi; Sultan gemileri ve
  mallarıyla gitmelerine izin verdi (**R**). Nihat anar.
- Rıhtımla tekne arasına düşen Osmanlı tayfasını Bizans tarafından birinin de tutması **(kurgu)**: 38o faz 3b'nin öbür
  ucu. Tarih değişmez, bir insan suda kalmaz.

### 9.2 Yer ve sistemler

- **Harita:** 38o ile aynı: `Horn.build(self, 62.0, Rect2(), Vector2(-20, 20), 3801)`, 18b'nin sur parçası, `ladder_gap`,
  **deniz kapısı** (`SeaWalls.gate(parent, pos)`, 38o'nun çıkardığı yardımcı), kapının önünde rıhtım ve iki demir baba.
  Oyuncu bu kez **surun üstünde** (yürüyüş yolu y 9,6) ve kapının **içinde**.
- **Petrion damları:** 39o'nun `Petrion` seviyesinin kapı ucundaki ilk 40 m'si (sağdaki tek katlı düz damlar, moloz,
  kuyu) bu bölümde de kurulur: `Petrion.build(self, Vector3(...), {"day": true, "crowd": "flee"})` (küçük seçenek: gündüz,
  kaçan halk); papazın evi listedeki 4. ev (ikon nişi).
- **Gemiler:** 38o'nun kaçan gemileri (`SeaBattle.carrack` ×2, `war_galley` ×3) + zincir (kütükler, demir bağlar; 38o'nun
  zincir görüntüsü). Son Ceneviz karakasının kıçında küçük **kıç topu** (`CannonCrew`), kıçtan sarkan **kıç halatı**.
- **Kayık:** Niko'nun kuzeninin kayığı (17'nin kayığı, 6 kişilik; yolcu figürleri kayığın çocuğu).
- **Surda:** `WallFight.add_cauldron` (NPC döker), mazgallarda üç **çatal** (uzun sırık, iki uç), kum fıçısı ve kova,
  tahta **mazgal kepengi** (yanabilir: `Vfx.fire`).
- **Yeniden kullanılan:** `RowMeter` (çatal itişi, kapı, kürek), `BalanceMeter` (kayık yatışı, kıç halatı), 38o'nun
  kum kovası (8 sn), "Siper!" kuralı (C: mazgalın arkası), `Traversal` (damlar), 38o'nun "tekne ile rıhtım arası" kurtarma
  döngüsü (ters taraftan), `hud.choose` (çeviri), 33b'nin ip merdiven dalga zamanlaması, `GunDrill` + `CannonCrew`,
  `TespitCam`, `Lore.scatter(self, "38b")`, `Grade.finish("38b")`.
- **Süre hedefi:** 12–13 dk; durdurulan konuşma ≤ 2,5 dk.

### 9.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Mazgal | 01.30 | `UI_OBJ38B_FORK`, `UI_OBJ38B_SAND`, `UI_OBJ38B_DUCK` | Trevisano'nun kesimi. Haliç'ten fustalar yanaşır. (a) **Üç merdiven** mazgallara dayanır. Merdivenin tepesi mazgala değdiği an **çatalı geçir** (E), sonra **it**: RowMeter, işaret yeşilken Space; 3 iyi vuruş = merdiven 15° geri yatar ve tekneye düşer. Aşağıdakiler bastırdıkça (38o'nun "bastır"ı) ibre geri gelir. (b) Fustalardan **yanan oklar** mazgal kepengini tutuşturur: kum fıçısından kova (E), ateşe (E), **8 sn** içinde. (c) Ok yaylımı: "Ok!" sonrası 2 sn içinde mazgalın arkasına (C). Kaynar yağ NPC kazanından (Tolga'nın işi değil; yanında durursa bark). **4 dk**. | Bir merdivenin ucuna tırmanan biri varırsa Trevisano'nun adamları onu iterek geri yollar (−1, `reached +1`). Kepenk yanarsa sur yolunda 4 m geçilmez olur (3 dk). |
| 2a. Haber | 06.00 | `UI_OBJ38B_ROOFS`, `UI_OBJ38B_KEY` | Batıdaki burçlarda sancaklar. Savunanlar mazgalları bırakıp evlerine koşar. Trevisano kalır: "Biz kalıyoruz. Sen git." Niko: "Annem Petrion'da!" Petrion'un ihtiyarları teslime karar vermiş, kapının anahtarı papazın evinde, cadde kaçan insanlarla dolu. **90 sn:** **damlardan koş** (serbest tırmanma: moloz, tek katlı damlar, iki dam arası 1,2 m atlama; dam kenarından düşersen −15 can, caddeye inersin ve kalabalıkta yavaşlarsın). Papazın kapısında anahtar demetini al (E), geri dön. | Süre biterse papaz anahtarı kendisi getirir (yavaş), kapı faz 2b'de 30 sn geç açılır. |
| 2b. Deniz kapısı | Hemen ardından | `UI_OBJ38B_BAR`, `UI_OBJ38B_GRAB` | Kapının sürgüsü sıkışmış (gece gülle sarsıntısı, kurgu). Niko'yla iki ucundan **kaldır**: E basılı + zamanlama (gerilim çubuğu), sonra kanatları **it** (RowMeter, 3). Kapı açılır: rıhtımda 38o'nun fustası, tayfa karaya atlıyor. **Bir tayfa tekne ile rıhtım arasına düşer.** Rıhtımın kenarına yat ve **elini tut** (E basılı; tekne her ~5 sn rıhtıma vurur, 0,8 sn önce uyarı: vuruş anında bırak, yoksa el kayar). **30 sn.** | Süre biterse yaşlı tayfa kancayla çeker. Sayaç: `grabbed`. |
| 2c. Teslim | Hemen ardından | `UI_OBJ38B_WORDS` | İhtiyarlar ve papaz rıhtıma iner, anahtarı reise uzatır. Tolga ihtiyarların sözünü Türkçeye çevirir: **seçim** `UI_C38B_EXACT` ("Kapıları açıyoruz, canımızı ve evlerimizi istiyoruz.") / `UI_C38B_ADD` ("…kimseye zarar vermedik" eklemesi). `flags["petrion_word_b"]`. | — |
| 3a. Kayık | Öğleye doğru | `UI_OBJ38B_ROW`, `UI_OBJ38B_TRIM` | Gemiler zincire iniyor, sığınmacıları bekliyor. Niko'nun kuzeninin kayığında altı kişi (bir aile ve iki Venedikli tayfa; Niko'nun annesi **değil**: o evinde kalmak istedi). **RowMeter** 150 m (son Ceneviz gemisi) **ve** aynı anda **yatış**: yolcular kıpırdadıkça kayık yan yatar (`BalanceMeter`), A/D ile "sağa geç / sola geç" dersin (yolcular yer değiştirir). Kadırgaların kürek dalgası her ~8 sn yatışı iter. Yatış kırmızıda ≥ 1 sn: kayık su alır (−5 sn, kova sesi). | Sayaç: su alma. |
| 3b. İp merdiven | Gemiye varınca | `UI_OBJ38B_LADDER` | Karakanın bordasından ip merdiven sarkar. Yolcular sırayla tırmanır; Tolga merdivenin altını kayığa **bastırır**: dalga göstergesi, tepe anında E (33b faz 2b). Kötü anda merdiven savrulur, tırmanan bir an asılı kalır (−3 sn). **Altı kişi.** | Sayaç: çıkan /6 (hepsi çıkar; süre farkı). |
| 3c. Zincir | Öğle | `UI_OBJ38B_BOOM`, `UI_OBJ38B_PHOTO` | Tolga gemide. Öndeki Venedik kadırgalarından iki denizci zincirin kütüklerini bağlayan demir halkalara balta indiriyor (**B**). Karakanın kayığından Tolga demir halkayı bir **manivela** ile gergin tutar (E basılı, gerilim çubuğu ortada), her balta inişinde Space (zamanlı, 4 vuruş): iyi vuruşta halka yarılır, kötüde balta kayar. Zincir açılır. **Tespit:** açılan zincirden geçen gemiler, arkada Haliç ve şehir (pencere 40 sn). | Kare kaçarsa not. |
| 3d. Uyarı atışı | Zincirden sonra | `UI_OBJ38B_GUN` | Bir Osmanlı fustası peşte (38o faz 4). Kaptan: "Önüne at, üstüne değil." Kıç topu: **GunDrill** + nişan; nişan yayı fustanın gövdesinin en az 8 m önünde kalacak biçimde sınırlı (uyarı atışı). İki atış. | Sayaç: atış. Gemi her durumda kurtulur. |
| 4. Dönüş | Öğleden sonra | `UI_OBJ38B_ROPE` | Niko annesinin yanına dönmek istiyor; Nihat: "Dosya burada kalıyor." Kayık karakanın kıçına bağlı sürükleniyor. **Kıç halatından in** (E basılı = kay, `BalanceMeter`: halat geminin dalgasıyla sallanır, 7 m) kayığa. Niko çözer, kayık şehre döner. | Halattan düşersen suya; Niko çeker, −10 can. |

**Animasyon ve görsel geri bildirim**
- **Faz 1:** merdivenin tepesi mazgala sürtünür (taş tozu); çatal iki ucuyla merdivenin son basamağını kavrar, Tolga ve
  bir Venedikli sırığa yüklenir (eğilme pozu, ayaklar taşta kayar); merdiven yavaşça geri yatar, tepesindeki kişi bir an
  sallanır, sonra merdiven teknenin güvertesine iner (düşen kişi tekneye, suya değil). Yanan ok kepenge saplanır, alev
  büyür; kum kovasında kum yay çizer, alev söner, duman. Kazan (NPC) sallanır, devrilir (38o'nun `OilHazard` görüntüsü,
  kendi tarafından).
- **Faz 2a:** batıda burçlarda sancaklar; sur yolunda savunanlar koşarak merdivenlerden iner; Trevisano mazgalda kalır.
  Damlarda kiremit tıkırdar, bir iki kiremit kayıp düşer; aşağıda caddede insanlar bohçalarla (yürüyerek, koşarak; gömülme
  yok, cadde eğimini izler). Papaz anahtar demetini avucuna koyar.
- **Faz 2b:** sürgü iki halkadan kalkar, toz; kapı kanatları içe açılır (`open_gate`), rıhtımda fusta; tayfa küpeşteden
  atlar; düşen tayfanın başı ve kolları suda; Tolga'nın eli onunkini kavrar (IK); tekne vurunca eller ayrılır, tayfa bir
  an batar.
- **Faz 2c:** ihtiyarlar elinde **anahtar**, reis anahtarı alır, başıyla selam verir.
- **Faz 3a–b:** kürekler aynı evrede; yolcular yer değiştirirken eğilerek yürür, kayık yan yatar (su küpeşteye yaklaşır);
  ip merdiven bordaya çarpar, tırmanan yolcunun elleri basamaklarda.
- **Faz 3c:** iki denizci baltayı omuzdan indirir, her vuruşta kıvılcım; manivela halkanın içinde, Tolga'nın gövdesi geriye
  yaslanır; halka yarılır, kütükler akıntıyla açılır (38o'nun zincir görüntüsü).
- **Faz 3d:** kıç topunun ağzında alev, duman; fustanın önünde suda halka büyür ve su sütunu (fustanın güvertesine sprey).
- **Faz 4:** kıç halatı geminin kıçından kayığa katener; inerken Tolga'nın elleri halatta kayar, ayakları halata dolanır;
  Niko halatı çözer, halat suya düşer.
- **Zemin:** sur yolundakiler y 9,6; rıhtım y 1,2; tayfa ve yolcular teknenin çocuğu (tekneyle sallanır).

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **38B.1** Kapı zamanında açıldı, suya düşen tutuldu | anahtar süre içinde **ve** `grabbed` (Tolga tuttu) **ve** `reached ≤ 1` | `FLOW_38B_1` |
| **38B.2** Kapı geç açıldı ya da tayfayı yaşlı tayfa çekti | aksi hâlde | `FLOW_38B_2` |

`--autotest[=late]` (varsayılan 38B.1; `=late`: bot damdan bir kez düşer, kapıda vuruş anında bırakmaz, çatalı geç
geçirir). Akış şeması: `FLOW38B_WALL` → `FLOW38B_KEY` → `FLOW38B_GATE` → `FLOW38B_BOAT` → `FLOW38B_BOOM` →
`FLOW38B_BACK` → {`38B.1`, `38B.2`}; altında `Grade.finish("38b")`.

### 9.4 Konuşanlar

Yeni: `SPK_BARBARO` (Nicolò Barbaro, Venedikli gemi hekimi, günlüğün yazarı; tek kısa sahne). Var olan: `SPK_TREVISANO`,
`SPK_NIKO`, `SPK_PRIEST` (Petrion'un yaşlı papazı, 39o), `SPK_TOWNSMAN` (ihtiyar), `SPK_PATROL` (38o'nun reisi),
`SPK_SAILOR` / `SPK_SAILOR2` (Osmanlı tayfası), `SPK_GENOESE` (karakanın kaptanı). Koşullu: çeviri seçimine göre
`D38B_T_TR` / `D38B_T_TR_ADD`; `D38B_SA_THANKS` yalnız Tolga tuttuysa.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D38B_N_01` | SPK_NIHAT | say |
| `D38B_T_01` | SPK_TOLGA | say |
| `D38B_TR_01` | SPK_TREVISANO | say |
| `D38B_T_TR1` | SPK_TOLGA | say |
| `D38B_TR_FORK` | SPK_TREVISANO | bark |
| `D38B_NK_FIRE` | SPK_NIKO | bark |
| `D38B_TR_ARROW` | SPK_TREVISANO | bark |
| `D38B_T_FORK` | SPK_TOLGA | bark |
| `D38B_TR_REACHED` | SPK_TREVISANO | bark |
| `D38B_N_DAWN` | SPK_NIHAT | say |
| `D38B_TR_STAY` | SPK_TREVISANO | say |
| `D38B_NK_MOTHER` | SPK_NIKO | say |
| `D38B_TW_KEY` | SPK_TOWNSMAN | say |
| `D38B_T_ROOFS` | SPK_TOLGA | bark |
| `D38B_PR_KEY` | SPK_PRIEST | bark |
| `D38B_NK_BAR` | SPK_NIKO | bark |
| `D38B_SA_FALL` | SPK_SAILOR2 | bark |
| `D38B_T_GRAB` | SPK_TOLGA | bark |
| `D38B_SA_THANKS` | SPK_SAILOR | bark |
| `D38B_TW_01` | SPK_TOWNSMAN | say |
| `D38B_T_TR` | SPK_TOLGA | say |
| `D38B_T_TR_ADD` | SPK_TOLGA | say |
| `D38B_R_01` | SPK_PATROL | say |
| `D38B_NK_BOAT` | SPK_NIKO | say |
| `D38B_T_BOAT` | SPK_TOLGA | bark |
| `D38B_NK_TRIM` | SPK_NIKO | bark |
| `D38B_GE_LADDER` | SPK_GENOESE | bark |
| `D38B_BA_01` | SPK_BARBARO | bark |
| `D38B_T_BOOM` | SPK_TOLGA | bark |
| `D38B_N_PHOTO` | SPK_NIHAT | bark |
| `D38B_GE_GUN` | SPK_GENOESE | bark |
| `D38B_T_GUN` | SPK_TOLGA | bark |
| `D38B_NK_BACK` | SPK_NIKO | say |
| `D38B_N_STAY` | SPK_NIHAT | say |
| `D38B_T_END` | SPK_TOLGA | say |
| `D38B_N_END` | SPK_NIHAT | say |

### 9.5 Metinler

```csv
UI_CH38B_TITLE,"BÖLÜM {N} — ZİNCİR","CHAPTER {N} — THE BOOM"
UI_CH38B_SUB,"29 Mayıs 1453 · Haliç suru, Petrion kapısı ve zincir · gece 01.30 → öğle","29 May 1453 · The Horn wall, the Petrion gate and the boom · 1:30 a.m. → noon"
UI_FLOW38B_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: ZİNCİR","FLOWCHART — CHAPTER {N}: THE BOOM"
SPK_BARBARO,"Nicolò Barbaro","Nicolò Barbaro"
UI_OBJ38B_FORK,"Merdiveni çatalla it: ucu mazgala değince E, sonra yeşilde Space · %d/%d","Push the ladder off with the fork: E when it touches, then Space on the green · %d/%d"
UI_OBJ38B_SAND,"Kepenk yanıyor! Kum kovası (8 sn)","The shutter's on fire! Sand bucket (8 s)"
UI_OBJ38B_DUCK,"Ok! Mazgalın arkasına (C)","Arrows! Behind the merlon (C)"
UI_OBJ38B_ROOFS,"Damlardan papazın evine koş · %d sn","Run over the rooftops to the priest's house · %d s"
UI_OBJ38B_KEY,"Anahtarı al ve kapıya dön","Take the key and get back to the gate"
UI_OBJ38B_BAR,"Sıkışan sürgüyü Niko'yla kaldır (E basılı · kırmızıda bırak)","Lift the jammed bar with Niko (hold E · let go on red)"
UI_OBJ38B_GRAB,"Suya düşenin elini tut (E basılı · tekne vurunca bırak)","Hold the hand of the man in the water (hold E · let go when the boat hits)"
UI_OBJ38B_WORDS,"İhtiyarların sözünü çevir","Translate the elders' words"
UI_OBJ38B_ROW,"Son Ceneviz gemisine kürek çek (yeşilde Space)","Row to the last Genoese ship (Space on the green)"
UI_OBJ38B_TRIM,"Kayığı dengede tut: A/D ile yolculara yer değiştirt","Keep the boat trimmed: A/D to move the passengers"
UI_OBJ38B_LADDER,"İp merdiveni bastır: dalga tepedeyken E · %d/%d","Hold the rope ladder down: E at the top of the swell · %d/%d"
UI_OBJ38B_BOOM,"Halkayı manivelayla gergin tut (E basılı), balta inince Space · %d/%d","Keep the ring taut with the bar (hold E), Space when the axe falls · %d/%d"
UI_OBJ38B_PHOTO,"Tespit et: açılan zincirden geçen gemiler","Record: the ships passing through the opened boom"
UI_OBJ38B_GUN,"Uyarı atışı: fustanın önüne (üstüne değil) · %d/%d","Warning shot: ahead of the fusta (not at it) · %d/%d"
UI_OBJ38B_ROPE,"Kıç halatından kayığa in (E basılı · dengede kal)","Slide down the stern line into the boat (hold E · keep your balance)"
UI_C38B_EXACT,"'Kapıları açıyoruz; canımızı ve evlerimizi istiyoruz.'","'We are opening the gates; we ask for our lives and our homes.'"
UI_C38B_ADD,"'…ve kimseye zarar vermedik.' (ekle)","'…and we have harmed no one.' (add it)"
FLOW38B_WALL,"Mazgalda çatal ve kum","Fork and sand at the battlements"
FLOW38B_KEY,"Damlardan anahtara","Over the rooftops for the key"
FLOW38B_GATE,"Deniz kapısı açıldı; sudaki el","The sea gate opened; a hand in the water"
FLOW38B_BOAT,"Dolu kayık, ip merdiven","A full boat, a rope ladder"
FLOW38B_BOOM,"Zincir kesildi","The boom is cut"
FLOW38B_BACK,"Kıç halatından şehre dönüş","Back to the city down the stern line"
FLOW_38B_1,"Kapı zamanında açıldı, sudaki el tutuldu","The gate opened in time; the hand in the water was held"
FLOW_38B_2,"Kapı geç açıldı","The gate opened late"
UI_CH38B_STATS,"Merdiven: %d/%d   ·   Ateş: %d   ·   Yolcu: %d/%d   ·   Dosya: %d/%d sayfa","Ladders: %d/%d   ·   Fires: %d   ·   Passengers: %d/%d   ·   File: %d/%d pages"
SIEGE_NOTE_38B_1,"Haliç suru. Gece merdiven ittim, sabah kapıyı açtım, suya düşen bir Osmanlı tayfasının elini tuttum. Öğlen zincir kesildi, gemiler gitti. Ben gemiden indim. — T.","The Horn wall. At night I pushed ladders away, in the morning I opened the gate, I held the hand of an Ottoman sailor who fell in the water. At noon the boom was cut and the ships left. I got off the ship. — T."
SIEGE_NOTE_38B_2,"Haliç suru. Kapı geç açıldı; ihtiyarlar bekledi. Öğlen zincir kesildi. Gemilere bindirebildiğimizi bindirdik; gemi beni bırakmadı, ben gemiyi bıraktım. — T.","The Horn wall. The gate opened late; the elders waited. At noon the boom was cut. We got aboard whoever we could; the ship didn't leave me, I left the ship. — T."
LORE_38B_1_T,"Zincirin kesilmesi","The cutting of the boom"
LORE_38B_1,"Barbaro'ya göre 29 Mayıs öğlesi iki denizci baltayla zincirin bağlarını kesti; Venedik kadırgaları ve Ceneviz gemileri açığa çıktı. Osmanlı tayfası şehre dağılmıştı; kimse peşlerine düşmedi.","According to Barbaro, at noon on 29 May two sailors cut the fastenings of the boom with axes, and the Venetian galleys and Genoese ships got out to sea. The Ottoman crews had scattered into the city; no one went after them."
LORE_38B_2_T,"Gabriele Trevisano","Gabriele Trevisano"
LORE_38B_2,"Venedikli Gabriele Trevisano kuşatmada Haliç surlarının bir kesimini tuttu. Şehir düştüğünde kaçmadı ve esir düştü.","The Venetian Gabriele Trevisano held a section of the Horn walls during the siege. When the city fell he did not flee and was taken prisoner."
LORE_38B_3_T,"Nicolò Barbaro","Nicolò Barbaro"
LORE_38B_3,"Venedikli bir gemi hekimi olan Barbaro kuşatmayı gün gün yazdı. Günlüğü kuşatmanın en ayrıntılı tanıklıklarından biridir; kendi tarafını tutar, rakamlarını dikkatle okumak gerekir.","Barbaro, a Venetian ship's doctor, wrote down the siege day by day. His diary is one of its most detailed testimonies; it takes its own side, and its numbers must be read with care."
```

Replikler:

```csv
D38B_N_01,"Tolga Bey, 29 Mayıs, gece bir buçuk. Kara surlarında son hücum başladı. Haliç'e karadan indirilen gemiler de surlara yanaşıyor. Siz Trevisano'nun surundasınız. Bu gecenin sonunu biliyorsunuz. Onlar bilmiyor.","Mr Tolga, 29 May, half past one at night. The final assault has begun on the land walls. The ships dragged overland into the Horn are coming up to the walls too. You're on Trevisano's wall. You know how this night ends. They don't."
D38B_T_01,"Biliyorum. Ve bilmek hiçbir şeyi kolaylaştırmıyor.","I know. And knowing doesn't make anything easier."
D38B_TR_01,"Kâtip! Coco'nun gecesinden beri görmedim seni. Çatalı al. Merdiven mazgala değdiği an geçir ve it. Yukarı çıkan olmasın.","Clerk! I haven't seen you since Coco's night. Take the fork. The moment a ladder touches the battlements, hook it and push. No one comes up."
D38B_T_TR1,"Çatal. Mutfakta kullandığımdan biraz büyük.","A fork. A bit bigger than the one I use in the kitchen."
D38B_TR_FORK,"Şimdi! İt!","Now! Push!"
D38B_NK_FIRE,"Kepenk yanıyor! Kum, casus, kum!","The shutter's burning! Sand, spy, sand!"
D38B_TR_ARROW,"Oklar! Eğil!","Arrows! Down!"
D38B_T_FORK,"Gitti. Merdiven tekneye indi, adam güverteye düştü. Kalkıyor. İyi. Kalksın.","Gone. The ladder came down on the boat, the man fell on the deck. He's getting up. Good. Let him get up."
D38B_TR_REACHED,"Biri çıktı! Geri, geri! İtin onu!","One's up! Back, back! Push him off!"
D38B_N_DAWN,"Şafak, Tolga Bey. Batıya bakın.","Dawn, Mr Tolga. Look west."
D38B_TR_STAY,"Sancak. Kara surları... Herkes evine koşuyor. Kimseyi suçlamam. Biz kalıyoruz. Sen git; burada artık yazacak bir şey yok.","A banner. The land walls... Everyone's running home. I blame no one. We're staying. You go; there's nothing left to write here."
D38B_NK_MOTHER,"Annem! Annem Petrion'da! Casus, gel benimle!","My mother! My mother's in Petrion! Spy, come with me!"
D38B_TW_KEY,"(Rumca) Kapıyı açacağız. Direnmeyeceğiz. Ama anahtar papazda, papaz evinde, cadde insanla dolu!","(In Greek) We'll open the gate. We won't resist. But the key's with the priest, the priest's at home, and the street is full of people!"
D38B_T_ROOFS,"Cadde dolu. Damlar boş. Sigortada buna 'alternatif güzergâh' denir.","The street's full. The roofs are empty. Insurance calls this an 'alternative route'."
D38B_PR_KEY,"(Rumca) Al. Kapıyı açmak da bir dua sayılır bugün.","(In Greek) Take it. Today opening a gate counts as a prayer too."
D38B_NK_BAR,"Sürgü sıkışmış! Kaldır, ben de kaldırıyorum!","The bar's stuck! Lift, I'm lifting too!"
D38B_SA_FALL,"(Türkçe, rıhtımdan) Düştü! Teknenin altında kalacak!","(In Turkish, from the quay) He's fallen! He'll be crushed under the boat!"
D38B_T_GRAB,"Elini ver! ...Hangi taraftan olduğun şu an hiç umurumda değil.","Give me your hand! ...Right now I couldn't care less which side you're on."
D38B_SA_THANKS,"(Türkçe, nefes nefese) Sen... Rum musun? Fesin var... Sağ ol, kardeşim.","(In Turkish, out of breath) You... are you Greek? You've got a fez... Thank you, brother."
D38B_TW_01,"(Rumca) Ona söyle: kapıları açıyoruz. Canımızı ve evlerimizi istiyoruz.","(In Greek) Tell him: we are opening the gates. We ask for our lives and our homes."
D38B_T_TR,"Reis, ihtiyarlar diyor ki: kapıları açıyoruz; canımızı ve evlerimizi istiyoruz.","Captain, the elders say: we are opening the gates; we ask for our lives and our homes."
D38B_T_TR_ADD,"Reis, ihtiyarlar diyor ki: kapıları açıyoruz, kimseye zarar vermedik; canımızı ve evlerimizi istiyoruz.","Captain, the elders say: we are opening the gates, we have harmed no one; we ask for our lives and our homes."
D38B_R_01,"Anahtarı aldım. Bunu Sultan'ın adamlarına ben götürürüm. Bu kapıya kimse el sürmeyecek; reis sözü.","I've taken the key. I'll take it to the Sultan's men myself. No one will lay a hand on this gate; a captain's word."
D38B_NK_BOAT,"Annem gelmiyor. 'Evim burada' diyor. Kuzenimin kayığı rıhtımda; gemiler zincirde bekliyor. Komşuları götürelim. Sonra dönerim.","My mother won't come. 'My home is here,' she says. My cousin's boat is at the quay; the ships are waiting at the boom. Let's take the neighbours. Then I'll come back."
D38B_T_BOAT,"Altı kişi, bir kayık, bir kürek. Kapasite aşımı. Poliçe bunu kesinlikle kapsamaz.","Six people, one boat, one oar. Over capacity. The policy absolutely doesn't cover this."
D38B_NK_TRIM,"Sağa geçin! Sağa! Kayık sola yatıyor!","Move right! Right! The boat's listing left!"
D38B_GE_LADDER,"Merdiven! Birer birer! Çocuk önce!","The ladder! One at a time! The child first!"
D38B_BA_01,"(Öndeki kadırgadan) Balta! Halkalara balta! Kesin şunu, kesin!","(From the galley ahead) Axes! Axes on the rings! Cut it, cut it!"
D38B_T_BOOM,"Kırk sekiz gün bu zincir şehri korudu. Şimdi şehirden kaçanlar için kesiliyor.","For forty-eight days this boom protected the city. Now it's being cut for the people fleeing it."
D38B_N_PHOTO,"Açılan zincir, Tolga Bey. Osmanlı nüshasında aynı gemiler fustanın pruvasından kaydediliyor.","The opening boom, Mr Tolga. In the Ottoman copy the same ships are being recorded from the bow of a fusta."
D38B_GE_GUN,"Peşimizde bir fusta! Önüne at, üstüne değil. Korkutalım, yeter.","There's a fusta after us! Fire ahead of it, not at it. Frighten them off, that's enough."
D38B_T_GUN,"Uyarı atışı. Bu sabah ilk kez bir şeyi bilerek ıskalıyorum.","A warning shot. For the first time this morning I'm missing on purpose."
D38B_NK_BACK,"Casus. Ben dönüyorum. Annem orada. Kayık kıçta bağlı. Sen?","Spy. I'm going back. My mother's there. The boat's tied astern. You?"
D38B_N_STAY,"Gemide kalamazsınız, Tolga Bey. Dosya şehirde kalıyor. Sizin de kalmanız lazım.","You can't stay on the ship, Mr Tolga. The file stays in the city. You have to stay too."
D38B_T_END,"Gemi gidiyor, ben iniyorum. Hayatımda ilk kez son gemiyi bilerek kaçırıyorum.","The ship's leaving and I'm getting off. The first time in my life I've missed the last boat on purpose."
D38B_N_END,"Kaydedildi. 29 Mayıs öğlesi, Bizans nüshası. Trevisano esir düştü. Giritliler kulelerini öğleden sonraya kadar tuttu; Sultan gemileriyle gitmelerine izin verdi. Siz Petrion'a dönüyorsunuz.","Recorded. Noon, 29 May, the Byzantine copy. Trevisano was taken prisoner. The Cretans held their towers until the afternoon; the Sultan let them leave with their ships. You're going back to Petrion."
```

### 9.6 Co-op bağlantısı (38o ⟷ 38b, aynı harita)

| t / faz | Olay | Yön | Etki |
|---|---|---|---|
| 38b faz 1 ⟷ 38o faz 2 | `38.ladder_up(id)`, `38.fork(id, beat)`, `38.brace(id, beat)` | O→B, B→O | **Kullanıcının örneği:** Osmanlı'nın merdiveni Bizans'ın üç merdiveninden biridir (`id = 0`, ortadaki). İki tarafın RowMeter'ı aynı merdivende: Bizans'ın iyi itişi +1, Osmanlı'nın iyi "bastır"ı −1; +3'te merdiven geri yatar (Osmanlı'nın `BalanceMeter`'ı sert itilir, tırmanan iki tayfa güverteye düşer, Osmanlı 6 sn ceza alır: 38o'nun mevcut kaybı); −3'te merdiven mazgala oturur ve Bizans çatalı yeniden geçirmek zorundadır. Osmanlı tırmanırken (38o faz 2d) Bizans aynı merdiveni itemez (paradoks: Osmanlı 3 m'nin içine girer); yalnız NPC kazanı döker (§2.3) ve reis geri çağırır. |
| 38b faz 1 ⟷ 38o faz 2c | `38.fire_arrow`, `38.pot` | O→B, B→O | Osmanlı tarafının yanan okları Bizans'ın kepengini tutuşturur (NPC okçular; zamanlama Osmanlı'nın merdivende kaldığı süreye bağlı). Surdan atılan ateş çömleği (NPC) Osmanlı güvertesine düşer: Osmanlı'nın 8 sn'lik kum kovası. İki taraf aynı anda kendi yangınını söndürür; ekranda öbürünün dumanı görünür. |
| 38b faz 2b ⟷ 38o faz 3a–b | `38.gate_open`, `38.sailor_fall`, `38.grab(side, hold)` | B→O, ortak | Kapıyı Bizans açar: Osmanlı'nın ekranında kapı **Bizans'ın açtığı anda** açılır (gölgede senaryo zamanı). Suya düşen tayfa **ortak kurtarmadır**: Osmanlı tekneden, Bizans rıhtımdan aynı adamı tutar (iki tutma noktası 3,4 m arayla: kol ve yaka). İkisi de E basılıysa ilerleme iki kat; tekne vurduğunda ikisi de bırakmalı. 30 sn içinde çıkarılırsa `grabbed = "both"`. |
| 38b faz 2c ⟷ 38o faz 3c | `38.translate(side, choice)` | ortak | **Çift tercüme:** Bizans ihtiyarları Türkçeye, Osmanlı reisi Rumcaya çevirir. Seçimler birbirinin altyazısında görünür. İkisi de `ADD` derse Nihat'ın Paradoks göstergesi %20 titrer (`D38_COOP_N_ADD`). `petrion_word` = Osmanlı'nın, `petrion_word_b` = Bizans'ın seçimi; 39o/39b'de ikisi de bir bark seçer. |
| 38b faz 3c–3d ⟷ 38o faz 4 | `38.boom_cut`, `38.warn_shot(pos)`, `38.photo` | B→O | Zincirin açılma anı ortak. Kıç topunun düşüş halkası **Bizans'ın nişanıdır**: Osmanlı'nın A/D ile reise yön söylediği halka Bizans'ın attığı yerdir (en az 8 m önde; §2.3). İki kare ±3 sn → **çift kayıt**. |
| 38b faz 4 | — | — | Osmanlı akış şemasına geçer; Bizans kıç halatından iner. 39'da ikisi yeniden aynı haritada. |

```csv
D38_COOP_N_ADD,"İki tercüman, iki ek. Tolga Bey ve Tolga Bey, bu kapının sözü artık iki kere söylendi. Göstergem titredi; ama bu sefer kayda geçiriyorum.","Two interpreters, two additions. Mr Tolga and Mr Tolga, this gate's word has now been spoken twice. My meter flickered; but this time I'm recording it."
```

**Ortak düğüm:** `COOP_38_A` "Sudaki adamı iki el çekti" (`grabbed == "both"`) / `COOP_38_B` "Sudaki adamı tek el çekti".

---

## 10. Bölüm 39b — "Sığınak" (29 Mayıs 1453 akşamı → gece)

### 10.1 Tarihî dayanak

- 39o'nun dayanağı aynen (OTTOMAN_NEW_B §3.1): şehrin çoğunda yağma sürdü (**R**, **K**, **D**); Petrion gibi teslim olan
  birkaç mahalle Sultan'ın adamlarınca korundu (**R**). Bölüm yağmayı göstermez ve süslemez: yağmacılar yalnız koşar ve
  kapılara sancak diker; kimseye dokunulmaz, ekranda kimse yaralanmaz.
- **Kapıdaki sancak:** askerlerin girdikleri evi sancakla işaretlemesi (26'da `D26_N_FLAGS`); teslim olan mahallede
  Sultan'ın sancağı ve nöbetçi "emanet" demekti **(kurgu; muhafız konması R'ye dayanır)**.
- **Kurgu:** Niko'nun mahallesi, ailelerin kiliseye taşınması, kapının içeriden desteklenmesi, kova zinciri ve iple
  inen yaşlı Theodoros (39o'daki aynı adam), tavuk Sinerji.
- **İmparator:** akıbeti belirsizdir; hiçbir sürüm gösterilmez (39o ile aynı). Kerkoporta yok.

### 10.2 Yer ve sistemler

- **Harita:** 39o'nun `Petrion` seviyesi (`scripts/level/petrion.gd`) **aynen**: deniz kapısından içeri cadde, iki yanda
  sekizer ev, solda kilise (kapı kanatları kırılabilir, 3 aşama), kuyu, ortada moloz yığını, sağdaki dört tek katlı düz dam,
  listedeki altı ev, yanacak cumbalı ev. **Ek:** kilisenin **iç yüzü** (kapı kanatlarının arkası: iki çapraz destek yuvası,
  sürgü halkaları, yan duvarda dar bir ışıklık; nef zemininde aileler oturur), kuyunun **çıkrığı** (`RowMeter` kolu), cumbalı
  evin **arka avlusu** (aşağıda ipi karşılama yeri).
- **Aileler:** dokuz ev (listedeki altı + üç liste dışı). Her ailede 2–3 `Person` (yaşlı, kadın, çocuk); takip kodu 30o'nun
  ekip yürüyüşü (`follow`), engelde bekler, "el ver" ile geçer.
- **Yağmacılar:** 39o'nun üç `Walker` tayfası, **aynı** zaman çizelgesi (50., 100., 150. sn) ve aynı hedef kapı seçimi.
- **Yeniden kullanılan:** `Traversal` (damlar, moloz), görünür ip (damdan indirme), `BalanceMeter` (yaşlıya el verme,
  ipi karşılama), zamanlı tuş (kama çakma), `RowMeter` (kapıya omuz, kuyu çıkrığı), 17o/39o kova zinciri, `Vfx.fire` +
  duman, `hud.choose`, `TespitCam`, `Lore.scatter(self, "39b")`, `Grade.finish("39b")` (yalnız istatistik).
- **Süre hedefi:** 10–12 dk; durdurulan konuşma ≤ 2,5 dk.

### 10.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 0. Mahalle | 19.30 | `UI_OBJ39B_NIKO` | Kayıktan rıhtıma, deniz kapısından içeri. Niko'nun annesi Eudokia kilisenin önünde; papaz kapıyı aralık tutuyor. Eudokia dokuz evi sayar: "Sancaksız kalan kapı, kiliseye gelir." (≈ 40 sn) | — |
| 1. Kiliseye | Alacakaranlık, **3 dk** | `UI_OBJ39B_LEAD`, `UI_OBJ39B_HAND`, `UI_OBJ39B_LOWER` | Kapısına Sultan'ın sancağı dikilen ev **emanettir**, o aile evde kalır. Sancaksız kalan ya da kapısına **yağmacının** sancağı dikilen evin ailesi kiliseye götürülmeli. Bir aileyi al (kapıda E), **önden yürü** (aile 2,6 m/sn izler; 10 m'den fazla açılırsan durur). Engeller: moloz yığını (yaşlıya **el ver**: E basılı + `BalanceMeter`, yaşlı yığının üstünde sendeler), yan sokak kapalıysa **dam yolu**: Tolga önden tırmanır, çocuğu düz damdan **iple indir** (ip baca dibine iki tur sarılır, E basılı sal, `BalanceMeter` sallanma). Yağmacılar 50., 100., 150. sn'de listedeki bir kapıya koşar (uzaktan "Bu kapı benim!"): o kapının ailesi **hemen** taşınmalı (yağmacı içeri girmez, kapıda bekler; aile kapıdan çıkınca yağmacı kenara çekilir, kimseye dokunmaz). | Sayaç: kilisedeki aile, `late` (yağmacı sancağından sonra 20 sn'den uzun bekleyen aile). |
| 2. Kapı | Akşam | `UI_OBJ39B_BRACE`, `UI_OBJ39B_WEDGE`, `UI_OBJ39B_CANDLE` | Kilisenin kapısında baltalı iki tayfa (39o faz 2). Kapı çubuğu **100 → 0, saniyede −2**. Tolga **içeride**: (a) iki **çapraz desteği** yuvalarına koy (E), (b) dibine **kama çak**: zamanlı E, her desteğe 3 kama (iyi kama: çubuk düşüşü −0,4/sn), (c) balta inişlerinde **kanada omuz ver**: RowMeter, baltanın inişine denk gelen iyi vuruş o darbenin zararını yarıya indirir. (d) Arada aileler korkuyor: üç mum söner (kapı sarsıntısı), mumu yeniden yak (E; ışıklık kenarındaki kandilden), karanlıkta çocuk ağlar. | Çubuk sıfıra inmeden çavuş gelirse "kapı dayandı"; yoksa kapı kırılır, çavuş eşikte durur (39o ile aynı). |
| 3. Yangın | 22.00, **90 sn çatı sayacı** | `UI_OBJ39B_WELL`, `UI_OBJ39B_CHAIN`, `UI_OBJ39B_CATCH` | Kilisenin yanındaki ev tutuşur; üst katta yaşlı Theodoros. (a) **Kuyu çıkrığı:** kova kuyudan RowMeter ile (3 iyi vuruş = dolu kova), (b) kova zincirine ver (E): zincirdeki her kova çatı sayacına +3 sn. (c) Pencerede ip görünür (39o'da Tolga indirir; tek kişilikte bir yeniçeri): arka avluya koş, **ipi karşıla**: ipin ucunu tut (E basılı), `BalanceMeter` ipin gerginliği (çok sıkı = ip sürtünür ve takılır, çok gevşek = adam hızlı iner). Adam yere değince kollarından tut (E). Düşen kiremitler (gölge, 1 sn; −20 can). | Sayaç biterse çatı çöker; içeridekiler kapıdan çıkarılır (yaralı ama sağ), −1. |
| 4. İçeride | Gece yarısı | `UI_OBJ39B_SINERJI`, `UI_OBJ39B_PHOTO`, `UI_OBJ39B_SIT` | Kilise içinde aileler; kapıda yeniçeri nöbette. Niko'nun kuzeninin çocuğu ağlıyor: **tavuk Sinerji** kayıp. Kilisenin galerisine çıkan dar merdivenin kırık yarısından **tırman** (4 m), galeride tavuğu yakala (tavuk kaçar: iki deneme). **Tespit:** galeriden aşağı: mumlar, aileler, açık kapının eşiğinde nöbetçi ve papaz (39o'nun karesinin içeriden aynası; pencere 60 sn). Sonra Eudokia'nın yanına otur: birisi İmparator'u sorar → **seçim** (3; 39o'nun seçeneklerinin Bizans sözleri). | Kare kaçarsa not. |

**Animasyon ve görsel geri bildirim**
- **Faz 0:** papaz kapı kanadını omzuyla tutar; Eudokia parmaklarıyla evleri sayar; Niko annesine sarılır (iki `Person`
  kucaklaşma pozu, kısa).
- **Faz 1:** aile kapıdan bohçalarla çıkar (her figür kapının **içinden** yürüyerek); yaşlı moloz yığınında Tolga'nın koluna
  tutunur, sendeler; damda ip bacanın dibine iki tur sarılır (görünür halkalar), çocuk ipin ucundaki ilmekte oturur, aşağıda
  annesi kollarını açar. Yağmacı koşarken meşalesinin ışığı duvarlarda; kapıya kendi sancağını diker (39o'nun animasyonu),
  aile çıkınca bir adım geri çekilir, bakmaz. Osmanlı sancağı dikilen kapıda kapı aralanır, içeriden biri sancağa bakar,
  kapıyı kapatır (rahatlama).
- **Faz 2:** destek kirişi yuvaya oturur, kama her vuruşta 2 cm girer (tokmak inip kalkar); balta inişinde kanat içeri
  doğru titrer, kıymıklar **içeri** sıçrar, yarık büyür (39o'nun kırılma aşamaları içeriden); Tolga omzunu kanada verir,
  gövdesi sarsılır; mum alevleri her darbede yatar, üçü söner.
- **Faz 3:** kuyu çıkrığının kolu döner, ip sarılır, kova sallanarak çıkar; kova zinciri: dört komşu ve iki Osmanlı tayfası
  (39o'nun tayfası) aynı sırada kova verir, su yayı alevlere; ip pencereden arka avluya katener, Theodoros ipin ilmeğinde
  yavaş iner, Tolga'nın elleri ipte, ip gerildikçe düzleşir.
- **Faz 4:** galerinin kırık merdiveni (eller tırabzanda), tavuk kanat çırpar, galeri parmaklıklarının arasından kaçar;
  yakalanınca Tolga'nın kollarında sakinleşir, çocuğa verilir. Aşağıda mumlar (`Night.flicker`), aileler oturur (oturma pozu,
  zemin y'sinde).
- **Zemin:** cadde eğimi (`Petrion` cadde y'si), damlar düz dam y'si, kilise içi döşeme y'si.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **39B.1** Bütün aileler zamanında içeride, kapı dayandı | `late == 0` **ve** kapı çubuğu > 0 | `FLOW_39B_1` |
| **39B.2** Bazı kapılara geç kalındı | aksi hâlde | `FLOW_39B_2` |

Seçim `GameState.flags["emperor_answer_b"] = "know" / "wall" / "write"`. `--autotest[=late]` (varsayılan 39B.1; `=late`:
bot aileyi uzun yoldan götürür, kama çakmaz, kova zincirine geç katılır). Akış şeması: `FLOW39B_KIN` →
`FLOW39B_CHURCH` → `FLOW39B_DOOR` → `FLOW39B_FIRE` → `FLOW39B_NIGHT` → {`39B.1`, `39B.2`}.

### 10.4 Konuşanlar

Yeni: `SPK_EUDOKIA` (Niko'nun annesi, kurgu), `SPK_OLDMAN` (yaşlı Theodoros, 39o'daki adam; 39o'da yalnız öksürük, burada
iki replik), `SPK_GIRL` (Niko'nun kuzeninin kızı Zoe, kurgu; 31b'de de var). Var olan: `SPK_NIKO`, `SPK_PRIEST`,
`SPK_SAILOR` (yağmacı ya da kova zincirindeki tayfa), `SPK_JANISSARY`, `SPK_CAVUS` (tek bark, kapıda).
Koşullu: `D39B_EU_WORD_ADD` yalnız `petrion_word_b == "add"`. Faz 4 seçimine göre `KNOW` / `WALL` / `WRITE` çifti.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D39B_N_01` | SPK_NIHAT | say |
| `D39B_T_01` | SPK_TOLGA | say |
| `D39B_EU_01` | SPK_EUDOKIA | say |
| `D39B_EU_WORD_ADD` | SPK_EUDOKIA | say |
| `D39B_NK_01` | SPK_NIKO | say |
| `D39B_EU_02` | SPK_EUDOKIA | say |
| `D39B_T_02` | SPK_TOLGA | bark |
| `D39B_EU_SAFE` | SPK_EUDOKIA | bark |
| `D39B_SA_FLAG` | SPK_SAILOR | bark |
| `D39B_NK_HURRY` | SPK_NIKO | bark |
| `D39B_T_HAND` | SPK_TOLGA | bark |
| `D39B_GI_ROPE` | SPK_GIRL | bark |
| `D39B_PR_01` | SPK_PRIEST | say |
| `D39B_T_BRACE` | SPK_TOLGA | bark |
| `D39B_NK_WEDGE` | SPK_NIKO | bark |
| `D39B_GI_DARK` | SPK_GIRL | bark |
| `D39B_T_CANDLE` | SPK_TOLGA | bark |
| `D39B_CA_DOOR` | SPK_CAVUS | bark |
| `D39B_T_DOOR_OK` | SPK_TOLGA | bark |
| `D39B_T_DOOR_BROKE` | SPK_TOLGA | bark |
| `D39B_PR_FIRE` | SPK_PRIEST | bark |
| `D39B_NK_WELL` | SPK_NIKO | bark |
| `D39B_SA_CHAIN` | SPK_SAILOR | bark |
| `D39B_T_CATCH` | SPK_TOLGA | bark |
| `D39B_OM_01` | SPK_OLDMAN | bark |
| `D39B_GI_HEN` | SPK_GIRL | say |
| `D39B_T_HEN` | SPK_TOLGA | bark |
| `D39B_N_PHOTO` | SPK_NIHAT | bark |
| `D39B_OM_02` | SPK_OLDMAN | say |
| `D39B_T_KNOW` | SPK_TOLGA | say |
| `D39B_EU_KNOW` | SPK_EUDOKIA | say |
| `D39B_T_WALL` | SPK_TOLGA | say |
| `D39B_EU_WALL` | SPK_EUDOKIA | say |
| `D39B_T_WRITE` | SPK_TOLGA | say |
| `D39B_EU_WRITE` | SPK_EUDOKIA | say |
| `D39B_NK_END` | SPK_NIKO | say |
| `D39B_N_END` | SPK_NIHAT | say |

### 10.5 Metinler

```csv
UI_CH39B_TITLE,"BÖLÜM {N} — SIĞINAK","CHAPTER {N} — SANCTUARY"
UI_CH39B_SUB,"29 Mayıs 1453 · Petrion mahallesi, kilisenin içi · akşam","29 May 1453 · The Petrion quarter, inside the church · evening"
UI_FLOW39B_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: SIĞINAK","FLOWCHART — CHAPTER {N}: SANCTUARY"
SPK_EUDOKIA,"Eudokia","Eudokia"
SPK_OLDMAN,"Yaşlı Theodoros","Old Theodoros"
SPK_GIRL,"Zoe","Zoe"
UI_OBJ39B_NIKO,"Kilisenin önünde Niko'nun annesini bul","Find Niko's mother in front of the church"
UI_OBJ39B_LEAD,"Sancaksız kapıların ailelerini kiliseye götür · kilisede %d aile","Lead the families from doors without a banner to the church · %d families in the church"
UI_OBJ39B_HAND,"Yaşlıya el ver (E basılı · dengede tut)","Give the old one a hand (hold E · keep them steady)"
UI_OBJ39B_LOWER,"Çocuğu damdan iple indir (E basılı)","Lower the child from the roof on the rope (hold E)"
UI_OBJ39B_BRACE,"Kapıya destekleri koy (E)","Set the braces against the door (E)"
UI_OBJ39B_WEDGE,"Kama çak (yeşilde E) · balta inince kanada omuz ver (Space)","Drive the wedges (E on the green) · shoulder the door when the axe falls (Space)"
UI_OBJ39B_CANDLE,"Sönen mumları yeniden yak","Relight the candles that went out"
UI_OBJ39B_WELL,"Kuyudan kova çek (yeşilde Space)","Draw buckets from the well (Space on the green)"
UI_OBJ39B_CHAIN,"Kovayı zincire ver (E) · çatı: %d sn","Pass the bucket down the chain (E) · roof: %d s"
UI_OBJ39B_CATCH,"Arka avluda ipi karşıla (E basılı · ibreyi ortada tut)","Take the rope in the back yard (hold E · keep the needle centred)"
UI_OBJ39B_SINERJI,"Sinerji kayıp: galeriye tırman, tavuğu yakala","Synergy is missing: climb to the gallery, catch the chicken"
UI_OBJ39B_PHOTO,"Tespit et: içeriden, kapıdaki nöbet","Record: the watch at the door, from inside"
UI_OBJ39B_SIT,"Eudokia'nın yanına otur","Sit down beside Eudokia"
UI_PROMPT39B_FAMILY,"E: 'Benimle gelin, kiliseye.'","E: 'Come with me, to the church.'"
UI_C39B_KNOW,"Bilmiyorum.","I don't know."
UI_C39B_WALL,"Surda, adamlarının yanında düştü diyorlar.","They say he fell on the wall, beside his men."
UI_C39B_WRITE,"Kimse bilmiyor. Ben de öyle yazacağım.","Nobody knows. That's what I'll write."
FLOW39B_KIN,"Niko'nun mahallesi","Niko's quarter"
FLOW39B_CHURCH,"Sancaksız kapılardan kiliseye","From the doors without banners to the church"
FLOW39B_DOOR,"Kapının içi","The inside of the door"
FLOW39B_FIRE,"Kuyu, kova, ip","Well, bucket, rope"
FLOW39B_NIGHT,"Mumlar ve bir tavuk","Candles and a chicken"
FLOW_39B_1,"Bütün aileler içeride, kapı dayandı","Every family inside; the door held"
FLOW_39B_2,"Bazı kapılara geç kalındı","Some doors were too late"
UI_CH39B_STATS,"Aile: %d/%d   ·   Kapı: %d/100   ·   Kova: %d   ·   Dosya: %d/%d sayfa","Families: %d/%d   ·   Door: %d/100   ·   Buckets: %d   ·   File: %d/%d pages"
SIEGE_NOTE_39B_1,"Petrion, içeriden. Sancaksız kapıların ailelerini kiliseye taşıdık; kapıya kama çaktım; yaşlı Theodoros'u ipten karşıladım; tavuğu galeriden indirdim. Şehrin geri kalanı bu sayfada yok. — T.","Petrion, from inside. We moved the families from doors without banners into the church; I wedged the door; I caught old Theodoros off the rope; I brought the chicken down from the gallery. The rest of the city isn't on this page. — T."
SIEGE_NOTE_39B_2,"Petrion, içeriden. Bazı kapılara geç kaldım; aileler yine de kiliseye geldi. Kapıda çavuş durdu. Kapsam: bir sokak ve bir kilise. — T.","Petrion, from inside. I was late for some doors; the families still reached the church. The çavuş stood in the doorway. Coverage: one street and one church. — T."
LORE_39B_1_T,"Kiliselere sığınanlar","Those who took refuge in churches"
LORE_39B_1,"Şehir düşerken pek çok insan kiliselere sığındı. Kiliselerin çoğu korunamadı; teslim olan birkaç mahallede ise kapılara muhafız kondu ve içeridekiler kurtuldu.","As the city fell many people took refuge in churches. Most churches could not be protected; in the few quarters that surrendered, guards were set on the doors and those inside were spared."
LORE_39B_2_T,"Petrion","Petrion"
LORE_39B_2,"Haliç kıyısındaki Petrion, kuşatmanın son sabahı direnmeden teslim olan mahallelerden biriydi. Runciman'a göre evleri ve kiliseleri yağmadan kurtuldu.","Petrion, on the Golden Horn, was one of the quarters that surrendered without resistance on the last morning of the siege. According to Runciman its houses and churches escaped the plunder."
LORE_39B_3_T,"Mum","Candles"
LORE_39B_3,"Bizans kiliselerinde mum ve kandil yalnız ışık değil duaydı. O gece pek çok kilisede mumlar sabaha kadar yandı.","In Byzantine churches candles and oil lamps were not only light but prayer. That night, in many churches, the candles burned until morning."
```

Replikler:

```csv
D39B_N_01,"Akşam oldu, Tolga Bey. Şehrin çoğunda yağma sürüyor; kaynaklar bunu saklamaz, ben de saklamayacağım. Petrion teslim oldu, Sultan'ın adamları muhafız koyuyor. Ama her kapıya değil. Siz bu gece kapıların öbür yüzündesiniz.","Evening, Mr Tolga. Most of the city is being plundered; the sources don't hide it and neither will I. Petrion has surrendered, and the Sultan's men are setting guards. But not on every door. Tonight you're on the other side of the doors."
D39B_T_01,"Bütün gün mazgal, dam, kayık, halat. Şimdi kapı. Kapının iç tarafı.","All day battlements, rooftops, boats, ropes. Now a door. The inside of a door."
D39B_EU_01,"(Rumca) Sen Niko'nun casususun. Biliyorum, her akşam seni anlatıyordu. Dinle: dokuz ev var. Kapısına Sultan'ın sancağı dikilen evde kalırlar. Sancaksız kalan kiliseye gelir.","(In Greek) You're Niko's spy. I know, he talked about you every evening. Listen: there are nine houses. Where the Sultan's banner goes on the door, they stay. Where there's no banner, they come to the church."
D39B_EU_WORD_ADD,"(Rumca) Bu sabah rıhtımda 'kimseye zarar vermedik' demişsin. Doğru söyledin. Şimdi o söz bizi koruyor.","(In Greek) This morning on the quay you said 'we have harmed no one'. You told the truth. Now those words are protecting us."
D39B_NK_01,"Anne, bu casus iyidir. Kırmızımsı fesli ama iyidir.","Mother, this spy is a good one. Reddish fez, but good."
D39B_EU_02,"(Rumca) Fesin rengi umurumda değil. Çabuk ol.","(In Greek) I don't care what colour his fez is. Be quick."
D39B_T_02,"Dokuz kapı, bir kilise, bir ben. Bunu bir dağıtım problemi olarak düşünüyorum. Yardımı olmuyor.","Nine doors, one church, one me. I'm thinking of it as a logistics problem. It isn't helping."
D39B_EU_SAFE,"(Rumca) Sancak dikildi! O ev kalsın, sıradakine!","(In Greek) The banner's up! That house stays, on to the next!"
D39B_SA_FLAG,"(Uzaktan, Türkçe) Bu kapı benim! Sancağımı diktim!","(Far off, in Turkish) This door's mine! I've planted my banner!"
D39B_NK_HURRY,"Yağmacı kapıda! İçeridekileri al, casus, şimdi!","A looter at the door! Get the people out, spy, now!"
D39B_T_HAND,"Tutun bana, teyze. Yavaş. Bu taşlar da sizin kadar yaşlı.","Hold on to me, auntie. Slowly. These stones are as old as you are."
D39B_GI_ROPE,"(Rumca) Sallanıyorum! ...Gördün mü anne, uçuyorum!","(In Greek) I'm swinging! ...Look, mum, I'm flying!"
D39B_PR_01,"(Rumca) Kapıyı kırıyorlar! İçeriden tutun! Kirişleri koyun!","(In Greek) They're breaking the door! Hold it from inside! Get the beams in!"
D39B_T_BRACE,"Destek, kama, omuz. Sigortada buna 'hasar azaltma tedbiri' denir.","Brace, wedge, shoulder. Insurance calls this 'loss mitigation'."
D39B_NK_WEDGE,"Bir kama daha! Kapı benden yaşlı ama benden sağlam değil!","One more wedge! The door's older than me but it's not as tough!"
D39B_GI_DARK,"(Rumca) Mumlar söndü... Karanlık...","(In Greek) The candles went out... It's dark..."
D39B_T_CANDLE,"Işık geliyor. Bak. Bir, iki, üç. Karanlık sigortası yoktur ama mum vardır.","Light's coming. Look. One, two, three. There's no insurance against the dark, but there are candles."
D39B_CA_DOOR,"(Kapının dışından, Türkçe) Durun! Bu mahalle Sultan'ın emanetidir!","(From outside the door, in Turkish) Stop! This quarter is in the Sultan's trust!"
D39B_T_DOOR_OK,"Balta durdu. Dışarıda biri Türkçe 'emanet' diyor. Bu gece duyduğum en güzel kelime.","The axe has stopped. Someone outside is saying 'in trust' in Turkish. The best word I've heard tonight."
D39B_T_DOOR_BROKE,"Kanat düştü. Ama eşikte biri duruyor ve kimse içeri adım atmıyor.","The door's come down. But someone's standing on the threshold and no one's taking a step inside."
D39B_PR_FIRE,"(Rumca) Yangın! Yan ev! Theodoros yukarıda!","(In Greek) Fire! Next door! Theodoros is upstairs!"
D39B_NK_WELL,"Kuyuya! Kova benden, çıkrık senden!","To the well! I'll take the bucket, you take the windlass!"
D39B_SA_CHAIN,"(Türkçe) Ver kovayı! Sabahtan beri kürek çektim; kova da çekerim!","(In Turkish) Give me the bucket! I've rowed since morning; I can pull a bucket too!"
D39B_T_CATCH,"İp geliyor. Yavaş... yavaş... Tuttum! Tuttum seni, dede.","The rope's coming. Easy... easy... Got you! I've got you, grandad."
D39B_OM_01,"(Rumca, öksürerek) İki kişi tuttu beni. Biri yukarıdan, biri aşağıdan. Hangisi kimdi?","(In Greek, coughing) Two men held me. One from above, one from below. Which was which?"
D39B_GI_HEN,"(Rumca) Sinerji yok! Tavuk yok! Galeriye kaçtı!","(In Greek) Synergy's gone! The chicken's gone! She ran up to the gallery!"
D39B_T_HEN,"Kuşatmanın son gecesinde bir tavuk kovalıyorum. Bunu da yazacağım.","On the last night of the siege I'm chasing a chicken. I'll write that down too."
D39B_N_PHOTO,"Galeriden aşağı bakın, Tolga Bey: mumlar, aileler, kapıda nöbet. Osmanlı nüshasında aynı kapı dışarıdan kaydediliyor.","Look down from the gallery, Mr Tolga: candles, families, a guard at the door. In the Ottoman copy the same door is being recorded from outside."
D39B_OM_02,"(Rumca) Söyle bana, yabancı. İmparator'a ne oldu?","(In Greek) Tell me, stranger. What happened to the Emperor?"
D39B_T_KNOW,"Bilmiyorum.","I don't know."
D39B_EU_KNOW,"(Rumca) Bilmemek dürüst. Bu gece dürüst olan az.","(In Greek) Not knowing is honest. There's little honesty about tonight."
D39B_T_WALL,"Surda, adamlarının yanında düştü diyorlar.","They say he fell on the wall, beside his men."
D39B_EU_WALL,"(Rumca) Öyleyse onu orada anarız. Mezarı olmasa da.","(In Greek) Then we'll remember him there. Even without a grave."
D39B_T_WRITE,"Kimse bilmiyor. Ben de öyle yazacağım.","Nobody knows. That's what I'll write."
D39B_EU_WRITE,"(Rumca) Yaz. Yanlış bir şey yazmaktansa boş bırakmak iyidir.","(In Greek) Write it. Better to leave it blank than to write something false."
D39B_NK_END,"Casus. Annem burada, kuzenim burada, tavuk burada. Şehir gitti. Ama bunlar burada.","Spy. My mother's here, my cousin's here, the chicken's here. The city's gone. But these are here."
D39B_N_END,"Kaydedildi. 29 Mayıs gecesi, Petrion, Bizans nüshası. Yarın sabah şehirde başka işler var. İnsanlar saklandıkları yerlerden çıkacak.","Recorded. The night of 29 May, Petrion, the Byzantine copy. Tomorrow morning there's other work in the city. People will come out of where they've been hiding."
```

### 10.6 Co-op bağlantısı (39o ⟷ 39b, aynı harita `Petrion`)

**Kullanıcının örneği:** 39o'da Osmanlı sancak yarışını, 39b'de Bizans aileleri kiliseye taşımayı oynar; ikisi aynı
yağmacı zaman çizelgesine karşı yarışır.

| t / faz | Olay | Yön | Etki |
|---|---|---|---|
| Faz 1 ⟷ 39o faz 1 | `39.flag(door, owner)` | O→B, NPC→ikisi | **Ortak kapılar:** Osmanlı'nın diktiği Sultan sancağı Bizans'ın ekranında o kapıyı "emanet" yapar (aile evde kalır, Bizans'ın işi azalır). Yağmacının sancağı iki ekranda aynı anda belirir: Osmanlı'ya "kapı kaybedildi", Bizans'a "aileyi çıkar". Bizans'ın taşıdığı ailenin evi boşalır: Osmanlı'nın listesindeki o kapıya sancak dikmek yine sayılır ama ipucu `D39O_TW_EMPTY` ("Bu ev boş; aile kilisede") bark'ı gelir. Ortak sayaç ekranın üstünde: "kapı 6/6 · aile 9/9". |
| Faz 1 ⟷ 39o faz 1 | `39.roof_route` | ortak | Damlar ikisinin de kestirmesidir; paradoks mesafesi dam yolunda iki oyuncunun aynı anda geçmesini engeller (biri bekler). Bu, ikisini birbirine **yol vermeye** zorlar: bilerek kurulmuş bir küçük işbirliği anı. |
| Faz 2 ⟷ 39o faz 2 | `39.door_hp(v)`, `39.brace(beat)`, `39.tezkire`, `39.struggle` | ortak | **Kapı çubuğu ortak.** Osmanlı dışarıda tezkire gösterip çavuşu getirirken Bizans içeriden kama çakar ve omuz verir; ikisinin etkileri toplanır (Bizans'ın kaması düşüşü yavaşlatır, Osmanlı'nın tezkiresi durdurur). Osmanlı balta sapında çekişirken (39o faz 2d) Bizans'ın omzu çekişmenin yeşil penceresini 0,1 sn genişletir. İkisi birbirini görmez (kapı arada). |
| Faz 3 ⟷ 39o faz 3 | `39.bucket`, `39.rope(tension)`, `39.catch` | ortak | **Yukarıdan ve aşağıdan:** Osmanlı cumbadan girer, dumanda Theodoros'u bulur, iple indirir (39o); Bizans kuyudan kova çeker (her kova Osmanlı'nın çatı sayacına +3 sn) ve ipi aşağıda karşılar. İpin gerilimi iki tarafın `BalanceMeter`'ının ortalamasıdır: biri sıkı biri gevşek tutarsa ibre ortaya çekilir. Adam yere değdiği an iki oyuncu 6 m arayla (pencere ve avlu) **göz göze** gelir: `D39_COOP_T_ROPE_O` / `_B`. |
| Faz 4 ⟷ 39o faz 4 | `39.photo`, `39.emperor(choice)` | ortak | Aynı kapı, iki taraftan (dışarıdan nöbetçi, içeriden mumlar): ±3 sn → **çift kayıt**. İki tarafın İmparator cevabı aynıysa Nihat bir satır ekler (`D39_COOP_N_SAME`); farklıysa hiçbir şey demez. |

```csv
D39O_TW_EMPTY,"(Rumca) Bu ev boş. Aile kilisede.","(In Greek) This house is empty. The family's in the church."
D39_COOP_T_ROPE_O,"Aşağıda biri tuttu. Kukuletalı. Teşekkür etmek isterdim ama Büro mesafesi.","Someone caught him below. Hooded. I'd like to say thanks, but there's the Bureau distance."
D39_COOP_T_ROPE_B,"Yukarıda biri indirdi. Fesli. Bu gece her şey iki kere oluyor.","Someone lowered him from above. In a fez. Tonight everything happens twice."
D39_COOP_N_SAME,"İki nüsha, aynı cevap. Büro bu satıra dokunmaz; ama iki kere yazıldığını not ediyorum.","Two copies, the same answer. The Bureau doesn't touch that line; but I'm noting that it was written twice."
```

**Ortak düğüm:** `COOP_39_A` "Altı kapı emanette, dokuz aile güvende" (sancak ≥ 5 **ve** `late == 0`) / `COOP_39_B`
"Sokak tam tutulamadı".

---

## 11. Bölüm 31b — "Sarnıç" (30 Mayıs – 1 Haziran 1453)

### 11.1 Tarihî dayanak

- **Fethin ertesi:** Sultan şehri yeniden doldurmak istedi: kaçan ya da saklananları evlerine çağırttı, fidyesiyle azat
  ettiği esirleri şehre yerleştirdi, sonra dışarıdan aileler getirtti (**K**; çağrı **D**'de de geçer). İlk subaşı Süleyman
  Bey (**AP**). 31o'nun tellalı bu çağrıyı ilan eder; bu bölüm çağrıyı **duyan** taraftır.
- **Yangın ve çöküş:** söndürülmemiş yangınlar ve çökük evler 29 Mayıs'ın sonucudur (**K**, **D**). 31o'nun yanık evi
  (kurgu) bu bölümde alttan oynanır.
- **Sarnıçta saklananlar (kurgu):** şehrin altında yüzlerce sarnıç vardı (gerçek); bir mahallenin ailelerinin bir sarnıçta
  saklanması oyun kurgusudur. Rivayete göre o günlerde kimi insanlar sarnıçlarda ve mahzenlerde günlerce saklandı; bölüm
  bunu **rivayet** olarak anar, kaynak göstermez.
- **Galata'ya geçenler:** şehir düştükten sonra kimi Rumlar ve Latinler Galata'ya geçti; Galata'nın ahitnamesi 1 Haziran'da
  okundu (27; **R**). Niko'nun kuzeninin ailesinin Galata'ya geçmesi **(kurgu)**, 27'ye bağ.
- **Ayasofya'da ilk cuma** (1 Haziran, **TB**, **AP**) ve **ahşap şerefe** (31o, kurgu): bu bölümde yalnız sudan, uzaktan
  görünür; ezan duyulur.
- Bölüm esaret, fidye ve ayrılıkları **göstermez**; Nihat bir cümleyle söyler.

### 11.2 Yer ve sistemler

Üç aşama, 31o'nun düzeni gibi (biri kurulurken öbürü silinir):

1. **30 Mayıs, cadde ve yanık ev:** 31o'nun `FallenCity` kurulumu (gündüz, Kadri'nin kazanı, yanık ev, saray cephesi).
   **Ek:** yanık evin **zemin katı**: kapı molozla kapalı; molozun içinden 4 m'lik **sürünme yolu** (21o'nun tünel kazısı
   kodu: kaz, E basılı; destek koy, E), içeride devrik kirişin **alt** ucu (31o faz 1c'deki kirişin öbür ucu).
2. **30 Mayıs öğleden sonra, sarnıç:** yeni küçük seviye `scripts/level/cistern.gd` (`Cistern`, ≈ 250 satır): 6×8 sütunlu
   tuğla tonozlu sarnıç (Binbirdirek benzeri, küçük), diz boyu su (yürüme %60), sütun başlıklarında yankı, tek giriş:
   yarısı yıkık taş merdiven (6 m), üstünde bir delik ve ışık huzmesi. Karanlık; Tolga'nın kandili (yağ sayacı).
3. **31 Mayıs, dönüş yolu:** `FallenCity`'nin cadde parçası + bir yan sokak (`ByzCity._house` ×6, ikisi çökük; moloz
   tepeleri, bir dam yolu) ve Eudokia'nın komşusunun evi (üst kat döşemesi yarı çökmüş).
4. **1 Haziran sabahı, Haliç:** 38b'nin `Horn` suyu ve kayığı; karşıda Galata (`GalataView`), arkada şehrin silueti ve
   Ayasofya (31o'nun güneybatı payandasındaki ahşap şerefe uzaktan görünür).

- **Yeniden kullanılan:** 21o kaz + destek, 31o'nun kiriş kaldırma (RowMeter, iki uçtan), `_drop_stone` (köz, sıva),
  `Traversal`, görünür ip ve düğüm (ip merdiven), `BalanceMeter` (ip merdiven, kiriş, kayık), 21o'nun dumanı (sarnıçta
  değil, zemin katında), 39o'nun "öksürüğü takip et" sesi (sarnıçta yankı ile: "sesi takip et"), `RowMeter` (kürek),
  `TespitCam`, `Lore.scatter(self, "31b")`.
- **Süre hedefi:** 12–13 dk; durdurulan konuşma ≤ 2,5 dk.

### 11.3 Fazlar

| Faz | Gün | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Alttan | 30 Mayıs sabahı, **3 dk köz sayacı** (31o ile aynı sayaç) | `UI_OBJ31B_DIG`, `UI_OBJ31B_PROP`, `UI_OBJ31B_LIFT` | Niko: "Komşunun çocuğu içeride!" Yanık evin kapısı moloz. (a) **Kaz** (E basılı) ve her 1 m'de **destek koy** (E): destek konmadan kazmaya devam edersen tavan tozar, 2 sn sonra çöker (−20 can, 1 m geri). (b) İçeride duman (21o): eğil (C). Devrik kirişin altında bir çocuk (Zoe) ve bir **azap** (yaralı; 30o/32o'nun azabı). (c) **Kirişi kaldır**: kirişin alt ucuna omuz, RowMeter "hep birlikte" (31o'da üst uçtan Kadri'nin adamı ya da Osmanlı Tolga'sı; 3 iyi vuruş). Tavandan köz yağar (gölge, −15). (d) Azabı ve çocuğu **sürünme yolundan çıkar**: önce çocuk (önden git, o izler), sonra azap (kolundan tut, E basılı, yavaş). | Sayaç biterse tavanın yarısı çöker; Kadri'nin adamları molozu söker, herkes çıkar (yaralı ama sağ), −1. |
| 2. Sarnıç | 30 Mayıs öğleden sonra | `UI_OBJ31B_LISTEN`, `UI_OBJ31B_LAMP`, `UI_OBJ31B_LADDER` | Tellalın çağrısı (31o'nun tellalı): saklananlar evlerine dönebilir. Eudokia: "Komşular sarnıçta." **Kandil yağı 3 dk.** (a) Yarı yıkık taş merdivenden **in** (son 2 m serbest tırmanma, ıslak taş). (b) Karanlıkta **sesi takip et**: iki aile sütunların arasında (yankı yön değiştirir; çocuk ıslık çalar, 3 sn'de bir). Diz boyu su; bir yerde çukur (su göğse kadar, kandil söner riski: kandili yukarı tut, E basılı, yavaş). (c) Merdivenin yıkık kısmına **ip merdiven** kur: üstteki demir halkaya ipi at (nişan + E), tırman, üç **düğüm** (zamanlı E), sal. (d) Aileler sırayla tırmanırken ip merdiveni **alttan gergin tut** (`BalanceMeter`; tırmanan her kişi ibreyi iter). **8 kişi.** | Kandil sönerse karanlık: yalnız ses (ıslık) ve ışık huzmesi; yağ biterse aileler Niko'nun sesine yürür (yavaş), −1. |
| 3. Dönüş | 31 Mayıs | `UI_OBJ31B_ESCORT`, `UI_OBJ31B_PAPER`, `UI_OBJ31B_FLOOR` | Eudokia'nın komşu ailesini evine götür. (a) **Moloz tepeleri**: yaşlıya el ver (39b), çöken bir sokağı **dam yolundan** aş (Tolga önden tırmanır, ip sarkıtır, aile ipten tutunarak çıkar). (b) Evin kapısında bir askerin 29 Mayıs'ta diktiği **sancak**; kapıda nöbetçi yok, ev boş. Subaşının adamlarından birine evin sahibini göster: **pusula** (39o'nun çavuşunun emanet pusulası, Eudokia'da; eşya gösterme) + Tolga'nın tercümesi (kısa seçim: `UI_C31B_PLAIN` / `UI_C31B_POLITE`, ikisi de işe yarar, yalnız bark değişir). Sancak kaldırılır. (c) Üst katta ailenin **ikonası ve belgeleri**: yarı çökük döşemede **kirişten kirişe** yürü (`BalanceMeter`; iki kiriş çatırdar), tavandan sıva düşer (gölge). | Döşemeden düşersen alt kata −20 can, merdivenden yeniden. |
| 4. Kayık | 1 Haziran sabahı | `UI_OBJ31B_ROW`, `UI_OBJ31B_PHOTO` | Niko'nun kuzeni ailesiyle Galata'ya geçmek istiyor (27'ye bağ). Kayık: **RowMeter** 250 m Haliç'in karşısına; akıntı ve iki büyük kadırganın **dümen suyu** (dalga uyarısı: 1 sn önce, A/D ile burnu dalgaya çevir; yoksa kayık su alır). Yarı yolda Ayasofya'dan **ezan** duyulur: **Tespit:** sudan Ayasofya ve ahşap şerefe (pencere 40 sn; 31o faz 3'ün tamamlandığı an). Galata rıhtımına yanaş: halatı babaya sar (34b faz 1a). | Kare kaçarsa not. |

**Animasyon ve görsel geri bildirim**
- **Faz 1:** kazma toprağa girerken toz; destek kalası iki tokmak vuruşuyla oturur; çökmede tavandan moloz yağar, toz bulutu;
  kirişin alt ucuna Tolga omuz verir, üst uçta (görünmeyen yerde) biri iter: kiriş her iyi vuruşta 8 cm kalkar, köz düşer;
  çocuk sürünme yolunda Tolga'nın ayaklarını izler (diz ve dirsek animasyonu); azap topallar.
- **Faz 2:** kandil alevi Tolga'nın elinde, sütunlarda gölgeler döner; su halkaları her adımda; ıslık yankısı (ses yönü
  sütunlardan seker); çukurda kandil başın üstünde, su göğüste; ip halkadan sarkar, düğümlerin sarımları görünür; aile
  ipten tırmanırken ip gerilir ve titrer; yukarıdan ışık huzmesinde toz.
- **Faz 3:** moloz tepesinde taşlar ayak altında kayar; dam kenarından sarkan ip; kapıdaki sancak kaldırılınca direk
  halkadan çıkar, kumaş katlanır; döşeme kirişleri çatırdar, aradaki boşluktan alt kat görünür; ikona Tolga'nın kolunun
  altında, belgeler bir bohçada.
- **Faz 4:** kayıkta altı kişi (yolcular kayığın çocuğu); kadırganın dümen suyu iki dalga hâlinde gelir; burun dalgaya dönünce
  kayık bir kalkıp iner; ezanda Haliç'teki martılar kalkar (`Gulls`); Galata rıhtımında halat babaya.
- **Zemin:** sarnıçta su yüzü y −0,5 (yürüme yüzü y −1,0), figüranlar su içinde dize kadar (gömülme değil: bacak su yüzünün
  altında görünür, `Water` kırılma); `FallenCity` molozu `ground_y`.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **31B.1** Hepsi zamanında | köz sayacı bitmeden **ve** kandil sönmeden 8/8 **ve** düşüş ≤ 1 | `FLOW_31B_1` |
| **31B.2** Başkaları yetişti | aksi hâlde | `FLOW_31B_2` |

`--autotest[=late]` (varsayılan 31B.1; `=late`: bot destek koymadan kazar, sarnıçta çukurda kandili indirir). Akış şeması:
`FLOW31B_BELOW` → `FLOW31B_CISTERN` → `FLOW31B_HOME` → `FLOW31B_CROSSING` → {`31B.1`, `31B.2`}. 31b'den sonra 27
(Galata) gelir; 27'nin Bizans dalında Niko'nun kuzeni rıhtımda tek bark söyler (`D27_NKC_01`, önerilir).

### 11.4 Konuşanlar

Var olan / yeni (§10): `SPK_NIKO`, `SPK_EUDOKIA`, `SPK_GIRL` (Zoe), `SPK_AZAP`, `SPK_KADRI`, `SPK_HERALD`, `SPK_SOLDIER`
(subaşının adamı). Yeni: `SPK_COUSIN` (Niko'nun kuzeni Stavros, kayıkçı; kurgu). Koşullu: 3b seçimine göre `PLAIN` /
`POLITE` çifti.

| Anahtar | Konuşan | Tür |
|---|---|---|
| `D31B_N_01` | SPK_NIHAT | say |
| `D31B_T_01` | SPK_TOLGA | say |
| `D31B_NK_01` | SPK_NIKO | bark |
| `D31B_T_DIG` | SPK_TOLGA | bark |
| `D31B_NK_PROP` | SPK_NIKO | bark |
| `D31B_GI_01` | SPK_GIRL | bark |
| `D31B_AZ_01` | SPK_AZAP | bark |
| `D31B_T_LIFT` | SPK_TOLGA | bark |
| `D31B_KA_ABOVE` | SPK_KADRI | bark |
| `D31B_AZ_02` | SPK_AZAP | say |
| `D31B_T_AZ` | SPK_TOLGA | say |
| `D31B_HE_01` | SPK_HERALD | bark |
| `D31B_EU_01` | SPK_EUDOKIA | say |
| `D31B_T_DARK` | SPK_TOLGA | bark |
| `D31B_GI_WHISTLE` | SPK_GIRL | bark |
| `D31B_T_LAMP` | SPK_TOLGA | bark |
| `D31B_NK_ROPE` | SPK_NIKO | bark |
| `D31B_EU_CLIMB` | SPK_EUDOKIA | bark |
| `D31B_T_ESCORT` | SPK_TOLGA | bark |
| `D31B_SO_01` | SPK_SOLDIER | say |
| `D31B_T_PLAIN` | SPK_TOLGA | say |
| `D31B_SO_PLAIN` | SPK_SOLDIER | say |
| `D31B_T_POLITE` | SPK_TOLGA | say |
| `D31B_SO_POLITE` | SPK_SOLDIER | say |
| `D31B_T_FLOOR` | SPK_TOLGA | bark |
| `D31B_CO_01` | SPK_COUSIN | say |
| `D31B_T_CO1` | SPK_TOLGA | say |
| `D31B_CO_WAKE` | SPK_COUSIN | bark |
| `D31B_N_PHOTO` | SPK_NIHAT | bark |
| `D31B_T_EZAN` | SPK_TOLGA | bark |
| `D31B_NK_END` | SPK_NIKO | say |
| `D31B_T_END` | SPK_TOLGA | say |
| `D31B_N_END` | SPK_NIHAT | say |

### 11.5 Metinler

```csv
UI_CH31B_TITLE,"BÖLÜM {N} — SARNIÇ","CHAPTER {N} — THE CISTERN"
UI_CH31B_SUB,"30 Mayıs – 1 Haziran 1453 · Yanık ev, sarnıç, Haliç","30 May – 1 June 1453 · A burnt house, a cistern, the Golden Horn"
UI_FLOW31B_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: SARNIÇ","FLOWCHART — CHAPTER {N}: THE CISTERN"
SPK_COUSIN,"Kayıkçı Stavros","Stavros the boatman"
UI_OBJ31B_DIG,"Molozu kaz (E basılı) · köz: %d sn","Dig through the rubble (hold E) · embers: %d s"
UI_OBJ31B_PROP,"Her metrede destek koy (E)","Set a prop every metre (E)"
UI_OBJ31B_LIFT,"Kirişin alt ucuna omuz ver: yeşilde Space","Put your shoulder to the lower end of the beam: Space on the green"
UI_OBJ31B_LISTEN,"Karanlıkta sesi takip et","Follow the sound in the dark"
UI_OBJ31B_LAMP,"Kandili yukarıda tut (E basılı) · yağ: %d sn","Hold the lamp up (hold E) · oil: %d s"
UI_OBJ31B_LADDER,"İp merdiveni kur, düğümle, alttan gergin tut · %d/%d","Rig the rope ladder, knot it, hold it taut from below · %d/%d"
UI_OBJ31B_ESCORT,"Aileyi evine götür: molozdan ve damdan","Take the family home: over the rubble and the rooftops"
UI_OBJ31B_PAPER,"Kapıdaki sancak: pusulayı göster, çevir","The banner on the door: show the note, translate"
UI_OBJ31B_FLOOR,"Çökük döşemede kirişten kirişe: ikonayı al","Beam to beam across the broken floor: fetch the icon"
UI_OBJ31B_ROW,"Galata'ya kürek çek · dümen suyunda burnu dalgaya çevir (A/D)","Row to Galata · turn the bow into the wake (A/D)"
UI_OBJ31B_PHOTO,"Tespit et: sudan Ayasofya ve ahşap şerefe","Record: Hagia Sophia and the wooden gallery, from the water"
UI_C31B_PLAIN,"'Ev bu ailenin. Pusula burada.'","'The house belongs to this family. Here is the note.'"
UI_C31B_POLITE,"'Efendi, izin verirseniz: ev bu ailenin; çavuşun pusulası burada.'","'Sir, if you'll allow me: the house is this family's; here is the çavuş's note.'"
FLOW31B_BELOW,"Yanık ev, alttan","The burnt house, from below"
FLOW31B_CISTERN,"Sarnıçta saklananlar","The people hiding in the cistern"
FLOW31B_HOME,"Eve dönüş","The way home"
FLOW31B_CROSSING,"Galata'ya geçiş, ezan","The crossing to Galata, the call to prayer"
FLOW_31B_1,"Hepsi zamanında","Everyone in time"
FLOW_31B_2,"Başkaları yetişti","Others got there"
UI_CH31B_STATS,"Köz: %d sn kala   ·   Sarnıç: %d/%d   ·   Düşüş: %d   ·   Dosya: %d/%d sayfa","Embers: %d s to spare   ·   Cistern: %d/%d   ·   Falls: %d   ·   File: %d/%d pages"
SIEGE_DATE_31B,"30 Mayıs – 1 Haziran 1453","30 May – 1 June 1453"
SIEGE_EV_31B,"Fethin ertesi. Sultan saklananları evlerine çağırır. Kimi aileler evine döner, kimi Galata'ya geçer. 1 Haziran'da Ayasofya'da ilk cuma.","The days after the conquest. The Sultan calls those in hiding back to their homes. Some families return home, some cross to Galata. On 1 June, the first Friday prayer in Hagia Sophia."
SIEGE_NOTE_31B_1,"Yanık evin altından bir çocuk ve bir azap çıkardım. Sarnıçtan sekiz kişi. Bir aileyi evine götürdüm, bir ikonayı kirişlerden geçirdim. Bir aileyi Galata'ya geçirdim. Ezanı sudan duydum. — T.","From under the burnt house I got out a child and an azap. Eight people out of the cistern. I took one family home and carried an icon across the beams. I rowed another family to Galata. I heard the call to prayer from the water. — T."
SIEGE_NOTE_31B_2,"Kimini ben çıkardım, kimini başkaları. Hasar tespiti: ölçülemez. Kurtarma: kısmi. — T.","Some I got out, some others did. Damage assessment: immeasurable. Rescue: partial. — T."
LORE_31B_1_T,"Sarnıçlar","The cisterns"
LORE_31B_1,"Konstantinopolis'in altında yüzlerce sarnıç vardı: kimi açık havuz, kimi sütunlu tonozlu yeraltı salonu. Şehir suyunu kemerler ve sarnıçlarla taşırdı. Rivayete göre şehir düştüğünde kimileri günlerce bu karanlık salonlarda saklandı.","Beneath Constantinople there were hundreds of cisterns: some open reservoirs, some vaulted underground halls full of columns. The city carried and stored its water through aqueducts and cisterns. Tradition has it that when the city fell, some people hid for days in these dark halls."
LORE_31B_2_T,"Çağrı","The call"
LORE_31B_2,"Kritovoulos'a göre Sultan, şehri yeniden doldurmak için saklanan ya da kaçanları evlerine çağırttı; sonra dışarıdan aileler getirtti. Şehrin ilk subaşısı Süleyman Bey'di.","According to Kritovoulos, the Sultan, wishing to repopulate the city, had those who had hidden or fled called back to their homes; later he brought in families from elsewhere. The city's first governor was Süleyman Bey."
LORE_31B_3_T,"Galata'ya geçenler","Those who crossed to Galata"
LORE_31B_3,"Şehir düştükten sonra kimi Rumlar ve Latinler Haliç'in karşısındaki Galata'ya geçti. 1 Haziran'da Galata'ya verilen ahitname orada yaşayanların canını ve malını güvenceye aldı.","After the city fell some Greeks and Latins crossed the Horn to Galata. The charter granted to Galata on 1 June guaranteed the lives and property of those living there."
```

Replikler:

```csv
D31B_N_01,"Tolga Bey, 30 Mayıs sabahı. Yangınların çoğu söndü, bazıları hâlâ için için yanıyor. Bugün şehirde kimse savaşmıyor. Bugün herkes birini arıyor.","Mr Tolga, the morning of 30 May. Most of the fires are out; some are still smouldering. Today nobody in the city is fighting. Today everyone is looking for someone."
D31B_T_01,"Arama kurtarma. Bunun için bir poliçe yok. Olmalıydı.","Search and rescue. There's no policy for this. There should be."
D31B_NK_01,"Casus! Komşunun kızı içeride! Kapı molozun altında!","Spy! The neighbour's girl is inside! The door's under the rubble!"
D31B_T_DIG,"Kazıyorum. Bir metre, bir destek. Sigortacılar buna 'yapısal risk' der; ben şimdi buna 'tavan' diyorum.","I'm digging. One metre, one prop. Insurers call this 'structural risk'; right now I'm calling it 'the ceiling'."
D31B_NK_PROP,"Destek! Desteksiz kazma! Tavan sana kızar!","A prop! Don't dig without a prop! The ceiling will get angry with you!"
D31B_GI_01,"(Rumca) Buradayım! Yanımda bir asker var, ayağı sıkıştı!","(In Greek) I'm here! There's a soldier with me, his leg's stuck!"
D31B_AZ_01,"(Türkçe) Çocuk korkmasın. Ben bir şey yapmam. Ayağım kirişin altında.","(In Turkish) Don't let the child be scared. I won't do anything. My leg's under the beam."
D31B_T_LIFT,"Ben alttan, yukarıdaki üstten. Bir kiriş, iki omuz. Hep birlikte!","Me from below, whoever's up there from above. One beam, two shoulders. All together!"
D31B_KA_ABOVE,"(Yukarıdan) Hey-yap! Bir daha! Kalkıyor!","(From above) Heave! Again! It's lifting!"
D31B_AZ_02,"(Türkçe) Sen... Blakherna'da beni sırtında taşıyan kâtibe benziyorsun. Ama kukuletalısın. Olsun. Allah razı olsun.","(In Turkish) You... look like the clerk who carried me on his back at Blachernae. But you're wearing a hood. Never mind. God bless you."
D31B_T_AZ,"Benzerim çok, kardeşim. Bugünlerde iki tane.","I've got a lot of lookalikes, brother. Two, these days."
D31B_HE_01,"(Uzaktan) Saklananlar evlerine dönsün! Sultan'ın emri: evine dönen evinde oturur!","(Far off) Let those in hiding return to their homes! The Sultan's order: whoever returns home may stay in his home!"
D31B_EU_01,"(Rumca) Duydun mu? Komşularımız sarnıçta. Üç gündür. Kandil al. Merdiven yarı yıkık.","(In Greek) Did you hear? Our neighbours are in the cistern. Three days now. Take a lamp. The stairs are half gone."
D31B_T_DARK,"Karanlık, su, sütun. Sütunlar sayılmıyor, ses her yerden geliyor.","Dark, water, columns. Too many columns to count, and the sound comes from everywhere."
D31B_GI_WHISTLE,"(Uzaktan, ıslık)","(Far off, a whistle)"
D31B_T_LAMP,"Kandil yukarıda. Su göğsümde. Kandil sönerse ben de sönerim.","The lamp's up high. The water's up to my chest. If the lamp goes out, so do I."
D31B_NK_ROPE,"(Yukarıdan) İp tamam! Gergin tut, ben yukarıdan çekiyorum!","(From above) The rope's fine! Hold it taut, I'm pulling from the top!"
D31B_EU_CLIMB,"(Rumca) Birer birer. Çocuklar önce. Işığa bakmayın, ipe bakın.","(In Greek) One at a time. Children first. Don't look at the light, look at the rope."
D31B_T_ESCORT,"Moloz, dam, moloz. Bu şehirde artık yol yok; sadece güzergâh var.","Rubble, rooftop, rubble. There are no streets in this city any more; only routes."
D31B_SO_01,"(Türkçe) Bu evde sancak var. Kimin evi? Sen kimsin?","(In Turkish) There's a banner on this house. Whose house is it? Who are you?"
D31B_T_PLAIN,"Ev bu ailenin. Pusula burada; Petrion'un çavuşunun mührü.","The house belongs to this family. Here's the note; the seal of the çavuş of Petrion."
D31B_SO_PLAIN,"Mühür doğru. ...Sancağı ben kaldırırım. Subaşı böyle istiyor.","The seal's genuine. ...I'll take the banner down. That's how the governor wants it."
D31B_T_POLITE,"Efendi, izin verirseniz: ev bu ailenin; çavuşun pusulası burada.","Sir, if you'll allow me: the house is this family's; here is the çavuş's note."
D31B_SO_POLITE,"İzin benim değil, Sultan'ın. Ama mühür doğru. Kaldırıyorum.","The permission isn't mine, it's the Sultan's. But the seal's genuine. I'm taking it down."
D31B_T_FLOOR,"Bir kiriş, bir boşluk, bir kiriş. Bu evde yürümek değil, karar vermek gerekiyor.","A beam, a gap, a beam. In this house you don't walk, you make decisions."
D31B_CO_01,"(Rumca) Ben Stavros, Niko'nun kuzeni. Karım Galata'da kalmak istiyor; orada akrabası var. Kayık hazır. Sen kürek çeker misin? Niko çekmez; Niko annesinin yanında.","(In Greek) I'm Stavros, Niko's cousin. My wife wants to stay in Galata; she has family there. The boat's ready. Will you row? Niko won't; Niko's staying with his mother."
D31B_T_CO1,"Çekerim. Bu kayığı tanıyorum. Dün öğlen altı kişiyle zincire kadar götürdüm.","I'll row. I know this boat. Yesterday at noon I took it to the boom with six people aboard."
D31B_CO_WAKE,"Dalga! Burnunu dalgaya çevir!","A wave! Turn her bow into it!"
D31B_N_PHOTO,"Ayasofya, Tolga Bey. Payandanın üstünde ahşap bir şerefe. Osmanlı nüshasında biri onu bu sabah bağladı. Bir kare.","Hagia Sophia, Mr Tolga. A wooden gallery on top of the buttress. In the Ottoman copy someone tied it up there this morning. One frame."
D31B_T_EZAN,"Ezan. Sudan, Galata'ya giderken, Ayasofya'dan. Bunu kaydedecek bir form yok.","The call to prayer. From the water, on the way to Galata, from Hagia Sophia. There's no form to record this."
D31B_NK_END,"(Rıhtımdan, el sallayarak, uzaktan) Casus! Tavuk bende! Annem de bende! Sen nereye gidersen git, dön bir gün!","(From the quay, waving, far off) Spy! I've got the chicken! I've got my mother! Wherever you go, come back one day!"
D31B_T_END,"Dönerim, Niko. Dosya kapandıktan sonra.","I'll come back, Niko. After the file's closed."
D31B_N_END,"Kaydedildi. 30 Mayıs – 1 Haziran, Bizans nüshası. Kimi saklandığı yerden çıktı, kimi çıkamadı; kimi fidyeyle kurtuldu, kimi esir gitti. Kaynaklar bunların hepsini yazar. Bugün Galata'da bir ahitname okunacak.","Recorded. 30 May – 1 June, the Byzantine copy. Some came out of their hiding places, some did not; some were ransomed, some were taken away as captives. The sources record all of it. Today a charter will be read in Galata."
```

### 11.6 Co-op bağlantısı (31o ⟷ 31b, kısmen aynı harita)

| t / faz | Olay | Yön | Etki |
|---|---|---|---|
| Faz 1 ⟷ 31o faz 1 | `31.dig`, `31.lift(side, beat)`, `31.ember` | ortak | **Bir kiriş, iki uç:** Osmanlı harap saray cephesinden tırmanıp kömürleşmiş kirişte yürüyerek odaya **yukarıdan** girer (31o), Bizans molozu kazıp **alttan** girer. Köz sayacı ortaktır. Kiriş kaldırma iki tarafın RowMeter'ıdır: iki oyuncu aynı vuruşta yeşili tutturursa kiriş iki kat kalkar (2 vuruş yeter); tek taraf iyi vurursa 3 vuruş. Kiriş uçları 4 m arayla: paradoks yok, ama iki Tolga birbirini dumanın içinden görür (**göz göze**, `D_COOP_T_MEET_2`). Çocuğu Osmanlı iple pencereden indirir (31o 1d) **ya da** Bizans sürünme yolundan çıkarır: önce kim yetişirse; azabı Bizans çıkarır (azabın repliği `D31B_AZ_02` bu yüzden yazıldı). |
| Faz 2 ⟷ 31o faz 1 sonu | `31.herald` | O→B | 31o'daki tellalın ilanı Bizans'ın sarnıç fazını başlatır (aynı ses; Bizans uzaktan duyar). |
| Faz 2–3 ⟷ 31o faz 2 | — | — | Uzak: Osmanlı Eyüp'te (rivayet), Bizans sarnıçta ve dönüş yolunda. Ortak saat yalnız; iki tarafın sayaçları (gün batımı / kandil yağı) aynı anda biter. Nihat köprüsü: `D_COOP_N_BRIDGE_*`. |
| Faz 4 ⟷ 31o faz 3–4 | `31.minaret_done`, `31.ezan`, `31.photo`, `31.wave` | O→B, ortak | Osmanlı'nın şerefe iskelesini bitirdiği an (31o faz 3 sonu) Bizans'ın ufkunda şerefe tamamlanır; ezan iki tarafta aynı anda. Osmanlı platformdan Haliç'e bakarsa Bizans'ın kayığını görür; iki oyuncu da **el sallama** (E) yaparsa ortak düğüm. Tespitler farklı hedeftir (Osmanlı: saflar; Bizans: şerefe sudan): `UI_COOP_PAIR` benzeri "AYNI SABAH" (`UI_COOP_MORNING`). |

```csv
UI_COOP_MORNING,"AYNI SABAH","THE SAME MORNING"
```

**Ortak düğüm:** `COOP_31_A` "Haliç'in iki yakasından selam" (iki el sallama) / `COOP_31_B` "Biri baktı, öbürü görmedi".

---

## 12. Var olan çiftlerin co-op bağlantıları

Bu çiftlerin iki sahnesi de var; aşağıdaki tablolar yalnız co-op'ta eklenen olayları yazar. Her satırın gölge varsayılanı
bugünkü tek kişilik davranıştır (kod değişikliği: olay kaynağını `Coop.on` ile değiştirmek). Ortak görsel/zarar kuralları
§2'deki gibidir.

### 12.1 Bölüm 29 — Zincirin Önü (20 Nisan) · 29o ⟷ 29 · aynı harita (`SeaBattle`)

Osmanlı Baltaoğlu'nun kadırgasında (kanca, ipten tırmanma, tüfek); Bizans Cattaneo'nun karakasında (ip kesme, güverte
düellosu, ateş çömlekleri). İkisi aynı bordanın iki yüzünde: karakanın iskele bordası.

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| 29o faz 2 ⟷ 29 faz 1 | `29.hook(rail_pos)`, `29.cut(rail_pos)` | O→B, B→O | Osmanlı'nın attığı kanca küpeştede Bizans'ın ekranında **kesilecek ip** olur (sahibi Osmanlı). Bizans E basılı keserse (1,2 sn) Osmanlı'nın ipi kopar: 29o'daki "takılan ipi yukarıdakiler keser" artık Bizans'tır. Kesilmeyen ip 6 sn sonra NPC tırmanıcı doğurur (29'un mevcut kuralı). |
| 29o faz 3 ⟷ 29 faz 1–2 | `29.climb(rail_pos)` | O→B | Osmanlı ipten tırmanırken Bizans o ipi kesebilir: Osmanlı kadırgaya düşer (29o'nun tarihî sonu zaten bu; kesilmezse yukarıdan NPC kovası düşürür). Tırmanan Osmanlı 3 m'ye girdiğinde paradoks: Bizans'ın ipe uzanması engellenir, NPC kova devreye girer. |
| 29o faz 5 ⟷ 29 faz 2–3 | `29.aim(target)`, `29.duck_call` | O→B, B→O | Osmanlı'nın tüfek hedefleri güvertedeki **NPC** tayfadır (Bizans hedef listesinde değil). Osmanlı nişan aldığında Bizans'ın ekranında o tayfanın üstünde kırmızı halka; Bizans yakınındaki tayfaya **E: "Eğil!"** derse tayfa çömelir ve atış ıskalar. Osmanlı'nın isabet oranı ile Bizans'ın uyarı sayısı karnelere ayrı ayrı yazılır. |
| 29o faz 4 ⟷ 29 faz 4 | `29.sultan_sea`, `29.photo` | ortak | Sultan atını denize sürer; iki taraf aynı anda görür (Bizans uzaktan, Osmanlı yakından). ±3 sn → **çift kayıt** (`ACH_HORSE_SEA`'nın co-op çifti `ACH_COOP_HORSE`). |
| 29o faz 6 ⟷ 29 faz 5 | `29.wind` | ortak | Akşam rüzgârı ortak saatte gelir; gemiler zincirden girer. |

**Ortak düğüm:** `COOP_29_A` "Bordada iplerin yarısı kesildi" (Bizans'ın kestiği ≥ Osmanlı'nın taktığı / 2) / `COOP_29_B`
"Kancalar bordayı tuttu".

### 12.2 Bölüm 17 — Kundak (28 Nisan gecesi) · 17o ⟷ 17 · aynı harita (`SeaWalls` + Haliç)

Bizans Trevisano'nun kadırgasında kürek çeker, Galata'daki ışığı görür, Coco'nun fustası batınca suya düşenleri çeker.
Osmanlı kıyı toplarında gözler, doldurur, ateş eder; kova zinciriyle yangın söndürür.

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| 17 kürek ⟷ 17o gözcülük | `17.row(beat)` | B→O | Bizans'ın kötü kürek vuruşu **ses** üretir (şapırtı). Her kötü vuruş 17o'da gözcülüğü kolaylaştırır: yaklaşan geminin silueti 2 sn erken belirir. İyi kürekle gemiler geç görünür. "Gizlilik ve tespit" çifti. |
| Işık | `17.light` | ortak | Galata'daki ışık iki tarafta aynı saniyede yanar (tohumlu); iki kare ±3 sn → **çift kayıt**. Kimin yaktığını oyun yine söylemez. |
| 17o atış ⟷ 17 batış | `17.shot(pos)`, `17.sink` | O→B | Osmanlı'nın top atışları gerçek düşüş noktalarıyla Bizans'ın etrafına iner (Bizans'ın kadırgasına isabet yok: GunDrill öngörüsü Bizans gemisinin 10 m çevresini yasaklı bölge sayar). Coco'nun fustasının batışı Osmanlı'nın isabetiyle tetiklenir (ıskalarsa gölge topçu batırır, tarih). Batış anı Bizans'ın kurtarma süresini başlatır. |
| 17 kurtarma ⟷ 17o yangın | `17.pot`, `17.rescued(n)` | B→O, O→B | Trevisano'nun adamlarının attığı ateş çömleği (NPC) demirli kadırgaya düşer: 17o'nun kova zinciri başlar. Osmanlı yangını hızlı söndürürse (17O.1) kıyı topları kurtarma bölgesine dönmez; geç söndürürse (17O.2) bir top daha ateş eder ve Bizans'ın kurtarma süresinden 5 sn düşer (atış halkası suda). |

**Ortak düğüm:** `COOP_17_A` "Su ve ateş bir gecede söndü" (17.1 **ve** 17O.1) / `COOP_17_B` "Gece uzun sürdü".

### 12.3 Bölüm 18 — Fıçı Köprü (Mayıs başı) · 18 ⟷ 18b · aynı harita (`Horn`)

Osmanlı köprüyü kurar (fıçı yuvarla, halatla bağla, kalas döşe); Bizans Haliç surundan küçük topla köprüye ateş eder
(barut seçimi; çok barut kendi surunu çatlatır).

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| Her bölüm | `18.section(n)`, `18.knot(ok)` | O→B | Osmanlı'nın bitirdiği her köprü bölümü Bizans'ın ekranında suya uzanır; eğri bağlar köprüde görünür kıvrım. |
| 18b atış | `18.shot(pos, charge)` | B→O | Bizans'ın atışı köprünün yakınına düşerse (≤ 4 m) **en son bağlanan halatın bir bağı çözülür**: Osmanlı geri dönüp yeniden bağlar (zamanlı E). Atıştan 1,5 sn önce Osmanlı'nın ekranında surda duman ve suda halka (§2.3). Doğrudan isabette fıçı çifti parçalanır, Osmanlı'nın sırası bir fıçı geri gider. |
| Köprüdeki top | `18.bridge_gun` | O→B | Köprü bitip top çekildiğinde Osmanlı bir kez ateş eder (yeni küçük adım: 18'e `GunDrill` tek atış, co-op'ta açık): Bizans'ın kulesinde çatlak aşaması +1 (18b'nin "geri tepme" çatlağıyla aynı görsel). |

**Ortak düğüm:** `COOP_18_A` "Köprü ayakta, sur çatladı" / `COOP_18_B` "Köprü eğri, sur sağlam".

### 12.4 Bölüm 19 — Brigantin / Devriye (3 Mayıs gecesi → 23 Mayıs) · 19o ⟷ 19 · aynı harita

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| Çıkış öncesi (co-op ek faz, 30 sn) | `19.disguise(n)` | B→O | Bizans brigantinde üç tayfanın sarığını **yeniden sarar** (zamanlı E, üç kez). Her düzeltilen sarık 19o'daki ipuçlarından birini kaldırır (19o: "sarıklar ters sarılmış"). Kalan ipucu sayısı Osmanlı'nın görebileceği işaret sayısıdır. |
| Yanaşma | `19.question(q)`, `19.answer(choice)` | O→B, B→O | **Soru ve cevap:** soruyu devriye reisi Türkçe sorar; Osmanlı Tolga'sı kürekte dinler, Bizans Tolga'sı brigantinin "tercümanı" olarak cevap verir (19'un mevcut seçimleri). Bizans'ın seçtiği cevap Osmanlı'nın ekranında altyazıdır; Osmanlı'nın "söyle / sus" seçimi bu cevaba ve kalan ipuçlarına göre reisin inanıp inanmamasını değiştirmez (tarih: brigantin geçer), yalnız reisin bark'ını değiştirir. İki Tolga iki teknede 3,5 m: paradoks göstergesi %40'a çıkar (yanaşma kısa tutulur, ≤ 25 sn). |
| 23 Mayıs dönüş | `19.chase(dist)`, `19.aim`, `19.shield` | ortak | Kovalamaca: iki tarafın RowMeter'ı aynı mesafe çubuğunu iter (Osmanlı kapatır, Bizans açar). Osmanlı'nın tüfek atışları brigantinin tayfasına (NPC); Bizans nişan halkasını gördüğünde **C: hasır kalkanı kaldır** ve kalkanın arkasındaki iki tayfa korunur. Brigantin her durumda zincirin ardına girer. |

**Ortak düğüm:** `COOP_19_A` "Reis inanmadı" (ipucu ≤ 1) / `COOP_19_B` "Reis kuşkulandı".

### 12.5 Bölüm 20 — Gedik (7 Mayıs) · 20o ⟷ 20 · aynı harita

Osmanlı gündüz Urban'ın topunda; gece hücumda gediğe gider. Bizans gece gediği kapatır.

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| Gündüz (co-op ek faz, Bizans, 2 dk) | `20.smoke`, `20.warn` | O→B, B→O | Bizans iç surda gözcünün yanında: Osmanlı'nın topunda duman görünce **E: "Top!"** (2 sn içinde) → onarım ekibi siper alır (NPC). Uyarılmayan ekip yere düşer, gece işi +1 yük. Osmanlı yağla soğuturken Bizans duvar dibinde ilk fıçıları dizer. |
| Gedik büyüklüğü | `20.hits(n)` | O→B | Osmanlı'nın isabet sayısı gece kapatılacak yük sayısını belirler: 6 + 2 × isabet (en çok 12). 20O.2 (surlar dayandı) ise gece işi 6 yüktür. |
| Gece tüfeği | `20.aim_peek(slot)` | O→B | Osmanlı'nın mazgal hedefleri NPC savunanlardır; Bizans'ın taşıma yolu bu mazgalların altından geçer: nişan halkası belirince Bizans 1 sn içinde yanındaki savunana E ile "Eğil!" diyebilir. |
| Gedik düellosu | `20.duel_start`, `20.duel_end` | ortak | Aynı gedikte iki ayrı şerit (Osmanlı gediğin batı dilinde, Bizans doğu dilinde; 6 m). **Göz göze** anı düellonun ortasında (1 sn). Bizans düelloyu kaybederse (20.3 yolu) Osmanlı'nın şeridine +1 savunan eklenmez; kazanırsa Osmanlı'nın şeridine bir Cenevizli daha gelir. |
| Şafak | `20.photo` | ortak | Bizans'ın tespit karesi "şafakta kapanmış gedik"; Osmanlı'nın akşam karesi "açılan gedik": `UI_COOP_PAIR` ("GECE / SABAH" yerine "AÇILDI / KAPANDI", `UI_COOP_BREACH`). |

```csv
UI_COOP_BREACH,"AÇILDI / KAPANDI","OPENED / CLOSED"
```

**Ortak düğüm:** `COOP_20_A` "Gedik akşam açıldı, şafakta kapandı" (20O.1 **ve** 20.1/20.2) / `COOP_20_B` "Gün ve gece berabere".

### 12.6 Bölüm 30 — Blakherna (12 Mayıs gece yarısı) · 30o ⟷ 30 · aynı harita (`Blachernae`)

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| 30 faz 1 ⟷ 30o faz 1 | `30.runner_hit(team)` | B→O | Bizans'ın tüfek hedefleri merdiven taşıyan **NPC**'lerdir. Osmanlı'nın ekibinden bir taşıyıcı vurulursa (yere düşer, sürünerek geri çekilir; ölüm gösterilmez) Osmanlı'nın taşımasında yük bir kişiye daha düşer: hız −20%, `BalanceMeter` açılır (merdiven sallanır). |
| 30 faz 2 ⟷ 30o faz 2 | `30.ladder_up(id)`, `30.push(id, beat)`, `30.climb(id, h)` | ortak | Osmanlı'nın merdiveni Bizans'ın itebileceği merdivenlerden biridir. **İtme yarışı:** Bizans E basılı iterken Osmanlı tırmanıyorsa ibre Osmanlı'nın yüksekliğine göre ağırlaşır (yukarıdaki ağırlık merdiveni tutar). Merdiven itilirse Osmanlı merdivenle birlikte geri yatar ve hendeğin olmadığı yamaca düşer (−25, yere düşme; 37o'nun tırmanma geri dönüşü yok, 30o'nun mevcut "atıldın" akışı). Kaynar yağ yalnız NPC kazanından (§2.3). |
| 30 faz 3 ⟷ 30o faz 3 | `30.walk_fight` | ortak | Sur yolu dövüşü: iki şerit (kulenin iki yanı). Osmanlı sur yoluna çıkarsa Bizans'ın şeridi ile arasında kule kapısı vardır; göz göze anı kule kapısında. |
| 30 faz 4 ⟷ 30o tespit | `30.emperor`, `30.photo` | ortak | İmparator meşalelerin arasında: aynı hedef, iki taraf → **çift kayıt**. |
| 30o faz 4 | `30.wounded_carry` | O→B | Osmanlı yaralı azabı sırtlayıp çekilirken Bizans'ın ekranında sur dibinde bir kişi yaralı birini taşır; Bizans'ın tüfeği o kişiye nişan alamaz (hedef dışı, imleç gri). |

**Ortak düğüm:** `COOP_30_A` "Merdiven itildi" / `COOP_30_B` "Merdiven tuttu, sur yolunda karşılaşıldı".

### 12.7 Bölüm 21 — Lağım (16 Mayıs) · 21o ⟷ 21 · aynı harita (peribolos + tünel)

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| 21 oynanış 1 ⟷ 21o kazı | `21.dig(pos, rate)` | O→B | **Titreşim gerçek:** Bizans'ın su kaplarındaki dalga genliği Osmanlı'nın o anki kazı hızından ve kazı yüzünün kaba uzaklığından hesaplanır. Osmanlı **yavaş kazabilir** (E basılı yerine E'ye aralıklı bas: hız %50, titreşim %25): gizlilik ve tespit. Bizans'ın kabı bulursa (21.1) Grant karşı lağımı o noktadan başlatır. |
| Karşılaşma | `21.breach`, `21.choice_b`, `21.choice_o` | ortak | Duvar açılır: karşıda Mirko **ve** arkasında Osmanlı Tolga'sı; Grant'in adamlarının arasında Bizans Tolga'sı. İki Tolga 3,4 m'de: Paradoks göstergesi %60'tan başlar, saniyede %10 dolar: **5 sn içinde** iki taraf da seçimini yapmalı (Bizans: sus işareti / kaç; Osmanlı: el kaldır / leblebi uzat). İkisi de barışçıl seçerse herkes geri çekilir; biri kaçarsa 21'in arbede yolu (yeniçeri koşar, Grant ateş kabı atar; NPC). |
| Duman | `21.fire_delay(s)` | B→O | Grant tüneli yakmadan önce Bizans **E: "Bekleyin!"** (en çok 10 sn) diyebilir; Osmanlı'nın duman sayacı o kadar geç başlar. 21O.1 kolaylaşır. |
| 23 Mayıs (21 oynanış 3) | — | — | Osmanlı yok; Bizans tek başına. Kasım'ın sorgusu co-op'ta da Bizans'ındır. |

**Ortak düğüm:** `COOP_21_A` "Tünelde iki taraf da geri çekildi" / `COOP_21_B` "Tünelde arbede".

### 12.8 Bölüm 22 — Kule (17–19 Mayıs) · 22o ⟷ 22 · aynı harita

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| Gece kurulum ⟷ şafak | `22.hides(n)`, `22.earth(n)` | O→B | Osmanlı'nın ıslattığı deri sayısı (0–3) Bizans'ın kuleyi yakmak için gereken isabet sayısını belirler: 3 ıslak deri → 2 isabet, daha azı → 1. Hendeğe taşınan toprak fıçıların yuvarlanma yolunu değiştirir (dolu hendekte fıçı kuleye kadar gider, boşta hendeğe düşer). |
| Şafak tüfeği | `22.aim_peek` | O→B | 22o'da Osmanlı kulenin tepesinden sur yolundaki NPC savunanlara 4 atış yapar; Bizans fıçıları oluğa dizerken nişan halkası görünür, oluğun arkasına çömel (C). |
| Gece fıçılar | `22.barrel(release_t)`, `22.tower_fire` | B→O | Bizans'ın fıçısı kuleyi tutuşturduğu an 22o'nun kurtarma sayacı başlar. **Merhamet anı:** kule yanarken Bizans'ın ekranında merdivenden inen marangozlar görünür; Bizans sıradaki fıçıyı **10 sn tutarsa** (E basılı, `UI_PROMPT22_HOLD` "E basılı: bekle, iniyorlar") Osmanlı'nın marangoz indirme süresi o kadar uzar. |
| Kule dibi düellosu | `22.duel` | ortak | Kule dibindeki çıkış düellosu (22o) ve gedikteki Bizans düellosu ayrı şeritlerde. |

```csv
UI_PROMPT22_HOLD,"E basılı: bekle, iniyorlar","Hold E: wait, they're climbing down"
```

**Ortak düğüm:** `COOP_22_A` "Kule yandı, herkes indi" (22O.1 **ve** fıçı tutuldu) / `COOP_22_B` "Kule yandı, biri geç indi".

### 12.9 Bölüm 23 — Elçi (21 Mayıs) · ortak sahne · co-op'a fiziksel ön faz

23 bugün iki tarafta da neredeyse yalnız diyalogdur (OTTOMAN_STORY §2.4). Co-op için (ve istenirse tek kişilik için)
**"Hendek köprüsü"** ön fazı önerilir (≈ 2,5 dk, **kurgu**: elçi heyetinin surun hangi kapısından ve nasıl girdiği kaynaklarda
ayrıntılı değildir; 28b'de köprüler yıkılmıştır, bu yüzden geçici bir köprü gerekir):
- **Bizans:** dış surun üstünde iki makara kolu; hendeğin üstüne **geçici kalas köprüyü iple indir**: iki ip, iki
  `BalanceMeter` ibresi (sol ve sağ ip), ikisini birlikte ortada tut; köprü yatay inmezse heyet bekler. İndikten sonra iki
  bağ (zamanlı düğüm).
- **Osmanlı:** elçinin **ürkek atını** köprüden geçir: dizgin E basılı, `BalanceMeter` (at köprünün sallanmasına göre
  ürker); rüzgârda bir kez sert ürkme.
- **Co-op:** köprünün sallanması Bizans'ın iki ip ibresinin farkıdır; Osmanlı'nın atı o sallanmaya göre ürker. Sonra
  sahne mevcut 23 gibi sürer: **çift tercüme** (Bizans İmparator'un sözünü Türkçeye, Osmanlı İsmail Hamza'nınkini Rumcaya
  çevirir); her tarafın sapma göstergesi ayrıdır, toplamları Paradoks göstergesine yazılır. İki taraf da sadıksa
  `COOP_23_A` "İki dil, tek anlam"; değilse `COOP_23_B` "İki dil, iki yorum". Tespit (iki heyet aynı karede): **çift kayıt**.

```csv
UI_OBJ23_BRIDGE_B,"Geçici köprüyü iple indir: iki ibreyi birlikte ortada tut","Lower the temporary bridge on its ropes: keep both needles centred together"
UI_OBJ23_BRIDGE_O,"Elçinin atını köprüden geçir (E basılı · dengede tut)","Lead the envoy's horse across the bridge (hold E · keep it steady)"
D23_COOP_N_01,"Köprü yok, Tolga Bey ve Tolga Bey. Yıkılmıştı, hatırlarsınız. Elçinin geçmesi için bir tanesi geçici olarak inecek. Biriniz ipte, biriniz atın başında.","There's no bridge, Mr Tolga and Mr Tolga. It was torn down, you'll recall. For the envoy to cross, a temporary one will be lowered. One of you on the ropes, one of you at the horse's head."
```

### 12.10 Bölüm 24 — Alametler (22, 24–25 Mayıs) · 24o ⟷ 24 · uzak eşleşme + ortak fırtına

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| 22 Mayıs (Osmanlı) | `24.eclipse` | O→B | Bizans'ın bölümü 24 Mayıs'ta açılır; co-op'ta Bizans için 60 sn'lik bir **sur ön fazı** eklenir: kanlı ay, surda korkmuş nöbetçiler; Bizans dört nöbetçiye meşale yakıp verir (E, rüzgârda meşale söner). Osmanlı'nın sakinleştirdiği ateş sayısı ordugâhtan duyulan uğultuyu azaltır (ses). |
| 24 Mayıs fırtına | `24.gust(t)`, `24.hail(t)`, `24.lightning(t)` | ortak | **Tek tohumlu fırtına:** sert rüzgârlar, dolu ve şimşek iki tarafta aynı saniyede. Osmanlı çadır iplerini tutarken Bizans ikona sedyesinin sırığında dengede kalır. Şimşek anında iki taraf da bir an beyaz ekran; iki oyuncu aynı şimşekte iyi tutarsa (Osmanlı ip yeşilde, Bizans ibre ortada) "Büro ritmi" işareti. |
| 25 Mayıs kubbede ışık | `24.dome_light`, `24.photo` | ortak | Kaynaklar ışığın Osmanlı ordugâhından da görüldüğünü yazar (**R**). Co-op'ta Osmanlı'ya 45 sn'lik bir **ordugâh son fazı** eklenir: sırta tırman (kısa serbest tırmanma, kaygan), kubbedeki ışığı kaydet. İki kare ±3 sn → **çift kayıt**. |

```csv
UI_OBJ24O_DOME,"Sırta tırman: şehrin üstünde bir ışık","Climb the ridge: a light above the city"
D24O_N_DOME,"25 Mayıs akşamı, Tolga Bey. Şehrin kubbesinde bir ışık. Kaynaklar onu iki tarafın da gördüğünü yazar; ordugâhta da korku ve yorum.","The evening of 25 May, Mr Tolga. A light on the city's dome. The sources say both sides saw it; in the camp too there was fear, and interpretation."
```

**Ortak düğüm:** `COOP_24_A` "Aynı fırtına, aynı ışık" (çift kayıt) / `COOP_24_B` "Fırtına iki yerde".

### 12.11 Bölüm 25 — Son Akşam (27 Mayıs gecesi) · ortak sahne · uzak eşleşme

§1'deki kronoloji düzeltmesiyle 25'in Bizans dalı yalnız 27 Mayıs gecesidir (ışıklar). Bu kısım tek başına ince
kaldığı için Bizans dalına bir **"alarm koşusu"** eklenir: ordugâh baştan uca aydınlanınca nöbetçi kampın yandığını sanır;
Tolga sur yolunda koşarak uyuyan bölükleri uyandırır (her bölükte E), yürüyüş yolunda yıkık bir aralığı **atlar** ya da
kulenin dışından **tırmanarak** geçer (`Traversal`), 90 sn içinde; sonra ışıkların bir yangın olmadığı anlaşılır ve tespit
karesi çekilir (25'in mevcut karesi).

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| Işıklar | `25.lamps(n)` | O→B | Osmanlı'nın şerbet yürüyüşü sırasında ordugâhın kandilleri yanar (senaryo); Bizans'ın koşu süresi o yürüyüşün süresidir. |
| Gizlilik | `25.spotted(n)` | O→B | Osmanlı nöbetçilere bir kez görünürse ordugâhta meşaleler koşuşur: Bizans'ın ekranında otağın çevresinde ışıklar kıpırdar, uyandırılacak bölük +1 ("Bir şey oluyor!"). İki kez görülürse (25.2) bir bölük daha. |
| Karar | `25.decision` | O→B | Sultan kararını verdiği an ordugâhta bir tekbir dalgası; Bizans surda duyar (ses + Nihat köprüsü). |

**Ortak düğüm:** `COOP_25_A` "Meclis sonuna dek dinlendi, sur uyandı" / `COOP_25_B` "Ordugâhta koşuşma".

### 12.12 Bölüm 26 — Şafak (29 Mayıs) · 26o ⟷ 26 · aynı harita

| Faz | Olay | Yön | Etki |
|---|---|---|---|
| Giriş | `32.result` (önceki bölüm) | ortak | 32o/32b'nin ortak düğümü (`COOP_32_A/B`) iki tarafta barikatın şafak aşamasını belirler; 32b'nin demet avı 26o'daki hendek yamacında boşluk bırakır. |
| 1. dalga | `26.water(n)` | ortak | Osmanlı kıyıdaki üç bölüğe, Bizans gedikteki adamlara su taşır: iki ayrı kuyu, aynı ritim (dalga zamanları ortak). |
| 2. dalga | `26.ladders(n)`, `26.cannon`, `26.repair` | O→B | Osmanlı'nın kıyıya taşıdığı merdiven sayısı Bizans'ın 2. dalgada gördüğü merdiven sayısıdır (en az 2). Urban'ın topu barikatı yıkar (senaryo; Osmanlı'nın "Siper!" uyarısı aynı atıştır); Bizans yeniden örer. |
| Tüfekler | `26.aim_runners`, `26.aim_peek` | ortak | Bizans'ın tüfeği hendeği geçen NPC yeniçerilere, Osmanlı'nınki mazgaldaki NPC savunanlara. Birbirlerinin hedef listesinde değiller; ama birinin vurmadığı NPC öbürünün düellosuna katılır (26 ve 26o'nun mevcut "+2 / +1" kuralları, şimdi karşı oyuncudan). |
| 3. dalga | `26.giust_wounded`, `26.warn` | ortak | Giustiniani yaralanır. Co-op'ta 26.3 kapalıdır (§2.8): Bizans uyarırsa Giustiniani yine vurulur, ama Bizans'ın uyarısı Osmanlı'nın ekranında tüfekçinin bir an duraksaması olarak görünür (`D26_COOP_N_WARN`). |
| Sancak | `26.banner`, `26.photo` | ortak | Hasan sancağı burca diker; Osmanlı aşağıdan, Bizans gedikten görür. ±3 sn → **çift kayıt**. `hasan_night` ve `niko_night` bayrakları iki tarafta birer bark seçer (Bizans'ta Niko'nun tek repliği: `D26_NK_FIG` / `_WORD` / `_SIT`). |
| Ayasofya | ortak sahne | ortak | Öğleden sonra iki taraf da kalabalığın içinde; paradoks mesafesi geçerli. Son kare seçimi iki tarafta ayrı. |

```csv
D26_COOP_N_WARN,"Uyardınız, Tolga Bey. Tüfekçi bir an durdu. Sonra yine de ateş etti. Bu nüshada tarih iki kere tutuluyor; değiştirilemiyor.","You warned him, Mr Tolga. The gunner hesitated for a moment. Then he fired anyway. In this copy history is being held by two hands; it can't be changed."
D26_NK_FIG,"(Gedikte, kısa) Casus! İncir cebimde. Akşama yerim.","(At the breach, briefly) Spy! The fig's in my pocket. I'll eat it this evening."
D26_NK_WORD,"(Gedikte, kısa) Yanımdasın! Söz tutuldu!","(At the breach, briefly) You're beside me! A promise kept!"
D26_NK_SIT,"(Gedikte, kısa, susar; başıyla selam verir.)","(At the breach, briefly; says nothing, nods.)"
```

**Ortak düğüm:** `COOP_26_A` "Sancak iki gözle kaydedildi" (çift kayıt) / `COOP_26_B` "Sancak tek gözle kaydedildi".

### 12.13 Bölüm 27 — Ahitname (1 Haziran) · ortak sahne

- Bizans Tolga'sı 31b'nin kayığıyla rıhtıma gelir (Stavros'un ailesi), Osmanlı Tolga'sı Zağanos Paşa'nın maiyetinin
  arkasında yürür.
- **Kal / git:** üç kişi (Spinola, noter, balıkçı) iki oyuncu arasında bölünür: her biri en yakın oyuncuya sorar (ilk
  yaklaşan). Dördüncü kişi olarak Stavros eklenir (yalnız Bizans'a sorar; `D27_NKC_01`). 27.1 / 27.2 dört cevabın toplamına
  bakar (≥ 2 "kal").
- **Tespit:** ahitname, paşa ve podesta aynı karede; iki açıdan → **çift kayıt**.
- Büro kapanışı: Nihat iki dosyayı yan yana imzalar (`D27_COOP_N_END`).

```csv
D27_NKC_01,"(Rumca) Kâtip! Karım kalalım diyor; ben gidelim diyorum. Sen ne dersin? Senin sözün bizi bir kere zincire kadar götürdü.","(In Greek) Clerk! My wife says stay; I say go. What do you say? Your word got us as far as the boom once."
D27_COOP_N_END,"İki dosya, Tolga Bey ve Tolga Bey. Biri fesli, biri kukuletalı. Aynı tarihler, aynı sonuç, iki ayrı sayfa düzeni. Yönetmelik iki nüshanın birbirini tamamladığını söyler. İlk kez buna inanıyorum.","Two files, Mr Tolga and Mr Tolga. One in a fez, one in a hood. The same dates, the same outcome, two different page layouts. The regulations say the two copies complete each other. For the first time, I believe it."
```

---

## 13. Yapım sırası

Her adım ayrı sürümdür (test, seslendirme listesi, yayın), SIEGE.md §6'daki gibi.

1. **Bizans tarafı küçük altyapı (kod değişikliği az):**
   - `Siege.recap` yalnız Osmanlı tarafında çalışıyor; Bizans için `UI_RECAP_<NN>B_PREV/NEXT` (ve ortak sahneler için
     `UI_RECAP_<NN>_B_PREV/NEXT`) anahtarlarına bakacak biçimde genişletilir. Satırlar ayrı bir küçük belgede yazılır.
   - `SIEGE_DATE_<NN>` / `SIEGE_EV_<NN>` için taraf eki: önce `SIEGE_DATE_<NN>B`, yoksa ortak anahtar (34b, 35b, 31b bunu kullanır).
   - `Lore.PAGES`: `"28b": 3, "37b": 3, "32b": 3, "38b": 3, "39b": 3, "31b": 3, "33b": 3, "34b": 3, "35b": 3`.
   - `Grade.finish`: 28b, 37b, 32b, 38b (39b ve 31b'de yalnız istatistik satırı).
   - Tespit kareleri: `siege28b`, `siege37b`, `siege32b`, `siege38b`, `siege39b`, `siege31b`, `siege33b`, `siege34b`, `siege35b`.
   - 25'in Bizans dalından Ayasofya aşamasını statik yardımcıya çıkar (32b için).
   - Statik yardımcılar: `Bogaz.crane` (33o yapılmadıysa önce küçük bir `Props.shear_crane`), `SeaBattle.rigging`,
     `Petrion.build(..., {"day": true})`, `TespitCam` sayım kipi.
2. **Aynı haritayı yeniden kullanan Bizans bölümleri (tek başına oynanır, co-op'suz):**
   **37b** (37o'nun haritası) → **32b** (32o'nun haritası + çan kulesi) → **38b** (38o'nun haritası + Petrion damları) →
   **39b** (39o'nun haritası + kilise içi) → **28b** (Lykos + köprü kurucusu). Bu beşi Bizans nüshasında 29 Mayıs'ın ve
   kuşatmanın ilk haftasının boşluğunu kapatır.
3. **`Coop` autoload ve hayalet** (§2.9), `--coop=loop` testi, paradoks mesafesi, ortak düğüm gösterimi. İlk olarak
   **aynı haritalı var olan çiftler**: 21 (titreşim, en temiz olay seti), 30 (merdiven itme), 20, 22, 29, 26.
4. **Yeni Bizans bölümlerinin co-op olayları:** 37 → 32 → 38 → 39 (bu dördü birbirine bağlı: barikat, merdiven, kapı,
   ip). Ardından 28, 17, 18, 19, 24, 25 ve 23'ün ön fazı.
5. **31b** (yeni `Cistern` seviyesi) — 31o ile birlikte.
6. **33b, 34b, 35b** — OTTOMAN_NEW_A'nın 33o, 34o, 35o'su ve onların seviyeleri (`Bogaz`, `EdirneYard`, `ThraceRoad`)
   yapıldıktan sonra.
7. **Seslendirme:** her adımın yeni replikleri `docs/voice/NEW_V0xxx.txt`'ye; `D_COOP_*`, `D<NN>_COOP_*` co-op
   replikleri ayrı bir listede (`NEW_COOP.txt`).
8. **Testler:** her yeni bölüm için `--chapter=NN --autotest[=…]` (bölüm tablolarında), her çift için
   `--coop=loop:O` ve `--coop=loop:B` (`COOPCHECK PASS`), `tests/siege_route.tscn`'de Bizans sırasının 22 bölümle
   doğru numaralandığı (`ROUTECHECK`), `VISAUDIT` (ip katenerleri, zemin, hayaletin konuşma görüş hattını kesmemesi).

## 14. Yeni konuşanlar (cast / ses)

Dokuz yeni `SPK_` anahtarı; her birinin `anahtar,tr,en` satırı ilk kullanıldığı bölümün Metinler bloğundadır (33b: `SPK_BARTOLO`, `SPK_CUSTOMS`; 34b: `SPK_MERCHANT`; 35b: `SPK_MANOLIS`; 38b: `SPK_BARBARO`; 39b: `SPK_EUDOKIA`, `SPK_OLDMAN`, `SPK_GIRL`; 31b: `SPK_COUSIN`). İki kez yapıştırmayın.

| Anahtar | Bölüm | Kim | Ses |
|---|---|---|---|
| `SPK_BARTOLO` | 33b | Ceneviz ticaret gemisinin kaptanı (kurgu) | Ellilerinde, Cenevizli; gür, alaycı, pazarlıkçı ama korkak değil; deniz deyimleriyle konuşur, kesesini sever. |
| `SPK_CUSTOMS` | 33b (yalnız tek kişilik) | Boğazkesen'in gümrük kâtibi | Genç, titiz, biraz ürkek; fenerle yürür, beyanı yüksek sesle sayar. |
| `SPK_MERCHANT` | 34b | Edirne'den gelen Venedikli tüccar | Kırklarında, yol yorgunu, dedikoducu; haberi büyüterek anlatır ama rakamları Doukas'ınkiyle aynıdır. |
| `SPK_MANOLIS` | 35b | Selymbria'lı gözcü başı (kurgu) | Otuzlarında, kısa cümleler, fısıltıya yakın; doğa benzetmeleri ("taş ol"); kılıçtan değil görülmekten korkar. |
| `SPK_BARBARO` | 38b | Nicolò Barbaro, Venedikli gemi hekimi, günlüğün yazarı (gerçek) | Kırklarında, aceleci, dikkatli gözlemci; kısa, emir kipinde bağırır; tek sahnesi kadırganın pruvasında. |
| `SPK_EUDOKIA` | 39b, 31b | Niko'nun annesi (kurgu) | Altmışlarında, Rumca konuşur (altyazı Türkçe); kararlı, pratik, yumuşak değil ama sıcak; sayarak ve emir vererek korkuyu yönetir. |
| `SPK_OLDMAN` | 39b | Yaşlı Theodoros (39o'daki iple inen adam) | Yetmişlerinde, öksürüklü, ince ses; şaşkın bir mizah ("hangisi kimdi?"). |
| `SPK_GIRL` | 39b, 31b | Zoe, Niko'nun kuzeninin kızı (kurgu) | 7–8 yaş, Rumca; korkuyla oyun arasında gidip gelir ("uçuyorum!"); tavuk Sinerji'nin sahibi. |
| `SPK_COUSIN` | 31b, 27 | Stavros, Niko'nun kuzeni, kayıkçı (kurgu; Bölüm 10H'deki "Niko'nun kuzeninin kayığı") | Kırklarında, Rumca, kaba ama yumuşak kalpli; kısa komutlar ("Dalga!"). |

**Var olan ve bu belgede yeniden kullanılan anahtarlar:** `SPK_NIHAT`, `SPK_TOLGA`, `SPK_NIKO` (Bizans tarafının Hasan'ı:
28b, 32b, 34b, 37b, 38b, 39b, 31b, 26'da tek bark), `SPK_GIUST`, `SPK_GRANT`, `SPK_EMPEROR`, `SPK_TREVISANO`, `SPK_MONK`
(Keşiş Makarios, 32b'nin çan kulesi), `SPK_LOOKOUT`, `SPK_DEFENDER`, `SPK_GENOESE`, `SPK_PRIEST`, `SPK_TOWNSMAN`,
`SPK_SAILOR`, `SPK_SAILOR2`, `SPK_PATROL`, `SPK_JANISSARY`, `SPK_CAVUS`, `SPK_AZAP`, `SPK_KADRI`, `SPK_HERALD`,
`SPK_SOLDIER`; OTTOMAN_NEW_A'da planlı olanlar: `SPK_FIRUZ`, `SPK_RIZZO`, `SPK_KARACA`.

**Seslendirme notları:**
- **Rumca konuşanlar** (Eudokia, Zoe, Stavros, papaz, ihtiyarlar) Türkçe altyazılıdır; seslendirme Türkçe yapılırsa
  repliklerin başındaki "(Rumca)" etiketi ekranda kalır (39o'daki uygulama).
- **İki Tolga:** co-op'ta iki oyuncunun repliklerini aynı Tolga sesi söyler. `D_COOP_T_MEET_*` aynı anda iki taraftan
  söylenmez: önce biri, 0,6 sn sonra öbürü (yankı hissi).
- **Niko'nun yayı:** 28b'de esprili (tavuk, kuzen), 32b'de ilk kez ciddi (annesi), 38b'de çaresiz, 39b'de rahatlamış,
  31b'de vedalaşan. Seslendirmede bu değişim duyulmalı; "casus" hitabı hep aynı sıcaklıkla.
- Replik sayıları (yaklaşık): 33b 41, 34b 29, 35b 25, 28b 28, 37b 27, 32b 37, 38b 36, 39b 37, 31b 33; co-op ve var olan
  bölümlere eklenenler ≈ 30. Toplam ≈ 320 yeni replik.
