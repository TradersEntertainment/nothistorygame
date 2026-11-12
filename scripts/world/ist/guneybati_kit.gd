class_name IstGbKit
extends RefCounted
## Güneybatı parçası için ortak yapı taşları (Props üstüne ince sarmalayıcılar).
## Her işlev host == null iken HİÇBİR ŞEY kurmaz (yalnız perches/climbs bilgisini hesaplamak için builder'lar
## host'suz da çalıştırılır). Eksenler: +x doğu, -z kuzey, zemin y = 0.

const DOOR_W := 1.7
const DOOR_H := 2.3
const STEP_RISE := 0.24      # dış merdiven basamağı (player STEP_H = 0.42, zıplama ≈ 0.66)
const STEP_RUN := 0.42
const CRATE_H := 0.5

const C_BRICK := Color("c98a62")
const C_STONE := Color("dccaa6")
const C_STONE_D := Color("b9a584")
const C_PLASTER := Color("e9dcc0")
const C_TILE := Color("b4553a")
const C_LEAD := Color("8d97a0")
const C_WOOD := Color("7b5934")
const C_WOOD_D := Color("5a3f24")
const C_DARK := Color("2b2320")
const C_MARBLE := Color("eee6d6")
const C_GRASS := Color("728f3e")
const C_DIRT := Color("9b7d55")
const C_WATER := Color("5f93b4")


static func sb(h: Node3D, size: Vector3, pos: Vector3, col: Color, pat := "", rot := Vector3.ZERO) -> StaticBody3D:
	if h == null:
		return null
	var b := Props.solid(h, size, pos, col, rot)
	if pat != "":
		Props.set_pattern(b, col, pat)
	return b


static func vb(h: Node3D, size: Vector3, pos: Vector3, col: Color, pat := "", rot := Vector3.ZERO) -> MeshInstance3D:
	if h == null:
		return null
	var m := Props.box(h, size, pos, col, rot)
	if pat != "":
		Props.set_pattern(m, col, pat)
	return m


## Silindir (pos = ortası). solid: dışbükey kabuk çarpışması.
static func cy(h: Node3D, r: float, ht: float, pos: Vector3, col: Color, seg := 10, top_r := -1.0, pat := "", solid := true) -> MeshInstance3D:
	if h == null:
		return null
	var m := Props.cyl(h, r, ht, pos, col, Vector3.ZERO, seg, top_r)
	if pat != "":
		Props.set_pattern(m, col, pat)
	if solid:
		Props.make_solid(m, 0.92)
	return m


static func bl(h: Node3D, r: float, pos: Vector3, col: Color, sc := Vector3.ONE, seg := 12, solid := true) -> MeshInstance3D:
	if h == null:
		return null
	var m := Props.ball(h, r, pos, col, sc, seg)
	if solid:
		Props.make_solid(m, 0.95)
	return m


## Dolu üçgen alınlık / çatı yanı (ridge x ya da z ekseninde). Dışbükey kabukla katı.
static func prism_solid(h: Node3D, size: Vector3, pos: Vector3, col: Color, rot := Vector3.ZERO, pat := "") -> void:
	if h == null:
		return
	var m := Props.prism(h, size, pos, col, rot)
	if pat != "":
		Props.set_pattern(m, col, pat)
	Props.make_solid(m, 1.0)


