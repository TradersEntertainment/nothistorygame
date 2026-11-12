extends Node3D
## DOKU-2 sondası (docs/_ajan/gorev/ist2_tur2.md "DOKU-2"): IstDunya ile v2'yi kurar, sabit bakışlardan kare alır ve
## mahalle dokusunu sayar.
##   godot --path . --resolution 1280x720 res://tests/_ist/doku2_kare.tscn -- shots=KLASÖR [on=ONEK] [sadece=ad,ad]
## Bakışlar gerçek koordinatla (doğu, kuzey m; S'den bağımsız). Yerden ve çatıdan karelerde nokta en yakın sokağa/evin
## çatısına oturtulur. Satırlar:
##   DOKU2 sayim …          ev, tip/kat dağılımı, sıra, sokak
##   DOKU2 aralik …         bitişik (0) / dar (0 < a < 1,4 m) / geçit sayıları (ev tabanları arasındaki en kısa uzaklık)
##   ISTBOS …               40 m'lik karelerde boş oranı (şehir içi), örnek boş kare koordinatları
##   RINFO doku2 <ad> …     çizim, üçgen

var shots := ""
var on := ""
var sadece: Array = []
var dunya: IstDunya
var cam: Camera3D

## ad, e, n, yükseklik ("@" mutlak), yön (pusula), eğim, kip ("" | "sokak" | "cati" | "sur")
const BAKIS := [
	["hava70", -1500.0, 250.0, "70", 125.0, -32.0, ""],
	["hava30", -1050.0, 420.0, "30", 140.0, -38.0, ""],
	["tepe", -2350.0, 450.0, "@2300", 0.0, -89.9, ""],
	["tepe_mahalle", -1450.0, 520.0, "260", 0.0, -89.9, ""],
	["tepe_batı", -3600.0, 600.0, "300", 0.0, -89.9, ""],
	["sokak", -1150.0, 330.0, "1.7", 0.0, -4.0, "sokak"],
	["sokak_bati", -3300.0, 400.0, "1.7", 0.0, -4.0, "sokak"],
	["cati", -950.0, 380.0, "1.7", 200.0, -12.0, "cati"],
	["sur_dibi30", -4250.0, 1100.0, "30", 250.0, -28.0, ""],
	["sur_dibi_yer", -4400.0, 400.0, "1.7", 0.0, -3.0, "sur"],
]


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"shots": shots = kv[1]
			"on": on = kv[1]
			"sadece": sadece = Array(kv[1].split(","))
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var w := IstGeo.w2(-1500.0, 250.0)
	cam.global_position = Vector3(w.x, 80.0, w.y)
	IstDunya.butce_us = 250000
	dunya = IstDunya.build(self, false, cam.global_position) as IstDunya
	_kareler.call_deferred()


func _bekle(sn := 25.0) -> void:
	var t0 := Time.get_ticks_msec()
	for i in 6:
		await get_tree().process_frame
	while Time.get_ticks_msec() - t0 < sn * 1000.0:
		var o := dunya.olcum()
		if o["isler"] == 0 and IstMahalleDoku.bekleyen() == 0:
			break
		await get_tree().process_frame
	for i in 6:
		await get_tree().process_frame


func _kareler() -> void:
	await _bekle(40.0)
	_sayim()
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	for b: Array in BAKIS:
		var ad: String = b[0]
		if not sadece.is_empty() and not ad in sadece:
			continue
		if not _kam(b):
			print("DOKU2 bakis_yok ", ad)
			continue
		await _bekle()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		print("RINFO doku2 %s cizim=%d ucgen=%d konum=%s" % [ad, dc, pr, cam.global_position])
		if shots != "":
			var img := get_viewport().get_texture().get_image()
			img.save_png(shots.path_join(on + ad + ".png"))
	print("DOKU2 bitti")
	get_tree().quit(0)


