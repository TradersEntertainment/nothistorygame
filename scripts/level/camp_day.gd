class_name CampDay
extends Node3D
## Bölüm 6a: Osmanlı ordugâhı, 23 Nisan 1453, gündüz (GDD §9.3).
## Ortada açık bir meydan; çevresinde otağa giden dört yolun durakları:
##   A · mutfak (Aşçıbaşı Kadri), B · tercüman çadırı (Lütfi), C · topçu alanı (Urban ve
##   büyük top), Y · pazar (kaçak keçi, kayıp yüzük, mektup yazdıran asker).
## Pazarın arkasında Çandarlı'nın adamı. Kuzeyde, tepede Padişah'ın otağı.

const SPAWN := Vector3(0.0, 0.0, 4.0)
const KITCHEN_SPAWN := Vector3(-11.0, 0.0, -3.0)
const KADRI_POS := Vector3(-13.0, 0.0, -6.5)
const LUTFI_POS := Vector3(12.5, 0.0, -6.5)
const URBAN_POS := Vector3(-3.0, 0.0, -20.0)
const SOLDIER_POS := Vector3(5.5, 0.0, 12.0)
const RING_POS := Vector3(-4.2, 0.0, 13.5)
const CANDARLI_POS := Vector3(9.0, 0.0, 19.5)
const OTAG_POS := Vector3(0.0, 0.0, -62.0)
const ROAD_Z := -30.0

const CAMP_PEOPLE := [
	{"coat": Color("b3262d"), "pants": Color("4a2a1e"), "hat": "turban", "mustache": true},
	{"coat": Color("2f5fa8"), "pants": Color("3a2a1e"), "hat": "turban", "mustache": true, "beard": true},
	{"coat": Color("3a6b3a"), "pants": Color("3a3a2a"), "hat": "turban", "mustache": true},
	{"coat": Color("c98a3a"), "pants": Color("4a3a2a"), "hat": "turban", "beard": true},
	{"coat": Color("8a2b22"), "pants": Color("2a2a2a"), "hat": "helm", "mustache": true},
	{"coat": Color("d8c8a8"), "pants": Color("5a4028"), "apron": Color("f0e8d8"), "hat": "turban", "mustache": true},
]

var kadri: Person
var lutfi: Person
var urban: Person
var letter_soldier: Soldier
var candarli: Person
var goat: Goat
var ring_node: Node3D
var cannon: Node3D
var lights: Array = []
var _t := 0.0
var _env_node: WorldEnvironment
var _sun: DirectionalLight3D


func _ready() -> void:
	_build_sky()
	_build_ground()
	_build_kitchen()
	_build_chicken_yard()
	_build_calligrapher()
	_build_interpreter()
	_build_artillery()
	_build_archery()
	_build_market()
	_build_otag()
	_build_tents()
	Dressing.auto(self, {"style": "camp", "seed": 1453, "rect": Rect2(-30, -58, 60, 84), "y_max": 2.0, "walkers": 8,
		"open_gap": 6.0, "open_clear": 3.2, "open_chance": 0.85,
		"reserved": [Rect2(-3.0, -62.0, 6.0, 34.0), Rect2(-7.0, 8.5, 14.0, 6.5), Rect2(-19.5, -2.5, 7.0, 8.0), Rect2(-4.0, -1.0, 8.0, 7.0)],
		"people": CAMP_PEOPLE})


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


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
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_light_color = Color("c7d7e4")
	e.fog_density = 0.004
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.25
	e.tonemap_exposure = 0.88
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.12
	e.adjustment_contrast = 1.06
	env.environment = e
	add_child(env)
	_env_node = env
	var sun := DirectionalLight3D.new()
	_sun = sun
	sun.rotation_degrees = Vector3(-42, 150, 0)
	sun.light_color = Color("ffe9c7")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 60.0
	add_child(sun)
	SkyBody.attach(self, sun)


