class_name Nature
extends RefCounted
## Doğa parçaları: rüzgârda salınan çimen öbekleri, köşeli kayalar ve arazi dokusu (ortak malzemeler).

static var _grass_mat: ShaderMaterial
static var _ground_mat: ShaderMaterial
static var _rock_mat: StandardMaterial3D
static var _tuft: ArrayMesh
static var _rocks: Array = []


static func ground_material() -> ShaderMaterial:
	if _ground_mat == null:
		_ground_mat = ShaderMaterial.new()
		_ground_mat.shader = load("res://assets/shaders/ground.gdshader")
	return _ground_mat


static func grass_material() -> ShaderMaterial:
	if _grass_mat == null:
		_grass_mat = ShaderMaterial.new()
		_grass_mat.shader = load("res://assets/shaders/grass.gdshader")
	return _grass_mat


static func rock_material() -> StandardMaterial3D:
	if _rock_mat == null:
		_rock_mat = StandardMaterial3D.new()
		_rock_mat.vertex_color_use_as_albedo = true
		_rock_mat.vertex_color_is_srgb = true
		_rock_mat.roughness = 0.95
		_rock_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return _rock_mat


## Çimen öbeği: 7 sap, her biri ince bir üçgen; dipte koyu, uçta açık yeşil; farklı boy ve eğim.
static func tuft() -> ArrayMesh:
	if _tuft:
		return _tuft
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 7:
		var a := TAU * i / 7.0 + rng.randf_range(-0.3, 0.3)
		var r := rng.randf_range(0.02, 0.09)
		var base := Vector3(cos(a) * r, 0, sin(a) * r)
		var h := rng.randf_range(0.28, 0.5)
		var lean := Vector3(cos(a), 0, sin(a)) * rng.randf_range(0.06, 0.16)
		var side := Vector3(-sin(a), 0, cos(a)) * rng.randf_range(0.022, 0.035)
		var tip := base + lean + Vector3(0, h, 0)
		var n := (side).cross(tip - base).normalized()
		for v in [[base - side, Color(0.55, 0.62, 0.45)], [base + side, Color(0.55, 0.62, 0.45)], [tip, Color(1.0, 1.0, 0.82)]]:
			st.set_color(v[1])
			st.set_normal(n.lerp(Vector3.UP, 0.5).normalized())
			st.add_vertex(v[0])
	_tuft = st.commit()
	return _tuft


## Köşeli kaya: kabaca küre, köşeleri rastgele itilmiş, yüzleri düz gölgeli; üstü açık, altı koyu.
static func rock(variant := 0) -> ArrayMesh:
	while _rocks.size() <= variant:
		_rocks.append(_make_rock(_rocks.size()))
	return _rocks[variant]


static func _make_rock(seed: int) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = 100 + seed
	var sm := SphereMesh.new()
	sm.radius = 0.5
	sm.height = 1.0
	sm.radial_segments = 7
	sm.rings = 4
	var arr := sm.get_mesh_arrays()
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
	# Aynı konumdaki köşeler aynı itmeyi alsın (dikiş açılmasın)
	var push := {}
	for i in verts.size():
		var k := Vector3i(roundi(verts[i].x * 100), roundi(verts[i].y * 100), roundi(verts[i].z * 100))
		if not push.has(k):
			push[k] = rng.randf_range(0.75, 1.15)
		var v := verts[i] * float(push[k])
		v.y = v.y * 0.62 + 0.18
		if v.y < 0.0:
			v.y *= 0.3
		verts[i] = v
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for t in range(0, idx.size(), 3):
		var a := verts[idx[t]]
		var b := verts[idx[t + 1]]
		var c := verts[idx[t + 2]]
		var n := (c - a).cross(b - a).normalized()
		if n.dot((a + b + c) / 3.0) < 0.0:
			n = -n
		var shade := clampf(0.62 + n.y * 0.38, 0.35, 1.0)
		for v in [a, b, c]:
			st.set_color(Color(shade, shade, shade * 0.97))
			st.set_normal(n)
			st.add_vertex(v)
	return st.commit()


# ---------------------------------------------------------------- zemin ayrıntısı ve kıyı (Bölüm 2 tur 2; ortak)

static var _detail_meshes := {}
static var _detail_mat: StandardMaterial3D
static var _gloss_mat: StandardMaterial3D

