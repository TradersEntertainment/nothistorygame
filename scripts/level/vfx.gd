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


static func _sphere(r: float, mat: Material, seg := 8) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = seg
	m.rings = maxi(4, seg / 2)
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
	# Yüzde birkaç küçük is lekesi (yüzü kapatmaz): yanak, alın, burun ucu. Lekeler ve diken saçlar
	# kafaya yapışır: kafa döndükçe, eğildikçe onunla birlikte oynar.
	var rig = person.get("rig")
	var head: Node3D = rig.head if rig != null and rig.get("head") is Node3D else null
	var made: Array[Node3D] = []
	for sp in [[Vector3(0.1, head_y - 0.05, 0.17), 0.045], [Vector3(-0.07, head_y + 0.1, 0.18), 0.035], [Vector3(-0.12, head_y - 0.08, 0.15), 0.03]]:
		var s := Props.ball(person, sp[1], sp[0], Color("3a302a"), Vector3(1.3, 0.8, 0.25), 6)
		s.name = "Soot"
		made.append(s)
		if not hair:
			break
	if hair:
		# Saçlar diken diken: birkaç koyu çubuk
		for i in 5:
			var a := -0.5 + i * 0.25
			made.append(Props.cyl(person, 0.015, 0.22, Vector3(sin(a) * 0.1, head_y + 0.24, cos(a) * 0.02), Color("1a1410"), Vector3(0, 0, rad_to_deg(a) * 0.8), 4))
	if head == null:
		return
	# Kafa şu an dönmüş/eğilmiş olabilir: lekeleri dinlenme duruşundaki yüze göre yerleştirip kafaya bağla
	var rest := head.transform
	head.rotation = Vector3.ZERO
	for n in made:
		n.reparent(head, true)
	head.transform = rest


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


## Tüten yıkıntı (kalıcı): yavaş yükselen gri duman sütunu ve arada kıvılcım. Gedikler, yanık kalıntılar için.
static func smolder(parent: Node3D, pos: Vector3, size := 1.0, embers := true) -> Node3D:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	var sm := CPUParticles3D.new()
	sm.amount = int(18 * size)
	sm.lifetime = 7.0
	sm.preprocess = 7.0
	sm.mesh = _sphere(0.5 * size, _mat(Color(1, 1, 1, 0.5)))
	sm.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	sm.emission_sphere_radius = 1.2 * size
	sm.direction = Vector3(0.25, 1, 0)
	sm.spread = 14.0
	sm.initial_velocity_min = 0.5
	sm.initial_velocity_max = 1.1
	sm.gravity = Vector3(0.12, 0.15, 0)
	sm.scale_amount_min = 1.0
	sm.scale_amount_max = 2.6
	var sc := Curve.new()
	sc.add_point(Vector2(0.0, 0.5))
	sc.add_point(Vector2(1.0, 1.6))
	sm.scale_amount_curve = sc
	sm.color_ramp = _grad([Color(0.32, 0.3, 0.28, 0.0), Color(0.36, 0.34, 0.32, 0.45), Color(0.55, 0.53, 0.5, 0.0)])
	root.add_child(sm)
	sm.emitting = true
	if embers:
		var em := CPUParticles3D.new()
		em.amount = int(10 * size)
		em.lifetime = 1.6
		em.preprocess = 2.0
		em.mesh = _sphere(0.04, _mat(Color("ffb050"), 4.0))
		em.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
		em.emission_sphere_radius = 0.9 * size
		em.direction = Vector3.UP
		em.spread = 30.0
		em.initial_velocity_min = 0.8
		em.initial_velocity_max = 2.0
		em.gravity = Vector3(0.2, 0.4, 0)
		em.color_ramp = _grad([Color(1.0, 0.75, 0.3, 1.0), Color(1.0, 0.4, 0.1, 0.0)])
		root.add_child(em)
		em.emitting = true
		var l := OmniLight3D.new()
		l.light_color = Color("ff8a3a")
		l.light_energy = 0.9 * size
		l.omni_range = 4.0 * size
		l.position = Vector3(0, 0.3, 0)
		root.add_child(l)
	return root


