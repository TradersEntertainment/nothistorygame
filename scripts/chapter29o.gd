extends Node3D
## Bölüm 29 (Osmanlı tarafı) — Zincirin Önü (Tolga · 20 Nisan 1453, öğleden sonra, Haliç'in ağzının dışı).
##
## Üç Ceneviz gemisi ve imparatorluğun tahıl gemisi Marmara'dan gelir; Baltaoğlu Süleyman Bey'in alçak kadırgaları
## yüksek bordalı gemileri sarar. Rüzgâr kesilir, gemiler birbirine bağlanıp kale gibi savaşır. Tolga Baltaoğlu'nun
## kadırgasındadır (karakanın kıyıya bakan iskele bordasında):
##   1. kürek ritmiyle karakaya yetiş (RowMeter)
##   2. küpeşteye kanca at (E; nişan küpeştede). Takılan ipi yukarıdakiler birkaç saniyede keser.
##   3. ipten tırmanma denemesi: yukarıdan kova ve taş, Tolga kadırgaya geri düşer (bordaya çıkılamadı, tarih)
##   4. kıyı: Sultan atını göğsüne kadar denize sürer, bağırır. Tespit karesi.
##   5. güvertedeki tayfaya tüfek (GunRange)
##   6. akşam rüzgârı döner, yelkenler dolar, gemiler zincirden içeri süzülür. Baltaoğlu ertesi gün azledilir.
##   29O.1 Kancalar tuttu (en az üç kez takıldı) · 29O.2 Kancalar tutmadı. Tarih ikisinde de aynı.
##   --autotest[=lose]   (varsayılan: 29O.1; =lose: kanca atılmaz)

const HOOK_GOAL := 4
const HOOK_TIME := 40.0
const HOOK_REACH := 34.0
const DECK := SeaBattle.GALLEY_DECK

var walls: SeaWalls
var player: Player
var hud: Hud
var meter: RowMeter
var cam: TespitCam
var carrack: Node3D
var ships: Array[Node3D] = []
var galley: Node3D
var balta: Person
var horse: Horse
var sultan: Person
var phase := "intro"
var _outcome := ""
var hooks_thrown := 0
var hooks_caught := 0
var climbed := false
var gun_shots := 0
var gun_hits := 0
var _hooks: Array[Node3D] = []
var _hook_cd := 0.0
var _path: Array = []
var _total := 0.0
var _d := 0.0
var _speed := 0.0
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
	meter = RowMeter.new()
	hud.add_child(meter)
	walls = SeaWalls.new()
	walls.in_world = true
	add_child(walls)
	SeaBattle.make_day(walls)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ sahne

## Karakaların başı zincire (x 0, z 34) döner; kadırga ana karakanın sancak (+X) bordasına yanaşır.
func _heading_yaw() -> float:
	var d := Vector3(0, 0, 34) - SeaBattle.BATTLE
	return atan2(-d.x, -d.z)


