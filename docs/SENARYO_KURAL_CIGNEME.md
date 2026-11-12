# Kuralı çiğneyen oyuncu: talimden kaçmak, halka vurmak (senaryo)

Sahibin sözü (12 Kasım): "tolgayla savaş eğitiminden kaçtım ne. geçen halka vurmaya çalıştım vurulmadı öyle bir şeye
karşı senaryo yazabilir misin"

Durum: **UYGULANDI** (v0.99.119 üstüne, dal `wip/senaryo-kacak`). Ne yapıldığı ve sınanmadığı: §5. Kanıt ve rapor:
`docs/_kanit_senaryo_kacak/`.

## 0. Bugün ne oluyor (kodu okuyarak; ekranlı kanıt `docs/_kanit_senaryo_kacak/`)

- **Talim** iki bölümde: 41o (Osmanlı, Turgut'un meydanı) ve 42b (Bizans, Giustiniani'nin meydanı); ikisi de
  `Drill` + `TrainingYard`. Meydanın etrafında ip çit var ama **sınır yok, görünmez duvar yok**. Kılıç derslerinde
  (`player.combat`) ve merdiven/fotoğraf evresinde oyuncu yürüyebiliyor; meydandan çıkıp ovaya, ordugâha yürüyebilir.
  Hoca orada bekler, ders süresi dolunca dersi kendisi "geçirir": **kimse bir şey demez**.
- **Vuruş**: serbest dolaşımda `kick` (F / sol tık) yalnız tırmanmaya gider (`Traversal._click`); bir kişiye
  bakılırken (`focus_id` dolu) tık hiç işlenmez. Tekme yalnız dövüşte (`Duel`) ve bazı bölüm olaylarında var. Yani
  sivile, askere, Fatih'e, keçiye tıklamak: **hiçbir şey**. Yumruk yok.
- Var olan, kullanılacak düzenekler: `Stubborn` (inatçı oyuncu sözleri + gizli başarımlar), `StreetEye` + `SideEvents`
  (sokak insanının rolü, rolüne uygun konuşmacı, "konuşan = görünen" kartı), `Person.kick()` (NPC tekmesi zaten var),
  `Player.kick()` (Tolga'nın bacağı), `Player.down()` (yere düşme + Nihat'ın sözü), `Stage.approach` (kişiyi yürütme),
  `GameState.bump_stat` / `unlock_achievement`, `GameState.paradox`, `replay_scene`.

## 1. Talimden kaçmak

Görev alanı: talim meydanı (41o/42b), meydanın ortasından ~15 m. Görev veren: Turgut (41o) / Giustiniani (42b).
Bir de kovalayan: meydanın kenarında balyada oturan azap (41o) / gönüllü (42b); ekranda zaten duran biri.

| Basamak | Tetik | Osmanlı (41o) | Bizans (42b) |
|---|---|---|---|
| 1. laf | alandan 2 sn dışarıda | Turgut: "Kâtip! Meydan bu yanda, sen öbür yana gidiyorsun." | Giustiniani: "Tercüman. Talim burada; şehir kaçmıyor, sen de kaçma." |
| 2. seslenme | 7 sn ya da 25 m | Turgut: "Bre Hızır'ın yeğeni, kalk! Getir şu kâtibi, kulağından!" Balyadaki azap kalkar, koşar. | Giustiniani: "Marco. Getir onu. Nazikçe; şimdilik." Gönüllü koşar. |
| 3. yakalanma | koşan 2 m'ye yetişir | Azap: "Firari yakaladım ağam! Bacakları uzun ama aklı kısa." | Gönüllü: "Kumandanım, kaçak burada. Hiç direnmedi, yoruldu." |
| Sonuç A: angarya | yakalandı | Kararan ekran, kart **"CEZA: Kadri'nin kazanı, akşama kadar"**. Turgut: "Kaçmak da talimdir; lâkin geri dönüş yokuştur. Kazan seni bekler." Tolga: "Kazan karıştırmak dövüş sanatı sayılır mı?" Turgut: "Sayılır. Kepçeyle." Meydana, kaçtığı yere geri. | Kart **"CEZA: sur taşı, akşama kadar"**. Giustiniani: "Kaçan adam surda işe yaramaz. Taş taşıyan yarar." Tolga: "Bel fıtığı kapsam dışı ama…" |
| 4. kaçış başarılı | koşanı atlattı (60 m ya da 45 sn) | Telsiz: Hikmet: "Evlât, nereye? Tarih kitabında bugün talimdesin. Sen dışarıdasın, kitap içeride." Nihat: "Görev yerini terk. Büro sizi iade ediyor." Kart **"İADE · 1 adet kâtip · kullanılmış"**, meydana geri. Turgut: "Gelmişsin. Ben de bekliyordum; kazan da bekliyordu." | Aynı Büro iadesi; Giustiniani: "Kayboldun, buldun kendini. Güzel. Şimdi kılıç." |
| Üstelemek | aynı bölümde 2. kaçış | Turgut ilk basamağı atlar: "Yine mi? Hızır, bu sefer koş." | Giustiniani: "İkinci kez. Leon, sen al." |

Kalıcı iz:
- Sayaç `GameState.stats["firar"]` (ömür boyu), bölüm işareti `flags["firar_41o"] / flags["firar_42b"]`.
- Büro iadesi: sayaç `stats["buro_iade"]`. (Paradoks sayacına yazılmadı: 12. bölümün sonuçları ona bakıyor; §4.)
- Gönderme: 37o (İlk Hücum) açılışında Turgut: "Talimden kaçan kâtip! Bu gece kaçacak yer yok, önümde dur.";
  36b (Huruç) açılışında Leon: "Talimden kaçan tercüman. Bugün kaçarsan, kapı arkandan kapanır."
- Başarım (gizli): **ACH_FIRAR "Firari Kâtip" / "The Deserting Clerk"**: talimden üç kez kaçmak (toplam).

Kaçmayan oyuncu için hiçbir şey değişmez: izleyici yalnız alandan çıkınca çalışır; test botu çıkmaz.

