class_name Slipway
extends Node3D
## Bölüm 2 sahnesi: 22 Nisan 1453 sabahı, Galata'nın arkasındaki tepelerden Haliç'e
## inen yağlı kızaklar. Low-poly tepeler, kadırga, askerler ve öküzler, dalgalı Haliç,
## karşı kıyıda tuğla bantlı surlar, kiremit çatılı şehir, Ayasofya (1453'te minaresi
## yoktu), Galata Kulesi, Haliç zinciri, bulutlar ve martılar.
##
## Yokuş "track" düğümünün içinde kuruludur: track'in yerel -Z yönü yokuş aşağıdır.
## s: yokuş boyunca metre (0 = tepe), x: şerit ekseni.

const SLOPE_DEG := 7.0
const LENGTH := 130.0
const WIDTH := 9.0
const LANES := [-2.4, 0.0, 2.4]

const C_TRACK := Color("7a5b3c")
const C_LOG := Color("8a6440")
const C_SAND := Color("dcc58f")
const C_STONE := Color("d8c7a4")
const C_STONE_DARK := Color("a8916c")
const C_BRICK := Color("a4513a")
const C_ROOF := Color("b5533a")

var track: Node3D
var ship: Node3D
var boat: Node3D
var water_y := 0.0
var obstacles: Array = []      # [{s, kind: "rope"/"log"/"block", lanes: [..], node, resolved}]
var _water: MeshInstance3D
var _clouds: Array[Node3D] = []
var _gulls: Array = []          # [{node, center, radius, speed, phase, wings}]
var _noise := FastNoiseLite.new()
var _t := 0.0
var _tan := tan(deg_to_rad(SLOPE_DEG))


func _ready() -> void:
	_noise.seed = 1453
	_noise.frequency = 0.035
	_noise.fractal_octaves = 3
	_build_sky()
	track = Node3D.new()
	track.rotation_degrees.x = -SLOPE_DEG
	add_child(track)
	water_y = end_point().y - 0.8
	_build_slope()
	_build_terrain()
	_build_sides()
	_build_ship()
	_build_obstacles()
	_build_bottom()
	_build_far_shore()
	_build_chain_and_boat()
	_build_clouds_and_gulls()


func _process(delta: float) -> void:
	_t += delta
	for c in _clouds:
		c.position.x += delta * 1.2
		if c.position.x > 320.0:
			c.position.x = -320.0
	for g in _gulls:
		var a: float = g["phase"] + _t * g["speed"]
		var n: Node3D = g["node"]
		n.position = g["center"] + Vector3(cos(a), sin(a * 2.0) * 0.08, sin(a)) * g["radius"]
		n.rotation.y = -a
		var flap := sin(_t * 9.0 + g["phase"] * 3.0) * 0.5
		(g["wings"][0] as Node3D).rotation.z = 0.25 + flap
		(g["wings"][1] as Node3D).rotation.z = -0.25 - flap


# ---------------------------------------------------------------- koordinatlar

func s_to_world(s: float, x := 0.0, up := 0.0) -> Vector3:
	return track.to_global(Vector3(x, up, -s))


func world_to_s(p: Vector3) -> float:
	return -track.to_local(p).z


func world_to_x(p: Vector3) -> float:
	return track.to_local(p).x


## Yokuş aşağı birim yön (dünya).
func down_dir() -> Vector3:
	return (track.global_transform.basis * Vector3(0, 0, -1)).normalized()


func end_point() -> Vector3:
	return s_to_world(LENGTH)


func swim_start() -> Vector3:
	return end_point() + Vector3(0, 0, -8)


func shore_point() -> Vector3:
	return end_point() + Vector3(14, 0, -4)


func chain_point() -> Vector3:
	return end_point() + Vector3(-34, 0, -30)


## Yokuşun iki yanındaki arazinin yüksekliği (dünya x, z).
func ground_h(x: float, z: float) -> float:
	var end_z := end_point().z
	var base := z * _tan
	var edge := WIDTH / 2.0 + 0.4
	var ax := absf(x) - edge
	var h := base - 0.3
	if ax > 0.0:
		var hills := _noise.get_noise_2d(x, z) * minf(ax * 0.35, 5.0)
		h += ax * 0.12 + hills + maxf(0.0, ax - 25.0) * 0.18
	# Kıyıya yaklaştıkça su seviyesine iner
	var shore := clampf((z - end_z) / 6.0, 0.0, 1.0)
	return lerpf(water_y - 1.6, h, shore) if z < end_z + 6.0 else h


