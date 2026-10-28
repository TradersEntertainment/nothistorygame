class_name Drone
extends Node3D
## Büro'nun keşif dronu (Model Z-DR1; Bölüm 43o). Saniye Hanım'ın demirbaş sayımında saha deposu yanlış tarihe açıldı;
## dron 25 Mayıs 1453'te Osmanlı ordugâhına düştü. Dört pervane, altında kameralı yalpa askısı (gimbal); uçarken
## görüntü, kumandanın ekranından (bu düğümün katmanı) verilir: kayıt noktası, pil, yükseklik, uzaklık, nişangâh.
##
## Kumanda: W/S ileri-geri, A/D yana, fare (ya da sağ çubuk) yön ve kamera eğimi, Boşluk yüksel, Ctrl/C alçal, Shift
## hızlı. Büro kilidi (fence): verilen alanın dışına (43o'da hendeğin ötesine) geçmez, 60 m'den yükseğe çıkmaz ("Frenk
## ayarı").
## Nihat'ın sabotajları: cover_lens (kamerayı eliyle kapatır), set_static (pili gevşetir: görüntü karlanır),
## kill (pil çıkar, dron düşer).
##
## Otomatik uçuş: fly_to(hedef) dronu hedefe götürür (Fatih'in elindeyken ve otomatik testte oyuncunun yerine).

signal crashed(at: Vector3)

const SPEED := 8.0
const FAST := 15.0
const CLIMB := 5.5
const ACCEL := 4.5
const MAX_ALT := 60.0
## Büro kilidi (yerel x-z dikdörtgeni): kuş bunun dışına çıkmaz. Bölüm kendi alanını verir (43o: hendeğin önüne kadar).
var fence := Rect2(-88.0, -105.0, 176.0, 205.0)
const RADIUS := 0.32

var cam: Camera3D
var gimbal: Node3D
var body: Node3D
var piloted := false
var powered := false
var dead := false
var battery := 100.0
## Pilin saniyedeki tükenişi (%); bölüm ders sırasında azaltabilir
var drain := 0.35
var vel := Vector3.ZERO
var yaw := 0.0
var pitch := -0.32
var lens_covered := false
var static_amt := 0.0
## Arazinin yüksekliği: (x, z) -> y. Verilmezse 0.
var ground_fn: Callable
## Otomatik uçuş hedefi (INF: yok) ve hızı
var auto_target := Vector3.INF
var auto_speed := 7.0
var auto_face := Vector3.INF
var fenced := false                 # bu karede Büro kilidine dayandı (bölüm "kuş geçmiyor" der)
var traveled := 0.0
var _auto_best := INF
var _auto_stall := 0.0
var _rotors: Array[Node3D] = []
var _hum: AudioStreamPlayer3D
var _leds: Array[MeshInstance3D] = []
var _blink := 0.0
var _ui: CanvasLayer
var _rec: Label
var _info: Label
var _brand: Label
var _cross: Control
var _noise: ColorRect
var _hand: ColorRect
var _warn: Label
var _shape: SphereShape3D


func _ready() -> void:
	body = Node3D.new()
	add_child(body)
	var dark := Color("2a2c30")
	var grey := Color("6a6e74")
	Props.box(body, Vector3(0.26, 0.09, 0.34), Vector3.ZERO, dark)
	Props.box(body, Vector3(0.2, 0.05, 0.22), Vector3(0, 0.065, -0.02), grey)
	Props.box(body, Vector3(0.12, 0.03, 0.01), Vector3(0, 0.04, -0.175), Color("c8a030"), Vector3.ZERO, 0.4)   # Büro şeridi
	for i in 4:
		var sx := -1.0 if i % 2 == 0 else 1.0
		var sz := -1.0 if i < 2 else 1.0
		var arm_to := Vector3(sx * 0.27, 0.02, sz * 0.27)
		var arm := Props.box(body, Vector3(0.04, 0.03, 0.36), arm_to * 0.5, dark)
		arm.rotation.y = atan2(arm_to.x, arm_to.z)
		Props.cyl(body, 0.035, 0.06, arm_to + Vector3(0, 0.02, 0), grey, Vector3.ZERO, 8)
		var rotor := Node3D.new()
		rotor.position = arm_to + Vector3(0, 0.06, 0)
		body.add_child(rotor)
		var blade := Props.box(rotor, Vector3(0.3, 0.006, 0.03), Vector3.ZERO, Color("1e2024"))
		blade.rotation.y = 0.3 * i
		var disc := Props.cyl(rotor, 0.15, 0.004, Vector3.ZERO, Color(0.8, 0.8, 0.85, 0.12), Vector3.ZERO, 16)
		disc.material_override = Props.mat(Color(0.8, 0.8, 0.85, 0.12), 0.0, true)
		disc.set_meta("disc", true)
		disc.visible = false
		_rotors.append(rotor)
		# Ayaklar
		Props.cyl(body, 0.008, 0.12, Vector3(sx * 0.1, -0.09, sz * 0.12), grey, Vector3.ZERO, 4)
	for c in [Color("ff2a1a"), Color("2aff5a")]:
		var led := Props.ball(body, 0.018, Vector3(-0.1 if c.r > 0.5 else 0.1, 0.0, -0.17), c, Vector3.ONE, 6, 2.0)
		_leds.append(led)
	gimbal = Node3D.new()
	gimbal.position = Vector3(0, -0.07, -0.12)
	body.add_child(gimbal)
	Props.ball(gimbal, 0.045, Vector3.ZERO, dark, Vector3.ONE, 8)
	Props.cyl(gimbal, 0.02, 0.02, Vector3(0, 0, -0.04), Color("101418"), Vector3(90, 0, 0), 10)
	cam = Camera3D.new()
	cam.position = Vector3(0, 0, -0.06)
	cam.fov = 78.0
	cam.near = 0.05
	cam.far = 4000.0
	gimbal.add_child(cam)
	_clear_air.call_deferred()
	_shape = SphereShape3D.new()
	_shape.radius = RADIUS
	_hum = AudioStreamPlayer3D.new()
	var st = load("res://assets/audio/sfx/drone_hum.ogg")
	if st is AudioStreamOggVorbis:
		(st as AudioStreamOggVorbis).loop = true
	_hum.stream = st
	_hum.unit_size = 3.0
	_hum.max_distance = 60.0
	_hum.volume_db = -8.0
	_hum.bus = "SFX"
	add_child(_hum)
	_build_ui()


