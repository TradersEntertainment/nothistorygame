extends Node3D
## TUR-10: sur YAKIN kareleri (oyuncu gözü, 0,5–3 m). Mesoteikhion kesimi (sur_oyun_demo ile aynı kurulum), ışık:
##   --gece : Bölüm 20/25'in ışığı (Night.environment(self, 0,006), ay SurSetSahne'deki açıda)
##   (yok)  : sur_oyun_demo'nun gündüz ışığı
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur10_yakin.tscn -- \
##     --out=DIR [--gece] [--onek=ONCE_]
## Kareler: y1 dış sur yolu dişi 0,6 m; y2 iç sur korkuluğu 1,5 m; y3 kule kapısı 2 m; y4 sur dibinden 2 m (iç sur dış
## yüzü, peribolostan); y5 dış sur yolu boyunca; y6 diş sırası üstten 1 m. Her karede çizim çağrısı / ilkel (TUR10YAKIN).
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")
const SURDOKU := preload("res://scripts/world/ist/sur_doku.gd")

var out := "user://tur10_yakin"
var gece := false
var onek := ""
var cam: Camera3D


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		var kv := s.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"gece": gece = true
			"onek": onek = kv[1]
	DirAccess.make_dir_recursive_absolute(out)
	get_window().size = Vector2i(1280, 720)
	if gece:
		var moon := Night.environment(self, 0.006)
		moon.rotation_degrees = Vector3(-34, 160, 0)
	else:
		_gunduz()
	cam = Camera3D.new()
	cam.fov = 75.0
	cam.near = 0.05
	cam.far = 4000.0
	add_child(cam)
	cam.current = true
	_kos.call_deferred()


func _kos() -> void:
	var sec := {"ebeveyn": self, "dunya": false, "uzak": true, "asama": 2, "dolgu": 0.5, "kalas": true, "poterna_acik": false}
	var k: Dictionary = SurOyun.kur("mesoteikhion", sec)
	var a: RefCounted = k["arayuz"]
	SURDOKU.uygula(k["kok"], 0)
	for i in 30:
		await get_tree().process_frame
	var d: Dictionary = a.d
	var gx: float = a.gx
	var zo1 := float(d["zo1"])
	var zi1 := float(d["zi1"])
	var OH := float(d["OH"])
	var HW := float(d["HW"])
	var PT := 0.45
	# dış sur mazgalı: gediğin +x yanında, kuleden uzak ilk açıklık
	var mz: Array = a.mazgallar("dis")
	var m1: Vector3 = mz[0]["p"]["yerel"]
	for m in mz:
		var p: Vector3 = m["p"]["yerel"]
		if p.x > gx + 12.0:
			m1 = p
			break
	var mi: Array = a.mazgallar("ic")
	var m2: Vector3 = mi[mi.size() / 2]["p"]["yerel"]
	for m in mi:
		var p: Vector3 = m["p"]["yerel"]
		if p.x > gx + 6.0:
			m2 = p
			break
	var ic_k: Array = a.kesim["kule"]["ic"]
	var kt: Array = ic_k[0]
	for t in ic_k:
		if float(t[0]) > gx:
			kt = t
			break
	var kx := float(kt[0]) - float(kt[1]) * 0.5
	var zd := zo1 - PT       # dış sur korkuluğunun iç yüzü
	var kam := {
		# m1 = iki diş arası açıklık; diş merkezi m1.x + 0.9 (yarım genişlik 0,5)
		"y1_dis_sur_disi_06m": [Vector3(m1.x + 0.2, OH + 1.62, zd - 0.6), Vector3(m1.x + 1.0, OH + 1.35, zo1 + 2.0)],
		"y2_ic_sur_korkulugu_15m": [Vector3(m2.x - 0.6, HW + 1.62, zi1 - PT - 1.5), Vector3(m2.x + 1.4, HW + 1.1, zi1)],
		"y3_kule_kapisi_2m": [Vector3(kx - 2.0, HW + 1.62, 0.2), Vector3(kx, HW + 1.2, 0.0)],
		"y4_sur_dibinden_2m": [Vector3(m2.x + 3.0, 1.62, zi1 + 2.0), Vector3(m2.x + 5.0, 3.2, zi1)],
		"y5_dis_sur_yolu_boyunca": [Vector3(m1.x - 1.0, OH + 1.62, a.zc_dis()), Vector3(m1.x + 12.0, OH + 1.0, zo1 - 0.2)],
		"y6_dis_sira_ustten_1m": [Vector3(m1.x - 0.5, OH + 2.3, zd - 1.0), Vector3(m1.x + 3.0, OH + 1.6, zo1)],
	}
	for ad: String in kam:
		var c: Array = kam[ad]
		cam.global_position = c[0]
		cam.look_at(c[1], Vector3.UP)
		for i in 10:
			await get_tree().process_frame
		var dc := 0.0
		var pr := 0.0
		for i in 3:
			await RenderingServer.frame_post_draw
			dc += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			pr += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		var img := get_viewport().get_texture().get_image()
		var f := "%s/%s%s%s.jpg" % [out, onek, "gece_" if gece else "gun_", ad]
		img.save_jpg(f, 0.85)
		print("TUR10YAKIN %s cizim=%.0f ilkel=%.0f kam=%s" % [f.get_file(), dc / 3.0, pr / 3.0, (c[0] as Vector3).snapped(Vector3.ONE * 0.01)])
	print("TUR10YAKIN BITTI")
	get_tree().quit(0)


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
	e.fog_enabled = true
	e.fog_light_color = Color("d6dcd8")
	e.fog_density = 0.0015
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.08
	e.adjustment_contrast = 1.05
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-36, 38, 0)
	sun.light_color = Color("ffe2b8")
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 140.0
	add_child(sun)
