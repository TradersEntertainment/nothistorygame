extends Node3D
## Bölüm 34 (yalnız Osmanlı tarafı) — Tuncun Sesi (Tolga · Ocak 1453, Edirne). docs/OTTOMAN_NEW_A.md §2.
##
##   1a. Kalıbı kır: tokmakla kil gömleğe 8 darbe (işaret yeşildeyken E); kırmızıda tunca değer → çentik. 40 sn.
##   1b. Çıkrık: Tolga arkadaki, ustabaşı öndeki çıkrıkta; yeşilde Space bir çevirme. Namlunun eğimi (denge ibresi):
##       ustabaşı ara sıra soluklanır (önüne geçme) ya da hızlanır. Kırmızıda 1 sn → zincir kayar. Her 3 iyi
##       çevirmede mandal (E, 1,5 sn) yoksa tambur geri boşalır. 3,2 m'de kızak sürülür, namlu iner. 90 sn.
##   2.  Gülle oluğu: sekiz gülle; E kabul, F geri. Biri büyük (çembere takılır), biri çatlak (yalnız yakından).
##       Dördüncü gülle takozu atlar ve yamaçtan ateşe yuvarlanır: önüne geç, E ile takozu at.
##   3.  Tellal ve kızaklar: tehlike alanındaki dört yetişkini (E) ve kızaklı iki çocuğu (yamaç dibinde E) ipin
##       arkasına al. Buzda denge (A/D). 90 sn.
##   4.  Deneme atışı: barut, tapa, makara (E basılı), tokmak, nişan. Ateş almaz: duman bitene kadar 4 m içine girme
##       (girersen falya öksürür). Sonra falyaya taze barut (E basılı 2 sn) ve 4 sn'de ipin arkasına. Tespit: Sultan.
##   34O.1 gülle direğin 25 m içine · 34O.2 kısa
##   --autotest[=bad]   (varsayılan 34O.1)

const BREAK_TIME := 40.0
const BREAK_HITS := 8
const CRANK_TIME := 90.0
const STEP_UP := 0.13
const BALLS := 8
const BALL_WAIT := 5.0
const CROWD_TIME := 90.0
const HIT_DIST := 25.0

var level: EdirneYard
var player: Player
var hud: Hud
var meter: RowMeter
var balance: BalanceMeter
var drill: GunDrill
var crew: CannonCrew
var cam: TespitCam
var phase := "intro"
var _outcome := ""
var _photo := ""

var urban: Person
var foreman: Person
var mason: Person
var herald: Person
var drummer: Person
var fatih: Person
var _workers: Array[Person] = []
var _fire_men: Array[Person] = []

# skor
var nicks := 0
var slips := 0
var calls_ok := 0
var runaway_stopped := 0
var crowd_saved := 0
var jam := false
var cracked_passed := false
var sparks := 0
var blasted := false
var hit := false


func _ready() -> void:
	GameState.snapshot(34)
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
	meter.stroke.connect(_on_stroke)
	balance = BalanceMeter.new()
	balance.visible = false
	hud.add_child(balance)
	balance.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	balance.position = Vector2(-210, -230)
	drill = GunDrill.new()
	hud.add_child(drill)
	level = EdirneYard.new()
	add_child(level)
	_build_people()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _variant() -> String:
	return GameState.autotest_variant if GameState.autotest else ""


func _gy(p: Vector3) -> Vector3:
	return Vector3(p.x, level.floor_y(p.x, p.z) if level else EdirneYard.ground_y(p.x, p.z), p.z)


func _worker(coat: Color, hat := "bork") -> Person:
	var w := Person.new({"coat": coat, "pants": Color("e8e0d0"), "hat": hat, "mustache": true, "skin": Color("c89070")})
	w.set_meta("no_talk", true)
	add_child(w)
	return w


func _build_people() -> void:
	urban = Person.new({"coat": Color("4a3a2a"), "pants": Color("3a2a22"), "hat": "kalpak", "beard": true, "mustache": true, "hair": Color("6a5040"), "face": "urban"})
	urban.set_meta("spk", "SPK_URBAN")
	add_child(urban)
	urban.position = _gy(Vector3(-3.4, 0, -3.0))
	urban.look_target = player
	foreman = _worker(Color("6a4a3a"), "turban")
	foreman.set_meta("spk", "SPK_SOLDIER")
	foreman.position = _gy(EdirneYard.WIND_FRONT + Vector3(1.4, 0, 0))
	foreman.rotation.y = -PI * 0.5
	# Öbür yanda tokmakla vuran iki işçi
	for k in 2:
		var w := _worker(Color("7a6a50") if k == 0 else Color("8a6a4a"))
		w.position = _gy(Vector3(EdirneYard.PIT_HX + 0.7, 0, -1.6 + k * 3.2))
		w.rotation.y = -PI * 0.5
		w.set_activity("hammer")
		_workers.append(w)
	mason = Person.new({"coat": Color("8a7a60"), "pants": Color("e8e0d0"), "hat": "turban", "beard": true, "hair": Color("b8b4a8"), "skin": Color("c89070")})
	mason.set_meta("spk", "SPK_MASON")
	add_child(mason)
	mason.position = _gy(EdirneYard.CHUTE_TOP + Vector3(1.6, 0, -1.4))
	mason.set_activity("hammer")
	# Ateş başındaki işçiler (oturur)
	for k in 3:
		var a := -0.8 + k * 0.8
		var w := _worker(Color("5a4a3a"))
		w.position = _gy(EdirneYard.FIRE + Vector3(sin(a) * 1.6, 0, -cos(a) * 1.6))
		w.look_at(Vector3(EdirneYard.FIRE.x, w.position.y, EdirneYard.FIRE.z), Vector3.UP, true)
		w.set_activity("sit_ground")
		_fire_men.append(w)
	# İpin arkasında uzak kalabalık (Edirneliler)
	var items: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 3410
	var coats := [Color("6a4a3a"), Color("4a5a6a"), Color("8a6a4a"), Color("5a3a3a"), Color("6a6a5a"), Color("3a4a3a")]
	for i in 70:
		var p := Vector3(rng.randf_range(-14.0, 22.0), 0, rng.randf_range(-19.0, -11.5))
		if p.distance_to(EdirneYard.SULTAN_SPOT) < 6.0 or (p.x > 9.0 and p.z < -12.0):
			continue
		p = _gy(p)
		items.append([Transform3D(Basis(Vector3.UP, rng.randf_range(-0.4, 0.4)), p),
			{"side": "C", "coat": coats[i % coats.size()], "hat": ["turban", "bork", "scarf"][i % 3], "pose": ""}])
	Crowd.place(self, items, true, false)


func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH34O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH34O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = _gy(Vector3(-EdirneYard.PIT_HX - 0.9, 0, -0.8)) + Vector3(0, 0.05, 0)
	player.face(level.gun.global_position)
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D34O_N_01")
	await hud.say("SPK_TOLGA", "D34O_T_01")
	var lost33 := String(GameState.chapter_outcomes.get(33, "")) == "33O.2"
	await hud.say("SPK_URBAN", "D34O_U_01_ALT" if lost33 else "D34O_U_01")
	await hud.say("SPK_URBAN", "D34O_U_02")
	Lore.scatter(self, "34o", [_gy(Vector3(-6.0, 0, -6.0)) + Vector3(0, 0.3, 0), _gy(Vector3(-24.0, 0, -6.0)) + Vector3(0, 0.3, 0),
		_gy(Vector3(10.0, 0, -11.0)) + Vector3(0, 0.3, 0)])
	await _break_mould()
	await _crank()
	await _balls()
	await _crowd()
	await _test_shot()
	await _end_chapter()


