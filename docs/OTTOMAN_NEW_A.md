# Osmanlı Tarafı · Kuşatmadan Önce: dört yeni bölüm (33o–36o) · v0.1

Bu belge `docs/OTTOMAN_STORY.md`'nin devamıdır. Kullanıcıya göre Osmanlı tarafında 5–10 bölüm eksik: nüsha **6 Nisan'da
kazıkla** açılıyor. Hisar, top, yol ve ilk hücum hiç oynanmıyor. Burada bu boşluğu dolduran **dört yeni bölüm**
var: kuşatmadan önceki yıl ve kuşatmanın ilk haftası. Biçim OTTOMAN_STORY §4 ile aynı. İlkeler de aynı:
*tarih inatçıdır*, Tolga sonucu değil insanları değiştirir, Kerkoporta rivayeti yok, NPC'ler "Büro"yu bilmez.
Büro'yu yalnız Nihat telsizde anar.

Kaynak kısaltmaları: **R** Runciman (*The Fall of Constantinople 1453*), **K** Kritovoulos, **B** Barbaro'nun günlüğü,
**D** Doukas, **S** Sphrantzes, **TB** Tursun Bey, **AP** Aşıkpaşazade. Kesin olmayan ya da sonraki anlatılara dayanan
ayrıntılar **(rivayet)** diye işaretlidir. Rakamlar (öküz, adam, menzil, ölü sayısı) kaynağın kendi rakamıdır ve öyle
söylenir.

---

## 0. Seçim, kimlikler, sıra

### 0.1 Seçilen dört bölüm

| İç id | Sahne | Başlık | Tarih | Neden bu |
|---|---|---|---|---|
| **33** | `chapter33o` | Boğazkesen | 31 Ağustos ve 26 Kasım 1452 | Kuşatmanın gerçek başlangıcı: hisar biter, Boğaz kapanır, Rizzo'nun gemisi Urban'ın **ilk** topuyla batar (**D**). Urban'ın ipi buradan başlar. Fiiller: iskele, denge, kürek, gümrük, uyarı atışı, büyük top. |
| **34** | `chapter34o` | Tuncun Sesi | Ocak 1453, Edirne | Büyük top kalıptan çıkar, gülleler ölçülür, tellal şehri uyarır, Sultan'ın önünde deneme atışı (**D**). Tolga'nın mesleği ilk kez gerçekten işe yarar: **kalite kontrol**. |
| **35** | `chapter35o` | Edirne Yolu | Şubat–Mart 1453, Trakya | Topun iki aylık yolculuğu: köprü kur, çamurdan çek, yokuşta frenle (**D**). 28o'daki "Altmış öküz bunu Edirne'den getirdi" cümlesi oynanmış olur. |
| **36** | `chapter36o` | İlk Hücum | 18 Nisan 1453 gecesi | Gedikteki barikata ilk büyük gece hücumu (**B**, **R**). SIEGE.md §1'de "—" olarak duruyordu. Yeni fiiller: **kancayla fıçı indirmek** ve **meşale atmak**. 28o ile 29o arasındaki boşluğu da kapatır. |

**Seçilmeyenler:**
- **22 Nisan gemilerin karadan yürütülmesi:** Bölüm 2 "Yağlı Kızaklar"da Tolga zaten bu yokuştadır. Ayrıca `Slipway`
  bu sahnenin kendisidir. 17o'nun "önceki bölümde" satırı bunu söylüyor, yeterli.
- **Therapia, Studios ve Prinkipo:** Üçü de teslim olan ya da yakılan garnizonların öldürülmesiyle biter
  (**K**, **R**). Oynanış merkezine konamaz. 36o'da Nihat bir cümleyle anar.
- **Ordunun gelişi ve otağın kurulması (2–5 Nisan):** 28o'nun 6 Nisan kazık fazına çok yakın. 35o'nun son replikleri
  ve 28o'nun açılışı bunu söyler.
- **Urban'ın dökümünün kendisi:** Döküm fırını ve potalar zaten 10B "Büyük Atış"ta güç çubuğuyla oynanıyor. 34o
  dökümden **sonrasını** oynatır: kalıp kırma, gülle seçimi, atış.

### 0.2 Siege.ORDER

```gdscript
const ORDER := [33, 34, 35, 28, 36, 29, 17, 18, 19, 20, 30, 21, 22, 23, 24, 25, 32, 26, 31, 27]
```

- 33, 34, 35 → 28o'dan önce. 36 → 28 ile 29 arasında.
- Dördünün de yalnız `chapterNo.tscn` sahnesi vardır (ortak `chapterN.tscn` ve `chapterNb.tscn` yok). Bu yüzden Bizans
  tarafı onları `_plays()` ile atlar ve Bizans sırası değişmez.
- `siege.gd`'deki ORDER yorum satırına şu eklenir: "33 (Ağustos–Kasım 1452, Boğazkesen), 34 (Ocak 1453, Edirne),
  35 (Şubat–Mart 1453, yol), 36 (18 Nisan, ilk hücum)".
- Ekran numaraları `{N}` ile kendiliğinden kayar (Osmanlı): 33o → 13, 34o → 14, 35o → 15, 28o → 16, 36o → 17,
  29o → 18, … 26o → 30, 27 → 31. Kuşatmadan sonraki 13/14/15 dört numara ileri gider.
- OTTOMAN_STORY §1'deki tablo bu kaymaya göre güncellenir. "Eski numaralı sonuç düğümleri" sorunu (`FLOW_20O_1` =
  "16O.1 …") böylece daha da büyür. Yeni bölümlerin sonuç düğümleri **numarasız** yazıldı.
- `Lore.PAGES`'e şu girdiler eklenir: `"33o": 3, "34o": 3, "35o": 3, "36o": 3`.
- `SIEGE.md` §1 tablosundaki "18 Nisan" satırının "Oyunda" sütunu **Bölüm 36o** olur. Tablonun başına iki satır
  eklenir:
  - "Nisan–Ağustos 1452: Boğazkesen | 33o"
  - "Ocak–Mart 1453: büyük top, deneme atışı, yol | 34o, 35o"

### 0.3 Büro önsözü ve 28o'nun değişen açılışı

Osmanlı tarafında ilk bölüm artık 33'tür. `chapter17.gd` `D17_N_FIRST_%d` anahtarını kullandığı için kod değişmez,
yalnız yeni anahtar eklenir. `D17_N_FIRST_28` Osmanlı tarafında artık söylenmez (silinmez, yedekte kalır).

```csv
D17_N_FIRST_33,"Bir düzeltme, Tolga Bey: Osmanlı nüshası çok daha erken açılmış. İlk kayıt Ağustos 1452, Boğaz'ın en dar yerinde bir hisar. Kuşatmaya yedi ay var. Kendinize rastlamazsınız; rastladıklarınız sizi Nisan'da hatırlarsa, formda ona da kutu yok.","One correction, Mr Tolga: the Ottoman copy opens much earlier. First entry: August 1452, a fortress at the narrowest point of the Bosporus. Seven months before the siege. You won't run into yourself; if the people you run into remember you in April, there's no box on the form for that either."
```

**28o'nun açılışı.** Tolga artık topla birlikte gelmiştir. Urban onu "mantolu yabancı" diye değil, kendi kâtibi diye
karşılar. Üç replik değişir, akış aynı kalır:

```csv
D28O_N_01,"Tolga Bey, 6 Nisan. Ordu dün geldi, bugün toprağa giriyor. Top da burada; iki ay yolda ona siz eşlik ettiniz. Şimdi kazık işiniz var.","Mr Tolga, 6 April. The army arrived yesterday, today it digs in. The gun is here too; you escorted it for two months on the road. Now you have stake duty."
D28O_U_01,"Kâtip! Yoldan sağ çıktın demek. Kazıkları siperin arkasına. Benim topum yerine geçtiğinde önünde çit olacak, düzgün olacak.","Clerk! So you survived the road. Stakes behind the rampart. When my gun goes into place there will be a fence in front of it, and it will be straight."
D28O_U_HAUL,"Altmış öküz bunu Edirne'den getirdi, sen de yanındaydın. Son kırk metre bizim. Hey-yap dediğimde hep birlikte! Kütük arkadan çıkınca öne!","Sixty oxen brought this from Edirne, and you walked beside it. The last forty metres are ours. When I say heave, all together! When a roller comes out the back, take it to the front!"
```

`D28O_T_01` ("Usta, bu kazıklar sizin topunuzu mu koruyacak…") olduğu gibi kalır, yeni açılışla da uyumludur.

### 0.4 Komşu bölümlerin değişen "Önceki bölümde / Sırada" satırları

Bütün satırlar 140 karakterin altındadır (denetlendi).

```csv
UI_RECAP_28O_PREV,"İki ay Trakya yolunda köprü kurdun, çamurdan çektin, yokuşta frenledin. Top surlara beş mil kala bekliyor.","Two months on the Thracian road: you built a bridge, hauled it out of the mud, braked it downhill. The gun waits five miles out."
UI_RECAP_28O_NEXT,"Şahi konuştu. 18 Nisan gecesi: gedikteki barikata kanca ve meşaleyle ilk büyük hücum.","The great gun has spoken. Night of 18 April: the first great assault, with hooks and torches, on the stockade in the breach."
UI_RECAP_29O_PREV,"18 Nisan gecesi barikattan fıçı indirdin, meşale attın; dört saat sonra boru çaldı. Ulak seni donanmaya yolladı.","On 18 April you pulled barrels off the stockade and threw torches; after four hours the horn sounded. A courier sent you to the fleet."
```

`UI_RECAP_29O_NEXT` ve sonrakiler değişmez.

**29o'nun açılışı (§2.1'deki "neden denizde" kopukluğu):** 36o, Baltaoğlu'na kürekçi toplayan bir ulakla biter
(`D36O_RD_01`). 29o'da ek replik gerekmez.

---

## 1. Bölüm 33o — "Boğazkesen" (31 Ağustos ve 26 Kasım 1452)

### 1.1 Tarihî dayanak

- **Hisar.** II. Mehmed 1452 baharında Boğaz'ın en dar yerinde, Anadoluhisarı'nın karşısında bir hisar yaptırdı.
  Yaklaşık dört buçuk ayda, Ağustos sonunda bitti (**K**, **D**, **TB**, **AP**). Bizanslılar ona "Boğazkesen" dedi:
  Doukas'ta *Laimokopia*, Osmanlı kaynaklarında *Boğazkesen*.
  - Üç büyük kuleyi üç vezir yaptırdı: Çandarlı Halil, Zağanos ve Saruca Paşa. Surları Sultan'ın kendisi yaptırdı.
    Vezirler arasında bir yarış anlatılır (**D**, **K**).
  - Hisarın planının Arapça bir adı yazdığı söylenir: **rivayet**, oyunda kullanılmaz.
- **Gümrük ve top.** Hisarın dibine kıyıya büyük toplar kondu. Boğaz'dan geçen her gemi yelkenini indirip durmak ve
  geçiş hakkı ödemek zorundaydı (**D**, **R**). Hisarın dizdarı (komutanı) Doukas'a göre Firuz Ağa'dır; emrinde
  400 asker vardı.
- **Rizzo'nun gemisi.** 1452 Kasım'ının sonunda Antonio Rizzo'nun Venedik gemisi Karadeniz'den şehre erzak
  getiriyordu (Barbaro ve Venedik kaynakları 26 Kasım der).
  - Gemi yelken indirmedi. Hisarın topundan çıkan tek bir büyük gülle onu batırdı (**D**, **R**).
  - Kaptan ve tayfa kıyıya çıktı ve yakalandı. Dimetoka'da Sultan'ın huzuruna götürüldüler. Tayfa öldürüldü,
    Rizzo kazığa oturtuldu. Doukas'a göre cesetler gömülmeden bırakıldı.
  - Oyun bunu **göstermez**. Nihat bölüm sonunda tek cümleyle söyler. Haber şehirde ve Venedik'te kuşatmanın gerçekten
    başladığı an sayıldı.
- **Urban.** Macar (ya da Erdelyli) dökümcü önce hizmetini İmparator'a sundu. İmparator istediği ücreti ve malzemeyi
  karşılayamadı. Urban Sultan'a geçti. Doukas'a göre ilk büyük dökümü **Boğazkesen'e konan ve Rizzo'nun gemisini
  batıran toptur**. Sultan bundan sonra daha büyüğünü istedi (→ 34o). Oyun bu bağı kullanır: Urban'ın ipi hisarda başlar.
- Kerkoporta yok. Bölümde ölüm gösterilmez.

### 1.2 Yer ve sistemler

**Yeni küçük seviye:** `scripts/level/bogaz.gd` (`Bogaz`). Yaklaşık 300 satır, yalnız 33o kullanır.
- **Yakın kesit:** Halil Paşa'nın deniz kulesinin önündeki sur parçası.
  - 12 m'lik perde duvar ve kulenin yarım silindiri. Taş dokusu `LandWalls`'ın sur malzemesinden alınabilir.
  - Önünde iki katlı ahşap iskele (kalaslar, dikmeler).
  - Kulenin tepesinde dört taşlık bir boşluk ("yuva") var. Taşlar `Props` blokları, harç teknesi kireç ocağının
    yanında.
- **Kıyı bataryası:** Rıhtımın üstünde iki top.
  - Küçük top: 17o'daki "orta top"un kurulumu (`CannonCrew` pivot/muzzle).
  - Urban'ın büyük topu: 28o'daki Şahi namlusunun küçültülmüşü, toprak set üstünde. Gülle yığını ve barut fıçıları.
- **Su:** `SeaWalls`'taki su düzlemi ve dalga malzemesi. Akıntı güneye doğrudur (+X) ve kayığa hız olarak eklenir.
  - Karşı kıyı (z ~ 600) `OuterWorld` tepeleridir. Üstünde Anadoluhisarı'nın küçük silueti var (tek kule ve sur).
  - Yamaçlar `Nature` çimeni ve kayasıyla kaplı. Kıyı boyunca `Crowd.ottoman` işçiler ve askerler var.
  - Hisarın arkasında sırtta çadırlar ve kireç ocağının dumanı var.