## ground_detail türleri: ağ, boy aralığı, renk aralığı, yere yatık mı (eğime oturur), malzeme ("grass", "gloss", "")
const DETAIL := {
	"grass": [0.45, 0.9, Color("3e6428"), Color("7e7c48"), false, "grass"],
	"tall_grass": [0.6, 0.95, Color("4a6a2c"), Color("8e8650"), false, "grass"],
	"stone": [0.12, 0.45, Color("7e7a6e"), Color("b2aa96"), false, "rock"],
	"pebble": [0.04, 0.12, Color("8a8478"), Color("c8bfae"), false, "rock"],
	"chips": [0.35, 0.7, Color("b89a6a"), Color("d8c090"), true, ""],
	"mud": [0.7, 1.9, Color("57442f"), Color("735d43"), true, ""],
	"grease": [0.5, 1.2, Color("241808"), Color("3a2810"), true, "gloss"],
	"footprint": [0.9, 1.1, Color("3e2e1e"), Color("54402c"), true, ""],      # biraz açık (kara delik gibiydi)
	"bush": [0.6, 1.4, Color("2f4f22"), Color("587a34"), false, ""],
	"log": [0.7, 1.3, Color("7a5434"), Color("a07a50"), false, ""],
	"plank": [0.7, 1.3, Color("7a6a54"), Color("a8957a"), true, ""],
	"wrack": [0.4, 0.9, Color("3a3a22"), Color("525030"), true, ""],
	"foam": [0.3, 0.8, Color("cfe2e4"), Color("eef6f6"), true, ""],
	"wet": [0.6, 1.3, Color("7e6e50"), Color("8e7e5e"), true, ""],
	# yayma P0: ordugâh, şehir, sur dibi
	"camp_mud": [0.8, 2.2, Color("4e3c2a"), Color("66523c"), true, ""],      # zeminin biraz koyusu
	"hoofprint": [0.9, 1.1, Color("33261a"), Color("4a3826"), true, ""],
	"straw": [0.5, 1.0, Color("c8a858"), Color("e8d088"), true, ""],
	"ash": [0.5, 1.2, Color("4a4846"), Color("8a8682"), true, ""],
	"coal": [0.04, 0.1, Color("1a1816"), Color("3a3430"), false, "rock"],
	"cobble_weed": [0.16, 0.32, Color("4a6a2c"), Color("7e8a48"), false, "grass"],
	"rubble": [0.1, 0.38, Color("9a9080"), Color("c8bca8"), false, "rock"],
	"arrows": [0.85, 1.1, Color("8a6a40"), Color("a88a5a"), false, ""],
	"snow_print": [0.9, 1.1, Color("8a98a4"), Color("a4b0ba"), true, ""],
}
## Kenarı yumuşak (köşe rengi saydam) yassı türler: zemine geçişli yamalar (tur 3)
const SOFT := ["mud", "grease", "wet", "footprint", "camp_mud", "hoofprint", "ash", "snow_print"]


## Zemin ayrıntısı saçıcı: area (dünya x-z dikdörtgeni) içine yoğunluk (adet / m²) kadar kind türünden parça; her tür
## tek çoklu ağ (tek çizim), gölge düşürmez, çarpışmasız (taş dahil: oynanış yolunu bozmaz). height(x, z) -> dünya y;
## keep(x, z) -> bool (false: oraya koyma; yol, su, iş alanı). Yere yatık türler (çamur, yağ, talaş, iz, köpük) eğime oturur.
## Türler: grass, tall_grass, stone, pebble, chips (talaş/yonga), mud (çiğnenmiş çamur), grease (parlak yağ lekesi),
## footprint, bush, log (kütük parçası), plank (tahta), wrack (kıyıya vurmuş yosun), foam, wet (ıslak kum lekesi).
## Örnek: Nature.ground_detail(self, Rect2(-20, -140, 40, 140), "mud", 0.4, 11, arazi_y, func(x, z): return absf(x) > 5)
## Bölüm 2 (kızak kenarı, kıyı), ordugâh, köy yolu, sur dibi, liman.
static func ground_detail(parent: Node3D, area: Rect2, kind: String, density: float, seed: int, height: Callable,
		keep := Callable(), max_count := 4000) -> MultiMeshInstance3D:
	var spec: Array = DETAIL.get(kind, DETAIL["stone"])
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var n := mini(max_count, int(area.get_area() * density))
	var xs: Array = []
	var cs: Array = []
	var flat: bool = spec[4]
	for i in n:
		var x := rng.randf_range(area.position.x, area.end.x)
		var z := rng.randf_range(area.position.y, area.end.y)
		if keep.is_valid() and not bool(keep.call(x, z)):
			continue
		var y := float(height.call(x, z))
		var s := rng.randf_range(float(spec[0]), float(spec[1]))
		var b := Basis(Vector3.UP, rng.randf() * TAU)
		if flat:
			var dx := float(height.call(x + 0.4, z)) - float(height.call(x - 0.4, z))
			var dz := float(height.call(x, z + 0.4)) - float(height.call(x, z - 0.4))
			var nrm := Vector3(-dx / 0.8, 1.0, -dz / 0.8).normalized()
			var ax := Vector3.UP.cross(nrm)
			if ax.length() > 0.0001:
				b = Basis(ax.normalized(), Vector3.UP.angle_to(nrm)) * b
			y += 0.025
		elif kind in ["stone", "pebble", "log"]:
			b = b * Basis.from_euler(Vector3(rng.randf_range(-0.25, 0.25), 0, rng.randf_range(-0.25, 0.25)))
			y -= s * 0.12
		var sc := Vector3(s * rng.randf_range(0.8, 1.25), s * (rng.randf_range(0.8, 1.3) if not flat else 1.0), s)
		xs.append(Transform3D(b * Basis.from_scale(sc), Vector3(x, y, z)))
		cs.append((spec[2] as Color).lerp(spec[3], rng.randf()))
	if xs.is_empty():
		return null
	var mat: Material
	match str(spec[5]):
		"grass":
			mat = grass_material()
		"rock":
			mat = rock_material()
		"gloss":
			mat = _gloss()
		_:
			mat = _detail()
	if kind in SOFT:
		mat = _soft(kind == "grease")
	var mesh: Mesh = tuft() if spec[5] == "grass" else (rock(rng.randi() % 3) if spec[5] == "rock" else detail_mesh(kind))
	var mi := Scenery.scatter(parent, mesh, xs, cs, mat)
	mi.set_meta("no_walk", true)        # WorldWalk: dekor, zemin değil
	mi.set_meta("soft", true)
	mi.visibility_range_end = 90.0 if kind in ["grass", "pebble", "chips", "footprint", "grease", "foam"] else 200.0
	return mi