func _clear_air() -> void:
	if not is_inside_tree():
		return
	var env: Environment = null
	for n in get_tree().root.find_children("*", "WorldEnvironment", true, false):
		if (n as WorldEnvironment).environment != null:
			env = (n as WorldEnvironment).environment
	if env == null:
		env = get_world_3d().environment
	if env == null:
		return
	var e := env.duplicate() as Environment
	e.fog_density *= 0.25
	e.fog_aerial_perspective *= 0.5
	e.volumetric_fog_enabled = false
	cam.environment = e


func _ground(x: float, z: float) -> float:
	return float(ground_fn.call(x, z)) if ground_fn.is_valid() else 0.0


## Yerden yüksekliği (m)
func altitude() -> float:
	return global_position.y - _ground(global_position.x, global_position.z)


func airborne() -> bool:
	return altitude() > 0.25


## Motorlar: çalışınca pervaneler döner, vızıltı başlar.
func power(on: bool) -> void:
	powered = on and not dead
	if powered and not _hum.playing:
		_hum.play()
	elif not powered:
		_hum.stop()
	for r in _rotors:
		for c in r.get_children():
			if c.has_meta("disc"):
				(c as Node3D).visible = powered


## Oyuncu kumandayı alır (görüntü kumandanın ekranına geçer) ya da bırakır.
func pilot(on: bool) -> void:
	piloted = on
	if on:
		yaw = global_rotation.y
		cam.make_current()
	_ui.visible = on


## Görüntüyü kumandanın ekranında göster ama kumandayı verme (Fatih uçururken Tolga omzunun üstünden bakar).
func feed(on: bool) -> void:
	if on:
		cam.make_current()
	_ui.visible = on


func fly_to(target: Vector3, speed := 7.0, face := Vector3.INF) -> void:
	auto_target = target
	auto_speed = speed
	auto_face = face
	_auto_best = INF
	_auto_stall = 0.0
	while is_inside_tree() and auto_target != Vector3.INF and not dead:
		await get_tree().process_frame


func cover_lens(on: bool) -> void:
	lens_covered = on
	_hand.visible = on


func set_static(amount: float) -> void:
	static_amt = amount


## Pil çıktı (Nihat çekti ya da bitti): motor durur, dron düşer.
func kill() -> void:
	if dead:
		return
	dead = true
	power(false)
	auto_target = Vector3.INF
	_warn.text = tr("UI_DRONE_SIGNAL_LOST")
	_warn.visible = true


func _process(delta: float) -> void:
	_blink += delta
	for i in _leds.size():
		_leds[i].visible = powered and fmod(_blink + i * 0.5, 1.0) < 0.5
	if powered:
		for i in _rotors.size():
			_rotors[i].rotate_y((40.0 if i % 2 == 0 else -40.0) * delta)
		_hum.pitch_scale = lerpf(_hum.pitch_scale, 1.0 + clampf(vel.length() / FAST, 0.0, 1.0) * 0.25 + (0.1 if vel.y > 0.5 else 0.0), delta * 4.0)
		battery = maxf(0.0, battery - drain * delta * (1.4 if Input.is_action_pressed("sprint") and piloted else 1.0))
	_update_ui()