# ================================================================ 1a. kalıbı kır

var _hits := 0
var _mallet: Node3D
var _break_t := 0.0


func _player_chunks() -> Array:
	# Oyuncunun tarafındaki (dünyada −x) kil parçaları; yoksa herhangi biri
	var out: Array = []
	for i in level.clay.size():
		var c: MeshInstance3D = level.clay[i]
		if c != null and c.global_position.x < 0.15:
			out.append(i)
	if out.is_empty():
		for i in level.clay.size():
			if level.clay[i] != null:
				out.append(i)
	return out


func _clay_left() -> int:
	var n := 0
	for c in level.clay:
		if c != null:
			n += 1
	return n


func _break_mould() -> void:
	phase = "break"
	player.frozen = false
	_mallet = Node3D.new()
	player.camera.add_child(_mallet)
	_mallet.position = Vector3(0.35, -0.4, -0.75)
	Props.cyl(_mallet, 0.03, 0.8, Vector3(0, 0.0, 0), Color("6a4a2c"), Vector3(-60, 0, 0), 6)
	Props.cyl(_mallet, 0.11, 0.32, Vector3(0, 0.36, -0.2), Color("8a6a44"), Vector3(0, 0, 90), 8)
	Props.strip_outlines(_mallet)
	var left := BREAK_TIME
	var work_t := 2.0
	var bad_left := 3 if _variant() == "bad" else 0
	while _hits < BREAK_HITS and _clay_left() > 0 and left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		var near := _near_barrel()
		meter.enabled = near
		hud.set_objective(tr("UI_OBJ34O_BREAK") % [_hits, BREAK_HITS], level.gun.global_position + Vector3(0, 1.0, 0))
		hud.set_prompt(tr("UI_PROMPT34O_STRIKE") if near else "")
		# Öbür yandaki işçiler kendi ritimlerinde vurur
		work_t -= dt
		if work_t <= 0.0:
			work_t = randf_range(3.2, 4.6)
			for i in range(level.clay.size() - 1, -1, -1):
				var c: MeshInstance3D = level.clay[i]
				if c != null and c.global_position.x > 0.15:
					level.break_clay(i)
					Audio.sfx("land_thud", -10.0, 1.2)
					break
		if GameState.autotest:
			player.global_position = _gy(Vector3(-EdirneYard.PIT_HX - 0.6, 0, -0.8)) + Vector3(0, 0.05, 0)
			# =bad: üç kez erken vurur (kırmızı)
			if bad_left > 0 and meter.enabled and meter.phase > 0.3 and meter.phase < 0.5 and not meter._pressed_this:
				bad_left -= 1
				meter.press()
	meter.enabled = false
	hud.set_prompt("")
	hud.set_objective("")
	# Kalan kili işçiler kırar
	for i in level.clay.size():
		if level.clay[i] != null:
			level.break_clay(i)
			await get_tree().create_timer(0.12).timeout
	_mallet.queue_free()
	player.frozen = true


func _near_barrel() -> bool:
	var p := player.global_position
	return absf(p.z) < EdirneYard.PIT_HZ - 0.3 and absf(p.x) < EdirneYard.PIT_HX + 2.0


func _swing_mallet() -> void:
	if not is_instance_valid(_mallet):
		return
	var tw := _mallet.create_tween()
	tw.tween_property(_mallet, "rotation:x", 0.9, 0.12)
	tw.tween_property(_mallet, "rotation:x", -0.5, 0.1)
	tw.tween_property(_mallet, "rotation:x", 0.0, 0.25)


func _on_stroke(good: bool) -> void:
	match phase:
		"break":
			_swing_mallet()
			if good:
				var ch := _player_chunks()
				if not ch.is_empty():
					level.break_clay(ch[0])
				_hits += 1
				player.shake(0.12)
				if _hits == 1:
					hud.bark("SPK_URBAN", "D34O_U_HIT_OK", 2.5)
				if _hits == 4:
					hud.bark("SPK_TOLGA", "D34O_T_02", 4.0)
			else:
				nicks += 1
				level.add_nick(randf_range(-2.8, 2.8))
				Audio.sfx("kick_metal", -4.0, 1.5)
				player.shake(0.25)
				hud.bark("SPK_URBAN", "D34O_U_HIT_BAD", 3.0)
		"crank":
			_crank_stroke(good)


# ================================================================ 1b. çıkrık

var _rear := 0.0          # arka (Tolga) yükseklik
var _front := 0.0         # ön (ustabaşı)
var _good_run := 0
var _pawl_due := 0.0
var _red_t := 0.0
var _gun_base_y := 0.0


func _set_gun_lift() -> void:
	var avg := (_rear + _front) * 0.5
	var tilt := _rear - _front
	level.gun.position.y = _gun_base_y + avg
	# Kök π döndürülmüş: yerel +x ekseni etrafında (dünya −x) eğim
	level.gun.rotation = Vector3(atan2(tilt, EdirneYard.BAND_Z * 2.0), PI, 0)
	level.update_chains()
	for k in 2:
		var sp: MeshInstance3D = level.spools[k]
		var h := _rear if k == 0 else _front
		sp.scale = Vector3(1.0 + h * 0.12, 1.0, 1.0 + h * 0.12)


func _crank() -> void:
	phase = "crank"
	_gun_base_y = level.gun.position.y
	player.global_position = _gy(EdirneYard.WIND_REAR + Vector3(1.5, 0, 0)) + Vector3(0, 0.05, 0)
	player.face(EdirneYard.WIND_REAR + Vector3(0, 1.1, 0))
	foreman.look_target = null
	hud.bark("SPK_SOLDIER", "D34O_S_CRANK", 3.0)
	player.frozen = true
	meter.enabled = true
	balance.visible = true
	balance.label_text = tr("UI_OBJ34O_CRANK") % [0, int(EdirneYard.LIFT)]
	var left := CRANK_TIME
	var fore_skip := 0
	var last_phase := meter.phase
	var tilt_warned := false
	while (_rear + _front) * 0.5 < EdirneYard.LIFT and left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		# Ustabaşı: her evrenin ortasında çevirir; ara sıra soluklanır (bir evre bekler) ya da hızlanır (iki çevirme)
		if meter.phase < last_phase:
			if fore_skip > 0:
				fore_skip -= 1
			else:
				var r := randf()
				_turn(1)
				if r < 0.16:
					fore_skip = 1
				elif r < 0.26:
					# Hızlanır (bir çevirme daha), sonra soluklanır
					get_tree().create_timer(0.5).timeout.connect(_fore_extra)
					fore_skip = 1
		last_phase = meter.phase
		if Input.is_action_just_pressed("jump"):
			meter.press()
		# Mandal
		if _pawl_due > 0.0:
			_pawl_due -= dt
			hud.set_qte(tr("UI_OBJ34O_PAWL"))
			if Input.is_action_just_pressed("interact") or GameState.autotest:
				_drop_pawl()
			elif _pawl_due <= 0.0:
				# Tambur geri boşalır
				hud.set_qte("")
				_rear = maxf(0.0, _rear - 0.5)
				var hub: Node3D = level.drums[0]
				hub.create_tween().tween_property(hub, "rotation:x", hub.rotation.x - PI * 3.0, 0.5)
				Audio.sfx("ship_haul", -2.0, 1.6)
				hud.bark("SPK_URBAN", "D34O_U_PAWL", 3.0)
				_set_gun_lift()
		var tilt := _rear - _front
		balance.value = clampf(tilt / 0.6, -1.2, 1.2)
		balance.label_text = tr("UI_OBJ34O_CRANK") % [int((_rear + _front) * 0.5), int(EdirneYard.LIFT)]
		if absf(balance.value) > 0.8:
			_red_t += dt
			if not tilt_warned:
				tilt_warned = true
				hud.bark("SPK_URBAN", "D34O_U_TILT", 2.5)
			if _red_t > 1.0:
				_slip()
		else:
			_red_t = 0.0
			if absf(balance.value) < 0.4:
				tilt_warned = false
		hud.set_objective(tr("UI_OBJ34O_CRANK") % [int((_rear + _front) * 0.5), int(EdirneYard.LIFT)])
	meter.enabled = false
	balance.visible = false
	hud.set_qte("")
	hud.set_objective("")
	if (_rear + _front) * 0.5 < EdirneYard.LIFT:
		# Süre doldu: ustalar kaldırır
		var tw := create_tween()
		tw.tween_method(_lift_both, (_rear + _front) * 0.5, EdirneYard.LIFT, 2.0)
		await tw.finished
	await _onto_sled()


