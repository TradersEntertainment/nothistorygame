class_name Dressing
extends RefCounted
## Sokak ve manzara dolgusu (kullanıcı isteği: "boş alan olmasın, gerçekçi olsun").
## Yüzlerce küçük parça (sandık, fıçı, küp, sepet, araba, kuyu, odun, saksı, sundurma...) tek tek
## MeshInstance yerine bölge bölge TEK bir ağ örgüsünde birleştirilir (köşe renkli, toon, dış hatlı):
## birkaç çizim çağrısı, binlerce parça.
##
## Kullanım:
##   var d := Dressing.new(seed)
##   d.at(pos, yaw).barrel(Vector3.ZERO)       # yerel çerçeve: +z duvardan dışarı / yüzün baktığı yön
##   d.build(parent)
## Ya da otomatik: Dressing.auto(level, {rect, reserved, style, ...}) — fizik ışınlarıyla duvar diplerini ve
## açık meydanları bulur, stile göre (byz, galata, camp) kümeler yerleştirir, yürüyen halk ekler.

const CHUNK := 24.0

var rng := RandomNumberGenerator.new()
var _frame := Transform3D.IDENTITY
var _chunks := {}          # "x|z|glow" -> {v, n, c}
var _shapes: Array = []    # [Transform3D, Vector3 boyut]
static var _prims := {}    # ilkel ağ örgüleri (üçgen listesi): anahtar -> [köşeler, normaller]
static var _mat: StandardMaterial3D
static var _glow_mat: StandardMaterial3D


func _init(seed := 1) -> void:
	rng.seed = seed


## Yerel çerçeveyi ayarlar: sonraki parçalar bu konuma ve dönüşe göre yerleşir.
func at(pos: Vector3, yaw := 0.0) -> Dressing:
	_frame = Transform3D(Basis(Vector3.UP, yaw), pos)
	return self


# ---------------------------------------------------------------- ilkel parçalar

static func _prim(key: String) -> Array:
	if _prims.has(key):
		return _prims[key]
	var m: Mesh
	var parts := key.split(":")
	match parts[0]:
		"box":
			var b := BoxMesh.new()
			b.size = Vector3.ONE
			m = b
		"cyl":
			var c := CylinderMesh.new()
			c.bottom_radius = 1.0
			c.top_radius = float(parts[2])
			c.height = 1.0
			c.radial_segments = int(parts[1])
			c.rings = 1
			m = c
		"ball":
			var s := SphereMesh.new()
			s.radius = 1.0
			s.height = 2.0
			s.radial_segments = int(parts[1])
			s.rings = maxi(3, int(parts[1]) / 2)
			m = s
		"prism":
			var p := PrismMesh.new()
			p.size = Vector3.ONE
			m = p
	var arr := m.surface_get_arrays(0)
	var sv: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var sn: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
	var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	if idx.is_empty():
		v = sv
		n = sn
	else:
		v.resize(idx.size())
		n.resize(idx.size())
		for i in idx.size():
			v[i] = sv[idx[i]]
			n[i] = sn[idx[i]]
	_prims[key] = [v, n]
	return _prims[key]


func _add(key: String, local: Transform3D, color: Color, glow := false) -> void:
	var prim := _prim(key)
	var xf := _frame * local
	var nb := Transform3D(xf.basis.inverse().transposed(), Vector3.ZERO)
	var ck := "%d|%d|%s" % [floori(xf.origin.x / CHUNK), floori(xf.origin.z / CHUNK), glow]
	if not _chunks.has(ck):
		_chunks[ck] = {"v": PackedVector3Array(), "n": PackedVector3Array(), "c": PackedColorArray(), "glow": glow}
	var c: Dictionary = _chunks[ck]
	var verts: PackedVector3Array = prim[0]
	c["v"].append_array(xf * verts)
	c["n"].append_array(nb * (prim[1] as PackedVector3Array))
	var cols := PackedColorArray()
	cols.resize(verts.size())
	cols.fill(color)
	c["c"].append_array(cols)


static func _xf(pos: Vector3, size: Vector3, rot_deg := Vector3.ZERO) -> Transform3D:
	var r := rot_deg * (PI / 180.0)
	return Transform3D(Basis.from_euler(r) * Basis.from_scale(size), pos)


func box(size: Vector3, pos: Vector3, color: Color, rot := Vector3.ZERO) -> void:
	_add("box", _xf(pos, size, rot), color)


func cyl(r: float, h: float, pos: Vector3, color: Color, rot := Vector3.ZERO, seg := 8, top := 1.0) -> void:
	_add("cyl:%d:%.2f" % [seg, top], _xf(pos, Vector3(r, h, r), rot), color)


func ball(r: float, pos: Vector3, color: Color, scl := Vector3.ONE, seg := 8) -> void:
	_add("ball:%d" % seg, _xf(pos, scl * r), color)


func prism(size: Vector3, pos: Vector3, color: Color, rot := Vector3.ZERO) -> void:
	_add("prism", _xf(pos, size, rot), color)


func glow(size: Vector3, pos: Vector3, color: Color) -> void:
	_add("box", _xf(pos, size), color, true)


## Çarpışma kutusu (yerel çerçevede).
func solid(size: Vector3, pos: Vector3, yaw_deg := 0.0) -> void:
	_shapes.append([_frame * Transform3D(Basis(Vector3.UP, deg_to_rad(yaw_deg)), pos), size])


## Birleşik ağ örgülerini ve çarpışmayı sahneye ekler.
func build(parent: Node3D) -> Node3D:
	var root := Node3D.new()
	root.name = "Dressing"
	parent.add_child(root)
	for k in _chunks:
		var c: Dictionary = _chunks[k]
		if (c["v"] as PackedVector3Array).is_empty():
			continue
		var arr := []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = c["v"]
		arr[Mesh.ARRAY_NORMAL] = c["n"]
		arr[Mesh.ARRAY_COLOR] = c["c"]
		var am := ArrayMesh.new()
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
		var mi := MeshInstance3D.new()
		mi.mesh = am
		mi.material_override = _glow_material() if c["glow"] else _material()
		if c["glow"]:
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(mi)
	if not _shapes.is_empty():
		var body := StaticBody3D.new()
		root.add_child(body)
		for s in _shapes:
			var cs := CollisionShape3D.new()
			var bs := BoxShape3D.new()
			bs.size = s[1]
			cs.shape = bs
			cs.transform = s[0]
			body.add_child(cs)
	_chunks.clear()
	_shapes.clear()
	return root


static func _material() -> StandardMaterial3D:
	if _mat == null:
		_mat = StandardMaterial3D.new()
		_mat.vertex_color_use_as_albedo = true
		_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		_mat.specular_mode = BaseMaterial3D.SPECULAR_TOON
		_mat.roughness = 0.9
		_mat.metallic_specular = 0.2
		_mat.rim_enabled = true
		_mat.rim = 0.2
		_mat.rim_tint = 0.6
		if Props.outlines:
			_mat.next_pass = Props._outline_mat()
	return _mat


