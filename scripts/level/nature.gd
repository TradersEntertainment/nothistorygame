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
