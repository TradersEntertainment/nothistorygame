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
## Gece üçte yağmurlu sokak (Bölüm 1): garaj kapısı yarıya kadar açık, altından sokak görünür. Kapalıysa eski oda.
var outside := false             # kepenk 1.65 m'ye kadar kalkık
## Makinenin ortasındaki girdap (0 kapalı, 1 tam açık); çekirdeğin parlaklığı ve makine ışığı da buna göre.
var portal := 0.0
## Kırmızı alarm lambası (takılma).
var alarm := false
var _portal_mat: ShaderMaterial
var _core: MeshInstance3D
var _dome_pos := Vector3.ZERO
var _arc_t := 1.0
var _needles: Array[Node3D] = []
var _beacon: OmniLight3D
var _beacon_ball: MeshInstance3D
var _strip_sparks: CPUParticles3D
var _spark_t := 3.0
var _car: Node3D
var _car_t := 6.0
var _t := 0.0


func _ready() -> void:
	Audio.voice_space("room")
	_build_room()
	_build_lights()
	_build_furniture()
	_build_clutter()
	_build_machine()
	_build_items()
	if outside:
		_build_outside()


func _process(delta: float) -> void:
	# Floresan lamba ara sıra titrer.
	_flicker_t -= delta
	if _flicker_t <= 0.0:
		_flicker_t = randf_range(0.05, 3.5)
		var on := randf() > 0.12
		fluoro_light.light_energy = 1.3 if on else 0.35
		fluoro_tube.material_override = Props.mat(Color("e8f4ff"), 2.5 if on else 0.3)
	_t += delta
	# Jiroskop: üç halka üç ayrı eksende döner
	for i in rings.size():
		var w := delta * spin * (0.3 + i * 0.18)
		match i % 3:
			0: rings[i].rotate_y(w)
			1: rings[i].rotate_x(-w * 0.8)
			_: rings[i].rotate_z(w * 1.2)
	_machine_fx(delta)
	if _car:
		_drive_car(delta)


