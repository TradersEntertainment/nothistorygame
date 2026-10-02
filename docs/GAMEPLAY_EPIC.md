# Oynanışı epik yapmak

Görsel yenileme yerine oynanışı güçlendirme planı. Her aşama ayrı bir sürümdür.

| Aşama | İçerik | Sürüm | Durum |
|---|---|---|---|
| 1 | Vuruş hissi: Fx (donma, ağır çekim, sarsıntı, görüş darbesi, ekran kenarı), müzik yoğunluğu, vurgu sesleri | 0.41.0 | bitti |
| 2 | Gerçek risk: oyuncu canı, hikâye düellolarında yenilgi, siper cezası. Ölüm yok, ceza var | 0.42.0 | bitti |
| 3 | Doruk sahneleri oynanabilir savaş: dalga motoru, Bölüm 26 gedik savunması, 26o merdiven ve sancak, 20 Şahi atışı | 0.43.0 | bitti (26o merdiven tırmanışı sonraya) |
| 4 | Dövüş derinliği: tekme, hedef değiştirme, bitirici darbe; arenada top dalgası ve değiştiriciler | 0.44.0 | bitti (arenada elle top dalgası sonraya) |

## Fx (`scripts/autoload/fx.gd`)

| Çağrı | Ne yapar | Nerede kullanılıyor |
|---|---|---|
| `Fx.hitstop(sec)` | Zaman bir anlığına neredeyse durur (vuruş "oturur") | Parry 0,08 sn; isabet 0,06 sn; son darbe 0,09 sn; yakına düşen gülle |
| `Fx.slowmo(scale, sec, ease)` | Ağır çekim, sonra tabana yumuşak dönüş; sesler de hafif yavaşlar | Parry, son darbe, son rakip düşünce, topla isabet |
| `Fx.trauma(a)` | Birikimli sarsıntı (`player.shake` üzerinden) | Gülle, isabet |
| `Fx.fov_punch(deg, sec)` | Görüş açısı bir an daralır | Son darbe, parry, top atışı |
| `Fx.edge(renk, güç, sec)` | Ekran kenarı rengi | Kırmızı: hasar ve ok. Altın: parry. Beyaz: top ve Şahi parlaması |

Zaman ölçeği:
- Bölümler otomatik testte `Engine.time_scale`'i 2,5–3'e çeker. Fx bu değeri taban sayar ve etkiyi onun üstüne çarpar.
- Fx'in yazmadığı bir değer görülürse yeni taban odur. Sahne değişince bütün etkiler sıfırlanır.
- Hiçbir etki 6 sn'den uzun sürmez. Sürerse bekçi sıfırlar ve testte `WARN_FX_STUCK` yazılır; test takımı bunu hata sayar.
- `tests/fx_check.tscn` 1× ve 3× tabanda dönüşü ve tabanın üzerine yazılmasını denetler.

Ayar `fx` (0–1, "Ağır çekim ve sarsıntı"): 0'da donma, ağır çekim, sarsıntı ve görüş darbesi kapanır. Kenar rengi (hasar uyarısı) yarım güçte kalır.

## Müzik (`scripts/autoload/audio.gd`)

`Audio.intensity(0..3)` aynı bölümün parçasından bir üst gerilim parçasına geçer:
- Sırası: `walls_night`, `tension`, `confrontation`, `chase`. Ordugâh ve Bizans parçaları için de aynı sıra kullanılır.
- Dalga başında 1–2, düelloda 3, dalga püskürtülünce 0.

`Audio.stinger(ad)`:
- Mevcut seslerden kısa bir vurgu yapar: `parry`, `hit`, `hurt`, `kill`, `victory`, `cannon`, `banner`, `heart`, `warn`.
- Çalarken müziği bir an kısar; bunu `Music` veri yolundaki yükseltici yapar (`Audio.duck`).

## Can ve yenilgi (Aşama 2)

