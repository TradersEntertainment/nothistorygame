extends Node3D
## Bölüm 24 — Alametler (Tolga · 24–25 Mayıs 1453, Konstantinopolis). docs/SIEGE.md §3.
##
## Hodegetria ikonası şehirde gezdirilir; fırtına ve dolu başlar, ikona taşıyıcısından kayar (kaynaklarda
## 23–24 Mayıs). Ertesi gün şehir sise gömülür, akşam Ayasofya'nın kubbesinde kızıl bir ışık görülür.
## Oynanış 1: Tolga sedyenin arka sırığını taşır; rüzgâra karşı denge (A/D). Ne yaparsa yapsın ikona bir an kayar
##   (tarih inatçıdır; bu espri konusu değildir). Sonra selde kalan bir çocuğu saçak altına götürür.
## Oynanış 2: Sisli şehir, tırmanma açık. Akşam kubbede ışık: tespit karesi. Tolga'nın feneri kapalıdır.
##   24.1 Çocuk saçağa alındı · 24.2 Çocuğa yetişilemedi, kendi koştu
##   --autotest[=late]   (varsayılan: 24.1)

const ROUTE_A := Vector3(0.0, 0.0, -24.0)
const ROUTE_B := Vector3(0.0, 0.0, 6.0)
const SLIP_AT := 0.72
const KID_POS := Vector3(-4.2, 0.0, 2.0)
const SHELTER := Vector3(5.2, 0.0, 3.5)
const DOME_LIGHT := Vector3(-14.0, 34.0, -82.0)
const DOME_TOP := Vector3(-14.0, 22.5, -82.0)
const KID_TIME := 22.0
const FOG_START := Vector3(-12.0, 0.05, -44.0)

