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
		m.albedo_texture = _pattern_tex(pattern) if pattern in PAINTED else _noise(pattern)
		m.uv1_triplanar = true
		m.uv1_world_triplanar = true
		match pattern:
			"wood":
				m.uv1_scale = Vector3(0.35, 2.5, 0.35)
			"concrete":
				m.uv1_scale = Vector3(0.3, 0.3, 0.3)
			"cobble":
				m.uv1_scale = Vector3(0.4, 0.4, 0.4)
			"ashlar":
				m.uv1_scale = Vector3(0.55, 0.55, 0.55)
			"tiles":
				m.uv1_scale = Vector3(0.9, 0.9, 0.9)
			"plaster":
				m.uv1_scale = Vector3(0.45, 0.45, 0.45)
			"marble":
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


## Elle "boyanan" (kodla çizilen) dokular: renkleri kendi içindedir, malzeme rengi onları hafifçe boyar.
##   cobble  Arnavut kaldırımı (Voronoi taşlar, harç çizgileri)
##   ashlar  Bizans duvarı: kesme taş sıraları ve kırmızı tuğla bantlar (opus mixtum)
##   tiles   Kiremit sıraları
##   plaster Eski sıva: lekeler, dökülmüş yerlerden görünen tuğla
##   marble  Damarlı mermer
const PAINTED := ["cobble", "ashlar", "tiles", "plaster", "marble"]


static func _pattern_tex(kind: String) -> ImageTexture:
	if _noise_cache.has(kind):
		return _noise_cache[kind]
	var n := 256
	var img := Image.create(n, n, false, Image.FORMAT_RGB8)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(kind)
	var fn := FastNoiseLite.new()
	fn.seed = 7
	fn.frequency = 0.04
	match kind:
		"cobble":
			var g := 8
			var cell := float(n) / g
			var seeds: Array = []
			var tints: Array = []
			for j in g:
				for i in g:
					seeds.append(Vector2((i + rng.randf_range(0.2, 0.8)) * cell, (j + rng.randf_range(0.2, 0.8)) * cell))
					tints.append(rng.randf_range(0.78, 1.0))
			for y in n:
				for x in n:
					var p := Vector2(x, y)
					var d1 := 1e9
					var d2 := 1e9
					var best := 0
					var cx := int(x / cell)
					var cy := int(y / cell)
					for oy in range(-1, 2):
						for ox in range(-1, 2):
							var ix := posmod(cx + ox, g)
							var iy := posmod(cy + oy, g)
							var sp: Vector2 = seeds[iy * g + ix] + Vector2((cx + ox - ix) * cell, (cy + oy - iy) * cell)
							var d := p.distance_to(sp)
							if d < d1:
								d2 = d1
								d1 = d
								best = iy * g + ix
							elif d < d2:
								d2 = d
					var t: float = tints[best]
					var shade := 1.0 - clampf(d1 / cell, 0.0, 1.0) * 0.18
					var c := Color(0.74, 0.70, 0.62) * t * shade
					if d2 - d1 < 2.6:
						c = Color(0.36, 0.33, 0.28)
					c = c * (0.94 + fn.get_noise_2d(x * 3.0, y * 3.0) * 0.08)
					img.set_pixel(x, y, c)
		"ashlar":
			# Üst yarı: dört sıra kesme taş; alt yarı: sekiz sıra tuğla (opus mixtum)
			for y in n:
				var stone := y < 128
				var row := int(y / 32) if stone else int((y - 128) / 16)
				var ry := y % 32 if stone else (y - 128) % 16
				var off := (row * 37) % 71 if stone else (row % 2) * 24
				for x in n:
					var bw := 64 if stone else 48
					var bx := posmod(x + off, bw)
					var bid := int(posmod(x + off, n) / bw) + row * 7
					rng.seed = bid * 131 + (0 if stone else 999)
					var tint := rng.randf_range(0.85, 1.0)
					var c: Color
					if stone:
						c = Color(0.84, 0.78, 0.66) * tint
					else:
						c = Color(0.66, 0.34, 0.24) * tint
					var mortar := ry < (3 if stone else 2) or bx < (3 if stone else 2)
					if mortar:
						c = Color(0.80, 0.76, 0.68)
					c = c * (0.93 + fn.get_noise_2d(x * 2.0, y * 2.0) * 0.1)
					img.set_pixel(x, y, c)
		"tiles":
			for y in n:
				var row := int(y / 32)
				var ry := float(y % 32) / 32.0
				for x in n:
					var off := (row % 2) * 16
					var tx := float(posmod(x + off, 32)) / 32.0
					rng.seed = row * 17 + int(posmod(x + off, n) / 32)
					var tint := rng.randf_range(0.82, 1.0)
					var curve := sin(tx * PI)
					var c := Color(0.72, 0.36, 0.22) * tint * (0.7 + 0.3 * curve)
					if ry > 0.85:
						c = c * 0.55
					img.set_pixel(x, y, c)
		"plaster":
			for y in n:
				for x in n:
					var v := fn.get_noise_2d(x, y)
					var c := Color(1, 1, 1) * (0.9 + v * 0.1)
					var chip := fn.get_noise_2d(x * 1.4 + 400.0, y * 1.4)
					if chip > 0.55:
						# Dökülen sıvanın altından tuğla
						var brick := posmod(x + (int(y / 10) % 2) * 12, 24) < 2 or y % 10 < 2
						c = Color(0.78, 0.74, 0.66) if brick else Color(0.74, 0.44, 0.34)
					elif chip > 0.5:
						c = c * 0.86
					img.set_pixel(x, y, c)
		"marble":
			for y in n:
				for x in n:
					var v := absf(sin((x + fn.get_noise_2d(x, y) * 60.0) * 0.05))
					var c := Color(0.96, 0.94, 0.9) * (0.88 + 0.12 * v)
					if v < 0.06:
						c = Color(0.72, 0.72, 0.74)
					img.set_pixel(x, y, c)
	img.generate_mipmaps()
	var tex := ImageTexture.create_from_image(img)
	_noise_cache[kind] = tex
	return tex


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


