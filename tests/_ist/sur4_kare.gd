extends Node3D
## SUR-4 sondası (docs/_ajan/gorev/ist2_tur4.md, SUR-4). Kamera gezi.tscn ile AYNI (gerçek doğu/kuzey, araziden
## yükseklik ya da @mutlak, pusula yönü, eğim; fov 70); fark: kareden önce şehir akışı (IstSehir kuyruğu, pencereli sur
## dilimleri) de biter (gezi yalnız arazi işlerini bekliyor; sur dilimleri yarım kurulu çekilebiliyordu).
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/sur4_kare.tscn -- --set=liste --liste=DOSYA
##       --out=KLASÖR [--gece]          (liste satırı: "ad e n yukseklik yon egim")
##   … -- --set=surekli                 (ISTSURSUREKLI hat=… katman=yakin|orta|uzak ornek=N bosluk=K)
##   … -- --set=kara --out=KLASÖR       (kara suru boyunca ~180 m'de bir: dışarıdan 30 m ve yerden 60 m; sur üstü)
##   … -- --set=hilal                   (ISTHILAL sayi=N: hilalli bez/hilal çağrısı)
##   … -- --set=yuru                    (ISTSURYURU: sur üstü yürüyüş oranı; IstSehir hat dilimleri üstünde)

var out := "user://sur4"
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
	DirAccess.make_dir_recursive_absolute(out)
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var ilk := Vector3.ZERO
	if set_ == "liste" and liste != "":
		var s := _satirlar()
		if s.size() > 0:
			_kam_koy(_kam_coz(s[0]))
			ilk = cam.global_position
	dunya = IstDunya.build(self, gece, ilk)
	IstDunya.butce_us = 250000
	await get_tree().process_frame
	match set_:
		"liste":
			await _liste()
		"surekli":
			await _surekli()
		"kara":
			await _kara()
		"hilal":
			_hilal()
		"hendek":
			await _hendek()
		"kim":
			await _kim()
		"deniz":
			await _deniz()
		"uzak":
			await _uzak()
	print("SUR4 BITTI")
	get_tree().quit(0)


func _satirlar() -> Array:
	var out_a: Array = []
	var f := FileAccess.open(liste, FileAccess.READ)
	if f == null:
		return out_a
	while not f.eof_reached():
		var s := f.get_line().strip_edges()
		if s != "" and not s.begins_with("#"):
			out_a.append(s)
	return out_a


func _kam_coz(s: String) -> Array:
	var p := s.split(" ", false)
	return [p[0], p[1].to_float(), p[2].to_float(), p[3], p[4].to_float(), p[5].to_float()]


func _kam_koy(k: Array) -> void:
	var w2 := IstGeo.w2(k[1], k[2])
	var ys: String = k[3]
	var y := 0.0
	if ys.begins_with("@"):
		y = ys.substr(1).to_float()
	else:
		y = maxf(IstGeo.h(w2.x, w2.y), 0.0) + ys.to_float()
	cam.global_position = Vector3(w2.x, y, w2.y)
	cam.rotation = Vector3(deg_to_rad(k[5]), -deg_to_rad(k[4]), 0.0)


## Arazi işleri ve şehir kuyruğu bitene kadar (şehir kuyruğu kare beklemeden boşaltılır: yazılımla çizimde kare ~2 sn)
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
	await _bekle()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	print("RINFO sur4 %s cizim=%d ucgen=%d" % [ad, dc, pr])
	var img := get_viewport().get_texture().get_image()
	img.save_png(out.path_join(ad + ".png"))
	print("SUR4 kare ", out.path_join(ad + ".png"))


func _liste() -> void:
	for s: String in _satirlar():
		var k := _kam_coz(s)
		_kam_koy(k)
		await _shot(String(k[0]))


