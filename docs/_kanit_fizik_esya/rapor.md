# Eşya fiziği — rapor

Dal `wip/fizik-esya` (taban `wip/fizik-taban4` 9af74b12). Godot 4.4.1, GodotPhysics3D (project.godot değişmedi).
Durum dosyası: `durum.md`. Envanter: `dokum.md`. Kareler: `kare/` (1280×720, jpg kalite 85).

## Özet

Dekor eşyası (Dressing `crate/crates/barrel/barrels`, sur yolu ve kule önü stauroma fıçıları) **uyur**: bugünkü durağan
hâli, görünüş aynı. Şu durumlarda o an gerçek gövdeye (`RigidBody3D`) döner:
- boş elle tekme (`kick`),
- koşarak çarpma (≥ 4 m/s),
- yürüyerek dayanma (0,35 sn; ağır eşya yavaş itilir),
- yakında patlama,
- altındaki destek gidince (yığında üstteki).

Fıçı 16 kenarlı dışbükey silindir: dikken tekmelenince devrilir, yan yatınca yuvarlanır. Sandık kutu: kayar ya da
kenarından döner. Durunca zemine oturduğu denetlenir ve **donar** (freeze, durağan kip; yeniden tekmelenebilir). Aynı anda
en çok 12 uyanık gövde; fazlası gelince en eskisi oturtulup donar. Düşen yük (Bölüm 20) ve atılan leblebi (Bölüm 6) artık
gövdeyle düşer, seker, yuvarlanır.

## Maddeler

| # | Madde | Durum | Kanıt / not |
|---|---|---|---|
| 1 | Ölç ve dök | **TAMAM** | `dokum.md`: kurucular, çizim biçimi (MultiMesh / tek düğüm / birleşik ağ), çarpışma, oynanış/dekor ayrımı, bölüm başına kayıt sayısı |
| 2 | Ortak sistem | **TAMAM** | `scripts/level/esya_fizik.gd`. Uyurken maliyet ölçüldü: ~20 µs/kare (aşağıda). Kütleler: fıçı 45, boş fıçı 16, sandık 28, kalas 14, testi 3, gülle 60 kg |
| 3 | Tekme ve çarpma | **TAMAM** | Deney sahnesi a–g. Oyun içi 18, 20, 26, 28o. Ses var olan kitaplıktan: fıçı `land_thud`, sandık/kalas `footstep_wood_1..4`, testi `land_pot`, gülle `kick_metal`. Yeni ses üretilmedi |
| 4 | Düşen / atılan eşya | **KISMEN** | Gövdeye çevrildi: Bölüm 20 `_fall_load`, Bölüm 6 leblebi. Bölüm 0 kasıtlı olarak dokunulmadı (gerekçe aşağıda). `battle_extras` kalkanı başka dosyaya istek. Liste `dokum.md`'de |
| 5 | Güvenlik denetimi `ESYAAUDIT` | **TAMAM** | Zemin altına düşen, havada donan, gömülen, yol tıkayan, sınır aşımı. Bölüm koşularında `sorun=0`. Zorlamalı sınamada iki gerçek bulgu yakalandı ve düzeltildi (aşağıda) |
| 6 | Sınama | **TAMAM** (bir eksik) | Deney sahnesi PASS; oyun içi kareler 18, 20, 26, 28o, 0. Bölüm 6'nın oyun içi tekme karesi yok (aşağıda) |
| 7 | Bütçe | **KISMEN** | Yöneticinin kendi maliyeti doğrudan ölçüldü. Bölüm koşusu ÖNCE/SONRA başsız ölçüm gürültüsü %1'den çok büyük (tablo) |
| 8 | Rapor | **TAMAM** | bu dosya |

## Mimari (kısa)

- **Kayıt.** Kurucu kendi satırında çağırır:
  - `EsyaFizik.kaydet_mm(model adı, Dressing-yerel dönüşüm, tür)` (MultiMesh örneği),
  - `kaydet_dugum(görünen düğüm, durağan gövde, tür)` (tek düğüm; birleşik ağa katılmasın diye `no_bake` işaretlenir),
  - `kaydet_engel` (Dressing yığınındaki birleşik ağa çizilmiş yatık fıçı: uyanmaz, ortak kutu açılınca kendi kutusunu alır).
