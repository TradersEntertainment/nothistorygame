DURUM: DEVAM EDİYOR (bölüm 1–4 yazıldı; 5–7 sürüyor). Yedi bölüm de dolunca bu satır `DURUM: TAMAM` olacak.

# Nisan–Mayıs 1453 Osmanlı ordugâhı ve kuşatma hatları: gerçekte nasıl görünüyordu?

Amaç: bir 3B sanatçısının/programcısının doğrudan uygulayabileceği kesinlikte, ama **uydurma kesinlik yazmadan**. Sahibin sorusu
(ilk kare: eş boy, eş renk, ızgara dizili yüzlerce küçük çadır; asker, at, top yok): *"çadırlar böyle mi normalde, ona da
çalıştın mı, askerler nerde, eksik bir şeyler var mı?"* Kısa cevap en üstte, ayrıntı aşağıda:

> **Hayır, böyle değildi; evet, eksik çok şey var.** (1) Çadırlar eş boy/eş renk/ızgara değildi: padişah, vezir ve
> paşa çadırları büyük ve kırmızı-altın, yeniçeri çadırları otağın çevresinde halka, geri kalan ordu obalar/birlik
> kümeleri hâlinde; ilk elden tanıklar (Barbaro) ordunun öyle kalabalık olduğunu söyler ki "yer görünmüyordu".
> (2) Askerler: ordugâhın kendisi insanla doluydu (aşçı, saka, seyis, demirci, lağımcı, tüccar, dervişler);
> sur önünde ise bir **hendek + toprak yığma + ahşap perde (palisade)** hattının arkasında, topçu bataryalarının çevresinde.
> (3) At, deve, katır, manda/öküz, koyun sürüleri, top arabaları, gülle yığınları, ocak dumanları, sancaklar ve
> davul/zurna sesi olmadan ordugâh "ordugâh" olmaz.

## Okuma kılavuzu: etiketler

| Etiket | Anlamı |
|---|---|
| **[K: kısaltma]** | Kaynakta açıkça var; kısaltma kaynakçada. Aşağıdaki "ikinci el" ibareli olanları ben birincil metinden değil, o metni aktaran eserden okudum. |
| **[SONRAKİ DÖNEM]** | Bilgi 16. yy ve sonrasına ait (minyatür, kanunname, gezgin); 1453'e aktarmak varsayımdır. |
| **[TAHMİN]** | Kaynak yok; çıkarım ya da sanatsal öneri. Uygularken "değiştirilebilir" demektir. |
| **[TARTIŞMALI]** | Kaynaklar çelişir ya da tek zayıf kaynağa dayanır. |

Okuduğum ve okuyamadığım kaynaklar belgenin sonunda ayrı ayrı listelidir. **Önemli dürüstlük notu:** Barbaro'nun
günlüğünü, Kritovulos'u, Dukas'ı, Tursun Bey'i, Atasoy'u, Nicolle'ü, Runciman'ı, Babinger'i, İnalcık'ı, Emecen'i,
Philippides & Hanak'ı ve Ágoston'ı **tam metin olarak okuyamadım** (erişim engeli/özet düzeyi). Birincil tanık bilgilerinin
çoğunu Edwin Pears'in 1903 tarihli, bu tanıkları ayrıntılı aktaran ve kaynak notlarıyla veren kitabından (tam metni
okudum) ve Kritovulos'un Riggs çevirisinden bir alıntı sayfasından aldım. Bu yüzden "Barbaro der ki" gibi cümleler
**Pears üzerinden** aktarılmıştır ve öyle işaretlenmiştir.

---

## 1. GENEL DÜZEN

### 1.1 Büyük resim (kroki)

Yönler `docs/ISTANBUL_YERLER.csv` çerçevesi: **doğu_m** (+ doğu), **kuzey_m** (+ kuzey). Kara surları kabaca kuzey-kuzeydoğu → güney-güneybatı bir
çizgi; "dışarısı" batı-kuzeybatı. Kapı koordinatları (CSV; "kestirim ±100–150 m"):

| Yer | doğu_m | kuzey_m | u (yarı ölçek yay, ≈) | Not |
|---|---|---|---|---|
| Altınkapı/Yedikule (güney uç) | −4780 | −1701 | 0 | kara suru–Marmara köşesi |
| Silivrikapı (Pege) | −5041 | −489 | ≈630 | Pege bataryası |
| Mevlanakapı (Rhegion) | −4856 | 289 | ≈1030 | Mesoteikhion güney ucu |
| Mesoteikhion / Lykos geçişi | −4805 | 656 | ≈1180 | surun en alçak, dere geçişi |
| **Topkapı (Aziz Romanos)** | **−4663** | **1101** | **≈1450** (kodda 1500) | Şahi ve ana hücum |
| Hücum Kapısı (Pempton) | −4016 | 1824 | ≈1935 | |
| Edirnekapı (Charisios) | −3612 | 2291 | ≈2244 | |
| Blakhernai kapısı | −3512 | 2925 | ≈2565 | kuzey uç; Haliç'e dönüş |

(u değerlerini CSV koordinatlarından yay uzunluğunun yarısı olarak hesapladım; kodun `IstOrdugah.at(u,d)` işleviyle uyumlu
olması için. Not: `ist2_kalite_notlari` madde 1 "kesit gerçek, uzunluk hat boyunca yarı ölçek" der; bu yüzden **d (surdan dışa uzaklık)
gerçek metre**, u yarı ölçek.)

```
                      KUZEY
          Haliç  (Zağanos Paşa: Galata/Kasımpaşa sırtları, fıçı köprüsü Cynegion'da)
                      │
      Blakhernai ─────┘      ┌─ Çifte Sütun/Beşiktaş: Baltaoğlu donanması (Boğaz kıyısı)
   Kerkoporta                │
 Edirnekapı  ▒▒▒ SOL KANAT   │
  Pempton    ▒▒▒ RUMELİ      │
              (Karaca Paşa)  │
 Topkapı  ═══▶ ŞAHİ ───●─── OTAĞ ──(küçük tepe/Maltepe)──┐   MERKEZ
 Lykos    ▓▓ yeniçeri halkası, Halil Paşa, topçu, hazine│   (Halil Paşa)
 Mevlana     SAĞ KANAT ANADOLU (İshak + Mahmud Paşa)     │
 Silivri  ░░░ Lykos'tan Marmara'ya                       │
 Yedikule                                                │
 Marmara ─────────── Baltaoğlu: Marmara kıyısı gözcülüğü ┘
                      GÜNEY
   BATI ◀── artçı, başıbozuk, pazar, hayvan sürüleri, ağırlıklar ──
```