## Kıyı bandı: from→to çizgisi boyunca (dünya, kabaca su kenarında) her ~0,7 m'de suyun kenarı aranır (height ile;
## to_water: kıyıdan suya yön) ve oraya ıslak kum bandı (koyu, kenardan karaya 1-2 m), köpük çizgisi (suyun 0,1-0,4 m
## içinde), çakıl, kıyıya vurmuş yosun ve tahta serpilir. Her tür tek çoklu ağ. Döndürür: kurulan düğümler.
## Örnek: Nature.shore_band(self, Vector3(-40, 0, z0), Vector3(40, 0, z0), Vector3(0, 0, -1), su_y, arazi_y, 5)
## Haliç kıyıları, Marmara sahili, liman, dere ağzı.
static func shore_band(parent: Node3D, from: Vector3, to: Vector3, to_water: Vector3, water_y: float, height: Callable, seed := 5,
		keep := Callable()) -> Array:
	var tw := Vector3(to_water.x, 0, to_water.z).normalized()
	var edge: Array = []
	var steps := maxi(2, int(from.distance_to(to) / 0.7))
	for i in steps + 1:
		var p := from.lerp(to, float(i) / steps)
		# Karadan suya doğru ilk "su altı" noktası (en çok 12 m)
		var a := p - tw * 6.0
		for k in 48:
			var q := a + tw * (k * 0.25)
			if float(height.call(q.x, q.z)) < water_y + 0.02:
				edge.append(Vector3(q.x, water_y, q.z))
				break
	var out: Array = []
	if edge.is_empty():
		return out
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var pick := {"wet": [], "foam": [], "pebble": [], "wrack": [], "plank": []}
	for e: Vector3 in edge:
		if keep.is_valid() and not bool(keep.call(e.x, e.z)):
			continue
		for k in 3:
			pick["wet"].append(e - tw * rng.randf_range(0.2, 1.6) + tw.cross(Vector3.UP) * rng.randf_range(-0.4, 0.4))
		for k in 3:
			pick["foam"].append(e + tw * rng.randf_range(0.05, 0.5) + tw.cross(Vector3.UP) * rng.randf_range(-0.4, 0.4))
		for k in 2:
			pick["pebble"].append(e - tw * rng.randf_range(-0.2, 1.4) + tw.cross(Vector3.UP) * rng.randf_range(-0.4, 0.4))
		if rng.randf() < 0.35:
			pick["wrack"].append(e - tw * rng.randf_range(0.1, 0.9))
		if rng.randf() < 0.05:
			pick["plank"].append(e - tw * rng.randf_range(0.3, 1.2))
	var hf := func(x: float, z: float) -> float: return maxf(float(height.call(x, z)), water_y - 0.01)
	for kind: String in pick:
		var pts: Array = pick[kind]
		if pts.is_empty():
			continue
		var mi := _scatter_at(parent, kind, pts, rng.randi(), hf)
		if mi:
			out.append(mi)
	return out


