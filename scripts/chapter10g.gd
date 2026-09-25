extends Node3D
## Bölüm 10G — Galata (Tolga · 25 Nisan 1453). CHAPTERS Bölüm 10, STORY_BRANCHES Son 7.
##
## 9.3'te Çandarlı'nın mühürlü mektubu Galata'ya götürülüyor: "Ceneviz tüccarı Lomellino'yu bul."
## Galata tarafsızdır; herkes iki tarafa da mal satar. Herkes Tolga'yı başka birine yollar:
##   balıkçı → şarapçı → noter → "Bu mektup Venedik kaptanına gider, gemi çan çalınca kalkar!"
## Noterden sonra ⏱ gemi çanı: iskeleye yetiş.
##   İskelede: ⏱ "Gemiye bin" → 10G.1 Venedik'e Elçi (W6): gemi Haliç'ten çıkarken burunda Fatih,
##             Tolga'yla göz göze gelir, başını hafifçe eğer. Bölüm 11 atlanır (Nihat izini kaybeder).
##             "Mektubu Fatih'e götür" → 10G.2 (Merak +1, dürüstlük) → 11 → 12
##   Gemi kaçırılırsa mektup yine Fatih'e gider (10G.2).
##   --autotest[=fatih|late|next]   (varsayılan: 10G.1)

const BELL_TIME := 45.0
const SPEAKERS := {"fishmonger": "SPK_FISHMONGER", "wine": "SPK_WINE", "notary": "SPK_NOTARY", "double": "SPK_DOUBLE",
	"captain": "SPK_CAPTAIN"}

var galata: Galata
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _busy := false
var _step := 0                  # 0 balıkçı, 1 şarapçı, 2 noter, 3 kaptan
var _bell := -1.0
var _sailing := false
var _talked: Dictionary = {}


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
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	player.show_remote(true)
	galata = Galata.new()
	add_child(galata)
	for id in galata.npcs:
		(galata.npcs[id] as Person).look_target = player
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	GameState.chapter_outcomes[9] = "9.3"
	GameState.chapter_outcomes[6] = "6a.4"
	GameState.flags["letter_route"] = "galata"


func _process(delta: float) -> void:
	if _bell >= 0.0 and phase == "free":
		_bell -= delta
		hud.set_chase(tr("UI_CH10G_BELL") % maxi(0, int(ceil(_bell))), 1.0 - _bell / BELL_TIME)
		if _bell <= 0.0:
			_bell = -1.0
			hud.set_chase("", 0.0)
			_missed()
	if _sailing:
		var v := Vector3(-3.2, 0, 1.1) * delta
		galata.ship.position += v
		player.global_position += v


func _d(sec: float) -> float:
	return 0.05 if GameState.autotest else sec


