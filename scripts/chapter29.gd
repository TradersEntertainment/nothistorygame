extends Node3D
## Bölüm 29 (Bizans tarafı) — Zincirin Önü (Tolga · 20 Nisan 1453, öğleden sonra, Haliç'in ağzının dışı).
##
## Üç Ceneviz gemisi ve imparatorluğun tahıl gemisi şehre erzak ve asker getirir. Rüzgâr kesilir; Osmanlı kadırgaları
## yüksek bordalı gemileri sarar, gemiler birbirine bağlanıp savaşır. Tolga Kaptan Cattaneo'nun karakasının
## güvertesindedir:
##   1. bordaya takılan kancaların iplerini kes (E basılı). Kesilmeyen ipten biri bordaya çıkar.
##   2. bordaya çıkanlarla güvertede kılıç (StoryDuel; çıkan kadar)
##   3. kadırgalardan atılan ateş çömlekleri: fıçıdan kovayı doldur, ateşe dök (her ateşe iki kova)
##   4. kıyı: Sultan atını denize sürer. Tespit karesi.
##   5. akşam rüzgârı: yelkenler dolar, gemiler zincirden içeri.
##   29.1 Gemi bütün girdi (en çok bir kişi bordaya çıktı, ateş kalmadı) · 29.2 Gemi yaralı girdi
##   --autotest[=lose]   (varsayılan: 29.1; =lose: ipler kesilmez, ateş söndürülmez)

const HOOKS := 6
const HOOK_EVERY := 5.5
const HOOK_LIFE := 9.0
const CUT_NEED := 0.6
const FIRES := 3
const FIRE_TIME := 45.0
const DECK := SeaBattle.CARRACK_DECK

var walls: SeaWalls
var player: Player
var hud: Hud
var cam: TespitCam
var carrack: Node3D
var ships: Array[Node3D] = []
var captain: Person
var horse: Horse
var sultan: Person
var phase := "intro"
var _outcome := ""
var cut := 0
var spawned := 0
var boarders := 0
var _duel_won := true
var fires_left := 0
var _hooks: Dictionary = {}          # id -> {"node", "life", "spot"}
var _fires: Dictionary = {}          # id -> {"node", "need"}
var _focus := ""
var _hold := 0.0
var carrying := ""
var _carry: Node3D
var _photo := ""
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(29)
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	walls = SeaWalls.new()
	walls.in_world = true
	add_child(walls)
	SeaBattle.make_day(walls)
	_build()
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ sahne

func _build() -> void:
	var d := Vector3(0, 0, 34) - SeaBattle.BATTLE
	var yaw := atan2(-d.x, -d.z)
	carrack = SeaBattle.carrack(self, SeaBattle.BATTLE, yaw, 8, 29)
	ships.append(carrack)
	ships.append(SeaBattle.carrack(self, carrack.to_global(Vector3(7.4, 0, 1.5)), yaw + 0.04, 6, 30))
	ships.append(SeaBattle.carrack(self, carrack.to_global(Vector3(15.0, 0, -2.0)), yaw - 0.05, 6, 31))
	# İskele bordasında (kıyı tarafı) iki kadırga yanaşmış; çevrede daha fazlası
	for z: float in [-5.0, 6.0]:
		SeaBattle.war_galley(self, carrack.to_global(Vector3(-(SeaBattle.RAIL_X + SeaBattle.GALLEY_RAIL_X + 0.7), 0, z)), yaw, true, true)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2004
	for i in 10:
		var a := rng.randf_range(0.0, TAU)
		var r := rng.randf_range(26.0, 46.0)
		var p := SeaBattle.BATTLE + Vector3(cos(a) * r, 0, sin(a) * r)
		if p.z > SeaBattle.BATTLE.z + 8.0 and absf(p.x - SeaBattle.SULTAN_TO.x) < 30.0:
			continue
		SeaBattle.war_galley(self, p, atan2(SeaBattle.BATTLE.x - p.x, SeaBattle.BATTLE.z - p.z) + PI, false, i % 2 == 0)
	# Küpeştenin üstü görünmez duvar (güverteden denize atlanmasın)
	for sx: float in [-1.0, 1.0]:
		var w := Props.solid(carrack, Vector3(0.2, 2.4, 15.2), Vector3(sx * SeaBattle.RAIL_X, SeaBattle.RAIL_TOP + 1.2, -0.3), Color.WHITE)
		w.get_child(0).visible = false
		w.set_meta("no_climb", true)
	captain = Person.new({"coat": Color("2a3a6a"), "pants": Color("2a2226"), "hat": "berretta", "beard": true, "mustache": true,
		"skin": Color("dcae88"), "face": {"nose": "long", "brow": 1.1}})
	captain.set_meta("spk", "SPK_CATTANEO")
	captain.position = Vector3(0.6, DECK, 5.6)
	captain.rotation.y = PI
	carrack.add_child(captain)
	captain.look_target = player
	# Su fıçısı (ana direğin dibinde)
	Props.cyl(carrack, 0.45, 1.0, Vector3(1.2, DECK + 0.5, 2.6), Color("6a4a2c"), Vector3.ZERO, 10)
	Props.cyl(carrack, 0.42, 0.04, Vector3(1.2, DECK + 1.02, 2.6), Color("4a7aa8"), Vector3.ZERO, 10)
	Props.interactable(carrack, "barrel", Vector3(1.2, 1.4, 1.2), Vector3(1.2, DECK + 0.7, 2.6))
	var sh := SeaBattle.shore(self)
	horse = sh["horse"]
	sultan = sh["sultan"]


