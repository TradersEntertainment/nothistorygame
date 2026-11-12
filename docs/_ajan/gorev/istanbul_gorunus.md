# İstanbul, Nisan 1453 NASIL GÖRÜNÜYORDU: görünüş kılavuzu — ARAŞTIRMACI (Sonnet)

Türkçe çalış. Soru sorma, plan sunma, onay bekleme: başla, bitir, gönder. Dalın: `wip/istanbul-gorunus`.
Oyun kodunu DEĞİŞTİRME; yalnız `docs/ISTANBUL_GORUNUS.md` belgesini yaz. İzin kutusu çıkaracak komut yazma
(rm -rf / mv / cp -r hedefinde kabuk değişkeni yok; `bash -c` içinde bekleme döngüsü yok; sudo yok). Alt ajan ya da
başka oturum başlatma. PR açma, main'e dokunma. İşin bitmeden DURMA: belge "DURUM: TAMAM" olana kadar sürdür; her
30 dakikada bir kaydet ve gönder.

## Sahibin sorusu (12 Kasım, aynen)
"1453 te istanbulun nasıl gözüktüğünü bulabildiler mi güzelde boş alan istemiyorum bir de"

Oyun: "Gerçek Tarih Bu Değil" (Godot, düşük poligonlu çizgi film üslubu, 1453 kuşatması). Şehir şu an kodla yeniden
kuruluyor (yarı ölçek, gerçek kıyı; `docs/_ajan/gorev/_ist2_ortak.md`). Modelciler "neye benzemeli?" sorusuna bu
belgeden bakacak. Var olan iskelet araştırma: `docs/ISTANBUL_1453.md`, `docs/ISTANBUL_YERLER.csv` (oku; tekrar etme).

## Yöntem
WebSearch / WebFetch ile GÖRSEL ve GÖZLEMCİ kaynaklara git; her maddeyi kaynağıyla yaz, emin olmadığını BELİRSİZ yaz:
- Dönem görünümleri: Buondelmonti'nin Liber insularum haritaları (1420'ler, çeşitli nüshalar), Schedel 1493 (Nürnberg
  Kroniği), Vavassore görünümü (~1520, 1480'lerin şehrine dayanır), Matrakçı Nasuh 1537, Piri Reis, Lorichs 1559
  panoraması (erken Osmanlı ama Bizans yapıları duruyor), Bertrandon de la Broquière el yazması minyatürü (1455, kuşatma).
- Gözlemciler: Clavijo (1403), Buondelmonti, Pero Tafur (1437–38), Bertrandon de la Broquière (1433), Rus hacılar
  (Novgorodlu Stephen, Zosima), Kritovulos, Barbaro, Sphrantzes, Leonardo, Tursun Bey, Âşıkpaşazade, Dukas.
- Modern canlandırmalar: Byzantium 1200, Antoine Helbert, Tayfun Öner; Müller-Wiener, Mango, Magdalino, Kuban, Necipoğlu
  (Byzantium between the Ottomans and the Latins), Kafescioğlu (Constantinopolis/Istanbul).

## Belgenin bölümleri (her biri modelcinin doğrudan uygulayabileceği kadar somut)
1. **Bir bakışta:** Nisan 1453'te Galata üstünden, Marmara'dan, kara surlarının dışından ve Boğaz'dan bakan biri ne
   görürdü? (ufuk çizgisi, hangi yapılar ufku keser, renk lekeleri, duman, bayraklar, gemiler). Dört kısa betim.
2. **Renk ve malzeme paleti (onaltılık renk önerileriyle):** sur taşı ve tuğla kuşakları, kurşun kubbe, kiremit
   (alaturka/Bizans kiremidi biçimi ve rengi), sıva tonları, ahşap, mermer (Prokonnesos beyaz-gri), porfir, harabe,
   toprak yol, Nisan bitki renkleri (erguvan!), deniz ve gök. Oyunun bugünkü evleri pembe sıva + parlak turuncu çatı:
   tarihî palete göre ne değişmeli?
3. **Ev ve sokak:** geç Bizans evinin görünüşü (kat sayısı, taş/tuğla/ahşap oranı, çıkma, çatı, avlu, pencere,
   kapı), yoksul ev / varlıklı konak (ör. Notaras), dükkân, Latin mahallesi evleri; sokak genişliği ve zemini, basamaklı
   yokuş, revak; mahalle "köy" görünümü. Kaynaklardaki somut cümleler (Tafur: "seyrek nüfuslu…"; Clavijo: "tepeler ve
   vadiler arasında ekin tarlaları, bağlar, bahçeler…").
4. **Mahalle mahalle görünüş (15–20 mahalle):** her biri için 5–10 satır: sıklık, yapı türü, bitki örtüsü, ayırt edici
   görüntü, 1453'teki hâl (dolu/yarı boş/harabe), kuşatma izi. Haritadaki yerleri `ISTANBUL_YERLER.csv` adlarıyla.
5. **Anıtların 1453 görünüşü (her biri 5–12 satır; ölçü, renk, durum, ayırt edici beş ayrıntı, HAVADAN görünüşü:
   çatı/kubbe biçimi):** Ayasofya, Aya İrini, Hipodrom, Büyük Saray, Bukoleon, Iustinianus Sütunu, Konstantin Sütunu,
   Tauri, Arkadius Sütunu, Bozdoğan, Havariyun, Pantokrator, Khora, Pammakaristos, Studios, Lips, Myrelaion, Blakhernai
   ve Tekfur, Anemas, kara surları ve her kapı, deniz surları, Altın Kapı, Galata Kulesi ve Galata, açık sarnıçlar,
   limanlar, zincir.
6. **"BOŞ ALAN YOK" kılavuzu:** tarihî olarak seyrek/boş olan her bölge için oraya ne konur ki hem doğru hem dolu
   görünsün: bitki ve tarım türleri (Nisan'daki hâliyle), harabe türleri, manastır/çiftlik/değirmen, mezarlık, sürüler,
   yollar, çitler, su yapıları; sur dışındaki ova (ordugâh düzeni, hendekler, bataryalar), karşı kıyılar (Galata'nın
   arkası, Üsküdar, Kadıköy, Eyüp, Boğaz köyleri), deniz (gemi türleri ve sayıları). En az 80 somut öğe, bölgeye göre.
7. **Kuşatmanın görüntüsü, Nisan 1453:** ordugâh (çadır renkleri ve biçimleri, otağ), toplar ve tabyalar, hendek
   doldurma, sur onarımları (fıçı-toprak-kazık), surlardaki bayraklar (Bizans, Venedik, Ceneviz), zincir ve gemiler,
   geceleri ateşler, dumanlar, çan ve ezan/mehter karşıtlığı (ses için not).
8. **Olmayanlar ve sık yapılan hatalar** (minare, Osmanlı kubbeli cami silüeti, Galata Köprüsü, bugünkü Kız Kulesi,
   kırmızı Marsilya kiremidi vb.) ve oyunun bugünkü modelinde bu belgeye aykırı duran şeyler (kareleri göremezsin; genel
   uyarı olarak yaz).
9. **Kaynakça** (bağlantılarla).