func _fore_extra() -> void:
	if phase == "crank":
		_turn(1)


## Bot için: ustabaşının önüne geçmemek üzere basmalı mı?
func _bot_should_press() -> bool:
	if _variant() == "bad":
		return true
	return _rear - _front < 0.05


func _lift_both(v: float) -> void:
	_rear = v
	_front = v
	_set_gun_lift()


func _turn(side: int) -> void:
	# side 0: Tolga (arka), 1: ustabaşı (ön)
	if side == 0:
		_rear += STEP_UP
	else:
		_front += STEP_UP
		foreman.set_activity("row")
	var hub: Node3D = level.drums[side]
	hub.create_tween().tween_property(hub, "rotation:x", hub.rotation.x + PI * 0.5, 0.35)
	Audio.sfx("ship_haul", -14.0, 1.0 + side * 0.2)
	_set_gun_lift()


func _crank_stroke(good: bool) -> void:
	if not good:
		return
	_turn(0)
	_good_run += 1
	if _good_run >= 3:
		_good_run = 0
		_pawl_due = 1.5


func _drop_pawl() -> void:
	_pawl_due = 0.0
	hud.set_qte("")
	for pw: Node3D in level.pawls:
		var tw := pw.create_tween()
		tw.tween_property(pw, "rotation:x", 0.1, 0.12)
		tw.tween_property(pw, "rotation:x", -0.6, 0.3)
	Audio.sfx("land_pot", -12.0, 1.8)


func _slip() -> void:
	slips += 1
	_red_t = 0.0
	# Yüksek taraftaki zincir kayar: o uç 0,5 m düşer
	if _rear > _front:
		_rear = maxf(_front, _rear - 0.5)
	else:
		_front = maxf(_rear, _front - 0.5)
	_set_gun_lift()
	Fx.trauma(0.4)
	Audio.sfx("kick_metal", -2.0, 0.6)
	Vfx.dust(self, level.gun.global_position + Vector3(0, -0.5, 0), 1.0)
	for w: Person in _workers:
		var tw := w.create_tween()
		tw.tween_property(w, "position", w.position + Vector3(1.2, 0, 0), 0.25)
		tw.tween_property(w, "position", w.position, 1.2)
	hud.bark("SPK_URBAN", "D34O_U_SLIP", 4.0)
	print("CHAIN_SLIP %d" % slips) if GameState.autotest else null


func _input(event: InputEvent) -> void:
	if phase == "break" and event.is_action_pressed("interact"):
		meter.press()
	if phase == "balls" and _ball_waiting:
		if event.is_action_pressed("interact"):
			_decide(true)
		elif event.is_action_pressed("kick"):
			_decide(false)
	if event.is_action_pressed("interact"):
		match phase:
			"runaway":
				_try_chock()
			"crowd":
				_try_shoo()


func _process(delta: float) -> void:
	if phase == "crank" and GameState.autotest and meter.enabled:
		# Bot: evrenin ortasında, ustabaşının önüne geçmiyorsa basar (RowMeter'in kendi otomatiğinden önce)
		if not meter._pressed_this and meter.phase > RowMeter.WIN_A + 0.02:
			if _bot_should_press():
				meter.press()
				# =bad: ustabaşının önüne geçer (aceleyle bir çevirme daha)
				if _variant() == "bad" and randf() < 0.45:
					_turn(0)
			else:
				meter._pressed_this = true
	if _runaway:
		_roll_runaway(delta)
	if phase == "crowd":
		_crowd_tick(delta)
	if phase == "hang" or phase == "prime":
		_hang_tick(delta)


func _onto_sled() -> void:
	hud.bark("SPK_URBAN", "D34O_U_LIFTED", 5.0)
	# Kızak çukurun üstüne sürülür, namlu iner; çukurun üstü kalaslarla kapanır
	var st := level.sled.create_tween()
	st.tween_property(level.sled, "position", Vector3(0, 0, 0), 2.4).set_trans(Tween.TRANS_SINE)
	await st.finished
	var deck := Props.solid(level, Vector3(EdirneYard.PIT_HX * 2.0 + 0.6, 0.2, EdirneYard.PIT_HZ * 2.0 + 0.6), Vector3(0, -0.1, 0), Color("7a5a3a"))
	deck.set_meta("ball_through", true)
	level.deck = true
	var y_to := EdirneYard.SLED_Y + EdirneYard.BARREL_R
	var gt := level.gun.create_tween()
	gt.tween_property(level.gun, "position:y", y_to, 2.0).set_trans(Tween.TRANS_SINE)
	gt.parallel().tween_property(level.gun, "rotation", Vector3(0, PI, 0), 2.0)
	gt.tween_property(level.sled, "position:y", -0.02, 0.15)
	gt.tween_callback(func():
		Audio.sfx("land_thud", -2.0, 0.6)
		Fx.trauma(0.2))
	while gt.is_running():
		level.update_chains()
		await get_tree().process_frame
	# Zincirler çözülür
	for c in level.chains:
		c.visible = false
	foreman.set_activity("")
	await get_tree().create_timer(1.0).timeout
	hud.bark("SPK_TOLGA", "D34O_T_REVEAL", 4.0)
	await get_tree().create_timer(2.0).timeout


# ================================================================ 2. gülle oluğu

var _ball: Node3D
var _ball_i := 0
var _ball_waiting := false
var _ball_decision := ""
var _runaway := false
var _run_v := 0.0
var _run_t := 0.0


func _balls() -> void:
	phase = "balls_walk"
	await hud.fade_to(1.0, 0.6)
	player.global_position = _gy(EdirneYard.RING + Vector3(1.6, 0, -1.4)) + Vector3(0, 0.05, 0)
	player.face(EdirneYard.RING + Vector3(0, 1.0, 0))
	await hud.fade_to(0.0, 0.6)
	await hud.say("SPK_MASON", "D34O_M_01")
	hud.bark("SPK_TOLGA", "D34O_T_03", 3.0)
	player.frozen = false
	for i in BALLS:
		_ball_i = i
		await _one_ball(i)
	phase = "balls_done"
	hud.set_objective("")
	hud.set_prompt("")
	if calls_ok == BALLS:
		hud.bark("SPK_MASON", "D34O_M_DONE", 3.5)
	await get_tree().create_timer(1.5).timeout
	player.frozen = true


