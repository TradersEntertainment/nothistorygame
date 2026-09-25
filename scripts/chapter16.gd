extends Node3D
## Bölüm 16 — Gıdak (gizli · Sinerji). CHAPTERS Bölüm 16.
##
## Koşul: Bölüm 13'te pencere kaçmak üzere (13.2 olacak) ve Sinerji Tolga'yla birlikte (Bizans yolu, 4b).
## Oyuncu 90 saniyeliğine Sinerji olur. Kamera tavuk yüksekliğinde. Telsiz-Kumanda Tolga'nın elinden
## düşmüştür; Hasan ile Hüseyin Tolga'yı (yanlış anlayıp) mutfağa taşımaktadır.
## Amaç: kırmızı düğmeyi üç kez gagalamak. Engeller: devriye gezen Hasan ile Hüseyin (yakalarlarsa
## başa), bir kedi (kovalar), bir çuval leblebi (dikkat dağıtıcı: yersen biter).
##   16.1 Düğme gagalandı → 13.6 (T1, Sinerji 2026'ya gelir) · 16.2 Leblebiye yenik düştü / süre bitti → 13.2
##   --autotest[=leb|late]   (varsayılan: 16.1)

const TIME := 90.0
const START := Vector3(-11.0, 0.0, 10.0)
const REMOTE := Vector3(11.0, 0.0, -7.0)
const SACK := Vector3(-3.0, 0.0, 12.5)
const TOLGA_CARRY := Vector3(4.0, 0.0, 14.0)

var day: CampDay
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _time := TIME
var _pecks := 0
var _caught := 0
var hasan: Soldier
var huseyin: Soldier
var cat: Node3D
var tolga_npc: Person
var remote: Node3D
var _red: MeshInstance3D
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(16)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	player.eye_height = 0.32
	player.speed_mult = 0.9
	add_child(player)
	player.interacted.connect(func(_id: String): pass)
	player.frozen = true
	hud.set_fez(false)
	hud.set_signal(0)
	hud.set_cinematic(true)
	day = CampDay.new()
	add_child(day)
	if day.ring_node:
		day.ring_node.queue_free()
	day.goat.chase = null
	_build()
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	# Yerdeki Telsiz-Kumanda: yanıp sönen kırmızı düğme
	remote = Node3D.new()
	remote.position = REMOTE
	add_child(remote)
	Props.box(remote, Vector3(0.16, 0.06, 0.3), Vector3(0, 0.03, 0), Color("2a2d34"))
	Props.cyl(remote, 0.01, 0.2, Vector3(0.05, 0.08, -0.14), Color("1a1a1e"), Vector3(70, 0, 0), 4)
	_red = Props.cyl(remote, 0.04, 0.03, Vector3(0, 0.075, 0.05), Color("ff3030"), Vector3.ZERO, 8, -1.0, 2.0)
	_red.material_override = Props.mat(Color("ff3030"), 2.5, false, "", false)
	var glow := OmniLight3D.new()
	glow.position = Vector3(0, 0.3, 0)
	glow.light_color = Color("ff4040")
	glow.light_energy = 1.5
	glow.omni_range = 3.0
	remote.add_child(glow)
	# Leblebi çuvalı (ağzı açık, etrafa dökülmüş)
	Props.ball(self, 0.45, SACK + Vector3(0, 0.4, 0), Color("c8b894"), Vector3(1, 1.1, 1), 8)
	for i in 14:
		var a := i * 0.9
		Props.ball(self, 0.05, SACK + Vector3(cos(a) * (0.6 + i * 0.04), 0.05, sin(a) * (0.6 + i * 0.04)), Color("e8d8a8"), Vector3.ONE, 5)
	Props.label(self, "LEBLEBİ", SACK + Vector3(0, 0.55, 0.46), 26, Color("5a3a24"), Vector3.ZERO, 0.8)
	# Hasan ile Hüseyin: Tolga'yı omuzlarında taşıyorlar (yanlış anlamış, "hasta" sanıyorlar)
	hasan = Soldier.new(Color("b3262d"), "stand", "bork")
	huseyin = Soldier.new(Color("2f5fa8"), "stand", "bork")
	add_child(hasan)
	add_child(huseyin)
	tolga_npc = Person.new({"face": "tolga", "coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")})
	tolga_npc.rotation = Vector3(0, 0, PI / 2.0)
	add_child(tolga_npc)
	# Kedi: turuncu, kutu gibi, kararlı
	cat = Node3D.new()
	add_child(cat)
	Props.box(cat, Vector3(0.22, 0.2, 0.45), Vector3(0, 0.2, 0), Color("e08a3a"))
	Props.box(cat, Vector3(0.2, 0.18, 0.18), Vector3(0, 0.32, 0.26), Color("e08a3a"))
	for s in [-1, 1]:
		Props.prism(cat, Vector3(0.06, 0.08, 0.04), Vector3(s * 0.06, 0.45, 0.26), Color("c8702a"))
		Props.ball(cat, 0.02, Vector3(s * 0.05, 0.35, 0.36), Color("1a3a1a"), Vector3.ONE, 5)
	Props.cyl(cat, 0.02, 0.35, Vector3(0, 0.35, -0.3), Color("e08a3a"), Vector3(-40, 0, 0), 4)
	_place_actors(0.0)


