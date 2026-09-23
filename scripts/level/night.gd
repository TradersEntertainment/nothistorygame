class_name Night
## 1453 gecesi için ortak parçalar: gece gökyüzü, ay, yıldızlar, kamp ateşi, çadır, meşale.
## Bölüm 4'ün iki yolu (ordugâh ve deniz surları) ve Perde I kapanışı bunları kullanır.


## Gece ortamı: lacivert gökyüzü, ay ışığı, soğuk sis. Ay ışığını döndürür.
static func environment(parent: Node3D, fog := 0.012) -> DirectionalLight3D:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("0b1330")
	sm.sky_horizon_color = Color("2a3560")
	sm.ground_horizon_color = Color("1c2238")
	sm.ground_bottom_color = Color("0a0d18")
	sm.sky_energy_multiplier = 1.0
	sm.sun_angle_max = 5.0
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("6a7ab8")
	e.ambient_light_energy = 0.45
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.1
	e.fog_enabled = true
	e.fog_light_color = Color("1a2240")
	e.fog_density = fog
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.8
	e.glow_bloom = 0.1
	env.environment = e
	parent.add_child(env)
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-38, -150, 0)
	moon.light_color = Color("9fb4ff")
	moon.light_energy = 0.55
	moon.shadow_enabled = true
	moon.directional_shadow_max_distance = 60.0
	parent.add_child(moon)
	# Ay ve yıldızlar
	var m := Props.ball(parent, 9.0, Vector3(-160, 120, -260), Color("f4f0d8"), Vector3.ONE, 16, 3.0)
	m.material_override = Props.mat(Color("f4f0d8"), 3.0, false, "", false)
	var stars := MultiMeshInstance3D.new()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var q := SphereMesh.new()
	q.radius = 0.6
	q.height = 1.2
	q.radial_segments = 4
	q.rings = 2
	mm.mesh = q
	mm.instance_count = 260
	var rng := RandomNumberGenerator.new()
	rng.seed = 53
	for i in mm.instance_count:
		var a := rng.randf() * TAU
		var el := rng.randf_range(0.12, 1.3)
		var dir := Vector3(cos(a) * cos(el), sin(el), sin(a) * cos(el))
		var s := rng.randf_range(0.4, 1.3)
		mm.set_instance_transform(i, Transform3D(Basis().scaled(Vector3.ONE * s), dir * 380.0))
	stars.multimesh = mm
	var sm2 := StandardMaterial3D.new()
	sm2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm2.albedo_color = Color("fffbe8")
	stars.material_override = sm2
	parent.add_child(stars)
	return moon


## Kamp ateşi: taşlar, odunlar, alev konileri ve titreyen turuncu ışık.
static func campfire(parent: Node3D, pos: Vector3, size := 1.0) -> OmniLight3D:
	var f := Node3D.new()
	f.position = pos
	parent.add_child(f)
	for i in 8:
		var a := TAU * i / 8.0
		Props.ball(f, 0.14 * size, Vector3(cos(a), 0.05, sin(a)) * 0.5 * size, Color("5a5a5e"), Vector3(1, 0.7, 1), 6)
	for i in 3:
		Props.cyl(f, 0.06 * size, 0.8 * size, Vector3(0, 0.12, 0), Color("4a3020"), Vector3(80, i * 60, 0), 5)
	var flame := StandardMaterial3D.new()
	flame.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame.albedo_color = Color("ffb030")
	var fl1 := Props.cyl(f, 0.28 * size, 0.7 * size, Vector3(0, 0.45 * size, 0), Color("ffb030"), Vector3.ZERO, 6, 0.0)
	fl1.material_override = flame
	var flame2 := StandardMaterial3D.new()
	flame2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame2.albedo_color = Color("fff0a0")
	var fl2 := Props.cyl(f, 0.14 * size, 0.45 * size, Vector3(0, 0.35 * size, 0), Color("fff0a0"), Vector3.ZERO, 6, 0.0)
	fl2.material_override = flame2
	fl1.set_meta("flame", true)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 0.9 * size, 0)
	light.light_color = Color("ff9a40")
	light.light_energy = 2.2 * size
	light.omni_range = 9.0 * size
	light.set_meta("base", light.light_energy)
	f.add_child(light)
	return light


## Meşale: direk, alev ve ışık.
static func torch(parent: Node3D, pos: Vector3, height := 2.2, with_light := true) -> OmniLight3D:
	Props.cyl(parent, 0.05, height, pos + Vector3(0, height / 2, 0), Color("4a3020"), Vector3.ZERO, 5)
	Props.cyl(parent, 0.09, 0.2, pos + Vector3(0, height, 0), Color("2a2a2a"), Vector3.ZERO, 6)
	var fl := Props.cyl(parent, 0.1, 0.35, pos + Vector3(0, height + 0.25, 0), Color("ffb030"), Vector3.ZERO, 5, 0.0)
	var flame := StandardMaterial3D.new()
	flame.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame.albedo_color = Color("ffc050")
	fl.material_override = flame
	if not with_light:
		return null
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, height + 0.4, 0)
	light.light_color = Color("ff9a40")
	light.light_energy = 1.8
	light.omni_range = 8.0
	light.set_meta("base", light.light_energy)
	parent.add_child(light)
	return light


## Osmanlı ordugâh çadırı: yuvarlak gövde, sivri tepe, üstünde küçük bayrak.
static func tent(parent: Node3D, pos: Vector3, radius := 1.8, color := Color("d8cbb0"), band := Color("8a2b22")) -> Node3D:
	var t := Node3D.new()
	t.position = pos
	parent.add_child(t)
	Props.cyl(t, radius, 1.4, Vector3(0, 0.7, 0), color, Vector3.ZERO, 10)
	Props.cyl(t, radius * 1.05, 1.3, Vector3(0, 2.05, 0), color.darkened(0.08), Vector3.ZERO, 10, 0.05)
	Props.cyl(t, radius * 1.01, 0.18, Vector3(0, 1.3, 0), band, Vector3.ZERO, 10)
	Props.cyl(t, 0.03, 0.8, Vector3(0, 3.0, 0), Color("4a3020"), Vector3.ZERO, 4)
	Props.box(t, Vector3(0.02, 0.25, 0.4), Vector3(0, 3.25, 0.2), band)
	# Kapı aralığı
	Props.box(t, Vector3(0.9, 1.2, 0.05), Vector3(0, 0.6, radius + 0.01), Color("1a1410"))
	return t


## Titreyen ışıklar: ateş ve meşale ışıklarını hafifçe oynatır (her karede çağrılır).
static func flicker(lights: Array, t: float) -> void:
	for i in lights.size():
		var l: OmniLight3D = lights[i]
		if l == null:
			continue
		var base: float = l.get_meta("base", 1.5)
		l.light_energy = base * (0.85 + 0.15 * sin(t * 11.0 + i * 1.7) + 0.08 * sin(t * 23.0 + i * 3.1))
