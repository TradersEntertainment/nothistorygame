# Osmanlı Tarafı · Yeni Bölümler B: Kuşatmanın içi ve ertesi (37, 38, 39, 31o) (v0.2)

Bu belge OTTOMAN_STORY.md'nin §4 biçimini izler. Kuşatma öncesi bölümler (33–36) ayrı belgededir (OTTOMAN_NEW_A.md);
burada **18 Nisan 1453'ten önceki hiçbir olay yoktur**. İlkeler aynıdır: *tarih inatçıdır*, Tolga sonucu değil insanları
değiştirir, **Kerkoporta rivayeti kullanılmaz**, 1453'teki hiçbir karakter "Büro"yu bilmez (Tolga onlar için "kâtip",
"Urban'ın kâtibi", "reisin kâtibi"dir; Büro yalnız Nihat'ın telsizindedir).

**v0.2 oynanış kuralı (kullanıcı isteği):** her bölümde **gerçek başarısızlık durumu olan en az iki yüksek gerilimli
mekanik** (tırmanma, denge, düello, tüfek, kürek yarışı, zamanlı kurtarma, düşen taş / kaynar yağ / Rum ateşi / çöken
çatı); taşıma yalnız kısa ve bir bükümle (tehlike, zamanlama, denge); **ara sahne ve durdurulan konuşma oynanış süresinin
%25'inden az**, oyun sırasında bark tercih edilir. Her fazın altında **"Animasyon ve görsel geri bildirim"** listesi
vardır; kalabalık ve dekorun **zemin yüksekliği** (gömülme / havada durma / yerden çıkma) ayrıca belirtilmiştir.

