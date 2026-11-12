# İstanbul v2 — KARIŞ KARIŞ GEZİ DENETİMİ (12 Kasım, 17:55 UTC)

Oyunun sahibinin sözü: **"karış karış tüm İstanbul'u gezecek, görsel ve mantık hatalarını bulacak ve kötü görünen kare
karelere dikkat edecek bir kaç ajan daha başlat"**. Sen o gezginlerden birisin: DENETÇİSİN, kendi BÖLGENİ gezersin.

Önce oku (bağlayıcı): `docs/_ajan/gorev/_ortak2.md` (kurulum, yasaklar, "Denetçi için ek"), `docs/_ajan/gorev/ist2_kalite_notlari.md`
(0–32; özellikle 32: KUTU YASAĞI), `docs/_ajan/gorev/ist2_tur4.md` (başı: sahibinin sözleri), `docs/ISTANBUL_1453.md` ve
`docs/ISTANBUL_PLAN.md` (varsa: şehir gerçekte nasıldı, ne nerede), ordugâh bölgeleri için `docs/ORDUGAH_1453.md`.
Taban: `wip/ist2-gezi-taban` (dördüncü turun 17:05'teki birleşik hâli). Oyun kodunu DEĞİŞTİRME.

## Sahibinin bugün karelere bakarak söyledikleri (senin ölçün bunlar)
- "bu görüntü kötü değil mi sence" · "surların arası boş, tam değil bazı yerlerde" · "o yeşil alan yükseltileri ne öyle"
- "öküzleri kare kare mi yapmışsın????? şu kare kare sevdandan vazgeç" · "çadırlara odaklandın mı, kamp ateşlerine vs"
- "yerler çok kötü" · "boşluğa tırmanıyo gibiler" · "boş alan istemiyorum" · "yaşam dolu olacak sokaklar"
Sahibi gibi bak: iyi niyetli değil, EKŞİ bak. "İdare eder" diye geçme. Bir karede gözüne batan ne varsa bulgu.

## Araçlar
- Kare: `tests/_ist/sur4_kare.tscn -- --set=liste --liste=DOSYA --out=KLASÖR` (şehir kuyruğu boşalınca çeker; yakın katman
  tam) ya da `tests/_ist/gezi.tscn -- liste=DOSYA shots=KLASÖR [gece=1]`. Liste satırı: `ad doğu kuzey yükseklik yön eğim`
  (gerçek metre; yükseklik arazinin üstünde; yön pusula derecesi; eğim aşağı eksi). Başlıklarını oku.
- Nesnenin kaynağı: `sur4_kare --set=kim` (karedeki düğüm adları) + `grep`: her bulguya dosya:işlev yaz (bulamazsan
  düğüm adını yaz).
- Yürüyüş: `gezi.tscn -- kip=yuru kam=…` ya da `sehir2_kare`/`sur4_kare`'deki gerçek oyuncu (`scripts/player/player.gd`)
  sınamaları örnek alınarak kendi sondan: `tests/_ist/gezi_<bölgen>.gd/.tscn` (yalnız test dosyası; oyun kodu değil).
- Yer adları ve koordinatlar: `scripts/world/ist/geo.gd` tabloları, `IstSehir.flight_data_v2`, `tests/_ist/gezi_sahip.txt`.
- Aynı anda en çok 1 ekranlı + 2 başsız koşu. Kareler 1280×720; pafta için 3×3 küçült (ImageMagick `montage`).

## Gezi yöntemi (karış karış: atlamak yok)
1. Bölgenin sınırını belirle (aşağıdaki tanım + yer adlarının koordinatları); rapora dört köşe koordinatını yaz.
2. **Izgara:** bölgeyi 60 m'lik ızgarayla tara; her düğümde göz hizasından (1,7 m) DÖRT yöne kare (K, D, G, B). Düğüm
   bir yapının içine/suya düşerse en yakın açık yere kaydır.
3. **Yollar:** bölgedeki bütün ana cadde/yol/sur dibi/kıyı boyunca 15 m'de bir yürüyüş yönüne kare; ünlü her yapının
   kapısına kadar yürü, çevresini dolaş (8 kare), girilebiliyorsa gir.
4. **Havadan:** 20 m ve 60 m'den, 120 m'de bir çapraz (−30°) kare; bölgenin tam tepeden bir karesi.
5. **Gece:** ızgaranın her üçüncü düğümünden iki yöne.
6. **Gerçek oyuncuyla yürüyüş:** en az 6 güzergâh (toplam ≥ 1,2 km): takılma, düşme, duvardan geçme, görünmez duvar,
   boşluğa basma, çıkılamayan basamak, kapalı cep say (`GEZI_OLAY <tür> <doğu> <kuzey>`).
7. Her kareye BAK: 3×3 paftaların HEPSİNİ aç ve incele; şüphe duyduğun her karenin tam boyunu aç. Bakmadığın kareyi
   "baktım" yazma: raporda "bakılan kare sayısı / çekilen kare sayısı" yaz.

## Ne aranır (bulgu türleri)
- **KUTU** (kalite notu 32): kutudan yapılmış canlı ya da yuvarlak olması gereken nesne; çıplak dokusuz küp/levha;
  "oyuncak" ağaç/çalı/kaya; cetvelle kesilmiş keskin kenarlı yama; kule/ev/çadır "kutu + levha çatı".
- **GÖRSEL:** dokusuz/beyaz/siyah yüzey, yanlış renk (oyuncak doygunluğu, camgöbeği gölge), titreyen/çakışan yüzey
  (z-fighting), delik, havada duran ya da yere gömülü nesne, birbirinin içine girmiş yapı, yarım kalmış katman,
  görünür LOD geçişi (belirme/kaybolma), ufukta kesik, su/kıyı hatası, gölge hatası, ışık sızması, çifte nesne.
- **ZEMİN:** düz renk + damga, parlak çim, keskin yama kenarı, yapıyla zemin arasında bıçak çizgisi, döşemesiz sokak,
  yol birden bitiyor, zemin ile yapı arasında boşluk.
- **MANTIK:** kapısı olmayan/kapısı duvara açılan yapı, hiçbir yere çıkmayan merdiven, evin içinden geçen yol, yola
  kapanmış sokak, suyun içinde ev, karada tekne, surun içinden geçen yol (kapı yok), çatıda/duvarda/suda duran kişi,
  havada yürüyen, birbirinin içinden geçen kişi, yanlış yöne bakan nöbetçi, eli boş iş yapan, aynı kişiden yan yana
  kopyalar, ateşsiz duman / dumansız ateş, rüzgâra ters bayraklar, ölçek hatası (kapıdan büyük insan, insandan küçük ev).
- **DÖNEM (Nisan–Mayıs 1453):** minare, hilal, Osmanlı yapısı sur içinde, Bizans surunda Osmanlı bayrağı, cam vitrin,
  tabela/yazı, domates/patates/mısır/tütün/kahve, modern nesne; yeri yanlış ünlü yapı (belgeye göre).
- **BOŞLUK / YAŞAM:** boş çayır kalmış ada, kişisiz sokak/meydan, eşyasız tezgâh, ölü liman; ordugâhta ateşsiz oba.
- **OYNANIŞ:** madde 6'daki olaylar. **PERFORMANS:** her 10 karede bir RINFO (çizim/üçgen) ve bütçeyi aşan yerler
  (uçuş 1 500 / 3,5 M; yer 1 200 / 2,5 M); kurulumda > 50 ms kare.

## "Biliniyor, düzeltiliyor" (yine de SAY ve yerini yaz; ama asıl hedefin bunların DIŞINDAKİLER)
Kara suru kuleleri kutu + kırmızı levha çatı; sur üstünde beyaz küpler; hendek kesme çokgen (SUR-5 çalışıyor) ·
ordugâh çadırları kulübe gibi, bacalı; kamp ateşi görünmüyor (ORDUGÂH-5) · hayvanlar kutu (CANLI) · zemin geneli (ZEMİN).

## Teslim (dal `wip/gezi-<bölgen>`, klasör `docs/_kanit_gezi_<bölgen>/`)
- `rapor.md`: (1) bölge sınırı, kare sayıları (çekilen / bakılan), yürüyüş km; (2) **GENEL NOT** 10 üzerinden ve üç
  cümle: sahibi bu bölgeyi gezse ilk neye kızar; (3) BULGU TABLOSU, her satır: `no | tür | önem (1 kritik, 2 belirgin,
  3 küçük) | yer adı | doğu, kuzey | kare dosyası | ne görünüyor (bir cümle) | kaynak (dosya:işlev ya da düğüm adı) |
  öneri`; (4) tür başına sayım ve `KUTU kalan=N`; (5) en kötü 12 kare (dosya adı + neden); (6) bölgenin İYİ olan 5 karesi
  (korunacaklar); (7) bakamadıkların.
- Kareler: bulgu kareleri tam boy (JPEG, ≤ 250 KB) `kare/` altında (en çok 120), paftalar `pafta_*.jpg` (en çok 20),
  kamera listelerin (`liste_*.txt`), ham olay/RINFO satırları. Bulgu olmayan ham kareleri gönderme.
- Hedef: en az 40 bulgu ya da bölgenin gerçekten temiz olduğunun kareli kanıtı. İlk gönderim (ilk 15 bulgu + paftalar)
  60 dakika içinde, son rapor en geç 2,5 saatte. Gönderim doğrulanmadan ve arka plan koşuların bitmeden durma.

## Kesin kurallar
- Oyun kodunu değiştirme (`git status` ile doğrula); yalnız kendi `tests/_ist/gezi_<bölgen>.*` sondan ve kanıt klasörün.
- Uydurma bulgu yazma: her bulgunun karesi olacak. Emin değilsen "ŞÜPHELİ" yaz.
- Yasak araçlar: oturum/tetikleyici/zamanlama/bildirim/alt ajan başlatan araçlar; `pkill`/`killall` (yalnız
  `kill <pid>`); ses üretme; PR; `main`e dokunma.
- İzin kutusu çıkaran komut yok: `rm -rf`/`rm -r`/`mv`/`cp -r` hedefinde kabuk değişkeni kullanma; silmeyi
  heredoc/zincir içine gömme; `bash -c '…'` ile bekleme döngüsü yazma; geçici dosyalar yalnız ev dizininde tek bir
  çalışma klasöründe; `sudo` yalnız `apt-get` için.

## Bölgeler
| kod | bölge |
|---|---|
| `kara-guney` | Kara surları güney üçte biri: Mermer Kule, Altın Kapı (Yedikule yöresi), Ksylokerkos, Pege (Silivri) kapısı; surun iki yanı 200 m (iç: sur dibi mahalleleri; dış: hendek ve ateş alanı) |
| `kara-orta` | Kara surları orta: Rhegion kapısı, Romanos (Topkapı), Mesoteikhion (Lykos vadisi), Pempton; iç yanda hub oyun alanı ve çevresi; surun iki yanı 200 m |
| `kara-kuzey` | Kara surları kuzey: Kharisios (Edirnekapı), Tekfur/Porphyrogennetos, Kaligaria, Blakherna Sarayı ve suru, Anemas, Blakherna Meryem; Khora (Kariye); Haliç'e iniş |
| `ordugah-merkez` | Osmanlı ordugâhı merkezi: otağ ve yerleşkesi, yeniçeri obaları, ordu pazarı, mescit, mutfaklar, Şahi topu ve Mesoteikhion karşısındaki bataryalar, siperler |
| `ordugah-kanat` | Ordugâhın kanatları: Anadolu kanadı (güney, Marmara'ya kadar), Rumeli kanadı (kuzey, Haliç'e kadar), başıbozuk obaları, ağıllar, at bağları; Haliç ötesinde Zağanos yakası ve fıçı köprüsü |
| `mese-bati` | Mese'nin batı kolu ve güneybatı: Altın Kapı'dan Arkadius Forumu, Bous Forumu, Theodosius (Tauri) Forumu'na; Psamathia, Studios Manastırı, Mokios Sarnıcı, güneybatı bostanları |
| `mese-dogu` | Mese'nin doğu ucu: Konstantin Forumu ve sütunu, Milion, Augustaion, Ayasofya ve dört yanı, Aya İrini, patrikhane, Khalke |
| `saray-hipodrom` | Büyük Saray harabeleri, Hipodrom, Zeuksippos, Küçük Ayasofya, Nea Ekklesia, Bukoleon ve Marmara kıyısının doğu ucu, Sarayburnu |
| `marmara` | Marmara surları ve kıyı: Kontoskalion ve Eleutherios (Langa) limanları, Marmara kapıları, güney kıyı mahalleleri, denizden görünüş |
| `halic` | Haliç kıyısı: Haliç surları ve kapıları, iskeleler, Venedik/Ceneviz/Pisa mahalleleri, Perama, Neorion, Eugenios kulesi ve zincir, limandaki gemiler |
| `galata` | Galata (Pera): surlar, Galata Kulesi, loca ve kiliseler, iskeleler, yamaç sokakları, zincirin Galata ucu, karşıdan İstanbul'a bakış |
| `orta-sirt` | Kuzey ve orta sırt: Bozdoğan (Valens) Kemeri, Havariyyun (Aziz Havariler), Pantokrator, Pammakaristos, Aspar ve Aetius sarnıçları, Lykos vadisinin şehir içi, bu tepelerdeki mahalle ve bostanlar |
| `havadan` | Bütün şehir Nihat'ın uçuşuyla: 30, 60, 120 m'den dört büyük tur (kara surları boyu, Marmara kıyısı, Haliç + Galata, Mese ekseni) ve ordugâhın üstü; LOD belirme/kaybolma, uzak katman, ufuk, bulut/sis, su; her yan görev eserine yaklaşma ve konma |
| `gece` | Bütün şehir ve ordugâh GECE: sokaklar, meydanlar, surlar, limanlar, ordugâh ateşleri; yerden ve havadan; karanlıkta kaybolan yerler, ışık hataları, ışıyan yanlış yüzeyler |
| `mantik-donem` | Bütün şehir, yalnız MANTIK ve DÖNEM gözüyle: yukarıdaki belgelerle karşılaştırarak yapıların yeri/yönü/ölçeği, sokak ağı tutarlılığı, kapı-yol bağlantıları, kişilerin ve eşyaların döneme uygunluğu; 28 yan görev eserinin her biri tek tek |