static func _glow_material() -> StandardMaterial3D:
	if _glow_mat == null:
		_glow_mat = StandardMaterial3D.new()
		_glow_mat.vertex_color_use_as_albedo = true
		_glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return _glow_mat


# ---------------------------------------------------------------- renkler

const WOOD := [Color("8a6440"), Color("7a5432"), Color("9a7248"), Color("6b4a2e")]
const CLAY := [Color("b8683a"), Color("c87a4a"), Color("a85a32"), Color("d0905a")]
const FRUIT := [Color("d83a2a"), Color("e8a020"), Color("f0d040"), Color("6a2a5a"), Color("8ab840"), Color("e86a2a")]
const CLOTH := [Color("b3262d"), Color("2f5fa8"), Color("d8b040"), Color("3a6b3a"), Color("e8e0cc"), Color("6a3a7a"), Color("c86a3a")]
const STONE := [Color("a8a090"), Color("989080"), Color("b8b0a0"), Color("8a8478")]


func _pick(a: Array) -> Color:
	return a[rng.randi() % a.size()]


# ---------------------------------------------------------------- parça kütüphanesi (yerel koordinat)

func crate(p: Vector3, s := 0.6, yaw := 0.0) -> void:
	var w := _pick(WOOD)
	box(Vector3(s, s, s), p + Vector3(0, s / 2.0, 0), w, Vector3(0, yaw, 0))
	for k in 2:
		box(Vector3(s + 0.02, 0.06, s + 0.02), p + Vector3(0, 0.08 + k * (s - 0.16), 0), w.darkened(0.25), Vector3(0, yaw, 0))


func crates(p: Vector3) -> void:
	var n := rng.randi_range(2, 4)
	for i in n:
		var s := rng.randf_range(0.45, 0.7)
		var q := p + Vector3(rng.randf_range(-0.5, 0.5), 0, rng.randf_range(0.0, 0.4))
		if i == n - 1 and n > 2:
			q = p + Vector3(0, 0.62, 0.2)
		crate(q, s, rng.randf_range(-15, 15))
	solid(Vector3(1.4, 1.2, 1.0), Vector3(0, 0.6, 0.35))


func barrel(p: Vector3, tip := false) -> void:
	var w := _pick(WOOD)
	var rot := Vector3(90, rng.randf_range(0, 180), 0) if tip else Vector3.ZERO
	var c := p + (Vector3(0, 0.3, 0) if tip else Vector3(0, 0.42, 0))
	cyl(0.3, 0.84, c, w, rot, 10, 1.0)
	for k in [-0.26, 0.26]:
		var off := Basis.from_euler(rot * (PI / 180.0)) * Vector3(0, k, 0)
		cyl(0.315, 0.06, c + off, Color("3a3634"), rot, 10, 1.0)


func barrels(p: Vector3) -> void:
	for i in rng.randi_range(2, 3):
		barrel(p + Vector3(-0.4 + i * 0.66, 0, rng.randf_range(0.0, 0.3)))
	if rng.randf() < 0.4:
		barrel(p + Vector3(0.2, 0, 1.0), true)
	solid(Vector3(1.8, 0.9, 0.9), Vector3(0.2, 0.45, 0.35))


func amphora(p: Vector3, tilt := 0.0) -> void:
	var c := _pick(CLAY)
	var rot := Vector3(tilt, 0, 0)
	ball(0.22, p + Vector3(0, 0.42, 0), c, Vector3(1, 1.5, 1))
	cyl(0.08, 0.26, p + Vector3(0, 0.86, 0), c, rot, 7, 0.8)
	cyl(0.11, 0.05, p + Vector3(0, 0.99, 0), c.darkened(0.1), rot, 7)
	for s in [-1, 1]:
		box(Vector3(0.03, 0.2, 0.05), p + Vector3(s * 0.12, 0.84, 0), c.darkened(0.1), Vector3(0, 0, s * 25))


func amphorae(p: Vector3) -> void:
	for i in rng.randi_range(2, 4):
		amphora(p + Vector3(-0.5 + i * 0.42, 0, rng.randf_range(0.0, 0.25)))
	solid(Vector3(1.6, 0.9, 0.6), Vector3(0.1, 0.45, 0.15))


func basket(p: Vector3, fill := Color.TRANSPARENT) -> void:
	cyl(0.28, 0.3, p + Vector3(0, 0.15, 0), Color("b8904a"), Vector3.ZERO, 9, 1.15)
	cyl(0.33, 0.04, p + Vector3(0, 0.3, 0), Color("9a7438"), Vector3.ZERO, 9)
	var f := fill if fill.a > 0.0 else _pick(FRUIT)
	for k in 6:
		var a := k * TAU / 6.0 + rng.randf()
		ball(0.08, p + Vector3(cos(a) * 0.15, 0.33 + (k % 2) * 0.04, sin(a) * 0.15), f)
	ball(0.08, p + Vector3(0, 0.4, 0), f.lightened(0.1))


func sack(p: Vector3) -> void:
	var c := Color("c8b48a").darkened(rng.randf_range(0.0, 0.2))
	ball(0.3, p + Vector3(0, 0.3, 0), c, Vector3(1, 1.1, 0.85))
	cyl(0.1, 0.14, p + Vector3(0, 0.66, 0), c, Vector3.ZERO, 6, 0.6)
	cyl(0.07, 0.04, p + Vector3(0, 0.6, 0), Color("5a4028"), Vector3.ZERO, 6)


func sacks(p: Vector3) -> void:
	for i in rng.randi_range(2, 4):
		sack(p + Vector3(-0.5 + i * 0.45, 0, rng.randf_range(0.0, 0.3)))
	solid(Vector3(1.6, 0.8, 0.8), Vector3(0.2, 0.4, 0.3))


func bench(p: Vector3) -> void:
	var w := _pick(WOOD)
	box(Vector3(1.6, 0.08, 0.4), p + Vector3(0, 0.45, 0.25), w)
	for s in [-0.65, 0.65]:
		box(Vector3(0.08, 0.45, 0.35), p + Vector3(s, 0.22, 0.25), w.darkened(0.2))
	solid(Vector3(1.6, 0.5, 0.45), Vector3(0, 0.25, 0.25))


func cart(p: Vector3) -> void:
	var w := _pick(WOOD)
	box(Vector3(1.2, 0.12, 2.0), p + Vector3(0, 0.7, 0), w)
	for s in [-0.6, 0.6]:
		box(Vector3(0.06, 0.35, 2.0), p + Vector3(s, 0.9, 0), w.darkened(0.15))
		cyl(0.45, 0.08, p + Vector3(s * 1.12, 0.45, -0.2), w.darkened(0.3), Vector3(0, 0, 90), 10)
		cyl(0.08, 0.1, p + Vector3(s * 1.15, 0.45, -0.2), Color("3a3634"), Vector3(0, 0, 90), 6)
		box(Vector3(0.06, 0.06, 1.6), p + Vector3(s * 0.4, 0.62, 1.6), w.darkened(0.1), Vector3(-10, 0, 0))
	var load := rng.randi() % 3
	for k in 3:
		match load:
			0:
				sack(p + Vector3(-0.3 + k * 0.3, 0.76, -0.4 + (k % 2) * 0.6))
			1:
				box(Vector3(0.4, 0.4, 0.4), p + Vector3(-0.3 + k * 0.3, 0.96, -0.4 + (k % 2) * 0.6), _pick(WOOD))
			_:
				cyl(0.12, 1.0, p + Vector3(-0.3 + k * 0.3, 0.9, 0), Color("8a6440"), Vector3(90, 0, 0), 6)
	solid(Vector3(1.4, 1.1, 2.2), Vector3(0, 0.55, 0))


