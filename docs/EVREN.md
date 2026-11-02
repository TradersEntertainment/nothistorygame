# Evren Kanonu · Gerçek Tarih Bu Değil

> Yazarlar ve geliştiriciler için kanon kaynağı (PLANLAR.md, "Aynı evrende ikinci oyun"). Her iddianın yanında kaynak dosya yazılı.
> Kaynakta olmayan şey "kaynakta yok" diye işaretlidir; burada tahmin yoktur. Bölüm numaraları CHAPTERS.md'dekidir; ekran ve dosya numaraları farklıdır (bkz. 6.3-2).
> **Öncelik:** Tasarım belgeleri çeliştiğinde oyunun kendisi (kod ve i18n/strings.csv) esastır. GDD.md, STORY_BRANCHES.md ve CHAPTERS.md'nin eski sayıları (10, 13, 15 final) tasarımın önceki aşamalarıdır.
> Güncelleme: 2026-11-02 (6.3'te 1, 3–7 oyundaki hâliyle çözüldü). Kaynak sürümleri: CHAPTERS.md v1.1, FINALS.md v0.40, OTTOMAN_STORY.md v0.1, BYZANTINE_MIRROR.md v0.1, STORY_BRANCHES.md v0.2, GDD.md v1.1.

## 1. Evrenin özü

1453 İstanbul'unda koli bantlı bir zaman makinesi çalışıyor. Yanlış kişi bindi: 34 yaşında sigortacı Tolga, "Osmanlı Gecesi" partisinden kalma kırmızı fes ve siyah redingotla (19. yüzyıl modası) kuşatmanın ortasına düşer (GDD.md §5.1, §6.1). Oyunun teması, bildiğini sanmak ile bilmek arasındaki farktır (CHAPTERS.md §3.1). Tarih inatçıdır: fetih engellenemez, yalnız ertelenebilir (README.md, Bölüm 12 "Son Akşam"; OTTOMAN_STORY.md §4.1).

**Ton kuralları**
- Gülünür: Tolga'nın plaza dili ve yanlış dönem kostümü; iki imparatorlukta da bürokrasi; bilinçli anakronizmler (fes 1829'da gelir, domates-patates-biber Amerika'dan, leblebi "ilk kez görülür") (GDD.md §3-4, §15; STORY_BRANCHES.md Son 8).
- Gülünmez: Fatih ve Konstantinos ciddi karakterlerdir; espri onlarla değil, Tolga ve durumla ilgilidir (GDD.md §4 kural 1).
- Din, etnik köken ve kutsal değerler espri malzemesi değildir; iki taraf da kötü adam değildir (GDD.md §4 kural 2).
- Kırmızı çizgi: Giustiniani'nin yaralanması ve şehrin düşüşü şaka konusu değildir; ciddi tonla geçer (GDD.md §4 kural 8).
- Ciddiyet bütçesi: sahne başına en fazla bir samimi an, en az 3 saniye (GDD.md §4 kural 6).
- Şehrin düşüşü ölçülü gösterilir: yağma ekranda yoktur, ölüm ve esaret Nihat'ın tek cümlesiyle söylenir (BYZANTINE_MIRROR.md giriş).
- Kerkoporta rivayeti kullanılmaz (GDD.md §15; BYZANTINE_MIRROR.md giriş).
- Dil: dönem karakterleri sade Türkçe konuşur, ağır Osmanlıca yoktur. Bizanslılar Yunanca konuşur; altyazıda italik ve [Yunanca] etiketiyle gösterilir (GDD.md §4, §11).

## 2. Zaman yolculuğunun kuralları

- **Makine:** Hikmet'in "Zamanatör 3000"i. Yıl tuşlarla girilir; 1453 paneli "14:53" gösterir (GDD.md §9.1; README.md).
- **Telsiz-Kumanda:** Telsiz ile TV kumandası koli bandıyla birleşir, Tolga'nın kemerine bantlıdır. Kırmızı düğme "acil dönüş"tür (CHAPTERS.md §2.1).
- **İade garantisi:** 2026 saatiyle kalkıştan sonraki ilk 10 dakika. Sonra düğme cızırdar ama Hikmet'e sinyal gider: Telsiz Bağı +1, bir kez (CHAPTERS.md §2.2).
- **Dönüş penceresi:** Hikmet 2026'dan açar. Pencere açıkken kırmızı düğme yeniden çalışır. Süre 3-12 sn, Telsiz Bağı'na bağlıdır (CHAPTERS.md §2.2, §4.5, Bölüm 13).
- **Zaman oranı:** 2026'da 1 saat = 1453'te yaklaşık 1 gün. Başlangıç pazar gecesi 03:12; servis pazartesi 07:30 (CHAPTERS.md §2.4).
- **Yönetmelik 7/c:** "Anomali geldiği araçla iade edilir." Büro araçları yalnız kadrolu personel taşır; Nihat Tolga'yı getiremez. İstisna: Tolga Büro'ya katılırsa (T4) Büro aracıyla döner (CHAPTERS.md §2.3).
- **Zaman Bürosu** zaman dışında durur. Nihat istediği ana inebilir (CHAPTERS.md §2.4).
- **Hasar Tespit (Perde IV) zamanın dışında geçer:** Nihat Tolga'yı 26 Nisan öğlesinde (Son Akşam yolunda gün batımında) alır, Geçici Tanık Sözleşmesi'yle (Form Z-1453/GT) kuşatmanın günlerine götürür ve aldığı ana geri bırakır: "Hikmet Bey'in penceresi bir saniye bile kaymaz" (D17_N_INTRO_2, D17_N_BACK, D17_N_BACK_DUSK). Bu yüzden 1453'te Ağustos 1452 – 1 Haziran 1453 arası gezilse de 2026 saati ilerlemez; zaman oranı yalnız Perde I–III'ün 22–26 Nisan'ı için geçerlidir.
- **Geçici teminat:** Büro tanığı yerlilere adıyla ve göreviyle tanıtır; dosya süresince onu tanıyormuş gibi davranırlar, dosya kapanınca öncesini de sonrasını da unuturlar (D17_N_RULE). Tanık kendine rastlamaz (D17_N_FIRST_33).
- **Takvim yankısı:** Tolga'nın Nisan'daki varlığı tarihî olayların erken birer gölgesini doğurur: 22 Nisan'da ay tutulması (D4B_T_ECLIPSE_1), 25 Nisan'da ordugâhın şenlik ateşleri (D11_N_ILLUM). Tolga ikisini de "bu ... Mayıs'ta olacaktı" diye işaretler (anakronizm etiketi, GDD.md §4 kural 3). Asıl olaylar yine tarihî günlerinde olur: tutulma 22 Mayıs (24o, LORE_24_1), ateşler ve sükût 27–28 Mayıs (32o). Tarih inatçıdır.
- **Paradoks metresi (0-100):** 0-29 tarih sağlam; 30-59 Vikipedi'de tuhaflık; 60-89 Denetçi Nihat ilk kez belirir ve Form Z-1453'ü açar; 90+ gerçeklik kırılır ve anlık sonlar açılır (GDD.md §7.8; STORY_BRANCHES.md §7).
- **Değişmez kural:** Tolga dönerse dış hayatı değişmez ve değişen dünyayı fark etmez. Dönemezse yokluğunu kimse fark etmez. Değişiklikleri fark eden tek kişi Hikmet'tir ve kimse ona inanmaz (CHAPTERS.md §2.5; GDD.md §4).
- **İç dünya:** Huzurda dürüst davranıldıysa finalde Tolga ilk kez "Bilmiyorum. Araştırıp döneyim." der (CHAPTERS.md §2.5, §7).
- **Yanlış yıl (T3):** Frekans kaçarsa Tolga 1977'deki mahalle düğününe düşer ve Bölüm 26'da oynanır (FINALS.md başı; CHAPTERS.md §5).
- **Telsiz Bağı:** 0-5 arası, 2'den başlar (CHAPTERS.md §4.5).
- **Form ailesi:** Z-0 akış şeması ve tespit makinesi (GDD.md §9; README.md). Z-1 Büro'nun kuruluş belgesidir; imza yeri "T." (CHAPTERS.md §3.2). Z-1453 vaka formudur, üç nüsha ve ıslak imza (GDD.md §5.9). Osmanlı nüshası Z-1453/GT (OTTOMAN_STORY.md §3).
- **Büro'nun yapısı:** Denetçi Nihat, Başdenetçi Saniye Hanım (strings.csv SPK_MUFIDE), vaka adları "1453-T" ve "1977-T" (CHAPTERS.md §3.2; FINALS.md).

## 3. Ana karakterler

**Tolga** (oyuncu karakteri, 34, sigortacı)
- İster: Gelecek bilgisiyle tarihi değiştirmek. Yayı, bildiğini sanmaktan bilmeye geçmesidir (CHAPTERS.md §3.1).
- Tarz: plaza Türkçesi ("Açıkçası burada bir sinerji görüyorum"); "20 belgesel izledim" ve "gelecekten geliyorum" ile tanıtır (GDD.md §5.1).
- Oyun sonu: 1453'te kalabilir (T2), dönebilir (T1), 1977'de kalabilir (T3), Büro'ya katılabilir (T4) (CHAPTERS.md §5).

**Hikmet Amca** (emekli elektrik teknisyeni, mucit)
- İster: Tolga'yı geri getirmek. Yayı: 1977'de dans etmeye cesaret edememesi; Tolga'yı göndermesi bu korkunun bedelini başkasına ödetmesidir (CHAPTERS.md §3.3).
- Tarz: "Evlât", "Evladım"; her şeyi koli bandıyla tamir eder; telsizden yarı anlatıcı, yarı ipucu (GDD.md §5.2).
- Şaka: "Evlât, o fes 1829'da gelecek"; "Bantladım"; "O kırmızı düğmeye basma".
- Oyun sonu: H1 makine elinde, H2 makineye el konuldu, H3 pijamayla 1453'e bindi (CHAPTERS.md §5). Ana menüde "Bir kere de ben gitsem?" (CHAPTERS.md §10).

**Denetçi Nihat Zamanoğlu** (Zaman Bürosu)
- İster: Yönetmeliği uygulamak. Yayı: Kural Sadakati göstergesiyle kuraldan empatiye geçmek (CHAPTERS.md §3.2, §4.3).
- Tarz: sabırlı, kibar memur; "Yönetmelik 7/c", "Madde 14/b uyarınca". 1453'te 1920'lerden fötr şapka, yelek ve daktilo taşır (CHAPTERS.md §3.2).
- Şaka: Bizans bürokrasisine mesleki hayranlık: "Ben bu adamlardan çok şey öğrenirim" (GDD.md §5.9).
- Oyun sonu: N1 kurala sadık, N2 kuralsız (Yönetmelik Duvarı'nda formu yırtar), N3 yerine yeni model gelir, N4 istifa eder (CHAPTERS.md §5).

**Sultan Mehmed (Fatih)** (21 yaşında, merakı ve dürüstlüğü ödüllendirilir)
- İster: Kaynakta açıkça: bilgi değil, merak uyandıran şeyler ve dürüstlük (GDD.md §5.3). Kilit soru: "Bu şehir alınacak mı?" (GDD.md §9.6).
- Tarz: soğukkanlı, kısa, keskin. Rubik küpünü 40 saniyede çözer; tarih kitabındaki kendi portresine "Burnumu büyük çizmişler" der (GDD.md §8 #3, #10).
- Oyun sonu: Huzur sonlarında belirleyici. Telsiz-Kumanda'yı tamir ederse Tolga tam zamanına döner (W4) (CHAPTERS.md Bölüm 12, 12.4).

**İmparator XI. Konstantinos** (son Bizans imparatoru)
- İster: Kaynakta açık bir istek yazmıyor. Tolga'ya Fatih'e götürmesi için mektup verir; teslim teklifini reddeder, çünkü şehri teslim etmek kimsenin elinde değildir (GDD.md §5.12, §15).
- Tarz: yorgun, onurlu, ciddi. Espri, Tolga'nın saçmalıklarından ve Niko'nun tercümelerinden çıkar (GDD.md §5.12).
- Rubik küpünü nazikçe reddeder: "Şu an bulmacaya ihtiyacım yok" (GDD.md §8 #10).

**Aşçıbaşı Kadri** (ordugâh mutfağı): leblebiyi görür, yeni yemek icat etmek ister. Yol A'nın anahtarıdır. "Sultan's Table" dalında 2026'daki lokanta menüsüne adı geçer (GDD.md §5.6; STORY_BRANCHES.md Son 8).

**Tercüman Lütfi** (yedi dil bildiğini iddia eder): deyimleri birebir çevirir ("Sinerji" → "cin"). Yol B'nin anahtarıdır; Heyet dalına götürür (GDD.md §5.4; CHAPTERS.md Bölüm 9-10).

**Usta Urban** (Macar dökümcü): huysuz, büyük toplara takıntılı; hesap makinesini "cin" sanar. Top çatlar. Sonu kaynaklarda belirsizdir, ölüm rivayettir (GDD.md §5.5, §15; OTTOMAN_STORY.md §2.3).

**Niko** (Bizans askeri): surdan laf atar ve tavuk fırlatır. Kırık çarşı Türkçesi konuşur; Tolga'nın anlayabildiği tek Bizanslı. Tercümeleri hakaret içerir: "Annen bir Ceneviz kayığıydı!" (GDD.md §5.11).

**Sinerji** (tavuk): Niko'nun dördüncü fırlatmasından sonra Tolga'yı izlemeye başlar. Asla kaybolmaz; gizli Bölüm 16'da 90 saniye oynanır (GDD.md §5.15; CHAPTERS.md Bölüm 16). Sinerji 2026'ya geldiyse her finalin son karesinde garajda bir tavuk vardır (CHAPTERS.md §7).

**Hasan ile Hüseyin** (nöbetçi ikilisi): kimin Hasan olduğunu tartışırlar. Esir çadırı kaçışının anahtarıdır (GDD.md §5.7, §9.3). Hüseyin 4a'da Tolga'nın fesini takar ("Fesli Hüseyin", D4A_HU_FEZ_3).
**Hasan tek kişidir:** kızaklarda (2), ordugâh kapısında ve esir çadırında (4a), Sorucu Ağa'nın kapısında (10O) nöbet tutan yeniçeri, kuşatmada kule gecesi (22o), son ateş (32o) ve 29 Mayıs şafağında sancağı burca diken Hasan'dır (26o). 22o'da Tolga'yı tanır: "Hasan, kapıdan. Hatırladın mı?" (D22O_H_01_KNOWN, GameState.has_met("guards")). Oyun onu Ulubatlı Hasan'la eşler (D26_N_BANNER, LORE_26O_2, FATE26_CHICKPEAS_HASAN_LEB_32O): Perde I'de şakanın, Perde IV'te saygının kişisidir; 26o'daki ayrıntılar kahramanlık abartısı olmadan, kaynaklara bağlı kalır (OTTOMAN_STORY.md).

**Giovanni Giustiniani** (Cenevizli komutan): sözleşme gözüyle bakar; Tolga'nın "savaş sigortası" satışına ilgi duyar, primleri görünce vazgeçer. Uyarılırsa paradoks +30 (GDD.md §5.13; CHAPTERS.md Bölüm 6b).

**Logothetes Theodoros** (Bizans bürokrasisi): "Misafir İzni" belgesi yedi nüsha ve yedi mühür ister. Labirentin sahibidir; arşiv teklifi yapar (GDD.md §5.14; STORY_BRANCHES.md Son 9).

**Sorucu Ağa** (otağ kapısı): üç soru sorar; üçüncüsü saçmadır ("Bir devenin günde kaç okka su içtiğini bilir misin?") (GDD.md §5.8).

**Çandarlı Halil Paşa** (sadrazam): temkinli, barış yanlısı. "Savaş herkese pahalıya patlar. Barış ise sadece bana." (STORY_BRANCHES.md §2 tablosu; GDD.md §5.10).

**Diğerleri (kısa):** Zağanos Paşa, Galata ve Haliç kuvvetlerinin komutanı (GDD.md §15). Lağımcı Dragan, Novo Brdo'lu madenci (README.md Bölüm 10). Mühendis Grant, Bizanslı mühendis (README.md Bölüm 10; strings.csv). Hırdavatçı Cemil, gece açık hırdavatçı (CHAPTERS.md Bölüm 8; strings.csv). Ajan 7/c ve 12/b, Büro ajanları (CHAPTERS.md Bölüm 8; strings.csv). Kaptan Bartolomeo, Cenevizli kaptan (kurgu) ve Antonio Rizzo, Venedik gemisi (tarihî) (BYZANTINE_MIRROR.md §3).

## 4. Mekânlar ve dönem

**1453 İstanbul**
- **Haliç:** kütükler üstünde zincir, şehir tarafındaki kuleden Galata tarafına uzanır. 22 Nisan'da gemiler Galata'nın arkasındaki tepelerden kızaklarla karadan indirilir (GDD.md §15, §9.2).
- **Osmanlı ordugâhı:** esir çadırı, mutfak, topçu alanı, tercüman çadırı, pazar yeri, otağa giden yol (GDD.md §9.3). Otağ kırmızı-altındır (GDD.md §12.1), Topkapı (St. Romanus) kapısının karşısındaki tepededir (GDD.md §15).
- **Bizans şehri:** Labirent (kançılarya, 7 oda), kara surları, Konstantinos'un sarayı, deniz surları ve Niko'nun kapısı (GDD.md §9.4; README.md "byz_city.gd").
- **Surların mekânları:** Mesoteichion (gedik; Urban'ın topu), Blakherna (merdiven), Petrion (kapı ve sığınak; 38-39), Ayasofya (README.md; BYZANTINE_MIRROR.md §1; OTTOMAN_STORY.md §1).
- **Galata:** Cenevizlilerin resmen tarafsız mahallesi. Şarapçı Spinola, balıkçı ve noter burada (GDD.md §15; strings.csv).
- **Boğazkesen ve Silivri:** planlı sahneler, aynı oyun içinde (BYZANTINE_MIRROR.md §3, §5).

**2026**
- **Garaj:** soğuk floresan, gri ve turuncu koli bandı. Duvardaki boş çerçeve sonda bir portre taşır (GDD.md §12.1, §9.1).
- **Nöbetçi Hırdavat:** gece açık tek hırdavatçı, Cemil'in tezgâhı (CHAPTERS.md Bölüm 8).
- **Ofis ve servis durağı:** pazartesi sabahı; müdür ve servis şoförü. Durağın tabelası kurulan dünyayı gösterir (CHAPTERS.md Bölüm 15; README.md Bölüm 15).
- **Zaman Bürosu:** zaman dışı; sonsuz koridor, kostüm deposu, Nihat'ın odası (duvarda Form Z-1), Bekleme Salonu (CHAPTERS.md §2.4, §3.2; STORY_BRANCHES.md Son 3).

## 5. Tekrar eden öğeler ve eşyalar

- **Telsiz-Kumanda:** koli bandı, kırmızı düğme, iade garantisi (GDD.md §4, §9.1).
- **Koli bandı:** Hikmet'in; Urban'ın çatlak topunu bantlar; Logothetes mühür bantlamayı "sahtecilik" sayar (GDD.md §8 #6).
- **Leblebi:** poşet; Kadri'nin yeni yemeği, Niko'nun ziyafeti, "Leblebipolis" (GDD.md §8 #4, §11).
- **Telefon %14:** %1'de dram müziği, %0'da tuğla. Powerbank +%40 (GDD.md §7.7).
- **Fes:** Osmanlı'da "Frenk elçisi", Bizans'ta "Türk casusu"; fes hiçbir zaman kaybolmaz (GDD.md §7.5).
- **Hesap makinesi:** Urban ve Fatih için "cin" (GDD.md §5.5).
- **Rubik küpü:** Fatih çözer, Konstantinos reddeder (GDD.md §8 #10).
- **Selfie çubuğu, kolonya, termos:** dürtme ya da denge aracı, diplomasi bonusu, çay (GDD.md §8).
- **Sinerji (tavuk):** Niko'nun tavuğu, her seferinde geri gelir (GDD.md §5.15).
- **Vikipedi tartışma sayfası:** Paradoks'un göstergesi (GDD.md §4).
- **Form Z-1453:** üç nüsha, ıslak imza (GDD.md §5.9).
- **"1453 → 14:53":** panelin görüntüsü (GDD.md §9.1).
- **"Bütçe yetmedi" haritası:** kesik çizgili ok; Büro'nun da bütçesi yoktur (GDD.md §4 tablo).
- **Açılış uyarısı:** "Bu oyun gerçek tarih değildir ... ama biraz öyle." (GDD.md §9.0).
- **Hasan ile Hüseyin:** "kim kim" tartışması (GDD.md §5.7).
- **"Kimse fark etmez":** Tolga dönse de dönmese de dünyayı kimse fark etmez (GDD.md §4).

## 6. Kanonda açık uçlar

### 6.1 Hangi final kanon sayılacak (sahibinin kararı, 2026-11-02: şimdi değil)
Sahibi: "İkinci oyunu şimdi yazmayacağız, kalsın. İleride Napolyon'u görmeye gitmek gibi bir şey olacak." Kanon final seçilmedi; ikinci oyun yazılırken karar verilir. O güne kadar hiçbir final ötekilerin önüne geçmez ve yeni içerik herhangi bir finali dışlamaz. Seçenekler (FINALS.md, CHAPTERS.md §7) not olarak kalır:
- **A. Final kanon değil:** yalnız dünya kuralları ve karakterler kanon; oyuncunun gördüğü final küçük göndermelerle anılır.
- **B. Tolga döner, dünya düzeltilmez:** Kimse Fark Etmedi, Sıradan Bir Pazartesi.
- **C. Yanlış yıl kolu:** 49 Yıl Geç, Başka Bir Yıl (1977).
- **D. Büro kolu:** Kurucu Üye, Gece Mesaisi.
- **E. Nihat kolu:** Yeni Model, Zaman Tamir Servisi.
- **F. Makine kolu:** Mühürlü Garaj (Zamanatör 3001), Sultan'ın Tamiri.
- **G. 1453'te kalan Hikmet:** İki Komşu 1453'te.

### 6.2 İkinci oyun için kancalar (yalnız kaynakta dayanağı olanlar)
- **"Bölüm 2: Hikmet'in Yolculuğu (yakında)"** menü seçeneği; Hikmet 1977'ye gitmek ister (CHAPTERS.md §10). Koşul: "8 adlandırılmış final" (bkz. 6.3-1).
- **Bekleme Salonu:** "Başka dönemlerden gelmiş başka Tolgalar" oturur (STORY_BRANCHES.md Son 3). Bu Tolgaların kim olduğu yazılmamıştır.
- **Kurucu "T.":** Z-1 kuruluş belgesindeki imza açık gizemdir (GDD.md §6.3; CHAPTERS.md §3.2).
- **Vaka numaralandırması:** 1453-T ve 1977-T "Halay" (FINALS.md). Büro'nun başka vakaları bu düzene oturur.
- **Zamanatör 3001:** Mühürlü Garaj finalinde Hikmet'in yapmaya başladığı yedek makine (CHAPTERS.md §7, final 10).
- **Kırmızı düğmenin bandı:** "Sonraki oyunda düğmede koli bandı" (STORY_BRANCHES.md Son 10, Matris 6).
- **Meta kayıt:** makinenin sayacı "{n}. yolculuk" der; görülen yollar sonraki oyunlarda küçük göndermeler yapar. Mekanik avantaj yoktur (GDD.md §6.4, §13.2).
- **Açık ipler:** Urban'ın ödenmemiş faturası (GDD.md §6.4); Niko'nun "Leb... bir şeydi" rüyası (GDD.md §6.4); Fatih'in "Bu cihazı daha önce görmüş gibiyim" dediği uzaktan kumanda (GDD.md §6.4); Dragan'ın çöken lağımı (OTTOMAN_STORY.md §2.3).
- **Fikirler (tasarlanmadı):** Napolyon'u görmeye gitmek (sahibinin ikinci oyun fikri, 2026-11-02); Kanuni dönemi (Mimar Sinan'a deprem yönetmeliği), Antik Mısır (piramit proje yöneticisi), 1923 (nüfus kâğıdı), Truva (at) (GDD.md §14).
- **Açık sorular:** Sinerji'nin cinsiyeti ve sesi; jenerik olarak selfie albümü; 11. "gerçek son" (Hikmet makineye binerse) (GDD.md §16).

### 6.3 Çelişkiler

**Çözüldü (oyundaki hâliyle, 2026-11-02):**
1. **Final sayısı: 27.** Oyun 27 final sayar (Achievements.FINALS_TOTAL, FinalReview.FINALS_ORDER, ACH_FINALS_ALL; README.md). GDD.md §10'daki 10 son demonun, CHAPTERS.md §7'deki 15 + 1 ve README'nin eski 13'ü önceki tasarım aşamalarıdır. Hikmet'in "8 final" koşulu (CHAPTERS.md §10) 27'nin 8'i olarak geçerlidir; bu menü seçeneği oyunda yok, ikinci oyun kancasıdır.
   27 final: İki Komşu 1453'te, Mühürlü Garaj, Boş Masa, 49 Yıl Geç, Başka Bir Yıl, Kurucu Üye, Gece Mesaisi, Sultan'ın Tamiri, Evrak Eksik, Uzun Bekleyiş, Bir Yıl Daha, Sultan'ın Sofrası, Venedik'e Elçi, Büronun Kuruluşu, Tünel Sulhu, Bir Akşam, Büyük Patlama, Topçubaşı, Zaman Tamir Servisi, Yeni Model, Pijamalı Kurtarma, Kimse Fark Etmedi, Saçaktaki Çocuk, Sakabaşı, Kuralsız, Düzeltildi Ama..., Sıradan Bir Pazartesi (UI_CH15_FINAL_*).
3. **Kuşatma takvimi:** Perde I–III 22–26 Nisan'dır ve 2026'da pazar 03:12 – pazartesi 07:30 arasına sığar (1 saat ≈ 1 gün). Perde IV (Hasar Tespit, Ağustos 1452 – 1 Haziran 1453) zamanın dışındaki Büro'dan yürür ve Tolga aldığı ana (26 Nisan öğle ya da gün batımı) geri bırakılır; 2026 saati ilerlemez (bkz. §2, D17_N_BACK). OTTOMAN_STORY.md §3'teki "26 Nisan öğlesine geri bırakacak" bununla aynıdır.
4. **Ay tutulması:** Asıl tutulma 22 Mayıs'tadır (24o, LORE_24_1, UI_LOADTIP_7). 4b'deki 22 Nisan tutulması Tolga'nın gelişinin takvim yankısıdır; Tolga onu anakronizm diye işaretler (D4B_T_ECLIPSE_1). İkisi de olur.
5. **Şenlik ateşleri:** Asılları 27–28 Mayıs'tadır (32o). Bölüm 11'deki 25 Nisan aydınlatması yankıdır, Nihat "26 Mayıs'ta yakılacaktı" diye işaretler (D11_N_ILLUM).
6. **İmparator'un mektubu ve teslim reddi:** İki ayrı olaydır. 25 Nisan heyeti (10H) oyunun uydurmasıdır, erkene alınmıştır (GDD.md §15); İmparator'un mektubu Fatih'e Tolga'nın elinden gider. 21 Mayıs'taki İsmail Hamza teklifi (23) tarihîdir ve o mektubun cevabı olarak sunulur (D23_I_LETTER). Konstantinos iki kez de reddeder (D10H_K_ANSWER, D23_K_ANSWER_2).
7. **Hasan:** Tek kişidir (bkz. §3, Hasan tek kişidir). SPK_HASAN anahtarı doğru; 22o'daki yeniden tanışma, 4a ya da 10O'da karşılaşılmadıysa geçerlidir (D22O_H_01 / D22O_H_01_KNOWN).

**Açık (karar verilmedi):**
2. **Bölüm numaraları:** CHAPTERS.md'de Bölüm 15 final; FINALS.md'de ekran numarası kuşatma 13-23, dönüş 24-26, final 27; dosya numaraları (chapter15.gd, Siege.ORDER) ayrı. README.md: Bizans 13-25, Osmanlı 13-34. Hangisi kanon?
8. **Topçubaşı:** "Topçubaşı Ali" (SPK_TOPCU; 17o, 32o) ile "Topçubaşı Mehmed Ağa" (SPK_SARUCA, strings.csv) iki ayrı ad.
9. **Çandarlı anahtarı:** SPK_CANDARLI etiketi "Kukuletalı adam" (strings.csv); Çandarlı için SPK_PASHA ve SPK_HALIL kullanılır. Anahtar etiketi hatalı olabilir; kodla doğrulanmalı.
10. **Büro'nun bilinirliği:** "1453'teki hiçbir karakter Büro'yu bilmez" ilkesi (BYZANTINE_MIRROR.md giriş; OTTOMAN_STORY.md §2.2) ile Arşiv dalında (Son 9) Z-1 kuruluş belgesinin 1453'te Theodoros'un arşivinde bulunması çelişir.
11. **Form kodu:** Osmanlı nüshası TR'de "Z-1453/GT" (OTTOMAN_STORY.md §3), EN'de "Z-1453/TW-D" (BYZANTINE_MIRROR.md §2). GT-TW eşlemesi belgelenmemiştir.
12. **Hızır, Leon, Turgut:** WRITERS_BRIEF.md yalnız kısaltma olarak verir (HZ, LN, AB). Leon artık var: Okçu Leon, Giustiniani'nin bölüğünde Rum okçu (SPK_LEON; 36b). Hızır yalnız bir etiket olarak var ("Azap Hızır", SPK_HIZIR_TAG); Turgut için strings.csv'de karakter yoktur. SPK_AZAP ve SPK_DEFENDER genel etiketlerdir. Hızır ve Turgut henüz kanonlaşmamıştır.

## 7. Tutarlılık kuralları

### 7.1 İsimler (TR / EN)
- Tolga / Tolga · Hikmet Amca / Hikmet · Denetçi Nihat (Zamanoğlu) / Inspector Nihat · Başdenetçi Saniye Hanım / Chief Inspector Saniye (strings.csv).
- Sultan Mehmed (Fatih) / Sultan Mehmed (SPK_FATIH). Tarihî ad II. Mehmed (GDD.md §15).
- İmparator Konstantinos / Emperor Constantine (SPK_EMPEROR). Tarihî ad XI. Konstantinos (GDD.md §15).
- Aşçıbaşı Kadri / Head Cook Kadri · Tercüman Lütfi / Lütfi the Interpreter · Usta Urban / Master Urban · Niko / Niko · Sinerji / Synergy.
- Hasan ile Hüseyin / Hasan and Hüseyin · Giovanni Giustiniani / Giovanni Giustiniani · Logothetes Theodoros / Theodoros the Logothete · Sorucu Ağa / The Questioning Agha.
- Çandarlı Halil Paşa / Çandarlı Halil Pasha · Zağanos Paşa / Zaganos Pasha (strings.csv).
- Zamanatör 3000 / The Chrono-Matic 3000 · Gerçek Tarih Bu Değil / Not a History Game · Leblebipolis / Chickpeapolis (GDD.md §11).
- Bölüm ve final adları: CHAPTERS.md §6.2 ve §7 (TR/EN). Para birimi: akçe (Osmanlı), duka (Urban ve Cenevizli/Venedikli) (GDD.md §4 kural 7).

### 7.2 Tarih ve saat sabitleri
- Pazar gecesi 03:12 başlangıç; kalkış 03:20; dönüş penceresi 07:15 (26 Nisan öğle); servis pazartesi 07:30 (CHAPTERS.md §2.4).
- Kırmızı düğme garantisi 10 dakika (2026) = 1453'te yaklaşık 4 saat (CHAPTERS.md §2.2).
- Panel 1453 → 14:53 (GDD.md §9.1). Telefon %14 başlangıç (GDD.md §7.7).
- Kuşatma 6 Nisan 1453; gemiler 22 Nisan'da karadan; şehir 29 Mayıs 1453'te alındı (GDD.md §15).
- Fatih 30 Mart 1432 doğumlu; kuşatmada 21 yaşında (GDD.md §15).
- Oruç günü 28 Mayıs; hücum 29 Mayıs şafağı (OTTOMAN_STORY.md §4.1). Perde IV'ün günleri Tolga'nın 2026 saatine eklenmez (bkz. §2).
- Bekleme Salonu sıra no 4.582.119 (STORY_BRANCHES.md Son 3; README.md Bölüm 14).
- Telsiz Bağı 0-5, başlangıç 2; pencere 12 sn (5) ya da 3 sn (0) (CHAPTERS.md §4.5).
- Kural Sadakati başlangıç 60; 50 ve 35 eşikleri (CHAPTERS.md §4.3).
- Paradoks eşikleri 30, 60, 90 (GDD.md §7.8).
- Merak ve İkna %: 0 → %10, 1 → %40, 2 → %70, 3+ → %100 (CHAPTERS.md §4.2).
- Form Z-1453 üç nüsha; Misafir İzni yedi nüsha (GDD.md §5.9, §5.14).

### 7.3 Değişmeyecekler
- Tolga dönerse dış hayatı değişmez; değişiklikleri fark eden tek kişi Hikmet'tir (CHAPTERS.md §2.5).
- Kerkoporta kullanılmaz (GDD.md §15).
- Fatih ve Konstantinos ciddi karakterlerdir; onlarla dalga geçilmez (GDD.md §4 kural 1).
- Giustiniani'nin yaralanması ve şehrin düşüşü şaka konusu değildir (GDD.md §4 kural 8).
- Anakronizmler etiketlenir; yanlış tarih bilgisi kahramanın ağzından ya da kostümünden gelir ve düzeltilir (GDD.md §4 kural 3).
- Fes hiçbir zaman kaybolmaz; Sinerji asla kaybolmaz (GDD.md §5.15, §7.5).
- Bizanslı replikleri [Yunanca] etiketiyle italik gösterilir (GDD.md §11).
- Tuş adı metne yazılmaz; "tekmele" denir (WRITERS_BRIEF.md kural 6).
- Altyazı en çok ~160 karakter (WRITERS_BRIEF.md kural 2).
- Tarih kaynakları: Runciman, Sphrantzes, Barbaro, Tursun Bey, Kritovoulos. Uydurma ayrıntı "uydurma" diye işaretlenir (WRITERS_BRIEF.md kural 4).

### 7.4 Güncelleme kuralı
- Yeni karakter, hikâye ya da kural eklenince bu belge güncellenir; çelişki çıkarsa sahibine sorulur (PLANLAR.md).
- Yeni dış yazar satırları WRITERS_BRIEF.md'deki anahtar biçimine uyar (`D<bölüm>_<KISALTMA>_<AD>`); yeni karakterler `not` alanında belirtilir.
