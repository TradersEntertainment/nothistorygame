extends Node3D
## HAVADAN gezi sondası (docs/_ajan/gorev/ist2_gezi.md, bölge `havadan`). Yalnız test; oyun kodu değişmez.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/gezi_havadan.tscn -- mod=tur tur=kara yuk=30,60,120 adim=40 shots=KLASÖR
##   mod=tur    : tur=kara|marmara|halic|mese|ordugah; her adımda her yükseklikte ileri (-12°) ve aşağı (-45°) kare.
##                bas=N son=M ile dilimlenir. Çıktı: kamera listesi (HVD_KAM), RINFO.
##   mod=ucus   : sürekli uçuş (hiz=18 m/sn, sabit dt): tur=…, yuk=…, a0=ark başlangıcı, uzun=ark boyu (dünya m);
##                her karede HVD_UCUS satırı (çizim, üçgen, süreç ms, dünya kare_us, iş sırası); her `kayit` karede PNG.
##   mod=eser   : flight_data_v2 her eseri: 150/80/40/15 m yaklaşma + konma noktasından dört yön; KONMA ışın sınaması.
##   mod=eserler: yalnız eser listesini yaz.
## Adımlar dünya metresiyle (oyuncunun yaşadığı ölçek); IstGeo.S = 0,35.

var mod := "tur"
var tur := "kara"
var yuk := "30,60,120"
var adim := 40.0
var shots := ""
var bas := 0
var son := 1000000
var hiz := 18.0
var a0 := 0.0
var uzun := 400.0
var kayit := 12
var yan := 0.0          # yola dik kaydırma (dünya m; + sol)
var gece := false
var bak := "ikisi"
var cam: Camera3D
var dunya: Node3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"mod": mod = kv[1]
			"tur": tur = kv[1]
			"yuk": yuk = kv[1]
			"adim": adim = kv[1].to_float()
			"shots": shots = kv[1]
			"bas": bas = kv[1].to_int()
			"son": son = kv[1].to_int()
			"hiz": hiz = kv[1].to_float()
			"a0": a0 = kv[1].to_float()
			"uzun": uzun = kv[1].to_float()
			"kayit": kayit = kv[1].to_int()
			"yan": yan = kv[1].to_float()
			"gece": gece = kv[1] == "1"
			"bak": bak = kv[1]
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var ilk := Vector3.ZERO
	var yol := _yol(tur)
	if yol.size() > 0 and mod != "eser" and mod != "eserler":
		ilk = Vector3(yol[0].x, 60.0, yol[0].y)
	dunya = IstDunya.build(self, gece, ilk)
	IstDunya.butce_us = 250000
	cam.global_position = ilk if ilk != Vector3.ZERO else Vector3(0, 80, 0)
	for i in 3:
		await get_tree().process_frame
	match mod:
		"tur": await _tur()
		"ucus": await _ucus()
		"eser": await _eser()
		"eserler": await _eserler()
	print("HVD BITTI kurulum_ms=%.0f" % dunya.olcum()["kurulum_ms"])
	get_tree().quit(0)


# ------------------------------------------------------------------ güzergâhlar (dünya x,z)

func _yol(ad: String) -> PackedVector2Array:
	var ham := PackedVector2Array()
	match ad:
		"kara": ham = IstGeo.yol("kara_suru")
		"marmara": ham = IstGeo.yol("marmara_suru")
		"halic":
			ham = IstGeo.yol("halic_suru")
		"galata": ham = IstGeo.yol("galata_suru")
		"mese": ham = IstGeo.yol("mese")
		"ordugah":
			for u in range(0, 2500, 25):
				ham.append(IstOrdugah.at(float(u), 330.0))
		"halic_galata":
			ham = IstGeo.yol("halic_suru")
			var g := IstGeo.yol("galata_suru")
			for p in g:
				ham.append(p)
	return ham


## Çizgiyi `d` dünya metrede bir yeniden örnekle: [[nokta, teğet]]
func _ornekle(ham: PackedVector2Array, d: float) -> Array:
	var out: Array = []
	if ham.size() < 2:
		return out
	var acc := 0.0
	var next := 0.0
	for i in ham.size() - 1:
		var a := ham[i]
		var b := ham[i + 1]
		var L := a.distance_to(b)
		if L < 0.001:
			continue
		var t := (b - a) / L
		while next <= acc + L:
			out.append([a + t * (next - acc), t])
			next += d
		acc += L
	return out


