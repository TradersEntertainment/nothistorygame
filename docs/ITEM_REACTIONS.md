# Eşya Tepki Matrisi — v0.2

> GDD §7.2'deki **Göster matrisi**. Belge üç bölümden oluşur:
>
> 1. **[Temel tepkiler](#bölüm-1--temel-tepkiler):** 10 eşya × 12 karakter = 120 tepki. Özel bir hikaye koşulu yoksa bunlar oynar.
> 2. **[Hikaye seçimine göre varyantlar](#bölüm-2--hikaye-seçimine-göre-varyantlar):** Oyuncunun seçtiği yol, fes durumu, paradoks seviyesi, verdiği eşyalar ve önceki oyunlarına göre değişen tepkiler.
> 3. **[Seçim → sonuç matrisi](#bölüm-3--seçim--sonuç-matrisi):** Hikayedeki her karar noktası, sonuçları ve hangi yoldan hangi sona gidilebildiği.
>
> - **Türkçe** ve **English** sütunları birebir çeviri değildir. Espri her dilde ayrı kurulur (GDD §11).
> - **Etki** sütunu oyun mantığıdır: `Merak +1` (Fatih bulmacası), `Şüphe ±n`, `Paradoks +n`, `flag:ad` (ileride kullanılacak bayrak), `Ver:` (eşya karaktere bırakılırsa ne olur).
> - Etki sütunu boşsa tepki sadece espri içindir.
> - Bizans karakterleri (Niko hariç) Yunanca konuşur. Oyuncu altyazıyı `[Yunanca]` etiketiyle okur, Tolga anlamaz (GDD §4).

**Eşyalar:** 📱 Telefon · 🔥 Çakmak · 📘 Tarih Kitabı · 🥜 Leblebi · 🔋 Powerbank · 📦 Koli Bandı · ☕ Termos Çay · 🤳 Selfie Çubuğu · 🍋 Kolonya · 🧊 Rubik Küpü

**Karakterler:**
[1. Hikmet](#1-hikmet-amca--garaj) · [2. Hasan ile Hüseyin](#2-hasan-ile-hüseyin--nöbetçiler) · [3. Aşçıbaşı Kadri](#3-aşçıbaşı-kadri) · [4. Tercüman Lütfi](#4-tercüman-lütfi) · [5. Usta Urban](#5-usta-urban) · [6. Sorucu Ağa](#6-sorucu-ağa) · [7. Fatih](#7-sultan-ii-mehmed-fatih) · [8. Denetçi Nihat](#8-denetçi-nihat-zamanoğlu) · [9. Niko](#9-niko) · [10. Konstantinos](#10-imparator-xi-konstantinos) · [11. Giustiniani](#11-giovanni-giustiniani) · [12. Logothetes Theodoros](#12-logothetes-theodoros)

---

# Bölüm 1 — Temel tepkiler

## 1. Hikmet Amca — garaj
*Garajda eşyalara bakınca oynar (GDD §9.1). Oyuncu eşyayı seçmeden önce ne işe yarayabileceği hakkında ipucu verir.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | Tolga: "Şarj %14." Hikmet: "Yeter de artar evlât. Orada şarj aleti yok ama priz de yok. Adil yani." | Tolga: "Fourteen percent." Hikmet: "Plenty, son. No chargers there, but no sockets either. Fair's fair." | |
| 🔥 | "Al onu. İnsanlık ateşi bulmak için binlerce yıl uğraştı. Sen hazırını götür." | "Take it. Mankind spent millennia discovering fire. You just bring the finished product." | |
| 📘 | "Aç bak, sayfa 88'de Fatih'e bıyık çizmişsin. Zaten bıyığı vardı. İkinci bir bıyık çizmişsin." | "Look at page 88. You drew a moustache on the Sultan. He already had one. You gave him a spare." | |
| 🥜 | "Onu yeme, o benim gece leblebim. ...Tamam al. Diplomasi için." | "Don't touch those, that's my midnight snack. ...Fine. For diplomacy." | |
| 🔋 | "Onu ben şarj ettim. Kendi icadım olan şarj aletiyle. Sadece bir kere yandı." | "I charged that myself. With a charger of my own design. It only caught fire the once." | |
| 📦 | "Makinenin yüzde altmışı bundan. Kalanı umut." | "Sixty percent of that machine is this. The rest is hope." | |
| ☕ | "Demlik çay, iki şeker. Orada çay yoksa bile senin var." | "Proper brewed tea, two sugars. History might not have tea yet. You do." | |
| 🤳 | "Tarihi yazanlarla fotoğraf çekil. Kimse inanmaz ama olsun." | "Take selfies with the history makers. Nobody'll believe you, but still." | |
| 🍋 | "Limon kolonyası. Bizim milletin diplomatik dokunulmazlığı budur." | "Lemon cologne. It's the closest thing we have to diplomatic immunity." | EN notu: kolonya ikramı yabancı oyuncuya açıklanmalı |
| 🧊 | "Onu 1987'den beri çözemedim. Belki geçmişte biri çözer." | "Haven't solved it since 1987. Maybe someone in the past can." | Fatih'in çözeceğinin ipucu |

## 2. Hasan ile Hüseyin — nöbetçiler
*İki nöbetçi her tepkide birlikte konuşur. Kimin kim olduğu her seferinde tartışmalıdır.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | Hasan: "İçinde minik adam var!" Hüseyin: "Minik adam değil, minik Hasan." Hasan: "Hasan benim!" | Hasan: "There's a tiny man inside!" Hüseyin: "Not a tiny man. A tiny Hasan." Hasan: "*I'm* Hasan!" | Şüphe +1 |
| 🔥 | Hasan: "Büyücü!" Hüseyin: "Büyücü değil, çakmaktaşı bu. Sadece küçük ve hızlı." | Hasan: "Sorcerer!" Hüseyin: "It's flint, you dolt. Just small and quick." | Şüphe +1 |
| 📘 | Hasan: "Resimli kitap! Bizi de çizmişler mi?" Hüseyin: "Bak, yeniçeri. Hangisi sensin?" Hasan: "Soldaki." Hüseyin: "Soldaki benim." | Hasan: "A picture book! Did they draw us?" Hüseyin: "Look, Janissaries. Which one's you?" Hasan: "Left." Hüseyin: "Left is me." | |
| 🥜 | Hasan (yer): "Nohut ama kuru. Ama güzel." Hüseyin: "Bana da uzat. ...Casus böyle güzel şey getirmez." | Hasan (munching): "Chickpeas, but dry. But good." Hüseyin: "Pass them over. ...Spies don't bring snacks this nice." | Şüphe −1 |
| 🔋 | Hasan: "Bu taş sıcak!" Hüseyin: "Kutsal olabilir. Dokunma." Hasan: "Dokundum." | Hasan: "This stone is warm!" Hüseyin: "Could be holy. Don't touch it." Hasan: "Touched it." | |
| 📦 | Hüseyin: "Bununla ne bağlanır?" Tolga: "Her şey." Hasan: "Beni bağlama." | Hüseyin: "What does it tie?" Tolga: "Everything." Hasan: "Don't tie me." | Kullan: kaçış bulmacasında ikisini birbirine bantlamak (`flag:guards_taped`) |
| ☕ | İkisi birden: "Bu ne, otlu sıcak su mu?" (Bir yudum. Uzun bir sessizlik.) "...Beş dakika mola." | Both: "What's this, hot leaf water?" (A sip. A long silence.) "...Five minute break." | Şüphe sıfırlanır, `flag:guards_break` (5 dk) |
| 🤳 | Tolga fotoğraf çeker. Hasan: "Ruhumu mu aldın?" Hüseyin: "Senin ruhun yok ki Hasan." Hasan: "Ben Hüseyin'im!" | Tolga takes a photo. Hasan: "Did you steal my soul?" Hüseyin: "You haven't got one, Hasan." Hasan: "I'm Hüseyin!" | Fotoğraf albümü +1 |
| 🍋 | Hasan: "Limon mu? Limondan su mu olur?" Hüseyin (ellerini uzatır): "Bir daha." | Hasan: "Lemon? You can make water out of lemons?" Hüseyin (holding out his hands): "Again." | Şüphe −1 |
| 🧊 | İkisi küpü kapar. "Sen çevir." "Hayır sen." Küp giderek daha çok karışır. | They both grab it. "You turn it." "No, you." The cube gets progressively worse. | 20 sn dikkat dağıtma (`flag:guards_distracted`) |

## 3. Aşçıbaşı Kadri
*Yol A'nın anahtarı (GDD §9.3). Her şeye "tencereye girer mi" diye bakar.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Tencereye sığar mı? Sığmıyor mu? O zaman beni ilgilendirmez." | "Does it fit in a pot? No? Then it's none of my business." | |
| 🔥 | "Ocağı tek hamlede mi yakıyor? ...Evlâdım, sen bu mutfakta kalıyorsun." | "Lights the stove in one go? ...Son, you're staying in this kitchen." | Yol A ilerler |
| 📘 | "İçinde yemek tarifi yok mu? Tarifsiz tarih eksik yazılmış tarihtir." | "No recipes? History without recipes is just dates. ...Dates! Now *there's* a fruit." | EN'de "dates" kelime oyunu, TR'de farklı espri |
| 🥜 | "Nohut... ama kavrulmuş... ama kuru... ama çıtır! Bu bir devrim. Adı ne?" Tolga: "Leblebi." Kadri: "Leb-le-bi. Sultan'ın sofrasına!" | "Chickpeas... roasted... dry... *crunchy!* This is a revolution. What do you call it?" Tolga: "Leblebi." Kadri: "Leb-le-bi. To the Sultan's table!" | Yol A açılır. Ver: Paradoks +10, `flag:leblebi_given` (Leblebipolis sonu) |
| 🔋 | "Sıcak taş mı? Hamur bunun üstünde güzel mayalanır." | "A warm stone? Dough would rise lovely on that." | |
| 📦 | "Siz gelecekte dolmayı bununla mı sarıyorsunuz? Kötü bir yermiş gelecek." | "Is this how you wrap dolma in the future? Grim place, the future." | |
| ☕ | "Sıcağı saklayan testi mi? Çorba için isterim. Takas edelim: sana bir kaftan." | "A jug that keeps things hot? I need that for soup. Let's trade: one kaftan." | Ver: kaftan verir, yedek yolu kısaltır (`flag:has_kaftan`) |
| 🤳 | "Kepçenin sapı uzun olmuş ama kepçesi yok. Kötü kepçe." | "The ladle's all handle and no ladle. Terrible ladle." | |
| 🍋 | "Mutfağıma limon kokusu mu? ...Aslında hoş oldu." | "Lemon in *my* kitchen? ...Actually, that's rather nice." | Şüphe −1 |
| 🧊 | "Renkleri ayırıyorsun değil mi? Ben de bütün gün pilavla bulguru ayırıyorum. Aynı iş." | "Sorting colours, is it? I sort rice from bulgur all day. Same job." | |

## 4. Tercüman Lütfi
*Yol B'nin anahtarı. Yedi dil bildiğini iddia eder, her şeyi çevirmeye çalışır.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Bu kutu hangi dilde konuşuyor? ...Bilmediğim dil yoktur. Demek ki bu dil yok." | "Which language does this box speak? ...I know every language. So this one doesn't exist." | |
| 🔥 | (Yanındakilere tercüme eder) "Diyor ki: 'Ateşi cebimde taşırım.' Yani... tehlikeli bir adam." | (Translating to the crowd) "He says, 'I carry fire in my pocket.' So... a dangerous man." | Şüphe +1 |
| 📘 | "Türkçe ama tuhaf. 'Fatih Sultan Mehmet İstanbul'u 1453'te fethetti.' Fethetti mi? Geçmiş zaman mı? Şu an 1453! Bu bir kehanet kitabı!" | "It's Turkish, but odd. 'Mehmed conquered Constantinople in 1453.' *Conquered?* Past tense? It *is* 1453! This is a book of prophecy!" | Yol B ilerler, Paradoks +5 |
| 🥜 | "Bunun adını her dilde bilirim. Söylemeyeceğim. Ama biliyorum." | "I know the word for this in every language. I shan't say it. But I know it." | |
| 🔋 | (Etiketi okur) "'Hıtay'da yapılmıştır.' Hıtay'dan geldiysen yol uzun." | (Reading the label) "'Made in Cathay.' You've come a long way, friend." | |
| 📦 | "'Koli bandı.' Bunu çevirmeyeceğim. İsmi zaten mükemmel." | "'Duct tape.' I refuse to translate it. It's perfect as it is." | |
| ☕ | "'Termos'... Rumca 'sıcak' demek! Sonunda bildiğim bir kelime!" | "'Thermos'... that's Greek for 'hot'! Finally, a word I actually know!" | Lütfi'nin güveni artar, Yol B ilerler |
| 🤳 | "'Selfie' diyorsun. Yani kendi... resmini... kendin... Neden?" | "'Selfie,' you say. So you paint... yourself... by yourself... Why?" | |
| 🍋 | "Frenkler bunu sever. Demek ki sen gerçekten Frenk elçisisin." | "The Franks love this sort of thing. So you really *are* a Frankish envoy." | Fesliyken elçi kimliği pekişir, Yol B ilerler |
| 🧊 | "Macar icadı mı? Urban'a gösterme, yine top yapar." | "A Hungarian invention? Don't show Urban, he'll turn it into a cannon." | Yol C ipucu (Rubik küpü gerçekten Macar icadıdır) |

## 5. Usta Urban
*Yol C'nin anahtarı. Her şeyi "top olur mu" diye değerlendirir.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Bu kutu hesap yapıyor! İçinde cin var. Cini satın alırım. Kaç duka?" | "This box does sums! There's a djinn inside. I'll buy the djinn. How many ducats?" | Yol C açılır, Paradoks +5 |
| 🔥 | "Fitili tek seferde mi yakıyor? Yağmurda da mı? Bu adamı topçu yapın!" | "Lights a fuse first time? Even in rain? Make this man a gunner!" | Yol C ilerler |
| 📘 | Tolga sayfayı gösterir: "Büyük top çatladı." Urban: "Kitabı yazan topçu mu? Değil. O zaman sussun." | Tolga shows the page: "The great cannon cracked." Urban: "Was the author a gunner? No? Then he can keep quiet." | Şüphe +1 (Urban kırılır) |
| 🥜 | "Gülle mi bunlar? Çok küçük. Her şey çok küçük." | "Cannonballs? Too small. Everything is too small." | |
| 🔋 | "Ağır, sıcak, güçlü. Bunu topun içine koysak ne olur?" Tolga: "Lütfen koymayalım." | "Heavy, warm, powerful. What if we put it in the cannon?" Tolga: "Let's please not." | |
| 📦 | "Çatlağı yapışkan bezle mi kapatacağım? ...Deneyelim." | "Patch my crack with sticky cloth? ...Let's try it." | Ver: top bantlanır, Paradoks +20, `flag:cannon_taped` |
| ☕ | "Sıcağı saklayan kap mı? Bronz dökerken işime yarar." | "A vessel that keeps heat? Useful when casting bronze." | |
| 🤳 | "Uzun, ince, boş. Namlu için fazla ince. Değersiz." | "Long, thin, hollow. Too thin for a barrel. Worthless." | |
| 🍋 | (Koklar) "Topçu barut kokar. Sen bana limon mu sürüyorsun?" | (Sniffs) "A gunner smells of powder. You're putting *lemon* on me?" | Şüphe +1 |
| 🧊 | "Bu Macar mı? ...Macar. Hissediyorum. Vatanım." (Gözleri dolar) | "Is this Hungarian? ...It is. I can feel it. My homeland." (Welling up) | Urban'ın dostluğu, Yol C ilerler |

## 6. Sorucu Ağa
*Otağ kapısındaki bekçi. Üç soru sorar; bazı eşyalar soruları etkiler.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Bu kutu bana soru soruyormuş gibi bakıyor. Burada soruyu ben sorarım." | "That box is looking at me like it wants to ask a question. *I* ask the questions here." | |
| 🔥 | "Ateşi nereden aldın? Bu da bir soru. Cevap ver." | "Where did you get fire? That's also a question. Answer it." | Soru sayılmaz |
| 📘 | "Bu kitapta bir devenin günde kaç okka su içtiği yazıyor mu? Yazmıyorsa işe yaramaz." | "Does this book say how many measures of water a camel drinks a day? No? Useless." | 3. soru ipucu (kitapta yok) |
| 🥜 | "Birinci soru: Bu ne? İkinci soru: Bir tane daha verir misin?" | "Question one: what is this? Question two: may I have another?" | 1. soru leblebiyle geçilir |
| 🔋 | "Kutsal taş mı? Kutsal taşı olana bir soru az sorulur. ...Yine de üç soru." | "A holy stone? He who bears a holy stone is asked one question fewer. ...It's still three." | |
| 📦 | "Ağzımı bantlamayı aklından bile geçirme. Denediler." | "Don't even think about taping my mouth. It's been tried." | |
| ☕ | "Sorulardan önce bir yudum. ...Güzel. Şimdi üç soru." | "A sip before the questions. ...Lovely. Now: three questions." | |
| 🤳 | "Asa! Asası olan bilgedir. Bilgeye iki soru yeter." | "A staff! A man with a staff is wise. Two questions will do for the wise." | 1 soru atlanır (GDD §9.6) |
| 🍋 | "Kokulu adam. Soru: Neden kokulusun?" | "A fragrant man. Question: why are you fragrant?" | |
| 🧊 | "Bulmaca mı bu? Burada bulmacayı ben sorarım. Kıskandım." | "Is that a puzzle? *I* do the puzzles around here. I'm jealous." | |

## 7. Sultan II. Mehmed (Fatih)
*Ciddi karakter (GDD §4). Espri ondan değil, Tolga'nın ona karşı durumundan çıkar. Merak Puanları buradan gelir.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Işık saçan bir levha, hesap yapıyor. Nasıl çalıştığını anlat. ...Anlatamıyor musun? Taşıdığın şeyi bilmiyorsun." | "A glowing tablet that calculates. Explain how it works. ...You can't? You carry a thing you don't understand." | Merak +1 (hesap makinesi açılırsa) |
| 🔥 | "Çakmaktaşıyla demir, küçültülmüş. Güzel. Ama savaşları çakmak kazanmaz." | "Flint and steel, made small. Clever. But wars aren't won with lighters." | |
| 📘 | (Sayfaları çevirir) "Burnumu büyük çizmişler. ...Bütün bir hayatı iki satıra sığdırmışlar." | (Turning pages) "They've made my nose rather large. ...And fit an entire life into two lines." | Merak +1, Paradoks +10, `flag:book_shown_sultan` (Leblebipolis sonu) |
| 🥜 | "Kavrulmuş nohut. Askerin taşıması kolay, bozulmaz. Bunu kim düşündü?" | "Roasted chickpeas. Light for a soldier to carry, and they keep. Whose idea was this?" | Kadri'ye verildiyse Leblebipolis sonu güçlenir |
| 🔋 | "Taş gibi ama taş değil. İçinde ne var?" Tolga: "Elektrik." Fatih (not alır): "Elektrik." | "Like a stone, yet not a stone. What's inside?" Tolga: "Electricity." Mehmed (noting it down): "Electricity." | Paradoks +5 |
| 📦 | "Yapışıyor, kopuyor, yine yapışıyor. Her mühendisin rüyası. Kaç tane var?" | "It sticks, it tears, it sticks again. Every engineer's dream. How much do you have?" | `flag:tape_shown_sultan` (gizli son) |
| ☕ | "Sıcağı saklayan bir kap. İlginç. Tadı ise... Sizin zamanınızda bunu herkes mi içiyor?" | "A vessel that keeps its heat. Curious. And the taste... Does everyone in your time drink this?" | |
| 🤳 | Tolga: "Hatıra fotoğrafı?" Fatih: "Ressamım var. Ama... bakayım. Kendi yüzümü bu kadar küçük görmemiştim." | Tolga: "Commemorative photo?" Mehmed: "I have a painter. But... let me see. I've never seen my face so small." | Fotoğraf albümü +1 (nadir) |
| 🍋 | Elini uzatır. "Limon. Güzel bir âdet. Sizin zamanınızda herkes bunu mu yapıyor?" Tolga: "Bayramlarda." | Holds out his hands. "Lemon. A pleasant custom. Is this done by everyone in your time?" Tolga: "On holidays." | Huzurda bonus diyalog seçeneği |
| 🧊 | (Kırk saniye) "Altı yüz, dokuz parça, bir kural. ...İşte." Tolga: "Ben bununla otuz yıldır..." Fatih: "Otuz yıl mı?" | (Forty seconds) "Six faces, nine pieces, one rule. ...There." Tolga: "I've been at that for thirty years..." Mehmed: "Thirty *years?*" | Merak +1, `flag:cube_solved_sultan` (gizli son) |

## 8. Denetçi Nihat Zamanoğlu
*Paradoks eşiği aşılınca belirir. Her eşyayı bir forma bağlar.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Anakronik iletişim cihazı. Form Z-12. Şarj yüzdesini de yazın." | "Anachronistic communication device. Form Z-12. Please include battery percentage." | |
| 🔥 | "Çakmak, 20. yüzyıl. Form Z-20, ek B." | "Lighter, twentieth century. Form Z-20, annex B." | |
| 📘 | "Geleceğe ait bilgi içeren basılı materyal. En ağır ihlal. ...Sayfa 88'deki bıyık da size mi ait?" | "Printed material containing future knowledge. The gravest violation. ...Is the moustache on page 88 also yours?" | Paradoks +5 |
| 🥜 | "Gıda maddeleri serbesttir. ...Bir tane alabilir miyim? Kayıt dışı." | "Foodstuffs are exempt. ...Might I have one? Off the record." | Form mini oyununda 1 hata affı |
| 🔋 | "Lityum pil. Zaman yolculuğunda da uçaktaki gibi kabin bagajında taşınmalıdır." | "Lithium battery. As with air travel, it must be carried in hand luggage when time travelling." | |
| 📦 | "Makinenizin yüzde altmışı bu. Biliyoruz. Dosyanızda yazıyor." | "Sixty percent of your machine is this. We know. It's in your file." | |
| ☕ | "Çay. 1453'te çay yok. Ama ben de içiyorum. İkimiz de kuralı çiğniyoruz. Bu aramızda kalsın." | "Tea. There is no tea in 1453. But I'm drinking it too. We are both in breach. Let's keep this between us." | Form mini oyununda süre +30 sn |
| 🤳 | "Kanıt oluşturma cihazı. Fotoğrafları silmeniz gerekecek. ...Beni de çekmişsiniz." | "Evidence-generating device. You'll have to delete those photos. ...You've photographed me as well." | Fotoğraf albümü +1 (sadece bu yolla) |
| 🍋 | "Kolonya, 18. yüzyıl. ...Ama ellerim kurudu. Bir damla." | "Cologne, eighteenth century. ...But my hands are rather dry. Just a drop." | |
| 🧊 | "1974, Macaristan. Beyan edilmemiş. ...Çözebilen biri var mı? Bizim büroda kimse çözemedi." | "1974, Hungary. Undeclared. ...Has anyone actually solved it? No one at our bureau has." | |

## 9. Niko
*Bizans askeri, çarşı Türkçesi konuşur (GDD §5.11). Tolga'yı "casus" sanar ama ona bağlanır.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Küçük ayna ama içinde adam var! Hey adam! Annen de mi ayna?" | "Tiny mirror with a man inside! Oi, man! Was your mother a mirror too?" | |
| 🔥 | "Deniz ateşi mi bu?! Cebinde mi taşıyorsun? Casus! Büyük casus!" Tolga (kendi kendine): "Rum ateşi... tamam, belgeselini izlemiştim." | "Is that sea fire?! In your *pocket?* Spy! Big spy!" Tolga (aside): "Greek fire... right, I saw a documentary." | Fesliyken Şüphe +2 |
| 📘 | "Harfler çok düz. Bunu kim yazdı, cetvel mi?" | "The letters are so straight. Who wrote this, a ruler?" | |
| 🥜 | "Nohut! Kavrulmuş! Kırk gündür kuru ekmek yiyorum. Sen... sen iyi casussun." | "Chickpeas! Roasted! Forty days I've eaten dry bread. You... you're a good spy." | Niko'nun dostluğu, Bizans'ta Şüphe −2 |
| 🔋 | "Fırlatmak için güzel taş. Surdan atayım mı?" | "Nice throwing stone. Shall I chuck it off the wall?" | |
| 📦 | "Surun çatlaklarını bununla kapatalım. ...Kapatmaz mı? O zaman geleceklilerin nesi var?" | "Let's patch the wall cracks with it. ...It won't? Then what good are you future people?" | |
| ☕ | "Sıcak ama tencere değil! Sihirli testi! İmparatora götür, madalya verir. Bana da iki madalya." | "Hot, but not a pot! Magic jug! Take it to the Emperor, he'll give you a medal. Get me two." | |
| 🤳 | Niko poz verir, tavuk Sinerji de kadraja girer: "Tavuğu da çek. Tavuk Bizanslı." | Niko strikes a pose; Sinerji the chicken wanders in. "Get the chicken in. The chicken is Byzantine." | Fotoğraf albümü +1 |
| 🍋 | "Limon! Venedikliler gibi kokuyorsun. Venedikliler iyidir, gemileri var. Sen gemisizsin." | "Lemon! You smell like a Venetian. Venetians are good, they have ships. You have no ship." | |
| 🧊 | "Renkli kutu, dönüyor. Ver oynayayım. ...Kırıldı. Zaten kırıktı senin kutun." | "Colourful box that twists. Give it here. ...It broke. Your box was already broken." | |

## 10. İmparator XI. Konstantinos
*Ciddi karakter (GDD §4, §5.12). Kısa, onurlu, yorgun. Tepkiler espriden çok bir tebessüm ya da sessizlik taşır. Yunanca konuşur; Niko ya da çeviri uygulaması aracılığıyla anlaşılır.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | [Yunanca] (Uzun uzun bakar) "Işık, ama ateş değil. Demek dünya değişecek. İyiye mi?" | [Greek] (A long look) "Light, but not fire. So the world will change. For the better?" | |
| 🔥 | [Yunanca] "Küçük bir ateş. Bu şehir yeterince ateş gördü, yabancı." | [Greek] "A small fire. This city has seen enough fire, stranger." | |
| 📘 | *Kitabı kapatır ve tek kelime etmeden geri verir.* Tolga: "...Özür dilerim." | *He closes the book and hands it back without a word.* Tolga: "...I'm sorry." | Paradoks +10 |
| 🥜 | [Yunanca] "Askerlerime götürebilir miyim? ...Teşekkür ederim." | [Greek] "May I take these to my soldiers? ...Thank you." | Ver: Paradoks +5, Niko'nun dostluğu kesinleşir |
| 🔋 | [Yunanca] "Ağır bir taş. Taşımız eksik değil, yabancı. Surlarımız taştan." | [Greek] "A heavy stone. We have no shortage of stone, stranger. Our walls are made of it." | |
| 📦 | [Yunanca] "Surlarımızı bin yıldır taşla onarırız. Bu, bin yıl dayanır mı?" Tolga: "...Garantisi iki yıl." | [Greek] "We have mended our walls with stone for a thousand years. Will this last a thousand?" Tolga: "...It's got a two-year warranty." | |
| ☕ | [Yunanca] (Kabul eder, bir yudum alır) "Sıcak. Uzun zamandır sıcak bir şey içmemiştim. Sağ ol." | [Greek] (Accepts, takes a sip) "Warm. It has been some time since I drank anything warm. Thank you." | |
| 🤳 | [Yunanca] "Bir imparatorun hatırası mı? Sende kalsın. Birinin hatırlaması iyi." | [Greek] "A keepsake of an emperor? Keep it. It is good that someone remembers." | Fotoğraf albümü +1 (nadir) |
| 🍋 | Konstantinos elini uzatmaz. Niko elini uzatır: "İmparator elini vermez. Ben veririm." | The Emperor does not offer his hands. Niko offers his: "The Emperor doesn't do hands. I do." | |
| 🧊 | [Yunanca] "Şu an bulmacaya ihtiyacım yok." | [Greek] "I have enough puzzles at present." | |

## 11. Giovanni Giustiniani
*Cenevizli komutan. Her şeye sözleşme ve kâr gözüyle bakar. 💼 Plaza seçenekleri onda işe yarar.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Parlak, pahalı görünüyor. Kaç duka? Satmayacaksan konuşmayalım." | "Shiny. Looks expensive. How many ducats? If it's not for sale, we're done." | |
| 🔥 | "Kaç tane var? Yüz tane getirirsen sözleşme yaparız." | "How many do you have? Bring me a hundred and we'll draw up a contract." | |
| 📘 | Tolga 29 Mayıs sayfasını gösterir. Giustiniani: "Adım yazıyor mu? ...Yazıyor mu?" | Tolga shows the page for 29 May. Giustiniani: "Is my name in there? ...Is it?" | Uyarma seçeneğini açar (GDD §5.13): seçilirse Paradoks +30, Denetçi hemen gelir |
| 🥜 | "Cenova'da bunu satarız. Yüzde kaç komisyon?" | "We could sell these in Genoa. What's your commission?" | |
| 🔋 | "Ağır, tuhaf bir taş. Gemi safrası olarak iş görür." | "Heavy, strange stone. Would make decent ballast." | |
| 📦 | "Sözleşme mühürlerini bununla yapıştırırsan kimse açamaz. Güzel." | "Seal a contract with this and nobody's opening it. Nice." | |
| ☕ | "Sıcak ve kapalı. Cenova'ya ihraç ederim. İhraç hakkı kimde?" | "Hot, and sealed. I'd export this to Genoa. Who holds the rights?" | |
| 🤳 | "Resmimi yapıyorsan ücret var." | "If you're making my portrait, there's a fee." | |
| 🍋 | "Cenovalılar da güzel koku sever. Bir şişesi ne kadar?" | "Genoese appreciate a fine scent too. What's it cost per bottle?" | 💼 "Savaş sigortası poliçesi" diyaloğunu açar |
| 🧊 | "Oyun. Askerlerim bununla oyalanırsa nöbette uyumazlar. Otuz tane isterim." | "A game. If my men fiddle with these, they won't doze on watch. I'll take thirty." | |

## 12. Logothetes Theodoros
*Bizans bürokrasisi (GDD §5.14). Yunanca konuşur. Her şeyi bir odaya, bir forma, bir güne yönlendirir. Bizans Labirenti'nde ipucu verir.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | [Yunanca] "Bu belgenin mührü yok. Mühürsüz belge yoktur." | [Greek] "This document is unsealed. An unsealed document does not exist." | |
| 🔥 | [Yunanca] "Arşivimde ateş mi? Dışarı. Sonra tekrar sıraya girin." | [Greek] "Fire? In my archive? Out. Then rejoin the queue." | Şüphe +1, Labirent bir oda geri |
| 📘 | [Yunanca] "Kaç nüsha? Bir mi? Yedi olmalı." | [Greek] "How many copies? One? There should be seven." | |
| 🥜 | [Yunanca] "Yiyecekler gümrük odasına. Üçüncü kat. Salı günleri." | [Greek] "Foodstuffs go to the customs office. Third floor. Tuesdays." | |
| 🔋 | [Yunanca] "Kâğıt ağırlığı olarak kabul edilmiştir. Teşekkürler." (Masasına koyar) | [Greek] "Accepted as a paperweight. Thank you." (Places it on his desk) | Ver: eşya kaybedilir, Labirent'te 1 mühür kazanılır |
| 📦 | [Yunanca] "Mühürleri bununla birleştirmek sahteciliktir. Sahtecilik formu dördüncü odada." | [Greek] "Joining seals with this constitutes forgery. Forgery forms are in the fourth room." | Kullanılırsa Labirent başa döner |
| ☕ | [Yunanca] "Sıcak içecek... (bir yudum) ...Bu belgeyi bugün işleme alırım." | [Greek] "A hot drink... (a sip) ...I shall process this document today." | Labirent'te bir oda atlanır |
| 🤳 | [Yunanca] "Kendi portrenizi mi yapıyorsunuz? Portre izni ikinci odada." | [Greek] "You are making your own portrait? Portrait permits are in the second room." | |
| 🍋 | [Yunanca] "Hoş bir koku. Memurlara hediye vermek yasaktır." (Şişeyi cebine koyar) | [Greek] "A pleasant scent. Gifts to officials are forbidden." (Pockets the bottle) | Ver: eşya kaybedilir, Şüphe −2 |
| 🧊 | [Yunanca] "Renklere göre sınıflandırma. Kusursuz bir arşiv sistemi. Bunu kim tasarladı?" | [Greek] "Classification by colour. A flawless archival system. Who designed this?" | 💼 "akış şeması" seçeneği güçlenir, Labirent'te mühür sırası ipucu |

---

## Özet: Etkili tepkiler

Oyun mantığı açısından önemli olan tepkiler (tasarım ve test için hızlı liste):

| Etki | Nereden |
|------|---------|
| **Fatih Merak Puanı** | 📱 (hesap makinesi), 📘, 🧊 → Fatih |
| **Gizli son bayrakları** | 📦 → Fatih, 🧊 → Fatih, 📱 → Fatih |
| **Leblebipolis bayrakları** | 🥜 Ver → Kadri, 📘 → Fatih |
| **Yol A (Mutfak)** | 🥜, 🔥 → Kadri; ☕ Ver → Kadri (kaftan) |
| **Yol B (Tercüman)** | 📘, ☕, 🍋 → Lütfi |
| **Yol C (Topçu)** | 📱, 🔥, 🧊 → Urban; 🧊 → Lütfi (ipucu) |
| **Nöbetçi kaçışı** | ☕ (mola), 🧊 (dikkat dağıtma), 📦 (bantlama) → Hasan ile Hüseyin |
| **Sorucu Ağa kestirmeleri** | 🤳 (1 soru atlanır), 🥜 (1. soru geçilir) |
| **Bizans Labirenti** | ☕ (oda atla), 🔋 Ver (mühür), 🧊 (ipucu); 🔥 ve 📦 cezalı |
| **Büyük paradoks** | 📦 Ver → Urban (+20), 📘 → Giustiniani uyarısı (+30), 📘 → Fatih / Konstantinos (+10) |
| **Şüpheyi azaltan** | 🥜, 🍋 (Osmanlı); 🥜 → Niko, 🍋 → Theodoros (Bizans) |

---

# Bölüm 2 — Hikaye seçimine göre varyantlar

## 2.0 Nasıl çalışır

### Seçim boyutları
Bir tepkiyi değiştirebilen hikaye durumları:

| Boyut | Değerler | Nereden gelir |
|-------|----------|---------------|
| **Yol** | 🍲 **A** Mutfak · 🗣️ **B** Tercüman · 💣 **C** Topçu · 🐐 **Y** Yedek (pazar/kaftan) · 🏛️ **Bz** Bizans | Haliç ayrımı (GDD §9.2) ve ordugâhta seçilen yol (§9.3) |
| **Fes** | 🎩 takılı · 🚫 çıkarılmış | H tuşu, anlık (GDD §7.5) |
| **Paradoks** | 🟢 0–29 · 🟡 30–59 · 🟠 60–89 · 🔴 90+ | Paradoks Metresi (GDD §7.8) |
| **Bayrak** | `leblebi_given`, `cannon_taped`, `niko_friend`, `giustiniani_warned`, `letter_opened`, `nihat_met`, `maze_rooms≥4`... | Önceki Ver/Kullan kararları |
| **Meta** | Önceki oyunlarda görülen sonlar | Meta kayıt (GDD §6.4) |

### Öncelik kuralı
Birden fazla varyant tutarsa **en özel olan** oynar:

1. **Bayrak** varyantı
2. **Paradoks 🔴** varyantı (dünya kırılıyorsa her şeyi ezer)
3. **Yol** varyantı
4. **Fes** varyantı
5. **Meta** varyantı
6. **Temel** tepki (Bölüm 1)

Motor tarafında anahtar şöyle aranır: `REACT_FATIH_PHONE@flag:x` → `@paradox:red` → `@route:a` → `@fez:off` → `@meta:x` → `REACT_FATIH_PHONE`. İlk bulunan oynar.

### Varsayılan durum
Bölüm 1'deki temel tepkiler şu durumu varsayar: **fes takılı**, yol henüz seçilmemiş, paradoks 🟢/🟡. Bizans karakterlerinin temel tepkileri de fes takılı hâli (Tolga = "Türk casusu") içindir. Tek istisna Giustiniani'dir: onun temel tepkileri **fessiz** hâl içindir.

### Hangi karakter hangi yolda
| Karakter | 🍲 A | 🗣️ B | 💣 C | 🐐 Y | 🏛️ Bz |
|----------|:---:|:---:|:---:|:---:|:---:|
| Hikmet (garaj) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Hasan ile Hüseyin | ✅ | ✅ | ✅ | ✅ | ✅ otağda onur muhafızı |
| Aşçıbaşı Kadri | ✅ | ✅ | ✅ | ✅ | ❌ |
| Tercüman Lütfi | ✅ | ✅ | ✅ | ✅ | ✅ otağda elçinin tercümanı |
| Usta Urban | ✅ | ✅ | ✅ | ✅ | ❌ |
| Sorucu Ağa | ✅ | ✅ | ✅ | ✅ | ✅ arkandan koşar |
| Fatih | ✅ | ✅ | ✅ | ✅ | ✅ |
| Denetçi Nihat | 🟠🔴 | 🟠🔴 | 🟠🔴 | 🟠🔴 | ✅ Labirent cameo + 🟠🔴 |
| Niko · Konstantinos · Giustiniani · Theodoros | ❌ | ❌ | ❌ | ❌ | ✅ |

### Sayım
| Karakter | Varyant sayısı |
|----------|---------------:|
| Fatih | 55 |
| Tercüman Lütfi | 10 |
| Hasan ile Hüseyin | 8 |
| Aşçıbaşı Kadri | 8 |
| Sorucu Ağa | 7 |
| Denetçi Nihat | 7 |
| Niko | 7 |
| Usta Urban | 6 |
| Giustiniani | 6 |
| Logothetes Theodoros | 6 |
| Hikmet | 5 |
| Konstantinos | 5 |
| **Toplam** | **130** (temel 120 ile birlikte **250** tepki) |

---

## 2.1 Fatih — yola göre (50 varyant)
*Fatih'in tepkileri Tolga'nın huzura **nasıl** geldiğine göre değişir. Merak ve bayrak etkileri, aksi belirtilmedikçe temel tepkiyle aynıdır (Bölüm 1 §7).*

> **Karakter notu:** Fes durumu Fatih'in tepkilerini değiştirmez. Fatih insanları kıyafetlerine göre yargılamaz. Tek istisna GDD §5.3'teki *"Bu başlık... kimin icadı?"* repliğidir.

### 🍲 Yol A — aşçı yamağı olarak, elinde leblebi tepsisiyle
| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Aşçının cebinden ışık saçan bir levha çıkıyor. Mutfağımda başka neler oluyor?" | "A glowing tablet from a cook's pocket. What else goes on in my kitchen?" | Merak +1 (hesap makinesi) |
| 🔥 | "Ocak için mi taşıyorsun? ...Hayır. Sen aşçı değilsin." | "For lighting the stove? ...No. You're no cook." | Kılık düşer (`flag:cover_blown`), Merak ±0 |
| 📘 | "Bir aşçı yamağı kitap okuyor. Üstelik geleceğin kitabını. Mutfağımı ciddi olarak denetlemeliyim." | "A kitchen boy who reads. And the future, no less. I must inspect my kitchens more closely." | Temel etki |
| 🥜 | "Tepside getirdin, şimdi de cebinden çıkarıyorsun. Kadri'nin buluşu olmadığını anlamıştım zaten." | "You brought them on the tray, and now from your pocket. I suspected this wasn't Kadri's invention." | Leblebipolis güçlenir |
| 🔋 | "Tepside taş mı taşıyorsun? Kadri yeni bir ekmek mi deniyor?" | "Carrying stones on the tray now? Is Kadri trying a new bread?" | |
| 📦 | "Kadri'nin dolmaları bununla sardığını söyleme bana." | "Please don't tell me Kadri wraps dolma with this." | Temel etki |
| ☕ | "Kadri bunu çorba için istemiştir. Vermedin mi? Akıllısın." | "Kadri will have wanted this for his soup. You didn't give it to him? Wise." | |
| 🤳 | "Sizin zamanınızda aşçılar da mı resim yapar?" Tolga: "Özellikle aşçılar." | "Do cooks make portraits in your time?" Tolga: "Cooks mostly." | Fotoğraf albümü +1 |
| 🍋 | "Yemekten sonra limon. Doğru sıra. Kadri'den iyi usul biliyorsun." | "Lemon after the meal. The correct order. Your manners are better than Kadri's." | Temel etki |
| 🧊 | (Çözer) "Pilavla bulguru ayırmaktan zor değil. Kadri'ye söyleme." | (Solves it) "No harder than sorting rice from bulgur. Don't tell Kadri." | Temel etki |

### 🗣️ Yol B — Frenk elçisi olarak, Lütfi'nin tercümanlığında
*Espri: Lütfi, ikisi de Türkçe konuşmasına rağmen tercüme etmekte ısrar eder.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | Lütfi: "Elçi diyor ki: 'Bu kutu... kutu.'" Fatih: "Lütfi, adam Türkçe konuşuyor." Lütfi: "Frenk aksanıyla, efendim." | Lütfi: "The envoy says: 'This box is... a box.'" Mehmed: "Lütfi, the man is speaking Turkish." Lütfi: "With a Frankish accent, my lord." | Merak +1 (hesap makinesi) |
| 🔥 | "Frenk elçisi hediye olarak ateş mi getirdi? Mesajı açık." Tolga: "Yok yok, mesaj yok!" | "The Frankish envoy brings fire as a gift? The message is clear." Tolga: "No, no, there's no message!" | Paradoks +5 |
| 📘 | Lütfi: "Kehanet kitabı, efendim, size bahsetmiştim." Fatih: "Kehanet değil Lütfi. Tarih. Biri olanı yazmış. Sadece... henüz olmamış." | Lütfi: "The book of prophecy, my lord, as I said." Mehmed: "Not prophecy, Lütfi. History. Someone wrote down what happened. It simply... hasn't yet." | Temel etki |
| 🥜 | "Frenkler artık nohut mu kavuruyor? Dünya bildiğimden hızlı değişiyor." | "The Franks roast chickpeas now? The world is changing faster than I knew." | |
| 🔋 | Lütfi: "'Hıtay'da yapılmış', efendim." Fatih: "Bir Frenk elçisi Hıtay malı taş getiriyor. Ticaret yolların ilginç." | Lütfi: "'Made in Cathay,' my lord." Mehmed: "A Frankish envoy bearing Cathay stones. Your trade routes are intriguing." | |
| 📦 | "Frenk saraylarında her şey bununla mı bağlanıyor? Kaç tane var?" | "Is everything in Frankish courts held together with this? How much do you have?" | Temel etki |
| ☕ | Lütfi: "Termos, efendim. Rumca 'sıcak' demek." Fatih: "Biliyorum Lütfi." (Lütfi kırılır) | Lütfi: "Thermos, my lord. Greek for 'hot'." Mehmed: "I know, Lütfi." (Lütfi is crushed) | |
| 🤳 | Lütfi: "Elçi sizi... kendi resmine koymak istiyor." Fatih: "Önce sen çekil Lütfi. Sonra bakarız." | Lütfi: "The envoy wishes to place you... in his own portrait." Mehmed: "Try it on yourself first, Lütfi. Then we'll see." | Fotoğraf albümü +1 (Lütfi'yle) |
| 🍋 | "Bu âdeti Frenkler mi bizden aldı, biz mi onlardan?" Tolga: "Aslında... ikiniz de değil." | "Did the Franks take this custom from us, or we from them?" Tolga: "Actually... neither of you." | Temel etki |
| 🧊 | Lütfi: "Macar icadı efendim. Urban'a göstermeyin demiştim." Fatih (çözer): "Urban zaten çözemezdi." | Lütfi: "A Hungarian invention, my lord. I said not to show Urban." Mehmed (solving it): "Urban couldn't have solved it anyway." | Temel etki |

### 💣 Yol C — Urban'ın çırağı olarak, top denemesinden sonra
| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Sahada Urban'ı ağlatan 'cin' bu mu? Kolay iş değil." | "Is this the 'djinn' that made Urban weep on the field? No small feat." | Merak +1 |
| 🔥 | "Topçuya lazım olan tam bu. Urban gördü mü? Görmesin, ister." | "Exactly what a gunner needs. Has Urban seen it? Keep it from him, he'll want it." | |
| 📘 | "Topun çatlayacağını bu kitap mı söyledi? ...Ona söyledin, değil mi? Dinlemedi. Doğru." | "Did this book say the cannon would crack? ...You told him, didn't you? He didn't listen. Of course." | Temel etki |
| 🥜 | "Gülle mi? Urban'a göre çok küçük, eminim." | "Cannonballs? Too small for Urban, I'm sure." | |
| 🔋 | "Bunu topa koymak istedi, değil mi?" Tolga: "Nereden bildiniz?" Fatih: "Urban'ı tanıyorum." | "He wanted to put this in the cannon, didn't he?" Tolga: "How did you know?" Mehmed: "I know Urban." | |
| 📦 | `cannon_taped` ise: "Topu bununla bantladığını sahada gördüm. Hâlâ duruyor. Kaç tane var?" Değilse temel tepki. | If `cannon_taped`: "I saw you tape the cannon with this. It's still holding. How much do you have?" Otherwise base line. | `cannon_taped` ise Merak +1 + temel etki |
| ☕ | "Döküm için mi taşıyorsun? ...Hayır, içiyorsun. Topçular tuhaf insanlar." | "For the casting? ...No, you're drinking it. Gunners are strange people." | |
| 🤳 | "Top denemesinde de bunu tutuyordun. Topun yanında durmak cesaret ister. Ya da cehalet." | "You held this during the cannon test too. Standing beside a cannon takes courage. Or ignorance." | Fotoğraf albümü +1 |
| 🍋 | "Barut kokusuna limon. Urban kızmıştır." Tolga: "Kızdı." | "Lemon over gunpowder. Urban must have been furious." Tolga: "He was." | Temel etki |
| 🧊 | (Çözer) "Urban bunun Macar olduğunu söyledi mi? Ağladı mı?" Tolga: "Biraz." | (Solves it) "Did Urban say it was Hungarian? Did he weep?" Tolga: "A bit." | Temel etki |

### 🐐 Yol Y — kaftanlı, pazardaki üç iyilikten sonra
*Fatih'in adamları pazardaki "keçiyi yakalayan tuhaf adamı" ona anlatmıştır.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Keçiyi yakalayan adam sen misin? Keçiyi bununla mı büyüledin?" | "So you're the man who caught the goat. Did you bewitch it with this?" | Merak +1 (hesap makinesi) |
| 🔥 | "Pazarda ateş yakan kaftanlı adam. Adamlarım anlattı." | "The man in the kaftan who makes fire in the market. My men told me." | |
| 📘 | "Pazarda bir askerin mektubunu yazmışsın. Bu kitaptaki gibi düz harflerle mi?" Tolga: "Evet." Fatih: "Asker okuyabildi mi?" Tolga: "...Hayır." | "You wrote a soldier's letter in the market. In straight letters like these?" Tolga: "Yes." Mehmed: "Could he read it?" Tolga: "...No." | Temel etki |
| 🥜 | "Pazarda bunu dağıttığını duydum. Ordumun yarısı nohut kokuyor." | "I hear you handed these out in the market. Half my army smells of chickpeas." | Leblebipolis güçlenir |
| 🔋 | "Kayıp mühür yüzüğünü bulan sensin. Bu taşı da bir yerde mi buldun?" | "You're the one who found the lost signet ring. Did you find this stone somewhere too?" | |
| 📦 | "Keçiyi bununla mı bağladın?" Tolga: "...Evet." | "Did you tie the goat with this?" Tolga: "...Yes." | Temel etki |
| ☕ | "Kaftanın altında Frenk ceketi, elinde sıcak su. Kim olduğunu hâlâ çözemedim." | "A Frankish coat under a kaftan, hot water in hand. I still can't work out who you are." | |
| 🤳 | "Pazardaki herkesin resmini bununla yapmışsın. Keçinin de." | "You made portraits of the whole market with this. And the goat." | Fotoğraf albümü +1 |
| 🍋 | "Pazarcılar bundan bahsediyor. Hepsi elini uzatmış." | "The merchants talk of nothing else. They all held out their hands." | Temel etki |
| 🧊 | (Çözer) "Pazarda bununla bahse girip kaybettiğini duydum." | (Solves it) "I hear you wagered on this in the market. And lost." | Temel etki |

### 🏛️ Yol Bz — Bizans'tan elçi olarak, elinde mektup, yanında Sinerji
*Bu yolda Fatih'in tonu biraz daha ağırdır: karşısında surların içini görmüş biri vardır.*

| Eşya | Türkçe | English | Etki |
|------|--------|---------|------|
| 📱 | "Bizans'tan gelen elçinin cebinde ne Rum ne Türk bir cihaz. Hangi tarafın adamısın?" Tolga: "Sigorta sektörü." | "An envoy from Byzantium, carrying a device neither Greek nor Turkish. Whose man are you?" Tolga: "Insurance sector." | Merak +1 (hesap makinesi) |
| 🔥 | "Rumların deniz ateşini mi getirdin?" Tolga: "Hayır, bu sadece çakmak." Fatih: "Rahatladım. Biraz da hayal kırıklığına uğradım." | "Have you brought the Greeks' sea fire?" Tolga: "No, it's just a lighter." Mehmed: "A relief. And a slight disappointment." | |
| 📘 | "Konstantinos bu kitabı gördü mü?" (Tolga başını sallar) Fatih: "Ne dedi?" Tolga: "Hiçbir şey." Fatih (uzun bir sessizlik): "...Anlıyorum." | "Did Constantine see this book?" (Tolga nods) Mehmed: "What did he say?" Tolga: "Nothing." Mehmed (a long silence): "...I understand." | Merak +1, Paradoks +10 |
| 🥜 | "İmparatorun askerleri de bundan yedi mi?" Tolga: "Biraz." Fatih: "Açlar mı?" Tolga: "...Evet." Fatih bir şey söylemez. | "Did the Emperor's soldiers eat these too?" Tolga: "Some." Mehmed: "Are they hungry?" Tolga: "...Yes." Mehmed says nothing. | |
| 🔋 | "Surların içinden bu taşla mı geldin? Orada taş eksik değil." | "You came out of the walls carrying a stone? They have no shortage in there." | |
| 📦 | "Rumlar surlarını artık bununla mı onarıyor? ...Hayır mı? İyi." | "Are the Greeks mending their walls with this now? ...No? Good." | Temel etki |
| ☕ | "Konstantinos'a da ikram ettin mi?" Tolga: "Evet." Fatih: "İçti mi?" Tolga: "İçti. Teşekkür etti." Fatih: "...İyi bir adam." | "Did you offer this to Constantine too?" Tolga: "Yes." Mehmed: "Did he drink?" Tolga: "He did. He thanked me." Mehmed: "...He is a good man." | |
| 🤳 | "İmparatorun resmi de bu cihazda mı? ...Görmek istemiyorum. Kalsın." | "Is the Emperor's likeness in this device too? ...I don't wish to see it. Leave it." | |
| 🍋 | Sinerji tezgâha zıplar. Fatih: "Önce tavuğun elleri mi, benimkiler mi?" Tolga: "Sizinkiler efendim." | Sinerji hops onto the table. Mehmed: "The chicken's hands first, or mine?" Tolga: "Yours, my lord." | Temel etki |
| 🧊 | (Çözer, sonra Sinerji'ye bakar) "Tavuğun da denedi mi?" Tolga: "Gagaladı." | (Solves it, then glances at Sinerji) "Did your chicken try as well?" Tolga: "It pecked it." | Temel etki |

## 2.2 Fatih — mektup, paradoks ve diğer durumlar (5 varyant)
| Koşul | Tetik | Türkçe | English | Etki |
|-------|-------|--------|---------|------|
| 🏛️ `letter_opened = false` | Mektup teslim | (Mührü inceler, açar, okur. Uzun bir sessizlik. Mektubu katlar.) "Cevabını ben vereceğim." | (He examines the seal, opens it, reads. A long silence. He folds it.) "I will answer this myself." | Merak +1 |
| 🏛️ `letter_opened = true` | Mektup teslim | "Mühür kırılmış. Okudun mu?" → Dürüst: "En azından dürüstsün. Bugün gördüğüm en nadir şey." / Yalan: "Yalan söylerken kulakların kızarıyor. Fesinden daha kırmızı." | "The seal is broken. Did you read it?" → Honest: "At least you're honest. The rarest thing I've seen today." / Lie: "Your ears go red when you lie. Redder than your hat." | Dürüst: Merak +1 · Yalan: Merak −1 |
| 🔴 | 📱 | "Bu levhayı... bir yerde gördüm. Rüyamda. Sen de vardın. Fesin de." | "This tablet... I've seen it before. In a dream. You were there. So was your hat." | Paradoks +5 |
| 🔴 | 📘 | "Kitaptaki yazılar değişiyor. Harfler kıpırdıyor. Ne yaptın?" | "The words in this book are changing. The letters are moving. What have you done?" | Denetçi hemen belirir |
| 🔴 | 🧊 | (Çevirmeden önce küpe bakar) "Renkler... kendi kendine yer değiştiriyor." | (Looks at the cube before turning it) "The colours... are moving on their own." | Merak ±0 (gerçeklik kırılıyor) |

## 2.3 Hikmet Amca — önceki sonlara göre (meta, 5 varyant)
| Koşul | Eşya | Türkçe | English |
|-------|------|--------|---------|
| "Tarih Yerinde" görüldü | 📘 | "Geçen sefer kaftanla döndün. Bu sefer bir kılıç getir, garaja lazım." | "Last time you came back with a kaftan. Bring a sword this time. The garage needs one." |
| "Leblebipolis" görüldü | 🥜 | "Bu leblebiyi dikkatli kullan. Geçen sefer tabelaları değiştirdin. Kimse fark etmedi ama ben fark ettim." | "Careful with those chickpeas. Last time you changed all the road signs. Nobody noticed. I noticed." |
| "Form Z-1453" görüldü | 📦 | "Bir memur geldi, garajı ölçtü, 'Form Z-7 eksik' dedi. Senin işin mi?" | "A civil servant came round, measured the garage and said 'Form Z-7 is missing.' Your doing?" |
| "İki Hükümdar" görüldü | 🍋 | "Sigorta şirketinizin logosu niye tavuk evlât?" Tolga: "Hep tavuktu." | "Why is your insurance company's logo a chicken, son?" Tolga: "It's always been a chicken." |
| Gizli son görüldü | 🧊 | "Duvardaki çerçevedeki adam bunu çözmüş diyorlar. ...Ben de çözerim bir gün." | "They say the fellow in that picture frame solved it. ...I'll solve it one day too." |

## 2.4 Hasan ile Hüseyin (8 varyant)
| Koşul | Eşya | Türkçe | English | Etki |
|-------|------|--------|---------|------|
| 🚫 fessiz ("deli") | 📱 | Hasan: "Delinin kutusu." Hüseyin: "Delinin kutusu ışık saçmaz." Hasan: "Bu delininki saçıyor." | Hasan: "The madman's box." Hüseyin: "A madman's box doesn't glow." Hasan: "This madman's does." | Şüphe ±0 |
| 🚫 fessiz | 🔥 | İkisi birden: "Deliye ateş verilmez!" | Both: "Never give a madman fire!" | Şüphe +2 |
| 🚫 fessiz | 🤳 | Hasan: "Deli bizi resmediyor." Hüseyin: "Bırak, deliye kimse inanmaz." | Hasan: "The madman's painting us." Hüseyin: "Let him. Nobody believes a madman." | Fotoğraf albümü +1, Şüphe ±0 |
| 🚫 fessiz | 🍋 | Hüseyin: "Deli bile güzel kokuyor. Biz niye kokmuyoruz?" | Hüseyin: "Even the madman smells nice. Why don't we?" | Şüphe −2 |
| 🍲 A (aşçı kılığı) | 🥜 | Hasan: "Yeni yamak nohut getirmiş!" Hüseyin: "Yeni yamak iyiymiş. Eski yamak hiçbir şey getirmezdi." | Hasan: "The new kitchen boy brought chickpeas!" Hüseyin: "Good lad. The old one never brought anything." | Şüphe −2 |
| 🍲 A | ☕ | "Mutfaktan sıcak su gelmiş. ...Mola uzun olsun." | "Hot water from the kitchen. ...Make it a long break." | `flag:guards_break` (8 dk) |
| 🏛️ Bz (onur muhafızı) | 📱 | Hasan: "Elçi efendi, cihazınız..." Hüseyin: "Elçiye dokunulmaz, Hasan." Hasan: "Hüseyin'im!" | Hasan: "Lord envoy, your device..." Hüseyin: "You don't touch an envoy, Hasan." Hasan: "I'm Hüseyin!" | |
| 🏛️ Bz | 🥜 | (Sinerji leblebiyi kapar) Hasan: "Tavuk nohut yiyor!" Hüseyin: "Bizans tavukları şımarık." | (Sinerji snaps up a chickpea) Hasan: "The chicken's eating chickpeas!" Hüseyin: "Spoilt, these Byzantine chickens." | |

## 2.5 Aşçıbaşı Kadri (8 varyant)
| Koşul | Eşya | Türkçe | English | Etki |
|-------|------|--------|---------|------|
| 🍲 A (yamağı) | 📱 | "Yamağım! O kutuyu mutfakta açma, yağ olur." | "My boy! Don't open that box in here, it'll get greasy." | |
| 🍲 A | 🔥 | "Ocağın sorumlusu artık sensin. Kutlu olsun." | "The stove is your responsibility now. Congratulations." | `flag:stove_master` |
| 🍲 A | 🥜 | "Tepsiyi hazırladım. Sultan'a sen götüreceksin. Titremeden." | "The tray's ready. You're taking it to the Sultan. No trembling." | Yol A → Bölüm 3 |
| 🍲 A | 🍋 | "Tepsiden önce ellerini kolonyala. Sultan'ın sofrası bu." | "Cologne your hands before the tray. This is the Sultan's table." | Huzurda kolonya bonusu hazır başlar |
| 🍲 A | 🧊 | "Yamak oyun oynamaz. ...Bir tur da ben çevireyim." | "Kitchen boys don't play games. ...Let me have one turn." | |
| 💣 C (Urban'ın çırağı) | 🔥 | "Topçunun çırağı mutfağıma ateşle mi girdi? Çık dışarı!" | "The gunner's apprentice walks into my kitchen with fire? Out!" | Şüphe +1 |
| 💣 C | 🥜 | "Urban'ın çırağı bile güzel nohut getiriyor. Urban hiçbir şey getirmez." | "Even Urban's apprentice brings good chickpeas. Urban never brings anything." | Şüphe −1 |
| 🐐 Y (`has_kaftan`) | ☕ | "Kaftan zaten sende. O zaman takas şu olsun: Sultan'ın tepsisini sen taşı." | "You've already got a kaftan. So here's the trade: you carry the Sultan's tray." | Ver: Yol A'ya kestirme |

## 2.6 Tercüman Lütfi (10 varyant)
| Koşul | Eşya | Türkçe | English | Etki |
|-------|------|--------|---------|------|
| 🚫 fessiz ("deli") | 📱 | "Deliler hangi dilde konuşur? ...Onu da bilirim." | "What language do madmen speak? ...I know that one too." | |
| 🚫 fessiz | 📘 | "Delinin kitabı. Kehanet değil, karalama." | "A madman's book. Not prophecy. Scribbles." | Yol B ilerlemez (fes takma ipucu) |
| 🚫 fessiz | 🔋 | "Deli, Hıtay malı taş taşıyor. Dünyanın en uzun yolunu yürümüşsün." | "A madman carrying Cathay stones. You've walked the longest road in the world." | |
| 🚫 fessiz | 🍋 | "Frenk olmadığına göre bu limon nereden? Çaldın mı?" | "If you're not a Frank, where did you get this lemon? Did you steal it?" | Şüphe +1 |
| 🗣️ B (ortağı) | 📱 | "Ortak, huzurda bu kutuyu çıkar, ben 'cin' diye tercüme ederim." | "Partner, bring out the box before the Sultan. I'll translate it as 'djinn.'" | Yol B, huzurda 📱 Merak garantisi |
| 🗣️ B | 🤳 | "Huzurda bununla ortada durursan seni ben de kurtaramam." | "If you wave that about before the Sultan, even I can't save you." | |
| 🗣️ B | ☕ | "Huzurda 'termos' kelimesini ben söyleyeceğim. Söz mü?" | "Before the Sultan, I get to say 'thermos.' Promise?" | Fatih'in Yol B ☕ tepkisini hazırlar |
| 🏛️ Bz (elçinin tercümanı) | 📱 | "Bu kutu mu Rumca tercüme etti? Kaç kelime? Hepsi yanlış mı? ...Güzel. Rakibim yok." | "This box translated Greek? How many words? All wrong? ...Good. No competition, then." | |
| 🏛️ Bz | 📘 | "Rum sarayına da mı bu kitabı götürdün? Bizim kehanetimizi onlara mı gösterdin?!" | "You took this book into the Greek palace? You showed *them* our prophecy?!" | Şüphe +1 |
| 🏛️ Bz | 🍋 | (Sinerji'yi görür) "Tavuğa da mı kolonya? ...Tavuk için tercüman gerekir mi?" | (Spots Sinerji) "Cologne for the chicken too? ...Does the chicken need an interpreter?" | |

## 2.7 Usta Urban (6 varyant)
| Koşul | Eşya | Türkçe | English | Etki |
|-------|------|--------|---------|------|
| 💣 C (çırağı) | 📱 | "Çırağım cinimi getirmiş! Bugün topu cinle hesaplayacağız." | "My apprentice has brought my djinn! Today we calculate with the djinn." | Paradoks +5 |
| 💣 C | 📘 | "Çırak, o kitabı bir daha açarsan seni topla fırlatırım." | "Apprentice, open that book again and I'll fire *you* out of the cannon." | |
| 💣 C | 🧊 | "Çırak! Vatanımdan bir parça! Topun adını 'Küp' koyacağım." | "Apprentice! A piece of my homeland! I shall name the cannon 'The Cube.'" | `flag:cannon_named_cube` |
| `cannon_taped` | 📦 | "Bant tutuyor! Bir kat daha! İki kat daha!" | "The tape holds! Another layer! Two more!" | Paradoks +10 |
| 🔴 | 📘 | "Kitap değişmiş. 'Top çatlamadı' yazıyor. Sonunda doğruyu yazmışlar." | "The book has changed. It says 'the cannon did not crack.' They finally got it right." | Denetçi hemen belirir |
| 🐐 Y (kaftanlı) | 🔥 | "Pazarda keçiyi yakalayan kaftanlı sen misin? Keçiyi de mi yaktın?" | "Are you the kaftan man who caught the goat? Did you set that on fire too?" | |

## 2.8 Sorucu Ağa (7 varyant)
| Koşul | Eşya | Türkçe | English | Etki |
|-------|------|--------|---------|------|
| 🏛️ Bz (arkandan koşarken) | 🥜 | "Elçiye soru sorulmaz dediler. Ben de nohut soruyorum: Bir tane?" | "They said envoys can't be questioned. So I'm asking the chickpeas: may I?" | |
| 🏛️ Bz | 🤳 | "Asa! Elçinin asası! ...Yine de deve sorusu." | "A staff! The envoy's staff! ...Still. The camel question." | |
| 🏛️ Bz | 📘 | "Rum kitabı mı? Deve yazıyor mu? Rumlar deveyi bilmez." | "A Greek book? Does it mention camels? The Greeks know nothing of camels." | |
| 🍲 A (tepsiyle) | 🥜 | "Tepside ne var? Bu soru sayılmaz. Tadına bakmak da sayılmaz." | "What's on the tray? That question doesn't count. Neither does tasting." | 1. soru geçilir |
| 🍲 A | 🍋 | "Sultan'ın yemeği kokulu gidiyor. Soru: Yemek mi kokulu, sen mi?" | "The Sultan's supper smells fragrant. Question: is it the food, or you?" | |
| 💣 C | 🔥 | "Topçunun çırağı. Soru: Topu ateşlemek mi zor, soruma cevap vermek mi?" | "The gunner's apprentice. Question: what's harder, firing a cannon or answering me?" | |
| 🐐 Y (kaftanlı) | 🤳 | "Kaftanlı ve asalı. Neredeyse bilgesin. Bir soru az." | "A kaftan and a staff. Practically a sage. One question fewer." | 1 soru atlanır |

## 2.9 Denetçi Nihat (7 varyant)
| Koşul | Eşya | Türkçe | English | Etki |
|-------|------|--------|---------|------|
| 🔴 | 📱 | "Artık form yok. Formlar bitti. Siz bitirdiniz." | "There are no more forms. The forms have run out. You ran them out." | |
| 🔴 | 📘 | "Bu kitabın yarısı artık yanlış. Siz yanlış yaptınız, kitap da yanlış oldu." | "Half this book is now wrong. You did wrong, so the book went wrong." | |
| 🔴 | ☕ | "Bir bardak daha. Bu saatten sonra fark etmez." | "Another cup. It hardly matters now." | Form mini oyununda süre +60 sn |
| 🔴 | 🧊 | "Bırakın küpü. Küp değil, benim kariyerim karışık." | "Put the cube down. It's not the cube that's scrambled. It's my career." | |
| 🏛️ Bz (Labirent cameo) | 📦 | "Logothetes Bey bunu görse bir haftalık form çıkarır. Harika bir adam." | "If Logothetes Theodoros saw this, he'd produce a week of paperwork. Marvellous man." | |
| 🏛️ Bz | 🤳 | "Beni Theodoros Bey'le yan yana çeker misiniz? Meslek hatırası." | "Would you take one of me with Theodoros? A professional keepsake." | Fotoğraf albümü +1 (nadir) |
| 🏛️ Bz | 🔋 | "Bunu kâğıt ağırlığı yaptılarsa tebrik ederim. Doğru karar." | "If they've made it a paperweight, congratulations. Correct decision." | |

## 2.10 Niko (7 varyant)
| Koşul | Eşya | Türkçe | English | Etki |
|-------|------|--------|---------|------|
| 🚫 fessiz ("Frenk tüccarı") | 📱 | "Frenk tüccarının aynası! Kaç duka? İçindeki adamla birlikte." | "A Frankish merchant's mirror! How many ducats? With the little man included." | |
| 🚫 fessiz | 🔥 | "Frenkler de mi deniz ateşi yapıyor? İmparatora sat, zengin ol." | "The Franks make sea fire too? Sell it to the Emperor, get rich." | Şüphe ±0 |
| 🚫 fessiz | 📘 | "Frenk kitabı. Düz harfler. Frenkler cetvelle yazar." | "A Frankish book. Straight letters. Franks write with rulers." | |
| 🚫 fessiz | 🍋 | "Venedikli gibi kokuyorsun, üstelik Frenksin. Neredeyse gemin var." | "You smell like a Venetian, and you're a Frank. You almost have a ship." | Şüphe −1 |
| 🚫 fessiz | 🧊 | "Frenk oyunu. Kırıldı. Frenk malı zaten kırık gelir." | "Frankish toy. It broke. Frankish goods always arrive broken." | |
| `niko_friend` | 🔥 | "Deniz ateşin var, nohudun var. Sen casus değilsin. Sen dostsun. ...Yine de casussun." | "You have sea fire, you have chickpeas. You're no spy. You're a friend. ...Still a spy." | |
| `niko_friend` | ☕ | "Dost! Sihirli testiyi imparatora ikimiz götürelim. Madalyayı yarı yarıya paylaşırız." | "Friend! We'll take the magic jug to the Emperor together. Split the medal." | Konstantinos sahnesinde Niko olumlu tanıtım yapar |

## 2.11 İmparator XI. Konstantinos (5 varyant)
*Ton kuralı geçerlidir (GDD §4): ciddi, onurlu, kısa.*

| Koşul | Eşya | Türkçe | English | Etki |
|-------|------|--------|---------|------|
| 🚫 fessiz (Niko onu "casus" diye tanıtır) | 🥜 | [Yunanca] "Bir casus bile askerlerimi düşünüyorsa, belki de casus değildir." | [Greek] "If even a spy thinks of my soldiers, perhaps he is no spy." | Ver: Paradoks +5 |
| 🚫 fessiz | ☕ | [Yunanca] "Bir casustan sıcak içecek. ...Yine de teşekkür ederim." | [Greek] "A warm drink from a spy. ...Thank you all the same." | |
| 🚫 fessiz | 📱 | [Yunanca] "Casusların aletleri de değişmiş." | [Greek] "Even spies' instruments have changed." | |
| `giustiniani_warned` | 📘 | [Yunanca] "Giustiniani'ye ne söyledin? ...Söyleme. Bir şey söylediğini biliyorum." | [Greek] "What did you tell Giustiniani? ...Don't. I know you told him something." | Paradoks +5 |
| 🔴 | 🤳 | [Yunanca] (Fotoğrafa bakar) "Bu resimde... farklı görünüyorum. Ne yaptın, yabancı?" | [Greek] (Looking at the photo) "In this picture... I look different. What have you done, stranger?" | Denetçi hemen belirir |

## 2.12 Giovanni Giustiniani (6 varyant)
*Giustiniani'nin temel tepkileri fessiz hâl içindir. Fes takılıysa onu yeni bir tarikatın üyesi sanır.*

| Koşul | Eşya | Türkçe | English | Etki |
|-------|------|--------|---------|------|
| 🎩 fesli ("tarikat") | 📱 | "Tarikatınız zengin görünüyor. Üyelik kaç duka?" | "Your order looks wealthy. What does membership cost?" | |
| 🎩 fesli | 🍋 | "Tarikatınızın kutsal suyu mu bu? Tarikat indirimi var mı?" | "Is this your order's holy water? Is there a members' discount?" | 💼 poliçe diyaloğu açılır |
| 🎩 fesli | 🧊 | "Tarikat ritüeli mi? Olsun. Yine de otuz tane isterim." | "A ritual of your order? No matter. I'll still take thirty." | |
| `giustiniani_warned` | 📱 | "O kutu geleceği mi gösteriyor? Bana da göster. ...Hayır, gösterme." | "Does that box show the future? Show me. ...No. Don't." | |
| `giustiniani_warned` | 🔥 | "Ateş istemem. Sadece... 29 Mayıs'a kaç gün var?" | "No fire, thank you. Just... how many days until the twenty-ninth of May?" | |
| `giustiniani_warned` | 🍋 | "O poliçeyi imzalayacağım. Primi ne olursa olsun." | "I'll sign that policy. Whatever the premium." | Poliçe imzalanır, Paradoks +5, İki Hükümdar sonu güçlenir |

## 2.13 Logothetes Theodoros (6 varyant)
| Koşul | Eşya | Türkçe | English | Etki |
|-------|------|--------|---------|------|
| 🎩 fesli ("Türk casusu") | 📘 | [Yunanca] "Türk casusunun kitabı. Casusluk beyannamesi altıncı odada." | [Greek] "A Turkish spy's book. Espionage declarations are in the sixth room." | Labirent +1 oda |
| 🚫 fessiz ("Frenk tüccarı") | 🍋 | [Yunanca] "Frenk tüccarları hediye verebilir. Ticari hediye formu. ...Çok naziksiniz." | [Greek] "Frankish merchants may give gifts. Commercial gift form. ...Most kind." | Şüphe −2, eşya kaybolmaz |
| `maze_rooms ≥ 4` | 📱 | [Yunanca] "Dördüncü mühre ulaştınız. Tebrikler. Kalan üç mühür için kutuyu kapatın." | [Greek] "You have reached the fourth seal. Congratulations. Please close the box for the remaining three." | |
| `maze_rooms ≥ 4` | ☕ | [Yunanca] "Bu kez iki yudum. İki oda." | [Greek] "Two sips this time. Two rooms." | Labirent'te iki oda atlanır |
| `maze_rooms ≥ 4` | 🧊 | [Yunanca] "Yedinci mührün rengi... bu yüzdeki kırmızı." | [Greek] "The colour of the seventh seal... is the red on this face." | Son mührün doğrudan ipucu |
| `nihat_met` | 📦 | [Yunanca] "Sizin memurunuz bundan bir form yapmayı önerdi. Kabul ettim." | [Greek] "Your official suggested we make a form for this. I agreed." | |

---

# Bölüm 3 — Seçim → sonuç matrisi

## 3.1 Karar noktaları
Hikayedeki her karar, verildiği yer ve sonucu.

| # | Karar noktası | Seçenekler | Sonuç | Bölüm |
|---|---------------|------------|-------|-------|
| 1 | **Çanta** | 10 eşyadan 5'i | Açılan yollar, kestirmeler, sonlar (Bölüm 1 özeti) | Garaj |
| 2 | **Haliç** | Kıyıya yüz / zincire yüz | 🍲🗣️💣🐐 ordugâh yolları / 🏛️ Bizans yolu | Kızak |
| 3 | **Fes** | 🎩 tak / 🚫 çıkar (her an) | Kimlik ve bazı kapılar (GDD §7.5), Bölüm 2 varyantları | Her yer |
| 4 | **Ordugâh yolu** | 🍲 A / 🗣️ B / 💣 C / 🐐 Y | Huzura geliş biçimi, Fatih varyantları (§2.1) | Ordugâh |
| 5 | **Çandarlı'nın mektubu** | Kabul / ret | Kabul: Paradoks +10, huzurda ek diyalog, İki Hükümdar sonuna Osmanlı tarafından ipucu | Ordugâh |
| 6 | **Urban'a koli bandı** | Ver / verme | Ver: Paradoks +20, `cannon_taped` | Ordugâh |
| 7 | **Kadri'ye leblebi** | Ver / verme | Ver: Paradoks +10, `leblebi_given` (Leblebipolis) | Ordugâh |
| 8 | **Kadri'ye termos** | Ver / verme | Ver: kaftan (ya da 🐐'da Yol A kestirmesi) | Ordugâh |
| 9 | **Konstantinos'a leblebi** | Ver / verme | Ver: Paradoks +5, `niko_friend` kesinleşir | Bizans |
| 10 | **Giustiniani'yi uyar** | Uyar / uyarma | Uyar: Paradoks +30, Denetçi hemen gelir, `giustiniani_warned` | Bizans |
| 11 | **Mektubu aç** | Aç / açma | Aç: Paradoks +15, `letter_opened`, Tolga'nın ciddi anı | Bizans → Otağ |
| 12 | **Mektup hakkında dürüstlük** | Dürüst / yalan | Merak +1 / −1 | Huzur |
| 13 | **Form Z-1453** | Başar / başaramama | Başarısızlık: Form Z-1453 sonu | Paradoks 🟠+ |
| 14 | **Kilit soru** | Aşağıda | Sonu belirler | Huzur |

## 3.2 Kilit soru: *"Bu şehir alınacak mı?"*
| Cevap | Türkçe | English | Etki |
|-------|--------|---------|------|
| **"Bunu size söyleyemem."** | Fatih: *"Doğru cevap."* | Mehmed: *"The right answer."* | Tarih Yerinde sonuna gider (Paradoks < 30 ise) |
| **"Evet, alacaksınız."** | Fatih: *"Bunu zaten biliyordum. Senden duymam bir şey değiştirmez."* | Mehmed: *"I already knew. Hearing it from you changes nothing."* | Paradoks +15 |
| **"Hayır, alamayacaksınız."** | Fatih: *"O hâlde senin geleceğin yanlış."* | Mehmed: *"Then your future is mistaken."* | Paradoks +25 |
| **🤓 "1435'te aldınız zaten!"** | Fatih: *"O zaman üç yaşındaydım. Hatırlamam lazımdı."* | Mehmed: *"I was three years old. I think I'd remember."* | Merak −1, Paradoks +5 |
| **💼 "Ortak kullanım modeli önerebilirim."** (sadece 🏛️ Bz) | Fatih: *"Anlat."* (Tolga anlatır.) Fatih: *"Hayır."* | Mehmed: *"Go on."* (Tolga explains.) Mehmed: *"No."* | İki Hükümdar sonuna gider (koşullar tutarsa) |

## 3.3 Yol × son erişilebilirliği
| Son | 🍲 A | 🗣️ B | 💣 C | 🐐 Y | 🏛️ Bz | Not |
|-----|:---:|:---:|:---:|:---:|:---:|-----|
| **1. Tarih Yerinde** | ✅ | ✅ | ✅ | ✅ | ⚠️ | Bz'de paradoksu 30'un altında tutmak zordur (mektubu açma, Giustiniani'yi uyarma) |
| **2. Leblebipolis** | ✅ | ✅ | ✅ | ✅ | ❌ | Kadri'ye leblebi vermek gerekir; Bizans yolunda Kadri yok |
| **3. Form Z-1453** | ✅ | ✅ | ✅ | ✅ | ✅ | Her yoldan, paradoks 90+ ya da form başarısızlığı |
| **4. İki Hükümdar, Bir Danışman** | ❌ | ❌ | ❌ | ❌ | ✅ | Sadece Bizans yolu |
| **5. Gizli son: Sultan'ın Tamiri** | ✅ | ✅ | ✅ | ✅ | ⚠️ | 📦 + 🧊 + 📱 çantada olmalı; Bz'de paradoksu 60'ın altında tutmak gerekir |

## 3.4 En kısa yollar (test senaryoları)
| Hedef son | Önerilen çanta | Yol | Kritik kararlar |
|-----------|----------------|-----|-----------------|
| Tarih Yerinde | 🥜 ☕ 🤳 🍋 🔋 | 🍲 A | Hiçbir şey verme, geleceği anlatma; kilit soruda "Bunu size söyleyemem" |
| Leblebipolis | 🥜 📘 📱 📦 🔥 | 🍲 A ya da 🗣️ B | 🥜 Kadri'ye ver, 📘 Fatih'e göster, 📦 Urban'a ver (paradoks ≥ 60) |
| Form Z-1453 | 📘 📦 📱 🔥 🔋 | 💣 C | Her şeyi anlat, Urban'a bant ver, kilit soruda "Hayır" |
| İki Hükümdar | 🥜 🍋 📘 📱 ☕ | 🏛️ Bz | 🥜 Konstantinos'a, 🍋 Giustiniani'ye (poliçe), mektubu aç (paradoks ≥ 40), kilit soruda 💼 |
| Gizli son | 📦 🧊 📱 🥜 🤳 | 💣 C ya da 🗣️ B | 📦 🧊 📱 Fatih'e göster, dürüst ol, 3 Merak, paradoks < 60 |
