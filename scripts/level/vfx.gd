class_name Vfx
## Çizgi film efektleri: patlama (ateş topu, duman mantarı, moloz, flaş ışığı), toz bulutu, duman halkası.
## Hepsi CPUParticles3D (GL Compatibility'de güvenilir) ve kendini birkaç saniye sonra siler.


static func _mat(color: Color, emission := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.vertex_color_use_as_albedo = true
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if emission > 0.0 else BaseMaterial3D.SHADING_MODE_PER_PIXEL
	if color.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	return m


static func _burst(parent: Node3D, pos: Vector3, amount: int, mesh: Mesh, color_ramp: Gradient, life: float,
		speed: Vector2, spread: float, gravity: Vector3, scale: Vector2, direction := Vector3.UP) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.position = pos
	p.amount = amount
	p.one_shot = true
	p.explosiveness = 0.92
	p.lifetime = life
	p.mesh = mesh
	p.direction = direction
	p.spread = spread
	p.initial_velocity_min = speed.x
	p.initial_velocity_max = speed.y
	p.gravity = gravity
	p.damping_min = 1.5
	p.damping_max = 3.0
	p.scale_amount_min = scale.x
	p.scale_amount_max = scale.y
	p.angular_velocity_min = -180.0
	p.angular_velocity_max = 180.0
	p.color_ramp = color_ramp
	var sc := Curve.new()
	sc.add_point(Vector2(0.0, 0.4))
	sc.add_point(Vector2(0.25, 1.0))
	sc.add_point(Vector2(1.0, 0.7))
	p.scale_amount_curve = sc
	parent.add_child(p)
	p.emitting = true
	p.get_tree().create_timer(life + 0.5, false).timeout.connect(p.queue_free)
	return p


static func _sphere(r: float, mat: Material) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = 8
	m.rings = 4
	m.material = mat
	return m


static func _grad(colors: Array) -> Gradient:
	var g := Gradient.new()
	var offs := PackedFloat32Array()
	var cols := PackedColorArray()
	for i in colors.size():
		offs.append(float(i) / float(maxi(1, colors.size() - 1)))
		cols.append(colors[i])
	g.offsets = offs
	g.colors = cols
	return g


## Büyük çizgi film patlaması. size 1 = top patlaması.
static func explosion(parent: Node3D, pos: Vector3, size := 1.0) -> void:
	sheet(parent, pos + Vector3(0, 1.2 * size, 0), "explosion_big" if size >= 1.0 else "explosion_small", 4, 4, 5.0 * size, 1.1)
	var fire := _sphere(0.6 * size, _mat(Color.WHITE, 1.0))
	# Üç renk kümesi: sarı çekirdek, turuncu, kırmızı kenar
	for pal in [[Color("fff6c0"), Color("ffd040")], [Color("ffb040"), Color("ff7a1a")], [Color("ff6a2a"), Color("d8341a")]]:
		_burst(parent, pos, 10, fire, _grad([pal[0], pal[1], pal[1].darkened(0.5), Color(0.3, 0.12, 0.06, 0.0)]),
			1.1, Vector2(4.0, 9.0) * size, 180.0, Vector3(0, 2.0, 0), Vector2(1.0, 2.4))
	var smoke := _sphere(0.9 * size, _mat(Color(1, 1, 1, 0.92)))
	_burst(parent, pos + Vector3(0, 0.5, 0), 22, smoke, _grad([Color("5a5048"), Color("7a7068"), Color(0.55, 0.52, 0.5, 0.0)]),
		3.2, Vector2(2.0, 5.0) * size, 70.0, Vector3(0, 1.6, 0), Vector2(1.2, 2.8))
	var chunk := BoxMesh.new()
	chunk.size = Vector3(0.25, 0.18, 0.3) * size
	chunk.material = _mat(Color.WHITE)
	_burst(parent, pos, 30, chunk, _grad([Color("6a4a2c"), Color("b8863a"), Color("3a2a1e")]),
		2.2, Vector2(7.0, 15.0) * size, 75.0, Vector3(0, -12.0, 0), Vector2(0.6, 1.4))
	var spark := _sphere(0.07 * size, _mat(Color.WHITE, 1.0))
	_burst(parent, pos, 40, spark, _grad([Color("fff4c0"), Color("ffb040"), Color(1, 0.4, 0.1, 0.0)]),
		1.4, Vector2(8.0, 18.0) * size, 180.0, Vector3(0, -6.0, 0), Vector2(0.8, 1.2))
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, 1.0, 0)
	light.light_color = Color("ffb050")
	light.light_energy = 9.0
	light.omni_range = 26.0 * size
	parent.add_child(light)
	var tw := light.create_tween()
	tw.tween_property(light, "light_energy", 0.0, 1.4)
	tw.tween_callback(light.queue_free)


