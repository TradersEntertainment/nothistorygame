class_name NihatPowers
extends Node
## Nihat'ın Büro donanımı (Bölüm 3'te Rıza Bey verir): Kaldırma Formu Z-9 ile uçar (F), Zaman Perdesi ile görünmez
## olur (Q). Oyuncunun (Player) çocuğudur; uçuş fiziğini Player çağırır (fly).
##
## Görünürken uçarsa çevredeki herkes onu görür: döner, şaşırır, bağırır ("Cin!", "Melek!"). Her görülme sayılır
## (GameState.flags["nihat_seen"]); bölümdeki ilk görülme Büro Baskısı +1, üçüncü görülme 1453'te bir efsane doğurur
## (flying_legend). Bölümler witnessed sinyaliyle tanığa göre hikâyeyi değiştirir (ör. yalan söyleyecek tanık, gökten
## inen denetçiye yalan söyleyemez). Görünmezken birinin 3 m yanına sokulunca eavesdrop gelir (fısıltı).

signal witnessed(node: Node3D)
signal eavesdrop(node: Node3D)
signal veil_changed(on: bool)

const FLY_SPEED := 7.0
const FLY_BOOST := 18.0
const MAX_ALT := 70.0
const CLOAK_DRAIN := 1.0 / 24.0
const CLOAK_RECHARGE := 1.0 / 30.0
const SEE_RANGE := 32.0
## Uçuş menzili: saha kapısından (donanımın açıldığı yer) en çok bu kadar uzaklaşılır
const RANGE := 150.0
const LEGEND_AT := 5
## Süzülüş: yüksekte koşu tuşuyla şehirler arası hız
const GLIDE := 32.0
## Seyir defteri: oyun boyunca uçarak görülebilecek yerler (Bölüm 7 ve 11 şehir manzarası)
const LANDMARK_IDS := ["AYASOFYA", "HIPODROM", "KONSTANTIN", "HAVARIYUN", "BOZDOGAN", "ZINCIR", "GALATA", "BLAKHERNA", "SURLAR"]
const MARK_RANGE := 900.0
## Uçuşan formlar: Nihat'ın ilk uçuşta saçtığı Z-9 formları şehrin en yüksek yerlerine kondu (yan görev "forms")
const FORMS_TOTAL := 12
const FORM_MARK_RANGE := 140.0

var player: Player
var chapter := 0
var can_fly := true
var can_cloak := true
var flying := false
var cloaked := false
var landing := false
var energy := 1.0
var seen_here := 0
var _seen: Dictionary = {}
var _near: Dictionary = {}
var _scan_t := 0.0
var _bark_cd := 0.0
var _view_shown := false
var _first_fly := true
var _layer: CanvasLayer
var _tint: ColorRect
var _bar: ProgressBar
var _state: Label
var _alt := 0.0
var _home := Vector3.INF
var _edge_cd := 0.0
var _v := Vector3.ZERO      # uçuş hızı (Player yerçekimsizken dikey hızı sıfırlar; burada tutulur)
var range_m := RANGE
var max_alt := MAX_ALT
## Bu bölümün seyir noktaları: {id, pos, r, seen}
var landmarks: Array = []
var _marks: Array = []
var _toast: Label
var _env: Environment
## {id, node, paper, t}
var _forms: Array = []
var _form_marks: Array = []
## Konma noktaları (yan görev "perch"): {id, pos, r}
var _perches: Array = []
var _was_flying := false
var _explore_hint := false
## Ayağın altındaki Kaldırma Formu Z-9 (uçarken görünür; aşağı bakınca)
var _board: HoverRig
var _fog0 := -1.0


func _ready() -> void:
	player = get_parent() as Player
	_build_ui()


