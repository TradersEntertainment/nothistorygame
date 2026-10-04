extends Node
## Surdaki canlı mızraklı (Garrison, dış surun yürüyüş yolu): sırayla bakınır, siperden aşağı eğilip bakar,
## mızrakla merdivenlere/tırmananlara dürter (mızrak öne-aşağı döner, ileri geri gider), taş kaldırıp aşağı atar
## (taş hendeğe düşer, toz), sur boyunca bir iki adım yer değiştirir. Ebeveyn bir Person'dır (mızrağı "Spear").

var _t := 0.0
var _dur := 0.0
var _state := "watch"
var _home := Vector3.INF
var _yaw := 0.0
var _jab := 0.0
var _stones: Array = []      # [MeshInstance3D, hız]
var _held: MeshInstance3D    # atılmadan önce baş üstünde tutulan taş


func _ready() -> void:
	_dur = randf_range(0.5, 3.0)


func _process(delta: float) -> void:
	var p := get_parent() as Person
	if p == null or not p.visible or p.rig == null or p.rig.lock > 0:
		_drop_held()
		return
	if _home == Vector3.INF:
		_home = p.position
		_yaw = p.rotation.y
	# Yer değiştirirken yürüme yönüne döner; sonra yine ovaya (dışarı) bakar
	if _state != "shift":
		p.rotation.y = lerp_angle(p.rotation.y, _yaw, clampf(delta * 5.0, 0.0, 1.0))
	_t += delta
	var sp := p.find_child("Spear", true, false) as Node3D
	match _state:
		"watch", "lean", "shift":
			_spear_rest(sp)
		"thrust":
			_jab += delta
			var out := fmod(_jab, 0.5) < 0.22
			p.rig.activity = "thrust_b" if out else "thrust_a"
			_spear_down(p, sp, 0.1 if out else -0.55)
		"throw":
			_spear_rest(sp)
			if p.rig.activity == "throw_up":
				if not is_instance_valid(_held):
					_held = _stone_mesh()
				_held.global_position = p.global_position + Vector3(0, 2.3 * p.scale.y, 0) + _fwd(p) * 0.12
			if _t > 0.6 and p.rig.activity == "throw_up":
				p.rig.activity = "throw_down"
				_drop_stone(p)
	if _t >= _dur:
		_next(p)
	_fly(delta)


func _next(p: Person) -> void:
	_t = 0.0
	var r := randf()
	if _state == "thrust" or _state == "throw" or _state == "lean":
		_state = "watch"
		_dur = randf_range(1.0, 2.5)
		p.rig.activity = ""
		return
	if r < 0.45:
		_state = "thrust"
		_jab = randf()
		_dur = randf_range(1.6, 3.2)
	elif r < 0.62:
		_state = "throw"
		_dur = 1.3
		p.rig.activity = "throw_up"
	elif r < 0.82:
		_state = "lean"
		_dur = randf_range(1.2, 2.4)
		p.rig.activity = "lean_down"
	else:
		# Sur boyunca bir iki adım (yürüme adımı Rig'den; ev konumundan en çok 1 m)
		_state = "shift"
		_dur = 1.0
		p.rig.activity = ""
		var to := _home + Vector3(randf_range(-1.0, 1.0), 0, 0)
		# Kule duvarına ya da mazgal taşına girmesin: yol (ve 0.4 m ötesi) boşsa yürür
		var from := p.global_position + Vector3(0, 1.0, 0)
		var dir := (p.get_parent() as Node3D).global_transform.basis * (to - p.position)
		var q := PhysicsRayQueryParameters3D.create(from, from + dir + dir.normalized() * 0.4) if dir.length() > 0.05 else null
		# Yanındaki nöbetçinin yerine de yürümez (iki mızraklı iç içe giriyordu)
		var to_g := (p.get_parent() as Node3D).global_transform * to
		if q and p.get_world_3d().direct_space_state.intersect_ray(q).is_empty() and not Unclip.crowded(p, to_g, 0.7):
			p.create_tween().tween_property(p, "position", to, 0.9)


func _exit_tree() -> void:
	_drop_held()
	for a: Array in _stones:
		if is_instance_valid(a[0]):
			(a[0] as Node).queue_free()
	_stones.clear()


func _drop_held() -> void:
	if is_instance_valid(_held):
		_held.queue_free()
	_held = null


func _spear_rest(sp: Node3D) -> void:
	if sp and sp.has_meta("rest"):
		sp.transform = sp.get_meta("rest")
		sp.remove_meta("rest")


## Mızrak öne-aşağı (siperin ötesine, merdivenlere): el hizasından ileri; off: dürtüş ileri/geri kayması.
func _spear_down(p: Person, sp: Node3D, off: float) -> void:
	if sp == null:
		return
	if not sp.has_meta("rest"):
		sp.set_meta("rest", sp.transform)
	var b := p.global_basis.orthonormalized() * Basis(Vector3.RIGHT, 2.2)
	var hand := (sp.get_parent() as Node3D).global_transform * Vector3(0, -0.28, 0.06)
	sp.global_transform = Transform3D(b, hand + b.y * off)


func _fwd(p: Person) -> Vector3:
	var fwd := p.global_basis.z
	fwd.y = 0.0
	return fwd.normalized() if fwd.length() > 0.1 else Vector3.BACK


func _stone_mesh() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.16
	sm.height = 0.26
	sm.radial_segments = 6
	sm.rings = 3
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("a89878")
	sm.material = m
	mi.mesh = sm
	get_tree().current_scene.add_child(mi)
	return mi


func _drop_stone(p: Person) -> void:
	var fwd := _fwd(p)
	var mi := _held if is_instance_valid(_held) else _stone_mesh()
	_held = null
	mi.global_position = p.global_position + Vector3(0, 2.0, 0) + fwd * 0.5
	_stones.append([mi, fwd * randf_range(1.5, 3.0) + Vector3(0, 1.0, 0)])


func _fly(delta: float) -> void:
	for k in range(_stones.size() - 1, -1, -1):
		var a: Array = _stones[k]
		var n := a[0] as Node3D
		if not is_instance_valid(n):
			_stones.remove_at(k)
			continue
		var v: Vector3 = a[1]
		v.y -= 9.8 * delta
		a[1] = v
		n.global_position += v * delta
		n.rotate_x(delta * 6.0)
		var gy := Assault.ground_y(n.global_position.x, n.global_position.z)
		if n.global_position.y <= gy + 0.1:
			var cam := get_viewport().get_camera_3d()
			if cam and cam.global_position.distance_to(n.global_position) < 40.0:
				Vfx.dust(get_tree().current_scene, n.global_position, 0.6)
			n.queue_free()
			_stones.remove_at(k)