func _build() -> void:
	var yaw := _heading_yaw()
	carrack = SeaBattle.carrack(self, SeaBattle.BATTLE, yaw, 8, 29)
	ships.append(carrack)
	# Öbür iki Ceneviz gemisi sancak bordasına bağlı, tahıl gemisi biraz geride (gemiler birbirine bağlanıp savaştı).
	# Tolga'nın kadırgası iskele bordasında, kıyı tarafında: Sultan oradan görünür.
	ships.append(SeaBattle.carrack(self, carrack.to_global(Vector3(7.4, 0, 1.5)), yaw + 0.04, 6, 30))
	ships.append(SeaBattle.carrack(self, carrack.to_global(Vector3(15.0, 0, -2.0)), yaw - 0.05, 6, 31))
	# Kadırgalar karakaları sarar (kıyı tarafı açık: Sultan oradan görünür)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2004
	for i in 14:
		var a := rng.randf_range(0.0, TAU)
		var r := rng.randf_range(24.0, 46.0)
		var p := SeaBattle.BATTLE + Vector3(-6.0, 0, 0) + Vector3(cos(a) * r, 0, sin(a) * r)
		if p.z > SeaBattle.BATTLE.z + 8.0 and absf(p.x - SeaBattle.SULTAN_TO.x) < 30.0:
			continue
		# İskele (kıyı) tarafı Tolga'nın kadırgasının yolu: orada başka kadırga durmaz
		if carrack.to_local(p).x < 4.0:
			continue
		var gy := atan2(SeaBattle.BATTLE.x - p.x, SeaBattle.BATTLE.z - p.z) + PI
		SeaBattle.war_galley(self, p, gy, false, i % 2 == 0)
	# Tolga'nın kadırgası: açık denizden (karakanın önünden, zincir tarafından) dolanıp iskele bordasına yanaşır
	var side := -carrack.global_transform.basis.x.normalized()
	var back := carrack.global_transform.basis.z.normalized()
	var along := SeaBattle.BATTLE + side * (SeaBattle.RAIL_X + SeaBattle.GALLEY_RAIL_X + 0.7) + back * 1.0
	_path = [along - back * 60.0 + side * 6.0, along - back * 24.0 + side * 9.0, along + back * 14.0 + side * 3.0, along]
	_total = _length(_path)
	galley = SeaBattle.war_galley(self, _path[0], yaw)
	# Tolga'nın oturduğu ve kanca attığı yerin (sancak tarafı, ortadan kıça) kürekçileri: kameranın dibinde durmasınlar
	var keep: Array = []
	for r: Person in galley.get_meta("rowers"):
		if r.position.x > 0.0 and r.position.z > -2.0:
			r.queue_free()
		else:
			keep.append(r)
	galley.set_meta("rowers", keep)
	balta = Person.new({"coat": Color("2f4a6a"), "pants": Color("e8e0d0"), "hat": "turban", "beard": true, "mustache": true,
		"robe": Color("2f4a6a"), "skin": Color("d8a882"), "face": {"brow": 1.2, "beard": "full"}})
	balta.set_meta("spk", "SPK_BALTA")
	balta.position = Vector3(0, DECK, 7.0)
	balta.rotation.y = PI
	galley.add_child(balta)
	balta.look_target = player
	var sh := SeaBattle.shore(self)
	horse = sh["horse"]
	sultan = sh["sultan"]
	_place(galley, 0.0)


static func _length(path: Array) -> float:
	var l := 0.0
	for i in path.size() - 1:
		l += (path[i] as Vector3).distance_to(path[i + 1])
	return l


func _place(n: Node3D, d: float) -> void:
	d = clampf(d, 0.0, _total)
	for i in _path.size() - 1:
		var a: Vector3 = _path[i]
		var b: Vector3 = _path[i + 1]
		var l := a.distance_to(b)
		if d <= l or i == _path.size() - 2:
			var p := a.lerp(b, clampf(d / l, 0.0, 1.0))
			n.global_position = p + Vector3(0, sin(_t * 1.3) * 0.05, 0)
			# Son ayakta kadırga karakaya paralel durur
			var dir := (b - a).normalized()
			if i == _path.size() - 2 and d / l > 0.6:
				dir = -carrack.global_transform.basis.z
			n.look_at(n.global_position + dir, Vector3.UP)
			return
		d -= l


func _seat() -> void:
	player.eye_height = 1.15
	player.global_position = galley.to_global(Vector3(1.0, DECK + 0.05, 4.0))


