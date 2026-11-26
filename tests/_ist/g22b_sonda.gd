extends "res://tests/_ist/tasima12_kare.gd"
## G22b sondası (ekransız): bölümü GERÇEK akışında açar (varsayılan 23), v2 sokak verisini ölçer; isterse kapı → uc →
## iç mahallenin sokak ağzı hattını oyuncuyla yürür.
##   godot --headless --path . res://tests/_ist/g22b_sonda.tscn -- bolum=23 [taban=s,h,d,o,a,m] [yuru=1]
## Satırlar:
##   G22BSONDA karma ad=… n=… onek=… md5=…        listelerin taban uzunluğuna kadarki öneki (D5: 37ae2b7d ile birebir)
##   G22BSONDA dolgu {…}                           IstSokak.dolgu özeti (taban uzunlukları, sayılar)
##   G22BSONDA daire occ={…}                       hub dairesi (r 54) hücreleri: hub yereli x < 14 / 14…17
##   G22BSONDA bos yer=… kare=… bos=… oran=…        10 m'lik karelerin boş oranı (nöbet açıklığı ve senaryo alanı hariç)
##   G22BSONDA cimen bakis=… en_uzun=…              kameradan sura ışınlarda en uzun kesintisiz çıplak çimen (m)
##   G22BSONDA yol nokta=… kopuk=… en_dar=…         kapı→uc→iç sokak ağzı hattında occ=1 sürekliliği ve yol genişliği
##   G22BSONDA yer ad=… yerel=… en_yakin=… durum=…  senaryo yerinin yeni dolgu kayıtlarına en yakın uzaklığı (≥ 3 m)
##   G22BSONDA yuru bacak=… / G22BSONDA yuru OZET takilma=… dusme=…
##   G22BSONDA OZET …

var taban: Array = []
var yuru := false


func _ready() -> void:
	bolum = "23"
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"taban":
				for t: String in kv[1].split(","):
					taban.append(int(t))
			"yuru":
				yuru = kv[1] == "1"
	super._ready()


func _surus() -> void:
	var sc := load("res://scenes/chapter%s.tscn" % bolum) as PackedScene
	var t0 := Time.get_ticks_msec()
	ch = sc.instantiate() as Node3D
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	await get_tree().process_frame
	var t := 0.0
	while city == null and t < 120.0:
		city = _bul(ch)
		await get_tree().process_frame
		t += get_process_delta_time()
	var tt := 0.0
	while (IstSehir.sokak == null or not IstBaglama.aktif()) and tt < 120.0:
		await get_tree().process_frame
		tt += get_process_delta_time()
	await _bekle(6.0)
	print("G22BSONDA yuklendi bolum=%s v2=%s ms=%d" % [bolum, IstBaglama.aktif(), Time.get_ticks_msec() - t0])
	_olc()
	await _yukseklik()
	if yuru:
		await _yuru()
	get_tree().quit()


