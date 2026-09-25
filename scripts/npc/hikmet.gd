class_name Hikmet
extends Node3D
## Hikmet Amca: pijamalı, koca kafalı, bıyıklı, gözlüklü emekli mucit.
## Low-poly parçalardan kurulur. Konuşurken bıyığı oynar, oyuncuya döner.

const C_PAJAMA := Color("5b7fb3")
const C_STRIPE := Color("a9c1e3")
const C_SKIN := Color("e0a57e")
const C_HAIR := Color("c9c9c9")

var talking := false
var look_target: Node3D
var _head: Node3D
var _mustache: MeshInstance3D
var _body: Node3D
var _t := 0.0
var _busy := false
var _kick_leg: Node3D
var _slipper: MeshInstance3D
var _leg_l: Node3D
var _arm_l: Node3D
var _arm_r: Node3D
var _eyes: Node3D
var rig: Rig

signal kick_hit


func _ready() -> void:
	_body = Node3D.new()
	add_child(_body)
	# Bacaklar ve gövde (çizgili pijama). İki bacak da kalçadan döner (yürüme; sağ bacak tekme). CharKit parçaları.
	_leg_l = Node3D.new()
	_leg_l.position = Vector3(-0.1, 0.66, 0)
	_body.add_child(_leg_l)
	var knee_l := CharKit.leg(_leg_l, C_PAJAMA, Color("6b4a3a"), 0.66, 0.088)
	_kick_leg = Node3D.new()
	_kick_leg.position = Vector3(0.1, 0.66, 0)
	_body.add_child(_kick_leg)
	var knee_r := CharKit.leg(_kick_leg, C_PAJAMA, Color("6b4a3a"), 0.66, 0.088)
	# Terlik (tekmede uçan parça): ayağın üstünde ayrı, yassı yuvarlak
	_slipper = CharKit.ball(knee_r, 0.08, Vector3(0, -0.27, 0.06), Color("8a5a40"), Vector3(1.05, 0.45, 1.8))
	CharKit.torso(_body, C_PAJAMA, C_SKIN, 0.27, 1.0, 1.26)
	for i in 4:
		Props.cyl(_body, 0.285 - i * 0.012, 0.035, Vector3(0, 0.74 + i * 0.14, 0), C_STRIPE, Vector3.ZERO, 16)
	# Kollar
	_arm_l = Node3D.new()
	_arm_l.position = Vector3(-0.3, 1.2, 0.02)
	_body.add_child(_arm_l)
	var elbow_l := CharKit.arm(_arm_l, C_PAJAMA, C_SKIN, 0.5)
	_arm_r = Node3D.new()
	_arm_r.position = Vector3(0.3, 1.2, 0.02)
	_body.add_child(_arm_r)
	var elbow_r := CharKit.arm(_arm_r, C_PAJAMA, C_SKIN, 0.5)
	# Kafa (bilerek büyük): kel tepe, yanlarda kabarık kır saç, kocaman beyaz bıyık, yuvarlak gözlük
	_head = Node3D.new()
	_head.position = Vector3(0, 1.5, 0)
	_body.add_child(_head)
	_eyes = Node3D.new()
	_head.add_child(_eyes)
	var brows := Node3D.new()
	_head.add_child(brows)
	CharKit.face(_head, _eyes, brows, C_SKIN, C_HAIR, 0.25, 1.2)
	for sx: int in [-1, 1]:
		CharKit.ball(_head, 0.1, Vector3(sx * 0.22, 0.04, -0.08), C_HAIR, Vector3(0.7, 1.0, 1.3))
	CharKit.ball(_head, 0.12, Vector3(0, 0.02, -0.2), C_HAIR, Vector3(1.6, 0.9, 0.6))
	_mustache = MeshInstance3D.new()
	_head.add_child(_mustache)
	_mustache.position = Vector3(0, -0.1, 0)
	_mustache.mesh = null
	var mh := Node3D.new()
	_mustache.add_child(mh)
	mh.position = Vector3(0, 0.1, 0)
	CharKit.mustache(mh, Color("e8e8e4"), 0.25, 1.6)
	Props.ring(_head, 0.055, 0.07, Vector3(-0.09, 0.06, 0.235), Color("222222"), Vector3(90, 0, 0))
	Props.ring(_head, 0.055, 0.07, Vector3(0.09, 0.06, 0.235), Color("222222"), Vector3(90, 0, 0))
	Props.box(_head, Vector3(0.05, 0.012, 0.012), Vector3(0, 0.07, 0.245), Color("222222"))
	# Kemerde koli bandı (her zaman yanında)
	Props.ring(_body, 0.05, 0.1, Vector3(0.24, 0.7, 0.12), Color("c98a3a"), Vector3(0, 0, 80))

	CharKit.bake(self, [_body, _leg_l, _kick_leg, knee_l, knee_r, _arm_l, _arm_r, elbow_l, elbow_r, _head, _eyes, brows, _mustache], [_slipper], [_eyes, brows])
	# Etkileşim alanı
	Props.interactable(self, "hikmet", Vector3(0.7, 1.8, 0.7), Vector3(0, 0.9, 0))
	add_to_group("persons_hikmet")
	rig = Rig.new(self, {"body": _body, "head": _head, "arm_l": _arm_l, "arm_r": _arm_r, "leg_l": _leg_l,
		"leg_r": _kick_leg, "eyes": _eyes, "brows": brows, "arm_rest_z": 0.21,
		"knee_l": knee_l, "knee_r": knee_r, "elbow_l": elbow_l, "elbow_r": elbow_r})


