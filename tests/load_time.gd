extends Node
## Bölüm açılış süresi ölçümü (yükleme donması, "program yanıt vermiyor"): her bölüm sahnesi için
##   load    : PackedScene yüklemesi (iş parçacığında yapılabilen kısım)
##   inst    : instantiate
##   ready   : add_child -> _ready (bölümün kendi kurulumu; ana iş parçacığında, pencere bu sürede donar)
##   frame1  : ilk kare (deferred kurulumlar)
## Kullanım: godot --headless --path . res://tests/load_time.tscn [-- --only=chapter26]
## Çıktı: "LOADTIME scene=... load=.. inst=.. ready=.. frame1=.. total=.." (ms)

func _ready() -> void:
	var only := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			only = a.substr(7)
	var files: Array[String] = []
	for f in DirAccess.get_files_at("res://scenes"):
		if f.ends_with(".tscn") and f.begins_with("chapter") and (only == "" or f.get_basename() == only):
			files.append(f)
	files.sort()
	for f in files:
		var path := "res://scenes/" + f
		var t0 := Time.get_ticks_usec()
		var ps := load(path) as PackedScene
		var t1 := Time.get_ticks_usec()
		var n := ps.instantiate()
		var t2 := Time.get_ticks_usec()
		get_tree().root.add_child(n)
		var t3 := Time.get_ticks_usec()
		await get_tree().process_frame
		var t4 := Time.get_ticks_usec()
		print("LOADTIME scene=%s load=%d inst=%d ready=%d frame1=%d total=%d" % [f.get_basename(), (t1 - t0) / 1000,
			(t2 - t1) / 1000, (t3 - t2) / 1000, (t4 - t3) / 1000, (t4 - t0) / 1000])
		n.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	get_tree().quit()
