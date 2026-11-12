class_name IstKB
extends RefCounted
## İstanbul 1453 / kiliseler: ortak yapı yardımcıları (yalnız Props ilkelleri ve MultiMesh kullanır).
## Eksen kuralı: yapının uzun ekseni z boyunca; apsis -z (kuzey, yon_derece = 0 iken), giriş +z.
## dry = true: hiçbir düğüm kurulmaz, yalnız perches / climbs hesaplanır (perches_x / climbs_x için).
## lod 0: katı + tam ayrıntı; lod 1: ana kütleler + çatı (çarpışmasız); lod 2: birkaç kutu/kubbe.

const STONE := Color("d6c6a2")
const STONE_D := Color("b3a280")
const BRICK := Color("b4684a")
const TILE := Color("b3552f")
const TILE_D := Color("8f4226")
const LEAD := Color("8d939b")
const MARBLE := Color("d8cdb6")
const WOOD := Color("5e4129")
const WOOD_D := Color("3e2a1a")
const DARK := Color("1f170e")
const GOLD := Color("c8a040")
const IVY := Color("4d7a38")
const IVY_D := Color("3a5e2a")
const GRASS := Color("6f8c46")
const SOIL := Color("7a6446")
const WATER := Color("4a7c96")
const CYPRESS := Color("2e4a2a")

const STEP_RISE := 0.28      # dış merdiven basamağı (STEP_H = 0,42 ve zıplama 0,66 m'nin altında)
const STEP_RUN := 0.36

var host: Node3D
var k := 0.5
var lod := 0
var dry := false
var id := ""
var rng := RandomNumberGenerator.new()
var latin := false
var stone: Color = STONE
var perches: Array = []
var climbs: Array = []
var top_y := 0.0             # en yüksek nokta (yerel, pivot dahil değil)
var off := Vector3.ZERO      # çıktı kaydırması (merkezi taban ortasına almak için)
var _wf: Array = []      # pencere çerçevesi (kutu)
var _wd: Array = []      # pencere karanlığı (kutu)
var _df: Array = []      # kemer çerçevesi (disk)
var _dd: Array = []      # kemer karanlığı (disk)
var _band: Array = []    # tuğla bantları
var _ivy: Array = []     # sarmaşık topakları
var _moss: Array = []    # ot / yosun yamaları
var _stone_bits: Array = []   # moloz taşları
var _tile_rows: Array = []    # kiremit mahya sıraları


func _init(h: Node3D, k_: float, lod_: int, id_: String, dry_ := false) -> void:
	host = h
	k = k_
	lod = lod_
	id = id_
	dry = dry_
	var sv := 1453
	if h != null and h.has_meta("tohum"):
		sv = int(h.get_meta("tohum"))
	rng.seed = sv * 7919 + hash(id_)
	latin = h != null and bool(h.get_meta("latin", false))
	var t := rng.randf_range(-0.07, 0.07)
	stone = STONE.lightened(t) if t > 0.0 else STONE.darkened(-t)


## Merkez kaydırması: sonraki bütün düğümler bu pivotun altına kurulur (taban ortası = yerel başlangıç).
func set_pivot(o: Vector3) -> void:
	off = o
	if dry or host == null:
		return
	var pv := Node3D.new()
	pv.position = o
	host.add_child(pv)
	host = pv


func S(v: float) -> float:
	return v * k


## Duvar yüksekliği: kütle k ile küçülür, ama kapı (2,2 m) sığsın diye en az hmin.
func Hs(v: float, hmin := 3.4) -> float:
	return maxf(v * k, hmin)


func detail() -> bool:
	return lod == 0 and not dry


func visible() -> bool:
	return not dry


# ---------------------------------------------------------------- ilkeller

## Katı kutu: taban ortası base, boyut size (lod ≥ 1: çarpışmasız görsel).
func sb(base: Vector3, size: Vector3, color: Color, pat := "", rot_y := 0.0) -> Node3D:
	top_y = maxf(top_y, base.y + size.y)
	if dry:
		return null
	var pos := Vector3(base.x, base.y + size.y * 0.5, base.z)
	if lod == 0:
		var body := Props.solid(host, size, pos, color, Vector3(0, rot_y, 0))
		if pat != "":
			Props.set_pattern(body, color, pat)
		return body
	var mi := Props.box(host, size, pos, color, Vector3(0, rot_y, 0))
	if pat != "":
		Props.set_pattern(mi, color, pat)
	return mi


