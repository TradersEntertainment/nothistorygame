extends Node3D
## BİRLİK kare sondası (ortak görsel kural; scripts/world/ist/gorsel_dil.gd). Gerçek oyun kurucusu (IstDunya.build).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/birlik_kare.tscn --
##       --set=uret --out=KLASÖR --kam=DOSYA   (kameraları kurar, kareleri alır, mutlak kamera listesini DOSYA'ya yazar)
##       --set=liste --liste=DOSYA --out=KLASÖR [--sec=ad1,ad2] [--gece] [--id]
## --id: her karenin yanına kategori kimlik karesi (AD_id.png; tests/_ist/birlik_olc.py ölçer).
## Ortam değişkeni BIRLIK_YOK=1: uyum geçişi kurulmaz (ÖNCE kareleri; kod yolu aynı).
## Kamera satırı: "ad x y z rx ry" (dünya koordinatı, radyan). Kareler 1280×720 jpg (kalite 85). Sis AÇIK (oyundaki gibi).

const GD := preload("res://scripts/world/ist/gorsel_dil.gd")
const ID := preload("res://tests/_ist/birlik_id.gd")
var out := "user://birlik"
var set_ := "liste"
var liste := ""
var kam_dosya := ""
var sec: Array = []
var gece := false
var id_ := false
var en := 1000            # --en=N: N kareden sonra dur
var _say := 0
var cam: Camera3D
var dunya: Node3D
var _kam_satir: Array = []
var _rinfo: Array = []


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"set": set_ = kv[1]
			"liste": liste = kv[1]
			"kam": kam_dosya = kv[1]
			"sec": sec = Array(kv[1].split(","))
			"gece": gece = true
			"id": id_ = true
			"en": en = kv[1].to_int()
	DirAccess.make_dir_recursive_absolute(out)
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var ilk := Vector3.ZERO
	var satirlar: Array = []
	if set_ == "liste":
		satirlar = _satirlar()
		if satirlar.size() > 0:
			var p: PackedStringArray = (satirlar[0] as String).split(" ", false)
			ilk = Vector3(p[1].to_float(), p[2].to_float(), p[3].to_float())
	else:
		ilk = _kara(0.35, 150.0)
	var t0 := Time.get_ticks_msec()
	dunya = IstDunya.build(self, gece, ilk)
	print("BIRLIK yukleme_ms=%d birlik=%s" % [Time.get_ticks_msec() - t0, not OS.has_environment("BIRLIK_YOK")])
	IstDunya.butce_us = 250000
	await get_tree().process_frame
	if set_ == "liste":
		for s: String in satirlar:
			var p: PackedStringArray = s.split(" ", false)
			if not sec.is_empty() and not p[0] in sec:
				continue
			cam.global_position = Vector3(p[1].to_float(), p[2].to_float(), p[3].to_float())
			cam.rotation = Vector3(p[4].to_float(), p[5].to_float(), 0.0)
			await _shot(p[0])
	else:
		await _uret()
		if kam_dosya != "":
			var f := FileAccess.open(kam_dosya, FileAccess.WRITE)
			for s: String in _kam_satir:
				f.store_line(s)
			f.close()
	print("BIRLIK sayac ", GD.sayac)
	print("BIRLIK BITTI")
	get_tree().quit(0)


func _satirlar() -> Array:
	var o: Array = []
	var f := FileAccess.open(liste, FileAccess.READ)
	if f == null:
		return o
	while not f.eof_reached():
		var s := f.get_line().strip_edges()
		if s != "" and not s.begins_with("#"):
			o.append(s)
	return o


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
			var yy := y as IstOrdugahYonetici
			yy.butce_us = 400000
			if not yy.kuyruk.is_empty():
				bos = false
		if bos:
			break
		await get_tree().process_frame
	for i in 3:
		await get_tree().process_frame
	var g = GD.aktif
	if g != null:
		g.bitir()
	await get_tree().process_frame


func _shot(ad: String) -> void:
	_say += 1
	if _say > en:
		return
	await _bekle()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	print("RINFO birlik %s cizim=%d ucgen=%d" % [ad, dc, pr])
	var img := get_viewport().get_texture().get_image()
	img.save_jpg(out.path_join(ad + ".jpg"), 0.85)
	if id_:
		await ID.cek(get_tree(), out.path_join(ad + "_id.png"))


func _bak(ad: String, from: Vector3, to: Vector3) -> void:
	cam.global_position = from
	cam.look_at(to, Vector3.UP)
	_kam_satir.append("%s %.3f %.3f %.3f %.5f %.5f" % [ad, from.x, from.y, from.z, cam.rotation.x, cam.rotation.y])
	await _shot(ad)


