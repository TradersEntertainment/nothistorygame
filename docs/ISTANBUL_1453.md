DURUM: TAMAM

# İstanbul / Konstantinopolis, Nisan 1453: araştırma belgesi

Amaç: `scripts/world/world1453.gd` haritasını gerçek Nisan 1453 şehrine dayandırmak. Bu belge yalnız araştırmadır; oyun kodu değişmez.

**Kaynak etiketleri.** [WP-Walls] = Wikipedia "Walls of Constantinople"; [WP-Fall] = "Fall of Constantinople"; [WP-Cpl] = "Constantinople"; [WP-Aya] = "Hagia Sophia"; [WP-Hipo] = "Hippodrome of Constantinople"; [WP-Saray] = "Great Palace of Constantinople"; [WP-Valens] = "Aqueduct of Valens"; [WP-Khora] = "Chora Church"; [WP-Pantokrator] = "Pantokrator Monastery"; [WP-Altın] = "Golden Gate (Constantinople)"; [WP-Galata] = "Galata"; [WP-Kız] = "Maiden's Tower"; [WP-Rumeli] = "Rumeli Fortress"; [WP-Tepeler] = "Seven hills of Istanbul"; [WP-geo] = Vikipedi geosearch koordinatları (maddelerin başlık koordinatı); [OSM] = OpenStreetMap Nominatim; [SRTM] = Open-Elevation (SRTM, 90 m ızgara, ±10 m); [VanMillingen] = Van Millingen, *Byzantine Constantinople* (1899, Gutenberg/scriptorium.ro); [Barbaro-WP] = Wikipedia "Nicolò Barbaro" ve arama özetleri; [Clavijo], [IbnBattuta] = arama özetlerinden dolaylı aktarım; [Bilgi] = yazarın genel tarih bilgisi, bu oturumda kaynağa karşı doğrulanmadı (Müller-Wiener, Janin, Mango, Magdalino, Kuban türünden ikinci el literatür). "BELİRSİZ" = emin değilim, uydurmadım. "kestirim" = ölçülmeden tahmin.

**Dürüstlük notu.** WebFetch bir özetleyici model üzerinden çalıştığı için kaynak sayfalar çoğu zaman yalnız ilk 100 bin karakterde okundu; Müller-Wiener/Janin/Mango'nun basılı sayfalarına erişilemedi. Bu yüzden ölçülerin çoğu [Bilgi] etiketlidir; oyunda kullanılırken "yaklaşık" okunmalıdır.

**Koordinat düzeni.** Ayasofya kubbesi (0,0); `dogu_m = (boylam − 28,9800)·84 010`, `kuzey_m = (enlem − 41,0086)·111 200`. Yer dizini: `docs/ISTANBUL_YERLER.csv` (172 satır). Konumlar "kestirim" ise ±100–300 m'dir; Vikipedi/OSM koordinatı olanlar ±50–100 m.

