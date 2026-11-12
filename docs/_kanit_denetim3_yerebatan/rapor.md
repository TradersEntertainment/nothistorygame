# Denetim 3 — Yerebatan Sarnıcı (bölüm 44b) — Bağımsız denetim raporu

Dal `wip/denetim3-yerebatan` (taban `wip/0.99.119`). Oyun dosyalarına dokunulmadı; yalnız bu klasör eklendi. Godot 4.4.1 resmi linux x86_64 (`~/is/godot`), `xvfb-run` + `--rendering-driver opengl3`, 1280×720.
Önceki raporlar (`docs/_kanit_yerebatan/`) yalnız bağlam için okundu; aşağıdaki her yargı bu koşunun kendi karelerine / günlüğüne dayanır.

**Özet:** Hayranlık **8/10**, Heyecan **6/10**. **HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL.** Yayına engel 4 madde var (Z1–Z4); üçü metin/akış düzeyinde, hepsi küçük.

Ortam notu: ses cihazı yok (Godot "dummy" sürücüsü), yani **ses dinlenmedi**; yalnız ölçüldü ve oyunun gerçekten çalmaya kalktığı günlükten doğrulandı. Ekran kartı yok (llvmpipe yazılım çizimi), bu yüzden **gerçek kare hızı ölçülemedi** (aşağıda §6).

---

## 1. Testler (hepsi geçti)

`test_ciktilari.txt` ve `ekranli_kosu_gunlugu.txt` ham çıktıdır.

| Test | Sonuç (son satır) |
|---|---|
| `python3 tests/check_keys.py` | `anahtar: 6888 sorun: 0` |
| `check_speakers.py` | `SPEAKERCHECK PASS` |
| `check_voice_rules.py` | `VOICERULES PASS (9783 anahtar, 0 sorun)` |
| `check_inline.py` | `INLINECHECK PASS (723 anahtar, 0 sorun)` |
| `tests/parse_check.tscn` | `PARSECHECK PASS scripts=250` |
| `--chapter=44b --autotest` | `AUTOTEST PASS chapter=44 variant= outcome=44.1 light=phone battery=4.1 bumps=0 hits=0` |
| `--autotest=blab` | `PASS … outcome=44.2 …` |
| `--autotest=dark` | `PASS … outcome=44.1 light=remote battery=0.0 rescued=true` |
| `--autotest=kid` | `PASS … kid=true` |
| `--autotest=nophone` | `PASS … light=remote battery=14.0 bumps=2` |
| `--autotest=hit` | `PASS … hits=3` |

Ekranlı, gerçek hızlı (`PACE=1`) tam koşu da `AUTOTEST PASS … outcome=44.1 … bumps=4` ile bitti; `AUDIOAUDIT` hiç `cut/silent/overlap/clip` satırı yazmadı (`ekranli_kosu_gunlugu.txt`).
Bot bölümü baştan sona oynadı (avlu → iniş → fener → kayık → kürek → Yakovos → sarsıntı → Medusa → tırmanış → kiler → avlu → seçim → akış şeması). Kareler `ffmpeg x11grab` ile 2 kare/sn alındı (1257 kare), oyun koduna dokunulmadan; dosya adındaki `fNNNN` kare numarasıdır (≈ koşu saniyesi × 2).

## 2. Kareler ve kontrol (a–f)

24 tam boy (1280×720) kare. Sütunlar: **a** kutu yasağı · **b** havada/gömülü · **c** boşlukta duruş · **d** ışık · **e** altyazı konuşmacı/taşma · **f** dönem.