func _olc() -> void:
	var sk: IstSokak = IstSehir.sokak
	if sk == null:
		print("G22BSONDA sokak yok")
		return
	var xf: Transform3D = SurHub.hub_v2()
	var xi := xf.affine_inverse()
	var so := Vector2(SurHub.SARAY_OFS.x, SurHub.SARAY_OFS.z)
	# 1) önek karması
	var adlar := ["streets", "houses", "doku", "oge", "avlu", "meydan"]
	var tb: Dictionary = (_dl(sk).get("taban", {}) as Dictionary)
	for i in adlar.size():
		var ls: Array = sk.get(adlar[i])
		var n := ls.size()
		if i < taban.size():
			n = mini(int(taban[i]), ls.size())
		var ctx := HashingContext.new()
		ctx.start(HashingContext.HASH_MD5)
		for k in n:
			ctx.update(var_to_bytes(ls[k]))
		print("G22BSONDA karma ad=%s n=%d onek=%d md5=%s dolgu_taban=%s" % [adlar[i], ls.size(), n, ctx.finish().hex_encode(), str(tb.get(adlar[i], "-"))])
	var ozet: Dictionary = _dl(sk).duplicate()
	for k: String in ["yol", "ek_yok", "degisen", "degisen_eski"]:
		ozet.erase(k)
	print("G22BSONDA dolgu ", ozet)
	# 2) daire
	var hc := _w(xf, Vector2.ZERO)
	var say := {}
	for j in range(int((hc.y - 56.0 - sk.z0) / IstSokak.G), int((hc.y + 56.0 - sk.z0) / IstSokak.G) + 1):
		for i in range(int((hc.x - 56.0 - sk.x0) / IstSokak.G), int((hc.x + 56.0 - sk.x0) / IstSokak.G) + 1):
			var q := sk.cell_c(i, j)
			if q.distance_to(hc) > 54.0:
				continue
			var l := _l(xi, q)
			if l.x >= 17.0:
				continue
			var key := "%s%d" % ["a" if l.x < 14.0 else "k", sk.occ[j * sk.nx + i]]
			if sk.occ[j * sk.nx + i] == 1:
				var rr := sk.rid[j * sk.nx + i]
				var rk := "rid_" + ("yok" if rr < 0 else String(sk.streets[rr]["ad"]) + "_" + String(sk.streets[rr]["tur"]))
				say[rk] = int(say.get(rk, 0)) + 1
			say[key] = int(say.get(key, 0)) + 1
	print("G22BSONDA daire occ=%s" % [say])
	# 3) boş kareler: hub dairesi (x < 2: nöbet açıklığı hariç) ve iç mahalle çevresi (IC_RECT + 3 m dışı, alan/daire)
	_bos_kare(sk, "hub", func(l: Vector2) -> bool: return l.length() <= 54.0 and l.x <= 2.0, xf, Vector2.ZERO)
	var kutu: Rect2 = IstSehir.saray_alani().grow(2.0) if IstSehir.active != null else Rect2()
	var icr := ByzCity.IC_RECT.grow(3.0)
	_bos_kare(sk, "saray", func(l: Vector2) -> bool:
		var w := _w(xf, l + so)
		return (kutu.has_point(w) or l.length() <= 54.0) and not icr.has_point(l), xf, so)
	# 4) çimen ışınları (kare 01 / 6'nın ilk bakışı: hub yereli (−20, −14))
	var en := 0.0
	for a in range(-40, 41, 5):
		var dir := Vector2.from_angle(deg_to_rad(a))
		var run := 0.0
		var best := 0.0
		var d := 0.0
		while d < 90.0:
			var l := Vector2(-20.0, -14.0) + dir * d
			if l.x >= 18.0:
				break
			var cv := sk.cell(_w(xf, l).x, _w(xf, l).y)
			if cv == 0 or cv == 3:
				run += 0.5
				best = maxf(best, run)
			else:
				run = 0.0
			d += 0.5
		en = maxf(en, best)
		print("G22BSONDA cimen bakis=%d en_uzun=%.1f" % [a, best])
	print("G22BSONDA cimen OZET en_uzun=%.1f esik=12 durum=%s" % [en, "PASS" if en <= 12.0 else "FAIL"])
	# 5) yol sürekliliği: sur parçasının sokak ağzı → hub yolu → bağlantı → saray yolu → iç sokak ağzı
	var hat := _hat(sk, xf)
	var kopuk := 0
	var en_dar := INF
	var orn: Array = []
	var nk := 0
	for i in hat.size() - 1:
		var a: Vector2 = hat[i]
		var b: Vector2 = hat[i + 1]
		var L := a.distance_to(b)
		var nn := maxi(1, int(L))
		var dd := (b - a) / maxf(L, 0.001)
		for k in nn:
			var p := a.lerp(b, float(k) / nn)
			nk += 1
			if sk.cell(p.x, p.y) != 1 and not (sk.cell(p.x, p.y) == 3 and _l(xi, p).x >= 16.5 and _l(xi, p).x < 40.0):
				kopuk += 1
				if orn.size() < 8:
					orn.append(_l(xi, p).snapped(Vector2.ONE * 0.5))
				continue
			if sk.cell(p.x, p.y) != 1:
				continue
			var nr := Vector2(-dd.y, dd.x)
			var gen := 0.0
			for sgn: float in [1.0, -1.0]:
				var s := 0.0
				while s < 12.0 and sk.cell(p.x + nr.x * sgn * (s + 0.25), p.y + nr.y * sgn * (s + 0.25)) == 1:
					s += 0.25
				gen += s
			en_dar = minf(en_dar, gen)
	print("G22BSONDA yol nokta=%d kopuk=%d en_dar=%.2f ornek=%s" % [nk, kopuk, en_dar, orn])
	# 6) senaryo yerleri
	var yeni := _yeni_izler(sk)
	var kotu := 0
	var yerler := _yerler()
	for y: Array in yerler:
		var w: Vector2 = y[1]
		var en_y := INF
		var hangi := ""
		for z: Array in yeni:
			var pg: PackedVector2Array = z[1]
			var dist := 0.0 if Geometry2D.is_point_in_polygon(w, pg) else _poly_uz(w, pg)
			if dist < en_y:
				en_y = dist
				hangi = String(z[0])
		var ok := en_y >= 3.0
		if not ok:
			kotu += 1
		print("G22BSONDA yer ad=%s yerel=%s en_yakin=%.1f (%s) durum=%s" % [y[0], y[2], en_y, hangi, "PASS" if ok else "FAIL"])
	var en_x := -INF
	var en_ad := ""
	for z: Array in yeni:
		for p: Vector2 in (z[1] as PackedVector2Array):
			var l := _l(xi, p)
			if l.length() < 70.0 and l.x > en_x:
				en_x = l.x
				en_ad = String(z[0])
	print("G22BSONDA dolgu_en_dogu x=%.1f (%s) esik=14" % [en_x, en_ad])
	_harita(sk, xf, "hub", Vector2.ZERO)
	_harita(sk, xf, "saray", so)
	print("G22BSONDA OZET yer=%d kotu=%d yeni_iz=%d dolgu_en_dogu_x=%.1f kopuk=%d en_dar=%.2f cimen=%.1f" % [yerler.size(), kotu, yeni.size(), en_x, kopuk, en_dar, en])


