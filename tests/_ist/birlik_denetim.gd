extends Node3D
## BİRLİK denetimi: v2 dünyası gerçek kurucuyla kurulur (sur dışı ordugâh önü + şehir içi iki nokta), akış biter,
## bütün malzemeler gezilir (scripts/world/ist/gorsel_dil.gd denetle()). Son satır:
##   BIRLIK malzeme=<n> kategorisiz=<n> doygunluk_asan=<n> duz_buyuk_yuzey=<n> saf_beyaz=<n>
## Hedef: son dördü 0 (eşik gevşetme yok; tanımlar gorsel_dil.gd denetle() açıklamasında).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/birlik_denetim.tscn

const GD := preload("res://scripts/world/ist/gorsel_dil.gd")
var cam: Camera3D
var dunya: Node3D


func _ready() -> void:
	cam = Camera3D.new()
	cam.far = 30000.0
	add_child(cam)
	cam.current = true
	var w := IstOrdugah.at(1350.0, 70.0)
	var noktalar := [Vector3(w.x, IstGeo.h(w.x, w.y) + 15.0, w.y)]
	var w2 := IstOrdugah.at(1350.0, -400.0)
	noktalar.append(Vector3(w2.x, IstGeo.h(w2.x, w2.y) + 2.0, w2.y))
	var w3 := IstOrdugah.at(2400.0, 260.0)
	noktalar.append(Vector3(w3.x, IstGeo.h(w3.x, w3.y) + 2.0, w3.y))
	cam.global_position = noktalar[0]
	var t0 := Time.get_ticks_msec()
	dunya = IstDunya.build(self, false, cam.global_position)
	print("BIRLIK yukleme_ms=%d" % (Time.get_ticks_msec() - t0))
	IstDunya.butce_us = 250000
	var top := {"malzeme": 0, "kategorisiz": 0, "doygunluk_asan": 0, "duz_buyuk_yuzey": 0, "saf_beyaz": 0}
	var ornek := {}
	for p: Vector3 in noktalar:
		cam.global_position = p
		await _bekle()
		var r := GD.denetle(dunya)
		print("BIRLIK nokta=%s malzeme=%d kategorisiz=%d doygunluk_asan=%d duz_buyuk_yuzey=%d saf_beyaz=%d" % [p, r["malzeme"],
			r["kategorisiz"], r["doygunluk_asan"], r["duz_buyuk_yuzey"], r["saf_beyaz"]])
		for k in top:
			top[k] = maxi(int(top[k]), int(r[k]))
		for s: String in r["ornek"]:
			ornek[s] = true
	for s: String in ornek:
		print("BIRLIK ornek ", s)
	print("BIRLIK sayac ", GD.sayac)
	print("BIRLIK malzeme=%d kategorisiz=%d doygunluk_asan=%d duz_buyuk_yuzey=%d saf_beyaz=%d" % [top["malzeme"], top["kategorisiz"],
		top["doygunluk_asan"], top["duz_buyuk_yuzey"], top["saf_beyaz"]])
	get_tree().quit(0)


func _bekle() -> void:
	for i in 4:
		await get_tree().process_frame
	var s := IstSehir.active
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 120000:
		var bos := true
		if dunya.has_method("olcum") and int(dunya.olcum()["isler"]) > 0:
			bos = false
		if s != null:
			s._last_cam = Vector3.INF
			for k in 400:
				s._process(0.0)
				if s._queue.is_empty():
					break
			if not s._queue.is_empty():
				bos = false
		for y in get_tree().root.find_children("*", "IstOrdugahYonetici", true, false):
			(y as IstOrdugahYonetici).butce_us = 400000
			if not (y as IstOrdugahYonetici).kuyruk.is_empty():
				bos = false
		if bos:
			break
		await get_tree().process_frame
	for i in 3:
		await get_tree().process_frame
	if GD.aktif != null:
		GD.aktif.bitir()
	await get_tree().process_frame
