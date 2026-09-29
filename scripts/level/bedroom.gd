class_name Bedroom
extends Node3D
## Bölüm 1 öncesi: Tolga'nın yatak odası, gece 03.00. Küçük bekâr odası: yatak, komodinde çalan telefon ve 03:00
## gösteren saat, pencerede yağmurlu İstanbul gecesi (karşı apartmanın ışıkları), dolap, masada dizüstü, duvarda
## "Ayın Çalışanı" belgesi. Oda garajdan uzakta kurulur (ORIGIN); pencere Hikmet'in terliğinin gireceği yer.

const ORIGIN := Vector3(0.0, 0.0, -60.0)
const W := 4.0
const D := 3.6
const H := 2.6
const PILLOW := Vector3(-1.25, 0.7, -1.25)       # yerel: yastık (yatarken göz)
const PHONE := Vector3(-0.45, 0.55, -1.42)
const WINDOW := Vector3(0.75, 1.5, -1.8)         # pencere ortası (arka duvar)
const STAND := Vector3(-0.35, 0.0, -0.3)         # yataktan kalkınca durulan yer
const DOOR := Vector3(1.25, 0.0, 1.8)
const SLIPPER_REST := Vector3(-0.55, 0.03, -0.75)

const C_WALL := Color("b8ab98")
const C_FLOOR := Color("7a5a3e")
const C_WOOD := Color("8a6a48")

var phone: Node3D
var phone_light: OmniLight3D
var ringing := false
var _ring_t := 0.0


func _ready() -> void:
	position = ORIGIN
	_room()
	_furniture()
	_window()
	_lights()


func _process(delta: float) -> void:
	if not ringing or phone == null:
		return
	# Titreşim: komodinin üstünde kısa kısa zıplar, ekran ışığı yanıp söner
	_ring_t += delta
	var on := fmod(_ring_t, 1.1) < 0.7
	phone.position = PHONE + (Vector3(randf_range(-0.004, 0.004), 0, randf_range(-0.004, 0.004)) if on else Vector3.ZERO)
	phone.rotation.y = 0.2 + (sin(_ring_t * 60.0) * 0.04 if on else 0.0)
	phone_light.light_energy = 0.45 if on else 0.15
	if on and fmod(_ring_t, 1.1) < delta:
		Audio.sfx("radio_beep", -10.0, 1.4)


func set_ringing(on: bool) -> void:
	ringing = on
	if phone_light:
		phone_light.light_energy = 0.12 if not on else 0.45


func world(p: Vector3) -> Vector3:
	return ORIGIN + p


func _room() -> void:
	Props.set_pattern(Props.solid(self, Vector3(W, 0.2, D), Vector3(0, -0.1, 0), C_FLOOR), C_FLOOR, "wood")
	Props.solid(self, Vector3(W, 0.2, D), Vector3(0, H + 0.1, 0), Color("5a606b"))
	# Arka duvar pencere boşluğu bırakarak (pencere 1.0 × 1.0, ortası WINDOW)
	var wx := WINDOW.x
	var zb := -D / 2 - 0.1
	Props.solid(self, Vector3(wx - 0.5 + W / 2, H, 0.2), Vector3((-W / 2 + wx - 0.5) / 2, H / 2, zb), C_WALL)
	Props.solid(self, Vector3(W / 2 - wx - 0.5, H, 0.2), Vector3((wx + 0.5 + W / 2) / 2, H / 2, zb), C_WALL)
	Props.solid(self, Vector3(1.0, WINDOW.y - 0.5, 0.2), Vector3(wx, (WINDOW.y - 0.5) / 2, zb), C_WALL)
	Props.solid(self, Vector3(1.0, H - WINDOW.y - 0.5, 0.2), Vector3(wx, (H + WINDOW.y + 0.5) / 2, zb), C_WALL)
	Props.solid(self, Vector3(0.2, H, D), Vector3(-W / 2 - 0.1, H / 2, 0), C_WALL.darkened(0.08))
	Props.solid(self, Vector3(0.2, H, D), Vector3(W / 2 + 0.1, H / 2, 0), C_WALL.darkened(0.08))
	Props.solid(self, Vector3(W, H, 0.2), Vector3(0, H / 2, D / 2 + 0.1), C_WALL)
	# Süpürgelik
	Props.box(self, Vector3(W, 0.08, 0.02), Vector3(0, 0.04, D / 2 - 0.01), Color("e8e0d0"))
	Props.box(self, Vector3(0.02, 0.08, D), Vector3(-W / 2 + 0.01, 0.04, 0), Color("e8e0d0"))
	# Kapı (ön duvar): kanat, kulp; üstünde etkileşim
	Props.box(self, Vector3(0.9, 2.05, 0.06), Vector3(DOOR.x, 1.025, D / 2 - 0.03), Color("c8b89a"))
	Props.ball(self, 0.035, Vector3(DOOR.x - 0.32, 1.0, D / 2 - 0.08), Color("c8a040"))
	Props.interactable(self, "bed_door", Vector3(0.9, 2.0, 0.3), Vector3(DOOR.x, 1.0, D / 2 - 0.2))
	# Yerde halı
	Props.box(self, Vector3(1.4, 0.01, 1.0), Vector3(-0.2, 0.005, 0.2), Color("7a3a3a"))