func _build_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 40
	add_child(_layer)
	_tint = ColorRect.new()
	_tint.color = Color(1, 1, 1, 1)
	_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tint.material = _veil_material()
	_tint.visible = false
	# Perde yalnız 3B görüntüye: arayüzün (altyazı, hedef) altında ayrı katman, yazılar dalgalanmasın
	var veil_layer := CanvasLayer.new()
	veil_layer.layer = -1
	add_child(veil_layer)
	veil_layer.add_child(_tint)
	var box := PanelContainer.new()
	box.anchor_top = 1.0
	box.anchor_bottom = 1.0
	box.offset_left = 18
	box.offset_top = -92
	box.offset_bottom = -18
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.1, 0.14, 0.72)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	box.add_theme_stylebox_override("panel", sb)
	_layer.add_child(box)
	var vb := VBoxContainer.new()
	box.add_child(vb)
	_state = Label.new()
	_state.add_theme_font_size_override("font_size", 15)
	_state.add_theme_color_override("font_color", Color("c9f2e8"))
	vb.add_child(_state)
	_bar = ProgressBar.new()
	_bar.custom_minimum_size = Vector2(190, 8)
	_bar.max_value = 1.0
	_bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("6ff2c8")
	fill.set_corner_radius_all(4)
	_bar.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(1, 1, 1, 0.12)
	bg.set_corner_radius_all(4)
	_bar.add_theme_stylebox_override("background", bg)
	vb.add_child(_bar)
	_toast = Label.new()
	_toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast.offset_top = 64
	_toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_font_size_override("font_size", 22)
	_toast.add_theme_color_override("font_color", Color("f2e6c9"))
	_toast.add_theme_color_override("font_outline_color", Color(0.05, 0.06, 0.1, 0.9))
	_toast.add_theme_constant_override("outline_size", 6)
	_toast.modulate.a = 0.0
	_layer.add_child(_toast)
	_refresh_ui()


## Uçuşan formlar: [[numara, dünya konumu], ...]; toplananlar (form_N bayrağı) yeniden çıkmaz.
func add_forms(list: Array) -> void:
	var scene := get_tree().current_scene
	for f in list:
		var id := int(f[0])
		if GameState.flags.get("form_%d" % id, false):
			continue
		var n := Node3D.new()
		scene.add_child(n)
		n.global_position = f[1]
		var paper := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(0.55, 0.75)
		paper.mesh = qm
		var pm := StandardMaterial3D.new()
		pm.albedo_color = Color("f2ecd8")
		pm.emission_enabled = true
		pm.emission = Color("fff0c0")
		pm.emission_energy_multiplier = 0.6
		pm.cull_mode = BaseMaterial3D.CULL_DISABLED
		paper.material_override = pm
		n.add_child(paper)
		var stamp := MeshInstance3D.new()
		var sq := QuadMesh.new()
		sq.size = Vector2(0.16, 0.16)
		stamp.mesh = sq
		stamp.position = Vector3(0.12, -0.2, 0.005)
		var sm := StandardMaterial3D.new()
		sm.albedo_color = Color("c8262f")
		sm.cull_mode = BaseMaterial3D.CULL_DISABLED
		stamp.material_override = sm
		paper.add_child(stamp)
		# Altın ışık hüzmesi: uzaktan görünür, keşfe çağırır
		var beam := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.25
		cm.bottom_radius = 0.9
		cm.height = 70.0
		cm.radial_segments = 8
		cm.rings = 1
		beam.mesh = cm
		beam.position = Vector3(0, 35.0, 0)
		var bm := StandardMaterial3D.new()
		bm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		bm.albedo_color = Color(1.0, 0.82, 0.35, 0.32)
		bm.cull_mode = BaseMaterial3D.CULL_DISABLED
		beam.material_override = bm
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		n.add_child(beam)
		_forms.append({"id": id, "node": n, "paper": paper, "t": randf() * TAU, "base": n.global_position})
	while _form_marks.size() < 3:
		var m := Label.new()
		m.add_theme_font_size_override("font_size", 14)
		m.add_theme_color_override("font_color", Color("ffe08a"))
		m.add_theme_color_override("font_outline_color", Color(0.05, 0.06, 0.1, 0.85))
		m.add_theme_constant_override("outline_size", 5)
		m.visible = false
		_layer.add_child(m)
		_form_marks.append(m)


## Konma noktaları: [[id, dünya konumu, yarıçap], ...]
func add_perches(list: Array) -> void:
	for p in list:
		_perches.append({"id": p[0], "pos": p[1], "r": p[2]})


