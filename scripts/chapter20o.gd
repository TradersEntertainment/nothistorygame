extends Node3D
## Bölüm 20 (Osmanlı tarafı) — Gedik (Tolga · 7 Mayıs 1453, gündüz, Urban'ın büyük topu).
##
## Aynı günün öbür yüzü: gündüz Urban'ın topu Mesoteichion'u döver, gece savunucular gediği kapatır.
## Tolga topun ekibindedir: doldur ve nişan al (GunDrill), sonra namluyu zeytinyağıyla soğut (E basılı tut).
## Soğutulmayan namlu çatlamaya başlar (Urban: "Tunç sabır ister"). Üç atış. Akşam: açılan gediğin karesi.
##   20O.1 Gedik açıldı (en az iki isabet) · 20O.2 Surlar dayandı, yarın yine
##   --autotest[=wide]   (varsayılan: 20O.1)

const SHOTS := 3
const COOL_TIME := 2.4

var walls: LandWalls
var gun: Node3D
var player: Player
var hud: Hud
var urban: Person
var crew: Array[Soldier] = []
var drill: GunDrill
var gun_crew: CannonCrew
var cam: TespitCam
var phase := "intro"
var _outcome := ""
var hits := 0
var _acc := 0.0
var _cool := 0.0
var cracks := 0
var _photo := ""
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(20)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	walls = LandWalls.new()
	add_child(walls)
	walls.make_day()
	walls.field.bombard = true          # bütün hat döver: sağda solda bataryalar ateş eder
	walls.set_repair(LandWalls.STAGES)
	gun = walls.build_great_gun()
	drill = GunDrill.new()
	hud.add_child(drill)
	drill.fired.connect(func(a: float): _acc = a)
	_setup_gun_crew()
	urban = Person.new({"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "hat": "kalpak", "face": "urban", "mustache": true, "beard": true,
		"hair": Color("8a5a2a"), "apron": Color("4a3020"), "skin": Color("e8b894")})
	# Urban topun kuyruğunun sağında: oyuncunun ilk bakışında namlu araya girmesin
	urban.position = gun.position + Vector3(4.8, 0, 4.4)
	add_child(urban)
	urban.look_target = player
	for i in 4:
		var s := Soldier.new([Color("b3262d"), Color("6a4a3a"), Color("2f5fa8"), Color("8a6a4a")][i], "stand", "bork" if i % 2 == 0 else "turban")
		s.position = gun.position + Vector3([-4.2, -2.0, 6.6, 8.2][i], 0, [3.2, 4.0, 2.4, 3.4][i])
		add_child(s)
		crew.append(s)
	# Topun çevresi boş kalmasın: iki yanda (setle topçu ordugâhı arasında) sancaklı bölükler, halat çitin ardında
	# topu seyreden askerler, karşıda surlarda Bizans nöbetçileri (uzak)
	for spec in [[Vector3(-40.0, 0, 123.0), Color("b3262d"), Color("2e6a3a")], [Vector3(-22.0, 0, 124.0), Color("2f5fa8"), Color("b3262d")],
			[Vector3(40.0, 0, 123.0), Color("6a4a3a"), Color("f0ece0")], [Vector3(58.0, 0, 124.0), Color("3a6b3a"), Color("b3262d")]]:
		walls.field.formation(spec[0], spec[1], 8, 5, spec[2])
	for i in 7:
		var o := Soldier.new([Color("8a6a4a"), Color("b3262d"), Color("6a4a3a"), Color("3a6b3a")][i % 4], "stand", ["bork", "turban"][i % 2])
		o.position = gun.position + Vector3(-7.5 + i * 2.6 + (i % 2) * 0.4, 0, 13.0 + (i % 3) * 0.5)
		o.rotation.y = PI + (i - 3) * 0.08
		add_child(o)
		if i % 3 == 1:
			o.equip("spear")
	Garrison.land_walls(self, [], [], [], 2010)
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH20O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH20O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = gun.position + Vector3(1.8, 0.05, 9.2)
	player.face(urban.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D20O_N_01")
	await hud.say("SPK_URBAN", "D20O_U_01")
	await hud.say("SPK_TOLGA", "D20O_T_01")
	await hud.say("SPK_URBAN", "D20O_U_02")
	for shot in SHOTS:
		phase = "drill"
		player.global_position = gun.position + Vector3(3.0, 0.05, 6.0)
		player.face(LandWalls.BREACH + Vector3(0, 4.0, 0))
		hud.set_objective(tr("UI_OBJ20O_LOAD") % [shot + 1, SHOTS])
		var wide := GameState.autotest_variant == "wide"
		drill.start(0.25 + shot * 0.1, 0.16)
		while drill.active:
			await get_tree().process_frame
		if GameState.autotest and wide:
			_acc = 0.2
		hud.set_objective("")
		await _fire()
		if shot < SHOTS - 1:
			await _cool_step()
	await _evening()
	await _end_chapter()


## Urban'ın topu: elle doldurma ve nişan (CannonCrew). Barut fıçıları ve gülle yığını topun yanında.
func _setup_gun_crew() -> void:
	gun_crew = CannonCrew.new()
	add_child(gun_crew)
	gun_crew.player = player
	gun_crew.hud = hud
	gun_crew.pivot = gun.get_node("Pivot")
	gun_crew.muzzle = gun.get_node("Pivot/Muzzle")
	gun_crew.recoil_node = gun
	gun_crew.aim_spot = gun.to_global(Vector3(0, 0, 8.5))
	gun_crew.aim_back = 13.5
	gun_crew.supplies = {"powder": gun.to_global(Vector3(-2.7, 0, 2.2)), "ball": gun.to_global(Vector3(3.8, 0, -0.5)),
		"wad": gun.to_global(Vector3(-2.8, 0, 5.6)), "rammer": gun.to_global(Vector3(2.8, 0, 5.6))}
	gun_crew.spawn = ["wad"]
	gun_crew.target = func() -> Vector3: return LandWalls.BREACH + Vector3(0, 4.0, 0)
	gun_crew.hit_radius = 5.0
	gun_crew.tolerance = 16.0
	gun_crew.ground_y = 0.0
	gun_crew.load_radius = 3.2
	gun_crew.design_elev = 5.0
	gun_crew.pitch_min = -2.0
	gun_crew.pitch_max = 14.0
	gun_crew.yaw_limit = 6.0
	var screen := gun.get_node("Screen") as Node3D
	gun_crew.before_fire = func():
		walls.fire_flash()
		var tw := create_tween()
		tw.tween_property(screen, "rotation:x", deg_to_rad(-85), 0.5 if not GameState.autotest else 0.02)
		await tw.finished
	gun_crew.after_fire = func():
		var tw := create_tween()
		tw.tween_property(screen, "rotation:x", 0.0, 1.5)
	gun_crew.setup()
	drill.bind(gun_crew)


func _fire() -> void:
	if not drill.physical:
		walls.fire_flash()
		Audio.sfx("cannon", 2.0, 0.75)
		Vfx.explosion(self, gun.position + Vector3(0, 1.6, -5.0), 1.6)
		player.shake(1.0)
		var tw := create_tween()
		tw.tween_property(gun, "position:z", gun.position.z + 0.8, 0.12)
		tw.tween_property(gun, "position:z", gun.position.z, 1.2)
		await get_tree().create_timer(1.6).timeout
	var hit := _acc >= 0.5
	var at := LandWalls.BREACH + Vector3(randf_range(-1.5, 1.5) if hit else randf_range(-14, 14), 3.0 if hit else 1.0, 1.2 if hit else 6.0)
	if drill.physical and drill.last_impact != Vector3.INF:
		at = drill.last_impact
	walls.impact(at)
	Audio.sfx("explosion_big", -8.0)
	if hit:
		hits += 1
		walls.set_repair(maxi(0, LandWalls.STAGES - hits * 4))
		await hud.say("SPK_URBAN", "D20O_U_HIT_%d" % mini(hits, 3))
	else:
		await hud.say("SPK_URBAN", "D20O_U_MISS")


## Namluyu zeytinyağıyla soğut: E basılı tutulur (Urban'ın topu sıcakken yeniden atılamazdı).
func _cool_step() -> void:
	phase = "cool"
	_cool = 0.0
	player.frozen = false
	hud.set_objective(tr("UI_OBJ20O_COOL"), gun.global_position + Vector3(0, 2.4, 0))
	await hud.say("SPK_URBAN", "D20O_U_COOL")
	var t := 0.0
	var limit := 10.0
	while _cool < COOL_TIME and t < limit:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var near := player.global_position.distance_to(gun.global_position + Vector3(0, 0, -1.0)) < 5.0
		hud.set_prompt(tr("UI_PROMPT20O_COOL") if near else "")
		if (near and Input.is_action_pressed("interact")) or GameState.autotest:
			_cool += dt
			if fmod(_cool, 0.4) < dt:
				Vfx.steam(self, gun.global_position + Vector3(randf_range(-0.6, 0.6), 2.6, randf_range(-3.0, 1.0)))
		hud.set_chase(tr("UI_CH20O_COOL"), _cool / COOL_TIME)
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	hud.set_objective("")
	player.frozen = true
	if _cool < COOL_TIME:
		cracks += 1
		Audio.sfx("kick_metal", -4.0, 0.6)
		await hud.say("SPK_URBAN", "D20O_U_CRACK")
	else:
		await hud.say("SPK_URBAN", "D20O_U_COOLED")


func _evening() -> void:
	phase = "evening"
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH20O_EVENING"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	walls.make_dawn(0.01)
	await hud.fade_to(0.0, 0.8)
	var target := Node3D.new()
	walls.add_child(target)
	target.position = LandWalls.BREACH + Vector3(0, 3.0, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ20O_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege20o")
	hud.add_child(cam)
	cam.max_dist = 140.0
	cam.cone_deg = 8.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	var opened := hits >= 2
	await hud.say("SPK_URBAN", "D20O_U_END_OPEN" if opened else "D20O_U_END_HOLD")
	await hud.say("SPK_TOLGA", "D20O_T_END")
	await hud.say("SPK_NIHAT", "D20O_N_END")
	_outcome = "20O.1" if opened else "20O.2"
	Siege.record(20, _photo, "SIEGE_NOTE_20O_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(20, _outcome)
	await Siege.show_page(hud, 20)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(20)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW20O_TITLE")
	c.nodes = [
		{"id": "load", "key": "FLOW20O_LOAD", "pos": Vector2(0.5, 0.14)},
		{"id": "20O.1", "key": "FLOW_20O_1", "pos": Vector2(0.3, 0.38), "outcome": true},
		{"id": "20O.2", "key": "FLOW_20O_2", "pos": Vector2(0.7, 0.38), "outcome": true},
	]
	c.edges = [["load", "20O.1"], ["load", "20O.2"]]
	c.taken["load"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH20O_STATS") % [hits, SHOTS, cracks, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "20O.1", "wide": "20O.2"}.get(v, "20O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("20", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=20o variant=%s outcome=%s hits=%d cracks=%d" % ["PASS" if ok else "FAIL", v, _outcome, hits, cracks])
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
	player.global_position = gun.position + Vector3(3.0, 0.05, 6.0)
	await get_tree().create_timer(0.8).timeout
	player.face(LandWalls.BREACH + Vector3(0, 4.0, 0))
	drill.start(0.0, 0.16)
	drill.step = 4
	await _shot_png("c20o_01_aim.png")
	drill.stop()
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = gun.position + Vector3(9.0, 3.0, 7.0)
	cv.look_at(gun.position + Vector3(-1.0, 1.8, -8.0), Vector3.UP)
	cv.fov = 58.0
	cv.make_current()
	await get_tree().create_timer(0.25).timeout
	await _shot_png("c20o_cover.png")
	get_tree().quit()
