# Bölüm 44 — Sarnıç (Yerebatan) · tasarım belgesi

> Sahibin sözü (12 Kasım): "bizansa yerebatan sarnıcı bölümü ekleyelim hem manzara hayranlık yaratsın hem de heyecanlı bi
> bölüm olsun". Bu belge bölümün yerini, akışını, düzeneklerini, sonuçlarını ve replik taslağını verir. Dal:
> `wip/bolum-yerebatan`. Kimlik: **44** (yalnız Bizans tarafı, `scenes/chapter44b.tscn`, `scripts/chapter44b.gd`,
> mekân `scripts/level/cistern.gd`).

## 1. Hikâyedeki yeri (karar ve gerekçe)

**Perde IV (Hasar Tespit), Bizans kayıtlarının yeni sayfası: 26 Mayıs 1453, gece.** `Siege.ORDER`'da 43'ün ardına,
25'in (Son Akşam, 27–28 Mayıs) önüne girer: `… 23, 24, 43, 44, 25 …`. Osmanlı tarafında sahnesi yoktur, o tarafta
kendiliğinden atlanır (28o, 43o ve 36b ile aynı düzen).

- Neden burası: 24 (Alametler) 23–24 Mayıs fırtınasıyla ve selle biter, ertesi akşam Ayasofya'nın çevresi sistedir.
  Sarnıç Ayasofya'nın 150 m güneybatısındadır; selin suyu sarnıca dolar. 25'in ikinci yarısı Ayasofya'daki son
  ayindir. Sarnıç bu iki Ayasofya sayfasının arasında, şehrin "son tedbirler" günündedir: şehir düşerse ne kalır?
- Neden Perde IV: kuşatmaya yeni sayfa eklemek oyunun var olan düzeneğidir (28, 29, 30, 36, 41, 42, 43 böyle girdi);
  bağlantı, bölüm listesi, numara ("Bölüm N"), Hasar Tespit Dosyası ve kayıt `Siege` üstünden kendiliğinden yürür.
  Öteki bölümlerin akışına dokunulmaz: 24'ün sonu `Siege.next_path(24)` ile artık 44'e, 44'ün sonu 25'e gider.
- Kayıt uyumu: eski kayıtlar çalışır. 24'ü bitirmiş ama 25'e geçmemiş kayıt "devam" deyince 44'ü oynar; 25 ve sonrası
  kayıtlarında 44 dosyada boş sayfa olarak görünür (Bölüm seçme ekranından oynanabilir). Sayfa sayısı (Bizans) bir artar.
- Perde IV'te Tolga'nın kulağındaki ses Nihat'tır (zamanın dışındaki Büro); Hikmet bu perdede telsizden ulaşamaz
  (EVREN §2). Görev metnindeki "Hikmet'in telsiz yorumları" bu yüzden **Nihat'ın Büro yorumlarına** dönüştü
  (sahibin kararına açık: §8).

## 2. Kısa öykü

Logothetes Theodoros her belgeyi yedi nüsha tutar. Altısı sarayın arşivinde; **yedinci nüsha** her zaman başka bir
yerde durur. Şehrin son günlerinde Theodoros yedinci nüshaları, İustinianos'un sarnıcında, eski logothetlerin
kullandığı kuru bir nişe saklamak ister: "Şehir düşerse kâğıt yanar. Taş yanmaz, su yanmaz." Nişin yeri eski bir
kayıtta yazılıdır: "**Biri yana bakar, biri yere. Bakışları bir taşta buluşur.**" Sarnıcın üstündeki evlerden birinin
mahzeninden inerler, sandala sandığı koyarlar. Sel suyu sarnıca dolmaktadır: niş birkaç dakika sonra su altında
kalacak. Tolga kürek çeker; Theodoros kandili tutar. Sonra kandil söner.

Büro'nun tespit karesi: **suyun altındaki Medusa** (Nihat: "1985'e kadar kimse görmeyecek. Siz görüyorsunuz.").

## 3. Akış (vuruş vuruş, ~12–15 dk)

1. **İniş (karanlık → ışık).** Bir evin mahzeni (dar, sıcak, kandil). Kapak açılır, taş merdiven aşağı iner; yankı
   büyür. Theodoros önde. Nihat: kayıt cümlesi. Tolga: "Abi burası Yerebatan. Ben buraya bilet aldım, kuyruk vardı."
