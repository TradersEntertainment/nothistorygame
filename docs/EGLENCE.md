# Bölüm bölüm eğlence niyeti

Eğlenceyi ölçmenin tek yolu gerçek oyuncu; neyin eğlenceli olması gerektiğine oyunun sahibi karar verir.
Bu tablo ikisini yan yana koyar:

- **Niyet** (sahibi yazar): bu bölümde oyuncu neye gülmeli, ne hissetmeli? Tek cümle.
- **Test** (tools/playtest_report.py doldurur): ortalama eğlence puanı (1-5), ortalama süre, yarıda bırakılma.
- **Karar** (sahibi verir): tut / kısalt / birleştir / yeniden yaz. Claude, niyeti tutmayan ya da puanı düşük
  bölümler için somut öneri (hangi sahne, kaç dakika, ne kesilir) yazar; uygulama onaydan sonra.

Oyun testi: Ayarlar → Oyun testi → "Oyun testine katıl". Oyuncu dosya aramaz: çıkarken gönderilmemiş cevap varsa
"Kopyala / Çık / Geri" kartı çıkar; "Kopyala" cevapları panoya alır, oyuncu WhatsApp, Discord ya da e-postayla
yapıştırıp gönderir. Gelen mesajları (ya da sohbet dışa aktarımını) bir .txt dosyasına koymak yeter; dosyalar da
olur (Ayarlar → "Test verisini klasörde göster").
Toplama: `python3 tools/playtest_report.py MESAJLAR.txt KLASÖR... -o docs/OYUN_TESTI_SONUC.md` (aynı oturum iki kez
gelirse bir sayılır).

**Niyet sütunundaki "(taslak)" satırları Claude'un her bölümün senaryo ve kod başlığından çıkardığı öneridir (v0.99.109).**
Sahibi düzeltir, siler ya da "(taslak)" işaretini kaldırarak onaylar. "(taslak, emin değil)": bölümün ayırt edici şakası ya da
duygusu kaynaklardan net çıkmadı.