## ground_detail'in noktaları verilmiş hâli (kıyı bandı, iz çizgisi).
static func _scatter_at(parent: Node3D, kind: String, pts: Array, seed: int, height: Callable) -> MultiMeshInstance3D:
	var spec: Array = DETAIL.get(kind, DETAIL["stone"])
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var xs: Array = []
	var cs: Array = []
	for p: Vector3 in pts:
		var y := float(height.call(p.x, p.z)) + (0.03 if spec[4] else 0.0)
		if kind == "foam":
			y = p.y + 0.035
		var s := rng.randf_range(float(spec[0]), float(spec[1]))
		var b := Basis(Vector3.UP, rng.randf() * TAU) * Basis.from_scale(Vector3(s * rng.randf_range(0.8, 1.3), s, s))
		xs.append(Transform3D(b, Vector3(p.x, y, p.z)))
		cs.append((spec[2] as Color).lerp(spec[3], rng.randf()))
	var mat: Material = rock_material() if spec[5] == "rock" else (_gloss() if spec[5] == "gloss" else _detail())
	if kind in SOFT:
		mat = _soft(kind == "grease")
	if kind == "foam":
		mat = _foam()      # köpük yarı saydam: suyun üstünde kâğıt parçası gibi durmasın
	var mesh: Mesh = rock(rng.randi() % 3) if spec[5] == "rock" else detail_mesh(kind)
	var mi := Scenery.scatter(parent, mesh, xs, cs, mat)
	mi.set_meta("no_walk", true)
	mi.set_meta("soft", true)
	return mi


