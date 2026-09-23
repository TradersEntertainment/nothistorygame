class_name Soldier
extends Node3D
## 1453 ordugâhından bir asker/işçi: renkli kaftan, beyaz börk, kocaman bıyık.
## pose: "stand", "pull" (halat çeker, geriye yaslanır), "point" (bağırır, işaret eder).

var coat := Color("b3262d")
var pose := "stand"
var hat := "bork"          # "bork" (uzun beyaz başlık) ya da "turban"
var _body: Node3D
var _arm_r: Node3D
var _t := 0.0


func _init(p_coat := Color("b3262d"), p_pose := "stand", p_hat := "bork") -> void:
	coat = p_coat
	pose = p_pose
	hat = p_hat


func _ready() -> void:
	_t = randf() * 10.0
	_body = Node3D.new()
	add_child(_body)
	var skin := Color("d9a07a")
	# Çizmeler, şalvar, kaftan
	Props.box(_body, Vector3(0.14, 0.14, 0.26), Vector3(-0.11, 0.07, 0.03), Color("5a3a24"))
	Props.box(_body, Vector3(0.14, 0.14, 0.26), Vector3(0.11, 0.07, 0.03), Color("5a3a24"))
	Props.cyl(_body, 0.1, 0.55, Vector3(-0.11, 0.4, 0), Color("e8e0cc"), Vector3.ZERO, 6)
	Props.cyl(_body, 0.1, 0.55, Vector3(0.11, 0.4, 0), Color("e8e0cc"), Vector3.ZERO, 6)
	Props.cyl(_body, 0.3, 0.8, Vector3(0, 0.95, 0), coat, Vector3.ZERO, 8, 0.24)
	Props.cyl(_body, 0.31, 0.08, Vector3(0, 0.82, 0), Color("e0b52a"), Vector3.ZERO, 8)
	# Kollar
	Props.cyl(_body, 0.07, 0.5, Vector3(-0.32, 1.05, 0), coat, Vector3(0, 0, -10), 6)
	_arm_r = Node3D.new()
	_arm_r.position = Vector3(0.32, 1.28, 0)
	_body.add_child(_arm_r)
	Props.cyl(_arm_r, 0.07, 0.5, Vector3(0, -0.24, 0), coat, Vector3.ZERO, 6)
	Props.ball(_arm_r, 0.07, Vector3(0, -0.5, 0), skin, Vector3.ONE, 6)
	# Kafa, bıyık, başlık
	var head := Node3D.new()
	head.position = Vector3(0, 1.58, 0)
	_body.add_child(head)
	Props.ball(head, 0.22, Vector3.ZERO, skin, Vector3(1, 1.05, 1), 10)
	Props.ball(head, 0.06, Vector3(0, -0.02, 0.21), Color("c98a68"), Vector3.ONE, 6)
	Props.box(head, Vector3(0.3, 0.05, 0.05), Vector3(0, -0.09, 0.19), Color("2b1d14"), Vector3(0, 0, 0))
	Props.ball(head, 0.025, Vector3(-0.08, 0.05, 0.19), Color("1a1a1a"), Vector3.ONE, 6)
	Props.ball(head, 0.025, Vector3(0.08, 0.05, 0.19), Color("1a1a1a"), Vector3.ONE, 6)
	if hat == "bork":
		Props.cyl(head, 0.2, 0.08, Vector3(0, 0.16, 0), Color("c9a24a"), Vector3.ZERO, 8)
		Props.cyl(head, 0.18, 0.45, Vector3(0, 0.38, -0.04), Color("f3efe4"), Vector3(-12, 0, 0), 8, 0.14)
		Props.box(head, Vector3(0.14, 0.4, 0.04), Vector3(0, 0.12, -0.24), Color("f3efe4"), Vector3(20, 0, 0))
	else:
		Props.ball(head, 0.24, Vector3(0, 0.16, 0), Color("f3efe4"), Vector3(1.1, 0.7, 1.1), 8)
	Props.interactable(self, "soldier", Vector3(0.7, 1.9, 0.7), Vector3(0, 0.95, 0)).collision_layer = 0


func _process(delta: float) -> void:
	_t += delta
	match pose:
		"pull":
			_body.rotation.x = -0.35 + sin(_t * 2.2) * 0.12
			_arm_r.rotation.x = -1.2
		"point":
			_arm_r.rotation.x = -1.6 + sin(_t * 8.0) * 0.25
			_body.rotation.x = 0.05
		_:
			_body.rotation.z = sin(_t * 1.1) * 0.03
