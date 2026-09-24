extends Node3D
## Bölüm 9 — Teklifler (Tolga · 25 Nisan 1453). CHAPTERS Bölüm 9, STORY_BRANCHES Matris 1 (D2–D6).
##
## Ordugâhta bir sabah. Yol değiştiren teklifler gelir; her yola en az biri:
##   A · Kadri:    "Ziyafeti sen pişir."            (menü denemesi)  → 9.1 · Ziyafet
##   C · Urban:    "Kal, top dökelim."              (açı hesabı)     → 9.2 · Büyük Atış
##   Y · Çandarlı: "Bu mektubu Galata'ya götür."    (Y'de garanti; 6a.5'te mektup alındıysa her yolda)
##                  Galata → 9.3 · ya da Fatih'e götür (Merak +1) → Otağ kapısı
##   B · Lütfi:    "Heyete Frenk danışman olarak gel." (selam denemesi) → 9.4 · Heyet
##   Bz · Theodoros (Labirent kusursuzsa, 6b.1): eksik çıkış formu için beyaz bayrakla ordugâha gelir,
##                  "Arşivde kal." → 9.5 · Arşiv
##   Hepsini reddet, otağ kapısında bekle → 9.6 · Otağ Kapısı
## Hikmet 8.4'te makineye bindiyse pazarda pijamayla bir keçiden kaçarken karşımıza çıkar.
##   --autotest[=b|c|y|arch|none|fatih|cell|hikmet]   (varsayılan: 9.1)

const GATE_POS := Vector3(0.0, 0.0, -52.5)
const PASHA_POS := Vector3(10.6, 0.0, 21.0)
const THEO_POS := Vector3(-2.5, 0.0, 16.0)
const HIKMET_POS := Vector3(-5.5, 0.0, 12.5)
const BYZ_SPAWN := Vector3(0.0, 0.0, 22.0)
const SPEAKERS := {"kadri": "SPK_KADRI", "lutfi": "SPK_LUTFI", "urban": "SPK_URBAN", "pasha": "SPK_PASHA",
	"theodoros": "SPK_THEODOROS", "guards": "SPK_HASAN", "hikmet": "SPK_HIKMET", "candarli": "SPK_CANDARLI"}
const RESULT := {"kadri": "9.1", "urban": "9.2", "pasha": "9.3", "lutfi": "9.4", "theodoros": "9.5"}
## Oynanabilir dal bölümleri (diğerleri "yakında")
const NEXT_SCENE := {"9.2": "res://scenes/chapter10b.tscn", "9.6": "res://scenes/chapter10.tscn"}

var day: CampDay
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _busy := false
var _route := ""                 # A, B, C, Y ya da "" (Bizans'tan gelen)
var _byz := false
var _offers: Array = []          # teklif veren karakterler
var _declined: Dictionary = {}
var _trial: Dictionary = {}
var pasha: Person
var theodoros: Person
var hikmet_npc: Hikmet
var hasan: Soldier
var huseyin: Soldier


func _ready() -> void:
	GameState.snapshot(9)
	_apply_autotest_setup()
	var ch6: String = GameState.chapter_outcomes.get(6, "6a.1")
	_byz = ch6.begins_with("6b")
	if not _byz:
		_route = {"6a.1": "A", "6a.2": "B", "6a.3": "C", "6a.4": "Y"}.get(ch6, GameState.flags.get("route", "A"))
	match _route:
		"A": _offers.append("kadri")
		"B": _offers.append("lutfi")
		"C": _offers.append("urban")
		"Y": _offers.append("pasha")
	if _route != "Y" and not _byz and GameState.flags.get("candarli_letter", false):
		_offers.append("pasha")
	if ch6 == "6b.1":
		_offers.append("theodoros")
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
	day = CampDay.new()
	add_child(day)
	day.goat.chase = player
	day.kadri.look_target = player
	day.lutfi.look_target = player
	day.urban.look_target = player
	if day.ring_node:
		day.ring_node.queue_free()
	_build_extras()
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
		"b": GameState.chapter_outcomes[6] = "6a.2"
		"c": GameState.chapter_outcomes[6] = "6a.3"
		"y": GameState.chapter_outcomes[6] = "6a.4"
		"arch": GameState.chapter_outcomes[6] = "6b.1"
		"cell": GameState.chapter_outcomes[6] = "6b.3"
		"fatih": GameState.flags["candarli_letter"] = true
		"hikmet": GameState.chapter_outcomes[8] = "8.4"


