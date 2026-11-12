extends Node3D
## İstanbul 1453 şehir sondası (kanıt kareleri): hub'ın dünyası (ByzCity "walls" = World1453.build) gündüz kurulur;
## IstSehir akışı her kamera konumunda bitene kadar beklenir, sonra kare yazılır.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/sehir_kare.tscn -- --out=KLASÖR --tur=N [--set=hava|eser|yer|hepsi]
## Kareler: tur_<n>_{kuzey,guney,dogu,bati,tepe}.jpg (bütün şehir havadan), eser_<id>_{15m,tepe}.jpg (yan görev eserleri),
## yer_<ad>.jpg (hub çevresi, oyuncu gözü). Satırlar: ISTKARE …, RINFO-benzeri ISTSAY çizim/üçgen.

var out := "user://ist_kare"
var tur := 1
var set_ := "hepsi"
var cam: Camera3D
var city: ByzCity
var f: SiegeField


func _ready() -> void:
	GameState.autotest = false
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
		elif a.begins_with("--tur="):
			tur = a.substr(6).to_int()
		elif a.begins_with("--set="):
			set_ = a.substr(6)
		elif a == "--once":
			IstSehir.enabled = false
	if set_ == "liste":
		for e: Dictionary in IstSehir.catalog_all():
			var d: Dictionary = e["data"]
			var pl := IstSehir.place_of(e)
			var p: Vector3 = pl["pos"]
			print("LISTE %s|%s|%s|real=(%.0f,%.0f)|olcu=%s|yon=%.0f|dunya=(%.0f,%.0f,%.1f)|k=%.2f|r=%.0f|su=%s|gorev=%s|%s" % [e["mod"], e["id"],
				d.get("tur", ""), float(d.get("dogu_m", 0)), float(d.get("kuzey_m", 0)), str(d.get("gercek_olcu")), float(d.get("yon_derece", 0)),
				p.x, p.z, p.y, pl["k"], pl["r"], World1453.is_water(p.x, p.z), d.get("gorev", false), d.get("ad", "")])
		print("KITS %s" % [IstSehir.KITS.keys()])
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(out)
	city = ByzCity.new()
	city.part = "walls"
	add_child(city)
	if find_children("*", "WorldEnvironment", true, false).is_empty():
		_env()
	f = city.world
	if f:
		f.set_mode("day")
	cam = Camera3D.new()
	cam.far = 6000.0
	cam.fov = 60.0
	add_child(cam)
	cam.make_current()
	# Havadan kanıt: yer bölümünün sisi kapatılır (uçuş bölümleri kendi göğünü kurar)
	for we in find_children("*", "WorldEnvironment", true, false):
		var env := (we as WorldEnvironment).environment
		if env:
			env.fog_enabled = false
			env.volumetric_fog_enabled = false
	var ww: WorldWalk = f.get_node_or_null("WorldWalk") if f else null
	var t := 0.0
	while ww and not ww.done and t < 400.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	print("ISTKARE kurulum bitti t=%.1f" % t)
	if set_ in ["hava", "hepsi"]:
		await _aerial()
	if set_ in ["eser", "hepsi"]:
		await _monuments()
	if set_ in ["yer", "hepsi"]:
		await _ground()
	get_tree().quit(0)


func _env() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	var ps := ProceduralSkyMaterial.new()
	ps.sky_top_color = Color("6a9ad8")
	ps.sky_horizon_color = Color("d8e4ec")
	ps.ground_horizon_color = Color("c8d0d0")
	sky.sky_material = ps
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.8
	env.fog_enabled = true
	env.fog_light_color = Color("d0dce4")
	env.fog_density = 0.00025
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -135, 0)
	sun.light_energy = 1.25
	sun.light_color = Color("fff0d8")
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 600.0
	add_child(sun)


## Kamera dünya noktasında (f yereli), hedefe bakar; IstSehir akışı bitene kadar bekler, kareyi yazar
func _shot(name: String, at: Vector3, look: Vector3, fov := 60.0) -> void:
	cam.fov = fov
	cam.global_position = f.to_global(at)
	var up := Vector3.UP if absf((look - at).normalized().y) < 0.98 else Vector3(0, 0, -1)
	cam.look_at(f.to_global(look), up)
	for i in 4:
		await get_tree().process_frame
	var guard := 0
	while guard < 600 and _busy():
		await get_tree().process_frame
		guard += 1
	for i in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_jpg(out.path_join(name + ".jpg"), 0.82)
	var draws := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var tris := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	print("ISTKARE %s at=(%.0f,%.0f,%.0f) cizim=%d ucgen=%d bekleme=%d" % [name, at.x, at.y, at.z, draws, tris, guard])


func _busy() -> bool:
	for n in f.find_children("*", "IstSehir", true, false):
		var s := n as IstSehir
		s._t = 0.0
		if not s._queue.is_empty():
			return true
	return false


func _aerial() -> void:
	var c := Vector3(-120.0, 0.0, -860.0)
	var p := "tur_%d_" % tur
	await _shot(p + "kuzey", c + Vector3(-1250, 650, 0), c, 62)    # Haliç (kuzey) tarafından
	await _shot(p + "guney", c + Vector3(1250, 650, 0), c, 62)     # Marmara tarafından
	await _shot(p + "dogu", c + Vector3(0, 650, -1350), c, 62)     # Boğaz (doğu) tarafından
	await _shot(p + "bati", c + Vector3(0, 650, 1300), c, 62)      # kara surlarının dışından
	await _shot(p + "tepe", c + Vector3(0, 2100, 0.1), c, 55)


func _monuments() -> void:
	var s: IstSehir = IstSehir.active
	if s == null:
		return
	for it: Dictionary in s.items:
		var d: Dictionary = it["data"]
		if not d.get("gorev", false):
			continue
		var p: Vector3 = it["pos"]
		var h := float((d.get("gercek_olcu", Vector3(20, 20, 20)) as Vector3).y) * float(it["k"])
		var r := float(it["r"])
		await _shot("eser_%s_15m" % it["id"], p + Vector3(r * 0.9 + 12.0, h + 15.0, r * 0.9 + 12.0), p + Vector3(0, h * 0.4, 0), 60)
		await _shot("eser_%s_tepe" % it["id"], p + Vector3(0, h + maxf(30.0, r * 2.2), 0.1), p, 60)


func _ground() -> void:
	# Hub (Romanos) çevresi: cadde boyunca ve dört uçtan dışarı (göz 1,7 m)
	var pts := [["hub_cadde", Vector3(-10, 0, -60), Vector3(-10, 0, -140)], ["hub_kuzey", Vector3(-50, 0, -40), Vector3(-160, 0, -60)],
		["hub_guney", Vector3(40, 0, -40), Vector3(160, 0, -60)], ["hub_ic", Vector3(0, 0, -50), Vector3(0, 0, -260)],
		["mese", Vector3(-380, 0, -1060), Vector3(-430, 0, -1180)], ["aya", Vector3(-500, 0, -1400), Vector3(-560, 0, -1480)]]
	for e: Array in pts:
		var a: Vector3 = e[1]
		var b: Vector3 = e[2]
		a.y = World1453.surface_h(a.x, a.z) + 1.7
		b.y = World1453.surface_h(b.x, b.z) + 4.0
		await _shot("yer_" + String(e[0]), a, b, 70)