## Dönmüş katı kutu (voussoir, eğik taş): merkez c, her eksende rot (derece).
func sr(c: Vector3, size: Vector3, color: Color, pat := "", rot := Vector3.ZERO) -> Node3D:
	top_y = maxf(top_y, c.y + size.length() * 0.5)
	if dry:
		return null
	if lod == 0:
		var body := Props.solid(host, size, c, color, rot)
		if pat != "":
			Props.set_pattern(body, color, pat)
		return body
	var mi := Props.box(host, size, c, color, rot)
	if pat != "":
		Props.set_pattern(mi, color, pat)
	return mi


## İç içe kurucu: pos / rot_y'deki alt yapı. İş bitince adopt(alt, pos, rot_y) ile perches / climbs devralınır.
func sub(sub_id: String, pos: Vector3, rot_y := 0.0) -> IstKB:
	var h: Node3D = null
	if not dry:
		h = Node3D.new()
		h.position = pos
		h.rotation_degrees = Vector3(0, rot_y, 0)
		host.add_child(h)
		for key in ["tohum", "latin"]:
			if host.has_meta(key):
				h.set_meta(key, host.get_meta(key))
	var s := IstKB.new(h, k, lod, sub_id, dry)
	s.rng.seed = rng.randi()
	return s


func adopt(s: IstKB, pos: Vector3, rot_y := 0.0) -> void:
	var rb := Basis(Vector3.UP, deg_to_rad(rot_y))
	for p: Vector3 in s.perches:
		perches.append(off + pos + rb * p)
	for c in s.climbs:
		climbs.append([off + pos + rb * (c[0] - s.off) + s.off * 0.0 + rb * s.off, off + pos + rb * (c[1] - s.off) + rb * s.off, c[2]])
	top_y = maxf(top_y, pos.y + s.top_y)


## Görsel kutu (çarpışmasız, süs). Denetimde "dekor" sayılır.
func vb(base: Vector3, size: Vector3, color: Color, pat := "", rot := Vector3.ZERO, center := false) -> MeshInstance3D:
	if dry:
		return null
	var pos := base if center else Vector3(base.x, base.y + size.y * 0.5, base.z)
	var mi := Props.box(host, size, pos, color, rot)
	if pat != "":
		Props.set_pattern(mi, color, pat)
	mi.set_meta("dekor", true)
	return mi


func vc(base: Vector3, r: float, h: float, color: Color, segs := 8, rot := Vector3.ZERO, top_r := -1.0, center := false) -> MeshInstance3D:
	if dry:
		return null
	var pos := base if center else Vector3(base.x, base.y + h * 0.5, base.z)
	var mi := Props.cyl(host, r, h, pos, color, rot, segs, top_r)
	mi.set_meta("dekor", true)
	return mi


func vball(pos: Vector3, r: float, color: Color, scl := Vector3.ONE, segs := 8) -> MeshInstance3D:
	if dry:
		return null
	var mi := Props.ball(host, r, pos, color, scl, segs)
	mi.set_meta("dekor", true)
	return mi


## Katı silindir (sütun, kule, kasnak): görünen ağın dışbükey kabuğu.
func sc(base: Vector3, r: float, h: float, color: Color, pat := "", segs := 10, top_r := -1.0) -> Node3D:
	top_y = maxf(top_y, base.y + h)
	if dry:
		return null
	var mi := Props.cyl(host, r, h, Vector3(base.x, base.y + h * 0.5, base.z), color, Vector3.ZERO, segs, top_r)
	if pat != "":
		Props.set_pattern(mi, color, pat)
	if lod == 0:
		Props.make_solid(mi)
	return mi


