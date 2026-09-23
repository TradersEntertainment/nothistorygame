extends Node3D
## Bölüm 2 — Yağlı Kızaklar (CHAPTERS.md, Bölüm 2).
## Gökten düşüş → telsiz (Telsiz Bağı) → kızak kaçışı (şerit, zıplama, kadırga kovalar,
## iade garantisi geri sayar) → Haliç: kıyı mı zincir mi (süreli) → sonuç → akış şeması.
##
## Sonuçlar: 2.1 kıyıda yakalandı · 2.2 kıyıya gizlice çıktı (hiç tökezlemeden)
##           2.3 zincire ulaştı · 2.4 zincirden düştü · 2.5 kırmızı düğme (garanti içinde)
##
## Test: --chapter=2 --autotest[=perfect|chain|chainfail|red]

const RUN_SPEED := 7.4
const SHIP_SPEED := 6.6
const START_S := 14.0
const START_GAP := 13.0
const BOW := 9.9                 # kadırga merkezinden pruvaya
const CHECKPOINTS := [14.0, 50.0, 88.0]
const WARRANTY_WARN_S := 36.0
const WARRANTY_END_S := 100.0
const RED_HOLD_SECONDS := 3.0

var level: Slipway
var player: Player
var hud: Hud

var _underwater := false
var phase := "intro"        # intro, run, caught, swim, done
var lane := 1
var ship_s := 0.0
var stumble_t := 0.0
var hits := 0
var red_hold := 0.0
var warranty := true
var _warned := false
var _after_warranty_said := false
var _stumble_i := 0
var _outcome := ""


func _ready() -> void:
	GameState.snapshot(2)
	level = Slipway.new()
	add_child(level)
	player = Player.new()
	add_child(player)
	hud = Hud.new()
	add_child(hud)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	player.show_remote(true)
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH2_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH2_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()

	# Gökten düşüş
	ship_s = START_S - START_GAP - BOW
	level.set_ship_s(ship_s)
	player.global_position = level.s_to_world(START_S, 0.0, 6.0)
	player.face(level.s_to_world(START_S + 25.0, 0.0, -4.0))
	_capture_mouse()
	await hud.fade_to(0.0, 0.6)
	await _wait(1.4)
	player.shake(1.2)
	await _wait(0.4)
	player.face(level.s_to_world(ship_s + BOW, 0.0, 2.5))

	await _t("D2_T_01")
	await _h("D2_H_02")
	var radio := await hud.choose(["UI_CHOICE_RADIO_YES", "UI_CHOICE_RADIO_NO"], 4.0, 0)
	GameState.flags["ch2_radio_answered"] = radio == 0
	if radio == 0:
		GameState.telsiz_bag = mini(5, GameState.telsiz_bag + 1)
		hud.set_signal(GameState.telsiz_bag)
		await _h("D2_H_RADIO_YES")
	else:
		await _h("D2_H_RADIO_NO")
	await _t("D2_T_03")
	await _h("D2_H_04")
	await _t("D2_T_05")
	await _say("SPK_SOLDIER", "D2_S_06")
	hud.bark("SPK_HIKMET", "D2_H_07", 1.5)

	# Kızak kaçışı
	player.face(level.s_to_world(START_S + 40.0, 0.0, 1.0))
	phase = "run"
	player.move_mode = "script"
	player.frozen = false
	hud.set_objective(tr("UI_OBJ_RUN"))
	_flash_prompt(tr("UI_RUN_HINT"), 6.0)
	while phase in ["run", "caught"]:
		await get_tree().process_frame
	if phase == "done":
		return
	await _swim()
	await _end_chapter()


# ================================================================ koşu

func _process(delta: float) -> void:
	if hud == null:
		return
	hud.fez.motion = player.horizontal_speed() * 0.6
	# Sualtı görünümü kameranın gerçek yüksekliğine bağlı (dalış, düşüş)
	var uw := player.camera.global_position.y < level.water_y - 0.02
	if uw != _underwater:
		_underwater = uw
		hud.set_underwater(uw)
		level.set_underwater(uw)
	if phase not in ["done"] and Input.is_action_just_pressed("fez"):
		var on: bool = not GameState.flags.get("fez", true)
		GameState.flags["fez"] = on
		hud.set_fez(on)
	if phase == "run":
		_run_step(delta)
		_red_button(delta)