2. **Hayranlık anı (oyuncu durur).** Merdivenin sahanlığı sarnıcın kuzeydoğu köşesinde, su çizgisinin 1,5 m
   üstünde. Önde 12 × 28 sütunluk orman: tuğla çapraz tonozlar, Korint/İon/yalın başlıklar, sütunların durgun suda
   tam yansıması, tavandaki kuyu ağızlarından inen 6 ışık huzmesi ve içlerinde toz, tavanda suyun kıpırtılı yansıması
   (kostik), uzakta karanlığa gömülen sıralar, damlalar ve halkalar, yankı. Denetim oyuncuda: kamera elden alınmaz;
   hedef yazısı 6 sn boş, müzik susar, ortamda yalnız damla ve yankı. Oyuncu bakmayı bırakıp merdiveni inince sürer.
   (Kanıt kareleri üç açıdan: sahanlık, sandaldan, uzak sıradan geri.)
3. **Sandal.** Sandık sandalda. Tolga küreğe geçer (var olan `RowMeter` ritmi: hız) ve sandalı A/D ile döndürür
   (sütunlar arasında 4,9 m aralık; sütuna sürtünme: sandal durur, yankılı "tok"). Yol: Theodoros'un sayımı ("dokuzuncu
   sıra, sola"). Sütunlarda tebeşirle Yunan rakamları (sıra işaretleri) vardır; yalnız ışıkta okunur.
   Gözyaşı sütunu (tavus gözü/gözyaşı oymaları) yolun üstündedir: Theodoros'un ve Tolga'nın tek samimi anı (≥ 3 sn).
4. **Karanlık.** Bir kuyu ağzından düşen tuğla kandili suya düşürür. **Işık yönetimi** başlar:
   - **Telefon feneri**: geniş, uzun menzil; şarj (yüzde) yandıkça düşer. %0'da "tuğla" (oyunun şakası).
   - **Çakmak**: kısa menzil, titrek; uzun yakılınca başparmak yanar (6 sn sonra kendiliğinden söner, 2 sn soğur).
   - Işık yokken yalnız huzmelerin aydınlattığı sütunlar ve suyun parıltısı görünür. Tebeşir işaretleri yalnız ışıkta.
5. **Gerilim: çöken kuyu ve yükselen su.** Selin suyu batıdaki kanaldan gürleyerek girer; ekranda **su sayacı**
   (nişin dibine kalan santim). Tavandan tozla haber veren parçalar düşer: önce damlalar suda halka yapar, 1,2 sn sonra
   tuğla iner. Halkayı gören sandalı durdurur ya da yana kırar; vurulursa sandal sarsılır, su alır, sayaç hızlanır.
   Bir kuyu bacası çöker (büyük düşüş, köpük, dalga): yol kapanır, Theodoros başka sıra söyler.
6. **Medusa köşesi (bulmaca, süreli).** Kuzeybatı köşede iki sütun Medusa başları üstüne oturur: biri **yan**, biri
   **ters**; yüzleri yarı yarıya suyun içinde. Herkesin bir teorisi var (Tolga: "Tersi, taşa dönmesin diye"; Theodoros:
   "Taş ölçüye uysun diye"; Nihat: "Kayıtlarda gerekçe yok. Kimse form doldurmamış."). Bulmaca: ışığı yan Medusa'nın
   yüzüne tut → gözündeki cam parıltı duvarda bir çizgi verir. Ters Medusa'yı suda doğrult: sandalı onun yansımasını
   düz gösteren yere getir (sudaki halka), ışığı yansımaya tut → ikinci çizgi. İki çizginin buluştuğu duvar taşı parlar:
   yanına yanaş, E basılı it → niş açılır, sandığı koy (E). Tespit karesi: suyun altındaki Medusa (telefonla).
7. **Çıkış (iki farklı yer).**
   - **44.1 Niş kuru kaldı:** Theodoros'la en yakın kuyunun ipinden yukarı (tırmanma, `Ladder` düzeni). Kuyu bir evin
     mutfağına çıkar: kova sallayan bir kadın kovada balık yerine Tolga'yı bulur. 24.1'de selde saçağa götürülen çocuk
     (siege_kid) bu evdeyse çocuk Tolga'yı tanır.
   - **44.2 Su nişe yetişti:** niş taşar; Theodoros sandığı "Medusa bekçilik etsin" diye ters başın dibine batırır.
     Sel kanalının yanındaki eski bakım merdiveniyle **Ayasofya'nın alt yapısına** (tonozlu bodrum) çıkılır; yukarıdan
     ilahi sesi gelir.

## 4. Oynanış düzenekleri (var olanlardan)

