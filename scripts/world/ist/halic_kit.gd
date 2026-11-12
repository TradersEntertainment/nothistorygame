class_name IstHalicKit
extends RefCounted
## Haliç parçası ortak yardımcıları: katı kutu, basamak, MultiMesh sırası, ahşap/taş ayrıntıları.
## Kural: görünen kütle katıdır (Props.solid); küçük süs çarpışmasızdır. İnsan ölçüleri k'den bağımsızdır.

const STONE := Color("c4b494")
const STONE_D := Color("a99a7c")
const BRICK := Color("9a5a40")
const PLASTER := [Color("e8c890"), Color("d89a78"), Color("efe0c4"), Color("c8a0a0"), Color("b8c4c0"), Color("e0b070")]
const TIMBER := Color("6a4a2c")
const TIMBER_D := Color("4e3822")
const TILE := Color("b4573a")
const TILE_D := Color("96462f")
const IRON := Color("3a3d42")
const WATER := Color("3f6f86")
const SHUTTER := [Color("3a6a5a"), Color("3a5a8a"), Color("6a3a2a"), Color("5a6a3a")]
const STEP_RISE := 0.26
## lod>=1 iken merdivenler tek rampa olur (çarpışma lod 0'da anlamlı; lod>=1'de IstHalic.build çarpışmayı da atar)
static var lod := 0


## Katı kutu + doku. pos kutunun ORTASI.
static func blk(p: Node3D, size: Vector3, pos: Vector3, col: Color, pat := "", rot := Vector3.ZERO) -> StaticBody3D:
	var b := Props.solid(p, size, pos, col, rot)
	if pat != "":
		Props.set_pattern(b, col, pat)
	return b


## Tabanı y0'da, x0..x1 / z0..z1 aralığında katı kutu (tabandan üste)
static func slab(p: Node3D, x0: float, x1: float, z0: float, z1: float, y0: float, y1: float, col: Color, pat := "") -> StaticBody3D:
	return blk(p, Vector3(absf(x1 - x0), y1 - y0, absf(z1 - z0)), Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, (z0 + z1) * 0.5), col, pat)


## Kapalı basamaklı merdiven: base = ilk basamağın ön alt köşesi ortası (zemin), dir = yatay yön, h toplam yükseklik.
## Her basamak yerden başlayan dolu blok (altı boş değil). Basamak yüksekliği <= 0,26 m.
static func stair(p: Node3D, base: Vector3, dir: Vector3, h: float, width: float, col: Color, pat := "ashlar") -> Array:
	var n := int(ceil(h / STEP_RISE))
	var rise := h / n
	var run := 0.34
	var d := dir.normalized()
	if lod >= 1:
		var a := base
		var b := base + d * (run * n) + Vector3(0, h, 0)
		Props.ramp(p, a, b, width, col)
		return [a, b]
	var ang := atan2(d.x, d.z)
	for i in n:
		var top := rise * (i + 1)
		var c := base + d * (run * (i + 0.5)) + Vector3(0, top * 0.5, 0)
		blk(p, Vector3(width, top, run), c, col, pat, Vector3(0, rad_to_deg(ang), 0))
	return [base, base + d * (run * n) + Vector3(0, h, 0)]


## MultiMesh sırası: tek mesh, çok dönüşüm (çarpışmasız süs)
static func multi(p: Node3D, mesh: Mesh, xf: Array, col: Color, pat := "") -> MultiMeshInstance3D:
	if xf.is_empty():
		return null
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xf.size()
	for i in xf.size():
		mm.set_instance_transform(i, xf[i])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = Props.mat(col, 0.0, false, pat)
	p.add_child(mi)
	return mi


static func box_mesh(s: Vector3) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = s
	return m


static func cyl_mesh(r: float, h: float, seg := 8) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = r
	m.bottom_radius = r
	m.height = h
	m.radial_segments = seg
	m.rings = 1
	return m