## Gece: gökyüzü, ay ışığı ve yol boyunca meşaleler (Bölüm 11).
func make_night() -> void:
	Scenery.darken_smoke(get_tree())
	if _env_node:
		_env_node.queue_free()
	if _sun:
		_sun.queue_free()
	Night.environment(self, 0.01)
	for z in [-10.0, -22.0, -34.0, -46.0]:
		for sx in [-3.2, 3.2]:
			lights.append(Night.torch(self, Vector3(sx, 0, z), 2.2))
	for p in [Vector3(-12.0, 0, -2.0), Vector3(11.0, 0, -3.0), Vector3(-4.0, 0, 9.0)]:
		lights.append(Night.campfire(self, p, 0.8))


## Arazi yüksekliği: oynanan alan (otağ dahil) düzdür; tepeler ve dalgalar yalnızca kenarlarda başlar.
static var _noise: FastNoiseLite


static func height(x: float, z: float) -> float:
	if _noise == null:
		_noise = FastNoiseLite.new()
		_noise.seed = 23
		_noise.frequency = 0.03
	var edge := maxf(absf(x) - 36.0, maxf(-z - 84.0, z - 32.0))
	if edge <= 0.0:
		return 0.0
	return _noise.get_noise_2d(x, z) * clampf(edge / 14.0, 0.0, 1.0) * 5.0 + edge * 0.12


func _build_ground() -> void:
	var noise := FastNoiseLite.new()
	noise.seed = 23
	noise.frequency = 0.03
	var hf := func(x: float, z: float) -> float:
		return CampDay.height(x, z)
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		if absf(x) < 2.2 and z < -24.0 and z > -60.0:
			return Color("9a7a52")
		var d := Vector2(x, z + 4.0).length()
		if d < 20.0:
			return Color("8a7050").lerp(Color("6e7a44"), clampf((d - 12.0) / 8.0, 0.0, 1.0))
		return Color("4b7a35").lerp(Color("62893e"), noise.get_noise_2d(x * 3.0, z * 3.0) * 0.5 + 0.5)
	add_child(LowPoly.terrain(-90.0, 90.0, -110.0, 70.0, 45, 45, hf, cf))
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(74, 1, 118)
	shape.shape = box
	shape.position = Vector3(0, -0.5, -26)
	floor_body.add_child(shape)
	add_child(floor_body)
	# Meydanın ortasında bayrak direği
	Props.cyl(self, 0.08, 7.0, Vector3(0, 3.5, -4.0), Color("6a4c30"), Vector3.ZERO, 6)
	Props.box(self, Vector3(0.02, 1.0, 1.6), Vector3(0, 6.3, -3.2), Color("c8262f"))
	Props.ring(self, 0.14, 0.22, Vector3(0.02, 6.3, -3.1), Color("f4f1ea"), Vector3(0, 90, 0))


func _pavilion(pos: Vector3, size: Vector2, color: Color, band: Color) -> void:
	for k in 4:
		var p := pos + Vector3((k % 2 - 0.5) * size.x, 1.5, (k / 2 - 0.5) * size.y)
		Props.cyl(self, 0.07, 3.0, p, Color("5a4028"), Vector3.ZERO, 6)
	Props.box(self, Vector3(size.x + 0.6, 0.08, size.y + 0.6), pos + Vector3(0, 3.05, 0), color)
	Props.prism(self, Vector3(size.x + 0.6, 1.0, size.y + 0.6), pos + Vector3(0, 3.6, 0), color.darkened(0.06))
	Props.box(self, Vector3(size.x + 0.62, 0.3, 0.04), pos + Vector3(0, 2.85, size.y / 2 + 0.3), band)
	Props.box(self, Vector3(size.x + 0.62, 0.3, 0.04), pos + Vector3(0, 2.85, -size.y / 2 - 0.3), band)