var city: ByzCity
var player: Player
var hud: Hud
var litter: Node3D
var icon: Node3D
var bearers: Array[Person] = []
var crowd: Array[Person] = []
var kid: Person
var meter: BalanceMeter
var rain: CPUParticles3D
var hail: CPUParticles3D
var dome_light: Node3D
var phase := "intro"
var _outcome := ""
var _route := 0.0
var _balance := 0.0
var _gust := 0.0
var _gust_t := 2.0
var stumbles := 0
var _kid_follow := false
var _kid_saved := false
var _photo := ""
var cam: TespitCam
var _flash_t := 3.0
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(24)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	city = ByzCity.new()
	add_child(city)
	city.niko.visible = false
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	# Sedye: iki uzun sırık, üstünde kırmızı örtülü taht ve Hodegetria ikonası (Meryem ve Çocuk, altın zemin)
	litter = Node3D.new()
	add_child(litter)
	for sx: float in [-0.55, 0.55]:
		Props.cyl(litter, 0.05, 4.2, Vector3(sx, 1.25, 0), Color("6a4a2c"), Vector3(90, 0, 0), 6)
	Props.box(litter, Vector3(1.3, 0.12, 1.4), Vector3(0, 1.3, 0), Color("7a1e24"))
	Props.box(litter, Vector3(1.32, 0.35, 1.42), Vector3(0, 1.2, 0), Color("c8a040"))
	icon = Node3D.new()
	icon.position = Vector3(0, 1.4, 0)
	litter.add_child(icon)
	Props.box(icon, Vector3(0.9, 1.2, 0.08), Vector3(0, 0.62, 0), Color("c8a040"))
	Props.box(icon, Vector3(0.78, 1.06, 0.02), Vector3(0, 0.62, 0.045), Color("e8b84a"))
	Props.ball(icon, 0.16, Vector3(-0.05, 0.9, 0.06), Color("1e3a6a"), Vector3(1.0, 1.1, 0.2), 8)
	Props.ball(icon, 0.1, Vector3(-0.05, 0.9, 0.08), Color("c89a70"), Vector3(0.8, 1.0, 0.2), 8)
	Props.ball(icon, 0.3, Vector3(-0.05, 0.5, 0.06), Color("1e3a6a"), Vector3(0.9, 1.2, 0.2), 8)
	Props.ball(icon, 0.08, Vector3(0.12, 0.62, 0.1), Color("c89a70"), Vector3(0.8, 1.0, 0.2), 8)
	Props.ball(icon, 0.13, Vector3(0.12, 0.5, 0.08), Color("e8e0c8"), Vector3(0.9, 1.0, 0.2), 8)
	# Taşıyıcılar: üç keşiş (önde iki, arkada biri); arka sol Tolga'nın yeri
	for spec in [Vector3(-0.55, 0, -1.8), Vector3(0.55, 0, -1.8), Vector3(0.55, 0, 1.8)]:
		var b := Person.new({"coat": Color("2a2226"), "pants": Color("2a2226"), "robe": Color("2a2226"), "beard": true,
			"hair": Color("3a3030"), "hat": "none"})
		b.set_meta("no_talk", true)
		b.position = spec
		litter.add_child(b)
		bearers.append(b)
	# Alayı izleyen ve arkasından yürüyen halk
	var rng := RandomNumberGenerator.new()
	rng.seed = 24
	for i in 14:
		var p := Person.new({"coat": [Color("6a5040"), Color("5a6a7a"), Color("7a4a3a"), Color("8a7a5a"), Color("4a4a5a")][i % 5],
			"pants": Color("3a3028"), "skirt": i % 3 == 0, "hair": Color("3a2a1e"), "mustache": i % 4 == 1})
		p.set_meta("no_talk", true)
		p.position = Vector3(rng.randf_range(-2.8, 2.8), 0, rng.randf_range(3.0, 7.0))
		litter.add_child(p)
		crowd.append(p)
	kid = Person.new({"coat": Color("c8603a"), "pants": Color("3a3a5a"), "hair": Color("5a3a1e"), "skin": Color("f0c8a0")})
	kid.scale = Vector3.ONE * 0.72
	kid.position = KID_POS
	kid.visible = false
	kid.set_meta("no_talk", true)
	add_child(kid)
	# Saçak (sığınak): tahta sundurma
	Props.box(self, Vector3(3.4, 0.12, 2.4), SHELTER + Vector3(0, 2.6, 0), Color("7a5634"), Vector3(-10, 0, 0))
	for sx: float in [-1.5, 1.5]:
		Props.cyl(self, 0.07, 2.6, SHELTER + Vector3(sx, 1.3, 1.0), Color("5a3e26"), Vector3.ZERO, 5)
	# Kubbedeki ışık (25 Mayıs akşamı)
	dome_light = Node3D.new()
	dome_light.position = DOME_LIGHT
	dome_light.visible = false
	add_child(dome_light)
	var g := Props.ball(dome_light, 1.4, Vector3.ZERO, Color("ff3a2a"), Vector3(1.0, 0.7, 1.0), 10, 2.0)
	g.material_override = Props.mat(Color("ff3a2a"), 1.6, false, "", false)
	# Kubbeyi saran kızıl hale (ışık kubbenin üstünde görülür, sonra tepeye yükselir)
	var halo := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 8.0
	sm.height = 9.0
	halo.mesh = sm
	var hm := StandardMaterial3D.new()
	hm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hm.albedo_color = Color(1.0, 0.3, 0.2, 0.28)
	hm.cull_mode = BaseMaterial3D.CULL_DISABLED
	halo.material_override = hm
	halo.position = DOME_TOP - DOME_LIGHT
	halo.name = "Halo"
	dome_light.add_child(halo)
	var dl := OmniLight3D.new()
	dl.light_color = Color("ff5a40")
	dl.light_energy = 6.0
	dl.omni_range = 30.0
	dome_light.add_child(dl)
	meter = BalanceMeter.new()
	meter.name = "Balance"
	meter.label_text = tr("UI_CH24_BALANCE")
	meter.visible = false
	hud.add_child(meter)


func _storm(on: bool, hail_on := false) -> void:
	if rain == null:
		rain = _particles(900, Vector3(0.01, 0.5, 0.01), Color(0.75, 0.82, 0.95, 0.55), -40.0, 1.0)
		hail = _particles(160, Vector3(0.06, 0.06, 0.06), Color("f4f6fa"), -30.0, 1.4)
	rain.emitting = on
	hail.emitting = hail_on
	var e := city.get("_env") as Environment
	var sm := city.get("_sky_mat") as ProceduralSkyMaterial
	if e and on:
		e.fog_enabled = true
		e.fog_light_color = Color("5a6070")
		e.fog_density = 0.02
		e.ambient_light_color = Color("8a90a0")
	if sm and on:
		sm.sky_top_color = Color("3a4050")
		sm.sky_horizon_color = Color("6a7080")
	var sun := city.get("_sun") as DirectionalLight3D
	if sun and on:
		sun.light_energy = 0.25


