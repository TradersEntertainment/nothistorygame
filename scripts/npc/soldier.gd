class_name Soldier
extends Node3D
## 1453 ordugâhından bir asker/işçi: renkli kaftan, beyaz börk, kocaman bıyık.
## pose: "stand", "pull" (halat çeker, geriye yaslanır), "point" (bağırır, işaret eder).

var coat := Color("b3262d")
var pose := "stand"
var hat := "bork"          # "bork" (uzun beyaz başlık) ya da "turban"
var _body: Node3D
var _arm_r: Node3D
var _arm_l: Node3D
var _head: Node3D
var _eyes: Node3D
var _t := 0.0
var talking := false
var look_target: Node3D
var _mouth: MeshInstance3D
static var _count := 0
var rig: Rig
var _legs: Array[Node3D] = []
var _knees: Array[Node3D] = []


func _init(p_coat := Color("b3262d"), p_pose := "stand", p_hat := "bork") -> void:
	coat = p_coat
	pose = p_pose
	hat = p_hat


func _ready() -> void:
	add_to_group("soldiers")
	_t = randf() * 10.0
	_body = Node3D.new()
	add_child(_body)
	var skin := Color("d9a07a")
	# Çizmeler, şalvar, kaftan (CharKit: yuvarlak parçalar)
	var legs: Array[Node3D] = []
	var knees: Array[Node3D] = []
	for sx in [-0.11, 0.11]:
		var leg := Node3D.new()
		leg.position = Vector3(sx, 0.68, 0)
		_body.add_child(leg)
		knees.append(CharKit.leg(leg, Color("e8e0cc"), Color("5a3a24"), 0.68, 0.1))
		legs.append(leg)
	CharKit.torso(_body, coat, skin, 0.28, 0.6)
	# Kaftan eteği ve kuşak
	Props.cyl(_body, 0.31, 0.4, Vector3(0, 0.66, 0), coat.darkened(0.06), Vector3.ZERO, 14, 0.27)
	Props.cyl(_body, 0.3, 0.08, Vector3(0, 0.85, 0), Color("e0b52a"), Vector3.ZERO, 14)
	# Kollar
	_arm_l = Node3D.new()
	_arm_l.position = Vector3(-0.33, 1.26, 0)
	_body.add_child(_arm_l)
	var elbow_l := CharKit.arm(_arm_l, coat, skin, 0.5, 0.072)
	_arm_r = Node3D.new()
	_arm_r.position = Vector3(0.33, 1.26, 0)
	_body.add_child(_arm_r)
	var elbow_r := CharKit.arm(_arm_r, coat, skin, 0.5, 0.072)
	# Kafa, kocaman bıyık, başlık
	var head := Node3D.new()
	head.position = Vector3(0, 1.58, 0)
	_body.add_child(head)
	_head = head
	_eyes = Node3D.new()
	head.add_child(_eyes)
	var brows := Node3D.new()
	head.add_child(brows)
	# Her asker farklı yüz ve bıyık (sıra sayacıyla tutarlı)
	_count += 1
	var spec := CharKit.random_face(hash(coat.to_html()) + _count * 7919)
	_mouth = CharKit.face(head, _eyes, brows, skin, Color("2b1d14"), 0.21, 1.15, spec)
	var ms := str(spec.get("mustache", "curl"))
	CharKit.mustache(head, Color("2b1d14"), 0.21, 1.45 if ms == "curl" else 1.2, ms)
	if hat == "bork":
		Props.cyl(head, 0.205, 0.08, Vector3(0, 0.16, 0), Color("c9a24a"), Vector3.ZERO, 16)
		Props.cyl(head, 0.18, 0.45, Vector3(0, 0.38, -0.04), Color("f3efe4"), Vector3(-12, 0, 0), 16, 0.14)
		Props.box(head, Vector3(0.14, 0.4, 0.04), Vector3(0, 0.12, -0.24), Color("f3efe4"), Vector3(20, 0, 0))
	else:
		Props.ball(head, 0.24, Vector3(0, 0.16, 0), Color("f3efe4"), Vector3(1.1, 0.7, 1.1), 8)
	_legs = legs
	_knees = knees
	CharKit.bake(self, [_body, legs[0], legs[1], knees[0], knees[1], _arm_l, _arm_r, elbow_l, elbow_r, _head, _eyes, brows], [_mouth], [_eyes, brows])
	Props.interactable(self, "soldier", Vector3(0.7, 1.9, 0.7), Vector3(0, 0.95, 0)).collision_layer = 0
	rig = Rig.new(self, {"body": _body, "head": _head, "arm_l": _arm_l, "arm_r": _arm_r, "leg_l": legs[0],
		"leg_r": legs[1], "eyes": _eyes, "brows": brows, "arm_rest_z": 0.17,
		"knee_l": knees[0], "knee_r": knees[1], "elbow_l": elbow_l, "elbow_r": elbow_r})


func _process(delta: float) -> void:
	_t += delta
	if _mouth:
		_mouth.scale.y = 0.22 * (1.0 + (LipSync.mouth(_t, delta) * 2.8 if talking else 0.0))
	match pose:
		"pull":
			# Halat çekerken geriye yaslanır: bacaklar önde, dizler bükük, kollar önde
			_body.rotation.x = -0.35 + sin(_t * 2.2) * 0.12
			_arm_r.rotation.x = -1.2
			_arm_l.rotation.x = -1.1
			for i in _legs.size():
				_legs[i].rotation.x = -0.45 - sin(_t * 2.2 + i) * 0.08
				_knees[i].rotation.x = 0.7 + sin(_t * 2.2 + i) * 0.1
		"point":
			_arm_r.rotation.x = -1.6 + sin(_t * 8.0) * 0.25
			_body.rotation.x = 0.05
		_:
			_body.rotation.z = sin(_t * 1.1) * 0.03
			if look_target and is_instance_valid(look_target):
				var to := look_target.global_position - global_position
				to.y = 0.0
				if to.length() > 0.1:
					rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 4.0, 0.0, 1.0))
			rig.update(delta, talking, false)


func emote(kind: String) -> void:
	if pose == "stand":
		await rig.emote(kind)