func _process(_delta: float) -> void:
	if hud and phase == "free" and not _busy and Input.is_action_just_pressed("fez"):
		var on: bool = not GameState.flags.get("fez", true)
		GameState.flags["fez"] = on
		hud.set_fez(on)


# ================================================================ sahne

func _build_extras() -> void:
	# Otağ kapısında onur muhafızı: Hasan ile Hüseyin
	var gy := _ground_y(GATE_POS.z)
	hasan = Soldier.new(Color("b3262d"), "stand", "bork")
	hasan.position = GATE_POS + Vector3(-1.7, gy, 0)
	add_child(hasan)
	huseyin = Soldier.new(Color("2f5fa8"), "stand", "bork")
	huseyin.position = GATE_POS + Vector3(1.7, gy, 0)
	add_child(huseyin)
	Props.interactable(self, "guards", Vector3(4.6, 2.2, 1.4), GATE_POS + Vector3(0, gy + 1.1, 0))
	# Çandarlı Halil Paşa: pazarın arkasında, kılık değiştirmiş (ama sarığı fazla büyük)
	if "pasha" in _offers:
		pasha = Person.new({"coat": Color("3a4a3a"), "pants": Color("2a2a24"), "hat": "turban", "beard": true, "mustache": true,
			"hair": Color("8a8a8a"), "robe": Color("3a4a3a"), "skin": Color("d9a07a")})
		pasha.position = PASHA_POS
		pasha.rotation.y = PI * 0.9
		pasha.scale = Vector3(1.05, 1.05, 1.05)
		pasha.look_target = player
		add_child(pasha)
		Props.interactable(self, "pasha", Vector3(1.2, 2.0, 1.2), PASHA_POS + Vector3(0, 1.0, 0))
	# Theodoros: beyaz bayrakla, elinde form
	if "theodoros" in _offers or GameState.chapter_outcomes.get(6, "") == "6b.3":
		theodoros = Person.new({"coat": Color("5a3a6a"), "pants": Color("3a2a4a"), "hat": "kamelaukion", "robe": Color("5a3a6a"),
			"beard": true, "hair": Color("6a6a6a"), "skin": Color("e0b08a")})
		theodoros.position = THEO_POS
		theodoros.rotation.y = PI
		theodoros.look_target = player
		add_child(theodoros)
		Props.cyl(theodoros, 0.02, 2.2, Vector3(0.35, 1.1, 0.1), Color("6a5030"), Vector3.ZERO, 5)
		Props.box(theodoros, Vector3(0.02, 0.5, 0.7), Vector3(0.35, 1.95, 0.45), Color("f4f1ea"))
		Props.interactable(self, "theodoros", Vector3(1.2, 2.0, 1.2), THEO_POS + Vector3(0, 1.0, 0))
	# Hikmet (8.4): pijamayla, pazarda, keçiden kaçıyor
	if GameState.chapter_outcomes.get(8, "") == "8.4":
		hikmet_npc = Hikmet.new()
		hikmet_npc.position = HIKMET_POS
		hikmet_npc.look_target = player
		add_child(hikmet_npc)
		Props.interactable(self, "hikmet", Vector3(1.2, 2.0, 1.2), HIKMET_POS + Vector3(0, 1.0, 0))