# ---------------------------------------------------------------- gökyüzü

func _build_sky() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3a7fc4")
	sm.sky_horizon_color = Color("c4dceb")
	sm.ground_horizon_color = Color("c9d8c0")
	sm.ground_bottom_color = Color("6d7f5a")
	sm.sky_energy_multiplier = 0.95
	sm.sun_angle_max = 18.0
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.05
	e.fog_enabled = true
	e.fog_light_color = Color("c7d7e4")
	e.fog_density = 0.0012
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.2
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.05
	e.adjustment_contrast = 1.06
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-34, 145, 0)
	sun.light_color = Color("ffe9c7")
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)


func _build_clouds_and_gulls() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2204
	var white := Props.mat(Color("fbfbf8"), 0.0, false, "", false)
	var belly := Props.mat(Color("dfe6ee"), 0.0, false, "", false)
	for i in 14:
		var c := Node3D.new()
		c.position = Vector3(rng.randf_range(-300, 300), rng.randf_range(48, 85), rng.randf_range(-40, -480))
		add_child(c)
		for k in rng.randi_range(4, 7):
			var r := rng.randf_range(5.0, 10.0)
			var mi := MeshInstance3D.new()
			var sm := SphereMesh.new()
			sm.radius = r
			sm.height = r * 2.0
			sm.radial_segments = 7
			sm.rings = 4
			mi.mesh = sm
			mi.material_override = white if k > 0 else belly
			mi.position = Vector3(rng.randf_range(-14, 14), rng.randf_range(-1.5, 3.0), rng.randf_range(-6, 6))
			mi.scale = Vector3(1.4, 0.6, 1.0)
			c.add_child(mi)
		_clouds.append(c)
	# Martılar
	var end := end_point()
	for i in 7:
		var g := Node3D.new()
		add_child(g)
		var wings: Array = []
		for side in [-1, 1]:
			var pivot := Node3D.new()
			g.add_child(pivot)
			var w := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = Vector3(0.9, 0.04, 0.25)
			w.mesh = bm
			w.material_override = Props.mat(Color("f4f4f0"), 0.0, false, "", false)
			w.position = Vector3(side * 0.45, 0, 0)
			pivot.add_child(w)
			wings.append(pivot)
		var body := MeshInstance3D.new()
		var bb := BoxMesh.new()
		bb.size = Vector3(0.18, 0.14, 0.5)
		body.mesh = bb
		body.material_override = Props.mat(Color("e9e9e4"), 0.0, false, "", false)
		g.add_child(body)
		_gulls.append({
			"node": g, "wings": wings,
			"center": end + Vector3(rng.randf_range(-40, 30), rng.randf_range(10, 22), rng.randf_range(-70, -10)),
			"radius": rng.randf_range(8, 20), "speed": rng.randf_range(0.25, 0.5), "phase": rng.randf() * TAU,
		})


# ---------------------------------------------------------------- yokuş

func _build_slope() -> void:
	# Kızak yolu (çarpışmalı)
	var body := Props.solid(track, Vector3(WIDTH, 1.0, LENGTH + 6), Vector3(0, -0.5, -LENGTH / 2.0 + 2), C_TRACK)
	Props.set_pattern(body, C_TRACK, "wood")
	# Yanlarda görünmez duvarlar: oyuncu yoldan çıkamaz
	for side in [-1, 1]:
		var wall := Props.solid(track, Vector3(0.4, 3.0, LENGTH + 6), Vector3(side * (WIDTH / 2.0 + 0.2), 1.5, -LENGTH / 2.0 + 2), Color(0, 0, 0, 0))
		wall.get_child(0).visible = false
	# Enine yağlı kütükler
	var s := 1.0
	while s < LENGTH:
		Props.cyl(track, 0.17, WIDTH - 0.4, Vector3(0, 0.02, -s), C_LOG, Vector3(0, 0, 90), 8)
		s += 2.6
	# Yağ lekeleri (koyu, parlak şeritler)
	for i in 14:
		var ls := 8.0 + i * 8.5
		var lx: float = LANES[i % 3]
		Props.box(track, Vector3(1.6, 0.02, 3.0), Vector3(lx, 0.2, -ls), Color(0.18, 0.12, 0.05, 0.55))
	# Kenar kirişleri ve kazıklar
	for side in [-1, 1]:
		Props.box(track, Vector3(0.3, 0.3, LENGTH + 6), Vector3(side * (WIDTH / 2.0 - 0.15), 0.15, -LENGTH / 2.0 + 2), Color("5f4329"))
		var k := 0.0
		while k < LENGTH:
			Props.cyl(track, 0.09, 0.8, Vector3(side * (WIDTH / 2.0 + 0.05), 0.25, -k), Color("6b4a2e"), Vector3.ZERO, 6)
			k += 6.5


