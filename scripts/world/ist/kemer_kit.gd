class_name IstKemerKit
extends RefCounted
## Kemer parçası ortak yardımcıları: katı kutu, kubbe, tambur, tonoz, merdiven, çokgen gövde, MultiMesh.
## Her şey ilkel parçalardan (Props); "k" yalnız kütleyi ölçekler, insan ölçüsü sabit kalır.

const STONE := Color("d8c7a4")        # kesme taş, sıcak
const STONE_D := Color("b9a47c")
const BRICK := Color("c0795a")        # Bizans tuğlası
const BRICK_D := Color("9c5a42")
const LEAD := Color("77828f")         # kurşun kubbe
const TILE := Color("b4553a")         # kiremit
const MOSS := Color("6f8a4a")
const SOIL := Color("7a6446")
const DARK := Color("2a2a30")
const GOLD := Color("d4b24c")


## Katı kutu: tabanı (x, y0, z), boyu size.
static func blk(host: Node3D, size: Vector3, base: Vector3, col: Color, pat := "", rot_y := 0.0) -> StaticBody3D:
	var b := Props.solid(host, size, base + Vector3(0, size.y * 0.5, 0), Color.WHITE if pat != "" else col, Vector3(0, rot_y, 0))
	if pat != "":
		Props.set_pattern(b, col, pat)
	return b


## Yalnız görüntü kutusu (taban merkezli).
static func vis(host: Node3D, size: Vector3, base: Vector3, col: Color, pat := "", rot_deg := Vector3.ZERO) -> MeshInstance3D:
	var m := Props.box(host, size, base + Vector3(0, size.y * 0.5, 0), Color.WHITE if pat != "" else col, rot_deg)
	if pat != "":
		m.material_override = Props.mat(col, 0.0, false, pat)
	return m


static func cylinder_solid(host: Node3D, r: float, h: float, base: Vector3, col: Color, pat := "", seg := 16, top_r := -1.0) -> MeshInstance3D:
	var mi := Props.cyl(host, r, h, base + Vector3(0, h * 0.5, 0), Color.WHITE if pat != "" else col, Vector3.ZERO, seg, top_r)
	if pat != "":
		mi.material_override = Props.mat(col, 0.0, false, pat)
	var bd := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var sh := CylinderShape3D.new()
	sh.radius = maxf(r, top_r) * 0.98
	sh.height = h
	cs.shape = sh
	bd.position = base + Vector3(0, h * 0.5, 0)
	bd.add_child(cs)
	host.add_child(bd)
	return mi


## Yarım küre kubbe + kaburgalar (MultiMesh) + tepe haçı + tepede düz katı kapak (konma noktası).
## base: kubbe eteğinin merkezi. r: yarıçap, hy: yükseklik oranı (0,5 sığ).
static func dome(host: Node3D, r: float, base: Vector3, col: Color, ribs := 16, hy := 0.55, cross := true, lod := 0) -> float:
	var segs := 24 if lod == 0 else 12
	var ball := Props.ball(host, r, base, col, Vector3(1.0, hy, 1.0), segs)
	ball.material_override = Props.mat(col, 0.0, false, "")
	# Çarpışma: ağın dışbükey kabuğu (alt yarı tamburun içinde)
	Props.make_solid(ball, 0.97)
	var top := base.y + r * hy
	if lod < 2:
		if ribs > 0 and lod == 0:
			var xs: Array = []
			for i in ribs:
				var a := TAU * i / ribs
				for j in 3:
					var el := 0.3 + j * 0.42
					var pp := Vector3(r * cos(el) * sin(a), r * hy * sin(el), r * cos(el) * cos(a))
					var tg := Vector3(-r * sin(el) * sin(a), r * hy * cos(el), -r * sin(el) * cos(a)).normalized()
					var nr := Vector3(sin(a) * cos(el), sin(el) / hy, cos(a) * cos(el)).normalized()
					var bs := Basis.looking_at(tg, nr)
					xs.append(Transform3D(bs, base + pp * 1.004))
			var rib_mat := Props.mat(col.lightened(0.22), 0.0, false, "", false)
			multi(host, _box_mesh(Vector3(0.12, 0.08, r * 0.5)), rib_mat, xs)
		if cross:
			# Düz katı tepe kapağı + haç
			var cap := Props.cyl(host, 0.7, 0.3, Vector3(base.x, top - 0.05, base.z), STONE_D, Vector3.ZERO, 10)
			Props.make_solid(cap)
			Props.box(host, Vector3(0.12, 1.5, 0.12), Vector3(base.x, top + 0.9, base.z), GOLD)
			Props.box(host, Vector3(0.7, 0.12, 0.12), Vector3(base.x, top + 1.25, base.z), GOLD)
	return top + 0.1