func _update_forms(delta: float) -> void:
	var here := player.global_position + Vector3.UP * 1.0
	var near: Array = []
	for f in _forms:
		if not is_instance_valid(f.node):
			continue
		f.t += delta
		(f.paper as Node3D).rotation.y = f.t * 1.6
		(f.node as Node3D).global_position = f.base + Vector3(0, sin(f.t * 1.8) * 0.18, 0)
		var d := here.distance_to(f.base)
		if d < 2.6:
			_collect_form(f)
			continue
		if d < FORM_MARK_RANGE:
			near.append([d, f])
	_forms = _forms.filter(func(f): return is_instance_valid(f.node))
	near.sort_custom(func(a, b): return a[0] < b[0])
	var cam := player.camera
	for i in _form_marks.size():
		var m: Label = _form_marks[i]
		if i >= near.size() or cam == null or player.frozen:
			m.visible = false
			continue
		var p: Vector3 = near[i][1].base
		if cam.is_position_behind(p):
			m.visible = false
			continue
		m.text = tr("UI_FORM_MARK") % int(near[i][0])
		m.reset_size()
		m.position = cam.unproject_position(p) - Vector2(m.size.x * 0.5, m.size.y + 12.0)
		m.visible = true


func _collect_form(f: Dictionary) -> void:
	GameState.flags["form_%d" % f.id] = true
	(f.node as Node3D).queue_free()
	var got := 0
	for i in range(1, FORMS_TOTAL + 1):
		if GameState.flags.get("form_%d" % i, false):
			got += 1
	Audio.sfx("paper_tear", -6.0, 1.3)
	_toast.text = tr("UI_FORM_FOUND") % [got, FORMS_TOTAL]
	var tw := create_tween()
	tw.tween_property(_toast, "modulate:a", 1.0, 0.3)
	tw.tween_interval(2.5)
	tw.tween_property(_toast, "modulate:a", 0.0, 0.6)
	var h := _hud()
	if h and not h.is_talking():
		if got >= FORMS_TOTAL:
			h.bark("SPK_NIHAT", "D_FORM_ALL", 5.5)
		else:
			h.bark("SPK_NIHAT", "D_FORM_%d" % (got % 4 + 1), 3.5)


func _check_perch() -> void:
	# Uçuştan inip bir noktaya konunca
	if flying or landing or not player.is_on_floor():
		return
	var here := player.global_position
	for p in _perches:
		var key := "perch_%s" % str(p.id)
		if GameState.flags.get(key, false) or here.distance_to(p.pos) > p.r:
			continue
		GameState.flags[key] = true
		var h := _hud()
		if h and not h.is_talking():
			h.bark("SPK_NIHAT", "D_PERCH_%s" % str(p.id).to_upper(), 5.5)


## Suya inince (CityPanorama.water_catch): Büro formları ıslanmaz, donanım kendiliğinden havalanır.
func on_water() -> void:
	set_flying(true)
	_v = Vector3(_v.x * 0.3, 7.0, _v.z * 0.3)
	var h := _hud()
	if h and not h.is_talking() and _edge_cd <= 0.0:
		_edge_cd = 5.0
		h.bark("SPK_NIHAT", "D_NIHAT_WATER", 3.5)


## Bölüm, uçarak gidilebilecek yerleri verir: [[id, dünya konumu, yarıçap], ...]. reach: bu bölümde uçuş menzili.
func add_landmarks(list: Array, reach := 0.0, alt := 0.0) -> void:
	for l in list:
		landmarks.append({"id": l[0], "pos": l[1], "r": l[2], "seen": false})
	range_m = maxf(range_m, reach)
	max_alt = maxf(max_alt, alt)
	while _marks.size() < landmarks.size():
		var m := Label.new()
		m.add_theme_font_size_override("font_size", 15)
		m.add_theme_color_override("font_color", Color("fff2c8"))
		m.add_theme_color_override("font_outline_color", Color(0.05, 0.06, 0.1, 0.85))
		m.add_theme_constant_override("outline_size", 5)
		m.visible = false
		_layer.add_child(m)
		_marks.append(m)