func _build_terrain() -> void:
	var end_z := end_point().z
	var edge := WIDTH / 2.0 + 0.3
	var colf := func(x: float, z: float, y: float, steep: float) -> Color:
		var ax := absf(x) - WIDTH / 2.0
		if y < water_y + 0.25:
			return C_SAND
		if ax < 1.6:
			return Color("8f6f4a")
		var n := _noise.get_noise_2d(x * 3.1, z * 3.1)
		var c := Color("2c4d1d").lerp(Color("466426"), clampf(n * 1.5 + 0.5, 0.0, 1.0))
		if steep > 0.35:
			c = c.darkened(0.12)
		if y - z * _tan > 5.0:
			c = c.lerp(Color("5f6238"), 0.35)
		return c
	var hf := func(x: float, z: float) -> float: return ground_h(x, z)
	add_child(LowPoly.terrain(edge, 110.0, end_z - 10.0, 160.0, 36, 90, hf, colf))
	add_child(LowPoly.terrain(-110.0, -edge, end_z - 10.0, 160.0, 36, 90, hf, colf))
	# Yokuşun tepesinin arkası (kadırga buradan başlar)
	add_child(LowPoly.terrain(-edge, edge, 4.0, 160.0, 4, 30, hf, colf))


func _place_on_ground(node: Node3D, x: float, z: float) -> void:
	node.position = Vector3(x, ground_h(x, z), z)
	add_child(node)


## Yokuş boyunca s, kenardan uzaklık -> dünya x, z
func _side_xz(s: float, side: int, dist: float) -> Vector2:
	var p := s_to_world(s, side * (WIDTH / 2.0 + dist))
	return Vector2(p.x, p.z)


func _build_sides() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 22041453
	for side in [-1, 1]:
		# Selviler (gruplar hâlinde)
		for i in 26:
			var xz := _side_xz(rng.randf_range(-5, LENGTH - 4), side, rng.randf_range(5, 40))
			var tree := Node3D.new()
			_cypress(tree, rng.randf_range(4.0, 8.0))
			_place_on_ground(tree, xz.x, xz.y)
		# Çadırlar
		for i in 6:
			var xz2 := _side_xz(10.0 + i * 20.0 + rng.randf_range(-4, 4), side, rng.randf_range(8, 16))
			var tent := Node3D.new()
			_tent(tent, rng.randf() > 0.5)
			tent.rotation_degrees.y = rng.randf_range(-20, 20)
			_place_on_ground(tent, xz2.x, xz2.y)
		# Halat çeken askerler
		for i in 9:
			var s3 := 6.0 + i * 13.0
			var coat: Color = [Color("b3262d"), Color("2f5fa8"), Color("3f7a3a"), Color("c98a3a")][i % 4]
			var sol := Soldier.new(coat, "pull" if i % 3 != 2 else "point", "bork" if i % 2 == 0 else "turban")
			var xz3 := _side_xz(s3, side, 1.4)
			sol.rotation_degrees.y = 180.0
			_place_on_ground(sol, xz3.x, xz3.y)
			if i % 3 != 2:
				Props.cyl(track, 0.025, 3.0, Vector3(side * (WIDTH / 2.0 + 1.0), 0.9, -s3 + 1.4), Color("c9b48a"), Vector3(70, 0, side * 10), 4)
		# Öküz takımları
		for i in 3:
			var xz4 := _side_xz(24.0 + i * 38.0, side, 4.5)
			var team := Node3D.new()
			_ox(team, Vector3(-0.8, 0, 0))
			_ox(team, Vector3(0.8, 0, 0))
			var herder := Soldier.new(Color("7a5232"), "point", "turban")
			herder.position = Vector3(2.0, 0, 0.6)
			team.add_child(herder)
			team.rotation_degrees.y = 180.0
			_place_on_ground(team, xz4.x, xz4.y)
		# Fıçılar, sandıklar, yağ kovaları, kütük yığınları
		for i in 12:
			var xz5 := _side_xz(rng.randf_range(4, LENGTH - 6), side, rng.randf_range(0.9, 3.0))
			var prop := Node3D.new()
			match i % 4:
				0:
					Props.cyl(prop, 0.35, 0.8, Vector3(0, 0.4, 0), Color("7a5232"), Vector3.ZERO, 8)
					Props.cyl(prop, 0.37, 0.06, Vector3(0, 0.2, 0), Color("4a4d52"), Vector3.ZERO, 8)
					Props.cyl(prop, 0.37, 0.06, Vector3(0, 0.6, 0), Color("4a4d52"), Vector3.ZERO, 8)
				1:
					Props.box(prop, Vector3(0.8, 0.6, 0.6), Vector3(0, 0.3, 0), Color("a57a4e"))
					Props.box(prop, Vector3(0.6, 0.45, 0.5), Vector3(0.1, 0.82, 0), Color("b88c5c"), Vector3(0, 15, 0))
				2:
					Props.cyl(prop, 0.22, 0.35, Vector3(0, 0.18, 0), Color("2b2622"), Vector3.ZERO, 8)
					Props.cyl(prop, 0.2, 0.02, Vector3(0, 0.36, 0), Color("141210"), Vector3.ZERO, 8)
				3:
					for r in 3:
						for c in 3 - r:
							Props.cyl(prop, 0.2, 2.4, Vector3(-0.4 + c * 0.42 + r * 0.21, 0.2 + r * 0.36, 0), C_LOG, Vector3(90, 0, 0), 8)
			prop.rotation_degrees.y = rng.randf_range(0, 360)
			_place_on_ground(prop, xz5.x, xz5.y)