| Sahne | Başlık | Niyet (sahibi) | Puan | Süre (dk) | Bırakılma | Karar |
|---|---|---|---|---|---|---|
| chapter0 | Soğuk açılış (29 Mayıs 1453, gedik) | (taslak) Ok yağmurunda kare donar, Tolga "nasıl geldiğimi merak ediyorsunuz" der, Nihat "sayfa henüz yazılmadı" diye keser. |  |  |  |  |
| chapter1 | BÖLÜM 1 — ZAMANATÖR · Tolga · Pazar gecesi, 03:00 | (taslak) Amcanın garajında 1453'ün 14:53 sanılması; on eşyadan beşini çantaya seçip kırmızı düğmeye basma merakı. |  |  |  |  |
| chapter2 | BÖLÜM 2 — YAĞLI KIZAKLAR · Tolga · 22 Nisan 1453, sabah | (taslak) Gökten yağlı kızağa düşüp kadırganın önünden kaçarken iade garantisinin geri sayması; kıyı mı zincir mi paniği. |  |  |  |  |
| chapter3 | BÖLÜM 3 — VAKA 1453-T · Nihat · Zaman Bürosu, zamanın dışında | (taslak) Pnömatik tüp, Form Z-1 ve fötr şapkayla Büro bürokrasisi; Hikmet'i leblebi kabuklarıyla sıkıştırıp sonunda çay içmek. |  |  |  |  |
| chapter4 | BÖLÜM 4 — İLK GECE | (taslak) Hasan ile Hüseyin "kim kim" diye tartışırken aralarından sıvışmak, ya da Niko'nun fırlattığı tavuklardan biriyle arkadaş olmak. |  |  |  |  |
| chapter5 | BÖLÜM 5 — GARAJDA GECE · Hikmet · 2026, pazar gecesi 04:00 | (taslak) Minibüsün projektöründen saklanarak makineyi söken yaşlı amca; şakaların ortasında 1977 itirafının üç saniyelik sessizliği. |  |  |  |  |
| chapter6 | BÖLÜM 6 — ORDUGÂH | (taslak) Otağa sızmanın dört yolu (aşçı yamağı, sahte Frenk elçisi, topu bantlamak) ya da izni kapan martıyı çatılarda kovalamak. |  |  |  |  |
| chapter7 | BÖLÜM 7 — SAHA ÇALIŞMASI · Denetçi Nihat · 24 Nisan 1453, öğle | (taslak) Denetçi 1453'te tarayıcıyla iz sürerken her sohbet saat yer; Lütfi'ye form doldurtmak, Yönetmelik Duvarı'nda formu yırtmak. |  |  |  |  |
| chapter8 | BÖLÜM 8 — HIRDAVATÇI · Hikmet · 2026, pazartesi 05:00 · servise iki buçuk saat | (taslak) Gece hırdavatçısında 1453 µF kondansatör ararken fenerli ajanlardan reyon arkasına saklanan amca; sonunda makineye kendisi biner. |  |  |  |  |
| chapter9 | BÖLÜM 9 — TEKLİFLER · Tolga · 25 Nisan 1453, sabah | (taslak) Herkesin Tolga'ya iş teklif ettiği sabah, hangi kapıyı açacağını seçmek; pazarda keçiden kaçan pijamalı Hikmet. |  |  |  |  |
| chapter10 | BÖLÜM 10 — ARŞİV | (taslak) Holy Grail'deki köprü bekçisi gibi Sorucu Ağa'nın saçma üçüncü sorusu; dürüst "bilmiyorum"un ödüllendirilmesi. |  |  |  |  |
| chapter10a | BÖLÜM 10 — ARŞİV · Tolga · 25 Nisan 1453, Bizans arşivi | (taslak) Bizans arşivini plaza usulü renk koduyla düzenlemek; Zaman Bürosu'nun kuruluş belgesindeki boş imzanın "T." çıkması. |  |  |  |  |
| chapter10b | BÖLÜM 10 — BÜYÜK ATIŞ · Tolga · 25 Nisan 1453, topçu sahası | (taslak) Urban'ın topuna "Pazartesi" ya da "Koli" adı koyup barutu ikiye katlamak; ağır çekimde herkesin uçtuğu Büyük Patlama. |  |  |  |  |
| chapter10g | BÖLÜM 10 — GALATA · Tolga · 25 Nisan 1453, Haliç'in öbür yakası | (taslak) Galata'da herkesin seni bir başkasına yollaması (balıkçı, şarapçı, noter); gemi çanı çalarken iskeleye yetişme telaşı. |  |  |  |  |
| chapter10h | BÖLÜM 10 — HEYET · Tolga · 25 Nisan 1453, beyaz bayrak altında | (taslak) Lütfi huzurda her şeyi yanlış çevirirken düzeltmek ya da susmak; sonunda İmparator'a "gelecekten geliyorum" deme anı. |  |  |  |  |
| chapter10l | BÖLÜM 10 — LAĞIM · Tolga · 25 Nisan 1453, toprağın altında | (taslak) Mum azalırken kaz, destek koy, dinle gerilimi; karşı lağımla karanlıkta yüz yüze gelip ekmek bölüşmek. |  |  |  |  |
| chapter10z | BÖLÜM 10 — ZİYAFET · Tolga · 25 Nisan 1453, ordugâh mutfağı | (taslak) Sultan'a ziyafet menüsü önerirken domatesin, patatesin, acı biberin daha gelmemiş olması; yanınca leblebi yağmuru. |  |  |  |  |
| chapter11 | BÖLÜM 11 — YÜZLEŞME · Nihat ve Tolga · 25 Nisan 1453, gece | (taslak) "Form Z-1453'ü doldurmadınız"; kontrol avcıdan kaçana geçer, araya pijamalı Hikmet formlarla kavgaya girer. |  |  |  |  |
| chapter12 | BÖLÜM 12 — HUZUR · Tolga · 26 Nisan 1453, sabah · Padişah'ın otağı | (taslak) Fatih "bu şehir alınacak mı?" diye sorar; sigortacının en güçlü kozu dürüst bir "bilmiyorum"dur. |  |  |  |  |
| chapter12b | BÖLÜM 12 — SON AKŞAM · Tolga · 26 Nisan 1453, surlarda gün batımı | (taslak) Bilerek espri yok: gün batımında Konstantinos'a "yetecek mi?" sorusunu dürüst ya da iyi niyetli yalanla cevaplamanın ağırlığı. |  |  |  |  |
| chapter13 | BÖLÜM {N} — DÖNÜŞ PENCERESİ · Hikmet · 2026, pazartesi 07:15 · servise 15 dakika | (taslak) Servise on beş dakika kala amca pencereyi açar, Tolga kırmızı düğmeyi son saniyede basılı tutar; kaçarsa 1977. |  |  |  |  |
| chapter14 | BÖLÜM {N} — SON FORM · Nihat · Zaman Bürosu, zamanın dışında | (taslak) Nihat'ın daktilodaki raporu dünyayı yazar; Tolga'nın 4.582.119 numaralı bekleme sırası Büro'nun son şakası. |  |  |  |  |
| chapter15 | BÖLÜM {N} — PAZARTESİ · Final | (taslak, emin değil) Pazartesi sabahı bütün kaderlerin servis durağında toplanması; 1977'de kalırsan ilk poliçeyi genç Hikmet'e yazmak. |  |  |  |  |
| chapter16 | GİZLİ BÖLÜM — GIDAK · Sinerji · 90 saniye | (taslak) Tavuk yüksekliğinde 90 saniye: kırmızı düğmeyi üç kez gagalamak mı, leblebi çuvalına yenik düşmek mi. |  |  |  |  |
| chapter17 | BÖLÜM {N} — KUNDAK · 28 Nisan 1453 · Haliç · şafaktan iki saat önce | (taslak) Tanık sözleşmesiyle geri dönüp karanlıkta sessiz kürek; Coco'nun fustası batarken denizcileri sudan çekme telaşı. |  |  |  |  |
| chapter17o | BÖLÜM {N} — KUNDAK (ORDUGÂH) · 28 Nisan 1453 · Haliç'in kuzey kıyısı · kıyı topları | (taslak) Aynı geceyi öbür kıyıdan görmek: top doldurduktan sonra yanan kadırgaya kova zinciri, Kadri yamaklarıyla yetişir. |  |  |  |  |
| chapter18 | BÖLÜM {N} — FIÇI KÖPRÜ · Mayıs başı 1453 · Haliç'in iç ucu · Osmanlı kıyısı | (taslak) Fıçı köprüye "yapı sigortası" satmaya çalışırken bağı kaçırıp koli bandına sarılmak; usta: "Halat var evlat." |  |  |  |  |
| chapter18b | BÖLÜM {N} — FIÇI KÖPRÜ (SURLAR) · Mayıs başı 1453 · Haliç surları · öğle | (taslak, emin değil) Bizans topunda barut ikilemi: çok koyarsan menzil tam ama kendi surun çatlar. |  |  |  |  |
| chapter19 | BÖLÜM {N} — BRİGANTİN · 3 Mayıs 1453 · Haliç · gece yarısı | (taslak) Sarıklı sahte Türk gemisinde tercümanlık; Ege'de boş ufuk ve dönme oylamasıyla perdenin en sessiz anı. |  |  |  |  |
| chapter19o | BÖLÜM {N} — DEVRİYE (ORDUGÂH) · 3 Mayıs 1453 gecesi · Haliç'in ağzı, zincirin dışı | (taslak, emin değil) Sarıkların ters sarıldığını, kaptanın "aleyküm"ünün İtalyanca olduğunu fark edip reise söylemek ya da susmak. |  |  |  |  |
| chapter20 | BÖLÜM {N} — GEDİK · 7 Mayıs 1453 · Kara surları, Lykos vadisi · gece | (taslak) Gedikte yük taşıyıp gözcünün "Siper!"inde saklanmak; "gedik sigortası"na Giustiniani: "Prim her gün artar." |  |  |  |  |
| chapter20o | BÖLÜM {N} — GEDİK (ORDUGÂH) · 7 Mayıs 1453 · Urban'ın büyük topu · gündüz | (taslak) Urban'ın topunu zeytinyağıyla soğutma sabrı; acele edersen namlu çatlar, "Tunç sabır ister." |  |  |  |  |
| chapter21 | BÖLÜM {N} — LAĞIM · 16 Mayıs 1453 · Mesoteichion · gece | (taslak) Telefondaki deprem uygulamasıyla su kaplarında sıcak-soğuk; karşı lağımda Mirko'yla leblebili sus anlaşması. |  |  |  |  |
| chapter21o | BÖLÜM {N} — LAĞIM (ORDUGÂH) · 16 Mayıs 1453 · Zağanos Paşa'nın lağımı · toprağın altı | (taslak) Dragan'la kazı ritmi, karşı lağımla karanlıkta bir anlık bakışma, ardından dumandan kaçış. |  |  |  |  |
| chapter22 | BÖLÜM {N} — KULE · 18 Mayıs 1453 · Mesoteichion · şafak | (taslak) "Dün burada yoktu, ruhsatı var mı?" denen kuleye fitilli fıçıyı doğru anda bırakmak; geç kalırsan kaşlar gider. |  |  |  |  |
| chapter22o | BÖLÜM {N} — KULE (ORDUGÂH) · 17 Mayıs 1453 gecesi · hendeğin önü | (taslak) Bir gecede kule kurmak (toprak, deri, makara); ertesi gece yanarken marangozları merdivenden indirmek. |  |  |  |  |
| chapter23 | BÖLÜM {N} — ELÇİ · 21 Mayıs 1453 · Blakherna Sarayı | (taslak) Bu kez ikna değil sadık tercüme; yumuşatma isteğine direnmek, iki onurlu tarafın aynı karede durması. |  |  |  |  |
| chapter24 | BÖLÜM {N} — ALAMETLER · 24 Mayıs 1453 · Konstantinopolis · Hodegetria alayı | (taslak) Fırtınada ikona sedyesini dengede tutup selde çocuğu saçağa almak; kubbedeki ışığa "bu sefer ben değilim." |  |  |  |  |
| chapter24o | BÖLÜM {N} — ALAMETLER (ORDUGÂH) · 22 Mayıs 1453 gecesi · ordugâh | (taslak) Kanlı ay altında çorba taşıyıp tedirgin askerleri ateş başlarında yatıştırmak; dolu altında çadır ipine asılmak. |  |  |  |  |
| chapter25 | BÖLÜM {N} — SON AKŞAM · 27 Mayıs 1453 · Osmanlı ordugâhı · gece | (taslak) Şerbet bahanesiyle otağın arkasında meclisi gizlice dinlemek; sonra Ayasofya'da fotoğrafsız, tek bir mum. |  |  |  |  |
| chapter26 | BÖLÜM {N} — ŞAFAK · 29 Mayıs 1453 · Mesoteichion · gece 01.30 | (taslak) Soğuk açılıştaki karenin gerçekten gelmesi; Giustiniani'yi uyarıp uyarmamak ve son kareyi çekmeme hakkı. |  |  |  |  |
| chapter26o | BÖLÜM {N} — ŞAFAK (ORDUGÂH) · 29 Mayıs 1453 · hendeğin önü · gece 01.30 | (taslak, emin değil) Son hücumu sucu olarak dışarıdan yaşamak; su verdiğin Hasan'ın sancakla gediğe koşması. |  |  |  |  |
| chapter27 | BÖLÜM {N} — AHİTNAME · 1 Haziran 1453 · Galata · öğleden sonra | (taslak) Galata rıhtımında tanıdıklara "kal" ya da "git" demek; ahitnameyle kuşatma dosyasının kapanması. |  |  |  |  |
| chapter28o | BÖLÜM {N} — İLK ATIŞ (ORDUGÂH) · 6 Nisan 1453 · Kara surlarının önü · Urban'ın bataryası | (taslak) Şahi'yi "hey-yap" ritmiyle çekerken kütüğü öne yetiştirme telaşı; yetişemezsen top burnunu toprağa gömer. |  |  |  |  |
| chapter29 | BÖLÜM {N} — ZİNCİRİN ÖNÜ · 20 Nisan 1453 · Haliç'in ağzı · Ceneviz karakası | (taslak) Ceneviz karakasında kanca ipi kesip ateş söndürürken kıyıda Sultan'ın atını denize sürmesine tanık olmak. |  |  |  |  |
| chapter29o | BÖLÜM {N} — ZİNCİRİN ÖNÜ (DONANMA) · 20 Nisan 1453 · Haliç'in ağzı · öğleden sonra | (taslak) Alçak kadırgadan kanca atıp tırmanırken tepeden gelen kovayla geri düşmek; tarih zaten aynı kalacak. |  |  |  |  |
| chapter30 | BÖLÜM {N} — BLAKHERNA · 12 Mayıs 1453 · saray önündeki surun yürüyüş yolu · gece yarısı | (taslak) Sur yolunda merdivenleri itip çıkanlarla kılıçlaşmak; meşaleler arasında İmparator'un bizzat sura çıkışı. |  |  |  |  |
| chapter30o | BÖLÜM {N} — BLAKHERNA (ORDUGÂH) · 12 Mayıs 1453 · Blakherna sarayı önündeki sur · gece yarısı | (taslak) Geri çekilme borusunda merdivenden panikle inmek, yetişemezsen merdivenle birlikte çalıya devrilmek. |  |  |  |  |
| chapter31o | BÖLÜM {N} — CUMA · 30 Mayıs – 1 Haziran 1453 · şehir, Eyüp, Ayasofya | (taslak) Fethin ertesinde yanık evden çocuk kurtarmak, Ayasofya'da hasırları kıbleye çevirmek, kamette telefonu cebe koymak. |  |  |  |  |
| chapter32o | BÖLÜM {N} — SON GÜN · 28 Mayıs 1453 · Lykos vadisi, hendeğin önü · oruç günü | (taslak, emin değil) Oruç gününün bitmeyen hazırlığından sonra akşam ışıkları ve Sultan geçerken gelen "Sükût!" |  |  |  |  |
| chapter33o | BÖLÜM {N} — BOĞAZKESEN · 31 Ağustos 1452 · Boğaziçi, Rumeli kıyısı · yeni hisar | (taslak) Sertifikasız, sigortasız serbest tırmanış; gümrükte "siz sigortacılığı icat etmişsiniz" deyip şarap hediyesini reddetmek. |  |  |  |  |
| chapter34o | BÖLÜM {N} — TUNCUN SESİ · Ocak 1453 · Edirne, Tunca kıyısı · Urban'ın döküm yeri | (taslak) Edirne'de topu dökerken çıkrık ritmi, buzda kızaklı çocukları ipin arkasına toplamak, ateş almayan deneme atışı. |  |  |  |  |
| chapter35o | BÖLÜM {N} — EDİRNE YOLU · Mart 1453 · Trakya, taşkın bir derenin kıyısı · konvoyun önü | (taslak) Konvoyun önünde taşkın dereye köprü, çamurda hey-yap, yokuşta fren ipi; kaçan öküzü adıyla çağırmak. |  |  |  |  |
| chapter36b | BÖLÜM {N} — HURUÇ · 9 Nisan 1453 · Mesoteichion'un önü · şafaktan önce | (taslak) Surdan gizlice çıkıp siper yakmanın cüreti; davullar gelince yaralı Leon'u omuzlayıp poterna kapanmadan dönmek. |  |  |  |  |
| chapter37o | BÖLÜM {N} — İLK HÜCUM · 18 Nisan 1453 · Mesoteichion, barikatın önü · gece | (taslak) Kâtibin ilk hücumu: hasır kalkan altında zil çalmak, kalastan hendeğe düşmek, barikatın fıçılarını kancayla sökmek. |  |  |  |  |
| chapter38o | BÖLÜM {N} — HALİÇ SURLARI (DONANMA) · 29 Mayıs 1453 · Haliç, Petrion önü · gece 01.30 → öğle | (taslak) Haliç surunda merdiveni tutarken kaynar yağdan yana sarkmak; rıhtımla tekne arasına düşeni zamanında çekmek. |  |  |  |  |
| chapter39o | BÖLÜM {N} — EMANET · 29 Mayıs 1453 · Petrion mahallesi, Haliç kıyısı · akşam | (taslak) Yağmacılardan önce altı kapıya Sultan'ın sancağını yetiştirme yarışı; baltalı tayfayı tezkireyle durdurmak. |  |  |  |  |
| chapter41o | BÖLÜM {N} — TALİM · 17 Nisan 1453 · Ordugâhın talim meydanı · öğleden sonra | (taslak) Kılıç tutmayı bilmeyen kâtibin Turgut'un meydanında dayak yiyerek öğrenmesi; kum torbasında "Taş olsaydı..." |  |  |  |  |
| chapter42b | BÖLÜM {N} — TALİM · 7 Nisan 1453 · Surların içi, Mesoteichion'un ardındaki meydan · sabah | (taslak) Giustiniani'nin meydanında Leon'la talim; merdiveni itince tırmananın samana düşmesi, ders oyun gibi akar. |  |  |  |  |
| chapter43o | BÖLÜM {N} — KUŞBAKIŞI · 25 Mayıs 1453 · Sultan'ın otağı · öğleden sonra | (taslak) Fatih'e dron uçurmayı öğretirken görünmez Nihat pili gevşetir; her aksaklıkta kelleyi kurtaracak bahane bulmak. |  |  |  |  |

