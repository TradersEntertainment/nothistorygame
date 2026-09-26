extends Node3D
## Bölüm 22 — Kule (Tolga · 18 Mayıs 1453, şafak ve gece, Mesoteichion). docs/SIEGE.md §3.
##
## Osmanlılar bir gecede hendeğin önüne, derisi ıslatılmış tahta bir kuşatma kulesi kurar; önündeki hendeği
## toprakla doldururlar. Savunucular gece barut fıçılarını aşağı yuvarlayıp kuleyi yakar (Barbaro, 18–19 Mayıs).
## Oynanış: dış surun tepesinde üç fıçı. Fıçıyı oluğa koy, fitili yak, doğru anda bırak:
##   erken bırakırsan fitil uzun kalır, aşağıdakiler fıçıyı hendeğe iter · geç bırakırsan yamaçta patlar ·
##   hiç bırakmazsan oluğun ağzında patlar (Tolga'nın kaşları gider).
##   22.1 Kule Tolga'nın fıçısıyla yandı · 22.2 Kule yandı, Tolga'nın kaşı da · 22.3 Tolga ıskaladı,
##   Giustiniani'nin adamları yaktı (tarih yine aynı)
##   --autotest[=brow|miss]   (varsayılan: 22.1)

const TOWER := Vector3(-3.0, 0.0, 40.0)
const WALK_Y := LandWalls.OUTER_H
const CHUTE := Vector3(-2.5, LandWalls.OUTER_H, LandWalls.OUTER_Z1 - 0.2)
const BARRELS := Vector3(3.5, LandWalls.OUTER_H, 15.0)
const FUSE_TIME := 2.6
const WIN_A := 0.42
const WIN_B := 0.68

var walls: LandWalls
var player: Player
var hud: Hud
var giust: Person
var tower: Node3D
var _fire: Array[Node3D] = []
var _fire_light: OmniLight3D
var phase := "intro"
var _outcome := ""
var barrels_left := 3
var hits := 0
var singed := false
var carrying := false
var _carry: Node3D
var _fuse := -1.0
var _gauge: Control
var _photo := ""
var cam: TespitCam
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(22)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	walls = LandWalls.new()
	add_child(walls)
	walls.set_repair(LandWalls.STAGES)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	# Surun tepesi: yürüyüş yolunun dış kenarında mazgal boyu korkuluk (düşülmesin), iç kenarında alçak duvar
	var zc := (LandWalls.OUTER_Z0 + LandWalls.OUTER_Z1) * 0.5
	for spec in [[Vector3(30, 1.1, 0.3), Vector3(-10.0, WALK_Y + 0.55, LandWalls.OUTER_Z1 - 0.05)],
			[Vector3(30, 0.7, 0.2), Vector3(-10.0, WALK_Y + 0.35, LandWalls.OUTER_Z0 + 0.05)],
			[Vector3(0.3, 1.2, 2.0), Vector3(5.2, WALK_Y + 0.6, zc)], [Vector3(0.3, 1.2, 2.0), Vector3(-25.0, WALK_Y + 0.6, zc)]]:
		var b := Props.solid(self, spec[0], spec[1], Color("b8a888"))
		b.get_child(0).visible = false
		b.set_meta("no_climb", true)
	# Gedik barikatı yürüyüş yolunu böler: üstüne kalas köprü
	Props.solid(self, Vector3(LandWalls.BREACH_W + 0.4, 0.2, 1.8), Vector3(0, WALK_Y - 0.1, zc), Color("8a6440"))
	# Oluk: mazgal aralığından aşağı eğik tahta kanal
	var chute := Node3D.new()
	chute.position = CHUTE
	add_child(chute)
	Props.box(chute, Vector3(1.0, 0.1, 3.4), Vector3(0, -0.6, 1.4), Color("7a5634"), Vector3(-28, 0, 0))
	for sx: float in [-0.5, 0.5]:
		Props.box(chute, Vector3(0.08, 0.35, 3.4), Vector3(sx, -0.45, 1.4), Color("5a3e26"), Vector3(-28, 0, 0))
	Props.interactable(self, "chute", Vector3(1.4, 1.4, 1.2), CHUTE + Vector3(0, 0.7, -0.6))
	# Barut fıçıları (kara, üstünde fitil)
	for i in 3:
		var b := Node3D.new()
		b.name = "Powder%d" % i
		b.position = BARRELS + Vector3(i * 0.7, 0, -0.3)
		add_child(b)
		_powder_barrel(b)
	Props.interactable(self, "powder", Vector3(2.4, 1.2, 1.2), BARRELS + Vector3(0.7, 0.6, -0.3))
	giust = Person.new({"face": "giustiniani", "coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero",
		"beard": true, "skin": Color("e0b08a")})
	giust.position = Vector3(-6.0, WALK_Y, 15.0)
	giust.rotation.y = PI * 0.5
	add_child(giust)
	giust.look_target = player
	_build_tower()
	# Hendeğin kule önündeki kısmı doldurulmuş: toprak rampası
	Props.box(self, Vector3(10.0, 3.2, 16.0), Vector3(TOWER.x, -1.4, 28.0), Color("5a4630"))
	_gauge = Control.new()
	_gauge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gauge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gauge.draw.connect(_draw_gauge)
	hud.add_child(_gauge)


