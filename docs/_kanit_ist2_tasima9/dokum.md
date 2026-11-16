# TAŞIMA 9 — ÖLÇÜM DÖKÜMÜ: eski Blakherna seti ve Bölüm 30 / 30o bağları

Taban `wip/ist2-taban16` = fa66841e. Ölçüm aracı `tests/_ist/tasima9_sonda.tscn` (başsız; `Blachernae`'yi eski ve yeni kipte AYNI
sahnede sırayla kurar, çevre dünyası kurulmaz: `in_world = false`). Ham çıktı `testler/sonda.txt`.

## 1. Eski set (`scripts/level/blachernae.gd`) — çarpışma ve yürüme noktaları

### 1.1 Sabitler
| ad | değer | yer |
|---|---|---|
| `WALL_Z0` / `WALL_Z1` | 0 / 4,6 (iç yüz / dış yüz, ova +z) | `blachernae.gd:15-16` |
| `WALK_Y`, `WALL_H` | 12, 12 | `:17-18` |
| `TOWERS` | x −40, −20, 20, 40 (8 × 17 × 8 m; merkez z 6,2 = WALL_Z1 + 1,6: surdan 5,6 m öne taşar) | `:19`, `shell_parts "wall"` |
| köşe kuleleri (`join`) | x ±62, 9 × 19 × 9 m, merkez z 2,3 | `shell_parts "join"` |
| mazgal dişleri | x −59 + 1,9 k, 1,1 × 1,1 × 0,6 m, z 4,0…4,6, tepe y 13,1 (çarpışmasız) | `shell_parts "wall"` |
| iç taş rampa | (−14; 0; −6) → (−6; 12; −0,2), en 2,4 m (eğim ≈ 50°) | `_wall` |
| dış zemin | 6 levha 140 × 0,4 × 10,2 m, üstü **y 0** (z 4,6…65,8); `slope_y(z) = 0` | `_ground`, `slope_y` |
| iç avlu | 140 × 0,4 × 60 m, üstü y 0 (z −60…0) | `_ground` |
| saray | gövde 26 × 16 × 10 (merkez (0; 8; −21), cephe z −16), yan kuleler 5 × 20 × 5 (±14,4; 10; −20) | `shell_parts "palace"` |
| korkuluklar (görünmez, `build_guards`) | dış: 3 m yüksek, z 4,35…4,65, merdiven açıklığı x ± 0,9; iç: z −0,05…0,25, 30'da merdiven başı açık (x −7,4…−4,6), 30o'da kapalı | `build_guards` |
| oynanış alanı (dünya kesmesi) | Rect2(−75; −62; 150; 130) | `_ready` |

### 1.2 Sur yolu (ışın, üstten; 0,5 m adım)
    BLAKYOL eski z=1.0 -62.0..-60.5@-9.00 -60.0..60.0@12.00 60.5..62.0@-9.00
    BLAKYOL eski z=2.3 -62.0..-60.5@-9.00 -60.0..-44.5@12.00 -44.0..-36.0@17.00 -35.5..-24.5@12.00 -24.0..-16.0@17.00 -15.5..15.5@12.00 16.0..24.0@17.00 24.5..35.5@12.00 36.0..44.0@17.00 44.5..60.0@12.00 60.5..62.0@-9.00
    BLAKYOL eski z=3.6 -62.0..-60.5@-9.00 -60.0..-44.5@12.00 -44.0..-36.0@17.00 -35.5..-24.5@12.00 -24.0..-16.0@17.00 -15.5..15.5@12.00 16.0..24.0@17.00 24.5..35.5@12.00 36.0..44.0@17.00 44.5..60.0@12.00 60.5..62.0@-9.00
    BLAKRAMPA eski 0.56 1.56 2.56 3.56 4.56 5.56 6.56 7.56 8.56 9.56 10.56 11.56
    BLAKZEMIN eski dis y=0.000..0.000 bos=29
    BLAKZEMIN eski ic y=0.000..0.000 bos=0

- z 1,0 (yolun iç yarısı): x −60…60 kesintisiz y 12 (kulelerin arkası).
- z 2,3 ve 3,6 (yolun dış yarısı): kuleler yolu keser → yürünür parçalar −60…−44,5 · −35,5…−24,5 · **−15,5…15,5 (31 m, oynanan
  kısım)** · 24,5…35,5 · 44,5…60 (y 12); kuleler x ±16…24, ±36…44 (y 17, kule tepesi).
- Rampa: 12 noktada 0,56 … 11,56 (doğrusal, 1 m/adım).
- Zemin: dış ve iç levhaların hepsi y 0,000 (düz).

