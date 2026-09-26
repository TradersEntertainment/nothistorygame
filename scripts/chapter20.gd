extends Node3D
## Bölüm 20 — Gedik (Tolga · 7 Mayıs 1453 gecesi, Mesoteichion). docs/SIEGE.md §3.
##
## Gündüz Urban'ın topu dış surda gedik açar; savunucular her gece fıçı, toprak ve kalasla kapatır (Barbaro,
## Kritovoulos). Tolga, Giustiniani'nin emrinde yük taşır: depodan istenen malzemeyi alır, gediğe götürür.
## Büyük top ateşlenmeden önce gözcü bağırır: tahta siperin arkasına geçmeyen devrilir, yükünü düşürür.
## Gecenin ortasında hücum: Tolga okçulara ok sandığı yetiştirir. Şafakta kapanmış gedik tespit edilir.
##   20.1 Gedik şafaktan önce kapandı · 20.2 Kapandı, Tolga koli bandıyla "sağlamlaştırdı" · 20.3 Yarım kaldı,
##   şafakta Giustiniani'nin adamları bitirdi (tarih yine aynı)
##   --autotest[=tape|late|hit]   (varsayılan: 20.1)

const NIGHT := 170.0
const ASSAULT_AT := 0.52       # gecenin bu oranında hücum
const ARCHERS := Vector3(-9.0, 0.0, 11.0)
const ARROWS := Vector3(6.2, 0.0, 0.2)

var walls: LandWalls
var player: Player
var hud: Hud
var giust: Person
var workers: Array[Person] = []
var phase := "intro"
var _outcome := ""
var _time := NIGHT
var repair := 0
var carrying := ""
var _carry_node: Node3D
var _gun_t := 20.0
var _warn := false
var _knocks := 0
var _assault_done := false
var _arrows_ok := false
var _taped := false
var _photo := ""
var cam: TespitCam
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(20)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	hud.chase_music = "tension"
	walls = LandWalls.new()
	add_child(walls)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	giust = Person.new({"face": "giustiniani", "coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero",
		"beard": true, "skin": Color("e0b08a")})
	giust.position = LandWalls.BREACH + Vector3(-2.2, 0, -3.0)
	add_child(giust)
	giust.look_target = player
	# Yük taşıyan savunucular: depo ile gedik arasında gidip gelir
	for i in 3:
		var w := Person.new({"coat": [Color("6a5040"), Color("5a6a7a"), Color("7a4a3a")][i], "pants": Color("3a3028"), "hat": "helm", "mustache": i != 1})
		w.set_meta("no_talk", true)
		add_child(w)
		w.position = LandWalls.DEPOT + Vector3(-1.0 - i, 0, 1.6)
		w.carry(["crate", "basket", "sack"][i])
		workers.append(w)
	# Ok sandıkları (hücumda okçulara) ve okçular
	for i in 3:
		Props.box(self, Vector3(0.9, 0.45, 0.5), ARROWS + Vector3(0, 0.23 + i * 0.46, 0), Color("6a4a2c"))
		for k in 5:
			Props.cyl(self, 0.012, 0.8, ARROWS + Vector3(-0.3 + k * 0.15, 0.55 + i * 0.46, 0), Color("c8b894"), Vector3(0, 0, 90), 4)
	Props.interactable(self, "pile_arrows", Vector3(1.2, 1.6, 1.0), ARROWS + Vector3(0, 0.8, 0))
	for i in 3:
		var a := Person.new({"coat": Color("7a2a24"), "pants": Color("3a2a22"), "hat": "helm", "beard": i == 1})
		a.set_meta("no_talk", true)
		a.position = ARCHERS + Vector3(-1.5 + i * 1.5, 0, 0.6)
		add_child(a)
	Props.interactable(self, "archers", Vector3(4.6, 2.4, 1.6), ARCHERS + Vector3(0, 1.2, 0.2))


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH20_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH20_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = LandWalls.SPAWN
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D20_N_01")
	await hud.say("SPK_GIUST", "D20_G_01")
	await hud.say("SPK_TOLGA", "D20_T_01")
	await hud.say("SPK_GIUST", "D20_G_02")
	await hud.say("SPK_GIUST", "D20_G_03")
	player.frozen = false
	phase = "work"
	_update_objective()
	if GameState.autotest:
		_auto()
	while phase in ["work", "assault"]:
		await get_tree().process_frame
	await _dawn()
	await _end_chapter()


