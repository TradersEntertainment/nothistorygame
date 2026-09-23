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

signal kick_hit


func _ready() -> void:
	_body = Node3D.new()
	add_child(_body)
	# Terlikler
	Props.box(_body, Vector3(0.14, 0.06, 0.28), Vector3(-0.1, 0.03, 0.04), Color("6b4a3a"))
	# Bacaklar ve gövde (çizgili pijama). Sağ bacak kalçadan döner (tekme).
	Props.cyl(_body, 0.08, 0.6, Vector3(-0.1, 0.36, 0), C_PAJAMA, Vector3.ZERO, 6)
	_kick_leg = Node3D.new()
	_kick_leg.position = Vector3(0.1, 0.66, 0)
	_body.add_child(_kick_leg)
	Props.cyl(_kick_leg, 0.08, 0.6, Vector3(0, -0.3, 0), C_PAJAMA, Vector3.ZERO, 6)
	_slipper = Props.box(_kick_leg, Vector3(0.14, 0.06, 0.28), Vector3(0, -0.63, 0.04), Color("6b4a3a"))
	Props.cyl(_body, 0.26, 0.62, Vector3(0, 0.95, 0), C_PAJAMA, Vector3.ZERO, 8, 0.22)
	for i in 4:
		Props.cyl(_body, 0.262 - i * 0.012, 0.035, Vector3(0, 0.72 + i * 0.15, 0), C_STRIPE, Vector3.ZERO, 8)
	# Göbek
	Props.ball(_body, 0.2, Vector3(0, 0.88, 0.1), C_PAJAMA, Vector3(1, 0.9, 0.8), 8)
	# Kollar
	Props.cyl(_body, 0.06, 0.5, Vector3(-0.3, 0.98, 0.02), C_PAJAMA, Vector3(0, 0, -12), 6)
	Props.cyl(_body, 0.06, 0.5, Vector3(0.3, 0.98, 0.02), C_PAJAMA, Vector3(0, 0, 12), 6)
	Props.ball(_body, 0.06, Vector3(-0.35, 0.72, 0.02), C_SKIN, Vector3.ONE, 6)
	Props.ball(_body, 0.06, Vector3(0.35, 0.72, 0.02), C_SKIN, Vector3.ONE, 6)
	# Kafa (bilerek büyük)
	_head = Node3D.new()
	_head.position = Vector3(0, 1.48, 0)
	_body.add_child(_head)
	Props.ball(_head, 0.25, Vector3.ZERO, C_SKIN, Vector3(1, 1.05, 1), 10)
	# Kel tepe, yanlarda kır saç
	Props.ring(_head, 0.2, 0.27, Vector3(0, 0.02, -0.02), C_HAIR, Vector3(10, 0, 0))
	# Burun
	Props.ball(_head, 0.07, Vector3(0, -0.02, 0.24), Color("d48f6a"), Vector3(1, 1.1, 1), 6)
	# Bıyık
	_mustache = Props.box(_head, Vector3(0.26, 0.06, 0.06), Vector3(0, -0.1, 0.22), Color("d8d8d8"))
	# Gözlük
	Props.ring(_head, 0.045, 0.06, Vector3(-0.09, 0.06, 0.235), Color("222222"), Vector3(90, 0, 0))
	Props.ring(_head, 0.045, 0.06, Vector3(0.09, 0.06, 0.235), Color("222222"), Vector3(90, 0, 0))
	Props.box(_head, Vector3(0.06, 0.012, 0.012), Vector3(0, 0.06, 0.24), Color("222222"))
	Props.ball(_head, 0.02, Vector3(-0.09, 0.06, 0.225), Color("1a1a1a"), Vector3.ONE, 6)
	Props.ball(_head, 0.02, Vector3(0.09, 0.06, 0.225), Color("1a1a1a"), Vector3.ONE, 6)
	# Kulaklar
	Props.ball(_head, 0.05, Vector3(-0.25, 0.0, 0), C_SKIN, Vector3(0.6, 1, 1), 6)
	Props.ball(_head, 0.05, Vector3(0.25, 0.0, 0), C_SKIN, Vector3(0.6, 1, 1), 6)
	# Kemerde koli bandı (her zaman yanında)
	Props.ring(_body, 0.05, 0.1, Vector3(0.24, 0.7, 0.12), Color("c98a3a"), Vector3(0, 0, 80))

	# Etkileşim alanı
	Props.interactable(self, "hikmet", Vector3(0.7, 1.8, 0.7), Vector3(0, 0.9, 0))


func _process(delta: float) -> void:
	_t += delta
	# Nefes alma / hafif sallanma
	_body.position.y = sin(_t * 2.0) * 0.01
	_body.rotation.z = sin(_t * 0.9) * 0.02
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


func is_kicking() -> bool:
	return _busy