- **Gemiler:** `SeaBattle`'ın karaka kurucusu.
  - Ceneviz gemisi: kırmızı haçlı yelken, yelkenler indirilmiş.
  - Rizzo'nun gemisi: Aziz Markos aslanlı, kırmızı-altın yelken, yelkenler dolu.
  - SeaBattle'ın karaka işlevi renk ve sancak parametresi almıyorsa ona `sail_color` / `emblem` eklenir (tek küçük değişiklik).
  - Kayık: 17'deki fusta/kayık ve `RowMeter`'ın kürekçi animasyonu (`Rig.row_phase`).

**Kullanılan sistemler:**
- `Ladder` (iskele ve gemi bordası).
- `BalanceMeter`: iskele kalasında rüzgâr. 4b'deki zincir dengesinin aynısı, sırttaki taş yüzünden ibre ×1,4 hızlı.
- 32o'nun taşıma döngüsü (`_take/_drop_carry`, sırtta yük %30 yavaş).
- 32o'nun basamak zamanlaması: taşı yerine oturtmak için "işaret ortadayken E".
- `RowMeter`, `CannonCrew` + `GunDrill`.
- `TespitCam`, `hud.choose`, `Lore.scatter(self, "33o")`.
- Işık: `SeaBattle.make_day()` benzeri gündüz. Ağustos sabahı ve Kasım öğleden sonrası (soğuk, alçak güneş) için iki ayar.

**Süre hedefi:** 9–11 dk, diyalog ≤ 3 dk.

### 1.3 Fazlar

