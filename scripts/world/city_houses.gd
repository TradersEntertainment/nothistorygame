class_name CityHouses
extends RefCounted
## Dünyanın şehir evleri: Kit.house (Quaternius Medieval Village: sıvalı / düzensiz tuğla duvarlar, kemerli pencereler,
## kepenkler, balkonlar, oluklu kiremit çatı) ile kurulan birkaç örnek ev bir kez pişirilir ve MultiMesh ile sokak
## kenarlarına çoğaltılır. Üç katman (bir ev ~20 bin üçgen: binlercesi tam ayrıntıda çizilemez):
##   · Yakın: dokulu tam model (malzemeye göre birleşik yüzeyler), 60 m'lik hücrelerde örnek başına bir MultiMesh;
##     hücre ortası NEAR metreden uzaksa gizli.
##   · Orta: aynı evin kutulardan sade kopyası (~500 üçgen, köşe renkli, tek yüzey); NEAR…MID.
##   · Uzak: sade kutu (gövde + beşik çatı), 400 m'lik hücrelerde, her uzaklıkta görünür (yakında modelin içinde
##     kalır). Çarpışma (WorldWalk) bu kutulardan alınır: gövde + çatı tek kutu, saçak basamak olmaz.
## Ev yerel çerçevesi (CityPlan): yerel x sokaktan dışarı (derinlik), yerel z sokak boyunca (cephe), taban ortası.

const NEAR := 55.0
const MID := 260.0
const CELL := 60.0
const CELL_FAR := 400.0
const FH := 3.12                 # Kit.house kat yüksekliği
const PLINTH := 4.0              # yamaçta evin altındaki taş kaide (yerel y −4 … 0)
## Örnekler: [bölme (2 m), derinlik (2 m), kat, zemin kat tuğla, sıva boyası, balkon olasılığı, tohum]
const VARIANTS := [
	[2, 3, 2, true, Color("f0e2c8"), 0.3, 11],
	[3, 3, 2, false, Color("e8c890"), 0.4, 12],
	[3, 4, 3, true, Color("f4eee2"), 0.5, 13],
	[4, 3, 2, true, Color("f0cfc0"), 0.3, 14],
	[2, 3, 1, false, Color("ece0cc"), 0.0, 15],
	[4, 4, 3, true, Color("f0dca8"), 0.5, 16],
	[5, 4, 2, false, Color("f2e6d0"), 0.4, 17],
]
## Sokak türüne göre örnekler (CityPlan.MESE, ROAD, LANE)
const BY_KIND := [[2, 3, 5, 6], [1, 2, 3, 5], [0, 1, 4, 3, 0]]
const FAR_COLS := [Color("cdb898"), Color("c8a878"), Color("d0c4ae"), Color("c8a898"), Color("c4b49a"), Color("ccb080"), Color("cebca0")]
const CACHE_DIR := "user://house_cache"

static var _meshes := {}         # örnek → [tam, orta]
static var _far: ArrayMesh
static var _far_mat: StandardMaterial3D
static var _mid_mat: StandardMaterial3D
static var _salt := ""


## Örneğin taban boyutu: Vector3(derinlik, gövde yüksekliği, cephe)
static func size(v: int) -> Vector3:
	var d: Array = VARIANTS[v]
	return Vector3(int(d[1]) * 2.0, int(d[2]) * FH, int(d[0]) * 2.0)


## Çatı dahil toplam yükseklik
static func height(v: int) -> float:
	var d: Array = VARIANTS[v]
	return int(d[2]) * FH + 2.2 + int(d[1]) * 0.3


