extends Node3D
## IstHayatYakin önizlemesi (docs/_ajan/gorev/istanbul_parcalar.md "hayat-yakin"): v2'de Mese, mahalle sokağı, iskele,
## meydan, sur dibi; oyuncu gözü yüksekliğinde (1,65 m) kareler + ISTKISI sayımı.
##   godot --path . res://tests/_ist/hayat_yakin_onizleme.tscn -- gece=0|1 shots=KLASÖR sahne=mese,sokak,iskele,meydan,sur
##       bekle=SN (her sahnede akış/yürüyüş süresi) tekrar=N (aynı sahneden zaman aralıklı kare)
var gece := false
var shots := ""
var sahneler := "mese,sokak,iskele,meydan,sur"
var bekle := 6.0
var tekrar := 2
var cam: Camera3D
var dunya: IstDunya
var hy: IstHayatYakin
var sokak: IstSokak


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"gece": gece = kv[1] == "1"
			"shots": shots = kv[1]
			"sahne": sahneler = kv[1]
			"bekle": bekle = kv[1].to_float()
			"tekrar": tekrar = kv[1].to_int()
	cam = Camera3D.new()
	cam.far = 3000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var w0 := IstGeo.w2(0.0, 0.0)
	cam.global_position = Vector3(w0.x, 30.0, w0.y)
	IstDunya.butce_us = 250000
	dunya = IstDunya.build(self, gece, cam.global_position) as IstDunya
	dunya.izle = cam
	sokak = IstSehir.sokak
	hy = IstHayatYakin.attach(dunya, cam, gece)
	hy.hizli_isinma = true
	_calis.call_deferred()


func _bekle_arazi(sn := 25.0) -> void:
	var t0 := Time.get_ticks_msec()
	for i in 6:
		await get_tree().process_frame
	while Time.get_ticks_msec() - t0 < sn * 1000.0:
		if dunya.olcum()["isler"] == 0:
			break
		await get_tree().process_frame
	for i in 4:
		await get_tree().process_frame


func _en_yakin(hedef: Vector2, uygun: Callable, acik := false) -> int:
	var best := -1
	var bd := INF
	for g in hy._P.size():
		var p: Vector2 = hy._P[g]
		var d := p.distance_to(hedef)
		if d < bd and uygun.call(g) and (not acik or _acik(p, _yon(g))):
			bd = d
			best = g
	return best


## Noktadan yöne 28 m boyunca yol/boş hücre mi (duvara bakmasın)
func _acik(p: Vector2, d: Vector2) -> bool:
	for k in range(1, 15):
		var q := p + d * (k * 2.0)
		var c := sokak.cell(q.x, q.y)
		if c != 0 and c != 1:
			return false
	return true


func _tur(g: int) -> String:
	var p: Vector2 = hy._P[g]
	return String(IstGeo.mahalle(p.x, p.y).get("tur", ""))


func _yon(g: int) -> Vector2:
	var s: int = hy._PS[g]
	var i: int = hy._PI[g]
	var a: Vector2 = hy._P[hy._s0[s] + maxi(i - 1, 0)]
	var b: Vector2 = hy._P[hy._s0[s] + mini(i + 1, hy._sn[s] - 1)]
	return (b - a).normalized()


## Sahne adı → [kamera konumu (x, z), bakış yönü (x, z)]
func _sahne(ad: String) -> Array:
	var c0 := IstGeo.w2(0.0, 0.0)
	match ad:
		"mese":
			var g := _en_yakin(IstGeo.w2(-300.0, 100.0), func(k): return hy._stur[hy._PS[k]] == "mese")
			# şeridin içinde, sağ tarafta
			var d := _yon(g)
			var p: Vector2 = hy._P[g] + Vector2(-d.y, d.x) * 2.0
			return [p, d]
		"sokak":
			var g := _en_yakin(c0 + Vector2(-80, 80), func(k): return hy._stur[hy._PS[k]] == "sokak" and _tur(k) in ["carsi", "sik"] and hy._sn[hy._PS[k]] > 12, true)
			return [hy._P[g], _yon(g)]
		"iskele":
			var g := _en_yakin(IstGeo.w2(-700.0, 900.0), func(k): return _tur(k) == "liman" and IstGeo.h(hy._P[k].x, hy._P[k].y) > 0.5)
			var p: Vector2 = hy._P[g]
			var bd := Vector2.DOWN
			for k in 16:
				var dv := Vector2.from_angle(k * TAU / 16.0)
				if IstGeo.su(p.x + dv.x * 18.0, p.y + dv.y * 18.0):
					bd = dv
					break
			return [p, bd]
		"meydan":
			var best := Vector2.ZERO
			var bd := INF
			for m: Dictionary in sokak.meydan:
				var c: Vector2 = m["c"]
				var d := c.distance_to(c0)
				if d < bd and String(IstGeo.mahalle(c.x, c.y).get("tur", "")) in ["carsi", "sik"]:
					bd = d
					best = c
			# meydana 9 m uzaktan, önü açık yönden bak
			for k in 16:
				var dv := Vector2.from_angle(k * TAU / 16.0)
				var q := best + dv * 9.0
				if (sokak.cell(q.x, q.y) in [0, 1, 5]) and _acik(q, -dv):
					return [q, -dv]
			return [best + Vector2(9, 0), Vector2.LEFT]
		"sur":
			var kara := IstGeo.yol("kara_suru")
			var m := kara[kara.size() / 2]
			var g := _en_yakin(m, func(k): return _tur(k) == "sur_dibi")
			var p: Vector2 = hy._P[g]
			# sura en yakın nokta
			var nn := kara[0]
			for q in kara:
				if q.distance_to(p) < nn.distance_to(p):
					nn = q
			return [p, (nn - p).normalized()]
	return [c0, Vector2.DOWN]


