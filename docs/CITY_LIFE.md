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
