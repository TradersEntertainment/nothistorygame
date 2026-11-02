extends Node3D
## Boşta duran karakter galerisi: her kıpırdanma (Rig.FIDGETS) zorla gösterilir, bir de oyuncuya bakış.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 res://tests/idle_gallery.tscn -- --out=DİZİN
var out := "user://idle_gallery"


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(out)
	_run.call_deferred()


func _shot(n: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(out.path_join(n + ".png"))


func _run() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("9fc2e0")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("d8e2ee")
	e.ambient_light_energy = 0.5
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	add_child(sun)
	Props.box(self, Vector3(30, 0.2, 30), Vector3(0, -0.1, 0), Color("6f7a5a"))
	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.3, 3.0)
	add_child(cam)
	cam.look_at(Vector3(0, 1.1, 0))
	cam.make_current()
	var people: Array[Person] = []
	var looks := [{"coat": Color("8a6a4a"), "hat": "turban", "beard": true}, {"coat": Color("2f5fa8"), "hat": "bork"},
		{"coat": Color("6a3a2a"), "apron": Color("d8c8a8")}]
	for i in 3:
		var p := Person.new(looks[i])
		p.set_meta("no_chat", true)
		add_child(p)
		p.position = Vector3(-1.4 + i * 1.4, 0, 0)
		p.rotation.y = 0.0
		people.append(p)
	await get_tree().create_timer(1.0).timeout
	for k in Rig.FIDGETS.size():
		for p in people:
			p.rig._fid_kind = k
			p.rig._fid_left = 99.0
		await get_tree().create_timer(1.2).timeout
		await _shot("fidget_%d" % k)
	print("IDLE_GALLERY done")
	get_tree().quit()
