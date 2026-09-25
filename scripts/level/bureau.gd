class_name Bureau
extends Node3D
## Zaman Bürosu: zamanın dışında duran bir devlet dairesi (CHAPTERS §3.2, Bölüm 3).
## Nihat'ın odası (Form Z-1, akrepsiz saat, hiçliğe bakan pencere), sise gömülüp
## sonsuza uzanan koridor (her kapıda bir yıl), kostüm deposu, Başdenetçi'nin
## kâğıt dağları arasındaki masası ve saha asansörü.

const OFFICE_W := 6.0
const OFFICE_D := 6.0
const OFFICE_H := 3.0
const COR_W := 4.0
const COR_H := 3.4
const COR_LEN := 84.0
const DEPOT_Z0 := -10.5
const DEPOT_Z1 := -17.5
const DESK_Z := -26.0
const LIFT_Z := -34.0

const SPAWN_POS := Vector3(0.0, 0.0, 1.6)
const MUFIDE_POS := Vector3(0.0, 0.0, DESK_Z - 1.0)
const RIZA_POS := Vector3(4.3, 0.0, -14.0)

const C_WALL := Color("7d8a78")
const C_WALL_LOW := Color("5d6b5c")
const C_WOOD := Color("7a4f30")
const C_WOOD_DARK := Color("5a3820")
const C_BRASS := Color("c49a45")
const C_PAPER := Color("efe9d8")
const C_METAL := Color("8b939a")

const YEARS := ["1071", "1204", "1299", "1492", "1517", "1683", "1789", "1826", "1908",
	"1923", "1969", "2026", "2150", "MÖ 44", "MÖ 776", "1453", "1453", "1453"]

var mufide: Person
var riza: Person
var file_node: Node3D
var capsule: Node3D
var fedora_node: Node3D
var lift_door: Node3D


func _ready() -> void:
	Audio.voice_space("room")
	_build_env()
	_build_office()
	_build_corridor()
	_build_depot()
	_build_desk()
	_build_lift()


# ---------------------------------------------------------------- ortam

func _build_env() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("2a3029")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("c9d6c0")
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	# Koridor sisin içinde kaybolur: sonsuz gibi
	e.fog_enabled = true
	e.fog_light_color = Color("2f3a31")
	e.fog_density = 0.055
	e.glow_enabled = true
	e.glow_intensity = 0.5
	env.environment = e
	add_child(env)


func _checker(c1: Color, c2: Color) -> ImageTexture:
	var img := Image.create(2, 2, false, Image.FORMAT_RGB8)
	img.set_pixel(0, 0, c1)
	img.set_pixel(1, 1, c1)
	img.set_pixel(1, 0, c2)
	img.set_pixel(0, 1, c2)
	return ImageTexture.create_from_image(img)


func _floor(size: Vector2, pos: Vector3, c1: Color, c2: Color, tiles: float) -> void:
	var body := Props.solid(self, Vector3(size.x, 0.2, size.y), pos + Vector3(0, -0.1, 0), c1)
	var m := StandardMaterial3D.new()
	m.albedo_texture = _checker(c1, c2)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3(tiles, tiles, tiles)
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.roughness = 0.6
	(body.get_child(0) as MeshInstance3D).material_override = m


func _wall(size: Vector3, pos: Vector3, color := C_WALL) -> void:
	Props.set_pattern(Props.solid(self, size, pos, color), color, "wall")


func _tube(pos: Vector3, lit := true) -> void:
	Props.box(self, Vector3(0.18, 0.06, 1.3), pos, Color("e8f4e0"), Vector3.ZERO, 2.2 if lit else 0.2)
	Props.box(self, Vector3(0.26, 0.04, 1.4), pos + Vector3(0, 0.05, 0), C_METAL)


# ---------------------------------------------------------------- Nihat'ın odası

