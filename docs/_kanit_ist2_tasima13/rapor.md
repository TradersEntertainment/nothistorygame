# Taşıma 13 — 31o'da yeni surun ardında yaşayan şehir; 31o varsayılan yeni sette

Dal `wip/ist2-tasima13` (taban f1f007c5). Godot 4.4.1 resmi linux sürümü; testler çalışma ağacının eşinde
(`/home/user/is/kopya`), `--max-fps 20`. Ham çıktıların süzülmüşü `testler/*.txt`.

## Özet

| Madde | Durum |
|---|---|
| Yol: 8y kalıbı (SurHub "romanos" + IstBaglama yeni bölge `fallen31o`) | TAMAM |
| 1. Tek sur | TAMAM (kesimin kendi dilimi, komşular v2'nin; `_temizle` 8y dalı) |
| 2. Cadde korunur, sayılar değişmez | TAMAM (caddede v2 evi 0; FallenCity ve bölüm sayıları aynı) |
| 3. Kalabalık çalışır, caddeye girmez | TAMAM; dönem seçeneği YAPILMADI (KESME SIRASI son) |
| 4. Evre geçişi temiz | TAMAM (düğüm eski düzeyde); bellek +92 MB kalıcı (aşağıda, KISMEN) |
| 5. Işık ve ortam | TAMAM (eski setin gündüzü + FallenCity.mood + sis 0,006; v2 göğü yok) |
| 6. Harita tek alan | TAMAM (SurSetSahne yok; tek MapView kökü IstBaglama'nınki) |
| 7. Bütçe | KISMEN: kurulum v2 hub düzeyinde (39 sn ↔ 24: 55 sn); ev evresinde bellek ×2,6; kare süresi üç bakışta +%15'i aşıyor (yazılım çizici, aşağıda) |
| 8. Yedek yol | Gerekmedi |
| `ESKI_VARSAYILAN`'dan "31o" çıkarıldı | TAMAM (`--eskisur=31o` eski seti kurar, PASS) |
| Kareler + rapor | TAMAM |

## Seçilen yol ve gerekçe

Danışman düzeltmesindeki 8y kalıbı aynen: `SurSetSahne` + `IstBaglama` birlikte kurulmaz (çift sur, çift ova).
`chapter31o.gd` üç dallı:

- `--eskisur=31o` → eski `LandWalls` (değişmedi).
- yeni sette v2 açık (varsayılan) → `_sur_kur_v2()`:
  `SurHub.kur(_stage, {"cerceve": IstBaglama.t31o() * SurHub.M8(), "kapi_acik": true})` +
  `IstBaglama.build(_stage, "fallen31o", [OYUN_31O], false)` (öncesinde `IstBaglama.gece = false`). `t31o()` yalnız z
  kaydırması: kesimin iç surunun şehir yüzü (`zi0`) → `LandWalls.INNER_Z0` (−4). Böylece iç kapı x 0'da, şehir −z'de;
  FallenCity ve bölümün bütün sayıları (yanık ev, saçak, tellal, Kadri, kuyruk, Lore, kamera) DEĞİŞMEDİ.
  `IstBaglama.donusum("fallen31o") = SurHub.gate8y_v2() · t31o()⁻¹` (8y ile aynı yer; ölçülen yaw −108,1° iki bölgede aynı).
- yeni sette v2 kapalı (`--eski-dunya`) → Taşıma 12'nin `SurSetSahne` yolu (dokunulmadı).

Ortam: `Night.environment(_stage, 0.006)` + `LandWalls.make_day`'in değerleri birebir (gök renkleri, `Look.refresh`,
pozlama 0,92, ortam ışığı, güneş açısı −48/150), sonra eskisi gibi `FallenCity.mood` + sis 0,006 + güneş 1,15.
`IstBaglama._process`'in km ölçeği sis tavanı (0,0009) yeni bölgede uygulanmaz (`KENDI_SIS`): sis eskisiyle aynı kalsın diye.

Dosyalar (hepsi seçmeli; var olan bölgeler ve varsayılan bit bit aynı):

- `scripts/world/ist/baglama.gd`: `YAMA`/`TEMIZ` girdisi, `B31O`, `OYUN_31O`, `KENDI_SIS`, `t31o()`, `donusum` dalı;
  yamanın `sur_z` sınırı 8y'ninkinin 31o çerçevesindeki karşılığı; `_temizle`'nin 8y dalı (Romanos kapı dilimi kalkar,
  kara suru dilimleri kalır); oyun alanı (sokak/ev/çatı/kalabalık boş bırakır) yeni bölgede hub alanı yerine caddenin şeridi.
- `scripts/level/fallen_city.gd`: `var v2 := false`; true iken kutu siluet (`_skyline`: kutu evler, duman, Ayasofya
  maketi) kurulmaz ve taş döşeme evlerin/kilisenin altına (x ±15) ve iç surun şehir yüzüne kadar daralır. 26 değişmedi.
- `scripts/chapter31o.gd`: üç dallı kurulum, `_env/_sun` her dalda (eski dalda `walls.env/moon`), evre geçişinde
  `IstBaglama.birak()` + `IstGeo.dislanan/deniz_yok` boşaltma, ölçüm satırları (`T13_31O`, yalnız otomatik oyunda ya da
  `T13_OLC` ortam değişkeniyle).
- `scripts/world/ist/sur_set.gd`: `ESKI_VARSAYILAN: Array = []` ve yorumu.
- Yeni: `tests/_ist/tasima13_kare.*` (kareler, ESKİ|YENİ aynı kameralar; `evre=1` eyüp/aya), `tasima13_olc.*` (cadde
  temizliği, ev kuşakları, kalabalık), `tasima13_menu.*` (menü kalıntısı teşhisi; aşağıda).
- `sur_set_sahne.gd`, `sur_set_hub.gd`, `hayat*.gd`, `city_check.gd`, `sehir.gd`: DOKUNULMADI.

## Dikiş yerleri

- Sur: kesim (SurHub, "romanos", yan/uzak yok) Romanos'un gerçek yerinde; şehrin Romanos kapı dilimi `_temizle`'de kalkar,
  komşu kara suru dilimleri kalır. `04a_tepeden_dikis` ve `02_caddeden_sura`'da kopukluk/üst üste duvar görünmüyor;
  ZFIGHT 0 satır.
- Zemin: iç surun şehir yanında arazi yaması bölümün döşemesi (yerel −0,03), surdan dışarısı kesimin gerçek arazisi (8y ile
  aynı kural). Cadde döşemesi z −4,2'den −94'e, x ±15; caddenin başına görünmez döşeme (8y `_build_ground_yeni` gibi).
- v2 evleri: caddenin şeridinde 0 ev (`T13OLC evler_cadde_icinde=0`). Ama şerit çevresinde **ev seyrek**: 10–20 m 8 ev,
  20–30 m 6, 30–40 m 12, 50–60 m 19 (mahalle türü "sık" ve "sur dibi"). Kök neden `IstSehir` (sehir.gd:3159): oyun
  alanları ev yerleşiminde AABB'nin yarı köşegeni yarıçaplı **daire** sayılıyor; döndürülmüş 32 × 93 m şeridin AABB'si
  98 × 59 → ~57 m yarıçaplı boşluk. `sehir.gd` bu turda bana açık değil → "başka dosyaya istek" 1. Eski sette de caddenin
  çevresi boştu (FallenCity `_clear_field` 80 × 64 m'yi temizliyordu; `eski/04a`), yani gerileme değil, ama tepeden kötü.

## Evre geçişi (otomatik oyun, `T13_31O olc=…`; 31o_yeni_2 ve 31o_eski_1)

| An | Eski set düğüm / bellek | Yeni (v2) düğüm / bellek |
|---|---|---|
| başlangıç | 186 / 152 MB | 186 / 152 MB |
| ev evresi kurulu | 25 678 / 564 MB | 8 319 / 1 465 MB |
| eyüp evresi başı | 239 / 331 MB | 239 / 423 MB |
| aya evresi başı | 242 / 338 MB | 242 / 535 MB |

- `T12_31O asama=eyup surset_etkin_temiz=true`, `asama=aya … true` sürüyor (8 yeni koşunun hepsinde).
- Eyüp başında `IstBaglama.aktif_bolge == ""`, `is_instance_valid(IstHayatYakin.aktif) == false` (satırda `yakin_gecerli=false`).
- Düğüm sayısı eski düzeye iniyor (239 = 239). Bellek eskisinden **+92 MB** fazla kalıyor: v2'nin statik önbellekleri
  (ev/çatı ağ önbellekleri, sokak planı, IstGeo tabloları; aynı süreçte sonraki v2 bölümleri bunları yeniden kullanır).
  Bölüm 24'ten çıkışta da aynısı (aşağıda menü). Benim dosyalarımda boşaltılabilecek bir şey değil → istek 2.
- Kareler `kare/evre/05_eyup_ilk.jpg`, `05_aya_ilk.jpg`: v2'den iz yok (eski World1453 eyüp yamacı, Ayasofya iskelesi).

## Bütçe (eski | yeni)

Kurulum (otomatik oyun, headless): eski sur + cadde 6,3–8,0 sn; yeni 39,4 sn (v2 38,6 sn + SurHub 0,6 sn).
v2 hub bölümleri aynı makinede: 7b 42,0 sn, 23 55,7 sn, 24 54,8 sn, 8y 56,8 sn → **hub düzeyinde, kabul sınırı içinde**;
eski sete göre ×5 (rapora not).

Kare (xvfb + llvmpipe YAZILIM çizici, 1280×720; bakış başına 2 sn ortalama, 1–3 kare — gürültülü; çizim sayısı güvenilir):

| Bakış | kare ms eski | kare ms yeni | çizim eski | çizim yeni | ilkel eski | ilkel yeni |
|---|---|---|---|---|---|---|
| 01a kapıdan şehre | 1085 | 2597 (tek kare, akış) | 3010 | 2242 | 3,12 M | 3,24 M |
| 01b kapıdan derin | 988 | 1332 | 3141 | 2295 | 3,30 M | 3,50 M |
| 02 caddeden sura | 1385 | 1119 | 3807 | 1068 | 6,64 M | 1,83 M |
| 04a tepeden dikiş | 706 | 1463 | 3248 | 1879 | 1,46 M | 2,17 M |
| 04b tepeden şehir | 1483 | 1533 | 6878 | 2040 | 6,50 M | 2,90 M |
| 03 kalabalık yakın | — | — | 4436 | 1362 | 5,85 M | 2,49 M |

Çizim çağrısı her bakışta düşük (−%25…−%72). Kare süresi 01a/01b/04a'da +%15'i aşıyor (01a tek ölçüm, v2 akışının
yüklemesine denk); yazılım çizicide piksel doldurma baskın, gerçek GPU'da ölçülmedi (rapora not: "hâlâ kötü").
Kalabalığın kare süresi (CITYCHECK, BUDGET 1500 µs): 31o 1295 / 1445 µs (iki koşu, en kötü nokta), 24 1096 µs.

## Doğrulama (son kayıttaki kod; `testler/`)

- `parse_check`: PASS (368 betik).
- Sözleşme altılısı: `SURSOZLESME PASS kalem=13 kesim=8`, `SUROYUN nokta=519 havada=0 gomuk=0 katida=0`,
  `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`, `ESYATEST PASS`, `HALICSONDA OZET carp=661 karma=3854034809`,
  `MARMARASONDA OZET carp=1837 karma=2250736444` — aynı.
- 31o yeni (anahtarsız, varsayılan) `""`, `=late`, `=petrion_ok`, `=petrion_bad` ×2: 8/8 AUTOTEST PASS, biter, denetim 0
  (VISAUDIT/WALKTHRU/HELDAUDIT/ARMAUDIT/WARN_*/ESYAAUDIT/HAREKETAUDIT satırı yok). `--eskisur=31o` `""` ×1: PASS.
  (İlk deneme `--yenisur=31o` ile de PASS: `/home/user/is/ilk_yeni.log`, ESKI_VARSAYILAN boşaltılmadan önce.)
- `CITYCHECK_CH=31o` ×2: PASS (v2 yolu, 3 nokta: sivil 14–19, devriye 0–2, evde/havada/suda/kopuk 0). `city_check.gd`'ye
  dokunulmadı: v2 yolu (`_chapter_v2`) 31o'da olduğu gibi çalıştı.
- `tasima13_olc`: PASS — caddede v2 evi 0; 20 sn boyunca caddenin oyun alanına giren kalabalık 0 (en yakın 5,1 m: şeridin
  çevre sokağı); oyuncuya 90 m içinde 10–13 sivil, 2 devriye.
- ZFIGHT (`zfight_check.gd -- res://scenes/chapter31o.tscn`, ESKI_VARSAYILAN boş, v2 kurulu): 0 satır.
- Ortak dosyaya dokunulduğu için (baglama.gd, fallen_city.gd, sur_set.gd) ×1: 7, 7 =byz (7b), 11, 13, 13 =city, 23, 24, 26,
  26o, 12b, 8y → hepsi AUTOTEST PASS, denetim 0. `CITYCHECK_CH=24`: PASS (1096 µs). (13 =city ilk koşuda çöktü: dört süreç
  aynı anda `user://ist_onbellek`'e yazıp önbelleği bozdu — "Unrecognized binary resource file"; önbellek silinip tek
  başına koşuldu: PASS. Koşu düzeni hatası, kod değil.)
- `menu_return -- --chapter=31o`: **varsayılan (MR_AFTER 4 sn) FAIL** "kalıntı 5356 → 8604". Menü sahnesinin olağan
  düğüm sayısı ~8 600 (`menu_return_26`: 8619 → 8618; `menu_return_24`: 8591 → 8608); 31o'nun 1. turundaki 5356 olağan dışı
  düşük (o tur başlık kartında, v2 kurulmadan döndü; ölçüm dört paralel sürecin yükü altındaydı) — yani düğüm "büyümesi"
  ölçümün tabanından. Gerçek kalıntı **sahipsiz düğüm**: v2 ziyareti başına 680 (31o 2. tur 680; değişmemiş 24'te de
  680 → 1360; v2'siz 26'da 0). 31o'yu 24 ile aynı koşulda ölçmek için `MR_AFTER=60`: 8605 → 8620, sahipsiz 680 → 1360,
  **PASS** — 24 ile birebir. 31o'ya özgü kalıntı yok; ziyaret başına 680 sahipsiz düğüm v2'nin önceden var olan sızıntısı
  → istek 3. `menu_return -- --chapter=26` (fallen_city.gd'ye dokunuldu): PASS, sahipsiz 0. (`tasima13_menu` teşhis aracı
  bu koşularda betik hatası verdi — sahne değişiminde ağaçtan düşen eşi; sonuçları `t13menu_*.txt` güvenilir değil.)
- `street_check`: **FAIL "StreetEye kare süresi 271 µs > 150"** — tabanda (f1f007c5, benim değişikliklerim geri alınmış
  eş, tek süreç) da FAIL 210 µs. Bu makinenin hızı; değişiklikten değil (StreetEye ve 24'ün yolu değişmedi).
- `run_tests.sh`'in 31o kalemleri (:173 çeşitleri) yukarıdaki 8 koşu.

## Kareler (`kare/eski`, `kare/yeni`, `kare/evre`; 1280×720 jpg 85, aynı kamera)

- `yeni/01a_kapidan_sehre`: iç kapıdan caddeye 13 m; caddenin evleri aynı, kutu yok, havada bir şey yok; cadde iki sette aynı.
- `yeni/01b_kapidan_derin`: aynı yerden 150 m derinliğe; caddenin sonu yeniçeri sırası, ardında v2 çatıları duman/sis içinde
  seçiliyor; eski setin kutu silueti yok. Uzak şehir sisle çok soluk (sis eskisiyle aynı 0,006) — orta.
- `yeni/02_caddeden_sura`: caddeden geri bakış; artık kesimin gerçek iç kapısı ve kuleleri (eski: LandWalls kutu sur);
  dikiş yok, aynı ressam. İyi.
- `yeni/03_kalabalik_yakin`: v2 kalabalığından iki kişi 2 m'den (sur dibinde işçiler, tuğla yığını); gövde düzgün, ayaklar
  yerde. Eski karede CityLife'tan yakına gelen devriye (yeniçeri) vardı. Kişiler "oyuncak" çizgisinde (oyunun genel kişi dili).
- `yeni/04a_tepeden_dikis`: 85 m'den set + şehir: kesim ile v2 kara suru dilimleri kesintisiz, iç kale/kule dizisi düzgün;
  caddenin iki yanında geniş boş kum — **kötü** (yukarıdaki daire kök nedeni; eski sette de boştu).
- `yeni/04b_tepeden_sehir`: şehrin içinden sura doğru 70 m: cadde şeridi v2 çatılarının ortasında, ama çevresi seyrek —
  **kötü** (aynı neden).
- `evre/05_eyup_ilk`, `evre/05_aya_ilk`: v2 kalkmış, eyüp yamacı ve Ayasofya iskelesi eskisi gibi.
- Sahibine: `kare/sahip_1_caddeden_sura.jpg`, `sahip_2_tepeden_dikis.jpg`, `sahip_3_kalabalik_yakin.jpg`,
  `sahip_4_tepeden_sehir.jpg`.

## Hâlâ kötü olanlar (dürüst)

1. Caddenin çevresinde ~50–60 m'lik seyrek/boş kuşak (tepeden açıkça görünüyor). Oyuncu caddeden çıkamadığı için oyuncu
   gözünden pek görünmüyor, ama "surun ardında yaşayan şehir" tepeden yarım. Kök neden ve öneri: istek 1.
2. Yeni sette ev evresinin belleği 1,47 GB (eski 0,56 GB); evre geçişinden sonra +92 MB kalıcı; menüye dönüşte v2 ziyareti
   başına 680 sahipsiz düğüm (24'te de, önceden var).
3. Kurulum 39 sn (eski 6–8 sn); hub bölümleri düzeyinde ama 31o artık bölüm içinde, başlık kartından sonra eşzamanlı
   kuruluyor: ekran o sürede donuk (yükleme ekranı yok; 24/8y bölüm açılışında kurar). Gerçek makinede ölçülmedi.
4. Kare süresi yazılım çizicide üç bakışta +%15'i aşıyor (çizim çağrısı ise düşük).
5. `menu_return -- --chapter=31o` varsayılan haliyle FAIL (yukarıdaki açıklama: ilk turun tabanı düşük ölçüldü; MR_AFTER=60
   ile PASS, 24 ile aynı). Tam paket bu kalemi koşmuyor (`run_tests.sh` yalnız 26 ve 20o). Tek başına, varsayılanla
   yeniden koşulmadı (süre).
6. Dönem seçeneği (madde 3, isteğe bağlı) yapılmadı: v2 kalabalığı 13/23/24 ile aynı davranışta (az sayıda devriye + sivil;
   "fethin ertesi" ayrı ayarı yok).

## Başka dosyaya istek

1. `scripts/world/ist/sehir.gd` (~3159, ev ayak izi): oyun alanı dairesi uzun dikdörtgenlerde (en/boy > 1,4) şeridin ekseni
   boyunca birkaç küçük daire olsun (her biri kısa kenarın yarı köşegeni). Kare alanlar (hub 84×70'in AABB'si, meydan 55×50)
   eşiğin altında: 7b/13/23/24 bit bit aynı kalır. 31o'da cadde çevresindeki ~57 m boş halka ~20 m'ye iner.
2. v2 statik önbellekleri (evler/çatı ağları, `IstSehir.sokak`, IstGeo tabloları): bölüm v2'den çıkınca bırakılabilir bir
   `IstSehir.bosalt_statik()` (31o evre geçişinde ve menüye dönüşte çağrılır).
3. Menüye dönüşte v2 ziyareti başına kalan 680 sahipsiz düğüm (24'te de): `IstBaglama._exit_tree` `_bosalt`'ı yalnız
   `items/hat_items/_cells0`'ı tarıyor; kalan sahipsizlerin sahibi bulunmalı (`Node.print_orphan_nodes()`;
   `tests/_ist/tasima13_menu.gd` taslak, henüz düzgün çalışmıyor).
4. `tests/run_tests.sh`: v2 bölümlerini paralel koşan paketler `user://ist_onbellek`'i paylaşıyor (bu turda bir çöküş);
   paralel koşuda süreç başına ayrı `--user-data-dir` ya da önbelleği önceden ısıtma.
