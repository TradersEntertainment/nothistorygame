class_name Props
## Low-poly sahne parçaları üretmek için yardımcı fonksiyonlar.
## Oyunun görselleri harici model kullanmadan bu basit şekillerden kurulur:
## düz renkler, az köşe, hafif abartı ("bütçe estetiği", GDD §12.1).

static var _materials: Dictionary = {}
static var _noise_cache: Dictionary = {}
static var _outline: StandardMaterial3D

## Dış hatlar (ters kabuk yöntemi). Performans için kapatılabilir.
static var outlines := true
const OUTLINE_COLOR := Color("141821")
const OUTLINE_WIDTH := 0.012


## Düz renkli, çizgi film gölgeli malzeme.
## pattern: "" (düz), "concrete" (beton), "wall" (boyalı duvar), "wood" (ahşap).
static func mat(color: Color, emission := 0.0, transparent := false, pattern := "", outline := true) -> StandardMaterial3D:
	var key := "%s|%s|%s|%s|%s" % [color.to_html(), emission, transparent, pattern, outline]
	if _materials.has(key):
		return _materials[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.specular_mode = BaseMaterial3D.SPECULAR_TOON
	m.roughness = 0.9
	m.metallic_specular = 0.2
	m.rim_enabled = true
	m.rim = 0.2
	m.rim_tint = 0.6
	if pattern != "":
		m.albedo_texture = _noise(pattern)
		m.uv1_triplanar = true
		m.uv1_world_triplanar = true
		match pattern:
			"wood":
				m.uv1_scale = Vector3(0.35, 2.5, 0.35)
			"concrete":
				m.uv1_scale = Vector3(0.3, 0.3, 0.3)
			_:
				m.uv1_scale = Vector3(0.5, 0.5, 0.5)
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emission
	if transparent:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	elif outlines and outline:
		m.next_pass = _outline_mat()
	_materials[key] = m
	return m


static func _outline_mat() -> StandardMaterial3D:
	if _outline == null:
		_outline = StandardMaterial3D.new()
		_outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_outline.albedo_color = OUTLINE_COLOR
		_outline.cull_mode = BaseMaterial3D.CULL_FRONT
		_outline.grow = true
		_outline.grow_amount = OUTLINE_WIDTH
	return _outline


## Dokular için gürültü: albedo rengiyle çarpılır, bu yüzden 0.75..1.0 arasında kalır.
static func _noise(kind: String) -> NoiseTexture2D:
	if _noise_cache.has(kind):
		return _noise_cache[kind]
	var n := FastNoiseLite.new()
	var g := Gradient.new()
	match kind:
		"concrete":
			n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
			n.frequency = 0.035
			n.fractal_octaves = 5
			g.set_color(0, Color(0.72, 0.72, 0.74))
			g.set_color(1, Color(1, 1, 1))
		"wood":
			n.noise_type = FastNoiseLite.TYPE_PERLIN
			n.frequency = 0.05
			n.fractal_octaves = 2
			n.frequency = 0.02
			g.set_color(0, Color(0.88, 0.85, 0.82))
			g.set_color(1, Color(1, 1, 1))
		_:
			n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
			n.frequency = 0.02
			n.fractal_octaves = 3
			g.set_color(0, Color(0.86, 0.86, 0.88))
			g.set_color(1, Color(1, 1, 1))
	var t := NoiseTexture2D.new()
	t.width = 256
	t.height = 256
	t.seamless = true
	t.noise = n
	t.color_ramp = g
	_noise_cache[kind] = t
	return t


## Bir mesh'in malzemesini desenli hâle getirir (Props.solid ile kurulan zemin, duvar gibi).
static func set_pattern(mesh_owner: Node, color: Color, pattern: String) -> void:
	var mi: MeshInstance3D = mesh_owner if mesh_owner is MeshInstance3D else mesh_owner.get_child(0)
	mi.material_override = mat(color, 0.0, false, pattern)


## Duvara asılan düz resim (SVG ya da PNG). size: metre cinsinden genişlik.
static func picture(parent: Node3D, path: String, width: float, pos: Vector3, rot_deg := Vector3.ZERO) -> Sprite3D:
	var sp := Sprite3D.new()
	sp.texture = load(path)
	sp.pixel_size = width / float(sp.texture.get_width())
	sp.position = pos
	sp.rotation_degrees = rot_deg
	sp.shaded = true
	sp.double_sided = false
	sp.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	parent.add_child(sp)
	return sp


static func _place(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color, rot_deg := Vector3.ZERO, emission := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	# Çok küçük parçalarda (gözlük, tuş) dış hat şekli boğar: kapatılır.
	var small := mesh.get_aabb().size[mesh.get_aabb().size.max_axis_index()] < 0.1
	mi.material_override = mat(color, emission, color.a < 1.0, "", not small)
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
