# Hareket hissi — ÖNCE dökümü (taban 0ef7b470)

Ölçüm: gerçek `Player`, gerçek girdi (`Input.action_press`). Kaynak satırlar `~/is/once/*.log` (taban kopyası; yalnız
ölçüm kancası eklenmiş, davranış aynı). Sondalar:

- `tests/_fizik/hareket_sahne.tscn -- --is=olc` (yeni): ivme, duruş, dönüş, zıplama, coyote/tampon, düşüş kamerası,
  merdiven, kenar, tırmanma.
- `tests/_ist/cati_hareket.tscn -- --kip=kapali|acik --bolum=N` (var olan): menzil ve basamak sınırları
  (`docs/ISTANBUL_CATI.md` tablosunun kaynağı).
- `tests/_ist/cati_sehir.tscn -- --is=bot [--kip=acik]` (çatı rotaları R1–R3 botu), `tests/_ist/sur_oyun_yuru.tscn`
  (sur yürüyüşü), `sur_sozlesme.tscn`, `sur_oyun_denetim.tscn`, `tests/_ist/esya_fizik.tscn`.

## 1. Hız ve ivme (`scripts/player/player.gd`)

| ölçü | değer | kaynak |
|---|---|---|
| yürüme hızı | 3,20 m/sn | `WALK` |
| koşu hızı (Shift) | 5,20 m/sn | `RUN` |
| duruştan %90 hıza | 0,10 sn (yürüme ve koşu) | `move_toward(…, speed·delta·10)` — doğrusal, yerde ve havada aynı |
| koşudan duruşa | 0,17 sn | aynı |
| ani 90° dönüş: hız yönünün dönmesi | 0,08 sn | aynı |
| yaralıyken / sendelerken | `speed_mult`, `_wound_mult`, sendelemede ×0,3'e kadar | |

Bağlılar: süreli koşular (Bölüm 2 kızak `move_mode="script"`, 8y koşu botu `Player.WALK`), çatı rotaları (koşu hızı
→ atlama menzili), `speed_mult` kullanan 25 bölüm (yüzme, taşıma, sis), `stage.gd`/`chapter4/12` yürütme
(`script_velocity = …WALK`).

## 2. Zıplama ve menzil

| ölçü | KAPALI (`can_climb` yok) | AÇIK (`Traversal`) |
|---|---|---|
| `JUMP` dikey hız | 3,6 m/sn | 3,6 |
| yerinde zıplama tepesi | 0,68 m (sonda 0,692) | 0,68 |
| havada kalış | 0,77 sn | |
| yürüyerek çıkılan basamak | 0,48 m | 0,48 |
| koşup zıplayarak çıkılan kenar | 0,75 m | 2,55 m (tutunup çıkar; `ISTANBUL_CATI.md`) |
| koşarak atlama aralığı | **4,2 m** | 5,9 m (`ISTANBUL_CATI.md`) |
| yürüyerek atlama aralığı | 2,6 m | |
| aşağı atlama dh 1,0 / 2,4 / 3,4 m | 5,2 / 6,1 / 6,7 m | |
| coyote (kenardan sonra zıplama) | yok (0,07 sn sonra basılan zıplama yutuluyor, vy −0,98) | |
| zıplama tamponu | yok (inişten 0,08 sn önce basılan yutuluyor) | |

Kural: `ISTANBUL_CATI.md` çatı rotaları "atlanır aralık ≤ 2,0 m, kenar ≤ 0,40 m" paylarıyla kuruldu; menzil 4,2 / 5,9 m
**değişmeyecek**.

## 3. Düşüş, iniş, sendeleme

| ölçü | KAPALI | AÇIK |
|---|---|---|
| 1,0 / 2,5 / 3,5 / 6,0 m düşüş süresi | 0,47 / 0,72 / 0,85 / 1,12 sn | aynı |
| inişte kamera | **hiç oynamaz** (en alçak göz 1,620 = `EYE`) | 4 m'ye kadar oynamaz; 6 m'de sendeleme: göz −0,45 m (0,12 sn iner, 0,5 sn döner) → en alçak 1,17 |
| sendeleme eşiği | — | `Traversal.STAGGER_FALL` = 4,0 m: `stagger(0,7)`, sarsıntı `0,25+fall·0,06` (≤ 0,9), fes düşer, `D_CLIMB_FALL_1..3` |
| hasar | yok (düşme hasarı yok; `hurt` yalnız dövüş/ok/gülle) | yok |
| tente (`soft_landing`) | — | > 1,2 m'de yaylanır (`cartoon_boing`), > 4 m'de `D_CLIMB_LEAP` |
| iniş sesi | yok | `land_thud` (> 1,2 m −16 dB; > 4 m −6 dB) |
| toz | yok | yok |
| havada kollar | sağ el hızla biraz kalkar (`_animate_hands`) | aynı |
| serbest düşüşte | hiçbir şey (kol, rüzgâr, ses yok) | aynı |