## Devriye: Hasan ile Hüseyin (Tolga omuzlarında) sahanın ortasında gidip gelir; kedi kumandanın çevresinde döner.
func _place_actors(t: float) -> void:
	var gz := 2.0 + sin(t * 0.55) * 7.0
	var gx := sin(t * 0.3) * 2.0
	hasan.position = Vector3(gx - 0.5, 0, gz)
	huseyin.position = Vector3(gx + 0.5, 0, gz + 0.1)
	var dir := 1.0 if cos(t * 0.55) > 0 else -1.0
	hasan.rotation.y = 0.0 if dir > 0 else PI
	huseyin.rotation.y = hasan.rotation.y
	tolga_npc.position = Vector3(gx, 1.55, gz)
	tolga_npc.rotation.y = hasan.rotation.y
	var ca := t * 0.9
	cat.position = REMOTE + Vector3(cos(ca) * 3.2, 0, sin(ca) * 3.2)
	cat.rotation.y = -ca


func _process(delta: float) -> void:
	_t += delta
	if _red:
		_red.visible = fmod(_t, 0.6) < 0.4
	if phase != "free":
		return
	_place_actors(_t)
	_time -= delta
	hud.set_chase(tr("UI_CH16_TIME") % maxi(0, int(ceil(_time))), 1.0 - _time / TIME)
	var p := player.global_position
	# Muhafızlar yakalarsa: başa (Hüseyin tavukları sever)
	for g in [hasan, huseyin]:
		if Vector2(p.x - g.position.x, p.z - g.position.z).length() < 1.3:
			_caught += 1
			_time -= 8.0
			# Replikler kişiye yazılı: 1-2 Hasan ("Hüseyin, tavuk kaçıyor!"), 3 Hüseyin ("...Hasan")
			var n := mini(_caught, 3)
			hud.bark("SPK_HUSEYIN" if n == 3 else "SPK_HASAN", "D16_G_CATCH_%d" % n, 2.5)
			Audio.sfx("chicken", -4.0)
			player.global_position = START + Vector3(0, 0.1, 0)
			player.face(REMOTE)
			break
	# Kedi: kovalar, geri iter
	if Vector2(p.x - cat.position.x, p.z - cat.position.z).length() < 0.9:
		var away := (p - cat.position)
		away.y = 0
		player.global_position += away.normalized() * 2.2
		player.shake(0.3)
		hud.bark("SPK_SINERJI", "D16_S_CAT", 1.5)
		Audio.sfx("chicken", -2.0, 1.3)
	var near_sack := p.distance_to(SACK) < 1.6
	var near_remote := p.distance_to(REMOTE) < 1.1
	if near_sack:
		hud.set_prompt(tr("UI_PROMPT16_SACK"))
	elif near_remote:
		hud.set_prompt(tr("UI_PROMPT16_PECK") % (3 - _pecks))
	else:
		hud.set_prompt("")
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("kick"):
		if near_sack:
			_eat()
		elif near_remote:
			_peck()
	if _time <= 0.0:
		_time = 0.0
		_finish_fail("late")


func _peck() -> void:
	_pecks += 1
	Audio.sfx("chicken", -6.0, 1.2)
	var tw := create_tween()
	tw.tween_property(player.camera, "position:y", 0.12, 0.08)
	tw.tween_property(player.camera, "position:y", player.eye_height, 0.12)
	if _pecks >= 3:
		_win()


