class_name IstKemerSu
extends RefCounted
## Valens (Bozdoğan) Su Kemeri. Ana eksen yerelde x boyunca kurulur, kök düğüm 90° döner (yon_derece = 0 iken eksen
## kuzey-güney, -z). İki katlı kemerler (orta bölümde), uçlarda tek katlı ve alçak; altından geçilir, üstünde yürünür.
## k yalnız kütleyi ölçekler; geçit genişliği (≥ 3,6 m), kemer altı (≥ 4,2 m), basamak (0,28 m), korkuluk (1,1 m),
## yürüme yolu (1,5 m) sabittir.

const KIT := preload("res://scripts/world/ist/kemer_kit.gd")

const LEN_REAL := 970.0
const H_REAL := 29.0
const DECK_W := 5.9
const SLAB_T := 1.6
const H_END := 5.5


static func params(k: float, uzunluk := -1.0) -> Dictionary:
	var pw := maxf(3.0 * k, 1.7)
	var ow := maxf(5.0 * k, 3.6)
	var bay := pw + ow
	var L := (uzunluk if uzunluk > 0.0 else LEN_REAL) * k
	var n := clampi(int(round(L / bay)), 10, 150)
	var depth := maxf(4.0 * k, 2.8)
	var hmax := maxf(H_REAL * k, 10.5)
	return {"pw": pw, "ow": ow, "bay": bay, "n": n, "L": n * bay, "depth": depth, "hmax": hmax}


## Eksen boyunca u (0..1) noktasındaki gerçek yükseklik (kemer altı kenarı)
static func h_at(p: Dictionary, u: float) -> float:
	var bump := pow(sin(PI * clampf(u, 0.0, 1.0)), 0.7)
	return H_END + (p["hmax"] - H_END) * bump


static func deck_top(p: Dictionary, u: float) -> float:
	return h_at(p, u) + 1.0


## Yerel x konumundan (orta = 0) yüzeyin üst yüksekliği
static func top_at_x(p: Dictionary, x: float) -> float:
	return deck_top(p, (x + p["L"] * 0.5) / p["L"])


static func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, nrm: Vector3) -> void:
	var n := (b - a).cross(c - a)
	var pts := [a, b, c, a, c, d]
	if n.dot(nrm) < 0.0:
		pts = [a, c, b, a, d, c]
	for v: Vector3 in pts:
		st.set_normal(nrm)
		st.add_vertex(v)


