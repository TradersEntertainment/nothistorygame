class_name IstSurlarAyrinti
extends RefCounted
## Nisan 1453 izleri (yalnız lod 0): top oyukları, dibe düşen taşlar, kazık-fıçı-toprak onarımı (stauroma), iskele,
## sur üstü nöbetçi barınakları, mancınık, taş gülle yığınları, sancaklar, sarmaşık ve ot.

const C_WOOD := Color("7a5634")
const C_DARK := Color("2e2a25")
const C_SOOT := Color("5e584e")
const C_CHIP := Color("a89c86")


static func build(root: Node3D, lay: Dictionary, o: Dictionary) -> void:
	var d: Dictionary = lay["d"]
	var L: float = lay["L"]
	var rng := RandomNumberGenerator.new()
	rng.seed = int(lay["rng_seed"]) + 77
	var dmg: float = float(o.get("hasar", 1.0))
	var stone: Color = o.get("tas", Color("cdbd9e"))
	var zi1: float = d["zi1"]
	var zo1: float = d["zo1"]
	var zo0: float = d["zo0"]
	var HW: float = d["HW"]
	var OH: float = d["OH"]
	var itx: Array = lay["itx"]
	var otx: Array = lay["otx"]
	var gw: float = lay["gw"]
	# ---- top oyukları (dış yüzlerde): koyu oyuk + açık kırık halkası + çatlaklar
	var hits := int(round(L / 9.0 * dmg))
	for i in hits:
		var on_outer := i % 2 == 0
		var x := rng.randf_range(-L * 0.5 + 3.0, L * 0.5 - 3.0)
		if gw > 0.0 and absf(x) < gw * 0.5 + 1.6:
			continue
		if on_outer:
			_crater(root, Vector3(x, rng.randf_range(1.4, OH - 1.0), zo1), 1.0, rng.randf_range(0.35, 0.7), rng)
			for j in 4:
				Props.ball(root, rng.randf_range(0.12, 0.3), Vector3(x + rng.randf_range(-1.4, 1.4), 0.1, zo1 + rng.randf_range(0.3, 1.6)), C_CHIP.darkened(rng.randf_range(0.1, 0.4)), Vector3(1.2, 0.7, 1.0), 5)
		else:
			_crater(root, Vector3(x, rng.randf_range(OH + 0.6, HW - 1.0), zi1), 1.0, rng.randf_range(0.4, 0.8), rng)
	# ---- stauroma: dış sur tepesinde tahta perde, toprak dolu fıçılar (korkuluk üstünde) ve kazıklar
	var n_st := 2 + int(dmg * 2.0)
	for i in n_st:
		var x := rng.randf_range(-L * 0.5 + 8.0, L * 0.5 - 8.0)
		if gw > 0.0 and absf(x) < gw * 0.5 + 3.0:
			continue
		if _near_tower(otx, x, float(d["OTW"]) * 0.5 + 4.5):
			continue
		_stauroma(root, x, zo1 - 0.225, OH + 1.2, rng)
	# ---- iskele (dış sur yüzünde): direkler, kirişler, tahta
	if otx.size() > 0:
		var sx: float = float(otx[0]) + 7.5
		if absf(sx) < L * 0.5 - 4.0:
			_scaffold(root, sx, zo1 + 0.15, OH * 0.7)
	# ---- nöbetçi barınağı, taş gülle yığını ve sancak: iç kule tepelerinde
	for i in itx.size():
		var tw: Dictionary = itx[i]
		var cx: float = tw["x"]
		var w: float = tw["w"]
		var z0: float = -float(d["T"]) * 0.5 - 0.1
		var z1: float = float(d["T"]) * 0.5 + float(tw["p"]) + 0.15
		var HT: float = d["HT"]
		match i % 4:
			0:
				_hut(root, cx - w * 0.2, HT, (z0 + z1) * 0.5, rng)
				_flag(root, cx + w * 0.3, HT, z0 + 1.1, Color("8a1c1c"), Color("d9a82a"))
			1:
				_balls(root, cx, HT, z1 - 1.3, 4, rng)
				_mangonel(root, cx - 1.0, HT, (z0 + z1) * 0.5 - 0.4)
			2:
				_flag(root, cx, HT, z0 + 1.1, Color("1c3a8a"), Color("e8e0d0"))
				_balls(root, cx + w * 0.25, HT, z1 - 1.3, 3, rng)
			_:
				_hut(root, cx + w * 0.15, HT, (z0 + z1) * 0.5, rng)
	# ---- dış kule tepelerinde fıçı ve gülle
	for j in otx.size():
		var ox: float = otx[j]
		if j % 2 == 0:
			_balls(root, ox + 0.5, d["OTH"], zo0 + 1.2, 3, rng)
		else:
			_barrel(root, Vector3(ox - 0.7, float(d["OTH"]), zo0 + float(d["OT"]) + 0.8))
	# ---- sarmaşık: duvar yüzünde küçük, düzensiz yaprak öbekleri (düz yeşil levha değil)
	var ivy := Color("4a5f2c")
	for i in int(L / 12.0):
		var x2 := rng.randf_range(-L * 0.5 + 2.0, L * 0.5 - 2.0)
		var fz: float = zo1 if i % 2 == 0 else zi1
		if gw > 0.0 and absf(x2) < gw * 0.5 + 2.0:
			continue
		var y2 := 0.2
		for j in 9:
			var ww := rng.randf_range(0.18, 0.5)
			var hh := rng.randf_range(0.2, 0.55)
			y2 += rng.randf_range(0.1, 0.35)
			var m := Props.box(root, Vector3(ww, hh, 0.04), Vector3(x2 + rng.randf_range(-0.5, 0.5), y2, fz + 0.025), ivy.darkened(rng.randf_range(0.0, 0.3)), Vector3(0, 0, rng.randf_range(-30.0, 30.0)))
			m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var bushes: Array = []
	for i in int(L * 0.5):
		var bz: float = rng.randf_range(float(d["zo1"]) + 0.8, float(d["zm0"]) - 2.2)
		var bx := rng.randf_range(-L * 0.5 + 2.0, L * 0.5 - 2.0)
		if gw > 0.0 and absf(bx) < gw * 0.5 + 2.0:
			continue
		var s := rng.randf_range(0.25, 0.6)
		bushes.append(Transform3D(Basis.from_scale(Vector3(s, s * 0.7, s)), Vector3(bx, s * 0.25, bz)))
	if bushes.size() > 0:
		var sm := SphereMesh.new()
		sm.radius = 1.0
		sm.height = 2.0
		sm.radial_segments = 6
		sm.rings = 3
		Scenery.scatter(root, sm, bushes, [], Props.mat(Color("5c7a34"), 0.0, false, ""))


