class_name Flame
extends RefCounted
## Alev ve ışık halesi (assets/shaders/flame.gdshader): koni/küre yerine kameraya dönen, yumuşak kenarlı, titreyen alev
## ve sıcak hale. Meşale, kamp ateşi, kandil ve fener, ordugâhın uzak ateşleri bununla çizilir.
##   Flame.add(parent, pos, w, h)          tek alev (dibi pos'ta) + halesi
##   Flame.glow(parent, pos, size)         yalnız hale (uzak kandil, pencere ışığı)
##   Flame.scatter_flames(parent, xforms)  çoklu ağ alev (dönüşüm: dip noktası, ölçek x=en, y=boy)
##   Flame.scatter_glows(parent, xforms)   çoklu ağ hale (ölçek = çap)

const SHADER := preload("res://assets/shaders/flame.gdshader")

static var _mats := {}
static var _flame_mesh: QuadMesh
static var _glow_mesh: QuadMesh


## kind: "flame" / "glow"; sonuna "_vc" eklenirse parçacığın rengi (renk eğrisi) alevi boyar ve sönümler
static func mat(kind := "flame", energy := 1.6, core := Color("fff0a8"), edge := Color("ff6a14")) -> ShaderMaterial:
	var key := "%s|%.2f|%s|%s" % [kind, energy, core.to_html(), edge.to_html()]
	if _mats.has(key):
		return _mats[key]
	var m := ShaderMaterial.new()
	m.shader = SHADER
	m.set_shader_parameter("mode", 0 if kind.begins_with("flame") else 1)
	m.set_shader_parameter("use_color", kind.ends_with("_vc"))
	m.set_shader_parameter("energy", energy)
	m.set_shader_parameter("core_color", core)
	m.set_shader_parameter("edge_color", edge)
	m.set_shader_parameter("flicker", 0.28 if kind.begins_with("flame") else 0.18)
	_mats[key] = m
	return m


## Dibi orijinde, 1 × 1 (ölçekle boyutlanır)
static func flame_mesh() -> QuadMesh:
	if _flame_mesh == null:
		_flame_mesh = QuadMesh.new()
		_flame_mesh.size = Vector2(1, 1)
		_flame_mesh.center_offset = Vector3(0, 0.5, 0)
	return _flame_mesh


static func glow_mesh() -> QuadMesh:
	if _glow_mesh == null:
		_glow_mesh = QuadMesh.new()
		_glow_mesh.size = Vector2(1, 1)
	return _glow_mesh


static func _inst(parent: Node3D, mesh: Mesh, m: Material, pos: Vector3, scale: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos
	mi.scale = scale
	# Kamera yönüne dönen dörtgen: sınır kutusu dönüşü kapsasın (yandan bakınca kırpılmasın)
	mi.extra_cull_margin = maxf(scale.x, scale.y)
	parent.add_child(mi)
	return mi


## Tek alev: dibi pos'ta, en w, boy h; içinde daha küçük sıcak çekirdek alev ve çevresinde hale
static func add(parent: Node3D, pos: Vector3, w := 0.5, h := 0.9, glow_size := -1.0) -> Node3D:
	var f := Node3D.new()
	f.position = pos
	parent.add_child(f)
	_inst(f, flame_mesh(), mat("flame", 1.5), Vector3.ZERO, Vector3(w, h, w))
	_inst(f, flame_mesh(), mat("flame", 1.2, Color("fffbe0"), Color("ffb040")), Vector3(0, 0.01, 0), Vector3(w * 0.55, h * 0.6, w * 0.55))
	var gs := glow_size if glow_size > 0.0 else maxf(w, h) * 2.6
	_inst(f, glow_mesh(), mat("glow", 0.55, Color("ffd890"), Color("ff7a20")), Vector3(0, h * 0.4, 0), Vector3.ONE * gs)
	f.set_meta("flame", true)
	return f


## Tek alev dili (halesiz): ateşin yanlarındaki küçük diller
static func tongue(parent: Node3D, pos: Vector3, w: float, h: float, energy := 1.4) -> MeshInstance3D:
	return _inst(parent, flame_mesh(), mat("flame", energy), pos, Vector3(w, h, w))


static func glow(parent: Node3D, pos: Vector3, size := 0.8, energy := 0.9, core := Color("ffe0a0"), edge := Color("ff8a28")) -> MeshInstance3D:
	return _inst(parent, glow_mesh(), mat("glow", energy, core, edge), pos, Vector3.ONE * size)


static func _scatter(parent: Node3D, mesh: Mesh, m: Material, xforms: Array) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	var ab := AABB()
	for i in xforms.size():
		var x: Transform3D = xforms[i]
		mm.set_instance_transform(i, x)
		var s := x.basis.get_scale()
		var r := maxf(s.x, s.y)
		var b := AABB(x.origin - Vector3(r, r, r), Vector3(r, r, r) * 2.0)
		ab = b if i == 0 else ab.merge(b)
	mm.custom_aabb = ab
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.set_meta("xforms", xforms)
	parent.add_child(mi)
	return mi


static func scatter_flames(parent: Node3D, xforms: Array, energy := 1.5) -> MultiMeshInstance3D:
	return _scatter(parent, flame_mesh(), mat("flame", energy), xforms)


static func scatter_glows(parent: Node3D, xforms: Array, energy := 0.9, core := Color("ffe0a0"), edge := Color("ff8a28")) -> MultiMeshInstance3D:
	return _scatter(parent, glow_mesh(), mat("glow", energy, core, edge), xforms)


## Parçacık ağı: malzemesi yüzeyde (CPUParticles3D mesh'in malzemesini kullanır)
static func particle_mesh(kind := "flame", energy := 1.6) -> QuadMesh:
	var q := QuadMesh.new()
	q.size = Vector2(1, 1)
	if kind == "flame":
		q.center_offset = Vector3(0, 0.5, 0)
	q.material = mat(kind + "_vc", energy)
	return q
