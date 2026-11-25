extends Node
## G19: tests/load_time.gd'nin eşi; bölümün _ready kurulumu açık bir kurulum kapsamında (LoadingScreen.kurulum_basla)
## ölçülür: nabız noktaları çalışır (başsızda process_events ucuz), en uzun canlılık boşluğu da basılır.
## Kullanım: godot --headless --path . res://tests/_yukleme19/load_time19.tscn -- --only=chapter26 [--kapsam=0]
## Çıktı: "LOADTIME19 scene=... kapsam=1 load=.. inst=.. ready=.. frame1=.. total=.. bosluk=.. kaynak=.."

func _ready() -> void:
	_kos.call_deferred()      # tests/load_time.gd _ready içinde add_child yapıyordu: kök meşgul, bölüm hiç eklenmiyordu


func _kos() -> void:
	var only := ""
	var kapsam := true
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			only = a.substr(7)
		elif a == "--kapsam=0":
			kapsam = false
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
		if kapsam:
			LoadingScreen.kurulum_basla("load_time19")
		LoadingScreen._olc_acik = true
		LoadingScreen._olc_en = 0
		LoadingScreen._olc_kaynak = ""
		LoadingScreen._son_kaynak = "bas"
		LoadingScreen._last_pump = Time.get_ticks_msec()
		get_tree().root.add_child(n)
		var t3 := Time.get_ticks_usec()
		LoadingScreen.nabiz("ready_son")
		LoadingScreen._bosluk_yaz(Time.get_ticks_msec() - LoadingScreen._last_pump, "ready_son")
		if kapsam:
			LoadingScreen.kurulum_bitir()
		await get_tree().process_frame
		var t4 := Time.get_ticks_usec()
		LoadingScreen._bosluk_yaz(Time.get_ticks_msec() - LoadingScreen._last_pump, "kare1")
		LoadingScreen._olc_acik = false
		print("LOADTIME19 scene=%s kapsam=%d load=%d inst=%d ready=%d frame1=%d total=%d bosluk=%d kaynak=%s" % [
			f.get_basename(), int(kapsam), (t1 - t0) / 1000, (t2 - t1) / 1000, (t3 - t2) / 1000, (t4 - t3) / 1000,
			(t4 - t0) / 1000, LoadingScreen._olc_en, LoadingScreen._olc_kaynak])
		n.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	get_tree().quit()