| Kare | Ne | a | b | c | d | e | f |
|---|---|---|---|---|---|---|---|
| `k01_f0141` avlu kuyu | Tolga repliği, kuyu + Eudokia | Kuyu bileziği 8 köşeli çokgen silindir (kutu değil, ama köşeleri görünüyor); Eudokia gövde/baş yuvarlak parçalı, kutu yok | yok | yok | kuyu ağzı düz siyah sekizgen: derinlik yok, "boyalı disk" | `Tolga`, taşma yok | tahta kuyu vinci, kiremit: uyar |
| `k02_f0181` Eudokia yakın | altyazı 1 | yüz/saç/gövde yuvarlatılmış, kutu yok | yok | yok | gün ışığı, doğal | **`Kadın`** doğru; 2 satır, kutu içinde | uyar |
| `k03_f0231` iniş: kuyu ağzı | yukarı bakış | kuyu borusu 12 köşeli halka, sağda ip/sarkıt | yok | — | tepede **tam beyaz disk** (gök); bilinçli, fosforlu değil | altyazı yok | uyar |
| `k04_f0251` iniş: tuğla boru | aşağı bakış | kemerli tuğla halkalar kalın şeritler; tuğla ayrıntısı yok | yok | — | çok koyu kahve ama okunur; zifiri değil | altyazı yok | uyar |
| `k05_f0291` iniş: karanlık sütunlar | `D44B_T_DARK` | ön plandaki iki sütun **yatık/eğik** (perspektif aşırı) ve tabanları sisle çözülüp zemine oturmuyor | iki sütun tabansız "asılı" | el yukarıda, suya basmıyor (yüzüyor: doğru) | karanlık amaçlı; ince meşale parıltıları var | `Tolga`, iç ses rengi (mavi) | uyar |
| `k06_f0301` fener hedefi | `HEDEF Telefonun fenerini aç [F]` | sütun gövdeleri düz silindir | ön sütunlar yine tabansız | — | zifiri kara değil, kuyudan ışık lekesi | hedef yazısı net | — |
| `k07_f0331` sütun ormanı | `D44B_T_AWE_2` | **sütunlar gerçek silindir + Korint başlık, kemerli tonoz: kutu görünmüyor**; su yansıması dolgun | ön sütunlar tabansız (suya iniş çizgisi yok) | — | koyu mavi + beyaz sütun gövdeleri; fosforlu değil; **en iyi kare** | `Tolga` | uyar |
| `k08_f0381` kayık/kürek | kayığa biniş sonrası | kürek: düz tahta + yuvarlak tutamak; kayık gövdesi **sivri düz yüzeyli kama** (kutu olmasa da çokgen) | ön sütun tabanı su çizgisinde koyu elips + yeşil halka (sütun suyun içinden değil "üstünden" geçiyor gibi) | el/kol tutarlı | yan sütun beyaza yakın yanmış (≈ fosfor) | altyazı yok | uyar |
| `k09_f0451` kürek + balıklar | HEDEF 26 m | **balıklar yassı balık gövdesi, kutu değil**; halka dalgaları var | bir balık sürünün üstünde (zıplama) — kabul | — | iyi | hedef yazısı iki satır, kutu içinde | uyar |
| `k10_f0471` kürek | `D44B_T_FISH` | sütunlar yuvarlak | meşale ve Yakovos'un sandalı uzakta, suya oturuyor | — | meşale yansıması turuncu, güzel | `Tolga`, taşma yok | uyar |
| `k11_f0511` Yakovos ilk | `D44B_Y_01` | Yakovos: yuvarlak başlı, kollar kapsül; **gövde yumuşatılmış ama bacaklar dikdörtgen prizma**; kayık kama; meşale düz çubuk + damla alev | ayakları kayık tahtasında, gömülü/havada değil | dik duruyor | meşale sıcak turuncu, sütunlar mavi-pembe: güzel | **`Balıkçı`** doğru | kürek/zıpkın/meşale uyar |
| `k12_f0531` Yakovos yakın | `D44B_Y_02` (3 satır) | aynı | yok | yok | iyi | `Balıkçı`; 3 satırlı altyazı **kayığın alt yarısını kapatıyor** ama kutudan taşmıyor | uyar |
| `k13_f0733` sarsıntı | düşen parçalar | **düşen tuğlalar tek yüzlü, ince turuncu paralelkenar kâğıt gibi** (hacim yok) | havada oldukları için doğru | — | ışık sütunu iyi; **suda sert kenarlı dikdörtgen parlak leke** (yansıma) | hedef + `Sarsıntılar sıklaşıyor · 91 sn` çubuğu üst üste binmiyor | uyar |
| `k14_f0831` Gözyaşı sütunu | `D44B_T_HENEYE` | sütunda **damla/göz oyukları** okunuyor; yuvarlak | tabanda siyah elips (suyla birleşim) | — | iyi | `Tolga`; hedef kutusu + sayaç + altyazı aynı karede, taşma yok | uyar |
| `k15_f0769` gün ışığı | `D44B_T_SUN` | tonoz, sütun, sağda tuğla duvar: **hayranlık anı çalışıyor** | sütunların suya girişi yumuşak | — | gün ışığı ışın hüzmesi parlak ama patlak değil | `Tolga` | uyar |
| `k16_f0957` Yakovos+Medusa köşesi | `D44B_Y_MEDUSA` | Yakovos pozlu; kayık kaba | — | kol dirsekten bükük, doğal | **arkasında tamamen beyaza yanmış sütun/ışık dikdörtgeni (fosforlu)**, ince dikey çizgi artefaktı | `Balıkçı`; 2 satır | uyar |
| `k17_f0911` Medusa geniş | `D44B_Y_STONE` | **iki Medusa bloğu birer KÜP**: dikdörtgen taş kutu + içine gömülü çerçeveli dikdörtgen panel, yüz paneli doldurmuyor (yan ve ters başlar okunuyor) | bloğun altı su/çamura gömülü, doğru | — | iyi: yüzler yandan ışıkla seçiliyor; ama su kısmı yatay tarama çizgili koyu panel gibi | `Balıkçı`, 3 satır | uyar (Gyllius/çamur kurgusuyla) |
| `k18_f0931` Medusa yakın | `D44B_T_MEDUSA_1` | yüz yumurta/kafatası gibi organik ama **yılan saç yok**, çerçeve kutu; "Medusa" diyen metinle yüz tam örtüşmüyor | taş kaide üstünde, havada değil | — | iyi | `Tolga` | uyar |
| `k19_f0993` tırmanış | demir basamaklar | basamak ve yan direkler tahta/ince prizma, uyumlu | basamaklar suya ve tonoz deliğine doğru uzuyor, yerinde | oyuncu elleri görünmüyor (kamera yukarıda) | koyu mavi-yeşil, okunur | altyazı yok | "demir basamak" (Y_05: "ben çaktım") ve görsel ahşap-demir karışık: sorun değil |
| `k20_f0997` tırmanış boru | boru içinden yukarı | boru **yalnız ince bej halka çizgileri; duvarlar tam siyah** — tel kafes tünel gibi | — | — | **duvar zifiri kara**, yalnız halka kenarları parlak | altyazı yok | uyar |
| `k21_f1001` kiler (üst) | kileri üstten | **soğan/sarımsak örgüleri "şiş kebap" gibi çokyüzlü toplar**, üstteki ip düz çubuk | örgüler havada asılı (ip çok ince, tavan görünmüyor) | — | **alt yarıyı kaplayan büyük düz bej levha** (kuyu kapağı/bilezik üstten), okunmuyor | altyazı yok | uyar |
| `k22_f1011` kiler (raf) | `D44B_T_CLIMB` | küpler çokgenli ama küp-şekilli; fıçı yuvarlak, bantlı | raf/fıçı yerinde | — | sıcak, iyi; kapıdan gün ışığı | `Tolga` | **iyi: fıçı, küp, kapı dönem uyumlu** |
| `k23_f1051` avlu çıkış | `D44B_E_BACK` | 4 karakter yan yana **sıralı dizilmiş** (Eudokia, Yakovos, bir komşu, mavi gömlekli); yuvarlak gövde/kollar; servi ağacı **düz koni** (yuvarlak nesne ama pürüzsüz koni) | kuyu bileziği + saksı yerinde | dört karakter de ayakta, dik | gün ışığı güzel | **`Kadın`** (Eudokia konuşuyor) doğru | uyar (saksı, kiremit) |
| `k24_f1101` seçim | 1/2 seçeneği | aynı | — | — | — | seçenek kutuları metne sığıyor, taşma yok | uyar |

