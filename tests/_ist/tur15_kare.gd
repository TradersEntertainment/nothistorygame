extends "res://tests/_ist/tasima12_kare.gd"
## TUR 15 kare aracı (Taşıma 12'ninkinin üstüne): 17o, oyuncunun gerçek konumlarından karşı kıyıya (Haliç surları) ve
## Galata'ya bakış; bir de dar açılı (25°) karşı kıyı karesi. ÖNCE | SONRA aynı araç, `--eskisur=17o` ile ve onsuz.
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur15_kare.tscn -- bolum=17o shots=KLASÖR [yalniz=a,b] [--eskisur=17o]
## Satırlar: T10KARE_YUKLE · T10KARE ad=… cizim=… ilkel=… · T15KARE_KARE ad=… ms=… · T10KARE_BITTI

const EYE := 1.65


func _bakislar() -> Array:
	if bolum != "17o":
		return super._bakislar()
	var k := func(ad: String) -> Vector3: return (ch.get_script() as Script).get_script_constant_map()[ad]
	var gun: Vector3 = k.call("GUN")
	var bk: Vector3 = k.call("BUCKETS")
	var walk: Rect2 = k.call("WALK")
	var g := func(p: Vector3) -> Vector3: return ch.to_global(p)
	# oyuncunun gerçek konumları: açılış (_run), top başı (_aim), kova yığını, kıyının iki ucu
	var bas := gun + Vector3(1.6, EYE, -2.6)
	var top := gun + Vector3(0.0, EYE, -2.3)
	var kova := bk + Vector3(-0.6, EYE, -1.6)
	var sag := Vector3(walk.end.x - 3.0, EYE, -1.5)
	var sol := Vector3(walk.position.x + 3.0, EYE, -1.5)
	var gc := Vector3(190.0, 12.0, -140.0)        # Galata (dünya galata_center, springs çerçevesinde)
	return [
		["01_baslangic_karsi_kiyi", g.call(bas), g.call(Vector3(bas.x, 6.0, 220.0)), null, 72.0],
		["02_top_basi_karsi_kiyi_sol", g.call(top), g.call(Vector3(-140.0, 6.0, 220.0)), null, 72.0],
		["03_kova_zinciri_karsi_kiyi_sag", g.call(kova), g.call(Vector3(150.0, 6.0, 220.0)), null, 72.0],
		["04_kiyi_sag_ucu_burun", g.call(sag), g.call(Vector3(360.0, 6.0, 260.0)), null, 72.0],
		["05_kiyi_sol_ucu_blakherna", g.call(sol), g.call(Vector3(-420.0, 6.0, 220.0)), null, 72.0],
		["06_baslangic_galata", g.call(bas), g.call(gc), null, 72.0],
		["07_dar_aci_karsi_kiyi", g.call(top), g.call(Vector3(10.0, 8.0, 220.0)), null, 25.0],
		["08_dar_aci_kule_dibi", g.call(kova), g.call(Vector3(60.0, 2.0, 220.0)), null, 20.0],
	]


func _surus() -> void:
	if bolum != "17o":
		await super._surus()
		return
	var sc := load("res://scenes/chapter17o.tscn") as PackedScene
	var t0 := Time.get_ticks_msec()
	ch = sc.instantiate() as Node3D
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	await get_tree().process_frame
	print("T10KARE_YUKLE bolum=%s v2=%s yeni=%s ms=%d" % [bolum, IstBaglama.aktif(), not SurSet.eski_istendi("17o"), Time.get_ticks_msec() - t0])
	await _bekle(12.0)
	cam = Camera3D.new()
	cam.far = 4000.0
	cam.near = 0.05
	ch.add_child(cam)
	for b: Array in _bakislar():
		if yalniz != "" and not (String(b[0]) in yalniz.split(",")):
			continue
		cam.fov = float(b[4]) if b.size() > 4 else 72.0
		cam.global_position = b[1]
		cam.look_at(b[2], Vector3.UP)
		cam.make_current()
		await _bekle(3.0)
		cam.make_current()
		# kare süresi: 30 karenin ortalaması (pencereli, sabit kamera)
		var tt := Time.get_ticks_usec()
		for i in 30:
			await RenderingServer.frame_post_draw
		print("T15KARE_KARE ad=%s ms=%.2f" % [String(b[0]), (Time.get_ticks_usec() - tt) / 30000.0])
		await _cek(String(b[0]))
	print("T10KARE_BITTI")
	get_tree().quit()
