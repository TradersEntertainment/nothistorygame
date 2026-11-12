# Bağımsız denetim (2. tur): bakış yönü düzeltmesi — `wip/duzeltme-bakis` ucu (`38be72d9`)

Denetçi, dal `wip/denetim2-bakis`. Oyun kodu DEĞİŞTİRİLMEDİ (kayıt yalnız bu klasör; koşular `~/w/sonra` ve `~/w/once` kopyalarında, depoda değil).
Yöntem: SONRA = dalın ucu (`git archive HEAD`). ÖNCE = özgün `e551de84` (`git archive`), yalnız `game_state.gd:_look_audit` (LOOKAUDIT) yamalı ki aynı
denetim ikisini de saysın. İki kopyaya da aynı geçici sonda eklendi (`WALKPROBE`/`HEADPROBE`/`WPSHOT`, yalnız scratch; `grep -rn PROBE scripts` depoda boş).
Godot 4.4.1; başsız koşular `--max-fps 20`; ekranlı koşular `xvfb-run` (PACE yalnız 4 ve 8y kapı için). Geliştirici paftasına bakmadım.

## GENEL HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL

Sahibin şikâyeti (kapıyı bize bakarak açmak) 4 ve 8y'de kareyle düzelmiş. Bölüm 20 `lose` yirmi koşuda `backturn` ÖNCE 12/20 → SONRA 0/20.
Süreler özgünle aynı. Replik/sayaç/sonuç/kalabalık/bot yolu değişmemiş, kanca yok, susturma eklenmemiş. 111 koşu PASS, yasak satır 0.
Ama "tüm oyunda yürürken gittiği yöne bakma" tam kapanmadı ve düzeltmenin **yeni bir yan etkisi** var (itilen kişi dönüyor, aşağıda). Bunlar kabulü engellemez.

### ZORUNLU düzeltmeler (küçük)
1. **İtilen kişi birden dönüyor (YENİ, SONRA'ya özgü).** `person.gd:_clear_way` (itme: `mover.global_position += step`) yürüyen işçinin önündeki kişiyi 0,1-0,3 m yana kaydırır; bu kayma
   `stage.gd:gaze_dir` kural 1'de "yürüyüş" (>0,35 m/sn) sayılıp gövde kayma yönüne döner, itme bitince oyuncuya geri döner. Bölüm 20 Giustiniani: yaw 108° → -61° → -4° → 51° → 146° (8 sn içinde, `GSERIES`,
   `PUSHDBG` aynı anlar; itenler iki işçi). ÖNCE'de gövde oyuncuya dönük kalıp kayıyordu (yan yan kayma, `backturn` 12/20), SONRA'da her itişte pivot atıyor.
   Beklenen: `_clear_way` itilene kısa süreli meta koysun (örn. `o.set_meta("gaze_pushed", Time.get_ticks_msec())`), `Stage.gaze_dir` kural 1 bu meta 0,4 sn'den tazeyken yürüyüşü yok saysın
   (gövde ne kaymaya ne oyuncuya birden dönmesin). Ölçüt: Bölüm 20 `lose` yirmi koşuda Giustiniani `LOOKAUDIT raw kind=walk` 0.
