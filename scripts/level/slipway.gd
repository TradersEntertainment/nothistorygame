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
var _capstans: Array[Node3D] = []
var ship: Node3D
var boat: Node3D
var water_y := 0.0
var obstacles: Array = []      # [{s, kind: "rope"/"log"/"block", lanes: [..], node, resolved}]
var _water: MeshInstance3D
var _env: Environment
var _fog_air := {}
var _clouds: Array[Node3D] = []
var _gulls: Array = []          # [{node, center, radius, speed, phase, wings}]
var _noise := FastNoiseLite.new()
var _t := 0.0
var _tan := tan(deg_to_rad(SLOPE_DEG))
## Yüzme alanı (Bölüm 2 serbest yüzme): çarpılabilir yüzen şeyler, kayıp fes, amfora noktası
var swim_debris: Array[Node3D] = []
var fez_float: Node3D
var amphora_spot := Vector3.ZERO
var _fish: Array = []           # [{node, center, radius, speed, phase}]
var _shafts: Array[Node3D] = []
var _bob_nodes: Array = []      # [{node, base_y, phase}]


func _ready() -> void:
	Audio.voice_space("outdoor")
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
	_build_swim_scenery()


func _process(delta: float) -> void:
	_t += delta
	for cp in _capstans:
		(cp.get_node("Turn") as Node3D).rotation.y += delta * 0.55
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
	for f in _fish:
		var a: float = f["phase"] + _t * f["speed"]
		var n: Node3D = f["node"]
		n.position = f["center"] + Vector3(cos(a) * f["radius"], sin(a * 3.0) * 0.25, sin(a) * f["radius"] * 0.6)
		n.rotation.y = -a + (PI if f["speed"] < 0.0 else 0.0)
	for b in _bob_nodes:
		var bn: Node3D = b["node"]
		if is_instance_valid(bn):
			bn.position.y = b["base_y"] + sin(_t * 1.4 + b["phase"]) * 0.08
			bn.rotation.z = sin(_t * 0.9 + b["phase"]) * 0.06


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
	_env = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-34, 145, 0)
	sun.light_color = Color("ffe9c7")
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)
	SkyBody.attach(self, sun)


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
		# Kızak ekipleri (ne yaptıkları uzaktan anlaşılsın):
		#   ırgat: dört asker kolları iterek dönen makarayı çevirir, halat kızağa iner
		#   yağcı: kovadan kızak kütüklerine iç yağı atar ("yağlı kızak")
		#   gözcü: yanından geçen Tolga'ya döner, gösterip bağırır
		for i in 9:
			var s3 := 6.0 + i * 13.0
			var coat: Color = [Color("b3262d"), Color("2f5fa8"), Color("3f7a3a"), Color("c98a3a")][i % 4]
			match i % 3:
				0:
					var xz3 := _side_xz(s3, side, 3.2)
					var cap := _capstan(coat)
					_place_on_ground(cap, xz3.x, xz3.y)
					_capstans.append(cap)
					var edge := s_to_world(s3, side * (WIDTH / 2.0 + 0.3), 0.15)
					_rope_between(self, cap.global_position + Vector3(0, 0.55, 0), edge + Vector3(0, 0.3, 0))
					_rope_between(self, edge + Vector3(0, 0.3, 0), s_to_world(s3 + 11.0, side * (WIDTH / 2.0 + 0.3), 0.12))
					Props.cyl(self, 0.09, 0.7, edge + Vector3(0, 0.2, 0), Color("5f4329"), Vector3.ZERO, 6)
				1:
					var xz4 := _side_xz(s3, side, 0.9)
					var gr := Soldier.new(coat, "grease", "turban" if i % 2 == 0 else "bork")
					_place_on_ground(gr, xz4.x, xz4.y)
					gr.face_toward(s_to_world(s3 + 1.0, 0.0))
					var pail := Node3D.new()
					Props.cyl(pail, 0.22, 0.35, Vector3(0, 0.18, 0), Color("6b4a2e"), Vector3.ZERO, 8)
					Props.cyl(pail, 0.2, 0.02, Vector3(0, 0.36, 0), Color("f0dc9a"), Vector3.ZERO, 8)
					var pxz := _side_xz(s3 - 0.8, side, 1.4)
					_place_on_ground(pail, pxz.x, pxz.y)
				_:
					var xz5 := _side_xz(s3, side, 1.4)
					var sol := Soldier.new(coat, "point", "bork" if i % 2 == 0 else "turban")
					sol.rotation_degrees.y = 180.0
					_place_on_ground(sol, xz5.x, xz5.y)
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
	_build_side_dressing()


