# Bağımsız denetim — fragman kusurları (Bölüm 0, 2, 12) · `wip/denetim-kusur`

Denetlenen: ÖNCE `1e3a9b60` → SONRA dal ucu `fe1ef427` (`scripts/chapter0.gd`, `chapter2.gd`, `chapter12.gd`).
Araç: Godot 4.4.1 resmî Linux sürümü, xvfb + yazılımla çizim (llvmpipe), 4 çekirdek. Oyun kodu değiştirilmedi
(`git diff` boş). ÖNCE ve sonda koşuları depo dışında, `/tmp` altındaki geçici kopyalarda yapıldı (ÖNCE =
`git archive 1e3a9b60`; sonda = SONRA + yalnız günlük/kare alan satırlar). Kanıt kareleri: `p01`…`p10`
(ÖNCE solda, SONRA sağda). Tam koşu dökümü: `testler.txt`.

Yöntem notu: Bölüm 2'nin PACE=1 yakalama sahnesi bu makinede ~12 dk sürüyor ve kare hızı düşük olduğu için Godot
oyun zamanını kare başına ~0,13 sn'ye kısıyor (yavaş çekim): her kare yakalanıyor. Sonda her karede askerlerin
baş/gövde/omuz/dirsek noktalarını kameranın yerelinde, el-bilek uzaklığını (`Stage.grip` dönüşü) ve tüm kareyi
kaydetti (ÖNCE ve SONRA için aynı sonda).

## 1. Hüküm özeti

| # | Madde | Hüküm |
|---|-------|-------|
| 1a | B2 2.1/2.4: askerler kameranın içinden/üstünden geçmiyor (ilk bakışta) | **DOĞRULANDI** |
| 1b | Eğilme 0,22 rad, `SEIZE_AHEAD`=1 m, `SEIZE_SIDE`=0,55 m | **DOĞRULANDI** (kodda ve ölçümde) |
| 1c | Eller bileklere değiyor | **DOĞRULANDI** (4-10 cm; ÖNCE 0-9 cm) — bakış çevrilmezse |
| 1d | Götürme/karartma evresi eskisiyle aynı | **DOĞRULANDI** |
| 1e | Oyuncu bakışı çevirince | **KISMEN / YENİ KUSUR** (konumlar bakışa göre hesaplanmıyor; bkz. Y1) |
| 1f | `_seize_audit` yalnız testte, yanlış alarm yok | **DOĞRULANDI** (0 yanlış alarm / 16 koşu); ama yalnız tek durumu görüyor (Y4) |
| 1g | Askerler birbirinin / ateşin / kütüğün içinden geçmiyor | **KISMEN** (birbirinin içinden geçmiyor; ateş-kütük için ölçüm yetersiz, Y2) |
| 2 | B12 kitchen: yalnız bot seçimi değişti | **DOĞRULANDI** |
| 3a | B0 yazı patlamanın ve "TOLGA" kartının üstünde kalmıyor | **DOĞRULANDI** (bot hızı ve PACE=1) |
| 3b | Yazı okunacak kadar kalıyor (≥ ~2 sn) | **KISMEN** (koşan oyuncuda tam hâl ~1,7 sn; bot/ışınlanmada 0,3 sn; Y5) |
| 3c | Yürüyen oyuncuda değişiklik yok, `_first_step_hint` ile çakışma yok | **DOĞRULANDI** (kod + ölçüm); durağan oyuncuyla ekranlı koşu **BAKILMADI** |
| 4 | 17 → 15 aynı süreç montajı | **YENİDEN ÜRETİLEMEDİ** (`MONTAGE done`, 82 sn) |

Genel hüküm: **KÜÇÜK DÜZELTMELERLE KABUL** (bölüm 5).

## 2. Madde madde bulgular

### Madde 1 — Bölüm 2, sonuç 2.1 ve 2.4

**Koşular:** `PACE=1` ekranlı, `""` (2.1) ve `chainfail` (2.4), ÖNCE ve SONRA ikişer sonda; ayrıca 2.1'de kamera
yaw'ı 90° ve 180° çevrilmiş SONRA + ÖNCE sondaları (yaw, askerler yaklaşırken 3. karede `player.rotation.y`
değiştirilerek; gerçek fare girdisiyle **BAKILMADI**, ama bölüm de yaw'ı bu alanla çevirir).

