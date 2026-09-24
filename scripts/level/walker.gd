class_name Walker
extends Node
## Yürüyen halk: bir Person'u yürüyüş noktaları arasında gezdirir. Bir sonraki nokta, aradaki çizgi
## açık olan (ışın bir şeye çarpmayan) ve 3-14 m uzaktaki noktalardan rastgele seçilir; varınca 1-5 sn durur,
## bazen etrafına bakar. Person'un Rig'i hızdan yürüme animasyonunu kendisi çıkarır.

var person: Person
var nodes: Array[Vector3] = []
var seed_value := 1
var space_owner: Node3D
var speed := 1.1
var _rng := RandomNumberGenerator.new()
var _target := Vector3.ZERO
var _wait := 0.0
var _has := false


func _ready() -> void:
	_rng.seed = seed_value
	speed = _rng.randf_range(0.9, 1.4)
	_wait = _rng.randf_range(0.0, 3.0)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(person):
		queue_free()
		return
	if _wait > 0.0:
		_wait -= delta
		return
	if not _has:
		_pick()
		return
	var to := _target - person.global_position
	to.y = 0.0
	if to.length() < 0.15:
		_has = false
		_wait = _rng.randf_range(1.0, 5.0)
		if _rng.randf() < 0.3 and person.has_method("emote"):
			person.emote(["wave", "shrug", "nod"][_rng.randi() % 3])
		return
	var step := minf(to.length(), speed * delta)
	person.global_position += to.normalized() * step
	person.global_position.y = lerpf(person.global_position.y, _target.y, clampf(delta * 4.0, 0.0, 1.0))
	person.rotation.y = lerp_angle(person.rotation.y, atan2(to.x, to.z), clampf(delta * 6.0, 0.0, 1.0))


func _pick() -> void:
	if nodes.is_empty() or space_owner == null:
		return
	var space := space_owner.get_world_3d().direct_space_state
	var here := person.global_position
	for tries in 12:
		var c: Vector3 = nodes[_rng.randi() % nodes.size()]
		var d := c.distance_to(here)
		if d < 3.0 or d > 14.0:
			continue
		var q := PhysicsRayQueryParameters3D.create(here + Vector3(0, 0.7, 0), c + Vector3(0, 0.7, 0), 1)
		if not space.intersect_ray(q).is_empty():
			continue
		# Yan tarafları da açık olsun (dar geçitte duvara sürtünmesin)
		var side := (c - here).normalized().cross(Vector3.UP) * 0.35
		q = PhysicsRayQueryParameters3D.create(here + side + Vector3(0, 0.7, 0), c + side + Vector3(0, 0.7, 0), 1)
		if not space.intersect_ray(q).is_empty():
			continue
		_target = c
		_has = true
		return
	_wait = 1.0
