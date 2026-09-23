class_name ByzCity
extends Node3D
## Bölüm 6b: Konstantinopolis, surların içi, 23 Nisan 1453 (GDD §9.4).
## Deniz kapısından çıkan taş cadde bir meydana açılır. Meydanın kuzeyinde Logothetes'in
## kançılaryası: koridor boyunca yedi oda, yedi memur, yedi mühür (Bizans Labirenti).
## Doğuda kara surları ve Giustiniani, batıda saray avlusu ve İmparator. Güneydoğuda
## beyaz bayrakla çıkılacak kapı.

const GREEK := ["Α", "Β", "Γ", "Δ", "Ε", "Ζ", "Η"]
const START := Vector3(0.0, 0.0, 12.0)
const CELL_START := Vector3(-7.0, 0.0, 14.0)
const NIKO_POS := Vector3(1.5, 0.0, -27.0)
const HALL_Z0 := -30.0          # kançılarya ön duvarı
const ROOM_Z0 := -32.5
const ROOM_Z1 := -40.0
const ROOM_W := 4.0
const GIUST_POS := Vector3(26.0, 0.0, -14.0)
const EMPEROR_POS := Vector3(-27.0, 0.0, -14.0)
const EXIT_POS := Vector3(33.0, 0.0, 4.0)

var clerks: Array[Person] = []
var niko: Person
var nihat: Person
var giustiniani: Person
var emperor: Person
var lights: Array = []
var _t := 0.0


func _ready() -> void:
	_build_sky()
	_build_ground()
	_build_street()
	_build_chancery()
	_build_walls()
	_build_palace()
	niko = Person.new({"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hair": Color("2a1e14"), "hat": "helm", "mustache": true, "beard": true, "skin": Color("d9a07a")})
	niko.position = NIKO_POS
	add_child(niko)
	Props.interactable(niko, "niko", Vector3(1.0, 1.9, 1.0), Vector3(0, 0.95, 0))


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


func _build_sky() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("4a86c0")
	sm.sky_horizon_color = Color("d8dcd0")
	sm.ground_horizon_color = Color("c9c0a8")
	sm.ground_bottom_color = Color("7a6a50")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.42
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.82
	e.fog_enabled = true
	e.fog_light_color = Color("d8d4c8")
	e.fog_density = 0.006
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.25
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, 35, 0)
	sun.light_color = Color("ffe4c0")
	sun.light_energy = 1.05
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 60.0
	add_child(sun)


func _build_ground() -> void:
	var body := Props.solid(self, Vector3(90, 0.2, 80), Vector3(0, -0.1, -10), Color("b8aa8a"))
	Props.set_pattern(body, Color("b8aa8a"), "concrete")
	# Caddenin taş döşemesi
	for i in 18:
		Props.box(self, Vector3(6.0, 0.02, 0.08), Vector3(0, 0.01, 16.0 - i * 2.2), Color("9a8c6c"))


func _house(pos: Vector3, size: Vector3, color: Color, rot := 0.0) -> void:
	var h := Node3D.new()
	h.position = pos
	h.rotation.y = deg_to_rad(rot)
	add_child(h)
	Props.set_pattern(Props.solid(h, size, Vector3(0, size.y / 2.0, 0), color), color, "wall")
	Props.prism(h, Vector3(size.x + 0.4, 1.2, size.z + 0.4), Vector3(0, size.y + 0.6, 0), Color("b5533a"))
	Props.box(h, Vector3(size.x + 0.02, 0.25, size.z + 0.02), Vector3(0, size.y * 0.45, 0), Color("a4513a"))
	for k in 2:
		Props.box(h, Vector3(0.7, 1.0, 0.05), Vector3(-size.x * 0.25 + k * size.x * 0.5, size.y * 0.7, size.z / 2.0 + 0.01), Color("2a2a30"))
	Props.box(h, Vector3(1.0, 1.9, 0.05), Vector3(0, 0.95, size.z / 2.0 + 0.01), Color("5a4028"))


