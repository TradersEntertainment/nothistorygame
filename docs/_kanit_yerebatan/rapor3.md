# Bölüm 44 Sarnıç — 3. tur (ikinci denetimin §7 zorunlu düzeltmeleri)

Dal `wip/bolum-yerebatan`. Taban (ÖNCE): denetlenen kayıt `888a070a`. Denetim: `origin/wip/denetim2-yerebatan:docs/_kanit_denetim2_yerebatan/rapor.md`
(HAYRANLIK 8, HEYECAN 6, KÜÇÜK DÜZELTMELERLE KABUL).

**Kanıt yöntemi.** İki ekranlı koşu, aynı ayar: `PACE=1 RINFO=1 xvfb-run 1280x720 … --chapter=44b --autotest --dialogshots --shotevery=1 --snapevery=0.5 --hitchaudit`.
ÖNCE: `888a070a`'nın depo dışı kopyası (`git worktree`), 1044 kare. SONRA: son kod (`6e97068c`), 979 kare. Kamera oyuncu kamerasıdır (bot oynar);
sonda karesi kanıt olarak KULLANILMADI (yalnız ayar için geçici bir sonda kullandım, silindi: `grep -rn _sonda44 scripts tests` → boş).
Kareler zaten **640×360** kaydediliyor: aşağıdaki "640×360'ta okunur mu" yargıları doğrudan bu karelere bakılarak verildi.
Kare adı `tNNNN` = koşunun 0,5 sn'lik karesi; `D44B_…` = o replik ekrana geldiği anın karesi (aynı replik karesi ÖNCE | SONRA eşleşmesi bunlarla).
İki koşunun zamanlaması birkaç saniye kayar (balık olayı, biniş, Medusa yakın bakışı değişti); `t` numaraları bu yüzden birebir aynı değil, aynı an
replik karesine ya da olaya göre hizalandı.

## Madde madde

| # | Madde | Durum | ÖNCE kare | SONRA kare | Pafta |
|---|---|---|---|---|---|
| 1 | Kiler | **DÜZELDİ** | `D44B_T_CLIMB`, `t0974` | `D44B_T_CLIMB`, `t0870` | `t3_p01_kiler` |
| 2 | Siyah payeler | **DÜZELDİ** | `t0255`, `t0345`, `t0745` | `t0262`, `t0330`, `t0745` | `t3_p02_payeler` |
| 3 | Medusa okunurluğu | **DÜZELDİ** (yakın bakışta); geniş kadrajda KISMEN | `D44B_Y_STONE`, `D44B_T_MEDUSA_1`, `t0862` | `D44B_Y_STONE`, `t0807`, `t0815` | `t3_p03_medusa` |
| 4 | Tırmanış | **DÜZELDİ** | `t0950`, `t0958`, `t0966` | `t0858`, `t0864`, `t0868` | `t3_p04_tirmanis` |
| 5 | Balık sürüsü | **DÜZELDİ** | `t0292`, `t0296` | `t0292`, `t0298` | `t3_p05_balik` |
| 6 | Metin (10 anahtar) | **DÜZELDİ** | `D44B_E_01`, `D44B_Y_03`, `D44B_N_MEDUSA` | aynı anahtarlar | `t3_p06_metin` |
| 7a | İniş: yatık, zeminsiz sütunlar | **KISMEN** | `t0110`, `t0118` | `t0116`, `t0124` | `t3_p07_inis_binis` |
| 7b | Biniş: 0,3 sn yumuşak geçiş | **DÜZELDİ** | `t0198`, `t0199` (kararma) | `t0217`, `t0218` | `t3_p07_inis_binis` |
| D7 | Kürek mili / turuncu levha | **DÜZELDİ** (kaynak bulundu: enkaz) | `t0640`, `t0652`, `t0670` | `t0642`, `t0648`, `t0654` | `t3_p08_D7_enkaz` |
| D8 | Avluda konuşanlar kuyunun arkasında | **DÜZELDİ** | `D44B_E_BACK`, `D44B_TW_DJINN` | aynı anahtarlar | `t3_p09_D8_avlu` |
| — | Korunan anlar (sütun ormanı, gün ışığı doruğu, gözyaşı sütunu) | **KORUNDU** | `D44B_T_AWE_2`, `t0658`, `t0712` | `D44B_T_AWE_2`, `t0624`, `t0684` | `t3_p10_korunan` |