## Ayrıntı ağları (birim boy; örnek rengiyle boyanır): yassı leke, talaş, çalı, kütük parçası, tahta, yosun, iz.
static func detail_mesh(kind: String) -> Mesh:
	if _detail_meshes.has(kind):
		return _detail_meshes[kind]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(kind)
	match kind:
		"camp_mud":
			# dişli, kenara doğru incelen çamur yaması: ortası yarı saydam, orta halka daha saydam, dış
			# kenar sıfır; çevresinde birkaç sıçramış küçük çamur. (Eskiden opak çekirdekli yassı leke "yağ lekesi" gibiydi.)
			_soft_blob(st, rng, Vector2.ZERO, 0.5, 22, 0.62)
			for k in 4:
				var a := rng.randf() * TAU
				var d := rng.randf_range(0.5, 0.68)
				_soft_blob(st, rng, Vector2(cos(a) * d, sin(a) * d * 0.75), rng.randf_range(0.07, 0.14), 9, 0.4)
		"mud", "grease", "foam", "wet", "ash":
			# Düzensiz yassı leke (yarıçap ~0,5), ortası biraz kabarık; kenarı köşe rengiyle saydamlaşır (tur 3: eskiden
			# keskin kenarlı düz turuncu/bej çokgen, zeminde levha gibi duruyordu)
			var n := 13
			var ring: Array[Vector2] = []
			for i in n:
				var a := TAU * i / n
				var r := rng.randf_range(0.36, 0.55) * (1.0 if kind != "foam" else rng.randf_range(0.5, 1.0))
				ring.append(Vector2(cos(a) * r, sin(a) * r * (0.7 if kind != "foam" else 0.35)))
			Vfx._soft_poly(st, Vector2.ZERO, ring, 0.5, 0.0, 0.012)
		"footprint", "snow_print":
			# Bir çift çıplak ayak / çizme izi (sol-sağ, yürüyüş yönünde, adım arası): ortak ayak izi biçimi, kenarı yumuşak
			var foot: ArrayMesh = Vfx._footprint_mesh()
			for side: float in [-1.0, 1.0]:
				_append_soft(st, foot, Transform3D(Basis.from_scale(Vector3(side * 1.1, 1, 1.1)), Vector3(side * 0.09, 0, side * 0.33)))
		"chips":
			# Talaş ve yonga: birkaç yassı küçük parça, biri kıvrık
			for k in 6:
				var c := Vector3(rng.randf_range(-0.25, 0.25), 0.01, rng.randf_range(-0.25, 0.25))
				var a := rng.randf() * TAU
				var u := Vector3(cos(a), 0, sin(a)) * rng.randf_range(0.03, 0.07)
				var v := Vector3(-sin(a), 0, cos(a)) * rng.randf_range(0.012, 0.025)
				var lift := Vector3(0, rng.randf_range(0.0, 0.03), 0)
				_tri(st, c - u - v, c + u - v + lift, c + u + v + lift, Color.WHITE)
				_tri(st, c - u - v, c + u + v + lift, c - u + v, Color.WHITE)
		"bush":
			# Çalı: üç yamru top (yarıçap ~0,5), alttakiler koyu
			var sm := SphereMesh.new()
			sm.radial_segments = 7
			sm.rings = 4
			for b: Array in [[Vector3(0, 0.32, 0), 0.42, 0.85], [Vector3(0.28, 0.24, 0.12), 0.3, 0.75], [Vector3(-0.22, 0.26, -0.15), 0.32, 1.0]]:
				sm.radius = b[1]
				sm.height = float(b[1]) * 1.6
				_append(st, sm, Transform3D(Basis(), b[0]), Color(b[2], b[2], b[2]))
		"log":
			var cm := CylinderMesh.new()
			cm.top_radius = 0.16
			cm.bottom_radius = 0.17
			cm.height = 1.1
			cm.radial_segments = 7
			_append(st, cm, Transform3D(Basis(Vector3.FORWARD, PI / 2.0), Vector3(0, 0.15, 0)), Color.WHITE)
			cm.top_radius = 0.13
			cm.bottom_radius = 0.13
			cm.height = 0.02
			_append(st, cm, Transform3D(Basis(Vector3.FORWARD, PI / 2.0), Vector3(0.56, 0.15, 0)), Color(1.35, 1.25, 1.05))
		"plank":
			var bm := BoxMesh.new()
			bm.size = Vector3(1.2, 0.04, 0.18)
			_append(st, bm, Transform3D(Basis(Vector3.UP, 0.1), Vector3(0, 0.02, 0)), Color.WHITE)
		"wrack":
			# Kıyıya vurmuş yosun: birkaç yassı kıvrık şerit
			for k in 4:
				var a := rng.randf() * TAU
				var c := Vector3(rng.randf_range(-0.2, 0.2), 0.01, rng.randf_range(-0.2, 0.2))
				var d := Vector3(cos(a), 0, sin(a))
				var side := Vector3(-d.z, 0, d.x) * 0.04
				var prev := c
				for j in 4:
					var nx: Vector3 = prev + d * 0.12 + side * sin(j * 1.7) * 2.0
					_tri(st, prev - side, nx + side, nx - side, Color.WHITE)
					_tri(st, prev - side, prev + side, nx + side, Color.WHITE)
					prev = nx
		"hoofprint":
			# At izi (yayma P0): dört küçük yuvarlak nal izi, yürüyüş düzeninde (ön-arka, sol-sağ), kenarı yumuşak
			for q: Vector2 in [Vector2(-0.1, 0.42), Vector2(0.1, 0.12), Vector2(-0.1, -0.2), Vector2(0.1, -0.48)]:
				var ring: Array[Vector2] = []
				for i in 9:
					var a := TAU * i / 9
					ring.append(q + Vector2(cos(a) * 0.065, sin(a) * 0.08))
				Vfx._soft_poly(st, q, ring, 0.55, 0.0, -0.006)
		"straw":
			# Saman: yere dağılmış ince sarı çöpler
			for k in 12:
				var c := Vector3(rng.randf_range(-0.3, 0.3), 0.006 + k * 0.0015, rng.randf_range(-0.3, 0.3))
				var a := rng.randf() * TAU
				var u := Vector3(cos(a), 0, sin(a)) * rng.randf_range(0.08, 0.16)
				var v := Vector3(-sin(a), 0, cos(a)) * 0.008
				_tri(st, c - u - v, c + u - v, c + u + v, Color.WHITE)
				_tri(st, c - u - v, c + u + v, c - u + v, Color.WHITE)
		"arrows":
			# Yere saplı kırık ok: eğik sap, ucunda tüy (biri kırık, kısa)
			for k in 2:
				var len := 0.55 if k == 0 else 0.3
				var base := Vector3(k * 0.12 - 0.06, 0, k * 0.05)
				var dir := Vector3(rng.randf_range(-0.35, 0.35), 1.0, rng.randf_range(-0.35, 0.35)).normalized()
				var cm := CylinderMesh.new()
				cm.top_radius = 0.008
				cm.bottom_radius = 0.008
				cm.height = len
				cm.radial_segments = 4
				var x := dir.cross(Vector3.FORWARD).normalized()
				var b := Basis(x, dir, x.cross(dir).normalized())
				_append(st, cm, Transform3D(b, base + dir * len * 0.5), Color.WHITE)
				if k == 0:
					var tip := base + dir * len
					_tri(st, tip - dir * 0.12, tip + x * 0.035, tip, Color(1.6, 1.6, 1.55))
					_tri(st, tip - dir * 0.12, tip - x * 0.035, tip, Color(1.6, 1.6, 1.55))
		_:
			var bm2 := BoxMesh.new()
			bm2.size = Vector3(0.3, 0.1, 0.3)
			_append(st, bm2, Transform3D(), Color.WHITE)
	var m := st.commit()
	_detail_meshes[kind] = m
	return m


