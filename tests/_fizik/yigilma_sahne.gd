extends Node3D
## Yığılma deney sahnesi (fizik-yığılma): düz, 25° yokuş, merdiven, moloz, sur yolu (3 m; korkuluk) ve hendek.
## Denekler sırayla ölür/düşer/serilir; her birinin 6 anı (0 · 0,2 · 0,45 · 0,8 · 1,3 · 2,4 sn) kameradan kare.
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_fizik/yigilma_sahne.tscn \
##       -- --yig-kare=/klasör [--yigilma=0]
## Klasör yoksa yalnız denetim (ekransız: YIGILMAAUDIT, YIGPERF).

var dir := ""
var cam: Camera3D
var _hedef: Node3D
const ANLAR := [0.0, 0.2, 0.45, 0.8, 1.3, 2.4]


func _ready() -> void:
	GameState.autotest = true
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--yig-kare="):
			dir = a.trim_prefix("--yig-kare=")
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
	_hedef = Node3D.new()
	add_child(_hedef)
	_hedef.position = Vector3(0, 0, -30)
	# Zemin
	_kutu(Vector3(0, -0.25, 0), Vector3(80, 0.5, 80), Vector3.ZERO, Color("7c8a5a"))
	# Yokuş 25° (x -14..-10), +z'ye doğru yükselir
	_yokus(Vector3(-12, 0, 0), 4.0, 25.0)
	# Merdiven (x 6..8)
	for i in 8:
		_kutu(Vector3(7, (i + 1) * 0.18 * 0.5, 2.0 + i * 0.35 + 0.175), Vector3(3, (i + 1) * 0.18, 0.35), Vector3.ZERO, Color("a09a8a"))
	_kutu(Vector3(7, 0.72, 2.0 + 8 * 0.35 + 1.5), Vector3(3, 1.44, 3.0), Vector3.ZERO, Color("a09a8a"))
	# Moloz (x -5)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in 12:
		var p := Vector3(-5 + rng.randf_range(-1.2, 1.2), rng.randf_range(0.0, 0.2), 3 + rng.randf_range(-1.2, 1.2))
		_kutu(p, Vector3(rng.randf_range(0.5, 1.1), rng.randf_range(0.3, 0.7), rng.randf_range(0.5, 1.1)),
			Vector3(rng.randf_range(-20, 20), rng.randf_range(0, 90), rng.randf_range(-20, 20)), Color("8a8580"))
	# Sur yolu: x 14..24, z 0..4, üstü 3 m; dış (z<0) kenarında alçak korkuluk; dibinde hendek (y -1)
	_kutu(Vector3(19, 1.5, 2.0), Vector3(10, 3.0, 4.0), Vector3.ZERO, Color("b0a890"))
	_kutu(Vector3(17, 3.35, 0.15), Vector3(6, 0.7, 0.3), Vector3.ZERO, Color("a09880"))
	_kutu(Vector3(19, -0.6, -4.0), Vector3(12, 0.2, 6.0), Vector3.ZERO, Color("6a6040"))
	await get_tree().physics_frame
	await get_tree().physics_frame
	var olay := [["duz_kilic", Vector3(0, 0, 0), 0.0], ["yokus_kilic", Vector3(-12, 0, 4.5), 90.0],
		["merdiven", Vector3(7, 0, 3.3), 180.0], ["moloz", Vector3(-5, 0, 3), 30.0], ["tekme_kalk", Vector3(3.5, 0, -3), 0.0],
		["kenardan", Vector3(22, 3.0, 0.6), 180.0], ["surda_olum", Vector3(17, 3.0, 0.7), 180.0], ["bitirici", Vector3(3.5, 0, 4), 0.0]]
	var ds: Array = []
	for o in olay:
		var d := Duelist.new({"coat": Color("b3262d"), "hat": "helm"}, "kilij", 0.5, true)
		add_child(d)
		d.position = _zemin_ust(o[1] + Vector3(0, 0.3, 0))
		d.rotation.y = deg_to_rad(o[2])
		d.target = _hedef
		d.hold_back = true
		d.pinned = true
		ds.append(d)
	# Tüfekle vurulan asker (Soldier.shot)
	var s := Soldier.new(Color("c98a3a"), "stand", "bork")
	add_child(s)
	s.position = _zemin_ust(Vector3(-2, 0, -4))
	await get_tree().create_timer(1.2).timeout
	for i in olay.size():
		var o: Array = olay[i]
		var d: Duelist = ds[i]
		var p := d.global_position
		cam.global_position = p + Vector3(3.6, 1.7, 2.2) if o[0] != "kenardan" else p + Vector3(6.5, -0.5, -6.5)
		if o[0] == "surda_olum":
			cam.global_position = p + Vector3(3.0, 1.8, 2.6)
		cam.look_at(p + Vector3(0, 0.5 if o[0] != "kenardan" else -1.2, -0.6))
		_tetik(o[0], d)
		await _anlar(o[0], 3.2 if o[0] == "tekme_kalk" else 0.0)
	cam.global_position = s.global_position + Vector3(3.5, 1.7, 2.0)
	cam.look_at(s.global_position + Vector3(0, 0.5, -0.5))
	s.shot(s.global_position + Vector3(0, 1.2, 8))
	await _anlar("tufek", 0.0)
	await get_tree().create_timer(1.5).timeout
	var Y = load("res://scripts/npc/yigilma.gd")
	print("YIGSAHNE adim n=%d us=%d uygula n=%d us=%d" % [Y.dbg_adim_n, Y.dbg_adim_us, Y.dbg_uyg_n, Y.dbg_uyg_us])
	print("YIGSAHNE bolum %s" % [Y.dbg_s])
	print("YIGSAHNE isin n=%d us=%d" % [load("res://scripts/npc/yigilma.gd").isin_n, load("res://scripts/npc/yigilma.gd").isin_us])
	print("YIGSAHNE bitti us=%d n=%d" % [load("res://scripts/npc/yigilma.gd").toplam_us, load("res://scripts/npc/yigilma.gd").toplam_n])
	get_tree().quit()


