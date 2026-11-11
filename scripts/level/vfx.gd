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


static func _burst(parent: Node, pos: Vector3, amount: int, mesh: Mesh, color_ramp: Gradient, life: float,
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
	# Ateş topu: yumuşak, parlayan haleler (eskiden köşeli düz renkli küreler)
	var fire := Flame.particle_mesh("glow", 2.2)
	for pal in [[Color("fff6c0"), Color("ffd040")], [Color("ffb040"), Color("ff7a1a")], [Color("ff6a2a"), Color("d8341a")]]:
		_burst(parent, pos, 10, fire, _grad([pal[0], pal[1], pal[1].darkened(0.5), Color(0.3, 0.12, 0.06, 0.0)]),
			1.1, Vector2(4.0, 9.0) * size, 180.0, Vector3(0, 2.0, 0), Vector2(2.2, 4.6) * size)
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


## Gülle surun taşına çarpar: yontulmuş taş parçaları ve harç tozu fışkırır, kireç bulutu yükselir.
static func masonry(parent: Node3D, pos: Vector3, size := 1.0, out := Vector3.BACK) -> void:
	var stone := BoxMesh.new()
	stone.size = Vector3(0.45, 0.32, 0.4) * size
	stone.material = _mat(Color.WHITE)
	var b := _burst(parent, pos, 26, stone, _grad([Color("b8ac98"), Color("8a8070"), Color("6a6054")]),
		2.6, Vector2(6.0, 14.0) * size, 55.0, Vector3(0, -14.0, 0), Vector2(0.6, 1.6), out.normalized())
	b.explosiveness = 1.0
	var grit := BoxMesh.new()
	grit.size = Vector3(0.12, 0.1, 0.12) * size
	grit.material = _mat(Color.WHITE)
	_burst(parent, pos, 40, grit, _grad([Color("c8bca8"), Color("9a9080")]),
		1.8, Vector2(8.0, 18.0) * size, 80.0, Vector3(0, -12.0, 0), Vector2(0.6, 1.2), out.normalized())
	var puff := _sphere(1.1 * size, _mat(Color(1, 1, 1, 0.85)))
	_burst(parent, pos, 18, puff, _grad([Color("e8e0d0"), Color("c8bca8"), Color(0.75, 0.72, 0.66, 0.0)]),
		4.0, Vector2(1.5, 4.5) * size, 70.0, Vector3(0, 0.8, 0), Vector2(1.2, 3.0), out.normalized())


## Kılıç kılıca: kısa, parlak kıvılcım saçılması (savuşturulan darbe).
static func sparks(parent: Node, pos: Vector3, size := 1.0) -> void:
	if parent == null:
		return
	var s := _sphere(0.025 * size, _mat(Color.WHITE, 1.0), 4)
	_burst(parent, pos, 14, s, _grad([Color("fffbe0"), Color("ffd060"), Color(1.0, 0.5, 0.1, 0.0)]),
		0.35, Vector2(3.0, 7.0) * size, 70.0, Vector3(0, -9.0, 0), Vector2(0.6, 1.2))


## Suya düşen: köpüklü sıçrama sütunu ve halka hâlinde yayılan damlalar.
static func splash(parent: Node, pos: Vector3, size := 1.0) -> void:
	if parent == null:
		return
	var drop := _sphere(0.09 * size, _mat(Color(1, 1, 1, 0.9)), 5)
	_burst(parent, pos, 30, drop, _grad([Color("f4f8ff"), Color("c8dcea"), Color(0.8, 0.88, 0.95, 0.0)]),
		1.2, Vector2(3.0, 7.5) * size, 28.0, Vector3(0, -12.0, 0), Vector2(0.8, 1.6))
	var foam := _sphere(0.4 * size, _mat(Color(1, 1, 1, 0.85)))
	_burst(parent, pos + Vector3(0, 0.1, 0), 12, foam, _grad([Color("ffffff"), Color("dfeaf2"), Color(0.85, 0.9, 0.95, 0.0)]),
		1.6, Vector2(0.8, 2.2) * size, 85.0, Vector3(0, -0.5, 0), Vector2(1.0, 2.0))


## Mazgaldan atlayan, merdivenden çıkan: kenardan dökülen birkaç küçük taş ve harç tozu (gülle izi değil, hafif).
static func ledge(parent: Node, pos: Vector3, out := Vector3.BACK, size := 1.0) -> void:
	if parent == null:
		return
	var grit := BoxMesh.new()
	grit.size = Vector3(0.09, 0.07, 0.09) * size
	grit.material = _mat(Color.WHITE)
	_burst(parent, pos, 16, grit, _grad([Color("c8bca8"), Color("9a9080")]),
		1.6, Vector2(1.5, 4.0) * size, 50.0, Vector3(0, -12.0, 0), Vector2(0.7, 1.3), (out.normalized() + Vector3(0, 0.6, 0)).normalized())
	var puff := _sphere(0.35 * size, _mat(Color(1, 1, 1, 0.8)))
	_burst(parent, pos, 8, puff, _grad([Color("e0d6c4"), Color("c0b49e"), Color(0.75, 0.72, 0.66, 0.0)]),
		1.8, Vector2(0.6, 1.8) * size, 70.0, Vector3(0, 0.4, 0), Vector2(0.9, 1.8))


## Yere düşen gülle ya da insan: toz bulutu. parent düz bir Node da olabilir (sahne kökü; konum o zaman dünyada).
static func dust(parent: Node, pos: Vector3, size := 1.0) -> void:
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
## Lekeler kafanın yüzeyine yapışık, yassı ve yarı saydam isli izlerdir (yüzden taşan top değil); kafaya bağlanır,
## kafa döndükçe onunla oynar. hair: saçlar da diken diken olur (patlamadan sonra).
static func soot(person: Node3D, head_y := 1.55, hair := true) -> void:
	var rig = person.get("rig")
	var head: Node3D = rig.head if rig != null and rig.get("head") is Node3D else null
	var hs := Vector3(1.0, 1.06, 0.98)
	var fs = person.get("face_spec")
	if fs is Dictionary and (fs as Dictionary).has("head"):
		hs = fs["head"]
	var rad := hs * 0.2
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.09, 0.08, 0.07, 0.78)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Yanak, alın, burun yanı, çene: yüz ön yarısında birkaç leke (gözleri kapatmaz)
	var spots := [[Vector2(-0.12, -0.04), 0.06], [Vector2(0.06, 0.12), 0.05], [Vector2(0.13, -0.02), 0.045],
		[Vector2(-0.04, 0.14), 0.035], [Vector2(-0.02, -0.14), 0.04]]
	var made: Array[Node3D] = []
	for sp in spots:
		var p2: Vector2 = sp[0]
		var r: float = sp[1]
		var q := 1.0 - pow(p2.x / rad.x, 2) - pow(p2.y / rad.y, 2)
		if q <= 0.05:
			continue
		var loc := Vector3(p2.x, p2.y, rad.z * sqrt(q))
		var n := Vector3(loc.x / (rad.x * rad.x), loc.y / (rad.y * rad.y), loc.z / (rad.z * rad.z)).normalized()
		var mi := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = r
		sm.height = r * 2.0
		sm.radial_segments = 10
		sm.rings = 5
		sm.material = m
		mi.mesh = sm
		mi.name = "Soot"
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var up := Vector3.UP if absf(n.dot(Vector3.UP)) < 0.95 else Vector3.RIGHT
		var bx := up.cross(n).normalized()
		var by := n.cross(bx)
		mi.transform = Transform3D(Basis(bx * 1.35, by * 0.85, n * 0.14), loc + n * 0.004)
		made.append(mi)
	if hair:
		for i in 5:
			var a := -0.5 + i * 0.25
			var c := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.015
			cm.bottom_radius = 0.015
			cm.height = 0.22
			cm.radial_segments = 4
			var hm := StandardMaterial3D.new()
			hm.albedo_color = Color("1a1410")
			cm.material = hm
			c.mesh = cm
			c.transform = Transform3D(Basis(Vector3.BACK, a * 0.8), Vector3(sin(a) * 0.1, 0.24 * hs.y / 1.06, cos(a) * 0.02))
			made.append(c)
	var host: Node3D = head
	var off := Vector3.ZERO
	if host == null:
		host = person
		off = Vector3(0, head_y, 0)
	# Kafa şu an dönmüş/eğilmiş olabilir: yerel koordinatla eklenir, kafayla birlikte döner
	for n in made:
		n.position += off
		host.add_child(n)


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
	# Alev dilleri: kameraya dönen, titreyen yumuşak alev (Flame; eskiden turuncu koniler)
	var tongue := Flame.particle_mesh("flame", 1.4)
	Flame.add(root, Vector3.ZERO, 0.9 * size, 1.5 * size, 4.0 * size)
	for layer in [[Color("fff2b0"), Color("ffc040"), 0.45, 14], [Color("ffb040"), Color("ff6a1a"), 0.75, 16], [Color("ff5a1a"), Color("a8281a"), 1.05, 12]]:
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
		f.scale_amount_min = 0.5 * size
		f.scale_amount_max = 1.1 * size
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
static func gun_blast(parent: Node3D, pos: Vector3, size := 1.0, light_at := Vector3.INF, day := false) -> void:
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
	var smoke := _sphere((1.9 if day else 2.6) * s, sm, 18)
	# Gündüz kara barut dumanı kirli beyaz-gri (güneşte koyu kahverengi küreler gibi duruyordu); gece kara bulut
	var low_g := _grad([Color("f2ede2"), Color("cfc8bc"), Color("aaa49a"), Color(0.62, 0.6, 0.56, 0.0)]) if day else \
		_grad([Color("5a4030"), Color("1e1c1a"), Color("2a2826"), Color(0.2, 0.19, 0.18, 0.0)])
	var col_g := _grad([Color("e8e2d6"), Color("b8b2a8"), Color(0.6, 0.58, 0.55, 0.0)]) if day else \
		_grad([Color("6a4a30"), Color("24211e"), Color(0.22, 0.21, 0.2, 0.0)])
	var low := _burst(parent, pos + Vector3(0, 1.0 * s, 0), 28 if day else 36, smoke, low_g,
		9.0, Vector2(3.0, 7.0) * s, 80.0, Vector3(0, 0.25, 0), Vector2(1.0, 2.2), Vector3(0, 0.15, -1).normalized())
	low.explosiveness = 0.75
	low.damping_min = 2.5
	low.damping_max = 4.0
	var col := _burst(parent, pos + Vector3(0, 3.0 * s, 0), 16 if day else 22, smoke, col_g,
		7.0 if day else 10.0, Vector2(2.0, 5.0) * s, 25.0, Vector3(0, 0.6, 0), Vector2(1.2, 2.6))
	col.explosiveness = 0.5
	# Kıvılcımlar
	var spark := _sphere(0.1 * s, _mat(Color.WHITE, 1.0))
	_burst(parent, pos, 40, spark, _grad([Color("fff4c0"), Color("ffb040"), Color(1, 0.4, 0.1, 0.0)]),
		1.2, Vector2(12.0, 26.0) * s, 35.0, Vector3(0, -6.0, 0), Vector2(0.8, 1.4), Vector3(0, 0.2, -1).normalized())


