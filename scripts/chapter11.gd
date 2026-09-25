extends Node3D
## Bölüm 11 — Yüzleşme (Nihat + Tolga · 25 Nisan 1453, gece). CHAPTERS Bölüm 11.
##
## Kontrol sahne ortasında el değiştirir: önce Nihat, sonra Tolga.
## Nihat saha kapısından geceye iner. Bölüm 7'de Tolga'nın yeri bulunduysa (7.1) tarayıcı onu
## gösterir; bulunamadıysa (7.2) iz kaybolur (11.4; Büro Baskısı kritikse Nihat görevden alınır).
## Yüzleşme: "Bay Tolga. Form Z-1453'ü doldurmadınız." Araya girenler:
##   Pijamalı Hikmet (8.4) → formlarla sözlü kavga, Tolga kaçar (11.5)
##   Niko (dost, 6b.4) → Sinerji'yi fırlatır, Tolga kaçar (11.6)
## Yoksa ⏱ Nihat olarak: Tutukla / Rapor et ama bırak / Yardım et
##   (Yardım et: Kuralsızsa doğrudan; Sadakat < 35 ise ⏱ Yönetmelik Duvarı; yoksa eli titrer, bırakır)
## Sonra Tolga olarak (tutuklamada): üç tur, ⏱ İkna olasılığı %: eşya göster (🥜 +15), dürüst ol,
##   sigorta mantığı, kaç ya da teslim ol.
##   11.1 tutuklandı · 11.2 serbest/kaçtı · 11.3 Nihat katıldı · 11.4 iz kaybedildi · 11.5 · 11.6
##   --autotest[=arrest|escape|persuade|help|helpwall|lost|fired|hikmet|niko]   (varsayılan: 11.2)

const TOLGA_POS := Vector3(-4.0, 0.0, -43.0)
const FIRE_POS := Vector3(-4.6, 0.0, -41.6)
const KITCHEN_TOLGA := Vector3(-11.4, 0.0, -5.2)
const CANNON_TOLGA := Vector3(6.5, 0.0, -17.0)
const TURNS := 3
## Dal bölümü başarıyla kapanırsa Tolga'nın 1453 hikâyesi biter, Bölüm 12 oynanmaz (CHAPTERS Bölüm 10)
const SKIP_12 := ["10B.1", "10B.2", "10B.3", "10Z.1", "10G.1", "10A.1", "10L.1"]

var day: CampDay
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _busy := false
var _found := true
var _tolga_at := TOLGA_POS
var _persuade := 25.0
var _used: Dictionary = {}
var tolga_npc: Person
var nihat_npc: Person
var door: Node3D


func _ready() -> void:
	GameState.snapshot(11)
	_apply_autotest_setup()
	_found = GameState.chapter_outcomes.get(7, "7.1") != "7.2"
	var ch10: String = GameState.chapter_outcomes.get(10, "10O.1")
	if ch10 == "10O.2" or ch10.begins_with("10Z"):
		_tolga_at = KITCHEN_TOLGA
	elif ch10.begins_with("10B"):
		_tolga_at = CANNON_TOLGA
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	player.hand_style = "nihat"
	add_child(player)
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(_on_focus)
	player.frozen = true
	hud.set_nihat_mode(true)
	hud.set_fez(false)
	hud.meters.loyalty = _loyalty()
	hud.meters._shown_loyalty = _loyalty()
	day = CampDay.new()
	add_child(day)
	day.make_night(true)
	day.goat.chase = null
	if day.ring_node:
		day.ring_node.queue_free()
	_build()
	if GameState.flags.get("big_bang", false):
		# Büyük Patlama'dan geriye: krater ve tahta parçaları
		day.cannon.visible = false
		Props.cyl(self, 2.6, 0.04, day.cannon.position + Vector3(0, 0.02, 0), Color("2a2420"), Vector3.ZERO, 14)
	player.show_remote(true)
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
		"help":
			GameState.flags["nihat_rulefree"] = true
		"helpwall":
			GameState.flags["sadakat"] = 30
			GameState.flags.erase("nihat_rulefree")
		"lost":
			GameState.chapter_outcomes[7] = "7.2"
		"fired":
			GameState.chapter_outcomes[7] = "7.2"
			GameState.flags["buro_baskisi"] = 4
		"hikmet":
			GameState.chapter_outcomes[8] = "8.4"
		"niko":
			GameState.flags["niko_friend"] = true


