class_name IstHipoAug
extends RefCounted
## Augustaion + Iustinianus Sütunu, Milion, Aya İrini, Aya Sergios-Bakhos (Küçük Ayasofya). Bkz. hipodrom.gd.

const K := preload("res://scripts/world/ist/hipodrom_kit.gd")

static func catalog() -> Array:
	return [
		{"id": "augustaion", "ad": "Augustaion ve Iustinianus Sütunu", "dogu_m": -60.0, "kuzey_m": -95.0,
		 "gercek_olcu": Vector3(60.0, 35.0, 90.0), "yon_derece": 0.0, "durum": "harap", "tur": "anit",
		 "bakis": Vector3(0, 35.0 * 0.5 + 9.0, 0), "bakis_r": 40.0, "gorev": true},
		{"id": "milion", "ad": "Milion (kalıntı)", "dogu_m": -110.0, "kuzey_m": -100.0,
		 "gercek_olcu": Vector3(14.0, 11.0, 14.0), "yon_derece": 0.0, "durum": "harap", "tur": "anit",
		 "bakis": Vector3(0, 18.0, 0), "bakis_r": 25.0, "gorev": true},
		{"id": "aya_irini", "ad": "Aya İrini (Hagia Eirene)", "dogu_m": 110.0, "kuzey_m": 70.0,
		 "gercek_olcu": Vector3(32.0, 28.0, 63.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
		 "bakis": Vector3(0, 28.0 * 0.6 + 8.0, 0), "bakis_r": 45.0, "gorev": true},
		{"id": "sergios", "ad": "Aya Sergios ve Bakkhos (Küçük Ayasofya)", "dogu_m": -520.0, "kuzey_m": -560.0,
		 "gercek_olcu": Vector3(37.0, 25.0, 40.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
		 "bakis": Vector3(0, 25.0 * 0.6 + 8.0, 0), "bakis_r": 40.0, "gorev": true},
	]


# ---------------------------------------------------------------------------------------------------------------
# Ortak: haç-planlı / bazilika kilise iskeleti
# ---------------------------------------------------------------------------------------------------------------
## Dikdörtgen gövdeli, orta kubbeli kilise: tuğla-taş şeritli duvar (katı, kapı 2,2 m), beşik çatılı kollar, apsis,
## kasnaklı kurşun kubbe, pencereler, narthex. Merkez gövdenin tabanı; ana eksen z (doğu = −z … apsis).
static func church(host: Node3D, w: float, d: float, h: float, dome_r: float, lod: int, ruin := 0.0, seed := 7) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var wall_t := 1.2
	var wall := K.BRICK.lerp(K.STONE, 0.35)
	var info := {"top": h, "dome_top": h}
	if lod >= 2:
		K.ground_box(host, w, h, d, 0, 0, wall)
		K.dome(host, dome_r, dome_r * 0.7, Vector3(0, h, 0), K.LEAD, 8)
		info["dome_top"] = h + dome_r * 0.7
		return info
	# duvar kutusu: dört duvar (kapı için batı duvarında 2,4 m boşluk), zemin döşemesi içeride
	var ez := -d * 0.5
	var wz := d * 0.5
	K.ground_box(host, w, 0.15, d, 0, 0, K.LIGHT.darkened(0.1), "marble")
	for sx: float in [-1.0, 1.0]:
		K.ground_box(host, wall_t, h, d, sx * (w * 0.5 - wall_t * 0.5), 0, wall, "brick")
	K.ground_box(host, w - wall_t * 2.0 + 0.02, h, wall_t, 0, ez + wall_t * 0.5, wall, "brick")
	# batı duvarı: ortada kapı (2,4 genişlik, 2,6 yükseklik) + lento
	var side_w := (w - wall_t * 2.0 - 2.4) * 0.5
	for sx2: float in [-1.0, 1.0]:
		K.ground_box(host, side_w, h, wall_t, sx2 * (1.2 + side_w * 0.5), wz - wall_t * 0.5, wall, "brick")
	K.ground_box(host, 2.4, h - 2.6, wall_t, 0, wz - wall_t * 0.5, wall, "brick", 2.6)
	# içeriye geçiş: kapı eşiği
	K.vb(host, Vector3(2.4, 0.1, 0.8), Vector3(0, 0.05, wz + 0.2), K.STONE_D)
	# şeritli silme (tuğla-taş kuşakları)
	if lod == 0:
		for sx3: float in [-1.0, 1.0]:
			for yy in [0.3, 0.6]:
				K.vb(host, Vector3(0.1, 0.22, d + 0.04), Vector3(sx3 * (w * 0.5 + 0.03), h * yy, 0), K.LIGHT)
		K.vb(host, Vector3(w + 0.1, 0.22, 0.1), Vector3(0, h * 0.3, wz + 0.04), K.LIGHT)
		K.vb(host, Vector3(w + 0.1, 0.22, 0.1), Vector3(0, h * 0.6, wz + 0.04), K.LIGHT)
		for sx4: float in [-1.0, 1.0]:
			K.windows(host, Vector3(sx4 * (w * 0.5 + 0.03), 0.0, 0), Vector3(sx4, 0, 0), d - 6.0, h * 0.4, maxi(3, int(d / 7.0)), 0.9, 1.8)
		K.windows(host, Vector3(0, 0, wz + 0.03), Vector3(0, 0, 1), w - 6.0, h * 0.55, 3, 0.8, 1.6)
		# kapı üstü kemer boşluğu
		K.vb(host, Vector3(2.4, 2.6, 0.06), Vector3(0, 1.3, wz + 0.04), K.DARK)
	# çatı: yan kollar ve ortada kubbe; kollar beşik çatı
	var eave := h
	var rise := minf(w * 0.18, 3.0)
	K.gable_roof(host, 0, 0, w, d, eave, rise, K.TILE, wall)
	# kubbe: kasnak + kurşun, çatının üstünde (çatı levhalarının üstüne taşar)
	var base_y := eave + rise * 1.0 + 0.2
	var drum_h := dome_r * 0.5
	K.lead_dome(host, dome_r, dome_r * 0.55, Vector3(0, base_y, -d * 0.04), 12, drum_h, wall, true)
	info["dome_top"] = base_y + drum_h + 0.25 + dome_r * 0.55
	info["roof_top"] = eave + rise
	# apsis: doğu uçta yarım silindir çıkıntı (üstü yarım kubbe/yarım koni)
	K.sc(host, w * 0.28, h * 0.8, Vector3(0, h * 0.4, ez - w * 0.28 + 0.2), wall.darkened(0.06), 10, w * 0.27, Vector3.ZERO, 1.0)
	K.dome(host, w * 0.28, w * 0.16, Vector3(0, h * 0.8, ez - w * 0.28 + 0.2), K.LEAD, 10)
	# narthex alçak çatılı sundurma
	if lod == 0:
		K.ground_box(host, w * 0.9, h * 0.45, 4.0, 0, wz + 2.0, wall.darkened(0.04), "brick")
		K.vb(host, Vector3(w * 0.9 + 0.3, 0.2, 4.4), Vector3(0, h * 0.45 + 0.1, wz + 2.0), K.TILE)
		K.vb(host, Vector3(2.4, 2.4, 0.07), Vector3(0, 1.2, wz + 4.03), K.DARK)
	if ruin > 0.0:
		pass
	return info


# ---------------------------------------------------------------------------------------------------------------
# Augustaion ve Iustinianus Sütunu
# ---------------------------------------------------------------------------------------------------------------
static func _col_params(k: float) -> Dictionary:
	var r := maxf(2.4 * k, 1.2)
	var h := maxf(30.0 * k, 11.0)
	return {"r": r, "h": h, "base": 2.0}


static func build_augustaion(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 527
	var p := _col_params(k)
	var r: float = p["r"]
	var h: float = p["h"]
	var W := maxf(60.0 * k, 28.0)
	var D := maxf(90.0 * k, 36.0)
	if lod >= 2:
		K.ground_box(host, W, 0.2, D, 0, 0, K.STONE_D)
		K.sc(host, r, h + 4.0, Vector3(0, (h + 4.0) * 0.5, 0), K.BRICK, 8, r * 0.9, Vector3.ZERO, 1.0)
		return
	# meydan döşemesi: büyük taş levhalar (çimenli aralıklar), 0,18 m yüksek
	K.ground_box(host, W, 0.18, D, 0, 0, K.STONE_D, "flagstone")
	if lod == 0:
		K.scatter(host, Rect2(-W * 0.5, -D * 0.5, W, D), int(120 * k + 40), rng, 0.18, "ot")
		K.scatter(host, Rect2(-W * 0.5, -D * 0.5, W, D), int(40 * k + 10), rng, 0.18, "moloz")
	# --- sütun: üç basamaklı kaide ---
	var by := 0.18
	for i in 3:
		var s := 9.0 - i * 2.2
		K.ground_box(host, s, 0.4, s, 0, 0, K.MARBLE.darkened(0.04 * i), "marble", by + i * 0.4)
	by += 1.2
	var pedestal := 3.6
	K.ground_box(host, 5.2, pedestal, 5.2, 0, 0, K.MARBLE.darkened(0.06), "marble", by)
	if lod == 0:
		for f in 4:
			var dir := Vector3(sin(deg_to_rad(f * 90.0)), 0, cos(deg_to_rad(f * 90.0)))
			K.vb(host, Vector3(3.6, 1.8, 0.1), Vector3(dir.x * 2.65, by + pedestal * 0.5, dir.z * 2.65), K.LIGHT, Vector3(0, f * 90.0, 0))
			K.vb(host, Vector3(3.9, 0.15, 0.14), Vector3(dir.x * 2.66, by + pedestal - 0.2, dir.z * 2.66), K.MARBLE, Vector3(0, f * 90.0, 0))
	by += pedestal
	# gövde: tuğla çekirdek (bronz kaplama 1204'te sökülmüş, çiviler ve yer yer lekeler kalmış), tepede mermer başlık
	K.sc(host, r, h, Vector3(0, by + h * 0.5, 0), K.BRICK, 14, r * 0.92, Vector3.ZERO, 1.0)
	if lod == 0:
		# tuğla sıraları (yatay koyu halkalar)
		var rows := int(h / 0.9)
		for i in rows:
			var yy := by + 0.5 + i * (h - 0.8) / rows
			var rr := lerpf(r, r * 0.92, float(i) / rows)
			K.vb(host, Vector3(rr * 2.0 + 0.06, 0.09, rr * 2.0 + 0.06), Vector3(0, yy, 0), K.BRICK2.darkened(0.2), Vector3(0, i * 21.0, 0))
		# bronz kaplama kalıntıları: yer yer yamalar
		for i in 18:
			var a := rng.randf() * TAU
			var yy2 := by + rng.randf_range(1.0, h - 1.0)
			var rr2 := r * lerpf(1.0, 0.92, (yy2 - by) / h) + 0.04
			K.vb(host, Vector3(rng.randf_range(0.6, 1.4), rng.randf_range(0.5, 1.4), 0.07), Vector3(cos(a) * rr2, yy2, sin(a) * rr2), K.BRONZE.darkened(0.15), Vector3(0, -rad_to_deg(a) + 90.0, 0))
		# başlık: dörtgen mermer başlık + kare kaide
	var cap_y := by + h
	K.sc(host, r * 1.2, 0.8, Vector3(0, cap_y + 0.4, 0), K.MARBLE.darkened(0.08), 12, r * 1.05, Vector3.ZERO, 1.0)
	K.ground_box(host, r * 2.8, 0.9, r * 2.8, 0, 0, K.MARBLE, "marble", cap_y + 0.8)
	var top_y := cap_y + 1.7
	# tepede at ve binici heykel (bronz, küre 1317'de düşmüş: elde küre yok)
	K.sb(host, Vector3(0.9, 0.9, 2.3), Vector3(0, top_y + 0.5 + 0.45, 0), K.BRONZE, "")
	K.vb(host, Vector3(0.42, 0.6, 0.5), Vector3(0, top_y + 1.1, 1.3), K.BRONZE)
	for lx: float in [-0.3, 0.3]:
		for lz: float in [-0.8, 0.8]:
			K.vb(host, Vector3(0.16, 0.5, 0.16), Vector3(lx, top_y + 0.25, lz), K.BRONZE.darkened(0.1))
	K.vb(host, Vector3(0.45, 0.8, 0.35), Vector3(0, top_y + 1.7, -0.1), K.BRONZE.lightened(0.05))
	Props.ball(host, 0.2, Vector3(0, top_y + 2.25, -0.1), K.BRONZE.lightened(0.1), Vector3.ONE, 6)
	K.vb(host, Vector3(0.1, 0.1, 0.9), Vector3(0.45, top_y + 2.0, 0.2), K.BRONZE)          # uzatılmış kol
	K.vb(host, Vector3(0.05, 0.05, 0.04), Vector3(0.45, top_y + 2.0, 0.65), K.BRONZE.darkened(0.2))
	# --- meydan çevresi: stoa sütun kütükleri, kuyu, yıkık duvar ---
	for i in 8:
		var sz := -D * 0.5 + 6.0 + i * (D - 12.0) / 7.0
		var sh := rng.randf_range(0.5, 3.0)
		K.sc(host, 0.42, sh, Vector3(-W * 0.5 + 3.0, 0.18 + sh * 0.5, sz), K.MARBLE.darkened(0.1), 10, 0.4, Vector3.ZERO, 1.0)
		if lod == 0:
			K.ground_box(host, 1.1, 0.3, 1.1, -W * 0.5 + 3.0, sz, K.STONE_D, "ashlar", 0.18)
	K.ruin_wall(host, Vector2(-W * 0.5 + 0.5, -D * 0.5 + 2.0), Vector2(-W * 0.5 + 0.5, D * 0.5 - 2.0), 3.0, 1.0, K.BRICK2, rng, "brick", 0.18, 1.0)
	K.ruin_wall(host, Vector2(W * 0.5 - 0.5, -D * 0.5 + 8.0), Vector2(W * 0.5 - 0.5, D * 0.5 - 12.0), 2.4, 1.0, K.BRICK2, rng, "brick", 0.18, 0.8)
	K.sc(host, 0.9, 0.9, Vector3(W * 0.5 - 6.0, 0.18 + 0.45, D * 0.5 - 8.0), K.STONE, 10, 0.9)
	K.sc(host, 0.6, 0.12, Vector3(W * 0.5 - 6.0, 0.18 + 0.96, D * 0.5 - 8.0), Color("4a6a7a"), 10)
	# taş arabası ve sandık yığını (sokaktan alçak taşlara)
	for i in 3:
		K.ground_box(host, 1.0, 0.4 * (i + 1), 1.2, W * 0.25 + i * 1.1, D * 0.25, K.WOOD, "wood", 0.18)


static func perches_augustaion(k: float = 0.5) -> Array:
	var p := _col_params(k)
	var h: float = p["h"]
	var by := 0.18 + 1.2 + 3.6
	return [Vector3(0, by + h + 1.7 + 0.9, 0), Vector3(0, by + h + 1.7 + 2.7, -0.1)]


static func climbs_augustaion(k: float = 0.5) -> Array:
	var W := maxf(60.0 * k, 28.0)
	var D := maxf(90.0 * k, 36.0)
	# sandık yığını → kaide basamakları (0,18 + 0,4 × 3) → kaide üstü (1,38 + 3,6 yüksek: sandıkla ulaşılmaz; basamak üstü)
	return [[Vector3(W * 0.25 - 1.2, 0.18, D * 0.25), Vector3(W * 0.25 + 2.4, 1.38, D * 0.25), "sandik"],
			[Vector3(2.0, 0.18, 6.0), Vector3(0, 1.38, 3.0), "basamak"]]


# ---------------------------------------------------------------------------------------------------------------
# Milion: dört kemerli tetrapylon kalıntısı
# ---------------------------------------------------------------------------------------------------------------
static func build_milion(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 330
	var span := 3.4                   # kemer geçit genişliği (insan ölçüsü, k'den bağımsız)
	var pier := maxf(3.0 * k + 1.2, 2.2)
	var h := maxf(11.0 * k, 6.0)
	var off := span * 0.5 + pier * 0.5
	if lod >= 2:
		K.ground_box(host, pier * 2 + span, h, pier * 2 + span, 0, 0, K.MARBLE.darkened(0.12))
		return
	K.ground_box(host, off * 2 + pier + 2.0, 0.3, off * 2 + pier + 2.0, 0, 0, K.STONE_D, "flagstone")
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			K.ground_box(host, pier, h, pier, sx * off, sz * off, K.MARBLE.darkened(0.1), "ashlar", 0.3)
			if lod == 0:
				K.vb(host, Vector3(pier + 0.25, 0.3, pier + 0.25), Vector3(sx * off, 0.45, sz * off), K.LIGHT)
				K.vb(host, Vector3(pier + 0.25, 0.3, pier + 0.25), Vector3(sx * off, 0.3 + h - 0.15, sz * off), K.LIGHT)
	# üst: dört kemerin üstündeki lento kirişleri (kaba kemer yerine düz katı) ve yıkık kubbe tabanı
	var lintel_y := 0.3 + 3.8
	for i in 2:
		var s: float = 1.0 if i == 0 else -1.0
		K.ground_box(host, off * 2 + pier, h - 3.8, span * 0.0 + pier * 0.55, 0, s * off, K.MARBLE.darkened(0.08), "ashlar", lintel_y)
		K.ground_box(host, pier * 0.55, h - 3.8, off * 2 + pier, s * off, 0, K.MARBLE.darkened(0.08), "ashlar", lintel_y)
	# kemer içi koyu boşluk ve kemer kaşı
	if lod == 0:
		for s2: float in [-1.0, 1.0]:
			K.vb(host, Vector3(span, 0.2, 0.2), Vector3(0, lintel_y - 0.1, s2 * (off + pier * 0.3)), K.LIGHT)
			K.vb(host, Vector3(0.2, 0.2, span), Vector3(s2 * (off + pier * 0.3), lintel_y - 0.1, 0), K.LIGHT)
	# tepe: düz taş döşeme, üstünde yıkık kubbe tabanı ve ot
	K.ground_box(host, off * 2 + pier + 0.4, 0.5, off * 2 + pier + 0.4, 0, 0, K.STONE, "ashlar", 0.3 + h)
	K.sc(host, off * 0.9, 1.4, Vector3(0, 0.3 + h + 0.5 + 0.7, 0), K.BRICK2, 10, off * 0.8)
	if lod == 0:
		K.scatter(host, Rect2(-off, -off, off * 2, off * 2), 40, rng, 0.3 + h + 0.5, "ot")
		# kaide taşı: ölçü sütunu (milion taşı) ortada
		K.sc(host, 0.35, 1.6, Vector3(0, 0.3 + 0.8, 0), K.MARBLE, 8, 0.28)
	# moloz yığını → tepeye basamak (yıkık duvar basamakları 0,4 m)
	var steps := int((h + 0.8) / 0.4) + 1
	for s3 in steps:
		K.ground_box(host, 0.9, (s3 + 1) * 0.4, 2.2, off + pier * 0.5 + 0.5 + (steps - 1 - s3) * 0.9, off + pier * 1.2, K.STONE_D, "ashlar")
	K.ground_box(host, 2.5, steps * 0.4, 2.2, off + pier * 0.5 - 0.7, off + pier * 1.2, K.STONE_D, "ashlar")


static func perches_milion(k: float = 0.5) -> Array:
	var h := maxf(11.0 * k, 6.0)
	return [Vector3(0, 0.3 + h + 0.5 + 1.4 + 0.1, 0)]


static func climbs_milion(k: float = 0.5) -> Array:
	var pier := maxf(3.0 * k + 1.2, 2.2)
	var h := maxf(11.0 * k, 6.0)
	var off := 1.7 + pier * 0.5
	var steps := int((h + 0.8) / 0.4) + 1
	return [[Vector3(off + pier * 0.5 + 0.5 + steps * 0.9 + 0.8, 0, off + pier * 1.2), Vector3(off + pier * 0.5 - 0.2, steps * 0.4, off + pier * 1.2), "basamak"]]


# ---------------------------------------------------------------------------------------------------------------
# Aya İrini
# ---------------------------------------------------------------------------------------------------------------
static func build_aya_irini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var w := maxf(32.0 * k, 14.0)
	var d := maxf(63.0 * k, 26.0)
	var h := maxf(15.0 * k, 8.0)
	var inf := church(host, w, d, h, w * 0.32, lod, 0.0, 11)
	if lod >= 2:
		return
	# ikinci (batı) küçük kubbe + atrium duvarı (batıda açık avlu, çevresi alçak duvar, ortasında sütun kütükleri)
	var rng := RandomNumberGenerator.new()
	rng.seed = 532
	K.lead_dome(host, w * 0.2, w * 0.1, Vector3(0, float(inf["roof_top"]) + 0.2, d * 0.28), 8, w * 0.1, K.BRICK, true)
	if lod == 0:
		var az := d * 0.5 + 6.0
		K.ground_box(host, w, 0.15, 12.0, 0, az, K.STONE_D, "flagstone")
		K.ruin_wall(host, Vector2(-w * 0.5, d * 0.5 + 12.0), Vector2(w * 0.5, d * 0.5 + 12.0), 2.6, 1.0, K.BRICK2, rng, "brick")
		for i in 4:
			K.sc(host, 0.36, rng.randf_range(1.0, 3.2), Vector3(-w * 0.35 + i * w * 0.23, 0.15 + 1.0, az), K.MARBLE.darkened(0.1), 8, 0.34)
		# kemerli dış kapı eşiği ve sandık yığını (çatıya erişim)
		for i in 3:
			K.ground_box(host, 1.0, 0.4 * (i + 1), 1.2, -w * 0.5 - 1.6 - (2 - i) * 1.0, 0, K.WOOD, "wood")
		# yan tuğla payandalar
		for sz in 4:
			for sx: float in [-1.0, 1.0]:
				K.ground_box(host, 1.0, h * 0.8, 0.9, sx * (w * 0.5 + 0.5), -d * 0.35 + sz * d * 0.23, K.BRICK2, "brick")


static func perches_aya_irini(k: float = 0.5) -> Array:
	var w := maxf(32.0 * k, 14.0)
	var h := maxf(15.0 * k, 8.0)
	var rise := minf(w * 0.18, 3.0)
	var base_y := h + rise + 0.2
	var r := w * 0.32
	return [Vector3(0, base_y + r * 0.5 + 0.25 + r * 0.55 + 0.1, -maxf(63.0 * k, 26.0) * 0.04)]


static func climbs_aya_irini(k: float = 0.5) -> Array:
	var w := maxf(32.0 * k, 14.0)
	var h := maxf(15.0 * k, 8.0)
	# sandık yığını (1,2) → payanda tepesi/yan çatı saçağı: çatı levhası saçakta h civarında; payanda h*0.8
	return [[Vector3(-w * 0.5 - 4.6, 0, 0), Vector3(-w * 0.5 - 0.6, 1.2, 0), "sandik"]]


# ---------------------------------------------------------------------------------------------------------------
# Aya Sergios ve Bakkhos: sekizgen planlı, kubbeli, tuğla
# ---------------------------------------------------------------------------------------------------------------
static func build_sergios(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var R := maxf(17.0 * k, 8.5)          # yarıçap (merkezden köşeye değil, kenara)
	var h := maxf(14.0 * k, 7.5)
	var rng := RandomNumberGenerator.new()
	rng.seed = 527
	var wall := K.BRICK.lerp(K.STONE, 0.3)
	if lod >= 2:
		K.sc(host, R, h, Vector3(0, h * 0.5, 0), wall, 8, R * 0.98, Vector3.ZERO, 1.0)
		K.dome(host, R * 0.85, R * 0.55, Vector3(0, h, 0), K.LEAD, 8)
		return
	# sekizgen gövde: 8 duvar parçası (kapı: güney yüzde 2,4 m)
	var t := 1.3
	K.ground_box(host, R * 2.0, 0.15, R * 2.0, 0, 0, K.LIGHT.darkened(0.12), "marble")
	for i in 8:
		var a := TAU * i / 8.0
		var rr := R * 0.95
		var cx := cos(a) * rr
		var cz := sin(a) * rr
		var chord := 2.0 * R * tan(PI / 8.0) * 0.96 + 0.3
		var rot := Vector3(0, -rad_to_deg(a) + 90.0, 0)
		if i == 2:       # güney: kapı
			var sidew := (chord - 2.4) * 0.5
			for sgn: float in [-1.0, 1.0]:
				var loc := Vector3(sgn * (1.2 + sidew * 0.5), h * 0.5, 0).rotated(Vector3.UP, deg_to_rad(rot.y))
				K.sb(host, Vector3(sidew, h, t), Vector3(cx + loc.x, loc.y, cz + loc.z), wall, "brick", rot)
			var lo := Vector3(0, 2.6 + (h - 2.6) * 0.5, 0).rotated(Vector3.UP, deg_to_rad(rot.y))
			K.sb(host, Vector3(2.4, h - 2.6, t), Vector3(cx + lo.x, lo.y, cz + lo.z), wall, "brick", rot)
			K.vb(host, Vector3(2.4, 2.6, 0.06), Vector3(cx + cos(a) * (t * 0.5 + 0.03), 1.3, cz + sin(a) * (t * 0.5 + 0.03)), K.DARK, rot)
		else:
			K.sb(host, Vector3(chord, h, t), Vector3(cx, h * 0.5, cz), wall, "brick", rot)
		if lod == 0:
			var out := Vector3(cos(a), 0, sin(a))
			K.windows(host, Vector3(cx, 0, cz) + out * (t * 0.5), out, chord * 0.7, h * 0.55, 2, 0.8, 1.8)
			for yy in [0.35, 0.7]:
				K.vb(host, Vector3(chord + 0.2, 0.2, 0.12), Vector3(cx, h * yy, cz) + out * (t * 0.5 + 0.02), K.LIGHT, rot)
	# kubbe: çatı katı disk + kasnak + 16 dilimli kubbe (kaburga + pencere) + stilize çatı
	K.sc(host, R * 0.98, 0.6, Vector3(0, h + 0.3, 0), K.STONE_D, 8, R * 0.98, Vector3.ZERO, 1.0)
	K.lead_dome(host, R * 0.88, R * 0.62, Vector3(0, h + 0.6, 0), 16, R * 0.35, wall, true)
	# narthex + güney sundurma kapısının önü
	K.ground_box(host, 6.0, h * 0.45, 3.0, 0, R + 2.0, wall.darkened(0.05), "brick")
	K.vb(host, Vector3(6.4, 0.2, 3.4), Vector3(0, h * 0.45 + 0.1, R + 2.0), K.TILE)
	var ns := int(h * 0.45 / 0.4) + 1
	for si in ns:
		K.ground_box(host, 0.6, minf((si + 1) * 0.4, h * 0.45), 2.4, 3.3 + (ns - 1 - si) * 0.6, R + 2.0, K.STONE_D, "ashlar")
	K.vb(host, Vector3(2.4, 2.4, 0.07), Vector3(0, 1.2, R + 3.53), K.DARK)
	# kuzey çıkıntı (apsis)
	K.sc(host, 4.0, h * 0.7, Vector3(0, h * 0.35, -R - 1.5), wall.darkened(0.05), 8, 3.9, Vector3.ZERO, 1.0)
	K.dome(host, 4.0, 2.2, Vector3(0, h * 0.7, -R - 1.5), K.LEAD, 8)
	if lod == 0:
		for i in 3:
			K.ground_box(host, 1.0, 0.4 * (i + 1), 1.2, R + 5.0 + (2 - i) * 1.0, 3.2, K.WOOD, "wood")
		K.scatter(host, Rect2(-R * 1.4, -R * 1.4, R * 2.8, R * 2.8), 40, rng, 0.0, "ot")


static func perches_sergios(k: float = 0.5) -> Array:
	var R := maxf(17.0 * k, 8.5)
	var h := maxf(14.0 * k, 7.5)
	return [Vector3(0, h + 0.6 + R * 0.35 + 0.25 + R * 0.62 + 0.9, 0)]


static func climbs_sergios(k: float = 0.5) -> Array:
	var R := maxf(17.0 * k, 8.5)
	var h := maxf(14.0 * k, 7.5)
	# sandık yığını → narthex çatısı (h*0.45 + 0,2); oradan duvar saçağına zıpla/tırman
	return [[Vector3(R + 7.2, 0, 3.2), Vector3(R + 5.0, 1.2, 3.2), "sandik"],
			[Vector3(3.3 + (int(h * 0.45 / 0.4)) * 0.6 + 1.4, 0, R + 2.0), Vector3(2.0, h * 0.45, R + 2.0), "basamak"]]