## Hub (ya da iç grup) yerelinde occ haritası: x −80…60, z −80…60, 4 px/m (+x sağa, +z aşağı); yeni kayıtlar işaretli
func _harita(sk: IstSokak, xf: Transform3D, ad: String, ofs: Vector2) -> void:
	var dir := ""
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("harita="):
			dir = a.get_slice("=", 1)
	if dir == "":
		return
	var renk := [Color("6a8a4a"), Color("b8a888"), Color("c04030"), Color("505050"), Color("2040a0"), Color("d0c040"), Color("907050")]
	var img := Image.create(560, 560, false, Image.FORMAT_RGB8)
	for py in 560:
		for px in 560:
			var l := Vector2(-80.0 + px * 0.25, -80.0 + py * 0.25) + ofs
			var w := _w(xf, l)
			var o := sk.cell(w.x, w.y)
			img.set_pixel(px, py, renk[clampi(o, 0, 6)])
	var tb: Dictionary = _dl(sk).get("taban", {})
	var xi := xf.affine_inverse()
	var nokta := func(w: Vector2, c: Color, r: int) -> void:
		var l := _l(xi, w) - ofs
		var px := int((l.x + 80.0) * 4.0)
		var py := int((l.y + 80.0) * 4.0)
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if px + dx >= 0 and px + dx < 560 and py + dy >= 0 and py + dy < 560:
					img.set_pixel(px + dx, py + dy, c)
	if not tb.is_empty():
		for i in range(int(tb["houses"]), int(tb["houses"]) + int(_dl(sk).get("ev", 0))):
			nokta.call(sk.houses[i]["c"], Color.BLACK, 3)
		for i in range(int(tb["oge"]), sk.oge.size()):
			nokta.call(sk.oge[i]["c"], Color.WHITE, 2)
		for i in range(int(tb["doku"]), sk.doku.size()):
			nokta.call(sk.doku[i]["c"], Color.MAGENTA, 3)
	for p: Vector2 in (_dl(sk).get("yol", PackedVector2Array()) as PackedVector2Array):
		nokta.call(p, Color.CYAN, 1)
		if ad == "hub":
			var lp := _l(xi, p)
			var px := int((lp.x + 80.0) * 4.0)
			var py := int((lp.y + 80.0) * 4.0)
			print("G22BSONDA yolnokta yerel=%s occ=%d piksel=(%d,%d) img=%s" % [lp.snapped(Vector2.ONE * 0.1), sk.cell(p.x, p.y), px, py, img.get_pixel(clampi(px + 6, 0, 559), py)])
	img.save_png(dir.path_join("harita_%s.png" % ad))
	print("G22BSONDA harita %s" % dir.path_join("harita_%s.png" % ad))