func _hat() -> Array:
	var pl := IstSehir._sade(IstGeo.yol("kara_suru"))
	var L := 0.0
	for i in pl.size() - 1:
		L += pl[i].distance_to(pl[i + 1])
	return [pl, L]


## Kara suru üstünde t (0..1) noktasından dışarı d m (d < 0 şehir içi): dünya noktası (yer + 0)
func _kara(t: float, d: float) -> Vector3:
	var h := _hat()
	var q := _hat_at(h[0], float(h[1]) * t)
	var o := IstSehir._out(q["d"], q["p"], "kara_suru")
	var p: Vector2 = q["p"] + o * d
	return Vector3(p.x, IstGeo.h(p.x, p.y), p.y)


func _yon(t: float) -> Array:
	var h := _hat()
	var q := _hat_at(h[0], float(h[1]) * t)
	var o := IstSehir._out(q["d"], q["p"], "kara_suru")
	return [q["p"], q["d"], o]


static func _hat_at(pl: PackedVector2Array, sv: float) -> Dictionary:
	var acc := 0.0
	for i in pl.size() - 1:
		var l := pl[i].distance_to(pl[i + 1])
		if acc + l >= sv or i == pl.size() - 2:
			var d := (pl[i + 1] - pl[i]) / l
			return {"p": pl[i] + d * clampf(sv - acc, 0.0, l), "d": d, "i": i}
		acc += l
	return {"p": pl[0], "d": Vector2.RIGHT, "i": 0}


func _yer(p: Vector2, h: float) -> Vector3:
	return Vector3(p.x, maxf(IstGeo.h(p.x, p.y), 0.0) + h, p.y)


## Sura en yakın ordugâh çadırı (t civarında): Vector2 ya da INF
func _cadir_yakin(t: float) -> Vector2:
	var y := _yon(t)
	var p: Vector2 = y[0]
	var o: Vector2 = y[2]
	var best := Vector2.INF
	var bd := INF
	for yn in get_tree().root.find_children("*", "IstOrdugahYonetici", true, false):
		for it: Dictionary in (yn as IstOrdugahYonetici).items:
			var ad := ""
			for k in it:
				if it[k] is String:
					ad += String(it[k])
			if not ad.contains("cadir"):
				continue
			var q: Vector2 = it["pos"]
			var v := q - p
			var dis := v.dot(o)
			var yan := absf(v.dot(Vector2(-o.y, o.x)))
			if dis < 60.0 or yan > 220.0:
				continue
			var sk := dis + yan * 0.5
			if sk < bd:
				bd = sk
				best = q
	return best


## Kara suru kapısı (kapı koşusu öğesi): t'ye en yakın; [p, o] ya da []
func _kapi(t: float) -> Array:
	var s := IstSehir.active
	var y := _yon(t)
	var hedef: Vector2 = y[0]
	var best: Array = []
	var bd := INF
	for it: Dictionary in s.hat_items + s.items:
		if String(it.get("kapi_hat", "")) != "kara_suru":
			continue
		var p3 = it.get("pos")
		var p := Vector2(p3.x, p3.z) if p3 is Vector3 else (p3 as Vector2 if p3 is Vector2 else Vector2.INF)
		if p == Vector2.INF:
			continue
		var dd := p.distance_to(hedef)
		if dd < bd:
			bd = dd
			var o := IstSehir._out(y[1], p, "kara_suru")
			best = [p, o]
	return best