func _furniture() -> void:
	# Yatak: sol duvara yaslı, başı arka duvarda
	var bx := -1.3
	Props.solid(self, Vector3(1.1, 0.3, 2.1), Vector3(bx, 0.15, -0.72), C_WOOD)
	Props.box(self, Vector3(1.05, 0.18, 2.0), Vector3(bx, 0.39, -0.72), Color("e8e4dc"))
	Props.box(self, Vector3(1.12, 0.9, 0.08), Vector3(bx, 0.45, -1.76), C_WOOD.darkened(0.15))
	# Yorgan (yarı açılmış, buruşuk) ve yastık
	Props.box(self, Vector3(1.1, 0.12, 1.3), Vector3(bx, 0.52, -0.25), Color("3a5a8a"), Vector3(0, 0, 2))
	Props.box(self, Vector3(0.5, 0.1, 0.5), Vector3(bx + 0.3, 0.55, -0.95), Color("3a5a8a"), Vector3(0, 25, 6))
	Props.ball(self, 0.22, Vector3(bx, 0.55, -1.45), Color("f2eee6"), Vector3(1.9, 0.5, 1.0), 10)
	# Komodin, telefon, saat
	Props.solid(self, Vector3(0.45, 0.5, 0.4), Vector3(-0.45, 0.25, -1.5), C_WOOD)
	Props.box(self, Vector3(0.02, 0.06, 0.02), Vector3(-0.36, 0.32, -1.29), Color("c8a040"))
	phone = Node3D.new()
	phone.position = PHONE
	phone.rotation.y = 0.2
	add_child(phone)
	Props.box(phone, Vector3(0.075, 0.012, 0.15), Vector3.ZERO, Color("1a1a1e"))
	Props.box(phone, Vector3(0.066, 0.002, 0.135), Vector3(0, 0.007, 0), Color("4fd08a"), Vector3.ZERO, 1.6)
	Props.label(phone, "HİKMET AMCA", Vector3(0, 0.01, -0.03), 22, Color("0a2a14"), Vector3(-90, 0, 0), 0.06)
	# Saat yatağa dönük (yastıktan okunur)
	Props.box(self, Vector3(0.16, 0.09, 0.07), Vector3(-0.56, 0.545, -1.6), Color("202020"), Vector3(0, -65, 0))
	var clock := Props.label(self, "03:00", Vector3(-0.595, 0.55, -1.585), 40, Color("ff3a2a"), Vector3(0, -65, 0), 0.14)
	clock.modulate = Color(1.6, 0.4, 0.3)
	# Dolap (sağ arka), masa + dizüstü + sandalye (sağ duvar)
	Props.solid(self, Vector3(1.0, 2.1, 0.55), Vector3(1.45, 1.05, -1.5), C_WOOD.lightened(0.1))
	Props.box(self, Vector3(0.01, 1.9, 0.01), Vector3(1.45, 1.05, -1.22), Color("5a4430"))
	Props.solid(self, Vector3(0.6, 0.75, 1.1), Vector3(1.68, 0.375, 0.35), C_WOOD)
	Props.box(self, Vector3(0.3, 0.015, 0.4), Vector3(1.62, 0.76, 0.3), Color("2a2a30"))
	Props.box(self, Vector3(0.28, 0.2, 0.01), Vector3(1.78, 0.87, 0.3), Color("2a2a30"), Vector3(0, 90, -15))
	Props.box(self, Vector3(0.45, 0.45, 0.45), Vector3(1.15, 0.225, 0.35), Color("3a3a40"))
	# Sandalyenin üstünde takım elbise ceketi ve kravat (Tolga garaja takım elbiseyle gidecek)
	Props.box(self, Vector3(0.4, 0.5, 0.06), Vector3(1.05, 0.7, 0.35), Color("23262d"), Vector3(0, 90, -8))
	Props.box(self, Vector3(0.05, 0.4, 0.01), Vector3(1.01, 0.72, 0.35), Color("8a1a24"), Vector3(0, 90, -8))
	# "Ayın Çalışanı" belgesi (sağ duvar) ve sigorta şirketi takvimi
	Props.box(self, Vector3(0.02, 0.4, 0.55), Vector3(W / 2 - 0.01, 1.55, 0.35), Color("c8a040"))
	Props.box(self, Vector3(0.02, 0.34, 0.49), Vector3(W / 2 - 0.02, 1.55, 0.35), Color("f4efe2"))
	Props.label(self, tr("UI_BED_CERT"), Vector3(W / 2 - 0.035, 1.55, 0.35), 30, Color("2a2a2a"), Vector3(0, -90, 0), 0.44)
	# Yerde terlik teki ve kitap yığını
	Props.box(self, Vector3(0.11, 0.03, 0.26), Vector3(-0.75, 0.015, 0.45), Color("7a2a2a"), Vector3(0, 20, 0))
	for k in 3:
		Props.box(self, Vector3(0.22, 0.05, 0.3), Vector3(0.2, 0.025 + k * 0.05, -1.55), [Color("6a3a2a"), Color("2a4a6a"), Color("c8a040")][k], Vector3(0, k * 12, 0))