func _build_room() -> void:
	# Zemin ve tavan
	Props.set_pattern(Props.solid(self, Vector3(W, 0.2, D), Vector3(0, -0.1, 0), C_FLOOR), C_FLOOR, "concrete")
	Props.set_pattern(Props.solid(self, Vector3(W, 0.2, D), Vector3(0, H + 0.1, 0), Color("3a3f48")), Color("3a3f48"), "wall")
	# Duvarlar
	Props.set_pattern(Props.solid(self, Vector3(W, H, 0.2), Vector3(0, H / 2, -D / 2 - 0.1), C_WALL), C_WALL, "wall")
	Props.set_pattern(Props.solid(self, Vector3(0.2, H, D), Vector3(-W / 2 - 0.1, H / 2, 0), C_WALL_DARK), C_WALL_DARK, "wall")
	_mirror_wall = Props.solid(self, Vector3(0.2, H, D), Vector3(W / 2 + 0.1, H / 2, 0), C_WALL_DARK)
	Props.set_pattern(_mirror_wall, C_WALL_DARK, "wall")
	if not outside:
		Props.set_pattern(Props.solid(self, Vector3(W, H, 0.2), Vector3(0, H / 2, D / 2 + 0.1), C_WALL), C_WALL, "wall")
		# Garaj kapısı (içeriden): yatay kanatlar
		for i in 6:
			Props.box(self, Vector3(4.4, 0.36, 0.05), Vector3(0, 0.25 + i * 0.4, D / 2 - 0.02), Color("7d8794") if i % 2 == 0 else Color("737d8a"))
	else:
		# Kapı açıklığı (4.5 × 2.5): iki yan ve üst duvar; kepenk yarıya kadar kalkık (altı 1.05 m açık)
		for sx: float in [-1.0, 1.0]:
			Props.set_pattern(Props.solid(self, Vector3(1.75, H, 0.2), Vector3(sx * 3.125, H / 2, D / 2 + 0.1), C_WALL), C_WALL, "wall")
		Props.set_pattern(Props.solid(self, Vector3(4.5, H - 2.5, 0.2), Vector3(0, 2.5 + (H - 2.5) / 2.0, D / 2 + 0.1), C_WALL), C_WALL, "wall")
		for i in 2:
			Props.box(self, Vector3(4.4, 0.36, 0.05), Vector3(0, 1.88 + i * 0.4, D / 2 - 0.02), Color("7d8794") if i % 2 == 0 else Color("737d8a"))
		Props.box(self, Vector3(4.44, 0.08, 0.1), Vector3(0, 1.68, D / 2 - 0.03), Color("3a3f48"))
		# Kapıdan çıkılmaz (görünmez engel); kapının altından sokak görünür
		var gate := StaticBody3D.new()
		var gs := CollisionShape3D.new()
		var gb := BoxShape3D.new()
		gb.size = Vector3(4.5, 2.5, 0.3)
		gs.shape = gb
		gs.position = Vector3(0, 1.25, D / 2 + 0.1)
		gate.add_child(gs)
		gate.set_meta("no_climb", true)
		add_child(gate)
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
	# Taban: sekizgen kaide, tehlike şeritli kenar, ortada parlayan halka (çarpışmasız, üstüne çıkılabilir)
	Props.cyl(m, 1.1, 0.1, Vector3(0, 0.05, 0), Color("3a3f48"), Vector3.ZERO, 8)
	Props.cyl(m, 1.0, 0.04, Vector3(0, 0.11, 0), Color("6d737c"), Vector3.ZERO, 16)
	for k in 16:
		var a := TAU * k / 16.0
		Props.box(m, Vector3(0.36, 0.1, 0.1), Vector3(cos(a) * 1.08, 0.06, sin(a) * 1.08), Color("e0b52a") if k % 2 == 0 else Color("1e1e1e"), Vector3(0, -rad_to_deg(a) + 90.0, 0))
	Props.ring(m, 0.86, 0.94, Vector3(0, 0.13, 0), Color("6ff2c8"), Vector3.ZERO, 1.2)
	Props.cyl(m, 0.25, 0.01, Vector3(0, 0.135, 0), Color("6ff2c8"), Vector3.ZERO, 8, -1.0, 1.5)
	# İki sütun: bakır bobin sargıları, cam tüp, ibreli saat
	for sx: float in [-1.0, 1.0]:
		var px := sx * 1.38
		Props.cyl(m, 0.14, 2.5, Vector3(px, 1.25, -0.3), Color("4a4f58"), Vector3.ZERO, 10)
		Props.cyl(m, 0.22, 0.14, Vector3(px, 0.07, -0.3), Color("2c313a"), Vector3.ZERO, 10)
		for k in 9:
			Props.ring(m, 0.13, 0.21, Vector3(px, 0.55 + k * 0.17, -0.3), Color("c87533").lerp(Color("a85a24"), (k % 2) * 0.5))
		var tube := Props.cyl(m, 0.06, 0.9, Vector3(px - sx * 0.22, 1.35, -0.1), Color("6ff2c8"), Vector3.ZERO, 8, -1.0, 1.8)
		tube.material_override = Props.mat(Color("6ff2c8"), 1.8, false, "", false)
		# İbreli saat (öne bakar), ibre titrer
		Props.cyl(m, 0.13, 0.04, Vector3(px, 2.05, -0.13), Color("e8e4d8"), Vector3(90, 0, 0), 14)
		Props.ring(m, 0.12, 0.145, Vector3(px, 2.05, -0.12), Color("8a6a2c"), Vector3(90, 0, 0))
		var nd := Node3D.new()
		nd.position = Vector3(px, 2.05, -0.1)
		m.add_child(nd)
		Props.box(nd, Vector3(0.012, 0.1, 0.01), Vector3(0, 0.045, 0), Color("c8262f"))
		_needles.append(nd)
		# Koli bandı ve uyarı levhası
		Props.box(m, Vector3(0.3, 0.08, 0.3), Vector3(px, 0.42, -0.3), C_TAPE, Vector3(0, 20, 0))
	Props.label(m, "YÜKSEK\nGERİLİM", Vector3(1.38, 1.62, -0.14), 24, Color("ffd24a"), Vector3.ZERO, 0.3)
	# Köprü ve Tesla bobini
	Props.box(m, Vector3(3.0, 0.16, 0.26), Vector3(0, 2.56, -0.3), Color("4a4f58"))
	Props.cyl(m, 0.07, 0.3, Vector3(0, 2.72, -0.3), Color("c87533"), Vector3.ZERO, 8)
	Props.ball(m, 0.2, Vector3(0, 2.94, -0.3), Color("b8bcc4"), Vector3(1.0, 0.7, 1.0), 12)
	_dome_pos = PLATFORM_POS + Vector3(0, 2.94, -0.3)
	# Alarm lambası (köprünün ucunda)
	_beacon_ball = Props.ball(m, 0.07, Vector3(1.2, 2.72, -0.3), Color("5a1a18"), Vector3.ONE, 8)
	_beacon = OmniLight3D.new()
	_beacon.position = Vector3(1.2, 2.72, -0.1)
	_beacon.light_color = Color("ff2a1a")
	_beacon.light_energy = 0.0
	_beacon.omni_range = 7.0
	m.add_child(_beacon)
	# Üç halkalı jiroskop (iç içe), ortada çekirdek
	var radii := [1.02, 0.86, 0.7]
	for i in 3:
		var pivot := Node3D.new()
		pivot.position = Vector3(0, 1.3, 0)
		m.add_child(pivot)
		var rr: float = radii[i]
		Props.ring(pivot, rr, rr + 0.08, Vector3.ZERO, [Color("9aa3ad"), Color("7f8893"), Color("c87533")][i], Vector3(90, 0, 0) if i < 2 else Vector3.ZERO)
		if i == 0:
			for a in [20, 140, 250]:
				var ang := deg_to_rad(a)
				Props.box(pivot, Vector3(0.15, 0.15, 0.15), Vector3(cos(ang) * (rr + 0.04), sin(ang) * (rr + 0.04), 0), C_TAPE, Vector3(0, 0, a))
		rings.append(pivot)
	_core = Props.ball(m, 0.12, Vector3(0, 1.3, 0), Color("bff8ff"), Vector3.ONE, 12, 3.0)
	_core.material_override = Props.mat(Color("bff8ff"), 3.0, false, "", false)
	# Girdap: halkaların ortasında, odaya dönük disk (Bölüm 1 kalkışı, Hikmet'in terliği)
	var pd := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(1.9, 1.9)
	pd.mesh = qm
	pd.position = Vector3(0, 1.3, 0.02)
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;
uniform float amount = 0.0;
void fragment() {
	vec2 uv = UV - 0.5;
	float r = length(uv) * 2.0;
	float a = atan(uv.y, uv.x);
	float sw = 0.5 + 0.5 * sin(a * 5.0 + r * 16.0 - TIME * 9.0);
	float disc = smoothstep(1.0, 0.55, r);
	vec3 col = mix(vec3(0.25, 0.85, 1.0), vec3(1.0, 0.96, 0.85), smoothstep(0.45, 0.0, r));
	float k = disc * (0.3 + 0.7 * sw) * amount;
	ALBEDO = col * k * 2.2;
	ALPHA = clamp(k, 0.0, 1.0);
}
"""
	_portal_mat = ShaderMaterial.new()
	_portal_mat.shader = sh
	pd.material_override = _portal_mat
	pd.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	m.add_child(pd)
	# Yerde kalın kablo demetleri: sütunlardan panele ve arka duvardaki prize
	for c in [[Vector3(1.38, 0.04, -1.9), Vector3(1.55, 0.04, -1.0)], [Vector3(-1.38, 0.04, -1.9), Vector3(-3.6, 0.04, -2.6)],
			[Vector3(-1.3, 0.04, -1.75), Vector3(-3.5, 0.04, -2.8)], [Vector3(1.3, 0.04, -1.8), Vector3(3.2, 0.04, -2.8)]]:
		var a: Vector3 = c[0]
		var b: Vector3 = c[1]
		var mid := (a + b) * 0.5
		var cb := Props.cyl(self, 0.03, a.distance_to(b), mid, Color("1a1a1a"), Vector3.ZERO, 5)
		cb.look_at_from_position(mid, b, Vector3.UP)
		cb.rotate_object_local(Vector3.RIGHT, PI / 2.0)
	# Tavandan inen kablolar
	for x in [-0.6, 0.5]:
		Props.cyl(m, 0.02, 0.6, Vector3(x, 2.9, -0.3), Color("1e1e1e"), Vector3(0, 0, x * 20), 4)
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


## Yaşanmış atölye: mantar pano (1453 çizimleri, kırmızı ipler), priz yumağı (kıvılcım), osiloskop, semaver ve çay
## bardakları, lastik yığını, tavanda bisiklet ve borular, sigorta kutusu, söndürücü, pizza kutusu, toz zerreleri.
func _build_clutter() -> void:
	var d := Dressing.new(1977)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	# Mantar pano (alet panosunun üstü, sol duvar)
	d.box(Vector3(0.04, 0.72, 2.8), Vector3(-3.97, 2.62, 0.0), Color("a8844e"))
	var pins: Array[Vector3] = []
	for k in 11:
		var p := Vector3(-3.945, rng.randf_range(2.35, 2.9), rng.randf_range(-1.25, 1.25))
		d.box(Vector3(0.01, rng.randf_range(0.14, 0.22), rng.randf_range(0.12, 0.2)), p, [Color("f2ecd8"), Color("f6e27a"), Color("e8e0cc"), Color("bfe0f0")][k % 4], Vector3(rng.randf_range(-8, 8), 0, 0))
		d.ball(0.012, p + Vector3(0.01, 0.07, 0), Color("c8262f"), Vector3.ONE, 5)
		pins.append(p + Vector3(0.012, 0.07, 0))
	for k in 7:
		var a := pins[k]
		var b := pins[(k * 3 + 2) % pins.size()]
		var mid := (a + b) * 0.5
		var ang := rad_to_deg(atan2(b.y - a.y, b.z - a.z))
		d.box(Vector3(0.004, 0.006, a.distance_to(b)), mid, Color("c8262f"), Vector3(-ang, 0, 0))
	for t in [["1453?", Vector3(-3.94, 2.78, -0.7)], ["t = ?", Vector3(-3.94, 2.5, 0.55)], ["E = mc² (?)", Vector3(-3.94, 2.4, -0.3)]]:
		Props.label(self, t[0], t[1], 26, Color("2a2a2a"), Vector3(0, 90, 0), 0.4)
	# Priz yumağı: arka sol köşe, arada kıvılcım
	d.box(Vector3(0.5, 0.05, 0.12), Vector3(-3.55, 0.03, -2.65), Color("e8e4d8"))
	for k in 5:
		d.box(Vector3(0.05, 0.05, 0.05), Vector3(-3.75 + k * 0.1, 0.07, -2.65), Color("2a2a2a"))
	_strip_sparks = CPUParticles3D.new()
	_strip_sparks.position = Vector3(-3.55, 0.1, -2.65)
	_strip_sparks.emitting = false
	_strip_sparks.one_shot = true
	_strip_sparks.amount = 18
	_strip_sparks.lifetime = 0.5
	_strip_sparks.explosiveness = 0.95
	_strip_sparks.direction = Vector3.UP
	_strip_sparks.spread = 70.0
	_strip_sparks.initial_velocity_min = 1.0
	_strip_sparks.initial_velocity_max = 2.4
	var spm := SphereMesh.new()
	spm.radius = 0.012
	spm.height = 0.024
	spm.material = Props.mat(Color("ffe08a"), 4.0, false, "", false)
	_strip_sparks.mesh = spm
	add_child(_strip_sparks)
	# Osiloskop: üst raf; ekranında yeşil dalga
	d.box(Vector3(0.36, 0.26, 0.42), Vector3(3.72, 2.22, 0.05), Color("8a8e96"))
	var scr := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(0.3, 0.2)
	scr.mesh = qm
	scr.position = Vector3(3.535, 2.23, 0.05)
	scr.rotation_degrees = Vector3(0, -90, 0)
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode unshaded;
void fragment() {
	vec2 uv = UV;
	float y = 0.5 + 0.3 * sin(uv.x * 18.0 + TIME * 6.0) * sin(TIME * 0.7 + uv.x * 3.0);
	float l = smoothstep(0.04, 0.0, abs(uv.y - y));
	float gr = step(0.96, fract(uv.x * 8.0)) + step(0.95, fract(uv.y * 6.0));
	ALBEDO = vec3(0.03, 0.09, 0.05) + vec3(0.35, 1.0, 0.45) * l + vec3(0.03, 0.08, 0.04) * gr;
}
"""
	var sm := ShaderMaterial.new()
	sm.shader = sh
	scr.material_override = sm
	add_child(scr)
	for k in 4:
		d.cyl(0.02, 0.02, Vector3(3.535, 2.13, -0.05 + k * 0.05), Color("2a2a2a"), Vector3(0, 0, 90), 6)
	# Semaver ve çay (arka sol köşe, küçük sehpa)
	var tb := Vector3(-3.2, 0, -2.45)
	d.box(Vector3(0.55, 0.04, 0.45), tb + Vector3(0, 0.6, 0), C_WOOD)
	for q in [Vector3(-0.23, 0.3, -0.18), Vector3(0.23, 0.3, -0.18), Vector3(-0.23, 0.3, 0.18), Vector3(0.23, 0.3, 0.18)]:
		d.box(Vector3(0.04, 0.6, 0.04), tb + q, C_WOOD_DARK)
	d.cyl(0.12, 0.34, tb + Vector3(-0.08, 0.79, 0), Color("c89a4a"), Vector3.ZERO, 12, 0.85)
	d.cyl(0.08, 0.1, tb + Vector3(-0.08, 1.0, 0), Color("b88a3a"), Vector3.ZERO, 10, 0.7)
	d.ball(0.05, tb + Vector3(-0.08, 1.08, 0), Color("c8a050"), Vector3(1, 0.8, 1), 8)
	d.cyl(0.015, 0.12, tb + Vector3(0.05, 0.75, 0), Color("b88a3a"), Vector3(0, 0, -70), 5)
	for k in 3:
		d.cyl(0.028, 0.08, tb + Vector3(0.12 + (k % 2) * 0.08, 0.66, -0.12 + k * 0.1), Color("9a3a1a"), Vector3.ZERO, 8, 0.8)
	# Lastik yığını (arka sağ köşe)
	for k in 3:
		Props.ring(self, 0.18, 0.34, Vector3(3.45, 0.1 + k * 0.2, -2.55), Color("1e1e20"))
	# Sigorta kutusu (arka duvar, sağ): kapağı açık, kablolar sarkar
	d.box(Vector3(0.5, 0.6, 0.12), Vector3(3.3, 1.6, -D / 2 + 0.07), Color("7a808a"))
	d.box(Vector3(0.04, 0.6, 0.45), Vector3(3.57, 1.6, -D / 2 + 0.3), Color("8a909a"), Vector3(0, -30, 0))
	for k in 5:
		d.box(Vector3(0.05, 0.1, 0.05), Vector3(3.14 + k * 0.08, 1.7, -D / 2 + 0.14), Color("2a2a2a") if k != 2 else Color("c8262f"))
	# Söndürücü (panelin yanı)
	d.cyl(0.08, 0.5, Vector3(2.35, 0.25, -2.5), Color("b3262d"), Vector3.ZERO, 10)
	d.box(Vector3(0.1, 0.05, 0.04), Vector3(2.35, 0.53, -2.5), Color("2a2a2a"))
	# Pizza kutusu ve üstünde boş çay bardağı (Hikmet'in sandalyesinin yanında)
	d.box(Vector3(0.42, 0.05, 0.42), Vector3(-2.75, 0.025, -0.35), Color("c8a878"), Vector3(0, 18, 0))
	d.cyl(0.028, 0.08, Vector3(-2.7, 0.09, -0.3), Color("c8b8a0"), Vector3.ZERO, 8, 0.8)
	# Tavan: açık borular ve asılı bisiklet (kapının yanında)
	for z: float in [-2.55, 1.2]:
		d.cyl(0.05, W, Vector3(0, H - 0.18, z), Color("7a808a"), Vector3(0, 0, 90), 8)
	var bk := Vector3(2.6, 2.6, 2.3)
	for sx: float in [-0.5, 0.5]:
		Props.ring(self, 0.28, 0.32, bk + Vector3(sx, 0, 0), Color("1e1e20"), Vector3(0, 0, 90))
	d.box(Vector3(1.0, 0.04, 0.04), bk + Vector3(0, 0.1, 0), Color("2f5fa8"))
	d.box(Vector3(0.04, 0.3, 0.04), bk + Vector3(0.1, 0.25, 0), Color("2f5fa8"))
	for sx: float in [-0.5, 0.5]:
		d.cyl(0.008, 0.25, bk + Vector3(sx, 0.45, 0), Color("2a2a2a"), Vector3.ZERO, 4)
	d.build(self)
	# Havada süzülen toz zerreleri (ışıkta parlar)
	var dust := CPUParticles3D.new()
	dust.amount = 140
	dust.lifetime = 9.0
	dust.preprocess = 9.0
	dust.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	dust.emission_box_extents = Vector3(3.8, 1.5, 2.8)
	dust.position = Vector3(0, 1.6, 0)
	dust.direction = Vector3(0.3, 0.2, 0.1)
	dust.spread = 180.0
	dust.initial_velocity_min = 0.02
	dust.initial_velocity_max = 0.08
	dust.gravity = Vector3(0, -0.005, 0)
	var dm := SphereMesh.new()
	dm.radius = 0.006
	dm.height = 0.012
	dm.radial_segments = 4
	dm.rings = 2
	var dmat := StandardMaterial3D.new()
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmat.albedo_color = Color(1.0, 0.95, 0.85, 0.55)
	dmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dm.material = dmat
	dust.mesh = dm
	add_child(dust)


