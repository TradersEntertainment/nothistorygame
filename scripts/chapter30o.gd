extends Node3D
## Bölüm 30 (Osmanlı tarafı) — Blakherna (Tolga · 12 Mayıs 1453, gece yarısı, saray önündeki sur).
##
## O gece Osmanlılar Blakherna sarayı önündeki tek sura büyük bir gece hücumu yaptı; İmparator bizzat geldi ve hücum
## püskürtüldü. Tolga Zağanos Paşa'nın askerleriyle:
##   1. merdiveni ekipçe sura taşı (karanlıkta, surdan ok yağar)
##   2. merdiveni daya, tırman: taş düşerken dur, sonra çık (26o'daki merdiven)
##   3. sur yolunda dövüş (WaveRunner, iki dalga; kuleden bir tüfekçi)
##   4. geri çekilme borusu: sur yolundan inilir, sur dibinde yaralı bir azap; sırtına al, ateşlerin hizasına getir
##   Tespit: sur yolunda meşalelerin arasında İmparator.
##   30O.1 Sur yolunda tutunuldu, düzenli çekilindi · 30O.2 Sur yolundan atıldın, yaralıyı yine getirdin
##   --autotest[=lose]   (varsayılan: 30O.1)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const CLIMB_X := 10.0
const TILT := 16.0
const START := Vector3(10.0, 0.0, 40.0)
const PLANT := Vector3(10.0, 0.0, 8.0)
const SAFE_Z := 34.0