### 1.2 Kimde nerede (kaynaklı)

- **Genel yerleşim [K: PEARS1903, WP-Fall].** Zağanos Paşa: Galata ve Haliç'in kuzey kıyısı, Haliç'in güney kıyısının bir bölümü; Haliç'in üst ucunda bir
  köprü kurmakla görevli. Karaca Paşa (Rumeli): Ksiloporta/Blakhernai'den Edirnekapı'ya kadar kara suru. İshak Paşa (Anadolu) ve Mahmud Paşa:
  Topkapı'dan Marmara'ya. En kritik bölge **Edirnekapı–Topkapı arası (Mesoteikhion)**: padişahın ana saldırı noktası ve **Halil Paşa** burada.
  Baltaoğlu donanmayla Marmara surlarını ve Haliç ağzını gözler. Kritovulos §117–121 aynı dağılımı verir [K: KRIT-DRM; ikinci el].
- **Otağ yeri.** Pears (Chalkokondyles s. 95'e dayanarak): padişahın "uzun kırmızı-altın çadırı surdan **yaklaşık çeyrek mil (~400 m)** uzakta, **küçük bir
  tepecik (knoll) üzerinde**, hem Edirnekapı hem Romanos kapısı karşısı diye anlatılır"; çevresinde yeniçeri çadırları, "aynı vadide" [K: PEARS1903]. Kritovulos §140:
  topları "Orta Sur'a karşı, ordugâhının ve çadırının bulunduğu yere" kurdurdu [K: KRIT-DRM]. Phrantzes: çadır Romanos karşısında; Dukas: Edirnekapı karşısında
  (Pears bu çelişkiyi "Pempton'a Romanos denirdi; tepe ikisinin ortasında" diye çözer) [K: PEARS1903, TARTIŞMALI]. **Büyük top, otağın önünde** [K: PEARS1903].
  - *Maltepe adı:* "Maltepe, Bayrampaşa deresinin sol yakası, 5 Nisan" bir haber-tarzı kaynakta geçer; **tek zayıf kaynak** [TARTIŞMALI]. Aynı sayfa Fatih'in 1481'de Maltepe'de öldüğünü
    söyler; bu **yanlıştır** (Hünkâr Çayırı, Gebze) → o sayfaya güvenme. `ISTANBUL_1453.md` "geleneksel otağ yeri Maltepe" der [Bilgi] = sonraki gelenek [SONRAKİ DÖNEM].
  - **Mesafe uyarısı (üç farklı sayı):** Pears ≈ 400 m; `ISTANBUL_YERLER.csv` otağı Topkapı kapısından ≈ 800 m (surun dış hendeğinden ≈ 620 m) koyar (kestirim);
    mevcut kod `at(1500,330)` = surdan 330 m. Önerim: **surun dış hendeğinden 400–450 m**, Topkapı–Edirnekapı arası, Lykos vadisinin kuzey yakasındaki hafif tepede
    (kuzey yaka çadır alanı kuru olsun diye); öyle ki otağın önünden bakınca Şahi ve hendek görünsün. [TAHMİN: 400–450 m aralığı, çelişen iki kaynaktan uzlaşma]
- **Varış tarihleri [K: WP-Fall].** 2 Nisan öncü ordugâhı; 5 Nisan padişah son birliklerle; 6 Nisan kuşatma/top ateşi başlar. Oyunun Nisan başı sahnelerinde ordugâh 2–5 Nisan arası "yarı kurulu" (çadırlar yarım, tomruk yığınları) görünebilir [TAHMİN].
- **Bölgesel çelişki:** CSV bataryaları surdan 600+ m uzakta işaretliyor (örn. Şahi (−5293,1068), Topkapı'dan ≈630 m) → bu, bataryaların surdan ≈100–200 m'de olduğunu
  anlatan kaynaklarla çelişir (bkz. 1.4). CSV'deki batarya satırları "kestirim" etiketli ve **yanlış sayılmalı**; kod (`d=128–136`) daha doğru.

### 1.3 Halkalar: otağdan surlara (kaç metre)

Aşağıdaki sıra **doğrultu d** (surun dış hendek kenarından batıya doğru, gerçek metre). [TAHMİN] ile işaretli olmayan tek veri "çeyrek mil" ve "hendeğe çok yakın perde"dir.

| d (m) | Ne var | Kaynak |
|---|---|---|
| 0 | Hendek dış kenarı (hendek ~20 m geniş, ≤10 m derin; iç yüzünde 1,5 m'lik siperlik; hendek bazı yerlerde doldurulmuş) | [K: WP-Walls, ikinci el: GORUNUS.md]; doldurma Kritovulos §142 |
| 0–15 | **Hendek kenarı: ahşap perde (palisade) üstü toprak sıra**, aralarda ateş delikleri | [K: PEARS1903, Chalkokondyles s. 159] |
| 15–40 | Siper (hendek-yol): ön topraklı, kazılmış; arkadan koşu yolu; süngü/ok atan hücum siperi | [TAHMİN, "trench in front of whole line" Pears]|
| 40–120 | Top bataryaları: toprak/tomruk kaideler, ahşap kapak, gülle yığını; ağır toplar daha geride (menzil sorunu yok; çekiş kolaylığı) | [TAHMİN; konum Pears/Kritovulos] |
| 120–250 | Cephe çadırları: topçu, lağımcı, nöbet birlikleri; barut ve gülle depoları (barut için çadır/çukur; ateşten uzak, ≥50 m [TAHMİN]) | [TAHMİN] |
| 250–400 | Ana birlik çadırları (azap, sipahi, eyalet askeri), kazanlar, hayvan bağları | [TAHMİN] |
| **400–450** | **Otağ tepeciği**: zokak, sayebân, divan, hazine, mutfak, hamam, mescit; yeniçeri halkası | [K: PEARS1903 mesafe; çevre: SONRAKİ DÖNEM] |
| 450–700 | Yeniçeri/kapıkulu ana çadırları, topçu ocağı çadırları, ordu pazarı, esir çadırı, Halil Paşa, tercüman | [TAHMİN] |
| 700–1500 | Artçı, başıbozuk, yük kafileleri, öküz/manda/deve ağılı, koyun sürüsü, saka yolu, ırmak/dere | [TAHMİN] |

**Menzil mantığı.** Savunmacının yay/arbalet menzili ~100–150 m [TAHMİN]; sur tepesi 12 m + hendek 20 m → Osmanlı ön hattı (perde) surun ok menzilinde; bu yüzden perde
zorunluydu. Gündüz ön hatta çıkanlar kalkan/perde ardında; geriye çekilince çadırlar menzil dışı (≥250 m) [TAHMİN]. Savunma topları (gunpowder) sınırlı etkiliydi: sur topları kendi surlarına zarar verdiği için az kullanıldı [K: PEARS1903].

### 1.4 Toplar nerede? (kısa; ayrıntı §4)

- **Üç ana top istasyonu** [K: PEARS1903, Kritovulos'un "üç yerde yol açtım" sözüne dayanır]: (1) Tekfur Sarayı–Edirnekapı arası, (2) **Pempton/"Romanos" kapısı çevresi Lykos vadisi** (en büyük top, otağ karşısı), (3) **Üçüncü Askerî Kapı (Silivrikapı–Mevlanakapı arası)**.
- Phrantzes: surun boyunca **14 batarya**, her birinde **4 top**; Barbaro: **9 batarya**, her birine ağır bir top eklenmiş; Montaldo: toplam 200; Tetaldi/Montaldo: 10.000 kolonborna [K: PEARS1903]; modern: ~70 top, aralık 12–62 [K: WP-Fall (Lanning 2005; Nicolle 2000)]. [TARTIŞMALI] — kod 14 batarya, 2–4 top kuruyor (≈ 40 top); makul.
- Galata arkası: Aziz Theodoros tepesinde (Galata doğu surunun kuzeyi) topçu, Haliç'teki zincir gemilerine ateş (21 Nisan; ~100 atış) [K: PEARS1903].

### 1.5 Sayılar (asker, hayvan, çadır)

| Konu | Aralık | Kaynak/Not |
|---|---|---|
| Toplam asker | 50–80 bin (modern); 80 bin (Cheirullah); 100 bin; 150 bin (Barbaro); 160–300 bin (Batılılar) | [K: WP-Fall (Pertusi), PEARS1903] [TARTIŞMALI]; Batılı sayılar abartılı sayılır |
| Yeniçeri | 5–10 bin (modern); Pears: ≥12 bin | [K: WP-Fall; PEARS1903] |
| Atlı | 20–40 bin (Tetaldi: 30–40 bin süvari/200 bin toplam) | [K: PEARS1903] |
| Donanma | ~110 gemi (≈70 büyük kadırga, 5 orta, 10 küçük, 25 büyük kayık, 75 at nakliyesi); 110–430 aralığı | [K: WP-Fall; Nicolle 2000] |
| Top | ~70 (12–62 ve 200 gibi uçlar var) | [TARTIŞMALI] |
| Barut | ≈ 55.000 lb (≈ 25 ton) 28 Mayıs'a kadar ~5000 atış | [K: WP-Fall (Crowley 2013)] [TARTIŞMALI] |
| Çadır sayısı | **kaynak yok.** Askerî düzen 50–80 bin eşit olmayan insanı; yeniçeri/azap/sipahi çadırı başına 8–15 kişi varsayımıyla birkaç bin çadır, ayrıca ağıl ve çalı kulübeler | [TAHMİN] |
| Hayvan | 10–20 bin at/katır/deve + yüzlerce öküz-manda + sürüler (yemek için) | [TAHMİN]; sınıf: bir sefer ordusunda yük hayvanı, asker sayısına yakın olurdu |

**Oyun için ölçek notu:** İstanbul oyunda yarı uzunluk ölçeğinde (surun uzunluğu yarıya iniyor); asker/çadır yoğunluğu gerçek orandan **daha sık** olmalı ki "çadır denizi"
okunsun (sahip: "boş alan istemiyorum"). Oyunun özgün sayıları (±%50) bu belgenin dışındadır.

---

## 2. ÇADIRLAR (en önemli bölüm)

### 2.1 Cevap: ızgara mı?

**Hayır.** Elimdeki 15. yy tanığı: Bertrandon de la Brocquière (1433, Murad II zamanı Edirne yolunda) bir Türkmen/yaya kafilesi kampını "**seksen küsur çadır, bir sokak biçiminde dizilmiş**"
diye anlatır [K: BROC1433, ikinci el alıntı; metni okuyamadım] ve çadır iskeletini "iki direk, bir çapraz, kalın yün/kıl örtü" diye verir. Yani **sokak** (uzun sıra) var, ama bu bir *karavan/obası* kampı. Resmî sefer ordugâhı (otağ-ı hümayun
çevresi) için ilk elden 15. yy düzeni yoktur; 16. yy minyatürleri ve 17–19. yy çadır sanatı (Onuk; Atasoy; Mesci) **[SONRAKİ DÖNEM]** merkezde padişah
otağı, çevresinde zokak, çevresinde kapıkulu çadırları, dışta eyalet askerleri ve pazarı gösterir. Ordu bölükleri **kendi sancakları çevresinde obalar** hâlinde yerleşir [TAHMİN, göçebe gelenek + 16. yy düzeni].

### 2.2 Tür tablosu

Ölçüler **kaynaksız ise [TAHMİN]**; 17.–19. yy müze örnekleri (Wawel, Dresden, Askerî Müze) 1453'ten 200+ yıl sonradır.

| Tür | Kimde/nerede | Biçim | Boyut (çap × yükseklik) | Kumaş, renk, süs | Kaynak |
|---|---|---|---|---|---|
| **Otağ-ı hümayun (ana)** | Padişah; otağ tepesi | Çok bölümlü çadır kompleksi; ana otağ yurt/çok direkli geniş çadır; iç kaplama astarlı (tenefli) | ana otağ çap 14–20 m, yükseklik 8–12 m [TAHMİN]; (sonraki dönem örneklerinde tek direkli çadırlar 6–8 m) | **Dış: kırmızı çuha/atlas; altın sırma, şemse (güneş madalyonu), rumi.** İç: ipek, deri, kıymetli halı. Kırmızı sadece padişah, şehzade, vezir, beylerbeyi | [SONRAKİ DÖNEM: AKIN-KEŞ2017 (Onuk 2005), WP-Tents]; 1453 rengi: **kırmızı-altın [K: WP-Fall, PEARS1903]** |
| **Zokak** (çevre perde duvarı) | Otağ çevresi | Kumaş duvar, **üstü mazgallı (dendanlı)**, beyaz veya koyu zemin, şemse/rumi bordür | yükseklik 2,5–3,5 m, çevre 100–200 m [TAHMİN] | Beyaz kumaş + lacivert/altın desen (minyatürlerde) | [SONRAKİ DÖNEM: AKIN-KEŞ2017; WP-Tents] |
| **Sayebân** (gölgelik) | Otağ ön ve yanlar | Direkli açık tente, bitişik ya da serbest, A biçimli | 6×8 m, yükseklik 3–4 m [TAHMİN] | kırmızı/mavi/lacivert üstüne altın şemse | [SONRAKİ DÖNEM: AKIN-KEŞ2017] |
| **Divan/Otağ-ı Âsafî (vezir)** | Büyük vezirler; "ara çadırla" padişaha bağlı | Birkaç direkli geniş çadır, pencereli, perdeli | 8–12 m uzun kenar [TAHMİN] | kırmızı (vezir hakkı) | [SONRAKİ DÖNEM: AKIN-KEŞ2017] |
| **Hazine, kilar, hamam (kurba), hastane, saraçhane, mutfak** | Otağ çevresi, zokak içinde/arkasında | dikdörtgen ya da çatma; mutfak "germe" (turuncu) tepe ortasında siyah duman deliği | 5–10 m [TAHMİN] | mutfak: turuncu; hazine: kalın sırma kumaş | [SONRAKİ DÖNEM: AKIN-KEŞ2017] |
| **Vezir/paşa çadırı (Halil, Karaca, İshak, Mahmud, Zağanos)** | paşalar | çok direkli, kırmızı veya bordo; zokaksız; küçük sancak | çap 8–12 m [TAHMİN] | kırmızı/yeşil; paşa sancağı + tuğ | [SONRAKİ DÖNEM + TAHMİN] |
| **Yeniçeri orta çadırı** | Otağ çevresi halka, orta başına kazan | Büyük konik/çatma çadır (bir oda=bir birlik); ortanın **kazanı çadır önünde**, ortanın simgesi çadır ve sancakta | çap 5–7 m, yükseklik 3,5–4,5 m [TAHMİN] | **Ağartılmamış kanvas/keten, soluk krem; beyaz–hafif gri**; kırmızı yok (paşa hakkı); yeşil/mavi kenar şeridi çok az [TAHMİN] | [Barbaro (Pears): "yeniçerilerin beyaz başlığı" ayırt edici renk; çadır rengi: TAHMİN]; orta/kazan sembolizmi [SONRAKİ DÖNEM: İnalcık/Ágoston sürece genel] |
| **Sipahi/eyalet askeri çadırı** | Kanatlar | Konik veya çatma | çap 4–5,5 m [TAHMİN] | doğal keten, kıl, yer yer koyu kahve; beyler çadırı daha büyük/renkli | [TAHMİN] |
| **Azap, gönüllü, başıbozuk barınağı** | Cephe gerisi | **Çalı-çırpı kulübe, çardak, tek direkli küçük çadır, yamalı örtü, açıkta yatma**, çoğu çadır bile yok | 2–3,5 m [TAHMİN] | kiremit kahvesi, bez parçaları, keçe, hasır | [Pears: "poorest Turks who didn't possess a horse + Christians for plunder"; ayrıntı TAHMİN] |
| **Akıncı** | Kanat önü ve yan | Küçük çadır + at; çok hareketli | 3–4 m [TAHMİN] | kıl/keçe, koyu | [TAHMİN] |
| **Topçu/dökümhane/demirci/barutçu** | Batarya arkası; Edirne dökümhanesi yolda | Açık sundurma + ocak, körük, çekiç; barut için ayrı çukur-çadır | sundurma 6×4 m [TAHMİN] | koyu kıl/keçe, is lekeli | [K: top dökümü Edirne WP-Fall; ordugâh yerinde döküm: Saruca, WP-Fall] + TAHMİN |
| **Pazarcı, esnaf, saka, aşçı** | Orta-artçı | Tezgâh, direkli tente; ordu pazarı | 4–8 m [TAHMİN] | rengârenk (ticaret kumaşı), kısa tente | [Tetaldi (Pears): "hawkers, thieves, plunderers following for gain"] |
| **Mehterhane** | Otağ önü | Açık tente + davul-zurna-nefir | 5×5 m [TAHMİN] | kırmızı/altın kenar | [SONRAKİ DÖNEM; WP-Fall: tellal/boru anılır] |
| **Mescit/imam çadırı** | Kanat başına bir | Küçük ak-yeşil çadır, önünde saf | 6×4 m [TAHMİN] | beyaz, yeşil şerit | [TAHMİN; ordu imamları ISTANBUL_1453.md 159] |

**Yazılı kaynaklarda doğrudan çadır tarifi (1453 Osmanlı) yok.** Barbaro "kızıl başlıklar ve beyaz yeniçeri başlığı"ndan başka çadır tarifi vermez
[K: PEARS1903]; 26 Mayıs'ta "her çadırda iki büyük ateş" [K: Barbaro; ikinci el özet]. Çadır rengi için tek birincil veri: *padişah çadırı kırmızı-altın* [K: Chalkokondyles/PEARS1903].

### 2.3 Biçim ve yapı (ip-kazık)

- **Konik tek direkli (pentagon/yuvarlak):** merkezde bir direk, eteğe kazıklı ip, düşük duvar (0,8–1,2 m) + koni; ortada küçük alem [SONRAKİ DÖNEM + TAHMİN].
- **Çatma/ridge (dikdörtgen, iki direk):** Brocquière: "iki direk, çapraz kiriş, kalın yün/kıl örtü" [K: BROC1433 ikinci el]; yan duvar 1 m, sırt 2,2–2,6 m [TAHMİN].
- **Kubbeli/topak ev (yurt):** saray çadırlarında; ordugâhta göçebe Türkmen birlikleri ve beyler [SONRAKİ DÖNEM: AKIN-KEŞ2017].
- **İp-kazık:** her çadırın çevresinde 8–16 kazık ve gergi ipi; gerginlik hattı dış yarıçap +1,5–2 m. Çadırlar arası **gergi ipi çarpışmasın diye ≥ 1,5–2,5 m** aralık (aslında tent "kenar-kenara" 1–2 m; sokak 3–5 m) [TAHMİN].
- **Dış/iç kabuk:** büyük çadırlar çift kabuk, dış kabuk mumlu/yağlı kanvas [K: WP-Tents].

### 2.4 Dizilişin mantığı

1. **Merkez:** otağ tepeciği; çevresi zokak.
2. **Birinci halka:** kapıkulu (yeniçeri orta çadırları; sipahi bölükleri yan kanatlarda) [SONRAKİ DÖNEM + K: PEARS1903 "yeniçeri çadırları otağı çevreler"].
3. **Kanatlar:** Rumeli sol, Anadolu sağ; her paşa kendi sancağı etrafında **oba kümeleri** (8–30 çadır; ortada büyük çadır = komutan/bey, önünde sancak) [TAHMİN].
4. **Sokaklar:** çadır sıraları arası 4–6 m yürüme yolu; kümeler arası 8–15 m; "ana cadde" (otağ → cephe), hendeğe dikey **siper yolları**, ikmal yolu (batıdan Edirne yolu) [TAHMİN].
5. **Hayvan bağlama yeri:** çadır kümesinin gerisinde **at kazıkları sıra sıra**; deve yatağı ayrı; öküz/manda ağılı kenarda (koku-rüzgâr) [TAHMİN].
6. **Ocak/kazan:** yeniçeride ortanın kazanı **çadırın önünde**; diğerlerinde 3–5 çadıra bir ocak; ocaklar kuzey-batı (rüzgâr üstü) [TAHMİN].
7. **Helâ ve su:** çadır alanının rüzgâr altında kazılı çukur-hela hendekleri; **su: Lykos (Bayrampaşa) deresi** ve kuyular; su taşıyıcı sakalar (deri tulum) [TAHMİN, alan bilgisi + K: Lykos CSV].
8. **Boşluk:** çadırlar arasında **çiğnenmiş çamurlu zemin**, eşeleme, odun yığını, saman, çuval; ot yok (çiğnenmiş) [TAHMİN].

### 2.5 Renk paleti önerisi (toon, 10 renk; oranlar kanat başına)

Toon üslubu için doygunluğu düşük, siluet okunur. **Hex'ler tamamen [TAHMİN]**; mevcut koddaki `BEZ #d9ccaa`, `KIRMIZI #b3262d` ile uyumlu.

| # | Rol | Hex | Nerede | Oran (çadır alanı) |
|---|---|---|---|---|
| 1 | Ağartılmamış keten (ana) | `#D9CCAA` | yeniçeri, sipahi, eyalet çadırları | %40 |
| 2 | Kirli ham kanvas (gölgeli/yağlı) | `#B8A882` | eyalet, cephe gerisi | %20 |
| 3 | Kıl/keçe koyu kahve | `#6A563C` | akıncı, başıbozuk, hizmet | %12 |
| 4 | Gri-kahve eski bez (yamalı) | `#8F8064` | başıbozuk barınağı | %10 |
| 5 | Soluk beyaz (yeni keten) | `#EFE6CC` | seçkin birlik, paşa çadırı gövdesi | %6 |
| 6 | **Otağ kırmızısı** | `#B3262D` (koyu `#8F2024`) | **yalnız** otağ kompleksi + vezir/paşa çadırları (toplamda ≤ %2) | %2 |
| 7 | Altın (sırma, alem, bordür) | `#D6A93C` | otağ, tuğ topuzu, alem | <%1 |
| 8 | Yeşil (sancak/mescit/ahşap bayrak şeridi) | `#3F6B3D` | mescit çadırı, bazı sancaklar | %2 |
| 9 | Lacivert (halı, tente bordürü, sayebân) | `#28366A` | otağ içi/önü | <%1 |
| 10 | Turuncu (mutfak çadırı, bakır kazan) | `#C87A2E` | mutfak, kazan | %2 |

Kural: **kırmızı çadır ordunun %2'sinden az**. Şu an koddaki `tent_mesh("yuvarlak")` her çadıra kırmızı bant (`Color(0.62,0.22,0.2)`) koyuyor ve `TURLER` bant renkleri lacivert/yeşil/kırmızı → bu, "kırmızı yalnız padişah/vezir hakkı" kuralına aykırı (bkz. §7d).

**Çeşitlilik kuralı (eş boy engeli):** çap dağılımı (kümeler için): küçük 3,0–3,6 m %35; orta 4,2–5,0 m %45; büyük 5,5–7,0 m %15; çok büyük (bey/komutan) 8–12 m %5.
Yükseklikte aynı oran. Her çadıra rastgele yaw, ±%15 ölçek, ±%8 ton (K.ton) ve tek tek ip-kazık. [TAHMİN]

---

## 3. İNSANLAR ve HAYVANLAR ("askerler nerde?")

### 3.1 Sorunun cevabı

İlk karede asker yoktu çünkü sahne çadırlardan ibaretti. Gerçekte üç yerde yoğunlaşırlardı: **(a) ön hat** (hendek kenarı perdesi, siper, batarya: gündüz en kalabalık ve en tehlikeli yer),
**(b) çadır alanı** (yemek, hayvan, nöbet değişimi, talim, ibadet), **(c) hizmet kuşağı** (kazan, demirci, saka, pazar, barut, ağıl). Barbaro'nun 1453'ten kendi sözü (Pears üzerinden): savaş günlerinde düşman
"o kadar çoktu ki **yer ya da başka bir şey görülmüyordu; yalnız yeniçerilerin beyaz başlıkları ve diğer Türklerin kırmızı başlıkları**" [K: PEARS1903, Barbaro s. 27, ikinci el].
Bu cümle ordugâhın görsel imzasıdır: **beyaz başlık (yeniçeri) + kırmızı başlık (diğerleri) noktaları**. Not: Pears'in "red fezes" çevirisi **modern fes (19. yy) değildir**; kırmızı keçe/kumaş başlık (üsküf/kalpak türü) olarak çizin [TAHMİN]. Oyunun Tolga fesi zaten bilinçli anakronizmdir.

### 3.2 Gruplar (kıyafet, silah, renk)

Sayısal oranlar [TAHMİN] (15. yy ordusu için kaynak yok; Ágoston'dan genel sonuç: yaygın yeniçeri tüfeği 16. yy ikinci yarısı).

| Grup | Oran (görünen kişi) | Silah | Başlık/giysi | Kaynak |
|---|---|---|---|---|
| **Yeniçeri** | %12 | **Yay + ok (ana), kısa kılıç/pala, balta, kalkan (küçük ahşap), mızrak/zıpkın; az sayıda el tüfeği/arkebüz (%5–15)** | **Beyaz keçe başlık (börk): Barbaro'nun "beyaz başlık"ı**; dolama (uzun kaftan) lacivert-koyu/kırmızı-bordo, kuşak; boyu bilek altı | Silah: PEARS1903 (Tetaldi, La Brocquière, Barbaro "firelocks that threw leaden balls"); tüfek oranı **[TARTIŞMALI]**; börk detay (sarkık kol) **[SONRAKİ DÖNEM]** |
| **Sipahi / Rumeli–Anadolu atlısı** | %10 | Ok-yay, pala, topuz, kalkan, mızrak; zırh zincir göğüslük/yastıklı "jacque" (kuşatmada çoğu atından inip piyade gibi savaşır) | Beyaz/renkli sarık, boyalı eyer örtüsü; çok çeşitli | PEARS1903 (Philelphus; Leonardo: "kuşatmada atlılar piyade gibi savaştı") |
| **Azap, eyalet piyadesi** | %30 | Yay, mızrak, kılıç, tahta kalkan; çoğu zırhsız | Keçe/yün başlık, sarık, yün dolama, bez kuşak | Tetaldi: yarısı ¼'ten azı zırhlı; geri kalan yastıklı kumaş |
| **Başıbozuk / gönüllü / yağmacı** | %20 | Sopa, bıçak, sapan, ok, kalkan; bir kısmı Hristiyan yağmacı | Paçavra, kürk parçası, hasır başlık | PEARS1903 (poorest Turks + Christians for plunder) |
| **Topçu ve top arabacıları** | %5 | Kürek, kama, zincir, kürek, sepet, ateş mızrağı; barutçular | Önlük/yağlı kumaş, is lekeli; başları bez örtülü | WP-Fall; Kritovulos (top yatağı, barut) |
| **Lağımcı (Sırp madenci), marangoz, demirci** | %4 | Kazma, kürek, tahta destek, el arabası | Gri/kahverengi yün, koyu başlık, kil rengi giysi | PEARS1903 (Novo Brdo madencileri Zağanos'un emrinde; Saksonlar olabilir) |
| **Hristiyan vasal birlikleri** | %2–3 | Sırp süvarisi (Branković, 1500 atlı), diğer vasaller | Kendi giysileri, Balkan mızraklı süvari | WP-Fall (Buc 2020; Ivanović 2019) |
| **Ulema, dervişler, imamlar** | %2 | Silahsız, tespih, bazıları kılıç | Beyaz sarık, yeşil/kahve cübbe; derviş keçe külah | Dervişler: Murad II 1422 kuşatması anlatısı PEARS1903; 1453'te Akşemseddin geleneksel olarak anılır **[TARTIŞMALI, kaynak okunamadı]** |
| **Saka, aşçı, seyis, bakıcı, çadır kurucu** | %8 | Deri tulum, kazan kepçesi, kalem; kırbaç | Önlük, rengârenk karışık | [TAHMİN; WP-Tents: çadır bakım birliği — çadırcılar] |
| **Tüccar, esnaf, çerçi** | %2 | Terazi, çuval | Renkli sarık, tezgâh | Tetaldi (Pears): "hawkers, thieves, plunderers" |
| **Yaralı/ölü taşıyıcılar, cerrah** | %1 | Sedye, battaniye | Kan lekeli beyaz/bej | **[TAHMİN]**; "hastane çadırı" sonraki dönem **[SONRAKİ DÖNEM]** |
| **Bayraktar, tellal, mehter** | %1 | Sancak, davul, zurna, nefir | Renkli sancak şeridi, kırmızı | Davul/zurna: PEARS1903 (gemi yolunda "fifes and drums"); tellal/boru: WP-Fall |

**Giysi rengi:** Çoğu yıkanmamış yün/keten tonları (krem, bej, gri, kahve). Boyalı kumaş (çivit mavisi, kök boya kırmızısı, sarı) azınlıkta ve **statü işareti**. Kıyafet rengi `#CDBF9A`, `#8F8064`, `#6A563C`, `#3A4F78` (çivit), `#8C3A2E` (kök boya kırmızısı), `#E8E0C8` (beyaz sarık/başlık) arasında dağıtılsın [TAHMİN]. **En yakın görsel kaynak** 1479–81 Gentile Bellini'nin İstanbul çizimleri (27 yıl sonra, saray çevresi, ordugâh değil) **[SONRAKİ DÖNEM]**; 16. yy minyatürleri (Süleymanname, Şehname-i Selim Han) daha geç.

### 3.3 Gündüz ve gece (ne yapıyorlar?)

| Saat | Etkinlik | Yer |
|---|---|---|
| Sabah ezan öncesi (~04:30) | Kalkış, abdest, saka kuyruğu, ocak yakma; ilk top atışı gün doğumunda | çadır alanı, dere |
| Sabah | Sabah namazı kümeleri (saf), kazan kaynatma, hayvan yemleme, talim/hücum provası | mescit çadırları |
| Gündüz | Top ateşi (büyük topun günde ≈ 7 atışı + 1 gece [K: Chalkokondyles, PEARS1903]); siper/hendek doldurma, gülle taşıma, top tamiri, ok atışları, nöbet değişimi | ön hat |
| Öğle/ikindi | Namaz, dinlenme, yemek (yeniçeri kazan başına toplanır), pazar yoğun | otağ çevresi, pazar |
| Akşam | Akşam namazı, ateşler, hayvan sulama, çadırlar önünde sohbet; **26 Mayıs: büyük ışıklandırma** | hepsi |
| Gece | Nöbet; devriye; **gece işçiliği**: kule inşası (17–18 Mayıs gecesi tamamlanıp sabah görüldü [K: PEARS1903, Barbaro]), hendek doldurma, lağım kazma; gemi yolu hazırlığı; top ateşi azalır | ön hat |

- **26 Mayıs akşamı** (güneş batışından bir saat sonra): ordugâh boyunca büyük bir aydınlatma, "her çadır görülebiliyordu", gece yarısına kadar süren çığlıklar; ferman: üç gün şükür, bir gün oruç [K: PEARS1903 (Leonardo); Barbaro'nun "her çadırda iki büyük ateş" ifadesi ikinci el özet].
- **24 Mayıs:** Barbaro: Türkler arasında müzik ve ziyafet; genel saldırı haberi [K: PEARS1903].
- **Saldırı öncesi:** gece 28–29 Mayıs hareketlenme, ateşler ve sessizlik [K: ISTANBUL_1453.md; WP-Fall].
- **Kuşatma ortası ağır işler:** gemilerin karadan çekilmesi (21–22 Nisan): ~70–80 gemi, **yağlı tomruk/kızak, 3 mil**, "bir kısmı insan gücüyle, bir kısmı makara, **bir kısmı manda** ile"; gemilerde yelkenler açık, kürekçiler yerinde, **zurna ve davul** çalıyor; ordu şenlikli [K: PEARS1903].

### 3.4 Hayvanlar (kaynaklı)

- **Öküz/manda:** Urban topunu 60 öküz çekti [K: WP-Fall (Norwich 1997); tutarlı]; yanında **400 adam** (Norwich) veya 200 adam [TARTIŞMALI: 200/400/1000]. 120 mil, 42 gün anlatısı tek ikincil kaynak [TARTIŞMALI].
- **Manda:** gemi yolunda [K: PEARS1903].
- **Deve:** yük taşıma; savaş düzeninde deve çevresi (Varna 1444 örneği: "yeniçeri merkezinde çevresinde hendek, onun arkasında develer, onun arkasında kalkan perdesi") [K: PEARS1903; 1444'te; 1453'te ordugâh çevre sırası olarak aynı yöntem **[TAHMİN]**]. Kule derileri: deve veya öküz derisi [K: PEARS1903].
- **At/katır:** süvari, top arabası çekimi, ikmal; atlar çadır gerisinde sıra sıra kazıkta [TAHMİN].
- **Koyun/keçi sürüleri:** et ihtiyacı; ağıllar çevre uçlarında [TAHMİN]; ISTANBUL_1453.md madde 162.
- **Köpek, tavuk, kuş:** ordugâh köpekleri; leş kuşları sur önünde (ölü çoğaldıkça) [TAHMİN].
- **Ses:** **ezan ordugâhta okunur, şehirde okunmaz** [K: ISTANBUL_1453.md 159]; davul-zurna-nefir (mehter) [**TARTIŞMALI**: "mehterhane" kurumunun 1453'teki biçimi bilinmiyor; davul/zurna/boru kesin]; tellal ve boru; hayvan bağırtısı; top gümbürtüsü; nal ve araba tekerleği; demirci çekici; dua ve hep bir ağızdan "Allah Allah" seslenişi.

### 3.5 Sayısal öneri: 70 m'den ve 30 m'den görünen insan sayıları

- **70 m uçuşunda:** her 40×40 m'lik karede **12–25 nokta insan** (çadır alanı); ön hatta **40–80**; otağ çevresinde **30–60**; pazar karesinde 60+; ağıl karesinde 15–30 hayvan. Kaynak yok, [TAHMİN]; sahibin "boş alan istemiyorum" ölçütüne uyumlu.
- **30 m yürürken görüş yarıçapı içinde:** en az **15–25 kişi** (ön hatta 40+), 4–10 hayvan, 3–5 ocak, 2–3 kazan.

---

## 4. TOPLAR ve KUŞATMA ARAÇLARI

### 4.1 Batarya sayısı ve yerleri (kaynaklara göre)

Bkz. §1.4. Özet: **üç ana top istasyonu** (Tekfur Sarayı–Edirnekapı; Pempton/Lykos vadisi; Üçüncü Askerî Kapı) + Silivrikapı çevresi bataryası + Galata'da St. Theodore tepesi bataryası. Phrantzes 14×4; Barbaro 9; modern ~70 top. Kod 14 batarya + Şahi: **makul**; ama Mesoteikhion'daki yoğunluğu Edirnekapı ve Silivrikapı'dan **2–3 kat** artırın: ana saldırı bölgesinde `u ≈ 1000–1700` aralığında toplam top sayısının ≥ %45'i [TAHMİN, Pears'ın "üç yarık" analizi].

### 4.2 Şahi / "Basilica" (Urban topu)

| Özellik | Değer | Kaynak |
|---|---|---|
| Boy | ≈ 27 ft ≈ **8,2 m** (Edirne'de dökülmüş, ~3 ay) | [K: WP-Fall (Runciman 1965)] |
| Gülle | Taş; **600 libre (≈ 270 kg)** (WP-Fall) / **1200 libre** (Leonardo, Pears) | [TARTIŞMALI] |
| Gülle çevresi | **88 inç ≈ 2,24 m çevre → çap ≈ 70 cm** (Leonardo ölçtü; Pears iki hayatta kalan güllede doğruladı) | [K: PEARS1903] |
| Gülle kaynağı | Karadeniz kıyısından taşınmış taş | [K: PEARS1903] |
| Menzil | > 1 mil (1,6 km) | [K: WP-Fall] |
| Ateş sıklığı | **Günde ≈ 7 atış + 1 gece** (Chalkokondyles); alt: 1 atış/3 saat yükleme ⇒ günde ≤ 7; "günde 3 atış" tek kaynak | [K: PEARS1903; WP-Fall] [TARTIŞMALI] |
| Çekim | **60 öküz + 200–400 adam** (+ ~50 marangoz ve 200 usta yol için, Karaca Paşa) | [K: WP-Fall] [TARTIŞMALI] |
| Yatak | **Tekerlek yok**; hedefe yöneltilip **ahşap bloklarla (yatak) gömülür**; atış sonrası geri kayar, yeniden yöneltilir | [K: Kritovulos aktarımı, PEARS1903] |
| Yeri | İlk Kaligaria (Blakhernai tarafı) civarı; sonra Lykos vadisi; "en büyük top Mesoteikhion'da, otağ önünde" | [K: PEARS1903 (Leonardo, Chalkokondyles)] [TARTIŞMALI] |
| Çatlama | "6 hafta sonra çatladı/patladı" yalnız Leonardo ve Nestor İskender'de | [K: WP-Fall] [TARTIŞMALI] |

**Uygulama (Şahi):** namlu 8 m, ağız çapı ≈ 75 cm [TAHMİN, gülle çapından]; kalın tomruk yatak; arkada **ağır çıkrık (vinç)** ve **sürükleme kızağı**; çevrede 2,5–3 m yükseklikte tomruk+toprak siper; namlu için kapaklı delik; **öküz sırası** (kod 6 öküz çiziyor: gerçekte 60; en az 12–20 göster, gerisi yolda/ağılda). Gülle piramidi çapı 70 cm taş küreler, yığın 3–4 katman.

### 4.3 Orta ve küçük toplar, havan

- **Orta ve küçük toplar:** çok sayıda; "bombard, kolonborna, çok sayıda küçük top" [K: PEARS1903; Tetaldi 10.000 abartılı]. Kısa namlu, ahşap yatak; **tekerleksiz** (Pears: "none were mounted on wheels") [K: PEARS1903] — sahra topu arabası değil, batarya yataklarında.
- **Havan (yüksek açılı):** 21 Nisan'da Galata'nın St. Theodore tepesinden **Haliç ağzındaki zincir gemilerine ~100 atış**, bir gemi battı [K: PEARS1903]. Bunu "havan" diye adlandıran kaynak okumadım; **yüksek tepeden alçak açıyla top** olabilir. Oyunda "tepe bataryası" olarak çizin; "havan" adı [TARTIŞMALI]. Havan benzeri kısa kalın namlu gösterecekseniz küçük sayıda (2–3) yapın [TAHMİN].
- **El silahı:** "ateşli kilitli silah (firelock/fusil)" Barbaro 18 Mayıs'taki çatışmada kurşun atar [K: PEARS1903, dn. 306 "zarabotane"]. Küçük sayıda.

### 4.4 Top siperleri ve ateş hattı

- Ön perde: **ahşap perde (palisade), üstüne toprak yığılı, ateş delikleri aralıklı**, hendek kenarına çok yakın [K: PEARS1903 (Chalkokondyles s. 159)].
- Batarya gövdesi (mevcut kod): toprak teras 1 m, ön sedde 1,5–2,6 m, boşluk 2,6 m. Gerçek ölçü kaynaksız; mantıklı [TAHMİN]. **Gabion** (toprak dolu sepet) ve **fıçı/çuval siper** 15. yy'da kullanılıyordu, ama 1453 Osmanlı özelinde kaynak yok [TAHMİN].
- **Barut ve gülle yığınları:** barut fıçıları batarya gerisinde kapaklı çukur; taş gülle piramitleri; kurşun gülle (küçük toplar için). **Çadırdan ≥ 50 m** [TAHMİN].
- **Hendek doldurma:** top ateşiyle yıkılan duvar parçaları, tahta, çalı, fıçı; Kritovulos §142 "hendeği toplar önünde doldurdular" [K: KRIT-DRM]; 18 Mayıs'taki kule bu amaçla da hendeğe sürülüyor; savunmacı barut fıçısı + çalı çırpı yakarak yok etti [K: PEARS1903]. Sonuç: Lykos vadisinde hendek ve dış sur tamamen doldu (yıkıntıyla) [K: PEARS1903, Tetaldi: ~1200 ft'lik yarık].

### 4.5 Kuşatma kulesi (18 Mayıs)

- Gece boyunca inşa edilmiş; sabah görüldü; "bütün Hristiyanlar bir ayda yapamazdı" [K: PEARS1903, Barbaro].
- Yeri: **Romanos (Pempton) kapısı yakınında**; ölçü: dış surun üstünü aşacak yükseklikte (dış sur ~8,5 m + kule) [K: PEARS1903]. **Tekerlek/tomruk üzerinde**, kalın kiriş iskelet, içi kısmen toprakla dolu (!), dışı **üç kat deve veya sığır derisi** kaplı; basamaklı üst platform; **ordugâha giden yol da kaplanmış (örtülü yol)**; tepeden **merdivenler** atılabiliyor [K: PEARS1903]. Barbaro: duvara 10 adım kala (hendeğin içinde) [TARTIŞMALI]. Hendeğe malzeme **üç açıklıktan** atılıyor, lağım kazımı için de [K: PEARS1903].
- Sonuç: gece Hristiyanlar kuleyi barut fıçıları ve yanan çalı ile yakıp yıktı; ikinci kule Pege/Üçüncü Askerî Kapı karşısı; başka kuleler olası [K: PEARS1903] [TARTIŞMALI].
- Kod: `ordugah_yapi.gd:build_kule` 4,6×4,6 m gövde, 13 m, üç kat deri, merdiven, bayrak: **iyi, makul**. Ölçü [TAHMİN] ama kaynakla uyumlu.

### 4.6 Merdiven, manto/tosbağa, lağım

- **Merdiven:** hücum merdivenleri çok sayıda; kuşatma kulesi merdiveni; hendeğe iniş merdivenleri [K: PEARS1903 + TAHMİN].
- **Manto (taşınır kalkan perde)/tosbağa (kalkanlı koruma):** 15. yy'da yaygın; 1453 Osmanlı özelinde **kaynak okumadım** [TAHMİN]. Ahşap, deri kaplı, sekiz tekerlekli kulübe şeklinde.
- **Lağım ağzı:** Sırp madenciler, Zağanos emrinde. **16 Mayıs'ta ilk lağım bulundu**; sonra 21, 23, 24, 25 Mayıs; Edirnekapı–Tekfur Sarayı arası; hendek ve dış sur altına; **tomruk destekli** galeri; savunmacı karşı-lağım (Johannes Grant), Yunan ateşi, **23 Mayıs'ta iki esir söz verdi, tüm lağımlar bulundu** [K: PEARS1903; WP-Fall]. Oyun: lağım ağzı = küçük toprak yığın + tomruk destekli giriş, çıkarılan toprak dumanı, kazı toprağı yığını, çevrede 6–10 işçi.

### 4.7 Kızak yolu ve fıçı köprüsü

- **Kızak yolu (21–22 Nisan):** **Tophane civarından Kasımpaşa vadisine** düzeltilmiş yol; kalas ve tomruk döşeli; **6 mızrak ≈ 13–14 ft (≈ 4 m)** uzunlukta yağlı silindirler (kütükler); gemi beşikleri (iskele kenarlarına direk takılı); ilk deneme küçük fusta; 70–80 gemi; yağlar; manda, makara, insan [K: PEARS1903]. Rota: Boğaz kıyısı → tepe geçişi (Taksim yönü) → Kasımpaşa; **~3 mil**; iniş noktası tartışmalı [K: ISTANBUL_1453.md; WP-Fall] [TARTIŞMALI]. Kod kızak yolu Beşiktaş–Kasımpaşa çizgisi ile uyumlu.
- **Fıçı köprüsü:** **Cynegion (Ayvansaray) civarı, Haliç'in üst ucu, kara surlarının Haliç surlarına bağlandığı yer**; **1000'den fazla şarap fıçısı**, halatlarla bağlı; genişlik **iki fıçı boyuna**; üstüne kirişler, kalas; **yan yana beş asker yürüyebilir**; amaç haberleşme ve **fıçı sallar (pontoons) üzerine top koymak** [K: PEARS1903]. Kritovulos §117: **Keramika'dan** (Ceramica) bir köprü [K: KRIT-DRM]. WP-Fall: yeri belirsiz. Oyun `fici_kopru` Kasımpaşa (kuzey) – Cibali (güney) arası yerleştiriyor → **Pears ve Kritovulos'la uyumsuz**: üst Haliç, Ayvansaray/Eyüp tarafı olmalı [bkz. §7d].