## Yamaçlar boş kalmasın: yokuş boyunca iki yanda yağ kazanları (katran kaynatan ocaklar), çuval ve sandık
## yığınları, halat kangalları, arabalar, bağlı atlar, işçi kümeleri (tek birleşik ağ örgüsü).
func _build_side_dressing() -> void:
	var d := Dressing.new(1453)
	var rng := d.rng
	var coats := [Color("b3262d"), Color("2f5fa8"), Color("3f7a3a"), Color("c98a3a"), Color("7a5232")]
	for side in [-1, 1]:
		var s := 2.0
		while s < LENGTH - 4.0:
			var dist := rng.randf_range(3.2, 12.0)
			var xz := _side_xz(s, side, dist)
			var gp := Vector3(xz.x, ground_h(xz.x, xz.y), xz.y)
			d.at(gp, rng.randf() * TAU)
			match rng.randi() % 7:
				0:
					d.hearth(Vector3.ZERO)
					for k in 2:
						d.figure(Vector3(1.2 * (k * 2 - 1), 0, 0.6), coats[rng.randi() % coats.size()], false, Color("f0ece0"), rng.randf_range(0, 360))
				1: d._c_sacks()
				2: d._c_barrels()
				3:
					d.rope_coil(Vector3.ZERO)
					d.rope_coil(Vector3(0.8, 0, 0.3))
					d.crates(Vector3(0, 0, 1.0))
				4: d.cart(Vector3.ZERO)
				5: d._c_horses()
				_:
					for k in 3:
						d.figure(Vector3(k * 0.7, 0, rng.randf_range(-0.4, 0.4)), coats[rng.randi() % coats.size()], false, Color("f0ece0"), rng.randf_range(0, 360))
			s += rng.randf_range(5.0, 9.0)
	d.build(self)


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


## Irgat: dikme makara, dört itme kolu ve kolları iterek dönen dört asker ("Turn" döner).
func _capstan(coat: Color) -> Node3D:
	var root := Node3D.new()
	Props.cyl(root, 0.5, 0.12, Vector3(0, 0.06, 0), Color("6f5a3e"), Vector3.ZERO, 10)
	var turn := Node3D.new()
	turn.name = "Turn"
	root.add_child(turn)
	Props.cyl(turn, 0.28, 1.1, Vector3(0, 0.6, 0), Color("7a5232"), Vector3.ZERO, 10)
	Props.cyl(turn, 0.3, 0.25, Vector3(0, 0.55, 0), Color("c9b48a"), Vector3.ZERO, 10)
	for k in 4:
		var a := k * PI / 2.0
		var d := Vector3(sin(a), 0, cos(a))
		var bar := Props.cyl(turn, 0.045, 1.5, d * 0.95 + Vector3(0, 1.0, 0), Color("8a6440"), Vector3.ZERO, 6)
		bar.basis = Basis(Vector3.UP.cross(d).normalized(), PI / 2.0)
		var t := Vector3(cos(a), 0, -sin(a))
		var sol := Soldier.new(coat if k % 2 == 0 else coat.darkened(0.25), "push", "bork" if k % 2 == 0 else "turban")
		sol.position = d * 1.45 - t * 0.55
		sol.rotation.y = atan2(t.x, t.z)
		sol.set_meta("no_unclip", true)
		turn.add_child(sol)
	return root


