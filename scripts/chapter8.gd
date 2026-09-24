extends Node3D
## Bölüm 8 — Hırdavatçı (Hikmet · 2026, pazartesi 05:00). CHAPTERS Bölüm 8, §3.3.
##
## Hikmet, makineyi tamir etmek için gece açık tek hırdavatçıya gider: Nöbetçi Hırdavat, Cemil'in
## dükkânı. Büro'nun minibüsü peşindedir; iki ajan dükkâna girip el fenerleriyle reyonları gezer.
## ⏱ Servis saatine iki buçuk saat var (05:00 → 07:30). Ajanların ışığına yakalanırsan 10 dakika
## kaybedersin; üçüncüde sepete el konur.
##   Tamir listesi: 1453 µF kondansatör, anten (+ panel camı, Bölüm 1'de panel çatladıysa)
##   Depo planı (makineye el konulduysa): cıvata makası, laminasyon makinesi, gri yağmurluk
##   Tolga koli bandını götürdüyse: son bant, ajanların mühür çantasında.
## Nihat'ı ara (kartvizit varsa): Sadakat −5, ilişki +1. Nihat Kuralsızsa (7.5a) ajanları geri çağırır.
## Tamir tamamsa garajda ⏱ büyük karar: makineye kendin bin (8.4, H3) ya da kal (8.1).
##   8.1 tamir edildi · 8.2 parça bulunamadı · 8.3 Büro deposu planı · 8.4 Hikmet makineye bindi
##   --autotest[=ride|caught|late|heist|call|rulefree]   (varsayılan: 8.1)

const START_MIN := 300.0            # 05:00
const END_MIN := 450.0              # 07:30
const MIN_PER_SEC := 1.0
const CAUGHT_PENALTY := 10.0
const MAX_CATCHES := 3
const VIEW_DIST := 7.0
const VIEW_ANGLE := 32.0
const PART_KEYS := {"capacitor": "UI_PART8_CAPACITOR", "antenna": "UI_PART8_ANTENNA", "glass": "UI_PART8_GLASS",
	"tape": "UI_PART8_TAPE", "cutter": "UI_PART8_CUTTER", "laminator": "UI_PART8_LAMINATOR", "raincoat": "UI_PART8_RAINCOAT"}

var store: HardwareStore
var garage: Garage
var player: Player
var hud: Hud
var phase := "intro"                # intro, street, store, checkout, garage, done
var machine := "free"
var _outcome := ""
var _busy := false
var _clock := START_MIN
var _needed: Array = []
var _have: Dictionary = {}
var _catches := 0
var _met_cemil := false
var _called := false
var _agents: Array[Person] = []
var _routes: Array = []
var _state: Array = []              # her ajan için {"i": hedef, "wait": s, "aware": 0..1}
var _lamps: Array[SpotLight3D] = []


func _ready() -> void:
	GameState.snapshot(8)
	_apply_autotest_setup()
	machine = GameState.flags.get("machine", "free")
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	player.hand_style = "hikmet"
	add_child(player)
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(_on_focus)
	player.frozen = true
	hud.set_signal(GameState.telsiz_bag)
	hud.set_fez(false)
	store = HardwareStore.new()
	add_child(store)
	if machine == "confiscated":
		_needed = ["cutter", "laminator", "raincoat"]
	else:
		_needed = ["capacitor", "antenna"]
		if GameState.flags.get("panel_cracked", false):
			_needed.append("glass")
	if "tape" in GameState.bag:
		_needed.append("tape")
	for id in HardwareStore.PARTS:
		if not id in _needed:
			store.hide_part(id)
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
		"heist":
			GameState.flags["machine"] = "confiscated"
		"call":
			GameState.flags["nihat_card"] = true
		"rulefree":
			GameState.flags["nihat_card"] = true
			GameState.flags["nihat_rulefree"] = true


