# Görev: "Gerçek Tarih Bu Değil" oyununun görsel ve işitsel varlıklarını üret

Sen bu oyunun sanat ve ses ekibisin. Oyun Godot 4.4 ile yapılmış, birinci şahıs, Monty Python tadında bir zaman yolculuğu komedisi. Tolga adında bir sigortacı, Hikmet Amca'nın garajda yaptığı zaman makinesiyle yanlışlıkla 1453 İstanbul'una düşüyor. Oynanabilir üç karakter var: **Tolga** (1453'te), **Hikmet Amca** (2026'da garajda, pijamalı mucit) ve **Denetçi Nihat** (Zaman Bürosu'nun fötr şapkalı bürokratı).

Oyundaki 3B dünya şu an tamamen kodla, düz renkli kutu ve silindirlerle kuruluyor. Senin işin bu belgedeki listeyi **eksiksiz** üretmek. Her dosyayı belirtilen **yola ve adla** teslim et. Aynı adla konan dosyayı oyun kendiliğinden kullanır. Yeni klasörlerdeki dosyaları geliştirici koda bağlayacak.

**Öncelik sırası:** 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9. Her görevi bitirince bir sonrakine geç.

---

## Bütün görevler için kurallar

1. **Üslup:**
   - Düz renkli yüzeyler; kalın, koyu lacivert kontur (`#1d2330`, 512 px'lik görselde 9–10 px).
   - Yumuşak köşeler; sıcak ve hafif karikatürize.
   - Referans: Tintin'in çizgisi ile sade 2B animasyon afişlerinin arası.
   - Fotoğraf dokusu, gerçekçi gölge ve parlak 3B render **yok**.
2. **Ana palet:**

   | Renk | Kod |
   |---|---|
   | Krem | `#f3ecd8` |
   | Fes kırmızısı | `#b3262d` |
   | Lacivert kontur | `#1d2330` |
   | Büro grisi | `#6a6e76` |
   | Bizans moru | `#5a2a6a` |
   | Osmanlı altını | `#d8b040` |
   | Ekran yeşili | `#6ff2c8` |
   | Garaj mavisi | `#5d6673` |

3. **Dil:** Görselin içinde yazı varsa Türkçe olsun. Bizans'la ilgili yazılar Yunan harfleriyle (Α Β Γ Δ...).
4. **Tarihî saygı:** İmparator Konstantinos ve Fatih Sultan Mehmet **karikatürize edilmez**. İkisi de saygılı ve ağırbaşlı çizilir. Komedi yan karakterlerden ve durumlardan gelir.
5. **Lisans:** Her şey oyunla birlikte ticari olarak dağıtılabilir olmalı. Üçüncü taraf kaynak kullanırsan (yazı tipi, ses) yalnızca **CC0, CC-BY veya OFL** lisanslı olanları kullan ve kaynağını teslim raporuna yaz.
6. **Teslim raporu:** İşin sonunda `assets/CREDITS.md` dosyası oluştur. İçinde her dosyanın yolu, ne olduğu ve dış kaynak kullanıldıysa kaynağı ve lisansı yazsın.

---

## Görev 1 — Eksik konuşmacı portrelerini çiz

**Yol:** `assets/art/portraits/<ad>.svg`

**Şartlar:**
- 512×512 SVG, köşeleri yuvarlatılmış kare arka plan (rx=64), büst çekim.
- Yüz görselin üst yarısında olsun.
- Oyunda 112×112 px görünür. Büyük kafa, net siluet ve en fazla 1–2 ayırt edici öğe kullan.
- Arka plan, karakter başına tek renkli bir radyal degrade.
- Mevcut `tolga.svg` ve `hikmet.svg` dosyalarını aç, aynı çizgi kalınlığını ve oranları kullan.

| Dosya | Karakter | Tarif | Arka plan |
|---|---|---|---|
| `kadri.svg` | Aşçıbaşı Kadri | İri yapılı, uzun beyaz aşçı külahı, önlük, kalın siyah bıyık, elinde kepçe. Sert ama sevecen. | sıcak turuncu |
| `lutfi.svg` | Tercüman Lütfi | Hevesli, kurnaz gülümseme, yeşil kaftan, küçük beyaz sarık, parmaklarında mürekkep lekesi. | nane yeşili |
| `urban.svg` | Usta Urban | Macar topçu ustası. Yüzü is lekeli, deri önlük, kulaklarında pamuk, gururlu duruş. | kurum grisi |
| `hasan.svg` | Hasan | Yeniçeri. Uzun beyaz börk, **kırmızı** kaftan, bıyık, biraz kafası karışık. | açık kırmızı |
| `huseyin.svg` | Hüseyin | Hasan'ın neredeyse aynısı (şaka bu). Aynı börk, **mavi** kaftan. | açık mavi |
| `candarli.svg` | Kukuletalı adam ("Kimse") | Siyah kukuleta, yüz gölgede, yalnızca bıyık görünür. | koyu gri |
| `pasha.svg` | Çandarlı Halil Paşa | Yaşlı sadrazam. **Fazla büyük** beyaz sarık, gri sakal, yeşil kaftan; kılık değiştirmiş ama belli oluyor. | zeytin |
| `theodoros.svg` | Logothetes Theodoros | Bizans bürokratı. Mor cüppe, kırmızı yuvarlak kamelaukion şapka, gri sakal, elinde mühür. Nihat'ın 1453'teki aynası. | lavanta |
| `clerk.svg` | Bizans memuru | Theodoros'un sadeleşmiş, genç hâli. Kahverengi cüppe. | bej |
| `giust.svg` | Giovanni Giustiniani | Cenevizli komutan. Gümüş zırh, kırmızı tüylü miğfer, kısa sakal, tüccar gözü. | çelik mavisi |
| `emperor.svg` | İmparator Konstantinos XI | Mor cüppe, altın taç, ağırbaşlı, yorgun ama sıcak bakış. Saygılı çizim. | koyu mor |
| `fatih.svg` | Fatih Sultan Mehmet | 21 yaşında genç sultan. Büyük beyaz kavuk, kırmızı-altın kaftan, ince bıyık, keskin ve meraklı bakış. Saygılı çizim. | kırmızı-altın |
| `cemil.svg` | Hırdavatçı Cemil | Yaşlı esnaf. Mavi iş önlüğü, kahverengi hırka, gözlük, elinde ince belli çay bardağı. | gece mavisi |
| `agent1.svg` | Ajan 7/c | Zaman Bürosu ajanı. Gri yağmurluk, fötr şapka, gözlük, el feneri. | Büro grisi |
| `agent2.svg` | Ajan 12/b | Aynı üniforma, bıyıklı, biraz daha esmer. | Büro grisi |
| `soldier.svg` | Genç asker | Genç yeniçeri, yeşil kaftan, börk, okuma yazma bilmiyor ama annesine mektup yazdırıyor. | yeşil |
| `rower.svg` | Kürekçi | Bizans kadırgası kürekçisi. Terli, çizgili bere, kaslı kollar. | deniz mavisi |
| `sinerji.svg` | Sinerji (tavuk) | Niko'nun tavuğu, gizli karakter. Kendinden emin bir tavuk. | sarı |

**Ayrıca:** Mevcut 7 portreyi (`tolga`, `tolga_fez`, `hikmet`, `nihat`, `mufide`, `riza`, `niko`) aynı kalitede yeniden çiz ve üstüne yaz. Tarifler:
- **Tolga:** 30'larında sigortacı; siyah redingot, beyaz gömlek, şaşkın ve iyimser. `tolga_fez` aynı görsel, üstüne kırmızı fes ve siyah püskül.
- **Hikmet:** 70'lerinde mucit; açık mavi çizgili pijama, kalın gözlük, dağınık beyaz saç, cebinden koli bandı sarkıyor.
- **Nihat:** Gri takım, fötr şapka, ince bıyık, ciddi bürokrat bakışı.
- **Müfide Hanım:** Topuzlu gri saç, gözlük zinciri, Büro'nun annesi gibi.
- **Rıza:** Kostüm deposunun sorumlusu; fötr şapka, askılı pantolon.
- **Niko:** Bizans nöbetçisi; miğfer, sakal, kırmızı tunik, iyi kalpli.

## Görev 2 — Çanta eşyası ikonlarını yeniden çiz

**Yol:** `assets/art/icons/<ad>.svg`, mevcut dosyaların üstüne yaz.

**Şartlar:**
- 256×256 SVG, krem (`#f3ecd8`) yuvarlak kare zemin (rx=40), eşya ortada.
- Oyunda 52×52 px görünür. Çok sade tut, tek bakışta tanınmalı.

| Dosya | Eşya | Not |
|---|---|---|
| `phone.svg` | Akıllı telefon | Ekranda kırmızı "%1" pil göstergesi |
| `lighter.svg` | Plastik çakmak | Küçük alev |
| `book.svg` | Tarih kitabı | Kalın, kapakta fes silueti |
| `chickpeas.svg` | Leblebi | Kâğıt külahta sarı leblebi |
| `powerbank.svg` | Powerbank | Kablosu sarkıyor |
| `tape.svg` | Koli bandı | Kahverengi rulo. **Oyunun simgesi, en özenli bu olsun** |
| `thermos.svg` | Termos | Ekose desenli eski termos |
| `selfie.svg` | Selfie çubuğu | Açılmış, ucunda telefon |
| `cologne.svg` | Limon kolonyası | Klasik şişe, limon etiketi |
| `cube.svg` | Rubik küpü | Karışık renkler |

## Görev 3 — Logo ve afişler

**Yol:** `assets/art/posters/`

| Dosya | Boyut | Tarif |
|---|---|---|
| `fez.svg` | 256×256 | Fes ve püskülü. Oyunun amblemi, başlık ekranında 130 px yükseklikte görünür. |
| `logo.svg` | 1024×384 | **Yeni.** "GERÇEK TARİH BU DEĞİL" yazılı ana logo. Fes, zaman makinesi halkası ve bir koli bandı şeridiyle. Altında küçük "Not a History Game". Şeffaf arka plan. |
| `calendar.svg` | 300×400 | 1970'ler tarzı duvar takvimi. Bir sayfa: "Nisan"; 22 rakamı kırmızı daire içinde. |
| `patent.svg` | 400×300 | "ZAMANATÖR 3000 — Patent Başvurusu". Teknik çizim, iki dönen halka, bir kahve lekesi, "RED" damgası. |
| `form_z1.svg` | 300×420 | **Yeni.** Zaman Bürosu'nun kuruluş belgesi "Form Z-1". Resmî, eski, damgalı; imza yerinde yalnızca "T." |
| `bureau_sign.svg` | 512×128 | **Yeni.** "ZAMAN BÜROSU · Size zaman ayırıyoruz" tabelası; minibüsün yanı ve Büro kapısı için. |

## Görev 4 — Yazı tipi ve simge ikonları (acil)

Oyundaki yazı tipi bazı simgeleri çizemiyor; arayüzde boş kutu ya da daire olarak görünüyorlar.

**4a. Yazı tipi — yol:** `assets/fonts/`

- Türkçe (ç ğ ı İ ö ş ü) ve Yunanca harfleri tam destekleyen, okunaklı, sıcak bir sans-serif bul. Öneri: **Nunito** ya da **Baloo 2**, OFL lisanslı.
- Normal ağırlığı `ui_regular.ttf`, kalın ağırlığı `ui_bold.ttf` adıyla koy.
- Bölüm başlıkları için karakterli ikinci bir yazı tipi bul. Öneri: **Rye** ya da **Alfa Slab One** tarzı, OFL. `title.ttf` adıyla koy.
- Lisans dosyalarını `assets/fonts/LICENSE_<ad>.txt` olarak ekle.

**4b. Simge ikonları — yol:** `assets/art/symbols/<ad>.svg`

- 64×64 SVG, şeffaf arka plan, tek renkli krem (`#f2e6c9`) ve ince kontur. Metin satırı içinde küçük görünecek.

| Dosya | Simge | Anlamı |
|---|---|---|
| `timer.svg` | ⏱ | Süreli karar |
| `phone.svg` | 📱 | Telefon |
| `clipboard.svg` | 📋 | Form |
| `briefcase.svg` | 💼 | Plaza jargonu |
| `radar.svg` | 📡 | Paradoks Tarayıcı |
| `tea.svg` | ☕ | Çay |
| `folder.svg` | 🗂 | Arşiv / meslek sohbeti |
| `flashlight.svg` | 🔦 | Ajanın el feneri |
| `card.svg` | 📇 | Kartvizit |
| `pot.svg` | 🍲 | Mutfak |
| `speech.svg` | 🗣 | Tercüman |
| `bomb.svg` | 💣 | Top |
| `columns.svg` | 🏛 | Bizans |
| `envelope.svg` | ✉ | Mektup |
| `ice.svg` | 🧊 | Küp |
| `box.svg` | 📦 | Koli bandı |
| `clock.svg` | 🕐 | Saat |

## Görev 5 — Bölüm kapakları

**Yol:** `assets/art/covers/ch<no>.png` (şube bölümlerinde `ch4a.png`, `ch4b.png` gibi)

**Şartlar:**
- 1920×1080 PNG, sahneyi anlatan tek bir illüstrasyon, oyunun üslubunda.
- Başlık yazısını görselin içine **koyma**; oyun kendisi yazacak.
- Alt üçte biri daha sade ve koyu olsun, çünkü yazı oraya binecek.

| Dosya | Bölüm | Sahne |
|---|---|---|
| `ch1.png` | 1 — Zamanatör | Gece 03:12, dar bir garaj. Floresan titriyor, ortada koli bantlı iki dönen halkalı zaman makinesi. Redingotlu Tolga çantasını hazırlıyor, pijamalı Hikmet Amca heyecanla panele bakıyor. |
| `ch2.png` | 2 — Yağlı Kızaklar | 22 Nisan 1453 sabahı. Osmanlı gemileri yağlanmış kızaklarla karadan Haliç'e indiriliyor; fesli Tolga bir kızağın üstünde kayarak denize doğru düşüyor. |
| `ch3.png` | 3 — Vaka 1453-T | Zamanın dışında Zaman Bürosu: sonsuz koridor, yıllarla numaralı kapılar, dev kâğıt kuleleri. Masasında Denetçi Nihat, önünde "VAKA 1453-T" dosyası. |
| `ch4a.png` | 4 — İlk Gece (Ordugâh) | Gece Osmanlı ordugâhı, meşaleler. Esir çadırından kafasını uzatan Tolga, tartışan iki nöbetçi Hasan ile Hüseyin. |
| `ch4b.png` | 4 — İlk Gece (Deniz surları) | Gece, Haliç zinciri, Bizans deniz surları. Zincirin üstünde dengede yürüyen Tolga, yukarıdan bir tavuk fırlatan Niko. |
| `ch5.png` | 5 — Garajda Gece | 2026, gece 04:00. Garajın önünde gri "ZAMAN BÜROSU" minibüsü, projektörü kepenk aralığından içeri vuruyor. İçeride telsize eğilmiş Hikmet Amca. |
| `ch6a.png` | 6 — Ordugâh | Gündüz ordugâhı. Aşçı Kadri, tercüman Lütfi, Urban ve çatlak dev top, pazarda kaçan keçi. Kaftanlı Tolga ortada. |
| `ch6b.png` | 6 — Surların İçi | Konstantinopolis'te yedi odalı kançılarya koridoru, her kapıda bir Yunan harfi. Önünde mühür sırası bekleyen Tolga. |
| `ch7.png` | 7 — Saha Çalışması | Tarlanın ortasında tek başına duran gri "Saha Kapısı". Fötr şapkalı Nihat pirinç Paradoks Tarayıcı'yla leblebi kabuklarını tarıyor; uzakta mavi bir Tolga hologramı. |
| `ch8.png` | 8 — Hırdavatçı | 2026, 05:00. Pembe neonlu "NÖBETÇİ HIRDAVAT" dükkânı. Pijamalı Hikmet raflar arasında saklanıyor, iki gri ajanın el feneri ışığı reyonda. |
| `ch9.png` | 9 — Teklifler | Sabah, ordugâh. Tolga'nın etrafında ona bir şey uzatan eller: Kadri'nin kepçesi, Urban'ın gülle hesabı, Lütfi'nin heyet listesi, Çandarlı'nın mühürlü mektubu, Theodoros'un formu. |
| `ch10.png` | 10 — Huzur | Padişah'ın otağı içinde, halılar ve fener ışığı. Genç Fatih tahtta, karşısında eğilen fesli Tolga. Saygılı, sıcak bir sahne. |

## Görev 6 — Akış şeması başlık şeritleri

**Yol:** `assets/art/flow/ch<no>.png`

- 1024×256 PNG, yatay şerit, sade ve koyu tonlarda.
- Bölüm sonu akış şemasının üstünde görünecek.
- Her bölümün en simgesel nesnesi ortada olsun: 1 zaman makinesi, 2 kızak, 3 dosya, 4 meşale, 5 telsiz, 6 mühür, 7 tarayıcı, 8 kondansatör, 9 mühürlü mektup.
- Arka planı koyu lacivert (`#141824`), nesnesi krem çizgili olsun.

## Görev 7 — Low-poly 3B modeller

**Yol:** `assets/models/<ad>.glb`

**Teknik şartlar:**
- **glTF 2.0 binary (.glb).** Y yukarı, 1 birim = 1 metre.
- **Orijin ayakların ortasında ve yerde.** Model **+Z yönüne** bakmalı.
- **Low-poly:** karakter başına en fazla 3.000 üçgen, bina ve eşya için en fazla 5.000.
- **Doku kullanma.** Renkleri **vertex color** ile ya da her renk için ayrı düz malzemeyle ver (malzeme adı = renk, örn. `fez_red`). Paleti yukarıdan al.
- **Karakterler iskeletsiz ve parçalı olsun:** oyun animasyonu kodla yapıyor.
  - Her parçayı ayrı bir düğüm (node) olarak ver: `Body`, `Head`, `ArmL`, `ArmR`, `LegL`, `LegR`, `Hat`.
  - **Pivotlar eklemlerde olsun:** kollar omuzda, bacaklar kalçada, kafa boyunda.
  - Kafa içinde, konuşurken açılıp kapanacak ayrı bir `Mouth` düğümü olsun.
- Karakter boyu yaklaşık 1,75 m olsun. Oranlar hafif karikatürize: kafa biraz büyük.

| Dosya | Model | Not |
|---|---|---|
| `tolga.glb` | Tolga | Redingot, beyaz gömlek. `Hat` düğümü fes olsun, ayrıca `tolga_nofez.glb` ver. |
| `hikmet.glb` | Hikmet Amca | Çizgili pijama, terlik, gözlük |
| `nihat.glb` | Denetçi Nihat | Gri takım, fötr |
| `fatih.glb` | Fatih Sultan Mehmet | Büyük kavuk, kırmızı-altın kaftan, saygılı |
| `janissary.glb` | Yeniçeri (Hasan/Hüseyin) | Börk, kaftan. Kaftan malzemesi ayrı olsun ki kodla kırmızı ya da mavi boyansın |
| `kadri.glb`, `lutfi.glb`, `urban.glb` | Ordugâh karakterleri | Portre tariflerindeki gibi |
| `niko.glb`, `theodoros.glb`, `emperor.glb`, `giust.glb` | Bizans karakterleri | Portre tariflerindeki gibi |
| `agent.glb` | Büro ajanı | Gri yağmurluk, fötr, elinde el feneri (`Lamp` düğümü) |
| `zamanator.glb` | Zaman makinesi | Platform + iki dönen halka (`RingA`, `RingB` ayrı düğümler, merkezde pivot), halkalara sarılı koli bandı, tepede huni ve kırmızı lamba. Yaklaşık 2,4 m çap, 3 m yükseklik |
| `otag.glb` | Padişah otağı | Kırmızı-altın, sivri tepeli, yaklaşık 14 m çap. Girişi +Z tarafında |
| `cannon.glb` | Urban'ın büyük topu | Bronz namlu, ahşap kızak, namluda koli bandıyla sarılı bir çatlak. Yaklaşık 8 m uzunluk |
| `tent.glb` | Ordugâh çadırı | Tek direkli yuvarlak çadır, bant rengi ayrı malzeme |
| `van.glb` | Zaman Bürosu minibüsü | Gri, tavanda projektör, yanda "ZAMAN BÜROSU" yazısı (yazı ayrı düz malzeme ya da boş bırak) |
| `goat.glb` | Keçi | Bacaklar ayrı düğüm (`Leg0`–`Leg3`) |
| `chicken.glb` | Tavuk (Sinerji) | Kanatlar ayrı düğüm |

## Görev 8 — Ses efektleri

**Yol:** `assets/audio/sfx/<ad>.ogg`

- OGG Vorbis, 44,1 kHz, mono, sessizliği baştan ve sondan kırpılmış, tepe değeri −3 dB.
- CC0 kaynak ya da kendi üretimin olabilir.

| Dosya | Ses | Süre |
|---|---|---|
| `machine_spin.ogg` | Zaman makinesi halkalarının dönüşü, yükselen uğultu (döngüye girebilir) | 3 sn, döngü |
| `machine_jump.ogg` | Zaman sıçraması: vınlama + patlama + cam çınlaması | 2 sn |
| `radio_static.ogg` | Telsiz cızırtısı | 1,5 sn |
| `radio_beep.ogg` | Telsiz bip sesi | 0,3 sn |
| `typewriter.ogg` | Tek daktilo tuşu | 0,1 sn |
| `typewriter_bell.ogg` | Daktilo satır sonu zili | 0,6 sn |
| `stamp.ogg` | Mühür vurma | 0,4 sn |
| `paper_tear.ogg` | Kâğıt yırtılması | 0,8 sn |
| `cannon.ogg` | Büyük top atışı, uzun yankı | 3 sn |
| `chicken.ogg` | Tavuk gıdaklaması (komik) | 1 sn |
| `goat.ogg` | Keçi meleme | 1 sn |
| `splash.ogg` | Denize düşme | 1,5 sn |
| `kick_metal.ogg` | Metal panele tekme | 0,5 sn |
| `door_metal.ogg` | Garaj kepengi | 2 sn |
| `footstep_grass.ogg`, `footstep_stone.ogg`, `footstep_wood.ogg` | Ayak sesi, her biri 4 varyasyon (`_1`…`_4`) | 0,3 sn |
| `crowd_camp.ogg` | Ordugâh ortam sesi: uzak konuşmalar, at, demirci (döngü) | 30 sn, döngü |
| `night_camp.ogg` | Gece ordugâhı: cırcır böceği, meşale çıtırtısı (döngü) | 30 sn, döngü |
| `city_2026.ogg` | 2026 gece sokağı: uzak trafik, köpek (döngü) | 30 sn, döngü |
| `fluorescent.ogg` | Floresan vızıltısı (döngü) | 5 sn, döngü |
| `ui_select.ogg`, `ui_confirm.ogg` | Menü seçimi ve onay | 0,2 sn |
| `timer_tick.ogg` | Süreli karar tik-takı | 0,5 sn |

## Görev 9 — Müzik

**Yol:** `assets/audio/music/<ad>.ogg`

- OGG Vorbis, 44,1 kHz, stereo, **kesintisiz döngü**: bitiş başa oturmalı.
- Çalgılar: ney, ud, kanun, darbuka ve mehter davulu. Bunlara komik bir tuba ya da fagot, 2026 sahnelerinde de hafif synth karışır.
- CC0/CC-BY ya da kendi üretimin olabilir.

| Dosya | Ruh hâli | Süre |
|---|---|---|
| `theme.ogg` | Ana tema: mehter ritmi üstüne muzip bir melodi. Başlık ekranı. | 90 sn |
| `camp_day.ogg` | Ordugâh gündüz, hareketli ve hafif | 120 sn |
| `camp_night.ogg` | Gece gizlilik, ince ve gergin | 120 sn |
| `byzantium.ogg` | Bizans, ağır Bizans ilahisi tadında ama komik bir bürokrasi ritmiyle | 120 sn |
| `bureau.ogg` | Zaman Bürosu: daktilo ritmi, bekleme salonu müziği | 90 sn |
| `garage.ogg` | Hikmet'in garajı, gece, yalnız ve sıcak | 90 sn |
| `chase.ogg` | Kovalamaca ve süreli sahneler, hızlı darbuka | 60 sn |
| `tender.ogg` | Duygusal anlar (1977 itirafı, huzura çıkış), tek ney | 60 sn |
| `flowchart.ogg` | Bölüm sonu akış şeması, düşünceli ve kısa | 45 sn |
