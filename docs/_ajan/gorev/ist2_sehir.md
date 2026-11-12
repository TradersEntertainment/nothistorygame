# İstanbul v2 — ŞEHİR: parçaların yerleşimi, surlar, sokaklar, mahalle dokusu (Opus)

Önce `docs/_ajan/gorev/_ist2_ortak.md` (karar ve dondurulmuş arayüz), sonra işaret ettiği dosyaları oku ve uy.
Dalın: `wip/ist2-sehir` (taban: `wip/istanbul`). Kanıt: `docs/_kanit_ist2_sehir/`. Öbür oturum: `wip/ist2-dunya`
(coğrafya: `IstGeo`, `IstDunya`, gezi sahnesi; ilk 30 dakikada `geo.gd`'yi gönderir: çek ve birleştir. O gelene kadar
aynı imzalarla geçici bir `geo.gd` taslağıyla çalışma, kendi dosyalarında `IstGeo`'yu çağır; birleştirince onunki geçerli).

## Teslimler
1. **Parça dallarını birleştir** (on iki `wip/ist-<ad>` dalı; yalnız yeni dosyalar; `wip/istanbul` on birini içeriyor,
   `ist-marmara` ve hepsinin son hâlleri için yeniden çek; her 45–60 dakikada yinele: parçalar derinleşmeye devam ediyor).
2. **Yer tablosu (gerçek koordinatta).** Her `catalog()` kaydının `dogu_m`/`kuzey_m`/`yon_derece` değerini
   `docs/ISTANBUL_YERLER.csv` ve `docs/ISTANBUL_1453.md` ile doğrula; sapanı tabloda düzelt (modül dosyasına dokunma;
   düzeltmeyi `IstSehir.YER2` içinde tut, raporda parça adıyla yaz). Yerleşim `IstGeo.w(e, n)` ile, k = 0,5.
   Ayasofya'nın kendisi: var olan `ByzCity.aya_exterior(host)` modeli (0,0)'a; Blakherna Sarayı:
   `Blachernae.shell_parts`; Konstantin Sütunu: `ByzCity.column_parts` (forumlar parçasınınkiyle çift olmasın: birini seç).
3. **Uzun hatlar** (`IstGeo.yol(...)` çoklu çizgileri boyunca, parçaların parametreli kurucularıyla): Theodosius kara
   surları (iç/dış sur, peribolos, hendek, 96 kule; kapılar dizindeki yerlerinde), Blakherna suru, Marmara ve Haliç
   deniz surları (kıyıyı izler; kapılar, kuleler), Galata suru ve kulesi, Bozdoğan Kemeri (iki tepe arasında, altından
   Mese kolu geçer), Mese (revaklı dilimler), zincir. Köşe ve eğimde dilimler kopmasın, üst üste binmesin; sur üstü
   yürüme yolu kesintisiz (oyuncu sur üstünde baştan sona yürüyebilsin: sına).
4. **Sokak ağı ve mahalle dokusu.** v2 için yeni sokak grafiği (`scripts/world/ist/sokak.gd`): Mese ve kolları, kapılardan
   Mese'ye inen yollar, Haliç iskelelerinden yukarı çıkan yokuşlar, mahalle içi organik sokaklar (ızgara değil), yamaçta
   basamaklı sokak. Evler `IstEvler` (mektup bölümünün ev dili) ile sokak boyunca bitişik nizam, `IstGeo.mahalle`
   yoğunluğuna göre: çarşıda revak/dükkân/tente, sık mahallede sıra ev + avlu, seyrek köyde tek tek ev + bahçe, bostan
   ve bağ (bitki parçası), harabe (kiliseler parçasının harabe tipleri), mahalle kilisesi/şapel (kiliseler parçası),
   meydan/kuyu/çeşme, sokak ayrıntısı (ayrinti parçasının "köşe" grupları). Nisan 1453: surların içi büyük ölçüde
   seyrek: tarla, bağ, bostan, harabe; nüfus Mese boyunda, Haliç kıyısında, Ayasofya çevresinde, Studios ve Blakherna
   köylerinde toplanmış. Hedef yaklaşık 4–6 bin ev (akışla; uzakta pişmiş tek ağlar).
   Oynanış kuralları (şart): her ev kapalı katı, bitişik evler arasında aralık 0 ya da ≥ 1,4 m, zeminde delik yok,
   her adada sokaktan çatıya en az bir yol, çatıdan çatıya geçiş; yamaçta taban araziye oturur (havada/gömülü yok).
5. **Akış ve bütçe** (`IstSehir.attach_v2`): parça ızgarası, lod 2 → 1 → 0 mesafeyle, zaman dilimli (≤ 6 ms/kare),
   uzak/orta katman tek ağa pişmiş. Uçuşta (70 m tavandan bütün şehir) ≤ 1 500 çizim ve ≤ 3,5 M üçgen; yerde ≤ 900
   çizim ve ≤ 2,5 M üçgen. Birden belirme/ölü bant/çifte çizim yok.
6. **Nihat'ın yan görevi verisi:** `IstSehir.flight_data_v2()` → eski `World1453.flight_data` ile aynı biçimde
   (`landmarks`, `forms`, `perches`): ilk dokuz eser aynı kimlik ve sırayla, v2'deki yerlerinde; ardından `"gorev": true`
   olan yeni eserler. Her işaret eserin tam üstünde, her konma noktası gerçek çarpışmalı yüzeyde (sına).
7. **Denetim ve kanıt** (gezi sahnesi `tests/_ist/gezi.tscn` öbür oturumdan gelir; gelene kadar kendi sondanla):
   - `city_audit`'i v2'ye uyarla ve beş mahallede koş (delik, dar aralık, kapalı cep, havada/gömülü, iç içe yapı = 0 hedef).
   - Her eser için 15 m üstünden ve tam tepeden kare (kutu gibi, üstü açık, arka cephesi boş, yanlış yerde/yönde eser
     kalmasın); kusuru parça adıyla raporla.
   - Peter'in ilk karesi: Galata üstünden Haliç'in ötesinde yarımada (Ayasofya silüeti, zincir, gemiler yoksa bile
     surlar ve mahalleler dolu). Kara surlarının dışından, Marmara'dan, Sarayburnu açığından bakışlar. Gece.
   - Yerden: Mese'de yürüyüş, bir Haliç iskelesi, bir bostan köyü, sur dibi, Hipodrom içi; çatıya çıkış beş yerde.
   - Her birleştirme turunda `docs/_kanit_ist2_sehir/tur_<n>_*.jpg` yenile ve gönder (yönetici sahibine gösterecek).
8. **Rapor:** yerleşen/yerleşmeyen parçalar (gerekçeyle), parça kusurları (parça adıyla, kare adıyla), ölçümler, audit
   sayıları, BAKILMADI listesi.

## Sonra (zaman kalırsa; kalmazsa raporda "sıradaki" diye yaz)
Tolga'nın şehir bölümlerinin (hub: 6b, 7b, 10h, 12b, 23, 24; Ayasofya meydanı: 24, 25, 26, 31o) oynanış alanlarının
v2'de oturacağı yerler: hub gerçek yerine (Romanos Kapısı'nın iç tarafı; cadde yönü kapıdan Mese koluna), Ayasofya
meydanı Ayasofya'nın batısına. Bu alanların dikdörtgenlerini v2'de BOŞ bırak (ev/ağaç koyma) ve yerlerini raporla;
bölümlerin bağlanması ayrı pakette yapılacak.