static func _near_tower(otx: Array, x: float, r: float) -> bool:
	for t in otx:
		if absf(float(t) - x) < r:
			return true
	return false


static func _crater(root: Node3D, p: Vector3, nz: float, r: float, rng: RandomNumberGenerator) -> void:
	var a := Props.box(root, Vector3(r * 1.9, r * 1.6, 0.02), p + Vector3(0, 0, nz * 0.012), C_SOOT, Vector3(0, 0, rng.randf_range(-25.0, 25.0)))
	var b := Props.box(root, Vector3(r * 1.1, r * 1.0, 0.03), p + Vector3(0, -r * 0.05, nz * 0.025), C_DARK, Vector3(0, 0, 45.0 + rng.randf_range(-15.0, 15.0)))
	a.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for k in 3:
		var ang := rng.randf_range(-PI, PI)
		var ln := rng.randf_range(0.6, 1.2) * r * 1.0
		var c := Props.box(root, Vector3(0.05, ln, 0.025), p + Vector3(cos(ang) * (r + ln * 0.5), sin(ang) * (r + ln * 0.5), nz * 0.02), C_DARK, Vector3(0, 0, rad_to_deg(ang) + 90.0))
		c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func _barrel(root: Node3D, p: Vector3) -> void:
	var b := Props.cyl(root, 0.42, 0.95, p + Vector3(0, 0.475, 0), C_WOOD.darkened(0.1), Vector3.ZERO, 10, 0.38)
	Props.make_solid(b, 0.9)
	Props.cyl(root, 0.43, 0.06, p + Vector3(0, 0.25, 0), Color("3a3634"), Vector3.ZERO, 10)
	Props.cyl(root, 0.43, 0.06, p + Vector3(0, 0.75, 0), Color("3a3634"), Vector3.ZERO, 10)
	Props.cyl(root, 0.36, 0.03, p + Vector3(0, 0.96, 0), Color("5a4630"), Vector3.ZERO, 10)


static func _stauroma(root: Node3D, x: float, z: float, y: float, rng: RandomNumberGenerator) -> void:
	for i in 4:
		_barrel(root, Vector3(x + i * 0.95 - 1.4, y, z))
	# arkada toprak yığını ve öne eğik kazıklar
	var earth := Props.ball(root, 0.5, Vector3(x, y + 0.95, z), Color("5a4630"), Vector3(4.4, 0.35, 0.6), 6)
	earth.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in 7:
		var sx := x - 1.7 + i * 0.57
		Props.cyl(root, 0.06, 1.7, Vector3(sx, y + 0.75, z + 0.42), C_WOOD.darkened(0.2), Vector3(-24.0 + rng.randf_range(-4.0, 4.0), 0, 0), 5, 0.02)
	Props.box(root, Vector3(3.8, 0.1, 0.12), Vector3(x, y + 0.5, z + 0.34), C_WOOD.darkened(0.1))


