extends Node3D
## Bölüm 5 — Garajda Gece (Hikmet · 2026, pazar gecesi 04:00). CHAPTERS Bölüm 5.
##
## Oyuncu Hikmet'i ilk kez oynar. Garajın önünde Zaman Bürosu'nun gri minibüsü bekler,
## tavandaki projektörünün ışığı garajın içinde gezinir (ışığa yakalanırsan minibüsün
## hoparlörü konuşur). Bölüm 3'e göre:
##   makine serbest  → sök, üç parçayı bodrum kapağına taşı (5.1)
##   mühürlü         → önce mührü koli bandıyla aş, sonra aynısı (5.1)
##   el konulmuş     → yedek Telsiz-Kumanda'yı bul (hep son bakılan yerde) (5.2)
## Sonra ⏱ telsiz frekansı (Tolga'ya ulaş), bölümün tek ciddi anı (1977 itirafı, üç saniye
## sessizlik, Tolga'nın kazara gelen sesi) ve kartvizit varsa Nihat'ı arama (5.3).
## Frekans bulunamazsa 5.4 (Telsiz Bağı −2).
##   --autotest[=call|confiscated|sealed|noradio]   (varsayılan: 5.1)

const TUNE_TIME := 15.0
const BEAM_ANGLE := 16.0
const PART_NAMES := {"part:ring": "UI_PART_RING", "part:panel": "UI_PART_PANEL", "part:antenna": "UI_PART_ANTENNA"}
const SPOTS := ["spot:tin", "spot:calendar", "spot:tv", "spot:slipper"]

var garage: Garage
var player: Player
var hud: Hud
var phase := "intro"
var machine := "free"          # free, sealed, confiscated
var _outcome := ""
var _busy := false
var _done: Dictionary = {}
var _carrying := ""
var _hidden_parts := 0
var _searched: Array = []
var _parts: Dictionary = {}
var _hatch: Node3D
var _rug: Node3D
var _beam: SpotLight3D
var _van_light: SpotLight3D
var _beam_on := true
var _t := 0.0
var _caught_cd := 0.0
var _suspicion := 0
var _tuned := false
var _called := false
var _tuner: RadioTuner


func _ready() -> void:
	GameState.snapshot(5)
	machine = GameState.flags.get("machine", "free")
	match GameState.autotest_variant:
		"confiscated":
			machine = "confiscated"
		"sealed":
			machine = "sealed"
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
	hud.set_cinematic(true)
	garage = Garage.new()
	add_child(garage)
	_setup_garage()
	_build_outside()
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _process(delta: float) -> void:
	_t += delta
	# Projektör: minibüsten garajın içine, soldan sağa gezinir
	if _beam:
		_beam.visible = _beam_on
		_beam.position.x = sin(_t * 0.55) * 3.3
		_van_light.rotation.y = sin(_t * 0.55) * 0.35
	_caught_cd = maxf(0.0, _caught_cd - delta)
	if phase in ["protect", "to_radio"] and not _busy:
		_check_beam()
	if phase == "tune":
		_tune_step(delta)


# ================================================================ sahne

