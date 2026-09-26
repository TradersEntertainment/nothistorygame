extends Node3D
## Bölüm 18 — Fıçı Köprü (Tolga · Mayıs başı 1453, Haliç'in iç ucu, Osmanlı kıyısı). docs/SIEGE.md §3.
##
## Osmanlılar Haliç'in en iç kısmında, fıçıları ikişer ikişer bağlayıp üstüne kalas döşeyerek bir köprü kurar;
## köprünün üstüne top konur (Kritovoulos). Tolga köprücü ustanın yanında çalışır: her bölümde
##   fıçı çiftini suya yuvarla (E) · iki kez halatla bağla (zamanlama, E) · kalasları döşe (E).
## Bağ kaçarsa bölüm eğri durur. Altı bölüm sonunda top köprüye çekilir. Tespit karesi: köprünün üstündeki top.
##   18.1 Köprü sağlam (en çok iki kaçan bağ) · 18.2 Köprü eğri ama ayakta
##   --autotest[=crooked]   (varsayılan: 18.1)

const SECTIONS := 6
const SEC_LEN := 3.0
const SHORE_Z := 0.0
const DECK_Y := 0.7
const WIN := 0.16

var player: Player
var hud: Hud
var usta: Person
var workers: Array[Person] = []
var cannon: Node3D
var sections: Array[Node3D] = []
var phase := "intro"
var _outcome := ""
var built := 0
var step := ""              # "barrels" · "lash" · "planks"
var lashes := 0
var misses := 0
var _gauge: Control
var _g := -1.0
var _g_dir := 1.0
var _g_center := 0.5
var _pile_barrel: Node3D
var _pile_plank: Node3D
var _lash_point: Node3D
var _photo := ""
var cam: TespitCam
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(18)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	# Gün ortası, açık gök
	var we := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("4a86c8")
	sm.sky_horizon_color = Color("bcd8ec")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.9
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_light_color = Color("c8d8e8")
	e.fog_density = 0.004
	we.environment = e
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)
	# Su (dalga gölgeli), kıyı ve kum
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(400, 300)
	pm.subdivide_width = 80
	pm.subdivide_depth = 60
	w.mesh = pm
	var sh := ShaderMaterial.new()
	sh.shader = load("res://assets/shaders/water.gdshader")
	w.material_override = sh
	w.position = Vector3(0, 0, 150)
	add_child(w)
	Props.set_pattern(Props.solid(self, Vector3(120, 1.0, 40), Vector3(0, -0.2, SHORE_Z - 20.0), Color.WHITE), Color("c8b48a"), "cobble")
	Props.box(self, Vector3(120, 0.6, 4.0), Vector3(0, -0.3, SHORE_Z + 1.2), Color("d8c8a0"), Vector3(-8, 0, 0))
	# Karşı kıyı: kara surları ve Blakherna (uzakta)
	for i in 14:
		var x := -90.0 + i * 14.0
		Props.box(self, Vector3(12.0, 14.0, 4.0), Vector3(x, 7.0, 150.0), Color("cdbd9e"))
		Props.box(self, Vector3(7.0, 20.0, 7.0), Vector3(x + 6.0, 10.0, 149.0), Color("c8b898"))
		for k in 5:
			Props.box(self, Vector3(1.2, 1.2, 1.0), Vector3(x - 5.0 + k * 2.4, 14.6, 148.2), Color("bcac8e"))
	Props.box(self, Vector3(30.0, 22.0, 14.0), Vector3(40.0, 11.0, 162.0), Color("b8573a"))
	# Osmanlı kıyısı: çadırlar, sancaklar
	for i in 10:
		Night.tent(self, Vector3(-40.0 + i * 9.0, 0.0, SHORE_Z - 22.0 - (i % 3) * 5.0), 2.2)
	# Köprünün kıyı ucu: kazıklar, iskele başı
	Props.set_pattern(Props.solid(self, Vector3(5.0, 0.4, 3.0), Vector3(0, DECK_Y - 0.2, SHORE_Z + 0.5), Color.WHITE), Color("8a6440"), "wood")
	for sx: float in [-2.2, 2.2]:
		Props.cyl(self, 0.18, 3.0, Vector3(sx, 0.2, SHORE_Z + 1.8), Color("5a3e26"), Vector3.ZERO, 6)
	# Bölümler (her biri: iki fıçı, iki halat bağı, kalaslar); yapıldıkça görünür
	for i in SECTIONS:
		var s := Node3D.new()
		s.position = Vector3(0, 0, SHORE_Z + 2.0 + SEC_LEN * (i + 0.5))
		add_child(s)
		var barrels := Node3D.new()
		barrels.name = "Barrels"
		barrels.visible = false
		s.add_child(barrels)
		for sx: float in [-1.3, 1.3]:
			Props.cyl(barrels, 0.55, 2.2, Vector3(sx, 0.15, 0), Color("7a5634"), Vector3(90, 0, 0), 12)
			for zz: float in [-0.7, 0.7]:
				Props.cyl(barrels, 0.56, 0.08, Vector3(sx, 0.15, zz), Color("3a3634"), Vector3(90, 0, 0), 12)
		var rope := Node3D.new()
		rope.name = "Rope"
		rope.visible = false
		s.add_child(rope)
		for zz: float in [-0.6, 0.6]:
			Props.box(rope, Vector3(3.4, 0.08, 0.08), Vector3(0, 0.62, zz), Color("c8b080"))
		var deck := Node3D.new()
		deck.name = "Deck"
		deck.visible = false
		s.add_child(deck)
		for k in 6:
			Props.box(deck, Vector3(4.2, 0.1, 0.46), Vector3(0, DECK_Y, -1.2 + k * 0.49), Color("9a7248").darkened((k % 3) * 0.06))
		var body := Props.solid(s, Vector3(4.2, 0.3, SEC_LEN), Vector3(0, DECK_Y - 0.15, 0), Color.WHITE)
		body.name = "Solid"
		body.get_child(0).visible = false
		body.process_mode = Node.PROCESS_MODE_DISABLED
		for sx: float in [-2.15, 2.15]:
			var rail := Props.solid(s, Vector3(0.1, 0.9, SEC_LEN), Vector3(sx, DECK_Y + 0.45, 0), Color("6a4a2c"))
			rail.name = "Rail"
			rail.visible = false
			rail.process_mode = Node.PROCESS_MODE_DISABLED
		sections.append(s)
	# Malzeme yığınları: bölüm başına taşınır (işçiler getirir)
	_pile_barrel = Node3D.new()
	add_child(_pile_barrel)
	for i in 3:
		Props.cyl(_pile_barrel, 0.4, 1.4, Vector3(0, 0.4 + (i / 2) * 0.78, -0.45 + (i % 2) * 0.9), Color("7a5634"), Vector3(0, 0, 90), 12)
	Props.interactable(_pile_barrel, "barrels", Vector3(1.6, 1.8, 2.2), Vector3(0, 0.8, 0))
	_pile_plank = Node3D.new()
	add_child(_pile_plank)
	for i in 6:
		Props.box(_pile_plank, Vector3(0.46, 0.1, 2.2), Vector3(0, 0.1 + i * 0.12, 0), Color("9a7248"))
	Props.interactable(_pile_plank, "planks", Vector3(1.0, 1.2, 2.4), Vector3(0, 0.5, 0))
	_lash_point = Node3D.new()
	add_child(_lash_point)
	Props.interactable(_lash_point, "lash", Vector3(3.6, 1.6, 2.0), Vector3(0, 0.6, 0))
	_move_piles()
	usta = Person.new({"coat": Color("6a5a3a"), "pants": Color("3a3028"), "hat": "turban", "beard": true, "mustache": true,
		"hair": Color("5a5a5a"), "apron": Color("8a7050"), "skin": Color("d9a07a")})
	usta.set_meta("spk", "SPK_USTA")
	add_child(usta)
	usta.look_target = player
	for i in 3:
		var wk := Soldier.new([Color("8a6a4a"), Color("6a4a3a"), Color("7a5a3a")][i], "stand", "turban")
		wk.position = Vector3(-6.0 + i * 1.5, 0, SHORE_Z - 3.0)
		add_child(wk)
	# Top (bitişte köprüye çekilir)
	cannon = Node3D.new()
	cannon.position = Vector3(6.0, 0, SHORE_Z - 4.0)
	add_child(cannon)
	Props.box(cannon, Vector3(1.4, 0.4, 3.2), Vector3(0, 0.3, 0), Color("5a3e26"))
	Props.cyl(cannon, 0.35, 3.0, Vector3(0, 0.85, 0.2), Color("8c5e26"), Vector3(90, 0, 0), 12)
	Props.cyl(cannon, 0.42, 0.3, Vector3(0, 0.85, 1.65), Color("7a4e1e"), Vector3(90, 0, 0), 12)
	for sx: float in [-0.75, 0.75]:
		Props.cyl(cannon, 0.35, 0.12, Vector3(sx, 0.35, -0.9), Color("3a2a1c"), Vector3(0, 0, 90), 10)
	_gauge = Control.new()
	_gauge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gauge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gauge.draw.connect(_draw_gauge)
	hud.add_child(_gauge)