func _bak(ad: String, from: Vector3, to: Vector3) -> void:
	cam.global_position = from
	cam.look_at(to, Vector3.UP)
	var r := IstGeo.real(from.x, from.z)
	var yon := fposmod(rad_to_deg(-cam.rotation.y), 360.0)
	print("SUR4 kam %s %.0f %.0f @%.1f %.1f %.1f" % [ad, r.x, r.y, from.y, yon, rad_to_deg(cam.rotation.x)])
	await _shot(ad)


# ---------------------------------------------------------------- pafta_ordugah "hendek" karesi (sehir2_kare s3_hendek ile aynı kamera)

func _hendek() -> void:
	var w := IstOrdugah.at(1350.0, 70.0)
	var w2 := IstOrdugah.at(1600.0, 20.0)
	for we in get_tree().root.find_children("*", "WorldEnvironment", true, false):
		var env := (we as WorldEnvironment).environment
		if env and env.fog_enabled:
			env.fog_enabled = false
	cam.fov = 70.0
	await _bak("s3_hendek", Vector3(w.x, IstGeo.h(w.x, w.y) + 15.0, w.y), Vector3(w2.x, IstGeo.h(w2.x, w2.y) + 4.0, w2.y))


## Hendek karesindeki ağaç/kutu kaynağı: kameranın önündeki şeritte (sur dışı 60–130 m) duran görünür öğelerin düğüm yolu
func _kim() -> void:
	await _bekle()
	var w := IstOrdugah.at(1350.0, 70.0)
	var w2 := IstOrdugah.at(1600.0, 20.0)
	var dir := (w2 - w).normalized()
	var pts: Array = []
	for t in 12:
		pts.append(w + dir * (8.0 + t * 12.0))
	var say := {}
	for c in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
		var gi := c as GeometryInstance3D
		if not gi.is_visible_in_tree():
			continue
		var yol := String(gi.get_path()).replace("/root/Sur4Kare/", "")
		var parca := yol.split("/")
		var kisa := "/".join(parca.slice(0, mini(4, parca.size())))
		if gi is MultiMeshInstance3D:
			var mm := (gi as MultiMeshInstance3D).multimesh
			if mm == null:
				continue
			var xf := gi.global_transform
			var n := 0
			for i in mini(mm.visible_instance_count if mm.visible_instance_count >= 0 else mm.instance_count, mm.instance_count):
				var o := xf * mm.get_instance_transform(i).origin
				for q: Vector2 in pts:
					if Vector2(o.x, o.z).distance_to(q) < 9.0:
						n += 1
						break
			if n > 0:
				say[kisa + " [MM " + String(mm.mesh.resource_name if mm.mesh else "") + "]"] = int(say.get(kisa, 0)) + n
		else:
			var o2 := gi.global_position
			for q: Vector2 in pts:
				if Vector2(o2.x, o2.z).distance_to(q) < 9.0:
					say[kisa] = int(say.get(kisa, 0)) + 1
					break
	for k: String in say:
		print("SURKIM %s = %d" % [k, say[k]])


# ---------------------------------------------------------------- kara suru boyunca kareler

func _kara() -> void:
	var pl := IstSehir._sade(IstGeo.yol("kara_suru"))
	var L := 0.0
	for i in pl.size() - 1:
		L += pl[i].distance_to(pl[i + 1])
	var n := maxi(12, int(L / 180.0))
	for i in n:
		var sv := L * (i + 0.5) / n
		var q := _hat_at(pl, sv)
		var p: Vector2 = q["p"]
		var d: Vector2 = q["d"]
		var o := IstSehir._out(d, p, "kara_suru")
		var y0 := IstGeo.h(p.x, p.y)
		var dis := p + o * 70.0
		await _bak("kara_%02d_dis30" % i, Vector3(dis.x, IstGeo.h(dis.x, dis.y) + 30.0, dis.y) - Vector3(d.x, 0, d.y) * 25.0, Vector3(p.x, y0 + 8.0, p.y))
		var yer := p + o * 60.0
		await _bak("kara_%02d_yer60" % i, Vector3(yer.x, IstGeo.h(yer.x, yer.y) + 1.7, yer.y), Vector3(p.x, y0 + 9.0, p.y))
		if i % 3 == 0:
			var w := _walk_at("kara_suru", sv, y0 + 12.0)
			var top := Vector3(p.x, w + 1.7, p.y)
			await _bak("kara_%02d_ust_a" % i, top, top + Vector3(d.x, 0, d.y) * 40.0 + Vector3(0, -2.0, 0))
			await _bak("kara_%02d_ust_b" % i, top, top - Vector3(d.x, 0, d.y) * 40.0 + Vector3(0, -2.0, 0))