func _cypress(parent: Node3D, h: float) -> void:
	Props.cyl(parent, 0.14, 0.9, Vector3(0, 0.45, 0), Color("5a3a24"), Vector3.ZERO, 6)
	Props.cyl(parent, 0.62, h, Vector3(0, 0.8 + h / 2.0, 0), Color("2f5a2c"), Vector3.ZERO, 7, 0.06)
	Props.cyl(parent, 0.5, h * 0.55, Vector3(0.05, 0.9 + h * 0.28, 0.05), Color("3a6a34"), Vector3.ZERO, 7, 0.2)


func _tent(parent: Node3D, red: bool) -> void:
	var c := Color("f1e9d6")
	Props.prism(parent, Vector3(3.0, 2.2, 3.6), Vector3(0, 1.1, 0), c)
	if red:
		Props.prism(parent, Vector3(3.05, 0.5, 3.65), Vector3(0, 2.0, 0), Color("b3262d"))
	Props.cyl(parent, 0.04, 1.0, Vector3(0, 2.6, 0), Color("5a3a24"), Vector3.ZERO, 4)
	Props.box(parent, Vector3(0.5, 0.3, 0.02), Vector3(0.25, 2.95, 0), Color("b3262d"))


func _ox(parent: Node3D, pos: Vector3) -> void:
	var brown := Color("8a5a36")
	Props.box(parent, Vector3(0.9, 0.9, 1.9), pos + Vector3(0, 1.0, 0), brown)
	Props.box(parent, Vector3(0.55, 0.55, 0.7), pos + Vector3(0, 1.25, -1.2), brown.darkened(0.1))
	Props.box(parent, Vector3(0.4, 0.3, 0.2), pos + Vector3(0, 1.1, -1.6), Color("d9b08a"))
	for sx in [-1, 1]:
		Props.cyl(parent, 0.04, 0.45, pos + Vector3(sx * 0.35, 1.6, -1.2), Color("efe6cf"), Vector3(0, 0, sx * -60), 5)
		for zz in [-0.6, 0.6]:
			Props.box(parent, Vector3(0.18, 0.6, 0.18), pos + Vector3(sx * 0.3, 0.3, zz), brown.darkened(0.2))
	Props.box(parent, Vector3(2.2, 0.1, 0.12), Vector3(0, 1.62, -0.95), Color("6b4428"))


# ---------------------------------------------------------------- kadırga

