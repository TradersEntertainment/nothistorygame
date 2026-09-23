# Gerçek Tarih Bu Değil — Oyun Tasarım Belgesi (GDD)

> **Oyunun adı:** *Gerçek Tarih Bu Değil* (EN: *Not a History Game*)
> **Bölüm 1:** *Zamanatör 3000 — 1453* (EN: *The Chrono-Matic 3000 — 1453*)
> **Tür:** Birinci şahıs komedi-macera, hafif aksiyon
> **Motor:** Godot 4 · **Platform:** PC (Windows/Linux) → Web → (sonra) konsol
> **Dil:** Türkçe + İngilizce (baştan iki dilli)
> **Hedef:** 20–25 dakikalık oynanabilir demo (ana yol ≈18 dk + Bizans gizli yolu ≈7 dk)
> **Belge sürümü:** 0.3 — 2026-09-23

---

## 1. Tek cümlelik özet

Kendini tarih uzmanı sanan bir belgesel bağımlısı, **yanlış yüzyılın Osmanlı kostümünü** giyip emekli komşusunun koli bandıyla tutturulmuş zaman makinesine biner ve **1453 İstanbul kuşatmasının ortasına** düşer. "Gelecekten gelen bilgisiyle" Fatih Sultan Mehmet'e (ya da yanlışlıkla XI. Konstantinos'a) yardım etmeye çalışır, ama herkes ondan daha zekidir.

## 2. Oyuncu fantezisi

Herkesin aklından en az bir kere "şimdiki aklımla / şu eşyayla geçmişe gitseydim..." geçmiştir. Oyun bu fanteziyi hem **gerçekleştiriyor** hem de **alaya alıyor**. Gidiyorsun, ama bildiklerin yarım, eşyaların saçma, kıyafetin 400 yıl ileride, tarihteki insanlar da sandığından çok daha akıllı.

## 3. Tasarım sütunları

| # | Sütun | Anlamı |
|---|-------|--------|
| 1 | **Her seçim bir espri** | Her eşya, her diyalog seçeneği ve her başarısızlık bir espri ödülü verir. Başarısız olmak da eğlenceli olmalı. |
| 2 | **Durumun saçmalığı, kişinin değil** | Monty Python tarzı absürtlük dünyada ve durumlarda olur. Tarihi figürler (Fatih ve Konstantinos) aklı başında ciddi karakterlerdir. |
| 3 | **Çanta = oyun tarzı** | Başta seçilen 5 eşya çözüm yollarını, diyalogları ve sonları değiştirir. Tekrar oynama nedeni budur. |
| 4 | **Tarih kırılabilir, Tolga'nın hayatı kırılmaz** | Oyuncu tarihi gerçekten bozabilir, dünya da bunu gösterir. Ama 2026'da Tolga'nın hayatı hiç değişmez ve kimse (Tolga da) değişen dünyayı fark etmez. |
| 5 | **Küçük ama cilalı** | 20–25 dakikalık, baştan sona oynanan ve paylaşılabilir bir demo; yarım kalmış 2 saatten iyidir. |

## 4. Mizah rehberi

**Ton:** Monty Python absürtlüğü. Dördüncü duvar yıkılabilir, oyun kendi bütçesiyle dalga geçebilir, bürokrasi her yerdedir (iki imparatorlukta da).

**Kurallar:**
1. **Fatih ve Konstantinos ciddi karakterlerdir.** Fatih 21 yaşında, birkaç dil bilen, matematiğe ve mühendisliğe meraklı bir dahidir. Konstantinos yorgun, onurlu ve durumun farkında bir hükümdardır. Espri onların Tolga'dan hep bir adım önde olmasından çıkar, onlarla dalga geçilmez.
2. **Din, etnik köken ve kutsal değerler espri malzemesi değildir.** İki taraf da kötü adam değildir; iki tarafın sıradan insanları, askerleri ve memurları kendi dertlerinde komiktir.
3. **Anakronizm serbest, yalan tarih bilgisi etiketlidir.** Oyun gerçek tarihi (bkz. §15) bilir; yanlışları kahramanın ağzından, kostümünden ya da "Lise Tarih Kitabı"ndan gelir ve oyun bunları düzeltir.
4. **Kahraman hedefe koyulan kişidir.** Espri çoğunlukla onun kendine güveninin boşa çıkmasıdır.
5. **Başarısızlık = ödül.** Her "yakalandın" ekranı özgün bir espri sahnesidir (bkz. §9.5).

**Diyalog yazım tonu:**
- **Dönem karakterleri** sade, anlaşılır Türkçe konuşur. Araya serpiştirilmiş eski kelimeler (*efendim, evlât, mademki, hâlâ, ahali, münasip, hakikaten*) dönem kokusunu verir. Ağır Osmanlıca yoktur.
- **Tolga** plaza Türkçesi konuşur: *"Şöyle bir aksiyon alalım"*, *"Bu konuyu bir toplantıda netleştirelim"*, *"Açıkçası burada bir sinerji görüyorum."* Espri iki dil arasındaki kontrasttan çıkar.
- **Bizanslılar** Yunanca konuşur. Oyuncu bunu altyazıyla okur, Tolga ise anlamaz (bkz. §7.6 Çeviri uygulaması). İstisna: çarşı Türkçesi bilen asker Niko.

**Tekrar eden espriler (running gags):**
- **Açılış uyarısı.** Oyun, belgesel ciddiyetinde siyah bir ekranla açılır: *"Bu oyun gerçek tarih değildir."* Üç saniye sonra altına küçük harflerle eklenir: *"...ama biraz öyle."* (EN: *"This is not a history game." / "...well, a bit."*)
- **"Bütçe nedeniyle..."** Pahalı sahneler karton dekor, ağızla yapılmış ses efekti ya da haritada ilerleyen bir okla geçiştirilir.
- **Hikmet Amca'nın telsizi.** En kritik anlarda cızırdar: *"O kırmızı düğmeye basma... bastın mı?"*
- **Telefonun şarjı.** Her kullanımda düşer ve %1'de oyunun en dramatik müziği çalar.
- **Vikipedi düzenleme savaşı.** Tarih bozuldukça sayfa değişir, "tartışma sayfası" giderek çıldırır.
- **Fes.** Kim görürse Tolga'yı başka bir şey sanar (§7.5). Hikmet telsizden: *"Evlât, o fes 1829'da gelecek. Biraz erken gittin."*
- **Nöbetçi ikilisi Hasan ile Hüseyin.** Her karşılaşmada kimin kim olduğunu tartışırlar.
- **Kimse fark etmez.** Her sonda dünya değişir, Tolga ise pazartesi sabahı aynı servise biner ve hiçbir şeyi fark etmez.

## 5. Karakterler

