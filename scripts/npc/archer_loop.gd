extends Node
## Surdaki canlı okçu (Garrison): birkaç saniyede bir yayı gerer (Rig "aim"), bir an nişan alır, oku ovaya bırakır
## (yay çizip hendeğin ötesine düşer, saplanır), sonra yayı indirip bekler. Ebeveyn bir Person'dır (yayı "Bow").

var _t := 0.0
var _next := 0.0
var _state := "rest"
var _arrows: Array = []     # [MeshInstance3D, hız, kalan süre, yer yüksekliği]
## Okun düştüğü uzaklık (m, önüne). İç surdakiler (Garrison) dış surun üstünden ovaya atar: daha uzak.
var reach := Vector2(16.0, 32.0)


func _ready() -> void:
	_next = randf_range(1.0, 4.0)


func _process(delta: float) -> void:
	var p := get_parent() as Person
	if p == null or not p.visible or p.rig == null:
		return
	_t += delta
	var bow := p.find_child("Bow", true, false) as Node3D
	match _state:
		"rest":
			if bow:
				bow.rotation.x = lerpf(bow.rotation.x, 0.0, clampf(delta * 6.0, 0.0, 1.0))
			if _t >= _next:
				_t = 0.0
				_state = "draw"
				p.rig.activity = "aim"
		"draw":
			if bow:
				bow.rotation.x = lerpf(bow.rotation.x, 1.45, clampf(delta * 6.0, 0.0, 1.0))
			if _t >= randf_range(1.1, 1.6):
				_t = 0.0
				_state = "rest"
				_next = randf_range(2.5, 5.5)
				_loose(p)
				p.rig.activity = ""
	_fly(delta)


## Ok: nişan yönüne (okçunun önü, ovaya), 1.3–1.9 sn uçuş, hendek ve ötesindeki yere düşer.
func _loose(p: Person) -> void:
	var fwd := p.global_basis.z
	fwd.y = 0.0
	fwd = fwd.normalized() if fwd.length() > 0.1 else Vector3.BACK
	var from := p.global_position + Vector3(0, 1.45, 0) + fwd * 0.5
	var to := p.global_position + fwd * randf_range(reach.x, reach.y) + p.global_basis.x * randf_range(-5.0, 5.0)
	to.y = Assault.ground_y(to.x, to.z)
	var t := randf_range(1.5, 2.1) if reach.x > 24.0 else randf_range(1.3, 1.9)
	var v := (to - from) / t
	v.y = (to.y - from.y + 0.5 * 9.8 * t * t) / t
	var mi := MeshInstance3D.new()
	mi.mesh = Assault.arrow_mesh()
	mi.material_override = Crowd.material()
	get_tree().current_scene.add_child(mi)
	mi.global_position = from
	_arrows.append([mi, v, 18.0 + t, to.y])
	var cam := get_viewport().get_camera_3d()
	if cam and cam.global_position.distance_to(from) < 14.0:
		Audio.sfx("whoosh_fly", -16.0, randf_range(1.2, 1.5))


func _fly(delta: float) -> void:
	for k in range(_arrows.size() - 1, -1, -1):
		var a: Array = _arrows[k]
		var n := a[0] as Node3D
		a[2] = float(a[2]) - delta
		if not is_instance_valid(n) or float(a[2]) <= 0.0:
			if is_instance_valid(n):
				n.queue_free()
			_arrows.remove_at(k)
			continue
		var v: Vector3 = a[1]
		if v == Vector3.ZERO:
			continue       # saplanmış: süresi dolunca kalkar
		v.y -= 9.8 * delta
		a[1] = v
		n.global_position += v * delta
		n.look_at(n.global_position + v, Vector3.UP if absf(v.normalized().y) < 0.98 else Vector3.RIGHT)
		n.rotate_object_local(Vector3.UP, PI)
		if n.global_position.y <= float(a[3]):
			n.global_position.y = float(a[3])
			n.global_position -= v.normalized() * 0.18
			a[1] = Vector3.ZERO
			a[2] = minf(float(a[2]), 12.0)