## Yağmurlu İstanbul gecesi, 03.00: ıslak sokak, kaldırım, sokak lambası, brandalı Şahin, karşı apartmanın ışıkları,
## uzakta minare, yağmur ve sıçramalar; arada bir araba geçer, farları kapının altından garaja vurur.
func _build_outside() -> void:
	var wet := StandardMaterial3D.new()
	wet.albedo_color = Color("24262a")
	wet.roughness = 0.12
	wet.metallic_specular = 0.9
	var road := Props.box(self, Vector3(40, 0.2, 14), Vector3(0, -0.12, 11.0), Color("24262a"))
	road.material_override = wet
	Props.box(self, Vector3(40, 0.14, 1.6), Vector3(0, -0.02, 3.9), Color("5a5a5e"))
	Props.box(self, Vector3(40, 0.16, 0.2), Vector3(0, -0.02, 4.7), Color("7a7a7e"))
	var pud := StandardMaterial3D.new()
	pud.albedo_color = Color(0.1, 0.11, 0.13, 0.9)
	pud.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pud.roughness = 0.02
	pud.metallic = 0.4
	pud.metallic_specular = 1.0
	for p in [Vector3(-1.5, 0.0, 6.2), Vector3(1.8, 0.0, 7.5), Vector3(-4.0, 0.0, 9.0), Vector3(4.5, 0.0, 5.8)]:
		var pd := Props.cyl(self, 1.0, 0.01, p, Color.WHITE, Vector3.ZERO, 14)
		pd.material_override = pud
		pd.scale = Vector3(randf_range(0.6, 1.2), 1.0, randf_range(0.4, 0.8))
	# Karşı apartman: pencerelerin çoğu karanlık, birkaçı sarı yanık
	Props.box(self, Vector3(40, 16, 1.0), Vector3(0, 7.8, 17.0), Color("3a3440"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for fl in 5:
		for k in 14:
			var lit := rng.randf() < 0.22
			var wp := Vector3(-13.0 + k * 2.0, 1.6 + fl * 3.0, 16.48)
			var w := Props.box(self, Vector3(0.9, 1.2, 0.04), wp, Color("ffd79a") if lit else Color("15161c"), Vector3.ZERO, 1.6 if lit else 0.0)
			if lit:
				w.material_override = Props.mat(Color("ffd79a"), 1.6, false, "", false)
		Props.box(self, Vector3(40, 0.12, 0.5), Vector3(0, 3.0 + fl * 3.0, 16.3), Color("2a2630"))
	# Uzakta minare silueti ve şehir ışığının vurduğu gök
	var sil := Color("0e1018")
	Props.cyl(self, 0.8, 30.0, Vector3(-16.0, 15.0, 42.0), sil, Vector3.ZERO, 10)
	Props.cyl(self, 1.3, 0.6, Vector3(-16.0, 24.0, 42.0), sil, Vector3.ZERO, 10)
	Props.cyl(self, 0.8, 4.0, Vector3(-16.0, 32.0, 42.0), sil, Vector3.ZERO, 10, 0.02)
	Props.box(self, Vector3(120, 60, 1), Vector3(0, 20, 60), Color("1c1c2a"))
	# Sokak lambası (turuncu)
	var lp := Vector3(-3.4, 0, 5.0)
	Props.cyl(self, 0.07, 5.2, lp + Vector3(0, 2.6, 0), Color("3a3f48"), Vector3.ZERO, 8)
	Props.box(self, Vector3(0.08, 0.08, 1.0), lp + Vector3(0, 5.15, -0.45), Color("3a3f48"))
	var head := Props.box(self, Vector3(0.3, 0.12, 0.45), lp + Vector3(0, 5.05, -0.9), Color("ffb060"))
	head.material_override = Props.mat(Color("ffb060"), 3.0, false, "", false)
	var sl := OmniLight3D.new()
	sl.position = lp + Vector3(0, 4.8, -0.9)
	sl.light_color = Color("ffa050")
	sl.light_energy = 2.6
	sl.omni_range = 11.0
	add_child(sl)
	# Sokağın soğuk dolgu ışığı (ay ve şehir ışığı): araba ve karşı apartman seçilsin
	var fill := OmniLight3D.new()
	fill.position = Vector3(2.0, 4.0, 10.0)
	fill.light_color = Color("7a8ab8")
	fill.light_energy = 1.4
	fill.omni_range = 14.0
	add_child(fill)
	# Brandası yarım Tofaş Şahin
	var car := Node3D.new()
	car.position = Vector3(3.0, 0, 8.6)
	car.rotation_degrees.y = 90
	add_child(car)
	Props.box(car, Vector3(1.66, 0.62, 4.3), Vector3(0, 0.55, 0), Color("7a2420"))
	Props.box(car, Vector3(1.5, 0.52, 2.0), Vector3(0, 1.1, -0.2), Color("7a2420"))
	Props.box(car, Vector3(1.52, 0.4, 1.9), Vector3(0, 1.12, -0.2), Color("1c2230"))
	for q in [Vector3(-0.8, 0.3, 1.35), Vector3(0.8, 0.3, 1.35), Vector3(-0.8, 0.3, -1.35), Vector3(0.8, 0.3, -1.35)]:
		Props.cyl(car, 0.3, 0.2, q, Color("141414"), Vector3(0, 0, 90), 12)
	Props.box(car, Vector3(1.8, 0.7, 2.2), Vector3(0, 1.0, -1.2), Color("4a5a6a"), Vector3(4, 0, 0))
	Props.label(car, "34 HKM 77", Vector3(0, 0.45, 2.16), 24, Color("1a1a1a"), Vector3.ZERO, 0.4)
	# Kaputun üstünde yağmurdan saklanmayan kedi
	Props.box(car, Vector3(0.2, 0.18, 0.4), Vector3(0.1, 0.95, 1.3), Color("2a2a2a"))
	Props.box(car, Vector3(0.18, 0.16, 0.16), Vector3(0.1, 1.08, 1.52), Color("2a2a2a"))
	for sx: float in [-0.05, 0.05]:
		Props.ball(car, 0.018, Vector3(0.1 + sx, 1.1, 1.61), Color("d8e060"), Vector3.ONE, 5, 2.0)
	# Yağmur ve sıçramalar (yalnız dışarıda)
	var rain := CPUParticles3D.new()
	rain.position = Vector3(0, 7.0, 10.0)
	rain.amount = 1400
	rain.lifetime = 0.9
	rain.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	rain.emission_box_extents = Vector3(12, 0.5, 6.5)
	rain.direction = Vector3(0.1, -1, 0)
	rain.spread = 3.0
	rain.initial_velocity_min = 9.0
	rain.initial_velocity_max = 11.0
	var rm := BoxMesh.new()
	rm.size = Vector3(0.012, 0.5, 0.012)
	var rmat := StandardMaterial3D.new()
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rmat.albedo_color = Color(0.75, 0.8, 0.9, 0.45)
	rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.material = rmat
	rain.mesh = rm
	add_child(rain)
	var spl := CPUParticles3D.new()
	spl.position = Vector3(0, 0.02, 9.0)
	spl.amount = 260
	spl.lifetime = 0.25
	spl.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	spl.emission_box_extents = Vector3(12, 0.01, 5.6)
	spl.direction = Vector3.UP
	spl.spread = 35.0
	spl.initial_velocity_min = 0.6
	spl.initial_velocity_max = 1.2
	var sbm := BoxMesh.new()
	sbm.size = Vector3(0.025, 0.025, 0.025)
	sbm.material = rmat
	spl.mesh = sbm
	add_child(spl)
	# Geçen araba: farlar ve ışığı (arada bir, sokağın bir ucundan öbürüne)
	_car = Node3D.new()
	add_child(_car)
	Props.box(_car, Vector3(4.0, 0.8, 1.7), Vector3(0, 0.6, 0), Color("2a2e36"))
	Props.box(_car, Vector3(2.0, 0.6, 1.5), Vector3(-0.2, 1.2, 0), Color("22262e"))
	for sz: float in [-0.6, 0.6]:
		var hl := Props.box(_car, Vector3(0.05, 0.14, 0.3), Vector3(2.02, 0.7, sz), Color("fff4d8"))
		hl.material_override = Props.mat(Color("fff4d8"), 4.0, false, "", false)
		var tl := Props.box(_car, Vector3(0.05, 0.12, 0.25), Vector3(-2.02, 0.7, sz), Color("ff2a1a"))
		tl.material_override = Props.mat(Color("ff2a1a"), 3.0, false, "", false)
	var hlight := SpotLight3D.new()
	hlight.position = Vector3(2.1, 0.8, 0)
	hlight.rotation_degrees = Vector3(0, -90, 0)
	hlight.spot_range = 16.0
	hlight.spot_angle = 35.0
	hlight.light_energy = 5.0
	hlight.light_color = Color("fff0d0")
	_car.add_child(hlight)
	_car.visible = false


func _drive_car(delta: float) -> void:
	_car_t -= delta
	if _car_t > 0.0:
		return
	if not _car.visible:
		_car.visible = true
		_car.position = Vector3(-22.0, 0, 11.5)
		Audio.sfx("whoosh_fly", -20.0, 0.5)
	_car.position.x += delta * 9.0
	if _car.position.x > 22.0:
		_car.visible = false
		_car_t = randf_range(14.0, 26.0)


## Makinenin canlılığı: ibreler titrer, çekirdek ve girdap dönüş hızına göre parlar, Tesla bobininden arklar
## çakar (hızlandıkça sıklaşır), alarm lambası yanıp söner, priz arada kıvılcım atar.
func _machine_fx(delta: float) -> void:
	var heat := clampf((spin - 1.0) / 12.0, 0.0, 1.0)
	for i in _needles.size():
		_needles[i].rotation.z = sin(_t * (3.0 + i) + i) * (0.2 + heat * 1.1) - 0.3
	if _core:
		var s := 1.0 + heat * 1.6 + portal * 2.2 + sin(_t * 9.0) * 0.06
		_core.scale = Vector3.ONE * s
	if _portal_mat:
		_portal_mat.set_shader_parameter("amount", portal)
	if machine_light:
		machine_light.light_energy = 0.7 + heat * 2.5 + portal * 3.2
		machine_light.omni_range = 3.5 + heat * 3.0 + portal * 4.0
	if _beacon:
		var on := alarm and fmod(_t, 0.5) < 0.25
		_beacon.light_energy = 4.0 if on else 0.0
		_beacon_ball.material_override = Props.mat(Color("ff2a1a") if on else Color("5a1a18"), 3.0 if on else 0.0, false, "", false)
	# Arklar
	var rate := heat * 7.0 + portal * 10.0
	if rate > 0.05:
		_arc_t -= delta * rate
		if _arc_t <= 0.0:
			_arc_t = randf_range(0.6, 1.4)
			var to: Vector3
			match randi() % 3:
				0: to = PLATFORM_POS + Vector3(randf_range(-1.0, 1.0), 1.3 + randf_range(-0.9, 0.9), 0)
				1: to = PLATFORM_POS + Vector3(-1.38, randf_range(0.6, 2.0), -0.3)
				_: to = PLATFORM_POS + Vector3(1.38, randf_range(0.6, 2.0), -0.3)
			_arc(_dome_pos, to)
	# Priz kıvılcımı
	_spark_t -= delta * (1.0 + heat * 6.0)
	if _spark_t <= 0.0 and _strip_sparks:
		_spark_t = randf_range(4.0, 9.0)
		_strip_sparks.restart()
		_strip_sparks.emitting = true


## Elektrik arkı: iki nokta arasında kırık çizgi (ince parlak kutular), bir an çakar ve söner.
func _arc(a: Vector3, b: Vector3) -> void:
	var root := Node3D.new()
	add_child(root)
	var n := 7
	var prev := a
	var mat := Props.mat(Color("d8f8ff"), 5.0, false, "", false)
	for k in range(1, n + 1):
		var t := float(k) / n
		var p := a.lerp(b, t)
		if k < n:
			p += Vector3(randf_range(-0.12, 0.12), randf_range(-0.12, 0.12), randf_range(-0.12, 0.12))
		var mid := (prev + p) * 0.5
		var seg := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.018, 0.018, prev.distance_to(p))
		seg.mesh = bm
		seg.material_override = mat
		seg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(seg)
		seg.look_at_from_position(mid, p, Vector3.UP if absf((p - prev).normalized().y) < 0.95 else Vector3.RIGHT)
		prev = p
	var l := OmniLight3D.new()
	l.position = (a + b) * 0.5
	l.light_color = Color("a8e8ff")
	l.light_energy = 3.0
	l.omni_range = 4.0
	root.add_child(l)
	get_tree().create_timer(0.07).timeout.connect(root.queue_free)
	if randf() < 0.5:
		Audio.sfx("radio_static", -22.0, randf_range(1.6, 2.2))


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


func set_item_visible(id: String, on: bool, animate := false) -> void:
	var entry: Dictionary = items[id]
	var node := entry["node"] as Node3D
	(entry["body"] as StaticBody3D).collision_layer = 2 if on else 0
	if on or not animate or not node.is_inside_tree() or GameState.autotest:
		node.visible = on
		return
	# Alınan eşya çantaya süzülür: kalkar, küçülür, kaybolur (sonra yerine döner, görünmez kalır)
	var p0 := node.position
	var s0 := node.scale
	var tw := node.create_tween()
	tw.tween_property(node, "position", p0 + Vector3(0, 0.3, 0), 0.18).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "rotation:y", node.rotation.y + PI, 0.3)
	tw.tween_property(node, "scale", s0 * 0.05, 0.15).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		node.visible = false
		node.position = p0
		node.scale = s0)


