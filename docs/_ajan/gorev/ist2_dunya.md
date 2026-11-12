# İstanbul v2 — DÜNYA: coğrafya, arazi, deniz, gezi sahnesi (Opus)

Önce `docs/_ajan/gorev/_ist2_ortak.md` (karar ve dondurulmuş arayüz), sonra işaret ettiği dosyaları oku ve uy.
Dalın: `wip/ist2-dunya` (taban: `wip/istanbul`). Kanıt: `docs/_kanit_ist2_dunya/`. Öbür oturum: `wip/ist2-sehir`.

## Teslimler (sırayla; her biri bitince kaydet ve gönder)
1. **İlk 30 dakika: `scripts/world/ist/geo.gd` (`IstGeo`)**, dondurulmuş imzalarla, çalışır hâlde (ilk sürümde kıyı
   ve yollar kaba olabilir; imzalar tam). Gönder: öbür oturum bunu bekliyor.
   - Kıyı çokgenleri gerçek koordinatta (doğu/kuzey metre) sayısallaştırılır, ×0,5 dünyaya geçer. Kaynak:
     `docs/ISTANBUL_YERLER.csv` (kapılar, kuleler, limanlar: deniz surları hattı = 1453 kıyısı) + kendi coğrafya bilgin +
     varsa ağdan kıyı verisi (OpenStreetMap/Natural Earth; erişim yoksa elle, yarımada için en az 160 nokta, Galata
     ve Anadolu kıyısı için 60'ar). Bugünkü dolguları çıkar (Yenikapı, Eminönü, Sarayburnu sahili). Tanınması gereken
     biçimler: Sarayburnu burnu, Haliç'in batıya doğru daralan kıvrımı, Marmara kıyısının yayı, Langa koyu (dolmuş
     liman: bostan), Kontoskalion havuzu, Galata burnu, Tophane koyu, Üsküdar/Damalis burnu, Kız Kulesi adacığı,
     Boğaz'ın kuzeye açılışı, Kâğıthane/Alibeyköy dereleri (Haliç'in ucu), Eyüp.
   - Arazi: yedi tepe (yükseklik ve yerleriyle: 1. Sarayburnu/Ayasofya ~40 m, 2. Çemberlitaş ~50 m, 3. Beyazıt ~60 m,
     4. Fatih/Havariyun ~60 m, 5. Sultanselim ~60 m, 6. Edirnekapı ~70 m, 7. Kocamustafapaşa/Xerolophos ~60 m), Lykos
     vadisi, Galata tepesi (~60 m, kule tepede), Çamlıca yönü; yükseklik × 0,5; kıyıda yumuşak iniş, deniz tabanı.
     `h(x,z)` sürekli ve hızlı (çağrı başına < 5 µs hedef: ızgara + çift doğrusal).
   - Yollar: kara suru (Marmara'dan Haliç'e gerçek hattı; kapı yerleri dizinden), Blakherna suru, deniz surları (kıyıyı
     izler), Galata suru, Mese ve iki kolu (Milion → Konstantin Forumu → Tauri → Philadelphion'da çatallanma: kuzey
     kol Havariyun → Harisios; güney kol Bous → Arkadius → Altın Kapı), Lykos deresi, zincir (Eugenios → Galata),
     Bozdoğan kemeri hattı.
   - `mahalle(x,z)`: `docs/ISTANBUL_PLAN.md` §2 çizelgesinin v2 karşılığı (gerçek yerleriyle): Mese boyu çarşı, Haliç
     kıyısı sık ve liman, Ayasofya çevresi sık, kara surlarının iç şeridi ve Lykos vadisi bostan/bağ/harabe/seyrek köy,
     açık sarnıçlar bostan, Büyük Saray harabe.
2. **`scripts/world/ist/dunya.gd` (`IstDunya.build`)**: arazi ağı parça parça (ör. 128 m parça, uzakta seyrek ızgara),
   çarpışma oyuncunun/uçuşun çevresinde (zaman dilimli, takılma yok), doku (çayır/toprak/taşlık/kıyı kumu; `Props`
   desenleri ve `scripts/level/nature.gd` üslubu), deniz (var olan su gölgelendiricisini kullan: `scripts/level/horn.gd`
   ya da `scripts/world/horn_world.gd` içinde ara; yeniden yazma), gökyüzü ve güneş/ay (var olan `ByzCity`/`World1453`
   gök kurucularının üslubu; gece kipi), sis (uzak ufku yumuşatır ama şehri soldurmaz), uzak ufuk (Trakya, Anadolu
   tepeleri, Boğaz boyunca kıyılar, Adalar silüeti). Su altına düşen oyuncu/uçuş için yakalayıcı. Sur dışında kuşatma
   ovası: düz/dalgalı arazi (ordugâh sonraki pakette yerleşecek; zemini hazır olsun).
3. **`tests/_ist/gezi.tscn`** (ortak dosyadaki tanım): kare alma listesi + serbest uçuş + yürüyen oyuncu.
   Kareler: tam tepeden bütün yarımada (biçim İstanbul'a benziyor mu: yan yana bir gerçek kıyı krokisiyle karşılaştır),
   60 m'den dört yön, Sarayburnu, Haliç ağzı, Galata'dan yarımadaya bakış (Peter'in "ilk kare"si: Galata üstünden
   Haliç'in ötesinde Ayasofya), kara surlarının dışından şehre bakış, gece.
4. **Öbür oturumla birleşme:** `wip/ist2-sehir` dalını her 45–60 dakikada çek ve birleştir; `IstDunya.build` sonunda
   `IstSehir.attach_v2` çağrılır (yoksa atla). Birleşik karelerde arazi–yapı uyumunu denetle (havada/gömülü yapı,
   suya taşan sur, yamaçta eğik duran taban): arazi tarafındaki kusuru sen düzelt (taban düzleme: `IstGeo` içinde
   yapı tabanları için düzlük kaydı `duzle(merkez, yaricap, y)` ekleyebilirsin; imza ekle, var olanı değiştirme).
5. **Performans:** uçuşta bütün şehir görünürken arazi + deniz + ufuk ≤ 120 çizim, ≤ 400 bin üçgen; yürürken ≤ 60
   çizim. Kurulum: ilk kare ≤ 2 sn, sonrası zaman dilimli (kare başına ≤ 6 ms).
6. **Rapor** (`docs/_kanit_ist2_dunya/rapor.md`): kıyı verisinin kaynağı ve doğruluğu, tepe/vadi tablosu, ölçümler,
   bilinen kusurlar, BAKILMADI listesi; paftalar (en çok 12).

## Sonra (bu oturumda, zaman kalırsa; kalmazsa raporda "sıradaki" diye yaz)
Uçuş bölümlerini (7 ve 11) v2'ye bağlamak için gerekenlerin dökümü: bölümlerin eski dünyada kullandığı noktalar
(başlangıç, tarayıcı hedefleri, ordugâh, yan görev işaretleri, konma noktaları: `World1453.flight_data`,
`scripts/chapter7.gd`, `scripts/chapter11.gd`, `scripts/world/world_flight.gd`) ve v2'deki karşılıkları. UYGULAMA
ayrı pakette yapılacak; bu oturumda yalnız döküm.