## Kalıcı ateş (yakılana dek sürer): katmanlı alev dilleri (sarı çekirdek, turuncu, kırmızı uç), sıçrayan közler,
## tavana yayılan is dumanı (smoke_dir yönünde sürüklenir) ve titreyen ışık. size ile büyütülür (tween'le yanar).
## Dönen düğümün "light" meta'sı ışıktır.
static func fire(parent: Node3D, pos: Vector3, size := 1.0, smoke_dir := Vector3.ZERO) -> Node3D:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	var tongue := CylinderMesh.new()
	tongue.top_radius = 0.02
	tongue.bottom_radius = 0.22
	tongue.height = 0.7
	tongue.radial_segments = 5
	tongue.rings = 1
	tongue.material = _mat(Color.WHITE, 1.0)
	for layer in [[Color("fff2b0"), Color("ffc040"), 0.45, 26], [Color("ffb040"), Color("ff6a1a"), 0.75, 30], [Color("ff5a1a"), Color("a8281a"), 1.05, 22]]:
		var f := CPUParticles3D.new()
		f.amount = int(layer[3])
		f.lifetime = layer[2]
		f.preprocess = 1.0
		f.mesh = tongue
		f.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
		f.emission_sphere_radius = 0.55 * size
		f.direction = Vector3.UP
		f.spread = 12.0
		f.initial_velocity_min = 1.2 * size
		f.initial_velocity_max = 2.4 * size
		f.gravity = Vector3(0, 1.5, 0)
		f.scale_amount_min = 0.8 * size
		f.scale_amount_max = 1.8 * size
		var sc := Curve.new()
		sc.add_point(Vector2(0.0, 0.6))
		sc.add_point(Vector2(0.3, 1.0))
		sc.add_point(Vector2(1.0, 0.1))
		f.scale_amount_curve = sc
		f.color_ramp = _grad([layer[0], layer[1], Color(layer[1].r, layer[1].g, layer[1].b, 0.0)])
		root.add_child(f)
		f.emitting = true
	var em := CPUParticles3D.new()
	em.amount = int(30 * size)
	em.lifetime = 1.8
	em.preprocess = 1.0
	em.mesh = _sphere(0.035, _mat(Color("ffc060"), 4.0))
	em.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	em.emission_sphere_radius = 0.6 * size
	em.direction = Vector3.UP
	em.spread = 45.0
	em.initial_velocity_min = 1.5
	em.initial_velocity_max = 4.0
	em.gravity = Vector3(0, -1.5, 0) + smoke_dir * 0.5
	em.color_ramp = _grad([Color(1.0, 0.85, 0.4, 1.0), Color(1.0, 0.45, 0.1, 1.0), Color(0.6, 0.2, 0.05, 0.0)])
	root.add_child(em)
	em.emitting = true
	var sm := CPUParticles3D.new()
	sm.amount = int(26 * size)
	sm.lifetime = 4.5
	sm.preprocess = 2.0
	sm.mesh = _sphere(0.5, _mat(Color(1, 1, 1, 0.6)))
	sm.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	sm.emission_sphere_radius = 0.5 * size
	sm.position = Vector3(0, 1.0 * size, 0)
	sm.direction = (Vector3.UP + smoke_dir).normalized()
	sm.spread = 20.0
	sm.initial_velocity_min = 0.8
	sm.initial_velocity_max = 1.6
	sm.gravity = Vector3(0, 0.3, 0) + smoke_dir * 0.8
	sm.damping_min = 0.3
	sm.damping_max = 0.6
	sm.scale_amount_min = 1.0 * size
	sm.scale_amount_max = 2.4 * size
	var ssc := Curve.new()
	ssc.add_point(Vector2(0.0, 0.4))
	ssc.add_point(Vector2(1.0, 2.2))
	sm.scale_amount_curve = ssc
	sm.color_ramp = _grad([Color(0.18, 0.15, 0.13, 0.0), Color(0.16, 0.14, 0.12, 0.75), Color(0.3, 0.28, 0.26, 0.0)])
	root.add_child(sm)
	sm.emitting = true
	var l := OmniLight3D.new()
	l.light_color = Color("ff8a3a")
	l.light_energy = 4.0 * size
	l.omni_range = 9.0 * size
	l.shadow_enabled = false
	l.position = Vector3(0, 0.8 * size, 0)
	root.add_child(l)
	root.set_meta("light", l)
	# Titreyen ışık
	var tw := l.create_tween().set_loops()
	for k in 6:
		tw.tween_property(l, "light_energy", (3.0 + randf() * 2.2) * size, 0.07 + randf() * 0.08)
	return root


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


