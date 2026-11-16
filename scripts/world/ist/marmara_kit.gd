class_name IstMk
extends RefCounted
## Marmara parçası için ortak yapı taşları (palet + kısa yazımlı katı/görsel parçalar + MultiMesh yardımcıları).
## Konum kuralı: S/V/CY işlevlerinde `base` parçanın TABANININ ortasıdır (y = taban yüksekliği).
## Yerel eksenler: +x doğu, -z kuzey, +z güney = DENİZ yönü.

const STONE := Color("d9c9a6")        # kireçtaşı (tekfur deseniyle: taş + tuğla bantları)
const STONE_DK := Color("b9a680")
const BRICK := Color("b4623e")
const BRICK_DK := Color("8e4a2e")
const MARBLE := Color("c2b9a2")
const MARBLE_GREY := Color("a8a69c")
const ROCK := Color("8d8678")
const ROCK_DK := Color("6d675c")
const WOOD := Color("7a5634")
const WOOD_DK := Color("523824")
const WOOD_LT := Color("a8855a")
const TILE := Color("c0603a")
const THATCH := Color("b99a5c")
const DARK := Color("2a2622")
const WATER := Color(0.20, 0.50, 0.62, 0.62)
const MOSS := Color("6f8a47")
const GRASS := Color("5f7d38")
const SOIL := Color("7a5a3c")
const SAND := Color("d3bf8c")
const ROPE := Color("8a7248")
const GOLD := Color("d8b040")
const RED := Color("a8272c")

const MAXVIS := 0.0

## Kurulum penceresi (ŞEHİR-3, zaman dilimi): yalnız x'i [pencere.x, pencere.y) içinde kalan parçalar kurulur (şehir
## kurucusu uzun sur dilimini pencere pencere ayrı karelerde kurar). Dışarıda kalan çağrılar boş bir yer tutucu döndürür.
static var pencere := Vector2(-1e9, 1e9)
static var _bos_s: StaticBody3D
static var _bos_m: MeshInstance3D
static var _bos_mm: MultiMeshInstance3D

static func _ic(x: float) -> bool:
	return x >= pencere.x and x < pencere.y

static func _bos() -> MeshInstance3D:
	if _bos_m == null:
		_bos_m = MeshInstance3D.new()
	return _bos_m


## Katı kutu (taban ortası verilir).
static func S(p: Node3D, size: Vector3, base: Vector3, col: Color, pat := "", rot_y := 0.0) -> StaticBody3D:
	if not _ic(base.x):
		if _bos_s == null:
			_bos_s = StaticBody3D.new()
		return _bos_s
	var b := Props.solid(p, size, base + Vector3(0, size.y * 0.5, 0), col, Vector3(0, rot_y, 0))
	if pat != "":
		Props.set_pattern(b, col, pat)
	return b


## Çarpışmasız görsel kutu (taban ortası).
static func V(p: Node3D, size: Vector3, base: Vector3, col: Color, pat := "", rot := Vector3.ZERO) -> MeshInstance3D:
	if not _ic(base.x):
		return _bos()
	var m := Props.box(p, size, base + Vector3(0, size.y * 0.5, 0), col, rot)
	if pat != "":
		Props.set_pattern(m, col, pat)
	return m


## Silindir (görsel ya da katı), taban ortası.
static func CY(p: Node3D, r: float, h: float, base: Vector3, col: Color, pat := "", seg := 10, solid := false, top_r := -1.0) -> MeshInstance3D:
	if not _ic(base.x):
		return _bos()
	var m := Props.cyl(p, r, h, base + Vector3(0, h * 0.5, 0), col, Vector3.ZERO, seg, top_r)
	if pat != "":
		Props.set_pattern(m, col, pat)
	if solid:
		Props.make_solid(m, 0.92)
	return m


## Yatık silindir (sütun kütüğü, direk, kereste): merkez + dönüş.
static func CYR(p: Node3D, r: float, h: float, center: Vector3, col: Color, rot_deg: Vector3, pat := "", seg := 8, solid := false) -> MeshInstance3D:
	if not _ic(center.x):
		return _bos()
	var m := Props.cyl(p, r, h, center, col, rot_deg, seg)
	if pat != "":
		Props.set_pattern(m, col, pat)
	if solid:
		Props.make_solid(m, 0.95)
	return m


