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

---

# TUR 2 kareleri (09:26 UTC, `docs/_kanit_ist2_dunya2/sahip_*.jpg`) — yöneticinin notları (3. tura girecek)

İyi: yarımadanın biçimi ve derli topluluğu; Galata'dan bakışta filo, zincir, ufukta Ayasofya; Mese'de taş döşeme ve
yürüyen insanlar; sur dibi mahallesi (taş-tuğla şeritli sur, döşeli meydan, dükkânlar); karşı kıyılar dolu; gece.

Düzeltilecekler:
11. **Uzak sur katmanı kaba kutular:** Galata'dan ve sur dışından bakışta deniz/kara surlarının uzak hâli ten rengi,
    beyaz ve siyah düz bloklar (dokusuz, mazgalsız; gece siyah-beyaz). Uzak katman da şeritli taş rengi, mazgallı
    silüet, kule ritmi olmalı.
12. **Yakındaki kutu insanlar:** uzak yaşam katmanının küp figürleri yakından görünüyor (Mese'de ön planda, sur dışında
    çadırın önünde): ≤ 60–90 m'de oyunun gerçek kişi modeli (`Person`; `wip/ist-hayat-yakin`), küp figür yalnız uzakta.
13. **Ayasofya meydanı ve çevresi hâlâ çayır:** Ayasofya'nın dört yanı, Augustaion, Mese'nin iki yanı ve evlerin arası
    yeşil; taş döşeli meydan, avlu duvarları, patrikhane ekleri, tezgâhlar, ağaçlı avlular olmalı. Evler Ayasofya
    çevresinde aralıklı ve tek tek; bitişik adalar yok.
14. **Romanos'un iç yanı boş çayır** (hub oyun alanı 90 × 90 m boş bırakılmış): oraya Tolga'nın mektup bölümünün
    şehri (hub: `ByzCity.far_hub` / aynı kurucular) yerleşmeli; boş alan kalmasın.
15. **Sur dışı hâlâ seyrek:** tek büyük beyaz çadır (kutu gibi, dokusuz) ve birkaç küçük çadır; "çadır denizi", toplar,
    tabyalar, hendek, sancaklar yok ya da görünmüyor; kara suru önünde hendek ve dış sur okunmuyor. Sur dışındaki
    zemin düz yeşil.
16. **Tam tepeden siyah dikdörtgenler** sürüyor (≥ 8 adet: uzak katmanda kararan çatı/parça). Kaynağı bulunup
    giderilmeli (şehir/parça tarafı).
17. **Döşeme çok beyaz ve iri:** Mese ve meydan döşemesi nane-beyaz, 1 m'lik dev karolar; Prokonnesos mermeri/kireçtaşı
    tonu (sıcak gri-krem), düzensiz derzler, yer yer kırık/otlu olmalı.
18. **Ev renkleri hâlâ tek tip** (parlak turuncu çatı + açık duvar): görünüş kılavuzundaki palet (soluk kırmızı-kahve
    Bizans kiremidi, taş-tuğla şerit, kireç badana tonları) uygulanmalı; çatılar daha az doygun.
19. **ISTBOS şehir içi %5,5** (hedef %0).

---

# TUR 3 ilk eser kareleri (11:18 UTC, `docs/_kanit_ist2_sehir3/ilk/eser_*`) — yöneticinin notları (4. tura girecek)

İyi: şehir artık ufka kadar dolu ve okunaklı (ada/sokak); Haliç'te filo; Konstantin ve Tauri forumları döşeli, insanlı;
Blakherna Sarayı + arkasında surlar + sur dışında çadır denizi; Galata Kulesi ve suru; Hipodrom'un bütünü.

Düzeltilecekler:
20. **Ayasofya'nın dört yanı HÂLÂ çıplak çayır** (15 m, tepe ve yer karelerinin üçünde de): döşeli meydan yok, avlu
    duvarı yok, insan yok, tezgâh yok; yerden bakınca boş arazide tek bina. Not 13 kapanmadı: en öncelikli iş.
    Ayasofya'nın kendisi iyi ama kütle dili yalın: payandalar, atrium, vaftizhane, batı avlusu, güney ek yapıları yok.
21. **Eserlerin rengi oyuncak gibi doygun:** Studios ve Ayasofya'nın yanındaki kilise (Aya İrini?) parlak turuncu-kırmızı
    tuğla + düz KIRMIZI çatı levhası (kiremit/kurşun değil); Galata Kulesi'nin külahı parlak kırmızı; Konstantin Sütunu
    macenta. Eserler evlerle aynı palete insin: Bizans tuğlası soluk kırmızı-kahve + geniş harç derzi + taş şerit;
    çatılar kurşun gri ya da soluk kiremit; porfir koyu erguvan-kahve (macenta değil).
