class_name Cat
extends Node3D
## Galata'nın kayıp kedisi: bir köşede oturur; oyuncu yaklaşınca peşine takılır, sahibine (grup "cat_owner")
## yaklaşınca yanına oturur ve "cat_returned" bayrağı açılır (yan görev).

var _t := 0.0
var _body: Node3D
var _tail: Node3D
var _state := "hiding"     # hiding, following, home
var _owner_node: Node3D


func _ready() -> void:
	_t = randf() * 4.0
	_body = Node3D.new()
	add_child(_body)
	var fur := Color("d8843a")
	Props.ball(_body, 0.14, Vector3(0, 0.2, 0), fur, Vector3(0.9, 0.85, 1.5), 8)
	var head := Node3D.new()
	head.position = Vector3(0, 0.32, 0.2)
	_body.add_child(head)
	Props.ball(head, 0.1, Vector3.ZERO, fur, Vector3.ONE, 8)
	for s in [-1, 1]:
		Props.prism(head, Vector3(0.05, 0.07, 0.03), Vector3(s * 0.055, 0.1, 0), fur, Vector3.ZERO)
		Props.ball(head, 0.014, Vector3(s * 0.04, 0.02, 0.09), Color("2a3a1a"), Vector3.ONE, 4)
		for k in 2:
			Props.cyl(_body, 0.02, 0.18, Vector3(s * 0.06, 0.09, -0.12 + k * 0.24), fur.darkened(0.1), Vector3.ZERO, 4)
	Props.ball(head, 0.015, Vector3(0, -0.01, 0.1), Color("d86a6a"), Vector3.ONE, 4)
	_tail = Node3D.new()
	_tail.position = Vector3(0, 0.26, -0.2)
	_body.add_child(_tail)
	Props.cyl(_tail, 0.02, 0.28, Vector3(0, 0.12, -0.04), fur, Vector3(-30, 0, 0), 4)


func _process(delta: float) -> void:
	_t += delta
	_tail.rotation.z = sin(_t * (6.0 if _state == "following" else 2.0)) * 0.5
	if _owner_node == null:
		_owner_node = get_tree().get_first_node_in_group("cat_owner") as Node3D
	var sc := get_tree().current_scene
	var pl: Player = sc.get("player") as Player if sc else null
	match _state:
		"hiding":
			_body.position.y = absf(sin(_t * 1.5)) * 0.01
			if pl and pl.global_position.distance_to(global_position) < 1.6:
				_state = "following"
				Audio.sfx("ui_confirm", -10.0, 1.6)
				var hud := get_tree().get_first_node_in_group("hud") as Hud
				if hud:
					hud.bark("SPK_TOLGA", "D_CAT_FOUND", 3.0)
		"following":
			if pl == null:
				return
			var target := pl.global_position + pl.global_transform.basis.z * 1.0 + pl.global_transform.basis.x * 0.5
			var to := target - global_position
			to.y = 0.0
			if to.length() > 0.4:
				global_position += to.normalized() * minf(to.length(), delta * 4.5)
				rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 8.0, 0.0, 1.0))
				_body.position.y = absf(sin(_t * 12.0)) * 0.05
			global_position.y = lerpf(global_position.y, pl.global_position.y, clampf(delta * 6.0, 0.0, 1.0))
			if _owner_node and _owner_node.global_position.distance_to(global_position) < 3.6:
				_state = "home"
				GameState.flags["cat_returned"] = true
				var hud := get_tree().get_first_node_in_group("hud") as Hud
				if hud:
					hud.bark("SPK_KID", "NPC_KID_THANKS_1", 4.5)
				if _owner_node.has_method("emote"):
					_owner_node.emote("cheer")
		"home":
			if _owner_node:
				var spot := _owner_node.global_position + Vector3(0.6, 0, 0.5)
				global_position = global_position.lerp(Vector3(spot.x, global_position.y, spot.z), clampf(delta * 3.0, 0.0, 1.0))
			_body.position.y = 0.0
