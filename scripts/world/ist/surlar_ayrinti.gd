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
	# Her öğenin kendi rasgele üreteci (ŞEHİR-3: IstSurlar.pencere ile pencere pencere kurulurken aynı sonuç)
	var sd := int(lay["rng_seed"]) + 77
	# TUR-7: dış kademe (dy): dış surun ova yüzündeki her şey (döküntü, çalı, iskele) terasın gerçek zemininde
	var dy := float(d.get("dis_dy", 0.0))
	# TUR-7: gedik aralıkları (oyulan sur): yüz ayrıntısı (oyuk, sarmaşık, çalı) gediğin boşluğunda kalmasın
	var gcut: Array = []
	for gx in o.get("gedik", []):
		gcut.append([float(gx) - IstSurlar.GEDIK_W * 0.5 - 2.5, float(gx) + IstSurlar.GEDIK_W * 0.5 + 2.5])
	var gedikte := func(x: float) -> bool:
		for c: Array in gcut:
			if x > float(c[0]) and x < float(c[1]):
				return true
		return false
	# ---- top oyukları (dış yüzlerde): TUR-7 tek ağ: düzensiz oyuk (koyu iç, kırık açık kenar, dökülmüş blok izleri),
	# incelen çatlaklar; dibinde dökülmüş taş (yerde). Baklava levha + çubuk yok.
	var iz := IstSurlar.KULE.Ag.new()
	var dok: Array = []
	var hits := int(round(L / 9.0 * dmg))
	for i in hits:
		rng = _rr(sd, 1, i)
		var on_outer := i % 2 == 0
		var x := rng.randf_range(-L * 0.5 + 3.0, L * 0.5 - 3.0)
		if gw > 0.0 and absf(x) < gw * 0.5 + 1.6:
			continue
		if not IstSurlar._ic(x) or gedikte.call(x):
			continue
		if on_outer:
			if _near_tower(otx, x, float(d["OTW"]) * 0.5 + 1.2):
				continue
			var yy := rng.randf_range(maxf(1.4, dy + 2.0), OH - 1.0)
			_oyuk(iz, Vector3(x, yy, zo1), rng.randf_range(0.35, 0.7), rng)
			for j in 5:
				var sc := rng.randf_range(0.14, 0.32)
				dok.append(Transform3D(Basis.from_euler(Vector3(rng.randf(), rng.randf() * TAU, rng.randf())).scaled(Vector3(sc * 1.2, sc * 0.7, sc)),
					Vector3(x + rng.randf_range(-1.6, 1.6), dy + sc * 0.2, zo1 + rng.randf_range(0.3, 1.8))))
		else:
			var ok := true
			for tw in itx:
				if absf(float(tw["x"]) - x) < float(tw["w"]) * 0.5 + 1.2:
					ok = false
			if ok:
				_oyuk(iz, Vector3(x, rng.randf_range(OH + 0.6, HW - 1.0), zi1), rng.randf_range(0.4, 0.8), rng)
	iz.mesh_ekle(root, _iz_mat(), "Tas_GulleIzi", false)
	if dok.size() > 0:
		Scenery.scatter(root, IstSurlar.KULE.kaya_mesh(), dok, [], IstSurlar.KULE._tas_mat(stone.darkened(0.12), 0))
	# ---- stauroma: dış sur tepesinde tahta perde, toprak dolu fıçılar (korkuluk üstünde) ve kazıklar
	var n_st := 2 + int(dmg * 2.0)
	for i in n_st:
		rng = _rr(sd, 2, i)
		var x := rng.randf_range(-L * 0.5 + 8.0, L * 0.5 - 8.0)
		if gw > 0.0 and absf(x) < gw * 0.5 + 3.0:
			continue
		if _near_tower(otx, x, float(d["OTW"]) * 0.5 + 4.5) or not IstSurlar._ic(x):
			continue
		# TUR-7: gediğin yanında kurulmaz (gedik onarımı kendi parçalarını kurar; fıçılar açıkta kalıyordu)
		var gyakin := false
		for gx in o.get("gedik", []):
			if absf(x - float(gx)) < IstSurlar.GEDIK_W * 0.5 + 6.0:
				gyakin = true
		if gyakin:
			continue
		_stauroma(root, x, zo1 - 0.225, OH + 1.2, rng)
	# ---- iskele (dış sur yüzünde): direkler, kirişler, tahta
	if otx.size() > 0:
		var sx: float = float(otx[0]) + 7.5
		if absf(sx) < L * 0.5 - 4.0 and IstSurlar._ic(sx):
			if not gedikte.call(sx):
				_scaffold(root, sx, zo1 + 0.15, OH * 0.7, dy)
	# ---- nöbetçi barınağı, taş gülle yığını ve sancak: iç kule tepelerinde
	for i in itx.size():
		rng = _rr(sd, 3, i)
		var tw: Dictionary = itx[i]
		var cx: float = tw["x"]
		if not IstSurlar._ic(cx):
			continue
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
		rng = _rr(sd, 4, j)
		var ox: float = otx[j]
		if not IstSurlar._ic(ox):
			continue
		if j % 2 == 0:
			_balls(root, ox + 0.5, d["OTH"], zo0 + 1.2, 3, rng)
		else:
			_barrel(root, Vector3(ox - 0.7, float(d["OTH"]), zo0 + float(d["OT"]) + 0.8))
	# ---- sarmaşık YOK (TUR-7 ikinci geçiş): duvar yüzüne yapışık yaprak örtüsü uzaktan yeşil dama/kutu okunuyordu ("havada
	# duran kare yeşillikler"). Sur yüzünde bitki yalnız dipte (oturtma eteğinin ot / çalı öbekleri) kalır.
	_beden(root, lay, sd, stone)
	# ---- teras bitkisi (TUR-7): ince yapraklı ot tutamı ve seyrek alçak çalı (oturtma kitinin ağları; yuvarlak/altıgen
	# küre "nilüfer yaprağı" değil). Tozlu, solgun: sur ve zeminle aynı palet.
	var otlar: Array = []
	var calilar: Array = []
	rng = _rr(sd, 6, 0)
	for i in int(L * 0.5):
		var bz: float = rng.randf_range(float(d["zo1"]) + 0.8, float(d["zm0"]) - 2.2)
		var bx := rng.randf_range(-L * 0.5 + 2.0, L * 0.5 - 2.0)
		if gw > 0.0 and absf(bx) < gw * 0.5 + 2.0 or gedikte.call(bx):
			continue
		if not IstSurlar._ic(bx):
			continue
		var s := rng.randf_range(0.8, 1.5)
		var bas := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s, s * rng.randf_range(0.7, 1.1), s))
		if i % 5 == 0:
			calilar.append(Transform3D(bas.scaled(Vector3(0.75, 0.6, 0.75)), Vector3(bx, dy - 0.06, bz)))
		else:
			otlar.append(Transform3D(bas, Vector3(bx, dy - 0.02, bz)))
			for k in 2:
				var s2 := s * rng.randf_range(0.5, 0.8)
				otlar.append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s2, s2, s2)), Vector3(bx + rng.randf_range(-0.7, 0.7), dy - 0.02, bz + rng.randf_range(-0.6, 0.6))))
	var OTA := load("res://scripts/world/ist/sur_oturtma_ag.gd")
	if otlar.size() > 0:
		Scenery.scatter(root, OTA.ot_mesh(), otlar, [], _ot_mat())
	if calilar.size() > 0:
		Scenery.scatter(root, OTA.cali_mesh(), calilar, [], _ot_mat())


