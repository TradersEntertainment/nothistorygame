extends Node3D
## OTURTMA kare sondası (sur ile araziyi tek yer yapma işi). Gerçek oyun kurucusu (IstDunya.build → IstSehir.attach_v2).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/oturtma_kare.tscn --
##       --set=uret --out=KLASÖR --kam=DOSYA     (bütün kameraları kurar, kareleri alır, mutlak kamera listesini DOSYA'ya yazar)
##       --set=liste --liste=DOSYA --out=KLASÖR [--sec=ön_ek]  (aynı kameraları mutlak konumdan oynatır: ÖNCE ile SONRA AYNI kamera)
## Kamera satırı: "ad x y z rx ry" (dünya koordinatı, radyan). Kareler 1280×720 jpg (kalite 85).

var out := "user://oturtma"
var set_ := "liste"
var liste := ""
var kam_dosya := ""
var birlestir := ""      # --birlestir=DOSYA (liste kipinde): göz bu ağacın arazisinin 1,7 m altında kalmasın; düzeltilmiş liste
var sec := ""
var en := 100000         # --en=N: N kareden sonra dur (hızlı deneme)
var _say := 0
var pxs: Array = []      # --px=x,y;x,y: kareden sonra bu piksellerde görünen ilk yüzeyin düğümü (ışın × üçgen)
var cam: Camera3D
var dunya: Node3D
var _kam_satir: Array = []


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"set": set_ = kv[1]
			"liste": liste = kv[1]
			"kam": kam_dosya = kv[1]
			"birlestir": birlestir = kv[1]
			"sec": sec = kv[1]
			"en": en = kv[1].to_int()
			"px":
				for t in kv[1].split(";"):
					var xy := t.split(",")
					pxs.append(Vector2(xy[0].to_float(), xy[1].to_float()))
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
		ilk = _kara_nokta(0.5)
	var t0 := Time.get_ticks_msec()
	dunya = IstDunya.build(self, false, ilk)
	print("OTURTMA yukleme_ms=%d" % (Time.get_ticks_msec() - t0))
	IstDunya.butce_us = 250000
	await get_tree().process_frame
	for we in get_tree().root.find_children("*", "WorldEnvironment", true, false):
		var env := (we as WorldEnvironment).environment
		if env and env.fog_enabled:
			env.fog_enabled = false
	if set_ == "liste" and birlestir != "":
		# iki ağacın kamerası aynı olsun: göz her iki arazinin de üstünde (hendek içi kameraları hariç: onlar oyuğun içinde)
		var f := FileAccess.open(birlestir, FileAccess.WRITE)
		for s: String in satirlar:
			var p: PackedStringArray = s.split(" ", false)
			var x := p[1].to_float()
			var z := p[3].to_float()
			var y := p[2].to_float()
			if not p[0].begins_with("hendek_ici") and not p[0].ends_with("_icten"):
				y = maxf(y, IstGeo.h(x, z) + 1.7)
			f.store_line("%s %.3f %.3f %.3f %s %s" % [p[0], x, y, z, p[4], p[5]])
		f.close()
		print("OTURTMA BITTI")
		get_tree().quit(0)
		return
	if set_ == "liste":
		for s: String in satirlar:
			var p: PackedStringArray = s.split(" ", false)
			if sec != "" and not p[0].begins_with(sec):
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
	print("OTURTMA BITTI")
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


func _shot(ad: String) -> void:
	_say += 1
	if _say > en:
		return
	if sec != "" and not ad.begins_with(sec) and set_ != "liste":
		return
	await _bekle()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	print("RINFO oturtma %s cizim=%d ucgen=%d" % [ad, dc, pr])
	var img := get_viewport().get_texture().get_image()
	img.save_jpg(out.path_join(ad + ".jpg"), 0.85)
	for px: Vector2 in pxs:
		_piksel(ad, px)


