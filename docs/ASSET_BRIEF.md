# Görsel iş listesi (dış üretim için)

Oyundaki 3B dünya (karakterler, çadırlar, top, garaj...) tamamen kodla üretiliyor. Bu belge, **dosya olarak duran** ve dışarıda (başka bir yapay zekâ ya da çizer) yeniden çizilebilecek görselleri listeler. Dosyalar aynı adla aynı yola konursa oyun onları kendiliğinden kullanır.

## Ortak kurallar

- **Biçim:** SVG tercih edilir. PNG de olur (şeffaf arka plan, en az 2× çözünürlük); PNG gelirse koddaki `.svg` uzantısı değiştirilir.
- **Üslup:** Düz renkli, kalın koyu kontur (`#1d2330`, yaklaşık 9–10 px @512), yumuşak köşeler, sıcak ve biraz karikatürize. Monty Python / "Kim 500 Milyar İster" değil; **"Tintin + Pixar'ın sade 2B afişleri"** arası. Gerçekçi gölge, degrade yüzey, fotoğraf dokusu yok.
- **Palet:** krem `#f3ecd8`, fes kırmızısı `#b3262d`, lacivert `#1d2330`, Büro grisi `#6a6e76`, Bizans moru `#5a2a6a`, altın `#d8b040`, zümrüt `#6ff2c8` (ekran ışıkları).
- **Metin:** Görselin içinde yazı olacaksa Türkçe; Bizans için Yunanca harfler (Α Β Γ...).
- **Lisans:** Üretilen görseller oyunda dağıtılabilir olmalı.

## 1. Konuşmacı portreleri — `assets/art/portraits/`

- **Boyut:** 512×512, köşeleri yuvarlatılmış kare arka plan (rx≈64), büst çekim, yüz ekranın üst yarısında.
- **Görünür boyut:** Diyalog kutusunda 112×112 px. Küçükte okunmalı: büyük kafa, net siluet, 1–2 ayırt edici öğe.
- **Arka plan:** Karakter başına tek renkli radyal degrade (aşağıda öneri var).

### Mevcut olanlar (yeniden çizilebilir)

| Dosya | Karakter | Tarif |
|---|---|---|
| `tolga.svg` | Tolga | 30'larında sigortacı; siyah redingot, beyaz gömlek, şaşkın iyimser yüz. Mavi arka plan |
| `tolga_fez.svg` | Tolga (fesli) | Aynısı + kırmızı fes, siyah püskül |
| `hikmet.svg` | Hikmet Amca | 70'lerinde mucit; açık mavi çizgili pijama, kalın gözlük, dağınık beyaz saç, tamirci ellerinde bant. Turuncu arka plan |
| `nihat.svg` | Denetçi Nihat | Gri takım, fötr şapka, ince bıyık, ciddi bürokrat bakışı. Mor arka plan |
| `mufide.svg` | Başdenetçi Müfide Hanım | Topuzlu gri saç, gözlük zinciri, Büro'nun annesi. Pembe arka plan |
| `riza.svg` | Depocu Rıza | Kostüm deposu sorumlusu; fötr şapka, askılı pantolon. Kum rengi arka plan |
| `niko.svg` | Niko | Bizans nöbetçisi; miğfer, sakal, kırmızı tunik, iyi kalpli. Somon arka plan |

### Eksik olanlar (şu an sadece isim görünüyor)

| Dosya adı (önerilen) | Karakter | Tarif |
|---|---|---|
| `kadri.svg` | Aşçıbaşı Kadri | İri, beyaz aşçı külahı, önlük, kalın bıyık, elinde kepçe. "Tencereye girer mi?" bakışı |
| `lutfi.svg` | Tercüman Lütfi | Çok dilli, hevesli, yeşil kaftan, küçük sarık, parmakta mürekkep |
| `urban.svg` | Usta Urban | Macar topçu ustası; is lekeli yüz, deri önlük, kulakta pamuk, gururlu |
| `hasan.svg` | Hasan | Yeniçeri; uzun beyaz börk, **kırmızı** kaftan |
| `huseyin.svg` | Hüseyin | Hasan'ın ikizi gibi; aynı börk, **mavi** kaftan (kim kim belli değil şakası) |
| `candarli.svg` | Kukuletalı adam ("Kimse") | Siyah kukuleta, yalnızca bıyık görünür |
| `pasha.svg` | Çandarlı Halil Paşa | Yaşlı sadrazam; fazla büyük sarık, gri sakal, yeşil kaftan, "kılık değiştirmiş" ama belli |
| `theodoros.svg` | Logothetes Theodoros | Bizans bürokratı; mor cüppe, kırmızı kamelaukion, gri sakal, elinde mühür. Nihat'ın aynası |
| `clerk.svg` | Bizans memuru | Theodoros'un sadeleşmiş hâli, farklı renk cüppe |
| `giust.svg` | Giovanni Giustiniani | Cenevizli komutan; gümüş zırh, tüylü miğfer, kısa sakal, tüccar gözü |
| `emperor.svg` | İmparator Konstantinos | Mor cüppe, altın taç, ağırbaşlı, yorgun ama sıcak. **Karikatür değil, saygılı** |
| `cemil.svg` | Hırdavatçı Cemil | Yaşlı esnaf; mavi iş önlüğü, hırka, gözlük, terlik, çay bardağı |
| `agent1.svg` | Ajan 7/c | Büro ajanı; gri yağmurluk, fötr, gözlük, el feneri |
| `agent2.svg` | Ajan 12/b | Aynı üniforma, bıyıklı, biraz daha esmer |
| `soldier.svg` | Asker | Genç yeniçeri, yeşil kaftan, börk |
| `rower.svg` | Kürekçi | Bizans kadırgası kürekçisi, terli, çizgili bere |