## Pencereli tambur (kasnak): silindir + pencere kemerleri + payandalar. y0 tabanı, çarpışmalı.
static func drum(host: Node3D, r: float, h: float, base: Vector3, col: Color, n := 12, lod := 0) -> void:
	var mi := cylinder_solid(host, r, h, base, col, "brick" if col == BRICK else "ashlar", 20 if lod == 0 else 12)
	if lod > 0:
		return
	var xs: Array = []
	var xp: Array = []
	for i in n:
		var a := TAU * i / n
		xs.append(Transform3D(Basis.from_euler(Vector3(0, a, 0)), base + Vector3(sin(a) * (r + 0.02), h * 0.5, cos(a) * (r + 0.02))))
		var b := a + TAU / (2.0 * n)
		xp.append(Transform3D(Basis.from_euler(Vector3(0, b, 0)), base + Vector3(sin(b) * (r + 0.1), h * 0.5, cos(b) * (r + 0.1))))
	multi(host, _box_mesh(Vector3(minf(0.55, r * 0.2), h * 0.55, 0.14)), Props.mat(DARK, 0.0, false, "", false), xs)
	multi(host, _box_mesh(Vector3(0.28, h, 0.3)), Props.mat(col.darkened(0.12), 0.0, false, "", false), xp)
	# silme (korniş)
	var cor := Props.cyl(host, r + 0.18, 0.22, base + Vector3(0, h + 0.02, 0), STONE, Vector3.ZERO, 20)
	Props.make_solid(cor)


## Yatay ana eksen boyunca yarım silindir tonoz (görsel + dışbükey katı). axis_z=true: eksen z boyunca.
static func barrel(host: Node3D, r: float, length: float, base: Vector3, col: Color, axis_z := true, seg := 12) -> void:
	var mi := Props.cyl(host, r, length, base, col, Vector3(90, 0, 0) if axis_z else Vector3(0, 0, 90), seg)
	mi.material_override = Props.mat(col, 0.0, false, "tiles" if col == TILE else "")
	Props.make_solid(mi, 1.0)


## Yarım daire apsis (plan): merkez c (taban), yarıçap r, yükseklik h; +z yönüne açılır (kapak = yarım silindir)
static func apse(host: Node3D, c: Vector3, r: float, h: float, col: Color, dir_deg: float, lod := 0) -> void:
	var holder := Node3D.new()
	holder.position = c
	holder.rotation_degrees = Vector3(0, dir_deg, 0)
	host.add_child(holder)
	cylinder_solid(holder, r, h, Vector3.ZERO, col, "brick" if col == BRICK else "ashlar", 12 if lod == 0 else 8)
	if lod == 0:
		# yarım kubbe başlığı (konik çatı)
		var cone := Props.cyl(holder, 0.1, 1.4, Vector3(0, h + 0.5, 0), TILE, Vector3.ZERO, 12, r * 1.02)
		Props.make_solid(cone)
		for i in 3:
			var a := PI * (i - 1) / 2.4
			Props.box(holder, Vector3(0.5, 1.3, 0.12), Vector3(sin(a) * (r + 0.03), h * 0.5, cos(a) * (r + 0.03)), DARK, Vector3(0, rad_to_deg(a), 0))