### 1.3 Bütün çarpışma şekilleri (47; eski kip, sıralı)
| konum, dönüş, boy, no_climb |
|---|
| poz=(-10.000,5.900,-3.100) don=(50.53,-125.94,0.00) boy=(2.400,0.200,15.645) nc=false |
| poz=(-14.400,10.000,-20.000) don=(-0.00,0.00,0.00) boy=(5.000,20.000,5.000) nc=false |
| poz=(-16.031,0.360,92.851) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(-16.282,0.360,75.552) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(-20.000,8.500,6.200) don=(-0.00,0.00,0.00) boy=(8.000,17.000,8.000) nc=false |
| poz=(-22.504,0.360,97.172) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(-25.450,13.500,4.500) don=(-0.00,0.00,0.00) boy=(69.100,3.000,0.300) nc=true |
| poz=(-27.804,0.360,86.009) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(-33.952,0.360,101.447) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(-4.204,0.360,100.751) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(-40.000,8.500,6.200) don=(-0.00,0.00,0.00) boy=(8.000,17.000,8.000) nc=false |
| poz=(-40.238,0.360,82.689) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(-52.142,0.360,83.356) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(-56.129,0.360,77.641) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(0.000,-0.200,-30.000) don=(-0.00,0.00,0.00) boy=(140.000,0.400,60.000) nc=false |
| poz=(0.000,-0.200,19.600) don=(-0.00,0.00,0.00) boy=(140.000,0.400,10.200) nc=false |
| poz=(0.000,-0.200,29.600) don=(-0.00,0.00,0.00) boy=(140.000,0.400,10.200) nc=false |
| poz=(0.000,-0.200,39.600) don=(-0.00,0.00,0.00) boy=(140.000,0.400,10.200) nc=false |
| poz=(0.000,-0.200,49.600) don=(-0.00,0.00,0.00) boy=(140.000,0.400,10.200) nc=false |
| poz=(0.000,-0.200,59.600) don=(-0.00,0.00,0.00) boy=(140.000,0.400,10.200) nc=false |
| poz=(0.000,-0.200,9.600) don=(-0.00,0.00,0.00) boy=(140.000,0.400,10.200) nc=false |
| poz=(0.000,0.000,0.000) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=false |
| poz=(0.000,0.000,0.000) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=false |
| poz=(0.000,0.000,0.000) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=false |
| poz=(0.000,0.000,0.000) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=false |
| poz=(0.000,0.000,0.000) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=false |
| poz=(0.000,0.000,0.000) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=false |
| poz=(0.000,0.000,0.000) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=false |
| poz=(0.000,0.000,0.000) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=false |
| poz=(0.000,0.000,0.000) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=false |
| poz=(0.000,0.000,0.000) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=false |
| poz=(0.000,13.500,0.100) don=(-0.00,0.00,0.00) boy=(120.000,3.000,0.300) nc=true |
| poz=(0.000,6.000,2.300) don=(-0.00,0.00,0.00) boy=(120.000,12.000,4.600) nc=true |
| poz=(0.000,8.000,-21.000) don=(-0.00,0.00,0.00) boy=(26.000,16.000,10.000) nc=false |
| poz=(1.075,0.360,95.896) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(1.602,0.360,96.058) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(14.400,10.000,-20.000) don=(-0.00,0.00,0.00) boy=(5.000,20.000,5.000) nc=false |
| poz=(18.716,0.360,87.977) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(20.000,8.500,6.200) don=(-0.00,0.00,0.00) boy=(8.000,17.000,8.000) nc=false |
| poz=(35.450,13.500,4.500) don=(-0.00,0.00,0.00) boy=(49.100,3.000,0.300) nc=true |
| poz=(40.000,8.500,6.200) don=(-0.00,0.00,0.00) boy=(8.000,17.000,8.000) nc=false |
| poz=(45.577,0.360,102.589) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(51.065,0.360,97.147) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(52.388,0.360,82.656) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(54.042,0.360,82.866) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(56.654,0.360,80.620) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |
| poz=(57.424,0.360,70.600) don=(-0.00,0.00,0.00) boy=(-1.000,-1.000,-1.000) nc=true |

(boy −1 = kutu olmayan şekil: ateş/ışık düğümlerinin küçük gövdeleri.)

## 2. Bölüm bağları (eski → yeni)

Yeni sette **çarpışma ve ölçü aynı** (bkz. §3): bütün sabit koordinatlar, `WALK_Y`, `WALL_Z0/Z1`, `TOWERS`, `build_guards`,
`night_assault`, tırmanıcı merdivenleri, rampa, `quiet_tower`, `live_range/live_spots` AYNI yerde kalır. Değişen tek bağ türü:
**düz zemin varsayan NPC/nesne yükseklikleri** (merdiven ayağı, taşıyanlar, koşucular, okların düştüğü yer, çalı, yaralı,
Zağanos, bozgun, Grant) artık `Blachernae.zemin_y(x, z)` sorgusundan (eski sette 0; yeni sette görünen zeminin ±1,6 cm
engebesi). Oyuncunun kendi yüksekliği (`slope_y + 0,05`) çarpışma zemininde kalır (y 0).

Toplam: Bölüm 30 → aşağıdaki tablo; Bölüm 30o → aşağıdaki tablo (SUR_BOLUM_TASIMA §4.1 sayımı 19 / 87 idi; burada sabit
tanımları ve sabitleri kullanan satırlar birlikte).

### `scripts/chapter30.gd` (44 satır)

