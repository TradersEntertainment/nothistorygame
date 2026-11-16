extends SceneTree
## IstGeo hızlı sınama: godot --headless --path . -s res://tests/_ist/geo_sina.gd
func _init() -> void:
	var G = load("res://scripts/world/ist/geo.gd")
	var t0 := Time.get_ticks_usec()
	var s := 0.0
	var n := 200000
	for i in n:
		s += G.h(-1500.0 + float(i % 1000) * 3.0, -900.0 + float(i / 1000) * 9.0)
	var us := float(Time.get_ticks_usec() - t0) / n
	print("GEOSINA h_us=%.3f" % us)
	for p in [["Ayasofya", 0.0, 0.0], ["Sarayburnu", 571.0, 878.0], ["Galata kulesi", -512.0, 1889.0], ["Haliç orta", -1200.0, 1500.0],
			["Marmara", -1000.0, -1500.0], ["Edirnekapı içi", -3500.0, 2350.0], ["Kız Kulesi", 2010.0, 1390.0], ["Üsküdar", 3200.0, 2000.0],
			["Lykos", -3000.0, 300.0], ["Topkapı dışı", -5200.0, 800.0], ["Beyazıt", -1360.0, 500.0], ["Langa", -2250.0, -560.0]]:
		var wv: Vector3 = G.w(p[1], p[2])
		print("GEOSINA %s w=%s su=%s ici=%s galata=%s mahalle=%s" % [p[0], wv, G.su(wv.x, wv.z), G.sehir_ici(wv.x, wv.z), G.galata_ici(wv.x, wv.z), G.mahalle(wv.x, wv.z)])
	for a in ["kara_suru", "marmara_suru", "halic_suru", "galata_suru", "blakherna_suru", "mese", "mese_kuzey", "mese_guney", "lykos", "zincir", "bozdogan"]:
		var c: PackedVector2Array = G.yol(a)
		var L := 0.0
		for i in c.size() - 1:
			L += c[i].distance_to(c[i + 1])
		print("GEOSINA yol %s n=%d uzunluk=%.0f" % [a, c.size(), L])
	for a in ["yarimada", "galata", "anadolu", "trakya"]:
		print("GEOSINA kiyi %s n=%d" % [a, G.kiyi(a).size()])
	print("GEOSINA yerler ", G.yerler().size(), " ", G.yerler()[0])
	t0 = Time.get_ticks_usec()
	for i in 2000:
		G.mahalle(-1500.0 + float(i % 50) * 30.0, -300.0 + float(i / 50) * 20.0)
	print("GEOSINA mahalle_us=%.1f" % (float(Time.get_ticks_usec() - t0) / 2000.0))
	quit(0)
