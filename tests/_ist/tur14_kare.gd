extends Node3D
## TUR-14 (kare sahibi): yakın görünüş kusurları için ÖNCE|SONRA kareleri (tur13_kare'nin aynısı; aynı kesim: Bölüm 26
## Mesoteikhion, iç poterna + Romanos kanatları, dolgu 1). Yeni kadrajlar: Romanos kemeri şehirden 3 m / 10 m, kanat 1 m,
## dış kapı kemeri peribolostan, harpuşta 0,6 m / sur yolu boyu, sur yolu döşemesi (iç ve dış), surdan 12 m.
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur14_kare.tscn -- \
##     --out=DIR --set=kapi|harpusta|doseme|genel|hepsi [--gece]
## Her karede çizim çağrısı / ilkel: "TUR14KARE <ad> ciz=<n> ilkel=<n>".
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")
const SURDOKU := preload("res://scripts/world/ist/sur_doku.gd")

var out := "user://tur14_kare"
var acik := false
var gece := false
var setler := "hepsi"
var cam: Camera3D


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		var kv := s.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"acik": acik = true
			"gece": gece = true
			"set": setler = kv[1]
	DirAccess.make_dir_recursive_absolute(out)
	get_window().size = Vector2i(1280, 720)
	_isik()
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
	cer.name = "SurCerceve"
	cer.transform = sur.cerceve()
	cer.set_meta("ic_poterna", true)          # TUR-13: Bölüm 26'nın SurSetSahne.ic_poterna'sı ile aynı istek
	add_child(cer)
	var k: Dictionary = SurOyun.kur("mesoteikhion", {"ebeveyn": cer, "dunya": false, "asama": 2, "dolgu": 1.0, "kalas": true,
		"ic_poterna": true, "romanos_kanat": true, "romanos_kopru": false, "kapi_acik": acik})
	SURDOKU.uygula(k["kok"], 0)
	if gece:
		SURDOKU.gece_ver(1.0)
	if acik and k["parca"].has("ic_poterna"):
		k["parca"]["ic_poterna"].ac(true, false)
	for a2: String in OS.get_cmdline_user_args():
		if a2.begins_with("--gizle="):
			# tanı: adı verilen düğümleri gizle (gri blokların kaynağını bulmak için)
			for n in (k["kok"] as Node).find_children(a2.trim_prefix("--gizle="), "", true, false):
				if n is Node3D:
					(n as Node3D).visible = false
					print("TUR14GIZLE %s" % (k["kok"] as Node).get_path_to(n))
	for i in 30:
		await get_tree().process_frame
	var ro := sur.romanos()
	var pt := sur.ic_poterna()
	var px := sur.poterna_x()
	var dz1 := sur.dis_sur_z1()
	var ty := sur.teras_y()
	print("TUR14YER poterna=%s romanos=%s dis_poterna_x=%.2f dis_z1=%.2f teras=%.2f" % [pt, ro, px, dz1, ty])
	if OS.get_cmdline_user_args().has("--sonda"):
		# Romanos şehir yanı: kapının iki yanında iç surun dibine düşen ışınlar (gri blokların düğüm yolu)
		var sp := get_world_3d().direct_space_state
		for dx: float in [-6.0, -4.5, -3.5, -2.9, 2.9, 3.5, 4.5, 6.0]:
			for dz: float in [-0.2, -0.5, -0.9, -1.4]:
				var a := Vector3(float(ro["x"]) + dx, 4.0, float(ro["ic_z0"]) + dz)
				var q := PhysicsRayQueryParameters3D.create(a, a + Vector3(0, -6, 0))
				var hit := sp.intersect_ray(q)
				if not hit.is_empty():
					var c: Node = hit["collider"]
					print("TUR14SONDA dx=%.1f dz=%.1f y=%.2f yol=%s meta=%s" % [dx, dz, hit["position"].y, get_path_to(c), c.get_meta_list()])
		var pt2 := sur.ic_poterna()
		for dx: float in [-1.6, -1.0, 0.0, 1.0, 1.6, 2.5, 3.5]:
			for dz: float in [0.2, 0.5, 1.0, 2.0, 3.0]:
				var a := pt2 + Vector3(dx, 3.0, dz)
				var q := PhysicsRayQueryParameters3D.create(a, a + Vector3(0, -6, 0))
				var hit := sp.intersect_ray(q)
				if not hit.is_empty():
					print("TUR14SONDA_P dx=%.1f dz=%.1f y=%.3f yol=%s" % [dx, dz, hit["position"].y, String(get_path_to(hit["collider"])).get_file()])
		get_tree().quit()
		return
	var kam := {}
	var hepsi := setler == "hepsi"
	var yy := sur.dis_yol_y()
	var zz := sur.dis_yol_z()
	var iy := sur.ic_yol_y()
	var iz := sur.ic_yol_z()
	var rx := float(ro["x"])
	var rz := float(ro["ic_z0"])
	if hepsi or setler.contains("kapi"):
		kam["k1_kemer_sehirden_3m"] = [Vector3(rx + 0.8, 1.62, rz - 3.0), Vector3(rx, 4.6, rz)]
		kam["k2_kapi_sehirden_10m"] = [Vector3(rx + 1.6, 1.62, rz - 10.0), Vector3(rx, 3.6, rz)]
		kam["k3_kanat_1m"] = [Vector3(rx + 0.7, 1.62, rz - 0.5), Vector3(rx - 0.5, 1.4, rz + 0.6)]
		kam["k4_dis_kapi_peribolos_4m"] = [Vector3(rx - 1.0, 1.62, float(ro["dis_z0"]) - 4.0), Vector3(rx, 3.2, float(ro["dis_z0"]))]
	if hepsi or setler.contains("harpusta"):
		kam["h1_harpusta_06m"] = [Vector3(-14.6, yy + 1.62, zz - 0.2), Vector3(-14.6, yy + 1.3, zz + 1.4)]
		kam["h2_harpusta_yol_boyu"] = [Vector3(-18.0, yy + 1.62, zz - 0.6), Vector3(-6.0, yy + 1.2, zz + 0.4)]
		kam["h3_ic_sur_disler_2m"] = [Vector3(-22.0, iy + 1.62, iz - 1.2), Vector3(-19.0, iy + 1.3, iz + 1.2)]
	if hepsi or setler.contains("doseme"):
		kam["d1_dis_yol_doseme_15m"] = [Vector3(-12.0, yy + 1.62, zz - 0.4), Vector3(-10.6, yy, zz - 0.2)]
		kam["d2_ic_yol_doseme_3m"] = [Vector3(-26.0, iy + 1.62, iz - 0.3), Vector3(-23.0, iy, iz)]
	if hepsi or setler.contains("genel"):
		kam["g1_peribolostan_12m"] = [Vector3(-14.0, 1.62, float(ro["dis_z0"]) - 12.0), Vector3(-6.0, 5.0, float(ro["dis_z0"]))]
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
		var f := out.path_join("%s%s%s.jpg" % [ad, "_acik" if acik else "", "_gece" if gece else ""])
		img.save_jpg(f, 0.85)
		print("TUR14KARE %s ciz=%d ilkel=%d" % [ad, dc / 4, pr / 4])
	get_tree().quit()


func _isik() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3f7fc4") if not gece else Color("0a1424")
	sm.sky_horizon_color = Color("cfdde6") if not gece else Color("25344a")
	sm.ground_horizon_color = Color("cfc4aa") if not gece else Color("2a2a30")
	sm.ground_bottom_color = Color("7a6a50") if not gece else Color("101014")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.52 if not gece else 0.35
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.9
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, 150, 0) if not gece else Vector3(-34, 160, 0)
	sun.light_energy = 1.1 if not gece else 0.25
	sun.light_color = Color("ffe9c7") if not gece else Color("9fb4d8")
	sun.shadow_enabled = true
	add_child(sun)
	if gece:
		var l := OmniLight3D.new()
		l.light_color = Color("ffb060")
		l.light_energy = 2.0
		l.omni_range = 9.0
		l.name = "Fener"
		add_child(l)
		_fener = l


var _fener: OmniLight3D

func _process(_d: float) -> void:
	if _fener and cam:
		_fener.global_position = cam.global_position + Vector3(0.6, 0.4, 0)
