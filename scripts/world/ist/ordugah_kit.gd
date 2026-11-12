class_name IstOrdugahKit
extends RefCounted
## Ordugâh için ortak araçlar: tek ağda birleştiren "Bld" (köşe renkli, düz gölgeli), çarpışma, çoklu ağ, renkler.
## Bütün yapı dosyaları (ordugah_yapi/kanat/donanma) bunu kullanır. İnsan ölçüsü k'den bağımsızdır.

# Renkler (Nisan 1453 ordugâhı: keten, keçe, bitki boyası, toprak, ahşap)
const BEZ := Color("d9ccaa")        # keten çadır
const BEZ2 := Color("cdbf9a")
const KECE := Color("a89a78")
const KIRMIZI := Color("b3262d")    # otağ çuhası
const KIRMIZI2 := Color("9a2a26")
const ALTIN := Color("d6a93c")
const KREM := Color("f1e6c8")
const LACI := Color("28366a")
const YESIL := Color("3f6b3d")
const TOPRAK := Color("7a6446")
const TOPRAK2 := Color("6a563c")
const CAMUR := Color("5c4a34")
const AHSAP := Color("7a5634")
const AHSAP2 := Color("5e4228")
const AHSAP_A := Color("a07a4a")
const SEPET := Color("a58a54")      # hasır sepet (gabion)
const BRONZ := Color("8a6a2c")
const DEMIR := Color("3a3a3e")
const TAS := Color("b8ad98")
const KOYU := Color("1c1814")
const SAMAN := Color("c8ac5c")
const DERI := Color("8c6a46")

## Zemin yüksekliği (yerel x,z → y). Boşken düz zemin (önizleme). attach() konumlandırmadan önce doldurur.
static var zemin := Callable()
static var filtre := Callable()          # (x,z yerel) → bu noktaya çadır konabilir mi (attach doldurur)
static var gece := false

static func gy(x: float, z: float) -> float:
	if zemin.is_valid():
		return float(zemin.call(x, z))
	return 0.0

