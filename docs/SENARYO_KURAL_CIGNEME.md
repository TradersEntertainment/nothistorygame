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
