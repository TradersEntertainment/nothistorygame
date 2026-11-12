# Niko'yu Yeniden Yazmak: Teşhis, Üç Yön, Öneri

> **Durum:** yalnız öneri. `i18n/strings.csv`, betikler ve ses dosyaları değişmedi; ses üretilmedi.
> Makine okur örnekler: `docs/NIKO_YENIDEN_ornek.json` (üç yön × aynı 12 anahtar).

## Özet

**Teşhis.** Niko bir karakter olarak değil, bir skeç olarak tasarlanmış ve bu yazılı olarak duruyor. `docs/GDD.md` §5.11'in başlığı "Monty Python'daki Fransız şövalyesi gibi". Sahibin dinlediği iki replik de o skeçteki hakaretin Türkçeye uyarlanmış hali: "Annen bir Ceneviz kayığıydı / baban kötü zeytinyağı kokardı". İngilizce karşılıkları skeçtekiyle neredeyse kelimesi kelimesine aynı: *"Your mother was a… and your father smelt of…"*. Bu kalıbın üstüne üç şey daha eklenmiş:
- **Tek nota:** 125 satırın 30'u `[shouting]`/`[excited]` etiketli, satırlarda toplam 99 ünlem var. Ses tasarımı da bunu istiyor: `cast.json`'da "Loud, booming, good-hearted, jovial" yazıyor. Böyle bir tarif sesi animatöre ya da spikere götürür.
- **Her cümlenin sonunda bir espri:** "Tavuk hep yanlış adamı seçer", "O martı geçen hafta bir fermanı yedi", "Yok da bir renktir". Bu, nöbetçinin değil stand-up'çının ritmi.
- **İsteği olmayan bir adam:** Niko'nun neden bağırdığı, neden tavuk attığı, neden Tolga'yı gezdirdiği belli değil. Kuşatmanın kendisi de onun ağzından hemen hiç duyulmuyor: açlık, gecikmiş maaş, yorgunluk, korku yok.

Buna karşılık sonraki bölümlerde (8Y, 19, 20, 24) yazılmış Niko replikleri iyi ve gerçek bir askere benziyor: "Yapma.", "Dönmeniz yeter.", "Çocuk kuru." Yani karakter oyunun içinde zaten kendiliğinden düzelmeye başlamış; düzelmeyen kısım, sahibin dinlediği giriş sahneleri (4b ve 6b).

**Üç yön:**
- **(a) Esnaf nöbetçi:** Fener'in balıkçısı ve kayık kiracısı, zorla sura çıkarılmış. Her şeyin bir hesabı var, Tolga'yı da önce bir mal gibi tartıyor. Sonunda tek bir şey için para almıyor.
- **(b) Eski nöbetçi:** otuz yıldır aynı surda, 1422 kuşatmasını da görmüş, elli yaşında, kuru ve az konuşan biri. Komedi onun hiçbir şeye şaşırmamasından doğuyor. Korkusunu yalnızca sonlara doğru belli ediyor.
- **(c) Acemi nöbetçi:** yirmi yaşında, başındaki miğfer büyük gelen Petrionlu bir çocuk. Bağırıyor, çünkü korkuyor. Tolga onun ilk "casusu" ve ilk gerçek dostu oluyor; kuşatma ilerledikçe bağırmayı bırakıyor.

**Önerim: (b) Eski nöbetçi.** Gerekçeleri:
- Sahibin istediği "oradan bir asker" tarifine en çok o uyuyor.
- Kadroda Kadri, Urban ve Hasan ile Hüseyin zaten gürültülü; sakin ve kuru bir ses kadroda yeni bir renk olur.
- En önemlisi, oyundaki en iyi Niko replikleri (8Y, 19, 24) zaten bu sesle yazılmış. (b) yeni bir karakter icat etmiyor, var olan iyi Niko'yu baştan sona yayıyor.
- (a)'nın para ve kuzen motifi (pazarlık mini oyunu) (b)'nin içinde küçük bir damar olarak korunuyor.

---

## 1. Döküm: Niko'nun 125 repliği ve sahneleri

Kaynak: `docs/voice/VOICE_MAP.csv` (`SPK_NIKO` = 125 satır), `i18n/strings.csv` ve bölüm betikleri. "say" konuşmayı durdurup bekler, "bark" oynanış sürerken üstten akar (sayı = ekranda kalma süresi, sn).

### 1.1 Bölüm 4b · Deniz surları, ilk gece (`scripts/chapter4.gd`, `_run_4b`, `_gate`, `_eclipse`, `_fell`)