func _update_marks() -> void:
	var cam := player.camera
	var show := flying and not player.frozen and cam != null
	var here := player.global_position
	# Yalnız en yakın dört hedef: ufuk yazıyla dolmasın
	var near: Array = []
	for lm in landmarks:
		if not lm.seen:
			near.append(lm)
	near.sort_custom(func(a, b): return here.distance_to(a.pos) < here.distance_to(b.pos))
	near = near.slice(0, 4)
	for i in _marks.size():
		var m: Label = _marks[i]
		var lm: Dictionary = landmarks[i] if i < landmarks.size() else {}
		if not show or lm.is_empty() or lm.seen or not near.has(lm):
			m.visible = false
			continue
		var p: Vector3 = lm.pos
		var d := here.distance_to(p)
		if d > MARK_RANGE or cam.is_position_behind(p):
			m.visible = false
			continue
		var sp := cam.unproject_position(p)
		m.text = tr("UI_LM_MARK") % [tr("LM_" + str(lm.id)), int(d)]
		m.reset_size()
		m.position = sp - Vector2(m.size.x * 0.5, m.size.y * 0.5)
		# Uzaktakiler soluk: yakındaki hedef öne çıksın
		m.modulate.a = clampf(1.2 - d / MARK_RANGE, 0.35, 1.0)
		m.visible = true


## Şehir manzaralı bölümlerde yükseldikçe sis incelir: uzaktaki yapılar seçilsin (yerde eski hâline döner).
func _thin_fog(delta: float) -> void:
	if landmarks.is_empty():
		return
	if _env == null:
		var we := get_tree().current_scene.find_children("*", "WorldEnvironment", true, false) if get_tree().current_scene else []
		if we.is_empty():
			return
		_env = (we[0] as WorldEnvironment).environment
		_fog0 = _env.fog_density
	var k := clampf((_alt - 8.0) / 30.0, 0.0, 1.0) if flying else 0.0
	_env.fog_density = lerpf(_env.fog_density, lerpf(_fog0, minf(_fog0, 0.0007), k), clampf(delta * 1.5, 0.0, 1.0))


func _check_landmarks() -> void:
	var here := player.global_position
	for lm in landmarks:
		if lm.seen or here.distance_to(lm.pos) > lm.r:
			continue
		lm.seen = true
		var book: Array = (GameState.flags.get("nihat_landmarks", []) as Array).duplicate()
		if not book.has(lm.id):
			book.append(lm.id)
		GameState.flags["nihat_landmarks"] = book
		GameState.flags["lm_%s" % str(lm.id)] = true
		Audio.sfx("radio_beep", -8.0, 1.4)
		_toast.text = tr("UI_LM_FOUND") % [tr("LM_" + str(lm.id)), book.size(), LANDMARK_IDS.size()]
		var tw := create_tween()
		tw.tween_property(_toast, "modulate:a", 1.0, 0.4)
		tw.tween_interval(3.5)
		tw.tween_property(_toast, "modulate:a", 0.0, 0.8)
		var h := _hud()
		if h and not h.is_talking():
			_bark_cd = 6.0
			h.bark("SPK_NIHAT", "D_LM_" + str(lm.id), 6.0)
		if book.size() >= LANDMARK_IDS.size() and not GameState.flags.get("nihat_seyyah", false):
			GameState.flags["nihat_seyyah"] = true
			get_tree().create_timer(6.5).timeout.connect(func():
				if is_instance_valid(h) and not h.is_talking():
					h.bark("SPK_NIHAT", "D_NIHAT_SEYYAH", 5.0))
		return


func _refresh_ui() -> void:
	var parts: PackedStringArray = []
	if can_fly:
		parts.append(("✈ " if flying else "") + tr("UI_POW_FLY"))
	if can_cloak:
		parts.append(("◌ " if cloaked else "") + tr("UI_POW_CLOAK"))
	_state.text = "   ".join(parts)
	_bar.visible = can_cloak
	_bar.value = energy


func _hud() -> Hud:
	return get_tree().get_first_node_in_group("hud") as Hud


