extends Node3D
## Bölüm 25 — Son Akşam (Tolga · 27–28 Mayıs 1453). docs/SIEGE.md §3.
##
## İlk yarı (Osmanlı ordugâhı, 27 Mayıs gecesi): ordugâh kandillerle aydınlanmıştır. Tolga aşçı yamağıdır; otağa
## şerbet götürür, sonra otağın arka duvarının dibinde meclisi dinler: Çandarlı Halil barıştan (Batı'dan yardım
## gelir korkusu), Zağanos Paşa hücumdan yana; Sultan kararını verir: yarın oruç ve dinlenme, ertesi gün hücum.
## Nöbetçiler otağın çevresinde döner: görülen yamak mutfağa geri gönderilir. İki kez görülürse meclisin sonu kaçar.
## Tespit karesi: kandillerle ordugâh.
## İkinci yarı (Ayasofya, 28 Mayıs akşamı): Rum ve Latin aynı mekânda son ayin. İmparator helallik ister.
## Tolga bir mum yakabilir. Fotoğraf yok.
##   25.1 Meclis sonuna kadar dinlendi · 25.2 Meclisin sonu kaçtı (nöbetçiler)
##   --autotest[=caught]   (varsayılan: 25.1)

const OTAG := CampDay.OTAG_POS
const LISTEN_R := 7.7
const GUARD_R := 9.6
const COUNCIL := ["D25_H_1", "D25_Z_1", "D25_H_2", "D25_Z_2", "D25_F_1", "D25_F_2"]
const COUNCIL_SPK := ["SPK_HALIL", "SPK_ZAGANOS", "SPK_HALIL", "SPK_ZAGANOS", "SPK_FATIH", "SPK_FATIH"]
const LISTEN_TIME := 26.0
const AYA := Vector3(-14.0, 0.0, -82.0)

var day: CampDay
var city: ByzCity
var player: Player
var hud: Hud
var kadri: Person
var guards: Array[Soldier] = []
var _guard_a := [0.0, PI]
var door_guard: Soldier
var tray: Node3D
var phase := "intro"
var _outcome := ""
var _listen := 0.0
var _line := 0
var caught := 0
var _cool := 0.0
var _heard_all := false
var candle_lit := false
var _photo := ""
var cam: TespitCam
var emperor: Person
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(25)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(true)
	hud.set_signal(0)
	day = CampDay.new()
	add_child(day)
	day.make_night(true)
	_build_camp()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _gy(p: Vector3) -> Vector3:
	return Vector3(p.x, CampDay.height(p.x, p.z), p.z)


func _build_camp() -> void:
	# Otağın duvarı katı: içeri girilmez (dışarıdan dinlenir)
	var wall := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 7.15
	cyl.height = 6.0
	cs.shape = cyl
	wall.position = _gy(OTAG) + Vector3(0, 3.0, 0)
	wall.set_meta("no_climb", true)
	wall.add_child(cs)
	add_child(wall)
	kadri = Person.new({"face": "kadri", "coat": Color("f0e8d8"), "pants": Color("5a4028"), "hat": "cook", "mustache": true,
		"apron": Color("f0e8d8"), "skin": Color("d9a07a")})
	kadri.position = _gy(CampDay.KADRI_FRONT)
	add_child(kadri)
	kadri.look_target = player
	# Nöbetçiler: ikisi otağın çevresinde döner, biri kapıda durur
	for i in 2:
		var g := Soldier.new(Color("2f5fa8"), "stand", "bork")
		add_child(g)
		guards.append(g)
	door_guard = Soldier.new(Color("2f5fa8"), "stand", "bork")
	door_guard.position = _gy(OTAG + Vector3(1.8, 0, 9.6))
	add_child(door_guard)
	Props.interactable(self, "otag_door", Vector3(2.4, 2.4, 1.6), _gy(OTAG + Vector3(0, 0, 9.2)) + Vector3(0, 1.2, 0))
	# Dinleme yerleri: otağın arkası (kapının tersi); küçük kazık işaretleri
	for a: float in [150.0, 180.0, 210.0]:
		var r := deg_to_rad(a)
		var p := _gy(OTAG + Vector3(sin(r) * LISTEN_R, 0, cos(r) * LISTEN_R))
		Props.cyl(self, 0.05, 0.6, p + Vector3(0, 0.3, 0), Color("6a4a2c"), Vector3.ZERO, 5)
	_place_guards(0.0)


func _place_guards(delta: float) -> void:
	for i in guards.size():
		_guard_a[i] = fposmod(_guard_a[i] + delta * 0.16, TAU)
		var a: float = _guard_a[i]
		guards[i].position = _gy(OTAG + Vector3(sin(a) * GUARD_R, 0, cos(a) * GUARD_R))
		guards[i].rotation.y = a + PI * 0.5


