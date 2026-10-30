class_name HeldCycle
extends Node
## --heldcycle: oyuncunun elindeki eşya 3 sn'de bir sıradakine geçer (kumanda, çantadaki eşyalar). Tutuşları gerçek
## bölüm ışığında görüntülemek için (tests/visual_run.sh ... --heldcycle ya da elle).

var _t := 4.0
var _i := 0


func _init() -> void:
	name = "HeldCycle"
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	_t -= delta
	if _t > 0.0:
		return
	_t = 3.0
	var sc := get_tree().current_scene
	var p: Player = sc.get("player") as Player if sc else null
	if p == null or not p.is_inside_tree() or p.hand_style != "tolga":
		return
	_i = (_i + 1) % (GameState.bag.size() + 1)
	p.show_remote(true)
	p.select_item(_i, true)
	print("HELDCYCLE item=%s" % (p.held_item() if _i > 0 else "remote"))