func _process(delta: float) -> void:
	_t += delta
	# Hafif sallanma; nefes, yürüme, bakınma, jestler Rig'de
	if not _busy:
		_body.rotation.z = sin(_t * 0.9) * 0.02
	rig.update(delta, talking, _busy)
	# Konuşurken bıyık oynar
	if talking:
		_mustache.position.y = -0.1 + abs(sin(_t * 14.0)) * 0.025
	else:
		_mustache.position.y = -0.1
	# Hedefe dön
	if look_target and not _busy:
		var to := look_target.global_position - global_position
		to.y = 0.0
		if to.length() > 0.1:
			var target_yaw := atan2(to.x, to.z)
			rotation.y = lerp_angle(rotation.y, target_yaw, clampf(delta * 4.0, 0.0, 1.0))


## Makineye tekme: yürür, sağ bacağını geri çeker, savurur (terlik uçar gibi olur), geri döner.
## Darbe anında kick_hit sinyali gelir.
## stand verilirse tekmeyi o noktadan atar (izleyen kamera onu yandan görsün diye).
func kick(target: Vector3, stand := Vector3.INF) -> void:
	_busy = true
	var start := global_position
	var mid := stand
	if stand == Vector3.INF:
		var to := target - start
		to.y = 0.0
		mid = start + to.normalized() * maxf(0.0, to.length() - 0.75)
	mid.y = start.y
	var walk := mid - start
	if walk.length() > 0.05:
		rotation.y = atan2(walk.x, walk.z)
	var face := target - mid
	var tw := create_tween()
	tw.tween_property(self, "global_position", mid, 0.7).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(self, "rotation:y", atan2(face.x, face.z), 0.2)
	# Geri çekiş: gövde geriye yatar, bacak arkaya
	tw.tween_property(_kick_leg, "rotation:x", deg_to_rad(40), 0.35).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_body, "rotation:x", -0.12, 0.35)
	tw.tween_interval(0.15)
	# Savuruş
	tw.tween_property(_kick_leg, "rotation:x", deg_to_rad(-85), 0.13).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(_body, "rotation:x", 0.18, 0.13)
	tw.tween_callback(func(): kick_hit.emit())
	tw.tween_interval(0.25)
	tw.tween_property(_kick_leg, "rotation:x", 0.0, 0.3)
	tw.parallel().tween_property(_body, "rotation:x", 0.0, 0.3)
	tw.tween_interval(0.2)
	tw.tween_property(self, "global_position", start, 0.7).set_trans(Tween.TRANS_QUAD)
	await tw.finished
	_busy = false


func emote(kind: String) -> void:
	if not _busy:
		await rig.emote(kind)


func is_kicking() -> bool:
	return _busy