func _w(xf: Transform3D, l: Vector2) -> Vector2:
	var w := xf * Vector3(l.x, 0.0, l.y)
	return Vector2(w.x + IstGeo.OX, w.z + IstGeo.OZ)


func _l(xi: Transform3D, w: Vector2) -> Vector2:
	var l := xi * Vector3(w.x - IstGeo.OX, 0.0, w.y - IstGeo.OZ)
	return Vector2(l.x, l.z)


func _bos_kare(sk: IstSokak, ad: String, icinde: Callable, xf: Transform3D, ofs: Vector2) -> void:
	var n := 0
	var bos := 0
	var orn: Array = []
	for zi in range(-14, 14):
		for xi_ in range(-14, 14):
			var l0 := Vector2(xi_ * 10.0, zi * 10.0)
			var tam := true
			for c: Vector2 in [l0, l0 + Vector2(10, 0), l0 + Vector2(0, 10), l0 + Vector2(10, 10)]:
				if not icinde.call(c):
					tam = false
			if not tam:
				continue
			n += 1
			var dolu := false
			for b in 10:
				for a in 10:
					var w := _w(xf, l0 + Vector2(a + 0.5, b + 0.5) + ofs)
					var cv := sk.cell(w.x, w.y)
					if cv != 0 and cv != 3:
						dolu = true
						break
				if dolu:
					break
			if not dolu:
				bos += 1
				if orn.size() < 10:
					orn.append(l0)
	print("G22BSONDA bos yer=%s kare=%d bos=%d oran=%.3f ornek=%s" % [ad, n, bos, float(bos) / maxf(n, 1), orn])


## Kapıdan iç mahalleye yürüyüş hattı (v2 dünya noktaları)
func _hat(sk: IstSokak, xf: Transform3D) -> Array:
	var out: Array = []
	if not _dl(sk).has("yol"):
		return out
	for p: Vector2 in (_dl(sk)["yol"] as PackedVector2Array):
		out.append(p)
	var J: Vector2 = _dl(sk)["J"]
	var uc: Vector2 = _dl(sk)["uc"]
	out.append(uc)
	# saray yolu parçaları (uc'tan başlayıp sırayla)
	var parca: Array = []
	for st: Dictionary in sk.streets:
		if String(st["ad"]) == "saray_yolu":
			parca.append(st["pts"])
	var son: Vector2 = uc
	while not parca.is_empty():
		var bi := 0
		var bd := INF
		for i in parca.size():
			var pl: PackedVector2Array = parca[i]
			var d0 := pl[0].distance_to(son)
			if d0 < bd:
				bd = d0
				bi = i
		var pl2: PackedVector2Array = parca[bi]
		parca.remove_at(bi)
		for p: Vector2 in pl2:
			out.append(p)
		son = pl2[pl2.size() - 1]
	if _dl(sk).has("saray_agiz"):
		for p: Vector2 in (_dl(sk)["saray_agiz"] as Array).slice(1):
			out.append(p)
	print("G22BSONDA hat J=%s uc=%s nokta=%d" % [J, uc, out.size()])
	return out


