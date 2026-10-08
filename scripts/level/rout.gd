class_name Rout
extends Node3D
## Geri çekilme: askerler surun dibinden ordugâha doğru dağınık koşar, düz sıra hâlinde değil. Her biri kendi hızında
## ve yalpalayarak gider; arada durup sura dönüp bakar, topallayan geride kalır, ikisi bir yaralıyı koltuklar.
## Surdan oklar iner ve kaçanların çevresine saplanır; taşlar sur dibine düşer. Varan, soluklanmak için eğilir.
##   var r := Rout.new(); add_child(r); r.setup(sol_uç, sağ_uç, varış_z, kişi, tohum, zemin)
##   r.wall_top: okların çıktığı sur yolu (iki uç), r.player: oklar oyuncunun çevresine de iner

var wall_top: Array[Vector3] = []
var player: Node3D
var ground: Callable                # (x, z) -> y
var _men: Array[Dictionary] = []
var _flying: Array = []
var _arrow_t := 0.6
var _stone_t := 1.5
var _rng := RandomNumberGenerator.new()
const COATS := [Color("b3262d"), Color("6a4a3a"), Color("2f5fa8"), Color("8a6a4a"), Color("3a6b3a"), Color("a08050")]
const HATS := ["azap", "bork", "turban", "azap", "bork", "turban"]


## avoid: varış yerlerinin uzak durması gereken noktalar (ayakta duran karakterler)
func setup(a: Vector3, b: Vector3, to_z: float, n: int, seed := 0, p_ground := Callable(), avoid: Array = []) -> void:
	_rng.seed = seed
	ground = p_ground
	var ends: Array = avoid.duplicate()
	for i in n:
		var p := Soldier.new(COATS[(i + seed) % COATS.size()], "stand", HATS[(i * 5 + seed) % HATS.size()])
		p.set_meta("no_talk", true)
		p.set_meta("climber", true)
		add_child(p)
		if i % 4 == 1:
			p.equip("spear")
		var u := (float(i) + _rng.randf_range(0.1, 0.9)) / float(n)
		var start := a.lerp(b, u) + Vector3(0, 0, _rng.randf_range(0.0, 3.0))
		p.global_position = _on_ground(start)
		var end := Vector3(start.x + _rng.randf_range(-6.0, 6.0), 0, to_z + _rng.randf_range(0.0, 10.0))
		for _k in 12:
			var clash := false
			for e: Vector3 in ends:
				if Vector2(e.x - end.x, e.z - end.z).length() < 1.4:
					clash = true
			if not clash:
				break
			end.x += 1.5
		ends.append(end)
		var limp := i % 5 == 3
		_men.append({"p": p, "from": start, "to": end, "u": -_rng.randf_range(0.0, 0.9),
			"speed": _rng.randf_range(1.2, 1.6) if limp else _rng.randf_range(3.2, 4.4),
			"wob": _rng.randf_range(0.6, 1.6), "ph": _rng.randf() * TAU, "look_at": _rng.randf_range(0.3, 0.6) if i % 3 == 0 else 2.0,
			"look_t": 0.0, "done": false})
	# İkisi bir yaralıyı koltuklar: yaralı ortada, kolları omuzlarında (yavaş)
	if n >= 6:
		var m0: Dictionary = _men[0]
		var m1: Dictionary = _men[1]
		m1["from"] = (m0["from"] as Vector3) + Vector3(1.0, 0, 0)
		(m1["p"] as Node3D).global_position = _on_ground(m1["from"])
		m1["to"] = (m0["to"] as Vector3) + Vector3(1.0, 0, 0)
		m0["speed"] = 1.5
		m1["speed"] = 1.5
		m0["wob"] = 0.2
		m1["wob"] = 0.2
		m0["u"] = 0.0
		m1["u"] = 0.0
		m0["look_at"] = 2.0
		m1["look_at"] = 2.0
		var hurt := Soldier.new(Color("b3262d"), "stand", "azap")
		hurt.set_meta("no_talk", true)
		hurt.set_meta("climber", true)
		add_child(hurt)
		hurt.global_position = ((m0["p"] as Node3D).global_position + (m1["p"] as Node3D).global_position) * 0.5 + Vector3(0, 0, -0.35)
		_men.append({"p": hurt, "pair": [m0["p"], m1["p"]], "done": false})


func _on_ground(p: Vector3) -> Vector3:
	return Vector3(p.x, ground.call(p.x, p.z) if ground.is_valid() else p.y, p.z)


