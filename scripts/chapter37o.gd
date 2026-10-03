extends Node3D
## Bölüm 37 (yalnız Osmanlı tarafı) — İlk Hücum (Tolga · 18 Nisan 1453 gecesi, Mesoteichion). docs/OTTOMAN_NEW_B.md §1.
##
## Bir haftalık bombardımandan sonra Sultan dış surun yıkılan yerine örülen barikata ilk büyük gece hücumunu emreder.
## Giustiniani'nin adamları dört saat dayanır, hücum püskürtülür. Tolga Urban'ın kâtibidir; bu gece azaplarla gider.
##   0. Batarya: Urban ve Azap Bölükbaşı Turgut; zili al (E).
##   1. Zil ve kalkan: davulla zili çal (RowMeter, Space; 16 vuruş). Ok yaylımında C basılı: hasır kalkan başın üstünde.
##   2. Kalas köprü: kalası ekiple hendeğe taşı, indir (E); üstünden ilk sen geç (BalanceMeter, A/D). Düşersen hendeğin
##      dibinden karşı duvara tırman (Space ile tutun, nefes).
##   3. Barikat: beş fıçıya kanca at (nişan + E), hep birlikte çek (Space ritmi; kaçarsa savunan ipi keser). Taş ve
##      tüfekçi. İkinci fıçıdan sonra gedikten Cenevizliler çıkar (WaveRunner). Tespit: barikatın üstünde Giustiniani.
##   4. Geri: yaralı azabın hasır kalkanını ipinden çek (W; ip kayınca E), ateş çömleklerinin birikintilerinden kaçın.
##   37O.1 Barikat yer yer söküldü (≥3 fıçı) · 37O.2 Barikat çizik almadı
##   --autotest[=lose]   (varsayılan: 37O.1; =lose: geç vurur, kalastan bir kez düşer, düelloyu kaybeder)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const BEATS := 16
const MARCH_FROM := Vector3(-9.0, 0.0, 74.0)
const MARCH_TO := Vector3(-9.0, 0.0, 41.5)
const PLANK_X := -9.0
const PLANK_PILE := Vector3(-12.5, 0.0, 44.0)
const EDGE_Z := 37.0
const FAR_Z := 19.4
const BARRELS := 5
const STOCKADE_TIME := 180.0
const DRAG_FROM := Vector3(-9.0, 0.0, 39.5)
const DRAG_TO := Vector3(-9.0, 0.0, 68.0)

var walls: LandWalls
var gun: Node3D
var player: Player
var hud: Hud
var meter: RowMeter
var balance: BalanceMeter
var cam: TespitCam
var assault: Assault
var urban: Person
var turgut: Person
var giust: Person
var wounded: Soldier
var squad: Array[Soldier] = []
var drummer: Soldier
var phase := "intro"
var _outcome := ""
var _photo := ""
var beats_good := 0
var beats_done := 0
var arrows := 0
var falls := 0
var barrels_down := 0
var cuts := 0
var stone_hits := 0
var slips := 0
var burns := 0
var gunner_shots := 0
var gunner_dodged := 0
var _duel_won := true
var _shield: Node3D
var _cymbal: Node3D
var _plank: Node3D
var _plank_carried: Node3D
var _barrels: Array[Node3D] = []
var _hook: Node3D
var _hook_target := -1
var _pull := 0
var _bal := 0.0
var _t := 0.0
var _strokes: Array = []      # RowMeter.stroke (oyuncu Space ya da test botu): sırayla işlenir
var _shield_up := false


func _ready() -> void:
	GameState.snapshot(37)
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
	meter = RowMeter.new()
	hud.add_child(meter)
	meter.stroke.connect(func(good: bool): _strokes.append(good))
	balance = BalanceMeter.new()
	balance.label_text = tr("UI_OBJ37O_CROSS")
	balance.visible = false
	hud.add_child(balance)
	balance.place_bottom()
	walls = LandWalls.new()
	add_child(walls)
	walls.set_repair(4)                 # erken barikat: fıçı, kalas, toprak
	gun = walls.build_great_gun()
	_build_field()
	_build_people()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ yerleşim

func _build_field() -> void:
	# Ova yürünür; sınır yok (ötesi dünyanın ovası ve ordugâhı, WorldWalk). Hendeğe düşülebilir (oyunun parçası).
	var pad := Props.solid(self, Vector3(84, 1.2, 76), Vector3(0, -0.6, 74.0), Color("3a3e2a"))
	pad.get_child(0).visible = false
	# Hendeğin iki duvarı katı ve görünür: düşen oyuncu tutunup tırmanır (Traversal)
	# (gediğin önündeki moloz dili hariç: orada yamaç)
	for spec: Array in [[36.0, -32.0, 32.0], [20.2, -32.0, -LandWalls.TONGUE_W * 0.5], [20.2, LandWalls.TONGUE_W * 0.5, 32.0]]:
		var z: float = spec[0]
		var w := Props.solid(self, Vector3(spec[2] - spec[1], 3.0, 0.5), Vector3((spec[1] + spec[2]) * 0.5, -1.5, z), Color.WHITE)
		Props.set_pattern(w, LandWalls.C_STONE.darkened(0.3), "ashlar")
	Scenery.ground_detail(self, Rect2(-30.0, 37.5, 60.0, 70.0), 380, func(_x: float, _z: float) -> float: return 0.0, Color("2e3a24"), 3701)
	# Kalas yığını (ekip buradan alır)
	for k in 3:
		Props.box(self, Vector3(0.45, 0.12, 16.5), PLANK_PILE + Vector3(k * 0.5, 0.06 + k * 0.13, 0), Color("6a4a2c"), Vector3(0, 0, 0))
	Props.interactable(self, "plank", Vector3(2.2, 1.4, 4.0), PLANK_PILE + Vector3(0.5, 0.7, 0))
	Props.interactable(self, "edge", Vector3(3.0, 1.8, 1.6), Vector3(PLANK_X, 0.9, EDGE_Z + 0.4))
	# Barikatın fıçıları (gediğin moloz tepesinde, toprak dolu)
	for i in BARRELS:
		var p := LandWalls.on_rubble(LandWalls.BREACH + Vector3(-2.8 + i * 1.4, 0, 1.6))
		var b := Node3D.new()
		b.position = p
		add_child(b)
		Props.cyl(b, 0.42, 1.1, Vector3(0, 0.55, 0), Color("6a4a2c"), Vector3.ZERO, 10)
		for y: float in [0.2, 0.9]:
			Props.cyl(b, 0.44, 0.06, Vector3(0, y, 0), Color("3a3a40"), Vector3.ZERO, 10)
		Props.cyl(b, 0.4, 0.04, Vector3(0, 1.1, 0), Color("5a4630"), Vector3.ZERO, 10)
		_barrels.append(b)
	# Ordu: sancaklı bölükler, bataryalar, surda savunanlar (gece)
	assault = Assault.new()
	assault.night = true
	assault.keep = Rect2(-40.0, 36.4, 80.0, 72.6)
	add_child(assault)
	assault.build_calm()
	# Hendekte ve sur dibinde daha önceki günlerin ölüleri yok: ilk hücum. Yalnız gülle çukurları ve moloz.
	for x in [-20.0, -14.0, 6.0, 14.0, 22.0]:
		walls.lights.append(Night.torch(self, Vector3(x, 0, 46.0 + fmod(absf(x), 3.0))))


