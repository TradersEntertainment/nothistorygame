extends Node3D
## GEZİ mese-bati sondası (yalnız test; oyun kodu değil). Kamera sur4_kare ile aynı.
##   --set=ara  --out=DOSYA     : bölge ızgarası (60 m): e n tur ad su ici  -> CSV (başsız çalışır)
##   --set=liste --liste=DOSYA --out=KLASÖR [--gece] : "ad e n yukseklik yon egim" kareleri; suya düşen düğüm atlanır
##   --set=yuru --liste=DOSYA   : gerçek oyuncu (player.gd) güzergâh yürüyüşü; satır "ad e0 n0 e1 n1"; GEZI_OLAY satırları

var out := "user://gezi"
var set_ := "liste"
var liste := ""
var gece := false
var cam: Camera3D
var dunya: Node3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"set": set_ = kv[1]
			"liste": liste = kv[1]
			"gece": gece = true
	if set_ == "ara":
		_ara()
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(out)
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var s := _satirlar()
	var ilk := Vector3.ZERO
	if s.size() > 0:
		var p: PackedStringArray = String(s[0]).split(" ", false)
		var w2 := IstGeo.w2(p[1].to_float(), p[2].to_float())
		ilk = Vector3(w2.x, 10.0, w2.y)
	dunya = IstDunya.build(self, gece, ilk)
	IstDunya.butce_us = 250000
	await get_tree().process_frame
	match set_:
		"liste": await _liste(s)
		"yuru": await _yuru(s)
	print("GEZI BITTI")
	get_tree().quit(0)


func _satirlar() -> Array:
	var r: Array = []
	var f := FileAccess.open(liste, FileAccess.READ)
	if f == null:
		return r
	while not f.eof_reached():
		var s := f.get_line().strip_edges()
		if s != "" and not s.begins_with("#"):
			r.append(s)
	return r


func _ara() -> void:
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_line("e,n,tur,ad,yogunluk,alt,su,ici,h")
	var e := -4950.0
	while e <= -1450.0:
		var n := -1900.0
		while n <= 450.0:
			var w := IstGeo.w2(e, n)
			var m := IstGeo.mahalle(w.x, w.y)
			f.store_line("%d,%d,%s,%s,%.2f,%s,%d,%d,%.1f" % [e, n, m["tur"], m["ad"], m["yogunluk"], m.get("alt", ""),
				1 if IstGeo.su(w.x, w.y) else 0, 1 if IstGeo.sehir_ici(w.x, w.y) else 0, IstGeo.h(w.x, w.y)])
			n += 60.0
		e += 60.0
	f.close()
	print("GEZI ara bitti")


func _kam_koy(k: PackedStringArray) -> void:
	var w2 := IstGeo.w2(k[1].to_float(), k[2].to_float())
	var ys := k[3]
	var y := 0.0
	if ys.begins_with("@"):
		y = ys.substr(1).to_float()
	else:
		y = maxf(IstGeo.h(w2.x, w2.y), 0.0) + ys.to_float()
	cam.global_position = Vector3(w2.x, y, w2.y)
	cam.rotation = Vector3(deg_to_rad(k[5].to_float()), -deg_to_rad(k[4].to_float()), 0.0)


func _bekle() -> void:
	for i in 4:
		await get_tree().process_frame
	var s := IstSehir.active
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 90000:
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
	for i in 3:
		await get_tree().process_frame


func _liste(s: Array) -> void:
	var n_say := 0
	for ln: String in s:
		var k := ln.split(" ", false)
		var w2 := IstGeo.w2(k[1].to_float(), k[2].to_float())
		if IstGeo.su(w2.x, w2.y) and not k[3].begins_with("@") and k[3].to_float() < 30.0:
			print("GEZI_SU atlandi ", k[0])
			continue
		_kam_koy(k)
		await _bekle()
		if not k[3].begins_with("@") and k[3].to_float() < 5.0:
			await _kaydir(k)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		print("RINFO gezi %s cizim=%d ucgen=%d" % [k[0], dc, pr])
		cam.get_viewport().get_texture().get_image().save_png(out.path_join(k[0] + ".png"))
		n_say += 1
	print("GEZI kare_sayisi=%d" % n_say)