func _kam(b: Array) -> bool:
	var w := IstGeo.w2(b[1], b[2])
	var ys: String = b[3]
	var yaw := -deg_to_rad(float(b[4]))
	var kip: String = b[6]
	var sk: IstSokak = IstSehir.sokak
	if kip == "sokak" or kip == "sur":
		if sk == null:
			return false
		var best := Vector2.INF
		var bd := INF
		var dir := Vector2.RIGHT
		for s: Dictionary in sk.streets:
			var t := String(s["tur"])
			if kip == "sokak" and not t in ["sokak", "basamak"]:
				continue
			if kip == "sur" and t != "savunma":
				continue
			var pl: PackedVector2Array = s["pts"]
			for i in pl.size() - 1:
				var q := Geometry2D.get_closest_point_to_segment(w, pl[i], pl[i + 1])
				if q.distance_to(w) < bd:
					bd = q.distance_to(w)
					best = q
					dir = (pl[i + 1] - pl[i]).normalized()
		if best == Vector2.INF:
			if kip == "sur":
				best = w
			else:
				return false
		w = best
		yaw = atan2(-dir.x, -dir.y)
	var y := maxf(IstGeo.h(w.x, w.y), 0.0) + ys.trim_prefix("@").to_float()
	if ys.begins_with("@"):
		y = ys.substr(1).to_float()
	if kip == "cati":
		if sk == null or sk.houses.is_empty():
			return false
		var bh: Dictionary = sk.houses[0]
		var bd := INF
		for h: Dictionary in sk.houses:
			var d := (h["c"] as Vector2).distance_to(w)
			if d < bd:
				bd = d
				bh = h
		var dm := IstEvler.dims(int(bh["v"]))
		var c: Vector2 = bh["c"]
		var fr: Vector2 = bh["on"]
		w = c
		y = IstGeo.h(fr.x, fr.y) + dm.y + IstEvler.RISE + 1.7
	cam.global_position = Vector3(w.x, y, w.y)
	cam.rotation = Vector3(deg_to_rad(float(b[5])), yaw, 0.0)
	return true


