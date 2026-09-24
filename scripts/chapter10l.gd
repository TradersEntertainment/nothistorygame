extends Node3D
## Bölüm 10L — Lağım (Tolga · 25 Nisan 1453, toprağın altında). EXPANSION §7.
##
## Tarihî zemin: Osmanlı ordusu kuşatmada Novo Brdo'lu madencilerle surların altına lağım kazdı;
## Bizans tarafı karşı lağımlarla (mühendis Johannes Grant) bunları buldu.
## 9.7'de Lağımcı Dragan'ın teklifi kabul edildi. Mum ışığında, toprağın altında:
##   Kazı yüzüne her gelişte: ⛏ Kaz (2 m ilerler) · 🪵 Destek koy · 👂 Dinle
##   Mum (hava) her işte azalır; biterse geri çekilinir. Üç kez desteksiz kazılırsa tavan çöker.
##   Altı ilerlemede tünel, Bizanslıların karşı lağımına açılır: iki taraf karanlıkta yüz yüze.
##   10L.1 Tünel Sulhu: poliçe ya da leblebi, karanlıkta ekmek bölüşülür (W13, Bölüm 12 atlanır)
##   10L.2 Geri çekil (sessizce) · 10L.3 Tavan çöktü: Nihat bir formla kazıp çıkarır
##   --autotest[=collapse|retreat|leb|next]   (varsayılan: 10L.1)

const SEG := 2.0
const GOAL := 6
const CANDLE := 14.0
const START := Vector3(0.0, 0.0, 0.0)

var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _busy := false
var _progress := 0
var _unsupported := 0
var _candle := CANDLE
var _heard := false
var dragan: Person
var grant: Person
var _face: Node3D
var _tunnel: Node3D
var _lamp: OmniLight3D


func _ready() -> void:
	GameState.snapshot(10)
	_apply_autotest_setup()
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(_on_focus)
	player.frozen = true
	player.outfit_enabled = false
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(maxi(0, GameState.telsiz_bag - 2))
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	player.show_remote(true)
	_build()
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	GameState.chapter_outcomes[9] = "9.7"
	if not "chickpeas" in GameState.bag:
		GameState.bag.append("chickpeas")


func _d(sec: float) -> float:
	return 0.05 if GameState.autotest else sec


func _wait(sec: float) -> void:
	await get_tree().create_timer(_d(sec)).timeout


# ================================================================ sahne

func _build() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("0a0806")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("5a3a24")
	e.ambient_light_energy = 0.25
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_light_color = Color("1a120c")
	e.fog_density = 0.05
	e.glow_enabled = true
	env.environment = e
	add_child(env)
	_tunnel = Node3D.new()
	add_child(_tunnel)
	# Giriş: yukarıda gün ışığı sızan kuyu
	Props.solid(self, Vector3(3.0, 0.2, 4.0), Vector3(0, -0.1, 1.0), Color("4a3828"))
	Props.solid(self, Vector3(3.0, 3.0, 0.3), Vector3(0, 1.5, 3.0), Color("3a2a1e"))
	var sun := SpotLight3D.new()
	sun.position = Vector3(0, 6, 2.0)
	sun.rotation_degrees = Vector3(-90, 0, 0)
	sun.spot_angle = 18.0
	sun.spot_range = 8.0
	sun.light_energy = 3.0
	sun.light_color = Color("fff0d0")
	add_child(sun)
	Props.box(self, Vector3(1.2, 4.0, 1.2), Vector3(0, 4.5, 2.0), Color("ffe8b0"), Vector3.ZERO, 0.8)
	# İlk bölüm ve kazı yüzü
	_add_segment(0, true)
	_face = Node3D.new()
	add_child(_face)
	Props.set_pattern(Props.solid(_face, Vector3(2.4, 2.4, 0.4), Vector3(0, 1.2, 0), Color.WHITE), Color("5a4430"), "plaster")
	Props.interactable(_face, "face", Vector3(2.0, 2.0, 0.8), Vector3(0, 1.1, 0.5))
	_face.position = Vector3(0, 0, -SEG - 0.2)
	# Dragan: arkada, sepetle toprak taşıyor; yanında mum
	dragan = Person.new({"coat": Color("6a5a48"), "pants": Color("3a3028"), "hat": "none", "beard": true, "mustache": true,
		"hair": Color("4a3a2a"), "apron": Color("4a3a2a"), "skin": Color("c89070")})
	dragan.position = Vector3(0.8, 0, 0.6)
	dragan.rotation.y = PI
	dragan.look_target = player
	add_child(dragan)
	_lamp = OmniLight3D.new()
	_lamp.light_color = Color("ffb060")
	_lamp.light_energy = 1.6
	_lamp.omni_range = 7.0
	add_child(_lamp)
	# Karşı lağım (Bizans): kazı bitince açılan oda, mumlar, Grant ve iki kazmacı
	var ch := Vector3(0, 0, -SEG * GOAL - 3.6)
	Props.solid(self, Vector3(5.0, 0.2, 5.0), ch + Vector3(0, -0.1, 0), Color("4a3828"))
	Props.solid(self, Vector3(5.0, 3.0, 0.3), ch + Vector3(0, 1.5, -2.5), Color("3a2a1e"))
	for sx in [-2.5, 2.5]:
		Props.solid(self, Vector3(0.3, 3.0, 5.0), ch + Vector3(sx, 1.5, 0), Color("3a2a1e"))
	Props.box(self, Vector3(5.0, 0.3, 5.0), ch + Vector3(0, 2.8, 0), Color("2a1e14"))
	grant = Person.new({"coat": Color("5a5a62"), "pants": Color("3a3a40"), "hat": "none", "beard": true, "hair": Color("8a5a2a"),
		"apron": Color("3a3028"), "skin": Color("e8b894")})
	grant.position = ch + Vector3(0, 0, -1.2)
	add_child(grant)
	for sx in [-1.4, 1.4]:
		var d := Person.new({"coat": Color("7a6a58"), "pants": Color("3a3028"), "hat": "helm", "mustache": true, "skin": Color("d9a07a")})
		d.position = ch + Vector3(sx, 0, -1.6)
		add_child(d)
	var cl := OmniLight3D.new()
	cl.position = ch + Vector3(0, 2.4, 0.2)
	cl.light_color = Color("ffc070")
	cl.light_energy = 2.6
	cl.omni_range = 6.0
	add_child(cl)
	grant.visible = false


