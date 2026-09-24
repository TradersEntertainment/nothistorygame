extends Node3D
## Bölüm 10H — Heyet (Tolga · 25 Nisan 1453). CHAPTERS Bölüm 10 (Heyet), EXPANSION §2.
##
## 9.4'te Lütfi'nin teklifi kabul edildi. Osmanlı heyeti beyaz bayrak altında surların içine girer;
## Tolga "Frenk danışman"dır. Huzurda Lütfi her şeyi yanlış tercüme eder, Theodoros Tolga'ya fısıldar:
##   ⏱ üç kez: Lütfi'yi düzelt ya da karışma. Doğruluk ≥ 1 → 10H.1 (İmparator'un mektubu), 0 → 10H.2 (heyet rezil)
## Mektup (10H.1): aç ya da açma.
## Kapanışta İmparator Frenk'i bir an alıkoyar: ⏱ "Majeste... gelecekten geliyorum."
##   "Bunu size söyleyemem" → byz_honest (Fatih sahnesinin aynası)
##   "Size yardım edebilirim" → Bizans'ı Kurtar: gece üç görev, her biri Direniş +1 (EXPANSION §2.2)
##     📦 Gediği (topların surda açtığı yarık) barikatla kapat, koli bandıyla · 🔋/uyarı Giustiniani · 🥜 zincir nöbetçileri
## Direniş ≥ 1 → Bölüm 11'den sonra 12 yerine "Son Akşam" (12B); dünya W10/W11/W12 (1454, 1455, Ertelendi).
##   --autotest[=shame|save|save1|honest|open|next]   (varsayılan: 10H.1, itiraf yok)

const BREACH := Vector3(32.4, 0.0, -26.0)
const HALL := Vector3(-27.0, 0.0, -14.0)      # ByzCity.EMPEROR_POS
const SPEAKERS := {"emperor": "SPK_EMPEROR", "lutfi": "SPK_LUTFI", "theodoros": "SPK_THEODOROS", "envoy": "SPK_ENVOY",
	"niko": "SPK_NIKO", "giustiniani": "SPK_GIUST"}

var city: ByzCity
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _busy := false
var _truth := 0
var _helping := false
var _done: Dictionary = {}        # gece görevleri
var lutfi: Person
var envoy: Person
var theodoros: Person
var _stockade: Node3D


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
	city = ByzCity.new()
	add_child(city)
	city.niko.look_target = player
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
	GameState.chapter_outcomes[9] = "9.4"
	GameState.chapter_outcomes[6] = "6a.2"
	for id in ["tape", "powerbank", "chickpeas"]:
		if not id in GameState.bag:
			GameState.bag.append(id)


func _d(sec: float) -> float:
	return 0.05 if GameState.autotest else sec


func _wait(sec: float) -> void:
	await get_tree().create_timer(_d(sec)).timeout


# ================================================================ sahne

