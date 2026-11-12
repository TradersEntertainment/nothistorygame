# İstanbul v2 — yöneticinin kalite notları (tur 5 karelerinden; 2. dalga görevlerine girecek)

Kaynak kareler: `docs/_kanit_ist2_sehir/tur_5_*.jpg`, `yer_5_*.jpg` (dal `wip/ist2-sehir`).

0. **BOŞ ALAN YOK (sahibin sözü, 12 Kasım: "güzel de boş alan istemiyorum bir de").** Haritanın hiçbir yerinde çıplak düz
   çayır kalmayacak; uçuşta 70 m'den ve yerden bakınca her 40 × 40 m'lik karede en az bir "şey" seçilecek. 1453'te
   surların içi tarihî olarak seyrekti, ama seyrek = boş değil: çiçekte meyve bahçeleri (erguvan, badem, erik), bağlar,
   bostan tarhları ve su dolapları, yeşil buğday tarlaları ve aralarında patikalar, kuru taş bahçe duvarları, çitler,
   harabeler (yıkık tonoz, sütun sırası, sarmaşıklı duvar), manastırlar ve avlu duvarları, şapeller, mezarlıklar ve
   serviler, açık sarnıçların içinde bostanlar, kuyular, ağıllar ve sürüler, tek tek çiftlik evleri, dere ve köprüler,
   kayalıklar, ağaç kümeleri. Sur dışı: ordugâh (çadır denizi), hendek ve tabyalar, ikmal yolları, yakılmış köyler,
   bağlar, mezarlıklar. Karşı kıyılar ve ufuk da boş değil: Galata'nın arkası bağ ve bahçe, Üsküdar/Khrysopolis ve
   Kadıköy/Khalkedon köyleri, Eyüp/Kosmidion, Boğaz köyleri, ormanlık tepeler, tarlalar. Deniz: gemiler, kayıklar,
   balıkçı ağları, martılar. Zemin dokusu da tek renk yeşil olmayacak (toprak yol, taşlık, çiçekli çayır, sürülmüş
   tarla). Ölçüt: `IstGeo` ızgarasında 40 m'lik karelerin "boş" (içinde hiçbir öğe olmayan) oranı şehir içinde %0, sur
   dışı 600 m kuşakta ≤ %5, karşı kıyıların görünen yamaçlarında ≤ %15; sayım denetime eklenecek (`ISTBOS`).

0b. **ŞEHİR SURA KADAR DOLU (sahibin sözü, 12 Kasım: "içinin scale büyütüp sura yaslayabiliriz").** Yerleşik doku
   yalnız Ayasofya–Mese–Haliç üçgeninde kalmayacak: şehrin içi büyütülüp surlara YASLANACAK. `IstGeo.mahalle`
   yoğunlukları yeniden dağıtılır: sık çekirdek (çarşı, liman, Mese boyu) genişler; yarımadanın kalanı kara surlarının
   ve deniz surlarının iç yüzüne kadar mahalle dokusuyla dolar (orta yoğunluk: sıra evler + avlu/bahçe + mahalle
   kilisesi + meydan/kuyu); sur dibinde evler surun iç yüzüne yaslı sıralar hâlinde (arada savunma yolu 4–6 m).
   Bostan, bağ, meyve bahçesi, manastır ve harabeler bu dokunun İÇİNDE adalar olarak kalır (büyük boş kuşak olarak
   değil; en büyük kesintisiz evsiz alan ~120 × 120 m, açık sarnıç bostanları ve Hipodrom/Büyük Saray harabesi dışında).
   Hedef ev sayısı ~9–12 bin (akışla; bütçe aynı). Galata da surlarına kadar dolu.

0c. **SOKAKLAR YAŞAM DOLU (sahibin sözü, 12 Kasım: "yaşam dolu olacak sokaklar").** Yerden yürürken her sokakta, her
   meydanda, her iskelede insan ve hareket: yürüyen, taşıyan, pazarlık eden, tezgâh başında duran, kapı önünde oturan,
   çocuklar, keşişler, askerler, hamallar, balıkçılar; eşek/at/kedi/köpek/tavuk; tezgâhlar dolu, bacalar tütüyor,
   çamaşır ve sancak dalgalanıyor, martılar. Havadan bakınca sokaklarda ve meydanlarda kıpırdayan kalabalık seçiliyor.
   Parçalar: `wip/ist-hayat` (uzak/hava katmanı), `wip/ist-hayat-yakin` (oyuncunun çevresinde gerçek kişiler: oyunun
   `CityLife` sivil akışı ve "herkesle konuşma" düzeni v2 sokaklarına bağlanır). Ölçüt: yerde her bakışta en az 8–12
   kişi (çarşıda 25+), boş sokak karesi yok; uçuşta 70 m'den her mahallede hareket seçilir.