func _build_street() -> void:
	# Deniz kapısı (başlangıç) ve cadde boyunca evler
	Props.set_pattern(Props.solid(self, Vector3(20, 9, 1.5), Vector3(0, 4.5, 19.0), Color("c9b89a")), Color("c9b89a"), "wall")
	Props.box(self, Vector3(2.4, 3.2, 0.2), Vector3(0, 1.6, 18.2), Color("5a4028"))
	var cols := [Color("c8b494"), Color("d0bc98"), Color("b8a484"), Color("c4a88c")]
	for i in 4:
		_house(Vector3(-7.0, 0, 10.0 - i * 7.0), Vector3(5.0, 5.0 + (i % 2), 5.5), cols[i % 4], 90)
		_house(Vector3(7.0, 0, 10.0 - i * 7.0), Vector3(5.0, 5.5 - (i % 2), 5.5), cols[(i + 2) % 4], -90)
	# Meydan: çeşme ve sütun
	Props.cyl(self, 1.6, 0.6, Vector3(0, 0.3, -16.0), Color("c9c0a8"), Vector3.ZERO, 14)
	Props.cyl(self, 1.4, 0.05, Vector3(0, 0.58, -16.0), Color("5a8aa8"), Vector3.ZERO, 14)
	Props.cyl(self, 0.25, 1.6, Vector3(0, 1.1, -16.0), Color("c9c0a8"), Vector3.ZERO, 8)
	# Yönler: tabelalar
	for d in [[Vector3(-3.0, 0, -20.0), "ΚΑΓΚΕΛΛΑΡΙΑ ↑"], [Vector3(6.0, 0, -13.0), "ΤΕΙΧΗ →"], [Vector3(-6.0, 0, -13.0), "← ΠΑΛΑΤΙΟΝ"]]:
		Props.cyl(self, 0.05, 2.0, d[0] + Vector3(0, 1.0, 0), Color("4a3020"), Vector3.ZERO, 5)
		Props.box(self, Vector3(2.4, 0.45, 0.06), d[0] + Vector3(0, 1.9, 0), Color("e8e0cc"))
		Props.label(self, d[1], d[0] + Vector3(0, 1.9, 0.04), 30, Color("5a2a2a"), Vector3.ZERO, 2.2)


# ---------------------------------------------------------------- kançılarya (labirent)