func _build_office() -> void:
	var w := OFFICE_W
	var d := OFFICE_D
	var h := OFFICE_H
	_floor(Vector2(w, d), Vector3(0, 0, d / 2), Color("6b5a44"), Color("5e4e3a"), 0.8)
	Props.solid(self, Vector3(w, 0.2, d), Vector3(0, h + 0.1, d / 2), Color("c8c6b4"))
	_wall(Vector3(w, h, 0.2), Vector3(0, h / 2, d + 0.1))
	_wall(Vector3(0.2, h, d), Vector3(-w / 2 - 0.1, h / 2, d / 2))
	_wall(Vector3(0.2, h, d), Vector3(w / 2 + 0.1, h / 2, d / 2))
	# Kapılı ön duvar (koridora açılır)
	_wall(Vector3(w / 2 - 0.7, h, 0.2), Vector3(-(w / 2 + 0.7) / 2, h / 2, -0.1))
	_wall(Vector3(w / 2 - 0.7, h, 0.2), Vector3((w / 2 + 0.7) / 2, h / 2, -0.1))
	_wall(Vector3(1.4, h - 2.3, 0.2), Vector3(0, 2.3 + (h - 2.3) / 2, -0.1))
	# Lambri (alt duvar bandı)
	for x in [-w / 2 + 0.03, w / 2 - 0.03]:
		Props.box(self, Vector3(0.04, 1.0, d), Vector3(x, 0.5, d / 2), C_WALL_LOW)
	Props.box(self, Vector3(w, 1.0, 0.04), Vector3(0, 0.5, d - 0.03), C_WALL_LOW)
	_tube(Vector3(0, h - 0.05, 2.0))
	_tube(Vector3(0, h - 0.05, 4.2))
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.6, 3.0)
	lamp.light_color = Color("f2f6e6")
	lamp.light_energy = 1.4
	lamp.omni_range = 7.0
	lamp.shadow_enabled = true
	add_child(lamp)

	# Masa, sandalye, daktilo
	var desk_z := 4.3
	Props.set_pattern(Props.solid(self, Vector3(2.2, 0.08, 1.0), Vector3(0, 0.78, desk_z), C_WOOD), C_WOOD, "wood")
	for x in [-1.0, 1.0]:
		Props.box(self, Vector3(0.12, 0.74, 0.9), Vector3(x, 0.37, desk_z), C_WOOD_DARK)
	Props.box(self, Vector3(0.5, 0.05, 0.5), Vector3(0, 0.48, desk_z + 0.9), C_WOOD_DARK)
	Props.box(self, Vector3(0.5, 0.6, 0.05), Vector3(0, 0.8, desk_z + 1.15), C_WOOD_DARK)
	_typewriter(Vector3(0.45, 0.82, desk_z - 0.05), 0.0)
	# Dosya (pnömatik tüpten gelecek)
	file_node = Node3D.new()
	file_node.position = Vector3(-0.45, 0.83, desk_z - 0.15)
	add_child(file_node)
	Props.box(file_node, Vector3(0.36, 0.03, 0.26), Vector3.ZERO, Color("c9a45a"))
	Props.box(file_node, Vector3(0.2, 0.005, 0.05), Vector3(0, 0.017, -0.05), Color("a8242a"))
	Props.label(file_node, "1453-T", Vector3(0.0, 0.021, 0.04), 30, Color("3a2a18"), Vector3(-90, 0, 0), 0.22)
	file_node.visible = false
	Props.interactable(file_node, "file", Vector3(0.5, 0.3, 0.4), Vector3(0, 0.1, 0)).collision_layer = 0
	# Pnömatik tüp: tavandan masanın köşesine
	Props.cyl(self, 0.09, 2.1, Vector3(-1.75, 1.95, desk_z + 0.3), C_BRASS, Vector3.ZERO, 10)
	Props.cyl(self, 0.13, 0.12, Vector3(-1.75, 0.9, desk_z + 0.3), C_BRASS, Vector3.ZERO, 10)
	capsule = Node3D.new()
	capsule.position = Vector3(-1.75, 2.9, desk_z + 0.3)
	add_child(capsule)
	Props.cyl(capsule, 0.07, 0.22, Vector3.ZERO, Color("6f8a96"), Vector3.ZERO, 8)
	capsule.visible = false
	# Dosya dolapları, saksı, portmanto
	for x in [-2.5, 2.5]:
		Props.set_pattern(Props.solid(self, Vector3(0.6, 1.4, 0.6), Vector3(x, 0.7, 5.55), Color("6f7a70")), Color("6f7a70"), "wall")
		for i in 3:
			Props.box(self, Vector3(0.5, 0.02, 0.02), Vector3(x, 0.35 + i * 0.42, 5.24), C_BRASS)
	Props.cyl(self, 0.18, 0.35, Vector3(2.5, 1.58, 5.55), Color("8a5a3a"), Vector3.ZERO, 8, 0.22)
	for i in 5:
		Props.cyl(self, 0.02, 0.4, Vector3(2.5 + (i - 2) * 0.05, 1.9, 5.55), Color("9a8a5a"), Vector3(0, i * 30, 20 - i * 10), 4)
	Props.interactable(self, "plant", Vector3(0.5, 0.6, 0.5), Vector3(2.5, 1.8, 5.55))
	Props.cyl(self, 0.03, 1.8, Vector3(-2.4, 0.9, 0.5), C_WOOD_DARK, Vector3.ZERO, 6)
	Props.cyl(self, 0.25, 0.03, Vector3(-2.4, 0.02, 0.5), C_WOOD_DARK, Vector3.ZERO, 8)

	# Form Z-1: arka duvarda çerçeve
	var fz := Node3D.new()
	fz.position = Vector3(0, 1.95, d - 0.02)
	fz.rotation_degrees.y = 180
	add_child(fz)
	Props.box(fz, Vector3(0.78, 0.98, 0.04), Vector3(0, 0, 0.0), C_BRASS)
	Props.box(fz, Vector3(0.66, 0.86, 0.045), Vector3(0, 0, 0.0), C_PAPER)
	Props.label(fz, "ZAMAN BÜROSU", Vector3(0, 0.33, 0.03), 26, Color("2a2a2a"), Vector3.ZERO, 0.5)
	Props.label(fz, "FORM Z-1", Vector3(0, 0.25, 0.03), 34, Color("8a1f1f"), Vector3.ZERO, 0.4)
	Props.label(fz, "KURULUŞ BELGESİ", Vector3(0, 0.17, 0.03), 18, Color("3a3a3a"), Vector3.ZERO, 0.4)
	for i in 6:
		Props.box(fz, Vector3(0.5, 0.008, 0.005), Vector3(0, 0.08 - i * 0.055, 0.025), Color("9a9a90"))
	Props.label(fz, "Kurucu:", Vector3(-0.17, -0.28, 0.03), 18, Color("3a3a3a"), Vector3.ZERO, 0.2)
	Props.label(fz, "T.", Vector3(0.08, -0.29, 0.03), 44, Color("1a2a6a"), Vector3.ZERO, 0.12)
	Props.cyl(fz, 0.07, 0.01, Vector3(0.2, -0.33, 0.03), Color("b8323a"), Vector3(90, 0, 0), 12)
	Props.interactable(self, "formz1", Vector3(0.9, 1.1, 0.4), Vector3(0, 1.95, d - 0.2))

	# Akrepsiz saat (sol duvar)
	var clock := Node3D.new()
	clock.position = Vector3(-w / 2 + 0.03, 2.2, 3.0)
	clock.rotation_degrees.y = 90
	add_child(clock)
	Props.cyl(clock, 0.28, 0.05, Vector3.ZERO, Color("f4f1e6"), Vector3(90, 0, 0), 20)
	Props.ring(clock, 0.26, 0.3, Vector3.ZERO, C_BRASS, Vector3(90, 0, 0))
	for i in 12:
		var a := TAU * i / 12.0
		Props.box(clock, Vector3(0.02, 0.05, 0.01), Vector3(sin(a) * 0.22, cos(a) * 0.22, 0.03), Color("2a2a2a"), Vector3(0, 0, -rad_to_deg(a)))
	Props.interactable(self, "clock", Vector3(0.3, 0.7, 0.7), Vector3(-w / 2 + 0.2, 2.2, 3.0))

	# Hiçliğe bakan pencere (sağ duvar)
	var win := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(1.6, 1.2)
	win.mesh = q
	var sm := ShaderMaterial.new()
	sm.shader = load("res://assets/shaders/void.gdshader")
	win.material_override = sm
	win.position = Vector3(w / 2 - 0.005, 1.7, 3.0)
	win.rotation_degrees.y = -90
	add_child(win)
	Props.box(self, Vector3(0.08, 1.35, 0.1), Vector3(w / 2 - 0.04, 1.7, 3.0), C_WOOD_DARK)
	Props.box(self, Vector3(0.08, 0.08, 1.75), Vector3(w / 2 - 0.04, 2.33, 3.0), C_WOOD_DARK)
	Props.box(self, Vector3(0.08, 0.08, 1.75), Vector3(w / 2 - 0.04, 1.07, 3.0), C_WOOD_DARK)
	Props.box(self, Vector3(0.14, 0.05, 1.8), Vector3(w / 2 - 0.08, 1.03, 3.0), C_WOOD)
	Props.interactable(self, "window", Vector3(0.3, 1.2, 1.6), Vector3(w / 2 - 0.2, 1.7, 3.0))
	# Kapının üstünde tabela
	Props.label(self, "DENETÇİ N. ZAMANOĞLU", Vector3(0, 2.55, -0.21), 30, Color("e8e2c8"), Vector3(0, 180, 0), 1.3)