func _tetik(ad: String, d: Duelist) -> void:
	match ad:
		"duz_kilic", "surda_olum":
			d._kb = Vector3(0, 0, -2.4)
			d._die()
		"yokus_kilic":
			d._kb = Vector3(-2.4, 0, 0)
			d._die()
		"merdiven":
			d._kb = Vector3(0, 0, -1.5)
			d._die()
		"moloz":
			d._kb = Vector3(1.5, 0, -1.0)
			d._die()
		"tekme_kalk":
			d.knock_down(Vector3(0, 0, -5.6))
		"kenardan":
			d.fall_off(Vector3(0, 0, -1), false)
		"bitirici":
			d.kill()
			d.anim.fade = 0.05
			d.anim.play("Hit_Chest", 0.5, false)
			d.anim.create_tween().tween_property(d.anim, "lean", 0.55, 0.15)
			d._kb = Vector3(0, 0, -0.5)
			get_tree().create_timer(0.5).timeout.connect(func(): d.collapse("Death01", 0.9, 1.3))


func _anlar(ad: String, ek: float) -> void:
	var t0 := Time.get_ticks_msec()
	var anlar: Array = ANLAR.duplicate()
	if ek > 0.0:
		anlar.append_array([2.4 + ek * 0.25, 2.4 + ek * 0.5, 2.4 + ek * 0.8])
	for k in anlar.size():
		var hedef := float(anlar[k])
		while (Time.get_ticks_msec() - t0) / 1000.0 < hedef:
			await get_tree().process_frame
		if dir != "":
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_jpg(dir.path_join("%s_%d.jpg" % [ad, k]), 0.85)


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
	mi.material_override = CharKit.mat(c)
	b.add_child(mi)
