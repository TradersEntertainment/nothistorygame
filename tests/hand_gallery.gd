extends Node3D
## El tutuş galerisi (HandRig): her tutuş, eşyasıyla, üç açıdan çekilir: oyuncunun gözü (fp), sağdan yan (side),
## önden-alttan (front). Oyuna bağlamadan tutuş ayarlamak ve görsel ajanla denetlemek için.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 res://tests/hand_gallery.tscn -- --out=DİZİN [--only=phone,lighter]

const ITEMS := ["remote", "phone", "lighter", "book", "chickpeas", "powerbank", "tape", "thermos", "selfie", "cologne", "cube"]
const HAND_BASE := Vector3(0.24, -0.19, -0.4)       # Player._hand_base
const HAND_ROT := Vector3(12, -14, 0)


func _ready() -> void:
	var out := "user://hand_gallery"
	var only: Array = []
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.trim_prefix("--out=")
		elif a.begins_with("--only="):
			only = Array(a.trim_prefix("--only=").split(","))
	DirAccess.make_dir_recursive_absolute(out)
	_run.call_deferred(out, only)


func _shot(path: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(path)


func _run(out: String, only: Array) -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("9fc2e0")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("d8e2ee")
	e.ambient_light_energy = 0.45
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_energy = 0.9
	add_child(sun)
	Props.box(self, Vector3(60, 0.2, 60), Vector3(0, -0.1, 0), Color("6f7a5a"))
	Props.box(self, Vector3(60, 3, 0.3), Vector3(0, 1.5, -14), Color("7a6a58"))
	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.6, 0)
	cam.fov = 72.0
	cam.near = 0.02
	add_child(cam)
	var hand := Node3D.new()
	hand.position = HAND_BASE
	hand.rotation_degrees = HAND_ROT
	cam.add_child(hand)
	var rig := HandRig.new()
	hand.add_child(rig)
	var side := Camera3D.new()
	side.fov = 40.0
	side.near = 0.01
	cam.add_child(side)
	await get_tree().process_frame
	e.glow_enabled = false
	e.ssil_enabled = false
	e.ssao_enabled = false
	e.adjustment_enabled = false
	e.fog_enabled = false
	for id in ITEMS:
		if not only.is_empty() and not id in only:
			continue
		for c in rig.socket.get_children():
			c.queue_free()
		if OS.has_environment("RIG"):
			var v := OS.get_environment("RIG").split(",")
			rig.rig_override = Vector3(float(v[0]), float(v[1]), float(v[2]))
		rig.pose(id)
		_env_overrides(rig)
		var m := _model(id)
		Props.strip_outlines(m)          # oyunda da soyuluyor (Player.select_item)
		rig.attach(m)
		cam.make_current()
		await _shot(out.path_join(id + "_fp.png"))
		# Yan ve ön kamera avuca kilitli (el tutuşa göre kayabiliyor)
		var hc := cam.to_local(rig.socket.global_position)
		side.position = hc + Vector3(0.3, 0.06, 0.02)
		side.look_at(rig.socket.global_position, Vector3.UP)
		side.make_current()
		await _shot(out.path_join(id + "_side.png"))
		side.position = hc + Vector3(-0.08, -0.08, -0.28)
		side.look_at(rig.socket.global_position, Vector3.UP)
		await _shot(out.path_join(id + "_front.png"))
		print("HAND_GALLERY ", id)
	# Sol el (Player._build_free_hand): sağ elin aynası, kıvrılma üç düzeyde
	if only.is_empty() or "left" in only:
		hand.visible = false
		var fh := Node3D.new()
		fh.position = Vector3(-0.2, -0.17, -0.38)
		fh.rotation_degrees = Vector3(12, 14, 0)
		cam.add_child(fh)
		var lr := HandRig.new()
		lr.position = Vector3(-0.02, -0.05, 0.0)
		lr.scale = Vector3(-1, 1, 1)
		fh.add_child(lr)
		await get_tree().process_frame
		lr.palm.rotation_degrees = Vector3.ZERO
		for c in [-15.0, -70.0, -85.0]:
			lr.curl(c)
			cam.make_current()
			await _shot(out.path_join("left%d_fp.png" % int(-c)))
		print("HAND_GALLERY left")
	get_tree().quit()


## Ayar denemesi (yeniden derlemeden): G_ROOT=x,y,z,rx,ry,rz  G_AT=x,y,z  G_ROT=x,y,z  G_S=ölçek
func _env_overrides(rig: HandRig) -> void:
	var v := func(k: String) -> PackedFloat64Array:
		var a := PackedFloat64Array()
		for x in OS.get_environment(k).split(","):
			a.append(float(x))
		return a
	if OS.has_environment("G_ROOT"):
		var r: PackedFloat64Array = v.call("G_ROOT")
		rig.position = Vector3(r[0], r[1], r[2])
		rig.rotation_degrees = Vector3(r[3], r[4], r[5])
	if OS.has_environment("G_AT"):
		var a: PackedFloat64Array = v.call("G_AT")
		rig.socket.position = Vector3(a[0], a[1], a[2])
	if OS.has_environment("G_ROT"):
		var b: PackedFloat64Array = v.call("G_ROT")
		rig.socket.rotation_degrees = Vector3(b[0], b[1], b[2])
	if OS.has_environment("G_NOTHUMB"):
		(rig.thumb[0] as Node3D).visible = false
	if OS.has_environment("G_NOFING"):
		for f in rig.fingers:
			(f[0] as Node3D).visible = false
	if OS.has_environment("G_S"):
		rig.socket.scale = Vector3.ONE * float(OS.get_environment("G_S"))


func _model(id: String) -> Node3D:
	if id != "remote":
		return Items.build(id)
	# Player._build_hand'deki kumanda (TV kumandası + telsiz + bant + tuşlar)
	var r := Node3D.new()
	Props.box(r, Vector3(0.05, 0.022, 0.15), Vector3(0, -0.012, -0.07), Color("1f2229"))
	Props.box(r, Vector3(0.058, 0.035, 0.1), Vector3(0, -0.04, -0.06), Color("7d8794"))
	Props.cyl(r, 0.005, 0.12, Vector3(0.018, -0.02, -0.12), Color("2b2f3a"), Vector3(-60, 0, 0), 4)
	Props.box(r, Vector3(0.064, 0.064, 0.022), Vector3(0, -0.026, -0.05), Color("c98a3a"))
	Props.box(r, Vector3(0.064, 0.064, 0.022), Vector3(0, -0.026, -0.1), Color("c98a3a"), Vector3(0, 0, 4))
	for i in 3:
		Props.box(r, Vector3(0.008, 0.004, 0.008), Vector3(-0.012 + i * 0.012, 0.0, -0.035), Color("9aa0a8"))
	Props.cyl(r, 0.011, 0.008, Vector3(0, 0.001, -0.125), Color("ff3b30"), Vector3.ZERO, 8, -1.0, 1.5)
	return r