Ek gözlem (karelerden): `Denetçi Nihat` (Nihat) ve `Tolga` rengi/etiketi tutarlı (`D44B_N_QUAKE`, `D44B_N_COLLAPSE`, `D44B_N_SUN`: 3 satıra kadar, kutudan taşmıyor).
EN altyazı bu koşuda karelenmedi; EN konuşmacı adları `i18n/strings.csv`'den okundu: `SPK_EUDOKIA = Kadın / Woman`, `SPK_YAKOVOS = Balıkçı / The fishmonger`, doğru.

## 3. SES (74 anahtar × TR + EN = 148 dosya) — `ses_olcum.csv`

- **148/148 dosya var**, Godot `ResourceLoader.exists` ve `load` ile hepsi yüklendi (`godot_voice_stream_uzunluk.txt`), 0 bayt yok.
- Süre ≥ 0,4 sn: **0 ihlal** (en kısa `D44B_T_DARK_HINT` en 1,76 sn).
- Tepe: en yüksek −0,5 dB (`D44B_N_COLLAPSE` tr). **0 dBFS'ye yapışık dosya yok**; ortalama ses −40 dB altı (sessiz) dosya yok. Tepe aralığı −10,6 … −0,5 dB.
- Karakter/sn: TR ort. 13,9 (4,3 … 22,7), EN ort. 14,0 (10,0 … 18,7). Aşırı uçlar:
  - `D44B_T_Y_01` tr: "Sigortacıyım." (13 karakter) **3,0 sn**, 4,3 k/sn; son **1,14 sn sessiz** kuyruk.
  - `D44B_T_KID` tr: 9,77 sn, 72 karakter (7,4 k/sn); **son 2,36 sn sessiz**: ölü hava.
  - `D44B_T_Y_04` tr son sessizlik 0,75 sn; `D44B_N_KEEP` en 0,73 sn.
  - Hızlı: `D44B_T_Y_02` tr 22,7 k/sn (54 karakter 2,38 sn), `D44B_N_SPLASH` tr 20,7, `D44B_E_BLAB` tr 19,8 — okunur hızda ama telaşlı; dinlenmedi, kulakla doğrulanmalı.
