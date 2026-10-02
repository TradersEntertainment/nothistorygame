extends Node3D
## Bölüm 20 (Osmanlı tarafı) — Gedik (Tolga · 7 Mayıs 1453, gündüz, Urban'ın büyük topu).
##
## Aynı günün öbür yüzü: gündüz Urban'ın topu Mesoteichion'u döver, gece savunucular gediği kapatır.
## Tolga topun ekibindedir: doldur ve nişan al (GunDrill), sonra namluyu zeytinyağıyla soğut (E basılı tut).
## Soğutulmayan namlu çatlamaya başlar (Urban: "Tunç sabır ister"). Üç atış. Akşam: açılan gediğin karesi.
##   20O.1 Gedik açıldı (en az iki isabet) · 20O.2 Surlar dayandı, yarın yine
##   Gece yarısı hücumu: Urban'ın uzattığı tüfekle mazgaldakilere, sonra azaplarla gediğe (WaveRunner, surda tüfekçi).
##   --autotest[=wide|lose]   (varsayılan: 20O.1)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
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
	_build_tally()
	# Önceki hücumlardan kalanlar: hendekte ve sur dibinde yatan azaplar, düşmüş hasır kalkanlar
	for lane: Array in [[Vector3(-26.0, 0, 27.5), Vector3(26.0, 0, 27.5), 5.0], [Vector3(-24.0, 0, 17.9), Vector3(24.0, 0, 17.9), 0.6]]:
		var bx := BattleExtras.new()
		bx.side = "osm"
		add_child(bx)
		bx.hit_every = 0.0
		bx.populate(lane[0], lane[1], lane[2], 0, 5, 0, 2020 + int(lane[0].z))
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
	# Karşıda gedikte Bizanslılar gündüz de onarır: kazık çakanlar, toprak ve kalas taşıyanlar (top vurdukça)
	var fight := WallFight.new()
	add_child(fight)
	fight.add_builders(LandWalls.BREACH + Vector3(0, 0, -1.4), 4, 2070)
	fight.add_carriers(LandWalls.DEPOT + Vector3(-2.6, 0, 2.6), LandWalls.BREACH + Vector3(0, 0, -2.6), 4, 2080)
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
	# Büyük top günde en çok yedi kez atabilirdi (her atıştan sonra soğuma, yeniden doldurma saatler sürerdi)
	urban.emote("nod")
	await hud.say("SPK_URBAN", "D20O_U_SEVEN")
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
	# Gece yarısı hücumu (7 Mayıs gecesi azaplar gediğe yüklendi): Bölüm 20'nin Osmanlı aynası
	await _assault()
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
	gun_crew.before_fire = func():
		# Siperlik halatlarla kalkar, sonra ateş
		await get_tree().create_timer(walls.gun_screen(true, 0.7 if not GameState.autotest else 0.02)).timeout
		walls.fire_flash()
	gun_crew.after_fire = func():
		pass     # siperlik fire_flash'ten sonra kendiliğinden iner
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
	_tally_mark(hit)
	if hit:
		hits += 1
		walls.set_repair(maxi(0, LandWalls.STAGES - hits * 4))
		await hud.say("SPK_URBAN", "D20O_U_HIT_%d" % mini(hits, 3))
	else:
		await hud.say("SPK_URBAN", "D20O_U_MISS")


## Atış tahtası: kara tahta bir direğe çakılı, üstünde "BUGÜN · 7 ATIŞ"; her atışta bir çizik (isabet kırmızı).
var _tally: Node3D
var _tally_n := 0


func _build_tally() -> void:
	_tally = Node3D.new()
	add_child(_tally)
	_tally.global_position = gun.position + Vector3(6.2, 0, 3.0)
	_tally.rotation.y = deg_to_rad(-35)
	Props.cyl(_tally, 0.07, 2.2, Vector3(0, 1.1, 0), Color("5a4028"), Vector3.ZERO, 6)
	Props.box(_tally, Vector3(1.3, 0.8, 0.06), Vector3(0, 1.85, 0.08), Color("2a2e2a"))
	Props.label(_tally, "BUGÜN · 7 ATIŞ", Vector3(0, 2.13, 0.12), 26, Color("f2eee0"), Vector3.ZERO, 1.15)


func _tally_mark(hit: bool) -> void:
	if _tally == null:
		return
	Props.box(_tally, Vector3(0.04, 0.34, 0.01), Vector3(-0.5 + _tally_n * 0.14, 1.8, 0.115), Color("d83a2a") if hit else Color("f2eee0"), Vector3(0, 0, 8))
	_tally_n += 1


## Namluyu zeytinyağıyla soğut: E basılı tutulur (Urban'ın topu sıcakken yeniden atılamazdı).
func _cool_step() -> void:
	phase = "cool"
	_cool = 0.0
	player.frozen = false
	hud.set_objective(tr("UI_OBJ20O_COOL"), gun.global_position + Vector3(0, 2.4, 0))
	Lore.scatter(self, "20o")
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


var gun_shots := 0
var gun_hits := 0
var gunner_shots := 0
var gunner_dodged := 0
var _duel_won := true