## 2. Halka vurmak (sokak ve ordugâh)

Girdi: var olan `kick` (F / sol tık); yeni tuş yok. Hedef: önündeki 2 m içindeki kişi (sokağın "Konuş" hedefini
bulan `SideEvents.street_focus` ile aynı). Kişinin türü `SideEvents.street_role` ile çıkar.

### 2a. Yetişkin erkek sivil (esnaf, hamal, balıkçı, işçi, Galatalı)
1. **İlk vuruş**: tekme iner, adam sendeler, şaşırır. Kendi sesiyle (rolünün konuşmacısı): "Bre! Ne yaptın sen?" /
   "Hey! Beni at mı sandın?". Tolga: "Pardon, refleks. Sigortacı refleksi."
2. **İkinci vuruş** (aynı bölümde): çevredekiler kaçışır, biri bağırır ("Deli var! Tekmeci deli!"), vurulan karşılık
   verir: kendi tekmesi (`Person.kick`) → Tolga yere serilir (`Player.down`: var olan Nihat sözü).
3. **Üçüncü vuruş**: muhafız görüş dışından koşarak gelir (Bizans: şehir muhafızı; ordugâh/fetih: yeniçeri;
   Galata: Ceneviz). "Dur! Kanun namına!" → **tutuklanma**: kararan ekran, kısa kart sahnesi, üç söz:
   - Bizans: kart **"Eparkhos'un zindanı"** (7. bölümün zindanı). Muhafız: "Burada bir gece kal; yarın ayaklarını
     tanırsın." Tolga: "Avukatımı istiyorum. Bin dört yüz elli üçte avukat yok, değil mi?" Nihat: "Var. Ben."
   - Osmanlı: kart **"Kadı huzuru"**. Yeniçeri (kadının sözünü aktarır): "Kadı efendi hükmetti: kabahat ayaktadır,
     ayağa falaka. Lâkin kâtipsin; kırk dilekçe yazacaksın." Tolga: "Kırk mı? Ben dilekçeyi dijital yazarım…"
   - Galata: kart **"Podestà'nın divanı"**. Cenevizli: "Ceza on altın. Ya da üç gün iskele." Tolga: "Kartla olur mu?"
   Ekran açılır, Tolga aynı sokakta; bölüm kaldığı yerden sürer.