# ---------------------------------------------------------------- su, ıslaklık, sualtı, hava (Bölüm 2 tur 2; ortak)

static var _ring_mesh: ArrayMesh
static var _ring_n := 0
static var _drop_mesh: SphereMesh
static var _sway_mat: ShaderMaterial
static var _shaft_mat: ShaderMaterial
static var _foot_mesh: ArrayMesh
static var _dot_tex: GradientTexture2D
static var _bubble_tex: GradientTexture2D
static var _bubble_mat: StandardMaterial3D


## Yumuşak yuvarlak leke dokusu (merkezde dolu, kenara doğru saydamlaşan): zerre, toz, duman, kabarcık billboard'ları.
## Kare billboard'lar artık havada kutucuk gibi görünmez.
static func _soft_dot() -> GradientTexture2D:
	if _dot_tex == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0)])
		_dot_tex = GradientTexture2D.new()
		_dot_tex.gradient = g
		_dot_tex.fill = GradientTexture2D.FILL_RADIAL
		_dot_tex.fill_from = Vector2(0.5, 0.5)
		_dot_tex.fill_to = Vector2(1.0, 0.5)
		_dot_tex.width = 32
		_dot_tex.height = 32
	return _dot_tex


## Billboard parçacık malzemesi: yumuşak yuvarlak doku, köşe (parçacık) rengi, saydam, gölgesiz.
static func _soft_mat(color: Color, additive := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.albedo_texture = _soft_dot()
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.vertex_color_use_as_albedo = true
	m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	if additive:
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	return m


## Sualtı kabarcığı: kenarı parlak, içi saydam yuvarlak halka (billboard); kabarcık sütunu ve dalış.
static func _bubble() -> StandardMaterial3D:
	if _bubble_mat == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.55, 0.8, 0.92, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 0.12), Color(1, 1, 1, 0.2), Color(1, 1, 1, 0.85), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0)])
		_bubble_tex = GradientTexture2D.new()
		_bubble_tex.gradient = g
		_bubble_tex.fill = GradientTexture2D.FILL_RADIAL
		_bubble_tex.fill_from = Vector2(0.5, 0.5)
		_bubble_tex.fill_to = Vector2(1.0, 0.5)
		_bubble_tex.width = 32
		_bubble_tex.height = 32
		_bubble_mat = StandardMaterial3D.new()
		_bubble_mat.albedo_color = Color(0.88, 0.98, 1.0, 0.75)
		_bubble_mat.albedo_texture = _bubble_tex
		_bubble_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_bubble_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_bubble_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		_bubble_mat.vertex_color_use_as_albedo = true
		_bubble_mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	return _bubble_mat


