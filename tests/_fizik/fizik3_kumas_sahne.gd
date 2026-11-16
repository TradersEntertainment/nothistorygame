extends Node3D
## Giysi kumaşı deney sahnesi (fizik-3): yürüyen kaftanlı, koşan asker (bel eteği) ve pelerinli, rüzgârda duran padişah
## (yenler), oturan kaftanlı (tabure ve yerde), yığılan kaftanlı, merdiven çıkan kaftanlı, yokuşta duran kadın (etek).
## Her denekten 0,15 sn arayla 6 kare (yandan ve arkadan); tek paftada (tests/_fizik/fizik3_pafta.py).
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_fizik/fizik3_kumas_sahne.tscn \
##       -- --fizik3-kare=/klasör [--kumas=0] [--kumas-olc] [--fizik3-kalabalik=60]
## Klasör yoksa yalnız 8 sn koşar (hata denetimi; ekransız da koşar).

var dir := ""
var cam: Camera3D
var _subj := {}


func _ready() -> void:
	GameState.autotest = true
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--fizik3-kare="):
			dir = a.trim_prefix("--fizik3-kare=")
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("9fb8d0")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.45, 0.45, 0.5)
	e.ambient_light_energy = 1.0
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, 70, 0)
	sun.shadow_enabled = true
	sun.light_energy = 0.75
	add_child(sun)
	cam = Camera3D.new()
	add_child(cam)
	cam.current = true
	cam.fov = 50.0
	cam.position = Vector3(0, 3, -8)
	_kutu(Vector3(0, -0.25, 0), Vector3(80, 0.5, 80), Vector3.ZERO, Color("7c8a5a"))
	# Merdiven (x 12..14): 6 basamak 0,18 × 0,35, üstte sahanlık
	for i in 6:
		_kutu(Vector3(13, (i + 1) * 0.18 * 0.5, 2.0 + i * 0.35 + 0.175), Vector3(2, (i + 1) * 0.18, 0.35), Vector3.ZERO, Color("a09a8a"))
	_kutu(Vector3(13, 0.54, 4.1 + 1.5), Vector3(2, 1.08, 3.0), Vector3.ZERO, Color("a09a8a"))
	# Yokuş 20° (x -12..-8)
	var y := _kutu(Vector3(-10, 0, 4), Vector3(4, 0.4, 10), Vector3(-20, 0, 0), Color("8a8a6a"))
	y.position.y = 4.0 * sin(deg_to_rad(20.0)) * 0.5
	# Tabure
	_kutu(Vector3(6, 0.21, 10), Vector3(0.45, 0.42, 0.45), Vector3.ZERO, Color("6a4a30"))
	await get_tree().physics_frame
	await get_tree().physics_frame
	var kaftan := {"coat": Color("2f5fa8"), "pants": Color("3a2a20"), "hat": "turban", "beard": true, "robe": Color("2f5fa8")}
	# 1. yürüyen kaftanlı (z boyunca gidip gelir, uçlarda döner)
	var yur := _kisi("kaftan_yuru", Vector3(0, 0, 0), 0.0, kaftan)
	_yuru(yur, Vector3(0, 0, 0), Vector3(0, 0, 9.0), 1.35)
	# 2. koşan asker (bel eteği) ve pelerinli (Giustiniani kılığı)
	var s := Soldier.new(Color("b3262d"), "stand", "bork")
	add_child(s)
	s.position = Vector3(4, 0, 0)
	_subj["asker_kos"] = s
	_yuru(s, Vector3(4, 0, 0), Vector3(4, 0, 14.0), 4.2)
	var pel := _kisi("pelerin_kos", Vector3(-4, 0, 0), 0.0, {"coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero", "beard": true})
	_yuru(pel, Vector3(-4, 0, 0), Vector3(-4, 0, 14.0), 4.0)
	# 3. rüzgârda duran padişah (kaftan, yenler)
	_kisi("padisah_dur", Vector3(8, 0, 2), 200.0, {"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true, "robe": Color("c8323a")})
	# 4. oturan kaftanlı (tabure) ve yerde bağdaş
	var ot := _kisi("oturan", Vector3(6, 0, 10), 180.0, kaftan.merged({"robe": Color("6a4a3a"), "coat": Color("6a4a3a")}, true))
	ot.position.y = 0.0      # kök yerde, kalça taburede (Rig "sit": gövde 0,22 iner)
	ot.set_activity("sit")
	var bag := _kisi("bagdas", Vector3(11, 0, 10), 180.0, kaftan.merged({"robe": Color("3f7a3a"), "coat": Color("3f7a3a")}, true))
	bag.set_activity("sit_ground")
	# 5. yığılan kaftanlı (tüfekle vurulur)
	_kisi("yigilan", Vector3(-6, 0, 10), 90.0, kaftan.merged({"robe": Color("a8804a"), "coat": Color("a8804a")}, true))
	# 6. merdiven çıkan kaftanlı
	var mer := _kisi("merdiven", Vector3(13.4, 0, 0.8), 0.0, kaftan.merged({"robe": Color("5a3a6a"), "coat": Color("5a3a6a")}, true))
	_yuru(mer, Vector3(13.4, 0, 0.8), Vector3(13.4, 0, 5.0), 1.0)
	# 8. oturan börklü (Person "bork": enseye düşen yatırtma) ve oturan börklü asker
	var bk := _kisi("bork_otur", Vector3(16, 0, 10), 90.0, {"coat": Color("c8262f"), "pants": Color("f0eadc"), "hat": "bork"})
	bk.set_activity("sit_ground")
	var sb := Soldier.new(Color("b3262d"), "stand", "bork")
	add_child(sb)
	sb.position = Vector3(18, 0, 10)
	sb.rotation.y = deg_to_rad(90.0)
	_subj["bork_asker"] = sb
	# 7. yokuşta duran kadın (etek)
	_kisi("etek_yokus", Vector3(-10.5, 0, 4.0), 90.0, {"coat": Color("c98a3a"), "pants": Color("7a3a5a"), "skirt": true, "hat": "bun"})
	var kal := 0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--fizik3-kalabalik="):
			kal = int(a.trim_prefix("--fizik3-kalabalik="))
	if kal > 0:
		# Bütçe: kal kişi (yarısı kaftanlı, yarısı yürür), hepsi kameranın 25 m içinde ve görüşte; 30 sn ölçüm
		cam.global_position = Vector3(0, 7, -12)
		cam.look_at(Vector3(0, 0, 6))
		for i in kal:
			var p := Vector3(-9 + (i % 10) * 2.0, 0, -2 + (i / 10) * 2.5)
			var lk := {"coat": Color(randf(), randf(), randf())}
			if i % 2 == 0:
				lk["robe"] = lk["coat"]
			var k := _kisi("k%d" % i, p, randf() * 360.0, lk)
			if i % 2 == 0:
				_yuru(k, p, p + Vector3(0, 0, 6), 1.2 + randf())
		await get_tree().create_timer(32.0).timeout
		get_tree().quit()
		return
	if dir == "":
		await get_tree().create_timer(4.0).timeout
		(_subj["yigilan"] as Person).shot((_subj["yigilan"] as Node3D).global_position + Vector3(-3, 1.3, 0))
		await get_tree().create_timer(4.0).timeout
		print("KUMASSAHNE bitti")
		get_tree().quit()
		return
	await get_tree().create_timer(2.0).timeout
	# Yürüyen: yandan (yürümeye başlarken ve dönüşte), arkadan
	await _dizi("kaftan_yuru_yan", "kaftan_yuru", "yan", 3.0)
	await _dizi("kaftan_yuru_arka", "kaftan_yuru", "arka", 3.2)
	await _dizi("asker_kos_yan", "asker_kos", "yan", 3.6)
	await _dizi("pelerin_kos_yan", "pelerin_kos", "yan", 3.6)
	await _dizi("pelerin_kos_arka", "pelerin_kos", "arka", 3.6)
	await _dizi("padisah_ruzgar_yan", "padisah_dur", "yan", 3.4)
	await _dizi("padisah_ruzgar_arka", "padisah_dur", "arka", 3.4)
	await _dizi("oturan_yan", "oturan", "yan", 2.6)
	await _dizi("bagdas_yan", "bagdas", "yan", 2.6)
	await _dizi("merdiven_yan", "merdiven", "yan", 3.0)
	await _dizi("etek_yokus_yan", "etek_yokus", "yan", 2.8)
	await _dizi("bork_otur_yan", "bork_otur", "yan", 2.2)
	await _dizi("bork_otur_arka", "bork_otur", "arka", 2.2)
	await _dizi("bork_asker_yan", "bork_asker", "yan", 2.2)
	# Yığılan: vurulur, 6 kare
	var yg := _subj["yigilan"] as Person
	yg.shot(yg.global_position + yg.global_basis.z * 3.0 + Vector3(0, 1.3, 0))
	await _dizi("yigilan_yan", "yigilan", "yan", 3.4, true)
	await get_tree().create_timer(1.5).timeout
	await _dizi("yigilan_son", "yigilan", "ust", 3.0)
	cam.global_position = Vector3(4, 5, -6)
	cam.look_at(Vector3(4, 0.5, 6))
	await _kaydet("genel")
	print("KUMASSAHNE bitti")
	get_tree().quit()


## 6 kare, 0,15 sn arayla; kamera deneğin yanında (yan), arkasında (arka) ya da üstünde (ust); her karede deneği izler
## (_process), kok_sabit: kamera ilk yerde kalır (yığılan)
var _tk: Array = []

func _dizi(ad: String, kim: String, yon: String, dd: float, kok_sabit := false) -> void:
	var n := _subj[kim] as Node3D
	_tk = [n, yon, dd, n.global_position if kok_sabit else Vector3.INF, n.global_basis]
	for k in 3:
		await get_tree().process_frame
	for i in 6:
		await _kaydet("%s_%d" % [ad, i])
		await get_tree().create_timer(0.15).timeout
	_tk = []


func _process(_d: float) -> void:
	if _tk.is_empty():
		return
	var n := _tk[0] as Node3D
	var dd: float = _tk[2]
	var p: Vector3 = n.global_position if _tk[3] == Vector3.INF else _tk[3]
	var b: Basis = n.global_basis if _tk[3] == Vector3.INF else _tk[4]
	var side := b.x.normalized()
	var back := -b.z.normalized()
	match str(_tk[1]):
		"yan":
			cam.global_position = p + side * dd + Vector3(0, 0.9, 0)
		"arka":
			cam.global_position = p + back * dd + side * 0.8 + Vector3(0, 1.1, 0)
		_:
			cam.global_position = p + side * dd * 0.6 + Vector3(0, dd * 0.8, 0)
	cam.look_at(p + Vector3(0, 0.7, 0))


func _kaydet(ad: String) -> void:
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
	tw.tween_callback(func(): n.rotation.y = atan2(b.x - a.x, b.z - a.z))
	tw.tween_method(func(k: float): n.position = _zemin_ust(a.lerp(b, k)), 0.0, 1.0, t)
	tw.tween_interval(0.8)
	tw.tween_callback(func(): n.rotation.y = atan2(a.x - b.x, a.z - b.z))
	tw.tween_method(func(k: float): n.position = _zemin_ust(b.lerp(a, k)), 0.0, 1.0, t)
	tw.tween_interval(0.8)


## Görünen zemin (kişiler sayılmaz: yürüyenin kendi etkileşim kutusuna basıp yükselmesin)
func _zemin_ust(p: Vector3) -> Vector3:
	var y := Unclip.floor_y(self, Vector3(p.x, 0.0, p.z), 6.0, 2.0)
	return Vector3(p.x, 0.0 if is_nan(y) else y, p.z)


func _kutu(p: Vector3, size: Vector3, rot_deg: Vector3, c: Color) -> StaticBody3D:
	var sb := StaticBody3D.new()
	add_child(sb)
	sb.position = p
	sb.rotation_degrees = rot_deg
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	sb.add_child(cs)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = Props.mat(c)
	sb.add_child(mi)
	return sb