func well(p: Vector3) -> void:
	var s := _pick(STONE)
	cyl(0.9, 0.8, p + Vector3(0, 0.4, 0), s, Vector3.ZERO, 12)
	cyl(0.72, 0.02, p + Vector3(0, 0.81, 0), Color("2a3a44"), Vector3.ZERO, 12)
	cyl(0.95, 0.1, p + Vector3(0, 0.82, 0), s.lightened(0.1), Vector3.ZERO, 12)
	for sx in [-0.8, 0.8]:
		box(Vector3(0.12, 1.8, 0.12), p + Vector3(sx, 1.6, 0), Color("6b4a2e"))
	cyl(0.08, 1.7, p + Vector3(0, 2.2, 0), Color("5a3a22"), Vector3(0, 0, 90), 6)
	prism(Vector3(2.0, 0.7, 1.2), p + Vector3(0, 2.85, 0), Color("a8483a"))
	cyl(0.14, 0.22, p + Vector3(0.2, 1.3, 0), Color("6b4a2e"), Vector3.ZERO, 8)
	box(Vector3(0.01, 0.9, 0.01), p + Vector3(0.2, 1.85, 0), Color("3a3a3a"))
	solid(Vector3(1.9, 1.0, 1.9), Vector3(0, 0.5, 0))


func trough(p: Vector3) -> void:
	var s := _pick(STONE)
	box(Vector3(1.8, 0.5, 0.6), p + Vector3(0, 0.25, 0.3), s)
	box(Vector3(1.6, 0.02, 0.44), p + Vector3(0, 0.46, 0.3), Color("4a7a9a"))
	solid(Vector3(1.8, 0.5, 0.6), Vector3(0, 0.25, 0.3))


func firewood(p: Vector3) -> void:
	for row in 3:
		for k in 5 - row:
			cyl(0.1, 1.1, p + Vector3(-0.4 + k * 0.2 + row * 0.1, 0.1 + row * 0.18, 0.3), Color("7a5a3a").darkened(rng.randf() * 0.2), Vector3(90, rng.randf_range(-6, 6), 0), 6)
	box(Vector3(0.9, 0.06, 0.06), p + Vector3(0, 0.3, 0.86), Color("6b4a2e"))
	solid(Vector3(1.1, 0.6, 1.1), Vector3(0, 0.3, 0.3))


func pot_plant(p: Vector3, big := false) -> void:
	var s := 1.6 if big else 1.0
	cyl(0.16 * s, 0.28 * s, p + Vector3(0, 0.14 * s, 0), _pick(CLAY), Vector3.ZERO, 8, 1.25)
	ball(0.22 * s, p + Vector3(0, 0.38 * s, 0), Color("4a7a3a").darkened(rng.randf() * 0.2), Vector3(1, 0.9, 1))
	if rng.randf() < 0.6:
		var fc: Color = [Color("d83a4a"), Color("f0d040"), Color("f0f0f0"), Color("c86ad8")][rng.randi() % 4]
		for k in 3:
			ball(0.05 * s, p + Vector3(-0.1 + k * 0.1, 0.52 * s, 0.1 * s), fc)


func pots(p: Vector3) -> void:
	for i in rng.randi_range(2, 3):
		pot_plant(p + Vector3(-0.4 + i * 0.45, 0, 0.2), i == 0)


## Duvara yaslı sundurma (tente): iki direk, eğimli bez.
func awning(width: float, height: float, color: Color) -> void:
	box(Vector3(width, 0.04, 1.3), Vector3(0, height, 0.6), color, Vector3(-14, 0, 0))
	for k in int(width / 0.5):
		box(Vector3(0.25, 0.14, 0.02), Vector3(-width / 2.0 + 0.25 + k * 0.5, height - 0.23, 1.25), color.darkened(0.15) if k % 2 else color)
	for s in [-1, 1]:
		cyl(0.035, height - 0.15, Vector3(s * (width / 2.0 - 0.1), (height - 0.15) / 2.0, 1.2), Color("5a3a22"), Vector3.ZERO, 5)


## Duvarda sarmaşık.
func ivy(width: float, height: float) -> void:
	for k in int(width * height * 5.0):
		var q := Vector3(rng.randf_range(-width / 2.0, width / 2.0), rng.randf_range(0.2, height) * sqrt(rng.randf()), 0.04)
		ball(rng.randf_range(0.12, 0.24), q, Color("3a6a2e").lightened(rng.randf() * 0.15), Vector3(1, 1, 0.3), 6)


func wall_lantern(h := 2.5) -> void:
	box(Vector3(0.05, 0.05, 0.4), Vector3(0, h + 0.15, 0.2), Color("2a2a2a"))
	prism(Vector3(0.24, 0.1, 0.24), Vector3(0, h + 0.15, 0.38), Color("2a2a2a"))
	box(Vector3(0.22, 0.04, 0.22), Vector3(0, h - 0.2, 0.38), Color("2a2a2a"))
	for c in [Vector2(-0.09, -0.09), Vector2(0.09, -0.09), Vector2(-0.09, 0.09), Vector2(0.09, 0.09)]:
		box(Vector3(0.025, 0.3, 0.025), Vector3(c.x, h - 0.05, 0.38 + c.y), Color("2a2a2a"))
	glow(Vector3(0.15, 0.24, 0.15), Vector3(0, h - 0.05, 0.38), Color("ffd890"))


## Pazar tezgâhı: masa, mallar, dört direk, tente.
func stall(p: Vector3, color: Color) -> void:
	var w := _pick(WOOD)
	box(Vector3(2.0, 0.85, 0.9), p + Vector3(0, 0.42, 0.5), w)
	for k in 8:
		var kind := k % 3
		var q := p + Vector3(-0.8 + k * 0.23, 0.9, 0.5 + ((k % 2) - 0.5) * 0.3)
		if kind == 0:
			basket(q - Vector3(0, 0.04, 0))
		elif kind == 1:
			ball(0.1, q + Vector3(0, 0.08, 0), _pick(FRUIT))
		else:
			box(Vector3(0.18, 0.12, 0.18), q + Vector3(0, 0.06, 0), _pick(CLOTH))
	for c in 4:
		cyl(0.04, 2.3, p + Vector3(-0.95 + (c % 2) * 1.9, 1.15, 0.05 + (c / 2) * 1.0), Color("4a3020"), Vector3.ZERO, 5)
	box(Vector3(2.3, 0.05, 1.5), p + Vector3(0, 2.3, 0.55), color, Vector3(-10, 0, 0))
	solid(Vector3(2.0, 1.0, 1.0), Vector3(0, 0.5, 0.5))