- **Yönetici.** İlk kayıtta sahneye kurulur (sahne geçişine dayanıklı). Kit.batch'in MultiMesh'leri ağaca girdikleri anda
  durağan bir `node_added` kancasıyla kuyruğa alınır (yalnız kayıtlı modellerin parça ağları). Örnek dönüşümü kayıtla
  eşleştirilir; eşleştirme kare başı ≤ 2 ms'ye bölünür. **Ağaç taraması yok.**
- **Uyanma.**
  - Altında çarpışan zemin yoksa (oyun alanı dışındaki uzak dekor) uyanmaz.
  - Gövde, tabanı altındaki gerçek yüzeye oturtularak kurulur.
  - MultiMesh örneği `WorldWalk.hide_inst` ile gizlenir (ölçek ~0; denetimler aynı şeyi görür); parçalar gövdeye
    MeshInstance olarak gelir.
  - Tek düğüm gövdeye taşınır.
  - Yığının ortak kutusu kapanır; gruptaki uyuyanlar ve engeller kendi kutularını alır.
- **İtki.** GodotPhysics yeni gövdenin kütlesini bir adım sonra işler (o ana kadar ters kütle 1). İlk karedeki itki bir kare
  bekletilir. İlk sürümde 48 kg fıçı 40 m/s'ye fırlıyordu.
- **Tekme.**
  - `Player.kick()` darbe anında tek satır kanca: `EsyaFizik.darbe`.
  - `Traversal._click`: önde tekmelenecek dekor varsa tık tırmanmaya değil tekmeye gider.
  - Tekme tuşunu yönetici okur; yalnız serbest yürüyüşte, boş elle, konuşma/ara sahne yokken.
- **Donma.**
  - Durunca zemin boşluğu ≤ 6 cm değilse simülasyon sürer (9 sn sınırında zemine indirilir).
  - Gömükse ilk yerine konur.
  - Etkileşim alanının (katman 2) üstündeyse alanın dışına itilir.
  - Dar geçitte (iki yanında 1 m boyunca duvar, açıklık < 2,6 m) bir yanında 0,75 m yer kalmıyorsa yakın duvara yaslanır.
- **Patlama.** `Vfx.explosion`'un ışığı (renk ffb050, güç 9) `node_added` ile tanınır. Vfx'e dokunmadım; kanca isteği aşağıda.

## Deney sahnesi `tests/_ist/esya_fizik.tscn` — PASS

```
ESYATEST PASS
ESYAAUDIT OZET kayit=36 uyanan=33 tekme=7 kosu=2 itme=0 patlama=22 destek=2 en_cok_uyanik=12 sorun=0 (dusme=0 havada=0 gomuk=0 tikama=0 sinir=0)
```

Düz zemin, 14° eğim, 5 basamaklı merdiven, 2,4 m'lik sur yolu (korkuluklu); oyundaki kurucuların kendileri; gerçek Player.

| Senaryo | Sonuç (ölçüm) | Kareler (`kare/deney/`) |
|---|---|---|
| a. dik fıçıya tekme | devrildi, yan yattı, 0,74 m; zemin boşluğu 0,00 | `a_fici_1_once` … `a_fici_4_durunca` |
| b. tek sandığa tekme | kenarından döndü, 0,73 m | `b_sandik_*` |
| c. sandık yığınının üstü | üstteki düştü, yan yattı | `c_yigin_*` |
| d. koşarak (5,2 m/s) fıçı kümesine | 2 fıçı itildi, yan yattı | `d_kosu_*` |
| e. eğim: yandan tekme → yatan fıçıya arkadan tekme | yuvarlandı, yokuştan indi: dz = 15,9 m, dy = −2,6 m | `e_egim_1_once`, `e_egim_b_*` |
| f. merdiven başında fıçı | basamaklardan indi: dy = −1,38 m | `f_merdiven_*` |
| g. sur yolu, korkuluğa yaslı toprak dolu fıçı | 0,4 m kaydı, dik kaldı; yanında 1,67 m geçit | `g_suryolu_*` |
| h. patlama (küçük eşya: testi, gülle, kalas) | 6 eşya savruldu, hepsi zemine oturdu | `h_patlama_*` |
| i. düşürme (fıçı + kalas, 1,6 m, yan hız) | seğip yan yattı | `i_dusur_*` |
| j. 16 fıçıya büyük patlama | uyanık en çok 12; hepsi donup zemine oturdu | `j_sinir_*` |