## Deniz surları ve Galata: hat başına dört nokta (dışarıdan 45 m, 18 m yükseklik) + bir sur üstü; gece kipinde iki
func _deniz() -> void:
	var pre := "gece_" if gece else ""
	for ad: String in ["marmara_suru", "halic_suru", "galata_suru"]:
		var pl := IstSehir._sade(IstGeo.yol(ad))
		var L := 0.0
		for i in pl.size() - 1:
			L += pl[i].distance_to(pl[i + 1])
		var kisa := ad.get_slice("_", 0)
		var n := 2 if gece else 4
		for i in n:
			var sv := L * (i + 0.5) / n
			var q := _hat_at(pl, sv)
			var p: Vector2 = q["p"]
			var d: Vector2 = q["d"]
			var o := IstSehir._out(d, p, ad)
			var y0 := maxf(IstGeo.h(p.x, p.y), 0.0)
			var c := p + o * 45.0 - d * 20.0
			await _bak("%s%s_%d" % [pre, kisa, i], Vector3(c.x, maxf(IstGeo.h(c.x, c.y), 0.0) + 18.0, c.y), Vector3(p.x, y0 + 6.0, p.y))
		if not gece:
			var q2 := _hat_at(pl, L * 0.4)
			var p2: Vector2 = q2["p"]
			var d2: Vector2 = q2["d"]
			var w := _walk_at(ad, L * 0.4, maxf(IstGeo.h(p2.x, p2.y), 0.0) + 8.0)
			var top := Vector3(p2.x, w + 1.7, p2.y)
			await _bak("%s_ust" % kisa, top, top + Vector3(d2.x, 0, d2.y) * 40.0 + Vector3(0, -2.0, 0))


## Uzak katman: 400 m ve 1 km'den dörder kare (kara dışı, Marmara, Haliç, Galata)
func _uzak() -> void:
	var pre := "gece_" if gece else ""
	var hedef := [["kara_suru", 0.45], ["marmara_suru", 0.5], ["halic_suru", 0.45], ["galata_suru", 0.3]]
	for r: float in [400.0, 1000.0]:
		for hd: Array in hedef:
			var ad: String = hd[0]
			var pl := IstSehir._sade(IstGeo.yol(ad))
			var L := 0.0
			for i in pl.size() - 1:
				L += pl[i].distance_to(pl[i + 1])
			var q := _hat_at(pl, L * float(hd[1]))
			var p: Vector2 = q["p"]
			var d: Vector2 = q["d"]
			var o := IstSehir._out(d, p, ad)
			var c := p + o * r
			var y := maxf(IstGeo.h(c.x, c.y), 0.0) + (40.0 if r < 500.0 else 90.0)
			await _bak("%suzak_%s_%dm" % [pre, ad.get_slice("_", 0), int(r)], Vector3(c.x, y, c.y), Vector3(p.x, maxf(IstGeo.h(p.x, p.y), 0.0) + 8.0, p.y))


