extends Node3D
## Bölüm 1 — Zamanatör (CHAPTERS.md, Bölüm 1).
## Açılış uyarısı → giriş → kostüm → çanta (5/10) → Telsiz-Kumanda →
## panel (1453 → 14:53) → platform → makine takılır (süreli karar) → akış şeması.
## Erken son: Telsiz-Kumanda verildikten sonra kırmızı düğmeyi 3 sn basılı tutmak.
##
## Komut satırı modları (GameState):
##   --autotest[=red|kick]  Bölümü kendi kendine oynatır, sonucu yazdırır ve çıkar.
##   --shots=KLASÖR         Tanıtım ekran görüntülerini alır ve çıkar.

const RED_HOLD_SECONDS := 3.0

var garage: Garage
var hikmet: Hikmet
var player: Player
var hud: Hud

var phase := "intro"   # intro, explore, bag, remote, panel, platform, departing, done
var fez_on := false
var fez_unlocked := false
var remote_given := false
var red_hold := 0.0
var _panel_busy := false
var _idle_idx := 0
var _outcome := ""


func _ready() -> void:
	GameState.reset_run()
	garage = Garage.new()
	add_child(garage)
	hikmet = Hikmet.new()
	hikmet.position = Garage.HIKMET_POS
	add_child(hikmet)
	player = Player.new()
	player.position = Garage.SPAWN_POS
	add_child(player)
	hikmet.look_target = player
	hud = Hud.new()
	add_child(hud)
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(_on_focus)
	player.frozen = true
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ ana akış

