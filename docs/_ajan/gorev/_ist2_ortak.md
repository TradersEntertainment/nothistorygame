# İstanbul v2: yeni coğrafya — ortak karar ve dondurulmuş arayüz (ZORUNLU)

Türkçe çalış. Soru sorma, plan sunma, onay bekleme. HEDEF: şehir BUGÜN bitecek.

## Sahibin sözleri (12 Kasım, aynen)
- "ben şunu anlamıyorum hani kraldan mektup falan alırken oynadığımız istanbul neden nihatla istanbulun üstünden
  uçtuğumuz istanbula benzemiyor tolgayla oynadığımız istanbul nerde?"
- "kanka bence sen önce 1453 nisanda istanbul nasılmış ona çalış sonra bence bölümleri içine sığdırırız, peter çok
  detaylı istanbul yapmış ya günümüz o promtpları örnek al bunu 1453 nisan yap ve şekiller vs bizim oyna uysun tolganın
  tırmanabileceği içinden düşmeyeceğimiz şekilde falan olsun bizim şu anki tolganın mektup bölümündeki evleri
  kullanabilirsin şekil olarak galiba"
- "kank gerekirse çalışan sayısını arttır ama bu istanbulu bugün bitir"
- "tüm tarihi eserlere özen nihat hepsinini üstüne uçuo bakma yan görevi vr çünkü"

