# SUR-ARAYÜZ — sur sözleşmesi, oynanış arayüzü, kesim kurucusu, eksik parçalar (§5.2 "0. adım")

> Dal `wip/ist2-sur-arayuz` (taban `wip/ist2-sur-bolum-dokumu` + `wip/0.99.119` birleşimi). Bu oturumda **bölüm taşınmadı**,
> sur görünüşü değiştirilmedi (tek istisna 4e etek düzeltmesi, aşağıda). Kanıtlar bu klasörde.

## Denetim son satırları

```
SURSOZLESME PASS kalem=13 kesim=8
SUROYUN nokta=1186 havada=0 gomuk=0 katida=0
WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0
OTURTMA ornek=3227 bosluk=0 gomuk=6 yarik=26 levha=6
BIRLIK malzeme=238 kategorisiz=0 doygunluk_asan=0 duz_buyuk_yuzey=0 saf_beyaz=0
HAVADA pencere=0 esya=0 cati=0
PARSECHECK PASS scripts=352
```

OTURTMA hedefi (hepsi 0) **tutmuyor**, ama bu oturumdan önce de aynıydı: TUR-6 SONRA ölçümü `gomuk=6 yarik=26 levha=6`
(`docs/_kanit_ist2_tur6/rapor.md:106`). Bu oturumun 4e etek değişikliği sayıları değiştirmedi. Bölüm testleri son kodla
(`sehir_denetim_ve_bolumler.txt`): 30, 30o, 20, 26, 26o, 12b, 7, 11 → hepsi `AUTOTEST PASS`; SCRIPT ERROR 0, VISAUDIT 0,
WALKTHRU 0. Birleştirmeden hemen sonra da aynı sonuç alınmıştı.

```
```

## Madde madde