Kare cümleleri (tam boy bakıldı):
- **a_fici_1_once:** dik fıçı zeminde.
- **a_fici_2_03sn:** devriliyor, havada değil.
- **a_fici_4_durunca:** yan yatık, zemine oturmuş, gömük değil. **Silindir**: kutu gibi değil, çemberleriyle yuvarlak.
- **c_yigin_3_1sn:** üstteki sandık yere inmiş; alttakiler yerinde. Havada sandık yok.
- **h_patlama_4_durunca:** gülleler, testiler, kalas zeminde; hiçbiri havada ya da gömük değil.
- **i_dusur_2_03sn:** düşen kalas eğik seğiyor; fıçı havada, düşüyor. Gölgesi altında: düşüş anı, kusur değil.
- **j_sinir_2_durunca:** devrilmiş fıçılar zemine dağılmış. Ortadaki 4 dik fıçı patlama yarıçapı dışındaydı, uyumaya devam.

## Oyun içi kanıt — `tests/_ist/esya_bolum.tscn` sondası

Bölüm oyunun kendi açılışıyla açılır. Sonda oyuncuyu bir dekor eşyasının arkasına koyar ve `Player.kick` ile tekmeletir;
üçüncü kişi kamerasından tekmeden önce / 0,3 sn / 1 sn / durunca kare alır. Arayüz katmanları yalnız kare için gizlenir.

| Bölüm | Eşya | Kareler | Ne görülüyor |
|---|---|---|---|
| 18 (şehir, World1453 rıhtımı) | fıçı | `kare/b18/1..4` | dik fıçı devrildi, yan yattı, 0,74 m. Zemine oturdu, havada/gömük yok, silindir gibi |
| 20 (ordugâh, Osmanlı kampı) | sandık | `kare/b20/1..4` | sandık devrildi, yan yattı (0,63 m); öteki sandığın yanında zemine oturdu |
| 26 (sur içi meydan) | fıçı | `kare/b26/1..4` | fıçı yatık fıçıya çarpıp sekti, yan yattı (0,74 m), zemine oturdu. İlk sürümde yatık fıçının çarpışması kayboluyor, fıçı ona gömülüyordu. Kötüydü, düzeltildi (`kaydet_engel`) |
| 28o (ordugâh) | fıçı | `kare/b28o/1..4` | üç dik fıçıdan biri devrildi, yan yattı, yuvarlanıp zemine oturdu. Komşu fıçılar yerinde |
| 0 (savrulanlar) | — | `kare/b0/bolum0_savrulanlar_donma.jpg` | zaman durdurmasının donmuş karesi: kalkan ve ok demeti **kasıtlı olarak havada** |

**Bölüm 0 savrulanları neden gövdeye çevrilmedi.** Bölüm 0'ın patlaması bir zaman durdurma şakası: dünya donar
(`_pause_world(true)`), kalkan ve oklar havada asılı kalır ("Havada asılı kalan. Fesli olan."). Ardından kaset gibi geri
sarılıp garaja dönülür, dünya hiç devam etmez. Fizik verilirse düşmeleri gereken bir an yok; verilirse şaka bozulur.
Hikâye ve görüntü aynı kaldı.

**Bölüm 20 sur yolu fıçıları — kötü.** Stauroma fıçıları 12 cm arayla dörtlü sıra ve korkuluğa yaslı. Tekmede komşuya
ve korkuluğa dayanıp 3–11 cm kıpırdıyorlar. Gerçekçi ama gösterişsiz; bu yüzden Bölüm 20'nin kanıt karesi ordugâhtan.
Aynı fıçılar Bölüm 20 koşusunda bir kez gerçek gülle patlamasıyla uyandı: `uyanan=3 patlama=3 sorun=0`.

