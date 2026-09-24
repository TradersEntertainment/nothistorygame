class_name Galata
extends Node3D
## Bölüm 10G: Galata. Ceneviz'in tarafsız mahallesi: rıhtım, dar sokak, iki tarafa da mal satan tezgâhlar,
## limanda Venedik kadırgası, tepede Galata Kulesi. Haliç'in karşısında surlar ve kubbeler (ufuk boş kalmaz).
## Rıhtım z = 0 çizgisidir; su +z, mahalle −z tarafında.

const WATER_Y := -1.2
const SPAWN := Vector3(-22.0, 0.0, -4.0)
const FISH := Vector3(-14.0, 0.0, -2.2)
const WINE := Vector3(-4.0, 0.0, -9.6)
const NOTARY := Vector3(6.0, 0.0, -10.0)
const DOUBLE := Vector3(-8.0, 0.0, -2.0)
const GANGWAY := Vector3(17.0, 0.0, 0.6)
const SHIP_START := Vector3(19.0, WATER_Y, 7.0)
const FATIH_POINT := Vector3(-60.0, 0.0, 34.0)
const TOWER := Vector3(8.0, 0.0, -58.0)
const ALLEY_X0 := 4.0
const ALLEY_X1 := 12.0

var ship: Node3D
var npcs: Dictionary = {}
var fatih: Person
var lights: Array = []
var _t := 0.0


func _ready() -> void:
	_build_sky()
	_build_ground()
	_build_water()
	_build_houses()
	_build_tower()
	_build_tower_climb()
	_build_backstreets()
	_build_stalls()
	_build_ship()
	_build_far_shore()
	_build_people()
	Dressing.auto(self, {"style": "galata", "seed": 1267, "rect": Rect2(-43, -69, 86, 69), "y_max": 3.0, "walkers": 9, "edge_gap": 2.4, "edge_chance": 0.9, "open_clear": 3.0, "open_gap": 7.0, "open_chance": 0.8,
		"reserved": [Rect2(14.0, -2.0, 7.0, 4.0), Rect2(ALLEY_X0, -30.0, ALLEY_X1 - ALLEY_X0, 6.0), Rect2(TOWER.x - 7.0, TOWER.z - 7.0, 14.0, 14.0)],
		"people": GAL_PEOPLE})


const GAL_PEOPLE := [
	{"coat": Color("7a5a3a"), "pants": Color("3a3a3a"), "mustache": true},
	{"coat": Color("5a6a4a"), "pants": Color("3a3a3a"), "hat": "plume"},
	{"coat": Color("8a4a3a"), "pants": Color("3a3a3a"), "hat": "turban", "mustache": true},
	{"coat": Color("4a5a7a"), "pants": Color("3a3a3a"), "skirt": true, "hair": Color("5a3a1e")},
	{"coat": Color("6a2a3a"), "pants": Color("2a2a2a"), "beard": true, "hat": "plume", "skin": Color("e8b894")},
	{"coat": Color("d8c8a8"), "pants": Color("5a4028"), "apron": Color("f0e8d8"), "mustache": true},
]


func _process(delta: float) -> void:
	_t += delta
	if ship:
		ship.rotation.z = sin(_t * 0.8) * 0.015
	Night.flicker(lights, _t)


func _build_sky() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("4a86c8")
	sm.sky_horizon_color = Color("d8e4ea")
	sm.ground_horizon_color = Color("b8b0a0")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.5
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.82
	e.fog_enabled = true
	e.fog_light_color = Color("b8c8d4")
	e.fog_density = 0.004
	e.fog_sky_affect = 0.0
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -30, 0)
	sun.light_color = Color("ffe8c8")
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)
	SkyBody.attach(self, sun)


func _build_ground() -> void:
	# Rıhtım ve sokak: arnavut kaldırımı; mahalle hafifçe yokuş (basamaklarla)
	Props.set_pattern(Props.solid(self, Vector3(90, 0.4, 30), Vector3(0, -0.2, -13.0), Color.WHITE), Color("b8aa94"), "cobble")
	# Rıhtım duvarı
	Props.set_pattern(Props.solid(self, Vector3(90, 1.6, 1.2), Vector3(0, -0.8, 0.6), Color.WHITE), Color("a89880"), "ashlar")
	for x in range(-40, 41, 8):
		Props.cyl(self, 0.22, 0.7, Vector3(x, 0.35, 0.9), Color("5a4a3a"), Vector3.ZERO, 8)
	# Görünmez duvarlar: rıhtımdan düşülmesin, sokağın sonu kapalı
	for spec in [[Vector3(90, 3, 0.3), Vector3(0, 1.5, 1.3)], [Vector3(0.3, 3, 30), Vector3(-44, 1.5, -13)], [Vector3(0.3, 3, 30), Vector3(44, 1.5, -13)]]:
		var w := Props.solid(self, spec[0], spec[1], Color(0, 0, 0, 0))
		w.get_child(0).visible = false


