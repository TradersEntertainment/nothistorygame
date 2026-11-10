# Yaşayan İstanbul (v0.69)

Hedef: her bölümde yürünebilen İstanbul boş bina yığını değil, gezmesi zevkli bir şehir olsun (Assassin's Creed:
Revelations havası). Üç katman:

## 1. Şehir planı: sokaklar ve mahalleler (`scripts/world/city_plan.gd`, `class_name CityPlan`)
Deterministik (sabit tohum), statik veri; dünya koordinatında (World1453 çerçevesi, y = yüzey).
- **Mese** (ana cadde, 1453'teki yolu): Ayasofya/Augustaion → Milion → Konstantin Forumu (sütun) → Tauri
  (Theodosius) Forumu → Philadelphion → kol ayrımı: kuzey kolu Havariyun → Harisios (Edirnekapı); güney kolu
  Bovis/Arkadios forumu → Altınkapı. Genişlik 10–12 m, revaklı (sütun dizisi) kesimler.
- **İkincil sokaklar**: Mese'den Haliç ve Marmara kıyılarına inen 5–7 m'lik yollar, aralarda dar sokaklar
  (3–4 m). Hafif kıvrımlı (gürültü), yamaçlarda araziyi izler.
- **Meydanlar/forumlar**: daire ya da dikdörtgen açık alan; pazar tezgâhları, çeşme, sütun.
- **Evler** artık rastgele serpilmez: sokak kenarlarına cephesi sokağa bakan sıra halinde dizilir (arka bahçeler,
  bostanlar arada boş). Mevcut `Scenery.house_mesh` + MultiMesh + `xforms` meta (WorldWalk katılaştırır).
- API (CityLife ve anıtlar bunu kullanır):
  - `CityPlan.graph() -> {"nodes": PackedVector3Array, "edges": Array[Vector2i], "width": PackedFloat32Array}`
    (kenar başına genişlik)
  - `CityPlan.plazas() -> Array[Dictionary]` `{"name", "pos": Vector3, "r": float, "kind": "forum"|"market"|"harbor"}`
  - `CityPlan.on_street(x, z, margin) -> bool` (ev, ağaç, kilise yerleşimi sokağı kapatmasın)
  - `CityPlan.nearest_node(p: Vector3) -> int`, `CityPlan.path(a, b) -> PackedVector3Array` (A*)
- Kapsam: HornWorld `_city_east` (x −760..760, z −1780..−700) ve SiegeField'in kara surları içindeki şehri
  (z −700..−3). Keep içindeki bölgeler (bölümlerin kendi seviyeleri) dokunulmaz (`_free`).

## 2. Tarihî yapılar (`scripts/world/landmarks1453.gd`, `class_name Landmarks1453`)
1453'te ayakta olanlar, tanınır silüetle (Props/Dressing ilkelleri; katı; LANDMARKS'a eklenir):
Ayasofya (var), Aya İrini, Augustaion ve Justinianus sütunu (atlı heykel), Hipodrom (var; dikilitaş, Yılanlı
Sütun, Örme Dikilitaş, yıkık oturma basamakları), Büyük Saray kalıntıları, Konstantin Forumu ve sütunu (var),
Theodosius Forumu (zafer takı + sütun), Bozdoğan Kemeri (var), Havariyun (var), Pantokrator Manastırı (Zeyrek, üç
kilise), Khora (Kariye), Pammakaristos (Fethiye), Studios Manastırı, Altınkapı (iki mermer kule + kemer), Yerebatan
Sarnıcı girişi, Theodosius/Kontoskalion limanları (rıhtım, kayıklar), Haliç kıyısında Venedik/Ceneviz/Amalfi
iskeleleri ve depoları, Tekfur Sarayı, Blakherna Sarayı.
- Her yapı: `{"key", "name_key" (i18n), "info_key" (i18n, 1-2 cümle tarih), "pos", "r" (taban yarıçapı)}`.
  CityPlan bu tabanları boş bırakır.
- **Keşif**: oyuncu yapıya 35 m yaklaşınca üstte kart: yapının adı + kısa tarihi (bir kez; GameState'te
  `discovered` kümesi, kayıtta kalır). Başarım: 10 / tüm yapılar.
- **Gözcü noktaları**: 5–6 yüksek yapının tepesinde (Ayasofya kubbesi, Galata Kulesi, sütunlar, kemer) tırmanılınca
  çevredeki yapılar keşfedilmiş sayılır (AC senkronizasyonu); kamera kısa bir dönüş yapar.