func needed() -> String:
	if repair < 4:
		return "barrel"
	if repair < 6:
		return "earth"
	return "plank"


func _update_objective() -> void:
	if phase == "assault":
		hud.set_objective(tr("UI_OBJ20_ARROWS") if carrying != "arrows" else tr("UI_OBJ20_ARCHERS"),
			ARROWS + Vector3(0, 1.0, 0) if carrying != "arrows" else ARCHERS + Vector3(0, 1.6, 0))
		return
	if repair >= LandWalls.STAGES:
		hud.set_objective("")
		return
	var want := tr("UI_ITEM20_" + needed().to_upper())
	if carrying == "":
		hud.set_objective(tr("UI_OBJ20_FETCH") % [want, repair, LandWalls.STAGES], LandWalls.DEPOT + Vector3(0, 1.2, 0))
	else:
		hud.set_objective(tr("UI_OBJ20_BRING") % [tr("UI_ITEM20_" + carrying.to_upper()), repair, LandWalls.STAGES], LandWalls.BREACH + Vector3(0, 2.2, -1.2))


func _process(delta: float) -> void:
	_t += delta
	_move_workers()
	if phase != "work" and phase != "assault":
		return
	_time -= delta
	hud.set_chase(tr("UI_CH20_TIME") % _clock(), 1.0 - _time / NIGHT)
	if phase == "work":
		if not _assault_done and _time < NIGHT * (1.0 - ASSAULT_AT):
			_start_assault()
			return
		_gun_t -= delta
		if not _warn and _gun_t <= 4.0:
			_warn = true
			hud.bark("SPK_LOOKOUT", "D20_L_WARN_%d" % (randi() % 3 + 1), 3.0)
			Audio.sfx("church_bell", -10.0, 1.6)
			hud.set_qte(tr("UI_QTE20_COVER"))
		if _gun_t <= 0.0:
			_fire()
		if repair >= LandWalls.STAGES:
			phase = "done"
	if _time <= 0.0:
		_time = 0.0
		phase = "done"


## Gece saati: 21.00'dan şafağa (05.00) doğru ilerler.
func _clock() -> String:
	var h := 21.0 + (1.0 - _time / NIGHT) * 8.0
	var hh := int(h) % 24
	return "%02d.%02d" % [hh, int(fmod(h, 1.0) * 60.0)]


func _fire() -> void:
	_warn = false
	_gun_t = randf_range(24.0, 30.0)
	hud.set_qte("")
	walls.fire_flash()
	Audio.sfx("cannon", 0.0, 0.8)
	await get_tree().create_timer(1.1).timeout
	var at := LandWalls.BREACH + Vector3(randf_range(-2.5, 2.5), 2.0, 0.6)
	walls.impact(at)
	Audio.sfx("explosion_big", -4.0)
	player.shake(0.5)
	if repair > 0 and repair < LandWalls.STAGES:
		repair -= 1
		walls.set_repair(repair)
		hud.bark("SPK_GIUST", "D20_G_LOSS", 2.5)
	if _exposed():
		_knock()
	_update_objective()


## Siperin arkasında mı, depoda mı, gediğe uzak mı?
func _exposed() -> bool:
	var p := player.global_position
	if p.distance_to(LandWalls.BREACH) > 9.0 or p.distance_to(LandWalls.DEPOT) < 4.5:
		return false
	for m: Vector3 in LandWalls.MANTLETS:
		if absf(p.x - m.x) < 1.5 and p.z < m.z + 0.9 and p.z > m.z - 2.2:
			return false
	return true


func _knock() -> void:
	_knocks += 1
	player.stagger(1.2)
	player.shake(1.0)
	Audio.sfx("land_thud", 0.0)
	if carrying != "":
		_drop()
	_time -= 5.0
	hud.bark("SPK_TOLGA", "D20_T_KNOCK_%d" % mini(_knocks, 3), 3.0)


