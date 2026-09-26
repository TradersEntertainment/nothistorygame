class_name Horse
extends Node3D
## Binek atı: low-poly gövde, boyun, baş, yele, kuyruk, dört bacak (diz eklemli), eyer ve süslü örtü.
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
var _neck: Node3D
var _tail: Node3D
var _t := 0.0
var _phase := 0.0


func _init(p_coat := Color("f2efe8"), p_cloth := Color("b3262d")) -> void:
	coat = p_coat
	cloth = p_cloth


func _ready() -> void:
	# Gövde: fıçı gibi, önü göğüs, arkası sağrı
	Props.cyl(self, 0.42, 1.55, Vector3(0, 1.25, 0), coat, Vector3(90, 0, 0), 10)
	Props.ball(self, 0.43, Vector3(0, 1.27, 0.72), coat, Vector3(1.0, 1.05, 0.9), 10)
	Props.ball(self, 0.45, Vector3(0, 1.3, -0.72), coat, Vector3(1.05, 1.0, 0.95), 10)
	# Boyun ve baş (boyun ekseninden sallanır)
	_neck = Node3D.new()
	_neck.position = Vector3(0, 1.45, 0.85)
	add_child(_neck)
	Props.cyl(_neck, 0.2, 0.9, Vector3(0, 0.34, 0.2), coat, Vector3(-35, 0, 0), 8, 0.26)
	var head := Node3D.new()
	head.position = Vector3(0, 0.78, 0.48)
	_neck.add_child(head)
	Props.box(head, Vector3(0.26, 0.28, 0.58), Vector3(0, 0, 0.12), coat, Vector3(35, 0, 0))
	Props.box(head, Vector3(0.22, 0.2, 0.2), Vector3(0, -0.22, 0.38), coat.darkened(0.05), Vector3(35, 0, 0))
	for sx: float in [-1.0, 1.0]:
		Props.box(head, Vector3(0.06, 0.16, 0.05), Vector3(sx * 0.09, 0.2, -0.08), coat, Vector3(-10, 0, sx * 12))
		Props.ball(head, 0.035, Vector3(sx * 0.13, 0.04, 0.08), Color("1a1410"), Vector3.ONE, 6)
	# Yele (boyun boyunca) ve perçem
	for k in 5:
		Props.box(_neck, Vector3(0.06, 0.2, 0.16), Vector3(0, 0.3 + k * 0.12, -0.02 + k * 0.08), mane, Vector3(-35, 0, 0))
	# Dizgin (ağızdan eyere)
	Props.box(_neck, Vector3(0.02, 0.02, 0.9), Vector3(0.14, 0.25, 0.25), Color("4a2a18"), Vector3(-20, 0, 0))
	Props.box(_neck, Vector3(0.02, 0.02, 0.9), Vector3(-0.14, 0.25, 0.25), Color("4a2a18"), Vector3(-20, 0, 0))
	# Kuyruk
	_tail = Node3D.new()
	_tail.position = Vector3(0, 1.45, -1.1)
	add_child(_tail)
	Props.cyl(_tail, 0.1, 0.8, Vector3(0, -0.35, -0.12), mane, Vector3(20, 0, 0), 6, 0.04)
	# Bacaklar: kalça/omuz ekseni, diz; toynak koyu
	for spec in [[-0.22, 0.62], [0.22, 0.62], [-0.22, -0.62], [0.22, -0.62]]:
		var hip := Node3D.new()
		hip.position = Vector3(spec[0], 1.05, spec[1])
		add_child(hip)
		Props.cyl(hip, 0.1, 0.55, Vector3(0, -0.27, 0), coat, Vector3.ZERO, 6, 0.08)
		var knee := Node3D.new()
		knee.position = Vector3(0, -0.54, 0)
		hip.add_child(knee)
		Props.cyl(knee, 0.065, 0.46, Vector3(0, -0.23, 0), coat, Vector3.ZERO, 6, 0.06)
		Props.cyl(knee, 0.08, 0.08, Vector3(0, -0.47, 0.01), Color("2a2420"), Vector3.ZERO, 6)
		_legs.append(hip)
		_knees.append(knee)
	# Eyer, örtü (kenarı altın), üzengiler
	Props.box(self, Vector3(0.98, 0.04, 1.0), Vector3(0, 1.66, -0.05), cloth)
	for sx: float in [-1.0, 1.0]:
		Props.box(self, Vector3(0.04, 0.5, 1.0), Vector3(sx * 0.48, 1.42, -0.05), cloth)
		Props.box(self, Vector3(0.045, 0.06, 1.0), Vector3(sx * 0.49, 1.18, -0.05), Color("d8b040"))
		Props.cyl(self, 0.012, 0.5, Vector3(sx * 0.46, 1.25, 0.05), Color("3a2a1c"), Vector3.ZERO, 4)
		Props.box(self, Vector3(0.12, 0.03, 0.08), Vector3(sx * 0.46, 1.0, 0.05), Color("8a8480"))
	Props.box(self, Vector3(0.5, 0.12, 0.62), Vector3(0, 1.72, -0.05), Color("5a2a18"))
	Props.box(self, Vector3(0.44, 0.18, 0.08), Vector3(0, 1.8, 0.24), Color("5a2a18"))
	# Göğüslük: altın zincir, püskül
	Props.box(self, Vector3(0.7, 0.05, 0.05), Vector3(0, 1.3, 1.02), Color("d8b040"), Vector3(0, 0, 0))
	Props.ball(self, 0.06, Vector3(0, 1.22, 1.06), cloth, Vector3(1, 1.4, 1), 6)


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
		# Ön bacaklar diz öne, arka bacaklar diz arkaya bükülür
		_knees[i].rotation.x = lerpf(_knees[i].rotation.x, bend * (1.0 if i >= 2 else -1.0), clampf(delta * 10.0, 0.0, 1.0))
	if _neck:
		_neck.rotation.x = (sin(_phase * 2.0) * 0.06 if moving else sin(_t * 0.6) * 0.03)
	if _tail:
		_tail.rotation.z = sin(_t * 1.3) * 0.18
		_tail.rotation.x = 0.1 + (sin(_phase * 2.0) * 0.1 if moving else 0.0)