func _build_water() -> void:
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(700, 500)
	pm.subdivide_width = 100
	pm.subdivide_depth = 80
	w.mesh = pm
	var sh := ShaderMaterial.new()
	sh.shader = load("res://assets/shaders/water.gdshader")
	sh.set_shader_parameter("shallow_color", Color(0.12, 0.3, 0.38))
	sh.set_shader_parameter("deep_color", Color(0.05, 0.14, 0.22))
	sh.set_shader_parameter("foam_color", Color(0.75, 0.8, 0.82))
	sh.set_shader_parameter("wave_height", 0.15)
	sh.set_shader_parameter("shore_z", 1.4)
	sh.set_shader_parameter("foam_width", 1.0)
	w.material_override = sh
	w.position = Vector3(0, WATER_Y, 250)
	add_child(w)


## Ceneviz evleri: sıvalı, ahşap cumbalı, kiremit çatılı; iki sıra (sokağın iki yanı).
func _build_houses() -> void:
	var cols := [Color("e8d8b8"), Color("d8b890"), Color("c8a888"), Color("e0c8a8"), Color("d0b8a0")]
	var rng := RandomNumberGenerator.new()
	rng.seed = 1267
	for row in 2:
		var z := -13.5 if row == 0 else -24.0
		var x := -42.0
		var i := 0
		while x < 42.0:
			var w := rng.randf_range(5.0, 7.5)
			var h := rng.randf_range(6.0, 10.0) + row * 3.0
			var c: Color = cols[i % cols.size()]
			# Kuleye çıkan ara sokak (x = 5 .. 11) boş kalır
			if x < ALLEY_X1 and x + w > ALLEY_X0:
				x += w
				i += 1
				continue
			var p := Vector3(x + w * 0.5, h * 0.5 + row * 1.2, z - 3.0)
			Props.set_pattern(Props.solid(self, Vector3(w - 0.2, h, 6.0), p, Color.WHITE), c, "plaster")
			var roof := Props.prism(self, Vector3(w + 0.3, 1.6, 6.6), p + Vector3(0, h * 0.5 + 0.8, 0), Color("a8483a"))
			Props.set_pattern(roof, Color("b85a44"), "tiles")
			for k in int(w / 1.8):
				for fl in int(h / 3.2):
					Props.box(self, Vector3(0.8, 1.1, 0.06), Vector3(x + 1.2 + k * 1.8, 2.0 + fl * 3.1 + row * 1.2, z + 0.02), Color("3a4a5a"))
					Props.box(self, Vector3(0.95, 0.08, 0.1), Vector3(x + 1.2 + k * 1.8, 1.4 + fl * 3.1 + row * 1.2, z + 0.06), Color("8a6a4a"))
			if row == 0 and i % 3 == 1:
				# Cumba
				Props.box(self, Vector3(2.4, 2.2, 1.0), Vector3(x + w * 0.5, 5.2, z + 0.5), c.darkened(0.1))
			x += w
			i += 1
	# Ceneviz bayrakları (beyaz üstüne kırmızı haç)
	for x in [-30.0, -6.0, 18.0]:
		Props.cyl(self, 0.05, 4.0, Vector3(x, 2.0, -9.5), Color("5a4028"), Vector3.ZERO, 5)
		Props.box(self, Vector3(0.02, 0.9, 1.4), Vector3(x, 3.6, -8.8), Color("f4f1ea"))
		Props.box(self, Vector3(0.03, 0.9, 0.2), Vector3(x, 3.6, -8.8), Color("c8262f"))
		Props.box(self, Vector3(0.03, 0.18, 1.4), Vector3(x, 3.6, -8.8), Color("c8262f"))