func _run_step(delta: float) -> void:
	var s := level.world_to_s(player.global_position)
	var x := level.world_to_x(player.global_position)
	if Input.is_action_just_pressed("move_left"):
		lane = maxi(0, lane - 1)
	if Input.is_action_just_pressed("move_right"):
		lane = mini(2, lane + 1)
	if GameState.autotest:
		_auto_step(s)

	stumble_t = maxf(0.0, stumble_t - delta)
	var speed := RUN_SPEED * (0.35 if stumble_t > 0.0 else 1.0)
	var side := level.track.global_transform.basis.x.normalized()
	var target_x: float = Slipway.LANES[lane]
	player.script_velocity = level.down_dir() * speed + side * (target_x - x) * 7.0

	# Kadırga: sabit hızla gelir, çok geride kalırsa yetişir
	ship_s += SHIP_SPEED * delta
	ship_s = maxf(ship_s, s - BOW - 22.0)
	level.set_ship_s(ship_s)
	var gap := s - (ship_s + BOW)
	hud.set_chase(tr("UI_CHASE"), 1.0 - clampf(gap / START_GAP, 0.0, 1.0))

	# Engeller
	var prompt := ""
	for o in level.obstacles:
		if o["resolved"]:
			continue
		var ds: float = o["s"] - s
		if ds <= 0.0:
			o["resolved"] = true
			var hit := false
			if o["kind"] == "rope":
				hit = player.is_on_floor()
			else:
				hit = lane in o["lanes"]
			if hit:
				_stumble(o)
		elif ds < 12.0 and prompt == "":
			if o["kind"] == "rope":
				prompt = tr("UI_QTE_JUMP")
			elif lane in o["lanes"]:
				prompt = tr("UI_QTE_DODGE")
	hud.set_qte(prompt)

	# İade garantisi
	if not _warned and s > WARRANTY_WARN_S:
		_warned = true
		hud.bark("SPK_HIKMET", "D2_H_WARRANTY", 3.5)
	if warranty and s > WARRANTY_END_S:
		warranty = false
		hud.bark("SPK_HIKMET", "D2_H_WARRANTY_END", 3.0)

	if gap < 0.8:
		_caught(s)
	elif s >= Slipway.LENGTH - 1.0:
		phase = "swim"


func _stumble(o: Dictionary) -> void:
	hits += 1
	stumble_t = 0.9
	player.shake(1.0)
	if o["kind"] == "rope":
		hud.bark("SPK_SOLDIER", "D2_S_ROPE", 1.4)
	var lines := ["D2_T_STUMBLE_1", "D2_T_STUMBLE_2", "D2_T_STUMBLE_3"]
	hud.bark("SPK_TOLGA", lines[_stumble_i % lines.size()], 2.2)
	_stumble_i += 1


func _caught(s: float) -> void:
	phase = "caught"
	hits += 1
	player.frozen = true
	hud.set_qte("")
	await hud.fade_to(1.0, 0.3)
	await hud.card([[tr("UI_CAUGHT_SHIP"), 24, Color(1, 1, 1, 0.9)]], 2.4)
	hud.clear_card()
	var cp: float = CHECKPOINTS[0]
	for c in CHECKPOINTS:
		if c <= s:
			cp = c
	player.global_position = level.s_to_world(cp, 0.0, 0.4)
	player.velocity = Vector3.ZERO
	player.face(level.s_to_world(cp + 30.0, 0.0, -2.0))
	ship_s = cp - START_GAP - BOW
	level.set_ship_s(ship_s)
	level.reset_obstacles_after(cp)
	lane = 1
	stumble_t = 0.0
	await hud.fade_to(0.0, 0.5)
	player.frozen = false
	phase = "run"