func _sign(pos: Vector3, text: String, rot := 0.0) -> void:
	Props.cyl(self, 0.05, 2.2, pos + Vector3(0, 1.1, 0), Color("4a3020"), Vector3.ZERO, 5)
	Props.box(self, Vector3(1.8, 0.45, 0.06), pos + Vector3(0, 2.0, 0), Color("c8a868"), Vector3(0, rot, 0))
	Props.label(self, text, pos + Vector3(0, 2.0, 0) + Vector3(sin(deg_to_rad(rot)), 0, cos(deg_to_rad(rot))) * 0.035, 36, Color("2a1a10"), Vector3(0, rot, 0), 1.6)


# ---------------------------------------------------------------- A · mutfak

## Mutfağın batısında tavuk kümesi: çitle çevrili avlu, kümes, yem; üç serbest tavuk (kovalanabilir).
## Hattat (yan karakter): tercüman çadırının yanında alçak yazı masası, kâğıtlar, hokka.
func _build_calligrapher() -> void:
	var p := Vector3(7.2, 0, -5.4)
	Props.solid(self, Vector3(1.2, 0.35, 0.6), p + Vector3(0, 0.175, 0.7), Color("6b4428"))
	Props.box(self, Vector3(0.5, 0.01, 0.35), p + Vector3(-0.2, 0.36, 0.7), Color("efe6cf"), Vector3(0, 8, 0))
	Props.cyl(self, 0.05, 0.08, p + Vector3(0.35, 0.39, 0.65), Color("1a1a1a"), Vector3.ZERO, 8)
	Props.cyl(self, 0.006, 0.25, p + Vector3(0.3, 0.45, 0.7), Color("c8a060"), Vector3(0, 0, 30), 4)
	for k in 3:
		Props.cyl(self, 0.04, 0.4, p + Vector3(-0.8, 0.05 + k * 0.08, 0.3), Color("efe6cf"), Vector3(0, 0, 90), 6)
	var h := Person.new({"coat": Color("3a4a6a"), "pants": Color("2a2a30"), "hat": "turban", "beard": true, "robe": Color("3a4a6a"), "hair": Color("5a5a5a")})
	h.position = p
	add_child(h)
	Props.interactable(self, "npc:calligrapher", Vector3(1.2, 2.0, 1.4), p + Vector3(0, 1.0, 0.3))


func _build_chicken_yard() -> void:
	var yard := Rect2(-19.0, -2.0, 6.0, 7.0)
	var wood := Color("8a6440")
	var c := Vector3(yard.get_center().x, 0, yard.get_center().y)
	for x in [yard.position.x, yard.end.x]:
		Props.box(self, Vector3(0.06, 0.06, yard.size.y), Vector3(x, 0.55, c.z), wood)
		Props.box(self, Vector3(0.06, 0.06, yard.size.y), Vector3(x, 0.25, c.z), wood)
	for z in [yard.position.y, yard.end.y]:
		Props.box(self, Vector3(yard.size.x, 0.06, 0.06), Vector3(c.x, 0.55, z), wood)
		Props.box(self, Vector3(yard.size.x, 0.06, 0.06), Vector3(c.x, 0.25, z), wood)
	var x := yard.position.x
	while x <= yard.end.x + 0.01:
		for z in [yard.position.y, yard.end.y]:
			Props.cyl(self, 0.04, 0.7, Vector3(x, 0.35, z), Color("6b4428"), Vector3.ZERO, 4)
		x += 1.5
	Props.solid(self, Vector3(1.4, 1.0, 1.1), Vector3(yard.position.x + 0.9, 0.5, yard.position.y + 0.8), Color("a07a4e"))
	Props.prism(self, Vector3(1.6, 0.6, 1.3), Vector3(yard.position.x + 0.9, 1.3, yard.position.y + 0.8), Color("8a2b22"))
	for k in 8:
		Props.ball(self, 0.04, Vector3(c.x + randf_range(-1.5, 1.5), 0.03, c.z + randf_range(-1.5, 1.5)), Color("e0b85a"), Vector3.ONE, 4)
	for k in 3:
		var hen := Chicken.new()
		hen.yard = yard
		hen.position = Vector3(c.x - 1.0 + k, 0, c.z - 1.0 + k * 0.8)
		add_child(hen)


