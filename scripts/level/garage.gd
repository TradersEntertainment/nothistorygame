class_name Garage
extends Node3D
## Hikmet'in garajı (Bölüm 1). Bütün geometri kodla, low-poly parçalardan kurulur.
## Garaj: x -4..4, z -3..3, tavan 3.2 m. Zamanatör arka duvarın önünde.

const W := 8.0
const D := 6.0
const H := 3.2

const C_FLOOR := Color("454a52")
const C_WALL := Color("5d6673")
const C_WALL_DARK := Color("4b5360")
const C_WOOD := Color("8a5a36")
const C_WOOD_DARK := Color("6b4428")
const C_METAL := Color("8d949e")
const C_TAPE := Color("c98a3a")

const SPAWN_POS := Vector3(0.0, 0.0, 2.3)
const HIKMET_POS := Vector3(-1.4, 0.0, -0.4)
const PLATFORM_POS := Vector3(0.0, 0.0, -1.6)

var items: Dictionary = {}          # id -> {"node": Node3D, "body": StaticBody3D}
var rings: Array[Node3D] = []
var panel_screen: Label3D
var panel_node: Node3D
var machine_light: OmniLight3D
var fluoro_light: OmniLight3D
var fluoro_tube: MeshInstance3D
var frame_inner: MeshInstance3D
var spin := 1.0                     # halkaların dönüş hızı çarpanı
var _flicker_t := 0.0
var _mirror_wall: Node3D


func _ready() -> void:
	Audio.voice_space("room")
	_build_room()
	_build_lights()
	_build_furniture()
	_build_machine()
	_build_items()


func _process(delta: float) -> void:
	# Floresan lamba ara sıra titrer.
	_flicker_t -= delta
	if _flicker_t <= 0.0:
		_flicker_t = randf_range(0.05, 3.5)
		var on := randf() > 0.12
		fluoro_light.light_energy = 1.3 if on else 0.35
		fluoro_tube.material_override = Props.mat(Color("e8f4ff"), 2.5 if on else 0.3)
	for i in rings.size():
		rings[i].rotate_y(delta * spin * (0.25 + i * 0.15) * (1.0 if i % 2 == 0 else -1.0))


func _build_room() -> void:
	# Zemin ve tavan
	Props.set_pattern(Props.solid(self, Vector3(W, 0.2, D), Vector3(0, -0.1, 0), C_FLOOR), C_FLOOR, "concrete")
	Props.set_pattern(Props.solid(self, Vector3(W, 0.2, D), Vector3(0, H + 0.1, 0), Color("3a3f48")), Color("3a3f48"), "wall")
	# Duvarlar
	Props.set_pattern(Props.solid(self, Vector3(W, H, 0.2), Vector3(0, H / 2, -D / 2 - 0.1), C_WALL), C_WALL, "wall")
	Props.set_pattern(Props.solid(self, Vector3(0.2, H, D), Vector3(-W / 2 - 0.1, H / 2, 0), C_WALL_DARK), C_WALL_DARK, "wall")
	_mirror_wall = Props.solid(self, Vector3(0.2, H, D), Vector3(W / 2 + 0.1, H / 2, 0), C_WALL_DARK)
	Props.set_pattern(_mirror_wall, C_WALL_DARK, "wall")
	Props.set_pattern(Props.solid(self, Vector3(W, H, 0.2), Vector3(0, H / 2, D / 2 + 0.1), C_WALL), C_WALL, "wall")
	# Garaj kapısı (içeriden): yatay kanatlar
	for i in 6:
		Props.box(self, Vector3(4.4, 0.36, 0.05), Vector3(0, 0.25 + i * 0.4, D / 2 - 0.02), Color("7d8794") if i % 2 == 0 else Color("737d8a"))
	Props.box(self, Vector3(0.08, 2.5, 0.1), Vector3(-2.25, 1.25, D / 2 - 0.05), C_METAL)
	Props.box(self, Vector3(0.08, 2.5, 0.1), Vector3(2.25, 1.25, D / 2 - 0.05), C_METAL)
	# Yağ lekeleri
	Props.cyl(self, 0.6, 0.01, Vector3(1.8, 0.005, 1.0), Color("2f3237"), Vector3.ZERO, 12)
	Props.cyl(self, 0.35, 0.01, Vector3(-0.9, 0.005, 1.6), Color("33363c"), Vector3.ZERO, 10)
	# Duvar dibi şeridi
	Props.box(self, Vector3(W, 0.12, 0.03), Vector3(0, 0.06, -D / 2 + 0.015), Color("3f4650"))