func _setup_garage() -> void:
	garage.spin = 0.0
	garage.machine_light.light_energy = 0.3
	garage.panel_screen.text = "14:53"
	if GameState.flags.get("panel_cracked", false):
		garage.panel_screen.modulate = Color("ff5a4a")
	# Tolga'nın götürdüğü eşyalar yok; kalanlar etkileşimsiz
	for id in garage.items:
		(garage.items[id]["body"] as StaticBody3D).collision_layer = 0
		if id in GameState.bag:
			garage.set_item_visible(id, false)
	var m := garage.get_node("Zamanator") as Node3D
	if machine == "confiscated":
		m.visible = false
		garage.panel_node.visible = false
		garage.machine_light.light_energy = 0.0
		# Makinenin yerinde tozlu bir çember ve bir "EL KONULDU" etiketi
		Props.ring(garage, 0.95, 1.0, Garage.PLATFORM_POS + Vector3(0, 0.01, 0), Color("6a6e76"))
		Props.label(garage, tr("UI_CH3_TAG_CONFISCATED"), Garage.PLATFORM_POS + Vector3(0, 0.02, 0), 36, Color("ff5a4a"), Vector3(-90, 0, 0), 1.6)
	else:
		if machine == "sealed":
			for a in [-35.0, 35.0]:
				var band := Props.box(m, Vector3(2.3, 0.14, 0.02), Vector3(0, 1.25, 1.13), Color("c8323a"), Vector3(0, 0, a))
				band.name = "Seal"
		Props.interactable(garage, "machine", Vector3(2.0, 2.4, 2.0), Garage.PLATFORM_POS + Vector3(0, 1.2, 0))
	# Bodrum kapağı ve üstündeki kilim
	_hatch = Node3D.new()
	_hatch.position = Vector3(-2.1, 0.0, 2.0)
	garage.add_child(_hatch)
	Props.box(_hatch, Vector3(1.0, 0.02, 0.8), Vector3(0, 0.01, 0), Color("1a1a1e"))
	Props.box(_hatch, Vector3(1.1, 0.03, 0.08), Vector3(0, 0.015, -0.42), Garage.C_WOOD_DARK)
	Props.box(_hatch, Vector3(1.1, 0.03, 0.08), Vector3(0, 0.015, 0.42), Garage.C_WOOD_DARK)
	Props.ring(_hatch, 0.04, 0.07, Vector3(0.35, 0.03, 0), Color("8d949e"))
	_rug = Node3D.new()
	_rug.position = _hatch.position + Vector3(0, 0.02, 0)
	garage.add_child(_rug)
	Props.box(_rug, Vector3(1.3, 0.02, 1.0), Vector3.ZERO, Color("8a2b22"))
	Props.box(_rug, Vector3(1.1, 0.021, 0.8), Vector3.ZERO, Color("c98a3a"))
	Props.box(_rug, Vector3(0.9, 0.022, 0.6), Vector3.ZERO, Color("8a2b22"))
	# Tezgâhta telsiz (Tolga'nınkinin eşi) ve kurabiye kutusu
	var radio := Node3D.new()
	radio.position = Vector3(-3.35, 0.9, -0.35)
	radio.rotation_degrees.y = 90
	garage.add_child(radio)
	Props.box(radio, Vector3(0.12, 0.2, 0.06), Vector3(0, 0.1, 0), Color("7d8794"))
	Props.cyl(radio, 0.008, 0.2, Vector3(0.04, 0.3, 0), Color("2b2f3a"), Vector3.ZERO, 4)
	Props.box(radio, Vector3(0.05, 0.04, 0.005), Vector3(0, 0.15, 0.031), Color("6ff2c8"), Vector3.ZERO, 1.2)
	Props.interactable(garage, "radio_set", Vector3(0.6, 0.6, 0.8), Vector3(-3.35, 1.1, -0.35))
	if machine == "confiscated":
		Props.cyl(garage, 0.12, 0.1, Vector3(-3.4, 0.95, 0.5), Color("2f5fa8"), Vector3.ZERO, 12)
		Props.cyl(garage, 0.125, 0.02, Vector3(-3.4, 1.01, 0.5), Color("c49a45"), Vector3.ZERO, 12)
		Props.interactable(garage, "spot:tin", Vector3(0.4, 0.4, 0.4), Vector3(-3.4, 1.0, 0.5))
		Props.interactable(garage, "spot:calendar", Vector3(0.3, 0.8, 0.7), Vector3(-3.85, 1.75, 2.2))
		Props.interactable(garage, "spot:tv", Vector3(0.6, 0.5, 0.6), Vector3(3.6, 2.29, -1.0))
		Props.box(garage, Vector3(0.12, 0.05, 0.26), Vector3(-1.75, 0.03, -0.4), Color("6b4a3a"), Vector3(0, 30, 0))
		Props.interactable(garage, "spot:slipper", Vector3(0.4, 0.3, 0.4), Vector3(-1.75, 0.1, -0.4))
	# Eski radyo (rafta): dünya değişiyor
	Props.interactable(garage, "radio_old", Vector3(0.5, 0.4, 0.6), Vector3(3.6, 2.19, 0.8))