func _unhandled_input(event: InputEvent) -> void:
	if GameState.autotest or player == null or player.frozen:
		return
	if can_fly and event.is_action_pressed("fly"):
		set_flying(not flying)
		get_viewport().set_input_as_handled()
	elif can_cloak and event.is_action_pressed("cloak"):
		set_cloak(not cloaked)
		get_viewport().set_input_as_handled()


func set_flying(on: bool) -> void:
	if on == flying:
		return
	flying = on
	player.gravity_on = not on
	if on and _board == null:
		_board = HoverRig.make(player)
		_board.position = Vector3(0, 0.02, 0)
	elif not on and _board:
		_board.queue_free()
		_board = null
	if on:
		landing = false
		_v = Vector3(player.velocity.x, 3.5, player.velocity.z)
		Audio.sfx("whoosh_fly", -8.0, 0.8)
		if _first_fly:
			_first_fly = false
			var h := _hud()
			if h and not h.is_talking():
				h.bark("SPK_NIHAT", "D_NIHAT_FLY_FIRST", 3.5)
	else:
		landing = true
		Audio.sfx("paper_tear", -14.0, 0.8)
	_refresh_ui()


func set_cloak(on: bool) -> void:
	if on == cloaked:
		return
	if on and energy < 0.15:
		var h := _hud()
		if h:
			h.bark("SPK_NIHAT", "D_NIHAT_CLOAK_EMPTY", 2.5)
		return
	cloaked = on
	Audio.sfx("whoosh_fly", -8.0, 0.55 if on else 0.8)
	Audio.sfx("radio_beep", -14.0, 0.5 if on else 0.8)
	# Zaman Perdesi: kenarlarda dalgalanan turkuaz perde, soluk renkler, alçak uğultu; el yarı saydam titrer
	_tint.visible = true
	var mat := _tint.material as ShaderMaterial
	var tw := create_tween()
	tw.tween_method(func(k: float): mat.set_shader_parameter("k", k), 0.0 if on else 1.0, 1.0 if on else 0.0, 0.35)
	if not on:
		tw.tween_callback(func(): _tint.visible = cloaked)
	_veil_hum(on)
	if player.hand:
		player.hand.visible = not on
	# Görenler için ortadan kaybolur: ona bakan şaşırıp etrafına bakınır; perde inince yeniden belirir (irkilir)
	for n in _people():
		var pn := n as Node3D
		if pn == null or not pn.is_visible_in_tree() or pn.global_position.distance_to(player.global_position) > 14.0:
			continue
		if on and pn.get("look_target") == player:
			pn.set_meta("veil_prev_look", true)
			pn.set("look_target", null)
			if pn.has_method("emote"):
				pn.call("emote", "surprise")
		elif not on and pn.has_meta("veil_prev_look"):
			pn.remove_meta("veil_prev_look")
			pn.set("look_target", player)
			if pn.has_method("emote"):
				pn.call("emote", "surprise")
	veil_changed.emit(on)
	_refresh_ui()


func _veil_material() -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = """shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float k = 0.0;
void fragment() {
	vec2 uv = SCREEN_UV;
	float edge = smoothstep(0.28, 0.78, length((uv - 0.5) * vec2(1.25, 1.0)) * 1.3);
	float wave = sin(uv.y * 70.0 + TIME * 5.0) * 0.5 + sin(uv.y * 23.0 - TIME * 2.3) * 0.5;
	vec2 off = vec2(wave * 0.006 * edge * k, 0.0);
	vec3 c = textureLod(screen_tex, uv + off, 0.0).rgb;
	float g = dot(c, vec3(0.3, 0.59, 0.11));
	c = mix(c, vec3(g) * vec3(0.82, 0.98, 1.02), 0.32 * k);
	float lines = smoothstep(0.94, 1.0, sin(uv.y * 180.0 + TIME * 9.0));
	vec3 teal = vec3(0.1, 0.42, 0.46);
	c = mix(c, c * vec3(0.8, 1.0, 1.0) + teal * (0.6 + 0.3 * sin(TIME * 3.0 + uv.y * 18.0)), edge * k * 0.55);
	c += teal * lines * 0.08 * k;
	COLOR = vec4(c, 1.0);
}"""
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("k", 0.0)
	return m


