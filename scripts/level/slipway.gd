class_name Slipway
extends Node3D
## Bölüm 2 sahnesi: 22 Nisan 1453 sabahı, Galata'nın arkasındaki tepelerden Haliç'e
## inen yağlı kızaklar. Yokuş, kadırga, askerler, Haliç, karşı kıyıda surlar ve
## Ayasofya (1453'te minaresi yoktu), Galata Kulesi ve Haliç zinciri.
##
## Yokuş "track" düğümünün içinde kuruludur: track'in yerel -Z yönü yokuş aşağıdır.
## s: yokuş boyunca metre (0 = tepe), x: şerit ekseni.

const SLOPE_DEG := 7.0
const LENGTH := 130.0
const WIDTH := 9.0
const LANES := [-2.4, 0.0, 2.4]

const C_TRACK := Color("7a5b3c")
const C_LOG := Color("8a6440")
const C_GRASS := Color("6f9a4a")
const C_SAND := Color("d9c28f")
const C_WATER := Color("15445a")
const C_STONE := Color("c9b99a")
const C_STONE_DARK := Color("a8977a")

var track: Node3D
var ship: Node3D
var boat: Node3D
var water_y := 0.0
var obstacles: Array = []      # [{s, kind: "rope"/"log"/"block", lanes: [..], node, resolved}]
var _water_mat: StandardMaterial3D
var _t := 0.0


func _ready() -> void:
	_build_sky()
	track = Node3D.new()
	track.rotation_degrees.x = -SLOPE_DEG
	add_child(track)
	_build_slope()
	_build_sides()
	_build_ship()
	_build_obstacles()
	_build_bottom()
	_build_far_shore()
	_build_chain_and_boat()


func _process(delta: float) -> void:
	_t += delta
	if _water_mat:
		_water_mat.uv1_offset = Vector3(_t * 0.01, 0, _t * 0.006)


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


## Yüzme bölümünün noktaları (dünya).
func swim_start() -> Vector3:
	return end_point() + Vector3(0, 0, -8)


func shore_point() -> Vector3:
	return end_point() + Vector3(14, 0, -4)


func chain_point() -> Vector3:
	return end_point() + Vector3(-34, 0, -30)


# ---------------------------------------------------------------- gökyüzü

func _build_sky() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3f86c9")
	sm.sky_horizon_color = Color("bcd6e6")
	sm.sky_energy_multiplier = 0.9
	sm.ground_horizon_color = Color("e8cfa8")
	sm.ground_bottom_color = Color("7d8a6a")
	sm.sun_angle_max = 20.0
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_light_color = Color("c9d6e0")
	e.fog_density = 0.0016
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.4
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, 150, 0)
	sun.light_color = Color("fff1d6")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)


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
	# Yağ lekeleri (parlak, koyu şeritler)
	for i in 14:
		var ls := 8.0 + i * 8.5
		var lx: float = LANES[i % 3]
		Props.box(track, Vector3(1.6, 0.02, 3.0), Vector3(lx, 0.2, -ls), Color(0.18, 0.12, 0.05, 0.55))
	# Kızağın kenar kirişleri
	for side in [-1, 1]:
		Props.box(track, Vector3(0.3, 0.3, LENGTH + 6), Vector3(side * (WIDTH / 2.0 - 0.15), 0.15, -LENGTH / 2.0 + 2), Color("5f4329"))


func _build_sides() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 22041453
	for side in [-1, 1]:
		# Çimenli yamaçlar
		var g := Props.solid(track, Vector3(40, 1.0, LENGTH + 30), Vector3(side * (WIDTH / 2.0 + 20), -0.7, -LENGTH / 2.0), C_GRASS)
		Props.set_pattern(g, C_GRASS, "wall")
		# Selviler
		for i in 22:
			var s := rng.randf_range(-5, LENGTH - 6)
			var x: float = side * rng.randf_range(WIDTH / 2.0 + 4, WIDTH / 2.0 + 30)
			_cypress(track, Vector3(x, -0.2, -s), rng.randf_range(3.5, 6.5))
		# Çadırlar
		for i in 6:
			var s2 := 10.0 + i * 20.0 + rng.randf_range(-4, 4)
			var x2: float = side * rng.randf_range(WIDTH / 2.0 + 7, WIDTH / 2.0 + 14)
			_tent(track, Vector3(x2, -0.2, -s2), rng.randf() > 0.5)
		# Halat çeken askerler
		for i in 9:
			var s3 := 6.0 + i * 13.0
			var coat: Color = [Color("b3262d"), Color("2f5fa8"), Color("3f7a3a"), Color("c98a3a")][i % 4]
			var sol := Soldier.new(coat, "pull" if i % 3 != 2 else "point", "bork" if i % 2 == 0 else "turban")
			sol.position = Vector3(side * (WIDTH / 2.0 + 1.4), -0.2, -s3)
			sol.rotation_degrees.y = 180.0 if side < 0 else 180.0
			track.add_child(sol)
			if i % 3 != 2:
				Props.cyl(track, 0.025, 3.0, Vector3(side * (WIDTH / 2.0 + 1.0), 0.9, -s3 + 1.4), Color("c9b48a"), Vector3(70, 0, side * 10), 4)