## Sayım: ev ve tip dağılımı, aralıklar, 40 m'lik karelerde boşluk
func _sayim() -> void:
	var sk: IstSokak = IstSehir.sokak
	if sk == null:
		print("DOKU2 sokak yok")
		return
	var tips := {}
	var katlar := {}
	for h: Dictionary in sk.houses:
		var t := String(h["tip"])
		tips[t] = int(tips.get(t, 0)) + 1
		var dm := IstEvler.dims(int(h["v"]))
		var kat := "1" if dm.y < 4.6 else ("2" if dm.y < 7.0 else "3+")
		katlar[kat] = int(katlar.get(kat, 0)) + 1
	var st := {}
	for s: Dictionary in sk.streets:
		st[String(s["tur"])] = int(st.get(String(s["tur"]), 0)) + 1
	print("DOKU2 sayim ev=%d sira=%d tip=%s kat=%s sokak=%s doku=%d meydan=%d stats=%s" % [sk.houses.size(), sk.rows, tips, katlar, st,
		sk.doku.size(), sk.meydan.size(), sk.stats])
	# Aralıklar: ev tabanı dikdörtgenleri (cumba dahil değil) arasındaki en kısa uzaklık
	var polys: Array = []
	var hash := {}
	for i in sk.houses.size():
		var h: Dictionary = sk.houses[i]
		var dm := IstEvler.dims(int(h["v"]))
		var c: Vector2 = h["c"]
		var yaw := float(h["yaw"])
		var u := Vector2(cos(yaw), -sin(yaw))
		var v := Vector2(sin(yaw), cos(yaw))
		var pg := PackedVector2Array([c - u * dm.x * 0.5 - v * dm.z * 0.5, c + u * dm.x * 0.5 - v * dm.z * 0.5,
			c + u * dm.x * 0.5 + v * dm.z * 0.5, c - u * dm.x * 0.5 + v * dm.z * 0.5])
		polys.append(pg)
		var key := Vector2i(floori(c.x / 16.0), floori(c.y / 16.0))
		if not hash.has(key):
			hash[key] = []
		hash[key].append(i)
	var bitisik := 0
	var dar := 0
	var ornek: Array = []
	for i in polys.size():
		var c: Vector2 = sk.houses[i]["c"]
		var key := Vector2i(floori(c.x / 16.0), floori(c.y / 16.0))
		for dj in range(-1, 2):
			for di in range(-1, 2):
				for j: int in hash.get(key + Vector2i(di, dj), []):
					if j <= i:
						continue
					var d := IstSokak.poly_gap(polys[i], polys[j])
					if d < 0.05:
						bitisik += 1
					elif d < 1.4:
						dar += 1
						if ornek.size() < 6:
							ornek.append(IstGeo.real(c.x, c.y).round())
	print("DOKU2 aralik bitisik=%d dar=%d ornek=%s" % [bitisik, dar, ornek])
	# 40 m'lik karelerde boşluk (şehir içi): ev, sokak dışı doku öğesi, anıt yoksa "boş"
	var dolu := {}
	for h: Dictionary in sk.houses:
		var c: Vector2 = h["c"]
		dolu[Vector2i(floori(c.x / 40.0), floori(c.y / 40.0))] = true
	for d: Dictionary in sk.doku:
		var c: Vector2 = d["c"]
		var al: Vector2 = d["alan"]
		for oy in [-0.4, 0.0, 0.4]:
			for ox in [-0.4, 0.0, 0.4]:
				dolu[Vector2i(floori((c.x + al.x * ox) / 40.0), floori((c.y + al.y * oy) / 40.0))] = true
	for m: Dictionary in sk.meydan:
		var c: Vector2 = m["c"]
		dolu[Vector2i(floori(c.x / 40.0), floori(c.y / 40.0))] = true
	for c: Vector2 in sk.oge_noktalari():
		dolu[Vector2i(floori(c.x / 40.0), floori(c.y / 40.0))] = true
	if IstSehir.active:
		for it: Dictionary in IstSehir.active.items:
			var p: Vector3 = it["pos"]
			var r := float(it["r"])
			var n := int(ceil(r / 40.0))
			for dj in range(-n, n + 1):
				for di in range(-n, n + 1):
					var q := Vector2(p.x + di * 40.0, p.z + dj * 40.0)
					if q.distance_to(Vector2(p.x, p.z)) <= r * 0.8:
						dolu[Vector2i(floori(q.x / 40.0), floori(q.y / 40.0))] = true
	var top := 0
	var bos := 0
	var bos_ornek: Array = []
	var poly := IstGeo.kiyi("yarimada")
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for p in poly:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	for j in range(floori(lo.y / 40.0), floori(hi.y / 40.0) + 1):
		for i in range(floori(lo.x / 40.0), floori(hi.x / 40.0) + 1):
			var c := Vector2((i + 0.5) * 40.0, (j + 0.5) * 40.0)
			# karenin tamamı sur içinde ve karada
			var ic := true
			for o: Vector2 in [Vector2(-18, -18), Vector2(18, -18), Vector2(18, 18), Vector2(-18, 18)]:
				if not IstGeo.sehir_ici(c.x + o.x, c.y + o.y) or IstGeo.su(c.x + o.x, c.y + o.y):
					ic = false
			if not ic or sk.cell(c.x, c.y) == 3:
				continue
			top += 1
			if not dolu.has(Vector2i(i, j)):
				bos += 1
				if bos_ornek.size() < 12:
					bos_ornek.append(IstGeo.real(c.x, c.y).round())
	print("ISTBOS sehir_ici kare=%d bos=%d oran=%.1f%% ornek=%s" % [top, bos, 100.0 * bos / maxf(top, 1), bos_ornek])
