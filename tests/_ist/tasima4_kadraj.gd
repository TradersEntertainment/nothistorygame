extends SceneTree
## TAŞIMA-4 kadraj sondası (çizim yok): Bölüm 0'ın yeni setteki açılış kamerasından (START → LINE, fov 72, 16:9) verilen
## noktaların ekran yeri (0..1; görünmüyorsa "dışarıda"). Kare çekmeden merdiven ucu, sur yolu, yaralı yerlerini seçmek için.
##   godot --headless --path . -s tests/_ist/tasima4_kadraj.gd -- [--kamera=x,y,z --bak=x,y,z]
## Satırlar: KADRAJ4 ad=… p=… ekran=(u, v)|dışarıda


func _init() -> void:
	_kos.call_deferred()


func _kos() -> void:
	var sur := SurSet.yeni("mesoteikhion")
	var cam := Camera3D.new()
	cam.fov = 72.0
	get_root().size = Vector2i(1280, 720)
	get_root().add_child(cam)
	var goz := Vector3(-8.6, 1.65, 4.4)
	var bak := Vector3(-0.6, 1.4, 10.6)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--kamera="):
			var v := a.trim_prefix("--kamera=").split(",")
			goz = Vector3(float(v[0]), float(v[1]), float(v[2]))
		if a.begins_with("--bak="):
			var v := a.trim_prefix("--bak=").split(",")
			bak = Vector3(float(v[0]), float(v[1]), float(v[2]))
	cam.look_at_from_position(goz, bak, Vector3.UP)
	var nok := {}
	for x: float in [-20.0, -15.0, -11.0, -8.0, -6.0, -4.6, 4.6, 6.0, 8.0, 11.0, 15.0, 20.0, 30.0]:
		nok["dis_yol_%.0f" % x] = Vector3(x, sur.dis_yol_y() + 1.6, sur.dis_yol_z())
		nok["merdiven_ucu_%.0f" % x] = Vector3(x, sur.dis_yol_y() + 2.8, sur.dis_sur_z1() + 0.1)
		nok["ic_yuz_dip_%.0f" % x] = Vector3(x, 0.3, sur.dis_sur_z0() - 0.6)
	for k in nok:
		var p: Vector3 = nok[k]
		var on := not cam.is_position_behind(p)
		var e := cam.unproject_position(p) / Vector2(1280, 720)
		var ic := on and e.x >= 0.0 and e.x <= 1.0 and e.y >= 0.0 and e.y <= 1.0
		print("KADRAJ4 ad=%s p=%s ekran=%s" % [k, p, ("(%.2f, %.2f)" % [e.x, e.y]) if ic else "disarida"])
	quit(0)
