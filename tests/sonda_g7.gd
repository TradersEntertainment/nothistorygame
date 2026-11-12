extends Node3D
## G7 sondası (serbest kamera): aynı dünya koordinatına yerden ve havadan bakış karesi.
## Kullanım (ekranlı): godot --path . res://tests/sonda_g7.tscn -- --mode=walls|camp --out=KLASÖR
##   --cam=ad,px,py,pz,lx,ly,lz [--cam=...] [--fov=70] [--wait=40] [--night=1]
## mode=walls: kara surları bölümlerinin dünyası (LandWalls + SiegeField, bölüm 20/22/26o/36b/0 gibi).
## mode=chapter: --scene=chapter10l gibi bölüm sahnesi (koordinatlar sahne koordinatı).
## mode=camp: uçuş bölümlerinin dünyası (CampDay in_world + World1453.build "camp", bölüm 7/11 gibi).
## Koordinatlar DÜNYA koordinatıdır (x sur boyunca, +z ova, y yukarı); alanın dönüşümüyle sahneye çevrilir.
## Kare adı: sonda_<mode>_<ad>.png; üstüne dünya koordinatı yazılır (kamera ve bakılan nokta).

var _cams: Array = []
var _out := "user://sonda"
var _mode := "walls"
var _fov := 70.0
var _wait := 40.0
var _night := true
var _field: SiegeField
var _scene := "chapter10l"


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--mode="):
			_mode = a.trim_prefix("--mode=")
		elif a.begins_with("--out="):
			_out = a.trim_prefix("--out=")
		elif a.begins_with("--fov="):
			_fov = float(a.trim_prefix("--fov="))
		elif a.begins_with("--wait="):
			_wait = float(a.trim_prefix("--wait="))
		elif a.begins_with("--scene="):
			_scene = a.trim_prefix("--scene=")
		elif a.begins_with("--night="):
			_night = a.trim_prefix("--night=") == "1"
		elif a.begins_with("--cam="):
			var p := a.trim_prefix("--cam=").split(",")
			if p.size() == 7:
				_cams.append({"name": p[0], "pos": Vector3(float(p[1]), float(p[2]), float(p[3])), "look": Vector3(float(p[4]), float(p[5]), float(p[6]))})
	DirAccess.make_dir_recursive_absolute(_out)
	GameState.autotest = _mode != "chapter"      # bölüm sahnesi kendi akışını (ve çıkışını) oynamasın
	if _mode == "chapter":
		# bölümün kendi sahnesi (ör. lağım kuyusunun içi): koordinatlar sahne koordinatı, arayüz gizlenir
		var ch := (load("res://scenes/%s.tscn" % _scene) as PackedScene).instantiate()
		add_child(ch)
		for n in ch.get_children():
			if n is CanvasLayer:
				(n as CanvasLayer).visible = false
	elif _mode == "camp":
		var day := CampDay.new()
		add_child(day)
		if _night:
			day.make_night(true)
		_field = day.world
	else:
		var walls := LandWalls.new()
		add_child(walls)
		walls.set_repair(LandWalls.STAGES)
		_field = walls.field
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(_wait * 1000.0):
		await get_tree().process_frame
	var cam := Camera3D.new()
	cam.fov = _fov
	cam.far = 4000.0
	add_child(cam)
	cam.make_current()
	for c: Dictionary in _cams:
		var p: Vector3 = _field.to_global(c["pos"]) if _field else c["pos"]
		var l: Vector3 = _field.to_global(c["look"]) if _field else c["look"]
		cam.global_position = p
		cam.look_at(l, Vector3.UP)
		for i in 6:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		var f := _out.path_join("sonda_%s_%s.png" % [_mode, c["name"]])
		img.save_png(f)
		print("SONDA %s kamera=%s bakis=%s" % [f, c["pos"], c["look"]])
	print("SONDA DONE draws=%d prims=%dk" % [RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) / 1000])
	get_tree().quit()