var _hum: AudioStreamPlayer


func _veil_hum(on: bool) -> void:
	if _hum == null:
		var st := load("res://assets/audio/sfx/veil_hum.ogg") as AudioStreamOggVorbis
		if st == null:
			return
		st = st.duplicate()
		st.loop = true
		_hum = AudioStreamPlayer.new()
		_hum.stream = st
		_hum.bus = "SFX"
		_hum.volume_db = -40.0
		add_child(_hum)
	if on and not _hum.playing:
		_hum.play()
	var tw := _hum.create_tween()
	tw.tween_property(_hum, "volume_db", -13.0 if on else -40.0, 0.4)
	if not on:
		tw.tween_callback(_hum.stop)


## Etkileşimden önce: görünmezken biriyle konuşulmaz, perde düşer.
func before_interact(id: String) -> void:
	if cloaked and not (id.begins_with("trace") or id.begins_with("clue")):
		set_cloak(false)
		var h := _hud()
		if h and not h.is_talking():
			h.bark("SPK_NIHAT", "D_NIHAT_CLOAK_TALK", 2.5)


## Player._physics_process her karede çağırır (uçarken).
func fly(delta: float) -> void:
	if player.frozen:
		_v = _v.lerp(Vector3.ZERO, clampf(delta * 5.0, 0.0, 1.0))
		player.velocity = _v
		player.move_and_slide()
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir := player.camera.global_transform.basis * Vector3(input.x, 0, input.y)
	if Input.is_action_pressed("jump"):
		dir += Vector3.UP
	if Input.is_action_pressed("dive"):
		dir += Vector3.DOWN
	if dir.length() > 1.0:
		dir = dir.normalized()
	var sp := FLY_SPEED
	if Input.is_action_pressed("sprint"):
		sp = GLIDE if _alt > 20.0 else FLY_BOOST
	var want := dir * sp
	if _alt > max_alt and want.y > 0.0:
		want.y = 0.0
	# Menzil: saha kapısından çok uzaklaşınca geri iter
	if _home == Vector3.INF:
		_home = player.global_position
	var off := Vector2(player.global_position.x - _home.x, player.global_position.z - _home.z)
	if off.length() > range_m:
		var back := -Vector3(off.x, 0, off.y).normalized()
		want = want - back * minf(0.0, want.dot(back)) + back * 4.0
		_edge_cd -= delta
		if _edge_cd <= 0.0:
			_edge_cd = 6.0
			var h := _hud()
			if h and not h.is_talking():
				h.bark("SPK_NIHAT", "D_NIHAT_EDGE", 3.0)
	_v = _v.lerp(want, clampf(delta * 3.5, 0.0, 1.0))
	player.velocity = _v
	player.move_and_slide()
	_v = player.velocity
	# Hafif yatış: yana dönerken kamera eğilir
	player.camera.rotation.z = lerpf(player.camera.rotation.z, -input.x * 0.1, clampf(delta * 4.0, 0.0, 1.0))


func _physics_process(delta: float) -> void:
	if player == null:
		return
	# Yere olan yükseklik
	var from := player.global_position + Vector3.UP * 0.2
	var q := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 200.0, 1, [player.get_rid()])
	var hit := player.get_world_3d().direct_space_state.intersect_ray(q)
	_alt = (from.y - (hit["position"] as Vector3).y) if not hit.is_empty() else 200.0
	if landing:
		# Formlar paraşüt olur: yavaşça süzülür
		player.velocity.y = maxf(player.velocity.y, -3.5)
		if player.is_on_floor():
			landing = false
			player.camera.rotation.z = 0.0