## Taban uzunluğundan sonra eklenen kayıtların ayak izleri (dünya çokgenleri)
func _yeni_izler(sk: IstSokak) -> Array:
	var out: Array = []
	var tb: Dictionary = _dl(sk).get("taban", {})
	if tb.is_empty():
		return out
	for i in range(int(tb["houses"]), int(tb["houses"]) + int(_dl(sk).get("ev", 0))):
		var h: Dictionary = sk.houses[i]
		var dm := IstEvler.dims(int(h["v"]))
		out.append(["ev", _rect(h["c"], float(h["yaw"]), Vector2(dm.x + 1.4, dm.z))])
	for i in range(int(tb["doku"]), sk.doku.size()):
		var d: Dictionary = sk.doku[i]
		out.append(["doku_" + String(d["tur"]), _rect(d["c"], float(d["yaw"]), (d["alan"] as Vector2) + Vector2(1.2, 1.2))])
	for i in range(int(tb["oge"]), sk.oge.size()):
		var o: Dictionary = sk.oge[i]
		var tur := String(o["tur"])
		var r := 4.0
		if tur.begins_with("set_") and AyrintiSet.PLACE.has(tur.trim_prefix("set_")):
			# setin gerçek ayak izi: yerleşim tablosunun noktaları (ölçek 1,2) + 1,2 m
			var lo := Vector2(INF, INF)
			var hi := Vector2(-INF, -INF)
			for e: Array in AyrintiSet.PLACE[tur.trim_prefix("set_")]:
				var q := Vector2(float(e[1]), float(e[3])) * 1.2
				lo = Vector2(minf(lo.x, q.x), minf(lo.y, q.y))
				hi = Vector2(maxf(hi.x, q.x), maxf(hi.y, q.y))
			lo -= Vector2(1.2, 1.2)
			hi += Vector2(1.2, 1.2)
			var yw := float(o["yaw"])
			var u := Vector2(cos(yw), -sin(yw))
			var v := Vector2(sin(yw), cos(yw))
			var c: Vector2 = o["c"]
			out.append(["oge_" + tur, PackedVector2Array([c + u * lo.x + v * lo.y, c + u * hi.x + v * lo.y, c + u * hi.x + v * hi.y, c + u * lo.x + v * hi.y])])
			continue
		elif tur.begins_with("set_"):
			r = 9.0
		elif tur == "ciftlik":
			r = 13.0
		elif tur == "agac_kumesi":
			r = 8.5                       # 3–6 ağaç, merkezden 2 + i·1,3 m
		elif tur == "kulube_bag" or tur == "kuyu":
			r = 2.8
		elif tur == "agil":
			r = 5.0                       # çit halkası r 4,5 (saman yığını yan tarafta)
		elif tur == "yama_duvar":
			continue
		out.append(["oge_" + tur, _rect(o["c"], 0.0, Vector2(r, r) * 2.0)])
	for i in range(int(tb["avlu"]), sk.avlu.size()):
		var a: Dictionary = sk.avlu[i]
		var c: Vector2 = a["c"]
		var u: Vector2 = a["u"]
		var v: Vector2 = a["v"]
		var hx := float(a["hx"])
		var hz := float(a["hz"])
		out.append(["avlu", PackedVector2Array([c - u * hx - v * hz, c + u * hx - v * hz, c + u * hx + v * hz, c - u * hx + v * hz])])
	for i in range(int(tb["meydan"]), sk.meydan.size()):
		out.append(["meydan", _rect(sk.meydan[i]["c"], 0.0, Vector2(12.0, 12.0))])
	return out