var walls: Blachernae
var player: Player
var hud: Hud
var cam: TespitCam
var ladder: Ladder
var carriers: Array[Soldier] = []
var zaganos: Person
var emperor: Person
var wounded: Soldier
var phase := "intro"
var _outcome := ""
var stones := 0
var stone_hits := 0
var _stone_falling := false
var _duel_won := true
var climbed := false
var oil: OilHazard
var carried := false
var gunner_shots := 0
var gunner_dodged := 0
var _carry: Node3D
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
	walls.build_guards([CLIMB_X])
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	var lh := Blachernae.WALK_Y + 0.6
	ladder = Ladder.new(lh, TILT, Color("6a4a2c"))
	ladder.position = Vector3(CLIMB_X, 0.0, Blachernae.WALL_Z1 + lh * sin(deg_to_rad(TILT)) + 0.12)
	add_child(ladder)
	ladder.visible = false
	zaganos = Person.new({"coat": Color("2e6a3a"), "pants": Color("e8e0d0"), "hat": "turban", "beard": true, "mustache": true,
		"robe": Color("2e6a3a"), "skin": Color("d8a882")})
	zaganos.set_meta("spk", "SPK_ZAGANOS")
	zaganos.position = START + Vector3(-3.0, Blachernae.slope_y(START.z + 2.0), 2.0)
	zaganos.rotation.y = PI
	add_child(zaganos)
	zaganos.look_target = player
	# Merdiveni taşıyan bölük: oyuncunun önünde ve arkasında, merdiven omuzlarında
	for k in 3:
		var s := Soldier.new([Color("b3262d"), Color("6a4a3a"), Color("2f5fa8")][k], "stand", ["azap", "bork", "turban"][k])
		s.set_meta("no_talk", true)
		s.set_meta("climber", true)
		add_child(s)
		carriers.append(s)
	# Hücum kalabalığı: sura koşanlar, sur dibinde düşenler
	var bx := BattleExtras.new()
	bx.side = "osm"
	add_child(bx)
	bx.hit_every = 3.5
	bx.populate(Vector3(-40.0, 0, 16.0), Vector3(40.0, 0, 16.0), 8.0, 10, 6, 0, 3005)
	emperor = Person.new({"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "stemma", "face": "emperor", "beard": true,
		"mustache": true, "hair": Color("6a6a6a"), "robe": Color("5a2a6a")})
	emperor.set_meta("spk", "SPK_EMPEROR")
	emperor.set_meta("climber", true)
	emperor.position = Vector3(-3.0, Blachernae.WALK_Y, Blachernae.WALL_Z0 + 2.4)
	emperor.rotation.y = 0.0
	add_child(emperor)
	emperor.visible = false
	wounded = Soldier.new(Color("b3262d"), "stand", "azap")
	wounded.set_meta("no_talk", true)
	wounded.set_meta("climber", true)
	wounded.position = Vector3(CLIMB_X + 2.4, 0.1, Blachernae.WALL_Z1 + 1.6)
	wounded.rotation = Vector3(deg_to_rad(-80), 0.6, 0)
	add_child(wounded)
	wounded.visible = false
	Props.interactable(wounded, "wounded", Vector3(1.6, 1.0, 1.6), Vector3(0, 0.3, 0))
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(func(id: String): hud.set_prompt(tr("UI_PROMPT30O_LIFT") if id == "wounded" and phase == "retreat" and not carried else ""))


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH30O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH30O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	Audio.ambience("amb_wall_night")
	Audio.intensity(2, "walls_night")
	player.global_position = START + Vector3(0, Blachernae.slope_y(START.z) + 0.05, 0)
	player.face(zaganos.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D30O_N_01")
	await hud.say("SPK_ZAGANOS", "D30O_Z_01")
	await hud.say("SPK_TOLGA", "D30O_T_01")
	await _carry_ladder()
	await _climb()
	await _wall_fight()
	await _retreat()
	await _end_chapter()


## 1. Merdiven taşıma: ekip oyuncuyla yürür; merdiven omuzlarda. Sura vardığında E ile dayanır.
func _carry_ladder() -> void:
	phase = "carry"
	_carry = Node3D.new()
	_carry.position = Vector3(0.5, -0.35, -1.6)
	player.camera.add_child(_carry)
	for sx: float in [-0.3, 0.3]:
		Props.cyl(_carry, 0.05, 6.0, Vector3(sx, 0, -2.0), Color("6a4a2c"), Vector3(90, 0, 0), 5)
	Props.strip_outlines(_carry)
	player.speed_mult = 0.7
	player.frozen = false
	hud.set_objective(tr("UI_OBJ30O_CARRY"), PLANT + Vector3(0, 1.0, 0))
	var arrows := 0.0
	while Vector2(player.global_position.x - PLANT.x, player.global_position.z - PLANT.z).length() > 2.2:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		if GameState.autotest:
			var to := PLANT - player.global_position
			to.y = 0.0
			player.global_position += to.normalized() * minf(to.length(), 6.0 * dt)
			player.global_position.y = Blachernae.slope_y(player.global_position.z) + 0.05
		# Taşıyanlar oyuncunun önünde ve arkasında
		var fwd := -player.global_transform.basis.z
		fwd.y = 0.0
		fwd = fwd.normalized()
		for k in carriers.size():
			var along: float = [2.4, -2.2, 4.6][k]
			var off: Vector3 = fwd * along + fwd.cross(Vector3.UP) * 0.5
			var p: Vector3 = player.global_position + off
			p.y = Blachernae.slope_y(p.z)
			carriers[k].global_position = p
			carriers[k].look_at(p + fwd, Vector3.UP)
			carriers[k].rotate_object_local(Vector3.UP, PI)
		arrows -= dt
		if arrows <= 0.0:
			arrows = randf_range(2.0, 3.4)
			var at := player.global_position + Vector3(randf_range(-6.0, 6.0), 0, randf_range(-4.0, 4.0))
			at.y = Blachernae.slope_y(at.z)
			Vfx.dust(self, at, 0.3)
			Audio.sfx("whoosh_fly", -14.0, 1.6)
	player.frozen = true
	hud.set_objective("")
	_carry.queue_free()
	player.speed_mult = 1.0
	await hud.say("SPK_ZAGANOS", "D30O_Z_PLANT")
	ladder.visible = true
	Audio.sfx("land_thud", -2.0, 0.8)
	for c in carriers:
		c.visible = false


## 2. Tırmanış: yukarıdan taş (merdivende oyuncunun 1,1 m üstüne iner)
func _climb() -> void:
	phase = "climb"
	player.global_position = ladder.global_position + Vector3(0, 0.05, 1.0)
	player.face(ladder.point_at(2.5))
	await hud.say("SPK_TOLGA", "D30O_T_CLIMB")
	hud.set_objective(tr("UI_OBJ30O_CLIMB"), ladder.point_at(ladder.height))
	player.frozen = false
	# Merdivenin yanındaki kazan: yarı yolda kaynar yağ
	var fight := WallFight.new()
	add_child(fight)
	var cd := fight.add_cauldron(Vector3(CLIMB_X - 6.0, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.9), 3012)
	oil = OilHazard.make(self, fight, cd, ladder, player, hud)
	var hz := 1.0
	var t := 0.0
	while not (player.ladder == null and player.global_position.y > Blachernae.WALK_Y - 0.3 and player.global_position.z < Blachernae.WALL_Z1):
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		if player.ladder == ladder and not _stone_falling and player._ladder_t > ladder.height * 0.4:
			oil.trigger()
		if player.ladder == ladder and not oil.active:
			hz -= dt
			if hz <= 0.0:
				hz = randf_range(1.4, 2.0)
				_drop_stone()
		if GameState.autotest:
			if _stone_falling or oil.active:
				Input.action_release("move_forward")
			else:
				Input.action_press("move_forward")
			player.face(ladder.point_at(clampf(player._ladder_t + 2.0, 0.0, ladder.height)))
			if t > 40.0:
				player.global_position = ladder.top_exit()
	if GameState.autotest:
		Input.action_release("move_forward")
	hud.set_qte("")
	hud.set_objective("")
	player.frozen = true
	climbed = true


func _drop_stone() -> void:
	var l := ladder
	var t_h: float = player._ladder_t + 1.1
	if t_h > l.height - 0.3 or stones >= 4:
		return
	stones += 1
	_stone_falling = true
	hud.set_qte(tr("UI_QTE26O_STONE"))
	var top := l.point_at(l.height) + l.front_dir() * 0.5 + Vector3(0, 1.2, 0)
	var at := l.point_at(t_h) + l.front_dir() * 0.4
	var stone := Props.ball(self, 0.24, top, Color("8a8478"), Vector3(1.0, 0.8, 1.1), 8)
	Audio.sfx("whoosh_fly", -6.0, 0.7)
	var tw := stone.create_tween()
	tw.tween_property(stone, "global_position", at, 0.8).set_ease(Tween.EASE_IN)
	await tw.finished
	if is_instance_valid(stone) and player.ladder == l and absf(player._ladder_t - t_h) < 0.75:
		stone_hits += 1
		player.hurt(30.0, top)
		Audio.sfx("land_thud", -2.0, 1.1)
	_stone_falling = false
	hud.set_qte("")
	if is_instance_valid(stone):
		var tw2 := stone.create_tween()
		tw2.tween_property(stone, "global_position", l.global_position + l.front_dir() * 1.4 + Vector3(0, 0.2, 0), 0.5).set_ease(Tween.EASE_IN)
		tw2.tween_callback(stone.queue_free)


## 3. Sur yolu: iki dalga, kuleden tüfekçi. Sonra İmparator meşalelerle gelir (tespit karesi).
func _wall_fight() -> void:
	phase = "fight"
	var y := Blachernae.WALK_Y
	var zc := (Blachernae.WALL_Z0 + Blachernae.WALL_Z1) * 0.5
	var east := [Vector3(CLIMB_X + 3.6, y, zc), Vector3(CLIMB_X + 2.4, y, zc - 0.6)]
	var west := [Vector3(CLIMB_X - 3.6, y, zc), Vector3(CLIMB_X - 2.4, y, zc + 0.4)]
	var specs := []
	for k in 2:
		specs.append({"pos": east[k], "blade": "spathion", "shield": true, "name": "SPK_DEFENDER",
			"look": {"coat": [Color("7a2a24"), Color("5a6a7a")][k], "pants": Color("3a2a22"), "hat": "helm", "mustache": true, "beard": k == 0}})
	var more := []
	for k in 3:
		more.append({"pos": west[k % 2], "blade": "spathion", "shield": k % 2 == 0, "name": "SPK_DEFENDER",
			"look": {"coat": [Color("5a2a6a"), Color("7a2a24"), Color("6a5a3a")][k], "pants": Color("3a2a22"), "hat": "helm",
			"mustache": true, "beard": k == 1}})
	player.face(east[0] + Vector3(0, 1.5, 0))
	await hud.say("SPK_TOLGA", "D30O_T_WALL")
	player.frozen = false
	var gn := Gunner.spawn(self, Vector3(20.0 - 4.4, y + 5.0, Blachernae.WALL_Z1 - 1.0), player, hud, 6.0, Color("5a2a6a"), "helm")
	var r: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": specs, "max_active": 2, "skill": 0.45, "limit": 60.0},
		{"specs": more, "max_active": 2, "skill": 0.48, "limit": 60.0,
		"intro": func(): await hud.say("SPK_DEFENDER", "D30O_D_EMPEROR")}], "kilij")
	gunner_shots = gn.shots
	gunner_dodged = gn.dodged
	gn.stop()
	_duel_won = r["won"]
	player.frozen = true
	await hud.say("SPK_TOLGA", "D30O_T_DUEL" if _duel_won else "D30O_T_LOST")
	# İmparator sur yolunda, meşalelerin arasında
	emperor.visible = true
	player.face(emperor.global_position + Vector3(0, 1.6, 0))
	var target := Node3D.new()
	emperor.add_child(target)
	target.position = Vector3(0, 1.6, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ30O_PHOTO"), emperor.global_position + Vector3(0, 2.0, 0))
	cam = TespitCam.new(player, hud, target, "siege30o")
	hud.add_child(cam)
	cam.max_dist = 40.0
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
	await hud.say("SPK_EMPEROR", "D30O_E_01")
	await hud.say("SPK_TOLGA", "D30O_T_EMPEROR")


## 4. Geri çekilme: boru çalar; sur dibinde yaralı bir azap. Sırtına al, ateşlerin hizasına getir.
func _retreat() -> void:
	phase = "retreat"
	Audio.sfx("drum_boom", -2.0, 0.7)
	Audio.stinger("warn", -6.0)
	await hud.say("SPK_ZAGANOS", "D30O_Z_RETREAT")
	await hud.fade_to(1.0, 0.5)
	emperor.visible = false
	player.global_position = Vector3(CLIMB_X - 1.6, Blachernae.slope_y(Blachernae.WALL_Z1 + 2.4) + 0.05, Blachernae.WALL_Z1 + 2.4)
	wounded.visible = true
	player.face(wounded.global_position + Vector3(0, 0.3, 0))
	await hud.fade_to(0.0, 0.5)
	await hud.say("SPK_SOLDIER", "D30O_S_WOUNDED")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ30O_WOUNDED"), wounded.global_position + Vector3(0, 1.0, 0))
	while not carried:
		await get_tree().process_frame
		if GameState.autotest:
			_on_interact("wounded")
	hud.set_objective(tr("UI_OBJ30O_BACK"), Vector3(CLIMB_X, 1.0, SAFE_Z))
	while player.global_position.z < SAFE_Z:
		await get_tree().process_frame
		if GameState.autotest:
			player.global_position += Vector3(0, 0, 5.0 * get_process_delta_time())
			player.global_position.y = Blachernae.slope_y(player.global_position.z) + 0.05
	player.frozen = true
	hud.set_objective("")
	if is_instance_valid(_carry):
		_carry.queue_free()
	player.speed_mult = 1.0
	await hud.say("SPK_SOLDIER", "D30O_S_THANKS")
	await hud.say("SPK_ZAGANOS", "D30O_Z_END")
	await hud.say("SPK_NIHAT", "D30O_N_END")
	_outcome = "30O.1" if _duel_won else "30O.2"
	if _duel_won:
		GameState.bump_stat("blachernae_held", 1, true)
	Siege.record(30, _photo, "SIEGE_NOTE_30O_%s" % _outcome.split(".")[1])


func _on_interact(id: String) -> void:
	if id == "wounded" and phase == "retreat" and not carried:
		carried = true
		wounded.visible = false
		hud.set_prompt("")
		_carry = Node3D.new()
		_carry.position = Vector3(0.0, -0.5, 0.25)
		player.camera.add_child(_carry)
		Props.box(_carry, Vector3(0.5, 0.3, 0.7), Vector3(0.45, 0.1, 0), Color("b3262d"))
		Props.strip_outlines(_carry)
		player.speed_mult = 0.6
		Audio.sfx("land_pot", -10.0, 0.6)


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
	c.title_text = tr("UI_FLOW30O_TITLE")
	c.nodes = [
		{"id": "ladder", "key": "FLOW30O_LADDER", "pos": Vector2(0.5, 0.12)},
		{"id": "30O.1", "key": "FLOW_30O_1", "pos": Vector2(0.3, 0.34), "outcome": true},
		{"id": "30O.2", "key": "FLOW_30O_2", "pos": Vector2(0.7, 0.34), "outcome": true},
		{"id": "retreat", "key": "FLOW30O_RETREAT", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["ladder", "30O.1"], ["ladder", "30O.2"], ["30O.1", "retreat"], ["30O.2", "retreat"]]
	for k in ["ladder", _outcome, "retreat"]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH30O_STATS") % [stones - stone_hits, stones, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	c.footer_lines.insert(0, Grade.finish("30o"))
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "30O.1", "lose": "30O.2"}.get(v, "30O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("30", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and climbed and carried
	ok = ok and stones >= 1 and gunner_shots >= 1
	# Kaynar yağ: bir kez döküldü; bot sarkıp kaçtı (=lose'da yandı)
	ok = ok and oil != null and oil.dodged + oil.hits == 1 and oil.hits == (1 if v == "lose" else 0)
	if v == "lose":
		ok = ok and player.downs >= 1 and not _duel_won
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s tırmandı=%s taşıdı=%s)" % [expected, _outcome, not page.is_empty(),
			cam != null and cam.done, climbed, carried])
	print("AUTOTEST %s chapter=30o variant=%s outcome=%s stones=%d/%d gunner=%d/%d" % ["PASS" if ok else "FAIL", v, _outcome,
		stones - stone_hits, stones, gunner_dodged, gunner_shots])
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
	ladder.visible = true
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(CLIMB_X + 9.0, 3.0, 26.0)
	cv.look_at(Vector3(CLIMB_X - 2.0, 8.0, 2.0), Vector3.UP)
	cv.fov = 55.0
	cv.make_current()
	await get_tree().create_timer(0.6).timeout
	await _shot_png("c30o_cover.png")
	get_tree().quit()