## Katı beşik çatı (üçgen prizma): w = genişlik, rise = yükseklik, len = boy. along_z: mahya z boyunca.
## base = çatı tabanının ortası. Dışbükey kabuk: çatı altı tam doludur, üstünde durulabilir.
func gable(base: Vector3, w: float, rise: float, len: float, color: Color, along_z := true, pat := "tiles") -> Node3D:
	top_y = maxf(top_y, base.y + rise)
	if dry:
		return null
	var mi := Props.prism(host, Vector3(w, rise, len), Vector3(base.x, base.y + rise * 0.5, base.z), color,
		Vector3.ZERO if along_z else Vector3(0, 90, 0))
	if pat != "":
		Props.set_pattern(mi, color, pat)
	if lod == 0:
		Props.make_solid(mi)
	return mi


## Dik üçgen prizma (tek eğimli çatı, rampa gövdesi): yükseklik +x tarafında artar (rot_y ile döner).
## base = taban dikdörtgeninin ortası; run (x), rise (y), depth (z).
func wedge(base: Vector3, run: float, rise: float, depth: float, color: Color, rot_y := 0.0, pat := "tiles") -> Node3D:
	if dry:
		return null
	var mi := MeshInstance3D.new()
	mi.mesh = wedge_mesh(run, rise, depth)
	mi.position = base
	mi.rotation_degrees = Vector3(0, rot_y, 0)
	mi.material_override = Props.mat(color, 0.0, false, pat)
	host.add_child(mi)
	if lod == 0:
		Props.make_solid(mi)
	return mi


static func wedge_mesh(run: float, rise: float, depth: float) -> ArrayMesh:
	var x0 := -run * 0.5
	var x1 := run * 0.5
	var z0 := -depth * 0.5
	var z1 := depth * 0.5
	var a0 := Vector3(x0, 0, z0)   # alçak uç
	var b0 := Vector3(x1, 0, z0)
	var c0 := Vector3(x1, rise, z0)
	var a1 := Vector3(x0, 0, z1)
	var b1 := Vector3(x1, 0, z1)
	var c1 := Vector3(x1, rise, z1)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_tri(st, a0, c0, b0)   # arka uç
	_tri(st, a1, b1, c1)   # ön uç
	_tri(st, a0, b0, b1)
	_tri(st, a0, b1, a1)   # alt
	_tri(st, b0, c0, c1)
	_tri(st, b0, c1, b1)   # dik yüz
	_tri(st, a0, a1, c1)
	_tri(st, a0, c1, c0)   # eğim
	st.generate_normals()
	return st.commit()


static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)


## Dilimli kubbe ağı: gores dilim, her dilimin ortası çukur, kenarı (kaburga) hafif kabarık; vertex rengi dilimlere göre
## değişir (kurşun kaplama şeritleri).
static func dome_mesh(r: float, h: float, gores: int, rings: int, col_a: Color, col_b: Color) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in gores:
		var t0 := TAU * float(j) / gores
		var t1 := TAU * float(j + 1) / gores
		var tm := (t0 + t1) * 0.5
		var col := col_a if j % 2 == 0 else col_b
		for i in rings:
			var p0 := PI * 0.5 * float(i) / rings
			var p1 := PI * 0.5 * float(i + 1) / rings
			var rr0 := r * cos(p0)
			var rr1 := r * cos(p1)
			var y0 := h * sin(p0)
			var y1 := h * sin(p1)
			var rib := 1.014
			var v00 := Vector3(rr0 * rib * cos(t0), y0, rr0 * rib * sin(t0))
			var v01 := Vector3(rr0 * rib * cos(t1), y0, rr0 * rib * sin(t1))
			var v0m := Vector3(rr0 * cos(tm), y0, rr0 * sin(tm))
			var v10 := Vector3(rr1 * rib * cos(t0), y1, rr1 * rib * sin(t0))
			var v11 := Vector3(rr1 * rib * cos(t1), y1, rr1 * rib * sin(t1))
			var v1m := Vector3(rr1 * cos(tm), y1, rr1 * sin(tm))
			if i == rings - 1:
				v10 = Vector3(0, y1, 0)
				v11 = v10
				v1m = v10
			for q in [[v00, v0m, v1m, v10], [v0m, v01, v11, v1m]]:
				var a: Vector3 = q[0]
				var b: Vector3 = q[1]
				var c: Vector3 = q[2]
				var d: Vector3 = q[3]
				_cv(st, a, c, b, col)
				if not c.is_equal_approx(d):
					_cv(st, a, d, c, col)
	st.generate_normals()
	return st.commit()


