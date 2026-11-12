## 1. Kök neden ve düzenek

Hata gerçek: `look_target` verilen kişinin bütün gövdesi hedefe dönüyor, iskelette bel yok. İş yapan kişi atamadan sonra işini sırtında bırakıyordu. Repoda 243 `look_target = player` ataması var (60 dosya).

Tek ortak düzenek (parse_check PASS):

- **`scripts/level/stage.gd`:**
  - `Stage.gaze_dir`: Person ve Soldier'ın look_target dönüşünü yönlendirir. Yürüyen (>0.6 m/s) gittiği yöne döner. `grip_hold` sırasında iş noktasına (`work_at`) döner. Alet işindeki biri konuşmuyorsa ve oyuncu 3 m'den uzaktaysa gövdesini çevirmez. Konuşurken ya da oyuncu yakındayken döner, 2,5 sn susarsa işine geri döner. Boşta duranlarda davranış aynı.
  - `Stage.work_begin`, `work_end`, `work_turn`: dönüşü işe bağlar.
  - `grip_hold` ve `grip_release` artık `work_focus` ve `work_at` tutuyor.
- **`person.gd`, `soldier.gd`:** `work_focus` ve `work_at` alanları; look bloğu `gaze_dir` üzerinden. `Person.reach_to` ve `Stage.reach` hedef omuz arkasındaysa önce hedefe dönüyor.
- **`rig.gd` `_player_glance`:** uyuyan, yatan, yüzen oyuncuya bakmaz.
- **`crowd.gd` `look_at_event`:** uyuyanı atlar.
- **`game_state.gd`:** LOOKAUDIT (`_look_audit`, yalnız ekleme).

Konuşma bakışı bozulmadı. Mantık: konuşan ya da 3 m içindeki muhatap eskisi gibi oyuncuya döner. Ölçüm: konuşma yönelimi denetimi (SAYFACE) 25 anahtardan 25 anahtara geçti (aşağıda 1 yeni anahtar var).

## 2. Bulgu tablosu

| Bölüm | Kim | Ne yaparken | Durum |
|---|---|---|---|
| 8y | kapı nöbetçisi | sürgü, taşıma, kanatlar | DÜZELDİ kareli (`cift/8y_k1..k4`) |
| 10b | Urban | potayı tutup dökerken (grip) | DÜZELDİ kareli (`cift/10b_02`) |
| 35o | Urban | yürürken, sahneye dönük | KISMEN kareli (`cift/c35o_01`: önce kameraya dönük yürüyor, sonra yürüdüğü yöne bakıyor) |
| 28o | Urban | yürürken | KISMEN kareli (`cift/c28o_01`): yönelim farkı görünüyor, an eşleşmesi zayıf. LOOKAUDIT önce 1, sonra raw 1 (28o'nun backturn'ü sonra sıfıra indi) |
| 4 | Niko, deniz kapısı | kapıyı kanatlara arkası dönük açıyordu | DÜZELDİ kodla, kanıtsız (ekranlı koşuda bu noktaya zamanında ulaşılamadı; başsız koşular RUNOK) |
| 8y | nöbetçi mızrağı | elde kalıp kapıdan geçiyordu | DÜZELDİ kareli (mızrak yere dikiliyor) |
| 17 | Radu / Vlad | yürürken | KANITSIZ (`cift/c17_*`: iki karenin anı eşleşmiyor) |
| 26 | Giustiniani (aşağıdaki not) | yürürken | KANITSIZ (`cift/c26_01`) |
| 20, 29, 31o | – | walk / grip | 20 ve 29 BEKLİYOR, 31o raw kalıyor; ekranlı yakalama olmadı, KANITSIZ |
| 35o | ip tutan adamlar | kalçadaki ip tutamağı (12 raw) | meşru görünüm, kareyle doğrulanmadı |
| 9, 10 | Kadri, deveci | ışınlanma kesmesinde sırtı dönük konuşma başlıyordu | 10: SAYFACE temiz. 9: AÇIK, aşağıdaki not |
| diğer ~240 atama | – | kod taraması: `/tmp/scan3_out.txt` (78 dosya+değişken çifti ek hareket içeriyor) | çoğu konuşma, doğru. Yürüme, uzanma, grip ve alet işi olanlar ortak düzenekle kapandı; `leave()` zaten bırakıyor |

Chapter 20, 22o, 26o, 29, 38o ve diğer yasak dosyalara dokunmadım. Orada bulunan hataları ortak düzenek (Person ve Soldier tarafında) dolaylı olarak değiştirdi; kodda bir şey önermiyorum.

Not (26): chapter26'daki `stir` hit'i baseline'da yalnız raw'dı, yasak dosyada (`wall_fight`/Garrison) olabilir; kaynak doğrulanmadı.

## 3. LOOKAUDIT sayıları

Önce: `once3` (126 koşu, düzeltmesiz kod, aynı denetimle). Sonra: `sonra5` (son kodla 126 koşu).

| | backturn | raw |
|---|---|---|
| Önce | 9 | 44 |
| Sonra | 0 | 30 |

Önce backturn bölümleri: 10b 1, 17 4, 20 3, 28o 1. Önce raw: 0:1, 10b:2, 17:13, 20:7, 26:1, 28o:1, 29:2, 35o:12, 4:2, 8y:3. Sonra raw: 0:1, 17:13, 20:1, 26:1, 28o:1, 31o:1, 35o:12.

Başsız otomatik test çoğu sahneyi ışınlayıp hızlandırdığı için denetimin yakalama gücü sınırlı. Bu yüzden asıl kanıt kareler ve kod taraması.

## 4. Test sayıları

Başsız `quick118.txt`, 126 koşu, son kodla (`sonra5`): 126/126 RUNOK, RUNFAIL 0.

- VISAUDIT 0 → 0, WALKTHRU 0 → 0, ARMAUDIT 0 → 0, HELDAUDIT 0 → 0, SCRIPT ERROR 0 → 0.
- SAYDIST: 124 → 122.
- SAYFACE: 25 → 25. Yeni bir anahtar çıktı: `SAYFACE key=D9_KADRI_OFFER_1 scene=chapter9.tscn speaker=SPK_KADRI` (d=2.4, dot=-0.97). Kayıp anahtar: `D30O_S_WOUNDED`.
- WARN_ 1 → 1 (`WARN_PORTRAIT_STUDIO speaker=SPK_SOLDIER key=D28O_S_BALL`, önceden de vardı). JOURNEY satırı 1 → 1.

D9_KADRI_OFFER_1 (AÇIK): `chapter9.gd` 1003-1008'de ışınlanma kesmesinden sonra `face_toward` ekledim, ama SAYFACE aynen basıyor. Başsız bir hata ayıklama koşusunda aynı noktadaki `print` hiç görünmedi, yani bu SAYFACE başka bir yoldan geliyor ve nedenini bulamadım. Bu satırı "temiz" saymıyorum.

## 5. Bakamadıklarım

- Performans (RINFO önce/sonra): ölçmedim. 8y'de yeni mesh yok (mızrak yeniden bağlanıyor); sayı vermiyorum.
- Chapter 4 kapı sahnesi ekranlı kare (`kare4.sh` hâlâ çalışıyor ama zaman aşımına uğradı).
- 8y'de konuşma bakışı karesi (`--shotevery=1`) alınmadı.
- c26, c17, c20, c29, c31o ekranlı kanıt zayıf ya da yok.

Dosyalar: `scratchpad/nihat/bakis/` altında `rapor.md`, `liste.md`, `vitrin.jpg`, `cift/`.