## Beşik çatı: yürünebilir eğimli iki katı levha + mahya + iki alınlık. axis "x": mahya x boyunca.
## W = saçak-saçak genişlik (duvar dışı), L = mahya boyu. rise = mahya yüksekliği (saçaktan).
static func gable(h: Node3D, c: Vector3, W: float, L: float, rise: float, axis: String, col: Color, wall_col: Color, t := 0.4, close_ends := true) -> void:
	if h == null:
		return
	var half := W * 0.5
	var ang := rad_to_deg(atan2(rise, half))
	var sl := sqrt(half * half + rise * rise) + 0.12
	var th := 0.3
	for s in [-1.0, 1.0]:
		var mid_off: float = s * half * 0.5
		var n := Vector2(sin(deg_to_rad(ang)), cos(deg_to_rad(ang)))     # (yatay bileşen, düşey) üst normal
		var cp := Vector3.ZERO
		var rot := Vector3.ZERO
		if axis == "x":
			cp = c + Vector3(0, rise * 0.5, mid_off) - Vector3(0, n.y, s * n.x) * (th * 0.5)
			rot = Vector3(s * ang, 0, 0)
			sb(h, Vector3(L + 0.5, th, sl), cp, col, "tiles", rot)
		else:
			cp = c + Vector3(mid_off, rise * 0.5, 0) - Vector3(s * n.x, n.y, 0) * (th * 0.5)
			rot = Vector3(0, 0, -s * ang)
			sb(h, Vector3(sl, th, L + 0.5), cp, col, "tiles", rot)
	# mahya
	if axis == "x":
		sb(h, Vector3(L + 0.6, 0.22, 0.5), c + Vector3(0, rise + 0.02, 0), col.darkened(0.2))
	else:
		sb(h, Vector3(0.5, 0.22, L + 0.6), c + Vector3(0, rise + 0.02, 0), col.darkened(0.2))
	# çatı kiremit sıraları (ince koyu çizgiler, çatı eğimine paralel): görsel
	var rows := int(L / 1.1)
	for i in rows:
		var off := -L * 0.5 + (i + 0.5) * (L / rows)
		for s in [-1.0, 1.0]:
			var mid_off2: float = s * half * 0.5
			var top := c.y + rise * 0.5
			if axis == "x":
				var p := Vector3(c.x + off, top + 0.025, c.z + mid_off2)
				p -= Vector3(0, 0, 0)
				vb(h, Vector3(0.06, 0.03, sl - 0.2), p + Vector3(0, 0, 0), col.darkened(0.22), "", Vector3(s * ang, 0, 0))
			else:
				var p2 := Vector3(c.x + mid_off2, top + 0.025, c.z + off)
				vb(h, Vector3(sl - 0.2, 0.03, 0.06), p2, col.darkened(0.22), "", Vector3(0, 0, -s * ang))
	if close_ends:
		for e in [-1.0, 1.0]:
			if axis == "x":
				prism_solid(h, Vector3(W, rise, t), c + Vector3(e * (L * 0.5 - t * 0.5), rise * 0.5, 0), wall_col, Vector3(0, 0, 0) if false else Vector3(0, 90, 0), "brick")
			else:
				prism_solid(h, Vector3(W, rise, t), c + Vector3(0, rise * 0.5, e * (L * 0.5 - t * 0.5)), wall_col, Vector3.ZERO, "brick")


