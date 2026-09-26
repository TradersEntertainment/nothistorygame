extends Node3D
## Bölüm 17 (Osmanlı tarafı) — Kundak (Tolga · 28 Nisan 1453 gecesi, Haliç'in kuzey kıyısı, kıyı topları).
##
## Aynı gece, öbür kıyıdan: donanma Pınarlar Vadisi'nde demirli; kıyıda toplar. Galata'da bir ışık yanar
## (tespit karesi; kaynaklar kimin yaktığını tartışır). Tolga topçuların yanındadır: karanlıkta yaklaşan gemileri
## görür (bak ve E), topu doldurur ve nişan alır (GunDrill). Coco'nun fustası batar (tarih). Bir ateş çömleği demirli
## bir kadırgaya düşer: kova zinciriyle yangın söndürülür.
##   17O.1 Yangın çabuk söndü · 17O.2 Kadırganın kıçı yandı, ama gemi kurtuldu
##   --autotest[=slow]   (varsayılan: 17O.1)

const WATER_Y := 0.0
const GUN := Vector3(0.0, 0.0, -1.0)
const GALATA_LIGHT := Vector3(-70.0, 38.0, 30.0)
const FIRE_GALLEY := Vector3(18.0, 0.0, 7.0)
const BUCKETS := Vector3(11.0, 0.0, -0.6)
const FIRE_TIME := 40.0

var player: Player
var hud: Hud
var topcu: Soldier
var crew: Array[Soldier] = []
var drill: GunDrill
var cam: TespitCam
var lantern: Node3D
var _lantern_light: OmniLight3D
var coco_boat: Node3D
var ships: Array[Node3D] = []
var fire_nodes: Array[Node3D] = []
var _fire_light: OmniLight3D
var phase := "intro"
var _outcome := ""
var _photo := ""
var _acc := 0.0
var _spotted := false
var _water := 0
var _carry: Node3D
var carrying := false
var _fire_t := 0.0
var _t := 0.0
var _approach := 0.0