## Yükselen kabarcıklar (dalış, sudan çıkan nefes): küçük, yuvarlak, yarı saydam; yükseldikçe büyür, yüzeye varmadan
## söner. Tek seferlik (seconds boyunca yayar, sonra kendini siler). Örnek: Vfx.bubbles(self, ağız, 1.2, 1.5)
static func bubbles(parent: Node3D, pos: Vector3, seconds := 1.2, rise := 1.5, amount := 22) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(0.05, 0.05)
	q.material = _bubble()
	p.mesh = q
	p.amount = amount
	p.lifetime = clampf(rise / 0.9, 0.6, 4.0)
	p.local_coords = false
	p.direction = Vector3.UP
	p.spread = 14.0
	p.gravity = Vector3(0, 0.5, 0)
	p.initial_velocity_min = 0.35
	p.initial_velocity_max = 0.7
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.25
	p.scale_amount_min = 0.35
	p.scale_amount_max = 1.0
	var sc := Curve.new()
	sc.add_point(Vector2(0.0, 0.45))
	sc.add_point(Vector2(1.0, 1.35))
	p.scale_amount_curve = sc
	p.color_ramp = _grad([Color(1, 1, 1, 0.0), Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.0)])
	p.set_meta("transient", true)
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	var tree := parent.get_tree()
	tree.create_timer(seconds, false).timeout.connect(func():
		if is_instance_valid(p):
			p.emitting = false)
	tree.create_timer(seconds + p.lifetime + 0.2, false).timeout.connect(func():
		if is_instance_valid(p):
			p.queue_free())
	return p