## 3. Canlı şehir (`scripts/world/city_life.gd`, `class_name CityLife`)
Oyuncunun çevresinde akış (streaming): yakın yarıçapta (≈90 m) gerçek karakterler, ötesinde yok (uzak forumlarda
`Crowd` MultiMesh donmuş kalabalık olabilir). Havuz: ≈36 sivil + 4 devriye (3'er asker); hareket düşük maliyetli
(çarpışmasız, sokak çizgisinde, y = yüzey), her kare değil 10 Hz güncelleme; uzaktakiler `process` kapalı.
- **Siviller** (Person, Rig yürüyüş animasyonu kendi işler): satıcı (tezgâh başında), hamal (sepet/küfe), rahip ve
  keşiş (siyah cüppe), kadın (başörtüsü/etek), çocuk, balıkçı (limanda), su taşıyan; sokak düğümleri arasında
  yürür, meydanlarda durur, bazen sohbet (iki kişi karşılıklı), oyuncu yaklaşınca yol verir, bakar.
- **Devriyeler** (Soldier): sokak ağında döngü rotası, düzenli adım, öndeki fener (gece). Taraf bölümün dönemine
  göre: kuşatma (1453 Nisan–Mayıs) Bizans + Ceneviz/Venedik; fetihten sonra (26 ve sonrası, 13/14) yeniçeri
  devriyesi. Oyuncuya yakın geçerken bakar, bazen "Dur! Kimsin?" (altyazı) ve geçer.
- **Yoğunluk/dönem**: gece ve kuşatma: az sivil, fener taşıyanlar, kiliseye giden kalabalık (24/25 hava); gündüz:
  pazar kalabalığı. Bölüm `CityLife.attach(world, {"era": "siege"|"conquest", "night": bool, "density": 0..1})`.
- Bölümün kendi seviyesinin (keep) içine CityLife karakter sokmaz.
- Performans bütçesi: CityLife < 1,5 ms/kare (headless ölçülür).

## Test: CITYCHECK (`tests/city_check.gd`)
Birkaç bölümde (23, 24, 26o, 31o, 38o) oyuncuyu şehrin 5 noktasına ışınlar ve şunlara bakar:
- etrafta en az N sivil ve 1 devriye var;
- hiçbir karakter bir evin içinde değil ya da havada değil;
- sokak düğümlerinin %95'i evlerden boş;
- tüm Landmarks1453 yapıları kurulmuş;
- karede ortalama süre.

## 4. Sokak insanı: herkesle konuşma ve "tuhaflığa bakan halk"
- **Konuşma** (`scripts/side_events.gd`, `street_*`): sokakta, ordugâhta görünen her kişi "E · Konuş: <rol>" ile konuşur.
  Rol (BYZSOL, GENMERC, OSMSOL, JAN, AZAP, VENDB, VENDO, PORTER, WORKER, PRIEST, MONK, DERV, WOMB, CHILDB, FISHER,
  TOWNB) "street_role" işaretinden ya da görünüşten çıkar. Replikler `DST_<ROL>_IDLE/FEZ/NIGHT/CONQ/GAL_n`; aynı kişiye
  3., 4., 5.+ gidişte `DST_<GRUP>_AGAIN_1/_2/AGAIN`. Hikâye karakterleri ve 1452 bölümleri eski davranışta kalır.
- **Sokak gözü** (`scripts/street_eye.gd`, Hud kurar): zıplama, koşup çarpma, eşyalar, dönme, dik bakma, kılıç, fes,
  eğilme → çevredekiler sırayla baş çevirir, döner, durur, jest yapar, söylenir (`DST_ODD_*`); ilgi birikirse nöbetçi
  uyarır (`DST_WARN_*`). Gizlilik bölümlerinde (4, 16, 25, 5, 8, 21o, Trespass) yalnız baş çevrilir. CityLife'ın yakın
  (4 m) gövdelerine ve yakındaki askerlere konuşma alanını da o açar. Test: `tests/street_check.tscn` (STREETCHECK).
- **Konuşan = görünen** (v0.99.x): sokak sözünü her zaman ekranda görünen, ağzı oynayan bir kişi söyler.
  - Tepki sözü (`StreetEye._bark`): önce konuşacak kişi seçilir (tepki veren, jest aşamasını geçmiş, oyuncunun kamera
    kadrajında ve arası açık: `_in_view`; tetikleyen ilk, sonra en yakınlar); satır o kişinin KENDİ rolünün
    konuşmacısından (yoksa aynı öbekten: `SPK_GROUP`) seçilir (`_line_for`, `_pick_line`). O kişi için o tuhaflıkta satır
    yoksa aynı taraftan sıradaki aday denenir; hiçbiri yoksa söz yok, yalnız jest. Nöbetçi uyarısı da yalnız görünen,
    rolüne uyan nöbetçiden gelir. Eski "kalabalıktan uyan biri söyler, ağız oynamaz" yolu kalktı.
  - Kart (`Hud.street_bark`, `SideEvents.street_talk`, `Hud.show_reaction`): ad kişinin rol etiketi (`SideEvents.role_label`,
    istemdeki adla aynı; satır metni ve ses anahtarı değişmez). Portre kişinin kendi canlı kafasıdır (LivePortrait: başlık,
    saç, sakal, ten, giysi aynen). Yüzü kameraya açılamıyorsa ya da kişi 40 m'den uzaksa portre GİZLENİR; stüdyoda
    kurulan başka bir yüz asla gösterilmez. Konuşan, altyazı göründüğü anda konuşmaya başlar (`street_hold`), altyazı başka
    bir satıra geçince susar (`street_release`): aynı anda tek konuşan.
  - Kapı (`Hud.street_busy`): altyazı, replik, zincirleme konuşma, seçim, ara sahne, çalan ses, duraklatma varken tepki
    sözü söylenmez; "E · Konuş" cevabı öncelikli (çalan tepki sözünü keser).
  - Test: STREETCHECK (f) 100 rastgele olayda konuşan kadrajda/rol uyumlu, (g) kart kişiyle uyumlu, tek konuşan, kapı.