func _ready() -> void:
	if GameState.current_chapter != 17:
		GameState.snapshot(17)
	GameState.flags["siege_side"] = "O"
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
	drill = GunDrill.new()
	hud.add_child(drill)
	drill.fired.connect(_on_fired)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	Night.environment(self, 0.008)
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(500, 400)
	pm.subdivide_width = 100
	pm.subdivide_depth = 80
	w.mesh = pm
	var sh := ShaderMaterial.new()
	sh.shader = load("res://assets/shaders/water.gdshader")
	w.material_override = sh
	w.position = Vector3(0, WATER_Y, 190)
	add_child(w)
	# Kıyı: kum, iskele, kıyı bataryası (toprak siper, üç top)
	Props.set_pattern(Props.solid(self, Vector3(200, 1.0, 60), Vector3(0, -0.5, -30.0), Color.WHITE), Color("a89878"), "cobble")
	Props.box(self, Vector3(200, 0.6, 3.0), Vector3(0, -0.35, 1.0), Color("b8a888"), Vector3(-10, 0, 0))
	Props.box(self, Vector3(12.0, 1.1, 1.6), GUN + Vector3(0, 0.55, 1.8), Color("6a5a40"))
	for i in 3:
		var gx := -4.0 + i * 4.0
		var g := Node3D.new()
		g.position = GUN + Vector3(gx, 0, 0)
		add_child(g)
		Props.box(g, Vector3(1.4, 0.5, 2.6), Vector3(0, 0.3, 0), Color("5a3e26"))
		Props.cyl(g, 0.34, 2.6, Vector3(0, 0.9, 0.7), Color("7a5a2a"), Vector3(80, 0, 0), 12)
		Props.cyl(g, 0.4, 0.3, Vector3(0, 0.95, 1.9), Color("6a4a20"), Vector3(80, 0, 0), 12)
	Props.interactable(self, "gun", Vector3(1.8, 1.6, 2.8), GUN + Vector3(0, 0.8, 0.2))
	# Barut fıçıları, gülleler
	for i in 3:
		Props.cyl(self, 0.3, 0.7, GUN + Vector3(-7.0 + i * 0.7, 0.35, -1.8), Color("2e2a26"), Vector3.ZERO, 10)
	for i in 6:
		Props.ball(self, 0.22, GUN + Vector3(6.5 + (i % 3) * 0.46, 0.22 + (i / 3) * 0.38, -1.6), Color("b8b0a0"), Vector3.ONE, 8)
	for x: float in [-8.0, 8.0]:
		Night.torch(self, GUN + Vector3(x, 0, -0.6), 2.2)
	topcu = Soldier.new(Color("b3262d"), "stand", "bork")
	topcu.position = GUN + Vector3(-2.2, 0, -1.4)
	add_child(topcu)
	for i in 4:
		var s := Soldier.new([Color("2f5fa8"), Color("6a4a3a"), Color("8a6a4a"), Color("2f5fa8")][i], "stand", "bork" if i % 2 == 0 else "turban")
		s.position = GUN + Vector3([-6.5, -3.2, 3.2, 6.5][i], 0, -1.2)
		add_child(s)
		crew.append(s)
	# Demirli donanma (Pınarlar Vadisi): kadırgalar, fenerler
	var rng := RandomNumberGenerator.new()
	rng.seed = 1704
	for i in 8:
		var p := Vector3(10.0 + i * 8.0, 0, 7.0 + rng.randf_range(-1, 1))
		var g := _galley(p, deg_to_rad(88 + rng.randf_range(-6, 6)))
		if i == 1:
			g.name = "FireGalley"
	# Kova yığını (su kıyısında)
	for i in 5:
		Props.cyl(self, 0.18, 0.3, BUCKETS + Vector3(-0.6 + (i % 3) * 0.4, 0.15, (i / 3) * 0.4), Color("8a6440"), Vector3.ZERO, 8, 0.22)
	Props.interactable(self, "buckets", Vector3(1.8, 1.2, 1.6), BUCKETS + Vector3(0, 0.6, 0))
	# İskele: kıyıdan yanan kadırganın borda iskelesine
	Props.set_pattern(Props.solid(self, Vector3(2.2, 0.3, 5.0), Vector3(FIRE_GALLEY.x, 0.35, 2.0), Color.WHITE), Color("8a6440"), "wood")
	for sx: float in [-1.0, 1.0]:
		for z: float in [0.5, 2.5, 4.3]:
			Props.cyl(self, 0.1, 1.6, Vector3(FIRE_GALLEY.x + sx, -0.3, z), Color("4a3422"), Vector3.ZERO, 6)
	Props.interactable(self, "galley_fire", Vector3(3.0, 2.4, 2.0), FIRE_GALLEY + Vector3(0, 1.2, -2.4))
	# Karşı kıyı: şehir surları (uzakta), Galata kulesi ve fener
	for i in 12:
		Props.box(self, Vector3(12.0, 12.0, 4.0), Vector3(-70.0 + i * 13.0, 5.0, 180.0), Color("3a3e4a"))
	Props.cyl(self, 4.0, 34.0, Vector3(-70, 17, 30), Color("2a2c34"), Vector3.ZERO, 10)
	Props.cyl(self, 4.6, 7.0, Vector3(-70, 37, 30), Color("24262e"), Vector3.ZERO, 10, 0.2)
	lantern = Node3D.new()
	lantern.position = GALATA_LIGHT
	lantern.visible = false
	add_child(lantern)
	var lm := Props.ball(lantern, 0.8, Vector3.ZERO, Color("ffd070"), Vector3.ONE, 6, 4.0)
	lm.material_override = Props.mat(Color("ffd070"), 5.0, false, "", false)
	_lantern_light = OmniLight3D.new()
	_lantern_light.light_color = Color("ffc060")
	_lantern_light.light_energy = 6.0
	_lantern_light.omni_range = 40.0
	lantern.add_child(_lantern_light)
	# Yaklaşan Venedik gemileri (karanlık, fenersiz)
	coco_boat = _enemy(Vector3(30.0, 0, 120.0), 9.0)
	for i in 2:
		ships.append(_enemy(Vector3(24.0 + i * 16.0, 0, 140.0), 16.0))


func _galley(p: Vector3, yaw: float) -> Node3D:
	var g := Node3D.new()
	g.position = p + Vector3(0, -0.3, 0)
	g.rotation.y = yaw
	add_child(g)
	g.add_child(LowPoly.hull([
		{"z": -9.0, "w": 0.06, "top": 2.3, "bottom": 1.4},
		{"z": -6.0, "w": 1.3, "top": 1.9, "bottom": 0.3},
		{"z": 0.0, "w": 1.7, "top": 1.85, "bottom": 0.2},
		{"z": 5.0, "w": 1.4, "top": 2.0, "bottom": 0.4},
		{"z": 7.0, "w": 0.8, "top": 2.7, "bottom": 1.0},
	], Color("3a2a1c"), Color("7e2420"), 1.78))
	Props.cyl(g, 0.14, 9.0, Vector3(0, 6.2, -1.5), Color("4a3420"), Vector3.ZERO, 6)
	var f := Props.ball(g, 0.18, Vector3(0, 3.0, 6.5), Color("ffb040"), Vector3.ONE, 5, 3.0)
	f.material_override = Props.mat(Color("ffb040"), 3.0, false, "", false)
	return g