func _rect(c: Vector2, yaw: float, sz: Vector2) -> PackedVector2Array:
	var u := Vector2(cos(yaw), -sin(yaw))
	var v := Vector2(sin(yaw), cos(yaw))
	var hx := sz.x * 0.5
	var hz := sz.y * 0.5
	return PackedVector2Array([c - u * hx - v * hz, c + u * hx - v * hz, c + u * hx + v * hz, c - u * hx + v * hz])


func _poly_uz(p: Vector2, pg: PackedVector2Array) -> float:
	var best := INF
	for i in pg.size():
		best = minf(best, p.distance_to(Geometry2D.get_closest_point_to_segment(p, pg[i], pg[(i + 1) % pg.size()])))
	return best


## Senaryo yerleri (D15): [ad, v2 dünya, yerel]; sur parçası hub yerelinde, iç mahalle iç grup yerelinde (+ SARAY_OFS)
func _yerler() -> Array:
	var xf: Transform3D = SurHub.hub_v2()
	var so := Vector2(SurHub.SARAY_OFS.x, SurHub.SARAY_OFS.z)
	var out: Array = []
	var sur := func(ad: String, v: Vector3) -> void: out.append([ad, _w(xf, Vector2(v.x, v.z)), "hub(%.1f,%.1f)" % [v.x, v.z]])
	var ic := func(ad: String, v: Vector3) -> void: out.append([ad, _w(xf, Vector2(v.x, v.z) + so), "ic(%.1f,%.1f)" % [v.x, v.z]])
	var c6: Dictionary = load("res://scripts/chapter6.gd").get_script_constant_map()
	var pr: Array = c6["PERCHES"]
	for i in 4:
		ic.call("6b_tunek_%d" % i, pr[i])
	sur.call("6b_tunek_4_fici", ByzCity.FICI_POS)
	sur.call("6b_tunek_5_masa", pr[5])
	sur.call("6b_kararma_ficiya_11m", ByzCity.FICI_POS + Vector3(-1.5, 0.0, 10.9))
	sur.call("6b_10h_sokak_agzi_yerlesme", Vector3(ByzCity.BOLME_X + 2.0, 0.0, -14.0))
	sur.call("6b_giust_yani", ByzCity.GIUST_POS + Vector3(-3.2, 0.0, 1.6))
	sur.call("6b_giust_yani2", ByzCity.GIUST_POS + Vector3(-2.6, 0.0, 1.2))
	sur.call("6b_kapi_yani", ByzCity.EXIT_POS + Vector3(-6.0, 0.0, 0.0))
	sur.call("6b_niko_kapi", ByzCity.EXIT_POS + Vector3(-5.2, 0.0, -1.3))
	sur.call("6b_martı_sur", Vector3(30.0, 0.0, -14.0))
	sur.call("6b_vista_sur", Vector3(34.0, 0.0, -14.0))
	sur.call("GIUST_POS", ByzCity.GIUST_POS)
	sur.call("EXIT_POS", ByzCity.EXIT_POS)
	sur.call("7b_iz_walls", ByzCity.GIUST_POS + Vector3(-3.5, 0.0, 2.5))
	sur.call("7b_iz_outside", ByzCity.EXIT_POS + Vector3(-2.4, 0.0, 1.4))
	sur.call("10h_kapidan_giris", ByzCity.EXIT_POS - Vector3(3.0, 0.0, 0.0))
	sur.call("10h_gece_niko", ByzCity.FICI_POS + Vector3(1.4, 0.0, 2.2))
	sur.call("10h_gedik", load("res://scripts/chapter10h.gd").get_script_constant_map()["BREACH"])
	for r: Rect2 in [Rect2(24.0, -24.0, 12.0, 18.0), Rect2(21.0, -12.0, 13.0, 19.0), Rect2(27.0, -1.0, 9.0, 9.0),
			Rect2(ByzCity.FICI_POS.x - 4.0, ByzCity.FICI_POS.z - 2.0, 7.0, 13.0), Rect2(ByzCity.BOLME_X, -18.5, 6.0, 8.5)]:
		for k in 4:
			var q := r.position + Vector2(r.size.x if k & 1 else 0.0, r.size.y if k & 2 else 0.0)
			sur.call("dress_reserved_%d_%d_%d" % [int(r.position.x), int(r.position.y), k], Vector3(q.x, 0.0, q.y))
	if bolum == "12b" and ch != null:
		for ad: String in ["WALL_TOP", "EMP_AT", "DOOR"]:
			var v = ch.get(ad)
			if v is Vector3:
				sur.call("12b_" + ad, v)
	ic.call("START", ByzCity.START)
	ic.call("START_rapor_kapisi", ByzCity.START + Vector3(0.0, 0.0, 2.6))
	ic.call("13_dogus", ByzCity.START + Vector3(0.0, 0.0, -4.0))
	ic.call("EMPEROR_POS", ByzCity.EMPEROR_POS)
	ic.call("NIKO_POS", ByzCity.NIKO_POS)
	ic.call("CELL_START", ByzCity.CELL_START)
	ic.call("7b_iz_kancilarya", Vector3(-2.2, 0.0, -26.5))
	ic.call("24_ROUTE_A", Vector3(0.0, 0.0, -24.0))
	ic.call("24_ROUTE_B", Vector3(0.0, 0.0, 6.0))
	for k in 4:
		var r := ByzCity.IC_RECT
		ic.call("IC_RECT_kose_%d" % k, Vector3(r.position.x + (r.size.x if k & 1 else 0.0), 0.0, r.position.y + (r.size.y if k & 2 else 0.0)))
	ic.call("ic_sokak_agzi", Vector3(ByzCity.BOLME_X, 0.0, -14.25))
	return out