static func _cv(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color) -> void:
	if (b - a).cross(c - a).length_squared() < 1e-10:
		return
	for v in [a, c, b]:
		st.set_color(col)
		st.add_vertex(v)


## Kubbe: tabanı base'de, r yarıçap, h yükseklik. Kurşun dilimli, tepede taş kaide ve altın haç.
## Dönen: tepe noktası.
func dome(base: Vector3, r: float, h: float, gores := 12, cross_size := 1.2, tint := LEAD) -> Vector3:
	var apex := Vector3(base.x, base.y + h, base.z)
	top_y = maxf(top_y, apex.y + cross_size + 0.2)
	if dry:
		return apex
	var mi := MeshInstance3D.new()
	mi.mesh = dome_mesh(r, h, gores if lod < 2 else 8, 6 if lod == 0 else 3, tint.lightened(0.06), tint.darkened(0.10))
	var m := Props.mat(Color.WHITE).duplicate() as StandardMaterial3D
	m.vertex_color_use_as_albedo = true
	mi.material_override = m
	mi.position = base
	host.add_child(mi)
	if lod == 0:
		Props.make_solid(mi)
	# tepe kaidesi ve haç
	sb(apex + Vector3(0, -0.12, 0), Vector3(0.5, 0.3, 0.5), STONE_D)
	cross(apex + Vector3(0, 0.18, 0), cross_size)
	return apex


## Bizans haçı: dikey gövde + yatay kol + alt kol (altın). Çarpışmasız süs.
func cross(base: Vector3, size: float) -> void:
	if dry or lod == 2 and size < 0.5:
		return
	vb(base, Vector3(0.1, size, 0.1), GOLD)
	vb(base + Vector3(0, size * 0.62, 0), Vector3(size * 0.55, 0.09, 0.09), GOLD)
	vb(base + Vector3(0, size * 0.3, 0), Vector3(size * 0.34, 0.08, 0.08), GOLD)


# ------------------------------------------------------- pencere ve kapı

static func face_basis(nrm: Vector3) -> Basis:
	var x := Vector3.UP.cross(nrm).normalized()
	return Basis(x, Vector3.UP, nrm)


## Kemerli dar pencere: yüzeye gömülü değil, 3-8 cm dışarıda (z-çakışması yok). base = pencere tabanı ortası.
func win(base: Vector3, nrm: Vector3, w: float, h: float, arch := true) -> void:
	if dry or lod > 0:
		return
	var bs := face_basis(nrm)
	_wf.append(Transform3D(bs * Basis.from_scale(Vector3(w + 0.26, h + 0.12, 0.04)), base + Vector3(0, h * 0.5, 0) + nrm * 0.02))
	_wd.append(Transform3D(bs * Basis.from_scale(Vector3(w, h, 0.04)), base + Vector3(0, h * 0.5, 0) + nrm * 0.045))
	if arch:
		var ax := Basis(bs.x, nrm, -Vector3.UP)
		var top := base + Vector3(0, h, 0)
		_df.append(Transform3D(ax * Basis.from_scale(Vector3((w + 0.26) * 0.5, 0.04, (w + 0.26) * 0.5)), top + nrm * 0.02))
		_dd.append(Transform3D(ax * Basis.from_scale(Vector3(w * 0.5, 0.04, w * 0.5)), top + nrm * 0.045))


## Tuğla bandı (cloisonné): duvara 3 cm yapışık ince şerit. Boyut size, taban ortası base.
func band(base: Vector3, size: Vector3) -> void:
	if dry or lod > 0:
		return
	_band.append(Transform3D(Basis.from_scale(size), base + Vector3(0, size.y * 0.5, 0)))