func _physics_process(delta: float) -> void:
	var want := Vector3.ZERO
	if dead:
		want = Vector3(vel.x * 0.98, vel.y - 9.8 * delta * 1.6, vel.z * 0.98)
		vel = want
	elif powered:
		if auto_target != Vector3.INF:
			var to := auto_target - global_position
			# Hedefe yaklaşamıyorsa (Büro kilidi, bir engel) bir saniye sonra bırakır: fly_to sonsuza dek beklemesin
			if to.length() < _auto_best - 0.05:
				_auto_best = to.length()
				_auto_stall = 0.0
			else:
				_auto_stall += delta
			if to.length() < 0.6 or _auto_stall > 1.0:
				auto_target = Vector3.INF
			else:
				want = to.limit_length(auto_speed)
				if Vector2(to.x, to.z).length() > 1.0:
					var face_to := (auto_face - global_position) if auto_face != Vector3.INF else to
					yaw = lerp_angle(yaw, atan2(-face_to.x, -face_to.z), clampf(delta * 2.0, 0.0, 1.0))
		elif piloted:
			var mv := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
			var spd := FAST if Input.is_action_pressed("sprint") else SPEED
			want = Basis(Vector3.UP, yaw) * Vector3(mv.x, 0.0, mv.y) * spd
			var up := (1.0 if Input.is_action_pressed("jump") else 0.0) - (1.0 if Input.is_action_pressed("dive") else 0.0)
			want.y = up * CLIMB
			var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
			yaw -= look.x * 2.2 * delta
			pitch = clampf(pitch - look.y * 1.5 * delta, deg_to_rad(-80), deg_to_rad(15))
		vel = vel.lerp(want, clampf(delta * ACCEL, 0.0, 1.0))
		if not airborne() and vel.y < 0.0:
			vel.y = 0.0
	rotation.y = yaw
	gimbal.rotation.x = pitch
	# Gövde hıza göre yatar (dron gibi)
	var local := Basis(Vector3.UP, -yaw) * vel
	body.rotation.x = lerpf(body.rotation.x, clampf(local.z * 0.035, -0.35, 0.35), clampf(delta * 6.0, 0.0, 1.0))
	body.rotation.z = lerpf(body.rotation.z, clampf(-local.x * 0.035, -0.35, 0.35), clampf(delta * 6.0, 0.0, 1.0))
	gimbal.rotation.z = -body.rotation.z
	_move(vel * delta)


func _move(d: Vector3) -> void:
	if d.length() < 0.0001:
		return
	var from := global_position
	var space := get_world_3d().direct_space_state
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = _shape
	q.transform = Transform3D(Basis(), from)
	q.motion = d
	q.collision_mask = 1
	var r := space.cast_motion(q)
	var f := r[0] if r.size() > 0 else 1.0
	var to := from + d * f
	if f < 1.0:
		# Çarptı: kayarak sürer (yüzeye paralel kalan kısım), hız söner
		var rest := d * (1.0 - f)
		var slide := Vector3(rest.x, 0.0, rest.z) * 0.3 + Vector3(0, maxf(rest.y, 0.0), 0)
		to += slide
		vel *= 0.3
		if dead:
			_land(to)
			return
	fenced = false
	if to.x < fence.position.x or to.x > fence.end.x or to.z < fence.position.y or to.z > fence.end.y:
		fenced = true
		to.x = clampf(to.x, fence.position.x, fence.end.x)
		to.z = clampf(to.z, fence.position.y, fence.end.y)
		vel.x *= 0.2
		vel.z *= 0.2
	var gy := _ground(to.x, to.z) + 0.1
	if to.y > gy + MAX_ALT:
		to.y = gy + MAX_ALT
		fenced = true
	if to.y < gy:
		to.y = gy
		if dead:
			_land(to)
			return
	traveled += Vector2(to.x - from.x, to.z - from.z).length()
	global_position = to


func _land(at: Vector3) -> void:
	global_position = at
	vel = Vector3.ZERO
	set_physics_process(false)
	Audio.sfx_at("drone_crash", self, 2.0)
	crashed.emit(at)


func _unhandled_input(event: InputEvent) -> void:
	if not piloted or dead:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mm := event as InputEventMouseMotion
		var sens := 0.0022 * float(GameState.settings.get("mouse", 1.0))
		var inv := -1.0 if GameState.settings.get("invert_y", false) else 1.0
		yaw -= mm.relative.x * sens
		pitch = clampf(pitch - inv * mm.relative.y * sens, deg_to_rad(-80), deg_to_rad(15))


# ---------------------------------------------------------------- kumandanın ekranı

