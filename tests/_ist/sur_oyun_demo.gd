extends Node3D
## SUR OYUN gösterim sahnesi (pencereli): Mesoteikhion kesimi, bütün parçalar yerinde (poterna açık, kalas köprü,
## 3 dayalı merdivende tırmanan azaplar, gedik 2. aşamada (kazık/fıçı), hendek dolgusu yarım).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/sur_oyun_demo.tscn -- \
##     --out=DIR [--gece] [--mod=demo|once|sonra|olc]
## demo : 10 gündüz karesi (--gece ile 2 gece karesi)        → DIR/<no>_<ad>.jpg (1280×720, jpg 85)
## once : ÖNCE karesi: şehirdeki dilimin aynısı (kanca yok, parça yok, 4e etek düzeltmesi kapalı) 4 kamera
## sonra: SONRA karesi: bütün parçalar + kancalar + 4e, aynı 4 kamera
## olc  : 4 bakışta çizim çağrısı / ilkel sayısı: yeni kesim (uzak katmanlı) ve eski LandWalls seti   → SUROLC satırları
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")
const CLIMB := preload("res://scripts/npc/climb_anim.gd")
const SURDOKU := preload("res://scripts/world/ist/sur_doku.gd")
const OTAG := preload("res://scripts/world/ist/sur_oturtma_ag.gd")

var out := "user://sur_oyun_demo"
var gece := false
var mod := "demo"
var cam: Camera3D
var a: RefCounted
var kok: Node3D


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		var kv := s.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"gece": gece = true
			"mod": mod = kv[1]
	DirAccess.make_dir_recursive_absolute(out)
	get_window().size = Vector2i(1280, 720)
	_gok()
	cam = Camera3D.new()
	cam.fov = 70.0
	cam.near = 0.1
	cam.far = 4000.0
	add_child(cam)
	cam.current = true
	_kos.call_deferred()


func _kos() -> void:
	if mod == "olc":
		await _olc()
		get_tree().quit(0)
		return
	var sec := {"ebeveyn": self, "dunya": false, "uzak": true, "asama": 2, "dolgu": 0.5, "kalas": true, "poterna_acik": true, "merdiven": [0, 1, 2]}
	if mod == "once":
		OTAG.merdiven_duzelt = false
		sec = {"ebeveyn": self, "dunya": false, "uzak": true, "parca": false, "kanca": false}
	var t0 := Time.get_ticks_msec()
	var k: Dictionary = SurOyun.kur("mesoteikhion", sec)
	print("SURDEMO kur_ms=%d %s" % [Time.get_ticks_msec() - t0, k["ms"]])
	a = k["arayuz"]
	kok = k["kok"]
	SURDOKU.uygula(kok, 0)
	var gd = load("res://scripts/world/ist/gorsel_dil.gd")
	gd.kur(self)
	if mod != "once":
		_tirmananlar(k["parca"])
	for i in 30:
		await get_tree().process_frame
	var d: Dictionary = a.d
	var gx: float = a.gx
	var zo0 := float(d["zo0"])
	var zo1 := float(d["zo1"])
	var zm0 := float(d["zm0"])
	var zm1 := float(d["zm1"])
	var OH := float(d["OH"])
	var zc: float = a.zc_dis()
	var yt: float = a.y_teras()
	var yo: float = a.y_ova()
	var dy: float = a.dy
	var pot := float(a.poterna()["x"])
	var dm: Dictionary = a.dayamalar()[1]
	var ay: Vector3 = dm["ayak"]["yerel"]
	var kam := {
		"01_ovadan": [Vector3(gx + 22.0, yo + 1.7, zm1 + 38.0), Vector3(gx + 4.0, 3.0, zo1)],
		"02_hendek_kiyisindan": [Vector3(gx + 15.0, yo + 1.7, zm1 + 1.6), Vector3(gx - 2.0, dy - 3.5, zm0 + 6.0)],
		"03_kopru_ustunden": [Vector3(pot, dy + 1.7, (zm0 + zm1) * 0.5 + 4.0), Vector3(pot + 1.0, -0.5, zo1)],
		"04_merdiven_dibinden": [Vector3(ay.x + 3.0, yt + 1.6, ay.z + 3.2), Vector3(ay.x - 0.5, OH + 0.5, zo1)],
		"05_sur_yolundan_asagi": [Vector3(ay.x + 7.0, OH + 2.6, zo1 - 0.6), Vector3(ay.x - 3.0, yt, zm0 + 1.0)],
		"06_peribolostan": [Vector3(gx + 16.0, 1.6, zo0 - 6.5), Vector3(gx, 1.4, zo0 + 1.0)],
		"07_gedikten": [Vector3(gx + 0.5, 1.3 + 1.7, zc), Vector3(gx + 2.0, dy - 2.0, zm1 + 6.0)],
		"08_poternadan": [Vector3(pot - 0.3, 1.6, zo0 - 4.0), Vector3(pot + 0.3, 0.6, zm0)],
		"09_havadan_gedik": [Vector3(gx + 46.0, 42.0, zm1 + 40.0), Vector3(gx + 6.0, 0.0, zo1 + 4.0)],
		"10_havadan_kesim": [Vector3(-30.0, 70.0, -60.0), Vector3(-30.0, 0.0, 28.0)],
	}
	var adlar: Array = kam.keys()
	if gece:
		adlar = ["01_ovadan", "06_peribolostan"]
	if mod == "once" or mod == "sonra":
		adlar = ["01_ovadan", "06_peribolostan", "09_havadan_gedik", "05_sur_yolundan_asagi"]
	for ad: String in adlar:
		var c: Array = kam[ad]
		cam.global_position = c[0]
		cam.look_at(c[1], Vector3.UP)
		for i in 12:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		var dosya := "%s/%s%s%s.jpg" % [out, ("gece_" if gece else ""), ("%s_" % mod.to_upper() if mod in ["once", "sonra"] else ""), ad]
		img.save_jpg(dosya, 0.85)
		var vp := get_viewport()
		print("SURDEMO kare %s %dx%d cizim=%d ilkel=%d" % [dosya.get_file(), img.get_width(), img.get_height(),
			vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME),
			vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME)])
	print("SURDEMO BITTI")
	get_tree().quit(0)


