class_name IstGalataOrtak
extends RefCounted
## Galata parçası için ortak yardımcılar: katı kutu, silindir, çatı, merdiven, MultiMesh sıraları.
## `col` kapalıysa (lod 1/2) hiçbir şey çarpışmaz.

const STONE := Color("b9aa8c")
const STONE_D := Color("8f8470")
const LIGHT := Color("b5a784")
const PLASTER := Color("d9c7a4")
const PLASTER2 := Color("cfa982")
const PLASTER3 := Color("c9b48f")
const TILE := Color("b0553a")
const TILE_D := Color("96472f")
const WOOD := Color("6c4c2e")
const WOOD_D := Color("4a3220")
const DARK := Color("2a2228")
const LEAD := Color("7a8594")
const RED := Color("b32b2b")
const WHITE := Color("f2eee4")
const GREEN := Color("5f7a3c")
const GREEN_D := Color("3f5a2a")
const SEA := Color("1c4254")

static var col := true


static func start(lod: int) -> void:
	col = lod == 0


## Katı kutu: base = tabanın ortası (y alt yüzey).
static func sol(h: Node3D, size: Vector3, base: Vector3, c: Color, pat := "", yaw := 0.0) -> Node3D:
	var pos := base + Vector3(0, size.y * 0.5, 0)
	if col:
		var b := Props.solid(h, size, pos, c, Vector3(0, yaw, 0))
		if pat != "":
			Props.set_pattern(b, c, pat)
		return b
	var mi := Props.box(h, size, pos, c, Vector3(0, yaw, 0))
	Props.set_pattern(mi, c, pat if pat != "" else "plaster")
	return mi