func _one_ball(i: int) -> void:
	var big_ball := i == 1
	var crack := i == 5
	var r := 0.46 if big_ball else 0.34
	_ball = Node3D.new()
	add_child(_ball)
	var mesh := Props.ball(_ball, r, Vector3.ZERO, Color("b8b4aa").darkened(0.04 * (i % 3)), Vector3.ONE, 10)
	mesh.name = "Mesh"
	if crack:
		var c := Props.box(_ball, Vector3(0.012, 0.5, 0.02), Vector3(0, 0.02, r - 0.004), Color("2a2622"))
		c.rotation.z = 0.5
		c.visibility_range_end = 2.2
	var top := level.chute_top() + Vector3(0, r - 0.32, 0)
	var bot := level.chute_bot() + Vector3(0, r - 0.32, 0)
	_ball.global_position = top
	Audio.sfx("ship_haul", -10.0, 0.7)
	var tw := _ball.create_tween()
	tw.tween_property(_ball, "global_position", bot, 2.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(mesh, "rotation:x", 18.0, 2.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw.finished
	Audio.sfx("land_thud", -6.0, 0.8)
	# Dördüncü gülle: takozu atlar
	if i == 3:
		await get_tree().create_timer(1.2).timeout
		await _runaway_ball()
		_ball.queue_free()
		return
	_ball_waiting = true
	_ball_decision = ""
	var wait := BALL_WAIT
	var bot_t := 0.0
	while _ball_decision == "" and wait > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		wait -= dt
		hud.set_objective(tr("UI_OBJ34O_BALL") % [i + 1, BALLS], EdirneYard.RING + Vector3(0, 1.0, 0))
		var near := player.global_position.distance_to(_ball.global_position) < 4.0
		hud.set_prompt(tr("UI_PROMPT34O_ACCEPT") if near else "")
		if GameState.autotest:
			bot_t += dt
			if bot_t > 1.0:
				if _variant() == "bad":
					_decide(true)
				else:
					_decide(not (big_ball or crack))
	_ball_waiting = false
	hud.set_prompt("")
	if _ball_decision == "":
		# Karar yok: gülle takozu atlar
		await _runaway_ball()
		_ball.queue_free()
		return
	var accept := _ball_decision == "accept"
	var correct := accept == (not big_ball and not crack)
	if correct:
		calls_ok += 1
	if accept:
		if big_ball:
			jam = true
		if crack:
			cracked_passed = true
			hud.bark("SPK_MASON", "D34O_M_WRONG", 3.0)
		elif correct:
			hud.bark("SPK_MASON", "D34O_M_GOOD", 2.0)
		var to := _gy(EdirneYard.CART) + Vector3(0, 1.0 + r, 0)
		var at := _ball.create_tween()
		at.tween_property(_ball, "global_position", to, 1.0).set_trans(Tween.TRANS_SINE)
		await at.finished
		Audio.sfx("land_thud", -8.0, 0.9)
	else:
		if big_ball:
			hud.bark("SPK_MASON", "D34O_M_BIG", 3.0)
		elif crack:
			hud.bark("SPK_MASON", "D34O_M_CRACK", 3.0)
		else:
			hud.bark("SPK_MASON", "D34O_M_WRONG", 3.0)
		var to2 := _gy(EdirneYard.REJECT) + Vector3(0, r, 0)
		var rt := _ball.create_tween()
		rt.tween_property(_ball, "global_position", to2, 0.9).set_trans(Tween.TRANS_QUAD)
		await rt.finished
		Vfx.dust(self, to2, 0.3)
	# Sepete giden gülleler sahnede kalmaz (araba dolu görünmesin diye küçülür)
	var b := _ball
	get_tree().create_timer(1.5).timeout.connect(func():
		if is_instance_valid(b):
			b.queue_free())
	await get_tree().create_timer(0.6).timeout


func _decide(accept: bool) -> void:
	if not _ball_waiting or _ball_decision != "":
		return
	_ball_decision = "accept" if accept else "reject"


func _runaway_ball() -> void:
	phase = "runaway"
	hud.bark("SPK_MASON", "D34O_M_RUN", 3.0)
	await get_tree().create_timer(0.6).timeout
	hud.bark("SPK_TOLGA", "D34O_T_RUN", 3.0)
	# Takoz atlar: gülle yamaçtan ateşe doğru
	_ball.global_position = _gy(EdirneYard.CHUTE_BOT + Vector3(0, 0, 1.0)) + Vector3(0, 0.34, 0)
	_runaway = true
	_run_v = 1.0
	_run_t = 0.0
	var bot_done := false
	while _runaway:
		await get_tree().process_frame
		hud.set_objective(tr("UI_OBJ34O_RUNAWAY"), _ball.global_position + Vector3(0, 0.8, 0))
		var near := player.global_position.distance_to(_ball.global_position) < 2.2
		hud.set_prompt(tr("UI_PROMPT34O_CHOCK") if near else "")
		if GameState.autotest and _variant() != "bad" and not bot_done and _run_t > 0.8:
			bot_done = true
			player.global_position = _ball.global_position + Vector3(0.9, 0.0, 1.6)
			_try_chock()
	hud.set_prompt("")
	hud.set_objective("")
	phase = "balls"


func _roll_runaway(delta: float) -> void:
	_run_t += delta
	_run_v = minf(7.0, _run_v + delta * 1.6)
	var p := _ball.global_position
	var to := EdirneYard.FIRE
	var dir := Vector3(to.x - p.x, 0, to.z - p.z)
	var d := dir.length()
	dir = dir / maxf(d, 0.01)
	p += dir * _run_v * delta
	# Tümsekte seker
	var bump := 0.12 * absf(sin(_run_t * 5.0)) * (_run_v / 7.0)
	p.y = EdirneYard.ground_y(p.x, p.z) + 0.34 + bump
	_ball.global_position = p
	(_ball.get_node("Mesh") as Node3D).rotation.x += _run_v * delta / 0.34
	# Karda iz
	if Engine.get_process_frames() % 6 == 0:
		var tr_m := Props.box(self, Vector3(0.35, 0.02, 0.5), Vector3(p.x, EdirneYard.ground_y(p.x, p.z) + 0.01, p.z), Color("c8ccd0"))
		tr_m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		get_tree().create_timer(20.0).timeout.connect(tr_m.queue_free)
	# Oyuncuya çarpma
	if player.global_position.distance_to(p) < 0.8 and _run_v > 2.0:
		player.hurt(20.0, p)
		player.stagger(1.2)
		_run_v *= 0.6
	if d < 1.8:
		# Ateşe çarptı: kıvılcım, işçiler kaçar
		_runaway = false
		Vfx.explosion(self, to + Vector3(0, 0.5, 0), 0.5)
		Audio.sfx("land_thud", 0.0, 0.7)
		for w: Person in _fire_men:
			w.set_activity("")
			var away := (w.position - to).normalized() * 5.0
			w.create_tween().tween_property(w, "position", _gy(w.position + away), 1.2)


func _try_chock() -> void:
	if not _runaway or not is_instance_valid(_ball):
		return
	if player.global_position.distance_to(_ball.global_position) > 2.2:
		return
	_runaway = false
	runaway_stopped += 1
	calls_ok += 1
	# Takoz önüne atılır, gülle durur; kar püskürür
	var p := _ball.global_position
	var ck := Props.prism(self, Vector3(0.6, 0.22, 0.28), _gy(p + Vector3(0, 0, 0.45)) + Vector3(0, 0.1, 0), Color("4a3424"))
	ck.rotation.y = 0.0
	Vfx.dust(self, p, 0.7)
	Audio.sfx("land_thud", -2.0, 1.1)
	player.shake(0.3)
	hud.bark("SPK_MASON", "D34O_M_STOP", 3.0)
	get_tree().create_timer(6.0).timeout.connect(ck.queue_free)


# ================================================================ 3. tellal ve kızaklar

var _folk: Array = []          # [{"p": Person, "kind": "adult"|"kid", "state": "field"|"saved"|"sled", ...}]
var _crowd_left := 0.0
var _ice_t := 0.0
var _down_t := 0.0


func _crowd() -> void:
	phase = "crowd_intro"
	await hud.fade_to(1.0, 0.6)
	player.global_position = _gy(Vector3(4.0, 0, -6.0)) + Vector3(0, 0.05, 0)
	player.face(Vector3(4.0, 1.5, 20.0))
	herald = Person.new({"coat": Color("2a5a8a"), "pants": Color("e8e0d0"), "hat": "turban", "beard": true, "skin": Color("c89070")})
	herald.set_meta("spk", "SPK_HERALD")
	add_child(herald)
	herald.position = _gy(Vector3(-12.0, 0, -7.0))
	drummer = _worker(Color("8a2b22"))
	drummer.position = _gy(Vector3(-13.2, 0, -7.6))
	drummer.set_activity("hammer")
	Props.cyl(drummer, 0.3, 0.4, Vector3(0, 0.95, 0.35), Color("c8a070"), Vector3(90, 0, 0), 10)
	for n: Person in [herald, drummer]:
		n.create_tween().tween_property(n, "position", _gy(n.position + Vector3(30.0, 0, 0)), 40.0)
	# Tehlike alanındakiler: dört yetişkin, iki kızaklı çocuk
	var specs := [
		[{"coat": Color("7a3a3a"), "pants": Color("4a3a3a"), "hat": "scarf", "skin": Color("d8a888"), "female": true}, "woman", Vector3(-4.0, 0, 22.0)],
		[{"coat": Color("5a5a4a"), "pants": Color("4a4a3a"), "hat": "turban", "beard": true, "hair": Color("c8c4b8"), "skin": Color("c89070")}, "old", Vector3(8.0, 0, 34.0)],
		[{"coat": Color("6a4a2a"), "pants": Color("4a3a2a"), "hat": "bork", "mustache": true, "skin": Color("c89070")}, "carter", Vector3(-10.0, 0, 48.0)],
		[{"coat": Color("4a6a5a"), "pants": Color("4a4a3a"), "hat": "bork", "skin": Color("d0a07a")}, "boy", Vector3(12.0, 0, 60.0)],
	]
	for s: Array in specs:
		var p := Person.new(s[0])
		p.set_meta("no_talk", true)
		if s[1] == "woman":
			p.set_meta("spk", "SPK_WOMAN")
			p.equip("basket")
		elif s[1] == "carter":
			p.equip("plank")
		add_child(p)
		p.position = _gy(s[2])
		_folk.append({"p": p, "kind": "adult", "who": s[1], "state": "field", "home": s[2], "t": randf() * 6.0})
	for k in 2:
		var kid := Person.new({"coat": [Color("b3462d"), Color("3a6a9a")][k], "pants": Color("4a3a2a"), "hat": "bork", "skin": Color("d8a888"), "child": true})
		kid.set_meta("no_talk", true)
		add_child(kid)
		var sled := Node3D.new()
		add_child(sled)
		Props.box(sled, Vector3(0.5, 0.08, 1.1), Vector3(0, 0.12, 0), Color("6a4a2c"))
		for sx: float in [-0.22, 0.22]:
			Props.box(sled, Vector3(0.05, 0.06, 1.2), Vector3(sx, 0.04, 0), Color("4a3424"))
		_folk.append({"p": kid, "kind": "kid", "state": "slide", "sled": sled, "s": 0.35 + k * 0.45, "lane": -1.6 + k * 3.2, "t": 0.0})
	await hud.fade_to(0.0, 0.6)
	hud.bark("SPK_HERALD", "D34O_HR_01", 5.0)
	get_tree().create_timer(6.0).timeout.connect(func(): hud.bark("SPK_HERALD", "D34O_HR_02", 5.0))
	phase = "crowd"
	player.frozen = false
	_crowd_left = CROWD_TIME
	var kids_said := false
	var bot_t := 0.0
	while _crowd_left > 0.0 and crowd_saved < 6:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		_crowd_left -= dt
		hud.set_objective(tr("UI_OBJ34O_CROWD") % [crowd_saved, 6, ceili(_crowd_left)], _nearest_folk_pos())
		if not kids_said and player.global_position.z > 30.0:
			kids_said = true
			hud.bark("SPK_TOLGA", "D34O_T_KIDS", 3.5)
		if GameState.autotest:
			bot_t += dt
			if bot_t > 1.2:
				bot_t = 0.0
				_bot_crowd_step()
	if crowd_saved < 6:
		hud.bark("SPK_URBAN", "D34O_U_LATE", 4.0)
		for f: Dictionary in _folk:
			if f["state"] != "saved":
				_send_behind(f)
	else:
		hud.bark("SPK_TOLGA", "D34O_T_CROWD_OK", 3.5)
	phase = "crowd_done"
	balance.visible = false
	hud.set_prompt("")
	hud.set_objective("")
	await get_tree().create_timer(3.0).timeout
	player.frozen = true


func _nearest_folk_pos() -> Vector3:
	var best := Vector3.ZERO
	var bd := INF
	for f: Dictionary in _folk:
		if f["state"] == "saved":
			continue
		var p: Vector3 = (f["p"] as Node3D).global_position
		var d := p.distance_to(player.global_position)
		if d < bd:
			bd = d
			best = p + Vector3(0, 2.0, 0)
	return best


func _crowd_tick(delta: float) -> void:
	var prompt := ""
	for f: Dictionary in _folk:
		var p: Person = f["p"]
		if f["state"] == "saved":
			continue
		if f["kind"] == "adult":
			# Alanda gezinir (küçük daire)
			f["t"] = float(f["t"]) + delta
			var h: Vector3 = f["home"]
			var t: float = f["t"]
			var to := _gy(h + Vector3(sin(t * 0.25) * 4.0, 0, cos(t * 0.21) * 3.0))
			var mv := to - p.position
			if Vector2(mv.x, mv.z).length() > 0.002:
				p.rotation.y = atan2(mv.x, mv.z)
			p.position = to
			if p.global_position.distance_to(player.global_position) < 2.5:
				prompt = "UI_PROMPT34O_SHOO"
		else:
			_kid_tick(f, delta)
			if f["state"] == "slide" and float(f["s"]) > 0.55 and (f["sled"] as Node3D).global_position.distance_to(player.global_position) < 2.2:
				prompt = "UI_PROMPT34O_SLED"
	hud.set_prompt(tr(prompt) if prompt != "" else "")
	_ice(delta)


func _kid_tick(f: Dictionary, delta: float) -> void:
	var p: Person = f["p"]
	var sled: Node3D = f["sled"]
	var lane: float = f["lane"]
	var top := EdirneYard.SLED_TOP + Vector3(lane, 0, 0)
	var bot := EdirneYard.POND + Vector3(lane, 0, -1.0)
	match String(f["state"]):
		"slide":
			# Yamaçtan aşağı: hızlanarak; dipte birikintiye varınca yukarı yürür
			f["s"] = minf(1.0, float(f["s"]) + delta * (0.06 + 0.12 * float(f["s"])))
			var q := top.lerp(bot, float(f["s"]))
			q.y = EdirneYard.ground_y(q.x, q.z)
			sled.global_position = q
			sled.look_at(q + (bot - top).normalized(), Vector3.UP, true)
			p.global_position = q + Vector3(0, 0.12, 0)
			p.rotation = sled.rotation
			p.set_activity("sit")
			if int(Engine.get_process_frames()) % 8 == 0:
				Vfx.dust(self, q, 0.15)
			if float(f["s"]) >= 1.0:
				f["state"] = "climb"
				f["s"] = 1.0
		"climb":
			f["s"] = maxf(0.0, float(f["s"]) - delta * 0.05)
			var q2 := top.lerp(bot, float(f["s"])) + Vector3(0.9, 0, 0)
			q2.y = EdirneYard.ground_y(q2.x, q2.z)
			p.set_activity("")
			p.global_position = q2
			p.rotation = Vector3(0, PI, 0)
			sled.global_position = q2 + Vector3(0.6, 0, 0.6)
			if float(f["s"]) <= 0.0:
				f["state"] = "slide"


func _try_shoo() -> void:
	for f: Dictionary in _folk:
		if f["state"] == "saved":
			continue
		var p: Person = f["p"]
		if f["kind"] == "adult" and p.global_position.distance_to(player.global_position) < 2.5:
			_save(f)
			return
		if f["kind"] == "kid" and f["state"] == "slide" and float(f["s"]) > 0.55 and (f["sled"] as Node3D).global_position.distance_to(player.global_position) < 2.2:
			# Kızak durur, yan döner; çocuk kalkar, silkinir, ipe koşar
			var sled: Node3D = f["sled"]
			sled.create_tween().tween_property(sled, "rotation:y", sled.rotation.y + 1.4, 0.4)
			Vfx.dust(self, sled.global_position, 0.6)
			Audio.sfx("land_thud", -10.0, 1.4)
			_save(f)
			return


func _save(f: Dictionary) -> void:
	f["state"] = "saved"
	crowd_saved += 1
	var p: Person = f["p"]
	match String(f.get("who", "")):
		"woman":
			hud.bark("SPK_WOMAN", "D34O_W_01", 3.0)
			get_tree().create_timer(3.2).timeout.connect(func(): hud.bark("SPK_TOLGA", "D34O_T_W1", 3.0))
			get_tree().create_timer(6.4).timeout.connect(func(): hud.bark("SPK_WOMAN", "D34O_W_02", 2.5))
		"old":
			hud.bark("SPK_TOWNSMAN", "D34O_TW_01", 4.0)
	_send_behind(f)


func _send_behind(f: Dictionary) -> void:
	f["state"] = "saved"
	var p: Person = f["p"]
	p.set_activity("")
	p.rotation = Vector3.ZERO
	var to := _gy(Vector3(randf_range(-10.0, 6.0), 0, randf_range(-14.0, -11.0)))
	var d := p.global_position.distance_to(to)
	p.look_at(Vector3(to.x, p.global_position.y, to.z), Vector3.UP, true)
	var tw := p.create_tween()
	tw.tween_method(func(k: float): p.global_position = _gy(p.global_position.lerp(to, k)), 0.0, 1.0, maxf(2.0, d / 3.0))
	tw.tween_callback(func(): p.rotation.y = 0.0)


func _bot_crowd_step() -> void:
	for f: Dictionary in _folk:
		if f["state"] == "saved":
			continue
		if f["kind"] == "adult":
			player.global_position = (f["p"] as Node3D).global_position + Vector3(1.2, 0.05, 0)
			_try_shoo()
			return
		if f["kind"] == "kid" and f["state"] == "slide" and float(f["s"]) > 0.6:
			player.global_position = (f["sled"] as Node3D).global_position + Vector3(1.2, 0.05, 0.6)
			_try_shoo()
			return


## Buzlu birikinti: üstünde kayarsın (denge); düşersen 3 sn yerdesin
func _ice(delta: float) -> void:
	var p := player.global_position
	var on := Vector2(p.x - EdirneYard.POND.x, p.z - EdirneYard.POND.z).length() < EdirneYard.POND_R
	if _down_t > 0.0:
		_down_t -= delta
		if _down_t <= 0.0:
			player.frozen = false
		return
	if on and not GameState.autotest:
		if not balance.visible:
			balance.visible = true
			balance.value = randf_range(-0.2, 0.2)
			_ice_t = 0.0
			hud.bark("SPK_TOLGA", "D34O_T_ICE", 2.5)
		_ice_t += delta
		balance.value += (signf(balance.value) * 0.9 + randf_range(-0.5, 0.5)) * delta
		balance.value -= Input.get_axis("move_left", "move_right") * 1.8 * delta
		player.global_position += Vector3(sin(_ice_t * 2.0), 0, cos(_ice_t * 1.3)) * 0.8 * delta
		if absf(balance.value) >= 1.0:
			balance.visible = false
			player.frozen = true
			player.hurt(5.0, Vector3.INF, true)
			Vfx.dust(self, p, 0.6)
			_down_t = 3.0
	elif balance.visible:
		balance.visible = false


# ================================================================ 4. deneme atışı

var _smoke_t := 0.0
var _smoke_on := false
var _primed := 0.0
var _puff_t := 0.0
var _grace := 0.0
var _horses: Array[Horse] = []


func _test_shot() -> void:
	phase = "shot"
	await hud.fade_to(1.0, 0.8)
	level.make_afternoon()
	await hud.card([[tr("UI_CH34O_SHOT"), 26, Color("f2e6c9")]], 2.2)
	hud.clear_card()
	for f: Dictionary in _folk:
		(f["p"] as Node3D).visible = f["kind"] == "adult"
		if f.has("sled"):
			(f["sled"] as Node3D).visible = false
	# Sultan ve maiyeti: atlılar ipin arkasına gelir
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true, "robe": Color("c8323a"),
		"hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.set_meta("spk", "SPK_FATIH")
	for k in 3:
		var h := Horse.new(Color("f2efe8") if k == 0 else Color("6a4a3a"), Color("b3262d") if k == 0 else Color("2a4a6a"))
		add_child(h)
		h.position = _gy(Vector3(-40.0 - k * 3.0, 0, -22.0 - k * 2.0))
		_horses.append(h)
		if k == 0:
			h.mount(fatih)
		else:
			var r := Person.new({"coat": Color("2a4a6a"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("c89070")})
			r.set_meta("no_talk", true)
			h.mount(r)
		var to := _gy(EdirneYard.SULTAN_SPOT + Vector3(-k * 2.6, 0, -k * 1.8))
		h.look_at(Vector3(to.x, h.position.y, to.z), Vector3.UP, true)
		h.speed = 1.4
		var tw := h.create_tween()
		tw.tween_method(func(t: float): h.position = _gy(h.position.lerp(to, t)), 0.0, 1.0, 6.0)
		tw.tween_callback(func():
			h.speed = 0.0
			h.rotation.y = 0.0)
	player.global_position = _gy(Vector3(2.8, 0, -1.0)) + Vector3(0, 0.05, 0)
	player.face(level.gun.global_position)
	urban.position = _gy(Vector3(-2.2, 0, -5.4))
	await hud.fade_to(0.0, 0.8)
	_setup_crew()
	drill.start(0.3, 0.16)
	# Doldururken Sultan ve Urban konuşur (bark)
	var lines := [["SPK_FATIH", "D34O_F_01"], ["SPK_URBAN", "D34O_U_F1"], ["SPK_FATIH", "D34O_F_02"], ["SPK_URBAN", "D34O_U_F2"],
		["SPK_TOLGA", "D34O_T_SULTAN" if GameState.chapter_outcomes.has(12) else "D34O_T_SULTAN_ALT"]]
	var line_t := 6.0
	var jam_said := false
	var t := 0.0
	while drill.active and t < 240.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		line_t -= dt
		if line_t <= 0.0 and not lines.is_empty() and crew.state != "fly":
			line_t = 5.0
			var ln: Array = lines.pop_front()
			hud.bark(ln[0], ln[1], 4.5)
		if jam and crew.state == "ram" and not jam_said:
			jam_said = true
			hud.bark("SPK_URBAN", "D34O_U_JAM", 4.0)
	if drill.active:
		drill.stop()
	var at: Vector3 = drill.last_impact
	var post := level.post.global_position
	hit = at != Vector3.INF and Vector2(at.x - post.x, at.z - post.z).length() < HIT_DIST
	print("SHOT %s at=%s" % ["hit" if hit else "short", at]) if GameState.autotest else null
	# Düşüş: toprak ve kar sütunu, krater
	if at != Vector3.INF:
		Vfx.explosion(self, at + Vector3(0, 1.0, 0), 1.6)
		var cr := Props.cyl(self, 1.5, 0.04, at + Vector3(0, 0.03, 0), Color("4a3a2c"), Vector3.ZERO, 14)
		cr.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	await get_tree().create_timer(2.5).timeout
	hud.bark("SPK_URBAN", "D34O_U_HIT" if hit else "D34O_U_SHORT", 4.0)
	await get_tree().create_timer(2.0).timeout
	hud.bark("SPK_FATIH", "D34O_F_03", 4.0)
	await _photo_sultan()


func _setup_crew() -> void:
	crew = CannonCrew.new()
	add_child(crew)
	crew.player = player
	crew.hud = hud
	crew.pivot = level.pivot
	crew.muzzle = level.muzzle
	crew.recoil_node = level.gun
	var g := level.gun
	crew.aim_spot = _gy(g.to_global(Vector3(0, 0, EdirneYard.BARREL_LEN * 0.5 + 1.4)))
	crew.aim_back = 5.0
	crew.supplies = {"powder": _gy(g.to_global(Vector3(-2.6, 0, 1.6))), "wad": _gy(g.to_global(Vector3(2.4, 0, 2.6))),
		"rammer": _gy(g.to_global(Vector3(2.6, 0, -1.0)))}
	crew.spawn = ["powder", "wad"]
	crew.hoist_prompt = "UI_PROMPT34O_HOIST"
	crew.ram_needed = 6 if jam else 3
	level.build_hoist(_gy(level.muzzle.global_position + Vector3(0, 0, 0.6)))
	var post := level.post.global_position + Vector3(0, 3.0, 0)
	if _variant() == "bad":
		crew.target = func() -> Vector3: return post + Vector3(0, -10.0, -120.0)
	else:
		crew.target = func() -> Vector3: return post
	crew.hit_radius = 3.0            # direğin kendisi; isabet sayımı düştüğü yere göre (HIT_DIST)
	crew.tolerance = 120.0
	crew.ground_y = -20.0
	crew.load_radius = 3.0
	crew.design_elev = 8.0
	crew.pitch_min = -2.0
	crew.pitch_max = 20.0
	crew.yaw_limit = 12.0
	crew.before_fire = func(): await _misfire()
	crew.setup()
	drill.bind(crew)


## Ateş almadı: falya fışırdar ve söner; ince duman tüter. Duman bitene kadar 4 m içine girme.
func _misfire() -> void:
	var th := level.touch_hole.global_position
	urban.global_position = _gy(th + Vector3(-1.4, 0, -0.8))
	urban.look_target = level.gun
	await get_tree().create_timer(0.8).timeout
	Audio.sfx("fuse_burn", -4.0, 1.0)
	var fl := Props.ball(self, 0.12, th + Vector3(0, 0.15, 0), Color("ffb040"), Vector3.ONE, 6, 4.0)
	await get_tree().create_timer(0.7).timeout
	fl.queue_free()
	hud.bark("SPK_URBAN", "D34O_U_HANG", 4.0)
	urban.global_position = _gy(th + Vector3(-5.0, 0, -3.0))
	player.frozen = false
	get_tree().create_timer(3.0).timeout.connect(func(): hud.bark("SPK_TOLGA", "D34O_T_HANG", 4.0))
	_smoke_t = randf_range(8.0, 12.0)
	_smoke_on = true
	_grace = 2.5
	phase = "hang"
	var bot_t := 0.0
	var bot_sparked := false
	while _smoke_on:
		await get_tree().process_frame
		hud.set_objective(tr("UI_OBJ34O_HANG"))
		if GameState.autotest:
			bot_t += get_process_delta_time()
			if _variant() == "bad" and not bot_sparked and bot_t > 1.5:
				bot_sparked = true
				_grace = 0.0
				player.global_position = _gy(th + Vector3(2.0, 0, -0.5)) + Vector3(0, 0.05, 0)
			elif bot_t > 0.2 and (bot_sparked or _variant() != "bad"):
				player.global_position = _gy(th + Vector3(7.0, 0, -6.0)) + Vector3(0, 0.05, 0)
	# Yeniden falya
	hud.bark("SPK_URBAN", "D34O_U_PRIME", 4.0)
	phase = "prime"
	_primed = 0.0
	while _primed < 2.0:
		await get_tree().process_frame
		var near := player.global_position.distance_to(th) < 2.4
		hud.set_objective(tr("UI_OBJ34O_PRIME"), th + Vector3(0, 0.5, 0))
		hud.set_prompt(tr("UI_PROMPT34O_PRIME") if near else "")
		if near and (Input.is_action_pressed("interact") or GameState.autotest):
			_primed += get_process_delta_time()
		if GameState.autotest:
			player.global_position = _gy(th + Vector3(1.2, 0, 0)) + Vector3(0, 0.05, 0)
	hud.set_prompt("")
	Audio.sfx("land_pot", -10.0, 1.4)
	hud.set_objective(tr("UI_OBJ34O_PRIME"), Vector3(0, 1.0, EdirneYard.ROPE_Z - 2.0))
	# 4 sn: ipin arkasına koş
	var run_t := 4.0
	while run_t > 0.0:
		await get_tree().process_frame
		run_t -= get_process_delta_time()
		hud.set_qte("%.1f" % run_t)
		if GameState.autotest:
			player.global_position = _gy(Vector3(3.0, 0, EdirneYard.ROPE_Z - 2.5)) + Vector3(0, 0.05, 0)
	hud.set_qte("")
	hud.set_objective("")
	phase = "fire"
	blasted = player.global_position.z > EdirneYard.ROPE_Z
	player.frozen = true
	player.face(level.gun.global_position)
	# Fitil 0,55 sn sonra ateşler (CannonCrew._fire): o anda alev, ağır çekim ve basınç
	get_tree().create_timer(0.55).timeout.connect(_after_blast)


func _hang_tick(delta: float) -> void:
	var th := level.touch_hole.global_position
	if phase == "hang":
		_smoke_t -= delta
		# İnce duman sütunu, gittikçe incelir
		_puff_t -= delta
		if _puff_t <= 0.0:
			_puff_t = 0.12
			var k := clampf(_smoke_t / 10.0, 0.15, 1.0)
			var puff := Props.ball(self, 0.08 * k + 0.03, th + Vector3(0, 0.1, 0), Color("c8c4bc"), Vector3.ONE, 5)
			puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var tw := puff.create_tween()
			tw.tween_property(puff, "position", puff.position + Vector3(0.2, 2.2, 0.1), 2.0)
			tw.parallel().tween_property(puff, "scale", Vector3.ONE * 3.0, 2.0)
			tw.tween_callback(puff.queue_free)
		var p := player.global_position
		_grace -= delta
		if _grace <= 0.0 and Vector2(p.x - th.x, p.z - th.z).length() < 4.0:
			# Falya öksürür: kıvılcım, geri savrulma, bekleme baştan
			sparks += 1
			print("HANG_SPARK %d" % sparks) if GameState.autotest else null
			Vfx.explosion(self, th + Vector3(0, 0.4, 0), 0.4)
			Audio.sfx("cannon", -12.0, 1.8)
			player.hurt(25.0, th)
			var away := Vector3(p.x - th.x, 0, p.z - th.z).normalized()
			player.global_position = _gy(p + away * 3.5) + Vector3(0, 0.05, 0)
			player.stagger(1.2)
			hud.bark("SPK_URBAN", "D34O_U_SPARK", 3.0)
			_smoke_t = randf_range(8.0, 12.0)
		if _smoke_t <= 0.0:
			_smoke_on = false


func _after_blast() -> void:
	Fx.slowmo(0.4, 1.4, 0.4)
	# Atış: büyük alev ve duman, kalabalık eğilir, at başını sallar; ipin önündeysen basınç seni düşürür
	Vfx.gun_blast(self, level.muzzle.global_position + (level.muzzle.global_position - level.gun.global_position).normalized() * 2.0, 2.4)
	Fx.trauma(0.8)
	for h: Horse in _horses:
		var tw := h.create_tween()
		tw.tween_property(h, "rotation:y", h.rotation.y + 0.25, 0.2)
		tw.tween_property(h, "rotation:y", h.rotation.y - 0.2, 0.3)
		tw.tween_property(h, "rotation:y", h.rotation.y, 0.4)
	if blasted:
		player.hurt(30.0, level.gun.global_position)
		player.stagger(2.0)
		Audio.stinger("heart")
		hud.bark("SPK_URBAN", "D34O_U_BLAST", 4.0)


func _photo_sultan() -> void:
	player.frozen = false
	var target := Node3D.new()
	fatih.add_child(target)
	target.position = Vector3(0, 1.65, 0)
	hud.set_objective(tr("UI_OBJ34O_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege34o")
	hud.add_child(cam)
	cam.max_dist = 40.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 15.0):
		await get_tree().process_frame
		t += get_process_delta_time()
		if GameState.autotest:
			player.global_position = _gy(EdirneYard.SULTAN_SPOT + Vector3(5.0, 0, 3.0)) + Vector3(0, 0.05, 0)
			player.face(target.global_position)
	cam.stop()
	hud.set_objective("")
	player.frozen = true
	if not _photo.is_empty():
		hud.bark("SPK_TOLGA", "D34O_T_PHOTO", 3.5)
		await get_tree().create_timer(2.0).timeout
	_outcome = "34O.1" if hit else "34O.2"
	urban.global_position = _gy(player.global_position + Vector3(-1.6, 0, -1.6))
	urban.look_target = player
	await hud.say("SPK_NIHAT", "D34O_N_END")
	await hud.say("SPK_URBAN", "D34O_U_END_NICK" if nicks >= 3 else "D34O_U_END")
	Siege.record(34, _photo, "SIEGE_NOTE_34O_%s" % _outcome.split(".")[1])


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(34, _outcome)
	await Siege.show_page(hud, 34)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(34)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW34O_TITLE")
	c.nodes = [
		{"id": "mould", "key": "FLOW34O_MOULD", "pos": Vector2(0.5, 0.1)},
		{"id": "lift", "key": "FLOW34O_LIFT", "pos": Vector2(0.5, 0.22)},
		{"id": "balls", "key": "FLOW34O_BALLS", "pos": Vector2(0.5, 0.34)},
		{"id": "herald", "key": "FLOW34O_HERALD", "pos": Vector2(0.5, 0.46)},
		{"id": "shot", "key": "FLOW34O_SHOT", "pos": Vector2(0.5, 0.58)},
		{"id": "34O.1", "key": "FLOW_34O_1", "pos": Vector2(0.3, 0.72), "outcome": true},
		{"id": "34O.2", "key": "FLOW_34O_2", "pos": Vector2(0.7, 0.72), "outcome": true},
	]
	c.edges = [["mould", "lift"], ["lift", "balls"], ["balls", "herald"], ["herald", "shot"], ["shot", "34O.1"], ["shot", "34O.2"]]
	for k in ["mould", "lift", "balls", "herald", "shot"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		Grade.finish("34o"),
		tr("UI_CH34O_STATS") % [nicks, slips, calls_ok, BALLS, crowd_saved, 6, tr("UI_CH34O_HIT" if hit else "UI_CH34O_SHORT"),
			Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "34O.1", "bad": "34O.2"}.get(v, "34O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("34", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null
	match v:
		"":
			ok = ok and nicks == 0 and slips == 0 and calls_ok == BALLS and runaway_stopped == 1 and crowd_saved == 6 and sparks == 0 \
				and not blasted and hit and cam.done and not jam
		"bad":
			ok = ok and jam and slips >= 1 and sparks >= 1 and not hit and nicks >= 3
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s çentik=%d kayma=%d karar=%d kaçak=%d kalabalık=%d kıvılcım=%d basınç=%s isabet=%s sıkışma=%s foto=%s)" % [
			expected, _outcome, not page.is_empty(), nicks, slips, calls_ok, runaway_stopped, crowd_saved, sparks, blasted, hit, jam, cam != null and cam.done])
	print("AUTOTEST %s chapter=34o variant=%s outcome=%s nicks=%d slips=%d calls=%d/%d stopped=%d crowd=%d sparks=%d blast=%s jam=%s hit=%s" % [
		"PASS" if ok else "FAIL", v, _outcome, nicks, slips, calls_ok, BALLS, runaway_stopped, crowd_saved, sparks, blasted, jam, hit])
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
	hud.visible = false
	player.show_remote(false)
	var cv := Camera3D.new()
	add_child(cv)
	cv.fov = 60.0
	cv.make_current()
	# Kapak: çukur, A çatısı, çıkrıklar; arkada Edirne
	cv.global_position = Vector3(8.5, 3.6, 10.5)
	cv.look_at(Vector3(-1.0, 1.2, -3.0), Vector3.UP)
	foreman.set_activity("row")
	player.global_position = _gy(EdirneYard.WIND_REAR + Vector3(1.5, 0, 0))
	player.show_remote(false)
	for i in level.clay.size():
		if i % 3 != 0:
			level.break_clay(i)
	_rear = 3.0
	_front = 2.7
	_gun_base_y = level.gun.position.y
	_set_gun_lift()
	await get_tree().create_timer(1.0).timeout
	await _shot_png("c34o_cover.png")
	# Gülle oluğu
	cv.global_position = EdirneYard.RING + Vector3(4.0, 3.0, 4.0)
	cv.look_at(EdirneYard.CHUTE_TOP + Vector3(0, 1.0, 0), Vector3.UP)
	await get_tree().create_timer(0.4).timeout
	await _shot_png("c34o_01_chute.png")
	# Kızak yamacı ve atış sahası
	cv.global_position = Vector3(-6.0, 3.0, -12.0)
	cv.look_at(Vector3(10.0, 2.0, 60.0), Vector3.UP)
	await get_tree().create_timer(0.4).timeout
	await _shot_png("c34o_02_range.png")
	# Edirne (arkaya bakış)
	cv.global_position = Vector3(0.0, 6.0, -20.0)
	cv.look_at(Vector3(-40.0, 10.0, -220.0), Vector3.UP)
	await get_tree().create_timer(0.4).timeout
	await _shot_png("c34o_03_edirne.png")
	get_tree().quit()
