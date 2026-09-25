extends Node3D
## Bölüm 13 — Dönüş Penceresi (Hikmet · 2026, pazartesi 07:15). CHAPTERS Bölüm 13, §4.5.
##
## Servise 15 dakika var. Hikmet pencereyi açar; kontrol son saniyelerde Tolga'ya geçer ve Tolga
## Telsiz-Kumanda'nın kırmızı düğmesini basılı tutmalıdır. Pencerenin süresi Telsiz Bağı'na bağlıdır
## (Bağ 0: 3 sn · 5: 12 sn).
## Versiyonlar:
##   garaj   makine Hikmet'te (8.1/8.2): ⏱ zaman frekansı, kolu çek, pencere
##   depo    makineye el konuldu (8.3): sahte kartla Büro deposuna gir (Nihat katıldıysa kapı açık)
##   1453    Hikmet 1453'te (8.4): Urban'ın atölyesinde, topun gücüyle; birlikte dön ya da Hikmet kalsın
##   W4      Fatih Telsiz-Kumanda'yı tamir etti (12.4) ya da Mühendisler Meclisi (12.6): kutlama
##   13.1 döndü (T1) · 13.2 pencere kaçtı (T2) · 13.3 yanlış yıl (T3, 1977 düğünü)
##   13.4 Hikmet ile birlikte döndü · 13.5 Hikmet 1453'te kaldı
##   --autotest[=miss|wrong|depot|together|stay|w4|meclis|kitchen]   (varsayılan: 13.1)

const TUNE_TIME := 14.0
const HOLD_RED := 1.2

var garage: Garage
var bureau: Bureau
var hall: OtagHall
var camp: CampDay
var player: Player
var hud: Hud
var version := "garage"
var _outcome := ""
var _wrong_year := false
var _window := 6.0
var hikmet_npc: Hikmet