## Eksen hizalı duvar: a→b (XZ). Kapı açıklıkları [[merkez_s, genişlik], …] gerçekten açıktır (lento üstte).
## wins: eşit aralıklı pencere sayısı (koyu kutu + kemer, iki yüzde 2 cm taşar).
static func wall(h: Node3D, a: Vector2, b: Vector2, ht: float, t: float, col: Color, pat := "brick", doors: Array = [], wins := 0, y0 := 0.0, wy := -1.0, wh := 1.3, dh := DOOR_H) -> void:
	var along_x := absf(b.x - a.x) >= absf(b.y - a.y)
	var L := a.distance_to(b)
	var d := (b - a) / maxf(L, 0.001)
	var cuts: Array = []
	for dr in doors:
		cuts.append([dr[0] - dr[1] * 0.5, dr[0] + dr[1] * 0.5])
	cuts.sort_custom(func(p, q): return p[0] < q[0])
	var s0 := 0.0
	var segs: Array = []
	for c in cuts:
		if c[0] > s0 + 0.01:
			segs.append([s0, c[0]])
		s0 = c[1]
	if L > s0 + 0.01:
		segs.append([s0, L])
	if h != null:
		for sg in segs:
			var ln: float = sg[1] - sg[0]
			var mid: Vector2 = a + d * ((sg[0] + sg[1]) * 0.5)
			var size := Vector3(ln, ht, t) if along_x else Vector3(t, ht, ln)
			sb(h, size, Vector3(mid.x, y0 + ht * 0.5, mid.y), col, pat)
		for c in cuts:
			if ht > dh + 0.25:
				var ln2: float = c[1] - c[0]
				var mid2: Vector2 = a + d * ((c[0] + c[1]) * 0.5)
				var lh := ht - dh
				var size2 := Vector3(ln2, lh, t) if along_x else Vector3(t, lh, ln2)
				sb(h, size2, Vector3(mid2.x, y0 + dh + lh * 0.5, mid2.y), col, pat)
				# lento taşı (açık renk)
				var lsz := Vector3(ln2 + 0.5, 0.22, t + 0.06) if along_x else Vector3(t + 0.06, 0.22, ln2 + 0.5)
				vb(h, lsz, Vector3(mid2.x, y0 + dh + 0.11, mid2.y), C_STONE)
		if wins > 0:
			var perp := Vector2(-d.y, d.x)
			var wyy := wy if wy > 0.0 else y0 + ht * 0.58
			for i in wins:
				var sp := (i + 0.5) * L / wins
				var skip := false
				for c in cuts:
					if sp > c[0] - 0.6 and sp < c[1] + 0.6:
						skip = true
				if skip or wyy + wh * 0.5 > y0 + ht - 0.15:
					continue
				var wp := a + d * sp
				var wsz := Vector3(0.8, wh, t + 0.04) if along_x else Vector3(t + 0.04, wh, 0.8)
				vb(h, wsz, Vector3(wp.x, wyy, wp.y), C_DARK)
				var arch := Props.ball(h, 0.4, Vector3(wp.x, wyy + wh * 0.5, wp.y), C_DARK, Vector3(1, 1, 0.16) if along_x else Vector3(0.16, 1, 1), 8)
				arch.scale = Vector3(1, 0.9, (t + 0.04) / 0.8) if along_x else Vector3((t + 0.04) / 0.8, 0.9, 1)
				perp = perp


## Dış merdiven: başlangıç tabanı (x,z), yön dir (birim, eksen hizalı), n basamak. Her basamak yerden dolu katı.
## Dönüş: tepe noktası (üst basamağın yüzü, ön kenar ortası).
static func stair(h: Node3D, x: float, z: float, y0: float, dir: Vector2, n: int, w := 1.6, col := C_STONE_D, rise := STEP_RISE, run := STEP_RUN) -> Vector3:
	var top := Vector3.ZERO
	for i in n:
		var ht := y0 + rise * (i + 1)
		var c2 := Vector2(x, z) + dir * (run * (i + 0.5))
		var sz := Vector3(run + 0.02, ht, w) if absf(dir.x) > 0.5 else Vector3(w, ht, run + 0.02)
		sb(h, sz, Vector3(c2.x, ht * 0.5, c2.y), col, "ashlar")
		top = Vector3(c2.x, ht, c2.y)
	return top


## Sandık/fıçı yığını basamağı: duvara dayalı, duvara doğru yükselen sandıklar (her biri CRATE_H daha yüksek).
static func crates(h: Node3D, base: Vector3, toward: Vector2, n: int, w := 1.2) -> Vector3:
	var top := Vector3.ZERO
	for i in n:
		var ht := base.y + CRATE_H * (i + 1)
		var c2 := Vector2(base.x, base.z) + toward * (0.7 * (i + 0.5))
		var sz := Vector3(0.7, ht - base.y + 0.1, w) if absf(toward.x) > 0.5 else Vector3(w, ht - base.y + 0.1, 0.7)
		sb(h, sz, Vector3(c2.x, base.y + (ht - base.y - 0.1) * 0.5 + 0.0, c2.y), C_WOOD if i % 2 == 0 else C_WOOD_D, "wood")
		top = Vector3(c2.x, ht, c2.y)
	return top