| # | Madde | Durum | Kanıt |
|---|---|---|---|
| 0 | `wip/0.99.119` ile birleştirme | **TAMAM** | kayıt `a56c32d4`. Çakışmalar: `i18n/strings.csv` iki tarafın ekleme bloğu birlikte (bu dalın 38 v2 yer adı satırı + 0.99.119'un bölüm 44 satırları; yinelenen anahtar yok), `.translation` ve `shadow_body.gd.uid` 0.99.119'dan, `docs/_ajan/gorev/ist2_kalite_notlari.md` bu daldan. 0.99.119'un **sildiği** 69 `docs/_*` dosyası (çakışma değil, temiz silme) bu dalın hâliyle geri kondu (kural "docs/_* bu dalınki kalır" — tartışmalı yorum, not). `scripts/world/ist/` 0.99.119'da değişmemişti. Birleşik kodla `PARSECHECK PASS scripts=349` (ilk), sonda 352. |
| 1 | Sur sözleşmesi (dondurma) | **TAMAM** | `scripts/world/ist/sur_sozlesme.gd` + `sur_sozlesme_donmus.json`, `docs/SUR_SOZLESME.md`, `tests/_ist/sur_sozlesme.tscn` → `sur_sozlesme_cikti.txt`. 13 kalem (kesit, kule, kapı ölçü/yer, gedik + kural, merdiven, hendek rampası, çarpışma, dünya yeri, yan dilimler, oyun yerleri), 8 kesim. Bozma denemesi: oyun gediği 0 → 12 yapınca `SURSOZLESME fark kesim/mesoteikhion/gedik/x[0] canli=12.0 donmus=0.0` (+ poterna, dayama, geçiş satırları) yazdı. |
| 2 | Oynanış arayüzü | **TAMAM** (kara suru) / **KISMEN** (Blakherna, Haliç yok) | `scripts/world/ist/sur_oyun.gd`; sorgular `docs/SUR_SOZLESME.md` "Oynanış arayüzü". Denetim `tests/_ist/sur_oyun_denetim.tscn`: 8 kesim, 1186 nokta, **havada 0, gomuk 0, katida 0** (`sur_oyun_denetim.txt`). `blakherna` (Blachernae kabuğu) ve `halic` (IstHalicSur) ayrı kurucular: bu oturumda arayüze girmedi — 30/30o pilotu için **ilk iş** bu. |
| 3 | Kesim sahnesi kurucusu | **TAMAM** | `SurOyun.kur(kesim, secenekler)`: oyun dilimi (lod 0) + iki yan dilim (lod 0; Mesoteikhion'un kuzey yanı şehirdeki Romanos kapı koşusu) + uzak katman (her yanda 2 × 110 m, lod 2) + zemin levhaları + parçalar. Ölçüm aşağıda. |
| 4a | Poterna | **TAMAM** | `Poterna` (açılır kanat, çarpışmalı, eşik); dış kuşak aşağıdaysa sahanlık + 15 taş basamak (Mesoteikhion dy −3,7). Kareler `08_poternadan`, `03_kopru_ustunden`. |
| 4b | Hendek geçişleri | **TAMAM** | `KalasKopru` (21,8 m, iki A-sehpa ayak, tak/sök), `Dolgu` (12 sepet adımlı toprak set, 0..1), `KapiKopru` (sağlam/yıkık + dış kapıdan terasa toprak rampa). Hepsi üstünde yürünür (yürüyüş 4, 5, 7). |
| 4c | Dayalı hücum merdiveni | **TAMAM** | `HucumMerdiveni`: içinde gerçek `Ladder` (boy/eğim dayamadan), `it()` (chapter30 `_push` ile aynı tween), `devir()`, `dik()`, `cizgi()` (`climb_anim.set_line` tarifi). Gösterimde 6 azap `climb_anim.attach` ile basamak basamak tırmanıyor (CLIMBAUDIT satırı yok). Bot yürüyüşü 3 dayalı merdivenden sura çıktı. |
| 4d | Gedik (4 aşama + moloz rampası) | **TAMAM** | `GedikOnarim.asama(1..4)`: açık → kazık/fıçı (ortada 2,2 m geçit) → toprak set (geçit kapanır, 1,4 m çarpışma) → barikat tam (sur yolu tahtası + kazık çit). Moloz rampası peribolostan gediğe, terasa ve hendek dibine yürünür (yürüyüş 5, 6). Oyun gediğinde var olan stauroma kurulmuyor (`gedik_sade` seçeneği). |
| 4e | Sur dibi etek takılması (§3.4) | **TAMAM** (bulundu ve düzeltildi) | Neden: iç kulenin kaide eteği (sur_oturtma_ag `kule()`, 3,2–4,2 m yana) yanındaki taş merdivenin ilk basamağının üstüne taşıyordu: etek 0,284 m > basamak 0,255 m; bot basamağın 0,5 m önünde 8 sn kaldı (`sehir_icmerdiven` ilk koşu). Düzeltme: merdiven ayak izinde (+1 m) kule eteği yere iner (`kes["yasak"]`; şehirde de geçerli). Ayrıca poterna ve parateikhion geçitlerinin önünde etek kurulmuyor (yalnız oyun kesiminde). Kapıda: Romanos kesiminde kapı → peribolos → dış kapı → köprü → ova takılmasız. |
| 5 | Yürüyüş kanıtı | **TAMAM** | `tests/_ist/sur_oyun_yuru.tscn` → `yuruyus.txt` (aşağıda tablo). |
| 6 | Gösterim + kareler | **TAMAM** (kalite KISMEN) | `tests/_ist/sur_oyun_demo.tscn`: 12 kare (10 gündüz + 2 gece) + 4 ÖNCE|SONRA çifti, 1280×720 jpg 85 → `kare/`. Hâlâ kötü olanlar aşağıda. |
| — | §6 karar satırları | **TAMAM** | `docs/SUR_BOLUM_TASIMA.md` §6: 14 maddenin her birine "KARAR (sahibi, 13 Kasım): …" |
| — | Yön söyleyen replikler (karar 14) | **TAMAM** | `yon_replikleri.md` (24 replik, metne dokunulmadı) |
| — | Eski yardımcılar tablosu | **TAMAM** | aşağıda |

## Önemli bulgular (taşımayı etkiler)

1. **Oyun gediği Romanos kapısının 57 m güneyinde** (belge "170 m" diyordu). Şehir kapıyı `YER2`'ye (s = 955,9), gedikleri
   katalog noktasından (s = 1008,6) ölçüyor; 1. gedik s = 898,6, kapı koşusu 925,9–985,9. Mesoteikhion oyun dilimi bu
   yüzden kapı koşusunun hemen güneyinde biter, kuzey yan dilimi **şehirdeki Romanos kapı koşusunun aynısı** (karar 11:
   26'nın finali aynı sahnede). 2. gedik oyun diliminin içine düşüyor (x 34,87; dekor/kapalı, stauromalı).
2. **Dış kademe (dy):** Mesoteikhion'da teras/hendek/ova peribolostan **3,67 m aşağıda** (Romanos 3,55; Pege 5,5; Pempton 8,8;
   Kharisios 11,1; Altın Kapı 0). Belgedeki "Mesoteikhion düz" ölçümü sur çizgisi boyuncaydı. Sonuç: dış sur dışarıdan
   8,5 + 3,7 ≈ **12,2 m**; dış kapı ve poterna terasa 3,6 m yüksekten açılır → poterna basamağı ve kapı rampası eklendi.
   `D26O_T_CLIMB` ("Sekiz metre") bununla çelişir (replik değiştirilmedi; listede).
3. **Kapı koşusu 60 m** (`IstSehir.GATE_L`), `_gate_len` 150 değil; kapı kesimleri şehirle aynı olsun diye 60 m. Kısa koşuda
   hendek rampasının ayağı komşu dilimin hendek uç bölmesine düşüyor (rampa yürünmez); arayüz bu rampaları vermez.
   Kapı koşusunda taş merdiven yok (yan dilimlerde; arayüz `cikislar()` onları da verir).
4. **v2 kusuru (görünüşe dokunulmadı):** gediğe yakın dış kule kurulmuyor ama iki yanındaki kule tepesi basamakları yine
   kuruluyor (`surlar.gd _run` `for cx3 in otx`): Mesoteikhion x 28,96'da sur yolu 13 m'ye çıkıp boşluğa biter. Arayüz bu
   aralığı `kesik` verir. Ayrıca kapı kanatları kuşatma gereği kapalı ve çarpışmalı: 26/8y/31o için `KapiKanat` (seçenekle
   kurucunun kanatları kurulmaz, oynanış kanatları açılır).
5. **Kesim sahnesi ↔ şehir:** oyun dilimi ve kapı koşuları şehirle aynı boy/tohum/seçenek; ama şehir hattı 30–110 m'lik
   dilimlere bölüyor (`sehir.gd _hatlar_v2`), Mesoteikhion'un 190 m'lik oyun dilimi şehirde **tek dilim değil**: kule x'leri
   şehirdekiyle aynı değil (kesim sahnesi tek başına oynanır; şehir içinde bölüm oynanacaksa dilimleme bu sözleşmeye
   uydurulmalı — açık iş).

## Ölçüm: kurulum ve bütçe (karar 12)

Başsız `Time.get_ticks_msec`, 3 koşu (`olcum_cizim.txt`); pencereli 1280×720, xvfb + opengl3, 4 bakış. Yeni = Mesoteikhion
kesimi (oyun + yan + uzak + parçalar + 3 dayalı merdiven; askersiz), eski = `LandWalls.new()` (tam, gedikli).

| | Kurulum (başsız, ms) | Çizim çağrısı (ova / peribolos / hava / sur yolu) | İlkel (aynı sıra) |
|---|---|---|---|
| **Yeni kesim** | 813 / 781 / 767 (≈ 0,79 sn) | 148 / 188 / 168 / 162 | 197 k / 191 k / 198 k / 213 k |
| **Eski LandWalls** | 5918 / 5188 / 5241 (≈ 5,4 sn) | 5195 / 6127 / 5277 / 5277 | 1,60 M / 3,73 M / 1,83 M / 3,31 M |

Kurulumun kırılımı (`SurOyun.kur` `ms`): oyun dilimi ≈ 450–580 ms, iki yan dilim ≈ 220–370, uzak katman ≈ 8, zemin < 1,
parçalar 13–40 ms. Parçaların bütçesi: ÖNCE (yalnız sur) 129–158 çağrı → SONRA (parçalar + 6 tırmanan asker) 270–470;
askersiz ölçümde 148–188. İlk sürümde parçalar pişmiyordu (+700 çağrı); `Props.bake_static` ile düzeltildi. Asker
iskeletleri pişmez (asker başına ≈ 40–50 çağrı) — bölümler kalabalığı yine Assault'un toplu çizimiyle vermeli.

## Yürüyüş (gerçek `Player` botu, 3,2 m/sn, `yuruyus.txt`)

| Yol | Süre | Yol (m) | Takılma | Düşme |
|---|---|---|---|---|
| şehir önü → iç taş merdiven → iç sur yolu → dilim ucu (kule geçidi dâhil) | 48,0 sn | 161,4 | 0 | 0 |
| peribolos → dış taş merdiven → dış sur yolu → dış kule üstünden | 20,2 sn | 75,0 | 0 | 0 |
| teras → **dayalı el merdiveni** → dış sur yolu → kule geçidi (−32,3) → öbür yan | 14,9 sn (merdiven 6,7 sn) | 48,2 | 0 | 0 |
| peribolos → **poterna** → sahanlık + dış basamak → teras → **kalas köprü** → ova → geri | 34,9 sn | 111,5 | 0 | 0 |
| peribolos → **gedik molozu** → teras → **dolgu (dolu)** → karşı yaka → ova | 14,4 sn | 47,4 | 0 | 0 |
| gedik molozu → hendek dibine (dolgu yarım) | 6,8 sn | 23,6 | 0 | 0 |
| Romanos: şehir → **kapı (açık)** → peribolos → dış kapı → **kapı rampası** → **kapı köprüsü** → ova | 20,3 sn | 66,2 | 0 | 0 |

İlk koşularda bulunan ve düzeltilenler: iç merdiven dibinde takılma (4e), dayalı merdiven/poterna/gedikte düşme (yerel
kipte dy yanlış yerden ölçülüyordu → `_dy_kaydet`), gedik molozunun terasa 48° şevi (→ ≤ 30°), dış kapıdan 3,6 m düşüş
(→ kapı rampası). `VISAUDIT`: bu sahnede HUD yok (VISAUDIT HUD'un kişi denetimidir) — kişi denetimi bölüm taşınınca.

## Eski set yardımcıları ↔ yeni arayüz (yardımcılar DEĞİŞTİRİLMEDİ)

| Eski sabit / kullanım | Nerede | Yeni sorgu |
|---|---|---|
| `LandWalls.BREACH`, `BREACH_W` | Assault, WallFight, ch20/26 | `gedik()["x"]`, `["dikdortgen"]` (en 8,0) |
| `LandWalls.rubble_y(x)`, `tongue_y`, `TONGUE_Z/W` | Assault (gedik yamacı, hendeğe dil) | `gedik()["moloz"]` {peri, tepe, teras, hendek} + `sur_oyun_ag.moloz_profil()` (boy kesiti) |
| `LandWalls.OUTER_H`, `OUTER_Z`, `INNER_H` | Assault, Garrison (savunucu yüksekliği) | `yol("dis"/"ic")["y"]`, `["z"]`; `mazgallar()` (savunucu `ayak`, `bakis`) |
| `LandWalls.EDGE_W`, `outside_y` | Assault (hendek kıyısı, ova) | `hendek()["uzak_kiyi"]`, `y_ova()`, `alanlar()["ova"]` |
| `LandWalls.ditch_filled`, `fill_y` | Assault (26o dolgusu) | `Dolgu.doluluk(f)` + `hendek()["gecis"]` (tur "dolgu") |
| `set_repair(n)` (10 aşama) | ch20 | `GedikOnarim.asama(1..4)` (karar 5-B) |
| Assault merdiven ayağı z 18,35 / tepe (7,7; 16,25) | Assault | `dayamalar()` {ayak, tepe, boy, egim} + `HucumMerdiveni` |
| Assault `gun_spots` (z 92–94) | Assault | `bataryalar()` |
| Assault `keep` (Rect2 ova yürüme alanı) | Assault | `alanlar()["ova"]` + `engeller()` |
| `Garrison.land_walls(skip, near…)` kule boşlukları | Garrison | `yol("dis")["gecit"/"kesik"]`, `mazgallar("dis")` (kule ve basamak aralıkları zaten dışarıda) |
| `WallFight.add_cauldron(pos)` (±8,6; 8; 15) | WallFight | `mazgallar("dis")[i]["ayak"]` |
| `WallFight.add_carriers(a, b)`, `add_builders(site)` | WallFight | `cikislar()`, `alanlar()["peribolos"]`, `gedik()["moloz"]["peri"]` |
| `SiegeChaos.area` (Rect2 peribolos) | SiegeChaos | `alanlar()["peribolos"]` + `dogma("peribolos", n)` |
| ch26 POSTERN, ch36b LANE_X | bölümler | `poterna()` |
| ch36b/37o kalas, BRIDGE_Y | bölümler | `KalasKopru` + `hendek()["gecis"]` (tur "kalas") |
| ch8y GATE_Z / BRIDGE_Z | ch8y | `kapi()` {ic_esik, peri, dis_esik, kopru_yakin, kopru_uzak} + `KapiKanat`, `KapiKopru` |
| ch26 sur yoluna ışınlama (`lad.x − 1,9; OUTER_H; 14,95`) | ch26 | `dayamalar()[i]["yol"]` |

Eksik kalan (bu arayüzde karşılığı yok): `Garrison` kişi yerleştirmesinin kendisi, `Assault` dalga yolları (WaveRunner
hedefleri) — bunlar noktaları sorgudan alacak biçimde bölüm taşınırken bağlanır.

## Kendi karelerime bakınca hâlâ kötü olanlar (dürüst)

- `05_sur_yolundan_asagi`: kadraj kötü — korkuluk ve dişler önü kapatıyor, merdiven ve tırmanan ancak köşede; sur yolundan
  aşağı bakış istendiği gibi okunmuyor.
- `07_gedikten`: gediğin üstünde havada duran **yeşil kutular** (var olan sarmaşık ayrıntısı, gedik oyulsa da yerinde
  kalıyor; benim parçam değil, KUTU YASAĞI ihlali) ve ufukta uzak katmanın koyu kutuları (lod 2 dilimin hendek/parateikhion
  kütleleri düz ova levhasının üstünde).
- `02_hendek_kiyisindan`: yakın yaka hendek rampasının uç yüzü (var olan `sur_zemin rampa`) beyaz üçgen okunuyor; dolgu bu
  rampanın üstüne biniyor (oyun gediği x −67,7, rampa −77,5…−60,8) — dolgu yeri ile rampa çakışıyor.
- Ova ve şehir önü **düz levha** (kesim sahnesinde arazi yok); havadan karelerde (`09`, `10`) kum/çim tek renk.
- Poterna kanadı (`08`) açıkken griye yakın okunuyor; ahşap deseni zayıf.
- `ONCE|SONRA`: sur gövdesi aynı; gedikte stauroma yerine aşama parçaları geliyor (beklenen), oyun gediğinin kenarında dış sur
  yolu üstündeki ayrıntı fıçıları (var olan) stauroma tahtası kalkınca açıkta görünüyor (`SONRA_06`).

## Kutu sayımı (yeni parçalar)

`sur_oyun_parca.gd`: `Ag.kutu` 15 çağrı — hepsi düz kesitli ahşap/taş (kalas, kiriş, kanat tahtası, demir kuşak, söve, eşik,
korkuluk), `Props.solid` 2 (zemin levhaları), `IstSurlar._s` 1 (poterna sahanlığı) + `_stairs_x` taş basamakları.
Canlı ya da yuvarlak hiçbir nesne kutu değil: fıçı (`_barrel`, silindir), sepet ve kazık (silindir), toprak set (küre),
taşlar (`kaya_mesh`), moloz/dolgu (eğri tümsek ağı). `sur_oyun_ag.gd`: 0.

## Sözleşme özeti

Kesit: iç sur 5,0 × 12,0, iç kule 9 × 6 / 19, peribolos 15, dış sur 2,6 × 8,5, dış kule 4,5 × 4 / 13, teras 10, hendek 20 × 6;
yürüme yolu iç 4,1 / dış 1,7; iç kule geçidi 2,2 × 3,0; korkuluk 0,45 × 1,2; gedik 8,0; poterna 1,4 × 2,3. Kesimler,
kule/merdiven/dayama yerleri ve dünya yerleşimi: `docs/SUR_SOZLESME.md`. Kalem özetleri: `tests/_ist/sur_sozlesme_beklenen.txt`.

## Değişen dosyalar

- Yeni: `scripts/world/ist/sur_sozlesme.gd`, `sur_sozlesme_donmus.json`, `sur_oyun.gd`, `sur_oyun_parca.gd`, `sur_oyun_ag.gd`;
  `tests/_ist/sur_sozlesme.*`, `sur_sozlesme_beklenen.txt`, `sur_oyun_denetim.*`, `sur_oyun_yuru.*`, `sur_oyun_demo.*`;
  `docs/SUR_SOZLESME.md`, bu klasör.
- Değişen (yalnız seçenekle açılan kancalar; şehir kurucusu vermez → görünüş aynı): `surlar.gd` (poterna boşluğu,
  parateikhion geçidi, sade oyun gediği, etek kesikleri), `surlar_kapi.gd` (`kanat_disarida`).
- Değişen (davranış, 4e): `sur_oturtma_ag.gd` — merdiven ayak izinde kule eteği yere iner (şehirde de).
- `docs/SUR_BOLUM_TASIMA.md` §6 karar satırları.
- Bölüm betikleri, eski setler, ortak kişi/ses/arayüz dosyaları, replikler: **dokunulmadı**.

## Yapılmayan / açık iş

- Blakherna (30/30o pilotu) ve Haliç kesimleri arayüze girmedi (ayrı kurucular) — pilotun ilk adımı.
- Kesim sahnesi şehrin dilimlemesiyle birebir değil (bulgu 5).
- Assault/Garrison'ın kişi ve dalga yerleşimi arayüze bağlanmadı (yardımcılar değiştirilmedi; tablo yukarıda).
- Bölüm başına geri dönüş anahtarı (karar 13) bölüm taşınırken kurulacak; bu oturumda bölüm yok.