## Küçük, yumuşak, hızla dağılan toz (yuvarlanan kütük, düşen yük, sıçrayan asker): yere yakın, birkaç avuç. Eski
## dust() tuğla kadar iri bej küreler bırakıyordu. size 1: ~30 cm'lik pufçuklar, 0,7 sn'de söner.
static func dust_puff(parent: Node, pos: Vector3, size := 1.0, color := Color(0.78, 0.68, 0.52, 0.5)) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var q := QuadMesh.new()
	q.size = Vector2(0.3, 0.3) * size
	q.material = _soft_mat(color)
	var p := CPUParticles3D.new()
	p.mesh = q
	p.amount = 10
	p.one_shot = true
	p.explosiveness = 0.85
	p.lifetime = 0.75
	p.local_coords = false
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.25 * size
	p.direction = Vector3.UP
	p.spread = 75.0
	p.initial_velocity_min = 0.4 * size
	p.initial_velocity_max = 1.3 * size
	p.damping_min = 2.0
	p.damping_max = 3.5
	p.gravity = Vector3(0, 0.25, 0)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.2
	var sc := Curve.new()
	sc.add_point(Vector2(0.0, 0.5))
	sc.add_point(Vector2(1.0, 1.8))
	p.scale_amount_curve = sc
	p.color_ramp = _grad([Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)])
	p.set_meta("transient", true)
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	p.get_tree().create_timer(1.3, false).timeout.connect(p.queue_free)


## Sürekli toz izi (sürüklenen kızak, kayan gemi, koşan sürü): who'ya bağlı kutudan (yerel extents) küçük, yumuşak toz
## pufçukları kalkar, dünyada kalıp hızla dağılır. emitting ile açılıp kapanır (yalnız hareket ederken açın).
## Örnek: var t := Vfx.dust_trail(gemi, Vector3(0, 0.2, -9), Vector3(3, 0.1, 1)); t.emitting = hız > 0.8
static func dust_trail(who: Node3D, pos: Vector3, extents: Vector3, color := Color(0.8, 0.7, 0.55, 0.42)) -> CPUParticles3D:
	var q := QuadMesh.new()
	q.size = Vector2(0.45, 0.45)
	q.material = _soft_mat(color)
	var p := CPUParticles3D.new()
	p.mesh = q
	p.amount = 26
	p.lifetime = 0.9
	p.local_coords = false
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = extents
	p.direction = Vector3.UP
	p.spread = 60.0
	p.initial_velocity_min = 0.3
	p.initial_velocity_max = 1.1
	p.damping_min = 1.0
	p.damping_max = 2.0
	p.gravity = Vector3(0, 0.3, 0)
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.1
	var sc := Curve.new()
	sc.add_point(Vector2(0.0, 0.4))
	sc.add_point(Vector2(1.0, 1.7))
	p.scale_amount_curve = sc
	p.color_ramp = _grad([Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.8), Color(1, 1, 1, 0.0)])
	p.position = pos
	p.emitting = false
	p.set_meta("transient", true)
	who.add_child(p)
	return p


## Sürekli ince duman (ocak, kor, mangal): dipte küçük, yükseldikçe genişleyen, rüzgârla eğilen ve kaybolan tek sütun
## (yumuşak yuvarlak billboard'lar). Eski smolder'ın havada asılı duran iri gri topları yerine. Döndürür: parçacık düğümü.
## Örnek: Vfx.smoke_wisp(self, ateş + Vector3(0, 0.3, 0), 2.5)
static func smoke_wisp(parent: Node3D, pos: Vector3, height := 2.5, drift := Vector3(0.25, 0, 0.1)) -> CPUParticles3D:
	var q := QuadMesh.new()
	q.size = Vector2(0.32, 0.32)
	q.material = _soft_mat(Color(0.82, 0.8, 0.78, 0.5))
	var p := CPUParticles3D.new()
	p.mesh = q
	p.amount = 18
	p.lifetime = clampf(height / 0.75, 1.5, 6.0)
	p.preprocess = p.lifetime
	p.local_coords = false
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.06
	p.direction = Vector3.UP
	p.spread = 6.0
	p.initial_velocity_min = 0.6
	p.initial_velocity_max = 0.85
	p.gravity = drift
	p.damping_min = 0.05
	p.damping_max = 0.15
	p.scale_amount_min = 0.7
	p.scale_amount_max = 1.0
	var sc := Curve.new()
	sc.add_point(Vector2(0.0, 0.35))
	sc.add_point(Vector2(1.0, 3.2))
	p.scale_amount_curve = sc
	p.color_ramp = _grad([Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.7), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0.0)])
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	return p