## Pikselden ışın: görünen bütün ağ örneklerinin üçgenleriyle kesişim; en yakın 4 isabet (düğüm yolu, uzaklık, nokta)
func _piksel(ad: String, px: Vector2) -> void:
	var o := cam.project_ray_origin(px)
	var dr := cam.project_ray_normal(px)
	var hits: Array = []
	for c in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
		var gi := c as GeometryInstance3D
		if not gi.is_visible_in_tree():
			continue
		var parts: Array = []      # [mesh, xform]
		if gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null:
			parts.append([(gi as MeshInstance3D).mesh, gi.global_transform])
		elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh != null:
			var mm := (gi as MultiMeshInstance3D).multimesh
			if mm.mesh == null:
				continue
			var n := mm.instance_count if mm.visible_instance_count < 0 else mini(mm.visible_instance_count, mm.instance_count)
			for j in mini(n, 4000):
				parts.append([mm.mesh, gi.global_transform * mm.get_instance_transform(j)])
		for pr: Array in parts:
			var m: Mesh = pr[0]
			var xf: Transform3D = pr[1]
			var ab: AABB = xf * m.get_aabb()
			if ab.size.length() > 6000.0:
				continue
			if not ab.grow(0.5).intersects_ray(o, dr):
				continue
			var inv := xf.affine_inverse()
			var lo := inv * o
			var ld := (inv.basis * dr).normalized()
			var f := m.get_faces()
			var best := INF
			for k in range(0, f.size(), 3):
				var r = Geometry3D.ray_intersects_triangle(lo, ld, f[k], f[k + 1], f[k + 2])
				if r != null:
					var dd := (xf * (r as Vector3)).distance_to(o)
					if dd < best:
						best = dd
			if best < INF:
				var mt := gi.material_override
				var mts := "" if mt == null else (mt.get_class() + (" " + str((mt as BaseMaterial3D).albedo_color) if mt is BaseMaterial3D else " " + str((mt as ShaderMaterial).shader.resource_path if mt is ShaderMaterial and (mt as ShaderMaterial).shader else "")))
				hits.append([best, String(gi.get_path()).replace("/root/OturtmaKare/", "") + " ab=" + str(ab.size) + " mat=" + mts])
	hits.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	for i in mini(4, hits.size()):
		var w := o + dr * float(hits[i][0])
		print("OTPIKSEL %s px=%s #%d uzak=%.1f y=%.2f %s" % [ad, px, i, float(hits[i][0]), w.y, hits[i][1]])


func _bak(ad: String, from: Vector3, to: Vector3) -> void:
	cam.global_position = from
	cam.look_at(to, Vector3.UP)
	_kam_satir.append("%s %.3f %.3f %.3f %.5f %.5f" % [ad, from.x, from.y, from.z, cam.rotation.x, cam.rotation.y])
	await _shot(ad)


static func _hat_at(pl: PackedVector2Array, sv: float) -> Dictionary:
	var acc := 0.0
	for i in pl.size() - 1:
		var l := pl[i].distance_to(pl[i + 1])
		if acc + l >= sv or i == pl.size() - 2:
			var d := (pl[i + 1] - pl[i]) / l
			return {"p": pl[i] + d * clampf(sv - acc, 0.0, l), "d": d, "i": i}
		acc += l
	return {"p": pl[0], "d": Vector2.RIGHT, "i": 0}


func _kara_nokta(t: float) -> Vector3:
	var pl := IstSehir._sade(IstGeo.yol("kara_suru"))
	var L := 0.0
	for i in pl.size() - 1:
		L += pl[i].distance_to(pl[i + 1])
	var q := _hat_at(pl, L * t)
	var p: Vector2 = q["p"]
	return Vector3(p.x, IstGeo.h(p.x, p.y), p.y)


func _walk_at(ad: String, sv: float, yok: float) -> float:
	var s := IstSehir.active
	for it: Dictionary in s.hat_items + s.items:
		var on := String(it.get("hat", "")) == ad or String(it.get("kapi_hat", "")) == ad
		if on and it.has("s0") and it.has("walk") and sv >= float(it["s0"]) - 0.5 and sv <= float(it["s1"]) + 0.5:
			return float(it["walk"])
	return yok


## Yay boyu sv'deki dilimin (ya da kapı koşusunun) tabanı ve dış kademesi
func _taban_at(sv: float) -> Vector2:
	var s := IstSehir.active
	for it: Dictionary in s.hat_items + s.items:
		var on := String(it.get("hat", "")) == "kara_suru" or String(it.get("kapi_hat", "")) == "kara_suru"
		if on and it.has("s0") and sv >= float(it["s0"]) - 0.5 and sv <= float(it["s1"]) + 0.5 and not String(it["id"]).begins_with("kdolgu"):
			var dy := 0.0
			if it.has("len") or it.has("glen"):
				dy = s._dis_dy(it)
			return Vector2(float(it["pos"].y), dy)
	return Vector2(NAN, 0.0)