func _build_people() -> void:
	urban = Person.new({"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "hat": "kalpak", "face": "urban", "mustache": true, "beard": true,
		"hair": Color("8a5a2a"), "apron": Color("4a3020"), "skin": Color("e8b894")})
	urban.set_meta("spk", "SPK_URBAN")
	urban.position = gun.position + Vector3(4.8, 0, 4.4)
	add_child(urban)
	urban.look_target = player
	turgut = Person.new({"coat": Color("b3262d"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": true,
		"skin": Color("c89070")})
	turgut.set_meta("spk", "SPK_AZAPBASI")
	turgut.position = gun.position + Vector3(0.6, 0, 11.0)
	turgut.rotation.y = PI
	add_child(turgut)
	turgut.look_target = player
	Props.interactable(turgut, "turgut", Vector3(1.4, 2.0, 1.4), Vector3(0, 1.0, 0))
	giust = Person.new({"face": "giustiniani", "coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero",
		"beard": true, "skin": Color("e0b08a")})
	giust.set_meta("spk", "SPK_GIUST")
	giust.position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(0.4, 0, -0.6))
	giust.visible = false
	add_child(giust)
	wounded = Soldier.new(Color("b3262d"), "stand", "azap")
	wounded.set_meta("spk", "SPK_AZAP")
	wounded.visible = false
	add_child(wounded)
	# Bölük: altı azap ve davulcu (yürüyüşte oyuncunun çevresinde)
	for i in 6:
		var s := Soldier.new([Color("b3262d"), Color("8a6a4a"), Color("6a4a3a")][i % 3], "stand", "azap" if i % 2 == 0 else "bork")
		s.visible = false
		add_child(s)
		squad.append(s)
	drummer = Soldier.new(Color("b3262d"), "stand", "bork")
	drummer.visible = false
	add_child(drummer)
	Props.cyl(drummer, 0.3, 0.4, Vector3(0, 1.0, -0.35), Color("8a5a2a"), Vector3(90, 0, 0), 10)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH37O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH37O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = gun.position + Vector3(1.8, 0.05, 9.2)
	player.face(urban.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D37O_N_01")
	await hud.say("SPK_TOLGA", "D37O_T_01")
	await hud.say("SPK_URBAN", "D37O_U_01")
	await hud.say("SPK_TOLGA", "D37O_T_U1")
	await hud.say("SPK_URBAN", "D37O_U_02")
	await _cymbal_take()
	await _march()
	await _plank_phase()
	await _stockade()
	await _drag()
	await _dawn()
	await _end_chapter()


## 0. Turgut zili uzatır: E ile alınır
var _took_cymbal := false


func _cymbal_take() -> void:
	phase = "cymbal"
	player.face(turgut.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_AZAPBASI", "D37O_AB_01")
	await hud.say("SPK_TOLGA", "D37O_T_02")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ37O_URBAN"), turgut.global_position + Vector3(0, 2.0, 0))
	while not _took_cymbal:
		await get_tree().process_frame
		if GameState.autotest:
			_on_interact("turgut")
	hud.set_objective("")
	player.frozen = true


func _give_cymbal() -> void:
	_took_cymbal = true
	_cymbal = Node3D.new()
	_cymbal.position = Vector3(0.0, -0.4, -0.7)
	player.camera.add_child(_cymbal)
	# İki zil, yüzleri bize dönük, iki elde (birbirine çarpar)
	for sx: float in [-0.2, 0.2]:
		Props.cyl(_cymbal, 0.11, 0.015, Vector3(sx, 0, 0), Color("d8b040"), Vector3(80, 0, sx * 120.0), 16)
		Props.ball(_cymbal, 0.03, Vector3(sx, 0.0, 0.01), Color("8a6a2a"), Vector3.ONE, 6)
	Props.strip_outlines(_cymbal)
	Audio.sfx("kick_metal", -10.0, 1.6)


## 1. Davulla zil, ok yaylımında kalkan. Her iyi vuruşta bölük 0,6 m … (16 vuruşta kıyıya)
func _march() -> void:
	phase = "march"
	await hud.fade_to(1.0, 0.5)
	player.global_position = MARCH_FROM + Vector3(0, 0.05, 0)
	player.face(Vector3(0, 4.0, 15.0))
	_place_squad(MARCH_FROM)
	for s in squad:
		s.visible = true
	drummer.visible = true
	await hud.fade_to(0.0, 0.5)
	await hud.say("SPK_AZAPBASI", "D37O_AB_02")
	_shield = Node3D.new()
	_shield.position = Vector3(-0.35, -0.9, -0.7)
	player.camera.add_child(_shield)
	Props.cyl(_shield, 0.42, 0.05, Vector3.ZERO, Color("c8a868"), Vector3(80, 0, 0), 14)
	Props.ring(_shield, 0.3, 0.42, Vector3(0, 0, 0.01), Color("8a6a3a"), Vector3(80, 0, 0))
	Props.strip_outlines(_shield)
	hud.set_objective(tr("UI_OBJ37O_BEAT") % [0, BEATS])
	_strokes.clear()
	meter.enabled = true
	var at := MARCH_FROM
	var warn := -1.0
	var next_volley := 4.5
	var t := 0.0
	var lose := GameState.autotest_variant == "lose"
	while beats_done < BEATS:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var shield_up := Input.is_action_pressed("dive") or (GameState.autotest and warn >= 0.0)
		_shield.position = _shield.position.lerp(Vector3(-0.1, 0.18, -0.55) if shield_up else Vector3(-0.35, -0.9, -0.7), minf(1.0, dt * 10.0))
		_shield.rotation.x = lerpf(_shield.rotation.x, deg_to_rad(-80.0) if shield_up else 0.0, minf(1.0, dt * 10.0))
		if Input.is_action_just_pressed("jump"):
			meter.press()
		_shield_up = shield_up
		if _strokes.size() > 0:
			var good: bool = _strokes.pop_front() and not shield_up
			if GameState.autotest and lose and beats_done % 3 != 0:
				good = false
			beats_done += 1
			_strike(good)
			if good:
				beats_good += 1
				at = at.move_toward(MARCH_TO, (MARCH_FROM.z - MARCH_TO.z) / BEATS)
				if beats_good % 5 == 0:
					hud.bark("SPK_AZAPBASI", "D37O_AB_BEAT_OK", 2.2)
			else:
				at = at.move_toward(MARCH_TO, (MARCH_FROM.z - MARCH_TO.z) / BEATS * 0.5)
				hud.bark("SPK_AZAPBASI", "D37O_AB_BEAT_BAD", 2.0)
			hud.set_objective(tr("UI_OBJ37O_BEAT") % [beats_good, BEATS])
		# Bölük ve oyuncu ritimle ilerler
		var p := player.global_position
		player.global_position = Vector3(p.x, p.y, move_toward(p.z, at.z, dt * 2.0))
		_place_squad(Vector3(MARCH_FROM.x, 0, player.global_position.z))
		# Ok yaylımı (8. vuruştan sonra)
		if beats_done >= 6:
			if warn < 0.0:
				next_volley -= dt
				if next_volley <= 0.0:
					warn = 0.0
					hud.set_qte(tr("UI_OBJ37O_SHIELD"))
					hud.bark("SPK_SOLDIER", "D37O_S_VOLLEY", 2.0)
					if beats_done < 10:
						hud.bark("SPK_AZAPBASI", "D37O_AB_SHIELD", 2.5)
			else:
				var before := warn
				warn += dt
				if before < 0.4 and warn >= 0.4:
					assault.volley(Vector3(p.x, 0.0, p.z), 6.0, 40, false, 2.0)
				if warn >= 2.4:
					warn = -1.0
					next_volley = randf_range(4.5, 6.5)
					hud.set_qte("")
					if not shield_up:
						arrows += 1
						player.hurt(20.0, Vector3(p.x, 8.0, LandWalls.OUTER_Z1))
						player.stagger(0.5)
					else:
						Audio.sfx("pick_tap", -6.0, 1.6)      # oklar hasıra saplanır
						_stick_arrows()
		if t > 120.0:
			break
	meter.enabled = false
	hud.set_qte("")
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D37O_T_MARCH")


func _strike(good: bool) -> void:
	if _cymbal:
		var tw := _cymbal.create_tween()
		tw.tween_property(_cymbal, "scale", Vector3(0.45, 1.0, 1.0), 0.05)
		tw.tween_property(_cymbal, "scale", Vector3.ONE, 0.12)
	Audio.sfx("kick_metal", -6.0 if good else -12.0, 1.8 if good else 1.1)
	Audio.sfx("drum_boom", -8.0, 1.0)
	if good:
		Vfx.dust(self, player.global_position + Vector3(0, 1.3, -0.8), 0.15)
	else:
		player.shake(0.2)


func _stick_arrows() -> void:
	if _shield == null:
		return
	for k in 3:
		var a := Props.cyl(_shield, 0.008, 0.5, Vector3(randf_range(-0.25, 0.25), randf_range(-0.25, 0.25), -0.25), Color("6a4a2c"),
			Vector3(randf_range(60, 100), randf_range(-20, 20), 0), 4)
		a.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _place_squad(c: Vector3) -> void:
	for i in squad.size():
		var s := squad[i]
		var off := Vector3([-1.6, 1.8, -2.8, 2.6, -1.2, 1.0][i], 0, [-2.2, -2.0, -3.6, -3.8, 1.6, 1.8][i])      # çoğu önde (görünür)
		s.position = Vector3(c.x + off.x, 0.0, c.z + off.z)
		s.rotation.y = PI
	drummer.position = Vector3(c.x + 3.0, 0.0, c.z - 1.2)
	drummer.rotation.y = PI


# ---------------------------------------------------------------- 2. kalas

var _plank_down := false
var _carrying_plank := false


func _plank_phase() -> void:
	phase = "plank"
	await hud.say("SPK_AZAPBASI", "D37O_AB_03")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ37O_PLANK"), PLANK_PILE + Vector3(0, 1.2, 0))
	var t := 0.0
	while not _plank_down:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		if _carrying_plank:
			# Dört omuz: ekip oyuncunun iki yanında, kalas omuz hizasında onlarla birlikte
			var f := player.global_position
			for i in 3:
				squad[i].position = Vector3(f.x + [-0.7, 0.7, 0.0][i], 0.0, f.z + [2.5, 5.0, 7.5][i])
				squad[i].rotation.y = player.rotation.y
			hud.set_objective(tr("UI_OBJ37O_PLANK"), Vector3(PLANK_X, 1.0, EDGE_Z + 0.4))
		if GameState.autotest and t > 0.6:
			if not _carrying_plank:
				player.global_position = PLANK_PILE + Vector3(2.0, 0.05, 0)
				_on_interact("plank")
			else:
				player.global_position = Vector3(PLANK_X, 0.05, EDGE_Z + 1.6)
				_on_interact("edge")
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D37O_T_PLANK")
	# Kalastan geç: A/D dengede tutar; ibre kenara giderse düşülür. Düşen hendekten tırmanır.
	hud.set_objective(tr("UI_OBJ37O_CROSS"), Vector3(PLANK_X, 1.0, FAR_Z))
	player.enable_climb([Rect2(-32.0, 14.0, 64.0, 98.0)])
	var gust := 0.0
	var arrow_t := 2.0
	var fell_once := false
	t = 0.0
	while player.global_position.z > FAR_Z + 0.2 or player.global_position.y < -0.6:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var p := player.global_position
		var on := p.z < EDGE_Z - 0.6 and p.z > FAR_Z + 0.6 and p.y > -0.4 and absf(p.x - PLANK_X) < 0.8
		balance.visible = on
		if on:
			gust = lerpf(gust, sin(t * 1.3) * 0.5 + sin(t * 3.1) * 0.25, dt * 2.0)
			var input := Input.get_axis("move_left", "move_right")
			if GameState.autotest:
				input = -signf(_bal) * 0.9 if absf(_bal) > 0.15 else 0.0
				if GameState.autotest_variant == "lose" and not fell_once:
					input = 1.0
				player.global_position.z = move_toward(p.z, FAR_Z, dt * 1.6)
			arrow_t -= dt
			if arrow_t <= 0.0:
				arrow_t = 2.0
				_bal += randf_range(-0.35, 0.35)          # kalasın yanına saplanan ok ibreyi iter
				Audio.sfx("whoosh_fly", -10.0, 1.3)
			_bal += (gust * 0.5 + input * 1.5) * dt
			balance.value = _bal
			# Oyuncu kalasın üstünde kalır; A/D yalnız dengeyi değiştirir, gövde yalpalar
			player.global_position.x = PLANK_X + _bal * 0.2
			player.camera.rotation.z = -_bal * 0.12
			_plank.rotation.z = sin(t * 4.0) * 0.01 * absf(_bal)
			if absf(_bal) >= 1.0:
				# Düşüş: kalastan yana, hendeğin dibine
				falls += 1
				fell_once = true
				balance.visible = false
				player.camera.rotation.z = 0.0
				player.global_position.x = PLANK_X + signf(_bal) * 1.2
				_bal = 0.0
				Audio.sfx("land_thud", -2.0, 0.7)
				hud.bark("SPK_AZAPBASI", "D37O_AB_FALL", 3.0)
				await get_tree().create_timer(1.0).timeout
				player.hurt(20.0, Vector3.INF, true)
				hud.bark("SPK_TOLGA", "D37O_T_FALL", 3.0)
				hud.set_objective(tr("UI_OBJ37O_CLIMBOUT"), Vector3(PLANK_X, 0.5, FAR_Z))
				if GameState.autotest:
					await get_tree().create_timer(1.5).timeout
					player.global_position = Vector3(PLANK_X + 1.4, 0.05, FAR_Z - 0.4)
		else:
			player.camera.rotation.z = lerpf(player.camera.rotation.z, 0.0, dt * 6.0)
			if GameState.autotest and p.y > -0.4 and p.z >= EDGE_Z - 0.6:
				player.global_position = Vector3(PLANK_X, 0.15, EDGE_Z - 0.8)
		if t > 90.0:
			player.global_position = Vector3(PLANK_X, 0.05, FAR_Z - 0.4)
	balance.visible = false
	player.camera.rotation.z = 0.0
	player.disable_climb()
	hud.set_objective("")
	player.frozen = true


# ---------------------------------------------------------------- 3. barikat

var _stone_t := 9.0
var _shadow: Node3D
var _gn: Gunner
var _sally_done := false


func _stockade() -> void:
	phase = "stockade"
	await hud.fade_to(1.0, 0.4)
	player.global_position = _stockade_spot()
	player.face(LandWalls.BREACH + Vector3(0, 2.0, 1.6))
	giust.visible = true
	giust.look_target = player
	for s in squad:
		s.visible = false
	for i in 3:
		var s := squad[3 + i]
		s.visible = true
		s.position = Vector3(-1.6 + i * 1.6, LandWalls.outside_y(-1.6 + i * 1.6, 24.0), 24.0)
		s.rotation.y = PI
		s.pose = "pull"
	await hud.fade_to(0.0, 0.4)
	await hud.say("SPK_AZAPBASI", "D37O_AB_04")
	await hud.say("SPK_TOLGA", "D37O_T_03")
	hud.bark("SPK_GIUST", "D37O_G_01", 3.0)
	player.frozen = false
	meter.enabled = false
	# Tespit karesi: barikatın üstünde Giustiniani (faz boyunca açık)
	var target := Node3D.new()
	giust.add_child(target)
	target.position = Vector3(0, 1.6, 0)
	cam = TespitCam.new(player, hud, target, "siege37o")
	hud.add_child(cam)
	cam.max_dist = 40.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String):
		_photo = path
		hud.bark("SPK_NIHAT", "D37O_N_PHOTO_OK", 3.0))
	cam.start()
	hud.bark("SPK_NIHAT", "D37O_N_PHOTO", 4.0)
	var t := 0.0
	var gunner_at := 12.0
	var lose := GameState.autotest_variant == "lose"
	while barrels_down < BARRELS and t < STOCKADE_TIME:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		_stockade_objective()
		# Taş: yere gölge, 1,2 sn içinde yana çekil
		_stone_t -= dt
		if _stone_t <= 0.0:
			_stone_t = randf_range(8.0, 10.0)
			_drop_stone()
		if t > gunner_at and _gn == null:
			_gn = Gunner.spawn(self, Vector3(5.6, LandWalls.OUTER_H, LandWalls.OUTER_Z1 - 0.6), player, hud, 5.0, Color("7a2a24"), "helm")
		# Bot: fotoğraf, nişan, kanca, çekiş
		if GameState.autotest:
			if not cam.done and t > 1.0:
				player.face(giust.global_position + Vector3(0, 1.6, 0))
			elif _hook == null and fmod(t, 0.8) < dt * 3.0:
				var i := _next_barrel()
				if i >= 0:
					player.face(_barrels[i].global_position + Vector3(0, 0.7, 0))
					_throw_hook()
		elif Input.is_action_just_pressed("interact") and _hook == null:
			_throw_hook()
		# Çekiş: kanca takılıyken Space ritmi
		if _hook != null and _hook_target >= 0:
			if not meter.enabled:
				_strokes.clear()
			meter.enabled = true
			if Input.is_action_just_pressed("jump"):
				meter.press()
			while _strokes.size() > 0 and _hook != null:
				var good: bool = _strokes.pop_front()
				if GameState.autotest and lose and randf() < 0.5:
					good = false
				_heave(good)
		else:
			meter.enabled = false
		# Gedikten çıkış: ikinci fıçıdan sonra
		if barrels_down >= 2 and not _sally_done:
			_sally_done = true
			meter.enabled = false
			await _sally()
			if not _duel_won:
				break
	meter.enabled = false
	_clear_hook()
	if _gn:
		gunner_shots = _gn.shots
		gunner_dodged = _gn.dodged
		_gn.stop()
	cam.stop()
	hud.set_objective("")
	hud.set_qte("")
	player.frozen = true
	hud.bark("SPK_GIUST", "D37O_G_02", 3.0)
	await hud.say("SPK_SOLDIER", "D37O_S_RETREAT")