func rubble(p: Vector3) -> void:
	for k in rng.randi_range(4, 8):
		var q := p + Vector3(rng.randf_range(-0.7, 0.7), 0.1, rng.randf_range(0.0, 0.7))
		ball(rng.randf_range(0.12, 0.3), q, _pick(STONE), Vector3(1, rng.randf_range(0.5, 0.9), 1.2), 6)
	solid(Vector3(1.4, 0.5, 1.0), Vector3(0, 0.25, 0.35))


func rope_coil(p: Vector3) -> void:
	for k in 4:
		cyl(0.3 - k * 0.04, 0.06, p + Vector3(0, 0.03 + k * 0.06, 0), Color("c8a868").darkened(k * 0.05), Vector3.ZERO, 10)


func fish_basket(p: Vector3) -> void:
	box(Vector3(0.7, 0.25, 0.5), p + Vector3(0, 0.12, 0), Color("b8904a"))
	for k in 5:
		ball(0.07, p + Vector3(-0.25 + k * 0.12, 0.27, rng.randf_range(-0.1, 0.1)), Color("a8b8c8"), Vector3(2.2, 0.8, 1))


func net(p: Vector3) -> void:
	for k in 6:
		ball(0.35, p + Vector3(rng.randf_range(-0.4, 0.4), 0.08, rng.randf_range(0.0, 0.5)), Color("8a7a5a"), Vector3(1.2, 0.25, 1.0), 6)
	for k in 4:
		ball(0.05, p + Vector3(rng.randf_range(-0.4, 0.4), 0.15, rng.randf_range(0.0, 0.5)), Color("e8702a"))


func bollard(p: Vector3) -> void:
	cyl(0.2, 0.6, p + Vector3(0, 0.3, 0), Color("4a4040"), Vector3.ZERO, 8)
	cyl(0.26, 0.08, p + Vector3(0, 0.62, 0), Color("3a3232"), Vector3.ZERO, 8)


func anchor(p: Vector3) -> void:
	var c := Color("3a3a3e")
	box(Vector3(0.1, 1.3, 0.1), p + Vector3(0, 0.1, 0.4), c, Vector3(-80, 0, 0))
	box(Vector3(0.9, 0.1, 0.1), p + Vector3(0, 0.1, 1.0), c)
	for s in [-1, 1]:
		box(Vector3(0.1, 0.4, 0.1), p + Vector3(s * 0.45, 0.2, 1.0), c, Vector3(0, 0, s * -30))
	cyl(0.14, 0.05, p + Vector3(0, 0.12, -0.25), c, Vector3(90, 0, 0), 8)


func spear_rack(p: Vector3) -> void:
	var w := _pick(WOOD)
	for s in [-0.7, 0.7]:
		box(Vector3(0.08, 1.2, 0.08), p + Vector3(s, 0.6, 0.3), w)
	box(Vector3(1.5, 0.08, 0.08), p + Vector3(0, 1.1, 0.3), w)
	for k in 6:
		var x := -0.55 + k * 0.22
		cyl(0.02, 2.2, p + Vector3(x, 1.1, 0.22), Color("8a6a40"), Vector3(-8, 0, 0), 4)
		prism(Vector3(0.06, 0.18, 0.02), p + Vector3(x, 2.25, 0.07), Color("c8c8d0"))
	solid(Vector3(1.6, 1.2, 0.5), Vector3(0, 0.6, 0.3))


func shields(p: Vector3) -> void:
	for k in 4:
		var c: Color = [Color("b3262d"), Color("2f5fa8"), Color("3a6b3a"), Color("d8b040")][k]
		cyl(0.36, 0.06, p + Vector3(-0.5 + k * 0.34, 0.38, 0.12), c, Vector3(75, 0, 0), 12)
		cyl(0.1, 0.08, p + Vector3(-0.5 + k * 0.34, 0.4, 0.16), Color("c8a040"), Vector3(75, 0, 0), 8)


func hay(p: Vector3) -> void:
	box(Vector3(1.1, 0.55, 0.6), p + Vector3(0, 0.28, 0.35), Color("d8b860"))
	if rng.randf() < 0.5:
		box(Vector3(1.1, 0.55, 0.6), p + Vector3(0.1, 0.83, 0.35), Color("c8a850"), Vector3(0, 12, 0))
	solid(Vector3(1.2, 1.0, 0.7), Vector3(0, 0.5, 0.35))


## Gündüz ocağı: taş halka, kül, odunlar, üç ayak ve kazan.
func hearth(p: Vector3) -> void:
	for k in 9:
		var a := k * TAU / 9.0
		ball(0.14, p + Vector3(cos(a) * 0.55, 0.08, sin(a) * 0.55), _pick(STONE), Vector3(1, 0.7, 1), 6)
	cyl(0.45, 0.03, p + Vector3(0, 0.02, 0), Color("3a3230"), Vector3.ZERO, 10)
	for k in 3:
		cyl(0.06, 0.7, p + Vector3(0, 0.1, 0), Color("4a3020"), Vector3(90, k * 60, 0), 5)
		var a2 := k * TAU / 3.0
		box(Vector3(0.05, 1.5, 0.05), p + Vector3(cos(a2) * 0.4, 0.7, sin(a2) * 0.4), Color("3a2a1a"), Vector3(sin(a2) * -15, 0, cos(a2) * 15))
	cyl(0.25, 0.3, p + Vector3(0, 0.75, 0), Color("2a2624"), Vector3.ZERO, 10, 0.9)
	solid(Vector3(1.2, 0.5, 1.2), Vector3(0, 0.25, 0))


func banner_pole(p: Vector3, color: Color) -> void:
	cyl(0.05, 4.2, p + Vector3(0, 2.1, 0), Color("5a3a22"), Vector3.ZERO, 5)
	ball(0.08, p + Vector3(0, 4.25, 0), Color("d8b040"))
	box(Vector3(0.9, 1.3, 0.03), p + Vector3(0.47, 3.5, 0), color)
	box(Vector3(0.9, 0.1, 0.035), p + Vector3(0.47, 3.0, 0), color.darkened(0.3))


## Yerde yatan köpek ya da kedi.
func sleeping_animal(p: Vector3, dog := true) -> void:
	var c := Color("a87a4a") if dog else Color("d8843a")
	var s := 1.0 if dog else 0.6
	ball(0.25 * s, p + Vector3(0, 0.15 * s, 0), c, Vector3(1.4, 0.7, 0.9))
	ball(0.13 * s, p + Vector3(0.3 * s, 0.12 * s, 0.1 * s), c.darkened(0.1))
	box(Vector3(0.05, 0.05, 0.3) * s, p + Vector3(-0.3 * s, 0.06, 0.15 * s), c, Vector3(0, 40, 0))


