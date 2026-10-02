# Osmanlı Tarafı · Yeni Bölümler B: Kuşatmanın içi ve ertesi (37, 38, 39, 31o) (v0.1)

Bu belge OTTOMAN_STORY.md'nin §4 biçimini izler. Kuşatma öncesi bölümler (33–36) ayrı belgededir (OTTOMAN_NEW_A.md);
burada **18 Nisan 1453'ten önceki hiçbir olay yoktur**. Tasarım ilkeleri aynıdır: *tarih inatçıdır*, Tolga sonucu değil
insanları değiştirir, **Kerkoporta rivayeti kullanılmaz**, 1453'teki hiçbir karakter "Büro"yu bilmez (Tolga onlar için
"kâtip", "Urban'ın kâtibi", "reisin kâtibi"dir; Büro yalnız Nihat'ın telsizindedir).

Kaynak kısaltmaları: **R** Runciman (*The Fall of Constantinople 1453*), **K** Kritovoulos, **B** Barbaro'nun günlüğü,
**TB** Tursun Bey (*Târîh-i Ebü'l-Feth*), **AP** Aşıkpaşazade, **D** Doukas, **S** Sphrantzes. Kesin olmayan ya da sonraki
anlatılara dayanan ayrıntılar **(rivayet)**, oyunun kendi yorumu **(kurgu)** diye işaretlidir.

---

## 0. Özet: dört bölüm ve sıra

| İç id | Sahne | Tarih (1453) | Başlık | Tolga ne yapar (fiiller) | Ana olay | Sonuçlar |
|---|---|---|---|---|---|---|
| **37** | `chapter37o` (yeni) | 18 Nisan gecesi | İlk Hücum | zil ile ritim tut (RowMeter), kalası ekiple taşı + "Siper!", barikat fıçısına kanca at ve "hey-yap" ile çek, taştan kaç, tüfekçiden saklan, fotoğraf, yaralıyı kalkan-kızakla sürükle | Mesoteichion'a ilk büyük gece hücumu; Giustiniani dört saatte püskürtür | 37O.1 barikat söküldü (sabaha yine örülür) · 37O.2 barikat çizik almadı |
| **38** | `chapter38o` (yeni) | 29 Mayıs, 01.30 → öğle | Haliç Surları | kürek ritmi, teknede merdiven ayağını tut (BalanceMeter) + çatala karşı bastır, iki basamak tırman (taş), halatla tekneyi bağla, suya düşeni çek, Petrion ihtiyarlarını çevir, kaçan gemileri kovala, fotoğraf | Haliç'teki gemilerin Haliç surlarına hücumu; sabah şehir düşer, tayfa karaya dağılır; Petrion teslim olur; Hristiyan gemileri zinciri kesip kaçar | 38O.1 merdiven tuttu, tayfayı sen çektin · 38O.2 yaşlı tayfa çekti |
| **39** | `chapter39o` (yeni) | 29 Mayıs akşamı → gece | Emanet | listeye göre kapıya Sultan'ın sancağını dik (yarış), kilise kapısında tezkire göster + çavuşu bul ve getir, su ve ekmek taşı, ateş başı seçimi, fotoğraf | Teslim olan Petrion mahallesine muhafız; İmparator'un akıbeti bilinmiyor | 39O.1 altı kapı emanette, kilise kapısı dayandı · 39O.2 bazı kapılar geç kaldı |
| **31** | `chapter31o` (planlıydı; şimdi yazıldı) | 30 Mayıs – 1 Haziran | Cuma | su ve ekmek dağıt (saka döngüsü), kapı arkasındakilere tellalın sözünü doğru çevir (seçim), Akşemseddin'le yürü-dur-dinle, kaz (rivayet), Ayasofya'ya hasır taşı ve kıbleye çevir, fotoğraf | Fethin ertesi; şehri yeniden doldurma emri; Eyüp'ün kabri (rivayet); ilk cuma namazı | 31O.1 saflar kıbleye döndü · 31O.2 dervişler düzeltti |

**`Siege.ORDER` içindeki yerleri** (A belgesinin 33–36'sı kendi yerlerine ayrıca girer):

```gdscript
const ORDER := [28, 37, 29, 17, 18, 19, 20, 30, 21, 22, 23, 24, 25, 32, 26, 38, 39, 31, 27]
```

- **37** 28'in hemen ardına (6 ve 11–12 Nisan → 18 Nisan → 20 Nisan).
- **38** ve **39** 26'nın ardına. 38, 26o ile aynı gecede başlar: Nihat takvimi bilerek geri sarar (19o→20o'daki
  "Takvimi geri saralım" emsali). 26o'nun doruğu (Hasan ve sancak) bozulmasın diye 38 ondan sonra, "aynı sabahın öbür
  yüzü" olarak gelir.
- **31** zaten 39'un ardında, 27'nin önünde.
- `Siege._plays`: şehir düşmediyse oynanmayanlar listesi `[31, 27]` → **`[38, 39, 31, 27]`** (38 de şehrin düşüşüyle biter).
- `Lore.PAGES`: `"37o": 3, "38o": 3, "39o": 3, "31o": 3`.
- `Grade.finish("37o")` ve `Grade.finish("38o")` (taş, tüfekçi, ok sayaçları); 39 ve 31o'da savaş yok, karne yok.
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

Mevcut anahtarlar: `SPK_NIHAT`, `SPK_TOLGA`, `SPK_URBAN`, `SPK_AZAP`, `SPK_GIUST`, `SPK_SOLDIER`, `SPK_PATROL` (19o'nun devriye
reisi), `SPK_SAILOR`, `SPK_SAILOR2`, `SPK_TOWNSMAN`, `SPK_JANISSARY`, `SPK_KADRI`, `SPK_HERALD`, `SPK_DERVISH` (24o'nun dervişi).

---

## 1. Bölüm 37 — "İlk Hücum" (18 Nisan 1453 gecesi)

### 1.1 Tarihî dayanak

- **Tarih ve yer:** Bombardımanın bir haftasından sonra, 18 Nisan'da gün battıktan yaklaşık iki saat sonra Sultan
  Mesoteichion'a (Lykos vadisi, Aziz Romanos kapısının yakını) ilk büyük hücumu emretti (**R**, **B**).
- **Hücum:** Okçular, mızraklılar, ağır piyade ve yeniçeriler meşalelerle, davul, zil ve borularla, bağırarak geldi; dış
  surdaki yıkıkların yerine örülen **tahta-fıçı-toprak barikatı** yakmaya ve yıkmaya, merdiven dayamaya çalıştılar
  (**B**, **R**). Cephe dardı; sayı üstünlüğü işe yaramadı. Giustiniani'nin adamları **dört saat** dayandı (**R**).
- **Kayıp:** Barbaro iki yüz Türk'ün öldüğünü, savunuculardan kimsenin ölmediğini yazar (**B**; Venedikli bir kalemin
  rakamı, **R** de aktarır, kesin değil).
- **Kanca ile fıçı çekme:** barikatın fıçı ve kalaslarını kancayla çekmek **(kurgu)**: kaynaklar "yıkmaya çalıştılar" der,
  aracı söylemez. Ölüleri ve yaralıları geri taşıma gayreti kuşatma boyunca birçok kez anlatılır (**B**, **K**).
- **Gece:** 18 Nisan'da ay dolmaya yakındı (22 Mayıs tutulmasından geriye sayılır); oyun meşale ve ay ışığı kullanır.
- Bu bölüm 7 Mayıs'ın (20o, gündüz top + gece gedik) ve 12 Mayıs'ın (30o, Blakherna merdiveni) **tekrarı değildir**:
  burada top yok, merdiven yok; fiiller ritim, kalas köprü, kanca ve sürüklemedir.

### 1.2 Yer ve sistemler

- **Harita:** `LandWalls` + `SiegeField`, 20o ile aynı Lykos kesiti, **gece** (`Night.environment`, `make_day` yok).
  `intact = false` (gedik var), barikat erken aşamada: `set_repair(4)` (on aşamadan dört; 7 Mayıs'taki kadar büyük değil).
  `ditch_filled = false` (hendek henüz boş: kalas köprü bunun için). `field.bombard = false` (toplar susmuş, ağızları
  soğuyor).
- **Kalabalık:** `Assault.build_calm()` (ordu, bataryalar, surda savunanlar) + `BattleExtras.populate(..., "osm")`
  hendek kuşağında koşan ve çömelen azaplar; tam `Assault.build()` (merdivenli dalgalar) 29 Mayıs ölçeğidir, kullanılmaz.
  `Assault.volley` ok yaylımı. `SiegeField.formation` oyuncunun bölüğünün iki yanına iki sancaklı bölük.
- **Yeniden kullanılan oynanış:**
  - Faz 1: `RowMeter` (28o'nun "hey-yap" ritmi, burada zil: Space).
  - Faz 2: ekipçe taşıma (30o `_carry`, merdiven yerine 6 m kalas), "Siper!" kuralı (22o `_covered/_volley_tick`).
  - Faz 3: kanca atma (29o'daki küpeşte nişanı; hedef fıçının çemberi), çekme (28o `RowMeter`), taş düşmesi (26o
    `_drop_stone`), `Gunner.spawn` (barikatın üstünde Cenevizli tüfekçi), `TespitCam` (hedef Giustiniani).
  - Faz 4: sürükleme: 30o'nun sırtlama kodundan türetilir (yük sırtta değil, ipin ucundaki kalkanda; hız 1,4 m/sn).
- **Karakter modelleri:** Urban (28o), Giustiniani (20/26'daki model, barikatın üstünde, meşale ışığında), azap
  bölükbaşı (`BattleExtras.osm_look` azap: kırmızı keçe börk, hasır kalkan).
- **Yeni dosya yok.** `chapter37o.gd` + `scenes/chapter37o.tscn` (20o'nun sahne iskeleti).
- **Süre hedefi:** 9–11 dk; diyalog ≤ 2,5 dk.

### 1.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 0. Batarya | Gün batımı | `UI_OBJ37O_URBAN` | Urban'ın soğuyan topunun yanında kısa konuşma (Urban, Tolga'yı azaplara ödünç verir). Bölükbaşı bir **zil** uzatır. | — |
| 1. Zil | Gece, 20.30 | `UI_OBJ37O_BEAT` | Bölük siperden ölü bölgeye yürür. Mehter davulu vurur; **işaret yeşilken Space** (RowMeter, 16 vuruş, ~50 sn). İyi vuruşta bölük bir adım ilerler, kötüde duraklar (bark). Oklar yere saplanır ama bu fazda can gitmez (gerilim). | Sayaç: iyi vuruş /16. ≥10 → faz 3'te kanca ekibi bir kişi fazla (çekiş 3 yerine 2 iyi vuruşla biter). |
| 2. Kalas | Gece | `UI_OBJ37O_PLANK`, `UI_OBJ37O_COVER` | Üç azapla 6 m'lik kalası omuzla (E), 25 m taşı; yolda **bir yaylım**: "Ok!" uyarısından 2 sn içinde mantonun/hasır kalkanın 3 m yakınında değilsen −30 can. Kıyıda E: kalas hendeğin üstüne iner (kısa kesme, ekip geçer). | Can biterse yere düşülür, bölükbaşı kaldırır, kalas yeniden omuzlanır (−20 sn). Başarısızlık yok. |
| 3. Barikat | Gece yarısı | `UI_OBJ37O_HOOK`, `UI_OBJ37O_PULL`, `UI_OBJ37O_PHOTO` | Barikatta **beş fıçı** hedefi (çemberlerinde parlayan halka). (a) Nişan al, halka kadrajdayken **E**: kanca takılır (ıskada 2 sn bekle). (b) **Çek**: RowMeter "hey-yap", 3 iyi vuruş (ritim fazı ≥10 ise 2) → fıçı yuvarlanır, arkasındaki kalas düşer; her iki fıçıda `LandWalls.set_repair(aşama − 1)` ve `impact()` tozu. Tehlikeler: her 8–10 sn'de bir **taş** (gölge belirir, 1,2 sn içinde yana çekil yoksa −25 can; 26o kuralı), 12. sn'den sonra barikatın üstünde **tüfekçi** (`Gunner`, ilk bekleme 12 sn): kalkan siperin arkasına geç ya da yana kay. **Tespit:** barikatın üstünde meşale ışığında Giustiniani (fazın herhangi bir anında, 3 m içinde kalmak gerekmez). | Süre 3 dk. Sayaç: sökülen fıçı /5, yenen taş. |
| 4. Geri | 00.30 → şafak öncesi | `UI_OBJ37O_DRAG`, `UI_OBJ37O_BACK` | Geri çekilme borusu. Hendek kıyısında yaralı bir azap: hasır kalkanının ipini al (E). **W basılı** ile geri yürü (1,4 m/sn); her ~6 sn'de ip kayar (uyarı): 1 sn içinde **E** ile yeniden kavra, kaçırırsan 2 m geri kayar. Kalas köprüden geçilir; 40 m sonra ateşlerin hizası. Kısa kesme: şafak, batarya, Urban. | Başarısızlık yok; kaçan kavrayış sayısı yalnız bir bark'a döner. |

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **37O.1** Barikat yer yer söküldü (sabaha yine örüldü) | sökülen fıçı ≥ 3/5 | `FLOW_37O_1` |
| **37O.2** Barikat çizik almadı | aksi hâlde | `FLOW_37O_2` |

Tarih ikisinde de aynıdır: hücum püskürtülür. Fark yalnız Tolga'nın sonu (`D37O_T_END_OK` / `_BAD`) ve dosya notudur.
`--autotest[=lose]` (varsayılan 37O.1; `=lose`: bot zili hep geç vurur, kanca atmaz). Akış şeması (`UI_FLOW37O_TITLE`):
`FLOW37O_URBAN` → `FLOW37O_BEAT` → `FLOW37O_PLANK` → `FLOW37O_STOCKADE` → `FLOW37O_DRAG` → {`37O.1`, `37O.2`};
altında `Grade.finish("37o")` ve `UI_CH37O_STATS`. Başarım önerisi: `ACH_OSM_CYMBAL` (16/16 zil).

### 1.4 Konuşanlar

Koşullu: `D37O_AB_BEAT_*`, `D37O_AB_PULL_*`, `D37O_AB_STONE`, `D37O_S_VOLLEY`, `D37O_T_HIT`, `D37O_AB_SLIP` olay
bark'larıdır. `D37O_N_PHOTO_OK` yalnız kare çekilince. `D37O_T_END_OK` / `_BAD` sonuca göre.

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
| `D37O_T_MARCH` | SPK_TOLGA |
| `D37O_AB_03` | SPK_AZAPBASI |
| `D37O_S_VOLLEY` | SPK_SOLDIER |
| `D37O_T_PLANK` | SPK_TOLGA |
| `D37O_AB_04` | SPK_AZAPBASI |
| `D37O_T_03` | SPK_TOLGA |
| `D37O_G_01` | SPK_GIUST |
| `D37O_AB_PULL_1` | SPK_AZAPBASI |
| `D37O_AB_PULL_3` | SPK_AZAPBASI |
| `D37O_AB_STONE` | SPK_AZAPBASI |
| `D37O_T_HIT` | SPK_TOLGA |
| `D37O_N_PHOTO` | SPK_NIHAT |
| `D37O_N_PHOTO_OK` | SPK_NIHAT |
| `D37O_G_02` | SPK_GIUST |
| `D37O_S_RETREAT` | SPK_SOLDIER |
| `D37O_AB_05` | SPK_AZAPBASI |
| `D37O_AZ_01` | SPK_AZAP |
| `D37O_AB_SLIP` | SPK_AZAPBASI |
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
UI_OBJ37O_PLANK,"Kalası ekiple hendeğe taşı, kıyıda bırak (E)","Carry the plank to the moat with your squad, set it down at the edge (E)"
UI_OBJ37O_COVER,"Ok! Mantonun ya da kalkanın arkasına geç","Arrows! Get behind a mantlet or a shield"
UI_OBJ37O_HOOK,"Kancayı bir fıçının çemberine at (E) · fıçı %d/%d","Throw the hook onto a barrel's hoop (E) · barrels %d/%d"
UI_OBJ37O_PULL,"Hep birlikte çek: işaret yeşilken Space","Pull together: Space on the green"
UI_OBJ37O_PHOTO,"Tespit et: barikatın üstünde Giustiniani","Record: Giustiniani on the stockade"
UI_OBJ37O_DRAG,"Yaralının kalkanını ipinden çek (W basılı · ip kayınca E)","Drag the wounded man's shield by its rope (hold W · E when the rope slips)"
UI_OBJ37O_BACK,"Ateşlerin hizasına geri çekil","Fall back to the line of the fires"
UI_PROMPT37O_CYMBAL,"E: zili al","E: take the cymbal"
UI_PROMPT37O_PLANK,"E: kalası omuzla","E: shoulder the plank"
UI_PROMPT37O_DROP,"E: kalası hendeğin üstüne indir","E: lower the plank across the moat"
UI_PROMPT37O_HOOK,"E: kancayı at","E: throw the hook"
UI_PROMPT37O_ROPE,"E: kalkanın ipini al","E: take the shield's rope"
UI_PROMPT37O_GRIP,"E: ipi yeniden kavra!","E: grip the rope again!"
FLOW37O_URBAN,"Urban kâtibini ödünç verir","Urban lends out his clerk"
FLOW37O_BEAT,"Zil ve davulla ölü bölge","Cymbal and drum across the dead ground"
FLOW37O_PLANK,"Hendeğe kalas köprü","A plank bridge over the moat"
FLOW37O_STOCKADE,"Barikata kanca","Hooks on the stockade"
FLOW37O_DRAG,"Geri çekilme; yaralıyla birlikte","The retreat, with the wounded man"
FLOW_37O_1,"Barikat yer yer söküldü; sabaha yine örüldü","The stockade was torn in places; by morning it was rebuilt"
FLOW_37O_2,"Barikat çizik almadı","The stockade didn't take a scratch"
UI_CH37O_STATS,"Zil: %d/%d   ·   Fıçı: %d/%d   ·   Taş: %d   ·   Dosya: %d/%d sayfa","Cymbal: %d/%d   ·   Barrels: %d/%d   ·   Stones: %d   ·   File: %d/%d pages"
SIEGE_DATE_37,"18 Nisan 1453, gece","18 April 1453, night"
SIEGE_EV_37,"Mesoteichion'a ilk büyük gece hücumu: meşaleler, davul ve zil. Giustiniani'nin adamları barikatı dört saat tutar; hücum püskürtülür.","The first great night assault on the Mesoteichion: torches, drums and cymbals. Giustiniani's men hold the stockade for four hours; the assault is thrown back."
SIEGE_NOTE_37O_1,"İlk hücum. Zil çaldım, kalas taşıdım, barikattan fıçı söktüm. Sabaha hepsi yerindeydi. Hasar: gece yarısı oluştu, şafakta onarıldı. — T.","The first assault. I struck a cymbal, carried a plank, pulled barrels off the stockade. By morning they were all back. Damage: incurred at midnight, repaired by dawn. — T."
SIEGE_NOTE_37O_2,"İlk hücum. Zil çaldım, kalas taşıdım; kancalar fıçıları tutmadı. Barikat dört saat boyunca kılını kıpırdatmadı. Bir yaralıyı geri getirdik. — T.","The first assault. I struck a cymbal, carried a plank; the hooks wouldn't hold the barrels. The stockade didn't budge for four hours. We brought one wounded man back. — T."
LORE_37O_1_T,"18 Nisan hücumu","The assault of 18 April"
LORE_37O_1,"Bombardımanın bir haftasından sonra Sultan, Lykos vadisindeki yıkıklara ilk büyük hücumu gün batımından iki saat sonra başlattı. Cephe dardı; dört saat süren çarpışmada barikat geçilemedi.","After a week of bombardment the Sultan launched the first great assault on the breaches in the Lycus valley two hours after sunset. The front was narrow; in four hours of fighting the stockade could not be passed."
LORE_37O_2_T,"Barikat","The stockade"
LORE_37O_2,"Dış surun yıkılan yerlerine savunucular her gece kalas, fıçı, toprak ve çalıdan bir barikat ördü. Toprak dolu fıçılar gülleyi yumuşatıyordu. Giustiniani bu işin ustasıydı; gün boyu dövülen yer sabaha yeniden ayaktaydı.","Wherever the outer wall fell, the defenders built a stockade each night from planks, barrels, earth and brushwood. Earth-filled barrels softened the cannonballs. Giustiniani was a master of it; what was battered all day stood again by morning."
LORE_37O_3_T,"Davul ve zil","Drums and cymbals"
LORE_37O_3,"Osmanlı hücumları davul, zil, boru ve bağırışla yapılırdı. Barbaro bu gürültünün surdakileri nasıl sarstığını yazar. Ses bir silahtı: hem kendi askerine yürüyüş ritmi verir, hem karşı tarafın uykusunu alırdı.","Ottoman assaults came with drums, cymbals, trumpets and shouting. Barbaro writes how the din shook the men on the walls. Sound was a weapon: it gave one's own troops a marching rhythm and robbed the other side of sleep."
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
D37O_T_MARCH,"Ölü bölgeyi zil çalarak geçiyorum. Bunu ofiste kimseye anlatamam.","I'm crossing no man's land playing the cymbals. I can never tell anyone at the office."
D37O_AB_03,"Hendek! Kalası omuzlayın, kıyıdan kıyıya atacağız. Ok gelirse kalkanın altına, kalası bırakma!","The moat! Shoulder the plank, we lay it bank to bank. If arrows come, get under a shield, but don't drop the plank!"
D37O_S_VOLLEY,"Ok! Kalkanlar yukarı!","Arrows! Shields up!"
D37O_T_PLANK,"Kalas yerinde. Köprü dediğin bu kadar: bir tahta ve çok fazla iyimserlik.","The plank's down. That's all a bridge is: one board and far too much optimism."
D37O_AB_04,"Barikat! Kancayı fıçının çemberine geçir, sonra hep birlikte çek. Bir fıçı giderse arkasındaki kalas da gider.","The stockade! Get the hook round a barrel's hoop, then all pull together. When a barrel goes, the plank behind it goes too."
D37O_T_03,"Gece yarısı fıçı çekme yarışması. Karşı takım da çok istekli görünüyor.","A midnight barrel-pulling contest. The other team looks very keen as well."
D37O_G_01,"Tenete! Fıçıların arkasına! Çeksinler, biz yine koyarız!","Tenete! Behind the barrels! Let them pull, we'll put them back!"
D37O_AB_PULL_1,"Geldi! Bir fıçı!","It's coming! One barrel!"
D37O_AB_PULL_3,"Üç! Barikatta delik var!","Three! There's a hole in the stockade!"
D37O_AB_STONE,"Taş! Yukarı bak, yana çekil!","Stone! Look up, step aside!"
D37O_T_HIT,"Kafam... Fes kask değildir. Bu gece kask oldu.","My head... A fez is not a helmet. Tonight it was one."
D37O_N_PHOTO,"Barikatın üstündeki uzun boylu adam, Tolga Bey: Giustiniani. Bizans nüshasının kahramanı, sizinkinin baş ağrısı. Kayda alın.","The tall man on top of the stockade, Mr Tolga: Giustiniani. The hero of the Byzantine copy, the headache of yours. Record him."
D37O_N_PHOTO_OK,"Kaydedildi. Meşale ışığında, yüzü belli. Bundan sonra onu hep bu barikatta göreceksiniz.","Recorded. Torchlight, face clearly visible. From now on you'll always see him on this stockade."
D37O_G_02,"Bu gece geçemezsiniz! Ne bu gece, ne yarın!","You won't get through tonight! Not tonight, not tomorrow!"
D37O_S_RETREAT,"Geri! Borular geri çağırıyor!","Back! The trumpets are calling us back!"
D37O_AB_05,"Dört saat... Kâtip, şurada adamım yatıyor. Kalkanına yatırdık; ipinden çek. Kimseyi burada bırakmayız.","Four hours... Clerk, one of my men is lying there. We put him on his shield; pull it by the rope. We leave no one here."
D37O_AZ_01,"Kâtip... Zilini düşürmüşsün. Ben aldım. Ses kesilirse korkarız.","Clerk... You dropped your cymbal. I picked it up. If the noise stops, we get scared."
D37O_AB_SLIP,"İp kaydı! Tut onu!","The rope's slipping! Hold on to it!"
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

`D37O_U_04` 28o→29o geçişindeki boşluğu (OTTOMAN_STORY §2.1, "Topçu kâtibi bir gecede kürekçi") kapatır.

---

## 2. Bölüm 38 — "Haliç Surları" (29 Mayıs 1453, 01.30 → öğle)

### 2.1 Tarihî dayanak

- **Gece hücumu denizden de:** Son hücumda Haliç'e karadan indirilen gemiler Haliç surlarına yanaştı, merdiven dayandı;
  Hamza Bey'in donanması Marmara surlarını zorladı (**R**, **K**). Haliç surunu Venedikliler ve Rumlar tuttu; denizden
  gelen hücumlar kara surları düşene kadar başarılı olamadı (**R**).
- **Sabah:** Kara surlarında sancaklar görülünce Haliç surundaki savunucuların çoğu evlerine ve gemilere koştu; Haliç'teki
  gemilerin tayfası gemileri bırakıp kapılardan (Horaia/Plataia kapısı yöresi) şehre girdi (**R**, **B**).
- **Petrion:** Haliç kıyısındaki Petrion mahallesi gibi bazı mahalleler resmen teslim oldu; buralar Sultan'ın adamlarınca
  korundu ve yağmadan kurtuldu (**R**). Teslimin bir fustanın reisine yapılması ve Tolga'nın tercümanlığı **(kurgu)**.
- **Kaçış:** Öğleye doğru Venedik kadırgaları ve Ceneviz gemileri zincire indi; Barbaro'ya göre iki denizci baltayla
  zincirin bağlarını kesti, gemiler açığa çıktı. Haliç'teki Osmanlı gemilerinin tayfası şehre dağıldığı için peşlerine
  düşen olmadı (**B**, **R**). Barbaro bu gemilerden birindeydi.
- **Giritliler:** Haliç'in ağzına yakın üç kulede Giritli denizciler öğleden sonraya kadar teslim olmadı; Sultan
  cesaretlerine saygıyla gemileri ve mallarıyla gitmelerine izin verdi (**R**).
- **Reis:** 19o'nun devriye reisi (`SPK_PATROL`). 22 Nisan'da karadan aşırılan fustalardan birinde olması **(kurgu)**.

### 2.2 Yer ve sistemler

- **Harita:** `Horn.build(self, 62.0, Rect2(), Vector2(-20, 20), 3801)`: 18b ile aynı kurulum (Osmanlı kıyısı arkada,
  karşıda Haliç suru ve şehir). Sur parçası (x −20…20, yürüyüş yolu y 9,6) **18b'nin kendi parçası**; merdiven için bir
  `ladder_gap` ve bir **deniz kapısı** eklenir: `SeaWalls`'taki kapı kurucusu ve `open_gate` statik bir yardımcıya
  çıkarılır (`SeaWalls.gate(parent, pos)`, küçük iş). Kapının önüne dar bir taş rıhtım (SeaWalls'taki rıhtımın kesiti).
- **Tekne:** `SeaBattle.war_galley(self, ..., rowers := true)` (yürünür güverte, alçak katı küpeşte, kürekçiler; 29o).
  Küpeştede üç hasır kalkan (siper noktaları). Merdiven: `Ladder` (tilt 18°, güverteden mazgala).
- **Işık:** `Night.environment` → `SiegeField.make_dawn`'ın deniz karşılığı olarak `SeaBattle.make_day` geçişi (şafak
  turuncusu; 06.00) → öğle. Kara surlarındaki sancaklar: batıda uzak siluet (Horn'un `figures` listesiyle iki burç).
- **Kaçan gemiler:** `SeaBattle.carrack` (iki, Ceneviz) + `SeaBattle.war_galley(flag := false)` (üç, Venedik; kırmızı-altın
  bayrak) Horn'un suyunda doğuya (+x) kayar. **Gereksinim:** Horn'un su düzlemi +x yönünde en az 300 m uzanmalı; yoksa
  bölüm kendi su şeridini ekler (`CityPanorama.water_mat()` ile tek düzlem).
- **Yeniden kullanılan oynanış:** `RowMeter` (19o/29o kürek), `BalanceMeter` (4b/24o: sallanan teknede merdiven ayağı),
  zamanlı tuş (32o basamak çakma işareti → burada Space ile "bastır"), `Ladder` + 26o `_drop_stone`, 24o'nun ip tutma
  (`E basılı`, gerilim çubuğu), 17'nin suya düşeni çekme (Bizans tarafındaki kurtarma), `hud.choose` (23'ün sadık / ekleme
  tercümesi), `TespitCam`, `Assault.volley`'nin denize uyarlanmış hâli (ok suya ve güverteye saplanır).
- **Süre hedefi:** 10–12 dk; diyalog ≤ 3 dk.

### 2.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Kürek | 01.30 | `UI_OBJ38O_ROW`, `UI_OBJ38O_COVER` | Fusta Haliç'i surlara doğru geçer: **RowMeter 20 vuruş** (~60 sn). İyi vuruşta öndeki fustaya yetişilir, kötüde kürekler çarpışır (bark). İki **ok yaylımı**: "Ok!" uyarısından 2 sn içinde küpeştedeki hasır kalkanların 1,5 m yakınına çömel, yoksa −25 can. | Sayaç: iyi vuruş /20. |
| 2. Merdiven | 02.30 | `UI_OBJ38O_HOLD`, `UI_OBJ38O_BRACE`, `UI_OBJ38O_CLIMB` | Merdiven güverteden sura kalkar. (a) **Ayağını tut**: `BalanceMeter` 40 sn, tekne dalgayla sallanır, ibre ortada kalmalı (dışarı taşarsa merdiven kayar, iki tayfa geri iner, 5 sn ceza). (b) Bu sürede surdan **3 çatal itişi**: uyarıdan (yukarıda çatal belirir, `D38O_S_FORK`) sonra **1,5 sn içinde Space**: "bastır". (c) Reis: "Sen de çık." **İki basamak** tırman (`Ladder`, W); bir taş düşer (26o kuralı: W'yi bırak, geçsin). Reis geri çağırır. | Sayaç: tutulan itiş /3. Kaybetme yok (tarih: Haliç suru dayandı). |
| 3. Haber | 06.00 | `UI_OBJ38O_ROPE`, `UI_OBJ38O_PULL` | Batıdaki burçlarda sancaklar; surdakiler mazgalları bırakır, kapı açılır, tayfa karaya fırlar. Kalan: reis, yaşlı tayfa, Tolga. (a) **Halat**: rıhtım babasına yürü, E basılı tut, gerilim çubuğu kırmızıya girmeden bırak/yeniden tut (24o ip). 20 sn. (b) **Suya düşen tayfa**: tekneyle rıhtım arasında. E basılı = çek (ilerleme). Tekne her ~5 sn rıhtıma vurur (uyarı: gövde gıcırtısı, ekran kenarı): vuruş anında E basılıysa el kayar, ilerleme yarıya iner. 30 sn. Süre biterse yaşlı tayfa kancayla çeker. (c) Kısa sahne: Petrion ihtiyarları rıhtıma iner; Tolga çevirir: **seçim** (`UI_C38O_EXACT` / `UI_C38O_ADD`), `GameState.flags["petrion_word"] = "exact" / "add"` (39'un ilk çavuş repliğini seçer). | Sayaç: tayfayı kim çekti. |
| 4. Kaçan gemiler | Öğle | `UI_OBJ38O_CHASE`, `UI_OBJ38O_PHOTO` | Hristiyan gemileri doğuya, zincire iner. Reis: "Önlerini kesin!" Altı kürekçiyle **RowMeter** (hız tavanı: gemiler her durumda uzaklaşır; ritim yalnız mesafe çubuğunu yavaşlatır). **Tespit:** zincire inen Venedik kadırgaları ve Ceneviz gemileri (hedef öndeki kadırga; pencere 40 sn). Sonra Nihat zinciri ve Giritlileri anlatır (kesme: uzak burçta beyaz bayrak, kulelerden inen denizciler). | Kare kaçarsa dosyada fotoğraf yerine not. |

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **38O.1** Merdiven tuttu, düşen tayfayı sen çektin | tutulan itiş ≥ 2/3 **ve** tayfayı Tolga çekti | `FLOW_38O_1` |
| **38O.2** Yaşlı tayfa çekti | aksi hâlde | `FLOW_38O_2` |

`--autotest[=lose]` (varsayılan 38O.1; `=lose`: bot bastırmaz, kurtarmada vuruş anında bırakmaz). Akış şeması
(`UI_FLOW38O_TITLE`): `FLOW38O_ROW` → `FLOW38O_LADDER` → `FLOW38O_NEWS` → `FLOW38O_PETRION` → `FLOW38O_CHASE` →
{`38O.1`, `38O.2`}; altında `Grade.finish("38o")` ve `UI_CH38O_STATS`.

### 2.4 Konuşanlar

Koşullu: `D38O_R_ROW_*`, `D38O_S_ARROW`, `D38O_S_FORK`, `D38O_S_BRACE_*`, `D38O_R_ROW_SLOW` bark'tır. `D38O_T_PULL` +
`D38O_S_SAVED` yalnız Tolga çekerse; yoksa `D38O_S2_HOOK` + `D38O_S_SAVED`. Faz 3c'de `D38O_T_TR` ya da `D38O_T_TR_ADD`.

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
| `D38O_R_UP` | SPK_PATROL |
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
| `D38O_R_ROW_SLOW` | SPK_PATROL |
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
UI_OBJ38O_COVER,"Ok! Küpeştedeki kalkanların dibine çömel","Arrows! Crouch by the shields on the rail"
UI_OBJ38O_HOLD,"Merdivenin ayağını tut: ibreyi ortada tut","Hold the foot of the ladder: keep the needle centred"
UI_OBJ38O_BRACE,"Çatal geliyor: Space ile bastır · %d/%d","A fork is coming: brace with Space · %d/%d"
UI_OBJ38O_CLIMB,"İki basamak tırman (W) · taş düşerken dur","Climb two rungs (W) · stop while a stone falls"
UI_OBJ38O_ROPE,"Halatı rıhtımdaki babaya bağla (E basılı · kırmızıda bırak)","Make the rope fast to the bollard (hold E · let go on red)"
UI_OBJ38O_PULL,"Suya düşeni çek (E basılı · tekne vurunca bırak)","Pull out the man in the water (hold E · let go when the hull bumps)"
UI_OBJ38O_CHASE,"Kürek! Zincire inen gemilerin peşinden","Row! After the ships heading for the chain"
UI_OBJ38O_PHOTO,"Tespit et: zincire inen Hristiyan gemileri","Record: the Christian ships heading for the chain"
UI_PROMPT38O_LADDER,"E: merdivenin ayağını tut","E: hold the foot of the ladder"
UI_PROMPT38O_ROPE,"E: halatı al","E: take the rope"
UI_PROMPT38O_HAND,"E basılı: elini tut, çek","Hold E: grab his hand, pull"
UI_C38O_EXACT,"Olduğu gibi çevir.","Translate it exactly."
UI_C38O_ADD,"Bir cümle ekle: 'Kimseye zarar vermediler.'","Add one sentence: 'They have harmed no one.'"
FLOW38O_ROW,"Karanlıkta Haliç'i geçmek","Crossing the Horn in the dark"
FLOW38O_LADDER,"Tekneden sura merdiven","A ladder from the deck to the wall"
FLOW38O_NEWS,"Şafak: burçlarda sancak","Dawn: banners on the towers"
FLOW38O_PETRION,"Petrion teslim olur","Petrion surrenders"
FLOW38O_CHASE,"Zincire inen gemiler","The ships run for the chain"
FLOW_38O_1,"Merdiven tuttu; düşen tayfayı sen çektin","The ladder held; you pulled the sailor out"
FLOW_38O_2,"Düşen tayfayı yaşlı tayfa çekti","The old sailor pulled the man out"
UI_CH38O_STATS,"Kürek: %d/%d   ·   Çatal: %d/3   ·   Ok: %d   ·   Dosya: %d/%d sayfa","Oars: %d/%d   ·   Forks: %d/3   ·   Arrows: %d   ·   File: %d/%d pages"
SIEGE_DATE_38,"29 Mayıs 1453, Haliç","29 May 1453, the Golden Horn"
SIEGE_EV_38,"Haliç'teki gemiler gece surlara merdiven dayar; sur dayanır. Sabah şehir düşünce tayfa karaya dağılır, Petrion teslim olur. Öğlen Hristiyan gemileri zinciri kesip kaçar.","At night the ships in the Horn put ladders to the walls; the wall holds. When the city falls at dawn the crews scatter ashore and Petrion surrenders. At noon the Christian ships cut the boom and escape."
SIEGE_NOTE_38O_1,"Haliç. Merdiveni tuttum, sur dayandı. Sabah şehir başka yerden düştü. Bir tayfayı rıhtımla tekne arasından çektim, bir mahallenin teslimini çevirdim. Kaçan gemileri kovaladık; kovalamak için. — T.","The Horn. I held the ladder and the wall held. At dawn the city fell somewhere else. I pulled a sailor out from between the quay and the hull and translated a quarter's surrender. We chased the ships that got away; for the sake of chasing. — T."
SIEGE_NOTE_38O_2,"Haliç. Merdiven sallandı, sur dayandı. Sabah şehir başka yerden düştü. Suya düşeni yaşlı tayfa çekti; ben halatı tuttum. Kaçan gemileri yalnız fotoğrafladım. — T.","The Horn. The ladder wobbled and the wall held. At dawn the city fell somewhere else. The old sailor pulled the man out of the water; I held the rope. The ships that got away, I only photographed. — T."
LORE_38O_1_T,"Haliç'teki gemiler","The ships in the Horn"
LORE_38O_1,"22 Nisan'da karadan aşırılan gemiler Haliç surlarını kuşatmanın sonuna kadar tehdit etti; savunucular bu yüzden kara surlarından adam ayırmak zorunda kaldı. Son hücumda bu gemiler surlara merdiven dayadı, ama Haliç suru kara surları düşene kadar dayandı.","The ships hauled overland on 22 April threatened the Horn walls until the end of the siege, forcing the defenders to take men off the land walls. In the final assault they put ladders to the walls, but the Horn wall held until the land walls fell."
LORE_38O_2_T,"Giritli denizciler","The Cretan sailors"
LORE_38O_2,"Şehir düştükten sonra da Haliç'in ağzına yakın üç kulede Giritli denizciler direndi. Öğleden sonra Sultan onların gemileri ve eşyalarıyla serbestçe gitmelerine izin verdi. Runciman bunu kuşatmanın son ve en tuhaf onurlu anlarından biri sayar.","Even after the city had fallen, Cretan sailors held out in three towers near the mouth of the Horn. In the afternoon the Sultan let them sail away freely with their ships and belongings. Runciman counts it among the last and strangest honourable moments of the siege."
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
D38O_S_FORK,"Çatal! Yukarıdan çatalla itiyorlar! Bastır!","A fork! They're pushing it off with a fork! Brace!"
D38O_S_BRACE_OK,"Tuttu! Merdiven yerinde!","It held! The ladder's still up!"
D38O_S_BRACE_BAD,"Kaydı! Tut, tut!","It's slipping! Hold it, hold it!"
D38O_R_UP,"Sen de çık, kâtip! İki basamak yeter; mazgalın ağzını gör, gel. Kimse senden sur almanı beklemiyor.","You go up too, clerk! Two rungs is enough; look over the parapet and come down. Nobody expects you to take a wall."
D38O_T_UP,"Yukarıda kaynar yağ kokusu var. Ve Venedik aksanıyla bağırılan küfürler. İniyorum.","Up there it smells of boiling oil. And of swearing in a Venetian accent. I'm coming down."
D38O_R_BACK,"Geri! Burası dayanıyor. Kara tarafından haber gelmeden bu sur düşmez.","Back! This part's holding. This wall won't fall until word comes from the land side."
D38O_S2_02,"Bak! Batıda, kulelerin üstünde... Bizim sancak!","Look! To the west, on the towers... Our banner!"
D38O_N_02,"Aziz Romanos kapısı yöresi, Tolga Bey. Kara surlarında sancaklar. Sizin öbür kaydınız saatlerdir oradaydı.","The St Romanus gate, Mr Tolga. Banners on the land walls. Your other record has been there for hours."
D38O_T_03,"Hasan...","Hasan..."
D38O_S_03,"Surdakiler kaçıyor! Kapı açıldı! Herkes karaya! Şehir bizim!","They're running from the wall! The gate's open! Everyone ashore! The city is ours!"
D38O_R_04,"Durun! Gemiyi kim tutacak? ...Gittiler. Kâtip, yaşlı, siz kalın. Halatı rıhtıma bağla, akıntı bizi sura vurmasın.","Stop! Who's going to mind the ship? ...They're gone. Clerk, old man, you stay. Tie the rope to the quay, don't let the current smash us into the wall."
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
D38O_R_ROW_SLOW,"Ağır, çok ağır... Bir kürek boyu değil, bir mil geride kaldık.","Slow, far too slow... Not one oar's length behind this time, a whole mile."
D38O_N_PHOTO,"Kaydedin, Tolga Bey: Venedik kadırgaları, Ceneviz gemileri. Barbaro şu an onlardan birinde; günlüğü onunla birlikte gidiyor.","Record it, Mr Tolga: Venetian galleys, Genoese ships. Barbaro is on one of them right now; his diary is leaving with him."
D38O_N_BOOM,"Barbaro'ya göre iki denizci baltayla zincirin bağlarını kesti, gemiler açığa çıktı. Haliç'teki gemilerin tayfası şehre dağılmıştı; peşlerine düşen olmadı. Siz dışında.","According to Barbaro two sailors cut the boom's fastenings with axes and the ships got out. The crews of the ships in the Horn had scattered into the city; no one went after them. Except you."
D38O_N_CRETE,"Bir not daha: Haliç'in ağzındaki üç kulede Giritli denizciler öğleden sonraya kadar teslim olmadı. Sultan cesaretlerine saygı gösterdi, gemileriyle gitmelerine izin verdi. Kaynaklar bunu da yazar.","One more note: in three towers at the mouth of the Horn, Cretan sailors didn't surrender until the afternoon. The Sultan honoured their courage and let them leave with their ships. The sources record that too."
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
  satırı onu saklamaz.
- **Kapıdaki sancak:** Askerler girdikleri evi kapısına sancak dikerek işaretlerdi (26'da `D26_N_FLAGS`, kaynaklarda
  geçer). Burada aynı işaretin tersi: Sultan'ın sancağı + nöbetçi = "emanet" **(kurgu; teslim olan mahallede muhafız
  konması R'ye dayanır)**.
- **Kilise:** Teslim olan mahallede bir kilisenin kapısında başka gemilerden gelen ve teslimden habersiz tayfa ile çavuşun
  karşılaşması **(kurgu)**. "Emanete el uzatılmaz" 26'daki Fatih repliğinin yankısıdır (**TB**'nin anlattığı mermer
  kırma ve Sultan'ın men etmesi rivayeti 26'da).
- **İmparator:** XI. Konstantinos'un akıbeti kaynaklarda belirsizdir: çoğu surda savaşarak düştüğünü yazar (**K**, **S**
  İmparator'un öldüğünü yazar, ölümünü görmemiştir), ayrıntılar çelişir; mezarı bilinmez. Bölüm hiçbir sürümü göstermez,
  baş/beden anlatısı yoktur.
- Kerkoporta yok.

### 3.2 Yer ve sistemler

- **Harita:** `FallenCity`, iki küçük ekle (yeni dosya yok, `fallen_city.gd`'ye iki seçenek):
  - `spared := true`: evler yalnız "sooted" (çatılı, kurum lekesiz de olabilir), "burnt"/"collapsed" yok; kapılarda
    başlangıçta sancak yok (bölüm kendisi diker); yağmacı sandık taşıyanlar ve duman sütunları kurulmaz; sağdaki saray
    cephesi yerine iki ev daha (Petrion'da saray yok).
  - `harbor_end := true`: caddenin sur ucunda kara surunun iç kapısı yerine 38'deki Haliç suru parçası ve açık deniz kapısı
    (`SeaWalls.gate`, 38'de çıkarılan yardımcı). LandWalls kurulmaz.
  Caddenin öbür ucundaki yeniçeri sırası yerinde kalır (mahallenin sınırı). Soldaki kilise aynen (kapı kanatları
  **kapalı** başlar; kapıya `hp` çubuğu).
- **Işık:** Alacakaranlık (`FallenCity.mood` + `ByzCity.make_sunset` benzeri turuncu) → gece `Night.environment`;
  kapılarda `Night.torch`, kilisenin önünde `Night.campfire` (nöbetçi ateşi).
- **Kalabalık:** `Walker` (mahalle halkı; ikisi "?" işaretli, sorulunca yön gösterir), yağmacı tayfa üç `Walker` (hedef
  kapılı yol: belirli saniyelerde listedeki bir kapıya yürür), `Crowd` caddenin sonunda yeniçeriler. Uzakta şehrin
  başka semtlerinde ateş ışığı ve duman (yalnız gökte turuncu pus; ayrıntı yok).
- **Yeniden kullanılan oynanış:** E ile etkileşim + `hud.bark`, eşya gösterme (tezkire; 2 kullanım), NPC'yi takip ettirme
  (26'daki Giustiniani'yi taşıyanlara yol açma / 30o'daki ekip yürüyüşü), 22o'nun taşıma döngüsü (testi, ekmek sepeti),
  `hud.choose` (3 seçenek), `TespitCam`, `Lore.scatter(self, "39o")`.
- **Süre hedefi:** 9–11 dk; diyalog ≤ 3 dk.

### 3.3 Fazlar

| Faz | Saat | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 0. Kapı | 19.30 | `UI_OBJ39O_CAVUS` | Deniz kapısından girilir; çavuş ve Petrion ihtiyarı bekler. Kısa konuşma. Tolga'ya **6 sancak** ve ipucu listesi verilir. | — |
| 1. Sancaklar | Alacakaranlık | `UI_OBJ39O_FLAG` + ipucu satırı | Caddede ~16 kapı. HUD'da altı ipucu (`UI_HINT39O_1..6`): "Mavi kapı, üstünde balık" vb. Doğru kapıda **E**: sancak dikilir (kısa animasyon, nöbet için bir yeniçeri o kapıya yürür). Yanlış kapı: −10 sn ve çavuş bark'ı. **Üç yağmacı tayfa** 60., 120. ve 170. saniyelerde listedeki (henüz sancaksız) bir kapıya yürür; Tolga'dan önce varırsa kendi sancağını diker (`D39O_SA_FLAG`): o kapı kaybedilir. Süre 3 dk 30 sn. | Sayaç: sancak /6. |
| 2. Kilise kapısı | Akşam | `UI_OBJ39O_DOOR`, `UI_OBJ39O_FIND`, `UI_OBJ39O_LEAD` | Papaz koşarak gelir: kilisenin kapısında baltalı iki tayfa. Kapı çubuğu **100 → 0, saniyede −2** (50 sn). (a) Kapıdaki tayfaya **tezkireyi göster** (eşya gösterme, en çok 2 kez): her biri çubuğu 15 sn durdurur. (b) Çavuş caddenin iki ucundan birinde (rastgele); "?" işaretli halka **sor** (E) → ekranda yön oku. (c) Çavuşa ulaş (E), **önden yürü**: çavuş 3,2 m/sn izler; 12 m'den fazla açılırsan durur ve seslenir. | Kapı çubuğu sıfıra inmeden çavuş kapıdaysa "kapı dayandı"; yoksa kapı kırılır ama çavuş eşikte durur (içeridekiler yine korunur; tarih değişmez). |
| 3. Nöbet | Gece | `UI_OBJ39O_WATER`, `UI_OBJ39O_FIRE`, `UI_OBJ39O_PHOTO` | Kuyudan kiliseye **2 testi su**, ihtiyarın evinden **1 sepet ekmek** (22o taşıma; testi sırtta %20 yavaş). Sonra nöbet ateşinin başına otur (E): yeniçeri ve bir tayfa İmparator'u sorar → **seçim** (3). Nihat. **Tespit:** kilise kapısı: eşikte papaz, kapıda yeniçeri nöbetçi, içeride mumlar (hedef kapının ortası; pencere 60 sn). | Kare kaçarsa not. |

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **39O.1** Altı kapı emanette, kilise kapısı dayandı | sancak ≥ 5/6 **ve** kapı çubuğu > 0 | `FLOW_39O_1` |
| **39O.2** Bazı kapılar geç kaldı | aksi hâlde | `FLOW_39O_2` |

Seçim `GameState.flags["emperor_answer"] = "know" / "wall" / "write"` olarak yazılır (31o'da azabın bir bark'ı buna
bakabilir; zorunlu değil). `--autotest[=late]` (varsayılan 39O.1; `=late`: bot üç sancak diker, çavuşu ikinci uçta arar).
Akış şeması (`UI_FLOW39O_TITLE`): `FLOW39O_GATE` → `FLOW39O_FLAGS` → `FLOW39O_DOOR` → `FLOW39O_WATCH` → {`39O.1`, `39O.2`};
altında `UI_CH39O_STATS`.

### 3.4 Konuşanlar

Koşullu: `D39O_C_01_ADD` yalnız `petrion_word == "add"` (yoksa atlanır). `D39O_C_FLAG_*`, `D39O_SA_FLAG`, `D39O_C_LATE`,
`D39O_TW_POINT`, `D39O_SA_TEZ`, `D39O_C_FAR` olay bark'larıdır. `D39O_C_03` her durumda; `D39O_T_DOOR_BROKE` yalnız kapı
kırıldıysa. Faz 3'te seçime göre `D39O_J_KNOW` / `_WALL` / `_WRITE`.

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
| `D39O_C_FAR` | SPK_CAVUS |
| `D39O_C_03` | SPK_CAVUS |
| `D39O_T_DOOR_BROKE` | SPK_TOLGA |
| `D39O_SA_02` | SPK_SAILOR |
| `D39O_C_04` | SPK_CAVUS |
| `D39O_T_04` | SPK_TOLGA |
| `D39O_PR_02` | SPK_PRIEST |
| `D39O_T_05` | SPK_TOLGA |
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
UI_HINT39O_6,"Kilisenin yanındaki ev, eşikte mermer","The house beside the church, a marble threshold"
UI_OBJ39O_DOOR,"Kilisenin kapısı: tezkireyi göster, çavuşu bul","The church door: show your warrant, find the çavuş"
UI_OBJ39O_FIND,"Çavuşu bul: halka sor (E)","Find the çavuş: ask the townspeople (E)"
UI_OBJ39O_LEAD,"Çavuşu kiliseye götür (önden yürü)","Lead the çavuş to the church (walk ahead)"
UI_OBJ39O_WATER,"Kiliseye su ve ekmek taşı · %d/%d","Carry water and bread to the church · %d/%d"
UI_OBJ39O_FIRE,"Nöbet ateşinin başına otur","Sit down at the watch fire"
UI_OBJ39O_PHOTO,"Tespit et: kilisenin kapısında nöbet","Record: the watch at the church door"
UI_PROMPT39O_FLAG,"E: sancağı dik","E: plant the banner"
UI_PROMPT39O_SHOW,"E: tezkireyi göster","E: show the warrant"
UI_PROMPT39O_ASK,"E: çavuşu sor","E: ask about the çavuş"
UI_PROMPT39O_CALL,"E: 'Çavuş! Kiliseye!'","E: 'Çavuş! The church!'"
UI_PROMPT39O_JAR,"E: testiyi doldur","E: fill the jar"
UI_PROMPT39O_BREAD,"E: ekmek sepetini al","E: take the bread basket"
UI_PROMPT39O_GIVE,"E: kapıya bırak","E: leave it at the door"
UI_PROMPT39O_SIT,"E: ateşin başına otur","E: sit by the fire"
UI_C39O_KNOW,"Bilmiyorum.","I don't know."
UI_C39O_WALL,"Surda, adamlarının yanında düştü diyorlar.","They say he fell on the wall, beside his men."
UI_C39O_WRITE,"Kimse bilmiyor. Ben de öyle yazacağım.","Nobody knows. That's what I'll write."
FLOW39O_GATE,"Deniz kapısında çavuş","The çavuş at the sea gate"
FLOW39O_FLAGS,"Kapılara emanet sancağı","Banners of protection on the doors"
FLOW39O_DOOR,"Kilisenin kapısı","The church door"
FLOW39O_WATCH,"Nöbet ateşi: İmparator'a ne oldu?","The watch fire: what happened to the Emperor?"
FLOW_39O_1,"Altı kapı emanette, kilise kapısı dayandı","Six doors in trust; the church door held"
FLOW_39O_2,"Bazı kapılar geç kaldı","Some doors were too late"
UI_CH39O_STATS,"Sancak: %d/%d   ·   Kapı: %d/100   ·   Dosya: %d/%d sayfa","Banners: %d/%d   ·   Door: %d/100   ·   File: %d/%d pages"
SIEGE_DATE_39,"29 Mayıs 1453, akşam","29 May 1453, evening"
SIEGE_EV_39,"Şehrin çoğunda yağma sürer. Kendiliğinden teslim olan Petrion gibi birkaç mahalleye Sultan'ın adamları muhafız koyar. İmparator'un akıbeti bilinmiyor.","Most of the city is being plundered. A few quarters that surrendered of their own accord, such as Petrion, are given guards by the Sultan's men. The Emperor's fate is unknown."
SIEGE_NOTE_39O_1,"Petrion. Altı kapıya sancak diktik; kilisenin kapısı dayandı. Şehrin geri kalanını kimse tutamadı. Bu sayfa yalnız bir sokağı kapsar. — T.","Petrion. We put banners on six doors; the church door held. No one could hold the rest of the city. This page covers one street only. — T."
SIEGE_NOTE_39O_2,"Petrion. Bazı kapılara geç kaldım, kilisenin kapısı kırıldı; çavuş eşikte durdu, içeridekilere dokunulmadı. Kapsam: bir sokak, eksik. — T.","Petrion. I was too late for some doors, and the church door was broken; the çavuş stood on the threshold and no one inside was touched. Coverage: one street, incomplete. — T."
LORE_39O_1_T,"Teslim olan mahalleler","The quarters that surrendered"
LORE_39O_1,"Şehir düşerken Haliç kıyısındaki Petrion ve Marmara kıyısındaki Psamathia gibi birkaç mahalle direnmeden teslim oldu. Runciman'a göre bu mahallelere Sultan'ın adamları muhafız koydu; evleri ve kiliseleri yağmadan kurtuldu.","As the city fell, a few quarters, such as Petrion on the Golden Horn and Psamathia on the Marmara, surrendered without resistance. According to Runciman the Sultan's men set guards there, and their houses and churches escaped the plunder."
LORE_39O_2_T,"Kapıdaki sancak","The banner on the door"
LORE_39O_2,"Şehre giren askerler girdikleri evin kapısına küçük bir sancak dikerdi; sancaklı eve başkası girmezdi. Aynı işaret teslim olan mahallelerde tersine işledi: kapıdaki Sultan'ın işareti ve nöbetçi, o evin emanet olduğunu söylüyordu.","Soldiers who entered the city planted a small banner on the door of each house they took; no one else went into a house with a banner. In the quarters that surrendered the same sign worked the other way round: the Sultan's mark and a guard on the door said the house was held in trust."
LORE_39O_3_T,"İmparator'un sonu","The Emperor's end"
LORE_39O_3,"XI. Konstantinos'un nasıl öldüğü bilinmiyor. Kaynakların çoğu onun surda, adamlarının arasında savaşırken düştüğünü yazar; ayrıntılar birbirini tutmaz. Mezarı bilinmez.","How Constantine XI died is not known. Most sources say he fell fighting on the wall among his men; the details do not agree. His grave is unknown."
UI_RECAP_39O_PREV,"Haliç'te merdiven tuttun, suya düşen bir tayfayı çektin, Petrion'un teslimini çevirdin; Hristiyan gemileri zinciri kesti.","On the Horn you held a ladder, pulled a sailor from the water and translated Petrion's surrender; the Christian ships cut the boom."
UI_RECAP_39O_NEXT,"Petrion'da nöbet var. 30 Mayıs sabahı: yıkık sokaklarda su ve ekmek; sonra Eyüp ve Ayasofya'da ilk cuma.","Petrion is under guard. Morning, 30 May: water and bread in the ruined streets; then Eyüp, and the first Friday in Hagia Sophia."
```

Replikler:

```csv
D39O_N_01,"Akşam oldu, Tolga Bey. Şehrin çoğunda yağma sürüyor; kaynaklar bunu saklamaz, ben de saklamayacağım. Ama Petrion gibi teslim olan birkaç mahalleye Sultan'ın adamları muhafız koydu. Siz bu gece o muhafızların dilisiniz.","Evening, Mr Tolga. Most of the city is being plundered; the sources don't hide it and neither will I. But a few quarters that surrendered, like Petrion, were given guards by the Sultan's men. Tonight you are those guards' tongue."
D39O_T_01,"Bütün gün su taşıdım, kürek çektim, halat bağladım. Şimdi tercümanım. Özgeçmişime sığmıyor.","All day I've carried water, pulled an oar, tied ropes. Now I'm an interpreter. It won't fit on my CV."
D39O_C_01,"Reisin kâtibi sen misin? İki dil biliyormuşsun. Ben Sultan'ın çavuşu Davud. Elimde emir var, dilimde Rumca yok. Sen olacaksın.","You're the captain's clerk? They say you know both tongues. I am Davud, the Sultan's çavuş. I have the order in my hand and no Greek on my tongue. You'll be it."
D39O_C_01_ADD,"Reis, 'kimseye zarar vermediler' dediğini söyledi. Doğru mu, bilmem. Ama söz bir kere söylendi; artık bizim yükümüz.","The captain told me you said 'they have harmed no one'. Whether it's true I don't know. But the word has been spoken; now it's ours to carry."
D39O_C_02,"Şu sancaklar Sultan'ın. İhtiyarların listesindeki her kapıya bir tane. Sancaklı kapıya kimse girmez; girerse benimle konuşur.","These banners are the Sultan's. One on every door on the elders' list. No one enters a door with a banner; whoever does answers to me."
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
D39O_C_FAR,"Kâtip! Yavaş! Ben senin yaşında değilim!","Clerk! Slow down! I'm not your age!"
D39O_C_03,"Durun! Bu mahalle Sultan'ın emanetidir. Emanete el uzatan, Sultan'a el uzatır.","Stop! This quarter is in the Sultan's trust. Whoever lays a hand on a trust lays a hand on the Sultan."
D39O_T_DOOR_BROKE,"Kapı kırıldı. Ama eşikte çavuş duruyor ve kimse içeri adım atmıyor.","The door's broken. But the çavuş is standing on the threshold and nobody's taking a step inside."
D39O_SA_02,"Emir varsa emir. Bütün gece kürek çektik, şimdi eli boş dönüyoruz. ...Olsun.","If there's an order, there's an order. We rowed all night and now we go back empty-handed. ...So be it."
D39O_C_04,"Kapıya yeniçeri dikiyorum. Kâtip, içeridekilere söyle: sabaha kadar kimse girmeyecek.","I'm putting a Janissary on the door. Clerk, tell the people inside: no one comes in until morning."
D39O_T_04,"(Rumca) Kimse girmeyecek. Sabaha kadar kapıda nöbet var. Bu gece buradasınız, güvendesiniz.","(In Greek) No one will come in. There's a guard on the door until morning. Tonight you're here, and you're safe."
D39O_PR_02,"(Rumca) Tanrı seni korusun, fesli adam. Hangi taraftan olduğunu sormayacağım.","(In Greek) God keep you, man in the fez. I won't ask which side you're from."
D39O_T_05,"İyi. Ben de son zamanlarda kendime sormuyorum.","Good. I've stopped asking myself lately too."
D39O_PR_03,"(Rumca) Su... Ekmek... İçeride bir çocuk iki gündür ağlamadı bile. Şimdi ağlıyor. Bu iyi bir işaret.","(In Greek) Water... Bread... There's a child inside who hasn't even cried for two days. Now he's crying. That's a good sign."
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
D39O_N_END,"Kaydedildi. 29 Mayıs gecesi, Petrion. Yarın sabah şehirde başka bir iş var: su, ekmek ve bir cuma.","Recorded. The night of 29 May, Petrion. Tomorrow morning there's other work in the city: water, bread, and a Friday."
```

---

## 4. Bölüm 31o — "Cuma" (30 Mayıs – 1 Haziran 1453)

### 4.1 Tarihî dayanak

- **Kayser'in sarayı ve beyit — çakışma uyarısı:** Planlı 31o'nun ilk maddesi (Fatih harap sarayda Farsça beyti okur,
  **TB**) **zaten Bölüm 26'nın ortak giriş sahnesinde var** (`D26_F_COUPLET`, `D26_N_COUPLET`; 26o da bunu oynar,
  `chapter26o.gd` `chapter26.gd`'den türer). 31o beyti **tekrar etmez**; Nihat bir cümleyle anar (`D31O_N_01`).
  OTTOMAN_STORY §3'teki planlı `UI_RECAP_27_PREV` ("beyit okudu") bu yüzden aşağıdaki satırla değişir.
- **Fethin ertesi:** Sultan şehri yeniden doldurmak istedi: kaçanları evlerine çağırttı, esirlerin bir kısmını fidyesiyle
  azat edip şehre yerleştirdi, sonra dışarıdan aileler getirtti (**K**; çağrı **D**'de de geçer, sonuçları üzerine kaynaklar
  ayrışır). Şehrin ilk subaşısı **Süleyman Bey** (Karıştıran) oldu (**AP**). Ordu mutfağının şehre taşınması ve Kadri'nin
  kazanı **(kurgu)**.
- **Eyüp:** Akşemseddin'in Haliç'in ucunda, surların dışında Ebû Eyyûb el-Ensârî'nin kabrini bulduğu anlatısı
  **(rivayet)**: sonraki menâkıb ve Osmanlı kaynaklarına dayanır; kimi anlatı bunu kuşatma sırasına koyar. Türbe ve cami
  1458–59'da yapıldı. Kazı, taş ve üstündeki yazı oyunda rivayetin anlattığı gibidir ve öyle işaretlenir.
- **İlk cuma:** 1 Haziran 1453 cuma günü Ayasofya'da ilk cuma namazı kılındı; Sultan oradaydı (**TB**, **AP**). İlk hutbeyi
  Akşemseddin'in okuduğu **(rivayet)**. İlk minare ahşaptı (sonraki kaynaklar). Ayasofya'nın ekseni kıbleye çapraz
  düşer; saflar ve mihrap bugün de binaya göre yan döner (yapının gerçek bir özelliği; ilk cumada hasırların ipe göre
  serilmesi **(kurgu)**). Tarih: 29 Mayıs 1453 salıdır, 1 Haziran cuma (32o'daki "28 Mayıs pazartesi" ile tutarlı).
- **Mozaikler:** O gün sökülmediler; birçoğu yüzyıllarca görünür kaldı. Bölüm onları olduğu gibi bırakır.

### 4.2 Yer ve sistemler

Üç sahne, 26'daki `_entry_stage` / `_aya_stage` düzeni gibi aşama aşama kurulur (bir aşama kurulurken öbürü silinir):

1. **30 Mayıs, cadde:** `FallenCity` (26'nın caddesi, **gündüz**, `FallenCity.mood` dumanı yarıya indirilmiş; kapılardaki
   sancaklar yerinde; yağmacı sandık taşıyanlar yok, `spared := false`). Caddenin ortasına Kadri'nin kazanı (CampDay
   mutfağının kazan + ocak + ekmek sepeti parçaları, `CampDay` statik yardımcılarıyla ya da 24o'nun kazanı). Kuyu ve
   çeşme (26o'daki su fıçısı noktası gibi). Duvar dibinde oturan altı küme (yaralı askerler, esir aileler, yaşlı adam):
   `Person` + `BattleExtras` yatanlar **değil**, oturan pozlar. `Walker` halk. Üç saklanma kapısı (pencerede gölge).
2. **31 Mayıs, Eyüp:** `Horn.build(self, 150.0, Rect2(-40, -60, 80, 60), Vector2.ZERO, 3101)`: 18'in Osmanlı kıyısı
   (Haliç'in iç ucu, bugünkü Eyüp kıyısı). Çalışma alanında çınarlar (`Nature`), üç durak işareti (görünmez), kazı yeri
   (toprak tümsek; kazıldıkça üç katman iner; dipte yazılı mermer levha). `Night` yok; ikindi ışığı.
3. **1 Haziran, Ayasofya:** `ByzCity` + `Ayasofya.build` (26'nın aynısı). Narteks'te hasır yığını (8 rulo), nefin
   döşemesinde **kıble ipi** (iki çivi arası gergin kırmızı ip, nef eksenine göre **~30° sağa**), hasır yerleri (hayalet
   dikdörtgenler). Dua edenler: `Crowd` oturan saflar (her serilen hasırın üstüne bir sıra). Fatih ön safta (26'daki
   model, atsız; konuşmaz).
- **Yeniden kullanılan oynanış:** 26o saka döngüsü (`_pick("water")`, ver), 22o taşıma (ekmek sepeti, hasır rulosu: sırtta
  %25 yavaş), `hud.choose` (23'ün sadık tercüme fikri), "yürü-dur-bekle" (24o'nun ateş başında bekleme sayacı; hareket
  edersen sıfırlanır), 21o'nun kaz (E basılı, üç katman), hasır döndürme (yeni küçük kod: A/D ile 0,5°/kare döndür, ±4°
  içinde ip yeşil), `TespitCam`, `Lore.scatter(self, "31o")` (birinci aşamada).
- **Süre hedefi:** 11–13 dk; diyalog ≤ 3,5 dk.

### 4.3 Fazlar

| Faz | Gün | Hedefler | Oynanış | Kazanma / kaybetme |
|---|---|---|---|---|
| 1. Su ve ekmek | 30 Mayıs sabahı | `UI_OBJ31O_WATER`, `UI_OBJ31O_BREAD` | Kadri'nin kazanı. **Altı kümeye** su (kuyudan testi, E: ver) ve ekmek (sepetten 1, E: ver): toplam **8 teslim** (her kümeye su, ikisine ayrıca ekmek), 3 dk. Aynı kümeye iki kez su verilmez (bark). Kümelerden biri 32o'nun azabı: kolu sarılı, konuşur (Hasan anılır). | Sayaç: teslim /8. |
| 2. Tellal | 30 Mayıs öğle | `UI_OBJ31O_DOORS` | Tellal geçer, ilan eder. Nihat: üç kapının ardında saklananlar var. Her kapıda E → **seçim** (3): tellalın sözünü olduğu gibi çevir / söz ver / tehdit et. Doğru tercüme → kapı açılır, aile eşiğe çıkar (Walker, evin önünde durur); söz → kapı aralanır, Nihat uyarır (Paradoks hafifçe titrer, 23.2 gibi); tehdit → kapı kapanır, sürgü sesi. | Sayaç: doğru çeviri /3. |
| 3. Eyüp (rivayet) | 31 Mayıs ikindi | `UI_OBJ31O_FOLLOW`, `UI_OBJ31O_WAIT`, `UI_OBJ31O_DIG` | Derviş (24o'nun dervişi) Tolga'yı Akşemseddin'e götürür. Akşemseddin çınarların arasında yürür, **üç durakta durur**: Tolga 3 m içinde **hareket etmeden 6 sn** bekler (çubuk; kıpırdarsan sıfırlanır, Akşemseddin bekler). Üçüncü durakta "Burası." **Kaz**: E basılı, üç katman (her biri 4 sn), son katmanda yazılı levha. **Fotoğraf yok:** TespitCam bu aşamada kapalı (telefonu çıkarınca Nihat'ın satırı). | Başarısızlık yok. |
| 4. Hasır ve saf | 1 Haziran sabahı → öğle | `UI_OBJ31O_MAT`, `UI_OBJ31O_TURN`, `UI_OBJ31O_PHOTO`, `UI_OBJ31O_SIT` | Narteks'teki yığından **hasır rulosu** al (E), nefe taşı, hayalet yerine bırak (E), **A/D ile döndür**: kıble ipine paralel (±4°) olunca ip yeşil, **E ile sabitle**. **8 hasır**, 4 dk (azap ve derviş yanda iki hasır daha serer; süre dolarsa kalanları dervişler serer). Sonra saflar dolar: **Tespit** (kamet öncesi 60 sn; hedef: kubbenin altındaki çapraz saflar). Kamet: TespitCam kapanır; Tolga kapının yanına oturur (E), kısa kesme (sessiz, yalnız kumaş hışırtısı ve hutbe başlangıcı, sözsüz). Çıkış: İmparator Kapısı'ndan gün ışığına. | Kare kaçarsa not. |

**Sonuçlar**

| Kod | Koşul | Şema |
|---|---|---|
| **31O.1** Saflar kıbleye döndü | sabitlenen hasır ≥ 7/8 **ve** teslim ≥ 6/8 | `FLOW_31O_1` |
| **31O.2** Saflar biraz yamuk; dervişler düzeltti | aksi hâlde | `FLOW_31O_2` |

`--autotest[=late]` (varsayılan 31O.1; `=late`: bot 4 teslim yapar, hasırları ±10° bırakır). Akış şeması
(`UI_FLOW31O_TITLE`): `FLOW31O_WATER` → `FLOW31O_HERALD` → `FLOW31O_EYUP` → `FLOW31O_MATS` → `FLOW31O_FRIDAY` →
{`31O.1`, `31O.2`}; altında `UI_CH31O_STATS`. Başarım önerisi: `ACH_OSM_QIBLA` (8/8 hasır ilk denemede ±2°).

### 4.4 Konuşanlar

Koşullu: `D31O_K_BREAD`, `D31O_K_TWICE`, `D31O_TW_WATER`, `D31O_S_WATER` olay bark'larıdır. Faz 2'de her kapıda seçime göre
`D31O_TW_TRUE` / `D31O_TW_PROMISE` (+ `D31O_N_PROMISE`, yalnız ilk seferde) / `D31O_TW_THREAT`. `D31O_AZ_EMP` yalnız 39'da
bir seçim yapıldıysa (bayrak `emperor_answer` var). `D31O_N_NOPHOTO` yalnız Eyüp'te telefon çıkarılırsa. `D31O_DV_OK`,
`D31O_DV_TURN`, `D31O_AZ_MAT` hasır bark'ları. `D31O_N_PHOTO_OK` yalnız kare çekilince. `D31O_DV_FIXED` yalnız 31O.2'de.

| Anahtar | Konuşan |
|---|---|
| `D31O_N_01` | SPK_NIHAT |
| `D31O_T_01` | SPK_TOLGA |
| `D31O_K_01` | SPK_KADRI |
| `D31O_T_K1` | SPK_TOLGA |
| `D31O_K_02` | SPK_KADRI |
| `D31O_K_BREAD` | SPK_KADRI |
| `D31O_K_TWICE` | SPK_KADRI |
| `D31O_TW_WATER` | SPK_TOWNSMAN |
| `D31O_S_WATER` | SPK_SOLDIER |
| `D31O_AZ_01` | SPK_AZAP |
| `D31O_T_AZ` | SPK_TOLGA |
| `D31O_AZ_02` | SPK_AZAP |
| `D31O_AZ_EMP` | SPK_AZAP |
| `D31O_HR_01` | SPK_HERALD |
| `D31O_N_02` | SPK_NIHAT |
| `D31O_T_02` | SPK_TOLGA |
| `D31O_TW_TRUE` | SPK_TOWNSMAN |
| `D31O_TW_PROMISE` | SPK_TOWNSMAN |
| `D31O_N_PROMISE` | SPK_NIHAT |
| `D31O_TW_THREAT` | SPK_TOWNSMAN |
| `D31O_T_DOORS` | SPK_TOLGA |
| `D31O_N_03` | SPK_NIHAT |
| `D31O_DV_01` | SPK_DERVISH |
| `D31O_AK_01` | SPK_AKSEMSEDDIN |
| `D31O_T_03` | SPK_TOLGA |
| `D31O_AK_02` | SPK_AKSEMSEDDIN |
| `D31O_AK_03` | SPK_AKSEMSEDDIN |
| `D31O_N_NOPHOTO` | SPK_NIHAT |
| `D31O_T_STONE` | SPK_TOLGA |
| `D31O_AK_04` | SPK_AKSEMSEDDIN |
| `D31O_N_04` | SPK_NIHAT |
| `D31O_N_05` | SPK_NIHAT |
| `D31O_DV_02` | SPK_DERVISH |
| `D31O_T_05` | SPK_TOLGA |
| `D31O_DV_OK` | SPK_DERVISH |
| `D31O_DV_TURN` | SPK_DERVISH |
| `D31O_AZ_MAT` | SPK_AZAP |
| `D31O_DV_FIXED` | SPK_DERVISH |
| `D31O_T_DOME` | SPK_TOLGA |
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
UI_OBJ31O_WATER,"Duvar dibindekilere su taşı · %d/%d","Carry water to the people by the walls · %d/%d"
UI_OBJ31O_BREAD,"Kadri'nin sepetinden ekmek götür","Take bread from Kadri's basket"
UI_OBJ31O_DOORS,"Kapıların ardındakilere tellalın sözünü çevir · %d/%d","Translate the herald's words to those behind the doors · %d/%d"
UI_OBJ31O_FOLLOW,"Akşemseddin'in ardından yürü","Walk behind Akşemseddin"
UI_OBJ31O_WAIT,"Yanında dur ve bekle (kıpırdama)","Stand beside him and wait (don't move)"
UI_OBJ31O_DIG,"Kaz (E basılı) · yavaş","Dig (hold E) · slowly"
UI_OBJ31O_MAT,"Hasırları nefe taşı ve ser · %d/%d","Carry the mats into the nave and lay them · %d/%d"
UI_OBJ31O_TURN,"Hasırı kıble ipine paralel çevir (A/D), E ile sabitle","Turn the mat parallel to the qibla line (A/D), fix it with E"
UI_OBJ31O_PHOTO,"Tespit et: kubbenin altında saflar (kametten önce)","Record: the rows beneath the dome (before the call to stand)"
UI_OBJ31O_SIT,"Kapının yanına otur","Sit down by the door"
UI_PROMPT31O_JAR,"E: testiyi doldur","E: fill the jar"
UI_PROMPT31O_GIVE,"E: su ver","E: give water"
UI_PROMPT31O_BREAD,"E: ekmek ver","E: give bread"
UI_PROMPT31O_DOOR,"E: kapıya seslen","E: call through the door"
UI_PROMPT31O_DIG,"E basılı: kaz","Hold E: dig"
UI_PROMPT31O_MAT,"E: hasır rulosunu al","E: take a rolled mat"
UI_PROMPT31O_LAY,"E: hasırı ser","E: unroll the mat"
UI_PROMPT31O_FIX,"E: sabitle","E: fix it in place"
UI_PROMPT31O_SIT,"E: otur","E: sit"
UI_C31O_TRUE,"Tellalın sözünü çevir: 'Evinize dönebilirsiniz; derdiniz varsa subaşıya gidin.'","Translate the herald: 'You may return to your homes; take any grievance to the governor.'"
UI_C31O_PROMISE,"Söz ver: 'Size hiçbir şey olmayacak.'","Make a promise: 'Nothing will happen to you.'"
UI_C31O_THREAT,"'Çıkın, yoksa askerler gelir.'","'Come out, or the soldiers will come.'"
FLOW31O_WATER,"Fethin ertesi: su ve ekmek","The morning after: water and bread"
FLOW31O_HERALD,"Tellal: evlerinize dönün","The herald: return to your homes"
FLOW31O_EYUP,"Eyüp'te bir kabir (rivayet)","A grave at Eyüp (tradition)"
FLOW31O_MATS,"Ayasofya'ya hasır","Mats for Hagia Sophia"
FLOW31O_FRIDAY,"İlk cuma","The first Friday"
FLOW_31O_1,"Saflar kıbleye döndü","The rows turned towards the qibla"
FLOW_31O_2,"Saflar biraz yamuk; dervişler düzeltti","The rows a little crooked; the dervishes straightened them"
UI_CH31O_STATS,"Su ve ekmek: %d/%d   ·   Kapı: %d/%d   ·   Hasır: %d/%d   ·   Dosya: %d/%d sayfa","Water and bread: %d/%d   ·   Doors: %d/%d   ·   Mats: %d/%d   ·   File: %d/%d pages"
SIEGE_DATE_31,"30 Mayıs – 1 Haziran 1453","30 May – 1 June 1453"
SIEGE_EV_31,"Fethin ertesi. Sultan kaçanları evlerine çağırır, şehre subaşı atar. Rivayete göre Akşemseddin Eyüp'te bir sahabenin kabrini bulur. 1 Haziran cuma, Ayasofya'da ilk cuma namazı.","The morning after the conquest. The Sultan calls those who fled back to their homes and appoints a governor. Tradition says Akşemseddin finds a Companion's grave at Eyüp. Friday 1 June: the first Friday prayer in Hagia Sophia."
SIEGE_NOTE_31O_1,"Fethin ertesi. Su ve ekmek dağıttık, kapılara tellalın sözünü çevirdim, Eyüp'te bir rivayete kazma vurdum, Ayasofya'da hasırları kıbleye çevirdik. Ek not: bir yeniçeri su içti, sonra gitti. Yazdım. — T.","The morning after. We handed out water and bread, I translated the herald at the doors, I put a pick into a tradition at Eyüp, and in Hagia Sophia we turned the mats to the qibla. Addendum: a Janissary drank some water, then went. I wrote it down. — T."
SIEGE_NOTE_31O_2,"Fethin ertesi. Su ve ekmek yetmedi, hasırlar yamuk kaldı, dervişler düzeltti. Kubbe aynı kubbe. Ek not: bir yeniçeri su içti, sonra gitti. Yazdım. — T.","The morning after. There wasn't enough water and bread; the mats were crooked and the dervishes straightened them. The dome is the same dome. Addendum: a Janissary drank some water, then went. I wrote it down. — T."
LORE_31O_1_T,"Şehri yeniden doldurmak","Repopulating the city"
LORE_31O_1,"Fetihten sonra Sultan şehrin boş kalmasını istemedi: kaçanları evlerine çağırttı, fidyesiyle azat ettiği esirleri şehre yerleştirdi, sonraki yıllarda Anadolu'dan ve Rumeli'den aileler getirtti. Şehrin ilk subaşısı Süleyman Bey'di.","After the conquest the Sultan did not want the city left empty: he called those who had fled back to their homes, settled captives he had ransomed in the city, and in the following years brought in families from Anatolia and the Balkans. The city's first governor was Süleyman Bey."
LORE_31O_2_T,"Eyüp (rivayet)","Eyüp (tradition)"
LORE_31O_2,"Anlatıya göre Akşemseddin, Haliç'in ucunda, surların dışında Peygamber'in sahabesi Ebû Eyyûb el-Ensârî'nin kabrini buldu. Bu bir rivayettir; çağdaş kaynaklarda geçmez. Türbe ve cami 1458–59'da yapıldı ve semt bugün onun adını taşır.","According to tradition Akşemseddin found the grave of Abu Ayyub al-Ansari, a Companion of the Prophet, at the head of the Golden Horn outside the walls. It is a tradition, not found in contemporary sources. The tomb and mosque were built in 1458–59, and the district still bears his name."
LORE_31O_3_T,"İlk cuma","The first Friday"
LORE_31O_3,"1 Haziran 1453 cuma günü Ayasofya'da ilk cuma namazı kılındı. Yapının ekseni kıbleye tam bakmadığı için saflar ve sonradan yapılan mihrap binaya göre yan döner; bu çapraz düzen bugün de görülür. İlk minare ahşaptı.","On Friday 1 June 1453 the first Friday prayer was held in Hagia Sophia. Because the building's axis does not face the qibla, the rows and the later mihrab are turned at an angle to it; the diagonal is still visible today. The first minaret was made of wood."
UI_RECAP_31O_PREV,"29 Mayıs gecesi Petrion'da kapılara emanet sancağı diktin, kilisenin kapısına çavuşu yetiştirdin.","On the night of 29 May you planted banners of protection on Petrion's doors and got the çavuş to the church door in time."
UI_RECAP_31O_NEXT,"Ayasofya'da ilk cuma kılındı. 1 Haziran, Galata: Ceneviz kasabası kapılarını açtı; Zağanos Paşa ahitnameyi okuyacak.","The first Friday prayer was held in Hagia Sophia. 1 June, Galata: the Genoese town opened its gates; Zaganos Pasha will read the charter."
```

Replikler:

```csv
D31O_N_01,"Tolga Bey, 30 Mayıs sabahı. Fethin ertesi. Sultan'ın harap sarayın önünde okuduğu beyti dün duydunuz; bu sayfada şiir yok. Su, ekmek ve kayıt var. Bir de cuma.","Mr Tolga, the morning of 30 May. The day after the conquest. Yesterday you heard the couplet the Sultan recited before the ruined palace; there's no poetry on this page. There's water, bread and paperwork. And a Friday."
D31O_T_01,"Dün sabah bu sokak savaş alanıydı, dün akşam başka bir şey. Bu sabah bir aşçı kazan kuruyor. Tarih vardiyalı çalışıyor.","Yesterday morning this street was a battlefield, last night it was something else. This morning a cook is setting up his pot. History works in shifts."
D31O_K_01,"Yamak! Sağsın! Mutfağı şehre taşıdık; ordugâhın kazanı burada kaynıyor. Su kuyudan, ekmek benden. Kimin olduğuna bakma, aç olana ver.","Kitchen boy! You're alive! We've moved the kitchen into the city; the camp's pot is boiling here. Water from the well, bread from me. Don't ask whose they are; give to whoever's hungry."
D31O_T_K1,"Aşçıbaşı, bunu bir hafta önce söyleseydiniz inanmazdım.","Head cook, if you'd said that a week ago I wouldn't have believed you."
D31O_K_02,"Bir hafta önce bir haftaydı. Bugün kazanın dibi görünmeyecek, o kadar.","A week ago was a week ago. Today the bottom of the pot won't be seen, that's all."
D31O_K_BREAD,"Bir ekmek daha! Duvar dibindekiler önce.","Another loaf! The ones by the wall first."
D31O_K_TWICE,"Onlar içti, kâtip. Ötekiler bekliyor.","They've had theirs, clerk. The others are waiting."
D31O_TW_WATER,"(Rumca) Teşekkür ederim. ...Önce çocuğa.","(In Greek) Thank you. ...The child first."
D31O_S_WATER,"Allah razı olsun saka. Dün de su taşıyan sen miydin?","God bless you, water carrier. Was it you carrying water yesterday too?"
D31O_AZ_01,"Kâtip! Sağ mısın? Ben de sağım; kol bir yana, can bir yana. Hasan... Hasan'ı duydun mu?","Clerk! You're alive? So am I; the arm's one thing, life's another. Hasan... have you heard about Hasan?"
D31O_T_AZ,"Duydum. Su içti, sonra gitti. Yazdım.","I heard. He drank some water, then went. I wrote it down."
D31O_AZ_02,"Yazdın mı? İyi etmişsin. Biz unuturuz; kâğıt unutmaz.","You wrote it? Good. We forget; paper doesn't."
D31O_AZ_EMP,"Dün gece tekfuru sormuşlar sana. Ne dedinse doğrusu odur kâtip; kimse bilmiyor.","They asked you about the Emperor last night. Whatever you said, that's the truth of it, clerk; nobody knows."
D31O_HR_01,"Duyduk duymadık demeyin! Sultan'ın emridir: saklanan kim varsa evine dönsün! Şehrin subaşısı Süleyman Bey'dir; derdi olan ona gelsin!","Hear ye, and say not you did not hear! The Sultan's order: whoever is hiding, let him return to his home! The governor of the city is Süleyman Bey; whoever has a grievance, let him come to him!"
D31O_N_02,"Kritovoulos, Sultan'ın şehri yeniden doldurmak istediğini yazar; çağrı Doukas'ta da geçer. Kapıların ardında saklananlar var, Tolga Bey. Tellalın sözünü çevirin; fazlasını değil.","Kritovoulos writes that the Sultan wanted the city filled again; Doukas mentions the call too. There are people hiding behind these doors, Mr Tolga. Translate the herald's words; nothing more."
D31O_T_02,"Fazlasını değil. Bir sigortacı için en zor talimat.","Nothing more. The hardest instruction you can give an insurance man."
D31O_TW_TRUE,"(Rumca, kapı aralanır) Evimize... gerçekten mi? (Kapı açılır. Bir kadın ve iki çocuk eşiğe çıkar.)","(In Greek, the door opens a crack) To our home... truly? (The door opens. A woman and two children step onto the threshold.)"
D31O_TW_PROMISE,"(Rumca, kapı biraz aralanır) Söz mü? ...Dün de söz verenler vardı.","(In Greek, the door opens a little) A promise? ...There were people making promises yesterday too."
D31O_N_PROMISE,"Söz vermeyin, Tolga Bey. Tutabileceğinizi bilmediğiniz bir sözü kayda geçiremem.","Don't make promises, Mr Tolga. I can't enter a promise in the record when you don't know you can keep it."
D31O_TW_THREAT,"(Kapı kapanır. Sürgü sesi.)","(The door closes. The sound of a bolt.)"
D31O_T_DOORS,"Kapılar açılıyor. Hepsi değil. Tellal yarın da geçecek.","The doors are opening. Not all of them. The herald will come by again tomorrow."
D31O_N_03,"31 Mayıs. Şimdi bir rivayet sayfası, Tolga Bey: kaynak değil, anlatı. Akşemseddin'in Haliç'in ucunda, surların dışında Peygamber'in sahabesi Ebû Eyyûb el-Ensârî'nin kabrini bulduğu anlatılır. Kayda 'rivayet' diye geçecek.","31 May. Now a page of tradition, Mr Tolga: not a source, a story. It is told that at the head of the Horn, outside the walls, Akşemseddin found the grave of Abu Ayyub al-Ansari, a Companion of the Prophet. It goes in the record marked 'tradition'."
D31O_DV_01,"Kâtip! Kanlı ay gecesi çorba taşıyan sen değil miydin? Gel; şeyh elinde kürek olan birini istedi. Dilinde lafı az olan birini.","Clerk! Weren't you the one carrying soup the night of the blood moon? Come; the sheikh asked for someone with a spade in his hand. And not too many words on his tongue."
D31O_AK_01,"Acele eden bulamaz, evlat. Yürü, dur, dinle. Toprak da konuşur, biz susarsak.","He who hurries does not find, child. Walk, stop, listen. The earth speaks too, if we are quiet."
D31O_T_03,"Hocam, ben genelde koordinatla bulurum.","Master, I usually find things by coordinates."
D31O_AK_02,"Koordinat nedir bilmem. Burada durduk; burası değil. Yürü.","I don't know what coordinates are. We stopped here; this isn't the place. Walk."
D31O_AK_03,"Burası. Kaz, ama yavaş. Yüzyıllardır bekleyeni bir saatte uyandırma.","Here. Dig, but slowly. Don't wake in an hour what has waited for centuries."
D31O_N_NOPHOTO,"Telefonu kaldırın, Tolga Bey. Rivayetin fotoğrafı olmaz; olursa rivayet olmaz.","Put the phone away, Mr Tolga. A tradition can't be photographed; if it could, it wouldn't be a tradition."
D31O_T_STONE,"Bir taş. Üstünde yazı var. Okuyamıyorum. Ama ellerim titriyor.","A stone. There's writing on it. I can't read it. But my hands are shaking."
D31O_AK_04,"Burası Ebû Eyyûb'un yeridir. Sultan'a haber verin. ...Sen de yaz, kâtip. Ama bildiğin kadarını yaz.","This is the resting place of Abu Ayyub. Send word to the Sultan. ...And you, clerk, write it down. But write only as much as you know."
D31O_N_04,"Rivayet böyle anlatır. Türbe beş yıl sonra yapıldı; bugün hâlâ orada, semt de onun adını taşıyor. Dosyaya 'rivayet' damgasıyla giriyor.","That is how the tradition tells it. The tomb was built five years later; it's still there today, and the district bears his name. It goes into the file stamped 'tradition'."
D31O_N_05,"1 Haziran, cuma. Ayasofya. Dört gün önce burada son ayin vardı; bugün ilk cuma namazı kılınacak. İki sayfa, aynı kubbe.","1 June, a Friday. Hagia Sophia. Four days ago the last liturgy was held here; today the first Friday prayer. Two pages, one dome."
D31O_DV_02,"Hasırları içeri taşı. Kıble şu ipin gösterdiği yer. Binanın yönü başka, kıble başka; saflar ipe bakar, duvara değil.","Carry the mats inside. The qibla is where that line points. The building faces one way and the qibla another; the rows follow the line, not the wall."
D31O_T_05,"Bina bir yöne bakıyor, kıble başka yöne. Bin yıllık bir yapıda ilk defa bir şeyi çapraz döşüyoruz.","The building faces one way, the qibla another. In a thousand-year-old building, we're laying something at an angle for the first time."
D31O_DV_OK,"Oldu. İpe paralel.","That's it. Parallel to the line."
D31O_DV_TURN,"Biraz daha sağa. Duvara değil, ipe bak.","A little more to the right. Look at the line, not the wall."
D31O_AZ_MAT,"Kâtip, bu hasırı tek kolla taşıyamam ama çekiştiririm. Sen getir, ben düzeltirim.","Clerk, I can't carry this mat with one arm, but I can tug it. You bring them, I'll straighten them."
D31O_DV_FIXED,"Birkaçı yamuk kalmış. Olsun; bin yıl dik durmuş bina, iki hasırla devrilmez.","A few are crooked. No matter; a building that's stood straight for a thousand years won't topple over two mats."
D31O_T_DOME,"Kubbe aynı kubbe. Mozaikler yerinde. Altındaki hasırlar yeni ve hepsi hafifçe yana dönük.","The dome is the same dome. The mosaics are where they were. The mats beneath it are new, and every one of them is turned slightly aside."
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

`UI_RECAP_*` (hepsi ≤140 karakter, denetlendi). **Değişen** mevcut satırlar:

```csv
UI_RECAP_28O_NEXT,"Şahi surda. 18 Nisan gecesi: Mesoteichion'a ilk büyük hücum; azaplarla barikata gidiyorsun.","The great gun is at the wall. Night of 18 April: the first great assault on the Mesoteichion; you go to the stockade with the azaps."
UI_RECAP_29O_PREV,"18 Nisan gecesi zil çaldın, hendeğe kalas attın, barikata kanca taktın; Giustiniani'nin barikatı dayandı.","On the night of 18 April you struck a cymbal, bridged the moat with a plank and hooked the stockade; Giustiniani's stockade held."
UI_RECAP_26O_NEXT,"Şehir düştü. Takvimi geri saralım: 29 Mayıs gece 01.30, Haliç. Haliç'teki gemilerle Petrion önündeki sura.","The city has fallen. Back up the calendar: 1:30 a.m., 29 May, the Golden Horn. With the ships in the Horn, against the wall at Petrion."
UI_RECAP_31O_PREV,"29 Mayıs gecesi Petrion'da kapılara emanet sancağı diktin, kilisenin kapısına çavuşu yetiştirdin.","On the night of 29 May you planted banners of protection on Petrion's doors and got the çavuş to the church door in time."
UI_RECAP_31O_NEXT,"Ayasofya'da ilk cuma kılındı. 1 Haziran, Galata: Ceneviz kasabası kapılarını açtı; Zağanos Paşa ahitnameyi okuyacak.","The first Friday prayer was held in Hagia Sophia. 1 June, Galata: the Genoese town opened its gates; Zaganos Pasha will read the charter."
UI_RECAP_27_PREV,"Fethin ertesinde su ve ekmek taşıdın; Eyüp'te bir rivayete kazma vurdun; Ayasofya'da ilk cumanın hasırlarını serdin.","After the conquest you carried water and bread, dug into a tradition at Eyüp and laid the mats for the first Friday in Hagia Sophia."
```

Notlar:
- `UI_RECAP_31O_PREV/NEXT` strings.csv'de **zaten var** (5398–5399. satırlar, eski metin): yukarıdakilerle değiştirilir.
- OTTOMAN_STORY §3'teki **planlı** `UI_RECAP_26O_NEXT` ve `UI_RECAP_27_PREV` (beyitli) satırları artık geçersiz; yerine
  yukarıdakiler.
- `UI_RECAP_29O_PREV` 37 eklenince değişir; A belgesinin 33–36'sı 28'in önüne girerse `UI_RECAP_28O_PREV` onların işidir.
- **Bölüm 27'nin açılışı (Osmanlı yolu):** `D27_N_01` "Bir sayfa daha var… kuşatmanın ertesi… Şehir üç gündür Sultan'ın"
  31o'dan sonra tekrar olur. Osmanlı tarafı için bir varyant (`chapter27.gd`: `side() == "O"` iken):

```csv
D27O_N_01,"Son sayfa, Tolga Bey. Aynı gün, 1 Haziran, Galata. Siz öğlen Ayasofya'daydınız; Haliç'in bu yakasındaki Ceneviz kasabası kapılarını kendisi açtı.","The last page, Mr Tolga. The same day, 1 June, Galata. At noon you were in Hagia Sophia; the Genoese town on this side of the Horn opened its gates of its own accord."
```

- `UI_CH27_SUB` "1 Haziran 1453 · Galata · öğle" → 31o cuma namazıyla saat çakışmasın diye **"öğleden sonra"** önerilir
  (iki tarafta ortak satır; Bizans tarafına zararı yok):

```csv
UI_CH27_SUB,"1 Haziran 1453 · Galata · öğleden sonra","1 June 1453 · Galata · afternoon"
```

- **29o'nun açılışı:** `D37O_U_04` ("Baltaoğlu kürekçi istiyor. Sen hafifsin") 28o→29o kopukluğunu artık kapatır;
  29o'ya ayrıca replik gerekmez.
- **26o → 38:** 26o'nun sonu (ortak Ayasofya kapanışı) değişmez; 38 kendi `D38O_N_01`'iyle takvimi geri sarar.
- **Akış haritası (OTTOMAN_STORY §1):** tabloya dört satır eklenir (37: 28'in ardına; 38 ve 39: 26'nın ardına; 31o artık
  planlı değil).

---

## 6. Yapım notu (bölüm başına)

| Bölüm | Yeni dosya | Değişen ortak kod | Tahmini iş |
|---|---|---|---|
| 37 | `chapter37o.gd/.tscn` | yok (20o iskeleti; 29o kanca, 28o çekme, 26o taş, 30o taşıma kopyalanır ya da ortak yardımcıya çıkarılır) | 4–5 sa |
| 38 | `chapter38o.gd/.tscn` | `SeaWalls.gate()` statik yardımcı (kapı kurucusu + `open_gate`); gerekirse Horn'un su şeridi | 5–6 sa |
| 39 | `chapter39o.gd/.tscn` | `FallenCity`: `spared`, `harbor_end` seçenekleri | 4–5 sa |
| 31o | `chapter31o.gd/.tscn` | yok (26'nın aşama düzeni; hasır döndürme 40 satırlık yeni kod) | 5–6 sa |

Ortak: `Siege.ORDER`, `Siege._plays` listesi, `Lore.PAGES`, `TespitCam` hedef kimlikleri (`siege37/38/39/31`),
`tests/siege_route.tscn` ROUTECHECK beklentileri (Osmanlı tarafı dört bölüm uzar; 13/14/15'in `{N13}` numaraları kayar).
