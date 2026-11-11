# Fragman kusurları — yardımcı oturum raporu (wip/yardimci-kusur)

Taban: `wip/0.99.119` (HEAD 1e3a9b60, dal buradan açıldı). Godot 4.4.1 resmî Linux sürümü, xvfb + llvmpipe (yazılımla çizim).
Değişen dosyalar: `scripts/chapter0.gd`, `scripts/chapter2.gd`, `scripts/chapter12.gd`. Ortak dosyalara
(`scripts/level|world|npc|player/*`, `game_state.gd`, `hud.gd`, `montage.gd`) dokunulmadı. Kanca/sonda satırları
geçiciydi, söküldü (`grep -rn DBG scripts/` boş). Replik metni, sayaçlar, sonuçlar değişmedi.

| # | Kusur | Durum |
|---|-------|-------|
| 1 | B2 sonuç 2.1: askerler kameranın içinden geçiyor | **DÜZELDİ** (kare çifti + yeni denetim) |
| 2 | Aynı süreçte 17 → 15 yükleme takılması | **YENİDEN ÜRETİLEMEDİ** (4 koşul) |
| 3 | B12 "kitchen" kilit soruya ulaşmıyor | **DÜZELDİ** (yalnız bot; günlük kanıtı) |
| 4 | B0 yer/tarih yazısı bot hızında kalıyor | **DÜZELDİ** (kare çifti, 2,5× ve 1×) |

---

## 1. Bölüm 2, sonuç 2.1: askerler kameradan geçiyor — DÜZELDİ

**Hangi varyant:** varsayılan `--autotest` (`_autotest_report` beklenen `"": "2.1"`; bot ilk halatı bilerek kaçırır,
`chapter2.gd:1734`). Aynı yakalama kodu 2.4'te de (`chainfail`, `chapter2.gd:1352`) çalışır.

