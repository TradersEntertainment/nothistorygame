extends Node
## G7: bölüm sahnesinin açılış süresi (sahne düğümünün ağaca eklenişi = _ready/kurulum ve ilk kare), n kez.
## Kullanım: godot --headless --path . res://tests/sonda_load_g7.tscn -- --scene=chapter10l [--n=5]
## Çıktı: "LOADG7 scene=.. i=.. ready_ms=.. frame1_ms=.."  (tests/load_time.gd yerine: o, ağaç meşgulken add_child'da başarısız oluyor)

func _ready() -> void:
	var sc := "chapter10l"
	var n := 5
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--scene="):
			sc = a.trim_prefix("--scene=")
		elif a.begins_with("--n="):
			n = int(a.trim_prefix("--n="))
	GameState.autotest = true
	await get_tree().process_frame
	var ps := load("res://scenes/%s.tscn" % sc) as PackedScene
	for i in n:
		var inst := ps.instantiate()
		var t0 := Time.get_ticks_usec()
		get_tree().root.add_child(inst)
		var t1 := Time.get_ticks_usec()
		await get_tree().process_frame
		var t2 := Time.get_ticks_usec()
		print("LOADG7 scene=%s i=%d ready_ms=%.2f frame1_ms=%.2f" % [sc, i, (t1 - t0) / 1000.0, (t2 - t1) / 1000.0])
		inst.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	get_tree().quit()