func _red_button(delta: float) -> void:
	var pressed := Input.is_action_pressed("red_button")
	if GameState.autotest and GameState.autotest_variant == "red" and level.world_to_s(player.global_position) > 30.0:
		pressed = true
	if not warranty:
		if pressed and not _after_warranty_said:
			_after_warranty_said = true
			GameState.telsiz_bag = mini(5, GameState.telsiz_bag + 1)
			hud.set_signal(GameState.telsiz_bag)
			hud.bark("SPK_HIKMET", "D2_H_AFTER_WARRANTY", 3.0)
		return
	if pressed:
		red_hold += delta
	else:
		red_hold = maxf(0.0, red_hold - delta * 2.0)
	hud.set_red_progress(red_hold / RED_HOLD_SECONDS)
	player.press_red(red_hold / RED_HOLD_SECONDS)
	if red_hold >= RED_HOLD_SECONDS:
		red_hold = 0.0
		_early_end()


func _early_end() -> void:
	phase = "done"
	player.frozen = true
	hud.set_red_progress(0.0)
	hud.set_qte("")
	hud.set_chase("", 0.0)
	hud.set_objective("")
	await hud.fade_to(1.0, 0.3, Color.WHITE)
	await _wait(0.6)
	await hud.fade_to(1.0, 0.4)
	await _h("D2_H_24")
	_outcome = "2.5"
	await hud.card([[tr("UI_EARLY_END"), 26, Color(1, 1, 1, 0.9)]], 3.0)
	hud.clear_card()
	await _end_chapter()


# ================================================================ Haliç

func _swim() -> void:
	player.frozen = true
	player.move_mode = "walk"
	player.gravity_on = false
	player.velocity = Vector3.ZERO
	hud.set_chase("", 0.0)
	hud.set_qte("")
	hud.set_objective("")
	hud.set_red_progress(0.0)
	await _plunge()
	await _t("D2_T_08")
	await _h("D2_H_09")
	hud.set_objective(tr("UI_OBJ_SWIM"))
	var pick := 1 if GameState.autotest_variant in ["chain", "chainfail"] else 0
	var c := await hud.choose(["UI_CHOICE_SHORE", "UI_CHOICE_CHAIN"], 8.0, pick)
	hud.set_objective("")
	if c == -1:
		await _t("D2_T_CURRENT")
		c = 0
	if c == 0:
		await _to_shore()
	else:
		await _to_chain()


