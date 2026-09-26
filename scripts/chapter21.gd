extends Node3D
## Bölüm 21 — Lağım (Tolga · 16 Mayıs 1453, Mesoteichion ve toprağın altı). docs/SIEGE.md §3.
##
## Zağanos Paşa'nın Novo Brdo'lu madencileri surların altına lağım kazar; mühendis Johannes Grant karşı lağımla
## bulur (ilki 16 Mayıs gecesi; kaynaklar yere konan su kaplarının kazı titreşimiyle dalgalandığını anlatır).
## Oynanış 1: Peribolosta dört su kabı. Tolga'nın telefonundaki deprem uygulaması (şarjı powerbank'ten) sıcak-soğuk
##   gösterir; kabı toprağa koy (E), en çok dalgalanan kabın altı lağımdır. Tespit karesi: Grant'in su kapları.
## Oynanış 2: Karşı lağım: mum ışığında dar tünel. Kazı yüzünü dinle; duvar açılır, karşıda bir madenci.
##   İki taraf da karanlıkta bir an durur ve geri çekilir. Grant'in adamları tüneli ateşle kapatır (kimse içeride değil).
##   21.1 Lağımı Tolga'nın kabı buldu · 21.2 Kaplar tükendi, Grant kendisi buldu
##   --autotest[=grant]   (varsayılan: 21.1)

const MINE := Vector3(-9.0, 0.0, 7.0)
const BOWLS := 4
const FOUND_R := 2.6
const TUN := Vector3(60.0, -30.0, 0.0)
const TUN_LEN := 16.0

var walls: LandWalls
var player: Player
var hud: Hud
var grant: Person
var miner: Person
var phase := "intro"
var _outcome := ""
var bowls_left := BOWLS
var bowls: Array = []           # {node, ripple, strength}
var found := false
var found_by_bowl := false
var _photo := ""
var cam: TespitCam
var _meter: Control
var _heat := 0.0
var _face: Node3D
var _tunnel_lights: Array = []
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(21)
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
	grant = Person.new({"coat": Color("5a5a62"), "pants": Color("3a3a40"), "hat": "none", "beard": true, "hair": Color("8a5a2a"),
		"apron": Color("3a3028"), "skin": Color("e8b894")})
	grant.set_meta("spk", "SPK_GRANT")
	grant.position = Vector3(-4.0, 0, 3.0)
	add_child(grant)
	grant.look_target = player
	# Grant'in kendi kapları (sırada bekleyen, boş)
	for i in 4:
		Props.cyl(self, 0.22, 0.12, Vector3(-5.2 + i * 0.5, 0.06, 1.8), Color("9a6a40"), Vector3.ZERO, 10, 0.27)
	# Telefon deprem ölçeri (sağ alt): titreşim çizgisi ve sıcaklık çubuğu
	_meter = Control.new()
	_meter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_meter.visible = false
	_meter.draw.connect(_draw_meter)
	hud.add_child(_meter)
	_build_tunnel()