static func _hat_at(pl: PackedVector2Array, sv: float) -> Dictionary:
	var acc := 0.0
	for i in pl.size() - 1:
		var l := pl[i].distance_to(pl[i + 1])
		if acc + l >= sv or i == pl.size() - 2:
			var d := (pl[i + 1] - pl[i]) / l
			return {"p": pl[i] + d * clampf(sv - acc, 0.0, l), "d": d, "i": i}
		acc += l
	return {"p": pl[0], "d": Vector2.RIGHT, "i": 0}


func _walk_at(ad: String, sv: float, yok: float) -> float:
	var s := IstSehir.active
	for it: Dictionary in s.hat_items + s.items:
		var on := String(it.get("hat", "")) == ad or String(it.get("kapi_hat", "")) == ad
		if on and it.has("s0") and it.has("walk") and sv >= float(it["s0"]) - 0.5 and sv <= float(it["s1"]) + 0.5:
			return float(it["walk"])
	return yok


# ---------------------------------------------------------------- süreklilik (madde 1)

const MASK := 1 << 19
const HATLAR := {"kara_suru": "kara", "blakherna_suru": "blakherna", "marmara_suru": "deniz", "halic_suru": "deniz", "galata_suru": "deniz"}

func _surekli() -> void:
	var s := IstSehir.active
	s.set_process(false)
	var sur_items: Array = []
	for it: Dictionary in s.hat_items + s.items:
		if sur_items.has(it):
			continue
		if it.has("hat") or it.has("kapi_hat") or String(it.get("mod", "")) in IstSehir.SUR_MOD:
			sur_items.append(it)
	print("SURSUREKLI oge=%d" % sur_items.size())
	for katman: String in ["yakin", "orta", "uzak"]:
		var body := StaticBody3D.new()
		body.collision_layer = MASK
		body.collision_mask = 0
		add_child(body)
		var nsh := 0
		for it: Dictionary in sur_items:
			var meshes: Array = []
			if katman == "uzak" and it.get("no2", false):
				continue
			var lod := 0 if katman == "yakin" else (1 if katman == "orta" else 2)
			var tmp := Node3D.new()
			(it["holder"] as Node3D).add_child(tmp)
			IstSurlar.pencere = Vector2(-1e9, 1e9)
			IstMk.pencere = Vector2(-1e9, 1e9)
			if it.has("make"):
				(it["make"] as Callable).call(tmp, lod)
			else:
				(it["script"] as GDScript).call("build_" + String(it["id"]), tmp, float(it["k"]), lod)
			for c in tmp.find_children("*", "MeshInstance3D", true, false):
				meshes.append(c)
			for mi: MeshInstance3D in meshes:
				nsh += _ekle(body, mi)
			tmp.free()
		if katman == "uzak":
			for c in s.get_children():
				if c is MeshInstance3D and (c as MeshInstance3D).material_override is ShaderMaterial and (c as MeshInstance3D).visibility_range_begin > 0.0:
					nsh += _ekle(body, c)
		for i in 3:
			await get_tree().physics_frame
		var sp := get_world_3d().direct_space_state
		for ad: String in HATLAR:
			var r := _say(sp, ad, katman, false)
			print("ISTSURSUREKLI hat=%s katman=%s ornek=%d bosluk=%d%s" % [ad, katman, r["n"], r["k"], r["yer"]])
			if ad == "kara_suru":
				var r2 := _say(sp, ad, katman, true)
				print("ISTSURSUREKLI hat=kara_dis_sur katman=%s ornek=%d bosluk=%d%s" % [katman, r2["n"], r2["k"], r2["yer"]])
		print("SURSUREKLI katman=%s sekil=%d" % [katman, nsh])
		body.free()
		await get_tree().physics_frame


func _ekle(body: StaticBody3D, mi: MeshInstance3D) -> int:
	if mi.mesh == null or not mi.is_visible_in_tree() and mi.visibility_range_begin <= 0.0:
		return 0
	var sh := mi.mesh.create_trimesh_shape()
	if sh == null:
		return 0
	var cs := CollisionShape3D.new()
	cs.shape = sh
	body.add_child(cs)
	cs.global_transform = mi.global_transform
	return 1