## Sualtı yosun demeti: 5 uzun, ucuna doğru incelen, kıvrık şerit (boy ~2,5 m); Vfx.sway_material ile salınır.
static func seaweed_mesh() -> Mesh:
	if _detail_meshes.has("seaweed"):
		return _detail_meshes["seaweed"]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for k in 5:
		var a := TAU * k / 5.0 + rng.randf_range(-0.3, 0.3)
		var base := Vector3(cos(a), 0, sin(a)) * rng.randf_range(0.05, 0.22)
		var h := rng.randf_range(1.6, 2.6)
		var w := rng.randf_range(0.07, 0.11)
		var side := Vector3(-sin(a + 0.8), 0, cos(a + 0.8))
		var segs := 6
		for j in segs:
			var t0 := float(j) / segs
			var t1 := float(j + 1) / segs
			var p0 := base + Vector3(sin(t0 * 4.0 + k) * 0.12, h * t0, cos(t0 * 3.0 + k) * 0.1)
			var p1 := base + Vector3(sin(t1 * 4.0 + k) * 0.12, h * t1, cos(t1 * 3.0 + k) * 0.1)
			var w0 := w * (1.0 - t0 * 0.8)
			var w1 := w * (1.0 - t1 * 0.8)
			var c0 := Color(0.55, 0.6, 0.5).lerp(Color(1.1, 1.1, 0.85), t0)
			var c1 := Color(0.55, 0.6, 0.5).lerp(Color(1.1, 1.1, 0.85), t1)
			for v: Array in [[p0 - side * w0, c0], [p1 + side * w1, c1], [p1 - side * w1, c1], [p0 - side * w0, c0], [p0 + side * w0, c0], [p1 + side * w1, c1]]:
				st.set_color(v[1])
				st.set_normal(side.cross(Vector3.UP).normalized())
				st.add_vertex(v[0])
	var m := st.commit()
	_detail_meshes["seaweed"] = m
	return m


static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color) -> void:
	for v: Vector3 in [a, b, c]:
		st.set_color(col)
		st.set_normal(Vector3.UP)
		st.add_vertex(v)


static func _append(st: SurfaceTool, mesh: Mesh, xf: Transform3D, col: Color) -> void:
	var arr: Array = mesh.surface_get_arrays(0)
	var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var nr: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
	var ix: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
	if ix.is_empty():
		for i in v.size():
			ix.append(i)
	for i in ix:
		st.set_color(col)
		st.set_normal((xf.basis * nr[i]).normalized())
		st.add_vertex(xf * v[i])


static func _detail() -> StandardMaterial3D:
	if _detail_mat == null:
		_detail_mat = StandardMaterial3D.new()
		_detail_mat.vertex_color_use_as_albedo = true
		_detail_mat.vertex_color_is_srgb = true
		_detail_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		_detail_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		_detail_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _detail_mat


## Parlak yağ/ıslaklık: köşe rengi, düşük pürüzlülük, çizgi film parıltısı (güneşte ışıldar).
static func _gloss() -> StandardMaterial3D:
	if _gloss_mat == null:
		_gloss_mat = StandardMaterial3D.new()
		_gloss_mat.vertex_color_use_as_albedo = true
		_gloss_mat.vertex_color_is_srgb = true
		_gloss_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		_gloss_mat.specular_mode = BaseMaterial3D.SPECULAR_TOON
		_gloss_mat.roughness = 0.3
		_gloss_mat.metallic_specular = 0.6
		_gloss_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _gloss_mat


static var _foam_mat: StandardMaterial3D
static func _foam() -> StandardMaterial3D:
	if _foam_mat == null:
		_foam_mat = StandardMaterial3D.new()
		_foam_mat.vertex_color_use_as_albedo = true
		_foam_mat.albedo_color = Color(1, 1, 1, 0.5)
		_foam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_foam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_foam_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _foam_mat


## Yumuşak kenarlı yassı yamaların malzemesi: köşe rengi (alfa dahil) × örnek rengi, saydam; gloss: yağ gibi parlak.
static var _soft_mats := {}
static func _soft(gloss := false) -> StandardMaterial3D:
	if not _soft_mats.has(gloss):
		var m := StandardMaterial3D.new()
		m.vertex_color_use_as_albedo = true
		m.vertex_color_is_srgb = true
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
		m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		m.specular_mode = BaseMaterial3D.SPECULAR_TOON if gloss else BaseMaterial3D.SPECULAR_DISABLED
		if gloss:
			m.roughness = 0.3
			m.metallic_specular = 0.6
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.albedo_color = Color(1, 1, 1, 0.85)
		_soft_mats[gloss] = m
	return _soft_mats[gloss]


