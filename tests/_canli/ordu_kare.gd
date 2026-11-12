extends "res://tests/_ist/ordugah4_kare.gd"
## CANLI sondası: ORDUGÂH-4 sondasının kameralarıyla (aynı hesap, miras) yalnız hayvan kareleri + bütçe.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_canli/ordu_kare.tscn -- --out=KLASÖR
## Satırlar: ISTORDUKARE (miras), ISTORDUBUTCE (miras), CANLIORDU ad cizim ucgen


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
	DirAccess.make_dir_recursive_absolute(out)
	root = Node3D.new()
	root.name = "IstV2"
	add_child(root)
	cam = Camera3D.new()
	cam.far = 9000.0
	cam.fov = 62.0
	add_child(cam)
	cam.make_current()
	dunya = IstDunya.build(root, false, Vector3.ZERO)
	for i in 10:
		await get_tree().process_frame
	# sahibinin karesi (ORDUGÂH-4 _yer() ile aynı kamera hesabı)
	for n: Array in [["yer_sahi", "sahi_top", 28.0], ["yer_at_bagi", "ahir_otag", 14.0]]:
		var it := _plan_it(n[1])
		if it.is_empty():
			continue
		var c: Vector2 = it["pos"]
		var yaw := float(it["yaw"])
		var back := Vector2(-sin(yaw), -cos(yaw))
		var at := _bos_yer(c + back * float(n[2]))
		await _shot(n[0], _g(at, 1.7), _g(c, 1.5), 70)
	# yakın hayvan kareleri: öğenin yakınındaki ilk hayvan, 6 m yandan ve 60 m'den
	for n: Array in [["sahi_top", "yakin_sahi_okuz"], ["ahir_otag", "yakin_at_bagi"], ["anadolu_4_1", "yakin_oba_anadolu"], ["rumeli_3_1", "yakin_oba_rumeli"], ["yeniceri_1_1", "yakin_oba_yeniceri"], ["agil_anadolu", "yakin_agil"]]:
		var it := _plan_it(n[0])
		if it.is_empty():
			continue
		var c: Vector2 = it["pos"]
		cam.global_position = _g(c, 3.0)
		await _bekle(cam.global_position)
		var h := _yakin_hayvan(_g(c, 0.0), 90.0)
		if h == Vector3.INF:
			print("CANLIORDU %s hayvan_yok" % n[1])
			continue
		var at2 := _bos_yer(Vector2(h.x + 5.0, h.z + 3.0))
		await _shot(n[1], _g(at2, 1.6), h + Vector3(0, 0.8, 0), 60)
		await _shot(n[1] + "_60m", _g(Vector2(h.x + 45.0, h.z + 38.0), 12.0), h + Vector3(0, 0.8, 0), 60)
	await _butce("")
	print("ISTORDUKARE BITTI")
	get_tree().quit(0)


func _yakin_hayvan(c: Vector3, r: float) -> Vector3:
	var best := Vector3.INF
	var bd := r
	for n in get_tree().root.find_children("*", "Node3D", true, false):
		if not n.has_meta("hayvanlar"):
			continue
		var pts: PackedVector3Array = n.get_meta("hayvanlar")
		var xf := (n as Node3D).global_transform
		for p in pts:
			var w := xf * p
			var d := Vector2(w.x - c.x, w.z - c.z).length()
			if d < bd:
				bd = d
				best = w
	return best