func pigeons(p: Vector3) -> void:
	for k in rng.randi_range(3, 6):
		var q := p + Vector3(rng.randf_range(-1.2, 1.2), 0.08, rng.randf_range(-1.2, 1.2))
		ball(0.09, q, Color("8a8f9a"), Vector3(1.0, 0.8, 1.4), 6)
		ball(0.05, q + Vector3(0, 0.08, 0.1), Color("5a6070"), Vector3.ONE, 5)


func table_food(p: Vector3) -> void:
	var w := _pick(WOOD)
	box(Vector3(1.4, 0.06, 0.8), p + Vector3(0, 0.75, 0), w)
	for s in [Vector2(-0.6, -0.3), Vector2(0.6, -0.3), Vector2(-0.6, 0.3), Vector2(0.6, 0.3)]:
		box(Vector3(0.06, 0.75, 0.06), p + Vector3(s.x, 0.37, s.y), w.darkened(0.2))
	for k in 4:
		cyl(0.12, 0.04, p + Vector3(-0.45 + k * 0.3, 0.8, 0.0), Color("d8d0c0"), Vector3.ZERO, 8)
		ball(0.07, p + Vector3(-0.45 + k * 0.3, 0.84, 0.0), _pick(FRUIT))
	cyl(0.1, 0.3, p + Vector3(0.1, 0.93, 0.25), _pick(CLAY), Vector3.ZERO, 7, 0.6)
	for s in [-1, 1]:
		box(Vector3(1.2, 0.06, 0.3), p + Vector3(0, 0.45, s * 0.65), w)
	solid(Vector3(1.4, 0.8, 1.6), Vector3(0, 0.4, 0))


## Çamaşır ipi: a'dan b'ye (yerel), üstünde birkaç renkli çamaşır.
func laundry(a: Vector3, b: Vector3) -> void:
	var mid := (a + b) * 0.5
	var d := b - a
	var len := d.length()
	var yaw := atan2(d.x, d.z)
	_add("cyl:4:1.00", Transform3D(Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, PI / 2.0), mid).scaled_local(Vector3(0.01, len, 0.01)), Color("3a3a3a"))
	var n := int(len / 0.8)
	for k in n:
		var t := (k + 0.5) / n
		var q := a.lerp(b, t) + Vector3(0, -0.35 - sin(t * PI) * 0.15, 0)
		_add("box", Transform3D(Basis(Vector3.UP, yaw + PI / 2.0), q).scaled_local(Vector3(0.55, 0.6, 0.02)), _pick(CLOTH))


## Oturan ya da ayakta duran insan (uzak kalabalık kadar ucuz): gövde, baş, başlık.
func figure(p: Vector3, coat: Color, sitting := false, hat := Color("f0ece0"), yaw := 0.0) -> void:
	var skin: Color = [Color("e0b08a"), Color("c89070"), Color("d9a07a"), Color("e8c0a0")][rng.randi() % 4]
	var r := Vector3(0, yaw, 0)
	if sitting:
		cyl(0.2, 0.62, p + Vector3(0, 0.62, 0), coat, r, 7, 0.75)
		for s in [-1, 1]:
			var leg := Basis(Vector3.UP, deg_to_rad(yaw)) * Vector3(s * 0.1, 0.25, 0.25)
			box(Vector3(0.12, 0.12, 0.5), p + leg, Color("3a2a1e"), r)
		box(Vector3(0.4, 0.3, 0.3), p + Vector3(0, 0.15, 0), Color("6b4a2e"), r)
		ball(0.14, p + Vector3(0, 1.08, 0), skin)
		cyl(0.12, 0.26, p + Vector3(0, 1.28, 0), hat, r, 7, 0.8)
	else:
		cyl(0.22, 1.1, p + Vector3(0, 0.75, 0), coat, r, 7, 0.72)
		for s in [-1, 1]:
			cyl(0.07, 0.5, p + Basis(Vector3.UP, deg_to_rad(yaw)) * Vector3(s * 0.08, 0.25, 0), Color("2a2a30"), r, 5)
		ball(0.14, p + Vector3(0, 1.45, 0), skin)
		cyl(0.12, 0.28, p + Vector3(0, 1.68, 0), hat, r, 7, 0.8)


## Kazığa bağlı at: gövde, boyun, baş, bacaklar, kuyruk; yanında kazık ve yem torbası.
func horse(p: Vector3, color: Color) -> void:
	box(Vector3(0.5, 0.6, 1.5), p + Vector3(0, 1.3, 0), color)
	box(Vector3(0.3, 0.7, 0.35), p + Vector3(0, 1.75, 0.8), color, Vector3(-35, 0, 0))
	box(Vector3(0.25, 0.3, 0.55), p + Vector3(0, 2.05, 1.05), color)
	box(Vector3(0.08, 0.5, 0.3), p + Vector3(0, 1.85, 0.62), color.darkened(0.4), Vector3(-35, 0, 0))
	box(Vector3(0.1, 0.6, 0.1), p + Vector3(0, 1.2, -0.8), color.darkened(0.4), Vector3(20, 0, 0))
	for q in [Vector3(-0.18, 0.5, 0.55), Vector3(0.18, 0.5, 0.55), Vector3(-0.18, 0.5, -0.55), Vector3(0.18, 0.5, -0.55)]:
		cyl(0.07, 1.0, p + q, color.darkened(0.15), Vector3.ZERO, 5)
	box(Vector3(0.52, 0.12, 0.6), p + Vector3(0, 1.62, 0.1), _pick(CLOTH))
	cyl(0.06, 1.2, p + Vector3(0.8, 0.6, 1.4), Color("5a3a22"), Vector3.ZERO, 5)
	solid(Vector3(0.6, 1.6, 2.2), Vector3(0, 0.8, 0.2))


