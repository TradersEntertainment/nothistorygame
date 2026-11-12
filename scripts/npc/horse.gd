class_name Horse
extends Node3D
## Binek atı: canli_kit gövdesi (kesit halkalı gövde, boyun, uzun yüz, yele, kuyruk, diz eklemli dört bacak), eyer ve süslü örtü.
## +Z'ye bakar (Person gibi). speed > 0 iken yürüyüş adımı (çapraz bacaklar birlikte), baş ve kuyruk sallanır.
## mount(person): biniciyi eyere oturtur ("ride" hareketi).

const SADDLE_Y := 1.42

var coat := Color("f2efe8")
var mane := Color("d8d2c4")
var cloth := Color("b3262d")
var speed := 0.0
var rider: Person
var _legs: Array[Node3D] = []
var _knees: Array[Node3D] = []
const CK = preload("res://scripts/world/ist/canli_kit.gd")

var _ears: Array = []
var _neck: Node3D
var _tail: Node3D
var _t := 0.0
var _phase := 0.0


func _init(p_coat := Color("f2efe8"), p_cloth := Color("b3262d")) -> void:
	coat = p_coat
	cloth = p_cloth


func _ready() -> void:
	# CANLI (kalite notu 32): kesit halkalarından gövde, boyun, uzun yüz, yele, kıl kuyruk, diz/bilek eklemli bacaklar
	# (canli_kit); kutu parça yok. Arayüz aynı: _legs (kalça/omuz), _knees, _neck, _tail. Eyer yüksekliği SADDLE_Y'ye göre.
	var kit: Dictionary = CK.dugum("at", {"renk": coat, "H": 1.66, "lod": 0, "takim": ["cul", "eyer", "yular"], "cul_renk": cloth})
	add_child(kit["root"])
	var p: Dictionary = kit["p"]
	_neck = p["boyun"]
	_tail = p["kuyruk"]
	for i in 4:
		_legs.append(p["b%d" % i])
		_knees.append(p["d%d" % i])
	_ears = [p["kulak_l"], p["kulak_r"]]
	# Eyer kaşı ve örtü kenarı (altın şerit): yuvarlak kesitli ince tüpler; üzengi
	for sx: float in [-1.0, 1.0]:
		Props.cyl(self, 0.012, 0.5, Vector3(sx * 0.4, 1.38, 0.08), Color("3a2a1c"), Vector3.ZERO, 4)
		Props.cyl(self, 0.05, 0.025, Vector3(sx * 0.4, 1.12, 0.08), Color("8a8480"), Vector3(0, 0, 90), 8, 0.05)
	# Göğüslük: göğsü saran altın kayış (kesit halkalı yay) ve püskül
	var band: Array = []
	for k in 9:
		var a := lerpf(-1.25, 1.25, k / 8.0)
		band.append([Vector3(sin(a) * 0.36, 1.3 - 0.06 * cos(a * 2.0), 0.62 + cos(a) * 0.36), 0.018, 0.018, 0.018, Color("d8b040")])
	var acc = CK.Acc.new()
	CK._tube(acc, band, 5, true, true, 0.4)
	var bm := MeshInstance3D.new()
	bm.mesh = acc.mesh()
	bm.material_override = CK.mat()
	bm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(bm)
	Props.ball(self, 0.06, Vector3(0, 1.2, 1.0), cloth, Vector3(1, 1.4, 1), 6)


## Biniciyi eyere oturtur.
func mount(p: Person) -> void:
	rider = p
	if p.get_parent():
		p.get_parent().remove_child(p)
	add_child(p)
	p.position = Vector3(0, SADDLE_Y - 0.38, -0.05)
	p.rotation = Vector3.ZERO
	p.set_activity("ride")


func _process(delta: float) -> void:
	_t += delta
	var moving := speed > 0.2
	if moving:
		_phase += delta * (2.6 + speed * 1.4)
	var sw := sin(_phase) if moving else 0.0
	var amp := clampf(speed / 2.0, 0.3, 1.0) * 0.45
	# Çapraz eşli yürüyüş: sol ön + sağ arka birlikte
	for i in _legs.size():
		var sgn := 1.0 if i == 0 or i == 3 else -1.0
		var s := sw * sgn
		_legs[i].rotation.x = lerpf(_legs[i].rotation.x, s * amp, clampf(delta * 10.0, 0.0, 1.0))
		var bend := maxf(0.0, -s) * 0.9 * amp * 2.0 if moving else 0.0
		# Ön bacakta bilek (karpus) alt bacağı geriye, arka bacakta diz (hock) öne katlar (CANLI: anatomiye göre)
		_knees[i].rotation.x = lerpf(_knees[i].rotation.x, bend * (-1.0 if i >= 2 else 1.0), clampf(delta * 10.0, 0.0, 1.0))
	if _neck:
		_neck.rotation.x = (sin(_phase * 2.0) * 0.06 if moving else sin(_t * 0.6) * 0.03)
	for e in _ears.size():
		(_ears[e] as Node3D).rotation.x = 0.3 * maxf(0.0, sin(_t * 0.7 + e * 2.4) - 0.8) * 5.0
	if _tail:
		_tail.rotation.z = sin(_t * 1.3) * 0.18
		_tail.rotation.x = 0.1 + (sin(_phase * 2.0) * 0.1 if moving else 0.0)
