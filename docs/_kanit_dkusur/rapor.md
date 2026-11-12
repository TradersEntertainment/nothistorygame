# Düzeltme turu: fragman kusurları (B0, B2, B8y) — geliştirici raporu · `wip/duzeltme-kusur`

Taban: `ef860ea2`. Godot 4.4.1, xvfb + yazılım çizimi. Değişen dosyalar yalnız `scripts/chapter0.gd`, `chapter2.gd`, `chapter8y.gd`.
Sonda/kanca yalnız `/tmp/probe` kopyasında; depoda yok. Replik, süre, sayaç, sonuç, kalabalık değişmedi.

| # | Madde | Durum |
|---|-------|-------|
| 1 | B2 yakalama bakışa duyarlı | **KISMEN** (bakış kilidi + kameradan yön: askerler kameradan ≥0,65 m, WALKTHRU yok; avuç-bilek hatası ≤0,10 m sağlanamadı) |
| 2 | `_seize_audit` günlüğü | **DÜZELDİ** (kod + koşu: `SEIZE_AUDIT ok closest=…`) |
| 3 | B0 donmada düşme | **KISMEN** (başsız PACE=1 ve `next` PASS, `WARN_VOID_TELEPORT` yok; ekranlı/düşme sondası yok) |
| 4 | B0 yazı süresi | **KISMEN** (hold ölçüldü; bot hızında 2,0 sn fiziken sığmıyor; kare YOK) |
| 5 | 8y uyarı keçi repliğini kesmesin | **DÜZELDİ** (ekranlı sonda) |

## 1. B2 yakalama (`chapter2.gd`)
- `look_lock = true`, askerler doğmadan önce (iki çağrı yerinde) ve `_seize` başında; bırakma: `_seize_report()` + `free_hold = INF` yanında (iki yol).
  `fwd` ve askerlerin diziliş yönü (`_cam_fwd`/`_cam_look`) kameranın anlık yatay yönünden.
- **Bakış kilidi süresi:** ekranlı PACE=1'de doğuştan bırakmaya, `D2_S_14`/`D2_T_15` replikleri + yürüyüş + 4 sn tutma + `D2_S_16`; 3 sn'yi AŞIYOR
  (tutma evresi tek başına ~4,0 sn; toplam ölçülmedi, tahmin ≥ 10 sn). Götürme evresi aynı kaldı. Sonda: `lock_all=true yawdrift=0.000`.
- Ölçüm (ekranlı `PACE=1 --chapter=2 --autotest`, oyuncu yönü doğuşta 0/90/180° çevrilerek; sonda `/tmp/probe`):

| bakış | avuç-bilek hatası (asker1/asker2) | kameraya en yakın nokta | WALKTHRU |
|---|---|---|---|
| 0° | 0,100 / 0,080 | 0,81 / 0,70 | yok |
| 90° | **0,256 / 0,249** | 0,94 / 0,88 | yok |
| 180° | 0,045 / **0,252** | 0,72 / 0,88 | yok |

  **Kabul ölçütü (hata ≤0,10 m) 90° ve 180°'de KARŞILANMADI.** Kök neden: kıyı zemini yön başına 0,1-0,45 m eğimli; asker zemine basar,
  omzu oyuncunun eline göre alçalır (headless GEO: `ground_y − player_y` = −0,45 → hata 0,25; −0,18/+0,14 → 0,10/0,08; +0,08 → 0,045).
  "Duruş noktasını zemin yüksekliğine göre seç" denemesi ekranlı koşuda hatayı düzeltmedi (0°'de 0,28'e çıkardı); geri alındı (`a3e681ab`).
  Çözüm önerisi (başka dosya gerektirebilir): elin y'sini asker omzuna göre uyarlamak (`player.free_hold`/`hand` konumu) ya da askerin gövde yüksekliği
  (`Stage.grip_hold` `lean`) zemin farkına göre ayarlanmalı.
- ÖNCE|SONRA kare çifti: ÖNCE karesi **YOK (KANITSIZ)**. SONRA, üç bakış: `b2_bakis_0_90_180_sonra.jpg` (üst `D2_T_15`, alt `D2_S_16`):
  askerlerin yüzü her üç bakışta kadrajda, kameranın içinden geçen yok.
- Başsız: 8 varyant × 2 tur PASS (aşağıda).

