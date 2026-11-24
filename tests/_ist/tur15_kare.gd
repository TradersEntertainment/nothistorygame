extends "res://tests/_ist/tasima12_kare.gd"
## TUR 15 kare aracı (Taşıma 12'ninkinin üstüne): 17o, oyuncunun gerçek konumlarından karşı kıyıya (Haliç surları) ve
## Galata'ya bakış; bir de dar açılı (25°) karşı kıyı karesi. ÖNCE | SONRA aynı araç, `--eskisur=17o` ile ve onsuz.
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur15_kare.tscn -- bolum=17o shots=KLASÖR [yalniz=a,b] [--eskisur=17o]
## Satırlar: T10KARE_YUKLE · T10KARE ad=… cizim=… ilkel=… · T15KARE_KARE ad=… ms=… · T10KARE_BITTI

const EYE := 1.65


func _bakislar() -> Array:
	if bolum != "17o":
		return super._bakislar()
	var km := (ch.get_script() as Script).get_script_constant_map()
	var gun: Vector3 = km["GUN"]
	var bk: Vector3 = km["BUCKETS"]
	var walk: Rect2 = km["WALK"]
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
		# taban kipte eski kalan yerler: Eugenius kulesi (dünya −690, −1525), kuzey uç (Blakherna yönü), Galata'nın Haliç
		# yüzündeki suru (keep dışı), burun (dünya TIP)
		# (sağ uçtan bakışı demirli kadırgalar kapatır: Eugenius ve burun kıyının sol ucundan)
		["09_dar_eugenius", g.call(sol), g.call(Vector3(375.0, 10.0, 230.0)), null, 25.0],
		["10_dar_kuzey_ucu", g.call(sol), g.call(Vector3(-330.0, 8.0, 220.0)), null, 25.0],
		["11_dar_galata_suru", g.call(sag), g.call(Vector3(250.0, 8.0, -30.0)), null, 30.0],
		["12_dar_burun", g.call(sol), g.call(Vector3(570.0, 8.0, 320.0)), null, 25.0],
		# vadinin yamacından (yürünür arazi; yer ışınla): karşı kıyı geniş ve Galata suru yakın
		["13_yamactan_karsi_kiyi", g.call(_yer(Vector3(20.0, 0.0, -75.0)) + Vector3(0, EYE, 0)), g.call(Vector3(120.0, 6.0, 220.0)), null, 72.0],
		["14_yamactan_galata_suru", g.call(_yer(Vector3(100.0, 0.0, -60.0)) + Vector3(0, EYE, 0)), g.call(Vector3(230.0, 10.0, -60.0)), null, 40.0],
		# inceleme (oyuncunun konumundan, dürbün gibi 6–12°): sur dibi suya/kıyıya oturuyor mu, kule ve diş siluetleri.
		# Karşı sur yerel z ≈ 220 (dünya x −700); tabanda keep'e ≤ 250 m olan orta kesim yerel x ≈ −247…247
		["15_yakin_eugenius", g.call(sol), g.call(Vector3(375.0, 8.0, 230.0)), null, 6.0],
		["16_yakin_karsi_sur_kuzey", g.call(sol), g.call(Vector3(-320.0, 5.0, 220.0)), null, 8.0],
		["17_yakin_karsi_sur_guney", g.call(sol), g.call(Vector3(300.0, 5.0, 221.0)), null, 8.0],
		["18_yakin_galata_suru", g.call(sag), g.call(Vector3(250.0, 8.0, -30.0)), null, 12.0],
		["19_yakin_karsi_sur_orta", g.call(top), g.call(Vector3(0.0, 5.0, 220.0)), null, 8.0],
		# DÜZELTME 5(b, c): Blakherna kabuğu ve kara surlarının Haliç ucu (dünya ≈ −640, 0…40; yerel x ≈ −1170, z ≈ 280)
		["20_dar_blakherna_kara_suru_ucu", g.call(sol), g.call(Vector3(-1170.0, 12.0, 280.0)), null, 12.0],
	]


## Bölüm çerçevesinde (x, z) noktasının yürünen zemini (yukarıdan ışın)
func _yer(p: Vector3) -> Vector3:
	var from := ch.to_global(Vector3(p.x, 300.0, p.z))
	var to := ch.to_global(Vector3(p.x, -50.0, p.z))
	var hit := ch.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	if hit.is_empty():
		return p
	return ch.to_local(hit["position"])


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
	await _bekle(6.0)
	# Bölümün akışı (NPC'ler, yürüyenler, olaylar) donar, çizim sürer: ÖNCE | SONRA ilkel/çizim sayıları yalnız dünyaya bağlı
	# kalsın (akış zamanlamasıyla ±%40 oynuyordu)
	get_tree().paused = true
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
		# kare süresi: 10 karenin ortalaması (pencereli, sabit kamera; yazılım GL: göreli)
		# çizim ve ilkel de 10 karenin ortalaması (tek kare sayımı gölge atlası güncellemesiyle ±%10 oynuyordu)
		var tt := Time.get_ticks_usec()
		var sc_ := 0
		var si_ := 0
		var mn_ := 1 << 40
		for i in 10:
			await RenderingServer.frame_post_draw
			var pi_ := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
			sc_ += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			si_ += pi_
			mn_ = mini(mn_, pi_)
		print("T15KARE_KARE ad=%s ms=%.2f cizim_ort=%d ilkel_ort=%d ilkel_min=%d" % [String(b[0]), (Time.get_ticks_usec() - tt) / 10000.0, sc_ / 10, si_ / 10, mn_])
		await _cek(String(b[0]))
	print("T10KARE_BITTI")
	get_tree().quit()