func _build_tower() -> void:
	var t := Vector3(8.0, 0.0, -58.0)
	Props.set_pattern(Props.cyl(self, 4.2, 30.0, t + Vector3(0, 15.0, 0), Color.WHITE, Vector3.ZERO, 16), Color("d8ccb8"), "ashlar")
	Props.cyl(self, 4.6, 1.2, t + Vector3(0, 30.4, 0), Color("b8aa94"), Vector3.ZERO, 16)
	Props.cyl(self, 4.4, 7.0, t + Vector3(0, 34.5, 0), Color("6a7480"), Vector3.ZERO, 16, 0.2)
	for k in 8:
		var a := TAU * k / 8.0
		Props.box(self, Vector3(0.8, 1.4, 0.1), t + Vector3(sin(a) * 4.22, 28.0, cos(a) * 4.22), Color("2a3440"), Vector3(0, rad_to_deg(a), 0))
	# Tepe (kulenin dibi meydan seviyesinde), yamaçtaki evler (kule tek başına kalmasın; sokak açık)
	Props.ball(self, 30.0, t + Vector3(0, -30.2, 6.0), Color("8a8a6a"), Vector3(1.6, 1.0, 1.0), 12)
	for k in 14:
		if k in [6, 7]:
			continue
		var p := t + Vector3(-26.0 + k * 4.0, 2.5, 12.0 + (k % 3) * 2.0)
		Props.set_pattern(Props.box(self, Vector3(3.6, 5.0, 3.6), p, Color.WHITE), Color("e0ccb0"), "plaster")
		Props.set_pattern(Props.prism(self, Vector3(3.9, 1.2, 3.9), p + Vector3(0, 3.1, 0), Color("a8483a")), Color("b85a44"), "tiles")


## Kule sokağının iki yanı ve kule meydanının çevresi: Ceneviz evleri (kepenkli pencereler, kapılar, kiremit çatılar),
## altta uzanan kaldırım. Eskiden sokak ve meydanın ötesi boş kalıyor, kenarlardan ufka karanlık zemin görünüyordu.
func _build_backstreets() -> void:
	var under := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(160, 0.1, 110)
	under.mesh = bm
	under.position = Vector3(0, -0.12, -78)
	under.material_override = Props.mat(Color("a8987e"), 0.0, false, "cobble", false)
	add_child(under)
	var cols := [Color("e8d8b8"), Color("d8b890"), Color("c8a888"), Color("e0c8a8"), Color("d0b8a0"), Color("c8b8a8")]
	var shutters := [Color("3a6a5a"), Color("3a5a8a"), Color("6a3a2a"), Color("5a6a3a")]
	var rng := RandomNumberGenerator.new()
	rng.seed = 1348
	var fd := Dressing.new(1348)
	var t := TOWER
	# [merkez, genişlik (sokak boyunca), derinlik, sokağa bakan yön (yaw)]
	var specs: Array = []
	var z := -30.5
	while z > -47.0:
		var w := rng.randf_range(4.2, 5.6)
		specs.append([Vector3(ALLEY_X0 - 3.2, 0, z - w * 0.5), w, 6.0, PI / 2.0])
		specs.append([Vector3(ALLEY_X1 + 3.2, 0, z - w * 0.5 - 0.6), w, 6.0, -PI / 2.0])
		z -= w + 0.1
	# Meydanın batı ve doğu kenarı (sokağa bakar), arkası
	for k in 4:
		var mz := t.z + 8.0 - k * 5.4
		specs.append([Vector3(t.x - 15.2, 0, mz), 5.2, 6.0, PI / 2.0])
		specs.append([Vector3(t.x + 15.2, 0, mz), 5.2, 6.0, -PI / 2.0])
	for k in 5:
		specs.append([Vector3(t.x - 11.0 + k * 5.5, 0, t.z - 14.2), 5.3, 6.0, 0.0])
	# Meydanın güney köşeleri (sokak ağzının iki yanı)
	specs.append([Vector3(t.x - 8.0, 0, t.z + 14.2), 7.5, 6.0, PI])
	specs.append([Vector3(t.x + 8.5, 0, t.z + 14.2), 7.0, 6.0, PI])
	for sp in specs:
		var c: Vector3 = sp[0]
		var w: float = sp[1]
		var dep: float = sp[2]
		var yaw: float = sp[3]
		var h := rng.randf_range(6.5, 10.5)
		var body := Props.solid(self, Vector3(w, h, dep), c + Vector3(0, h * 0.5, 0), Color.WHITE, Vector3(0, rad_to_deg(yaw), 0))
		Props.set_pattern(body, cols[rng.randi() % cols.size()], "plaster")
		var roof := Props.prism(self, Vector3(w + 0.5, 1.5, dep + 0.6), c + Vector3(0, h + 0.75, 0), Color("a8483a"), Vector3(0, rad_to_deg(yaw), 0))
		Props.set_pattern(roof, Color("b85a44"), "tiles")
		# Cephe (sokağa bakan yüz): arkasına bakan yüz görünmez, süslenmez
		fd.at(c + Vector3(0, 0, dep * 0.5 + 0.01).rotated(Vector3.UP, yaw), yaw)
		fd.house_face(w - 0.3, h, true, shutters[rng.randi() % shutters.size()])
		if rng.randf() < 0.5:
			fd.at(c + Vector3(0, 0, dep * 0.5 + 0.01).rotated(Vector3.UP, yaw), yaw)
			fd.awning(minf(w - 0.8, 2.6), 2.5, [Color("b3262d"), Color("2f5fa8"), Color("d8b040"), Color("3a6b3a")][rng.randi() % 4])
	# Sokak üstünde çamaşır ipleri ve Ceneviz sancakları
	for k in 3:
		var lz := -33.0 - k * 5.5
		fd.at(Vector3.ZERO, 0.0)
		fd.laundry(Vector3(ALLEY_X0 - 0.2, 5.0 + k * 0.4, lz), Vector3(ALLEY_X1 + 0.2, 5.2, lz - 0.8))
	fd.build(self)