func _build_ui() -> void:
	_ui = CanvasLayer.new()
	_ui.layer = 5
	_ui.visible = false
	add_child(_ui)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(root)
	# Köşe çerçeveleri
	for corner in 4:
		for horiz in [true, false]:
			var r := ColorRect.new()
			r.color = Color(1, 1, 1, 0.75)
			r.size = Vector2(56, 3) if horiz else Vector2(3, 56)
			var ax := 0.0 if corner % 2 == 0 else 1.0
			var ay := 0.0 if corner < 2 else 1.0
			r.anchor_left = ax
			r.anchor_right = ax
			r.anchor_top = ay
			r.anchor_bottom = ay
			r.position = Vector2(-r.size.x - 40 if ax > 0.5 else 40, -r.size.y - 40 if ay > 0.5 else 40)
			r.mouse_filter = Control.MOUSE_FILTER_IGNORE
			root.add_child(r)
	_rec = _label(root, "● REC", Vector2(64, 52), Color("ff3a2a"), 22)
	_brand = _label(root, tr("UI_DRONE_BRAND"), Vector2(170, 52), Color(1, 1, 1, 0.8), 18)
	_info = _label(root, "", Vector2(64, 0), Color(1, 1, 1, 0.9), 20)
	_info.anchor_top = 1.0
	_info.anchor_bottom = 1.0
	_info.position = Vector2(64, -96)
	_warn = _label(root, "", Vector2(0, 0), Color("ffcc33"), 30)
	_warn.anchor_left = 0.5
	_warn.anchor_right = 0.5
	_warn.anchor_top = 0.3
	_warn.anchor_bottom = 0.3
	_warn.position = Vector2(-260, 0)
	_warn.size = Vector2(520, 40)
	_warn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_warn.visible = false
	_cross = Control.new()
	_cross.anchor_left = 0.5
	_cross.anchor_right = 0.5
	_cross.anchor_top = 0.5
	_cross.anchor_bottom = 0.5
	_cross.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_cross)
	for spec in [[Vector2(-26, -1), Vector2(18, 2)], [Vector2(8, -1), Vector2(18, 2)], [Vector2(-1, -26), Vector2(2, 18)], [Vector2(-1, 8), Vector2(2, 18)]]:
		var c := ColorRect.new()
		c.color = Color(1, 1, 1, 0.8)
		c.position = spec[0]
		c.size = spec[1]
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cross.add_child(c)
	# Nihat'ın eli: kameranın önünde kapkara, kenarları ten rengi bulanık bir avuç
	_hand = ColorRect.new()
	_hand.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hs := ShaderMaterial.new()
	var hsh := Shader.new()
	hsh.code = """shader_type canvas_item;
uniform float t = 0.0;
void fragment() {
	vec2 p = UV - vec2(0.5, 0.55);
	float d = length(p * vec2(1.0, 1.25));
	float palm = smoothstep(0.62, 0.25, d);
	float lines = 0.06 * sin(UV.y * 40.0 + UV.x * 6.0);
	vec3 skin = vec3(0.55, 0.36, 0.26) * (0.35 + 0.4 * (1.0 - palm)) + lines;
	COLOR = vec4(mix(skin, vec3(0.06, 0.04, 0.03), palm), 0.97);
}"""
	hs.shader = hsh
	_hand.material = hs
	_hand.visible = false
	root.add_child(_hand)
	_noise = ColorRect.new()
	_noise.set_anchors_preset(Control.PRESET_FULL_RECT)
	_noise.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ns := ShaderMaterial.new()
	var nsh := Shader.new()
	nsh.code = """shader_type canvas_item;
uniform float amount = 0.0;
float h(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	vec2 g = floor(UV * vec2(320.0, 180.0));
	float n = h(g + floor(TIME * 30.0));
	float band = step(0.92, fract(UV.y * 3.0 + TIME * 0.7));
	COLOR = vec4(vec3(n), amount * (0.75 + 0.25 * band));
}"""
	ns.shader = nsh
	_noise.material = ns
	root.add_child(_noise)


func _label(parent: Control, text: String, pos: Vector2, color: Color, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


func _update_ui() -> void:
	if not _ui.visible:
		return
	_rec.visible = fmod(_blink, 1.2) < 0.8
	var home := Vector2(global_position.x, global_position.z)
	_info.text = tr("UI_DRONE_INFO") % [int(round(battery)), altitude(), home.length()]
	(_noise.material as ShaderMaterial).set_shader_parameter("amount", clampf(static_amt + (0.25 if battery < 15.0 else 0.0), 0.0, 1.0))
	if not dead:
		if fenced:
			_warn.text = tr("UI_DRONE_FENCE")
			_warn.visible = true
		elif battery < 15.0:
			_warn.text = tr("UI_DRONE_LOWBAT")
			_warn.visible = true
		else:
			_warn.visible = false
