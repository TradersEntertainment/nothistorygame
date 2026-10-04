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
## Tek hedef (Walker.go): sahne betiğinin yürüttüğü kişi. Varınca "arrived" yayar ve kendini siler.
signal arrived
var _goal := Vector3.INF
var _goal_t := 0.0


func _ready() -> void:
	add_to_group("sight_dodgers")
	_rng.seed = seed_value
	if _goal != Vector3.INF:
		return
	speed = _rng.randf_range(0.9, 1.4)
	_wait = _rng.randf_range(0.0, 3.0)


## Bir kişiyi tek bir hedefe yürütür (sahne betiklerindeki düz tween'in yerine): yakındakilerin içinden geçmez (yana
## kayar, karşıdakini bekler), konuşmanın görüş çizgisinden çekilir, varınca "arrived" yayar ve kendini siler. Yol
## kapalı kalırsa ya da çok uzarsa (mesafe/hız × 2 + 6 sn) olduğu yerde varmış sayılır: bekleyen betik takılmaz.
static func go(p: Person, dst: Vector3, spd := 1.3) -> Walker:
	var w := Walker.new()
	w.person = p
	w.space_owner = p
	w._goal = dst
	w._target = dst
	w._has = true
	w.speed = spd
	w._goal_t = p.global_position.distance_to(dst) / maxf(spd, 0.1) * 2.0 + 6.0
	w.seed_value = p.get_instance_id() % 1000
	p.get_parent().add_child(w)
	return w


func _arrive() -> void:
	arrived.emit()
	queue_free()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(person):
		queue_free()
		return
	if _goal != Vector3.INF:
		_goal_t -= delta
		if _goal_t <= 0.0:
			_arrive()
			return
		if not _has and _wait <= 0.0:
			_target = _goal       # yana çekildikten / bekledikten sonra asıl hedefe döner
			_has = true
	if _wait > 0.0:
		_wait -= delta
		# Beklerken üstüne biri gelirse (sahnede yürütülen kafile, karşıdan gelen yürüyen) yana çekilir: içinden geçilmesin
		var yp := Unclip.push(person, person.global_position, 0.65)
		yp.y = 0.0
		if yp.length() > 0.01:
			_sidestep(yp.normalized(), minf(yp.length(), 1.0) * 1.8 * delta)
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
	# Hedefte biri duruyorsa (sonradan gelip dikilen) oraya gidilmez: yeni yol (tek hedefte: burada durur)
	if to.length() < 1.2 and to.length() > 0.15 and Engine.get_physics_frames() % 10 == seed_value % 10 \
			and Unclip.crowded(person, Vector3(_target.x, person.global_position.y, _target.z), 0.55):
		if _goal != Vector3.INF and _target == _goal:
			_arrive()
			return
		_has = false
		_wait = 0.3
		return
	if to.length() < 0.15:
		if _goal != Vector3.INF and _target == _goal:
			person.global_position = Vector3(_goal.x, person.global_position.y, _goal.z)
			_arrive()
			return
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
	if _goal != Vector3.INF and space_owner != null:
		# Tek hedefe yürüyen (yolu önceden denetlenmemiş): sütun, sandık, kürsü önüne çıkarsa yanından dolanır
		var od := _open_dir(here, dir, step)
		if od == Vector3.ZERO:
			_wait = 0.4
			return
		dir = od
	elif push != Vector3.ZERO and space_owner != null:
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
	# Son denetim: adım ayakta birinin içine (0,4 m) bitiyorsa atılmaz, bir an beklenir (beklerken itilen yana çekilir).
	# Yumuşak kaçınma büyük adımlarda (test hızı, takılan kare) yetmiyordu: 31o'da camiye akan cemaat iç içe yürüyordu.
	var np := here + dir * step
	for n in get_tree().get_nodes_in_group("persons"):
		var o := n as Node3D
		if o == person or o == null or not o.is_visible_in_tree() or Unclip.lying(o) or absf(o.global_position.y - np.y) > 0.9:
			continue
		var dn := Vector2(np.x - o.global_position.x, np.z - o.global_position.z).length()
		if dn < 0.4 and dn < Vector2(here.x - o.global_position.x, here.z - o.global_position.z).length():
			_wait = 0.25
			return
	person.global_position += dir * step
	person.global_position.y = lerpf(person.global_position.y, _target.y, clampf(delta * 4.0, 0.0, 1.0))
	person.rotation.y = lerp_angle(person.rotation.y, atan2(to.x, to.z), clampf(delta * 6.0, 0.0, 1.0))


## Önü (diz, bel, omuz hizasında; gövde genişliğinde) açık bir yön: önce istenen, sonra ±40°, ±80° döndürülmüş. Yoksa sıfır.
func _open_dir(here: Vector3, dir: Vector3, step: float) -> Vector3:
	var sp := space_owner.get_world_3d().direct_space_state
	var ex: Array[RID] = []
	var pl := get_tree().get_first_node_in_group("player")
	if pl is CollisionObject3D:
		ex.append((pl as CollisionObject3D).get_rid())
	for a: float in [0.0, 0.7, -0.7, 1.4, -1.4]:
		var d := dir.rotated(Vector3.UP, a)
		var side := d.cross(Vector3.UP) * 0.2
		var open := true
		for off: Vector3 in [Vector3.ZERO, side, -side]:
			for hy: float in [0.4, 0.9, 1.4]:
				var o := here + off + Vector3(0, hy, 0)
				var q := PhysicsRayQueryParameters3D.create(o, o + d * (step + 0.3), 1, ex)
				if not sp.intersect_ray(q).is_empty():
					open = false
					break
			if not open:
				break
		if open:
			return d
	return Vector3.ZERO


## Bekleyen yürüyenin yana çekilmesi: önü (diz ve bel hizasında) açıksa adım kadar kayar.
func _sidestep(dir: Vector3, step: float) -> void:
	if space_owner == null or step <= 0.0:
		return
	var here := person.global_position
	var sp := space_owner.get_world_3d().direct_space_state
	for hy: float in [0.4, 1.0]:
		var q := PhysicsRayQueryParameters3D.create(here + Vector3(0, hy, 0), here + Vector3(0, hy, 0) + dir * (step + 0.3), 1)
		if not sp.intersect_ray(q).is_empty():
			return
	person.global_position += dir * step


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