## Galata Kulesi'ne tırmanış (yan görev): ara sokak, kule meydanı, kuleyi iki kez saran ahşap rampa, tepede balkon.
func _build_tower_climb() -> void:
	var t := TOWER
	var stone := Color("b8aa94")
	# Ara sokak ve meydan zemini, görünmez kenarlar
	Props.set_pattern(Props.solid(self, Vector3(ALLEY_X1 - ALLEY_X0, 0.4, 22.0), Vector3((ALLEY_X0 + ALLEY_X1) * 0.5, -0.2, -39.0), Color.WHITE), stone, "cobble")
	Props.set_pattern(Props.solid(self, Vector3(24.0, 0.4, 22.0), t + Vector3(0, -0.2, 0), Color.WHITE), stone, "cobble")
	for spec in [[Vector3(0.3, 3, 22), Vector3(ALLEY_X0, 1.5, -39.0)], [Vector3(0.3, 3, 22), Vector3(ALLEY_X1, 1.5, -39.0)],
			[Vector3(0.3, 3, 22), t + Vector3(-12, 1.5, 0)], [Vector3(0.3, 3, 22), t + Vector3(12, 1.5, 0)],
			[Vector3(24, 3, 0.3), t + Vector3(0, 1.5, -11)],
			[Vector3(8, 3, 0.3), t + Vector3(-8, 1.5, 11)], [Vector3(8, 3, 0.3), t + Vector3(8, 1.5, 11)]]:
		var w := Props.solid(self, spec[0], spec[1], Color(0, 0, 0, 0))
		w.get_child(0).visible = false
	# Kule gövdesi katı (rampadan içine düşülmesin)
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 4.25
	cyl.height = 38.0
	cs.shape = cyl
	body.position = t + Vector3(0, 19.0, 0)
	body.add_child(cs)
	add_child(body)
	# Sarmal rampa: 48 parça, her biri 15° ve 0.63 m; iki tur, 30 m
	var r := 5.3
	var wood := Color("8a6440")
	var steps := 48
	var rise := 30.0 / steps
	var a0 := PI * 0.5            # sokaktan gelince önde başlar (+z yönü)
	for k in steps:
		var a := a0 + TAU * k / 24.0
		var b := a0 + TAU * (k + 1) / 24.0
		var pa := t + Vector3(sin(a) * r, k * rise, cos(a) * r)
		var pb := t + Vector3(sin(b) * r, (k + 1) * rise, cos(b) * r)
		Props.ramp(self, pa, pb, 1.9, wood)
		# Dış korkuluk direği ve görünmez dış kenar
		var mid := (pa + pb) * 0.5
		var outward := Vector3(mid.x - t.x, 0, mid.z - t.z).normalized()
		if k % 2 == 0:
			Props.cyl(self, 0.06, 1.1, mid + outward * 0.95 + Vector3(0, 0.55, 0), Color("6b4428"), Vector3.ZERO, 4)
		var edge := Props.solid(self, Vector3(0.1, 1.2, 1.5), mid + outward * 1.05 + Vector3(0, 0.6, 0), Color(0, 0, 0, 0))
		edge.get_child(0).visible = false
		edge.look_at_from_position(edge.global_position, edge.global_position + (pb - pa) * Vector3(1, 0, 1), Vector3.UP)
	# Tepede balkon: rampanın vardığı yerden (a0) başlayan yedi kalas; son 45° boş, altından rampa çıkar
	for k in 8:
		var ra := a0 + TAU * k / 8.0
		var rail := Props.solid(self, Vector3(4.6, 1.0, 0.1), t + Vector3(sin(ra) * 6.4, 30.5, cos(ra) * 6.4), Color("6b4428"))
		rail.rotation.y = ra
		rail.get_child(0).visible = false   # görünmez engel; görünen: ince tırabzan ve dikmeler
		var bar := Props.box(self, Vector3(4.6, 0.07, 0.07), t + Vector3(sin(ra) * 6.4, 31.0, cos(ra) * 6.4), Color("6b4428"))
		bar.rotation.y = ra
		Props.cyl(self, 0.04, 1.0, t + Vector3(sin(ra) * 6.4, 30.5, cos(ra) * 6.4), Color("6b4428"), Vector3.ZERO, 4)
		if k >= 6:
			continue
		var a := a0 + TAU * (k + 0.5) / 8.0
		var p := t + Vector3(sin(a) * 5.3, 30.0 - 0.17, cos(a) * 5.3)
		var plank := Props.solid(self, Vector3(4.6, 0.2, 2.2), p, wood)
		plank.rotation.y = a
	# Kayıp kedi (yan görev): kule meydanının köşesinde saklanır
	var cat := Cat.new()
	cat.position = t + Vector3(-9.0, 0, 7.5)
	add_child(cat)
	# Sokağın başında tabela
	Props.cyl(self, 0.05, 2.2, Vector3(ALLEY_X0 + 0.6, 1.1, -12.0), Color("4a3020"), Vector3.ZERO, 5)
	Props.box(self, Vector3(2.6, 0.45, 0.06), Vector3(ALLEY_X0 + 0.6, 2.0, -12.0), Color("e8e0cc"))
	Props.label(self, "TORRE DI CRISTO ↑", Vector3(ALLEY_X0 + 0.6, 2.0, -11.96), 30, Color("5a2a2a"), Vector3.ZERO, 2.4)
	# Tepede tetik
	Props.trigger(self, t + Vector3(0, 31.2, 0), Vector3(14.0, 2.4, 14.0), func():
		GameState.flags["climbed_galata"] = true
		var hud := get_tree().get_first_node_in_group("hud") as Hud
		if hud:
			hud.bark("SPK_TOLGA", "D_GAL_TOP", 5.5)
			get_tree().create_timer(5.7).timeout.connect(func():
				if is_instance_valid(hud):
					hud.bark("SPK_NOTARY", "D_GAL_NOTARY", 4.5)))


