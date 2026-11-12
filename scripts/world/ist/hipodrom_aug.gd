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
static func _irini(k: float) -> Dictionary:
	var w := maxf(32.0 * k, 14.0)          # toplam en (orta nef + iki yan nef)
	var d := maxf(63.0 * k, 26.0)          # boy (narteks hariç)
	var hn := maxf(17.0 * k, 9.0)          # orta nef duvarı (pencere sırası)
	var ha := hn * 0.58                    # yan nef saçağı
	var dr := w * 0.27                     # ana kubbe yarıçapı
	var dh := 3.2 + 1.0 * k                # kasnak
	var dz := -d * 0.12                    # ana kubbe ekseni (doğuya yakın)
	return {"w": w, "d": d, "hn": hn, "ha": ha, "dr": dr, "dh": dh, "dz": dz}


## Aya İrini (ÇEVRE-4; kalite notu 22): düz kutu değil, BAZİLİKA: yüksek orta nef + alçak yan nefler (eğik kurşun
## çatılar), orta nefin üstünde yüksek pencereli KASNAKLI ana kubbe, batıda alçak ikinci kubbe, doğuda dışı çokgen apsis
## (yarım kubbeli), yan neflerde tuğla payandalar, batıda narteks ve revaklı atrium (Bizans'ta kalan tek atrium).
## Taş-tuğla şeritli duvar (tuğla ağırlıklı), kurşun çatı ve kubbeler (eser paleti). Ana eksen z (doğu = −z).
static func build_aya_irini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var q := _irini(k)
	var w: float = q["w"]
	var d: float = q["d"]
	var hn: float = q["hn"]
	var ha: float = q["ha"]
	var dr: float = q["dr"]
	var dh: float = q["dh"]
	var dz: float = q["dz"]
	var nw := w * 0.52                     # orta nef eni
	var wall := K.BRICK.lerp(K.STONE, 0.2)
	var lead := K.LEAD
	var rng := RandomNumberGenerator.new()
	rng.seed = 532
	if lod >= 2:
		K.ground_box(host, w, ha, d, 0, 0, wall)
		K.ground_box(host, nw, hn, d * 0.9, 0, 0, wall)
		K.sc(host, dr * 1.02, dh, Vector3(0, hn + dh * 0.5, dz), wall, 10, dr, Vector3.ZERO, 1.0)
		K.dome(host, dr, dr * 0.6, Vector3(0, hn + dh, dz), lead, 10)
		K.sc(host, w * 0.24, hn * 0.8, Vector3(0, hn * 0.4, -d * 0.5 - w * 0.12), wall, 7, w * 0.24, Vector3.ZERO, 1.0)
		return
	# --- yan nefler: katı alçak gövde (kapı batıda), eğik kurşun çatı ---
	var t := 1.2
	K.ground_box(host, w, 0.15, d, 0, 0, K.LIGHT.darkened(0.1), "marble")
	for sx: float in [-1.0, 1.0]:
		K.ground_box(host, t, ha, d, sx * (w * 0.5 - t * 0.5), 0, wall, "brick")
		# eğik çatı: yan duvardan orta nef duvarına
		var run := (w - nw) * 0.5
		var rise := 1.8
		var ang := atan2(rise, run)
		var rl := sqrt(run * run + rise * rise) + 0.5
		var rb := K.sb(host, Vector3(rl, 0.25, d + 0.6), Vector3(sx * (nw * 0.5 + run * 0.5), ha + rise * 0.5 + 0.12, 0), lead, "", Vector3(0, 0, sx * -rad_to_deg(ang)))
		rb.name = "Roof"
	# doğu ve batı duvarları (batıda ortada 2,4 m kapı)
	K.ground_box(host, w - t * 2.0, ha, t, 0, -d * 0.5 + t * 0.5, wall, "brick")
	var sw := (w - t * 2.0 - 2.4) * 0.5
	for sx2: float in [-1.0, 1.0]:
		K.ground_box(host, sw, ha, t, sx2 * (1.2 + sw * 0.5), d * 0.5 - t * 0.5, wall, "brick")
	K.ground_box(host, 2.4, ha - 2.8, t, 0, d * 0.5 - t * 0.5, wall, "brick", 2.8)
	# --- orta nef (yüksek): yan nef çatısının üstünde pencere sırası ---
	for sx: float in [-1.0, 1.0]:
		K.ground_box(host, 1.0, hn - ha, d * 0.92, sx * (nw * 0.5 - 0.5), 0, wall, "brick", ha)
	for ez: float in [-1.0, 1.0]:
		K.ground_box(host, nw, hn - ha, 1.0, 0, ez * (d * 0.46 - 0.5), wall, "brick", ha)
	# orta nef çatısı: kubbelerin dışında düz kurşun teras (kubbe kaideleri arası)
	K.ground_box(host, nw + 0.4, 0.4, d * 0.92 + 0.4, 0, 0, lead, "", hn)
	# --- ana kubbe: kare kaide + yüksek pencereli kasnak + kurşun kubbe ---
	K.ground_box(host, dr * 2.3, 1.4, dr * 2.3, 0, dz, wall, "brick", hn + 0.4)
	var db := hn + 1.8
	var drum := K.sc(host, dr * 1.04, dh, Vector3(0, db + dh * 0.5, dz), wall, 16, dr * 1.02, Vector3.ZERO, 1.0)
	if lod == 0:
		Props.set_pattern(drum, wall, "brick")
		for i in 16:
			var a := TAU * (i + 0.5) / 16.0
			var o := Vector3(cos(a), 0, sin(a)) * (dr * 1.03 + 0.02)
			K.vb(host, Vector3(0.7, dh * 0.6, 0.7), Vector3(o.x, db + dh * 0.5, dz + o.z), K.DARK, Vector3(0, -rad_to_deg(a), 0))
		Props.cyl(host, dr * 1.08, 0.3, Vector3(0, db + dh, dz), K.STONE, Vector3.ZERO, 16)
	K.dome(host, dr, dr * 0.62, Vector3(0, db + dh + 0.15, dz), lead, 16)
	if lod == 0:
		for i in 12:
			var a2 := TAU * i / 12.0
			K.vb(host, Vector3(0.12, dr * 0.5, 0.12), Vector3(cos(a2) * dr * 0.72, db + dh + dr * 0.36, dz + sin(a2) * dr * 0.72), lead.darkened(0.15), Vector3(rad_to_deg(sin(a2)) * 0.9, 0, -rad_to_deg(cos(a2)) * 0.9))
		K.vb(host, Vector3(0.12, 1.6, 0.12), Vector3(0, db + dh + dr * 0.62 + 0.9, dz), K.GOLD)
		K.vb(host, Vector3(0.8, 0.12, 0.12), Vector3(0, db + dh + dr * 0.62 + 1.2, dz), K.GOLD)
	# --- batı (ikinci) kubbe: alçak, kasnaksız, elips ---
	var wz := d * 0.26
	K.ground_box(host, nw * 0.9, 0.9, nw * 0.9, 0, wz, wall, "brick", hn + 0.4)
	K.dome(host, nw * 0.42, nw * 0.22, Vector3(0, hn + 1.3, wz), lead, 12)
	# --- apsis: dışı çokgen (yedi yüz), yarım kubbe ---
	var ar := nw * 0.48
	var az := -d * 0.5 - ar * 0.55
	var aps := K.sc(host, ar, hn * 0.82, Vector3(0, hn * 0.41, az), wall, 7, ar, Vector3.ZERO, 1.0)
	if lod == 0:
		Props.set_pattern(aps, wall, "brick")
		for i in 3:
			var a3 := PI * 0.5 + (i - 1) * 0.6
			var o3 := Vector3(cos(a3), 0, -sin(a3)) * (ar + 0.02)
			K.vb(host, Vector3(1.0, 2.6, 0.2), Vector3(o3.x, hn * 0.45, az + o3.z), K.DARK, Vector3(0, rad_to_deg(a3) - 90.0, 0))
	K.dome(host, ar, ar * 0.5, Vector3(0, hn * 0.82, az), lead, 10)
	# --- payandalar (yan neflerde tuğla) ve şeritler ---
	for i in 5:
		var pz := -d * 0.4 + i * d * 0.2
		for sx3: float in [-1.0, 1.0]:
			K.ground_box(host, 1.2, ha * 0.92, 1.4, sx3 * (w * 0.5 + 0.6), pz, K.BRICK2, "brick")
			K.vb(host, Vector3(1.3, 0.3, 1.5), Vector3(sx3 * (w * 0.5 + 0.6), ha * 0.92 + 0.15, pz), lead)
	if lod == 0:
		for sx4: float in [-1.0, 1.0]:
			K.windows(host, Vector3(sx4 * (w * 0.5 + 0.03), 0.0, 0), Vector3(sx4, 0, 0), d - 8.0, ha * 0.45, 5, 1.0, 2.0)
			K.windows(host, Vector3(sx4 * (nw * 0.5 + 0.03), 0.0, 0), Vector3(sx4, 0, 0), d * 0.8, ha + 1.0, 6, 0.9, 1.8)
			for yy: float in [ha * 0.3, ha * 0.75]:
				K.vb(host, Vector3(0.08, 0.3, d + 0.04), Vector3(sx4 * (w * 0.5 + 0.03), yy, 0), K.STONE)
	# --- narteks (batı) ---
	K.ground_box(host, w * 0.96, ha * 0.8, 5.0, 0, d * 0.5 + 2.5, wall.darkened(0.04), "brick")
	K.vb(host, Vector3(w * 0.96 + 0.4, 0.3, 5.4), Vector3(0, ha * 0.8 + 0.15, d * 0.5 + 2.5), lead)
	K.vb(host, Vector3(2.4, 2.6, 0.07), Vector3(0, 1.3, d * 0.5 + 5.03), K.DARK)
	K.ground_box(host, 2.4, 0.1, 5.2, 0, d * 0.5 + 2.5, K.STONE_D, "", 0.0)
	# --- atrium: üç yanı revaklı avlu (batıda) ---
	if lod == 0:
		var a0 := d * 0.5 + 5.0
		var al := 16.0
		K.ground_box(host, w, 0.12, al, 0, a0 + al * 0.5, K.STONE_D, "flagstone")
		for sx5: float in [-1.0, 1.0]:
			K.ground_box(host, 0.8, 4.4, al, sx5 * (w * 0.5 - 0.4), a0 + al * 0.5, K.STONE, "ashlar")
			for i in 5:
				K.sc(host, 0.26, 3.6, Vector3(sx5 * (w * 0.5 - 3.6), 1.9, a0 + 1.6 + i * (al - 3.2) / 4.0), K.MARBLE.darkened(0.05), 8, 0.24)
			K.vb(host, Vector3(4.2, 0.22, al), Vector3(sx5 * (w * 0.5 - 2.2), 4.4, a0 + al * 0.5), K.TILE, Vector3(0, 0, sx5 * 10.0))
		var bw := (w - 3.0) * 0.5
		for sx6: float in [-1.0, 1.0]:
			K.ground_box(host, bw, 4.4, 0.8, sx6 * (1.5 + bw * 0.5), a0 + al - 0.4, K.STONE, "ashlar")
		K.sc(host, 1.3, 0.8, Vector3(0, 0.5, a0 + al * 0.5), K.MARBLE.darkened(0.08), 8, 1.3)
		K.scatter(host, Rect2(-w * 0.4, a0 + 1.0, w * 0.8, al - 2.0), 30, rng, 0.12, "ot")
		# kemerli dış kapı eşiği ve sandık yığını (çatıya erişim)
		for i in 3:
			K.ground_box(host, 1.0, 0.4 * (i + 1), 1.2, -w * 0.5 - 1.7 - (2 - i) * 1.0, 0, K.WOOD, "wood")


static func perches_aya_irini(k: float = 0.5) -> Array:
	var q := _irini(k)
	var dr: float = q["dr"]
	return [Vector3(0, float(q["hn"]) + 1.8 + float(q["dh"]) + 0.15 + dr * 0.62 + 0.1, float(q["dz"]))]


static func climbs_aya_irini(k: float = 0.5) -> Array:
	var q := _irini(k)
	var w: float = q["w"]
	# sandık yığını (1,2) → payanda tepesi (yan nef saçağının altı)
	return [[Vector3(-w * 0.5 - 5.8, 0, 0), Vector3(-w * 0.5 - 1.2, 1.2, 0), "sandik"]]


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
