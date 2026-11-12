DURUM: DEVAM EDİYOR (bölüm 1–2 yazıldı; 3–7 sürüyor). Yedi bölüm de dolunca bu satır `DURUM: TAMAM` olacak.

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