## Kapının yanında boy aynası: Tolga kendine bakabilir (E ya da V).
func _build_mirror() -> void:
	var p := Vector3(W / 2.0 - 0.08, 0.0, 1.9)
	var frame := Props.box(self, Vector3(0.08, 1.9, 0.8), p + Vector3(0, 1.15, 0), Color("6a4a2c"))
	Mirror.make(self, Vector2(0.66, 1.7), p + Vector3(-0.05, 1.15, 0), Vector3.LEFT)
	Mirror.hide_from_reflection(frame)
	Mirror.hide_from_reflection(_mirror_wall)
	Props.interactable(self, "mirror", Vector3(0.6, 1.8, 0.9), p + Vector3(-0.3, 1.1, 0))


## Arka duvarda iki çivi üstünde babadan kalma çifte (Bölüm 8: Hikmet 1453'e götürür).
func add_shotgun() -> Node3D:
	var g := Blades.shotgun(self)
	g.name = "WallShotgun"
	g.position = Vector3(-1.9, 2.05, -D / 2.0 + 0.09)
	g.rotation_degrees = Vector3(0, 0, -90)
	for x: float in [-1.55, -2.35]:
		Props.box(self, Vector3(0.03, 0.03, 0.1), Vector3(x, 1.97, -D / 2.0 + 0.05), Color("2a2a2a"))
	return g

