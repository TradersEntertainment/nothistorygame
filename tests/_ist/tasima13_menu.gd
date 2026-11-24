extends Node
## TAŞIMA-13 teşhis: 31o (v2 kurulu) açıkken menüye (chapter1) geçilince kalan düğümler. Önce chapter1 (taban), sonra 31o
## v2 kurulana kadar + 5 sn, sonra chapter1; düğüm/sahipsiz sayısı ve sahipsizlerin türleri.
##   godot --headless --path . res://tests/_ist/tasima13_menu.tscn [-- --eskisur=31o]
## Satırlar: T13MENU …

var runner := false


func _ready() -> void:
	if not runner:
		# sahne değişince bu düğüm silinir: sürücü kökte ayrı bir kopya (menu_return gibi)
		var r: Node = load("res://tests/_ist/tasima13_menu.gd").new()
		r.runner = true
		r.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child.call_deferred(r)
		return
	GameState.settings["auto_advance"] = false
	_kos.call_deferred()


func _say(ad: String) -> void:
	print("T13MENU %s dugum=%d sahipsiz=%d" % [ad, int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))])


func _bekle(sn: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(sn * 1000.0):
		await get_tree().process_frame


func _kos() -> void:
	get_tree().change_scene_to_file("res://scenes/chapter1.tscn")
	await _bekle(6.0)
	_say("taban_menu")
	get_tree().change_scene_to_file("res://scenes/chapter31o.tscn")
	var t0 := Time.get_ticks_msec()
	await _bekle(1.0)
	while get_tree().current_scene != null and get_tree().current_scene.get("city") == null and Time.get_ticks_msec() - t0 < 200000:
		await get_tree().process_frame
	await _bekle(5.0)
	_say("31o_kurulu")
	get_tree().change_scene_to_file("res://scenes/chapter1.tscn")
	await _bekle(6.0)
	_say("menuye_donus")
	Node.print_orphan_nodes()
	get_tree().quit()