static func rr(seed_: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_
	return r

static func ton(c: Color, r: RandomNumberGenerator, a := 0.06) -> Color:
	var d := r.randf_range(-a, a)
	return Color(clampf(c.r + d, 0, 1), clampf(c.g + d, 0, 1), clampf(c.b + d, 0, 1))


static func mat(pattern := "") -> StandardMaterial3D:
	return Bld.vmat(pattern)


## Köşe renkli, düz yüzlü birleşik ağ. Çarpışma: solid_box / solid_cyl.
class Bld:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var c := PackedColorArray()
	var tris := 0
	var pattern := ""
	var body: StaticBody3D
	var no_climb := false
	var cast := true
	static var _mats := {}

	static func vmat(pattern := "") -> StandardMaterial3D:
		if _mats.has(pattern):
			return _mats[pattern]
		var m := Props.mat(Color.WHITE, 0.0, false, pattern, true).duplicate() as StandardMaterial3D
		m.vertex_color_use_as_albedo = true
		m.albedo_color = Color(0.78, 0.76, 0.72)
		m.cull_mode = BaseMaterial3D.CULL_BACK
		_mats[pattern] = m
		return m

	func _init(p := "") -> void:
		pattern = p

	## Dışbükey çokgen (saat yönü ters sıralı olması gerekmez), out = dış yön
	func poly(pts: Array, out: Vector3, col: Color) -> void:
		if pts.size() < 3:
			return
		var nn: Vector3 = ((pts[1] as Vector3) - (pts[0] as Vector3)).cross((pts[2] as Vector3) - (pts[0] as Vector3))
		if nn.length() < 0.000001:
			return
		var flip := nn.dot(out) > 0.0
		var nrm := nn.normalized() if flip else -nn.normalized()
		for i in range(1, pts.size() - 1):
			var a: Vector3 = pts[0]
			var b: Vector3 = pts[i]
			var d: Vector3 = pts[i + 1]
			if flip:
				v.append(a); v.append(d); v.append(b)
			else:
				v.append(a); v.append(b); v.append(d)
			n.append(nrm); n.append(nrm); n.append(nrm)
			c.append(col); c.append(col); c.append(col)
			tris += 1

	static func xf(pos: Vector3, yaw_deg := 0.0, rot_deg := Vector3.ZERO) -> Transform3D:
		var b := Basis.from_euler(Vector3(deg_to_rad(rot_deg.x), deg_to_rad(yaw_deg + rot_deg.y), deg_to_rad(rot_deg.z)))
		return Transform3D(b, pos)

	## Kutu: merkez pos, size = (en x, boy y, derinlik z)
	func box(pos: Vector3, size: Vector3, col: Color, yaw_deg := 0.0, rot_deg := Vector3.ZERO) -> void:
		tbox(xf(pos, yaw_deg, rot_deg), size, col)

	func tbox(t: Transform3D, size: Vector3, col: Color) -> void:
		var h := size * 0.5
		var P := func(sx: float, sy: float, sz: float) -> Vector3:
			return t * Vector3(h.x * sx, h.y * sy, h.z * sz)
		var p000: Vector3 = P.call(-1, -1, -1)
		var p100: Vector3 = P.call(1, -1, -1)
		var p110: Vector3 = P.call(1, 1, -1)
		var p010: Vector3 = P.call(-1, 1, -1)
		var p001: Vector3 = P.call(-1, -1, 1)
		var p101: Vector3 = P.call(1, -1, 1)
		var p111: Vector3 = P.call(1, 1, 1)
		var p011: Vector3 = P.call(-1, 1, 1)
		var bs := t.basis
		poly([p001, p101, p111, p011], bs.z, col)
		poly([p100, p000, p010, p110], -bs.z, col)
		poly([p101, p100, p110, p111], bs.x, col)
		poly([p000, p001, p011, p010], -bs.x, col)
		poly([p011, p111, p110, p010], bs.y, col.lightened(0.06))
		poly([p000, p100, p101, p001], -bs.y, col.darkened(0.2))

	## Silindir/koni (y ekseni, merkez ortada): r alt, rt üst (−1 = r)
	func cyl(t: Transform3D, r: float, h: float, col: Color, segs := 8, rt := -1.0, cap := true) -> void:
		if rt < 0.0:
			rt = r
		var hh := h * 0.5
		var bot: Array = []
		var top: Array = []
		for i in segs:
			var a := TAU * i / segs
			bot.append(t * Vector3(cos(a) * r, -hh, sin(a) * r))
			top.append(t * Vector3(cos(a) * rt, hh, sin(a) * rt))
		for i in segs:
			var j := (i + 1) % segs
			var am := TAU * (i + 0.5) / segs
			var out := t.basis * Vector3(cos(am), (r - rt) / maxf(h, 0.001), sin(am))
			var q: Array = [bot[i], bot[j], top[j], top[i]]
			if rt <= 0.0001:
				q = [bot[i], bot[j], top[0]]
			var shade := 0.0 if i % 2 == 0 else 0.05
			poly(q, out, col.darkened(shade))
		if cap:
			if rt > 0.0001:
				var tp := top.duplicate()
				poly(tp, t.basis.y, col.lightened(0.08))
			if r > 0.0001:
				poly(bot, -t.basis.y, col.darkened(0.25))

	func cylp(pos: Vector3, r: float, h: float, col: Color, segs := 8, rt := -1.0, rot_deg := Vector3.ZERO, yaw_deg := 0.0) -> void:
		cyl(xf(pos, yaw_deg, rot_deg), r, h, col, segs, rt)

	## Küre (alçak çokgen)
	func sph(pos: Vector3, r: float, col: Color, segs := 6, scale := Vector3.ONE) -> void:
		var rings := maxi(segs / 2, 2)
		for ri in rings:
			var a0 := PI * ri / rings
			var a1 := PI * (ri + 1) / rings
			for i in segs:
				var b0 := TAU * i / segs
				var b1 := TAU * (i + 1) / segs
				var P := func(a: float, b: float) -> Vector3:
					return pos + Vector3(sin(a) * cos(b) * r * scale.x, cos(a) * r * scale.y, sin(a) * sin(b) * r * scale.z)
				var p00: Vector3 = P.call(a0, b0)
				var p01: Vector3 = P.call(a0, b1)
				var p10: Vector3 = P.call(a1, b0)
				var p11: Vector3 = P.call(a1, b1)
				var out := (p00 + p01 + p10 + p11) * 0.25 - pos
				if ri == 0:
					poly([p00, p10, p11], out, col)
				elif ri == rings - 1:
					poly([p00, p01, p10], out, col)
				else:
					poly([p00, p01, p11, p10], out, col)

	## Üçgen kesitli çatı/sırt: tabanda (size.x boy, size.z en), tepe size.y; sırt x boyunca
	func prism(t: Transform3D, size: Vector3, col: Color) -> void:
		var hx := size.x * 0.5
		var hz := size.z * 0.5
		var a0 := t * Vector3(-hx, 0, -hz)
		var a1 := t * Vector3(hx, 0, -hz)
		var b0 := t * Vector3(-hx, 0, hz)
		var b1 := t * Vector3(hx, 0, hz)
		var r0 := t * Vector3(-hx, size.y, 0)
		var r1 := t * Vector3(hx, size.y, 0)
		var bs := t.basis
		poly([b0, b1, r1, r0], bs.z * size.y + bs.y * hz, col)
		poly([a1, a0, r0, r1], -bs.z * size.y + bs.y * hz, col.darkened(0.06))
		poly([a0, b0, r0], -bs.x, col.darkened(0.12))
		poly([b1, a1, r1], bs.x, col.darkened(0.12))
		poly([a0, a1, b1, b0], -bs.y, col.darkened(0.3))

	## Eğik düz levha: p0'dan p1'e (uzun eksen), genişlik w, kalınlık th (rampa, merdiven kolu, direk)
	func rod(p0: Vector3, p1: Vector3, th: float, col: Color, w := -1.0) -> void:
		var d := p1 - p0
		var l := d.length()
		if l < 0.001:
			return
		var y := d / l
		var x := y.cross(Vector3.FORWARD if absf(y.dot(Vector3.UP)) > 0.9 else Vector3.UP).normalized()
		var z := x.cross(y).normalized()
		tbox(Transform3D(Basis(x, y, z), (p0 + p1) * 0.5), Vector3(th if w < 0.0 else w, l, th), col)

	func _body() -> StaticBody3D:
		if body == null:
			body = StaticBody3D.new()
			if no_climb:
				body.set_meta("no_climb", true)
		return body

	func solid_box(pos: Vector3, size: Vector3, yaw_deg := 0.0, rot_deg := Vector3.ZERO) -> void:
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = size
		cs.shape = bs
		cs.transform = xf(pos, yaw_deg, rot_deg)
		_body().add_child(cs)

	func solid_cyl(pos: Vector3, r: float, h: float) -> void:
		var cs := CollisionShape3D.new()
		var sh := CylinderShape3D.new()
		sh.radius = r
		sh.height = h
		cs.shape = sh
		cs.position = pos
		_body().add_child(cs)

	## Eğimli katı yüzey (rampa): dışbükey gövde
	func solid_hull(pts: PackedVector3Array) -> void:
		var cs := CollisionShape3D.new()
		var sh := ConvexPolygonShape3D.new()
		sh.points = pts
		cs.shape = sh
		_body().add_child(cs)

	func done(host: Node3D, nm := "") -> MeshInstance3D:
		var mi: MeshInstance3D = null
		if v.size() > 0:
			var arr := []
			arr.resize(Mesh.ARRAY_MAX)
			arr[Mesh.ARRAY_VERTEX] = v
			arr[Mesh.ARRAY_NORMAL] = n
			arr[Mesh.ARRAY_COLOR] = c
			var m := ArrayMesh.new()
			m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
			mi = MeshInstance3D.new()
			mi.mesh = m
			mi.material_override = Bld.vmat(pattern)
			if not cast:
				mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			if nm != "":
				mi.name = nm
			host.add_child(mi)
		if body != null:
			if nm != "":
				body.name = nm + "_katı"
			host.add_child(body)
		return mi


## Çoklu ağ: aynı ağdan çok kopya. xfs: Array[Transform3D] (host yerel), cols: renk dizisi (boş = beyaz)
static func mm(host: Node3D, mesh: Mesh, xfs: Array, cols: Array = [], nm := "", pattern := "", shadow := false) -> MultiMeshInstance3D:
	if xfs.is_empty():
		return null
	var m := MultiMesh.new()
	m.transform_format = MultiMesh.TRANSFORM_3D
	m.use_colors = not cols.is_empty()
	m.mesh = mesh
	m.instance_count = xfs.size()
	for i in xfs.size():
		m.set_instance_transform(i, xfs[i])
		if not cols.is_empty():
			m.set_instance_color(i, cols[i % cols.size()])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = m
	mi.material_override = mat(pattern)
	if not shadow:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if nm != "":
		mi.name = nm
	mi.set_meta("no_walk", true)
	host.add_child(mi)
	return mi


static func bld_mesh(b: Bld) -> ArrayMesh:
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = b.v
	arr[Mesh.ARRAY_NORMAL] = b.n
	arr[Mesh.ARRAY_COLOR] = b.c
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return m


static var _mesh_cache := {}

## Çadır ağları (birim ölçek, taban y = 0): yarıçap/boy ölçeği örnek dönüşümünde
## "yuvarlak": duvar + koni çatı + kapı + alem; "cati": dikdörtgen sırtlı çadır (çatma); "sade": uzak koni
static func tent_mesh(kind: String) -> ArrayMesh:
	if _mesh_cache.has(kind):
		return _mesh_cache[kind]
	var b := Bld.new()
	match kind:
		"yuvarlak":
			b.cyl(Bld.xf(Vector3(0, 0.55, 0)), 1.0, 1.1, Color(0.93, 0.9, 0.8), 10, 1.0, false)
			b.cyl(Bld.xf(Vector3(0, 1.82, 0)), 1.05, 1.45, Color(0.85, 0.8, 0.68), 10, 0.12)
			b.cyl(Bld.xf(Vector3(0, 0.02, 0)), 1.12, 0.05, Color(0.6, 0.5, 0.36), 10)
			b.cyl(Bld.xf(Vector3(0, 1.12, 0)), 1.015, 0.16, Color(0.62, 0.22, 0.2), 10, 1.015, false)
			b.box(Vector3(0, 0.55, 1.0), Vector3(0.6, 1.0, 0.08), Color(0.12, 0.09, 0.07))
			b.cylp(Vector3(0, 2.75, 0), 0.025, 0.7, Color(0.28, 0.2, 0.12), 4)
			b.sph(Vector3(0, 3.1, 0), 0.07, Color(0.8, 0.65, 0.25), 4)
		"cati":
			# boy x = 1.0 (ölçekle), en z = 1.0, yan duvar 0.9, sırt 2.0 (birim)
			b.box(Vector3(0, 0.45, 0), Vector3(1.0, 0.9, 1.0), Color(0.92, 0.88, 0.76))
			b.prism(Bld.xf(Vector3(0, 0.9, 0)), Vector3(1.04, 0.95, 1.08), Color(0.85, 0.8, 0.66))
			b.box(Vector3(0.0, 0.5, 0.505), Vector3(0.36, 0.78, 0.04), Color(0.12, 0.09, 0.07))
			b.box(Vector3(0, 0.97, 0.0), Vector3(1.08, 0.04, 0.14), Color(0.4, 0.3, 0.2))
		"bark":
			# başıbozuk barınağı: alçak, yamuk, eğik çatı (ters yan yatmış sırt)
			b.prism(Bld.xf(Vector3(0, 0, 0)), Vector3(1.0, 0.9, 1.0), Color(0.62, 0.54, 0.4))
			b.box(Vector3(0, 0.4, 0.46), Vector3(0.5, 0.7, 0.05), Color(0.1, 0.08, 0.06))
		"sade":
			b.cyl(Bld.xf(Vector3(0, 0.9, 0)), 1.0, 1.8, Color(0.88, 0.83, 0.7), 6, 0.1, false)
		"sade_cati":
			b.prism(Bld.xf(Vector3(0, 0, 0)), Vector3(1.0, 1.7, 1.0), Color(0.86, 0.8, 0.66))
	var m := bld_mesh(b)
	_mesh_cache[kind] = m
	return m


## Ağ üçgen sayısı (denetim için)
static func mesh_tris(m: Mesh) -> int:
	var t := 0
	for s in m.get_surface_count():
		var a := m.surface_get_arrays(s)
		var idx = a[Mesh.ARRAY_INDEX]
		if idx != null and (idx as PackedInt32Array).size() > 0:
			t += (idx as PackedInt32Array).size() / 3
		else:
			t += (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return t


static func in_poly(p: Vector2, poly_: PackedVector2Array) -> bool:
	return Geometry2D.is_point_in_polygon(p, poly_)


static func poly_bounds(poly_: PackedVector2Array) -> Rect2:
	var r := Rect2(poly_[0], Vector2.ZERO)
	for p in poly_:
		r = r.expand(p)
	return r


## Çokgenin ağırlık merkezi (basit ortalama; dışbükeye yakın alanlar için yeter)
static func centroid(poly_: PackedVector2Array) -> Vector2:
	var s := Vector2.ZERO
	for p in poly_:
		s += p
	return s / maxf(poly_.size(), 1)


## Ateş: yalnız gece ya da istenirse (Flame ile)
static func ates(host: Node3D, pos: Vector3, w := 0.5, h := 0.8) -> void:
	Flame.add(host, pos, w, h)