**Bölüm 6 — oyun içi tekme karesi YOK.** Oyuncunun yanında açık yönlü (önü ve arkası boş) dekor eşyası yok; yakındaki tek
sandık çadıra yaslı. Bölüm 6'nın kayıtları (6a 102, 6b 214) koşularda temiz (`sorun=0`). Ordugâh kanıtı 28o'dan.

## Denetimin yakaladıkları (zorlamalı sınama: oyuncuya en yakın 12 eşya aynı anda rastgele itkiyle)

1. **Zeminsiz uzak dekor (Bölüm 6, z≈266).** Sandıklar dünyadan düştü. Denetim yakalayıp ilk yerine koydu (`dusme`).
   - Kök: o dekorun altında çarpışan zemin yok.
   - Düzeltme: zemini olmayan eşya uyanmaz. Zemin denetiminde eşya gövdeleri ve yığının ortak kutusu zemin sayılmaz;
     ilk sürümde alttaki uyanmış sandık "zemin" sanılıyordu.
2. **İki zemin üst üste (28o ordugâhı, (52, −3.5, 163)).** `Ova` ağının üçgen çarpışması y = −3,44'te,
   `Toprak_ZeminOva` 6 cm altında. Sert itkiyle havalanıp düşen sandık ince üçgen kabuğa yarı gömülü kalıyor; denetim
   `gomuk` sayıp ilk yerine koyuyor.
   - Uyanırken tabanı yüzeye oturtmak (Dressing düz y'ye koyuyor, arazi inişli çıkışlı) ve CCD'yi yalnız küçük eşyada
     bırakmak bunu çözmedi.
   - Normal tekme aynı yerde temiz: 20 ve 28o kareleri.
   - **Kök arazide:** "başka dosyaya istek"e yazıldı.

## Bütçe

**Yöneticinin kendi maliyeti.** Doğrudan ölçüm: `_physics_process` süresi, `ESYAAUDIT MALIYET` satırı, başsız, 20 fps
autotest koşusu.

| Bölüm | Kayıt | Uyurken µs/kare (ort.) | En kötü kare µs (sahne başı eşleştirme) |
|---|---|---|---|
| 20 | 85 | 20,8 | 4.028 |
| 26 (hold) | 96 | 19,4 | 1.690 |
| 6 (6b) | 214 | 23,7 | 1.824 |
| deney sahnesi (33 uyanma) | 36 | 44 (uyanıkken 72) | 6.338 |

Uyurken ~20 µs = 60 fps'te 16,7 ms'lik karenin **~%0,12'si**. Ortalamaya sahne başındaki eşleştirme kareleri de dahil;
durağan hâlde birkaç µs.

İlk sürümde sahne başında **250–436 ms'lik tek kare** vardı. Oynanış adları için bütün ağaç taraması 235 ms, ilk
MultiMesh taraması 42 ms, 11 bin MultiMesh'in gruplanması 16 ms tutuyordu. Üçü de kaldırıldı: durağan kanca, yalnız
kayıtlı model ağları, karelere bölünmüş eşleştirme.

**Bölüm koşusu ÖNCE | SONRA.** Başsız, `tests/_ist/esya_bolum.tscn -- --olc`; ÖNCE = aynı ikili `ESYA_KAPALI=1`
(kayıt yok, yönetici yok). Betik ms = `TIME_PROCESS`, fizik ms = `TIME_PHYSICS_PROCESS`, 240 kare ortalaması.

| Bölüm | ÖNCE betik / fizik ms | SONRA betik / fizik ms (dururken) | Tekme anı betik / fizik, en kötü kare | 12 uyanık betik / fizik, en kötü kare |
|---|---|---|---|---|
| 20 (1. koşu) | 8,09 / 0,89 | 7,59 / 0,85 | 8,74 / 0,80, 12,9 ms | 12,55 / 1,45, 8,7 ms |
| 20 (2. koşu) | 9,18 / 0,78 | 12,08 / 1,77 | — | 10,77 / 0,89, 8,5 ms |
| 26 | 46,9 / 5,12 | 43,1 / 4,95 | 102,0 / 5,91, 200 ms (*) | (*) |
| 28o | 11,95 / 1,78 | 14,89 / 1,27 | 8,57 / 1,36, 9,0 ms | 8,57 / 1,36, 10,3 ms |
| 6 | 9,03 / 4,16 | 8,08 / 4,00 | — | 9,12 / 4,97, 13,0 ms |
| 18 | 19,73 / 3,72 | 8,40 / 4,29 | — | 33,6 / 4,62, 9,8 ms |
| 0 | 46,1 / 2,42 | 50,9 / 3,22 | — | 39,0 / 1,55, 54,6 ms |

**Bu tablo +%1 / +%5 sınırını kanıtlamaya yetmiyor.** Aynı bölümün iki koşusu arasındaki fark (20: 7,6 ↔ 12,1 ms)
aranan farktan çok büyük. Bölüm o sırada kendi akışını oynatıyor (konuşma, ara sahne, yükleme); 26'nın tekme penceresine
200 ms'lik bir oyun karesi denk geldi. (*) 26'da zorlamalı uyandırmada eşyaların hepsi zeminsiz ya da etkileşim
alanındaydı (uyanık 0).

- **Fizik ms.** 12 gövde uyanıkken ÖNCE değerine göre +0,5 ms civarı (20: 0,89 → 1,45; 6: 4,16 → 4,97).
- **Çizim çağrısı.** Bölüm 20, pencere (xvfb, yazılım çizimi), başlangıç görüşü: ÖNCE 2989, SONRA 2986. Fark yok.
  - Sur yolu fıçılarının birleşik ağdan ayrılması (`no_bake`, ~69 fıçı) o görüşte görünmüyor. Sur yolunun göründüğü bir
    kadrajda ölçülmedi.
  - Kare ms pencerede ölçülemedi: yazılım çiziminde kare ~1,1 sn.

## Testler (son kodla)

- `res://tests/parse_check.tscn` → `PARSECHECK PASS scripts=363`
- `tests/_ist/sur_sozlesme.tscn` → `SURSOZLESME PASS kalem=13 kesim=8`
- `tests/_ist/sur_oyun_denetim.tscn` → `SUROYUN nokta=519 havada=0 gomuk=0 katida=0`
- `tests/_ist/sur_oyun_yuru.tscn` → `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`
- Bölümler (`--max-fps 20`, tam süzgeç `AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|
  WARN_FLY|WARN_VOID|ESYAAUDIT`): **31/31 PASS**. Hiçbir koşuda süzgeçten sorun satırı çıkmadı; `ESYAAUDIT` yalnız OZET,
  hepsinde `sorun=0`.

| Koşu | Sonuç | Kayıt | Uyanan (oyunun kendi akışında) |
|---|---|---|---|
| 20 varsayılan, tape, late, hit, lose, niko_idle, idle, --difficulty=0, --difficulty=2 | 9/9 PASS | 85 | 0–5 (gülle patlaması sur yolu fıçılarını uyandırdı), sorun 0 |
| 26 hold, hold_box ×3, varsayılan | 5/5 PASS | 96 / 233 | 0 |
| 0 | PASS | 69 | 0 |
| 6 varsayılan, b, c, y, letter, byz, byzmistake, byzfail, byzclimb, byzgive | 10/10 PASS | 102 / 214 | 0 |
| 8y, 17o, 18, 18b, 28o, 29 | 6/6 PASS | 104, 130, 96, 96, 89, 96 | 0 |

Önceki Bölüm 20 `--difficulty=0` koşusunda bir kez görülen `VISAUDIT personhidden` (Giustiniani konuşmacısı) son koşuda
çıkmadı. Fizikle ilgisi yok (o koşuda uyanan eşya 0); tabanda da çıkıp çıkmadığını ayrıca sınamadım.

## Kalanlar

- **Yalnız kayda geçen eşyalar uyanıyor.** Dressing `amphora/basket/sack(s)/pots/bench` ve bölümlerin `dd.cyl` ile
  birleşik ağa çizdiği fıçılar (Bölüm 18'in 7 dik fıçısı, siege_field barut çadırı) yetkim dışında (yalnız
  crate/crates/barrel/barrels) ve birleşik ağda tek tek gizlenemiyor. Bunlar için kurucunun eşyayı Kit modeli / MultiMesh
  olarak çizmesi gerekir.
- **Bölüm 6'nın oyun içi tekme karesi:** yukarıda.
- **Bölüm 20 sur yolu fıçıları:** sıkışık; tekmede az kıpırdıyor (gerçekçi).
- **Kişiler:** eşya kişiye çarpınca yalnız seker (yığılma sistemine bağlantı yok, istendiği gibi). Kişinin üstünden
  yuvarlanmayı ayrıca sınamadım.
- **Dar geçit denetimi:** 2,6 m'den dar geçidi "yol" sayıyor. Daha geniş yollarda eşya ortada donarsa itilmez (geçit
  kalır).