## Garajın dışı: sokak, karşı evler, sokak lambası ve Büro'nun gri minibüsü.
func _build_outside() -> void:
	var out := Node3D.new()
	add_child(out)
	var z0 := Garage.D / 2.0 + 0.2
	Props.solid(out, Vector3(40, 0.2, 30), Vector3(0, -0.1, z0 + 15.0), Color("2a2c30"))
	Props.box(out, Vector3(40, 0.12, 2.0), Vector3(0, 0.06, z0 + 1.0), Color("5a5c60"))
	# Garajın dış cephesi ve dışarıdan kepenk
	Props.box(out, Vector3(Garage.W + 0.6, Garage.H + 0.6, 0.1), Vector3(0, (Garage.H + 0.6) / 2.0, z0), Color("8a8478"))
	for i in 7:
		Props.box(out, Vector3(4.4, 0.33, 0.05), Vector3(0, 0.2 + i * 0.36, z0 + 0.08), Color("9aa2ac") if i % 2 == 0 else Color("8d959f"))
	Props.box(out, Vector3(2.2, 0.35, 0.05), Vector3(2.2, Garage.H + 0.1, z0 + 0.08), Color("20252e"))
	Props.label(out, "HİKMET TAMİR", Vector3(2.2, Garage.H + 0.1, z0 + 0.12), 40, Color("ffc98a"), Vector3.ZERO, 2.0)
	# Karşı evler: ışığı yanan tek tük pencereler
	var rng := RandomNumberGenerator.new()
	rng.seed = 1977
	for i in 6:
		var x := -15.0 + i * 6.0
		var h := rng.randf_range(5.0, 9.0)
		Props.box(out, Vector3(5.4, h, 5.0), Vector3(x, h / 2.0, z0 + 17.0), Color("3a3834"))
		for k in 4:
			var lit := rng.randf() < 0.3
			var win := Props.box(out, Vector3(0.8, 0.9, 0.05), Vector3(x - 1.3 + (k % 2) * 2.6, 1.8 + (k / 2) * 2.6, z0 + 14.47), Color("ffd08a") if lit else Color("1a1e28"), Vector3.ZERO, 1.2 if lit else 0.0)
			win.material_override = Props.mat(Color("ffd08a") if lit else Color("1a1e28"), 1.2 if lit else 0.0, false, "", false)
	# Sokak lambası
	Props.cyl(out, 0.07, 5.0, Vector3(-5.0, 2.5, z0 + 2.2), Color("3a3f48"), Vector3.ZERO, 6)
	Props.box(out, Vector3(0.6, 0.12, 0.3), Vector3(-4.75, 5.0, z0 + 2.2), Color("3a3f48"))
	var sl := OmniLight3D.new()
	sl.position = Vector3(-4.6, 4.8, z0 + 2.2)
	sl.light_color = Color("ffb870")
	sl.light_energy = 2.0
	sl.omni_range = 9.0
	out.add_child(sl)
	# Ay ışığı gibi soğuk bir dolgu ışığı (sokağı ve minibüsün yan yüzünü aydınlatır)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-1.0, 4.0, z0 + 12.0)
	fill.light_color = Color("9fb4ff")
	fill.light_energy = 1.6
	fill.omni_range = 14.0
	out.add_child(fill)
	# Minibüs
	var van := Node3D.new()
	van.position = Vector3(1.8, 0, z0 + 6.5)
	van.rotation_degrees.y = 90
	out.add_child(van)
	Props.box(van, Vector3(1.9, 1.7, 4.4), Vector3(0, 1.25, 0), Color("8a8f96"))
	Props.box(van, Vector3(1.9, 0.9, 0.9), Vector3(0, 0.85, 2.6), Color("8a8f96"))
	Props.box(van, Vector3(1.8, 0.55, 0.05), Vector3(0, 1.75, 2.24), Color("1a2238"), Vector3(-20, 0, 0))
	for side in [-1, 1]:
		Props.box(van, Vector3(0.05, 0.5, 1.2), Vector3(side * 0.96, 1.6, 1.2), Color("1a2238"))
		for wz in [-1.5, 1.7]:
			Props.cyl(van, 0.36, 0.25, Vector3(side * 0.9, 0.36, wz), Color("15171c"), Vector3(0, 0, 90), 10)
		var tx := Props.label(van, "ZAMAN BÜROSU", Vector3(side * 0.97, 1.35, -0.4), 40, Color("1d2330"), Vector3(0, 90 * side, 0), 2.6)
		tx.double_sided = false
		Props.label(van, "Size zaman ayırıyoruz", Vector3(side * 0.97, 1.0, -0.4), 22, Color("3a3f48"), Vector3(0, 90 * side, 0), 2.2)
	for hx in [-0.65, 0.65]:
		var hl := Props.box(van, Vector3(0.3, 0.16, 0.05), Vector3(hx, 0.95, 3.06), Color("fff4d0"), Vector3.ZERO, 3.0)
		hl.material_override = Props.mat(Color("fff4d0"), 3.0, false, "", false)
	# Tavanda projektör ve periskop
	Props.cyl(van, 0.2, 0.3, Vector3(0, 2.25, 0.6), Color("3a3f48"), Vector3(90, 0, 0), 10)
	Props.cyl(van, 0.04, 0.6, Vector3(-0.5, 2.4, -1.2), Color("3a3f48"), Vector3.ZERO, 6)
	Props.box(van, Vector3(0.12, 0.08, 0.2), Vector3(-0.5, 2.72, -1.15), Color("3a3f48"))
	_van_light = SpotLight3D.new()
	_van_light.position = Vector3(1.8, 2.3, z0 + 5.8)
	_van_light.rotation_degrees = Vector3(-8, 0, 0)
	_van_light.spot_angle = 14.0
	_van_light.spot_range = 14.0
	_van_light.light_energy = 6.0
	_van_light.light_color = Color("dfe8ff")
	out.add_child(_van_light)
	# Garajın içine düşen projektör ışığı (gölgesiz: kapıdan "sızar")
	_beam = SpotLight3D.new()
	_beam.position = Vector3(0, 1.9, Garage.D / 2.0 + 0.5)
	_beam.rotation_degrees = Vector3(-12, 0, 0)
	_beam.spot_angle = BEAM_ANGLE
	_beam.spot_range = 9.0
	_beam.light_energy = 5.0
	_beam.light_color = Color("dfe8ff")
	_beam.shadow_enabled = false
	add_child(_beam)


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH5_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH5_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	# Dışarıdan: minibüs
	player.gravity_on = false
	player.global_position = Vector3(-3.0, 0.2, Garage.D / 2.0 + 13.5)
	player.face(Vector3(0.6, 1.4, Garage.D / 2.0 + 5.5))
	await hud.fade_to(0.0, 1.2)
	await _h("D5_H_01")
	await _h("D5_H_02")
	await hud.fade_to(1.0, 0.6)
	# İçeride
	player.gravity_on = true
	player.global_position = Garage.SPAWN_POS
	player.face(Garage.PLATFORM_POS + Vector3(0, 1.3, 0))
	hud.set_cinematic(false)
	player.show_remote(true)
	_capture_mouse()
	await hud.fade_to(0.0, 0.8)
	await _say("SPK_RADIO", "D5_RADIO_01")
	await _h("D5_H_03")
	# Koru ve sakla
	phase = "protect"
	player.frozen = false
	_update_objective()
	_flash_prompt(tr("UI_HINT5_BEAM"), 6.0)
	if GameState.autotest:
		await _auto_protect()
	while not _done.has("protect"):
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	# Telsiz
	phase = "to_radio"
	hud.set_objective(tr("UI_OBJ5_RADIO"), hud.spot("radio_set"), 0.4)
	if GameState.autotest:
		await _start_tuning()
	while not _done.has("radio"):
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	await _confession()
	if GameState.flags.get("nihat_card", false):
		await _card_call()
	await _ending()
	await _end_chapter()


