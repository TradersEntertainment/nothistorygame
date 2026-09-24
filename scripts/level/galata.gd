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
	_build_stalls()
	_build_ship()
	_build_far_shore()
	_build_people()


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
	# Tepe, yamaçtaki evler (kule tek başına kalmasın)
	Props.ball(self, 30.0, t + Vector3(0, -22.0, 6.0), Color("8a8a6a"), Vector3(1.6, 1.0, 1.0), 12)
	for k in 14:
		var p := t + Vector3(-26.0 + k * 4.0, 2.0 + absf(k - 7) * -0.4 + 4.0, 12.0 + (k % 3) * 2.0)
		Props.set_pattern(Props.box(self, Vector3(3.6, 5.0, 3.6), p, Color.WHITE), Color("e0ccb0"), "plaster")
		Props.set_pattern(Props.prism(self, Vector3(3.9, 1.2, 3.9), p + Vector3(0, 3.1, 0), Color("a8483a")), Color("b85a44"), "tiles")


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