**1a — kameranın içi (ölçüm).** Tutma anından itibaren askerin en yakın noktasının kameraya uzaklığı:

| | asker 1 (kırmızı) | asker 2 (mavi) | baş, kameranın yerelinde (x, y, z) |
|---|---|---|---|
| ÖNCE 2.1 (n=16-55) | 0,69 m | **0,50 m** | (−0,45; −0,48; −0,22) ve (0,46; 0,15; −0,10): 0,1-0,2 m önde, kamera düzlemine neredeyse bitişik |
| SONRA 2.1 (n=15-54) | 0,81-0,83 m | 0,70-0,73 m | (−0,36; −0,14; −0,73) ve (0,36; 0,17; −0,70): ~0,7 m önde |
| ÖNCE 2.4 | 0,69 | 0,50 | aynı örüntü |
| SONRA 2.4 | 0,81-0,83 | 0,71-0,73 | aynı örüntü |

Kareler: `p01` (n=13 yaklaşma), `p02` (n=16 tutma anı: ÖNCE'de sol kenarı bir börk, sağı mavi gövde kaplıyor; SONRA'da iki
yüz kadrajda), `p03` (n=19 tutma sürerken), `p04` (2.4, n=16). Yaklaşma boyunca (n=0-15) hiçbir karede asker
kamerayı kaplamıyor; en yakın kare n=15 (0,71 m). Yani "askerler kameranın içinden geçiyor" ÖNCE'de gerçek,
SONRA'da yok.

**1c — eller.** `Stage.grip` hata dönüşü (avucun bileğe kalan uzaklığı): SONRA'da 0,04-0,10 m (kırmızı 0,04-0,10;
mavi 0,04-0,08); ÖNCE'de 0,00-0,09 (mavi 0,00). Mavi askerde 0 → 4-8 cm: görünür bir kopma yok (`p03`: mavi
askerin yumruğu bilekte, kırmızının eli bilekte), ama "mesafe arttı" demek teknik olarak doğru; fark küçük.

**1d — evre sonrası.** Tutma bitince ekran kararıyor, "ORDUGÂHA YOLCULUK" kartı ve Hikmet "Bu sahneye bütçe yetmedi
evlât." geliyor; ÖNCE ve SONRA'da aynı kare sırası ve aynı replik anahtarları (`D2_S_14` → `D2_T_15` → `D2_S_16`).
Ölü süre 39,2 sn (ÖNCE) / 36,1 sn (SONRA): aynı yapı, üç süreç eşzamanlı koştuğu için gürültü. 2.4 için `D2_S_23`
sonrası 29,0 / 28,7 sn.

**1g — çarpışma.** Askerlerin birbirine uzaklığı yaklaşma boyunca 3,28 → 1,14 m (ÖNCE: 2,19 m): iç içe geçme yok.
Yol ile dünya geometrisi kesişimi (AABB, 0,3 m'den yüksek ve 8 m'den küçük cisimler): ~400 asker-kare örneğinde
0 isabet. **Sınır:** ateşin taş halkası ve kütükler bu süzgece takılmaz (alçak/küçük). Kareyle: mavi asker ateşin hemen
arkasında doğuyor ve ilk adımlarda taş halkasının yanından geçiyor (`PA2_1/p0003-p0005`); bu doğuş yeri
`_shore_guards` içinde (`chapter2.gd:1259-1266`), düzeltmeden bağımsız, ÖNCE'de aynı. Taş halkasıyla kesişimi sayısal
olarak **ölçemedim → BAKILMADI**.

**1f — `_seize_audit`.** Çağrı `if GameState.autotest:` altında (`chapter2.gd:1206`); oyunda yalnız bir bool
denetimi var, coroutine başlamıyor: oyunda maliyet yok. Yanlış alarm: SONRA ile sekiz varyant × 2 tur (16 koşu), hepsi
PASS, `WALKTHRU` 0 satır. Pozitif kontrol: kamera yaw'ı çevrilince denetim gerçekten alarm veriyor
(`PA2_y90`/`PA2_y180` günlüklerinde `WALKTHRU … by=player/camera`), yani çalışıyor. Zayıflık: bkz. Y4.

### Madde 2 — Bölüm 12 "kitchen"