static var _otm: StandardMaterial3D


## Teras otu: köşe rengi × tozlu çarpan (ot kuru, çalı solgun zeytin; fosforlu yeşil değil)
static func _ot_mat() -> StandardMaterial3D:
	if _otm == null:
		_otm = StandardMaterial3D.new()
		_otm.vertex_color_use_as_albedo = true
		_otm.albedo_color = Color(0.86, 0.82, 0.70)
		_otm.cull_mode = BaseMaterial3D.CULL_DISABLED
		_otm.roughness = 1.0
		_otm.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return _otm


static func _rr(sd: int, kind: int, i: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = sd * 131 + kind * 7919 + i * 104729
	return r


static func _near_tower(otx: Array, x: float, r: float) -> bool:
	for t in otx:
		if absf(float(t) - x) < r:
			return true
	return false


static var _iz_m: StandardMaterial3D


static func _iz_mat() -> StandardMaterial3D:
	if _iz_m == null:
		_iz_m = StandardMaterial3D.new()
		_iz_m.vertex_color_use_as_albedo = true
		_iz_m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		_iz_m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		_iz_m.roughness = 1.0
	return _iz_m


## TUR-7 gülle oyuğu (düz duvar yüzünde, +z ya da −z'ye bakan): düzensiz çokgen; içi koyu ve duvara gömük görünen kademeli
## halkalar (dış halka kırık taşın taze açık rengi, iç halka gölge, merkez is), birkaç kopmuş blok izi ve incelen çatlaklar.
## nz: yüzün dış normali (z işareti p.z'den: iç sur zi1 (+z), dış sur zo1 (+z)) — ikisi de +z'ye bakar.
static func _oyuk(ag, p: Vector3, r: float, rng: RandomNumberGenerator) -> void:
	var nrm := Vector3.BACK
	var n := 11
	var kenar: Array = []
	for k in n:
		var a := TAU * k / n + rng.randf_range(-0.2, 0.2)
		var rr := r * rng.randf_range(0.75, 1.3)
		kenar.append(Vector2(cos(a) * rr * 1.15, sin(a) * rr))
	var taze := Color(0.56, 0.52, 0.44)       # TUR-7: kırık taşın tozu, duvardan az açık (beyaz leke değil)
	var golge := Color(0.33, 0.30, 0.25)
	var is_ := Color(0.16, 0.14, 0.12)
	var halkalar := [[1.0, 0.012, taze], [0.72, 0.016, golge], [0.4, 0.02, is_]]
	for h in halkalar.size():
		var f: float = halkalar[h][0]
		var z: float = halkalar[h][1]
		var c: Color = halkalar[h][2]
		var m := Vector3(p.x, p.y - r * 0.08 * h, p.z + z)
		for k in n:
			var q0: Vector2 = kenar[k] * f
			var q1: Vector2 = kenar[(k + 1) % n] * f
			ag.tri(m, m + Vector3(q0.x, q0.y, 0), m + Vector3(q1.x, q1.y, 0), nrm, c.darkened(rng.randf_range(0.0, 0.12)))
	# kopmuş blok izleri (oyuğun kenarında 2–3 dikdörtgen taş yuvası; taze kırık tonu)
	for k in rng.randi_range(2, 3):
		var a := rng.randf_range(0, TAU)
		var c := p + Vector3(cos(a) * r * 1.2, sin(a) * r * 0.9, 0.008)
		var w := rng.randf_range(0.35, 0.6)
		var hh := w * 0.45
		ag.quad(c + Vector3(-w * 0.5, -hh * 0.5, 0), c + Vector3(w * 0.5, -hh * 0.5, 0), c + Vector3(w * 0.5, hh * 0.5, 0), c + Vector3(-w * 0.5, hh * 0.5, 0), nrm, golge.lerp(taze, 0.55))
	# çatlaklar: oyuktan dışa incelen kırık çizgiler (3 parça)
	for k in 3:
		var a := rng.randf_range(-PI, PI)
		var o := p + Vector3(cos(a) * r * 0.9, sin(a) * r * 0.8, 0.01)
		var w := 0.028
		for s in 2:
			a += rng.randf_range(-0.5, 0.5)
			var ln := rng.randf_range(0.25, 0.5) * r * 2.0
			var e := o + Vector3(cos(a) * ln, sin(a) * ln, 0)
			var t := Vector3(-sin(a), cos(a), 0)
			ag.quad(o - t * w, o + t * w, e + t * w * 0.5, e - t * w * 0.5, nrm, is_)
			o = e
			w *= 0.5


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


static func _scaffold(root: Node3D, x: float, z: float, h: float, dy := 0.0) -> void:
	# TUR-7: direkler terasın zeminine iner (dış kademe dy < 0 iken havada başlıyordu)
	for sx in [-1.0, 1.0]:
		for dz in [0.0, 1.2]:
			Props.cyl(root, 0.07, h + 1.4 - dy, Vector3(x + sx * 1.0, (h + 1.4 + dy) * 0.5, z + dz + 0.1), C_WOOD, Vector3.ZERO, 5)
	for lvl in [0.4, 0.8, 1.0]:
		Props.box(root, Vector3(2.2, 0.08, 0.1), Vector3(x, h * lvl, z + 0.1), C_WOOD.darkened(0.1))
		Props.box(root, Vector3(2.2, 0.08, 0.1), Vector3(x, h * lvl, z + 1.3), C_WOOD.darkened(0.1))
	for pz in 5:
		Props.box(root, Vector3(2.2, 0.06, 0.22), Vector3(x, h * 0.8 + 0.08, z + 0.2 + pz * 0.24), C_WOOD.lightened(0.05))
	# merdiven (iskeleye dayalı; terasa inemeyen kademede kurulmaz)
	if dy < -0.5:
		return
	Props.box(root, Vector3(0.06, h * 0.9, 0.06), Vector3(x - 0.3, h * 0.4, z + 1.6), C_WOOD, Vector3(-18, 0, 0))
	Props.box(root, Vector3(0.06, h * 0.9, 0.06), Vector3(x + 0.3, h * 0.4, z + 1.6), C_WOOD, Vector3(-18, 0, 0))
	for r in 8:
		Props.box(root, Vector3(0.62, 0.04, 0.05), Vector3(x, 0.4 + r * h * 0.1, z + 1.9 - r * h * 0.032), C_WOOD)


static func _hut(root: Node3D, x: float, y: float, z: float, rng: RandomNumberGenerator) -> void:
	# SUR-5: yuvarlak nöbetçi barınağı (kutu değil): taş dipli ahşap gövde, konik saz/kiremit çatı, karanlık kapı boşluğu
	var r := 0.95
	Props.cyl(root, r + 0.06, 0.5, Vector3(x, y + 0.25, z), Color("8a7f6c"), Vector3.ZERO, 10)
	var body := Props.cyl(root, r, 1.4, Vector3(x, y + 1.2, z), C_WOOD.lightened(0.05), Vector3.ZERO, 10)
	Props.set_pattern(body, C_WOOD.lightened(0.05), "wood")
	Props.make_solid(body, 0.9)
	var roof := Props.cyl(root, r + 0.35, 1.1, Vector3(x, y + 1.9 + 0.55, z), Color("6e5446"), Vector3.ZERO, 10, 0.05)
	roof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	var kp := Props.box(root, Vector3(0.62, 1.15, 0.05), Vector3(x, y + 0.98, z - r + 0.02), Color("15120f"))
	kp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


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



## SUR-5 (B): beden ayrıntısı ve sur üstü savunma eşyası.
##   iç sur ova yüzünde su oluğu (çıkıntılı taş oluk + altında is/yosun akıntısı), şehir yüzünde payanda (şevli taş
##   destek), ova yüzünde örülmüş eski kapı izi (tuğla kemer + farklı tonda dolgu taşı);
##   yürüme yolunda korkuluğa yaslı ok sepetleri, taş yığınları (düzensiz kaya), kazanlar (yuvarlak; zift/su), kalas
##   istifi. Görünüm yalnız (çarpışmasız: yürüme yolunu kesmez).
static func _beden(root: Node3D, lay: Dictionary, sd: int, stone: Color) -> void:
	var KULE = IstSurlar.KULE
	var d: Dictionary = lay["d"]
	var L: float = lay["L"]
	var zi0: float = d["zi0"]
	var zi1: float = d["zi1"]
	var HW: float = d["HW"]
	var itx: Array = lay["itx"]
	var gw: float = lay["gw"]
	var tas = KULE.Ag.new()
	var koyu = KULE.Ag.new()
	var tug = KULE.Ag.new()
	var dolgu = KULE.Ag.new()
	var kaya: Array = []
	for i in range(itx.size() - 1):
		var xa: float = float(itx[i]["x"]) + float(itx[i]["w"]) * 0.5
		var xb: float = float(itx[i + 1]["x"]) - float(itx[i + 1]["w"]) * 0.5
		if xb - xa < 10.0:
			continue
		var xm := (xa + xb) * 0.5
		if gw > 0.0 and absf(xm) < gw * 0.5 + 6.0:
			continue
		var rng := _rr(sd, 9, i)
		# su olukları (iki tane)
		for k in 2:
			var ox := lerpf(xa, xb, 0.3 + 0.4 * k) + rng.randf_range(-1.0, 1.0)
			if IstSurlar._ic(ox):
				tas.kutu(Vector3(ox, HW - 0.55, zi1), Vector3.RIGHT, Vector3.BACK, 0.34, 0.26, 0.7)
				koyu.quad(Vector3(ox - 0.08, HW - 0.42, zi1 + 0.71), Vector3(ox + 0.08, HW - 0.42, zi1 + 0.71), Vector3(ox + 0.08, HW - 0.3, zi1 + 0.71), Vector3(ox - 0.08, HW - 0.3, zi1 + 0.71), Vector3.BACK)
				# akıntı izi (koyu ince şerit, aşağı doğru incelir)
				var y := HW - 0.6
				var w := 0.22
				while y > 1.0 and w > 0.04:
					koyu.quad(Vector3(ox - w, y - 1.2, zi1 + 0.012), Vector3(ox + w, y - 1.2, zi1 + 0.012), Vector3(ox + w * 1.1, y, zi1 + 0.012), Vector3(ox - w * 1.1, y, zi1 + 0.012), Vector3.BACK)
					y -= 1.2
					w *= 0.78
		# payanda (şehir yüzü): şevli taş destek
		if i % 2 == 0 and IstSurlar._ic(xm):
			var pb := 1.6
			var ph := HW * 0.72
			var a0 := Vector3(xm - 0.9, 0.0, zi0)
			var a1 := Vector3(xm + 0.9, 0.0, zi0)
			var f0 := Vector3(xm - 0.9, 0.0, zi0 - pb)
			var f1 := Vector3(xm + 0.9, 0.0, zi0 - pb)
			var t0 := Vector3(xm - 0.8, ph, zi0 - 0.25)
			var t1 := Vector3(xm + 0.8, ph, zi0 - 0.25)
			var u0 := Vector3(xm - 0.8, ph, zi0)
			var u1 := Vector3(xm + 0.8, ph, zi0)
			tas.quad_auto(f0, f1, t1, t0, Vector3(0, 0.3, -1))
			tas.quad_auto(a0, f0, t0, u0, Vector3.LEFT)
			tas.quad_auto(a1, f1, t1, u1, Vector3.RIGHT)
			tas.quad(t0, t1, u1, u0, Vector3.UP)
		# örülmüş eski kapı izi (ova yüzü, dipte)
		if i % 3 == 1 and IstSurlar._ic(xm):
			var bx := xm + rng.randf_range(-3.0, 3.0)
			var r := 1.3
			var hy := 2.0
			dolgu.quad(Vector3(bx - r, 0.0, zi1 + 0.02), Vector3(bx + r, 0.0, zi1 + 0.02), Vector3(bx + r, hy, zi1 + 0.02), Vector3(bx - r, hy, zi1 + 0.02), Vector3.BACK)
			for k in 8:
				var a := PI * float(k) / 8.0
				var b := PI * float(k + 1) / 8.0
				dolgu.tri(Vector3(bx, hy, zi1 + 0.02), Vector3(bx + cos(a) * r, hy + sin(a) * r, zi1 + 0.02), Vector3(bx + cos(b) * r, hy + sin(b) * r, zi1 + 0.02), Vector3.BACK)
			for k in 9:
				var am := PI * (float(k) + 0.5) / 9.0
				var p := Vector3(bx + cos(am) * (r + 0.18), hy + sin(am) * (r + 0.18) - 0.12, zi1)
				tug.kutu(p, Vector3(-sin(am), cos(am), 0).normalized(), Vector3.BACK, 0.34, 0.26, 0.08)
			tas.kutu(Vector3(bx - r - 0.2, 0.0, zi1), Vector3.RIGHT, Vector3.BACK, 0.4, hy, 0.08)
			tas.kutu(Vector3(bx + r + 0.2, 0.0, zi1), Vector3.RIGHT, Vector3.BACK, 0.4, hy, 0.08)
		# sur üstü savunma eşyası (dış korkuluğa yaslı)
		var zp := zi1 - 0.45 - 0.45
		var ex := lerpf(xa, xb, rng.randf_range(0.2, 0.8))
		if not IstSurlar._ic(ex):
			continue
		match (i + sd) % 4:
			0:
				# taş yığını (düzensiz kaya)
				for k in 9:
					var sc := rng.randf_range(0.22, 0.42)
					kaya.append(Transform3D(Basis.from_euler(Vector3(rng.randf(), rng.randf() * TAU, rng.randf())).scaled(Vector3(sc, sc * 0.8, sc)), Vector3(ex + rng.randf_range(-0.6, 0.6), HW + sc * 0.35 + (0.25 if k > 5 else 0.0), zp + rng.randf_range(-0.3, 0.3))))
			1:
				# kazan (yuvarlak, demir) üç ayaklı ocak üstünde
				Props.ball(root, 0.42, Vector3(ex, HW + 0.62, zp), Color("2e2c2a"), Vector3(1.0, 0.7, 1.0), 10)
				Props.cyl(root, 0.44, 0.06, Vector3(ex, HW + 0.86, zp), Color("3a3634"), Vector3.ZERO, 10)
				for k in 3:
					var a := TAU * k / 3.0
					Props.cyl(root, 0.03, 0.7, Vector3(ex + cos(a) * 0.3, HW + 0.33, zp + sin(a) * 0.3), Color("2a2622"), Vector3(sin(a) * 12.0, 0, -cos(a) * 12.0), 4)
				for k in 4:
					Props.ball(root, 0.12, Vector3(ex + rng.randf_range(-0.25, 0.25), HW + 0.08, zp + rng.randf_range(-0.25, 0.25)), Color("3a2a1c"), Vector3(1.6, 0.5, 0.6), 5)
			2:
				# ok sepetleri (yuvarlak hasır) ve içinde oklar
				for k in 2:
					var bxp := ex + k * 0.7
					Props.cyl(root, 0.22, 0.75, Vector3(bxp, HW + 0.375, zp), Color("8a6a40"), Vector3.ZERO, 8, 0.26)
					for m in 5:
						Props.cyl(root, 0.012, 0.85, Vector3(bxp + rng.randf_range(-0.12, 0.12), HW + 0.95, zp + rng.randf_range(-0.12, 0.12)), Color("6a5a3a"), Vector3(rng.randf_range(-8, 8), 0, rng.randf_range(-8, 8)), 3)
			_:
				# taş gülle yığını (yuvarlak)
				for k in 7:
					var row := 0 if k < 4 else (1 if k < 6 else 2)
					Props.ball(root, 0.2, Vector3(ex + (k - (1.5 if row == 0 else (4.5 if row == 1 else 6.0))) * 0.4 + row * 0.0, HW + 0.2 + row * 0.33, zp), Color("6e6a62"), Vector3.ONE, 7)
	if kaya.size() > 0:
		Scenery.scatter(root, KULE.kaya_mesh(), kaya, [], Props.mat(stone.darkened(0.15), 0.0, false, "ashlar_far"))
	tas.mesh_ekle(root, KULE._tas_mat(stone, 0), "BedenTas")
	dolgu.mesh_ekle(root, KULE._tas_mat(stone.darkened(0.22), 0), "OrulmusKapi")
	koyu.mesh_ekle(root, Props.mat(Color("2a2620")), "BedenAkinti", false)
	tug.mesh_ekle(root, Props.mat(Color("7a4a3a"), 0.0, false, "brick"), "BedenTugla")