func _process(delta: float) -> void:
	if hud == null:
		return
	if phase == "store":
		if not _busy:
			_clock += delta * MIN_PER_SEC
			_update_objective()
			if _clock >= END_MIN and not GameState.autotest:
				_fail("late")
				return
		_patrol(delta)


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH8_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH8_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = HardwareStore.SPAWN
	player.face(Vector3(0, 2.8, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _h("D8_H_01")
	await _h("D8_H_PAJAMA")
	if "tape" in GameState.bag:
		await _h("D8_H_TAPE")
	player.face(HardwareStore.VAN_POS + Vector3(0, 1.4, 0))
	await _h("D8_H_VAN")
	await _say("SPK_VAN", "D8_V_01")
	player.face(Vector3(0, 1.6, -6.0))
	phase = "street"
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		await _auto()
	while _outcome == "":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	await _end_chapter()


func _physics_process(_delta: float) -> void:
	# Dükkâna girince Cemil'le tanışma ve ajanların gelişi
	if phase == "street" and not _busy and player.global_position.z < -1.5:
		_enter_store()


func _update_objective() -> void:
	var h := int(_clock / 60.0)
	var m := int(_clock) % 60
	var lines := PackedStringArray()
	for id in _needed:
		lines.append(("☑ " if _have.has(id) else "☐ ") + tr(PART_KEYS[id]))
	var head := tr("UI_OBJ8_HEIST" if machine == "confiscated" else "UI_OBJ8") % ["%02d:%02d" % [h, m], _catches, MAX_CATCHES]
	var ids: Array = []
	for id in _needed:
		ids.append("part:" + id)
	var target: Variant = hud.spot(ids, func(pid): return _have.has(str(pid).trim_prefix("part:")))
	var th := 0.3
	if phase == "street":
		head = tr("UI_OBJ8_ENTER")
		target = Vector3(0, 1.4, HardwareStore.DOOR_Z)
	elif _all_parts():
		head = tr("UI_OBJ8_PAY")
		target = hud.spot("cemil")
		th = 0.7
	hud.set_objective(head + "\n" + "   ".join(lines), target, th)


func _all_parts() -> bool:
	for id in _needed:
		if not _have.has(id):
			return false
	return true


func _enter_store() -> void:
	_busy = true
	player.frozen = true
	player.face(store.cemil.global_position + Vector3(0, 1.5, 0))
	store.cemil.look_target = player
	await _say("SPK_CEMIL", "D8_C_01")
	await _h("D8_H_C_02")
	await _say("SPK_CEMIL", "D8_C_03")
	await _h("D8_H_LIST_HEIST" if machine == "confiscated" else "D8_H_LIST")
	await _say("SPK_CEMIL", "D8_C_WHERE_HEIST" if machine == "confiscated" else "D8_C_WHERE")
	if "tape" in _needed:
		await _say("SPK_CEMIL", "D8_C_TAPE")
	_met_cemil = true
	# Ajanlar gelir
	_spawn_agents()
	player.face(Vector3(0, 1.6, 1.0))
	await _wait(0.6)
	await _say("SPK_AGENT1", "D8_A1_ENTER")
	await _say("SPK_CEMIL", "D8_C_TEA")
	await _say("SPK_AGENT2", "D8_A2_ENTER")
	await _h("D8_H_AGENTS")
	phase = "store"
	_update_objective()
	player.frozen = false
	_busy = false


# ---------------------------------------------------------------- ajanlar

func _spawn_agents() -> void:
	_routes = [
		[Vector3(-1.75, 0, -5.2), Vector3(-1.75, 0, -13.8), Vector3(-5.4, 0, -13.8), Vector3(-5.4, 0, -5.2)],
		[Vector3(5.3, 0, -13.8), Vector3(1.75, 0, -13.8), Vector3(1.75, 0, -5.2), Vector3(5.3, 0, -5.2)],
	]
	var names := ["SPK_AGENT1", "SPK_AGENT2"]
	for k in 2:
		var a := Person.new({"coat": Color("6a6e76"), "pants": Color("4a4e56"), "hat": "fedora", "glasses": k == 0,
			"mustache": k == 1, "hair": Color("2a2a2e"), "skin": Color("e8b894") if k == 0 else Color("c89070")})
		a.position = Vector3(-0.4 + k * 0.8, 0, 1.2)
		a.set_meta("speaker", names[k])
		add_child(a)
		# El feneri: önüne doğru (Person'un önü +Z)
		var lamp := SpotLight3D.new()
		lamp.position = Vector3(0.25, 1.25, 0.3)
		lamp.rotation_degrees = Vector3(-12, 180, 0)
		lamp.spot_angle = VIEW_ANGLE
		lamp.spot_range = VIEW_DIST + 1.0
		lamp.light_energy = 7.0
		lamp.light_color = Color("fff0c8")
		lamp.shadow_enabled = false
		a.add_child(lamp)
		Props.cyl(a, 0.03, 0.18, Vector3(0.25, 1.2, 0.25), Color("2a2a30"), Vector3(90, 0, 0), 6)
		_agents.append(a)
		_lamps.append(lamp)
		_state.append({"i": 0, "wait": 0.0, "aware": 0.0})


func _patrol(delta: float) -> void:
	var worst := 0.0
	for k in _agents.size():
		var a := _agents[k]
		if not is_instance_valid(a):
			continue
		var st: Dictionary = _state[k]
		var target: Vector3 = _routes[k][st["i"]]
		var to := target - a.position
		to.y = 0
		if st["wait"] > 0.0:
			st["wait"] -= delta
			a.rotation.y += sin(Time.get_ticks_msec() * 0.002 + k) * delta * 1.2
		elif to.length() < 0.1:
			st["i"] = (int(st["i"]) + 1) % _routes[k].size()
			st["wait"] = 1.4
		else:
			var step := minf(to.length(), 1.25 * delta)
			a.position += to.normalized() * step
			var want := atan2(to.x, to.z)
			a.rotation.y = lerp_angle(a.rotation.y, want, minf(1.0, delta * 6.0))
		# Görüş: mesafe, açı ve raflar
		if not _busy and not GameState.autotest:
			var eye := a.global_position + Vector3(0, 1.5, 0)
			var p := player.global_position
			var dv := p - a.global_position
			dv.y = 0
			var fwd := Vector3(sin(a.rotation.y), 0, cos(a.rotation.y))
			var seen := dv.length() < VIEW_DIST and rad_to_deg(fwd.angle_to(dv.normalized())) < VIEW_ANGLE * 0.6 \
				and not HardwareStore.blocked(eye, p)
			st["aware"] = clampf(float(st["aware"]) + (delta * 1.5 if seen else -delta * 0.6), 0.0, 1.0)
			worst = maxf(worst, st["aware"])
			if st["aware"] >= 1.0:
				st["aware"] = 0.0
				_caught(a)
	hud.set_chase(tr("UI_CH8_AWARE") if worst > 0.01 else "", worst)


func _caught(agent: Person) -> void:
	if _busy:
		return
	_busy = true
	player.frozen = true
	_catches += 1
	_clock += CAUGHT_PENALTY
	player.shake(0.3)
	player.face(agent.global_position + Vector3(0, 1.5, 0))
	agent.look_target = player
	var spk: String = agent.get_meta("speaker", "SPK_AGENT1")
	await _say(spk, "D8_A_CAUGHT_%d" % mini(_catches, MAX_CATCHES))
	if _catches >= MAX_CATCHES:
		_busy = false
		await _fail("caught")
		return
	await _h("D8_H_CAUGHT_%d" % _catches)
	agent.look_target = null
	# Kasanın önüne "buyur" edilir
	player.global_position = Vector3(3.2, 0.05, -1.8)
	player.face(Vector3(0, 1.4, -8.0))
	for st in _state:
		st["aware"] = 0.0
	_update_objective()
	player.frozen = false
	_busy = false


# ---------------------------------------------------------------- ürünler

func _pick(id: String) -> void:
	if _busy or _have.has(id) or not id in _needed:
		return
	_busy = true
	_have[id] = true
	store.take_part(id)
	player.shake(0.05)
	await _h("D8_H_GOT_" + id.to_upper())
	_update_objective()
	_busy = false


func _talk_cemil() -> void:
	if _busy:
		return
	if phase == "store" and _all_parts():
		await _checkout()
		return
	_busy = true
	player.frozen = true
	await _say("SPK_CEMIL", "D8_C_HINT")
	player.frozen = false
	_busy = false


## Sabit hattan Nihat'ı ara (kartvizit Bölüm 3'te bırakıldıysa).
func _phone(auto_pick := -1) -> void:
	if _busy or _called:
		return
	if not GameState.flags.get("nihat_card", false):
		hud.bark("SPK_HIKMET", "D8_H_NO_CARD", 3.0)
		return
	_busy = true
	player.frozen = true
	await _h("D8_H_PHONE")
	var c := await hud.choose(["UI_CH8_CALL", "UI_CH8_NO_CALL"], 0.0, auto_pick if auto_pick >= 0 else 1)
	if c != 0:
		player.frozen = false
		_busy = false
		return
	_called = true
	GameState.flags["ch8_called"] = true
	GameState.flags["hn_rel"] = mini(2, int(GameState.flags.get("hn_rel", 0)) + 1)
	GameState.flags["sadakat"] = int(GameState.flags.get("sadakat", 60)) - 5
	await _h("D8_H_CALL_1")
	await _say("SPK_NIHAT", "D8_N_CALL_2")
	await _h("D8_H_CALL_3")
	if GameState.flags.get("nihat_rulefree", false):
		await _say("SPK_NIHAT", "D8_N_RULEFREE")
		await _say("SPK_AGENT1", "D8_A1_RECALL")
		await _say("SPK_AGENT2", "D8_A2_RECALL")
		for a in _agents:
			var tw := a.create_tween()
			tw.tween_property(a, "position", Vector3(a.position.x * 0.2, 0, 3.0), 2.0)
			tw.tween_callback(a.queue_free)
		_agents.clear()
		_state.clear()
		_routes.clear()
		GameState.flags["ch8_agents_recalled"] = true
	else:
		await _say("SPK_NIHAT", "D8_N_HINT")
		await _h("D8_H_CALL_END")
	player.frozen = false
	_busy = false


# ---------------------------------------------------------------- sonlar

func _checkout() -> void:
	_busy = true
	phase = "checkout"
	player.frozen = true
	hud.set_chase("", 0.0)
	player.face(store.cemil.global_position + Vector3(0, 1.5, 0))
	await _say("SPK_CEMIL", "D8_C_PAY")
	await _h("D8_H_PAY")
	await _say("SPK_CEMIL", "D8_C_PAY2")
	if machine == "confiscated":
		await _heist_finale()
	else:
		await _garage_finale()
	_busy = false


## Makineye el konulmuştu: laminasyonla sahte Büro kartı. 8.3
func _heist_finale() -> void:
	await _h("D8_H_BADGE_1")
	await hud.fade_to(1.0, 0.5)
	await hud.card([[tr("UI_CH8_BADGE"), 34, Color("f2e6c9")], [tr("UI_CH8_BADGE_SUB"), 20, Color(1, 1, 1, 0.75)]], 2.4)
	hud.clear_card()
	await hud.fade_to(0.0, 0.5)
	await _say("SPK_CEMIL", "D8_C_BADGE")
	await _h("D8_H_BADGE_2")
	await _h("D8_H_BADGE_3")
	GameState.flags["depot_plan"] = true
	_outcome = "8.3"


## Tamir tamam: garaj, 07:10. ⏱ Makineye bin ya da kal.
func _garage_finale() -> void:
	phase = "garage"
	await hud.fade_to(1.0, 0.6)
	for a in _agents:
		if is_instance_valid(a):
			a.queue_free()
	_agents.clear()
	store.queue_free()
	store = null
	garage = Garage.new()
	add_child(garage)
	garage.spin = 0.0
	garage.panel_screen.text = "----"
	for id in garage.items:
		(garage.items[id]["body"] as StaticBody3D).collision_layer = 0
		if id in GameState.bag:
			garage.set_item_visible(id, false)
	player.global_position = Garage.SPAWN_POS + Vector3(0, 0.05, 0)
	player.face(Garage.PLATFORM_POS + Vector3(0, 1.3, 0))
	await hud.card([[tr("UI_CH8_GARAGE"), 30, Color("f2e6c9")]], 1.6)
	hud.clear_card()
	await hud.fade_to(0.0, 0.8)
	await _h("D8_H_G1")
	var tw := create_tween()
	tw.tween_property(garage, "spin", 1.0, 2.0)
	garage.machine_light.light_energy = 1.5
	garage.panel_screen.text = "1453"
	await _wait(1.2)
	await _h("D8_H_G2")
	if GameState.telsiz_bag > 0:
		var ch6: String = GameState.chapter_outcomes.get(6, "6a.1")
		await hud.say("SPK_TOLGA", "D8_T_RADIO_B" if ch6.begins_with("6b") else "D8_T_RADIO_A")
		await _h("D8_H_G3")
	else:
		await _h("D8_H_G3_NO")
	await _h("D8_H_G4")
	# ⏱ Büyük karar
	var pick := 0 if GameState.autotest_variant == "ride" else 1
	var c := await hud.choose(["UI_CH8_RIDE", "UI_CH8_STAY"], 10.0, pick)
	if c == 0:
		await _ride()
		_outcome = "8.4"
	else:
		await _h("D8_H_STAY")
		_outcome = "8.1"


func _ride() -> void:
	GameState.flags["hikmet_1453"] = true
	await _h("D8_H_RIDE_1")
	player.frozen = true
	player.gravity_on = false
	var tw := create_tween()
	tw.tween_property(player, "global_position", Garage.PLATFORM_POS + Vector3(0, 0.12, 0), 1.6)
	var tw2 := create_tween()
	tw2.tween_property(garage, "spin", 6.0, 2.2)
	await tw.finished
	player.face(Garage.PLATFORM_POS + Vector3(0, 1.6, 4.0))
	await _h("D8_H_RIDE_2")
	player.shake(0.8)
	await hud.fade_to(1.0, 0.8, Color.WHITE)
	await hud.card([[tr("UI_CH8_RIDE_CARD"), 34, Color("2a2a30")], [tr("UI_CH8_RIDE_SUB"), 20, Color(0.2, 0.2, 0.25, 0.8)]], 2.4)
	hud.clear_card()


func _fail(reason: String) -> void:
	if _outcome != "":
		return
	_busy = true
	phase = "checkout"
	player.frozen = true
	hud.set_chase("", 0.0)
	if reason == "caught":
		await _h("D8_H_FAIL_CAUGHT")
	else:
		_clock = END_MIN
		_update_objective()
		await _say("SPK_CEMIL", "D8_C_LATE")
		await _h("D8_H_FAIL_LATE")
	await _h("D8_H_FAIL_END")
	GameState.flags["ch8_reason"] = reason
	_outcome = "8.2"
	_busy = false


# ---------------------------------------------------------------- otomatik test

func _auto() -> void:
	await get_tree().process_frame
	player.global_position = Vector3(0, 0.05, -2.0)
	while phase != "store":
		await get_tree().process_frame
	var v := GameState.autotest_variant
	if v in ["call", "rulefree"]:
		await _phone(0)
	if v == "caught":
		for i in MAX_CATCHES:
			if _agents.size() > 0:
				await _caught(_agents[i % _agents.size()])
		return
	if v == "late":
		await _pick(_needed[0])
		await _fail("late")
		return
	for id in _needed:
		await _pick(id)
	await _checkout()


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	hud.set_chase("", 0.0)
	GameState.set_outcome(8, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=8 -> 9 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter9.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter9.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW8_TITLE")
	c.nodes = [
		{"id": "store", "key": "FLOW8_STORE", "pos": Vector2(0.5, 0.15)},
		{"id": "call", "key": "FLOW8_CALL", "pos": Vector2(0.84, 0.15)},
		{"id": "parts", "key": "FLOW8_PARTS", "pos": Vector2(0.3, 0.32)},
		{"id": "heist", "key": "FLOW8_HEIST", "pos": Vector2(0.72, 0.32)},
		{"id": "8.2", "key": "FLOW_8_2", "pos": Vector2(0.5, 0.48), "outcome": true},
		{"id": "8.3", "key": "FLOW_8_3", "pos": Vector2(0.84, 0.48), "outcome": true},
		{"id": "garage", "key": "FLOW8_GARAGE", "pos": Vector2(0.24, 0.52)},
		{"id": "8.1", "key": "FLOW_8_1", "pos": Vector2(0.1, 0.72), "outcome": true},
		{"id": "8.4", "key": "FLOW_8_4", "pos": Vector2(0.38, 0.72), "outcome": true},
	]
	c.edges = [["store", "call"], ["store", "parts"], ["store", "heist"], ["parts", "8.2"], ["heist", "8.2"],
		["heist", "8.3"], ["parts", "garage"], ["garage", "8.1"], ["garage", "8.4"]]
	c.taken["store"] = true
	c.taken["heist" if machine == "confiscated" else "parts"] = true
	if _outcome in ["8.1", "8.4"]:
		c.taken["garage"] = true
	if _called:
		c.taken["call"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	var h := int(_clock / 60.0)
	c.footer_lines = [
		tr("UI_CH8_STATS") % [GameState.telsiz_bag, "%02d:%02d" % [h, int(_clock) % 60], _catches],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW8_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase in ["street", "store"]:
		if id == "cemil":
			p = tr("UI_PROMPT3_TALK") % tr("SPK_CEMIL")
		elif id == "phone":
			p = tr("UI_PROMPT8_PHONE")
		elif id.begins_with("part:") and phase == "store":
			p = tr("UI_PROMPT5_PICK") % tr(PART_KEYS[id.trim_prefix("part:")])
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy or not phase in ["street", "store"]:
		return
	if id == "cemil":
		_talk_cemil()
	elif id == "phone":
		_phone()
	elif id.begins_with("part:") and phase == "store":
		_pick(id.trim_prefix("part:"))
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _h(key: String) -> void:
	await hud.say("SPK_HIKMET", key)


func _say(speaker: String, key: String) -> void:
	var who: Person = null
	if speaker == "SPK_CEMIL" and store:
		who = store.cemil
	else:
		for a in _agents:
			if is_instance_valid(a) and a.get_meta("speaker", "") == speaker:
				who = a
	if who:
		who.talking = true
	await hud.say(speaker, key)
	if who and is_instance_valid(who):
		who.talking = false


func _wait(s: float) -> void:
	if GameState.autotest:
		await get_tree().process_frame
		return
	await get_tree().create_timer(s).timeout


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var expected: String = {"": "8.1", "ride": "8.4", "caught": "8.2", "late": "8.2", "heist": "8.3",
		"call": "8.1", "rulefree": "8.1", "next": "8.1"}[GameState.autotest_variant]
	var ok := _outcome == expected
	match GameState.autotest_variant:
		"ride":
			ok = ok and GameState.flags.get("hikmet_1453", false)
		"call":
			ok = ok and _called and not GameState.flags.get("ch8_agents_recalled", false)
		"rulefree":
			ok = ok and GameState.flags.get("ch8_agents_recalled", false)
		"caught":
			ok = ok and _catches == MAX_CATCHES
	if GameState.chapter_outcomes.get(8, "") != _outcome:
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=8 variant=%s machine=%s outcome=%s parts=%s catches=%d called=%s" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, machine, _outcome, str(_have.keys()), _catches, str(_called)])
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
	phase = "street"
	_update_objective()
	player.global_position = Vector3(2.0, 0.05, 8.5)
	player.face(Vector3(-1.5, 2.4, 0))
	hud.bark("SPK_HIKMET", "D8_H_01", 30.0)
	await _shot("c8_01_hirdavat.png")
	player.global_position = Vector3(2.6, 0.05, -1.4)
	player.face(store.cemil.global_position + Vector3(0, 1.5, 0))
	store.cemil.look_target = player
	store.cemil.talking = true
	hud.bark("SPK_CEMIL", "D8_C_03", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c8_02_cemil.png")
	store.cemil.talking = false
	_spawn_agents()
	phase = "store"
	_clock = 352.0
	_update_objective()
	set_process(false)
	_agents[0].position = Vector3(-1.75, 0, -11.5)
	_agents[0].rotation.y = 0.0
	_agents[1].position = Vector3(5.3, 0, -12.0)
	_agents[1].rotation.y = PI
	hud.set_chase(tr("UI_CH8_AWARE"), 0.55)
	player.global_position = Vector3(-1.2, 0.05, -12.8)
	player.face(Vector3(-1.75, 1.3, -9.0))
	_agents[0].position = Vector3(-1.75, 0, -7.4)
	_agents[0].rotation.y = PI
	hud.bark("SPK_HIKMET", "D8_H_AGENTS", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c8_04_ajan.png")
	hud.set_chase("", 0.0)
	# Garaj: büyük karar
	for a in _agents:
		a.queue_free()
	_agents.clear()
	store.queue_free()
	store = null
	garage = Garage.new()
	add_child(garage)
	garage.spin = 1.0
	garage.machine_light.light_energy = 1.5
	garage.panel_screen.text = "1453"
	player.global_position = Garage.SPAWN_POS + Vector3(0, 0.05, 0)
	player.face(Garage.PLATFORM_POS + Vector3(0, 1.3, 0))
	phase = "garage"
	hud.set_objective("")
	hud.bark("SPK_HIKMET", "D8_H_G4", 30.0)
	hud.choose(["UI_CH8_RIDE", "UI_CH8_STAY"], 10.0, 0)
	await get_tree().create_timer(1.0).timeout
	await _shot("c8_05_karar.png")
	get_tree().quit()