## Kubbe: kasnak (silindir) + pencereler + dilimli kurşun kubbe + haç. base_y = kasnak tabanı.
static func dome(h: Node3D, c: Vector3, r: float, drum_h: float, dome_h: float, lead := C_LEAD, wall := C_BRICK, ribs := 12, windows := 8) -> float:
	var top := c.y + drum_h
	if h != null:
		cy(h, r * 1.02, drum_h, Vector3(c.x, c.y + drum_h * 0.5, c.z), wall, 16, -1.0, "brick")
		# kasnak kornişi
		cy(h, r * 1.08, 0.2, Vector3(c.x, top - 0.1, c.z), C_STONE, 16, -1.0, "", false)
		for i in windows:
			var a := TAU * i / windows
			var p := Vector3(c.x + sin(a) * r * 1.02, c.y + drum_h * 0.52, c.z + cos(a) * r * 1.02)
			var wb := Props.box(h, Vector3(0.7, drum_h * 0.5, 0.06), p, C_DARK, Vector3(0, rad_to_deg(a), 0))
			wb.scale = Vector3(1, 1, 1)
		bl(h, r, Vector3(c.x, top, c.z), lead, Vector3(1, dome_h / r, 1), 14)
		for i in ribs:
			var rb := Props.ball(h, r, Vector3(c.x, top, c.z), lead.darkened(0.18), Vector3(0.03, dome_h / r * 1.012, 1.012), 14)
			rb.rotation_degrees = Vector3(0, 360.0 * i / (ribs * 2), 0)
		# haç
		var ty := top + dome_h
		vb(h, Vector3(0.1, 0.9, 0.1), Vector3(c.x, ty + 0.4, c.z), C_STONE)
		vb(h, Vector3(0.5, 0.1, 0.1), Vector3(c.x, ty + 0.62, c.z), C_STONE)
	return top + dome_h


## Kiremit çizgili yarım silindir apsis (dışbükey kabuk) + külah çatı.
static func apse(h: Node3D, c: Vector3, r: float, ht: float, wall: Color, roof: Color, windows := 3) -> void:
	if h == null:
		return
	cy(h, r, ht, Vector3(c.x, ht * 0.5, c.z), wall, 14, -1.0, "brick")
	cy(h, r * 1.06, ht * 0.4 if ht > 3 else 0.9, Vector3(c.x, ht + (ht * 0.4 if ht > 3 else 0.9) * 0.5, c.z), roof, 14, 0.08, "tiles")
	for i in windows:
		var a := deg_to_rad(-55.0 + 55.0 * i)
		var p := Vector3(c.x + cos(a) * r * 1.0, ht * 0.55, c.z + sin(a) * r * 1.0)
		vb(h, Vector3(0.12, 1.5, 0.8), p, C_DARK, "", Vector3(0, -rad_to_deg(a), 0))


## Aynı kutudan çok kopya (MultiMesh): kiremit sırası, bostan tarhı, kütük vb.
static func mm(h: Node3D, mesh: Mesh, col: Color, xfs: Array, pat := "") -> MultiMeshInstance3D:
	if h == null or xfs.is_empty():
		return null
	var m := MultiMesh.new()
	m.transform_format = MultiMesh.TRANSFORM_3D
	m.mesh = mesh
	m.instance_count = xfs.size()
	for i in xfs.size():
		m.set_instance_transform(i, xfs[i])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = m
	mi.material_override = Props.mat(col, 0.0, false, pat, false)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	h.add_child(mi)
	return mi


static func box_mesh(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b


static func cone_mesh(r: float, ht: float, seg := 6) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.bottom_radius = r
	c.top_radius = 0.02
	c.height = ht
	c.radial_segments = seg
	c.rings = 1
	return c


## Kafes silüet (lod 2): tek renkli kütle + isteğe bağlı tepe.
static func silhouette(h: Node3D, size: Vector3, col: Color, roof_col := C_TILE, roof_rise := 0.0, dome_r := 0.0) -> void:
	if h == null:
		return
	sb(h, size - Vector3(0, 0, 0), Vector3(0, size.y * 0.5, 0), col)
	if roof_rise > 0.0:
		Props.prism(h, Vector3(size.x, roof_rise, size.z), Vector3(0, size.y + roof_rise * 0.5, 0), roof_col, Vector3(0, 90, 0) if size.x < size.z else Vector3.ZERO)
	if dome_r > 0.0:
		Props.ball(h, dome_r, Vector3(0, size.y + roof_rise, 0), C_LEAD, Vector3(1, 0.7, 1), 8)


static func out_add(out: Dictionary, key: String, v: Variant) -> void:
	if not out.has(key):
		out[key] = []
	(out[key] as Array).append(v)