func _build_ship() -> void:
	ship = Node3D.new()
	track.add_child(ship)
	var hull := LowPoly.hull([
		{"z": -9.6, "w": 0.06, "top": 2.5, "bottom": 1.5},
		{"z": -8.0, "w": 0.9, "top": 2.15, "bottom": 0.55},
		{"z": -5.0, "w": 1.5, "top": 1.95, "bottom": 0.28},
		{"z": 0.0, "w": 1.72, "top": 1.9, "bottom": 0.22},
		{"z": 4.0, "w": 1.62, "top": 1.95, "bottom": 0.28},
		{"z": 6.5, "w": 1.3, "top": 2.35, "bottom": 0.55},
		{"z": 7.7, "w": 0.85, "top": 2.9, "bottom": 1.1},
	], Color("5b3a22"), Color("7e2420"), 1.78)
	ship.add_child(hull)
	# Güverte, kıç köşkü, küpeşte bandı
	Props.box(ship, Vector3(2.9, 0.1, 12.0), Vector3(0, 1.85, -0.6), Color("b08a5c"))
	Props.box(ship, Vector3(2.3, 0.8, 2.0), Vector3(0, 2.3, 5.8), Color("6b4428"))
	Props.box(ship, Vector3(2.5, 0.12, 2.2), Vector3(0, 2.76, 5.8), Color("c9a24a"))
	Props.ball(ship, 0.18, Vector3(0, 3.35, 7.2), Color("ffcf6a"), Vector3.ONE, 8, 2.5)
	Props.cyl(ship, 0.04, 0.5, Vector3(0, 3.05, 7.2), Color("3a2a1a"), Vector3.ZERO, 4)
	# Mahmuz
	Props.cyl(ship, 0.14, 2.4, Vector3(0, 1.25, -10.7), Color("6b4428"), Vector3(90, 0, 0), 6, 0.04)
	# Kürekler
	for i in 10:
		for side in [-1, 1]:
			Props.cyl(ship, 0.04, 3.4, Vector3(side * 2.35, 1.1, -5.0 + i * 1.05), Color("c9a878"), Vector3(0, 0, side * 62), 4)
	# Direk, latin yelkenin çubuğu ve sarılı yelken, bayraklar
	Props.cyl(ship, 0.15, 9.5, Vector3(0, 6.5, -1.5), Color("6b4428"), Vector3.ZERO, 6)
	Props.cyl(ship, 0.08, 11.0, Vector3(0, 8.4, -1.8), Color("6b4428"), Vector3(55, 0, 0), 6)
	Props.cyl(ship, 0.24, 8.0, Vector3(0, 8.2, -1.6), Color("efe6cf"), Vector3(55, 0, 0), 7)
	Props.box(ship, Vector3(0.05, 0.7, 1.4), Vector3(0, 11.0, -1.3), Color("b3262d"))
	Props.box(ship, Vector3(0.05, 0.5, 0.9), Vector3(0, 3.6, 6.4), Color("b3262d"))
	Props.cyl(ship, 0.03, 1.0, Vector3(0, 3.2, 6.8), Color("3a2a1a"), Vector3.ZERO, 4)
	# Kızak kütükleri
	for i in 5:
		Props.cyl(ship, 0.2, 4.0, Vector3(0, 0.2, -6.0 + i * 3.0), C_LOG, Vector3(0, 0, 90), 8)
	# Güvertede şaşkın tayfalar
	for p in [Vector3(0.6, 1.9, -5.5), Vector3(-0.7, 1.9, -2.5)]:
		var crew := Soldier.new(Color("2f5fa8"), "point", "turban")
		crew.position = p
		crew.rotation_degrees.y = 180
		ship.add_child(crew)


func set_ship_s(s: float) -> void:
	ship.position = Vector3(0, 0.0, -s)


# ---------------------------------------------------------------- engeller