## run_tests.sh isteği

- Paketin ön denetimlerine deney sahnesi: `timeout 300 "$GODOT" --headless --path . res://tests/_ist/esya_fizik.tscn`,
  `ESYATEST PASS` yoksa `fail=1`.
- `run()` içindeki süzgece `ESYAAUDIT` eklenmesi. Bölüm koşularında yalnız OZET/MALIYET satırı çıkar; `ESYAAUDIT dusme|
  havada|gomuk|tikama…` gibi sorun satırı çıkarsa hata sayılması: `grep -q "^ESYAAUDIT \(dusme\|havada\|gomuk\|tikama\)"`.

## Başka dosyaya istek

1. **`scripts/level/vfx.gd` (sahibi kim ise):** `Vfx.explosion(parent, pos, size)` içine tek satır
   `EsyaFizik.patlama(pos, size)`. Bugün patlama ışığın rengi ve gücüyle (ffb050, 9) `node_added` üzerinden tanınıyor;
   ışık değişirse kopar.
2. **`scripts/level/battle_extras.gd:520` (düşen askerin kalkanı):** tween yerine
   `if not EsyaFizik.dusur(sh, "kalas", Vector3.UP * 1.5): <eski tween>`.
3. **Arazi (siege_field / Ova, 28o ordugâhı):** `Ova` ağının üçgen çarpışması ile `Toprak_ZeminOva` 6 cm arayla üst
   üste. Sert itkiyle düşen gövde ince kabuğa gömülüyor. İkisinden biri kaldırılmalı ya da yüzeyler aynı yükseklikte
   olmalı.