func _build() -> void:
	# Heyet: Lütfi, elçi, beyaz bayrak
	lutfi = Person.new({"coat": Color("3a6b3a"), "pants": Color("2a3a2a"), "hat": "turban", "mustache": true, "beard": true,
		"hair": Color("3a2a1e"), "robe": Color("3a6b3a")})
	add_child(lutfi)
	envoy = Person.new({"coat": Color("8a6a3a"), "pants": Color("4a3a2a"), "hat": "turban", "beard": true, "mustache": true,
		"hair": Color("5a5a5a"), "robe": Color("a8804a"), "skin": Color("d9a07a")})
	add_child(envoy)
	Props.cyl(envoy, 0.025, 2.4, Vector3(0.35, 1.2, 0.1), Color("6a4a2c"), Vector3.ZERO, 5)
	Props.box(envoy, Vector3(0.02, 0.6, 0.9), Vector3(0.35, 2.1, 0.55), Color("f4f1ea"))
	theodoros = Person.new({"coat": Color("5a3a6a"), "pants": Color("3a2a4a"), "hat": "kamelaukion", "robe": Color("5a3a6a"),
		"beard": true, "hair": Color("6a6a6a"), "skin": Color("e0b08a")})
	add_child(theodoros)
	# Gedik: Urban'ın toplarının surda açtığı yarık. Savunucular her gece tahta, fıçı ve toprakla kapatır.
	var k := BREACH
	# Düzensiz yarık: üst üste binen, eğik koyu parçalar ve kırık tuğla kenarları
	for spec in [[Vector3(0.2, 2.6, 2.2), Vector3(0.12, 1.3, 0.1), 0.0], [Vector3(0.2, 1.8, 1.4), Vector3(0.12, 2.4, -0.5), 18.0],
			[Vector3(0.2, 1.4, 1.2), Vector3(0.12, 2.2, 0.8), -24.0], [Vector3(0.2, 0.9, 0.9), Vector3(0.12, 3.1, 0.1), 40.0]]:
		Props.box(self, spec[0], k + spec[1], Color("1a1410"), Vector3(spec[2], 0, 0))
	for i in 7:
		Props.box(self, Vector3(0.3, 0.22, 0.45), k + Vector3(-0.05, 0.4 + i * 0.45, (-1.25 if i % 2 == 0 else 1.2) + (i % 3) * 0.1), Color("8a4a36"), Vector3(i * 17.0, 0, 0))
	for i in 9:
		var rp := k + Vector3(-0.3 - (i % 3) * 0.5, 0.25 + (i / 3) * 0.2, -1.2 + (i % 4) * 0.8)
		Props.ball(self, 0.35 + (i % 3) * 0.1, rp, Color("b8a888").darkened((i % 3) * 0.1), Vector3(1.2, 0.7, 1.0), 6)
	# Yarım kalmış barikat: birkaç dikme ve fıçı
	for z in [-1.2, 1.2]:
		Props.cyl(self, 0.08, 3.0, k + Vector3(-0.6, 1.5, z), Color("6a4a2c"), Vector3.ZERO, 5)
	for z in [-0.9, 0.9]:
		Props.cyl(self, 0.35, 0.8, k + Vector3(-1.0, 0.4, z), Color("7a5030"), Vector3.ZERO, 10)
	_stockade = Node3D.new()
	add_child(_stockade)
	_stockade.visible = false
	for y in [0.6, 1.2, 1.8, 2.4]:
		Props.box(_stockade, Vector3(0.12, 0.3, 2.8), k + Vector3(-0.6, y, 0), Color("8a6440"))
	for y in [0.9, 2.1]:
		Props.box(_stockade, Vector3(0.14, 0.12, 2.9), k + Vector3(-0.68, y, 0), Color("c8a468"))
	Props.cyl(_stockade, 0.35, 0.8, k + Vector3(-1.0, 1.2, 0), Color("7a5030"), Vector3.ZERO, 10)
	Props.interactable(self, "gedik", Vector3(1.4, 2.6, 3.0), k + Vector3(-0.9, 1.3, 0))
	city.lights.append(Night.torch(self, k + Vector3(-1.2, 0, 1.8), 2.4))