## Donan kare için patlama heykeli (Bölüm 0 ve fragmanın soğuk açılışı): parçacıklar donduğunda henüz küçük ve
## dağınık oluyordu. Bu, tepe anını elle kurar: katmanlı ateş topu (beyaz çekirdek → sarı → turuncu → kızıl),
## üstünde is taçlı mantar, yerde toz halkası ve şok dalgası, ışınlar boyunca havada asılı taş/tahta parçaları ve
## kıvılcım çizgileri, yerde kararmış iz. `grow` süresinde küçükten tam boya açılır (donmadan hemen önce).
static func frozen_blast(parent: Node3D, pos: Vector3, size := 1.0, grow := 0.14, face := Vector3.ZERO) -> Node3D:
	var root := Node3D.new()
	parent.add_child(root)
	root.global_position = pos
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var hot := func(c: Color) -> StandardMaterial3D:
		var m := StandardMaterial3D.new()
		m.albedo_color = c
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		return m
	var solid := func(c: Color) -> StandardMaterial3D:
		var m := StandardMaterial3D.new()
		m.albedo_color = c
		m.roughness = 1.0
		return m
	var ball := func(r: float, p: Vector3, mat: Material, sq: Vector3) -> void:
		var mi := MeshInstance3D.new()
		mi.mesh = _sphere(r, mat)
		(mi.mesh as SphereMesh).radial_segments = 14
		(mi.mesh as SphereMesh).rings = 8
		mi.position = p
		mi.scale = sq
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(mi)
	var s := size
	# İs tacı: ateşin üstünde ve çevresinde koyu, kabarık duman (arkada kalır)
	for k in 9:
		var a := rng.randf() * TAU
		var h := rng.randf_range(3.0, 4.3) * s
		var rr := rng.randf_range(0.5, 1.5) * s
		ball.call(rng.randf_range(0.7, 1.05) * s, Vector3(cos(a) * rr, h, sin(a) * rr),
			solid.call(Color("4a423a").lerp(Color("7a6e64"), rng.randf())), Vector3.ONE)
	# Ateş topu: dıştan içe kızıl, turuncu, sarı, beyaz çekirdek; hafif yukarı uzamış, kabarcıklı kenar
	var layers := [[Color("ff4a1a"), 2.1, 14], [Color("ff7a1a"), 1.7, 12], [Color("ffb440"), 1.3, 9], [Color("ffe890"), 0.9, 6], [Color("fffbe8"), 0.5, 3]]
	for li in layers.size():
		var col: Color = layers[li][0]
		var rad: float = layers[li][1] * s
		var n: int = layers[li][2]
		var mat: StandardMaterial3D = hot.call(col)
		# İç katmanlar seyirciye doğru öne çıkar: sıcak çekirdek kızıl kabuğun içinde kaybolmasın
		var c0 := Vector3(0, 1.7 * s + li * 0.1 * s, 0) + face * (li * 0.42 * s)
		ball.call(rad * 0.85, c0, mat, Vector3(1.0, 1.15, 1.0))
		for k in n:
			var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.3, 1.0), rng.randf_range(-1, 1)).normalized()
			ball.call(rad * rng.randf_range(0.35, 0.6), c0 + d * rad * 0.62, mat, Vector3.ONE)
	# Yerde toz eteği: basık, açık kahve bulutlar halka halinde
	for k in 18:
		var a := k * TAU / 18.0 + rng.randf() * 0.2
		var rr := rng.randf_range(2.2, 3.4) * s
		ball.call(rng.randf_range(0.55, 0.9) * s, Vector3(cos(a) * rr, 0.35 * s, sin(a) * rr),
			solid.call(Color("8a7458").lerp(Color("b8a07c"), rng.randf())), Vector3(1.4, 0.6, 1.4))
	# Şok dalgası: yerde parlak, ince halka
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 3.7 * s
	tm.outer_radius = 4.0 * s
	tm.rings = 48
	tm.ring_segments = 6
	var rm := StandardMaterial3D.new()
	rm.albedo_color = Color(1.0, 0.85, 0.6, 0.55)
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tm.material = rm
	ring.mesh = tm
	ring.position = Vector3(0, 0.25, 0)
	ring.scale = Vector3(1, 0.25, 1)
	root.add_child(ring)
	# Kararmış yer
	var scorch := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 2.4 * s
	cm.bottom_radius = 2.4 * s
	cm.height = 0.02
	cm.material = solid.call(Color("1e1814"))
	scorch.mesh = cm
	scorch.position = Vector3(0, 0.03, 0)
	root.add_child(scorch)
	# Havada asılı parçalar ve arkalarında hareket izi; kıvılcım çizgileri
	var stone: StandardMaterial3D = solid.call(Color("7a6a58"))
	var wood: StandardMaterial3D = solid.call(Color("6a4a2c"))
	var trail := StandardMaterial3D.new()
	trail.albedo_color = Color(0.45, 0.4, 0.35, 0.35)
	trail.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trail.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var spark: StandardMaterial3D = hot.call(Color("ffd060"))
	var add_box := func(sz: Vector3, p: Vector3, dir: Vector3, mat: Material) -> void:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = sz
		bm.material = mat
		mi.mesh = bm
		root.add_child(mi)
		var up := Vector3.UP if absf(dir.dot(Vector3.UP)) < 0.95 else Vector3.RIGHT
		mi.transform = Transform3D(Basis.looking_at(dir, up), p)
	for k in 30:
		var dir := Vector3(rng.randf_range(-1, 1), rng.randf_range(0.15, 1.1), rng.randf_range(-1, 1)).normalized()
		var dist := rng.randf_range(2.0, 5.5) * s
		var p := Vector3(0, 0.8 * s, 0) + dir * dist
		var sz := Vector3(rng.randf_range(0.12, 0.34), rng.randf_range(0.1, 0.24), rng.randf_range(0.14, 0.4)) * s
		var mi_dir := Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
		add_box.call(sz, p, mi_dir, wood if k % 3 == 0 else stone)
		var tl := rng.randf_range(0.8, 1.6) * s
		add_box.call(Vector3(sz.x * 0.6, sz.y * 0.6, tl), p - dir * tl * 0.5, dir, trail)
	for k in 46:
		var dir := Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.1, 1.2), rng.randf_range(-1, 1)).normalized()
		var dist := rng.randf_range(1.8, 6.5) * s
		var ln := rng.randf_range(0.3, 0.9) * s
		add_box.call(Vector3(0.035, 0.035, ln) * s, Vector3(0, 1.0 * s, 0) + dir * dist, dir, spark)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 1.6 * s, 0)
	light.light_color = Color("ffa850")
	light.light_energy = 6.0
	light.omni_range = 18.0 * s
	root.add_child(light)
	if grow > 0.0:
		root.scale = Vector3.ONE * 0.35
		root.create_tween().tween_property(root, "scale", Vector3.ONE, grow).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	return root