Kaynak kısaltmaları: **R** Runciman (*The Fall of Constantinople 1453*), **K** Kritovoulos, **B** Barbaro'nun günlüğü,
**TB** Tursun Bey (*Târîh-i Ebü'l-Feth*), **AP** Aşıkpaşazade, **D** Doukas, **S** Sphrantzes. Sonraki anlatılara dayanan
ayrıntılar **(rivayet)**, oyunun kendi yorumu **(kurgu)** diye işaretlidir.

---

## 0. Özet: dört bölüm ve sıra

| İç id | Sahne | Tarih (1453) | Başlık | Gerilim mekanikleri (başarısızlıklı) | Ana olay | Sonuçlar |
|---|---|---|---|---|---|---|
| **37** | `chapter37o` (yeni) | 18 Nisan gecesi | İlk Hücum | ritim + kalkan (çift girdi), kalas üstünde **denge** (düşersen hendekten **tırman**), **kanca + çekiş** taş ve tüfekçi altında, gedikten çıkanlarla **düello** (WaveRunner), Rum ateşi çömlekleri arasında yaralı **sürükleme** | Mesoteichion'a ilk büyük gece hücumu; Giustiniani dört saatte püskürtür | 37O.1 barikat söküldü (sabaha örülür) · 37O.2 çizik almadı |
| **38** | `chapter38o` (yeni) | 29 Mayıs, 01.30 → öğle | Haliç Surları | **kürek** ok altında, sallanan teknede merdiven **dengesi** + çatala karşı bastır, güvertede **ateş çömleği** söndür (8 sn), merdivende **kaynar yağ** (OilHazard) ve taş, ezilmeden **kurtarma**, top gülleleri altında **kürek yarışı** | Haliç surlarına deniz hücumu; şehir düşer, tayfa dağılır, Petrion teslim olur; Hristiyan gemileri zinciri kesip kaçar | 38O.1 merdiven tuttu, tayfayı sen çektin · 38O.2 yaşlı tayfa çekti |
| **39** | `chapter39o` (yeni) | 29 Mayıs akşamı → gece | Emanet | yağmacılara karşı **kapı yarışı** (çatıdan kestirme **tırmanma**), kilise kapısında **zamanlı arama + çekişme** (silahsız), yanan evde **tırmanarak kurtarma** (duman, düşen kiremit, çöken kiriş, iple indirme dengesi) | Teslim olan Petrion'a muhafız; İmparator'un akıbeti bilinmiyor | 39O.1 altı kapı emanette, kapı dayandı · 39O.2 geç kalınan kapılar |
| **31** | `chapter31o` (planlıydı) | 30 Mayıs – 1 Haziran | Cuma | yanık evde **çöküş kurtarması** (harap saray cephesine **tırman**, kömürleşmiş kirişte **denge**, kiriş kaldır, çocuğu iple indir), Eyüp'te **gün batımına karşı arama** (rivayet), Ayasofya'da geçici şerefe **iskelesi** (tırmanma, rüzgârda denge, bağ zamanlaması), ezana karşı **hasır** | Fethin ertesi; Eyüp (rivayet); ilk cuma | 31O.1 hepsi zamanında · 31O.2 başkaları yetişti |

**`Siege.ORDER` içindeki yerleri** (A belgesinin 33–36'sı kendi yerlerine ayrıca girer):

```gdscript
const ORDER := [28, 37, 29, 17, 18, 19, 20, 30, 21, 22, 23, 24, 25, 32, 26, 38, 39, 31, 27]
```

- **37** 28'in hemen ardına (6 ve 11–12 Nisan → 18 Nisan → 20 Nisan).
- **38** ve **39** 26'nın ardına. 38, 26o ile aynı gecede başlar; Nihat takvimi bilerek geri sarar (19o→20o'daki
  "Takvimi geri saralım" emsali). 26o'nun doruğu (Hasan ve sancak) bozulmasın diye 38 ondan sonra, "aynı sabahın öbür
  yüzü" olarak gelir.
- **31** 39'un ardında, 27'nin önünde (zaten ORDER'da).
- `Siege._plays`: şehir düşmediyse yazılmayan bölümler `[31, 27]` → **`[38, 39, 31, 27]`**.
- `Lore.PAGES`: `"37o": 3, "38o": 3, "39o": 3, "31o": 3`.
- `Grade.finish("37o")`, `Grade.finish("38o")`, `Grade.finish("39o")` (darbe, düşme, tüfekçi; 39'da çekişme ve duman),
  31o'da karne yok (yalnız istatistik satırı).
- Tespit kareleri: `siege37`, `siege38`, `siege39`, `siege31`.

**Yeni `SPK_` anahtarları (dört tane):**

```csv
SPK_AZAPBASI,Azap Bölükbaşı Turgut,Azap Captain Turgut
SPK_CAVUS,Çavuş Davud,Davud the Çavuş
SPK_PRIEST,Yaşlı papaz,The old priest
SPK_AKSEMSEDDIN,Akşemseddin,Akşemseddin
```

| Anahtar | Ses |
|---|---|
| `SPK_AZAPBASI` | Kırklarında, Rumelili, boğuk ve kaba ama sıcak; kendi kalkanıyla dalga geçer, ritmi ve düzeni sever. |
| `SPK_CAVUS` | Sultan'ın çavuşu; elli yaşlarında, ağır, kısa cümleler, sesini yükseltmeden emreder; "emanet" kelimesini sever. |
| `SPK_PRIEST` | Petrion'un yaşlı papazı; Rumca konuşur (altyazı Türkçe), yorgun, alçak sesli, korkuyla değil ağırbaşlılıkla. |
| `SPK_AKSEMSEDDIN` | Sultan'ın hocası; altmışına yakın, yumuşak, yavaş, az söz; cümleleri öğüt gibi değil gözlem gibi biter. |

Mevcut anahtarlar: `SPK_NIHAT`, `SPK_TOLGA`, `SPK_URBAN`, `SPK_AZAP` (30o/32o'nun azabı), `SPK_GIUST`, `SPK_SOLDIER`
(asker; 31o'da 22o/32o'nun marangozu), `SPK_PATROL` (19o'nun devriye reisi), `SPK_SAILOR`, `SPK_SAILOR2`, `SPK_TOWNSMAN`,
`SPK_JANISSARY`, `SPK_KADRI`, `SPK_HERALD`, `SPK_DERVISH` (24o'nun dervişi).

**Ortak görsel kurallar (dört bölüm için):**
- Bütün yürüyen, koşan, oturan figüranlar zemine o noktadaki gerçek yükseklik işleviyle oturtulur: kara surlarında
  `Assault.ground_y` / `LandWalls.fill_y` / `SiegeField.ground`; Haliç kıyısında `Horn`'un arazi işlevi (`hf`); şehirde
  `FallenCity`'nin cadde/moloz yüksekliği; Ayasofya içinde döşeme y'si. Doğma anı kameranın görmediği yerdedir (bir
  kapının, siperin, barikatın ardı) ve figür oradan **yürüyerek** gelir; "yerden yükselme" yok.
- Görünen her ip / halat (kanca ipi, kalkan ipi, rıhtım halatı, indirme ipi, iskele bağı) iki uç arasında **her karede
  yeniden kurulan sarkık bir eğri ağ**dır (`SeaBattle.hook` gibi); gergin olunca düzleşir, gevşeyince sarkar; düğüm
  atılınca sarımlar tek tek görünür. Görünmez ip yok.
- İş yapan NPC'ler oyuncuyla aynı işi aynı ritimde yapar (çekiş, kürek, çekiç, kova); başarısız denemede onlar da
  sendeler. Kırılan her şey (fıçı, çömlek, taş, kiriş, kiremit) parçalanır ve döküntü bırakır; her isabetin ses + ekran
  sarsıntısı + parçacık geri bildirimi vardır (`Fx`).

---

## 1. Bölüm 37 — "İlk Hücum" (18 Nisan 1453 gecesi)

### 1.1 Tarihî dayanak

- **Tarih ve yer:** Bombardımanın bir haftasından sonra, 18 Nisan'da gün battıktan yaklaşık iki saat sonra Sultan
  Mesoteichion'a (Lykos vadisi, Aziz Romanos kapısının yakını) ilk büyük hücumu emretti (**R**, **B**).
- **Hücum:** Okçular, mızraklılar, ağır piyade ve yeniçeriler meşalelerle, davul, zil ve borularla geldi; dış surdaki
  yıkıkların yerine örülen **tahta-fıçı-toprak barikatı** yakmaya ve yıkmaya, merdiven dayamaya çalıştılar (**B**, **R**).
  Cephe dardı; sayı üstünlüğü işe yaramadı. Giustiniani'nin adamları **dört saat** dayandı (**R**).
- **Kayıp:** Barbaro iki yüz Türk'ün öldüğünü, savunuculardan kimsenin ölmediğini yazar (**B**; Venedikli bir kalemin
  rakamı, kesin değil).
- **Ayrıntılar:** fıçıları kancayla çekme **(kurgu)** (kaynaklar "yıkmaya çalıştılar" der, aracı söylemez); savunucuların
  ateş çömlekleri ve yanıcı karışımlar atması kuşatma boyunca anlatılır (**B**, **K**); ölüleri ve yaralıları geri taşıma
  gayreti birçok kez geçer (**B**, **K**). 18 Nisan'da ay dolmaya yakındı (22 Mayıs tutulmasından geriye sayılır).
- 20o (7 Mayıs, top + gedik) ve 30o'nun (12 Mayıs, Blakherna merdiveni) **tekrarı değildir**: burada top ve merdiven yok;
  fiiller ritim, kalas üstünde denge, kanca-çekiş ve sürüklemedir.

### 1.2 Yer ve sistemler

- **Harita:** `LandWalls` + `SiegeField`, 20o ile aynı Lykos kesiti, **gece** (`Night.environment`). `intact = false`,
  barikat erken aşamada `set_repair(4)`. `ditch_filled = false` (hendek boş, dibi y −3: kalas bunun için).
  `field.bombard = false`.
- **Kalabalık:** `Assault.build_calm()` + `BattleExtras.populate(..., "osm")` hendek kuşağında; `Assault.volley` ok
  yaylımı; `SiegeField.formation` oyuncunun bölüğünün iki yanına iki sancaklı bölük. Tam `Assault.build()` (29 Mayıs
  ölçeği) kullanılmaz.
- **Yeniden kullanılan:** `RowMeter` (28o "hey-yap"), ekipçe taşıma (30o), "Siper!" (22o `_covered/_volley_tick`),
  `BalanceMeter` (4b), `player.enable_climb([hendek kesiti])` (Traversal; nefes), kanca nişanı (29o), `_drop_stone` (26o),
  `Gunner.spawn`, `WaveRunner.run` (bir dalga), `Vfx.fire` (yerde Rum ateşi birikintisi), 30o'nun yük taşıma kodundan
  türetilmiş sürükleme, `TespitCam`, `Lore.scatter(self, "37o")`, `Grade.finish("37o")`.
- **Yeni dosya yok:** `chapter37o.gd` + `scenes/chapter37o.tscn` (20o iskeleti).
- **Süre hedefi:** 10–12 dk; durdurulan konuşma ≤ 2 dk (%18).

### 1.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 0. Batarya | Gün batımı | `UI_OBJ37O_URBAN` | Urban'ın soğuyan topunun yanında 40 sn konuşma; bölükbaşı **zil** uzatır (E). | — |
| 1. Zil ve kalkan | 20.30 | `UI_OBJ37O_BEAT`, `UI_OBJ37O_SHIELD` | Bölük ölü bölgeyi yürür. **RowMeter 16 vuruş**: davul işareti yeşilken Space. 8. vuruştan sonra surdan oklar: kırmızı "Ok!" uyarısında **C basılı = hasır kalkan başın üstünde**, ama ritim sürer (çift girdi). Kalkan inikken ok = −20 can; kalkanla vuruş "yarım" sayılır. | Can 0 → yere düşülür, bölükbaşı kaldırır, 8. vuruştan yeniden. Sayaç: iyi vuruş /16 (≥10 → faz 3'te çekiş ekibi bir kişi fazla). |
| 2. Kalas köprü | 21.00 | `UI_OBJ37O_PLANK`, `UI_OBJ37O_CROSS`, `UI_OBJ37O_CLIMBOUT` | (a) Üç azapla 6 m kalası omuzla, **20 m** (kısa) hendeğe; E ile indir. (b) **İlk geçen sensin**: kalasın öbür ucunu tutmak için 6 m'lik kalastan yürü, `BalanceMeter` (rüzgâr + kalas esnemesi; her 2 sn'de bir ok kalasın yanına saplanır, ibreyi iter). (c) Düşersen: 3 m hendeğin dibi (−20 can), **karşı duvara serbest tırmanma** (`enable_climb` yalnız hendeğin iki duvarı; nefes çubuğu biterse kayar, yeniden) ve yeniden geç. | İki düşüşten sonra bölükbaşı geçer, Tolga arkasından (ilerleme; yalnız sayaç). |
| 3. Barikat | Gece yarısı | `UI_OBJ37O_HOOK`, `UI_OBJ37O_PULL`, `UI_OBJ37O_PHOTO` | Barikatta **beş fıçı**. (a) Nişan al, çember halkası kadrajda **E**: kanca uçar, takılırsa ip gerilir (ıska: 2 sn sar, yeniden). (b) **Çek**: RowMeter "hey-yap", 3 iyi vuruş (zil ≥10 ise 2): fıçı devrilir. Bir vuruş kaçarsa savunucu ipi baltayla keser (ip kopar, kanca düşer, yeniden at). Tehlikeler: her 8–10 sn **taş** (yere gölge, 1,2 sn içinde yana çekil, yoksa −25 can), 12. sn'den sonra **tüfekçi** (`Gunner`; kalkan sipere geç ya da yana kay). **Tespit:** barikatın üstünde Giustiniani. Süre **3 dk**. | Can 0 → azaplar geri sürükler, −30 sn. Sayaç: fıçı /5. |
| 3b. Gedikten çıkış | Faz 3 içinde (2. fıçı devrilince) | `UI_OBJ37O_SALLY` | Açılan delikten üç Cenevizli çıkar: **WaveRunner**, bir dalga, aynı anda 2, süre 45 sn, beceri 0,4, Tolga'ya kılıç (kilij), yanında bölükbaşı ve iki azap (müttefik). | Kaybedilirse Tolga yere düşer, Cenevizliler delikten geri çekilip onu kapatır: **faz 3 hemen biter** (o ana kadarki fıçılar sayılır). |
| 4. Geri | 00.30 | `UI_OBJ37O_DRAG`, `UI_OBJ37O_FIRE` | Geri çekilme borusu. Yaralı azabın hasır kalkanının ipini al. **W basılı** geri yürü (1,4 m/sn); her ~6 sn ip kayar: 1 sn içinde **E** (kaçarsa 2 m geri). Barikattan **ateş çömlekleri**: ıslık + düşme gölgesi, 1 sn sonra 2 m'lik yanan birikinti (8 sn). Kızağı birikintinin içinden geçirme: −20 can, ip kayar. Kalas köprü (kızakla denge yok, yavaş), 40 m. | Başarısızlık yok; yanık ve kayma sayısı bark ve karneye. |

**Animasyon ve görsel geri bildirim**
- **Faz 0:** Urban topun ağzına ıslak paçavra sürer (döngü), namludan buhar tüter; bölükbaşı zili iki elle uzatır,
  Tolga'nın elleri zile oturur (Rig el hedefleri).
- **Faz 1:** Tolga'nın iki kolu zili çarpar (iyi vuruşta zillerin arasında beyaz kıvılcım, kötüde metalik "tıss" ve sarsılma);
  mehter davulcusunun tokmağı aynı vuruşta iner; bölük bloku her iyi vuruşta 0,6 m öne kayar (figüranlar adım animasyonuyla,
  kaymadan); oklar yayla gelir, yere saplanıp titrer (`Assault.arrow_mesh`), kalkana saplananlar kalkanda kalır; kalkan
  kaldırma: sol kol yukarı, hasır kalkan başın üstünde (`BattleExtras.overhead_shield`). Figüranlar `Assault.ground_y`
  üstünde; gülle çukurlarının içinde yürüyen eğilir, gömülmez.
- **Faz 2:** kalas dört omuzda (her taşıyıcının elleri kalasa kilitli, adımlar eş); indirirken uçlar iki kıyıya çarpar,
  toz puf; üstünde yürürken ortası 3 cm sarkar ve gıcırdar; ibre kenara yaklaşınca kamera yalpalar; düşüş: kısa savrulma,
  dipte toz, ekran kenarı kırmızı; tırmanmada eller taşa tutunur (Traversal), nefes çubuğu ekranda.
- **Faz 3:** kanca ipi elden çembere sarkık eğri; takılınca "klank" + kıvılcım; çekişte ip düzleşip titrer, arkadaki
  azaplar her "hey"de geriye yaslanır, ayakları toprağı kazır (toz); fıçı önce sallanır, sonra devrilir, moloz yamacından
  yuvarlanır, kapağı açılır, **toprak dökülür**, arkasındaki kalas düşer ve `LandWalls.set_repair` bir aşama azalır;
  balta inince ip kopar, iki ucu savrulur. Taş: gölge büyür, taş 4 parçaya bölünür + toz; isabette fes yamulur, ekran
  sarsılır. Tüfekçi: fitil kızarır, "TÜFEKÇİ!" uyarısı (Gunner).
- **Faz 3b:** Cenevizliler barikatın **arkasından** (z < 14) yürüyerek delikten çıkar; karşılamada kıvılcım, darbede
  yere çömelme; yenilen Cenevizli kılıcını bırakıp deliğe geri çekilir.
- **Faz 4:** ip Tolga'nın ellerinden kalkanın ön kenarına gergin; kalkan toprakta iz bırakır (iz şeridi); kayma anında ip
  ellerden kayar, kıvılcım değil toz ve "ip yanığı" sesi; çömlek havada döner, düşünce seramik parçalar + alev birikintisi
  yayılır (`Vfx.fire`, 2 m), yanındaki figüranlar çekilir. Şafak kesmesi: Urban'ın bataryası, gökte morluk.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **37O.1** Barikat yer yer söküldü (sabaha yine örüldü) | sökülen fıçı ≥ 3/5 | `FLOW_37O_1` |
| **37O.2** Barikat çizik almadı | aksi hâlde | `FLOW_37O_2` |

Tarih ikisinde de aynıdır. `--autotest[=lose]` (varsayılan 37O.1; `=lose`: bot zili geç vurur, kalastan bir kez düşer,
düelloyu kaybeder). Akış şeması (`UI_FLOW37O_TITLE`): `FLOW37O_URBAN` → `FLOW37O_BEAT` → `FLOW37O_PLANK` →
`FLOW37O_STOCKADE` → `FLOW37O_DRAG` → {`37O.1`, `37O.2`}; altında `Grade.finish("37o")` ve `UI_CH37O_STATS`.
Başarım önerisi: `ACH_OSM_CYMBAL` (16/16 zil, hiç ok yemeden).

### 1.4 Konuşanlar

Koşullu: `_BEAT_*`, `_SHIELD`, `_PULL_*`, `_CUT`, `_STONE`, `_FALL`, `_POT`, `_SLIP`, `S_VOLLEY`, `T_HIT`, `T_FALL`
olay bark'larıdır. `D37O_N_PHOTO_OK` yalnız kare çekilince. `D37O_T_SALLY_LOST` yalnız 3b kaybedilince. `D37O_T_END_OK` /
`_BAD` sonuca göre.

| Anahtar | Konuşan |
|---|---|
| `D37O_N_01` | SPK_NIHAT |
| `D37O_T_01` | SPK_TOLGA |
| `D37O_U_01` | SPK_URBAN |
| `D37O_T_U1` | SPK_TOLGA |
| `D37O_U_02` | SPK_URBAN |
| `D37O_AB_01` | SPK_AZAPBASI |
| `D37O_T_02` | SPK_TOLGA |
| `D37O_AB_02` | SPK_AZAPBASI |
| `D37O_AB_BEAT_OK` | SPK_AZAPBASI |
| `D37O_AB_BEAT_BAD` | SPK_AZAPBASI |
| `D37O_AB_SHIELD` | SPK_AZAPBASI |
| `D37O_T_MARCH` | SPK_TOLGA |
| `D37O_AB_03` | SPK_AZAPBASI |
| `D37O_S_VOLLEY` | SPK_SOLDIER |
| `D37O_T_PLANK` | SPK_TOLGA |
| `D37O_AB_FALL` | SPK_AZAPBASI |
| `D37O_T_FALL` | SPK_TOLGA |
| `D37O_AB_04` | SPK_AZAPBASI |
| `D37O_T_03` | SPK_TOLGA |
| `D37O_G_01` | SPK_GIUST |
| `D37O_AB_PULL_1` | SPK_AZAPBASI |
| `D37O_AB_CUT` | SPK_AZAPBASI |
| `D37O_AB_PULL_3` | SPK_AZAPBASI |
| `D37O_AB_STONE` | SPK_AZAPBASI |
| `D37O_T_HIT` | SPK_TOLGA |
| `D37O_AB_SALLY` | SPK_AZAPBASI |
| `D37O_T_SALLY_LOST` | SPK_TOLGA |
| `D37O_N_PHOTO` | SPK_NIHAT |
| `D37O_N_PHOTO_OK` | SPK_NIHAT |
| `D37O_G_02` | SPK_GIUST |
| `D37O_S_RETREAT` | SPK_SOLDIER |
| `D37O_AB_05` | SPK_AZAPBASI |
| `D37O_AZ_01` | SPK_AZAP |
| `D37O_AB_SLIP` | SPK_AZAPBASI |
| `D37O_AB_POT` | SPK_AZAPBASI |
| `D37O_T_DRAG` | SPK_TOLGA |
| `D37O_AZ_02` | SPK_AZAP |
| `D37O_AB_06` | SPK_AZAPBASI |
| `D37O_T_END_OK` | SPK_TOLGA |
| `D37O_T_END_BAD` | SPK_TOLGA |
| `D37O_U_03` | SPK_URBAN |
| `D37O_T_U2` | SPK_TOLGA |
| `D37O_U_04` | SPK_URBAN |
| `D37O_N_END` | SPK_NIHAT |

### 1.5 Metinler

```csv
UI_CH37O_TITLE,"BÖLÜM {N} — İLK HÜCUM","CHAPTER {N} — THE FIRST ASSAULT"
UI_CH37O_SUB,"18 Nisan 1453 · Mesoteichion, barikatın önü · gece","18 April 1453 · The Mesoteichion, before the stockade · night"
UI_FLOW37O_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: İLK HÜCUM","FLOWCHART — CHAPTER {N}: THE FIRST ASSAULT"
UI_OBJ37O_URBAN,"Urban'ın bataryasına git","Go to Urban's battery"
UI_OBJ37O_BEAT,"Davulla birlikte zili çal (işaret yeşilken Space) · %d/%d","Strike the cymbal with the drum (Space on the green) · %d/%d"
UI_OBJ37O_SHIELD,"Ok! Kalkanı kaldır (C basılı), ritmi bırakma","Arrows! Raise your shield (hold C), keep the rhythm"
UI_OBJ37O_PLANK,"Kalası ekiple hendeğe taşı, kıyıda indir (E)","Carry the plank to the moat with your squad, lower it at the edge (E)"
UI_OBJ37O_CROSS,"Kalastan ilk sen geç: dengede kal","Cross the plank first: keep your balance"
UI_OBJ37O_CLIMBOUT,"Hendekten çık: karşı duvara tırman (Space)","Get out of the moat: climb the far wall (Space)"
UI_OBJ37O_HOOK,"Kancayı bir fıçının çemberine at (E) · fıçı %d/%d","Throw the hook onto a barrel's hoop (E) · barrels %d/%d"
UI_OBJ37O_PULL,"Hep birlikte çek: işaret yeşilken Space","Pull together: Space on the green"
UI_OBJ37O_SALLY,"Gedikten çıktılar! Bölükbaşının yanında dayan","They've come out of the gap! Hold beside your captain"
UI_OBJ37O_PHOTO,"Tespit et: barikatın üstünde Giustiniani","Record: Giustiniani on the stockade"
UI_OBJ37O_DRAG,"Yaralının kalkanını ipinden çek (W basılı · ip kayınca E)","Drag the wounded man's shield by its rope (hold W · E when the rope slips)"
UI_OBJ37O_FIRE,"Ateş çömlekleri! Yanan yerlerden uzak dur","Fire pots! Keep clear of the burning patches"
UI_PROMPT37O_CYMBAL,"E: zili al","E: take the cymbal"
UI_PROMPT37O_PLANK,"E: kalası omuzla","E: shoulder the plank"
UI_PROMPT37O_DROP,"E: kalası hendeğin üstüne indir","E: lower the plank across the moat"
UI_PROMPT37O_HOOK,"E: kancayı at","E: throw the hook"
UI_PROMPT37O_ROPE,"E: kalkanın ipini al","E: take the shield's rope"
UI_PROMPT37O_GRIP,"E: ipi yeniden kavra!","E: grip the rope again!"
FLOW37O_URBAN,"Urban kâtibini ödünç verir","Urban lends out his clerk"
FLOW37O_BEAT,"Zil ve kalkanla ölü bölge","Cymbal and shield across the dead ground"
FLOW37O_PLANK,"Hendeğe kalas köprü","A plank bridge over the moat"
FLOW37O_STOCKADE,"Barikata kanca; gedikten çıkış","Hooks on the stockade; a sally from the gap"
FLOW37O_DRAG,"Ateş çömlekleri arasında geri","Back through the fire pots"
FLOW_37O_1,"Barikat yer yer söküldü; sabaha yine örüldü","The stockade was torn in places; by morning it was rebuilt"
FLOW_37O_2,"Barikat çizik almadı","The stockade didn't take a scratch"
UI_CH37O_STATS,"Zil: %d/%d   ·   Fıçı: %d/%d   ·   Düşüş: %d   ·   Dosya: %d/%d sayfa","Cymbal: %d/%d   ·   Barrels: %d/%d   ·   Falls: %d   ·   File: %d/%d pages"
SIEGE_DATE_37,"18 Nisan 1453, gece","18 April 1453, night"
SIEGE_EV_37,"Mesoteichion'a ilk büyük gece hücumu: meşaleler, davul ve zil. Giustiniani'nin adamları barikatı dört saat tutar; hücum püskürtülür.","The first great night assault on the Mesoteichion: torches, drums and cymbals. Giustiniani's men hold the stockade for four hours; the assault is thrown back."
SIEGE_NOTE_37O_1,"İlk hücum. Zil çaldım, kalastan geçtim, barikattan fıçı söktüm. Sabaha hepsi yerindeydi. Hasar: gece yarısı oluştu, şafakta onarıldı. — T.","The first assault. I struck a cymbal, crossed a plank, pulled barrels off the stockade. By morning they were all back. Damage: incurred at midnight, repaired by dawn. — T."
SIEGE_NOTE_37O_2,"İlk hücum. Zil çaldım, kalastan geçtim; kancalar fıçıları tutmadı. Barikat dört saat kılını kıpırdatmadı. Bir yaralıyı geri getirdik. — T.","The first assault. I struck a cymbal, crossed a plank; the hooks wouldn't hold the barrels. The stockade didn't budge for four hours. We brought one wounded man back. — T."
LORE_37O_1_T,"18 Nisan hücumu","The assault of 18 April"
LORE_37O_1,"Bombardımanın bir haftasından sonra Sultan, Lykos vadisindeki yıkıklara ilk büyük hücumu gün batımından iki saat sonra başlattı. Cephe dardı; dört saat süren çarpışmada barikat geçilemedi.","After a week of bombardment the Sultan launched the first great assault on the breaches in the Lycus valley two hours after sunset. The front was narrow; in four hours of fighting the stockade could not be passed."
LORE_37O_2_T,"Barikat","The stockade"
LORE_37O_2,"Dış surun yıkılan yerlerine savunucular her gece kalas, fıçı, toprak ve çalıdan bir barikat ördü. Toprak dolu fıçılar gülleyi yumuşatıyordu. Giustiniani bu işin ustasıydı; gün boyu dövülen yer sabaha yeniden ayaktaydı.","Wherever the outer wall fell, the defenders built a stockade each night from planks, barrels, earth and brushwood. Earth-filled barrels softened the cannonballs. Giustiniani was a master of it; what was battered all day stood again by morning."
LORE_37O_3_T,"Davul ve zil","Drums and cymbals"
LORE_37O_3,"Osmanlı hücumları davul, zil, boru ve bağırışla yapılırdı. Barbaro bu gürültünün surdakileri nasıl sarstığını yazar. Ses bir silahtı: kendi askerine yürüyüş ritmi verir, karşı tarafın uykusunu alırdı.","Ottoman assaults came with drums, cymbals, trumpets and shouting. Barbaro writes how the din shook the men on the walls. Sound was a weapon: it gave one's own troops a marching rhythm and robbed the other side of sleep."
UI_RECAP_37O_PREV,"Urban'ın siperine kazık çaktın, Şahi'yi kütükler üstünde bataryaya çektin ve ilk gülleyi sura indirdin.","You planted stakes at Urban's rampart, hauled the great gun into its battery on rollers and put the first ball into the wall."
UI_RECAP_37O_NEXT,"Barikat sabaha yine ayakta. 20 Nisan, Haliç'in ağzı: Baltaoğlu'nun kadırgasında dört gemiye karşı kürek ve kanca.","The stockade stands again by morning. 20 April, the mouth of the Horn: oars and hooks on Baltaoğlu's galley against four ships."
```

Replikler:

```csv
D37O_N_01,"Tolga Bey, 18 Nisan. Toplar bir haftadır dövüyor; Mesoteichion'da dış surun bir parçası indi, Rumlar yerine fıçı ve kalastan bir barikat ördü. Sultan bu gece ilk büyük hücumu deniyor. Siz azapların arasındasınız.","Mr Tolga, 18 April. The guns have been pounding for a week; part of the outer wall at the Mesoteichion has come down, and the Greeks have built a stockade of barrels and planks in its place. Tonight the Sultan tries the first great assault. You're among the azaps."
D37O_T_01,"Bir hafta önce o topu kütüklerin üstünde ben çektim. Şimdi açtığı deliğe yakından bakmaya gidiyorum. Sigortada buna ekspertiz denir.","A week ago I hauled that gun on rollers myself. Now I'm going to take a close look at the hole it made. In insurance we call that an appraisal."
D37O_U_01,"Kâtip! Bu gece toplar susuyor, ağızları sıcak. Ben barutun başında kalırım. Sen azaplarla git, gördüğünü yaz. Dönünce anlatırsın: güllelerim ne açmış.","Clerk! Tonight the guns are silent, their mouths are hot. I stay with the powder. You go with the azaps and write down what you see. When you come back, tell me: what have my balls opened up."
D37O_T_U1,"Yani siz duvarı açıyorsunuz, ben içinden geçip rapor yazıyorum. Bu iş bölümü bana çok tanıdık geliyor, usta.","So you open the wall and I walk through it and write the report. This division of labour feels very familiar, master."
D37O_U_02,"Rapor iyidir. Rapor top dökmez ama ikinci topun parasını getirir.","Reports are good. A report casts no gun, but it brings in the money for the second one."
D37O_AB_01,"Urban'ın kâtibi sen misin? İyi. Ben Turgut, bu bölüğün başıyım. Al şu zili. Mehter çalarken sen de çal; ses ne kadar büyükse surdaki o kadar küçülür.","You're Urban's clerk? Good. I'm Turgut, captain of this company. Take this cymbal. When the band plays, you play too; the bigger the noise, the smaller the man on the wall."
D37O_T_02,"Zil. Benim müzik eğitimim ilkokulda blok flütle bitmişti.","A cymbal. My musical education ended with the recorder in primary school."
D37O_AB_02,"Davul vurdukça bir adım. Ritmi kaçırma; bölük ritimle yürür, ritmi kaybeden bölük dağılır.","One step for every drumbeat. Don't lose the rhythm; a company marches on rhythm, and a company that loses it scatters."
D37O_AB_BEAT_OK,"İşte böyle! Duysunlar!","That's it! Let them hear it!"
D37O_AB_BEAT_BAD,"Ritim, kâtip! Ritim!","Rhythm, clerk! Rhythm!"
D37O_AB_SHIELD,"Kalkan yukarı, zil aşağı! İkisi birden, kâtip!","Shield up, cymbal down! Both at once, clerk!"
D37O_T_MARCH,"Ölü bölgeyi zil çalarak geçiyorum. Bunu ofiste kimseye anlatamam.","I'm crossing no man's land playing the cymbals. I can never tell anyone at the office."
D37O_AB_03,"Hendek! Kalası indir. Öbür ucu tutacak biri lazım; en hafifimiz sensin.","The moat! Lower the plank. Someone has to hold the far end; you're the lightest of us."
D37O_S_VOLLEY,"Ok! Kalkanlar yukarı!","Arrows! Shields up!"
D37O_T_PLANK,"Köprü dediğin bu kadar: bir tahta ve çok fazla iyimserlik.","That's all a bridge is: one board and far too much optimism."
D37O_AB_FALL,"Düştü! Kâtip, duvara tutun, yukarı! Hendekte kalan ok yer!","He's down! Clerk, grab the wall, climb! Whoever stays in the moat eats arrows!"
D37O_T_FALL,"Hendeğin dibi. Burası da surun bir parçası sayılır mı?","The bottom of the moat. Does this count as part of the wall too?"
D37O_AB_04,"Barikat! Kancayı fıçının çemberine geçir, sonra hep birlikte çek. Bir fıçı giderse arkasındaki kalas da gider.","The stockade! Get the hook round a barrel's hoop, then all pull together. When a barrel goes, the plank behind it goes too."
D37O_T_03,"Gece yarısı fıçı çekme yarışması. Karşı takım da çok istekli görünüyor.","A midnight barrel-pulling contest. The other team looks very keen as well."
D37O_G_01,"Tenete! Fıçıların arkasına! Çeksinler, biz yine koyarız!","Tenete! Behind the barrels! Let them pull, we'll put them back!"
D37O_AB_PULL_1,"Geldi! Bir fıçı!","It's coming! One barrel!"
D37O_AB_CUT,"İpi kestiler! Yeniden at!","They've cut the rope! Throw again!"
D37O_AB_PULL_3,"Üç! Barikatta delik var!","Three! There's a hole in the stockade!"
D37O_AB_STONE,"Taş! Yukarı bak, yana çekil!","Stone! Look up, step aside!"
D37O_T_HIT,"Kafam... Fes kask değildir. Bu gece kask oldu.","My head... A fez is not a helmet. Tonight it was one."
D37O_AB_SALLY,"Delikten çıkıyorlar! Kâtip, şu kılıcı al, yanımdan ayrılma!","They're coming out through the gap! Clerk, take this sword, stay by my side!"
D37O_T_SALLY_LOST,"Yerdeyim. Deliği arkalarından kapattılar. Bu gecelik fıçı yarışması bitti.","I'm on the ground. They've closed the gap behind them. That's the end of tonight's barrel contest."
D37O_N_PHOTO,"Barikatın üstündeki uzun boylu adam, Tolga Bey: Giustiniani. Bizans nüshasının kahramanı, sizinkinin baş ağrısı. Kayda alın.","The tall man on top of the stockade, Mr Tolga: Giustiniani. The hero of the Byzantine copy, the headache of yours. Record him."
D37O_N_PHOTO_OK,"Kaydedildi. Meşale ışığında, yüzü belli. Bundan sonra onu hep bu barikatta göreceksiniz.","Recorded. Torchlight, face clearly visible. From now on you'll always see him on this stockade."
D37O_G_02,"Bu gece geçemezsiniz! Ne bu gece, ne yarın!","You won't get through tonight! Not tonight, not tomorrow!"
D37O_S_RETREAT,"Geri! Borular geri çağırıyor!","Back! The trumpets are calling us back!"
D37O_AB_05,"Dört saat... Kâtip, şurada adamım yatıyor. Kalkanına yatırdık; ipinden çek. Kimseyi burada bırakmayız.","Four hours... Clerk, one of my men is lying there. We put him on his shield; pull it by the rope. We leave no one here."
D37O_AZ_01,"Kâtip... Zilini düşürmüşsün. Ben aldım. Ses kesilirse korkarız.","Clerk... You dropped your cymbal. I picked it up. If the noise stops, we get scared."
D37O_AB_SLIP,"İp kaydı! Tut onu!","The rope's slipping! Hold on to it!"
D37O_AB_POT,"Çömlek! Ateş! Sağa çek, sağa!","A pot! Fire! Pull right, right!"
D37O_T_DRAG,"Yavaş, kardeşim. Az kaldı. Kalası geçince düzlük.","Easy, brother. Not far now. Once we're over the plank it's flat ground."
D37O_AZ_02,"Düzlük iyi. Annem de hep öyle derdi: düzlüğe çık, gerisi kolay.","Flat ground is good. My mother always said so: get to the flat, the rest is easy."
D37O_AB_06,"Sabaha barikat yine ayakta olur, biliyorum. Ama bu gece onlar da uyumadı.","By morning the stockade will be standing again, I know. But tonight they didn't sleep either."
D37O_T_END_OK,"Üç fıçı, iki kalas. Sabaha yenileri gelecek. Hasar her gece aynı, onarım her gece biraz daha hızlı.","Three barrels, two planks. By morning there'll be new ones. Same damage every night; the repairs get a little faster every night."
D37O_T_END_BAD,"Kancalar tutmadı. Barikat bir çizik bile almadı. Raporuma 'kozmetik hasar bile yok' yazıyorum.","The hooks wouldn't hold. The stockade didn't take a scratch. I'm writing 'not even cosmetic damage' in my report."
D37O_U_03,"Ee kâtip? Güllelerim ne açmış?","Well, clerk? What have my balls opened up?"
D37O_T_U2,"Bir gedik açmışlar, usta. İçine de bir İtalyan yerleşmiş.","They opened a breach, master. And an Italian has moved into it."
D37O_U_04,"Demek daha büyük top lazım. ...Bir haber daha: Baltaoğlu kürekçi istiyor. Sen hafifsin, kadırgaya git.","Then we need a bigger gun. ...One more thing: Baltaoğlu wants oarsmen. You're light; off to the galley with you."
D37O_N_END,"Kaydedildi. 18 Nisan, Osmanlı nüshası. Barbaro bu gece iki yüz Türk'ün öldüğünü, savunuculardan kimsenin ölmediğini yazar. Rakam Venedikli bir kalemden; ama barikatın sabah yine ayakta olduğunu herkes yazar.","Recorded. 18 April, the Ottoman copy. Barbaro writes that two hundred Turks died tonight and not one defender. The figure comes from a Venetian pen; but everyone writes that the stockade stood again in the morning."
```

`D37O_U_04`, 28o→29o kopukluğunu (OTTOMAN_STORY §2.1, "Topçu kâtibi bir gecede kürekçi") kapatır.

---

## 2. Bölüm 38 — "Haliç Surları" (29 Mayıs 1453, 01.30 → öğle)

### 2.1 Tarihî dayanak

- **Gece hücumu denizden de:** Son hücumda Haliç'e karadan indirilen gemiler Haliç surlarına yanaştı, merdiven dayadı;
  Hamza Bey'in donanması Marmara surlarını zorladı (**R**, **K**). Haliç surunu Venedikliler ve Rumlar tuttu; denizden
  gelen hücumlar kara surları düşene kadar başarılı olamadı (**R**). Savunucuların kaynar yağ, taş ve ateş çömleği
  kullanması kuşatma boyunca anlatılır (**B**, **K**).
- **Sabah:** Kara surlarında sancaklar görülünce Haliç surundaki savunucuların çoğu evlerine ve gemilere koştu; Haliç'teki
  gemilerin tayfası gemileri bırakıp şehre girdi (**R**, **B**).
- **Petrion:** Haliç kıyısındaki Petrion gibi bazı mahalleler resmen teslim oldu ve korundu (**R**). Teslimin bir fustanın
  reisine yapılması ve Tolga'nın tercümanlığı **(kurgu)**.
- **Kaçış:** Öğleye doğru Venedik kadırgaları ve Ceneviz gemileri zincire indi; Barbaro'ya göre iki denizci baltayla
  zincirin bağlarını kesti, gemiler açığa çıktı; Osmanlı tayfası şehre dağıldığı için peşlerine düşen olmadı (**B**, **R**).
  Barbaro bu gemilerden birindeydi. Bir Ceneviz gemisinin kovalayan fustaya top atması **(kurgu)**.
- **Giritliler:** Haliç'in ağzına yakın üç kulede Giritli denizciler öğleden sonraya kadar direndi; Sultan gemileri ve
  mallarıyla gitmelerine izin verdi (**R**).
- **Reis:** 19o'nun devriye reisi (`SPK_PATROL`); 22 Nisan'da karadan aşırılan fustalardan birinde olması **(kurgu)**.

### 2.2 Yer ve sistemler

- **Harita:** `Horn.build(self, 62.0, Rect2(), Vector2(-20, 20), 3801)`, 18b ile aynı kurulum. Sur parçası (x −20…20,
  yürüyüş yolu y 9,6) **18b'nin kendi parçası** + bir `ladder_gap` + bir **deniz kapısı**: `SeaWalls`'taki kapı kurucusu
  ve `open_gate` statik bir yardımcıya çıkarılır (`SeaWalls.gate(parent, pos)`, küçük iş). Kapının önünde dar taş rıhtım
  (üstü y 1,2) ve iki demir baba.
- **Tekne:** `SeaBattle.war_galley(self, ..., rowers := true)` (yürünür güverte, alçak katı küpeşte; 29o). Küpeştede üç
  hasır kalkan (siper), direk dibinde kum kovası. Merdiven: `Ladder` (tilt 18°, güverteden mazgala, ayağı güverteye
  halatla bağlı). Surda bir kazan: `WallFight.add_cauldron` (yürüyüş yolu y 9,6'ya göre) + `OilHazard.make(...)`.
- **Işık:** `Night.environment` → şafak (06.00, turuncu) → öğle (`SeaBattle.make_day`). Batıda kara surları: iki uzak burç,
  üstünde sancak (Horn `figures` + sancak ağı).
- **Kaçan gemiler:** `SeaBattle.carrack` ×2 (Ceneviz) + `SeaBattle.war_galley(flag := false)` ×3 (Venedik, kırmızı-altın
  bayrak) Horn'un suyunda doğuya (+x). **Gereksinim:** su düzlemi +x'te ≥ 300 m; yoksa bölüm kendi şeridini ekler
  (`CityPanorama.water_mat()`).
- **Yeniden kullanılan:** `RowMeter`, "Siper!" kuralı, `BalanceMeter`, zamanlı tuş (32o basamak), `Ladder` + `_drop_stone`
  + `OilHazard`, 24o ip (E basılı, gerilim çubuğu), 17'nin kurtarma döngüsü, `hud.choose`, `TespitCam`,
  `Assault.volley`'nin deniz hâli, `Grade.finish("38o")`.
- **Süre hedefi:** 11–13 dk; durdurulan konuşma ≤ 2,5 dk (%20).

### 2.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Kürek | 01.30 | `UI_OBJ38O_ROW`, `UI_OBJ38O_COVER` | Haliç'i surlara geç: **RowMeter 20 vuruş** (~60 sn). Kötü vuruşta kürekler çarpışır, tekne yalpalar. İki **ok yaylımı**: "Ok!" sonrası 2 sn içinde **C basılı** (küpeşte kalkanının dibine çömel) ama kürek bırakılırsa tekne durur: çömelirken ritim sayılmaz, 2 vuruş kaçar. Çömelmezsen −25 can. | Can 0 → reis Tolga'yı kıç tarafına çeker, 20 sn ceza. Sayaç: iyi vuruş /20. |
| 2. Merdiven | 02.30 | `UI_OBJ38O_HOLD`, `UI_OBJ38O_BRACE`, `UI_OBJ38O_POT`, `UI_OBJ38O_CLIMB` | (a) **Ayağını tut**: `BalanceMeter` 45 sn (tekne dalgayla sallanır). İbre taşarsa merdiven kayar, tırmanan iki tayfa güverteye düşer, 6 sn ceza. (b) **3 çatal itişi**: yukarıda çatal belirir, 1,5 sn içinde **Space** = bastır. (c) 25. sn'de **ateş çömleği** güverteye düşer: merdiveni bırak (ibre serbest kalır!), direk dibindeki kum kovasını al, ateşe at (E) — **8 sn** içinde; geç kalınırsa yelken tutuşur, tayfa söndürür, −1 sonuç puanı. (d) Reis: "Sen de çık." **Tırman** (W, 4 m): bir **taş** (dur, geçsin) ve kazandan **kaynar yağ** (`OilHazard`: uyarıda A/D ile merdivenin yanına sark; ortada kalırsan −40 can ve aşağı kayarsın). Reis geri çağırır. | Tarih: Haliç suru dayanır, faz sonu sabit. Sayaç: bastırılan çatal /3, ateş söndü mü, yağ yendi mi. |
| 3. Haber | 06.00 | `UI_OBJ38O_ROPE`, `UI_OBJ38O_PULL` | Burçlarda sancak; surdakiler mazgalları bırakır, kapı açılır, tayfa karaya fırlar; tekne akıntıyla sura sürüklenir. (a) **Halat**: rıhtım babasına atla (E), E basılı tut, gerilim çubuğu kırmızıya girince bırak, yeşilde yeniden tut; 20 sn içinde 3 sarım. Kopma: tekne surun dibine vurur, küpeşte kırılır, yeniden. (b) **Suya düşen tayfa** tekne ile rıhtım arasında: E basılı = çek; tekne her ~5 sn rıhtıma vurur (gıcırtı + ekran kenarı uyarısı 0,8 sn önce): vuruş anında E basılıysa elin kayar, ilerleme yarıya iner. **30 sn.** Süre biterse yaşlı tayfa kancayla çeker. (c) Petrion ihtiyarları rıhtıma iner: **seçim** (`UI_C38O_EXACT` / `UI_C38O_ADD`), `flags["petrion_word"]`. | Sayaç: tayfayı kim çekti. |
| 4. Kovalamaca | Öğle | `UI_OBJ38O_CHASE`, `UI_OBJ38O_SPLASH`, `UI_OBJ38O_PHOTO` | Hristiyan gemileri zincire iner. Altı kürekle **RowMeter** (gemiler her durumda uzaklaşır; ritim mesafe çubuğunu yavaşlatır). Son Ceneviz gemisinin kıç topu ateş eder: ağız alevinden 2 sn sonra suda **halka** belirir (düşeceği yer); o anda **A/D**: reise "sol/sağ" de, tekne kayar. Yanlış yön ya da kötü vuruş: su sütunu güverteyi yıkar, −15 can, iki kürek kırılır (hız düşer). **Tespit:** zincire inen gemiler (pencere 40 sn). Sonra Nihat (zincir, Giritliler). | Kare kaçarsa not. |

**Animasyon ve görsel geri bildirim**
- **Faz 1:** kürekler `SeaBattle.row_oars` ile RowMeter'ın evresinden sallanır (oyuncunun küreği dahil, eller küreğin
  sapına kilitli); kürek suya girerken sıçrama, çekerken iz köpüğü; kötü vuruşta iki kürek çarpışır (tahta sesi, tekne 3°
  yalpa); öndeki fustanın kürekleri de aynı ritimde; oklar suya düşünce küçük sıçrama, güverteye saplananlar titrer.
  Tayfa güverte y'sinde (gemiyle birlikte sallanır, gemiye bağlı düğümde).
- **Faz 2:** merdiveni iki tayfa basamaklardan iterek kaldırır (ayağı güvertede halatla bağlı, halat görünür); tekne
  sallandıkça merdivenin tepesi mazgalda sürtünür (taş tozu); çatal mazgaldan uzanır, merdivenin tepesini iter: merdiven
  5° geri yatar, tırmanan tayfa bir an sallanır; bastırmada Tolga ve iki tayfa merdivene yüklenir (eğilme pozu). Çömlek
  havada döner, güvertede parçalanır, alev tahtaya yayılır (3 alev, her kum kovasında biri söner, buhar); yelken
  tutuşursa yelken kumaşı kararır, iki tayfa kovayla koşar. Kaynar yağ: kazan sallanır (uyarı), devrilir, yağ perdesi
  merdivenin ortasından iner, alttaki suya değince buhar; Tolga yana sarktığında gövde merdivenden dışa kayar
  (`Player.ladder_side`). Taş: suya düşerse sütun, güverteye düşerse tahta kıymıkları.
- **Faz 3:** batıdaki burçlarda sancaklar dalgalanır (şafak ışığı arkadan); savunucular mazgalların ardında koşarak kaybolur
  (yürüyüş yolu y 9,6 üstünde); kapı kanatları içe açılır (`open_gate`); tayfa küpeşteden rıhtıma **atlar** (sıçrama
  animasyonu, rıhtım üstüne y 1,2'ye iner). Halat: babaya her sarımda bir halka belirir, gergin olunca düz ve titrer,
  gevşekken sarkar; tekne gövdesi rıhtıma vurunca toz + gıcırtı + tekne geri seker. Sudaki tayfa: başı ve kolları suda
  iner kalkar, Tolga'nın eli onunkini kavrar (IK), çekişte yukarı gelir; kayışta eller ayrılır, tayfa bir an batar.
  İhtiyarlar rıhtım basamaklarından yürüyerek iner (kapının ardından), ellerinde açık avuç ve haç değil, **anahtar**.
- **Faz 4:** kaçan gemilerin yelkenleri dolar (`fill_sails`), kadırgaların kürekleri hızlı ritimde; kıç topunda ağız
  alevi ve duman; suda düşüş halkası büyür; isabette 6 m su sütunu, güverteye sağanak, kırılan kürek parçaları yüzer.
  Uzakta zincir: kütükler ayrılır ve akıntıyla açılır (gemiler geçerken). Giritli kulelerde kesmede beyaz bayrak değil
  **kulelerden inen denizciler** ve rıhtıma yanaşan bir gemi.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **38O.1** Merdiven tuttu, düşen tayfayı sen çektin | bastırılan çatal ≥ 2/3 **ve** ateş 8 sn içinde söndü **ve** tayfayı Tolga çekti | `FLOW_38O_1` |
| **38O.2** Düşen tayfayı yaşlı tayfa çekti | aksi hâlde | `FLOW_38O_2` |

`--autotest[=lose]` (varsayılan 38O.1; `=lose`: bot bastırmaz, ateşe geç kalır, kurtarmada vuruşta bırakmaz). Akış
şeması (`UI_FLOW38O_TITLE`): `FLOW38O_ROW` → `FLOW38O_LADDER` → `FLOW38O_NEWS` → `FLOW38O_PETRION` → `FLOW38O_CHASE` →
{`38O.1`, `38O.2`}; altında `Grade.finish("38o")` ve `UI_CH38O_STATS`.

### 2.4 Konuşanlar

Koşullu: `_ROW_*`, `S_ARROW`, `S_FORK`, `S_BRACE_*`, `S_POT`, `T_POT_OK`, `S_SAIL`, `S_OIL`, `R_LEFT/RIGHT`, `S_SPLASH`
bark'tır. `D38O_T_PULL` yalnız Tolga çekerse, yoksa `D38O_S2_HOOK`; sonra `D38O_S_SAVED`. Faz 3c'de `D38O_T_TR` ya da
`D38O_T_TR_ADD`.

| Anahtar | Konuşan |
|---|---|
| `D38O_N_01` | SPK_NIHAT |
| `D38O_T_01` | SPK_TOLGA |
| `D38O_R_01` | SPK_PATROL |
| `D38O_T_R1` | SPK_TOLGA |
| `D38O_R_02` | SPK_PATROL |
| `D38O_S2_01` | SPK_SAILOR2 |
| `D38O_R_ROW_OK` | SPK_PATROL |
| `D38O_R_ROW_BAD` | SPK_PATROL |
| `D38O_S_ARROW` | SPK_SAILOR |
| `D38O_R_03` | SPK_PATROL |
| `D38O_T_02` | SPK_TOLGA |
| `D38O_S_FORK` | SPK_SAILOR |
| `D38O_S_BRACE_OK` | SPK_SAILOR |
| `D38O_S_BRACE_BAD` | SPK_SAILOR |
| `D38O_S_POT` | SPK_SAILOR |
| `D38O_T_POT_OK` | SPK_TOLGA |
| `D38O_S_SAIL` | SPK_SAILOR |
| `D38O_R_UP` | SPK_PATROL |
| `D38O_S_OIL` | SPK_SAILOR |
| `D38O_T_UP` | SPK_TOLGA |
| `D38O_R_BACK` | SPK_PATROL |
| `D38O_S2_02` | SPK_SAILOR2 |
| `D38O_N_02` | SPK_NIHAT |
| `D38O_T_03` | SPK_TOLGA |
| `D38O_S_03` | SPK_SAILOR |
| `D38O_R_04` | SPK_PATROL |
| `D38O_S2_FALL` | SPK_SAILOR2 |
| `D38O_T_PULL` | SPK_TOLGA |
| `D38O_S2_HOOK` | SPK_SAILOR2 |
| `D38O_S_SAVED` | SPK_SAILOR |
| `D38O_TW_01` | SPK_TOWNSMAN |
| `D38O_R_05` | SPK_PATROL |
| `D38O_T_TR` | SPK_TOLGA |
| `D38O_T_TR_ADD` | SPK_TOLGA |
| `D38O_R_06` | SPK_PATROL |
| `D38O_S2_03` | SPK_SAILOR2 |
| `D38O_R_07` | SPK_PATROL |
| `D38O_R_LEFT` | SPK_PATROL |
| `D38O_R_RIGHT` | SPK_PATROL |
| `D38O_S_SPLASH` | SPK_SAILOR |
| `D38O_N_PHOTO` | SPK_NIHAT |
| `D38O_N_BOOM` | SPK_NIHAT |
| `D38O_N_CRETE` | SPK_NIHAT |
| `D38O_R_END` | SPK_PATROL |
| `D38O_T_END` | SPK_TOLGA |
| `D38O_N_END` | SPK_NIHAT |

### 2.5 Metinler

```csv
UI_CH38O_TITLE,"BÖLÜM {N} — HALİÇ SURLARI (DONANMA)","CHAPTER {N} — THE HORN WALLS (THE FLEET)"
UI_CH38O_SUB,"29 Mayıs 1453 · Haliç, Petrion önü · gece 01.30 → öğle","29 May 1453 · The Golden Horn, off Petrion · 1:30 a.m. → noon"
UI_FLOW38O_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: HALİÇ SURLARI","FLOWCHART — CHAPTER {N}: THE HORN WALLS"
UI_OBJ38O_ROW,"Kürek çek: işaret yeşilken Space · %d/%d","Row: Space on the green · %d/%d"
UI_OBJ38O_COVER,"Ok! Küpeşte kalkanının dibine çömel (C basılı)","Arrows! Crouch by the shield on the rail (hold C)"
UI_OBJ38O_HOLD,"Merdivenin ayağını tut: ibreyi ortada tut","Hold the foot of the ladder: keep the needle centred"
UI_OBJ38O_BRACE,"Çatal geliyor: Space ile bastır · %d/%d","A fork is coming: brace with Space · %d/%d"
UI_OBJ38O_POT,"Güvertede ateş! Kum kovasını kap, at (8 sn)","Fire on deck! Grab the sand bucket and throw it (8 s)"
UI_OBJ38O_CLIMB,"Tırman (W) · taşta dur · yağda yana sark (A/D)","Climb (W) · stop for stones · lean aside from the oil (A/D)"
UI_OBJ38O_ROPE,"Halatı rıhtımdaki babaya sar (E basılı · kırmızıda bırak) · %d/3","Wrap the rope round the bollard (hold E · let go on red) · %d/3"
UI_OBJ38O_PULL,"Suya düşeni çek (E basılı · tekne vurunca bırak)","Pull out the man in the water (hold E · let go when the hull bumps)"
UI_OBJ38O_CHASE,"Kürek! Zincire inen gemilerin peşinden","Row! After the ships heading for the chain"
UI_OBJ38O_SPLASH,"Top! Halka nerede: sola (A) ya da sağa (D)","A gun! Where's the ring: left (A) or right (D)"
UI_OBJ38O_PHOTO,"Tespit et: zincire inen Hristiyan gemileri","Record: the Christian ships heading for the chain"
UI_PROMPT38O_LADDER,"E: merdivenin ayağını tut","E: hold the foot of the ladder"
UI_PROMPT38O_SAND,"E: kum kovasını al","E: take the sand bucket"
UI_PROMPT38O_THROW,"E: kumu ateşe at","E: throw the sand on the fire"
UI_PROMPT38O_JUMP,"E: rıhtıma atla","E: jump onto the quay"
UI_PROMPT38O_ROPE,"E basılı: halatı sar","Hold E: wrap the rope"
UI_PROMPT38O_HAND,"E basılı: elini tut, çek","Hold E: grab his hand, pull"
UI_C38O_EXACT,"Olduğu gibi çevir.","Translate it exactly."
UI_C38O_ADD,"Bir cümle ekle: 'Kimseye zarar vermediler.'","Add one sentence: 'They have harmed no one.'"
FLOW38O_ROW,"Karanlıkta Haliç'i geçmek","Crossing the Horn in the dark"
FLOW38O_LADDER,"Tekneden sura merdiven; ateş ve yağ","A ladder from the deck; fire and oil"
FLOW38O_NEWS,"Şafak: burçlarda sancak","Dawn: banners on the towers"
FLOW38O_PETRION,"Petrion teslim olur","Petrion surrenders"
FLOW38O_CHASE,"Zincire inen gemiler","The ships run for the chain"
FLOW_38O_1,"Merdiven tuttu; düşen tayfayı sen çektin","The ladder held; you pulled the sailor out"
FLOW_38O_2,"Düşen tayfayı yaşlı tayfa çekti","The old sailor pulled the man out"
UI_CH38O_STATS,"Kürek: %d/%d   ·   Çatal: %d/3   ·   Yağ: %d   ·   Dosya: %d/%d sayfa","Oars: %d/%d   ·   Forks: %d/3   ·   Oil: %d   ·   File: %d/%d pages"
SIEGE_DATE_38,"29 Mayıs 1453, Haliç","29 May 1453, the Golden Horn"
SIEGE_EV_38,"Haliç'teki gemiler gece surlara merdiven dayar; sur dayanır. Sabah şehir düşünce tayfa karaya dağılır, Petrion teslim olur. Öğlen Hristiyan gemileri zinciri kesip kaçar.","At night the ships in the Horn put ladders to the walls; the wall holds. When the city falls at dawn the crews scatter ashore and Petrion surrenders. At noon the Christian ships cut the boom and escape."
SIEGE_NOTE_38O_1,"Haliç. Merdiveni tuttum, güvertedeki ateşi kumla söndürdüm, sur dayandı. Sabah şehir başka yerden düştü. Bir tayfayı rıhtımla tekne arasından çektim, bir mahallenin teslimini çevirdim. — T.","The Horn. I held the ladder, put out the fire on deck with sand, and the wall held. At dawn the city fell somewhere else. I pulled a sailor out from between the quay and the hull and translated a quarter's surrender. — T."
SIEGE_NOTE_38O_2,"Haliç. Merdiven sallandı, sur dayandı. Sabah şehir başka yerden düştü. Suya düşeni yaşlı tayfa çekti; ben halatı tuttum. Kaçan gemileri yalnız fotoğrafladım. — T.","The Horn. The ladder wobbled and the wall held. At dawn the city fell somewhere else. The old sailor pulled the man out of the water; I held the rope. The ships that got away, I only photographed. — T."
LORE_38O_1_T,"Haliç'teki gemiler","The ships in the Horn"
LORE_38O_1,"22 Nisan'da karadan aşırılan gemiler Haliç surlarını kuşatmanın sonuna kadar tehdit etti; savunucular bu yüzden kara surlarından adam ayırmak zorunda kaldı. Son hücumda bu gemiler surlara merdiven dayadı, ama Haliç suru kara surları düşene kadar dayandı.","The ships hauled overland on 22 April threatened the Horn walls until the end of the siege, forcing the defenders to take men off the land walls. In the final assault they put ladders to the walls, but the Horn wall held until the land walls fell."
LORE_38O_2_T,"Giritli denizciler","The Cretan sailors"
LORE_38O_2,"Şehir düştükten sonra da Haliç'in ağzına yakın üç kulede Giritli denizciler direndi. Öğleden sonra Sultan onların gemileri ve eşyalarıyla serbestçe gitmelerine izin verdi.","Even after the city had fallen, Cretan sailors held out in three towers near the mouth of the Horn. In the afternoon the Sultan let them sail away freely with their ships and belongings."
LORE_38O_3_T,"Zincirin kesilmesi","Cutting the boom"
LORE_38O_3,"Öğleye doğru Venedik kadırgaları ve Ceneviz gemileri Haliç'in ağzındaki zincire indi. Barbaro'ya göre iki denizci baltayla zincirin bağlarını kesti. Barbaro da o gemilerdeydi; günlüğü bu yüzden bugüne kaldı.","Towards noon the Venetian galleys and Genoese ships ran down to the boom at the mouth of the Horn. According to Barbaro two sailors cut its fastenings with axes. Barbaro was aboard; that is why his diary survives."
UI_RECAP_38O_PREV,"29 Mayıs şafağında su ve merdiven taşıdın; Hasan sancağı burca dikti. Öğleden sonra Sultan Ayasofya'ya girdi.","At dawn on 29 May you carried water and ladders; Hasan planted the banner on the tower. That afternoon the Sultan entered Hagia Sophia."
UI_RECAP_38O_NEXT,"Petrion teslim oldu. 29 Mayıs akşamı: Sultan'ın çavuşuyla mahalleye giriyorsun; kapılara emanet sancağı.","Petrion has surrendered. Evening, 29 May: you enter the quarter with the Sultan's çavuş; banners of protection for the doors."
```

Replikler:

```csv
D38O_N_01,"Tolga Bey, takvimi bir kez daha geri sarıyorum: 29 Mayıs, gece bir buçuk. Bu sefer Haliç'tesiniz. Kara surlarındaki kendinize rastlamazsınız; Büro aynı kişiyi aynı gece iki yere koymayı sevmez, ama bazen mecbur kalır.","Mr Tolga, I'm winding the calendar back once more: 29 May, half past one at night. This time you're on the Horn. You won't run into yourself at the land walls; the Bureau doesn't like putting one person in two places on the same night, but sometimes it has to."
D38O_T_01,"Bir saat önce Hasan'a su verdim. Şimdi aynı saatte bir teknedeyim. Mesai çizelgem bunu nasıl gösterecek?","An hour ago I gave Hasan water. Now, at the same hour, I'm on a boat. How is my timesheet going to show this?"
D38O_R_01,"Kâtip! Zincirin önündeki göz! Bir kürek boyu kaçırmıştık, hatırladın mı? Bu gece kaçacak bir şey yok: biz gidiyoruz, sur yerinde duruyor.","Clerk! The eyes before the chain! We missed by one oar's length, remember? Tonight nothing's getting away: we're the ones going, and the wall stays put."
D38O_T_R1,"Reis! Siz de mi Haliç'in içine geçtiniz?","Captain! You've come inside the Horn too?"
D38O_R_02,"Gemileri tepeden aşırdılar, biz de içindeydik. Kürek başına. Yeşil yerde çek; bu gece su şapırdasın, sur duysun. Duysun ki korksun.","They hauled the ships over the hill and we were in them. To the oar. Pull on the green; tonight let the water slap and the wall hear it. Let it hear and be afraid."
D38O_S2_01,"Kırk yıldır kürek çekerim; denizden sura merdiven dayamadım. İlk iş her yaşta zor.","Forty years I've pulled an oar, and never put a ladder to a wall from the sea. First times are hard at any age."
D38O_R_ROW_OK,"Böyle! Öndeki fustaya yetiş!","Like that! Catch the fusta ahead!"
D38O_R_ROW_BAD,"Kürekler çarpıştı! Ritim!","The oars clashed! Rhythm!"
D38O_S_ARROW,"Ok! Küpeştenin dibine!","Arrows! Down by the rail!"
D38O_R_03,"Sura yanaştık! Merdiveni kaldırın! Kâtip, ayağını tut; tekne sallanırsa merdiven sallanır, sallanan merdivenden adam düşer.","We're alongside the wall! Raise the ladder! Clerk, hold its foot; if the boat rocks the ladder rocks, and men fall off a rocking ladder."
D38O_T_02,"Deniz sallıyor, sur itiyor, ben tutuyorum. Ortada kalan hep ben oluyorum.","The sea rocks it, the wall pushes it, I hold it. I'm always the one stuck in the middle."
D38O_S_FORK,"Çatal! Yukarıdan itiyorlar! Bastır!","A fork! They're pushing it off! Brace!"
D38O_S_BRACE_OK,"Tuttu! Merdiven yerinde!","It held! The ladder's still up!"
D38O_S_BRACE_BAD,"Kaydı! Tut, tut!","It's slipping! Hold it, hold it!"
D38O_S_POT,"Çömlek! Güverte yanıyor! Kum, kâtip, kum!","A pot! The deck's on fire! Sand, clerk, sand!"
D38O_T_POT_OK,"Söndü. Yangın tüpü olmayan bir dünyada kum kovası en iyi arkadaşım.","It's out. In a world without fire extinguishers, a sand bucket is my best friend."
D38O_S_SAIL,"Yelken tutuştu! Kova! Kova!","The sail's caught! Buckets! Buckets!"
D38O_R_UP,"Sen de çık, kâtip! Mazgalın ağzını gör, gel. Kimse senden sur almanı beklemiyor.","You go up too, clerk! Look over the parapet and come down. Nobody expects you to take a wall."
D38O_S_OIL,"Kazan! Yana sarkın, yağ geliyor!","The cauldron! Lean aside, here comes the oil!"
D38O_T_UP,"Yukarıda kaynar yağ kokusu var. Ve Venedik aksanıyla bağırılan küfürler. İniyorum.","Up there it smells of boiling oil. And of swearing in a Venetian accent. I'm coming down."
D38O_R_BACK,"Geri! Burası dayanıyor. Kara tarafından haber gelmeden bu sur düşmez.","Back! This part's holding. This wall won't fall until word comes from the land side."
D38O_S2_02,"Bak! Batıda, kulelerin üstünde... Bizim sancak!","Look! To the west, on the towers... Our banner!"
D38O_N_02,"Aziz Romanos kapısı yöresi, Tolga Bey. Kara surlarında sancaklar. Sizin öbür kaydınız saatlerdir oradaydı.","The St Romanus gate, Mr Tolga. Banners on the land walls. Your other record has been there for hours."
D38O_T_03,"Hasan...","Hasan..."
D38O_S_03,"Surdakiler kaçıyor! Kapı açıldı! Herkes karaya! Şehir bizim!","They're running from the wall! The gate's open! Everyone ashore! The city is ours!"
D38O_R_04,"Durun! Gemiyi kim tutacak? ...Gittiler. Kâtip, yaşlı, siz kalın. Halatı babaya sar, akıntı bizi sura vurmasın.","Stop! Who's going to mind the ship? ...They're gone. Clerk, old man, you stay. Wrap the rope round the bollard, don't let the current smash us into the wall."
D38O_S2_FALL,"Adam suya düştü! Rıhtımla teknenin arasına! Çek onu, ezilmeden!","Man in the water! Between the quay and the hull! Pull him out before he's crushed!"
D38O_T_PULL,"Tuttum! Elini ver! ...Tamam. Yaşıyor. Islak ama yaşıyor.","Got you! Give me your hand! ...There. He's alive. Wet, but alive."
D38O_S2_HOOK,"Çekil kâtip, kancayla alırım! ...Hah. Kırk yılın kancası.","Out of the way, clerk, I'll get him with the hook! ...There. Forty years' worth of hook."
D38O_S_SAVED,"Karaya koşarken ayağım kaydı. Allah'ın işi; bana dur dedi galiba.","My foot slipped while I was running ashore. God's doing; I think He was telling me to stop."
D38O_TW_01,"(Rumca) Biz Petrion'un ihtiyarlarıyız. Mahallemiz direnmeyecek. Kapılarımızı açıyoruz; evlerimize ve kilisemize dokunulmasın.","(In Greek) We are the elders of Petrion. Our quarter will not resist. We are opening our gates; let our houses and our church be spared."
D38O_R_05,"Ne diyor, kâtip? Kelimesi kelimesine.","What's he saying, clerk? Word for word."
D38O_T_TR,"Teslim oluyorlar, reis. Mahallenin kapılarını açıyorlar. Evlerine ve kiliselerine dokunulmasın istiyorlar.","They're surrendering, captain. They're opening the quarter's gates. They ask that their houses and their church be spared."
D38O_T_TR_ADD,"Teslim oluyorlar, reis. Kapılarını açıyorlar, evlerine ve kiliselerine dokunulmasın istiyorlar. Bir de... kimseye zarar vermediklerini söylüyorlar.","They're surrendering, captain. They're opening their gates and ask that their houses and church be spared. And... they say they've harmed no one."
D38O_R_06,"Teslim olana el kalkmaz; Sultan'ın sözü budur. Ben reisim, paşa değilim; ama sözü yukarı götürürüm. Kâtip, akşam çavuşla mahalleye sen gireceksin. Dili bilen sensin.","No hand is raised against those who surrender; that's the Sultan's word. I'm a captain, not a pasha, but I'll carry the word up. Clerk, this evening you go into the quarter with the çavuş. You're the one with the language."
D38O_S2_03,"Reis! Frenk gemileri! Zincire iniyorlar!","Captain! The Frankish ships! They're heading for the chain!"
D38O_R_07,"Kürek! Önlerini kesin! ...Kaç kişiyiz? Altı. Altı kürekle kadırga kovalanmaz. Yine de çek, kâtip; görsünler ki biri kaldı.","Oars! Cut them off! ...How many of us are there? Six. You can't chase a galley with six oars. Pull anyway, clerk; let them see someone stayed."
D38O_R_LEFT,"Sola! Sola kır!","Left! Hard left!"
D38O_R_RIGHT,"Sağa! Sağa!","Right! Right!"
D38O_S_SPLASH,"Yakından geçti! Kürek kırıldı!","That was close! An oar's broken!"
D38O_N_PHOTO,"Kaydedin, Tolga Bey: Venedik kadırgaları, Ceneviz gemileri. Barbaro şu an onlardan birinde; günlüğü onunla birlikte gidiyor.","Record it, Mr Tolga: Venetian galleys, Genoese ships. Barbaro is on one of them right now; his diary is leaving with him."
D38O_N_BOOM,"Barbaro'ya göre iki denizci baltayla zincirin bağlarını kesti, gemiler açığa çıktı. Haliç'teki tayfa şehre dağılmıştı; peşlerine düşen olmadı. Siz dışında.","According to Barbaro two sailors cut the boom's fastenings with axes and the ships got out. The crews in the Horn had scattered into the city; no one went after them. Except you."
D38O_N_CRETE,"Bir not daha: Haliç'in ağzındaki üç kulede Giritli denizciler öğleden sonraya kadar teslim olmadı. Sultan cesaretlerine saygı gösterdi, gemileriyle gitmelerine izin verdi.","One more note: in three towers at the mouth of the Horn, Cretan sailors didn't surrender until the afternoon. The Sultan honoured their courage and let them leave with their ships."
D38O_R_END,"Önce bir kürek boyu kaçırdık, şimdi bir mil. Ama gemi burada, adam burada. Reis dediğin bunu sayar.","First we missed by an oar's length, now by a mile. But the ship's here and the man's here. That's what a captain counts."
D38O_T_END,"Bugün kovaladığımız hiçbir şeyi yakalamadık. Bir adamı sudan çektim, bir halatı bağladım, bir cümleyi çevirdim. Raporuma üçünü de yazıyorum.","Today we caught nothing we chased. I pulled a man out of the water, tied a rope, translated a sentence. All three go in my report."
D38O_N_END,"Kaydedildi. 29 Mayıs, Haliç, Osmanlı nüshası. Akşam Petrion'a çavuşla giriyorsunuz. Dilinizi yanınızda götürün.","Recorded. 29 May, the Horn, the Ottoman copy. This evening you go into Petrion with the çavuş. Take your languages with you."
```

---

## 3. Bölüm 39 — "Emanet" (29 Mayıs 1453 akşamı → gece)

### 3.1 Tarihî dayanak

- **Yağma ve teslim olan mahalleler:** Şehrin çoğunda 29 Mayıs boyunca yağma sürdü; kaynaklar süresinde anlaşamaz (kimi üç
  gün der, kimi Sultan'ın ilk gün durdurduğunu yazar) (**R**, **K**, **D**). Petrion ve Psamathia gibi kendiliğinden
  teslim olan birkaç mahalle Sultan'ın adamlarınca korundu (**R**). Bölüm yağmayı göstermez ve süslemez; Nihat'ın açılış
  satırı onu saklamaz. Uzak semtlerdeki yangınlar kaynaklarda geçer; bir kıvılcımın korunan mahallede bir evi tutuşturması
  **(kurgu)**.
- **Kapıdaki sancak:** Askerler girdikleri evi kapısına sancak dikerek işaretlerdi (26'da `D26_N_FLAGS`). Burada aynı işaretin
  tersi: Sultan'ın işareti + nöbetçi = "emanet" **(kurgu; muhafız konması R'ye dayanır)**.
- **Kilise kapısı:** teslimden habersiz başka gemilerin tayfasıyla çavuşun karşılaşması **(kurgu)**. "Emanete el uzatan…"
  26'daki Fatih repliğinin (`D26_F_TRUST`, **TB**'nin anlattığı mermer kırmayı men etme) yankısıdır.
- **İmparator:** XI. Konstantinos'un akıbeti belirsizdir: çoğu kaynak surda savaşarak düştüğünü yazar (**K**; **S**
  öldüğünü yazar, ölümünü görmemiştir), ayrıntılar çelişir, mezarı bilinmez. Hiçbir sürüm gösterilmez; baş/beden anlatısı
  yoktur. Kerkoporta yok.

### 3.2 Yer ve sistemler

- **Harita:** `FallenCity` + iki seçenek (`fallen_city.gd`, yeni dosya yok):
  - `spared := true`: evler "sooted"/sağlam (burnt/collapsed yok; **yalnız bir ev**, listedeki 6. ev, kurgu yangını için
    "yangın kurulumu": çatı kirişleri, cumba, iç oda, düşebilir çatı parçaları); kapılarda başlangıçta sancak yok; yağmacı
    sandık taşıyanlar ve yakın duman sütunları yok; sağdaki saray cephesi yerine iki ev. İki evin önünde (yolun ortasında)
    moloz yığını **yan sokağı** kapatır; yığının üstü ve iki tek katlı evin damı **tırmanılabilir kestirme**.
  - `harbor_end := true`: caddenin sur ucunda kara surunun iç kapısı yerine 38'in Haliç suru parçası ve açık deniz kapısı
    (`SeaWalls.gate`). LandWalls kurulmaz. Öbür uçtaki yeniçeri sırası yerinde (mahallenin sınırı).
  - Soldaki kilise aynen; kapı kanatları **kapalı** başlar, kapıya `hp` çubuğu ve kırılma aşamaları (3 ağ: sağlam, yarık,
    kırık).
- **Işık:** alacakaranlık (turuncu) → gece `Night.environment`; kapılarda `Night.torch`, kilisenin önünde
  `Night.campfire`; uzakta şehrin başka semtlerinde gökyüzünde turuncu pus (ayrıntısız).
- **Kalabalık:** `Walker` halk (ikisi "?" işaretli), yağmacı tayfa üç `Walker` (hedef kapılı yol), `Crowd` yeniçeriler.
- **Yeniden kullanılan:** `player.enable_climb([cadde dikdörtgeni])` (Traversal: dam ve moloz kestirmesi, yanan evin cumbası;
  nefes), eşya gösterme (tezkire), NPC takip (30o ekip yürüyüşü), `RowMeter` (çekişme: balta sapı), `Vfx.fire` + duman
  (21o'nun dumanı: görüş düşer, can 2/sn azalır), `BalanceMeter` (iple indirme), `_drop_stone` (düşen kiremit), `hud.choose`,
  `TespitCam`, `Lore.scatter(self, "39o")`, `Grade.finish("39o")`.
- **Süre hedefi:** 10–12 dk; durdurulan konuşma ≤ 2,5 dk (%22).

### 3.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 0. Kapı | 19.30 | `UI_OBJ39O_CAVUS` | Deniz kapısından girilir; çavuş ve ihtiyar bekler (45 sn konuşma). **6 sancak** + ipucu listesi. | — |
| 1. Sancak yarışı | Alacakaranlık | `UI_OBJ39O_FLAG` + `UI_HINT39O_1..6` | Caddede ~16 kapı. Doğru kapıda **E** (1 sn dikme animasyonu, bu sırada hareket yok). Yanlış kapı: −10 sn. **Üç yağmacı tayfa** 50., 100. ve 150. sn'lerde listedeki sancaksız bir kapıya **koşar** (haritada değil, sesten ve görüntüden fark edilir: "Bu kapı benim!" bağırışı uzaktan); Tolga'dan önce varırsa kendi sancağını diker: kapı kaybedilir. Moloz ve dam üstünden **kestirme** (serbest tırmanma, nefes; dam kenarından düşersen −15 can). Süre **3 dk**. | Sayaç: sancak /6. |
| 2. Kilise kapısı | Akşam | `UI_OBJ39O_DOOR`, `UI_OBJ39O_FIND`, `UI_OBJ39O_LEAD`, `UI_OBJ39O_STRUGGLE` | Papaz koşar: kilisenin kapısında baltalı iki tayfa. Kapı çubuğu **100 → 0, saniyede −2**. (a) **Tezkire göster** (en çok 2): her biri 15 sn durdurur. (b) Çavuş caddenin iki ucundan birinde (rastgele); "?" işaretli halka **sor** (E) → yön oku. Yan sokak molozla kapalı: **molozdan tırman** ya da uzun yoldan dön. (c) Çavuşa ulaş (E), **önden koş**: çavuş 3,2 m/sn izler; 12 m'den fazla açılırsan durur. (d) Çubuk 25'in altına inerse kapıda **çekişme** açılır: balta sapını kavra (E), RowMeter çekiş: 3 iyi vuruş = baltayı alırsın, +12 sn; kötü vuruşta itilirsin (yere düşme, −15 can, 3 sn). Silah yok, kimse yaralanmaz. | Çubuk sıfıra inmeden çavuş kapıdaysa "kapı dayandı"; yoksa kapı kırılır ama çavuş eşikte durur (içeridekiler korunur; tarih değişmez). |
| 3. Yangın | 22.00 | `UI_OBJ39O_FIRE`, `UI_OBJ39O_SMOKE`, `UI_OBJ39O_LOWER` | Uzak bir yangından gelen kıvılcım kilisenin yanındaki evin (listedeki 6. ev) damını tutuşturur; üst katta yaşlı bir adam. **90 sn çatı sayacı.** (a) Kapı alevli: **cumbaya tırman** (Traversal; nefes; alev saçağı: saçağın altından geçerken −10 can/sn). (b) İçeride **duman**: görüş 6 m'ye iner, can 2/sn azalır; eğilerek (C) yürürsen 1/sn. Öksürük sesine göre adamı bul (karanlık oda, iki oda). (c) Adamı pencereye götür (E: kolundan tut, yavaş yürür), **iple indir**: E basılı ip salınır, `BalanceMeter` (ip pencere kenarında sürtünüp sallanır); ibre taşarsa adam sarsılır ve ip bir an takılır (−3 sn). Aşağıda yeniçeri ve **faz 2'nin tayfası** ipi karşılar. (d) Kendin in: cumbadan atla ya da tırmanarak in. Bu arada **düşen kiremitler** (gölge, 1 sn; −20 can). | Sayaç biterse çatı çöker: Tolga'yı ve adamı yeniçeri ile tayfa kapıdan çeker (yaralı ama sağ), sonuç puanı −1. Can 0 → aynı. |
| 4. Nöbet | Gece yarısı | `UI_OBJ39O_SIT`, `UI_OBJ39O_PHOTO` | Nöbet ateşinin başına otur (E): yeniçeri ve tayfa İmparator'u sorar → **seçim** (3). Nihat. **Tespit:** kilise kapısı: eşikte papaz, kapıda yeniçeri, içeride mumlar (pencere 60 sn). | Kare kaçarsa not. |

**Animasyon ve görsel geri bildirim**
- **Faz 0:** deniz kapısının kanatları açık, ihtiyar elindeki anahtar demetini çavuşa uzatır (el-ele geçiş); sancaklar
  Tolga'nın sırtında demet hâlinde görünür, her dikilen sancakla demet incelir.
- **Faz 1:** sancak dikme: Tolga direği kapı halkasına geçirir ve iki vuruşla sıkıştırır (çekiç değil avuç; kumaş açılıp
  dalgalanır); bir yeniçeri o kapıya **yürüyerek** gelir, kapının yanında durur (cadde zemininde; caddenin hafif eğimini
  izler). Yağmacı koşarken gölgesi ve meşalesi duvarlarda; kendi sancağını dikerken aynı animasyon (karşılık). Yanlış
  kapıda kapı aralanır, korkmuş bir yüz görünür ve kapanır. Tırmanmada eller dam saçağına tutunur, kiremitler ayak altında
  tıkırdar (bir iki kiremit kayıp düşer, kırılır).
- **Faz 2:** iki tayfa baltayı sırayla vurur (iki elle, omuzdan); her vuruşta kapıdan kıymık sıçrar, kanatta yarık
  büyür (kırılma aşamaları), menteşe gıcırdar; tezkire gösterilince tayfa baltayı indirir, kâğıda eğilir, mühre dokunur;
  çekişmede iki el balta sapında, ileri geri itişme; kaybedince Tolga geriye savrulup yere oturur. Çavuş koşmaz, uzun
  adımla yürür (yaşı), elini kaldırınca tayfalar bir adım geri çekilir. Kapı kırılırsa kanat içe düşer, toz.
- **Faz 3:** damda alev saçağı (Vfx.fire ×3), kıvılcımlar yukarı, duman pencerelerden taşar; iç odada duman katmanı
  tavandan aşağı iner (yükseklik zamanla düşer, eğilince baş altında kalır); adam yerde öksürür, kolundan tutulunca Tolga'ya
  yaslanır; ip pencere direğine iki sarım (görünür), adam ipin ucunda yavaş iner, ip gerilir ve sürtünme noktasında toz;
  aşağıda yeniçeri ve tayfa kollarını açar, adamı yakalar. Kiremit: gölge, düşer, üçe bölünür. Çatı çökerse kirişler içe
  düşer, kıvılcım bulutu, ekran beyaz-turuncu parlar. Kova zinciri: tayfa, yeniçeri ve iki komşu kova taşır (kuyu → ev),
  su yayı alevlere düşer (17o kova kodu).
- **Faz 4:** ateşin başında oturanlar (oturma pozu, zemin y'sinde), alev titreşir (`Night.flicker`); papazın elindeki mum.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **39O.1** Altı kapı emanette, kapı dayandı, adam zamanında indi | sancak ≥ 5/6 **ve** kapı çubuğu > 0 **ve** çatı çökmeden indi | `FLOW_39O_1` |
| **39O.2** Bazı kapılar geç kaldı | aksi hâlde | `FLOW_39O_2` |

Seçim `GameState.flags["emperor_answer"] = "know" / "wall" / "write"` (31o'da azabın bir bark'ı buna bakar).
`--autotest[=late]` (varsayılan 39O.1; `=late`: bot üç sancak diker, çavuşu ikinci uçta arar, dumanda yavaş kalır).
Akış şeması (`UI_FLOW39O_TITLE`): `FLOW39O_GATE` → `FLOW39O_FLAGS` → `FLOW39O_DOOR` → `FLOW39O_FIRE` → `FLOW39O_WATCH` →
{`39O.1`, `39O.2`}; altında `Grade.finish("39o")` ve `UI_CH39O_STATS`.

### 3.4 Konuşanlar

Koşullu: `D39O_C_01_ADD` yalnız `petrion_word == "add"`. `_FLAG_*`, `SA_FLAG`, `C_LATE`, `TW_POINT`, `SA_TEZ`, `C_FAR`,
`T_STRUGGLE_*`, `S_TILE`, `T_SMOKE` olay bark'larıdır. `D39O_T_DOOR_BROKE` yalnız kapı kırıldıysa; `D39O_J_ROOF` yalnız
çatı çöktüyse. Faz 4'te seçime göre `D39O_J_KNOW` / `_WALL` / `_WRITE`.

| Anahtar | Konuşan |
|---|---|
| `D39O_N_01` | SPK_NIHAT |
| `D39O_T_01` | SPK_TOLGA |
| `D39O_C_01` | SPK_CAVUS |
| `D39O_C_01_ADD` | SPK_CAVUS |
| `D39O_C_02` | SPK_CAVUS |
| `D39O_TW_01` | SPK_TOWNSMAN |
| `D39O_T_02` | SPK_TOLGA |
| `D39O_C_FLAG_OK` | SPK_CAVUS |
| `D39O_C_FLAG_WRONG` | SPK_CAVUS |
| `D39O_SA_FLAG` | SPK_SAILOR |
| `D39O_C_LATE` | SPK_CAVUS |
| `D39O_T_FLAGS` | SPK_TOLGA |
| `D39O_PR_01` | SPK_PRIEST |
| `D39O_T_03` | SPK_TOLGA |
| `D39O_SA_01` | SPK_SAILOR |
| `D39O_T_TEZ` | SPK_TOLGA |
| `D39O_SA_TEZ` | SPK_SAILOR |
| `D39O_TW_POINT` | SPK_TOWNSMAN |
| `D39O_T_STRUGGLE_OK` | SPK_TOLGA |
| `D39O_T_STRUGGLE_BAD` | SPK_TOLGA |
| `D39O_C_FAR` | SPK_CAVUS |
| `D39O_C_03` | SPK_CAVUS |
| `D39O_T_DOOR_BROKE` | SPK_TOLGA |
| `D39O_SA_02` | SPK_SAILOR |
| `D39O_C_04` | SPK_CAVUS |
| `D39O_T_04` | SPK_TOLGA |
| `D39O_PR_02` | SPK_PRIEST |
| `D39O_T_05` | SPK_TOLGA |
| `D39O_PR_FIRE` | SPK_PRIEST |
| `D39O_T_FIRE` | SPK_TOLGA |
| `D39O_T_SMOKE` | SPK_TOLGA |
| `D39O_S_TILE` | SPK_SAILOR |
| `D39O_SA_ROPE` | SPK_SAILOR |
| `D39O_J_ROOF` | SPK_JANISSARY |
| `D39O_PR_03` | SPK_PRIEST |
| `D39O_J_01` | SPK_JANISSARY |
| `D39O_SA_03` | SPK_SAILOR |
| `D39O_J_KNOW` | SPK_JANISSARY |
| `D39O_J_WALL` | SPK_JANISSARY |
| `D39O_J_WRITE` | SPK_JANISSARY |
| `D39O_N_EMP` | SPK_NIHAT |
| `D39O_N_PHOTO` | SPK_NIHAT |
| `D39O_N_PHOTO_OK` | SPK_NIHAT |
| `D39O_C_END` | SPK_CAVUS |
| `D39O_T_END` | SPK_TOLGA |
| `D39O_N_END` | SPK_NIHAT |

### 3.5 Metinler

```csv
UI_CH39O_TITLE,"BÖLÜM {N} — EMANET","CHAPTER {N} — IN TRUST"
UI_CH39O_SUB,"29 Mayıs 1453 · Petrion mahallesi, Haliç kıyısı · akşam","29 May 1453 · The Petrion quarter, on the Golden Horn · evening"
UI_FLOW39O_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: EMANET","FLOWCHART — CHAPTER {N}: IN TRUST"
UI_OBJ39O_CAVUS,"Deniz kapısında çavuşu bul","Find the çavuş at the sea gate"
UI_OBJ39O_FLAG,"Listedeki kapılara Sultan'ın sancağını dik (E) · %d/%d","Plant the Sultan's banner on the listed doors (E) · %d/%d"
UI_HINT39O_1,"Mavi kapı, üstünde oyma bir balık","A blue door with a carved fish above it"
UI_HINT39O_2,"Kuyunun tam karşısı","Directly across from the well"
UI_HINT39O_3,"Asmalı avlu, iki küp","A courtyard with a vine and two jars"
UI_HINT39O_4,"Kapı üstünde ikon nişi, kandili sönmüş","An icon niche above the door, its lamp gone out"
UI_HINT39O_5,"Kırık kepenkli, kırmızı pencere","A red window with a broken shutter"
UI_HINT39O_6,"Kilisenin yanındaki ev, cumbalı","The house beside the church, with the bay window"
UI_OBJ39O_DOOR,"Kilisenin kapısı: tezkireyi göster, çavuşu bul","The church door: show your warrant, find the çavuş"
UI_OBJ39O_FIND,"Çavuşu bul: halka sor (E) · moloz kestirme (Space)","Find the çavuş: ask the townspeople (E) · shortcut over the rubble (Space)"
UI_OBJ39O_LEAD,"Çavuşu kiliseye götür (önden koş)","Lead the çavuş to the church (run ahead)"
UI_OBJ39O_STRUGGLE,"Balta sapını kavra: işaret yeşilken Space","Grab the axe handle: Space on the green"
UI_OBJ39O_FIRE,"Ev yanıyor! Cumbaya tırman · çatı: %d sn","The house is burning! Climb the bay window · roof: %d s"
UI_OBJ39O_SMOKE,"Dumanda eğil (C basılı), öksürüğü takip et","Stoop in the smoke (hold C), follow the coughing"
UI_OBJ39O_LOWER,"Adamı iple indir (E basılı · ibreyi ortada tut)","Lower the man on the rope (hold E · keep the needle centred)"
UI_OBJ39O_SIT,"Nöbet ateşinin başına otur","Sit down at the watch fire"
UI_OBJ39O_PHOTO,"Tespit et: kilisenin kapısında nöbet","Record: the watch at the church door"
UI_PROMPT39O_FLAG,"E: sancağı dik","E: plant the banner"
UI_PROMPT39O_SHOW,"E: tezkireyi göster","E: show the warrant"
UI_PROMPT39O_ASK,"E: çavuşu sor","E: ask about the çavuş"
UI_PROMPT39O_CALL,"E: 'Çavuş! Kiliseye!'","E: 'Çavuş! The church!'"
UI_PROMPT39O_AXE,"E: balta sapını kavra","E: grab the axe handle"
UI_PROMPT39O_ARM,"E: kolundan tut","E: take his arm"
UI_PROMPT39O_ROPE,"E basılı: ipi sal","Hold E: pay out the rope"
UI_PROMPT39O_SIT,"E: ateşin başına otur","E: sit by the fire"
UI_C39O_KNOW,"Bilmiyorum.","I don't know."
UI_C39O_WALL,"Surda, adamlarının yanında düştü diyorlar.","They say he fell on the wall, beside his men."
UI_C39O_WRITE,"Kimse bilmiyor. Ben de öyle yazacağım.","Nobody knows. That's what I'll write."
FLOW39O_GATE,"Deniz kapısında çavuş","The çavuş at the sea gate"
FLOW39O_FLAGS,"Kapılara emanet sancağı","Banners of protection on the doors"
FLOW39O_DOOR,"Kilisenin kapısı","The church door"
FLOW39O_FIRE,"Yanan ev, iple inen adam","The burning house, the man on the rope"
FLOW39O_WATCH,"Nöbet ateşi: İmparator'a ne oldu?","The watch fire: what happened to the Emperor?"
FLOW_39O_1,"Altı kapı emanette, kilise kapısı dayandı","Six doors in trust; the church door held"
FLOW_39O_2,"Bazı kapılar geç kaldı","Some doors were too late"
UI_CH39O_STATS,"Sancak: %d/%d   ·   Kapı: %d/100   ·   Çatı: %d sn kala   ·   Dosya: %d/%d sayfa","Banners: %d/%d   ·   Door: %d/100   ·   Roof: %d s to spare   ·   File: %d/%d pages"
SIEGE_DATE_39,"29 Mayıs 1453, akşam","29 May 1453, evening"
SIEGE_EV_39,"Şehrin çoğunda yağma sürer. Kendiliğinden teslim olan Petrion gibi birkaç mahalleye Sultan'ın adamları muhafız koyar. İmparator'un akıbeti bilinmiyor.","Most of the city is being plundered. A few quarters that surrendered of their own accord, such as Petrion, are given guards by the Sultan's men. The Emperor's fate is unknown."
SIEGE_NOTE_39O_1,"Petrion. Altı kapıya sancak diktik; kilisenin kapısı dayandı; yanan evden bir adamı iple indirdik. Şehrin geri kalanını kimse tutamadı. Bu sayfa yalnız bir sokağı kapsar. — T.","Petrion. We put banners on six doors; the church door held; we lowered a man on a rope from a burning house. No one could hold the rest of the city. This page covers one street only. — T."
SIEGE_NOTE_39O_2,"Petrion. Bazı kapılara geç kaldım; kilisenin kapısı kırıldı ama çavuş eşikte durdu, içeridekilere dokunulmadı. Kapsam: bir sokak, eksik. — T.","Petrion. I was too late for some doors; the church door was broken, but the çavuş stood on the threshold and no one inside was touched. Coverage: one street, incomplete. — T."
LORE_39O_1_T,"Teslim olan mahalleler","The quarters that surrendered"
LORE_39O_1,"Şehir düşerken Haliç kıyısındaki Petrion ve Marmara kıyısındaki Psamathia gibi birkaç mahalle direnmeden teslim oldu. Runciman'a göre bu mahallelere Sultan'ın adamları muhafız koydu; evleri ve kiliseleri yağmadan kurtuldu.","As the city fell, a few quarters, such as Petrion on the Golden Horn and Psamathia on the Marmara, surrendered without resistance. According to Runciman the Sultan's men set guards there, and their houses and churches escaped the plunder."
LORE_39O_2_T,"Kapıdaki sancak","The banner on the door"
LORE_39O_2,"Şehre giren askerler girdikleri evin kapısına küçük bir sancak dikerdi; sancaklı eve başkası girmezdi. Teslim olan mahallelerde aynı işaret tersine işledi: kapıdaki Sultan'ın işareti ve nöbetçi, o evin emanet olduğunu söylüyordu.","Soldiers who entered the city planted a small banner on the door of each house they took; no one else went into a house with a banner. In the quarters that surrendered the same sign worked the other way round: the Sultan's mark and a guard on the door said the house was held in trust."
LORE_39O_3_T,"İmparator'un sonu","The Emperor's end"
LORE_39O_3,"XI. Konstantinos'un nasıl öldüğü bilinmiyor. Kaynakların çoğu onun surda, adamlarının arasında savaşırken düştüğünü yazar; ayrıntılar birbirini tutmaz. Mezarı bilinmez.","How Constantine XI died is not known. Most sources say he fell fighting on the wall among his men; the details do not agree. His grave is unknown."
UI_RECAP_39O_PREV,"Haliç'te merdiven tuttun, suya düşen bir tayfayı çektin, Petrion'un teslimini çevirdin; Hristiyan gemileri zinciri kesti.","On the Horn you held a ladder, pulled a sailor from the water and translated Petrion's surrender; the Christian ships cut the boom."
UI_RECAP_39O_NEXT,"Petrion'da nöbet var. 30 Mayıs: yanık bir evde mahsur kalanlar; sonra Eyüp ve Ayasofya'da ilk cuma.","Petrion is under guard. 30 May: people trapped in a burnt house; then Eyüp, and the first Friday in Hagia Sophia."
```

Replikler:

```csv
D39O_N_01,"Akşam oldu, Tolga Bey. Şehrin çoğunda yağma sürüyor; kaynaklar bunu saklamaz, ben de saklamayacağım. Ama Petrion gibi teslim olan birkaç mahalleye Sultan'ın adamları muhafız koydu. Siz bu gece o muhafızların dilisiniz.","Evening, Mr Tolga. Most of the city is being plundered; the sources don't hide it and neither will I. But a few quarters that surrendered, like Petrion, were given guards by the Sultan's men. Tonight you are those guards' tongue."
D39O_T_01,"Bütün gün su taşıdım, kürek çektim, halat bağladım. Şimdi tercümanım. Özgeçmişime sığmıyor.","All day I've carried water, pulled an oar, tied ropes. Now I'm an interpreter. It won't fit on my CV."
D39O_C_01,"Reisin kâtibi sen misin? İki dil biliyormuşsun. Ben Sultan'ın çavuşu Davud. Elimde emir var, dilimde Rumca yok. Sen olacaksın.","You're the captain's clerk? They say you know both tongues. I am Davud, the Sultan's çavuş. I have the order in my hand and no Greek on my tongue. You'll be it."
D39O_C_01_ADD,"Reis, 'kimseye zarar vermediler' dediğini söyledi. Doğru mu, bilmem. Ama söz bir kere söylendi; artık bizim yükümüz.","The captain told me you said 'they have harmed no one'. Whether it's true I don't know. But the word has been spoken; now it's ours to carry."
D39O_C_02,"Şu sancaklar Sultan'ın. Listedeki her kapıya bir tane. Çabuk ol; bu mahallenin teslim olduğunu bilmeyen gemiciler sokakta.","These banners are the Sultan's. One on every door on the list. Be quick; there are sailors in the streets who don't know this quarter has surrendered."
D39O_TW_01,"(Rumca) Kapıları adla değil, işaretle söyleyeyim; sokaklarımızın adı yok. Mavi kapı, üstünde balık. Kuyunun karşısı. Asmalı avlu...","(In Greek) I'll give you the doors by their marks, not by names; our streets have none. The blue door with the fish. Across from the well. The courtyard with the vine..."
D39O_T_02,"Adres: 'kuyunun karşısı'. Bizim kargo da tam böyle bulurdu.","Address: 'across from the well'. That's exactly how our couriers find people too."
D39O_C_FLAG_OK,"Oldu. Bir kapı daha emanette.","Done. One more door in trust."
D39O_C_FLAG_WRONG,"O değil! O kapı listede yok.","Not that one! That door isn't on the list."
D39O_SA_FLAG,"Bu kapı benim! Sancağımı diktim!","This door's mine! I've planted my banner!"
D39O_C_LATE,"Geç kaldık. Onun sancağı dikilmiş. O evin hesabını yarın subaşı sorar; bu gece ben soramam.","We're too late. His banner's up. Tomorrow the governor will settle that house; tonight I can't."
D39O_T_FLAGS,"Kapılar sancaklı. Sigortada buna 'teminat altına alındı' denir. Burada bir bez parçası ve bir çavuşun sesi.","The doors have their banners. In insurance we'd say 'now under cover'. Here it's a strip of cloth and a çavuş's voice."
D39O_PR_01,"(Rumca) Kilise! Kilisenin kapısını kırıyorlar! İçeride kadınlar, çocuklar var!","(In Greek) The church! They're breaking down the church door! There are women and children inside!"
D39O_T_03,"Çavuş nerede? Az önce buradaydı!","Where's the çavuş? He was right here!"
D39O_SA_01,"Çekil kâtip! Bütün şehir yağmada; bu kapı mı kutsal?","Out of the way, clerk! The whole city's being plundered; what makes this door holy?"
D39O_T_TEZ,"Bu mahalle teslim oldu. Sultan'ın emri var, çavuş yolda. Bekleyin.","This quarter has surrendered. There's an order from the Sultan and the çavuş is on his way. Wait."
D39O_SA_TEZ,"Kâğıt... Okuyamam ama mühür tanıdık. Biraz beklerim; sonra baltam karar verir.","Paper... I can't read it, but I know the seal. I'll wait a bit; then my axe decides."
D39O_TW_POINT,"(Rumca) Çavuş mu? Kuyunun oradan aşağı, kapıya doğru indi.","(In Greek) The çavuş? He went down past the well, towards the gate."
D39O_T_STRUGGLE_OK,"Balta bende. Kimseye sallamayacağım; sadece sende olmasın.","I've got the axe. I'm not swinging it at anyone; I just don't want you to have it."
D39O_T_STRUGGLE_BAD,"Ah. Gemici kolu. Kürek çekmek insanı güçlü yapıyormuş.","Ow. A sailor's arm. Turns out rowing makes you strong."
D39O_C_FAR,"Kâtip! Yavaş! Ben senin yaşında değilim!","Clerk! Slow down! I'm not your age!"
D39O_C_03,"Durun! Bu mahalle Sultan'ın emanetidir. Emanete el uzatan, Sultan'a el uzatır.","Stop! This quarter is in the Sultan's trust. Whoever lays a hand on a trust lays a hand on the Sultan."
D39O_T_DOOR_BROKE,"Kapı kırıldı. Ama eşikte çavuş duruyor ve kimse içeri adım atmıyor.","The door's broken. But the çavuş is standing on the threshold and nobody's taking a step inside."
D39O_SA_02,"Emir varsa emir. Bütün gece kürek çektik, şimdi eli boş dönüyoruz. ...Olsun.","If there's an order, there's an order. We rowed all night and now we go back empty-handed. ...So be it."
D39O_C_04,"Kapıya yeniçeri dikiyorum. Kâtip, içeridekilere söyle: sabaha kadar kimse girmeyecek.","I'm putting a Janissary on the door. Clerk, tell the people inside: no one comes in until morning."
D39O_T_04,"(Rumca) Kimse girmeyecek. Sabaha kadar kapıda nöbet var. Bu gece buradasınız, güvendesiniz.","(In Greek) No one will come in. There's a guard on the door until morning. Tonight you're here, and you're safe."
D39O_PR_02,"(Rumca) Tanrı seni korusun, fesli adam. Hangi taraftan olduğunu sormayacağım.","(In Greek) God keep you, man in the fez. I won't ask which side you're from."
D39O_T_05,"İyi. Ben de son zamanlarda kendime sormuyorum.","Good. I've stopped asking myself lately too."
D39O_PR_FIRE,"(Rumca) Yangın! Yan ev! Yukarıda Theodoros var, yaşlı, yürüyemez!","(In Greek) Fire! The house next door! Theodoros is upstairs, he's old, he can't walk!"
D39O_T_FIRE,"Kapı alev almış. Cumba... Cumbaya tırmanırım. Sigortada buna 'sorumluluk dışı' denir. Ben şimdi içerdeyim.","The door's on fire. The bay window... I'll climb the bay window. In insurance that's 'outside the scope of cover'. I'm inside now."
D39O_T_SMOKE,"Göremiyorum. Eğil. Öksürük... Sağ tarafta.","I can't see. Stay low. Coughing... On the right."
D39O_S_TILE,"Kiremit! Yukarı bak!","Tiles! Look up!"
D39O_SA_ROPE,"Ver ipi! Tuttum! Yavaş... yavaş... İndi!","Give me the rope! Got it! Easy... easy... He's down!"
D39O_J_ROOF,"Çatı gitti! Kâtip, kapıdan, ıslak bezle! İkinizi de aldık, sağsınız!","The roof's gone! Clerk, through the door, with a wet cloth! We've got you both, you're alive!"
D39O_PR_03,"(Rumca) Kapıyı kırmaya gelen adam ipi tuttu. Bu gece her şey ters. Tanrı da öyle istedi belki.","(In Greek) The man who came to break the door held the rope. Everything is backwards tonight. Perhaps God wanted it so."
D39O_J_01,"Kâtip, sen yazarsın: tekfura ne oldu? Biri gediğin orada düştü diyor, biri kaçtı diyor.","Clerk, you're the one who writes: what happened to the Emperor? One says he fell by the breach, another says he ran."
D39O_SA_03,"Gemiyle kaçtı diyorlar. Frenk gemileri gitti; onunki niye gitmesin?","They say he got away on a ship. The Frankish ships got away; why not his?"
D39O_J_KNOW,"Kâtip bilmezse kim bilir? ...Doğru. Kimse.","If the clerk doesn't know, who does? ...Right. Nobody."
D39O_J_WALL,"Adamlarının yanında. Öyleyse iyi bir ölüm. Allah rahmet etsin; düşmandı ama adamdı.","Beside his men. Then it was a good death. God rest him; he was the enemy, but he was a man."
D39O_J_WRITE,"'Kimse bilmiyor' diye yazılır mı? Yazılır herhalde. Dürüst olanı o.","Can you write 'nobody knows'? I suppose you can. It's the honest thing."
D39O_N_EMP,"Kaynaklar gerçekten anlaşamaz, Tolga Bey. Çoğu İmparator'un surda, savaşırken düştüğünü yazar; nasıl ve nerede, kimse kesin bilmez. Mezarı bilinmiyor. Büro bu satıra dokunmaz.","The sources truly don't agree, Mr Tolga. Most say the Emperor fell fighting on the wall; how and where, no one knows for sure. His grave is unknown. The Bureau doesn't touch that line."
D39O_N_PHOTO,"Kapıya bakın: nöbette bir yeniçeri, eşikte papaz, içeride mumlar. Bu gecenin bir kare hakkı var.","Look at the door: a Janissary on guard, the priest on the threshold, candles inside. Tonight is entitled to one frame."
D39O_N_PHOTO_OK,"Kaydedildi. Bu kare bütün şehri anlatmaz. Bu kapıyı anlatır.","Recorded. This frame doesn't tell the whole city. It tells this door."
D39O_C_END,"Sabah ben giderim, nöbet kalır. İyi tercüman çok konuşmaz derler, kâtip. Sen az konuştun, doğru konuştun.","In the morning I go, and the guard stays. They say a good interpreter doesn't talk much, clerk. You said little, and you said it right."
D39O_T_END,"Bu gece iki dilin arasında bir kapı tuttum. Şehrin geri kalanını tutamadım; kimse tutamazdı.","Tonight I held one door between two languages. I couldn't hold the rest of the city; no one could."
D39O_N_END,"Kaydedildi. 29 Mayıs gecesi, Petrion. Yarın sabah şehirde başka bir iş var. Sonra bir cuma.","Recorded. The night of 29 May, Petrion. Tomorrow morning there's other work in the city. Then a Friday."
```

---

## 4. Bölüm 31o — "Cuma" (30 Mayıs – 1 Haziran 1453)

### 4.1 Tarihî dayanak

- **Kayser'in sarayı ve beyit — çakışma:** Planlı 31o'nun ilk maddesi (Fatih harap sarayda Farsça beyti okur, **TB**)
  **zaten Bölüm 26'nın ortak giriş sahnesinde var** (`D26_F_COUPLET`, `D26_N_COUPLET`; 26o da bunu oynar,
  `chapter26o.gd` `chapter26.gd`'den türer). 31o beyti **tekrar etmez**; yalnız Nihat anar (`D31O_N_01`) ve faz 1'de aynı
  **harap saray cephesine tırmanılır** (yer bağı). OTTOMAN_STORY §3'teki planlı `UI_RECAP_27_PREV` ("beyit okudu") bu yüzden
  değişir (§5).
- **Fethin ertesi:** Sultan şehri yeniden doldurmak istedi: kaçanları evlerine çağırttı, fidyesiyle azat ettiği esirleri
  şehre yerleştirdi, sonra dışarıdan aileler getirtti (**K**; çağrı **D**'de de geçer). İlk subaşı **Süleyman Bey** (**AP**).
  Tellalın bu çağrısı bölümde bark olarak geçer. Kadri'nin kazanı ve yanık evdeki kurtarma **(kurgu)**; söndürülmemiş
  yangınlar ve çökük evler 29 Mayıs'ın sonucudur (**K**, **D**).
- **Eyüp:** Akşemseddin'in Haliç'in ucunda, surların dışında Ebû Eyyûb el-Ensârî'nin kabrini bulduğu anlatı **(rivayet)**:
  sonraki menâkıb ve Osmanlı anlatılarına dayanır; kimi anlatı bunu kuşatma sırasına koyar. Türbe ve cami 1458–59.
  Oyundaki işaretler (yıldırım yarığı çınar, pınar, eski taş) ve gün batımı sınırı **(kurgu)**; kazı ve levha rivayetin
  anlattığı gibidir.
- **İlk cuma:** 1 Haziran 1453 cuma günü Ayasofya'da ilk cuma namazı kılındı; Sultan oradaydı (**TB**, **AP**). İlk hutbeyi
  Akşemseddin'in okuduğu **(rivayet)**. İlk minare ahşaptı (sonraki kaynaklar); ilk cuma için güneybatı payandasına geçici
  ahşap bir şerefe çatılması **(kurgu)**. Ayasofya'nın ekseni kıbleye çapraz düşer; saflar bugün de binaya göre yan döner
  (gerçek). 29 Mayıs 1453 salı, 1 Haziran cuma (32o'daki "28 Mayıs pazartesi" ile tutarlı).
- **Mozaikler** o gün sökülmedi; bölüm onları olduğu gibi bırakır.

### 4.2 Yer ve sistemler

Üç aşama, 26'nın `_entry_stage` / `_aya_stage` düzeni gibi sırayla kurulur (biri kurulurken öbürü silinir):

1. **30 Mayıs, cadde:** `FallenCity` (26'nın caddesi, **gündüz**, duman yarıya inmiş; kapılardaki sancaklar yerinde;
   yağmacılar yok). Caddenin ortasında Kadri'nin kazanı (24o kazanı + ocak + ekmek sepeti). **Yanık ev:** sağdaki harap
   saray cephesinin (Tekfur Sarayı benzeri, "Sultan burada durur" yeri) bitişiğindeki "burnt" ev, kurulumu: üst kat yarı
   çökük, iki kömürleşmiş kiriş saray cephesinin üst kemer pencerelerinden evin damına uzanır (denge yolu), içeride devrilmiş
   kirişin altında bir azap ve bir çocuk, tavan közleri. Saray cephesi `enable_climb` alanına alınır (kemer kenarları,
   tuğla bantlar tutunulur; nefes).
2. **31 Mayıs, Eyüp:** `Horn.build(self, 150.0, Rect2(-40, -60, 80, 60), Vector2.ZERO, 3101)` (18'in Osmanlı kıyısı:
   Haliç'in iç ucu, bugünkü Eyüp kıyısı). Çalışma alanında çınarlar (`Nature`), yamaçta eski mezar taşları ve devrik
   sütunlar, bir pınar, bir yıldırım yarığı çınar; kazı yeri (üç katman + kökler; dipte yazılı mermer levha). İkindi →
   gün batımı (güneş gerçekten alçalır; gölgeler uzar = sayaç).
3. **1 Haziran, Ayasofya:** `ByzCity` + `Ayasofya.build`. **İskele:** güneybatı payandasının dış yüzünde iki kat ahşap
   iskele (2 `Ladder` + tuğla yüzde serbest tırmanma bölümü), tepede 2×3 m tahta platform ve üç bağ noktası. **Nef:**
   narteks'te 8 hasır rulosu, döşemede **kıble ipi** (iki çivi arasında kırmızı ip, nef eksenine ~30° sağa), hasır yerleri
   (hayalet dikdörtgen). Saflar: `Crowd` oturan sıralar, her sabitlenen hasırın üstüne bir sıra. Fatih ön safta (26'nın
   modeli, konuşmaz).
- **Yeniden kullanılan:** `player.enable_climb` (Traversal), `BalanceMeter` (kiriş, iskele platformu, iple indirme),
  zamanlı tuş (32o basamak → kiriş kaldırma / kök kesme / bağ), 21o kaz (E basılı) + 21o dumanı, `_drop_stone` (düşen
  köz ve kiremit), `Ladder`, `TespitCam`, `Lore.scatter(self, "31o")`; hasır döndürme yeni küçük kod (A/D, ±4°).
- **Süre hedefi:** 12–14 dk; durdurulan konuşma ≤ 3 dk (%22).

### 4.3 Fazlar

| Faz | Gün | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Yanık ev | 30 Mayıs sabahı | `UI_OBJ31O_HOUSE`, `UI_OBJ31O_BEAM`, `UI_OBJ31O_LIFT`, `UI_OBJ31O_LOWER` | Kadri'nin kazanının yanından geçerken (bark, durmadan) tellal ilan eder. Çığlık: yanık evde mahsur kalanlar; kapı çökük. **3 dk köz sayacı.** (a) **Harap saray cephesine tırman** (Traversal, 9 m, nefes; bir tuğla bant kopar: 0,5 sn içinde başka tutamağa geç ya da 3 m kay). (b) **Kömürleşmiş kirişte yürü** (6 m, `BalanceMeter`; kiriş iki kez çatırdar ve 10 cm çöker: ibre sıçrar). Düşüş: moloza −25 can, yeniden tırman. (c) Odaya atla: azabın bacağı devrik kirişin altında. **Kirişi kaldır**: E basılı, işaret yeşilken Space ile "hep birlikte" (azap da iter), 3 iyi vuruş; tavandan **köz yağmuru** (gölge, −15 can). (d) Çocuğu pencereden **iple indir** (E basılı + `BalanceMeter`); aşağıda Kadri tutar. Azap topallayarak kirişten geçer (Tolga önden, onu bekleyerek). | Sayaç biterse ya da can 0 → tavanın yarısı çöker, Kadri'nin adamları kapı molozunu söker ve herkesi çıkarır (yaralı ama sağ). Sayaç: kalan sn. |
| 2. Eyüp (rivayet) | 31 Mayıs ikindi | `UI_OBJ31O_SIGNS`, `UI_OBJ31O_DIG`, `UI_OBJ31O_ROOTS` | Derviş Tolga'yı Akşemseddin'e götürür. **Gün batımına 3 dk.** Akşemseddin üç işaret söyler; yamaçta ara (E: incele): **yıldırım yarığı çınar**, **pınar**, **üstünde oyma olan eski taş** (her biri yanlış adaylar arasında; yanlışta Akşemseddin başını sallar, −10 sn). Yamaç kaygan: koşarken çakıllı yerlerde kayış (0,5 sn kontrol kaybı). Üç işaret bulununca Akşemseddin üçünün arasında durur. **Kaz**: E basılı, üç katman; her katmanda **kök**: kök işareti yeşilken Space (kes); ıskada yan toprak çöker (katman yarıya). **Telefon kapalı** (çıkarılırsa Nihat'ın satırı, fotoğraf çekilmez). | Güneş batarsa Akşemseddin kendisi bulur (kazmayı alır, son katmanı o kazar); sayaç. |
| 3. Şerefe iskelesi | 1 Haziran sabahı | `UI_OBJ31O_SCAFF`, `UI_OBJ31O_LASH`, `UI_OBJ31O_WIND` | 22o/32o'nun marangozu ezan için geçici ahşap şerefeyi bağlıyor, ip lazım. **Ezana 3,5 dk.** (a) İki merdiven + 5 m tuğla payanda **serbest tırmanma** (sırtta ip kangalı: nefes %30 daha hızlı biter). (b) Platformda **üç bağ**: her birinde E basılı → ip sarılır; sarım çubuğu yeşilken Space = düğüm (3 sarım + düğüm); ıska = ip boşalır, baştan. (c) **Rüzgâr**: her ~8 sn sert esinti, platformda `BalanceMeter` (C basılı = çömel, ibre yavaşlar ama bağ duraklar). Düşüş: alt kat iskele tahtasına −25 can, oradan yeniden tırman. | Süre biterse marangoz son bağları kendisi atar (sayaç). |
| 4. Hasır ve saf | 1 Haziran öğleye doğru | `UI_OBJ31O_MAT`, `UI_OBJ31O_TURN`, `UI_OBJ31O_PHOTO`, `UI_OBJ31O_SIT` | Ezan okunuyor, cemaat kapılardan giriyor. **2,5 dk.** Narteks'ten hasır rulosu (E), nefe, hayalet yerde E: açılır, **A/D ile döndür**, ±4°'de ip yeşil, E sabitle. **8 hasır**. Büküm: içeri yürüyen cemaat serilmemiş yerlere oturmaz ama yolunu keser (aralarından geç; çarparsan rulo düşer, 2 sn). Sonra **Tespit** (kamet öncesi 60 sn; hedef: kubbenin altında çapraz saflar). Kamet: TespitCam kapanır; Tolga kapının yanına oturur (E). Kısa sessiz kesme. Çıkış: İmparator Kapısı'ndan gün ışığına. | Süre biterse dervişler kalanları serer (sayaç). |

**Animasyon ve görsel geri bildirim**
- **Faz 1:** Kadri kepçeyle kazanı karıştırır, kuyruktakilere uzatır (yürüyüş sırasında görülür); tellal caddenin öbür
  ucundan **yürüyerek** gelir. Yanık evin damından ince duman, közler kırmızı nabız gibi parlar (ışık titrer). Tırmanmada
  eller kemer kenarına ve tuğla bantlara oturur; kopan tuğla bant parçası düşer, yere çarpınca kırılır. Kiriş yürünürken
  kömür tozu ayak altında ufalanır, çatırdamada kiriş görünür biçimde 10 cm iner ve kıvılcım saçar. Kiriş kaldırma:
  Tolga ve azap iki uçtan yüklenir (zorlanma pozu), kiriş her iyi vuruşta biraz kalkar, ıskada geri düşer + toz; köz
  yağmurunda tavandan turuncu parçacıklar ve sönen kor parçaları. İple indirme: ip pencere pervazında iki sarım (görünür),
  çocuk ipin ucunda iner, Kadri kollarını açar ve yakalar (iki elle, IK). Çöküş: kirişler içe düşer, toz bulutu, ekran sarsılır.
  Bütün figüranlar cadde/moloz yüksekliğinde (26'nın `_entry_ground`'u gibi; moloz üstündekiler molozun üstüne basar).
- **Faz 2:** Akşemseddin yavaş yürür, bastonuna dayanır; durduğu yerde bir avuç toprak alıp elinde ufalar. İncelenen
  işaret yakın çekimde (çınarın yarığı, pınarın suyu taşta parlar, taşın oyması). Kaymada Tolga bir dizinin üstüne çöker,
  çakıl yamaçtan yuvarlanır. Kazıda kürek toprağa girer ve atılan toprak yanda tümsek olur (tümsek büyür); kök kesilince
  iki uç geri çekilir; çökmede yan duvardan toprak kayar. Levha: üstündeki toprak fırçayla (elle) silinir, yazı belirir
  (okunamaz Arapça satırlar; rivayetin sözü altyazıda değil). Dervişler kenarda diz çöker. Güneş alçaldıkça ışık
  turuncuya döner ve gölgeler uzar (gerçek sayaç).
- **Faz 3:** marangoz platformda çekiçle dikme çakar (döngü), Tolga gelince ipi alır; tırmanmada ip kangalı sırtta sallanır;
  bağda ip dikme ile kirişin çevresine sarılır, her sarım yeni bir halka olarak belirir, düğümde uç ilmeğe geçer ve
  çekilince gerilir; ıskada sarımlar çözülüp sarkar. Esintide iskele tahtaları gıcırdar, bayrak ve ip uçları savrulur, tahta
  tozu düşer. Düşüşte alt tahta esner ve gıcırdar. Aşağıda avluda bekleyen cemaat yukarı bakar (oturan/ayakta, avlu
  zemininde).
- **Faz 4:** hasır rulosu kolun altında; serilirken açılarak yere yayılır (ölçeklenen ağ değil, açılma animasyonu); döndürürken
  hasırın kenarı ipe yaklaşınca ip kırmızıdan yeşile döner; sabitlenen hasırın üstüne bir saf yürüyerek gelip oturur
  (döşeme y'sinde, ayakkabısız). Cemaat kapılardan akar; çarpılınca rulo düşer ve yuvarlanır. Kamette bütün saflar ayağa
  kalkar (aynı anda, hafif gecikmelerle), rükûda eğilir; ses yok, yalnız kumaş hışırtısı. Mozaikler yerinde.

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **31O.1** Hepsi zamanında | dört fazın üçünde sayaç bitmeden (yanık ev, Eyüp, iskele, hasır: ≥3/4) | `FLOW_31O_1` |
| **31O.2** Başkaları yetişti | aksi hâlde | `FLOW_31O_2` |

`--autotest[=late]` (varsayılan 31O.1; `=late`: bot kirişten bir kez düşer, iki yanlış işarete bakar, bir bağı kaçırır,
hasırları ±10° bırakır). Akış şeması (`UI_FLOW31O_TITLE`): `FLOW31O_HOUSE` → `FLOW31O_EYUP` → `FLOW31O_SCAFF` →
`FLOW31O_MATS` → `FLOW31O_FRIDAY` → {`31O.1`, `31O.2`}; altında `UI_CH31O_STATS`. Başarım önerisi: `ACH_OSM_QIBLA`
(8/8 hasır ilk denemede ±2°).

### 4.4 Konuşanlar

Koşullu: `K_LADLE`, `HR_01`, `AZ_TRAPPED`, `T_BEAM_CREAK`, `S_EMBER`, `AK_NO`, `CARP_GUST`, `CARP_KNOT_*`, `DV_OK`,
`DV_TURN` olay bark'larıdır. `D31O_K_CAVEIN` yalnız yanık ev sayacı biterse;
`D31O_AK_SUNSET` yalnız gün batarsa (yoksa `D31O_AK_04`); `D31O_CARP_LATE` yalnız iskele süresi biterse; `D31O_DV_FIXED`
yalnız hasır süresi biterse. `D31O_N_NOPHOTO` yalnız Eyüp'te telefon çıkarılırsa. `D31O_AZ_EMP` yalnız `emperor_answer`
bayrağı varsa. `D31O_N_PHOTO_OK` yalnız kare çekilince.

| Anahtar | Konuşan |
|---|---|
| `D31O_N_01` | SPK_NIHAT |
| `D31O_T_01` | SPK_TOLGA |
| `D31O_K_LADLE` | SPK_KADRI |
| `D31O_HR_01` | SPK_HERALD |
| `D31O_AZ_TRAPPED` | SPK_AZAP |
| `D31O_T_02` | SPK_TOLGA |
| `D31O_T_BEAM_CREAK` | SPK_TOLGA |
| `D31O_AZ_01` | SPK_AZAP |
| `D31O_S_EMBER` | SPK_SOLDIER |
| `D31O_T_AZ` | SPK_TOLGA |
| `D31O_AZ_02` | SPK_AZAP |
| `D31O_K_CATCH` | SPK_KADRI |
| `D31O_K_CAVEIN` | SPK_KADRI |
| `D31O_AZ_EMP` | SPK_AZAP |
| `D31O_K_01` | SPK_KADRI |
| `D31O_N_03` | SPK_NIHAT |
| `D31O_DV_01` | SPK_DERVISH |
| `D31O_AK_01` | SPK_AKSEMSEDDIN |
| `D31O_T_03` | SPK_TOLGA |
| `D31O_AK_NO` | SPK_AKSEMSEDDIN |
| `D31O_AK_03` | SPK_AKSEMSEDDIN |
| `D31O_N_NOPHOTO` | SPK_NIHAT |
| `D31O_T_STONE` | SPK_TOLGA |
| `D31O_AK_04` | SPK_AKSEMSEDDIN |
| `D31O_AK_SUNSET` | SPK_AKSEMSEDDIN |
| `D31O_N_04` | SPK_NIHAT |
| `D31O_N_05` | SPK_NIHAT |
| `D31O_CARP_01` | SPK_SOLDIER |
| `D31O_T_04` | SPK_TOLGA |
| `D31O_CARP_GUST` | SPK_SOLDIER |
| `D31O_CARP_KNOT_OK` | SPK_SOLDIER |
| `D31O_CARP_KNOT_BAD` | SPK_SOLDIER |
| `D31O_CARP_LATE` | SPK_SOLDIER |
| `D31O_T_TOP` | SPK_TOLGA |
| `D31O_DV_02` | SPK_DERVISH |
| `D31O_T_05` | SPK_TOLGA |
| `D31O_DV_OK` | SPK_DERVISH |
| `D31O_DV_TURN` | SPK_DERVISH |
| `D31O_DV_FIXED` | SPK_DERVISH |
| `D31O_N_PHOTO` | SPK_NIHAT |
| `D31O_N_PHOTO_OK` | SPK_NIHAT |
| `D31O_AZ_03` | SPK_AZAP |
| `D31O_N_KHUTBE` | SPK_NIHAT |
| `D31O_T_06` | SPK_TOLGA |
| `D31O_T_END` | SPK_TOLGA |
| `D31O_N_END` | SPK_NIHAT |

### 4.5 Metinler

```csv
UI_CH31O_TITLE,"BÖLÜM {N} — CUMA","CHAPTER {N} — FRIDAY"
UI_CH31O_SUB,"30 Mayıs – 1 Haziran 1453 · şehir, Eyüp, Ayasofya","30 May – 1 June 1453 · the city, Eyüp, Hagia Sophia"
UI_FLOW31O_TITLE,"AKIŞ ŞEMASI — BÖLÜM {N}: CUMA","FLOWCHART — CHAPTER {N}: FRIDAY"
UI_OBJ31O_HOUSE,"Yanık evde mahsur kalanlar! Saray cephesine tırman · köz: %d sn","People trapped in the burnt house! Climb the palace front · embers: %d s"
UI_OBJ31O_BEAM,"Kömürleşmiş kirişten geç: dengede kal","Cross the charred beam: keep your balance"
UI_OBJ31O_LIFT,"Kirişi kaldır: işaret yeşilken Space · %d/3","Lift the beam: Space on the green · %d/3"
UI_OBJ31O_LOWER,"Çocuğu iple indir (E basılı · ibreyi ortada tut)","Lower the child on the rope (hold E · keep the needle centred)"
UI_OBJ31O_SIGNS,"Akşemseddin'in işaretlerini bul (E: incele) · %d/3 · gün batımı: %d sn","Find Akşemseddin's signs (E: examine) · %d/3 · sunset: %d s"
UI_OBJ31O_DIG,"Kaz (E basılı) · katman %d/3","Dig (hold E) · layer %d/3"
UI_OBJ31O_ROOTS,"Kök! İşaret yeşilken Space ile kes","A root! Cut it with Space on the green"
UI_OBJ31O_SCAFF,"İpi iskeleye çıkar: tırman · ezana %d sn","Take the rope up the scaffold: climb · call to prayer in %d s"
UI_OBJ31O_LASH,"Bağı at: E basılı sar, yeşilde Space ile düğüm · %d/3","Make the lashing: hold E to wrap, Space on the green to knot · %d/3"
UI_OBJ31O_WIND,"Esinti! Dengede kal (C basılı: çömel)","A gust! Keep your balance (hold C: crouch)"
UI_OBJ31O_MAT,"Hasırları nefe taşı ve ser · %d/%d","Carry the mats into the nave and lay them · %d/%d"
UI_OBJ31O_TURN,"Hasırı kıble ipine paralel çevir (A/D), E ile sabitle","Turn the mat parallel to the qibla line (A/D), fix it with E"
UI_OBJ31O_PHOTO,"Tespit et: kubbenin altında saflar (kametten önce)","Record: the rows beneath the dome (before the call to stand)"
UI_OBJ31O_SIT,"Kapının yanına otur","Sit down by the door"
UI_PROMPT31O_LIFT,"E basılı: kirişe yüklen","Hold E: put your weight under the beam"
UI_PROMPT31O_ROPE,"E basılı: ipi sal","Hold E: pay out the rope"
UI_PROMPT31O_LOOK,"E: incele","E: examine"
UI_PROMPT31O_DIG,"E basılı: kaz","Hold E: dig"
UI_PROMPT31O_COIL,"E: ip kangalını al","E: take the coil of rope"
UI_PROMPT31O_WRAP,"E basılı: sar","Hold E: wrap"
UI_PROMPT31O_MAT,"E: hasır rulosunu al","E: take a rolled mat"
UI_PROMPT31O_LAY,"E: hasırı ser","E: unroll the mat"
UI_PROMPT31O_FIX,"E: sabitle","E: fix it in place"
UI_PROMPT31O_SIT,"E: otur","E: sit"
FLOW31O_HOUSE,"Fethin ertesi: yanık evde kurtarma","The morning after: a rescue in the burnt house"
FLOW31O_EYUP,"Eyüp'te bir kabir (rivayet)","A grave at Eyüp (tradition)"
FLOW31O_SCAFF,"Geçici şerefe","A makeshift minaret balcony"
FLOW31O_MATS,"Ayasofya'ya hasır","Mats for Hagia Sophia"
FLOW31O_FRIDAY,"İlk cuma","The first Friday"
FLOW_31O_1,"Hepsi zamanında","All in time"
FLOW_31O_2,"Başkaları yetişti","Others got there"
UI_CH31O_STATS,"Köz: %d sn kala   ·   İşaret: %d/3   ·   Bağ: %d/3   ·   Hasır: %d/%d   ·   Dosya: %d/%d sayfa","Embers: %d s to spare   ·   Signs: %d/3   ·   Lashings: %d/3   ·   Mats: %d/%d   ·   File: %d/%d pages"
SIEGE_DATE_31,"30 Mayıs – 1 Haziran 1453","30 May – 1 June 1453"
SIEGE_EV_31,"Fethin ertesi. Sultan kaçanları evlerine çağırır, şehre subaşı atar. Rivayete göre Akşemseddin Eyüp'te bir sahabenin kabrini bulur. 1 Haziran cuma, Ayasofya'da ilk cuma namazı.","The morning after the conquest. The Sultan calls those who fled back to their homes and appoints a governor. Tradition says Akşemseddin finds a Companion's grave at Eyüp. Friday 1 June: the first Friday prayer in Hagia Sophia."
SIEGE_NOTE_31O_1,"Fethin ertesi. Yanık evden bir çocuk ve bir azap çıktı, Eyüp'te bir rivayete kazma vurdum, şerefenin iplerini bağladım, hasırları kıbleye çevirdik. Ek not: bir yeniçeri su içti, sonra gitti. Yazdım. — T.","The morning after. A child and an azap came out of the burnt house, I put a pick into a tradition at Eyüp, tied the lashings of the balcony, and we turned the mats to the qibla. Addendum: a Janissary drank some water, then went. I wrote it down. — T."
SIEGE_NOTE_31O_2,"Fethin ertesi. Her yere biraz geç kaldım; başkaları yetişti. Kubbe aynı kubbe, hasırlar çapraz. Ek not: bir yeniçeri su içti, sonra gitti. Yazdım. — T.","The morning after. I was a little late everywhere; others got there. The dome is the same dome, the mats at an angle. Addendum: a Janissary drank some water, then went. I wrote it down. — T."
LORE_31O_1_T,"Şehri yeniden doldurmak","Repopulating the city"
LORE_31O_1,"Fetihten sonra Sultan şehrin boş kalmasını istemedi: kaçanları evlerine çağırttı, fidyesiyle azat ettiği esirleri şehre yerleştirdi, sonraki yıllarda Anadolu'dan ve Rumeli'den aileler getirtti. Şehrin ilk subaşısı Süleyman Bey'di.","After the conquest the Sultan did not want the city left empty: he called those who had fled back to their homes, settled captives he had ransomed in the city, and in the following years brought in families from Anatolia and the Balkans. The city's first governor was Süleyman Bey."
LORE_31O_2_T,"Eyüp (rivayet)","Eyüp (tradition)"
LORE_31O_2,"Anlatıya göre Akşemseddin, Haliç'in ucunda, surların dışında Peygamber'in sahabesi Ebû Eyyûb el-Ensârî'nin kabrini buldu. Bu bir rivayettir; çağdaş kaynaklarda geçmez. Türbe ve cami 1458–59'da yapıldı; semt bugün onun adını taşır.","According to tradition Akşemseddin found the grave of Abu Ayyub al-Ansari, a Companion of the Prophet, at the head of the Golden Horn outside the walls. It is a tradition, not found in contemporary sources. The tomb and mosque were built in 1458–59; the district still bears his name."
LORE_31O_3_T,"İlk cuma","The first Friday"
LORE_31O_3,"1 Haziran 1453 cuma günü Ayasofya'da ilk cuma namazı kılındı. Yapının ekseni kıbleye tam bakmadığı için saflar ve sonradan yapılan mihrap binaya göre yan döner; bu çapraz düzen bugün de görülür. İlk minare ahşaptı.","On Friday 1 June 1453 the first Friday prayer was held in Hagia Sophia. Because the building's axis does not face the qibla, the rows and the later mihrab are turned at an angle to it; the diagonal is still visible today. The first minaret was made of wood."
UI_RECAP_31O_PREV,"29 Mayıs gecesi Petrion'da kapılara emanet sancağı diktin, kilisenin kapısını tuttun, yanan evden bir adamı indirdin.","On the night of 29 May you put banners on Petrion's doors, held the church door and lowered a man from a burning house."
UI_RECAP_31O_NEXT,"Ayasofya'da ilk cuma kılındı. 1 Haziran, Galata: Ceneviz kasabası kapılarını açtı; Zağanos Paşa ahitnameyi okuyacak.","The first Friday prayer was held in Hagia Sophia. 1 June, Galata: the Genoese town opened its gates; Zaganos Pasha will read the charter."
```

Replikler:

```csv
D31O_N_01,"Tolga Bey, 30 Mayıs sabahı. Fethin ertesi. Sultan'ın harap sarayın önünde okuduğu beyti dün duydunuz; bu sayfada şiir yok. Söndürülmemiş közler, çökmüş evler ve bir cuma var.","Mr Tolga, the morning of 30 May. The day after the conquest. Yesterday you heard the couplet the Sultan recited before the ruined palace; there's no poetry on this page. There are embers no one put out, collapsed houses, and a Friday."
D31O_T_01,"Dün sabah bu sokak savaş alanıydı, dün akşam başka bir şey. Bu sabah bir aşçı kazan kuruyor. Tarih vardiyalı çalışıyor.","Yesterday morning this street was a battlefield, last night it was something else. This morning a cook is setting up his pot. History works in shifts."
D31O_K_LADLE,"Yamak! Sağsın! Kazan şehirde kaynıyor; kimin olduğuna bakmadan dolduruyoruz. Dur durak yok, yürü!","Kitchen boy! You're alive! The pot's boiling in the city; we fill every bowl without asking whose. No stopping, keep moving!"
D31O_HR_01,"Duyduk duymadık demeyin! Sultan'ın emridir: saklanan kim varsa evine dönsün! Şehrin subaşısı Süleyman Bey'dir; derdi olan ona gelsin!","Hear ye, and say not you did not hear! The Sultan's order: whoever is hiding, let him return to his home! The governor of the city is Süleyman Bey; whoever has a grievance, let him come to him!"
D31O_AZ_TRAPPED,"Kâtip! Buradayım! Kiriş bacağımda, yanımda bir çocuk var! Kapı çöktü, yukarıdan gel!","Clerk! In here! There's a beam on my leg and a child beside me! The door's caved in, come from above!"
D31O_T_02,"Yukarıdan. Sarayın cephesinden. Dün Sultan bu duvarın önünde şiir okudu; ben bugün üstünden geçiyorum.","From above. Up the palace front. Yesterday the Sultan recited poetry in front of this wall; today I'm climbing over it."
D31O_T_BEAM_CREAK,"Kiriş çatırdıyor. Kömür bir şey taşımak için yapılmamıştır. Ben de.","The beam is creaking. Charcoal isn't made for carrying things. Neither am I."
D31O_AZ_01,"Kâtip! Yine sen! Blakherna'da sen taşıdın, hendekte ben taşıdım; bugün sıra yine sende. Kirişin öbür ucuna geç!","Clerk! You again! At Blachernae you carried me, at the moat I carried you; today it's your turn again. Get to the other end of the beam!"
D31O_S_EMBER,"Köz! Tavan dökülüyor!","Embers! The ceiling's coming down!"
D31O_T_AZ,"Hasan'ı duydun mu?","Have you heard about Hasan?"
D31O_AZ_02,"Duydum. Su içti, sonra gitti, diyorlar. Sen mi yazdın onu? İyi etmişsin. Biz unuturuz; kâğıt unutmaz.","I heard. He drank some water, then went, they say. Did you write that? Good. We forget; paper doesn't."
D31O_K_CATCH,"Ver çocuğu! Tuttum! ...Ağlıyor. Ağlayan çocuk sağ çocuktur.","Hand down the child! Got him! ...He's crying. A crying child is a living child."
D31O_K_CAVEIN,"Tavan gitti! Kapıyı açın, molozu sökün! ...Hepsi burada. Kâtip, yüzün kapkara ama sağsın.","The ceiling's gone! Open the door, clear the rubble! ...They're all here. Clerk, your face is black, but you're alive."
D31O_AZ_EMP,"Dün gece tekfuru sormuşlar sana. Ne dedinse doğrusu odur; kimse bilmiyor.","They asked you about the Emperor last night. Whatever you said, that's the truth of it; nobody knows."
D31O_K_01,"Dün dündü. Bugün kazanın dibi görünmeyecek, o kadar. Git yüzünü yıka, kâtip; seni bir derviş arıyor.","Yesterday was yesterday. Today the bottom of the pot won't be seen, that's all. Go and wash your face, clerk; a dervish is looking for you."
D31O_N_03,"31 Mayıs. Şimdi bir rivayet sayfası, Tolga Bey: kaynak değil, anlatı. Akşemseddin'in Haliç'in ucunda, surların dışında Peygamber'in sahabesi Ebû Eyyûb el-Ensârî'nin kabrini bulduğu anlatılır. Kayda 'rivayet' diye geçecek.","31 May. Now a page of tradition, Mr Tolga: not a source, a story. It is told that at the head of the Horn, outside the walls, Akşemseddin found the grave of Abu Ayyub al-Ansari, a Companion of the Prophet. It goes in the record marked 'tradition'."
D31O_DV_01,"Kâtip! Kanlı ay gecesi çorba taşıyan sen değil miydin? Gel; şeyh genç bir göz istedi. Güneş batmadan.","Clerk! Weren't you the one carrying soup the night of the blood moon? Come; the sheikh wants young eyes. Before the sun goes down."
D31O_AK_01,"Üç işaret var, evlat: yıldırımın yardığı çınar, taştan akan su, üstünde el izi olan eski bir taş. Üçü bir yeri gösterir. Acele eden bulamaz; ama güneş de beklemez.","There are three signs, child: a plane tree split by lightning, water running from stone, and an old stone with a hand's mark on it. The three point to one place. He who hurries does not find; but neither does the sun wait."
D31O_T_03,"Hocam, ben genelde koordinatla bulurum.","Master, I usually find things by coordinates."
D31O_AK_NO,"O değil. Bak, ama gözle değil.","Not that one. Look, but not only with your eyes."
D31O_AK_03,"Burası. Kaz, ama yavaş. Yüzyıllardır bekleyeni bir saatte uyandırma.","Here. Dig, but slowly. Don't wake in an hour what has waited for centuries."
D31O_N_NOPHOTO,"Telefonu kaldırın, Tolga Bey. Rivayetin fotoğrafı olmaz; olursa rivayet olmaz.","Put the phone away, Mr Tolga. A tradition can't be photographed; if it could, it wouldn't be a tradition."
D31O_T_STONE,"Bir taş. Üstünde yazı var. Okuyamıyorum. Ama ellerim titriyor.","A stone. There's writing on it. I can't read it. But my hands are shaking."
D31O_AK_04,"Burası Ebû Eyyûb'un yeridir. Sultan'a haber verin. ...Sen de yaz, kâtip. Ama bildiğin kadarını yaz.","This is the resting place of Abu Ayyub. Send word to the Sultan. ...And you, clerk, write it down. But write only as much as you know."
D31O_AK_SUNSET,"Güneş battı. Ver kazmayı, evlat. Bazı şeyleri bulan değil, bekleyen görür. ...Burası Ebû Eyyûb'un yeridir.","The sun has set. Give me the pick, child. Some things are seen not by the one who finds but by the one who waits. ...This is the resting place of Abu Ayyub."
D31O_N_04,"Rivayet böyle anlatır. Türbe beş yıl sonra yapıldı; bugün hâlâ orada, semt de onun adını taşıyor. Dosyaya 'rivayet' damgasıyla giriyor.","That is how the tradition tells it. The tomb was built five years later; it's still there today, and the district bears his name. It goes into the file stamped 'tradition'."
D31O_N_05,"1 Haziran, cuma. Ayasofya. Dört gün önce burada son ayin vardı; bugün ilk cuma namazı kılınacak. İki sayfa, aynı kubbe.","1 June, a Friday. Hagia Sophia. Four days ago the last liturgy was held here; today the first Friday prayer. Two pages, one dome."
D31O_CARP_01,"Kâtip! Kule gecesinin merdivencisi! Yukarı ip lazım; ezana şerefe yetişmezse müezzin damda bağırır. Al kangalı, çık!","Clerk! The ladder man from the night of the tower! I need rope up here; if the balcony isn't ready for the call to prayer, the muezzin will be shouting from the roof. Take the coil and climb!"
D31O_T_04,"Bin yıllık bir binaya iple bir balkon bağlıyoruz. Belediyeden izin aldık mı diye sormayacağım.","We're tying a balcony onto a thousand-year-old building with rope. I won't ask whether we got a permit from the municipality."
D31O_CARP_GUST,"Rüzgâr! Çömel, tahtaya yapış!","Wind! Crouch, hug the planks!"
D31O_CARP_KNOT_OK,"Sıkı. Bu bağ ezanı da taşır, müezzini de.","Tight. That lashing will carry the call and the muezzin both."
D31O_CARP_KNOT_BAD,"Boşaldı! Baştan sar!","It's come loose! Wrap it again!"
D31O_CARP_LATE,"Ver, ben bağlarım. Ezan başlıyor; müezzin tahtayı değil, sesini düşünsün.","Give it here, I'll tie it. The call is starting; let the muezzin think of his voice, not the planks."
D31O_T_TOP,"Buradan bütün şehir görünüyor. Dün yanıyordu. Bugün dumanı ince.","From up here you can see the whole city. Yesterday it was burning. Today the smoke is thin."
D31O_DV_02,"Hasırları içeri taşı. Kıble şu ipin gösterdiği yer. Binanın yönü başka, kıble başka; saflar ipe bakar, duvara değil.","Carry the mats inside. The qibla is where that line points. The building faces one way and the qibla another; the rows follow the line, not the wall."
D31O_T_05,"Bin yıllık bir yapıda ilk defa bir şeyi çapraz döşüyoruz. Ve herkes kapıdan giriyor.","In a thousand-year-old building we're laying something at an angle for the first time. And everyone's coming in through the door."
D31O_DV_OK,"Oldu. İpe paralel.","That's it. Parallel to the line."
D31O_DV_TURN,"Biraz daha sağa. Duvara değil, ipe bak.","A little more to the right. Look at the line, not the wall."
D31O_DV_FIXED,"Kalanları biz serdik. Olsun; bin yıl dik durmuş bina, iki hasırla devrilmez.","We laid the rest. No matter; a building that's stood straight for a thousand years won't topple over two mats."
D31O_N_PHOTO,"Kaydı şimdi alın, Tolga Bey: saflar dolarken, kubbenin altında. Kamet başlayınca telefonu cebinize koyun.","Take the record now, Mr Tolga: the rows filling beneath the dome. When the call to stand begins, put the phone in your pocket."
D31O_N_PHOTO_OK,"Kaydedildi. Mozaikler yerinde, hasırlar çapraz. Bu kare iki sayfanın arasında duruyor.","Recorded. Mosaics in place, mats at an angle. This frame stands between two pages."
D31O_AZ_03,"Sultan geldi, ön safta. Kâtip, sen arkada, kapının yanında otur. Seni kimse kaldırmaz.","The Sultan has come; he's in the front row. Clerk, you sit at the back, by the door. Nobody will move you."
D31O_N_KHUTBE,"Rivayete göre ilk hutbeyi Akşemseddin okudu. Kaynaklar o günü ve namazı yazar; kimin okuduğu kesin değil. Telefonu cebinize koyun.","Tradition says Akşemseddin gave the first sermon. The sources record the day and the prayer; who preached is not certain. Put your phone away."
D31O_T_06,"(Tolga kapının yanında oturur. Kubbenin altında binlerce kişi aynı anda eğiliyor. Ses yok; yalnız kumaş hışırtısı.)","(Tolga sits by the door. Beneath the dome thousands of people bow at the same moment. No voices; only the rustle of cloth.)"
D31O_T_END,"Elli gün surun dışından yazdım. Bugün içindeyim ve yazacak bir şey bulamıyorum. Belki bu sayfa böyle kalmalı.","For fifty days I wrote from outside the wall. Today I'm inside and I can't find anything to write. Maybe this page should stay that way."
D31O_N_END,"Kaydedildi. 30 Mayıs – 1 Haziran, Osmanlı nüshası. Aynı gün Galata'da bir masa kuruluyor, Tolga Bey. Son sayfa orada.","Recorded. 30 May – 1 June, the Ottoman copy. The same day a table is being set up in Galata, Mr Tolga. The last page is there."
```

---

## 5. Komşu bölümlerde değişecek satırlar

`UI_RECAP_*` (hepsi ≤140 karakter, denetlendi). **Değişen** satırlar:

```csv
UI_RECAP_28O_NEXT,"Şahi surda. 18 Nisan gecesi: Mesoteichion'a ilk büyük hücum; azaplarla barikata gidiyorsun.","The great gun is at the wall. Night of 18 April: the first great assault on the Mesoteichion; you go to the stockade with the azaps."
UI_RECAP_29O_PREV,"18 Nisan gecesi zil çaldın, kalastan hendeği geçtin, barikata kanca taktın; Giustiniani'nin barikatı dayandı.","On the night of 18 April you struck a cymbal, crossed the moat on a plank and hooked the stockade; Giustiniani's stockade held."
UI_RECAP_26O_NEXT,"Şehir düştü. Takvimi geri saralım: 29 Mayıs gece 01.30, Haliç. Haliç'teki gemilerle Petrion önündeki sura.","The city has fallen. Back up the calendar: 1:30 a.m., 29 May, the Golden Horn. With the ships in the Horn, against the wall at Petrion."
UI_RECAP_31O_PREV,"29 Mayıs gecesi Petrion'da kapılara emanet sancağı diktin, kilisenin kapısını tuttun, yanan evden bir adamı indirdin.","On the night of 29 May you put banners on Petrion's doors, held the church door and lowered a man from a burning house."
UI_RECAP_31O_NEXT,"Ayasofya'da ilk cuma kılındı. 1 Haziran, Galata: Ceneviz kasabası kapılarını açtı; Zağanos Paşa ahitnameyi okuyacak.","The first Friday prayer was held in Hagia Sophia. 1 June, Galata: the Genoese town opened its gates; Zaganos Pasha will read the charter."
UI_RECAP_27_PREV,"Fethin ertesi yanık bir evden çocuk çıkardın, Eyüp'te bir rivayete kazma vurdun, Ayasofya'da ilk cumanın hasırlarını serdin.","After the conquest you got a child out of a burnt house, dug into a tradition at Eyüp and laid the mats for Hagia Sophia's first Friday."
```

Notlar:
- `UI_RECAP_31O_PREV/NEXT` strings.csv'de **zaten var** (eski metin): yukarıdakilerle değiştirilir.
- OTTOMAN_STORY §3'teki **planlı** `UI_RECAP_26O_NEXT` ve `UI_RECAP_27_PREV` (beyitli) satırları geçersiz; yerine yukarıdakiler.
- `UI_RECAP_29O_PREV` 37 eklenince değişir; A belgesinin 33–36'sı 28'in önüne girerse `UI_RECAP_28O_PREV` onların işidir.
- **Bölüm 27'nin açılışı (Osmanlı yolu):** `D27_N_01` ("Bir sayfa daha var… kuşatmanın ertesi… Şehir üç gündür Sultan'ın")
  31o'dan sonra tekrar olur. `chapter27.gd`'de `side() == "O"` iken:

```csv
D27O_N_01,"Son sayfa, Tolga Bey. Aynı gün, 1 Haziran, Galata. Siz öğlen Ayasofya'daydınız; Haliç'in bu yakasındaki Ceneviz kasabası kapılarını kendisi açtı.","The last page, Mr Tolga. The same day, 1 June, Galata. At noon you were in Hagia Sophia; the Genoese town on this side of the Horn opened its gates of its own accord."
```

- `UI_CH27_SUB` "öğle" → 31o'nun cuma namazıyla çakışmasın diye **"öğleden sonra"** (iki tarafta ortak, Bizans'a zararı yok):

```csv
UI_CH27_SUB,"1 Haziran 1453 · Galata · öğleden sonra","1 June 1453 · Galata · afternoon"
```

- **29o'nun açılışı:** `D37O_U_04` 28o→29o kopukluğunu kapatır; 29o'ya replik gerekmez.
- **31o ↔ 30o/32o azabı:** `D31O_AZ_01` 30o (Blakherna'da taşınan) ve 32o'ya (`D32O_AZ_DOWN`, hendekte Tolga'yı taşıyan)
  gönderme yapar; 32O.1 yolunda azap Tolga'yı taşımamış olabilir, satır yine doğru kalır ("sıra"dan söz eder). İstenirse
  `chapter_outcomes`'a göre `D31O_AZ_01_ALT` yazılabilir.
- **Akış haritası (OTTOMAN_STORY §1):** tabloya dört satır (37: 28'in ardına; 38 ve 39: 26'nın ardına; 31o artık planlı değil).

---

## 6. Yapım notu

| Bölüm | Yeni dosya | Değişen ortak kod | Tahmini iş |
|---|---|---|---|
| 37 | `chapter37o.gd/.tscn` | yok (20o iskeleti; 29o kanca, 28o çekiş, 26o taş, 30o taşıma, 4b denge; hendek tırmanması için `enable_climb` dikdörtgeni; `Vfx.fire` birikintisi) | 5–6 sa |
| 38 | `chapter38o.gd/.tscn` | `SeaWalls.gate()` statik yardımcı; gerekirse Horn'un su şeridi | 6–7 sa |
| 39 | `chapter39o.gd/.tscn` | `FallenCity`: `spared`, `harbor_end` seçenekleri + yanabilir ev kurulumu (cumba, iç oda, düşebilir çatı) | 6–7 sa |
| 31o | `chapter31o.gd/.tscn` | `FallenCity`'de yanık ev kurulumu (39'unkiyle ortak), Ayasofya güneybatı payandasına iskele parçası (yalnız 31o'da eklenir), hasır döndürme (~40 satır) | 7–8 sa |

Ortak: `Siege.ORDER`, `Siege._plays` listesi, `Lore.PAGES`, `TespitCam` hedef kimlikleri (`siege37/38/39/31`),
`tests/siege_route.tscn` ROUTECHECK beklentileri (Osmanlı tarafı dört bölüm uzar; `{N13}` `{N14}` `{N15}` kayar). Her
bölümün otomatik testi `VISAUDIT personhidden` ve zemin denetimiyle (figüranın ayak y'si ile zemin işlevi arasındaki fark
> 0,15 m ise `WARN_GROUND`) koşulmalı; v0.x'teki "yerden yükselen asker" ve "görünmez ip" hataları buna göre yakalanır.