> Eksik portreler gelince `scripts/ui/hud.gd` içindeki `PORTRAITS` sözlüğüne eklenir (tek satır).

## 2. Çanta eşyaları — `assets/art/icons/`

- **Boyut:** 256×256, krem yuvarlak kare zemin (`#f3ecd8`, rx≈40), eşya ortada.
- **Görünür boyut:** 52×52 px. Çok sade tut; tek bakışta tanınmalı.

| Dosya | Eşya | Not |
|---|---|---|
| `phone.svg` | Akıllı telefon | Ekranda %1 pil şakası olabilir |
| `lighter.svg` | Çakmak | Klasik plastik çakmak, küçük alev |
| `book.svg` | Tarih kitabı | Kapakta "TARİH" ve fes silueti |
| `chickpeas.svg` | Leblebi | Kâğıt külahta sarı leblebi |
| `powerbank.svg` | Powerbank | Kablo sarkıyor |
| `tape.svg` | Koli bandı | Kahverengi rulo — oyunun simgesi, özenli olsun |
| `thermos.svg` | Termos | Ekose desenli eski termos |
| `selfie.svg` | Selfie çubuğu | Açılmış, ucunda telefon |
| `cologne.svg` | Limon kolonyası | Klasik şişe, limon etiketi |
| `cube.svg` | Rubik küpü | Karışık renkler |

## 3. Afişler ve logo — `assets/art/posters/`

| Dosya | Boyut | Nerede | Tarif |
|---|---|---|---|
| `fez.svg` | 256×256 | **Başlık ekranındaki logo** (130 px yüksek) | Fes ve püskülü; oyunun amblemi. İstenirse "GERÇEK TARİH BU DEĞİL" yazılı bir logo da olur (o zaman 1024×384 önerilir) |
| `calendar.svg` | 300×400 | Garaj duvarındaki takvim | 1970'ler tarzı duvar takvimi, bir sayfa, bir tarih yuvarlak içine alınmış |
| `patent.svg` | 400×300 | Garajda çerçeveli belge | "Zamanatör 3000 — Patent Başvurusu", teknik çizim ve bir kahve lekesi |

## 4. Bunlardan daha etkili olabilecek büyük işler (isteğe bağlı)

1. **Yazı tipi (en acil):** Varsayılan yazı tipinde bazı simgeler (⏱ 🍲 📱 ✉️ 🕐) boş kutu ya da daire olarak görünüyor. Türkçe + Yunanca harfleri ve bu simgeleri içeren, **serbest lisanslı (OFL)** bir yazı tipi (örn. Nunito + Noto Emoji) gelirse ya da simgeler için 64×64 küçük ikonlar çizilirse arayüz toparlanır.
2. **Akış şeması kartları:** Her bölüm sonundaki akış şeması şu an düz kutular. Bölüm başına bir küçük başlık çizimi (512×256) gelirse eklenir.
3. **Bölüm kapak kartları:** Her bölümün açılışında düz yazı var. 1920×1080 tek görsellik kapaklar (Bölüm 1–9) büyük fark yaratır.
4. **3B modeller:** Karakterler ve binalar kodla yapılmış kutulardan oluşuyor. **Low-poly `.glb` modeller** (özellikle insan karakterleri, otağ, büyük top, Zamanatör makinesi) gelirse entegre edilebilir. Bu en büyük görsel sıçrama olur ama en uzun iştir.
5. **Ses:** Oyunda hiç ses dosyası yok (konuşmalar sentezlenmiş mırıltı). Kısa efektler (top, tavuk, daktilo, telsiz cızırtısı) ve bir ana tema müziği eklenebilir.
