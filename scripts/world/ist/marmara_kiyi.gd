class_name IstMarmaraKiyi
extends RefCounted
## Kıyı öğeleri (Nisan 1453): Mermer Kule (kara surı ile deniz surunun birleştiği köşe), Ahırkapı çevresi (küçük deniz kapısı),
## balıkçı barınakları, kayıkhane, ağ kurutma sehpaları, kıyı kayaları. Eksenler: +x doğu, -z kuzey, +z güney = deniz.

const SUR := preload("res://scripts/world/ist/marmara_sur.gd")


# ============================================================ MERMER KULE ========================================
static func md(k: float) -> Dictionary:
	var sd := SUR.dims(k)
	var a := maxf(13.0 * k, 7.0)
	var h := maxf(20.0 * k, 10.0)
	var len := 2.1 * float(sd["S"])
	return {"A": a, "H": h, "LEN": len, "SD": sd}


static func build_mermerkule(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var d := md(k)
	var A: float = d["A"]
	var H: float = d["H"]
	var LEN: float = d["LEN"]
	var root := IstMk.root(host, "MermerKule")
	# gövde: alt 60 % mermer kaplama, üstte taş-tuğla; köşe kulesi
	IstMk.S(root, Vector3(A, H * 0.6, A), Vector3.ZERO, IstMk.MARBLE, "marble")
	IstMk.S(root, Vector3(A - 0.3, H * 0.4, A - 0.3), Vector3(0, H * 0.6, 0), IstMk.STONE, "ashlar")
	# deniz yüzü (+z) ve batı yüzü (-x) dışa açık; sur parçaları: doğu (deniz suru) ve kuzey (kara suru)
	var sea := IstMk.root(root, "DenizSuru")
	sea.position = Vector3(A * 0.5 + LEN * 0.5 - 0.5, 0, -0.0)
	SUR.build_run(sea, LEN, k, lod, {"merdiven": true})
	var land := IstMk.root(root, "KaraSuru")
	land.position = Vector3(0, 0, -(A * 0.5 + LEN * 0.5 - 0.5))
	land.rotation.y = deg_to_rad(-90.0)
	SUR.build_run(land, LEN, k, lod, {"merdiven": false})
	if lod >= 2:
		return
	# tepe: korkuluk (batı yüzünde merdiven ağzı), mazgal, ortada gözcü kulesi
	var top := H
	var stm := stair_mk(k)
	var zt: float = stm["z_top"]
	IstMk.S(root, Vector3(A, 1.5, 0.5), Vector3(0, top, A * 0.5 - 0.25), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(A, 1.5, 0.5), Vector3(0, top, -A * 0.5 + 0.25), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(0.5, 1.5, A - 1.0), Vector3(A * 0.5 - 0.25, top, 0), IstMk.STONE, "ashlar")
	var wa := -(A * 0.5 - 0.5)
	var wb := zt - 0.8
	var wc := zt + 2.4
	var wd := A * 0.5 - 0.5
	if wb - wa > 0.3:
		IstMk.S(root, Vector3(0.5, 1.5, wb - wa), Vector3(-A * 0.5 + 0.25, top, (wa + wb) * 0.5), IstMk.STONE, "ashlar")
	if wd - wc > 0.3:
		IstMk.S(root, Vector3(0.5, 1.5, wd - wc), Vector3(-A * 0.5 + 0.25, top, (wc + wd) * 0.5), IstMk.STONE, "ashlar")
	var ts := A * 0.28
	IstMk.S(root, Vector3(ts, 3.0, ts), Vector3(0, top, 0), IstMk.STONE_DK, "ashlar", 45.0)
	var pyr := Props.cyl(root, ts * 0.78, 2.4, Vector3(0, top + 3.0 + 1.2, 0), IstMk.TILE, Vector3(0, 0, 0), 4, 0.04)
	Props.set_pattern(pyr, IstMk.TILE, "tiles")
	Props.make_solid(pyr, 1.0)
	IstMk.FLIGHT(root, Vector3(float(stm["x"]), 0.0, float(stm["z_foot"])), Vector3(0, 0, -1), H, 1.7, [1.0, -1.0], IstMk.STONE, "ashlar")
	if lod >= 1:
		return
	# mazgal
	var xf: Array = []
	var n := int(floor(A / 1.7))
	for i in n:
		var px := -A * 0.5 + (i + 0.5) * A / n
		xf.append([Vector3(px, top + 1.5 + 0.4, A * 0.5 - 0.25), 0.0])
		xf.append([Vector3(px, top + 1.5 + 0.4, -A * 0.5 + 0.25), 0.0])
		xf.append([Vector3(A * 0.5 - 0.25, top + 1.5 + 0.4, px), 90.0])
	IstMk.MM(root, Vector3(0.95, 0.8, 0.52), xf, IstMk.STONE, "ashlar")
	IstMk.DOOR_DARK(root, Vector3(0, top, ts * 0.5 + 0.02), 1.0, 2.0)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			IstMk.S(root, Vector3(0.8, H * 0.6, 0.8), Vector3(sx * (A * 0.5), 0, sz * (A * 0.5)), IstMk.MARBLE, "marble")
	for i in 2:
		IstMk.V(root, Vector3(A + 0.1, 0.4, A + 0.1), Vector3(0, H * 0.6 + i * H * 0.15, 0), IstMk.BRICK, "brick")
	var win: Array = []
	for r in 2:
		for i in 3:
			win.append([Vector3(-A * 0.3 + i * A * 0.3, H * (0.35 + 0.25 * r), A * 0.5 + 0.02), 0.0])
	IstMk.MM(root, Vector3(0.6, 1.3, 0.06), win, IstMk.DARK)
	IstMk.V(root, Vector3(1.8, 0.9, 0.08), Vector3(0, H * 0.45, A * 0.5 + 0.05), IstMk.MARBLE_GREY, "marble")
	IstMk.V(root, Vector3(0.1, 0.9, 0.1), Vector3(0, H * 0.45, A * 0.5 + 0.11), IstMk.GOLD)
	IstMk.CY(root, 0.06, 3.2, Vector3(A * 0.5 - 1.0, top + 1.5, A * 0.5 - 1.0), IstMk.WOOD_DK, "", 5)
	IstMk.V(root, Vector3(0.04, 0.8, 1.4), Vector3(A * 0.5 - 1.0, top + 1.5 + 2.2, A * 0.5 - 1.0 - 0.75), IstMk.GOLD)
	IstMk.V(root, Vector3(0.05, 0.8, 0.4), Vector3(A * 0.5 - 1.0, top + 1.5 + 2.2, A * 0.5 - 1.0 - 0.25), IstMk.RED)


static func stair_mk(k: float) -> Dictionary:
	var d := md(k)
	var A: float = d["A"]
	var H: float = d["H"]
	var n := int(ceil(H / 0.34))
	var zt := -A * 0.5 + 1.8
	return {"x": -(A * 0.5 + 0.86), "z_foot": zt + n * 0.46, "z_top": zt}


static func perches_mermerkule(k: float = 0.5) -> Array:
	var d := md(k)
	var A: float = d["A"]
	var H: float = d["H"]
	return [Vector3(A * 0.3, H, A * 0.3), Vector3(0, H + 3.0 + 2.4, 0)]


static func climbs_mermerkule(k: float = 0.5) -> Array:
	var d := md(k)
	var A: float = d["A"]
	var H: float = d["H"]
	var sd: Dictionary = d["SD"]
	var stm := stair_mk(k)
	var st := SUR.stair_pos(float(d["LEN"]), k)
	var T: float = sd["T"]
	var zc := -T * 0.5 - 0.85
	var xo := A * 0.5 + float(d["LEN"]) * 0.5 - 0.5
	var sx: float = stm["x"]
	var zt: float = stm["z_top"]
	return [
		[Vector3(sx, 0.0, float(stm["z_foot"]) + 0.5), Vector3(sx, H, zt + 0.25), "merdiven"],
		[Vector3(sx, H, zt + 0.2), Vector3(-A * 0.5 + 1.2, H, zt + 0.2), "basamak"],
		[Vector3(xo + float(st["x_foot"]) - 0.4, 0.0, zc), Vector3(xo + float(st["x_top"]) - 0.25, float(sd["H"]), zc), "merdiven"],
	]


# ============================================================= AHIRKAPI ==========================================
static func _ahir_opts(k: float) -> Dictionary:
	var sd := SUR.dims(k)
	var S: float = sd["S"]
	var n := int(ceil(float(sd["H"]) / SUR.RISE))
	var l := n * SUR.RUN
	var mid := -S * 0.5 - float(sd["TW"]) * 0.5 - float(sd["NST"]) * 0.5 - l * 0.5 - 0.6
	return {"kapi": [0.0], "stair_mid": mid}


static func build_ahirkapi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var sd := SUR.dims(k)
	var S: float = sd["S"]
	var T: float = sd["T"]
	var root := IstMk.root(host, "Ahirkapi")
	SUR.build_run(root, 2.0 * S, k, lod, _ahir_opts(k))
	if lod >= 2:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 1500
	var prj: float = sd["PROJ"]
	IstMk.S(root, Vector3(S * 0.9, 0.08, 6.0), Vector3(0, 0.0, T * 0.5 + 3.0 + 0.5), IstMk.STONE_DK, "flagstone")
	IstMk.S(root, Vector3(S * 0.9, 2.0, 0.8), Vector3(0, -2.0, T * 0.5 + 6.9), IstMk.STONE_DK, "ashlar")
	IstMk.S(root, Vector3(S * 0.9, 0.3, 0.8), Vector3(0, 0.0, T * 0.5 + 6.9), IstMk.STONE, "ashlar")
	if lod >= 1:
		return
	for i in 4:
		IstMk.CY(root, 0.17, 0.6, Vector3(-S * 0.4 + i * (S * 0.8 / 3.0), 0.08, T * 0.5 + 6.2), IstMk.STONE_DK, "marble", 8, true)
	var fx := 5.0
	var fz := -T * 0.5 - 0.2
	IstMk.S(root, Vector3(3.2, 3.0, 0.7), Vector3(fx, 0.0, fz - 0.35), IstMk.MARBLE, "marble")
	IstMk.V(root, Vector3(1.6, 1.8, 0.06), Vector3(fx, 0.5, fz - 0.7 - 0.03), IstMk.DARK)
	IstMk.ARCH(root, Vector3(fx, 2.3, fz - 0.74), 0.8, 0.3, 0.1, IstMk.MARBLE_GREY, "marble", 9)
	IstMk.CYR(root, 0.06, 0.4, Vector3(fx, 1.1, fz - 0.9), IstMk.STONE_DK, Vector3(90, 0, 0), "", 6)
	IstMk.S(root, Vector3(2.4, 0.5, 1.2), Vector3(fx, 0.0, fz - 1.5), IstMk.MARBLE_GREY, "marble")
	IstMk.V(root, Vector3(2.0, 0.04, 0.8), Vector3(fx, 0.5, fz - 1.5), Color("4a86a0"))
	for i in 2:
		_boat(root, Vector3(-S * 0.3 + i * 5.0, 0.0, T * 0.5 + 4.0), 8.0 + i * 25.0, 1.0)
	IstMk.CY(root, 0.09, 3.2, Vector3(-3.4, 0.0, T * 0.5 + 1.0), IstMk.WOOD_DK, "wood", 6, true)
	IstMk.V(root, Vector3(0.35, 0.35, 0.35), Vector3(-3.4, 3.1, T * 0.5 + 1.0), IstMk.DARK)
	Flame.add(root, Vector3(-3.4, 3.25, T * 0.5 + 1.0), 0.3, 0.45)


static func perches_ahirkapi(k: float = 0.5) -> Array:
	var sd := SUR.dims(k)
	var S: float = sd["S"]
	var out: Array = []
	for x: float in SUR.tower_xs(2.0 * S, k):
		out.append(Vector3(x, float(sd["TH"]), float(sd["PROJ"]) * 0.5))
	return out


static func climbs_ahirkapi(k: float = 0.5) -> Array:
	var sd := SUR.dims(k)
	var S: float = sd["S"]
	var T: float = sd["T"]
	var st := SUR.stair_pos(2.0 * S, k, _ahir_opts(k))
	var zc := -T * 0.5 - 0.85
	var xt: float = st["x_top"]
	return [
		[Vector3(float(st["x_foot"]) - 0.4, 0.0, zc), Vector3(xt - 0.25, float(sd["H"]), zc), "merdiven"],
		[Vector3(xt - 0.2, float(sd["H"]), zc), Vector3(xt - 0.2, float(sd["H"]), -T * 0.5 + 0.9), "basamak"],
	]


# ============================================================ BALIKÇI BARINAKLARI ================================
static func _hut(p: Node3D, pos: Vector3, yaw_deg: float, size: Vector3, steps := false) -> Node3D:
	# kulübe: taş-moloz alt kat (0,9), hasır üst; hasır (kamış) beşik çatı, dış çatı katı; kapı dışarıya (+z yerel) boş kapı
	var h := IstMk.root(p, "Kulube")
	h.position = pos
	h.rotation.y = deg_to_rad(yaw_deg)
	IstMk.S(h, Vector3(size.x, 1.0, size.z), Vector3.ZERO, IstMk.ROCK, "rubble")
	IstMk.S(h, Vector3(size.x - 0.2, size.y - 1.0, size.z - 0.2), Vector3(0, 1.0, 0), IstMk.WOOD_LT, "wood")
	IstMk.ROOF(h, Vector3(size.z + 0.6, 1.3, size.x + 0.8), Vector3(0, size.y, 0), IstMk.THATCH, "", 90.0)
	IstMk.DOOR_DARK(h, Vector3(0, 0, size.z * 0.5 + 0.02), 0.9, 1.9)
	# direkler ve çatı bağı: köşelerde sürüklenmiş odun direkleri
	for sx: float in [-1.0, 1.0]:
		IstMk.CY(h, 0.08, size.y + 0.4, Vector3(sx * (size.x * 0.5), 0.0, size.z * 0.5), IstMk.WOOD_DK, "wood", 6)
	if steps:
		for i in 7:
			IstMk.S(h, Vector3(1.4, size.y / 7.0 * (i + 1), 0.82), Vector3(size.x * 0.28, 0.0, size.z * 0.5 + 0.4 + (6 - i) * 0.8), IstMk.WOOD_LT if i % 2 == 0 else IstMk.WOOD, "wood")
	return h


static func _boat(p: Node3D, pos: Vector3, yaw_deg: float, sc: float) -> void:
	# karaya çekilmiş kayık: tekne gövdesi (katı), kıç ve pruva kaş, kürek yatıyor
	var b := IstMk.root(p, "Kayik")
	b.position = pos
	b.rotation.y = deg_to_rad(yaw_deg)
	IstMk.S(b, Vector3(1.5 * sc, 0.55, 4.6 * sc), Vector3(0, 0.25, 0), IstMk.WOOD_LT, "wood")
	IstMk.S(b, Vector3(1.0 * sc, 0.35, 1.0 * sc), Vector3(0, 0.25, 2.6 * sc), IstMk.WOOD_LT, "wood")
	IstMk.S(b, Vector3(1.0 * sc, 0.35, 1.0 * sc), Vector3(0, 0.25, -2.6 * sc), IstMk.WOOD_LT, "wood")
	IstMk.V(b, Vector3(1.2 * sc, 0.06, 0.4), Vector3(0, 0.82, 0.8), IstMk.WOOD)
	IstMk.V(b, Vector3(1.2 * sc, 0.06, 0.4), Vector3(0, 0.82, -0.8), IstMk.WOOD)
	IstMk.CYR(b, 0.04, 2.6, Vector3(0.9 * sc, 0.88, 0.0), IstMk.WOOD_DK, Vector3(90, 0, 0), "", 5)
	# kızak kütükleri
	IstMk.CYR(b, 0.12, 2.0, Vector3(0, 0.12, 1.4 * sc), IstMk.WOOD_DK, Vector3(0, 0, 90), "wood", 6)
	IstMk.CYR(b, 0.12, 2.0, Vector3(0, 0.12, -1.4 * sc), IstMk.WOOD_DK, Vector3(0, 0, 90), "wood", 6)


static func build_balikci(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var root := IstMk.root(host, "Balikci")
	var rng := RandomNumberGenerator.new()
	rng.seed = 404
	if lod >= 2:
		IstMk.S(root, Vector3(18.0, 2.4, 10.0), Vector3(0, 0, 0), IstMk.WOOD_LT, "wood")
		return
	# dört kulübe (yarım daire), ortada ateş çukuru; ilk kulübenin çatısına sandık merdiveni
	var poses := [
		[Vector3(-6.5, 0.0, -2.5), 15.0, Vector3(3.8, 2.6, 3.2)],
		[Vector3(0.5, 0.0, -4.5), 0.0, Vector3(3.4, 2.4, 3.0)],
		[Vector3(7.0, 0.0, -2.0), -20.0, Vector3(4.2, 2.6, 3.4)],
		[Vector3(11.5, 0.0, 4.5), -50.0, Vector3(3.2, 2.4, 2.8)],
	]
	for pi in poses.size():
		var pz: Array = poses[pi]
		_hut(root, pz[0], pz[1], pz[2], pi == 0)
	if lod >= 1:
		return
	# ateş çukuru: taş halka + kütük oturaklar + ateş
	var fp := Vector3(0.5, 0.0, 2.0)
	for i in 10:
		var a := TAU * i / 10.0
		IstMk.S(root, Vector3(0.5, 0.25, 0.4), fp + Vector3(cos(a) * 0.8, 0.0, sin(a) * 0.8), IstMk.ROCK, "rubble", rad_to_deg(-a))
	Flame.add(root, fp + Vector3(0, 0.2, 0), 0.7, 1.0)
	for i in 3:
		var a := TAU * (i + 0.3) / 3.0
		IstMk.CYR(root, 0.22, 1.2, fp + Vector3(cos(a) * 2.2, 0.22, sin(a) * 2.2), IstMk.WOOD, Vector3(0, rad_to_deg(-a), 90), "wood", 7, true)
	# asılı kazan
	IstMk.CY(root, 0.3, 0.4, fp + Vector3(1.4, 0.0, 0.4), IstMk.DARK, "", 8, true)
	# amfora yığını (yatık üçgen) ve küfeler
	for r in 3:
		for c in 3 - r:
			IstMk.CYR(root, 0.22, 0.9, Vector3(15.0 + c * 0.5 + r * 0.25, 0.22 + r * 0.38, 0.0), Color("b0764a"), Vector3(0, 0, 90), "", 8, true)
	# balık kurutma çerçevesi (kısa)
	IstMk.S(root, Vector3(2.8, 0.1, 0.9), Vector3(-1.5, 1.0, 6.0), IstMk.WOOD, "wood")
	for sx: float in [-1.0, 1.0]:
		IstMk.CY(root, 0.07, 1.0, Vector3(-1.5 + sx * 1.3, 0.0, 6.0), IstMk.WOOD_DK, "wood", 6, true)
	var fish: Array = []
	for i in 7:
		fish.append([Vector3(-2.5 + i * 0.4, 0.85, 6.0), 0.0])
	IstMk.MM(root, Vector3(0.08, 0.3, 0.05), fish, Color("c0c8cc"))
	# kayıklar karada
	_boat(root, Vector3(-1.0, 0.0, 9.5), 80.0, 1.0)
	_boat(root, Vector3(5.5, 0.0, 8.5), 60.0, 1.2)
	# fıçılar, sepetler, çıpa (taş)
	for i in 3:
		IstMk.CY(root, 0.36, 0.85, Vector3(-9.8 + i * 0.8, 0.0, 1.0 + (i % 2) * 0.4), IstMk.WOOD, "wood", 10, true)
	IstMk.S(root, Vector3(0.6, 0.18, 0.9), Vector3(-3.0, 0.0, 4.0), IstMk.ROCK, "rubble")
	IstMk.TUFTS(root, rng, Rect2(-12.0, -8.0, 28.0, 20.0), 70, 0.0, IstMk.GRASS, 0.4)


static func perches_balikci(k: float = 0.5) -> Array:
	return [Vector3(-6.5, 2.6 + 1.3, -2.5), Vector3(7.0, 2.6 + 1.3, -2.0)]


static func climbs_balikci(k: float = 0.5) -> Array:
	var rot := Basis(Vector3.UP, deg_to_rad(15.0))
	var base := Vector3(-6.5, 0.0, -2.5)
	var alt := base + rot * Vector3(3.8 * 0.28, 0.0, 3.2 * 0.5 + 0.4 + 6 * 0.8 + 1.2)
	var ust := base + rot * Vector3(3.8 * 0.28, 3.55, 0.0)
	return [[alt, ust, "sandik"]]


# ============================================================= KAYIKHANE ==========================================
static func kdim(k: float) -> Dictionary:
	return {"W": maxf(18.0 * k, 12.0), "D": maxf(9.0 * k, 6.6), "H": maxf(7.0 * k, 4.4)}


static func build_kayikhane(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var d := kdim(k)
	var W: float = d["W"]
	var D: float = d["D"]
	var H: float = d["H"]
	var root := IstMk.root(host, "Kayikhane")
	var OW := 4.0         # ön açıklık (gerçek boy)
	var OH := 3.2
	# arka duvar, iki yan duvar, ön duvar iki parça (ortada açıklık), tavan levhası
	var t := 0.6
	IstMk.S(root, Vector3(W, H, t), Vector3(0, 0, -D * 0.5 + t * 0.5), IstMk.STONE_DK, "rubble")
	IstMk.S(root, Vector3(t, H, D), Vector3(-W * 0.5 + t * 0.5, 0, 0), IstMk.STONE_DK, "rubble")
	IstMk.S(root, Vector3(t, H, D), Vector3(W * 0.5 - t * 0.5, 0, 0), IstMk.STONE_DK, "rubble")
	var fw := (W - OW) * 0.5
	IstMk.S(root, Vector3(fw, H, t), Vector3(-(OW * 0.5 + fw * 0.5), 0, D * 0.5 - t * 0.5), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(fw, H, t), Vector3((OW * 0.5 + fw * 0.5), 0, D * 0.5 - t * 0.5), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(OW + 0.02, H - OH, t), Vector3(0, OH, D * 0.5 - t * 0.5), IstMk.STONE, "ashlar")
	# tavan levhası ve kiremitli çatı
	IstMk.S(root, Vector3(W, 0.4, D), Vector3(0, H, 0), IstMk.WOOD_DK, "wood")
	IstMk.ROOF(root, Vector3(D + 1.0, D * 0.3, W + 1.0), Vector3(0, H + 0.4, 0), IstMk.TILE, "tiles", 90.0)
	if lod >= 1:
		IstMk.FLIGHT(root, Vector3(W * 0.5 + 0.86, 0.0, D * 0.5 - 0.4 + 0.0), Vector3(0, 0, -1), H + 0.4, 1.6, [1.0, -1.0], IstMk.STONE, "ashlar") if lod >= 1 and D > 3.0 else null
		return
	# ön açıklık: kemer + ahşap lento; içeride zemin levha, tekne ve kızak
	IstMk.ARCH(root, Vector3(0, OH, D * 0.5 + 0.02), OW * 0.5, 0.4, 0.2, IstMk.BRICK, "brick", 11)
	IstMk.V(root, Vector3(OW, OW * 0.5, 0.05), Vector3(0, OH, D * 0.5 + 0.0), IstMk.DARK)
	IstMk.V(root, Vector3(W - 1.4, 0.03, D - 1.2), Vector3(0, 0.0, 0.0), IstMk.SAND, "flagstone")
	# iç: orta eksende tekne iskeleti (katı), kızak kirişleri, direkler
	var bz := -D * 0.5 + 0.5 + 2.8
	IstMk.S(root, Vector3(1.5, 0.7, 5.6), Vector3(0, 0.5, bz), IstMk.WOOD_LT, "wood")
	for i in 3:
		IstMk.S(root, Vector3(1.0, 0.5, 0.35), Vector3(0, 0.0, bz - 2.0 + i * 2.0), IstMk.WOOD_DK, "wood")
	IstMk.V(root, Vector3(1.6, 0.1, 0.5), Vector3(0, 1.2, bz + 0.8), IstMk.WOOD)
	# arka duvara yaslı kürek dizisi ve ağ yığını (bitişik: boşluk yok)
	var oars: Array = []
	for i in 8:
		oars.append([Vector3(-W * 0.5 + 1.5 + i * 0.35, 1.2, -D * 0.5 + t + 0.12), 0.0])
	IstMk.MMC(root, 0.05, 2.4, oars, IstMk.WOOD, 5)
	IstMk.S(root, Vector3(1.8, 0.5, 0.9), Vector3(W * 0.5 - 1.5, 0.0, -D * 0.5 + t + 0.45), IstMk.ROPE, "")
	# pencere yarıkları, dışta halat halkaları ve kandil
	var sl: Array = []
	for i in 4:
		sl.append([Vector3(-W * 0.35 + i * W * 0.23, H * 0.75, -D * 0.5 - 0.01), 0.0])
	IstMk.MM(root, Vector3(0.18, 0.9, 0.06), sl, IstMk.DARK)
	for sx: float in [-1.0, 1.0]:
		IstMk.V(root, Vector3(0.12, 0.3, 0.12), Vector3(sx * (OW * 0.5 + 0.5), 2.4, D * 0.5 + 0.1), IstMk.DARK)
		Flame.add(root, Vector3(sx * (OW * 0.5 + 0.5), 2.7, D * 0.5 + 0.1), 0.2, 0.32)
	# önde kızak: taş levha zemin + ahşap kızak rayları (denize doğru)
	IstMk.V(root, Vector3(OW + 1.0, 0.04, 8.0), Vector3(0, 0.0, D * 0.5 + 4.0), IstMk.STONE_DK, "flagstone")
	IstMk.V(root, Vector3(0.2, 0.1, 8.0), Vector3(-0.8, 0.0, D * 0.5 + 4.0), IstMk.WOOD_DK, "wood")
	IstMk.V(root, Vector3(0.2, 0.1, 8.0), Vector3(0.8, 0.0, D * 0.5 + 4.0), IstMk.WOOD_DK, "wood")
	# mahya kiremiti ve baca yok; yan merdiven (dama) doğu yüzünde
	IstMk.FLIGHT(root, Vector3(W * 0.5 + 0.86, 0.0, D * 0.5 - 0.4), Vector3(0, 0, -1), H + 0.4, 1.6, [1.0, -1.0], IstMk.STONE, "ashlar")
	IstMk.V(root, Vector3(W + 1.2, 0.2, 0.3), Vector3(0, H + 0.4 + D * 0.3 - 0.05, 0), IstMk.BRICK_DK, "brick")


static func perches_kayikhane(k: float = 0.5) -> Array:
	var d := kdim(k)
	return [Vector3(0, float(d["H"]) + 0.4 + float(d["D"]) * 0.3, 0)]


static func climbs_kayikhane(k: float = 0.5) -> Array:
	var d := kdim(k)
	var W: float = d["W"]
	var D: float = d["D"]
	var H: float = d["H"]
	var n := int(ceil((H + 0.4) / 0.34))
	var zt := D * 0.5 - 0.4 - n * 0.46
	return [
		[Vector3(W * 0.5 + 0.86, 0.0, D * 0.5 - 0.4 + 0.5), Vector3(W * 0.5 + 0.86, H + 0.4, zt + 0.25), "merdiven"],
	]


# ============================================================= AĞ SEHPALARI ======================================
static func build_agsehpa(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var root := IstMk.root(host, "AgSehpalari")
	if lod >= 2:
		IstMk.S(root, Vector3(16.0, 2.4, 0.5), Vector3(0, 0, -2.0), IstMk.WOOD, "wood")
		IstMk.S(root, Vector3(16.0, 2.4, 0.5), Vector3(0, 0, 2.0), IstMk.WOOD, "wood")
		return
	# iki sıra, her sırada üç sehpa (5,2 m aralık): iki direk + üst kiriş (katı) + sarkan ağ (ince katı) + şamandıra
	for row in 2:
		var z := -2.4 + row * 4.8
		for i in 3:
			var cx := -5.4 + i * 5.4
			for sx: float in [-2.2, 2.2]:
				IstMk.CY(root, 0.09, 2.5, Vector3(cx + sx, 0.0, z), IstMk.WOOD_DK, "wood", 6, true)
				# payanda
			IstMk.S(root, Vector3(4.6, 0.14, 0.14), Vector3(cx, 2.35, z), IstMk.WOOD, "wood")
			if lod == 0:
				# ağ: koyu ince levha (çarpışmalı), altına tüy sarkıtları
				IstMk.S(root, Vector3(4.2, 1.7, 0.05), Vector3(cx, 0.65, z), Color("5b5a44"), "")
				var fl: Array = []
				for j in 9:
					fl.append([Vector3(cx - 1.9 + j * 0.47, 2.2, z + 0.06), 0.0])
				IstMk.MMC(root, 0.07, 0.14, fl, Color("d8c08a"), 6)
				var weights: Array = []
				for j in 9:
					weights.append([Vector3(cx - 1.9 + j * 0.47, 0.6, z + 0.06), 0.0])
				IstMk.MMC(root, 0.04, 0.1, weights, Color("5a5a5a"), 5)
	if lod >= 1:
		return
	# gözlem ve onarım iskelesi: sandık basamakları (0,4 → 0,8 → 1,2) ve 2,4×2,4 platform (1,2 m), korkuluksuz alçak
	IstMk.S(root, Vector3(2.4, 1.2, 2.4), Vector3(9.5, 0.0, 0.0), IstMk.WOOD_LT, "wood")
	IstMk.S(root, Vector3(1.0, 0.4, 1.4), Vector3(7.7, 0.0, 0.0), IstMk.WOOD, "wood")
	IstMk.S(root, Vector3(1.0, 0.8, 1.4), Vector3(8.4, 0.0, 0.0), IstMk.WOOD_LT, "wood")
	# platformda tabure, onarım ağı yığını, kazık kafası (kuşa konma noktası: direk tepesi)
	IstMk.CY(root, 0.08, 2.0, Vector3(10.4, 1.2, 0.8), IstMk.WOOD_DK, "wood", 6, true)
	IstMk.S(root, Vector3(0.9, 0.4, 0.9), Vector3(9.2, 1.2, -0.6), IstMk.ROPE, "")
	IstMk.CY(root, 0.2, 0.45, Vector3(9.6, 1.2, 0.6), IstMk.WOOD, "wood", 8, true)
	# yerde: serilmiş ağ (görsel ince yaprak), kovalar
	IstMk.V(root, Vector3(3.0, 0.03, 2.0), Vector3(-5.0, 0.0, 6.5), Color("6b6a50"))
	IstMk.CY(root, 0.25, 0.4, Vector3(-2.0, 0.0, 6.2), IstMk.WOOD, "wood", 8, true)


static func perches_agsehpa(k: float = 0.5) -> Array:
	return [Vector3(10.4, 3.2, 0.8), Vector3(-5.4 + 2.2, 2.5, -2.4)]


static func climbs_agsehpa(k: float = 0.5) -> Array:
	return [[Vector3(6.3, 0.0, 0.0), Vector3(9.5, 1.2, 0.0), "sandik"]]


# ================================================================ KAYALAR ========================================
static func build_kayalar(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var root := IstMk.root(host, "KiyiKayalari")
	var rng := RandomNumberGenerator.new()
	rng.seed = 2204
	# büyük kaya merdiveni: üst yüzeyleri 0,4 m aralıklı yükselen sekiz kaya (tepe 3,2 m); üst üste biner
	var tops := [0.4, 0.8, 1.2, 1.6, 2.0, 2.4, 2.8, 3.2]
	for i in tops.size():
		var t: float = tops[i]
		var rxz := 1.7 + 0.1 * (i % 3)
		var pos := Vector3(-7.0 + i * 1.5, 0.0, 1.0 * sin(i * 1.3))
		var m := IstMk.CY(root, rxz, t + 0.3, pos - Vector3(0, 0.3, 0), IstMk.ROCK if i % 2 == 0 else IstMk.ROCK_DK, "rubble", 7, true, rxz * 0.85)
	if lod >= 2:
		return
	# tepede düz taş levha (konma noktası): üst yüzeyi 3,2 m
	IstMk.S(root, Vector3(2.4, 0.2, 2.4), Vector3(-7.0 + 7 * 1.5, 3.2 - 0.05, 1.0 * sin(7 * 1.3)), IstMk.ROCK, "rubble")
	# dağınık kayalar
	for i in 16:
		var pos := Vector3(rng.randf_range(-12.0, 10.0), 0.0, rng.randf_range(-6.0, 7.0))
		if absf(pos.z - 0.5) < 3.8 and pos.x > -11.0 and pos.x < 6.0:
			continue
		IstMk.ROCKB(root, pos, Vector3(rng.randf_range(0.5, 1.4), rng.randf_range(0.25, 0.7), rng.randf_range(0.5, 1.2)), IstMk.ROCK if rng.randf() < 0.6 else IstMk.ROCK_DK, true)
	if lod >= 1:
		return
	# yosun bandı, midye lekeleri, kuru deniz otu yığını, sürüklenmiş kütük, yarım gömülü amfora
	var sea: Array = []
	for i in 30:
		sea.append([Vector3(rng.randf_range(-12.0, 10.0), 0.12, rng.randf_range(6.0, 9.0)), rng.randf_range(0.0, 180.0)])
	IstMk.MM(root, Vector3(0.9, 0.12, 0.5), sea, Color("3f5a34"))
	IstMk.CYR(root, 0.25, 4.0, Vector3(5.0, 0.25, 5.0), IstMk.WOOD_LT, Vector3(0, 35, 90), "wood", 7, true)
	IstMk.CYR(root, 0.28, 0.9, Vector3(-9.5, 0.2, 5.5), Color("b0764a"), Vector3(0, 0, 70), "", 8, true)
	IstMk.TUFTS(root, rng, Rect2(-12.0, -6.0, 22.0, 13.0), 60, 0.0, Color("6b8a45"), 0.35)


static func perches_kayalar(k: float = 0.5) -> Array:
	return [Vector3(-7.0 + 7 * 1.5, 3.2 + 0.05, sin(7 * 1.3))]


static func climbs_kayalar(k: float = 0.5) -> Array:
	return [[Vector3(-9.2, 0.0, 0.0), Vector3(-7.0 + 7 * 1.5, 3.2, sin(7 * 1.3)), "basamak"]]