## Kızağın ucundan Haliç'e: fırlayış, havada süzülme, suya çarpma, sualtı, yüzeye çıkış.
## Kesme yok: kamera baştan sona oyuncunun gözünde kalır.
func _plunge() -> void:
	var p0 := player.global_position
	var fwd := level.down_dir()
	fwd.y = 0.0
	fwd = fwd.normalized()
	var land := level.swim_start()
	var surf := Vector3(land.x, level.water_y - Player.EYE, land.z)
	var under := surf + Vector3(0, -1.5, 0) + fwd * 1.2
	var peak := p0.lerp(surf, 0.35) + Vector3(0, 2.2, 0)
	hud.bark("SPK_TOLGA", "D2_T_FALL", 1.8)
	# Kadırga da kızağın ucuna kadar gelir, burnu suyun üstünde durur
	var ship_tw := create_tween()
	ship_tw.tween_method(func(v: float):
		ship_s = v
		level.set_ship_s(v), ship_s, Slipway.LENGTH - BOW + 1.5, 2.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	# Havada: yay çizerek düşer, kamera suya bakar
	var pitch0 := player.camera.rotation.x
	var air := create_tween()
	air.tween_method(func(t: float):
		var a := p0.lerp(peak, t)
		var b := peak.lerp(surf, t)
		player.global_position = a.lerp(b, t)
		player.camera.rotation.x = lerpf(pitch0, -0.8, smoothstep(0.1, 0.9, t)), 0.0, 1.0, 1.0).set_trans(Tween.TRANS_LINEAR)
	await air.finished
	# Şap!
	level.splash(surf + fwd * 0.5)
	player.shake(0.8)
	var down := create_tween()
	down.tween_property(player, "global_position", under, 0.45).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	down.parallel().tween_property(player.camera, "rotation:x", -0.2, 0.45)
	await down.finished
	level.bubbles(under + Vector3(0, Player.EYE, 0) + fwd * 0.6, 1.0)
	# Yüzeye dönerken şehre doğru döner
	var look := land + Vector3(-10, 1.5, -60)
	var to := look - surf
	var yaw := atan2(-to.x, -to.z)
	var yaw0 := player.rotation.y
	await _wait(0.7)
	var up := create_tween()
	up.tween_property(player, "global_position", surf + Vector3(0, -0.1, 0), 0.7).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	up.parallel().tween_method(func(t: float): player.rotation.y = lerp_angle(yaw0, yaw, t), 0.0, 1.0, 0.9)
	up.parallel().tween_property(player.camera, "rotation:x", 0.05, 0.9)
	await up.finished
	level.splash(surf + Vector3(0, 0, -0.6) - fwd * 0.2)
	var rise := create_tween()
	rise.tween_property(player, "global_position", _water(land), 0.3).set_ease(Tween.EASE_OUT)
	await rise.finished
	player.floating = true
	player.face(look)


func _water(p: Vector3) -> Vector3:
	return Vector3(p.x, level.water_y - Player.EYE + 0.25, p.z)


func _swim_to(target: Vector3, seconds: float) -> void:
	player.face(Vector3(target.x, level.water_y + 1.0, target.z))
	if GameState.autotest:
		player.global_position = target
		await get_tree().process_frame
		return
	var tw := create_tween()
	tw.tween_property(player, "global_position", target, seconds).set_trans(Tween.TRANS_SINE)
	await tw.finished


func _to_shore() -> void:
	GameState.flags["ch2_route"] = "shore"
	var sp := level.shore_point()
	await _swim_to(_water(sp + Vector3(0, 0, 2.0)), 3.0)
	player.floating = false
	player.global_position = Vector3(sp.x - 1.0, level.water_y + 0.2, sp.z + 3.2)
	player.face(sp + Vector3(2.0, 1.2, 1.0))
	if hits == 0:
		_outcome = "2.2"
		GameState.flags["ch2_sneaked"] = true
		await _say("SPK_HASAN", "D2_HA_11")
		await _say("SPK_HUSEYIN", "D2_HU_12")
		await _say("SPK_HASAN", "D2_HA_13")
		await _t("D2_T_10")
	else:
		_outcome = "2.1"
		await _say("SPK_SOLDIER", "D2_S_14" if GameState.flags.get("fez", true) else "D2_S_14_NOFEZ")
		await _t("D2_T_15")
		await _say("SPK_SOLDIER", "D2_S_16")
		await _budget()


func _to_chain() -> void:
	GameState.flags["ch2_route"] = "chain"
	var start := level.swim_start()
	var cp := level.chain_point()
	var mid := start.lerp(cp, 0.55)
	await _swim_to(_water(start.lerp(cp, 0.25)), 2.2)
	# Kayık yandan geçer: zamanında dal
	var side := (cp - start).cross(Vector3.UP).normalized()
	level.boat.global_position = Vector3(mid.x, level.water_y, mid.z) + side * 28.0
	level.boat.look_at(Vector3(mid.x, level.water_y, mid.z), Vector3.UP)
	var boat_tw := create_tween()
	boat_tw.tween_property(level.boat, "global_position", Vector3(mid.x, level.water_y, mid.z) - side * 28.0, 3.6)
	var swim_tw := create_tween()
	swim_tw.tween_property(player, "global_position", _water(mid), 3.6)
	var dived := false
	var t := 0.0
	while t < 3.6:
		var dt := get_process_delta_time()
		t += dt
		var in_window := t > 1.2 and t < 2.6
		hud.set_qte(tr("UI_QTE_DIVE") if t > 0.9 and t < 2.6 else "")
		var want := Input.is_action_just_pressed("dive") or (GameState.autotest and GameState.autotest_variant == "chain")
		if in_window and want and not dived:
			dived = true
			hud.set_qte("")
			level.splash(player.global_position + Vector3(0, Player.EYE, 0))
			swim_tw.kill()
			var down := create_tween()
			down.tween_property(player, "global_position", _water(mid) + Vector3(0, -1.4, 0), 0.3)
			level.bubbles(_water(mid) + Vector3(0, Player.EYE - 1.2, 0), 1.2)
			await _wait(1.4)
			var up := create_tween()
			up.tween_property(player, "global_position", _water(mid) + Vector3(0, -0.35, 0), 0.3)
			await up.finished
			level.splash(_water(mid) + Vector3(0, Player.EYE, 0))
			var rise := create_tween()
			rise.tween_property(player, "global_position", _water(mid), 0.2)
			await rise.finished
			break
		await get_tree().process_frame
	hud.set_qte("")
	if not dived:
		player.shake(1.2)
		await _say("SPK_ROWER", "D2_R_21")
	await _swim_to(_water(cp + Vector3(1.5, 0, 1.5)), 2.6)
	player.face(cp + Vector3(20, 1.0, -60))
	if dived:
		_outcome = "2.3"
		await _t("D2_T_18")
		await _h("D2_H_19")
		await _t("D2_T_20")
	else:
		_outcome = "2.4"
		GameState.flags["wet"] = true
		await _t("D2_T_22")
		await hud.fade_to(1.0, 0.8)
		player.floating = false
		var sp := level.shore_point()
		player.global_position = Vector3(sp.x - 1.0, level.water_y + 0.2, sp.z + 3.2)
		player.face(sp + Vector3(2.0, 1.2, 1.0))
		await hud.fade_to(0.0, 0.8)
		await _say("SPK_SOLDIER", "D2_S_23")
		await _budget()


func _budget() -> void:
	await hud.fade_to(1.0, 0.6)
	_delayed_bark(1.2, "SPK_HIKMET", "D2_H_17", 3.0)
	await hud.budget_map(tr("UI_BUDGET_TITLE"), tr("UI_BUDGET_FROM"), tr("UI_BUDGET_TO"), 4.0)


func _delayed_bark(delay: float, speaker: String, key: String, seconds: float) -> void:
	await _wait(delay)
	hud.bark(speaker, key, seconds)


# ================================================================ son

func _end_chapter() -> void:
	player.frozen = true
	hud.set_objective("")
	GameState.set_outcome(2, _outcome)
	GameState.flags["ch2_stumbles"] = hits
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, false)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	if result == "replay":
		get_tree().reload_current_scene()
	else:
		get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW2_TITLE")
	c.nodes = [
		{"id": "fall", "key": "FLOW2_FALL", "pos": Vector2(0.5, 0.17)},
		{"id": "radio", "key": "FLOW2_RADIO", "pos": Vector2(0.5, 0.27)},
		{"id": "clean", "key": "FLOW2_CLEAN", "pos": Vector2(0.37, 0.38)},
		{"id": "stumble", "key": "FLOW2_STUMBLE", "pos": Vector2(0.63, 0.38)},
		{"id": "2.5", "key": "FLOW_2_5", "pos": Vector2(0.88, 0.38), "outcome": true},
		{"id": "horn", "key": "FLOW2_HORN", "pos": Vector2(0.5, 0.5)},
		{"id": "2.1", "key": "FLOW_2_1", "pos": Vector2(0.13, 0.63), "outcome": true},
		{"id": "2.2", "key": "FLOW_2_2", "pos": Vector2(0.38, 0.63), "outcome": true},
		{"id": "2.3", "key": "FLOW_2_3", "pos": Vector2(0.62, 0.63), "outcome": true},
		{"id": "2.4", "key": "FLOW_2_4", "pos": Vector2(0.87, 0.63), "outcome": true},
	]
	c.edges = [["fall", "radio"], ["radio", "clean"], ["radio", "stumble"], ["radio", "2.5"],
		["clean", "horn"], ["stumble", "horn"], ["horn", "2.1"], ["horn", "2.2"], ["horn", "2.3"], ["horn", "2.4"]]
	c.taken["fall"] = true
	c.taken["radio"] = true
	if _outcome != "2.5":
		c.taken["clean" if hits == 0 else "stumble"] = true
		c.taken["horn"] = true
	c.taken[_outcome] = true
	for id in ["2.1", "2.2", "2.3", "2.4", "2.5"]:
		if GameState.has_seen(id):
			c.seen[id] = true
	var fez_on: bool = GameState.flags.get("fez", true)
	c.footer_lines = [
		tr("UI_FLOW_STATS") % GameState.telsiz_bag + "     ·     " + tr("UI_STUMBLES") % hits + "     ·     " + ("Fes: ✓" if fez_on else "Fes: ✗"),
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW2_NEXT") if _outcome != "2.5" else tr("UI_EARLY_END"),
		tr("UI_FLOW2_REPLAY"),
	]
	return c


