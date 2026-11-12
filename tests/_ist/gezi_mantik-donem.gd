extends Node3D
## Mantık/dönem gezisi sondası (yalnız test; oyun kodu değil).
##   -- --set=dump                    : eser/kapı dökümü (GZ_ESER satırları)
##   -- --set=liste --liste=DOSYA --out=KLASÖR [--gece]
##        satır: ad kamE kamN kamYuk hedefE hedefN hedefYuk   (gerçek metre; yükseklikler ARAZİNİN üstünde)
##   -- --set=ara --ara=ANAHTAR       : düğüm adında/mesh adında anahtar geçen görünür düğümleri sayar
var out := "user://gz"
var set_ := "liste"
var liste := ""
var ara := ""
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
			"ara": ara = kv[1]
			"gece": gece = true
	DirAccess.make_dir_recursive_absolute(out)
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var ilk := Vector3.ZERO
	var sat := _satirlar()
	if set_ == "liste" and sat.size() > 0:
		var p: PackedStringArray = String(sat[0]).split(" ", false)
		var w := IstGeo.w2(p[1].to_float(), p[2].to_float())
		ilk = Vector3(w.x, 10.0, w.y)
		cam.global_position = ilk
	dunya = IstDunya.build(self, gece, ilk)
	IstDunya.butce_us = 250000
	await get_tree().process_frame
	match set_:
		"dump": await _dump()
		"ara": await _ara()
		_: await _liste(sat)
	print("GZ bitti")
	get_tree().quit(0)


func _satirlar() -> Array:
	var r: Array = []
	if liste == "":
		return r
	var f := FileAccess.open(liste, FileAccess.READ)
	if f == null:
		return r
	while not f.eof_reached():
		var s := f.get_line().strip_edges()
		if s != "" and not s.begins_with("#"):
			r.append(s)
	return r


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
		if bos:
			break
		await get_tree().process_frame
	for i in 3:
		await get_tree().process_frame


func _dump() -> void:
	await _bekle()
	var s := IstSehir.active
	for it: Dictionary in s.items:
		var d: Dictionary = it["data"]
		var p: Vector3 = it["pos"]
		var r := IstGeo.real(p.x, p.z)
		print("GZ_ESER %s e=%.0f n=%.0f yaw=%.0f k=%.2f r=%.0f gorev=%s h=%.1f" % [it["id"], r.x, r.y, rad_to_deg(float(it["yaw"])),
			float(it["k"]), float(it["r"]), str(d.get("gorev", false)), IstGeo.h(p.x, p.z)])


func _ara() -> void:
	await _bekle()
	var keys := ara.split(",", false)
	var say := {}
	for k in keys:
		say[k] = 0
	for c in get_tree().root.find_children("*", "Node", true, false):
		var ad := String(c.name).to_lower()
		var ms := ""
		if c is MeshInstance3D and (c as MeshInstance3D).mesh:
			ms = String((c as MeshInstance3D).mesh.resource_name).to_lower()
		var tx := ""
		if c is Label3D:
			tx = (c as Label3D).text.to_lower()
		for k in keys:
			if ad.contains(k.to_lower()) or ms.contains(k.to_lower()) or tx.contains(k.to_lower()):
				say[k] += 1
				if say[k] < 6:
					var pos := Vector3.ZERO
					if c is Node3D:
						pos = (c as Node3D).global_position
					var r := IstGeo.real(pos.x, pos.z)
					print("GZ_ARA %s | %s | %s (%.0f,%.0f)" % [k, String(c.get_path()).replace("/root/", ""), tx, r.x, r.y])
	var lab := 0
	for c in get_tree().root.find_children("*", "Label3D", true, false):
		lab += 1
		if lab < 15:
			print("GZ_LABEL ", (c as Label3D).text.replace("\n", " "), " @", String(c.get_path()).replace("/root/", ""))
	print("GZ_ARA sayim ", say, " Label3D=", lab)


func _liste(sat: Array) -> void:
	for s: String in sat:
		var p := s.split(" ", false)
		if p.size() < 7:
			continue
		var wc := IstGeo.w2(p[1].to_float(), p[2].to_float())
		var wt := IstGeo.w2(p[4].to_float(), p[5].to_float())
		var yc := maxf(IstGeo.h(wc.x, wc.y), 0.0) + p[3].to_float()
		var yt := maxf(IstGeo.h(wt.x, wt.y), 0.0) + p[6].to_float()
		cam.global_position = Vector3(wc.x, yc, wc.y)
		var tgt := Vector3(wt.x, yt, wt.y)
		if cam.global_position.distance_to(tgt) < 0.5:
			tgt += Vector3(0, -1, 0)
		cam.look_at(tgt, Vector3.UP)
		await _bekle()
		await RenderingServer.frame_post_draw
		var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		print("RINFO gz %s cizim=%d ucgen=%d" % [p[0], dc, pr])
		var img := get_viewport().get_texture().get_image()
		img.save_png(out.path_join(p[0] + ".png"))