func _place_audience() -> void:
	var c := HALL
	lutfi.position = c + Vector3(1.4, 0, -1.1)
	envoy.position = c + Vector3(1.4, 0, 1.1)
	theodoros.position = c + Vector3(2.9, 0, 2.0)
	for p in [lutfi, envoy]:
		p.look_at_from_position(p.position, city.emperor.global_position, Vector3.UP)
		p.rotate_y(PI)
	theodoros.look_target = player
	player.global_position = c + Vector3(4.4, 0.05, 0.0)
	player.face(city.emperor.global_position + Vector3(0, 1.4, 0))


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	Audio.music("byzantium")
	await hud.card([[tr("UI_CH10H_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH10H_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	# Kapıdan giriş
	var gate := ByzCity.EXIT_POS + Vector3(-3.0, 0, 0)
	lutfi.position = gate + Vector3(-1.4, 0, -1.0)
	envoy.position = gate + Vector3(-1.8, 0, 0.8)
	player.global_position = gate + Vector3(0, 0.05, 0.4)
	player.face(gate + Vector3(-10.0, 1.6, 0))
	lutfi.look_target = player
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _say("SPK_ENVOY", "D10H_E_01")
	await _say("SPK_LUTFI", "D10H_L_02")
	await _t("D10H_T_03")
	await _say("SPK_LUTFI", "D10H_L_04")
	await hud.fade_to(1.0, 0.6)
	_place_audience()
	await hud.fade_to(0.0, 0.8)
	await _audience()
	await _private()
	if _helping:
		await _night()
	await _leave()
	await _end_chapter()


# ---------------------------------------------------------------- huzur: üç tercüme

func _audience() -> void:
	var v := GameState.autotest_variant
	var fix := 0 if v != "shame" else 1
	await _say("SPK_EMPEROR", "D10H_K_01")
	await _say("SPK_THEODOROS", "D10H_TH_01")
	# 1. Sultan'ın teklifi: Lütfi "ev almak istiyor" diye çevirir
	await _say("SPK_ENVOY", "D10H_E_OFFER")
	await _say("SPK_LUTFI", "D10H_L_OFFER")
	await _say("SPK_THEODOROS", "D10H_TH_OFFER")
	var c := await hud.choose(["UI_CH10H_FIX_1", "UI_CH10H_LEAVE", "UI_CH10H_RENT"], 8.0, fix)
	match c:
		0:
			_truth += 1
			await _t("D10H_T_FIX_1")
			await _say("SPK_LUTFI", "D10H_L_FIXED_1")
			await _say("SPK_EMPEROR", "D10H_K_FIXED_1")
		2:
			await _t("D10H_T_RENT")
			await _say("SPK_EMPEROR", "D10H_K_RENT")
		_:
			await _say("SPK_EMPEROR", "D10H_K_HOUSE")
	# 2. İmparator'un cevabı: Lütfi "güçlü bir belki" diye çevirir
	await _say("SPK_EMPEROR", "D10H_K_ANSWER")
	await _say("SPK_LUTFI", "D10H_L_ANSWER")
	await _say("SPK_THEODOROS", "D10H_TH_ANSWER")
	c = await hud.choose(["UI_CH10H_FIX_2", "UI_CH10H_LEAVE"], 8.0, fix)
	if c == 0:
		_truth += 1
		await _t("D10H_T_FIX_2")
		await _say("SPK_ENVOY", "D10H_E_FIXED_2")
	else:
		await _say("SPK_ENVOY", "D10H_E_MAYBE")
	# 3. Frenk danışmana soru
	await _say("SPK_EMPEROR", "D10H_K_FRANK")
	await _say("SPK_THEODOROS", "D10H_TH_FRANK")
	c = await hud.choose(["UI_CH10H_FRANK_1", "UI_CH10H_FRANK_2", "UI_CH10H_FRANK_3"], 8.0, 2 if v != "shame" else 0)
	await _t("D10H_T_FRANK_%d" % (maxi(c, 0) + 1))
	await _say("SPK_EMPEROR", "D10H_K_FRANK_%d" % (maxi(c, 0) + 1))
	if c == 2:
		_truth += 1
	GameState.flags["ch10h_truth"] = _truth
	if _truth >= 1:
		await _say("SPK_EMPEROR", "D10H_K_LETTER")
		await _say("SPK_THEODOROS", "D10H_TH_LETTER")
		GameState.flags["letter"] = true
		GameState.flags["byz_letter"] = true
		var open := await hud.choose(["UI_CH10H_KEEP", "UI_CH10H_OPEN"], 0.0, 1 if v == "open" else 0)
		if open == 1:
			GameState.flags["letter_opened"] = true
			GameState.paradox += 10
			await _t("D10H_T_OPEN")
			await hud.card([[tr("UI_CH10H_LETTER_HEAD"), 22, Color("f2e6c9")], [tr("UI_CH10H_LETTER_TEXT"), 20, Color(1, 1, 1, 0.9)]], 5.0)
			hud.clear_card()
			await _t("D10H_T_OPEN_2")
		else:
			await _t("D10H_T_KEEP")
		_outcome = "10H.1"
	else:
		await _say("SPK_EMPEROR", "D10H_K_SHAME")
		await _say("SPK_LUTFI", "D10H_L_SHAME")
		GameState.flags["merak"] = int(GameState.flags.get("merak", 0)) - 1
		_outcome = "10H.2"


## Heyet çıkarken İmparator Frenk'i bir an alıkoyar.
func _private() -> void:
	if _outcome != "10H.1":
		return
	var v := GameState.autotest_variant
	await _say("SPK_EMPEROR", "D10H_K_STAY")
	lutfi.visible = false
	envoy.visible = false
	var confess := 0 if v in ["save", "save1", "honest"] else 1
	var c := await hud.choose(["UI_CH10H_CONFESS", "UI_CH10H_SAFE"], 8.0, confess)
	if c != 0:
		await _t("D10H_T_SAFE")
		await _say("SPK_EMPEROR", "D10H_K_SAFE")
		return
	await _t("D10H_T_CONFESS")
	await _say("SPK_THEODOROS", "D10H_TH_CONFESS")
	await _say("SPK_EMPEROR", "D10H_K_CONFESS")
	GameState.paradox += 10
	c = await hud.choose(["UI_CH10H_CANT_SAY", "UI_CH10H_HELP"], 10.0, 0 if v == "honest" else 1)
	if c == 0:
		await _t("D10H_T_CANT_SAY")
		await _say("SPK_EMPEROR", "D10H_K_CANT_SAY")
		GameState.flags["byz_honest"] = true
		GameState.flags["honest_with_sultan"] = true
		return
	await _t("D10H_T_HELP")
	await _say("SPK_EMPEROR", "D10H_K_HELP")
	await _say("SPK_THEODOROS", "D10H_TH_HELP")
	_helping = true


# ---------------------------------------------------------------- gece: Bizans'ı Kurtar

func _night() -> void:
	await hud.fade_to(1.0, 0.6)
	await hud.card([[tr("UI_CH10H_NIGHT"), 30, Color("f2e6c9")], [tr("UI_CH10H_NIGHT_SUB"), 18, Color(1, 1, 1, 0.7)]], 2.4)
	hud.clear_card()
	theodoros.visible = false
	player.global_position = ByzCity.START + Vector3(0, 0.05, 0)
	player.face(Vector3(10.0, 1.6, -10.0))
	await hud.fade_to(0.35, 0.8)
	phase = "free"
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		await _auto_night()
	while phase == "free":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	hud.set_objective("")
	var direnc := _done.size()
	GameState.flags["direnc"] = direnc
	await hud.fade_to(0.0, 0.3)


func _update_objective() -> void:
	var lines := PackedStringArray([tr("UI_OBJ10H_NIGHT")])
	for id in ["gedik", "giustiniani", "niko"]:
		lines.append(("✓ " if _done.has(id) else "· ") + tr("UI_OBJ10H_" + id.to_upper()))
	lines.append(tr("UI_OBJ10H_EXIT"))
	hud.set_objective("\n".join(lines))


func _gedik() -> void:
	if _done.has("gedik"):
		await _t("D10H_T_K_DONE")
		return
	player.face(BREACH + Vector3(0, 1.3, 0))
	await _t("D10H_T_K_1")
	if not "tape" in GameState.bag:
		await _t("D10H_T_K_NOTAPE")
		return
	var c := await hud.choose(["UI_CH10H_K_TAPE", "UI_CH10H_K_LEAVE"], 0.0, 0)
	if c != 0:
		return
	await hud.fade_to(0.7, _d(0.4))
	_stockade.visible = true
	Audio.sfx("paper_tear", -6.0)
	await hud.fade_to(0.35, _d(0.4))
	_done["gedik"] = true
	GameState.flags["breach_taped"] = true
	await _t("D10H_T_K_2")
	await _say("SPK_NIKO", "D10H_N_K")


func _giust() -> void:
	if _done.has("giustiniani"):
		await _say("SPK_GIUST", "D10H_G_DONE")
		return
	player.face(city.giustiniani.global_position + Vector3(0, 1.5, 0))
	await _say("SPK_GIUST", "D10H_G_1")
	var keys := ["UI_CH10H_G_WARN", "UI_CH10H_G_NOTHING"]
	if "powerbank" in GameState.bag:
		keys.push_front("UI_CH10H_G_POWERBANK")
	var c := await hud.choose(keys, 0.0, 0)
	var picked: String = keys[maxi(c, 0)]
	match picked:
		"UI_CH10H_G_POWERBANK":
			await _t("D10H_T_G_PB")
			await _say("SPK_GIUST", "D10H_G_PB")
			_done["giustiniani"] = true
			GameState.flags["giust_armored"] = true
		"UI_CH10H_G_WARN":
			await _t("D10H_T_G_WARN")
			await _say("SPK_GIUST", "D10H_G_WARN")
			_done["giustiniani"] = true
		_:
			await _say("SPK_GIUST", "D10H_G_NOTHING")


func _niko() -> void:
	if _done.has("niko"):
		await _say("SPK_NIKO", "D10H_N_DONE")
		return
	player.face(city.niko.global_position + Vector3(0, 1.5, 0))
	await _say("SPK_NIKO", "D10H_N_1")
	if not "chickpeas" in GameState.bag:
		await _say("SPK_NIKO", "D10H_N_NOPEAS")
		return
	var c := await hud.choose(["UI_CH10H_N_PEAS", "UI_CH10H_N_LEAVE"], 0.0, 0)
	if c != 0:
		return
	await _t("D10H_T_N_PEAS")
	await _say("SPK_NIKO", "D10H_N_PEAS")
	_done["niko"] = true
	GameState.flags["chain_watch"] = true


func _auto_night() -> void:
	var tasks: Array = ["gedik", "giustiniani", "niko"] if GameState.autotest_variant == "save" else ["gedik"]
	for id in tasks:
		await _task(id)
	await _task("exit")


func _task(id: String) -> void:
	if _busy or phase != "free":
		return
	_busy = true
	player.frozen = true
	hud.set_prompt("")
	match id:
		"gedik":
			await _gedik()
		"giustiniani":
			await _giust()
		"niko":
			await _niko()
		"exit":
			await _t("D10H_T_EXIT_%d" % mini(_done.size(), 3))
			phase = "leaving"
	if phase == "free":
		_update_objective()
	player.frozen = phase != "free"
	_busy = false


# ---------------------------------------------------------------- dönüş

func _leave() -> void:
	await hud.fade_to(1.0, 0.6)
	await hud.say("SPK_HIKMET", "D10H_H_RADIO")
	var d := int(GameState.flags.get("direnc", 0))
	if d > 0:
		await _t("D10H_T_RADIO_SAVE")
		await hud.say("SPK_HIKMET", "D10H_H_RADIO_SAVE")
	elif _outcome == "10H.1":
		await _t("D10H_T_RADIO_LETTER")
	else:
		await _t("D10H_T_RADIO_SHAME")


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
		print("AUTOTEST chapter=10h -> 11 outcome=%s" % _outcome)
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
	c.title_text = tr("UI_FLOW10H_TITLE")
	c.nodes = [
		{"id": "gate", "key": "FLOW10H_GATE", "pos": Vector2(0.12, 0.14)},
		{"id": "tr", "key": "FLOW10H_TRANSLATE", "pos": Vector2(0.36, 0.14)},
		{"id": "10H.2", "key": "FLOW_10H_2", "pos": Vector2(0.36, 0.36), "outcome": true},
		{"id": "10H.1", "key": "FLOW_10H_1", "pos": Vector2(0.62, 0.14), "outcome": true},
		{"id": "open", "key": "FLOW10H_OPEN", "pos": Vector2(0.88, 0.14)},
		{"id": "confess", "key": "FLOW10H_CONFESS", "pos": Vector2(0.62, 0.36)},
		{"id": "cant", "key": "FLOW10H_CANT_SAY", "pos": Vector2(0.88, 0.36)},
		{"id": "help", "key": "FLOW10H_HELP", "pos": Vector2(0.5, 0.56)},
		{"id": "gedik", "key": "FLOW10H_BREACH", "pos": Vector2(0.24, 0.74)},
		{"id": "giustiniani", "key": "FLOW10H_GIUST", "pos": Vector2(0.5, 0.74)},
		{"id": "niko", "key": "FLOW10H_CHAIN", "pos": Vector2(0.76, 0.74)},
	]
	c.edges = [["gate", "tr"], ["tr", "10H.1"], ["tr", "10H.2"], ["10H.1", "open"], ["10H.1", "confess"], ["confess", "cant"],
		["confess", "help"], ["help", "gedik"], ["help", "giustiniani"], ["help", "niko"]]
	for id in ["gate", "tr", _outcome]:
		c.taken[id] = true
	if GameState.flags.get("letter_opened", false) and _outcome == "10H.1":
		c.taken["open"] = true
	if GameState.flags.get("byz_honest", false):
		c.taken["confess"] = true
		c.taken["cant"] = true
	if _helping:
		c.taken["confess"] = true
		c.taken["help"] = true
	for id in _done:
		c.taken[id] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH10H_STATS") % [_truth, int(GameState.flags.get("direnc", 0)), GameState.paradox],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW10H_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase == "free":
		match id:
			"gedik": p = tr("UI_PROMPT10H_BREACH")
			"giustiniani": p = tr("UI_PROMPT3_TALK") % tr("SPK_GIUST")
			"niko": p = tr("UI_PROMPT3_TALK") % tr("SPK_NIKO")
			"exit": p = tr("UI_PROMPT10H_EXIT")
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy or phase != "free":
		return
	if id in ["gedik", "giustiniani", "niko", "exit"]:
		await _task(id)
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _npc(speaker: String) -> Person:
	match speaker:
		"SPK_EMPEROR": return city.emperor
		"SPK_LUTFI": return lutfi
		"SPK_THEODOROS": return theodoros
		"SPK_ENVOY": return envoy
		"SPK_NIKO": return city.niko
		"SPK_GIUST": return city.giustiniani
	return null


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _say(speaker: String, key: String) -> void:
	var who := _npc(speaker)
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
	var expected: String = {"": "10H.1", "shame": "10H.2", "save": "10H.1", "save1": "10H.1", "honest": "10H.1",
		"open": "10H.1", "next": "10H.1"}[v]
	var direnc := int(GameState.flags.get("direnc", 0))
	var ok: bool = _outcome == expected and GameState.chapter_outcomes.get(10, "") == _outcome
	match v:
		"save": ok = ok and direnc == 3
		"save1": ok = ok and direnc == 1
		"honest": ok = ok and GameState.flags.get("byz_honest", false) and direnc == 0
		"open": ok = ok and GameState.flags.get("letter_opened", false)
		"": ok = ok and direnc == 0 and _truth >= 1
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (direnç %d)" % [expected, _outcome, direnc])
	print("AUTOTEST %s chapter=10h variant=%s outcome=%s truth=%d direnc=%d paradox=%d" % [
		"PASS" if ok else "FAIL", v, _outcome, _truth, direnc, GameState.paradox])
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
	_place_audience()
	player.face(city.emperor.global_position + Vector3(0, 1.4, 0))
	lutfi.talking = true
	hud.bark("SPK_LUTFI", "D10H_L_OFFER", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c10h_01_huzur.png")
	lutfi.talking = false
	player.global_position = BREACH + Vector3(-4.0, 0.05, 2.2)
	player.face(BREACH + Vector3(0, 1.3, 0))
	hud.bark("SPK_TOLGA", "D10H_T_K_1", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c10h_02_gedik.png")
	get_tree().quit()