## Çarpışmasız süs kutusu.
static func vis(h: Node3D, size: Vector3, base: Vector3, c: Color, pat := "", rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := Props.box(h, size, base + Vector3(0, size.y * 0.5, 0), c, rot)
	if pat != "":
		Props.set_pattern(mi, c, pat)
	return mi


## Katı silindir/koni (dışbükey kabuk). base = tabanın ortası.
static func cyl(h: Node3D, r: float, hh: float, base: Vector3, c: Color, pat := "", seg := 16, top_r := -1.0, solid := true, yaw := 0.0) -> MeshInstance3D:
	var mi := Props.cyl(h, r, hh, base + Vector3(0, hh * 0.5, 0), c, Vector3(0, yaw, 0), seg, top_r)
	if pat != "":
		Props.set_pattern(mi, c, pat)
	if solid and col:
		Props.make_solid(mi, 1.0)
	return mi


static func xf(a: float, r: float, y: float, yaw_off := 0.0, sc := Vector3.ONE) -> Transform3D:
	var b := Basis(Vector3.UP, a + yaw_off).scaled(sc)
	return Transform3D(b, Vector3(sin(a) * r, y, cos(a) * r))


## Aynı kutudan çok kopya (mazgal, pencere, kiremit sırası): tek MultiMesh.
static func mm(h: Node3D, size: Vector3, xforms: Array, c: Color, pat := "") -> MultiMeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = size
	var m := MultiMesh.new()
	m.transform_format = MultiMesh.TRANSFORM_3D
	m.mesh = bm
	m.instance_count = xforms.size()
	for i in xforms.size():
		m.set_instance_transform(i, xforms[i])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = m
	mi.material_override = Props.mat(c, 0.0, false, pat)
	h.add_child(mi)
	return mi


## Çift eğimli katı çatı. Ana eksen: along_x ise x boyunca (kesit z'de). base = saçak üst yüzeyinin ortası.
## w: saçak arası genişlik, l: boy, rise: mahya yüksekliği. Altı duvar bloğu kapatır.
static func gable(h: Node3D, w: float, l: float, base: Vector3, rise: float, c: Color, along_x := false, over := 0.5, gable_c := PLASTER) -> void:
	var g := Node3D.new()
	g.position = base
	g.rotation_degrees.y = 90.0 if along_x else 0.0
	h.add_child(g)
	var hw := w * 0.5
	var ang := atan2(rise, hw)
	var slen := sqrt(hw * hw + rise * rise) + over
	for s: float in [-1.0, 1.0]:
		var mid := Vector3(s * hw * 0.5, rise * 0.5 + 0.06, 0)
		if col:
			var body := Props.solid(g, Vector3(slen, 0.25, l + 0.8), mid, c, Vector3(0, 0, -s * rad_to_deg(ang)))
			Props.set_pattern(body, c, "tiles")
		else:
			var mi := Props.box(g, Vector3(slen, 0.25, l + 0.8), mid, c, Vector3(0, 0, -s * rad_to_deg(ang)))
			Props.set_pattern(mi, c, "tiles")
	# mahya sırtı
	Props.box(g, Vector3(0.5, 0.3, l + 0.9), Vector3(0, rise + 0.1, 0), TILE_D)
	# alın üçgenleri (iki uçta)
	for e: float in [-1.0, 1.0]:
		var pr := Props.prism(g, Vector3(w, rise, 0.3), Vector3(0, rise * 0.5 - 0.02, e * (l * 0.5 + 0.0)), gable_c, Vector3(0, 0, 0))
		Props.set_pattern(pr, gable_c, "ashlar" if gable_c == STONE else "plaster")


## Merdiven: base'den dir yönünde, rise kadar yükselir (basamak ≤ 0,3 m). Dolu bloklu basamaklar.
static func stair(h: Node3D, base: Vector3, dir: Vector3, rise: float, w: float, c: Color, pat := "") -> Vector3:
	var n := maxi(1, ceili(rise / 0.30))
	var sh := rise / n
	var tread := 0.36
	var d := Vector3(dir.x, 0, dir.z).normalized()
	var yaw := rad_to_deg(atan2(d.x, d.z))
	for i in n:
		var hi := sh * (i + 1)
		sol(h, Vector3(w, hi, tread), base + d * (tread * (i + 0.5)), c, pat, yaw)
	return base + d * (tread * n) + Vector3(0, rise, 0)


## Sandık yığını (0,4 m'lik adımlar): sokaktan alçak saçağa çıkış.
static func crates(h: Node3D, base: Vector3, dir: Vector3, steps: int) -> Vector3:
	var d := Vector3(dir.x, 0, dir.z).normalized()
	var yaw := rad_to_deg(atan2(d.x, d.z))
	for i in steps:
		var hi := 0.4 * (i + 1)
		sol(h, Vector3(1.0, hi, 0.9), base + d * (0.9 * (i + 0.5)), WOOD, "wood", yaw)
	return base + d * (0.9 * steps) + Vector3(0, 0.4 * steps, 0)


## Daire üstünde dolanan 1,1 m korkuluk (katı, çokgen) — dışarı düşmeyi önler.
static func ring_rail(h: Node3D, r: float, y: float, n: int, c: Color, hh := 1.1, th := 0.4) -> void:
	var side := 2.0 * r * sin(PI / n) + 0.05
	for i in n:
		var a := TAU * (i + 0.5) / n
		var p := Vector3(sin(a) * r * cos(PI / n), y, cos(a) * r * cos(PI / n))
		sol(h, Vector3(th, hh, side), p, c, "ashlar", rad_to_deg(a) + 90.0 + 0.0)


## Mazgal sırası: dikdörtgen çevrenin kenarları boyunca.
static func merlons_rect(h: Node3D, w: float, d: float, y: float, c: Color, gap := 1.7) -> void:
	var xs: Array = []
	var nx := maxi(2, int(w / gap))
	for i in nx:
		var x := -w * 0.5 + (i + 0.5) * w / nx
		xs.append(Transform3D(Basis(), Vector3(x, y + 0.45, -d * 0.5)))
		xs.append(Transform3D(Basis(), Vector3(x, y + 0.45, d * 0.5)))
	var nz := maxi(2, int(d / gap))
	for i in nz:
		var z := -d * 0.5 + (i + 0.5) * d / nz
		xs.append(Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(-w * 0.5, y + 0.45, z)))
		xs.append(Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(w * 0.5, y + 0.45, z)))
	mm(h, Vector3(0.9, 0.9, 0.5), xs, c, "ashlar")