## 4. Tırmanma ve kenar (`scripts/player/traversal.gd`)

| sabit | değer |
|---|---|
| `CLIMB_SPEED` / `CLIMB_FAST` | 1,2 / 1,9 m/sn |
| `DRAIN_MOVE` / `DRAIN_FAST` / `DRAIN_IDLE` | 0,12 / 0,24 / 0,02 /sn |
| `JUMP_COST` / `JUMP_TIME` / `JUMP_SPEED` | 0,22 / 0,35 sn / 3,6 m/sn |
| `REGEN` / `REGEN_DELAY` / `TIRED_MIN` | 0,55 /sn / 0,45 sn / 0,4 |
| `REACH` / `VAULT_MAX` | 2,3 m / 1,1 m |
| `STEP_TIME` / `STEP_COST` (el el tıklama) | 0,3 sn / 0,035 |

Sonda: 2,2 m duvara zıplayıp çıkma 0,68 sn (`mantle`, nefes 1,00); 7 m duvarda tırmanış 3,90 sn, kenarda nefes 0,53.
Görüntü: tutunmada iki "kol" kameraya bağlı belirir (`_show_hands`), çıkarken aşağı iter; tutunma anında taş sesi.
Kamera: tutunma ve çıkışta **hiç oynamaz** (gövde tween'le taşınır). Yorgunlukta ellerde/kamerada değişiklik yok, nefes
sesi yok (kitaplıkta nefes efekti de yok); nefes tükenince `D_CLIMB_TIRED_1..3`.

## 5. Merdiven (`Player._ladder_physics`)

Hız 2,2 m/sn (Shift ×1,5); 3,4 m merdiven 1,47 sn. Eller basamaklarda (`_ladder_hands_tick`), basamak başına adım sesi.
Tepede `global_position = ladder.top_exit()`: gövde ve kamera **bir karede** 0,7 m geri ve ~0,2 m yukarı sıçrar.

## 6. Kamera

| davranış | değer |
|---|---|
| baş sallanması | `sin(_bob·2)·0,03 m` × (hız/WALK, ≤ 1); `_bob += hız·1,3·delta` |
| adım sıklığı | yürüme ~2,6/sn, koşu ~4,3/sn (adım sesi `_bob` çeyrek turunda) |
| görüş açısı | ayardaki `fov` (60–100, varsayılan 72); koşuda **değişmez** |
| eğilme / yatış | yok (yalnız yüzerken `floating` yatışı) |
| sarsıntı | `shake(x)`: ±0,05·x m rastgele, 2,5/sn söner |
| basamak | `step_up` → `_cam_dy` (kamera geride kalır, 14/sn ile yetişir) |
| kamera ara değerleme | `_interpolate_camera` (fizik 60 Hz / ekran) |
| erişilebilirlik | `sway` (baş ve el sallanması kapatılır), `fx` (vuruş hissi: ağır çekim, sarsıntı) |

## 7. Sesler

| olay | ses |
|---|---|
| adım | `Audio.step(hand_style)` — Tolga terlik (`footstep_slipper`, −23 dB), çimde `footstep_grass`; koşuda aynı ses, yalnız sıklık artar |
| iniş | yalnız AÇIK kipte `land_thud` |
| tutunma / el el | `footstep_stone` −18..−24 dB |
| tırmanırken sıçrama | `whoosh_fly` −20 dB |
| nefes | yok |
| düşüş | serbest düşüşte yok; bölümler kendisi: Bölüm 2 `D2_T_FALL_SCREAM` + `flail(1.4)`; 41o/38o `fall_scream` |

## 8. Bölüm 2 ve 44b düşüşleri

- **Bölüm 2** (`chapter2.gd _plunge`): kızağın ucundan suya yay; `hud.bark(D2_T_FALL_SCREAM)`, `flail(1.4)`, 1,25 sn
  tween, suya çarpınca `cut_voice`, `shake(0.8)`. Oyun sahibinin sevdiği düşüş.
- **Bölüm 44b** (`chapter44b.gd _descend`): ip kopar (`paper_tear`), `shake(0.25)`, 0,75 sn'lik tween'le suya iner.
  Kol savrulması, rüzgâr, çığlık **yok**.

## 9. Değişmeyecekler (bu işte)

`WALK`, `RUN`, `JUMP`, havadaki ivme (menzil), `STEP_H`, `STAGGER_FALL`, sendeleme süresi, düşme davranışı/hasar,
tırmanma ve nefes sabitlerinin tümü, merdiven hızı, `Traversal` süreleri (mantle `t1 + 0,22`, vault 0,2 sn).