## Ev cephesi (yerel: duvar yüzeyi z=0, kök cephe ortasının dibi): üst kat kepenkli pencereler, kat kirişi,
## isteğe bağlı kemerli kapı ve basamak, zemin katta parmaklıklı küçük pencere.
func house_face(width: float, h: float, door: bool, shutter := Color("3a6a5a"), floor_h := 3.0, up := 0.0) -> void:
	box(Vector3(width + up * 2.0, 0.16, 0.14 + up), Vector3(0, floor_h, 0.07 + up * 0.5), Color("4a3020"))
	var n := maxi(1, int(width / 1.7))
	var floors := maxi(1, int((h - floor_h) / 2.6))
	for f in floors:
		var y := floor_h + 1.3 + f * 2.6
		if y + 0.6 > h:
			break
		for k in n:
			var x := -width / 2.0 + (k + 0.5) * width / n
			box(Vector3(0.62, 0.95, 0.05), Vector3(x, y, 0.01 + up), Color("1e1a18"))
			box(Vector3(0.8, 0.07, 0.14), Vector3(x, y - 0.52, 0.06 + up), Color("d8d0bc"))
			if rng.randf() < 0.55:
				for sd in [-1, 1]:
					box(Vector3(0.32, 0.95, 0.04), Vector3(x + sd * 0.5, y, 0.12 + up), shutter, Vector3(0, sd * 55, 0))
			else:
				for sd in [-1, 1]:
					box(Vector3(0.3, 0.95, 0.04), Vector3(x + sd * 0.16, y, 0.03 + up), shutter)
			if rng.randf() < 0.3:
				pot_plant(Vector3(x + 0.2, y - 0.49, 0.1 + up))
	if door:
		var dx := rng.randf_range(-width * 0.25, width * 0.25)
		box(Vector3(1.0, 1.9, 0.06), Vector3(dx, 0.95, 0.02), Color("5a3a22"))
		cyl(0.5, 0.06, Vector3(dx, 1.9, 0.02), Color("5a3a22"), Vector3(90, 0, 0), 10)
		box(Vector3(1.3, 0.14, 0.5), Vector3(dx, 0.07, 0.25), Color("b0a48c"))
		var wx := dx + (1.4 if dx < 0.0 else -1.4)
		if absf(wx) < width / 2.0 - 0.4:
			box(Vector3(0.5, 0.55, 0.05), Vector3(wx, 1.9, 0.02), Color("1e1a18"))
			for k in 3:
				cyl(0.015, 0.55, Vector3(wx - 0.15 + k * 0.15, 1.9, 0.05), Color("3a3a3a"), Vector3.ZERO, 4)


## Yüksek, boş duvarın üst kısmına süs (yerel: duvar yüzeyi z=0).
func wall_decor(style: String) -> void:
	var r := rng.randf()
	if r < 0.25:
		# Uzun sancak / kilim
		var c := _pick(CLOTH)
		box(Vector3(0.9, 2.4, 0.04), Vector3(0, 3.6, 0.05), c)
		box(Vector3(0.9, 0.18, 0.05), Vector3(0, 2.45, 0.06), c.darkened(0.3))
		box(Vector3(1.1, 0.06, 0.08), Vector3(0, 4.82, 0.08), Color("5a3a22"))
	elif r < 0.45:
		at_offset(Vector3(rng.randf_range(-0.6, 0.6), 0, 0))
		ivy(rng.randf_range(1.4, 2.6), rng.randf_range(3.0, 5.0))
	elif r < 0.65:
		# Kepenkli küçük pencere
		var y := rng.randf_range(3.2, 4.4)
		box(Vector3(0.7, 0.9, 0.05), Vector3(0, y, 0.02), Color("1e1a18"))
		box(Vector3(0.9, 0.08, 0.14), Vector3(0, y - 0.5, 0.06), Color("d8d0bc"))
		var sc: Color = [Color("3a6a5a"), Color("3a5a8a"), Color("6a3a2a")][rng.randi() % 3]
		for sd in [-1, 1]:
			box(Vector3(0.36, 0.9, 0.04), Vector3(sd * 0.55, y, 0.1), sc, Vector3(0, sd * 60, 0))
		if rng.randf() < 0.6:
			pot_plant(Vector3(0.15, y - 0.46, 0.1))
	elif r < 0.8 and style == "byz":
		# İkon nişi: kemerli oyuk, altın zeminli ikon, küçük kandil
		box(Vector3(0.7, 0.9, 0.08), Vector3(0, 2.2, 0.02), Color("5a4a3a"))
		cyl(0.35, 0.08, Vector3(0, 2.65, 0.02), Color("5a4a3a"), Vector3(90, 0, 0), 10)
		box(Vector3(0.5, 0.6, 0.04), Vector3(0, 2.2, 0.07), Color("d8b040"))
		ball(0.12, Vector3(0, 2.3, 0.1), Color("e0b08a"))
		glow(Vector3(0.08, 0.1, 0.08), Vector3(0, 1.7, 0.2), Color("ffc860"))
	else:
		wall_lantern(rng.randf_range(2.6, 3.0))


# ---------------------------------------------------------------- kümeler (stile göre)

## Duvar dibi kümesi: yerel çerçevenin kökü duvarın dibinde, +z sokağa doğru.
func edge_cluster(style: String) -> void:
	var opts: Array = EDGE[style] if EDGE.has(style) else EDGE["byz"]
	_run(opts)
	# Duvarda küçük süs: fener ya da sarmaşık (sokak ışığı ve yeşillik)
	var r2 := rng.randf()
	if style != "camp":
		if r2 < 0.22:
			wall_lantern(rng.randf_range(2.3, 2.7))
		elif r2 < 0.4:
			at_offset(Vector3(rng.randf_range(-1.2, 1.2), 0, 0))
			ivy(rng.randf_range(0.8, 1.6), rng.randf_range(1.8, 3.2))
	if rng.randf() < 0.12:
		sleeping_animal(Vector3(rng.randf_range(-1.0, 1.0), 0, 1.2), style != "galata")


## Açık alan kümesi (meydan ortası): yerel kök merkez.
func open_cluster(style: String) -> void:
	var opts: Array = OPEN[style] if OPEN.has(style) else OPEN["byz"]
	_run(opts)


## [[ağırlık, "kümeadı"], ...] listesinden ağırlıklı seçip çalıştırır.
func _run(opts: Array) -> void:
	var total := 0.0
	for o in opts:
		total += float(o[0])
	var r := rng.randf() * total
	for o in opts:
		r -= float(o[0])
		if r <= 0.0:
			call("_c_" + str(o[1]))
			return


const EDGE := {
	"byz": [[3, "amphorae"], [3, "pots"], [3, "crates"], [2, "barrels"], [2, "bench"], [2, "sacks"], [1, "firewood"], [2, "baskets"], [1, "rubble"], [1, "trough"]],
	"galata": [[4, "barrels"], [3, "crates"], [2, "sacks"], [2, "amphorae"], [2, "fish"], [2, "pots"], [2, "bench"], [2, "awning_crates"], [1, "firewood"]],
	"camp": [[3, "sacks"], [3, "barrels"], [3, "crates"], [2, "spears"], [2, "hay"], [2, "firewood"], [1, "shields"]],
}
const OPEN := {
	"byz": [[2, "well"], [3, "cart"], [2, "table"], [3, "pigeons_bench"], [2, "trough_pots"]],
	"galata": [[3, "cart"], [3, "barrel_pile"], [2, "net_anchor"], [2, "pigeons"]],
	"camp": [[5, "hearth"], [2, "cart"], [2, "banner_hay"], [2, "table"], [2, "armory"], [3, "horses"]],
}


func _c_amphorae() -> void: amphorae(Vector3.ZERO)
func _c_pots() -> void: pots(Vector3.ZERO)
func _c_crates() -> void: crates(Vector3.ZERO)
func _c_barrels() -> void: barrels(Vector3.ZERO)
func _c_bench() -> void: bench(Vector3.ZERO)
func _c_sacks() -> void: sacks(Vector3.ZERO)
func _c_firewood() -> void: firewood(Vector3.ZERO)
func _c_rubble() -> void: rubble(Vector3.ZERO)
func _c_trough() -> void: trough(Vector3.ZERO)
func _c_spears() -> void: spear_rack(Vector3.ZERO)
func _c_hay() -> void: hay(Vector3.ZERO)
func _c_well() -> void: well(Vector3.ZERO)
func _c_cart() -> void: cart(Vector3.ZERO)
func _c_table() -> void: table_food(Vector3.ZERO)
func _c_pigeons() -> void: pigeons(Vector3.ZERO)


