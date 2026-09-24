class_name Chicken
extends Node3D
## Sinerji: Niko'nun surdan fırlattığı, her seferinde geri gelen ve sonunda Tolga'nın
## peşine takılan tavuk (GDD §5.15). Kanat çırpar, kafasını sallar; follow ayarlanınca
## hedefin arkasından sekerek gelir.

var follow: Node3D
var flapping := false
## Serbest tavuk (ordugâh kümesi): yard boş değilse içinde dolaşır, yaklaşınca kaçar, köşede yakalanır.
var yard := Rect2()
var _wild_target := Vector3.ZERO
var _catch_cd := 0.0
var _t := 0.0
var _body: Node3D
var _head: Node3D
var _wings: Array[Node3D] = []


func _ready() -> void:
	_t = randf() * 5.0
	_body = Node3D.new()
	add_child(_body)
	Props.ball(_body, 0.16, Vector3(0, 0.24, 0), Color("f6f2e8"), Vector3(1.0, 0.9, 1.25), 8)
	Props.box(_body, Vector3(0.12, 0.16, 0.08), Vector3(0, 0.34, -0.2), Color("f6f2e8"), Vector3(-30, 0, 0))
	for side in [-1, 1]:
		Props.cyl(_body, 0.012, 0.14, Vector3(side * 0.06, 0.07, 0.02), Color("e0a020"), Vector3.ZERO, 4)
		var w := Node3D.new()
		w.position = Vector3(side * 0.15, 0.27, 0)
		_body.add_child(w)
		Props.box(w, Vector3(0.04, 0.12, 0.22), Vector3(side * 0.02, -0.02, 0), Color("e8e2d4"))
		_wings.append(w)
	_head = Node3D.new()
	_head.position = Vector3(0, 0.42, 0.14)
	_body.add_child(_head)
	Props.ball(_head, 0.08, Vector3.ZERO, Color("f6f2e8"), Vector3.ONE, 8)
	Props.box(_head, Vector3(0.025, 0.07, 0.1), Vector3(0, 0.08, -0.01), Color("d8262d"))
	Props.prism(_head, Vector3(0.05, 0.06, 0.05), Vector3(0, -0.01, 0.09), Color("e0a020"), Vector3(-90, 0, 0))
	Props.ball(_head, 0.022, Vector3(0, -0.07, 0.05), Color("d8262d"), Vector3.ONE, 5)
	Props.ball(_head, 0.014, Vector3(-0.05, 0.02, 0.05), Color("141414"), Vector3.ONE, 4)
	Props.ball(_head, 0.014, Vector3(0.05, 0.02, 0.05), Color("141414"), Vector3.ONE, 4)


func _process(delta: float) -> void:
	_t += delta
	if yard.has_area() and follow == null:
		_wild(delta)
	var flap := flapping or (follow != null and _moving)
	for i in _wings.size():
		var s := -1.0 if i == 0 else 1.0
		_wings[i].rotation.z = s * (0.9 + sin(_t * 30.0) * 0.6) if flapping else s * sin(_t * 3.0) * 0.08
	_head.rotation.x = sin(_t * 7.0) * 0.25 if not flapping else -0.4
	if follow:
		var target := follow.global_position - follow.global_transform.basis.z * -1.2 + follow.global_transform.basis.x * 0.6
		target.y = follow.global_position.y
		var to := target - global_position
		to.y = 0.0
		_moving = to.length() > 0.4
		if _moving:
			global_position += to.normalized() * minf(to.length(), delta * 4.0)
			rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 8.0, 0.0, 1.0))
			_body.position.y = absf(sin(_t * 14.0)) * 0.08
		else:
			_body.position.y = 0.0
		global_position.y = lerpf(global_position.y, follow.global_position.y, clampf(delta * 6.0, 0.0, 1.0))
	elif not flapping:
		_body.position.y = absf(sin(_t * 2.0)) * 0.01


var _moving := false


func _wild_pick() -> void:
	_wild_target = Vector3(randf_range(yard.position.x, yard.end.x), global_position.y, randf_range(yard.position.y, yard.end.y))


## Kümes davranışı: gezinir, oyuncu 3 m'ye girince kanat çırparak kaçar; 0.9 m'de yakalanır (Tolga ise sayılır).
func _wild(delta: float) -> void:
	_catch_cd = maxf(0.0, _catch_cd - delta)
	var sc := get_tree().current_scene
	var pl: Player = sc.get("player") as Player if sc else null
	var speed := 0.6
	flapping = false
	if pl and not pl.frozen:
		var away := global_position - pl.global_position
		away.y = 0.0
		var d := away.length()
		if d < 0.9 and _catch_cd <= 0.0:
			_caught(pl)
			return
		if d < 3.0:
			speed = 3.1
			flapping = true
			_wild_target = global_position + away.normalized() * 1.5
			_wild_target.x = clampf(_wild_target.x, yard.position.x, yard.end.x)
			_wild_target.z = clampf(_wild_target.z, yard.position.y, yard.end.y)
	var to := _wild_target - global_position
	to.y = 0.0
	if to.length() < 0.2:
		if _wild_target == Vector3.ZERO or randf() < 0.02:
			_wild_pick()
		_body.position.y = 0.0
		return
	global_position += to.normalized() * minf(to.length(), delta * speed)
	rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 8.0, 0.0, 1.0))
	_body.position.y = absf(sin(_t * (18.0 if speed > 1.0 else 9.0))) * (0.12 if speed > 1.0 else 0.03)


func _caught(pl: Player) -> void:
	_catch_cd = 4.0
	Audio.sfx("cartoon_boing", -8.0)
	# Kanat çırpıp kümesin öbür ucuna kaçar
	var far := Vector3(yard.position.x + yard.size.x * randf(), global_position.y, yard.position.y + yard.size.y * randf())
	var tw := create_tween()
	tw.tween_property(self, "global_position", global_position + Vector3(0, 0.8, 0), 0.2)
	tw.tween_property(self, "global_position", far, 0.5)
	if pl.hand_style != "tolga" or GameState.autotest:
		return
	var n := int(GameState.flags.get("chicken_catches", 0)) + 1
	GameState.flags["chicken_catches"] = n
	if n >= 3:
		GameState.flags["chickens_3"] = true
	GameState.bump_stat("chicken_catches")
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud:
		hud.bark("SPK_TOLGA", "D_CHICKEN_CATCH_%d" % mini(n, 4), 2.5)