## Tezgâhlar: balıkçı, şarapçı, noter; bir de "iki tarafa da" satan tüccar.
func _build_stalls() -> void:
	var stalls := [[FISH, Color("2f5fa8"), "PESCE · BALIK"], [WINE, Color("7a2a3a"), "VINO · ŞARAP"],
		[NOTARY, Color("3a4a3a"), "NOTAIO · NOTER"], [DOUBLE, Color("c98a3a"), "OSMANLI ⟷ BİZANS · TOPTAN"]]
	for s in stalls:
		var p: Vector3 = s[0]
		var awn: Color = s[1]
		var face := 1.0 if p.z < -5.0 else -1.0
		Props.solid(self, Vector3(2.6, 0.95, 1.0), p + Vector3(0, 0.48, -0.9 * face), Color("8a6440"))
		for sx in [-1.2, 1.2]:
			Props.cyl(self, 0.05, 2.5, p + Vector3(sx, 1.25, -1.4 * face), Color("5a4028"), Vector3.ZERO, 5)
		Props.box(self, Vector3(2.9, 0.08, 1.6), p + Vector3(0, 2.5, -0.9 * face), awn, Vector3(8 * face, 0, 0))
		Props.label(self, s[2], p + Vector3(0, 2.2, -0.05 * face), 22, Color("f2e6c9"), Vector3(0, 0 if face > 0 else 180, 0), 2.4)
	# Tezgâhların üstü
	for i in 5:
		Props.ball(self, 0.12, FISH + Vector3(-0.9 + i * 0.45, 1.02, 0.9), Color("a8b8c0"), Vector3(2.2, 0.6, 0.8), 6)
	for i in 3:
		var b := Props.cyl(self, 0.38, 0.8, WINE + Vector3(-0.9 + i * 0.9, 0.4, 1.9), Color("7a5030"), Vector3(90, 0, 0), 10)
		b.name = "Barrel%d" % i
	# Fıçı yığınları (Kimi modeli): şarapçının yanı ve iskele
	for bp in [WINE + Vector3(2.4, 0, 0.2), WINE + Vector3(3.2, 0, 0.6), WINE + Vector3(2.8, 0.9, 0.4),
			GANGWAY + Vector3(-3.0, 0, -2.2), GANGWAY + Vector3(-3.9, 0, -2.0), GANGWAY + Vector3(-3.4, 0, -2.9)]:
		Props.model(self, "barrel", bp, randf() * 360.0)
	# Venedikli çocuk (yan karakter, kedisini arıyor)
	var kid := Person.new({"coat": Color("c8603a"), "pants": Color("3a3a5a"), "hair": Color("5a3a1e"), "skin": Color("f0c8a0")})
	kid.position = FISH + Vector3(-3.4, 0, -2.6)
	kid.scale = Vector3.ONE * 0.72
	kid.add_to_group("cat_owner")
	add_child(kid)
	Props.interactable(self, "npc:kid", Vector3(0.9, 1.4, 0.9), kid.position + Vector3(0, 0.7, 0))
	Props.interactable(self, "mg:haggle_wine", Vector3(2.0, 1.6, 1.6), WINE + Vector3(2.8, 0.8, 0.4))
	Props.interactable(self, "mg:haggle_double", Vector3(1.2, 1.4, 1.2), DOUBLE + Vector3(1.9, 0.7, 1.3))
	for k in 3:
		Props.box(self, Vector3(0.6, 0.5, 0.6), DOUBLE + Vector3(1.6 + k * 0.3, 0.25 + (k % 2) * 0.5, 1.3), Color("6b4a2c"))
	for i in 4:
		Props.box(self, Vector3(0.35, 0.02, 0.5), NOTARY + Vector3(-0.8 + i * 0.5, 0.97, -0.9), Color("efe6cf"), Vector3(0, i * 9, 0))
	Props.box(self, Vector3(0.5, 0.5, 0.5), DOUBLE + Vector3(-0.6, 1.2, 0.9), Color("4a4a50"))
	Props.box(self, Vector3(0.5, 0.5, 0.5), DOUBLE + Vector3(0.6, 1.2, 0.9), Color("4a4a50"))


