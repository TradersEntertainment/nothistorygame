extends Node3D
## Bölüm 30 (Bizans tarafı) — Blakherna (Tolga · 12 Mayıs 1453, gece yarısı, saray önündeki surun yürüyüş yolu).
##
## Osmanlılar saray önündeki tek sura gece hücumu yapar. Tolga sur yolundadır:
##   1. ovadan merdiven taşıyanlara tüfek (GunRange runners): vurulan merdiven sura varmaz
##   2. sura dayanan merdivenleri it (merdivenin başında E basılı); tırmanan tepeye varırsa sur yoluna çıkar
##   3. sur yoluna çıkanlarla kılıç (StoryDuel; en az bir kişi, kuleden)
##   4. İmparator atını bırakıp sur yoluna çıkar, meşalelerin arasında. Tespit karesi.
##   30.1 Sur yolu tutuldu (en çok bir kişi çıktı, dövüş kazanıldı) · 30.2 Sur yoluna çıkıldı, güçlükle atıldılar
##   --autotest[=lose]   (varsayılan: 30.1)

const LADDERS := [-12.0, -4.0, 6.0, 14.0]
const CLIMB_TIME := 11.0
const PUSH_NEED := 0.8
const TILT := 16.0
const WALK := Blachernae.WALK_Y