func _build_obstacles() -> void:
	# kind: "rope" (zıpla), "log" (şeritleri kapatır), "block" (şeritte duran asker)
	var plan := [
		[20.0, "rope", [0, 1, 2]],
		[32.0, "log", [0, 1]],
		[44.0, "block", [2]],
		[56.0, "rope", [0, 1, 2]],
		[68.0, "log", [1, 2]],
		[80.0, "block", [0]],
		[92.0, "log", [0, 2]],
		[104.0, "rope", [0, 1, 2]],
		[114.0, "block", [1]],
	]
	for p in plan:
		var s: float = p[0]
		var kind: String = p[1]
		var lanes: Array = p[2]
		var node := Node3D.new()
		track.add_child(node)
		node.position = Vector3(0, 0, -s)
		match kind:
			"rope":
				Props.cyl(node, 0.06, WIDTH + 1.0, Vector3(0, 0.55, 0), Color("c9b48a"), Vector3(0, 0, 90), 6)
				for side in [-1, 1]:
					var sol := Soldier.new(Color("b3262d"), "pull", "bork")
					sol.position = Vector3(side * (WIDTH / 2.0 + 0.8), -0.2, 0)
					sol.rotation_degrees.y = -90.0 * side
					node.add_child(sol)
			"log":
				for l in lanes:
					Props.cyl(node, 0.42, 2.6, Vector3(LANES[l], 0.42, 0), C_LOG, Vector3(0, 0, 90), 8)
					Props.cyl(node, 0.2, 0.02, Vector3(LANES[l] + 1.31, 0.42, 0), Color("c9a878"), Vector3(0, 0, 90), 8)
			"block":
				for l in lanes:
					var sol2 := Soldier.new(Color("3f7a3a"), "point", "turban")
					sol2.position = Vector3(LANES[l], 0.0, 0)
					node.add_child(sol2)
		obstacles.append({"s": s, "kind": kind, "lanes": lanes, "node": node, "resolved": false})


func reset_obstacles_after(s: float) -> void:
	for o in obstacles:
		if o["s"] > s:
			o["resolved"] = false
			(o["node"] as Node3D).visible = true


# ---------------------------------------------------------------- Haliç

func _build_bottom() -> void:
	var end := end_point()
	# Kum şeridi
	var sand := Props.solid(self, Vector3(80, 1.0, 10), Vector3(end.x, water_y - 0.3, end.z + 2), C_SAND)
	Props.set_pattern(sand, C_SAND, "concrete")
	# Dalgalı su (low-poly gölgelendirici)
	_water = MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(900, 900)
	pm.subdivide_width = 150
	pm.subdivide_depth = 150
	_water.mesh = pm
	var sh := ShaderMaterial.new()
	sh.shader = load("res://assets/shaders/water.gdshader")
	sh.set_shader_parameter("shore_z", end.z - 3.0)
	_water.material_override = sh
	_water.position = Vector3(end.x, water_y, end.z - 380)
	add_child(_water)
	# İskele
	Props.box(self, Vector3(2.0, 0.15, 8.0), Vector3(end.x + 22, water_y + 0.35, end.z - 5), Color("8a6440"))
	for zz in [-8.0, -5.0, -2.0]:
		for xx in [-0.9, 0.9]:
			Props.cyl(self, 0.12, 2.0, Vector3(end.x + 22 + xx, water_y - 0.4, end.z + zz), Color("5f4329"), Vector3.ZERO, 6)
	# Kıyıda askerler ve fıçılar (kıyı yolu için)
	var sp := shore_point()
	for i in 3:
		Props.cyl(self, 0.35, 0.8, sp + Vector3(-1.5 + i * 0.8, water_y - sp.y + 0.6, 2.5), Color("7a5232"), Vector3.ZERO, 8)
	for i in 2:
		var sol := Soldier.new(Color("b3262d") if i == 0 else Color("2f5fa8"), "stand", "bork")
		sol.position = sp + Vector3(1.5 + i * 1.2, water_y - sp.y + 0.2, 1.0)
		sol.rotation_degrees.y = 150
		add_child(sol)