func _uret() -> void:
	# (a) sahibinin baktığı 4 kamera (oturtma_kare.gd ile aynı tanım)
	var sahip := [["sahip_03_sur_disi_30m", -5030.0, 1010.0, 2.0, 95.0, 6.0], ["sahip_04_sur_disi_70m", -5136.0, 889.0, 2.0, 92.0, 4.0]]
	for k: Array in sahip:
		var w2 := IstGeo.w2(k[1], k[2])
		cam.global_position = Vector3(w2.x, maxf(IstGeo.h(w2.x, w2.y), 0.0) + float(k[3]), w2.y)
		cam.rotation = Vector3(deg_to_rad(k[5]), -deg_to_rad(k[4]), 0.0)
		_kam_satir.append("%s %.3f %.3f %.3f %.5f %.5f" % [k[0], cam.global_position.x, cam.global_position.y, cam.global_position.z, cam.rotation.x, cam.rotation.y])
		await _shot(k[0])
	var w := IstOrdugah.at(1350.0, 70.0)
	var wb := IstOrdugah.at(1600.0, 20.0)
	await _bak("s3_hendek", Vector3(w.x, IstGeo.h(w.x, w.y) + 15.0, w.y), Vector3(wb.x, IstGeo.h(wb.x, wb.y) + 4.0, wb.y))
	var h := _hat()
	var pl: PackedVector2Array = h[0]
	var L: float = h[1]
	var n := maxi(12, int(L / 180.0))
	var dm := IstSurlar.dims(1.0)
	var zm0 := float(dm["zm0"])
	var zm1 := float(dm["zm1"])
	var mz := (zm0 + zm1) * 0.5
	var sv := L * 5.5 / n
	var q := _hat_at(pl, sv)
	var p0: Vector2 = q["p"]
	var d0: Vector2 = q["d"]
	var o0 := IstSehir._out(d0, p0, "kara_suru")
	var base := IstGeo.h(p0.x, p0.y)
	for it: Dictionary in IstSehir.active.hat_items + IstSehir.active.items:
		if String(it.get("hat", "")) == "kara_suru" and it.has("s0") and it.has("walk") and sv >= float(it["s0"]) - 0.5 and sv <= float(it["s1"]) + 0.5:
			base = float(it["walk"]) - 12.0
			break
	var c0 := p0 + o0 * mz
	var k2 := p0 + o0 * (zm1 + 6.0)
	await _bak("hendek_kenar_05", Vector3(k2.x, IstGeo.h(k2.x, k2.y) + 1.7, k2.y) - Vector3(d0.x, 0, d0.y) * 8.0, Vector3(c0.x, base - 4.5, c0.y) + Vector3(d0.x, 0, d0.y) * 12.0)
	# (b) 12 karışık kare: aynı karede sur + çadır + zemin + ağaç + insan
	var bolum := [[0.35, "a"], [0.62, "b"]]
	var no := 1
	for bt: Array in bolum:
		var t: float = bt[0]
		var y := _yon(t)
		var p: Vector2 = y[0]
		var d: Vector2 = y[1]
		var o: Vector2 = y[2]
		var cd := _cadir_yakin(t)
		if cd == Vector2.INF:
			cd = p + o * 180.0
		var cd_s := (cd - p).dot(d)
		var duvar := p + d * cd_s       # çadırın hizasında sur
		# yakın 5 m: çadırın yanında, arkasından sura (çadır 5–6 m önde, kadrajın solunda; sur arkada)
		var tw := (duvar - cd).normalized()
		var e1 := cd - tw * 5.0 + d * 4.0
		await _bak("k%02d_cadir_yakin_5m" % no, _yer(e1, 1.7), _yer(duvar - d * 10.0, 9.0)); no += 1
		# orta 40 m: çadırın 40 m arkasından sura
		var e2 := cd - (duvar - cd).normalized() * 40.0
		await _bak("k%02d_ordugah_on_hat_40m" % no, _yer(e2, 1.8), _yer(duvar + d * 30.0, 8.0)); no += 1
		# hendek kenarı: hendeğin dış omzunda, sur boyunca ve biraz dışa (çadırlar sağda/solda)
		var e3 := p + o * (zm1 + 4.0)
		await _bak("k%02d_hendek_kenari" % no, _yer(e3, 1.7), _yer(p + o * (zm1 + 10.0) + d * 60.0, 3.0)); no += 1
		# sur üstünden ordugâha (uzak 400 m)
		var yk := _yer(p, 0.0).y
		for it: Dictionary in IstSehir.active.hat_items + IstSehir.active.items:
			if String(it.get("hat", "")) == "kara_suru" and it.has("walk") and it.has("s0"):
				var sv2 := L * t
				if sv2 >= float(it["s0"]) - 0.5 and sv2 <= float(it["s1"]) + 0.5:
					yk = float(it["walk"])
					break
		await _bak("k%02d_sur_ustunden_ordugaha" % no, Vector3(p.x, yk + 3.4, p.y) + Vector3(o.x, 0, o.y) * 1.0, _yer(p + o * 400.0 + d * 60.0, 0.0)); no += 1
		# ordugâhtan sura (uzak 400 m; tepecikten 12 m)
		var e5 := p + o * 400.0 - d * 50.0
		await _bak("k%02d_ordugahtan_sura_400m" % no, _yer(e5, 12.0), _yer(p, 10.0)); no += 1
		# şehir içinden sura (orta 40 m)
		var e6 := p - o * (absf(float(dm["zi0"])) + 45.0) + d * 20.0
		await _bak("k%02d_sehirden_sura_40m" % no, _yer(e6, 11.0), _yer(p, 12.0)); no += 1
	# kapı önü (iki kapı) — kapı yoksa sur önünden
	var kk := [_kapi(0.45), _kapi(0.7)]
	var kn := 1
	for ka: Array in kk:
		if ka.is_empty():
			continue
		var p: Vector2 = ka[0]
		var o: Vector2 = ka[1]
		await _bak("k%02d_kapi_onu_%d" % [no, kn], _yer(p + o * (zm1 + 40.0), 1.7), _yer(p, 7.0)); no += 1
		kn += 1