## Duvar çevresi boyunca tuğla bantları (4 yüz): merkez c (taban), yarı boyutlar hx, hz, bant yüksekliği y.
func band_ring(c: Vector3, hx: float, hz: float, y: float, thick := 0.14, skip_south := false) -> void:
	if dry or lod > 0:
		return
	band(c + Vector3(0, y, -hz - 0.03), Vector3(hx * 2.0 + 0.06, thick, 0.06))
	if not skip_south:
		band(c + Vector3(0, y, hz + 0.03), Vector3(hx * 2.0 + 0.06, thick, 0.06))
	band(c + Vector3(-hx - 0.03, y, 0), Vector3(0.06, thick, hz * 2.0))
	band(c + Vector3(hx + 0.03, y, 0), Vector3(0.06, thick, hz * 2.0))


## Kapı: kemerli ahşap kapı, mermer söve, eşik taşı (0,2 m; basamak). base = eşiğin duvar önündeki ortası.
func door(base: Vector3, nrm: Vector3, w := 1.5, h := 2.3) -> void:
	if dry:
		return
	var bs := face_basis(nrm)
	var right := bs.x
	# eşik taşı: alçak, katı
	var th := 0.2
	var rot := rad_to_deg(atan2(nrm.x, nrm.z))
	sb(base + nrm * 0.45, Vector3(w + 0.9, th, 0.9), STONE_D, "ashlar", rot)
	if lod > 0:
		return
	vb(base + nrm * 0.045 + Vector3(0, th, 0), Vector3(w + 0.5, h - th + 0.15, 0.06), MARBLE, "marble", Vector3(0, rot, 0))
	vb(base + nrm * 0.09 + Vector3(0, th, 0), Vector3(w, h - th, 0.06), WOOD_D, "wood", Vector3(0, rot, 0))
	# kemer başı
	var ax := Basis(right, nrm, -Vector3.UP)
	var mi := vc(base + nrm * 0.045 + Vector3(0, h + 0.15, 0), (w + 0.5) * 0.5, 0.06, MARBLE, 12, Vector3.ZERO, -1.0, true)
	if mi:
		mi.basis = ax
		mi.scale = Vector3.ONE
	var mi2 := vc(base + nrm * 0.09 + Vector3(0, h, 0), w * 0.5, 0.06, WOOD_D, 12, Vector3.ZERO, -1.0, true)
	if mi2:
		mi2.basis = ax
	# kanat ortası dikmesi ve demir halkalar
	vb(base + nrm * 0.13 + Vector3(0, th, 0), Vector3(0.05, h - th + w * 0.3, 0.04), WOOD, "", Vector3(0, rot, 0))
	for s in [-1.0, 1.0]:
		vb(base + nrm * 0.14 + right * s * 0.18 + Vector3(0, 1.1, 0), Vector3(0.1, 0.1, 0.03), DARK, "", Vector3(0, rot, 0))


# ------------------------------------------------------ merdiven ve yol

## Dış taş merdiven: dir yönünde yükselir (yatay birim vektör), taban base (en alçak basamağın ön kenarı). Her basamak
## yerden kapalı bir kütledir (altı boş değil). Dönen: [alt, ust] (zemin noktası, tepe noktası).
func stair(base: Vector3, dir: Vector3, width: float, height: float, color: Color, pat := "ashlar") -> Array:
	var n := int(ceil(height / STEP_RISE))
	var rise := height / n
	var rot := rad_to_deg(atan2(dir.x, dir.z))
	if not dry:
		for i in n:
			var hh := rise * (i + 1)
			var c := base + dir * (STEP_RUN * (i + 0.5))
			sb(Vector3(c.x, base.y, c.z), Vector3(width, hh, STEP_RUN), color.lightened(0.02 * (i % 2)), pat, rot)
	var alt := base - dir * 0.9
	var ust := base + dir * (STEP_RUN * n + 0.7) + Vector3(0, height, 0)
	return [alt, ust]


## Kenar boşluğu denetimi için: çatıya yürüyüş yolu kaydı.
func add_climb(alt: Vector3, ust: Vector3, tur: String) -> void:
	climbs.append([alt + off, ust + off, tur])


func add_perch(p: Vector3) -> void:
	perches.append(p + off)


func stair_run(height: float) -> float:
	return ceil(height / STEP_RISE) * STEP_RUN