func _typewriter(pos: Vector3, rot: float) -> Node3D:
	var t := Node3D.new()
	t.position = pos
	t.rotation_degrees.y = rot
	add_child(t)
	Props.box(t, Vector3(0.42, 0.1, 0.34), Vector3(0, 0.05, 0), Color("1f2426"))
	Props.box(t, Vector3(0.4, 0.06, 0.12), Vector3(0, 0.12, -0.08), Color("2b3134"), Vector3(-15, 0, 0))
	Props.cyl(t, 0.035, 0.46, Vector3(0, 0.16, -0.15), Color("15191a"), Vector3(0, 0, 90), 8)
	Props.box(t, Vector3(0.28, 0.2, 0.005), Vector3(0, 0.26, -0.16), C_PAPER, Vector3(-10, 0, 0))
	for r in 3:
		for c in 7:
			Props.box(t, Vector3(0.025, 0.012, 0.025), Vector3(-0.13 + c * 0.043, 0.105 + r * 0.012, 0.06 + r * 0.035 - 0.06), Color("d8d2c0"))
	return t


# ---------------------------------------------------------------- koridor

func _build_corridor() -> void:
	var z0 := 0.0
	var z1 := -COR_LEN
	var mid := (z0 + z1) / 2.0
	_floor(Vector2(COR_W, COR_LEN), Vector3(0, 0, mid), Color("c9c3a8"), Color("3d4a3e"), 1.0)
	Props.solid(self, Vector3(COR_W, 0.2, COR_LEN), Vector3(0, COR_H + 0.1, mid), Color("b8b6a4"))
	# Sol duvar (asansör girintisi hariç)
	_wall(Vector3(0.2, COR_H, -(LIFT_Z + 1.0)), Vector3(-COR_W / 2 - 0.1, COR_H / 2, (LIFT_Z + 1.0) / 2.0))
	_wall(Vector3(0.2, COR_H, (LIFT_Z - 1.0) - z1), Vector3(-COR_W / 2 - 0.1, COR_H / 2, (LIFT_Z - 1.0 + z1) / 2.0))
	# Sağ duvar (depo açıklığı hariç)
	_wall(Vector3(0.2, COR_H, -DEPOT_Z0), Vector3(COR_W / 2 + 0.1, COR_H / 2, DEPOT_Z0 / 2.0))
	_wall(Vector3(0.2, COR_H, DEPOT_Z1 - z1), Vector3(COR_W / 2 + 0.1, COR_H / 2, (DEPOT_Z1 + z1) / 2.0))
	_wall(Vector3(COR_W, COR_H, 0.2), Vector3(0, COR_H / 2, z1 - 0.1))
	# Lambri bandı
	for x in [-COR_W / 2 + 0.02, COR_W / 2 - 0.02]:
		Props.box(self, Vector3(0.03, 0.12, COR_LEN), Vector3(x, 1.0, mid), C_WOOD_DARK)
	# Tavan lambaları: biri bozuk, yanıp söner
	var z := -3.0
	var n := 0
	while z > z1:
		_tube(Vector3(0, COR_H - 0.05, z), n % 7 != 5)
		z -= 5.0
		n += 1
	for lz in [-6.0, -20.0, -30.0]:
		var l := OmniLight3D.new()
		l.position = Vector3(0, COR_H - 0.4, lz)
		l.light_color = Color("e6f0d8")
		l.light_energy = 1.2
		l.omni_range = 11.0
		add_child(l)
	# Kapılar: her birinde bir yıl
	var i := 0
	z = -4.0
	while z > z1 + 2.0:
		for side in [-1, 1]:
			var skip: bool = (side == 1 and z < DEPOT_Z0 + 1.0 and z > DEPOT_Z1 - 1.0) or (side == -1 and absf(z - LIFT_Z) < 2.0)
			if skip:
				continue
			_door(side, z, YEARS[i % YEARS.size()])
			i += 1
		z -= 4.5