func _stand() -> void:
	player.pinned = false
	player.eye_height = Player.EYE
	player.global_position = galley.to_global(Vector3(0.9, DECK + 0.05, 0.4))
	player.face(carrack.to_global(Vector3(-SeaBattle.RAIL_X, SeaBattle.RAIL_TOP, 0)))


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH29O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH29O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	Audio.ambience("amb_shore_day")
	player.pinned = true
	player.show_remote(false)
	_seat()
	player.face(carrack.global_position + Vector3(0, 8.0, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D29O_N_01")
	await hud.say("SPK_BALTA", "D29O_B_01")
	await hud.say("SPK_TOLGA", "D29O_T_01")
	await hud.say("SPK_BALTA", "D29O_B_02")
	# 1. Kürek
	phase = "row"
	player.frozen = false
	meter.enabled = true
	hud.set_objective(tr("UI_OBJ29O_ROW"), carrack.global_position + Vector3(0, 6, 0))
	while _d < _total - 0.2:
		await get_tree().process_frame
	meter.enabled = false
	hud.set_objective("")
	phase = "alongside"
	player.frozen = true
	await hud.say("SPK_BALTA", "D29O_B_HOOK")
	await _hooks_phase()
	await _climb()
	await _sultan()
	await _gun()
	await _wind()
	await _end_chapter()


## 2. Kanca: küpeşteye nişan al, E. Takılan kancanın ipi birkaç saniye sonra yukarıdan kesilir.
func _hooks_phase() -> void:
	_stand()
	phase = "hooks"
	player.frozen = false
	hud.bark("SPK_TOLGA", "D29O_T_HOOK", 3.0)
	var t := 0.0
	var auto := 0.0
	_update_hook_objective()
	while hooks_caught < HOOK_GOAL and t < HOOK_TIME:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		_hook_cd -= dt
		if GameState.autotest:
			auto -= dt
			if auto <= 0.0 and GameState.autotest_variant != "lose":
				auto = 1.6
				# Bot küpeştenin bir noktasına bakar ve atar (her üç atıştan biri suya)
				var z := -5.0 + (hooks_thrown % 5) * 2.4
				var aim := carrack.to_global(Vector3(-SeaBattle.RAIL_X, SeaBattle.CARRACK_DECK + 0.9, z))
				if hooks_thrown % 3 == 2:
					aim += Vector3(0, 7.0, 0)
				player.face(aim)
				_throw()
			elif GameState.autotest_variant == "lose" and t > 4.0:
				break
		elif Input.is_action_just_pressed("interact") and not player.frozen:
			_throw()
	player.frozen = true
	hud.set_prompt("")
	hud.set_objective("")
	await hud.say("SPK_BALTA", "D29O_B_HOOKS_OK" if hooks_caught >= 3 else "D29O_B_HOOKS_BAD")


func _update_hook_objective() -> void:
	hud.set_objective(tr("UI_OBJ29O_HOOK") % [hooks_caught, HOOK_GOAL], carrack.to_global(Vector3(-SeaBattle.RAIL_X, SeaBattle.RAIL_TOP, 0)))


func _throw() -> void:
	if _hook_cd > 0.0:
		return
	_hook_cd = 1.2
	hooks_thrown += 1
	Audio.sfx("whoosh_fly", -10.0, 1.4)
	var c := player.camera
	var from := c.global_position
	var to := from - c.global_transform.basis.z * HOOK_REACH
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.exclude = [player.get_rid()]
	var r := get_world_3d().direct_space_state.intersect_ray(q)
	if not r.is_empty() and (r["collider"] as Node).has_meta("rail"):
		var top: Vector3 = r["position"]
		top.y = maxf(top.y, carrack.to_global(Vector3(0, SeaBattle.RAIL_TOP, 0)).y - 0.1)
		var bottom := galley.to_global(Vector3(SeaBattle.GALLEY_RAIL_X, DECK + 0.5, galley.to_local(top).z))
		var h := SeaBattle.hook(self, top, bottom)
		_hooks.append(h)
		hooks_caught += 1
		Audio.sfx("kick_metal", -8.0, 1.6)
		_update_hook_objective()
		_cut_later(h, randf_range(3.5, 6.0))
	else:
		# Iska: kanca suya
		var miss := to if r.is_empty() else r["position"] as Vector3
		var splash := Vector3(miss.x, 0.1, miss.z) if r.is_empty() else galley.to_global(Vector3(4.0, 0.1, galley.to_local(miss).z))
		Vfx.dust(self, splash, 0.5)
		Audio.sfx("splash", -8.0, 1.2)
		hud.bark("SPK_BALTA", "D29O_B_MISS", 2.0)


## Yukarıdan balta: ip kopar, kanca suya
func _cut_later(h: Node3D, secs: float) -> void:
	await get_tree().create_timer(secs).timeout
	if not is_instance_valid(h):
		return
	Audio.sfx("pick_tap", -6.0, 0.8)
	Vfx.dust(self, h.global_position, 0.25)
	h.queue_free()


## 3. İpten tırmanma: yukarıdan kova dolusu su ve bir taş. Tolga kadırgaya geri düşer.
func _climb() -> void:
	phase = "climb"
	for h in _hooks:
		if is_instance_valid(h):
			h.queue_free()
	await hud.say("SPK_BALTA", "D29O_B_CLIMB")
	await hud.say("SPK_TOLGA", "D29O_T_CLIMB")
	player.pinned = true
	var foot := galley.to_global(Vector3(1.2, DECK + 0.05, 0.4))
	var up := carrack.to_global(Vector3(-SeaBattle.RAIL_X - 0.45, 3.0, 0.4))
	player.global_position = foot
	player.face(carrack.to_global(Vector3(-SeaBattle.RAIL_X, SeaBattle.RAIL_TOP + 1.0, 0.4)))
	var hook := SeaBattle.hook(self, carrack.to_global(Vector3(-SeaBattle.RAIL_X - 0.1, SeaBattle.RAIL_TOP, 0.4)), foot + Vector3(0, 0.3, 0))
	var tw := create_tween()
	tw.tween_property(player, "global_position", up, 2.2).set_trans(Tween.TRANS_SINE)
	await tw.finished
	# Yukarıda bir yüz, bir kova
	Audio.sfx("splash", -2.0, 0.9)
	Vfx.steam(self, up + Vector3(0, 1.6, 0))
	Fx.trauma(0.5)
	climbed = true
	await get_tree().create_timer(0.5).timeout
	Audio.sfx("land_thud", -2.0)
	var fall := create_tween()
	fall.tween_property(player, "global_position", foot, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await fall.finished
	Fx.trauma(0.6)
	hook.queue_free()
	_stand()
	await hud.say("SPK_TOLGA", "D29O_T_FELL")
	await hud.say("SPK_NIHAT", "D29O_N_FELL")


## 4. Sultan kıyıdan atını denize sürer. Tespit karesi.
func _sultan() -> void:
	phase = "sultan"
	await hud.say("SPK_BALTA", "D29O_B_SHORE")
	player.face(sultan.global_position + Vector3(0, 1.8, 0))
	var target := Node3D.new()
	sultan.add_child(target)
	target.position = Vector3(0, 1.6, 0)
	var t := 0.0
	var said := false
	player.frozen = false
	hud.set_objective(tr("UI_OBJ29O_PHOTO"), sultan.global_position + Vector3(0, 2.0, 0))
	cam = TespitCam.new(player, hud, target, "siege29o")
	hud.add_child(cam)
	cam.max_dist = 80.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
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
	await hud.say("SPK_TOLGA", "D29O_T_SULTAN")
	await hud.say("SPK_NIHAT", "D29O_N_SULTAN")


## 5. Güvertedeki tayfaya tüfek
func _gun() -> void:
	phase = "gun"
	await hud.say("SPK_BALTA", "D29O_B_GUN")
	# Bordanın dibinden küpeştenin ardı görünmez: kadırganın öbür bordasına geç (yukarıyı oradan görürsün)
	player.global_position = galley.to_global(Vector3(-1.0, DECK + 0.05, 0.4))
	player.face(carrack.to_global(Vector3(-SeaBattle.RAIL_X, SeaBattle.RAIL_TOP + 0.8, 0)))
	var crew: Array = (carrack.get_meta("crew") as Array).filter(func(p): return p.position.x < 0.0)
	var res: Dictionary = await GunRange.run(self, hud, player, {"targets": crew, "shots": 4, "limit": 24.0,
		"objective": tr("UI_OBJ29O_GUN") % 4, "look": carrack.to_global(Vector3(-SeaBattle.RAIL_X, SeaBattle.RAIL_TOP + 0.6, 0))})
	gun_shots = res["shots"]
	gun_hits = res["hits"]
	player.frozen = true
	await hud.say("SPK_TOLGA", "D20_T_GUN_GOOD" if gun_hits >= 2 else "D29O_T_GUN_BAD")


## 6. Akşam rüzgârı: yelkenler dolar, gemiler zincire kayar; zincir bir an indirilir, içeri süzülürler.
func _wind() -> void:
	phase = "wind"
	await hud.say("SPK_TOLGA", "D29O_T_WIND")
	SeaBattle.make_dusk(walls)
	Audio.sfx("whoosh_fly", -4.0, 0.6)
	var starts: Array = []
	for s in ships:
		starts.append(s.global_position)
	var goal := Vector3(6.0, 0, 40.0)
	var t := 0.0
	while t < 9.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var k := clampf(t / 9.0, 0.0, 1.0)
		for i in ships.size():
			SeaBattle.fill_sails(ships[i], clampf(t / 2.0, 0.0, 1.0))
			var off: Vector3 = starts[i] - SeaBattle.BATTLE
			ships[i].global_position = (starts[i] as Vector3).lerp(goal + off, k * k)
		player.face(carrack.global_position + Vector3(0, 6, 0))
	Audio.sfx("kick_metal", -6.0, 0.5)
	await hud.say("SPK_BALTA", "D29O_B_END")
	await hud.say("SPK_TOLGA", "D29O_T_END")
	await hud.say("SPK_NIHAT", "D29O_N_END")
	_outcome = "29O.1" if hooks_caught >= 3 else "29O.2"
	Siege.record(29, _photo, "SIEGE_NOTE_29O_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	if phase == "row":
		var target := (2.4 + 4.4 * meter.speed_factor()) if meter.enabled else 0.6
		_speed = move_toward(_speed, target, delta * 1.5)
		_d = minf(_d + _speed * delta, _total)
		if Input.is_action_just_pressed("jump") and not player.frozen:
			meter.press()
		_place(galley, _d)
		_seat()
	SeaBattle.row_oars(galley, meter.phase if meter.enabled else fmod(_t * 0.3, 1.0), meter.enabled)
	if phase == "hooks" and not player.frozen:
		hud.set_prompt(tr("UI_PROMPT29O_HOOK") if _hook_cd <= 0.0 else "")


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
	c.title_text = tr("UI_FLOW29O_TITLE")
	c.nodes = [
		{"id": "row", "key": "FLOW29O_ROW", "pos": Vector2(0.5, 0.12)},
		{"id": "29O.1", "key": "FLOW_29O_1", "pos": Vector2(0.3, 0.34), "outcome": true},
		{"id": "29O.2", "key": "FLOW_29O_2", "pos": Vector2(0.7, 0.34), "outcome": true},
		{"id": "wind", "key": "FLOW29O_WIND", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["row", "29O.1"], ["row", "29O.2"], ["29O.1", "wind"], ["29O.2", "wind"]]
	for k in ["row", _outcome, "wind"]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH29O_STATS") % [hooks_caught, hooks_thrown, gun_hits, gun_shots, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	c.footer_lines.insert(0, Grade.finish("29o"))
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "29O.1", "lose": "29O.2"}.get(v, "29O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("29", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and climbed
	ok = ok and gun_shots >= 3 and gun_hits >= 1
	if v != "lose":
		ok = ok and hooks_caught >= 3 and hooks_thrown > hooks_caught
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s)" % [expected, _outcome, not page.is_empty(), cam != null and cam.done])
	print("AUTOTEST %s chapter=29o variant=%s outcome=%s hooks=%d/%d gun=%d/%d" % ["PASS" if ok else "FAIL", v, _outcome,
		hooks_caught, hooks_thrown, gun_hits, gun_shots])
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
	_d = _total
	_place(galley, _d)
	_stand()
	await get_tree().create_timer(0.6).timeout
	await _shot_png("c29o_01_rail.png")
	SeaBattle.ride_in(horse, 1.0)
	player.face(sultan.global_position + Vector3(0, 1.8, 0))
	await _shot_png("c29o_02_sultan.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = galley.to_global(Vector3(-13.0, 8.0, 15.0))
	cv.look_at(galley.to_global(Vector3(3.0, 3.5, -2.0)), Vector3.UP)
	cv.fov = 50.0
	cv.make_current()
	await get_tree().create_timer(0.3).timeout
	await _shot_png("c29o_cover.png")
	get_tree().quit()