## Suyun yüzünde genişleyip sönen ince köpük halkası: yüzücünün kulacı, kayığın izi, suya giren pala, ok, yüzen kütük.
## water_y: suyun yüksekliği (dünya). Aynı anda en çok 60 halka (fazlası atlanır). parent: sahne kökü ya da bölüm.
## Örnek: Vfx.water_ring(self, el.global_position, su_y, 0.1, 0.8, 0.9, 0.55). Bölüm 2, 17, 19O (kürek), Haliç sahneleri.
static func water_ring(parent: Node, pos: Vector3, water_y: float, r0 := 0.4, r1 := 2.0, life := 1.4, alpha := 0.5) -> void:
	if parent == null or not parent.is_inside_tree() or _ring_n > 60:
		return
	if _ring_mesh == null:
		_ring_mesh = _soft_ring_mesh()
	var ring := MeshInstance3D.new()
	ring.mesh = _ring_mesh
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.95, 0.98, 1.0, alpha)
	m.vertex_color_use_as_albedo = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	ring.material_override = m
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(ring)
	ring.global_position = Vector3(pos.x, water_y + 0.06, pos.z)
	ring.scale = Vector3(r0, 0.08, r0)
	_ring_n += 1
	var tw := ring.create_tween().set_parallel()
	tw.tween_property(ring, "scale", Vector3(r1, 0.08, r1), life).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(m, "albedo_color:a", 0.0, life).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(func():
		_ring_n -= 1
		ring.queue_free())


## Yumuşak köpük halkası ağı (tur 4): düz halka, iki kenarı köşe rengiyle saydamlaşır, ortası dolu. Eskiden üç kenarlı simit
## kesiti (TorusMesh) sivri beyaz üçgenler gibi görünüyordu.
static func _soft_ring_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var radii := [0.7, 0.86, 1.0]
	var alphas := [0.0, 1.0, 0.0]
	var n := 28
	for i in n:
		var a0 := TAU * i / n
		var a1 := TAU * (i + 1) / n
		for r in 2:
			var pts: Array = []
			for q: Array in [[r, a0], [r + 1, a0], [r, a1], [r, a1], [r + 1, a0], [r + 1, a1]]:
				var rr: float = radii[q[0]]
				pts.append([Vector3(cos(q[1]) * rr, 0.0, sin(q[1]) * rr), float(alphas[q[0]])])
			for p: Array in pts:
				st.set_color(Color(1, 1, 1, p[1]))
				st.set_normal(Vector3.UP)
				st.add_vertex(p[0])
	return st.commit()


## Su damlaları: küçük (yarıçap r), yarı saydam, yer çekimiyle düşer; su yüzeyinin hemen üstünden sıçrar.
## Suya giren el ya da pala, ok. Örnek: Vfx.water_drops(self, pala_ucu, su_y, 7). Kameranın önüne konmaz.
static func water_drops(parent: Node, pos: Vector3, water_y: float, n := 8, up := 2.2, r := 0.022) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var p := _drop_particles(parent, n, r)
	p.global_position = Vector3(pos.x, water_y + 0.04, pos.z)
	p.one_shot = true
	p.explosiveness = 0.9
	p.lifetime = 0.75
	p.direction = Vector3.UP
	p.spread = 40.0
	p.gravity = Vector3(0, -9.8, 0)
	p.initial_velocity_min = up * 0.5
	p.initial_velocity_max = up
	p.emitting = true
	p.get_tree().create_timer(1.3, false).timeout.connect(p.queue_free)