# ------------------------------------------------------------- doğa ve süs

func tree_cypress(base: Vector3, h := 6.0) -> void:
	if dry:
		return
	vc(base, 0.18, h * 0.2, WOOD_D, 5)
	vc(base + Vector3(0, h * 0.2, 0), h * 0.12, h * 0.8, CYPRESS, 7, Vector3.ZERO, 0.04)
	# gövde taban çarpışması: ince katı sütun
	if lod == 0:
		var body := StaticBody3D.new()
		body.position = base + Vector3(0, 1.0, 0)
		host.add_child(body)
		var sh := CollisionShape3D.new()
		var cs := CylinderShape3D.new()
		cs.radius = 0.3
		cs.height = 2.0
		sh.shape = cs
		body.add_child(sh)


func tree_plane(base: Vector3, h := 7.0) -> void:
	if dry:
		return
	vc(base, 0.3, h * 0.5, Color("6b5a44"), 6, Vector3.ZERO, 0.2)
	for i in 4:
		var a := TAU * i / 4.0 + rng.randf() * 0.5
		vball(base + Vector3(cos(a) * h * 0.18, h * 0.62 + rng.randf() * h * 0.1, sin(a) * h * 0.18), h * 0.22, Color("5b8a3a").darkened(rng.randf() * 0.15), Vector3(1.0, 0.8, 1.0), 7)
	vball(base + Vector3(0, h * 0.78, 0), h * 0.24, Color("68993f"), Vector3(1, 0.8, 1), 7)
	if lod == 0:
		var body := StaticBody3D.new()
		body.position = base + Vector3(0, 1.1, 0)
		host.add_child(body)
		var sh := CollisionShape3D.new()
		var cs := CylinderShape3D.new()
		cs.radius = 0.34
		cs.height = 2.2
		sh.shape = cs
		body.add_child(sh)


## Sarmaşık topağı (yassı yeşil top): duvara yapışık süs.
func ivy(pos: Vector3, r: float, scl := Vector3(1, 0.7, 1)) -> void:
	if dry or lod > 0:
		return
	_ivy.append(Transform3D(Basis.from_scale(scl * r), pos))


func grass_patch(pos: Vector3, sx: float, sz: float) -> void:
	if dry or lod > 0:
		return
	_moss.append(Transform3D(Basis.from_scale(Vector3(sx, 0.05, sz)), pos + Vector3(0, 0.025, 0)))


## Moloz yığını (yürünür, katı): yarıçap r, tepe yüksekliği h. Basamak basamak yükselen kutu kümesi (alt kütle kapalı).
func rubble_heap(c: Vector3, r: float, h: float, color: Color) -> void:
	if dry:
		return
	var layers := maxi(2, int(ceil(h / 0.38)))
	for i in layers:
		var f := float(layers - i) / layers
		var rr := r * (0.35 + 0.65 * f)
		var hh := h * float(i + 1) / layers
		var jit := Vector3(rng.randf_range(-0.12, 0.12) * r, 0, rng.randf_range(-0.12, 0.12) * r) * (1.0 if i > 0 else 0.0)
		sb(Vector3(c.x, c.y, c.z) + jit, Vector3(rr * 2.0, hh, rr * 2.0 * rng.randf_range(0.85, 1.0)), color.darkened(rng.randf() * 0.18), "rubble", rng.randf_range(-25, 25) if i > 0 else 0.0)
	if lod > 0:
		return
	for i in 7:
		var a := rng.randf() * TAU
		var d := r * rng.randf_range(0.7, 1.15)
		_stone_bits.append(Transform3D(Basis.from_euler(Vector3(rng.randf(), rng.randf() * TAU, rng.randf())) * Basis.from_scale(Vector3(rng.randf_range(0.25, 0.5), rng.randf_range(0.15, 0.3), rng.randf_range(0.25, 0.45))),
			c + Vector3(cos(a) * d, 0.12, sin(a) * d)))


## Yağ kandili / mum alevi: Flame ile (kutu değil).
func lamp(pos: Vector3, scl := 1.0) -> void:
	if dry or lod > 0:
		return
	Flame.add(host, pos, 0.14 * scl, 0.26 * scl)


