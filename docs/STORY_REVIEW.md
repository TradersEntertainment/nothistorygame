# Hikaye Kalite Kontrolü — v1.0 belgeleri

> Geliştirmeye başlamadan önce [GDD.md](GDD.md), [CHAPTERS.md](CHAPTERS.md), [STORY_BRANCHES.md](STORY_BRANCHES.md) ve [ITEM_REACTIONS.md](ITEM_REACTIONS.md) birlikte okunarak yapılan kontrol.
> Amaç: mantık hataları, tutarsızlıklar, tempo sorunları, karakter gelişimi, ton ve tarih doğruluğu.

---

## 1. Genel değerlendirme

| Alan | Puan | Kısa yorum |
|------|:----:|------------|
| **Ana fikir (premise)** | 9/10 | Güçlü ve kolay anlatılır: "Yanlış yüzyılın kostümüyle, yarım bilgiyle 1453'e düşen plaza çalışanı." Tek cümlede satılır. |
| **Mizah motoru** | 8/10 | Eşya × karakter matrisi, fes kimliği ve plaza dili gibi tekrarlanabilir espri kaynakları var. Espriler duruma dayanıyor, tarihi kişilerle dalga geçilmiyor. |
| **Karakterler** | 7/10 | Nihat en iyi yazılmış karakter: net bir değişim yayı var. Tolga ve Hikmet'in iç yolculuğu zayıf. |
| **Yapı (Detroit)** | 6/10 | Akış şemaları ve kaderler iyi kurulmuş, ama tempo ve bazı dallar dengesiz. |
| **İç tutarlılık** | 5/10 | Oyunu bozan birkaç mantık hatası var (§2). Hepsi küçük kural eklemeleriyle düzeltilebilir. |
| **Tarih doğruluğu** | 8/10 | Temel tarihler, isimler ve olaylar doğru; anakronizmler bilinçli ve etiketli. Küçük pürüzler var (§4). |
| **Hassasiyet** | 9/10 | Fatih ve Konstantinos saygılı, din espri malzemesi değil, kimse ölmüyor. Tek dikkat noktası §4.4. |

**Özet:** Hikayenin çekirdeği sağlam ve komik. Asıl risk mizah değil **mantık**: Detroit tarzı yapıya geçince zaman yolculuğunun kuralları yazılmadan kaldı ve oyuncunun ilk soracağı sorulara ("Neden düğmeye basıp dönmüyor?", "Denetçi neden onu kendisi geri götürmüyor?") cevap yok. Bunlar geliştirmeden **önce** düzeltilmeli, çünkü bölüm yapısını etkiliyorlar.

---

## 2. Kritik sorunlar (oyunu bozan mantık hataları)

### K1 — Kırmızı düğme bütün hikayeyi gereksiz kılıyor
- **Sorun:** Kırmızı düğme Tolga'yı her an anında eve döndürüyor (Son 10). O zaman Bölüm 12'deki dönüş penceresi, Hikmet'in çabası, T2 ("1453'te kaldı") kaderi ve gizli tavuk bölümü anlamsız. Oyuncu ilk soruyu soracak: *"Neden düğmeye basıp dönmüyor?"*
- **Öneri:** Düğmeye bir **garanti süresi** eklemek: *"İlk 10 dakika koşulsuz iade garantisi var evlât. Sonrası... garanti dışı."* Bu, sigorta temasına da oturur. Düğme sadece Bölüm 1–2'de çalışır. Sonra basılırsa sadece cızırdar ve Hikmet: *"Garanti bitti. Ben bir şey yapacağım, bekle."* Böylece Bölüm 12 zorunlu hâle gelir.

### K2 — Zaman Bürosu neden Tolga'yı kendisi geri götürmüyor?
- **Sorun:** Nihat zamanda serbestçe yolculuk ediyor. Tolga'yı bulunca onu 2026'ya kendisi götürebilir. O zaman Hikmet'in makinesine ve dönüş penceresine neden gerek olsun?
- **Öneri:** Bürokratik bir kural (tam da oyunun tonunda): **"Yönetmelik 7/c: Anomali, geldiği araçla iade edilir. Büro araçları yalnızca kadrolu personel taşır."** Nihat bu kuralı Bölüm 3'te söyler. Kuralsız Nihat (N2) bile bu kuralı çiğneyemez: Büro'nun makinesi kadrosuz birini fiziksel olarak kabul etmez. Bu hem Hikmet'i vazgeçilmez yapar hem de T4 ("Büroya katıldı") kaderine yeni bir anlam verir: kadroya giren Tolga artık Büro araçlarıyla seyahat edebilir.