## Barikata kanca atılan yer: moloz dilinin ortası (fıçılara 6–7 m)
func _stockade_spot() -> Vector3:
	return Vector3(0.0, LandWalls.outside_y(0.0, 22.6) + 0.05, 22.6)


func _stockade_objective() -> void:
	if _hook != null:
		hud.set_objective(tr("UI_OBJ37O_PULL"))
	else:
		var i := _next_barrel()
		hud.set_objective(tr("UI_OBJ37O_HOOK") % [barrels_down, BARRELS], _barrels[i].global_position + Vector3(0, 1.4, 0) if i >= 0 else Vector3.INF)


func _next_barrel() -> int:
	for i in _barrels.size():
		if not _barrels[i].has_meta("down"):
			return i
	return -1


## Kanca: bakılan fıçıya (koni 9°, 18 m) uçar; takılırsa ip gerilir. Iska: kanca yere düşer, 2 sn sarılır.
func _throw_hook() -> void:
	var best := -1
	var cam3 := player.camera
	var fwd := -cam3.global_transform.basis.z
	for i in _barrels.size():
		if _barrels[i].has_meta("down"):
			continue
		var to := _barrels[i].global_position + Vector3(0, 0.7, 0) - cam3.global_position
		if to.length() < 18.0 and rad_to_deg(fwd.angle_to(to)) < 9.0:
			best = i
	# İp sağ elden çıkar (kameranın içinden değil)
	var from := player.global_position + Vector3(0, 1.1, 0) + player.camera.global_transform.basis.x * 0.4
	var at: Vector3 = (_barrels[best].global_position + Vector3(0, 0.9, 0)) if best >= 0 else from + fwd * 9.0
	at.y = maxf(at.y, 0.2)
	Audio.sfx("whoosh_fly", -6.0, 1.1)
	_hook = SeaBattle.hook(self, at, from)
	_hook_target = best
	_pull = 0
	if best < 0:
		var tw := _hook.create_tween()
		tw.tween_interval(1.6)
		tw.tween_callback(_clear_hook)
	else:
		Audio.sfx("kick_metal", -6.0, 1.4)       # "klank": kanca çembere takıldı
		Vfx.dust(self, at, 0.2)