func _start_assault() -> void:
	_assault_done = true
	phase = "assault"
	_warn = false
	hud.set_qte("")
	if carrying != "":
		_drop()
	Audio.sfx("crowd_camp", -2.0)
	hud.say("SPK_GIUST", "D20_G_ASSAULT")
	_update_objective()
	var t := 0.0
	var limit := 30.0
	while not _arrows_ok and t < limit:
		await get_tree().process_frame
		t += get_process_delta_time()
		if randf() < 0.02:
			Vfx.explosion(walls, Vector3(randf_range(-12, 12), 3.0, 24.0), 0.4)
			Audio.sfx("explosion_small", -12.0)
	if not _arrows_ok:
		hud.bark("SPK_GIUST", "D20_G_ARROWS_LATE", 3.0)
		if carrying == "arrows":
			_drop()
	for i in 4:
		Vfx.explosion(walls, Vector3(randf_range(-10, 10), 2.0, 26.0), 0.6)
		Audio.sfx("explosion_small", -6.0)
		await get_tree().create_timer(0.35).timeout
	await hud.say("SPK_GIUST", "D20_G_REPELLED")
	phase = "work"
	_gun_t = 14.0
	_update_objective()


func _pick(kind: String) -> void:
	if carrying != "":
		hud.bark("SPK_TOLGA", "D20_T_FULL", 2.0)
		return
	if phase == "assault" and kind != "arrows":
		hud.bark("SPK_GIUST", "D20_G_ARROWS_FIRST", 2.5)
		return
	if phase == "work" and kind == "arrows":
		return
	carrying = kind
	_carry_node = Node3D.new()
	_carry_node.position = Vector3(0.3, -0.78, -1.05)
	_carry_node.scale = Vector3.ONE * 0.6
	player.camera.add_child(_carry_node)
	match kind:
		"barrel":
			Props.cyl(_carry_node, 0.3, 0.8, Vector3.ZERO, LandWalls.C_WOOD, Vector3(90, 0, 0), 10)
		"earth":
			Props.cyl(_carry_node, 0.26, 0.4, Vector3.ZERO, Color("9a7a48"), Vector3.ZERO, 8, 1.15)
			Props.ball(_carry_node, 0.24, Vector3(0, 0.2, 0), Color("5a4630"), Vector3(1, 0.5, 1), 6)
		"plank":
			Props.box(_carry_node, Vector3(0.24, 0.1, 2.6), Vector3(0.2, 0.1, -0.3), Color("8a6440"), Vector3(0, 12, 0))
		"arrows":
			Props.box(_carry_node, Vector3(0.8, 0.4, 0.45), Vector3.ZERO, Color("6a4a2c"))
	Props.strip_outlines(_carry_node)
	player.speed_mult = 0.75
	Audio.sfx("land_pot", -10.0, 0.8)
	_update_objective()


func _drop() -> void:
	carrying = ""
	if _carry_node:
		_carry_node.queue_free()
		_carry_node = null
	player.speed_mult = 1.0
	_update_objective()


func _deliver() -> void:
	if carrying == "" or carrying == "arrows":
		return
	if repair >= LandWalls.STAGES:
		return
	if carrying != needed():
		hud.bark("SPK_GIUST", "D20_G_WRONG_" + needed().to_upper(), 3.0)
		return
	_drop()
	repair += 1
	walls.set_repair(repair)
	Audio.sfx("land_thud", -6.0, 1.2)
	player.hand_gesture("reach")
	if repair in [4, 6, 8]:
		hud.bark("SPK_GIUST", "D20_G_STAGE_%d" % repair, 3.0)
	elif repair < LandWalls.STAGES:
		hud.bark("SPK_TOLGA", "D20_T_DROP_%d" % (repair % 3 + 1), 2.2)
	_update_objective()


func _move_workers() -> void:
	for i in workers.size():
		var w := workers[i]
		var ph := fmod(_t * 0.045 + i * 0.33, 1.0)
		var a := LandWalls.DEPOT + Vector3(-1.0 - i * 0.8, 0, 1.4)
		var b := LandWalls.BREACH + Vector3(-2.5 + i * 2.2, 0, -2.2)
		var k := smoothstep(0.0, 0.5, ph) if ph < 0.5 else 1.0 - smoothstep(0.5, 1.0, ph)
		var np := a.lerp(b, k)
		var dir := (b - a) if ph < 0.5 else (a - b)
		w.position = np
		w.rotation.y = atan2(dir.x, dir.z)


