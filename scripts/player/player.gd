class_name Player
extends CharacterBody3D
## Birinci şahıs oyuncu (Tolga). Yürür, koşar, zıplar, bakar ve
## E ile önündeki etkileşim alanıyla (katman 2) etkileşir.

signal interacted(id: String)
signal focus_changed(id: String)
## Elde tutulan eşya kullanıldı: target = bakılan etkileşim kimliği ("" = kendine/boşluğa)
signal item_used(target: String, item: String)

const WALK := 3.2
const RUN := 5.2
const JUMP := 3.6
const MOUSE_SENS := 0.0022
const EYE := 1.62

var frozen := false
## "walk": klavyeyle yürüme. "script": yatay hız bölüm betiğinden gelir (koşu, yüzme).
var move_mode := "walk"
var script_velocity := Vector3.ZERO
var gravity_on := true
## Suda: kamera dalgayla hafifçe iner kalkar ve yana yatar.
var floating := false
var _float_t := 0.0
var focus_id := ""
var camera: Camera3D
var _ray: RayCast3D
var _bob := 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _shake := 0.0
var hand: Node3D
var _thumb: Node3D
var _red_light: MeshInstance3D
var _hand_shown := false
var _hand_base := Vector3(0.24, -0.19, -0.4)
var _hand_tween: Tween
var leg: Node3D
## Birinci şahıs el görünümü: "tolga" (redingot) ya da "hikmet" (çizgili pijama).
var hand_style := "tolga"
## Göz yüksekliği ve hız çarpanı (Bölüm 16: tavuk yüksekliğinde kamera)
var eye_height := EYE
var speed_mult := 1.0
## Kendine bakış: fes/kaftan değişince ya da V tuşuyla kısa bir üçüncü şahıs çekimi (yalnızca Tolga)
var outfit_enabled := true
var _outfit_busy := false
var _outfit_pending := false
var _last_fez := -1
var _last_kaftan := -1
var _fez_key_t := 0.0
var scanner_screen: MeshInstance3D
## Elde tutulan: 0 = Telsiz-Kumanda, 1..5 = çantadaki eşya. Bölüm betiği item_handler ile
## bir eşya-karakter eşleşmesini kendisi işleyebilir (true dönerse genel tepki oynamaz).
var held := 0
var item_handler: Callable
var _remote_model: Node3D
var _held_model: Node3D
var _item_busy := false


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.75
	shape.shape = cap
	shape.position.y = 0.875
	add_child(shape)
	collision_mask = 1

	camera = Camera3D.new()
	camera.position.y = eye_height
	camera.fov = float(GameState.settings.get("fov", 72.0))
	camera.near = 0.05
	add_child(camera)
	GameState.settings_changed.connect(func():
		if is_instance_valid(camera):
			camera.fov = float(GameState.settings.get("fov", 72.0)))
	camera.current = true

	_ray = RayCast3D.new()
	_ray.target_position = Vector3(0, 0, -2.4)
	_ray.collision_mask = 2
	_ray.collide_with_areas = false
	camera.add_child(_ray)
	_build_hand()
	_build_leg()


func _process(_delta: float) -> void:
	if hand_style != "tolga" or not outfit_enabled or GameState.autotest or GameState.shots_dir != "":
		return
	var fez := 1 if GameState.flags.get("fez", true) else 0
	var kaftan := 1 if GameState.flags.get("has_kaftan", false) else 0
	# Fes yalnızca oyuncu H'ye bastıysa (kovalamacada düşen fes kamerayı döndürmesin); kaftan her zaman
	if Input.is_action_just_pressed("fez"):
		_fez_key_t = 0.6
	_fez_key_t = maxf(0.0, _fez_key_t - _delta)
	if _last_fez >= 0 and ((fez != _last_fez and _fez_key_t > 0.0) or kaftan > _last_kaftan):
		_outfit_pending = true
	_last_fez = fez
	_last_kaftan = kaftan
	if _outfit_pending and not frozen and not _outfit_busy:
		_outfit_pending = false
		outfit_view()