## Bir kat: bay genişliğinde, h yüksekliğinde, depth kalınlığında; sh = yarım daire yayının başladığı yükseklik.
static func bay_mesh(bay: float, ow: float, h: float, depth: float, sh: float, segs: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var r := ow * 0.5
	var hd := depth * 0.5
	var hb := bay * 0.5
	var cs := Vector3.BACK
	for side in [1.0, -1.0]:
		var z: float = hd * side
		var nrm: Vector3 = cs * side
		# iki pilye yarısı
		for sx in [-1.0, 1.0]:
			var x0: float = r * sx
			var x1: float = hb * sx
			_quad(st, Vector3(x0, 0, z), Vector3(x1, 0, z), Vector3(x1, h, z), Vector3(x0, h, z), nrm)
		# kemer üstü şeritler
		for i in segs:
			var t0 := PI * i / segs
			var t1 := PI * (i + 1) / segs
			var xa := r * cos(t0)
			var xb := r * cos(t1)
			var ya := sh + r * sin(t0)
			var yb := sh + r * sin(t1)
			_quad(st, Vector3(xa, ya, z), Vector3(xb, yb, z), Vector3(xb, h, z), Vector3(xa, h, z), nrm)
	# kemer içi
	for i in segs:
		var t0 := PI * i / segs
		var t1 := PI * (i + 1) / segs
		var a := Vector3(r * cos(t0), sh + r * sin(t0), hd)
		var b := Vector3(r * cos(t1), sh + r * sin(t1), hd)
		var c := Vector3(r * cos(t1), sh + r * sin(t1), -hd)
		var d := Vector3(r * cos(t0), sh + r * sin(t0), -hd)
		var mid := (a + b) * 0.5
		_quad(st, a, b, c, d, (Vector3(0, sh, mid.z) - mid).normalized())
	# dik yan yüzler
	for sx in [-1.0, 1.0]:
		_quad(st, Vector3(r * sx, 0, hd), Vector3(r * sx, sh, hd), Vector3(r * sx, sh, -hd), Vector3(r * sx, 0, -hd), Vector3(-sx, 0, 0))
	return st.commit()


static func _box_shape(size: Vector3) -> BoxShape3D:
	var b := BoxShape3D.new()
	b.size = size
	return b


static func _add_shape(body: StaticBody3D, shape: Shape3D, pos: Vector3, rot := Vector3.ZERO) -> void:
	var cs := CollisionShape3D.new()
	cs.shape = shape
	cs.position = pos
	cs.rotation = rot
	body.add_child(cs)


static func _wedge(depth: float, r: float, sh: float, sx: float) -> ConvexPolygonShape3D:
	var pts2 := [Vector2(r, sh), Vector2(r * 0.707, sh + r * 0.707), Vector2(0, sh + r), Vector2(r, sh + r)]
	var pts := PackedVector3Array()
	for z in [-depth * 0.5, depth * 0.5]:
		for q: Vector2 in pts2:
			pts.append(Vector3(q.x * sx, q.y, z))
	var cp := ConvexPolygonShape3D.new()
	cp.points = pts
	return cp


static func build_bozdogan(host: Node3D, k: float = 0.5, lod: int = 0, uzunluk := -1.0) -> void:
	var p := params(k, uzunluk)
	var root := Node3D.new()
	root.name = "Bozdogan"
	root.rotation_degrees.y = 90.0
	host.add_child(root)
	var pw: float = p["pw"]
	var ow: float = p["ow"]
	var bay: float = p["bay"]
	var n: int = p["n"]
	var L: float = p["L"]
	var depth: float = p["depth"]
	var segs := 8 if lod == 0 else 4
	var stone := KIT.STONE
	var mat_arch := Props.mat(Color("d6bf94"), 0.0, false, "ashlar", false)
	var mat_arch2 := Props.mat(Color("c4a97c"), 0.0, false, "ashlar", false)
	var body := StaticBody3D.new()
	body.name = "Katı"
	root.add_child(body)
	# sınıf başına MultiMesh listeleri
	if lod >= 1:
		_build_far(root, p, lod)
		return
	var tier1: Dictionary = {}     # (h1 -> [xforms])
	var tier2: Dictionary = {}
	var slab_x: Array = []
	var rail_x: Array = []
	var cap_x: Array = []
	for i in n:
		var xc := -L * 0.5 + bay * (i + 0.5)
		var u := (i + 0.5) / n
		var hq := roundf(h_at(p, u))
		var two := hq >= 10.0
		var h1 := maxf(5.5, roundf(hq * 0.58)) if two else hq
		var h2 := hq - h1
		var sh1 := h1 - 1.3 - ow * 0.5
		var key1 := "%d|%d" % [int(h1), int(sh1 * 10)]
		if not tier1.has(key1):
			tier1[key1] = [bay_mesh(bay, ow, h1, depth, sh1, segs), []]
		tier1[key1][1].append(Transform3D(Basis.IDENTITY, Vector3(xc, 0, 0)))
		var r := ow * 0.5
		# çarpışma: pilye yarıları
		for sx in [-1.0, 1.0]:
			_add_shape(body, _box_shape(Vector3(pw * 0.5, hq, depth)), Vector3(xc + sx * (r + pw * 0.25), hq * 0.5, 0))
		if lod == 0:
			_add_shape(body, _wedge(depth, r, sh1, 1.0), Vector3(xc, 0, 0))
			_add_shape(body, _wedge(depth, r, sh1, -1.0), Vector3(xc, 0, 0))
			if two:
				_add_shape(body, _box_shape(Vector3(ow, h1 - (sh1 + r), depth)), Vector3(xc, (h1 + sh1 + r) * 0.5, 0))
				var sh2 := h2 - 1.2 - r
				var key2 := "%d|%d" % [int(h2), int(sh2 * 10)]
				if not tier2.has(key2):
					tier2[key2] = [bay_mesh(bay, ow, h2, depth, sh2, segs), []]
				tier2[key2][1].append(Transform3D(Basis.IDENTITY, Vector3(xc, h1, 0)))
				_add_shape(body, _wedge(depth, r, h1 + sh2, 1.0), Vector3(xc, 0, 0))
				_add_shape(body, _wedge(depth, r, h1 + sh2, -1.0), Vector3(xc, 0, 0))
				_add_shape(body, _box_shape(Vector3(ow, h2 - (sh2 + r), depth)), Vector3(xc, h1 + (h2 + sh2 + r) * 0.5, 0))
			else:
				_add_shape(body, _box_shape(Vector3(ow, h1 - (sh1 + r), depth)), Vector3(xc, (h1 + sh1 + r) * 0.5, 0))
		elif two:
			var sh2b := h2 - 1.2 - r
			var key2b := "%d|%d" % [int(h2), int(sh2b * 10)]
			if not tier2.has(key2b):
				tier2[key2b] = [bay_mesh(bay, ow, h2, depth, sh2b, segs), []]
			tier2[key2b][1].append(Transform3D(Basis.IDENTITY, Vector3(xc, h1, 0)))
		# döşeme levhası: iki pilye hattı arasında eğimli
		var ya := deck_top(p, float(i) / n)
		var yb := deck_top(p, float(i + 1) / n)
		var ang := atan2(yb - ya, bay)
		var ymid := (ya + yb) * 0.5
		var slab_len := bay / cos(ang) + 0.2
		var center := Vector3(xc, ymid - SLAB_T * 0.5 / cos(ang), 0)
		slab_x.append([center, ang, slab_len])
	# Katlar (görsel)
	for key: String in tier1:
		KIT.multi(root, tier1[key][0], mat_arch, tier1[key][1])
	for key: String in tier2:
		KIT.multi(root, tier2[key][0], mat_arch2, tier2[key][1])
	_deck(root, body, p, slab_x, lod)
	_ends(root, p, lod)
	if lod == 0:
		_details(root, p)


static func _deck(root: Node3D, body: StaticBody3D, p: Dictionary, slabs: Array, lod: int) -> void:
	var bay: float = p["bay"]
	var depth: float = p["depth"]
	var w := DECK_W
	var slab_mesh := BoxMesh.new()
	slab_mesh.size = Vector3(1.0, SLAB_T, w)
	var xs: Array = []
	var rail_mesh := BoxMesh.new()
	rail_mesh.size = Vector3(1.0, 1.1, 0.5)
	var rails: Array = []
	var cap_mesh := BoxMesh.new()
	cap_mesh.size = Vector3(1.0, 0.6, 1.9)
	var caps: Array = []
	for s: Array in slabs:
		var c: Vector3 = s[0]
		var ang: float = s[1]
		var ln: float = s[2]
		var b := Basis.from_euler(Vector3(0, 0, ang))
		xs.append(Transform3D(b.scaled(Vector3(ln, 1, 1)), c))
		_add_shape(body, _box_shape(Vector3(ln, SLAB_T, w)), c, Vector3(0, 0, ang))
		var up := b * Vector3(0, SLAB_T * 0.5 + 0.55, 0)
		for sz in [-1.0, 1.0]:
			var rp: Vector3 = c + up + Vector3(0, 0, sz * (w * 0.5 - 0.25))
			rails.append(Transform3D(b.scaled(Vector3(ln, 1, 1)), rp))
			_add_shape(body, _box_shape(Vector3(ln, 1.1, 0.5)), rp, Vector3(0, 0, ang))
		var cp: Vector3 = c + b * Vector3(0, SLAB_T * 0.5 + 0.3, 0)
		caps.append(Transform3D(b.scaled(Vector3(ln, 1, 1)), cp))
		_add_shape(body, _box_shape(Vector3(ln, 0.6, 1.9)), cp, Vector3(0, 0, ang))
	KIT.multi(root, slab_mesh, Props.mat(Color("cbb68c"), 0.0, false, "ashlar", false), xs)
	KIT.multi(root, rail_mesh, Props.mat(Color("d9c69e"), 0.0, false, "ashlar", false), rails)
	KIT.multi(root, cap_mesh, Props.mat(Color("bfa982"), 0.0, false, "flagstone", false), caps)


## Uçlar: kapak duvarı, taş merdiven (zeminden köprü üstüne), kenar duvarları
static func _ends(root: Node3D, p: Dictionary, lod: int) -> void:
	var L: float = p["L"]
	var depth: float = p["depth"]
	var topv := deck_top(p, 0.0)
	var n_steps := int(ceil(topv / 0.28))
	var rise := topv / n_steps
	var run := 0.5
	for e in [-1.0, 1.0]:
		var xe: float = e * (L * 0.5 + 0.3)
		var cap := KIT.blk(root, Vector3(0.6, topv + 0.0, DECK_W), Vector3(xe, 0, 0), KIT.STONE, "ashlar")
		# merdiven: dıştan kapağa doğru yükselir
		var base := Vector3(xe + e * (0.3 + run * n_steps), 0, 0)
		KIT.stairs(root, base, Vector3(-e, 0, 0), n_steps, rise, run, 2.4, Color("cdb88e"))
		# merdiven korkulukları (alçak yan duvar)
		for sz in [-1.0, 1.0]:
			var wall := KIT.blk(root, Vector3(run * n_steps, 0.5, 0.4), Vector3(xe + e * (0.3 + run * n_steps * 0.5), 0, sz * 1.4), KIT.STONE_D, "ashlar")
			wall.position.y += 0.0
			# eğimli taş sırt: basamak çizgisini izleyen eğik kiriş (görsel)
		if lod == 0:
			pass


static func _details(root: Node3D, p: Dictionary) -> void:
	var L: float = p["L"]
	var bay: float = p["bay"]
	var n: int = p["n"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	# Hava bacaları (su yolu üstünde, her 12 bayda): 1,2 × 1,2 × 2,2 taş baca, tepesi kiremit kapaklı
	var i := 6
	while i < n:
		var xc := -L * 0.5 + bay * (i + 0.5)
		var top := top_at_x(p, xc)
		var b := KIT.blk(root, Vector3(1.2, 2.0, 1.2), Vector3(xc, top + 0.6, 0), KIT.STONE, "ashlar")
		Props.make_solid(Props.prism(root, Vector3(1.6, 0.5, 1.6), Vector3(xc, top + 0.6 + 2.25, 0), KIT.TILE))
		Props.box(root, Vector3(0.3, 0.5, 0.05), Vector3(xc, top + 0.6 + 1.0, 0.61), KIT.DARK)
		i += 12
	# Ot ve yosun tutamları, pilye diplerinde; birkaç incir kökü
	for j in range(2, n, 5):
		var xc := -L * 0.5 + bay * (j + 0.5)
		var top := top_at_x(p, xc)
		var side := 1.0 if rng.randf() > 0.5 else -1.0
		Props.box(root, Vector3(rng.randf_range(0.8, 1.6), 0.12, 0.7), Vector3(xc + rng.randf_range(-1, 1), top + 0.07, side * (DECK_W * 0.5 - 1.0)), KIT.MOSS)


## Uzak LOD: kalın duvar parçaları + koyu kemer dörtgenleri + eğimli döşeme (çarpışmasız)
static func _build_far(root: Node3D, p: Dictionary, lod: int) -> void:
	var n: int = p["n"]
	var bay: float = p["bay"]
	var L: float = p["L"]
	var depth: float = p["depth"]
	var ow: float = p["ow"]
	var g := 4 if lod == 1 else maxi(8, int(ceil(n / 9.0)))
	var wall_mat := Props.mat(Color("d2bc92"), 0.0, false, "", false)
	var deck_mat := Props.mat(Color("c4ad84"), 0.0, false, "", false)
	var walls: Array = []
	var decks: Array = []
	var i := 0
	while i < n:
		var m := mini(g, n - i)
		var x0 := -L * 0.5 + bay * i
		var x1 := -L * 0.5 + bay * (i + m)
		var u := (i + m * 0.5) / n
		var h := h_at(p, u)
		walls.append(Transform3D(Basis.from_scale(Vector3(x1 - x0, h, depth)), Vector3((x0 + x1) * 0.5, h * 0.5, 0)))
		var ya := deck_top(p, float(i) / n)
		var yb := deck_top(p, float(i + m) / n)
		var ang := atan2(yb - ya, x1 - x0)
		var ln := (x1 - x0) / cos(ang) + 0.2
		decks.append(Transform3D(Basis.from_euler(Vector3(0, 0, ang)).scaled(Vector3(ln, SLAB_T + 1.1, DECK_W)), Vector3((x0 + x1) * 0.5, (ya + yb) * 0.5 - (SLAB_T - 1.1) * 0.5 - 0.3, 0)))
		i += m
	var unit := BoxMesh.new()
	unit.size = Vector3.ONE
	KIT.multi(root, unit, wall_mat, walls)
	KIT.multi(root, unit, deck_mat, decks)
	# koyu kemer ağızları (iki yüz)
	var q := QuadMesh.new()
	q.size = Vector2(ow, 1.0)
	var holes: Array = []
	var step := 1 if lod == 1 else 4
	var j := 0
	while j < n:
		var xc := -L * 0.5 + bay * (j + 0.5)
		var hq := roundf(h_at(p, (j + 0.5) / n))
		var two := hq >= 10.0
		var h1 := maxf(5.5, roundf(hq * 0.58)) if two else hq
		var tiers := [[0.0, h1 - 1.3]]
		if two and lod == 1:
			tiers.append([h1, hq - 1.2])
		for t: Array in tiers:
			var hh: float = t[1] - t[0]
			for sz in [-1.0, 1.0]:
				var b := Basis.from_scale(Vector3(1.0, hh, 1.0))
				if sz < 0:
					b = Basis.from_euler(Vector3(0, PI, 0)).scaled(Vector3(1.0, hh, 1.0))
				holes.append(Transform3D(b, Vector3(xc, t[0] + hh * 0.5, sz * (depth * 0.5 + 0.02))))
		j += step
	KIT.multi(root, q, Props.mat(Color("5a4a3a"), 0.0, false, "", false), holes)
