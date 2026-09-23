class_name Props
## Low-poly sahne parçaları üretmek için yardımcı fonksiyonlar.
## Oyunun görselleri harici model kullanmadan bu basit şekillerden kurulur:
## düz renkler, az köşe, hafif abartı ("bütçe estetiği", GDD §12.1).

static var _materials: Dictionary = {}


static func mat(color: Color, emission := 0.0, transparent := false) -> StandardMaterial3D:
	var key := "%s|%s|%s" % [color.to_html(), emission, transparent]
	if _materials.has(key):
		return _materials[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	m.metallic = 0.0
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emission
	if transparent:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_materials[key] = m
	return m


static func _place(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color, rot_deg := Vector3.ZERO, emission := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat(color, emission, color.a < 1.0)
	mi.position = pos
	mi.rotation_degrees = rot_deg
	parent.add_child(mi)
	return mi


static func box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, rot_deg := Vector3.ZERO, emission := 0.0) -> MeshInstance3D:
	var m := BoxMesh.new()
	m.size = size
	return _place(parent, m, pos, color, rot_deg, emission)


static func cyl(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color, rot_deg := Vector3.ZERO, segments := 8, top_radius := -1.0, emission := 0.0) -> MeshInstance3D:
	var m := CylinderMesh.new()
	m.bottom_radius = radius
	m.top_radius = radius if top_radius < 0.0 else top_radius
	m.height = height
	m.radial_segments = segments
	m.rings = 1
	return _place(parent, m, pos, color, rot_deg, emission)


static func ball(parent: Node3D, radius: float, pos: Vector3, color: Color, scale := Vector3.ONE, segments := 10, emission := 0.0) -> MeshInstance3D:
	var m := SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	m.radial_segments = segments
	m.rings = maxi(4, segments / 2)
	var mi := _place(parent, m, pos, color, Vector3.ZERO, emission)
	mi.scale = scale
	return mi


static func ring(parent: Node3D, inner: float, outer: float, pos: Vector3, color: Color, rot_deg := Vector3.ZERO, emission := 0.0) -> MeshInstance3D:
	var m := TorusMesh.new()
	m.inner_radius = inner
	m.outer_radius = outer
	m.rings = 16
	m.ring_segments = 6
	return _place(parent, m, pos, color, rot_deg, emission)


static func label(parent: Node3D, text: String, pos: Vector3, size := 48, color := Color.WHITE, rot_deg := Vector3.ZERO) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font_size = size
	l.pixel_size = 0.004
	l.modulate = color
	l.outline_size = 0
	l.position = pos
	l.rotation_degrees = rot_deg
	l.double_sided = false
	parent.add_child(l)
	return l


## Duvar, zemin gibi çarpışmalı statik kutu.
static func solid(parent: Node3D, size: Vector3, pos: Vector3, color: Color, rot_deg := Vector3.ZERO) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation_degrees = rot_deg
	parent.add_child(body)
	box(body, size, Vector3.ZERO, color)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	shape.shape = bs
	body.add_child(shape)
	return body


## Oyuncunun bakıp E ile etkileşebileceği bir alan (çarpışma katmanı 2).
static func interactable(parent: Node3D, id: String, size: Vector3, pos: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = "Interact_" + id
	body.collision_layer = 2
	body.collision_mask = 0
	body.position = pos
	body.set_meta("interact_id", id)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	shape.shape = bs
	body.add_child(shape)
	parent.add_child(body)
	return body
