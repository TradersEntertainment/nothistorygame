extends Node
## TUR-12 bölüm içi bütçe ölçümü (ÖNCE | SONRA aynı kameralar). Bölümü ana sahneden (boot.gd) açar; bekleme sonunda
## oyunu duraklatır, sabit bir kameradan 4 yönde (yaw 0/90/180/270) 12 karelik ortalama çizim çağrısı ve ilkel ölçer.
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur12_butce.tscn --
##       --chapter=26 [--autotest] --t12bekle=25 --t12kam=<json> [--t12kare=<klasör>]
## --t12kam dosyası yoksa bekleme sonundaki etkin kameranın dönüşümü yazılır (ilk koşu), varsa okunur (aynı kamera).
## Duraklatmadan önceki --t12pencere (varsayılan 4) sn'nin ortalama betik (process) süresi de yazılır. Satırlar: T12BUTCE …, T12SURE …
## --t12kare: her yönün karesi (1280×720 jpg 85) + 0,4 sn arayla 3 kare (dalga kanıtı) o klasöre.

var bekle := 25.0
var pencere := 4.0
var kam_yol := ""
var kare_dir := ""
var _t0 := 0
var _surec: Array = []


func _ready() -> void:
	if has_meta("izle"):
		return
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--t12bekle="):
			bekle = float(a.get_slice("=", 1))
		elif a.begins_with("--t12kam="):
			kam_yol = a.get_slice("=", 1)
		elif a.begins_with("--t12kare="):
			kare_dir = a.get_slice("=", 1)
		elif a.begins_with("--t12pencere="):
			pencere = float(a.get_slice("=", 1))
	var iz := Node.new()
	iz.set_script(get_script())
	iz.set_meta("izle", true)
	iz.process_mode = Node.PROCESS_MODE_ALWAYS
	iz.bekle = bekle
	iz.kam_yol = kam_yol
	iz.kare_dir = kare_dir
	iz.pencere = pencere
	get_tree().root.add_child.call_deferred(iz)
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")


func _enter_tree() -> void:
	if has_meta("izle"):
		_t0 = Time.get_ticks_msec()
		_calis.call_deferred()


func _calis() -> void:
	while (Time.get_ticks_msec() - _t0) / 1000.0 < bekle - pencere:
		await get_tree().process_frame
	# betik süresi (oyun akarken)
	var n := 0
	var ps := 0.0
	var fs := 0.0
	while (Time.get_ticks_msec() - _t0) / 1000.0 < bekle:
		await get_tree().process_frame
		ps += Performance.get_monitor(Performance.TIME_PROCESS) + Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
		fs += get_process_delta_time()
		n += 1
	print("T12SURE kare=%d betik_ms=%.2f kare_ms=%.1f" % [n, ps * 1000.0 / maxi(n, 1), fs * 1000.0 / maxi(n, 1)])
	get_tree().paused = true
	var cam0 := get_viewport().get_camera_3d()
	var xf := Transform3D.IDENTITY
	if kam_yol != "" and FileAccess.file_exists(kam_yol):
		var j: Array = JSON.parse_string(FileAccess.get_file_as_string(kam_yol))
		xf = Transform3D(Basis(Vector3(j[0], j[1], j[2]), Vector3(j[3], j[4], j[5]), Vector3(j[6], j[7], j[8])), Vector3(j[9], j[10], j[11]))
		print("T12KAM okundu")
	elif cam0 != null:
		xf = cam0.global_transform
		var b := xf.basis
		var o := xf.origin
		var f := FileAccess.open(kam_yol, FileAccess.WRITE)
		if f != null:
			f.store_string(JSON.stringify([b.x.x, b.x.y, b.x.z, b.y.x, b.y.y, b.y.z, b.z.x, b.z.y, b.z.z, o.x, o.y, o.z]))
			f.close()
		print("T12KAM yazildi")
	var cam := Camera3D.new()
	cam.process_mode = Node.PROCESS_MODE_ALWAYS
	if cam0 != null:
		cam.fov = cam0.fov
		cam.near = cam0.near
		cam.far = cam0.far
	get_tree().root.add_child(cam)
	# yatay bakış: kameranın ileri yönünü yatay düzleme indir (aşağı/yukarı bakan oyuncu kamerası 4 yönde aynı olsun)
	var ileri := -xf.basis.z
	ileri.y = clampf(ileri.y, -0.25, 0.25)
	for k in 4:
		var yon := ileri.rotated(Vector3.UP, k * PI * 0.5).normalized()
		cam.global_transform = Transform3D(Basis.looking_at(yon, Vector3.UP), xf.origin)
		cam.make_current()
		for i in 8:
			await get_tree().process_frame
		var dc := 0.0
		var pr := 0.0
		for i in 12:
			await get_tree().process_frame
			dc += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			pr += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		print("T12BUTCE yon=%d cizim=%.0f ilkel=%.0f poz=%s" % [k, dc / 12.0, pr / 12.0, xf.origin.snapped(Vector3.ONE * 0.1)])
		if kare_dir != "":
			DirAccess.make_dir_recursive_absolute(kare_dir)
			for s in 3:
				await RenderingServer.frame_post_draw
				var img := get_viewport().get_texture().get_image()
				img.save_jpg(kare_dir.path_join("y%d_%d.jpg" % [k, s]), 0.85)
				var tt := Time.get_ticks_msec()
				while Time.get_ticks_msec() - tt < 400:
					await get_tree().process_frame
	print("T12BITTI")
	get_tree().quit()
