extends SceneTree
## Görsel tur. xvfb-run godot --path . -s tests/visual_tour.gd -- OUTDIR res://scenes/chapterN.tscn VARIANT [MAX]
## Görsel tur: autotest akışında her yeni hedefte ve her 4. yeni altyazıda oyuncu bakışından kare (en çok MAX).
func _initialize() -> void:
	_run()

func _run() -> void:
	var a := OS.get_cmdline_user_args()
	var out: String = a[0]
	DirAccess.make_dir_recursive_absolute(out)
	var gs = root.get_node("GameState")
	gs.autotest = true
	gs.autotest_variant = a[2]
	var mx := int(a[3]) if a.size() > 3 else 12
	change_scene_to_file(a[1])
	await create_timer(1.0).timeout
	var n := 0
	var last_obj := ""
	var last_sub := ""
	var subs := 0
	var t := 0.0
	var start_scene = null
	while t < 600.0 and n < mx:
		await process_frame
		t += 0.016
		var sc = current_scene
		if sc == null or not ("hud" in sc) or sc.hud == null or not ("player" in sc) or sc.player == null:
			continue
		if start_scene == null:
			start_scene = sc
		elif sc != start_scene:
			break
		if sc.hud._fade.color.a > 0.5:
			continue
		var why := ""
		var obj: String = sc.hud._objective.text if sc.hud._objective_box.visible else ""
		var ok := obj
		for d in "0123456789":
			ok = ok.replace(d, "")
		if ok != "" and ok != last_obj:
			last_obj = ok
			why = "obj"
		var sub: String = sc.hud._sub_text.text if sc.hud._sub_box.visible else ""
		if sub != "" and sub != last_sub:
			last_sub = sub
			subs += 1
			if subs % 4 == 1:
				why = "sub"
		if why == "":
			continue
		var ts := Engine.time_scale
		Engine.time_scale = 0.02
		for f in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_viewport().get_texture().get_image().save_png(out + "/%02d_%s.png" % [n, why])
		print("TOUR %02d %s | %s | %s" % [n, why, obj.substr(0, 60), sub.substr(0, 80)])
		n += 1
		Engine.time_scale = ts
	quit()