var walls: Blachernae
var player: Player
var hud: Hud
var cam: TespitCam
var emperor: Person
var phase := "intro"
var _outcome := ""
var gun_shots := 0
var gun_hits := 0
var pushed := 0
var boarders := 0
var _duel_won := true
var _ladders: Array = []          # {"node": Ladder, "climber": Soldier, "t": float, "x": float, "state": "up"|"gone"}
var _focus := ""
var _hold := 0.0
var _photo := ""
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(30)
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	walls = Blachernae.new()
	add_child(walls)
	walls.build_guards([])
	walls.night_assault(LADDERS + [6.0, -6.0], false)
	emperor = Person.new({"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "stemma", "face": "emperor", "beard": true,
		"mustache": true, "hair": Color("6a6a6a"), "robe": Color("5a2a6a")})
	emperor.set_meta("spk", "SPK_EMPEROR")
	emperor.position = Vector3(-6.0, WALK, Blachernae.WALL_Z0 + 1.2)
	add_child(emperor)
	emperor.visible = false
	emperor.look_target = player
	# Sur yolundaki savunucular (yüz ve meşale)
	for k in 5:
		var d := Soldier.new([Color("7a2a24"), Color("5a6a7a"), Color("6a5a3a"), Color("8a8e96"), Color("5a2a6a")][k], "stand", "helm")
		d.set_meta("no_talk", true)
		# Oyuncunun (x 1) ve merdivenlerin (x −12, −4, 6, 14) önünde durmasınlar
		var dx: float = [-20.0, -8.0, 10.0, 18.0, 25.0][k]
		d.position = Vector3(dx, WALK, Blachernae.WALL_Z1 - 1.2)
		d.rotation.y = 0.0
		add_child(d)
		d.equip(["spear", "sword_shield", "spear", "sword_shield", "spear"][k])
	player.focus_changed.connect(_on_focus)
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH30_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH30_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	Audio.ambience("amb_wall_night")
	Audio.intensity(2, "walls_night")
	player.global_position = Vector3(1.0, WALK + 0.05, Blachernae.WALL_Z0 + 2.2)
	player.face(Vector3(1.0, 2.0, 30.0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D30_N_01")
	await hud.say("SPK_DEFENDER", "D30_D_01")
	await hud.say("SPK_TOLGA", "D30_T_01")
	await _gun()
	await _ladders_phase()
	await _fight()
	await _emperor()
	await _end_chapter()


## 1. Ovadan merdiven taşıyanlar koşar; Tolga sur yolundan tüfekle (vurulan bölük merdivenini bırakır)
func _gun() -> void:
	phase = "gun"
	await hud.say("SPK_DEFENDER", "D30_D_GUN")
	var runners: Array = []
	for i in 4:
		var x: float = LADDERS[i]
		runners.append({"coat": [Color("b3262d"), Color("6a4a3a"), Color("2f5fa8"), Color("e8e0d0")][i], "hat": ["azap", "bork", "turban", "azap"][i],
			"path": [Vector3(x + 6.0, 0, 46.0), Vector3(x + 2.0, 0, 26.0), Vector3(x, 0, Blachernae.WALL_Z1 + 3.0)], "delay": i * 1.6})
	var res: Dictionary = await GunRange.run(self, hud, player, {"runners": runners, "shots": 4, "limit": 26.0, "speed": 2.4,
		"objective": tr("UI_OBJ30_GUN") % 4, "look": Vector3(0, 1.0, 30.0)})
	gun_shots = res["shots"]
	gun_hits = res["hits"]
	player.frozen = true
	await hud.say("SPK_TOLGA", "D20_T_GUN_GOOD" if gun_hits >= 2 else "D30_T_GUN_BAD")


## 2. Merdivenler: vurulmayan bölüklerin merdivenleri sura dayanır. Başına gidip E basılı tut: merdiven devrilir.
func _ladders_phase() -> void:
	phase = "ladders"
	var n := maxi(2, 4 - gun_hits)
	await hud.say("SPK_DEFENDER", "D30_D_LADDERS")
	for i in n:
		_spawn_ladder(LADDERS[(i * 3) % 4] if i < 4 else LADDERS[i % 4], i * 2.5)
	player.frozen = false
	_update_objective()
	var bot := 0.0
	while _ladders.any(func(l): return l["state"] == "up"):
		await get_tree().process_frame
		var dt := get_process_delta_time()
		for l: Dictionary in _ladders:
			if l["state"] != "up":
				continue
			if float(l["t"]) < 0.0:
				l["t"] = float(l["t"]) + dt
				if float(l["t"]) >= 0.0 and not (l["node"] as Node3D).visible:
					(l["node"] as Node3D).visible = true
					(l["climber"] as Node3D).visible = true
					Audio.sfx("land_thud", -6.0, 0.8)
				continue
			l["t"] = float(l["t"]) + dt
			var lad: Ladder = l["node"]
			var k := clampf(float(l["t"]) / CLIMB_TIME, 0.0, 1.0)
			(l["climber"] as Node3D).global_position = lad.point_at(lad.height * k * 0.92) + lad.front_dir() * 0.35
			var cs: Soldier = l["climber"]
			if cs.rig:   # basamak basamak: el ve karşı ayak dönüşümlü (assault.gd ile aynı)
				cs.rig.activity = "climb_a" if int(lad.height * k * 0.92 / 0.45) % 2 == 0 else "climb_b"
			if k >= 1.0:
				_board(l)
		if GameState.autotest and GameState.autotest_variant != "lose":
			bot -= dt
			var up: Array = _ladders.filter(func(l): return l["state"] == "up" and float(l["t"]) >= 1.0)
			if not up.is_empty():
				var l: Dictionary = up[0]
				player.global_position = Vector3(float(l["x"]), WALK + 0.05, Blachernae.WALL_Z1 - 1.0)
				_hold += dt
				hud.set_chase(tr("UI_CH30_PUSH"), _hold / PUSH_NEED)
				if _hold >= PUSH_NEED:
					_push(l)
		elif not GameState.autotest:
			var near: Dictionary = {}
			for l: Dictionary in _ladders:
				if l["state"] == "up" and float(l["t"]) >= 0.0 and Vector2(player.global_position.x - float(l["x"]), player.global_position.z - (Blachernae.WALL_Z1 - 1.0)).length() < 1.8:
					near = l
			if not near.is_empty() and Input.is_action_pressed("interact"):
				_hold += dt
				hud.set_chase(tr("UI_CH30_PUSH"), _hold / PUSH_NEED)
				if _hold >= PUSH_NEED:
					_push(near)
			elif _hold > 0.0:
				_hold = 0.0
				hud.set_chase("", 0.0)
			hud.set_prompt(tr("UI_PROMPT30_PUSH") if not near.is_empty() else "")
	player.frozen = true
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	hud.set_objective("")


func _spawn_ladder(x: float, delay: float) -> void:
	var lh := WALK + 0.6
	var lad := Ladder.new(lh, TILT, Color("6a4a2c"))
	lad.position = Vector3(x, 0.0, Blachernae.WALL_Z1 + lh * sin(deg_to_rad(TILT)) + 0.12)
	add_child(lad)
	lad.visible = false
	var c := Soldier.new([Color("b3262d"), Color("6a4a3a"), Color("2f5fa8")][_ladders.size() % 3], "stand", "azap")
	c.set_meta("no_talk", true)
	c.set_meta("climber", true)
	c.rotation.y = PI
	add_child(c)
	if c.rig:
		c.rig.activity = "climb_a"
	c.visible = false
	_ladders.append({"node": lad, "climber": c, "t": -delay, "x": x, "state": "up"})


func _push(l: Dictionary) -> void:
	_hold = 0.0
	hud.set_chase("", 0.0)
	l["state"] = "gone"
	pushed += 1
	Audio.sfx("whoosh_fly", -4.0, 0.6)
	var lad: Ladder = l["node"]
	var c: Soldier = l["climber"]
	c.set_meta("no_turn", true)   # +z'ye savrulurken yaw 0'a dönmesin: sırtüstü geriye düşer
	c.rotation.y = PI
	if c.rig:
		c.rig.activity = "fall"
	var tw := create_tween().set_parallel()
	tw.tween_property(c, "rotation:x", -1.4, 1.0).set_ease(Tween.EASE_IN)
	tw.tween_property(lad, "rotation:x", deg_to_rad(70.0), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(c, "global_position", c.global_position + Vector3(0, -c.global_position.y, 6.0), 1.0).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(func():
		Audio.sfx("land_thud", -2.0, 0.7)
		Vfx.dust(self, Vector3(float(l["x"]), 0.2, Blachernae.WALL_Z1 + 8.0), 1.0)
		lad.queue_free()
		c.visible = false)
	hud.bark("SPK_TOLGA", "D30_T_PUSH", 2.0)
	_update_objective()


func _board(l: Dictionary) -> void:
	l["state"] = "gone"
	boarders += 1
	(l["climber"] as Node3D).visible = false
	hud.bark("SPK_DEFENDER", "D30_D_BOARD", 2.5)
	Audio.stinger("warn", -8.0)
	_update_objective()


func _update_objective() -> void:
	if phase != "ladders":
		return
	var left := _ladders.filter(func(l): return l["state"] == "up").size()
	var look: Variant = null
	for l: Dictionary in _ladders:
		if l["state"] == "up" and float(l["t"]) >= 0.0:
			look = Vector3(float(l["x"]), WALK + 1.0, Blachernae.WALL_Z1 - 0.6)
			break
	hud.set_objective(tr("UI_OBJ30_LADDERS") % left, look)


func _on_focus(id: String) -> void:
	_focus = id


## 3. Sur yoluna çıkanlar (en az biri kuleden iner)
func _fight() -> void:
	phase = "duel"
	await hud.say("SPK_DEFENDER", "D30_D_DUEL")
	var specs := []
	var n := clampi(1 + boarders, 1, 3)
	var zc := (Blachernae.WALL_Z0 + Blachernae.WALL_Z1) * 0.5
	for k in n:
		specs.append({"pos": Vector3(player.global_position.x + 3.2 + k * 1.2, WALK, zc + (k % 2) * 0.6 - 0.3), "blade": "kilij",
			"shield": k % 2 == 0, "name": "SPK_SOLDIER", "look": {"coat": [Color("b3262d"), Color("6a5040"), Color("2f5fa8")][k],
			"pants": Color("e8e0d0"), "hat": ["azap", "bork", "turban"][k], "mustache": true, "beard": k == 1}})
	player.frozen = false
	var r: Dictionary = await StoryDuel.fight(self, hud, player, specs, "spathion", 0.42)
	_duel_won = r["won"]
	player.frozen = true
	await hud.say("SPK_TOLGA", "D30_T_DUEL" if _duel_won else "D30_T_LOST")


## 4. İmparator sur yoluna çıkar (merdivenden), meşalelerin arasında. Tespit karesi.
func _emperor() -> void:
	phase = "emperor"
	emperor.visible = true
	emperor.global_position = Vector3(player.global_position.x - 6.0, WALK, Blachernae.WALL_Z0 + 1.6)
	player.face(emperor.global_position + Vector3(0, 1.6, 0))
	var target := Node3D.new()
	emperor.add_child(target)
	target.position = Vector3(0, 1.6, 0)
	await hud.say("SPK_DEFENDER", "D30_D_EMPEROR")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ30_PHOTO"), emperor.global_position + Vector3(0, 2.0, 0))
	cam = TespitCam.new(player, hud, target, "siege30")
	hud.add_child(cam)
	cam.max_dist = 30.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 30.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_EMPEROR", "D30_E_01")
	await hud.say("SPK_TOLGA", "D30_T_EMPEROR")
	await hud.say("SPK_EMPEROR", "D30_E_02")
	await hud.say("SPK_NIHAT", "D30_N_END")
	_outcome = "30.1" if boarders <= 1 and _duel_won else "30.2"
	Siege.record(30, _photo, "SIEGE_NOTE_30_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(30, _outcome)
	await Siege.show_page(hud, 30)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(30)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW30_TITLE")
	c.nodes = [
		{"id": "walk", "key": "FLOW30_WALK", "pos": Vector2(0.5, 0.12)},
		{"id": "30.1", "key": "FLOW_30_1", "pos": Vector2(0.3, 0.34), "outcome": true},
		{"id": "30.2", "key": "FLOW_30_2", "pos": Vector2(0.7, 0.34), "outcome": true},
		{"id": "emperor", "key": "FLOW30_EMPEROR", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["walk", "30.1"], ["walk", "30.2"], ["30.1", "emperor"], ["30.2", "emperor"]]
	for k in ["walk", _outcome, "emperor"]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH30_STATS") % [gun_hits, gun_shots, pushed, boarders, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	c.footer_lines.insert(0, Grade.finish("30"))
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "30.1", "lose": "30.2"}.get(v, "30.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("30", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and gun_shots >= 3
	if v == "lose":
		ok = ok and boarders >= 2 and not _duel_won
	else:
		ok = ok and pushed >= 2 and boarders == 0 and _duel_won
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s)" % [expected, _outcome, not page.is_empty(), cam != null and cam.done])
	print("AUTOTEST %s chapter=30 variant=%s outcome=%s gun=%d/%d pushed=%d boarders=%d duel=%s" % ["PASS" if ok else "FAIL", v, _outcome,
		gun_hits, gun_shots, pushed, boarders, _duel_won])
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
	_spawn_ladder(6.0, 0.0)
	(_ladders[0]["node"] as Node3D).visible = true
	(_ladders[0]["climber"] as Node3D).visible = true
	var lad: Ladder = _ladders[0]["node"]
	(_ladders[0]["climber"] as Node3D).global_position = lad.point_at(lad.height * 0.7) + lad.front_dir() * 0.35
	emperor.visible = true
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(-4.0, WALK + 2.6, Blachernae.WALL_Z0 + 1.0)
	cv.look_at(Vector3(6.0, WALK - 2.0, Blachernae.WALL_Z1 + 2.0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await get_tree().create_timer(0.6).timeout
	await _shot_png("c30_cover.png")
	get_tree().quit()