## Semantron: sundurma/duvar çıkmasından asılı tahta levha ve tokmak (Bizans çanı). Duvara yaslı, çarpışmasız.
func semantron(base: Vector3, nrm: Vector3) -> void:
	if dry or lod > 0:
		return
	var rot := rad_to_deg(atan2(nrm.x, nrm.z))
	vb(base + nrm * 0.35, Vector3(0.14, 0.14, 0.7), WOOD_D, "", Vector3(0, rot, 0), true)       # çıkma kirişi
	var bs := face_basis(nrm)
	vb(base + nrm * 0.65 + Vector3(0, -0.85, 0), Vector3(0.1, 1.5, 0.12), WOOD, "wood", Vector3(0, rot, 0), true)    # asılı levha
	vb(base + nrm * 0.65 + bs.x * 0.22 + Vector3(0, -0.9, 0), Vector3(0.05, 0.5, 0.05), WOOD_D, "", Vector3(0, rot, 0), true)   # tokmak
	for s in [-1.0, 1.0]:
		vb(base + nrm * 0.65 + Vector3(0, -0.12, 0) + bs.x * s * 0.0, Vector3(0.03, 0.2, 0.03), DARK, "", Vector3.ZERO, true)


# ---------------------------------------------------------- toplu çizim

static func _mm(host: Node3D, mesh: Mesh, mat: Material, xf: Array, shadow := true) -> void:
	if xf.is_empty():
		return
	var m := MultiMesh.new()
	m.transform_format = MultiMesh.TRANSFORM_3D
	m.mesh = mesh
	m.instance_count = xf.size()
	for i in xf.size():
		m.set_instance_transform(i, xf[i])
	var inst := MultiMeshInstance3D.new()
	inst.multimesh = m
	inst.material_override = mat
	inst.set_meta("dekor", true)
	if not shadow:
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	host.add_child(inst)


func flush() -> void:
	if dry or lod > 0:
		return
	var unit_box := BoxMesh.new()
	unit_box.size = Vector3.ONE
	var unit_cyl := CylinderMesh.new()
	unit_cyl.top_radius = 1.0
	unit_cyl.bottom_radius = 1.0
	unit_cyl.height = 1.0
	unit_cyl.radial_segments = 10
	unit_cyl.rings = 1
	var unit_ball := SphereMesh.new()
	unit_ball.radius = 1.0
	unit_ball.height = 2.0
	unit_ball.radial_segments = 6
	unit_ball.rings = 3
	_mm(host, unit_box, Props.mat(MARBLE, 0.0, false, "", false), _wf, false)
	_mm(host, unit_box, Props.mat(DARK, 0.0, false, "", false), _wd, false)
	_mm(host, unit_cyl, Props.mat(MARBLE, 0.0, false, "", false), _df, false)
	_mm(host, unit_cyl, Props.mat(DARK, 0.0, false, "", false), _dd, false)
	_mm(host, unit_box, Props.mat(BRICK, 0.0, false, "brick", false), _band)
	_mm(host, unit_ball, Props.mat(IVY, 0.0, false, "", false), _ivy)
	_mm(host, unit_cyl, Props.mat(GRASS, 0.0, false, "", false), _moss, false)
	_mm(host, unit_box, Props.mat(Color("9b8c70"), 0.0, false, "rubble", false), _stone_bits)
	_mm(host, unit_box, Props.mat(TILE_D, 0.0, false, "", false), _tile_rows)
	_wf.clear()
	_wd.clear()
	_df.clear()
	_dd.clear()
	_band.clear()
	_ivy.clear()
	_moss.clear()
	_stone_bits.clear()
	_tile_rows.clear()


## Mahya taşı sırası: çatı sırtında boyunca ince kiremit sırası (süs).
func ridge(base: Vector3, len: float, along_z := true) -> void:
	if dry or lod > 0:
		return
	var bs := Basis.IDENTITY if along_z else Basis(Vector3.UP, deg_to_rad(90.0))
	_tile_rows.append(Transform3D(bs * Basis.from_scale(Vector3(0.22, 0.14, len)), base + Vector3(0, 0.05, 0)))