**Yeniden üretim:** `PACE=1 xvfb-run … --chapter=2 --autotest --dialogshots=… --shotevery=1 --snapevery=0.5`
(PACE: askerler gerçekten yürür; PACE'siz testte `Stage.fast()` onları yürütmeden yerine koyar).
Kareler `k1_b2_yakalama_once_sonra.jpg` (sondan sayılan aynı anlık kareler) ve `k1_b2_replik_ani.jpg` (aynı replik
anı: D2_T_15, D2_S_16). ÖNCE'de askerler kameranın üstüne yürür; varınca kırmızının börkü sol kenarda, mavinin
gövdesi sağda kameranın içindedir.

**Ölçüm (geçici sonda, söküldü):** tutma anında askerlerin başı kameranın yerelinde (−0,47; −0,48; −0,14) ve
(0,45; 0,15; −0,16): kameranın 15 cm önü, 45 cm yanı; bazı omuz/dirsekler kamera düzleminin arkasında (z > 0).

**Kök neden:** `chapter2.gd:1177` (özgün) askerleri oyuncunun hizasına yürütüyordu (`fwd * 0.3 + side * ±1.05`),
`_grab_arms` (`chapter2.gd:1198`, `lean := 0.4`) tutarken gövdeyi 0,4 rad oyuncuya eğiyordu: baş 1,5 m'lik kolla
~0,6 m kameraya kayıp onun yanına/içine giriyordu.

**Düzeltme:** `chapter2.gd:40-41` `SEIZE_AHEAD := 1.0`, `SEIZE_SIDE := 0.55` — askerler oyuncunun 1 m önünde,
0,55 m yanında durur (yolları oyuncuya varmadan biter, yüzleri kadrajda); `chapter2.gd:1204` eğilme 0,22 rad.
Eller bileklere yine uzanıyor (SONRA kareleri).

**WALKTHRU neden yakalamadı:** `Unclip.walk_audit` (`scripts/npc/unclip.gd:339,366`) (a) yalnız görünen
`StaticBody3D`'ye ışın atar — oyuncu `CharacterBody3D`, kamera hiç cisim değil; (b) testte (PACE yok) askerler
`Stage.fast()` ile ışınlanır, kareler arası hareket olmaz; (c) yerinde öne eğilme yürüme sayılmaz.
**Güçlendirme (bölüm içi):** `chapter2.gd:1222 _seize_audit` — testte tutma boyunca baş/omuz/dirsekleri kameranın
yerelinde ölçer; kameranın 25 cm önünden geride ve görüş ekseninden 0,8 m'den yakınsa
`WALKTHRU … by=player/camera` basar (run_tests bunu hata sayar). Kanıt: eski yerleşim + yeni denetim →
`WALKTHRU scene=chapter2.tscn who=SPK_SOLDIER … local=(-0.45, -0.48, -0.21)`; yeni yerleşim → temiz.

**Ortak dosya önerisi (uygulanmadı, `scripts/npc/unclip.gd` ana makinede):** walk_audit'e oyuncu kamerası için ek:
```gdscript
# walk_audit sonunda: sahne betiğinin yürüttüğü kişi oyuncunun kamerasına girdi mi (oyuncu StaticBody değil)
var cam := ch.get_viewport().get_camera_3d() if ch.get_viewport() else null
if cam and not ch.has_meta("cam_ok"):
	var lp := cam.to_local(ch.global_position + Vector3(0, 1.5, 0))
	if lp.z > -0.25 and Vector2(lp.x, lp.y).length() < 0.6:
		_wa_done[id] = true
		print("WALKTHRU scene=%s who=%s by=player/camera local=%s" % [...])
```
(+ `Stage.fast()` yerleştirmesinde de son konumu bir kez denetlemek).

## 2. Aynı süreçte 17 → 15 takılması — YENİDEN ÜRETİLEMEDİ

Denenen koşullar (hepsi düzeltmesiz 17/15 koduyla, `res://tools/trailer/gameplay.tscn`):

| Koşul | Sonuç |
|---|---|
| başsız, `set=shorts only=0,5` (17 `edirne_policy` → 15 `wrong_stay`) | 17 koşulu t=113,4; 15 koşulu t=100,5; `MONTAGE done`, rc=0 |
| başsız, `set=shorts only=0,5 clean nohud` | t=114,5 / t=100,3; done, rc=0 |
| ekranlı kayıt: `xvfb-run … --write-movie … --fixed-fps 30 --resolution 1920x1080 … only=0,5` | 3578 kare, t=119,6 / t=102,5; done, rc=0. **Duvar saatiyle ~32 dk, %100-190 işlemci** |
| ekranlı, gerçek zaman, bütün kısa set (17→6→17→17→17→**15**→10l→33o) | 8 kesitin hepsinde koşul sağlandı; done, rc=0 |

Kanıt: `k2_montaj_17_15_kayit.jpg` (kayıttan 1000/1700: 17 Vlad; 2700/3400: 15 1977 ofisi, aynı süreç).
Ayrıca test paketi 12 → 17 (`--autotest=next`) geçişi de PASS.

İncelenip elenen adaylar: Edirne ara bölümü (`EdirneInterlude`, Node, sahneyle birlikte silinir; döngüleri
`await`'li); `Fx` (sahne değişince `reset()`, 6 sn bekçi); `GameState.reset_run` bayrakları siler; 15'teki
bütün `while` döngüleri kare bekler; `LoadingScreen.current` fragmanda kullanılmıyor.

**Olası açıklama (kanıtsız):** bu makinede 1080p yazılım kaydı 17 → 15'i 32 dakikada, sürekli yüksek işlemciyle
bitirdi; 22 dakikalık "%100 takılma" kaydın olağan süresi olabilir (kara ekranda atlanan bekleme de kare kare
yazılır: 15'in koşuluna kadar 771 kare). İkinci aday: `montage.gd:314` zaman ölçeğini yalnız `> 0.05` ise
hızlandırır; önceki bölümden ~0 ölçek kalsaydı `_t` hiç artmaz, `wait` sınırı (3000 sn) dolmazdı — ama Fx
sahne değişiminde ölçeği sıfırladığı için bu yol tetiklenemedi. Öneri (montage.gd, dokunulmadı): `_clip` başında
`Engine.time_scale = 1.0`, bekleme döngüsüne gerçek zaman sınırı (`Time.get_ticks_msec()`) ve her 30 sn'de
`MONTAGE wait seg=… t=…` satırı — bir dahaki takılmada hangi koşulun beklendiği günlükte görünsün.

## 3. Bölüm 12 "kitchen" — DÜZELDİ (yalnız bot kopukluğu)

**Varyantın sınadığı:** 12.5 "Mutfağa gönderildi, kilit soru yeniden" (`docs/CHAPTERS.md:533`): kilit soruya
"Salı" (B) → `D12_F_KEY_B_NO` → mutfak → dönüş → kilit soru yeniden → B → 12.5. Kilit sorudaki seçimi
(`"kitchen": "b"`) bu yüzden vardı.

**Kopma:** bot "Frenk elçisi" (B) der, eşya göstermez ve top sorusunda da yanlış (C) seçerdi
(`chapter12.gd:237` özgün: `cp := 0 if v != "kitchen" … else 2`) → Merak 0 → merak kapısı
(`chapter12.gd:259` özgün / `:264` yeni, `if _merak < 1: _kitchen()`) iki turda da kilit sorudan önce mutfağa yolladı.
Günlük (ÖNCE): `merak=0 tries=2`, `D12_F_KEY` hiç yok.

**Oyuncu için:** kilitlenme yok. Merak kapısı tasarım (`D12_F_KITCHEN`: "Yeterince merak etmedim"); merakı ≥1 olan
oyuncu kilit soruya ulaşır, mutfaktan dönüşte eşya/top sorusu yeniden açıktır. Merak 0'daki kapıyı zaten `retry`
varyantının ilk turu sınıyor. Kural/sayaç değişmedi.

**Düzeltme:** `chapter12.gd:242` kitchen top sorusunu doğru (A) cevaplar (Merak 1). `chapter12.gd:388`
`_key_asked` sayacı; `chapter12.gd:808-812` kitchen'da kilit soru 2 kez sorulmadıysa FAIL; rapor satırına `key=`.
Kanıt: eski seçim + yeni denetim → `AUTOTEST FAIL … kitchen kilit soruya 0 kez ulaştı`; SONRA →
`PASS … outcome=12.5 merak=1 paradox=40 tries=2 key=2`, günlükte sırasıyla `D12_F_KEY, D12_F_KEY_B_NO,
D12_F_KITCHEN, … D12_F_RETRY, D12_F_AGAIN, …, D12_END_12_5_1`.

## 4. Bölüm 0 yer/tarih yazısı — DÜZELDİ

**Yeniden üretim:** ekranlı `--chapter=0 --autotest --snapevery=0.25` (gerçek zamanlı kare). Ek ölçüm (geçici):
fragman kanca kesitinde (`set=story only=0`) donma penceresi açıldığında yazı `a=1.00`.

**Normal hızda:** `Engine.time_scale = 1.0` ile (geçici yama, aynı bot) ÖNCE kodunda yazı yine patlamanın ve
"TOLGA" donma kartının üstünde (kare 24–31). Yani neden zaman ölçeği değil: sönme tween'i zamanla doğru akıyor
(2,5× ve 4×'te ölçüldü), ama yazının ömrü (1,4 + 2,6 + 0,5 = 4,5 oyun sn, `chapter0.gd:197-200` özgün) akıştan
habersiz. Bot (ışınlanır) ve koşan oyuncu (5,2 m/sn, ~10 m: ~2 sn) çizgiye bundan önce varır; yazı vuruşa ve donan
kareye taşar.

**Düzeltme:** `chapter0.gd:198` tween `_place_tw` üyesinde; `chapter0.gd:301` top ateşlenmeden hemen önce
`_place_out()` (`chapter0.gd:419`): süre dolmadıysa yazı 0,3 sn'de söner. Yürüyen oyuncuda değişiklik yok (yazı
kendi süresinde söner); `_first_step_hint` yine alfaya bakar.

Kanıt: `k4_b0_yer_yazisi_once_sonra.jpg` — aynı koşu düzeni, aynı kare sıraları: 2,5× kare 4 (yazı okunur, ikisinde
de), kare 10 patlama, kare 11 donma; 1× kare 26 donma. ÖNCE'de yazı patlama ve donmada; SONRA'da yok.

## Testler (son kodla, `--max-fps 20`, başsız; tam döküm `testler.txt`)

PARSECHECK PASS scripts=247 · check_tween_await rc=0.

| Bölüm | Koşu | Sonuç |
|---|---|---|
| 0 | `""`, `next` (→1→2), `PACE=1 ""` | 3/3 PASS |
| 2 | `""` `perfect` `chain` `chainfail` `red` `swimshore` `swimchain` `next` | 8/8 PASS (2.1, 2.2, 2.3, 2.4, 2.5, 2.1, 2.3, →3 PASS) |
| 12 | `""` `leblebi` `twokings` `repair` `kitchen` `retry` `hikmet` `nihat` `urban` `next` | 10/10 PASS (`next` → 17 PASS) |
| 17 | 8 + `edirne_policy` `edirne_none` `edirne_legend --bag=…` `osm` `route` | 13/13 PASS |
| 15 | run_tests listesindeki 33 varyant | 33/33 PASS |

Toplam 67/67 PASS. `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WALKTHRU`, `ARMAUDIT`,
`HELDAUDIT`, `JOURNEY_*`: yok. Tek uyarı: `PACE=1 --chapter=0` → `WARN_VOID_TELEPORT scene=chapter0.tscn
pos=(0.2, -415.4871, 9.4)`; **özgün kodla da birebir aynı** (önceden var, PACE run_tests'te yok; bu işin dışında, AÇIK).

## Açık kalanlar
- 2. madde yeniden üretilemedi; montage.gd için günlük önerisi yukarıda.
- Bölüm 0 PACE kipindeki `WARN_VOID_TELEPORT` (önceden var).
- `unclip.gd` walk_audit'e oyuncu kamerası denetimi önerisi (ortak dosya, uygulanmadı).