## Zorla yerleştirilen duran kişilerin yakın planı: sahne adı "yakin_<rol>" (satici, oturan, camasir, dilenci, isci, nobetci, sohbet, balikci)
func _yakin(ad: String) -> void:
	var rol := ad.trim_prefix("yakin_")
	var geniş := rol in ["satici"]
	var c0 := IstGeo.w2(-250.0, 100.0)
	var g := _en_yakin(c0, func(k): return hy._sw[hy._PS[k]] >= (5.5 if geniş else 3.0) and hy._sn[hy._PS[k]] > 6 and _tur(k) in ["carsi", "sik", "liman"], true)
	if rol == "isci" or rol == "nobetci":
		var kara := IstGeo.yol("kara_suru")
		g = _en_yakin(kara[kara.size() / 2], func(k): return _tur(k) == "sur_dibi")
	if rol == "balikci":
		g = _en_yakin(IstGeo.w2(-700.0, 900.0), func(k): return _tur(k) == "liman" and IstGeo.h(hy._P[k].x, hy._P[k].y) > 0.5)
	hy.kapat(true)
	hy.kapat(false)
	var before := hy.active_list().size()
	var ok := false
	for k in 8:
		var gg: int = g + k * 3
		match rol:
			"satici": ok = hy._spawn_vendor(gg)
			"oturan": ok = hy._spawn_edge(gg, "sitter")
			"camasir": ok = hy._spawn_edge(gg, "washer")
			"dilenci": ok = hy._spawn_edge(gg, "beggar")
			"isci": ok = hy._spawn_wall(gg) and true
			"nobetci": ok = hy._spawn_wall(gg) and true
			"sohbet": ok = hy._spawn_gossip(gg) > 0
			"balikci": ok = hy._spawn_fisher(gg)
		if ok:
			g = gg
			break
	print("YAKIN %s ok=%s etkin=%d" % [rol, ok, hy.active_list().size() - before])
	if not ok:
		return
	var ag: IstHayatYakin.Agent = hy.active_list()[0]
	var best := ag
	for a: IstHayatYakin.Agent in hy.active_list():
		best = a
	var fp := Vector2(best.pos.x, best.pos.z)
	var dv := Vector2.from_angle(best.yaw)
	dv = Vector2(sin(best.yaw), cos(best.yaw))
	var cp := fp + dv * 3.2
	cam.global_position = Vector3(cp.x, IstGeo.h(cp.x, cp.y) + 1.5, cp.y)
	cam.look_at(Vector3(fp.x, best.pos.y + 1.1, fp.y))
	hy._ilk = 0.0
	hy._tick_t = 99.0
	hy._stream_t = 999.0


func _calis() -> void:
	await _bekle_arazi()
	print("ONIZLEME hazir; havuz=%d" % hy.agents.size())
	hy.prof_sum_us = 0.0
	hy.prof_n = 0
	hy.prof_max_us = 0.0
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	for ad: String in sahneler.split(","):
		if ad.begins_with("yakin_"):
			await _bekle_arazi()
			_yakin(ad)
			for k in 12:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var im := get_viewport().get_texture().get_image()
			if shots != "":
				im.save_png(shots.path_join("%s_%s.png" % ["gece" if gece else "gunduz", ad]))
			continue
		var sh := _sahne(ad)
		var p: Vector2 = sh[0]
		var d: Vector2 = sh[1]
		var y := IstGeo.h(p.x, p.y) + 1.65
		cam.global_position = Vector3(p.x, y, p.y)
		cam.rotation = Vector3(deg_to_rad(-3.0), atan2(-d.x, -d.y), 0.0)
		await _bekle_arazi()
		# akış: mevcut herkes uzaktan çekilsin, yeniden dolsun
		hy._ilk = 6.0
		hy.prof_sum_us = 0.0
		hy.prof_n = 0
		hy.prof_max_us = 0.0
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < bekle * 1000.0:
			await get_tree().process_frame
		for r in tekrar:
			await RenderingServer.frame_post_draw
			var img := get_viewport().get_texture().get_image()
			var fn := "%s_%s_%d.png" % ["gece" if gece else "gunduz", ad, r]
			if shots != "":
				img.save_png(shots.path_join(fn))
			print(hy.sayim_satiri(ad + "_" + str(r)))
			var t1 := Time.get_ticks_msec()
			while Time.get_ticks_msec() - t1 < 2500:
				await get_tree().process_frame
	print("ONIZLEME bitti")
	get_tree().quit(0)