static func _scaffold(root: Node3D, x: float, z: float, h: float) -> void:
	for sx in [-1.0, 1.0]:
		for dz in [0.0, 1.2]:
			Props.cyl(root, 0.07, h + 1.4, Vector3(x + sx * 1.0, (h + 1.4) * 0.5, z + dz + 0.1), C_WOOD, Vector3.ZERO, 5)
	for lvl in [0.4, 0.8, 1.0]:
		Props.box(root, Vector3(2.2, 0.08, 0.1), Vector3(x, h * lvl, z + 0.1), C_WOOD.darkened(0.1))
		Props.box(root, Vector3(2.2, 0.08, 0.1), Vector3(x, h * lvl, z + 1.3), C_WOOD.darkened(0.1))
	for pz in 5:
		Props.box(root, Vector3(2.2, 0.06, 0.22), Vector3(x, h * 0.8 + 0.08, z + 0.2 + pz * 0.24), C_WOOD.lightened(0.05))
	# merdiven (iskeleye dayalı)
	Props.box(root, Vector3(0.06, h * 0.9, 0.06), Vector3(x - 0.3, h * 0.4, z + 1.6), C_WOOD, Vector3(-18, 0, 0))
	Props.box(root, Vector3(0.06, h * 0.9, 0.06), Vector3(x + 0.3, h * 0.4, z + 1.6), C_WOOD, Vector3(-18, 0, 0))
	for r in 8:
		Props.box(root, Vector3(0.62, 0.04, 0.05), Vector3(x, 0.4 + r * h * 0.1, z + 1.9 - r * h * 0.032), C_WOOD)


static func _hut(root: Node3D, x: float, y: float, z: float, rng: RandomNumberGenerator) -> void:
	# tahta nöbetçi barınağı: dört duvar tek katı kutu + kiremit çatı + açık ön (karanlık kapı boşluğu)
	var body := Props.solid(root, Vector3(1.9, 1.7, 1.7), Vector3(x, y + 0.85, z), C_WOOD.lightened(0.05))
	Props.set_pattern(body, C_WOOD.lightened(0.05), "wood")
	var roof := Props.prism(root, Vector3(2.3, 0.9, 2.1), Vector3(x, y + 1.7 + 0.45, z), Color("b4532f"))
	Props.set_pattern(roof, Color("b4532f"), "tiles")
	Props.make_solid(roof, 1.0)
	Props.box(root, Vector3(0.7, 1.2, 0.04), Vector3(x, y + 0.65, z - 0.86), Color("15120f"))


static func _balls(root: Node3D, x: float, y: float, z: float, n: int, rng: RandomNumberGenerator) -> void:
	# taş gülle piramidi: n tabanlı üçgen dizilim (her sıra bir üstte), katı taban
	var r := 0.22
	var base := Props.solid(root, Vector3(n * r * 2.2 + 0.2, 0.12, n * r * 2.2 * 0.8 + 0.2), Vector3(x, y + 0.06, z), Color("8a7a60"))
	var yy := y + 0.12 + r
	for row in n:
		var cnt := n - row
		for i in cnt:
			var bx := x + (i - (cnt - 1) * 0.5) * r * 2.1
			Props.ball(root, r, Vector3(bx, yy + row * r * 1.7, z), Color("6e6a62").lightened(rng.randf_range(0.0, 0.1)), Vector3.ONE, 7)


static func _flag(root: Node3D, x: float, y: float, z: float, c1: Color, c2: Color) -> void:
	Props.cyl(root, 0.05, 3.6, Vector3(x, y + 1.8, z), C_WOOD.darkened(0.2), Vector3.ZERO, 5)
	Props.cyl(root, 0.09, 0.14, Vector3(x, y + 3.65, z), Color("d9a82a"), Vector3.ZERO, 6)
	Props.box(root, Vector3(0.03, 1.0, 1.6), Vector3(x, y + 3.0, z + 0.85), c1)
	Props.box(root, Vector3(0.035, 0.34, 0.5), Vector3(x, y + 3.0, z + 0.6), c2)


static func _mangonel(root: Node3D, x: float, y: float, z: float) -> void:
	# Alçak, gerili mancınık: iki ayak, eksen, uzun kol ve ağırlık sandığı (çatı üstü)
	var w := C_WOOD.darkened(0.1)
	for sx in [-1.0, 1.0]:
		Props.box(root, Vector3(0.16, 1.9, 0.16), Vector3(x + sx * 0.8, y + 0.95, z - 0.45), w, Vector3(0, 0, -sx * 14.0))
		Props.box(root, Vector3(0.16, 1.9, 0.16), Vector3(x + sx * 0.8, y + 0.95, z + 0.45), w, Vector3(0, 0, -sx * 14.0))
		Props.box(root, Vector3(0.14, 0.14, 1.1), Vector3(x + sx * 0.55, y + 0.15, z), w)
	Props.cyl(root, 0.06, 1.8, Vector3(x, y + 1.82, z), Color("3a3634"), Vector3(0, 0, 90), 6)
	Props.box(root, Vector3(0.12, 0.14, 3.2), Vector3(x, y + 1.9, z), w.lightened(0.05), Vector3(24, 0, 0))
	Props.box(root, Vector3(0.7, 0.55, 0.6), Vector3(x, y + 0.95, z - 1.45), w.darkened(0.1))
