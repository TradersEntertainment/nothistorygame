extends Node
## pilot20_teshis.gd yardımcısı (sahne değişince de yaşar; kökte durur).

var dir := "user://teshis"
var kutu := Rect2i(760, 405, 410, 65)
var bakis := "depo"


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--teshis="):
			dir = a.trim_prefix("--teshis=")
		elif a.begins_with("--kutu="):
			var p := a.trim_prefix("--kutu=").split(",")
			kutu = Rect2i(int(p[0]), int(p[1]), int(p[2]) - int(p[0]), int(p[3]) - int(p[1]))
		elif a.begins_with("--bakis="):
			bakis = a.trim_prefix("--bakis=")
	DirAccess.make_dir_recursive_absolute(dir)
	_kos()


func _kos() -> void:
	for i in 30:
		await get_tree().process_frame
	var ch: Node = get_tree().current_scene
	while ch == null or ch.get("player") == null or ch.get("sur") == null:
		await get_tree().process_frame
		ch = get_tree().current_scene
	await get_tree().create_timer(4.0).timeout
	var player: Node3D = ch.get("player")
	var sur: SurSet = ch.get("sur")
	var hud: Node = ch.get("hud")
	var pos: Vector3
	var bak: Vector3
	match bakis:
		"dogus":
			pos = sur.dogus()
			bak = (ch.get("giust") as Node3D).global_position + Vector3(0, 1.5, 0)
		"siper":
			pos = sur.siperler()[0] + Vector3(0.3, 0.05, -1.6)
			bak = sur.gedik() + Vector3(0, 2.0, 0)
		"gedik":
			pos = sur.gedik_onu() + Vector3(-1.5, 0.05, -4.0)
			bak = sur.barikat() + Vector3(0, 0.6, 0)
		"okcu":
			var ap: Vector3 = ch.get("archers_p")
			pos = ap + Vector3(0, 0.05, -1.6)
			bak = ap + Vector3(0, 1.2, 0.2)
		_:
			pos = sur.depo() + Vector3(-3.0 if sur.eski_mi else 3.0, 0.05, 4.0)
			bak = sur.gedik() + Vector3(0, 2.0, 0)
	var tut := func() -> void:
		player.set("frozen", true)
		player.global_position = pos
		player.call("face", bak)
	if hud:
		hud.set("visible", false)
	tut.call()
	var taban := await _olc(tut, "taban")
	print("TESHIS taban koyu=%.3f renk=%s" % [taban[0], taban[1]])
	# 1) sur kesimi dışındaki her şey gizli (kalabalık, dekor, ova): kusur kalıyorsa kaynak kesimin kendisidir
	var walls: Node = ch.get("walls")
	var gizlenen: Array = []
	for c in ch.get_children():
		if c is Node3D and c != walls and c != player and (c as Node3D).visible:
			(c as Node3D).visible = false
			gizlenen.append(c)
	for c in walls.get_children():
		if c is Node3D and c.name != "SurCerceve" and (c as Node3D).visible:
			(c as Node3D).visible = false
			gizlenen.append(c)
	var yalniz := await _olc(tut, "yalniz_sur")
	print("TESHIS yalniz_sur koyu=%.3f renk=%s" % [yalniz[0], yalniz[1]])
	# 2) kesimin adlı alt düğümleri (üç kat) tek tek
	var aday: Array = []
	var cer := walls.get_node_or_null("SurCerceve")
	if cer:
		var yig: Array = [[cer, 0]]
		while not yig.is_empty():
			var e: Array = yig.pop_back()
			for c2 in (e[0] as Node).get_children():
				if c2 is Node3D and not String(c2.name).begins_with("@"):
					aday.append(c2)
				if int(e[1]) < 3:
					yig.append([c2, int(e[1]) + 1])
	var n := 0
	for c: Node3D in aday:
		if not is_instance_valid(c) or not c.visible:
			continue
		c.visible = false
		var r := await _olc(tut, "")
		if is_instance_valid(c):
			c.visible = true
		var fark: float = float(yalniz[0]) - float(r[0])
		var renk_f: float = (yalniz[1] as Color).v - (r[1] as Color).v
		if absf(fark) > 0.01 or absf(renk_f) > 0.02:
			n += 1
			print("TESHIS gizli=%s koyu=%.3f fark=%.3f parlaklik_fark=%.3f" % [cer.get_path_to(c), r[0], fark, renk_f])
			if absf(fark) > 0.03 and is_instance_valid(c):
				c.visible = false
				await _olc(tut, "gizli_%02d_%s" % [n, c.name])
				c.visible = true
	print("TESHIS BITTI aday=%d etkili=%d" % [aday.size(), n])
	get_tree().quit(0)


func _olc(tut: Callable, ad: String) -> Array:
	for k in 3:
		tut.call()
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if ad != "":
		img.save_jpg(dir.path_join(ad + ".jpg"), 0.85)
	var koyu := 0
	var top := 0
	var cs := Color(0, 0, 0)
	for y in range(kutu.position.y, kutu.end.y, 2):
		for x in range(kutu.position.x, kutu.end.x, 2):
			var c := img.get_pixel(x, y)
			top += 1
			cs += c
			if c.get_luminance() < 0.10:
				koyu += 1
	return [float(koyu) / maxf(top, 1), Color(cs.r / top, cs.g / top, cs.b / top)]
