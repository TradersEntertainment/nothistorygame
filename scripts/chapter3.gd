extends Node3D
## Bölüm 3 — Vaka 1453-T (Nihat · Zaman Bürosu ve Hikmet'in garajı). CHAPTERS §7, Bölüm 3.
##
## Akış: Nihat'ın odası (pnömatik tüpten dosya, Form Z-1) → Başdenetçi Müfide Hanım'ın
## brifingi → kostüm deposu (fötr şapka) → saha asansörü → 2026, Hikmet'in garajı →
## Paradoks İzi (isteğe bağlı: leblebi kabukları, fes püskülü, koli bandı + tekmenin
## hologramı) → Hikmet'in sorgusu (doğruyu söyletme olasılığı %) → yalanı yakala ya da
## geç → ⏱ makineye ne yapılacak → 5 sonuç ve akış şeması.
##
## Sonuçlar: 3.1 el konuldu · 3.2 mühürlendi · 3.3 bırakıldı, kartvizit · 3.4 eli boş ·
## 3.5 çay içildi.
##   --autotest[=tea|confiscate|seal|lie]   (varsayılan: 3.3)

const PERSUADE_BASE := 30.0
const TRACE_BONUS := 15.0
const REL_NAMES := {-2: "UI_REL_ENEMY", -1: "UI_REL_COLD", 0: "UI_REL_NEUTRAL", 1: "UI_REL_FRIEND", 2: "UI_REL_PARTNER"}

var bureau: Bureau
var garage: Garage
var hikmet: Hikmet
var player: Player
var hud: Hud
var phase := "intro"    # intro, office, bureau, garage, interro, done
var _outcome := ""
var _done: Dictionary = {}
var _clues: Dictionary = {}
var _approach := ""
var _persuade := PERSUADE_BASE
var _busy := false
var _flavor_idx: Dictionary = {}
var _clue_nodes: Dictionary = {}


func _ready() -> void:
	GameState.snapshot(3)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(_on_focus)
	player.frozen = true
	hud.set_nihat_mode(true)
	hud.set_fez(false)
	hud.meters.loyalty = _loyalty()
	hud.meters._shown_loyalty = _loyalty()
	_load_bureau()
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _loyalty() -> float:
	return float(GameState.flags.get("sadakat", 60))


func _add_loyalty(d: int) -> void:
	GameState.flags["sadakat"] = clampi(int(_loyalty()) + d, 0, 100)
	hud.meters.set_loyalty(_loyalty())


func _set_persuade(v: float) -> void:
	_persuade = clampf(v, 0.0, 100.0)
	hud.meters.set_persuade(_persuade)


# ================================================================ sahneler

func _load_bureau() -> void:
	bureau = Bureau.new()
	add_child(bureau)
	player.global_position = Bureau.SPAWN_POS
	player.face(Vector3(0, 1.2, 4.3))
	bureau.mufide.look_target = player
	bureau.riza.look_target = player


func _load_garage() -> void:
	bureau.queue_free()
	bureau = null
	garage = Garage.new()
	add_child(garage)
	garage.spin = 0.3
	# Tolga'nın aldığı eşyalar raflarda yok
	for id in GameState.bag:
		if garage.items.has(id):
			garage.set_item_visible(id, false)
	for id in garage.items:
		(garage.items[id]["body"] as StaticBody3D).collision_layer = 0
	if GameState.flags.get("panel_cracked", false):
		garage.panel_screen.modulate = Color("ff5a4a")
	garage.panel_screen.text = "14:53"
	hikmet = Hikmet.new()
	hikmet.position = Garage.HIKMET_POS
	add_child(hikmet)
	hikmet.look_target = player
	_build_clues()
	player.global_position = Garage.SPAWN_POS + Vector3(0.6, 0, 0.3)
	player.face(hikmet.global_position + Vector3(0, 1.3, 0))


