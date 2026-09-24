extends Node3D
## Bölüm 12B — Son Akşam (Tolga · 26 Nisan 1453, gün batımı). EXPANSION §2.5.
##
## Bizans'ı Kurtar yolunda (Direniş ≥ 1) Bölüm 12'nin (Fatih'in huzuru) yerine oynanır.
## Konstantinos surlarda, gün batımında Tolga'yla konuşur. Espri yok: Fatih'in huzurundaki
## "Bunu size söyleyemem" sahnesinin aynası.
##   ⏱ "Yaptığın şey yetecek mi?"
##     12B.1 "Bunu size söyleyemem." (dürüst) · 12B.2 "Yetecek." (iyi niyetli yalan) · 12B.3 "Belki bir yıl."
## Dünya Direniş'ten gelir: 1 → W10 (1454), 2 → W11 (1455), 3 → W12 (Ertelendi).
##   --autotest[=lie|year|d2|d3|next]   (varsayılan: 12B.1, Direniş 1)

const WALL_TOP := Vector3(33.6, 12.05, -8.0)
const EMP_AT := Vector3(34.2, 12.0, -6.4)
const WORLDS := {1: "W10", 2: "W11", 3: "W12"}

var city: ByzCity
var player: Player
var hud: Hud
var _outcome := ""
var _direnc := 1


func _ready() -> void:
	GameState.snapshot(12)
	_apply_autotest_setup()
	_direnc = clampi(int(GameState.flags.get("direnc", 1)), 1, 3)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	hud.set_cinematic(true)
	player.show_remote(true)
	city = ByzCity.new()
	add_child(city)
	city.make_sunset()
	# İmparator surun üstünde, dışarıya (ordugâha) bakar
	city.emperor.position = EMP_AT
	city.emperor.rotation.y = PI / 2.0
	city.emperor.look_target = null
	_build_camp_view()
	# Surun tepesine yürüme yüzeyi
	Props.solid(self, Vector3(2.4, 0.1, 10.0), Vector3(33.6, 12.0, -7.0), Color("c9b89a"))
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


