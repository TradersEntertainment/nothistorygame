extends Node3D
## Bölüm 24 (Osmanlı tarafı) — Alametler (Tolga · 22 ve 24 Mayıs 1453, ordugâh).
##
## 22 Mayıs gecesi ay tutulur (kanlı ay). Şehirde bu, "ay küçülünce şehir düşer" kehaneti diye okunur; ordugâhta
## da askerler tedirgindir. Tolga Aşçıbaşı Kadri'nin çorbasını ateş başlarına taşırken üç ateşteki askerlerle konuşur
## (ay bitmeden). Tespit: kanlı ay. 24 Mayıs: fırtına ve dolu ordugâhı döver; Tolga mutfak çadırlarının iplerini
## tutar (E basılı), rüzgâr sertleştikçe ip kayar.
##   24O.1 Üç ateş de sakinleşti · 24O.2 Ay geri geldi; kalan ateşleri derviş sakinleştirdi
##   --autotest[=late]   (varsayılan: 24O.1)

const FIRES := [Vector3(-12.0, 0.0, -2.0), Vector3(11.0, 0.0, -3.0), Vector3(-4.0, 0.0, 9.0)]
const ECLIPSE_TIME := 75.0
const TENTS := [Vector3(-33.0, 0.0, -13.0), Vector3(-33.5, 0.0, -5.5), Vector3(-33.0, 0.0, 2.0)]   # ordugâhın batı kenarı, mutfak ambarları
const HOLD_TIME := 2.2
const STORM_TIME := 40.0

var day: CampDay
var player: Player
var hud: Hud
var dervish: Person
var groups: Array = []          # [[Person, Person], ...]
var calmed: Array[bool] = [false, false, false]
var moon: SkyBody
var cam: TespitCam
var phase := "intro"
var _outcome := ""
var _eclipse_t := 0.0
var tents: Array[Node3D] = []
var _tent_hold: Array[float] = [0.0, 0.0, 0.0]
var tent_state: Array[int] = [0, 0, 0]     # 0 bekliyor · 1 bağlandı · -1 uçtu
var _gust: Array[float] = [0.0, 0.0, 0.0]
var _storm_t := 0.0
var rain: CPUParticles3D
var hail: CPUParticles3D
var _photo := ""
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(24)
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	day = CampDay.new()
	add_child(day)
	day.make_night(false)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _gy(p: Vector3) -> Vector3:
	return Vector3(p.x, CampDay.height(p.x, p.z), p.z)


func _build() -> void:
	for c in day.get_children():
		if c is SkyBody and (c as SkyBody).is_moon:
			moon = c
	# Ateş başlarında ikişer asker
	for i in FIRES.size():
		var g: Array = []
		for k in 2:
			var a := TAU * (0.2 + k * 0.45 + i * 0.1)
			var s := Person.new({"coat": [Color("b3262d"), Color("6a4a3a"), Color("2f5fa8")][(i + k) % 3], "pants": Color("e8e0d0"),
				"hat": "bork" if k == 0 else "turban", "mustache": true, "beard": k == 1, "skin": Color("d9a07a")})
			s.set_meta("no_talk", true)
			s.position = _gy((FIRES[i] as Vector3) + Vector3(cos(a), 0, sin(a)) * 1.4)
			_turn(s, FIRES[i])
			add_child(s)
			s.set_activity("sit_ground")
			g.append(s)
		groups.append(g)
		Props.interactable(self, "fire_%d" % i, Vector3(3.2, 1.6, 3.2), _gy(FIRES[i]) + Vector3(0, 0.8, 0))
	dervish = Person.new({"coat": Color("6a5a48"), "pants": Color("4a4038"), "hat": "turban", "beard": true, "robe": Color("7a6a50"),
		"hair": Color("8a8a88"), "skin": Color("c89070")})
	dervish.set_meta("spk", "SPK_DERVISH")
	dervish.position = _gy(Vector3(2.0, 0, 3.0))
	add_child(dervish)
	dervish.look_target = player
	# Fırtınada tutulacak çadırlar (mutfak tarafı): ipler ve kazıklar
	for i in TENTS.size():
		var t := Night.tent(self, _gy(TENTS[i]), 1.7, Color("d8cbb0"), Color("8a2b22"))
		tents.append(t)
		var peg := _gy((TENTS[i] as Vector3) + Vector3(1.9, 0, 1.2))
		Props.cyl(self, 0.05, 0.5, peg + Vector3(0, 0.2, 0), Color("5a3e26"), Vector3(0, 0, -15), 4)
		Props.cyl(self, 0.012, 2.6, peg.lerp(_gy(TENTS[i]) + Vector3(0, 2.4, 0), 0.5), Color("c8b894"), Vector3(0, 0, 0), 3)
		Props.interactable(self, "rope_%d" % i, Vector3(1.4, 1.6, 1.4), peg + Vector3(0, 0.6, 0))
	rain = _particles(900, Vector3(0.01, 0.5, 0.01), Color(0.75, 0.82, 0.95, 0.55), -40.0, 1.0)
	hail = _particles(160, Vector3(0.06, 0.06, 0.06), Color("f4f6fa"), -30.0, 1.4)


