# İstanbul, Nisan 1453: parça (modül) oturumları için ortak kurallar — ZORUNLU

Türkçe çalış. Soru sorma, plan sunma, onay bekleme: başla, bitir, gönder. HEDEF: şehir BUGÜN bitecek; sen onun bir
parçasını kuruyorsun, on beş kadar oturum aynı anda başka parçaları kuruyor. Kimseyle konuşamazsın; bu dosyadaki arayüz
dondurulmuştur, AYNEN uy (yoksa parçan şehre takılamaz).

## Sahibin sözleri (12 Kasım, aynen)
- "kanka bence sen önce 1453 nisanda istanbul nasılmış ona çalış sonra bence bölümleri içine sığdırırız, peter çok
  detaylı istanbul yapmış ya günümüz o promtpları örnek al bunu 1453 nisan yap ve şekiller vs bizim oyna uysun tolganın
  tırmanabileceği içinden düşmeyeceğimiz şekilde falan olsun bizim şu anki tolganın mektup bölümündeki evleri
  kullanabilirsin şekil olarak galiba"
- "kank gerekirse çalışan sayısını arttır ama bu istanbulu bugün bitir"

Oyun: "Gerçek Tarih Bu Değil", Godot 4.4.1 (gl_compatibility), 1453 kuşatmasında geçen birinci şahıs komedi. Her şey
GDScript ile, ilkel parçalardan çizilir (`scripts/level/props.gd`: `Props.box/solid/cyl/ball/prism/ring/ramp`,
`Props.mat`, `Props.set_pattern` ile taş/tuğla/sıva/kiremit desenleri; `scripts/level/kit.gd`). Üslup: düşük poligon,
çizgi film, sıcak renkler. ÜSLUP ÖRNEĞİ (oku, paleti ve oranları buradan al): `scripts/level/byz_city.gd` içindeki
`_house`, `_build_street`, `_build_chancery`, `_build_palace` (Tolga'nın mektup bölümü), `aya_exterior` (Ayasofya),
`scripts/level/blachernae.gd` `shell_parts` (sur ve saray), `scripts/level/land_walls.gd` (kara surları).
AYRINTI ÖRNEĞİ: `docs/_ajan/istanbul_prompt.txt` (günümüz İstanbul'u için; ayrıntı yoğunluğunu al, 1453'te olmayan her
şeyi at: minare, cami, köprü, vapur, çanak anten, cam, asfalt…).

## Kurulum
1. Godot 4.4.1: https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip
   → aç, yolu `G`. `xvfb-run`, `imagemagick` yoksa `apt-get install -y` ile kur.
2. Depo kökünde bir kez `$G --headless --import` (üretilen `.import` dosyalarını KAYDETME).
3. Ayrıştırma: `timeout 200 $G --headless --path . res://tests/parse_check.tscn` → `PARSECHECK PASS`.

## Araştır (20–30 dakika, fazla değil)
WebSearch/WebFetch ile kendi parçanın Nisan 1453'teki hâlini öğren: yeri, ölçüsü (metre), malzemesi, rengi, o günkü
durumu (sağlam / harap / bostan olmuş), ayırt edici biçimleri. Bulduklarını kaynak adıyla raporun başına yaz
(15–40 satır). Emin olmadığını BELİRSİZ yaz; uydurma ayrıntıyı "kestirim" diye işaretle. Anakronizm yasak.

## DONDURULMUŞ ARAYÜZ
Yalnız YENİ dosya yaz; var olan hiçbir dosyayı değiştirme (çakışma olmasın):
- `scripts/world/ist/<ad>.gd` (bir ya da birkaç dosya; `class_name Ist<Ad>` serbest; `extends RefCounted`)
- `tests/_ist/<ad>_onizleme.gd` + `.tscn` (kendi önizleme ve denetim sahnen)
- `docs/_kanit_ist_<ad>/` (rapor ve paftalar)

Her yapı/öğe için aynı kalıpta STATİK işlevler (yapının adı `X` olsun):
```gdscript
## Kayıt: şehir kurucusu bunu okuyup yerleştirir.
static func catalog() -> Array:
    return [{
        "id": "x",                       # küçük harf, benzersiz
        "ad": "…",                       # Türkçe görünen ad
        "dogu_m": 0.0, "kuzey_m": 0.0,   # GERÇEK konum: Ayasofya kubbesi (0,0); doğu ve kuzey metre (bilinmiyorsa kestirim)
        "gercek_olcu": Vector3(en, yukseklik, boy),   # gerçek ölçü, metre
        "yon_derece": 0.0,               # yapının ana ekseninin kuzeyden saat yönünde açısı
        "durum": "saglam|harap|bostan|…",
        "tur": "anit|kapi|sur|kilise|ev|liman|bitki|ayrinti",
    }, …]

## Kurucu: host'un altına, YEREL koordinatta kurar. Merkez tabanın ortası, zemin y = 0, +x doğu, -z kuzey
## (yon_derece = 0 iken). k = oyun ölçeği (dünya gerçeğin küçültülmüşü; şehir kurucusu 0,3–1,0 arası verir).
## lod: 0 = yakın (tam ayrıntı + çarpışma), 1 = orta (ana kütleler + çatı, ≤ %15 üçgen), 2 = uzak siluet (birkaç kutu/kubbe).
static func build_x(host: Node3D, k: float = 0.5, lod: int = 0) -> void

## Uçuş konma noktaları ve sokaktan çatıya yollar (yerel koordinat, k ile ölçekli).
static func perches_x(k: float = 0.5) -> Array      # [Vector3, …]
static func climbs_x(k: float = 0.5) -> Array       # [[alt: Vector3, ust: Vector3, "merdiven|sandik|basamak|iskele"], …]
```
ÖLÇEK KURALI (çok önemli): `k` yalnız KÜTLEYİ ölçekler (taban, yükseklik, aralıklar = gerçek ölçü × k). İnsan ölçüsündeki
her şey k'den BAĞIMSIZ gerçek boyda kalır: kapı 2,0–2,4 m, basamak ≤ 0,3 m, korkuluk/mazgal 1,0–1,1 m, pencere, tezgâh,
merdiven, sandık, yürüme yolu genişliği (≥ 1,4 m). Kat sayısı k'ye göre azalabilir (kule 20 m × 0,5 = 10 m: iki kat).
k = 0,35, 0,5 ve 1,0 için önizlemede kur ve bak: üçünde de inandırıcı ve oynanabilir olmalı.

## OYNANIŞ KURALLARI (şart; sahibin sözü: "Tolga tırmanabilsin, içinden düşmeyelim")
- Görünen her kütle KAPALI katıdır: duvarlar ve çatı/üst yüzey `Props.solid` (ya da eşdeğer StaticBody3D + kutu).
  Çatıda durulabilir; eğimli çatı görseldir, altında/üstünde düz katı yüzey vardır (kayıp içine düşme yok).
- Delik yok: oyuncu (yarıçap ~0,35 m, boy ~1,8 m) hiçbir aralıktan yapının İÇİNE, iki kütlenin ARASINA ya da zeminin
  ALTINA düşemez/sıkışamaz. İki katı arasındaki girilebilir aralık ya ≥ 1,4 m (geçit) ya 0 (bitişik). Avlu, sarnıç,
  hendek gibi çukurların yürünür bir tabanı ve bir ÇIKIŞI (rampa/merdiven) olur.
- Tırmanma: oyuncunun çıkabildiği yükseklikleri `scripts/player/player.gd` (`JUMP`, `STEP_H`) ve
  `scripts/player/traversal.gd` içinden HESAPLA (zıplama yüksekliği = JUMP² / (2 × yerçekimi)); raporda yaz. Her
  yapıda sokaktan üst yüzeye en az bir doğal yol (sandık yığını, alçak sundurma, dış merdiven, iskele, yıkık duvar
  basamakları); adımlar bu yüksekliğe göre. Tırmanılmaması gereken yer (yüksek sur yüzü) düz ve tutunmasızdır.
- Havada duran parça yok (her şey bir şeye oturur); gövdeye/duvara yarım giren parça yok; z-çakışması (titreyen yüzey)
  yok (üst üste yüzeylere ≥ 2 cm pay).
- Işık/ateş: `scripts/level/flame.gd` (`Flame`) kullan; parlak sarı kutu ateş yasak.
- Performans: lod 0'da yapı başına ≤ 60 bin üçgen (büyük külliye ≤ 150 bin), lod 1 ≤ %15'i, lod 2 ≤ 600 üçgen.
  Yinelenen parçalar (mazgal, kemer, sütun, kiremit sırası, pencere) MultiMesh ile. Her karede ağ kurma yok.

## Önizleme ve KENDİ denetimin (`tests/_ist/<ad>_onizleme.tscn`)
Sahne: düz zemin, güneş (öğleden sonra, sıcak), gökyüzü; parçalarını k = 0,5 ile yan yana kurar; komut satırından
`-- ist=<id> k=0.5 lod=0 shots=KLASÖR` alır. Şu kareleri PNG yazar (1280×720): oyuncu gözünden (1,7 m) dört yönden
yaklaşma, kapı önü yakın plan, ÇATIDA/üst yüzeyde oyuncu gözü, 15 m ve 60 m yükseklikten kuş bakışı (Nihat'ın uçuşu),
tam tepe, lod 1 ve lod 2 aynı açıdan. Ayrıca otomatik denetim basar: `ISTAUDIT id=… tris=… draws=… delik=… dar=…
havada=… cati_yolu=…` (zemine 0,5 m ızgarayla yukarıdan ışın: yapının tabanı içinde çarpışmasız görünür yüzey = delik;
iki katı arası 0,2–1,4 m girilebilir aralık = dar; tabanı zeminden > 5 cm yukarıda kütle = havada; sokaktan çatıya yol
sayısı: `climbs_x` noktalarını gerçek bir CharacterBody3D ile adım adım sına). Ekranlı koşu:
`xvfb-run -a -s "-screen 0 1280x720x24" $G --path . --resolution 1280x720 res://tests/_ist/<ad>_onizleme.tscn -- …`.
KARELERİNE KENDİN BAK (Read ile aç), kusurları listele, düzelt; en az ÜÇ tur. "Kutu yığını" görünümü kabul edilmez:
her anıt bir bakışta tanınmalı (silüet + ayırt edici ayrıntı + doku).

## Yasaklar
Var olan dosyaları değiştirme. Ses üretme. PR açma, `main`e dokunma. Alt ajan / başka oturum / zamanlanmış görev yok.
`pkill`/`killall` yok. İZİN KUTUSU çıkaracak komut yazma, çıkarsa iş kilitlenir: `rm -rf`/`mv`/`cp -r` hedefinde kabuk
değişkeni yok; `bash -c '…'` içinde `until`/`while` bekleme döngüsü ve `sleep` zinciri yok (uzun koşuyu arka planda
başlat, bitiş bildirimini bekle); geçici dosyalarını `/tmp` yerine ev klasöründe açtığın tek bir çalışma klasöründe
tut; `sudo` yalnız `apt-get` için; reddedilen komutu yineleme, başka yoldan yap.

## Teslim ve zaman
- İlk 60 dakikada: bütün öğelerinin lod 2 + kaba lod 0 hâli ve `catalog()` → kaydet, kendi dalına gönder
  (`git push -u origin <dal>`). Şehir kurucusu oturumu dalını bu andan itibaren çekip yerleştirmeye başlar.
- Sonra ayrıntıyı derinleştir; her 45–60 dakikada bir kaydet ve gönder. Toplam süre hedefi: 3 saat.
- `docs/_kanit_ist_<ad>/rapor.md`: araştırma özeti (kaynaklı), öğe listesi (id, ne, durum: TAMAM / KABA / YAPILMADI),
  `ISTAUDIT` satırları, üçgen sayıları (lod 0/1/2), bilinen kusurlar, bakamadıkların + en çok 12 pafta (JPEG ≤ 300 KB;
  yerden, çatıdan, havadan). Arka plan koşuların bitmeden ve `git push` doğrulanmadan durma.