func _build_lights() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("0c0f16")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("5a6a8a")
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.6
	e.glow_bloom = 0.05
	env.environment = e
	add_child(env)

	# Floresan tüp
	fluoro_tube = Props.cyl(self, 0.04, 1.6, Vector3(0, H - 0.12, 0.3), Color("e8f4ff"), Vector3(0, 0, 90), 6, -1.0, 2.5)
	Props.box(self, Vector3(1.7, 0.05, 0.14), Vector3(0, H - 0.05, 0.3), C_METAL)
	fluoro_light = OmniLight3D.new()
	fluoro_light.position = Vector3(0, H - 0.3, 0.3)
	fluoro_light.omni_range = 9.0
	fluoro_light.light_energy = 1.3
	fluoro_light.light_color = Color("dfeeff")
	fluoro_light.shadow_enabled = true
	add_child(fluoro_light)

	# Tezgâh lambası (sıcak ışık)
	var lamp := SpotLight3D.new()
	lamp.position = Vector3(-3.0, 2.0, 0.0)
	lamp.rotation_degrees = Vector3(-90, 0, 0)
	lamp.spot_range = 3.0
	lamp.spot_angle = 45.0
	lamp.light_energy = 1.6
	lamp.light_color = Color("ffc98a")
	add_child(lamp)
	Props.cyl(self, 0.18, 0.2, Vector3(-3.0, 2.1, 0.0), Color("2d6a4f"), Vector3.ZERO, 8, 0.08)
	Props.cyl(self, 0.01, 1.0, Vector3(-3.0, 2.7, 0.0), Color("222222"), Vector3.ZERO, 4)

	# Makinenin ışığı
	machine_light = OmniLight3D.new()
	machine_light.position = PLATFORM_POS + Vector3(0, 1.4, 0)
	machine_light.omni_range = 3.5
	machine_light.light_energy = 0.7
	machine_light.light_color = Color("6ff2c8")
	add_child(machine_light)


func _build_furniture() -> void:
	# Sol duvar: tezgâh
	Props.set_pattern(Props.solid(self, Vector3(0.9, 0.08, 3.8), Vector3(-3.5, 0.86, 0.0), C_WOOD), C_WOOD, "wood")
	for z in [-1.8, 1.8]:
		for x in [-3.85, -3.15]:
			Props.box(self, Vector3(0.07, 0.82, 0.07), Vector3(x, 0.41, z), C_WOOD_DARK)
	Props.box(self, Vector3(0.85, 0.05, 3.7), Vector3(-3.5, 0.25, 0.0), C_WOOD_DARK)
	# Tezgâhın üstünde alet panosu
	Props.box(self, Vector3(0.04, 1.0, 2.4), Vector3(-3.97, 1.7, 0.0), Color("b89060"))
	for i in 7:
		Props.box(self, Vector3(0.05, 0.3 + (i % 3) * 0.1, 0.05), Vector3(-3.93, 1.75, -1.0 + i * 0.33), C_METAL)
	# Sol duvar: 1977 takvimi (Hikmet'in geçmişi, CHAPTERS §3.3)
	Props.picture(self, "res://assets/art/posters/calendar.svg", 0.5, Vector3(-3.985, 1.75, 2.2), Vector3(0, 90, 0))
	Props.label(self, "1977", Vector3(-3.975, 1.92, 2.2), 56, Color("f3ecd8"), Vector3(0, 90, 0), 0.36)

	# Sağ duvar: raflar
	for y in [0.86, 1.46, 2.06]:
		Props.set_pattern(Props.solid(self, Vector3(0.6, 0.05, 3.4), Vector3(3.68, y, 0.0), C_WOOD), C_WOOD, "wood")
	for z in [-1.7, 1.7]:
		Props.box(self, Vector3(0.05, 2.1, 0.05), Vector3(3.4, 1.05, z), C_WOOD_DARK)
	# Eski televizyon ve radyo (üst raf)
	Props.box(self, Vector3(0.45, 0.4, 0.5), Vector3(3.7, 2.29, -1.0), Color("3b3226"))
	Props.box(self, Vector3(0.02, 0.28, 0.36), Vector3(3.47, 2.29, -1.0), Color("1a2320"), Vector3.ZERO, 0.4)
	Props.box(self, Vector3(0.3, 0.2, 0.5), Vector3(3.7, 2.19, 0.8), Color("7a4f2a"))
	Props.cyl(self, 0.05, 0.02, Vector3(3.54, 2.2, 0.95), Color("d9c9a3"), Vector3(0, 0, 90), 8)
	# Karton kutular
	Props.box(self, Vector3(0.6, 0.45, 0.5), Vector3(2.9, 0.225, 2.3), Color("b68a58"), Vector3(0, 12, 0))
	Props.box(self, Vector3(0.5, 0.35, 0.45), Vector3(2.95, 0.63, 2.28), Color("c39866"), Vector3(0, -8, 0))
	Props.box(self, Vector3(0.62, 0.05, 0.08), Vector3(2.9, 0.455, 2.3), C_TAPE, Vector3(0, 12, 0))

	# Arka duvar: boş çerçeve (gizli son, GDD §9.1)
	Props.box(self, Vector3(0.9, 0.7, 0.04), Vector3(-2.6, 1.9, -D / 2 + 0.03), Color("7b5a2e"))
	frame_inner = Props.box(self, Vector3(0.74, 0.54, 0.045), Vector3(-2.6, 1.9, -D / 2 + 0.035), Color("d9d2c0"))
	# Arka duvar: patent afişi
	Props.picture(self, "res://assets/art/posters/patent.svg", 0.85, Vector3(2.6, 1.9, -D / 2 + 0.015))
	# Yazı afişin sol üst bölümüne sığdırılır (sağ alttaki dişliye binmez)
	Props.label(self, "PATENT\nBEKLEMEDE", Vector3(2.46, 2.07, -D / 2 + 0.025), 28, Color("8a2b22"), Vector3.ZERO, 0.46)

	# Sandalye (Hikmet'in)
	Props.box(self, Vector3(0.45, 0.05, 0.45), Vector3(-2.2, 0.45, -0.9), C_WOOD)
	Props.box(self, Vector3(0.45, 0.5, 0.05), Vector3(-2.2, 0.72, -1.12), C_WOOD)
	for p in [Vector3(-2.4, 0.22, -0.7), Vector3(-2.0, 0.22, -0.7), Vector3(-2.4, 0.22, -1.1), Vector3(-2.0, 0.22, -1.1)]:
		Props.box(self, Vector3(0.04, 0.45, 0.04), p, C_WOOD_DARK)