- `git diff 1e3a9b60 -- scripts/chapter12.gd`: oyuncuyu etkileyen satır yok. Değişenler: `_key_asked` sayacı
  (`chapter12.gd:27`, `:388`), `cp` ifadesi (`:242`), test raporu (`:808-812`, `:825`). `cp`, `hud.choose(...,
  autotest_pick)` üçüncü parametresi (`hud.gd:3112`); yalnız otomatik testte kullanılır, oyuncu için yok. `cp` ifadesi
  `v != "kitchen"` koşulunu yitirdi: yalnız `v=="kitchen"` için farklı sonuç veriyor. Merak eşiği (`_merak < 1`),
  soru sırası, replik akışı değişmemiş.
- ÖNCE `kitchen`: `PASS … merak=0 tries=2`, günlükte `D12_F_KEY` **0** kez (kusur yeniden üretildi). SONRA:
  `PASS … outcome=12.5 merak=1 paradox=40 tries=2 key=2`, günlükte `D12_F_KEY` **2** kez (`SAYDIST` satırları 15 ve
  25; arada `D12_F_KEY_B_NO → D12_F_KITCHEN → D12_F_RETRY → D12_F_AGAIN`).
- Varyantlar (SONRA): `""`, `leblebi`, `twokings`, `repair`, `kitchen`, `retry`, `hikmet`, `nihat`, `urban`, `next`
  → 10/10 PASS (`next` → Bölüm 17 PASS). Sonuçlar: 12.1, 12.2, 12.3, 12.4, 12.5, 12.1, 12.6, 12.1, 12.1, →17.
- Küçük not: `kitchen` artık "merak kapısı → mutfak" yolunu kendisi sınamıyor (onu `retry`'ın ilk turu sınıyor; geliştirici
  de yazmış). PASS satırına `key=` eklendi; bunu ayrıştıran bir araç bulunamadı.

### Madde 3 — Bölüm 0 yer/tarih yazısı

- **Patlama / TOLGA kartı:** ÖNCE'de yazı patlama karesinde ve donma kartında görünür kalıyor (`p07` bot hızı, `p08`
  PACE=1). SONRA'da ikisinde de yok.
- **Okunurluk (ölçüm, headless PACE=1, gerçek süre):** yazı başlar 12,24 sn, tam yazılı 13,59, sönme başlar 13,87,
  gitti 14,09 → toplam 1,85 sn, tam hâl yalnızca ~0,3 sn (bot ışınlandığı için `delivered` yazıyla aynı anda; sönme
  `_hit`+1,6 sn). Bot hızında (zaman ölçeği > 1): toplam 1,03 sn. Ekranlı PACE=1 koşuda (bot daha geç vardı): yazının
  ilk harfinden sönmeye ~3 sn (`p09`: t0011 yazılıyor, t0016 tam, t0018 sönüyor).
- **İnsan oyuncu (hesap, koşu değil):** `START`→`delivered` çizgisine ~7,6 m; koşu 5,2 m/sn → 1,5 sn + 1,6 sn bekleme =
  3,1 sn'de sönme; tam yazılı kalma ~1,7 sn, toplam ~3,4 sn. Yürüme 3,2 m/sn → 2,4 + 1,6 = 4,0 sn: özgün sönme
  zamanıyla (4,0 sn) aynı → yürüyen oyuncuda fark yok. `_place_out` yalnız `_hit` içinde çağrılıyor (`chapter0.gd:301`).
- **`_first_step_hint`:** ipucu yazı sönene (`a ≤ 0,05`) kadar bekler (`chapter0.gd:230`) ve yalnız oyuncu başlangıçtan 2 m
  içindeyken çalışır; `_place_out` yalnız çizgiye varınca çağrıldığından çakışma yok. Durağan bir oyuncuyla ekranlı koşu
  **BAKILMADI** (bot hep yürüyor).
- `""`, `next`, `PACE=1 ""`: PASS (3/3). `PACE=1`'de `WARN_VOID_TELEPORT` ÖNCE'de de birebir aynı (bölüm 4 / Y3).

### Madde 4 — 17 → 15 montaj

