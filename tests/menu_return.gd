extends Node
## Ana menüye dönüş testi: bölümü açar, MR_AFTER sn sonra duraklatma menüsünden "Ana menü"yü seçer (Hud._set_paused'ın
## gerçek yolu), menü kurulunca aynı bölüme yeniden girip bir kez daha döner. Menü sahnesi açılmazsa, düğüm sayısı
## turdan tura büyürse (kalıntı) ya da betik hatası olursa düşer. Kullanım: --path . res://tests/menu_return.tscn -- --chapter=26
var after := float(OS.get_environment("MR_AFTER")) if OS.has_environment("MR_AFTER") else 4.0
var hold := float(OS.get_environment("MR_HOLD")) if OS.has_environment("MR_HOLD") else 6.0
var runner := false


func _ready() -> void:
	if runner:
		_run.call_deferred()
		return
	# Sahne değişince bu düğüm silinir: sürücü kökte ayrı bir kopya
	var r: Node = load("res://tests/menu_return.gd").new()
	r.runner = true
	r.name = "MenuReturnRunner"
	r.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child.call_deferred(r)
	add_child(preload("res://scripts/boot.gd").new())


func _run() -> void:
	var start := ""
	var counts: Array[int] = []
	var ok := true
	for i in 2:
		await _wait(after)
		var sc := get_tree().current_scene
		if start == "" and sc:
			start = sc.scene_file_path
		var hud := get_tree().get_first_node_in_group("hud")
		if hud == null or not hud.has_method("_set_paused"):
			print("MENURETURN FAIL: bölümde Hud yok (%s)" % start)
			get_tree().quit(1)
			return
		hud.call("_set_paused", true)
		await get_tree().process_frame
		var m = hud.get("_menu")
		if m == null:
			print("MENURETURN FAIL: duraklatma menüsü açılmadı")
			get_tree().quit(1)
			return
		m.picked.emit("main_menu", 0)
		await _wait(hold)
		sc = get_tree().current_scene
		var n := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
		counts.append(n)
		print("MENURETURN round=%d scene=%s nodes=%d orphans=%d" % [i, sc.scene_file_path if sc else "?", n,
			int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))])
		if sc == null or sc.scene_file_path != "res://scenes/chapter1.tscn":
			ok = false
		if i == 0:
			GameState.change_scene(start)
	# İkinci dönüşte sahne birincisinden belirgin büyükse eski bölümden kalıntı var
	if counts.size() == 2 and counts[1] > counts[0] + 600:
		print("MENURETURN kalıntı: %d → %d düğüm" % counts)
		ok = false
	print("MENURETURN %s from=%s" % ["PASS" if ok else "FAIL", start])
	get_tree().quit(0 if ok else 1)


func _wait(s: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(s * 1000.0):
		await get_tree().process_frame