## Eğik çatı ya da prizma: görsel + dışbükey katı (Props.make_solid). size = (en, yükseklik, boy), taban ortası.
static func ROOF(p: Node3D, size: Vector3, base: Vector3, col: Color, pat := "tiles", rot_y := 0.0, solid := true) -> MeshInstance3D:
	var m := Props.prism(p, size, base + Vector3(0, size.y * 0.5, 0), col, Vector3(0, rot_y, 0))
	if pat != "":
		Props.set_pattern(m, col, pat)
	if solid:
		Props.make_solid(m, 1.0)
	return m


## Birçok aynı kutu: MultiMesh. xf: [[merkez Vector3, yaw_derece], …] ya da Transform3D.
static func MM(p: Node3D, size: Vector3, xf: Array, col: Color, pat := "", shadow := false) -> MultiMeshInstance3D:
	xf = xf.filter(func(e) -> bool: return _ic((e as Transform3D).origin.x if e is Transform3D else (e[0] as Vector3).x))
	if xf.is_empty() and pencere.x > -1e8:
		if _bos_mm == null:
			_bos_mm = MultiMeshInstance3D.new()
		return _bos_mm
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var bm := BoxMesh.new()
	bm.size = size
	mm.mesh = bm
	mm.instance_count = xf.size()
	for i in xf.size():
		var t: Transform3D
		if xf[i] is Transform3D:
			t = xf[i]
		else:
			t = Transform3D(Basis(Vector3.UP, deg_to_rad(float(xf[i][1]))), xf[i][0] as Vector3)
		mm.set_instance_transform(i, t)
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = Props.mat(col, 0.0, false, pat)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.add_child(mi)
	return mi


## Birçok aynı silindir (direk, bacak, sütunçe): xf = [[merkez, yaw], …]
static func MMC(p: Node3D, r: float, h: float, xf: Array, col: Color, seg := 6, pat := "") -> MultiMeshInstance3D:
	xf = xf.filter(func(e) -> bool: return _ic((e as Transform3D).origin.x if e is Transform3D else (e[0] as Vector3).x))
	if xf.is_empty() and pencere.x > -1e8:
		if _bos_mm == null:
			_bos_mm = MultiMeshInstance3D.new()
		return _bos_mm
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var cm := CylinderMesh.new()
	cm.top_radius = r
	cm.bottom_radius = r
	cm.height = h
	cm.radial_segments = seg
	cm.rings = 1
	mm.mesh = cm
	mm.instance_count = xf.size()
	for i in xf.size():
		var t: Transform3D
		if xf[i] is Transform3D:
			t = xf[i]
		else:
			t = Transform3D(Basis(Vector3.UP, deg_to_rad(float(xf[i][1]))), xf[i][0] as Vector3)
		mm.set_instance_transform(i, t)
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = Props.mat(col, 0.0, false, pat)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.add_child(mi)
	return mi


## Basamaklı merdiven. foot = alt basamağın ÖN kenarının tabanı (zemin y). dir: çıkış yönü (xz). Her basamak zeminden
## basamak üstüne dolu katı sütun; üst basamağın üstü = foot.y + n × rise. Dönüş: üst basamağın üst orta noktası.
static func STAIRS(p: Node3D, foot: Vector3, dir: Vector3, n: int, rise: float, run: float, width: float, col: Color, pat := "ashlar") -> Vector3:
	var d := Vector3(dir.x, 0, dir.z).normalized()
	var yaw := rad_to_deg(atan2(d.x, d.z))
	for i in n:
		var top := rise * (i + 1)
		var c := foot + d * (run * (i + 0.5))
		S(p, Vector3(width, top, run + 0.02), Vector3(c.x, foot.y, c.z), col, pat, yaw)
	return foot + d * (run * n) + Vector3(0, rise * n, 0) - d * (run * 0.5)