## Taş basamak dizisi: from taban noktası (yerde), dir yatay yön, n basamak, basamak yüksekliği rise, derinliği run, genişliği w.
static func stairs(host: Node3D, from: Vector3, dir: Vector3, n: int, rise: float, run: float, w: float, col: Color, pat := "ashlar") -> Vector3:
	var d := dir.normalized()
	var ang := rad_to_deg(atan2(d.x, d.z))
	for i in n:
		var c := from + d * (run * (i + 0.5))
		var hh := rise * (i + 1)
		var s := Props.solid(host, Vector3(w, hh, run + 0.02), Vector3(c.x, from.y + hh * 0.5, c.z), Color.WHITE, Vector3(0, ang, 0))
		Props.set_pattern(s, col, pat)
	return from + d * (run * n) + Vector3(0, rise * n, 0)


## MultiMesh: mesh'i xforms (Transform3D listesi) ile yinele.
static func multi(host: Node3D, mesh: Mesh, material: Material, xforms: Array) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = material
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	host.add_child(mmi)
	return mmi


static func _box_mesh(size: Vector3) -> BoxMesh:
	var bm := BoxMesh.new()
	bm.size = size
	return bm


## Çatı sırtı: eğimli kiremit (görsel prizma) + altında düz katı levha. L: sırt boyu (z), W: genişlik (x).
static func gable(host: Node3D, W: float, L: float, rise: float, base: Vector3, col: Color) -> void:
	var pm := Props.prism(host, Vector3(W + 0.4, rise, L + 0.4), base + Vector3(0, rise * 0.5, 0), col)
	pm.material_override = Props.mat(col, 0.0, false, "tiles")
	Props.make_solid(pm)


## Moloz öbeği (tırmanılabilir basamaklı): merkez base, yarıçap r, yükseklik h. Üst üste küçülen katı tabakalar.
static func rubble(host: Node3D, base: Vector3, r: float, h: float, seed_v := 1, col := STONE_D) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v * 31 + 7
	var steps := maxi(2, int(ceil(h / 0.32)))
	var layer := h / steps
	for i in steps:
		var rr := r * (1.0 - 0.8 * float(i) / steps)
		var off := Vector3(rng.randf_range(-0.2, 0.2), 0, rng.randf_range(-0.2, 0.2)) * r * 0.3
		var s := blk(host, Vector3(rr * 2.0, layer, rr * 1.7), base + off + Vector3(0, layer * i, 0), col, "rubble", rng.randf_range(0, 80))
		s.rotation_degrees.x = 0.0
	return [base + Vector3(r + 0.6, 0, 0), base + Vector3(0, h, 0)]


## Ağaç (selvi/çınar/incir benzeri basit): gövde + taç. kind: "selvi" ya da "incir".
static func tree(host: Node3D, base: Vector3, h: float, kind := "selvi") -> void:
	var trunk := Props.cyl(host, 0.18, h * 0.35, base + Vector3(0, h * 0.175, 0), Color("5a4630"), Vector3.ZERO, 6)
	Props.make_solid(trunk)
	if kind == "selvi":
		Props.make_solid(Props.cyl(host, h * 0.14, h * 0.8, base + Vector3(0, h * 0.6, 0), Color("3e5a35"), Vector3.ZERO, 7, 0.02), 1.0)
	else:
		Props.make_solid(Props.ball(host, h * 0.3, base + Vector3(0, h * 0.62, 0), Color("6c8d44"), Vector3(1, 0.8, 1), 8), 0.8)


## Bostan tarhası (alçak toprak tarla, yürünür, görsel): w×d, 0,12 m yüksek katı.
static func plot(host: Node3D, base: Vector3, w: float, d: float, rot_y := 0.0) -> void:
	var s := blk(host, Vector3(w, 0.12, d), base, SOIL, "rubble", rot_y)
	s.get_child(0).material_override = Props.mat(SOIL, 0.0, false, "")
	var xs: Array = []
	var rows := maxi(2, int(w / 0.9))
	for i in rows:
		var lx := -w * 0.5 + 0.45 + i * (w - 0.9) / maxf(1.0, rows - 1.0)
		xs.append(Transform3D(Basis.from_euler(Vector3(0, deg_to_rad(rot_y), 0)), base + Basis.from_euler(Vector3(0, deg_to_rad(rot_y), 0)) * Vector3(lx, 0.2, 0)))
	multi(host, _box_mesh(Vector3(0.35, 0.16, d * 0.9)), Props.mat(Color("5f8a3c"), 0.0, false, "", false), xs)