| Faz | Zaman | Hedef | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Son taşlar | 31 Ağustos 1452, sabah | `UI_OBJ33O_STONE`, `UI_OBJ33O_MORTAR` | Taşçının yığınından **taş** al (sırtta: %30 yavaş, koşu yok). İskelenin dibine yürü. **Merdivenle** (`Ladder`, yükle tırmanma hızı ×0,6) birinci kata çık. **6 m'lik kalası** geç: `BalanceMeter` açılır, rüzgâr 3–5 sn'de bir ibreyi iter, A/D ile düzelt. İkinci merdivenle kule tepesine çık. Yuvada **E işaret ortadayken** taşı oturt. Iska olursa taş oynar: kaldır, yeniden dene. **Dört taş.** Her iki taştan sonra kireç ocağının teknesinden **bir kova harç** zorunlu; harç dökülmeden üçüncü taş sayılmaz (taşçı uyarır). Halil'in ve Zağanos'un kulelerinde ekipler yarışır. Sağ üstte üç küçük kule simgesi dolar (yalnız görüntü). | Süre 4 dk; ezan okununca faz biter. Kalastan düşen oyuncu alt kata iner (−15 can) ve taş yığına döner (`D33O_M_FALL`). Konan taş sayısı sonuçta sayılmaz, istatistikte görünür. Dört taş süre içinde konursa `D33O_M_DONE` (Tolga'nın kulesi önce biter), konmazsa `D33O_M_DONE_LATE`. |
| 2. Gümrük | Kasım 1452, sabah ("Kasım 1452 · gümrük" kartı) | `UI_OBJ33O_ROW`, `UI_OBJ33O_BOARD`, `UI_OBJ33O_STAMP` | Ceneviz gemisi yelkeni indirmiştir. Gümrük kayığında **kürek** (`RowMeter`, 120 m). Akıntı ritim kaçınca kayığı güneye kaydırır; çok kayarsa kürekçi uyarır, süre uzar. Bordadaki **ip merdivene** tırman (`Ladder`, tilt 8°). Güvertede **üç yükü** gözle: balık fıçısı, kenevir balyası, şarap küpü (her birine bak ve E). Kaptan "hediye" uzatır: **seçim** (`UI_C33O_REFUSE` / `UI_C33O_TAKE`). Sonra beyanı **mühürle** (E). Kayığa in. | Başarısızlık yok. Seçim `GameState.flags["toll_gift"]` = `refuse` / `take` olarak yazılır, dosya notunda bir kelime değiştirir. |
| 3. Uyarı atışı | 26 Kasım 1452, öğleden sonra ("26 Kasım 1452" kartı) | `UI_OBJ33O_WARN` | Kuzeyden Rizzo'nun gemisi gelir: yelkenler dolu, akıntı ve rüzgârla 5 m/sn. Firuz Ağa uyarı atışı ister. Tolga küçük topu **elle doldurur** (`CannonCrew`: barut, tapa, gülle, tokmak, nişan, ateş). Hedef suda, geminin **burnunun 25–60 m önünde** hareket eden bir halka; GunDrill'in nişan yayı halkayı gösterir. Gemi bataryanın önündeki koridoru **75 sn**'de geçer. | Gülle halkaya düşerse `warn = "ok"`. Gemiye değerse `warn = "hit"` (Firuz kızar). Başka yere düşerse ya da süre biterse `warn = "miss"`. Gemi her durumda yelken indirmez (tarih). |
| 4. Büyük top | Hemen ardından | `UI_OBJ33O_BIG`, `UI_OBJ33O_PHOTO` | Urban'ın topu. Gülle çok ağır; iki işçi taşır. Tolga **tokmak** (ritim, 3 iyi vuruş) ve **nişan** yapar, fitili Urban yakar. Hedef: hareket eden gövde, 180 m. `CannonCrew._predict`'in yayı geminin 2 sn sonraki yerine öne nişan almayı öğretir. **Tek atış.** İsabet olursa gövdede delik açılır, gemi yan yatar. Iska olursa yan topu Urban ateşler ve vurur (tarih). Gemi yan yatıp batarken **tespit karesi**: yatan direk ve arkada deniz kulesi. Pencere 20 sn, hedef direk tepesi. | `big = true/false`. Kare kaçarsa dosyada not (`UI_SIEGE_NO_PHOTO`). |
| 5. Kıyı | Akşamüstü | — | Kısa sahne, oyuncu yürür. Tayfa sandalla kıyıya çıkar, askerler onları alır (uzakta, arkası dönük). Tolga rıhtımda gümrük defterini kapatır. Nihat'ın kaydı. Urban Tolga'yı Edirne'ye çağırır. | — |

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **33O.1** Uyarı yerinde, gülle bordada | `warn == "ok"` **ve** `big` | `FLOW_33O_1` |
| **33O.2** Tunç ikinci kez konuştu | aksi hâlde | `FLOW_33O_2` |

Tarih ikisinde de aynıdır. Fark Firuz'un ve Urban'ın repliklerinde, dosya notunda ve 34o'daki ilk Urban repliğindedir
(`D34O_U_01` / `D34O_U_01_ALT`).

**Otomatik test:** `--chapter=33 --autotest[=wide|fall]`.
- Varsayılan 33O.1: bot dört taşı koyar, halkaya atar, büyük topla vurur, fotoğrafı çeker.
- `=wide`: uyarı gemiye değer, büyük top ıskalar → 33O.2. Satırlar: `WARN hit`, `BIG miss`.
- `=fall`: bot ilk kalasta dengeyi bilerek bırakır. Denetim: `downs == 0`, `stone_falls >= 1`, faz yine biter.
- Rizzo gemisinin yolu boyunca su yüksekliği ve gövde yüksekliği `VISAUDIT` ile denetlenir: gemi suya gömülmemeli.

**Akış şeması** (`UI_FLOW33O_TITLE`): `FLOW33O_STONES` → `FLOW33O_TOLL` → `FLOW33O_WARN` → `FLOW33O_BIG` →
{`33O.1`, `33O.2`}. Altında `UI_CH33O_STATS` ve `Siege.recap(…, "NEXT")`.

**Başarım önerisi:** `ACH_OSM_TOLL`: "Gümrük Memuru". Hediyeyi reddet ve uyarı atışını halkaya düşür.

### 1.4 Konuşanlar

Yeni anahtarlar:

| Anahtar | tr / en | Ses |
|---|---|---|
| `SPK_MASON` | Taşçı Ustası / Master Mason | Altmışlık, tozlu, sabırlı. Kısa cümlelerle konuşur, taşı insan gibi anlatır. 34o'da gülle yontan taşçı da bu anahtarı kullanır (başka kişi, aynı meslek). |
| `SPK_FIRUZ` | Dizdar Firuz Ağa / Firuz Agha, Warden | Hisarın komutanı. Kuralcı, gür sesli, kısa emirler verir. Kendi kuralına gurur duyar. |
| `SPK_RIZZO` | Kaptan Antonio Rizzo / Captain Antonio Rizzo | Uzaktan, rüzgârın içinden bağırır. Kibirli değil, inatçıdır: şehre erzak götürüyordur. |

Mevcut anahtarlar: `SPK_NIHAT`, `SPK_TOLGA`, `SPK_ZAGANOS`, `SPK_HALIL`, `SPK_FATIH`, `SPK_ROWER`, `SPK_GENOESE`,
`SPK_URBAN`.

**Koşullu replikler:**
- `D33O_M_FALL` ve `D33O_T_WIND` olayla söylenir. `D33O_M_STONE_BAD` ıskada söylenir.
- `D33O_M_DONE` / `D33O_M_DONE_LATE` süreye göre seçilir.
- Seçimden sonra yalnız bir çift söylenir: `REFUSE` ya da `TAKE`.
- Uyarı sonucuna göre `D33O_FZ_WARN_OK` / `_HIT` / `_MISS`.
- Büyük top `D33O_U_HIT` ya da (`D33O_U_MISS` + `D33O_U_SECOND`).
- Bitiş `D33O_U_END_OK` (33O.1) ya da `D33O_U_END_BAD` (33O.2).

| Anahtar | Konuşan |
|---|---|
| `D33O_N_01` | SPK_NIHAT |
| `D33O_T_01` | SPK_TOLGA |
| `D33O_N_02` | SPK_NIHAT |
| `D33O_M_01` | SPK_MASON |
| `D33O_T_02` | SPK_TOLGA |
| `D33O_M_02` | SPK_MASON |
| `D33O_Z_01` | SPK_ZAGANOS |
| `D33O_H_01` | SPK_HALIL |
| `D33O_T_03` | SPK_TOLGA |
| `D33O_M_STONE_1` | SPK_MASON |
| `D33O_M_STONE_BAD` | SPK_MASON |
| `D33O_T_STONE` | SPK_TOLGA |
| `D33O_M_MORTAR` | SPK_MASON |
| `D33O_T_WIND` | SPK_TOLGA |
| `D33O_M_FALL` | SPK_MASON |
| `D33O_M_DONE` | SPK_MASON |
| `D33O_M_DONE_LATE` | SPK_MASON |
| `D33O_F_01` | SPK_FATIH |
| `D33O_T_04` | SPK_TOLGA |
| `D33O_N_03` | SPK_NIHAT |
| `D33O_FZ_01` | SPK_FIRUZ |
| `D33O_T_05` | SPK_TOLGA |
| `D33O_R_01` | SPK_ROWER |
| `D33O_G_01` | SPK_GENOESE |
| `D33O_T_REFUSE` | SPK_TOLGA |
| `D33O_G_REFUSE` | SPK_GENOESE |
| `D33O_T_TAKE` | SPK_TOLGA |
| `D33O_N_TAKE` | SPK_NIHAT |
| `D33O_T_STAMP` | SPK_TOLGA |
| `D33O_FZ_SHIP` | SPK_FIRUZ |
| `D33O_RZ_01` | SPK_RIZZO |
| `D33O_FZ_WARN` | SPK_FIRUZ |
| `D33O_T_WARN` | SPK_TOLGA |
| `D33O_FZ_WARN_OK` | SPK_FIRUZ |
| `D33O_FZ_WARN_HIT` | SPK_FIRUZ |
| `D33O_FZ_WARN_MISS` | SPK_FIRUZ |
| `D33O_RZ_02` | SPK_RIZZO |
| `D33O_FZ_BIG` | SPK_FIRUZ |
| `D33O_U_01` | SPK_URBAN |
| `D33O_T_URBAN` | SPK_TOLGA |
| `D33O_U_HIT` | SPK_URBAN |
| `D33O_U_MISS` | SPK_URBAN |
| `D33O_U_SECOND` | SPK_URBAN |
| `D33O_T_SINK` | SPK_TOLGA |
| `D33O_N_PHOTO` | SPK_NIHAT |
| `D33O_FZ_BOAT` | SPK_FIRUZ |
| `D33O_T_BOAT` | SPK_TOLGA |
| `D33O_N_END` | SPK_NIHAT |
| `D33O_T_END` | SPK_TOLGA |
| `D33O_U_END_OK` | SPK_URBAN |
| `D33O_U_END_BAD` | SPK_URBAN |

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
UI_OBJ33O_STONE,Taşı kulenin tepesindeki yuvaya taşı · %d/%d,Carry the stone to the gap at the top of the tower · %d/%d
UI_OBJ33O_MORTAR,Kireç ocağından bir kova harç getir,Fetch a bucket of mortar from the lime kiln
UI_OBJ33O_BALANCE,Kalasta dengede kal (A/D),Keep your balance on the plank (A/D)
UI_OBJ33O_ROW,Kürek çek (ibre yeşildeyken Space) · Ceneviz gemisine yanaş,Row (Space when the needle is green) · come alongside the Genoese ship
UI_OBJ33O_BOARD,İp merdivenden güverteye çık,Climb the rope ladder to the deck
UI_OBJ33O_STAMP,Yükleri gözle ve beyanı mühürle · %d/%d,Inspect the cargo and stamp the manifest · %d/%d
UI_OBJ33O_WARN,"Uyarı atışı: topu doldur, geminin burnunun önüne at","Warning shot: load the gun, put it in front of the ship's bow"
UI_OBJ33O_BIG,"Büyük top: tokmakla sıkıştır, gövdeye nişan al","The great gun: ram it home, aim at the hull"
UI_OBJ33O_PHOTO,Tespit et: yatan direk ve kule,Record: the falling mast and the tower
UI_PROMPT33O_STONE,E: taşı sırtına al,E: take the stone on your back
UI_PROMPT33O_SET,E: taşı oturt (işaret ortadayken),E: set the stone (when the marker is centred)
UI_PROMPT33O_MORTAR,E: harç kovasını al,E: take the mortar bucket
UI_PROMPT33O_POUR,E: harcı dök,E: pour the mortar
UI_PROMPT33O_CARGO,E: yükü gözle,E: inspect the cargo
UI_PROMPT33O_SEAL,E: beyanı mühürle,E: stamp the manifest
UI_C33O_REFUSE,"Teşekkürler. Yazıyorum: balık, kenevir, şarap.","Thank you. I'm writing it down: fish, hemp, wine."
UI_C33O_TAKE,Bir şişe al; deftere numune yaz.,Take one bottle; write sample in the ledger.
FLOW33O_STONES,Kulenin son taşları (31 Ağustos),The tower's last stones (31 August)
FLOW33O_TOLL,"Gümrük: yelken indir, beyan et","The toll: lower your sail, declare your cargo"
FLOW33O_WARN,Rizzo'nun gemisine uyarı atışı,A warning shot at Rizzo's ship
FLOW33O_BIG,Urban'ın topu konuşur,Urban's gun speaks
FLOW_33O_1,"Uyarı yerinde, gülle bordada","Warning on the mark, ball in the hull"
FLOW_33O_2,Tunç ikinci kez konuştu,The bronze had to speak twice
UI_CH33O_STATS,Taş: %d/%d   ·   Uyarı: %s   ·   Büyük top: %s   ·   Dosya: %d/%d sayfa,Stones: %d/%d   ·   Warning: %s   ·   Great gun: %s   ·   File: %d/%d pages
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
LORE_33O_1,"Sultan II. Mehmed 1452 baharında Boğaz'ın en dar yerinde, babasının karşı kıyıdaki hisarının tam karşısına bir kale yaptırdı. Üç büyük kuleyi üç vezir, Çandarlı Halil, Zağanos ve Saruca Paşa yaptırdı; iş dört buçuk ayda bitti. Bizanslılar kaleye 'boğaz kesen' dediler.","In the spring of 1452 Sultan Mehmed II built a castle at the narrowest point of the Bosporus, right across from his great-grandfather's fortress on the Asian shore. Its three great towers were raised by three viziers, Çandarlı Halil, Zaganos and Saruja Pasha; the work was done in four and a half months. The Byzantines called it the throat-cutter."
LORE_33O_2_T,Yelken indir,Lower your sail
LORE_33O_2,"Hisarın dibine, kıyıya büyük toplar kondu. Karadeniz'den inen ya da çıkan her gemi yelkenini indirip durmak ve geçiş hakkını ödemek zorundaydı. Şehrin Karadeniz'den gelen tahılı artık Sultan'ın izniyle geçiyordu.","Large guns were set on the shore below the fortress. Every ship coming down from the Black Sea or going up to it had to lower its sails, stop and pay the toll. The grain the city received from the Black Sea now passed only with the Sultan's leave."
LORE_33O_3_T,Urban'ın ilk topu,Urban's first gun
LORE_33O_3,"Dökümcü Urban hizmetini önce İmparator'a sundu; istediği ücret ve malzeme karşılanamadı. Sultan'a geçti. Doukas'a göre Urban'ın Sultan için döktüğü ilk büyük top hisara kondu ve Kasım 1452'de Antonio Rizzo'nun Venedik gemisini tek gülleyle batırdı.","The founder Urban first offered his services to the Emperor, who could not meet his wages or supply his materials. He went over to the Sultan. According to Doukas, the first great gun Urban cast for the Sultan was set up at the fortress, and in November 1452 it sank Antonio Rizzo's Venetian ship with a single ball."
```

Replikler:

```csv
D33O_N_01,"Tolga Bey, 31 Ağustos 1452. Kuşatmaya yedi ay var. Dosyanın ilk sayfası bir inşaat: Boğaz'ın en dar yerinde bir hisar, bugün bitiyor.","Mr Tolga, 31 August 1452. Seven months until the siege. The file's first page is a building site: a fortress at the narrowest point of the Bosporus, finished today."
D33O_T_01,"Kuşatmanın dosyası inşaat ruhsatıyla mı açılıyor? Bizde de öyledir; önce bina, sonra hasar.","The siege file opens with a building permit? Same in our line of work: first the building, then the damage."
D33O_N_02,"Kayıtta göreviniz gümrük kâtibi. Kasım'da başlıyor; o zamana kadar ne iş verirlerse.","The record has you down as a toll clerk. That starts in November; until then, whatever job they hand you."
D33O_M_01,"Kâtip misin? Kalemi kulağına tak, taşı sırtına al. Akşam ezanına kadar bu kule kapanacak.","You're a clerk? Tuck your pen behind your ear and put a stone on your back. This tower closes before the evening call to prayer."
D33O_T_02,"Usta, ben gümrük için geldim. ...Tamam. Taş da bir çeşit gümrük.","Master, I'm here for the customs. ...Fine. A stone is a kind of customs too."
D33O_M_02,"Taşı al, iskeleye çık, yuvasına oturt. İki taşta bir kova harç. Kalasta rüzgâr çarpar; düşersen alt kat seni tutar, taşı tutmaz.","Take the stone, climb the scaffold, set it in its place. A bucket of mortar every two stones. The wind hits you on the plank; if you fall, the floor below catches you, not the stone."
D33O_Z_01,"Usta! Halil Paşa'nın kulesi bizden iki sıra önde. Bu tepe ondan geri kalırsa sen de duyarsın, ben de.","Master! Halil Pasha's tower is two courses ahead of us. If this hill falls behind his, you'll hear about it, and so will I."
D33O_H_01,"Zağanos acele eder. Benim kulem denize bakar. Deniz acele etmez, ama her şeyi sonunda o alır.","Zaganos is always in a hurry. My tower looks at the sea. The sea never hurries, but in the end it takes everything."
D33O_T_03,"İki vezir, iki kule, bir yarış. Bizde buna bütçe dönemi denir.","Two viziers, two towers, one race. Where I work we call that budget season."
D33O_M_STONE_1,"Oturdu. Taş da insan gibidir; yerini bulunca susar.","It's set. A stone is like a man; once it finds its place, it goes quiet."
D33O_M_STONE_BAD,"Oynuyor! Kaldır, bir daha. Bu duvara yüz yıl sonra da biri bakacak.","It's rocking! Lift it, again. Someone will still be looking at this wall in a hundred years."
D33O_T_STONE,"Beş yüz yılı geçer, usta. Biletle gezecekler.","More than five hundred, master. They'll buy tickets to walk round it."
D33O_M_MORTAR,"Harç! İki taş oldu. Harçsız üçüncüsü olmaz.","Mortar! That's two stones. No third without mortar."
D33O_T_WIND,"Rüzgâr! Kalasta sigortasız bir adam ve bir taş. İkimiz de düşmek istemiyoruz.","Wind! An uninsured man and a stone on a plank. Neither of us wants to fall."
D33O_M_FALL,"Düştün mü? Kat tuttu. Taş aşağıda. Git, getir.","Fell, did you? The floor caught you. The stone's at the bottom. Go and fetch it."
D33O_M_DONE,"Kule kapandı! Halil Paşa'nınkinden önce. Bunu kimseye söyleme; Zağanos Paşa'ya ben söylerim.","The tower is closed! Before Halil Pasha's. Don't tell anyone; I'll tell Zaganos Pasha myself."
D33O_M_DONE_LATE,"Ezan okundu. Kule kapandı, Halil Paşa'nınki de kapandı. Aynı gün; Sultan böyle istemişti.","There's the call to prayer. The tower is closed, and so is Halil Pasha's. The same day; that's how the Sultan wanted it."
D33O_F_01,"Bu hisarın adı Boğazkesen. Bu sudan bundan sonra kim geçerse önce bize sorar.","This fortress is called the Throat-Cutter. From now on, whoever passes on this water asks us first."
D33O_T_04,"Boğaz'ın en dar yeri. Karşıda öbür hisar. Ortadan geçen her gemi iki kalenin arasından geçecek. Gümrük kapısı, ama toplu.","The narrowest point of the Bosporus. The other fortress across the water. Every ship will pass between two castles. A toll gate, with guns."
D33O_N_03,"Kaydedildi: dört buçuk ayda bitti. Şimdi Kasım'a atlıyoruz, Tolga Bey. Gümrük kâtipliğiniz başlıyor.","Recorded: finished in four and a half months. Now we skip to November, Mr Tolga. Your clerkship at the toll begins."
D33O_FZ_01,"Kâtip! Dizdar Firuz Ağa benim. Kural basit: Karadeniz'den inen de çıkan da yelkeni indirir, kayığımız yanaşır, mal yazılır, hak alınır. İndirmeyene top konuşur.","Clerk! I am Firuz Agha, warden of this fortress. The rule is simple: up from the Black Sea or down, you lower your sail, our boat comes alongside, the cargo is written down, the toll is taken. Whoever won't lower, the gun talks to."
D33O_T_05,"Yelken indir, beyan et, prim öde. Ağam, siz sigortacılığı icat etmişsiniz.","Lower your sail, declare, pay the premium. Agha, you've invented insurance."
D33O_R_01,"Akıntı güneye çeker, kâtip. Ritmi kaçırırsan bizi Galata'ya kadar götürür.","The current pulls south, clerk. Lose the rhythm and it'll carry us all the way to Galata."
D33O_G_01,"Buyurun efendim! Tuzlu balık, kenevir, bir de... şarap. Biraz da sizin için, yolunuz açık olsun.","Welcome aboard, sir! Salt fish, hemp and... some wine. And a little something for you, for a smooth passage."
D33O_T_REFUSE,"Beyan eksiksiz. Hediye beyanda yok, bende de yok.","The declaration is complete. There's no gift on it, and none on me."
D33O_G_REFUSE,"Dürüst bir gümrükçü. Cenova'da anlatsam inanmazlar.","An honest customs man. Nobody in Genoa will believe me."
D33O_T_TAKE,"Numune. Kalite kontrolü. Bizim sektörde de her şey böyle başlar.","A sample. Quality control. In my line of work that's how everything starts."
D33O_N_TAKE,"Tolga Bey, numune şişesini lütfen kendi beyanınıza da ekleyin. Büro da kayıt tutar.","Mr Tolga, please add the sample bottle to your own declaration too. The Bureau keeps records as well."
D33O_T_STAMP,"Mühür. Geçebilirsiniz. Gemi hasarsız, mal hasarsız, kâtip hasarsız.","Stamped. You may pass. Ship undamaged, cargo undamaged, clerk undamaged."
D33O_FZ_SHIP,"Kuzeyden bir yelken! Venedik sancağı. Yelkenler dolu... İndirmiyor!","A sail from the north! Venetian colours. Sails full... He's not lowering!"
D33O_RZ_01,"Venedik gemisi! Konstantinopolis'e erzak! Kimseye yelken indirmeyiz!","Venetian ship! Provisions for Constantinople! We lower our sails to no one!"
D33O_FZ_WARN,"Uyarı atışı! Kâtip, küçük topa! Gemiye değil, burnunun önüne. Görsünler, duysunlar.","Warning shot! Clerk, to the small gun! Not at the ship, in front of its bow. Let them see it and hear it."
D33O_T_WARN,"Burnunun önüne. Bir hasar tespit uzmanından ilk kez kaza çıkarması isteniyor.","In front of the bow. For the first time someone's asking a claims assessor to cause an accident."
D33O_FZ_WARN_OK,"Tam önüne! Su burnuna kadar sıçradı. Şimdi indirir.","Right in front! The spray reached the bow. Now he'll lower."
D33O_FZ_WARN_HIT,"Gemiye değdi! Uyarı dedim, kâtip! Uyarı!","You hit the ship! I said a warning, clerk! A warning!"
D33O_FZ_WARN_MISS,"Uzağa düştü. Görmediler bile.","Way off. They didn't even see it."
D33O_RZ_02,"Rüzgâr bizim, akıntı bizim! Yelkenler kalsın!","The wind is ours, the current is ours! Keep the sails up!"
D33O_FZ_BIG,"İndirmiyor. Venedik inadı... Usta! Büyük topa!","He won't lower. Venetian stubbornness... Master! The great gun!"
D33O_U_01,"Sen, kâtip! Tokmağı al. Gülle ağır, top sabırsız. Ben 'nişan' derim, sen geminin gideceği yere bakarsın, durduğu yere değil.","You, clerk! Take the rammer. The ball is heavy, the gun impatient. I say aim, and you look where the ship is going, not where it is."
D33O_T_URBAN,"Usta Urban. ...Daha tanışmadık, değil mi? Tanışmadık. Tokmak bende.","Master Urban. ...We haven't met yet, have we? We haven't. I've got the rammer."
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
  - Kritovoulos dökümü ayrıntılı anlatır (topların genel dökümü bağlamında):
    - Kilden bir kalıp ve öz yapılır.
    - Kalıp demir ve kirişlerle sarılır, toprakla gömülür.
    - Tuğla fırınlarda bakır ve kalay günlerce körükle eritilir, kalıba akıtılır.
  - Kalıp soğuyunca kırılıp top çıkarılır. Oyun dökümü göstermez (10B'de var), çıkarmayı oynatır.
- **Gülleler.** Kritovoulos'a göre taş gülleler Karadeniz kıyısından getirilen sert taştan yontuldu. Ölçüleri namluya
  göre ayarlanırdı. Oyundaki çember (kalıp halka) ile kontrol, işin mantığına dayanan bir **oyun kurgusudur**.
- **Deneme atışı.** Ocak 1453'te top Edirne'de, Sultan'ın yeni sarayının kapısının önünde denendi (**D**).
  - Bir gün önce tellallar şehirde dolaşıp halkı uyardı: ses beklenmedik gelip insanları, özellikle gebe kadınları
    korkutmasın.
  - Doukas'a göre ses on mil öteden duyuldu. Gülle bir mil öteye düştü ve toprağa bir kulaç gömüldü. Rakamlar
    Doukas'ındır.
- **Şahi adı:** Osmanlı geleneğinde büyük toplara verilen ad. Oyun 28o'dan beri bu adı kullanıyor.
- **Sultan ve Urban'ın ücreti.** Sultan'ın Urban'a istediğinden fazlasını verdiği yazılır (**D**). Kesin oran
  kaynaktan kaynağa değişir, oyunda sayı söylenmez.
- Edirne manzarası: 1447'de bitmiş Üç Şerefeli Cami'nin minareleri ve yapımı süren yeni saray (Sarayiçi), Tunca kıyısında.

### 2.2 Yer ve sistemler

**Yeni küçük seviye:** `scripts/level/edirne_yard.gd` (`EdirneYard`). Yaklaşık 350 satır. Karlı bir Tunca kıyısı.
- **Döküm çukuru:** Dört kenarı toprak set. İçinde kil gömlekli, yarı gömülü dev namlu. Kil, kırıldıkça parça parça
  silinen düğümlerden oluşur; altındaki tunç ağı parlar.
- **Fırınlar ve kömür:** İki tuğla fırın (soğumuş, hafif dumanlı), kömür yığınları.
- **Taşçı tezgâhı:** Eğik oluk (gülleler yuvarlanır), çember kalıbı (dikilmiş ahşap halka), "kabul" arabası ve "geri"
  yığını.
- **Atış sahası:** Topun önünde ip çekilmiş güvenlik hattı (kazıklar + ip). Kar örtülü tarla, 380 m ötede bir tepede
  kırmızı bezli direk (hedef).
- **Arka plan:** Ufukta Edirne. Üç Şerefeli'nin dört minaresi (biri üç şerefeli), kubbeler, saray duvarları,
  kiremit çatılar (`OuterWorld` köy kümeleri, büyük `towns` yarıçapı). Tunca'nın su düzlemi.
- **Kar:** Zemin malzemesi beyaz-gri. Hafif kar tanesi `GPUParticles3D`. Ağaçlar çıplak (`Nature`).

**Kullanılan sistemler:**
- 21o'nun "kaz" (E basılı) mekaniği. 32o'nun basamak zamanlaması (tokmak: işaret ortadayken E).
- `Walker` ve `Person` (kalabalık, çocuklar kızakla). `Crowd.civilian` (uzak halk), `Horse` + `Person` (Sultan ve
  maiyeti, 29o'daki gibi yol üstünde yürüyüş).
- `CannonCrew` + `GunDrill`, gülle adımı **makara** ile:
  - Gülle elle taşınamaz. Üç ayaklı ahşap kaldıraç (makara) kullanılır.
  - "Gülle" adımı "E basılı tut: makarayla indir" olur (2,5 sn).
  - CannonCrew'a adım adı ve süresi parametresi eklenir; varsayılan davranış değişmez.
- `Fx.slowmo` + `Fx.fov_punch` (atış), `TespitCam`, `Lore.scatter(self, "34o")`.

**Süre hedefi:** 9–11 dk, diyalog ≤ 3 dk.

### 2.3 Fazlar

| Faz | Zaman | Hedef | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Kalıbı kır | Sabah | `UI_OBJ34O_DIG`, `UI_OBJ34O_BREAK` | (a) Namlunun çevresinde **dört işaretli yerde toprağı aç** (E basılı, 3 sn, 21o'daki kazı). İşçiler yanında kazar. (b) **Kil gömleği kır:** tahta tokmakla 8 darbe. İşaret yeşil banttayken E. Yeşil = kil parçası düşer. Kırmızıdayken basmak = tunca değdin, "çentik" (`D34O_U_HIT_BAD`). Iska sayılır ama darbe yine ilerler. Bant her darbede biraz daralır. | Başarısızlık yok. Sayaç: iyi darbe / 8. Çentik ≥ 3 ise Urban'ın sondaki repliği değişir (`D34O_U_END` → `_NICK`). |
| 2. Gülle ölçüsü | Öğle | `UI_OBJ34O_BALL` | Taşçı **sekiz gülleyi** oluktan tek tek yuvarlar. Her gülle çember kalıbın önünde durur, **6 sn** düşünme süresi var. **E = kabul** (arabaya), **F = geri** (yeniden yontulacak). Gülleyi gözle: ikisi kusurlu. Biri çembere takılır, açıkça büyüktür, yakından bakınca kalıp halkadan taşar. Öbüründe kılcal çatlak vardır (ince koyu çizgi, yakınken görünür). Süre dolarsa gülle kabul sayılır. | Doğru karar / 8. **Büyük gülle kabul edilirse** faz 4'te sıkışır: tokmak adımı iki tur sürer (`D34O_U_JAM`). **Çatlak gülle kabul edilirse** dosyaya not düşer (`D34O_M_WRONG`). Atışta kullanılmaz. |
| 3. Tellal | Öğleden sonra | `UI_OBJ34O_CROWD` | Tellal sahanın kenarından duyurur (yürüyüş durmaz). Tehlike konisinde **altı kişi** var (`Walker`): sepetli kadın, yaşlı adam, iki kızaklı çocuk, odun taşıyan arabacı, köpeğini arayan çırak. Her birine yaklaş ve E: "İpin arkasına!" Kişi ipin ardına yürür. Çocuklar bir kez daha kaçar, ikinci E gerekir. **90 sn.** | Süre biterse kalanları muhafızlar götürür, Urban bekler (`D34O_U_LATE`). Sayaç: Tolga'nın çıkardığı / 6. Sonuca etkisi yok, dosya notunda görünür. |
| 4. Deneme atışı | İkindi | `UI_OBJ34O_LOAD`, `UI_OBJ34O_PHOTO` | Sultan atla gelir, maiyetiyle ipin önünde durur. Kısa diyalog (Sultan ve Urban, Tolga araya girmez). Tolga topu **elle doldurur**: barut torbaları (3 kez, büyük top), tapa, **makara** (E basılı, gülle iner), tokmak (3 iyi vuruş, büyük gülle kabul edildiyse 6), nişan. Hedef 380 m ötedeki direk. Nişan yayı yalnız ilk 120 m'yi gösterir (büyük top, belirsiz menzil). Oyuncu yükseklik çizgisini Urban'ın tahta cetveline göre ayarlar ("üç parmak" ipucu). Ateşi Urban verir: ağır çekim 0,4×, görüş darbesi, kar sarsıntıyla dallardan düşer. **Tespit:** dumanın içinden Sultan ve at (hedef Sultan'ın başı). Pencere atıştan sonraki 15 sn. | Gülle direğin 25 m içine düşerse `hit = true` (toprak sütunu, gömülme izi). Değilse kısa düşer (karda iz). |

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **34O.1** Gülle işarete gömüldü | `hit` | `FLOW_34O_1` |
| **34O.2** Gülle karda kısa düştü | aksi hâlde | `FLOW_34O_2` |

Tarih aynıdır: top çalışır, Sultan onu İstanbul'a götürmeyi emreder.

**Otomatik test:** `--chapter=34 --autotest[=bad]`.
- Varsayılan 34O.1: bot 8/8 doğru karar verir, 6/6 kişiyi çıkarır, direği vurur, fotoğrafı çeker.
- `=bad`: bot bütün gülleleri kabul eder (sıkışma yolu denenir), kalabalıkta 2 kişide durur, kısa nişan alır → 34O.2.
  Denetimler: `JAM 1`, `CROWD 2/6`, `SHOT short`.
- `VISAUDIT`: Sultan'ın atı ve yürüyen kalabalık kar zeminine oturmalı (gömülme yok).

**Akış şeması** (`UI_FLOW34O_TITLE`): `FLOW34O_MOULD` → `FLOW34O_BALLS` → `FLOW34O_HERALD` → `FLOW34O_SHOT` →
{`34O.1`, `34O.2`}.

**Başarım önerisi:** `ACH_OSM_QC`: "Kalite Kontrol". Sekiz gülle, sekiz doğru karar.

### 2.4 Konuşanlar

Yeni anahtar:

| Anahtar | tr / en | Ses |
|---|---|---|
| `SPK_WOMAN` | Edirneli kadın / Woman of Edirne | Orta yaşlı, sepetli. Meraklı, korkmuyor, sorgulayıcı. Kuru bir halk mizahı var. |

Mevcut anahtarlar: `SPK_NIHAT`, `SPK_TOLGA`, `SPK_URBAN`, `SPK_MASON` (33o'da eklendi; burada gülle yontan başka bir
taşçı), `SPK_HERALD`, `SPK_TOWNSMAN` (yaşlı Edirneli; anahtar "Kentli", her şehir için genel), `SPK_FATIH`.

**Koşullu replikler:**
- `D34O_U_01_ALT` 33O.2 yolunda `D34O_U_01`'in yerine geçer.
- `D34O_U_HIT_OK` / `_BAD` olay bark'ıdır. `D34O_M_BIG` / `_CRACK` / `_GOOD` / `_WRONG` her karar için söylenir.
- `D34O_U_LATE` yalnız süre dolarsa söylenir.
- `D34O_U_JAM` yalnız büyük gülle kabul edildiyse söylenir.
- `D34O_U_HIT` / `_SHORT` sonuca göre seçilir.
- `D34O_U_END_NICK` çentik ≥ 3 ise `D34O_U_END`'in yerine geçer.
- `D34O_T_SULTAN` yalnız Bölüm 12 oynandıysa (`chapter_outcomes.has(12)`) söylenir, yoksa `_ALT`.

| Anahtar | Konuşan |
|---|---|
| `D34O_N_01` | SPK_NIHAT |
| `D34O_T_01` | SPK_TOLGA |
| `D34O_U_01` | SPK_URBAN |
| `D34O_U_01_ALT` | SPK_URBAN |
| `D34O_U_02` | SPK_URBAN |
| `D34O_T_02` | SPK_TOLGA |
| `D34O_U_HIT_OK` | SPK_URBAN |
| `D34O_U_HIT_BAD` | SPK_URBAN |
| `D34O_U_REVEAL` | SPK_URBAN |
| `D34O_T_REVEAL` | SPK_TOLGA |
| `D34O_M_01` | SPK_MASON |
| `D34O_T_03` | SPK_TOLGA |
| `D34O_M_BIG` | SPK_MASON |
| `D34O_M_CRACK` | SPK_MASON |
| `D34O_M_GOOD` | SPK_MASON |
| `D34O_M_WRONG` | SPK_MASON |
| `D34O_M_DONE` | SPK_MASON |
| `D34O_HR_01` | SPK_HERALD |
| `D34O_HR_02` | SPK_HERALD |
| `D34O_T_04` | SPK_TOLGA |
| `D34O_W_01` | SPK_WOMAN |
| `D34O_T_W1` | SPK_TOLGA |
| `D34O_W_02` | SPK_WOMAN |
| `D34O_TW_01` | SPK_TOWNSMAN |
| `D34O_T_KIDS` | SPK_TOLGA |
| `D34O_T_CROWD_OK` | SPK_TOLGA |
| `D34O_U_LATE` | SPK_URBAN |
| `D34O_F_01` | SPK_FATIH |
| `D34O_U_F1` | SPK_URBAN |
| `D34O_F_02` | SPK_FATIH |
| `D34O_U_F2` | SPK_URBAN |
| `D34O_T_SULTAN` | SPK_TOLGA |
| `D34O_T_SULTAN_ALT` | SPK_TOLGA |
| `D34O_U_LOAD` | SPK_URBAN |
| `D34O_U_JAM` | SPK_URBAN |
| `D34O_T_FIRE` | SPK_TOLGA |
| `D34O_U_HIT` | SPK_URBAN |
| `D34O_U_SHORT` | SPK_URBAN |
| `D34O_F_03` | SPK_FATIH |
| `D34O_T_PHOTO` | SPK_TOLGA |
| `D34O_N_END` | SPK_NIHAT |
| `D34O_U_END` | SPK_URBAN |
| `D34O_U_END_NICK` | SPK_URBAN |

### 2.5 Metinler

```csv
UI_CH34O_TITLE,BÖLÜM {N} — TUNCUN SESİ,CHAPTER {N} — THE VOICE OF BRONZE
UI_CH34O_SUB,"Ocak 1453 · Edirne, Tunca kıyısı · Urban'ın döküm yeri","January 1453 · Edirne, on the Tundzha · Urban's foundry"
UI_CH34O_SHOT,"Aynı gün, ikindi · deneme atışı","The same day, mid-afternoon · the test shot"
UI_FLOW34O_TITLE,AKIŞ ŞEMASI — BÖLÜM {N}: TUNCUN SESİ,FLOWCHART — CHAPTER {N}: THE VOICE OF BRONZE
SPK_WOMAN,Edirneli kadın,Woman of Edirne
UI_OBJ34O_DIG,Namlunun çevresinde toprağı aç (E basılı) · %d/%d,Dig the earth away from the barrel (hold E) · %d/%d
UI_OBJ34O_BREAK,"Kil kalıbı tokmakla kır (işaret yeşildeyken E) · %d/%d","Break the clay mould with the mallet (E while the marker is green) · %d/%d"
UI_OBJ34O_BALL,Gülleyi çemberle ölç: E kabul · F geri · %d/%d,Gauge the ball against the ring: E accept · F reject · %d/%d
UI_OBJ34O_CROWD,Tehlike alanındakileri ipin arkasına al · %d/%d,Get the people in the danger zone behind the rope · %d/%d
UI_OBJ34O_LOAD,"Topu doldur: barut, tapa, makara, tokmak, nişan","Load the gun: powder, wad, hoist, rammer, aim"
UI_OBJ34O_PHOTO,Tespit et: dumanın içinde Sultan,Record: the Sultan in the smoke
UI_PROMPT34O_DIG,E basılı: kaz,Hold E: dig
UI_PROMPT34O_STRIKE,E: vur (işaret yeşildeyken),E: strike (when the marker is green)
UI_PROMPT34O_ACCEPT,E: kabul · F: geri,E: accept · F: reject
UI_PROMPT34O_SHOO,E: İpin arkasına!,E: Behind the rope!
UI_PROMPT34O_HOIST,E basılı: gülleyi makarayla indir,Hold E: lower the ball with the hoist
FLOW34O_MOULD,Kil kalıp kırıldı,The clay mould is broken
FLOW34O_BALLS,Gülleler çemberden geçti,The balls go through the ring
FLOW34O_HERALD,Tellal ve kalabalık,The herald and the crowd
FLOW34O_SHOT,Sultan'ın önünde deneme atışı,The test shot before the Sultan
FLOW_34O_1,Gülle işarete gömüldü,The ball buried itself at the mark
FLOW_34O_2,Gülle karda kısa düştü,The ball fell short in the snow
UI_CH34O_STATS,Darbe: %d/%d   ·   Gülle kararı: %d/%d   ·   Kalabalık: %d/%d   ·   Atış: %s   ·   Dosya: %d/%d sayfa,Strikes: %d/%d   ·   Ball calls: %d/%d   ·   Crowd: %d/%d   ·   Shot: %s   ·   File: %d/%d pages
UI_CH34O_HIT,işarette,on the mark
UI_CH34O_SHORT,kısa,short
SIEGE_DATE_34,Ocak 1453,January 1453
SIEGE_EV_34,"Urban'ın Edirne'de döktüğü büyük top Sultan'ın sarayının önünde denenir. Tellallar halkı önceden uyarır; ses kilometrelerce öteden duyulur.","The great gun Urban cast at Edirne is tested before the Sultan's palace. Heralds warn the people beforehand; the sound is heard for miles."
SIEGE_NOTE_34O_1,"Kalıp kırıldı, gülleler ölçüldü, kalabalık ipin arkasındaydı. Gülle işarete gömüldü. Ekspertiz raporu: ürün çalışıyor. Ne yazık ki. — T.","The mould was broken, the balls gauged, the crowd behind the rope. The ball buried itself at the mark. Assessor's report: the product works. Unfortunately. — T."
SIEGE_NOTE_34O_2,"Kalıp kırıldı, gülleler ölçüldü. Gülle kısa düştü ama ses düşmedi; bütün Edirne duydu. Ekspertiz raporu: menzil eksik, gürültü fazla. — T.","The mould was broken, the balls gauged. The ball fell short but the sound didn't; all Edirne heard it. Assessor's report: range insufficient, noise excessive. — T."
LORE_34O_1_T,Kilden kalıp,A mould of clay
LORE_34O_1,"Kritovoulos topların dökümünü şöyle anlatır: kilden bir kalıp ve öz yapılır, demir ve kirişlerle sarılıp toprağa gömülür; tuğla fırınlarda bakır ve kalay günlerce körükle eritilir ve kalıba akıtılır. Soğuyunca kalıp kırılır ve tunç ortaya çıkar.","Kritovoulos describes how the guns were cast: a mould and a core are made of clay, bound with iron and timber and buried in earth; copper and tin are melted for days in brick furnaces with bellows and run into the mould. Once it cools, the mould is broken and the bronze appears."
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
D34O_U_02,"Önce toprağı aç. Sonra tokmakla kili kır. Yumuşak vur, işaret yeşilken. Tunca vurursan tunç sana küser.","First dig the earth away. Then break the clay with the mallet. Strike soft, while the marker is green. Hit the bronze and the bronze will hold it against you."
D34O_T_02,"Kalıbı kırarak teslim almak. Bizim sektörde hasarlı teslim alınmaz; burada hasarsız teslim alınmıyor.","Taking delivery by breaking the packaging. In my line of work you never accept damaged goods; here you can't get the goods without damage."
D34O_U_HIT_OK,"İyi. Kil dökülüyor, tunç parlıyor.","Good. The clay falls away, the bronze shines."
D34O_U_HIT_BAD,"Ah! Tunca değdin! Bir çentik. Topun da insanın da çentiği kalır.","Ah! You hit the bronze! A nick. Guns and men both keep their nicks."
D34O_U_REVEAL,"İşte. Namlunun ağzına bir adam sığar. Sultan buna Şahi diyecek. Ben çocuğum diyorum.","There. A man could crawl into its mouth. The Sultan will call it the Shahi. I call it my child."
D34O_T_REVEAL,"Namluya eğilip seslendim. Yankı geri gelmedi. Belki hâlâ gidiyordur.","I leaned into the barrel and called out. The echo didn't come back. Maybe it's still going."
D34O_M_01,"Gülleler hazır, kâtip. Karadeniz taşından yontuldu. Ustanın çemberinden geçen top içindir, geçmeyen yeniden yontulur. Çatlağa da bak; çatlak gülle namlunun ağzında dağılır.","The balls are ready, clerk. Cut from Black Sea stone. Whatever passes the master's ring goes to the gun; whatever doesn't gets recut. Watch for cracks too; a cracked ball shatters in the muzzle."
D34O_T_03,"Kalite kontrol. Sonunda kendi işimi yapıyorum.","Quality control. At last, my actual job."
D34O_M_BIG,"Çembere takıldı. Büyük. Namluda sıkışır.","It catches on the ring. Too big. It'd jam in the barrel."
D34O_M_CRACK,"Çatlak. Kılcal ama çatlak. İyi gördün.","Cracked. Hairline, but cracked. Good eye."
D34O_M_GOOD,"Temiz. Arabaya.","Clean. Onto the cart."
D34O_M_WRONG,"Onu kabul ettin ha? Usta görmesin.","You passed that one? Don't let the master see."
D34O_M_DONE,"Sekiz gülle, sekiz karar. Kâtiplerin en işe yarayanı sen çıktın.","Eight balls, eight calls. You're the most useful clerk I've ever met."
D34O_HR_01,"Duyduk duymadık demeyin! Sultan'ın topu bugün konuşacak! Gürültüden korkmayın, ipin önüne geçmeyin!","Hear ye, and say not you did not hear! The Sultan's gun speaks today! Be not afraid of the noise, and do not cross the rope!"
D34O_HR_02,"Gebe olan, hasta olan, yaşlı olan içeri girsin! Gök gürlemesi değildir, toptur!","Let those with child, the sick and the old stay indoors! It is not thunder, it is the gun!"
D34O_T_04,"Tellal duyuruyor, ben sahayı boşaltıyorum. Bir tatbikat bu. Çok gerçek bir tatbikat.","The herald announces, I clear the field. This is a drill. A very real drill."
D34O_W_01,"Kâtip efendi, bu top Edirne'yi mi vuracak, İstanbul'u mu?","Master clerk, is this gun going to hit Edirne, or Istanbul?"
D34O_T_W1,"Bugün sadece karşıdaki tepeyi, teyze. İpin arkasına, lütfen.","Today only the hill over there, auntie. Behind the rope, please."
D34O_W_02,"Tepe ne yaptı ki?","And what did the hill ever do?"
D34O_TW_01,"Ben Murad Han'ın toplarını da gördüm. Hiçbiri bunun yarısı kadar değildi.","I saw Sultan Murad's guns too. None of them was half this size."
D34O_T_KIDS,"Çocuklar! Kızakla ipin önüne değil! Benim kızaklarla ilgili kötü anılarım var.","Children! Not in front of the rope with that sled! I have bad memories involving sleds."
D34O_T_CROWD_OK,"Herkes ipin arkasında. Sahada şimdi tek risk benim.","Everyone's behind the rope. The only risk left on the field is me."
D34O_U_LATE,"Kalabalık hâlâ önde! Muhafızlar, çekin şunları! Top bekler, Sultan beklemez.","The crowd's still in front! Guards, move them back! The gun can wait, the Sultan won't."
D34O_F_01,"Usta Urban. Bunun gibisini Bizans'a da sunmuştun, değil mi?","Master Urban. You offered something like this to Byzantium as well, didn't you?"
D34O_U_F1,"Sundum, Sultanım. Ücretimi veremediler, tuncumu alamadılar. Siz istediğimden fazlasını verdiniz.","I did, my Sultan. They couldn't pay my wages or buy my bronze. You gave me more than I asked."
D34O_F_02,"Bana surları yıkacak bir top demiştin.","You promised me a gun that would bring down walls."
D34O_U_F2,"Babil'in surlarını bile, Sultanım. Bugün o tepeyi göreceksiniz, baharda surları.","Even the walls of Babylon, my Sultan. Today you'll see that hill; in the spring, the walls."
D34O_T_SULTAN,"Üç ay sonra otağında karşısında duracağım. O bunu bilmiyor. Ben de tam bilmiyorum aslında.","In three months I'll stand before him in his tent. He doesn't know that. To be honest, neither do I, quite."
D34O_T_SULTAN_ALT,"Yirmi yaşında. Atın üstünde dimdik. Bu topu dünyada ilk dinleyecek kişi o.","Twenty years old. Straight as a spear on his horse. He'll be the first person in the world to hear this gun."
D34O_U_LOAD,"Kâtip, makara! Gülleyi sen indir, yavaş. Sonra tokmak. Sonra nişan: o tepedeki kırmızı bez.","Clerk, the hoist! You lower the ball, slowly. Then the rammer. Then aim: the red cloth on that hill."
D34O_U_JAM,"Sıkıştı! Bu gülleyi kim geçirdi? ...Ben söylemeyeyim, sen bil. Tokmağa yüklen!","It's jammed! Who passed this ball? ...I won't say; you know. Lean on that rammer!"
D34O_T_FIRE,"Fitil yanıyor. Kulaklarım, size veda ediyorum.","The fuse is burning. Ears, it's been an honour."
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
- **Karaca Bey.** Rumeli Beylerbeyi Karaca Bey önceden gönderildi.
  - Trakya'daki Bizans kalelerini aldı: Karadeniz kıyısında Mesembria, Anchialos ve Vizye kolayca düştü.
  - Selymbria (Silivri) ve Epibatos direndi ve kuşatma boyunca dayandı (**R**).
  - Karaca Bey kuşatmada Rumeli askerinin başındaydı. Oyun onu yalnız yoldan geçen bir atlı olarak gösterir.
- **Sultan:** 23 Mart'ta Edirne'den çıktı, 5 Nisan'da surların önündeydi (**R**). 28o ertesi gün açılır.
- **Yol tasviri:** Mart'ta Trakya yolu, dere taşkınları, çamur ve yokuşlarda fren için kazığa sarılan halat. Yolun
  ayrıntıları **oyun kurgusudur**. Doukas yalnız adam, öküz, araba ve köprü sayısını verir.

### 3.2 Yer ve sistemler

**Yeni küçük seviye:** `scripts/level/thrace_road.gd` (`ThraceRoad`). Yaklaşık 400 satır. Sırtlar arasından inen
300 m'lik bir yol parçası:
- **Dere ve köprü:** Taşkın dere. Yarım kalmış ahşap köprü: dört sehpa kurulu, kalas yuvaları boş.
- **Çamur:** Karşı kıyıda çamurlu bir düzlük. Teker izleri, çamurda sıçrayan su.
- **İniş:** 70 m'lik bir yokuş, eğim ~12°. Yol kenarında iki **fren kazığı**: kalın meşe direk, halat sarılı.
- **Konak:** Yokuşun dibinde gece konağı. Ateşler, öküz sıraları, çadırlar.
- **Ufuk:** `OuterWorld` ile tarla lekeleri, köyler, uzak sırtlar. İlk bahar: çimen yer yer yeşil, ağaçlar çıplak.

**Konvoy:**
- 28o'nun Şahi namlusu ve kızağı (`chapter28o.gd` "Kızak: kalın kirişler, üstünde iki parçalı tunç namlu"). Bu kurucu
  ortak bir statik işleve taşınır, iki bölüm aynı topu görür.
- Namlunun altında birbirine bağlı **altı görünür araba** (otuzu temsil eder): tekerlekler, dingiller.
- Önde **çift çift öküz**: `Slipway._ox` statik yapılır. Yakında 12 canlı öküz, uzakta `MultiMesh` sıra. Boyunduruk
  ve çanlar. Yanlarda halat tutan iki sıra adam (`Crowd.ottoman`, `arm: ""`).

**Kullanılan sistemler:**
- 18'in halat bağlama zamanlaması (iki vuruş, E).
- 32o'nun taşıma döngüsü (kalas; demet).
- 28o'nun "hey-yap" çekişi (`RowMeter`, Space; kızak STEP ilerler, kayma geri götürür).
- `BalanceMeter` (fren ipi; ibre = arabanın hızı).
- Yürüyen arabacılar ve öküzler (`Horse` benzeri yürüyüş).
- `Night.campfire/torch`, `TespitCam`, `Lore.scatter(self, "35o")`.

**Süre hedefi:** 9–11 dk, diyalog ≤ 3 dk.

### 3.3 Fazlar

| Faz | Zaman | Hedef | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Köprü | Sabah | `UI_OBJ35O_PLANK`, `UI_OBJ35O_LASH` | Kıyıdaki istiften **kalas** al (sırtta, %30 yavaş). Köprünün ucundaki **boş yuvaya** koy (E). Kalası sehpaya **iki bağla** bağla (18'deki zamanlama: işaret yeşildeyken E, iki kez). **Altı kalas.** Köprünün ucu her kalasla ilerler, oyuncu yeni kalasın üstüne yürür. Arka planda öküz çanları yaklaşır. **4 dk.** Kaçan bağ = gevşek kalas (sarı işaret). Dülger uyarır, isteyen geri dönüp yeniden bağlar (E). | Süre biterse dülgerler kalan kalasları gevşek döşer. Sonra konvoy geçer: gevşek kalas başına bir gıcırtı. **≥ 2 gevşek kalas** → bir teker kalasları döndürüp dereye iner (`D35O_D_BREAK`), faz 2 bir demet fazla ve bir "kayma" ile başlar. |
| 2. Çamur | Öğle | `UI_OBJ35O_BUNDLE`, `UI_OBJ35O_HEAVE` | Öndeki araba karşı kıyıda çamura oturur. Yol kenarındaki yığından **çalı demeti** al, **ön tekerin önüne** at (E). **Üç demet**, köprü kırıldıysa dört. Sonra **"hey-yap"**: `RowMeter`, yeşilde Space. İki yüz adam ve öküzler birlikte çeker. İyi çekiş araba 1,5 m ilerletir. Demet tükenmeden çekilen ya da kırmızıda basılan çekiş kaydırır (−1 m). **12 m** sonra araba sert zemine çıkar. | Başarısızlık yok. Sayaç: kayma. |
| 3. İniş | İkindi | `UI_OBJ35O_BRAKE`, `UI_OBJ35O_POST` | Yokuşun başı. Fren halatı kazığa sarılıdır, ucu Tolga'nın elindedir. **`BalanceMeter`**: ibre arabanın hızıdır. **E basılı = sık** (ibre sola, yavaşlar), **bırak = gevşet** (ibre sağa). Teker izleri ve tümsekler ibreyi sağa iter (3–5 sn'de bir). Kırmızı sağ (≥ 1 sn) = araba kaçar: adamlar halata asılır, araba yan hendeğe kayar (**kayma**). Kırmızı sol (≥ 1,5 sn) = halat gerilir, öküzler bağırır: bir kez uyarı, ikincide halat kopar (yine kayma). Yokuşun yarısında halat **ikinci kazığa** aktarılır: Urban "Aktar!" der, oyuncu 6 m yürüyüp E'ye basar. **6 sn** içinde. Bu arada ibre kendi başına sağa kayar. **75 sn.** | Yokuşun sonunda sayaç kapanır: kayma (faz 2 + faz 3). |
| 4. Konak | Gece | `UI_OBJ35O_HAY`, `UI_OBJ35O_PHOTO` | Kısa ve sakin faz. Arabacı Durmuş'un yanında **altı öküze saman** (E, her öküzün başında). Öküzlerin adları bark olarak söylenir. Sonra **tespit karesi**: meşaleler arasında kızaktaki top, önünde yatan öküzler (hedef namlunun ağzı; serbest, süre yok). Urban'ın kısa gün sayımı ve Nihat'ın kaydı. | — |

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **35O.1** Top yokuşu kaymadan indi | toplam kayma ≤ 1 **ve** köprü kırılmadı | `FLOW_35O_1` |
| **35O.2** Top bir gün geç kaldı | aksi hâlde | `FLOW_35O_2` |

Tarih aynıdır: top Nisan başında surların önündedir. 35O.2'de Urban'ın 28o'daki ilk repliği aynı kalır. Fark dosya
notunda ve `D35O_U_END_*`'dadır.

**Otomatik test:** `--chapter=35 --autotest[=slip]`.
- Varsayılan 35O.1: bot 6 kalası iki bağla bağlar, 3 demet atar, 8 iyi çekiş yapar, ibreyi ortada tutar, kazığı
  4 sn'de aktarır.
- `=slip`: bot iki kalası tek bağla bırakır (köprü kırılır), kazık aktarmasında 8 sn bekler (kayma) → 35O.2.
  Denetimler: `BRIDGE broke`, `SLIPS >= 2`.
- `VISAUDIT`: öküzler ve araba tekerlekleri yol yüzeyine oturmalı (yokuşta da). Bu, Slipway'deki "ırgat askerleri
  yamaçta havada" hatasının tekrarı olmasın.

**Akış şeması** (`UI_FLOW35O_TITLE`): `FLOW35O_BRIDGE` → `FLOW35O_MUD` → `FLOW35O_SLOPE` → `FLOW35O_CAMP` →
{`35O.1`, `35O.2`}.

**Başarım önerisi:** `ACH_OSM_ROAD`: "Yol Kâtibi". Köprüde hiç gevşek kalas yok, yokuşta hiç kırmızı yok.

### 3.4 Konuşanlar

Yeni anahtarlar:

| Anahtar | tr / en | Ses |
|---|---|---|
| `SPK_DULGER` | Dülgerbaşı İlyas / İlyas, Master Carpenter | Kırk yaşında, hızlı konuşan, sürekli ölçen ustabaşı. Her şeyi "bunun üstünden tunç geçer mi" diye tartar. |
| `SPK_DROVER` | Arabacı Durmuş / Durmuş the Drover | Yaşlı, yavaş, öküzlerle konuşur gibi insanlarla da konuşur. Altmış öküzün adını bilir. |
| `SPK_KARACA` | Karaca Bey / Karaja Bey | Rumeli Beylerbeyi, atlı. Kısa, emir veren, aceleci. İki replik. |

Mevcut anahtarlar: `SPK_NIHAT`, `SPK_TOLGA`, `SPK_URBAN`.

**Koşullu replikler:**
- `D35O_D_LASH_OK` / `_BAD`, `D35O_U_SLIP`, `D35O_U_RUN`, `D35O_U_TIGHT` olay bark'larıdır.
- `D35O_D_CREAK` yalnız 1 gevşek kalasta, `D35O_D_BREAK` ≥ 2'de söylenir.
- `D35O_U_SLOPE_OK` / `D35O_U_SLIDE` sonuca göre seçilir.
- `D35O_U_END_OK` / `_BAD` sonuca göre seçilir.
- `D35O_DR_OX_*` öküz başına birer bark'tır.

| Anahtar | Konuşan |
|---|---|
| `D35O_N_01` | SPK_NIHAT |
| `D35O_T_01` | SPK_TOLGA |
| `D35O_D_01` | SPK_DULGER |
| `D35O_T_02` | SPK_TOLGA |
| `D35O_D_02` | SPK_DULGER |
| `D35O_D_LASH_OK` | SPK_DULGER |
| `D35O_D_LASH_BAD` | SPK_DULGER |
| `D35O_T_BRIDGE` | SPK_TOLGA |
| `D35O_DR_01` | SPK_DROVER |
| `D35O_D_CREAK` | SPK_DULGER |
| `D35O_D_BREAK` | SPK_DULGER |
| `D35O_U_01` | SPK_URBAN |
| `D35O_T_MUD` | SPK_TOLGA |
| `D35O_U_HEAVE` | SPK_URBAN |
| `D35O_U_SLIP` | SPK_URBAN |
| `D35O_U_FREE` | SPK_URBAN |
| `D35O_K_01` | SPK_KARACA |
| `D35O_U_K1` | SPK_URBAN |
| `D35O_K_02` | SPK_KARACA |
| `D35O_U_SLOPE` | SPK_URBAN |
| `D35O_T_SLOPE` | SPK_TOLGA |
| `D35O_U_POST` | SPK_URBAN |
| `D35O_U_RUN` | SPK_URBAN |
| `D35O_U_TIGHT` | SPK_URBAN |
| `D35O_U_SLIDE` | SPK_URBAN |
| `D35O_U_SLOPE_OK` | SPK_URBAN |
| `D35O_DR_02` | SPK_DROVER |
| `D35O_DR_OX_1` | SPK_DROVER |
| `D35O_DR_OX_2` | SPK_DROVER |
| `D35O_DR_OX_3` | SPK_DROVER |
| `D35O_T_OX` | SPK_TOLGA |
| `D35O_DR_03` | SPK_DROVER |
| `D35O_T_PHOTO` | SPK_TOLGA |
| `D35O_U_DAY` | SPK_URBAN |
| `D35O_T_DAY` | SPK_TOLGA |
| `D35O_U_END_OK` | SPK_URBAN |
| `D35O_U_END_BAD` | SPK_URBAN |
| `D35O_N_END` | SPK_NIHAT |
| `D35O_T_END` | SPK_TOLGA |

### 3.5 Metinler

```csv
UI_CH35O_TITLE,BÖLÜM {N} — EDİRNE YOLU,CHAPTER {N} — THE EDIRNE ROAD
UI_CH35O_SUB,"Mart 1453 · Trakya, taşkın bir derenin kıyısı · konvoyun önü","March 1453 · Thrace, the bank of a flooded stream · the head of the convoy"
UI_CH35O_SLOPE,"Aynı gün, ikindi · yokuş","The same day, mid-afternoon · the descent"
UI_FLOW35O_TITLE,AKIŞ ŞEMASI — BÖLÜM {N}: EDİRNE YOLU,FLOWCHART — CHAPTER {N}: THE EDIRNE ROAD
SPK_DULGER,Dülgerbaşı İlyas,"İlyas, Master Carpenter"
SPK_DROVER,Arabacı Durmuş,Durmuş the Drover
SPK_KARACA,Karaca Bey,Karaja Bey
UI_OBJ35O_PLANK,Kalası köprünün ucuna döşe · %d/%d,Lay the plank at the end of the bridge · %d/%d
UI_OBJ35O_LASH,Kalası sehpaya bağla (işaret yeşildeyken E) · %d/2,Lash the plank to the trestle (E while the marker is green) · %d/2
UI_OBJ35O_BUNDLE,Tekerin önüne çalı demeti at · %d/%d,Throw a brushwood bundle in front of the wheel · %d/%d
UI_OBJ35O_HEAVE,"Hey-yap! Çek (ibre yeşildeyken Space) · %d/%d m","Heave! Pull (Space when the needle is green) · %d/%d m"
UI_OBJ35O_BRAKE,Fren ipi: E basılı sık · bırak gevşet · ibreyi ortada tut,Brake rope: hold E to tighten · release to slacken · keep the needle centred
UI_OBJ35O_POST,İpi ikinci kazığa aktar (E) · %d sn,Move the rope to the second post (E) · %d s
UI_OBJ35O_HAY,Öküzlere saman ver · %d/%d,Give the oxen hay · %d/%d
UI_OBJ35O_PHOTO,Tespit et: meşaleler arasında top,Record: the gun among the torches
UI_PROMPT35O_PLANK,E: kalas al,E: take a plank
UI_PROMPT35O_LAY,E: kalası döşe,E: lay the plank
UI_PROMPT35O_LASH,E: bağla,E: lash it
UI_PROMPT35O_BUNDLE,E: demet al,E: take a bundle
UI_PROMPT35O_WHEEL,E: tekerin önüne at,E: throw it in front of the wheel
UI_PROMPT35O_POST,E: ipi kazığa sar,E: wrap the rope round the post
UI_PROMPT35O_HAY,E: saman ver,E: give hay
FLOW35O_BRIDGE,Taşkın derede köprü,A bridge over the flooded stream
FLOW35O_MUD,Çamurdan hey-yap,Heaving out of the mud
FLOW35O_SLOPE,Yokuşta fren ipi,The brake rope on the descent
FLOW35O_CAMP,"Gece konağı: öküzler, top, meşaleler","Night halt: oxen, gun, torches"
FLOW_35O_1,Top yokuşu kaymadan indi,The gun came down the slope without slipping
FLOW_35O_2,Top bir gün geç kaldı,The gun lost a day
UI_CH35O_STATS,Gevşek kalas: %d   ·   Kayma: %d   ·   Saman: %d/%d   ·   Dosya: %d/%d sayfa,Loose planks: %d   ·   Slips: %d   ·   Hay: %d/%d   ·   File: %d/%d pages
SIEGE_DATE_35,Şubat–Mart 1453,February–March 1453
SIEGE_EV_35,"Büyük top Edirne'den İstanbul'a iki ayda taşınır: otuz araba, altmış öküz, yanında iki yüz adam; önde köprü kuran ve yol düzelten dülgerler ve işçiler.","The great gun is moved from Edirne to Istanbul in two months: thirty wagons, sixty oxen, two hundred men walking beside it; ahead of it carpenters and labourers building bridges and levelling the road."
SIEGE_NOTE_35O_1,"Bir köprü, bir çamur, bir yokuş. Top kaymadı, öküzler doydu. Nakliye sigortası olsa hasarsızlık indirimi alırdık. — T.","One bridge, one mud hole, one hill. The gun didn't slip, the oxen were fed. If this were cargo insurance we'd get a no-claims discount. — T."
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
D35O_D_01,"Yol kâtibi! Dere taştı, köprü yarım. Kalasları taşı, yuvaya döşe, iple sehpaya bağla. Çanlar yaklaşmadan bitmeli.","Road clerk! The stream's flooded, the bridge is half done. Carry the planks, lay them in, lash them to the trestles. It has to be finished before the bells get here."
D35O_T_02,"Çanlar?","Bells?"
D35O_D_02,"Öküzlerin çanları. Onlar geldiğinde köprü yoksa altmış öküzün sabrı da yok.","The oxen's bells. If there's no bridge when they arrive, sixty oxen run out of patience."
D35O_D_LASH_OK,"Sıkı. Bunun üstünden tunç geçer.","Tight. Bronze can cross that."
D35O_D_LASH_BAD,"Gevşek! Bağ kayarsa kalas döner, teker düşer. Dön, bir daha bağla.","Loose! If the lashing slips the plank turns and the wheel goes through. Go back and lash it again."
D35O_T_BRIDGE,"Altı kalas, bir dere. Hayatımın ilk köprüsü. İçimden bir ses son olmayacak diyor.","Six planks, one stream. The first bridge of my life. Something tells me it won't be the last."
D35O_DR_01,"Çekil kâtip, öküzler geliyor! Hooo, Sarıkız, yavaş! Köprü bu, ahır değil!","Out of the way, clerk, the oxen are coming! Whoa, Sarıkız, easy! It's a bridge, not a barn!"
D35O_D_CREAK,"Bir kalas gıcırdadı... Teker geçti. Bir daha geçmez ama.","One plank creaked... The wheel got over. It won't a second time, though."
D35O_D_BREAK,"Kalas döndü! Teker dereye! Herkes ipe! Kâtip, senin bağın mıydı o?","The plank turned! Wheel in the stream! Everyone on the ropes! Clerk, was that one of your lashings?"
D35O_U_01,"Öndeki araba çamura oturdu. Kâtip, demetleri tekerin önüne! Sonra hep birlikte: hey-yap!","The lead wagon's sunk in the mud. Clerk, bundles in front of the wheel! Then all together: heave!"
D35O_T_MUD,"Mart, Trakya, çamur. Hiçbir belgesel bu kısmı çekmiyor.","March, Thrace, mud. No documentary ever films this part."
D35O_U_HEAVE,"Hey-yap! Bir daha! Bu tunç sizi bekler, siz onu bekletmeyin!","Heave! Again! This bronze waits for you; don't you keep it waiting!"
D35O_U_SLIP,"Geri kaydı! Demetsiz çekilmez!","It slid back! Don't pull without the bundles!"
D35O_U_FREE,"Çıktı! Yürüyor! Altmış öküz, iki yüz adam ve bir kâtip!","It's out! It's moving! Sixty oxen, two hundred men and one clerk!"
D35O_K_01,"Usta Urban! Silivri kapılarını kapadı, Epibatos da. Biz yolu açık tutuyoruz, sen topu yürüt.","Master Urban! Selymbria has shut its gates, and Epibatos too. We keep the road open; you keep the gun moving."
D35O_U_K1,"Yol açık olsun, Karaca Bey, ben yürütürüm. Şu yokuşu da siz düzeltseydiniz keşke.","Keep the road open, Karaja Bey, and I'll keep it moving. I only wish you'd levelled that hill as well."
D35O_K_02,"Yokuş Allah'ın, düz yol bizim. Yokuşu sen halledeceksin.","The hill is God's, the flat road is ours. The hill is your problem."
D35O_U_SLOPE,"Yokuş! Kâtip, fren ipi sende, kazığa sarılı. Çok gevşetirsen araba öküzleri ezer, çok sıkarsan ip kopar.","The descent! Clerk, the brake rope is yours, it's wrapped round the post. Slacken too much and the wagon runs over the oxen; pull too hard and the rope snaps."
D35O_T_SLOPE,"Yani tam ortası. Hayatım boyunca benden hep tam ortasını istediler.","So, right in the middle. All my life people have asked me for right in the middle."
D35O_U_POST,"İkinci kazık! İpi aktar, çabuk!","The second post! Move the rope, quick!"
D35O_U_RUN,"Kaçıyor! Sık! Sık!","She's running! Tighten! Tighten!"
D35O_U_TIGHT,"Fazla sıktın! Öküzler bağırıyor! Gevşet biraz!","Too tight! The oxen are bellowing! Let it out a little!"
D35O_U_SLIDE,"Kaydı... yan hendeğe. Sabaha kadar çıkarırız. Bir gün kaybettik.","She slid... into the side ditch. We'll have her out by morning. We've lost a day."
D35O_U_SLOPE_OK,"Aşağıda! Tek kayma yok. Kâtip, bunu Sultan'a ben anlatacağım, sen yazacaksın.","At the bottom! Not a single slip. Clerk, I'll tell the Sultan, you'll write it down."
D35O_DR_02,"Öküzlere saman, kâtip. Bu yolun asıl askerleri onlar.","Hay for the oxen, clerk. They're the real soldiers on this road."
D35O_DR_OX_1,"Bu Sarıkız. Önde o yürür, öbürleri ona bakar.","This is Sarıkız. She walks in front; the others follow her."
D35O_DR_OX_2,"Karabaş. Yokuşta en çok o yük çeker, saman da en çok ona.","Karabaş. He pulls hardest on the hills, so he gets the most hay."
D35O_DR_OX_3,"Benekli. Huysuzdur. Elini başına değil, boynuna koy.","Benekli. Bad-tempered. Put your hand on his neck, not his head."
D35O_T_OX,"Altmış öküz ve her birinin adı var. Durmuş Ağa hepsini biliyor.","Sixty oxen and every one of them has a name. Durmuş Agha knows them all."
D35O_DR_03,"Bilmesem çekmezler. Adını bilmediğin hayvan senin için yürümez.","If I didn't, they wouldn't pull. An animal won't walk for you if you don't know its name."
D35O_T_PHOTO,"Meşale ışığında top. Kızağın üstünde, öküzlerin arasında. Bu kare sigortaya gitmez, müzeye gider.","The gun by torchlight. On its sled among the oxen. This shot doesn't go to an insurer; it goes to a museum."
D35O_U_DAY,"Kâtip, defterine yaz: yolda kırk birinci gün. Köprü sayısı belli değil, çamur sonsuz.","Clerk, put it in your ledger: day forty-one on the road. Number of bridges unknown, mud infinite."
D35O_T_DAY,"Yazdım. Altına bir not ekledim: usta yorgun, top değil.","Written. I added a note underneath: master tired, gun not."
D35O_U_END_OK,"Nisan başında surların önündeyiz. Sultan gelmeden topun yatağı hazır olacak.","By early April we're before the walls. The gun's bed will be ready before the Sultan arrives."
D35O_U_END_BAD,"Bir gün kaybettik ama topu kaybetmedik. Nisan başında yine surların önündeyiz.","We lost a day but we didn't lose the gun. We'll still be before the walls in early April."
D35O_N_END,"Kaydedildi. Kaynaklara göre top iki ayda surların beş mil yakınına vardı. Sultan 23 Mart'ta Edirne'den çıkacak, 5 Nisan'da ordu surların önünde olacak. Sıradaki kayıt: siper ve kazık.","Recorded. According to the sources the gun reached five miles from the walls in two months. The Sultan leaves Edirne on 23 March, and on 5 April the army will be before the walls. Next entry: rampart and stakes."
D35O_T_END,"Bu kadar emek bir duvarı yıkmak için. Bizim şirkette buna yatırım derdik.","All this effort to knock down one wall. At my company we'd call this an investment."
```

```csv
UI_RECAP_35O_PREV,"Edirne'de kalıbı kırdın, gülleleri ölçtün, kalabalığı ipin arkasına aldın; Sultan'ın önünde top ilk kez konuştu.","At Edirne you broke the mould, gauged the balls and moved the crowd behind the rope; before the Sultan, the gun spoke first."
UI_RECAP_35O_NEXT,"Top surların önünde. 6 Nisan: ordu toprağa giriyor; 11 Nisan'da topu bataryasına çekeceğiz.","The gun is before the walls. 6 April: the army digs in; on 11 April we haul the gun into its battery."
```

---

## 4. Bölüm 36o — "İlk Hücum" (18 Nisan 1453 gecesi)

### 4.1 Tarihî dayanak

- **Gedik ve barikat.** Bombardımanın ilk haftasında Lykos vadisinde (Mesoteichion) dış sur yer yer çöktü.
  - Giustiniani'nin adamları yıkılan yerlere barikat (stockade) ördü: kazıklar, kalaslar, çalı, toprak dolu fıçılar,
    üstünde ıslak deriler (**R**, **B**).
  - Oyunda bu barikat `LandWalls` gedik molozunun üstündeki mevcut barikattır (`set_repair`).
- **18 Nisan.** Güneş battıktan yaklaşık iki saat sonra Sultan Mesoteichion'daki barikata ilk büyük hücumu emretti
  (**B**, **R**).
  - Okçular, ağır piyade ve yeniçeriler davul ve borularla geldi. Meşalelerle barikatı yakmaya, kancalarla fıçıları
    indirmeye, merdivenlerle tırmanmaya çalıştılar.
  - Yer dar olduğu için sayılarının faydası olmadı. Dört saat sonra çekildiler.
  - Barbaro saldıranlardan yaklaşık 200 kişinin öldüğünü, savunanlardan hiç kimsenin ölmediğini yazar. Rakam
    abartılı olabilir (**R** de çekinceyle aktarır). Nihat "Barbaro yazar" diyerek söyler.
- **Bağlam:** Aynı günlerde Sultan surların dışında kalan küçük Bizans kalelerini (Therapia, Studios) aldırdı,
  Baltaoğlu Prens Adaları'nı (Prinkipo) aldı (**K**, **R**). Oyun bunları göstermez. Nihat tek cümleyle anar (`D36O_N_01`).
  20 Nisan'da deniz savaşı gelir (29o).
- Kerkoporta yok. Ölüm gösterilmez. Düşen saldıranlar `StoryDuel.make` kuralıyla teslim olur ya da geri çekilir.

### 4.2 Yer ve sistemler

**Yeni seviye yok.**
- **Harita:** `LandWalls` (gedik + barikat, varsayılan; `intact = false`) + `SiegeField` (`near_works`, gece).
  20o ve 32o ile aynı Lykos kesiti.
- **Işık:** `Night.environment`. Ay yok (18 Nisan'da hilal batmış sayılır). Meşale ve ateş ışığı.
- `Assault.build()` ordu bloklarıyla, ama **merdiven ve dalga kalabalığı seyrek** (ilk hücum; `waves` yoğunluğu 0,4).
  Yoksa 32o'nun `build_calm()`'u + gece ve tek bir koşan dalga.
- `WallFight`: barikatın arkasında kova taşıyan ve su döken savunucular, kazanlar (yağ değil **su**: `pour` su
  rengiyle).

**Kullanılan sistemler:**
- 32o'nun mantolu ok yaylımı (`Assault.volley`, siperde değilsen −30 can).
- 29o'nun kanca atışı (`_throw`, hedef işareti küpeşte yerine fıçı).
- 28o / 35o'nun `RowMeter` "çek" ritmi (kancalı ipi çekmek).
- Meşale atışı: kanca atışının aynısı. Yay ve `Vfx.fire`. `SiegeTower.burn`'deki alev büyütme mantığı barikatın üç
  kesitine uyarlanır.
- `Gunner` (barikatın tepesinde), `WaveRunner` (moloz tepesinde), `StoryDuel`, `TespitCam`, `Grade.finish("36o")`,
  `Lore.scatter(self, "36o")`.
- `Audio.intensity` 1 → 3 → 0, `Fx.slowmo` (fıçı yuvarlanırken), `Audio.stinger("warn")`.

**Barikat düzeni (yeni, bölüm içinde):**
- Barikatın üstünde **5 fıçı**: `LandWalls` barikat aşamasının en üst sırası; her fıçı ayrı düğüm.
- Barikatın ova yüzünde **3 kalas kesiti** (sol, orta, sağ). Her kesitin "açık" (deri sıyrılmış) bir alanı var.
- Fıçı indirilince arkasındaki kalas kesiti açığa çıkar ve meşaleye karşı zayıflar: söndürme süresi 8 sn'den
  12 sn'ye çıkar.

**Süre hedefi:** 10–12 dk, diyalog ≤ 2,5 dk.

### 4.3 Fazlar

| Faz | Zaman | Hedef | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 0. Batarya | Akşam | — | Urban'ın bataryasında kısa açılış (yürürken). Yeniçeri çavuşu Tolga'ya **kancalı sırık** ve sırtına bağlı **meşale demeti** verir (E). Davullar başlar. | — |
| 1. Ölü bölge | Güneş batışı + 2 saat | `UI_OBJ36O_CROSS`, `UI_OBJ36O_COVER` | Siperden hendek kıyısına **90 m**, bölükle birlikte. Surdan **ok yaylımı** 10–14 sn'de bir (32o kuralı): "Ok!" uyarısından 2 sn içinde **mantonun** arkasında değilsen −30 can. Ölü bölgede dört manto. Savunucuların fırlattığı **ateş çömlekleri** yerde yanar, alan aydınlanır ve 6 sn yürünmez (−10 can/sn). Hendek henüz dolu değil: kıyıdaki **köprü merdivenini** geç (yatay `Ladder`; 8 m, dengede yürüme yok, yalnız dar). | Can biterse yere düşülür. Yeniçeri çavuşu kaldırır (`D36O_J_DOWN`), mantonun arkasında 40 canla kalkılır. |
| 2. Kanca | Gece | `UI_OBJ36O_HOOK`, `UI_OBJ36O_PULL` | Moloz yamacının dibinde. Barikatın tepesindeki fıçılardan birine **nişan al ve kancayı at** (E). Hedef işareti fıçının çemberi; menzil 4–9 m. Takılırsa **çek**: `RowMeter`, iki yoldaşla. **4 iyi çekiş** fıçıyı devirir. Fıçı molozdan yuvarlanır: **kaç!** 1,5 sn ağır çekim. Fıçı yolu çizgiyle gösterilir, 2 m içindeysen −25 can. Savunucular ipi içeri çeker: **iki kötü çekiş** (kırmızı) sırığı kaybettirir. Yeni sırık yığından alınır (6 m geride). Barikatın tepesinde bir **tüfekçi** (`Gunner`) nişan alır: yana kay ya da mantoya geç. **Hedef: 3 fıçı, 2 dk 30 sn.** | Sayaç: indirilen fıçı (0–5). |
| 3. Meşale | Hemen ardından | `UI_OBJ36O_TORCH`, `UI_OBJ36O_PHOTO` | Çavuş meşaleleri tutuşturur. Tolga **4 meşale** atar (E; yay, 6–12 m). Açık kalas kesitine düşen meşale kesiti tutuşturur. Savunucular kovayla 8 sn'de (fıçısı indirilmiş kesitte 12 sn'de) söndürür. **İki kesit aynı anda yanarsa** "yanıyor" eşiği aşılır: alevler büyür, savunucular deri ve toprakla gelir. Sonunda söndürürler (tarih), ama sayaç yazılır. Bu fazın ortasında Giustiniani barikatın tepesine çıkar ve bağırır. **Tespit karesi:** meşale ışığında miğferi (hedef baş, 15 sn pencere). | Sayaç: aynı anda yanan en çok kesit (0–3). Meşaleler bitince faz biter. |
| 4. Moloz | Gece yarısına doğru | `UI_OBJ36O_FIGHT` | Bölük moloz yamacına çıkar. **`WaveRunner`**: 1. dalga 2 Cenevizli, 2. dalga 2 savunucu (aynı anda en çok 2). Yanında 1 yeniçeri. Barikatın tepesinde `Gunner`. Fıçı indirilen kesitlerin önü daha alçaktır, dövüş orada geçer. **90 sn.** | Kaybedilirse Tolga molozdan yuvarlanır (`D36O_T_LOST`). Kazanılırsa da tarih aynıdır: boru çalar. |
| 5. Geri çekilme | Gece yarısından sonra | `UI_OBJ36O_BACK` | "Geri!" borusu. Ölü bölgeyi geri geç (60 m, **iki yaylım**, mantolar). Siperde ulak Tolga'yı bulur → 29o'ya bağ. Nihat'ın kaydı. | — |

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **36O.1** Barikat tutuştu, fıçılar indi | indirilen fıçı ≥ 2 **ve** aynı anda yanan kesit ≥ 2 | `FLOW_36O_1` |
| **36O.2** Barikat bütün kaldı | aksi hâlde | `FLOW_36O_2` |

Tarih ikisinde de aynıdır: hücum püskürtülür. Fark Urban'ın son repliğinde (`D36O_U_END_OK` / `_BAD`) ve dosya
notundadır. Dövüş sonucu sonucu bozmaz; savaş karnesine gider. Akış şemasının altında `Grade.finish("36o")` çalışır.
Bu satır ve `ACH_FLAWLESS` ("Ayakta") için 36o savaş bölümleri listesine eklenir.

**Otomatik test:** `--chapter=36 --autotest[=weak|lose]`.
- Varsayılan 36O.1: bot yaylımda mantoya geçer, 3 fıçı indirir, iki kesiti birlikte tutuşturur, dövüşü kazanır
  (`duel.god`), kareyi çeker.
- `=weak`: bot 1 fıçıda durur, meşaleleri açık olmayan yere atar → 36O.2. Denetim: `BARRELS 1`, `BURN 1`.
- `=lose`: bot düelloda savunmasız durur, tüfekçiden kaçmaz. Denetimler: `player.downs >= 1`, kaybedilmiş düello,
  sonuç yine 36O.1/2 kuralına göre.
- Fıçı yuvarlanma yolu ve kalabalığın moloz yüzeyine oturması `VISAUDIT` ile denetlenir. 20o'daki "moloz dili
  görüntüden ibaret" hatası tekrarlanmasın: dövüş alanı `LandWalls`'ın katı katmanlarıdır.

**Akış şeması** (`UI_FLOW36O_TITLE`): `FLOW36O_CROSS` → `FLOW36O_HOOKS` → `FLOW36O_TORCH` → `FLOW36O_FIGHT` →
`FLOW36O_HORN` → {`36O.1`, `36O.2`}. Altında `Grade.finish("36o")` ve `UI_CH36O_STATS`.

**Başarım önerisi:** `ACH_OSM_HOOK`: "Fıçı Avcısı". Beş fıçının beşini indir.

### 4.4 Konuşanlar

Yeni anahtar yok. Kullanılanlar: `SPK_NIHAT`, `SPK_TOLGA`, `SPK_URBAN`, `SPK_JANISSARY` (bölüğün çavuşu; 32o'daki
"Sükût!" diyen yeniçeri değil, aynı genel anahtar), `SPK_DEFENDER`, `SPK_GIUST`, `SPK_RIDER`.

Giustiniani'nin repliği Osmanlı tarafından duyulan bir bağırıştır. Altyazı Türkçe çevirisidir. İsteğe bağlı olarak
seslendirmede İtalyanca okunabilir, altyazı yine çeviri kalır.

**Koşullu replikler:**
- Olay bark'ları: `D36O_J_VOLLEY`, `_SAFE`, `D36O_T_HIT`, `D36O_J_DOWN`, `D36O_J_PULL`, `_BARREL`, `_CUT`,
  `D36O_T_DODGE`, `D36O_D_*`, `D36O_J_BURN`, `_OUT`.
- `D36O_T_WON` / `D36O_T_LOST` dövüşe göre seçilir.
- `D36O_U_END_OK` / `_BAD` sonuca göre seçilir.

| Anahtar | Konuşan |
|---|---|
| `D36O_N_01` | SPK_NIHAT |
| `D36O_U_01` | SPK_URBAN |
| `D36O_T_01` | SPK_TOLGA |
| `D36O_J_01` | SPK_JANISSARY |
| `D36O_T_02` | SPK_TOLGA |
| `D36O_J_VOLLEY` | SPK_JANISSARY |
| `D36O_J_SAFE` | SPK_JANISSARY |
| `D36O_T_HIT` | SPK_TOLGA |
| `D36O_J_DOWN` | SPK_JANISSARY |
| `D36O_T_DITCH` | SPK_TOLGA |
| `D36O_J_HOOK` | SPK_JANISSARY |
| `D36O_J_PULL` | SPK_JANISSARY |
| `D36O_J_BARREL` | SPK_JANISSARY |
| `D36O_T_DODGE` | SPK_TOLGA |
| `D36O_J_CUT` | SPK_JANISSARY |
| `D36O_D_01` | SPK_DEFENDER |
| `D36O_J_TORCH` | SPK_JANISSARY |
| `D36O_T_TORCH` | SPK_TOLGA |
| `D36O_D_WATER` | SPK_DEFENDER |
| `D36O_J_BURN` | SPK_JANISSARY |
| `D36O_J_OUT` | SPK_JANISSARY |
| `D36O_GU_01` | SPK_GIUST |
| `D36O_T_GIUST` | SPK_TOLGA |
| `D36O_N_PHOTO` | SPK_NIHAT |
| `D36O_J_FIGHT` | SPK_JANISSARY |
| `D36O_T_FIGHT` | SPK_TOLGA |
| `D36O_T_WON` | SPK_TOLGA |
| `D36O_T_LOST` | SPK_TOLGA |
| `D36O_J_HORN` | SPK_JANISSARY |
| `D36O_T_RETREAT` | SPK_TOLGA |
| `D36O_U_END_OK` | SPK_URBAN |
| `D36O_U_END_BAD` | SPK_URBAN |
| `D36O_RD_01` | SPK_RIDER |
| `D36O_T_RIDER` | SPK_TOLGA |
| `D36O_N_END` | SPK_NIHAT |

### 4.5 Metinler

```csv
UI_CH36O_TITLE,BÖLÜM {N} — İLK HÜCUM,CHAPTER {N} — THE FIRST ASSAULT
UI_CH36O_SUB,"18 Nisan 1453 · Mesoteichion, gedikteki barikat · gece","18 April 1453 · The Mesoteichion, the stockade in the breach · night"
UI_FLOW36O_TITLE,AKIŞ ŞEMASI — BÖLÜM {N}: İLK HÜCUM,FLOWCHART — CHAPTER {N}: THE FIRST ASSAULT
UI_OBJ36O_CROSS,Bölükle ölü bölgeyi geç: hendeğin kıyısına,Cross the dead ground with your company: to the edge of the moat
UI_OBJ36O_COVER,Ok! Mantonun arkasına geç,Arrows! Get behind a mantlet
UI_OBJ36O_HOOK,Barikatın fıçısına kanca at (E) · indirilen %d/%d,Throw the hook at a barrel on the stockade (E) · pulled down %d/%d
UI_OBJ36O_PULL,"Çek! (ibre yeşildeyken Space) · %d/4","Pull! (Space when the needle is green) · %d/4"
UI_OBJ36O_TORCH,Meşaleyi açık kalasa at (E) · meşale %d/%d,Throw the torch at the bare timber (E) · torch %d/%d
UI_OBJ36O_PHOTO,Tespit et: barikatın tepesinde Giustiniani,Record: Giustiniani on top of the stockade
UI_OBJ36O_FIGHT,Moloz yamacında tutun,Hold on the slope of rubble
UI_OBJ36O_BACK,Geri çekil: siperin arkasına,Fall back: behind the rampart
UI_PROMPT36O_POLE,E: kancalı sırığı al,E: take a hook pole
UI_PROMPT36O_THROW,E: kancayı at (fıçının çemberine),E: throw the hook (at the barrel's hoop)
UI_PROMPT36O_TORCH,E: meşaleyi at,E: throw the torch
UI_HINT36O_ROLL,FIÇI GELİYOR! Yoldan çekil!,BARREL COMING! Get out of the way!
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
D36O_J_01,"Kâtip! Sırık sende, meşale sırtında. Ölü bölgeyi geç; ok gelirse mantoya. Barikatın fıçılarını kancayla indireceğiz, kalaslarını yakacağız.","Clerk! The pole's yours, the torches on your back. Cross the dead ground; if arrows come, get behind a mantlet. We pull the stockade's barrels down with hooks and burn its timber."
D36O_T_02,"Kanca, meşale, gece. Sigortada buna kasıt unsuru denir.","Hooks, torches, darkness. In insurance we call this intent."
D36O_J_VOLLEY,"Ok! Mantoya!","Arrows! Behind the mantlet!"
D36O_J_SAFE,"Geçti! İleri!","It's passed! Forward!"
D36O_T_HIT,"Omzum! Gece de nişan alıyorlar. Fazla mesai.","My shoulder! They aim in the dark too. Overtime."
D36O_J_DOWN,"Kâtip! Kalk! Mantonun arkasına çekin onu!","Clerk! Up! Drag him behind the mantlet!"
D36O_T_DITCH,"Hendek dolu değil. Merdiveni köprü yaptılar. Merdiven yatay durunca da korkutucuymuş.","The moat isn't filled. They've laid a ladder across as a bridge. Turns out a ladder is frightening lying down too."
D36O_J_HOOK,"Fıçılar tepede. Kancayı çembere at, takılınca hep birlikte çek!","The barrels are on top. Throw the hook at a hoop; when it catches, pull together!"
D36O_J_PULL,"Çek! Çek! Hey!","Pull! Pull! Heave!"
D36O_J_BARREL,"Devrildi! Çekil, yuvarlanıyor!","Over it goes! Get clear, it's rolling!"
D36O_T_DODGE,"Toprak dolu bir fıçı yanımdan geçti. Hayatımın en ağır hasar tespiti olabilirdi.","A barrel full of earth just rolled past me. That could have been the heaviest claim of my life."
D36O_J_CUT,"Sırığı içeri çektiler! Yığından yenisini al!","They've pulled the pole in! Get another from the pile!"
D36O_D_01,"Kancalar! İpleri kesin! Toprak dökün!","Hooks! Cut the ropes! Throw earth down!"
D36O_J_TORCH,"Kalaslar açıkta! Meşaleleri at! İki yer birden yanarsa söndüremezler!","The timber is bare! Throw the torches! If two places burn at once they can't put it out!"
D36O_T_TORCH,"Meşale atıyorum. Kasko poliçesinin hiçbir maddesinde kendimi bu kadar suçlu hissetmemiştim.","I'm throwing torches. No clause in any car policy has ever made me feel this guilty."
D36O_D_WATER,"Su! Derileri ıslatın! Ateşe su!","Water! Wet the hides! Water on the fire!"
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

`D36O_RD_01`'deki "Çifte Sütunlar" Diplokionion'dur (bugünkü Beşiktaş). 29o'da Sultan'ın atını denize sürdüğü kıyı
burasıdır, Baltaoğlu'nun donanmasının demir yeri de burasıdır (**R**).

---

## 5. Akış: yeni Osmanlı başlangıcı

| # | İç id | Sahne | Tarih | Tolga ne yapar | Sonuçlar |
|---|---|---|---|---|---|
| 13 | 33 | `chapter33o` (yeni) | 31 Ağustos ve 26 Kasım 1452 | taş taşı, iskelede denge, harç; kürek, beyan, seçim; uyarı atışı (elle top); büyük top | 33O.1 / 33O.2 |
| 14 | 34 | `chapter34o` (yeni) | Ocak 1453 | kaz, kalıp kır (zamanlama); gülle kabul/geri; kalabalığı ipin arkasına al; makara + elle top | 34O.1 / 34O.2 |
| 15 | 35 | `chapter35o` (yeni) | Şubat–Mart 1453 | kalas döşe + bağla; demet + hey-yap; fren ipi (denge); saman | 35O.1 / 35O.2 |
| 16 | 28 | `chapter28o` | 6 ve 11–12 Nisan | (değişmedi; açılış 3 replik) | 28O.1 / 28O.2 |
| 17 | 36 | `chapter36o` (yeni) | 18 Nisan gecesi | mantolu geçiş, kanca at + çek, kaç, meşale at, moloz dövüşü, tespit | 36O.1 / 36O.2 |
| 18 | 29 | `chapter29o` | 20 Nisan | (değişmedi) | 29O.1 / 29O.2 |
| … | | | | OTTOMAN_STORY §1'deki sıra, numaralar +4 | |

**Hikâye bağları:**
- **Urban'ın ipi:** 33o ilk top → 34o büyük top → 35o yol → 28o batarya → 36o barikat → 20o gedik.
  Urban'ın "kâtip" hitabı ve "Tunç sabır ister" sözü 28o'dan önce kurulmuş olur. 20o'daki
  `D20O_U_01` ("Kazanı patlatan, sonra kaçan adam… Yoksa başkası mıydı?") Bölüm 6a'ya gönderme yapar ve olduğu gibi
  kalabilir: Urban, Tolga'yı hem kâtibi hem de garip bir yabancı olarak hatırlar.
- **Halil ve Zağanos:** 33o'daki kule yarışı, 25'teki meclis karşıtlığının (barış / hücum) tohumudur.
- **Tellal:** 34o'daki tellal ile 32o'daki tellal aynı anahtardır. İlk ve son duyuru aynı sesle yapılır.
- **Kanca:** 29o'da Baltaoğlu'nun kancaları, 36o'da barikatın kancaları. 36o'nun ulağı Tolga'yı doğrudan kadırgaya
  gönderir.
- **Büro hiç anılmaz:** NPC'ler Tolga'ya "kâtip", "gümrük kâtibi", "yol kâtibi", "topçu kâtibi" der. "Büro" kelimesi
  yalnız Nihat'ın telsizinde (`D33O_N_TAKE`) geçer.

**Seslendirme listesi:** Yeni replikler `docs/voice/NEW_V0550.txt`'ye (sürüm numarası yapımcının) şu anahtar
önekleriyle eklenir: `D33O_`, `D34O_`, `D35O_`, `D36O_`, `D17_N_FIRST_33` ve değişen `D28O_N_01`, `D28O_U_01`,
`D28O_U_HAUL`.