## Sudan çıkanın üstünden damlayan su (giysiden; head verilirse saçtan da, gözün ÖNÜNE değil yanlarına): küçük, yarı
## saydam, yer çekimiyle düşen damlalar, seconds sn. who: oyuncu ya da karakter (gövdesine bağlanır).
static func drip(who: Node3D, seconds := 6.0, head: Node3D = null) -> void:
	if who == null or not who.is_inside_tree():
		return
	var parts: Array = []
	var body := _drop_particles(who, 14, 0.012)
	body.position = Vector3(0, 0.8, 0.02)
	body.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	body.emission_box_extents = Vector3(0.24, 0.3, 0.08)
	body.direction = Vector3.DOWN
	body.spread = 5.0
	body.gravity = Vector3(0, -9.8, 0)
	body.initial_velocity_max = 0.2
	body.lifetime = 0.5
	body.emitting = true
	parts.append(body)
	if head:
		for sx: float in [-0.24, 0.24]:
			var hair := _drop_particles(head, 2, 0.006)
			hair.set_meta("transient", true)      # kameradaki geçici efekt: elde kalan eşya sayılmaz (HELDAUDIT)
			hair.position = Vector3(sx, 0.02, 0.06)     # kulakların yanında: görüşün dışında, kamera önünde değil
			hair.direction = Vector3.DOWN
			hair.spread = 3.0
			hair.gravity = Vector3(0, -7.0, 0)
			hair.initial_velocity_max = 0.05
			hair.lifetime = 0.6
			hair.emitting = true
			parts.append(hair)
	who.get_tree().create_timer(seconds, false).timeout.connect(func():
		for p: CPUParticles3D in parts:
			if is_instance_valid(p):
				p.emitting = false)
	who.get_tree().create_timer(seconds + 1.2, false).timeout.connect(func():
		for p: CPUParticles3D in parts:
			if is_instance_valid(p):
				p.queue_free())


static func _drop_particles(parent: Node, n: int, r: float) -> CPUParticles3D:
	if _drop_mesh == null:
		_drop_mesh = SphereMesh.new()
		_drop_mesh.radius = 1.0
		_drop_mesh.height = 2.6       # damla biçimi: dikine uzun
		_drop_mesh.radial_segments = 5
		_drop_mesh.rings = 3
		var m := StandardMaterial3D.new()
		m.albedo_color = Color(0.85, 0.93, 1.0, 0.55)
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_drop_mesh.material = m
	var p := CPUParticles3D.new()
	p.mesh = _drop_mesh
	p.amount = maxi(1, n)
	p.scale_amount_min = r * 0.7
	p.scale_amount_max = r * 1.2
	p.local_coords = false
	parent.add_child(p)
	return p


## Islak iz: ayak biçimli koyu, yarı saydam leke (yaw yönünde, sol/sağ ayak aynası), seconds içinde kurur. Sudan
## çıkanın izleri, dökülen su. Zemin eğimine yatmaz: kumsal, güverte, taş gibi düz yerlere. size 1: 27 cm'lik taban.
## Örnek: Vfx.wet_mark(self, nokta, yon, sol_mu, 40.0).
static func wet_mark(parent: Node, pos: Vector3, yaw: float, left := false, seconds := 30.0, size := 1.0, puddle := false,
		normal := Vector3.UP) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var mi := MeshInstance3D.new()
	mi.mesh = _footprint_mesh() if not puddle else _puddle_mesh()
	var m := StandardMaterial3D.new()
	# Koyu ıslak ton; kenarı köşe rengiyle (saydam) yumuşak (tur 3: eskiden keskin kenarlı nokta ve poligon leke)
	m.albedo_color = Color(0.05, 0.04, 0.025, 0.78)
	m.vertex_color_use_as_albedo = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# Az parlak: çok parlak iz gökyüzünü yansıtıp açık mavi nokta gibi görünüyordu
	m.roughness = 0.45
	m.metallic_specular = 0.35
	m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	mi.global_position = pos + normal.normalized() * 0.02
	# Eğime oturur (normal): yamaçta iz havada ya da gömülü kalmaz
	var b := Basis(Vector3.UP, yaw)
	var n := normal.normalized()
	var ax := Vector3.UP.cross(n)
	if ax.length() > 0.001:
		b = Basis(ax.normalized(), Vector3.UP.angle_to(n)) * b
	mi.global_transform.basis = b * Basis.from_scale(Vector3(-size if left else size, 1.0, size))
	var tw := mi.create_tween()
	tw.tween_interval(seconds * 0.55)
	tw.tween_property(m, "albedo_color:a", 0.0, seconds * 0.45)
	tw.tween_callback(mi.queue_free)


## Çıplak ayak izi ağı (+Z ileri, sağ ayak; sol için x aynalanır): topuk, dış kenarı dolu içi oyuk taban kemeri, ön
## taban ve beş parmak ucu (başparmak iri, içte). Köşe rengi: içi dolu (a=1), kenarı saydam (a=0): kenar yumuşak.
## Boy ~26 cm. Tur 3: eskiden iki yuvarlak nokta, ayak gibi okunmuyordu.
static func _footprint_mesh() -> ArrayMesh:
	if _foot_mesh:
		return _foot_mesh
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var sole: Array[Vector2] = [Vector2(0.0, -0.125), Vector2(0.028, -0.117), Vector2(0.041, -0.092), Vector2(0.039, -0.055),
		Vector2(0.036, -0.018), Vector2(0.044, 0.018), Vector2(0.05, 0.05), Vector2(0.041, 0.075), Vector2(0.016, 0.088),
		Vector2(-0.018, 0.09), Vector2(-0.044, 0.077), Vector2(-0.052, 0.047), Vector2(-0.04, 0.014), Vector2(-0.021, -0.022),
		Vector2(-0.019, -0.055), Vector2(-0.03, -0.09), Vector2(-0.024, -0.116)]
	_soft_poly(st, Vector2(0.006, -0.01), sole, 0.78)
	for toe: Array in [[Vector2(-0.031, 0.113), 0.018], [Vector2(-0.006, 0.12), 0.012], [Vector2(0.013, 0.116), 0.011],
			[Vector2(0.03, 0.106), 0.0095], [Vector2(0.043, 0.091), 0.0085]]:
		var ring: Array[Vector2] = []
		for i in 8:
			var a := TAU * i / 8.0
			ring.append(toe[0] + Vector2(cos(a), sin(a) * 1.2) * float(toe[1]))
		_soft_poly(st, toe[0], ring, 0.55)
	_foot_mesh = st.commit()
	return _foot_mesh