func _build_kitchen() -> void:
	var c := Vector3(-13.0, 0, -8.0)
	_pavilion(c, Vector2(6.0, 4.0), Color("e0d4b8"), Color("8a2b22"))
	_sign(Vector3(-9.0, 0, -3.8), "MUTFAK", 45.0)
	# Kazanlar ve ocak
	for i in 3:
		var p := c + Vector3(-1.8 + i * 1.8, 0, -0.8)
		Props.cyl(self, 0.5, 0.4, p + Vector3(0, 0.2, 0), Color("6a6a70"), Vector3.ZERO, 8)
		Props.cyl(self, 0.62, 0.7, p + Vector3(0, 0.75, 0), Color("b87a3a"), Vector3.ZERO, 12, 0.55)
		Props.cyl(self, 0.56, 0.02, p + Vector3(0, 1.11, 0), Color("d8b070"), Vector3.ZERO, 12)
		lights.append(Night.campfire(self, p + Vector3(0, 0.05, 0), 0.5))
	# Tezgâh, soğan ve nohut çuvalları
	Props.box(self, Vector3(3.0, 0.9, 0.8), c + Vector3(0, 0.45, 1.4), Color("8a6440"))
	for i in 6:
		Props.ball(self, 0.09, c + Vector3(-1.2 + i * 0.45, 0.98, 1.4), Color("c8a060") if i % 2 == 0 else Color("e8e0cc"), Vector3.ONE, 6)
	for i in 3:
		Props.ball(self, 0.35, c + Vector3(2.9, 0.3, -1.4 + i * 0.8), Color("c8b894"), Vector3(1, 0.9, 1), 7)
	# Kadri'nin dev kazanı ve erzak fıçıları (Kimi modelleri)
	Props.model(self, "cauldron", c + Vector3(-3.6, 0, -1.2), 20.0, 1.2)
	Props.interactable(self, "mg:cauldron", Vector3(1.8, 1.6, 1.8), c + Vector3(-3.6, 0.8, -1.2))
	for bp in [c + Vector3(-3.4, 0, 1.3), c + Vector3(-3.6, 0, 2.2), c + Vector3(-4.3, 0, 1.7)]:
		Props.model(self, "barrel", bp, randf() * 360.0)
	kadri = Person.new({"coat": Color("f3efe4"), "pants": Color("6a5a48"), "hat": "cook", "mustache": true, "hair": Color("2a1e14"), "apron": Color("e8e2d4"), "skin": Color("d9a07a")})
	kadri.position = KADRI_POS
	kadri.scale = Vector3(1.12, 1.0, 1.12)
	add_child(kadri)
	Props.interactable(self, "kadri", Vector3(1.2, 2.0, 1.2), KADRI_POS + Vector3(0, 1.0, 0))


# ---------------------------------------------------------------- B · tercüman

func _build_interpreter() -> void:
	var c := Vector3(13.0, 0, -8.0)
	var t := Night.tent(self, c + Vector3(0, 0, -1.0), 3.0, Color("e8e0cc"), Color("2f5fa8"))
	t.rotation.y = 0.0
	_sign(Vector3(9.0, 0, -3.8), "TERCÜMAN", -45.0)
	# Masa, parşömenler, mürekkep
	Props.box(self, Vector3(1.8, 0.75, 0.9), c + Vector3(0, 0.375, 2.2), Color("7a5a38"))
	for i in 4:
		Props.cyl(self, 0.05, 0.5, c + Vector3(-0.6 + i * 0.35, 0.8, 2.0), Color("efe6cf"), Vector3(0, 0, 90), 6)
	Props.cyl(self, 0.06, 0.1, c + Vector3(0.7, 0.8, 2.4), Color("1a1a1a"), Vector3.ZERO, 8)
	# "7 dil" tabelası
	Props.box(self, Vector3(1.6, 0.5, 0.05), c + Vector3(0, 1.6, 2.7), Color("f4f1ea"))
	Props.label(self, "7 DİL · 1 TERCÜMAN", c + Vector3(0, 1.6, 2.73), 30, Color("2f5fa8"), Vector3.ZERO, 1.4)
	lutfi = Person.new({"coat": Color("3a6b3a"), "pants": Color("2a3a2a"), "hat": "turban", "mustache": true, "beard": true, "hair": Color("3a2a1e"), "robe": Color("3a6b3a")})
	lutfi.position = LUTFI_POS
	add_child(lutfi)
	Props.interactable(self, "lutfi", Vector3(1.2, 2.0, 1.2), LUTFI_POS + Vector3(0, 1.0, 0))


