class_name Player
extends CharacterBody3D
## Birinci şahıs oyuncu (Tolga). Yürür, koşar, zıplar, bakar ve
## E ile önündeki etkileşim alanıyla (katman 2) etkileşir.

signal interacted(id: String)
signal focus_changed(id: String)

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
	camera.position.y = EYE
	camera.fov = 72.0
	camera.near = 0.05
	add_child(camera)
	camera.current = true

	_ray = RayCast3D.new()
	_ray.target_position = Vector3(0, 0, -2.4)
	_ray.collision_mask = 2
	_ray.collide_with_areas = false
	camera.add_child(_ray)
	_build_hand()
	_build_leg()


func _unhandled_input(event: InputEvent) -> void:
	if frozen:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * MOUSE_SENS, deg_to_rad(-85), deg_to_rad(85))
	elif event.is_action_pressed("interact") and focus_id != "":
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
	var speed := RUN if Input.is_action_pressed("sprint") else WALK
	velocity.x = move_toward(velocity.x, dir.x * speed, speed * delta * 10.0)
	velocity.z = move_toward(velocity.z, dir.z * speed, speed * delta * 10.0)
	move_and_slide()
	_after_move(delta)


func _after_move(delta: float) -> void:
	# Kafa sallanması ve sarsıntı
	var horiz := Vector2(velocity.x, velocity.z).length()
	_bob += delta * horiz * 2.2
	var y := EYE + sin(_bob * 2.0) * 0.03 * clampf(horiz / WALK, 0.0, 1.0)
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


func horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


## Oyuncuyu bir noktaya bakacak şekilde çevirir (ara sahneler için).
func face(point: Vector3) -> void:
	var to := point - global_position
	rotation.y = atan2(-to.x, -to.z)
	var flat := Vector2(to.x, to.z).length()
	camera.rotation.x = atan2(to.y - EYE, flat)


# ---------------------------------------------------------------- el ve Telsiz-Kumanda

## Birinci şahıs el: redingot kolu, el ve koli bandıyla birleştirilmiş telsiz + TV kumandası.
func _build_hand() -> void:
	hand = Node3D.new()
	hand.position = _hand_base + Vector3(0, -0.4, 0)
	hand.rotation_degrees = Vector3(12, -14, 0)
	hand.visible = false
	camera.add_child(hand)
	# Redingot kolu ve beyaz manşet
	var hikmet := hand_style == "hikmet"
	Props.cyl(hand, 0.05, 0.16, Vector3(0.03, -0.07, 0.1), Color("5b7fb3") if hikmet else Color("2b2f38"), Vector3(90, 0, 0), 8)
	Props.cyl(hand, 0.047, 0.03, Vector3(0.03, -0.065, 0.02), Color("a9c1e3") if hikmet else Color("f4f1ea"), Vector3(90, 0, 0), 8)
	if hikmet:
		Props.cyl(hand, 0.051, 0.02, Vector3(0.03, -0.068, 0.12), Color("a9c1e3"), Vector3(90, 0, 0), 8)
	# El
	Props.ball(hand, 0.05, Vector3(0.02, -0.05, -0.02), Color("e0a57e") if hikmet else Color("e6ad88"), Vector3(1.1, 0.8, 1.2), 8)
	# TV kumandası (üstte) ve telsiz (altta)
	Props.box(hand, Vector3(0.05, 0.022, 0.15), Vector3(0, -0.012, -0.07), Color("1f2229"))
	Props.box(hand, Vector3(0.058, 0.035, 0.1), Vector3(0, -0.04, -0.06), Color("7d8794"))
	Props.cyl(hand, 0.005, 0.12, Vector3(0.018, -0.02, -0.12), Color("2b2f3a"), Vector3(-60, 0, 0), 4)
	# Koli bandı
	Props.box(hand, Vector3(0.064, 0.064, 0.022), Vector3(0, -0.026, -0.05), Color("c98a3a"))
	Props.box(hand, Vector3(0.064, 0.064, 0.022), Vector3(0, -0.026, -0.1), Color("c98a3a"), Vector3(0, 0, 4))
	# Tuşlar ve kırmızı düğme
	for i in 3:
		Props.box(hand, Vector3(0.008, 0.004, 0.008), Vector3(-0.012 + i * 0.012, 0.0, -0.035), Color("9aa0a8"))
	_red_light = Props.cyl(hand, 0.011, 0.008, Vector3(0, 0.001, -0.125), Color("ff3b30"), Vector3.ZERO, 8, -1.0, 1.5)
	# Başparmak
	_thumb = Node3D.new()
	_thumb.position = Vector3(-0.028, 0.012, -0.02)
	hand.add_child(_thumb)
	Props.cyl(_thumb, 0.012, 0.07, Vector3(0.012, 0, -0.035), Color("e6ad88"), Vector3(90, -20, 0), 6)
	Props.strip_outlines(hand)


func show_remote(on: bool) -> void:
	if on == _hand_shown:
		return
	_hand_shown = on
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