## Sivri (gotik) pencere: karanlık dikdörtgen + üst sivri prizma. Cephe normali yaw ile.
static func lancet(h: Node3D, pos: Vector3, yaw: float, wd := 0.7, ht := 2.0) -> void:
	var g := Node3D.new()
	g.position = pos
	g.rotation_degrees.y = yaw
	h.add_child(g)
	Props.box(g, Vector3(wd, ht, 0.12), Vector3(0, ht * 0.5, 0.05), DARK)
	Props.prism(g, Vector3(wd, wd * 0.9, 0.12), Vector3(0, ht + wd * 0.45, 0.05), DARK)
	Props.box(g, Vector3(wd + 0.2, 0.12, 0.16), Vector3(0, -0.02, 0.06), LIGHT)


## Ceneviz bayrağı: beyaz zemin, kırmızı Aziz Georg haçı.
static func flag(h: Node3D, base: Vector3, pole_h := 4.0, w := 1.8, fh := 1.2) -> void:
	Props.cyl(h, 0.05, pole_h, base + Vector3(0, pole_h * 0.5, 0), WOOD_D, Vector3.ZERO, 6)
	var top := base + Vector3(0, pole_h - fh * 0.5 - 0.1, 0)
	Props.box(h, Vector3(0.03, fh, w), top + Vector3(0, 0, w * 0.5 + 0.05), WHITE)
	Props.box(h, Vector3(0.05, fh, 0.22), top + Vector3(0, 0, w * 0.5 + 0.05), RED)
	Props.box(h, Vector3(0.05, 0.22, w), top + Vector3(0, 0, w * 0.5 + 0.05), RED)


## Fıçı ve sandık yığını (süs + dayanak): parçalar birbirine değer, aralarında dar boşluk kalmaz.
static func cargo(h: Node3D, base: Vector3, _seed: int) -> void:
	var yaw := float(_seed % 4) * 90.0
	var g := Node3D.new()
	g.position = base
	g.rotation_degrees.y = yaw
	h.add_child(g)
	sol(g, Vector3(0.8, 0.8, 0.8), Vector3(-0.45, 0, 0), WOOD, "wood")
	sol(g, Vector3(0.6, 0.6, 0.6), Vector3(-0.45, 0.8, 0), WOOD_D, "wood")
	cyl(g, 0.38, 0.9, Vector3(0.33, 0, 0), WOOD_D, "wood", 8, 0.33)
	cyl(g, 0.38, 0.9, Vector3(0.33, 0, 0.76), WOOD_D, "wood", 8, 0.33)


## Katı rampa: base (alçak uç, zemin) → dir yönünde run kadar ilerleyip rise kadar yükselir.
static func ramp(h: Node3D, base: Vector3, dir: Vector3, run: float, rise: float, w: float, c: Color, pat := "") -> void:
	var d := Vector3(dir.x, 0, dir.z).normalized()
	var yaw := rad_to_deg(atan2(d.x, d.z))
	var ang := atan2(rise, run)
	var ln := sqrt(run * run + rise * rise)
	var mid := base + d * run * 0.5 + Vector3(0, rise * 0.5, 0)
	var n := Vector3(0, cos(ang), 0) - d * sin(ang)   # yüzey normali (yukarı ve alçak uca doğru)
	mid -= n * 0.15
	var rot := Vector3(-rad_to_deg(ang), yaw, 0)
	if col:
		var b := Props.solid(h, Vector3(w, 0.3, ln + 0.2), mid, c, rot)
		if pat != "":
			Props.set_pattern(b, c, pat)
	else:
		Props.box(h, Vector3(w, 0.3, ln + 0.2), mid, c, rot)


## Aynı küreden çok kopya (çalı, bağ asması).
static func mm_ball(h: Node3D, r: float, xforms: Array, c: Color) -> MultiMeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	sm.radial_segments = 6
	sm.rings = 3
	var m := MultiMesh.new()
	m.transform_format = MultiMesh.TRANSFORM_3D
	m.mesh = sm
	m.instance_count = xforms.size()
	for i in xforms.size():
		m.set_instance_transform(i, xforms[i])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = m
	mi.material_override = Props.mat(c, 0.0, false, "")
	h.add_child(mi)
	return mi