## Yöneticinin kararı (ilk birleştirme turundan çıkan ders)
Oyunun bugünkü haritası (`World1453`) şematik, küçük bir üçgen (≈ 1,4 × 1,7 km; gerçeğin ~1/3,5'i, kıyılar düz çizgi).
Gerçek boyda kurulan parçalar bu haritaya SIĞMADI (Galata, kara surları, Bozdoğan, Tekfur, kıyı surları yerleştirilemedi;
Ayasofya çevresinde gerçek 480 m haritada 95 m) ve havadan bakınca şehir İstanbul'a benzemiyor. Sahibi "önce şehri kur,
bölümleri sonra içine sığdırırız" dedi. Bu yüzden:

1. **Yeni dünya: "İstanbul v2".** Eski `World1453` bölümler taşınana kadar OLDUĞU GİBİ kalır (dokunma; bölümler
   bozulmasın). Şehir, yeni ve bağımsız bir dünyada kurulur.
2. **Ölçek: gerçeğin YARISI, doğrusal, bükmesiz.** Gerçek koordinat: Ayasofya kubbesi (0,0), doğu `e`, kuzey `n`, metre.
   Dünya: `x = e × 0,5`, `z = −n × 0,5` (+x doğu, −z kuzey), `y` arazi yüksekliği (gerçek yükseklik × 0,5).
   Böylece yarımada ≈ 2,6 × 2,8 km; Nihat (7 m/sn, hızlı 18 m/sn, tavan 70 m) şehri 2–6 dakikada geçer.
3. **Anıtlar k = 0,5 ile kurulur** (parçaların önizlendiği ölçek; oyunun var olan Ayasofya modeli ~35 m = gerçeğin
   ~yarısı: uyumlu). İnsan ölçüsündeki her şey (kapı, basamak, korkuluk, tezgâh) gerçek boyda kalır. Evler ve sokaklar
   gerçek boyda (1:1), ev sayısı seyreltilir (alan dörtte bir). Uzun hatlar (surlar, kemer, Mese) gerçek uzunluk × 0,5.
4. **Kıyı gerçek biçimiyle:** Sarayburnu, Haliç'in kıvrımı, Marmara kıyısı, Galata, Üsküdar yakası, Boğaz ağzı. 1453
   kıyısı = deniz surlarının hattı (surlar su kenarındaydı); bugünkü dolgu alanları (Yenikapı, Sarayburnu sahil yolu,
   Eminönü dolgusu) YOK.
5. **Parçalar hazır:** on iki oturum `scripts/world/ist/<ad>*.gd` dosyalarını yazdı/yazıyor (arayüz:
   `docs/_ajan/gorev/_istanbul_ortak.md`: `catalog()`, `build_x(host, k, lod)`, `perches_x`, `climbs_x`). Dallar:
   `wip/ist-surlar`, `-marmara`, `-halic`, `-galata`, `-hipodrom`, `-forumlar`, `-kemer`, `-kuzeybati`, `-guneybati`,
   `-kiliseler`, `-ayrinti`, `-bitki`. `wip/istanbul` dalında önceki birleştiricinin işi var: ev kiti
   (`scripts/world/ist/evler.gd`, mektup bölümünün ev dili), akış/pişirme (`scripts/world/ist/sehir.gd`: lod 2→1→0,
   zaman dilimli, tek ağa pişirme), şehir denetimi (`tests/city_audit.*`), sonda (`tests/_ist/sehir_kare.*`), araştırma
   (`docs/ISTANBUL_1453.md`, `docs/ISTANBUL_YERLER.csv`: 84+ yer, enlem/boylam ve doğu/kuzey metre). Bunları KULLAN;
   eski haritaya bağlayan kancaları (CityHouses/Landmarks1453/HornWorld/World1453 içindekiler) v2'de kullanma ve eski
   dünyada varsayılan olarak KAPALI bırak (`IstSehir.enabled = false`), eski dünya eski hâliyle çalışsın.

## DONDURULMUŞ ARAYÜZ: `scripts/world/ist/geo.gd` (`class_name IstGeo`, `extends RefCounted`)
İki oturum aynı anda çalışıyor ("dünya" bu dosyayı yazar ve ilk 30 dakikada gönderir; "şehir" bu imzalara göre yazar):
```gdscript
const S := 0.5                                              # dünya ölçeği
static func w(e: float, n: float) -> Vector3               # gerçek (doğu, kuzey m) → dünya (x, yükseklik, z)
static func w2(e: float, n: float) -> Vector2              # → (x, z)
static func ll(enlem: float, boylam: float) -> Vector3     # enlem/boylam → dünya (Ayasofya 41.0086, 28.9802)
static func real(x: float, z: float) -> Vector2            # dünya → gerçek (e, n)
static func h(x: float, z: float) -> float                 # arazi yüksekliği (su altında deniz tabanı < 0)
static func su(x: float, z: float) -> bool                 # deniz mi (deniz düzeyi y = 0)
static func sehir_ici(x: float, z: float) -> bool          # surların içinde mi (yarımada)
static func galata_ici(x: float, z: float) -> bool
static func yol(ad: String) -> PackedVector2Array          # dünya (x,z) çoklu çizgi: "kara_suru", "marmara_suru",
    # "halic_suru", "galata_suru", "blakherna_suru", "mese", "mese_kuzey", "mese_guney", "lykos", "zincir", "bozdogan"
static func kiyi(ad: String) -> PackedVector2Array         # kapalı çokgen: "yarimada", "galata", "anadolu", "trakya"
static func mahalle(x: float, z: float) -> Dictionary      # {"ad", "tur": "carsi|sik|seyrek|bostan|harabe|liman|sur_dibi|kir", "yogunluk": 0..1}
static func yerler() -> Array                              # ISTANBUL_YERLER.csv satırları: {ad, tur, e, n, w: Vector3, satir}
```
"Dünya" oturumu ayrıca: `scripts/world/ist/dunya.gd` (`class_name IstDunya`): `static func build(parent: Node3D, gece := false,
merkez := Vector3.ZERO) -> Node3D` araziyi (parça parça ağ + çarpışma, mesafeye göre), denizi, gökyüzünü, ışığı,
uzak ufku (Trakya tepeleri, Anadolu yakası, Boğaz) kurar; `IstSehir`in v2 girişini çağırır.
"Şehir" oturumu: `scripts/world/ist/sehir.gd` içinde `static func attach_v2(dunya: Node3D, gece := false) -> void`:
parçaları, surları, evleri, sokakları, bitkiyi, ayrıntıyı v2'ye yerleştirir ve akışla kurar.

## Ortak kurallar
- Kurulum, testler, yasaklar, izin kutusu kuralları: `docs/_ajan/gorev/_ortak2.md` (oku). Oynanış kuralları (kapalı
  katı, delik yok, tırmanma, havadan bakış kalitesi, Nihat'ın yan görevi): `docs/_ajan/gorev/_istanbul_ortak.md` (oku).
- Eski dünyanın dosyalarına (`scripts/world/world1453.gd`, `horn_world.gd`, `landmarks1453.gd`, `city_*.gd`,
  `scripts/level/*`) DOKUNMA; önceki birleştiricinin oralara eklediği kancalar kalabilir ama kapalı olmalı
  (`parse_check`, `world_check`, `flight_check`, `city_check` ve Bölüm 6, 7, 11, 12b, 24 başsız PASS; eski görünüm).
- Yeni `class_name` serbest. Her 45–60 dakikada bir kendi dalına kaydet ve gönder; öbür oturumun dalını ara ara çek
  ve birleştir (`git fetch origin <dal>:refs/remotes/origin/<dal>` + `git merge`).
- Gezi sahnesi (ikisi de kullanır; "dünya" yazar): `tests/_ist/gezi.tscn`: v2'yi kurar; komut satırı: `-- gece=0|1
  kam=e,n,yukseklik,yon,egim shots=KLASÖR liste=dosya` (liste: satır satır kamera konumları → PNG); ayrıca serbest uçuş
  (WASD + fare) ve yürüyen oyuncu (`scripts/player/player.gd` ile) kipi.