## Üç dayalı merdivende tırmanan azaplar (ortak tırmanma animasyonu, basamak basamak)
func _tirmananlar(parca: Dictionary) -> void:
	var i := 0
	for m in parca.get("merdiven", []):
		var renk: Color = [Color("b3262d"), Color("6a4a3a"), Color("2f5fa8")][i % 3]
		for j in 2:
			var s := Soldier.new(renk, "stand", ["azap", "bork"][j])
			s.set_meta("no_talk", true)
			s.set_meta("climber", true)
			s.set_meta("no_turn", true)
			add_child(s)
			var lad: Ladder = m.lad
			var at := lad.height * (0.25 + 0.35 * j + 0.1 * i)
			s.global_position = lad.point_at(at)
			var ca: Node = CLIMB.attach(s, lad, at, "sur_demo")
			ca.go_to(minf(at + 3.0, lad.height * 0.9), 0.6)
		i += 1


func _gok() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3f7fc4") if not gece else Color("0b1330")
	sm.sky_horizon_color = Color("cfdde6") if not gece else Color("2a3560")
	sm.ground_horizon_color = Color("b8c4c8") if not gece else Color("1c2238")
	sm.ground_bottom_color = Color("5a6a70") if not gece else Color("10141f")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.48 if not gece else 0.22
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.9
	e.fog_enabled = true
	e.fog_light_color = Color("d6dcd8") if not gece else Color("1c2440")
	e.fog_density = 0.0015 if not gece else 0.004
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.08
	e.adjustment_contrast = 1.05
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-36, 38, 0) if not gece else Vector3(-50, -140, 0)
	sun.light_color = Color("ffe2b8") if not gece else Color("9fb4e8")
	sun.light_energy = 1.2 if not gece else 0.28
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 140.0
	add_child(sun)
	if gece:
		# meşaleler (sur yolunda ve gedikte): sıcak nokta ışıklar
		for p: Vector3 in [Vector3(-67.7, 2.2, 15.0), Vector3(-55.9, 9.8, 18.8), Vector3(-20.0, 9.8, 18.8), Vector3(-85.6, 1.8, 16.0), Vector3(-67.7, -2.0, 26.0)]:
			var l := OmniLight3D.new()
			l.light_color = Color("ffb35c")
			l.light_energy = 2.2
			l.omni_range = 14.0
			l.position = p
			add_child(l)


## Karar 12: 4 bakışta çizim/ilkel — yeni kesim (uzak katmanlı) ve eski LandWalls (gedikli, 20'nin seti) yan yana
func _olc() -> void:
	var bak := [["ova", Vector3(0, 1.7, 90.0), Vector3(0, 4.0, 18.0)], ["peribolos", Vector3(10.0, 1.6, 9.0), Vector3(-10.0, 3.0, 12.0)],
		["hava", Vector3(40.0, 50.0, 80.0), Vector3(0, 0, 20.0)], ["sur_yolu", Vector3(-10.0, 10.2, 18.8), Vector3(30.0, 8.0, 19.0)]]
	for set_ad in ["yeni", "eski"]:
		var t0 := Time.get_ticks_usec()
		var n: Node3D
		var off := Vector3.ZERO
		if set_ad == "yeni":
			var k: Dictionary = SurOyun.kur("mesoteikhion", {"ebeveyn": self, "dunya": false, "uzak": true, "asama": 2, "dolgu": 0.5, "merdiven": [0, 1, 2]})
			n = k["kok"]
			SURDOKU.uygula(n, 0)
			off = Vector3(float(k["arayuz"].gx), 0, 0)       # yeni kesimde bakışlar oyun gediğine göre
		else:
			var lw := LandWalls.new()
			add_child(lw)
			n = lw
			# eski setin ekseni: +z dış yüz, gedik x = 0, dış sur z 14…16 (yeni: 17,5…20,1): bakışlar aynı göreli yerde
			off = Vector3(0, 0, -3.0)
		var ms := (Time.get_ticks_usec() - t0) / 1000.0
		for i in 20:
			await get_tree().process_frame
		if DisplayServer.get_name() == "headless":
			# başsız: yalnız kurulum süresi (çizim sayısı yok)
			print("SUROLC %s bassiz kurulum_ms=%.0f" % [set_ad, ms])
			n.queue_free()
			for i in 4:
				await get_tree().process_frame
			continue
		for b in bak:
			cam.global_position = (b[1] as Vector3) + off
			cam.look_at((b[2] as Vector3) + off, Vector3.UP)
			for i in 6:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var vp := get_viewport()
			print("SUROLC %s bakis=%s kurulum_ms=%.0f cizim=%d ilkel=%d" % [set_ad, b[0], ms,
				vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME),
				vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME)])
		n.queue_free()
		for i in 4:
			await get_tree().process_frame