func _clear_hook() -> void:
	if is_instance_valid(_hook):
		_hook.queue_free()
	_hook = null
	_hook_target = -1


## Bir "hey": arkadaki azaplar geriye yaslanır; iyi çekişte fıçı sallanır, üçüncüde devrilir. Kaçan çekişte savunan
## ipi baltayla keser.
func _heave(good: bool) -> void:
	if _hook_target < 0:
		return
	var b := _barrels[_hook_target]
	for i in 3:
		squad[3 + i].position.z += 0.0
	if not good:
		if randf() < 0.5 or GameState.autotest_variant == "lose":
			cuts += 1
			Audio.sfx("chop", -4.0, 1.2)
			hud.bark("SPK_AZAPBASI", "D37O_AB_CUT", 2.5)
			_clear_hook()
		return
	_pull += 1
	Audio.sfx("ship_haul", -6.0, randf_range(0.95, 1.1))
	var tw := b.create_tween()
	tw.tween_property(b, "rotation:x", deg_to_rad(10.0 * _pull), 0.15)
	tw.tween_property(b, "rotation:x", deg_to_rad(6.0 * _pull), 0.25)
	if _pull >= 3:
		_topple(_hook_target)
		_clear_hook()


func _topple(i: int) -> void:
	var b := _barrels[i]
	b.set_meta("down", true)
	barrels_down += 1
	var to := LandWalls.on_rubble(b.position + Vector3(randf_range(-0.6, 0.6), 0, 3.6)) + Vector3(0, 0.4, 0)
	var tw := b.create_tween()
	tw.tween_property(b, "rotation:x", deg_to_rad(95.0), 0.35).set_ease(Tween.EASE_IN)
	tw.tween_property(b, "position", to, 0.7).set_trans(Tween.TRANS_QUAD)
	tw.tween_callback(func():
		Vfx.dust(self, to, 1.4)
		Audio.sfx("land_thud", -2.0, 0.6)
		# Kapağı açılır, toprak dökülür
		Props.ball(self, 0.6, to + Vector3(0, -0.3, 0.6), Color("6a5236"), Vector3(1.6, 0.4, 1.2), 7))
	walls.set_repair(maxi(0, 4 - barrels_down))
	Fx.trauma(0.3)
	if barrels_down == 1:
		hud.bark("SPK_AZAPBASI", "D37O_AB_PULL_1", 2.5)
	elif barrels_down == 3:
		hud.bark("SPK_AZAPBASI", "D37O_AB_PULL_3", 2.5)