func _build_machine() -> void:
	var m := Node3D.new()
	m.name = "Zamanator"
	m.position = PLATFORM_POS
	add_child(m)
	# Platform (çarpışmasız, üstüne çıkılabilir)
	Props.cyl(m, 1.0, 0.08, Vector3(0, 0.04, 0), Color("6d737c"), Vector3.ZERO, 12)
	Props.ring(m, 0.9, 1.0, Vector3(0, 0.08, 0), Color("e0b52a"))
	Props.cyl(m, 0.25, 0.01, Vector3(0, 0.085, 0), Color("6ff2c8"), Vector3.ZERO, 8, -1.0, 1.5)
	# Dönen halkalar
	for i in 2:
		var pivot := Node3D.new()
		pivot.position = Vector3(0, 1.25, 0)
		m.add_child(pivot)
		var r := Props.ring(pivot, 1.02, 1.12, Vector3.ZERO, Color("9aa3ad") if i == 0 else Color("7f8893"), Vector3(90, i * 90, 0))
		# Halkaya sarılmış koli bantları
		for a in [20, 140, 250]:
			var ang := deg_to_rad(a)
			var p := Vector3(cos(ang) * 1.07, sin(ang) * 1.07, 0).rotated(Vector3.UP, deg_to_rad(i * 90))
			Props.box(pivot, Vector3(0.16, 0.16, 0.16), p, C_TAPE, Vector3(0, i * 90, a))
		rings.append(pivot)
	# Tepe: huni ve anten
	Props.cyl(m, 0.12, 0.5, Vector3(0, 2.75, 0), Color("8d949e"), Vector3.ZERO, 8, 0.35)
	Props.ball(m, 0.09, Vector3(0, 3.02, 0), Color("ff5a4a"), Vector3.ONE, 8, 2.0)
	# Tavandan inen kablolar
	for x in [-0.5, 0.4]:
		Props.cyl(m, 0.02, 1.0, Vector3(x, 2.7, 0.1), Color("1e1e1e"), Vector3(0, 0, x * 20), 4)
	# Tabela: arka duvarda, halkaların dönüş alanının dışında
	Props.box(self, Vector3(1.5, 0.32, 0.04), Vector3(1.95, 2.72, -D / 2 + 0.03), Color("20252e"))
	Props.label(self, "ZAMANATÖR 3000", Vector3(1.95, 2.72, -D / 2 + 0.055), 52, Color("6ff2c8"), Vector3.ZERO, 1.3)

	# Kontrol paneli
	panel_node = Node3D.new()
	panel_node.position = Vector3(1.55, 0, -1.0)
	panel_node.rotation_degrees = Vector3(0, -35, 0)
	add_child(panel_node)
	Props.box(panel_node, Vector3(0.7, 1.0, 0.4), Vector3(0, 0.5, 0), Color("3d4450"))
	Props.box(panel_node, Vector3(0.72, 0.06, 0.5), Vector3(0, 1.02, 0.03), Color("2c313a"), Vector3(-20, 0, 0))
	Props.box(panel_node, Vector3(0.5, 0.18, 0.02), Vector3(0, 1.22, -0.1), Color("0f1a14"), Vector3(-10, 0, 0))
	panel_screen = Props.label(panel_node, "----", Vector3(0, 1.22, -0.085), 34, Color("6ff2c8"), Vector3(-10, 0, 0))
	for row in 3:
		for col in 4:
			Props.box(panel_node, Vector3(0.07, 0.02, 0.06), Vector3(-0.17 + col * 0.11, 1.07, 0.1 + row * 0.08 - 0.08), Color("c9ccd1"), Vector3(-20, 0, 0))
	Props.box(panel_node, Vector3(0.74, 0.06, 0.06), Vector3(0, 0.75, 0.21), C_TAPE, Vector3(0, 0, 8))
	Props.ball(panel_node, 0.035, Vector3(0.28, 1.25, -0.05), Color("ff3b30"), Vector3.ONE, 6, 2.0)
	Props.ball(panel_node, 0.035, Vector3(0.28, 1.15, -0.05), Color("ffd60a"), Vector3.ONE, 6, 2.0)
	# Kol
	Props.cyl(panel_node, 0.02, 0.4, Vector3(-0.42, 0.9, 0.05), C_METAL, Vector3(0, 0, 15), 6)
	Props.ball(panel_node, 0.05, Vector3(-0.47, 1.1, 0.05), Color("d8342c"), Vector3.ONE, 8)
	var col_body := Props.solid(panel_node, Vector3(0.7, 1.0, 0.4), Vector3(0, 0.5, 0), Color(0, 0, 0, 0))
	col_body.get_child(0).visible = false
	Props.interactable(panel_node, "panel", Vector3(0.8, 0.6, 0.6), Vector3(0, 1.1, 0))
	_build_mirror()


