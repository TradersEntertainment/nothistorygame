extends Node3D
## TUR-13 sergi: oyunun KENDİ kurucularından pavez (Assault.pavez_ag: Assault._pavises ve Bölüm 26o siperi ölçüleri),
## öküz arabası (Dressing.cart, birkaç tohum: Kit modeli dalı ve tahta araba dalı) ve Bölüm 26/26o burç sancağı (aynı
## satır: kumaş bayrak, direk). Sabit kameralar; 0,4 sn arayla iki kare (sancak dalgası). ÖNCE kopyasında pavez_ag yoksa
## eski kutu siper satırları kurulur (ÖNCE karesi için).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur13_sergi.tscn -- --out=DIR
var out := "user://tur13_sergi"
var cam: Camera3D


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		var kv := s.trim_prefix("--").split("=", true, 1)
		if kv[0] == "out":
			out = kv[1]
	DirAccess.make_dir_recursive_absolute(out)
	get_window().size = Vector2i(1280, 720)
	_isik()
	cam = Camera3D.new()
	cam.fov = 72.0
	cam.near = 0.05
	add_child(cam)
	cam.current = true
	_kos.call_deferred()


func _kos() -> void:
	var zemin := Props.solid(self, Vector3(80, 1, 80), Vector3(0, -0.5, 0), Color("7b8653"))
	Props.set_pattern(zemin, Color("7b8653"), "grass")
	# --- pavezler (sol: Assault._pavises ölçüsü ve dönüşü; sağ: 26o siperi)
	var A: Variant = load("res://scripts/level/assault.gd")
	var yeni := (A as GDScript).source_code.contains("static func pavez_ag")
	for i in 3:
		var x := -4.0 + i * 1.6
		var col: Color = [Color("7a5634"), Color("8a3a2e"), Color("3e5238")][i]
		if yeni:
			var mi := MeshInstance3D.new()
			mi.mesh = A.pavez_ag(1.1, 1.7, 0.1, col, -12.0)
			mi.material_override = Dressing._material()
			mi.transform = Transform3D(Basis(Vector3.RIGHT, deg_to_rad(-12.0)), Vector3(x, 0, 0))
			add_child(mi)
		else:
			var d := Dressing.new(7711)
			d.box(Vector3(1.1, 1.7, 0.1), Vector3(x, 0.85, 0), col, Vector3(-12, 0, 0))
			d.box(Vector3(0.14, 1.72, 0.12), Vector3(x, 0.86, -0.02), col.darkened(0.25), Vector3(-12, 0, 0))
			d.cyl(0.03, 1.6, Vector3(x, 0.7, 0.55), Color("4a3020"), Vector3(40, 0, 0), 4)
			d.build(self)
	var pv := Node3D.new()
	pv.position = Vector3(1.2, 0, 0)
	pv.rotation = Vector3(deg_to_rad(-12), 0.3, 0)
	add_child(pv)
	if yeni:
		var pc := Props.solid(pv, Vector3(1.3, 2.1, 0.12), Vector3(0, 1.05, 0), Color("6a4a2c"))
		var eski := pc.get_child(0)
		pc.remove_child(eski)
		eski.queue_free()
		var pm := MeshInstance3D.new()
		pm.mesh = A.pavez_ag(1.3, 2.1, 0.12, Color("8a3a2e"), -12.0)
		pm.material_override = Dressing._material()
		pm.position = Vector3(0, -1.05, 0)
		pc.add_child(pm)
	else:
		Props.solid(pv, Vector3(1.3, 2.1, 0.12), Vector3(0, 1.05, 0), Color("6a4a2c"))
		Props.box(pv, Vector3(1.35, 0.12, 0.16), Vector3(0, 1.7, 0.02), Color("4a3422"))
		Props.box(pv, Vector3(1.35, 0.12, 0.16), Vector3(0, 0.5, 0.02), Color("4a3422"))
		Props.box(pv, Vector3(0.45, 0.45, 0.02), Vector3(0, 1.2, -0.07), Color("b3262d"))
		Props.box(pv, Vector3(0.08, 1.6, 0.08), Vector3(0, 0.75, 0.5), Color("4a3422"), Vector3(-30, 0, 0))
	# --- arabalar (z 8 sırası): 6 tohum
	for i in 6:
		var d := Dressing.new(100 + i)
		d.at(Vector3(-7.5 + i * 3.0, 0, 9.0), 0.4)
		d.cart(Vector3.ZERO)
		d.build(self)
	# --- sancak (26/26o satırları; direk 4 m, kule tepesi yerine zemin)
	var banner := Node3D.new()
	banner.position = Vector3(0, 0, -6.0)
	add_child(banner)
	Props.cyl(banner, 0.05, 4.0, Vector3(0, 2.0, 0), Color("5a3e26"), Vector3.ZERO, 5)
	if ResourceLoader.exists("res://scripts/world/ist/kumas.gd") and FileAccess.get_file_as_string("res://scripts/chapter26.gd").contains("kumas.gd\").bayrak(banner"):
		preload("res://scripts/world/ist/kumas.gd").bayrak(banner, Vector3(0, 3.9, 0.03), Vector3.BACK, 1.8, 1.2, Color("b3262d"), [], 8, "Sancak").set_meta("flag", true)
	else:
		Props.box(banner, Vector3(0.04, 1.2, 1.8), Vector3(0, 3.3, 0.92), Color("b3262d"))
	for i in 20:
		await get_tree().process_frame
	var kam := {
		"s1_pavez_on_3m": [Vector3(-1.0, 1.62, -3.2), Vector3(-1.2, 0.9, 0)],
		"s2_pavez_arka_2m": [Vector3(-2.2, 1.62, 2.2), Vector3(-2.4, 0.8, 0)],
		"s3_pavez_26o_1m": [Vector3(1.6, 1.62, -1.5), Vector3(1.2, 1.1, 0)],
		"a1_araba_3m": [Vector3(-3.0, 1.62, 6.2), Vector3(-4.0, 0.7, 9.0)],
		"a2_araba_yandan_3m": [Vector3(1.6, 1.62, 6.8), Vector3(-0.5, 0.6, 9.3)],
		"a3_araba_12m": [Vector3(0.0, 1.62, -2.0), Vector3(0.0, 0.6, 9.0)],
		"b1_sancak_5m": [Vector3(4.0, 2.4, -3.0), Vector3(0, 3.3, -5.4)],
	}
	for ad in kam:
		var v: Array = kam[ad]
		cam.global_position = v[0]
		cam.look_at(v[1], Vector3.UP)
		for t in 2:
			var dc := 0
			var pr := 0
			for i in 4:
				await RenderingServer.frame_post_draw
				dc += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
				pr += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
			get_viewport().get_texture().get_image().save_jpg(out.path_join("%s%s.jpg" % [ad, "" if t == 0 else "_b"]), 0.85)
			print("TUR13SERGI %s%s ciz=%d ilkel=%d" % [ad, "" if t == 0 else "_b", dc / 4, pr / 4])
			if not ad.begins_with("b"):
				break
			await get_tree().create_timer(0.4).timeout
	get_tree().quit()


func _isik() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3f7fc4")
	sm.sky_horizon_color = Color("cfdde6")
	sm.ground_horizon_color = Color("cfc4aa")
	sm.ground_bottom_color = Color("7a6a50")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.52
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.9
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, 150, 0)
	sun.light_energy = 1.1
	sun.light_color = Color("ffe9c7")
	sun.shadow_enabled = true
	add_child(sun)