func _kam_yerles(p: Vector2, t: Vector2, y: float, egim: float) -> void:
	var n := Vector2(-t.y, t.x)         # sol
	var q := p + n * yan
	var g := maxf(IstGeo.h(q.x, q.y), 0.0)
	cam.global_position = Vector3(q.x, g + y, q.y)
	# teğet (x,z) → yaw: bakış −z; Godot'ta rotation.y = atan2(-t.x, -t.y)
	cam.rotation = Vector3(deg_to_rad(egim), atan2(-t.x, -t.y), 0.0)


func _kam_satir(ad: String) -> String:
	var r := IstGeo.real(cam.global_position.x, cam.global_position.z)
	var yon := fposmod(rad_to_deg(-cam.rotation.y), 360.0)
	var g := maxf(IstGeo.h(cam.global_position.x, cam.global_position.z), 0.0)
	return "%s %.0f %.0f %.1f %.1f %.1f" % [ad, r.x, r.y, cam.global_position.y - g, yon, rad_to_deg(cam.rotation.x)]


# ------------------------------------------------------------------ bekleme ve kare

func _bekle(sn := 90.0) -> void:
	RenderingServer.render_loop_enabled = false      # bekleme sırasında çizme (yazılımla çizim kare başına ~1 sn)
	for i in 3:
		await get_tree().process_frame
	var s := IstSehir.active
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < sn * 1000.0:
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
		if bos:
			break
		await get_tree().process_frame
	for i in 2:
		await get_tree().process_frame
	RenderingServer.render_loop_enabled = true


func _kare(ad: String, bekle := true) -> void:
	if bekle:
		await _bekle()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	print("RINFO havadan %s cizim=%d ucgen=%d surec_ms=%.1f" % [ad, dc, pr, Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0])
	if shots != "":
		get_viewport().get_texture().get_image().save_png(shots.path_join(ad + ".png"))


# ------------------------------------------------------------------ mod=tur

func _tur() -> void:
	var pts := _ornekle(_yol(tur), adim)
	print("HVD tur=%s nokta=%d adim=%.0f" % [tur, pts.size(), adim])
	var yuks := yuk.split(",")
	var i := -1
	for e: Array in pts:
		i += 1
		if i < bas or i >= son:
			continue
		for ys in yuks:
			var y := ys.to_float()
			for gor in ["ileri", "asagi"]:
				if bak != "ikisi" and bak != gor:
					continue
				_kam_yerles(e[0], e[1], y, -12.0 if gor == "ileri" else -45.0)
				var ad := "%s_%03d_%s_%03d" % [tur, i, gor, int(y)]
				print("HVD_KAM ", _kam_satir(ad))
				await _kare(ad)


# ------------------------------------------------------------------ mod=ucus: sürekli uçuş

func _ucus() -> void:
	var pts := _ornekle(_yol(tur), 1.0)
	var y := yuk.split(",")[0].to_float()
	var dt := 1.0 / 60.0
	var ark := a0
	var kare := 0
	var yavas := 0
	var cmax := 0
	var tmax := 0
	var sure_top := 0.0
	var sure_max := 0.0
	var idx_son := -1
	if pts.is_empty():
		return
	# ilk konum: tam akış (uçuş başlamadan sahne kurulu olsun)
	var e0: Array = pts[clampi(int(a0), 0, pts.size() - 1)]
	_kam_yerles(e0[0], e0[1], y, -12.0)
	await _bekle()
	var bitis := a0 + uzun
	while ark < bitis and int(ark) < pts.size() - 1:
		var e: Array = pts[int(ark)]
		_kam_yerles(e[0], e[1], y, -12.0)
		var t0 := Time.get_ticks_usec()
		await get_tree().process_frame
		var s_ms := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		await RenderingServer.frame_post_draw
		var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		var o: Dictionary = dunya.olcum()
		var q := 0
		if IstSehir.active != null:
			q = IstSehir.active._queue.size()
		cmax = maxi(cmax, dc)
		tmax = maxi(tmax, pr)
		sure_top += s_ms
		sure_max = maxf(sure_max, s_ms)
		if s_ms > 50.0:
			yavas += 1
		kare += 1
		if kare % 4 == 0 or s_ms > 50.0:
			print("HVD_UCUS k=%d ark=%.1f cizim=%d ucgen=%d surec_ms=%.1f dunya_us=%d isler=%d sehir_kuyruk=%d lod=%s" % [
				kare, ark, dc, pr, s_ms, o["kare_us"], o["isler"], q, str(o["lod"])])
		if shots != "" and kare % kayit == 0:
			var ad := "ucus_%s_%03d_k%04d" % [tur, int(y), kare]
			print("HVD_KAM ", _kam_satir(ad))
			get_viewport().get_texture().get_image().save_png(shots.path_join(ad + ".png"))
		ark += hiz * dt
	print("HVD_UCUS_OZET tur=%s yuk=%.0f kare=%d en_cok_cizim=%d en_cok_ucgen=%d surec_ort_ms=%.1f surec_max_ms=%.1f yavas50=%d" % [
		tur, y, kare, cmax, tmax, sure_top / maxf(kare, 1), sure_max, yavas])


