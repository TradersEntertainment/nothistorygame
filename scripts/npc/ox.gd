class_name Ox
extends Node3D
## Öküz: low-poly gövde, kambur, baş ve boynuzlar, dört bacak (yürürken çapraz adım), kuyruk, boyunda çan.
## +Z'ye bakar. Hızı kendi konum değişiminden çıkar (dışarıdan taşınsa da yürür). bellow(): baş kalkar.
## lie(true): bacaklar katlanır, gövde yere iner (gece konağı).

var coat := Color("8a5a36")
var _legs: Array[Node3D] = []
var _head: Node3D
var _tail: Node3D
var _body: Node3D
var _last := Vector3.INF
var _phase := 0.0
var _t := 0.0
var _bellow := 0.0
var lying := false
var lean := 0.0          # yokuş aşağı geriye yaslanma (−1..1)
var name_key := ""


func _init(p_coat := Color("8a5a36")) -> void:
	coat = p_coat


func _ready() -> void:
	_body = Node3D.new()
	add_child(_body)
	var dark := coat.darkened(0.25)
	# Gövde (fıçı), sağrı, kambur
	Props.cyl(_body, 0.5, 1.9, Vector3(0, 1.15, 0), coat, Vector3(90, 0, 0), 10)
	Props.ball(_body, 0.52, Vector3(0, 1.17, -0.85), coat, Vector3(1.0, 1.0, 0.8), 10)
	Props.ball(_body, 0.55, Vector3(0, 1.25, 0.8), coat, Vector3(1.0, 1.08, 0.8), 10)
	Props.ball(_body, 0.32, Vector3(0, 1.62, 0.75), coat.darkened(0.08), Vector3(1.0, 0.7, 1.2), 8)
	# Gerdan (sarkık deri)
	Props.box(_body, Vector3(0.18, 0.5, 0.5), Vector3(0, 0.8, 1.05), coat.darkened(0.1))
	# Baş: boyunla birlikte döner
	_head = Node3D.new()
	_head.position = Vector3(0, 1.35, 1.2)
	_body.add_child(_head)
	Props.box(_head, Vector3(0.42, 0.42, 0.62), Vector3(0, 0.0, 0.32), coat)
	Props.box(_head, Vector3(0.34, 0.3, 0.22), Vector3(0, -0.1, 0.68), Color("d9b08a"))
	for sx: float in [-1.0, 1.0]:
		var horn := Props.cyl(_head, 0.045, 0.5, Vector3(sx * 0.3, 0.22, 0.12), Color("efe6cf"), Vector3(0, 0, sx * -70), 5, 0.015)
		horn.rotation_degrees = Vector3(-20, 0, sx * -70)
		Props.box(_head, Vector3(0.18, 0.08, 0.1), Vector3(sx * 0.27, 0.08, 0.2), dark)
		Props.ball(_head, 0.03, Vector3(sx * 0.17, 0.08, 0.6), Color("1a1410"), Vector3.ONE, 5)
	# Çan
	Props.cyl(_body, 0.09, 0.16, Vector3(0, 0.62, 1.12), Color("b8902a"), Vector3.ZERO, 8, 0.05)
	# Bacaklar: omuz/kalça ekleminden sallanır
	for p: Vector3 in [Vector3(-0.3, 0.9, 0.7), Vector3(0.3, 0.9, 0.7), Vector3(-0.3, 0.9, -0.75), Vector3(0.3, 0.9, -0.75)]:
		var leg := Node3D.new()
		leg.position = p
		_body.add_child(leg)
		Props.box(leg, Vector3(0.2, 0.86, 0.22), Vector3(0, -0.43, 0), coat.darkened(0.12))
		Props.box(leg, Vector3(0.21, 0.1, 0.24), Vector3(0, -0.87, 0.02), Color("2a2420"))
		_legs.append(leg)
	# Gövde katı: oyuncu öküzün içinden geçmesin (öküz yürüdükçe gövde de taşınır)
	var col := AnimatableBody3D.new()
	col.name = "OxBody"
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.0, 1.1, 2.5)
	cs.shape = bs
	cs.position = Vector3(0, 1.1, 0.05)
	col.add_child(cs)
	add_child(col)
	_tail = Node3D.new()
	_tail.position = Vector3(0, 1.45, -1.25)
	_body.add_child(_tail)
	Props.cyl(_tail, 0.03, 0.8, Vector3(0, -0.4, -0.05), dark, Vector3.ZERO, 5)
	Props.ball(_tail, 0.08, Vector3(0, -0.82, -0.05), Color("2a2420"), Vector3(1, 1.6, 1), 5)


func bellow() -> void:
	_bellow = 1.2


func lie(on: bool) -> void:
	lying = on


func _process(delta: float) -> void:
	_t += delta
	var p := global_position
	var spd := 0.0
	if _last != Vector3.INF and delta > 0.0:
		spd = Vector2(p.x - _last.x, p.z - _last.z).length() / delta
	_last = p
	if lying:
		_body.position.y = lerpf(_body.position.y, -0.62, minf(1.0, delta * 3.0))
		for i in 4:
			_legs[i].rotation.x = lerpf(_legs[i].rotation.x, -1.45 if i < 2 else 1.45, minf(1.0, delta * 3.0))
		_head.rotation.x = lerpf(_head.rotation.x, 0.25 + 0.05 * sin(_t * 0.6), minf(1.0, delta * 2.0))
		_tail.rotation.z = 0.15 * sin(_t * 0.8)
		return
	_body.position.y = lerpf(_body.position.y, 0.0, minf(1.0, delta * 4.0))
	_body.rotation.x = lerpf(_body.rotation.x, -lean * 0.12, minf(1.0, delta * 3.0))
	if spd > 0.15:
		_phase += delta * clampf(spd, 0.5, 4.0) * 2.4
		var a := sin(_phase) * clampf(spd * 0.25, 0.15, 0.5)
		_legs[0].rotation.x = a
		_legs[3].rotation.x = a
		_legs[1].rotation.x = -a
		_legs[2].rotation.x = -a
	else:
		for l in _legs:
			l.rotation.x = lerpf(l.rotation.x, 0.0, minf(1.0, delta * 5.0))
	# Baş: yürürken sallanır; böğürürken kalkar
	_bellow = maxf(0.0, _bellow - delta)
	var hx := 0.12 * sin(_phase * 0.5) if spd > 0.15 else 0.05 * sin(_t * 0.7)
	if _bellow > 0.0:
		hx = -0.6 * sin(clampf(_bellow / 1.2, 0.0, 1.0) * PI)
	_head.rotation.x = lerpf(_head.rotation.x, hx + 0.15, minf(1.0, delta * 6.0))
	_tail.rotation.z = 0.25 * sin(_t * 1.7)