# ---------------------------------------------------------------- C · topçu

func _build_artillery() -> void:
	var c := Vector3(3.0, 0, -21.0)
	_sign(Vector3(-2.0, 0, -15.5), "TOPÇU", 20.0)
	# Büyük top: bronz namlu, ahşap kızak, yanında dev gülleler
	cannon = Node3D.new()
	cannon.position = c
	cannon.rotation.y = deg_to_rad(-20)
	add_child(cannon)
	Props.box(cannon, Vector3(2.2, 0.5, 7.0), Vector3(0, 0.25, 0), Color("6a4a2c"))
	Props.cyl(cannon, 0.95, 6.2, Vector3(0, 1.3, 0.2), Color("b8863a"), Vector3(90, 0, 0), 14, 0.8)
	Props.cyl(cannon, 1.0, 0.25, Vector3(0, 1.3, -2.8), Color("a47430"), Vector3(90, 0, 0), 14)
	Props.cyl(cannon, 0.85, 0.25, Vector3(0, 1.3, 3.1), Color("a47430"), Vector3(90, 0, 0), 14)
	Props.cyl(cannon, 0.6, 0.05, Vector3(0, 1.3, 3.25), Color("1a1a1a"), Vector3(90, 0, 0), 14)
	# Çatlak
	var crack := Props.box(cannon, Vector3(0.06, 0.5, 0.9), Vector3(0.9, 1.6, -0.6), Color("2a1a10"), Vector3(0, 0, 25))
	crack.name = "Crack"
	for i in 5:
		Props.ball(self, 0.45, c + Vector3(3.2 + (i % 3) * 0.9, 0.45 + (i / 3) * 0.8, 1.5 - (i / 3) * 0.4), Color("6a6a70"), Vector3.ONE, 8)
	for i in 3:
		Props.cyl(self, 0.4, 0.9, c + Vector3(-3.5, 0.45, -1.5 + i * 1.0), Color("5a3a24"), Vector3.ZERO, 8)
	# Döküm kalıbı: Urban'ın bir sonraki topu (içinde bronz kızarır)
	Props.model(self, "mold", c + Vector3(-5.2, 0, 2.6), 35.0, 1.3)
	urban = Person.new({"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "mustache": true, "beard": true, "hair": Color("8a5a2a"), "apron": Color("4a3020"), "skin": Color("e8b894")})
	urban.position = URBAN_POS
	urban.scale = Vector3(1.2, 1.1, 1.2)
	add_child(urban)
	Props.interactable(self, "urban", Vector3(1.3, 2.2, 1.3), URBAN_POS + Vector3(0, 1.1, 0))
	Props.interactable(self, "cannon", Vector3(2.4, 2.5, 3.0), c + Vector3(0, 1.3, 0))


## Topçu alanının doğusunda okçuluk talim alanı (mini oyun): iki saman hedef, atış çizgisi, yay sehpası.
## Urban'ın yanında hatıra gülle tezgâhı (pazarlık mini oyunu).
func _build_archery() -> void:
	var a := Vector3(16.5, 0, -18.0)
	_sign(a + Vector3(-3.2, 0, 4.2), "TALİM", -20.0)
	for k in 2:
		var t := a + Vector3(-1.8 + k * 3.6, 0, -5.0)
		for sx in [-0.45, 0.45]:
			Props.cyl(self, 0.06, 2.2, t + Vector3(sx, 1.0, 0.15), Color("5a3a22"), Vector3(-12, 0, sx * 20.0), 5)
		var rings := [Color("d8b860"), Color("f4f0e4"), Color("2a2a2a"), Color("2f5fa8"), Color("c8262f"), Color("ffd24a")]
		for r in rings.size():
			Props.cyl(self, 0.95 - r * 0.16 if r > 0 else 1.02, 0.12 + r * 0.01, t + Vector3(0, 1.6, 0.02 * r), rings[r], Vector3(90, 0, 0), 20)
		Props.ball(self, 0.1, t + Vector3(0, 2.72, 0), Color("c8262f"), Vector3.ONE, 8)
		for i in 3:
			var off := Vector3(-0.3 + i * 0.25, 1.3 + (i % 2) * 0.35, 0.1)
			Props.cyl(self, 0.012, 0.6, t + off + Vector3(0, 0, 0.3), Color("6a4a2a"), Vector3(80, 0, 0), 4)
	for k in 3:
		Props.solid(self, Vector3(1.2, 0.6, 0.7), a + Vector3(-4.4 + k * 0.3, 0.3, -6.5 + k * 1.2), Color("d8b860"))
	# Atış çizgisi, yay sehpası, ok sepeti
	Props.box(self, Vector3(5.0, 0.03, 0.12), a + Vector3(0, 0.02, 2.2), Color("f2e6c9"))
	Props.solid(self, Vector3(1.4, 1.0, 0.25), a + Vector3(2.8, 0.5, 2.6), Color("6b4428"))
	for i in 3:
		Props.ring(self, 0.35, 0.4, a + Vector3(2.4 + i * 0.4, 1.3, 2.6), Color("8a5a2a"), Vector3(0, 0, 90))
	Props.cyl(self, 0.16, 0.6, a + Vector3(-2.6, 0.3, 2.6), Color("6a3a22"), Vector3.ZERO, 8)
	for i in 5:
		Props.cyl(self, 0.01, 0.5, a + Vector3(-2.66 + i * 0.03, 0.8, 2.6), Color("c8a868"), Vector3(0, 0, -8 + i * 4), 4)
	var archer := Person.new({"coat": Color("8a2b22"), "pants": Color("3a2a1e"), "hat": "turban", "mustache": true})
	archer.position = a + Vector3(-1.2, 0, 2.6)
	archer.rotation.y = PI
	add_child(archer)
	Props.interactable(self, "mg:archery", Vector3(1.8, 2.0, 1.4), a + Vector3(2.6, 1.0, 2.6))
	# Hatıra gülle tezgâhı (Urban)
	var u := Vector3(-6.8, 0, -17.2)
	Props.solid(self, Vector3(1.6, 0.8, 0.8), u + Vector3(0, 0.4, 0), Color("5a3a24"))
	for i in 5:
		Props.ball(self, 0.1 + (i % 2) * 0.04, u + Vector3(-0.55 + i * 0.27, 0.92, 0.05 * (i % 2)), Color("6a6a70"), Vector3.ONE, 8)
	Props.cyl(self, 0.03, 1.6, u + Vector3(0.7, 0.8, -0.3), Color("4a3020"), Vector3.ZERO, 5)
	Props.box(self, Vector3(1.3, 0.35, 0.05), u + Vector3(0.1, 1.6, -0.3), Color("c8a868"))
	Props.label(self, "HATIRA GÜLLE", u + Vector3(0.1, 1.6, -0.27), 30, Color("2a1a10"), Vector3.ZERO, 1.2)
	Props.interactable(self, "mg:haggle_urban", Vector3(1.8, 1.4, 1.2), u + Vector3(0, 0.8, 0.2))


# ---------------------------------------------------------------- Y · pazar

func _build_market() -> void:
	_sign(Vector3(-2.5, 0, 7.2), "PAZAR", 0.0)
	var awning := [Color("b3262d"), Color("2f5fa8"), Color("c98a3a"), Color("3a6b3a"), Color("6a3a7a")]
	for i in 5:
		var p := Vector3(-8.0 + i * 4.0, 0, 17.0)
		Props.solid(self, Vector3(2.4, 0.9, 1.2), p + Vector3(0, 0.45, 0), Color("7a5a38"))
		for k in 4:
			Props.cyl(self, 0.04, 2.2, p + Vector3(-1.1 + (k % 2) * 2.2, 1.1, -0.55 + (k / 2) * 1.1), Color("4a3020"), Vector3.ZERO, 4)
		Props.box(self, Vector3(2.8, 0.05, 1.8), p + Vector3(0, 2.2, 0.2), awning[i], Vector3(-10, 0, 0))
		for k in 5:
			Props.ball(self, 0.13, p + Vector3(-0.9 + k * 0.45, 1.0, -0.2), [Color("e0a020"), Color("b3262d"), Color("6a8a3a"), Color("e8e0cc"), Color("c98a3a")][(k + i) % 5], Vector3.ONE, 6)
	# Kaçak keçi
	goat = Goat.new()
	goat.position = Vector3(0, 0, 11.0)
	goat.bounds = Rect2(-7.0, 8.5, 14.0, 6.5)
	add_child(goat)
	Props.interactable(goat, "goat", Vector3(0.9, 1.0, 1.1), Vector3(0, 0.5, 0))
	# Kayıp mühür yüzüğü: tozun içinde parıldar
	ring_node = Node3D.new()
	ring_node.position = RING_POS
	add_child(ring_node)
	var r := Props.ring(ring_node, 0.03, 0.05, Vector3(0, 0.02, 0), Color("ffd24a"), Vector3.ZERO, 3.0)
	r.material_override = Props.mat(Color("ffd24a"), 3.0, false, "", false)
	Props.ball(ring_node, 0.025, Vector3(0.04, 0.035, 0), Color("c8262f"), Vector3.ONE, 5, 2.0)
	Props.interactable(ring_node, "ring", Vector3(0.6, 0.4, 0.6), Vector3(0, 0.2, 0))
	# Mektup yazdıracak asker (okuma yazma bilmiyor)
	letter_soldier = Soldier.new(Color("3a6b3a"), "stand", "bork")
	letter_soldier.position = SOLDIER_POS
	letter_soldier.rotation.y = PI * 0.8
	add_child(letter_soldier)
	Props.box(self, Vector3(0.5, 0.45, 0.5), SOLDIER_POS + Vector3(0.8, 0.22, 0.2), Color("8a6440"))
	Props.interactable(self, "letter", Vector3(1.0, 1.9, 1.0), SOLDIER_POS + Vector3(0, 0.95, 0))
	# Çandarlı'nın adamı: pazarın arkasında, kukuletalı
	candarli = Person.new({"coat": Color("2a2a30"), "pants": Color("1f1f24"), "hat": "hood", "robe": Color("2a2a30"), "mustache": true, "hair": Color("1a1a1a")})
	candarli.position = CANDARLI_POS
	candarli.rotation.y = PI
	add_child(candarli)
	Props.interactable(self, "candarli", Vector3(1.2, 2.0, 1.2), CANDARLI_POS + Vector3(0, 1.0, 0))


# ---------------------------------------------------------------- otağ

func _build_otag() -> void:
	_sign(Vector3(2.6, 0, ROAD_Z + 2.0), "OTAĞ ↑", 0.0)
	var base := OTAG_POS
	# Padişah'ın otağı: büyük, kırmızı-altın, sivri tepeli
	Props.cyl(self, 7.0, 4.0, base + Vector3(0, 2.0, 0), Color("b3262d"), Vector3.ZERO, 16)
	Props.cyl(self, 7.4, 3.2, base + Vector3(0, 5.6, 0), Color("c8323a"), Vector3.ZERO, 16, 0.3)
	Props.cyl(self, 7.05, 0.5, base + Vector3(0, 3.8, 0), Color("d8b040"), Vector3.ZERO, 16)
	Props.cyl(self, 0.08, 2.4, base + Vector3(0, 8.4, 0), Color("d8b040"), Vector3.ZERO, 6)
	Props.ball(self, 0.3, base + Vector3(0, 9.7, 0), Color("d8b040"), Vector3.ONE, 8)
	for i in 8:
		if i == 0:
			continue          # yolun üstündeki çadır kapıyı kapatıyordu
		var a := TAU * i / 8.0
		Night.tent(self, base + Vector3(sin(a) * 13.0, 0, cos(a) * 13.0), 2.0, Color("e0d4b8"), Color("d8b040"))
	# Yol kenarında sancaklar
	for z in [-34.0, -40.0, -46.0, -52.0]:
		for side in [-1, 1]:
			var y := 0.0
			Props.cyl(self, 0.05, 4.0, Vector3(side * 2.8, y + 2.0, z), Color("5a4028"), Vector3.ZERO, 5)
			Props.box(self, Vector3(0.02, 1.2, 0.8), Vector3(side * 2.8, y + 3.4, z + 0.45), Color("c8262f") if side < 0 else Color("3a6b3a"))


## Derin manzara: oynanan alanın dışında yüzlerce çadır, askerler, atlar, dumanlar; güneyde Konstantinopolis'in
## kara surları ve ardında şehir; çevrede ağaçlar ve ufku kapatan tepeler (boş ufuk yok).
func _build_scenery() -> void:
	var avoid := [Rect2(-26, -36, 52, 62), Rect2(-9, -92, 18, 60), Rect2(-22, -84, 44, 30)]
	var hf := func(x: float, z: float) -> float:
		return CampDay.height(x, z)
	Scenery.camp(self, Vector3(0, 0, -20), 28.0, 125.0, 320, avoid, hf)
	Scenery.trees(self, Vector3(0, 0, -20), 60.0, 150.0, 160, avoid + [Rect2(-300, 55, 600, 300)], hf, 11)
	# Arazinin bittiği yerde zemin devam eder (ufuk boşluğu yok)
	for spec in [[Vector3(900, 2, 400), Vector3(0, 2.4, 270)], [Vector3(900, 2, 400), Vector3(0, 2.4, -310)],
			[Vector3(360, 2, 180), Vector3(-270, 2.4, -20)], [Vector3(360, 2, 180), Vector3(270, 2.4, -20)]]:
		var g := Props.box(self, spec[0], spec[1], Color("5f7a3c"))
		g.material_override = Props.mat(Color("5f7a3c"), 0.0, false, "", false)
	var walls := Node3D.new()
	walls.position = Vector3(0, 3.6, 0)
	add_child(walls)
	Scenery.city_walls(walls, 118.0, 520.0, 1.0)
	Scenery.hills(self, Vector3(0, 0, -30), 230.0, 30, Color("6a7a48"))
	Scenery.ground_detail(self, Rect2(-85, -105, 170, 170), 2600, hf)
	# Meydanın kenarlarında eşya yığınları (oynanan noktaları kapatmaz)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var spots: Array = []
	for i in 60:
		var a := rng.randf() * TAU
		var r := rng.randf_range(20.0, 34.0)
		var p := Vector3(sin(a) * r, 0, cos(a) * r - 6.0)
		if absf(p.x) < 8.0 and p.z < -18.0:
			continue
		p.y = CampDay.height(p.x, p.z)
		spots.append(p)
	Scenery.camp_clutter(self, spots)


func _build_tents() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 6
	var colors := [Color("d8cbb0"), Color("c8b894"), Color("e0d4b8")]
	var bands := [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a"), Color("c98a3a")]
	for i in 40:
		var a := rng.randf() * TAU
		var r := rng.randf_range(26.0, 70.0)
		var p := Vector3(sin(a) * r, 0, cos(a) * r - 8.0)
		if absf(p.x) < 6.0 and p.z < -20.0:
			continue
		p.y = CampDay.height(p.x, p.z) - 0.15
		var t := Night.tent(self, p, rng.randf_range(1.6, 2.6), colors[i % 3], bands[i % 4])
		t.rotation.y = rng.randf() * TAU
	_build_scenery()