func _particles(n: int, size: Vector3, col: Color, grav: float, life: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.amount = n
	p.lifetime = life
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(14, 1, 14)
	p.position = Vector3(0, 9, 0)
	p.direction = Vector3(0.15, -1, 0)
	p.spread = 4.0
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


func _fog() -> void:
	_storm(false)
	var e := city.get("_env") as Environment
	if e:
		e.fog_enabled = true
		e.fog_light_color = Color("c8c8c8")
		e.fog_density = 0.045
		e.fog_sky_affect = 0.9
		e.ambient_light_color = Color("b0b0b0")
	var sun := city.get("_sun") as DirectionalLight3D
	if sun:
		sun.light_energy = 0.4


func _evening() -> void:
	var e := city.get("_env") as Environment
	if e:
		e.fog_density = 0.012
		e.fog_light_color = Color("4a4050")
		e.ambient_light_color = Color("6a6078")
	var sm := city.get("_sky_mat") as ProceduralSkyMaterial
	if sm:
		sm.sky_top_color = Color("2a2a48")
		sm.sky_horizon_color = Color("8a5a60")
	var sun := city.get("_sun") as DirectionalLight3D
	if sun:
		sun.light_energy = 0.15


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH24_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH24_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	_place_litter(0.0)
	player.pinned = true
	player.show_remote(false)
	_seat()
	player.face(litter.global_position + Vector3(0, 1.6, 4.0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D24_N_01")
	await hud.say("SPK_TOLGA", "D24_T_01")
	await hud.say("SPK_MONK", "D24_M_01")
	player.frozen = false
	phase = "carry"
	meter.visible = true
	hud.set_objective(tr("UI_OBJ24_CARRY"))
	await get_tree().create_timer(2.0).timeout
	_storm(true)
	hud.bark("SPK_MONK", "D24_M_RAIN", 3.0)
	while phase == "carry":
		await get_tree().process_frame
	await _slip()
	await _kid_step()
	await _fog_day()
	await _end_chapter()


func _place_litter(k: float) -> void:
	litter.global_position = ROUTE_A.lerp(ROUTE_B, k)
	litter.rotation.y = PI


func _seat() -> void:
	# Arka sol sırık (sedye kuzeye bakar: arka taraf +z)
	player.global_position = litter.to_global(Vector3(-0.55, 0.05, 1.8))


func _process(delta: float) -> void:
	_t += delta
	match phase:
		"carry":
			_route = minf(_route + delta / (12.0 if GameState.autotest else 38.0), 1.0)
			_place_litter(_route)
			_seat()
			_gust_t -= delta
			if _gust_t <= 0.0:
				_gust_t = randf_range(1.2, 2.6)
				_gust = randf_range(-1.0, 1.0) * (0.6 + _route)
			var input := Input.get_axis("move_left", "move_right")
			if GameState.autotest:
				input = -signf(_balance) * 0.9
			_balance += (_gust * 0.55 + input * 1.6) * delta
			_balance = lerpf(_balance, 0.0, delta * 0.15)
			meter.value = _balance
			litter.rotation.z = _balance * 0.12
			if absf(_balance) >= 1.0:
				stumbles += 1
				_balance = signf(_balance) * 0.5
				player.shake(0.4)
				hud.bark("SPK_MONK", "D24_M_STUMBLE", 2.0)
			if _route >= SLIP_AT:
				phase = "slip"
			_lightning(delta)
		"kid":
			_lightning(delta)
			if _kid_follow:
				var to := player.global_position - kid.global_position
				to.y = 0.0
				if to.length() > 1.4:
					kid.global_position += to.normalized() * minf(to.length() - 1.2, 4.2 * delta)
					kid.rotation.y = atan2(to.x, to.z)
				if kid.global_position.distance_to(SHELTER) < 2.2:
					_kid_saved = true
	var m := meter
	var vs := get_viewport().get_visible_rect().size
	m.position = Vector2((vs.x - m.size.x) * 0.5, vs.y - 170.0)


func _lightning(delta: float) -> void:
	if rain == null or not rain.emitting:
		return
	_flash_t -= delta
	if _flash_t > 0.0:
		return
	_flash_t = randf_range(3.0, 7.0)
	var e := city.get("_env") as Environment
	if e == null:
		return
	var was := e.ambient_light_energy
	e.ambient_light_energy = 3.0
	create_tween().tween_property(e, "ambient_light_energy", was, 0.25)
	get_tree().create_timer(0.6).timeout.connect(func(): Audio.sfx("explosion_big", -20.0, 0.45))


## Dolu ve fırtınanın doruğu: ikona taşıyıcıdan kayar. Tolga'nın dengesiyle ilgisi yoktur.
func _slip() -> void:
	player.frozen = true
	meter.visible = false
	hud.set_objective("")
	_storm(true, true)
	Audio.sfx("crowd_gasp", -2.0)
	var tw := create_tween()
	tw.tween_property(icon, "rotation:x", deg_to_rad(-70), 0.35).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(icon, "position", Vector3(0, 1.1, -0.9), 0.35)
	await tw.finished
	await hud.say("SPK_MONK", "D24_M_SLIP")
	await hud.say("SPK_TOLGA", "D24_T_SLIP")
	await hud.say("SPK_NIHAT", "D24_N_SLIP")
	var tw2 := create_tween()
	tw2.tween_property(icon, "rotation:x", 0.0, 1.2)
	tw2.parallel().tween_property(icon, "position", Vector3(0, 1.4, 0), 1.2)
	await hud.say("SPK_MONK", "D24_M_STOP")


func _kid_step() -> void:
	phase = "kid"
	player.pinned = false
	player.global_position = litter.to_global(Vector3(-1.4, 0.05, 2.2))
	kid.visible = true
	kid.set_activity("")
	Audio.sfx("crowd_gasp", -8.0, 1.4)
	hud.bark("SPK_KID", "D24_K_HELP", 3.0)
	player.face(kid.global_position + Vector3(0, 0.9, 0))
	var body := Props.interactable(kid, "kid", Vector3(1.0, 1.6, 1.0), Vector3(0, 0.8, 0))
	player.frozen = false
	hud.set_objective(tr("UI_OBJ24_KID"), KID_POS + Vector3(0, 1.0, 0))
	var t := KID_TIME
	if GameState.autotest:
		if GameState.autotest_variant == "late":
			t = 0.2
		else:
			_on_interact("kid")
			kid.global_position = SHELTER + Vector3(0.5, 0, 0)
	while t > 0.0 and not _kid_saved:
		await get_tree().process_frame
		t -= get_process_delta_time()
		hud.set_chase(tr("UI_CH24_TIME") % maxi(0, int(ceil(t))), 1.0 - t / KID_TIME)
		if _kid_follow:
			hud.set_objective(tr("UI_OBJ24_SHELTER"), SHELTER + Vector3(0, 1.5, 0))
	hud.set_chase("", 0.0)
	hud.set_objective("")
	player.frozen = true
	if is_instance_valid(body):
		body.queue_free()
	if _kid_saved:
		kid.global_position = SHELTER + Vector3(0.3, 0, 0.2)
		await hud.say("SPK_KID", "D24_K_THANKS")
		await hud.say("SPK_TOLGA", "D24_T_KID")
	else:
		kid.leave(player.global_position, 8.0, 2.0, true)
		await hud.say("SPK_TOLGA", "D24_T_KID_RAN")


func _fog_day() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH24_FOG"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	_fog()
	litter.visible = false
	kid.visible = false
	player.global_position = FOG_START
	player.face(Vector3(-14.0, 12.0, -82.0))
	player.enable_climb([Rect2(-36, -58, 70, 76)])
	await hud.fade_to(0.0, 1.2)
	await hud.say("SPK_TOLGA", "D24_T_FOG")
	await hud.say("SPK_NIHAT", "D24_N_FOG")
	phase = "fog"
	player.frozen = false
	hud.set_objective(tr("UI_OBJ24_WAIT"))
	await get_tree().create_timer(2.0 if GameState.autotest else 14.0).timeout
	_evening()
	# Işık kubbenin üstünden tepesine doğru yükselir (kaynaklarda: "tepeye çıktı ve kayboldu")
	dome_light.visible = true
	dome_light.position = DOME_LIGHT + Vector3(0, -8.0, 0)
	var rise := create_tween().set_parallel()
	rise.tween_property(dome_light, "position", DOME_LIGHT, 6.0).set_trans(Tween.TRANS_SINE)
	rise.tween_property(dome_light.get_node("Halo"), "position", DOME_TOP - DOME_LIGHT, 6.0).set_trans(Tween.TRANS_SINE)
	Audio.sfx("church_bell", -6.0, 0.8)
	await hud.say("SPK_MONK", "D24_M_LIGHT")
	hud.set_objective(tr("UI_OBJ24_PHOTO"), DOME_LIGHT)
	cam = TespitCam.new(player, hud, dome_light, "siege24")
	hud.add_child(cam)
	cam.max_dist = 160.0
	cam.cone_deg = 9.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 60.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	player.disable_climb()
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D24_T_PHONE")
	await hud.say("SPK_NIHAT", "D24_N_END")
	_outcome = "24.1" if _kid_saved else "24.2"
	GameState.flags["siege_kid"] = _kid_saved
	Siege.record(24, _photo, "SIEGE_NOTE_24_%s" % _outcome.split(".")[1])


func _on_focus(id: String) -> void:
	hud.set_prompt(tr("UI_PROMPT24_KID") if id == "kid" and not _kid_follow else "")


func _on_interact(id: String) -> void:
	if id == "kid" and phase == "kid" and not _kid_follow:
		_kid_follow = true
		kid.emote("nod")
		hud.bark("SPK_TOLGA", "D24_T_TAKE_KID", 2.5)


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
	c.title_text = tr("UI_FLOW24_TITLE")
	c.nodes = [
		{"id": "procession", "key": "FLOW24_PROCESSION", "pos": Vector2(0.5, 0.12)},
		{"id": "slip", "key": "FLOW24_SLIP", "pos": Vector2(0.5, 0.28)},
		{"id": "24.1", "key": "FLOW_24_1", "pos": Vector2(0.3, 0.46), "outcome": true},
		{"id": "24.2", "key": "FLOW_24_2", "pos": Vector2(0.7, 0.46), "outcome": true},
		{"id": "light", "key": "FLOW24_LIGHT", "pos": Vector2(0.5, 0.64)},
	]
	c.edges = [["procession", "slip"], ["slip", "24.1"], ["slip", "24.2"], ["24.1", "light"], ["24.2", "light"]]
	c.taken["procession"] = true
	c.taken["slip"] = true
	c.taken["light"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH24_STATS") % [stumbles, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "24.1", "late": "24.2"}.get(v, "24.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("24", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=24 variant=%s outcome=%s stumbles=%d kid=%s" % ["PASS" if ok else "FAIL", v, _outcome, stumbles, _kid_saved])
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
	_place_litter(0.4)
	player.pinned = true
	_seat()
	await get_tree().create_timer(0.5).timeout
	player.face(litter.global_position + Vector3(0, 1.6, 4.0))
	_storm(true, true)
	meter.visible = true
	meter.value = 0.4
	phase = "shots"
	await get_tree().create_timer(1.2).timeout
	await _shot("c24_01_storm.png")
	hud.visible = false
	meter.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = litter.global_position + Vector3(-2.2, 2.6, -6.0)
	cv.look_at(litter.global_position + Vector3(0, 1.8, 0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c24_cover.png")
	player.camera.make_current()
	hud.visible = true
	meter.visible = false
	_fog()
	_evening()
	dome_light.visible = true
	player.pinned = false
	litter.visible = false
	player.global_position = FOG_START
	player.face(DOME_LIGHT)
	await get_tree().create_timer(0.5).timeout
	await _shot("c24_02_dome.png")
	get_tree().quit()