- Kırpılma: tepe yapışması yok; baş sessizlik 0. Kuyruk sessizliği dışında kırpık şüphesi yok.
- **Oyun gerçekten çalıyor mu?** Ekranlı koşuda `PACE say … len=` değeri `mp3 süresi + 0,3 sn soluk` ile **41 replikte tam örtüştü** (ör. `D44B_Y_02 len=9.6, mp3 9.27`), yani `voice_stream` dosyayı buluyor ve oynatıyor (`ekranli_kosu_gunlugu.txt`). Fakat **şu 4 anahtarın sesi hiç çalmıyor**: `D44B_T_DARK`, `D44B_T_AWE_PHONE`, `D44B_T_AWE_LIGHTER`, `D44B_T_AWE_REMOTE` (bkz. Z1).
- Olay tetikli ayak üstü sözler (`T_FISH`, `T_FAR`, `N_SPLASH`, `T_HENEYE`, `N_COLLAPSE`, `T_SUN`, `N_SUN`, `T_DROP`, `T_FOUND`, `T_HIT_*`, `T_BATTERY_0`, `T_THUMB`, `Y_TORCH` …) `PACE say` yazmaz; bunların dosyaları var ve yüklenir (yukarı), ama çalmaları günlükten **doğrulanamadı** (altyazı karesi `k10`, `k14`, `k15` ile ekrana geldikleri görüldü).

## 4. METİN (74 satır TR + EN okundu)

İyi çalışanlar (kısaca): Tolga sigortacı ağzı güçlü (`D44B_T_ROPE` "'Herhalde' lafını poliçede hiç sevmem", `T_HIT_3` "Kullanıcı hatası", `T_BATTERY_0` "Pahalı bir tuğla", `T_END` "kapsam dışı"); Nihat bürokrat ciddiyeti tutarlı (`N_SUN` "Hayranlığı sonra kayda geçiririz"); Yakovos sıcak, kendine özgü (`Y_03` "Mahalle buna cin der, ben akşam yemeği", `Y_RESCUE_2`); EN çevirisi doğal, çeviri kokmuyor.

Bulunan sorunlar (metin değiştirilmedi):

