extends Node
## G23 kare aracı (lykos21_kare'nin sürüşü): bölümü kurar, eski dünyanın uzak sur akışının bitmesini bekler, arayüzü gizler,
## listedeki bakışlardan kare alır. ÖNCE (dd0f6dd1) ve SONRA aynı araçla, aynı kamerayla.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --rendering-driver opengl3 --resolution 1280x720 \
##       res://tests/_ist/sur23_kare.tscn -- bolum=43o shots=KLASÖR liste=DOSYA [v2=1] [on=ONEK] [bekle=SN]
## liste: her satır "ad x y z hedef_x hedef_y hedef_z" (eski dünya koordinatı) ya da "ad acilis" (bölümün kendi kamerası).
## Satırlar: SUR23KARE ad=… cizim=… ilkel=…; SUR23KARE bitti n=…

var bolum := "43o"
var shots := ""
var liste := ""
var on := ""
var bekle := 10.0
var ch: Node


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"bolum": bolum = kv[1]
			"shots": shots = kv[1]
			"liste": liste = kv[1]
			"on": on = kv[1]
			"bekle": bekle = kv[1].to_float()
			"v2":
				if kv[1] == "1":
					IstSehir.enabled = true
					IstSehir.v2 = true
	match bolum:
		"6":
			GameState.chapter_outcomes[4] = "4b.1"
		"23", "24":
			GameState.chapter_outcomes[8] = "8.1"
	_calis.call_deferred()


func _calis() -> void:
	DirAccess.make_dir_recursive_absolute(shots)
	var ps: PackedScene = load("res://scenes/chapter%s.tscn" % bolum)
	ch = ps.instantiate()
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	await get_tree().create_timer(bekle, false).timeout
	# uzak sur akışı bitsin (bir bölgenin ilk saniyelerinde içerik eksik görünür)
	for k in 600:
		if ch.find_child("EskiSurAkis", true, false) == null:
			break
		await get_tree().process_frame
	for k in 30:
		await get_tree().process_frame
	var oyun_kam := get_viewport().get_camera_3d()
	var cam := Camera3D.new()
	cam.fov = 70.0
	cam.near = 0.1
	cam.far = 20000.0
	ch.add_child(cam)
	var n := 0
	var f := FileAccess.open(liste, FileAccess.READ)
	while f != null and not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var p := line.split(" ", false)
		_gizle()
		if p.size() == 2 and p[1] == "acilis":
			if oyun_kam != null:
				oyun_kam.current = true
		elif p.size() >= 7:
			cam.current = true
			var fx := _alan_xf()
			cam.global_position = fx * Vector3(p[1].to_float(), p[2].to_float(), p[3].to_float())
			cam.look_at(fx * Vector3(p[4].to_float(), p[5].to_float(), p[6].to_float()), Vector3.UP)
		else:
			continue
		for k in 10:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var ad := on + p[0] + ".png"
		get_viewport().get_texture().get_image().save_png(shots.path_join(ad))
		var vp := get_viewport().get_viewport_rid()
		print("SUR23KARE ad=%s cizim=%d ilkel=%d" % [p[0], RenderingServer.viewport_get_render_info(vp, RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE, RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME),
			RenderingServer.viewport_get_render_info(vp, RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE, RenderingServer.VIEWPORT_RENDER_INFO_PRIMITIVES_IN_FRAME)])
		n += 1
	print("SUR23KARE bitti n=%d bolum=%s v2=%s" % [n, bolum, str(IstSehir.v2)])
	get_tree().quit()


func _gizle() -> void:
	for c in ch.find_children("*", "CanvasLayer", true, false):
		(c as CanvasLayer).visible = false
	for c in get_tree().root.get_children():
		if c is CanvasLayer:
			(c as CanvasLayer).visible = false
		for cc in c.find_children("*", "CanvasLayer", true, false):
			(cc as CanvasLayer).visible = false


func _alan_xf() -> Transform3D:
	for n in ch.find_children("*", "Node3D", true, false):
		if n is SiegeField:
			return (n as Node3D).global_transform
	return Transform3D.IDENTITY