func _unhandled_input(event: InputEvent) -> void:
	if _item_input(event):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("outfit") and not frozen and hand_style == "tolga" and not _outfit_busy:
		outfit_view(3.2)
		get_viewport().set_input_as_handled()
		return
	if frozen:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var inv := -1.0 if GameState.settings.get("invert_y", false) else 1.0
		rotate_y(-event.relative.x * MOUSE_SENS * float(GameState.settings["mouse"]))
		camera.rotation.x = clampf(camera.rotation.x - inv * event.relative.y * MOUSE_SENS * float(GameState.settings["mouse"]), deg_to_rad(-85), deg_to_rad(85))
	elif event.is_action_pressed("interact") and focus_id != "":
		if focus_id.begins_with("mg:"):
			_start_minigame(focus_id.trim_prefix("mg:"))
		elif focus_id.begins_with("npc:") or focus_id.begins_with("ev:"):
			SideEvents.interact(focus_id, get_tree().get_first_node_in_group("hud") as Hud)
		else:
			interacted.emit(focus_id)
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if gravity_on and not is_on_floor():
		velocity.y -= _gravity * delta
	elif not gravity_on:
		velocity.y = 0.0
	if move_mode == "script" and not frozen:
		velocity.x = script_velocity.x
		velocity.z = script_velocity.z
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP
		move_and_slide()
		_after_move(delta)
		return
	var dir := Vector3.ZERO
	if not frozen:
		var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		dir = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP
	var speed := (RUN if Input.is_action_pressed("sprint") else WALK) * speed_mult
	velocity.x = move_toward(velocity.x, dir.x * speed, speed * delta * 10.0)
	velocity.z = move_toward(velocity.z, dir.z * speed, speed * delta * 10.0)
	move_and_slide()
	_after_move(delta)


## Kol: sağ çubukla bakış (fare hassasiyeti ayarı da uygulanır).
func _pad_look(delta: float) -> void:
	if frozen:
		return
	var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look.length_squared() < 0.0001:
		return
	var sens := 2.6 * float(GameState.settings.get("pad_sens", 1.0)) * delta
	var inv := -1.0 if GameState.settings.get("invert_y", false) else 1.0
	rotate_y(-look.x * sens * 1.2)
	camera.rotation.x = clampf(camera.rotation.x - inv * look.y * sens, deg_to_rad(-85), deg_to_rad(85))


func _after_move(delta: float) -> void:
	_pad_look(delta)
	# Kafa sallanması ve sarsıntı
	var horiz := Vector2(velocity.x, velocity.z).length()
	var step_before := int(_bob * 2.0 / PI)
	_bob += delta * horiz * 2.2
	if int(_bob * 2.0 / PI) != step_before and is_on_floor() and horiz > 0.5:
		Audio.step()
	var y := eye_height + sin(_bob * 2.0) * 0.03 * clampf(horiz / WALK, 0.0, 1.0)
	_shake = maxf(0.0, _shake - delta * 2.5)
	var roll := 0.0
	if floating:
		_float_t += delta
		y += sin(_float_t * 1.7) * 0.07
		roll = sin(_float_t * 1.1) * 0.035
	camera.rotation.z = lerpf(camera.rotation.z, roll, clampf(delta * 4.0, 0.0, 1.0))
	camera.position = Vector3(randf_range(-1, 1) * _shake * 0.05, y + randf_range(-1, 1) * _shake * 0.05, 0)

	_update_focus()
	if hand and hand.visible and _hand_shown and not (_hand_tween and _hand_tween.is_running()):
		var b := sin(_bob * 2.0) * 0.012 * clampf(horiz / WALK, 0.0, 1.0)
		hand.position = hand.position.lerp(_hand_base + Vector3(b * 0.5, b, 0), clampf(delta * 10.0, 0.0, 1.0))


## Koşu bölümü için zıplama (otomatik test de kullanır).
func jump() -> void:
	if is_on_floor():
		velocity.y = JUMP


func _update_focus() -> void:
	var id := ""
	if not frozen and _ray.is_colliding():
		var c := _ray.get_collider()
		if c and c.has_meta("interact_id"):
			id = c.get_meta("interact_id")
	if id != focus_id:
		focus_id = id
		focus_changed.emit(id)
		if id.begins_with("mg:") or id.begins_with("npc:") or id.begins_with("ev:"):
			var hud := get_tree().get_first_node_in_group("hud") as Hud
			if hud:
				hud.set_prompt(tr("UI_PROMPT_MG_" + id.trim_prefix("mg:").to_upper()) if id.begins_with("mg:") else SideEvents.prompt(id))


func horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


## Oyuncuyu bir noktaya bakacak şekilde çevirir (ara sahneler için).
func face(point: Vector3) -> void:
	var to := point - global_position
	rotation.y = atan2(-to.x, -to.z)
	var flat := Vector2(to.x, to.z).length()
	camera.rotation.x = atan2(to.y - eye_height, flat)


# ---------------------------------------------------------------- el ve Telsiz-Kumanda

## Birinci şahıs el: redingot kolu, el ve koli bandıyla birleştirilmiş telsiz + TV kumandası.
func _build_hand() -> void:
	hand = Node3D.new()
	hand.position = _hand_base + Vector3(0, -0.4, 0)
	hand.rotation_degrees = Vector3(12, -14, 0)
	hand.visible = false
	camera.add_child(hand)
	if hand_style == "nihat":
		_build_scanner()
		return
	# Redingot kolu ve beyaz manşet
	var hikmet := hand_style == "hikmet"
	Props.cyl(hand, 0.05, 0.16, Vector3(0.03, -0.07, 0.1), Color("5b7fb3") if hikmet else Color("2b2f38"), Vector3(90, 0, 0), 8)
	Props.cyl(hand, 0.047, 0.03, Vector3(0.03, -0.065, 0.02), Color("a9c1e3") if hikmet else Color("f4f1ea"), Vector3(90, 0, 0), 8)
	if hikmet:
		Props.cyl(hand, 0.051, 0.02, Vector3(0.03, -0.068, 0.12), Color("a9c1e3"), Vector3(90, 0, 0), 8)
	# El
	Props.ball(hand, 0.05, Vector3(0.02, -0.05, -0.02), Color("e0a57e") if hikmet else Color("e6ad88"), Vector3(1.1, 0.8, 1.2), 8)
	_remote_model = Node3D.new()
	hand.add_child(_remote_model)
	# TV kumandası (üstte) ve telsiz (altta)
	Props.box(_remote_model, Vector3(0.05, 0.022, 0.15), Vector3(0, -0.012, -0.07), Color("1f2229"))
	Props.box(_remote_model, Vector3(0.058, 0.035, 0.1), Vector3(0, -0.04, -0.06), Color("7d8794"))
	Props.cyl(_remote_model, 0.005, 0.12, Vector3(0.018, -0.02, -0.12), Color("2b2f3a"), Vector3(-60, 0, 0), 4)
	# Koli bandı
	Props.box(_remote_model, Vector3(0.064, 0.064, 0.022), Vector3(0, -0.026, -0.05), Color("c98a3a"))
	Props.box(_remote_model, Vector3(0.064, 0.064, 0.022), Vector3(0, -0.026, -0.1), Color("c98a3a"), Vector3(0, 0, 4))
	# Tuşlar ve kırmızı düğme
	for i in 3:
		Props.box(_remote_model, Vector3(0.008, 0.004, 0.008), Vector3(-0.012 + i * 0.012, 0.0, -0.035), Color("9aa0a8"))
	_red_light = Props.cyl(_remote_model, 0.011, 0.008, Vector3(0, 0.001, -0.125), Color("ff3b30"), Vector3.ZERO, 8, -1.0, 1.5)
	# Başparmak
	_thumb = Node3D.new()
	_thumb.position = Vector3(-0.028, 0.012, -0.02)
	hand.add_child(_thumb)
	Props.cyl(_thumb, 0.012, 0.07, Vector3(0.012, 0, -0.035), Color("e6ad88"), Vector3(90, -20, 0), 6)
	Props.strip_outlines(hand)


