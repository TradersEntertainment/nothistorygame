# Bağımsız denetim: bakış yönü / iş yaparken oyuncuya dönme

Denetçi, dal `wip/denetim-bakis`. Oyun kodu DEĞİŞTİRİLMEDİ (`git status`: yalnız `--import` çıktıları ve bu klasör; ikisini de kaydetmedim).
Yöntem: ÖNCE = aynı HEAD, yalnız bakış dosyaları (`stage.gd, person.gd, soldier.gd, rig.gd, crowd.gd, chapter8y/4/9/10.gd`) `e551de84` hâlinde
(depo dışında `scratchpad/once`; `game_state.gd` LOOKAUDIT'li kaldı, böylece aynı denetimle sayılır). SONRA = HEAD. Her iki taraf Godot 4.4.1.
Kendi koşularım; geliştirici paftasına bakmadım.

## GENEL HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL

Sahibin şikâyeti (kapıyı oyuncuya bakarak açmak) 8y ve Bölüm 4'te kareyle DÜZELMİŞ. Konuşma bakışında ölçebildiğim bir gerileme yok. Ama
"tüm oyunda" iddiası kanıtlanamadı: yürüyenler büyük ölçüde düzelmedi, iki yeni SAYFACE satırı çıktı (testte, nedeni aşağıda) ve
geliştiricinin "açık" bıraktığı Kadri satırının kök nedeni geliştiricinin denediği yerde değil.

### ZORUNLU düzeltmeler
1. `stage.gd:gaze_dir` yürüyüş eşiği `0.6` m/s, ama yürüme animasyonu `rig.gd:309` `speed > 0.35`'te başlıyor. 0,35-0,6 m/s arası yürüyen, `look_target`'ı olan kişi
   gövdesi oyuncuya dönük, ayakları yürüyor ("ay yürüyüşü"). Ölçüm: Bölüm 20 Giustiniani, hız 0,46-0,55 m/s, hareket yönüne göre açı -104°, -170°, 93°, -106° (`WALKPROBE`).
   Beklenen: gaze_dir'de eşik 0,35 (çıkışta 0,25, titremesin diye histerezis), `game_state.gd:_look_audit` walk eşiği aynı. ÖNCE'de de vardı (aynı eşik `person.gd:841`), yani
   gerileme değil ama "yürürken gittiği yöne bakma" maddesini tam kapatmıyor.
2. `D9_KADRI_OFFER_1` ve (varyantta) `D9_URBAN_OFFER_1_PLAIN` SAYFACE kök nedeni ve düzeltme önerisi aşağıda (ORTAK DOSYA ÖNERİSİ A). Geliştiricinin `chapter9.gd:1005` `face_toward` satırı
   yalnız `_run_shots()` içinde; otomatik testte hiç çalışmıyor, bu yüzden "bakmıyor". Bu satırı geri almak gerekmiyor ama işe yaramıyor, yanıltıcı; `chapter10.gd:837` aynı.

### KÜÇÜK (kabulü engellemez)
3. 8y kapı ve Bölüm 4'te cutscene süresi uzadı (kural: süre değişmeyecek): `chapter4.gd:_niko_opens_gate` açılıştan önce 0,7 sn bekliyor (+0,7 sn), `chapter8y.gd:_open_gate` kanat açma 1,6 sn iken artık
   `_pull_leaves` 1,0 sn + yol verme 1,2 sn (+0,6 sn) ve yürüyüşler. Replik, sayaç, sonuç, kalabalık, bot yolu: değişmedi (`git diff e551de84` tarandı; replik/anahtar/`hud.say` satırı eklenmemiş). Sahibe "kapı sahnesi ~1 sn uzadı" notu yeter.
4. 8y mızrak geri alma anlık: `chapter8y.gd` `spear.reparent(guard._elbow_r…)` nöbetçi mızrağın 0,5-0,6 m yakınında iken tek karede ele geçiyor (sondada: mızrak (-2,0, 0,37, 9,7) → el (-2,46, 0,74, 9,21)). Küçük "pop". Mızrağa uzanma/eğilme yok.
5. `_look_audit` kör noktaları (aşağıda 5. madde).
6. `stage.gd:gaze_dir` içinde `gaze_seen` farkı `> 0.6` rad: 20 fps'te (headless) 172°'den büyük tek dönüş adımı 0,63 rad olur ve `gaze_home` (işine dönüş yönü) silinir; 60 fps'te tetiklenmez. Çoğu oyuncuda sorun değil; zayıf makinede alet işindeki kişi konuşma sonrası işine dönmez. Beklenen: eşik `0.6` yerine delta'ya göre ölçeklenmiş (`> 0.6 * maxf(delta*60.0, 1.0)`) ya da meta'yı karede değil başka bir sürücüyle tut.

## Maddeler

| # | Madde | Hüküm | Kanıt |
|---|---|---|---|
| 1a | 8y kapı (sürgü, taşıma, kanat çekme, yol verme) | DOĞRULANDI | `pafta1_8y_…jpg` (ÖNCE üst, SONRA alt, aynı saat sırası: `once_8y/t0124…t0156`, `sonra_8y/t0124…t0156`). ÖNCE: nöbetçi sürgüyü omzunda yüzü oyuncuya dönük taşıyor, mızrak elde, sürgüye giriyor. SONRA: sırtı/yanı bize, işine dönük, mızrak yok (yere dikili). Not: kamera genelde duvara bakıyor, kanat çekme anı kadrajda sınırlı |
| 1b | Bölüm 4 deniz kapısı (Niko) | DOĞRULANDI | `pafta2_4_…jpg` (`--chapter=4 --autotest=chain`: kapı sahnesi 4b yolunda, varsayılan yolda yok). ÖNCE: Niko oyuncuya dönük dururken kanatlar arkasında kendiliğinden açılıyor (şikâyetin aynısı). SONRA: Niko kanatlara dönüyor, açıklığa bir adım giriyor, sırtı kamerada, sonra oyuncuya dönüyor |
| 1c | 10b Urban döküm | KANITSIZ | `pafta3`, `pafta4`: ÖNCE ve SONRA karelerinde fark görmedim (ikisinde de Urban dökerken potaya dönük, sırtı bize, konuşan satırlarda da). ÖNCE'de benim koşumda `LOOKAUDIT` 10b grip/work satırı yok (geliştiricinin ÖNCE sayısı 10b: 1 backturn, 2 raw benim 61'lik varsayılan koşumda yok). "Düzeldi" iddiasını ne doğrulayabildim ne çürütebildim. Yan not: dökerken konuşan Urban oyuncuya dönmüyor (`gaze_dir` kural 2 grip'i konuşmanın önüne koyuyor): kasıtlı, ama "Güzel. Tam dolu." sırtı dönük söyleniyor |
| 2a | 14 bölümde konuşma bakışı gerilemesi | DOĞRULANDI (sınırlı kapsam) | `talkprobe_once.txt` / `talkprobe_sonra.txt`: Person/Soldier her replik bitişinde konuşanın oyuncuya açısı (probe yalnız `scratchpad` kopyasında, depoda yok). 47 bölümde 153 (ÖNCE) / 148 (SONRA) konuşma; 8 m içi: 139 / 135; açı>90°: 2 / 2 (aynı iki satır, iş yapan değil); alet işindeki konuşan 13 / 13, hepsi ≤3,5 m'de açı 0-14° (89° yalnız Bölüm 24 `carry` keşiş, ÖNCE'de de 89°). Bölümler 1, 3, 4, 6, 8, 9, 10, 10b, 12, 17, 20, 24, 26 var; 35o'da konuşan örnek çıkmadı (BAKILMADI). Replikler autotestte ~0,2-0,4 sn: 3 m'den uzak alet işindeki konuşanın dönüşü (>3,5 m) bu koşularda ölçülemedi (örnek yok) → o kısım KANITSIZ |
| 2b | 3 m dışı alet işi, 2,5 sn sonra işine dönüş, titreme | KANITSIZ | Koddan: dönüşte ani sıçrama yok (`lerp_angle` delta*4); salınım riski yürüme eşiğinde (madde 1) ve 6. küçük madde. Kareyle ölçülmedi |
| 2c | SAYFACE sayısı (ÖNCE→SONRA) | KISMEN | ÖNCE 23 anahtar, SONRA 25 (bütün bölümler, varsayılan). Fark 2 anahtar, ikisi de SONRA'da fazla. `D39O_SA_02` (39o) rastgele: ÖNCE ağacında 4 koşunun 2'sinde çıktı (2'sinde çıkmadı), SONRA ağacında da dalgalı: gerileme DEĞİL. `D9_KADRI_OFFER_1` SONRA 4/4, ÖNCE 0/2 (kök neden aşağıda). Geliştirici "25→25, kayıp `D30O_S_WOUNDED`" demişti; benim koşumda kayıp yok, artış 23→25. Varyantlar (8y/4/9/10b, 30 koşu): ayrıca `D9_URBAN_OFFER_1_PLAIN` yeni (aynı neden); `D4A_HA_END`, `D4A_HU_END` ÖNCE'de de var |
| 3 | Yürüyenler | KISMEN | `LOOKAUDIT` walk (>100° sırtı dönük): ÖNCE 9 (2 backturn + 7 raw: 0, 17 Radu, 20, 26, 28o, 31o×2), SONRA 7 raw 0 backturn: 0 Giustiniani 143°, 17 Radu 146° (konuşurken), 20 Giustiniani 155°, 28o Urban 148°, 31o dervish 101°; ÖNCE'deki 20 `carry` ve 26 satırları kalkmış, ama 20'de Giustiniani 155° yeni raw. 28o Urban 139° backturn → 148° raw: yalnız gösterge değişti. Kök neden: 0,35-0,6 m/s açığı (ZORUNLU 1). Kareyle yürüyen doğrulaması YOK (17, 20, 26, 28o, 31o, 35o için ekranlı koşu yapmadım: BAKILMADI). 8y nöbetçi `walk_back` geri geri çekme kasıtlı |
| 4 | Kalabalık (uyuyan/yatan/ölü/ayakta boş) | KISMEN (yalnız kod) | `rig.gd:_player_glance` uyuyan/yatan/dalmış/yüzeni atlıyor; `dead`, `crouch` vb. `STATIC_POSES` dalında başı sabit tutup `return true` ediyor (rig.gd:549-568), dolayısıyla bakmıyor. Boş ayakta duran: ara sıra 3-6 sn bakıyor (kod değişmedi), canlılık korunmuş. EKSİK: `crowd.gd:look_at_event` `w.get("activity")` okuyor; Soldier'da `activity` yok (rig'de), uyuyan Soldier atlanmıyor. Kareyle bakılmadı |
| 5 | LOOKAUDIT | KISMEN | Yalnız `GameState.autotest` iken çalışıyor (`game_state.gd:_process`), oyunda maliyet yok. Yanlış alarm: `walk` ölçümü anlık hız gürültüsüne duyarlı (`ang` -170°/93° değişiyor), `raw` bu yüzden çok. Kör noktalar: `ride/row/swim/fly/hover/lie/sleep/doze/crouch` atlanıyor; walk eşiği 0,6 (animasyon 0,35); `lt == null` yürüyenler hiç ölçülmüyor; `no_audit` meta'lı kişi atlanıyor (başkalarının eklediği `chapter22o.gd:1189`, `gun_range.gd:147`; geliştirici eklememiş); "work" türü yalnız `yaw0` kaydı varsa; `grip` ölçümü yalnız SONRA'da var (`work_at` alanı ÖNCE'de yok), ÖNCE-SONRA sayıları bu yüzden eşit koşulda değil |
| 6 | 8y nöbetçi mızrağı | DOĞRULANDI | Sonda (`scratchpad/dbg`, depo dışı) 8y: mızrak gövdesi 2,7 m (y -0,4…2,3 yerelde); dikilince pivot y=0,37 (zemin -0,03): alt uç tam zeminde, havada değil, gömülü değil. Eğim -4°, gövdeye girmiyor (0,6 m yanında). Sonra eline `reparent` (küçük pop, KÜÇÜK 4). Karede: mızrak ÖNCE'de elde sürgüden geçiyordu (`once_8y/t0136`, `t0150`), SONRA'da görünmüyor/elde değil |
| 7 | Oyun geneli tarama | KISMEN | `grep -rn "look_target = player" scripts/ \| wc -l` = 245 (HEAD; geliştirici 243). 20 an hedefine ulaşamadım: 3 kareli (8y, 4, 10b), 13 ölçümlü (`talkprobe_*.txt` iş+bakış satırları, tablo aşağıda), kalanı kod taraması. Eksik: kare çiftleri 17, 20, 26, 28o, 31o, 35o için |
| 8 | Testler | DOĞRULANDI | `parse_check` PASS (248). 61 varsayılan koşu (`run_tests.sh` listesindeki her bölüm bir kez): ÖNCE 61/61 RUNOK, SONRA 61/61 RUNOK. Varyantlar SONRA: 8y 6, 4 8, 9 11, 10b 5 = 30/30 RUNOK; ÖNCE (4, 9, 10b) 24/24 RUNOK. `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_*`: 0 (her iki yanda). Tek `WARN_PORTRAIT_STUDIO` (28o) iki tarafta da var. `LOOKAUDIT backturn`: ÖNCE 2, SONRA 0 (geliştirici: 9 → 0, benim ÖNCE koşumda 2) |

### Madde 7: iş + bakış ölçümleri (konuşma bitişinde oyuncuya açı)
Bölüm, kim, iş, mesafe, açı ÖNCE | SONRA: 15 `sit` 3,5 m 14|14; 17 Gürani `sit_ground` 4,0 m 12|11; 17 Vlad `whittle` 2,6 m 8|8; 24 keşiş `carry` 1,0 m 89|89; 24o `chop` 3,1 m 14|14; 32o Hasan `sit_ground` 1,9 m 0|0; 36b Leon `dead` 1,2 m 12|10; 36b Leon `sit_ground` 0|0; 6 `chop` 1,7 m 0|0; 7 `chop` 1,7 m 0|0; 9 Kadri `chop` 2,4 m 0|0. Hepsi aynı, gerileme ve kazanım yok: bu madde ölçümü yalnız "bozulmadı" kanıtlar, "düzeldi" kanıtlamaz.

## Kök neden: `D9_KADRI_OFFER_1` (geliştirici açık bıraktı)
`chapter9.gd:_talk` (satır ~357) otomatik testte oyuncuyu Kadri'nin önüne ışınlıyor (`if node and GameState.autotest: … player.global_position = _approach_point(…)`).
Kadri `chop` alet işinde ve `look_target = player` (`chapter9.gd:83`). Yeni `Stage.gaze_dir` alet işindeki, konuşmayan, oyuncusu 3 m'den uzak kişiyi çevirmiyor (tasarım), dolayısıyla Kadri ışınlanma anında sırtı oyuncuya dönük (d=2,4, dot=-0,97) ve `Hud._say_staging` bunu satır başında ölçüyor.
ÖNCE'de `look_target` her zaman gövdeyi çevirdiği için Kadri hep oyuncuya dönüktü. Oyunda etkileşim ışını 2,4 m (`player.gd:160`): oyuncu yürüyerek yaklaşırken 3 m eşiğinden geçip Kadri'yi çevirmiş olur, sorun oyunda görünmez; yalnız testin ışınlaması yüzünden. Geliştiricinin eklediği `face_toward` satırları yalnız `_run_shots()` içinde ve bu yola hiç girmiyor (kanıt: sonda print'i hiç basmadı; SAYFACE basarken `_run_shots` çalışmıyor).

### ORTAK DOSYA ÖNERİSİ A (uygulamadım) `scripts/ui/hud.gd:_turn_speaker`
Satır `if (busy is bool and busy) or (act is String and act != "") or (pose is String and pose != "stand"): return` testte ışınlanma sonrası konuşan alet işindekini çevirmiyor. Değişiklik:
```gdscript
	var lt = who.get("look_target")
	var worker: bool = act is String and act != ""
	if (busy is bool and busy) or (pose is String and pose != "stand"):
		return
	if worker and not (lt == p and _fast()):
		return      # alet işindeki yalnız testte (ışınlanma) oyuncuya döndürülür; oyunda gaze_dir yaklaşınca çeviriyor
```
(Not: aşağıdaki `if lt == p: if _fast() and dot < 0.7: who.call("face_toward", …)` dalı zaten bunu yapıyor; yalnız `act != ""` erken çıkışı onu engelliyor.)

### ORTAK DOSYA ÖNERİSİ B (`stage.gd:gaze_dir` + `game_state.gd:_look_audit`)
```gdscript
	var walk_v := 0.6 if not who.has_meta("walking_now") else 0.3   # histerezis: yürürken 0.3'e kadar sürsün
	if delta > 0.0 and not who.has_meta("walk_back"):
		var hv := Vector3(mv.x, 0.0, mv.z)
		var sp := hv.length() / delta
		if sp > 0.35 and sp < 40.0 ...  # rig.gd:309 yürüme animasyonu 0,35'te başlıyor
```
(`hv.length() < 2.0` karelik üst sınırı kalsın; eşik 0,6 → 0,35, çıkış 0,25.)

## Liste dışı yeni kusurlar
- Havada duran/gövdeye giren nesne: mızrak (yukarıda) temiz. 8y kanat çekmede ellerin kanatta kalması: kare yetersiz (BAKILMADI).
- Birden beliren kişi görmedim (8y, 4, 10b kareleri).
- Bölüm 4: açıklığın içi tam siyah (kapının arkası aydınlatılmamış); ÖNCE'de de aynı karede siyah. Sahne bütünlüğü sorunu, bu yamanın değil.
- ÖNCE'de var mıydı: yürüyen ay yürüyüşü EVET; mızrak sürgüden geçmesi EVET (düzelmiş); diğerleri yeni değil.

## Bakamadıklarım
- RINFO (çizim/üçgen) ÖNCE|SONRA: ölçmedim (geliştirici maddesi; yeni ağ eklenmediği kodda görünüyor: yalnız `Spear` yeniden bağlama).
- Ekranlı kare çiftleri: 17 Radu/Vlad, 20, 26 Giustiniani, 28o/35o Urban, 31o, 35o ip tutanlar: yapılmadı (zaman). 35o grip raw 12 satır (ip tutanlar) kareyle bakılmadı; kalça hizasında iş noktası, muhtemelen meşru.
- Bölüm 10b dökümde SONRA'nın ÖNCE'den farkı: kareyle görülemedi.
- Konuşan alet işçisi >3,5 m: örnek çıkmadı.
- 35o'da konuşma probu örneği yok.

## Dosyalar
`pafta1_8y_…`, `pafta2_4_…`, `pafta3_10b_…`, `pafta4_10b_…` (ÖNCE üstte, SONRA altta), `ham_test_satirlari.txt` (özetler, SAYFACE, LOOKAUDIT, 8y sonda), `talkprobe_once.txt`, `talkprobe_sonra.txt`, `ara_not.md`.
Probe/sonda kodu yalnız `scratchpad/dbg` ve `scratchpad/once` kopyalarında; depoda (`grep -rn "TALKPROBE\|WALKPROBE\|PROBE" scripts` → boş) kanca yok.