func _powder_barrel(b: Node3D) -> void:
	Props.cyl(b, 0.32, 0.8, Vector3(0, 0.4, 0), Color("2e2a26"), Vector3.ZERO, 10)
	for y: float in [0.15, 0.65]:
		Props.cyl(b, 0.33, 0.05, Vector3(0, y, 0), Color("6a6a70"), Vector3.ZERO, 10)
	Props.cyl(b, 0.015, 0.25, Vector3(0.1, 0.9, 0), Color("c8b894"), Vector3(0, 0, 20), 4)


## Kuşatma kulesi: üç katlı tahta iskelet, ıslak deri kaplama, tepede asma köprü, altında tekerlekler.
func _build_tower() -> void:
	tower = Node3D.new()
	tower.position = TOWER
	add_child(tower)
	var wood := Color("4a3220")
	var hide := Color("6a4a30")
	for sx: float in [-2.2, 2.2]:
		for sz: float in [-2.2, 2.2]:
			Props.cyl(tower, 0.2, 14.0, Vector3(sx, 7.0, sz), wood, Vector3.ZERO, 6)
	for y: float in [0.8, 5.0, 9.2, 13.4]:
		Props.box(tower, Vector3(4.8, 0.3, 4.8), Vector3(0, y, 0), wood.darkened(0.1))
	for y: float in [3.0, 7.2, 11.4]:
		Props.box(tower, Vector3(4.7, 3.8, 0.12), Vector3(0, y, -2.35), hide.darkened(randf() * 0.15))
		for sx: float in [-1.0, 1.0]:
			Props.box(tower, Vector3(0.12, 3.8, 4.7), Vector3(sx * 2.35, y, 0), hide.darkened(randf() * 0.15))
	for y: float in [3.0, 7.2, 11.4]:
		for d: float in [-35.0, 35.0]:
			Props.box(tower, Vector3(0.18, 5.2, 0.14), Vector3(0, y, -2.45), wood.lightened(0.1), Vector3(0, 0, d))
	Props.box(tower, Vector3(3.0, 0.15, 3.4), Vector3(0, 14.2, -3.4), wood, Vector3(-70, 0, 0))
	for sx: float in [-1.9, 1.9]:
		for sz: float in [-1.9, 1.9]:
			Props.cyl(tower, 0.6, 0.3, Vector3(sx, 0.6, sz), Color("3a2a1c"), Vector3(0, 0, 90), 10)
	Props.box(tower, Vector3(0.05, 1.2, 1.8), Vector3(0.6, 15.6, 0), Color("b3262d"))
	Props.cyl(tower, 0.04, 2.6, Vector3(0.6, 15.0, -0.9), wood, Vector3.ZERO, 4)
	_fire_light = OmniLight3D.new()
	_fire_light.position = Vector3(0, 4.0, -2.8)
	_fire_light.light_color = Color("ff8a3a")
	_fire_light.light_energy = 0.0
	_fire_light.omni_range = 40.0
	tower.add_child(_fire_light)