### 1. Kiler — DÜZELDİ
- Kök neden: tırmanış sonunda bakış güneye, düz sıva duvara ve parlaklığı 1,2 olan beyaz kapı düzlemine çevriliyordu; küpler batı duvarında, fıçı
  kuzeydoğuda, yani kadrajın dışındaydı.
- `scripts/level/cistern.gd:_build_cellar` baştan yazıldı: tek tek renkli **döşeme kalasları**, **kuyu bileziği** ve yana çekilmiş kapağı, nemli alt bandı olan
  sıva ve **ahşap dikmeler**, **tavan kirişleri**, batıda **iki raf, on turşu küpü** (sırlı ağızlı), kuzeyde **sarımsak/soğan örgüleri** ve **çuvallar**,
  güneybatıda **fıçı**, güney duvarında **çerçeveli, kanadı içeri açık kapı**; kapının ardı beyaz düzlem değil kısık, gölgelendirilmiş bir avlu
  görünümü (taş zemin, karşı duvar, gök şeridi), döşemeye düşen gün ışığı lekesi ve kapının yanında ayrı bir gün ışığı (`_cellar_door_light`).
- `scripts/chapter44b.gd:_climb`: kilere çıkınca oyuncu bileziğin kuzeydoğusuna basar ve güneybatıya, hafif aşağı bakar: sağda raflar ve küpler, ortada
  bilezik ve fıçı, solda açık kapıdan avlu. "Kırk basamak… turşu kokusu" bu kadrajda söylenir.
- 640×360'ta: küpler, raf, fıçı, kapı ve bilezik açıkça seçiliyor (`D44B_T_CLIMB`). Yanmış beyaz dikdörtgen yok.

### 2. Siyah payeler — DÜZELDİ
- Kök neden (sondayla ayırt edildi): siyah dikdörtgenler gerçek payeler değil, **su altındaki yansıma kopyasındaki** payelerdi. Aynalanmış ağda
  `cull_front` payenin ön yüzünü ayıklıyor, **duvara yapışık arka yüzünü** (normali duvarın içine bakan, ışıksız) bırakıyordu: su çizgisinin altında
  1 m genişliğinde kapkara dikdörtgenler.
- `cistern.gd:_brick_cull`: yansıyan duvar kopyası iki yüzlü çizilir (`cull_disabled`; normal `FRONT_FACING` ile kameraya döner, derinlik sınaması
  öndeki yüzü seçer). Tonozun yansıması değişmedi. Ek: duvar ve payelere hafif dolgu (`EMISSION = col * 0.07`), gölgede de tuğla okunsun.
- SONRA'da ilk kürek, Nihat'ın şıpırtı repliği ve sarsıntı küreği karelerinde su çizgisinde siyah dikdörtgen yok (`t3_p02`). Çizim çağrısı artmadı.

### 3. Medusa — yakın bakışta DÜZELDİ, geniş kadrajda KISMEN
- Başlar yükseltildi: yüzün ortası su yüzünün 0,84 m altında (önce 1,2 m), bloğun tepesi su yüzünün 4 cm altında (`cistern.gd:MEDUSA_Y`); bloğun altına
  taş kaide (boşlukta durmasın).
- Kayık 3,3 m'ye yanaşır (önce 4,4). Tespit karesinde telefon **yakınlaştırır** (görüş açısı 72° → 36°, `chapter44b.gd:MEDUSA_FOV`, `_zoom`);
  "Biri yan, biri ters" repliğinde bakış önce yan yatık başa, 2,4 sn sonra ters başa döner (`_turn_later`), sonra geniş kadraja ve 72°'ye geri.
- Kandil iki başın ARASINA ve hemen önüne alındı: yüzlere yandan (sıyırarak) vurur. Yüz gölgelendiricisinde göz çukuru gölgesi, göz bebeği oyuğu,
  burun delikleri, ağız yarığı ve kaş altı koyulaştırıldı (`_medusa_mat`).
- Ölçü (640×360, SONRA `t0807` yan baş, `t0815` ters baş): yüz ovali ≈ 115 px / 640 ≈ **%18** (yılan saç halkasıyla ≈ 150 px, %23); ölçüt (≥ %15) tutuyor. Göz, burun, ağız
  seçiliyor; yan baş ile ters baş ayrı karelerde ayırt ediliyor.