| satır | kod (bugünkü) | yeni sette |
|---|---|---|
| 14 | `const LADDERS := [-12.0, -4.0, 6.0, 14.0]` | aynı (çarpışma/ölçü aynı) |
| 15 | `const CLIMB_TIME := 11.0` | aynı (çarpışma/ölçü aynı) |
| 18 | `const TILT := 16.0` | aynı (çarpışma/ölçü aynı) |
| 19 | `const WALK := Blachernae.WALK_Y` | aynı (çarpışma/ölçü aynı) |
| 54 | `walls = Blachernae.new()` | aynı (çarpışma/ölçü aynı) |
| 57 | `walls.dissiz = LADDERS` | aynı (çarpışma/ölçü aynı) |
| 60 | `walls.night_assault(LADDERS + [6.0, -6.0], false)` | aynı (çarpışma/ölçü aynı) |
| 64 | `emperor.position = Vector3(-6.0, WALK, Blachernae.WALL_Z0 + 1.2)` | aynı (çarpışma/ölçü aynı) |
| 75 | `d.position = Vector3(dx, WALK, Blachernae.WALL_Z1 - 1.2)` | aynı (çarpışma/ölçü aynı) |
| 103 | `player.global_position = Vector3(1.0, WALK + 0.05, Blachernae.WALL_Z0 + 2.2)` | aynı (çarpışma/ölçü aynı) |
| 138 | `var x: float = LADDERS[i]` | aynı (çarpışma/ölçü aynı) |
| 140 | `"path": [Vector3(x + 6.0, 0, 46.0), Vector3(x + 2.0, 0, 26.0), Vector3(x, 0, Blachernae.WALL_Z1 + 3.0)], "delay": i * 1.6, "ladder": true})` | aynı (çarpışma/ölçü aynı) |
| 143 | `"look": Vector3(0, 1.0, 30.0), "ground": Blachernae.zemin_y})` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 155 | `await hud.say("SPK_DEFENDER", "D30_D_LADDERS")` | aynı (çarpışma/ölçü aynı) |
| 157 | `_spawn_ladder(LADDERS[(i * 3) % 4] if i < 4 else LADDERS[i % 4], i * 2.5)` | aynı (çarpışma/ölçü aynı) |
| 186 | `var k := clampf(float(l["t"]) / CLIMB_TIME, 0.0, 1.0)` | aynı (çarpışma/ölçü aynı) |
| 202 | `player.global_position = Vector3(float(l["x"]), WALK + 0.05, Blachernae.WALL_Z1 - 1.0)` | aynı (çarpışma/ölçü aynı) |
| 212 | `if l["state"] == "up" and float(l["t"]) >= 0.0 and Vector2(player.global_position.x - float(l["x"]), player.global_position.z - (Blachern…` | aynı (çarpışma/ölçü aynı) |
| 269 | `var lh := WALK + 0.6` | aynı (çarpışma/ölçü aynı) |
| 270 | `var lad := Ladder.new(lh, TILT, Color("6a4a2c"))` | aynı (çarpışma/ölçü aynı) |
| 271 | `var bz := Blachernae.WALL_Z1 + lh * sin(deg_to_rad(TILT)) + 0.12` | aynı (çarpışma/ölçü aynı) |
| 272 | `var base := Vector3(x, Blachernae.zemin_y(x, bz), bz)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 291 | `const CARRY_T := 5.5       # ovadan surun dibine taşıma (sn)` | aynı (çarpışma/ölçü aynı) |
| 292 | `const RAISE_T := 1.3       # merdiveni kaldırıp sura dayama` | aynı (çarpışma/ölçü aynı) |
| 293 | `const CARRY_FROM := 34.0   # surun dibinden ne kadar uzaktan gelirler (m)` | aynı (çarpışma/ölçü aynı) |
| 303 | `var flat := deg_to_rad(90.0 + TILT)            # düğümün x dönüşü: merdiven yerde, sur tarafından dışarı doğru uzanır` | aynı (çarpışma/ölçü aynı) |
| 305 | `var k := clampf(float(l["st"]) / CARRY_T, 0.0, 1.0)` | aynı (çarpışma/ölçü aynı) |
| 306 | `var at := base + Vector3(0, 1.35, CARRY_FROM * (1.0 - k))` | aynı (çarpışma/ölçü aynı) |
| 313 | `c.global_position = Vector3(at.x + side, Blachernae.zemin_y(at.x + side, at.z + along), at.z + along)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 320 | `var k := clampf(float(l["st"]) / RAISE_T, 0.0, 1.0)` | aynı (çarpışma/ölçü aynı) |
| 328 | `to.y = Blachernae.zemin_y(to.x, to.z)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 362 | `Vfx.dust(self, Vector3(float(l["x"]), 0.2, Blachernae.WALL_Z1 + 8.0), 1.0)` | aynı (çarpışma/ölçü aynı) |
| 387 | `var walk := Vector3(float(l["x"]), WALK, Blachernae.WALL_Z1 - 1.3)` | aynı (çarpışma/ölçü aynı) |
| 416 | `look = Vector3(float(l["x"]), WALK + 1.0, Blachernae.WALL_Z1 - 0.6)` | aynı (çarpışma/ölçü aynı) |
| 418 | `hud.set_objective(tr("UI_OBJ30_LADDERS") % left, look)` | aynı (çarpışma/ölçü aynı) |
| 432 | `var zc := (Blachernae.WALL_Z0 + Blachernae.WALL_Z1) * 0.5` | aynı (çarpışma/ölçü aynı) |
| 434 | `var at := Vector3(player.global_position.x + 3.2 + k * 1.2, WALK, zc + (k % 2) * 0.6 - 0.3)` | aynı (çarpışma/ölçü aynı) |
| 437 | `at = Vector3((_boarded[k] as Node3D).global_position.x, WALK, zc + (k % 2) * 0.6 - 0.3)` | aynı (çarpışma/ölçü aynı) |
| 457 | `var at := Vector3(px + float(order[0]), WALK, Blachernae.WALL_Z0 + 1.6)` | aynı (çarpışma/ölçü aynı) |
| 459 | `var c := Vector3(px + dx, WALK, Blachernae.WALL_Z0 + 1.6)` | aynı (çarpışma/ölçü aynı) |
| 465 | `var stair_lo := Vector3(-14.0, 0.0, Blachernae.WALL_Z0 - 6.0)` | aynı (çarpışma/ölçü aynı) |
| 466 | `var stair_hi := Vector3(-6.0, WALK, Blachernae.WALL_Z0 - 0.2)` | aynı (çarpışma/ölçü aynı) |
| 620 | `cv.global_position = Vector3(-4.0, WALK + 2.6, Blachernae.WALL_Z0 + 1.0)` | aynı (çarpışma/ölçü aynı) |
| 621 | `cv.look_at(Vector3(6.0, WALK - 2.0, Blachernae.WALL_Z1 + 2.0), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |

### `scripts/chapter30o.gd` (142 satır)

| satır | kod (bugünkü) | yeni sette |
|---|---|---|
| 20 | `const CLIMB_X := 10.0` | aynı (çarpışma/ölçü aynı) |
| 21 | `const TILT := 16.0` | aynı (çarpışma/ölçü aynı) |
| 22 | `const START := Vector3(10.0, 0.0, 40.0)` | aynı (çarpışma/ölçü aynı) |
| 23 | `const PLANT := Vector3(10.0, 0.0, 8.0)` | aynı (çarpışma/ölçü aynı) |
| 24 | `const SAFE_Z := 34.0` | aynı (çarpışma/ölçü aynı) |
| 25 | `const TOWER_X := 20.0                  # tüfekçinin kulesi (Blachernae.TOWERS)` | aynı (çarpışma/ölçü aynı) |
| 27 | `const BUSH := Vector3(CLIMB_X + 2.8, 0.0, Blachernae.WALL_Z1 + 7.4)` | aynı (çarpışma/ölçü aynı) |
| 86 | `walls = Blachernae.new()` | aynı (çarpışma/ölçü aynı) |
| 89 | `walls.build_guards([CLIMB_X], false)` | aynı (çarpışma/ölçü aynı) |
| 91 | `walls.live_range = Vector2(CLIMB_X - 28.0, CLIMB_X + 30.0)` | aynı (çarpışma/ölçü aynı) |
| 92 | `walls.quiet_tower = TOWER_X` | aynı (çarpışma/ölçü aynı) |
| 93 | `walls.night_assault([CLIMB_X])` | aynı (çarpışma/ölçü aynı) |
| 107 | `var lh := Blachernae.WALK_Y + 0.6` | aynı (çarpışma/ölçü aynı) |
| 108 | `ladder = Ladder.new(lh, TILT, Color("6a4a2c"))` | aynı (çarpışma/ölçü aynı) |
| 109 | `var lz := Blachernae.WALL_Z1 + lh * sin(deg_to_rad(TILT)) + 0.12` | aynı (çarpışma/ölçü aynı) |
| 110 | `ladder.position = Vector3(CLIMB_X, Blachernae.zemin_y(CLIMB_X, lz), lz)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 114 | `var th := Blachernae.WALL_H + 5.0 - Blachernae.WALK_Y + 0.6` | aynı (çarpışma/ölçü aynı) |
| 116 | `tower_ladder.position = Vector3(TOWER_X - 4.0 - th * sin(deg_to_rad(14.0)) - 0.12, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 1.3)` | aynı (çarpışma/ölçü aynı) |
| 121 | `_bush(BUSH)` | aynı (çarpışma/ölçü aynı) |
| 122 | `_bush(Vector3(TOWER_X + 1.0, 0.0, Blachernae.WALL_Z1 + 7.4))` | aynı (çarpışma/ölçü aynı) |
| 126 | `zaganos.position = START + Vector3(-3.0, Blachernae.zemin_y(START.x - 3.0, START.z + 2.0), 2.0)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 151 | `emperor.position = Vector3(-3.0, Blachernae.WALK_Y, Blachernae.WALL_Z0 + 2.4)` | aynı (çarpışma/ölçü aynı) |
| 160 | `wounded.position = Vector3(CLIMB_X + 2.4, 0.1 + Blachernae.zemin_y(CLIMB_X + 2.4, Blachernae.WALL_Z1 + 1.6), Blachernae.WALL_Z1 + 1.6)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 177 | `player.global_position = START + Vector3(0, Blachernae.slope_y(START.z) + 0.05, 0)` | aynı (oyuncu: çarpışma zemini y 0) |
| 206 | `hud.set_objective(tr("UI_OBJ30O_CARRY"), PLANT + Vector3(0, 1.0, 0))` | aynı (çarpışma/ölçü aynı) |
| 209 | `while Vector2(player.global_position.x - PLANT.x, player.global_position.z - PLANT.z).length() > 2.2:` | aynı (çarpışma/ölçü aynı) |
| 215 | `var to := PLANT - player.global_position` | aynı (çarpışma/ölçü aynı) |
| 220 | `player.global_position.y = Blachernae.slope_y(player.global_position.z) + 0.05` | aynı (oyuncu: çarpışma zemini y 0) |
| 231 | `at.y = Blachernae.zemin_y(at.x, at.z)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 247 | `at.y = Blachernae.zemin_y(at.x, at.z)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 250 | `c.look_at(Vector3(at.x, at.y, Blachernae.WALL_Z1), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 257 | `hud.bark("SPK_ZAGANOS", "D30O_Z_PLANT", 3.5)` | aynı (çarpışma/ölçü aynı) |
| 325 | `p.y = Blachernae.zemin_y(p.x, p.z)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 342 | `var cd := fight.add_cauldron(Vector3(CLIMB_X - 6.0, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.9), 3012)` | aynı (çarpışma/ölçü aynı) |
| 350 | `_top_man.global_position = Vector3(CLIMB_X + 0.75, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.55)` | aynı (çarpışma/ölçü aynı) |
| 357 | `while not (player.ladder == null and player.global_position.y > Blachernae.WALK_Y - 0.3 and player.global_position.z < Blachernae.WALL_Z1):` | aynı (çarpışma/ölçü aynı) |
| 475 | `var y := Blachernae.WALK_Y` | aynı (çarpışma/ölçü aynı) |
| 476 | `var zc := (Blachernae.WALL_Z0 + Blachernae.WALL_Z1) * 0.5` | aynı (çarpışma/ölçü aynı) |
| 477 | `var east := [Vector3(CLIMB_X + 3.6, y, zc), Vector3(CLIMB_X + 2.4, y, zc - 0.6)]` | aynı (çarpışma/ölçü aynı) |
| 480 | `var west := [Vector3(CLIMB_X - 3.6, y, zc), Vector3(CLIMB_X - 2.4, y, zc + 0.4)]` | aynı (çarpışma/ölçü aynı) |
| 522 | `if player.global_position.y > Blachernae.WALK_Y + 3.0:` | aynı (çarpışma/ölçü aynı) |
| 535 | `var on_tower := player.global_position.y > Blachernae.WALK_Y + 3.0` | aynı (çarpışma/ölçü aynı) |
| 540 | `emperor.position = Vector3(CLIMB_X + 0.35, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.3)` | aynı (çarpışma/ölçü aynı) |
| 577 | `return Vector3(TOWER_X - 1.6, Blachernae.WALL_H + 5.0, Blachernae.WALL_Z1 + 0.2)` | aynı (çarpışma/ölçü aynı) |
| 588 | `var top := Blachernae.WALL_H + 5.0` | aynı (çarpışma/ölçü aynı) |
| 659 | `var on_tower := p.y > Blachernae.WALK_Y + 3.0` | aynı (çarpışma/ölçü aynı) |
| 660 | `var face_z := Blachernae.WALL_Z1 + (8.0 + 0.6 if on_tower else 0.6)` | aynı (çarpışma/ölçü aynı) |
| 661 | `var land := Vector3(TOWER_X + 1.0, 0.0, Blachernae.WALL_Z1 + 7.4) if on_tower else BUSH` | aynı (çarpışma/ölçü aynı) |
| 674 | `player.face(Vector3(land.x, Blachernae.WALK_Y + 1.5, Blachernae.WALL_Z0))` | aynı (çarpışma/ölçü aynı) |
| 680 | `at.y += Blachernae.zemin_y(at.x, at.z)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 693 | `var top := Blachernae.WALL_H + 5.0` | aynı (çarpışma/ölçü aynı) |
| 694 | `var zc := Blachernae.WALL_Z1 + 1.6` | aynı (çarpışma/ölçü aynı) |
| 695 | `for b: Array in [[Vector3(8.0, 2.0, 0.3), Vector3(TOWER_X, top + 1.0, zc + 4.0)],` | aynı (çarpışma/ölçü aynı) |
| 696 | `[Vector3(0.3, 2.0, 8.0), Vector3(TOWER_X + 4.0, top + 1.0, zc)],` | aynı (çarpışma/ölçü aynı) |
| 697 | `[Vector3(8.0, 2.0, 0.3), Vector3(TOWER_X, top + 1.0, zc - 4.0)],` | aynı (çarpışma/ölçü aynı) |
| 698 | `[Vector3(0.3, 2.0, 5.0), Vector3(TOWER_X - 4.0, top + 1.0, zc + 1.5)]]:` | aynı (çarpışma/ölçü aynı) |
| 704 | `Props.box(self, Vector3(1.1, 0.9, 0.5), Vector3(TOWER_X - 3.0 + k * 2.0, top + 0.45, zc + 3.75), Blachernae.C_STONE.darkened(0.1))` | aynı (çarpışma/ölçü aynı) |
| 705 | `Props.box(self, Vector3(0.5, 0.9, 1.1), Vector3(TOWER_X + 3.75, top + 0.45, zc - 3.0 + k * 2.0), Blachernae.C_STONE.darkened(0.1))` | aynı (çarpışma/ölçü aynı) |
| 727 | `var y := Blachernae.WALK_Y` | aynı (çarpışma/ölçü aynı) |
| 728 | `var zc := (Blachernae.WALL_Z0 + Blachernae.WALL_Z1) * 0.5` | aynı (çarpışma/ölçü aynı) |
| 730 | `var px := player.global_position.x if on_wall else CLIMB_X` | aynı (çarpışma/ölçü aynı) |
| 774 | `var look := emperor.global_position if on_wall else Vector3(CLIMB_X, y, zc)` | aynı (çarpışma/ölçü aynı) |
| 804 | `s.face_toward(player.global_position if on_wall else Vector3(CLIMB_X, y, 40.0))` | aynı (çarpışma/ölçü aynı) |
| 821 | `if player.global_position.y > Blachernae.WALK_Y - 2.0:` | aynı (çarpışma/ölçü aynı) |
| 832 | `hud.set_objective(tr("UI_OBJ30O_BACK"), Vector3(CLIMB_X, 1.0, SAFE_Z))` | aynı (çarpışma/ölçü aynı) |
| 836 | `while player.global_position.z < SAFE_Z:` | aynı (çarpışma/ölçü aynı) |
| 843 | `player.global_position.y = Blachernae.slope_y(player.global_position.z) + 0.05` | aynı (oyuncu: çarpışma zemini y 0) |
| 847 | `if volley <= 0.0 and player.global_position.z < SAFE_Z - 4.0:` | aynı (çarpışma/ölçü aynı) |
| 850 | `at.y = Blachernae.zemin_y(at.x, at.z)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 862 | `await Stage.approach(zaganos, player.global_position, 2.4, 1.6, Vector3.ZERO, func(x: float, z: float) -> float: return Blachernae.zemin_…` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 891 | `if nd and nd.is_visible_in_tree() and not (nd is Soldier and nd in reinforcements) and absf(nd.global_position.y - Blachernae.WALK_Y) < 2.0:` | aynı (çarpışma/ölçü aynı) |
| 893 | `var mx := CLIMB_X - 16.0` | aynı (çarpışma/ölçü aynı) |
| 898 | `var c := Vector3(mx, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.45)` | aynı (çarpışma/ölçü aynı) |
| 909 | `player.global_position = Vector3(CLIMB_X - 1.6, Blachernae.slope_y(Blachernae.WALL_Z1 + 2.4) + 0.05, Blachernae.WALL_Z1 + 2.4)` | aynı (oyuncu: çarpışma zemini y 0) |
| 933 | `var ends: Array = [Vector3(CLIMB_X - 3.0, 0.0, SAFE_Z + 7.0)]` | aynı (çarpışma/ölçü aynı) |
| 935 | `ends.append(Vector3(c, 0.0, SAFE_Z + 9.5))` | aynı (çarpışma/ölçü aynı) |
| 993 | `var push_spot := Vector3(CLIMB_X + 0.65, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 1.0)` | aynı (çarpışma/ölçü aynı) |
| 1003 | `var on_walk := grab_t < 0.0 and player.ladder == null and pp.y > Blachernae.WALK_Y - 0.8 and not player.frozen` | aynı (çarpışma/ölçü aynı) |
| 1035 | `var wx := maxf(pp.x + 0.8, CLIMB_X + 1.3) + float(c[1])` | aynı (çarpışma/ölçü aynı) |
| 1036 | `want = Vector3(wx, Blachernae.WALK_Y, clampf(pp.z, 0.8, 3.8) if s == lead else float(c[2]))` | aynı (çarpışma/ölçü aynı) |
| 1069 | `if absf(q.y - Blachernae.WALK_Y) < 1.2 and q.x > CLIMB_X - 2.0 and q.x < TOWER_X:` | aynı (çarpışma/ölçü aynı) |
| 1115 | `if is_instance_valid(s) and s.visible and s.global_position.x > maxf(px, CLIMB_X) + 0.4:` | aynı (çarpışma/ölçü aynı) |
| 1117 | `var zc := (Blachernae.WALL_Z0 + Blachernae.WALL_Z1) * 0.5` | aynı (çarpışma/ölçü aynı) |
| 1124 | `s.global_position = Vector3(15.4, Blachernae.WALK_Y, zc + (float(k) - 0.5) * 1.3)` | aynı (çarpışma/ölçü aynı) |
| 1128 | `var spot := Vector3(CLIMB_X, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 1.0)` | aynı (çarpışma/ölçü aynı) |
| 1159 | `g.face_toward(Vector3(CLIMB_X, g.global_position.y, Blachernae.WALL_Z1 + 2.0))` | aynı (çarpışma/ölçü aynı) |
| 1202 | `var a1 := deg_to_rad(TILT + 89.6)` | aynı (çarpışma/ölçü aynı) |
| 1203 | `var fling_at := deg_to_rad(TILT + 52.0)` | aynı (çarpışma/ölçü aynı) |
| 1218 | `player.face(ladder.point_at(ladder.height).lerp(Vector3(CLIMB_X + 0.6, Blachernae.WALK_Y + 1.4, Blachernae.WALL_Z1 - 1.0), 0.75))` | aynı (çarpışma/ölçü aynı) |
| 1235 | `player.face(Vector3(CLIMB_X, Blachernae.WALK_Y + 1.2, Blachernae.WALL_Z1 - 0.6))` | aynı (çarpışma/ölçü aynı) |
| 1241 | `return Vector3(CLIMB_X + 1.9, 0.0, clampf(p.z + 0.8, Blachernae.WALL_Z1 + 6.0, 22.0))` | aynı (çarpışma/ölçü aynı) |
| 1360 | `s.global_position = Vector3(p.x + st.x, Blachernae.zemin_y(p.x + st.x, p.z + st.z), p.z + st.z)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 1374 | `if d and d.team == 0 and d.alive() and d.is_visible_in_tree() and absf(d.global_position.y - Blachernae.WALK_Y) < 1.5 \` | aynı (çarpışma/ölçü aynı) |
| 1375 | `and absf(d.global_position.x - CLIMB_X) < 12.0:` | aynı (çarpışma/ölçü aynı) |
| 1391 | `if absf(cx - CLIMB_X) < 1.4 or absf(cx - (CLIMB_X - 6.0)) < 1.3 or cx > TOWER_X - 5.0 or cx in out:` | aynı (çarpışma/ölçü aynı) |
| 1408 | `d.path = [Vector3(d.global_position.x - 2.6, Blachernae.WALK_Y, d.global_position.z)]` | aynı (çarpışma/ölçü aynı) |
| 1418 | `d.path = [Vector3(cx, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.65)]` | aynı (çarpışma/ölçü aynı) |
| 1450 | `var peak := Vector3(cx, Blachernae.WALK_Y + 1.25, Blachernae.WALL_Z1 + 0.55)` | aynı (çarpışma/ölçü aynı) |
| 1451 | `var land := Vector3(cx, Blachernae.zemin_y(cx, Blachernae.WALL_Z1 + 6.0), Blachernae.WALL_Z1 + 6.0)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 1473 | `var gy := func(x: float, z: float) -> float: return Blachernae.zemin_y(x, z)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 1475 | `for side: Array in [[Vector3(CLIMB_X - 17.0, 0, Blachernae.WALL_Z1 + 3.0), Vector3(CLIMB_X - 4.5, 0, Blachernae.WALL_Z1 + 3.0), 7, 3011],` | aynı (çarpışma/ölçü aynı) |
| 1476 | `[Vector3(CLIMB_X + 5.0, 0, Blachernae.WALL_Z1 + 6.9), Vector3(CLIMB_X + 16.0, 0, Blachernae.WALL_Z1 + 6.9), 6, 3012]]:` | aynı (çarpışma/ölçü aynı) |
| 1481 | `rt.wall_top = [Vector3(CLIMB_X - 16.0, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.3), Vector3(CLIMB_X + 12.0, Blachernae.WALK_Y, Blacherna…` | aynı (çarpışma/ölçü aynı) |
| 1482 | `rt.setup(side[0], side[1], SAFE_Z + 4.0, side[2], side[3], gy, avoid)` | aynı (çarpışma/ölçü aynı) |
| 1491 | `player.global_position = Vector3(p.x, Blachernae.slope_y(p.z) + 0.05, p.z)` | aynı (oyuncu: çarpışma zemini y 0) |
| 1556 | `at.y = Blachernae.zemin_y(at.x, at.z)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 1562 | `grant.global_position = Vector3(at.x - 0.2, Blachernae.zemin_y(at.x - 0.2, gz), gz)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 1570 | `m.global_position = Vector3(at.x - 1.3 + 2.6 * k, Blachernae.zemin_y(at.x - 1.3 + 2.6 * k, mz), mz)` | **zemin_y** (görünen zemin; eski 0 / slope_y) |
| 1732 | `cv.global_position = Vector3(CLIMB_X + 9.0, 3.0, 26.0)` | aynı (çarpışma/ölçü aynı) |
| 1733 | `cv.look_at(Vector3(CLIMB_X - 2.0, 8.0, 2.0), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 1739 | `for v: Array in [[START + Vector3(0, 1.7, 0), Vector3(0, 6.0, 0), "c30o_view_wall.png"],` | aynı (çarpışma/ölçü aynı) |
| 1740 | `[Vector3(CLIMB_X, Blachernae.WALK_Y + 1.7, 2.0), Vector3(200.0, 4.0, 10.0), "c30o_view_south.png"],` | aynı (çarpışma/ölçü aynı) |
| 1741 | `[Vector3(CLIMB_X, Blachernae.WALK_Y + 1.7, 2.0), Vector3(-200.0, 0.0, -60.0), "c30o_view_horn.png"],` | aynı (çarpışma/ölçü aynı) |
| 1742 | `[Vector3(CLIMB_X, Blachernae.WALK_Y + 1.7, 2.0), Vector3(CLIMB_X, 0.0, 120.0), "c30o_view_field.png"],` | aynı (çarpışma/ölçü aynı) |
| 1776 | `player.global_position = Vector3(CLIMB_X, Blachernae.WALK_Y + 0.05, 2.3)` | aynı (çarpışma/ölçü aynı) |
| 1780 | `cv.global_position = Vector3(CLIMB_X + 1.0, Blachernae.WALK_Y + 2.6, 4.6)` | aynı (çarpışma/ölçü aynı) |
| 1781 | `cv.look_at(Vector3(CLIMB_X - 9.0, Blachernae.WALK_Y + 1.0, 2.3), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 1783 | `cv.look_at(Vector3(CLIMB_X + 5.0, Blachernae.WALK_Y + 1.0, 2.3), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 1787 | `player.global_position = Vector3(13.3, Blachernae.WALK_Y + 0.05, 3.3)` | aynı (çarpışma/ölçü aynı) |
| 1792 | `cv.global_position = Vector3(CLIMB_X - 1.6, Blachernae.WALK_Y + 1.6, 1.4)` | aynı (çarpışma/ölçü aynı) |
| 1797 | `player.global_position = Vector3(11.6, Blachernae.WALK_Y + 0.05, 3.6)` | aynı (çarpışma/ölçü aynı) |
| 1807 | `_chase_step(c, Vector3(maxf(player.global_position.x + 0.8, CLIMB_X + 1.3) + float(c[1]), Blachernae.WALK_Y, cz), dt, none, true)` | aynı (çarpışma/ölçü aynı) |
| 1808 | `cv.global_position = Vector3(CLIMB_X - 0.4, Blachernae.WALK_Y + 1.6, 3.9)` | aynı (çarpışma/ölçü aynı) |
| 1809 | `cv.look_at(Vector3(CLIMB_X + 4.0, Blachernae.WALK_Y + 1.1, 2.4), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 1811 | `_azap_slide(az, Vector3(CLIMB_X - 3.0, 0.0, SAFE_Z + 7.0))` | aynı (çarpışma/ölçü aynı) |
| 1813 | `cv.global_position = Vector3(CLIMB_X - 6.0, 3.0, 14.0)` | aynı (çarpışma/ölçü aynı) |
| 1814 | `cv.look_at(Vector3(CLIMB_X, 5.0, 6.5), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 1820 | `jumper.global_position = Vector3(8.45, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.65)` | aynı (çarpışma/ölçü aynı) |
| 1828 | `lead.global_position = Vector3(CLIMB_X + 0.65, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 1.0)` | aynı (çarpışma/ölçü aynı) |
| 1835 | `cv.global_position = Vector3(CLIMB_X + 6.0, 2.2, 15.0)` | aynı (çarpışma/ölçü aynı) |
| 1836 | `cv.look_at(Vector3(CLIMB_X, 9.0, 5.5), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 1841 | `cv.global_position = Vector3(CLIMB_X - 9.0, 3.5, 13.0)` | aynı (çarpışma/ölçü aynı) |
| 1842 | `cv.look_at(Vector3(CLIMB_X, 5.0, 11.0), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 1851 | `cv.global_position = Vector3(CLIMB_X + 6.0, 2.0, 24.0)` | aynı (çarpışma/ölçü aynı) |
| 1852 | `cv.look_at(Vector3(CLIMB_X, 3.0, 8.0), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 1856 | `player.global_position = Vector3(CLIMB_X - 1.6, Blachernae.slope_y(Blachernae.WALL_Z1 + 2.4) + 0.05, Blachernae.WALL_Z1 + 2.4)` | aynı (oyuncu: çarpışma zemini y 0) |
| 1859 | `cv.global_position = Vector3(CLIMB_X - 1.0, 2.2, Blachernae.WALL_Z1 + 1.2)` | aynı (çarpışma/ölçü aynı) |
| 1860 | `cv.look_at(Vector3(CLIMB_X - 1.0, 0.8, 30.0), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 1864 | `cv.global_position = Vector3(CLIMB_X + 2.0, 2.0, 22.0)` | aynı (çarpışma/ölçü aynı) |
| 1865 | `cv.look_at(Vector3(CLIMB_X, 4.0, 4.0), Vector3.UP)` | aynı (çarpışma/ölçü aynı) |
| 1871 | `player.global_position = BUSH + Vector3(0, 0, -1.5)` | aynı (çarpışma/ölçü aynı) |
| 1872 | `player.global_position.y = Blachernae.slope_y(player.global_position.z) + 0.05` | aynı (oyuncu: çarpışma zemini y 0) |

### 2.1 Bağ özetleri
| bağ | eski | yeni |
|---|---|---|
| 30 merdivenler `LADDERS` | x −12, −4, 6, 14; ayak z = WALL_Z1 + 12,6·sin16° + 0,12 = 8,19, y 0 | aynı x/z; ayak y = zemin_y (±1,6 cm); o x'lerde diş kurulmaz (`walls.dissiz`, görünüş) |
| 30 koşucular (GunRange) | yol (x+6; 0; 46) → (x+2; 0; 26) → (x; 0; 8,6) | aynı yol; y = `"ground": Blachernae.zemin_y` |
| 30 taşıma | CARRY_FROM 34 m, CARRY_T 5,5 sn, RAISE_T 1,3 sn, CLIMB_TIME 11 sn, TILT 16° | aynı (taşıyan y = zemin_y) |
| 30 oyuncu | (1; 12,05; 2,2); itme noktası (x; 12,05; 3,6) | aynı |
| 30 İmparator / rampa | rampa (−14; 0; −6) → (−6; 12; −0,2), İmparator sur yolunda z 1,6 | aynı (rampa çarpışması aynı; görünüş basamaklı taş merdiven) |
| 30o merdiven | CLIMB_X 10, TILT 16°, ayak z 8,19 | aynı; korkuluk mazgal aralığında (9,95…10,75) açık (görünüş) |
| 30o taşıma | START (10; 0; 40) → PLANT (10; 0; 8) | aynı; taşıyanlar/ok yeri y = zemin_y |
| 30o tüfekçi kulesi | TOWER_X 20, kule merdiveni x 14,5 → kule batı yüzü x 16, tepe y 17 | aynı (yeni kule planı pahlı kare: batı yüzü z 2,2…9,75 düz; merdiven z 3,3'te yüze yaslı) |
| 30o çalı, SAFE_Z | BUSH (12,8; 0; 12), (21; 0; 12); SAFE_Z 34 | aynı x/z; y = zemin_y |
| `night_assault` | merdivenler x −54…56 (kule ±6,2 ve bölüm ±7 dışı), siperler z 24,6, ordu z 30,6+ | aynı rng dizisi ve yerler; siper kutusu → pavez, kırık merdiven kutusu → direk + basamak, sancak levhası → kumaş (görünüş) |