func _loyalty() -> float:
	return float(GameState.flags.get("sadakat", 60))


func _process(_delta: float) -> void:
	if phase == "seek" and tolga_npc:
		var d := player.global_position.distance_to(tolga_npc.global_position)
		var v := clampf(1.0 - d / 45.0, 0.0, 1.0)
		hud.set_chase(tr("UI_SCANNER"), v)
		player.set_scanner(v)


func _build() -> void:
	# Tolga: ateşin başında, yarını bekliyor
	tolga_npc = Person.new({"face": "tolga", "coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")})
	tolga_npc.position = _tolga_at
	add_child(tolga_npc)
	if _tolga_at == TOLGA_POS:
		day.lights.append(Night.campfire(day, FIRE_POS, 0.8))
		tolga_npc.rotation.y = atan2(FIRE_POS.x - _tolga_at.x, FIRE_POS.z - _tolga_at.z)
	Props.interactable(self, "tolga", Vector3(1.4, 2.0, 1.4), _tolga_at + Vector3(0, 1.0, 0))
	# Büro'nun saha kapısı (Bölüm 7'deki)
	door = Node3D.new()
	door.position = CampDay.SPAWN + Vector3(0, 0, 2.6)
	add_child(door)
	for s in [-1, 1]:
		Props.box(door, Vector3(0.14, 2.4, 0.2), Vector3(s * 0.62, 1.2, 0), Color("8a8f98"))
	Props.box(door, Vector3(1.38, 0.14, 0.2), Vector3(0, 2.4, 0), Color("8a8f98"))
	Props.box(door, Vector3(1.1, 2.3, 0.06), Vector3(0, 1.15, 0.02), Color("5a6470"))
	var glow := OmniLight3D.new()
	glow.position = Vector3(0, 1.8, -0.8)
	glow.light_color = Color("b8d8ff")
	glow.light_energy = 1.2
	glow.omni_range = 4.0
	door.add_child(glow)


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH11_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH11_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = door.position + Vector3(0, 0.05, -1.2)
	player.face(Vector3(0, 1.6, -20.0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _n("D11_N_ARRIVE")
	# Şenlik ateşleri: tarihte 26 Mayıs gecesi; burada bir ay erken (Büro bunu anomali olarak kaydeder)
	await _n("D11_N_ILLUM")
	await _say("SPK_MUFIDE", "D11_M_ILLUM")
	await _n("D11_N_ILLUM_2")
	if not _found:
		await _lost()
	else:
		await _say("SPK_MUFIDE", "D11_M_FOUND")
		await _n("D11_N_FOUND")
		phase = "seek"
		hud.set_objective(tr("UI_OBJ11"))
		player.frozen = false
		if GameState.autotest:
			await _confront()
	while _outcome == "":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	await _end_chapter()


## 7.2: iz yok. Büro Baskısı kritikse görevden alınır (N3).
func _lost() -> void:
	player.frozen = true
	await _n("D11_N_LOST_1")
	await _say("SPK_MUFIDE", "D11_M_LOST")
	if int(GameState.flags.get("buro_baskisi", 0)) >= 4:
		await _say("SPK_MUFIDE", "D11_M_FIRED")
		await _n("D11_N_FIRED")
		await hud.card([[tr("UI_CH11_FIRED"), 30, Color("f2e6c9")], [tr("UI_CH11_FIRED_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
		hud.clear_card()
		GameState.flags["nihat_dismissed"] = true
	else:
		await _n("D11_N_LOST_2")
	_outcome = "11.4"


func _confront() -> void:
	if _busy or phase != "seek":
		return
	_busy = true
	phase = "talk"
	player.frozen = true
	hud.set_chase("", 0.0)
	hud.set_objective("")
	if GameState.autotest:
		player.global_position = _tolga_at + Vector3(0.4, 0.05, 2.2)
	player.face(tolga_npc.global_position + Vector3(0, 1.5, 0))
	tolga_npc.look_target = player
	if GameState.flags.get("big_bang", false):
		await _n("D11_N_BOOM")
		await _t("D11_T_BOOM")
	elif GameState.flags.get("buried", false):
		await _n("D11_N_BURIED")
		await _t("D11_T_BURIED")
	elif int(GameState.flags.get("direnc", 0)) >= 1:
		await _n("D11_N_BYZ")
		await _t("D11_T_BYZ")
	await _n("D11_N_01")
	await _t("D11_T_02")
	await _n("D11_N_03")
	await _t("D11_T_04")
	await _n("D11_N_05")
	# Araya girenler
	if GameState.chapter_outcomes.get(8, "") == "8.4":
		await _hikmet_interrupts()
		_busy = false
		return
	if GameState.flags.get("niko_friend", false):
		await _niko_interrupts()
		_busy = false
		return
	await _nihat_decides()
	_busy = false


func _hikmet_interrupts() -> void:
	var h := Hikmet.new()
	h.position = _tolga_at + Vector3(-2.4, 0, 1.2)
	h.look_target = player
	add_child(h)
	await _say("SPK_HIKMET", "D11_H_01")
	player.face(h.global_position + Vector3(0, 1.4, 0))
	await _n("D11_N_H_02")
	await _say("SPK_HIKMET", "D11_H_03")
	await _n("D11_N_H_04")
	await _say("SPK_HIKMET", "D11_H_05")
	await _n("D11_N_H_06")
	await _say("SPK_HIKMET", "D11_H_07")
	# Bu arada Tolga sıvışır
	var tw := create_tween()
	tw.tween_property(tolga_npc, "position", tolga_npc.position + Vector3(-9, 0, -4), 1.6 if not GameState.autotest else 0.05)
	await tw.finished
	player.face(tolga_npc.global_position + Vector3(0, 1.4, 0))
	await _n("D11_N_H_08")
	GameState.flags["hn_rel_locked"] = true
	_outcome = "11.5"


func _niko_interrupts() -> void:
	var niko := Person.new({"face": "niko", "coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true, "beard": true, "skin": Color("d9a07a")})
	niko.position = _tolga_at + Vector3(2.6, 0, 1.0)
	niko.look_target = player
	add_child(niko)
	await _say("SPK_NIKO", "D11_NK_01")
	var hen := Chicken.new()
	hen.position = niko.position + Vector3(0, 1.4, 0)
	add_child(hen)
	var tw := create_tween()
	tw.tween_property(hen, "position", player.global_position + Vector3(0, 1.9, 0), 0.6 if not GameState.autotest else 0.05)
	await tw.finished
	player.shake(0.4)
	await _n("D11_N_NK_02")
	await _say("SPK_NIKO", "D11_NK_03")
	await _n("D11_N_NK_04")
	_outcome = "11.6"


## ⏱ Nihat'ın kararı.
func _nihat_decides() -> void:
	await _n("D11_N_DECIDE")
	var pick: int = {"arrest": 0, "escape": 0, "persuade": 0, "help": 2, "helpwall": 2}.get(GameState.autotest_variant, 1)
	var c := await hud.choose(["UI_CH11_ARREST", "UI_CH11_RELEASE", "UI_CH11_HELP"], 10.0, pick)
	if c < 0:
		await _n("D11_N_FROZE")
		c = 0
	if c == 2:
		var ok := false
		if GameState.flags.get("nihat_rulefree", false):
			ok = true
		elif _loyalty() < 35.0:
			await _n("D11_N_WALL")
			ok = await RegulationWall.run(hud, player, GameState.autotest_variant == "helpwall")
			if ok:
				GameState.flags["nihat_rulefree"] = true
				await _n("D11_N_WALL_TORN")
			else:
				GameState.flags["sadakat"] = 50
				hud.meters.set_loyalty(50.0)
				await _n("D11_N_WALL_KEPT")
		else:
			await _n("D11_N_CANT_HELP")
		if ok:
			await _switch_to_tolga()
			await _tolga_helped()
			return
		c = 1
	await _switch_to_tolga()
	if c == 1:
		await _tolga_released()
	else:
		await _tolga_arrested()


## Kontrol el değiştirir: Nihat'ın gözünden Tolga'nın gözüne.
func _switch_to_tolga() -> void:
	await hud.fade_to(1.0, 0.5)
	var nihat_spot := player.global_position
	nihat_npc = Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
		"hair": Color("3a2a1e"), "skin": Color("ecb892")})
	nihat_npc.position = Vector3(nihat_spot.x, 0, nihat_spot.z)
	add_child(nihat_npc)
	tolga_npc.visible = false
	player.hand_style = "tolga"
	player.hand.queue_free()
	player.scanner_screen = null
	player._hand_shown = false
	player._build_hand()
	player.show_remote(true)
	player.global_position = _tolga_at + Vector3(0, 0.05, 0)
	player.face(nihat_npc.global_position + Vector3(0, 1.5, 0))
	nihat_npc.look_target = player
	hud.set_nihat_mode(false)
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.update_bag(GameState.bag)
	await hud.card([[tr("UI_CH11_SWITCH"), 26, Color("f2e6c9")]], 1.0)
	hud.clear_card()
	await hud.fade_to(0.0, 0.5)


func _tolga_released() -> void:
	await _say("SPK_NIHAT", "D11_N_RELEASE")
	await _t("D11_T_RELEASE")
	GameState.flags["buro_baskisi"] = int(GameState.flags.get("buro_baskisi", 0)) + 1
	_outcome = "11.2"


func _tolga_helped() -> void:
	await _say("SPK_NIHAT", "D11_N_HELP_1")
	await _t("D11_T_HELP_2")
	await _say("SPK_NIHAT", "D11_N_HELP_3")
	await _t("D11_T_HELP_4")
	GameState.flags["nihat_joined"] = true
	_outcome = "11.3"


## Tutuklama: Tolga'nın üç turu. İkna olasılığı %70'e ulaşırsa Nihat bırakır.
func _tolga_arrested() -> void:
	await _say("SPK_NIHAT", "D11_N_ARREST")
	_persuade = 25.0 + int(GameState.flags.get("hn_rel", 0)) * 10.0
	_show_persuade()
	var plan: Array = {"arrest": ["surrender"], "escape": ["chickpeas", "honest", "run"],
		"persuade": ["chickpeas", "honest", "insurance"]}.get(GameState.autotest_variant, ["surrender"])
	for turn in TURNS:
		var keys: Array = []
		var ids: Array = []
		for id in GameState.bag:
			if not _used.has(id):
				keys.append(Items.name_key(id))
				ids.append(id)
		for opt in ["honest", "insurance", "run", "surrender"]:
			if not _used.has(opt):
				keys.append("UI_CH11_T_" + opt.to_upper())
				ids.append(opt)
		var want: String = plan[mini(turn, plan.size() - 1)]
		var c := await hud.choose(keys, 9.0, maxi(0, ids.find(want)))
		if c < 0:
			await _say("SPK_NIHAT", "D11_N_T_SILENT")
			continue
		var pick: String = ids[c]
		_used[pick] = true
		match pick:
			"surrender":
				await _t("D11_T_SURRENDER")
				await _arrested()
				return
			"run":
				await _t("D11_T_RUN")
				if _persuade >= 50.0:
					await _say("SPK_NIHAT", "D11_N_RUN_OK")
					GameState.flags["buro_baskisi"] = int(GameState.flags.get("buro_baskisi", 0)) + 1
					_outcome = "11.2"
				else:
					await _say("SPK_NIHAT", "D11_N_RUN_FAIL")
					await _arrested()
				return
			"honest":
				await _t("D11_T_HONEST")
				await _say("SPK_NIHAT", "D11_N_HONEST")
				_add_persuade(20.0)
			"insurance":
				await _t("D11_T_INSURANCE")
				await _say("SPK_NIHAT", "D11_N_INSURANCE")
				_add_persuade(10.0)
			_:
				var k := "D11_N_ITEM_" + pick.to_upper()
				await _say("SPK_NIHAT", k if tr(k) != k else "D11_N_ITEM_ANY")
				_add_persuade(15.0 if pick == "chickpeas" else 5.0)
		if _persuade >= 70.0:
			await _say("SPK_NIHAT", "D11_N_GIVE_UP")
			GameState.flags["buro_baskisi"] = int(GameState.flags.get("buro_baskisi", 0)) + 1
			_outcome = "11.2"
			hud.set_chase("", 0.0)
			return
	await _say("SPK_NIHAT", "D11_N_TIME_UP")
	await _arrested()


func _arrested() -> void:
	hud.set_chase("", 0.0)
	await _say("SPK_NIHAT", "D11_N_CUFF")
	await _t("D11_T_CUFF")
	GameState.flags["tolga_arrested"] = true
	_outcome = "11.1"


func _add_persuade(v: float) -> void:
	_persuade = clampf(_persuade + v, 0.0, 100.0)
	_show_persuade()


func _show_persuade() -> void:
	hud.set_chase(tr("UI_CH11_PERSUADE") % int(_persuade), _persuade / 100.0)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	hud.set_chase("", 0.0)
	GameState.set_outcome(11, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=11 -> %s outcome=%s" % [_next_scene().get_file(), _outcome])
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


## 11.1 → Bölüm 14 (Bekleme Salonu). Dal bölümü kapandıysa → 13. Yoksa → 12 (huzur).
func _next_scene() -> String:
	if _outcome == "11.1":
		return "res://scenes/chapter14.tscn"
	if GameState.chapter_outcomes.get(10, "10O.1") in SKIP_12:
		return "res://scenes/chapter13.tscn"
	if int(GameState.flags.get("direnc", 0)) >= 1:
		return "res://scenes/chapter12b.tscn"
	return "res://scenes/chapter12.tscn"


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW11_TITLE")
	c.nodes = [
		{"id": "night", "key": "FLOW11_NIGHT", "pos": Vector2(0.5, 0.13)},
		{"id": "11.4", "key": "FLOW_11_4", "pos": Vector2(0.86, 0.26), "outcome": true},
		{"id": "face", "key": "FLOW11_FACE", "pos": Vector2(0.4, 0.28)},
		{"id": "11.5", "key": "FLOW_11_5", "pos": Vector2(0.1, 0.42), "outcome": true},
		{"id": "11.6", "key": "FLOW_11_6", "pos": Vector2(0.1, 0.56), "outcome": true},
		{"id": "nihat", "key": "FLOW11_NIHAT", "pos": Vector2(0.45, 0.44)},
		{"id": "tolga", "key": "FLOW11_TOLGA", "pos": Vector2(0.32, 0.62)},
		{"id": "11.1", "key": "FLOW_11_1", "pos": Vector2(0.22, 0.8), "outcome": true},
		{"id": "11.2", "key": "FLOW_11_2", "pos": Vector2(0.5, 0.8), "outcome": true},
		{"id": "11.3", "key": "FLOW_11_3", "pos": Vector2(0.78, 0.62), "outcome": true},
	]
	c.edges = [["night", "face"], ["night", "11.4"], ["face", "11.5"], ["face", "11.6"], ["face", "nihat"],
		["nihat", "tolga"], ["nihat", "11.3"], ["nihat", "11.2"], ["tolga", "11.1"], ["tolga", "11.2"]]
	c.taken["night"] = true
	if _outcome != "11.4":
		c.taken["face"] = true
	if _outcome in ["11.1", "11.2", "11.3"]:
		c.taken["nihat"] = true
	if _outcome == "11.1" or (_outcome == "11.2" and not _used.is_empty()):
		c.taken["tolga"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH11_STATS") % [int(_loyalty()), int(GameState.flags.get("buro_baskisi", 0)), int(GameState.flags.get("hn_rel", 0))],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW11_NEXT_WAIT") if _outcome == "11.1" else (tr("UI_FLOW11_NEXT_13") if _next_scene().ends_with("chapter13.tscn") else (tr("UI_FLOW11_NEXT_12B") if _next_scene().ends_with("chapter12b.tscn") else tr("UI_FLOW11_NEXT"))),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	hud.set_prompt(tr("UI_PROMPT11_TOLGA") if id == "tolga" and phase == "seek" and not _busy else "")


func _on_interact(id: String) -> void:
	if id == "tolga" and phase == "seek":
		_confront()


# ================================================================ yardımcılar

func _n(key: String) -> void:
	await hud.say("SPK_NIHAT", key)


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _say(speaker: String, key: String) -> void:
	var who: Person = nihat_npc if speaker == "SPK_NIHAT" else null
	if speaker == "SPK_TOLGA" and tolga_npc and tolga_npc.visible:
		who = tolga_npc
	if who:
		who.talking = true
	await hud.say(speaker, key)
	if who and is_instance_valid(who):
		who.talking = false


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var expected: String = {"": "11.2", "arrest": "11.1", "escape": "11.2", "persuade": "11.2", "help": "11.3",
		"helpwall": "11.3", "lost": "11.4", "fired": "11.4", "hikmet": "11.5", "niko": "11.6", "next": "11.2"}[GameState.autotest_variant]
	var ok := _outcome == expected
	match GameState.autotest_variant:
		"fired":
			ok = ok and GameState.flags.get("nihat_dismissed", false)
		"helpwall":
			ok = ok and GameState.flags.get("nihat_rulefree", false)
		"arrest":
			ok = ok and GameState.flags.get("tolga_arrested", false)
		"persuade":
			ok = ok and not _used.has("run")
	if GameState.chapter_outcomes.get(11, "") != _outcome:
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=11 variant=%s outcome=%s persuade=%d sadakat=%d baski=%d" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, _outcome, int(_persuade), int(_loyalty()),
		int(GameState.flags.get("buro_baskisi", 0))])
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
	await get_tree().create_timer(1.0).timeout
	phase = "seek"
	hud.set_objective(tr("UI_OBJ11"))
	player.global_position = _tolga_at + Vector3(2.0, 0.05, 6.0)
	player.face(tolga_npc.global_position + Vector3(0, 1.4, 0))
	tolga_npc.look_target = player
	hud.bark("SPK_NIHAT", "D11_N_01", 30.0)
	await get_tree().create_timer(0.5).timeout
	await _shot("c11_01_yuzlesme.png")
	phase = "talk"
	hud.set_chase("", 0.0)
	hud.set_objective("")
	await _switch_to_tolga()
	_persuade = 55.0
	_show_persuade()
	hud.bark("SPK_NIHAT", "D11_N_HONEST", 30.0)
	hud.choose(["UI_CH11_T_HONEST", "UI_CH11_T_INSURANCE", "UI_CH11_T_RUN", "UI_CH11_T_SURRENDER"], 9.0, 0)
	await get_tree().create_timer(0.8).timeout
	await _shot("c11_02_tolga.png")
	get_tree().quit()