## Şahi topunun ateşi (gece): namludan kör edici sarı-turuncu parlama, ufku ve surları/yüzleri aydınlatan güçlü
## ışık (light_at: ikinci ışık, sura yakın), ardından ovayı kaplayan, yere yayılan yoğun kara-gri barut bulutu ve
## yükselen duman sütunu. Duman küreleri pürüzsüz (köşeli değil) ve yavaş dağılır.
static func gun_blast(parent: Node3D, pos: Vector3, size := 1.0, light_at := Vector3.INF) -> void:
	var s := size
	# Namlu parlaması: beyaz-sarı çekirdek, turuncu hale; bir an büyür ve söner
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(1.0, 0.92, 0.6, 1.0)
	fm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var flash := MeshInstance3D.new()
	flash.mesh = _sphere(1.2 * s, fm, 20)
	flash.position = pos
	flash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(flash)
	var hm := StandardMaterial3D.new()
	hm.albedo_color = Color(1.0, 0.55, 0.15, 0.55)
	hm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var halo := MeshInstance3D.new()
	halo.mesh = _sphere(2.0 * s, hm, 20)
	halo.position = pos + Vector3(0, 0.5 * s, 0)
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(halo)
	var tw := flash.create_tween().set_parallel(true)
	tw.tween_property(flash, "scale", Vector3.ONE * 1.8, 0.12)
	tw.tween_property(fm, "albedo_color:a", 0.0, 0.35).set_delay(0.08)
	tw.tween_property(halo, "scale", Vector3.ONE * 2.2, 0.3)
	tw.tween_property(hm, "albedo_color:a", 0.0, 0.28)
	tw.chain().tween_callback(flash.queue_free)
	tw.chain().tween_callback(halo.queue_free)
	for lp: Vector3 in [pos + Vector3(0, 3.0 * s, 0), light_at]:
		if lp == Vector3.INF:
			continue
		var l := OmniLight3D.new()
		l.position = lp
		l.light_color = Color("ffc070")
		l.light_energy = 22.0
		l.omni_range = 90.0 * s
		l.omni_attenuation = 0.6
		parent.add_child(l)
		var lt := l.create_tween()
		lt.tween_property(l, "light_energy", 0.0, 0.9).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		lt.tween_callback(l.queue_free)
	# Yere yayılan kara barut bulutu (ovayı kaplar) ve yükselen sütun
	# Işıktan etkilenmeyen koyu duman: gece gökyüzüne karşı kara bir bulut (ışıkta beyazlaşmasın)
	var sm := _mat(Color(1, 1, 1, 0.92))
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var smoke := _sphere(2.6 * s, sm, 18)
	var low := _burst(parent, pos + Vector3(0, 1.0 * s, 0), 36, smoke, _grad([Color("5a4030"), Color("1e1c1a"), Color("2a2826"), Color(0.2, 0.19, 0.18, 0.0)]),
		9.0, Vector2(4.0, 11.0) * s, 80.0, Vector3(0, 0.25, 0), Vector2(1.0, 2.2), Vector3(0, 0.15, -1).normalized())
	low.explosiveness = 0.75
	low.damping_min = 1.2
	low.damping_max = 2.0
	var col := _burst(parent, pos + Vector3(0, 3.0 * s, 0), 22, smoke, _grad([Color("6a4a30"), Color("24211e"), Color(0.22, 0.21, 0.2, 0.0)]),
		10.0, Vector2(2.0, 5.0) * s, 25.0, Vector3(0, 0.6, 0), Vector2(1.2, 2.6))
	col.explosiveness = 0.5
	# Kıvılcımlar
	var spark := _sphere(0.1 * s, _mat(Color.WHITE, 1.0))
	_burst(parent, pos, 40, spark, _grad([Color("fff4c0"), Color("ffb040"), Color(1, 0.4, 0.1, 0.0)]),
		1.2, Vector2(12.0, 26.0) * s, 35.0, Vector3(0, -6.0, 0), Vector2(0.8, 1.4), Vector3(0, 0.2, -1).normalized())