func _build_items() -> void:
	var spots := {
		"phone": Vector3(-3.4, 0.9, -1.45),
		"lighter": Vector3(-3.4, 0.9, -0.75),
		"book": Vector3(-3.4, 0.9, 0.0),
		"chickpeas": Vector3(-3.4, 0.9, 0.75),
		"tape": Vector3(-3.4, 0.9, 1.45),
		"powerbank": Vector3(3.6, 0.885, -1.2),
		"thermos": Vector3(3.6, 0.885, -0.4),
		"cologne": Vector3(3.6, 0.885, 0.4),
		"cube": Vector3(3.6, 0.885, 1.2),
		"selfie": Vector3(3.6, 1.485, 0.0),
	}
	for id in Items.IDS:
		var node := Items.build(id)
		node.position = spots[id]
		node.rotation_degrees.y = 90.0 if spots[id].x > 0 else -90.0
		if id == "selfie":
			node.rotation_degrees.y = 0.0
		add_child(node)
		var hs := Items.hit_size(id)
		var body := Props.interactable(node, "item:" + id, hs, Vector3(0, hs.y / 2.0, 0))
		items[id] = {"node": node, "body": body}


func set_item_visible(id: String, on: bool) -> void:
	var entry: Dictionary = items[id]
	(entry["node"] as Node3D).visible = on
	(entry["body"] as StaticBody3D).collision_layer = 2 if on else 0


## Kapının yanında boy aynası: Tolga kendine bakabilir (E ya da V).
func _build_mirror() -> void:
	var p := Vector3(W / 2.0 - 0.08, 0.0, 1.9)
	var frame := Props.box(self, Vector3(0.08, 1.9, 0.8), p + Vector3(0, 1.15, 0), Color("6a4a2c"))
	Mirror.make(self, Vector2(0.66, 1.7), p + Vector3(-0.05, 1.15, 0), Vector3.LEFT)
	Mirror.hide_from_reflection(frame)
	Mirror.hide_from_reflection(_mirror_wall)
	Props.interactable(self, "mirror", Vector3(0.6, 1.8, 0.9), p + Vector3(-0.3, 1.1, 0))