- Su: dairesel sert kesik ve "kuru çukur" kalktı. Çamur tabanı kenarı saydamlaşan bir yüzey; yansıma kopyası berrak bölgenin kenarında ekran titreşimiyle
  (dither) yumuşakça geri gelir; berrak bölgede su en az %55 örtücü kalır (su olarak okunur).
- **KISMEN kalan:** geniş kadrajda (iki baş birlikte, `D44B_Y_STONE`, `D44B_N_MEDUSA`) her yüz ≈ %11–12; göz ve ağız seçiliyor ama ölçütün %15'i bu
  kadrajda tutmuyor. Botun tespit karesi 0,5 sn'den kısa sürdüğü için yakınlaştırılmış tespit anının kendi karesi koşuda yakalanmadı (KANITSIZ);
  aynı yakınlaştırma replik anında görülüyor (`t0807`, `t0815`).

### 4. Tırmanış — DÜZELDİ
- "Yumurta" lekesi telefonun spotuydu (bacanın taşına 0,5 m'den vuruyordu). Tırmanışta fener cebe girer; bacayı yukarıdaki kilerin ışığı ve ağızdan inen
  ışık kartı aydınlatır. Demir basamaklar açık, paslı renkte, kalın ve dayanaklı.
- İp merdiven ayrı ağ: Medusa'ya bakarken kadrajın ortasında durmasın diye gizli, tırmanma hedefi gelince salınır (`cistern.gd:ladder_down`).
- SONRA `t0858` (ip merdiven), `t0864` (bacada basamak dizisi), `t0868` (kilerin ağzı: raf, küp, sarımsak örgüleri). 640×360'ta basamaklar okunur;
  leke yok. Bacanın alt yarısı koyu (bilerek: ışık yukarıdan gelir).

### 5. Balık sürüsü — DÜZELDİ
- İki kök neden: (a) balık ağı yatay iki üçgendi, yatay bakışta ince çizgi oluyordu; (b) yol dünyaya sabitti, kayık 2,6 m/sn giderken sürüyü hemen sol
  arkada bırakıyordu (ilk SONRA koşusunda bu yüzden yine kadrajın kenarındaydı; düzeltildi).
- `cistern.gd:carp_mesh`: yassı sazan gövdesi (45 cm, yandan okunur), dikey kuyruk ve sırt yüzgeci. `chapter44b.gd:_ev_fish`: 14 balık, yol **kayığa
  göre** her karede hesaplanır: soldan pruvanın 4 m önüne, ortada 3,6–3,8 m, sonra kayığa kıvrılıp altına dalar; **beş balık sıçrar** (halka + şıpırtı);
  Tolga'nın "Altımdan bir şey geçti" repliği sürü altına daldıktan sonra.
- 640×360'ta (SONRA `t0290–t0300`): sürü kadrajın ortasında, ≈ 80–100 px genişlikte (**%12–15**), sıçrayan balıklar tek tek seçiliyor. Not: sürü kürek
  ibresinin hemen üstünden/üzerinden geçiyor (ibre bir kısmını örtüyor, sürü yine okunuyor).

### 6. Metin — DÜZELDİ (yalnız bu bölümün yeni replikleri)
- On anahtar yeniden yazıldı (`D44B_E_01`, `D44B_Y_02`, `D44B_T_DARK`, `D44B_T_ROPE`, `D44B_T_AWE_3`, `D44B_Y_03`, `D44B_N_QUAKE`, `D44B_T_HIT_1` (yalnız EN),
  `D44B_Y_KEEP`, `D44B_N_MEDUSA`); Türkçesi Türkçe, İngilizcesi İngilizce kuruldu; espri notları `yeni_replikler3.txt`'te.
- `D44B_E_01`: Eudokia "Büro"yu söylemez, Tolga'yı "saraydaki tercüman" diye bilir (`D25_E_CISTERN_2` "Saraylı tercüman" ile tutarlı), adını tam
  bilmez ("Tolga mıydı, Dolga mıydı, neydi adın…"). Sonraki `D44B_E_BACK` "Tolga!" bu yüzden tutarlı.
- `i18n/strings.csv` ve `docs/voice/VOICE_MAP.csv` birlikte (VOICE_MAP CRLF korundu; `git diff --numstat`: 10/10 her iki dosyada), `yeni_replikler.txt`
  de CSV ile eşitlendi. **Derlenmiş çeviri dosyaları** (`i18n/strings.tr.translation`, `.en.translation`; depoda izleniyor) yeniden içe aktarılarak
  güncellendi: ilk SONRA koşusunda altyazılar eski metni gösteriyordu, bu yüzden. Son koşuda yeni metin ekranda (`t3_p06`).
- `tests/check_keys.py` (6902, 0 sorun), `check_speakers.py` PASS, `check_voice_rules.py` PASS (9781, 0), `check_inline.py` PASS (723, 0).
- Başka bölümün hiçbir repliğine dokunulmadı. Ses üretilmedi.

### 7a. İniş — KISMEN
- Yapılan: aşağı dönüş dik değil; ağız tonoza açılınca bakış ufka döner (-12°); bu sırada ortam ışığı hafifçe açılır (0,38), suya düşünce yeniden
  karanlık (hayranlık anı korunur).
- Sonuç: denetçinin gördüğü "yatık, zeminsiz, boşlukta asılı" sütunlar kalktı (SONRA `t0116` tonoz kemeri ufka yakın, `t0124`). **Ama** bu 2–3 sn'lik
  kesitte kare çok karanlık: sütunlar ve su silik, "boşluk" duygusu bu kez karanlıktan geliyor. İyi bir "suyun üstünde sütunlar" görüntüsü yok.
  Yapılmadı sayılmaz ama DÜZELDİ demiyorum.

### 7b. Biniş — DÜZELDİ
- Kararma yok: kamera 0,3 sn'de kayıktaki oturağa süzülür, bakış kayığın burnuna döner (`_to_boat`). ÖNCE `t0198–t0199` iki kare kararma; SONRA `t0217`
  geçiş, `t0218` kayıkta. Kararma karesi yok.

### D7. Kürek mili ve "devasa turuncu levha" — gerçek, DÜZELDİ
- Denetçinin karesindeki "turuncu levha" ve "gri silindir" **kayığın kendisi değil**: çöküşte kayığın 2–3 m yanına düşen tonoz parçaları (düz
  renkli kutu, gün ışığında turuncu) ve devrilen sütun tamburuydu (ÖNCE `t0640–t0682` boyunca kadrajın altında). Parçalar artık örme tuğla
  dokulu (`cistern.gd:brick_mat`), suya gömülü (sırtı ≈ 15 cm), tambur da yarı batık (`_fall_slab`, `_fall_drum`). SONRA `t0642–t0654`.
- Ayrıca gerçek bir ikinci kusur buldum: ortak `OarGrip` kürekleri dünya ekseninde tutar; kayık 2°'den çok **yan yatınca** kürek mili borda
  tahtasının içinden geçer. Ortak dosyaya dokunmadan `chapter44b.gd:_boat_place`'te yan yatma 0,02 rad ile sınırlandı; sarsıntı baş-kıç salınımı
  ve dikey çalkantı olarak verilir. Sarsıntının hissi kareden ölçülmedi (KANITSIZ: yalnız kod).

### D8. Avlu sonu — gerçek, DÜZELDİ
- ÖNCE: Eudokia ve komşular kuyunun çatkısının tam arkasında, ayakları bilezikte gizli. SONRA: konuşanlar oyuncunun önünde, kuyunun solunda bir yay
  üstünde (3–3,6 m); dördü de boydan görünüyor, kuyu kadrajın solunda (`_yard_end`, `t3_p09`).

### Korunan anlar
- Sütun ormanı (`D44B_T_AWE_2`), çöküş + gün ışığı doruğu (SONRA `t0624`), gözyaşı sütunu (`t0684`) aynen duruyor (`t3_p10`). Sarsıntı sayacı, süreler,
  sonuçlar değişmedi; gizli süre eklenmedi.

## Kendi karelerime bakınca hâlâ kötü olanlar
1. **İniş (7a):** tonoza açılış kesiti çok karanlık (`t0116–t0130`); sütunlar artık yatık değil ama "suyun üstünde orman" da görünmüyor.
2. **Medusa geniş kadrajı:** iki baş birlikteyken yüzler ≈ %11–12; özellikler ancak yakın bakışta (36°) rahat okunuyor. Yüzde kandilin parlak bir
   yansıma lekesi var (`t0815` yanak).
3. **Balık sürüsü kürek ibresinin üstünden geçiyor:** sürü okunuyor ama ibre çubuğu sürünün altını kesiyor (`t0294–t0298`).
4. **Tırmanışın alt yarısı** (ip merdiven, tonoz içi) koyu; basamaklar siluet olarak okunuyor (`t0858`).
5. **Çöküş enkazı** suya gömülünce yosun bandının yeşiline boyandı; tuğla dokusu uzaktan "yeşilimsi kütle" gibi duruyor (`t0648`).

## Testler (son kod, başsız `--max-fps 20`)
- 44b: `""`, blab, dark, kid, nophone, hit → **6/6 PASS** (son kodla; ayrıca iki ara turda da 6/6). `hit`: 3 isabet, ışık bulundu; olay günlüğü
  `fish, far_shot, splash, collapse, sun, hen_eye` (dark'ta hen_eye yok: tasarım gereği).
- Komşular: 24 `""`, late, niko, niko_slow, eclipse (5/5); 25 `""`, caught, pass, kid, cistern, cistern_blab, osm (7/7); 43o `""`, bad, miss, dive (4/4);
  12b `""` (1/1) → **17/17 PASS**. (Komşular kod değişikliklerinin ortasında koşuldu; o noktadan sonra değişen yalnız 44b'nin kendi dosyaları.)
- Yasak satırlar (`SCRIPT ERROR`, `WARN_*`, `VISAUDIT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `LOOKAUDIT backturn`, `JOURNEY_*`): bütün başsız ve üç ekranlı
  koşuda **0**. `parse_check` PASS (250 betik).
- Sarnıçta aynı anda görünür ışık en çok **7** (Medusa; önceki gibi), tırmanışta spot kapalı, kiler ışığı + kapı ışığı.

## Performans (RINFO, ekranlı koşular, yalnız sarnıç örnekleri)
| | örnek | çizim ortanca / en çok | üçgen ortanca / en çok |
|---|---|---|---|
| ÖNCE `888a070a` | 56 | 269 / 468 | 571K / 605K |
| SONRA `6e97068c` | 57 | 274 / 454 | 572K / 606K |

Aynı evreye hizalı üç örnek (t, çizim, üçgen K; sarnıç kesitinin %15 / %50 / %90'ı: iniş-hayranlık, kürek-sarsıntı, Medusa-tırmanış):
ÖNCE (38, 203, 572) (77, 223, 560) (123, 415, 599) · SONRA (38, 274, 594) (79, 223, 560) (124, 382, 568).
Sarnıçta çizim ≤ 454 (≤ 600 ✔), üçgen ≤ 606K (≤ 1,5M ✔; her evrede artış ≤ %4 ✔). **Çizim:** ortanca +5 (+%2), en çok −14; ilk evre örneğinde
+71 (bakış yönü bir koşudan ötekine farklı; kalıcı yeni ağlar: ip merdiven, kapı görünümü, gün ışığı lekesi yalnız kiler/tırmanışta). "Çizim artmaz"
kuralı ortancada küçük bir artışla (+%2) KISMEN tutuyor. 60 FPS: yazılım çizimi (llvmpipe), KANITSIZ.

## Değişen dosyalar
`scripts/chapter44b.gd`, `scripts/level/cistern.gd`, `i18n/strings.csv`, `i18n/strings.tr.translation`, `i18n/strings.en.translation`,
`docs/voice/VOICE_MAP.csv`, `docs/_kanit_yerebatan/yeni_replikler.txt`, `yeni_replikler3.txt`, bu rapor ve paftalar `t3_p01…t3_p10`.
Ortak dosyaya dokunulmadı (`oar_grip.gd`'deki yan yatma sorunu bölüm tarafında çözüldü). Kanca/sonda kalmadı.

## ORTAK DOSYA ÖNERİSİ (uygulanmadı)
`scripts/*/oar_grip.gd:_process` kürek yönünü dünya ekseninde hesaplıyor; tekne yan yatınca mil bordaya giriyor. Öneri: yönü teknenin yerel
eksenine göre kurmak:
```gdscript
# hd hesaplandıktan sonra, _pose'dan önce:
var up := _boat.global_transform.basis.y.normalized()
var u := (hd * cos(asin(sa)) + up * sa).normalized()
```

## Bakamadıklarım
Ekranlı `dark`, `blab`, `kid`, `nophone`, `hit` (yalnız başsız PASS); 44.2 sonu kareleri; ses; İngilizcenin anadil okuması; gerçek oyuncunun
(bot dışı) tespit karesi anı; 60 FPS.