## Yumuşak kenarlı düzensiz yassı leke (camp_mud): merkez alfa a0, orta halka (yarıçapın %55'i) a0 * 0,6,
## dişli dış kenar 0. r: ortalama yarıçap, n: kenar noktası.
static func _soft_blob(st: SurfaceTool, rng: RandomNumberGenerator, c: Vector2, r: float, n: int, a0: float) -> void:
	var ph := rng.randf() * TAU
	var outer: Array[Vector2] = []
	for i in n:
		var a := TAU * i / n
		var rr := r * rng.randf_range(0.68, 1.12) * (1.0 + 0.16 * sin(a * 3.0 + ph))
		outer.append(c + Vector2(cos(a) * rr, sin(a) * rr * 0.78))
	var cv := Vector3(c.x, 0.006, c.y)
	var ca := Color(1, 1, 1, a0)
	var ma := Color(1, 1, 1, a0 * 0.6)
	var oa := Color(1, 1, 1, 0.0)
	var mid: Array[Vector2] = []
	for o: Vector2 in outer:
		mid.append(c + (o - c) * rng.randf_range(0.45, 0.6))
	for i in n:
		var o0: Vector2 = outer[i]
		var o1: Vector2 = outer[(i + 1) % n]
		var m0: Vector2 = mid[i]
		var m1: Vector2 = mid[(i + 1) % n]
		var v0 := Vector3(o0.x, 0, o0.y)
		var v1 := Vector3(o1.x, 0, o1.y)
		var w0 := Vector3(m0.x, 0.003, m0.y)
		var w1 := Vector3(m1.x, 0.003, m1.y)
		for v: Array in [[cv, ca], [w1, ma], [w0, ma], [w0, ma], [w1, ma], [v1, oa], [w0, ma], [v1, oa], [v0, oa]]:
			st.set_color(v[1])
			st.set_normal(Vector3.UP)
			st.add_vertex(v[0])


## Köşe rengi (alfa) korunarak ağ eklenir (ayak izi ağı).
static func _append_soft(st: SurfaceTool, mesh: Mesh, xf: Transform3D) -> void:
	var arr: Array = mesh.surface_get_arrays(0)
	var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var cl = arr[Mesh.ARRAY_COLOR]
	for i in v.size():
		st.set_color(cl[i] if cl != null and cl.size() > i else Color.WHITE)
		st.set_normal(Vector3.UP)
		st.add_vertex(xf * v[i])


# ---------------------------------------------------------------- rıhtım dibi ve iz çizgisi (yayma P0)

## Rıhtım dibi: dikey taş rıhtımın / sur duvarının su kenarı (from→to, duvar yüzü çizgisi; to_water: duvardan suya
## yön). Duvarın dibinde su çizgisinin üstünde koyu ıslak taş bandı (yukarı doğru saydamlaşır), su çizgisinde düzensiz
## yeşil yosun lekeleri, suyun üstünde duvar boyunca köpük ve arada yüzen yosun. Tek ağ (bant + yosun) + iki çoklu ağ.
## Döner: kurulan düğümler. shore_band eğimli kumsal içindir; bu dik duvar içindir.
## Örnek: Nature.quay_band(self, Vector3(-30, 0, 12.4), Vector3(30, 0, 12.4), Vector3(0, 0, 1), SU_Y)
## Galata rıhtımı (10g, 27), Haliç surları (4b, 17o), Petrion (38o), Boğaz hisarı iskelesi.
static func quay_band(parent: Node3D, from: Vector3, to: Vector3, to_water: Vector3, water_y: float, seed := 7,
		wet_h := 0.7) -> Array:
	var out: Array = []
	var tw := Vector3(to_water.x, 0, to_water.z).normalized()
	var along := Vector3(to.x - from.x, 0, to.z - from.z)
	var ln := along.length()
	if ln < 0.2 or tw.length() < 0.5:
		return out
	along /= ln
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var base := Vector3(from.x, water_y, from.z) + tw * 0.015
	var wet := Color("2a2a22")
	var steps := maxi(2, int(ln / 0.5))
	# Islak bant: alt kenar su altında (dolu), üst kenar dalgalı ve saydam
	var prev_top := 0.0
	for i in steps + 1:
		var top := wet_h * rng.randf_range(0.6, 1.0)
		if i > 0:
			var a := base + along * (ln * (i - 1) / steps)
			var b := base + along * (ln * i / steps)
			var q := [a + Vector3(0, -0.15, 0), b + Vector3(0, -0.15, 0), b + Vector3(0, top, 0), a + Vector3(0, prev_top, 0)]
			var al := [0.85, 0.85, 0.0, 0.0]
			for j: int in [0, 2, 1, 0, 3, 2]:
				st.set_color(Color(wet.r, wet.g, wet.b, al[j]))
				st.set_normal(tw)
				st.add_vertex(q[j])
		prev_top = top
	# Yosun lekeleri: su çizgisinde, duvara yapışık (biraz önde), yeşilden kahveye
	var moss_n := int(ln * 1.4)
	for k in moss_n:
		var c := base + tw * 0.01 + along * rng.randf_range(0.0, ln) + Vector3(0, rng.randf_range(-0.05, 0.12), 0)
		var w := rng.randf_range(0.18, 0.55)
		var h := rng.randf_range(0.08, 0.22)
		var col := Color("2e4a1e").lerp(Color("5a5a28"), rng.randf())
		var n := 8
		var ctr := c
		for i in n:
			var a0 := TAU * i / n
			var a1 := TAU * (i + 1) / n
			var p0 := c + along * cos(a0) * w * 0.5 + Vector3(0, sin(a0) * h * 0.5 * (1.4 if sin(a0) < 0 else 1.0), 0)
			var p1 := c + along * cos(a1) * w * 0.5 + Vector3(0, sin(a1) * h * 0.5 * (1.4 if sin(a1) < 0 else 1.0), 0)
			for v: Array in [[ctr, 0.95], [p1, 0.0], [p0, 0.0]]:
				st.set_color(Color(col.r, col.g, col.b, v[1]))
				st.set_normal(tw)
				st.add_vertex(v[0])
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var m := _soft(false).duplicate() as StandardMaterial3D
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.set_meta("no_walk", true)
	parent.add_child(mi)
	if parent.is_inside_tree():
		mi.global_transform = Transform3D.IDENTITY
	out.append(mi)
	# Köpük ve yüzen yosun: suyun üstünde, duvarın dibinde
	var foam: Array = []
	var wrack: Array = []
	var fs := maxi(2, int(ln / 0.45))
	for i in fs:
		var p := Vector3(from.x, water_y, from.z) + along * (ln * (i + rng.randf()) / fs)
		foam.append(p + tw * rng.randf_range(0.08, 0.45))
		if rng.randf() < 0.12:
			wrack.append(p + tw * rng.randf_range(0.3, 1.2))
	var hf := func(_x: float, _z: float) -> float: return water_y
	var f := _scatter_at(parent, "foam", foam, rng.randi(), hf)
	if f:
		out.append(f)
	if not wrack.is_empty():
		var wr := _scatter_at(parent, "wrack", wrack, rng.randi(), func(_x: float, _z: float) -> float: return water_y - 0.015)
		if wr:
			out.append(wr)
	return out


