extends Node3D
## Ayak yerleştirme deney sahnesi (fizik-ayak): eğim (15° ve 25°), basamak, moloz; duran (eğime dik ve boyuna),
## yürüyen (yokuş yukarı/aşağı, merdiven), asker, at. Her denekten yandan kare; AYAKAUDIT satırları.
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_fizik/ayak_sahne.tscn \
##       -- --ayak-kare=/klasör [--ayak-ik=0]
## Klasör yoksa yalnız denetim (ekransız da koşar).

var dir := ""
var cam: Camera3D
var _subj := {}
var _t := 0.0


func _ready() -> void:
	GameState.autotest = true
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ayak-kare="):
			dir = a.trim_prefix("--ayak-kare=")
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("9fb8d0")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.45, 0.45, 0.5)
	e.ambient_light_energy = 0.6
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 35, 0)
	sun.shadow_enabled = true
	sun.light_energy = 0.75
	add_child(sun)
	cam = Camera3D.new()
	add_child(cam)
	cam.current = true
	cam.fov = 50.0
	cam.position = Vector3(0, 3, -8)
	# Zemin
	_kutu(Vector3(0, -0.25, 0), Vector3(60, 0.5, 60), Vector3.ZERO, Color("7c8a5a"))
	# Yokuş 15° (x -1..3), +z'ye doğru yükselir, z 0..10
	_yokus(Vector3(1, 0, 0), 4.0, 15.0)
	# Yokuş 25° (x -14..-10)
	_yokus(Vector3(-12, 0, 0), 4.0, 25.0)
	# Merdiven (x 6..8): 6 basamak 0,18 × 0,35
	for i in 6:
		_kutu(Vector3(7, (i + 1) * 0.18 * 0.5, 2.0 + i * 0.35 + 0.175 + (6 - i - 1) * 0.0), Vector3(2, (i + 1) * 0.18, 0.35), Vector3.ZERO, Color("a09a8a"))
	_kutu(Vector3(7, 0.54, 4.1 + 1.5), Vector3(2, 1.08, 3.0), Vector3.ZERO, Color("a09a8a"))
	# Moloz (x -6)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 9:
		var p := Vector3(-6 + rng.randf_range(-1.0, 1.0), rng.randf_range(0.0, 0.15), 3 + rng.randf_range(-1.0, 1.0))
		_kutu(p, Vector3(rng.randf_range(0.6, 1.2), rng.randf_range(0.3, 0.6), rng.randf_range(0.6, 1.2)),
			Vector3(rng.randf_range(-15, 15), rng.randf_range(0, 90), rng.randf_range(-15, 15)), Color("8a8580"))
	await get_tree().physics_frame
	await get_tree().physics_frame
	# Denekler
	_kisi("yokus_dik", Vector3(0.0, 0, 5.0), 90.0, {"coat": Color("b3262d"), "hat": "bork"})
	_kisi("yokus_boyuna", Vector3(2.2, 0, 4.0), 0.0, {"coat": Color("2f5fa8")})
	_kisi("merdiven_dur", Vector3(6.6, 0, 2.53), 0.0, {"coat": Color("3a6b3a")})
	var s := Soldier.new(Color("c98a3a"), "stand", "bork")
	add_child(s)
	s.position = _zemin_ust(Vector3(-6, 0, 3))
	s.rotation.y = deg_to_rad(60)
	_subj["moloz_asker"] = s
	_kisi("yokus25_dik", Vector3(-12.5, 0, 4.0), 90.0, {"coat": Color("6a4a3a")})
	var yur := _kisi("yokus_yuru", Vector3(2.0, 0, 0.5), 0.0, {"coat": Color("8a6a4a")})
	_yuru(yur, Vector3(2.0, 0, 0.5), Vector3(2.0, 0, 9.0), 1.3)
	var mer := _kisi("merdiven_yuru", Vector3(7.4, 0, 1.0), 0.0, {"coat": Color("5a6a7a")})
	_yuru(mer, Vector3(7.4, 0, 1.0), Vector3(7.4, 0, 5.5), 1.1)
	var kos := _kisi("yokus_kos", Vector3(-0.2, 0, 9.0), 180.0, {"coat": Color("c98a3a")})
	_yuru(kos, Vector3(-0.2, 0, 9.5), Vector3(-0.2, 0, 0.5), 4.0)
	var at := Horse.new()
	add_child(at)
	at.position = _zemin_ust(Vector3(-12.0, 0, 6.0))
	_subj["at_yokus"] = at
	var kal := 0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ayak-kalabalik="):
			kal = int(a.trim_prefix("--ayak-kalabalik="))
	if kal > 0:
		# Bütçe: kal kişi (yarısı yürür) yokuşta ve düzde, hepsi kameranın 25 m içinde; 20 sn AYAKPERF
		cam.global_position = Vector3(0, 6, -10)
		cam.look_at(Vector3(0, 0, 6))
		for i in kal:
			var p := Vector3(-9 + (i % 10) * 2.0, 0, -2 + (i / 10) * 2.5)
			var k := _kisi("k%d" % i, p, randf() * 360.0, {"coat": Color(randf(), randf(), randf())})
			if i % 2 == 0:
				_yuru(k, p, p + Vector3(0, 0, 6), 1.2 + randf())
		await get_tree().create_timer(32.0).timeout
		get_tree().quit()
		return
	if dir == "":
		await get_tree().create_timer(6.0).timeout
		print("AYAKSAHNE bitti")
		get_tree().quit()
		return
	await get_tree().create_timer(2.5).timeout
	for ad in ["yokus_dik", "yokus_boyuna", "merdiven_dur", "moloz_asker", "yokus25_dik", "at_yokus"]:
		await _kare(ad, _subj[ad])
	for k in 3:
		await _kare("yokus_yuru_%d" % k, _subj["yokus_yuru"])
		await _kare("merdiven_yuru_%d" % k, _subj["merdiven_yuru"])
		await _kare("yokus_kos_%d" % k, _subj["yokus_kos"])
		await get_tree().create_timer(0.37).timeout
	# Genel bakış
	cam.global_position = Vector3(16, 6, 4)
	cam.look_at(Vector3(-2, 0.5, 4))
	await _kaydet("genel")
	print("AYAKSAHNE bitti")
	get_tree().quit()