| Düzenek | Kaynak | Bu bölümde |
|---|---|---|
| Kürek ritmi | `RowMeter` (17, 19, 38o) | Sandalın hızı; ritimsiz kürek gürültü yapar, yankı büyür |
| Yön | yeni, bölüm içinde | A/D sandalın burnunu çevirir; sütuna sürtme durdurur |
| Işık | `Player._phone_light` düzeni + bölüm içi şarj/çakmak | Işık yönetimi, tebeşir işaretleri ve bulmaca |
| Tırmanma | `Ladder`, `enable_climb` | 44.1 çıkışı: kuyu ipi |
| Süre çubuğu | `Hud.set_chase` | Su sayacı, taşı itme |
| Tespit karesi | `TespitCam` | Su altındaki Medusa |
| Dosya sayfası, akış şeması | `Siege.record`, `Flowchart` | Sayfa 44, iki sonuç |

## 5. Sonuçlar ve etkileri

| ID | Sonuç | Bayrak | Etki |
|---|---|---|---|
| **44.1** | Yedinci nüsha kuru nişte; kuyudan bir evin mutfağına | `cistern_chest = "niche"` | Bölüm 15 İnsanların Akıbeti: Theodoros satırı ("yedinci nüsha nişte; 2026'da turistler üstünden geçiyor") |
| **44.2** | Niş taştı; sandık ters Medusa'nın dibinde; Ayasofya'nın altından çıkış | `cistern_chest = "medusa"` | Akıbet: "1987 temizliğinde 50 bin ton çamurdan bir kurşun mühür çıktı; müzede 'kökeni bilinmiyor'" |

Ek bayraklar: `cistern_battery` (telefonun bölüm sonundaki yüzdesi, sonraki sayfada değil yalnız dosya notunda),
`cistern_kid` (44.1 + siege_kid). Başarım: **"Medusa'ya Bakan"** (iki parıltıyı tek seferde buluşturdu, su sayacı
yarıdan önce). Var olan sonuçlar, denge ve öteki bölümlerin replikleri değişmez.

## 6. Replik taslağı (tr; anahtar biçimi `D44B_<K>_<AD>`, K: T Tolga, TH Theodoros, N Nihat, W kadın, K çocuk)

- N: "Bugünkü kayıt yerin altında, Tolga Bey. Logothetes Theodoros şehrin son kâğıtlarını saklayacak. Siz kürek çekin."
- TH: "Altı nüsha sarayda. Yedincisi her zaman başka yerde durur. Kural benim değil; benden önceki altı logothetin."
- T: "Abi burası Yerebatan. Ben buraya bilet aldım, yarım saat kuyruk bekledim. Şimdi bedava giriyorum, üstüne kürek."
- T (hayranlık, kendi kendine): "…Tamam. Bunu fotoğraf anlatmıyormuş."
- TH: "İustinianos yaptırdı. Üç yüz otuz altı sütun. Hepsini başka binalardan topladılar; hiçbiri ötekine benzemez."
- T: "Devşirme sütun. Bizde buna 'muadil parça' denir, hasar dosyasında sevmeyiz."
- TH (gözyaşı sütunu): "Bunu yapan ustalar ağlamış derler. Bin yüz yıldır da ağlıyor." (ciddi an)
- T (kandil sönünce): "Tamam, sakin. Benim fenerim var. Yüzde on dört. …Yüzde on üç."
- TH (telefona): "Işık bir taşın içinde mi yanıyor? Mühür var mı üstünde?"
- T (çakmak): "Çakmak, iki saniye. Başparmağım da sigortalı değil."
- N (su sayacı): "Su nişin dibine otuz santim. Kayıtlara 'zamanında' yazmak isterim."
- T (Medusa): "Neden ters? Bence taşa dönmesin diye. Rehber de öyle dedi, ama rehber her şeye öyle diyor."
- TH: "Ters değil. Taş ölçüye uysun diye konmuş. Ustalar ölçüye bakar, yüze bakmaz."
- N: "Kayıtlarda gerekçe yok. Kimse form doldurmamış. Ben de doldurmayacağım."
- W (mutfak): "Her gece kovaya bir şey takılır. Genelde sazan."
- T: "Ben sigortacıyım. Sazanla aynı poliçeye girmem ama… teşekkür ederim."
- N (son, 44.1): "Yedinci nüsha kuru. Bazı kâğıtlar kurtulur, Tolga Bey. Çoğu değil."

