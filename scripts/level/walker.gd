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
var _dodging := false


func _ready() -> void:
	add_to_group("sight_dodgers")
	_rng.seed = seed_value
	speed = _rng.randf_range(0.9, 1.4)
	_wait = _rng.randf_range(0.0, 3.0)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(person):
		queue_free()
		return
	if _wait > 0.0:
		_wait -= delta
		# Beklerken biri tam üstündeyse (aynı noktada başlayan iki yürüyen) hemen yürüyüp ayrılır
		if _wait > 0.3 and Engine.get_physics_frames() % 20 == seed_value % 20:
			for n in get_tree().get_nodes_in_group("persons"):
				var o := n as Node3D
				if o != person and o != null and o.is_visible_in_tree() and o.global_position.distance_to(person.global_position) < 0.5:
					_wait = 0.0
					break
		return
	if not _has:
		_pick()
		return
	var to := _target - person.global_position
	to.y = 0.0
	if to.length() < 0.15:
		_has = false
		_dodging = false
		_wait = _rng.randf_range(1.0, 5.0)
		if _rng.randf() < 0.3 and person.has_method("emote"):
			person.emote(["wave", "shrug", "nod"][_rng.randi() % 3])
		return
	var step := minf(to.length(), speed * (2.2 if _dodging else 1.0) * delta)
	var dir := to.normalized()
	# Yakındaki insanlardan kaçın (birbirinin içinden geçilmesin): 1 m içindekiler yana iter; önü tamamen kapalıysa bekler
	var push := Vector3.ZERO
	var here := person.global_position
	for n in get_tree().get_nodes_in_group("persons"):
		var o := n as Node3D
		if o == person or o == null or not o.is_visible_in_tree():
			continue
		var d := Vector3(here.x - o.global_position.x, 0, here.z - o.global_position.z)
		var dl := d.length()
		if dl < 1.0 and dl > 0.001 and absf(here.y - o.global_position.y) < 1.0:
			push += d / dl * (1.0 - dl) * 1.6
	# Oyuncu da bir engel: içinden geçilmez (biraz daha geniş pay: kamera onun gözünde)
	var by_player := false
	var pl := get_tree().get_first_node_in_group("player") as Node3D
	if pl:
		var d := Vector3(here.x - pl.global_position.x, 0, here.z - pl.global_position.z)
		var dl := d.length()
		if dl < 1.3 and dl > 0.001 and absf(here.y - pl.global_position.y) < 1.2:
			push += d / dl * (1.3 - dl) * 2.2
			by_player = true
	if push != Vector3.ZERO:
		dir = (dir + push).normalized()
		if dir.dot(to.normalized()) < -0.2:
			_wait = 0.4          # tam karşıda biri var: geri geri yürümez, bir an bekler
			if by_player:
				_has = false     # oyuncu yolda duruyor: başka yere yürür (sonsuza dek beklemez)
			return
	if push != Vector3.ZERO and space_owner != null:
		# Kaçınma yön değiştirdiyse duvarın/evin içine itilmesin: önü kapalıysa asıl yöne döner, o da kapalıysa yeni yol seçer
		var sp := space_owner.get_world_3d().direct_space_state
		var q := PhysicsRayQueryParameters3D.create(here + Vector3(0, 0.5, 0), here + Vector3(0, 0.5, 0) + dir * (step + 0.35), 1)
		if not sp.intersect_ray(q).is_empty():
			dir = to.normalized()
			q = PhysicsRayQueryParameters3D.create(here + Vector3(0, 0.5, 0), here + Vector3(0, 0.5, 0) + dir * (step + 0.35), 1)
			if not sp.intersect_ray(q).is_empty():
				_has = false
				_wait = 0.4
				return
	person.global_position += dir * step
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
		# Yol açık mı: diz, bel ve omuz hizasında, ortada ve iki yanda (alçak masa, sandık, tezgâh içinden geçilmesin)
		var side := (c - here).normalized().cross(Vector3.UP) * 0.35
		var blocked := false
		for off in [Vector3.ZERO, side, -side]:
			for hy: float in [0.35, 0.7, 1.2]:
				var q := PhysicsRayQueryParameters3D.create(here + off + Vector3(0, hy, 0), c + off + Vector3(0, hy, 0), 1)
				if not space.intersect_ray(q).is_empty():
					blocked = true
					break
			if blocked:
				break
		if blocked or _crosses_sightline(here, c) or _crosses_person(here, c):
			continue
		_target = c
		_has = true
		return
	_wait = 1.0