func _build_far_shore() -> void:
	var end := end_point()
	var base_y := water_y
	var far_z := end.z - 150.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	# Karşı kıyı zemini
	Props.box(self, Vector3(600, 6, 70), Vector3(end.x, base_y - 2.2, far_z - 33), C_STONE_DARK)
	# Arkadaki tepeler (şehrin yedi tepesi, low-poly)
	var far_noise := FastNoiseLite.new()
	far_noise.seed = 7
	far_noise.frequency = 0.012
	var hf := func(x: float, z: float) -> float:
		var d := clampf((far_z - 40.0 - z) / 180.0, 0.0, 1.0)
		return base_y + 1.0 + d * 26.0 + far_noise.get_noise_2d(x, z) * (4.0 + d * 14.0)
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		var c := Color("4a6e30").lerp(Color("6a7640"), clampf(far_noise.get_noise_2d(x * 2.0, z * 2.0) + 0.5, 0.0, 1.0))
		return c.darkened(0.12) if steep > 0.4 else c
	add_child(LowPoly.terrain(end.x - 420, end.x + 420, far_z - 320, far_z - 50, 42, 16, hf, cf))

	# Şehrin evleri: basamak basamak yükselen sıralar
	var walls_c := [Color("efe0c2"), Color("e3c9a0"), Color("d9b48a"), Color("f2e8d6"), Color("dcc0a8"), Color("e8d2b8")]
	for i in 150:
		var hx := rng.randf_range(-200, 200)
		var depth := rng.randf_range(6, 55)
		var hz := far_z - depth
		var ground := base_y + 1.0 + depth * 0.12
		var w := rng.randf_range(4.0, 7.0)
		var h := rng.randf_range(3.5, 7.5)
		var d := rng.randf_range(4.0, 6.5)
		var house := Node3D.new()
		house.position = Vector3(end.x + hx, ground, hz)
		house.rotation_degrees.y = [0.0, 90.0, 8.0, -6.0][i % 4]
		add_child(house)
		Props.box(house, Vector3(w, h, d), Vector3(0, h / 2.0, 0), walls_c[i % walls_c.size()])
		if i % 3 == 0:
			# Ahşap çıkma kat
			Props.box(house, Vector3(w + 0.8, 1.8, d * 0.7), Vector3(0, h + 0.9, 0), Color("8a6440"))
			Props.prism(house, Vector3(w + 1.2, 1.8, d + 0.6), Vector3(0, h + 2.7, 0), C_ROOF)
		else:
			Props.prism(house, Vector3(w + 0.6, 1.8, d + 0.6), Vector3(0, h + 0.9, 0), C_ROOF.lerp(Color("c86a45"), rng.randf()))
	# Kiliseler: kubbeli
	for i in 6:
		var cx := rng.randf_range(-180, 180)
		var cz := far_z - rng.randf_range(15, 50)
		var gy := base_y + 1.0 + (far_z - cz) * 0.12
		var ch := Vector3(end.x + cx, gy, cz)
		Props.box(self, Vector3(10, 8, 12), ch + Vector3(0, 4, 0), Color("d9a67a"))
		Props.cyl(self, 3.2, 2.0, ch + Vector3(0, 9, 0), Color("d9a67a"), Vector3.ZERO, 10)
		Props.ball(self, 3.3, ch + Vector3(0, 10, 0), Color("8e9aa3"), Vector3(1, 0.8, 1), 10)
	# Selviler
	for i in 40:
		var tx := rng.randf_range(-200, 200)
		var tz := far_z - rng.randf_range(5, 55)
		var tree := Node3D.new()
		_cypress(tree, rng.randf_range(6, 11))
		tree.position = Vector3(end.x + tx, base_y + 1.0 + (far_z - tz) * 0.12, tz)
		add_child(tree)

	# Deniz surları: tuğla bantlı taş, burçlar
	Props.box(self, Vector3(420, 9, 3), Vector3(end.x, base_y + 4.5, far_z), C_STONE)
	for band in [2.5, 6.0]:
		Props.box(self, Vector3(420.2, 0.5, 3.1), Vector3(end.x, base_y + band, far_z), C_BRICK)
	var x := -210.0
	while x <= 210.0:
		Props.box(self, Vector3(1.2, 1.2, 3.2), Vector3(end.x + x, base_y + 9.6, far_z), C_STONE)
		if int(x) % 24 == 0:
			var tower := Vector3(end.x + x, base_y, far_z)
			Props.box(self, Vector3(6, 14, 6), tower + Vector3(0, 7.0, 0), C_STONE_DARK)
			for band2 in [3.0, 7.0, 11.0]:
				Props.box(self, Vector3(6.1, 0.5, 6.1), tower + Vector3(0, band2, 0), C_BRICK)
			for cx2 in [-2.2, 0.0, 2.2]:
				Props.box(self, Vector3(1.0, 1.0, 6.2), tower + Vector3(cx2, 14.5, 0), C_STONE_DARK)
		x += 3.0

	# Ayasofya: merkezi kubbe, iki yarım kubbe, payandalar (1453'te minaresi yoktu)
	var hs := Vector3(end.x + 40, base_y + 6.0, far_z - 48)
	var ochre := Color("cc8f63")
	Props.box(self, Vector3(34, 16, 30), hs + Vector3(0, 8, 0), ochre)
	for bx in [-18.0, 18.0]:
		for bz in [-12.0, 12.0]:
			Props.box(self, Vector3(4, 20, 6), hs + Vector3(bx, 10, bz), ochre.darkened(0.08))
	Props.cyl(self, 11.5, 3.0, hs + Vector3(0, 17.5, 0), ochre, Vector3.ZERO, 16)
	Props.ball(self, 11.8, hs + Vector3(0, 19, 0), Color("8e9aa3"), Vector3(1, 0.55, 1), 16)
	for sz in [-13.0, 13.0]:
		Props.ball(self, 8.5, hs + Vector3(0, 15, sz), Color("8e9aa3"), Vector3(1, 0.5, 0.8), 12)
	for i in 12:
		var a := TAU * i / 12.0
		Props.box(self, Vector3(1.2, 1.4, 1.2), hs + Vector3(cos(a) * 11.6, 18.2, sin(a) * 11.6), ochre.darkened(0.05))

	# Galata Kulesi (bu kıyıda, solda)
	var gx := end.x - 58.0
	var gz := end.z + 6.0
	var gt := Vector3(gx, ground_h(gx, gz), gz)
	Props.cyl(self, 4.0, 32.0, gt + Vector3(0, 16, 0), C_STONE_DARK, Vector3.ZERO, 12)
	for band3 in [8.0, 20.0]:
		Props.cyl(self, 4.05, 0.6, gt + Vector3(0, band3, 0), C_STONE_DARK, Vector3.ZERO, 12)
	Props.cyl(self, 4.7, 2.0, gt + Vector3(0, 32, 0), C_STONE_DARK, Vector3.ZERO, 12)
	Props.cyl(self, 4.6, 9.0, gt + Vector3(0, 37.5, 0), Color("6d7f8f"), Vector3.ZERO, 12, 0.2)