# ================================================================ yardımcılar

func _h(key: String) -> void:
	await hud.say("SPK_HIKMET", key)


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


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
	if hud:
		hud.set_prompt("")


# ================================================================ otomatik test

## Test oyuncusu: engelleri görür, zıplar ya da şerit değiştirir.
## Varsayılan varyant ilk halatı bilerek kaçırır (en az bir tökezleme -> 2.1).
func _auto_step(s: float) -> void:
	for o in level.obstacles:
		if o["resolved"]:
			continue
		var ds: float = o["s"] - s
		if ds < 0.0 or ds > 6.0:
			continue
		if o["kind"] == "rope":
			var skip_first: bool = GameState.autotest_variant == "" and o["s"] == level.obstacles[0]["s"]
			if ds < 2.2 and not skip_first:
				player.jump()
		elif lane in o["lanes"]:
			for l in 3:
				if l not in o["lanes"]:
					lane = l
					break
		break


func _autotest_report() -> void:
	var expected: String = {"": "2.1", "perfect": "2.2", "chain": "2.3", "chainfail": "2.4", "red": "2.5"}.get(GameState.autotest_variant, "?")
	var ok := _outcome == expected
	if not ok:
		printerr("AUTOTEST: beklenen sonuç %s, gelen %s" % [expected, _outcome])
	if GameState.autotest_variant == "perfect" and hits != 0:
		ok = false
		printerr("AUTOTEST: kusursuz koşuda %d tökezleme" % hits)
	if GameState.autotest_variant == "" and hits == 0:
		ok = false
		printerr("AUTOTEST: tökezleme bekleniyordu")
	if GameState.chapter_outcomes.get(2, "") != _outcome:
		ok = false
		printerr("AUTOTEST: bölüm sonucu kaydedilmedi")
	if GameState.chapter_outcomes.has(1) and GameState.bag.size() != 5:
		ok = false
		printerr("AUTOTEST: Bölüm 1'in çantası Bölüm 2'ye taşınmadı")
	print("AUTOTEST %s chapter=2 variant=%s outcome=%s stumbles=%d telsiz=%d" % ["PASS" if ok else "FAIL", GameState.autotest_variant, _outcome, hits, GameState.telsiz_bag])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(file_name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(file_name))
	print("shot: ", file_name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	await get_tree().create_timer(0.6).timeout
	# 1. Varış: arkadaki kadırgaya bakış
	ship_s = START_S - START_GAP - BOW
	level.set_ship_s(ship_s)
	player.global_position = level.s_to_world(START_S, 0.0, 0.3)
	player.face(level.s_to_world(ship_s + BOW - 2.0, 0.0, 2.8))
	hud.bark("SPK_TOLGA", "D2_T_03", 30.0)
	await get_tree().create_timer(0.5).timeout
	await _shot("c2_01_varis.png")

	# 1b. Kadırga yandan
	hud.bark("SPK_SOLDIER", "D2_S_06", 30.0)
	player.global_position = level.s_to_world(ship_s + 4.0, 4.2, 0.3)
	player.face(level.s_to_world(ship_s - 1.0, 0.0, 3.0))
	await _shot("c2_08_kadirga.png")

	# 2. Koşu: önde halat, kadırga yaklaşıyor
	player.global_position = level.s_to_world(48.0, 0.0, 0.3)
	player.face(level.s_to_world(70.0, 0.0, -1.4))
	hud.set_objective(tr("UI_OBJ_RUN"))
	hud.set_qte(tr("UI_QTE_JUMP"))
	hud.set_chase(tr("UI_CHASE"), 0.55)
	hud.bark("SPK_SOLDIER", "D2_S_ROPE", 30.0)
	await _shot("c2_02_kosu.png")

	# 3. Aşağıda Haliç ve karşıda şehir
	hud.set_qte("")
	player.global_position = level.s_to_world(110.0, 2.4, 0.3)
	player.face(level.end_point() + Vector3(10, 4, -120))
	hud.bark("SPK_HIKMET", "D2_H_WARRANTY_END", 30.0)
	await _shot("c2_03_halic.png")

	# 3b. Kızağın ucundan Haliç'e uçuş
	hud.set_qte("")
	hud.set_objective("")
	hud.set_chase("", 0.0)
	var land := level.swim_start()
	var fly := level.end_point().lerp(land, 0.35) + Vector3(0, 2.4, 0)
	player.gravity_on = false
	player.global_position = fly
	player.face(land + Vector3(0, -1.0, -10))
	hud.bark("SPK_TOLGA", "D2_T_FALL", 30.0)
	await get_tree().create_timer(0.35).timeout
	await _shot("c2_09_ucus.png")

	# 3c. Sualtı
	player.global_position = Vector3(land.x, level.water_y - Player.EYE - 1.4, land.z)
	player.face(land + Vector3(-6, -0.4, -20))
	level.bubbles(player.global_position + Vector3(1.2, Player.EYE - 1.0, -4.0), 2.0)
	hud.bark("SPK_HIKMET", "D2_H_09", 30.0)
	await get_tree().create_timer(0.8).timeout
	await _shot("c2_10_sualti.png")
	player.global_position = _water(land)

	# 4. Suda: karar
	hud.set_chase("", 0.0)
	hud.set_objective(tr("UI_OBJ_SWIM"))
	player.gravity_on = false
	player.global_position = _water(level.swim_start())
	player.face(level.swim_start() + Vector3(-12, 2.0, -60))
	hud.choose(["UI_CHOICE_SHORE", "UI_CHOICE_CHAIN"], 8.0)
	await get_tree().create_timer(1.0).timeout
	await _shot("c2_04_karar.png")

	# 5. Kayık geliyor: dal!
	hud.choose_cancel()
	hud.set_objective("")
	var cp := level.chain_point()
	var mid := level.swim_start().lerp(cp, 0.55)
	player.global_position = _water(level.swim_start().lerp(cp, 0.45))
	var far := level.swim_start().lerp(cp, 0.75)
	level.boat.global_position = Vector3(far.x + 6, level.water_y, far.z + 2)
	level.boat.look_at(Vector3(far.x - 20, level.water_y, far.z), Vector3.UP)
	player.face(level.boat.global_position + Vector3(0, 0.3, 0))
	hud.bark("SPK_ROWER", "D2_R_21", 30.0)
	hud.set_qte(tr("UI_QTE_DIVE"))
	await _shot("c2_05_kayik.png")

	# 6. Bütçe haritası
	hud.set_qte("")
	var m := BudgetMap.new()
	m.title = tr("UI_BUDGET_TITLE")
	m.from_label = tr("UI_BUDGET_FROM")
	m.to_label = tr("UI_BUDGET_TO")
	m.progress = 1.0
	hud.add_child(m)
	hud.bark("SPK_HIKMET", "D2_H_17", 30.0)
	await _shot("c2_06_butce.png")
	m.queue_free()

	# 7. Akış şeması
	_outcome = "2.3"
	hits = 1
	GameState.seen_outcomes = {"2.1": true}
	var chart := _make_chart()
	hud.add_child(chart)
	await _shot("c2_07_akis.png")
	get_tree().quit()