**Oyuncu canı** (`Player.hp`, 100):
- `player.hurt(miktar, kaynak)`: Can düşer, ekran kenarı kızarır, kamera darbenin geldiği yana yatar.
- Can 0'a inince `player.down()` çalışır:
  - Oyuncu ölmez. Kamera yere iner, ekran kızıl kararır, kalp atışı duyulur, Nihat telsizden takılır.
  - 40 canla ayağa kalkılır. `player.downs` bir artar ve `downed` sinyali yayınlanır.
- Can, son darbeden 4 sn sonra saniyede 8 dolar (dövüşte dolmaz).
- Can 25'in altındayken oyuncu %20 yavaş yürür ve kalp atışı duyulur.
- Can eksikken sol altta ince bir can şeridi görünür.

**Hasar kaynakları:**

| Kaynak | Hasar | Bölüm |
|---|---|---|
| Siperde değilken Şahi güllesi | 40 | 20, 26 |
| Siperde değilken ok yaylımı | 30 | 22o, 26o |
| Kılıç darbesi (rakip `damage`) | 18 | 20, 22o, 26, 26o |

**Hikâye düellosu** (`StoryDuel.fight`):
- Düellonun canı oyuncunun canıdır (`Duel.link_player`). Rakipler 80 can taşır ve 18 hasar verir.
- Can biterse düello kaybedilir, oyuncu yere düşer, rakipler geri çekilir. Süre dolarsa da kaybedilmiş sayılır.
- Dönüş değeri: `{won, hits_taken, parries, kills, time}`.

**Yenilginin sonucu bozduğu yerler:**

| Bölüm | Yenilgi | Sonuç |
|---|---|---|
| 20 Gedik | Düello kaybı ya da iki kez yere düşme: gedik sabaha yetişmez | 20.3 |
| 22o Kule | Bir marangoz kulede kalır | 22O.2 |
| 26 Şafak (Bizans) | Tolga yerdeyken tüfekçi ateş eder, uyaramaz: saldırı püskürtülemez | 26.3 kapanır |
| 26o Son hücum | Fatih'in girişi kaçar, kare yok | 26.2 |

**Testler:**
- `--autotest=lose` (20, 22o, 26o) ve `--autotest=hold_lose` (26): bot düelloda savunmasız durur.
- Beklenen kötü sonuç, `player.downs >= 1` ve kaybedilmiş düello denetlenir.

## Dalga çarpışmaları (Aşama 3)

`WaveRunner.run(scene, hud, player, waves, blade)` (`scripts/combat/wave_runner.gd`) dalgaları sırayla oynatır:
- Aynı anda en çok `max_active` rakip vardır; düşen rakibin yerine sıradaki takviye gelir (`Duel.add_enemy`, `Duel.reserve`).
- `allies` verilirse iki yanda dost askerler de çarpışır.
- Dalga arasında +35 can. Süre dolduğunda oyuncu hâlâ ayaktaysa hat tutulmuş sayılır.
- Can biterse oyuncu yere düşer ve kalan dalgalar oynanmaz.
- Rakipleri `StoryDuel.make` kurar: teslim olur, ölmez.

| Bölüm | Yeni oynanış |
|---|---|
| 20 Gedik | Şahi uyarısında siperde değilsen ağır çekim (0,55×, 2,2 sn). Gedik dövüşü iki dalga: 2 azap, ardından 2 azap daha; iki savunucu yanında |
| 26 Şafak | 1. dalga: su taşındıktan sonra merdivenden 2 azap. 2. dalga: top atışı öncesi ağır çekim ve topa bakış; barikat kapanırken 3 azap (aynı anda 2, iki dost). Yeniçeri dövüşü iki dalga: 2 yeniçeri, ardından 4 yeniçerilik son bölük (aynı anda 2, iki dost). Giustiniani'nin yaralandığı an: ağır çekim 0,2×, müzik susar, kalp atışı |
| 26o Son hücum | Ceneviz dövüşü iki dalga: 2 Cenevizli, ardından 3 savunucu (aynı anda 2, iki sipahi). Sancak burca çıkarken ağır çekim, davul ve kalabalık, görüş darbesi |