func _rope_between(parent: Node3D, a: Vector3, b: Vector3) -> void:
	var r := Props.cyl(parent, 0.03, a.distance_to(b), Vector3.ZERO, Color("c9b48a"), Vector3.ZERO, 5)
	var y := (b - a).normalized()
	var x := y.cross(Vector3.UP if absf(y.y) < 0.95 else Vector3.RIGHT).normalized()
	r.global_transform = Transform3D(Basis(x, y, x.cross(y)), (a + b) * 0.5)


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
			o["cleared"] = false
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
	# Deniz tabanı: dalışta aşağıda boşluk değil kum görünür
	var bed := Props.box(self, Vector3(900, 1.0, 900), Vector3(end.x, water_y - 7.5, end.z - 380), Color("6f7f62"))
	bed.material_override = Props.mat(Color("6f7f62"), 0.0, false, "", false)
	for i in 40:
		var r := RandomNumberGenerator.new()
		r.seed = 90 + i
		var rp := Vector3(end.x + r.randf_range(-45, 45), water_y - 7.0, end.z - r.randf_range(4, 80))
		var rock := Props.ball(self, r.randf_range(0.4, 1.3), rp, Color("5d6a55"), Vector3(1.0, 0.6, 1.2), 6)
		rock.material_override = Props.mat(Color("5d6a55"), 0.0, false, "", false)
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


# ---------------------------------------------------------------- su efektleri

## Dalış: sualtında yoğun, yeşil-mavi sis (uzaktaki her şey ve gökyüzü kaybolur).
func set_underwater(on: bool) -> void:
	if _fog_air.is_empty():
		_fog_air = {"density": _env.fog_density, "color": _env.fog_light_color, "sky": _env.fog_sky_affect}
	for sh in _shafts:
		sh.visible = on
	if on:
		_env.fog_density = 0.085
		_env.fog_light_color = Color("2a7a84")
		_env.fog_sky_affect = 1.0
	else:
		_env.fog_density = _fog_air["density"]
		_env.fog_light_color = _fog_air["color"]
		_env.fog_sky_affect = _fog_air["sky"]