## Mazgal sırası: x0..x1 arası, z'de sabit, üst yüzeyin y'sinde (mazgal yüksekliği 1,0 m'ye kadar siper gibi)
static func merlons(p: Node3D, x0: float, x1: float, z: float, y: float, col: Color, step := 1.6) -> void:
	var xf: Array = []
	var x := x0 + 0.4
	while x < x1 - 0.3:
		xf.append(Transform3D(Basis.IDENTITY, Vector3(x, y + 0.45, z)))
		x += step
	multi(p, box_mesh(Vector3(0.8, 0.9, 0.5)), xf, col, "ashlar")


## Yatay tuğla/taş bant (görsel, ince; yüzeyden 2 cm taşar)
static func band(p: Node3D, x0: float, x1: float, y: float, z: float, thick: float, col := BRICK, h := 0.3) -> void:
	Props.box(p, Vector3(absf(x1 - x0), h, 0.04), Vector3((x0 + x1) * 0.5, y, z), col)


## Ahşap fıçı (çarpışmalı değil; kümeler için küçük katı taban yok)
static func barrel(p: Node3D, pos: Vector3) -> void:
	Props.cyl(p, 0.34, 0.9, pos + Vector3(0, 0.45, 0), TIMBER, Vector3.ZERO, 8, 0.3)
	Props.cyl(p, 0.355, 0.05, pos + Vector3(0, 0.25, 0), IRON, Vector3.ZERO, 8)
	Props.cyl(p, 0.355, 0.05, pos + Vector3(0, 0.65, 0), IRON, Vector3.ZERO, 8)


## Fıçı yığını: n x m taban, üst üste (katı: tek kutu hacmi; sandık gibi tırmanılır)
static func barrel_stack(p: Node3D, pos: Vector3, nx: int, nz: int, layers: int) -> void:
	var w := nx * 0.72
	var d := nz * 0.72
	var hh := 0.9 * layers
	var b := blk(p, Vector3(w, hh - 0.02, d), pos + Vector3(0, (hh - 0.02) * 0.5, 0), TIMBER_D)
	b.name = "FicStack"
	for l in layers:
		for i in nx:
			for j in nz:
				var o := Vector3((i + 0.5) * 0.72 - w * 0.5, 0.9 * l, (j + 0.5) * 0.72 - d * 0.5)
				var c := Props.cyl(p, 0.34, 0.9, pos + o + Vector3(0, 0.45, 0), TIMBER if (i + j + l) % 2 == 0 else Color("7a5a38"), Vector3.ZERO, 8, 0.3)
				c.position.y += 0.0
	# yığının tepe örtüsü: kutu içinde kalır, fıçı üstleri dışa taşar -> iki cm pay bırakıldı


## Balya yığını (kumaş, yün): katı blok + şerit görünümü
static func bale_stack(p: Node3D, pos: Vector3, nx: int, nz: int, layers: int, col := Color("d8c9a0")) -> void:
	var w := nx * 1.0
	var d := nz * 0.6
	var hh := 0.5 * layers
	blk(p, Vector3(w, hh, d), pos + Vector3(0, hh * 0.5, 0), col)
	for l in layers - 1:
		Props.box(p, Vector3(w + 0.04, 0.03, d + 0.04), pos + Vector3(0, 0.5 * (l + 1), 0), IRON)
	for i in nx:
		Props.box(p, Vector3(0.04, hh + 0.02, d + 0.05), pos + Vector3((i + 0.5) - w * 0.5, hh * 0.5, 0), Color("6a4a2c"))


## Sandık yığını (tırmanma basamağı): kademeli, her kademe 0,5 m
static func crate_steps(p: Node3D, base: Vector3, dir: Vector3, n: int) -> Array:
	var d := dir.normalized()
	var ang := rad_to_deg(atan2(d.x, d.z))
	for i in n:
		var h := 0.5 * (n - i)
		blk(p, Vector3(1.3, h, 1.0), base + d * (1.0 * i + 0.5) + Vector3(0, h * 0.5, 0), Color("8a6a40") if i % 2 == 0 else Color("7a5a38"), "wood", Vector3(0, ang, 0))
	return [base, base + d * n + Vector3(0, 0.5 * n, 0)]