### 5.1 Tolga (oyuncu karakteri) — konuşan kahraman
- **Kim:** 34 yaşında, sigorta şirketinde çalışıyor, gece 3'te belgesel izliyor ve kendini tarih uzmanı sanıyor.
- **Kişiliği:** Çok konuşur, laf sokar, kendine fazla güvenir; özünde iyi niyetli ve korkaktır. Plaza Türkçesiyle konuşur.
- **Kıyafeti — yanlış dönemin kostümü:** Zamanatör'ü görünce "hazırlıklı gitmeliyim" der ve şirketin geçen yılki *"Osmanlı Gecesi"* partisinden kalan kostümü giyer: **kırmızı fes, siyah redingot (İstanbulin ceket), altında çoraplı terlik**. Kostümcü "tam dönem" demiştir. Dönem doğrudur, ama 19. yüzyıl.
- **Oynanışta:** Diyalog seçenekleri onun ağzından yazılır. Oyuncu *ne söyleneceğini* değil, *Tolga'nın hangi saçmalığı söyleyeceğini* seçer.
- **Replik örnekleri:**
  - *"Sakin ol Tolga. 20 tane belgesel izledin. Sen bu işin uzmanısın. ...Fethin tarihi neydi? 1435? 1543? Bir 5, bir 3, bir 4 vardı."*
  - *"Merhaba, ben Tolga, gelecekten geliyorum. Kısaca kendimi tanıtayım: sigorta sektöründe 8 yıllık tecrübem var."*

### 5.2 Hikmet Amca (mucit) — emekli, kendini dahi sanan komşu
- **Kim:** Emekli elektrik teknisyeni. Garajında "Zamanatör 3000"ü yapmış. Her şeyi koli bandıyla tamir eder.
- **Rolü:** Tolga'nın çantasına bantladığı telsizle oyun boyunca araya girer; yarı anlatıcı, yarı ipucu sistemidir. İpuçları çoğunlukla yanlıştır ama bazen dâhicedir.
- **Replik örnekleri:**
  - *"Evladım, makinede sadece bir sorun var: çalışıyor. Bunu hiç beklemiyordum."*
  - *"Padişah'a benden selam söyle. Bir de sor, o toplar kaç volt?"*
- **Gizli yönü:** Gizli sonda Fatih'in makineyi ondan daha iyi tamir ettiğini öğrenince bozulur.

### 5.3 Sultan II. Mehmed (Fatih) — ciddi karakter
- **Kim:** 21 yaşında genç padişah. Soğukkanlı, meraklı, keskin zekâlı.
- **Rolü:** Demonun son "boss"u bir diyalog bulmacasıdır. Tolga'nın "gelecek bilgileri"nin çoğunu zaten biliyordur (gemileri karadan yürütme planı çoktan uygulanmıştır).
- **Onu etkileyen:** Bilgi değil, **merak uyandıran şeyler**: hesap makinesi, Rubik küpü, bir mühendislik fikri, dürüstlük. Bir de fes: *"Bu başlık... garip, ama kullanışlı. Kimin icadı?"*
- **Replik örneği:** *"Gemileri karadan mı yürütelim diyorsun? ...Dün yürüttük. Sen de üstlerinden birinin önünde kayıyordun. Hatırladın mı?"*

### 5.4 Tercüman Lütfi
- Yedi dil bildiğini iddia eder; Tolga'nın plaza Türkçesini "tercüme" eder.
- **Espri motoru:** Deyimleri birebir çevirir. "Kafayı yedim" → *"Bu adam bir kafa yemiş, efendim. Kimin kafası olduğu henüz bilinmiyor."* "Sinerji" kelimesini "cin" diye çevirir.
- Otağa giden **Yol B**'nin anahtarıdır.

### 5.5 Usta Urban (topçu)
- Macar top dökümcüsü. Huysuz, mükemmeliyetçi, büyük toplara takıntılı.
- Tolga ona "bu top çatlayacak" diye uyarmaya çalışır; Urban bunu mesleki hakaret sayar.
- **Yol C**'nin anahtarıdır: telefonun hesap makinesini görünce ona "cin" der ve cini satın almak ister.
- **Bizans bağlantısı:** Urban önce hizmetini Bizans'a teklif etmiş, parası ödenmeyince Fatih'e gelmiştir (bkz. §15). Tolga bunu iki tarafa da söylerse iki tarafta da kötü karşılanır.

### 5.6 Aşçıbaşı Kadri
- Ordugâhın mutfağının hâkimi. Leblebiyi hayatında ilk kez görür ve hemen yeni bir yemek icat etmeye kalkar.
- **Yol A**'nın anahtarıdır: aşçı kılığı ve "Sultan'ın sofrasına yeni lezzet" bahanesi.

### 5.7 Nöbetçiler Hasan ile Hüseyin
- İki yeniçeri. Hangisinin Hasan olduğu konusunda anlaşamazlar.
- Gizlilik bölümlerinin "koruma" NPC'leridir; şüphelenme mantıkları bilerek aptalcadır ama tutarlıdır.

### 5.8 Kapı Bekçisi (Sorucu Ağa)
- Otağın kapısında durur ve Holy Grail'deki köprü bekçisi gibi **üç soru** sorar. Cevaplar çantadaki eşyalara göre değişir.
- *"Adın ne? Buraya niye geldin? ...Bir devenin günde kaç okka su içtiğini bilir misin?"*

### 5.9 Denetçi Nihat Zamanoğlu (Zaman Bürosu)
- Takım elbiseli, dosya taşıyan, sonsuz sabırlı bir memur. **Paradoks Metresi** eşiği aşınca belirir.
- Tolga'ya **Form Z-1453**'ü (üç nüsha, ıslak imza) doldurtur. Bu, oyuncuyu engelleyen ama komik bir bürokrasi mini oyunudur.
- **Bizans'ta:** Bizans bürokrasisini görünce mesleki hayranlıkla gözleri dolar: *"Yedi nüsha... Mühür sırası... Ben bu adamlardan çok şey öğrenirim."*
- Bir sonun sahibidir (bkz. §10).

### 5.10 Çandarlı Halil Paşa (arka plan, opsiyonel)
- Kuşatmaya karşı çıkan temkinli sadrazam. Tolga'yı "barış elçisi" sanıp kendi planına alet etmeye çalışabilir.
- Demoda sadece bir yan diyalog ve bir sonun ipucudur; ileride genişletilebilir.

### 5.11 Niko (Bizans tarafı) — surdan laf atan asker
- **Kim:** Deniz surlarında nöbet tutan, gürültücü bir Bizans askeri. Barış zamanında çarşıda Türk tüccarlarla alışveriş yaptığı için **kırık dökük bir çarşı Türkçesi** konuşur. Bizans tarafında Tolga'nın anlayabildiği tek kişidir.
- **Monty Python'daki Fransız şövalyesi gibi:** Önce surdan Tolga'ya laf atar ve eline ne geçerse fırlatır (kuru incir çuvalı, bir tavuk, eski bir kalkan). *"Hey sen, fesli! Annen bir Ceneviz kayığıydı! Baban kötü zeytinyağı kokardı!"*
- Tolga'yı yakalayınca, onu kendisine terfi getirecek bir "Türk casusu" sanır ve bir rehber gibi şehirde dolaştırır. Hem Tolga'ya hem de dışarıdaki ordulara laf atmaya devam eder.
- **Rolü:** Bizans yolunda rehber ve tercümandır. Tercümeleri Lütfi'ninki kadar berbattır, ama başka bir şekilde.