## Paradoks İzi ipuçları: leblebi kabukları, fes püskülü ipi, koli bandı parçaları.
func _build_clues() -> void:
	var shells := Node3D.new()
	shells.position = Vector3(-2.85, 0.0, 1.0)
	garage.add_child(shells)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	for i in 14:
		Props.ball(shells, 0.018, Vector3(rng.randf_range(-0.25, 0.25), 0.01, rng.randf_range(-0.2, 0.2)), Color("d9b98a"), Vector3(1.2, 0.5, 1.0), 5)
	_clue(shells, "clue:shells", Vector3(0.7, 0.4, 0.6))
	var tassel := Node3D.new()
	tassel.position = Garage.PLATFORM_POS + Vector3(0.45, 0.09, 0.35)
	garage.add_child(tassel)
	Props.cyl(tassel, 0.006, 0.22, Vector3(0.0, 0.006, 0), Color("141414"), Vector3(0, 30, 90), 4)
	Props.ball(tassel, 0.03, Vector3(0.11, 0.02, 0.06), Color("141414"), Vector3(1, 0.6, 1), 6)
	_clue(tassel, "clue:fez", Vector3(0.6, 0.4, 0.6))
	var tape := Node3D.new()
	tape.position = garage.panel_node.global_position + Vector3(-0.35, 0.0, 0.35)
	garage.add_child(tape)
	for i in 5:
		Props.box(tape, Vector3(0.09, 0.005, 0.04), Vector3(rng.randf_range(-0.15, 0.15), 0.003, rng.randf_range(-0.12, 0.12)), Garage.C_TAPE, Vector3(0, rng.randf_range(0, 180), 0))
	_clue(tape, "clue:tape", Vector3(0.7, 0.5, 0.7))