func _process(delta: float) -> void:
	if player == null:
		return
	_bark_cd = maxf(0.0, _bark_cd - delta)
	if cloaked:
		energy = maxf(0.0, energy - CLOAK_DRAIN * delta)
		if energy <= 0.0:
			set_cloak(false)
			var h := _hud()
			if h:
				h.bark("SPK_NIHAT", "D_NIHAT_CLOAK_OUT", 3.0)
	else:
		energy = minf(1.0, energy + CLOAK_RECHARGE * delta)
	_bar.value = energy
	if flying and not _view_shown and _alt > 25.0:
		_view_shown = true
		var key := "D_NIHAT_VIEW_%d" % chapter
		var h := _hud()
		if h and not h.is_talking():
			h.bark("SPK_NIHAT", key if tr(key) != key else "D_NIHAT_VIEW", 4.5)
	_update_marks()
	_thin_fog(delta)
	if not _forms.is_empty():
		_update_forms(delta)
	if flying and not _explore_hint and not _forms.is_empty() and _alt > 12.0:
		_explore_hint = true
		get_tree().create_timer(5.0).timeout.connect(func():
			var hh := _hud()
			if hh and not hh.is_talking():
				hh.bark("SPK_NIHAT", "D_NIHAT_EXPLORE", 6.0))
	_scan_t -= delta
	if _scan_t > 0.0:
		return
	_scan_t = 0.25
	if flying and not cloaked and _alt > 1.2:
		_look_for_witnesses()
	if flying and not landmarks.is_empty():
		_check_landmarks()
	if not _perches.is_empty():
		_check_perch()
	if cloaked:
		_look_for_listeners()


func _people() -> Array:
	var out: Array = []
	for g in ["persons", "soldiers", "persons_hikmet"]:
		out.append_array(get_tree().get_nodes_in_group(g))
	return out


func _look_for_witnesses() -> void:
	var here := player.global_position + Vector3.UP * 1.0
	var space := player.get_world_3d().direct_space_state
	for n in _people():
		var p := n as Node3D
		if p == null or not p.is_visible_in_tree() or _seen.has(p.get_instance_id()) or player.is_ancestor_of(p):
			continue
		var eye := p.global_position + Vector3.UP * 1.5
		if eye.distance_to(here) > SEE_RANGE:
			continue
		var q := PhysicsRayQueryParameters3D.create(eye, here, 1, [player.get_rid()])
		if not space.intersect_ray(q).is_empty():
			continue
		_seen[p.get_instance_id()] = true
		_witness(p)


func _witness(p: Node3D) -> void:
	if "look_target" in p:
		p.set("look_target", player)
	if p.has_method("emote"):
		p.call("emote", "surprise")
	seen_here += 1
	GameState.flags["nihat_seen"] = int(GameState.flags.get("nihat_seen", 0)) + 1
	var h := _hud()
	if h and _bark_cd <= 0.0 and not h.is_talking():
		_bark_cd = 2.8
		h.bark("SPK_WITNESS", "D_WIT_%d" % (randi() % 10 + 1), 2.6)
	if seen_here == 1:
		GameState.flags["buro_baskisi"] = int(GameState.flags.get("buro_baskisi", 0)) + 1
		if h:
			get_tree().create_timer(1.2).timeout.connect(func():
				if is_instance_valid(h) and not h.is_talking():
					h.bark("SPK_NIHAT", "D_NIHAT_SEEN_1", 3.5))
	if seen_here == LEGEND_AT and not GameState.flags.get("flying_legend", false):
		GameState.flags["flying_legend"] = true
		GameState.bump_stat("flying_legend")
		if h:
			get_tree().create_timer(4.0).timeout.connect(func():
				if is_instance_valid(h) and not h.is_talking():
					h.bark("SPK_NIHAT", "D_NIHAT_LEGEND", 4.0))
	witnessed.emit(p)


func _look_for_listeners() -> void:
	var here := player.global_position
	for n in _people():
		var p := n as Node3D
		if p == null or not p.is_visible_in_tree() or _near.has(p.get_instance_id()):
			continue
		if Vector2(p.global_position.x - here.x, p.global_position.z - here.z).length() < 3.0 and absf(p.global_position.y - here.y) < 2.5:
			_near[p.get_instance_id()] = true
			eavesdrop.emit(p)


## Bölüm yeniden kontrolü başka birine verirken (Bölüm 11: Tolga'ya geçiş) donanımı kapatır.
func shutdown() -> void:
	set_flying(false)
	set_cloak(false)
	landing = false
	player.gravity_on = true
	_layer.visible = false
	set_process_unhandled_input(false)
	set_process(false)