func _door(side: int, z: float, year: String) -> void:
	var x := side * (COR_W / 2 - 0.02)
	var rot := Vector3(0, -90 * side, 0)
	Props.box(self, Vector3(0.05, 2.2, 1.0), Vector3(x, 1.1, z), Color("5f4630"), )
	Props.box(self, Vector3(0.06, 2.3, 0.08), Vector3(x, 1.15, z - 0.54), Color("3f2e20"))
	Props.box(self, Vector3(0.06, 2.3, 0.08), Vector3(x, 1.15, z + 0.54), Color("3f2e20"))
	Props.box(self, Vector3(0.06, 0.08, 1.16), Vector3(x, 2.3, z), Color("3f2e20"))
	Props.ball(self, 0.04, Vector3(x - side * 0.04, 1.05, z + 0.35), C_BRASS, Vector3.ONE, 6)
	# Buzlu cam ve yıl yazısı
	Props.box(self, Vector3(0.055, 0.5, 0.6), Vector3(x, 1.7, z), Color("b9c9b8"))
	Props.label(self, year, Vector3(x - side * 0.035, 1.7, z), 48, Color("2a2a2a"), rot, 0.5)
	Props.interactable(self, "door:" + year, Vector3(0.4, 2.0, 1.0), Vector3(x - side * 0.2, 1.1, z))