## Merdiven uçuşu: height kadar yükselir (n = ceil(height / 0.34), rise ≤ 0,34), foot = alt basamağın ön kenarı (zemin y).
## dir: çıkış yönü; sides: yan korkuluk taraf işaretleri (+1 sağ, -1 sol; sağ = dir × YUKARI). Dönüş: {n, run_len, top, rise}
static func FLIGHT(p: Node3D, foot: Vector3, dir: Vector3, height: float, width: float, sides: Array, col: Color, pat := "ashlar", run := 0.46) -> Dictionary:
	var n := int(ceil(height / 0.34))
	var rise := height / n
	var d := Vector3(dir.x, 0, dir.z).normalized()
	var yaw := rad_to_deg(atan2(d.x, d.z))
	for i in n:
		var top := rise * (i + 1)
		var c := foot + d * (run * (i + 0.5))
		S(p, Vector3(width, top, run + 0.02), Vector3(c.x, foot.y, c.z), col, pat, yaw)
	var right := Vector3(d.z, 0, -d.x)
	for sg in sides:
		var side := right * float(sg) * (width * 0.5 + 0.11)
		var total := Vector3(d.x * run * n, rise * n, d.z * run * n)
		var zb := total.normalized()
		var xb := Vector3.UP.cross(zb).normalized()
		var yb := zb.cross(xb)
		var mid := foot + side + total * 0.5 + Vector3(0, 0.55, 0)
		var b := Props.solid(p, Vector3(0.22, 1.1, total.length()), mid, col)
		b.transform = Transform3D(Basis(xb, yb, zb), mid)
		if pat != "":
			Props.set_pattern(b, col, pat)
	return {"n": n, "run_len": run * n, "top": foot + d * (run * n) + Vector3(0, height, 0), "rise": rise}


## Yarım daire kemer halkası (düzlem XY, normal ±Z): kutunun x ekseni radyal
static func ARCH(p: Node3D, center: Vector3, r: float, thick: float, depth: float, col: Color, pat := "", n := 11, flip := 1.0) -> void:
	var xf: Array = []
	var w := PI * (r + thick * 0.5) / float(n) * 1.03
	for i in n:
		var a := PI * (float(i) + 0.5) / float(n)
		var rad := r + thick * 0.5
		var pos := center + Vector3(cos(a) * rad, sin(a) * rad, 0.0)
		xf.append(Transform3D(Basis(Vector3.BACK, a), pos))
	MM(p, Vector3(thick, w, depth * flip), xf, col, pat)


static func WATER_PLANE(p: Node3D, size: Vector2, center: Vector3) -> MeshInstance3D:
	var m := Props.box(p, Vector3(size.x, 0.04, size.y), center, WATER)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return m


static func FLAME(p: Node3D, pos: Vector3, w := 0.5, h := 0.8) -> void:
	Flame.add(p, pos, w, h)


## Taş (kaya): basık küre + katı gövde.
static func ROCKB(p: Node3D, base: Vector3, radius: Vector3, col: Color = ROCK, solid := true) -> MeshInstance3D:
	var m := Props.ball(p, 1.0, base + Vector3(0, radius.y * 0.55, 0), col, radius, 8)
	Props.set_pattern(m, col, "rubble")
	if solid:
		Props.make_solid(m, 0.9)
	return m


## Ot tutamları (çarpışmasız, çok küçük): MultiMesh prizma.
static func TUFTS(p: Node3D, rng: RandomNumberGenerator, rect: Rect2, n: int, y: float, col: Color = GRASS, size: float = 0.22) -> void:
	var xf: Array = []
	for i in n:
		var pos := Vector3(rng.randf_range(rect.position.x, rect.end.x), y + size * 0.3, rng.randf_range(rect.position.y, rect.end.y))
		xf.append([pos, rng.randf_range(0.0, 180.0)])
	MM(p, Vector3(size, size * 0.7, size * 0.35), xf, col)


## Yardımcı: yerel kök düğümü
static func root(host: Node3D, nm: String) -> Node3D:
	var r := Node3D.new()
	r.name = nm
	host.add_child(r)
	return r


## Kapı eşiği / karanlık kapı boşluğu (girilemeyen kapı): koyu ince kutu + çerçeve.
static func DOOR_DARK(p: Node3D, base: Vector3, w: float, h: float, frame: Color = WOOD_DK) -> void:
	V(p, Vector3(w, h, 0.06), base, DARK)
	V(p, Vector3(w + 0.2, 0.14, 0.12), base + Vector3(0, h, 0), frame)
	V(p, Vector3(0.12, h, 0.12), base + Vector3(-w * 0.5 - 0.04, 0, 0), frame)
	V(p, Vector3(0.12, h, 0.12), base + Vector3(w * 0.5 + 0.04, 0, 0), frame)