func _update_objective() -> void:
	match machine:
		"confiscated":
			hud.set_objective(tr("UI_OBJ5_BACKUP") % _searched.size(), hud.spot(SPOTS, func(id): return id in _searched), 0.3)
		"sealed":
			if not _done.has("seal"):
				hud.set_objective(tr("UI_OBJ5_SEAL"), hud.spot("machine"), 0.4)
			else:
				hud.set_objective(tr("UI_OBJ5_HIDE") % _hidden_parts, hud.spot(PART_NAMES.keys()), 0.4)
		_:
			hud.set_objective(tr("UI_OBJ5_HIDE") % _hidden_parts, hud.spot(PART_NAMES.keys()), 0.4)


# ---------------------------------------------------------------- projektör

func _in_beam() -> bool:
	if not _beam_on:
		return false
	var p := player.global_position
	var dz := _beam.position.z - p.z
	if dz < 0.0 or dz > 8.0:
		return false
	var half := dz * tan(deg_to_rad(BEAM_ANGLE)) + 0.25
	return absf(p.x - _beam.position.x) < half


func _check_beam() -> void:
	if _caught_cd > 0.0 or GameState.autotest or not _in_beam():
		return
	_caught_cd = 5.0
	_suspicion += 1
	player.shake(0.3)
	hud.bark("SPK_VAN", "D5_V_%d" % mini(_suspicion, 4), 3.5)
	if _suspicion == 4:
		_knock()


## Dördüncü yakalanmada Büro'dan biri kapıyı çalar... ve yanlış garajı çaldığını söyler.
func _knock() -> void:
	player.shake(1.0)
	await get_tree().create_timer(3.6).timeout
	hud.bark("SPK_VAN", "D5_V_KNOCK", 4.0)


# ---------------------------------------------------------------- makineyi sakla

func _seal() -> void:
	_busy = true
	player.frozen = true
	await _h("D5_H_SEAL")
	var m := garage.get_node("Zamanator") as Node3D
	# Mührün tam üstüne, çapraz koli bandı: mühür bozulmadı, sadece "askıya alındı"
	for a in [-35.0, 35.0]:
		Props.box(m, Vector3(2.35, 0.1, 0.02), Vector3(0, 1.25, 1.15), Garage.C_TAPE, Vector3(0, 0, a + 5.0))
	GameState.flags["seal_bypassed"] = true
	_done["seal"] = true
	await _h("D5_H_SEAL2")
	_update_objective()
	player.frozen = false
	_busy = false