## Evler: list CityPlan.houses_in kayıtları. surf: görünen yüzey (x, z → y). free(x, z, pay): bölümün alanı dışı mı.
## nd: gece ışıkları (cephede fener).
static func build(parent: Node3D, list: Array, surf: Callable, free: Callable, nd: Dressing) -> void:
	var near := {}            # Vector3i(hücre x, hücre z, örnek) → [Transform3D]
	var far := {}             # Vector2i → [[Transform3D], [Color]]
	var i := 0
	for h: Dictionary in list:
		var c: Vector2 = h["c"]
		var v: int = h.get("v", 0)
		var s := size(v)
		var r := maxf(s.x, s.z) * 0.5
		if not free.call(c.x, c.y, r + 2.0):
			continue
		var yaw: float = h["yaw"]
		var st := LowPoly.seat(c.x, c.y, r * 0.85, r * 0.85, surf)
		var floor_y := st.x + 0.35 + st.y - 0.12          # döşeme: en yüksek köşenin hemen altı (kaide aşağıda)
		var b := Basis(Vector3.UP, yaw)
		var nk := Vector3i(floori(c.x / CELL), floori(c.y / CELL), v)
		if not near.has(nk):
			near[nk] = []
		near[nk].append(Transform3D(b, Vector3(c.x, floor_y, c.y)))
		var fk := Vector2i(floori(c.x / CELL_FAR), floori(c.y / CELL_FAR))
		if not far.has(fk):
			far[fk] = [[], []]
		far[fk][0].append(Transform3D(b * Basis.from_scale(Vector3(s.x, s.y, s.z)), Vector3(c.x, floor_y, c.y)))
		far[fk][1].append(FAR_COLS[v % FAR_COLS.size()])
		if i % 4 == 0:
			var away: Vector2 = h["away"]
			var f := c - away * (s.x * 0.5 + 0.08)
			nd.at(Vector3(f.x, floor_y + 2.3, f.y), yaw).glow(Vector3(0.1, 0.45, 0.32), Vector3.ZERO, Color("ffc870"))
		i += 1
	nd.at(Vector3.ZERO)
	for fk: Vector2i in far:
		_layer(parent, far_mesh(), far[fk][0], far[fk][1], _far_material())
	if not Kit.has_village():
		return
	for nk: Vector3i in near:
		var ms := meshes(nk.z)
		var a := _layer(parent, ms[0], near[nk], [], null)
		a.visibility_range_end = NEAR
		a.set_meta("no_walk", true)             # çarpışma uzak katmanın kutularından
		var m := _layer(parent, ms[1], near[nk], [], _mid_material())
		m.visibility_range_begin = NEAR
		m.visibility_range_end = MID
		m.set_meta("no_walk", true)


## Bir hücrenin MultiMesh'i: düğüm hücrenin ortasında (görünürlük uzaklığı oradan ölçülür), örnekler ona göre.
## "xforms" metası (WorldWalk) düğüme göre.
static func _layer(parent: Node3D, m: Mesh, xfs: Array, cols: Array, mat: Material) -> MultiMeshInstance3D:
	var c := Vector3.ZERO
	for x: Transform3D in xfs:
		c += x.origin
	c /= xfs.size()
	var local: Array = []
	for x: Transform3D in xfs:
		local.append(Transform3D(x.basis, x.origin - c))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = not cols.is_empty()
	mm.mesh = m
	mm.instance_count = local.size()
	for k in local.size():
		mm.set_instance_transform(k, local[k])
		if mm.use_colors:
			mm.set_instance_color(k, cols[k])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.position = c
	mi.set_meta("xforms", local)
	if mat:
		mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


## Uzak ev: birim boyutlu; gövde (y −0,6…1, yamaçta kaide) yanlardan %8 içeride (yakında modelin duvarlarının
## içinde kalır, titreşmez), sokağa paralel mahyalı beşik çatı (y 1…1,3). Örnek rengi gövdeyi boyar. Sınır kutusu
## evin tam tabanı: WorldWalk çarpışması evle aynı genişlikte.
static func far_mesh() -> ArrayMesh:
	if _far == null:
		var roof := PrismMesh.new()
		roof.size = Vector3(1.0, 0.3, 1.0)
		_far = Scenery.merged([
			[Scenery._boxm(Vector3(0.92, 1.6, 0.92)), Scenery._t(Vector3(0, 0.2, 0)), Color.WHITE],
			[roof, Scenery._t(Vector3(0, 1.15, 0), Vector3.ZERO, Vector3(0.96, 1, 0.98)), Color(0.72, 0.36, 0.26)],
			[Scenery._boxm(Vector3(1.0, 0.02, 1.0)), Scenery._t(Vector3(0, -0.59, 0)), Color(0.5, 0.45, 0.4)],
		])
	return _far


