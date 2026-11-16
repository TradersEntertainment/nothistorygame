extends Node3D
## IstHayat önizleme: v2 dünyayı (IstDunya) kurar, IstHayat.attach ile yaşamı ekler ve kamera listesinden kare alır.
##   godot --path . --resolution 1280x720 res://tests/_ist/hayat_onizleme.tscn -- gece=0|1 shots=KLASÖR liste=DOSYA [hayat=0]
## liste satırı: "ad e n yukseklik yon egim" (gerçek doğu/kuzey m, arazi üstü yükseklik, pusula yönü, eğim °; '@' önekiyle mutlak y)
## Yürüme sınaması: yurume=1 → Player kam konumunda; yer kareleri 1,7 m göz yüksekliğiyle.

var gece := false
var shots := ""
var liste := ""
var hayat_ac := true
var sayim := false
var cam: Camera3D
var dunya: IstDunya
var hayat: IstHayat
var _yaw := 0.0
var _pitch := 0.0


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"gece": gece = kv[1] == "1"
			"shots": shots = kv[1]
			"liste": liste = kv[1]
			"hayat": hayat_ac = kv[1] != "0"
			"sayim": sayim = kv[1] == "1"
	cam = Camera3D.new()
	cam.far = 12000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var w0 := IstGeo.w2(-200.0, 100.0)
	cam.global_position = Vector3(w0.x, 40.0, w0.y)
	dunya = IstDunya.build(self, gece, cam.global_position) as IstDunya
	if hayat_ac:
		hayat = IstHayat.attach(dunya, gece)
	IstDunya.butce_us = 250000
	_kareler.call_deferred()


func _kam_koy(k: PackedStringArray) -> void:
	var w2 := IstGeo.w2(k[0].to_float(), k[1].to_float())
	var ys := k[2]
	var y := ys.substr(1).to_float() if ys.begins_with("@") else maxf(IstGeo.h(w2.x, w2.y), 0.0) + ys.to_float()
	cam.global_position = Vector3(w2.x, y, w2.y)
	cam.rotation = Vector3(deg_to_rad(k[4].to_float()), -deg_to_rad(k[3].to_float()), 0.0)
	cam.fov = k[5].to_float() if k.size() > 5 else 70.0


func _kam_kayit(p: PackedStringArray) -> void:
	var kt: IstHayatKatman = hayat.K[p[2]]
	var n := p[3].to_int()
	var uz := p[4].to_float()
	var yy := p[5].to_float()
	var aci := p[6].to_float()
	var i := 0
	for key in kt.cells:
		var a: PackedFloat32Array = kt.cells[key]
		var m := a.size() / kt.stride
		if n >= i + m:
			i += m
			continue
		var o := (n - i) * kt.stride
		var pos := Vector3(a[o + 3], a[o + 7], a[o + 11])
		var dir := Vector3(deg_to_rad(aci), 0, 0)
		var q := pos + Vector3(sin(deg_to_rad(aci)) * uz, yy, cos(deg_to_rad(aci)) * uz)
		cam.global_position = q
		cam.look_at(pos + Vector3(0, 1.0, 0), Vector3.UP)
		cam.fov = 60.0
		print("KAYIT ", p[2], " ", n, " konum=", pos)
		return


func _bekle() -> void:
	var t0 := Time.get_ticks_msec()
	for i in 6:
		await get_tree().process_frame
	while Time.get_ticks_msec() - t0 < 30000:
		if dunya.olcum()["isler"] == 0:
			break
		await get_tree().process_frame
	# şehir akışı (ev/anıt kurma kuyruğu) bitsin
	var sh := IstSehir.active
	var g := 0
	while sh != null and g < 900 and (not sh._queue.is_empty() or g < 40):
		await get_tree().process_frame
		g += 1
	if hayat != null:
		hayat.yenile_hepsi()
	for i in 12:
		await get_tree().process_frame


func _kareler() -> void:
	var satirlar: Array = []
	if liste != "":
		var f := FileAccess.open(liste, FileAccess.READ)
		while f != null and not f.eof_reached():
			var s := f.get_line().strip_edges()
			if s != "" and not s.begins_with("#"):
				satirlar.append(s)
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	for s: String in satirlar:
		var p := s.split(" ", false)
		var ad := p[0]
		if p.size() > 1 and p[1] == "tur":
			# tur KATMAN N UZAKLIK YUKSEKLIK AÇI: katmanın N'inci kaydına bak (kayıt sırası hücre sırasıdır)
			_kam_kayit(p)
		else:
			_kam_koy(p.slice(1))
		await _bekle()
		await RenderingServer.frame_post_draw
		var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		var ho := hayat.olcum() if hayat != null else {}
		print("HAYATKARE %s cizim=%d ucgen=%d hayat=%s" % [ad, dc, pr, ho])
		if shots != "":
			get_viewport().get_texture().get_image().save_png(shots.path_join(ad + ".png"))
	print("HAYATBITTI")
	get_tree().quit(0)