## Bir düğümün altındaki bütün parçalardan dış hatları kaldırır (kameraya çok yakın
## nesnelerde dış hat devasa siyah lekelere dönüşür: birinci şahıs el gibi).
static func strip_outlines(node: Node) -> void:
	for c in node.get_children():
		if c is MeshInstance3D:
			var m := (c as MeshInstance3D).material_override as StandardMaterial3D
			if m and m.next_pass:
				var e := m.emission_energy_multiplier if m.emission_enabled else 0.0
				(c as MeshInstance3D).material_override = mat(m.albedo_color, e, false, "", false)
		strip_outlines(c)


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


static func prism(parent: Node3D, size: Vector3, pos: Vector3, color: Color, rot_deg := Vector3.ZERO) -> MeshInstance3D:
	var m := PrismMesh.new()
	m.size = size
	return _place(parent, m, pos, color, rot_deg)


static func ring(parent: Node3D, inner: float, outer: float, pos: Vector3, color: Color, rot_deg := Vector3.ZERO, emission := 0.0) -> MeshInstance3D:
	var m := TorusMesh.new()
	m.inner_radius = inner
	m.outer_radius = outer
	m.rings = 16
	m.ring_segments = 6
	return _place(parent, m, pos, color, rot_deg, emission)


## max_width > 0 ise yazı, ölçülen genişliği bu değeri (metre) aşmayacak şekilde küçültülür.
static func label(parent: Node3D, text: String, pos: Vector3, size := 48, color := Color.WHITE, rot_deg := Vector3.ZERO, max_width := 0.0) -> Label3D:
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
	if max_width > 0.0:
		var w := text_width(text, size, l.pixel_size)
		if w > max_width:
			l.pixel_size *= max_width / w
	return l


## Label3D yazısının dünya birimindeki genişliği (varsayılan font ile ölçülür).
static func text_width(text: String, size: int, pixel_size: float) -> float:
	var font := ThemeDB.fallback_font
	var widest := 0.0
	for line in text.split("\n"):
		widest = maxf(widest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x)
	return widest * pixel_size


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


## Kimi'nin .glb dekor modeli (assets/models/NAME.glb): malzemeleri oyunun toon + kontur üslubuna çevrilir.
## Dosya yoksa null döner; çağıran yine de çalışır.
static func model(parent: Node3D, name: String, pos: Vector3, rot_y := 0.0, scale := 1.0) -> Node3D:
	var path := "res://assets/models/%s.glb" % name
	if not ResourceLoader.exists(path):
		return null
	var ps: PackedScene = load(path)
	var inst: Node3D = ps.instantiate()
	inst.position = pos
	inst.rotation_degrees.y = rot_y
	inst.scale = Vector3.ONE * scale
	parent.add_child(inst)
	for n in inst.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var src := mi.get_active_material(i) as BaseMaterial3D
			if src == null:
				mi.set_surface_override_material(i, mat(Color("8a8a8a")))
				continue
			var m := src.duplicate() as BaseMaterial3D
			m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
			m.specular_mode = BaseMaterial3D.SPECULAR_TOON
			m.roughness = 0.9
			m.metallic = 0.0
			if outlines and not m.emission_enabled:
				m.next_pass = _outline_mat()
			mi.set_surface_override_material(i, m)
	return inst