func _wait(sec: float) -> void:
	await get_tree().create_timer(_d(sec)).timeout


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH10G_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH10G_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = Galata.SPAWN + Vector3(0, 0.1, 0)
	player.face(Vector3(0, 1.6, -6.0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _t("D10G_T_01")
	await _t("D10G_T_02")
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
	var who: String = ["fishmonger", "wine", "notary", "captain"][clampi(_step, 0, 3)]
	hud.set_objective(tr("UI_OBJ10G_%d" % _step), galata.npcs.get(who))


# ---------------------------------------------------------------- sokak

func _talk(id: String) -> void:
	if _busy or phase != "free":
		return
	_busy = true
	player.frozen = true
	hud.set_prompt("")
	var p: Person = galata.npcs[id]
	player.face(p.global_position + Vector3(0, 1.5, 0))
	var spk: String = SPEAKERS[id]
	match id:
		"fishmonger":
			if _step == 0:
				await _say(spk, "D10G_F_1")
				await _t("D10G_T_F_2")
				await _say(spk, "D10G_F_3")
				_step = 1
			else:
				await _say(spk, "D10G_F_AGAIN")
		"wine":
			if _step == 1:
				await _say(spk, "D10G_W_1")
				var c := await hud.choose(["UI_CH10G_W_BUY", "UI_CH10G_W_INSURE", "UI_CH10G_W_ASK"], 0.0, 1)
				await _t("D10G_T_W_%d" % (maxi(c, 0) + 1))
				await _say(spk, "D10G_W_R%d" % (maxi(c, 0) + 1))
				await _say(spk, "D10G_W_2")
				_step = 2
			elif _step == 0:
				await _say(spk, "D10G_W_EARLY")
			else:
				await _say(spk, "D10G_W_AGAIN")
		"notary":
			if _step == 2:
				await _say(spk, "D10G_N_1")
				await _t("D10G_T_N_2")
				await _say(spk, "D10G_N_3")
				await _t("D10G_T_N_4")
				await _say(spk, "D10G_N_5")
				Audio.sfx("church_bell", -4.0)
				_step = 3
				_bell = BELL_TIME
			elif _step < 2:
				await _say(spk, "D10G_N_EARLY")
			else:
				await _say(spk, "D10G_N_AGAIN")
		"double":
			if not _talked.has(id):
				await _say(spk, "D10G_D_1")
				await _t("D10G_T_D_2")
				await _say(spk, "D10G_D_3")
			else:
				await _say(spk, "D10G_D_AGAIN")
		"captain":
			if _step < 3:
				await _say(spk, "D10G_C_EARLY")
			else:
				await _gangway()
	_talked[id] = true
	if phase == "free":
		_update_objective()
		player.frozen = false
	_busy = false


## İskelede: gemiye bin (10G.1) ya da mektubu Fatih'e götür (10G.2).
func _gangway() -> void:
	_bell = -1.0
	hud.set_chase("", 0.0)
	var cap: String = SPEAKERS["captain"]
	await _say(cap, "D10G_C_1")
	await _t("D10G_T_C_2")
	await _say(cap, "D10G_C_3")
	var pick := 1 if GameState.autotest_variant == "fatih" else 0
	var c := await hud.choose(["UI_CH10G_BOARD", "UI_CH10G_TO_FATIH"], 10.0, pick)
	if c == 1:
		await _t("D10G_T_TO_FATIH")
		await _say(cap, "D10G_C_TO_FATIH")
		await _to_fatih()
		return
	phase = "sailing"
	await _sail()


func _missed() -> void:
	if _busy or phase != "free":
		return
	_busy = true
	phase = "missed"
	player.frozen = true
	Audio.sfx("church_bell", -2.0)
	var tw := create_tween()
	tw.tween_property(galata.ship, "position", galata.ship.position + Vector3(-20.0, 0, 12.0), _d(6.0))
	player.face(galata.ship.global_position + Vector3(0, 3.0, 0))
	await _t("D10G_T_MISSED")
	await _say("SPK_CAPTAIN", "D10G_C_MISSED")
	await _t("D10G_T_MISSED_2")
	await _to_fatih()
	_busy = false


func _to_fatih() -> void:
	await hud.fade_to(1.0, 0.8)
	# Kart arka planda kalır: otağ sahnesi kurulmadan kara ekranda konuşulmasın
	await hud.card([[tr("UI_CH10G_BACK"), 28, Color("f2e6c9")], [tr("UI_CH10G_BACK_SUB"), 18, Color(1, 1, 1, 0.75)]], 2.8)
	await hud.say("SPK_FATIH", "D10G_F_LETTER")
	await _t("D10G_T_LETTER")
	hud.clear_card()
	GameState.flags["letter_route"] = "fatih"
	GameState.flags["merak"] = int(GameState.flags.get("merak", 0)) + 1
	phase = "done"
	_outcome = "10G.2"


## Gemi kalkar. Haliç'in ağzında, burunda Fatih.
func _sail() -> void:
	player.frozen = true
	await hud.fade_to(1.0, 0.5)
	player.gravity_on = false
	player.global_position = galata.ship.global_position + Vector3(-6.5, 2.5, 0.0)
	player.face(Galata.FATIH_POINT + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	_sailing = true
	Audio.sfx("church_bell", -6.0)
	await _say("SPK_CAPTAIN", "D10G_C_SAIL")
	await _t("D10G_T_SAIL")
	# Burnun önünden geçerken
	if GameState.autotest:
		galata.ship.position = Galata.FATIH_POINT + Vector3(18.0, Galata.WATER_Y, 12.0)
	else:
		# Oyuncu replikleri yavaş okursa gemi burnu geçmiş olabilir: o zaman beklemeden devam (kilitlenmesin)
		while galata.ship.global_position.distance_to(Galata.FATIH_POINT) > 34.0 \
				and (Galata.FATIH_POINT - galata.ship.global_position).dot(Vector3(-3.2, 0, 1.1)) > 0.0:
			player.face(Galata.FATIH_POINT + Vector3(0, 1.5, 0))
			await get_tree().process_frame
	galata.fatih.look_target = player
	player.face(galata.fatih.global_position + Vector3(0, 1.6, 0))
	await _t("D10G_T_FATIH_1")
	await _wait(1.2)
	var tw := create_tween()
	tw.tween_property(galata.fatih, "rotation:x", 0.18, _d(0.6))
	tw.tween_property(galata.fatih, "rotation:x", 0.0, _d(0.6))
	await tw.finished
	await _t("D10G_T_FATIH_2")
	await _wait(0.8)
	await _say("SPK_CAPTAIN", "D10G_C_VENICE")
	await _t("D10G_T_SEASICK")
	await hud.say("SPK_HIKMET", "D10G_H_RADIO")
	await _t("D10G_T_RADIO")
	_sailing = false
	GameState.flags["world10"] = "W6"
	GameState.paradox += 15
	# Nihat Tolga'yı bu gece bulamaz: Bölüm 11 atlanır
	GameState.chapter_outcomes[11] = "11.4"
	_outcome = "10G.1"


# ---------------------------------------------------------------- otomatik test

func _auto() -> void:
	for id in ["fishmonger", "wine", "double", "notary"]:
		await _talk(id)
	if GameState.autotest_variant == "late":
		_bell = 0.01
		while _outcome == "":
			await get_tree().process_frame
		return
	await _talk("captain")


# ================================================================ bölüm sonu

func _next_scene() -> String:
	return "res://scenes/chapter13.tscn" if _outcome == "10G.1" else "res://scenes/chapter11.tscn"


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
		print("AUTOTEST chapter=10g -> %s outcome=%s" % [_next_scene().get_file(), _outcome])
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file(_next_scene())
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file(_next_scene())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW10G_TITLE")
	c.nodes = [
		{"id": "fish", "key": "FLOW10G_FISH", "pos": Vector2(0.12, 0.16)},
		{"id": "wine", "key": "FLOW10G_WINE", "pos": Vector2(0.37, 0.16)},
		{"id": "notary", "key": "FLOW10G_NOTARY", "pos": Vector2(0.62, 0.16)},
		{"id": "bell", "key": "FLOW10G_BELL", "pos": Vector2(0.87, 0.16)},
		{"id": "10G.1", "key": "FLOW_10G_1", "pos": Vector2(0.3, 0.5), "outcome": true},
		{"id": "10G.2", "key": "FLOW_10G_2", "pos": Vector2(0.7, 0.5), "outcome": true},
	]
	c.edges = [["fish", "wine"], ["wine", "notary"], ["notary", "bell"], ["bell", "10G.1"], ["bell", "10G.2"]]
	for id in ["fish", "wine", "notary", "bell", _outcome]:
		c.taken[id] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH10G_STATS") % [int(GameState.flags.get("merak", 0)), GameState.paradox],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW10G_NEXT_1") if _outcome == "10G.1" else tr("UI_FLOW10G_NEXT_2"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase == "free" and SPEAKERS.has(id):
		p = tr("UI_PROMPT3_TALK") % tr(SPEAKERS[id])
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy or phase != "free":
		return
	if SPEAKERS.has(id):
		await _talk(id)
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _say(speaker: String, key: String) -> void:
	var who: Person = null
	for id in SPEAKERS:
		if SPEAKERS[id] == speaker:
			who = galata.npcs[id]
	if who:
		who.talking = true
	await hud.say(speaker, key)
	if who and is_instance_valid(who):
		who.talking = false


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "10G.1", "fatih": "10G.2", "late": "10G.2", "next": "10G.1"}[v]
	var ok: bool = _outcome == expected and GameState.chapter_outcomes.get(10, "") == _outcome
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=10g variant=%s outcome=%s step=%d merak=%d" % ["PASS" if ok else "FAIL", v, _outcome, _step,
		int(GameState.flags.get("merak", 0))])
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
	player.global_position = Galata.WINE + Vector3(-3.5, 0.1, 5.0)
	player.face(Galata.WINE + Vector3(4.0, 2.0, -6.0))
	hud.bark("SPK_WINE", "D10G_W_1", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c10g_01_galata.png")
	player.gravity_on = false
	galata.ship.position = Galata.FATIH_POINT + Vector3(22.0, Galata.WATER_Y, 14.0)
	player.global_position = galata.ship.global_position + Vector3(-6.5, 2.5, 0.0)
	player.face(galata.fatih.global_position + Vector3(0, 1.6, 0))
	hud.bark("SPK_TOLGA", "D10G_T_FATIH_1", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c10g_02_fatih.png")
	get_tree().quit()