22. **Ayasofya'nın yanındaki kilise düz kutu:** kırmızı düz dam üstüne oturmuş iki kubbe; cephe ayrıntısı yok.
23. **Büyük Saray/Hipodrom güneyindeki "harabe"ler ham basamak blokları** (turuncu tuğla merdiven yığınları): harabe gibi
    okunmuyor; yıkık tonoz, sarmaşık, moloz, yarım kemer.
24. **Uzak deniz surları hâlâ beyaz blok yığını** (Ayasofya ve Konstantin karelerinin ufkunda Haliç boyunca).
25. **Ordugâh:** çadır denizi var ama eş boy, eş renk, ızgara dizili küçük kulübeler; otağ, sancaklar, toplar, at
    sıraları, yollar, ateşler, obalara göre renk/boy farkı yok; kümeler ve boşluk-yollar olmalı.
26. **Kırık kareler:** `eser_hipodrom_yer` (kamera bir sütunun içinde, gece/karanlık), `eser_halic_eugenios_yer` (5 KB,
    boş): yer kareleri eserin önünde 12–20 m geride, göz hizasında, gündüz alınmalı; kanıt karesine bakılmadan gönderilmiş.
27. **Sur dokusu ahşap kaplama gibi** (Blakherna ve Galata surlarında bej yatay şeritler tahta gibi okunuyor): taş sıra +
    tuğla hatıl (5 sıra tuğla / 1–1,5 m taş) oranı ve renkleri kara surlarındaki gibi olmalı.
28. **Döşeme tonu** Tauri'de hâlâ nane-beyaz ve gölgede camgöbeği; Konstantin'de iyi: aynı sıcak gri-krem her yerde.
29. **Yeşil küreler** forum döşemesinin üstünde düzenli aralıkla (ot öbeği mi?): yapay duruyor; seyrek ve derz aralarında.

## Sahibin 12:15 sözleri (sur dışı karesi `s3_kara_disi.jpg` üstüne)
30. **"Surların arası boş, tam değil bazı yerlerde."** Kara surları kesik dilimler hâlinde: dilimler arasında boşluk,
    bazı dilimler düz beyaz (şeritsiz, mazgalsız), önlerinde beyaz düz taban levhaları; iç sur / dış sur / peribolos /
    hendek üçlüsü okunmuyor. Ölçüt: hat boyunca 5 m adımla örnekleme: boşluk sayısı 0 (kapılar dışında), yakın ve uzak
    katmanın ikisinde de; uzak katman yakınla aynı renk ve şeritte; deniz surları ve Galata suru da aynı ölçütle.
31. **"Çadırlar böyle mi normalde, ona da çalıştın mı, askerler nerde, eksik bir şeyler var mı?"** Ordugâh tek tip, eş
    boy, ızgara dizili çadırlar; asker, at, top, tabya, sancak, yol, ateş görünmüyor. Ordugâh ayrı bir araştırmaya
    dayanmalı (`docs/ORDUGAH_1453.md`, dal `wip/ordugah-arastirma`) ve yaşam dolu olmalı: talim eden, nöbet tutan,
    yemek pişiren, top başındaki askerler; at sıraları, develer, erzak arabaları; bataryalar ve Şahi; hendek-set;
    tuğlar ve sancaklar; obalar arası yollar; gece ateşleri. Yakında gerçek kişi modeli (`Person`), uzakta ucuz katman.

## Sahibinin 16:40 sözü (ordugâh yer karesindeki öküzlere bakarak): KUTU YASAĞI
32. **"Öküzleri kare kare mi yapmışsın????? Şu kare kare sevdandan vazgeç."** Bağlayıcı, bütün oturumlar ve bütün oyun için:
    - Canlılar (insan, öküz, manda, at, deve, koyun, keçi, köpek, kedi, kuş, balık) ASLA kutu parçalarından kurulmaz.
      Gövde, boyun, baş, bacak, kuyruk yuvarlak kesitli ve birbirine akan biçimlerdir (kesit halkalarından örülmüş ağ,
      kapsül/küre/koni birleşimi; kenarlar yumuşak normalli). Uzak katmanda bile siluet hayvan gibi okunur (dört bacak,
      boyun, baş); "ayaklı sandık" olmaz.
    - Yuvarlak olması gereken nesneler de kutu olmaz: ağaç tacı, çalı, çuval, fıçı, testi, küp, kazan, gülle, top namlusu,
      tekerlek, sütun, kubbe, çadır, saman balyası dışındaki yığınlar, kaya, toprak yığını, insan elinden çıkmamış her şey.
    - Kutu yalnız gerçekten köşeli şeylerde kalır (kesme taş, kiriş, kalas, sandık, tuğla) ve onlarda da çıplak tek kutu
      değil: pah, derz, aşınma, eğrilik, parça çeşitliliği.
    - Rapor ölçütü: kendi karelerinde "kutu gibi duran" her şeyi say ve listele (`KUTU kalan=…`); hedef 0. Canlılar için
      yakın kare (5 m) ve uzak kare (60 m) zorunlu.