# ---------------------------------------------------------------- kostüm deposu

func _build_depot() -> void:
	var x0 := COR_W / 2
	var x1 := x0 + 4.4
	var zc := (DEPOT_Z0 + DEPOT_Z1) / 2.0
	var dz := DEPOT_Z0 - DEPOT_Z1
	_floor(Vector2(x1 - x0, dz), Vector3((x0 + x1) / 2, 0, zc), Color("8a7a5a"), Color("7a6a4a"), 1.2)
	Props.solid(self, Vector3(x1 - x0, 0.2, dz), Vector3((x0 + x1) / 2, COR_H + 0.1, zc), Color("b8b6a4"))
	_wall(Vector3(x1 - x0, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, DEPOT_Z0 + 0.1))
	_wall(Vector3(x1 - x0, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, DEPOT_Z1 - 0.1))
	_wall(Vector3(0.2, COR_H, dz), Vector3(x1 + 0.1, COR_H / 2, zc))
	Props.label(self, "KOSTÜM DEPOSU", Vector3(x0 - 0.02, 2.75, zc), 40, Color("f2e6c9"), Vector3(0, -90, 0), 2.2)
	Props.label(self, "Her dönem · Her beden · İade yok", Vector3(x0 - 0.02, 2.5, zc), 20, Color("c8c0a8"), Vector3(0, -90, 0), 2.4)
	_tube(Vector3((x0 + x1) / 2, COR_H - 0.05, zc))
	var l := OmniLight3D.new()
	l.position = Vector3((x0 + x1) / 2, COR_H - 0.5, zc)
	l.light_color = Color("fff0d0")
	l.light_energy = 1.3
	l.omni_range = 6.0
	add_child(l)
	# Tezgâh
	Props.set_pattern(Props.solid(self, Vector3(0.6, 1.05, dz - 1.2), Vector3(x0 + 1.4, 0.525, zc), C_WOOD), C_WOOD, "wood")
	Props.box(self, Vector3(0.7, 0.05, dz - 1.1), Vector3(x0 + 1.4, 1.07, zc), C_WOOD_DARK)
	# Zil ve damga
	Props.cyl(self, 0.06, 0.05, Vector3(x0 + 1.3, 1.12, zc + 1.5), C_BRASS, Vector3.ZERO, 10, 0.02)
	Props.box(self, Vector3(0.08, 0.08, 0.08), Vector3(x0 + 1.4, 1.14, zc - 1.2), Color("3a2a20"))
	# Fötr şapka (Nihat'a verilecek)
	fedora_node = Node3D.new()
	fedora_node.position = Vector3(x0 + 1.3, 1.1, zc)
	add_child(fedora_node)
	Props.cyl(fedora_node, 0.2, 0.02, Vector3(0, 0.01, 0), Color("4a4038"), Vector3.ZERO, 10)
	Props.cyl(fedora_node, 0.12, 0.12, Vector3(0, 0.08, 0), Color("4a4038"), Vector3.ZERO, 8, 0.1)
	Props.cyl(fedora_node, 0.125, 0.03, Vector3(0, 0.035, 0), Color("1f1b18"), Vector3.ZERO, 8)
	fedora_node.visible = false
	# Askılı kostüm rafları: her dönemden
	var coats := [Color("b3262d"), Color("2f5fa8"), Color("e8d9a8"), Color("3a6b3a"), Color("6a3a7a"),
		Color("d8d8d0"), Color("1f2a44"), Color("c98a3a"), Color("8a2b22"), Color("4a4038")]
	for r in 2:
		var rx := x1 - 0.5 - r * 1.3
		Props.cyl(self, 0.025, dz - 1.0, Vector3(rx, 1.9, zc), C_METAL, Vector3(90, 0, 0), 6)
		for k in 9:
			var cz := DEPOT_Z1 + 0.9 + k * (dz - 1.8) / 8.0
			var c: Color = coats[(k + r * 3) % coats.size()]
			Props.box(self, Vector3(0.12, 0.95, 0.42), Vector3(rx, 1.4, cz), c, Vector3(0, 0, 3 - k % 3 * 3))
	# Rafta tarihî başlıklar: Roma miğferi, pudralı peruk, astronot kaskı, bir de fes
	var shelf_x := x1 - 0.25
	Props.box(self, Vector3(0.45, 0.04, dz - 1.0), Vector3(shelf_x, 2.45, zc), C_WOOD_DARK)
	var hz := DEPOT_Z1 + 1.0
	Props.ball(self, 0.15, Vector3(shelf_x, 2.6, hz), Color("c9a24a"), Vector3(1, 0.9, 1.1), 8)
	Props.box(self, Vector3(0.04, 0.12, 0.3), Vector3(shelf_x, 2.78, hz), Color("b3262d"))
	for k in 5:
		Props.ball(self, 0.07, Vector3(shelf_x, 2.55 + (k % 2) * 0.1, hz + 1.2 + (k - 2) * 0.09), Color("f4f1ea"), Vector3.ONE, 6)
	Props.ball(self, 0.17, Vector3(shelf_x, 2.64, hz + 2.4), Color("f0f0f0"), Vector3.ONE, 10)
	Props.box(self, Vector3(0.02, 0.12, 0.2), Vector3(shelf_x - 0.16, 2.64, hz + 2.4), Color("d4a020"), Vector3.ZERO, 0.6)
	Props.cyl(self, 0.1, 0.14, Vector3(shelf_x, 2.54, hz + 3.6), Color("b3262d"), Vector3.ZERO, 8, 0.08)
	Props.interactable(self, "fezshelf", Vector3(0.6, 0.5, 0.6), Vector3(shelf_x - 0.2, 2.55, hz + 3.6))
	# Depo memuru Rıza
	riza = Person.new({"coat": Color("7a6a4a"), "pants": Color("3a3228"), "hair": Color("2a2a2a"), "mustache": true, "glasses": true})
	riza.position = RIZA_POS
	riza.rotation_degrees.y = -90
	add_child(riza)
	Props.interactable(self, "riza", Vector3(1.4, 1.8, 2.0), Vector3(x0 + 1.0, 1.0, zc))


