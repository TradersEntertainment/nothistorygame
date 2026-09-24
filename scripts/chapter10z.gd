extends Node3D
## Bölüm 10Z — Ziyafet (Tolga · 25 Nisan 1453). CHAPTERS Bölüm 10, STORY_BRANCHES Son 8.
##
## 9.1'de Kadri'nin teklifi kabul edildi: Sultan'ın ziyafetini Tolga pişirecek.
##   1. Menü: Tolga modern yemek önerir, her biri tarihe takılır (domates ve patates Amerika'dan gelir,
##      acı biber de yoktur). Sonunda dönemin malzemeleriyle üç tabak seçilir.
##   2. Ocak: üç tabak, ısı çubuğu (yeşilde dur). Kırmızı = yandı. Her tabaktan sonra Kadri'nin "denetimi".
##      🥜 leblebi gizli malzeme olarak eklenebilir.
##   3. İki tabak yanarsa mutfak alev alır, havaya patlamış leblebi yağar → 10Z.2 (Paradoks +30)
##      Yoksa Fatih mutfağa gelir, üçüncü tabağı tadar: "Bunu kim pişirdi?" → 10Z.1 (W7 Sultan'ın Sofrası)
##   --autotest[=fire|noleb|next]   (varsayılan: 10Z.1)

const KITCHEN := Vector3(-13.0, 0.0, -8.0)
const STOVES := [Vector3(-14.8, 0.0, -8.8), Vector3(-13.0, 0.0, -8.8), Vector3(-11.2, 0.0, -8.8)]
const TOLGA_AT := Vector3(-13.0, 0.0, -5.6)
const KADRI_AT := Vector3(-15.6, 0.0, -6.6)
const DOOR := Vector3(-8.0, 0.0, -4.0)

var day: CampDay
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _good := 0
var _burnt := 0
var _leblebi := false
var _menu: Array[int] = []
var kadri: Person
var fatih: Person


func _ready() -> void:
	GameState.snapshot(10)
	_apply_autotest_setup()
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	player.show_remote(true)
	day = CampDay.new()
	add_child(day)
	if day.ring_node:
		day.ring_node.queue_free()
	day.goat.chase = null
	kadri = day.kadri
	kadri.position = KADRI_AT
	kadri.look_target = player
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "turban", "mustache": true, "robe": Color("c8323a"),
		"hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.scale = Vector3(1.06, 1.06, 1.06)
	fatih.visible = false
	add_child(fatih)
	Props.box(fatih, Vector3(0.06, 1.1, 0.02), Vector3(0, 0.95, 0.25), Color("d8b040"))
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	GameState.chapter_outcomes[9] = "9.1"
	GameState.chapter_outcomes[6] = "6a.1"
	if GameState.autotest_variant == "noleb":
		GameState.bag.erase("chickpeas")
	elif not "chickpeas" in GameState.bag:
		GameState.bag.append("chickpeas")


func _d(sec: float) -> float:
	return 0.05 if GameState.autotest else sec


