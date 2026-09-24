# Genişleme Planı — v1.2
### Bizans'ı Kurtar yolu, 1454 gazetesi, Büyük Patlama, menü ve kayıt, eksik bölümler, sonraki dönem

Bu belge CHAPTERS.md (v1.1) ve STORY_BRANCHES.md'nin üstüne eklenir. Çelişki olursa bu belge geçerlidir.

---

## 0. Durum: ne var, ne eksik

| Parça | Durum |
|---|---|
| Bölüm 1–9, 11–15 | ✅ Oynanabilir |
| Bölüm 10 · Otağ Kapısı | ✅ |
| Bölüm 10 · **Büyük Atış** (Urban) | ✅ Büyük Patlama dahil |
| Bölüm 10 · **Heyet** (Lütfi) | ✅ Bizans'ı Kurtar + Son Akşam (12B) |
| Bölüm 10 · **Ziyafet** (Kadri) | ✅ |
| Bölüm 10 · **Galata** (Çandarlı'nın mektubu) | ✅ |
| Bölüm 10 · **Arşiv** (Theodoros) | ✅ |
| Bölüm 16 · **Gıdak** (Sinerji, gizli) | ✅ |
| Dünyalar W5–W8 | ✅ (W5B Büyük Patlama dahil); W9 Form Z-1453 ❌ |
| Yeni dünyalar W10 "1454", W11 "1455", W12 "Ertelendi" | ✅ |
| Ana menü, kayıt, bölüme dönme | ✅ |
| Finaller: Kurucu Üye ✅, Sinerji eklentisi ✅, Form Z-1453 ❌ |
| Ana menüde Hikmet'in yorumları | ✅ |
| Akış şemasında "oyuncuların %X'i" | ❌ (çevrimiçi değil, Steam başarımlarıyla taklit edilebilir) |

**Yapım sırası:** menü ve kayıt → Büyük Atış → Heyet ve Bizans'ı Kurtar → Ziyafet → Galata → Arşiv → Gıdak.

---

## 1. Tasarım ilkesi: "Tarih inatçıdır"

Oyuncuların bir kısmı fethi engellemeye çalışacak: Bizans'ı sevenler, Hristiyan oyuncular, ya da sadece "bakalım ne olur" diyenler. Bunu **yasaklamıyoruz, ödüllendiriyoruz**, ama komediyle:

- Tolga fethi **engelleyemez, sadece erteleyebilir**. Her erteleme bir öncekinden daha saçma bir 2026 doğurur.
- Tarih kendini onarmaya çalışır. Tolga bir kapıyı kapatır, tarih başka bir kapı açar. Bu, "değişmez kural"ın (CHAPTERS §2.5) oyun içi mizahi karşılığıdır.
- **Saygı çizgisi aynen geçerli:** Konstantinos ve Fatih ciddi ve ağırbaşlı kalır. Din, inanç ve kayıplar espri konusu olmaz. Espri Tolga'dan, bürokrasiden, koli bandından ve takvimden gelir.
- İki tarafın oyuncusu da kendini dışlanmış hissetmez. Bizans yolunun sonunda Konstantinos'un sahnesi Fatih'inki kadar onurludur.

---

## 2. Bizans'ı Kurtar yolu ve "1454" gazetesi

### 2.1 Tolga'nın bildiği şey
Tolga "yirmi belgesel izlemiştir" (Bölüm 15'teki toplantı esprisi). Bizans yolunda bu ilk kez işe yarar gibi görünür: kuşatmanın nasıl geçtiğini **biliyor**. İki bilgi vardır, ikisi de gerçek:

1. **Gedikler:** Urban'ın topları gündüz surda yarık açar, savunucular her gece tahta, fıçı ve toprakla kapatır.
2. **Giustiniani'nin yaralanması:** Ceneviz komutan son gün yaralanıp çekilir.

(Karar notu: "Kerkoporta açık kaldı" rivayeti kullanılmaz. Rivayet, fethi Bizans'ın bir dikkatsizliğine bağlayıp Osmanlı'nın başarısını küçültür; Türk oyuncuları haklı olarak rahatsız eder. Gedik tamiri hem gerçek hem de tarafsızdır. Espri simetriden gelir: Tolga Osmanlı'nın çatlak topunu da, Bizans'ın gedikli surunu da aynı koli bandıyla bantlar.)

### 2.2 Yolun kapısı: Heyet dalı (10H) ve 6b
- **6b · Surların İçi** ya da **10 · Heyet** üzerinden Konstantinos'a ulaşan Tolga, huzurda yeni bir seçenek görür:
  ⏱ *"Majeste... size bir şey söylemem lazım. Gelecekten geliyorum."*
- Konstantinos ona inanmaz ama dinler. Tolga bildiklerini sıralar. Her doğru bilgi **Direniş** puanı verir (gizli, 0–3).
- **Direniş kaynakları** (her biri +1):
  - 🔴 **Gediği koli bandıyla sağlamlaştırmak** (Bölüm 10H'de gece görevi; 📦 çantadaysa). Niko: *"Urban'ın topunda da aynısından varmış. Sen iki tarafa da mı bant satıyorsun?"*
  - 🛡️ **Giustiniani'ye powerbank'ten bir "zırh ısıtıcı" yapmak.** Komutan: *"Bu kutu neden ısınıyor?"* (🔋 çantadaysa.) Olmazsa Giustiniani'ye sadece *"Sağ omzunuza dikkat edin"* denebilir, bu da +1 sayılır ama komutan bunu hakaret sanır.
  - ⛓️ **Zinciri güçlendirmek:** Bölüm 4b'deki zincir sahnesinde Niko'ya koli bandını vermek (geriye dönük bayrak `chain_taped`).
- Nihat bunu fark eder: Bölüm 11'de **Paradoks** göstergesi normalin iki katı hızla dolar. Bizans yolu Nihat için "kırmızı alarm"dır.

### 2.3 Sonuç: yeni dünyalar
| Direniş | Dünya | 2026 |
|:--:|---|---|
| 1 | **W10 · 1454** | Fetih bir yıl gecikmiştir. Her şey aynıdır, **sadece tarih 1454'tür.** |
| 2 | **W11 · 1455** | İki yıl. 1454 ile 1455 arasında "Uzun Bekleyiş" diye bir dönem vardır, okulda ayrı ünite olarak okutulur. |
| 3 | **W12 · Ertelendi** | Fetih "Form Z-1453 eksik olduğu için" ertelenmiştir: Nihat'ın Büro'su 1453'te bile bürokrasi çıkarır. Tarih kitaplarında: *"Fetih, gerekli evrakın tamamlanmasının ardından 1456'da gerçekleşmiştir."* |

**Fetih her durumda olur.** Bu yolun en iyi sonu bile tarihi değil, **takvimi** değiştirir.

### 2.4 Pazartesi sahneleri (Bölüm 15)
Tolga servis durağındadır. Büfenin önünde gazete standı vardır. **Gazete manşeti** dünyaya göre değişir, Tolga kulaklıklıdır, bakmaz. Kamera bakar:

- **W10:** *"İSTANBUL'UN FETHİ'NİN 572. YILI — 29 Mayıs 1454"* · alt başlık: *"Tarihçiler: 'Bir yıl gecikme mi? Ne gecikmesi, hep 1454'tü.'"*
- **W10, ofis:** İş arkadaşı: *"1453 değil miydi?"* Diğeri: *"Hayır canım, 1454. İlkokulda ezberlettiler."* Hikmet (telsiz): *"...Evlât ne yaptın?"*
- **W10, sokak:** "1454 Simit Sarayı", "Fetih 1454 Spor Kulübü".
- **W11:** Gazete: *"UZUN BEKLEYİŞ'İN 571. YILI ANILDI"*. Müdür toplantıda: *"Bu çeyrek tıpkı Uzun Bekleyiş gibi, sabırlı olacağız."*
- **W12:** Gazete: *"FETİH 570 YAŞINDA — Form Z-1453'ün aslı ilk kez sergilendi"*. Sergi afişinde Nihat'ın imzası vardır. Nihat (kendi masasında, final): *"...Formun aslı müzede. Ben ne imzaladım?"*

### 2.5 Konstantinos'un sahnesi (Bizans yolunun doruğu)
Direniş ≥ 1 ise Bölüm 12'nin Bizans eşi oynar: **"Son Akşam"**. Konstantinos surlarda, gün batımında Tolga'yla konuşur. Tolga "belgesellerden" bildiği sonu söyleyemez. Konstantinos: *"Bir şehrin kaderini bir adam değiştirmez, yabancı. Ama bir akşamı değiştirebilir. Teşekkür ederim."* Espri yok. Sahne, Fatih'in huzurundaki "Bunu size söyleyemem" sahnesinin aynasıdır.

### 2.6 Yeni finaller
| Öncelik | Final | Koşul |
|:--:|---|---|
| 6.5 | **Bir Yıl Daha** / *One More Year* | W10 |
| 6.6 | **Uzun Bekleyiş** / *The Long Wait* | W11 |
| 6.7 | **Evrak Eksik** / *Missing Paperwork* | W12 |

Başarım: **"Tarih İnatçıdır"**: 1454, 1455 ve Ertelendi'nin üçünü de görmek.

---

## 3. Büyük Atış ve Büyük Patlama (Bölüm 10B)

Fragmanın en güçlü sahnesi burası olacak.

### 3.1 Akış
1. **Döküm (≈2 dk):** Erimiş bronzu kalıba zamanlamayla dökme (akan bronz, sıcaklık çubuğu, 3 kalıp). Urban her hatada Macarca söylenir.
2. **Hesap (≈1 dk):** Tolga açıyı telefonun hesap makinesiyle hesaplar (%1 şarj, her hesap bir çentik). Urban: *"Bu cin kutusu kaç okka barut diyor?"*
3. **Koli bandı:** Topun namlusundaki çatlak bantlanmıştır (📦, Bölüm 6a). Urban: *"Bant tutar mı?"* Tolga: *"Bu bant bir zaman makinesini tutuyor."*
4. **Ateş:** Fatih sahaya gelir. Herkes bekler. Tolga fitili yakar (🔥 çakmak).

### 3.2 Sonuç A: Gülle Galata'ya (10B.1, W5, STORY_BRANCHES Son 6)
Gülle yay çizer ve Galata'da bir şarap fıçısına düşer. Diplomatik kriz.

### 3.3 Sonuç B: **Büyük Patlama** (10B.3, yeni)
**Koşul:** Hesapta hata yapıldı **ya da** çatlak bantlanmadı **ya da** oyuncu fitile ⏱ süre dolmadan iki kez bastı.
- Top ateşlenmez. Bir saniye sessizlik. Urban: *"...Hmm."*
- **Patlama.** Ekran beyaza döner, ağır çekim (zaman ölçeği 0,15).
- Havada, ağır çekimde uçanlar: **Tolga** (fes başında, çanta elinde, yüzü kapkara), **Hasan ile Hüseyin** (birbirine sarılmış), **keçi**, **Sinerji**, üç topçu, bir kazan, Urban'ın bıyığı.
- Kamera Tolga'yla birlikte uçar. Tolga havada telsize konuşur: *"Hikmet Amca... garanti hâlâ geçerli mi?"* Hikmet: *"Ne sesiydi o?"*
- Herkes bir yere düşer: Hasan ile Hüseyin Kadri'nin kazanına, keçi bir çadırın tepesine, Tolga **tam Fatih'in önüne**.
- Fatih kıpırdamamıştır. Yüzünde tek bir is lekesi. Uzun sessizlik. Fatih: *"Urban."* Urban (çadırın tepesinden): *"Efendim."* Fatih: *"Yenisini dök. Bu sefer bantsız."*
- **Kimse ölmez, kimse yaralanmaz.** Çizgi film kuralı: yüzler kararır, saçlar diken diken olur, ağızdan duman halkası çıkar, kulaklarda çınlama (ses). Kan yok.
- **Sonuç:** Paradoks +40, Nihat anında gelir (Bölüm 11 bu sahneden açılır: Nihat patlamanın ortasında form doldurmaktadır). Dünya: **W5b "Büyük Patlama"**. 2026'da Askerî Müze'de: *"Urban'ın Büyük Topu'nun parçaları. 25 Nisan 1453'te bilinmeyen bir sebeple patlamıştır. Olay yerinde bir fes bulunmuştur."*

### 3.4 Teknik (oyun motoru)
- Karakter parçaları (Kimi'nin modelleri parçalı: Body/Head/ArmL/ArmR/LegL/LegR) ağır çekimde ayrı ayrı döner ama **kopmaz**. Bütün karakter tek bir RigidBody3D olarak uçar, parçalar kodla sallanır (ragdoll gerekmez).
- Patlama: GPU parçacıkları (duman, ateş, kıvılcım, toz), ekran sarsıntısı, beyaz flaş, 2 sn kulak çınlaması (ses filtresi).
- **Fragman modu:** `--trailer` bayrağı: HUD'u gizler, sabit sinematik kamera açıları kullanır ve sahneyi tekrar tekrar oynatır.

### 3.5 Diğer "patlamalı" anlar (fragman listesi)
| Sahne | Bölüm | Ne olur |
|---|---|---|
| Büyük Patlama | 10B | Yukarıda |
| Mutfak yangını | 10Z (başarısız) | Kadri'nin kazanı leblebi yüzünden patlar, patlamış leblebi yağmuru |
| Şarap fıçısı | 10G | Galata'da gülle bir fıçıya düşer, Cenevizliler şaraba bulanır |
| Zaman sıçraması | 1, 13 | Makinenin halkaları ve flaş (var) |
| Zincir | 4b | Tolga zincirden denize (var) |

---

## 4. Menü, kayıt ve bölüme dönme

### 4.1 Ana menü (Hikmet'in garajında)
Başlık ekranından sonra, arka planda Hikmet'in garajı ve Hikmet:
- **Devam Et:** son bölüm başı.
- **Yeni Oyun:** otomatik kayıt üstüne yazılır (uyarı sorulur).
- **Bölümler:** bu oyunda ulaşılan bölümlerin listesi ve kapakları. Birine tıklayınca o bölümün **başındaki** duruma dönülür (Detroit'teki "Bölümler" gibi). O bölümden sonraki ilerleme, yeniden oynandıkça üzerine yazılır. Oyuncu önce bir kayıt yuvasına kaydedebilir.
- **Kayıtlar:** 3 kayıt yuvası (bölüm, tarih, oynama süresi, kapak küçük resmi).
- **Ayarlar:** müzik, efekt, ses, fare hassasiyeti, tam ekran, dil.
- **Çıkış.**
- **Hikmet'in yorumu** (CHAPTERS §10): son finale göre bir cümle.

### 4.2 Duraklatma menüsü
Devam · **Bölümün başına dön** · **Önceki bölümler** (bölümler listesi) · **Kaydet** (yuva seç) · Ayarlar · Ana menü · Çıkış.

### 4.3 Kayıt kuralı
Bölümler zaman uyumsuz (async) sahne akışı olduğu için kayıt **bölüm başlarında** alınır. Her bölüm başında otomatik kayıt olur. Elle kayıt, içinde bulunulan bölümün başlangıcını kaydeder. Bu durum menüde açıkça yazılır: *"Kayıt, bölümün başından devam eder."*

### 4.4 Oynama süresine etkisi
Bölümler + akış şeması + kayıt, oyuncuyu **başka sonu görmek için geri dönmeye** teşvik eder. Tek oyun ≈ 3–3,5 saat, bütün finalleri görmek ≈ 10–12 saat.

---

## 5. Diğer eksik dal bölümleri (kısa)

- **10Z · Ziyafet:** STORY_BRANCHES Son 8 aynen. Başarısızlık: mutfak yangını ve patlamış leblebi yağmuru (§3.5).
- **10G · Galata:** STORY_BRANCHES Son 7 aynen. Bizans'ı Kurtar yoluna da bağlanır: Galata'da Giustiniani'nin adamlarına mektubu verirsen Direniş +1.
- **10A · Arşiv:** STORY_BRANCHES Son 9 aynen (Büro'nun kuruluşu, Form Z-1). W12 "Ertelendi" ancak bu dalı görmüş oyuncuda açılır.
- **16 · Gıdak:** CHAPTERS §6 aynen.

---

## 6. 1453'ten sonra: sıradaki dönem

Ölçütler: **komedi potansiyeli**, **hassasiyet riski** (ne kadar düşükse o kadar iyi), **uluslararası pazar**, **eldeki varlıkların tekrar kullanımı**.

| Olay | Yıl | Komedi | Risk | Pazar | Varlık | Not |
|---|---|:--:|:--:|:--:|:--:|---|
| **Hezarfen'in uçuşu + Lagari'nin roketi** | 1632–33 | ★★★★★ | Düşük | ★★★ | ★★★★ (İstanbul, Galata) | Hikmet'in aynası: iki Osmanlı mucidi. Kanatlar, roket, **patlamalar**, Galata Kulesi'nden Üsküdar'a uçuş. Fragman için ideal. Rivayet olduğu için özgürce oynanabilir. |
| **Viyana Kuşatması: kahve ve kruvasan** | 1683 | ★★★★★ | Orta-düşük | ★★★★★ | ★★ | Avrupa pazarı için en güçlüsü. Tolga Viyana'ya ilk kahveyi götüren adam olur. Kruvasan efsanesi, çuvallarca kahve, Viyanalı bürokratlar. |
| **Süleymaniye'nin inşaatı (Mimar Sinan)** | 1550–57 | ★★★★ | Düşük | ★★ | ★★★ | Tolga şantiyeye "proje yöneticisi" olarak düşer: iş güvenliği, Gantt şeması, Sinan'ın sabrı. Sinan, Fatih gibi ciddi karakter. |
| **Ay'a iniş** | 1969 | ★★★★★ | Orta (komplo teorisi çağrışımı) | ★★★★★ | ★ | Fesli bir astronot fotoğrafı. Küresel ilgi yüksek, ama sıfırdan yeni varlık ister. |
| **1977 düğünü (Hikmet'in yolculuğu)** | 1977 | ★★★★ | Çok düşük | ★★ | ★★★★ | Oyunda zaten ima ediliyor (T3, ana menü). Küçük bir DLC ya da ücretsiz güncelleme olarak ideal. |
| Çanakkale, Çaldıran, Cumhuriyet | — | — | **Yüksek** | — | — | **Önerilmez.** Kayıplar, mezhep ve siyasi hassasiyet komediyle bağdaşmaz. |

**Öneri:**
1. **Ücretsiz güncelleme:** "Hikmet'in Yolculuğu" (1977): oyunun kendi vaadi, küçük kapsamlı.
2. **Oyun 2 ya da büyük DLC:** **"Hezarfen" (1632)**. İstanbul varlıkları tekrar kullanılır, uçuş ve roket patlamaları fragmanı taşır, Hikmet bu kez bir meslektaşıyla karşılaşır.
3. **Avrupa hamlesi:** **Viyana 1683** (kahve). İngilizce ve Almanca pazar için en güçlü konu.