func _build_ship() -> void:
	ship = Node3D.new()
	ship.position = SHIP_START
	ship.rotation.y = PI / 2.0
	add_child(ship)
	ship.add_child(LowPoly.hull([
		{"z": -11.0, "w": 0.06, "top": 3.1, "bottom": 1.9},
		{"z": -9.0, "w": 1.1, "top": 2.7, "bottom": 0.7},
		{"z": -5.0, "w": 1.8, "top": 2.45, "bottom": 0.3},
		{"z": 0.0, "w": 2.05, "top": 2.4, "bottom": 0.25},
		{"z": 5.0, "w": 1.9, "top": 2.45, "bottom": 0.3},
		{"z": 8.0, "w": 1.5, "top": 2.9, "bottom": 0.6},
		{"z": 9.5, "w": 0.9, "top": 3.5, "bottom": 1.3},
	], Color("4a3020"), Color("b38a2a"), 2.2))
	Props.solid(ship, Vector3(3.4, 0.12, 16.0), Vector3(0, 2.35, -0.6), Color("b08a5c"))
	Props.box(ship, Vector3(3.0, 1.2, 2.6), Vector3(0, 3.0, 7.2), Color("7a2a2a"))
	Props.cyl(ship, 0.16, 12.0, Vector3(0, 8.3, -1.0), Color("5a4028"), Vector3.ZERO, 8)
	Props.cyl(ship, 0.09, 9.0, Vector3(0, 11.0, -1.0), Color("5a4028"), Vector3(0, 0, 90), 6)
	Props.box(ship, Vector3(8.0, 6.0, 0.08), Vector3(0, 8.0, -0.8), Color("f0e8d4"), Vector3(0, 0, 0))
	# Venedik aslanı: kırmızı zemin, altın aslan
	Props.box(ship, Vector3(0.05, 1.2, 1.6), Vector3(0, 13.4, 0.2), Color("b3262d"))
	Props.ball(ship, 0.3, Vector3(0.04, 13.4, 0.2), Color("d8b040"), Vector3(0.2, 1.0, 1.2), 8)
	for side in [-1, 1]:
		for k in 9:
			Props.box(ship, Vector3(0.08, 0.08, 4.0), Vector3(side * 2.9, 1.6, -7.0 + k * 1.7), Color("6a4a2c"), Vector3(0, 0, side * 22))
	# İskele
	Props.solid(self, Vector3(1.2, 0.12, 5.2), Vector3(GANGWAY.x, 0.7, 3.4), Color("8a6a44"), Vector3(-14, 0, 0))