## Karşı lağım: dar, destekli, mumlu bir tünel ve sonunda kazı yüzü.
func _build_tunnel() -> void:
	var t := TUN
	Props.solid(self, Vector3(2.6, 0.2, TUN_LEN + 6.0), t + Vector3(0, -0.1, -TUN_LEN * 0.5), Color("4a3828"))
	Props.solid(self, Vector3(2.6, 0.2, TUN_LEN + 6.0), t + Vector3(0, 2.3, -TUN_LEN * 0.5), Color("2a1e14"))
	for sx: float in [-1.2, 1.2]:
		Props.set_pattern(Props.solid(self, Vector3(0.2, 2.4, TUN_LEN + 6.0), t + Vector3(sx, 1.1, -TUN_LEN * 0.5), Color.WHITE), Color("5a4430"), "plaster")
	Props.solid(self, Vector3(2.6, 2.4, 0.3), t + Vector3(0, 1.1, 2.8), Color("3a2a1e"))
	var z := 0.0
	while z > -TUN_LEN:
		for sx: float in [-1.0, 1.0]:
			Props.cyl(self, 0.08, 2.2, t + Vector3(sx, 1.1, z), Color("6a4a2c"), Vector3.ZERO, 5)
		Props.box(self, Vector3(2.2, 0.16, 0.16), t + Vector3(0, 2.15, z), Color("6a4a2c"))
		z -= 2.5
	for i in 4:
		var cp := t + Vector3(-0.95 if i % 2 == 0 else 0.95, 1.2, -1.5 - i * 4.0)
		Props.cyl(self, 0.03, 0.18, cp, Color("f4ecd0"), Vector3.ZERO, 5)
		var fl := Props.ball(self, 0.03, cp + Vector3(0, 0.12, 0), Color("ffc860"), Vector3(1, 1.6, 1), 5, 3.0)
		fl.material_override = Props.mat(Color("ffc860"), 3.0, false, "", false)
		var l := OmniLight3D.new()
		l.position = cp + Vector3(0, 0.3, 0)
		l.light_color = Color("ffb060")
		l.light_energy = 1.4
		l.omni_range = 5.0
		add_child(l)
		_tunnel_lights.append(l)
	_face = Node3D.new()
	_face.position = t + Vector3(0, 0, -TUN_LEN - 0.2)
	add_child(_face)
	Props.set_pattern(Props.solid(_face, Vector3(2.4, 2.4, 0.4), Vector3(0, 1.1, 0), Color.WHITE), Color("5a4430"), "plaster")
	Props.interactable(_face, "face", Vector3(2.0, 2.0, 0.8), Vector3(0, 1.1, 0.5))
	# Kazı yüzünün ardı: kısa Osmanlı lağımı (kapalı, karanlık), madenci
	var ot := t + Vector3(0, 0, -TUN_LEN - 3.4)
	Props.solid(self, Vector3(2.4, 0.2, 6.0), ot + Vector3(0, -0.1, 0), Color("3a2a1e"))
	Props.solid(self, Vector3(2.4, 0.2, 6.0), ot + Vector3(0, 2.3, 0), Color("22180f"))
	for sx: float in [-1.1, 1.1]:
		Props.solid(self, Vector3(0.2, 2.4, 6.0), ot + Vector3(sx, 1.1, 0), Color("3a2a1e"))
	Props.solid(self, Vector3(2.4, 2.4, 0.2), ot + Vector3(0, 1.1, -3.0), Color("22180f"))
	for bz: float in [-1.5, 0.5, 2.5]:
		Props.box(self, Vector3(2.0, 0.14, 0.14), ot + Vector3(0, 2.1, bz), Color("5a3e26"))
	# Kazı yüzünün ardı: Osmanlı lağımı ve madenci (duvar açılınca görünür)
	miner = Person.new({"coat": Color("6a5a48"), "pants": Color("3a3028"), "hat": "none", "beard": true, "mustache": true,
		"hair": Color("4a3a2a"), "apron": Color("4a3a2a"), "skin": Color("c89070")})
	miner.set_meta("spk", "SPK_NOVOMINER")
	miner.position = t + Vector3(0.2, 0, -TUN_LEN - 2.2)
	miner.visible = false
	add_child(miner)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH21_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH21_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = Vector3(-2.0, 0.05, 5.0)
	player.face(grant.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_GRANT", "D21_G_01")
	await hud.say("SPK_TOLGA", "D21_T_01")
	await hud.say("SPK_GRANT", "D21_G_02")
	await hud.say("SPK_NIHAT", "D21_N_01")
	phase = "bowls"
	_meter.visible = true
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		_auto_bowls()
	while phase == "bowls":
		await get_tree().process_frame
	player.frozen = true
	await _found()
	await _tunnel()
	await _end_chapter()


func _update_objective() -> void:
	if phase == "bowls":
		hud.set_objective(tr("UI_OBJ21_BOWLS") % bowls_left)


func _place_bowl(at: Vector3) -> void:
	if bowls_left <= 0 or phase != "bowls":
		return
	bowls_left -= 1
	var b := Node3D.new()
	b.position = Vector3(at.x, 0.0, at.z)
	add_child(b)
	Props.cyl(b, 0.22, 0.12, Vector3(0, 0.06, 0), Color("9a6a40"), Vector3.ZERO, 10, 0.27)
	var water := Props.cyl(b, 0.2, 0.01, Vector3(0, 0.115, 0), Color("4a78a8"), Vector3.ZERO, 12)
	var ripple := Props.ring(b, 0.05, 0.08, Vector3(0, 0.125, 0), Color("c8e0f8"), Vector3(90, 0, 0))
	var d := Vector2(at.x - MINE.x, at.z - MINE.z).length()
	var strength := clampf(1.0 - d / 10.0, 0.0, 1.0)
	bowls.append({"node": b, "water": water, "ripple": ripple, "strength": strength})
	player.hand_gesture("reach")
	Audio.sfx("splash", -18.0, 1.6)
	if d <= FOUND_R:
		found = true
		found_by_bowl = true
		phase = "found"
	elif bowls_left <= 0:
		found = true
		phase = "found"
	else:
		var key := "D21_T_WARM" if strength > 0.55 else ("D21_T_TEPID" if strength > 0.25 else "D21_T_COLD")
		hud.bark("SPK_TOLGA", key, 2.5)
	_update_objective()


func _found() -> void:
	hud.set_objective("")
	if found_by_bowl:
		await get_tree().create_timer(0.6).timeout
		await hud.say("SPK_GRANT", "D21_G_FOUND")
	else:
		await hud.say("SPK_GRANT", "D21_G_SELF")
		var b := Node3D.new()
		b.position = MINE
		add_child(b)
		Props.cyl(b, 0.22, 0.12, Vector3(0, 0.06, 0), Color("9a6a40"), Vector3.ZERO, 10, 0.27)
		var water := Props.cyl(b, 0.2, 0.01, Vector3(0, 0.115, 0), Color("4a78a8"), Vector3.ZERO, 12)
		var ripple := Props.ring(b, 0.05, 0.08, Vector3(0, 0.125, 0), Color("c8e0f8"), Vector3(90, 0, 0))
		bowls.append({"node": b, "water": water, "ripple": ripple, "strength": 1.0})
	# Tespit karesi: dalgalanan kap
	var best: Dictionary = bowls[0]
	for bw in bowls:
		if bw["strength"] > best["strength"]:
			best = bw
	var target: Node3D = best["node"]
	player.frozen = false
	hud.set_objective(tr("UI_OBJ21_PHOTO"), target.global_position + Vector3(0, 0.3, 0))
	cam = TespitCam.new(player, hud, target, "siege21")
	hud.add_child(cam)
	cam.max_dist = 6.0
	cam.cone_deg = 16.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	_meter.visible = false
	await hud.say("SPK_GRANT", "D21_G_DIG")


func _tunnel() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH21_TUNNEL"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	phase = "tunnel"
	var e := walls.env.environment
	e.ambient_light_color = Color("5a3a24")
	e.ambient_light_energy = 0.2
	walls.moon.light_energy = 0.0
	player.global_position = TUN + Vector3(0, 0.05, 1.5)
	player.face(TUN + Vector3(0, 1.2, -TUN_LEN))
	grant.global_position = TUN + Vector3(0.6, 0, 2.2)
	grant.rotation.y = PI
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_GRANT", "D21_G_TUNNEL")
	await hud.say("SPK_NIHAT", "D21_N_MAP")
	await hud.say("SPK_TOLGA", "D21_T_MAP")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ21_FACE"), _face.global_position + Vector3(0, 1.2, 0))
	if GameState.autotest:
		_on_interact("face")
	while phase == "tunnel":
		await get_tree().process_frame
	player.frozen = true
	hud.set_objective("")
	# Duvar açılır: karşıda madenci, elinde kandil
	Audio.sfx("land_thud", 0.0, 0.7)
	Vfx.dust(self, _face.global_position + Vector3(0, 1.2, 0.3), 1.2)
	_face.visible = false
	for c in _face.get_children():
		if c is StaticBody3D:
			c.queue_free()
	miner.visible = true
	miner.global_position = TUN + Vector3(0.2, 0, -TUN_LEN - 1.4)
	miner.face_toward(player.global_position)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0.3, 1.3, 0.4)
	lamp.light_color = Color("ffb060")
	lamp.light_energy = 1.6
	lamp.omni_range = 5.0
	miner.add_child(lamp)
	player.face(miner.global_position + Vector3(0, 1.5, 0))
	await get_tree().create_timer(0.8).timeout
	await hud.say("SPK_NOVOMINER", "D21_M_1")
	await hud.say("SPK_TOLGA", "D21_T_FACE")
	var c := await hud.choose(["UI_C21_WAVE", "UI_C21_LEB"], 0.0, 0)
	if c == 1 and "chickpeas" in GameState.bag:
		await hud.say("SPK_TOLGA", "D21_T_LEB")
		await hud.say("SPK_NOVOMINER", "D21_M_LEB")
	else:
		await hud.say("SPK_TOLGA", "D21_T_WAVE")
		await hud.say("SPK_NOVOMINER", "D21_M_WAVE")
	miner.leave(player.global_position, 6.0, 2.0, true)
	await hud.say("SPK_GRANT", "D21_G_BACK")
	await hud.fade_to(1.0, 0.8)
	# Tünel ateşle kapatılır (kimse içeride değil)
	player.global_position = TUN + Vector3(0, 0.05, 1.8)
	player.face(TUN + Vector3(0, 1.0, -8.0))
	var fire := OmniLight3D.new()
	fire.position = TUN + Vector3(0, 1.2, -6.0)
	fire.light_color = Color("ff7a2a")
	fire.light_energy = 6.0
	fire.omni_range = 14.0
	add_child(fire)
	for i in 6:
		var f := Props.cyl(self, 0.35, 1.6, TUN + Vector3(randf_range(-0.8, 0.8), 0.8, -4.0 - i * 1.6), Color("ffa030"), Vector3.ZERO, 6, 0.05, 3.0)
		f.material_override = Props.mat(Color("ff9a30"), 3.5, false, "", false)
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_GRANT", "D21_G_FIRE")
	await hud.say("SPK_TOLGA", "D21_T_END")
	await hud.say("SPK_NIHAT", "D21_N_END")
	_outcome = "21.1" if found_by_bowl else "21.2"
	Siege.record(21, _photo, "SIEGE_NOTE_21_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	for bw in bowls:
		var s: float = bw["strength"]
		var r: MeshInstance3D = bw["ripple"]
		var k := fmod(_t * (0.8 + s * 2.2), 1.0)
		r.scale = Vector3.ONE * (0.4 + k * 2.2 * (0.3 + s))
		(bw["water"] as Node3D).position.y = 0.115 + sin(_t * 30.0) * 0.004 * s
	if phase == "bowls":
		var d := Vector2(player.global_position.x - MINE.x, player.global_position.z - MINE.z).length()
		_heat = lerpf(_heat, clampf(1.0 - d / 14.0, 0.0, 1.0), delta * 3.0)
		_meter.queue_redraw()
	for i in _tunnel_lights.size():
		(_tunnel_lights[i] as OmniLight3D).light_energy = 1.3 + sin(_t * 7.0 + i) * 0.15


func _draw_meter() -> void:
	var vs := _meter.size
	var r := Rect2(Vector2(vs.x - 330, vs.y - 230), Vector2(300, 120))
	_meter.draw_rect(r, Color(0.05, 0.06, 0.08, 0.85))
	_meter.draw_rect(r, Color("7fd3ff"), false, 2.0)
	_meter.draw_string(ThemeDB.fallback_font, r.position + Vector2(10, 22), tr("UI_CH21_APP"), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("7fd3ff"))
	var pts := PackedVector2Array()
	for i in 60:
		var x := r.position.x + 10 + i * 4.7
		var amp := 4.0 + _heat * 34.0
		var y := r.position.y + 70 + sin(_t * 18.0 + i * 0.9) * amp * (0.4 + 0.6 * sin(i * 0.37 + _t * 3.0))
		pts.append(Vector2(x, y))
	_meter.draw_polyline(pts, Color("5fcf6a").lerp(Color("ff5a4a"), _heat), 2.0)
	_meter.draw_rect(Rect2(r.position + Vector2(10, 100), Vector2(280 * _heat, 8)), Color("ff9a4a"))


func _unhandled_input(event: InputEvent) -> void:
	# Kabı toprağa koymak: bakılan bir şey yokken E
	if phase == "bowls" and event.is_action_pressed("interact") and player.focus_id == "" and not player.frozen:
		var fwd := -player.global_transform.basis.z
		fwd.y = 0.0
		_place_bowl(player.global_position + fwd.normalized() * 0.9)
		get_viewport().set_input_as_handled()


func _auto_bowls() -> void:
	await get_tree().create_timer(0.3).timeout
	if GameState.autotest_variant == "grant":
		for p: Vector3 in [Vector3(8, 0, 4), Vector3(10, 0, 2), Vector3(6, 0, 10), Vector3(12, 0, 8)]:
			_place_bowl(p)
	else:
		_place_bowl(Vector3(2, 0, 4))
		_place_bowl(MINE + Vector3(1.2, 0, 0.5))


func _on_focus(id: String) -> void:
	hud.set_prompt(tr("UI_PROMPT21_FACE") if id == "face" and phase == "tunnel" else "")


func _on_interact(id: String) -> void:
	if id == "face" and phase == "tunnel":
		phase = "breach"
		Audio.sfx("timer_tick", -6.0, 0.6)
		hud.bark("SPK_TOLGA", "D21_T_LISTEN", 2.5)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(21, _outcome)
	await Siege.show_page(hud, 21)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(21)
			GameState.change_scene(nxt if nxt != "" else "res://scenes/main.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW21_TITLE")
	c.nodes = [
		{"id": "bowls", "key": "FLOW21_BOWLS", "pos": Vector2(0.5, 0.12)},
		{"id": "21.1", "key": "FLOW_21_1", "pos": Vector2(0.3, 0.32), "outcome": true},
		{"id": "21.2", "key": "FLOW_21_2", "pos": Vector2(0.7, 0.32), "outcome": true},
		{"id": "tunnel", "key": "FLOW21_TUNNEL", "pos": Vector2(0.5, 0.52)},
	]
	c.edges = [["bowls", "21.1"], ["bowls", "21.2"], ["21.1", "tunnel"], ["21.2", "tunnel"]]
	for k in ["bowls", "tunnel", _outcome]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH21_STATS") % [BOWLS - bowls_left, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "21.1", "grant": "21.2"}.get(v, "21.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("21", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=21 variant=%s outcome=%s bowls=%d" % ["PASS" if ok else "FAIL", v, _outcome, BOWLS - bowls_left])
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
	phase = "bowls"
	_meter.visible = true
	_place_bowl(Vector3(-5.0, 0, 6.0))
	_place_bowl(MINE + Vector3(3.5, 0, 0.0))
	player.global_position = MINE + Vector3(4.2, 0.05, 2.4)
	await get_tree().create_timer(0.8).timeout
	player.face(MINE + Vector3(3.5, 0.0, 0.0))
	_heat = 0.7
	await _shot("c21_01_bowls.png")
	_meter.visible = false
	phase = "shots"
	player.global_position = TUN + Vector3(0, 0.05, -TUN_LEN + 1.6)
	var e := walls.env.environment
	e.ambient_light_color = Color("5a3a24")
	e.ambient_light_energy = 0.2
	walls.moon.light_energy = 0.0
	_face.visible = false
	miner.visible = true
	miner.global_position = TUN + Vector3(0.2, 0, -TUN_LEN - 1.4)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0.3, 1.3, 0.4)
	lamp.light_color = Color("ffb060")
	lamp.light_energy = 1.6
	lamp.omni_range = 5.0
	miner.add_child(lamp)
	miner.face_toward(player.global_position)
	await get_tree().create_timer(0.4).timeout
	player.face(miner.global_position + Vector3(0, 1.5, 0))
	await _shot("c21_02_miner.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = TUN + Vector3(0.7, 1.5, -TUN_LEN + 3.0)
	cv.look_at(miner.global_position + Vector3(0, 1.3, 0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c21_cover.png")
	get_tree().quit()