func _c_baskets() -> void:
	basket(Vector3(-0.3, 0, 0.3))
	basket(Vector3(0.35, 0, 0.35))
	amphora(Vector3(0.9, 0, 0.15))
	solid(Vector3(1.8, 0.8, 0.7), Vector3(0.2, 0.4, 0.3))


func _c_fish() -> void:
	fish_basket(Vector3(0, 0, 0.4))
	rope_coil(Vector3(0.8, 0, 0.4))
	solid(Vector3(1.8, 0.4, 0.8), Vector3(0.3, 0.2, 0.4))


func _c_awning_crates() -> void:
	awning(2.2, 2.4, _pick(CLOTH))
	crates(Vector3(0, 0, 0.1))


func _c_shields() -> void:
	shields(Vector3.ZERO)
	solid(Vector3(1.4, 0.8, 0.4), Vector3(0, 0.4, 0.15))


func _c_pigeons_bench() -> void:
	pigeons(Vector3.ZERO)
	bench(Vector3(0, 0, 1.4))


func _c_trough_pots() -> void:
	trough(Vector3.ZERO)
	pots(Vector3(0, 0, 1.0))


func _c_barrel_pile() -> void:
	barrels(Vector3.ZERO)
	crates(Vector3(0, 0, 1.2))


func _c_net_anchor() -> void:
	net(Vector3.ZERO)
	anchor(Vector3(1.4, 0, 0))


func _c_hearth() -> void:
	hearth(Vector3.ZERO)
	var coats := [Color("b3262d"), Color("2f5fa8"), Color("3a6b3a"), Color("c98a3a"), Color("8a2b22")]
	for k in rng.randi_range(2, 4):
		var a := k * TAU / 4.0 + rng.randf_range(-0.3, 0.3)
		figure(Vector3(cos(a) * 1.3, 0, sin(a) * 1.3), coats[rng.randi() % coats.size()], true, Color("f0ece0"), rad_to_deg(-a) - 90.0)
	at_offset(Vector3(2.2, 0, 0.4))
	sacks(Vector3.ZERO)


func _c_horses() -> void:
	var cols := [Color("6a4028"), Color("3a2a1e"), Color("c8b8a0"), Color("8a5a38"), Color("2a2622")]
	for k in rng.randi_range(1, 3):
		horse(Vector3(k * 1.3, 0, rng.randf_range(-0.3, 0.3)), cols[rng.randi() % cols.size()])
	box(Vector3(0.4, 0.3, 0.4), Vector3(-1.0, 0.15, 0.6), Color("d8b860"))


func _c_guards() -> void:
	var coats := [Color("b3262d"), Color("2f5fa8"), Color("3a6b3a")]
	for k in rng.randi_range(2, 3):
		figure(Vector3(k * 0.8, 0, rng.randf_range(-0.3, 0.3)), coats[rng.randi() % coats.size()], false, Color("f0ece0"), rng.randf_range(0, 360))
	spear_rack(Vector3(0, 0, -1.0))


func _c_banner_hay() -> void:
	banner_pole(Vector3.ZERO, _pick(CLOTH))
	hay(Vector3(1.2, 0, 0))


func _c_armory() -> void:
	spear_rack(Vector3.ZERO)
	shields(Vector3(0, 0, 0.8))


## Çerçeveyi yerel bir kaydırmayla ötele (küme içi parça yerleştirmek için).
func at_offset(off: Vector3) -> void:
	_frame = _frame * Transform3D(Basis.IDENTITY, off)


# ---------------------------------------------------------------- otomatik yerleşim

## cfg: rect (Rect2 x,z), reserved ([Rect2]), style ("byz" | "galata" | "camp"), seed, edge_gap (m),
## open_gap (m), open_clear (m, açık alan sayılması için dört yönde boşluk), walkers (adet), y_max (zemin üst sınırı),
## people (Person yapılandırmaları: rastgele seçilir).
static func auto(level: Node3D, cfg: Dictionary) -> void:
	var d := Dressing.new(int(cfg.get("seed", 7)))
	level.set_meta("_dressing", d)   # await sırasında nesne yaşasın
	d._auto_run(level, cfg)