func _cypress(parent: Node3D, pos: Vector3, h: float) -> void:
	Props.cyl(parent, 0.12, 0.8, pos + Vector3(0, 0.4, 0), Color("5a3a24"), Vector3.ZERO, 6)
	Props.cyl(parent, 0.55, h, pos + Vector3(0, 0.7 + h / 2.0, 0), Color("2f5a2c"), Vector3.ZERO, 7, 0.05)


func _tent(parent: Node3D, pos: Vector3, red: bool) -> void:
	var c := Color("f1e9d6")
	Props.prism(parent, Vector3(3.0, 2.2, 3.6), pos + Vector3(0, 1.1, 0), c)
	if red:
		Props.prism(parent, Vector3(3.05, 0.5, 3.65), pos + Vector3(0, 2.0, 0), Color("b3262d"))
	Props.cyl(parent, 0.04, 1.0, pos + Vector3(0, 2.6, 0), Color("5a3a24"), Vector3.ZERO, 4)
	Props.box(parent, Vector3(0.5, 0.3, 0.02), pos + Vector3(0.25, 2.95, 0), Color("b3262d"))


# ---------------------------------------------------------------- kadırga

func _build_ship() -> void:
	ship = Node3D.new()
	track.add_child(ship)
	var hull := Color("5b3a22")
	var deck := Color("a07a4e")
	# Gövde (kıç arkada, pruva yokuş aşağı bakar)
	Props.box(ship, Vector3(3.0, 1.4, 13.0), Vector3(0, 0.9, 0), hull)
	Props.prism(ship, Vector3(3.0, 3.4, 1.4), Vector3(0, 0.9, -8.2), hull, Vector3(-90, 0, 0))
	Props.box(ship, Vector3(3.2, 0.12, 13.2), Vector3(0, 1.62, 0), deck)
	Props.box(ship, Vector3(3.0, 1.0, 2.4), Vector3(0, 2.1, 5.4), hull)
	Props.box(ship, Vector3(3.3, 0.18, 13.4), Vector3(0, 1.1, 0), Color("c9a24a"))
	# Kürekler
	for i in 9:
		for side in [-1, 1]:
			Props.cyl(ship, 0.04, 3.2, Vector3(side * 2.4, 0.8, -4.5 + i * 1.1), Color("c9a878"), Vector3(0, 0, side * 70), 4)
	# Direk, çubuk (latin yelkeni sarılı), bayrak
	Props.cyl(ship, 0.14, 9.0, Vector3(0, 6.0, -1.5), Color("6b4428"), Vector3.ZERO, 6)
	Props.cyl(ship, 0.08, 10.0, Vector3(0, 8.2, -1.8), Color("6b4428"), Vector3(55, 0, 0), 6)
	Props.cyl(ship, 0.22, 7.5, Vector3(0, 8.0, -1.6), Color("efe6cf"), Vector3(55, 0, 0), 6)
	Props.box(ship, Vector3(0.05, 0.6, 1.1), Vector3(0, 10.6, -1.9), Color("b3262d"))
	# Kızak kütükleri üzerinde
	for i in 4:
		Props.cyl(ship, 0.2, 4.0, Vector3(0, 0.2, -4.5 + i * 3.0), C_LOG, Vector3(0, 0, 90), 8)
	# Güvertede şaşkın bir tayfa
	var crew := Soldier.new(Color("2f5fa8"), "point", "turban")
	crew.position = Vector3(0.6, 1.68, -4.0)
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
	water_y = end.y - 0.8
	# Kum şeridi
	var sand := Props.solid(self, Vector3(80, 1.0, 10), Vector3(end.x, water_y - 0.3, end.z + 2), C_SAND)
	Props.set_pattern(sand, C_SAND, "concrete")
	# Su
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(700, 700)
	mi.mesh = pm
	_water_mat = StandardMaterial3D.new()
	_water_mat.albedo_color = C_WATER
	_water_mat.albedo_texture = Props._noise("wall")
	_water_mat.uv1_scale = Vector3(40, 40, 40)
	_water_mat.roughness = 0.7
	_water_mat.metallic_specular = 0.3
	_water_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	_water_mat.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	mi.material_override = _water_mat
	mi.position = Vector3(end.x, water_y, end.z - 300)
	add_child(mi)
	# Kıyıda askerler ve fıçılar (kıyı yolu için)
	var sp := shore_point()
	for i in 3:
		Props.cyl(self, 0.35, 0.8, sp + Vector3(-1.5 + i * 0.8, water_y - sp.y + 0.2, 2.5), Color("7a5232"), Vector3.ZERO, 8)
	for i in 2:
		var sol := Soldier.new(Color("b3262d") if i == 0 else Color("2f5fa8"), "stand", "bork")
		sol.position = sp + Vector3(1.5 + i * 1.2, water_y - sp.y + 0.2, 1.0)
		sol.rotation_degrees.y = 150
		add_child(sol)