func _enemy(p: Vector3, length: float) -> Node3D:
	var g := Node3D.new()
	g.position = p
	g.rotation.y = PI
	add_child(g)
	var h := length * 0.5
	g.add_child(LowPoly.hull([
		{"z": -h - 0.6, "w": 0.06, "top": 1.7, "bottom": 0.9},
		{"z": 0.0, "w": length * 0.14, "top": 1.3, "bottom": -0.35},
		{"z": h + 0.4, "w": length * 0.07, "top": 1.8, "bottom": 0.5},
	], Color("2a2018"), Color("2a3a5a"), 1.15))
	Props.cyl(g, 0.12, length * 0.7, Vector3(0, length * 0.35 + 1.0, 0), Color("3a2a1c"), Vector3.ZERO, 6)
	return g


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH17O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH17O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = GUN + Vector3(1.6, 0.05, -2.6)
	player.face(topcu.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_TOPCU", "D17O_A_01")
	await hud.say("SPK_TOLGA", "D17O_T_01")
	await hud.say("SPK_TOPCU", "D17O_A_02")
	# Galata'da ışık: tespit
	lantern.visible = true
	Audio.sfx("radio_beep", -10.0)
	await hud.say("SPK_TOPCU", "D17O_A_LIGHT")
	hud.bark("SPK_NIHAT", "D17_N_RADIO_LIGHT", 5.0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ17_LIGHT"), GALATA_LIGHT)
	cam = TespitCam.new(player, hud, lantern, "siege17")
	hud.add_child(cam)
	cam.max_dist = 260.0
	cam.cone_deg = 8.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 22.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	lantern.visible = false
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D17_T_SHOT" if cam.done else "D17O_T_MISSED")
	# Gözcülük: karanlıkta yaklaşan gemiyi gör
	phase = "watch"
	hud.set_objective(tr("UI_OBJ17O_WATCH"))
	await hud.say("SPK_TOPCU", "D17O_A_WATCH")
	if GameState.autotest:
		_spot()
	while not _spotted:
		await get_tree().process_frame
		if Input.is_action_just_pressed("interact") and _looking_at(coco_boat.global_position + Vector3(0, 1, 0), 10.0):
			_spot()
	hud.set_objective("")
	# Top: iki atış
	player.frozen = true
	player.global_position = GUN + Vector3(0.0, 0.05, -2.3)
	player.face(coco_boat.global_position + Vector3(0, 1.0, 0))
	for shot in 2:
		phase = "drill"
		await hud.say("SPK_TOPCU", "D17O_A_LOAD_%d" % (shot + 1))
		hud.set_objective(tr("UI_OBJ17O_GUN"))
		drill.start(0.3 + shot * 0.15, 0.2)
		while drill.active:
			await get_tree().process_frame
		hud.set_objective("")
		await _shot(shot)
	await _fire_step()
	await _dawn()
	await _end_chapter()


func _looking_at(p: Vector3, cone: float) -> bool:
	var cam3 := player.camera
	var to := p - cam3.global_position
	return rad_to_deg((-cam3.global_transform.basis.z).angle_to(to.normalized())) < cone


func _spot() -> void:
	if _spotted:
		return
	_spotted = true
	Audio.sfx("church_bell", -8.0, 1.8)
	hud.bark("SPK_TOLGA", "D17O_T_SPOT", 3.0)
	for s in crew:
		s.look_target = coco_boat


func _on_fired(acc: float) -> void:
	_acc = maxf(_acc, acc)


func _shot(n: int) -> void:
	Audio.sfx("cannon", 0.0)
	Vfx.explosion(self, GUN + Vector3(0, 1.0, 2.6), 0.7)
	player.shake(0.6)
	await get_tree().create_timer(1.0).timeout
	var hitp := coco_boat.global_position
	if n == 0:
		Vfx.explosion(self, hitp + Vector3(randf_range(-6, 6), 0.3, randf_range(-6, 6)), 0.5)
		Audio.sfx("splash", -2.0)
		await hud.say("SPK_TOPCU", "D17O_A_NEAR" if _acc >= 0.5 else "D17O_A_MISS")
		return
	# İkinci atış: Coco'nun fustası vurulur (tarih). Kimin topuyla olduğunu isabet belirler.
	Vfx.explosion(self, hitp + Vector3(0, 0.6, 0), 1.2)
	Audio.sfx("explosion_big", -2.0)
	var fire := OmniLight3D.new()
	fire.light_color = Color("ff8a3a")
	fire.light_energy = 5.0
	fire.omni_range = 20.0
	fire.position = Vector3(0, 2.0, 0)
	coco_boat.add_child(fire)
	var tw := create_tween().set_parallel()
	tw.tween_property(coco_boat, "rotation:x", deg_to_rad(-20), 5.0)
	tw.tween_property(coco_boat, "position:y", -3.0, 7.0)
	tw.tween_property(fire, "light_energy", 0.0, 7.0)
	GameState.flags["siege_gun_hit"] = _acc >= 0.6
	await hud.say("SPK_TOPCU", "D17O_A_HIT_YOU" if _acc >= 0.6 else "D17O_A_HIT_OTHER")
	await hud.say("SPK_TOLGA", "D17O_T_HIT")


func _fire_step() -> void:
	# Ateş çömleği demirli bir kadırgaya düşer
	var g := get_node_or_null("FireGalley") as Node3D
	var fp := FIRE_GALLEY + Vector3(0, 2.0, 0)
	Vfx.explosion(self, fp, 0.8)
	Audio.sfx("explosion_small", -2.0)
	_fire_light = OmniLight3D.new()
	_fire_light.position = fp + Vector3(0, 1.0, 0)
	_fire_light.light_color = Color("ff8a3a")
	_fire_light.light_energy = 6.0
	_fire_light.omni_range = 18.0
	add_child(_fire_light)
	for i in 6:
		var f := Props.cyl(self, 0.35, 1.4, fp + Vector3(randf_range(-1.5, 1.5), 0.2, randf_range(-3, 3)), Color("ffa030"), Vector3.ZERO, 6, 0.05, 3.0)
		f.material_override = Props.mat(Color("ff8a20"), 1.8, false, "", false)
		fire_nodes.append(f)
	await hud.say("SPK_TOPCU", "D17O_A_FIRE")
	player.frozen = false
	phase = "fire"
	_fire_t = FIRE_TIME
	_update_fire_objective()
	if GameState.autotest:
		var n := 1 if GameState.autotest_variant == "slow" else 3
		for i in n:
			_on_interact("buckets")
			_on_interact("galley_fire")
		if n < 3:
			_fire_t = 0.01
	while phase == "fire":
		await get_tree().process_frame
	hud.set_chase("", 0.0)
	hud.set_objective("")
	hud.set_prompt("")
	player.frozen = true
	if carrying:
		_drop()


func _update_fire_objective() -> void:
	if carrying:
		hud.set_objective(tr("UI_OBJ17O_POUR") % [_water, 3], FIRE_GALLEY + Vector3(0, 1.4, -2.6))
	else:
		hud.set_objective(tr("UI_OBJ17O_BUCKET") % [_water, 3], BUCKETS + Vector3(0, 1.0, 0))


func _drop() -> void:
	carrying = false
	if _carry:
		_carry.queue_free()
		_carry = null
	player.speed_mult = 1.0


func _dawn() -> void:
	var quick := _water >= 3
	for f in fire_nodes:
		f.visible = false
	if _fire_light:
		_fire_light.light_energy = 0.0
	await hud.say("SPK_TOPCU", "D17O_A_OUT" if quick else "D17O_A_BURNED")
	await hud.fade_to(1.0, 1.0)
	await hud.card([[tr("UI_CH17O_DAWN"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_TOPCU", "D17O_A_DAWN")
	await hud.say("SPK_TOLGA", "D17O_T_END")
	await hud.say("SPK_NIHAT", "D17_N_END")
	_outcome = "17O.1" if quick else "17O.2"
	Siege.record(17, _photo, "SIEGE_NOTE_17O_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	if lantern and lantern.visible:
		_lantern_light.light_energy = 6.0 if fmod(_t, 1.2) < 0.7 else 1.0
	if phase in ["watch", "drill"]:
		_approach = minf(_approach + delta * 0.08, 1.0)
		coco_boat.position = Vector3(30.0, sin(_t) * 0.05, lerpf(120.0, 55.0, _approach))
		for i in ships.size():
			ships[i].position = Vector3(24.0 + i * 16.0, sin(_t + i) * 0.05, lerpf(140.0, 85.0, _approach))
	for f in fire_nodes:
		if f.visible:
			f.scale.y = 1.0 + sin(_t * 9.0 + f.position.x) * 0.25
	if phase == "fire":
		_fire_t -= delta
		hud.set_chase(tr("UI_CH17O_TIME") % maxi(0, int(ceil(_fire_t))), 1.0 - _fire_t / FIRE_TIME)
		if _fire_t <= 0.0 or _water >= 3:
			phase = "fire_done"


func _on_focus(id: String) -> void:
	match id:
		"buckets":
			hud.set_prompt(tr("UI_PROMPT17O_BUCKET") if phase == "fire" and not carrying else "")
		"galley_fire":
			hud.set_prompt(tr("UI_PROMPT17O_POUR") if phase == "fire" and carrying else "")
		_:
			hud.set_prompt("")


func _on_interact(id: String) -> void:
	if phase != "fire":
		return
	match id:
		"buckets":
			if carrying:
				return
			carrying = true
			_carry = Node3D.new()
			_carry.position = Vector3(0.3, -0.78, -1.05)
			_carry.scale = Vector3.ONE * 0.6
			player.camera.add_child(_carry)
			Props.cyl(_carry, 0.2, 0.36, Vector3.ZERO, Color("8a6440"), Vector3.ZERO, 8, 0.24)
			Props.cyl(_carry, 0.22, 0.02, Vector3(0, 0.16, 0), Color("4a78a8"), Vector3.ZERO, 8)
			Props.strip_outlines(_carry)
			player.speed_mult = 0.8
			Audio.sfx("splash", -12.0, 1.2)
			_update_fire_objective()
		"galley_fire":
			if not carrying:
				return
			_drop()
			_water += 1
			Audio.sfx("splash", -2.0, 0.9)
			Vfx.steam(self, FIRE_GALLEY + Vector3(0, 2.2, 0))
			for i in 2:
				if not fire_nodes.is_empty():
					var f: Node3D = fire_nodes.pop_back()
					f.queue_free()
			if _fire_light:
				_fire_light.light_energy = maxf(0.0, _fire_light.light_energy - 2.0)
			hud.bark("SPK_TOLGA", "D17O_T_POUR_%d" % mini(_water, 3), 2.2)
			_update_fire_objective()


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(17, _outcome)
	await Siege.show_page(hud, 17)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(17)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW17O_TITLE")
	c.nodes = [
		{"id": "light", "key": "FLOW17_LIGHT", "pos": Vector2(0.5, 0.12)},
		{"id": "gun", "key": "FLOW17O_GUN", "pos": Vector2(0.5, 0.3)},
		{"id": "17O.1", "key": "FLOW_17O_1", "pos": Vector2(0.3, 0.52), "outcome": true},
		{"id": "17O.2", "key": "FLOW_17O_2", "pos": Vector2(0.7, 0.52), "outcome": true},
	]
	c.edges = [["light", "gun"], ["gun", "17O.1"], ["gun", "17O.2"]]
	for k in ["gun", _outcome]:
		c.taken[k] = true
	if cam and cam.done:
		c.taken["light"] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH17O_STATS") % [int(_acc * 100.0), _water, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "17O.1", "slow": "17O.2", "osm": "17O.1"}.get(v, "17O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("17", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and _spotted
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=17o variant=%s outcome=%s acc=%.2f water=%d" % ["PASS" if ok else "FAIL", v, _outcome, _acc, _water])
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
	phase = "drill"
	_approach = 0.6
	player.global_position = GUN + Vector3(0.0, 0.05, -2.3)
	await get_tree().create_timer(0.8).timeout
	player.face(coco_boat.global_position + Vector3(0, 1.0, 0))
	drill.start(0.0, 0.2)
	drill.step = 4
	await _shot_png("c17o_01_gun.png")
	drill.stop()
	phase = "fire"
	_fire_step_visual()
	player.global_position = FIRE_GALLEY + Vector3(-2.0, 0.05, -5.0)
	player.face(FIRE_GALLEY + Vector3(0, 2.0, 0))
	await _shot_png("c17o_02_fire.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = GUN + Vector3(-5.0, 3.0, -6.0)
	cv.look_at(GUN + Vector3(4.0, 1.0, 12.0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot_png("c17o_cover.png")
	get_tree().quit()


func _fire_step_visual() -> void:
	var fp := FIRE_GALLEY + Vector3(0, 2.0, 0)
	var l := OmniLight3D.new()
	l.position = fp + Vector3(0, 1.0, 0)
	l.light_color = Color("ff8a3a")
	l.light_energy = 6.0
	l.omni_range = 18.0
	add_child(l)
	for i in 6:
		var f := Props.cyl(self, 0.35, 1.4, fp + Vector3(randf_range(-1.5, 1.5), 0.2, randf_range(-3, 3)), Color("ffa030"), Vector3.ZERO, 6, 0.05, 3.0)
		f.material_override = Props.mat(Color("ff8a20"), 1.8, false, "", false)
		fire_nodes.append(f)
