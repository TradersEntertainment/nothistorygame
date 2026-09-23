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


func _ready() -> void:
	_build_sky()
	_build_ground()
	_build_kitchen()
	_build_interpreter()
	_build_artillery()
	_build_market()
	_build_otag()
	_build_tents()


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
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, 150, 0)
	sun.light_color = Color("ffe9c7")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 60.0
	add_child(sun)


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
	urban = Person.new({"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "mustache": true, "beard": true, "hair": Color("8a5a2a"), "apron": Color("4a3020"), "skin": Color("e8b894")})
	urban.position = URBAN_POS
	urban.scale = Vector3(1.2, 1.1, 1.2)
	add_child(urban)
	Props.interactable(self, "urban", Vector3(1.3, 2.2, 1.3), URBAN_POS + Vector3(0, 1.1, 0))
	Props.interactable(self, "cannon", Vector3(2.4, 2.5, 3.0), c + Vector3(0, 1.3, 0))


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
	# Uzakta Bizans surları
	var wall_z := 140.0
	Props.box(self, Vector3(400, 14, 6), Vector3(0, 5, wall_z), Color("c9b89a"))
	for i in 16:
		Props.box(self, Vector3(9, 20, 9), Vector3(-180.0 + i * 24.0, 8, wall_z - 2), Color("bfae90"))