func _clue(node: Node3D, id: String, size: Vector3) -> void:
	_clue_nodes[id] = node
	Props.interactable(node, id, size, Vector3(0, size.y / 2.0, 0))
	# Tarayıcı işareti: hafifçe parlayan halka
	var ring := Props.ring(node, 0.16, 0.2, Vector3(0, 0.01, 0), Color("6ff2c8"), Vector3.ZERO, 1.5)
	ring.name = "Marker"


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH3_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH3_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)

	# Nihat'ın odası: pnömatik tüp
	phase = "office"
	await _n("D3_N_01")
	bureau.capsule.visible = true
	var tw := create_tween()
	tw.tween_property(bureau.capsule, "position:y", 0.98, 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tw.finished
	player.shake(0.3)
	bureau.file_node.visible = true
	(bureau.file_node.get_child(bureau.file_node.get_child_count() - 1) as StaticBody3D).collision_layer = 2
	await _n("D3_N_02")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ3_FILE"))
	await _step("file", _take_file)
	hud.set_objective(tr("UI_OBJ3_MUFIDE"))
	phase = "bureau"
	await _step("mufide", _briefing)
	hud.set_objective(tr("UI_OBJ3_DEPOT"))
	await _step("riza", _depot)
	hud.set_objective(tr("UI_OBJ3_LIFT"))
	await _step("lift", _lift)

	# 2026: garaj
	phase = "garage"
	await _garage_intro()
	hud.set_objective(tr("UI_OBJ3_TRACE") % _clues.size())
	player.frozen = false
	await _step("hikmet", _interrogation)
	await _end_chapter()


## Etkileşimle tamamlanan adım. Otomatik testte adım doğrudan oynatılır.
func _step(id: String, handler: Callable) -> void:
	if GameState.autotest:
		if id == "hikmet" and GameState.autotest_variant != "lie":
			for c in ["clue:shells", "clue:fez", "clue:tape"]:
				await _scan(c)
		await handler.call()
		return
	while not _done.has(id):
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame


# ---------------------------------------------------------------- Büro

func _take_file() -> void:
	_busy = true
	player.frozen = true
	bureau.file_node.visible = false
	(bureau.file_node.get_child(bureau.file_node.get_child_count() - 1) as StaticBody3D).collision_layer = 0
	await _n("D3_N_03")
	await _n("D3_N_04")
	player.frozen = false
	_done["file"] = true
	_busy = false


func _briefing() -> void:
	_busy = true
	player.frozen = true
	player.face(bureau.mufide.global_position + Vector3(0, 1.4, 0))
	await _m("D3_M_05")
	await _n("D3_N_06")
	await _m("D3_M_07")
	await _m("D3_M_08")
	var c := await hud.choose(["UI_CH3_TONE_RULE", "UI_CH3_TONE_SOFT"], 10.0, 0)
	if c == 1:
		_add_loyalty(-5)
		await _m("D3_M_09B")
	else:
		_add_loyalty(5)
		await _m("D3_M_09A")
	await bureau.mufide.stamp()
	await _m("D3_M_10")
	player.frozen = false
	_done["mufide"] = true
	_busy = false


func _depot() -> void:
	_busy = true
	player.frozen = true
	player.face(bureau.riza.global_position + Vector3(0, 1.4, 0))
	await _say("SPK_RIZA", "D3_R_11")
	bureau.fedora_node.visible = true
	await _n("D3_N_12")
	await _say("SPK_RIZA", "D3_R_13")
	var c := await hud.choose(["UI_CH3_TAKE_HAT", "UI_CH3_ASK_FEZ"], 10.0, 0)
	if c == 1:
		await _say("SPK_RIZA", "D3_R_14B")
	await _n("D3_N_14")
	bureau.fedora_node.visible = false
	hud.set_fez(true)
	GameState.flags["nihat_fedora"] = true
	await _say("SPK_RIZA", "D3_R_15")
	player.frozen = false
	_done["riza"] = true
	_busy = false


func _lift() -> void:
	_busy = true
	player.frozen = true
	hud.set_objective("")
	await bureau.open_lift()
	await _n("D3_N_16")
	await hud.fade_to(1.0, 0.8, Color.WHITE)
	_load_garage()
	await hud.card([[tr("UI_CH3_GARAGE"), 30, Color("1d2330")]], 1.8)
	hud.clear_card()
	await hud.fade_to(0.0, 0.8, Color.WHITE)
	_done["lift"] = true
	_busy = false


# ---------------------------------------------------------------- garaj

func _garage_intro() -> void:
	player.frozen = true
	await _h("D3_H_17")
	await _n("D3_N_18")
	await _h("D3_H_19")
	await _n("D3_N_20")
	await _h("D3_H_21")
	await _h("D3_H_22")
	# Hikmet çay koymaya tezgâha gider: bu sırada iz taranabilir
	hikmet.look_target = null
	var tw := create_tween()
	hikmet.rotation.y = atan2(-1.9, 0.9)
	tw.tween_property(hikmet, "position", Vector3(-3.1, 0, -0.9), 1.6)
	await tw.finished
	hikmet.rotation.y = -PI / 2
	hud.bark("SPK_NIHAT", "D3_N_23", 4.0)


## Bir ipucunu tara: kısa bir tarama, Nihat'ın yorumu. Koli bandı tekmenin hologramını oynatır.
func _scan(id: String) -> void:
	if _clues.has(id) or _busy:
		return
	_busy = true
	player.frozen = true
	var node: Node3D = _clue_nodes[id]
	player.face(node.global_position + Vector3(0, 0.1, 0))
	for i in 5:
		hud.set_prompt(tr("UI_SCANNING") + " " + "▮".repeat(i + 1) + "▯".repeat(4 - i))
		await _wait(0.2)
	hud.set_prompt("")
	_clues[id] = true
	var marker := node.get_node_or_null("Marker")
	if marker:
		marker.queue_free()
	match id:
		"clue:shells":
			await _n("D3_N_SHELLS" if "chickpeas" in GameState.bag else "D3_N_SHELLS_NO")
		"clue:fez":
			await _n("D3_N_FEZ")
		"clue:tape":
			await _n("D3_N_TAPE")
			await _replay_kick()
	hud.set_objective(tr("UI_OBJ3_TRACE") % _clues.size())
	if _clues.size() == 3:
		GameState.flags["ch3_trace"] = true
		await _n("D3_N_TRACE_DONE")
		hud.set_objective(tr("UI_OBJ3_HIKMET"))
	player.frozen = false
	_busy = false


## Kalkış anının hologramı: Bölüm 1'de tekmeyi kim attıysa o.
func _replay_kick() -> void:
	var tolga_kicked: bool = GameState.chapter_outcomes.get(1, "1.1") == "1.2"
	var k := garage.panel_node.global_position
	var spot := k + Vector3(-0.75, 0, 0.35)
	var holo: Node3D
	if tolga_kicked:
		var p := Person.new({"coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez"})
		holo = p
	else:
		holo = Hikmet.new()
	holo.position = spot
	add_child(holo)
	holo.rotation.y = atan2(k.x - spot.x, k.z - spot.z)
	await get_tree().process_frame
	Person.make_hologram(holo)
	_no_interact(holo)
	player.face(spot + Vector3(0.3, 0.9, 0))
	await _wait(0.4)
	if tolga_kicked:
		(holo as Person).kick_hit.connect(func(): player.shake(0.3), CONNECT_ONE_SHOT)
		hud.bark("SPK_NIHAT", "D3_N_HOLO_TOLGA", 3.5)
		await (holo as Person).kick()
	else:
		(holo as Hikmet).kick_hit.connect(func(): player.shake(0.3), CONNECT_ONE_SHOT)
		hud.bark("SPK_NIHAT", "D3_N_HOLO_HIKMET", 3.5)
		await (holo as Hikmet).kick(k, spot)
	await _wait(0.3)
	var tw := create_tween()
	tw.tween_property(holo, "scale", Vector3(1, 0.01, 1), 0.3)
	await tw.finished
	holo.queue_free()
	GameState.flags["ch3_holo"] = "tolga" if tolga_kicked else "hikmet"


# ---------------------------------------------------------------- sorgu

func _interrogation() -> void:
	_busy = true
	phase = "interro"
	player.frozen = true
	hud.set_objective("")
	var trace: bool = GameState.flags.get("ch3_trace", false)
	# Hikmet çayla gelir, karşılıklı otururlar
	var tw := create_tween()
	tw.tween_property(hikmet, "position", Vector3(-1.2, 0, 0.2), 1.0)
	await tw.finished
	hikmet.look_target = player
	player.global_position = Vector3(0.3, 0, 1.2)
	player.face(hikmet.global_position + Vector3(0, 1.35, 0))
	_set_persuade(PERSUADE_BASE + (TRACE_BONUS if trace else 0.0))
	if trace:
		hud.bark("SPK_NIHAT", "D3_N_TRACE_BONUS", 2.5)
	await _h("D3_H_24")
	var pick: int = {"tea": 2, "confiscate": 0, "seal": 0}.get(GameState.autotest_variant, 1)
	var c := await hud.choose(["UI_CH3_APP_RULE", "UI_CH3_APP_KIND", "UI_CH3_APP_TEA"], 12.0, pick)
	if c == -1:
		await _n("D3_N_FREEZE")
		c = 0
	match c:
		0:
			_approach = "rule"
			_set_persuade(_persuade + 10)
			await _n("D3_N_RULE")
			await _h("D3_H_RULE")
			await _h("D3_H_LIE_RULE")
		1:
			_approach = "kind"
			_set_persuade(_persuade + 15)
			await _n("D3_N_KIND")
			await _h("D3_H_KIND")
			await _h("D3_H_LIE_KIND")
			await _n("D3_N_LIE_KIND_SLIP")
		_:
			_approach = "tea"
			_set_persuade(_persuade + 20)
			_add_loyalty(-15)
			await _n("D3_N_TEA")
			await _h("D3_H_TEA_1")
			await _h("D3_H_TEA_2")
			await _h("D3_H_TEA_3")
			_set_persuade(100)
			await _rule_7c()
			_outcome = "3.5"
			await _n("D3_N_END_35")
			await _h("D3_H_END_35")
			_busy = false
			return

	# Yalan: yakala ya da geç (⏱)
	var lie_pick := 1 if GameState.autotest_variant == "lie" else 0
	var call := await hud.choose(["UI_CH3_CALL_LIE", "UI_CH3_ACCEPT_LIE"], 7.0, lie_pick)
	var caught := false
	if call == 0:
		if trace:
			await _n("D3_N_EVIDENCE_" + ("TOLGA" if GameState.flags.get("ch3_holo", "hikmet") == "tolga" else "HIKMET"))
			caught = true
		else:
			var roll := randf() * 100.0
			if GameState.autotest:
				roll = 0.0
			caught = roll < _persuade
			await _n("D3_N_CALL")
		if not caught:
			await _h("D3_H_DOUBLE_DOWN")
	if not caught:
		_outcome = "3.4"
		GameState.flags["buro_baskisi"] = int(GameState.flags.get("buro_baskisi", 0)) + 1
		_set_persuade(-1)
		await _n("D3_N_END_34")
		await _h("D3_H_END_34")
		# Nihat gidince Hikmet telsize fısıldar
		player.face(hikmet.global_position + Vector3(0, 1.2, 0))
		await _h("D3_H_END_34B")
		_busy = false
		return

	_set_persuade(100)
	await _h("D3_H_CONFESS_1")
	await _h("D3_H_CONFESS_2")
	await _rule_7c()
	# ⏱ Makineye ne yapılacak?
	var keys := ["UI_CH3_CONFISCATE", "UI_CH3_SEAL"] if _approach == "rule" else ["UI_CH3_CARD", "UI_CH3_SEAL"]
	var dpick: int = {"confiscate": 0, "seal": 1}.get(GameState.autotest_variant, 0)
	var d := await hud.choose(keys, 8.0, dpick)
	var action := "seal"
	if d == 0:
		action = "confiscate" if _approach == "rule" else "card"
	match action:
		"confiscate":
			_outcome = "3.1"
			_add_loyalty(10)
			await _n("D3_N_END_31")
			await _confiscate_fx()
			await _h("D3_H_END_31")
			await _n("D3_N_END_31B")
		"card":
			_outcome = "3.3"
			_add_loyalty(-10)
			await _n("D3_N_END_33")
			await _h("D3_H_END_33")
			await _n("D3_N_END_33B")
		_:
			_outcome = "3.2"
			await _n("D3_N_END_32")
			await _seal_fx()
			await _h("D3_H_END_32")
	_busy = false


## Hologramın etkileşim alanını kapatır (hologram Hikmet'e "konuş" denmesin).
func _no_interact(node: Node) -> void:
	for c in node.get_children():
		if c is StaticBody3D:
			(c as StaticBody3D).collision_layer = 0
		_no_interact(c)


func _rule_7c() -> void:
	await _n("D3_N_7C_1")
	await _n("D3_N_7C_2")
	await _h("D3_H_7C")
	await _n("D3_N_7C_3")


## 3.1: makineye "EL KONULDU" etiketi, parlayıp Büro deposuna ışınlanır.
func _confiscate_fx() -> void:
	var m := garage.get_node("Zamanator") as Node3D
	var tag := Props.label(m, tr("UI_CH3_TAG_CONFISCATED"), Vector3(0, 1.3, 1.05), 40, Color("ff5a4a"), Vector3.ZERO, 1.4)
	tag.outline_size = 8
	await _wait(0.6)
	var tw := create_tween()
	tw.tween_property(garage.machine_light, "light_energy", 12.0, 0.5)
	tw.parallel().tween_property(m, "scale", Vector3(0.01, 1.4, 0.01), 0.6).set_ease(Tween.EASE_IN)
	await tw.finished
	m.visible = false
	garage.panel_node.visible = false
	garage.machine_light.light_energy = 0.0
	player.shake(0.6)
	GameState.flags["machine"] = "confiscated"


## 3.2: halkalara çapraz kırmızı "MÜHÜRLÜDÜR" bantları.
func _seal_fx() -> void:
	var m := garage.get_node("Zamanator") as Node3D
	for a in [-35.0, 35.0]:
		Props.box(m, Vector3(2.3, 0.14, 0.02), Vector3(0, 1.25, 1.13), Color("c8323a"), Vector3(0, 0, a))
	var tag := Props.label(m, tr("UI_CH3_TAG_SEALED"), Vector3(0, 1.25, 1.16), 36, Color("fff3d8"), Vector3.ZERO, 1.0)
	tag.outline_size = 8
	garage.spin = 0.0
	player.shake(0.3)
	GameState.flags["machine"] = "sealed"
	await _wait(0.5)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	hud.meters.set_persuade(-1)
	var rel: int = {"3.1": -2, "3.2": -1, "3.3": 0, "3.4": 0, "3.5": 1}[_outcome]
	GameState.flags["hn_rel"] = rel
	if not GameState.flags.has("machine"):
		GameState.flags["machine"] = "free"
	if _outcome in ["3.3", "3.5"]:
		GameState.flags["nihat_card"] = true
	GameState.set_outcome(3, _outcome)
	# Nihat raporunu daktiloya geçer
	await hud.fade_to(1.0, 0.8)
	var report := tr("UI_CH3_REPORT_" + _outcome.replace(".", "_"))
	await hud.card([[tr("UI_CH3_REPORT_HEAD"), 26, Color("f2e6c9")], [report, 20, Color(1, 1, 1, 0.85)]], 3.2)
	hud.clear_card()
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=3 -> 4 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter4.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter4.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW3_TITLE")
	c.nodes = [
		{"id": "brief", "key": "FLOW3_BRIEF", "pos": Vector2(0.5, 0.16)},
		{"id": "depot", "key": "FLOW3_DEPOT", "pos": Vector2(0.5, 0.25)},
		{"id": "trace", "key": "FLOW3_TRACE", "pos": Vector2(0.36, 0.35)},
		{"id": "skip", "key": "FLOW3_SKIP", "pos": Vector2(0.64, 0.35)},
		{"id": "interro", "key": "FLOW3_INTERRO", "pos": Vector2(0.5, 0.45)},
		{"id": "rule", "key": "FLOW3_RULE", "pos": Vector2(0.3, 0.55)},
		{"id": "kind", "key": "FLOW3_KIND", "pos": Vector2(0.7, 0.55)},
		{"id": "3.1", "key": "FLOW_3_1", "pos": Vector2(0.1, 0.68), "outcome": true},
		{"id": "3.2", "key": "FLOW_3_2", "pos": Vector2(0.3, 0.68), "outcome": true},
		{"id": "3.4", "key": "FLOW_3_4", "pos": Vector2(0.5, 0.68), "outcome": true},
		{"id": "3.3", "key": "FLOW_3_3", "pos": Vector2(0.7, 0.68), "outcome": true},
		{"id": "3.5", "key": "FLOW_3_5", "pos": Vector2(0.9, 0.68), "outcome": true},
	]
	c.edges = [["brief", "depot"], ["depot", "trace"], ["depot", "skip"], ["trace", "interro"], ["skip", "interro"],
		["interro", "rule"], ["interro", "kind"], ["interro", "3.5"],
		["rule", "3.1"], ["rule", "3.2"], ["rule", "3.4"], ["kind", "3.3"], ["kind", "3.2"], ["kind", "3.4"]]
	for id in ["brief", "depot", "interro"]:
		c.taken[id] = true
	c.taken["trace" if GameState.flags.get("ch3_trace", false) else "skip"] = true
	if _approach in ["rule", "kind"]:
		c.taken[_approach] = true
	c.taken[_outcome] = true
	for id in ["3.1", "3.2", "3.3", "3.4", "3.5"]:
		if GameState.has_seen(id):
			c.seen[id] = true
	var rel: int = GameState.flags.get("hn_rel", 0)
	c.footer_lines = [
		tr("UI_FLOW3_STATS") % [int(_loyalty()), tr(REL_NAMES[rel]), int(GameState.flags.get("buro_baskisi", 0))],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW3_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase in ["office", "bureau", "garage"]:
		if id == "file" and not _done.has("file"):
			p = tr("UI_PROMPT3_FILE")
		elif id == "mufide" and _done.has("file") and not _done.has("mufide"):
			p = tr("UI_PROMPT3_TALK") % tr("SPK_MUFIDE")
		elif id == "riza" and _done.has("mufide") and not _done.has("riza"):
			p = tr("UI_PROMPT3_TALK") % tr("SPK_RIZA")
		elif id == "lift" and _done.has("riza"):
			p = tr("UI_PROMPT3_LIFT")
		elif id.begins_with("clue:") and not _clues.has(id):
			p = tr("UI_PROMPT3_SCAN")
		elif id == "hikmet" and phase == "garage":
			p = tr("UI_PROMPT3_INTERRO")
		elif id in ["formz1", "clock", "window", "plant", "fezshelf"] or id.begins_with("door:"):
			p = tr("UI_PROMPT3_LOOK")
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy:
		return
	if id == "file" and not _done.has("file"):
		_take_file()
	elif id == "mufide" and _done.has("file") and not _done.has("mufide"):
		_briefing()
	elif id == "mufide" and _done.has("mufide"):
		hud.bark("SPK_MUFIDE", "D3_M_IDLE", 3.0)
	elif id == "riza" and _done.has("mufide") and not _done.has("riza"):
		_depot()
	elif id == "riza":
		hud.bark("SPK_RIZA", "D3_R_IDLE", 3.0)
	elif id == "lift" and _done.has("riza"):
		_lift()
	elif id == "lift":
		hud.bark("SPK_NIHAT", "D3_N_LIFT_EARLY", 3.0)
	elif id.begins_with("clue:"):
		_scan(id)
	elif id == "hikmet" and phase == "garage":
		_done["hikmet"] = true
		_interrogation()
	elif id.begins_with("door:"):
		var key := "D3_N_DOOR_" + id.trim_prefix("door:").replace(" ", "_")
		if tr(key) == key:
			key = "D3_N_DOOR"
		hud.bark("SPK_NIHAT", key, 3.5)
	elif id in ["formz1", "clock", "window", "plant", "fezshelf"]:
		hud.bark("SPK_NIHAT", "D3_N_LOOK_" + id.to_upper(), 4.5)
		if id == "formz1":
			GameState.flags["seen_z1"] = true
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _n(key: String) -> void:
	await hud.say("SPK_NIHAT", key)


func _h(key: String) -> void:
	hikmet.talking = true
	await hud.say("SPK_HIKMET", key)
	hikmet.talking = false


func _m(key: String) -> void:
	bureau.mufide.talking = true
	await hud.say("SPK_MUFIDE", key)
	bureau.mufide.talking = false


func _say(speaker: String, key: String) -> void:
	var who: Person = bureau.riza if speaker == "SPK_RIZA" and bureau else null
	if who:
		who.talking = true
	await hud.say(speaker, key)
	if who:
		who.talking = false


func _wait(s: float) -> void:
	if GameState.autotest:
		await get_tree().process_frame
		return
	await get_tree().create_timer(s).timeout


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ================================================================ otomatik test

func _autotest_report() -> void:
	var expected: String = {"": "3.3", "next": "3.3", "tea": "3.5", "confiscate": "3.1", "seal": "3.2", "lie": "3.4"}[GameState.autotest_variant]
	var ok := _outcome == expected
	if not ok:
		printerr("AUTOTEST: beklenen sonuç %s, gelen %s" % [expected, _outcome])
	if GameState.chapter_outcomes.get(3, "") != _outcome:
		ok = false
		printerr("AUTOTEST: bölüm sonucu kaydedilmedi")
	var trace_expected := GameState.autotest_variant != "lie"
	if GameState.flags.get("ch3_trace", false) != trace_expected:
		ok = false
		printerr("AUTOTEST: Paradoks İzi durumu yanlış")
	print("AUTOTEST %s chapter=3 variant=%s outcome=%s sadakat=%d rel=%d baski=%d machine=%s" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, _outcome, int(_loyalty()),
		int(GameState.flags.get("hn_rel", 0)), int(GameState.flags.get("buro_baskisi", 0)), GameState.flags.get("machine", "")])
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
	await get_tree().create_timer(0.6).timeout
	# 1. Nihat'ın odası: Form Z-1
	bureau.file_node.visible = true
	player.global_position = Vector3(0.6, 0, 2.2)
	player.face(Vector3(0, 1.7, 6.0))
	hud.set_objective(tr("UI_OBJ3_FILE"))
	hud.bark("SPK_NIHAT", "D3_N_LOOK_FORMZ1", 30.0)
	await _shot("c3_01_oda.png")
	# 2. Sonsuz koridor
	hud.set_objective(tr("UI_OBJ3_MUFIDE"))
	player.global_position = Vector3(0.9, 0, -2.0)
	player.face(Vector3(0, 1.4, -40.0))
	hud.bark("SPK_NIHAT", "D3_N_DOOR", 30.0)
	await _shot("c3_02_koridor.png")
	# 3. Başdenetçi
	player.global_position = Vector3(0.3, 0, Bureau.DESK_Z + 2.6)
	player.face(bureau.mufide.global_position + Vector3(0, 1.3, 0))
	hud.bark("SPK_MUFIDE", "D3_M_05", 30.0)
	await _shot("c3_03_mufide.png")
	# 4. Kostüm deposu
	hud.set_fez(true)
	bureau.fedora_node.visible = true
	player.global_position = Vector3(1.2, 0, -12.6)
	player.face(bureau.riza.global_position + Vector3(0.3, 1.2, -1.2))
	hud.bark("SPK_RIZA", "D3_R_13", 30.0)
	await _shot("c3_04_depo.png")
	# 5. Garaj: hologram tekme
	_load_garage()
	await get_tree().create_timer(0.3).timeout
	hud.set_objective(tr("UI_OBJ3_TRACE") % 2)
	var k := garage.panel_node.global_position
	var spot := k + Vector3(-0.75, 0, 0.35)
	var holo := Hikmet.new()
	holo.position = spot
	add_child(holo)
	holo.rotation.y = atan2(k.x - spot.x, k.z - spot.z)
	await get_tree().process_frame
	Person.make_hologram(holo)
	player.global_position = Vector3(-0.4, 0, 0.9)
	player.face(spot + Vector3(0.2, 0.8, 0))
	holo.kick(k, spot)
	await holo.kick_hit
	Engine.time_scale = 0.0
	hud.bark("SPK_NIHAT", "D3_N_HOLO_HIKMET", 30.0)
	await _shot("c3_05_iz.png")
	Engine.time_scale = 1.0
	holo.queue_free()
	# 6. Sorgu
	hud.set_objective("")
	hikmet.position = Vector3(-1.2, 0, 0.2)
	player.global_position = Vector3(0.3, 0, 1.2)
	player.face(hikmet.global_position + Vector3(0, 1.35, 0))
	_set_persuade(45)
	hud.meters.set_persuade(60)
	hud.choose(["UI_CH3_APP_RULE", "UI_CH3_APP_KIND", "UI_CH3_APP_TEA"], 12.0)
	await get_tree().create_timer(1.2).timeout
	await _shot("c3_06_sorgu.png")
	hud.choose_cancel()
	# 7. Mühür
	_seal_fx()
	hud.meters.set_persuade(-1)
	player.global_position = Vector3(0.9, 0, 1.4)
	player.face(Garage.PLATFORM_POS + Vector3(0, 1.2, 0))
	hud.bark("SPK_HIKMET", "D3_H_END_32", 30.0)
	await get_tree().create_timer(0.6).timeout
	await _shot("c3_07_muhur.png")
	# 8. Akış şeması
	_outcome = "3.3"
	_approach = "kind"
	GameState.flags["ch3_trace"] = true
	GameState.flags["hn_rel"] = 0
	GameState.seen_outcomes["3.5"] = true
	hud.set_fez(false)
	hud.add_child(_make_chart())
	await _shot("c3_08_akis.png")
	get_tree().quit()
