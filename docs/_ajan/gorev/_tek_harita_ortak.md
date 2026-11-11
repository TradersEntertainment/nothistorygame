# Tek harita göç paketleri: ortak kurallar (bağlayıcı)

Oyun sahibinin sözü: "tüm İstanbul tek harita, tüm görevler aynı harita; her şey full içerik, kalite; performans için
yaratıcı şeyler bulursun, uzakken yüklenmez". Şikâyeti: Nihat'la uçunca gördüğü İstanbul'un yerde oynadığı yerlerle
alakası yoktu. Hedef: 1453'te geçen her bölüm tek dünyanın (World1453) gerçek bir yerinde oynanır; o yer başka
bölümlerden ve havadan bakınca AYNI yerde, AYNI biçimde durur; uzaklık yalnız ayrıntıyı değiştirir.

## Kurulum (bu makinede bir kez)
1. Godot 4.4.1: https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip → aç, yolu `G`. xvfb-run, ffmpeg, imagemagick yoksa kur (apt).
2. Depo kökünde bir kez `$G --headless --import` (bitmesini bekle).
3. Başsız test: `timeout 600 $G --headless --max-fps 20 --path . -- --chapter=N --autotest[=varyant]` → `AUTOTEST PASS`; şu satırlar OLMAMALI: `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_MISS`, `JOURNEY_OVERLAP`. Varyantlar: `tests/run_tests.sh`. Betik denetimi: `timeout 120 $G --headless --path . res://tests/parse_check.tscn`. Dünya denetimleri: `res://tests/world_check.tscn`, `city_check.tscn`, `flight_check.tscn`.
4. Ekranlı koşu (kare): `PACE=1 timeout 2400 xvfb-run -a -s "-screen 0 1280x720x24" $G --path . --resolution 1280x720 -- --chapter=N --autotest[=varyant] --dialogshots=KLASÖR --shotevery=1 --snapevery=0.5`.

## Önce oku
- `docs/_ajan/tek_harita.md` (bölüm→harita tablosu §A, World1453 mimarisi §B, hedef §C, göç planı §D, ORTAK ARAYÜZ §F: yayımcı işlevler, `World1453.bake`, `FAR_REGIONS`, `Flame.from_glow_boxes`). Not: bu arayüz ana makinede hâlâ geliştiriliyor; bu dalda gördüğün hâlini kullan, imzalarını DEĞİŞTİRME.
- `scripts/world/world1453.gd` (REGIONS, build, keep/flat_y/BLEND), örnek bağlanmalar: `scripts/chapter31o.gd`, `chapter38o.gd`, `chapter17o.gd`, `scripts/level/camp_day.gd` (in_world), `scripts/level/byz_city.gd` (`far_hub`), `scripts/level/blachernae.gd` (`shell_parts`).
- `docs/_ajan/ajan_kurallari.md`, `docs/QA_DERSLER.md` son dersler, `CLAUDE.md`.

## Değişmeyecekler
Var olan replik metni ve sırası; akış, süreler, gizli sayaçlar, denge, sonuçlar; kalabalık sayısı; test botunun yolu
(oynanış alanının YEREL koordinatları aynı kalır: yer değiştirme bölge dönüşümüyle yapılır); karakterlerin görünüşü.
Yeni `class_name` dosyası yok. Denetimleri susturmak yok. Ses üretimi yok. PR yok. `main`e dokunma. Alt ajan başlatma.

## Ortak dosyalar
`scripts/world/*.gd` ana makinedeki ajanın: yalnız EKLEME (ör. `REGIONS`/`FAR_REGIONS` içine bir kayıt, `match` içine bir
satır, yeni statik işlev); var olan işlev ve imzalara dokunma; eklediğin her satırı raporda dosya:satırla yaz. Bundan
fazlası gerekiyorsa uygulama: raporda kod parçasıyla öner.

## Performans (şart; "uzakken yüklenmez")
- Bölümün her evresinde: çizim sayısı ≤ 900 ve üçgen ≤ 2,5 M (yerde), ya da bugünkü değerin en çok +%10'u (hangisi
  büyükse). Bugünkü değer daha yüksekse artırma.
- Yükleme süresi (sahne açılışından ilk kareye) en çok +1,5 sn; kurulumu karelere yay (bkz. `WorldWalk`, 12 ms/kare).
- Uzak şey tam ayrıntıyla kurulmaz: birleşik ağ (`World1453.bake`), MultiMesh, `visibility_range_*` (kenar payıyla:
  birden belirme/kaybolma yok), kalabalık ve ışık mesafeyle seyrelir, görülmeyen (duvarın arkası, iç mekânın dışı) hiç kurulmaz.
- Ölç: oyunun `RINFO` çıktısı, ÖNCE ve SONRA aynı replik anında üçer örnek.

## Kanıt (şart)
- "Aynı yer" çifti: (a) bölümün içinden, yerden, oyuncunun gözünden ufka bakış; (b) bir uçuş bölümünden (7 ya da 11,
  Nihat'ın uçuşu; ya da serbest kamera sondası, adı `sonda_`) aynı dünya koordinatına havadan bakış. İkisinde yapılar,
  yerleşim, renkler aynı mı, kare üstüne koordinatı yaz.
- Her değişiklik için AYNI koşu, AYNI replik anı ÖNCE|SONRA çifti (ÖNCE: dalın başlangıç kaydı; dosyaları
  `git show <kayıt>:<dosya>` ile geçici eski hâline koy, koş, `git checkout -- <dosya>` ile geri al).
- Kendi karelerine bak: havada duran, gömülü, küp gibi kalan, birden beliren, titreyen (z-fighting), boşluğa açılan,
  dünyanın evinin/çadırının içine giren bir şey var mı? Varsa düzelt.
- Kanıtsız hiçbir şeye "düzeldi" deme; görmediğine "KANITSIZ", bakmadığına "BAKILMADI" yaz. Bağımsız denetçi kendi
  koşusuyla sınayacak.

## İzin kutusu
İzin kutusu çıkaracak komut yazma: `rm -rf`/`mv`/`cp -r` hedefinde kabuk değişkeni kullanma (açık yol yaz ya da yeni
klasör aç); sudo yalnız apt kurulumu için. Arka planda koşu başlattıysan bitmesini bekle; rapor gönderilmeden durma.

## Teslim
Kod + `docs/_kanit_<paket>/rapor.md` + en çok 12 pafta (JPEG, ≤ 300 KB) kendi dalına kaydedilir ve gönderilir. Rapor:
ne taşındı (dosya:işlev), ortak dosyalara eklenen satırlar, "aynı yer" çiftleri, test sayıları ve hata satırları aynen,
RINFO ve yükleme süresi tablosu, açık kalanlar, ortak dosyalar için öneriler.