func _kare(ad: String, n: Node3D) -> void:
	var side := n.global_basis.x.normalized()
	var p := n.global_position
	cam.global_position = p + side * 3.2 + Vector3(0, 0.95, 0)
	cam.look_at(p + Vector3(0, 0.7, 0))
	await _kaydet(ad)


func _kaydet(ad: String) -> void:
	for k in 2:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_jpg(dir.path_join(ad + ".jpg"), 0.85)


func _kisi(ad: String, p: Vector3, yaw: float, look: Dictionary) -> Person:
	var pr := Person.new(look)
	add_child(pr)
	pr.position = _zemin_ust(p)
	pr.rotation.y = deg_to_rad(yaw)
	_subj[ad] = pr
	return pr


func _yuru(n: Node3D, a: Vector3, b: Vector3, v: float) -> void:
	var t := a.distance_to(b) / v
	var tw := create_tween().set_loops()
	var pa := _zemin_ust(a)
	var pb := _zemin_ust(b)
	# Kök yolun iki ucunu doğrusal izler (sahne betikleri gibi): aradaki zemin kırığında kök havada/gömülü kalabilir
	tw.tween_property(n, "position", pb, t).from(pa)
	tw.tween_callback(func(): n.rotation.y += PI)
	tw.tween_property(n, "position", pa, t)
	tw.tween_callback(func(): n.rotation.y += PI)


func _zemin_ust(p: Vector3) -> Vector3:
	var space := get_world_3d().direct_space_state
	var h := space.intersect_ray(PhysicsRayQueryParameters3D.create(p + Vector3(0, 10, 0), p + Vector3(0, -5, 0)))
	return h["position"] if not h.is_empty() else p


func _yokus(at: Vector3, w: float, deg: float) -> void:
	var a := deg_to_rad(deg)
	var L := 10.0 / cos(a)
	var th := 0.3
	var zc := 5.0
	var top := zc * tan(a)
	var c := Vector3(at.x, top - th * 0.5 / cos(a), at.z + zc) + Vector3(0, 0, th * 0.5 * sin(a))
	_kutu(c, Vector3(w, th, L), Vector3(-deg, 0, 0), Color("b8a888"))




func _kutu(p: Vector3, size: Vector3, rot_deg: Vector3, c: Color) -> void:
	var b := StaticBody3D.new()
	add_child(b)
	b.position = p
	b.rotation_degrees = rot_deg
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	b.add_child(cs)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	mi.material_override = m
	b.add_child(mi)