## Bir tünel bölümü: zemin, duvarlar, tavan; destekli ise ahşap çerçeve.
func _add_segment(i: int, supported: bool) -> void:
	var z := -i * SEG - SEG * 0.5
	Props.solid(_tunnel, Vector3(2.4, 0.2, SEG), Vector3(0, -0.1, z), Color("4a3828"))
	for sx in [-1.3, 1.3]:
		Props.set_pattern(Props.solid(_tunnel, Vector3(0.3, 2.6, SEG), Vector3(sx, 1.3, z), Color.WHITE), Color("5a4430"), "plaster")
	Props.box(_tunnel, Vector3(2.8, 0.3, SEG), Vector3(0, 2.55, z), Color("3a2a1e"))
	if supported:
		_add_support(i)


func _add_support(i: int) -> void:
	var z := -i * SEG - SEG * 0.5
	for sx in [-1.05, 1.05]:
		Props.cyl(_tunnel, 0.09, 2.3, Vector3(sx, 1.15, z), Color("7a5a38"), Vector3.ZERO, 6)
	Props.box(_tunnel, Vector3(2.3, 0.16, 0.2), Vector3(0, 2.35, z), Color("7a5a38"))


func _process(_delta: float) -> void:
	if _lamp and player:
		_lamp.global_position = player.global_position + Vector3(0.3, 1.5, -0.4)
		_lamp.light_energy = 0.5 + 1.2 * clampf(_candle / CANDLE, 0.0, 1.0) + sin(Time.get_ticks_msec() * 0.02) * 0.08


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH10L_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH10L_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = Vector3(0, 0.1, 1.6)
	player.face(Vector3(0, 1.2, -4.0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _dr("D10L_D_01")
	await _t("D10L_T_02")
	await _dr("D10L_D_03")
	await _t("D10L_T_04")
	await _dr("D10L_D_05")
	phase = "free"
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		await _auto()
	while _outcome == "":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	await _end_chapter()


func _update_objective() -> void:
	hud.set_objective(tr("UI_OBJ10L") % [_progress * 2, GOAL * 2, int(ceil(_candle)), "⚠" if _unsupported >= 2 else ""])
	hud.set_chase(tr("UI_CH10L_CANDLE"), 1.0 - _candle / CANDLE)


## Kazı yüzünde bir iş: kaz, destek koy ya da dinle.
func _work(auto := -1) -> void:
	if _busy or phase != "free":
		return
	_busy = true
	player.frozen = true
	hud.set_prompt("")
	var keys := ["UI_CH10L_DIG", "UI_CH10L_SUPPORT", "UI_CH10L_LISTEN"]
	var c := await hud.choose(keys, 0.0, maxi(auto, 0))
	match c:
		1:
			if _unsupported == 0:
				await _dr("D10L_D_SUPPORT_NO")
			else:
				_add_support(_progress)
				Audio.sfx("kick_metal", -10.0, 0.7)
				_unsupported = 0
				_candle -= 0.5
				await _dr("D10L_D_SUPPORT")
		2:
			_candle -= 0.5
			await _t("D10L_T_LISTEN")
			if _progress >= 3:
				_heard = true
				GameState.flags["ch10l_heard"] = true
				Audio.sfx("kick_metal", -20.0, 0.5)
				await _t("D10L_T_HEARD")
				await _dr("D10L_D_HEARD")
			else:
				await _dr("D10L_D_SILENT")
		_:
			await _dig()
	if _outcome == "" and _candle <= 0.0:
		await _candle_out()
	if _outcome == "":
		_update_objective()
		player.frozen = false
	_busy = false


func _dig() -> void:
	Audio.sfx("kick_metal", -8.0, 0.6)
	player.shake(0.25)
	Vfx.dust(self, _face.global_position + Vector3(0, 1.2, 0.4), 0.5)
	await _wait(0.5)
	_add_segment(_progress + 1, false)
	_progress += 1
	_unsupported += 1
	_candle -= 1.5
	_face.position.z = -(_progress + 1) * SEG - 0.2
	if _unsupported >= 3:
		await _collapse()
		return
	if _unsupported == 2:
		await _dr("D10L_D_WARN")
	elif _progress < GOAL:
		await _dr("D10L_D_DIG_%d" % mini(_progress, 5))
	if _progress >= GOAL:
		await _breakthrough()


## Tavan çöker: toz, karanlık, ve Nihat bir formla kazıp çıkarır.
func _collapse() -> void:
	player.shake(1.0)
	Audio.sfx("cannon", -4.0, 0.5)
	Vfx.dust(self, player.global_position + Vector3(0, 1.8, -1.0), 1.5)
	await hud.fade_to(1.0, 0.3)
	hud.set_chase("", 0.0)
	await _t("D10L_T_COLLAPSE")
	await _wait(1.2)
	await hud.say("SPK_NIHAT", "D10L_N_DIG_1")
	await _t("D10L_T_COLLAPSE_2")
	await hud.say("SPK_NIHAT", "D10L_N_DIG_2")
	GameState.paradox += 20
	GameState.flags["buried"] = true
	_outcome = "10L.3"


func _candle_out() -> void:
	await _t("D10L_T_CANDLE")
	await _dr("D10L_D_CANDLE")
	_outcome = "10L.2"


## Tünel, karşı lağıma açılır.
func _breakthrough() -> void:
	player.shake(0.6)
	Vfx.dust(self, _face.global_position + Vector3(0, 1.2, 0.4), 1.0)
	_face.visible = false
	_face.position.y = -20.0
	grant.visible = true
	grant.look_target = player
	hud.set_chase("", 0.0)
	hud.set_objective("")
	var tw := create_tween()
	tw.tween_property(player, "global_position", Vector3(0, 0.1, -SEG * GOAL - 0.6), _d(1.2))
	await tw.finished
	player.face(grant.global_position + Vector3(0, 1.5, 0))
	await _t("D10L_T_MEET_1")
	await _g("D10L_G_MEET_2")
	await _t("D10L_T_MEET_3" if _heard else "D10L_T_MEET_3B")
	await _g("D10L_G_MEET_4")
	var keys := ["UI_CH10L_POLICY", "UI_CH10L_RETREAT"]
	if "chickpeas" in GameState.bag:
		keys.insert(1, "UI_CH10L_LEBLEBI")
	var pick := 0
	match GameState.autotest_variant:
		"retreat": pick = keys.size() - 1
		"leb": pick = 1
	var c := await hud.choose(keys, 10.0, pick)
	var chosen: String = keys[c] if c >= 0 else "UI_CH10L_RETREAT"
	match chosen:
		"UI_CH10L_POLICY":
			await _t("D10L_T_POLICY")
			await _g("D10L_G_POLICY")
			await _truce()
		"UI_CH10L_LEBLEBI":
			await _t("D10L_T_LEBLEBI")
			await _g("D10L_G_LEBLEBI")
			GameState.flags["leblebi_given"] = true
			await _truce()
		_:
			await _t("D10L_T_RETREAT")
			await _g("D10L_G_RETREAT")
			_outcome = "10L.2"


## Tünel Sulhu: iki taraf karanlıkta ekmek bölüşür, kimse kimseyi görmemiş sayılır.
func _truce() -> void:
	dragan.position = Vector3(0.9, 0, -SEG * GOAL + 0.4)
	dragan.visible = true
	await _dr("D10L_D_TRUCE")
	await _g("D10L_G_TRUCE")
	await _t("D10L_T_TRUCE")
	await hud.fade_to(1.0, 1.0)
	await hud.card([[tr("UI_CH10L_TRUCE"), 28, Color("f2e6c9")], [tr("UI_CH10L_TRUCE_SUB"), 18, Color(1, 1, 1, 0.8)]], 3.0)
	hud.clear_card()
	await hud.say("SPK_HIKMET", "D10L_H_RADIO")
	await _t("D10L_T_RADIO")
	GameState.flags["world10"] = "W13"
	GameState.paradox += 15
	_outcome = "10L.1"


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	hud.set_chase("", 0.0)
	GameState.set_outcome(10, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=10l -> 11 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter11.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter11.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW10L_TITLE")
	c.nodes = [
		{"id": "dig", "key": "FLOW10L_DIG", "pos": Vector2(0.2, 0.16)},
		{"id": "listen", "key": "FLOW10L_LISTEN", "pos": Vector2(0.5, 0.16)},
		{"id": "meet", "key": "FLOW10L_MEET", "pos": Vector2(0.8, 0.16)},
		{"id": "10L.1", "key": "FLOW_10L_1", "pos": Vector2(0.8, 0.48), "outcome": true},
		{"id": "10L.2", "key": "FLOW_10L_2", "pos": Vector2(0.5, 0.48), "outcome": true},
		{"id": "10L.3", "key": "FLOW_10L_3", "pos": Vector2(0.2, 0.48), "outcome": true},
	]
	c.edges = [["dig", "listen"], ["listen", "meet"], ["meet", "10L.1"], ["meet", "10L.2"], ["dig", "10L.3"], ["dig", "10L.2"]]
	c.taken["dig"] = true
	if _heard:
		c.taken["listen"] = true
	if _progress >= GOAL:
		c.taken["meet"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH10L_STATS") % [_progress * 2, int(ceil(maxf(_candle, 0.0))), GameState.paradox],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW10L_NEXT_1") if _outcome == "10L.1" else tr("UI_FLOW10L_NEXT_2"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	hud.set_prompt(tr("UI_PROMPT10L_FACE") if (id == "face" and phase == "free" and not _busy) else "")


func _on_interact(id: String) -> void:
	if id == "face":
		await _work()
		_on_focus(player.focus_id)


func _auto() -> void:
	var plan: Array
	match GameState.autotest_variant:
		"collapse":
			plan = [0, 0, 0]
		_:
			plan = [0, 0, 1, 0, 2, 0, 1, 0, 0, 1, 0]
	for a in plan:
		if _outcome != "":
			break
		await _work(a)


# ================================================================ yardımcılar

func _dr(key: String) -> void:
	dragan.talking = true
	await hud.say("SPK_MINER", key)
	dragan.talking = false


func _g(key: String) -> void:
	grant.talking = true
	await hud.say("SPK_GRANT", key)
	grant.talking = false


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "10L.1", "collapse": "10L.3", "retreat": "10L.2", "leb": "10L.1", "next": "10L.1"}[v]
	var ok: bool = _outcome == expected and GameState.chapter_outcomes.get(10, "") == _outcome
	if v == "":
		ok = ok and _heard
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=10l variant=%s outcome=%s progress=%d candle=%.1f heard=%s" % ["PASS" if ok else "FAIL", v, _outcome,
		_progress, _candle, str(_heard)])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(file_name: String) -> void:
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(file_name))
	print("shot: ", file_name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	for i in 4:
		_add_segment(i + 1, i != 2)
	_progress = 4
	_face.position.z = -(_progress + 1) * SEG - 0.2
	player.global_position = Vector3(0, 0.1, -_progress * SEG + 1.2)
	player.face(_face.global_position + Vector3(0, 1.2, 0))
	dragan.position = Vector3(0.7, 0, -_progress * SEG + 2.6)
	_candle = 7.0
	_update_objective()
	await get_tree().create_timer(0.8).timeout
	hud.bark("SPK_MINER", "D10L_D_HEARD", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c10l_01_lagim.png")
	hud.set_objective("")
	hud.set_chase("", 0.0)
	_face.visible = false
	for i in [5, 6]:
		_add_segment(i, true)
	grant.visible = true
	player.global_position = Vector3(0, 0.1, -SEG * GOAL - 0.6)
	player.face(grant.global_position + Vector3(0, 1.5, 0))
	grant.look_target = player
	hud.bark("SPK_GRANT", "D10L_G_MEET_2", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c10l_02_karsi_lagim.png")
	get_tree().quit()
