extends "res://tests/_ist/gezi.gd"
## Gece gezi sondası (denetçi): gezi.gd'nin kare döngüsünü ezer; sudaki kareleri atlar, her karenin ortanca parlaklığını
## ve karanlık oranını yazar, JPEG kaydeder.  Kullanım: gezi_gece.tscn -- gece=1 liste=DOSYA shots=KLASÖR [bas=N son=M]

var _bas := 0
var _son := 1000000


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2 and kv[0] == "bas":
			_bas = kv[1].to_int()
		elif kv.size() == 2 and kv[0] == "son":
			_son = kv[1].to_int()
	super._ready()


func _kareler() -> void:
	var satirlar: Array = []
	var f := FileAccess.open(liste, FileAccess.READ)
	while not f.eof_reached():
		var s := f.get_line().strip_edges()
		if s != "" and not s.begins_with("#"):
			satirlar.append(s)
	DirAccess.make_dir_recursive_absolute(shots)
	var i := -1
	for s: String in satirlar:
		i += 1
		if i < _bas or i >= _son:
			continue
		var p := s.split(" ", false)
		var ad := p[0]
		var k := _kam_coz(",".join(p.slice(1, 6)))
		_kam_koy(k)
		var w2 := cam.global_position
		if IstGeo.su(w2.x, w2.z) and w2.y < 12.0:
			print("GECE_SU ", ad)
			continue
		await _bekle(12.0)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		var img := get_viewport().get_texture().get_image()
		var sm := img.duplicate() as Image
		sm.resize(160, 90, Image.INTERPOLATE_BILINEAR)
		var vals: Array = []
		var kara := 0
		var ort := 0.0
		for y in 90:
			for x in 160:
				var c := sm.get_pixel(x, y)
				var l := 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
				vals.append(l)
				ort += l
				if l < 0.02:
					kara += 1
		vals.sort()
		print("GECE %s ort=%.1f medyan=%.1f karanlik=%.2f cizim=%d ucgen=%d" % [ad, ort / 14400.0 * 255.0,
			float(vals[7200]) * 255.0, kara / 14400.0, dc, pr])
		img.save_jpg(shots.path_join(ad + ".jpg"), 0.85)
	print("GEZI bitti")
	get_tree().quit(0)