## 2. `_seize_audit`
Sabit adlar (`head`, `arm_l`, `arm_r`, `elbow_l`, `elbow_r`), ilk ihlalde çıkmaz; süre boyunca parça başına en kötü değer `_seize_report()` ile TEK kez
basılır (`WALKTHRU … part=head`); ihlal yoksa `SEIZE_AUDIT ok closest=%.2f`. Hepsi `GameState.autotest` altında. (İlk sürüm özeti bölüm erken bitince
basamıyordu; çağrı yerine taşındı.) Ayrıca soyut: ihlal yolunun POZİTİF denetimi (sahte ihlalle kasıtlı alarm) YAPILMADI.

## 3. B0 donma
`_freeze`: `_pause_world(true)` ardından `gravity_on=false; velocity=ZERO`; `_rewind`: `_pause_world(false)` ardından `gravity_on=true`.
`PACE=1 --chapter=0` başsız: PASS, `WARN_VOID_TELEPORT` yok. `--autotest=next` zinciri: 0 → 1 → 2 → 3 PASS. Ekranlı koşu ve donma sırasında y sondası: BAKILMADI.

## 4. B0 yazı süresi
`_place_age` (oyun zamanı) tutulur; `_place_out` yazı tam yazıldıktan (1,4 sn) en az 2,0 sn sonrasına kadar bekletir, bekleme ≤1,0 sn (söner: top
ateşinden 1,3 sn sonra, patlamadan ~0,26 sn önce). Ölçüm (`PLACE_OUT` satırı): bot başsız `age=1,99 hold=1,00`; PACE=1 `age=1,65 hold=1,00`; `next` `age=1,97 hold=1,00`.
Tam yazıldıktan görünür kalma = (age−1,4)+hold+0,3 sönme ≈ **1,5-1,9 sn (bot)**: botun çizgiye çok erken varması yüzünden 2,0 sn sığmıyor (patlama zamanı
değişmez). Koşan insan oyuncu (hesap, ölçüm değil): age≈1,5 → hold 1,0 → ≈2,2 sn. Yürüyen: hold 0 (eski davranış). Kare: yok (KANITSIZ).

## 5. 8y uyarı oku / keçi repliği
`_yorum_left` (oyun sn, `_events` içinde azalır; Tolga yorumu başlayınca 4,5) + `_warn_lines` içinde `while _yorum_left > 0 and hud.is_talking() and phase=="field": await`.
Ok yine anında saplanır. İlk sürüm gerçek saniyeye bağlıydı, yavaş çekimde işe yaramadı; oyun zamanına çevrildi.
Ekranlı PACE=1 geçici sonda (yorum +0,6 sn zorla uyarı): `yorum MANTLET t=539,72` → `force_warn talking=true t=544,82` → `warn_line t=585,26` (gerçek sn; yavaş çekim)
— uyarı yorum bitene dek bekledi (önceki sürümde 0,01 sn). Not: sonda zorla ek uyarı verdiği için sondalı `warn` koşusu `lowered=1` ile FAIL oldu; sondasız `warn` PASS (`lowered=2`).
Keçi yorumuyla (`D8Y_T_GOAT`) doğrudan sınanmadı (bot keçi yorumuna ulaşmıyor); MANTLET yorumuyla aynı kod yolu. Kare: yok.

## Testler (`--headless --max-fps 20`, yasak desen satırı: yok; `LOOKAUDIT raw` bilgi, önceden var)
- `parse_check`: PARSECHECK PASS scripts=248.
- B0: `""`, `PACE=1`, `next`: 3/3 PASS.
- B2: 8 varyant × 2 tur PASS (`""`,perfect,chain,chainfail,red,swimshore,swimchain,next) + son kodla 8 varyant yeniden PASS (`SEIZE_AUDIT ok closest=0,69-0,73`).
- 8y: 8 varyant PASS (`""`,warn,dep,opened,honest,hikmet,sinerji,next→9).
- 8: `""`,ride,caught,late,heist PASS. 9 `""` PASS. 3 `""` PASS. 17 `edirne_policy` PASS.

## Bakılamayanlar / eksikler
RINFO (çizim/üçgen) ölçülmedi; ÖNCE karesi yok; B0 ve 8y kareleri yok; gerçek fare ile bakış çevirme (kilit olduğu için çevrilemez) denenmedi; pafta sayısı 1.
`.import`/`strings.*.translation` içe aktarma artıkları KAYDEDİLMEDİ.
