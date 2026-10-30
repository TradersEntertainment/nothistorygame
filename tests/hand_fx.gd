extends Node3D
## Eldeki eşya eylemleri galerisi (gerçek Player): telefon ekranının sekmeleri, leblebi yeme ve verme (taneler
## keseden çıkar). Kareler --out=DİZİN altına: phone_<sekme>.png, eat_<n>.png, give_<n>.png.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 res://tests/hand_fx.tscn -- --out=DİZİN

var out := "user://hand_fx"


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(out)
	_run.call_deferred()


func _shot(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(out.path_join(name + ".png"))


func _run() -> void:
	GameState.bag.assign(["phone", "chickpeas", "lighter"])
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("9fc2e0")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("d8e2ee")
	e.ambient_light_energy = 0.45
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	add_child(sun)
	var floor := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(40, 0.2, 40)
	cs.shape = bs
	floor.add_child(cs)
	floor.position = Vector3(0, -0.1, 0)
	add_child(floor)
	Props.box(self, Vector3(40, 0.2, 40), Vector3(0, -0.1, 0), Color("6f7a5a"))
	Props.box(self, Vector3(40, 3, 0.3), Vector3(0, 1.5, -10), Color("7a6a58"))
	var hud := Hud.new()
	add_child(hud)
	hud.fade_to(0.0, 0.01)
	var p := Player.new()
	add_child(p)
	p.global_position = Vector3(0, 0.05, 0)
	await get_tree().create_timer(0.8).timeout
	hud.set_objective("Masadaki dosyayı al.")
	p.select_item(1, true)                    # telefon
	await get_tree().create_timer(0.8).timeout
	var ps := p._held_model.get_node_or_null("PhoneScreen") as PhoneScreen
	print("HAND_FX phone_screen=", ps != null)
	for t in ["notes", "map", "msg"]:
		if ps:
			ps.tab = t
			ps._t = 0.0
			ps._draw()
		await get_tree().create_timer(0.3).timeout
		await _shot("phone_" + t)
	if ps:
		ps.show_torch(2.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("phone_torch")
	p.select_item(2, true)                    # leblebi
	await get_tree().create_timer(0.8).timeout
	p._self_use("chickpeas", hud)
	for k in 10:
		await _shot("eat_%d" % k)
	await get_tree().create_timer(1.5).timeout
	GameState.spend("chickpeas", "test_give")
	for k in 12:
		await _shot("give_%d" % k)
		if OS.has_environment("FX_DBG"):
			for b in get_children() + p.camera.get_children():
				if b.has_meta("transient") and b.get_child_count() > 0:
					var g: Node3D = b.get_child(0)
					print("FXDBG k=%d vis=%s pos_cam=%s" % [k, g.is_visible_in_tree(), p.camera.to_local(g.global_position)])
	print("HAND_FX done")
	get_tree().quit()