## Yumuşak kenarlı yassı çokgen (y = 0, yukarı bakar): merkezden yelpaze; iç halka (pay inner) dolu, dış halka saydam.
## Ayak izi, ıslak leke, çamur ve yağ yaması (Nature) bununla kurulur: kenarı zemine geçişli, düz levha gibi durmaz.
static func _soft_poly(st: SurfaceTool, c: Vector2, ring: Array[Vector2], inner := 0.75, y := 0.0, mid_y := 0.0) -> void:
	var n := ring.size()
	var cv := Vector3(c.x, mid_y, c.y)
	var on := Color(1, 1, 1, 1)
	var off := Color(1, 1, 1, 0)
	for i in n:
		var p0: Vector2 = ring[i]
		var p1: Vector2 = ring[(i + 1) % n]
		var i0 := Vector3(c.x + (p0.x - c.x) * inner, y, c.y + (p0.y - c.y) * inner)
		var i1 := Vector3(c.x + (p1.x - c.x) * inner, y, c.y + (p1.y - c.y) * inner)
		var o0 := Vector3(p0.x, y, p0.y)
		var o1 := Vector3(p1.x, y, p1.y)
		for v: Array in [[cv, on], [i1, on], [i0, on], [i0, on], [i1, on], [o1, off], [i0, on], [o1, off], [o0, off]]:
			st.set_color(v[1])
			st.set_normal(Vector3.UP)
			st.add_vertex(v[0])


static var _puddle: ArrayMesh
static func _puddle_mesh() -> ArrayMesh:
	if _puddle:
		return _puddle
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var pts: Array[Vector2] = []
	for i in 13:
		var a := TAU * i / 13.0
		var rr := rng.randf_range(0.36, 0.5)
		pts.append(Vector2(cos(a) * rr, sin(a) * rr * 0.8))
	_soft_poly(st, Vector2.ZERO, pts, 0.6)      # kenarı yumuşak birikinti (tur 3)
	_puddle = st.commit()
	return _puddle


## Sualtında sürekli yükselen kabarcık sütunu (dipteki çatlaktan, batıktan, dalgıçtan): height kadar yükselip söner.
## Sahne bitene dek kalır (döndürülen düğüm silinince biter). Tek çizim. Örnek: Vfx.bubble_column(self, dip, 4.0).
static func bubble_column(parent: Node3D, pos: Vector3, height := 4.0, amount := 14) -> CPUParticles3D:
	# Yuvarlak, kenarı parlak, içi saydam kabarcık (billboard); yükseldikçe büyür (eskiden düz beyaz çokgen küreler)
	var p := CPUParticles3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(0.06, 0.06)
	q.material = _bubble()
	p.mesh = q
	p.amount = amount
	p.local_coords = true
	p.position = pos
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.18
	p.direction = Vector3.UP
	p.spread = 8.0
	p.gravity = Vector3(0, 0.4, 0)
	p.initial_velocity_min = 0.6
	p.initial_velocity_max = 1.0
	p.lifetime = height / 1.1
	p.scale_amount_min = 0.4
	p.scale_amount_max = 1.0
	var sc := Curve.new()
	sc.add_point(Vector2(0.0, 0.4))
	sc.add_point(Vector2(1.0, 1.4))
	p.scale_amount_curve = sc
	p.color_ramp = _grad([Color(1, 1, 1, 0.0), Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.8), Color(1, 1, 1, 0.0)])
	parent.add_child(p)
	p.emitting = true
	return p