func _auto_run(level: Node3D, cfg: Dictionary) -> void:
	var tree := level.get_tree()
	await tree.physics_frame
	await tree.physics_frame
	if not is_instance_valid(level):
		return
	var t0 := Time.get_ticks_msec()
	var space := level.get_world_3d().direct_space_state
	var rect: Rect2 = cfg.get("rect", Rect2(-30, -30, 60, 60))
	var reserved: Array = cfg.get("reserved", [])
	var style: String = cfg.get("style", "byz")
	var edge_gap: float = cfg.get("edge_gap", 3.2)
	var open_gap: float = cfg.get("open_gap", 9.0)
	var open_clear: float = cfg.get("open_clear", 4.0)
	var y_max: float = cfg.get("y_max", 2.0)
	var placed: Array[Vector3] = []
	var nodes: Array[Vector3] = []    # yürüyüş noktaları
	var persons := tree.get_nodes_in_group("persons")
	var step := 1.0
	var z := rect.position.y
	while z <= rect.end.y:
		var x := rect.position.x
		while x <= rect.end.x:
			var g := _ground(space, Vector3(x, 0, z), y_max)
			x += step
			if g.is_empty():
				continue
			var p: Vector3 = g["pos"]
			if _in(reserved, p, 0.0) or not _free(space, p):
				continue
			if int(round(p.x)) % 4 == 0 and int(round(p.z)) % 4 == 0:
				nodes.append(p)
			# Duvar dibi mi?
			for k in 4:
				var dir := [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK][k] as Vector3
				var h1 := _wall_ray(space, p + Vector3(0, 0.6, 0), p + Vector3(0, 0.6, 0) + dir * 0.9)
				if h1.is_empty() or (h1["normal"] as Vector3).dot(dir) > -0.8 or not _visible_wall(h1["collider"]):
					continue
				var h2 := _wall_ray(space, p + Vector3(0, 2.2, 0), p + Vector3(0, 2.2, 0) + dir * 1.1)
				if h2.is_empty():
					continue
				var wall_p: Vector3 = h1["position"]
				wall_p.y = p.y
				if _near(placed, wall_p, edge_gap):
					continue
				# Karşı tarafta en az 2.6 m geçit kalsın; etkileşim alanı ve karakterlerin dibine konmasın
				if not _ray(space, p + Vector3(0, 0.6, 0), p + Vector3(0, 0.6, 0) - dir * 2.6).is_empty():
					continue
				if _near_interact(space, wall_p - dir * 0.8, 1.6) or _near_nodes(persons, wall_p, 1.8):
					continue
				if rng.randf() > float(cfg.get("edge_chance", 0.7)):
					placed.append(wall_p)
					continue
				var n: Vector3 = h1["normal"]
				at(wall_p + n * 0.02, atan2(n.x, n.z))
				edge_cluster(style)
				# Yüksek ve boş (üstü de çarpışmalı) duvar: üst kısma süs
				var h3 := _wall_ray(space, p + Vector3(0, 4.0, 0), p + Vector3(0, 4.0, 0) + dir * 1.3)
				if not h3.is_empty() and h3["collider"] == h1["collider"] and rng.randf() < 0.75:
					at(wall_p + n * 0.02 + Vector3(0, 0, 0), atan2(n.x, n.z))
					at_offset(Vector3(rng.randf_range(-1.5, 1.5), 0, 0))
					wall_decor(style)
				placed.append(wall_p)
				break
		z += step
	# Açık alanlar
	var opens: Array[Vector3] = []
	z = rect.position.y + 1.5
	while z <= rect.end.y:
		var x := rect.position.x + 1.5
		while x <= rect.end.x:
			var g := _ground(space, Vector3(x, 0, z), y_max)
			x += 3.0
			if g.is_empty():
				continue
			var p: Vector3 = g["pos"]
			if _in(reserved, p, 1.5) or not _free(space, p) or _near(placed, p, open_gap * 0.5) or _near(opens, p, open_gap):
				continue
			var clear := true
			for k in 8:
				var a := k * TAU / 8.0
				if not _ray(space, p + Vector3(0, 0.6, 0), p + Vector3(0, 0.6, 0) + Vector3(cos(a), 0, sin(a)) * open_clear).is_empty():
					clear = false
					break
			if not clear or _near_interact(space, p, 3.0) or _near_nodes(persons, p, 3.0):
				continue
			if rng.randf() > float(cfg.get("open_chance", 0.6)):
				opens.append(p)
				continue
			at(p, rng.randf() * TAU)
			open_cluster(style)
			opens.append(p)
		z += 3.0
	var t1 := Time.get_ticks_msec()
	build(level)
	if OS.is_debug_build() and "--dress-debug" in OS.get_cmdline_user_args():
		print("DRESS %s edges=%d opens=%d nodes=%d scan=%dms build=%dms" % [style, placed.size(), opens.size(), nodes.size(), t1 - t0, Time.get_ticks_msec() - t1])
	# Yürüyen halk
	var count: int = int(round(float(cfg.get("walkers", 0)) * GameState.crowd()))
	var looks: Array = cfg.get("people", [])
	if count > 0 and nodes.size() > 4 and not looks.is_empty():
		await tree.physics_frame
		space = level.get_world_3d().direct_space_state
		for i in count:
			var start: Vector3 = nodes[rng.randi() % nodes.size()]
			var w := Walker.new()
			w.nodes = nodes
			w.seed_value = rng.randi()
			w.space_owner = level
			var look: Dictionary = looks[rng.randi() % looks.size()]
			var pr := Person.new(look)
			pr.position = start
			level.add_child(pr)
			if rng.randf() < 0.3:
				pr.carry(["crate", "basket", "sack"][rng.randi() % 3])
			w.person = pr
			level.add_child(w)


static func _in(rects: Array, p: Vector3, pad: float) -> bool:
	for r in rects:
		if (r as Rect2).grow(pad).has_point(Vector2(p.x, p.z)):
			return true
	return false


static func _near(list: Array, p: Vector3, d: float) -> bool:
	for q in list:
		if (q as Vector3).distance_to(p) < d:
			return true
	return false


static func _near_nodes(nodes: Array, p: Vector3, d: float) -> bool:
	for n in nodes:
		if n is Node3D and (n as Node3D).global_position.distance_to(p) < d:
			return true
	return false


static func _ray(space: PhysicsDirectSpaceState3D, a: Vector3, b: Vector3, mask := 1) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(a, b, mask)
	return space.intersect_ray(q)


## Duvar ışını: görünmez bir sınıra çarparsa arkasına bakar; hemen arkasında (0.5 m) görünür bir duvar varsa
## çarpma noktası sınırın önü, çarpılan cisim o duvar olur (evin önündeki görünmez sınır eşyaları engellemesin).
static func _wall_ray(space: PhysicsDirectSpaceState3D, a: Vector3, b: Vector3) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(a, b, 1)
	var h := space.intersect_ray(q)
	if h.is_empty() or not _invisible(h["collider"]):
		return h
	q.exclude = [(h["collider"] as CollisionObject3D).get_rid()]
	q.to = b + (b - a).normalized() * 0.5
	var h2 := space.intersect_ray(q)
	if h2.is_empty() or (h2["position"] as Vector3).distance_to(h["position"]) > 0.5:
		return h
	h2["position"] = h["position"]
	return h2


## Zemin: yukarıdan aşağı ışın; üst yüzü y_max'ın altında, düz bir yüzey.
static func _ground(space: PhysicsDirectSpaceState3D, p: Vector3, y_max: float) -> Dictionary:
	var h := _ray(space, Vector3(p.x, y_max + 0.5, p.z), Vector3(p.x, -3.0, p.z))
	if h.is_empty() or (h["normal"] as Vector3).y < 0.9 or _invisible(h["collider"]):
		return {}
	return {"pos": h["position"]}


## Görünmez sınır duvarı mı (tepesi zemin sanılmasın)?
static func _invisible(c: Object) -> bool:
	if not (c is StaticBody3D) or (c as Node).has_meta("wall"):
		return false
	for ch in (c as Node).get_children():
		if ch is MeshInstance3D:
			return not (ch as MeshInstance3D).visible
	return false


## Nokta bir katı cismin içinde değil ve üstünde 2.4 m'ye kadar tavan yok.
static func _free(space: PhysicsDirectSpaceState3D, p: Vector3) -> bool:
	var q := PhysicsPointQueryParameters3D.new()
	q.position = p + Vector3(0, 0.9, 0)
	q.collision_mask = 1
	if not space.intersect_point(q, 1).is_empty():
		return false
	return _ray(space, p + Vector3(0, 2.4, 0), p + Vector3(0, 0.3, 0)).is_empty()


static func _near_interact(space: PhysicsDirectSpaceState3D, p: Vector3, r: float) -> bool:
	var q := PhysicsShapeQueryParameters3D.new()
	var s := SphereShape3D.new()
	s.radius = r
	q.shape = s
	q.transform = Transform3D(Basis.IDENTITY, p + Vector3(0, 1.0, 0))
	q.collision_mask = 2
	q.collide_with_areas = true
	return not space.intersect_shape(q, 1).is_empty()


## Görünür bir duvar mı (görünmez sınırların önüne eşya konmaz)?
static func _visible_wall(c: Object) -> bool:
	if not (c is StaticBody3D):
		return false
	if (c as Node).has_meta("wall"):
		return true
	for ch in (c as Node).get_children():
		if ch is MeshInstance3D:
			return (ch as MeshInstance3D).visible
	return false
