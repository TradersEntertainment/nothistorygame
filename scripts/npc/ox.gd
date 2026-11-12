class_name Ox
extends Node3D
## Öküz: canli_kit gövdesi (kesit halkalı gövde, geniş alınlı baş, lir boynuz, eklemli bacak), dört bacak (yürürken çapraz adım), kuyruk, boyunda çan.
## +Z'ye bakar. Hızı kendi konum değişiminden çıkar (dışarıdan taşınsa da yürür). bellow(): baş kalkar.
## lie(true): bacaklar katlanır, gövde yere iner (gece konağı).

const CK = preload("res://scripts/world/ist/canli_kit.gd")

var coat := Color("8a5a36")
var _legs: Array[Node3D] = []
var _knees: Array[Node3D] = []
var _ears: Array = []
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
	# CANLI (kalite notu 32): gövde, boyun, baş, bacak, kuyruk kesit halkalarından (canli_kit); kutu parça yok.
	# Arayüz aynı: _body (yatınca iner), _head (boyun kökünden döner), _tail, _legs[4] (omuz/kalça); _knees görünüş içindir.
	var kit: Dictionary = CK.dugum("okuz", {"renk": coat, "H": 1.48, "lod": 0})
	_body.add_child(kit["root"])
	var p: Dictionary = kit["p"]
	_head = p["boyun"]
	_tail = p["kuyruk"]
	for i in 4:
		_legs.append(p["b%d" % i])
		_knees.append(p["d%d" % i])
	_ears = [p["kulak_l"], p["kulak_r"]]
	# Çan (boyun altında, boyunla döner)
	Props.cyl(_head, 0.09, 0.16, Vector3(0, -0.36, 0.22), Color("b8902a"), Vector3.ZERO, 8, 0.05)
	# Gövde katı: oyuncu öküzün içinden geçmesin (öküz yürüdükçe gövde de taşınır). AnimatableBody3D değil: onun
	# sync_to_physics'i yalnız kendi yerel dönüşümünü izler, öküz (ebeveyn) yürüyünce gövde dünyanın merkezinde
	# kalıyordu (35o köprüsünde ortada görünmez duvar). StaticBody3D ebeveyniyle taşınır.
	var col := StaticBody3D.new()
	col.name = "OxBody"
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.0, 1.1, 2.5)
	cs.shape = bs
	cs.position = Vector3(0, 1.1, 0.05)
	col.add_child(cs)
	add_child(col)


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
			# görünüş: diz katlanır (bacak gövdenin altına toplanır; davranış aynı)
			_knees[i].rotation.x = lerpf(_knees[i].rotation.x, 2.6 if i < 2 else -2.5, minf(1.0, delta * 3.0))
		_head.rotation.x = lerpf(_head.rotation.x, 0.25 + 0.05 * sin(_t * 0.6), minf(1.0, delta * 2.0))
		_tail.rotation.z = 0.15 * sin(_t * 0.8)
		return
	_body.position.y = lerpf(_body.position.y, 0.0, minf(1.0, delta * 4.0))
	for k in _knees:
		k.rotation.x = lerpf(k.rotation.x, 0.0, minf(1.0, delta * 5.0))
	# kulak seğirmesi (sinek), görünüş
	for e in _ears.size():
		(_ears[e] as Node3D).rotation.z = 0.25 * maxf(0.0, sin(_t * 0.9 + e * 2.1) - 0.85) * 6.0 * (1.0 if e == 0 else -1.0)
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
	# yürürken diz bükülür (görünüş)
	if spd > 0.15:
		for i in 4:
			var bend := maxf(0.0, -_legs[i].rotation.x if i < 2 else _legs[i].rotation.x) * 1.4
			_knees[i].rotation.x = bend if i < 2 else -bend