2. **Yürüme eşiği `person.gd:841`** (`look_target == null` kolu) hâlâ `0.6`; `rig.gd:309` animasyonu 0,35'te başlıyor. Geliştirici bunu kendi önerisi olarak yazdı ama uygulamadı (denetlenen dosya).
   Beklenen: `0.6` → `0.35` (çıkışta 0,25), `stage.gd` ile aynı histerezis. (Görünüm: `look_target`'sız, 0,35-0,6 m/sn yürüyen kişi kendi yönüne dönmüyor.) Bu koşularda tetikleyen örnek çıkmadı: KANITSIZ ama kod açığı açık.
3. **Yürüyüş başında gövde geriden dönüyor (kalan raw):** Bölüm 28o Urban (hız 0,50, gidiş +x, gövde -x yani oyuncuya dönük, `gaze_walk` yeni açılmış), Bölüm 17 Radu (konuşurken). Dönüş `lerp 4/sn`, ilk ~0,5 sn "ay yürüyüşü".
   Beklenen: yürüyüş başlarken (`gaze_walk` yeni açıldığında) gövde ilk 0,3 sn daha hızlı dönsün (örn. `stage.gd:gaze_dir` çağıranda dönüş oranı `delta*10`), böylece ay yürüyüşü görünmez. KÜÇÜK.
4. **8y mızrak geri alma "pop"** (`chapter8y.gd:_open_gate`, `spear.reparent(guard._elbow_r, false)` + `spear.position = …`): önceki denetimin KÜÇÜK 4'ü, DEĞİŞMEDİ. Beklenen: 0,3 sn'lik tween ile elin altına gelsin (eğilme yok, tek karede ışınlanma yok).
5. **`_look_audit` kör noktaları** (önceki denetim KÜÇÜK 5, DEĞİŞMEDİ): `look_target == null` yürüyenler ölçülmüyor; `no_audit` metalı kişiler (12b imparator/Sfrantzes `chapter12b.gd:308`, `rear_life.gd:103` vb.) LOOKAUDIT'ten de muaf. Beklenen: `no_audit` yalnız zemin/içinden-geçme denetimini susturup bakış denetiminde ayrı meta (`no_look_audit`) kullanılsın.
6. (not, zorunlu değil) `hud.gd:_turn_speaker` yeni `lt == p and _fast()` dalı yalnız testte işler (ışınlanma sonrası alet işindekini döndürür). Oyunda aynı işi `Stage.gaze_dir` yapıyor, davranışı yanlış değil; ama test ile oyun yolu ayrıldığı için SAYFACE bu kişiler için oyunun gerçek tepkisini ölçmüyor.

## 1) İlk denetçinin ZORUNLU listesi için hüküm

| # | Madde | Hüküm | Kendi kanıtım |
|---|---|---|---|
| 1 | Yürüyüş eşiği 0,35 (0,25 çıkış), `_look_audit` aynı | **KISMEN** | Kod doğru (`stage.gd:229-235`, `game_state.gd:620-626`). Bölüm 20 `lose` 20 koşu: Giustiniani `kind=walk` `backturn` ÖNCE 12/20 → SONRA 0/20; `raw` 20 → 18. Hız 0,35-0,6'da `lt` var kişiler (WALKPROBE, 20+ koşu): ÖNCE 71 örnek, 67'si >35° (43'ü >90°); SONRA 94 örnek, 56'sı >35° (28'i >90°). Fark büyük ölçüde itilen Giustiniani (ÖNCE 61/58, SONRA 69/49); Giustiniani dışındakiler ÖNCE 10 örnekte 9 >35°, SONRA 25 örnekte 7 >35°: iyileşme gerçek. Kalan: itilme (ZORUNLU 1) ve yürüyüş başı (ZORUNLU 3). Ekranlı kare: 17 Fatih (`pafta03`, zaman-bükülmesi ekranı: kullanışsız), 31o (ÖNCE sırtı dönük yürüyen derviş / SONRA secdeye eğilmiş kişiler: yürüyen değil), 20 Giustiniani profilden yakın (ikisinde de oyuncuya yakın): **kareyle doğrulama YETERSİZ**; 26 ekranlı koşusu 900 sn zaman aşımı (iki ağaçta da, KANITSIZ), 28o'da kare yakalayan örnek çıkmadı |
| 2 | `D9_KADRI_OFFER_1`, `D9_URBAN_OFFER_1_PLAIN` SAYFACE | **DOĞRULANDI** | SONRA 111 koşuda bölüm 9 (12 varyant), 10 (7), 10b (6) için `SAYFACE` satırı 0 (yalnız Bölüm 4'te `D4A_HA_END` ×2 ve `D4A_HU_END` ×2, ÖNCE'de de var: aynı 4 satır). Kök neden onarımı `hud.gd:_turn_speaker` test dalı (`lt == p and _fast()`); `chapter9.gd`/`chapter10.gd` `_run_shots` satırları kaldırılmış. Not: bu test-yolu istisnası (yukarıda 6) |
| 3 | Süreler | **DOĞRULANDI** | bkz. 1b/1c (aynı süre) |
| 4 | Mızrak "pop" | **DEĞİŞMEDİ** (ZORUNLU 4) | kod aynı |
| 5 | LOOKAUDIT kör noktalar | **DEĞİŞMEDİ** (ZORUNLU 5) | |
| 6 | `gaze_seen` eşiği delta'lı | **DOĞRULANDI (kod)** | `stage.gd:250` `0.6 * maxf(delta*60.0, 1.0)`; 20 fps'te davranış testleri PASS; özel ölçüm yok (KANITSIZ, yan etki görmedim) |

### 1a) 0,35-0,6 m/sn yürüyenin yüzü gidiş yönüne mi
Hüküm **KISMEN**, yukarıdaki tablo. Kararlı yürüyüşte (Fatih 17, `ang` 19-24° ÖNCE|SONRA) açı küçük; büyük açılar iki durumda: itilme ve yürüyüş başı.

### 1b) Bölüm 4 kapıyı açma süresi, özgün ile aynı mı: **DOĞRULANDI (ÖLÇTÜM)**
Geçici ölçüm yalnız scratch'te (`chapter4.gd` autotest'in 0,05 sn kısaltması yerine gerçek değerler, öncesi/sonrası `Time.get_ticks_msec`):
- Başsız, autotest zaman ölçeği 2,5: ÖNCE (`open_gate(1.2)`) real 0,45 sn × 2,5 = **1,13**; SONRA (`_niko_opens_gate`: 0,3 + 0,9) **1,13** (aynı).
- Başsız `PACE=1` (ölçek 1): ÖNCE **1,15 sn**, SONRA **1,25 sn** (nominal ikisi de 1,2; fark 20 fps kare gürültüsü içinde, +0,1).
- 8y `_open_gate` `PACE=1`: ÖNCE **7,64**, SONRA **7,76** sn (geliştiricinin ölçümü 7,60/7,62 ile uyumlu, +0,12 gürültü).
Ham: `ham_test_satirlari.txt` `GATETIME` satırları.

### 1c) Bölüm 20 `--autotest=lose` yirmi koşu: **YANLIŞ iddia düzeltmesi, sonuç lehte**
SONRA: 20/20 PASS, `LOOKAUDIT backturn` **0** kez. ÖNCE (`e551de84`): 20/20 PASS, `backturn` **12 kez** (12 ayrı koşuda, hepsi `Person(giustiniani) kind=walk`, 104°-141°, konum ≈ (8,4, 5,7), `look=Player`). Geliştiricinin "111'lik pakette bir kez 146°" satırı bende 20 koşuda çıkmadı (dalgalı; yine de ÖNCE'de 12/20 olduğu için gerileme değil).
`raw` (ilk aşım): SONRA 18 koşuda, ÖNCE 20 koşuda; hepsi Giustiniani walk. Kişi: Giustiniani; an: oyuncu ~20 m uzakta, `Stage.approach` değil (`stage_walk=false`), hız 0,3-1,3 m/sn tek örnek sıçramaları. **Neden: `person.gd:_clear_way` itmesi** (`PUSHDBG`: iki yürüyen işçi 0,1-0,3 m'lik adımlar itiyor). Bu aynı zamanda ZORUNLU 1'in kaynağı.

## 2) Kapı açan/kapatan kişiler (ÖNCE | SONRA)

| Bölüm | Kim | Hüküm | Kare |
|---|---|---|---|
| 4 (Niko, deniz kapısı) | Niko | **DOĞRULANDI** | `pafta01`: ÖNCE (üst): Niko yüzü bize dönük dururken kanatlar arkasında açılıyor (ellerini kullanmıyor). SONRA (alt): Niko kapıya dönüyor, eli halkada, sırtı bize, sonra oyuncuya dönüyor. Aynı koşu/aynı replik anı (`D4B_T_ISTANBUL_2` sonrası, `--chapter=4 --autotest=chain`, PACE) |
| 8y (nöbetçi) | nöbetçi | **DOĞRULANDI** (sınırlı) | `pafta02`: ÖNCE: nöbetçi mızrak elinde yüzü bize dönük yürüyor/duruyor; SONRA: mızrak yerde dikili, eller kanat tutamağında, gövde kanada dönük (üç kare). Kareler aynı sahne bölümünden, TAM aynı an DEĞİL (kamera oyuncuyla sabit değil): kare eşleşmesi zayıf. Sürgü taşıma ve yol verme ayrı karelerle doğrulanmadı (BAKILMADI) |
| 6b (kapıdan çıkış) | — | **YOK** | Kodda `door_open/door_metal/open_gate` yok; çıkış kart+kararma. Karelere (`c6byz`) baktım: kapıyı açan kişi yok |
| 12b (kule kapısı) | İmparator, Sfrantzes | **DOĞRULANDI** | `pafta04`: kapı boyalı kutu, açılmıyor; ikisi de kapıya yürüyüp içeri giriyor. ÖNCE ve SONRA aynı (dönüş: İmparator Sfrantzes'e, sonra kapıya) |
| 23 (Blakherna salonu) | — | **YOK** | Kodda kapı yok |

## 3) Yan etki (kurallara uygunluk)
`git diff e551de84 -- scripts/` 43 dosya: bu dalın 40 yedek kaydı başka işleri de taşıyor (şehir v2, gölge gövdesi, ses). Bakış işiyle ilgili dosyaları tek tek taradım
(`stage.gd`, `person.gd`, `soldier.gd`, `rig.gd`, `crowd.gd`, `hud.gd`, `game_state.gd`, `chapter4/8y/9/10.gd`) ve geliştiricinin kendi deltasını (`2f35c591..HEAD`, 7 dosya):
- Replik/süre/sayaç/sonuç/kalabalık/bot yolu: **değişmemiş.** Eklenen `print`/`hud.say`/`bark`/`tr(` yok (`git diff 2f35c591 HEAD -- scripts | grep` boş). Süre: 4 ve 8y özgünle aynı (yukarıda). `chapter4.gd:_niko_opens_gate` `autotest` altında 0,05 sn (özgün de 0,05).
- Kanca/susturma: yok. `grep -rn "PROBE\|WALKPROBE\|TALKPROBE" scripts` boş. Yeni `no_audit` eklenmemiş (`e551de84`'te `chapter22o.gd` 3 satır var, aynı). Tek test-yolu istisnası `hud.gd:2315-2322` (ZORUNLU 6 notu).
- `crowd.gd:look_at_event` yalnız `Person.activity`'ye bakıyor; `Soldier` uyuyorsa atlanmıyor (önceki denetimin tespiti, KÜÇÜK, değişmedi).
- Testler (SONRA, 111 koşu = bölüm 3 (6), 4 (9), 5 (5), 6 (10), 7 (10), 8 (10), 8y (7), 9 (12), 10 (7), 10b (6), 11 (10), 12 (9), 12b (5), 23 (5)): **111/111 `AUTOTEST PASS`.** `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_*`, `LOOKAUDIT backturn`: **0**. `LOOKAUDIT raw`: 3 (10 fail Kadri `chop` 132°, 10b Urban walk 129° ve 179°). `SAYFACE`: 4 satır, hepsi Bölüm 4 (ÖNCE'de de).
  - `VISAUDIT insolid` 2 satır (Bölüm 4 `chain` ve `nofez`: Niko SeaWalls içinde): **benim geçici zamanlama yamamın yan etkisi** (autotest'te 0,05 yerine gerçek 0,3+0,9 sn). Yamasız `HEAD` `chapter4.gd` ile dokuz varyant koşusu: 0 VISAUDIT. Dalın kendisi temiz. (Kusur değil; yalnız denetçi yamasının eseri.)
  - ÖNCE (4, 9, 10, 10b, 34 koşu): SAYFACE yalnız `D4A_*` (aynı), `LOOKAUDIT` raw/backturn az; D9 SAYFACE ÖNCE'de de yok (rastgele/dalgalı: önceki denetim ÖNCE 0/2, SONRA 4/4 demişti; geliştirici düzeltmesinden sonra SONRA 0).
- Komşu beş bölüm (3, 5, 6, 7, 8) + 11, 12, 12b, 23 başsız: PASS, yasak satır 0.
- 8y bütün varyantlar (7): PASS. ÖNCE `PACE` koşusunda 8y `LOOKAUDIT backturn` 2, SONRA 0.

## 4) Liste dışı yeni kusur
- **İtilen kişi dönüyor** (SONRA'ya özgü): ZORUNLU 1. ÖNCE'de karşılığı "kayma" (backturn 12/20).
- Kafa/gövde: `HEADPROBE` (kafa gövdeye göre >90°) **0 satır** (SONRA ve ÖNCE, 130+ koşu).
- Birden beliren/havada duran nesne: 4 ve 8y karelerinde yok; 8y mızrak yere dikili, havada değil (önceki denetim ölçümü; değişmedi).
- 31o dervişi: `LOOKAUDIT backturn` 177° (SONRA, bir koşuda; ÖNCE'de o koşuda yok, önceki denetimde ÖNCE'de de raw vardı). Hız 0,56, `gaze_walk=false`: itme türü ani hareket (ZORUNLU 1 ile aynı kök). Tekrarlanabilirlik: tek koşu.
- Ekranlı kare alamadıklarım: 26 (900 sn zaman aşımı), 28o, 35o; 17/20/31o yürüyen kare çifti yetersiz (`pafta03`). RINFO ölçülmedi (BAKILMADI; yeni ağ eklenmemiş).

## Dosyalar
`pafta01_b4_…`, `pafta02_8y_…`, `pafta03_yuruyen_…` (bilgi, yetersiz), `pafta04_12b_…` (hepsi ÖNCE üstte, SONRA altta), `ham_test_satirlari.txt`.