## D16: kapı → uc → iç mahallenin sokak ağzı hattında yürüyüş (oyuncu fiziğiyle; çarpışma penceresi yol boyunca yenilenir)
func _yuru() -> void:
	var sk: IstSokak = IstSehir.sokak
	var pl := get_tree().get_first_node_in_group("player") as Player
	if pl == null or IstBaglama.kok == null:
		print("G22BSONDA yuru oyuncu_yok")
		return
	var kok := IstBaglama.kok
	var xf: Transform3D = SurHub.hub_v2()
	var hat := _hat(sk, xf)
	if hat.is_empty():
		print("G22BSONDA yuru hat_yok")
		return
	# başlangıç: sur parçasının üstünde, kapının şehir yanı (EXIT_POS − 6) → sokak ağzı
	var yerel_bas := Vector2(ByzCity.EXIT_POS.x - 6.0, ByzCity.EXIT_POS.z)
	var bas := _w(xf, yerel_bas)
	var nokt: Array = [_w(xf, Vector2(24.0, -6.0)), _w(xf, Vector2(21.0, -14.25))]
	# hat 6 m'de bir
	var acc := 0.0
	for i in hat.size() - 1:
		var a: Vector2 = hat[i]
		var b: Vector2 = hat[i + 1]
		var L := a.distance_to(b)
		var t := 0.0
		while t < L:
			if acc >= 6.0:
				nokt.append(a.lerp(b, t / maxf(L, 0.001)))
				acc = 0.0
			t += 1.0
			acc += 1.0
	nokt.append(hat[hat.size() - 1])
	var g := func(w: Vector2) -> Vector3:
		return kok.to_global(Vector3(w.x, IstGeo.h(w.x, w.y), w.y))
	var bp: Vector3 = g.call(bas)
	bp.y = city.to_global(Vector3(ByzCity.EXIT_POS.x - 6.0, 0.0, ByzCity.EXIT_POS.z)).y + 0.1
	IstBaglama.dunya.carpisma_yenile(kok.to_local(bp))
	for i in 10:
		await get_tree().physics_frame
	pl.global_position = bp
	pl.velocity = Vector3.ZERO
	pl.set("frozen", false)
	Engine.time_scale = 1.0
	for i in 20:
		await get_tree().physics_frame
	var takil := 0
	var dus := 0
	var yol := 0.0
	var son := pl.global_position
	var son_yen := pl.global_position
	var t0 := Time.get_ticks_msec()
	for k in nokt.size():
		var hedef: Vector3 = g.call(nokt[k])
		var t := 0.0
		var best := INF
		var iz := 0.0
		while t < 30.0:
			pl.set("frozen", false)
			pl.face(Vector3(hedef.x, pl.global_position.y + 1.4, hedef.z))
			Input.action_press("move_forward")
			await get_tree().physics_frame
			t += get_physics_process_delta_time()
			var p := pl.global_position
			yol += Vector2(p.x - son.x, p.z - son.z).length()
			son = p
			if p.distance_to(son_yen) > 40.0:
				IstBaglama.dunya.carpisma_yenile(kok.to_local(p))
				son_yen = p
			var ky := kok.to_local(p)
			if p.y < kok.to_global(Vector3(ky.x, IstGeo.h(ky.x, ky.z), ky.z)).y - 1.5:
				dus += 1
				print("G22BSONDA yuru dusme nokta=%d p=%s" % [k, p.snapped(Vector3.ONE * 0.1)])
				pl.global_position = hedef + Vector3(0, 0.5, 0)
				break
			var dd := Vector2(p.x - hedef.x, p.z - hedef.z).length()
			if dd < best - 0.2:
				best = dd
				iz = t
			if dd < 1.2:
				break
			if t - iz > 6.0:
				takil += 1
				print("G22BSONDA yuru takilma nokta=%d p=%s hedef=%s" % [k, p.snapped(Vector3.ONE * 0.1), hedef.snapped(Vector3.ONE * 0.1)])
				pl.global_position = hedef + Vector3(0, 0.5, 0)
				break
	Input.action_release("move_forward")
	print("G22BSONDA yuru OZET nokta=%d takilma=%d dusme=%d yol=%.0f sure_ms=%d" % [nokt.size(), takil, dus, yol, Time.get_ticks_msec() - t0])