func _build_far_shore() -> void:
	var end := end_point()
	var base_y := water_y
	var far_z := end.z - 150.0
	# Karşı kıyı zemini
	Props.box(self, Vector3(500, 6, 60), Vector3(end.x, base_y - 2.0, far_z - 28), C_STONE_DARK)
	# Deniz surları ve kuleler
	Props.box(self, Vector3(360, 9, 3), Vector3(end.x, base_y + 4.5, far_z), C_STONE)
	var x := -180.0
	while x <= 180.0:
		Props.box(self, Vector3(1.2, 1.2, 3.2), Vector3(end.x + x, base_y + 9.6, far_z), C_STONE)
		if int(x) % 24 == 0:
			Props.box(self, Vector3(6, 14, 6), Vector3(end.x + x, base_y + 7.0, far_z), C_STONE_DARK)
		x += 3.0
	# Şehrin evleri
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	for i in 70:
		var hx := rng.randf_range(-170, 170)
		var hz := far_z - rng.randf_range(6, 50)
		var h := rng.randf_range(4, 9)
		var c: Color = [Color("e7d3b0"), Color("d9b98f"), Color("c9a98a"), Color("efe3cc")][i % 4]
		Props.box(self, Vector3(6, h, 6), Vector3(end.x + hx, base_y + h / 2.0 + 1.0, hz), c)
		Props.prism(self, Vector3(6.4, 2.2, 6.4), Vector3(end.x + hx, base_y + h + 2.1, hz), Color("b0553a"))
	# Ayasofya: büyük kubbe (1453'te minaresi yoktu)
	var hs := Vector3(end.x + 40, base_y, far_z - 45)
	Props.box(self, Vector3(34, 16, 30), hs + Vector3(0, 9, 0), Color("d99a6c"))
	Props.ball(self, 13.0, hs + Vector3(0, 18, 0), Color("b8a38a"), Vector3(1, 0.62, 1), 14)
	Props.ball(self, 8.0, hs + Vector3(-15, 15, 0), Color("b8a38a"), Vector3(1, 0.5, 1), 12)
	Props.ball(self, 8.0, hs + Vector3(15, 15, 0), Color("b8a38a"), Vector3(1, 0.5, 1), 12)
	# Galata Kulesi (bu kıyıda, solda)
	var gt := end + Vector3(-70, water_y - end.y, 20)
	Props.cyl(self, 4.0, 30.0, gt + Vector3(0, 15, 0), C_STONE, Vector3.ZERO, 12)
	Props.cyl(self, 4.6, 2.0, gt + Vector3(0, 30, 0), C_STONE_DARK, Vector3.ZERO, 12)
	Props.cyl(self, 4.5, 8.0, gt + Vector3(0, 35, 0), Color("6d7f8f"), Vector3.ZERO, 12, 0.2)


func _build_chain_and_boat() -> void:
	# Haliç zinciri: yüzen kütükler ve halkalar, soldan karşı kıyıya
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
	# Kayık ve kayıkçı (zincir yolunda yan taraftan geçer)
	boat = Node3D.new()
	add_child(boat)
	Props.box(boat, Vector3(1.4, 0.6, 5.0), Vector3(0, 0.1, 0), Color("6b4428"))
	Props.prism(boat, Vector3(1.4, 1.4, 0.6), Vector3(0, 0.1, -2.9), Color("6b4428"), Vector3(-90, 0, 0))
	Props.box(boat, Vector3(1.2, 0.1, 4.6), Vector3(0, 0.38, 0), Color("a07a4e"))
	var rower := Soldier.new(Color("c98a3a"), "pull", "turban")
	rower.position = Vector3(0, 0.3, 0.6)
	rower.scale = Vector3.ONE * 0.9
	boat.add_child(rower)
	for side in [-1, 1]:
		Props.cyl(boat, 0.04, 2.8, Vector3(side * 1.2, 0.3, 0.4), Color("c9a878"), Vector3(0, 0, side * 70), 4)
	boat.position = Vector3(cp.x + 60, water_y, cp.z + 12)
	boat.rotation_degrees.y = 90