## Yere düşen gülle ya da insan: toz bulutu.
static func dust(parent: Node3D, pos: Vector3, size := 1.0) -> void:
	var puff := _sphere(0.5 * size, _mat(Color(1, 1, 1, 0.85)))
	_burst(parent, pos, 14, puff, _grad([Color("c8b090"), Color("a89070"), Color(0.6, 0.55, 0.45, 0.0)]),
		1.6, Vector2(1.5, 4.0) * size, 80.0, Vector3(0, 0.6, 0), Vector2(0.8, 1.8))


## Öksürükten çıkan duman halkası: yavaşça yükselir, büyür, kaybolur.
static func smoke_ring(parent: Node3D, pos: Vector3) -> void:
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.07
	tm.outer_radius = 0.13
	tm.rings = 12
	tm.ring_segments = 6
	ring.mesh = tm
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.3, 0.28, 0.26, 0.9)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.material_override = m
	ring.position = pos
	ring.rotation_degrees = Vector3(90, 0, 0)
	parent.add_child(ring)
	var tw := ring.create_tween().set_parallel(true)
	tw.tween_property(ring, "position", pos + Vector3(0, 0.9, 0), 2.2)
	tw.tween_property(ring, "scale", Vector3(3, 3, 3), 2.2)
	tw.tween_property(m, "albedo_color:a", 0.0, 2.2)
	tw.chain().tween_callback(ring.queue_free)


## Karakterin yüzüne is lekesi (Person ve Soldier +Z'ye bakar, kafa ≈1,55 m).
static func soot(person: Node3D, head_y := 1.55, hair := true) -> void:
	var s := Props.ball(person, 0.15, Vector3(0, head_y, 0.13), Color("2a2420"), Vector3(1.0, 0.85, 0.4), 8)
	s.name = "Soot"
	if not hair:
		return
	# Saçlar diken diken: birkaç koyu çubuk
	for i in 5:
		var a := -0.5 + i * 0.25
		Props.cyl(person, 0.015, 0.22, Vector3(sin(a) * 0.1, head_y + 0.24, cos(a) * 0.02), Color("1a1410"), Vector3(0, 0, rad_to_deg(a) * 0.8), 4)


## Kazandan yükselen buhar: sürekli yayar; çağıran queue_free() ile durdurur.
static func steam(parent: Node3D, pos: Vector3) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.position = pos
	p.amount = 14
	p.lifetime = 1.8
	p.mesh = _sphere(0.18, _mat(Color(1, 1, 1, 0.55)))
	p.direction = Vector3.UP
	p.spread = 18.0
	p.initial_velocity_min = 0.6
	p.initial_velocity_max = 1.2
	p.gravity = Vector3(0, 0.3, 0)
	p.scale_amount_min = 0.8
	p.scale_amount_max = 1.8
	p.color_ramp = _grad([Color(1, 1, 1, 0.6), Color(0.95, 0.95, 0.95, 0.0)])
	parent.add_child(p)
	p.emitting = true
	return p


## Patlamış leblebi yağmuru: bej taneler havaya fırlar, yere döküler.
static func popcorn(parent: Node3D, pos: Vector3) -> void:
	sheet(parent, pos + Vector3(0, 0.4, 0), "leblebi_burst", 4, 4, 1.8, 0.9)
	var m := _sphere(0.07, _mat(Color.WHITE))
	_burst(parent, pos, 90, m, _grad([Color("f0e2b8"), Color("d8c090"), Color("c8a868")]),
		3.0, Vector2(4.0, 10.0), 60.0, Vector3(0, -9.8, 0), Vector2(0.8, 1.4))


## Kimi'nin çizgi film sprite sheet'i (assets/art/vfx/): kameraya bakan tek kare dizisi, bir kez oynar ya da döner.
## Dosya yoksa sessizce hiçbir şey yapmaz (parçacık efektleri zaten görünür).
static func sheet(parent: Node3D, pos: Vector3, file: String, cols: int, rows: int, height: float, seconds: float,
		loops := 1) -> Sprite3D:
	var path := "res://assets/art/vfx/" + file + ".png"
	if not ResourceLoader.exists(path):
		return null
	var s := Sprite3D.new()
	s.texture = load(path)
	s.hframes = cols
	s.vframes = rows
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	s.pixel_size = height / float(s.texture.get_height() / rows)
	s.render_priority = 1
	parent.add_child(s)
	s.global_position = pos
	var frames := cols * rows
	var tw := s.create_tween().set_loops(loops)
	tw.tween_property(s, "frame", frames - 1, seconds).from(0)
	s.get_tree().create_timer(seconds * loops + 0.05, false).timeout.connect(s.queue_free)
	return s


## Başın üstünde dönen sersemlik yıldızları (inişten sonra).
static func stars(parent: Node3D, pos: Vector3) -> void:
	sheet(parent, pos, "dizzy_stars", 4, 2, 0.9, 0.6, 4)