func _ground_y(z: float) -> float:
	return CampDay.height(0.0, z)


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH9_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH9_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	var spawn := BYZ_SPAWN if _byz else CampDay.SPAWN
	player.global_position = spawn
	player.face(spawn + Vector3(0, 1.6, -10.0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	if _byz:
		if GameState.chapter_outcomes.get(6, "") == "6b.3":
			await _t("D9_T_DEPORTED")
		else:
			await _t("D9_T_BYZ")
	else:
		await _t("D9_T_" + _route)
	await _radio()
	await _t("D9_T_GOAL")
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


## Hikmet'in telsiz çağrısı: Bölüm 8'in sonucuna göre. 8.4'te Hikmet zaten burada.
func _radio() -> void:
	var ch8: String = GameState.chapter_outcomes.get(8, "8.1")
	if ch8 == "8.4":
		await _say("SPK_HIKMET", "D9_H_HERE")
		await _t("D9_T_HERE")
		return
	if GameState.telsiz_bag <= 0:
		await _t("D9_T_RADIO_DEAD")
		return
	await _say("SPK_HIKMET", "D9_H_CALL")
	var c := await hud.choose(["UI_CH6_ANSWER", "UI_CH6_IGNORE"], 6.0, 0)
	if c == 0:
		await _t("D9_T_ANSWER")
		await _say("SPK_HIKMET", "D9_H_" + ch8.replace(".", "_"))
		GameState.telsiz_bag = mini(5, GameState.telsiz_bag + 1)
	else:
		await _say("SPK_HIKMET", "D9_H_NO_ANSWER")
		GameState.telsiz_bag = maxi(0, GameState.telsiz_bag - 1)
	hud.set_signal(GameState.telsiz_bag)


func _update_objective() -> void:
	var names := PackedStringArray()
	for o in _offers:
		names.append(("✗ " if _declined.has(o) else "• ") + tr("UI_OFFER9_" + String(o).to_upper()))
	var head := tr("UI_OBJ9")
	if names.is_empty():
		head = tr("UI_OBJ9_NONE")
	hud.set_objective(head + ("\n" + "   ".join(names) if not names.is_empty() else ""))


# ---------------------------------------------------------------- teklifler

func _talk(npc: String, auto := -1) -> void:
	if _busy or _outcome != "":
		return
	_busy = true
	player.frozen = true
	var node := _npc_node(npc)
	if node:
		player.face(node.global_position + Vector3(0, 1.45, 0))
	match npc:
		"kadri", "lutfi", "urban":
			if npc in _offers:
				await _offer(npc, auto)
			else:
				await _say(SPEAKERS[npc], "D9_%s_BUSY" % npc.to_upper())
		"pasha":
			await _pasha(auto)
		"theodoros":
			await _theodoros(auto)
		"guards":
			await _gate(auto)
		"hikmet":
			await _hikmet()
		"candarli":
			await _say("SPK_CANDARLI", "D9_C_NOBODY")
	_update_objective()
	player.frozen = false
	_busy = false


## Kadri / Lütfi / Urban: teklif, küçük bir deneme, kabul ya da ret.
func _offer(npc: String, auto: int) -> void:
	var up := npc.to_upper()
	var spk: String = SPEAKERS[npc]
	if _declined.has(npc):
		await _say(spk, "D9_%s_AGAIN" % up)
	else:
		await _say(spk, "D9_%s_OFFER_1" % up)
		await _t("D9_T_%s_Q" % up)
		await _say(spk, "D9_%s_OFFER_2" % up)
		if not _trial.has(npc):
			await _say(spk, "D9_%s_TRIAL" % up)
			var t := await hud.choose(["UI_CH9_%s_T1" % up, "UI_CH9_%s_T2" % up, "UI_CH9_%s_T3" % up], 0.0, 1)
			t = clampi(t, 0, 2)
			_trial[npc] = t
			GameState.flags["ch9_trial_" + npc] = t
			await _say(spk, "D9_%s_TR%d" % [up, t + 1])
	var pick := 0 if _auto_accepts(npc) else 1
	var c := await hud.choose(["UI_CH9_ACCEPT_" + up, "UI_CH9_DECLINE"], 0.0, pick)
	if c == 0:
		await _say(spk, "D9_%s_YES" % up)
		await _t("D9_T_%s_YES" % up)
		_outcome = RESULT[npc]
	else:
		_declined[npc] = true
		await _say(spk, "D9_%s_NO" % up)


func _pasha(auto: int) -> void:
	if not "pasha" in _offers:
		return
	if _declined.has("pasha"):
		await _say("SPK_PASHA", "D9_P_AGAIN")
	else:
		await _say("SPK_PASHA", "D9_P_1")
		await _t("D9_T_P_2")
		await _say("SPK_PASHA", "D9_P_3")
		await _t("D9_T_P_4")
		await _say("SPK_PASHA", "D9_P_5")
	var pick := 1 if GameState.autotest_variant == "fatih" else (0 if _auto_accepts("pasha") else 2)
	if auto >= 0:
		pick = auto
	var c := await hud.choose(["UI_CH9_GALATA", "UI_CH9_TO_FATIH", "UI_CH9_DECLINE"], 0.0, pick)
	match c:
		0:
			await _say("SPK_PASHA", "D9_P_GALATA")
			await _t("D9_T_GALATA")
			GameState.flags["letter_route"] = "galata"
			_outcome = "9.3"
		1:
			# D4: dürüstlük. Mektup Fatih'e gider (Merak +1), yol otağ kapısına çıkar.
			await _say("SPK_PASHA", "D9_P_FATIH")
			await _t("D9_T_FATIH")
			GameState.flags["letter_route"] = "fatih"
			GameState.flags["merak"] = int(GameState.flags.get("merak", 0)) + 1
			_declined["pasha"] = true
		_:
			_declined["pasha"] = true
			await _say("SPK_PASHA", "D9_P_NO")


func _theodoros(auto: int) -> void:
	if not "theodoros" in _offers:
		# Labirent başarısız: başvurusu açık, teklif yok
		await _say("SPK_THEODOROS", "D9_THEO_OPEN")
		await _t("D9_T_THEO_OPEN")
		return
	if _declined.has("theodoros"):
		await _say("SPK_THEODOROS", "D9_THEO_AGAIN")
	else:
		await _say("SPK_THEODOROS", "D9_THEO_1")
		await _t("D9_T_THEO_2")
		await _say("SPK_THEODOROS", "D9_THEO_3")
		await _t("D9_T_THEO_4")
		await _say("SPK_THEODOROS", "D9_THEO_5")
	var pick := 0 if _auto_accepts("theodoros") else 1
	if auto >= 0:
		pick = auto
	var c := await hud.choose(["UI_CH9_ACCEPT_THEODOROS", "UI_CH9_DECLINE"], 0.0, pick)
	if c == 0:
		await _say("SPK_THEODOROS", "D9_THEO_YES")
		await _t("D9_T_THEO_YES")
		_outcome = "9.5"
	else:
		_declined["theodoros"] = true
		await _say("SPK_THEODOROS", "D9_THEO_NO")


## Otağ kapısı: teklifleri reddedip huzura çıkmayı beklemek (9.6).
func _gate(auto: int) -> void:
	await _say("SPK_HASAN", "D9_G_1")
	await _say("SPK_HUSEYIN", "D9_G_2")
	var open := 0
	for o in _offers:
		if not _declined.has(o):
			open += 1
	if open > 0:
		await _t("D9_T_GATE_OPEN")
	var pick := 0 if auto < 0 else auto
	if GameState.autotest and not GameState.autotest_variant in ["none", "fatih", "cell", "next"]:
		pick = 1
	var c := await hud.choose(["UI_CH9_WAIT_GATE", "UI_CH9_NOT_YET"], 0.0, pick)
	if c != 0:
		await _say("SPK_HUSEYIN", "D9_G_LATER")
		return
	for o in _offers:
		_declined[o] = true
	await _say("SPK_HASAN", "D9_G_WAIT")
	await _t("D9_T_GATE_" + ("LETTER" if GameState.flags.get("letter_route", "") == "fatih" else ("BYZ" if _byz else "WAIT")))
	_outcome = "9.6"


func _hikmet() -> void:
	if GameState.flags.get("ch9_met_hikmet", false):
		await _say("SPK_HIKMET", "D9_H2_AGAIN")
		return
	GameState.flags["ch9_met_hikmet"] = true
	await _t("D9_T_H2_1")
	await _say("SPK_HIKMET", "D9_H2_2")
	await _t("D9_T_H2_3")
	await _say("SPK_HIKMET", "D9_H2_4")
	await _t("D9_T_H2_5")
	await _say("SPK_HIKMET", "D9_H2_6")


func _auto_accepts(npc: String) -> bool:
	if not GameState.autotest:
		return false
	return GameState.autotest_variant not in ["none", "fatih", "cell", "next"] and npc == _auto_target()


func _auto_target() -> String:
	match GameState.autotest_variant:
		"b": return "lutfi"
		"c": return "urban"
		"y": return "pasha"
		"arch": return "theodoros"
	return "kadri"


func _npc_node(npc: String) -> Node3D:
	match npc:
		"kadri": return day.kadri
		"lutfi": return day.lutfi
		"urban": return day.urban
		"candarli": return day.candarli
		"pasha": return pasha
		"theodoros": return theodoros
		"guards": return hasan
		"hikmet": return hikmet_npc
	return null


# ---------------------------------------------------------------- otomatik test

func _auto() -> void:
	var v := GameState.autotest_variant
	if v == "hikmet":
		await _talk("hikmet")
	match v:
		"none", "next":
			for o in _offers:
				await _talk(o)
			await _talk("guards", 0)
		"fatih":
			await _talk("pasha")
			await _talk("kadri")
			await _talk("guards", 0)
		"cell":
			await _talk("theodoros")
			await _talk("guards", 0)
		_:
			var target := _auto_target()
			await _talk("guards", 1)
			await _talk(target)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	GameState.set_outcome(9, _outcome)
	await _farewell()
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var can_go := NEXT_SCENE.has(_outcome)
	var result := await hud.show_flowchart(chart, can_go)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=9 -> 10 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file(NEXT_SCENE.get(_outcome, "res://scenes/chapter10.tscn"))
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file(NEXT_SCENE.get(_outcome, "res://scenes/chapter10.tscn"))
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


## Bölümün son kartı: hangi dala gidildiği.
func _farewell() -> void:
	await hud.fade_to(1.0, 0.6)
	var key := "UI_CH9_END_" + _outcome.replace(".", "_")
	await hud.card([[tr(key), 30, Color("f2e6c9")], [tr(key + "_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW9_TITLE")
	c.nodes = [
		{"id": "morning", "key": "FLOW9_MORNING", "pos": Vector2(0.5, 0.14)},
		{"id": "9.1", "key": "FLOW_9_1", "pos": Vector2(0.1, 0.36), "outcome": true},
		{"id": "9.2", "key": "FLOW_9_2", "pos": Vector2(0.26, 0.5), "outcome": true},
		{"id": "9.3", "key": "FLOW_9_3", "pos": Vector2(0.42, 0.36), "outcome": true},
		{"id": "9.4", "key": "FLOW_9_4", "pos": Vector2(0.58, 0.5), "outcome": true},
		{"id": "9.5", "key": "FLOW_9_5", "pos": Vector2(0.74, 0.36), "outcome": true},
		{"id": "9.6", "key": "FLOW_9_6", "pos": Vector2(0.9, 0.5), "outcome": true},
		{"id": "fatih", "key": "FLOW9_LETTER_FATIH", "pos": Vector2(0.9, 0.68)},
	]
	c.edges = [["morning", "9.1"], ["morning", "9.2"], ["morning", "9.3"], ["morning", "9.4"], ["morning", "9.5"],
		["morning", "9.6"], ["9.6", "fatih"]]
	c.taken["morning"] = true
	c.taken[_outcome] = true
	if GameState.flags.get("letter_route", "") == "fatih":
		c.taken["fatih"] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH9_STATS") % [GameState.telsiz_bag, GameState.paradox, int(GameState.flags.get("merak", 0))],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW9_NEXT_" + _outcome.replace(".", "_")) if NEXT_SCENE.has(_outcome) else tr("UI_FLOW9_NEXT_SOON"),
		tr("UI_FLOW_CONTINUE") if NEXT_SCENE.has(_outcome) else tr("UI_FLOW2_REPLAY"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase == "free" and SPEAKERS.has(id):
		p = tr("UI_PROMPT3_TALK") % tr(SPEAKERS[id] if id != "guards" else "UI_CH7_GUARDS")
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy or phase != "free":
		return
	if SPEAKERS.has(id):
		_talk(id)
	elif id == "goat":
		hud.bark("SPK_TOLGA", "D9_T_GOAT", 2.5)
	elif id == "cannon":
		hud.bark("SPK_TOLGA", "D6A_T_CANNON", 3.5)
	elif id == "letter":
		hud.bark("SPK_SOLDIER", "D7_S_LETTER", 3.5)
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _say(speaker: String, key: String) -> void:
	var who: Node3D = null
	for k in SPEAKERS:
		if SPEAKERS[k] == speaker:
			who = _npc_node(k)
	if who and who is Person:
		(who as Person).talking = true
	await hud.say(speaker, key)
	if who and is_instance_valid(who) and who is Person:
		(who as Person).talking = false


func _wait(s: float) -> void:
	if GameState.autotest:
		await get_tree().process_frame
		return
	await get_tree().create_timer(s).timeout


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var expected: String = {"next": "9.6", "": "9.1", "b": "9.4", "c": "9.2", "y": "9.3", "arch": "9.5", "none": "9.6",
		"fatih": "9.6", "cell": "9.6", "hikmet": "9.1"}[GameState.autotest_variant]
	var ok := _outcome == expected
	match GameState.autotest_variant:
		"fatih":
			ok = ok and GameState.flags.get("letter_route", "") == "fatih" and int(GameState.flags.get("merak", 0)) >= 1
		"hikmet":
			ok = ok and GameState.flags.get("ch9_met_hikmet", false)
	if GameState.chapter_outcomes.get(9, "") != _outcome:
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=9 variant=%s route=%s byz=%s offers=%s outcome=%s telsiz=%d merak=%d" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, _route, str(_byz), str(_offers), _outcome,
		GameState.telsiz_bag, int(GameState.flags.get("merak", 0))])
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
	phase = "free"
	_update_objective()
	if _byz:
		player.global_position = THEO_POS + Vector3(1.2, 0.05, -2.6)
		player.face(theodoros.global_position + Vector3(0, 1.4, 0))
		theodoros.talking = true
		hud.bark("SPK_THEODOROS", "D9_THEO_1", 30.0)
		await get_tree().create_timer(0.4).timeout
		await _shot("c9_04_theodoros.png")
		get_tree().quit()
		return
	player.global_position = CampDay.KADRI_POS + Vector3(1.6, 0.05, 2.6)
	player.face(day.kadri.global_position + Vector3(0, 1.3, 0))
	day.kadri.talking = true
	hud.bark("SPK_KADRI", "D9_KADRI_OFFER_1", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c9_01_kadri.png")
	day.kadri.talking = false
	if pasha:
		player.global_position = PASHA_POS + Vector3(-1.4, 0.05, -2.4)
		player.face(pasha.global_position + Vector3(0, 1.4, 0))
		pasha.talking = true
		hud.bark("SPK_PASHA", "D9_P_3", 30.0)
		await get_tree().create_timer(0.4).timeout
		await _shot("c9_02_candarli.png")
	if hikmet_npc:
		day.goat.chase = null
		day.goat.set_process(false)
		day.goat.position = HIKMET_POS + Vector3(1.0, 0, 0.6)
		player.global_position = HIKMET_POS + Vector3(1.6, 0.05, -2.8)
		player.face(hikmet_npc.global_position + Vector3(0, 1.3, 0))
		hud.bark("SPK_HIKMET", "D9_H2_2", 30.0)
		await get_tree().create_timer(0.4).timeout
		await _shot("c9_03_hikmet.png")
	var gy := _ground_y(GATE_POS.z)
	player.global_position = GATE_POS + Vector3(0.3, gy + 0.05, 4.5)
	player.face(GATE_POS + Vector3(0, gy + 2.2, -6.0))
	hud.bark("SPK_HUSEYIN", "D9_G_2", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c9_05_otag.png")
	get_tree().quit()