`$G --headless --path . res://tools/trailer/gameplay.tscn -- set=shorts only=0,5` (kesit 0 = `vlad_kasko`/17
`edirne_policy`, kesit 5 = `hikmet_1977`/15 `wrong_stay`): `MONTAGE seg=0 … t=112.5`, `MONTAGE out seg=0 frame=5474`,
`MONTAGE seg=1 … t=100.3`, `MONTAGE out seg=1 frame=10559`, **`MONTAGE done`**, rc=0; duvar saati **1 dk 22 sn**
(kullanıcı işlemcisi 27 sn). Takılma yok. Hüküm: **YENİDEN ÜRETİLEMEDİ**; geliştiricinin sonucu (t=113,4 / 100,5)
doğrulandı.

## 3. Yeni kusurlar (ÖNCE'de var mıydı ayrıldı)

**Y1 — B2 yakalama: konumlar oyuncunun canlı bakışına göre değil, iniş anındaki `_shore_look`'a göre (ÖNCE'de de
var; SONRA'da kısmen daha kötü).** `_seize` (`chapter2.gd:1172-1184`) `fwd`'yi `_shore_look(at)` ile alıyor; oyuncu bir
replik ekrandayken bakışı çevirebilir (`player.gd` `_dialogue_look`, `look_lock` yoksa). Ölçüm (3. karede yaw çevrildi):

| | yaw | en yakın nokta | el-bilek hatası |
|---|---|---|---|
| ÖNCE | 90° | 0,50-0,69 m, baş x=0,1: kameranın içi (`p05` solda ekranı bir börk kaplıyor) | asker 1: 0,00-0,11 · asker 2: 0,32-0,33 |
| SONRA | 90° | 0,73-0,83 m; asker kameranın yanında (x≈0,7), biri düzlemin arkasında (z=+0,4) | asker 1: **0,43-0,44** · asker 2: **0,31** |
| ÖNCE | 180° | 0,49-0,69 m | asker 1: 0,42-0,56 · asker 2: 0,39-0,40 |
| SONRA | 180° | 0,70-0,83 m, askerler arkada (z≈+0,7) | asker 1: **0,81-0,84** · asker 2: **0,75-0,77** |