# ---------------------------------------------------------------- Başdenetçi'nin masası

func _build_desk() -> void:
	var z := DESK_Z
	Props.set_pattern(Props.solid(self, Vector3(2.4, 0.08, 1.1), Vector3(0, 0.8, z), C_WOOD), C_WOOD, "wood")
	Props.set_pattern(Props.solid(self, Vector3(2.3, 0.76, 0.1), Vector3(0, 0.38, z + 0.5), C_WOOD_DARK), C_WOOD_DARK, "wood")
	# Kâğıt dağları: tavana kadar
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for k in 10:
		var px := -1.0 + (k % 5) * 0.5
		var pz := z - 0.25 + (k / 5) * 0.4
		# Ortada alçak (Başdenetçi görünsün), kenarlarda tavana kadar
		var hgt := rng.randf_range(0.15, 0.3) if absf(px) < 0.3 else rng.randf_range(1.2, 2.4)
		Props.box(self, Vector3(0.34, hgt, 0.26), Vector3(px, 0.84 + hgt / 2, pz), C_PAPER, Vector3(0, rng.randf_range(-8, 8), 0))
		Props.box(self, Vector3(0.345, 0.01, 0.265), Vector3(px, 0.84 + hgt * 0.5, pz), Color("c8bfa8"))
	Props.box(self, Vector3(0.3, 0.02, 0.22), Vector3(0.9, 0.85, z + 0.25), Color("b8323a"))
	Props.label(self, "BAŞDENETÇİ", Vector3(0, 1.0, z + 0.56), 28, Color("f2e6c9"), Vector3.ZERO, 1.0)
	Props.label(self, "M. ZAMANOVA", Vector3(0, 0.88, z + 0.56), 22, Color("d8d0b8"), Vector3.ZERO, 1.0)
	# Tepede 'SIRA NUMARANIZ' tabelası
	Props.box(self, Vector3(1.0, 0.35, 0.05), Vector3(0, 3.0, z + 0.2), Color("1a1f1a"))
	Props.label(self, "SIRA: 1453", Vector3(0, 3.0, z + 0.23), 40, Color("ff5a4a"), Vector3.ZERO, 0.9)
	var l := OmniLight3D.new()
	l.position = Vector3(0, 2.5, z + 1.5)
	l.light_color = Color("fff4d8")
	l.light_energy = 1.2
	l.omni_range = 5.0
	add_child(l)
	mufide = Person.new({"coat": Color("6b3a4a"), "pants": Color("3a2a30"), "hair": Color("9a9a9a"), "hat": "bun", "glasses": true, "skirt": true, "skin": Color("e8b894")})
	mufide.position = MUFIDE_POS
	add_child(mufide)
	Props.interactable(self, "mufide", Vector3(2.4, 2.0, 1.6), Vector3(0, 1.0, z + 0.2))