func _dismantle() -> void:
	_busy = true
	player.frozen = true
	await _h("D5_H_DISMANTLE")
	await hud.fade_to(1.0, 0.4)
	var m := garage.get_node("Zamanator") as Node3D
	# Platform (ilk üç parça) kalır, geri kalan her şey sökülür
	for i in m.get_child_count():
		if i >= 3:
			(m.get_child(i) as Node3D).visible = false
	garage.panel_node.visible = false
	garage.machine_light.light_energy = 0.0
	# Parçalar platformun üstünde
	var base := Garage.PLATFORM_POS
	var ring := Node3D.new()
	ring.position = base + Vector3(-0.4, 0.12, 0.2)
	garage.add_child(ring)
	Props.ring(ring, 0.42, 0.52, Vector3(0, 0.05, 0), Color("9aa3ad"))
	Props.box(ring, Vector3(0.14, 0.14, 0.14), Vector3(0.47, 0.05, 0), Garage.C_TAPE)
	var panel := Node3D.new()
	panel.position = base + Vector3(0.45, 0.12, 0.35)
	garage.add_child(panel)
	Props.box(panel, Vector3(0.5, 0.12, 0.35), Vector3(0, 0.06, 0), Color("3d4450"))
	Props.box(panel, Vector3(0.3, 0.02, 0.1), Vector3(0, 0.13, -0.05), Color("0f1a14"))
	Props.label(panel, "14:53", Vector3(0, 0.145, -0.05), 20, Color("6ff2c8"), Vector3(-90, 0, 0), 0.26)
	var ant := Node3D.new()
	ant.position = base + Vector3(0.1, 0.12, -0.45)
	garage.add_child(ant)
	Props.cyl(ant, 0.12, 0.45, Vector3(0, 0.22, 0), Color("8d949e"), Vector3(0, 0, 70), 8, 0.35)
	Props.ball(ant, 0.08, Vector3(0.28, 0.12, 0), Color("ff5a4a"), Vector3.ONE, 8, 1.5)
	for pair in [["part:ring", ring], ["part:panel", panel], ["part:antenna", ant]]:
		var node: Node3D = pair[1]
		Props.interactable(node, pair[0], Vector3(0.9, 0.6, 0.9), Vector3(0, 0.25, 0))
		_parts[pair[0]] = node
	# Kilim kenara çekilir, kapak görünür
	var tw := create_tween()
	tw.tween_property(_rug, "position", _rug.position + Vector3(1.3, 0, 0.3), 0.01)
	await tw.finished
	Props.interactable(_hatch, "hatch", Vector3(1.1, 0.5, 0.9), Vector3(0, 0.2, 0))
	_done["dismantled"] = true
	await hud.fade_to(0.0, 0.4)
	await _h("D5_H_DISMANTLE2")
	_update_objective()
	player.frozen = false
	_busy = false


func _pick_part(id: String) -> void:
	if _carrying != "":
		hud.bark("SPK_HIKMET", "D5_H_HANDS_FULL", 2.5)
		return
	_carrying = id
	(_parts[id] as Node3D).visible = false
	_disable_interact(_parts[id])
	hud.set_prompt("")
	hud.bark("SPK_HIKMET", "D5_H_PICK_" + id.trim_prefix("part:").to_upper(), 3.0)
	hud.set_objective(tr("UI_OBJ5_CARRY") % tr(PART_NAMES[id]), hud.spot("hatch"), 0.4)


func _drop_part() -> void:
	if _carrying == "":
		hud.bark("SPK_HIKMET", "D5_H_HATCH_EMPTY", 2.5)
		return
	_carrying = ""
	_hidden_parts += 1
	player.shake(0.2)
	_update_objective()
	if _hidden_parts >= 3:
		_busy = true
		player.frozen = true
		var tw := create_tween()
		tw.tween_property(_rug, "position", _hatch.position + Vector3(0, 0.02, 0), 0.4)
		await tw.finished
		_disable_interact(_hatch)
		GameState.flags["machine_hidden"] = true
		await _h("D5_H_HIDDEN")
		player.frozen = false
		_done["protect"] = true
		_busy = false


func _search(id: String) -> void:
	if id in _searched or _done.has("protect"):
		return
	_busy = true
	player.frozen = true
	_searched.append(id)
	var key := id.trim_prefix("spot:").to_upper()
	if _searched.size() < 3:
		await _h("D5_H_SPOT_" + key)
		_update_objective()
	else:
		# Hep son bakılan yerde
		await _h("D5_H_FOUND_" + key)
		await _h("D5_H_FOUND")
		GameState.flags["backup_remote"] = true
		_done["protect"] = true
	player.frozen = false
	_busy = false


