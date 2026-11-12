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

---

# İKİNCİ TUR (12 Kasım, 08:45 UTC) — KARAR DEĞİŞİKLİKLERİ (bu bölüm üsttekilerle çelişirse BU geçerlidir)

## Sahibin yeni sözleri (aynen)
- "1453 te istanbulun nasıl gözüktüğünü bulabildiler mi güzelde boş alan istemiyorum bir de"
- "içinin scale büyütüp sura yaslayabiliriz"
- "hayır yani aynı anda ayasofya yakın olsun sura"

## Ne demek (yöneticinin kararı)
İlk turun şehri (S = 0,5) fazla büyük ve batı yarısı boş kaldı. Sahibi derli toplu, DOLU bir şehir istiyor: içindekiler
(anıtlar, mahalleler) haritaya göre büyük, surlara yaslı, Ayasofya kara surlarına yakın.
1. **Dünya ölçeği `IstGeo.S = 0,3`** (0,5 değil). Yarımada ≈ 1,6 × 1,7 km; Romanos Kapısı → Ayasofya ≈ 1,4 km (koşarak
   ~4,5 dk, hızlı uçuşla ~80 sn). Kıyı biçimi gerçek kalır. `S` TEK sabit olmalı: koddaki bütün dünya konumları
   `IstGeo` üzerinden türesin; S 0,2–0,5 arasında değiştirilip şehir yeniden kurulabilsin (sahibi "daha yakın" derse
   tek satır). Önceden hesaplanmış çokgen/çizgi tabloları gerçek koordinatta tutulup S ile çarpılsın.
2. **İçerik büyük kalır:** anıtlar k = 0,5 (Ayasofya var olan modeli), evler ve sokaklar 1:1, **surların kesiti 1:1**
   (k = 1,0: iç sur ~12 m, kuleler 18–20 m, dış sur 8,5 m, hendek ~18 m; yalnız uzunluk hat boyunca S ile kısalır).
   S küçüldüğü için anıtlar birbirine yaklaşır: çakışanları öncelik sırasıyla (yan görev eserleri > öteki anıtlar >
   doku) ve gerçek komşuluk sırası korunarak kaydır; çok yer kaplayanları (Hipodrom, Büyük Saray, limanlar, açık
   sarnıçlar, forumlar) k = 0,3–0,4 ile kur. Hiçbir eser atılmaz.
3. **BOŞ ALAN YOK ve ŞEHİR SURA KADAR DOLU:** `docs/_ajan/gorev/ist2_kalite_notlari.md` (0, 0b ve 1–10. maddeler;
   TAMAMI bağlayıcı, oku). Görünüş kılavuzu `wip/istanbul-gorunus` dalında yazılıyor (`docs/ISTANBUL_GORUNUS.md`: renk
   ve malzeme paleti, ev/sokak görünüşü, mahalle ve anıt görünüşleri, "boş alan yok" öğe listesi): ilk hâli 30 dakikada
   gelir; ara ara çek, uygula. Araştırma dizini `wip/istanbul-arastirma` dalında büyüyor (160 satır hedefi): çek.
4. **Yeni parçalar** (yazılıyor; 60. dakikada ilk hâlleri gelir; çek, birleştir, bağla): `wip/ist-ordugah` (Osmanlı
   ordugâhı, bataryalar, hendekler: sur dışı boş kalmasın), `wip/ist-gemiler` (zincirin ardındaki filo, Osmanlı
   donanması, kayıklar: deniz boş kalmasın), `wip/ist-hayat` (insan/hayvan/duman/gece ışıkları katmanı). Arayüzleri
   raporlarında: `IstOrdugah.attach`, `IstGemiler.attach`, `IstHayat.attach` (`dunya`, `gece`).
5. **Dallar (ikinci tur):** taban `wip/ist2-taban2` (birinci turun dünyası + şehri). Üç oturum, dosyalar AYRIK:
   - DÜNYA-2 → `wip/ist2-dunya2`: `scripts/world/ist/geo.gd`, `dunya.gd`, `tests/_ist/gezi.*`
   - ŞEHİR-2 (yerleşim) → `wip/ist2-sehir2`: `scripts/world/ist/sehir.gd` (+ yeni yardımcı dosyalar), sonda/denetim
   - DOKU-2 (mahalle) → `wip/ist2-doku2`: `scripts/world/ist/sokak.gd`, `evler.gd` (+ yeni yardımcı dosyalar)
   Başkasının dosyasına dokunma; gereken değişikliği raporda "ORTAK İSTEK" diye kod parçasıyla yaz ve o dalı çekince
   geldi mi bak. Her 30–45 dakikada kendi dalına gönder, öbür iki dalı çek ve birleştir.


---

# İKİNCİ TUR — SON AYAR (12 Kasım, 08:50 UTC) — yukarıdaki sayılarla çelişirse BU geçerlidir

## Sahibin sözü (aynen)
"ev bin sayısını azaltmaktansa böyle zoom yapıyormuşuz gibi düşün ama aşırı büyük yapma dengeli git hem ev sayısı
arttır hem sur içini küçült hem de ayasofyayı falan büyüt"

## Dengeli ayar ("zoom": harita biraz küçülür, içindekiler büyür ve çoğalır)
- **`IstGeo.S = 0,35`** (0,5'ten küçük, 0,3 değil). Yarımada ≈ 1,9 × 2,0 km; Romanos → Ayasofya ≈ 1,6 km (koşarak
  ~5 dk, hızlı uçuşla ~90 sn). S tek sabit kalır (0,25–0,5 arası değiştirilebilir).
- **Eserler BÜYÜR:** yan görev eserleri ve ünlü anıtlar **k = 0,75** (Ayasofya: var olan model × 1,5: taban ~54 m, kubbe
  tepesi ~40 m; Galata Kulesi ~50 m; Konstantin/Arkadius/Iustinianus sütunları, Havariyun, Pantokrator, Khora,
  Pammakaristos, Studios, Aya İrini, Tekfur, Altın Kapı, kapılar). Öteki anıtlar ve kiliseler k = 0,6. Çok yer
  kaplayanlar (Hipodrom, Büyük Saray harabesi, limanlar, açık sarnıç bostanları, forum meydanları) k = 0,45–0,5.
  İnsan ölçüsündeki ayrıntılar parçalarda zaten k'den bağımsız; Ayasofya gibi düğüm ölçeğiyle büyütülenlerde kapı ve
  basamak 1,5 kat olur: kabul (anıtsal kapı), ama tırmanma basamakları ve konma noktaları yeniden sınanır.
- **Sur kesiti 1:1** (iç sur ~12 m, kuleler 18–20 m, dış sur 8,5 m, hendek ~18 m); uzunluk S ile.
- **Ev sayısı ARTAR:** hedef **9–12 bin ev** (birinci turda 4 003), 1:1 boyda, çoğu 1–2 katlı; sur içi baştan sona
  dolu doku (kalite notu 0 ve 0b). Yoğunluk ortalaması ~55 ev/hektar, çarşıda ve Haliç kıyısında daha sık. Akış ve
  pişirme ile bütçe aynı (uçuşta ≤ 1 500 çizim / 3,5 M üçgen; yerde ≤ 900 / 2,5 M).
- "Aşırı büyük yapma": hiçbir eser komşusunu yutmasın, sokaklar kapanmasın; eser çevresinde meydan/avlu payı kalsın;
  Ayasofya ufukta en büyük yapı, ama evlerin arasında dev bir kütle gibi değil (kubbe tepesi ≈ 6–7 ev yüksekliği).