# ------------------------------------------------------------------ mod=eser

func _eserler() -> void:
	await _bekle()
	var fd := IstSehir.flight_data_v2(IstSehir.active.get_parent() if IstSehir.active else null)
	var i := 0
	for lm: Array in fd["landmarks"]:
		var r := IstGeo.real((lm[1] as Vector3).x, (lm[1] as Vector3).z)
		print("HVD_ESER %02d %s dunya=%s gercek=%.0f,%.0f r=%.0f" % [i, lm[0], str(lm[1]), r.x, r.y, lm[2]])
		i += 1
	for p: Array in fd["perches"]:
		var r := IstGeo.real((p[1] as Vector3).x, (p[1] as Vector3).z)
		print("HVD_KONMA %s dunya=%s gercek=%.0f,%.0f r=%.0f" % [p[0], str(p[1]), r.x, r.y, p[2]])


func _eser() -> void:
	# her eser için önce yakın bölgeyi tam kurmak için işaret noktasına git
	var d0 := Vector3(IstGeo.w2(0, 0).x, 80, IstGeo.w2(0, 0).y)
	cam.global_position = d0
	await _bekle()
	var fd := IstSehir.flight_data_v2(IstSehir.active.get_parent() if IstSehir.active else null)
	var lms: Array = fd["landmarks"]
	var perches: Array = fd["perches"]
	print("HVD_ESER_SAYI landmark=%d perch=%d" % [lms.size(), perches.size()])
	var pmap := {}
	for p: Array in perches:
		pmap[String(p[0])] = p
	var yonler := [["K", 0.0], ["D", 90.0], ["G", 180.0], ["B", 270.0]]
	var i := -1
	for lm: Array in lms:
		i += 1
		if i < bas or i >= son:
			continue
		var kid := String(lm[0])
		var P: Vector3 = lm[1]
		var ad := "eser_%02d_%s" % [i, kid.to_lower()]
		# yaklaşma yönü: eserin kendi etrafında sabit GB (güneybatı → kuzeydoğu bakış); kıyıya düşerse denize bakmasın
		var dir := Vector3(-0.7071, 0, 0.7071)
		for d: float in [150.0, 80.0, 40.0, 15.0]:
			var c := P + dir * d + Vector3(0, 6.0, 0)
			var g := maxf(IstGeo.h(c.x, c.z), 0.0)
			c.y = maxf(P.y + 6.0, g + 6.0)
			cam.global_position = c
			cam.look_at(P - Vector3(0, 4.0, 0), Vector3.UP)
			print("HVD_KAM ", _kam_satir("%s_y%03d" % [ad, int(d)]))
			await _kare("%s_y%03d" % [ad, int(d)])
		# konma noktası: dört yöne bak
		var pk: Array = []
		for key: String in pmap:
			var pp: Array = pmap[key]
			var kk := key.to_lower().trim_prefix("ist_")
			var al := {"galata": "galata_kulesi", "surlar": "romanos", "aya": "ayasofya"}
			var kl: String = al.get(kid.to_lower(), kid.to_lower())
			if kk == kl or (kid == "AYASOFYA" and kk == "aya"):
				pk = pp
				break
		if pk.is_empty():
			print("HVD_KONMA_YOK %s (flight_data_v2 perches içinde eşleşme yok)" % kid)
			continue
		var Q: Vector3 = pk[1]
		cam.global_position = Q + Vector3(0, 1.7, 0)
		await _bekle()
		var space := get_world_3d().direct_space_state
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(Q + Vector3(0, 1.0, 0), Q - Vector3(0, 2.0, 0)))
		print("HVD_KONMA_SINA %s q=%s carpisma=%s" % [kid, str(Q), "var" if not hit.is_empty() else "YOK"])
		for yn: Array in yonler:
			cam.global_position = Q + Vector3(0, 1.7, 0)
			cam.rotation = Vector3(0.0, -deg_to_rad(float(yn[1])), 0.0)
			print("HVD_KAM ", _kam_satir("%s_konma%s" % [ad, yn[0]]))
			await _kare("%s_konma%s" % [ad, yn[0]], false)