## Tolga dinleme yerinde mi (otağın arka yarısında, duvara yakın)?
func _at_wall() -> bool:
	var p := player.global_position - OTAG
	p.y = 0.0
	var r := p.length()
	return r < LISTEN_R + 0.9 and p.z < -2.5


## Bir nöbetçi Tolga'yı görüyor mu (yakın ve önünde)?
func _seen() -> bool:
	for g in guards:
		var to := player.global_position - g.global_position
		to.y = 0.0
		if to.length() > 4.2:
			continue
		var fwd := Vector3(sin(g.rotation.y), 0, cos(g.rotation.y))
		if fwd.dot(to.normalized()) > 0.3:
			return true
	return false


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH25_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH25_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = _gy(CampDay.KITCHEN_SPAWN) + Vector3(0, 0.05, 0)
	player.face(kadri.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D25_N_01")
	await hud.say("SPK_KADRI", "D25_K_01")
	await hud.say("SPK_TOLGA", "D25_T_01")
	await hud.say("SPK_KADRI", "D25_K_02")
	_give_tray()
	player.frozen = false
	phase = "tray"
	hud.set_objective(tr("UI_OBJ25_TRAY"), _gy(OTAG + Vector3(0, 0, 9.2)) + Vector3(0, 1.6, 0))
	if GameState.autotest:
		_on_interact("otag_door")
	while phase == "tray":
		await get_tree().process_frame
	await _listen_phase()
	await _lights()
	await _liturgy()
	await _end_chapter()


func _give_tray() -> void:
	tray = Node3D.new()
	tray.position = Vector3(0.0, -0.5, -0.75)
	player.camera.add_child(tray)
	Props.cyl(tray, 0.32, 0.03, Vector3.ZERO, Color("c8a040"), Vector3.ZERO, 16)
	for k in 4:
		Props.cyl(tray, 0.05, 0.1, Vector3(-0.15 + k * 0.1, 0.06, 0.05 * (k % 2)), Color("c8e0f0"), Vector3.ZERO, 8)
	Props.strip_outlines(tray)


func _listen_phase() -> void:
	phase = "listen"
	hud.set_objective(tr("UI_OBJ25_LISTEN"), _gy(OTAG + Vector3(0, 0, -LISTEN_R)) + Vector3(0, 1.4, 0))
	hud.bark("SPK_TOLGA", "D25_T_LISTEN", 3.5)
	if GameState.autotest:
		if GameState.autotest_variant == "caught":
			for i in 2:
				_caught_once()
		else:
			player.global_position = _gy(OTAG + Vector3(0, 0, -LISTEN_R)) + Vector3(0, 0.05, 0)
			_listen = LISTEN_TIME
			_line = COUNCIL.size()
			_heard_all = true
	while phase == "listen":
		await get_tree().process_frame
	hud.set_chase("", 0.0)
	hud.set_objective("")
	hud.set_prompt("")
	player.frozen = true


func _caught_once() -> void:
	caught += 1
	_cool = 2.0
	Audio.sfx("crowd_gasp", -8.0, 1.2)
	hud.bark("SPK_SOLDIER", "D25_G_CAUGHT_%d" % mini(caught, 2), 3.0)
	player.global_position = _gy(OTAG + Vector3(0, 0, 16.0)) + Vector3(0, 0.05, 0)
	player.face(_gy(OTAG) + Vector3(0, 2.0, 0))
	if caught >= 2:
		phase = "listened"


func _lights() -> void:
	# Meclis dağılır; Sultan ordugâhı dolaşır, kandiller yanar. Tespit karesi.
	player.global_position = _gy(OTAG + Vector3(4.0, 0, 18.0)) + Vector3(0, 0.05, 0)
	player.face(_gy(OTAG + Vector3(0, 0, 40.0)) + Vector3(0, 3.0, 0))
	await hud.say("SPK_TOLGA", "D25_T_HEARD" if _heard_all else "D25_T_HALF")
	await hud.say("SPK_NIHAT", "D25_N_LIGHTS")
	var target := Node3D.new()
	add_child(target)
	target.global_position = Vector3(0.0, 4.0, 20.0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ25_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege25")
	hud.add_child(cam)
	cam.max_dist = 200.0
	cam.cone_deg = 25.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 45.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D25_T_LIGHTS")


## 28 Mayıs akşamı, Ayasofya: son ayin. Rum ve Latin birlikte. İmparator helallik ister.
func _liturgy() -> void:
	await hud.fade_to(1.0, 1.0)
	if tray:
		tray.queue_free()
		tray = null
	day.queue_free()
	day = null
	guards.clear()
	await get_tree().process_frame
	city = ByzCity.new()
	add_child(city)
	city.niko.visible = false
	city.emperor.visible = false
	city.make_sunset()
	hud.set_fez(false)
	var rng := RandomNumberGenerator.new()
	rng.seed = 528
	for i in 22:
		var latin := i % 4 == 0
		var p := Person.new({"coat": ([Color("5a3a2a"), Color("3a4a5a"), Color("6a5a4a"), Color("4a3a4a")][i % 4]) if not latin else Color("2a3a6a"),
			"pants": Color("2a2a2a"), "skirt": i % 3 == 1, "hat": "berretta" if latin else "none", "hair": Color("3a2a1e"),
			"beard": i % 5 == 0, "mustache": i % 2 == 0})
		p.set_meta("no_talk", true)
		p.position = AYA + Vector3(rng.randf_range(-6.0, 6.0), 0, rng.randf_range(-6.0, 4.0))
		p.rotation.y = PI + rng.randf_range(-0.3, 0.3)
		add_child(p)
	var isidore := Person.new({"coat": Color("b3262d"), "robe": Color("b3262d"), "hat": "galero", "face": "cardinal", "beard": true,
		"hair": Color("e8e8e8"), "skin": Color("e8c0a0")})
	isidore.position = AYA + Vector3(3.5, 0, -8.0)
	isidore.rotation.y = PI
	add_child(isidore)
	# Mumluk: kum dolu tepsi, yanan ince mumlar; bir tane boş yer
	var stand := AYA + Vector3(-5.5, 0, 7.5)
	Props.cyl(self, 0.05, 1.0, stand + Vector3(0, 0.5, 0), Color("c8a040"), Vector3.ZERO, 6)
	Props.cyl(self, 0.5, 0.08, stand + Vector3(0, 1.02, 0), Color("c8a040"), Vector3.ZERO, 16)
	for k in 9:
		var a := k * TAU / 9.0
		var cp := stand + Vector3(sin(a) * 0.35, 1.15, cos(a) * 0.35)
		Props.cyl(self, 0.012, 0.2, cp, Color("f4ecd0"), Vector3.ZERO, 5)
		var fl := Props.ball(self, 0.02, cp + Vector3(0, 0.12, 0), Color("ffc860"), Vector3(1, 1.6, 1), 5, 3.0)
		fl.material_override = Props.mat(Color("ffc860"), 3.0, false, "", false)
	var cl := OmniLight3D.new()
	cl.position = stand + Vector3(0, 1.5, 0)
	cl.light_color = Color("ffc070")
	cl.light_energy = 1.2
	cl.omni_range = 5.0
	add_child(cl)
	Props.interactable(self, "candle", Vector3(1.2, 1.4, 1.2), stand + Vector3(0, 1.0, 0))
	emperor = Person.new({"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "stemma", "face": "emperor", "beard": true,
		"mustache": true, "hair": Color("6a6a6a"), "robe": Color("5a2a6a")})
	emperor.position = AYA + Vector3(0, 0, 16.0)
	emperor.rotation.y = PI
	add_child(emperor)
	player.global_position = AYA + Vector3(-4.0, 0.05, 9.0)
	player.face(AYA + Vector3(0, 5.0, -8.0))
	await hud.card([[tr("UI_CH25_AYA"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 1.5)
	Audio.sfx("church_bell", -8.0, 0.7)
	await hud.say("SPK_NIHAT", "D25_N_AYA")
	await hud.say("SPK_TOLGA", "D25_T_AYA")
	# İmparator girer, ortaya yürür
	var tw := create_tween()
	tw.tween_property(emperor, "position", AYA + Vector3(0, 0, 4.0), 5.0)
	await tw.finished
	player.face(emperor.global_position + Vector3(0, 1.6, 0))
	emperor.talking = true
	await hud.say("SPK_EMPEROR", "D25_K_1")
	await hud.say("SPK_EMPEROR", "D25_K_2")
	emperor.talking = false
	await hud.say("SPK_ISIDORE", "D25_I_1")
	# Mum: isteğe bağlı
	player.frozen = false
	hud.set_objective(tr("UI_OBJ25_CANDLE"), stand + Vector3(0, 1.4, 0))
	var t := 0.0
	if GameState.autotest:
		_on_interact("candle")
	while not candle_lit and t < 30.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	player.frozen = true
	hud.set_objective("")
	hud.set_prompt("")
	var out := create_tween()
	out.tween_property(emperor, "position", AYA + Vector3(0, 0, 20.0), 5.0)
	await hud.say("SPK_TOLGA", "D25_T_EMPEROR")
	await out.finished
	emperor.visible = false
	await hud.say("SPK_NIHAT", "D25_N_END")
	_outcome = "25.1" if _heard_all else "25.2"
	GameState.flags["siege_candle"] = candle_lit
	Siege.record(25, _photo, "SIEGE_NOTE_25_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	if day == null:
		return
	_place_guards(delta)
	if phase != "listen":
		return
	_cool = maxf(0.0, _cool - delta)
	if _cool <= 0.0 and _seen():
		_caught_once()
		return
	var near := _at_wall()
	hud.set_prompt(tr("UI_PROMPT25_LISTEN") if near else "")
	if near:
		_listen += delta
		hud.set_chase(tr("UI_CH25_LISTEN"), _listen / LISTEN_TIME)
		var want := int(_listen / LISTEN_TIME * COUNCIL.size())
		if want > _line and _line < COUNCIL.size():
			hud.bark(COUNCIL_SPK[_line], COUNCIL[_line], 4.2)
			_line += 1
		if _listen >= LISTEN_TIME:
			_heard_all = true
			phase = "listened"


func _on_focus(id: String) -> void:
	match id:
		"otag_door":
			hud.set_prompt(tr("UI_PROMPT25_TRAY") if phase == "tray" else "")
		"candle":
			hud.set_prompt(tr("UI_PROMPT25_CANDLE") if not candle_lit else "")
		_:
			if phase != "listen":
				hud.set_prompt("")


func _on_interact(id: String) -> void:
	match id:
		"otag_door":
			if phase != "tray":
				return
			if tray:
				tray.queue_free()
				tray = null
			hud.bark("SPK_SOLDIER", "D25_G_TRAY", 3.0)
			phase = "delivered"
		"candle":
			if candle_lit:
				return
			candle_lit = true
			player.hand_gesture("reach")
			var fl := Props.ball(self, 0.025, AYA + Vector3(-5.5, 2.27, 7.5), Color("ffc860"), Vector3(1, 1.6, 1), 5, 3.0)
			fl.material_override = Props.mat(Color("ffc860"), 3.0, false, "", false)
			Props.cyl(self, 0.012, 0.2, AYA + Vector3(-5.5, 2.15, 7.5), Color("f4ecd0"), Vector3.ZERO, 5)
			hud.bark("SPK_TOLGA", "D25_T_CANDLE", 3.0)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(25, _outcome)
	await Siege.show_page(hud, 25)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(25)
			GameState.change_scene(nxt if nxt != "" else "res://scenes/main.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW25_TITLE")
	c.nodes = [
		{"id": "tray", "key": "FLOW25_TRAY", "pos": Vector2(0.5, 0.12)},
		{"id": "25.1", "key": "FLOW_25_1", "pos": Vector2(0.3, 0.32), "outcome": true},
		{"id": "25.2", "key": "FLOW_25_2", "pos": Vector2(0.7, 0.32), "outcome": true},
		{"id": "liturgy", "key": "FLOW25_LITURGY", "pos": Vector2(0.5, 0.52)},
		{"id": "candle", "key": "FLOW25_CANDLE", "pos": Vector2(0.5, 0.68)},
	]
	c.edges = [["tray", "25.1"], ["tray", "25.2"], ["25.1", "liturgy"], ["25.2", "liturgy"], ["liturgy", "candle"]]
	for k in ["tray", "liturgy", _outcome]:
		c.taken[k] = true
	if candle_lit:
		c.taken["candle"] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH25_STATS") % [caught, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "25.1", "caught": "25.2"}.get(v, "25.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("25", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and candle_lit
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=25 variant=%s outcome=%s caught=%d candle=%s" % ["PASS" if ok else "FAIL", v, _outcome, caught, candle_lit])
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
	phase = "listen"
	player.global_position = _gy(OTAG + Vector3(2.0, 0, -LISTEN_R - 0.3)) + Vector3(0, 0.05, 0)
	await get_tree().create_timer(0.8).timeout
	player.face(guards[0].global_position + Vector3(0, 1.4, 0))
	hud.set_chase(tr("UI_CH25_LISTEN"), 0.45)
	hud.bark("SPK_ZAGANOS", "D25_Z_1", 30.0)
	await _shot("c25_01_listen.png")
	phase = "shots"
	hud.set_chase("", 0.0)
	player.global_position = _gy(OTAG + Vector3(4.0, 0, 18.0)) + Vector3(0, 0.05, 0)
	player.face(Vector3(0.0, 4.0, 20.0))
	await _shot("c25_02_lights.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = _gy(OTAG + Vector3(10.0, 0, 22.0)) + Vector3(0, 5.0, 0)
	cv.look_at(_gy(OTAG) + Vector3(0, 4.0, 0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c25_cover.png")
	get_tree().quit()