func _uret() -> void:
	# (a) SUR-5 kameraları (sur5_kare.gd ile aynı tanım)
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
	var pl := IstSehir._sade(IstGeo.yol("kara_suru"))
	var L := 0.0
	for i in pl.size() - 1:
		L += pl[i].distance_to(pl[i + 1])
	var n := maxi(12, int(L / 180.0))
	var dm := IstSurlar.dims(1.0)
	var zm0 := float(dm["zm0"])
	var zm1 := float(dm["zm1"])
	var mz := (zm0 + zm1) * 0.5
	for i: int in [5]:
		var sv := L * (i + 0.5) / n
		var q := _hat_at(pl, sv)
		var p: Vector2 = q["p"]
		var o := IstSehir._out(q["d"], p, "kara_suru")
		var y0 := IstGeo.h(p.x, p.y)
		var yer := p + o * 60.0
		await _bak("kara_%02d_yer60" % i, Vector3(yer.x, IstGeo.h(yer.x, yer.y) + 1.7, yer.y), Vector3(p.x, y0 + 9.0, p.y))
	for i: int in [5, 8]:
		var sv := L * (i + 0.5) / n
		var q := _hat_at(pl, sv)
		var p: Vector2 = q["p"]
		var d: Vector2 = q["d"]
		var o := IstSehir._out(d, p, "kara_suru")
		var base := _walk_at("kara_suru", sv, IstGeo.h(p.x, p.y) + 12.0) - 12.0
		var c := p + o * mz
		await _bak("hendek_ici_%02d" % i, Vector3(c.x, base - 6.0 + 1.7, c.y) - Vector3(d.x, 0, d.y) * 20.0, Vector3(c.x, base - 5.0, c.y) + Vector3(d.x, 0, d.y) * 20.0)
		var k2 := p + o * (zm1 + 6.0)
		await _bak("hendek_kenar_%02d" % i, Vector3(k2.x, IstGeo.h(k2.x, k2.y) + 1.7, k2.y) - Vector3(d.x, 0, d.y) * 8.0, Vector3(c.x, base - 4.5, c.y) + Vector3(d.x, 0, d.y) * 12.0)
	# (b) dip turu: 12 nokta; dışarıdan (hendek dış kıyısından 8 m), peribolostan (iç sur dibinden 8 m), şehir yanından
	# (iç sur dibinden 8 m); her birinde sura dik, sur boyunca, ayağa bakış. Göz: dilim tabanı (+ dış kademe) + 1,7 m.
	var zi0 := float(dm["zi0"])
	var zi1 := float(dm["zi1"])
	var HW := float(dm["HW"])
	for i in 12:
		var sv := L * (i + 0.5) / 12.0 + 23.0
		var q := _hat_at(pl, sv)
		var p: Vector2 = q["p"]
		var d: Vector2 = q["d"]
		var o := IstSehir._out(d, p, "kara_suru")
		var tb := _taban_at(sv)
		if is_nan(tb.x):
			tb = Vector2(_walk_at("kara_suru", sv, IstGeo.h(p.x, p.y) + HW) - HW, 0.0)
		var yanlar := [["dis", zm1 + 0.9 + 8.0, zm1 + 0.9, tb.x + tb.y], ["peri", zi1 + 8.0, zi1, tb.x], ["sehir", zi0 - 8.0, zi0, tb.x]]
		for yn: Array in yanlar:
			var ze: float = yn[1]
			var zw: float = yn[2]
			var yy: float = yn[3]
			var e := p + o * ze
			var f := p + o * zw
			var ey := yy + 1.7
			var ad := "dip_%02d_%s" % [i, yn[0]]
			await _bak(ad + "_dik", Vector3(e.x, ey, e.y), Vector3(f.x, ey + 1.5, f.y))
			var bo := p + o * (zw + (ze - zw) * 0.35) + d * 40.0
			await _bak(ad + "_boy", Vector3(e.x, ey, e.y) - Vector3(d.x, 0, d.y) * 6.0, Vector3(bo.x, ey - 0.3, bo.y))
			await _bak(ad + "_ayak", Vector3(e.x, ey, e.y), Vector3(f.x, yy - 0.4, f.y) + Vector3(d.x, 0, d.y) * 2.0)
	# (c) hendek kenarında ayakta: aşağı ve boyunca; hendek içinden yukarı (4 nokta)
	for i: int in [1, 4, 7, 10]:
		var sv := L * (i + 0.5) / 12.0 + 61.0
		var q := _hat_at(pl, sv)
		var p: Vector2 = q["p"]
		var d: Vector2 = q["d"]
		var o := IstSehir._out(d, p, "kara_suru")
		var tb := _taban_at(sv)
		if is_nan(tb.x):
			continue
		var yd := tb.x + tb.y
		var k := p + o * (zm1 + 2.0)
		await _bak("hk_%02d_asagi" % i, Vector3(k.x, yd + 1.7, k.y), Vector3(p.x + o.x * mz, yd - 6.0, p.y + o.y * mz) + Vector3(d.x, 0, d.y) * 6.0)
		await _bak("hk_%02d_boyunca" % i, Vector3(k.x, yd + 1.7, k.y), Vector3(k.x, yd - 1.0, k.y) - Vector3(o.x, 0, o.y) * 6.0 + Vector3(d.x, 0, d.y) * 40.0)
		var c := p + o * mz
		await _bak("hk_%02d_icten" % i, Vector3(c.x, yd - 6.0 + 1.7, c.y) + Vector3(o.x, 0, o.y) * 4.0, Vector3(p.x + o.x * (zm0 - 4.0), yd + 6.0, p.y + o.y * (zm0 - 4.0)))
	# (d) 60 m'den eğik havadan 4 kare
	for i: int in [2, 5, 8, 11]:
		var sv := L * (i + 0.5) / 12.0
		var q := _hat_at(pl, sv)
		var p: Vector2 = q["p"]
		var d: Vector2 = q["d"]
		var o := IstSehir._out(d, p, "kara_suru")
		var tb := _taban_at(sv)
		var yb := tb.x if not is_nan(tb.x) else IstGeo.h(p.x, p.y)
		var c := p + o * 95.0 - d * 45.0
		await _bak("hava_%02d" % i, Vector3(c.x, yb + 60.0, c.y), Vector3(p.x + o.x * 25.0, yb, p.y + o.y * 25.0))