## IstSokak.dolgu (tabanda — 37ae2b7d — yok: boş)
func _dl(sk: IstSokak) -> Dictionary:
	var d = sk.get("dolgu")
	return d if d is Dictionary else {}


## Arazi çarpışması (görünen arazi ağıyla aynı ızgara) ile IstGeo.h ve hub düzlemi: dolgu noktalarında (D7: bölümde ve uçuşta)
func _yukseklik() -> void:
	if IstBaglama.kok == null or IstBaglama.dunya == null:
		return
	for lp: Vector2 in [Vector2(8.0, -30.0), Vector2(8.0, 10.0), Vector2(-10.0, -14.0), Vector2(-30.0, 10.0), Vector2(-40.0, -30.0), Vector2(16.0, -30.0), Vector2(25.0, -14.0)]:
		var w3: Vector3 = SurHub.hub_v2() * Vector3(lp.x, 0.0, lp.y)
		var top := IstBaglama.kok.to_global(Vector3(w3.x, 80.0, w3.z))
		IstBaglama.dunya.carpisma_yenile(IstBaglama.kok.to_local(top))
		for i in 3:
			await get_tree().physics_frame
		var hit := IstBaglama.kok.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(top, top + Vector3(0, -160, 0)))
		print("G22BSONDA yukseklik bolum=%s yerel=%s geo_h=%.3f h_ham=%.3f hub_y=%.3f carp_y=%.3f %s" % [bolum, lp, IstGeo.h(w3.x, w3.z), IstGeo.h_ham(w3.x, w3.z), SurHub.hub_v2().origin.y, IstBaglama.kok.to_local(hit["position"]).y if hit else -99.0, String(hit["collider"].name) if hit else ""])