## Gerçek oyuncu: her satır "ad e0 n0 e1 n1"; hedefe doğru ileri yürür (move_forward + sprint yok), olay sayar.
func _yuru(s: Array) -> void:
	var P = load("res://scripts/player/player.gd")
	var pl := P.new() as CharacterBody3D
	add_child(pl)
	cam.current = false
	var dn := dunya as IstDunya
	dn.izle = pl
	var toplam := 0.0
	for ln: String in s:
		var p: PackedStringArray = ln.split(" ", false)
		var a := IstGeo.w2(p[1].to_float(), p[2].to_float())
		var b := IstGeo.w2(p[3].to_float(), p[4].to_float())
		pl.global_position = Vector3(a.x, IstGeo.h(a.x, a.y) + 1.0, a.y)
		pl.velocity = Vector3.ZERO
		dn.carpisma_yenile(pl.global_position)
		for i in 180:
			await get_tree().physics_frame
		var yol := 0.0
		var son := pl.global_position
		var takili := 0
		var dusme := 0
		var t0 := Time.get_ticks_msec()
		var son_ilerleme_t := t0
		var ilerleme_noktasi := son
		var olay := 0
		Input.action_press("move_forward")
		var tick := 0
		var son_tick := 0
		while tick < 9000:
			tick += 1
			var pos := pl.global_position
			var hedef := Vector2(b.x - pos.x, b.y - pos.z)
			if hedef.length() < 4.0:
				break
			pl.rotation.y = atan2(-hedef.x, -hedef.y)
			await get_tree().physics_frame
			var q := pl.global_position
			yol += Vector2(q.x - son.x, q.z - son.z).length()
			son = q
			var g := IstGeo.h(q.x, q.z)
			if q.y - g < -0.6 and not IstGeo.su(q.x, q.z):
				dusme += 1
				var r := IstGeo.real(q.x, q.z)
				print("GEZI_OLAY dusme %d %d" % [r.x, r.y])
				pl.global_position = Vector3(q.x, g + 1.0, q.z)
			if tick - son_tick > 240:
				son_tick = tick
				if Vector2(q.x - ilerleme_noktasi.x, q.z - ilerleme_noktasi.z).length() < 1.0:
					takili += 1
					var r2 := IstGeo.real(q.x, q.z)
					print("GEZI_OLAY takilma %d %d" % [r2.x, r2.y])
					var ileri := Vector3(hedef.x, 0, hedef.y).normalized()
					pl.global_position += ileri * 6.0 + Vector3(0, 1.5, 0)
					olay += 1
				ilerleme_noktasi = q
				son_ilerleme_t = Time.get_ticks_msec()
			if IstGeo.su(q.x, q.z):
				var r3 := IstGeo.real(q.x, q.z)
				print("GEZI_OLAY suya_girdi %d %d" % [r3.x, r3.y])
				break
		Input.action_release("move_forward")
		toplam += yol / IstGeo.S
		print("GEZI_YURU %s yol_gercek=%.0f m takilma=%d dusme=%d oyun_sn=%.0f duvar_sn=%.0f" % [p[0], yol / IstGeo.S, takili, dusme, tick / 60.0, (Time.get_ticks_msec() - t0) / 1000.0])
	print("GEZI_YURU toplam=%.0f m" % toplam)


## Yer karesi yapının/çatının içine düştüyse en yakın açık yere kaydır (halka: 4, 8, 12, 18, 26 dünya m)
func _icerde(pos: Vector3) -> bool:
	var sp := get_world_3d().direct_space_state
	var q := PhysicsPointQueryParameters3D.new()
	q.position = pos
	if sp.intersect_point(q, 1).size() > 0:
		return true
	var rq := PhysicsRayQueryParameters3D.create(pos, pos + Vector3(0, 40, 0))
	return sp.intersect_ray(rq).size() > 0


func _kaydir(k: PackedStringArray) -> void:
	(dunya as IstDunya).carpisma_yenile(cam.global_position)
	for i in 3:
		await get_tree().physics_frame
	var p0 := cam.global_position
	if not _icerde(p0):
		return
	for r in [4.0, 8.0, 12.0, 18.0, 26.0]:
		for a in 8:
			var d: Vector3 = Vector3(cos(a * PI / 4.0), 0, sin(a * PI / 4.0)) * r
			var w: Vector3 = p0 + d
			w.y = maxf(IstGeo.h(w.x, w.z), 0.0) + k[3].to_float()
			if not _icerde(w):
				cam.global_position = w
				print("GEZI_KAYDIR %s %.0f dunya_m" % [k[0], r])
				return
	print("GEZI_KAYDIR %s bulunamadi" % k[0])