1. **Surlar cılız.** Kara surları dışarıdan alçak kahverengi bir çit gibi (k = 0,5 ile iç sur ~6 m; evlerden alçak).
   Oyunun var olan surları gerçek yükseklikte (`Blachernae.WALL_H` ~11–12 m). Karar: bütün surların KESİTİ gerçek boyda
   (k = 1,0: iç sur ~12 m, kuleler ~18–20 m, dış sur ~8,5 m, hendek ~18 m), yalnız UZUNLUK hat boyunca yarı ölçek
   (kule sayısı azalır, aralık gerçek kalır). Sur dışından bakınca üçlü hat ve kuleler ufku kesmeli.
2. **Evler serpiştirilmiş oyuncak gibi.** Havadan (70 m) ev sırası/sokak/ada okunmuyor: aynı pembe-krem duvar ve aynı
   turuncu çatı her yerde, sokak zemini yok (çayırın üstünde evler). İstenen: (a) sokak ZEMİNİ görünür (Mese ve
   forumlar taş döşeme; ara sokaklar sıkışmış toprak/kaldırım; basamaklı yokuşlar), (b) adalar: bitişik sıra + avlu
   duvarı + bahçe/ağaç, (c) çeşitlilik mahalleye göre: taş-tuğla şeritli, kireç badanalı, ahşap çıkmalı, harap; çatı
   kiremidi tonları, yer yer düz dam/teras, sundurma, (d) evlerin çoğu 1–2 katlı (4–6,5 m; 1453'ün yoksul şehri), üç
   katlılar yalnız çarşıda ve Latin mahallelerinde, (e) uzak katmanda evler beyaza dönüyor: uzak/orta/yakın renkleri aynı.
3. **Anıtlar ufukta kaybolmuş.** Galata'dan bakışta Ayasofya ve kubbeler seçilmiyor. Evler alçalınca (2d) düzelir;
   ayrıca kurşun kubbelerin rengi/parlaması, sütunlar ve kemer silüette okunmalı; hafif pus uzak şehri yumuşatsın ama
   silmesin.
4. **Tam tepeden kusurlar:** (a) batıda dikdörtgen MAVİ göl: açık sarnıç (Mokios/Aetios/Aspar) ya da dolmuş liman su
   olarak çizilmiş: 1453'te bostan çukuru, su değil; (b) siyah kareler/dikdörtgenler (uzak katmanda kararan ya da
   malzemesiz yapılar); (c) kıyı çizgisi merdiven gibi basamaklı (arazi ızgarası kaba): kıyı yumuşak eğri olmalı;
   (d) Mese'nin bir kolu düz beyaz çizgi (döşeme mi, kusur mu?).
5. **Sur dışı boş.** Nisan 1453'te sur dışında Osmanlı ordugâhı, bataryalar, hendekler var (parça: `wip/ist-ordugah`).
   Su boş: zincirin arkasında filo, iskelelerde gemiler, Osmanlı donanması (parça: `wip/ist-gemiler`). Sokaklar boş:
   yaşam katmanı (parça: `wip/ist-hayat`).
6. **Zemin:** Mese'de döşeme yok (çayır); Ayasofya meydanı düz çayır: Augustaion döşemesi, meydan taşları, yol izleri.
7. **Ayasofya'nın çevresi boş:** patrikhane ek yapıları, Augustaion, Milion, Aya İrini ile arası; batı avlusu (atrium).
8. **Zaman dilimi:** tek iş 6 ms'yi aşıyor (kuzeybati_semt 148 ms, forumlar 78–104 ms…): yaklaşırken takılma. Ağır
   parçaların lod 0/1 kurulumu bölünmeli (alt parçalara) ya da açılışta ön-pişirilmeli.
9. **Denetim eksikleri:** zeminde delik/kapalı cep ışın ızgarası v2'de koşulmadı; sur üstünde gerçek oyuncuyla yürüyüş;
   çatıdan çatıya geçiş oyuncuyla; kapıların üstünde sur yürüme yolu kesik (kara surunda %9 boşluk).
10. **Halic parçasının konumları yanlıştı** (hepsi Sarayburnu'nda kümelenmiş; şehir oturumu düzeltti): parça kaydı da
    düzeltilmeli. Kiliseler parçasının adlı kiliseleri konumsuz: mahalle kilisesi olarak kullanılıyor (uygun).