## Haliç'in karşısı: surlar, kuleler, kubbeler, tepeler.
func _build_far_shore() -> void:
	var z := 150.0
	Props.box(self, Vector3(600, 18, 60), Vector3(0, 2.0, z + 30), Color("6a7a4a"))
	var city := Node3D.new()
	city.position = Vector3(0, 11.0, 0)
	add_child(city)
	Scenery.city_walls(city, z + 4.0, 460.0, 1.0, 1453)
	Props.box(self, Vector3(420, 10, 4), Vector3(0, 8.0, z), Color("b8a888"))
	for i in 22:
		Props.box(self, Vector3(7, 16, 7), Vector3(-210.0 + i * 20.0, 10.0, z - 1.0), Color("c8b898"))
	# Ayasofya ve kubbeler
	Props.box(self, Vector3(40, 18, 30), Vector3(60, 14, z + 26), Color("d8b8a0"))
	Props.ball(self, 18.0, Vector3(60, 24, z + 26), Color("9aa8b8"), Vector3(1, 0.55, 1), 16)
	for x in [-80.0, -20.0, 120.0]:
		Props.ball(self, 8.0, Vector3(x, 14, z + 22), Color("a8b0b8"), Vector3(1, 0.6, 1), 12)
		Props.box(self, Vector3(16, 10, 16), Vector3(x, 12, z + 22), Color("d8c8b0"))
	for i in 8:
		Props.ball(self, 40.0, Vector3(-300.0 + i * 90.0, -8.0, z + 90.0), Color("7a8a6a"), Vector3(1.4, 0.5, 1.0), 10)
	# Batı yakası: Galata'nın ötesinde Osmanlı tepeleri ve çadırları (burnun arkası boş kalmasın)
	Props.box(self, Vector3(316, 3.0, 190), Vector3(-206, -1.2, -85), Color("5f6a40"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 29
	for i in 10:
		Props.ball(self, rng.randf_range(35.0, 60.0), Vector3(-130.0 - i * 32.0, -14.0, -40.0 + rng.randf_range(-60.0, 90.0)), Color("56643a"), Vector3(1.3, 0.55, 1.1), 10)
	for i in 70:
		var tp := Vector3(rng.randf_range(-260.0, -80.0), 0.3, rng.randf_range(-120.0, 60.0))
		var t := Night.tent(self, tp, rng.randf_range(1.8, 3.2), [Color("d8cbb0"), Color("c8b894"), Color("e0d4b8")][i % 3],
			[Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a")][i % 3])
		t.rotation.y = rng.randf() * TAU
	for i in 6:
		var fp := Vector3(-90.0 - i * 25.0, 0.3, 25.0 - i * 9.0)
		Props.cyl(self, 0.12, 9.0, fp + Vector3(0, 4.5, 0), Color("5a4028"), Vector3.ZERO, 5)
		Props.box(self, Vector3(0.05, 1.6, 2.6), fp + Vector3(0, 8.0, 1.3), Color("b3262d"))
	# Batı yakasında ağaçlar ve çimen: tepeler çıplak kalmasın (Galata ve su hariç)
	var hc := FATIH_POINT + Vector3(-8.0, -11.0, 6.0)
	var west_h := func(x: float, zz: float) -> float:
		var d2 := pow((x - hc.x) / 1.4, 2.0) + pow(zz - hc.z, 2.0)
		var on_hill := hc.y + sqrt(maxf(0.0, 196.0 - d2))
		return maxf(0.3, on_hill)
	var avoid := [Rect2(-56.0, -200.0, 400.0, 400.0), Rect2(-400.0, 8.0, 330.0, 300.0)]
	Scenery.trees(self, Vector3(-150, 0, -50), 12.0, 150.0, 240, avoid, west_h, 1453)
	Scenery.ground_detail(self, Rect2(-300.0, -170.0, 240.0, 175.0), 500, west_h, Color("6a7a3a"), 91)
	# Burnun üstünde birkaç servi (Fatih'in arkası)
	Scenery.trees(self, hc * Vector3(1, 0, 1), 4.0, 16.0, 14, [Rect2(-64.0, 28.0, 12.0, 14.0)], west_h, 77)
	# Fatih'in durduğu burun (Haliç'in ağzı)
	Props.ball(self, 14.0, FATIH_POINT + Vector3(-8.0, -11.0, 6.0), Color("7a7a5a"), Vector3(1.4, 1.0, 1.0), 10)
	Props.box(self, Vector3(8, 0.6, 6), FATIH_POINT + Vector3(0, -0.3, 0), Color("8a8060"))


func _build_people() -> void:
	var defs := {
		"fishmonger": [FISH + Vector3(0, 0, -0.3), {"coat": Color("5a6a7a"), "pants": Color("3a3a3a"), "apron": Color("d8d0c0"), "mustache": true, "hat": "none"}],
		"wine": [WINE + Vector3(0, 0, -0.3), {"coat": Color("7a2a3a"), "pants": Color("3a2a2a"), "hat": "plume", "beard": true, "skin": Color("e8b894")}],
		"notary": [NOTARY + Vector3(0, 0, -0.3), {"coat": Color("2a2a3a"), "pants": Color("2a2a30"), "glasses": true, "hat": "none", "hair": Color("6a6a6a")}],
		"double": [DOUBLE + Vector3(0, 0, 0.3), {"coat": Color("c98a3a"), "pants": Color("4a3a2a"), "hat": "turban", "mustache": true}],
		"captain": [GANGWAY + Vector3(-1.4, 0, -0.6), {"coat": Color("1a2a4a"), "pants": Color("2a2a30"), "hat": "plume", "beard": true, "mustache": true, "skin": Color("e0a57e")}],
	}
	for id in defs:
		var p := Person.new(defs[id][1])
		p.position = defs[id][0]
		if (defs[id][0] as Vector3).z > -5.0 and id != "double":
			p.rotation.y = PI
		add_child(p)
		npcs[id] = p
		Props.interactable(self, id, Vector3(1.2, 2.0, 1.2), p.position + Vector3(0, 1.0, 0))
	npcs["double"].rotation.y = PI
	# Kalabalık
	var rng := RandomNumberGenerator.new()
	rng.seed = 33
	for i in 10:
		var p := Person.new({"coat": [Color("7a5a3a"), Color("5a6a4a"), Color("8a4a3a"), Color("4a5a7a")][i % 4], "pants": Color("3a3a3a"),
			"hat": ["none", "plume", "turban", "none"][i % 4], "mustache": i % 2 == 0, "skirt": i % 5 == 1})
		p.position = Vector3(rng.randf_range(-34.0, 30.0), 0, rng.randf_range(-8.0, -3.0))
		p.rotation.y = rng.randf() * TAU
		add_child(p)
	# Burunda Fatih ve iki muhafız (gemi geçerken görünür)
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "turban", "mustache": true, "robe": Color("c8323a"),
		"hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.position = FATIH_POINT
	fatih.scale = Vector3(1.06, 1.06, 1.06)
	add_child(fatih)
	for s in [-1, 1]:
		var g := Soldier.new(Color("b3262d") if s < 0 else Color("2f5fa8"), "stand", "bork")
		g.position = FATIH_POINT + Vector3(s * 1.6, 0, -0.8)
		add_child(g)
	lights.append(Night.torch(self, GANGWAY + Vector3(-2.2, 0, -0.4), 2.2))