func _ready() -> void:
	GameState.snapshot(13)
	_apply_autotest_setup()
	var ch8: String = GameState.chapter_outcomes.get(8, "8.1")
	var ch12: String = GameState.chapter_outcomes.get(12, "12.1")
	if ch12 == "12.6":
		version = "meclis"
	elif ch12 == "12.4":
		version = "w4"
	elif ch8 == "8.4":
		version = "1453"
	elif ch8 == "8.3":
		version = "depot"
	_window = 3.0 + GameState.telsiz_bag * 1.8
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "countdown"
	player = Player.new()
	player.hand_style = "tolga" if version in ["1453", "meclis"] else "hikmet"
	add_child(player)
	player.frozen = true
	hud.set_fez(version in ["1453", "meclis"] and GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	match GameState.autotest_variant:
		"wrong":
			GameState.chapter_outcomes[8] = "8.2"
		"depot":
			GameState.chapter_outcomes[8] = "8.3"
			GameState.flags["machine"] = "confiscated"
		"together", "stay":
			GameState.chapter_outcomes[8] = "8.4"
		"w4":
			GameState.chapter_outcomes[12] = "12.4"
		"meclis":
			GameState.chapter_outcomes[8] = "8.4"
			GameState.chapter_outcomes[12] = "12.6"
		"kitchen":
			GameState.chapter_outcomes[12] = "12.5"


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH13_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH13_SUB_1453" if version in ["1453", "meclis"] else "UI_CH13_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	match version:
		"garage":
			await _garage_version()
		"depot":
			await _depot_version()
		"1453":
			await _h3_version()
		"w4":
			await _w4_version()
		"meclis":
			await _meclis_version()
	await _end_chapter()


# ---------------------------------------------------------------- garaj

func _load_garage(spin := 0.0) -> void:
	garage = Garage.new()
	add_child(garage)
	garage.spin = spin
	garage.panel_screen.text = "----"
	for id in garage.items:
		(garage.items[id]["body"] as StaticBody3D).collision_layer = 0
		if id in GameState.bag:
			garage.set_item_visible(id, false)


func _garage_version() -> void:
	_load_garage()
	player.global_position = Garage.SPAWN_POS + Vector3(0, 0.05, 0)
	player.face(Garage.PLATFORM_POS + Vector3(0, 1.3, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _h("D13_H_01")
	await _h("D13_H_02")
	player.face(garage.panel_node.global_position + Vector3(0, 1.2, 0))
	await _open_window("D13_H_TUNE")
	await _tolga_moment()


## Frekans + kol: pencere açılır. 8.2'de (parça eksik) frekans daha zor; kaçarsa yanlış yıl.
func _open_window(line: String) -> void:
	await _h(line)
	var parts_missing: bool = GameState.chapter_outcomes.get(8, "") == "8.2"
	var ok := await _tune(TUNE_TIME * (0.6 if parts_missing else 1.0), GameState.autotest_variant != "wrong")
	if garage:
		garage.panel_screen.text = "1453" if ok else "1977"
	if not ok:
		_wrong_year = true
		await _h("D13_H_WRONG")
	else:
		await _h("D13_H_TUNED")
	await _h("D13_H_LEVER")
	await _hold_qte("UI_CH13_LEVER", "interact", 1.5, true)
	if garage:
		var tw := create_tween()
		tw.tween_property(garage, "spin", 5.0, 1.5)
		garage.machine_light.light_energy = 2.5
	player.shake(0.5)
	await _h("D13_H_OPEN")


## Kontrol Tolga'ya geçer: pencere açıkken kırmızı düğmeyi basılı tut.
func _tolga_moment() -> void:
	await hud.fade_to(1.0, 0.4, Color.WHITE)
	if garage:
		garage.queue_free()
		garage = null
	if bureau:
		bureau.queue_free()
		bureau = null
	var kitchen: bool = GameState.chapter_outcomes.get(12, "") == "12.5"
	if kitchen:
		camp = CampDay.new()
		add_child(camp)
		camp.goat.chase = null
		player.global_position = CampDay.KITCHEN_SPAWN + Vector3(0, 0.05, 0)
		player.face(camp.kadri.global_position + Vector3(0, 1.4, 0))
	else:
		hall = OtagHall.new()
		add_child(hall)
		player.global_position = OtagHall.TOLGA_SPOT + Vector3(0, 0.05, 0)
		player.face(hall.fatih.global_position + Vector3(0, 1.6, 0))
	_switch_hand("tolga")
	hud.set_fez(GameState.flags.get("fez", true))
	await hud.card([[tr("UI_CH13_SWITCH"), 26, Color("2a2a30")]], 0.8)
	hud.clear_card()
	await hud.fade_to(0.0, 0.4, Color.WHITE)
	hud.bark("SPK_HIKMET", "D13_H_PRESS", 3.0)
	var pressed := await _red_button()
	if pressed:
		await _t("D13_T_PRESSED")
		if _wrong_year:
			await _wrong_year_scene()
			_outcome = "13.3"
		else:
			await _return_scene()
			_outcome = "13.1"
	else:
		await _t("D13_T_MISSED")
		await _say("SPK_HIKMET", "D13_H_MISSED")
		if kitchen:
			await _say("SPK_KADRI", "D13_K_MISSED")
		else:
			await hud.say("SPK_FATIH", "D13_F_MISSED")
		GameState.flags["tolga_fate"] = "T2"
		_outcome = "13.2"


## Pencere geri sayımı; kırmızı düğme HOLD_RED saniye basılı tutulmalı.
func _red_button() -> bool:
	var left := _window
	var hold := 0.0
	var auto_press := GameState.autotest_variant not in ["miss", "gidak"]
	hud.set_qte(tr("UI_CH13_PRESS"))
	while left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		hud.set_chase(tr("UI_CH13_WINDOW") % ceili(left), left / _window)
		var down := Input.is_action_pressed("red_button") or (GameState.autotest and auto_press and left < _window - 0.5)
		if down:
			hold += dt
			player.press_red(hold / HOLD_RED)
		else:
			hold = maxf(0.0, hold - dt * 2.0)
			player.press_red(0.0)
		hud.set_red_progress(hold / HOLD_RED)
		if hold >= HOLD_RED:
			break
	hud.set_qte("")
	hud.set_chase("", 0.0)
	hud.set_red_progress(0.0)
	player.press_red(0.0)
	return hold >= HOLD_RED


func _return_scene() -> void:
	await hud.fade_to(1.0, 0.6, Color.WHITE)
	_clear_levels()
	_load_garage(1.0)
	player.global_position = Garage.PLATFORM_POS + Vector3(0, 0.12, 0)
	player.face(Garage.SPAWN_POS + Vector3(0, 1.4, 0))
	hikmet_npc = Hikmet.new()
	hikmet_npc.position = Garage.SPAWN_POS + Vector3(0, 0, -0.3)
	hikmet_npc.look_target = player
	add_child(hikmet_npc)
	await hud.fade_to(0.0, 1.2, Color.WHITE)
	var tw := create_tween()
	tw.tween_property(garage, "spin", 0.0, 2.0)
	await _say("SPK_HIKMET", "D13_H_BACK_1")
	await _t("D13_T_BACK_2")
	await _say("SPK_HIKMET", "D13_H_BACK_3")
	await _t("D13_T_BACK_4")
	GameState.flags["tolga_fate"] = "T1"


func _wrong_year_scene() -> void:
	await hud.fade_to(1.0, 0.6, Color.WHITE)
	_clear_levels()
	await hud.card([[tr("UI_CH13_1977"), 34, Color("2a2a30")], [tr("UI_CH13_1977_SUB"), 20, Color(0.2, 0.2, 0.25, 0.8)]], 2.6)
	hud.clear_card()
	await _t("D13_T_1977_1")
	await _say("SPK_HIKMET", "D13_H_1977_2")
	await _t("D13_T_1977_3")
	GameState.flags["tolga_fate"] = "T3"


# ---------------------------------------------------------------- depo (8.3)

func _depot_version() -> void:
	bureau = Bureau.new()
	add_child(bureau)
	player.global_position = Vector3(0.0, 0.05, Bureau.DEPOT_Z0 + 2.5)
	player.face(bureau.riza.global_position + Vector3(0, 1.4, 0))
	bureau.riza.look_target = player
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _h("D13_H_DEPOT_1")
	var nihat_open: bool = GameState.flags.get("nihat_joined", false) or GameState.flags.get("nihat_rulefree", false) \
		or int(GameState.flags.get("hn_rel", 0)) >= 2
	if nihat_open:
		await _say("SPK_RIZA", "D13_R_OPEN")
		await _h("D13_H_OPEN_THANKS")
	else:
		await _say("SPK_RIZA", "D13_R_CARD")
		await _h("D13_H_CARD")
		await _say("SPK_RIZA", "D13_R_CARD_OK")
	await _h("D13_H_FOUND")
	await _open_window("D13_H_TUNE_DEPOT")
	await _tolga_moment()


# ---------------------------------------------------------------- 1453 (8.4)

func _h3_version() -> void:
	camp = CampDay.new()
	add_child(camp)
	camp.goat.chase = null
	hikmet_npc = Hikmet.new()
	hikmet_npc.position = CampDay.URBAN_POS + Vector3(2.0, 0, 1.4)
	hikmet_npc.look_target = player
	add_child(hikmet_npc)
	camp.urban.look_target = player
	player.global_position = CampDay.URBAN_POS + Vector3(3.2, 0.05, 4.2)
	player.face(hikmet_npc.global_position + Vector3(0, 1.4, 0))
	player.show_remote(true)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _say("SPK_HIKMET", "D13_H3_01")
	await _t("D13_T3_02")
	await _say("SPK_URBAN", "D13_U3_03")
	await _say("SPK_HIKMET", "D13_H3_TUNE")
	var ok := await _tune(TUNE_TIME, true)
	if not ok:
		await _say("SPK_HIKMET", "D13_H3_FAIL")
		_outcome = "13.2"
		return
	await _say("SPK_URBAN", "D13_U3_FIRE")
	await _hold_qte("UI_CH13_FIRE", "interact", 1.5, true)
	player.shake(1.0)
	await _say("SPK_HIKMET", "D13_H3_OPEN")
	# ⏱ Birlikte mi, Hikmet kalsın mı?
	await _say("SPK_URBAN", "D13_U3_ASK")
	var pick := 1 if GameState.autotest_variant == "stay" else 0
	var c := await hud.choose(["UI_CH13_TOGETHER", "UI_CH13_HE_STAYS"], 8.0, pick)
	if c == 1:
		await _t("D13_T3_STAY")
		await _say("SPK_HIKMET", "D13_H3_STAY")
	else:
		await _t("D13_T3_TOGETHER")
		await _say("SPK_HIKMET", "D13_H3_TOGETHER")
	var pressed := await _red_button()
	if not pressed:
		await _t("D13_T_MISSED")
		_outcome = "13.2"
		return
	if c == 1:
		await hud.fade_to(1.0, 0.8, Color.WHITE)
		await hud.card([[tr("UI_CH13_STAY_CARD"), 30, Color("2a2a30")], [tr("UI_CH13_STAY_SUB"), 20, Color(0.2, 0.2, 0.25, 0.8)]], 2.6)
		hud.clear_card()
		GameState.flags["hikmet_fate"] = "H3"
		GameState.flags["tolga_fate"] = "T1"
		_outcome = "13.5"
	else:
		await _return_together()
		_outcome = "13.4"


func _return_together() -> void:
	await hud.fade_to(1.0, 0.6, Color.WHITE)
	_clear_levels()
	_load_garage(1.0)
	player.global_position = Garage.PLATFORM_POS + Vector3(0.4, 0.12, 0)
	player.face(Garage.SPAWN_POS + Vector3(0, 1.4, 0))
	hikmet_npc = Hikmet.new()
	hikmet_npc.position = Garage.PLATFORM_POS + Vector3(-0.6, 0, 0.2)
	hikmet_npc.look_target = player
	add_child(hikmet_npc)
	await hud.fade_to(0.0, 1.2, Color.WHITE)
	var tw := create_tween()
	tw.tween_property(garage, "spin", 0.0, 2.0)
	await _say("SPK_HIKMET", "D13_H_TOG_1")
	await _t("D13_T_TOG_2")
	await _say("SPK_HIKMET", "D13_H_TOG_3")
	GameState.flags["hikmet_fate"] = "H1"
	GameState.flags["tolga_fate"] = "T1"


# ---------------------------------------------------------------- W4

func _w4_version() -> void:
	_load_garage(0.0)
	player.global_position = Garage.SPAWN_POS + Vector3(0, 0.05, 0)
	player.face(Garage.PLATFORM_POS + Vector3(0, 1.3, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _h("D13_W4_1")
	var tw := create_tween()
	tw.tween_property(garage, "spin", 4.0, 2.0)
	garage.machine_light.light_energy = 2.5
	garage.panel_screen.text = "1453"
	await _h("D13_W4_2")
	player.shake(0.6)
	await hud.fade_to(1.0, 0.5, Color.WHITE)
	var t := Person.new({"face": "tolga", "coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")})
	t.position = Garage.PLATFORM_POS + Vector3(0, 0.08, 0)
	t.rotation.y = PI
	add_child(t)
	await hud.fade_to(0.0, 0.8, Color.WHITE)
	var tw2 := create_tween()
	tw2.tween_property(garage, "spin", 0.0, 2.0)
	t.talking = true
	await _t("D13_W4_3")
	t.talking = false
	await _h("D13_W4_4")
	await _t("D13_W4_5")
	GameState.flags["tolga_fate"] = "T1"
	_outcome = "13.1"


func _meclis_version() -> void:
	# Fatih ile Hikmet makineyi birlikte tamir etti: ikisi birlikte döner
	await hud.fade_to(1.0, 0.1)
	await _return_together()
	await _say("SPK_HIKMET", "D13_MECLIS_1")
	await _t("D13_MECLIS_2")
	_outcome = "13.4"


# ================================================================ mini oyunlar

## Zaman frekansı (Bölüm 5'teki telsiz kadranı): A/D ile çevir, E'yi basılı tutup kilitle.
func _tune(seconds: float, auto_ok: bool) -> bool:
	var tuner := RadioTuner.new()
	tuner.label_text = tr("UI_CH13_TUNER")
	tuner.hint_text = tr("UI_TUNER_HINT")
	tuner.target = [92.6, 104.5, 99.8][randi() % 3]
	hud.add_child(tuner)
	var vp := get_viewport().get_visible_rect().size
	tuner.position = Vector2((vp.x - tuner.size.x) / 2.0, vp.y * 0.1)
	var left := seconds
	var ok := false
	var prev_music := Audio.current_music()
	Audio.music("countdown", 0.5)
	while left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		tuner.time_left = clampf(left / seconds, 0.0, 1.0)
		var dir := Input.get_axis("move_left", "move_right")
		if GameState.autotest:
			dir = 0.0
			if auto_ok:
				tuner.freq = tuner.target
		tuner.freq = clampf(tuner.freq + dir * 4.0 * dt, 88.0, 108.0)
		var holding := Input.is_action_pressed("interact") or (GameState.autotest and auto_ok)
		if holding and tuner.strength() > 0.8:
			tuner.lock = minf(1.0, tuner.lock + dt * 1.2)
		else:
			tuner.lock = maxf(0.0, tuner.lock - dt * 0.6)
		if tuner.lock >= 1.0:
			ok = true
			break
	tuner.queue_free()
	Audio.music(prev_music, 1.0)
	return ok


## Basılı tutma: kol çekmek, topu ateşlemek.
func _hold_qte(label_key: String, action: String, seconds: float, auto_ok: bool) -> void:
	hud.set_qte(tr(label_key))
	var hold := 0.0
	while hold < seconds:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		if Input.is_action_pressed(action) or (GameState.autotest and auto_ok):
			hold += dt
		else:
			hold = maxf(0.0, hold - dt)
		hud.set_red_progress(hold / seconds)
	hud.set_red_progress(0.0)
	hud.set_qte("")


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	hud.set_objective("")
	# Gizli Bölüm 16: pencere kaçtı ama Sinerji her şeyi gördü (Bizans yolu, 4b'de Tolga'ya takılan tavuk)
	if _outcome == "13.2" and (GameState.flags.get("sinerji", false) or GameState.autotest_variant == "gidak"):
		GameState.set_outcome(13, _outcome)
		await hud.fade_to(1.0, 0.6)
		await hud.card([[tr("UI_CH13_GIDAK"), 30, Color("f2e6c9")], [tr("UI_CH13_GIDAK_SUB"), 18, Color(1, 1, 1, 0.75)]], 2.6)
		hud.clear_card()
		if GameState.autotest:
			print("AUTOTEST chapter=13 -> 16 outcome=%s" % _outcome)
			GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter16.tscn")
		return
	GameState.set_outcome(13, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=13 -> 14 outcome=%s" % _outcome)
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
	c.title_text = tr("UI_FLOW13_TITLE")
	c.nodes = [
		{"id": "garage", "key": "FLOW13_GARAGE", "pos": Vector2(0.14, 0.15)},
		{"id": "depot", "key": "FLOW13_DEPOT", "pos": Vector2(0.38, 0.15)},
		{"id": "1453", "key": "FLOW13_1453", "pos": Vector2(0.62, 0.15)},
		{"id": "w4", "key": "FLOW13_W4", "pos": Vector2(0.86, 0.15)},
		{"id": "window", "key": "FLOW13_WINDOW", "pos": Vector2(0.38, 0.36)},
		{"id": "13.1", "key": "FLOW_13_1", "pos": Vector2(0.12, 0.6), "outcome": true},
		{"id": "13.2", "key": "FLOW_13_2", "pos": Vector2(0.32, 0.72), "outcome": true},
		{"id": "13.3", "key": "FLOW_13_3", "pos": Vector2(0.52, 0.6), "outcome": true},
		{"id": "13.4", "key": "FLOW_13_4", "pos": Vector2(0.72, 0.72), "outcome": true},
		{"id": "13.5", "key": "FLOW_13_5", "pos": Vector2(0.9, 0.6), "outcome": true},
	]
	c.edges = [["garage", "window"], ["depot", "window"], ["window", "13.1"], ["window", "13.2"], ["window", "13.3"],
		["1453", "13.4"], ["1453", "13.5"], ["1453", "13.2"], ["w4", "13.1"], ["w4", "13.4"]]
	c.taken[{"meclis": "w4"}.get(version, version)] = true
	if version in ["garage", "depot"]:
		c.taken["window"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH13_STATS") % [GameState.telsiz_bag, _window],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW13_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ yardımcılar

func _clear_levels() -> void:
	for n in [garage, bureau, hall, camp, hikmet_npc]:
		if n and is_instance_valid(n):
			n.queue_free()
	garage = null
	bureau = null
	hall = null
	camp = null
	hikmet_npc = null


func _switch_hand(style: String) -> void:
	player.hand_style = style
	player.hand.queue_free()
	player.scanner_screen = null
	player._hand_shown = false
	player._build_hand()
	player.show_remote(true)


func _h(key: String) -> void:
	await hud.say("SPK_HIKMET", key)


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _say(speaker: String, key: String) -> void:
	if speaker == "SPK_HIKMET" and hikmet_npc:
		hikmet_npc.talking = true
	await hud.say(speaker, key)
	if hikmet_npc and is_instance_valid(hikmet_npc):
		hikmet_npc.talking = false


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var expected: String = {"": "13.1", "miss": "13.2", "wrong": "13.3", "depot": "13.1", "together": "13.4",
		"stay": "13.5", "w4": "13.1", "meclis": "13.4", "kitchen": "13.1", "next": "13.1"}[GameState.autotest_variant]
	var ok := _outcome == expected
	if GameState.chapter_outcomes.get(13, "") != _outcome:
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=13 variant=%s version=%s outcome=%s window=%.1f tolga=%s hikmet=%s" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, version, _outcome, _window,
		GameState.flags.get("tolga_fate", ""), GameState.flags.get("hikmet_fate", "")])
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
	_load_garage(3.0)
	garage.machine_light.light_energy = 2.5
	garage.panel_screen.text = "1453"
	player.global_position = Garage.SPAWN_POS + Vector3(0.6, 0.05, 0)
	player.face(Garage.PLATFORM_POS + Vector3(0, 1.3, 0))
	await get_tree().create_timer(0.8).timeout
	hud.bark("SPK_HIKMET", "D13_H_OPEN", 30.0)
	hud.set_qte(tr("UI_CH13_LEVER"))
	hud.set_red_progress(0.7)
	await _shot("c13_01_pencere.png")
	hud.set_qte("")
	hud.set_red_progress(0.0)
	_clear_levels()
	hall = OtagHall.new()
	add_child(hall)
	_switch_hand("tolga")
	hud.set_fez(true)
	player.global_position = OtagHall.TOLGA_SPOT + Vector3(0, 0.05, 0)
	player.face(hall.fatih.global_position + Vector3(0, 1.6, 0))
	await get_tree().create_timer(0.6).timeout
	hud.bark("SPK_HIKMET", "D13_H_PRESS", 30.0)
	hud.set_qte(tr("UI_CH13_PRESS"))
	hud.set_chase(tr("UI_CH13_WINDOW") % 5, 0.45)
	hud.set_red_progress(0.6)
	player.press_red(0.6)
	await _shot("c13_02_dugme.png")
	get_tree().quit()
