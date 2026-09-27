extends Node3D
## Bölüm 18 (Bizans tarafı) — Fıçı Köprü, surdan (Tolga · Mayıs başı 1453, Haliç surları).
##
## Osmanlıların Haliç'in iç ucunda kurduğu fıçı köprünün öbür yüzü. Tolga Haliç surunun üstünde küçük bir Bizans topunun
## ekibindedir. Kaynaklar savunucuların büyük toplarını pek kullanamadığını yazar: geri tepme kendi surlarını sarsıyordu.
## Her atıştan önce barut miktarı seçilir (az: sur güvende, menzil kısa · çok: menzil tam, sur çatlar), sonra GunDrill.
## Köprünün ucundaki top karşılık verir. Tespit: köprü ve üstündeki top.
##   18B.1 Köprüye isabet (en az bir) · 18B.2 Gülleler suya düştü
##   --autotest[=miss]   (varsayılan: 18B.1)

const SHOTS := 3
const WALL_Z := 62.0
const WALK_Y := 9.6
const BRIDGE_Z0 := 2.0
const SEC_LEN := 3.0
const SECTIONS := 11
const DECK_Y := 0.7

var player: Player
var hud: Hud
var gunner: Person
var gun: Node3D
var bridge_gun: Node3D
var sections: Array[Node3D] = []
var drill: GunDrill
var gun_crew: CannonCrew
var cam: TespitCam
var phase := "intro"
var _outcome := ""
var hits := 0
var cracks := 0
var _acc := 0.0
var _photo := ""
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(18)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", false))
	hud.set_signal(0)
	drill = GunDrill.new()
	hud.add_child(drill)
	drill.fired.connect(func(a: float): _acc = a)
	_build()
	_setup_gun_crew()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	var we := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("4a86c8")
	sm.sky_horizon_color = Color("bcd8ec")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.5
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.85
	e.fog_enabled = true
	e.fog_light_color = Color("c8d8e8")
	e.fog_density = 0.0022
	we.environment = e
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 120, 0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	add_child(sun)
	SkyBody.attach(self, sun)
	# Haliç: su, karşıda Osmanlı kıyısı (tepeler, ordugâh, köprü malzemesi, kadırgalar); bu yanda Haliç surları ve şehir
	Horn.build(self, WALL_Z, Rect2(), Vector2(-20.0, 20.0), 1811)
	# Köprünün kıyı başı: çalışan ve bekleyen askerler, fıçı yığını
	var dd := Dressing.new(1812)
	for row in 3:
		for k in 5 - row:
			dd.cyl(0.4, 1.2, Vector3(-7.5 + k * 0.82 + row * 0.41, 0.4 + row * 0.7, -3.0), Color("7a5634"), Vector3(90, 0, 0), 10)
	for i in 7:
		dd.box(Vector3(0.5, 0.1, 3.6), Vector3(6.0, 0.35 + i * 0.12, -3.5), Color("9a7248"))
	dd.build(self)
	var men: Array = []
	for i in 8:
		men.append([Transform3D(Basis(Vector3.UP, randf() * TAU), Vector3(-10.0 + i * 2.6, 0.3, -6.0 - (i % 3) * 1.5)), Horn.COATS[i % 6]])
	Horn.figures(self, men)
	# Köprü: tamamlanmış yedi bölüm, ucunda top
	for i in SECTIONS:
		var s := Node3D.new()
		s.position = Vector3(0, 0, BRIDGE_Z0 + SEC_LEN * (i + 0.5))
		add_child(s)
		for sx: float in [-1.3, 1.3]:
			Props.cyl(s, 0.55, 2.2, Vector3(sx, 0.15, 0), Color("7a5634"), Vector3(90, 0, 0), 12)
		for k in 6:
			Props.box(s, Vector3(4.2, 0.1, 0.46), Vector3(0, DECK_Y, -1.2 + k * 0.49), Color("9a7248").darkened((k % 3) * 0.06))
		sections.append(s)
	bridge_gun = Node3D.new()
	bridge_gun.position = Vector3(0, DECK_Y, BRIDGE_Z0 + SEC_LEN * (SECTIONS - 1))
	add_child(bridge_gun)
	Props.box(bridge_gun, Vector3(1.4, 0.4, 3.2), Vector3(0, 0.3, 0), Color("5a3e26"))
	Props.cyl(bridge_gun, 0.35, 3.0, Vector3(0, 0.85, 0.2), Color("8c5e26"), Vector3(90, 0, 0), 12)
	for i in 3:
		var s := Soldier.new([Color("8a6a4a"), Color("6a4a3a"), Color("b3262d")][i], "stand", "turban")
		s.position = bridge_gun.position + Vector3(-1.6 + i * 1.6, 0, -2.0)
		add_child(s)
	# Haliç surunun bu kesimi: gövde, yürüyüş yolu, mazgallar, yan kuleler
	Props.set_pattern(Props.solid(self, Vector3(40, WALK_Y, 3.0), Vector3(0, WALK_Y * 0.5, WALL_Z + 1.5), Color.WHITE), Color("cdbd9e"), "ashlar")
	Props.set_pattern(Props.solid(self, Vector3(40, 0.3, 4.0), Vector3(0, WALK_Y - 0.15, WALL_Z - 0.5), Color.WHITE), Color("b8a888"), "cobble")
	for i in 16:
		Props.set_pattern(Props.box(self, Vector3(1.2, 1.1, 0.5), Vector3(-19.0 + i * 2.5, WALK_Y + 0.55, WALL_Z - 2.3), Color.WHITE), Color("a89878"), "ashlar")
	var rail := Props.solid(self, Vector3(40, 1.1, 0.3), Vector3(0, WALK_Y + 0.55, WALL_Z - 2.4), Color.WHITE)
	rail.get_child(0).visible = false
	rail.set_meta("no_climb", true)
	for sx: float in [-1.0, 1.0]:
		Props.set_pattern(Props.solid(self, Vector3(6.0, WALK_Y + 5.0, 6.0), Vector3(sx * 17.0, (WALK_Y + 5.0) * 0.5, WALL_Z), Color.WHITE), Color("c8b898"), "ashlar")
	var back := Props.solid(self, Vector3(40, 3.0, 0.3), Vector3(0, WALK_Y + 1.5, WALL_Z + 1.6), Color.WHITE)
	back.get_child(0).visible = false
	back.set_meta("no_climb", true)
	# Küçük Bizans topu (mazgal aralığında)
	gun = Node3D.new()
	gun.position = Vector3(-0.25, WALK_Y, WALL_Z - 1.4)
	add_child(gun)
	Props.box(gun, Vector3(0.9, 0.35, 1.8), Vector3(0, 0.3, 0.2), Color("5a3e26"))
	for sx: float in [-0.5, 0.5]:
		Props.cyl(gun, 0.3, 0.1, Vector3(sx, 0.3, 0.6), Color("3a2a1c"), Vector3(0, 0, 90), 10)
	# Namlu muylu ekseninde (elle nişan): Pivot, ağzında Muzzle (-Z dışarı, köprüye doğru)
	var pv := Node3D.new()
	pv.name = "Pivot"
	pv.position = Vector3(0, 0.7, 0.2)
	gun.add_child(pv)
	Props.cyl(pv, 0.2, 1.8, Vector3(0, 0, -0.4), Color("7a5020"), Vector3(90, 0, 0), 10)
	Props.cyl(pv, 0.25, 0.18, Vector3(0, 0, -1.25), Color("6a4418"), Vector3(90, 0, 0), 10)
	var mz := Node3D.new()
	mz.name = "Muzzle"
	mz.position = Vector3(0, 0, -1.36)
	pv.add_child(mz)
	for k in 3:
		Props.ball(gun, 0.12, Vector3(0.8, 0.12, 0.8 + k * 0.26), Color("8a8480"), Vector3.ONE, 8)
	gunner = Person.new({"coat": Color("7a2a24"), "pants": Color("3a2a22"), "hat": "helm", "beard": true, "mustache": true, "skin": Color("e0b08a")})
	gunner.set_meta("spk", "SPK_DEFENDER")
	gunner.position = Vector3(-2.6, WALK_Y, WALL_Z - 0.4)
	gunner.rotation.y = PI * 0.8
	add_child(gunner)
	gunner.look_target = player


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH18B_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH18B_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = Vector3(1.4, WALK_Y + 0.05, WALL_Z - 0.2)
	player.face(gunner.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D18B_N_01")
	await hud.say("SPK_DEFENDER", "D18B_G_01")
	await hud.say("SPK_TOLGA", "D18B_T_01")
	await hud.say("SPK_DEFENDER", "D18B_G_02")
	for shot in SHOTS:
		phase = "drill"
		player.global_position = gun.position + Vector3(0.0, 0.05, 1.7)
		player.face(bridge_gun.global_position + Vector3(0, 1.0, 0))
		var big := await hud.choose(["UI_C18B_SMALL", "UI_C18B_BIG"], 0.0, 0 if GameState.autotest_variant == "miss" else 1)
		hud.set_objective(tr("UI_OBJ18B_LOAD") % [shot + 1, SHOTS])
		drill.start(0.3 + shot * 0.1, 0.18, 1.0 if big == 1 else 0.72)
		while drill.active:
			await get_tree().process_frame
		hud.set_objective("")
		await _fire(big == 1)
		if shot < SHOTS - 1:
			await _reply()
	await _photo_step()
	await _end_chapter()


## Küçük Bizans topu: elle doldurma ve nişan (CannonCrew). Barut, tapa, tokmak yürüyüş yolunda.
func _setup_gun_crew() -> void:
	gun_crew = CannonCrew.new()
	add_child(gun_crew)
	gun_crew.player = player
	gun_crew.hud = hud
	gun_crew.pivot = gun.get_node("Pivot")
	gun_crew.muzzle = gun.get_node("Pivot/Muzzle")
	gun_crew.recoil_node = gun
	gun_crew.aim_spot = gun.to_global(Vector3(0, 0, 2.3))
	gun_crew.aim_back = 2.6
	gun_crew.supplies = {"powder": gun.to_global(Vector3(-4.0, 0, 1.8)), "ball": gun.to_global(Vector3(1.3, 0, 1.2)),
		"wad": gun.to_global(Vector3(2.6, 0, 1.8)), "rammer": gun.to_global(Vector3(4.2, 0, 1.6))}
	gun_crew.spawn = ["powder", "wad"]
	gun_crew.target = func() -> Vector3: return bridge_gun.global_position + Vector3(0, 0.8, 0)
	gun_crew.hit_radius = 2.6
	gun_crew.tolerance = 10.0
	gun_crew.ground_y = 0.0
	gun_crew.load_radius = 2.4
	gun_crew.design_elev = 3.0
	gun_crew.pitch_min = -20.0
	gun_crew.pitch_max = 20.0
	gun_crew.yaw_limit = 20.0
	gun_crew.setup()
	drill.bind(gun_crew)


func _fire(big: bool) -> void:
	if not drill.physical:
		Audio.sfx("cannon", -2.0, 1.25)
		Vfx.explosion(self, gun.global_position + Vector3(0, 0.7, -1.4), 0.5)
		player.shake(0.6 if big else 0.3)
		await get_tree().create_timer(1.2).timeout
	var hit := big and _acc >= 0.5
	var at := bridge_gun.global_position + (Vector3(randf_range(-1.0, 1.0), 0.6, randf_range(-3.0, 1.0)) if hit else Vector3(randf_range(-6, 6), 0.0, randf_range(8.0, 16.0)))
	if drill.physical and drill.last_impact != Vector3.INF:
		at = drill.last_impact
	if hit:
		hits += 1
		Vfx.explosion(self, at, 0.8)
		Audio.sfx("explosion_small", -4.0)
		var s := sections[SECTIONS - 1 - mini(hits, 3)]
		var tw := create_tween()
		tw.tween_property(s, "position:y", -0.35, 1.0)
		tw.parallel().tween_property(s, "rotation:z", 0.12 * (1 if hits % 2 == 0 else -1), 1.0)
		await hud.say("SPK_DEFENDER", "D18B_G_HIT_%d" % mini(hits, 2))
	else:
		if not drill.physical:
			Vfx.dust(self, at, 0.8)
			Audio.sfx("splash", -2.0, 0.7)
		await hud.say("SPK_DEFENDER", "D18B_G_SHORT" if not big else "D18B_G_MISS")
	if big:
		# Büyük barut: geri tepme surun taşlarını oynatır
		cracks += 1
		Vfx.dust(self, gun.global_position + Vector3(0, -0.4, 0.8), 0.6)
		Audio.sfx("land_thud", -2.0, 0.6)
		await hud.say("SPK_DEFENDER", "D18B_G_CRACK_%d" % mini(cracks, 2))


## Köprüdeki top karşılık verir: gülle surun dibine çarpar.
func _reply() -> void:
	await get_tree().create_timer(0.6).timeout
	Vfx.explosion(self, bridge_gun.global_position + Vector3(0, 1.0, 2.0), 0.6)
	Audio.sfx("cannon", -8.0, 0.9)
	await get_tree().create_timer(1.0).timeout
	Vfx.dust(self, Vector3(randf_range(-6, 6), 3.0, WALL_Z - 0.6), 1.0)
	Audio.sfx("explosion_big", -6.0)
	player.shake(0.5)
	hud.bark("SPK_TOLGA", "D18B_T_REPLY", 2.5)
	await get_tree().create_timer(1.0).timeout


func _photo_step() -> void:
	var target := Node3D.new()
	bridge_gun.add_child(target)
	target.position = Vector3(0, 1.0, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ18B_PHOTO"), bridge_gun.global_position + Vector3(0, 1.2, 0))
	cam = TespitCam.new(player, hud, target, "siege18b")
	hud.add_child(cam)
	cam.max_dist = 90.0
	cam.cone_deg = 10.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_DEFENDER", "D18B_G_END_HIT" if hits > 0 else "D18B_G_END_MISS")
	await hud.say("SPK_TOLGA", "D18B_T_END")
	await hud.say("SPK_NIHAT", "D18B_N_END")
	_outcome = "18B.1" if hits > 0 else "18B.2"
	Siege.record(18, _photo, "SIEGE_NOTE_18B_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(18, _outcome)
	await Siege.show_page(hud, 18)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(18)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW18B_TITLE")
	c.nodes = [
		{"id": "gun", "key": "FLOW18B_GUN", "pos": Vector2(0.5, 0.14)},
		{"id": "18B.1", "key": "FLOW_18B_1", "pos": Vector2(0.3, 0.38), "outcome": true},
		{"id": "18B.2", "key": "FLOW_18B_2", "pos": Vector2(0.7, 0.38), "outcome": true},
	]
	c.edges = [["gun", "18B.1"], ["gun", "18B.2"]]
	c.taken["gun"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH18B_STATS") % [hits, SHOTS, cracks, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "18B.1", "miss": "18B.2"}.get(v, "18B.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("18", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=18b variant=%s outcome=%s hits=%d cracks=%d" % ["PASS" if ok else "FAIL", v, _outcome, hits, cracks])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot_png(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.show_remote(false)
	player.global_position = gun.position + Vector3(0.0, 0.05, 1.7)
	await get_tree().create_timer(0.8).timeout
	player.face(bridge_gun.global_position + Vector3(0, 1.0, 0))
	drill.start(0.0, 0.18)
	drill.step = 4
	await _shot_png("c18b_01_aim.png")
	drill.stop()
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = gun.global_position + Vector3(3.0, 1.6, 2.5)
	cv.look_at(bridge_gun.global_position + Vector3(0, 1.0, 6.0), Vector3.UP)
	cv.fov = 50.0
	cv.make_current()
	await get_tree().create_timer(0.3).timeout
	await _shot_png("c18b_cover.png")
	get_tree().quit()