## Surların dışı: ovada Osmanlı ordugâhı. Gün batımında çadırlar ve yanmaya başlayan ateşler (boş ufuk yok).
func _build_camp_view() -> void:
	var ground := Props.box(self, Vector3(420, 0.2, 360), Vector3(245, -0.3, -10), Color("7a6a48"))
	ground.material_override = Props.mat(Color("7a6a48"), 0.0, false, "", false)
	# Hendek ve dış sur
	Props.box(self, Vector3(8, 0.3, 120), Vector3(44, -0.25, -10), Color("3a4a3a"))
	Props.set_pattern(Props.box(self, Vector3(2.0, 7.0, 120.0), Vector3(50, 3.5, -10), Color.WHITE), Color("e8d8c0"), "ashlar")
	for z in [-60.0, -40.0, -20.0, 0.0, 20.0, 40.0]:
		Props.set_pattern(Props.box(self, Vector3(5.0, 10.0, 5.0), Vector3(50, 5.0, z), Color.WHITE), Color("e0d0b8"), "ashlar")
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var colors := [Color("d8cbb0"), Color("c8b894"), Color("e0d4b8"), Color("b8a888")]
	var bands := [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a"), Color("c98a3a")]
	for i in 140:
		var p := Vector3(rng.randf_range(80.0, 300.0), 0, rng.randf_range(-150.0, 130.0))
		var t := Night.tent(self, p, rng.randf_range(1.8, 3.4), colors[i % 4], bands[i % 4])
		t.rotation.y = rng.randf() * TAU
	# Otağ: uzakta, kırmızı-altın
	Props.cyl(self, 9.0, 6.0, Vector3(170, 3.0, -10), Color("b3262d"), Vector3.ZERO, 16)
	Props.cyl(self, 9.4, 5.0, Vector3(170, 8.5, -10), Color("c8323a"), Vector3.ZERO, 16, 0.4)
	Props.ball(self, 0.8, Vector3(170, 11.5, -10), Color("d8b040"), Vector3.ONE, 8)
	# Ateşler: sıcak ışık noktaları ve ince duman
	for i in 36:
		var p := Vector3(rng.randf_range(75.0, 280.0), 0.4, rng.randf_range(-140.0, 120.0))
		var fire := Props.ball(self, 0.6, p, Color("ffb050"), Vector3.ONE, 6, 4.0)
		fire.material_override = Props.mat(Color("ffb050"), 4.0, false, "", false)
		if i % 4 == 0:
			var l := OmniLight3D.new()
			l.position = p + Vector3(0, 1.5, 0)
			l.light_color = Color("ff9a4a")
			l.light_energy = 2.0
			l.omni_range = 14.0
			add_child(l)
	# Uzakta tepeler (ufuk kapanır)
	for i in 9:
		var hp := Vector3(330.0 + rng.randf_range(-20.0, 20.0), -6.0, -200.0 + i * 50.0)
		Props.ball(self, rng.randf_range(40.0, 70.0), hp, Color("6a6048"), Vector3(1.0, 0.45, 1.3), 10)


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	GameState.chapter_outcomes[10] = "10H.1"
	var f := GameState.flags
	f["direnc"] = {"d2": 2, "d3": 3}.get(GameState.autotest_variant, 1)
	f["breach_taped"] = true


func _wait(sec: float) -> void:
	await get_tree().create_timer(0.05 if GameState.autotest else sec).timeout


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	Audio.music("byzantium_evening" if ResourceLoader.exists("res://assets/audio/music/byzantium_evening.ogg") else "tender")
	await hud.card([[tr("UI_CH12B_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH12B_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.gravity_on = false
	player.global_position = WALL_TOP
	player.face(Vector3(90.0, 8.0, -10.0))
	await hud.fade_to(0.0, 1.4)
	await _wait(1.5)
	player.face(city.emperor.global_position + Vector3(0, 1.5, 0))
	await _k("D12B_K_01")
	await _t("D12B_T_02")
	# Gece yapılanları İmparator biliyor
	var f := GameState.flags
	if f.get("breach_taped", false) or _direnc >= 1:
		await _k("D12B_K_DONE_%d" % _direnc)
	await _k("D12B_K_03")
	player.face(Vector3(90.0, 9.0, -8.0))
	await _t("D12B_T_04")
	player.face(city.emperor.global_position + Vector3(0, 1.5, 0))
	await _k("D12B_K_Q")
	var pick: int = {"lie": 1, "year": 2}.get(GameState.autotest_variant, 0)
	var c := await hud.choose(["UI_CH12B_CANT_SAY", "UI_CH12B_LIE", "UI_CH12B_YEAR"], 12.0, pick)
	match c:
		1:
			await _t("D12B_T_LIE")
			await _k("D12B_K_LIE")
			_outcome = "12B.2"
		2:
			await _t("D12B_T_YEAR")
			await _k("D12B_K_YEAR")
			_outcome = "12B.3"
		_:
			await _t("D12B_T_CANT_SAY")
			await _k("D12B_K_CANT_SAY")
			GameState.flags["honest_with_sultan"] = true
			GameState.flags["byz_honest"] = true
			_outcome = "12B.1"
	await _wait(1.0)
	await _k("D12B_K_END")
	await _wait(1.2)
	await hud.fade_to(1.0, 1.4)
	await hud.say("SPK_HIKMET", "D12B_H_RADIO")
	await _t("D12B_T_RADIO")
	GameState.flags["world10"] = WORLDS[_direnc]
	GameState.flags["world"] = WORLDS[_direnc]
	await _end_chapter()


func _k(key: String) -> void:
	city.emperor.talking = true
	await hud.say("SPK_EMPEROR", key)
	city.emperor.talking = false


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	GameState.set_outcome(12, _outcome)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=12b -> 13 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter13.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter13.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW12B_TITLE")
	c.nodes = [
		{"id": "walls", "key": "FLOW12B_WALLS", "pos": Vector2(0.5, 0.14)},
		{"id": "12B.1", "key": "FLOW_12B_1", "pos": Vector2(0.18, 0.42), "outcome": true},
		{"id": "12B.2", "key": "FLOW_12B_2", "pos": Vector2(0.5, 0.42), "outcome": true},
		{"id": "12B.3", "key": "FLOW_12B_3", "pos": Vector2(0.82, 0.42), "outcome": true},
		{"id": "W10", "key": "FLOW12B_W10", "pos": Vector2(0.18, 0.7)},
		{"id": "W11", "key": "FLOW12B_W11", "pos": Vector2(0.5, 0.7)},
		{"id": "W12", "key": "FLOW12B_W12", "pos": Vector2(0.82, 0.7)},
	]
	c.edges = [["walls", "12B.1"], ["walls", "12B.2"], ["walls", "12B.3"], ["12B.1", "W10"], ["12B.2", "W11"], ["12B.3", "W12"]]
	c.taken["walls"] = true
	c.taken[_outcome] = true
	c.taken[WORLDS[_direnc]] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH12B_STATS") % [_direnc, tr("FATE_" + String(WORLDS[_direnc]))],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW12B_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "12B.1", "lie": "12B.2", "year": "12B.3", "d2": "12B.1", "d3": "12B.1", "next": "12B.1"}[v]
	var world: String = GameState.flags.get("world10", "")
	var want_world: String = {"d2": "W11", "d3": "W12"}.get(v, "W10")
	var ok: bool = _outcome == expected and world == want_world and GameState.chapter_outcomes.get(12, "") == _outcome
	if not ok:
		printerr("AUTOTEST: beklenen %s/%s, gelen %s/%s" % [expected, want_world, _outcome, world])
	print("AUTOTEST %s chapter=12b variant=%s outcome=%s world=%s honest=%s" % ["PASS" if ok else "FAIL", v, _outcome, world,
		str(GameState.flags.get("honest_with_sultan", false))])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.gravity_on = false
	player.global_position = WALL_TOP + Vector3(-1.2, 0, -1.8)
	player.face(city.emperor.global_position + Vector3(2.0, 1.3, 0.4))
	await get_tree().create_timer(0.8).timeout
	hud.bark("SPK_EMPEROR", "D12B_K_END", 30.0)
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join("c12b_01_son_aksam.png"))
	print("shot: c12b_01_son_aksam.png")
	get_tree().quit()
