class_name PhotoMode
extends CanvasLayer
## Foto modu (F2 ya da duraklatma menüsü): oyun durur, serbest kamera Tolga'nın görünen modeliyle.
## WASD/QE kamera, fare bak, tekerlek yakınlık (FOV), F filtre, C çerçeve, P poz, H fes, Boşluk çek, Esc çık.
## Fotoğraf hud.snap_photo ile albüme (filigranlı) kaydedilir; filtre ve çerçeve fotoğrafa dahildir.

signal closed

const MAX_DIST := 8.0
const POSES := ["wave", "cheer", "shrug", "surprise", "laugh", "nod", "facepalm"]
const FILTER_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform int mode = 0;
void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float g = dot(c, vec3(0.299, 0.587, 0.114));
	if (mode == 1) {          // sepya
		c = vec3(g * 1.07, g * 0.87, g * 0.62);
	} else if (mode == 2) {   // 1453 minyatür: doygun, sıcak
		c = mix(vec3(g), c, 1.6) * vec3(1.08, 1.0, 0.86);
	} else if (mode == 3) {   // siyah-beyaz, kontrastlı
		c = vec3(smoothstep(0.05, 0.95, g));
	} else if (mode == 4) {   // Zaman Bürosu: soğuk mavi, taramalı
		c = vec3(g * 0.55, g * 0.85, g * 1.15) * (0.92 + 0.08 * sin(SCREEN_UV.y * 900.0));
	}
	float v = smoothstep(0.95, 0.35, length(SCREEN_UV - vec2(0.5)));   // hafif vinyet
	COLOR = vec4(c * mix(0.78, 1.0, v), 1.0);
}
"""

var player: Player
var hud: Hud
var _cam: Camera3D
var _me: Person
var _fez := true
var _filter := 0
var _frame := 0
var _pose := -1
var _yaw := 0.0
var _pitch := 0.0
var _filter_rect: ColorRect
var _frame_root: Control
var _help: Label
var _info: Label
var _mouse_before := Input.MOUSE_MODE_CAPTURED
var _busy := false
var _fez_orig := true


func _init(p_player: Player, p_hud: Hud) -> void:
	player = p_player
	hud = p_hud
	layer = 9
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	get_tree().paused = true
	hud.visible = false   # çanta, telsiz, altyazı ve birinci şahıs fes kenarı fotoğrafa girmesin
	_mouse_before = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_fez = GameState.flags.get("fez", true)
	_fez_orig = _fez
	player.camera.visible = false   # birinci şahıs el ve eşya modeli fotoğrafa girmesin
	_spawn_me()
	_cam = Camera3D.new()
	_cam.process_mode = Node.PROCESS_MODE_ALWAYS
	_cam.fov = 60.0
	player.get_parent().add_child(_cam)
	var back := player.global_transform.basis.z
	back.y = 0.0
	_cam.global_position = player.global_position + back.normalized() * 2.6 + Vector3(0, 1.7, 0)
	_yaw = player.rotation.y
	_pitch = -0.12
	_apply_rot()
	_cam.make_current()
	# Filtre
	_filter_rect = ColorRect.new()
	_filter_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_filter_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sm := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = FILTER_SHADER
	sm.shader = sh
	_filter_rect.material = sm
	add_child(_filter_rect)
	_frame_root = Control.new()
	_frame_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_frame_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame_root)
	# Yardım ve durum
	_help = Label.new()
	_help.text = tr("UI_PHOTO_HELP_PAD" if GameState.pad else "UI_PHOTO_HELP")
	_help.add_theme_font_size_override("font_size", 16)
	_help.add_theme_color_override("font_color", Color("f2e6c9"))
	_help.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_help.position = Vector2(24, 20)
	add_child(_help)
	_info = Label.new()
	_info.add_theme_font_size_override("font_size", 16)
	_info.add_theme_color_override("font_color", Color("6ff2c8"))
	_info.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_info.position = Vector2(24, 46)
	add_child(_info)
	_refresh()


func _spawn_me() -> void:
	if _me:
		_me.queue_free()
	GameState.flags["fez"] = _fez
	_me = player._me_person()
	_me.process_mode = Node.PROCESS_MODE_ALWAYS
	player.get_parent().add_child(_me)
	_me.global_position = player.global_position
	_me.rotation.y = player.rotation.y + PI


func _apply_rot() -> void:
	_cam.rotation = Vector3(_pitch, _yaw, 0.0)


func _refresh() -> void:
	(_filter_rect.material as ShaderMaterial).set_shader_parameter("mode", _filter)
	_filter_rect.visible = _filter != 0
	for c in _frame_root.get_children():
		c.queue_free()
	var vs := get_viewport().get_visible_rect().size
	if _frame == 1:   # polaroid: beyaz kenar, altta kalın şerit ve yazı
		for r in [Rect2(0, 0, vs.x, 28), Rect2(0, 0, 28, vs.y), Rect2(vs.x - 28, 0, 28, vs.y), Rect2(0, vs.y - 110, vs.x, 110)]:
			var cr := ColorRect.new()
			cr.color = Color("f4f1ea")
			cr.position = r.position
			cr.size = r.size
			_frame_root.add_child(cr)
		var cap := Label.new()
		cap.text = tr("UI_PHOTO_POLAROID")
		cap.add_theme_font_size_override("font_size", 30)
		cap.add_theme_color_override("font_color", Color("1d2330"))
		cap.position = Vector2(48, vs.y - 86)
		_frame_root.add_child(cap)
	elif _frame == 2:   # gazete: üstte manşet, altta tarih
		var top := ColorRect.new()
		top.color = Color("efe6cf")
		top.size = Vector2(vs.x, 96)
		_frame_root.add_child(top)
		var head := Label.new()
		head.text = tr("UI_PHOTO_NEWS")
		head.add_theme_font_size_override("font_size", 52)
		head.add_theme_color_override("font_color", Color("1d2330"))
		if hud._title_font:
			head.add_theme_font_override("font", hud._title_font)
		head.size = Vector2(vs.x, 96)
		head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		head.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_frame_root.add_child(head)
		var bottom := ColorRect.new()
		bottom.color = Color("efe6cf")
		bottom.position = Vector2(0, vs.y - 48)
		bottom.size = Vector2(vs.x, 48)
		_frame_root.add_child(bottom)
		var date := Label.new()
		date.text = tr("UI_PHOTO_NEWS_DATE")
		date.add_theme_font_size_override("font_size", 20)
		date.add_theme_color_override("font_color", Color("5a2a2a"))
		date.position = Vector2(24, vs.y - 38)
		_frame_root.add_child(date)
	_help.position.y = 110.0 if _frame == 2 else 20.0
	_info.position.y = _help.position.y + 26.0
	_info.text = tr("UI_PHOTO_INFO") % [tr("UI_PHOTO_F_%d" % _filter), tr("UI_PHOTO_C_%d" % _frame), int(_cam.fov)]


func _process(delta: float) -> void:
	if _busy:
		return
	var input := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input.z -= 1.0
	if Input.is_action_pressed("move_back"):
		input.z += 1.0
	if Input.is_action_pressed("move_left"):
		input.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input.x += 1.0
	if Input.is_key_pressed(KEY_E):
		input.y += 1.0
	if Input.is_key_pressed(KEY_Q):
		input.y -= 1.0
	# Kol: tetikler yükseklik, sağ çubuk bakış
	input.y += Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT) - Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT)
	var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look.length_squared() > 0.0001:
		_yaw -= look.x * 2.4 * delta
		_pitch = clampf(_pitch - look.y * 2.0 * delta, -1.4, 1.4)
		_apply_rot()
	var lx := Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var ly := Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	if absf(lx) > 0.35 and input.x == 0.0:
		input.x = lx
	if absf(ly) > 0.35 and input.z == 0.0:
		input.z = ly
	if absf(input.y) < 0.2:
		input.y = 0.0
	if input != Vector3.ZERO:
		var speed := 5.0 if Input.is_action_pressed("sprint") else 2.2
		var move := _cam.global_transform.basis * Vector3(input.x, 0, input.z)
		move.y = input.y
		var p := _cam.global_position + move.normalized() * speed * delta
		var center := player.global_position + Vector3(0, 1.2, 0)
		if p.distance_to(center) > MAX_DIST:
			p = center + (p - center).normalized() * MAX_DIST
		p.y = maxf(p.y, player.global_position.y + 0.25)
		_cam.global_position = p


func _input(event: InputEvent) -> void:
	if _busy:
		return
	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * 0.003
		_pitch = clampf(_pitch - event.relative.y * 0.003, -1.4, 1.4)
		_apply_rot()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_cam.fov = clampf(_cam.fov - 3.0, 20.0, 90.0)
			_refresh()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_cam.fov = clampf(_cam.fov + 3.0, 20.0, 90.0)
			_refresh()
	elif event is InputEventJoypadButton and event.pressed:
		match (event as InputEventJoypadButton).button_index:
			JOY_BUTTON_X:
				_filter = (_filter + 1) % 5
				_refresh()
			JOY_BUTTON_Y:
				_frame = (_frame + 1) % 3
				_refresh()
			JOY_BUTTON_RIGHT_SHOULDER:
				_pose = (_pose + 1) % POSES.size()
				_me.emote(POSES[_pose])
			JOY_BUTTON_BACK:
				_fez = not _fez
				_spawn_me()
			JOY_BUTTON_A:
				_shoot()
			JOY_BUTTON_B, JOY_BUTTON_START:
				close()
			JOY_BUTTON_DPAD_UP:
				_cam.fov = clampf(_cam.fov - 5.0, 20.0, 90.0)
				_refresh()
			JOY_BUTTON_DPAD_DOWN:
				_cam.fov = clampf(_cam.fov + 5.0, 20.0, 90.0)
				_refresh()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F:
				_filter = (_filter + 1) % 5
				_refresh()
			KEY_C:
				_frame = (_frame + 1) % 3
				_refresh()
			KEY_P:
				_pose = (_pose + 1) % POSES.size()
				_me.emote(POSES[_pose])
			KEY_H:
				_fez = not _fez
				_spawn_me()
			KEY_SPACE:
				_shoot()
			KEY_ESCAPE, KEY_F2:
				close()
	get_viewport().set_input_as_handled()


func _shoot() -> void:
	_busy = true
	_help.visible = false
	_info.visible = false
	hud.visible = false
	await hud.snap_photo("photo")
	hud.visible = false
	var flash := ColorRect.new()
	flash.color = Color.WHITE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	var tw := create_tween()
	tw.tween_property(flash, "modulate:a", 0.0, 0.35)
	tw.tween_callback(flash.queue_free)
	_info.text = tr("UI_PHOTO_SAVED")
	await get_tree().create_timer(0.8).timeout
	_refresh()
	_help.visible = true
	_info.visible = true
	_busy = false


func close() -> void:
	_cam.queue_free()
	_me.queue_free()
	player.camera.visible = true
	player.camera.make_current()
	hud.visible = true
	GameState.flags["fez"] = _fez_orig
	get_tree().paused = false
	Input.mouse_mode = _mouse_before
	closed.emit()
	queue_free()