## İz çizgisi: bir yol boyunca (path: dünya noktaları) yürüyüş yönüne dönük izler: "footprint", "hoofprint",
## "snow_print" ya da "wheel_ruts" (iki paralel tekerlek izi şeridi, aks 1,3 m). spacing: izler arası (m). Tek çoklu ağ.
## Örnek: Nature.trail(self, [Vector3(0, 0, 0), Vector3(4, 0, 12), Vector3(5, 0, 30)], "hoofprint", arazi_y, 1.4)
## Ordugâh yolu (35o tekerlek izi), at izi, kar izi (34o), çamurlu meydan.
static func trail(parent: Node3D, path: Array, kind: String, height: Callable, spacing := 1.2, seed := 3, jitter := 0.25) -> MultiMeshInstance3D:
	if path.size() < 2:
		return null
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var xs: Array = []
	var cs: Array = []
	var ruts := kind == "wheel_ruts"
	var spec: Array = DETAIL.get("footprint" if ruts else kind, DETAIL["footprint"])
	for i in path.size() - 1:
		var a: Vector3 = path[i]
		var b: Vector3 = path[i + 1]
		var d := Vector3(b.x - a.x, 0, b.z - a.z)
		var ln := d.length()
		if ln < 0.01:
			continue
		d /= ln
		var side := Vector3(-d.z, 0, d.x)
		var step := spacing if not ruts else 0.9
		var n := maxi(1, int(ln / step))
		for k in n:
			var p := a.lerp(b, (k + 0.5) / n) + side * rng.randf_range(-jitter, jitter) * (0.3 if ruts else 1.0)
			var yaw := atan2(d.x, d.z) + rng.randf_range(-0.15, 0.15) * (0.2 if ruts else 1.0)
			var offs: Array = [Vector3.ZERO] if not ruts else [side * 0.65, -side * 0.65]
			for o: Vector3 in offs:
				var q := p + o
				var y := float(height.call(q.x, q.z)) + 0.025
				var sc := Vector3(0.22, 1.0, 1.45) if ruts else Vector3.ONE * rng.randf_range(float(spec[0]), float(spec[1]))
				xs.append(Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(sc), Vector3(q.x, y, q.z)))
				cs.append((spec[2] as Color).lerp(spec[3], rng.randf()))
	if xs.is_empty():
		return null
	var mesh: Mesh = detail_mesh("mud") if ruts else detail_mesh(kind)
	var mi := Scenery.scatter(parent, mesh, xs, cs, _soft(false))
	mi.set_meta("no_walk", true)
	mi.set_meta("soft", true)
	mi.visibility_range_end = 120.0
	return mi