### 5.12 İmparator XI. Konstantinos — ciddi karakter
- **Kim:** Bizans'ın son imparatoru. Yorgun, onurlu, durumun ne kadar zor olduğunu bilen bir adam.
- **Rolü:** Bizans yolunun "huzur" sahnesi. Fesli Tolga'yı Osmanlı elçisi sanar ve ona Fatih'e götürmesi için bir **mektup** verir.
- **Kural:** Fatih gibi o da ciddi karakterdir. Espri, Tolga'nın ona karşı yaptığı saçmalıklardan ve Niko'nun tercümelerinden çıkar.
- **Replik örneği (Niko'nun tercümesiyle):** Konstantinos: *"Sana bir mektup veriyorum. Sultana götür."* Niko: *"İmparator diyor: kâğıt al, git, bir daha gelme."*

### 5.13 Giovanni Giustiniani (Cenevizli komutan)
- Kara surlarını savunan Cenevizli paralı asker komutanı. Pratik, yorgun, her şeye sözleşme gözüyle bakan biri.
- Tolga'nın sigortacı içgüdüleri ilk kez işe yarar: Giustiniani'ye bir **"savaş sigortası poliçesi"** anlatır. Giustiniani ilgilenir, sonra primleri görünce vazgeçer.
- **Paradoks tuzağı:** Tolga ona "29 Mayıs'ta dikkat et, yaralanacaksın" derse paradoks puanı büyük bir sıçrama yapar ve Denetçi hemen belirir.

### 5.14 Logothetes Theodoros (Bizans bürokrasisi)
- Sarayın evrak işlerini yöneten memur. Şehirde kalmak isteyen herkes, **yedi nüsha** hâlinde ve **yedi farklı odada mühürlenen** bir Yunanca "Misafir İzni" belgesine ihtiyaç duyar.
- Denetçi Nihat'ın 1453'teki muadilidir: Nihat'tan daha yavaş, daha kibar, daha karmaşık.
- **Bizans Labirenti** mini oyununun sahibidir (§9.4).

## 6. Hikaye

### 6.1 Önbilgi
2026, İstanbul, gece 03:12. Tolga yine bir fetih belgeseli izliyor ve "Ah ben orada olsaydım, şimdiki aklımla..." diye iç çekiyor. Kapı çalıyor: pijamalı Hikmet Amca. *"Evladım, gel bir bak şuna. Büyük bir buluş yaptım ve deneyecek birine ihtiyacım var. Tercihen sigortalı."*

Tolga makinenin gerçek olduğunu anlayınca "Böyle gidilmez, dönem kıyafeti lazım" deyip dolaptan geçen yılın parti kostümünü (fes + redingot) çıkarıyor.

### 6.2 Olay örgüsü (demo)
1. **Açılış uyarısı:** *"Bu oyun gerçek tarih değildir. ...ama biraz öyle."*
2. **Garaj:** Tolga kostümünü giyiyor, çantasını hazırlıyor, tarihi girmeye çalışıyor. **1453** yazıyor, makine bunu **14:53** okuyor. Hikmet makineye tekme atıyor. Işık.
3. **22 Nisan 1453:** Tolga, Osmanlı gemilerinin karadan Haliç'e indirildiği yağlı kızakların üstüne düşüyor. Arkasında bir kadırga yokuş aşağı geliyor. **Koş!** Kaçışın sonunda Haliç'e düşüyor.
4. **Yol ayrımı — Haliç'te:**
   - **Ana yol:** Osmanlı kıyısına yüzer. Zağanos Paşa'nın askerleri onu yakalar (redingot yüzünden "Frenk casusu" sanılır). Ordugâh bölümü başlar.
   - **Gizli yol:** Haliç'in ağzındaki **büyük zincire** tutunur ve zincirin üstünde dengede yürüyerek şehir tarafına geçer. Bizans bölümü başlar.
5. **Ordugâh (ana yol):** Tolga çadırdan kaçıyor. Amacı Padişah'ın otağına varmak. 3 yol + yedek yol var (§9.3).
6. **Surların İçi (gizli yol):** Niko, Bizans bürokrasisi, Giustiniani ve İmparator. Konstantinos, Tolga'yı Osmanlı elçisi sanıp eline bir mektup veriyor ve onu beyaz bayrakla surların dışına gönderiyor (§9.4).
7. **Otağ kapısı:** Ana yoldan gelenler için Sorucu Ağa'nın üç sorusu. Bizans'tan elçi olarak gelenler kapıdan resmî törenle girer ama Sorucu Ağa yine de üçüncü soruyu sormak için arkalarından koşar.
8. **Huzur:** Fatih'le diyalog bulmacası. Bizans yolundan gelen oyuncunun elinde Konstantinos'un mektubu ve fazladan seçenekler vardır.
9. **Son:** Paradoks puanı, gidilen yol ve verilen kararlara göre 5 sondan biri (§10).

### 6.3 Büyük resim (demo sonrası)
Zamanatör her seferinde yanlış bir döneme atıyor. Gelecek bölüm fikirleri §14'te. Hikmet Amca ile Denetçi Nihat seriyi bağlayan karakterlerdir. Tolga'nın hayatı hiçbir bölümde değişmez: her dönüşte aynı pazartesi sabahına uyanır.

## 7. Oynanış mekanikleri

### 7.1 Temel kontroller
| Eylem | Klavye/Fare | Gamepad |
|-------|-------------|---------|
| Hareket | WASD | Sol analog |
| Bakış | Fare | Sağ analog |
| Zıplama | Space | A |
| Eğilme / gizlenme | Ctrl / C | B |
| Koşma | Shift | Sol analog bas |
| Etkileşim / konuş | E | X |
| Eşya kullan / fırlat | Sol tık | RT |
| Eşya göster (NPC'ye) | Sağ tık | LT |
| Çanta çarkı | Tab / fare tekerleği | LB/RB |
| Telefon | F | Y |
| Fesi tak / çıkar | H | D-pad yukarı |

### 7.2 Çanta sistemi
- Garajda **10 eşya** var, çantaya **5 tane** sığıyor (§8). Kostüm (fes + redingot) çantadan sayılmaz, her zaman üstündedir.
- Her eşyanın 3 kullanımı vardır: **Kullan** (fiziksel etki), **Göster** (NPC tepkisi), **Ver** (NPC'ye bırakmak, geri alınamaz).
- **Göster matrisi:** Demodaki her konuşan NPC, çantadaki her eşyaya **özel bir replikle** tepki verir. 10 eşya × 12 NPC = 120 kısa replik. Bu, oyunun ana ödül döngüsüdür. Oyuncular bunu paylaşır, bu da oyunun reklamı olur.
  - **Kapsam emniyeti:** Zaman yetmezse Bizans NPC'leri 10 eşyanın sadece 5'ine özel tepki verir, diğerlerine ortak bir "Bu ne?" repliğiyle karşılık verir.

### 7.3 Diyalog sistemi
- Dallanan diyalog ağaçları var. Her düğümde 2–4 Tolga repliği ve varsa bir **[Eşya göster]** seçeneği bulunur.
- Bazı seçeneklerin **ton etiketi** vardır: 😎 Ukala, 😰 Panik, 🤓 Belgesel bilgisi, 💼 Plaza. Sonuçları NPC'ye göre değişir.
- "🤓 Belgesel bilgisi" seçenekleri **%50 yanlış** bilgi içerir; oyuncu hangisinin doğru olduğunu Vikipedi'ye bakarak anlayabilir (şarj harcar).
- "💼 Plaza" seçenekleri Osmanlı tarafında genelde kötü sonuç verir, ama Giustiniani ve Bizans bürokrasisinde şaşırtıcı biçimde işe yarar.

### 7.4 Şüphe Metresi (gizlilik)
- Her NPC'nin başının üstünde bir şüphe ikonu var: ❔ → ❓ → ❗.
- Koşmak, telefonun ışığı ve anakronik konuşma şüpheyi **artırır**. Kılık, kalabalıkta durmak ve "yerel" diyalog seçimi şüpheyi **azaltır**. Fesin etkisi tarafa göre değişir (§7.5).
- ❗ olunca kovalamaca başlar. Yakalanmak oyun sonu değildir: bir **"Yakalandın" skeci** oynatılır ve oyuncu en yakın kontrol noktasından devam eder.

### 7.5 Kimlik: fes ve redingot
Kostüm her tarafta Tolga'yı başka bir şey sandırır. Bu, oyunun ikinci ana mekaniğidir.

| Taraf | Fesli Tolga'yı ne sanıyor | Fessiz Tolga'yı ne sanıyor |
|-------|----------------------------|-----------------------------|
| **Osmanlı ordugâhı** | Tuhaf başlıklı bir **Frenk elçisi**. Saygı görür ama sürekli sorguya çekilir. | Redingotlu bir **deli**. Kimse onu ciddiye almaz, ama kimse onu takip etmeye de zahmet etmez. |
| **Bizans şehri** | Bir **Türk casusu**. Şüphe hızla yükselir. | Kaybolmuş bir **Frenk tüccarı**. Serbestçe dolaşabilir. |
| **Cenevizliler (Giustiniani)** | Yeni bir **tarikatın** üyesi. Merak edilir, sorular sorulur. | Sıradan bir yolcu. |

- Fesi takıp çıkarmak (H) anlık bir karar mekaniğidir. Bazı kapılar sadece fesle açılır (örneğin "elçi" muamelesi), bazıları sadece fessiz.
- **Fes hiçbir zaman kaybolmaz.** Fırlatılsa bile bir sonraki sahnede başında olur. Tolga: *"Bunu nasıl...?"* Hikmet: *"Bantladım."*

### 7.6 Hafif aksiyon (silahsız)
- **Fırlatma:** Leblebi (dikkat dağıtır), testi (kırılır, ses çıkarır), yastık (sersemletir, 2 saniye).
- **Kovalamaca sahneleri:** Kızak kaçışı (açılış), ordugâh kaçışı ve Bizans'ta çatılar üzerinde kısa bir kaçış. Engeller ve kaygan zeminlerle fiziğe dayalı komedi.
- **Denge bölümü:** Haliç zinciri. Zincir dalgalarla sallanır, Tolga'nın ağırlık merkezini oyuncu fareyle dengeler. Düşünce suya dalar, zincirin başladığı yere döner.
- **Doğaçlama:** Selfie çubuğu kısa menzilli dürtme aleti olarak kullanılabilir: *"Hop! Hop! Mesafe lütfen!"*
- Can barı yok. Çok darbe yersen sersemlersin ve yakalanırsın (§7.4).

### 7.7 Telefon (%14)
| Uygulama | İşlevi | Şarj maliyeti |
|----------|--------|---------------|
| Çevrimdışı Vikipedi | Doğru tarih bilgisi + tarih bozuldukça değişen sayfalar | %1 / açılış |
| Hesap makinesi | Urban ve Fatih'i etkiler ("cin") | %1 |
| Çeviri (Modern Yunanca) | Bizanslıların Ortaçağ Yunancasını çevirmeye çalışır. Sonuçlar %30 doğru, %70 saçmadır. | %1 / cümle |
| Fener | Karanlıkta yol; NPC'lerde şüpheyi çok artırır | %1 / 10 sn |
| Kamera | Selfie. Her önemli NPC'yle "fotoğraf albümü" koleksiyonu | %1 |
| Müzik | Mehter parodisi / pop şarkı çalar, bir sahnede nöbetçiler dans eder | %2 |

- **%1'de** ağır dram müziği çalar. **%0'da** telefon "tuğla" eşyasına dönüşür: gerçek bir tuğla gibi fırlatılabilir.
- Powerbank şarjı +%40 artırır (tek kullanımlık).
- **Çeviri örneği:** Logothetes: *"Belgenizin yedinci mührü eksiktir."* Çeviri: *"Senin yedinci keçin kayıptır. Lütfen balık."*

### 7.8 Paradoks Metresi
- Tarihi bozan her eylem puan verir: bir NPC'ye gelecek bilgisi vermek, Urban'ın topunu "düzeltmek", Fatih'e modern bir eşya bırakmak, Giustiniani'yi uyarmak.
- **Eşikler:**
  - **0–29:** Tarih sağlam. Vikipedi değişmez.
  - **30–59:** Vikipedi'de küçük tuhaflıklar ("İstanbul'un fethinde fesli bir adamın da bulunduğu iddia edilmektedir[kaynak belirtilmeli]").
  - **60–89:** Denetçi Nihat ilk kez belirir ve **Form Z-1453** mini oyununu başlatır.
  - **90+:** Gerçeklik kırılır, sonlar açılır (§10).
- Metre ekranda gösterilmez. Değerini dolaylı olarak Vikipedi'den ve Hikmet'in telsizdeki panik seviyesinden anlarsın.

## 8. Eşyalar (10 eşya, 5 seçilir)

| # | Eşya (TR / EN) | Kullan | Göster/Ver — öne çıkan etkisi | Açtığı yol/son |
|---|----------------|--------|-------------------------------|----------------|
| 1 | **Telefon %14** / *Phone 14%* | Uygulamalar (§7.7) | Urban: "cin kutusu"; Fatih: gerçekten ilgilenir; Niko: "Küçük ayna, ama içinde adam var!" | Yol C, Gizli son, Bizans'ta çeviri |
| 2 | **Çakmak** / *Lighter* | Işık, fitil yakma | Hasan: "büyücü!", Hüseyin: "tütün var mı?"; Niko: "Rum ateşi mi bu?!" | Kızakta kestirme |
| 3 | **Lise Tarih Kitabı (9. sınıf)** / *High School History Book* | Oku: ipucu (yarısı yanlış) | Fatih kendi portresini görür: *"Burnumu büyük çizmişler."* Konstantinos kitabı kapatır ve bir şey söylemeden geri verir. | Leblebipolis sonu |
| 4 | **Bir poşet leblebi** / *Bag of Roasted Chickpeas* | Fırlat: dikkat dağıt | Aşçıbaşı yeni yemek icat eder; kuşatma altındaki Niko için tam bir ziyafettir | Yol A, Leblebipolis sonu, Niko'nun dostluğu |
| 5 | **Powerbank** / *Power Bank* | Telefonu şarj et (+%40) | Görünüşü yüzünden "kutsal taş" sanılır | — |
| 6 | **Koli bandı (Hikmet'in)** / *Duct Tape* | Tamir et / bağla / kapıyı kilitle | Urban çatlak topu bantlar (paradoks +20); Logothetes mühürleri bantla birleştirmeyi "sahtecilik" sayar | Gizli son (makine tamiri) |
| 7 | **Termos çay** / *Thermos of Tea* | İç: koşma süresi +; ver: dostluk | Nöbetçiler çay için 5 dakika mola verir; Giustiniani bir yudum alıp Ceneviz'e ihraç etmeyi düşünür | Gizlilik kolaylığı |
| 8 | **Selfie çubuğu** / *Selfie Stick* | Dürt / uzaktaki eşyayı al | Sorucu Ağa onu "asa" sanar, bir soruyu atlar | Kapı kestirmesi, zincirde denge çubuğu |
| 9 | **Kolonya (limon)** / *Cologne* | Sersemlemiş NPC'yi ayılt | Otağda herkesin eline döker: diplomasi bonusu; Bizans sarayında da aynı ritüeli yapmaya çalışır, ama kimse elini uzatmaz | Huzurda bonus seçenek |
| 10 | **Rubik küpü** / *Rubik's Cube* | Oyna (hiçbir şey olmaz) | Fatih 40 saniyede çözer. Tolga'nın hayatı sorgulaması. Konstantinos küpü nazikçe reddeder: "Şu an bulmacaya ihtiyacım yok." | Fatih'le en iyi bağ |

**Denge notu:** Her yol en az 3 farklı eşya kombinasyonuyla açılabilmeli. Hiçbir 5'li seçim oyunu çözülemez hale getirmemeli: her bölgede "eşyasız" bir yedek çözüm olmalı (daha uzun, daha komik).

## 9. Demo akışı — bölüm bölüm

### 9.0 Açılış
- Siyah ekran, belgesel fontu, ağır bir çello: *"Bu oyun gerçek tarih değildir."*
- Üç saniye sessizlik. Altına küçük harflerle: *"...ama biraz öyle."*
- Çello bir kazoo'ya dönüşür. Başlık: **Gerçek Tarih Bu Değil**.

### 9.1 Bölüm 0 — Hikmet'in Garajı (≈3 dk)
- **Amaç:** Kontrolleri öğretmek, çanta seçmek, kostümü giydirmek, karakterleri tanıtmak.
- **Olaylar:**
  1. Kapı çalar, Hikmet garaja davet eder. Yürüme ve bakınma öğretilir.
  2. Tolga makinenin gerçek olduğunu anlar ve evine koşup parti kostümünü alır. Aynada fes takılır, **fes tak/çıkar** öğretilir. Hikmet: *"Hiç yakışmadı. Ama kim bilir, orada moda olabilir."*
  3. Garajda 10 eşya dağınık hâlde durur (bkz. §8). Her birine bakınca Tolga ve Hikmet atışan bir yorum yapar. Eşya alma öğretilir.
  4. Çanta dolunca Hikmet: *"Beşten fazla sığmaz. Ben denedim, çanta patladı, o yüzden koli bandı var."*
  5. Zamanatör paneli: oyuncu yılı tuşlarla girer. **1453 → 14:53.** Hikmet makineye tekme atar. Işık.
- **Gizli detay:** Garajın duvarında boş bir çerçeve var. Gizli sonda içinde bir portre belirir.

### 9.2 Bölüm 1 — Kızak Kaçışı, 22 Nisan 1453 (≈3 dk)
- **Amaç:** Güçlü bir açılış, fiziğe dayalı komedi, dünyayı tanıtmak.
- **Olaylar:**
  1. Tolga, gökten yağlı kızakların üstüne düşer. Kameranın ilk görüntüsü: tepeden aşağı inen bir kadırganın pruvası.
  2. **Koşu bölümü:** Kaygan kızaklar, yuvarlanan kütükler, şaşkın askerler. Çakmak varsa yağlı bir kütüğü yakıp bir kestirme açılabilir.
  3. Sonunda Haliç'e düşer. **Yol ayrımı** (oyuncuya açıkça gösterilmez, keşfedilir):
     - Yakındaki Osmanlı kıyısına yüzmek → Zağanos Paşa'nın askerleri etrafını sarar → **Bölüm 2A**. **Bütçe sahnesi:** ordugâha yolculuk, haritada kesik çizgili okla gösterilir. Hikmet'in telsiz yorumu.
     - Uzaktaki zincire yüzmek (yol boyunca bir Osmanlı kayığının altından geçmek gerekir) → **Zincir denge bölümü** → **Bölüm 2B**.

### 9.3 Bölüm 2A — Ordugâh (ana yol, ≈8 dk)
- **Harita:** Küçük, yoğun bir açık alan: esir çadırı, mutfak, topçu alanı, tercüman çadırı, pazar yeri, otağa giden yol.
- **Başlangıç:** Tolga bir esir çadırında ("Frenk casusu" etiketiyle). Çıkış bulmacası: nöbetçi ikilisi Hasan ile Hüseyin'in "kim kim" tartışmasını kullanarak kaçmak.
- **Otağa giden 3 yol:**

| Yol | Anahtar NPC | Özeti | Önerilen eşyalar |
|-----|-------------|-------|------------------|
| **A — Mutfak** | Aşçıbaşı Kadri | Leblebiyi göster, "yeni lezzet"i Sultan'ın sofrasına taşıyan aşçı yamağı kılığına gir (fessiz) | Leblebi, Termos, Kolonya |
| **B — Tercüman** | Tercüman Lütfi | Lütfi'yi ikna et. Onun berbat tercümelerini düzeltmeye çalışırken Padişah'a "Frenk elçi" olarak götürül (fesli) | Tarih kitabı, Telefon (Vikipedi) |
| **C — Topçu** | Usta Urban | Hesap makinesi "cin"i ile Urban'ı etkile; top denemesini izlemeye gelen Padişah'ın karşısına onun çırağı olarak çık | Telefon, Koli bandı, Rubik küpü |

- **Yedek yol (eşyasız):** Pazar yerinde 3 küçük iyilik yap: kaçan keçiyi yakala, kayıp mühür yüzüğünü bul, bir askerin mektubunu yaz. Karşılığında bir kaftan alırsın (redingotun üstüne giyilir, çok komik görünür). Uzun, ama komik.
- **Yan içerik:** Çandarlı Halil Paşa'nın adamı Tolga'ya gizli bir mektup teklif eder. Kabul edersen paradoks artar, ayrıca bir son ipucu açılır.

### 9.4 Bölüm 2B — Surların İçi (gizli yol, ≈7 dk)
- **Giriş — Haliç zinciri:** Zincirin üstünde denge bölümü. Yarı yolda bir Venedik gemisinin tayfaları Tolga'ya bahis oynar. Selfie çubuğu denge çubuğu olarak kullanılabilir.
- **Deniz surları — Niko:** Zincirin şehir ucunda, surun tepesinden Niko laf atar ve bir şeyler fırlatır. Bu bölüm kısa bir kaçınma oyunudur: fırlatılan tavuklardan, incir çuvallarından ve kalkanlardan saklanarak surun dibindeki küçük kapıya ulaşmak gerekir. Kapıda Niko, Tolga'yı "Türk casusu" olarak yakalar (fesliyse) ya da "kaybolmuş Frenk tüccarı" olarak içeri alır (fessizse).
- **Bizans Labirenti — Logothetes Theodoros:** Şehirde kalmak için yedi nüsha "Misafir İzni" gerekir. Yedi oda, yedi memur, yedi mühür. Her memur bir sonraki odanın başka bir mühre ihtiyacı olduğunu söyler. Mini oyun, doğru mühür sırasını bulmaktır. İpuçları:
  - Telefonun çeviri uygulaması (yarısı saçma),
  - Niko'nun tercümeleri (yarısı hakaret),
  - "💼 Plaza" diyalog seçenekleri: *"Bu süreci bir akış şemasına dökelim"* Bizans memurlarını gerçekten etkiler.
  - Denetçi Nihat burada bir cameo yapar ve bürokrasiye hayran kalır.
- **Kara surları — Giustiniani:** Tolga ona "savaş sigortası" satmaya çalışır. Giustiniani'yi uyarmak büyük paradoks puanı verir (§5.13).
- **İmparatorun huzuru — Konstantinos:** Kısa ve ciddi bir sahne. Konstantinos fesli Tolga'yı Osmanlı elçisi sanır (fessizse Niko onu "Türk casusu" diye tanıtır, sonuç aynıdır). Tolga'ya Sultan'a götürmesi için mühürlü bir **mektup** verir.
- **Çıkış:** Tolga beyaz bir bayrakla kara surlarının bir kapısından dışarı çıkarılır. Niko surdan son lafını atar. Tolga, Osmanlı hatlarına "Bizans'tan elçi" olarak ulaşır ve doğrudan **Bölüm 3**'e geçer.

### 9.5 "Yakalandın" skeçleri (tüm bölümlerde)
Her yakalanmada bir tanesi rastgele oynatılır (tekrar etmeyecek şekilde). Örnekler:
- Hasan ile Hüseyin, Tolga'yı kimin yakaladığını tartışırken Tolga ortada bekler. Kontrol noktasına dönülür.
- Ekran bir tarih kitabı sayfasına dönüşür: *"Sayfa 214: Kuşatma sırasında fesli bir casus yakalandı ve bulaşık yıkamaya verildi. Tarihe etkisi: yok."*
- Bizans'ta: Tolga zindana atılır. Hücrede, 7 nüshalı "Zindandan Çıkış İzni" formunu doldurması istenir. Doldurunca serbest bırakılır.
- Hikmet telsizden: *"Evladım, geri sarıyorum. Bu makinede geri sarma yoktu ama... bir şekilde oldu."*

### 9.6 Bölüm 3 — Otağ kapısı ve huzur (≈5 dk)
- **Kapı:**
  - Ana yoldan gelenler: Sorucu Ağa'nın 3 sorusu. 3. soru her seferinde saçma bir sorudur. Yanlış cevapta *hafifçe* dışarı atılırsın (skeç). Selfie çubuğu bir soruyu atlatır.
  - Bizans'tan gelenler: Resmî elçi töreniyle geçer. Sorucu Ağa arkalarından koşup üçüncü soruyu yine de sorar: *"Bir dakika! Deve! Kaç okka?!"*
- **Huzur — diyalog bulmacası:**
  - Fatih, Tolga'yı dinler. Tolga'nın her "gelecek bilgisi" için Fatih'in hazır bir karşılığı vardır.
  - Kazanmak için 3 **Merak Puanı** gerekir. Bunlar gelir:
    - ilginç bir eşyayı göstermekten (Rubik küpü, hesap makinesi, tarih kitabındaki portre),
    - dürüst bir itiraftan ("Aslında hiçbir şey bilmiyorum" = +1, bu Fatih'i en çok şaşırtan seçenektir),
    - bir mühendislik sorusundan (Urban'ın topu hakkında doğru bir yorum),
    - **(Bizans yolu)** Konstantinos'un mektubunu teslim etmekten ve iki tarafı da görmüş biri olarak dürüst bir yorum yapmaktan.
  - Kötü seçimler, Fatih'in Tolga'yı kibarca "danışman" olarak mutfağa göndermesiyle biter; oyuncu tekrar deneyebilir.
- **Kilit an:** Fatih sorar: *"Madem gelecektensin, söyle bakalım. Bu şehir alınacak mı?"* Oyuncunun cevabı, paradoks puanı ve gidilen yolla birlikte sonu belirler.

## 10. Sonlar (demoda 5 son)

**Değişmez kural:** Tolga'nın kendi hayatı hiçbir sonda değişmez. Her son, Tolga'nın pazartesi sabahı aynı alarmla uyanıp aynı servise binmesiyle biter. Değişen şey dünyadır ve bunu kimse, Tolga da, fark etmez. Espri, oyuncunun arka plandaki değişiklikleri görmesinden çıkar.

| Son | Koşul | Özeti | 2026'da (kimsenin fark etmediği) değişiklik |
|-----|-------|-------|---------------------------------------------|
| **1. "Tarih Yerinde"** (gerçek son) | Paradoks < 30; kilit soruda "Bunu size söyleyemem" | Fatih gülümser: *"Doğru cevap."* Tolga'yı hediyelerle yolcu eder. | Hiçbiri. Sadece dolapta, parti kostümünün yanında gerçek bir 1453 kaftanı asılıdır. |
| **2. "Leblebipolis"** | Leblebi Aşçıbaşı'na verildi + tarih kitabı Fatih'e gösterildi + paradoks ≥ 60 | Leblebi orduya "moral yemeği" olur, şehir adını değiştirir. | Servisin geçtiği bütün tabelalarda *Leblebipolis* yazar. Tolga kulaklığıyla müzik dinler, bakmaz. |
| **3. "Form Z-1453"** (bürokrasi sonu) | Paradoks ≥ 90 ya da Denetçi mini oyununda başarısızlık | Denetçi Nihat, Tolga'yı "Zaman Bürosu Bekleme Salonu"na alır. Sıra numarası: 4.582.119. Salonda başka dönemlerden gelmiş başka "Tolgalar" oturur. | Sıra gelince Tolga tam pazartesi sabahına bırakılır. Ofisteki kahve makinesinin üstünde "Form Z-1453 doldurulmadan kullanmayınız" yazan bir etiket vardır. |
| **4. "İki Hükümdar, Bir Danışman"** (Bizans yolu sonu) | Bizans yolu tamamlandı + mektup teslim edildi + paradoks ≥ 40 + kilit soruda 💼 Plaza cevabı | Tolga iki tarafa bir "ortak kullanım anlaşması" önerir: şehir altı ay Osmanlı'nın, altı ay Bizans'ın olsun. Fatih'in cevabı kısadır: *"Hayır."* Tolga iki ordugâhtan da kovulur ve tarafsız Galata'ya düşer, orada Cenevizlilere sigorta satar. | Tolga'nın çalıştığı sigorta şirketinin logosunun altında artık *"Kuruluş: Galata, 1453"* yazar. |
| **5. Gizli son: "Sultan'ın Tamiri"** | Koli bandı + Rubik küpü + telefon Fatih'e gösterildi, 3 Merak Puanı, Paradoks < 60 | Fatih bozuk Zamanatör'ün uzaktan kumandasını 3 dakikada tamir eder ve Tolga'yı **tam doğru** zamana geri gönderir. | Garajdaki boş çerçevede Fatih'in makineyi elinde tutarken yapılmış bir portresi vardır. Hikmet: *"...Benden iyi tamir etmiş. Kimse duymasın."* |

Demo, hangi sonla biterse bitsin, "**Bölüm 2 yakında: Zamanatör bu sefer [bulanık] yılına atıyor...**" kartıyla kapanır.

## 11. İki dil ve yerelleştirme

- **Kural:** Koda hiçbir yazı gömülmez. Tüm metinler anahtarlarla tutulur (`DLG_URBAN_CALC_01`, `ITEM_CHICKPEA_NAME`...).
- **Format:** Godot'nun yerleşik çeviri sistemi (`TranslationServer`), CSV kaynağı: `keys,tr,en`.
- **Kelime oyunları:** Birebir çevrilmez, her dil için ayrı yazılır. Anahtarın yanında `note` sütunu olur ("TR'de deyim esprisi; EN'de eşdeğer bir espri yaz").
  - Örnek: Lütfi'nin "kafayı yedim" tercümesi EN'de *"I'm losing my head"* → *"He says he is losing his head, Sultan. Shall I fetch the executioner to help him look?"*
- **Dönem dili (EN):** TR'deki "serpiştirme eski kelimeler" yaklaşımının İngilizce karşılığı hafif arkaik bir İngilizcedir (*"Pray tell", "indeed", "good sir"*). Tolga'nın plaza dili EN'de kurumsal İngilizceye dönüşür (*"Let's circle back", "synergy", "take this offline"*).
- **Bizans Yunancası:** İki dilde de altyazıda *italik* ve köşeli parantezle gösterilir: *[Yunanca] Belgenizin yedinci mührü eksiktir.* Oyuncu anlar, Tolga anlamaz.
- **Sabit kalan espriler:** "1453 → 14:53", görsel espriler, Leblebipolis (EN: *Chickpeapolis*), açılış uyarısı (EN: *"This is not a history game." / "...well, a bit."*).
- **Font:** Türkçe karakterleri (ğ, ş, ı, İ) ve Yunan harflerini destekleyen, el yazısına yakın bir font + okunaklı bir UI fontu.
- **Seslendirme:** Demoda gerçek seslendirme yok. Karakterler Animal Crossing tarzı **anlamsız mırıltılar** çıkarır, konuşmalar altyazıyla verilir. Bizanslıların mırıltısı biraz farklı bir perdededir. Maliyet sıfır, iki dilde de çalışır, komik bir etki verir.

## 12. Görsel ve ses yönü

### 12.1 Görsel
- **Low-poly çizgi film:** Abartılı oranlar (büyük kafalar, büyük eller), düz renkler, hafif kontur.
- **Renk paleti:**
  - **Osmanlı ordugâhı:** Sıcak toprak tonları, kırmızı-altın otağ, Haliç'in turkuazı.
  - **Bizans şehri:** Soluk mor, eskimiş altın ve kuşatma altındaki bir şehrin gri taşları. Mozaik desenli ama çatlak duvarlar.
  - **2026 garajı:** Soğuk floresan, gri ve turuncu koli bandı.
- **Tolga'nın kostümü:** Sahnede her zaman görünür olan tek parlak kırmızı fes. Oyuncu onu her ayna, su birikintisi ve cilalı kalkanda görür.
- **"Bütçe" estetiği:** Bazı arka planlar bilerek karton dekordur. Bazı NPC'ler tahta çubuğa yapıştırılmış 2D figürlerdir ve bu oyunda açıkça söylenir.
- **Referanslar:** *Totally Accurate Battle Simulator* (oranlar), *Untitled Goose Game* (düz renkler), *Monty Python* kolaj animasyonları (geçiş sahneleri).

### 12.2 Ses
- **Müzik:**
  - Osmanlı tarafı: Mehter marşının komik aranjmanları (tuba, kazoo).
  - Bizans tarafı: Bizans ilahilerinin melodik havasını taşıyan ama kazoo'yla çalınan bir tema (dini metin kullanılmaz).
  - Gerilim anları: "Ciddi" orkestra parodisi.
- **Ses efektleri:** Önemli anlarda bilerek ağızla yapılmış sesler ("pıııııv!", "güm!"). Niko'nun fırlattığı tavukların sesi.
- **UI:** Telsiz cızırtısı, telefon bildirimleri, Denetçi'nin ve Bizans memurlarının damga sesleri (Bizans damgası daha yavaş ve yedi kez).

## 13. Teknik plan (Godot 4)

### 13.1 Klasör yapısı (planlanan)
```
nothistorygame/
  docs/            # tasarım belgeleri (bu dosya)
  project.godot
  scenes/
    levels/        # garage, slipway, chain, camp, city, tent
    characters/    # player, npc_base, her NPC
    ui/            # dialogue_box, inventory_wheel, phone, wiki, translator
  scripts/
    autoload/      # GameState, Inventory, Paradox, Dialogue, Suspicion, Identity
    player/
    npc/
    items/
  data/
    items/         # eşya tanımları (.tres Resource)
    dialogue/      # diyalog ağaçları (JSON)
    wiki/          # Vikipedi sayfa varyantları
    endings/       # 2026 sahnesindeki değişiklik setleri (tabela, logo, etiket...)
  i18n/
    strings.csv    # keys,tr,en,note
  assets/
    models/ textures/ audio/ fonts/
```

### 13.2 Çekirdek sistemler (autoload)
| Sistem | Görevi |
|--------|--------|
| `GameState` | Bayraklar (flags), kontrol noktaları, seçilen yol (ana/Bizans), kayıt/yükleme |
| `Inventory` | 5 slot, kullan/göster/ver, eşya kaynakları |
| `Paradox` | Puan, eşik sinyalleri (Denetçi, Vikipedi, son hesaplama) |
| `Dialogue` | JSON diyalog ağaçlarını oynatır; koşullar (flag, eşya, paradoks, fes, taraf) ve efektler |
| `Suspicion` | NPC başına şüphe değeri, algı konisi, kovalamaca tetikleme |
| `Identity` | Fes takılı mı, Tolga'nın bulunduğu taraf; her NPC'ye "Tolga'yı ne sanıyor" bilgisini verir (§7.5) |

### 13.3 Diyalog verisi (örnek)
```json
{
  "id": "urban_intro",
  "nodes": {
    "start": {
      "speaker": "urban",
      "text": "DLG_URBAN_INTRO_01",
      "choices": [
        { "text": "DLG_TOLGA_CRACK_WARN", "tone": "smug", "next": "offended", "paradox": 5 },
        { "text": "DLG_TOLGA_ADMIRE",     "tone": "panic", "next": "flattered" },
        { "text": "DLG_TOLGA_SYNERGY",    "tone": "plaza", "next": "confused" },
        { "show_item": "phone", "next": "calc_djinn", "requires": { "battery_min": 1 } }
      ]
    },
    "confused": {
      "speaker": "urban",
      "text": "DLG_URBAN_SYNERGY_DJINN",
      "requires": { "fez": true },
      "next": "start"
    }
  }
}
```

### 13.4 Performans hedefi
- Orta seviye bir dizüstü bilgisayarda 60 FPS, web sürümünde 30 FPS.
- Low-poly + düz renkli materyaller ve basit gölgeler kullanılacak.

## 14. Kapsam ve yol haritası

| Aşama | İçerik | Çıktı |
|-------|--------|-------|
| **M0 — Tasarım** | Bu belge, diyalog taslakları, eşya/NPC tepki matrisi | ✅ GDD v0.3 |
| **M1 — Oynanabilir garaj** | FPS kontrolcüsü, etkileşim, çanta seçimi, fes tak/çıkar, i18n altyapısı, Zamanatör paneli, açılış uyarısı | Yürünebilen garaj sahnesi |
| **M2 — Kızak kaçışı** | Fiziğe dayalı koşu bölümü, kovalamaca, Haliç yol ayrımı, "bütçe" geçişi | İlk "vay be" anı |
| **M3 — Ordugâh** | Şüphe + kimlik sistemi, 3 yol + yedek yol, 6 NPC, göster matrisi | Demonun gövdesi |
| **M4 — Huzur ve sonlar** | Fatih diyalog bulmacası, paradoks sistemi, 4 son (ana yol), Vikipedi, 2026 dönüş sahnesi | Baştan sona oynanan demo |
| **M5 — Bizans gizli yolu** | Zincir denge bölümü, Niko, Bizans Labirenti, Giustiniani, Konstantinos, mektup, 5. son | Tekrar oynama nedeni |
| **M6 — Cila** | Ses, müzik, skeçler, EN çeviri geçişi, web build, test oyuncuları | Paylaşılabilir demo linki |

**Not:** Bizans yolu bilerek M5'e alındı. Zaman yetmezse demo onsuz da eksiksiz bir oyun olarak yayınlanabilir; Bizans yolu bir güncelleme olarak eklenir.

**Kapsam dışı (demo için):** Seslendirme, kuşatma finali (29 Mayıs), Kerkoporta sahnesi, kayıt yuvaları, başarımlar.

**Gelecek bölüm fikirleri:**
- **Kanuni dönemi:** Mimar Sinan'a "deprem yönetmeliği" anlatmaya çalışmak.
- **Antik Mısır:** Piramit inşaatında proje yöneticisi olmak ("Bu bir Gantt şeması, firavunum").
- **1923:** Nüfus kâğıdını kaybetmiş bir zaman yolcusu olmak.
- **Truva:** "O at hediye değil!" diye bağırmak ve kimseyi inandıramamak.

## 15. Tarihsel notlar (doğruluk kontrolü)

Oyunun "doğru bildiği" gerçekler. Tolga'nın yanlışları bunlarla karşılaştırılarak yazılır.

- Kuşatma **6 Nisan 1453**'te başladı, şehir **29 Mayıs 1453**'te alındı.
- II. Mehmed **30 Mart 1432** doğumludur; kuşatma sırasında **21 yaşındaydı**.
- Osmanlı gemileri **22 Nisan 1453**'te Galata'nın arkasındaki tepelerden, yağlanmış kızaklar üzerinde karadan **Haliç'e** (Kasımpaşa tarafına) indirildi. Böylece Haliç'in girişindeki zincir aşılmış oldu.
- **Haliç zinciri**, yüzen kütükler üzerinde, şehir tarafındaki bir kuleden (bugünkü Sirkeci/Sarayburnu civarı) Galata tarafına uzanıyordu. Gemiler Haliç'e girdikten sonra da zincir yerinde kaldı.
- Macar dökümcü **Urban (Orban)** önce hizmetlerini Bizans'a teklif etti; istediği ücreti alamayınca Osmanlı tarafına geçip dev toplar döktü. Büyük topun kuşatma sırasında çatladığı rivayet edilir.
- Padişahın otağı kara surlarının karşısında, **Topkapı (St. Romanus)** kapısının karşısındaki tepede kuruluydu.
- **Zağanos Paşa** Galata/Haliç tarafındaki kuvvetleri yönetti. Sadrazam **Çandarlı Halil Paşa** kuşatmaya temkinli yaklaşıyordu.
- Bizans tarafında son imparator **XI. Konstantinos** vardı. Kuşatma boyunca taraflar arasında elçiler gidip geldi; Konstantinos şehri teslim etme tekliflerini reddetti.
- Cenevizli komutan **Giovanni Giustiniani Longo** kara surlarının savunmasında kilit rol oynadı. 29 Mayıs'taki son saldırıda yaralandı ve savaş alanından çekildi. Galata'daki Cenevizliler resmen tarafsızdı.
- **Kerkoporta:** Son gün açık kaldığı rivayet edilen küçük kapı. Demoda kullanılmıyor, ileride kullanılabilir.
- **Fes:** Osmanlı'da resmî başlık olarak ilk kez **1829'da, II. Mahmud döneminde** kullanılmaya başlandı. **Redingot / İstanbulin** ceket de 19. yüzyıl Tanzimat modasıdır. Tolga'nın kostümü yaklaşık **400 yıl** erkendir. Bu bilinçli bir espridir (§4, kural 3).
- **Leblebi:** Kökeni tartışmalıdır. Oyunda "ilk kez görülen" bir şey olarak kullanılması bilinçli bir anakronizm esprisidir (§4, kural 3).
- **Bizans bürokrasisi:** "Bizans entrikası/bürokrasisi" deyimi abartılı bir klişedir. Oyun bunu bilerek abartır, ama Bizans'ı kötü göstermez (§4, kural 2).

## 16. Açık sorular

1. Niko surdan ne fırlatsın? Holy Grail'deki inek esprisinin 1453 karşılığı ne olmalı (tavuk, keçi, incir çuvalı, bir Bizans eşeği)?
2. Konstantinos'un mektubunda ne yazsın? Oyuncu açıp okuyabilsin mi (paradoks), yoksa mühürlü mü kalsın?
3. Ana yolla Bizans yolu birbirinden haberdar olsun mu? Örneğin Bizans yolundan geçen oyuncu, bir sonraki oyununda ordugâhta Niko'nun surdan laf attığını duysun mu?
4. Tolga Bizans yolunda Urban'ın eski Bizans macerasını öğrenirse bunu Urban'a karşı kullanabilsin mi?