### K3 — İki zaman arasındaki süre tanımlı değil
- **Sorun:** 2026'da olaylar tek gecede geçiyor (03:12 → 04:00 → pazartesi sabahı). 1453'te ise Tolga günlerce kalıyor (22 Nisan'dan Mayıs'a uzanan olaylar, Konstantinos'un mektubu). İki zaman arasındaki oran yazılmamış. Ayrıca gecenin hangi gün olduğu belirsiz: "pazartesi sabahı" finali için gecenin **pazar gecesi** olması gerekiyor.
- **Öneri:**
  - Önbilgiye: *"Pazar gecesi, 03:12."*
  - Kural: **2026'daki 1 saat = 1453'te yaklaşık 1 gün.** 03:12'den sabah 07:30'daki servise kadar yaklaşık 4 saat vardır, bu da 1453'te 4–5 gün eder. Tolga'nın 1453 macerası 22–26 Nisan arasında geçer.
  - Konstantinos'un mektubu tarihte Mayıs sonuna ait. Belge bunu "erkene alındı" diye belirtiyor ama bu kuralla çelişmiyor, sadece not olarak kalmalı.
  - Hikmet'in "servise yetişmen lazım" baskısı Bölüm 12'ye doğal bir **saat baskısı** ekler.

### K4 — Nihat'ın "Kuralsız" olması neredeyse imkânsız (hesap hatası)
- **Sorun:** Kural Sadakati 100'den başlıyor ve Yönetmelik Duvarı 30'un altında tetikleniyor. Bölüm 6'ya kadar yapılabilecek en fazla düşüş şöyle:
  - Bölüm 3: çay (−15). "Makineyi bırak" (−10) ayrı bir sonuç olduğu için ikisi birden seçilemez.
  - Bölüm 6: nöbetçilerin molası (−10) ya da Theodoros (−10), yola göre biri.
  - Toplam **−25 → Sadakat 75.** Duvar Bölüm 6'da hiçbir koşulda gelmez. Bölüm 10'da da en fazla −20 daha düşer (55). **N2 kaderi ve ona bağlı finaller ("Kuralsız", Nihat'ın katılması, rapor tahrifatı) pratikte ulaşılamaz.**
- **Öneri:** Başlangıç değerini **60**, Duvar eşiğini **35** yapmak ve Bölüm 4 ile 7'de Hikmet'in telefonla Nihat'ı aradığı anlara da küçük düşüşler (−5) eklemek. Yeni hesap: 60 − 15 − 5 − 10 = **30** → Bölüm 6'da Duvar ancak Nihat'a en empatik yol seçilirse gelir. Bu, Detroit'teki Connor'ın dengesine benzer: sapma mümkün ama bilinçli bir çaba ister.

### K5 — "Uzaktan kumanda" hiç tanıtılmıyor
- **Sorun:** Gizli son (Fatih'in tamiri), Bölüm 4 (yedek kumanda) ve gizli tavuk bölümü bir "uzaktan kumanda"ya dayanıyor. Ama Bölüm 1'de Tolga'ya sadece bir **telsiz** veriliyor. Kırmızı düğme de telsizde. Oyuncu kumandanın ne olduğunu hiç öğrenmiyor.
- **Öneri:** Üç nesneyi tek nesnede birleştirmek: Hikmet Bölüm 1'de Tolga'nın çantasına **bir telsizle bir TV kumandasını koli bandıyla birbirine yapıştırır**: *"Bu telsiz, bu kumanda. Kırmızı düğme acil dönüş. Diğer düğmeler... kanal değiştiriyor olabilir."* Fatih'in tamir ettiği, Sinerji'nin gagaladığı ve Hikmet'in yedeğini sakladığı hep bu nesnedir. Adı: **"Telsiz-Kumanda"**.

### K6 — Bazı yollarda Fatih hiç görünmüyor
- **Sorun:** Oyunun ana vaadi *"padişahla görüşebilmek"*. Ama Galata (9G) ve Arşiv (9A) dallarında Tolga Fatih'i **hiç görmüyor**, çünkü bu dallar Bölüm 11'i (huzur) atlıyor.
- **Öneri:** Her yolda en az bir Fatih sahnesi olsun:
  - **Galata:** Tolga Venedik gemisine binerken, Fatih kıyıdan Galata'yı incelemektedir (tarihte Galata'yla yazışmaları vardır). Göz göze gelirler. Fatih bir şey söylemez, sadece başını hafifçe eğer. Sonra gemi kalkar.
  - **Arşiv:** Büro'nun ilk toplantısından sonra Nihat, Tolga'yı "resmî denetim ziyareti" için kısa bir süreliğine otağa götürür. Fatih üç dakika dinler ve Büro'nun ilk formunu imzalar: *"Bürokrasinin en iyisi, kısa olanıdır."*

---

## 3. Önemli sorunlar (yapı, tempo ve karakter)

### Ö1 — Perde I demosunda üç garaj bölümü var, 1453'te sadece 6 dakika geçiyor
- **Sorun:** Demonun bölümleri: Garaj (Tolga, 8 dk) → Kızak (6 dk) → Garaj (Nihat, 12 dk) → Garaj (Hikmet, 8 dk). Bölüm 3'ün Büro sahnesi hariç, oyuncunun 34 dakikanın yaklaşık 25'ini **aynı garajda** geçirdiği ve 1453'ü sadece 6 dakika gördüğü bir demo, oyunun vaadini (1453'e gitmek) satmaz.
- **Öneri:** Perde I'i yeniden sıralamak:
  1. **Zamanatör** (Tolga, garaj) — kısaltılmış, 6 dk.
  2. **Yağlı Kızaklar** (Tolga, 1453).
  3. **Vaka 1453-T** (Nihat) — Büro sahnesi büyütülür (yeni ve komik bir mekân: sonsuz koridorlar, her dönemden kostümler), garaj kısmı kısalır.
  4. **Esir Çadırı / Zincir** (Tolga, 1453) — Bölüm 5'in ilk 8 dakikası buraya taşınır.
  - Demo, **Nihat'ın 1453'e indiği bir kapanış sahnesiyle** biter: fötr şapka, daktilo, uzaktan Tolga'nın fesi. Güçlü bir merak kancası olur.
  - Hikmet'in ilk bölümü (Garajda Gece) Perde II'nin başına taşınır. Hikmet demoda Bölüm 1 ve telsiz üzerinden var olur.
  - Sonuç: Demo yine yaklaşık 32 dakika sürer, ama 1453'te geçen süre 6 dakikadan 14 dakikaya çıkar, garajda geçen süre 25 dakikadan yaklaşık 9 dakikaya iner. Demoda yine üç karakter de görünür.

### Ö2 — Bölüm 8 (Teklifler), Tercüman ve Pazar yollarında boş kalıyor
- **Sorun:** Teklifler Mutfak (Kadri), Topçu (Urban), Bizans (Theodoros) ve Çandarlı'dan geliyor. **Yol B (Tercüman) ve Yol Y (Pazar)** oyuncularına kendi yollarına özel bir teklif gelmiyor. Bu yollar "daha az içerikli" hissettirir.
- **Öneri:**
  - **Yol B — Lütfi'nin teklifi:** *"Ortak, sultan Bizans'a bir elçi heyeti yolluyor. Tercüman olarak ben gidiyorum, sen de 'Frenk danışman' olarak gel."* Kabul edilirse Tolga ordugâh yolundan **Bizans'a** geçer. Bu, iki ana yolu birbirine bağlayan tek köprü olur ve ordugâh oyuncusuna Konstantinos'u görme şansı verir. Yeni bir dünya sonucu gerekmez, mevcut W3 (İki Hükümdar) yoluna bağlanır.
  - **Yol Y:** Ayrı bir teklif yerine, Çandarlı'nın adamı Yol Y'de **garanti** ortaya çıkar (pazar yerinde dolaştığı için onu tanır). Bu yol "Çandarlı yolu" olarak kimlik kazanır.

### Ö3 — Tolga'nın iç yolculuğu yok
- **Sorun:** Nihat kurala bağlılıktan empatiye geçiyor, bu net bir yay. Tolga ise "hayatı değişmez ve hiçbir şeyi fark etmez" kuralı yüzünden hiçbir şey öğrenmiyor. Komedi için iyi, ama 3 saatlik bir oyunda ana karakterin hiç değişmemesi finali boş bırakır.
- **Öneri:** **"Dış dünya değişmez, iç dünya biraz değişir."** Oyunun teması zaten bellidir: **bildiğini sanmak ile bilmek arasındaki fark.** Fatih'in en çok ödüllendirdiği şey dürüst bir "bilmiyorum"dur. Final sahnesinde tek küçük bir değişiklik: pazartesi toplantısında müdür bir soru sorar ve Tolga, oyunda ilk kez, *"Bilmiyorum. Araştırıp döneyim."* der. Müdür şaşırır. Kimse bunun nereden geldiğini bilmez. Bu satır, oyuncu huzurda dürüst olduysa oynar; olmadıysa Tolga yine kendinden emin bir saçmalık söyler.

### Ö4 — Hikmet'in yayı zayıf
- **Sorun:** Hikmet'in bölümleri görev odaklı (makineyi sakla, parça bul, pencereyi aç). Neden bu kadar uğraştığı yazılmamış.
- **Öneri:** Hikmet'e tek cümlelik bir geçmiş vermek: **makineyi yıllar önce kendisi için yapmıştır**, gençken bir yere gitmek istemiştir ama hiç cesaret edememiştir. Tolga'yı yollamak, kendi korkusunun bedelini başkasına ödetmektir. Bölüm 7'deki "makineye bin" kararı böylece Hikmet'in kendi korkusunu yenmesi anlamına gelir. Ana menüdeki *"Bir kere de ben gitsem?"* sorusu da bu yayın doğal sonu olur.

### Ö5 — Büronun kuruluş sırrı sadece tek yolda anlam kazanıyor
- **Sorun:** "Büronun kurucusu Tolga'ymış" sürprizi (Son 9) güçlü bir fikir ama sadece Arşiv dalında ortaya çıkıyor. Diğer yollarda hiç ipucu yok.
- **Öneri:** Bölüm 3'te, Nihat'ın Büro'daki odasının duvarında çerçeveli bir **Form Z-1** asılı olsun. İmza kısmında sadece **"T."** yazar. Nihat: *"Kurucumuz. Kimse kim olduğunu bilmiyor."* Arşiv yolunu görmeyen oyuncu için bu, bir sonraki bölümün gizemi olarak kalır; gören için tam bir döngü olur. Nihat'ın Tolga'ya karşı açıklanamayan sabrı da böylece anlam kazanır.

### Ö6 — Belgeler arasında eski kural metni kalmış
- **Sorun:** GDD §4, §6.3 ve §10'da hâlâ *"Tolga'nın hayatı hiçbir sonda değişmez, her son pazartesi servisiyle biter"* yazıyor. CHAPTERS.md ise T2 (1453'te kaldı) ve T3 (savruldu) kaderlerini ekledi. İki belge çelişiyor.
- **Öneri:** GDD'deki metinleri CHAPTERS §1'deki yeni kurala göre güncellemek.

### Ö7 — Detroit ciddiyeti ile Monty Python absürtlüğü çatışabilir
- **Sorun:** Detroit'in gücü duygusal gerilimden gelir, Monty Python'unki ise ciddiyeti sürekli kırmaktan. 3 saat boyunca iki ton birbirini sulandırabilir: ya hiçbir karar ağır gelmez ya da espriler duygusal anların önünü keser.
- **Öneri:** Bir **"ciddiyet bütçesi"** kuralı: **Her bölümde en fazla bir samimi an olur ve bu an en az 3 saniye bozulmadan kalır.** Sonra mizah geri döner. Mevcut örnek zaten bu kalıpta: Konstantinos'un mektubu okunur, sessizlik olur, sonra Sinerji mektubu gagalar. Bu kural yazılı olursa bütün bölümlere tutarlı uygulanır.

### Ö8 — Mizah yorgunluğu
- **Sorun:** 3 saatlik bir oyunda aynı espriler (fes, plaza dili, Hasan ile Hüseyin, "bütçe yetmedi") tekrar eder ve eskir.
- **Öneri:** Her tekrarlanan espri için bir **tırmanma planı**: ilk kez tanıtılır, ikinci kez tersine çevrilir, üçüncü kez karakterler espriyi kendileri fark eder. Örnek: Hasan ile Hüseyin 3. perdede birbirlerinin isim etiketlerini takmış olarak gelir, ama ters takmışlardır.

---

## 4. Küçük sorunlar

1. **Merak yüzdesi:** "Her Merak Puanı %25" deniyor, ama gizli son 3 Merak istiyor (%75). Ya %33 yapılmalı ya da "3 Merak = %100" diye yuvarlanmalı.
2. **Gösterge sayısı:** Şüphe, kimlik, şarj, Paradoks, Merak, Kural Sadakati, İlişki, Telsiz Bağı ve Büro Baskısı dahil **9 sistem** var. Oyuncu hepsini takip edemez. **Öneri:** Büro Baskısı ve Paradoks ekranda gösterilmesin, sadece akış şemasında görünsün (Paradoks zaten gizli, GDD §7.8).
3. **"Matbah-ı Âmire":** Bu terim saray mutfağı için kullanılır ve ordugâhtaki bir mutfak için tam oturmaz. Espri olarak kalabilir ("Kadri, unvanı kendi uydurur"), ama belgede bilinçli olduğu belirtilmeli.
4. **Sinerji sadece Bizans yolunda:** Gizli tavuk bölümüne sadece Bizans oyuncuları ulaşabiliyor. Ordugâh oyuncuları Sinerji'yi sadece bir göndermede görüyor. Bu kabul edilebilir, ama akış şemasında "başka bir yolda açılır" ipucu olmalı.
5. **Bölüm 10'da numarasız sonuç:** "10.x Niko araya girdi" sonucu numaralandırılmalı (10.6), yoksa akış şeması sistemi onu bir düğüm olarak göstermez.
6. **Eşya matrisinde eksik karakterler:** Tolga, Bölüm 10'da Nihat'a eşya gösterebiliyor (Nihat'ın tepkileri var), ama 1453'e gelen Hikmet'in (H3) eşya tepkileri yazılmadı.
7. **"Duka":** Urban ve Giustiniani'nin duka (düka altını) istemesi doğrudur. Ama Osmanlı karakterleri (Kadri, nöbetçiler) para konuşursa **akçe** demeli.
8. **Giustiniani'nin uyarılması:** Tarihte yaralanması şehrin düşüşünde kritik bir andır. Oyunda bunun şakası yapılmıyor, sadece paradoks tuzağı olarak kullanılıyor. Bu doğru. Yazım sırasında bu çizgi korunmalı.

---

## 5. Güçlü yanlar (korunması gerekenler)

- **Yanlış yüzyılın kostümü:** Kılık, espri ve oynanış mekaniği tek fikirde birleşiyor.
- **Eşya × karakter matrisi:** Tekrar oynamayı ödüllendiriyor ve paylaşılabilir anlar üretiyor.
- **Fatih'in ciddi karakter olması:** Hem saygılı hem daha komik. En iyi espriler Fatih'in Tolga'dan zeki olmasından çıkıyor ("O zaman üç yaşındaydım").
- **Nihat:** En iyi karakter. Bürokrasiden empatiye giden yolu hem komik hem dokunaklı.
- **"Kimse fark etmez" finalleri:** Tolga'nın hiçbir şeyi fark etmemesi güçlü ve özgün bir fikir.
- **Kırmızı düğme:** K1'deki garanti süresiyle birlikte hem şaka hem de mekanik olarak işe yarıyor.
- **Tarih doğruluğu:** Domates, deniz ateşi, termos, Rubik küpü gibi doğru bilgiler espri olarak kullanılıyor; oyun fark ettirmeden öğretiyor.

---

## 6. Öneri listesi

| # | Düzeltme | Öncelik | Etkilediği belgeler |
|---|----------|:-------:|---------------------|
| K1 | Kırmızı düğmeye 10 dakikalık garanti süresi | 🔴 Kritik | GDD, CHAPTERS, STORY_BRANCHES |
| K2 | Yönetmelik 7/c: anomali geldiği araçla iade edilir | 🔴 Kritik | CHAPTERS |
| K3 | Zaman oranı (1 saat = 1 gün) ve "pazar gecesi" | 🔴 Kritik | GDD, CHAPTERS |
| K4 | Kural Sadakati: başlangıç 60, eşik 35 | 🔴 Kritik | CHAPTERS |
| K5 | Telsiz-Kumanda: tek nesne, Bölüm 1'de tanıtılır | 🔴 Kritik | GDD, CHAPTERS, STORY_BRANCHES |
| K6 | Her yolda en az bir Fatih sahnesi | 🔴 Kritik | STORY_BRANCHES, CHAPTERS |
| Ö1 | Perde I'i yeniden sırala (1453'te daha fazla zaman) | 🟠 Önemli | CHAPTERS |
| Ö2 | Lütfi'nin teklifi (ordugâhtan Bizans'a köprü), Yol Y = Çandarlı yolu | 🟠 Önemli | CHAPTERS, STORY_BRANCHES |
| Ö3 | Tolga'nın "Bilmiyorum" anı | 🟠 Önemli | CHAPTERS, GDD |
| Ö4 | Hikmet'in geçmişi | 🟠 Önemli | GDD, CHAPTERS |
| Ö5 | Form Z-1 ve "T." imzası Bölüm 3'te | 🟠 Önemli | CHAPTERS |
| Ö6 | GDD'deki eski kural metnini güncelle | 🟠 Önemli | GDD |
| Ö7 | Ciddiyet bütçesi kuralı | 🟠 Önemli | GDD |
| Ö8 | Tekrarlanan espriler için tırmanma planı | 🟡 Normal | GDD |
| 4.1–4.8 | Küçük düzeltmeler | 🟡 Normal | Çeşitli |