## Nihat'ın eli: gri takım elbise kolu ve Büro'nun pirinç Paradoks Tarayıcısı (yeşil ekran, anten).
func _build_scanner() -> void:
	Props.cyl(hand, 0.05, 0.16, Vector3(0.03, -0.07, 0.1), Color("4a4a52"), Vector3(90, 0, 0), 8)
	Props.cyl(hand, 0.047, 0.03, Vector3(0.03, -0.065, 0.02), Color("f4f1ea"), Vector3(90, 0, 0), 8)
	Props.ball(hand, 0.05, Vector3(0.02, -0.05, -0.02), Color("ecb892"), Vector3(1.1, 0.8, 1.2), 8)
	Props.box(hand, Vector3(0.09, 0.05, 0.13), Vector3(0, -0.02, -0.08), Color("a8864a"))
	Props.box(hand, Vector3(0.094, 0.012, 0.135), Vector3(0, 0.004, -0.08), Color("6a5230"))
	scanner_screen = Props.box(hand, Vector3(0.066, 0.004, 0.06), Vector3(0, 0.012, -0.095), Color("3aff9a"), Vector3.ZERO, 1.2)
	for i in 3:
		Props.cyl(hand, 0.007, 0.006, Vector3(-0.025 + i * 0.025, 0.012, -0.04), Color("d8b070"), Vector3.ZERO, 6)
	Props.cyl(hand, 0.004, 0.14, Vector3(0.035, 0.05, -0.13), Color("2b2f3a"), Vector3(-25, 0, 0), 4)
	Props.ball(hand, 0.01, Vector3(0.035, 0.115, -0.16), Color("ff5a4a"), Vector3.ONE, 5, 1.5)
	Props.label(hand, "Z", Vector3(0, -0.02, -0.0145 - 0.0005), 24, Color("4a3a1e"), Vector3(0, 0, 0), 0.04)
	_thumb = Node3D.new()
	_thumb.position = Vector3(-0.03, 0.012, -0.02)
	hand.add_child(_thumb)
	Props.cyl(_thumb, 0.012, 0.07, Vector3(0.012, 0, -0.035), Color("ecb892"), Vector3(90, -20, 0), 6)
	_red_light = Props.cyl(hand, 0.001, 0.001, Vector3(0, -0.05, 0), Color("000000"))
	Props.strip_outlines(hand)


## Tarayıcı ekranı: 0 (iz yok, sönük) .. 1 (iz çok yakın, parlak ve kırmızıya döner).
func set_scanner(v: float) -> void:
	if scanner_screen == null:
		return
	var c := Color("3aff9a").lerp(Color("ff5a4a"), clampf(v, 0.0, 1.0))
	var pulse := 0.6 + v * 3.0 * (0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * (3.0 + v * 14.0)))
	scanner_screen.material_override = Props.mat(c, pulse, false, "", false)