## Yol, yerinde duran (yürümeyen) birinin 0.7 m yakınından geçiyor mu (sokakta dikilenin, satıcının içinden geçilmesin).
func _crosses_person(a: Vector3, b: Vector3) -> bool:
	var s := Vector2(a.x, a.z)
	var e := Vector2(b.x, b.z)
	for n in get_tree().get_nodes_in_group("persons"):
		var o := n as Node3D
		if o == person or o == null or not o.is_visible_in_tree():
			continue
		var op := Vector2(o.global_position.x, o.global_position.z)
		if Geometry2D.get_closest_point_to_segment(op, s, e).distance_to(op) < 0.7 and absf(o.global_position.y - a.y) < 1.2:
			return true
	var pl := get_tree().get_first_node_in_group("player") as Node3D
	if pl:
		var pp := Vector2(pl.global_position.x, pl.global_position.z)
		if Geometry2D.get_closest_point_to_segment(pp, s, e).distance_to(pp) < 1.0 and absf(pl.global_position.y - a.y) < 1.2:
			return true
	return false


## Konuşma sürerken (Hud.sightline) yol, oyuncunun gözünden konuşana uzanan çizgiyi kesiyor mu (yerde, 1 m pay).
func _crosses_sightline(a: Vector3, b: Vector3) -> bool:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud == null or (hud.get("sightline") as PackedVector3Array).size() < 2:
		return false
	var sl: PackedVector3Array = hud.get("sightline")
	var p := Vector2(sl[0].x, sl[0].z)
	var q := Vector2(sl[1].x, sl[1].z)
	var s := Vector2(a.x, a.z)
	var e := Vector2(b.x, b.z)
	if Geometry2D.segment_intersects_segment(s, e, p, q) != null:
		return true
	var c := Geometry2D.get_closest_points_between_segments(s, e, p, q)
	return c[0].distance_to(c[1]) < 1.0


## Replik başladı: kişi oyuncuyla konuşanın arasında (ya da oraya yürüyorsa) çizginin dışına yana çekilir.
## Otomatik testte beklemeden yerine konur.
func dodge(eye: Vector3, head: Vector3, speaker: Node3D) -> void:
	if not is_instance_valid(person) or person == speaker:
		return
	var here := person.global_position
	var flat := Vector3(head.x - eye.x, 0, head.z - eye.z)
	if flat.length() < 0.5:
		return
	var dir := flat.normalized()
	var t := clampf((here - eye).dot(dir), 0.0, flat.length())
	var foot := Vector3(eye.x, here.y, eye.z) + dir * t
	var off := Vector3(here.x - foot.x, 0, here.z - foot.z)
	var raw := (here - eye).dot(dir)
	if off.length() > 1.1 or raw <= 0.0 or raw >= flat.length():
		if _has and _crosses_sightline(here, _target):
			_has = false      # yolu çizgiyi kesiyordu: durup başka yol seçer
			_wait = 0.5
		return
	var side := off.normalized() if off.length() > 0.05 else dir.cross(Vector3.UP)
	var to := foot + side * 1.6
	to.y = here.y
	if GameState.autotest:
		person.global_position = to
		_has = false
		_wait = 1.0
		return
	_target = to
	_has = true
	_wait = 0.0
	_dodging = true