## Surdan taş: önce yere gölge düşer, 1,2 sn sonra taş iner; gölgenin içindeyse yaralar
func _drop_stone() -> void:
	var at := player.global_position
	at.y = LandWalls.outside_y(at.x, at.z) + 0.03
	_shadow = Props.cyl(self, 0.9, 0.02, at, Color(0, 0, 0, 1), Vector3.ZERO, 16)
	_shadow.material_override = Props.mat(Color(0.05, 0.05, 0.05), 0.0, false, "", false)
	_shadow.scale = Vector3(0.3, 1, 0.3)
	hud.bark("SPK_AZAPBASI", "D37O_AB_STONE", 1.6)
	var tw := _shadow.create_tween()
	tw.tween_property(_shadow, "scale", Vector3.ONE, 1.2)
	var stone := Props.ball(self, 0.3, Vector3(at.x, LandWalls.OUTER_H + 2.0, LandWalls.OUTER_Z0), Color("8a8478"), Vector3(1.0, 0.8, 1.1), 8)
	var st := stone.create_tween()
	st.tween_property(stone, "position", at + Vector3(0, 0.3, 0), 1.2).set_ease(Tween.EASE_IN)
	if GameState.autotest:
		# Bot gölgeyi görüp yana çekilir
		get_tree().create_timer(0.4).timeout.connect(func():
			if is_instance_valid(player):
				player.global_position.x += 1.8)
	await st.finished
	var shadow := _shadow
	if is_instance_valid(shadow):
		shadow.queue_free()
	if not is_instance_valid(stone):
		return
	Vfx.dust(self, stone.position, 0.8)
	Audio.sfx("land_thud", -4.0, 1.0)
	for k in 4:
		var c := Props.ball(self, 0.12, stone.position, Color("8a8478"), Vector3.ONE, 5)
		var ct := c.create_tween()
		ct.tween_property(c, "position", stone.position + Vector3(randf_range(-0.8, 0.8), -0.2, randf_range(-0.8, 0.8)), 0.4)
	stone.queue_free()
	var d := Vector2(player.global_position.x - at.x, player.global_position.z - at.z).length()
	if d < 0.9 and phase == "stockade" and not player.frozen:
		stone_hits += 1
		player.hurt(25.0, at + Vector3(0, 6, 0))
		hud.bark("SPK_TOLGA", "D37O_T_HIT", 3.0)


