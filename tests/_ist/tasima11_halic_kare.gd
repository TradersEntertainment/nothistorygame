extends Node3D
## TAŞIMA 11: şehirdeki Haliç dilimi (IstHalicSur.build, K_SUR 1,0, yakın katman) tek başına, şehir kurucusunun yaptığı gibi
## sur taşı gölgelendiricisine çevrilmiş (sur_doku tur 1); gündüz; kameralar dilimin yerel çerçevesinde (deniz −z).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tasima11_halic_kare.tscn -- \
##     --out=DIR [--eskisur]
const SURDOKU := preload("res://scripts/world/ist/sur_doku.gd")

var out := "user://tasima11_halic"


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		if s.begins_with("--out="):
			out = s.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(out)
	get_window().size = Vector2i(1280, 720)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3f7fc4")
	sm.sky_horizon_color = Color("cfdde6")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.48
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.9
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, 200, 0)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	add_child(sun)
	Props.box(self, Vector3(200, 0.2, 80), Vector3(0, -0.1, 41.5), Color("8e7c5c"))
	_kos.call_deferred()


func _kos() -> void:
	var n := Node3D.new()
	add_child(n)
	IstHalicSur.build(n, 1.0, 0)
	SURDOKU.uygula(n, 1)
	var cam := Camera3D.new()
	cam.fov = 72.0
	cam.near = 0.05
	cam.far = 2000.0
	add_child(cam)
	cam.current = true
	var kam := {
		"s1_denizden": [Vector3(6, 2.5, -40), Vector3(0, 6, 0)],
		"s2_rihtim_yakin": [Vector3(8, 2.1, -4.2), Vector3(12.5, 3.0, -1.5)],
		"s3_yol_dis_yakin": [Vector3(-20, 10.65, 0.2), Vector3(-22.5, 10.0, -1.4)],
		"s4_kule_gecidi": [Vector3(-25, 10.65, 0), Vector3(-42.2, 10.3, 0)],
		"s5_kapi_sehirden": [Vector3(1.5, 1.7, 9), Vector3(0, 3.0, 1.5)],
		"s6_kule_teras": [Vector3(14.4, 15.7, 6.5), Vector3(14.4, 14.8, 0)],
	}
	for ad in kam:
		var v: Array = kam[ad]
		cam.global_position = v[0]
		cam.look_at(v[1], Vector3.UP)
		var dc := 0
		var pr := 0
		for i in 6:
			await RenderingServer.frame_post_draw
			if i >= 2:
				dc += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
				pr += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		get_viewport().get_texture().get_image().save_jpg(out.path_join("%s.jpg" % ad), 0.85)
		print("T11KARE %s ciz=%d ilkel=%d" % [ad, dc / 4, pr / 4])
	get_tree().quit()