func _disable_interact(node: Node) -> void:
	for c in node.get_children():
		if c is StaticBody3D:
			(c as StaticBody3D).collision_layer = 0


func _auto_protect() -> void:
	if machine == "confiscated":
		for s in ["spot:tin", "spot:calendar", "spot:tv"]:
			await _search(s)
		return
	if machine == "sealed":
		await _seal()
	await _dismantle()
	for id in ["part:ring", "part:panel", "part:antenna"]:
		_pick_part(id)
		await _drop_part()


# ---------------------------------------------------------------- ⏱ telsiz frekansı

func _start_tuning() -> void:
	if _busy or _done.has("radio"):
		return
	_busy = true
	player.frozen = true
	player.global_position = Vector3(-2.4, 0.05, -0.35)
	player.face(Vector3(-3.35, 1.05, -0.35))
	await _h("D5_H_TUNE")
	hud.set_objective("")
	phase = "tune"
	_tuner = RadioTuner.new()
	_tuner.label_text = tr("UI_TUNER")
	_tuner.hint_text = tr("UI_TUNER_HINT")
	var rng := RandomNumberGenerator.new()
	rng.seed = 26
	_tuner.target = [91.4, 103.7, 99.2][rng.randi() % 3]
	hud.add_child(_tuner)
	var vp := get_viewport().get_visible_rect().size
	_tuner.position = Vector2((vp.x - _tuner.size.x) / 2.0, vp.y * 0.1)
	_tuner.set_meta("left", TUNE_TIME)
	while phase == "tune":
		await get_tree().process_frame
	_tuner.queue_free()
	_tuner = null
	_done["radio"] = true
	_busy = false


func _tune_step(delta: float) -> void:
	var left: float = _tuner.get_meta("left") - delta
	_tuner.set_meta("left", left)
	_tuner.time_left = clampf(left / TUNE_TIME, 0.0, 1.0)
	var dir := Input.get_axis("move_left", "move_right")
	if GameState.autotest:
		if GameState.autotest_variant == "noradio":
			dir = 0.0
		else:
			_tuner.freq = _tuner.target
	_tuner.freq = clampf(_tuner.freq + dir * 4.0 * delta, 88.0, 108.0)
	var holding := Input.is_action_pressed("interact") or (GameState.autotest and GameState.autotest_variant != "noradio")
	if holding and _tuner.strength() > 0.8:
		_tuner.lock = minf(1.0, _tuner.lock + delta * 1.2)
	else:
		_tuner.lock = maxf(0.0, _tuner.lock - delta * 0.6)
	if _tuner.lock >= 1.0:
		_tuned = true
		phase = "tuned"
	elif left <= 0.0:
		_tuned = false
		phase = "tuned"


# ---------------------------------------------------------------- 1977

## Bölümün tek ciddi anı: Hikmet boş garajda telsize konuşur. Üç saniye sessizlik. Sonra mizah.
func _confession() -> void:
	phase = "confession"
	player.frozen = true
	hud.set_objective("")
	_beam_on = false
	# Sandalyeye oturur, telsize bakar
	player.gravity_on = false
	player.velocity = Vector3.ZERO
	player.global_position = Vector3(-2.2, -0.35, -0.9)
	player.face(Vector3(-3.35, 1.0, -0.35))
	if _tuned:
		GameState.telsiz_bag = mini(5, GameState.telsiz_bag + 1)
		hud.set_signal(GameState.telsiz_bag)
		await _h("D5_H_CONF_0")
	else:
		await _h("D5_H_CONF_0_NO")
	if GameState.flags.get("red_after_warranty", false):
		await _h("D5_H_CONF_RED")
	for k in ["D5_H_CONF_1", "D5_H_CONF_2", "D5_H_CONF_3", "D5_H_CONF_4"]:
		await _h(k)
	# Üç saniye sessizlik: hiçbir şey
	await _wait(3.2)
	if _tuned:
		var ch4: String = GameState.chapter_outcomes.get(4, "4a.1")
		var key := "D5_T_ACCIDENT_CAMP"
		if ch4.begins_with("4b"):
			key = "D5_T_ACCIDENT_CHICKEN"
		elif ch4 == "4a.3":
			key = "D5_T_ACCIDENT_DISHES"
		await hud.say("SPK_TOLGA", key)
		await _h("D5_H_AFTER")
	else:
		await _say("SPK_BUREAU_RADIO", "D5_B_INTERCEPT")
		await _h("D5_H_AFTER_NO")
		GameState.telsiz_bag = maxi(0, GameState.telsiz_bag - 2)
		hud.set_signal(GameState.telsiz_bag)


