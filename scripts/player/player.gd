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
var focus_id := ""
var camera: Camera3D
var _ray: RayCast3D
var _bob := 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _shake := 0.0


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
	if not is_on_floor():
		velocity.y -= _gravity * delta
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

	# Kafa sallanması ve sarsıntı
	var horiz := Vector2(velocity.x, velocity.z).length()
	_bob += delta * horiz * 2.2
	var y := EYE + sin(_bob * 2.0) * 0.03 * clampf(horiz / WALK, 0.0, 1.0)
	_shake = maxf(0.0, _shake - delta * 2.5)
	camera.position = Vector3(randf_range(-1, 1) * _shake * 0.05, y + randf_range(-1, 1) * _shake * 0.05, 0)

	_update_focus()


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
