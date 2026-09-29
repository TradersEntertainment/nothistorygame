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
var _fog0 := -1.0


func _ready() -> void:
	player = get_parent() as Player
	_build_ui()


func _build_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 40
	add_child(_layer)
	_tint = ColorRect.new()
	_tint.color = Color(0.3, 0.9, 0.85, 0.0)
	_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(_tint)
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
	_env.fog_density = lerpf(_env.fog_density, _fog0 * (1.0 - 0.72 * k), clampf(delta * 1.5, 0.0, 1.0))


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
	Audio.sfx("radio_beep", -12.0, 0.5 if on else 0.8)
	var tw := create_tween()
	tw.tween_property(_tint, "color:a", 0.16 if on else 0.0, 0.3)
	if player.hand:
		player.hand.visible = not on
	_refresh_ui()


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
	_scan_t -= delta
	if _scan_t > 0.0:
		return
	_scan_t = 0.25
	if flying and not cloaked and _alt > 1.2:
		_look_for_witnesses()
	if flying and not landmarks.is_empty():
		_check_landmarks()
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