func _wait(sec: float) -> void:
	await get_tree().create_timer(_d(sec)).timeout


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH10Z_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH10Z_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = TOLGA_AT + Vector3(0, 0.1, 0)
	player.face(kadri.global_position + Vector3(0, 1.5, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _k("D10Z_K_01")
	await _t("D10Z_T_02")
	await _k("D10Z_K_03")
	await _menu_planning()
	await _cooking()
	if _burnt >= 2:
		await _fire()
	else:
		await _feast()
	await _end_chapter()


# ---------------------------------------------------------------- menü: tarih dersi

func _menu_planning() -> void:
	hud.set_objective(tr("UI_OBJ10Z_MENU"))
	# Üç ders: domates, patates, acı biber. Modern öneriler her seferinde tarihe takılır.
	for course in ["SOUP", "MAIN", "SWEET"]:
		await _k("D10Z_K_ASK_" + course)
		var tries := 0
		while true:
			var keys := ["UI_CH10Z_%s_MODERN" % course, "UI_CH10Z_%s_OLD_1" % course, "UI_CH10Z_%s_OLD_2" % course]
			var pick := 0 if tries == 0 else 1
			var c := await hud.choose(keys, 0.0, pick)
			if c <= 0:
				await _t("D10Z_T_%s_MODERN" % course)
				await _k("D10Z_K_%s_NO" % course)
				tries += 1
				continue
			await _k("D10Z_K_%s_OK_%d" % [course, c])
			_menu.append(c)
			break
	GameState.flags["ch10z_menu"] = _menu
	hud.set_objective("")
	await _t("D10Z_T_MENU_DONE")


# ---------------------------------------------------------------- ocak

func _cooking() -> void:
	await _k("D10Z_K_STOVE")
	var meter := KickMeter.new()
	hud.add_child(meter)
	var vp := get_viewport().get_visible_rect().size
	meter.position = Vector2((vp.x - meter.size.x) / 2.0, vp.y * 0.12)
	var v := GameState.autotest_variant
	for i in 3:
		var stove: Vector3 = STOVES[i]
		player.face(stove + Vector3(0, 1.1, 0))
		hud.set_objective(tr("UI_OBJ10Z_COOK") % (i + 1))
		meter.label_text = tr("UI_CH10Z_HEAT")
		meter.visible = true
		var t := randf() * 0.2
		var val := 0.0
		var auto_at := 0.93 if (v == "fire" and i < 2) else 0.7
		var steam := Vfx.steam(self, stove + Vector3(0, 1.2, 0))
		while true:
			t += get_process_delta_time()
			val = pingpong(t * (0.6 + i * 0.2), 1.0)
			meter.value = val
			if GameState.autotest and absf(val - auto_at) < 0.05:
				break
			if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("kick"):
				break
			await get_tree().process_frame
		meter.flash = 1.0
		steam.queue_free()
		await _wait(0.2)
		meter.visible = false
		match KickMeter.zone(val):
			"sweet":
				_good += 1
				await _k("D10Z_K_TASTE_OK_%d" % (i + 1))
			"weak":
				await _k("D10Z_K_TASTE_RAW")
			_:
				_burnt += 1
				Vfx.dust(self, stove + Vector3(0, 1.3, 0), 0.5)
				await _k("D10Z_K_TASTE_BURNT" if _burnt == 1 else "D10Z_K_TASTE_BURNT2")
		if _burnt >= 2:
			break
		# Kadri'nin denetimi: her tadımda fikir değiştirir
		await _k("D10Z_K_CRIT_%d" % (i + 1))
		var keys := ["UI_CH10Z_CRIT_YES", "UI_CH10Z_CRIT_FUSION"]
		if "chickpeas" in GameState.bag and not _leblebi:
			keys.append("UI_CH10Z_CRIT_LEBLEBI")
		var c := await hud.choose(keys, 0.0, keys.size() - 1 if i == 1 else 0)
		match keys[maxi(c, 0)]:
			"UI_CH10Z_CRIT_LEBLEBI":
				_leblebi = true
				GameState.flags["leblebi_given"] = true
				await _t("D10Z_T_LEBLEBI")
				await _k("D10Z_K_LEBLEBI")
			"UI_CH10Z_CRIT_FUSION":
				await _t("D10Z_T_FUSION")
				await _k("D10Z_K_FUSION")
			_:
				await _t("D10Z_T_YES")
				await _k("D10Z_K_YES_%d" % (i + 1))
	meter.queue_free()
	hud.set_objective("")


# ---------------------------------------------------------------- sonuçlar

## 10Z.2: kazan alev alır, patlamış leblebi yağar. Nihat'ın paradoks göstergesi zıplar.
func _fire() -> void:
	var stove: Vector3 = STOVES[1]
	player.face(stove + Vector3(0, 1.4, 0))
	await _k("D10Z_K_FIRE_1")
	if ResourceLoader.exists("res://assets/audio/sfx/explosion_small.ogg"):
		Audio.sfx("explosion_small", 0.0)
	else:
		Audio.sfx("cannon", -4.0, 1.4)
	Vfx.explosion(self, stove + Vector3(0, 1.2, 0), 0.4)
	Vfx.popcorn(self, stove + Vector3(0, 1.5, 0))
	player.shake(0.5)
	await _t("D10Z_T_FIRE_2")
	kadri.emote("facepalm")
	await _k("D10Z_K_FIRE_3")
	for i in 3:
		Vfx.dust(self, STOVES[i] + Vector3(0, 1.0, 0), 0.9)
	await _wait(0.8)
	await hud.say("SPK_HIKMET", "D10Z_H_FIRE")
	await _t("D10Z_T_FIRE_4")
	GameState.paradox += 30
	GameState.flags["route_ch12"] = "A"
	GameState.flags["kitchen_fire"] = true
	_outcome = "10Z.2"


## 10Z.1: akşam, ziyafet. Fatih mutfağa gelir.
func _feast() -> void:
	await hud.fade_to(1.0, 0.8)
	day.make_night()
	await hud.card([[tr("UI_CH10Z_EVENING"), 30, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	player.global_position = TOLGA_AT + Vector3(0.6, 0.1, 0.4)
	player.face(DOOR + Vector3(0, 1.6, 0))
	await hud.fade_to(0.0, 0.8)
	await _k("D10Z_K_WAIT")
	await _t("D10Z_T_WAIT")
	fatih.visible = true
	fatih.position = DOOR + Vector3(4.0, 0, 1.5)
	var tw := create_tween()
	tw.tween_property(fatih, "position", DOOR + Vector3(-1.2, 0, -0.6), _d(2.0))
	await tw.finished
	fatih.look_target = player
	player.face(fatih.global_position + Vector3(0, 1.6, 0))
	await _t("D10Z_T_ENTER")
	await _f("D10Z_F_01")
	await _wait(1.2)
	await _f("D10Z_F_TASTE_%s" % ("LEB" if _leblebi else ("GOOD" if _good >= 2 else "OK")))
	await _f("D10Z_F_WHO")
	await hud.say("SPK_KADRI", "D10Z_BOTH")
	await _f("D10Z_F_STAY")
	await _t("D10Z_T_TITLE")
	await _k("D10Z_K_TITLE")
	await _t("D10Z_T_TITLE_2")
	await hud.say("SPK_HIKMET", "D10Z_H_RADIO")
	await _t("D10Z_T_RADIO")
	GameState.flags["world10"] = "W7"
	GameState.flags["merak"] = int(GameState.flags.get("merak", 0)) + 1
	GameState.paradox += 10
	_outcome = "10Z.1"


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	GameState.set_outcome(10, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=10z -> 11 outcome=%s" % _outcome)
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
	c.title_text = tr("UI_FLOW10Z_TITLE")
	c.nodes = [
		{"id": "menu", "key": "FLOW10Z_MENU", "pos": Vector2(0.2, 0.16)},
		{"id": "stove", "key": "FLOW10Z_STOVE", "pos": Vector2(0.5, 0.16)},
		{"id": "leb", "key": "FLOW10Z_LEBLEBI", "pos": Vector2(0.8, 0.16)},
		{"id": "10Z.1", "key": "FLOW_10Z_1", "pos": Vector2(0.3, 0.46), "outcome": true},
		{"id": "10Z.2", "key": "FLOW_10Z_2", "pos": Vector2(0.7, 0.46), "outcome": true},
	]
	c.edges = [["menu", "stove"], ["stove", "leb"], ["stove", "10Z.1"], ["stove", "10Z.2"], ["leb", "10Z.1"]]
	for id in ["menu", "stove", _outcome]:
		c.taken[id] = true
	if _leblebi:
		c.taken["leb"] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH10Z_STATS") % [_good, _burnt, GameState.paradox],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW10Z_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ yardımcılar

func _k(key: String) -> void:
	kadri.talking = true
	await hud.say("SPK_KADRI", key)
	kadri.talking = false


func _f(key: String) -> void:
	fatih.talking = true
	await hud.say("SPK_FATIH", key)
	fatih.talking = false


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "10Z.1", "fire": "10Z.2", "noleb": "10Z.1", "next": "10Z.1"}[v]
	var ok: bool = _outcome == expected and GameState.chapter_outcomes.get(10, "") == _outcome
	if v == "":
		ok = ok and _leblebi and _menu.size() == 3
	if v == "noleb":
		ok = ok and not _leblebi
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=10z variant=%s outcome=%s good=%d burnt=%d leblebi=%s" % [
		"PASS" if ok else "FAIL", v, _outcome, _good, _burnt, str(_leblebi)])
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
	await get_tree().create_timer(0.8).timeout
	player.global_position = TOLGA_AT + Vector3(0, 0.1, 0)
	player.face(kadri.global_position + Vector3(0, 1.4, 0))
	kadri.talking = true
	hud.bark("SPK_KADRI", "D10Z_K_MAIN_NO", 30.0)
	hud.choose(["UI_CH10Z_MAIN_MODERN", "UI_CH10Z_MAIN_OLD_1", "UI_CH10Z_MAIN_OLD_2"], 0.0, 0)
	await get_tree().create_timer(0.5).timeout
	await _shot("c10z_01_menu.png")
	hud.choose_cancel()
	player.face(STOVES[1] + Vector3(0, 1.3, 0))
	Vfx.explosion(self, STOVES[1] + Vector3(0, 1.2, 0), 0.4)
	Vfx.popcorn(self, STOVES[1] + Vector3(0, 1.5, 0))
	hud.bark("SPK_KADRI", "D10Z_K_FIRE_3", 30.0)
	await get_tree().create_timer(0.35).timeout
	get_tree().paused = true
	await _shot("c10z_02_yangin.png")
	get_tree().quit()