static func _far_material() -> StandardMaterial3D:
	if _far_mat == null:
		_far_mat = Scenery._vc_mat()
	return _far_mat


static func _mid_material() -> StandardMaterial3D:
	if _mid_mat == null:
		_mid_mat = Scenery._vc_mat()
	return _mid_mat


## Örneğin ağları: [tam (dokulu), orta (köşe renkli LOD)]; bellekte ve diskte önbellek
static func meshes(v: int) -> Array:
	if _meshes.has(v):
		return _meshes[v]
	var out: Array = []
	for k in 2:
		var path := _cache_path(v, k)
		if FileAccess.file_exists(path):
			var m := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as ArrayMesh
			if m:
				out.append(m)
	if out.size() < 2:
		out = _bake(v)
		DirAccess.make_dir_recursive_absolute(CACHE_DIR)
		for k in 2:
			ResourceSaver.save(out[k], _cache_path(v, k), ResourceSaver.FLAG_COMPRESS)
	_meshes[v] = out
	return out


static func _cache_path(v: int, k: int) -> String:
	if _salt == "":
		var parts := ""
		for f in ["res://scripts/level/kit.gd", "res://scripts/world/city_houses.gd"]:
			if FileAccess.file_exists(f):
				parts += FileAccess.get_md5(f)
		_salt = parts.md5_text()
	return CACHE_DIR.path_join(("house%d_%d" % [v, k] + _salt).md5_text() + ".res")


## Kit.house sahne dışında kurulur; görünür parçaları malzeme adına göre birleşik yüzeylere toplanır (saydam cam,
## sarmaşık ve küçük metal süsler atılır). Cephe yerel −x'e (sokağa), boyu yerel z'ye döner; altına taş kaide.
static func _bake(v: int) -> Array:
	var d: Array = VARIANTS[v]
	var rng := RandomNumberGenerator.new()
	rng.seed = d[6]
	var holder := Node3D.new()
	var depth := int(d[1]) * 2.0
	var root := Kit.house(holder, Vector3(0, 0, depth * 0.5), 0.0, d[0], d[2], rng,
		{"depth": d[1], "brick": d[3], "tint": d[4], "balcony": d[5], "vine": 0.0})
	var turn := Transform3D(Basis(Vector3.UP, -PI * 0.5), Vector3.ZERO)
	var groups := {}            # ad → [SurfaceTool, malzeme]
	for c in root.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null:
			continue
		var xf := turn * _rel(mi, holder)
		for si in mi.mesh.get_surface_count():
			var m := mi.get_active_material(si) as BaseMaterial3D
			if m == null or m.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
				continue
			var nm := m.resource_name.replace("_Wear", "")
			if nm.contains("Metal") or nm.contains("Glass") or nm.contains("Vine"):
				continue
			if not groups.has(nm):
				var st := SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				groups[nm] = [st, m]
			(groups[nm][0] as SurfaceTool).append_from(mi.mesh, si, xf)
	holder.free()
	var im := ImporterMesh.new()
	for nm: String in groups:
		var st: SurfaceTool = groups[nm][0]
		st.index()
		im.add_surface(Mesh.PRIMITIVE_TRIANGLES, st.commit_to_arrays(), [], {}, groups[nm][1], nm)
	# Taş kaide (yamaçta evin altı): dünyaya göre desenli kesme taş
	var s := size(v)
	var pst := SurfaceTool.new()
	pst.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bm := BoxMesh.new()
	bm.size = Vector3(s.x + 0.3, PLINTH, s.z + 0.3)
	pst.append_from(bm, 0, Transform3D(Basis.IDENTITY, Vector3(0, -PLINTH * 0.5 + 0.02, 0)))
	pst.index()
	im.add_surface(Mesh.PRIMITIVE_TRIANGLES, pst.commit_to_arrays(), [], {}, Props.mat(Color("b8aa90"), 0.0, false, "ashlar"), "Plinth")
	im.generate_lods(25.0, 60.0, [])
	return [im.get_mesh(), _mid(v)]