Yani kameranın içinden geçme bakış çevrilince de azalıyor (90°'de 0,50→0,73 m), ama bilekleri tutmuyorlar: eldivenler
havada (`p05` sol eldiven, `p06` iki eldiven); 180°'de hata ÖNCE'ye göre ~1,5-2× büyük, 90°'de asker 1 için de büyümüş (0,00-0,11 → 0,43). Bu durum yeni değil ama
düzeltmenin "yakalayan bilekte" iddiasını yalnız sabit bakışta doğru kılıyor. Düzeltme önerisi bölüm 5'te.

**Y2 — mavi asker ateşin taş halkasının yanında doğuyor/yürüyor** (ÖNCE'de aynı; `chapter2.gd:1259-1266`, kare
`PA2_1/p0003-p0005`). Küçük görsel; iç içe geçme ölçülmedi (bölüm 2, 1g).

**Y3 — Bölüm 0 donma sırasında oyuncu gerçekten boşluğa düşüyor** (ÖNCE'de aynı). Bkz. bölüm 4.

**Y4 — `_seize_audit` zayıflıkları** (`chapter2.gd:1222-1244`): (a) yalnız baş/kol/dirsek noktalarını ölçüyor, börk ve gövde
uçlarını değil; (b) `part=@Node3D@40881` gibi anlamsız ad basıyor (`part.name`), hangi kemik olduğu günlükten
anlaşılmıyor; (c) ilk ihlalde `return`, sürenin kalanını izlemiyor. Kozmetik.

**Y5 — B0 yazının tam hâlinin ekranda kalma süresi hızlı oyuncuda/botta kısa** (~1,7 sn / 0,3 sn). Bilinçli tasarım
olabilir; fragman ve hızlı oyuncu için okunabilirlik sınırda.

**Y6 — (önceden var) `WARN_PORTRAIT_STUDIO speaker=SPK_KADRI key=D12_K_01/D12_K_03`** (B12 `kitchen`, `retry`; ÖNCE'de de).
Yasak desende değil, mutfak ara sahnesinde Kadri'nin portresi stüdyoda yok.

## 4. `PACE=1 --chapter=0 → WARN_VOID_TELEPORT pos=(0.2, -415.5, 9.4)` kök nedeni

- ÖNCE'de de çıkıyor (aynı `pos`, `testler.txt` `H0B_pace`).
- **Oyuncu gerçekten düşüyor.** Sonda günlüğü (`froze` sırasında, 30 fizik karede bir): y=0,0 → −5,5 (t=300) → −101,8
  (t=510) → −415 (t=810), `vy` −88,7 m/sn'ye kadar, `frozen=true gravity_on=true floor=false world_mode=4`. Oyuncunun
  kendi kamerasına geçince (sonda, y=−8 m) duvarın alt yüzü görünüyor (`p10`). Oyuncuya bu görünmez: ekran
  `freeze_cam`'de.
- **Neden:** `chapter0.gd:494` `_pause_world(true)` → `world.process_mode = DISABLED`; Godot `CollisionObject3D`'in
  devre dışı bırakılmasıyla zemin ve sur çarpışmaları kapanıyor (oyuncu `world` altında değil). Donmuş oyuncunun
  `gravity_on`'u açık kalıyor, donma konuşması (~9 sn) bitene dek düşüyor. Normal testte (bot, konuşma kısa) hız
  `player.gd:358-370`'in "ışınlanma" eşiğini (1,5 m/kare) aşmadığı için uyarı çıkmıyor; PACE'te ~9 sn düşünce ışınlanma
  sanılıp `WARN_VOID_TELEPORT` basılıyor (`player.gd:400`).
- **Düzeltme önerisi (uygulanmadı; sonda kopyasında denendi: PACE=1 `AUTOTEST PASS`, `WARN_VOID_TELEPORT` yok, y=0,0
  sabit; sonraki bölüme geçiş `next` bu düzeltmeyle koşulmadı):**
```gdscript
# chapter0.gd, _freeze(): _pause_world(true) satırının hemen altı
	_pause_world(true)
	player.gravity_on = false          # world DISABLED: zemin çarpışmaları kapandı, donmuş oyuncu düşmesin
	player.velocity = Vector3.ZERO
# chapter0.gd, _rewind(): _pause_world(false) satırının hemen altı
	_pause_world(false)
	player.gravity_on = true
```

## 5. Kurallara uygunluk ve GENEL HÜKÜM

**Kurallar (`git diff 1e3a9b60 -- scripts/`):**
- Replik anahtarı/metni değişmedi (`i18n` dokunulmadı). Süre/sayaç/sonuç koşulu: B2 `hold`/`Handover.wait` değerleri
  aynı; yalnız `_grab_arms` varsayılan eğilmesi 0,4 → 0,22 (`chapter2.gd:1204`) ve bitiş noktaları
  (`:40-41`, `:1183`). B12: oyuncu mantığı aynı (`:242` yalnız `autotest_pick`, `:27/:388` yeni sayaç). B0: `_place_out`
  (`chapter0.gd:301`, `:419-426`): yazının ömrü bitiş akışına bağlı kısaldı; replik/sayaç yok. Yeni denetim:
  `chapter2.gd:1206-1207,1222-1244`, `chapter12.gd:808-812` (yeni FAIL koşulu, yalnız `kitchen` raporunda).
- `grep -rn "DBG\|sonda\|_cshot" scripts/`: `DBG`/`_cshot` 0; "sonda" eşleşmeleri Türkçe "sonda" (= sonunda) sözcüğü
  geçen yorumlar ve bir dizi tanımı (`slipway.gd`, `camp_day.gd`, `chapter19o.gd`, `chapter28o.gd`, `chapter10a.gd`,
  `chapter1.gd`, `chapter17o.gd`); kare/sonda kancası kalmamış (bu işin diff'inde hiçbiri yok).
- Susturulmuş denetim yok (diff'te `WALKTHRU`/`VISAUDIT` filtresi eklenmedi, hiçbiri kaldırılmadı).
- Depo temiz: `git status` yalnız bu klasörü gösteriyor (`*.import` dosyaları Godot'un önbelleğidir, kaydedilmedi).

**Test sayıları (SONRA, `--headless --max-fps 20`; ayrıntı `testler.txt`):**

| Bölüm | Koşu | Sonuç | Hata satırı |
|---|---|---|---|
| 0 | `""`, `next`, `PACE=1 ""` | 3/3 PASS | `PACE=1`: `WARN_VOID_TELEPORT pos=(0.2, -415.4871, 9.4)` (ÖNCE'de aynı, Y3) |
| 0 | ekranlı bot hızı ve ekranlı PACE=1 (ÖNCE ve SONRA) | 4/4 PASS | yok (ekranlıda uyarı çıkmadı) |
| 2 | 8 varyant × 2 tur = 16 | 16/16 PASS (2.1, 2.2, 2.3, 2.4, 2.5, 2.1, 2.3, →3) | 0 (`WALKTHRU` yok). Not: `swimshore` `stumbles` 2 ve 1 (rastgele) |
| 12 | 10 varyant | 10/10 PASS | yasak satır yok; `WARN_PORTRAIT_STUDIO` (Y6, ÖNCE'de de) |
| 17 | `""`, `edirne_policy` | 2/2 PASS | yok |
| 15 | `""`, `wrong_stay`, `forge` | 3/3 PASS | yok (`JOURNEY cards=67 … overlap=0`) |
| — | `parse_check` | `PARSECHECK PASS scripts=247` | yok; `check_tween_await` rc=0; `check_keys` rc=0 |

Toplam 36 SONRA koşusu PASS (headless 34 + ekranlı 2; ekranlı 4 koşunun diğer ikisi ÖNCE), yasak desen satırı yalnızca `PACE=1` B0'daki önceden var olan
`WARN_VOID_TELEPORT` (2 koşu; ÖNCE ve SONRA birebir aynı). `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`,
`VISAUDIT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_MISS`, `JOURNEY_OVERLAP`: standart koşularda yok.
(Yaw çevrilmiş sonda koşuları `WALKTHRU … by=player/camera` basıyor; bu bilinçli deney.)

**BAKILMADI:** gerçek fare/oyuncu girdisiyle bakış çevirme; durağan oyuncuyla B0 ekranlı koşu (`_first_step_hint`
çakışması); ateş taş halkası/kütükle kesişim (sayısal); Bölüm 2 `swimchain`/`swimshore` varyantlarında yakalama
karelerinin ayrıca ekranlı koşusu; düzeltilmiş B0 `froze` sonrası zincir (`next`).

### GENEL HÜKÜM: **KÜÇÜK DÜZELTMELERLE KABUL**

Üç düzeltme de iddia ettiği şeyi yapıyor ve oyuncu kurallarını bozmuyor; B2 askerleri kameradan çıkardı (ölçüm +
kare), B12 kitchen yalnız bot seçimiydi ve kilit soruya iki kez ulaşıyor, B0 yazısı patlamadan önce sönüyor.
Kabulü bağlayan düzeltmeler:

1. **(ZORUNLU) B2 yakalama bakışa duyarlı olmalı.** Seçeneklerden biri: `_seize` içinde bakışı kilitle
   (`player.look_lock` zaten var, `player.gd:729`) ve `_seize`'i bitirince bırak; ya da `fwd`'yi `_shore_look` yerine
   kameranın anlık yönünden al. Öneri:
```gdscript
# chapter2.gd _seize(): fwd hesabı (look_lock ile birlikte; _grab_arms bitince player.look_lock = false)
	player.look_lock = true
	var fwd := -player.camera.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
```
   Kabul ölçütü: yaw 0/90/180° sondasında `gripErr ≤ 0,1 m` ve `WALKTHRU` yok.
2. **(ZORUNLU) `_seize_audit` günlüğü okunur olsun:** `part.name` yerine `rg.head/arm_l/…` için sabit ad
   (`"head"`, `"arm_l"`, …) bas.
3. **(ÖNERİLEN) B0 yazı süresi:** `_place_out`'ı yazı tam yazıldıktan en az 2 sn sonra çalıştır
   (`_place_tw` başlangıç zamanını tut; gerekirse `_hit` içinde kalan süre kadar bekle) ya da kabul edilen en kısa süreyi
   (1,7 sn) CHAPTERS'a yaz.
4. **(ÖNERİLEN, önceden var) B0 donmada düşme:** bölüm 4'teki iki satır (`gravity_on` kapat/aç).
5. **(ÖNERİLEN) Y6:** Kadri portresini stüdyo listesine ekle ya da `WARN_PORTRAIT_STUDIO`'yu bilinçli istisna yap.