4. **Kurucular (`dressing.gd` amphora/basket/sack/pots, bölüm `dd.cyl` fıçıları):** fiziğe katılmaları için Kit modeli /
   tek düğüm olarak çizilip `EsyaFizik.kaydet_mm/kaydet_dugum` ile kayda geçmeleri.

## Dokunulan dosyalar

| Dosya | Değişiklik |
|---|---|
| `scripts/level/esya_fizik.gd` (yeni) | ortak sistem |
| `scripts/level/dressing.gd` | yalnız `crate()`, `barrel()`: kayıt satırları (+ yatık fıçı engel kaydı). Görünüş aynı |
| `scripts/world/ist/surlar_ayrinti.gd` | `_barrel` kayıt parametresi (`esya := false`; gedik çağrıları değişmedi), dekor çağrıları (kule önü, `_stauroma`) `true` geçer |
| `scripts/player/player.gd` | yalnız `kick()` darbe anında `EsyaFizik.darbe(...)` |
| `scripts/player/traversal.gd` | yalnız `_click` tekme tıkı |
| `scripts/chapter20.gd` | yalnız `_fall_load`: tween → `EsyaFizik.dusur` (süreler, ses, silinme aynı) |
| `scripts/chapter6.gd` | yalnız `_scatter_chickpeas`: yay tween'i → `EsyaFizik.dusur` (aynı süre) |
| `tests/_ist/esya_fizik.*`, `tests/_ist/esya_bolum*.*` (yeni) | deney sahnesi, bölüm sondası |