| Anahtar | Sorun | Öneri |
|---|---|---|
| `D44B_N_MEDUSA` (TR/EN) | **Dönem/bilgi hatası:** Nihat 1977 Büro memurudur; "1985'teki temizliğe dek" kendi geleceği. Aynı karakter başka yerde yalnız geçmişi biliyor (Gyllius 1540'lar, "doksan yıl sonra") | "…Sabaha çamur yine örter; yüzyıllarca kimse görmeyecek." ya da cümleyi Tolga'ya ver ("rehber 1985'te çıkmış demişti") |
| `D44B_Y_04` (TR) | **Yazım sızıntısı:** "Blaherna" (TTS fonetik yazımı); oyunun 30 yerinde "Blakherna" yazıyor | Altyazıda "Blakherna", seslendirme metni zaten fonetik tutuluyor |
| `D44B_T_DARK` (TR vs EN) | TR "tabak kadar", EN "coin-sized": iki dil birbirini tutmuyor | EN: "plate-sized" / "no bigger than a saucer" |
| `D44B_T_Y_01` | Tek sözcük, ama ses 3 sn ve 1,1 sn boşlukla bitiyor: komik zamanlama bozuluyor | Dosyayı kırp ya da "Sigortacıyım. (…)" yerine ses hızlandırılsın |
| `D44B_K_01` / `SPK_KID` | Çocuk "Venedikli Marco" ama "Annemle burada kalıyoruz" diyor; tasarım notu (`docs/BOLUM_YEREBATAN.md` §3) çocuğu Eudokia'nın torunu yapıyordu. Eudokia kid varyantında çocuğa hiç tepki vermiyor (`D44B_E_*` hep aynı) | Ya "Annemle Kyra Eudokia'nın evinde kalıyoruz" ya da Eudokia'ya bir tanıma repliği |
| `D44B_Y_STONE`, `Y_RESCUE_2`, `T_CLIMB` | "Kırk" üç kez (kırk yıl, kırk yıl, kırk basamak) arka arkaya; bölümde yinelenen şaka gibi duruyor, kasıtsa güzel, değilse | Birini "otuz bir yıl"/"yirmi yıl" yap |
| `D44B_Y_KEEP` EN | "deep, and no echo": "ses vermiyor" = "sır tutuyor"; EN'de yalnız "yankı yok" okunuyor | "deep, and he doesn't talk back / doesn't give a thing away" |
| `SPK_YAKOVOS` EN "The fishmonger" | Yakovos balık **tutuyor**, satmıyor: "fishmonger" = balık satıcısı. Görev metni bu etiketi bekliyor; yalnız not | (İsteğe bağlı) "The fisherman" |
| `D44B_E_KEEP` | "Tolga, akşam balığa gel" iyi ama Eudokia'nın balığı Yakovos'un; Yakovos gülmüyor/tepki vermiyor (tasarım notunda "Yakovos güler" vardı) | `D44B_Y_KEEP` öncesine kısa bir "Balık benim, davet senin" şakası (isteğe bağlı) |

Kişilik uyumu: Niko bu bölümde yok; Tolga ve Nihat kişiliğine aykırı satır bulunmadı (yukarıdaki 1985 hariç).

## 5. OYNANIŞ

- **Süre (bot, `PACE=1`):** 1. satır 49,9 sn, `T_END` 570,2 sn: yaklaşık **8,7 dk** konuşmalı oynanış (+ yükleme ~50 sn). İnsan için 10–12 dk beklenir.
- **Takılma/yumuşak kilit:** 6 varyantın hepsi `AUTOTEST PASS`; ekranlı koşuda `soft-lock` yok. Hedef yazısı her aşamada kare üzerinde okunur (`k06`, `k09`, `k13`).
- **Dışarı düşme:** gözlenmedi.
- **Hedef yazısı belirsizliği:** "Kuzeybatı köşeye kürek çek · sudaki halka: oraya taş düşecek" (`k13`, `k14`) iki iş birden söylüyor ve oku ("◄ 58 m") yön veriyor; ama yeni oyuncu "halka"nın ne olduğunu bu satırdan çıkaramaz, Nihat'ın `D44B_N_QUAKE` repliği (halka → taş) önceden açıklıyor. Kabul.
- **Kare hızı:** ekran kartı yok, `HITCHSUM` medyan 376 ms/kare (yazılım çizimi), **bu bir oyun ölçüsü değildir**. Yalnız çizim yükü ölçüldü (`RINFO`): sahne düğümü ~28 bin, **avlu açılışında 4 865 çizim çağrısı / 1,5 M üçgen** (en kötü an, kare t=9 sn), sarnıç boyunca ortalama ~420 çağrı, sonda avluda 1 980 çağrı. Orta sınıf GPU'da avlu açılışı tek riskli an; gerçek kare hızı için donanımlı makinede `--hitchaudit` koşusu gerekir.
- **Yükleme:** koşunun ilk saniyelerinde 0,7–1,0 sn'lik takılma satırları (`HITCH … added=person<city_life x462`): kalabalık üretimi, sarnıçla ilgisiz ama bölümün ilk ekranında.

## 6. PUAN

**Hayranlık 8/10.** Sütun ormanı (`k07`, `k15`), yansımalar, tonoz kemerleri ve gün ışığı ışını, meşaleli balıkçı (`k11`) gerçekten hayranlık veriyor; kiler (`k22`) ve avlu (`k23`) sıcak ve okunur. Düşüren şeyler: tabansız ön sütunlar, Medusa'nın kutu içinde ve saçsız olması, patlak beyaz sütun.
**Heyecan 6/10.** Sarsıntı/halka/çöküş döngüsü çalışıyor, ama botun oynadığı koşuda tehlike hissi (düşen tuğlaların kâğıt gibi görünmesi, 91 sn'lik süre çubuğu) sınırlı; en güçlü an yine hayranlık anı.

**HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL.**

### Zorunlu (yayına engel)

| # | Madde | Kanıt |
|---|---|---|
| Z1 | **Seslendirilmiş ama oyunda hiç çalınmayan 4 replik (×2 dil):** `D44B_T_DARK`, `D44B_T_AWE_PHONE`, `D44B_T_AWE_LIGHTER`, `D44B_T_AWE_REMOTE`. Bölüm bunları `hud.think(...)` ile söylüyor (`scripts/chapter44b.gd:477`, `:496`); `think` `_inner=true` yapıyor ve `scripts/ui/hud.gd:1791` `vs = null if _inner` diyor, yani ses çalınmıyor, mırıltı da yok. Günlük: `D44B_T_DARK … PACE say len=6.0` (mp3 10,53 sn olmalıydı, +0,3), `T_AWE_PHONE len=3.3` (yazı süresi formülü). Hayranlık anının tam öncesi sessiz altyazıya düşüyor | `ekranli_kosu_gunlugu.txt` (satırlar 141,3 / 158,9), `ses_olcum.csv` |
| Z2 | `D44B_N_MEDUSA`: 1977 Nihat'ın "1985" demesi (dönem hatası) | §4 |
| Z3 | `D44B_Y_04`: altyazıda "Blaherna" (30 yerde "Blakherna") | §4 |
| Z4 | Ön plandaki sütunlar iniş ve kürek ilk karelerinde **tabansız / yatık** (zemine oturmuyor; önceki tur 7a "KISMEN" demişti, hâlâ görünüyor) ve yanmış beyaz sütun/ışık dikdörtgeni Yakovos'un arkasında (fosforlu yüzey) | `k05_f0291`, `k06_f0301`, `k08_f0381`, `k16_f0957` |

(Z4 görsel; yayını engelleyecek ağırlıkta sayılması bölüm sahibinin kararıdır — küçük düzeltmeyle kapanır: ön sütunlara taban/su halkası eklemek, yanık sütunun parlaklığını kısmak.)

### İsteğe bağlı

1. Medusa blokları küp + çerçeveli panel (`k17_f0911`, `k18_f0931`): yüz yılansız, "çerçeveli resim" gibi; öneri: bloğu yarı-yuvarlak taş başlığa çevir ve yılan saçı ekle.
2. Düşen tuğlalar tek yüzlü kâğıt gibi (`k13_f0733`): kalın küçük prizma kullan; suda sert kenarlı parlak dikdörtgen leke.
3. Tırmanış borusunun duvarı tam siyah, yalnız halka çizgileri (`k20_f0997`): duvara hafif dolgu ışığı.
4. Kiler ilk karesi: alt yarıyı kaplayan boş bej levha ve havada asılı şiş görünümlü örgüler (`k21_f1001`); `k22` kadrajı çok daha iyi, ilk kareyi ona yaklaştır.
5. Kuyu ağzı düz siyah disk (`k01_f0141`).
6. Avluda çıkışta dört karakterin sıralı durması (`k23_f1051`).
7. Kayık gövdesi kama (`k11`, `k08`).
8. Ses: `D44B_T_KID` tr son 2,36 sn, `D44B_T_Y_01` tr son 1,14 sn sessizlik kırpılsın.
9. Metin: §4'teki `K_01`/`Y_STONE`/`Y_KEEP`/`T_DARK EN`/`SPK_YAKOVOS EN` notları.
10. Avlu açılışında 4,8 bin çizim çağrısı (`RINFO`): kalabalık üretimi (`city_life`) bölümün ilk saniyelerinde.

### Bu denetimde YAPILMAYANLAR (dürüstlük notu)

- Ses **dinlenmedi** (cihaz yok); karakter/sn ve sessizlik ölçümü kulak yargısı yerine geçmez.
- Gerçek GPU kare hızı ölçülmedi.
- `kid`, `blab`, `dark`, `hit` varyantları yalnız başsız testle koşuldu, kare alınmadı; EN altyazı karelenmedi.
- Yeni ses üretilmedi, ElevenLabs'e istek atılmadı.
