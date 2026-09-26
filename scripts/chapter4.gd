extends Node3D
## Bölüm 4 — İlk Gece (Tolga · 22 Nisan 1453, gece). CHAPTERS Bölüm 4, GDD §9.3–9.4.
##
## Bölüm 2'nin sonucuna göre iki yol:
##   4a · Ordugâh (2.1, 2.4: esir çadırından; 2.2: pazar tezgâhının altından başlar).
##        Çıkıştaki Hasan ile Hüseyin arada bir "kim kim" tartışmasına dalar. Tartışırken
##        siperden sipere geçip çık (4a.1), yakalanınca bir eşyayla atlat (☕ 🧊 📦 → 4a.2),
##        iki kez yakalanırsan bulaşığa verilirsin (4a.3).
##   4b · Deniz surları (2.3: zincirden). Kütüklerde denge, surdan Niko'nun fırlattığı
##        tavuk/çuval/kalkanlardan kaç, dördüncü tavuk peşine takılır (Sinerji). Kapıda fes
##        kararı: fesli "Türk casusu" (4b.1), fessiz "Frenk tüccarı" (4b.2); denizde
##        düşersen sabahı hücrede beklersin (4b.3).
## Sonunda Perde I kapanışı: tepede Nihat belirir, daktilosuna "Anomali tespit edildi." yazar.
##   --autotest[=item|caught|market|chain|nofez|fall]

const WATCH_TIME := 5.5
const ARGUE_TIME := 4.2
const VIEW_RANGE := 8.5
const VIEW_ANGLE := 50.0
const WORKING_ITEMS := ["thermos", "cube", "tape"]
const CALMING_ITEMS := ["chickpeas", "cologne"]
## Nöbetçilerin eşya tepkileri (ITEM_REACTIONS §2).
const GUARD_REACTIONS := {
	"phone": [["SPK_HASAN", "D4A_ITEM_PHONE_1"], ["SPK_HUSEYIN", "D4A_ITEM_PHONE_2"], ["SPK_HASAN", "D4A_ITEM_PHONE_3"]],
	"lighter": [["SPK_HASAN", "D4A_ITEM_LIGHTER_1"], ["SPK_HUSEYIN", "D4A_ITEM_LIGHTER_2"]],
	"book": [["SPK_HASAN", "D4A_ITEM_BOOK_1"], ["SPK_HUSEYIN", "D4A_ITEM_BOOK_2"], ["SPK_HASAN", "D4A_ITEM_BOOK_3"], ["SPK_HUSEYIN", "D4A_ITEM_BOOK_4"]],
	"chickpeas": [["SPK_HASAN", "D4A_ITEM_CHICKPEAS_1"], ["SPK_HUSEYIN", "D4A_ITEM_CHICKPEAS_2"]],
	"powerbank": [["SPK_HASAN", "D4A_ITEM_POWERBANK_1"], ["SPK_HUSEYIN", "D4A_ITEM_POWERBANK_2"], ["SPK_HASAN", "D4A_ITEM_POWERBANK_3"]],
	"tape": [["SPK_HUSEYIN", "D4A_ITEM_TAPE_1"], ["SPK_TOLGA", "D4A_ITEM_TAPE_2"], ["SPK_HASAN", "D4A_ITEM_TAPE_3"]],
	"thermos": [["SPK_GUARDS", "D4A_ITEM_THERMOS_1"], ["SPK_GUARDS", "D4A_ITEM_THERMOS_2"]],
	"selfie": [["SPK_HASAN", "D4A_ITEM_SELFIE_1"], ["SPK_HUSEYIN", "D4A_ITEM_SELFIE_2"], ["SPK_HASAN", "D4A_ITEM_SELFIE_3"]],
	"cologne": [["SPK_HASAN", "D4A_ITEM_COLOGNE_1"], ["SPK_HUSEYIN", "D4A_ITEM_COLOGNE_2"]],
	"cube": [["SPK_HASAN", "D4A_ITEM_CUBE_1"], ["SPK_HUSEYIN", "D4A_ITEM_CUBE_2"], ["SPK_HASAN", "D4A_ITEM_CUBE_3"]],
}
const ITEM_EMOJI_KEY := {"phone": "PHONE", "lighter": "LIGHTER", "book": "BOOK", "chickpeas": "CHICKPEAS",
	"powerbank": "POWERBANK", "tape": "TAPE", "thermos": "THERMOS", "selfie": "SELFIE", "cologne": "COLOGNE", "cube": "CUBE"}

var camp: Camp
var walls: SeaWalls
var player: Player
var hud: Hud
var branch := "4a"
var start := "tent"         # tent, market, chain
var phase := "intro"
var _outcome := ""
var catches := 0
var hits := 0
var _guard_t := 0.0
var _arguing := false
var _argue_idx := 0
var _busy := false
var _tilt := 0.0
var _tilt_v := 0.0
var _chain_s := 0.0
var _throw_t := 0.0
var _throws := 0
var _chickens := 0
var sinerji: Chicken
var _vista_lights: Array = []


func _ready() -> void:
	GameState.snapshot(4)
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
	var ch2: String = GameState.chapter_outcomes.get(2, "2.1")
	var v := GameState.autotest_variant
	if v in ["chain", "nofez", "fall"]:
		ch2 = "2.3"
	elif v == "market":
		ch2 = "2.2"
	branch = "4b" if ch2 == "2.3" else "4a"
	set_meta("music", "walls_night" if branch == "4b" else "stealth")
	start = "chain" if branch == "4b" else ("market" if ch2 == "2.2" else "tent")
	if branch == "4a":
		camp = Camp.new()
		add_child(camp)
	else:
		walls = SeaWalls.new()
		add_child(walls)
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _process(delta: float) -> void:
	if hud == null:
		return
	hud.fez.motion = player.horizontal_speed() * 0.6
	if phase not in ["done", "gate", "vista"] and Input.is_action_just_pressed("fez"):
		var on: bool = not GameState.flags.get("fez", true)
		GameState.flags["fez"] = on
		hud.set_fez(on)
	if phase not in ["done", "vista", "intro"] and Input.is_action_just_pressed("red_button"):
		_red_after_warranty()
	match phase:
		"sneak":
			_sneak_step(delta)
		"balance":
			_balance_step(delta)
		"quay":
			_quay_step(delta)
	if phase == "vista":
		Night.flicker(_vista_lights, Time.get_ticks_msec() / 1000.0)