func _say(sp: PhysicsDirectSpaceState3D, ad: String, katman: String, dis: bool) -> Dictionary:
	var pl := IstSehir._sade(IstGeo.yol(ad))
	var L := 0.0
	for i in pl.size() - 1:
		L += pl[i].distance_to(pl[i + 1])
	var n := 0
	var k := 0
	var yer := ""
	var sv := 2.5
	var son := NAN
	var dm := IstSurlar.dims(1.0)
	while sv < L - 2.5:
		var q := _hat_at(pl, sv)
		var p: Vector2 = q["p"]
		var d: Vector2 = q["d"]
		var o := IstSehir._out(d, p, ad)
		var g := IstGeo.h(p.x, p.y)
		var w := _walk_at(ad, sv, NAN)
		if is_nan(w):
			w = son if not is_nan(son) else g + 10.0
		son = w
		var a: Vector3
		var b: Vector3
		if dis:
			var y := w - float(dm["HW"]) + float(dm["OH"]) - 2.0
			a = Vector3(p.x + o.x * (float(dm["zo1"]) + 5.0), y, p.y + o.y * (float(dm["zo1"]) + 5.0))
			b = Vector3(p.x + o.x * (float(dm["zo0"]) - 3.0), y, p.y + o.y * (float(dm["zo0"]) - 3.0))
		else:
			var st := 10.0 if HATLAR[ad] == "kara" else 14.0
			a = Vector3(p.x + o.x * st, w - 2.0, p.y + o.y * st)
			b = Vector3(p.x - o.x * 9.0, w - 2.0, p.y - o.y * 9.0)
		var qr := PhysicsRayQueryParameters3D.create(a, b, MASK)
		qr.hit_back_faces = true
		var hit := sp.intersect_ray(qr)
		n += 1
		if hit.is_empty():
			k += 1
			if yer.length() < 1600:
				var rr := IstGeo.real(p.x, p.y)
				yer += " s=%.0f(%.0f,%.0f)[%s]" % [sv, rr.x, rr.y, _kimde(ad, sv)]
		sv += 5.0
	return {"n": n, "k": k, "yer": yer}


func _kimde(ad: String, sv: float) -> String:
	var s := IstSehir.active
	var o := ""
	for it: Dictionary in s.hat_items + s.items:
		var on := String(it.get("hat", "")) == ad or String(it.get("kapi_hat", "")) == ad
		if on and it.has("s0") and sv >= float(it["s0"]) - 8.0 and sv <= float(it["s1"]) + 8.0:
			o += "%s:%.0f-%.0f " % [String(it["id"]), float(it["s0"]), float(it["s1"])]
		elif on and it.has("kd_s") and sv >= (it["kd_s"] as Vector2).x - 8.0 and sv <= (it["kd_s"] as Vector2).y + 8.0:
			o += "%s:%.0f-%.0f " % [String(it["id"]), (it["kd_s"] as Vector2).x, (it["kd_s"] as Vector2).y]
	return o.strip_edges()


# ---------------------------------------------------------------- hilal (madde 3b)

func _hilal() -> void:
	var n := 0
	var kaynak := ""
	var d := DirAccess.open("res://scripts/world/ist")
	for f: String in d.get_files():
		if not f.ends_with(".gd"):
			continue
		var txt := FileAccess.get_file_as_string("res://scripts/world/ist/" + f)
		var satir := 0
		for ln: String in txt.split("\n"):
			satir += 1
			var t := ln.strip_edges()
			if t.begins_with("#"):
				continue
			if t.contains("Props.crescent(") or (t.contains("sancak(") and t.contains(", 3,") and f.begins_with("hayat")):
				n += 1
				kaynak += " %s:%d" % [f, satir]
	print("ISTHILAL sayi=%d%s" % [n, kaynak])
