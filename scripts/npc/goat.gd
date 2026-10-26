class_name Goat
extends Node3D
## Pazarın kaçak keçisi: ortalıkta dolaşır, yaklaşınca kaçar, köşeye sıkışınca yakalanır.

var bounds := Rect2(-6, 4, 12, 10)     # x, z alanı
var chase: Node3D                       # yaklaşınca kaçacağı kişi
var follow: Node3D                      # peşine takıldığı kişi (Bölüm 9, 8.4: pijamalı Hikmet'i kovalar)
var caught := false
var _target := Vector3.ZERO
var _t := 0.0
var _legs: Array[Node3D] = []
var _dust_t := 0.0


func _ready() -> void:
	var body := Props.box(self, Vector3(0.35, 0.3, 0.7), Vector3(0, 0.55, 0), Color("e8e2d4"))
	body.name = "Body"
	Props.box(self, Vector3(0.2, 0.22, 0.26), Vector3(0, 0.78, 0.42), Color("e8e2d4"), Vector3(20, 0, 0))
	Props.box(self, Vector3(0.1, 0.12, 0.08), Vector3(0, 0.66, 0.56), Color("d8d0c0"))
	for side in [-1, 1]:
		Props.cyl(self, 0.02, 0.2, Vector3(side * 0.06, 0.95, 0.36), Color("5a4a3a"), Vector3(-30, 0, side * 20), 4)
		Props.box(self, Vector3(0.1, 0.03, 0.06), Vector3(side * 0.13, 0.82, 0.38), Color("d8d0c0"))
	Props.box(self, Vector3(0.05, 0.12, 0.04), Vector3(0, 0.58, 0.6), Color("8a8070"))
	for i in 4:
		var leg := Node3D.new()
		leg.position = Vector3(-0.12 + (i % 2) * 0.24, 0.42, -0.25 + (i / 2) * 0.5)
		add_child(leg)
		Props.cyl(leg, 0.035, 0.42, Vector3(0, -0.21, 0), Color("d8d0c0"), Vector3.ZERO, 4)
		_legs.append(leg)
	_pick_target()


func _pick_target() -> void:
	_target = Vector3(randf_range(bounds.position.x, bounds.end.x), 0, randf_range(bounds.position.y, bounds.end.y))


var _bleat_t := randf_range(6.0, 14.0)


func _process(delta: float) -> void:
	if caught:
		return
	_t += delta
	# Ara sıra meler (bölüm boyunca sessizdi); kaçarken daha sık
	_bleat_t -= delta
	if _bleat_t <= 0.0:
		_bleat_t = randf_range(7.0, 16.0)
		Audio.sfx_at("goat", self, -10.0)
	var speed := 1.2
	if follow and is_instance_valid(follow):
		# Peşinden gelir: yanına kadar sokulur, orada durup ona bakar, ara sıra dürtmek için bir adım daha atar
		var to_f := follow.global_position - global_position
		to_f.y = 0.0
		if to_f.length() > 1.4:
			_target = follow.global_position - to_f.normalized() * 1.0
			speed = 2.2 if to_f.length() > 3.0 else 1.4
		else:
			_target = global_position
			rotation.y = lerp_angle(rotation.y, atan2(to_f.x, to_f.z), clampf(delta * 4.0, 0.0, 1.0))
			position.y = lerpf(position.y, 0.0, clampf(delta * 8.0, 0.0, 1.0))
			for leg in _legs:
				leg.rotation.x = lerpf(leg.rotation.x, 0.0, clampf(delta * 8.0, 0.0, 1.0))
			return
	elif chase:
		var away := global_position - chase.global_position
		away.y = 0.0
		if away.length() < 3.5:
			# Kaçar: ama alanın dışına çıkamaz, köşede sıkışır
			_target = global_position + away.normalized() * 2.0
			_target.x = clampf(_target.x, bounds.position.x, bounds.end.x)
			_target.z = clampf(_target.z, bounds.position.y, bounds.end.y)
			speed = 2.6
			_bleat_t = minf(_bleat_t, randf_range(0.5, 2.5))
	var to := _target - global_position
	to.y = 0.0
	if to.length() < 0.3:
		_pick_target()
		return
	global_position += to.normalized() * minf(to.length(), delta * speed)
	rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 6.0, 0.0, 1.0))
	var fleeing := speed > 2.0
	for i in _legs.size():
		_legs[i].rotation.x = sin(_t * (20.0 if fleeing else 12.0) + i * PI) * (0.7 if fleeing else 0.4)
	# Kaçarken sekerek koşar, arkasında toz bırakır
	position.y = absf(sin(_t * 10.0)) * 0.22 if fleeing else lerpf(position.y, 0.0, clampf(delta * 8.0, 0.0, 1.0))
	if fleeing:
		_dust_t -= delta
		if _dust_t <= 0.0 and get_parent() is Node3D:
			_dust_t = 0.5
			Vfx.dust(get_parent(), global_position, 0.35)