func _dawn() -> void:
	phase = "dawn"
	player.frozen = true
	hud.set_chase("", 0.0)
	hud.set_qte("")
	hud.set_prompt("")
	hud.set_objective("")
	if carrying != "":
		_drop()
	var complete := repair >= LandWalls.STAGES
	if complete:
		await hud.say("SPK_GIUST", "D20_G_DONE")
	else:
		await hud.say("SPK_GIUST", "D20_G_UNFINISHED")
	await hud.fade_to(1.0, 0.8)
	walls.make_dawn(0.01)
	repair = LandWalls.STAGES
	walls.set_repair(repair)
	for w in workers:
		w.visible = false
	player.global_position = LandWalls.BREACH + Vector3(1.5, 0.05, -7.5)
	player.face(LandWalls.BREACH + Vector3(0, 2.4, 0))
	await hud.card([[tr("UI_CH20_DAWN"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	await hud.fade_to(0.0, 1.0)
	if complete and "tape" in GameState.bag:
		var pick := await hud.choose(["UI_C20_TAPE", "UI_C20_LEAVE"], 0.0, 0 if GameState.autotest_variant == "tape" else 1)
		if pick == 0:
			_taped = true
			Audio.sfx("paper_tear", -4.0, 0.7)
			var band := Props.box(walls, Vector3(LandWalls.BREACH_W - 0.6, 0.12, 0.02), LandWalls.BREACH + Vector3(0, 2.5, -0.9), Color("c98a3a"))
			band.rotation_degrees = Vector3(0, 0, 3)
			await hud.say("SPK_TOLGA", "D20_T_TAPE")
			await hud.say("SPK_GIUST", "D20_G_TAPE")
	# Tespit karesi: şafakta kapanmış gedik
	var target := Node3D.new()
	target.position = LandWalls.BREACH + Vector3(0, 2.4, -0.6)
	walls.add_child(target)
	hud.set_objective(tr("UI_OBJ20_PHOTO"), target.global_position)
	player.frozen = false
	cam = TespitCam.new(player, hud, target, "siege20")
	hud.add_child(cam)
	cam.max_dist = 30.0
	cam.cone_deg = 14.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_GIUST", "D20_G_END")
	await hud.say("SPK_TOLGA", "D20_T_END")
	await hud.say("SPK_NIHAT", "D20_N_END")
	_outcome = ("20.2" if _taped else "20.1") if complete else "20.3"
	GameState.flags["breach_night_taped"] = _taped
	Siege.record(20, _photo, "SIEGE_NOTE_20_%s" % _outcome.split(".")[1])


func _on_focus(id: String) -> void:
	match id:
		"pile_barrel", "pile_earth", "pile_plank":
			hud.set_prompt(tr("UI_PROMPT20_TAKE") % tr("UI_ITEM20_" + id.trim_prefix("pile_").to_upper()))
		"pile_arrows":
			hud.set_prompt(tr("UI_PROMPT20_TAKE") % tr("UI_ITEM20_ARROWS") if phase == "assault" else "")
		"breach":
			hud.set_prompt(tr("UI_PROMPT20_PUT") if carrying != "" and carrying != "arrows" else "")
		"archers":
			hud.set_prompt(tr("UI_PROMPT20_GIVE") if carrying == "arrows" else "")
		_:
			hud.set_prompt("")


func _on_interact(id: String) -> void:
	if phase != "work" and phase != "assault":
		return
	match id:
		"pile_barrel", "pile_earth", "pile_plank", "pile_arrows":
			_pick(id.trim_prefix("pile_"))
		"breach":
			_deliver()
		"archers":
			if carrying == "arrows":
				_drop()
				_arrows_ok = true
				hud.bark("SPK_TOLGA", "D20_T_ARROWS", 2.5)


func _auto() -> void:
	await get_tree().create_timer(0.3).timeout
	if GameState.autotest_variant == "hit":
		player.global_position = LandWalls.BREACH + Vector3(0, 0.05, -3.0)
		_gun_t = 0.05
		await get_tree().create_timer(2.0).timeout
	var loads := 5 if GameState.autotest_variant == "late" else LandWalls.STAGES
	while repair < loads and phase in ["work", "assault"]:
		if phase == "assault":
			if not _arrows_ok and carrying == "":
				_pick("arrows")
				_on_interact("archers")
			await get_tree().process_frame
			continue
		_pick(needed())
		_deliver()
		_gun_t = 30.0
		# Hücum da denensin: altıncı yükten sonra gece yarısına sar
		if repair == 6 and not _assault_done and GameState.autotest_variant != "late":
			_time = NIGHT * (1.0 - ASSAULT_AT) - 0.5
		await get_tree().create_timer(0.2).timeout
	if GameState.autotest_variant == "late":
		_time = 0.05


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
			if nxt != "":
				GameState.change_scene(nxt)
			else:
				hud.set_fade(1.0)
				await hud.card([[tr("UI_SIEGE_TBC"), 30, Color("f2e6c9")], [tr("UI_SIEGE_TBC_SUB"), 18, Color(1, 1, 1, 0.7)]], 3.5)
				GameState.change_scene("res://scenes/main.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW20_TITLE")
	c.nodes = [
		{"id": "carry", "key": "FLOW20_CARRY", "pos": Vector2(0.5, 0.14)},
		{"id": "arrows", "key": "FLOW20_ARROWS", "pos": Vector2(0.3, 0.32)},
		{"id": "noarrows", "key": "FLOW20_NOARROWS", "pos": Vector2(0.7, 0.32)},
		{"id": "20.1", "key": "FLOW_20_1", "pos": Vector2(0.2, 0.58), "outcome": true},
		{"id": "20.2", "key": "FLOW_20_2", "pos": Vector2(0.5, 0.58), "outcome": true},
		{"id": "20.3", "key": "FLOW_20_3", "pos": Vector2(0.8, 0.58), "outcome": true},
	]
	c.edges = [["carry", "arrows"], ["carry", "noarrows"]]
	for a in ["arrows", "noarrows"]:
		for o in ["20.1", "20.2", "20.3"]:
			c.edges.append([a, o])
	c.taken["carry"] = true
	c.taken["arrows" if _arrows_ok else "noarrows"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH20_STATS") % [_knocks, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "20.1", "tape": "20.2", "late": "20.3", "hit": "20.1"}.get(v, "20.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("20", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	if v == "hit":
		ok = ok and _knocks >= 1
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s, knocks=%d)" % [expected, _outcome, not page.is_empty(), _knocks])
	print("AUTOTEST %s chapter=20 variant=%s outcome=%s repair=%d knocks=%d arrows=%s" % ["PASS" if ok else "FAIL", v, _outcome,
		repair, _knocks, _arrows_ok])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.show_remote(false)
	phase = "work"
	repair = 5
	walls.set_repair(repair)
	player.global_position = LandWalls.DEPOT + Vector3(-3.0, 0.05, 4.0)
	await get_tree().create_timer(0.6).timeout
	player.face(LandWalls.BREACH + Vector3(0, 2.0, 0))
	_pick("earth")
	await _shot("c20_01_carry.png")
	_warn = true
	hud.set_qte(tr("UI_QTE20_COVER"))
	player.global_position = LandWalls.MANTLETS[0] + Vector3(0.3, 0.05, -1.6)
	player.face(LandWalls.CANNON)
	walls.fire_flash()
	await _shot("c20_02_cover.png")
	hud.set_qte("")
	var top := Camera3D.new()
	add_child(top)
	top.global_position = Vector3(18, 16, -8)
	top.look_at(LandWalls.BREACH + Vector3(-2, 0, 0), Vector3.UP)
	top.make_current()
	await _shot("c20_03_overview.png")
	walls.make_dawn(0.01)
	repair = LandWalls.STAGES
	walls.set_repair(repair)
	player.camera.make_current()
	_drop()
	player.global_position = LandWalls.BREACH + Vector3(1.5, 0.05, -7.5)
	player.face(LandWalls.BREACH + Vector3(0, 2.4, 0))
	await get_tree().create_timer(0.3).timeout
	await _shot("c20_04_dawn.png")
	hud.visible = false
	walls.set_repair(7)
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = LandWalls.BREACH + Vector3(4.5, 1.4, -6.5)
	cv.look_at(LandWalls.BREACH + Vector3(-1.0, 2.2, 0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	giust.global_position = LandWalls.BREACH + Vector3(-1.5, 0, -3.2)
	await _shot("c20_cover.png")
	get_tree().quit()