func _process(delta: float) -> void:
	_fly(delta)
	for m in _men:
		var p := m["p"] as Soldier
		if not is_instance_valid(p) or bool(m["done"]):
			continue
		if m.has("pair"):
			# Koltuklanan yaralı: iki arkadaşının arasında, biraz geride; ayakları sürünür
			var a := m["pair"][0] as Node3D
			var b := m["pair"][1] as Node3D
			if not is_instance_valid(a) or not is_instance_valid(b):
				continue
			var mid := (a.global_position + b.global_position) * 0.5
			p.global_position = mid + Vector3(0, 0.0, -0.35)
			p.global_rotation = a.global_rotation
			if p.rig:
				p.rig.activity = "lean_down"
			continue
		var u := float(m["u"])
		if u < 0.0:
			m["u"] = u + delta          # biraz sonra kalkar (hep birlikte değil)
			continue
		var from: Vector3 = m["from"]
		var to: Vector3 = m["to"]
		var length := maxf(Vector2(to.x - from.x, to.z - from.z).length(), 1.0)
		# Dönüp bakma: yolun bir yerinde durur, sura döner, sonra koşmaya devam eder
		var la := float(m["look_at"])
		if u >= la and float(m["look_t"]) < 0.9:
			m["look_t"] = float(m["look_t"]) + delta
			p.face_toward(Vector3(p.global_position.x, p.global_position.y, from.z - 20.0))
			if p.rig:
				p.rig.activity = ""
			continue
		u = minf(u + float(m["speed"]) * delta / length, 1.0)
		m["u"] = u
		var side := Vector3(to.z - from.z, 0, -(to.x - from.x)).normalized()
		var wob := sin(u * length * 0.35 + float(m["ph"])) * float(m["wob"]) * clampf(minf(u, 1.0 - u) * 5.0, 0.0, 1.0)
		var q := _on_ground(from.lerp(to, u) + side * wob)
		var prev := p.global_position
		p.global_position = q
		var mv := q - prev
		if Vector2(mv.x, mv.z).length() > 0.001:
			p.global_rotation = Vector3(0, atan2(mv.x, mv.z), 0)
		if p.rig:
			var running := float(m["speed"]) > 2.5
			p.rig.activity = ("run_a" if fmod(u * length * 0.9, 1.0) < 0.5 else "run_b") if running else ""
		if u >= 1.0:
			m["done"] = true
			if p.rig:
				p.rig.activity = "lean_down"       # soluklanır
	_arrows(delta)


## Surdan oklar (kaçanların ve oyuncunun çevresine) ve sur dibine düşen taşlar
func _arrows(delta: float) -> void:
	if wall_top.size() < 2:
		return
	_arrow_t -= delta
	if _arrow_t <= 0.0:
		_arrow_t = _rng.randf_range(0.25, 0.6)
		var from := wall_top[0].lerp(wall_top[1], _rng.randf()) + Vector3(0, 1.4, 0)
		var near: Vector3
		if player and _rng.randf() < 0.35:
			near = player.global_position
		else:
			var live := _men.filter(func(m): return not m.has("pair") and is_instance_valid(m["p"]))
			near = (live[_rng.randi() % live.size()]["p"] as Node3D).global_position if not live.is_empty() else from + Vector3(0, -10, 12)
		var to := _on_ground(near + Vector3(_rng.randf_range(-2.5, 2.5), 0, _rng.randf_range(-2.5, 2.5)))
		_shoot(from, to, false)
	_stone_t -= delta
	if _stone_t <= 0.0:
		_stone_t = _rng.randf_range(1.2, 2.4)
		var top := wall_top[0].lerp(wall_top[1], _rng.randf()) + Vector3(0, 1.0, 2.6)
		_shoot(top, _on_ground(top + Vector3(_rng.randf_range(-1.0, 1.0), 0, _rng.randf_range(1.5, 4.5))), true)


func _shoot(from: Vector3, to: Vector3, stone: bool) -> void:
	if _flying.size() >= 30:
		return
	var t := clampf(from.distance_to(to) / (12.0 if stone else 24.0), 0.5, 1.8)
	var v := (to - from) / t
	v.y = (to.y - from.y + 0.5 * 9.8 * t * t) / t
	var mi: Node3D
	if stone:
		mi = Props.ball(self, _rng.randf_range(0.14, 0.24), Vector3.ZERO, Color("8a8278"), Vector3(1.0, 0.8, 0.9), 6)
	else:
		var m := MeshInstance3D.new()
		m.mesh = Assault.arrow_mesh()
		m.material_override = Crowd.material()
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(m)
		mi = m
	mi.global_position = from
	_flying.append([mi, v, t, 9.0, stone])


func _fly(delta: float) -> void:
	for k in range(_flying.size() - 1, -1, -1):
		var a: Array = _flying[k]
		var n := a[0] as Node3D
		a[3] = float(a[3]) - delta
		if not is_instance_valid(n) or float(a[3]) <= 0.0:
			if is_instance_valid(n):
				n.queue_free()
			_flying.remove_at(k)
			continue
		var v: Vector3 = a[1]
		if v == Vector3.ZERO:
			continue
		a[2] = float(a[2]) - delta
		v.y -= 9.8 * delta
		a[1] = v
		n.global_position += v * delta
		if not bool(a[4]):
			n.look_at(n.global_position + v, Vector3.UP if absf(v.normalized().y) < 0.98 else Vector3.RIGHT)
			n.rotate_object_local(Vector3.UP, PI)
		if float(a[2]) <= 0.0:
			a[1] = Vector3.ZERO           # saplandı / düştü
			if bool(a[4]):
				Vfx.dust(self, n.global_position, 0.3)
				var cam := get_viewport().get_camera_3d()
				if cam and cam.global_position.distance_to(n.global_position) < 16.0:
					Audio.sfx("land_thud", -14.0, _rng.randf_range(1.1, 1.4))