## Yığınlar ve bağ noktası: köprünün ucuna taşınır.
func _move_piles() -> void:
	var head_z := SHORE_Z + 2.0 + SEC_LEN * built
	_pile_barrel.position = Vector3(-1.5, DECK_Y if built > 0 else 0.0, head_z - 2.2)
	_pile_plank.position = Vector3(1.5, DECK_Y if built > 0 else 0.0, head_z - 2.2)
	if built < SECTIONS:
		_lash_point.position = sections[built].position + Vector3(0, 0, 0)
	if usta:
		usta.position = Vector3(-1.4, DECK_Y if built > 0 else 0.0, head_z - 2.0)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH18_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH18_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = Vector3(0.8, 0.05, SHORE_Z - 3.5)
	player.face(Vector3(0, 1.0, 40.0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D18_N_01")
	await hud.say("SPK_USTA", "D18_U_01")
	await hud.say("SPK_TOLGA", "D18_T_01")
	await hud.say("SPK_USTA", "D18_U_02")
	player.frozen = false
	phase = "build"
	step = "barrels"
	_update_objective()
	if GameState.autotest:
		_auto()
	while built < SECTIONS:
		await get_tree().process_frame
	await _finish_bridge()
	await _end_chapter()


func _update_objective() -> void:
	if phase != "build":
		hud.set_objective("")
		return
	var k := "UI_OBJ18_" + step.to_upper()
	var target: Vector3 = {"barrels": _pile_barrel.global_position, "lash": _lash_point.global_position,
		"planks": _pile_plank.global_position}[step]
	hud.set_objective(tr(k) % [built + 1, SECTIONS], target + Vector3(0, 1.4, 0))


func _do_barrels() -> void:
	var s := sections[built]
	var b: Node3D = s.get_node("Barrels")
	b.visible = true
	var end := b.position
	b.position = end + Vector3(0, 1.2, -2.0)
	var tw := create_tween()
	tw.tween_property(b, "position", end, 0.6).set_ease(Tween.EASE_IN)
	Audio.sfx("splash", -4.0)
	step = "lash"
	lashes = 0
	hud.bark("SPK_USTA", "D18_U_BARRELS", 2.5)
	_update_objective()


func _start_lash() -> void:
	if _g >= 0.0:
		return
	_g = 0.0
	_g_dir = 1.0
	_g_center = randf_range(0.35, 0.75)
	player.frozen = true
	hud.set_prompt(tr("UI_PROMPT18_TIE"))


func _tie() -> void:
	if _g < 0.0:
		return
	var ok := absf(_g - _g_center) <= WIN
	_g = -1.0
	_gauge.queue_redraw()
	hud.set_prompt("")
	player.frozen = false
	lashes += 1
	if ok:
		Audio.sfx("land_pot", -8.0, 1.3)
	else:
		misses += 1
		Audio.sfx("cartoon_boing", -10.0)
		hud.bark("SPK_USTA", "D18_U_MISS_%d" % mini(misses, 3), 2.5)
		sections[built].rotation.z = deg_to_rad(randf_range(-4.0, 4.0))
	if lashes >= 2:
		sections[built].get_node("Rope").visible = true
		step = "planks"
	_update_objective()


func _do_planks() -> void:
	var s := sections[built]
	s.get_node("Deck").visible = true
	var solid: Node = s.get_node("Solid")
	solid.process_mode = Node.PROCESS_MODE_INHERIT
	for c in s.get_children():
		if c.name.begins_with("Rail"):
			c.visible = true
			c.process_mode = Node.PROCESS_MODE_INHERIT
	Audio.sfx("land_thud", -8.0, 1.1)
	built += 1
	if built in [2, 4]:
		hud.bark("SPK_USTA", "D18_U_SECTION_%d" % built, 3.0)
	elif built < SECTIONS:
		hud.bark("SPK_TOLGA", "D18_T_SECTION", 2.2)
	step = "barrels"
	_move_piles()
	_update_objective()


func _finish_bridge() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_USTA", "D18_U_DONE" if misses <= 2 else "D18_U_CROOKED")
	# Top köprüye çekilir
	var end := Vector3(0, DECK_Y, SHORE_Z + 2.0 + SEC_LEN * (SECTIONS - 1))
	cannon.position = Vector3(0, DECK_Y, SHORE_Z + 1.0)
	var tw := create_tween()
	tw.tween_property(cannon, "position", end, 4.0 if not GameState.autotest else 0.3)
	player.global_position = Vector3(2.8, 0.05, SHORE_Z - 2.0)
	player.face(end + Vector3(0, 1.0, 0))
	await hud.say("SPK_TOLGA", "D18_T_CANNON")
	await tw.finished
	player.frozen = false
	var target := Node3D.new()
	cannon.add_child(target)
	target.position = Vector3(0, 1.0, 0)
	hud.set_objective(tr("UI_OBJ18_PHOTO"), cannon.global_position + Vector3(0, 1.2, 0))
	cam = TespitCam.new(player, hud, target, "siege18")
	hud.add_child(cam)
	cam.max_dist = 40.0
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
	Audio.sfx("cannon", -2.0)
	Vfx.explosion(self, cannon.global_position + Vector3(0, 1.0, 2.2), 0.8)
	player.shake(0.4)
	await hud.say("SPK_USTA", "D18_U_END")
	await hud.say("SPK_TOLGA", "D18_T_END")
	await hud.say("SPK_NIHAT", "D18_N_END")
	_outcome = "18.1" if misses <= 2 else "18.2"
	Siege.record(18, _photo, "SIEGE_NOTE_18_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	if _g >= 0.0:
		_g += _g_dir * delta * 1.1
		if _g >= 1.0:
			_g = 1.0
			_g_dir = -1.0
		elif _g <= 0.0 and _g_dir < 0.0:
			_g = 0.0
			_g_dir = 1.0
		_gauge.queue_redraw()
	for i in built:
		sections[i].position.y = sin(_t * 1.2 + i * 0.7) * 0.03


func _draw_gauge() -> void:
	if _g < 0.0:
		return
	var vs := _gauge.size
	var r := Rect2(Vector2(vs.x * 0.5 - 200, vs.y * 0.62), Vector2(400, 18))
	_gauge.draw_rect(r.grow(3), Color(0, 0, 0, 0.5))
	_gauge.draw_rect(r, Color("2a2622"))
	_gauge.draw_rect(Rect2(r.position + Vector2(r.size.x * (_g_center - WIN), 0), Vector2(r.size.x * WIN * 2.0, r.size.y)), Color("5fcf6a"))
	var x := r.position.x + r.size.x * _g
	_gauge.draw_rect(Rect2(Vector2(x - 3, r.position.y - 6), Vector2(6, r.size.y + 12)), Color("fff3d6"))
	_gauge.draw_string(ThemeDB.fallback_font, r.position + Vector2(0, -12), tr("UI_CH18_ROPE"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("f2e6c9"))


func _unhandled_input(event: InputEvent) -> void:
	if _g >= 0.0 and event.is_action_pressed("interact"):
		_tie()
		get_viewport().set_input_as_handled()


func _on_focus(id: String) -> void:
	if phase != "build":
		hud.set_prompt("")
		return
	match id:
		"barrels":
			hud.set_prompt(tr("UI_PROMPT18_BARRELS") if step == "barrels" else "")
		"lash":
			hud.set_prompt(tr("UI_PROMPT18_LASH") if step == "lash" and _g < 0.0 else "")
		"planks":
			hud.set_prompt(tr("UI_PROMPT18_PLANKS") if step == "planks" else "")
		_:
			if _g < 0.0:
				hud.set_prompt("")


func _on_interact(id: String) -> void:
	if phase != "build":
		return
	match id:
		"barrels":
			if step == "barrels":
				_do_barrels()
		"lash":
			if step == "lash":
				_start_lash()
		"planks":
			if step == "planks":
				_do_planks()


func _auto() -> void:
	var bad := GameState.autotest_variant == "crooked"
	for i in SECTIONS:
		await get_tree().create_timer(0.1).timeout
		_on_interact("barrels")
		for k in 2:
			_on_interact("lash")
			_g_center = 0.5
			_g = 0.95 if bad else 0.5
			_tie()
		_on_interact("planks")


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(18, _outcome)
	await Siege.show_page(hud, 18)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(18)
			GameState.change_scene(nxt if nxt != "" else "res://scenes/main.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW18_TITLE")
	c.nodes = [
		{"id": "build", "key": "FLOW18_BUILD", "pos": Vector2(0.5, 0.14)},
		{"id": "18.1", "key": "FLOW_18_1", "pos": Vector2(0.3, 0.36), "outcome": true},
		{"id": "18.2", "key": "FLOW_18_2", "pos": Vector2(0.7, 0.36), "outcome": true},
		{"id": "cannon", "key": "FLOW18_CANNON", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["build", "18.1"], ["build", "18.2"], ["18.1", "cannon"], ["18.2", "cannon"]]
	for k in ["build", "cannon", _outcome]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH18_STATS") % [misses, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "18.1", "crooked": "18.2"}.get(v, "18.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("18", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and built == SECTIONS
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=18 variant=%s outcome=%s built=%d misses=%d" % ["PASS" if ok else "FAIL", v, _outcome, built, misses])
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
	phase = "build"
	for i in 3:
		step = "barrels"
		_do_barrels()
		lashes = 2
		sections[built].get_node("Rope").visible = true
		_do_planks()
	_do_barrels()
	player.global_position = Vector3(0.6, DECK_Y + 0.05, SHORE_Z + 2.0 + SEC_LEN * 2.6)
	await get_tree().create_timer(0.8).timeout
	player.face(_lash_point.global_position + Vector3(0, 0.3, 0))
	_g = 0.3
	_g_center = 0.55
	await _shot("c18_01_lash.png")
	_g = -1.0
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(9.0, 4.0, SHORE_Z - 6.0)
	cv.look_at(Vector3(0, 0.5, SHORE_Z + 10.0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c18_cover.png")
	get_tree().quit()