4. **Kalıcı iz**: o bölümde yakınından geçenler arada bir geri çekilip söylenir ("İşte o tekmeci!", "Çocuklar,
   içeri!"). Sayaç `stats["tekme_sivil"]`, `stats["tutuklama"]`. Başarım (gizli): **ACH_KADI "Kadı Huzurunda" /
   "Before the Kadi"**: bir kez tutuklanmak.

### 2b. Kadın, çocuk, yaşlı, din adamı
Vuruş **hiç işlemez**; şiddet gösterilmez. Bacak kalkar ve iner; sırayla (her seferinde biri):
- Tolga kendi vazgeçer: "Yok. Annem duysa beni Zamanatör'le geri yollar." / "Ayak kaldırdım ama vicdan indirdi."
- Araya biri girer (en yakın erkek): "Bre utanmaz! Kadına mı?" / "Çocuğa ayak kaldırana bu sokakta su verilmez!"
- Hikmet telsizden: "Evlât, o teyzeye ayak kaldırırsan makineyi ben de kaldırmam."
- Din adamı: Rahip/derviş bakar, Tolga: "Tamam, tamam. Günah hanesine yazılmasın."
Mizah Tolga'nın rezilliği. Sayaç `stats["utanc"]`; üçüncüde Tolga: "Bugün ayaklarımı cebime koyuyorum."

### 2c. Hayvan
- Keçi: kafa atar, Tolga yere (`down`). Tolga: "Keçi de mi taraf?"
- Tavuk (Sinerji dahil): kanat çırpıp Tolga'nın üstüne atlar (sarsıntı + kol savrulması), Tolga: "Tamam! Barış!"
- At, öküz: çifte → yere. Tolga: "Bunu poliçeye 'at tarafından' diye yazacaklar."
- Kedi: kaçar, damdan bakar. Tolga: "Kedi bile beni kınadı."

### 2d. Askere, komutana vurmak
Kuşatma ortası; askerle şaka olmaz: **tırmanma yok**. Asker ayağı havada yakalar, Tolga yere (`down`), doğrudan
tutuklanma (2a/3, asker kendi tarafının sözüyle: "Kâtip, ayağını indir; yoksa ben indiririm.").

### 2e. Fatih ya da İmparator'a el/ayak kaldırmak
Vuruş işlemez. Zaman donar (her şey ağır çekime iner), Nihat'ın sesi: "DUR." Kart **"ZAMAN BÜROSU · ACİL İADE ·
Form Z-0: Hükümdara Ayak Kaldırma Girişimi"**. Nihat: "Bu formu Büro'da kimse doldurmadı. Tebrikler, ilk sizsiniz."
Hikmet (telsiz): "Evlât, tarihe tekme atılmaz; tarih geri tepiyor." → **bölüm baştan başlar** (`replay_scene`),
Sayaç `stats["tarihe_tekme"]` (paradoksa yazılmadı, §4). Başarım (gizli): **ACH_TARIHE_TEKME "Tarihe Tekme" / "Kicking History"**.
Giustiniani, Turgut, Urban, Çandarlı gibi tarihî komutanlar 2d'ye girer (asker yakalar, tutuklanma).

## 3. Ortak düzenek (`scripts/level/kural.gd`, `class_name` yok, `preload`)

- `Kural.watch_area(scene, hud, player, center, radius, giver, giver_spk, runner, side, keys)`: alan izleyici.
  Basamakları çalar, yakalanınca ya da Büro iadesinde oyuncuyu çıktığı yere geri koyar. Bölüm yalnız kurar.
- `Kural.hits(scene, hud, player)`: vuruş yakalayıcı; `player.frozen`, `combat`, ara sahne, Nihat bölümleri ve
  gizlilik sahnelerinde kapalı. Kendi `_physics_process`'inde `kick` basışına bakar; bölümün kendi tekme olayı
  varsa (focus `mg:`/`ev:`) karışmaz.
- **Başka bölüme tek satır**: `preload("res://scripts/level/kural.gd").hits(self, hud, player)` (alan için
  `.watch_area(...)`).

Bağlanacak bölümler (ilk hâl): talim 41o, 42b · şehir 24 (Ayasofya alayı), 31o (fetih ertesi şehir, Ayasofya),
39o (Petrion), 10g (Galata), 7 (Bizans tarafı sokak) · ordugâh 6 (gündüz), 24o (gece).
Bağlanmayacak: gizlilik bölümleri (4, 16, 25, 5, 8, 21o), dövüş bölümleri (tekme zaten dövüşün parçası), Nihat
bölümleri (3, 7 denetçi kısmı, 11, 14).

## 4. Sahibin karar vermesi gerekenler
1. Hükümdara tekme = bölümü baştan başlatmak: sert mi? (Seçenek: yalnız kart ve paradoks, bölüm sürer.)
2. Tutuklanma bir kart sahnesi; oynanabilir zindan (7. bölüm byzcell gibi) ister misin?
3. Angarya şimdilik kart + söz; kazan karıştırma mini işi (Kadri'nin kazanı mini oyunu var) bağlansın mı?
4. Başarım adları: "Firari Kâtip", "Kadı Huzurunda", "Tarihe Tekme".
5. Paradoks sayacına yazılsın mı? 12. bölüm paradoks 40/60 eşiğiyle sonuç seçiyor; şimdilik YAZILMADI (yalnız `stats`).

## 5. Uygulama durumu

Düzenek: `scripts/level/kural.gd` (`class_name` yok; `preload`). Bölüm başına bir "Kural" düğümü.

| Durum | Uygulandı mı | Nasıl sınandı |
|---|---|---|
| Talimden kaçmak 41o / 42b: laf → seslenme + kovalayan → yakalanma → CEZA kartı + üç söz → kaçtığı yere dönüş | EVET | `kacak` (41o, 42b) başsız PASS; 41o ekranlı ÖNCE/SONRA |
| Kovalayanı atlatmak: Hikmet telsiz + Nihat + "İADE" kartı, görev veren bekliyor | EVET | `kacak_iade` (41o, 42b) başsız PASS |
| Üstelemek: aynı bölümde 2. kaçışta ilk basamak atlanır ("Yine mi?") | EVET | kodda; ayrı varyant YOK |
| Gönderme: 37o Turgut, 36b Leon (yalnız kaçan oyuncuya bir söz) | EVET | 37o/36b eski varyantlar PASS (söz kaçmayana çıkmaz); kaçan rota için koşu YOK |
| Erkek sivile tekme: 1 şaşkınlık + Tolga özrü · 2 kalabalık bağırır, vurulan tekmeyle karşılık verir, Tolga yere · 3 muhafız arkadan koşarak gelir → tutuklanma kartı (zindan / kadı / podestà) | EVET | `krl_hit` 24 (Bizans), 10g (Galata), 6 ve 24o (ordugâh). 39o bağlı ama sokakta rolü olan kişi yok: koşusu yok |
| Kalıcı iz: tutuklanandan sonra o bölümde yakından geçen sivil "İşte o tekmeci" der, döner bakar | EVET | kodda (`_mark_tick`); koşu günlüğünde `KURAL mark` |
| Kadın, çocuk, yaşlı, din adamı: bacak kalkar, iner; sırayla Tolga vazgeçer / biri araya girer / Hikmet telsizden / Tolga | EVET | `krl_soft` 24 |
| Askere, talim arkadaşına: ayağı yakalar, Tolga yere, doğrudan tutuklanma | EVET | `krl_soldier` 6 |
| Komutan/hikâye karakteri (Turgut, Giustiniani...): Tolga "Şaka!" der, muhafız gelir | EVET | KANITSIZ (varyant yok) |
| Fatih / İmparator: "Dur." → ACİL İADE kartı, Nihat + Hikmet, bölüm baştan | EVET | KANITSIZ (bağlanan bölümlerde hükümdar serbest dolaşımda yok; otomatik testte bölüm yeniden başlamaz) |
| Hayvan: keçi/at/öküz karşılık (Tolga yere), tavuk üstüne atlar, kedi kınar | EVET | `krl_animal` 6 |
| Sayaçlar `stats`: firar, buro_iade, tekme_sivil, tutuklama, utanc, tekme_asker, tekme_hayvan, tarihe_tekme | EVET | ACHCHECK |
| Başarımlar (gizli): ACH_FIRAR, ACH_KADI, ACH_TARIHE_TEKME | EVET | `tests/ach_check.gd` |
| Paradoks sayacı | HAYIR (bilerek) | 12. bölümün sonuçlarını değiştirir; sahibin kararı (§4) |
| Oynanabilir angarya (kazan) / oynanabilir zindan | HAYIR | kart + söz; sahibin kararı (§4) |

Bağlanan bölümler: 41o, 42b (alan + tekme) · 24, 10g, 39o, 31o (şehir) · 6, 24o (ordugâh): tekme.
Bağlanmayanlar: 7 ve 3/11/14 (oyuncu Nihat: düzenek zaten kapalı), gizlilik (4, 5, 8, 16, 21o, 25), dövüş bölümleri
(tekme dövüşün parçası; düzenek `player.combat` iken kapalı), 1452 bölümleri (33o, 34o, 35o), 2026 bölümleri.

**Başka bir bölüme bağlamak (tek satır, `add_child(player)`'dan sonra):**
```gdscript
kural = preload("res://scripts/level/kural.gd").hits(self, hud, player)
```
Talim gibi bir görev alanı için: `preload(...).area(self, hud, player, merkez, yarıçap, görev_veren, "SPK_..", kovalayan, "O"|"B")`.
Otomatik test için bölümün güvenli bir anına `if GameState.autotest: await kural.bot_window()` ve rapora
`kural.test_ok()`.

Kaçmayan, vurmayan oyuncu için hiçbir şey değişmez: izleyici yalnız alandan çıkınca ya da önünde biri varken tekmeye
basınca çalışır; eski varyantların hepsi aynı sonuçla geçer (§ rapor).

## 6. Hükümdara el kaldırmak: VURAMAZ → SÜRGÜN (sahibin kararı, 12 Kasım, 2. tur)

Sahibin sözü: "hükümdara vurmaya kalkarsa vuramasın bir şekilde: ya hükümdar ya da oradaki askerler düşürsün bizi;
hükümdarların hamle yapması havalı durabilir. Sonrasında bizi karşı tarafa sürsünler: surların dışına, ordugâha doğru,
bayraksız; ya da tersinde surlara doğru. Ceza karşı tarafa geçmek; karşı tarafa geçince de o tarihten devam."
Sorusu: "peki hangi bölümlerde elimizde kılıç vs varken hükümdara yaklaşma şansımız var ki?"

**Kısa cevap:** bugün (bu turdan önce) hemen hiçbirinde. Kılıç yalnız dövüş/talim düzeneğinde elde ve o sırada Kural
izleyicisi kapalı; hükümdarın karşımızda durduğu sahnelerin çoğu diyalog kilidinde (oyuncu donuk, tekme girdisi yok).
Eski paketin hükümdar yolu (§2e, "bölüm baştan") yalnız 6. bölümün Bizans yolunda (şehirde İmparator serbest
dolaşımdayken) gerçekten tetiklenebiliyordu. Bu tur fırsat bilerek AÇILDI (aşağıda "Açıldı mı").

### 6.1 Fırsat tablosu (hükümdarın bulunduğu her bölüm)

Sütunlar: **Uzaklık** hükümdarın oyuncuya en yakın olduğu serbest an (koddaki yerleşimden; ölçülen değerler §6.6'da
otomatik test sondasından) · **Serbest** oyuncu hükümdarın yanındayken yürüyebiliyor mu · **El** o an elinde ne var ·
**Bugün** bu turdan önce vurma/tekme girdisi işleniyor muydu · **Kilit** hükümdarlı anlar diyalog kilidinde mi ·
**Açıldı mı** bu turda.

| Bölüm | Hükümdar | Taraf · tarih | Uzaklık | Serbest | El | Bugün | Kilit | Açıldı mı |
|---|---|---|---|---|---|---|---|---|
| 6 (B yolu, şehir) | İmparator (byz_city, konuşulabilir) | Bizans · 23 Nisan (Perde II) | 1–2 m (yanına yürünür) | evet | boş / eşya | **evet** (Kural bağlı: Büro iadesi) | konuşma anında | EVET (serbest an + konuşma) · kuşatma öncesi kuralı |
| 7 (Niko/şehir) | İmparator (byz_city) | Bizans · 24 Nisan (Perde II) | 1–2 m | evet (Tolga kısmı) | boş / eşya | hayır | konuşma anında | EVET · kuşatma öncesi kuralı (Nihat kısmında kapalı) |
| 10 (otağ kapısı) | Fatih (perde arkasında gölge; içeride ara sahne) | Osmanlı · Perde II | otağ içinde 3–4 m | hayır (içeride ara sahne) | boş | hayır | evet | EVET (diyalog arası atılma) · kuşatma öncesi kuralı |
| 10b (top dökümü) | Fatih (sona doğru gelir) | Osmanlı · Perde II | 5–8 m | sonda hayır | boş | hayır | evet | EVET (diyalog arası) |
| 10g (Galata) | Fatih (sonda) | Galata/Osmanlı · Perde II | 3–6 m | hayır | boş | hayır (Kural bağlı ama hükümdarlı an donuk) | evet | EVET (diyalog arası) |
| 10z (ziyafet) | Fatih (kapıda, sonda) | Osmanlı · Perde II | ~4 m | hayır | boş | hayır | evet | EVET (diyalog arası) |
| 12 (otağ, huzur) | Fatih (tahtta) | Osmanlı · 26 Nisan (Perde III sonu) | 2–4 m | hayır | boş / kâğıt | hayır | evet | EVET (diyalog arası) |
| 10h (heyet) | İmparator | Bizans · Perde II | 2–5 m | kısmen (serbest evre) | boş / eşya | hayır | çoğunlukla | EVET |
| 12b (Blakherna, sur) | İmparator | Bizans · 26 Nisan | 2–5 m | evet (iki serbest evre) | boş / kandil | hayır | çoğunlukla | EVET |
| Edirne ara bölümü | çocuk Mehmed | Edirne · 1444 dolayı | — | — | — | — | — | HAYIR (çocuk: "yumuşak" kural §2b; hükümdar sayılmaz) |
| 34o (Ocak 1453, top) | Fatih | Osmanlı · kuşatma öncesi | 4–8 m | kısmen (ip, gülle evreleri) | boş / ip | hayır | atış anında | EVET · kuşatma öncesi: sürgün ilk iki taraflı bölümde |
| 28o (Şahi'nin ilk atışı) | Fatih (sultan) | Osmanlı · 6–12 Nisan | 5–10 m | evrelerde evet | boş / kazık / halat | hayır | sultan anlarında | EVET → Bizans |
| 32o (28 Mayıs, hazırlık) | Fatih (sultan, ateşler) | Osmanlı · 28 Mayıs | 3–6 m | kısmen | boş / eşya | hayır | evet ("sultan" evresi) | EVET → Bizans |
| 23 (21 Mayıs, tercüme) | İmparator (Bizans tarafı) | ortak sahne · 21 Mayıs | 2–3 m | kısmen | boş / kâğıt | hayır | çoğunlukla | EVET (Bizans tarafında) → Osmanlı |
| 25 (27–28 Mayıs, Ayasofya) | İmparator | ortak sahne · 27–28 Mayıs | 3–16 m | evet (tepsi, surlar evreleri) | boş / tepsi | hayır | dinleme anında | EVET → Osmanlı |
| 26 (gedik) | İmparator; sonda Fatih (Ayasofya) | Bizans · 29 Mayıs | 1–4 m | dalgalar arasında evet | **kılıç** (dövüşte) | hayır (dövüşte Kural kapalı) | dalga aralarında kısmen | EVET (kılıçla da) → Osmanlı; Fatih'e: karşı taraf hükümdarı (geri itilir) |
| 30 (12 Mayıs Blakherna) | İmparator | Bizans · 12 Mayıs | 2–6 m ("emperor" evresi) | evet | **kılıç** (düellodan sonra) | hayır | kısmen | EVET (kılıçla da) → Osmanlı |
| 30o (Blakherna, Osmanlı) | İmparator (surda, uzakta) | Osmanlı · 12 Mayıs | 5+ m, surda | evet | kılıç / merdiven | hayır | kısmen | EVET (karşı taraf hükümdarı: muhafızlar, geri itilir; sürgün yok) |

Sürgünün kuralı (§6.3): **kendi tarafının hükümdarına** el kaldıran karşı tarafa sürülür. Karşı tarafın hükümdarına
(26'nın sonunda Fatih, 30o'da İmparator) el kaldıran da vuramaz (karşı hamle / muhafız) ama sürülmez: "geldiği yere
geri" itilir, bölüm sürer. Kuşatma öncesi bölümlerde (Perde II, 34o) karşı taraf yok: §6.4.

(Bu tablo ilk hâl; ölçülen uzaklıklar ve "açıldı mı" sütununun kesin hâli uygulama bitince §6.6'da.)

### 6.2 VURAMAZ: tetik ve karşı hamle (`scripts/level/huzur.gd`)

Bölüm tek satır bağlar (`preload("res://scripts/level/huzur.gd").watch(self, hud, player)`); düğüm sahnedeki hükümdarları
(`Person.face_id` "fatih" / "emperor"; çocuk Mehmed sayılmaz) kendisi bulur. Yeni tuş yok:

| Durum | Girdi | Uzaklık |
|---|---|---|
| Serbest yürürken | tekme (F / sol tık) | `FREE_REACH` 2,4 m, bakış konisi ~30° |
| Replikte ya da replik arasında (oyuncu donuk) | yalnız F (sol tık replik ilerletir; kaza olmasın) | `LUNGE_REACH` 7,5 m: birkaç hızlı adım ve atılış (`DASH_SPEED` 8 m/sn) |
| Elde çantadan sert eşya (telefon, küp, termos, powerbank, çakmak, kitap, kolonya, bant) | tekme tuşu: eşyayla vurmaya kalkar | aynı |
| Elde kılıç (dövüşte ya da dövüşten sonra elde kalan) | kılıç sallama (sol tık / F; replikte yalnız F) | `SWORD_REACH` 3 m (donukken 7,5) |

Seçim kutusu açıkken, menüde, merdivende, yerdeyken, kamera başkasındayken tetik yok. Açık replik varsa sesi kesilir
ve bölümün sıradaki repliği sahne bitene kadar sırada bekler (Hud'un replik yeri tutulur; bölümün metni kaybolmaz).

**Kim karşılar** (`COUNTER_DIST` 3,4 m, `BEHIND_DOT`): hükümdar yakın ve oyuncu önündeyse kendisi; uzaksa ya da
arkadan gelindiyse en yakın iki muhafız (sahnede duran askerler; yoksa görüş dışından koşarak gelen iki muhafız; o da
yoksa hükümdarın kendisi).

| Kim | Boş el / eşya / tekme | Kılıçla gelene |
|---|---|---|
| **Mehmed** (genç, çevik) | Bileği (tekmede ayak bileğini) havada yakalar, yarım adım yana çekilir, çevirir; Tolga omzundan yanına yere iner. "Elini indir, kâtip. O el kalem tutmak için." | Kılıçlı bileği havada yakalar ve çevirir (parad yerine çıplak elle; kendi kılıcı kınında kalır): Tolga'nın kılıcı elinden fırlayıp yere düşer, sonra aynı çevirme. "Kılıcı kınından çıkaran, nereye ineceğini bilmeli." |
| **Konstantinos** (tecrübeli asker) | Sol eli göğse, sağ ayağı çeler; Tolga sırtüstü. "Otuz yıldır kılıç taşırım. Yerde kal biraz; kalkınca daha akıllı olursun." | Önkoluyla kılıcı yana süpürür, kılıç düşer; sonra aynı çelme. "O kılıç sana Şehir için verildi, bana karşı değil." |
| **Muhafızlar** | İki muhafız iki yandan koşar, mızrak sapları/kalkanla iter: "Huzurda el kalkmaz, kâtip! Yere!" (yeniçeri) · "Basileus'a el! Yere, yabancı!" (Bizans) | aynı, kılıç düşer |

Gövde: hükümdarın eli her karede oyuncunun bileğinde/ayağında/göğsünde (Rig.reach), ayakları yerde (yalnız yatay yarım
adım); oyuncu duvarın içine düşmez (iniş noktası ışınla kısaltılır). Kamera sarsılır, yana yatar, göz hizası yere iner;
bakış `LOOK_BACK` 1,2 sn sonra geri gelir (donukken de fare serbest). Ölümsüz, kansız. Tolga yerden bir söz söyler
("Hasar tespiti: tek taraflı, sigortalı kusurlu." / "Yerdeyim. Gökyüzü güzelmiş bu arada." / "Yine yerdeyim..." /
kılıçta "Kılıç gitti. Poliçede 'silah teslimi' diye bir madde vardı; şimdi anladım.").
`ACH_TARIHE_TEKME` karşı hamle anında (sayaç `tarihe_tekme`). Eski davranış (Büro acil iadesi, bölüm baştan) KALDIRILDI.

### 6.3 SÜRGÜN (`scripts/chapter8s.gd`, sahne `scenes/chapter8s.tscn`)

Hüküm (sakin, tek cümle; öldürtmez):
- Sultan: "Kan dökülmesin. Sancaksız çıkarın, surlara salın. Ayağını orada denesin."
- İmparator: "Kimse ona dokunmasın. Kapıyı açın, karşıya yollayın. Sultan'ın ordusunda bir ayak fazla olsun."

Kararır; sürgün yürüyüşü açılır. Ara Bölüm "Beyaz Havlu"nun (8y) kapısı, ölü bölgesi, siperi ve kişileri aynen
kullanılır (`extends chapter8y.gd`); bu kez **beyaz bez yok**:
- **Bizans → Osmanlı (B2O):** nöbetçi şehrin içinden kapıya götürür ("Kapı arkandan kapanacak. Ellerini kaldır, yavaş
  yürü. Bizim okçular da seni artık tanımıyor."), sürgüyü kaldırıp kapıyı açar ("İmparator'un emri: dokunmayacağız. Ama
  bu kapıyı bir daha senin için açmayacağız."); surdaki gözcü "Yayları indirin. Bu bizim kâtipti; artık değil."; ovada
  siperden Hasan "Dur orada! Ellerin havada kalsın!", Hüseyin "Tamam, gördük. Gel. Yavaş gel."; siperde karşılama:
  "Seni karşıdan yolladılar, öyle mi?" (Tolga'yı tanıyorsa "Bre, bizim Frenk kâtip!", tanımıyorsa "Bre, karşıdan biri
  geldi!"), Hüseyin: "İmparator'una el kaldırmışsın diyorlar...", Hasan: "Gel. Ağam karar versin. Ama önce bir tas çorba."
- **Osmanlı → Bizans (O2B):** Hasan ile Hüseyin siperin geçidinden ovaya salar ("Yürü bakalım, kâtip. Sancak yok, bez
  yok; ellerin havada olsun, yeter." / "Sultan'ım 'kan dökülmesin' dedi. Surdakiler de aynısını desin diye dua et.");
  sur önünde gözcü durdurur ("Dur! Ellerini göster! Kimsin sen?" · Tolga: "Kâtip! Eski Osmanlı kâtibi! Sultan yolladı.
  Uzun hikâye!" · "Sultan'a el kaldıran adam, ha? Gel. Yavaş gel."); nöbetçi kapıyı açar, Niko karşılar ("Seni
  karşıdan yolladılar demek. Sultan'a el kaldıran adama bu şehirde bir tas çorba çıkar." / tanışmamışsa "...Ben Niko.").

Ovada kural (oynanır): **E ile eller havaya** (iki el kadrajın üstünde açık; adım yavaşlar). Eller inikken
`WARN_GRACE` 2,5 sn, koşarken ya da koridorun kenarına sapınca uyarı oku ayağının dibine saplanır (yakın taraf atar:
surdan "Ellerini kaldır! Bir dahaki ok uyarı olmaz!" / siperden "Ellerini göster, bre! Ne saklıyorsun?"; koşana 8y'nin
"Yavaşla, Latin!" / "Teslim olmaya kimse koşmaz!" sözleri). Üst üste `HIT_AFTER` 3 uyarıda ok **sıyırır**: Tolga yere
(Nihat'ın var olan "yere serildi" sözü), kararır, **son geçtiği siper sırasında** eller havada kalkar ("Omzuma değdi.
Kayda geçsin: tek parça, biraz delik."). Ölüm yok. Eller havada `STREAK_CALM` 6 sn yürümek ya da terk edilmiş perde
sırasının dibinde (`COVER_DIST` 1,6 m) durmak ("siper almak") sayacı sıfırlar. Süre: kuralı tutan oyuncu için 2–3 dk.

Bitişte Nihat telsizden: "Dosyanız karşı nüshaya taşındı, Tolga Bey. Kaldığınız günden devam; tarih aynı, taraf
değil." → akış şeması (SÜRGÜN · Bayraksız Geçiş: hangi taraftan hangisine, uyarı/sıyıran ok sayısı, sıradaki bölüm ve
tarihi) → karşı tarafın sıradaki sayfası.

### 6.4 Kuşatma öncesi ve iki tarafın olmadığı bölümler

Perde II'de (6, 7, 10, 10b, 10g, 10h, 10z, 12, 12b) ve kuşatmanın kış sayfasında (34o) karşı taraf yok. Uygulanan:
karşı hamle aynen; hüküm "Bırakın. Bu adamı kuşatmada karşımda görmek isterim." (Sultan) / "Bırakın onu. Kuşatma
gelince karşı safta dursun; orada daha az zarar verir." (İmparator); kararır, muhafızlar kapı dışarı eder (oyuncu
hükümdardan 2,5 m geriye konur), **bölüm sürer** (repliği, sonucu aynı). Sürgün bekletilir (`flags.surgun_pending`):
- Perde II'den: **Büro'da** taraf seçilmez; Nihat: "Dosyanızda bir not var, Tolga Bey: 'Bu adamı kuşatmada karşımda
  görmek isterim.' Altında tuğra. Bizans nüshasına yazıldınız." (İmparator'unki: "...Osmanlı nüshasına yazıldınız.")
  Tolga: "Yani tayinim çıktı. Tekmeyle tayin diye bir şey varmış." İki hükümdara da el kalktıysa: "İki hükümdardan da
  not var... Tarafınızı seçin; huzura çıkmayacaksınız." (taraf serbest, ban).
- 34o'dan (Ocak 1453): 35o olduğu gibi oynanır; iki tarafın aynı günlerde yürüdüğü ilk sayfaya (7 Nisan, `TWO_SIDED_FROM`
  = 42) geçerken sürgün yürüyüşü (O2B), hedef 42b.

### 6.5 Tekrarı ve karşı tarafın hükümdarı

- **Atlı ya da oturan hükümdar** (28o ve 34o'da Sultan baştan sona at üstünde, 26'nın sonunda Ayasofya'da atlı; 12'de
  yere oturmuş): kendisi karşılamaz, **muhafızlar** karşılar; atlı Sultan'ın hükmünü yanındaki yeniçeri aktarır ("Sultan'ım
  buyurdu: kan dökülmeyecek. Sancaksız çık, surlara yürü!" / "...seni kuşatmada karşısında görmek istermiş." / "...geldiği
  yere götürün." / "...bu adam bir daha huzura çıkmayacak.").
- Karşı tarafın hükümdarına el kaldıran (30o'da İmparator; Osmanlı tarafında 23/25'te İmparator):
  vuramaz (aynı karşı hamle/muhafız), hüküm "Geldiği yere götürün. Dövüşecekse kendi safında dövüşsün." / "Geri itin.
  Bugün esir besleyecek ekmeğimiz yok."; geri itilir, **sürgün yok**, bölüm sürer.
- İkinci sürgün (öbür tarafın hükümdarına, artık kendi hükümdarı): yeniden sürgün, geri.
- Üçüncü kez (`EXILE_LIMIT` 2 sürgünden sonra): "Bu adamı bir daha huzuruma getirmeyin." (ikisi de); sürgün yok, bölüm
  sürer; bundan sonra hükümdara `BAN_DIST` 3 m'den fazla yaklaşılamaz: muhafız önünü keser ("Geri dur, kâtip. Huzur sana
  kapalı." / "Bir adım daha yok. Emir böyle."). Hükümdarlı sahneler kilitlenmez.

### 6.6 İki tarafın bölüm–tarih eşlemesi ve "sürgünden sonra hangi bölüm"

`Siege.ORDER` iki tarafın ortak tarih sırasıdır; bir sayfanın sahnesi o tarafta yoksa taraf onu atlar.

| Sıra | Tarih | Osmanlı | Bizans |
|---|---|---|---|
| 1 | Ağustos–Kasım 1452 | 33o | — |
| 2 | Ocak 1453 | 34o (Fatih) | — |
| 3 | Şubat–Mart 1453 | 35o | — |
| 4 | 7 Nisan 1453 | — | 42b |
| 5 | 9 Nisan 1453 | — | 36b |
| 6 | 6–12 Nisan 1453 | 28o (Fatih) | — |
| 7 | 17 Nisan 1453 | 41o | — |
| 8 | 18 Nisan 1453, gece | 37o | — |
| 9 | 20 Nisan 1453 | 29o | 29 |
| 10 | 28 Nisan 1453, gece | 17o | 17 |
| 11 | Mayıs başı 1453 | 18 | 18b |
| 12 | 3–23 Mayıs 1453 | 19o | 19 |
| 13 | 7 Mayıs 1453, gece | 20o | 20 |
| 14 | 12 Mayıs 1453, gece yarısı | 30o (İmparator, karşı) | 30 (İmparator, kılıç) |
| 15 | 16 Mayıs 1453, gece | 21o | 21 |
| 16 | 18 Mayıs 1453 | 22o | 22 |
| 17 | 21 Mayıs 1453 | 23 (ortak sahne) | 23 (İmparator) |
| 18 | 22–25 Mayıs 1453 | 24o | 24 |
| 19 | 25 Mayıs 1453 | 43o | — |
| 20 | 27–28 Mayıs 1453 | 25 (ortak sahne) | 25 (İmparator) |
| 21 | 28 Mayıs 1453 | 32o (Fatih) | — |
| 22 | 29 Mayıs 1453 | 26o | 26 (İmparator, kılıç; sonda Fatih: karşı) |
| 23 | 29 Mayıs 1453, Haliç | 38o | — |
| 24 | 29 Mayıs 1453, akşam | 39o | — |
| 25 | 30 Mayıs – 1 Haziran 1453 | 31o | — |
| 26 | 1 Haziran 1453 | 27 (ortak) | 27 |

Sürgünün hedefi: **karşı tarafın bu sayfadan SONRAKİ ilk sayfası** (`Huzur.next_on`; `tests/huzur_check.gd` denetler):

| Hükümdarlı sayfa | Sürgün | Sonraki sayfa (karşı taraf) |
|---|---|---|
| 34o (Ocak 1453, Fatih) | bekletilir → 35o'dan sonra O2B | 42b (7 Nisan) |
| 28o (6–12 Nisan, Fatih) | O2B | 29 (20 Nisan, Bizans) |
| 32o (28 Mayıs, Fatih) | O2B | 26 (29 Mayıs şafağı, Bizans) |
| 30 (12 Mayıs, İmparator) | B2O | 21o (16 Mayıs) |
| 23 (21 Mayıs, Bizans tarafı) | B2O | 24o (22–25 Mayıs) |
| 25 (27–28 Mayıs, Bizans tarafı) | B2O | 32o (28 Mayıs) |
| 26 (29 Mayıs, İmparator) | B2O | 38o (29 Mayıs, Haliç); şafak tutmaz (`Siege.resolve(false)`) |
| Perde II (6, 7, 10*, 12, 12b) | Büro'da taraf karşıya yazılır | kuşatmanın o taraftaki ilk sayfası |

**Taşınan / taşınmayan:** çanta eşyaları, bayraklar, sonuçlar, başarımlar, sayaçlar taşınır (aynı oyun); **paradoks
sayacına dokunulmaz**; sürgünün olduğu sayfanın sonucu YAZILMAZ (yarım kaldı; tanığın sicilinde sayılmaz); kaza rotası
(`siege_detour`) sürüyorsa kapanır. Yeni bayraklar: `siege_side` (yeni taraf), `surgun_log` ([{ch, from, to, next, ruler,
hits, warnings}]), `surgun_n`, `surgun_pending`, `surgun_bureau`, `huzur_ban`; sayaçlar `tarihe_tekme`, `surgun`.
Karşı tarafta tanışılmamış karakterler (Niko, Hasan-Hüseyin) karşılamada "seni karşıdan yolladılar" bilgisini taşır.

**Kayıt, liste, şema, akıbet:** sürgün yürüyüşünün kendi kaydı yok (ortasında çıkılırsa hükümdarlı bölümün başı
açılır); karşı tarafın sayfası açılınca onun kaydı alınır. Sürgünlü yolda `Siege.chapters()` iki tarafın sayfalarını tek
sırada sayar (`Siege.side_at`): bölüm numaraları ardışık, eski tarafın oynanmış sayfası listede "—" değil kendi
numarasıyla görünür. Akış şeması: sürgün sahnesinin kendi şeması. Akıbet (Bölüm 15, "İnsanların Akıbeti"): "İki
hükümdar" satırı (sürgün(ler), Büro notu, ban; 2026 izi).


### 6.7 Ölçülen fırsat (otomatik test sondası `HUZUR summary`, bütün eski varyantlar; bu turdan sonra)

Ölçüm test botunun yolundan: hükümdarın görünür olduğu süre (hızlı testte replikler kısalır; gerçek oyunda daha uzun),
oyuncunun serbest olduğu süre, elde kılıç olan süre, en yakın uzaklık (serbestken / herhangi bir anda). Gerçek oyuncu
serbest evrelerde bottan daha yakına yürüyebilir. "Açıldı" sütunu bu turun bağlantısı ve yeni varyantın sonucudur.

| Bölüm (varyant) | Hükümdar | Görünür / serbest / kılıçlı (sn) | En yakın serbest / her an | Açıldı mı (kanıt) |
|---|---|---|---|---|
| 6 (byz) | İmparator | 19 / 10 / 0 | 26,1 / 5,1 m | EVET: replikte atılış (5,1 m) → muhafız, bekleyen sürgün; `6 byz + huzur` 3/3 PASS |
| 7 (byz, byzniko, byzcell) | İmparator | 3–7 / 0 / 0 | — / 9,3–40,3 m | HAYIR (bağlı ama hükümdar hep 7,5 m'den uzak ve oyuncu donuk) |
| 10 | Fatih (yaya, otağın içi) | 1 / 0 / 0 | — / 1,8 m | EVET: `10 huzur` PASS (Mehmed karşı hamlesi) |
| 10b (boom, untaped) | Fatih | 3–6 / 0 / 0 | — / 1,6–5,6 m | EVET: `10b huzur` PASS (5,6 m: muhafız) |
| 10g (fatih, late) | Fatih | 4 / 0 / 0 | — / 3,2 m (varsayılan yolda 53,7) | EVET yalnız `fatih`/`late` yolunda; KANITSIZ |
| 10h | İmparator | 6–11 / 0 / 0 | — / 1,8 m | EVET: `10h huzur` PASS (eşyayla, muhafız, bekleyen sürgün) |
| 10z | Fatih (yaya) | 2 / 0 / 0 | — / 3,3 m | EVET: `10z huzur` PASS, **Mehmed'in kendi karşı hamlesi** (ekranlı ÖNCE/SONRA) |
| 12 | Fatih (tahtta) | 3–6 / 0 / 0 | — / 6,1 m | EVET: `12 huzur` PASS (atılış 6,1 m, eşyayla, bekleyen sürgün) |
| 12b | İmparator | 4–5 / 0 / 0 | — / 2,9 m | EVET: `12b huzur` 3/3 PASS (arkadan: muhafız) |
| Edirne ara bölümü | çocuk Mehmed | — | — | HAYIR (çocuk: §2b) |
| 34o | Fatih (atlı) | 32 / 21 / 0 | 8,1 / 5,9 m | EVET: `34o huzur` PASS (muhafız + yeniçeri aktarır, bekleyen sürgün) |
| 28o | Fatih (atlı) | 3 / 1 / 0 | 6,1 / 6,1 m | EVET: `28o huzur` PASS (muhafız + aktarma, sürgün → 29), `huzur_guard`, `huzur_save` |
| 32o | Fatih | 14 / 14 / 0 | 23,7 / 23,3 m | BAĞLI ama botun yolunda erişilmez (Sultan ateşlerin ötesinde); yürüyerek yaklaşılırsa çalışır: KANITSIZ |
| 23 | İmparator | 6 / 2 / 0 | 8,2 / 8,2 m | EVET (serbest anda yürüyüp): `23 huzur` (rapor2) |
| 25 | İmparator | 11–13 / 0 / 0 | — / 2,0–4,0 m | EVET: `25 huzur` (sürgün → 32o), `huzur2`, `huzur3` |
| 26 | İmparator (gedik), Fatih (Ayasofya, atlı) | 77 / 57 / **0** | 2,4 / 2,4 m | EVET boş elle; Fatih karşı taraf (geri itilir). **Kılıç hükümdarın yanında hiç elde değil** (dalga sonunda kınına giriyor) |
| 30 | İmparator | 7 / 0 / **6** | 6,3 / 6,3 m | EVET kılıçla: `30 huzur_sword` PASS (replikte F ile atılış → Konstantinos kolla süpürür, kılıç düşer; sürgün → 21o) |
| 30o | İmparator (surda, karşı taraf) | 20 / 10 / 0 | 13,1 / 13,1 m | BAĞLI (karşı taraf: geri itilir); botun yolunda erişilmez: KANITSIZ |

**Sahibin sorusunun cevabı ("hangi bölümlerde elimizde kılıç varken hükümdara yaklaşma şansımız var?"):** ölçüme göre
yalnız **30** (12 Mayıs, Blakherna; düellodan sonra kılıç elde, İmparator 6 m'de, replik arasında). 26'da hükümdarlar
2,4 m'ye kadar yaklaşıyor ama o anlarda kılıç kınında; Mehmed'e kılıçla yaklaşılan bir an oyunda **hiç yok**
(Osmanlı tarafında kılıçlı bölümlerde Sultan sahnede değil). Ayrıca Sultan kuşatma sayfalarında (28o, 34o, 26 sonu) hep
**atlı**: kendi karşı hamlesi yalnız Perde II'de (10, 10z: yaya) görülür; kuşatmada onu muhafızlar karşılar. Mehmed'in kılıçlıya karşı hamlesi kodda var, ama oyunun
doğal akışında tetiklenemez.
