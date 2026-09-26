class_name Soldier
extends Node3D
## 1453 ordugâhından bir asker/işçi: renkli kaftan, beyaz börk, kocaman bıyık.
## pose: "stand", "pull" (halat çeker, geriye yaslanır), "point" (kameraya/oyuncuya döner, bağırır, işaret eder),
## "push" (ırgat kolunu iterek yürür), "grease" (kovadan kızağa iç yağı atar).

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
var _elbow_r: Node3D
var _elbow_l: Node3D
var _thrown := false


func _init(p_coat := Color("b3262d"), p_pose := "stand", p_hat := "bork") -> void:
	coat = p_coat
	pose = p_pose
	hat = p_hat


func _ready() -> void:
	add_to_group("soldiers")
	Unclip.settle(self)
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
	_elbow_r = elbow_r
	_elbow_l = elbow_l
	if pose == "grease":
		# Yağ kovası: sağ elde, kulplu
		var bucket := Node3D.new()
		elbow_r.add_child(bucket)
		bucket.position = Vector3(0, -0.36, 0.02)
		Props.cyl(bucket, 0.13, 0.22, Vector3(0, -0.1, 0), Color("6b4a2e"), Vector3.ZERO, 10, 0.15)
		Props.cyl(bucket, 0.135, 0.03, Vector3(0, -0.02, 0), Color("4a4d52"), Vector3.ZERO, 10)
		Props.cyl(bucket, 0.125, 0.02, Vector3(0, 0.0, 0), Color("f0dc9a"), Vector3.ZERO, 10)
	CharKit.bake(self, [_body, legs[0], legs[1], knees[0], knees[1], _arm_l, _arm_r, elbow_l, elbow_r, _head, _eyes, brows], [_mouth], [_eyes, brows])
	Props.interactable(self, "soldier", Vector3(0.7, 1.9, 0.7), Vector3(0, 0.95, 0)).collision_layer = 0
	rig = Rig.new(self, {"body": _body, "head": _head, "arm_l": _arm_l, "arm_r": _arm_r, "leg_l": legs[0],
		"leg_r": legs[1], "eyes": _eyes, "brows": brows, "arm_rest_z": 0.17,
		"knee_l": knees[0], "knee_r": knees[1], "elbow_l": elbow_l, "elbow_r": elbow_r})


func _process(delta: float) -> void:
	_t += delta
	if _mouth:
		_mouth.scale.y = 0.22 * (1.0 + (LipSync.mouth(_t, delta) * 2.8 if talking else 0.0))
		_mouth.scale.x = rig.mouth_x if rig else 1.0
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
			# Yakından geçen oyuncuya (kameraya) döner, gösterip bağırır; uzaktaysa önüne bakıp el sallar
			_arm_r.rotation.x = -1.6 + sin(_t * 8.0) * 0.25
			_body.rotation.x = 0.05
			var cam := get_viewport().get_camera_3d() if is_inside_tree() else null
			var near := false
			if cam:
				var to := cam.global_position - global_position
				to.y = 0.0
				near = to.length() < 22.0
				if near and to.length() > 0.5:
					var want := atan2(to.x, to.z) - (get_parent_node_3d().global_rotation.y if get_parent_node_3d() else 0.0)
					rotation.y = lerp_angle(rotation.y, want, clampf(delta * 5.0, 0.0, 1.0))
			talking = near
			_arm_l.rotation.x = -0.5 + sin(_t * 8.0 + 1.0) * 0.3 if near else 0.0
		"push":
			# Irgat: öne yaslanır, kollar kolda, adım adım yürür
			_body.rotation.x = 0.42
			_arm_r.rotation.x = -1.35
			_arm_l.rotation.x = -1.35
			if _elbow_r:
				_elbow_r.rotation.x = -0.35
				_elbow_l.rotation.x = -0.35
			for i in _legs.size():
				var ph := _t * 4.2 + PI * i
				_legs[i].rotation.x = sin(ph) * 0.45 - 0.25
				_knees[i].rotation.x = maxf(0.0, -cos(ph)) * 0.8 + 0.1
		"grease":
			# 3 sn'lik döngü: kovayı geriye alır, ileri savurur (yağ kızağa uçar), bekler
			var k := fmod(_t, 3.0)
			if k < 1.2:
				var a := k / 1.2
				_arm_r.rotation.x = lerpf(0.0, 0.6, a)
				_body.rotation.x = lerpf(0.0, -0.12, a)
				_thrown = false
			elif k < 1.55:
				var b := (k - 1.2) / 0.35
				_arm_r.rotation.x = lerpf(0.6, -1.7, b)
				_arm_l.rotation.x = lerpf(0.0, -1.2, b)
				_body.rotation.x = lerpf(-0.12, 0.3, b)
				if b > 0.55 and not _thrown:
					_thrown = true
					_splash()
			else:
				var c := minf((k - 1.55) / 0.8, 1.0)
				_arm_r.rotation.x = lerpf(-1.7, 0.0, c)
				_arm_l.rotation.x = lerpf(-1.2, 0.0, c)
				_body.rotation.x = lerpf(0.3, 0.0, c)
		_:
			_body.rotation.z = sin(_t * 1.1) * 0.03
			if look_target and is_instance_valid(look_target):
				var to := look_target.global_position - global_position
				to.y = 0.0
				if to.length() > 0.1:
					rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 4.0, 0.0, 1.0))
			rig.update(delta, talking, false)


## Kovadan savrulan iç yağı: birkaç sarımsı damla önündeki kızağa yay çizip düşer, yayılıp söner.
func _splash() -> void:
	var par := get_parent_node_3d()
	if par == null or not is_inside_tree():
		return
	var fwd := global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var start := global_position + Vector3(0, 1.35, 0) + fwd * 0.5
	for i in 6:
		var blob := Props.ball(par, 0.07 + randf() * 0.05, Vector3.ZERO, Color("f0dc9a"), Vector3(1, 0.8, 1), 6)
		blob.global_position = start
		var land := global_position + fwd * randf_range(2.0, 3.4) + fwd.cross(Vector3.UP) * randf_range(-0.7, 0.7) + Vector3(0, -0.1, 0)
		var peak := (start + land) * 0.5 + Vector3(0, 0.6, 0)
		var tw := blob.create_tween()
		var d := randf_range(0.35, 0.5)
		tw.tween_method(func(t: float):
			if is_instance_valid(blob):
				blob.global_position = start.lerp(peak, t).lerp(peak.lerp(land, t), t), 0.0, 1.0, d)
		tw.tween_property(blob, "scale", Vector3(2.4, 0.2, 2.4), 0.15)
		tw.tween_interval(0.8)
		tw.tween_property(blob, "scale", Vector3(0.01, 0.01, 0.01), 0.5)
		tw.tween_callback(blob.queue_free)


func emote(kind: String) -> void:
	if pose == "stand":
		await rig.emote(kind)


## Bir noktaya dön (yalnız yatay: karakter eğilmez; look_at karakteri öne/arkaya yatırıyordu).
func face_toward(p: Vector3) -> void:
	var to := p - global_position
	if Vector2(to.x, to.z).length() > 0.01:
		global_rotation = Vector3(0, atan2(to.x, to.z), 0)