## Person +Z'ye bakar: hedefe döndür.
func _turn(n: Node3D, to: Vector3) -> void:
	var d := to - n.position
	n.rotation.y = atan2(d.x, d.z)


func _particles(n: int, size: Vector3, col: Color, grav: float, life: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.amount = n
	p.lifetime = life
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(14, 1, 14)
	p.position = Vector3(0, 9, 0)
	p.direction = Vector3(0.3, -1, 0)
	p.spread = 6.0
	p.initial_velocity_min = 14.0
	p.initial_velocity_max = 18.0
	p.gravity = Vector3(0, grav, 0)
	var m := BoxMesh.new()
	m.size = size
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = col
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.material = mat
	p.mesh = m
	p.emitting = false
	player.add_child(p)
	return p


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH24O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH24O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = _gy(CampDay.KADRI_FRONT + Vector3(0.8, 0, 2.0)) + Vector3(0, 0.05, 0)
	player.face(day.kadri.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D24O_N_01")
	await hud.say("SPK_KADRI", "D24O_K_01")
	await hud.say("SPK_TOLGA", "D24O_T_01")
	# Tutulma başlar
	if moon:
		player.face(moon.global_position)
		moon.eclipse(true, 6.0)
	Audio.sfx("crowd_gasp", -6.0, 0.8)
	await get_tree().create_timer(1.5).timeout
	await hud.say("SPK_KADRI", "D24O_K_02")
	await hud.say("SPK_DERVISH", "D24O_D_01")
	# Tespit: kanlı ay
	player.frozen = false
	await _moon_photo()
	# Üç ateş: ay geri gelmeden
	phase = "calm"
	_eclipse_t = ECLIPSE_TIME
	_update_objective()
	if GameState.autotest:
		_auto_calm()
	while phase == "calm" and _eclipse_t > 0.0 and calmed.count(true) < 3:
		await get_tree().process_frame
		if not hud.is_talking():
			_eclipse_t -= get_process_delta_time()
		hud.set_chase(tr("UI_CH24O_MOON") % maxi(0, int(ceil(_eclipse_t))), 1.0 - _eclipse_t / ECLIPSE_TIME)
	while hud.is_talking():
		await get_tree().process_frame
	phase = "moon_back"
	hud.set_chase("", 0.0)
	hud.set_objective("")
	hud.set_prompt("")
	player.frozen = true
	if moon:
		moon.eclipse(false, 6.0)
	player.face(dervish.global_position + Vector3(0, 1.5, 0))
	if calmed.count(true) < 3:
		await hud.say("SPK_DERVISH", "D24O_D_REST")
	else:
		await hud.say("SPK_DERVISH", "D24O_D_ALL")
	await hud.say("SPK_TOLGA", "D24O_T_MOON")
	await _storm()
	await _ending()
	await _end_chapter()


func _moon_photo() -> void:
	var target := Node3D.new()
	add_child(target)
	if moon:
		target.global_position = player.global_position + (moon.global_position - player.global_position).normalized() * 300.0
	else:
		target.global_position = player.global_position + Vector3(0, 150, -300)
	hud.set_objective(tr("UI_OBJ24O_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege24o")
	hud.add_child(cam)
	cam.max_dist = 1000.0
	cam.cone_deg = 10.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 30.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	hud.set_objective("")


func _update_objective() -> void:
	if phase == "calm":
		for i in 3:
			if not calmed[i]:
				hud.set_objective(tr("UI_OBJ24O_CALM") % [calmed.count(true), 3], _gy(FIRES[i]) + Vector3(0, 1.2, 0))
				return
	elif phase == "storm":
		for i in 3:
			if tent_state[i] == 0:
				hud.set_objective(tr("UI_OBJ24O_ROPE") % [tent_state.count(1), 3], _gy((TENTS[i] as Vector3) + Vector3(1.9, 0, 1.2)) + Vector3(0, 0.8, 0))
				return
	hud.set_objective("")


func _auto_calm() -> void:
	var late := GameState.autotest_variant == "late"
	for i in 3:
		await get_tree().create_timer(0.3).timeout
		if late and i == 2:
			_eclipse_t = 0.0
			return
		await _talk(i)


func _talk(i: int) -> void:
	if calmed[i] or phase != "calm":
		return
	player.frozen = true
	hud.set_prompt("")
	var g: Array = groups[i]
	player.face((g[0] as Node3D).global_position + Vector3(0, 1.0, 0))
	Audio.sfx("land_pot", -10.0, 1.1)
	await hud.say("SPK_SOLDIER", "D24O_S_%d" % (i + 1))
	var c := await hud.choose(["UI_C24O_SCIENCE", "UI_C24O_SOUP", "UI_C24O_JOKE"], 0.0, i % 3)
	await hud.say("SPK_TOLGA", ["D24O_T_SCIENCE", "D24O_T_SOUP", "D24O_T_JOKE"][c])
	await hud.say("SPK_SOLDIER", "D24O_S_%d_%s" % [i + 1, ["SCIENCE", "SOUP", "JOKE"][c]])
	calmed[i] = true
	for s in g:
		_turn(s, player.global_position)
	player.frozen = false
	_update_objective()


## 24 Mayıs: fırtına ve dolu. Üç çadırın ipleri: her çadır ara ara sert bir esintiyle zorlanır; ipin başında E basılı
## tutulunca bağlanır. Esinti dolduğunda bağlanmamış çadır uçar.
func _storm() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH24O_STORM"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	rain.emitting = true
	hail.emitting = true
	Audio.sfx("explosion_big", -16.0, 0.45)
	player.global_position = _gy(Vector3(-27.5, 0, -5.5)) + Vector3(0, 0.05, 0)
	player.face(_gy(TENTS[0]) + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_KADRI", "D24O_K_STORM")
	phase = "storm"
	player.frozen = false
	_storm_t = STORM_TIME
	for i in 3:
		_gust[i] = -i * 4.0
	_update_objective()
	if GameState.autotest:
		_auto_ropes()
	while phase == "storm" and _storm_t > 0.0 and tent_state.count(0) > 0:
		await get_tree().process_frame
		_storm_t -= get_process_delta_time()
	phase = "after_storm"
	for i in 3:
		if tent_state[i] == 0:
			tent_state[i] = 1   # süre dolarken kalanlar dayanır
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	hud.set_objective("")
	player.frozen = true
	rain.emitting = false
	hail.emitting = false
	var lost := tent_state.count(-1)
	await hud.say("SPK_KADRI", "D24O_K_LOST_%d" % mini(lost, 2))


func _auto_ropes() -> void:
	for i in 3:
		await get_tree().create_timer(0.3).timeout
		_tie(i)


func _tie(i: int) -> void:
	if tent_state[i] != 0:
		return
	tent_state[i] = 1
	_gust[i] = 0.0
	Audio.sfx("land_thud", -10.0, 1.4)
	hud.bark("SPK_TOLGA", "D24O_T_TIED_%d" % (tent_state.count(1)), 2.0)
	_update_objective()


func _fly(i: int) -> void:
	tent_state[i] = -1
	var t := tents[i]
	var tw := create_tween().set_parallel()
	tw.tween_property(t, "position", t.position + Vector3(8.0, 6.0, -4.0), 1.4).set_ease(Tween.EASE_IN)
	tw.tween_property(t, "rotation", Vector3(1.2, 2.0, 0.6), 1.4)
	tw.chain().tween_callback(t.hide)
	Audio.sfx("whoosh_fly", -4.0, 0.7)
	hud.bark("SPK_KADRI", "D24O_K_FLY", 2.5)
	_update_objective()


func _ending() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH24O_AFTER"), 26, Color("f2e6c9")]], 1.6)
	hud.clear_card()
	player.global_position = _gy(CampDay.KADRI_FRONT + Vector3(0.8, 0, 2.0)) + Vector3(0, 0.05, 0)
	player.face(day.kadri.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_KADRI", "D24O_K_END")
	await hud.say("SPK_TOLGA", "D24O_T_END")
	await hud.say("SPK_NIHAT", "D24O_N_END")
	_outcome = "24O.1" if calmed.count(true) == 3 else "24O.2"
	Siege.record(24, _photo, "SIEGE_NOTE_24O_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	if phase == "storm":
		var worst := 0.0
		for i in 3:
			var t := tents[i]
			if tent_state[i] == 0:
				_gust[i] += delta / 9.0
				t.rotation.z = sin(_t * 6.0 + i) * 0.06 * (1.0 + clampf(_gust[i], 0.0, 1.0) * 2.0)
				worst = maxf(worst, _gust[i])
				if _gust[i] >= 1.0:
					_fly(i)
			elif tent_state[i] == 1:
				t.rotation.z = sin(_t * 6.0 + i) * 0.02
		hud.set_chase(tr("UI_CH24O_WIND"), clampf(worst, 0.0, 1.0))
		var id := player.focus_id
		if id.begins_with("rope_") and Input.is_action_pressed("interact"):
			var k := int(id.trim_prefix("rope_"))
			if tent_state[k] == 0:
				_tent_hold[k] += delta
				_gust[k] = maxf(0.0, _gust[k] - delta * 0.3)
				hud.set_prompt(tr("UI_CH24O_TYING") + "  %d%%" % int(100.0 * _tent_hold[k] / HOLD_TIME))
				if _tent_hold[k] >= HOLD_TIME:
					_tie(k)
					hud.set_prompt("")


func _on_focus(id: String) -> void:
	if phase == "calm" and id.begins_with("fire_") and not calmed[int(id.trim_prefix("fire_"))]:
		hud.set_prompt(tr("UI_PROMPT24O_TALK"))
	elif phase == "storm" and id.begins_with("rope_") and tent_state[int(id.trim_prefix("rope_"))] == 0:
		hud.set_prompt(tr("UI_PROMPT24O_ROPE"))
	else:
		hud.set_prompt("")


func _on_interact(id: String) -> void:
	if phase == "calm" and id.begins_with("fire_") and not player.frozen:
		_talk(int(id.trim_prefix("fire_")))


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(24, _outcome)
	await Siege.show_page(hud, 24)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(24)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW24O_TITLE")
	c.nodes = [
		{"id": "moon", "key": "FLOW24O_MOON", "pos": Vector2(0.5, 0.12)},
		{"id": "24O.1", "key": "FLOW_24O_1", "pos": Vector2(0.3, 0.34), "outcome": true},
		{"id": "24O.2", "key": "FLOW_24O_2", "pos": Vector2(0.7, 0.34), "outcome": true},
		{"id": "storm", "key": "FLOW24O_STORM", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["moon", "24O.1"], ["moon", "24O.2"], ["24O.1", "storm"], ["24O.2", "storm"]]
	for k in ["moon", _outcome, "storm"]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH24O_STATS") % [calmed.count(true), tent_state.count(1), Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "24O.1", "late": "24O.2"}.get(v, "24O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("24", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and tent_state.count(1) == 3
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=24o variant=%s outcome=%s calmed=%d" % ["PASS" if ok else "FAIL", v, _outcome, calmed.count(true)])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot_png(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.show_remote(false)
	if moon:
		moon.eclipse(true, 0.1)
	player.global_position = _gy(FIRES[0] as Vector3 + Vector3(2.6, 0, 2.4)) + Vector3(0, 0.05, 0)
	await get_tree().create_timer(0.8).timeout
	player.face(_gy(FIRES[0]) + Vector3(0, 0.8, 0))
	phase = "calm"
	_update_objective()
	await _shot_png("c24o_01_fire.png")
	player.global_position = _gy(Vector3(-27.5, 0, -5.5)) + Vector3(0, 0.05, 0)
	player.face(_gy(TENTS[0]) + Vector3(0, 1.5, 0))
	phase = "storm"
	rain.emitting = true
	hail.emitting = true
	_update_objective()
	await get_tree().create_timer(1.0).timeout
	await _shot_png("c24o_02_storm.png")
	phase = "shots"
	rain.emitting = false
	hail.emitting = false
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = _gy(FIRES[0] as Vector3 + Vector3(4.0, 0, 4.0)) + Vector3(0, 1.2, 0)
	cv.look_at(_gy(FIRES[0]) + Vector3(0, 3.5, 0), Vector3.UP)
	cv.fov = 70.0
	cv.make_current()
	await get_tree().create_timer(0.3).timeout
	await _shot_png("c24o_cover.png")
	get_tree().quit()