Sonraya kalanlar:
- 26o'da merdivenden sura tırmanış (yukarıdan taş/ok, sur yolunda dövüş). Sur yolu çarpışma alanı ve merdiven başı noktaları ayrı bir iş.
- Arena dalgalarının WaveRunner'a geçmesi. Arena kendi dalga döngüsüyle çalışıyor ve gerçek ölümü olan tek mod.

**Çökme düzeltmesi:** Bölüm 26'da İmparator yolunun (26.3) Büro alarm sahnesi kapanırken oyun ara sıra (yaklaşık 4 koşuda 1) çöküyordu. Aynı çökme v0.40.4'te de vardı.
- Neden: Büro silinirken üzerinde hâlâ alarm döngüsü ve tweenler (sarsıntı, düşen kâğıtlar, Nihat'ın koşusu) çalışıyordu.
- Çözüm: Tweenler Büro'nun düğümlerine bağlanır ve silmeden önce durdurulur. Döngü çıkar, Büro bir kare gizli bekler, sonra silinir.
- Sonuç: 8 ardışık koşuda çökme olmadı.

**Testler:**
- Yenilgi denenmeyen otomatik testlerde düello canı 1'in altına inmez (`duel.god`); bot şansa kalmaz.
- Yenilgi yolu `=lose` ve `=hold_lose` varyantlarıyla gerçek hasarla denenir.

## Dövüş derinliği (Aşama 4)

| Hareket | Tuş | Ne yapar |
|---|---|---|
| Tekme | F (kolda B) | 2,6 m menzil, önde olmalı. Rakibi 1,2 sn sersemletir, kalkanını açar, saldırısını keser. 20 dayanıklılık; 2,5 sn bekleme |
| Bitirici darbe | E (kolda Y), rakip sersemken | Tek darbe: donma, ağır çekim, görüş darbesi. Hikâyede rakip yine teslim olur |
| Hedef | Bakış | Hedef bakılan yöndeki en yakın rakiptir (önceden de böyleydi) |
| Arkadan saldırı uyarısı | – | Görüş dışından vurmaya hazırlanan rakip için ekran kenarında yanıp sönen kırmızı ok |

**Arena değiştiricileri** (her 3. dalga, sırayla):

| Değiştirici | Etki |
|---|---|
| Yorgunluk | Dayanıklılık %55 hızla dolar |
| Kıdemliler | Rakip becerisi +0,12, oyuncunun darbesi ×1,3 |
| Şahi ateşi | 9–13 sn'de bir uyarı, ağır çekim, oyuncunun yakınında toz. 1,6 sn sonra gülle iner; 2,2 m içindeysen −25 can |

**Testler:**
- Arena `=mods`: üç dalgada üç değiştirici sırayla denenir.
- Arena `=osm`: kalkanlı rakiplere en az bir tekme şartı.
- Sonuç satırı tekme ve bitirici sayılarını da yazar.

Sonraya kalan: arenada elle top dalgası (CannonCrew ile gelen bölüğü vurma).

## Kalanlar tamamlandı (v0.45.0)

**26o hücum merdiveni:**
- Hasan'ın suyundan sonra oyuncu, dış surun ova yüzüne yaslı merdivenin dibine geçer (x 9, sancak kulesinin batısı) ve W ile tırmanır.
- Tırmanırken 1,4–2 sn'de bir surdan taş atılır. Ekranda "YUKARIDAN TAŞ! Dur!" yazısı çıkar.
- Taş oyuncunun 1,1 m üstüne iner. O anda hâlâ o yüksekliğe tırmanıyorsan −30 can; durursan taş önünden geçer.
- Tepede, sur yolunda iki dalga: 2 Cenevizli, ardından 3 savunucu (aynı anda 2).
- Sonra Hasan burçta direği tutar. Oyuncu kuleye 8 m kadar yaklaşıp E'yi 2,5 sn basılı tutarak sancağı kaldırmaya yardım eder; ardından ağır çekim ve davul.
- Test: bot gerçekten tırmanır, taş gelirken durur. Sura çıkmış olmak, en az bir taş atılmış olması ve taşa hiç yakalanmamak şartları denetlenir.

**Arenada top dalgası:**
- Her 5. dalga top dalgasıdır. Gediğin molozuna küçük bir top kurulur (CannonCrew). Hedef: Bizans'ta ovadan, Osmanlı'da surların arasından yaklaşan 4 kişilik bölük.
- 3 atış hakkı; her isabet bir askeri düşürür.
- Iskalanan atış sonraki dövüşü zorlaştırır: bir rakip fazla (en çok 3) ve iskalanan atış başına rakip canı +%12.
- Testler: `=cannon`, `=osm_cannon`.

**Zorluk (Ayarlar → Zorluk: Kolay / Normal / Zor):**

| | Kolay | Normal | Zor |
|---|---|---|---|
| Rakip hasarı | ×0,6 | ×1 | ×1,3 |
| Rakip becerisi | −0,15 | 0 | +0,1 |
| Rakip canı | ×0,8 | ×1 | ×1,15 |
| Karşılama (parry) penceresi | 0,40 sn | 0,28 sn | 0,22 sn |
| Ok ve gülle hasarı | ×0,6 | ×1 | ×1,25 |
| Can dolumu | ×1,5 | ×1 | ×0,8 |

- Ölüm yok kuralı her zorlukta geçerli. Arena çarpanları da kullanır.
- Test: `--difficulty=0/2`. Bölüm 20 her ikisinde de geçer. Ölçülen değerler: kolay 0,40 sn ve 10,8 hasar, zor 0,22 sn ve 23,4 hasar.

**Seslendirme:**
- Yeni replik listeleri: `docs/voice/NEW_V0420.txt`, `NEW_V0430.txt`, `NEW_V0450.txt`.
- `tools/voice_gen.py all` ortamda `ELEVENLABS_API_KEY` varsa üretir. Bu oturumda anahtar tanımlı değildi, ses üretilmedi. Replikler altyazıyla çalışır.

## Tüfek (v0.46.0)

Fitilli el topu (`scripts/combat/handgun.gd`, `Handgun`). 1453'te iki taraf da kullandı.

| Adım | Tuş | Ne olur |
|---|---|---|
| Doldur | R (pad Y) | Barut ve gülle kendiliğinden (1,3 sn). Harbiyle sıkıştırma: işaret ortadaki bölmedeyken R, 2 iyi vuruş |
| Nişan | Sağ tık (LT) | Görüş daralır (×0,66), tüfek göz hizasına gelir. Nefes salınımı: yürürken ×2, can 25'in altındayken ×1,5, zorluğa göre ×0,6 / ×1 / ×1,3 |
| Ateş | Sol tık (RT) | Horoz falyaya iner, 0,25 sn fitil gecikmesi, patlama, duman, geri tepme. Saçılma: nişanda 0,6°, kalçadan 3,5° |

- İsabet kameradan atılan ışınla hesaplanır: gövde 0,45 m, baş 0,25 m. Arada duvar varsa mermi duvara gider (toz). Namlu kameranın 1,3 m önünde sayılır (siperden sarkarak ateş).
- Koşan hedefe fitil gecikmesi kadar önden nişan almak gerekir.
- Vurulan asker geriye, atıcıdan uzağa devrilir.

**Bölüm 20:** Hücumun sonunda Giustiniani bir Ceneviz tüfeği verir. Tolga dış surun yürüyüş yolundan gediğe koşan 4 azaba ateş eder (4 atış, 25 sn). Vurulmayanlar gediğe varır ve gedik dövüşünün ikinci dalgasına katılır (en çok +2).

**Arena:** Top dalgası her 5. dalgada, tüfek dalgası 10, 20, … dalgalarda (top dalgasının yerine). Gediğin tepesinden koşan 4 kişilik bölüğe 4 atış. Vurulmayanlar sonraki dövüşü zorlaştırır (`_missed`).

**Testler:** Bölüm 20 her varyantta en az 3 atış ve 1 isabet ister. Arena `=gun` ve `=osm_gun` en az 1 isabet ister. Bot önden nişan alır, her dördüncü atışta bilerek 2,5° sapar (ıska yolu da denensin).

Yeni replikler: `docs/voice/NEW_V0460.txt`.

## Tüfek iki tarafta (v0.47.0)

Ortak sahne kodu: `scripts/combat/gun_range.gd` (`GunRange.run`). Bölüm 20, 26, 26o ve arena bunu kullanır. İki hedef türü var:
- **Koşanlar** (`runners`): bir yol boyunca koşar; yolun sonuna varan kaçar.
- **Mazgaldakiler** (`peek`): yerinde durur, 2,2 sn görünür, 1,6 sn siperin ardına çöker. Çökmüşken ışın taşa çarpar.

Görünmez sınır duvarları (sur yolu korkuluğu gibi) mermiyi durdurmaz: Handgun görünen ağı olmayan gövdeleri atlar.

| Bölüm | Ne olur | Sonucu |
|---|---|---|
| 26 Şafak (Bizans) | Giustiniani tüfeği verir (20'de kullandıysan "yine sen"); surdan hendeği geçen 4 yeniçeri | Vurulmayanlar son yeniçeri bölüğüne katılır (en çok +2) |
| 26o Son hücum (Osmanlı) | Hasan yeniçeri tüfeğini verir; hendeği dolduran toprağın üstünden mazgaldaki 4 savunucu | Merdivende atılan taş sayısı = vurulmayan savunucu (en az 1). 2+ ıska: sur yolu dövüşüne +1 savunucu |

Testler 26 ve 26o'da da en az 3 atış ve 1 isabet ister; 26o'da taş sayısının vurulmayanları aşmadığı denetlenir.

## Düşman tüfekçileri ve siper (v0.48.0)

`scripts/combat/gunner.gd` (`Gunner`).

| Adım | Süre | Ne olur |
|---|---|---|
| Bekleme | 7–11 sn (ilk atıştan önce 4–6 sn) | Tüfekçi oyuncuya döner |
| Nişan | Kolay 1,7 · Normal 1,3 · Zor 1,0 sn | Namluda fitil parlar, ekranda "TÜFEKÇİ! Yer değiştir ya da siper al!", tüfekçi ekrandaysa üstünde kırmızı halka, değilse ekran kenarında yön oku; uyarı sesi |
| Ateş | – | Duman ve patlama; kaçmadıysan −22 can (zorlukla), kısa sendeleme |

Kaçmanın üç yolu:
- Nişanın başladığı yerden 1,6 m uzaklaşmak.
- Ateş hattına dik yönde 0,9 m kaymak (dar sur yolunda da işe yarar).
- Tüfekçiyle arana görünen bir şey sokmak: mantlet, barikat, duvar, kazan. Görünmez sınırlar ve insanlar siper sayılmaz.

Düelloda kurşun düellonun canından düşer (kalkan tutmaz).

| Yer | Tüfekçi |
|---|---|
| Bölüm 20 | Gedik dövüşünde molozun tepesinde |
| Bölüm 26 | Yeniçeri dövüşünde molozun tepesinde |
| Bölüm 26o | Sur yolu dövüşünde sancak kulesinin tepesinde |
| Arena | Yeni değiştirici "Tüfekçi" (her üç dalgada bir dönen değiştiricilerin dördüncüsü) |

Testler: 20, 26 ve 26o'da en az bir atış ve bir kaçış; `=lose` varyantlarında bot kaçmaz. Arenada `=gunner` ve `=osm_gunner`.