## Kemerli kapı çerçevesi görseli (cephe düzleminde, +z'ye bakan): açıklık w x h, y0 tabanda
static func arch_front(p: Node3D, cx: float, y0: float, z: float, w: float, h: float, col: Color) -> void:
	Props.box(p, Vector3(0.35, h, 0.1), Vector3(cx - w * 0.5 - 0.17, y0 + h * 0.5, z), col)
	Props.box(p, Vector3(0.35, h, 0.1), Vector3(cx + w * 0.5 + 0.17, y0 + h * 0.5, z), col)
	Props.box(p, Vector3(w + 0.7, 0.4, 0.1), Vector3(cx, y0 + h + 0.2, z), col)
	Props.cyl(p, w * 0.5 + 0.1, 0.1, Vector3(cx, y0 + h + 0.45, z), col, Vector3(90, 0, 0), 10)


## Beşik çatı: katı üçgen prizma (çatıda durulur, içine düşülmez) + üstünde kiremit görseli (2 cm pay).
static func gable_roof(p: Node3D, cx: float, y: float, cz: float, w: float, l: float, rise: float, col := TILE, along_z := true) -> void:
	var holder := StaticBody3D.new()
	holder.position = Vector3(cx, y, cz)
	p.add_child(holder)
	if not along_z:
		holder.rotation.y = PI * 0.5
		var t := w
		w = l
		l = t
	var cs := CollisionShape3D.new()
	var conv := ConvexPolygonShape3D.new()
	conv.points = PackedVector3Array([Vector3(-w * 0.5, 0, -l * 0.5), Vector3(w * 0.5, 0, -l * 0.5), Vector3(0, rise, -l * 0.5),
		Vector3(-w * 0.5, 0, l * 0.5), Vector3(w * 0.5, 0, l * 0.5), Vector3(0, rise, l * 0.5)])
	cs.shape = conv
	holder.add_child(cs)
	var ang := atan2(rise, w * 0.5)
	var slope := sqrt(rise * rise + (w * 0.5) * (w * 0.5))
	for s in [-1.0, 1.0]:
		var nrm := Vector3(s * sin(ang), cos(ang), 0)
		var c := Vector3(s * w * 0.25, rise * 0.5, 0) + nrm * 0.08
		var pl := Props.box(holder, Vector3(slope + 0.3, 0.12, l + 0.5), c, col, Vector3(0, 0, -s * rad_to_deg(ang)))
		pl.name = "Tile"
	var rows := int(slope / 0.55)
	var xf: Array = []
	for s in [-1.0, 1.0]:
		var nrm2 := Vector3(s * sin(ang), cos(ang), 0)
		for i in rows:
			var t2 := (i + 0.5) / rows
			var pos := Vector3(s * w * 0.5 * (1.0 - t2), rise * t2, 0) + nrm2 * 0.16
			xf.append(Transform3D(Basis.from_euler(Vector3(0, 0, -s * ang)), pos))
	multi(holder, box_mesh(Vector3(0.1, 0.05, l + 0.55)), xf, TILE_D)
	Props.box(holder, Vector3(0.3, 0.16, l + 0.6), Vector3(0, rise + 0.06, 0), TILE_D)