func _run() -> void:
	var jump: int = await hud.title_screen()
	if jump > 1:
		# Gizli Yaratıcı Menüsü: doğrudan seçilen bölüme (varsayılan çanta ve sonuçlarla)
		GameState.ensure_defaults_for(jump)
		get_tree().change_scene_to_file("res://scenes/chapter%d.tscn" % jump)
		return
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH1_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH1_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.face(hikmet.global_position + Vector3(0, 1.3, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.2)

	# Giriş
	await _h("D1_H_01")
	await _h("D1_H_02")
	await _t("D1_T_03")
	await _h("D1_H_04")
	await _t("D1_T_05")
	await _h("D1_H_06")
	player.frozen = false
	phase = "explore"
	hud.show_controls(true)
	get_tree().create_timer(18.0).timeout.connect(func(): hud.show_controls(false))
	hud.set_objective(tr("UI_OBJ_MACHINE"))
	await _wait_near(Garage.PLATFORM_POS, 2.6)

	# Kostüm
	player.frozen = true
	hud.show_controls(false)
	player.face(Garage.PLATFORM_POS + Vector3(0, 1.3, 0))
	await _t("D1_T_07")
	player.face(hikmet.global_position + Vector3(0, 1.3, 0))
	await _h("D1_H_08")
	await _t("D1_T_09")
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_FADE_5MIN"), 28, Color(1, 1, 1, 0.85)]], 1.8)
	hud.clear_card()
	_set_fez(true)
	fez_unlocked = true
	player.global_position = Vector3(-0.6, 0, 0.8)
	player.face(hikmet.global_position + Vector3(0, 1.3, 0))
	await hud.fade_to(0.0, 0.8)
	await _h("D1_H_10")
	await _t("D1_T_11")
	await _h("D1_H_12")
	await _h("D1_H_13")

	# Çanta
	phase = "bag"
	player.frozen = false
	hud.update_bag(GameState.bag)
	_update_bag_objective()
	_flash_prompt(tr("UI_FEZ_HINT"), 5.0)
	await _wait_bag_full()

	# Telsiz-Kumanda
	phase = "remote"
	hud.set_objective("")
	hud.bag_locked = true
	hud.toggle_bag(false)
	hud.update_bag(GameState.bag)
	await _wait_seconds(2.0)
	player.frozen = true
	player.face(hikmet.global_position + Vector3(0, 1.3, 0))
	await _h("D1_H_15")
	await _h("D1_H_16")
	remote_given = true
	player.show_remote(true)
	hud.set_signal(GameState.telsiz_bag)
	await _h("D1_H_17")
	await _h("D1_H_18")
	await _h("D1_H_19")
	await _t("D1_T_20")
	await _h("D1_H_21")

	# Panel
	phase = "panel"
	player.frozen = false
	hud.set_objective(tr("UI_OBJ_PANEL"))
	hud.bark("SPK_HIKMET", "D1_H_22", 3.5)
	if GameState.autotest:
		await _use_panel()
	while phase == "panel":
		await get_tree().process_frame
	if phase == "done":
		return

	# Platform
	hud.set_objective(tr("UI_OBJ_PLATFORM"))
	await _wait_on_platform()
	if phase == "done":
		return
	await _departure()


func _departure() -> void:
	phase = "departing"
	player.frozen = true
	hud.set_objective("")
	hud.set_red_progress(0.0)
	player.face(garage.panel_node.global_position + Vector3(0, 1.2, 0))
	# Makine ısınır
	var tw := create_tween().set_parallel()
	tw.tween_property(garage, "spin", 6.0, 1.5)
	tw.tween_property(garage.machine_light, "light_energy", 3.0, 1.5)
	await _wait_seconds(1.6)
	# ...ve takılır
	tw.kill()
	garage.spin = 0.0
	garage.machine_light.light_energy = 0.4
	player.shake(0.8)
	hud.bark("SPK_HIKMET", "D1_H_26", 5.0)
	hud.set_objective(tr("UI_MACHINE_STUCK"))
	var pick := 0 if GameState.autotest_variant == "kick" else 1
	var choice := await hud.choose(["UI_CHOICE_KICK_ME", "UI_CHOICE_KICK_HIKMET"], 5.0, pick)
	hud.set_objective("")
	if choice == 0:
		_outcome = "1.2"
		await _player_kick()
		garage.panel_screen.modulate = Color("ff5a4a")
		GameState.telsiz_bag = mini(5, GameState.telsiz_bag + 1)
		hud.set_signal(GameState.telsiz_bag)
		GameState.flags["panel_cracked"] = true
		await _t("D1_T_28")
		await _h("D1_H_29")
	else:
		_outcome = "1.1"
		await _hikmet_kick()
		await _h("D1_H_27")
	GameState.set_outcome(1, _outcome)

	# Kalkış
	var tw2 := create_tween().set_parallel()
	tw2.tween_property(garage, "spin", 14.0, 2.0)
	tw2.tween_property(garage.machine_light, "light_energy", 8.0, 2.0)
	hud.bark("SPK_HIKMET", "D1_H_30", 3.0)
	player.shake(0.6)
	await _wait_seconds(1.4)
	await hud.fade_to(1.0, 1.2, Color.WHITE)
	await _wait_seconds(0.6)
	await _end_chapter()


# ---------------------------------------------------------------- tekme

## Tolga tekme atar: güç çubuğu gidip gelir, yeşilde basılırsa makine çalışır.
## Zayıf tekmede Hikmet laf sokar, tekrar denenir (üçüncüde her türlü olur).
func _player_kick() -> void:
	phase = "kick"
	var panel_top := garage.panel_node.global_position + Vector3(0, 0.9, 0)
	player.face(panel_top)
	hud.set_objective(tr("UI_OBJ_KICK"))
	var meter := KickMeter.new()
	meter.label_text = tr("UI_KICK_HINT")
	hud.add_child(meter)
	var vp := get_viewport().get_visible_rect().size
	meter.position = Vector2((vp.x - meter.size.x) / 2.0, vp.y * 0.12)
	var tries := 0
	var z := "weak"
	while true:
		tries += 1
		meter.visible = true
		var t := randf() * 0.3
		var v := 0.0
		var speed := 1.3 + tries * 0.3
		var auto_at := 0.3 if tries == 1 else 0.7
		while true:
			t += get_process_delta_time()
			v = pingpong(t * speed, 1.0)
			meter.value = v
			if GameState.autotest and absf(v - auto_at) < 0.06:
				break
			if Input.is_action_just_pressed("kick"):
				break
			await get_tree().process_frame
		meter.flash = 1.0
		z = KickMeter.zone(v)
		if tries >= 3 and z == "weak":
			z = "sweet"
		var power: float = {"weak": 0.15, "sweet": 0.7, "strong": 1.0}[z]
		await _wait_seconds(0.15)
		meter.visible = false
		await player.kick(garage.panel_node.global_position, power, func(): _panel_hit(power))
		if z != "weak":
			break
		await _h("D1_H_KICK_WEAK" if tries == 1 else "D1_H_KICK_WEAK2")
		player.face(panel_top)
	meter.queue_free()
	hud.set_objective("")
	phase = "departing"
	if z == "strong":
		await _h("D1_H_KICK_STRONG")


## Hikmet tekme atar: kamera onu takip eder.
func _hikmet_kick() -> void:
	hikmet.kick_hit.connect(func(): _panel_hit(0.8), CONNECT_ONE_SHOT)
	hikmet.kick(garage.panel_node.global_position, _hikmet_kick_spot())
	await get_tree().process_frame
	while hikmet.is_kicking():
		var head := hikmet.global_position + Vector3(0, 1.0, 0)
		_look_toward(head, get_process_delta_time())
		await get_tree().process_frame
	player.face(garage.panel_node.global_position + Vector3(0, 1.2, 0))


## Hikmet'in tekme noktası: panelin yanında, oyuncunun bakış çizgisine dik (profilden görünür).
func _hikmet_kick_spot() -> Vector3:
	var k := garage.panel_node.global_position
	var d := k - player.global_position
	d.y = 0.0
	var n := Vector3(-d.z, 0, d.x).normalized()
	if n.dot(hikmet.global_position - k) < 0.0:
		n = -n
	return k + n * 0.8 - d.normalized() * 0.15


func _look_toward(point: Vector3, delta: float) -> void:
	var to := point - player.global_position
	var yaw := atan2(-to.x, -to.z)
	var pitch := atan2(to.y - Player.EYE, Vector2(to.x, to.z).length())
	var k := clampf(delta * 6.0, 0.0, 1.0)
	player.rotation.y = lerp_angle(player.rotation.y, yaw, k)
	player.camera.rotation.x = lerpf(player.camera.rotation.x, pitch, k)


## Panele darbe: kıvılcım, panel sallanır, makine ışığı titrer. power 0..1.
func _panel_hit(power: float) -> void:
	var p := CPUParticles3D.new()
	var m := SphereMesh.new()
	m.radius = 0.02
	m.height = 0.04
	m.radial_segments = 4
	m.rings = 2
	p.mesh = m
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("ffd24a")
	mat.emission_enabled = true
	mat.emission = Color("ffb020")
	mat.emission_energy_multiplier = 4.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	p.material_override = mat
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = int(lerpf(8, 60, power))
	p.lifetime = 0.7
	p.spread = 70.0
	p.direction = Vector3.UP
	p.initial_velocity_min = 1.0
	p.initial_velocity_max = lerpf(2.0, 5.0, power)
	p.position = garage.panel_node.global_position + Vector3(0, 1.0, 0)
	add_child(p)
	p.emitting = true
	get_tree().create_timer(1.5).timeout.connect(p.queue_free)
	var base := garage.panel_node.rotation
	var tw := create_tween()
	tw.tween_property(garage.panel_node, "rotation:z", base.z + 0.12 * power, 0.06)
	tw.tween_property(garage.panel_node, "rotation:z", base.z - 0.08 * power, 0.1)
	tw.tween_property(garage.panel_node, "rotation:z", base.z, 0.15)
	garage.machine_light.light_energy = 0.4 + 4.0 * power
	var tw2 := create_tween()
	tw2.tween_property(garage.machine_light, "light_energy", 0.4, 0.4)
	if power < 0.3:
		garage.panel_screen.modulate = Color("ffd60a")
		get_tree().create_timer(0.3).timeout.connect(func(): garage.panel_screen.modulate = Color("6ff2c8"))
	player.shake(0.4 + power)


func _early_end() -> void:
	phase = "done"
	player.frozen = true
	hud.set_red_progress(0.0)
	hud.set_objective("")
	await hud.fade_to(1.0, 0.25, Color.WHITE)
	await _wait_seconds(0.8)
	player.face(hikmet.global_position + Vector3(0, 1.3, 0))
	await hud.fade_to(0.0, 0.6, Color.WHITE)
	await _h("D1_H_31")
	_outcome = "1.3"
	GameState.set_outcome(1, _outcome)
	await hud.fade_to(1.0, 1.0)
	await hud.card([[tr("UI_EARLY_END"), 26, Color(1, 1, 1, 0.9)]], 3.0)
	hud.clear_card()
	await _end_chapter()


func _end_chapter() -> void:
	hud.set_fez(false)
	hud.set_objective("")
	var chart := _make_chart(_outcome)
	var result := await hud.show_flowchart(chart, _outcome != "1.3")
	if GameState.autotest and GameState.autotest_variant == "next":
		# Bölüm geçişi testi: Bölüm 1'in sonucu ve çantasıyla Bölüm 2'ye geç
		print("AUTOTEST chapter=1 -> 2 outcome=%s bag=%s" % [_outcome, GameState.bag])
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter2.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter2.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart(outcome: String) -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW_TITLE")
	c.nodes = [
		{"id": "garage", "key": "FLOW_GARAGE", "pos": Vector2(0.5, 0.18)},
		{"id": "costume", "key": "FLOW_COSTUME", "pos": Vector2(0.5, 0.28)},
		{"id": "bag", "key": "FLOW_BAG", "pos": Vector2(0.5, 0.38)},
		{"id": "remote", "key": "FLOW_REMOTE", "pos": Vector2(0.5, 0.48)},
		{"id": "panel", "key": "FLOW_PANEL", "pos": Vector2(0.37, 0.58)},
		{"id": "1.1", "key": "FLOW_1_1", "pos": Vector2(0.24, 0.7), "outcome": true},
		{"id": "1.2", "key": "FLOW_1_2", "pos": Vector2(0.5, 0.7), "outcome": true},
		{"id": "1.3", "key": "FLOW_1_3", "pos": Vector2(0.77, 0.7), "outcome": true},
	]
	c.edges = [["garage", "costume"], ["costume", "bag"], ["bag", "remote"], ["remote", "panel"],
		["panel", "1.1"], ["panel", "1.2"], ["remote", "1.3"]]
	for id in ["garage", "costume", "bag", "remote"]:
		c.taken[id] = true
	if outcome != "1.3":
		c.taken["panel"] = true
	c.taken[outcome] = true
	for id in ["1.1", "1.2", "1.3"]:
		if GameState.has_seen(id):
			c.seen[id] = true
	if GameState.has_seen("1.1") or GameState.has_seen("1.2"):
		c.seen["panel"] = true
	var names: Array[String] = []
	for id in GameState.bag:
		names.append(tr(Items.name_key(id)))
	c.footer_lines = [
		tr("UI_FLOW_STATS") % GameState.telsiz_bag + "     ·     " + tr("UI_FLOW_BAG") % ", ".join(names),
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_NEXT") if outcome != "1.3" else tr("UI_EARLY_END"),
		tr("UI_FLOW_CONTINUE") if outcome != "1.3" else tr("UI_FLOW_REPLAY"),
	]
	return c


# ================================================================ her kare

func _process(delta: float) -> void:
	if hud == null:
		return
	hud.fez.motion = player.horizontal_speed()

	if fez_unlocked and phase not in ["departing", "done"] and Input.is_action_just_pressed("fez"):
		_set_fez(not fez_on)

	if phase in ["bag", "panel", "platform"] and Input.is_action_just_pressed("bag"):
		hud.update_bag(GameState.bag)
		hud.toggle_bag(not hud.is_bag_open())
	if phase == "bag" and hud.is_bag_open():
		for i in 5:
			if Input.is_action_just_pressed("choice_%d" % (i + 1)) and i < GameState.bag.size():
				_put_back(i)

	# Kırmızı düğme: Telsiz-Kumanda verildikten sonra, kalkıştan önce ve diyalog sırasında değil
	if remote_given and phase in ["panel", "platform"] and not _panel_busy:
		if Input.is_action_pressed("red_button"):
			red_hold += delta
			hud.set_red_progress(red_hold / RED_HOLD_SECONDS)
			player.press_red(red_hold / RED_HOLD_SECONDS)
			if red_hold >= RED_HOLD_SECONDS:
				red_hold = 0.0
				_early_end()
		elif red_hold > 0.0:
			red_hold = maxf(0.0, red_hold - delta * 2.0)
			hud.set_red_progress(red_hold / RED_HOLD_SECONDS)
			player.press_red(red_hold / RED_HOLD_SECONDS)

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not get_tree().paused \
			and phase in ["explore", "bag", "panel", "platform"] and Input.is_action_just_pressed("advance"):
		_capture_mouse()


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	if id.begins_with("item:"):
		if phase != "bag":
			hud.set_prompt("")
		elif GameState.bag.size() >= 5:
			hud.set_prompt(tr("UI_PROMPT_FULL"))
		else:
			hud.set_prompt(tr("UI_PROMPT_TAKE") % tr(Items.name_key(id.trim_prefix("item:"))))
	elif id == "panel" and phase == "panel":
		hud.set_prompt(tr("UI_PROMPT_PANEL"))
	elif id == "hikmet" and phase not in ["intro", "departing", "done"]:
		hud.set_prompt(tr("UI_PROMPT_HIKMET"))
	else:
		hud.set_prompt("")


func _on_interact(id: String) -> void:
	if id.begins_with("item:") and phase == "bag":
		_pick(id.trim_prefix("item:"))
	elif id == "panel" and phase == "panel":
		_use_panel()
	elif id == "hikmet" and phase not in ["intro", "departing", "done"]:
		var lines := ["D1_H_IDLE_1", "D1_H_IDLE_2", "D1_H_IDLE_3"]
		if fez_on:
			lines.append("D1_H_IDLE_4")
		hud.bark("SPK_HIKMET", lines[_idle_idx % lines.size()])
		_idle_idx += 1
	_on_focus(player.focus_id)


func _pick(id: String) -> void:
	if GameState.bag.size() >= 5:
		hud.bark("SPK_HIKMET", "D1_H_14")
		return
	if id in GameState.bag:
		return
	GameState.bag.append(id)
	garage.set_item_visible(id, false)
	hud.update_bag(GameState.bag)
	_update_bag_objective()
	if GameState.bag.size() == 5:
		hud.bark("SPK_HIKMET", "D1_H_14", 4.5)
	else:
		hud.bark("SPK_HIKMET", Items.comment_key(id), 4.5)


func _put_back(index: int) -> void:
	var id: String = GameState.bag[index]
	GameState.bag.remove_at(index)
	garage.set_item_visible(id, true)
	hud.update_bag(GameState.bag)
	_update_bag_objective()
	hud.bark("SPK_HIKMET", "HIKMET_ITEM_BACK", 3.0)


func _use_panel() -> void:
	if _panel_busy:
		return
	_panel_busy = true
	player.frozen = true
	hud.set_prompt("")
	while true:
		var v := await hud.keypad("1453")
		if v == "1453":
			break
		elif v == "1977":
			await _h("D1_H_YEAR_1977")
		elif v == "2026":
			await _h("D1_H_YEAR_2026")
		else:
			await _t("D1_T_YEAR_OTHER")
	garage.panel_screen.text = "14:53"
	player.face(garage.panel_screen.global_position)
	await _h("D1_H_23")
	await _t("D1_T_24")
	await _h("D1_H_25")
	player.frozen = false
	_panel_busy = false
	if phase == "panel":
		phase = "platform"


# ================================================================ yardımcılar

func _h(key: String) -> void:
	hikmet.talking = true
	await hud.say("SPK_HIKMET", key)
	hikmet.talking = false


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _set_fez(on: bool) -> void:
	fez_on = on
	GameState.flags["fez"] = on
	hud.set_fez(on)


func _update_bag_objective() -> void:
	if phase == "bag":
		hud.set_objective(tr("UI_OBJ_BAG") % GameState.bag.size())


func _flash_prompt(text: String, seconds: float) -> void:
	hud.set_prompt(text)
	await _wait_seconds(seconds)
	if hud and player.focus_id == "":
		hud.set_prompt("")


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _wait_seconds(s: float) -> void:
	if GameState.autotest:
		await get_tree().process_frame
		return
	await get_tree().create_timer(s).timeout


func _wait_near(point: Vector3, radius: float) -> void:
	if GameState.autotest:
		player.global_position = point + Vector3(0, 0, radius - 0.5)
	while true:
		var d := Vector2(player.global_position.x - point.x, player.global_position.z - point.z).length()
		if d <= radius:
			return
		await get_tree().process_frame


func _wait_bag_full() -> void:
	if GameState.autotest:
		for id in Items.IDS.slice(0, 5):
			_pick(id)
	while GameState.bag.size() < 5 or hud.is_bag_open():
		await get_tree().process_frame


func _wait_on_platform() -> void:
	if GameState.autotest:
		if GameState.autotest_variant == "red":
			# Kırmızı düğme testi: düğmeye basılıymış gibi tut
			for i in 400:
				red_hold += 0.05
				hud.set_red_progress(red_hold / RED_HOLD_SECONDS)
				if red_hold >= RED_HOLD_SECONDS:
					red_hold = 0.0
					await _early_end()
					return
				await get_tree().process_frame
		player.global_position = Garage.PLATFORM_POS + Vector3(0, 0.1, 0)
	while phase == "platform":
		var d := Vector2(player.global_position.x - Garage.PLATFORM_POS.x, player.global_position.z - Garage.PLATFORM_POS.z).length()
		if d <= 0.8:
			return
		await get_tree().process_frame


func _autotest_report() -> void:
	var ok := true
	var expected: String = {"": "1.1", "kick": "1.2", "red": "1.3"}[GameState.autotest_variant]
	if _outcome != expected:
		ok = false
		printerr("AUTOTEST: beklenen sonuç %s, gelen %s" % [expected, _outcome])
	if GameState.bag.size() != 5:
		ok = false
		printerr("AUTOTEST: çantada %d eşya var" % GameState.bag.size())
	if GameState.chapter_outcomes.get(1, "") != _outcome:
		ok = false
		printerr("AUTOTEST: bölüm sonucu kaydedilmedi")
	if _outcome == "1.2" and GameState.telsiz_bag != 3:
		ok = false
		printerr("AUTOTEST: Telsiz Bağı 3 olmalıydı, %d" % GameState.telsiz_bag)
	print("AUTOTEST %s variant=%s outcome=%s bag=%s telsiz=%d" % ["PASS" if ok else "FAIL", GameState.autotest_variant, _outcome, GameState.bag, GameState.telsiz_bag])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(file_name: String) -> void:
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(GameState.shots_dir.path_join(file_name))
	print("shot: ", file_name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	await get_tree().create_timer(0.5).timeout
	# 1. Açılış uyarısı
	hud.set_fade(1.0)
	hud.add_card_line(tr("UI_DISCLAIMER_1"), 40)
	hud.add_card_line(tr("UI_DISCLAIMER_2"), 22, Color(1, 1, 1, 0.7))
	await _shot("01_acilis.png")
	hud.clear_card()
	hud.set_fade(0.0)

	# 2. Giriş: Hikmet ve makine
	player.global_position = Vector3(0.9, 0, 1.9)
	player.face(Vector3(-0.6, 1.2, -1.0))
	hikmet.talking = true
	hud.bark("SPK_HIKMET", "D1_H_06", 30.0)
	await _shot("02_giris.png")

	# 3. Tezgâh, fes ve çanta
	hikmet.talking = false
	_set_fez(true)
	phase = "bag"
	for id in ["phone", "tape"]:
		GameState.bag.append(id)
		garage.set_item_visible(id, false)
	hud.update_bag(GameState.bag)
	_update_bag_objective()
	player.global_position = Vector3(-2.5, 0, 0.35)
	player.face(Vector3(-3.4, 0.95, 0.4))
	hud.set_prompt(tr("UI_PROMPT_TAKE") % tr("ITEM_CHICKPEAS"))
	hud.bark("SPK_HIKMET", "HIKMET_ITEM_TAPE", 30.0)
	await _shot("03_canta.png")

	# 4. Zamanatör ve Telsiz-Kumanda
	hud.set_prompt("")
	phase = "panel"
	hud.set_objective(tr("UI_OBJ_PANEL"))
	hud.set_signal(2)
	player.show_remote(true)
	player.global_position = Vector3(1.6, 0, 1.2)
	player.face(Vector3(-0.2, 1.3, -1.6))
	hud.bark("SPK_HIKMET", "D1_H_19", 30.0)
	await _shot("04_zamanator.png")

	# 5. Panel: 1453 → 14:53
	garage.panel_screen.text = "14:53"
	player.global_position = Vector3(1.0, 0, -0.1)
	player.face(garage.panel_screen.global_position)
	hud.set_objective("")
	hud.bark("SPK_HIKMET", "D1_H_23", 30.0)
	await _shot("05_panel.png")

	# 6. Makine takıldı: süreli karar
	garage.spin = 0.0
	player.global_position = Garage.PLATFORM_POS + Vector3(0.2, 0.1, 0.3)
	player.face(Vector3(-1.4, 1.3, -0.4))
	hud.set_objective(tr("UI_MACHINE_STUCK"))
	hud.bark("SPK_HIKMET", "D1_H_26", 30.0)
	hud.choose(["UI_CHOICE_KICK_ME", "UI_CHOICE_KICK_HIKMET"], 5.0)
	await get_tree().create_timer(1.2).timeout
	await _shot("06_secim.png")

	# 8. Arka duvar yakından: tabela ve patent afişi (yazılar panellere sığıyor mu?)
	hud.set_objective("")
	hud.choose_cancel()
	player.global_position = Vector3(2.2, 0, -1.3)
	player.face(Vector3(2.25, 2.3, -3.0))
	hud.bark("SPK_TOLGA", "D1_T_05", 30.0)
	await _shot("08_duvar.png")
	hud.bark("SPK_HIKMET", "D1_H_26", 30.0)

	# 9. Tolga panele tekme atıyor (güç çubuğu ve bacak)
	player.global_position = Garage.PLATFORM_POS + Vector3(0, 0.1, 0)
	var panel_top := garage.panel_node.global_position + Vector3(0, 0.9, 0)
	player.face(panel_top)
	hud.set_objective(tr("UI_OBJ_KICK"))
	var meter := KickMeter.new()
	meter.label_text = tr("UI_KICK_HINT")
	meter.value = 0.72
	hud.add_child(meter)
	var vp := get_viewport().get_visible_rect().size
	meter.position = Vector2((vp.x - meter.size.x) / 2.0, vp.y * 0.12)
	player.kick(garage.panel_node.global_position, 0.7, func(): _panel_hit(0.7))
	while player.leg.rotation_degrees.x < 88.0:
		await get_tree().process_frame
	Engine.time_scale = 0.0     # fotoğraf birkaç kare sürer: tekme havada dursun
	await _shot("09_tekme.png")
	Engine.time_scale = 1.0
	meter.queue_free()
	hud.set_objective("")
	await get_tree().create_timer(0.8).timeout

	# 10. Hikmet tekme atıyor
	player.global_position = Garage.PLATFORM_POS + Vector3(0, 0.1, 0)
	hikmet.global_position = Garage.HIKMET_POS
	hikmet.kick_hit.connect(func(): _panel_hit(0.8), CONNECT_ONE_SHOT)
	hikmet.kick(garage.panel_node.global_position, _hikmet_kick_spot())
	await hikmet.kick_hit
	player.face(hikmet.global_position + Vector3(0, 0.8, 0))
	Engine.time_scale = 0.0
	await _shot("10_hikmet_tekme.png")
	Engine.time_scale = 1.0

	# 7. Akış şeması
	GameState.seen_outcomes = {"1.1": true}
	GameState.bag = ["phone", "tape", "chickpeas", "cube", "cologne"] as Array[String]
	GameState.telsiz_bag = 3
	hud.set_fez(false)
	var chart := _make_chart("1.2")
	hud.add_child(chart)
	await _shot("07_akis_semasi.png")
	get_tree().quit()