func _particles(pos: Vector3, amount: int, color: Color, radius: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	var m := SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	m.radial_segments = 6
	m.rings = 3
	p.mesh = m
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	p.material_override = mat
	p.amount = amount
	p.position = pos
	add_child(p)
	return p


## Suya çarpma: yukarı fışkıran damlalar ve genişleyen köpük halkası.
func splash(pos: Vector3, big := false) -> void:
	var at := Vector3(pos.x, water_y + 0.1, pos.z)
	var drops := _particles(at, 120 if big else 70, Color("eef7f8"), 0.11 if big else 0.07)
	drops.one_shot = true
	drops.explosiveness = 0.92
	drops.lifetime = 1.6
	drops.direction = Vector3.UP
	drops.spread = 38.0
	drops.initial_velocity_min = 4.0 if big else 3.0
	drops.initial_velocity_max = 11.0 if big else 7.0
	drops.scale_amount_min = 0.5
	drops.scale_amount_max = 1.4
	drops.emitting = true
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.7
	tm.outer_radius = 1.0
	tm.rings = 24
	tm.ring_segments = 4
	ring.mesh = tm
	var rm := StandardMaterial3D.new()
	rm.albedo_color = Color(0.95, 0.98, 1.0, 0.85)
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = rm
	ring.position = at + Vector3(0, 0.05, 0)
	ring.scale = Vector3(1, 0.15, 1)
	add_child(ring)
	var k := 3.0 if big else 1.0
	var tw := create_tween().set_parallel()
	tw.tween_property(ring, "scale", Vector3(5.0 * k, 0.15, 5.0 * k), 2.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(rm, "albedo_color:a", 0.0, 2.2)
	tw.chain().tween_callback(func():
		ring.queue_free()
		drops.queue_free())


## Sualtında yükselen kabarcıklar.
func bubbles(pos: Vector3, seconds := 1.2) -> void:
	var b := _particles(pos, 30, Color(0.8, 0.95, 1.0), 0.05)
	# Yüzeye kadar (~1.5 m) yükselip söner: sudan dışarı taşmaz
	b.lifetime = 1.3
	b.direction = Vector3.UP
	b.spread = 20.0
	b.gravity = Vector3(0, 0.6, 0)
	b.initial_velocity_min = 0.3
	b.initial_velocity_max = 0.8
	b.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	b.emission_sphere_radius = 0.5
	b.emitting = true
	get_tree().create_timer(seconds).timeout.connect(func(): b.emitting = false)
	get_tree().create_timer(seconds + 1.6).timeout.connect(b.queue_free)


# ---------------------------------------------------------------- yüzme alanı

## Yüzme alanı: sığlık, yosun ormanı, deniz çayırı, batık kadırga, amforalar, balık sürüleri, ışık hüzmeleri
## (sualtı); demirli Osmanlı kadırgaları, yüzen kütük ve fıçılar, kayıp bir fes (yüzey).
func _build_swim_scenery() -> void:
	var end := end_point()
	var start := swim_start()
	var shore := shore_point()
	var chain := chain_point()
	var bed_y := water_y - 4.4
	var rng := RandomNumberGenerator.new()
	rng.seed = 1204
	# Sığlık: yüzme yollarının altı; dalınca tabanı görürsün
	var shoal := Props.box(self, Vector3(110, 1.0, 80), Vector3(end.x - 12, bed_y - 0.5, end.z - 38), Color("8a946a"))
	shoal.material_override = Props.mat(Color("8a946a"), 0.0, false, "", false)
	var area := Rect2(end.x - 62, end.z - 76, 104, 70)
	# Yosun ormanı: uzun ince yapraklar, hafif eğik
	var blade := Scenery.merged([[Scenery._boxm(Vector3(0.14, 1.0, 0.03)), Transform3D(), Color.WHITE],
		[Scenery._boxm(Vector3(0.03, 1.0, 0.12)), _td(Vector3(0.03, -0.1, 0)), Color.WHITE]])
	var xf: Array = []
	var cols: Array = []
	for i in 520:
		var x := rng.randf_range(area.position.x, area.end.x)
		var z := rng.randf_range(area.position.y, area.end.y)
		if Vector2(x - start.x, z - start.z).length() < 2.5:
			continue
		var h := rng.randf_range(1.2, 3.6)
		xf.append(_td(Vector3(x, bed_y + h * 0.5, z), Vector3(rng.randf_range(-8, 8), rng.randf() * 360.0, rng.randf_range(-8, 8)), Vector3(1, h, 1)))
		cols.append(Color("3f7a3a").lerp(Color("8aa83a"), rng.randf()))
	Scenery.scatter(self, blade, xf, cols)
	# Deniz çayırı ve taşlar
	var tuft := Scenery.merged([[Scenery._boxm(Vector3(0.5, 0.35, 0.02)), Transform3D(), Color.WHITE],
		[Scenery._boxm(Vector3(0.02, 0.35, 0.5)), Transform3D(), Color.WHITE]])
	xf = []
	cols = []
	for i in 420:
		var x := rng.randf_range(area.position.x, area.end.x)
		var z := rng.randf_range(area.position.y, area.end.y)
		xf.append(_td(Vector3(x, bed_y + 0.17, z), Vector3(0, rng.randf() * 360.0, 0), Vector3.ONE * rng.randf_range(0.7, 1.6)))
		cols.append(Color("6a9a4a").lerp(Color("b0a86a"), rng.randf()))
	Scenery.scatter(self, tuft, xf, cols)
	var stone := Scenery._ball(1.0)
	xf = []
	cols = []
	for i in 90:
		var x := rng.randf_range(area.position.x, area.end.x)
		var z := rng.randf_range(area.position.y, area.end.y)
		var r := rng.randf_range(0.25, 0.9)
		xf.append(_td(Vector3(x, bed_y + r * 0.3, z), Vector3(0, rng.randf() * 360.0, 0), Vector3(r * 1.3, r * 0.6, r)))
		cols.append(Color("6d7466").lerp(Color("a39a80"), rng.randf()))
	Scenery.scatter(self, stone, xf, cols)
	# Batık kadırga: zincir yolunun altında, yan yatmış
	var wreck_at := start.lerp(chain, 0.62) + Vector3(-4.0, 0, 3.0)
	var wreck := Props.model(self, "galley", Vector3(wreck_at.x, bed_y + 0.2, wreck_at.z), 35.0, 1.3)
	if wreck:
		wreck.rotation_degrees.z = 28.0
	else:
		Props.box(self, Vector3(3.0, 1.2, 10.0), Vector3(wreck_at.x, bed_y + 0.4, wreck_at.z), Color("4a3422"), Vector3(0, 35, 28))
	# Amforalar: enkazın çevresine dağılmış; biri yüzme yolunun hemen altında
	var amph := Scenery.merged([
		[Scenery._cyl(0.18, 0.5, 0.12, 8), Transform3D(), Color("b86a3a")],
		[Scenery._ball(0.2), _td(Vector3(0, -0.2, 0)), Color("b86a3a")],
		[Scenery._cyl(0.06, 0.25, 0.07, 6), _td(Vector3(0, 0.36, 0)), Color("a85e32")],
	])
	xf = []
	for i in 26:
		var p := wreck_at + Vector3(rng.randf_range(-7, 7), 0, rng.randf_range(-7, 7))
		xf.append(_td(Vector3(p.x, bed_y + 0.2, p.z), Vector3(rng.randf_range(40, 90), rng.randf() * 360.0, 0)))
	amphora_spot = start.lerp(chain, 0.38) + Vector3(1.5, 0, 0)
	amphora_spot.y = bed_y + 1.6
	xf.append(_td(Vector3(amphora_spot.x, bed_y + 0.7, amphora_spot.z), Vector3(0, 30, 0), Vector3.ONE * 1.6))
	Scenery.scatter(self, amph, xf)
	for i in 5:
		var bp := wreck_at + Vector3(rng.randf_range(-6, 6), 0, rng.randf_range(-6, 6))
		var br := Props.model(self, "barrel", Vector3(bp.x, bed_y, bp.z), rng.randf() * 360.0)
		if br:
			br.rotation_degrees.x = 90.0
	# Balık sürüleri
	var fish_mat := Props.mat(Color("e8a040"), 0.0, false, "", false)
	var silver := Props.mat(Color("b8c8d0"), 0.0, false, "", false)
	for sidx in 9:
		var school := Node3D.new()
		add_child(school)
		var n := rng.randi_range(6, 11)
		for k in n:
			var f := MeshInstance3D.new()
			var sm := SphereMesh.new()
			sm.radius = 0.09
			sm.height = 0.18
			sm.radial_segments = 6
			sm.rings = 3
			f.mesh = sm
			f.material_override = fish_mat if sidx % 3 == 0 else silver
			f.scale = Vector3(0.5, 0.8, 2.0)
			f.position = Vector3(rng.randf_range(-0.9, 0.9), rng.randf_range(-0.4, 0.4), rng.randf_range(-0.9, 0.9))
			var tail := MeshInstance3D.new()
			var tb := BoxMesh.new()
			tb.size = Vector3(0.01, 0.12, 0.08)
			tail.mesh = tb
			tail.material_override = f.material_override
			tail.position = Vector3(0, 0, 0.22)
			f.add_child(tail)
			school.add_child(f)
		var c := start.lerp(chain if sidx % 2 == 0 else shore, rng.randf_range(0.15, 0.95)) + Vector3(rng.randf_range(-6, 6), 0, rng.randf_range(-6, 6))
		c.y = water_y - rng.randf_range(1.6, 3.2)
		_fish.append({"node": school, "center": c, "radius": rng.randf_range(1.5, 4.0),
			"speed": rng.randf_range(0.25, 0.6) * (1.0 if sidx % 2 == 0 else -1.0), "phase": rng.randf() * TAU})
	# Işık hüzmeleri (yalnız sualtındayken görünür)
	var shaft_mat := StandardMaterial3D.new()
	shaft_mat.albedo_color = Color(0.85, 1.0, 0.9, 0.06)
	shaft_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shaft_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shaft_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	shaft_mat.no_depth_test = false
	for i in 26:
		var mi := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = rng.randf_range(0.4, 0.9)
		cm.bottom_radius = cm.top_radius * 1.8
		cm.height = 4.2
		cm.radial_segments = 6
		mi.mesh = cm
		mi.material_override = shaft_mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var p := start.lerp(chain if i % 2 == 0 else shore, rng.randf()) + Vector3(rng.randf_range(-9, 9), 0, rng.randf_range(-9, 9))
		mi.position = Vector3(p.x + 0.6, water_y - 2.1, p.z)
		mi.rotation_degrees = Vector3(0, 0, 12)
		mi.visible = false
		add_child(mi)
		_shafts.append(mi)
	# Demirli Osmanlı kadırgaları (Haliç'in açığında)
	for gp in [Vector3(-70, 0, -48), Vector3(-92, 0, -70), Vector3(-50, 0, -88), Vector3(30, 0, -64), Vector3(52, 0, -86)]:
		_anchored_galley(end + gp, rng.randf_range(-40, 40))
	# Yüzen enkaz: iki yolun üstünde, bazısı yolun tam ortasında
	for spec in [[shore, 0.42, 1.2], [shore, 0.7, -1.4], [chain, 0.18, -1.6], [chain, 0.3, 1.4], [chain, 0.5, -0.8],
			[chain, 0.72, 1.8], [chain, 0.86, -1.2]]:
		var goal: Vector3 = spec[0]
		var side := (goal - start).cross(Vector3.UP).normalized()
		var p: Vector3 = start.lerp(goal, spec[1]) + side * float(spec[2])
		var node := Node3D.new()
		node.position = Vector3(p.x, water_y + 0.05, p.z)
		add_child(node)
		if swim_debris.size() % 2 == 0:
			Props.cyl(node, 0.3, 2.6, Vector3.ZERO, C_LOG, Vector3(90, rng.randf() * 180.0, 0), 8)
		else:
			var bm := Props.model(node, "barrel", Vector3(0, -0.2, 0), rng.randf() * 360.0)
			if bm:
				bm.rotation_degrees.x = 80.0
			else:
				Props.cyl(node, 0.4, 0.9, Vector3.ZERO, Color("7a5232"), Vector3(90, 0, 0), 10)
		swim_debris.append(node)
		_bob_nodes.append({"node": node, "base_y": node.position.y, "phase": rng.randf() * TAU})
	# Kayıp fes: başlangıçtan biraz sapınca bulunur
	fez_float = Node3D.new()
	var fz := start + Vector3(-8.0, 0, -9.0)
	fez_float.position = Vector3(fz.x, water_y + 0.08, fz.z)
	add_child(fez_float)
	Props.cyl(fez_float, 0.16, 0.24, Vector3(0, 0.05, 0), Color("b3262d"), Vector3(0, 0, 70), 10, 0.13)
	Props.cyl(fez_float, 0.012, 0.18, Vector3(0.05, 0.14, 0), Color("1a1a1a"), Vector3(0, 0, 20), 4)
	_bob_nodes.append({"node": fez_float, "base_y": fez_float.position.y, "phase": 1.3})
	# Suya yakın uçan birkaç martı daha
	for i in 6:
		_add_gull(start + Vector3(rng.randf_range(-40, 20), rng.randf_range(4, 9), rng.randf_range(-50, -5)), rng)


func _anchored_galley(pos: Vector3, yaw: float) -> void:
	var g := Node3D.new()
	g.position = Vector3(pos.x, water_y - 0.4, pos.z)
	g.rotation_degrees.y = yaw
	add_child(g)
	g.add_child(LowPoly.hull([
		{"z": -9.0, "w": 0.06, "top": 2.3, "bottom": 1.4},
		{"z": -6.0, "w": 1.3, "top": 1.9, "bottom": 0.3},
		{"z": 0.0, "w": 1.7, "top": 1.85, "bottom": 0.2},
		{"z": 5.0, "w": 1.4, "top": 2.0, "bottom": 0.4},
		{"z": 7.0, "w": 0.8, "top": 2.7, "bottom": 1.0},
	], Color("5b3a22"), Color("7e2420"), 1.78))
	Props.box(g, Vector3(2.8, 0.1, 11.0), Vector3(0, 1.8, -0.5), Color("b08a5c"))
	Props.cyl(g, 0.14, 9.0, Vector3(0, 6.2, -1.5), Color("6b4428"), Vector3.ZERO, 6)
	Props.cyl(g, 0.22, 7.5, Vector3(0, 8.0, -1.6), Color("efe6cf"), Vector3(55, 0, 0), 7)
	Props.box(g, Vector3(0.05, 0.7, 1.3), Vector3(0, 10.6, -1.3), Color("b3262d"))
	for i in 8:
		for side in [-1, 1]:
			Props.cyl(g, 0.04, 3.0, Vector3(side * 2.2, 1.0, -4.0 + i * 1.1), Color("c9a878"), Vector3(0, 0, side * 70), 4)
	_bob_nodes.append({"node": g, "base_y": g.position.y, "phase": pos.x * 0.1})


func _add_gull(center: Vector3, rng: RandomNumberGenerator) -> void:
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
	_gulls.append({"node": g, "wings": wings, "center": center, "radius": rng.randf_range(5, 12),
		"speed": rng.randf_range(0.3, 0.6), "phase": rng.randf() * TAU})


## Ok uyarısı: suda kırmızımsı, büyüyen bir halka. Düşüş anında Chapter2 arrow_fall çağırır.
func arrow_warning(pos: Vector3, seconds: float) -> void:
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.9
	tm.outer_radius = 1.1
	tm.rings = 20
	tm.ring_segments = 4
	ring.mesh = tm
	var rm := StandardMaterial3D.new()
	rm.albedo_color = Color(1.0, 0.35, 0.25, 0.8)
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = rm
	ring.position = Vector3(pos.x, water_y + 0.06, pos.z)
	ring.scale = Vector3(1.4, 0.15, 1.4)
	add_child(ring)
	var tw := create_tween()
	tw.tween_property(ring, "scale", Vector3(0.35, 0.15, 0.35), seconds)
	tw.tween_callback(ring.queue_free)


## Ok suya saplanır: kısa bir süre yüzeyde kalır.
func arrow_fall(pos: Vector3) -> void:
	var a := Node3D.new()
	a.position = Vector3(pos.x, water_y + 6.0, pos.z)
	add_child(a)
	Props.cyl(a, 0.025, 0.9, Vector3.ZERO, Color("6b4428"), Vector3(12, 0, 8), 4)
	Props.box(a, Vector3(0.12, 0.2, 0.01), Vector3(0, 0.42, 0), Color("efe6cf"))
	var tw := create_tween()
	tw.tween_property(a, "position:y", water_y + 0.2, 0.22).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): splash(pos))
	tw.tween_interval(2.5)
	tw.tween_property(a, "position:y", water_y - 1.0, 1.0)
	tw.tween_callback(a.queue_free)


## Scenery._t, açıları derece olarak alır.
static func _td(pos: Vector3, deg := Vector3.ZERO, scl := Vector3.ONE) -> Transform3D:
	return Scenery._t(pos, deg * (PI / 180.0), scl)