## Kuleye ateş: her isabette alevler büyür.
func _burn(level: int) -> void:
	for i in 4 * level:
		var f := Props.cyl(tower, randf_range(0.4, 0.9), randf_range(1.2, 2.6), Vector3(randf_range(-2.2, 2.2), randf_range(0.8, 5.0 + level * 4.0), randf_range(-2.4, -1.6)), Color("ffa030"), Vector3.ZERO, 6, 0.05, 3.0)
		f.material_override = Props.mat(Color("ff9a30"), 3.5, false, "", false)
		_fire.append(f)
	_fire_light.light_energy = 3.0 + level * 4.0


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH22_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH22_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	walls.make_dawn(0.01)
	player.global_position = Vector3(-8.0, WALK_Y + 0.05, 15.0)
	player.face(TOWER + Vector3(0, 8.0, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.2)
	await hud.say("SPK_TOLGA", "D22_T_01")
	await hud.say("SPK_GIUST", "D22_G_01")
	await hud.say("SPK_TOLGA", "D22_T_02")
	await hud.say("SPK_GIUST", "D22_G_02")
	await hud.say("SPK_NIHAT", "D22_N_01")
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH22_NIGHT"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	_make_night()
	player.global_position = Vector3(0.0, WALK_Y + 0.05, 15.0)
	player.face(BARRELS + Vector3(0, 0.6, 0))
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_GIUST", "D22_G_03")
	await hud.say("SPK_GIUST", "D22_G_04")
	await hud.say("SPK_TOLGA", "D22_T_03")
	player.frozen = false
	phase = "barrels"
	_update_objective()
	if GameState.autotest:
		_auto()
	while phase == "barrels":
		await get_tree().process_frame
	await _finale()
	await _end_chapter()


func _make_night() -> void:
	var e := walls.env.environment
	var sm := e.sky.sky_material as ProceduralSkyMaterial
	sm.sky_top_color = Color("0b1330")
	sm.sky_horizon_color = Color("2a3560")
	sm.ground_horizon_color = Color("1c2238")
	e.ambient_light_color = Color("6a7ab8")
	e.ambient_light_energy = 0.45
	e.fog_light_color = Color("1a2240")
	walls.moon.light_color = Color("9fb4ff")
	walls.moon.light_energy = 0.55
	walls.moon.rotation_degrees = Vector3(-34, 160, 0)


func _update_objective() -> void:
	if phase != "barrels":
		hud.set_objective("")
	elif carrying:
		hud.set_objective(tr("UI_OBJ22_CHUTE") % [hits, 3 - barrels_left], CHUTE + Vector3(0, 0.8, 0))
	else:
		hud.set_objective(tr("UI_OBJ22_TAKE") % barrels_left, BARRELS + Vector3(0.7, 1.0, 0))


func _process(delta: float) -> void:
	_t += delta
	for i in _fire.size():
		var f := _fire[i]
		f.scale.y = 1.0 + sin(_t * 9.0 + i) * 0.25
	if _fire_light and _fire_light.light_energy > 0.0:
		_fire_light.light_energy = maxf(1.0, _fire_light.light_energy + sin(_t * 17.0) * 0.4)
	if _fuse >= 0.0:
		_fuse += delta / FUSE_TIME
		_gauge.queue_redraw()
		if _fuse >= 1.0:
			_release()


func _draw_gauge() -> void:
	if _fuse < 0.0:
		return
	var vs := _gauge.size
	var r := Rect2(Vector2(vs.x * 0.5 - 200, vs.y * 0.62), Vector2(400, 18))
	_gauge.draw_rect(r.grow(3), Color(0, 0, 0, 0.5))
	_gauge.draw_rect(r, Color("2a2622"))
	_gauge.draw_rect(Rect2(r.position + Vector2(r.size.x * WIN_A, 0), Vector2(r.size.x * (WIN_B - WIN_A), r.size.y)), Color("5fcf6a"))
	_gauge.draw_rect(Rect2(r.position + Vector2(r.size.x * 0.9, 0), Vector2(r.size.x * 0.1, r.size.y)), Color("ff5a4a"))
	var x := r.position.x + r.size.x * clampf(_fuse, 0.0, 1.0)
	_gauge.draw_rect(Rect2(Vector2(x - 3, r.position.y - 6), Vector2(6, r.size.y + 12)), Color("ffd070"))
	_gauge.draw_string(ThemeDB.fallback_font, r.position + Vector2(0, -12), tr("UI_CH22_FUSE"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("f2e6c9"))


func _take() -> void:
	if carrying or barrels_left <= 0 or phase != "barrels":
		return
	carrying = true
	var b := get_node_or_null("Powder%d" % (3 - barrels_left))
	if b:
		b.visible = false
	_carry = Node3D.new()
	_carry.position = Vector3(0, -0.6, -0.8)
	player.camera.add_child(_carry)
	_powder_barrel(_carry)
	_carry.scale = Vector3.ONE * 0.8
	Props.strip_outlines(_carry)
	player.speed_mult = 0.7
	_update_objective()


## Oluğa koy ve fitili yak: gösterge dolmaya başlar; ikinci E bırakır.
func _light() -> void:
	if not carrying or _fuse >= 0.0:
		return
	player.frozen = true
	player.face(TOWER + Vector3(0, 1.0, 0))
	_fuse = 0.0
	Audio.sfx("fuse_burn", -4.0)
	hud.set_prompt(tr("UI_PROMPT22_RELEASE"))


func _release() -> void:
	if _fuse < 0.0:
		return
	var f := _fuse
	_fuse = -1.0
	_gauge.queue_redraw()
	hud.set_prompt("")
	carrying = false
	if _carry:
		_carry.queue_free()
		_carry = null
	player.speed_mult = 1.0
	barrels_left -= 1
	var result := "hit"
	if f >= 0.999:
		result = "chute"
	elif f < WIN_A:
		result = "early"
	elif f > WIN_B:
		result = "late"
	await _roll(result)
	player.frozen = false
	if barrels_left <= 0 or hits >= 2:
		phase = "done"
	_update_objective()


## Fıçı oluktan yamaca, yamaçtan kulenin dibine yuvarlanır; sonuç fitile bağlıdır.
func _roll(result: String) -> void:
	var b := Node3D.new()
	add_child(b)
	_powder_barrel(b)
	b.global_position = CHUTE + Vector3(0, 0.1, 0)
	if result == "chute":
		await get_tree().create_timer(0.2).timeout
		Vfx.explosion(self, CHUTE + Vector3(0, 0.6, 0.8), 0.6)
		Audio.sfx("explosion_small", 0.0)
		player.shake(1.0)
		b.queue_free()
		singed = true
		hud.tolga_soot = true
		await hud.say("SPK_TOLGA", "D22_T_SINGED")
		await hud.say("SPK_GIUST", "D22_G_SINGED")
		return
	var mid := Vector3(TOWER.x + randf_range(-0.6, 0.6), 0.5, 26.0)
	var end := TOWER + Vector3(randf_range(-0.8, 0.8), 0.4, -2.8)
	var tw := create_tween()
	tw.tween_property(b, "global_position", mid, 1.0).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(b, "rotation:x", 8.0, 1.0)
	if result == "late":
		await tw.finished
		Vfx.explosion(self, mid, 0.7)
		Audio.sfx("explosion_small", -2.0)
		b.queue_free()
		await hud.say("SPK_GIUST", "D22_G_LATE")
		return
	tw.tween_property(b, "global_position", end, 1.2)
	tw.parallel().tween_property(b, "rotation:x", 16.0, 1.2)
	await tw.finished
	if result == "early":
		# Fitil uzun: aşağıdakiler fıçıyı hendeğe iter, sonra patlar
		var tw2 := create_tween()
		tw2.tween_property(b, "global_position", end + Vector3(4.0, -1.5, -2.0), 0.8)
		await tw2.finished
		Vfx.explosion(self, b.global_position, 0.5)
		Audio.sfx("explosion_small", -8.0)
		b.queue_free()
		await hud.say("SPK_GIUST", "D22_G_EARLY")
		return
	Vfx.explosion(self, end + Vector3(0, 0.5, 0), 1.3)
	Audio.sfx("explosion_big", -2.0)
	player.shake(0.5)
	b.queue_free()
	hits += 1
	_burn(hits)
	await hud.say("SPK_GIUST", "D22_G_HIT_%d" % mini(hits, 2))


func _finale() -> void:
	player.frozen = true
	hud.set_objective("")
	hud.set_prompt("")
	if hits == 0:
		await hud.say("SPK_GIUST", "D22_G_MEN")
		Vfx.explosion(self, TOWER + Vector3(0, 0.5, -2.8), 1.3)
		Audio.sfx("explosion_big", -2.0)
		_burn(1)
	_burn(2)
	await get_tree().create_timer(0.6).timeout
	await hud.say("SPK_TOLGA", "D22_T_BURN")
	# Tespit karesi: yanan kule
	player.frozen = false
	hud.set_objective(tr("UI_OBJ22_PHOTO"), TOWER + Vector3(0, 7.0, 0))
	var target := Node3D.new()
	tower.add_child(target)
	target.position = Vector3(0, 6.0, 0)
	cam = TespitCam.new(player, hud, target, "siege22")
	hud.add_child(cam)
	cam.max_dist = 60.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_GIUST", "D22_G_END")
	await hud.say("SPK_NIHAT", "D22_N_END")
	_outcome = "22.3" if hits == 0 else ("22.2" if singed else "22.1")
	GameState.flags["tolga_singed"] = singed
	Siege.record(22, _photo, "SIEGE_NOTE_22_%s" % _outcome.split(".")[1])


func _on_focus(id: String) -> void:
	match id:
		"powder":
			hud.set_prompt(tr("UI_PROMPT22_TAKE") if not carrying and barrels_left > 0 and phase == "barrels" else "")
		"chute":
			hud.set_prompt(tr("UI_PROMPT22_LIGHT") if carrying and _fuse < 0.0 else "")
		_:
			if _fuse < 0.0:
				hud.set_prompt("")


func _on_interact(id: String) -> void:
	match id:
		"powder":
			_take()
		"chute":
			_light()


func _unhandled_input(event: InputEvent) -> void:
	# Fitil yanarken oyuncu donuk: bırakma tuşu buradan gelir
	if _fuse >= 0.0 and event.is_action_pressed("interact"):
		_release()
		get_viewport().set_input_as_handled()


func _auto() -> void:
	var plan: Array = {"": [0.55, 0.55], "brow": [1.0, 0.55, 0.55], "miss": [0.2, 0.8, 0.2]}.get(GameState.autotest_variant, [0.55, 0.55])
	for f: float in plan:
		await get_tree().create_timer(0.3).timeout
		if phase != "barrels":
			break
		_take()
		_light()
		while _fuse >= 0.0 and _fuse < f:
			await get_tree().process_frame
		if _fuse >= 0.0 and f < 1.0:
			_release()
		while player.frozen and phase == "barrels":
			await get_tree().process_frame


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(22, _outcome)
	await Siege.show_page(hud, 22)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(22)
			if nxt != "":
				GameState.change_scene(nxt)
			else:
				hud.set_fade(1.0)
				await hud.card([[tr("UI_SIEGE_TBC"), 30, Color("f2e6c9")], [tr("UI_SIEGE_TBC_SUB"), 18, Color(1, 1, 1, 0.7)]], 3.5)
				GameState.change_scene("res://scenes/main.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW22_TITLE")
	c.nodes = [
		{"id": "tower", "key": "FLOW22_TOWER", "pos": Vector2(0.5, 0.14)},
		{"id": "barrels", "key": "FLOW22_BARRELS", "pos": Vector2(0.5, 0.32)},
		{"id": "22.1", "key": "FLOW_22_1", "pos": Vector2(0.2, 0.56), "outcome": true},
		{"id": "22.2", "key": "FLOW_22_2", "pos": Vector2(0.5, 0.56), "outcome": true},
		{"id": "22.3", "key": "FLOW_22_3", "pos": Vector2(0.8, 0.56), "outcome": true},
	]
	c.edges = [["tower", "barrels"], ["barrels", "22.1"], ["barrels", "22.2"], ["barrels", "22.3"]]
	c.taken["tower"] = true
	c.taken["barrels"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH22_STATS") % [hits, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "22.1", "brow": "22.2", "miss": "22.3"}.get(v, "22.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("22", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=22 variant=%s outcome=%s hits=%d singed=%s" % ["PASS" if ok else "FAIL", v, _outcome, hits, singed])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.show_remote(false)
	walls.make_dawn(0.01)
	player.global_position = Vector3(-8.0, WALK_Y + 0.05, 15.0)
	await get_tree().create_timer(0.8).timeout
	player.face(TOWER + Vector3(0, 8.0, 0))
	hud.bark("SPK_TOLGA", "D22_T_01", 30.0)
	await _shot("c22_01_dawn.png")
	_make_night()
	player.global_position = CHUTE + Vector3(0.3, 0.05, -0.9)
	phase = "barrels"
	carrying = true
	_fuse = 0.5
	player.face(TOWER + Vector3(0, 1.0, 0))
	_gauge.queue_redraw()
	await _shot("c22_02_fuse.png")
	_fuse = -1.0
	_burn(1)
	_burn(2)
	player.face(TOWER + Vector3(0, 6.0, 0))
	await _shot("c22_03_burn.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(6.0, WALK_Y + 1.8, 14.6)
	cv.look_at(TOWER + Vector3(0, 6.0, 0), Vector3.UP)
	cv.fov = 55.0
	cv.make_current()
	await _shot("c22_cover.png")
	get_tree().quit()