## 1. Genel görünüş, Nisan 1453
- **Nüfus.** Surların içinde büyük olasılıkla 50 bin altı, mülteciler dâhil [WP-Fall]; oyun için 40–50 bin kullanın. Savunmacı sayısı: yaklaşık 7 000 (2 000'i yabancı) [WP-Fall]; Sphrantzes Rum 4 773 + yabancı 200 sayar, ayrıca ~3 000 gönüllü [WP-Fall]. Kesin sayı BELİRSİZ.
- **Neden seyrek.** Kara Veba (1346–49) nüfusu kabaca yarıya indirdi; 1204 yağması ve 1261 sonrası yoksulluk binaları yıktı [Bilgi]. Clavijo (1403–06) büyük saraylar, kiliseler ve manastırların çoğunun harap olduğunu, şehrin ortasında mısır tarlaları ve meyve bahçeleri bulunduğunu, yerin "iyi dolu" olmadığını yazar [Clavijo, arama özeti]. İbn Battuta (1331) Ayasofya–Saray–Hipodrom çekirdeğinin dışında surların içinde "on üç büyük köy", tarla, bağ ve koru anlatır [IbnBattuta, arama özeti; "150 bin" rakamı doğrulanamadı]. Bir Arap coğrafyacı 14. yy başında ekili tarla ve bahçeler ile yıkık evler anar [arama özeti]. Pero Tafur (1437) evlerin yoksul, şehrin gösterişsiz ve seyrek olduğunu yazar [Bilgi].
- **Düzen.** Mahalleler birbirinden bostan, bağ, tarla, harabe ve açık sarnıçla ayrılmış, çoğu kendi manastırı/kilisesi çevresinde "köy" gibidir [Bilgi/Clavijo]. Haliç kıyısında (Blakhernai, Petra/Phanar, Perama–Neorion) ticaret mahalleleri; Ayasofya–Augustaion–Mese çekirdeği; geri kalanı seyrek.
  - **Sık:** Blakhernai çevresi, Petra–Phanar kıyısı, Perama–Venedik kıyısı, Ayasofya ve Patrikhane çevresi, Mese boyu (Konstantin Forumu–Boğa Forumu), Pantokrator/Zeyrek yamacı.
  - **Orta:** Havariyun, Lips–Aspar arası, Kontoskalion ve Samatya kıyısı.
  - **Seyrek/boş:** Hipodrom ve Büyük Saray harabesi, Eleutherios/Langa bostanları, Lykos vadisi, Altın Kapı–Yedikule tarlaları, Aetios–Aspar–Mokios açık sarnıçları (bostan), Marmara yamaçları, Tauri–Arkadius arası, Xerolophos (7. tepe) tarlaları.
- **Mevsim.** Pazartesi 2 Nisan Paskalya sonrasıdır [WP-Fall]. Takvim Julyen'dir; geriye dönük Gregoryen'e +9 gün (2 Nisan → 11 Nisan) [Bilgi, hesap]. Nisan'da İstanbul serin ve değişken: ortalama 9–17 °C, sık sağanak, bulutlu aralar; kuzeyli poyraz ve güneyli lodos rüzgârları [Bilgi]. Gün ~13 saat, güneş ~6:30'da doğar (yerel güneş saati) [Bilgi, hesap]. Bitki örtüsü: çiçekli badem, erik, kiraz, kayısı, elma; erguvan (*Cercis siliquastrum*) ağaçları çiçekte; sarmaşıklar, yabani gelincik/papatya ve çalı; zeytin, incir (yaprak yeni), çınar (yaprak açıyor), selvi (Bizans mezarlıklarında), fıstık çamı; tarlada buğday/arpa yeşil ve diz boyu değil, bostanda bakla, soğan, sarımsak, lahana, kuşkonmaz/enginar, bağda budanmış omcalar (asma yeni sürüyor) [Bilgi]. Işık: yumuşak, yer yer düşük açılı güneş ve nemli hava; sabahları Marmara/Boğaz sisi [Bilgi]. Kuşlar: martı, güvercin (güvercinlik), leylek ve kırlangıç göçü [Bilgi].

## 2. Yeryüzü
- **Yarımada.** Boğaz girişi, Haliç ve Marmara arasında üçgen bir burun [WP-Cpl]. Yedi tepe Roma'ya benzetilir [WP-Cpl]. Kuzeydoğuda Sarayburnu (Akropolis), kara tarafı batıda Theodosius surlarıyla kapalı.
- **Yedi tepe ve yükseklikleri.** [WP-Tepeler] yükseklik vermez; en yüksek zemin yaklaşık 250 ft (≈76 m) [VanMillingen]. Aşağıdaki [SRTM] değerleri modern zemindir, 90 m ızgara nedeniyle ±10 m sapar; Bizans zemini kazı/dolgu nedeniyle birkaç metre farklı olabilir:

| Tepe | Bizans adı / yapısı (1453) | SRTM kotu (m) | not |
|---|---|---|---|
| I | Akropolis/Sarayburnu; Ayasofya, Hipodrom, Büyük Saray | Ayasofya ~45, Hipodrom ~43, Topkapı 3. avlu ~46, Sarayburnu ~19 | Ayasofya platosu |
| II | Konstantin Forumu ve Sütunu | Çemberlitaş ~61, Kapalıçarşı yeri ~52 | |
| III | Theodosius (Tauri) Forumu | Beyazıt ~64, Süleymaniye ~62, Üniversite ~68 | |
| IV | Havariyun, Marcianus Sütunu | Fatih ~65 | Valens Kemeri III–IV arasından geçer [WP-Valens] |
| V | Pantokrator/Zeyrek ve Aspar; Yavuz Selim yeri | Yavuz Selim ~58; Pantokrator ~37; Fener üstü ~44 | |
| VI | Khora, Aetios; Edirnekapı | Khora ~61, Aetios ~61, Edirnekapı kapısı ~76 | kara surunun en yüksek yeri |
| VII | Xerolophos ("kuru tepe"): Arkadius Forumu, Mokios | Arkadius ~46, Mokios ~54 | güneybatı köşe [WP-Tepeler] |

  Haliç ve Marmara kıyısı ~0–10 m; Galata Kulesi tepesi ~53 m, Beyoğlu/Taksim sırtı ~70–82 m, Tarabya ~57 m [SRTM].
- **Lykos (Bayrampaşa) deresi vadisi.** Kara surunu Mesoteikhion'da keser ve Marmara'ya akar [VanMillingen: geniş çayır]; vadi tabanı sur çevresinde yakl. 35–50 m ve surun en alçak kesimidir (SRTM sapması nedeniyle tam kot BELİRSİZ). Sur burada vadiye "çanak" gibi iner, bu yüzden toplar sur yüksekliğinin altında kalan hedefi daha rahat vurur [Bilgi].
- **Haliç.** [WP-Cpl]: iyi, geniş liman. Uzunluk: [VanMillingen] "altı-yedi mil" (≈10–11 km) der; bugünkü ölçüm ~7,5 km, genişlik 0,2–0,8 km, kıyıları dik [Bilgi]. Kuzey kıyısı Pera/Galata, Kasımpaşa, Hasköy, Eyüp (uçta) [Bilgi]. Kağıthane ve Alibey dereleri Haliç'in ucundadır.
- **Boğaz.** Rumeli ve Anadolu Hisarları arası yalnız ~660 m genişliktedir [WP-Rumeli]. Akıntı güneye doğru kuvvetlidir [Bilgi].
- **Marmara.** Surun güneyinde açık deniz, Prens Adaları ufukta [WP-Fall].
- **Kıyı çizgisi bugünküyle aynı DEĞİL.** Yenikapı (Theodosius/Eleutherios Limanı) ve Marmara boyu (Kennedy Caddesi, Kumkapı, Samatya) bugün dolgudur; 1453 kıyısı birkaç yüz metre içerdeydi; Haliç kıyısı da Unkapanı–Cibali–Sirkeci'de dolgudur [Bilgi]. Bu yüzden CSV'de Marmara kapıları bugünkü kıyı çizgisinden biraz içeride, "eski kıyı" varsayımıyla verilmiştir.

## 3. Surlar ve kapılar
### 3.1 Theodosius kara surları [WP-Walls]
- Yapım 404/405–413; dış sur ve hendek büyük olasılıkla 447 depreminden sonra (tartışmalı). Toplam ~5,7 km, Marmara'dan Blakhernai'ye [Bilgi].
- **İç sur:** 4,5–6 m kalın, ~12 m yüksek; kireçtaşı kaplama, harç ve kırık tuğla çekirdek; 7–11 tuğla kuşağı. **96 kule** (çoğu kare, birkaç sekizgen, üç altıgen, bir beşgen); 15–20 m yüksek; aralık 21–77 m. Taş–tuğla şerit örgü: açık bej/sarı kireçtaşı bantlar arasında kırmızı-turuncu tuğla sıraları [Bilgi].
- **Peribolos:** iki sur arası teras (~15–20 m) [Bilgi: genişlik].
- **Dış sur:** tabanda ~2 m kalın, 8,5–9 m yüksek; **62 kule** (12–14 m, ~4 m geniş), iç kulelerin ortasına denk gelir.
- **Hendek:** dış surdan ~20 m ötede, 20 m'den geniş, 10 m'ye dek derin; iç yüzünde 1,5 m kenar duvarı; enine duvarlarla bölünmüş (su dolu olması gerekmez; 1453'te su tutmuyordu: BELİRSİZ).
- **Mesoteikhion:** en zayıf kesim; sınırı tartışmalı. Rhegion–Romanos arası, ~1 500 m [WP-Walls/WP-Fall].
- **Savunma gereçleri (Nisan 1453):** hendek içinde savunmacıların kazdığı kesişen duvarlar/çit; surun önüne kum torbası, yünlü örtü ve fıçı barikatı; onarım iskeleleri; kule tepelerinde ocaklar ve taş yığınları [Bilgi].

### 3.2 Kapılar (kuzeyden güneye) [WP-Walls; konumlar CSV'de]
| # | Bizans adı | Bugünkü ad | 1453 notu |
|---|---|---|---|
| 0 | (Blakhernai) Kaligaria? | Eğrikapı | Manuel suru ucunda; Venedikli Minotto'nun bölgesi [WP-Fall] |
| 1 | Karisios (Charisius) | Edirnekapı | Bocchiardi kardeşler (önce Giustiniani) [WP-Fall]; 6. tepe doruğunda; Fatih buradan girdi (efsane) |
| 2 | Beşinci Askerî Kapı (Pempton) | Hücum Kapısı/Sulukule | 29 Mayıs yarığı [WP-Walls] |
| 3 | Aziz Romanos | Topkapı | 26,5 m kapı yapısı; Mesoteikhion'un kuzey ucu |
| 4 | Dördüncü Askerî Kapı | — | duvarla kapalı |
| 5 | Rhegion (Rhesios) | Mevlanakapı | en iyi korunan; Mesoteikhion'un güney ucu |
| 6 | Üçüncü Askerî Kapı (Triton) | — | Kalagros olabilir |
| 7 | Pege | Silivrikapı | Cataneo, Theophilos Palaiologos [WP-Fall]; dışarıda Balıklı Ayazması |
| 8 | İkinci Askerî Kapı (Deuteron) | — | |
| 9 | Xylokerkos | Belgratkapı | 1189'da kapatılmış |
| 10 | — | Yedikule posterna | kule 11–12 arası |
| 11 | Altın Kapı (Chryseia) | Altınkapı | 3 kemerli mermer tören kapısı, 9.–10. kule arası; geç Palaiologos döneminde duvarla kapatılıp küçültülmüş, kale gibi kullanılmış; John V 1389–90 onarmış, Bayezid I 1391'de yıktırmış, John VIII 1434'te onarmaya kalkmış, Murad II engellemiş [WP-Altın]; Yedikule Hisarı Mehmed II 1458 [WP-Altın] → 1453'te yok |
| 12 | Birinci Askerî Kapı | Tabakkapı | kara–deniz sur birleşimi, posterna |
- **Kerkoporta:** kule 96 yakını, 1453 düşüşüyle anılır ama kazıyla doğrulanmadı [WP-Walls].
- **Kule/kapı görünümü:** kareli kuleler iki üç kat, üstte kirişsiz taş ve tuğla parapet; kapı yapıları kemerli, iç kapı demir kaplı ağaç [Bilgi].

### 3.3 Blakhernai surları [WP-Walls]
- Manuel I suru: ~220 m, sekiz kule, üstte ~5 m kalın; Eğrikapı. Leon suru (813): <3 m kalın. İç sur: Theophilos'un üç altıgen kulesi.
- Blakhernai kapısı; Brakhionion (Pentapyrgion); Gyrolimne postern (kapalı); Anemas zindanı = deniz suruyla birleşim. Anemas'ın yeri Haliç'e çıkan köşedir.
- Blakhernai Meryem Ana kilisesi 1434'te yanmıştı; sonrası BELİRSİZ [Bilgi].

### 3.4 Deniz surları [WP-Walls]
- **Haliç suru:** ~5 600 m, ~10 m yüksek, kıyının gerisinde; Buondelmonti 14 kapı, 110 kule sayar.
- **Haliç kapıları (batıdan doğuya, WP):** Koiliomene, Ag. Anastasia, Balat (Kynegion), Phanarion, Petrion, Yeni Ayakapı, Ayakapı (Ag. Theodosia), Eis Pegas, Platea, Ayazma, Drungaris, Ag. Ioannes, Perama, Hikanatissa, Neorion (Horaia), Bonus, Eugenios (Marmaroporta). [Kapı adlarının bugünkü karşılıkları ve tam konumları kaynaklarda değişir; CSV'deki konumlar sıralama + kıyı poligonundan enterpolasyondur, ±150 m.]
- **Marmara suru:** ~8 460 m + Vlanga limanı için 1 080 m; 12–15 m yüksek; 13 kapı, 188 kule; mermer sütun kalıntılarıyla güçlendirilmiş, kayalarla dalgakıran.
- **Marmara kapıları (Sarayburnu'ndan güneye):** Doğu (Ag. Barbara), Değirmen, Demirkapı, Balıkhane, Ahırkapı, Aslan/Boukoleon, Sophiae (Demir), Kontoskalion, Yenikapı, Davutpaşa (Ag. Aemilianos), Psamatya, Narlıkapı.
- **Zincir:** Leon III'ten beri Haliç ağzında yüzer varillerle/kütüklerle; bir ucu Eugenios Kulesi (Sirkeci), diğer ucu Galata Kastellion'u [WP-Walls]; Barbaro Venedik/Ceneviz gemilerinin zincir boyunca dizildiğini aktarır [Barbaro-WP]. Uç koordinatlarından hesaplanan uzunluk ~750 m (kestirim). Nisan başında gerilmişti [WP-Fall: "öncesi"].
- **Savunma bölüşümü [WP-Fall]:** Mesoteikhion: İmparator XI. Konstantinos, sonra Giustiniani; Charisios: Bocchiardi kardeşler; Blakhernai: Minotto ve Venedikliler; Pege: Cataneo ve Theophilos; Pege–Altın Kapı: F. Contarini; en güney: Kantakuzenos; Stoudios deniz suru: J. Contarini ve keşişler; Eleutherios Limanı: Prens Orhan; Büyük Saray: Cenevizliler ve Katalanlar; zincir yakını: Kardinal Isidoros; Haliç güneyi: Trevisano; yedek: Notaras (Petra), N. Palaiologos (Havariyun yakını); liman gemileri: Diedo. [WP-Kız]: Kız Kulesi (Damalis) Venedikli Gabriele Trevisano komutasında garnizonluydu.

## 4. Anıtlar (1453 hâliyle)
Biçim: **yer** (CSV'deki satırla) · **ölçü** · **malzeme** · **renk** · **1453 durumu**. Rakam kaynağı yoksa [Bilgi]; renkler yalnız malzemeden çıkarsama olup resmî bir tanık betimlemesi değildir (BELİRSİZ).

### 4.1 Çekirdek: Ayasofya–Augustaion–Hipodrom–Saray
1. **Ayasofya (Hagia Sophia).** *Yer:* 1. tepe, Augustaion'un kuzeyi; kubbe (0,0). *Ölçü:* 82 × 73 m taban, iç yükseklik 55,6 m [WP-Aya]; kubbe çapı ~32,7–33,5 m [WP-Aya; öteki kaynaklar ~31–32 m]. *Malzeme:* kesme taş ve Roma tuğlası, kurşun örtülü kubbe [WP-Aya]; dışta yıpranmış sıva/kireç; ilk dönem kaplaması beyaz mermerdi, 1453'te çoğunlukla çıplak tuğla-taş ve harçlı yüzey [WP-Aya/Bilgi]. *Renk:* kurşun grisi kubbe; açık sarımsı–pembemsi sıva ve kırmızı tuğla; yağmurla kararmış. Bugünkü sarı-kırmızı Fossati boyası (19. yy) YOK [WP-Aya]. *Ayrıntı:* 1317'de Andronikos II dört yeni payanda (doğu ve kuzey) eklemiştir [WP-Aya]; 1354'ten beri onarım [WP-Aya]. Narteks, batı avlusu (atrium) ve fiale hâlâ var olabilir (BELİRSİZ). **Minare YOK** [WP-Aya]. *Durum:* patrikhane katedrali; 1452 birlik (Floransa) kararı Ortodoksları küstürdü, halk bir süre kiliseden uzak durdu [WP-Aya/Doukas]; 21 Mayıs'ta kubbede ışık alametinin bildirilmesi [WP-Aya]; kuşatmada sığınanlarla dolu.
2. **Augustaion.** *Yer:* Ayasofya'nın güneyi, Chalke Kapısı önü. *Ölçü:* ~100 × 60 m [kestirim]. *Malzeme:* mermer döşeli meydan; revaklar. *Durum:* harap, kısmen bostana dönmüş (BELİRSİZ). Mese buradan başlar [WP-Saray]. Milion (tetrapilon) burada, harap [WP-geo].
3. **Iustinianus Sütunu.** *Yer:* Augustaion. *Ölçü:* ~35 m [Bilgi]. *Malzeme:* tuğla-taş sütun, bronz kaplamalı kaide, tepede bronz atlı heykel. *Durum:* Tafur (1437) gördü [Bilgi]; 1453'te ayakta olması muhtemel, heykel BELİRSİZ.
4. **Hipodrom (At Meydanı).** *Yer:* Ayasofya'nın güneybatısı, 1. tepe. *Ölçü:* ~450 × 130 m, ~100 000 seyirci kapasite [WP-Hipo]. *Malzeme:* taş ve tuğla tribünler, güney ucu sphendone. *Durum:* harap, taş ocağı, otlak/bostan gibi; Latinler 1204'te dört bronz atı götürdü [WP-Hipo]. Yarış 1453'te yok.
   - **Teodosius Dikilitaşı:** pembe granit, Mısır kökenli (Karnak, ~MÖ 1490), 390'da getirildi, mermer kaide üstünde [WP-Hipo]; ~19,6 m üst parça [Bilgi]. Ayakta.
   - **Yılanlı Sütun:** MÖ 5. yy bronz üç yılan, Delfi/Plataia zaferi [WP-Hipo]; 1700'de üst üçte biri ve başlar yok edildi [WP-Hipo] → **1453'te yılan başları büyük olasılıkla yerindeydi** (Fatih'in topuzuyla bir başı kırdığı rivayeti [Bilgi, efsane]).
   - **Örme (Konstantin Porphyrogennetos) Dikilitaşı:** taş çekirdek, ~32 m [Bilgi]; yaldızlı bronz levhaları 1204'te Latinlerce sökülmüştü [WP-Hipo] → 1453'te çıplak taş çekirdek.
   - **Kathisma (imparator locası):** doğu kenarında, Büyük Saray'dan geçitle bağlıydı [WP-Hipo]; harap.
   - **Sphendone:** güney kavis, alt kemerleri ayakta [WP-Hipo].
5. **Büyük Saray.** *Yer:* Hipodrom ile Marmara arası, 1. tepenin güney yamacı, altı teras, ~16 ha, kıyıya ~33 m iniş [WP-Saray]. *Parçalar:* Chalke, Magnaura, Daphne, Kathisma, Bukoleon [WP-Saray]. *Durum:* 11. yy'dan Blakhernai tercih edildi; 1204 yağması; Baldwin II kurşun çatıları sattı; 1261'den sonra terk edildi, bodrumları zindan [WP-Saray]; 1453'te harap ve boş [WP-Saray]. Cenevizliler ve Katalanlar bu bölgede savundu [WP-Fall]. Duvarlar yer yer ayakta, merdivenli tonoz altyapı, yıkık revaklar, yabani incir ve sarmaşık [Bilgi].
6. **Bukoleon Sarayı ve Limanı.** *Yer:* Marmara kıyısı, Aslan Kapısı (CSV). *Ölçü:* mermer cepheli deniz sarayı (Theophilos), imparator limanına kapı [WP-Saray]. *Durum:* harap; 1453'te lagün gibi bir koy [Bilgi].
7. **Aya İrini.** Büyük Saray'ın 1. avlusu; 1453'teki durumu BELİRSİZ.
8. **Küçük Ayasofya (Sergios ve Bakkhos).** Sekizgen kubbeli, ~25 m [Bilgi]; durum BELİRSİZ.
9. **Mangana Arsenali** (Sarayburnu yamacı) harap [Bilgi]. **Hodegon** (Hodegetria ikonu) Saray'a yakın; ikon 1453'te surlara/Khora'ya taşınmıştır [WP-Khora].

### 4.2 Forumlar ve sütunlar (Mese boyunca)
10. **Mese.** Augustaion'dan Konstantin, Theodosius (Tauri), Boğa ve Arkadius forumlarına, Altın Kapı yönünde 2. tepeden 7. tepeye uzanır [WP-Cpl]. Genişlik ~25 m [Bilgi]. İki yanı eskiden revaklıydı; 1453'te kesik kesik, harabeler ve bostanlarla.
11. **Konstantin Forumu ve Sütunu.** 2. tepe, oval forum ~160 × 130 m [Bilgi]; sütun ~35 m, porfir tamburlar, tepesinde (1105'te devrilen Apollon heykelinden sonra) haç [Bilgi]. 1453'te ayakta.
12. **Theodosius (Tauri) Forumu.** 3. tepe; harap, Beyazıt Meydanı yeri; zafer sütunu kalıntısı, kemer parçaları. Osmanlı Eski Saray'ı YOK.
13. **Boğa Forumu (Aksaray).** Mese'nin 7. tepeye çıkış noktası; öküz heykeli bakırdan (yok olmuş). Harap [Bilgi].
14. **Arkadius Forumu ve Sütunu.** 7. tepe (Xerolophos) [VanMillingen]; ~50 m sütun, spiral kabartmalı mermer [Bilgi]; ayakta; çevresi bostan.
15. **Marcianus Sütunu.** Havariyun yakını, ~10 m granit, tepede heykel yok [Bilgi]. **Philadelphion:** Mese'nin ikiye ayrıldığı kavşak; sütun/kemer kalıntısı [WP-geo].

### 4.3 Su yapıları
16. **Bozdoğan (Valens) Kemeri.** 3.–4. tepe arası [WP-Valens]. Ölçü: orijinal 971 m (kalan 921 m), ~29 m yükseklik, ~7,75–8,24 m genişlik, ayak kalınlığı ~3,7 m; kesme taş, harç, demir kenet [WP-Valens]. 1403'te Kastilyalı elçi çalıştığını bildirmiş; Latin ve Palaiologos döneminde bakımsız [WP-Valens]. Arkları Osmanlı onarımlarından (16–18. yy) önceki hâlinde: kırık, yer yer bitki ve yuva.
17. **Açık sarnıçlar (bostan/tarla):** *Aetios* (~244 × 85 m), *Aspar* (~152 × 152 m), *Mokios* (~170 × 147 m) [Bilgi]; duvarlar 8–15 m yükseklikte; içleri bostan, meyve bahçesi, hayvan otlağı [Bilgi]; çevre taş duvar yer yer çökmüş. Konum CSV'de ([WP-geo]).
18. **Kapalı sarnıçlar:** Yerebatan (Basilica, ~138 × 65 × 9 m, 336 sütun), Binbirdirek (Philoxenos, ~64 × 56 m, 224 sütun), Theodosius Sarnıcı, Myrelaion altı [Bilgi/WP-geo]. Dar kuyu ağızları sokaklarda; bazıları evlerin altından su alıyor.
19. **Çeşmeler:** Ayasofya fialesi, mahalle çeşmeleri, kıyı kaynakları (Balıklı Ayazması); Blakhernai ayazması [Bilgi].

### 4.4 Kiliseler ve manastırlar
20. **Havariyun.** 4. tepe, haç planlı beş kubbeli (Justinianus); Konstantin ve imparatorlar nekropolü; harap (BELİRSİZ); Mehmed Gennadios'u 1454'te patrik yapınca patrikhane buraya taşındı [WP-Aya].
21. **Pantokrator (Zeyrek).** Haliç yamacı, iki kubbeli kilise + şapel, kaba tuğla/derinleştirilmiş harç tekniği, opus sectile zemin, hastane ve kütüphane; Gennadios Scholarios keşiş [WP-Pantokrator]. Kullanımda.
22. **Khora (Kariye).** Kara surunun hemen içinde, Edirnekapı yanı; 742,5 m², altı kubbe; ana kubbe 7,7 m; eksonarteks ~4×23 m, ezonarteks ~4×18 m; mozaik ve freskler (Metochites, 1315–21) [WP-Khora]. Kuşatmada Hodegetria ikonu getirildi [WP-Khora].
23. **Pammakaristos.** Haliç tepesinde, Notaras bölgesi; Palaiologos döneminde parekklesion (Glabas, ~1310) [Bilgi]. Patrikhane 1456'dan [Bilgi].
24. **Stoudios (Imrahor).** Marmara'ya yakın, en eski bazilika manastır (5. yy, ~25 × 12 m) [Bilgi]; Jacopo Contarini ve keşişler savundu [WP-Fall]; çevresinde küçük kale ilk günlerde alındı [WP-Fall].
25. **Peribleptos (Sulu Manastır, Samatya).** Dış cephe tuğla/taş, bağ ve bahçe çevresi [Bilgi]. **Lips (Fenari İsa)** iki kilise, kuzeyde sıralı sütun [Bilgi]. **Myrelaion** (Bodrum Camii) altı sarnıçlı tonoz üstünde [Bilgi]. **Kyriotissa (Kalenderhane)**, **Ag. Theodosia (Gül)** Haliç yamacında [WP-geo].
26. **Blakhernai Meryem Ana (Ayazma)** 1434'te yanmış; burada ikon kutsal kaynak; yeri sarayın hemen yanı [Bilgi].
27. **Tipik küçük kilise sayısı.** Yüzlerce kilise/şapel (Janin ≈ 300) varlığı geçmişte; 1453'te kullanımda olan birkaç düzine [Bilgi, düşük güven].

### 4.5 Saraylar ve kuşatma sahası yapıları
28. **Blakhernai Sarayı + Tekfur Sarayı (Porphyrogennetos).** Kara surunun Haliç ucunda; Blakhernai imparatorluk ikâmetgâhı olarak 11. yy'dan; 14. yy'da bakımsız (Clavijo harap dedi) [Bilgi]; Tekfur Sarayı üç katlı, tuğla–taş şerit örgülü, ~40 × 15 m [Bilgi]. 1453'te imparator komuta yeri olarak kullanılması BELİRSİZ.
29. **Anemas zindanları.** Haliç ve kara surunun birleşimi; zindan [WP-Walls].
30. **Altın Kapı ve Yedikule öncülü.** Bkz. 3.2 (11). Palaiologos kalesi; Fatih'in 1458 hisarı YOK.

### 4.6 Limanlar, iskeleler, yabancı mahalleler
31. **Kontoskalion Limanı** (Kadırga): kısmen dolu, küçük tekne [Bilgi]. **Eleutherios (Theodosius) Limanı:** dolmuş, bostan/tarla [WP-Fall/WP-geo]. **Langa/Vlanga:** küçük iskele ve bostanlar [Bilgi]. **Neorion** tersane/arsenal (Haliç), silik, **Prosphorion** ve Perama iskeleleri Haliç'te aktif [Bilgi].
32. **Yabancı mahalleler (Haliç kıyısı):** Venedik (kendi kilisesi Ag. Akindynos, bailo evi, depolar) [Bilgi]; Ceneviz payı Pera'ya geçmişti (1267); Pisa ve Amalfi küçüldü; Provençal, Katalan, Anconitan ticaret kolonileri var [Bilgi]. Konumlar kaynaklarda çelişir (CSV'de kestirim).
33. **Yahudi mahallesi.** Eski Vlanga (Marmara) ve Pera/Haliç kıyısında; Galata'da Rum konuşan Yahudiler [WP-Galata]. Balat'ta Yahudi nüfusu 1453'te BELİRSİZ.
34. **Tersane/gemi evleri.** Haliç iç kıyı gemi onarım yerleri, Perama–Neorion [Bilgi].

## 5. Galata (Pera)
- **Statü.** Ceneviz kolonisi (1267'den), podestà yönetiminde; Bizans'a değil, Cenova'ya bağlı. Kuşatmada resmen tarafsız [WP-Galata/WP-Fall]; ticari ve gizli yardımlar yapıldı, Barbaro Cenevizlileri Osmanlılarla işbirliğiyle suçladı [Barbaro-WP]. Nüfus tahmini (Bilgi): birkaç bin kişi; Halil İnalcık'ın 1455 sayımına göre fetihten sonra nüfusun ~%8'i kaçmıştır [WP-Galata].
- **Surlar.** 1303'te sur yasağına rağmen genişletildi [WP-Galata]. Haliç kıyısı boyunca, tepeye doğru tırmanıp Galata Kulesi'nin altındaki zirveyi çevreleyen, hendekli (Büyük Hendek) üçgen sur; 19. yy'da yıkıldı, bugün yalnız kule yanında parça kaldı [WP-Galata]. Kapılar: Haliç tarafı (Azapkapı/Perama), Boğaz tarafı (Tophane), kuzey kapı (Şişhane/Tünel yönü) — konumlar CSV'de (kestirim).
- **Christea Turris (İsa Kulesi).** 1348'de kolonin kuzey tepesi/zirvesinde [WP-Galata]. Bugünkü ~62 m külahlı biçim YOK; Ceneviz taş kulesi daha alçak, düz/mazgallı çatı (yükseklik BELİRSİZ) [Bilgi]. Fener/ışık görevi 1453'te BELİRSİZ.
- **Kastellion (Megalos Pyrgos).** Zincirin kuzey ucunu kontrol eder; 1203'ten sağ kalmıştır [WP-Galata]. Kıyıdaki bugünkü Yeraltı Camii yeri [WP-geo].
- **Yapılar.** San Domenico/San Paolo (şapel 1233, Dominiken 1325) — bugünkü Arap Camii yeri; Saint Benoit (1427); Palazzo del Comune (Podestà Sarayı, 1314, Montano De Marini) [WP-Galata]. Santa Maria Draperis'in 1453'teki yeri BELİRSİZ. Dar sokaklar, taş–tuğla ve ahşap evler, depolar [Bilgi].
- **İskeleler.** Haliç ağzından Perama'ya kadar kıyıda rıhtım/iskele sırası; Ostreodes ve Karaköy iskeleleri [WP-geo].
- **Buondelmonti (1422).** Pera'yı hendekli ve surlu gösterir [arama özeti].
- **Ayrıca:** Pera Rum, Ermeni ve Yahudi nüfus da barındırdı [WP-Galata].
- **Kuşatma bağlantısı.** 22 Nisan'da gemiler Galata'nın arkasından geçirildi (Bkz. 8). Sultan'ın Pera'ya ilişkin güvenceleri BELİRSİZ.

## 6. Sıradan yapılar
Genel güven düşük; bu bölümdeki ölçüler [Bilgi] (Müller-Wiener, Kuban, Magdalino: geç Bizans konut mimarisi) ve ilgili arkeolojik buluntu özetleridir; kazı verisi seyrek.
- **Geç Bizans evi.** Cephe 6–12 m (dar parseller 4–6 m); zemin kat taş veya taş–tuğla örgü (opus mixtum), 2,5–3 m; üst kat/katlar ahşap ağırlıklı, çıkma yapan balkon ("solarion"/heliakon) sokağa taşar; çatı alçak eğimli kiremit (oluklu kil, "kiremit"); avlu içeride, kuyu ve sarnıç; üstte teras/çatı bahçesi [Bilgi]. Bir eve ortalama 2 kat.
- **Dükkân.** Zemin katta açık cephe, ahşap kepenk-tezgâh; üstte konut; tente (bez/hasır) [Bilgi]. Tezgâh önü taş sıra.
- **Han/fondaco.** Venedik/Ceneviz depo-ikamet evi, avlulu, iki kat revaklı [Bilgi]. Osmanlı "han"ları (Kürkçü, Valide) YOK.
- **Fırın.** Taş kubbeli ocak, avlu içinde veya sokağa bakar; ekmek halkası (kolouri) BELİRSİZ.
- **Değirmen.** Atla/öküzle çevrilen el değirmenleri ve su gücü (Lykos) BELİRSİZ; yel değirmeni BELİRSİZ.
- **Hamam.** Küçük Bizans hamamları (kubbeli tonoz) birkaç tane sağ [Bilgi, BELİRSİZ].
- **Manastır avlusu.** Dikdörtgen avlu, sütunlu revak, ortada çeşme/kuyu, kilise yanında hücreler, bahçe ve kümes [Bilgi].
- **Küçük kilise tipleri.** Haç planlı kubbeli (cross-in-square), 8–15 m kenar; tonozlu bazilika; ahşap çatılı salon; parekklesion (yan şapel) [Bilgi]. Çan yerine semantron (tahta levha) kullanımı yaygın; çan da Konstantinopolis'te anılır (Doukas: 29 Mayıs alarm çanı) [Bilgi].
- **Çeşme/kuyu.** Duvar çeşmesi veya sarnıçlı kuyu; taş sekili.
- **Mezarlık.** Kilise yanında selvi ve mermer lahit parçaları; Hristiyan mezarlığı sur dışında da var; Hristiyan mezar taşı Osmanlı kitabeli sanduka biçiminde YOK [Bilgi].
- **Bağ/bostan duvarı.** Kuru taş veya çit, yer yer harap [Bilgi].
- **Harabe türleri.** Çatısız duvar kalıntıları; yıkık kemerler (Mese revakları); devrik sütun gövdeleri ve başlıkları devşirme olarak evlerde; yıkık saray tonozları; boşalmış sarnıç [Bilgi].
- **Ölçü aralıkları (tek bakışta).**

| Öğe | Aralık |
|---|---|
| Ev cephesi | 4–12 m |
| Kat yüksekliği | 2,5–3,2 m |
| Ev yüksekliği (çatı sırtı) | 6–9 m |
| Dar sokak | 1,5–3 m (arka sokak) |
| Orta sokak | 4–6 m |
| Mese | ~25 m |
| Meydan/forum | 60–160 m |
| Küçük kilise | kenar 8–15 m, kubbe çapı 4–7 m |
| Kara sur iç duvarı | 4,5–6 m kalın, ~12 m yüksek [WP-Walls] |
| Haliç suru | ~10 m [WP-Walls] |
| Marmara suru | 12–15 m [WP-Walls] |

## 7. Sokak hayatı ve ayrıntı dizini
Güven: kesin = var (genel Bizans/Akdeniz kanıtı), olası = bu çağda mümkün, BELİRSİZ. Kaynak çoğunlukla [Bilgi]; kayıtlı ayrıntı yalnız bu belgede anılan yerlerde. Mahalle türleri: **K** = kıyı/liman, **Ç** = çekirdek (Ayasofya–Mese), **M** = mahalle/köy, **B** = bostan/tarla, **H** = harabe, **S** = sur boyu, **Ma** = manastır/kilise, **G** = Galata, **O** = Osmanlı ordugâhı, **D** = deniz.

### 7.1 Kıyı ve liman (K)
1. Ahşap iskele ve rıhtım tahtaları, tuzla beyazlaşmış babalar (bağlama kazıkları) — kesin.
2. Taş babalar ve demir halkalar (Haliç kıyısı) — kesin.
3. Amfora yığınları (şarap/zeytinyağı, sivri dipli, ahşap çerçevede) — kesin.
4. Fıçı sıraları (şarap, balık turşusu) — kesin.
5. Balık ağı kurutma çatıları ve ağ çırpma — kesin.
6. Küçük balıkçı kayıkları, yedek kürek, kıçta tek yelken — kesin.
7. Olta ile kıyıdan balıkçılık (iskelede) — kesin; çok kişi olması BELİRSİZ.
8. Kıyıdaki tuzlu balık tezgâhları (hamsi, uskumru, torik) — kesin.
9. Martılar (kıyıda, çatılarda, kayıklarda) — kesin.
10. Yelkenli/kadırga yükleme tahtaları, halat tekerleri — kesin.
11. Halat yığınları ve ağır demir çapalar — kesin.
12. Gemi onarımı: kalafat ateşi, kaynar zift kazanı — kesin.
13. Kereste yığınları ve testere çukuru — olası.
14. Yük arabaları ve çıplak ayaklı hamallar, sırtta çuval — kesin.
15. Eşek ve katır kervanı iskeleden yamaca — kesin.
16. Gümrük/ağırlık tezgâhı (kantar, ölçü kapları) — kesin.
17. Venedik arması (kanatlı aslan) levhası, Ceneviz haçı levhası — kesin.
18. Yabancı tüccar depo kapıları (kemerli, demir kilitli) — kesin.
19. Perama'da Galata'ya karşı kayık kuyruğu — kesin.
20. Haliç ağzında gerilmiş zincirin yüzer kütükleri — kesin [WP-Walls].
21. Zincir başında nöbet ateşi ve kule — kesin.
22. Savaş gemileri (kadırga, nave) kıyıya halatlı — kesin [WP-Fall].
23. Çıplak kıyıda çamur, yosun, deniz çöpü — kesin.
24. Sığ yerde midye/istiridye (Ostreodes) toplayanlar — olası.

### 7.2 Çekirdek: Ayasofya, Mese, forumlar (Ç)
25. Ayasofya kapısında dilenciler, rahipler, mum satıcıları — kesin.
26. Kurşun kubbede güvercin ve martı — kesin.
27. Ayasofya duvarına yapışık dükkân/barakalar — olası.
28. Fiale (abdest/şifa çeşmesi) — kesin (BELİRSİZ işleyişi).
29. Mum, buhur, mühür satıcıları, kandil yağı (zeytinyağı) — kesin.
30. İkonacı tezgâhı: boyalı ahşap ikona, ucuz baskı yok — kesin.
31. Kutsal emanet satıcıları (sahte parmak, bez parçası) — olası [Bilgi].
32. Mese üzerinde düzenli taş döşeme ve çatlaklar — kesin.
33. Revak sütunlarının arasına sıkıştırılmış dükkânlar — olası.
34. Forum zemininde ot, çalı ve lahit parçaları — kesin.
35. Sütunların yakınında sahipsiz mermer parçaları (devşirme) — kesin.
36. Sokak lambası YOK; gece kapı önü kandil ve meşale — kesin.
37. Kapı tokmağı ve gıcırdayan ahşap kepenk — kesin.
38. Bakkal/aktar tezgâhı: kuru incir, ceviz, bal, baharat — kesin.
39. Kasap: asılı koyun, kan ve sinek — kesin.
40. Fırıncı çırağı ekmek tablası taşır, kokusu sokakta — kesin.
41. Yerde kemik, sebze artığı, köpekler — kesin.
42. Sokak köpekleri ve kedi sürüsü — kesin.
43. Çeşme başında bekleyen kadınlar (testi, tulum) — kesin.
44. Hamal, ayakkabıcı, su taşıyıcısı (sucu) — kesin.
45. Yoksul keşişler, dilenci çocuklar — kesin.
46. Patrikhane görevlileri ve diyakoz alayları — kesin.
47. Sokakta ayin alayı: ikon, haç, kandil, davul-trampet YOK; zil/semantron sesi — kesin.
48. Çan sesi (alarm) veya semantron — olası [Bilgi].
49. Heykel kaideleri üzerinde yazılı mermer yazıt (Yunanca) — kesin.
50. Sıva üstüne haç kazıma, grafiti — kesin.

### 7.3 Hipodrom ve Büyük Saray harabesi (H)
51. Hipodrom ortasında ot ve çalı, koyun/keçi otlağı — olası.
52. Sphendone kemerlerinde yuva yapan serçe/güvercin — kesin.
53. Yıkık tribünlerde taş sökülüp götürülmüş boşluklar — kesin [WP-Hipo: taş ocağı].
54. Dikilitaş (granit) ve Yılanlı Sütun arasında çalı — kesin.
55. Büyük Saray tonozlarında zindan kapıları — kesin [WP-Saray].
56. Sarmaşık ve yabani incir yıkık duvarlarda — kesin.
57. Çatısız oda duvarları, eski mozaik zemin kalıntıları — kesin.
58. Kaçak çöp ve toprak yığını — kesin.
59. Deniz tarafında Bukoleon'un yıkık balkonu — kesin.
60. Savunma: Cenevizli ve Katalan nöbetçiler — kesin [WP-Fall].
61. Tırmanılabilir: yıkık duvarlarda basamak, çıkıntılar (oyun için) — kesin.

### 7.4 Mahalle (köy) sokakları (M)
62. Taş–tuğla zemin kat + ahşap çıkma üst kat — kesin.
63. Eğik kiremit çatı, yosunlu, yer yer eksik — kesin.
64. Avlu kapısı, içeride kuyu — kesin.
65. Kuyu: taş yuvarlak ağız, ip makara, ahşap kova — kesin.
66. Çamaşır ipi, sokak ile avlu arasında — kesin.
67. Kümes, tavuk, horoz — kesin.
68. Güvercinlik (kule veya çatı) — kesin.
69. Eşek ve katır (sokakta, bağlı) — kesin.
70. İki tekerlekli el/öküz arabası — olası; el arabası (tek tekerlek) BELİRSİZ.
71. Duvar nişinde ikona ve kandil (sokak köşesi) — kesin.
72. Kapı üstünde haç veya ikon kabartması — kesin.
73. Çatıda anten/çanak YOK; kurutulmuş balık, ot ve soğan iplikleri — kesin.
74. Çatı bacaları: küçük tuğla baca — BELİRSİZ.
75. Çıkmalardan sarkan sepet/kafes — olası.
76. Yağmur suyu için oluk/küp — kesin.
77. Gece ev önünde küçük yağ kandili — kesin.
78. Çocuklar taş atar, taş oyunları — kesin.
79. Taş, tuğla ve pişmiş toprak bozuntusu — kesin.
80. Kahvehane YOK (kahve yok); "kapelio" (şarap evi) var — kesin.
81. Şarap dükkânı: küp ve ağaç fıçı — kesin.
82. Zeytinyağı küpü evde — kesin.
83. Dikiş/dokuma tezgâhı, yün eğirme sokak kapısında — kesin.
84. Mezarlık yanında selvi — kesin.
85. Sokak boyunca açık mezbele/gübre yığını — kesin.
86. Mülteci aileler: çadır, bez barınak — olası (kuşatma öncesi köylülerin sığınması) [WP-Fall].
87. Sur dışı köylüler ağıllarla içeri alınmış — olası.

### 7.5 Bostan, tarla, bağ (B)
88. Bostanda bakla, soğan, sarımsak, lahana — kesin.
89. Kuru taş çit; çit üstünde dikenli çalı — kesin.
90. Meyve ağaçları: badem, erik, kiraz, elma, armut, nar (çiçek açmış) — kesin.
91. Zeytin ağaçları (yaşlı) — kesin.
92. Bağ: asma kütükleri, destek kazıkları — kesin.
93. Tarla: buğday/arpa yeşil, öküzle sürülmüş anız — kesin.
94. Arı kovanı (hasır/ağaç kütüğü) — olası.
95. Çoban ve küçük sürü (koyun, keçi) — kesin.
96. Tek kişilik gözetleme kulübesi — olası.
97. Açık sarnıç dibi: yeşil su, kamış, kurbağa — kesin (Aetios, Aspar, Mokios).
98. Sarnıç duvarına yaslı küçük kulübe — olası.
99. Eşekle su taşıma — kesin.
100. Yaban gelincik, papatya, nergis, mor sümbül — kesin [Bilgi].
101. Erguvan ağacı çiçekte (mor) — kesin [Bilgi].
102. Çınar ağaçları, yeni sürgün — kesin.
103. Çiftçi evi: taş zemin, saman çatı — olası.
104. Samanlık, ahır, tahıl ambarı — kesin.
105. Su değirmeni (Lykos) — BELİRSİZ.
106. Gübre ve çürük bostan atığı yığını — kesin.

### 7.6 Manastır, kilise (Ma)
107. Avlu çevresi revak, ortada çeşme — kesin.
108. Keşişler: siyah cüppe ve kukulla — kesin.
109. Kütüphane/skriptoryum penceresi, mum — kesin.
110. Kilise girişinde narteks: ikonlar, kandil asma zinciri — kesin.
111. Kubbeli kilise, dışarıda tuğla ve taş şerit — kesin.
112. Çan YOK ya da küçük; semantron — olası.
113. Mezarlıkta lahit parçaları — kesin.
114. Hastane odası (Pantokrator) — kesin [WP-Pantokrator].
115. Fresk ve mozaikli ikonlar (Khora) — kesin [WP-Khora].
116. Dilencilere dağıtılan ekmek ve çorba — kesin.
117. Hodegetria ikonu alayı — kesin [WP-Khora].
118. Ayin sırasında kemanlı/organlı müzik YOK; uzun koro — kesin.

### 7.7 Sur boyu ve savunma hazırlığı (S)
119. Kule tepesi taş yığınları — kesin.
120. Onarım iskelesi (ahşap kirişli, bağlı) — kesin.
121. Hendekte ahşap çit, kazık ve doldurma — kesin.
122. Kum torbası, yün balyası, deri barikatı (topa karşı) — olası [Bilgi].
123. Surun kapıları sürgülü ve demir bağlı — kesin.
124. Kapı önünde nöbetçi ateşi ve yağ kazanı — kesin.
125. Okçu, arbaletçi, tüfekçi ve zırhlı piyade savunmacılar — kesin.
126. Ağır mancınık YOK; kule tepesinde küçük top ve el topu — olası.
127. Yağlı sicim, ok, zırh yığını — kesin.
128. İmparatorluk bayrağı (Palaiologos kartalı), St Mark ve Ceneviz bayrağı — kesin [WP-Fall].
129. Yıkık sur parçası, çatlak, kuleler — kesin; Nisan'da bombardıman başlamıştı [WP-Fall].
130. Çatlak kulelere takılmış kerpiç/tahta takviye — olası.
131. Kule içindeki asker odası, ocak ve yatak — kesin.
132. Sur gölgesinde pazar yeri — BELİRSİZ.
133. Mesoteikhion'da Lykos'un sur altı geçişi (menfez) — kesin [WP-Walls].
134. Hendek önündeki Osmanlı sipereleri (palisade) — kesin [WP-Fall].
135. Sur boyu gözcü kulesi ve bayrak sinyali — olası.
136. Top gülleleri (taş, 600 libre Basilic) yığınları — kesin [WP-Fall].

### 7.8 Galata (G)
137. Tepeden iniş sokakları, taş basamaklı — kesin.
138. Tahta merdivenler ve dik rampalar — olası.
139. Ceneviz haç armalı kapı — kesin.
140. Ceneviz esnafı: kumaş, ipek, şarap — kesin.
141. Galata Kulesi'nin zirvesinde gözcü — olası.
142. Hendek (Büyük Hendek) kenarında çalı — kesin [WP-geo].
143. Kilise çanı (Latin) — kesin.
144. Haliç ağzında zincir ucundaki kule (Kastellion) — kesin [WP-Galata].
145. Kayıklarla Perama'ya geçiş — kesin.

### 7.9 Deniz (D)
146. Zincir gerilmiş, gemiler arkada — kesin.
147. Gemilerde bayrak ve flama; Venedik bayrağı — kesin.
148. Baltaoğlu'nun kadırgaları (bayraklı) — kesin [WP-Fall].
149. Kayık ve filika yan yana; mızraklı mancınık — olası.
150. Boğaz akıntısında sürüklenen enkaz — olası.
151. Ateşli gemi (yakma gemisi) denemesi — kesin [WP-Fall: 28 Nisan].

### 7.10 Osmanlı ordugâhı (O)
152. Kırmızı–altın otağ, çevresinde çadırlar [WP-Fall].
153. Yeniçeri çadır sıraları, odalar, kazanlar — kesin.
154. Topçu ocakları, dökümhane (Urban) — kesin.
155. Ordu pazarı: yiyecek, zahire, savaş esiri pazarı — olası.
156. Baltacı, lağımcı, yol açanlar — kesin.
157. Keşif atlıları (akıncı) ve bayraktarlar — olası [Bilgi].
158. Mehter takımı: davul, zurna, nefir — kesin.
159. Ordu imamları, topluca dua; ezan yalnız ordugâhta okunur, şehirde YOK — kesin.
160. Kurşun, barut fıçıları, taş gülle yığınları — kesin.
161. Hendeğe ağaç/dolgu atan askerler — kesin.
162. Koyun/deve/öküz sürüleri, ağıllar — kesin.
163. At nalı ve arabalar — kesin.
164. Hastaneler ve cerrahlar — olası.

### 7.11 Peter metnindeki ayrıntıların 1453 karşılığı (docs/_ajan/istanbul_prompt.txt)
| Peter metni | 1453 karşılığı |
|---|---|
| minare balkonları, çok minareli Sultanahmet | **YOK** — yerinde Büyük Saray harabesi |
| Mavi Cami (Sultanahmet) | **YOK** (17. yy) |
| Galata Köprüsü, çift katlı, restoranlar | **YOK** — yerinde zincir; Haliç'te kayık/gemi; Nisan sonunda fıçı köprüsü başka yerde |
| Tramvay, taksi, araba | **YOK** |
| Vapur (beyaz–kırmızı) | **YOK** — kadırga, nave, kayık |
| Simit satıcısı, kırmızı simit arabası | **YOK** (simit Osmanlı dönemi, tarihi BELİRSİZ); yerinde ekmek/halka (kolouri) tezgâhı BELİRSİZ |
| Çay semaveri/tepsi | **YOK** |
| Balıkçı olta | var |
| Martı | var |
| Kedi | var (Bizans'ta kedi) |
| Güvercin | var |
| Kümes/çamaşır ipi/ev çatısı | var |
| Uydu çanağı/anten/klima | **YOK** |
| Baca | BELİRSİZ (küçük tuğla baca olası) |
| Taş sokak, kaldırım | var (Mese ve ana yollar); iç sokak toprak |
| Selvi, çınar | var |
| Düğün fotoğrafı | **YOK** |
| Galata Kulesi, mavi–gri külah | Kule var (Christea Turris) ama külahsız |
| Boğaz köprüsü (Asma) | **YOK** — yerinde Rumeli ve Anadolu Hisarı |
| Asya yakası yalıları/camileri | **YOK** — Üsküdar küçük, Kız Kulesi bugünkü biçimde değil |
| Baharat Çarşısı | **YOK** (17. yy) |
| Han ve Kapalıçarşı | **YOK** (Fatih sonrası) |
| Topkapı Sarayı | **YOK** (1460'lar) |
| Ferry yolcuları ekmek atar | olası (balık ve kuşlar), ferry YOK |
| Işık: altın saat | Nisan'da geçerli |
| Camii/minare ışığı | **YOK** |
Madde sayısı: 7.1–7.10'da 164 numaralı madde, ayrıca bu tablo (25 satır).

## 8. Kuşatma, Nisan 1453 günlüğü
Tarih notu: kaynaklar arası ±1–3 gün fark; aşağıda [WP-Fall] ve [Barbaro-WP], bu oturumda doğrulanmayanlar [Bilgi]. Paskalya Pazarı 1 Nisan (Julyen) → "Paskalya sonrası Pazartesi" 2 Nisan [WP-Fall].
- **Öncesi.** Mart sonu/Nisan başı: zincir Haliç ağzına gerildi (Eugenios Kulesi–Galata Kastellion) [WP-Walls]; Rumeli Hisarı 15 Nisan 1452'de başladı, 1452 yazında bitti [WP-Rumeli/WP-Fall]; Anadolu Hisarı 1393–94 (Bayezid I) [WP-Rumeli]. Boğaz'ın en dar yeri ~660 m [WP-Rumeli]. Urban topu Edirne'de döküldü; ~60 öküz ve 400 adamla sürüldü [WP-Fall].
- **2 Nisan.** Osmanlı ordusunun öncüsü şehir önünde ordugâh kurdu [WP-Fall].
- **5 Nisan.** Mehmed II son birliklerle geldi; savunmacılar mevzilendi [WP-Fall]. **6 Nisan:** kuşatma başladı; topçu ateşi başlar [WP-Fall].
- **İlk günler.** Terapia kalesi ve Stoudios yakınındaki küçük kale alındı; Prens Adaları büyük olasılıkla Baltaoğlu donanmasınca [WP-Fall].
- **12 Nisan.** Osmanlı donanması Çifte Sütunlar'da (Diplokionion, bugünkü Beşiktaş) toplandı [Bilgi/Barbaro-WP]. WP-Fall bu günü açıkça vermez: BELİRSİZ ±3 gün.
- **Mevzi ve ordugâh [WP-Fall].** Sultan'ın kırmızı–altın çadırı Mesoteikhion yakınında (topçu ve seçkin yeniçerilerle); Karaca Paşa Rumeli düzenlilerini sur boyunca; İshak Paşa Anadolu düzenlilerini Lykos'un güneyinden Marmara'ya; başıbozuklar cephe gerisinde; Zağanos Paşa Haliç'in kuzeyinde (Pera yamaçları). Geleneksel otağ yeri Maltepe tepesi (Topkapı'nın dışında) [Bilgi].
- **Toplar.** ~70 parça [WP-Fall] (12–62 aralığı da anılır). Urban topu: ~27 ft (≈8,2 m), ~600 libre (≈272 kg) taş gülle, 1 milden fazla menzil; yükleme ~3 saat [WP-Fall]. Başlıca yer: Aziz Romanos kapısı karşısı (Şahi) [Bilgi]; diğer bataryalar Charisios, Pempton, Rhegion, Pege hizası ve Blakhernai karşısı [Bilgi; CSV'de kestirim, "batarya" satırları]. Bataryaların önünde ahşap palisade/siper [Bilgi].
- **18 Nisan.** İlk büyük hücum gecesi Mesoteikhion'da; hendek doldurulmaya çalışıldı, savunmacılar püskürttü [Bilgi; WP-Fall özetinde yok: BELİRSİZ].
- **20 Nisan.** Üç Ceneviz + bir Bizans gemisi ağır çarpışmayla Haliç'e girdi [WP-Fall]. Baltaoğlu muhtemelen gözünden yaralandı [WP-Fall].
- **22 Nisan.** Yağlanmış kütükler üzerinde gemiler Galata'nın gerisinden karadan Haliç'e indirildi; sayı kaynağa göre 30–80, ~70 yaygın [WP-Fall]. Rota: Boğaz kıyısı (Dolmabahçe/Beşiktaş) → tepe geçişi (Taksim yönü) → Kasımpaşa vadisi → Haliç; ~3 mil [Barbaro-WP]. Rota ve iniş noktası BELİRSİZ: Ducas, Diplokionion'un doğusu; Barbaro Pera limanı der [Barbaro-WP].
- **Köprü (fıçı köprüsü).** Fıçı ve kalaslarla Haliç'te kuruldu; Nisan sonu–Mayıs başı, yeri kaynaklarda net değil (Cibali–Kasımpaşa varsayımı: BELİRSİZ) [WP-Fall: yok].
- **28 Nisan.** Yakma gemisi girişimi başarısız; kaçan 40 İtalyan kazığa vuruldu; karşılık olarak 260 Osmanlı esiri öldürüldü [WP-Fall].
- **Donanma/ordu sayısı [WP-Fall].** Osmanlı 110–430 gemi (modern ~110: 70 büyük kadırga, 5 orta, 10 küçük, 25 büyük kayık, 75 at nakliyesi); savunma 26 gemi (5 Ceneviz, 5 Venedik, 3 Girit, 1 Ancona, 1 Aragon, 1 Fransız, ~10 Bizans); Osmanlı 50–80 bin (5–10 bin yeniçeri).
- **Çifte Sütunlar (Diplokionion).** Donanma üssü, Boğaz kıyısı; [WP-Fall] anmaz; Beşiktaş [Bilgi].
- **Rumeli Hisarı.** ~250 m kuzey–güney perde; üç ana kule: Sarıca Paşa (kuzey, silindir, 28 m, çap 23,3 m, duvar 7 m, 9 kat), Halil Paşa (orta, on iki köşe, 22 m, çap 23,3 m, duvar 6,5 m), Zağanos Paşa (güney, silindir, 21 m, çap 26,7 m, duvar 5,7 m, 8 kat) [WP-Rumeli]. **Anadolu Hisarı:** karşı kıyıda 1393–94 [WP-Rumeli].

## 9. OLMAYANLAR (anakronizm listesi)
**Yapılar:** minare ve ezan · Osmanlı camileri (Sultanahmet, Süleymaniye, Fatih, Beyazıt, Şehzade, Yeni Cami…) · Topkapı Sarayı ve Eski Saray · Kapalıçarşı ve Baharat Çarşısı · hanlar (Valide, Kürkçü) · Galata Köprüsü ve Atatürk Köprüsü · Yedikule Hisarı (1458) · Kız Kulesi'nin bugünkü biçimi (1725/1763) · Galata Kulesi'nin külahı ve üst kısmı · Dolmabahçe/Çırağan/Beylerbeyi saraylarının tümü · Eyüp Sultan türbesi (fetihten sonra "bulundu") · Süleymaniye/Fatih külliyeleri · Sebiller, Osmanlı çeşmeleri, saat kuleleri · Fındıklı, Cihangir, Nişantaşı gibi mahalleler.
**Ulaşım:** vapur, feribot, tramvay, otomobil, bisiklet, taksi, köprü trafiği · tren hattı, istasyon, Kennedy Caddesi.
**Bitkiler:** lale (süs bitkisi olarak) · domates, mısır, patates, biber, fasulye, kabak türleri, tütün, kakao, ayçiçeği (hepsi Yeni Dünya) · ananas · çay, kahve (kahve 16. yy) · söğüt/okaliptüs dikimleri.
**Hayvan:** hindi (Yeni Dünya).
**Eşya:** simit (BELİRSİZ) · çay bardağı/semaver · sigara · kâğıt para · cam şişe (var ama şeffaf kaliteli, ucuz değil) · plastik · tel örgü · beton · asfalt · elektrik · gaz lambası · saat (mekanik kule saati: Venedik'te var, Konstantinopolis'te BELİRSİZ) · gözlük (var, nadir) · baskı kitap (Gutenberg 1450'ler; Konstantinopolis'te YOK).
**Halk:** turist, rehber, fotoğraf · kamera · telefon · polis.
**Dil/yazı:** Latin harfli Türkçe tabela · Osmanlı yazılı sokak tabelası · numaralı kapı.
**Peter metnindeki martı–simit–çay kültürü:** martı var, simit/çay yok.
**Kurşun/barut:** ateşli silahlar Osmanlı ve savunmada var (top, el topu, tüfek) [WP-Fall]; ama tüfekli piyade ağırlıkta değil.

## 10. Oyunun bilerek tarihe uymadığı yerler
Komedi; düzeltme önerilmez. `scripts/world/world1453.gd` başlığından:
- **Ölçek.** Harita gerçeğin ≈ 1/4,5'i [world1453.gd]; kara surları x −580…+700 (≈1 280 m oyun = ~5,8 km gerçek) bu ölçekle tutarlı. Gerçek boyutlar bu belgede, oyun boyutu 1/4,5.
- **Haliç genişliği.** Oyunda ~220 m (≈ 1 000 m gerçek ölçekte), gerçek Haliç 200–800 m ve kıyıları farklı; kuzey kıyı Galata/Kasımpaşa/Pınarlar Vadisi [world1453.gd].
- **Haliç iç kolu / Eyüp.** Eyüp güney kıyıda, surların dışında ve iç kol surların dışında +z'ye uzanır — gerçekle kabaca uyumlu; Osmanlı köprüsü z≈−90'da (Haliç 62 m) — gerçek fıçı köprüsünün yeri BELİRSİZ.
- **Galata Kulesi'nin feneri.** Oyunda fener/ışık (GalataView top_y); gerçek 1453 kulesi fenersiz (kule 1348, işlevi BELİRSİZ).
- **Ayasofya uzak görünüşü.** Pişirilmiş tek ağ (far_aya), kurşun kubbe y 19,5 / yarıçap 11,1; gerçekte kubbe daha yassı ve daha büyük; minare yok (oyun da yok).
- **Tepeler/yükseklik.** Oyunda "yedi tepe" yerine birkaç rampa; gerçek yükseklikler Bölüm 2'de.
- **Diyaloglar.** Tolga 2026 sigortacı jargonu, Hikmet Amca "Zamanatör", Nihat/Saniye 1977 memuru, bilerek çağ dışı (CLAUDE.md §1) — tarihe uymayan kasıtlı komedi.
- **Tek harita.** Bütün bölümler aynı coğrafyada oynanır (`world1453.gd`); gerçek şehirde Mesoteikhion–Blakhernai–Haliç arası gerçek hâliyle çok uzak; oyunda sıkıştırılmış.
- **Fıçı köprüsü ve tarihler.** Kuşatma olayları (20/22/28 Nisan) oyunda sıkıştırılmış olabilir; kesin çakışma kontrol edilmedi.

## 11. Konum düzeltme günlüğü (ISTANBUL_YERLER.csv)
- **Haliç kapıları.** Önceki iskelette Fener–Petrion–Ayakapı–Cibali–Unkapanı kapıları Haliç'in içinde/yamacında kümeleniyordu (örn. Ayakapı 41,0225/28,9545 → [WP-geo] Ayakapı 41,0267/28,9565; Cibali–Perama sırası ters). Kapılar WP sırasına göre kıyı poligonuna yeniden yerleştirildi (±150 m).
- **Marmara kapıları.** Yenikapı (40,988/28,957), Davutpaşa, Psamatya, Narlıkapı denizde kalıyordu; eski kıyıya çekildi (Samatya [WP-geo] 41,0019/28,9330; Eleutherios Limanı [WP-geo] 41,0047/28,9522).
- **Eğrikapı** lon 28,945 (Balat'ta) → 28,9384 (Blakhernai); **Kerkoporta** aynı şekilde.
- **Mesoteikhion/Lykos/otağ.** Topkapı–Mevlanakapı arasına, otağ Maltepe'ye çekildi.
- **Lips** 41,0165/28,949 → [WP-geo] Fenari İsa 41,0154/28,9440.
- **Galata Kulesi** [OSM] 41,0256/28,9742; **Kastellion** Yeraltı Camii yeri.
- **Eski satırlardaki hata kaynağı:** "kestirim" etiketi taşıyan yaklaşık değerler Vikipedi/OSM karşılaştırmasıyla yer yer 400–900 m kaymıştı.