## Gece yarısı: Urban bir tüfek uzatır (kendi dökümü değil). Önce hendeğin ötesinden surdaki savunuculara
## (mazgalda görünüp saklanırlar), sonra azaplarla gediğin molozuna: Cenevizliler ve savunucular, surda bir
## tüfekçi. Ölüm yok; kaybedilirse Tolga geri çekilir (sonuç topun açtığı gediğe bağlıdır, hücuma değil).
func _assault() -> void:
	phase = "assault"
	await hud.fade_to(1.0, 0.6)
	await hud.card([[tr("UI_CH20O_NIGHT"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	var y := LandWalls.OUTER_H
	# Yakın ova (hendeğin dış kıyısı) bu bölümde boş: hücumun toplandığı yere çiğnenmiş toprak
	if get_node_or_null("AssaultGround") == null:
		var g := Props.solid(self, Vector3(44.0, 0.4, 18.0), Vector3(0, -0.2, 45.2), Color("6a5a40"))
		g.name = "AssaultGround"
		Props.set_pattern(g, Color("6a5a40"), "dirt")
	player.global_position = Vector3(2.0, 0.05, 41.0)
	player.face(Vector3(0, y + 1.2, 15.3))
	urban.global_position = Vector3(4.2, 0, 42.5)
	urban.look_target = player
	await hud.fade_to(0.0, 0.6)
	Audio.intensity(2, "walls_night")
	await hud.say("SPK_URBAN", "D20O_U_GUN")
	var peek: Array = []
	var xs := [-10.0, -7.5, 7.5, 10.0]
	for i in 4:
		peek.append({"coat": [Color("7a2a24"), Color("8a8e96"), Color("5a6a7a"), Color("6a5a3a")][i], "hat": "helm",
			"pos": Vector3(xs[i], y, 15.25), "face": Vector3(xs[i], y, 40.0), "phase": i * 0.9})
	var res: Dictionary = await GunRange.run(self, hud, player, {"peek": peek, "limit": 28.0,
		"objective": tr("UI_OBJ20O_GUN") % 4, "look": Vector3(0, y + 1.2, 15.3)})
	gun_shots = res["shots"]
	gun_hits = res["hits"]
	await hud.say("SPK_TOLGA", "D20_T_GUN_GOOD" if gun_hits >= 2 else "D26O_T_GUN_BAD")
	# Gedik: moloz dilinin üstünde, azaplarla birlikte
	await hud.fade_to(1.0, 0.4)
	var at := LandWalls.BREACH + Vector3(0, 0, 4.6)
	at.y = LandWalls.outside_y(at.x, at.z)
	player.global_position = at + Vector3(0, 0.05, 0)
	player.face(LandWalls.BREACH + Vector3(0, 2.0, 0))
	await hud.fade_to(0.0, 0.4)
	await hud.say("SPK_URBAN", "D20O_U_CHARGE")
	var crest := LandWalls.on_rubble(LandWalls.BREACH + Vector3(0, 0, 1.2))
	var spots := [crest + Vector3(-1.2, 0, 0), crest + Vector3(1.2, 0, 0)]
	var specs := []
	for k in 2:
		specs.append({"pos": spots[k], "blade": "spathion", "shield": true, "name": "SPK_GENOESE",
			"look": {"coat": Color("8a8e96"), "pants": Color("3a2a22"), "hat": "helm", "mustache": true, "beard": k == 0}})
	var more := []
	var extra := 1 if gun_hits < 2 else 0          # mazgaldakiler susturulmadıysa gedik daha kalabalık
	for k in 3 + extra:
		more.append({"pos": spots[k % 2], "blade": "spathion", "shield": k % 2 == 0, "name": "SPK_DEFENDER",
			"look": {"coat": [Color("7a2a24"), Color("5a6a7a"), Color("6a5a3a")][k % 3], "pants": Color("3a2a22"), "hat": "helm",
			"mustache": true, "beard": k % 2 == 1}})
	player.frozen = false
	var gn := Gunner.spawn(self, Vector3(8.4, y, 15.4), player, hud, 6.0, Color("7a2a24"), "helm")
	var r: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": specs, "max_active": 2, "skill": 0.4, "limit": 60.0},
		{"specs": more, "max_active": 2, "skill": 0.45, "allies": 2, "limit": 60.0,
		"intro": func(): await hud.say("SPK_URBAN", "D20O_U_MORE")}], "kilij")
	gunner_shots = gn.shots
	gunner_dodged = gn.dodged
	gn.stop()
	_duel_won = r["won"]
	if _duel_won:
		GameState.bump_stat("osm_breach", 1, true)
	player.frozen = true
	await hud.say("SPK_TOLGA", "D20O_T_DUEL" if _duel_won else "D20O_T_LOST")
	await hud.say("SPK_NIHAT", "D20O_N_NIGHT")


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
		Grade.finish("20o"),
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
	var expected: String = {"": "20O.1", "wide": "20O.2", "lose": "20O.1"}.get(v, "20O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("20", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	# Gece hücumu: tüfekle en az üç atış ve bir isabet, tüfekçi en az bir kez ateş etmiş; yenilgi testinde düşmüş olmalı
	ok = ok and gun_shots >= 3 and gun_hits >= 1 and gunner_shots >= 1
	if v.ends_with("lose"):
		ok = ok and player.downs >= 1 and not _duel_won
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=20o variant=%s outcome=%s hits=%d cracks=%d gun=%d/%d gunner=%d/%d duel=%s" % ["PASS" if ok else "FAIL", v, _outcome,
		hits, cracks, gun_hits, gun_shots, gunner_dodged, gunner_shots, _duel_won])
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
	# Siperlik: kapak halatlarla kalkar, top ateşlenir (yandan)
	cv.global_position = gun.position + Vector3(15.0, 6.5, 3.0)
	cv.look_at(gun.position + Vector3(0.0, 3.0, -5.5), Vector3.UP)
	await _shot_png("c20o_02_closed.png")
	await get_tree().create_timer(walls.gun_screen(true, 0.4) + 0.1).timeout
	await _shot_png("c20o_03_open.png")
	get_tree().quit()
