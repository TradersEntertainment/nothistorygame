# Eşya Tepki Matrisi (Göster) — v0.1

> GDD §7.2'deki **Göster matrisi**: Demodaki her konuşan karakter, çantadaki her eşyaya özel bir replikle tepki verir.
> **10 eşya × 12 karakter = 120 tepki**, Türkçe ve İngilizce.
>
> - **Türkçe** ve **English** sütunları birebir çeviri değildir. Espri her dilde ayrı kurulur (GDD §11).
> - **Etki** sütunu oyun mantığıdır: `Merak +1` (Fatih bulmacası), `Şüphe ±n`, `Paradoks +n`, `flag:ad` (ileride kullanılacak bayrak), `Ver:` (eşya karaktere bırakılırsa ne olur).
> - Etki sütunu boşsa tepki sadece espri içindir.
> - Bizans karakterleri (Niko hariç) Yunanca konuşur. Oyuncu altyazıyı `[Yunanca]` etiketiyle okur, Tolga anlamaz (GDD §4).

**Eşyalar:** 📱 Telefon · 🔥 Çakmak · 📘 Tarih Kitabı · 🥜 Leblebi · 🔋 Powerbank · 📦 Koli Bandı · ☕ Termos Çay · 🤳 Selfie Çubuğu · 🍋 Kolonya · 🧊 Rubik Küpü

**Karakterler:**
[1. Hikmet](#1-hikmet-amca--garaj) · [2. Hasan ile Hüseyin](#2-hasan-ile-hüseyin--nöbetçiler) · [3. Aşçıbaşı Kadri](#3-aşçıbaşı-kadri) · [4. Tercüman Lütfi](#4-tercüman-lütfi) · [5. Usta Urban](#5-usta-urban) · [6. Sorucu Ağa](#6-sorucu-ağa) · [7. Fatih](#7-sultan-ii-mehmed-fatih) · [8. Denetçi Nihat](#8-denetçi-nihat-zamanoğlu) · [9. Niko](#9-niko) · [10. Konstantinos](#10-imparator-xi-konstantinos) · [11. Giustiniani](#11-giovanni-giustiniani) · [12. Logothetes Theodoros](#12-logothetes-theodoros)

---

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