(İngilizce karşılıklar betikle birlikte `i18n/strings.csv`'ye yazılır; espri İngilizcede yeniden kurulur.)

## 7. Mekân, bütçe, araştırma (kısa)

- **Ölçü:** 138 × 65 m, 12 sıra × 28 sütun = 336; sütun 9 m (oyunda 8,6 m gövde + başlık), aralık ~4,9 m; dış duvar
  4 m kalınlık; tuğla çapraz tonoz (her göz tek ağda). Su çizgisi oyunda 1,2 m (tarihteki düzey bilinmiyor; sığ su
  oyuncunun düşüp sıkışmasını engeller: suya düşen yürür, sandala ya da merdivene döner).
- **Çizim/üçgen:** 336 sütun + 336 başlık + 336 kaide tek MultiMesh'lerde (başlık türüne göre 3 MultiMesh), tonoz tek
  birleşik ağ, ters yansıma (aynı MultiMesh'ler y'de ters, suyun altında) + saydam su; huzmeler ışık değil katkı
  (additive) koni ağ + toz parçacığı; kostik tavan gölgelendiricisi. Işık: 1 yönsüz ortam, ≤ 4 OmniLight (kandil,
  mahzen, kuyu dipleri), telefonun SpotLight'ı. Hedef: çizim ≤ 600, üçgen ≤ 1,5 M.
- **Araştırma notu (kaynaklı):**
  - İustinianos döneminde (6. yy) yapıldı; ~138 × 65 m, ~80 bin m³; 12 × 28 = 336 sütun, ~9 m; çoğu İon ve Korint
    başlıklı, birkaçı yalın; bir sütunda "tavus gözü", eğik dallar ve gözyaşı oymaları; kuzeybatı köşede iki sütun
    Medusa başlı bloklara oturur; 4 m tuğla duvar ve su geçirmez harç; su Belgrad Ormanı'ndan Valens Kemeri'yle
    gelirdi; 1985–87'de 50 bin tondan çok çamur çıkarıldı, Medusa kaideleri ortaya çıktı.
    ([Wikipedia: Basilica Cistern](https://en.wikipedia.org/wiki/Basilica_Cistern))
  - Petrus Gyllius (1540'lar; *De Topographia Constantinopoleos* II.20): üstteki evlerin halkı mahzenlerindeki
    kuyulardan kovayla su ve balık çekiyordu; ev sahibi meşale yakıp onu sütunların arasında sandalla gezdirdi,
    meşale ışığında balık zıpkınladı (J. Ball çevirisi, 1729: "The Master of the House, after having lighted some
    Torches, rowing me here and there across, through the Pillars…"). ([Byzantine Legacy](https://www.thebyzantinelegacy.com/basilica-cistern);
    [Project Gutenberg, Ball çevirisi](https://gutenberg.org/files/53083/53083-h/53083-h.htm);
    [Istanbul Su projesi](https://istanbul-su.rich.ru.nl/event/details/48/))
  - 1204'ten sonra su yolları onarılmadı; şehir sarnıçlara dayandı ([Byzantine Legacy: Cisterns](https://www.thebyzantinelegacy.com/cisterns)).
    1453'te Osmanlıların kemerleri kestiğine dair kaynak bulamadım: oyunda kesilmez.
  - **Uydurma (oyun için):** 1453'te sarnıcın dolu ve evlerden kullanıldığı (Gyllius'un 16. yy anlatısından
    geriye çıkarım, görevin varsayımı); Theodoros'un yedinci nüshası ve niş; 23–24 Mayıs fırtınasının (kaynaklı, 24)
    suyunun sarnıca dolması; çöken kuyu bacası; Medusa gözlerindeki cam.

## 8. Riskler ve sahibin kararı gereken yerler

1. **Yer:** Perde IV sayfası (26 Mayıs) mı, yoksa Perde II/III'te 12b/10'un Bizans dalından açılan yan yol mu? Seçilen
   yer akışı bozmaz ama Bizans tarafı bir sayfa uzar (~12–15 dk).
2. **Hikmet:** Perde IV'te telsiz yok; komedi Nihat ve Theodoros'tan. Hikmet istenirse yer Perde II/III olmalı.
3. **Sonuçların ağırlığı:** iki sonuç yalnız akıbet sayfasını ve başarımı etkiler (dünya sonucu değil). Daha ağır
   istenirse 25'teki son ayinde Theodoros'a tek satır eklenebilir (öteki bölüme dokunur: şimdi yapılmadı).
4. **Performans:** 336 sütun + yansıması + huzmeler gl_compatibility'de ağır olabilir; yansıma ve toz kademeli
   düşürülür (ayarlardaki kalite düzeyine göre).
5. **Ses:** yeni ses üretilmez; yeni replikler sessiz altyazıyla oynar (liste `docs/_kanit_yerebatan/yeni_replikler.txt`).