## Pencere: cephede koyu pano + çerçeve + kepenk (+z yüzüne bakar). Çarpışmasız.
static func window(p: Node3D, pos: Vector3, w := 0.6, h := 0.9, shutter := Color("3a5a8a"), dir_z := 1.0) -> void:
	Props.box(p, Vector3(w, h, 0.05), pos + Vector3(0, 0, dir_z * 0.02), Color("1d1a18"))
	Props.box(p, Vector3(w + 0.2, 0.08, 0.07), pos + Vector3(0, h * 0.5 + 0.04, dir_z * 0.03), Color("5e4e3e"))
	Props.box(p, Vector3(w + 0.2, 0.08, 0.07), pos + Vector3(0, -h * 0.5 - 0.04, dir_z * 0.03), Color("5e4e3e"))
	for s in [-1.0, 1.0]:
		Props.box(p, Vector3(w * 0.45, h, 0.04), pos + Vector3(s * (w * 0.5 + w * 0.2), 0, dir_z * 0.04), shutter)


## Kapı: ahşap kanat + çivi şeritleri + taş söve (cepheye yapışık). h = 2,2.
static func door(p: Node3D, pos: Vector3, dir_z := 1.0, w := 1.2, h := 2.2, col := Color("5a3a22")) -> void:
	Props.box(p, Vector3(w, h, 0.08), pos + Vector3(0, h * 0.5, dir_z * 0.03), col)
	for i in 3:
		Props.box(p, Vector3(w, 0.07, 0.1), pos + Vector3(0, 0.45 + i * 0.7, dir_z * 0.04), IRON)
	Props.box(p, Vector3(w + 0.5, 0.25, 0.14), pos + Vector3(0, h + 0.12, dir_z * 0.04), STONE_D)
	Props.box(p, Vector3(0.25, h, 0.14), pos + Vector3(-w * 0.5 - 0.12, h * 0.5, dir_z * 0.04), STONE_D)
	Props.box(p, Vector3(0.25, h, 0.14), pos + Vector3(w * 0.5 + 0.12, h * 0.5, dir_z * 0.04), STONE_D)


## Su yüzeyi + deniz tabanı (altında yürünür taban: suya düşen çıkabilir). x0..x1, z0..z1, su yüzeyi y=0
static func sea(p: Node3D, x0: float, x1: float, z0: float, z1: float, depth := 1.6) -> void:
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(absf(x1 - x0), absf(z1 - z0))
	w.mesh = pm
	var m := Props.mat(Color(0.25, 0.45, 0.55, 0.78), 0.0, true, "", false)
	w.material_override = m
	w.position = Vector3((x0 + x1) * 0.5, -0.35, (z0 + z1) * 0.5)
	p.add_child(w)
	slab(p, x0, x1, z0, z1, -depth - 0.5, -depth, Color("6a6a5a"), "cobble")


## Ahşap iskele tahtası + direk sırası: x0..x1 (uzunluk boyunca), z sabit; yükseklik y, genişlik w (>= 1,6)
static func jetty(p: Node3D, z0: float, z1: float, x: float, y: float, w: float, col := Color("7a5a38")) -> void:
	var b := blk(p, Vector3(w, 0.18, absf(z1 - z0)), Vector3(x, y - 0.09, (z0 + z1) * 0.5), col, "wood")
	b.name = "Jetty"
	var n := int(absf(z1 - z0) / 2.4) + 1
	var xf: Array = []
	for i in n:
		var z := minf(z0, z1) + i * 2.4
		for s in [-1.0, 1.0]:
			xf.append(Transform3D(Basis.IDENTITY, Vector3(x + s * (w * 0.5 - 0.12), (y - 1.8) * 0.5, z)))
	multi(p, cyl_mesh(0.14, y + 1.8, 6), xf, TIMBER_D, "wood")
	# kenar halat/korkuluk yok (iskele yaya yolu açık); bağlama babaları
	for i in range(0, n, 2):
		var z2 := minf(z0, z1) + i * 2.4
		Props.cyl(p, 0.11, 0.4, Vector3(x + (w * 0.5 - 0.15), y + 0.2, z2), TIMBER_D, Vector3.ZERO, 6)
		Props.cyl(p, 0.11, 0.4, Vector3(x - (w * 0.5 - 0.15), y + 0.2, z2), TIMBER_D, Vector3.ZERO, 6)