## 3b. Gedikten çıkan Cenevizliler: bölükbaşı ve iki azap yanında
func _sally() -> void:
	_clear_hook()
	hud.bark("SPK_AZAPBASI", "D37O_AB_SALLY", 3.0)
	hud.set_objective(tr("UI_OBJ37O_SALLY"))
	var lose := GameState.autotest and GameState.autotest_variant == "lose"
	var crest := LandWalls.on_rubble(LandWalls.BREACH + Vector3(0, 0, 1.2))
	var specs := []
	for k in 3:
		specs.append({"pos": crest + Vector3(-1.2 + k * 1.2, 0, -0.6), "blade": "spathion", "shield": k != 1, "name": "SPK_GENOESE",
			"look": {"coat": Color("8a8e96"), "pants": Color("3a2a22"), "hat": "helm", "mustache": true, "beard": k == 0}})
	var r: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": specs, "max_active": 2, "skill": 0.4 if not lose else 0.9, "allies": 2 if not lose else 0, "limit": 45.0}], "kilij")
	_duel_won = r["won"]
	if not _duel_won:
		await hud.say("SPK_TOLGA", "D37O_T_SALLY_LOST")
	else:
		# Düellodan sonra kanca atılan yere dön (gediğin molozunun içinde kalınmasın)
		await hud.fade_to(1.0, 0.25)
		player.global_position = _stockade_spot()
		player.face(LandWalls.BREACH + Vector3(0, 2.0, 1.6))
		await hud.fade_to(0.0, 0.25)
	player.frozen = false


# ---------------------------------------------------------------- 4. geri: yaralıyı sürükle

var _sled: Node3D
var _rope: MeshInstance3D
var _slip_t := 6.0
var _slipping := -1.0
var _pots: Array = []      # [düğüm, konum, kalan süre]