func show_remote(on: bool) -> void:
	if on == _hand_shown:
		return
	_hand_shown = on
	if on and hand_style == "tolga":
		(func():
			var hud := get_tree().get_first_node_in_group("hud") as Hud
			if hud:
				hud.set_held(held, held_item())).call_deferred()
	hand.visible = true
	hand.position = _hand_base + (Vector3(0, -0.4, 0) if on else Vector3.ZERO)
	var tw := create_tween()
	_hand_tween = tw
	tw.tween_property(hand, "position", _hand_base + (Vector3.ZERO if on else Vector3(0, -0.4, 0)), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if not on:
		tw.tween_callback(func(): hand.visible = false)


## Kırmızı düğmeye basılı tutma (0..1): başparmak iner, düğme parlar, el titrer.
func press_red(v: float) -> void:
	if _thumb == null:
		return
	if v > 0.0 and held != 0:
		select_item(0)
	_thumb.rotation_degrees.x = -lerpf(0.0, 18.0, clampf(v * 4.0, 0.0, 1.0))
	_red_light.material_override = Props.mat(Color("ff3b30"), 1.5 + v * 6.0, false, "", false)
	if v > 0.0:
		hand.position += Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * 0.002 * v


# ---------------------------------------------------------------- tekme

## Birinci şahıs bacak: redingot pantolonu ve rugan ayakkabı. Tekme anında aşağıdan görüşe girer.
func _build_leg() -> void:
	leg = Node3D.new()
	leg.visible = false
	camera.add_child(leg)
	# Kalçadan dizine, dizden ayağa (kalça kameranın altında ve biraz sağında)
	Props.cyl(leg, 0.085, 0.55, Vector3(0, -0.275, 0), Color("454b59"), Vector3.ZERO, 8)
	Props.cyl(leg, 0.078, 0.5, Vector3(0, -0.78, 0), Color("454b59"), Vector3.ZERO, 8)
	Props.cyl(leg, 0.08, 0.06, Vector3(0, -1.02, 0), Color("f1ede2"), Vector3.ZERO, 8)
	Props.box(leg, Vector3(0.15, 0.12, 0.36), Vector3(0, -1.1, -0.1), Color("1d2027"))
	Props.box(leg, Vector3(0.152, 0.035, 0.37), Vector3(0, -1.16, -0.1), Color("7a4f33"))
	Props.box(leg, Vector3(0.1, 0.02, 0.12), Vector3(0, -1.04, -0.2), Color("30343d"))
	Props.strip_outlines(leg)


## Tekme: bacak aşağıdan öne savrulur, oyuncu hedefe doğru atılır. power 0..1:
## güçlü tekmede savrulma daha geniş ve sert. Darbe anında on_hit çağrılır.
func kick(target: Vector3, power: float, on_hit: Callable) -> void:
	var start := global_position
	var to := target - start
	to.y = 0.0
	# Ayak (~1.1 m önde) hedefin yüzeyinde dursun, içine girmesin
	var lunge := start + to.normalized() * maxf(0.0, to.length() - 1.62 + power * 0.06)
	leg.visible = true
	leg.position = Vector3(0.12, -0.3, 0.15)
	leg.rotation_degrees = Vector3(5, 0, 0)
	var swing := lerpf(82.0, 105.0, power)
	var dur := lerpf(0.2, 0.12, power)
	var tw := create_tween()
	tw.tween_property(leg, "rotation_degrees:x", -15.0, 0.14).set_ease(Tween.EASE_OUT)
	tw.tween_property(leg, "rotation_degrees:x", swing, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(leg, "position", Vector3(0.03, -0.2, -0.05), dur)
	tw.parallel().tween_property(self, "global_position", lunge, dur)
	tw.tween_callback(func():
		shake(0.3 + power)
		on_hit.call())
	tw.tween_interval(0.18)
	tw.tween_property(leg, "rotation_degrees:x", 5.0, 0.3).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(leg, "position", Vector3(0.12, -0.3, 0.15), 0.3)
	tw.parallel().tween_property(self, "global_position", start, 0.45).set_trans(Tween.TRANS_QUAD)
	await tw.finished
	leg.visible = false


## Tolga'nın kendine dışarıdan bakışı: yanına bir ikiz koyar, kamera önünde yay çizer, sonra geri döner.
func outfit_view(seconds := 2.6) -> void:
	if _outfit_busy or not is_inside_tree():
		return
	_outfit_busy = true
	var was_frozen := frozen
	frozen = true
	var me := _me_person()
	get_parent().add_child(me)
	me.global_position = global_position
	me.rotation.y = rotation.y + PI
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud:
		hud.set_cinematic(true)
	var cam := Camera3D.new()
	get_parent().add_child(cam)
	cam.fov = 55.0
	cam.make_current()
	var fwd := -global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var center := global_position + Vector3(0, 1.15, 0)
	# Kamera duvarın dışına çıkmasın: en açık yönü seç, mesafeyi ona göre kısalt
	var best := -1.0
	var best_dir := fwd
	for k in 8:
		var d := fwd.rotated(Vector3.UP, k * PI / 4.0)
		var clear := 99.0
		for a in [-0.8, 0.0, 0.8]:
			clear = minf(clear, _clearance(center + Vector3(0, 0.3, 0), d.rotated(Vector3.UP, a), 2.8))
		if clear > best + 0.05:
			best = clear
			best_dir = d
		if k == 0 and clear >= 2.6:
			break
	fwd = best_dir
	var dist := clampf(best - 0.35, 0.9, 2.3)
	var tw := create_tween()
	tw.tween_method(func(a: float):
		var dir := fwd.rotated(Vector3.UP, a)
		cam.global_position = center + dir * dist + Vector3(0, 0.3, 0)
		cam.look_at(center + Vector3(0, 0.2, 0), Vector3.UP), -0.8, 0.8, seconds)
	await tw.finished
	camera.make_current()
	cam.queue_free()
	me.queue_free()
	if hud:
		hud.set_cinematic(false)
	frozen = was_frozen
	_outfit_busy = false


func _clearance(from: Vector3, dir: Vector3, max_d: float) -> float:
	var q := PhysicsRayQueryParameters3D.create(from, from + dir * max_d, 1)
	q.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	return from.distance_to(hit["position"]) if hit else max_d


## Oynanan karakterin üçüncü şahıs modeli (ayna, fotoğraf modu): Nihat, Hikmet ya da Tolga (kıyafet ve fes duruma göre).
func _me_person() -> Person:
	if hand_style == "nihat":
		return Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
			"hair": Color("3a2a1e"), "skin": Color("ecb892")})
	if hand_style == "hikmet":
		return Person.new({"face": {"wrinkles": true, "bags": true, "nose": "bulb", "brow_tilt": -6.0}, "coat": Color("7fa7d6"),
			"pants": Color("7fa7d6"), "glasses": true, "mustache": true, "hair": Color("e8e8e4"), "skin": Color("e0a57e")})
	var f := GameState.flags
	var kaftan: bool = f.get("has_kaftan", false)
	var opts := {"face": "tolga", "coat": Color("7a3a2a") if kaftan else Color("23262d"), "pants": Color("23262d"), "skin": Color("e6ad88"),
		"hat": "fez" if f.get("fez", true) else "none", "hair": Color("2a1e14")}
	if kaftan:
		opts["robe"] = Color("8a3a2a")
	return Person.new(opts)