## Niyeti zayıf görünen bölümler (şüphe, karar sahibinin)

Bunlar yalnızca şüphe; oynamadan, baş yorumlardan çıkardım. Karar senin.

**chapter15 (Pazartesi, final)**
- Neden: baş yorum açıkça "Oyuncu çoğunlukla izleyicidir: kamera sahneden sahneye geçer" diyor; seçim ve oynanış yalnız T3'ün 1977 sahnesinde.
- Oyuncu ne yapıyor: T1/T2/T4 finallerinde dört sahneyi (garaj, Nihat'ın masası, servis durağı, final kartı) izliyor.
- Seçenek: T1/T4 dalında servis durağına tek bir küçük eylem ekle (Tolga'nın çantasından 1453'ten kalan eşyayı müdüre gösterip göstermemek gibi); ya da garaj ve Nihat sahnelerini birer kısa karta indir.

**chapter32o (Son Gün)**
- Neden: baş yorum bölümün amacını "Bölüm 25 ile 26o arasındaki boşluğu oynanır kılar" diye tanımlıyor; mekanikleri başka bölümlerden: çalı demeti/sepet (35o, 22o), GunDrill ve namlu soğutma (20o), "Siper!" (22o, 26o).
- Oyuncu ne yapıyor: hendeğe altı demet, merdivene basamak, üç top atışı, akşam meşaleyle ateş yakmak.
- Seçenek: top bataryasını (faz 3) kes, bölüm hendek ve akşamın "Sükût!" anıyla kısalsın; ya da faz 3'ü 20o'nun sonuna taşı.

**chapter18b (Fıçı Köprü, surlar)**
- Neden: üç atışlık GunDrill; aynı nişan mekaniği 17o, 20o, 28o, 32o'da da var. Tek farkı barut miktarı seçimi ve baş yorumda bir mizah satırı yok.
- Oyuncu ne yapıyor: barut seç, doldur, nişan al, üç kez.
- Seçenek: Tolga'nın kendi surunu çatlatmasını "hasar tespit" şakasına çevir (her çatlakta Tolga kendi poliçesine hasar yazar); ya da bölümü chapter30'un girişine kısa bir sahne olarak birleştir.

**chapter19o (Devriye)**
- Neden: baş yorum iki kez "brigantin her durumda geçer", "Tarih yine aynı" diyor; kürek ritmi 17, 29o ve 38o'da da var. Tek seçimin (reise söyle/sus) sonucu yok gibi görünüyor.
- Oyuncu ne yapıyor: kürek çekiyor, brigantine bakıp E'ye basıyor, söyle ya da sus seçiyor, yirmi gün sonra şafak kovalamasında yine kürek.
- Seçenek: şafak kovalamasını kes, bölüm ters sarılmış sarıklar ve İtalyanca "aleyküm" anında bitsin; ya da reise söyleyince reisin kendisinin de fark edip göz kırpması gibi tek bir sonuç ekle.

**chapter26o (Şafak, ordugâh)**
- Neden: chapter26'dan türetilmiş (`extends chapter26.gd`); oyuncu sucu, iş taşımak (su, merdiven) ve "Siper!". Taşıma döngüsü 20, 22o, 26'da da var; kapanış 26 ile ortak.
- Oyuncu ne yapıyor: fıçıdan üç bölüğe su, üç merdiven, ok yaylımında siper, sonra Hasan'a su.
- Seçenek: merdiven taşıma dalgasını kısalt, ağırlığı Hasan'la son konuşmaya ver (32o'daki ateş başı seçiminin karşılığı burada duyulsun).

## Not: uyumsuz başlıklar

- docs/EGLENCE.md'deki 60 sahnenin hepsinin `scripts/` altında bir dosyası var; scripti ya da özeti bulunmayan sahne yok.
- **chapter10**: EGLENCE.md başlığı "ARŞİV" diyor, ama `chapter10.gd` Otağ Kapısı dalı (Sorucu Ağa). Arşiv `chapter10a.gd`. Taslağı scripte göre yazdım; başlığın düzeltilmesi gerekebilir.
- **chapter12b** ile **chapter25** aynı başlığı taşıyor ("SON AKŞAM"); test raporunda karışabilir.
- **chapter21o**, **chapter10l** ile aynı kaz, destek koy döngüsünü kullanıyor; ikisini aynı oyuncu görürse tekrar hissi doğabilir (21o bunu `ch10l_heard` ile anıyor).