func _window() -> void:
	# Çerçeve, iki kanat (biri aralık: terlik oradan girer), perde
	var z := -D / 2
	for s: float in [-1.0, 1.0]:
		Props.box(self, Vector3(0.05, 1.0, 0.08), Vector3(WINDOW.x + s * 0.5, WINDOW.y, z), Color("e8e4dc"))
		Props.box(self, Vector3(1.05, 0.05, 0.08), Vector3(WINDOW.x, WINDOW.y + s * 0.5, z), Color("e8e4dc"))
	Props.box(self, Vector3(1.1, 0.04, 0.2), Vector3(WINDOW.x, WINDOW.y - 0.52, z + 0.08), Color("e8e4dc"))
	var glass := Props.box(self, Vector3(0.48, 0.95, 0.01), Vector3(WINDOW.x - 0.25, WINDOW.y, z), Color(0.55, 0.7, 0.9, 0.25))
	glass.material_override = Props.mat(Color(0.55, 0.7, 0.9, 0.22), 0.0, true, "", false)
	# Aralık kanat: içeri doğru açık
	var sash := Props.box(self, Vector3(0.48, 0.95, 0.01), Vector3(WINDOW.x + 0.36, WINDOW.y, z + 0.2), Color(0.55, 0.7, 0.9, 0.25), Vector3(0, -50, 0))
	sash.material_override = Props.mat(Color(0.55, 0.7, 0.9, 0.22), 0.0, true, "", false)
	for s: float in [-1.0, 1.0]:
		Props.box(self, Vector3(0.35, 1.5, 0.04), Vector3(WINDOW.x + s * 0.72, WINDOW.y - 0.1, z + 0.12), Color("6a3a3a"))
	# Dışarısı: yağmurlu gece, karşı apartmanın birkaç yanan penceresi, uzakta minare
	Props.box(self, Vector3(6.0, 5.0, 0.05), Vector3(WINDOW.x, WINDOW.y, z - 3.5), Color("10182a"), Vector3.ZERO, 0.4)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in 14:
		var lit := rng.randf() < 0.3
		Props.box(self, Vector3(0.35, 0.45, 0.02), Vector3(WINDOW.x - 2.0 + (i % 7) * 0.62, WINDOW.y - 0.9 + (i / 7) * 0.9, z - 3.45),
			Color("ffcf70") if lit else Color("1a2436"), Vector3.ZERO, 1.2 if lit else 0.0)
	Props.cyl(self, 0.06, 1.6, Vector3(WINDOW.x + 1.4, WINDOW.y + 0.6, z - 3.4), Color("2a3448"), Vector3.ZERO, 6, 0.02)
	var rain := CPUParticles3D.new()
	rain.position = Vector3(WINDOW.x, WINDOW.y + 1.2, z - 0.8)
	rain.amount = 90
	rain.lifetime = 0.6
	rain.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	rain.emission_box_extents = Vector3(1.6, 0.1, 0.6)
	rain.direction = Vector3.DOWN
	rain.spread = 4.0
	rain.initial_velocity_min = 6.0
	rain.initial_velocity_max = 7.0
	rain.gravity = Vector3(0, -6, 0)
	var dm := BoxMesh.new()
	dm.size = Vector3(0.008, 0.18, 0.008)
	dm.material = Props.mat(Color(0.7, 0.8, 1.0, 0.5), 0.6, true, "", false)
	rain.mesh = dm
	add_child(rain)