func _build_chain_and_boat() -> void:
	# Haliç zinciri: yüzen kütükler ve halkalar
	var cp := chain_point()
	var a := Vector3(cp.x - 10, water_y, cp.z + 25)
	var b := Vector3(cp.x + 30, water_y, cp.z - 120)
	var n := 34
	for i in n:
		var t := float(i) / (n - 1)
		var p := a.lerp(b, t)
		var dir := (b - a).normalized()
		var yaw := rad_to_deg(atan2(dir.x, dir.z))
		Props.cyl(self, 0.35, 2.6, p + Vector3(0, 0.1, 0), C_LOG, Vector3(90, yaw, 0), 8)
		Props.ring(self, 0.12, 0.2, p + dir * 1.6 + Vector3(0, 0.25, 0), Color("4a4d52"), Vector3(0, yaw, 90))
	# Kayık ve kayıkçı
	boat = Node3D.new()
	add_child(boat)
	boat.add_child(LowPoly.hull([
		{"z": -2.8, "w": 0.05, "top": 0.75, "bottom": 0.35},
		{"z": -1.8, "w": 0.6, "top": 0.55, "bottom": -0.05},
		{"z": 0.5, "w": 0.75, "top": 0.5, "bottom": -0.1},
		{"z": 2.0, "w": 0.6, "top": 0.55, "bottom": -0.05},
		{"z": 2.6, "w": 0.35, "top": 0.7, "bottom": 0.2},
	], Color("6b4428"), Color("2f5fa8"), 0.4))
	Props.box(boat, Vector3(1.1, 0.06, 0.3), Vector3(0, 0.4, 0.6), Color("a07a4e"))
	var rower := Soldier.new(Color("c98a3a"), "pull", "turban")
	rower.position = Vector3(0, 0.1, 0.6)
	rower.scale = Vector3.ONE * 0.9
	boat.add_child(rower)
	for side in [-1, 1]:
		Props.cyl(boat, 0.04, 2.8, Vector3(side * 1.2, 0.3, 0.4), Color("c9a878"), Vector3(0, 0, side * 70), 4)
	boat.position = Vector3(cp.x + 60, water_y, cp.z + 12)
	boat.rotation_degrees.y = 90