func _deck(local: Vector3) -> Vector3:
	return carrack.to_global(local + Vector3(0, DECK, 0))


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH29_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH29_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	Audio.ambience("amb_shore_day")
	player.global_position = _deck(Vector3(-1.0, 0.05, 3.4))
	player.face(captain.global_position + Vector3(0, 1.5, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D29_N_01")
	await hud.say("SPK_CATTANEO", "D29_C_01")
	await hud.say("SPK_TOLGA", "D29_T_01")
	await hud.say("SPK_CATTANEO", "D29_C_02")
	await _hooks_phase()
	if boarders > 0:
		await _board_fight()
	await _fire_phase()
	await _sultan()
	await _wind()
	await _end_chapter()


## 1. Kancalar: iskele küpeştesine kanca takılır; ipi kesilmezse (HOOK_LIFE) biri bordaya çıkar.
func _hooks_phase() -> void:
	phase = "hooks"
	player.frozen = false
	var next := 1.0
	_update_objective()
	while spawned < HOOKS or not _hooks.is_empty():
		await get_tree().process_frame
		var dt := get_process_delta_time()
		next -= dt
		if spawned < HOOKS and next <= 0.0 and _hooks.size() < 3:
			next = HOOK_EVERY
			_spawn_hook()
		for id in _hooks.keys():
			var h: Dictionary = _hooks[id]
			h["life"] = float(h["life"]) - dt
			if float(h["life"]) <= 0.0:
				_board(id)
		if GameState.autotest and GameState.autotest_variant != "lose" and not _hooks.is_empty():
			# Bot en eski kancaya gider ve keser
			var id: String = _hooks.keys()[0]
			if float(_hooks[id]["life"]) < HOOK_LIFE - 1.5:
				player.global_position = Person.clear_spot(get_tree(), _hooks[id]["stand"], null, 0.5)    # güvertedeki topun, fıçının içine değil
				_cut(id)
	player.frozen = true
	hud.set_prompt("")
	hud.set_chase("", 0.0)
	hud.set_objective("")


func _spawn_hook() -> void:
	spawned += 1
	var id := "hook_%d" % spawned
	var z := -5.4 + ((spawned * 7) % 6) * 2.0
	var top := _deck(Vector3(-SeaBattle.RAIL_X - 0.1, SeaBattle.RAIL_TOP - DECK, z))
	var bottom := carrack.to_global(Vector3(-(SeaBattle.RAIL_X + 2.4), SeaBattle.GALLEY_DECK + 0.6, z))
	var n := SeaBattle.hook(self, top, bottom)
	Props.interactable(n, id, Vector3(1.0, 1.4, 1.0), Vector3(0.6, -0.4, 0)).global_position = top + carrack.global_transform.basis.x * 0.6 - Vector3(0, 0.4, 0)
	_hooks[id] = {"node": n, "life": HOOK_LIFE, "stand": _deck(Vector3(-SeaBattle.RAIL_X + 1.0, 0.05, z))}
	Audio.sfx("kick_metal", -6.0, 1.5)
	hud.bark("SPK_GENOESE", "D29_S_HOOK", 2.0)
	_update_objective()


func _update_objective() -> void:
	if phase == "hooks":
		var look := Vector3.INF
		if not _hooks.is_empty():
			look = (_hooks[_hooks.keys()[0]]["node"] as Node3D).global_position
		hud.set_objective(tr("UI_OBJ29_HOOKS") % [cut, HOOKS], look if look != Vector3.INF else null)
	elif phase == "fire":
		var look2: Variant = null
		if not _fires.is_empty():
			look2 = (_fires[_fires.keys()[0]]["node"] as Node3D).global_position
		hud.set_objective(tr("UI_OBJ29_FIRE") % fires_left, look2)


func _cut(id: String) -> void:
	if not _hooks.has(id):
		return
	var n: Node3D = _hooks[id]["node"]
	_hooks.erase(id)
	cut += 1
	Audio.sfx("pick_tap", -4.0, 0.8)
	Vfx.dust(self, n.global_position, 0.25)
	n.queue_free()
	_hold = 0.0
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	_update_objective()


## Kesilmeyen ipten bir azap bordaya çıkar (dövüşte karşına gelir)
func _board(id: String) -> void:
	var n: Node3D = _hooks[id]["node"]
	_hooks.erase(id)
	boarders += 1
	n.queue_free()
	hud.bark("SPK_CATTANEO", "D29_C_BOARD", 2.5)
	Audio.stinger("warn", -8.0)
	_update_objective()


## 2. Bordaya çıkanlarla güvertede
func _board_fight() -> void:
	phase = "duel"
	await hud.say("SPK_CATTANEO", "D29_C_DUEL")
	var specs := []
	for k in mini(boarders, 3):
		specs.append({"pos": _deck(Vector3(-SeaBattle.RAIL_X + 1.2, 0, -2.0 + k * 2.2)), "blade": "kilij", "shield": k % 2 == 0,
			"name": "SPK_SOLDIER", "look": {"coat": [Color("b3262d"), Color("6a5040"), Color("2f5fa8")][k], "pants": Color("e8e0d0"),
			"hat": ["azap", "bork", "turban"][k], "mustache": true, "beard": k == 1}})
	player.frozen = false
	var r: Dictionary = await StoryDuel.fight(self, hud, player, specs, "spathion", 0.38)
	_duel_won = r["won"]
	player.frozen = true
	await hud.say("SPK_TOLGA", "D29_T_DUEL" if _duel_won else "D29_T_LOST")


## 3. Ateş çömlekleri: güverteye üç ateş düşer. Fıçıdan kova, ateşe iki kova.
func _fire_phase() -> void:
	phase = "fire"
	await hud.say("SPK_CATTANEO", "D29_C_FIRE")
	var spots := [Vector3(-1.8, 0, -4.6), Vector3(0.6, 0, -1.6), Vector3(-1.6, 0, 1.2)]
	for i in FIRES:
		var at := _deck(spots[i] + Vector3(0, 0.05, 0))
		var f := Vfx.fire(self, at, 0.7)
		var id := "fire_%d" % i
		Props.interactable(f, id, Vector3(1.4, 1.2, 1.4), Vector3(0, 0.5, 0))
		_fires[id] = {"node": f, "need": 2}
		Audio.sfx("fire_crackle", -10.0, 1.0)
	fires_left = FIRES
	player.frozen = false
	_update_objective()
	var t := 0.0
	var bot := 0.0
	while fires_left > 0 and t < FIRE_TIME:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		if GameState.autotest and GameState.autotest_variant != "lose":
			bot -= dt
			if bot <= 0.0:
				bot = 1.0
				if carrying == "":
					_on_interact("barrel")
				else:
					_on_interact(_fires.keys()[0])
		elif GameState.autotest and t > 3.0:
			break
	player.frozen = true
	_drop()
	hud.set_prompt("")
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D29_T_FIRE_OK" if fires_left == 0 else "D29_T_FIRE_BAD")


## 4. Kıyıda Sultan (tespit karesi)
func _sultan() -> void:
	phase = "sultan"
	await hud.say("SPK_CATTANEO", "D29_C_SHORE")
	# Küpeşte boyunca tayfanın arasındaki boşluk (z 1,65): kıyı önünde kimse durmaz
	player.global_position = _deck(Vector3(-SeaBattle.RAIL_X + 0.95, 0.05, 1.65))
	player.face(sultan.global_position + Vector3(0, 1.8, 0))
	var target := Node3D.new()
	sultan.add_child(target)
	target.position = Vector3(0, 1.6, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ29_PHOTO"), sultan.global_position + Vector3(0, 2.0, 0))
	cam = TespitCam.new(player, hud, target, "siege29")
	hud.add_child(cam)
	cam.max_dist = 80.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	var said := false
	while (not cam.done or t < 6.0) and t < (9.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
		SeaBattle.ride_in(horse, t / 6.0)
		if t > 3.0 and not said:
			said = true
			hud.bark("SPK_FATIH", "D29O_F_SEA", 4.0)
	SeaBattle.ride_in(horse, 1.0)
	cam.stop()
	if _photo != "":
		GameState.bump_stat("horse_sea", 1, true)
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D29_T_SULTAN")
	await hud.say("SPK_NIHAT", "D29_N_SULTAN")


## Güvertede kalanlar (dövüşten sonra nefeslenen dost askerler, yatan düşmanlar, düşen kılıçlar) gemiyle birlikte
## gitsin: sahnenin kökündeydiler, gemi yelken açınca yerlerinde kalıyor, kasara perdesi içlerinden geçip denizin
## üstünde asılı kalıyorlardı.
func _board_cargo() -> void:
	for c in get_children():
		var n := c as Node3D
		if n == null or n == carrack or n in ships or n == player or n is Camera3D or not n.is_inside_tree():
			continue
		var lp := carrack.to_local(n.global_position)
		if absf(lp.x) < SeaBattle.RAIL_X + 0.4 and absf(lp.z) < 12.0 and lp.y > DECK - 0.6 and lp.y < DECK + 4.0:
			n.reparent(carrack, true)


## 5. Akşam rüzgârı: gemiler zincirden içeri (Tolga güvertede, gemiyle birlikte)
func _wind() -> void:
	phase = "wind"
	await hud.say("SPK_CATTANEO", "D29_C_WIND")
	SeaBattle.make_dusk(walls)
	Audio.sfx("whoosh_fly", -4.0, 0.6)
	var starts: Array = []
	for s in ships:
		starts.append(s.global_position)
	_board_cargo()
	var local := carrack.to_local(player.global_position)
	var goal := Vector3(6.0, 0, 40.0)
	var t := 0.0
	while t < 9.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		var k := clampf(t / 9.0, 0.0, 1.0)
		for i in ships.size():
			SeaBattle.fill_sails(ships[i], clampf(t / 2.0, 0.0, 1.0))
			var off: Vector3 = starts[i] - SeaBattle.BATTLE
			ships[i].global_position = (starts[i] as Vector3).lerp(goal + off, k * k)
		player.global_position = carrack.to_global(local)
	Audio.sfx("kick_metal", -6.0, 0.5)
	await hud.say("SPK_CATTANEO", "D29_C_END")
	await hud.say("SPK_TOLGA", "D29_T_END")
	await hud.say("SPK_NIHAT", "D29_N_END")
	_outcome = "29.1" if boarders <= 1 and fires_left == 0 else "29.2"
	Siege.record(29, _photo, "SIEGE_NOTE_29_%s" % _outcome.split(".")[1])


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	_focus = id
	var k := ""
	if id.begins_with("hook_") and phase == "hooks" and _hooks.has(id):
		k = "UI_PROMPT29_CUT"
	elif id == "barrel" and phase == "fire" and carrying == "":
		k = "UI_PROMPT29_FILL"
	elif id.begins_with("fire_") and phase == "fire" and carrying == "water" and _fires.has(id):
		k = "UI_PROMPT29_POUR"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	if phase != "fire":
		return
	if id == "barrel" and carrying == "":
		_pick()
	elif id.begins_with("fire_") and carrying == "water" and _fires.has(id):
		_drop()
		Audio.sfx("splash", -6.0, 1.2)
		var f: Dictionary = _fires[id]
		var n: Node3D = f["node"]
		Vfx.steam(self, n.global_position + Vector3(0, 0.4, 0))
		f["need"] = int(f["need"]) - 1
		n.scale = Vector3.ONE * 0.55
		if int(f["need"]) <= 0:
			_fires.erase(id)
			n.queue_free()
			fires_left -= 1
		_update_objective()


func _pick() -> void:
	carrying = "water"
	_carry = Node3D.new()
	_carry.position = Vector3(0.35, -0.55, -0.7)
	player.camera.add_child(_carry)
	Props.cyl(_carry, 0.16, 0.3, Vector3.ZERO, Color("6a4a2c"), Vector3.ZERO, 8, 0.19)
	Props.cyl(_carry, 0.15, 0.02, Vector3(0, 0.14, 0), Color("4a7aa8"), Vector3.ZERO, 8)
	Props.strip_outlines(_carry)
	Audio.sfx("splash", -14.0, 1.6)
	hud.set_prompt("")


func _drop() -> void:
	carrying = ""
	if is_instance_valid(_carry):
		_carry.queue_free()
	_carry = null


func _process(delta: float) -> void:
	_t += delta
	if phase == "hooks" and not player.frozen:
		if _focus.begins_with("hook_") and _hooks.has(_focus) and Input.is_action_pressed("interact"):
			_hold += delta
			hud.set_chase(tr("UI_CH29_CUT"), _hold / CUT_NEED)
			if _hold >= CUT_NEED:
				_cut(_focus)
		elif _hold > 0.0:
			_hold = 0.0
			hud.set_chase("", 0.0)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(29, _outcome)
	await Siege.show_page(hud, 29)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(29)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW29_TITLE")
	c.nodes = [
		{"id": "deck", "key": "FLOW29_DECK", "pos": Vector2(0.5, 0.12)},
		{"id": "29.1", "key": "FLOW_29_1", "pos": Vector2(0.3, 0.34), "outcome": true},
		{"id": "29.2", "key": "FLOW_29_2", "pos": Vector2(0.7, 0.34), "outcome": true},
		{"id": "wind", "key": "FLOW29_WIND", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["deck", "29.1"], ["deck", "29.2"], ["29.1", "wind"], ["29.2", "wind"]]
	for k in ["deck", _outcome, "wind"]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH29_STATS") % [cut, HOOKS, boarders, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	if boarders > 0:
		c.footer_lines.insert(0, Grade.finish("29"))
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "29.1", "lose": "29.2"}.get(v, "29.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("29", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and spawned == HOOKS
	if v == "lose":
		ok = ok and boarders >= 2 and not _duel_won
	else:
		ok = ok and cut >= HOOKS - 1 and fires_left == 0
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s)" % [expected, _outcome, not page.is_empty(), cam != null and cam.done])
	print("AUTOTEST %s chapter=29 variant=%s outcome=%s cut=%d/%d boarders=%d fires=%d duel=%s" % ["PASS" if ok else "FAIL", v, _outcome,
		cut, HOOKS, boarders, fires_left, _duel_won])
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
	player.global_position = _deck(Vector3(-1.0, 0.05, 2.0))
	_spawn_hook()
	_spawn_hook()
	player.face((_hooks[_hooks.keys()[0]]["node"] as Node3D).global_position)
	await get_tree().create_timer(0.6).timeout
	await _shot_png("c29_01_hooks.png")
	SeaBattle.ride_in(horse, 0.8)
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = carrack.to_global(Vector3(-14.0, 9.0, 14.0))
	cv.look_at(carrack.to_global(Vector3(-2.0, 6.0, 0.0)), Vector3.UP)
	cv.fov = 55.0
	cv.make_current()
	await get_tree().create_timer(0.3).timeout
	await _shot_png("c29_cover.png")
	get_tree().quit()