## Sualtı ışık huzmeleri: yüzeyden aşağı inen, eğik, uca doğru solan yarı saydam koniler; tek çoklu ağ (tek çizim),
## yavaşça kıpırdar. center: alanın ortası (dünya), size: alan, top_y: su yüzeyi. Yalnız sualtındayken görünür yapın.
## Örnek: var h := Vfx.light_shafts(self, merkez, Vector2(60, 60), 30, su_y, 6.0, 7); h.visible = sualti
static func light_shafts(parent: Node3D, center: Vector3, size: Vector2, count: int, top_y: float, length := 6.0, seed := 7,
		tilt := Vector3(12, 0, 8)) -> MultiMeshInstance3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var cm := CylinderMesh.new()
	cm.top_radius = 0.5
	cm.bottom_radius = 1.0
	cm.height = 1.0
	cm.radial_segments = 7
	cm.rings = 1
	cm.cap_top = false
	cm.cap_bottom = false
	var xs: Array = []
	for i in count:
		var p := center + Vector3(rng.randf_range(-size.x, size.x) * 0.5, 0, rng.randf_range(-size.y, size.y) * 0.5)
		var w := rng.randf_range(0.5, 1.3)
		var b := Basis.from_euler(tilt * (PI / 180.0)) * Basis.from_scale(Vector3(w, length * rng.randf_range(0.7, 1.1), w))
		xs.append(Transform3D(b, Vector3(p.x, top_y, p.z) + b * Vector3(0, -0.5, 0)))
	if _shaft_mat == null:
		_shaft_mat = ShaderMaterial.new()
		var sh := Shader.new()
		sh.code = """shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_add;
uniform vec4 tint : source_color = vec4(0.55, 0.85, 0.8, 1.0);
uniform float strength = 0.16;
varying float fy;
void vertex() { fy = VERTEX.y + 0.5; }
void fragment() {
	float edge = pow(abs(dot(normalize(NORMAL), normalize(VIEW))), 1.5);
	float flick = 0.75 + 0.25 * sin(TIME * 0.9 + NODE_POSITION_WORLD.x * 0.3);
	ALBEDO = tint.rgb;
	ALPHA = strength * fy * fy * edge * flick;
}"""
		_shaft_mat.shader = sh
	var mi := Scenery.scatter(parent, cm, xs, [], _shaft_mat)
	mi.set_meta("no_walk", true)
	mi.set_meta("soft", true)
	return mi


## Salınan bitki malzemesi (yosun, sazlık, uzun ot): köşe rengi × örnek rengi; köşe yüksekliğiyle (y / boy) artan,
## dünyada dalga gibi ilerleyen salınım. Sualtında yavaş ve geniş (under = true), karada rüzgâr. Tek paylaşılan.
## Örnek: Scenery.scatter(self, Nature.seaweed_mesh(), xs, cs, Vfx.sway_material(true))
static func sway_material(under := true) -> ShaderMaterial:
	if under and _sway_mat:
		return _sway_mat
	var m := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = """shader_type spatial;
render_mode cull_disabled, diffuse_lambert, specular_disabled;
uniform float amp = %s;
uniform float speed = %s;
uniform float height = 2.5;
void vertex() {
	vec3 w = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float k = clamp(VERTEX.y / height, 0.0, 1.0);
	float s = sin(TIME * speed + w.x * 0.45 + w.z * 0.3 + VERTEX.y * 1.3);
	float c = cos(TIME * speed * 0.7 + w.z * 0.5 + VERTEX.y * 0.9);
	VERTEX.x += s * amp * k * k;
	VERTEX.z += c * amp * 0.6 * k * k;
}
void fragment() {
	ALBEDO = COLOR.rgb;
	if (!FRONT_FACING) { NORMAL = -NORMAL; }
	ROUGHNESS = 1.0;
}""" % ["0.35" if under else "0.08", "0.9" if under else "1.8"]
	m.shader = sh
	if under:
		_sway_mat = m
	return m


## Havada süzülen zerreler (toz, talaş, polen, kıvılcımsız kül): who'nun çevresinde (yerel kutu extents), güneşte
## parlayan küçük açık lekeler; tek çizim. Kızak, harman, atölye, savaş alanı. who hareket etse de zerreler dünyada
## kalır (local_coords false). Örnek: Vfx.motes(kamera, Vector3(6, 2, 8), 60, Color(1, 0.92, 0.75, 0.7))
static func motes(who: Node3D, extents := Vector3(6, 2, 8), amount := 60, color := Color(1.0, 0.93, 0.78, 0.7)) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	var q := QuadMesh.new()
	# Yuvarlak, kenarı yumuşak, eklemeli (güneşte ışıldayan) zerre: eski düz renkli kare billboard havada krem kutucuk
	# gibi okunuyordu (Bölüm 2 tur 3)
	q.size = Vector2(0.022, 0.022)
	q.material = _soft_mat(color, true)
	p.mesh = q
	p.amount = amount
	p.lifetime = 5.0
	p.preprocess = 5.0
	p.local_coords = false
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = extents
	p.direction = Vector3(0.3, 0.2, 0)
	p.spread = 180.0
	p.gravity = Vector3(0, -0.05, 0)
	p.initial_velocity_min = 0.05
	p.initial_velocity_max = 0.25
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.6
	var fade := Gradient.new()
	fade.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	fade.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	p.color_ramp = fade
	p.set_meta("transient", true)
	who.add_child(p)
	p.emitting = true
	return p