## Orta katman: aynı evin kutulardan sade kopyası (~500 üçgen, köşe renkli): kaide, tuğla zemin kat, sıvalı üst
## katlar, kat hatılları, köşe taşları, cephede pencere ve kepenk, kapı, sokağa paralel kiremit çatı, baca. Uzak
## kutuyu (far_mesh) içine alır.
static func _mid(v: int) -> ArrayMesh:
	var d: Array = VARIANTS[v]
	var rng := RandomNumberGenerator.new()
	rng.seed = int(d[6]) + 100
	var s := size(v)
	var D := s.x
	var H := s.y
	var W := s.z
	var bays: int = d[0]
	var floors: int = d[2]
	var plaster: Color = Color("e6dcc8") * (d[4] as Color)
	var brick := Color("a08a78") if d[3] else plaster.darkened(0.06)
	var wood := Color("6a4a30")
	var stone := Color("d8d2c4")
	var dark := Color("2a2420")
	var parts: Array = []
	var box := func(sz: Vector3, p: Vector3, c: Color) -> void:
		parts.append([Scenery._boxm(sz), Scenery._t(p), c])
	box.call(Vector3(D + 0.3, PLINTH, W + 0.3), Vector3(0, -PLINTH * 0.5 + 0.02, 0), Color("a89a84"))
	box.call(Vector3(D, FH, W), Vector3(0, FH * 0.5, 0), brick)
	if floors > 1:
		box.call(Vector3(D, H - FH, W), Vector3(0, FH + (H - FH) * 0.5, 0), plaster)
	for f in floors:
		box.call(Vector3(D + 0.08, 0.2, W + 0.08), Vector3(0, (f + 1) * FH - 0.1, 0), wood)
	for cx: float in [-1.0, 1.0]:
		for cz: float in [-1.0, 1.0]:
			box.call(Vector3(0.36, H, 0.36), Vector3(cx * (D * 0.5 - 0.1), H * 0.5, cz * (W * 0.5 - 0.1)), stone)
	var door := rng.randi_range(0, bays - 1)
	for f in floors:
		for b in bays:
			var z := -W * 0.5 + 1.0 + b * 2.0
			var y := f * FH
			if f == 0 and b == door:
				box.call(Vector3(0.1, 2.2, 1.1), Vector3(-D * 0.5 - 0.03, y + 1.1, z), wood.darkened(0.2))
				continue
			if f == 0 and rng.randf() > 0.4:
				continue
			box.call(Vector3(0.1, 1.3, 0.75), Vector3(-D * 0.5 - 0.03, y + 1.6, z), dark)
			box.call(Vector3(0.1, 1.3, 0.3), Vector3(-D * 0.5 - 0.06, y + 1.6, z - 0.58), wood)
			box.call(Vector3(0.1, 1.3, 0.3), Vector3(-D * 0.5 - 0.06, y + 1.6, z + 0.58), wood)
			box.call(Vector3(0.1, 1.2, 0.7), Vector3(D * 0.5 + 0.03, y + 1.6, z), dark)
	var rise := 2.2 + int(d[1]) * 0.3
	var roof := PrismMesh.new()
	roof.size = Vector3(D + 0.7, rise, W + 0.7)
	parts.append([roof, Scenery._t(Vector3(0, H + rise * 0.5, 0)), Color("b05a3c")])
	if rng.randf() < 0.6:
		box.call(Vector3(0.7, 1.6, 0.7), Vector3(D * 0.2, H + rise * 0.6, W * 0.25), Color("9a8070"))
	return Scenery.merged(parts)


static func _rel(n: Node3D, top: Node3D) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var cur: Node = n
	while cur != null and cur != top:
		if cur is Node3D:
			xf = (cur as Node3D).transform * xf
		cur = cur.get_parent()
	return xf