## Kimlik kartı: Nihat, Zaman Bürosu kartını kameraya doğru uzatır, bir süre tutar, geri çeker.
func show_badge(hold := 2.6) -> void:
	var card := Node3D.new()
	camera.add_child(card)
	card.position = Vector3(0.08, -0.5, -0.42)
	card.rotation_degrees = Vector3(-10, 10, 5)
	Props.box(card, Vector3(0.21, 0.14, 0.012), Vector3.ZERO, Color("4a3020"))
	Props.box(card, Vector3(0.19, 0.12, 0.004), Vector3(0, 0, 0.007), Color("f2ead8"))
	Props.box(card, Vector3(0.19, 0.024, 0.005), Vector3(0, 0.048, 0.008), Color("2a4a8a"))
	# Vesikalık: gri zemin, yüz, fötr
	Props.box(card, Vector3(0.05, 0.06, 0.003), Vector3(-0.062, -0.012, 0.0095), Color("9aa4b4"))
	Props.ball(card, 0.013, Vector3(-0.062, -0.018, 0.011), Color("ecb892"), Vector3(1, 1.1, 0.4), 8)
	Props.box(card, Vector3(0.036, 0.008, 0.003), Vector3(-0.062, -0.002, 0.012), Color("3a3a42"))
	Props.box(card, Vector3(0.022, 0.012, 0.003), Vector3(-0.062, 0.006, 0.012), Color("3a3a42"))
	Props.box(card, Vector3(0.012, 0.003, 0.002), Vector3(-0.062, -0.024, 0.013), Color("3a2a1e"))
	# Altın mühür
	Props.cyl(card, 0.014, 0.003, Vector3(0.078, -0.036, 0.009), Color("d8b040"), Vector3(90, 0, 0), 12)
	for spec in [["ZAMAN BÜROSU", Vector3(0, 0.048, 0.0112), Color("f2ead8"), 0.00045], ["N. ZAMANOĞLU", Vector3(0.025, 0.012, 0.0102), Color("2a2a30"), 0.00038],
			["DENETÇİ · SİCİL 1453", Vector3(0.025, -0.008, 0.0102), Color("5a5a64"), 0.00028]]:
		var l := Props.label(card, spec[0], spec[1], 32, spec[2])
		l.pixel_size = spec[3]
	Props.strip_outlines(card)
	Audio.sfx("paper_tear", -18.0, 1.6)
	var tw := create_tween()
	tw.tween_property(card, "position", Vector3(0.02, -0.04, -0.34), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(card, "rotation_degrees", Vector3(0, -4, 1), 0.35)
	tw.tween_interval(hold)
	tw.tween_property(card, "position", Vector3(0.08, -0.55, -0.42), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(card.queue_free)


## Selfie: Tolga arkasını döner, kamera kol mesafesinde; bakılan kişi Tolga'nın omzunun üstünden görünür.
func selfie_shot(hud: Hud, who: String) -> void:
	if _outfit_busy or not is_inside_tree() or GameState.autotest:
		return
	_outfit_busy = true
	var was_frozen := frozen
	frozen = true
	var fwd := -global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var side := fwd.cross(Vector3.UP).normalized()
	var me := _me_person()
	get_parent().add_child(me)
	me.global_position = global_position
	me.rotation.y = rotation.y
	# Selfie çubuğu: omuzdan kameraya uzanan ince çubuk
	var stick := Props.cyl(me, 0.015, 0.8, Vector3(0.3, 1.35, 0.35), Color("8a8f99"), Vector3(55, 0, 0), 5)
	stick.name = "SelfieStick"
	hud.set_cinematic(true)
	var cam := Camera3D.new()
	get_parent().add_child(cam)
	cam.fov = 62.0
	cam.global_position = global_position - fwd * 1.5 + side * 0.65 + Vector3(0, 1.75, 0)
	cam.look_at(global_position + fwd * 1.4 + side * 0.1 + Vector3(0, 1.4, 0), Vector3.UP)
	me.look_at_from_position(me.global_position, cam.global_position * Vector3(1, 0, 1) + Vector3(0, me.global_position.y, 0), Vector3.UP)
	me.rotate_y(PI)   # Person +Z'ye bakar
	cam.make_current()
	var pose := Person.nearest(get_tree(), global_position + fwd * 1.8 + Vector3(0, 1.0, 0), 3.0, me)
	if pose:
		pose.emote(["wave", "cheer"][randi() % 2])
	await get_tree().create_timer(0.35).timeout
	await hud.snap_photo(who)
	await get_tree().create_timer(0.5).timeout
	camera.make_current()
	cam.queue_free()
	me.queue_free()
	hud.set_cinematic(false)
	frozen = was_frozen
	_outfit_busy = false


# ---------------------------------------------------------------- elde eşya

## Eldeki eşyayı değiştirir: 0 = Telsiz-Kumanda, 1..5 = çanta sırası.
func select_item(i: int) -> void:
	if hand_style != "tolga" or _remote_model == null:
		return
	var n := GameState.bag.size()
	held = clampi(i, 0, n)
	if _held_model:
		_held_model.queue_free()
		_held_model = null
	_remote_model.visible = held == 0
	if held > 0:
		var id: String = GameState.bag[held - 1]
		_held_model = Items.build(id)
		_held_model.scale = Vector3.ONE * (0.32 if id != "selfie" else 0.22)
		_held_model.position = Vector3(0, -0.035, -0.08)
		_held_model.rotation_degrees = Vector3(0, 90 if id == "selfie" else 0, 0)
		hand.add_child(_held_model)
		Props.strip_outlines(_held_model)
	if not _hand_shown:
		show_remote(true)
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud:
		hud.set_held(held, held_item())
	Audio.sfx("ui_select", -14.0)


func held_item() -> String:
	return "" if held <= 0 or held > GameState.bag.size() else String(GameState.bag[held - 1])


func _item_input(event: InputEvent) -> bool:
	if hand_style != "tolga" or frozen or _outfit_busy:
		return false
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud and hud.is_bag_open():
		return false
	var n := GameState.bag.size()
	if event.is_action_pressed("item_next"):
		select_item((held + 1) % (n + 1))
		return true
	if event.is_action_pressed("item_prev"):
		select_item((held + n) % (n + 1))
		return true
	for k in range(1, 6):
		if event.is_action_pressed("choice_%d" % k) and k <= n:
			select_item(k if held != k else 0)
			return true
	if event.is_action_pressed("use_item"):
		_use_held()
		return true
	return false


## Eldekini kullan: bir kişiye bakılıyorsa gösterilir, yoksa eşyanın kendi eylemi.
func _use_held() -> void:
	if _item_busy:
		return
	var item := held_item()
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if item == "":
		if hud:
			hud.bark("SPK_TOLGA", "ITEM_SELF_REMOTE", 2.5)
		return
	_item_busy = true
	var target := focus_id
	item_used.emit(target, item)
	# Karşıdaki karakter tepki verir (şaşırır, güler, omuz silker...)
	if target != "" and item != "selfie" and _ray.is_colliding():
		var who := Person.nearest(get_tree(), _ray.get_collision_point())
		if who:
			who.emote(["surprise", "laugh", "shrug", "nod", "facepalm"][randi() % 5])
	var qr := Quests.progress(target, item)
	if qr != "" and hud:
		if item == "selfie":
			await selfie_shot(hud, Quests.who(target))
		hud.quest_update(item, target, qr == "done")
	var handled := false
	if target != "" and item_handler.is_valid():
		handled = await item_handler.call(target, item)
	if not handled and hud:
		if target != "":
			hud.show_reaction(target, item)
		else:
			await _self_use(item, hud)
	_item_busy = false


## Eşyanın kendi eylemi (boşlukta kullanınca): küçük bir görsel ve Tolga'nın bir cümlesi.
func _self_use(item: String, hud: Hud) -> void:
	var key := "ITEM_SELF_" + item.to_upper()
	match item:
		"selfie":
			hud.bark("SPK_TOLGA", key, 3.0)
			await outfit_view(2.8)
			return
		"lighter":
			var fl := Props.ball(_held_model, 0.05, Vector3(0, 0.24, 0), Color("ffb040"), Vector3(1, 1.8, 1), 6, 3.0)
			fl.material_override = Props.mat(Color("ffb040"), 4.0, false, "", false)
			var l := OmniLight3D.new()
			l.light_color = Color("ffb060")
			l.light_energy = 1.5
			l.omni_range = 3.0
			_held_model.add_child(l)
			get_tree().create_timer(2.5).timeout.connect(func():
				if is_instance_valid(fl):
					fl.queue_free()
				if is_instance_valid(l):
					l.queue_free())
		"thermos", "cologne":
			var st := Vfx.steam(get_parent(), global_position + Vector3(0, eye_height - 0.2, 0) - global_transform.basis.z * 0.5)
			get_tree().create_timer(1.8).timeout.connect(func():
				if is_instance_valid(st):
					st.queue_free())
		"chickpeas":
			Audio.sfx("typewriter", -6.0, 0.6)
		"cube":
			var tw := create_tween()
			tw.tween_property(_held_model, "rotation:y", _held_model.rotation.y + TAU, 0.6)
		"phone":
			_held_model.scale *= 1.15
			get_tree().create_timer(0.4).timeout.connect(func():
				if is_instance_valid(_held_model):
					_held_model.scale /= 1.15)
	# Birkaç farklı cümle: sırayla döner
	var n := 1
	while tr("%s_%d" % [key, n + 1]) != "%s_%d" % [key, n + 1]:
		n += 1
	var idx: int = int(GameState.flags.get("self_use_" + item, 0))
	GameState.flags["self_use_" + item] = idx + 1
	hud.bark("SPK_TOLGA", key if idx % n == 0 else "%s_%d" % [key, idx % n + 1], 3.2)


# ---------------------------------------------------------------- mini oyunlar

## Seviyedeki "mg:<id>" etkileşim noktasından mini oyun: oyuncu donar, oyun biter, sonuç repliği gelir.
func _start_minigame(id: String) -> void:
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud == null or _item_busy or frozen:
		return
	var mg: MiniGame
	match id:
		"cauldron":
			mg = MiniGameCauldron.new()
		"haggle_wine", "haggle_double", "haggle_urban", "haggle_niko":
			var h := MiniGameHaggle.new()
			h.merchant = id.trim_prefix("haggle_")
			mg = h
		"mangala":
			mg = MiniGameMangala.new()
		"archery":
			mg = MiniGameArchery.new()
		_:
			return
	mg.title_font = hud._title_font
	frozen = true
	hud.set_prompt("")
	var mouse := Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.add_child(mg)
	var res: Array = await mg.finished
	mg.queue_free()
	Input.mouse_mode = mouse
	frozen = false
	var score: int = res[0]
	var won: bool = res[1]
	match id:
		"cauldron":
			GameState.bump_stat("cauldron_best", score, true)
			if (mg as MiniGameCauldron).duel:
				if won:
					GameState.bump_stat("kadri_duel_wins")
				hud.bark("SPK_TOLGA", "MG_CAUL_T_DUEL_WIN" if won else "MG_CAUL_T_DUEL_LOSE", 3.5)
		"archery":
			GameState.bump_stat("archery_best", score, true)
			hud.bark("SPK_HASAN", "MG_ARC_H_AFTER_WIN" if won else "MG_ARC_H_AFTER_LOSE", 4.0)
		"haggle_wine", "haggle_double", "haggle_urban", "haggle_niko":
			if won:
				GameState.bump_stat("haggle_wins")
			hud.bark("SPK_TOLGA", "MG_HAG_T_WIN" if won else "MG_HAG_T_LOSE", 3.0)
		"mangala":
			if won:
				GameState.bump_stat("mangala_wins")