func _lights() -> void:
	# Pencereden soğuk mavi gece ışığı; telefon ekranının yeşil parıltısı
	var moon := OmniLight3D.new()
	moon.position = WINDOW + Vector3(0, 0.1, 0.5)
	moon.light_color = Color("7890c8")
	moon.light_energy = 0.55
	moon.omni_range = 5.0
	add_child(moon)
	phone_light = OmniLight3D.new()
	phone_light.position = PHONE + Vector3(0, 0.12, 0)
	phone_light.light_color = Color("c8f0d8")
	phone_light.light_energy = 0.12
	phone_light.omni_range = 1.2
	add_child(phone_light)


## Hikmet'in terliği aralık pencereden fırlar, hedefe (oyuncunun kafası) çarpar, yere düşer ve alınabilir olur.
func throw_slipper(hit: Vector3) -> Node3D:
	var s := Node3D.new()
	add_child(s)
	Props.box(s, Vector3(0.12, 0.03, 0.28), Vector3(0, 0.015, 0), Color("3a5a8a"))
	Props.box(s, Vector3(0.13, 0.04, 0.08), Vector3(0, 0.05, 0.06), Color("2a4a7a"))
	var from := WINDOW + Vector3(0.3, 0.1, -1.2)
	var to := hit - ORIGIN
	s.position = from
	var tw := create_tween()
	tw.tween_method(func(k: float):
		s.position = from.lerp(to, k) + Vector3(0, sin(k * PI) * 0.35, 0)
		s.rotation = Vector3(k * TAU * 1.5, k * TAU, 0), 0.0, 1.0, 0.55)
	tw.tween_callback(func(): Audio.sfx("cartoon_boing", -4.0))
	tw.tween_property(s, "position", SLIPPER_REST, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(s, "rotation", Vector3(0, 0.6, 0), 0.35)
	tw.tween_callback(func():
		Audio.sfx("land_thud", -10.0)
		Props.interactable(s, "bed_slipper", Vector3(0.35, 0.3, 0.45), Vector3(0, 0.1, 0)))
	return s