| Anahtar | Ne iş görüyor | Kime / koşul | Oynanışa bağlı mı |
|---|---|---|---|
| `D4B_N_01` / `_NOFEZ` | Zincirde yürüyen Tolga'yı ilk fark ediş. Karakteri tanıtır, gerilim kurar | Tolga'ya, surdan. Zincirin %15'inde; fes bayrağına göre varyant | **bark 3,5**: denge oyunu sürerken çalar, kısa olmalı |
| `D4B_N_02` | İkinci laf, zincirin ortasında | %55'te | **bark 3,5** |
| `D4B_N_03` / `_NOFEZ` | Rıhtımda **yön verir** (hedef kapı) ve fırlatma bölümünü başlatır | Tolga'ya, uzaktan ("afar") | say; ardından kaçınma oyunu başlar |
| `D4B_N_THROW_CHICKEN_1…4` | Her fırlatmada uyarı. 4. tavuktan sonra `sinerji` bayrağı (tavuk Tolga'ya katılır) | Fırlatma sayısına bağlı | **bark**, fırlatmayla eş zamanlı |
| `D4B_N_THROW_SACK`, `_SHIELD` | Fırlatma uyarısı. Tolga'nın `D4B_T_HIT_2` ("İnciri de mi?") ve `_SHIELD` ("Hektor kim?!") cevapları bunlara bağlı | Rastgele fırlatma türü | bark |
| `D4B_N_ECLIPSE_1/2/3` | **Hikâye bilgisi**: ay tutulması kehaneti ve "ikinci alamet" (Tolga'nın ışığı). `eclipse_seen` bayrağı, paradoks +5. Bölüm 24'te Tolga buna geri döner | Kapıda, her girişte | say |
| `D4B_N_GATE` | Yakalama. Hemen ardından **eşya gösterme seçimi** açılır, yani "ne getirdin" sorusu gerekli | Kapıda | say → seçim |
| `D4B_N_CHICKEN` | Sinerji'nin Tolga'yı seçtiğini onaylar | `sinerji` ise | say |
| `D4B_NIKO_*` (10 eşya) | Eşya tepkisi. **Leblebi → `niko_friend`**: Niko'nun bütün dostluk dalı buradan açılır | Gösterilen eşya | say. Bölüm 6b'de aynı anahtarlar yine kullanılır |
| `D4B_N_HAT` / `_NOFEZ` | **Fes kararını açar** (6 sn süreli seçim) | Kapıda | say → süreli seçim |
| `D4B_N_SPY`, `D4B_N_SPY2` | Sonuç 4b.1: "Türk casusu" diye yakalar, rehberlik etmeyi teklif eder. Tolga'nın `D4B_T_SPY` cevabı ("Fes 1829'da gelecek") "fes + casus" sözlerine bağlı | fesli | say |
| `D4B_N_MERCHANT`, `_MERCHANT2` | Sonuç 4b.2: "kaybolmuş Frenk tüccarı" | fessiz | say |
| `D4B_N_ISTANBUL` | **Bilgi**: "is tin Polin" | Her iki sonuçta | say |
| `D4B_N_CELL` / `_NOFEZ`, `D4B_N_CELL2` | Sonuç 4b.3 (zincirden düştü): hücre. "Zindan formu" esprisi burada başlar | düşme | say |

### 1.2 Bölüm 6b · Surların içi (`scripts/chapter6.gd`)

| Anahtar | Ne iş görüyor | Koşul | Bağ |
|---|---|---|---|
| `D6B_N_CELL_MORNING` / `_NOFEZ` | Hücreden sabaha geçiş; "kırmızımsı" | 4b.3 | say |
| `D6B_N_CALL` | **Yön verir**: kançılaryanın önüne çağırır | Serbest dolaşım başında | bark 4 |
| `D6B_NK_ROOF` | Çatıya ilk çıkışta laf atar (sistem bildirimi) | İlk çatı | bark 4,5 |
| `D6B_N_PERMIT` | **Görev ve yön**: Misafir İzni, Theodoros, en sondaki oda, öbür altısıyla uğraşma | İlk konuşma | say |
| `D6B_N_HINT` | İpucu: Eta odası | Seçenek `UI_CH6B_HINT` | say |
| `D6B_N_NOT_YET` | Kapı bekçiliği: İmparator'a sırası gelmeden gidilmez | Giustiniani öncesi | bark 3 |
| `D6B_N_GULL` | **Kovalamacayı başlatır**: izni martı kaptı, izinsiz yakalanmanın cezası zindan | İzin alındıktan sonra | say (martı uzaklaşınca) |
| `D6B_N_MISS` | Kovalamada her ikinci ıskada laf atar (Tolga'nın `D6B_T_MISS` repliğiyle sırayla çalar) | Iska | bark 3 |
| `D6B_N_DUNGEON(_FIRST)(_NOFEZ)` | Martı kaçtıysa muhafızın yakaladığı Tolga'yı hücrede karşılar | Kovalama kaybedildi; "yine" yalnız 4b.3 ise | say |
| `D6B_N_E_01` / `_NOCHICK`, `_E_03`, `_E_04` | **Tercüme**: İmparator'un Yunanca sözleri. Mektup bu arada el değiştirir | Huzur | say |
| `D6B_N_FRIEND` | Dostluğun ödülü; `niko_friend_6b` bayrağı | `niko_friend` | say |
| `D6B_N_BYE` | Çıkış kapısında son söz (beyaz bayrak) | 6b sonu | say |
| `MG_HAG_NIKO_*` (8) | Kuzenin kayığı için pazarlık mini oyunu (`minigame_haggle.gd`, başlangıç 50 akçe, "çok sabırlı ama inatçı") | Şehirde isteğe bağlı | Durumlara bağlı tepkiler |

### 1.3 Sonraki görünüşler

| Bölüm / betik | Anahtarlar | İş |
|---|---|---|
| 7 (Nihat oynanır, `chapter7.gd`) | `D7_NIKO_HELLO`, `_LIE` (dostsa yanlış yer söyler: `ch7_lie`), `_AWE_TRUTH` + `D7_AWE_NIKO` (gökten inen birine yalan söyleyemez), `_CELL*`, `_OUTSIDE`, `_AGAIN`, `D7_EAVES_NIKO_*` (kulak misafiri bark 5) | Tanıklık. Dostluk bayrağı bu sahnenin dalını belirler |
| 8Y (sınır dışı/havlu, `chapter8y.gd`) | `D8Y_NIKO_1`, `_TOWEL`, `_LETTER`, `_OPENED`, `_DEP`, `_DEP_TOWEL`, `_SINERJI(_N)`, `_GATE`, `_GATE2`, `_RULES`, `_BYE` | Tolga'yı kapıya kadar götürür; yürüme kuralı (`_RULES`) **oynanış talimatıdır** |
| 10H (gece heyeti, `chapter10h.gd`) | `D10H_N_1`, `_NOPEAS(_NEW)`, `_PEAS` (`chain_watch` → Bölüm 17'de fenerli kayık), `_DONE`, `_K` / `_K_ALT` (`cannon_taped`) | Zincir nöbetçilerine leblebi görevi |
| 11 (`chapter11.gd`) | `D11_NK_00`, `_01` / `_01_HEN`, `_03` | Sonuç 11.6: sarıklı kılıkta ordugâha gelir, tavuğu Nihat'a fırlatır, Tolga kaçar (`niko_friend`) |
| 13 (`chapter13.gd`) | `D13_N_MISSED` / `_STRANGER` | Kırmızı düğme kaçırıldıysa Bizans'ta kalış |
| 19 (`chapter19.gd`) | `D19_NK_01`, `_TEZKIRE`, `_02` | Brigantinin dönüşü: haber yok |
| 20 (`chapter20.gd`) | `D20_NK_01`, `_DROP` | Dostsa gediğe her 15 sn'de bir yük taşır (oynanış etkisi) |
| 24 (`chapter24.gd`) | `D24_NK_01`, `_GUST` (bark 2,2), `_KID` (bark 3,5), `_SAVED`, `_LATE` | Dostsa alayda sırığa omuz verir; selde kapı kanadını yatırır, çocuğa yetişme süresi 22'den 29 saniyeye çıkar |
| Eşya tepkisi (`hud.gd`) | `REACT_NIKO_*` (12), `REACT_NIKO_REPLAY_1…5` | `D4B_NIKO_*` ile neredeyse aynı metnin ikinci kopyası; tekrar oynayanlar için `_REPLAY` |

### 1.4 Yay ve "Niko'nun ortadan kaybolması"

- **Yazılı yay (EVREN §Niko, GDD §5.11):** surdan laf atan ve tavuk fırlatan bir nöbetçi; Tolga'yı terfi için yakalar, rehber ve tercüman olur. Dostluğu leblebiyle kazanılır (`niko_friend`).
- **Hitap yayı (kendiliğinden oluşmuş, iyi):** Bölüm 4–11 arasında Tolga'ya hep "casus" der (`chapter7.gd:860`: "Niko onun adını bilmez"). 10H ve 20'de "Frenk" der, ilk kez 20'de ve 24'te "**Tolga**" der. Bu güzel bir yay ama tasarlanmamış: Niko'nun Tolga'nın adını ne zaman öğrendiği hiçbir sahnede yok.
- **Kayboluşu (açık sorun):**
  1. Uygulanmış oyunda Niko'nun son repliği **Bölüm 24**. Perde IV'te (25–43) Bizans tarafında 25, 26, 27, 29, 30, 36b, 42b bölümleri var ama hiçbirinde `SPK_NIKO` yok.
  2. Dost değilse son görünüşü 10H (o rotadaysa), değilse 8Y ya da 6b.
  3. `docs/BYZANTINE_MIRROR.md` 28B, 32B (Niko'nun ateşi), 34B, 37B, 38B (annesi Petrion'da, kuzenin kayığı) ve 39B (anne Eudokia) için Niko sahneleri tasarlamış. Ama bu anahtarların hiçbiri `strings.csv`'de yok, betikleri de yok.
  4. Sonuçta Niko bir vedayla değil, bir bölümde sessizce çıkıp bir daha gelmeyerek kayboluyor. Akıbet kartı (`PF_NIKO`, `PF26_NIKO`: "Niko buradaydı") onu bir taş yazısıyla kapatıyor.
- **Bu belgenin buna etkisi:** üç yön de kuşatmanın sonuna kadar taşınabilecek bir adam kuruyor ve üçünde de anne motifi var (MIRROR'daki Eudokia/Petrion ile uyumlu). Kayboluşu kapatmak için yeni sahne ya da yeni anahtar gerekiyor; bu iş kapsam dışı, §4.4'te ayrı öneri olarak duruyor.

---

## 2. Teşhis: Neden tutmuyor?

1. **Ödünç skeç, yazılı olarak.** GDD §5.11: "Monty Python'daki Fransız şövalyesi gibi… *Annen bir Ceneviz kayığıydı! Baban kötü zeytinyağı kokardı!*". `D4B_N_01`/`02`'nin İngilizcesi ("Your mother was a Genoese rowing boat… your father smelt of bad olive oil") skeçle neredeyse birebir aynı. Skeci bilen oyuncu alıntıyı tanır; bilmeyen oyuncu da durup dururken hakaret eden birini duyar. İkisinde de karşısında bir nöbetçi yok. `D6B_N_BYE` aynı hakareti üçüncü kez geri çağırıyor.
2. **Tek nota bağırma.** 30 satır bağırma/heyecan etiketli. Ses tarifi "Loud, booming, jovial" diyor. Bağırmanın bir sebebi olmadığı için ses tasarım aracı bunu "sahne enerjisi" diye okuyor ve sahibin "spiker gibi" dediği yere varıyor. Gerçek bir nöbetçinin gece sesi bir **çağrıdır** ("Kim var orada?"): kısa, yüksek, sakin ve işlevsel.
3. **Her cümle bir espriyle bitiyor.** "Surun dibi benim. *Tavuğum da benim.*", "*O martı geçen hafta bir fermanı yedi!*", "*Tavuk hep yanlış adamı seçer.*", "*Yok da bir renktir.*" Böyle replikler bir durumu değil, bir ritmi taşıyor. Oyuncu her satırın sonunda espriyi bekliyor ve karakterin kendisine hiç ulaşamıyor.
4. **İsteği yok.** Niko'nun tek isteği, `D4B_N_SPY`'daki ve termosla ilgili satırdaki "madalya". O da bir kez söylenip bırakılıyor. Neden tavuk atıyor? (Ok mu yok? Başka atacak şey mi kalmadı?) Neden Tolga'yı teslim etmeden önce gezdiriyor? Cevap yok, yani komedi durumdan doğmuyor.
5. **Yerin ve zamanın kokusu yok.** Nisan 1453'te deniz surundaki bir Rum nöbetçiden duyulması beklenen şeyler var: açlık, maaşın gecikmesi (İmparator kilise gümüşünü eritiyor), zincir nöbetinin uykusuzluğu, Ceneviz ve Venedikliye bakışı, bir tek Rumca kelime. Bunlardan ağızda yalnız "kuru ekmek" (`D4B_NIKO_CHICKPEAS`) ve "deniz ateşi" (`_LIGHTER`) var. İkisi de iyi, ikisi de korunmalı.
6. **Tolga'yla ilişki gelişmiyor, sonra birden sıçrıyor.** 4'ten 11'e kadar aynı "casus" esprisi ve aynı form esprisi sürüyor. "Kırmızımsı" ya da "Şapka: yok" yalnız Niko'nun ağzından 12 satırda geçiyor; oyunun tamamında 30 anahtara yayılmış durumda (Tolga'nın alıntıları, Nihat'ın Bölüm 7, 14 ve 15'teki raporları). Tavuk esprisi Niko'nun 13 satırında, kuzen esprisi 8 pazarlık satırının 6'sında aynı biçimde tekrarlanıyor. Sonra 19'da bir anda olgun bir adam çıkıyor ("Kaçabilirdiniz. Dönmüşsünüz."). Arada bir köprü yok.
7. **"Kırık çarşı Türkçesi" uygulanmamış.** EVREN ve GDD Niko'nun kırık Türkçe konuştuğunu söylüyor. Replikler ise akıcı ve esprili İstanbul Türkçesiyle yazılmış. Bu bir eksik ama aynı zamanda bir tuzak: kırık Türkçeyi abartmak bizi Yeşilçam'ın Rum karikatürüne götürür. Doğru ölçü: **az kelime, sade sözdizimi, arada bir Rumca kelime**. Hal ekleriyle oynanmamalı.
8. **Yeni "doğal" metin aynı yönde daha da ileri gidiyor.** `yeni_diyaloglar_dogal.txt`'deki Niko önerileri ("kırmızı saksı kafalı", "altı düz bir Ceneviz mavnası", "arsız martı imparatorluk buyruğunu yuttu") skeci süslüyor, bir askere çevirmiyor. Bu dosya Niko için **kullanılmamalı**.

**İyi çalışan ve korunacak replikler.** Bunlar ölçüt de olsun:
- `D8Y_NIKO_BYE` "Yapma." (Tolga "Bir gün sana bir poliçe yapacağım" dedikten sonra)
- `D8Y_NIKO_RULES` ("Koşan adam ya kaçıyordur ya saldırıyordur, ikisi de ok yer.")
- `D8Y_NIKO_OPENED`, `D8Y_NIKO_LETTER`, `D8Y_NIKO_DEP_TOWEL` ("Genelde.", Tolga da aynı sözle karşılık veriyor)
- `D19_NK_02` ("Kaçabilirdiniz. Dönmüşsünüz."), `D19_NK_TEZKIRE`
- `D20_NK_*` ve `D24_NK_*`'nin tamamı ("Çocuk kuru.")
- `D6B_N_E_04` ("Aslında güzel bir şey dedi. Ben söylemeyeyim.")
- `D7_NIKO_AWE_TRUTH`, `D10H_N_1` ("Uyumamak için şarkı söylüyorum. Kötü söylüyorum.")
- `D4B_NIKO_CHICKPEAS` ("Haftalardır kuru ekmek yiyorum. Sen… sen iyi casussun."), `D4B_N_ISTANBUL`, `D13_N_MISSED_STRANGER`

Ortak noktaları: kısa, düz söyleniyor, bir duruma bağlı ve sonu esprisiz.

---

## 3. Üç karakter yönü

Ortak kurallar:
- Komedi kişilikten ve durumdan gelmeli.
- Bağırmanın her seferinde bir sebebi olmalı.
- Metin seslendirilebilir olmalı: rakam ve parantez yok.
- Her yeniden yazım, anahtarın oyundaki işini korumalı.
- Uzunluk eski metnin %60–140'ı içinde kalmalı (aşağıda her biri betikle ölçüldü).
- `_NOFEZ` varyantları aynı yönde ayrıca yazılır (§4.2).

Seçilen 12 anahtar şu durumları kapsıyor:
- **ilk laf:** `D4B_N_01`, `02`
- **yön:** `03`
- **yakalama:** `GATE`, `SPY`
- **zindan formu:** `CELL`
- **kançılarya:** `PERMIT`
- **martı:** `GULL`
- **tercüme:** `E_03`
- **pazarlık:** `MG_HAG_NIKO_OPEN`
- **veda:** `D6B_N_BYE`
- **son karşılaşma:** `D24_NK_SAVED`

### 3a. Esnaf nöbetçi: "Her şeyin bir hesabı var"

**(a) Kim?** Niko otuzlarının sonunda, Fener'de balık satan ve kuzeninin kayığını gündelik kiraya veren biri. Türkçesini Galata'da ve Haliç kıyısında Türk tüccarlarla alışveriş yaparken öğrenmiş. Kuşatma başlayınca şehirde silah tutabilecek her erkek gibi o da sura çıkarılmış. Miğfer ödünç, maaş üç aydır yok.
- **İstediği:** kuşatmadan annesi, kayık ve kesesiyle çıkmak.
- **Korkusu:** satacak hiçbir şeyi kalmamış bir adam olmak.
- **Tolga'ya bakışı:** zincirde gördüğü ilk an Tolga bir **mal**dır: saraya götürülecek bir "casus", belki bir ödül. Kapıda bir **müşteri** olur (eşyalar, leblebi), kançılaryada bir **ortak** (iznin parasını kim ödeyecek?). 10H'den sonra hesap tutmayı bırakır. 24'te ilk ve tek kez "bunun parasını almam" der.
- **Tolga'yla ilişkisi:** iki satıcı karşı karşıya. Tolga sigorta satıyor, Niko her şeyi satıyor.

**(b) Konuşma biçimi.**
- Orta uzunlukta, hızlı cümleler. Fiyat söyler gibi kesin.
- Sık kullandığı sözler: "hesap", "kaç eder", "ona göre konuşuruz".
- Çarşı ağzı; Rumca neredeyse hiç kullanmaz, yalnızca küfür yerine "Panagia!" der.
- Bağırmaz, **sesini taşır**: tezgâhtan karşı tezgâha seslenir gibi.

**(c) Ses tarifi (EN).** *A Greek man in his late thirties from the Constantinople waterfront, a fishmonger and boat-hirer drafted onto the sea walls; he speaks a quick, practical market Turkish with a light Greek lilt, mid-pitched and a little hoarse from calling out prices. Not a narrator, not an announcer, not a cartoon: a real man recorded where he stands, on a cold stone wall at night, tired and hungry but still quick on his feet. He raises his voice only to carry across distance, never for effect.*

**Okuma notu.** Pazarlık temposunda konuşur: gülümser ama gülmez. Uzaktan seslenirken bağırmaz, sesini taşır. Tehditleri bile fiyat söyler gibi çıkar. Parayla ilgisi olmayan bir şey söylediği nadir anlarda yavaşlar ve sesi alçalır.

**(d) 12 replik.**

- **`D4B_N_01`.** *Eski:* "Hey sen, fesli! Annen bir Ceneviz kayığıydı!" → *Yeni:* **"Hey, fesli! Zincir yol değil! Geçeceksen geçiş parası var!"**
  *Neden:* Bir nöbetçinin ilk refleksi yolu kesmek; bu adamın refleksi de ücret istemek. Laf atma bir hakaretten doğmuyor, durumdan doğuyor.
- **`D4B_N_02`.** *Eski:* "Baban da kötü zeytinyağı kokardı! Buradan kokusu geliyor!" → *Yeni:* **"Gece geçişi iki katı! Düşersen seni ben çıkarırım, o da ayrı hesap!"**
  *Neden:* Espri tırmanıyor ama karakterin içinde kalıyor. Ayrıca zincirden düşme sonucunu (4b.3, nöbetçiler Tolga'yı sudan çıkarıyor) önceden haber veriyor.
- **`D4B_N_03`.** *Eski:* "Gel bakalım, fesli. Surun dibi benim. Tavuğum da benim." → *Yeni:* **"Kapı şu dipte, fesli. Gel. Yolda üstüne ne gelirse hesaba yazarım."**
  *Neden:* Yön veriyor (kapı) ve fırlatma bölümünü hem duyuruyor hem karakterine bağlıyor.
- **`D6B_N_GULL`.** *Eski:* "Casus, koş! İzinsiz yakalanırsan zindan! O martı geçen hafta bir fermanı yedi!" → *Yeni:* **"Koş, casus! Martı iznini kaptı! O kâğıt olmadan seni zindana atarlar, ben de kefil olamam!"**
  *Neden:* İş aynı (koş; ceza zindan). Sondaki ödünç espri yerine Niko'nun kendi riski geliyor: "kefil" çarşının sözü.
- **`D4B_N_GATE`.** *Eski:* "Dur! Kimsin sen? Ne getirdin? Casuslar hep bir şey getirir." → *Yeni:* **"Dur. Kimsin? Cebinde ne var? Göster, ona göre konuşuruz."**
  *Neden:* Eşya seçimini açan soru korunuyor; "ona göre konuşuruz" seçimin pazarlık olduğunu söylüyor.
- **`D4B_N_SPY`.** *Eski:* "Fes! Türk casusu! Yakaladım! Madalya alırım!" → *Yeni:* **"Fes mi o? Türk casusu! Saray casus başına ödül veriyor!"**
  *Neden:* "Madalya" soyut bir istekti. "Casus başına ödül" bu adamın gerçek isteği. Tolga'nın "Fes 1829'da gelecek" cevabı aynen çalışıyor.
- **`D4B_N_CELL`.** *Eski:* "Zindan formu: adın, baban, fesinin rengi. Sabah konuşuruz." → *Yeni:* **"Zindan defteri: adın, baban, fesin rengi. Yatak parası yok, sevin."**
  *Neden:* Form esprisi (sonraki "kırmızımsı" satırlarının kaynağı) korunuyor. Kapanış, karakterin hesap gözünden.
- **`D6B_N_PERMIT`.** *Eski:* "Şehirde kalmak için Misafir İzni lazım. Logothetes Theodoros verir, en sondaki oda. Öbür altı odayla uğraşma, orada sadece mühür sayarlar." → *Yeni:* **"Şehirde kalacaksan Misafir İzni lazım. Theodoros verir, en sondaki oda. Öbür altı odaya hiç girme; orada mühür sayarlar, para saymazlar, iş çıkmaz."**
  *Neden:* Yön ve kural aynen duruyor. Bürokrasiye bakışı bir esnafın bakışı. "Logothetes" çıktı, seslendirmede tökezliyordu.
- **`D6B_N_E_03`.** *Eski:* "İmparator diyor: mektup al, git, bir daha gelme." → *Yeni:* **"İmparator diyor: mektubu Sultan'a götür. Yol parası yok."**
  *Neden:* Tercüme esprisi korunuyor ama bu kez karakterden geliyor: Niko bir imparatorun ricasına bile bir masraf kalemi ekliyor.
- **`MG_HAG_NIKO_OPEN`.** *Eski:* "Kuzenimin kayığı. Kuzenim bilmiyor. Elli akçe, bir gün. Akşama geri getir, kuzen fark etmesin." → *Yeni:* **"Kayık kuzenimin, ama kuzen bugün nöbette. Elli akçe, bir gün. Güneş batmadan getir; kuzen akşam sayar."**
  *Neden:* Başlangıç fiyatı (50) ve koşullar aynı. Kuzenin yokluğu kuşatmaya bağlanıyor (o da nöbette). "Kuzen sayar" ailenin de esnaf olduğunu söylüyor.
- **`D6B_N_BYE`.** *Eski:* "Git, casus! Annene selam söyle! Annen hâlâ bir Ceneviz kayığı mı?" → *Yeni:* **"Git, casus! Bayrağın parasını almadım, unutma! Sağ dön de ödersin!"**
  *Neden:* Veda, ödünç hakaretin üçüncü tekrarı olmaktan çıkıyor. Borç, "geri gel" demenin bu adama özgü yolu oluyor.
- **`D24_NK_SAVED`.** *Eski:* "Çocuk kuru. Sen sırılsıklamsın, ben de. Ama çocuk kuru." → *Yeni:* **"Çocuk kuru. Bunun parasını kimseden almam. Senden de almam."**
  *Neden:* Yayı kapatıyor: hesabı hiç bitmeyen adam ilk kez hesap tutmuyor. (Not: eski metin de iyi; bu yönde bile aynen kalabilir.)

**(e) Riskleri.**
- Niko'yu Tolga'nın aynası yapmak, ikisinin sesini birbirine yaklaştırabilir: iki satıcı, iki ticari jargon.
- Para esprisi kendisi de bir tekrar makinesine dönüşebilir (eski kuzen esprisinin yaptığı gibi). Seyrek kullanılmalı.
- "Asker" hissi en zayıf bu yönde: üniformalı bir esnaf. Sahibin "asker gibi" isteğini tam karşılamayabilir.

### 3b. Eski nöbetçi: "Hepsini gördü, hiçbirine şaşırmıyor" (önerilen)

**(a) Kim?** Niko elli yaşlarında. Otuz yıldır aynı deniz surunda nöbet tutuyor; 1422'de II. Murad'ın kuşatmasını da bu surdan izlemiş, "o da geçti" diyor. Karısı ölmüş, annesi Petrion'da yaşıyor. Türkçesi yıllarca kapıdan geçen Türk kayıkçılarla laflaşmaktan kalma: az ve sade. Dört aydır maaş yok; ok bitti, elinde ne varsa onu atıyor (tavuk dahil, kusura bakmayın).
- **İstediği:** nöbetin bitmesi, birikmiş maaşı, bir gece deliksiz uyku.
- **Korkusu:** bu kez "geçmeyecek" olması. Bunu söylemez, Bölüm 19–24'te belli eder.
- **Tolga'ya bakışı:**
  - Bölüm 4'te Tolga bir **evrak işidir**, bu ayın üçüncü "casusu" (öbür ikisi balıkçıydı).
  - 6b'de **benim casusum** olur: başkası zindana atarsa defteri yine kendisi yazacaktır.
  - 8Y'de onu kapıya kadar götürür ("Yapma.").
  - 10H ve 20'de "Frenk" der ve onu bir işçi gibi görür.
  - 24'te adını söyler ve neredeyse gülümser.
- **Komedi kaynağı:** saçmalık karşısındaki düzlük (zincirde fesli adam: "Olur.") ve kurala alışkanlıktan uyan bir adamın Tolga'nın kaosunu deftere geçirmesi.

**(b) Konuşma biçimi.**
- Çok kısa cümleler (çoğu 2–6 kelime), duruşlarla ayrılmış.
- Tekrar ettiği sözler: **"Olur."** (saçmalığı kabul ediş), **"Geçer."** (kuşatma için, gittikçe daha az inanarak).
- Bağırmaz. Surdan seslenirken nöbetçi çağrısı yapar: iki kelime, yüksek ama öfkesiz.
- Rumca çok seyrek: dua anlarında "Panagia", yorgunlukta "Ela" (haydi).
- Kırık Türkçe sözdiziminde değil, **kelime azlığında** duyulur.

**(c) Ses tarifi (EN).** *A Greek soldier around fifty who has stood watch on the sea walls of Constantinople for thirty years; low, dry, slightly rough baritone, unhurried, with a light Greek accent in his Turkish and the flatness of a man on his third night without proper sleep. Not a narrator, not an announcer, not a jolly giant: a real guard recorded on the wall, speaking to the person in front of him, not to an audience. Mostly quiet and clipped; when he calls out, it is a trained sentry's call, short and practical.*

**Okuma notu.** Varsayılan sesi alçak ve tek nefes. Espriyi vurgulamaz; komedi düzlükten gelir. Surdan seslenmesi bir nöbetçi çağrısıdır: yüksek, sakin, iki kelime. Hiç gülmez. Bölüm 19–24'te sesi bir parça yumuşar. "Olur." her seferinde aynı düz tonda söylenir. Bark'larda bile acele etmez: kısa yazıldığı için süreye sığar.

**(d) 12 replik.**

- **`D4B_N_01`.** *Eski:* "Hey sen, fesli! Annen bir Ceneviz kayığıydı!" → *Yeni:* **"Kim var orada? …Fesli. Zincirde. Gece yarısı. Olur."**
  *Neden:* Gerçek bir nöbetçi çağrısıyla başlıyor. Komedi, durumun saçmalığını üç kuru kelimeyle tespit edip kabul etmesinden doğuyor. Karakter ilk cümlede kuruluyor.
- **`D4B_N_02`.** *Eski:* "Baban da kötü zeytinyağı kokardı! Buradan kokusu geliyor!" → *Yeni:* **"Zincirden in, fesli. Ben ok atmam. Ok bitti. Tavuk var, onu atarım."**
  *Neden:* Tavuk fırlatmayı bir şaka olmaktan çıkarıp kuşatmadaki kıtlığa bağlıyor. Fırlatma oyununun sebebini veriyor.
- **`D4B_N_03`.** *Eski:* "Gel bakalım, fesli. Surun dibi benim. Tavuğum da benim." → *Yeni:* **"Kapı şu dipte. Yürü. Başını eğ; elime ne geçerse atacağım, kusura bakma."**
  *Neden:* Yön (kapı) ve uyarı (fırlatma) net. "Kusura bakma" görevini yapan ama kötü niyetli olmayan bir adamı anlatıyor.
- **`D6B_N_GULL`.** *Eski:* "Casus, koş! İzinsiz yakalanırsan zindan! O martı geçen hafta bir fermanı yedi!" → *Yeni:* **"Martı. İznin gitti. Koş, casus; kâğıtsız yakalanırsan seni yine bana getirirler, ben de yine yazarım."**
  *Neden:* İş aynı (koş; ceza zindan). Espri ödünç değil, bu adamın yorgunluğundan geliyor: sonuç yine onun defterine yazılacak. Bağırmasa da aciliyet var.
- **`D4B_N_GATE`.** *Eski:* "Dur! Kimsin sen? Ne getirdin? Casuslar hep bir şey getirir." → *Yeni:* **"Dur. Adın sonra. Cebinde ne var, önce onu göster."**
  *Neden:* Eşya seçimini açıyor. Önce ceplere bakmak tecrübeli bir kapı nöbetçisinin sırası.
- **`D4B_N_SPY`.** *Eski:* "Fes! Türk casusu! Yakaladım! Madalya alırım!" → *Yeni:* **"Fes. Türk casusu. Bu ay üçüncü. Öbür ikisi balıkçıydı."**
  *Neden:* "Fes + casus" sözleri Tolga'nın cevabı için korunuyor. Sevinç çığlığının yerinde bu yorgun adamın kuşkusu var. Kuşatmanın paranoyası da hissediliyor.
- **`D4B_N_CELL`.** *Eski:* "Zindan formu: adın, baban, fesinin rengi. Sabah konuşuruz." → *Yeni:* **"Zindan defteri. Adın, baban, fesin rengi. Acelesi yok, sabah yazarız."**
  *Neden:* Form esprisi yerinde, sonraki "kırmızımsı" satırları buna dayanıyor. "Acelesi yok" bu adamın ritmi.
- **`D6B_N_PERMIT`.** *Eski:* "…Logothetes Theodoros verir, en sondaki oda. Öbür altı odayla uğraşma, orada sadece mühür sayarlar." → *Yeni:* **"Kalacaksan Misafir İzni lazım. Theodoros verir, en sondaki oda. Öbür altı oda bugün yalnız mühür sayıyor. Sayar dururlar. Sen sona git."**
  *Neden:* Bütün yön bilgisi duruyor (izin, Theodoros, son oda, altı odayı atla). "Sayar dururlar" bürokrasiye otuz yıllık bir bakış.
- **`D6B_N_E_03`.** *Eski:* "İmparator diyor: mektup al, git, bir daha gelme." → *Yeni:* **"İmparator diyor: mektup. Sultan'a. Git."**
  *Neden:* Tercüme esprisi kişilikten geliyor: uzun ve nazik bir Yunanca rica, üç kelimelik bir emre iniyor. Ardından gelen `E_04` ("Aslında güzel bir şey dedi") bununla daha da iyi oturuyor.
- **`MG_HAG_NIKO_OPEN`.** *Eski:* "Kuzenimin kayığı. Kuzenim bilmiyor. Elli akçe, bir gün. Akşama geri getir, kuzen fark etmesin." → *Yeni:* **"Kayık kuzenimin. Kuzen bilmiyor, bilmesin. Elli akçe, bir gün. Akşama getir, kuzen nöbetten dönmeden."**
  *Neden:* Mini oyunun bütün bilgisi korunuyor (50 akçe, bir gün, akşam). Kuzen de nöbette: kuşatma her aileye girmiş.
- **`D6B_N_BYE`.** *Eski:* "Git, casus! Annene selam söyle! Annen hâlâ bir Ceneviz kayığı mı?" → *Yeni:* **"Git, casus. Dümdüz yürü, koşma. …Annene selam söyle."**
  *Neden:* Eski satırın "annene selam söyle" kısmı korunuyor ama ödünç hakaret düşüyor. Selam bu kez gerçek bir dilek. Yürüme talimatı 8Y'deki `RULES` repliğiyle aynı adamın ağzından çıkıyor.
- **`D24_NK_SAVED`.** *Eski:* "Çocuk kuru. Sen sırılsıklamsın, ben de. Ama çocuk kuru." → *Yeni:* **"Çocuk kuru. Otuz yıldır bu surdayım. Bu iyi bir gündü."**
  *Neden:* Hiçbir şeye şaşırmayan adamın tek değer yargısı, yayın sonu oluyor. (Eski metin de bu yöne uyuyor; seçim sahibin.)

**(e) Riskleri.**
- **Monotonluk:** 125 satırı alçak ve düz bir sesle dinlemek yorabilir. Çare: hız ve vurgu, duruma göre değişmeli (seslenme, tehlike, dua) ve okuma notunda yazmalı.
- **Fırlatma bölümünün enerjisi düşebilir.** Çare: `THROW_*` bark'ları yüksek ama sakin, kısa uyarılar olarak kalmalı ("Tavuk geliyor.", "Eğil.").
- **Ses tasarım aracı "elli yaşında, kuru" tarifini "yaşlı ve zayıf" diye okuyabilir.** Çare: tarifte "rough baritone" ve "trained sentry's call" sözleri tutulmalı; deneme metni bağıran değil, seslenen satırlardan seçilmeli.
- **Tavuk esprisinin oyuncuya olan çekiciliği azalabilir.** Ama tavuk kalıyor, yalnızca bir sebebi oluyor.

### 3c. Acemi nöbetçi: "Korkusunu sesiyle örtüyor"

**(a) Kim?** Niko yirmi yaşlarında, Petrionlu bir balıkçı kadının oğlu. Şehirdeki erkekler azaldığı için sura çıkarılmış; başındaki miğfer büyük, mızrağı ödünç. Bu, ilk gerçek gece nöbeti. Sesini yaşlı askerlerden duyduğu gibi kalın çıkarmaya çalışıyor, beceremiyor.
- **İstediği:** ciddiye alınmak, annesine gösterecek bir şey (madalya burada gerçek bir istek).
- **Korkusu:** karanlık, toplar, kimse görmeden ölmek.
- **Tolga'ya bakışı:**
  - 4'te **ilk casusudur**, gururla yakalar.
  - 6b'de onunla bir yetişkinle konuşur gibi konuşan **ilk kişi** olur.
  - 10H'de Tolga'yla zincir nöbetinde şarkı söyler.
  - 19–24 arasında bağırmayı bırakır; kuşatma onu büyütür.
- **Komedi kaynağı:** blöf ile dürüstlük arasındaki uçurum ("Okum var! …Yok, okum yok.").

**(b) Konuşma biçimi.**
- Uzun ve aceleci cümleler, kendini düzeltmeler, yarım kalan övünmeler.
- Tekrar ettiği söz: **"Ciddiyim!"**
- Korkunca Rumca kaçar: "Panagia mu!"
- Bağırır, çünkü korkuyordur. Korku geçince sesi bir anda normale iner. Bu iniş, karakterin asıl komedisi ve asıl kalbi.

**(c) Ses tarifi (EN).** *A Greek youth of about twenty, a fisherwoman's son from the Petrion quarter, given a helmet too big for him and his first real night watch on the walls; light, slightly reedy tenor that cracks upward when he bluffs, quick and breathless, light Greek accent in his market Turkish. Not a narrator, not an announcer, not a cartoon kid: a real scared young man recorded on the wall at night, trying to sound like the veterans. His loudness is fear, so it drops the moment he is not afraid.*

**Okuma notu.** Blöf yaparken yüksek ve hızlı konuşur, cümle sonunda sesi incelir. Kendini düzelttiği yerde normal konuşmaya düşer. Bölüm 6'dan sonra bağırmaz. Bölüm 19–24'te yaşından büyük ve sakin konuşur.

**(d) 12 replik.**

- **`D4B_N_01`.** *Eski:* "Hey sen, fesli! Annen bir Ceneviz kayığıydı!" → *Yeni:* **"Kim var orada?! Dur! Ben nöbetçiyim! Fesli! Kımıldama!"**
  *Neden:* Bağırmanın sebebi var: korkan bir acemi. Zincirde yürümek zorunda olan adama "kımıldama" demesi, durumun kendi komedisi.
- **`D4B_N_02`.** *Eski:* "Baban da kötü zeytinyağı kokardı! Buradan kokusu geliyor!" → *Yeni:* **"Okum var! …Yok, okum yok. Ama tavuğum var! Ciddiyim!"**
  *Neden:* Blöf ve itiraf tek satırda. Tavuk fırlatmanın sebebi bu kez de karakterden çıkıyor.
- **`D4B_N_03`.** *Eski:* "Gel bakalım, fesli. Surun dibi benim. Tavuğum da benim." → *Yeni:* **"Kapıya yürü, fesli! Ben buradayım! …Korktuğumdan değil, nöbet bu."**
  *Neden:* Yön veriyor. Kimse sormadan yaptığı savunma onu ele veriyor.
- **`D6B_N_GULL`.** *Eski:* "Casus, koş! İzinsiz yakalanırsan zindan! O martı geçen hafta bir fermanı yedi!" → *Yeni:* **"Martı kaptı! Koş, casus, koş! İzinsiz yakalanırsan zindan, beni de nöbetten alırlar!"**
  *Neden:* Aciliyet ve ceza aynı. Ödünç espri yerine Niko'nun kendi telaşı ve riski var.
- **`D4B_N_GATE`.** *Eski:* "Dur! Kimsin sen? Ne getirdin? Casuslar hep bir şey getirir." → *Yeni:* **"Dur! Kimsin? Ne getirdin? Elindekini göster, yavaş!"**
  *Neden:* Seçimi açıyor. "Yavaş!" korkan nöbetçinin sesi.
- **`D4B_N_SPY`.** *Eski:* "Fes! Türk casusu! Yakaladım! Madalya alırım!" → *Yeni:* **"Fes! Türk casusu! Benim ilk casusum! Annem inanmayacak!"**
  *Neden:* Madalya sevinci aynı enerjide kalıyor ama bu kez kimin için olduğu belli: annesi.
- **`D4B_N_CELL`.** *Eski:* "Zindan formu: adın, baban, fesinin rengi. Sabah konuşuruz." → *Yeni:* **"Zindan formu. Adın, baban, fesin rengi. Yazmayı yeni öğrendim, yavaş söyle."**
  *Neden:* Form esprisi korunuyor. Kapanıştaki itiraf karakteri gösteriyor.
- **`D6B_N_PERMIT`.** *Eski:* "…Öbür altı odayla uğraşma, orada sadece mühür sayarlar." → *Yeni:* **"Şehirde kalmak için Misafir İzni lazım. Theodoros verir, en sondaki oda. Öbür altı odaya girme; ben girdim, bütün gün mühür saydım."**
  *Neden:* Bütün yön bilgisi duruyor. Uyarı kendi başına gelmiş bir felaketten çıkıyor.
- **`D6B_N_E_03`.** *Eski:* "İmparator diyor: mektup al, git, bir daha gelme." → *Yeni:* **"İmparator diyor: mektubu Sultan'a götür. …Lütfen dedi, duydun mu?"**
  *Neden:* Tercümede komedi ve hayranlık bir arada. Yunanca aslı ("götürür müsün?") bir rica; genç nöbetçi İmparator'un nezaketine şaşırıyor.
- **`MG_HAG_NIKO_OPEN`.** *Eski:* "Kuzenimin kayığı. Kuzenim bilmiyor. Elli akçe, bir gün. Akşama geri getir, kuzen fark etmesin." → *Yeni:* **"Kuzenimin kayığı. Kuzenim bilmiyor. Elli akçe, bir gün. Akşama getir; yoksa annem beni öldürür, kuzenimi de."**
  *Neden:* Bilgi aynı. Esprinin hedefi kuzenden, karakterin asıl korktuğu otoriteye kayıyor: annesine.
- **`D6B_N_BYE`.** *Eski:* "Git, casus! Annene selam söyle! Annen hâlâ bir Ceneviz kayığı mı?" → *Yeni:* **"Git, casus! Sağ git! Seni ben yakaladım, unutma! Başkası yakalamasın!"**
  *Neden:* Sahiplenme, sevgi kılığına girmiş. Veda gerçek bir vedaya dönüşüyor.
- **`D24_NK_SAVED`.** *Eski:* "Çocuk kuru. Sen sırılsıklamsın, ben de. Ama çocuk kuru." → *Yeni:* **"Çocuk kuru. Bağırmadım bak, Tolga. Bütün gün hiç bağırmadım."**
  *Neden:* Yayın kapanışı karakterin en belirgin özelliğine (bağırmasına) dokunuyor. Büyüdüğünü kendisi fark ediyor.

**(e) Riskleri.**
- Ses tasarımında "genç ve bağıran" tarifi kolayca çizgi filme kayar; sahibin şikâyetinin tam tersi olur.
- Bölüm 4'te yine çok bağırma var. Sebebi olsa da sahip ilk dinleyişte aynı sorunu duyabilir.
- `D19`/`D24`'teki olgun replikler genç bir sesten inandırıcı çıkmayabilir.
- `D8Y_NIKO_RULES` gibi tecrübe isteyen satırların yeniden yazılması gerekir.
- 1453'te yirmi yaşında birinin bu kadar "acemi" olması (şehir bir yıldır hazırlanıyordu) tartışılabilir.

### 3d. Üç yön yan yana

| | (a) Esnaf | (b) Eski nöbetçi | (c) Acemi |
|---|---|---|---|
| Yaş / tını | ~38, orta, hafif kısık | ~50, alçak, kuru bariton | ~20, ince tenor, çatlayan |
| Bağırma | Yok; ses taşır | Yok; nöbetçi çağrısı | Var; sebebi korku, sonra biter |
| Komedinin kaynağı | Her şeye fiyat biçmesi | Saçmalık karşısındaki düzlüğü | Blöf ile dürüstlük arasındaki uçurum |
| İstek / korku | Kese ve kayık / elinde bir şey kalmaması | Uyku ve maaş / "bu sefer geçmeyecek" | Ciddiye alınmak / karanlık, ölüm |
| Var olan iyi repliklerle uyum | Orta | **Yüksek** (8Y, 19, 24 zaten böyle) | Düşük (19, 24, 8Y yeniden yazılmalı) |
| Sahibin "asker gibi" isteği | Zayıf | **Güçlü** | Orta |

---

## 4. Öneri ve iş planı

### 4.1 Neden (b)?

1. Sahibin iki notu var: "Diyaloglarını da beğenmedim" ve "spiker gibi olmasın, oradan bir asker gibi hissettirsin". İkisini de en doğrudan (b) karşılıyor: ses ve metin aynı yönde, yerinde duran gerçek bir nöbetçiye doğru değişiyor.
2. Değişiklik en küçük (b)'de. Oyunun en iyi Niko satırları (§2'deki korunacaklar) zaten bu adamın ağzından yazılmış; değişecek olan, giriş sahnelerindeki skeç kalıbı. (c) bu iyi satırların çoğunu da yeniden yazdırır.
3. Kadro dengesi: Urban, Kadri, Hasan ile Hüseyin ve Tolga'nın kendisi zaten yüksek perdeden konuşuyor. Bizans tarafındaki tek "halk" sesi alçak ve kuru olursa, İmparator'un vakarı ile Theodoros'un titizliğinin arasına sahici bir asker yerleşir.
4. (a)'dan alınacak damar: kuzenin kayığı ve maaş motifi (b)'nin içinde seyrek kalsın. Pazarlık mini oyunu bu damarla yazılır.

### 4.2 Kalan ~113 repliğin yeniden yazımı (yön b)

Etiketler: **AYNEN** = metin kalır, yalnız yeni sesle yeniden üretilir · **DOKUNUŞ** = bir iki söz ya da sondaki espri değişir · **BAŞTAN** = aynı işi gören yeni metin.

| Grup | Anahtarlar | Karar | Not |
|---|---|---|---|
| 4b zincir/rıhtım varyantları | `D4B_N_01_NOFEZ`, `D4B_N_03_NOFEZ` | BAŞTAN | Örnek 12'nin fessiz eşleri ("Kim var orada? …Şapkasız. Zincirde…") |
| Fırlatma | `D4B_N_THROW_CHICKEN_1…4`, `_SACK`, `_SHIELD` | BAŞTAN (kısa) | Bağırma değil uyarı: "Tavuk geliyor. Eğil." / "Yine o tavuk." / "Geri geldi. …Olur." / "Son tavuk. …Nereye gidiyorsun sen?" `SACK` incir, `SHIELD` "Hektor'un" sözünü korumalı (Tolga'nın `D4B_T_HIT_2`, `_SHIELD` cevapları) |
| Tutulma | `D4B_N_ECLIPSE_1/2/3` | DOKUNUŞ | Bilgi ve kehanet kalır. `[shouting]` kalkar; korku fısıltıyla ve bir "Panagia" ile verilir. 2 ve 3'ün ünlemleri azalır. "Hodegetria" yazımı "Hodegetriya" olur (TTS) |
| Kapı | `D4B_N_CHICKEN`, `D4B_N_HAT`, `_HAT_NOFEZ` | DOKUNUŞ | "Tavuk hep yanlış adamı seçer" yerine "Tavuk seni seçmiş. Tavuk bilir." gibi bir söz. `HAT` aynen kalabilir |
| Sonuç 4b.1/4b.2 | `D4B_N_SPY2`, `D4B_N_MERCHANT`, `_MERCHANT2` | DOKUNUŞ | `SPY2`'deki "önce gezdiririm" nedenlenir: "Defter sabah açılır. O vakte kadar benimlesin." |
| Bilgi | `D4B_N_ISTANBUL` | AYNEN | İyi, bilgi taşıyor |
| Hücre | `D4B_N_CELL_NOFEZ`, `D4B_N_CELL2` | DOKUNUŞ | `CELL2` "İyi yüzüyorsun. Casus için." korunabilir: düz söylenince işliyor |
| Eşya tepkileri | `D4B_NIKO_*` (10) = `REACT_NIKO_*` (11) | DOKUNUŞ, tek yazım iki anahtara | `CHICKPEAS` ve `LIGHTER` aynen. `PHONE` ("Annen de mi ayna?" hakaret kalıbı) BAŞTAN. `SELFIE` ve `REACT_*`'teki parantez notları `[TON]`'a taşınır. `REACT_NIKO_LIGHTER` içindeki Tolga cümlesi ayrı konuşmacıya (`_s1`/`_s2`) bölünür |
| Tekrar oynayan | `REACT_NIKO_REPLAY_1…5` | DOKUNUŞ | Fikirler iyi; yalnız ton (2: tavuk, 4: rüya kalır) |
| 6b yön | `D6B_N_CALL`, `D6B_N_NOT_YET`, `D6B_N_HINT` | DOKUNUŞ | `CALL`'daki "tavuk bile gezemez" esprisi ve ünlemler azaltılır; iş aynı. `HINT` aynen |
| 6b çatı | `D6B_NK_ROOF` | BAŞTAN | "Ben yazdım" esprisi yerine "İn oradan. Kiremit kırılırsa onu da bana yazarlar." |
| 6b sabah/zindan | `D6B_N_CELL_MORNING(_NOFEZ)`, `D6B_N_DUNGEON(_FIRST)(_NOFEZ)` | DOKUNUŞ | "Kırmızımsı" ve "Şapka: yok" **korunur**, çünkü oyunda 30 anahtar buna bağlı (Tolga'nın `D7_T_CELL*` alıntıları; Nihat'ın `D7_N_TRACE_CELL*`, `D14_NN_2`, `D15_N_N3` raporları). Ama dört varyantta tek cümleye iner ve sondaki ikinci espri ("Yok da bir renktir") kalkar |
| 6b martı | `D6B_N_MISS` | BAŞTAN | "Yavaşsın, sigortacı. Martı bekliyor." (Not: Niko'nun bu bölümde "sigortacı" demesi hitap yayını bozar; "casus" olmalı) |
| 6b huzur | `D6B_N_E_01`, `_E_01_NOCHICK` | DOKUNUŞ | Tercüme kısalır: "İmparator soruyor: kimsin. …Bir de niye tavuk kokuyorsun." |
| 6b huzur | `D6B_N_E_04` | AYNEN | Korunacaklardan |
| 6b dost | `D6B_N_FRIEND` | DOKUNUŞ | "Yarısı yalandı ama iyiydi" kalabilir; ünlem düşer |
| Pazarlık | `MG_HAG_NIKO_LOW/FAIR/SWEET/NOSWEET/DEAL/WIN/LOSE` | BAŞTAN | Kuzen esprisi altı kez tekrarlanıyor. Bir kez kalsın; öbürleri kıtlık, maaş ve kayığın değeri üstüne kurulsun. Tepkilerin işi (düşük, makul, övgü, anlaşma) aynı kalır |
| 7 | `D7_NIKO_HELLO`, `_LIE`, `_CELL*` (4), `_OUTSIDE`, `_AGAIN`, `D7_EAVES_*` (2) | DOKUNUŞ | `LIE` ("İmparator'la çay içiyorlar") dostun yalanı olarak iyi; tonu düzleştir. `OUTSIDE`'daki "Benim havlum" kalır (8Y'ye bağlı) |
| 7 | `D7_AWE_NIKO`, `D7_NIKO_AWE_TRUTH` | AYNEN | |
| 8Y | `D8Y_NIKO_*` (12) | AYNEN (11), DOKUNUŞ (`SINERJI_N`) | Zaten (b) yönünde yazılmışlar |
| 10H | `D10H_N_1`, `_PEAS`, `_DONE`, `_NOPEAS(_NEW)` | AYNEN / küçük DOKUNUŞ | `_PEAS`: "Belki bir daha hiç uyumayacak" kalsın |
| 10H | `D10H_N_K`, `_K_ALT` | DOKUNUŞ | Soru ve iş aynı, ünlem azalır |
| 11 | `D11_NK_00`, `_01`, `_01_HEN`, `_03` | DOKUNUŞ | Büyük harfli "CASUS! … SALDIR!" çığlığı TTS'de de bozuluyor. "Sinerji. Ela." / "Koş, casus. Bu adamı ben oyalarım. Defterini de ben yazarım." Sahnenin işi aynı (11.6) |
| 13 | `D13_N_MISSED`, `_STRANGER` | AYNEN | |
| 19 | `D19_NK_01`, `_TEZKIRE`, `_02` | AYNEN | `_01`'in heyecanı biraz düşebilir |
| 20 | `D20_NK_01`, `_DROP` | AYNEN | Burası, Niko'nun "Tolga" dediği ilk yer olarak bilinçli işaretlenmeli (§4.4) |
| 24 | `D24_NK_01`, `_GUST`, `_KID`, `_LATE`, `_SAVED` | AYNEN (`_SAVED` için §3b'deki seçenek) | |

Toplam (12 örnek dışında, yaklaşık): AYNEN ~35 · DOKUNUŞ ~55 · BAŞTAN ~23.

Ses tarafı (ayrı onayla):
- `docs/voice/cast.json`'daki `SPK_NIKO.design` ve `tarif`, §3b'deki tarifle değiştirilmeli. "Loud, booming, jovial" kalırsa metin değişse de ses aynı yere döner.
- Ses tasarımı deneme metni (`design.json`'daki `text`) şu anda iki bağırma satırından oluşuyor. Bunun yerine bir seslenme, bir düz konuşma ve bir yumuşak satırdan kurulmalı. Örnek: `D4B_N_01` (yeni), `D8Y_NIKO_RULES`, `D19_NK_02`.
- `[shouting]` etiketleri `VOICE_MAP.csv`'de yalnızca gerçekten seslenilen satırlarda kalmalı.
- Üretimden önce `docs/voice/INLINE.json`'da Niko anahtarı olup olmadığı kontrol edilmeli (CLAUDE.md'deki tuzak).
- `yeni_diyaloglar_dogal.txt` ve `yeni_diyaloglar_elevenlabs_tts.txt`'deki Niko metinleri bu yönle çelişiyor; Niko için kaynak olarak kullanılmamalı.

### 4.3 Tolga'nın (ve başkalarının) uyum için değişmesi gereken replikleri

Sahip yalnızca Niko'nun repliklerine izin verdi; aşağıdakiler **ayrıca sorulacak**. Yön (b) seçilirse ve §4.2'deki dayanaklar (fes + casus, "kırmızımsı", incir, "Hektor", "Genelde.") korunursa Tolga'nın **zorunlu** değişikliği yok. Önerilenler:

| Anahtar | Konuşan | Neden | Önerilen |
|---|---|---|---|
| `D9_T_DEPORTED` | Tolga | "Kapıdan itti" sözü, 8Y'de kapıya kadar götüren Niko ile çelişiyor | "…Kapıya kadar götürdü. Gerisini bana bıraktı." |
| `D24_T_NK_01` | Tolga | "Sen de beni güldürme": yeni Niko şaka yapmıyor. Yine işler (düzlüğü güldürüyor) ama ince ayar istenebilir | "…Sen de bir şey deme; dersen gülerim." |
| `REACT_NIKO_LIGHTER` | Tolga + Niko | Tek anahtarda iki konuşmacı; Tolga'nın cümlesi Niko'nun sesiyle okunur | Satır `_s1`/`_s2` diye bölünmeli (metin değişmeden) |
| `REACT_EMPEROR_COLOGNE` | Niko (İmparator anahtarında) | Niko cümlesi İmparator'un anahtarında | Bölünmeli; Niko kısmı (b) tonuyla |
| `D4B_T_HIT_2_CHICKEN` | Tolga | Yalnız fırlatma bark'ları "Hektor"/incir dışında değişirse | Şimdilik değişmez |
| `D7_T_CELL*` (4) | Tolga | Yalnız "kırmızımsı" ya da "Şapka: yok" kaldırılırsa | Önerim: kaldırmayın; o zaman değişmez |
| `D11_N_NK_02`, `_04` | Nihat | `D11_NK_*` sakinleşirse Nihat'ın "şapkamda tavuk" esprisi aynen işler | Değişmez |

### 4.4 Kapsam dışı ama gerekli (ayrı karar)

- **Adın öğrenilmesi:** Niko'nun "casus"tan "Frenk"e, oradan "Tolga"ya geçişi oyunda kendiliğinden oluşmuş en güzel yay. Bir tek satırla kurulabilir: 10H'de Tolga leblebiyi verirken adını söyler, Niko 20'de ilk kez kullanır. Bunun için yeni bir anahtar gerekir.
- **Kayboluş:** Perde IV'te Niko hiç yok. `BYZANTINE_MIRROR.md`'deki 32B (Niko'nun ateşi: incir / söz / sus) ve 38B (anne Petrion'da, kuzenin kayığı) sahneleri (b) yönüyle doğrudan uyumlu. Yazılmaları, Niko'ya 24'te yarım kalan vedasını verir. En azından 24'ün sonuna tek satırlık bir ayrılık ("Ben Petrion'a, anneme. Geçer, Tolga. …Geçer.") eklenebilir. Bu da yeni bir anahtar ve bir betik değişikliği demek.
- **Ünvan:** `D6B_N_MISS`'teki "Sigortacı" hitabı, Niko'nun bu bölümde Tolga'yı ne bildiğiyle çelişiyor (§4.2).

---

*Hazırlayan notu: 12 örnek replik üç yönde de uzunluk (eski metnin %60–140'ı), rakam ve parantez açısından betikle denetlendi. Her biri, anahtarın betikteki işini (yön, uyarı, seçim açma, sonuç, bayrak) korur. Hiçbir bayrak, koşul ya da akış değişmez.*
