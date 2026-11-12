extends Node
## İstanbul v2 haritasını pişirir (BAĞLAMA-4): MapView v2 çerçevesi (V2_X0, V2_Z0, W × H × MPP) → assets/ui/harita_ist2.res
## (Image, sıkıştırılmış; içe aktarma gerektirmez). Kuzey yukarı. Deniz, arazi gölgesi, mahalle türleri, surlar, Mese,
## ordugâh. Koşu: godot --headless --path . res://tests/_ist/harita_v2.tscn [-- png=KLASÖR]

const MPP_PIX := 3.0      # pişirilen resmin piksel başına metresi (MapView.MPP çerçevesi ölçeklenir)


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	IstGeo.kaydir(Vector2.ZERO)
	var span := Vector2(MapView.W * MapView.MPP, MapView.H * MapView.MPP)
	var w := int(span.x / MPP_PIX)
	var h := int(span.y / MPP_PIX)
	var img := Image.create(w, h, false, Image.FORMAT_RGB8)
	var su_r := Color("5d7f93")
	var su_d := Color("3f6176")
	var kara := Color("d6c8a2")
	var renk := {"carsi": Color("b98a6c"), "sik": Color("c39a78"), "seyrek": Color("c9ae86"), "bostan": Color("a8ad78"),
		"harabe": Color("b2a184"), "liman": Color("b58f74"), "sur_dibi": Color("c3a07c"), "kir": Color("c8bf92")}
	for j in h:
		for i in w:
			var x := MapView.V2_X0 + (i + 0.5) * MPP_PIX
			var z := MapView.V2_Z0 + (j + 0.5) * MPP_PIX
			var y := IstGeo.h(x, z)
			var c: Color
			if y < 0.0:
				c = su_r.lerp(su_d, clampf(-y / 25.0, 0.0, 1.0))
			else:
				c = kara
				if IstGeo.sehir_ici(x, z) or IstGeo.galata_ici(x, z):
					var m := IstGeo.mahalle(x, z)
					c = renk.get(String(m.get("tur", "")), kara)
				else:
					c = kara.lerp(Color("b9b682"), clampf(y / 40.0, 0.0, 0.6))
				# tepe gölgesi (kuzeybatı ışık)
				var gx := IstGeo.h(x + 6.0, z) - IstGeo.h(x - 6.0, z)
				var gz := IstGeo.h(x, z + 6.0) - IstGeo.h(x, z - 6.0)
				var sh := clampf(0.5 + (gx + gz) * 0.06, 0.0, 1.0)
				c = c.darkened(clampf(sh - 0.5, 0.0, 0.3)).lightened(clampf(0.5 - sh, 0.0, 0.2))
				if y < 1.2:
					c = c.lerp(Color("e3d8b8"), 0.5)       # kıyı şeridi
			img.set_pixel(i, j, c)
	# Ordugâh (çadırlar ve öğeler)
	var oscr = load("res://scripts/world/ist/ordugah.gd") if ResourceLoader.exists("res://scripts/world/ist/ordugah.gd") else null
	if oscr != null:
		for it: Dictionary in oscr.call("plan"):
			var p: Vector2 = it["pos"]
			var r := clampf(float(it.get("r", 4.0)), 2.0, 14.0)
			var col := Color("8c3a30") if String(it.get("id", "")) == "otag" else Color("efe6d2")
			_disk(img, p, r, col)
	# Yollar ve surlar
	for ad in ["mese", "mese_kuzey", "mese_guney"]:
		_cizgi(img, IstGeo.yol(ad), 2.0, Color("e8dcc0"))
	for ad in ["marmara_suru", "halic_suru", "galata_suru"]:
		_cizgi(img, IstGeo.yol(ad), 2.2, Color("6a5a48"))
	for ad in ["kara_suru", "blakherna_suru"]:
		_cizgi(img, IstGeo.yol(ad), 3.2, Color("4e4032"))
	var e := ResourceSaver.save(img, MapView.V2_TEX_PATH, ResourceSaver.FLAG_COMPRESS)
	print("HARITA_V2 %dx%d kayit=%s ms=%d" % [w, h, error_string(e), Time.get_ticks_msec() - t0])
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("png="):
			img.save_png(a.trim_prefix("png=").path_join("harita_ist2.png"))
	get_tree().quit()


func _px(p: Vector2) -> Vector2:
	return (p - Vector2(MapView.V2_X0, MapView.V2_Z0)) / MPP_PIX


func _disk(img: Image, p: Vector2, r: float, col: Color) -> void:
	var c := _px(p)
	var rr := maxf(r / MPP_PIX, 0.8)
	for dj in range(-int(rr) - 1, int(rr) + 2):
		for di in range(-int(rr) - 1, int(rr) + 2):
			if Vector2(di, dj).length() <= rr:
				var q := Vector2i(int(c.x) + di, int(c.y) + dj)
				if q.x >= 0 and q.y >= 0 and q.x < img.get_width() and q.y < img.get_height():
					img.set_pixelv(q, col)


func _cizgi(img: Image, pl: PackedVector2Array, kal: float, col: Color) -> void:
	for i in pl.size() - 1:
		var a := pl[i]
		var b := pl[i + 1]
		var n := int(ceilf(a.distance_to(b) / MPP_PIX)) + 1
		for k in n + 1:
			_disk(img, a.lerp(b, float(k) / n), kal, col)
