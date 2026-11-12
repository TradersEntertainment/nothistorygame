class_name Cat
extends Node3D
## Galata'nın kayıp kedisi: bir köşede oturur; oyuncu yaklaşınca peşine takılır, sahibine (grup "cat_owner")
## yaklaşınca yanına oturur ve "cat_returned" bayrağı açılır (yan görev).

const CK = preload("res://scripts/world/ist/canli_kit.gd")

var _t := 0.0
var _body: Node3D
var _tail: Node3D
var _state := "hiding"     # hiding, following, home
var _owner_node: Node3D


func _ready() -> void:
	_t = randf() * 4.0
	_body = Node3D.new()
	add_child(_body)
	# CANLI (kalite notu 32): kedi canli_kit'ten (kesit halkalı ince gövde, yuvarlak baş, dik kulak, kıvrık kuyruk)
	var kit: Dictionary = CK.dugum("kedi", {"renk": Color("d8843a"), "lod": 0, "birlestir": ["kulak"], "golge": false})
	_body.add_child(kit["root"])
	_tail = (kit["p"] as Dictionary)["kuyruk"]


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