## Garanti bittikten sonra kırmızı düğme: sadece cızırdar, ama Hikmet'e sinyal gider (bir kez).
func _red_after_warranty() -> void:
	player.press_red(1.0)
	get_tree().create_timer(0.3).timeout.connect(func(): player.press_red(0.0))
	if GameState.flags.get("red_after_warranty", false):
		hud.bark("SPK_HIKMET", "D4_H_RED_AGAIN", 3.0)
		return
	GameState.flags["red_after_warranty"] = true
	GameState.telsiz_bag = mini(5, GameState.telsiz_bag + 1)
	hud.set_signal(GameState.telsiz_bag)
	hud.bark("SPK_HIKMET", "D4_H_RED", 3.5)


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	var sub := "UI_CH4_SUB_4B" if branch == "4b" else "UI_CH4_SUB_4A"
	hud.cover_override = "ch4b" if branch == "4b" else "ch4a"
	await hud.card([[tr("UI_CH4_TITLE"), 44, Color("f2e6c9")], [tr(sub), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	if branch == "4a":
		await _run_4a()
	else:
		await _run_4b()
	await _act_end()
	await _end_chapter()


# ---------------------------------------------------------------- 4a · ordugâh

func _spawn_4a() -> void:
	var p := Camp.TENT_SPAWN if start == "tent" else Camp.MARKET_SPAWN
	player.global_position = p
	player.velocity = Vector3.ZERO
	player.face(Vector3(0, 1.4, Camp.GATE_Z))


func _run_4a() -> void:
	_spawn_4a()
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	if start == "tent":
		await _t("D4A_T_01")
	else:
		await _t("D4A_T_01M")
	await _h("D4A_H_02")
	await _t("D4A_T_03")
	await _t("D4A_T_04")
	_guard_t = WATCH_TIME - 1.0
	hud.set_objective(tr("UI_OBJ4A_ESCAPE"), Vector3(0, 1.2, Camp.ESCAPE_Z))
	_flash_prompt(tr("UI_HINT4A"), 7.0)
	player.frozen = false
	phase = "sneak"
	if GameState.autotest and GameState.autotest_variant in ["item", "caught"]:
		_confront()
	while _outcome == "":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame


func _sneak_step(delta: float) -> void:
	if _busy or _outcome != "":
		return
	_guard_t += delta
	if not _arguing and _guard_t > WATCH_TIME:
		_guard_t = 0.0
		_set_arguing(true)
	elif _arguing and _guard_t > ARGUE_TIME:
		_guard_t = 0.0
		_set_arguing(false)
	if GameState.autotest and _arguing and GameState.autotest_variant in ["", "market", "next"]:
		player.global_position = Vector3(0, 0.05, Camp.ESCAPE_Z + 1.0)
	# Kaçış
	if player.global_position.z > Camp.ESCAPE_Z:
		_escaped_4a()
		return
	# Görüldü mü?
	for g in [camp.hasan, camp.huseyin]:
		if _sees(g):
			_confront()
			return


func _set_arguing(on: bool) -> void:
	_arguing = on
	var tw := create_tween().set_parallel()
	if on:
		tw.tween_property(camp.hasan, "rotation:y", PI / 2.0, 0.35)
		tw.tween_property(camp.huseyin, "rotation:y", -PI / 2.0, 0.35)
		camp.hasan.pose = "point"
		var lines := [["SPK_HASAN", "D4A_HA_ARGUE_1"], ["SPK_HUSEYIN", "D4A_HU_ARGUE_2"], ["SPK_HASAN", "D4A_HA_ARGUE_3"],
			["SPK_HUSEYIN", "D4A_HU_ARGUE_4"], ["SPK_HASAN", "D4A_HA_ARGUE_5"], ["SPK_HUSEYIN", "D4A_HU_ARGUE_6"]]
		var l: Array = lines[_argue_idx % lines.size()]
		_argue_idx += 1
		hud.bark(l[0], l[1], ARGUE_TIME - 0.3)
	else:
		tw.tween_property(camp.hasan, "rotation:y", PI, 0.35)
		tw.tween_property(camp.huseyin, "rotation:y", PI, 0.35)
		camp.hasan.pose = "stand"


## Nöbetçi oyuncuyu görüyor mu: menzil, bakış açısı ve görüş hattı (sandıklar keser).
func _sees(g: Soldier) -> bool:
	var to := player.global_position - g.global_position
	to.y = 0.0
	var d := to.length()
	if d < 1.4:
		return true
	if _arguing or d > VIEW_RANGE:
		return false
	var fwd := g.global_transform.basis.z
	fwd.y = 0.0
	if rad_to_deg(fwd.normalized().angle_to(to.normalized())) > VIEW_ANGLE:
		return false
	var q := PhysicsRayQueryParameters3D.create(g.global_position + Vector3(0, 1.6, 0), player.global_position + Vector3(0, 1.3, 0), 1)
	q.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	return hit.is_empty()


## Nöbetçilerle yüzleşme: yakalandın ya da kendin yanlarına gittin. Çantadan bir eşya göster.
func _confront() -> void:
	if _busy or _outcome != "":
		return
	_busy = true
	player.frozen = true
	_set_arguing(false)
	var mid := (camp.hasan.global_position + camp.huseyin.global_position) / 2.0
	player.face(mid + Vector3(0, 1.4, 0))
	var fez_on: bool = GameState.flags.get("fez", true)
	await _say("SPK_HASAN", "D4A_HA_STOP" if fez_on else "D4A_HA_STOP_NOFEZ")
	await _say("SPK_HUSEYIN", "D4A_HU_STOP")
	var keys: Array = []
	for id in GameState.bag:
		keys.append(Items.name_key(id))
	keys.append("UI_CH4A_BLUFF")
	var pick := keys.size() - 1
	if GameState.autotest and GameState.autotest_variant == "item":
		for i in GameState.bag.size():
			if GameState.bag[i] in WORKING_ITEMS:
				pick = i
				break
	var c := await hud.choose(keys, 0.0, pick)
	var item := GameState.bag[c] if c >= 0 and c < GameState.bag.size() else ""
	if item != "":
		await _guard_reaction(item)
	if item in WORKING_ITEMS:
		GameState.flags["guards_" + {"thermos": "break", "cube": "distracted", "tape": "taped"}[item]] = true
		_outcome = "4a.2"
		GameState.flags["guards_like_tolga"] = true
		await _guards_defeated(item)
		_busy = false
		return
	if item in CALMING_ITEMS:
		await _say("SPK_HUSEYIN", "D4A_HU_GO_BACK")
		await _back_to_start(false)
		_busy = false
		return
	if item == "":
		await _t("D4A_T_BLUFF")
		await _say("SPK_HASAN", "D4A_HA_BLUFF")
	catches += 1
	if catches >= 2:
		_outcome = "4a.3"
		await _dishes()
		_busy = false
		return
	await _say("SPK_HUSEYIN", "D4A_HU_CAUGHT")
	await _back_to_start(true)
	_busy = false
	if GameState.autotest and GameState.autotest_variant == "caught":
		_confront.call_deferred()


func _guard_reaction(item: String) -> void:
	for line in GUARD_REACTIONS[item]:
		await _say(line[0], line[1])


func _guards_defeated(item: String) -> void:
	var tw := create_tween().set_parallel()
	if item == "thermos":
		# Mangalın başına oturup mola verirler
		tw.tween_property(camp.hasan, "position", Vector3(-0.8, 0, Camp.GATE_Z + 2.9), 1.0)
		tw.tween_property(camp.huseyin, "position", Vector3(0.8, 0, Camp.GATE_Z + 2.9), 1.0)
		tw.tween_property(camp.hasan, "rotation:y", PI * 0.75, 1.0)
		tw.tween_property(camp.huseyin, "rotation:y", -PI * 0.75, 1.0)
	elif item == "tape":
		# Sırt sırta bantlanırlar
		tw.tween_property(camp.hasan, "position", Vector3(-0.22, 0, Camp.GATE_Z + 0.8), 0.6)
		tw.tween_property(camp.huseyin, "position", Vector3(0.22, 0, Camp.GATE_Z + 0.8), 0.6)
		tw.tween_property(camp.hasan, "rotation:y", -PI / 2.0, 0.6)
		tw.tween_property(camp.huseyin, "rotation:y", PI / 2.0, 0.6)
	else:
		tw.tween_property(camp.hasan, "rotation:y", PI / 2.0, 0.5)
		tw.tween_property(camp.huseyin, "rotation:y", -PI / 2.0, 0.5)
	await tw.finished
	if item == "tape":
		Props.cyl(camp, 0.33, 0.12, Vector3(0, 1.05, Camp.GATE_Z + 0.8), Garage.C_TAPE, Vector3.ZERO, 10)
	await _t("D4A_T_WIN_" + ITEM_EMOJI_KEY[item])
	var walk := create_tween()
	player.face(Vector3(0, 1.5, Camp.ESCAPE_Z + 6.0))
	walk.tween_property(player, "global_position", Vector3(1.6, 0.05, Camp.ESCAPE_Z + 1.5), 2.2 if not GameState.autotest else 0.2)
	await walk.finished
	await _escape_lines()


func _back_to_start(caught: bool) -> void:
	await hud.fade_to(1.0, 0.5)
	_spawn_4a()
	_guard_t = 0.0
	_arguing = false
	camp.hasan.rotation.y = PI
	camp.huseyin.rotation.y = PI
	await hud.fade_to(0.0, 0.5)
	if caught:
		await _t("D4A_T_AGAIN")
	player.frozen = false


func _escaped_4a() -> void:
	if _busy:
		return
	_busy = true
	_outcome = "4a.1"
	player.frozen = true
	player.face(Vector3(0, 1.5, Camp.GATE_Z))
	await _say("SPK_HASAN", "D4A_HA_END")
	await _say("SPK_HUSEYIN", "D4A_HU_END")
	await _t("D4A_T_END1")
	await _escape_lines()
	_busy = false


func _escape_lines() -> void:
	hud.set_objective("")
	player.face(Vector3(3.2, 2.0, Camp.GATE_Z + 7.0))
	await _t("D4A_T_OTAG")


## 4a.3: Aşçıbaşı Kadri'nin bulaşık dağı.
func _dishes() -> void:
	await hud.fade_to(1.0, 0.8)
	hud.set_objective("")
	await hud.card([[tr("UI_CH4A_DISHES"), 30, Color("f2e6c9")]], 1.6)
	hud.clear_card()
	# Bulaşık dağı: kazanlar ve tencereler
	var pile := Node3D.new()
	pile.position = Vector3(-6.5, 0, -8.0)
	camp.add_child(pile)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 26:
		var y := float(i / 6) * 0.35
		var p := Vector3(rng.randf_range(-0.9, 0.9) * (1.0 - y * 0.25), 0.2 + y, rng.randf_range(-0.6, 0.6))
		Props.cyl(pile, rng.randf_range(0.18, 0.34), rng.randf_range(0.16, 0.3), p, [Color("8a8a8e"), Color("b87a3a"), Color("6a6a70")][i % 3], Vector3(rng.randf_range(-20, 20), 0, rng.randf_range(-20, 20)), 8)
	player.global_position = Vector3(-6.5, 0.05, -5.8)
	player.face(Vector3(-6.5, 0.8, -8.0))
	await hud.fade_to(0.0, 0.6)
	await _say("SPK_KADRI", "D4A_K_DISHES")
	await _t("D4A_T_DISHES")
	await _say("SPK_KADRI", "D4A_K_DISHES2")


# ---------------------------------------------------------------- 4b · deniz surları

func _run_4b() -> void:
	player.move_mode = "script"
	player.gravity_on = false
	player.global_position = SeaWalls.CHAIN_START + Vector3(0, 0.25, 0)
	player.face(SeaWalls.CHAIN_END + Vector3(0, 1.6, 0))
	walls.niko.look_target = player
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _t("D4B_T_01")
	await _h("D4B_H_02")
	if "selfie" in GameState.bag:
		await _t("D4B_T_SELFIE")
	hud.set_objective(tr("UI_OBJ4B_CHAIN"))
	_flash_prompt(tr("UI_HINT4B"), 5.0)
	var meter := BalanceMeter.new()
	meter.label_text = tr("UI_BALANCE")
	meter.name = "Balance"
	hud.add_child(meter)
	var vp := get_viewport().get_visible_rect().size
	meter.position = Vector2((vp.x - meter.size.x) / 2.0, vp.y * 0.12)
	phase = "balance"
	while phase == "balance":
		await get_tree().process_frame
	meter.queue_free()
	if _outcome == "4b.3":
		await _fell()
		return
	# Rıhtım: Niko'nun fırlattıklarından kaç
	player.move_mode = "walk"
	player.gravity_on = true
	player.global_position = Vector3(0.6, SeaWalls.QUAY_Y + 0.05, -0.9)
	player.camera.rotation.z = 0.0
	player.face(Vector3(SeaWalls.GATE_X, 1.8, -1.5))
	await _say("SPK_NIKO", "D4B_N_03" if GameState.flags.get("fez", true) else "D4B_N_03_NOFEZ")
	hud.set_objective(tr("UI_OBJ4B_GATE"), Vector3(SeaWalls.GATE_X, SeaWalls.QUAY_Y + 1.4, SeaWalls.WALL_Z + 0.5))
	player.frozen = false
	_throw_t = 0.6
	phase = "quay"
	while phase == "quay":
		await get_tree().process_frame
	if _outcome == "4b.3":
		await _fell()
		return
	await _gate()


func _balance_step(delta: float) -> void:
	if _busy:
		return
	var total := SeaWalls.CHAIN_START.distance_to(SeaWalls.CHAIN_END)
	_chain_s += delta * 1.8
	var t := Time.get_ticks_msec() / 1000.0
	var noise := sin(t * 1.3) * 0.9 + sin(t * 2.9 + 1.0) * 0.6 + sin(t * 0.7 + 2.0) * 0.5
	if "selfie" in GameState.bag:
		noise *= 0.55
	var input := Input.get_axis("move_left", "move_right")
	if GameState.autotest:
		input = 0.0 if GameState.autotest_variant == "fall" else -clampf(_tilt * 3.0 + _tilt_v, -1.0, 1.0)
	# D ibreyi sağa, A sola iter: sola kayan ibreyi D ile ortaya getir
	_tilt_v += (noise * 0.9 + _tilt * 1.1 + input * 2.6) * delta
	_tilt_v *= 0.97
	_tilt += _tilt_v * delta
	if GameState.autotest and GameState.autotest_variant == "fall":
		_tilt += delta * 0.8
	var m := hud.get_node_or_null("Balance") as BalanceMeter
	if m:
		m.value = _tilt
	var p := SeaWalls.CHAIN_START.lerp(SeaWalls.CHAIN_END, clampf(_chain_s / total, 0.0, 1.0))
	player.global_position = p + Vector3(_tilt * 0.3, 0.25 + absf(sin(_chain_s * 2.2)) * 0.04, 0)
	player.camera.rotation.z = -_tilt * 0.35
	if absf(_tilt) >= 1.0:
		_outcome = "4b.3"
		GameState.flags["fell_chain"] = true
		phase = "fallen"
		return
	if _chain_s >= total:
		phase = "walked"
	# Niko lafı
	var progress := _chain_s / total
	if progress > 0.15 and not GameState.flags.has("_n1"):
		GameState.flags["_n1"] = true
		hud.bark("SPK_NIKO", "D4B_N_01" if GameState.flags.get("fez", true) else "D4B_N_01_NOFEZ", 3.5)
	elif progress > 0.55 and not GameState.flags.has("_n2"):
		GameState.flags["_n2"] = true
		hud.bark("SPK_NIKO", "D4B_N_02", 3.5)


func _quay_step(delta: float) -> void:
	if _busy:
		return
	var px := player.global_position.x
	# Niko surun tepesinde oyuncuyla birlikte yürür
	var n := walls.niko
	n.position.x = lerpf(n.position.x, px + 3.0, clampf(delta * 1.5, 0.0, 1.0))
	if GameState.autotest:
		player.global_position = Vector3(SeaWalls.GATE_X - 1.0, SeaWalls.QUAY_Y + 0.05, -1.2)
	if px > SeaWalls.GATE_X - 1.8:
		phase = "gate_reached"
		return
	if player.global_position.y < SeaWalls.QUAY_Y - 0.6:
		_outcome = "4b.3"
		GameState.flags["fell_quay"] = true
		phase = "fallen"
		return
	_throw_t -= delta
	if _throw_t <= 0.0:
		_throw_t = 1.8
		_throw()


## Niko bir şey fırlatır: yere düşeceği yer 1.1 sn önceden kırmızı halkayla belli olur.
func _throw() -> void:
	_throws += 1
	var kinds := ["chicken", "sack", "chicken", "shield", "chicken", "sack", "chicken", "shield", "sack"]
	var kind: String = kinds[(_throws - 1) % kinds.size()]
	if kind == "chicken" and _chickens >= 4:
		kind = "sack"
	var lead := player.velocity * 0.9
	lead.y = 0.0
	var target := player.global_position + lead
	target.x = clampf(target.x, -3.0, SeaWalls.GATE_X + 1.0)
	target.z = clampf(target.z, SeaWalls.WALL_Z + 0.5, -0.4)
	target.y = SeaWalls.QUAY_Y + 0.02
	var marker := Props.ring(walls, 0.45, 0.6, target + Vector3(0, 0.02, 0), Color("ff3b30"), Vector3.ZERO, 2.0)
	marker.material_override = Props.mat(Color("ff3b30"), 2.0, false, "", false)
	var from := walls.niko.global_position + Vector3(0.3, 1.8, 0.4)
	var obj: Node3D
	match kind:
		"chicken":
			_chickens += 1
			var c := Chicken.new()
			c.flapping = true
			obj = c
			hud.bark("SPK_NIKO", "D4B_N_THROW_CHICKEN_%d" % mini(_chickens, 4), 1.6)
		"sack":
			obj = Node3D.new()
			Props.ball(obj, 0.32, Vector3(0, 0.25, 0), Color("b89a6a"), Vector3(1, 0.8, 1), 7)
			Props.cyl(obj, 0.08, 0.14, Vector3(0, 0.55, 0), Color("8a6a44"), Vector3.ZERO, 6)
			hud.bark("SPK_NIKO", "D4B_N_THROW_SACK", 1.6)
		_:
			obj = Node3D.new()
			Props.cyl(obj, 0.45, 0.06, Vector3(0, 0.1, 0), Color("8a2b22"), Vector3(12, 0, 0), 12)
			Props.ball(obj, 0.09, Vector3(0, 0.15, 0), Color("c49a45"), Vector3.ONE, 6)
			hud.bark("SPK_NIKO", "D4B_N_THROW_SHIELD", 1.6)
	walls.add_child(obj)
	obj.global_position = from
	var dur := 1.1 if not GameState.autotest else 0.1
	var tw := create_tween()
	tw.tween_method(func(f: float):
		var p := from.lerp(target, f)
		p.y += sin(f * PI) * 2.5
		obj.global_position = p
		obj.rotation.x = f * 6.0 if kind != "chicken" else 0.0, 0.0, 1.0, dur)
	await tw.finished
	marker.queue_free()
	if phase != "quay":
		obj.queue_free()
		return
	var d := Vector2(player.global_position.x - target.x, player.global_position.z - target.z).length()
	if d < 0.95:
		hits += 1
		player.shake(1.0)
		hud.bark("SPK_TOLGA", "D4B_T_HIT_%d" % mini(hits, 3), 1.8)
		if hits >= 3:
			# Üçüncü darbe: rıhtımdan denize
			_busy = true
			var fall := create_tween()
			fall.tween_property(player, "global_position", player.global_position + Vector3(0, -1.8, 1.8), 0.6)
			await fall.finished
			_busy = false
			_outcome = "4b.3"
			GameState.flags["fell_quay"] = true
			phase = "fallen"
	if kind == "chicken":
		var c := obj as Chicken
		c.flapping = false
		c.rotation.y = randf() * TAU
		if _chickens >= 4 and sinerji == null:
			# Dördüncü tavuk geri dönmez: Tolga'nın peşine takılır
			sinerji = c
			sinerji.follow = player
			GameState.flags["sinerji"] = true
			hud.bark("SPK_TOLGA", "D4B_T_SINERJI", 3.5)
		else:
			var back := create_tween()
			back.tween_property(c, "global_position", Vector3(target.x + 1.0, target.y, SeaWalls.WALL_Z + 0.3), 0.8)
			back.tween_callback(c.queue_free)
	else:
		var fade := create_tween()
		fade.tween_interval(1.5)
		fade.tween_callback(obj.queue_free)


func _gate() -> void:
	phase = "gate"
	player.frozen = true
	hud.set_objective("")
	var n := walls.niko
	n.position = Vector3(SeaWalls.GATE_X, SeaWalls.QUAY_Y, SeaWalls.WALL_Z + 0.5)
	player.face(n.global_position + Vector3(0, 1.4, 0))
	await _eclipse()
	await _say("SPK_NIKO", "D4B_N_GATE")
	if GameState.flags.get("sinerji", false):
		await _say("SPK_NIKO", "D4B_N_CHICKEN")
	# Eşya göster (isteğe bağlı)
	var keys: Array = []
	for id in GameState.bag:
		keys.append(Items.name_key(id))
	keys.append("UI_CH4_NOTHING")
	var c := await hud.choose(keys, 0.0, keys.size() - 1)
	if c >= 0 and c < GameState.bag.size():
		var item: String = GameState.bag[c]
		await _say("SPK_NIKO", "D4B_NIKO_" + ITEM_EMOJI_KEY[item])
		if item == "chickpeas":
			GameState.flags["niko_friend"] = true
	# ⏱ Fes kararı Niko'nun önünde
	await _say("SPK_NIKO", "D4B_N_HAT")
	var fez_pick := 1 if GameState.autotest_variant == "nofez" else 0
	var f := await hud.choose(["UI_CH4B_FEZ_ON", "UI_CH4B_FEZ_OFF"], 6.0, fez_pick)
	if f == 1:
		GameState.flags["fez"] = false
		hud.set_fez(false)
	elif f == 0:
		GameState.flags["fez"] = true
		hud.set_fez(true)
	if GameState.flags.get("fez", true):
		_outcome = "4b.1"
		await _say("SPK_NIKO", "D4B_N_SPY")
		await _t("D4B_T_SPY")
		await _say("SPK_NIKO", "D4B_N_SPY2")
	else:
		_outcome = "4b.2"
		await _say("SPK_NIKO", "D4B_N_MERCHANT")
		await _t("D4B_T_MERCHANT")
		await _say("SPK_NIKO", "D4B_N_MERCHANT2")
	# Niko kapıyı açar
	await walls.open_gate(0.05 if GameState.autotest else 1.2)


## 4b.3: denize düştü; Bizans nöbetçileri çıkardı, sabahı hücrede bekler.
## Ay tutulması (tarihte 22 Mayıs 1453; burada tam bir ay erken: Tolga'nın paradoksu).
## Bizanslılar ay küçülürken şehrin düşeceğine inanıyordu; Niko alamet görür. Tolga'nın telefon ışığı
## "ikinci alamet" sanılır (tarihte Ayasofya'nın kubbesinde görülen gizemli ışık).
func _eclipse() -> void:
	var moon: SkyBody = null
	for c in walls.get_children():
		if c is SkyBody and (c as SkyBody).is_moon and not c.is_queued_for_deletion():
			moon = c
	if moon == null or GameState.autotest:
		GameState.flags["eclipse_seen"] = true
		return
	player.face(moon.global_position)
	var t0 := Time.get_ticks_msec()
	moon.eclipse(true, 5.0)
	await _say("SPK_NIKO", "D4B_N_ECLIPSE_1")
	# Tutulmanın bitmesini süreyle bekle: ay nesnesi silinirse animasyonun "bitti" sinyali hiç gelmez (oyun kilitleniyordu)
	var left := 5.0 - (Time.get_ticks_msec() - t0) / 1000.0
	if left > 0.0:
		await _wait(left)
	await _t("D4B_T_ECLIPSE_1")
	await _say("SPK_NIKO", "D4B_N_ECLIPSE_2")
	# Telefon feneri: kısa, beyaz bir ışık
	var flash := OmniLight3D.new()
	flash.light_color = Color("e8f0ff")
	flash.light_energy = 3.0
	flash.omni_range = 7.0
	player.add_child(flash)
	flash.position = Vector3(0.3, 1.5, -0.6)
	await _t("D4B_T_ECLIPSE_2")
	await _say("SPK_NIKO", "D4B_N_ECLIPSE_3")
	flash.queue_free()
	await _t("D4B_T_ECLIPSE_3")
	GameState.flags["eclipse_seen"] = true
	GameState.paradox += 5
	if is_instance_valid(moon):
		moon.eclipse(false, 8.0)
	player.face(walls.niko.global_position + Vector3(0, 1.4, 0))


func _fell() -> void:
	player.shake(1.5)
	hud.set_underwater(true)
	await _wait(0.6)
	await hud.fade_to(1.0, 0.6)
	hud.set_underwater(false)
	hud.set_objective("")
	await hud.card([[tr("UI_CH4B_CELL"), 30, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	# Hücre: taş duvarlar, parmaklık, saman
	Audio.voice_space("room")
	var cell := Node3D.new()
	cell.position = Vector3(40, 0, -40)
	walls.add_child(cell)
	Props.solid(cell, Vector3(4, 0.2, 4), Vector3(0, -0.1, 0), Color("5a5a5e"))
	for w in [[Vector3(4, 3, 0.2), Vector3(0, 1.5, -2)], [Vector3(0.2, 3, 4), Vector3(-2, 1.5, 0)], [Vector3(0.2, 3, 4), Vector3(2, 1.5, 0)]]:
		Props.set_pattern(Props.solid(cell, w[0], w[1], Color("6d6a64")), Color("6d6a64"), "wall")
	for i in 9:
		Props.cyl(cell, 0.04, 2.8, Vector3(-1.8 + i * 0.45, 1.4, 2.0), Color("3a3a3e"), Vector3.ZERO, 5)
	Props.box(cell, Vector3(1.4, 0.2, 0.8), Vector3(-1.1, 0.1, -1.4), Color("c8a860"))
	var l := OmniLight3D.new()
	l.position = Vector3(0, 2.4, 2.8)
	l.light_color = Color("ff9a40")
	l.light_energy = 1.4
	cell.add_child(l)
	walls.niko.position = cell.position + Vector3(0.4, 0, 2.8)
	walls.niko.look_target = player
	player.move_mode = "walk"
	player.gravity_on = true
	player.global_position = cell.position + Vector3(0, 0.05, -0.6)
	player.face(walls.niko.global_position + Vector3(0, 1.4, 0))
	player.camera.rotation.z = 0.0
	GameState.flags["wet"] = true
	await hud.fade_to(0.0, 0.6)
	await _say("SPK_NIKO", "D4B_N_CELL")
	await _t("D4B_T_CELL")
	await _say("SPK_NIKO", "D4B_N_CELL2")


# ---------------------------------------------------------------- Perde I kapanışı

## Kamera gece gökyüzüne kalkar, bir ışık çakar, tepede Nihat belirir ve daktilosuna yazar.
func _act_end() -> void:
	phase = "vista"
	player.frozen = true
	hud.set_objective("")
	await hud.fade_to(1.0, 1.0)
	if camp:
		camp.queue_free()
		camp = null
	if walls:
		walls.queue_free()
		walls = null
	if sinerji:
		sinerji = null
	hud.set_fez(false)
	hud.set_cinematic(true)
	player.show_remote(false)
	# Kapanış arazisinin çarpışması yok: kamera havada, yerçekimi kapalı
	player.gravity_on = false
	player.move_mode = "walk"
	player.velocity = Vector3.ZERO
	player.camera.rotation.z = 0.0
	var vista := Node3D.new()
	add_child(vista)
	Night.environment(vista, 0.008)
	var hf := func(x: float, z: float) -> float:
		var hill := maxf(0.0, 6.0 - Vector2(x, z + 4.0).length() * 0.55)
		return hill + sin(x * 0.08) * 1.2 + cos(z * 0.06) * 1.0 - 1.0
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		return Color("1e2a1a").lerp(Color("2c3a24"), clampf(y / 6.0, 0.0, 1.0))
	vista.add_child(LowPoly.terrain(-120.0, 120.0, -160.0, 60.0, 40, 36, hf, cf))
	# Uzakta kamp ateşi ve kırmızı bir fes
	var far := Vector3(22.0, hf.call(22.0, -46.0), -46.0)
	_vista_lights.append(Night.campfire(vista, far, 2.4))
	Props.cyl(vista, 0.35, 0.45, far + Vector3(1.8, 1.3, 0.4), Color("c8262f"), Vector3.ZERO, 8, 0.28)
	for i in 12:
		Night.tent(vista, Vector3(-60 + i * 11.0, 0, -95 - (i % 3) * 8.0), 2.2)
	# Tepede Nihat
	var top := Vector3(0, hf.call(0.0, -4.0), -4.0)
	var nihat := Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true, "hair": Color("3a2a1e"), "skin": Color("ecb892")})
	nihat.position = top
	vista.add_child(nihat)
	var tw_box := Node3D.new()
	tw_box.position = Vector3(0, 1.0, 0.35)
	nihat.add_child(tw_box)
	Props.box(tw_box, Vector3(0.42, 0.14, 0.32), Vector3.ZERO, Color("1f2426"))
	Props.box(tw_box, Vector3(0.28, 0.2, 0.01), Vector3(0, 0.16, -0.12), Color("efe9d8"), Vector3(-10, 0, 0))
	nihat.visible = false
	nihat.rotation.y = atan2(far.x - top.x, far.z - top.z)
	# Nihat'ı ay ışığı gibi soğuk bir ışık ve arkadan sıcak bir kenar ışığı aydınlatır
	var key := OmniLight3D.new()
	key.position = top + Vector3(-2.0, 3.0, 3.0)
	key.light_color = Color("b8c8ff")
	key.light_energy = 2.2
	key.omni_range = 9.0
	vista.add_child(key)
	var rim := OmniLight3D.new()
	rim.position = top + Vector3(1.5, 2.2, -2.5)
	rim.light_color = Color("ffb070")
	rim.light_energy = 1.6
	rim.omni_range = 6.0
	vista.add_child(rim)
	# Kamera: aşağıdan gökyüzüne
	player.global_position = top + Vector3(-3.5, -1.2, 7.0)
	player.face(top + Vector3(0, 8.0, -10.0))
	if GameState.shots_dir != "":
		nihat.visible = true
		player.global_position = top + Vector3(-3.4, -0.5, 1.4)
		player.face(top + Vector3(1.4, 1.0, -1.6))
		hud.set_fade(0.0)
		hud._sub_box.visible = false
		return
	await hud.fade_to(0.0, 1.2)
	await _wait(1.6)
	# Işık çakar
	await hud.fade_to(1.0, 0.15, Color.WHITE)
	nihat.visible = true
	player.global_position = top + Vector3(-3.4, -0.5, 1.4)
	player.face(top + Vector3(0.4, 1.2, 0))
	await hud.fade_to(0.0, 0.5, Color.WHITE)
	await _wait(1.0)
	# Nihat uzaktaki fese bakar ve yazar
	var look := create_tween()
	look.tween_method(func(f: float): player.face((top + Vector3(0.4, 1.2, 0)).lerp(top + Vector3(1.4, 1.0, -1.6), f)), 0.0, 1.0, 1.6)
	await look.finished
	await hud.typewriter(tr("UI_ACT1_TYPED"))
	await _wait(1.2)
	await hud.fade_to(1.0, 1.0)
	await hud.card([[tr("UI_ACT1_END"), 40, Color("f2e6c9")], [tr("UI_ACT1_END_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	GameState.flags["act1_done"] = true


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	GameState.set_outcome(4, _outcome)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=4 -> 5 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter5.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter5.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW4_TITLE")
	c.nodes = [
		{"id": "4a", "key": "FLOW4_4A", "pos": Vector2(0.28, 0.17)},
		{"id": "4b", "key": "FLOW4_4B", "pos": Vector2(0.72, 0.17)},
		{"id": "sneak", "key": "FLOW4_SNEAK", "pos": Vector2(0.16, 0.3)},
		{"id": "confront", "key": "FLOW4_CONFRONT", "pos": Vector2(0.38, 0.3)},
		{"id": "chain", "key": "FLOW4_CHAIN", "pos": Vector2(0.72, 0.3)},
		{"id": "niko", "key": "FLOW4_NIKO", "pos": Vector2(0.72, 0.41)},
		{"id": "4a.1", "key": "FLOW_4A_1", "pos": Vector2(0.08, 0.55), "outcome": true},
		{"id": "4a.2", "key": "FLOW_4A_2", "pos": Vector2(0.245, 0.55), "outcome": true},
		{"id": "4a.3", "key": "FLOW_4A_3", "pos": Vector2(0.41, 0.55), "outcome": true},
		{"id": "4b.3", "key": "FLOW_4B_3", "pos": Vector2(0.575, 0.55), "outcome": true},
		{"id": "4b.1", "key": "FLOW_4B_1", "pos": Vector2(0.74, 0.55), "outcome": true},
		{"id": "4b.2", "key": "FLOW_4B_2", "pos": Vector2(0.905, 0.55), "outcome": true},
		{"id": "act2", "key": "FLOW4_ACT2", "pos": Vector2(0.5, 0.69)},
	]
	c.edges = [["4a", "sneak"], ["4a", "confront"], ["sneak", "4a.1"], ["confront", "4a.2"], ["confront", "4a.3"],
		["4b", "chain"], ["chain", "4b.3"], ["chain", "niko"], ["niko", "4b.3"], ["niko", "4b.1"], ["niko", "4b.2"],
		["4a.1", "act2"], ["4a.2", "act2"], ["4a.3", "act2"], ["4b.1", "act2"], ["4b.2", "act2"], ["4b.3", "act2"]]
	c.taken[branch] = true
	if branch == "4a":
		c.taken["sneak" if _outcome == "4a.1" else "confront"] = true
	else:
		c.taken["chain"] = true
		if not GameState.flags.get("fell_chain", false):
			c.taken["niko"] = true
	c.taken[_outcome] = true
	c.seen["act2"] = true
	for id in ["4a.1", "4a.2", "4a.3", "4b.1", "4b.2", "4b.3"]:
		if GameState.has_seen(id):
			c.seen[id] = true
	var fez_on: bool = GameState.flags.get("fez", true)
	var sin: bool = GameState.flags.get("sinerji", false)
	c.footer_lines = [
		tr("UI_FLOW_STATS") % GameState.telsiz_bag + "     ·     " + ("Fes: ✓" if fez_on else "Fes: ✗") + "     ·     " + tr("UI_SINERJI") + (" ✓" if sin else " ✗"),
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW4_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	if id == "guards" and phase == "sneak" and not _busy:
		hud.set_prompt(tr("UI_PROMPT4_GUARDS"))
	else:
		hud.set_prompt("")


func _on_interact(id: String) -> void:
	if id == "guards" and phase == "sneak" and not _busy:
		_confront()


# ================================================================ yardımcılar

func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _h(key: String) -> void:
	await hud.say("SPK_HIKMET", key)


func _say(speaker: String, key: String) -> void:
	var who: Node = null
	if speaker == "SPK_NIKO" and walls:
		who = walls.niko
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


func _flash_prompt(text: String, seconds: float) -> void:
	hud.set_prompt(text)
	await _wait(seconds)
	# Başka bir şey yazılmadıysa her durumda sil (düşünce "A/D" ipucu hücrede asılı kalıyordu)
	if hud and hud._prompt.text == text:
		hud.set_prompt("")


# ================================================================ otomatik test

func _autotest_report() -> void:
	var expected: String = {"": "4a.1", "next": "4a.1", "item": "4a.2", "caught": "4a.3", "market": "4a.1",
		"chain": "4b.1", "nofez": "4b.2", "fall": "4b.3"}[GameState.autotest_variant]
	var ok: bool = _outcome == expected and GameState.flags.get("act1_done", false)
	if not ok:
		printerr("AUTOTEST: beklenen sonuç %s, gelen %s" % [expected, _outcome])
	if GameState.chapter_outcomes.get(4, "") != _outcome:
		ok = false
		printerr("AUTOTEST: bölüm sonucu kaydedilmedi")
	print("AUTOTEST %s chapter=4 variant=%s branch=%s start=%s outcome=%s catches=%d fez=%s telsiz=%d" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, branch, start, _outcome, catches,
		GameState.flags.get("fez", true), GameState.telsiz_bag])
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
	if branch == "4a":
		# 1. Esir çadırının önü: çıkışta nöbetçiler
		_spawn_4a()
		player.global_position = Vector3(-3.0, 0.05, -1.5)
		player.face(Vector3(0, 1.4, Camp.GATE_Z))
		hud.set_objective(tr("UI_OBJ4A_ESCAPE"), Vector3(0, 1.2, Camp.ESCAPE_Z))
		hud.bark("SPK_TOLGA", "D4A_T_04", 30.0)
		await _shot("c4_01_ordugah.png")
		# 2. Tartışma: sandığın arkasından
		_set_arguing(true)
		player.global_position = Vector3(-2.2, 0.05, 1.3)
		player.face(Vector3(0, 1.5, Camp.GATE_Z + 0.7))
		await get_tree().create_timer(0.6).timeout
		await _shot("c4_02_tartisma.png")
		# 3. Yüzleşme: termos
		_set_arguing(false)
		player.global_position = Vector3(0, 0.05, Camp.GATE_Z - 1.8)
		player.face(Vector3(0, 1.5, Camp.GATE_Z + 0.7))
		hud.bark("SPK_HASAN", "D4A_ITEM_THERMOS_1", 30.0)
		await get_tree().create_timer(0.5).timeout
		await _shot("c4_03_nobetciler.png")
		get_tree().quit()
		return
	# 4b
	walls.niko.look_target = player
	player.move_mode = "walk"
	player.gravity_on = false
	player.global_position = SeaWalls.CHAIN_START.lerp(SeaWalls.CHAIN_END, 0.55) + Vector3(0.1, 0.25, 0)
	player.face(Vector3(4, 8.0, -3.0))
	player.camera.rotation.z = -0.12
	var meter := BalanceMeter.new()
	meter.label_text = tr("UI_BALANCE")
	meter.value = 0.35
	hud.add_child(meter)
	var vp := get_viewport().get_visible_rect().size
	meter.position = Vector2((vp.x - meter.size.x) / 2.0, vp.y * 0.12)
	hud.bark("SPK_NIKO", "D4B_N_01", 30.0)
	await _shot("c4_04_zincir.png")
	meter.queue_free()
	player.camera.rotation.z = 0.0
	# 5. Rıhtım: tavuk geliyor
	player.gravity_on = true
	player.global_position = Vector3(2.0, SeaWalls.QUAY_Y + 0.05, -0.5)
	walls.niko.position.x = 9.0
	player.face(Vector3(10.0, 5.0, -2.2))
	var c := Chicken.new()
	c.flapping = true
	walls.add_child(c)
	c.global_position = Vector3(7.0, SeaWalls.QUAY_Y + 4.2, -1.9)
	c.scale = Vector3.ONE * 1.6
	var ring := Props.ring(walls, 0.45, 0.6, Vector3(5.8, SeaWalls.QUAY_Y + 0.04, -1.2), Color("ff3b30"), Vector3.ZERO, 2.0)
	ring.material_override = Props.mat(Color("ff3b30"), 2.0, false, "", false)
	hud.set_objective(tr("UI_OBJ4B_GATE"), Vector3(SeaWalls.GATE_X, SeaWalls.QUAY_Y + 1.4, SeaWalls.WALL_Z + 0.5))
	hud.bark("SPK_NIKO", "D4B_N_THROW_CHICKEN_1", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c4_05_niko.png")
	# 6. Perde I kapanışı
	await _act_end_shot()
	get_tree().quit()


func _act_end_shot() -> void:
	GameState.autotest = true
	await _act_end()
	GameState.autotest = false
	hud.typewriter(tr("UI_ACT1_TYPED"), 0.01)
	await get_tree().create_timer(1.0).timeout
	await _shot("c4_06_perde1.png")