func _drag() -> void:
	phase = "drag"
	await hud.fade_to(1.0, 0.6)
	_drop_cymbal_and_shield()
	player.global_position = DRAG_FROM + Vector3(0, 0.05, 0)
	player.face(DRAG_TO)
	# Yaralı hasır kalkanın üstünde yatar, kalkanın ipi oyuncunun elinde
	_sled = Node3D.new()
	add_child(_sled)
	_sled.position = DRAG_FROM + Vector3(0, 0, -2.2)
	Props.cyl(_sled, 0.55, 0.06, Vector3(0, 0.04, 0), Color("c8a868"), Vector3.ZERO, 14)
	wounded.visible = true
	wounded.position = Vector3.ZERO
	remove_child(wounded)
	_sled.add_child(wounded)
	wounded.position = Vector3(0, 0.1, 0)
	wounded.rotation = Vector3(-PI * 0.5, 0, 0)
	_rope = MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.02
	cm.bottom_radius = 0.02
	cm.height = 1.0
	_rope.mesh = cm
	_rope.material_override = Props.mat(Color("b89a6a"))
	add_child(_rope)
	await hud.fade_to(0.0, 0.6)
	await hud.say("SPK_AZAPBASI", "D37O_AB_05")
	await hud.say("SPK_AZAP", "D37O_AZ_01")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ37O_DRAG"), DRAG_TO + Vector3(0, 1.4, 0))
	var t := 0.0
	var pot_t := 3.0
	var said := false
	while _sled.position.z < DRAG_TO.z - 2.5 and t < 150.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		if GameState.autotest:
			var goal := Vector3(_dodge_x(), 0.05, _sled.position.z + 3.2)
			player.global_position = player.global_position.move_toward(goal, dt * 3.0)
		# İp kayması: 1 sn içinde E
		_slip_t -= dt
		if _slip_t <= 0.0 and _slipping < 0.0:
			_slipping = 0.0
			hud.set_prompt(tr("UI_PROMPT37O_GRIP"))
			hud.bark("SPK_AZAPBASI", "D37O_AB_SLIP", 1.5)
		if _slipping >= 0.0:
			_slipping += dt
			if Input.is_action_just_pressed("interact") or (GameState.autotest and _slipping > 0.4):
				_slipping = -1.0
				_slip_t = randf_range(5.0, 7.0)
				hud.set_prompt("")
				Audio.sfx("cloth", -8.0, 1.2)
			elif _slipping > 1.0:
				_slipping = -1.0
				_slip_t = randf_range(5.0, 7.0)
				slips += 1
				hud.set_prompt("")
				_sled.position.z -= 2.0
				Audio.sfx("cloth", -4.0, 0.7)
		# Kızak ipin ucunda oyuncunun ardından gelir (en çok 1,4 m/sn); ip gerilir
		# İp boyu: oyuncu kızaktan 3,2 m'den fazla uzaklaşamaz (kızağı çekmeden koşulmaz)
		var away := player.global_position - _sled.position
		away.y = 0.0
		if away.length() > 3.2:
			var fixp := _sled.position + away.normalized() * 3.2
			player.global_position = Vector3(fixp.x, player.global_position.y, fixp.z)
		var hand := player.global_position + Vector3(0, 0.9, 0)
		var tgt := Vector3(player.global_position.x, 0.0, player.global_position.z - 2.4)
		if _slipping < 0.0 and _sled.position.distance_to(tgt) > 0.2:
			_sled.position = _sled.position.move_toward(tgt, dt * 1.4)
		var a := _sled.position + Vector3(0, 0.15, 0.55)
		var d := hand - a
		_rope.global_transform = Transform3D(Basis(Quaternion(Vector3.UP, d.normalized())).scaled(Vector3(1, d.length(), 1)), a + d * 0.5)
		if fmod(t, 0.5) < dt:
			Props.box(self, Vector3(0.6, 0.01, 0.4), _sled.position + Vector3(0, 0.01, 0), Color("4a3a26"))      # toprakta iz
		# Ateş çömlekleri: ıslık + gölge, sonra 2 m'lik yanan birikinti (8 sn)
		pot_t -= dt
		if pot_t <= 0.0:
			pot_t = randf_range(3.0, 4.5)
			_throw_pot(Vector3(player.global_position.x + randf_range(-2.0, 2.0), 0.0, player.global_position.z + randf_range(3.0, 6.0)))
			if not said:
				said = true
				hud.bark("SPK_AZAPBASI", "D37O_AB_POT", 2.5)
		for pot: Array in _pots.duplicate():
			pot[2] -= dt
			if pot[2] <= 0.0:
				if is_instance_valid(pot[0]):
					(pot[0] as Node3D).queue_free()
				_pots.erase(pot)
				continue
			var c: Vector3 = pot[1]
			for who: Vector3 in [player.global_position]:
				if Vector2(who.x - c.x, who.z - c.z).length() < 1.1 and pot.size() <= 3:
					pot.append(true)
					burns += 1
					player.hurt(20.0, c)
					hud.bark("SPK_TOLGA", "D37O_T_HIT", 2.0)
		if t > 14.0 and t < 14.0 + dt * 2.0:
			hud.bark("SPK_TOLGA", "D37O_T_DRAG", 3.0)
	hud.set_prompt("")
	hud.set_objective("")
	player.frozen = true
	await hud.say("SPK_AZAP", "D37O_AZ_02")
	await hud.say("SPK_AZAPBASI", "D37O_AB_06")


func _dodge_x() -> float:
	var x := player.global_position.x
	for pot: Array in _pots:
		var c: Vector3 = pot[1]
		if absf(c.z - player.global_position.z) < 3.0 and absf(c.x - x) < 1.8:
			x = c.x + (2.2 if c.x <= x else -2.2)
	return clampf(x, -20.0, 2.0)


func _throw_pot(at: Vector3) -> void:
	var pot := Props.ball(self, 0.18, Vector3(at.x, LandWalls.OUTER_H + 1.5, LandWalls.OUTER_Z1), Color("8a5a3a"), Vector3.ONE, 8)
	Audio.sfx("whoosh_fly", -8.0, 0.9)
	var mark := Props.cyl(self, 1.1, 0.02, at + Vector3(0, 0.03, 0), Color(0, 0, 0), Vector3.ZERO, 16)
	mark.material_override = Props.mat(Color(0.08, 0.04, 0.02), 0.0, false, "", false)
	var tw := pot.create_tween()
	tw.tween_property(pot, "position", at + Vector3(0, 0.2, 0), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		pot.queue_free()
		if is_instance_valid(mark):
			mark.queue_free()
		Audio.sfx("explosion_small", -6.0, 1.1)
		for k in 5:
			var sh := Props.ball(self, 0.08, at + Vector3(0, 0.3, 0), Color("8a5a3a"), Vector3.ONE, 4)
			var st := sh.create_tween()
			st.tween_property(sh, "position", at + Vector3(randf_range(-1, 1), 0.05, randf_range(-1, 1)), 0.3)
		var f := Vfx.fire(self, at, 1.0)
		_pots.append([f, at, 8.0]))


func _drop_cymbal_and_shield() -> void:
	for n in [_cymbal, _shield]:
		if is_instance_valid(n):
			n.queue_free()


# ---------------------------------------------------------------- şafak