# ---------------------------------------------------------------- saha asansörü

func _build_lift() -> void:
	var z := LIFT_Z
	var x0 := -COR_W / 2
	var x1 := x0 - 1.6
	Props.solid(self, Vector3(1.6, 0.2, 2.0), Vector3((x0 + x1) / 2, -0.1, z), C_METAL)
	Props.solid(self, Vector3(1.6, 0.2, 2.0), Vector3((x0 + x1) / 2, COR_H + 0.1, z), C_METAL)
	_wall(Vector3(1.6, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, z + 1.1), Color("6f7a70"))
	_wall(Vector3(1.6, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, z - 1.1), Color("6f7a70"))
	_wall(Vector3(0.2, COR_H, 2.0), Vector3(x1 - 0.1, COR_H / 2, z), Color("6f7a70"))
	Props.box(self, Vector3(0.1, 0.5, 2.2), Vector3(x0, COR_H - 0.25, z), C_BRASS)
	Props.label(self, "SAHA ÇIKIŞI", Vector3(x0 + 0.06, COR_H - 0.25, z), 40, Color("1a1a1a"), Vector3(0, 90, 0), 1.9)
	# Kayan kapı (açılır)
	lift_door = Node3D.new()
	lift_door.position = Vector3(x0 - 0.05, 0, z)
	add_child(lift_door)
	Props.box(lift_door, Vector3(0.06, 2.6, 0.95), Vector3(0, 1.3, -0.48), C_BRASS)
	Props.box(lift_door, Vector3(0.06, 2.6, 0.95), Vector3(0, 1.3, 0.48), C_BRASS)
	# Kat göstergesi: yıllar dönüyor
	Props.label(self, "◀ 1453 ▶", Vector3(x0 + 0.06, COR_H - 0.7, z), 28, Color("ffb020"), Vector3(0, 90, 0), 0.8)
	var l := OmniLight3D.new()
	l.position = Vector3((x0 + x1) / 2, 2.6, z)
	l.light_color = Color("ffd89a")
	l.light_energy = 1.0
	l.omni_range = 4.0
	add_child(l)
	Props.interactable(self, "lift", Vector3(0.6, 2.4, 2.0), Vector3(x0 + 0.2, 1.2, z))


func open_lift() -> void:
	var tw := create_tween().set_parallel()
	tw.tween_property(lift_door.get_child(0), "position:z", -1.3, 0.8)
	tw.tween_property(lift_door.get_child(1), "position:z", 1.3, 0.8)
	await tw.finished