func _card_call() -> void:
	await _h("D5_H_CARD")
	var pick := 0 if GameState.autotest_variant == "call" else 1
	var c := await hud.choose(["UI_CH5_CALL", "UI_CH5_NO_CALL"], 0.0, pick)
	if c != 0:
		await _h("D5_H_NO_CALL")
		return
	_called = true
	player.shake(0.2)
	await _h("D5_H_CALL_1")
	await _say("SPK_NIHAT", "D5_N_CALL_2")
	await _h("D5_H_CALL_3")
	await _say("SPK_NIHAT", "D5_N_CALL_4")
	await _h("D5_H_CALL_5")
	await _say("SPK_NIHAT", "D5_N_CALL_6")
	GameState.flags["hn_rel"] = mini(2, int(GameState.flags.get("hn_rel", 0)) + 1)
	GameState.flags["buro_baskisi"] = maxi(0, int(GameState.flags.get("buro_baskisi", 0)) - 1)
	GameState.flags["sadakat"] = int(GameState.flags.get("sadakat", 60)) - 5


func _ending() -> void:
	player.gravity_on = true
	player.global_position = Garage.SPAWN_POS + Vector3(0, 0.05, 0.3)
	player.face(Vector3(0, 1.6, Garage.D / 2.0))
	await _h("D5_H_END")
	if not _tuned:
		_outcome = "5.4"
	elif _called:
		_outcome = "5.3"
	elif machine == "confiscated":
		_outcome = "5.2"
	else:
		_outcome = "5.1"
	GameState.flags["van_suspicion"] = _suspicion


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	GameState.set_outcome(5, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=5 -> 6 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter6.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter6.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW5_TITLE")
	c.nodes = [
		{"id": "van", "key": "FLOW5_VAN", "pos": Vector2(0.5, 0.16)},
		{"id": "hide", "key": "FLOW5_HIDE", "pos": Vector2(0.3, 0.27)},
		{"id": "backup", "key": "FLOW5_BACKUP", "pos": Vector2(0.7, 0.27)},
		{"id": "radio", "key": "FLOW5_RADIO", "pos": Vector2(0.5, 0.38)},
		{"id": "confess", "key": "FLOW5_CONFESS", "pos": Vector2(0.5, 0.49)},
		{"id": "5.1", "key": "FLOW_5_1", "pos": Vector2(0.14, 0.63), "outcome": true},
		{"id": "5.2", "key": "FLOW_5_2", "pos": Vector2(0.38, 0.63), "outcome": true},
		{"id": "5.3", "key": "FLOW_5_3", "pos": Vector2(0.62, 0.63), "outcome": true},
		{"id": "5.4", "key": "FLOW_5_4", "pos": Vector2(0.86, 0.63), "outcome": true},
	]
	c.edges = [["van", "hide"], ["van", "backup"], ["hide", "radio"], ["backup", "radio"], ["radio", "confess"],
		["confess", "5.1"], ["confess", "5.2"], ["confess", "5.3"], ["confess", "5.4"]]
	for id in ["van", "radio", "confess"]:
		c.taken[id] = true
	c.taken["backup" if machine == "confiscated" else "hide"] = true
	c.taken[_outcome] = true
	for id in ["5.1", "5.2", "5.3", "5.4"]:
		if GameState.has_seen(id):
			c.seen[id] = true
	var rel: int = GameState.flags.get("hn_rel", 0)
	var rel_names := {-2: "UI_REL_ENEMY", -1: "UI_REL_COLD", 0: "UI_REL_NEUTRAL", 1: "UI_REL_FRIEND", 2: "UI_REL_PARTNER"}
	c.footer_lines = [
		tr("UI_FLOW_STATS") % GameState.telsiz_bag + "     ·     " + tr("UI_FLOW5_STATS") % [tr(rel_names[rel]), int(GameState.flags.get("buro_baskisi", 0)), _suspicion],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW5_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy:
		if phase == "protect":
			if id == "machine" and machine == "sealed" and not _done.has("seal"):
				p = tr("UI_PROMPT5_SEAL")
			elif id == "machine" and not _done.has("dismantled") and (machine == "free" or _done.has("seal")):
				p = tr("UI_PROMPT5_DISMANTLE")
			elif id.begins_with("part:") and _carrying == "":
				p = tr("UI_PROMPT5_PICK") % tr(PART_NAMES[id])
			elif id == "hatch":
				p = tr("UI_PROMPT5_HATCH")
			elif id.begins_with("spot:") and not id in _searched:
				p = tr("UI_PROMPT5_SEARCH")
		elif phase == "to_radio" and id == "radio_set":
			p = tr("UI_PROMPT5_RADIO")
		if id == "radio_old":
			p = tr("UI_PROMPT3_LOOK")
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy:
		return
	if phase == "protect":
		if id == "machine" and machine == "sealed" and not _done.has("seal"):
			_seal()
		elif id == "machine" and not _done.has("dismantled") and (machine == "free" or _done.has("seal")):
			_dismantle()
		elif id.begins_with("part:"):
			_pick_part(id)
		elif id == "hatch":
			_drop_part()
		elif id.begins_with("spot:"):
			_search(id)
	elif phase == "to_radio" and id == "radio_set":
		_start_tuning()
	if id == "radio_old":
		hud.bark("SPK_RADIO", "D5_RADIO_02", 4.0)
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _h(key: String) -> void:
	await hud.say("SPK_HIKMET", key)


func _say(speaker: String, key: String) -> void:
	await hud.say(speaker, key)


func _wait(s: float) -> void:
	if GameState.autotest:
		await get_tree().process_frame
		return
	await get_tree().create_timer(s).timeout


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _flash_prompt(text: String, seconds: float) -> void:
	hud.set_prompt(text)
	await _wait(seconds)
	if hud and phase == "protect":
		hud.set_prompt("")


# ================================================================ otomatik test

func _autotest_report() -> void:
	var expected: String = {"": "5.1", "next": "5.1", "call": "5.3", "confiscated": "5.2", "sealed": "5.1", "noradio": "5.4"}[GameState.autotest_variant]
	var ok := _outcome == expected
	if GameState.autotest_variant == "sealed" and not GameState.flags.get("seal_bypassed", false):
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen sonuç %s, gelen %s" % [expected, _outcome])
	if GameState.chapter_outcomes.get(5, "") != _outcome:
		ok = false
	print("AUTOTEST %s chapter=5 variant=%s machine=%s outcome=%s telsiz=%d rel=%d" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, machine, _outcome, GameState.telsiz_bag, int(GameState.flags.get("hn_rel", 0))])
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
	# 1. Dışarıda minibüs
	player.gravity_on = false
	player.global_position = Vector3(-3.0, 0.2, Garage.D / 2.0 + 13.5)
	player.face(Vector3(0.6, 1.4, Garage.D / 2.0 + 5.5))
	hud.bark("SPK_HIKMET", "D5_H_01", 30.0)
	await _shot("c5_01_minibus.png")
	# 2. İçeride projektör
	player.gravity_on = true
	hud.set_cinematic(false)
	player.show_remote(true)
	player.global_position = Vector3(-1.6, 0.05, -0.8)
	player.face(Vector3(1.0, 0.9, 2.6))
	_t = 1.2
	hud.set_objective(tr("UI_OBJ5_HIDE") % 0, hud.spot(PART_NAMES.keys()), 0.4)
	hud.bark("SPK_VAN", "D5_V_1", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c5_02_projektor.png")
	# 3. Sökülen makine ve bodrum kapağı
	GameState.autotest = true
	await _dismantle()
	GameState.autotest = false
	hud.set_fade(0.0)
	player.global_position = Vector3(-0.9, 0.05, 1.6)
	player.face(Vector3(-1.2, 0.2, -0.6))
	hud.set_objective(tr("UI_OBJ5_CARRY") % tr("UI_PART_ANTENNA"), hud.spot("hatch"), 0.4)
	hud.bark("SPK_HIKMET", "D5_H_PICK_ANTENNA", 30.0)
	await _shot("c5_03_sakla.png")
	# 4. Telsiz frekansı
	player.global_position = Vector3(-2.4, 0.05, -0.35)
	player.face(Vector3(-3.35, 1.05, -0.35))
	hud.set_objective("")
	var tn := RadioTuner.new()
	tn.label_text = tr("UI_TUNER")
	tn.hint_text = tr("UI_TUNER_HINT")
	tn.freq = 102.6
	tn.target = 103.7
	tn.lock = 0.4
	tn.time_left = 0.55
	hud.add_child(tn)
	var vp := get_viewport().get_visible_rect().size
	tn.position = Vector2((vp.x - tn.size.x) / 2.0, vp.y * 0.1)
	hud.bark("SPK_HIKMET", "D5_H_TUNE", 30.0)
	await _shot("c5_04_frekans.png")
	tn.queue_free()
	# 5. 1977
	hud.set_objective("")
	_beam_on = false
	player.global_position = Vector3(-2.2, -0.35, -0.9)
	player.face(Vector3(-3.35, 1.0, -0.35))
	hud.bark("SPK_HIKMET", "D5_H_CONF_3", 30.0)
	await _shot("c5_05_1977.png")
	# 6. Akış şeması
	_outcome = "5.1"
	GameState.seen_outcomes["5.4"] = true
	hud.add_child(_make_chart())
	await _shot("c5_06_akis.png")
	get_tree().quit()