func _dawn() -> void:
	await hud.fade_to(1.0, 0.8)
	if is_instance_valid(_rope):
		_rope.queue_free()
	walls.make_dawn(0.01)
	player.global_position = gun.position + Vector3(1.8, 0.05, 9.2)
	player.face(urban.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	var ok := barrels_down >= 3
	await hud.say("SPK_TOLGA", "D37O_T_END_OK" if ok else "D37O_T_END_BAD")
	await hud.say("SPK_URBAN", "D37O_U_03")
	await hud.say("SPK_TOLGA", "D37O_T_U2")
	await hud.say("SPK_URBAN", "D37O_U_04")
	await hud.say("SPK_NIHAT", "D37O_N_END")
	_outcome = "37O.1" if ok else "37O.2"
	Siege.record(37, _photo, "SIEGE_NOTE_37O_%s" % _outcome.split(".")[1])


func _on_focus(id: String) -> void:
	var k := ""
	match id:
		"turgut":
			if phase == "cymbal" and not _took_cymbal:
				k = "UI_PROMPT37O_CYMBAL"
		"plank":
			if phase == "plank" and not _carrying_plank and not _plank_down:
				k = "UI_PROMPT37O_PLANK"
		"edge":
			if phase == "plank" and _carrying_plank:
				k = "UI_PROMPT37O_DROP"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	match id:
		"turgut":
			if phase == "cymbal" and not _took_cymbal:
				_give_cymbal()
		"plank":
			if phase == "plank" and not _carrying_plank and not _plank_down:
				_carrying_plank = true
				player.speed_mult = 0.6
				_plank_carried = Node3D.new()
				_plank_carried.position = Vector3(0.45, -0.25, -4.0)
				player.camera.add_child(_plank_carried)
				Props.box(_plank_carried, Vector3(0.4, 0.1, 8.0), Vector3.ZERO, Color("6a4a2c"))
				Props.strip_outlines(_plank_carried)
				Audio.sfx("wood_creak", -6.0, 0.9)
		"edge":
			if phase == "plank" and _carrying_plank:
				_carrying_plank = false
				player.speed_mult = 1.0
				if is_instance_valid(_plank_carried):
					_plank_carried.queue_free()
				# Kalas kıyıdan kıyıya iner: uçlar kıyılara çarpar, toz
				_plank = Node3D.new()
				add_child(_plank)
				_plank.position = Vector3(PLANK_X, 0.06, (EDGE_Z + FAR_Z) * 0.5 - 0.6)
				var body := Props.solid(_plank, Vector3(0.55, 0.12, EDGE_Z - FAR_Z + 1.6), Vector3.ZERO, Color("6a4a2c"))
				body.set_meta("no_climb", true)
				_plank.rotation.x = deg_to_rad(-60.0)
				var tw := _plank.create_tween()
				tw.tween_property(_plank, "rotation:x", 0.0, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
				tw.tween_callback(func():
					Vfx.dust(self, Vector3(PLANK_X, 0.1, FAR_Z), 0.6)
					Vfx.dust(self, Vector3(PLANK_X, 0.1, EDGE_Z), 0.6)
					Audio.sfx("land_thud", -2.0, 0.8))
				_plank_down = true
				for i in 3:
					squad[i].position = Vector3(PLANK_X + [-1.4, 1.4, 2.4][i], 0.0, EDGE_Z + 1.6 + i * 0.6)


func _process(delta: float) -> void:
	_t += delta


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(37, _outcome)
	await Siege.show_page(hud, 37)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(37)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW37O_TITLE")
	c.nodes = [
		{"id": "urban", "key": "FLOW37O_URBAN", "pos": Vector2(0.5, 0.1)},
		{"id": "beat", "key": "FLOW37O_BEAT", "pos": Vector2(0.5, 0.22)},
		{"id": "plank", "key": "FLOW37O_PLANK", "pos": Vector2(0.5, 0.34)},
		{"id": "stockade", "key": "FLOW37O_STOCKADE", "pos": Vector2(0.5, 0.46)},
		{"id": "drag", "key": "FLOW37O_DRAG", "pos": Vector2(0.5, 0.58)},
		{"id": "37O.1", "key": "FLOW_37O_1", "pos": Vector2(0.3, 0.72), "outcome": true},
		{"id": "37O.2", "key": "FLOW_37O_2", "pos": Vector2(0.7, 0.72), "outcome": true},
	]
	c.edges = [["urban", "beat"], ["beat", "plank"], ["plank", "stockade"], ["stockade", "drag"], ["drag", "37O.1"], ["drag", "37O.2"]]
	for k in ["urban", "beat", "plank", "stockade", "drag"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		Grade.finish("37o"),
		tr("UI_CH37O_STATS") % [beats_good, BEATS, barrels_down, BARRELS, falls, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "37O.1", "lose": "37O.2"}.get(v, "37O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("37", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and _took_cymbal and _plank_down
	ok = ok and beats_done == BEATS and _sled != null and _sled.position.z >= DRAG_TO.z - 2.6
	if v == "":
		ok = ok and beats_good >= 12 and arrows == 0 and falls == 0 and barrels_down >= 3 and _duel_won and cam.done
	else:
		ok = ok and falls >= 1 and not _duel_won
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s zil=%d/%d ok=%d düşüş=%d fıçı=%d düello=%s foto=%s kızak=%s plank=%s)" % [expected, _outcome,
			not page.is_empty(), beats_good, beats_done, arrows, falls, barrels_down, _duel_won, cam != null and cam.done,
			_sled.position if _sled else null, _plank_down])
	print("AUTOTEST %s chapter=37o variant=%s outcome=%s beats=%d/%d arrows=%d falls=%d barrels=%d/%d cuts=%d stones=%d slips=%d burns=%d duel=%s" % [
		"PASS" if ok else "FAIL", v, _outcome, beats_good, BEATS, arrows, falls, barrels_down, BARRELS, cuts, stone_hits, slips, burns, _duel_won])
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
	# Yürüyüş: bölük, davulcu, zil
	_give_cymbal()
	player.global_position = Vector3(-9.0, 0.05, 52.0)
	_place_squad(Vector3(-9.0, 0, 52.0))
	for s in squad:
		s.visible = true
	drummer.visible = true
	player.face(Vector3(0, 4.0, 15.0))
	meter.enabled = true
	await get_tree().create_timer(0.8).timeout
	await _shot_png("c37o_01_march.png")
	meter.enabled = false
	# Barikat: fıçılar, Giustiniani, kanca
	giust.visible = true
	player.global_position = _stockade_spot()
	player.face(LandWalls.BREACH + Vector3(0, 2.0, 1.6))
	_hook = SeaBattle.hook(self, _barrels[1].global_position + Vector3(0, 0.9, 0), player.global_position + Vector3(0.4, 1.1, 0))
	await get_tree().create_timer(0.5).timeout
	await _shot_png("c37o_02_stockade.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(-14.0, 3.5, 40.0)
	cv.look_at(Vector3(-2.0, 1.0, 18.0), Vector3.UP)
	cv.fov = 62.0
	cv.make_current()
	_on_interact_force_plank()
	await get_tree().create_timer(0.8).timeout
	await _shot_png("c37o_cover.png")
	get_tree().quit()


func _on_interact_force_plank() -> void:
	phase = "plank"
	_carrying_plank = true
	_on_interact("edge")