func _eat() -> void:
	_finish_fail("leb")


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH16_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH16_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = START + Vector3(0, 0.1, 0)
	player.face(REMOTE + Vector3(0, 0.2, 0))
	_place_actors(0.0)
	if player.hand:
		player.hand.visible = false
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_SINERJI", "D16_S_01")
	await hud.say("SPK_SINERJI", "D16_S_02")
	hud.set_objective(tr("UI_OBJ16"), REMOTE + Vector3(0, 0.6, 0))
	phase = "free"
	player.frozen = false
	if GameState.autotest:
		await _auto()
	while _outcome == "":
		await get_tree().process_frame
	await _end_chapter()


func _win() -> void:
	if phase != "free":
		return
	phase = "won"
	player.frozen = true
	hud.set_prompt("")
	hud.set_chase("", 0.0)
	hud.set_objective("")
	Audio.sfx("radio_beep", 0.0)
	await hud.fade_to(0.9, 0.15, Color.WHITE)
	Audio.sfx("machine_jump", 0.0)
	tolga_npc.visible = false
	await hud.fade_to(0.0, 0.6, Color.WHITE)
	player.face(hasan.global_position + Vector3(0, 1.6, 0))
	await hud.say("SPK_HASAN", "D16_H_GONE")
	await hud.say("SPK_HUSEYIN", "D16_HU_GONE")
	await hud.fade_to(0.9, 0.2, Color.WHITE)
	await hud.card([[tr("UI_CH16_WIN"), 30, Color("f2e6c9")], [tr("UI_CH16_WIN_SUB"), 18, Color(1, 1, 1, 0.8)]], 3.0)
	hud.clear_card()
	GameState.flags["tolga_fate"] = "T1"
	GameState.flags["sinerji_2026"] = true
	GameState.chapter_outcomes[13] = "13.6"
	_outcome = "16.1"


func _finish_fail(why: String) -> void:
	if phase != "free":
		return
	phase = "lost"
	player.frozen = true
	hud.set_prompt("")
	hud.set_chase("", 0.0)
	hud.set_objective("")
	if why == "leb":
		await hud.say("SPK_SINERJI", "D16_S_LEB")
		await hud.card([[tr("UI_CH16_LEB"), 28, Color("f2e6c9")]], 2.4)
	else:
		await hud.say("SPK_SINERJI", "D16_S_LATE")
	hud.clear_card()
	GameState.flags["tolga_fate"] = "T2"
	GameState.chapter_outcomes[13] = "13.2"
	_outcome = "16.2"


func _auto() -> void:
	match GameState.autotest_variant:
		"leb":
			player.global_position = SACK + Vector3(0.8, 0.1, 0)
			await get_tree().process_frame
			_eat()
		"late":
			_time = 0.05
		_:
			phase = "auto"
			player.global_position = REMOTE + Vector3(0.5, 0.1, 0.3)
			phase = "free"
			for i in 3:
				await get_tree().create_timer(0.05).timeout
				_peck()


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(16, _outcome)
	GameState.set_outcome(13, GameState.chapter_outcomes[13])
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=16 -> 14 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter14.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter14.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW16_TITLE")
	c.nodes = [
		{"id": "drop", "key": "FLOW16_DROP", "pos": Vector2(0.5, 0.16)},
		{"id": "16.1", "key": "FLOW_16_1", "pos": Vector2(0.28, 0.46), "outcome": true},
		{"id": "16.2", "key": "FLOW_16_2", "pos": Vector2(0.72, 0.46), "outcome": true},
	]
	c.edges = [["drop", "16.1"], ["drop", "16.2"]]
	c.taken["drop"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH16_STATS") % [_pecks, _caught, int(TIME - _time)],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW16_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "16.1", "leb": "16.2", "late": "16.2"}[v]
	var want13 := "13.6" if expected == "16.1" else "13.2"
	var ok: bool = _outcome == expected and GameState.chapter_outcomes.get(13, "") == want13
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=16 variant=%s outcome=%s ch13=%s pecks=%d" % ["PASS" if ok else "FAIL", v, _outcome,
		GameState.chapter_outcomes.get(13, ""), _pecks])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	await get_tree().create_timer(0.6).timeout
	if player.hand:
		player.hand.visible = false
	_place_actors(2.2)
	player.global_position = Vector3(-5.0, 0.1, 7.5)
	player.face(hasan.global_position + Vector3(1.0, 1.4, 0))
	hud.set_objective(tr("UI_OBJ16"), REMOTE + Vector3(0, 0.6, 0))
	hud.set_chase(tr("UI_CH16_TIME") % 64, 0.3)
	hud.bark("SPK_SINERJI", "D16_S_02", 30.0)
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join("c16_01_gidak.png"))
	print("shot: c16_01_gidak.png")
	get_tree().quit()
