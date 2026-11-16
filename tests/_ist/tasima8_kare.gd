extends Node3D
## TAŞIMA-8: Bölüm 26'nın yeni set eklerinin (iç poterna, Romanos kanatları) kareleri — bölüm çerçevesinde (SurSet.cerceve:
## gedik x 0, peribolos y 0, dış surun iç yüzü z 14). Bölüm kurulmaz; yalnız kesim + parçalar.
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tasima8_kare.tscn -- \
##     --out=DIR [--acik] [--kam="ad:x,y,z:bx,by,bz;..."]
## Her karede çizim çağrısı / ilkel (TASIMA8KARE).
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")
const SURDOKU := preload("res://scripts/world/ist/sur_doku.gd")

var out := "user://tasima8_kare"
var acik := false
var kamlar := ""
var cam: Camera3D


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		var kv := s.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"acik": acik = true
			"kam": kamlar = kv[1]
	DirAccess.make_dir_recursive_absolute(out)
	get_window().size = Vector2i(1280, 720)
	_gunduz()
	cam = Camera3D.new()
	cam.fov = 72.0
	cam.near = 0.05
	cam.far = 4000.0
	add_child(cam)
	cam.current = true
	_kos.call_deferred()


func _kos() -> void:
	var sur := SurSet.yeni("mesoteikhion")
	var cer := Node3D.new()
	cer.transform = sur.cerceve()
	add_child(cer)
	var k: Dictionary = SurOyun.kur("mesoteikhion", {"ebeveyn": cer, "dunya": false, "asama": 2, "dolgu": 1.0, "kalas": true,
		"ic_poterna": true, "romanos_kanat": true, "romanos_kopru": false, "kapi_acik": acik})
	SURDOKU.uygula(k["kok"], 0)
	if acik and k["parca"].has("ic_poterna"):
		k["parca"]["ic_poterna"].ac(true, false)
	for i in 30:
		await get_tree().process_frame
	var ro := sur.romanos()
	var pt := sur.ic_poterna()
	print("TASIMA8YER poterna=%s romanos=%s" % [pt, ro])
	var kam := {}
	if kamlar == "":
		kam["p1_poterna_onden"] = [pt + Vector3(-1.5, 1.62, 6.0), pt + Vector3(0, 1.2, 0)]
		kam["p2_poterna_yandan"] = [pt + Vector3(6.0, 1.62, 3.0), pt + Vector3(0, 1.0, 0)]
		kam["r1_romanos_sehirden"] = [Vector3(ro["x"], 1.62, float(ro["ic_z0"]) - 14.0), Vector3(ro["x"], 3.0, float(ro["ic_z0"]))]
		kam["r2_romanos_peribolostan"] = [Vector3(float(ro["x"]) + 10.0, 1.62, 7.0), Vector3(ro["x"], 2.0, 6.0)]
		kam["r3_romanos_koridor"] = [Vector3(ro["x"], 1.62, float(ro["dis_z0"]) - 1.0), Vector3(ro["x"], 1.6, float(ro["ic_z0"]))]
		kam["r4_romanos_disaridan"] = [Vector3(float(ro["x"]) + 4.0, sur.teras_y() + 1.62, float(ro["dis_z1"]) + 7.0), Vector3(ro["x"], 2.0, float(ro["dis_z1"]))]
	else:
		for t in kamlar.split(";", false):
			var p := t.split(":")
			var a := p[1].split(",")
			var b := p[2].split(",")
			kam[p[0]] = [Vector3(float(a[0]), float(a[1]), float(a[2])), Vector3(float(b[0]), float(b[1]), float(b[2]))]
	for ad in kam:
		var v: Array = kam[ad]
		cam.global_position = v[0]
		cam.look_at(v[1], Vector3.UP)
		var dc := 0
		var pr := 0
		for i in 4:
			await RenderingServer.frame_post_draw
			dc += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			pr += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		var img := get_viewport().get_texture().get_image()
		var f := out.path_join("%s%s.jpg" % [ad, "_acik" if acik else ""])
		img.save_jpg(f, 0.85)
		print("TASIMA8KARE %s ciz=%d ilkel=%d" % [ad, dc / 4, pr / 4])
	get_tree().quit()


func _gunduz() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3f7fc4")
	sm.sky_horizon_color = Color("cfdde6")
	sm.ground_horizon_color = Color("b8c4c8")
	sm.ground_bottom_color = Color("5a6a70")
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
	sun.rotation_degrees = Vector3(-42, 150, 0)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	add_child(sun)