func _build_chancery() -> void:
	var x0 := -3.5 * ROOM_W
	var x1 := 3.5 * ROOM_W
	var wall_c := Color("d8c8a8")
	# Ön duvar (kapı ortada) ve arka duvar
	# Ön duvar: ortada 2.4 m'lik kapı aralığı, üstünde lento
	_wall(Vector3(-1.2 - x0, 5.0, 0.3), Vector3((x0 - 1.2) / 2.0, 2.5, HALL_Z0), wall_c, true)
	_wall(Vector3(x1 - 1.2, 5.0, 0.3), Vector3((x1 + 1.2) / 2.0, 2.5, HALL_Z0), wall_c, false)
	_wall(Vector3(2.4, 1.8, 0.3), Vector3(0, 4.1, HALL_Z0), wall_c, false)
	_wall(Vector3(x1 - x0, 5.0, 0.3), Vector3(0, 2.5, ROOM_Z1), wall_c, false)
	_wall(Vector3(0.3, 5.0, ROOM_Z1 - HALL_Z0), Vector3(x0, 2.5, (HALL_Z0 + ROOM_Z1) / 2.0), wall_c, false)
	_wall(Vector3(0.3, 5.0, ROOM_Z1 - HALL_Z0), Vector3(x1, 2.5, (HALL_Z0 + ROOM_Z1) / 2.0), wall_c, false)
	Props.solid(self, Vector3(x1 - x0, 0.3, HALL_Z0 - ROOM_Z1), Vector3(0, 5.1, (HALL_Z0 + ROOM_Z1) / 2.0), Color("b5533a"))
	# Kapının üstünde yazı
	Props.box(self, Vector3(5.0, 0.7, 0.1), Vector3(0, 4.0, HALL_Z0 + 0.2), Color("8a2b22"))
	Props.label(self, "ΛΟΓΟΘΕΤΗΣ · ΜΙΣΑΦΙΡ ΙΖΝΙ", Vector3(0, 4.0, HALL_Z0 + 0.26), 36, Color("f2e6c9"), Vector3.ZERO, 4.6)
	# Odalar: koridorun kuzeyinde, aralarında bölmeler
	for i in 7:
		var cx := x0 + ROOM_W * (i + 0.5)
		if i > 0:
			_wall(Vector3(0.2, 5.0, ROOM_Z1 - ROOM_Z0), Vector3(x0 + ROOM_W * i, 2.5, (ROOM_Z0 + ROOM_Z1) / 2.0), wall_c, false)
		# Oda ön duvarı (kapı aralığıyla)
		_wall(Vector3(1.3, 5.0, 0.2), Vector3(cx - 1.35, 2.5, ROOM_Z0), wall_c, false)
		_wall(Vector3(1.3, 5.0, 0.2), Vector3(cx + 1.35, 2.5, ROOM_Z0), wall_c, false)
		_wall(Vector3(1.4, 2.4, 0.2), Vector3(cx, 3.8, ROOM_Z0), wall_c, false)
		# Kapı levhası
		Props.box(self, Vector3(0.7, 0.7, 0.05), Vector3(cx, 3.1, ROOM_Z0 + 0.12), Color("c49a45"))
		Props.label(self, GREEK[i], Vector3(cx, 3.1, ROOM_Z0 + 0.16), 64, Color("3a1a10"), Vector3.ZERO, 0.5)
		# Masa, kâğıt yığınları, mühür
		Props.box(self, Vector3(2.0, 0.8, 0.8), Vector3(cx, 0.4, ROOM_Z1 + 2.2), Color("7a5a38"))
		for k in 3:
			Props.box(self, Vector3(0.3, 0.2 + k * 0.15, 0.22), Vector3(cx - 0.7 + k * 0.3, 0.9 + k * 0.07, ROOM_Z1 + 2.1), Color("efe6cf"))
		Props.cyl(self, 0.06, 0.14, Vector3(cx + 0.6, 0.87, ROOM_Z1 + 2.3), Color("8a2b22"), Vector3.ZERO, 8)
		var l := OmniLight3D.new()
		l.position = Vector3(cx, 3.6, ROOM_Z1 + 2.5)
		l.light_color = Color("ffd8a0")
		l.light_energy = 1.0
		l.omni_range = 5.0
		add_child(l)
		var theo := i == 6
		var robes := [Color("6a3a7a"), Color("2f5fa8"), Color("3a6b3a"), Color("8a6a2a"), Color("7a2a3a"), Color("3a4a6a"), Color("5a2a6a")]
		var clerk := Person.new({"coat": robes[i], "pants": robes[i].darkened(0.3), "hat": "kamelaukion", "robe": robes[i],
			"beard": theo or i % 3 == 0, "mustache": true, "hair": Color("8a8a8a") if theo else Color("3a2a1e"), "glasses": theo})
		clerk.position = Vector3(cx, 0, ROOM_Z1 + 1.2)
		add_child(clerk)
		clerks.append(clerk)
		Props.interactable(self, "clerk:%d" % i, Vector3(2.2, 2.0, 1.6), Vector3(cx, 1.0, ROOM_Z1 + 2.6))
	# Koridordaki Nihat (cameo): fötr şapka, bir sütunun yanında, hayranlıkla
	nihat = Person.new({"coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true, "hair": Color("3a2a1e"), "skin": Color("ecb892")})
	nihat.position = Vector3(x1 - 1.5, 0, HALL_Z0 - 1.2)
	nihat.rotation.y = -PI / 2.0
	add_child(nihat)
	Props.interactable(self, "nihat", Vector3(1.0, 2.0, 1.0), nihat.position + Vector3(0, 1.0, 0))
	var hl := OmniLight3D.new()
	hl.position = Vector3(0, 3.8, HALL_Z0 - 1.2)
	hl.light_color = Color("ffe0b0")
	hl.light_energy = 1.2
	hl.omni_range = 16.0
	add_child(hl)


func _wall(size: Vector3, pos: Vector3, color: Color, _front: bool) -> void:
	Props.set_pattern(Props.solid(self, size.abs(), pos, color), color, "wall")


# ---------------------------------------------------------------- kara surları

func _build_walls() -> void:
	# İç sur: kuleli, tuğla bantlı, önünde ahşap iskele ve topçular
	var x := 34.0
	Props.set_pattern(Props.solid(self, Vector3(3.0, 12.0, 60.0), Vector3(x, 6.0, -10.0), Color("c9b89a")), Color("c9b89a"), "wall")
	for y in [3.0, 6.5, 10.0]:
		Props.box(self, Vector3(0.05, 0.4, 60.0), Vector3(x - 1.52, y, -10.0), Color("8a4a36"))
	for z in [-34.0, -18.0, -2.0, 14.0]:
		Props.set_pattern(Props.solid(self, Vector3(6.0, 16.0, 6.0), Vector3(x, 8.0, z), Color("bfae90")), Color("bfae90"), "wall")
	var zz := -38.0
	while zz < 18.0:
		Props.box(self, Vector3(0.6, 0.9, 0.8), Vector3(x - 1.2, 12.45, zz), Color("bba98a"))
		zz += 1.6
	# Ahşap iskele ve Giustiniani'nin masası (haritalar, sözleşmeler)
	Props.solid(self, Vector3(4.0, 0.3, 8.0), Vector3(x - 4.0, 1.2, GIUST_POS.z), Color("7a5a38"))
	for k in 4:
		Props.cyl(self, 0.1, 1.2, Vector3(x - 5.8 + (k % 2) * 3.6, 0.6, GIUST_POS.z - 3.6 + (k / 2) * 7.2), Color("5a4028"), Vector3.ZERO, 6)
	Props.box(self, Vector3(1.6, 0.8, 0.9), GIUST_POS + Vector3(-1.4, 0.4, 1.6), Color("6a4a2c"))
	Props.box(self, Vector3(1.2, 0.02, 0.8), GIUST_POS + Vector3(-1.4, 0.81, 1.6), Color("efe6cf"), Vector3(0, 8, 0))
	Props.label(self, "CONTRATTO", GIUST_POS + Vector3(-1.4, 0.83, 1.6), 24, Color("5a2a2a"), Vector3(-90, 8, 0), 0.9)
	for k in 3:
		Props.box(self, Vector3(0.6, 1.0, 0.4), Vector3(x - 3.0, 0.5, GIUST_POS.z + 5.0 + k * 0.9), Color("8a6440"))
	giustiniani = Person.new({"coat": Color("a8aeb6"), "pants": Color("6a2a2a"), "hat": "plume", "beard": true, "mustache": true, "hair": Color("5a3a1e"), "skin": Color("e8b894")})
	giustiniani.position = GIUST_POS
	giustiniani.rotation.y = -PI / 2.0
	add_child(giustiniani)
	Props.interactable(self, "giustiniani", Vector3(1.2, 2.0, 1.2), GIUST_POS + Vector3(0, 1.0, 0))
	# Çıkış kapısı (beyaz bayrakla çıkılır)
	Props.box(self, Vector3(0.3, 3.4, 2.6), EXIT_POS + Vector3(-1.3, 1.7, 0), Color("5a4028"))
	Props.ring(self, 1.3, 1.6, EXIT_POS + Vector3(-1.4, 3.4, 0), Color("a89878"), Vector3(0, 90, 90))
	Props.interactable(self, "exit", Vector3(1.4, 3.0, 3.0), EXIT_POS + Vector3(-1.8, 1.5, 0))
	lights.append(Night.torch(self, EXIT_POS + Vector3(-2.0, 0, 1.8), 2.4))


# ---------------------------------------------------------------- saray avlusu

func _build_palace() -> void:
	var c := EMPEROR_POS
	var body := Props.solid(self, Vector3(1.0, 8.0, 16.0), c + Vector3(-5.0, 4.0, 0), Color("d8c8b0"))
	Props.set_pattern(body, Color("d8c8b0"), "wall")
	# Sütunlar, mor sancaklar, taht
	for k in 6:
		var z := -6.0 + k * 2.4
		Props.cyl(self, 0.35, 5.0, c + Vector3(-1.5, 2.5, z), Color("e8e0cc"), Vector3.ZERO, 10)
		Props.box(self, Vector3(0.9, 0.3, 0.9), c + Vector3(-1.5, 5.1, z), Color("d8c8b0"))
	for z in [-3.0, 3.0]:
		Props.box(self, Vector3(0.05, 3.0, 1.2), c + Vector3(-4.45, 4.0, z), Color("5a2a6a"))
		Props.label(self, "ΧΡ", c + Vector3(-4.4, 4.6, z), 60, Color("d8b040"), Vector3(0, 90, 0), 0.8)
	Props.box(self, Vector3(1.4, 0.4, 1.8), c + Vector3(-3.6, 0.2, 0), Color("c9c0a8"))
	Props.box(self, Vector3(0.9, 1.8, 1.2), c + Vector3(-4.0, 1.3, 0), Color("5a2a6a"))
	emperor = Person.new({"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "crown", "beard": true, "mustache": true, "hair": Color("6a6a6a"), "robe": Color("5a2a6a")})
	emperor.position = c + Vector3(-2.6, 0, 0)
	emperor.rotation.y = PI / 2.0
	add_child(emperor)
	Props.interactable(self, "emperor", Vector3(1.2, 2.0, 1.2), emperor.position + Vector3(0, 1.0, 0))
	for k in 2:
		var g := Person.new({"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true})
		g.position = c + Vector3(-1.0, 0, -2.2 + k * 4.4)
		g.rotation.y = PI / 2.0
		add_child(g)
	var l := OmniLight3D.new()
	l.position = c + Vector3(0, 4.0, 0)
	l.light_color = Color("ffd8a0")
	l.light_energy = 1.2
	l.omni_range = 10.0
	add_child(l)


func clerk_x(i: int) -> float:
	return -3.5 * ROOM_W + ROOM_W * (i + 0.5)
