extends Node3D
## Bölüm 28 (yalnız Osmanlı tarafı) — İlk Atış (Tolga · 6 ve 11–12 Nisan 1453, kara surlarının önü, Urban'ın bataryası).
##
## Ordu 6 Nisan'da surların önüne gelir; siper kazılır, önüne kazık çakılır. Urban'ın büyük topu (Şahi) Edirne'den
## öküzler ve yüzlerce adamla çekilmiştir; bataryasına yerleştirilir ve kara surları 11–12 Nisan'da dövülmeye başlar.
## Sur o gün henüz sağlamdır (LandWalls.intact).
##   1. 6 Nisan: kazık yığınından dört kazık, siperin ardındaki deliklere (surdan arada bir gülle düşer)
##   2. 11 Nisan: Şahi kızağın üstünde, makara kütükleri üzerinde çekilir. "Hey-yap!" ritmi (RowMeter, Space).
##      Arkadan çıkan kütüğü öne taşı (E, E); kütük yokken çekilirse kızak kayar, geri gider.
##   3. İlk atış: topu doldur ve nişan al (GunDrill + CannonCrew, 20o ile aynı), gülle sağlam sura iner. Tespit: ilk toz.
##   28O.1 Top ilk seferde yerine oturdu · 28O.2 Kızak kaydı, yeniden kuruldu
##   --autotest[=lose]   (varsayılan: 28O.1; =lose: kütük beklemeden bir kez çekilir)

const STAKES := 4
const HAUL_FROM := -6.0       # kızağın x'i (bataryanın arkasındaki yol boyunca, +x'e çekilir)
const HAUL_TO := 9.0           # LandWalls.CANNON.x
const HAUL_Z := 122.0
const ROLLER_EVERY := 4.5
const STEP := 0.8              # iyi bir "hey-yap" başına kızağın yolu (m)

var walls: LandWalls
var player: Player
var hud: Hud
var meter: RowMeter
var drill: GunDrill
var gun_crew: CannonCrew
var cam: TespitCam
var gun: Node3D
var urban: Person
var horse: Horse
var sultan: Person
var sled: Node3D
var _rollers: Array[Node3D] = []
var _teams: Array[Soldier] = []
var phase := "intro"
var _outcome := ""
var stakes := 0
var carrying := ""
var _carry: Node3D
var _holes: Array[Node3D] = []
var haul_x := HAUL_FROM
var _next_roller := ROLLER_EVERY
var need_roller := false
var roller_held := false
var slips := 0
var _acc := 0.0
var hit := false
var _photo := ""
var _focus := ""
var _ball_t := 4.0
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(28)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	meter = RowMeter.new()
	hud.add_child(meter)
	walls = LandWalls.new()
	walls.intact = true
	add_child(walls)
	walls.make_day()
	walls.set_repair(0)
	gun = walls.far_gun
	gun.visible = false          # Şahi henüz yolda
	drill = GunDrill.new()
	hud.add_child(drill)
	drill.fired.connect(func(a: float): _acc = a)
	urban = Person.new({"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "hat": "kalpak", "face": "urban", "mustache": true, "beard": true,
		"hair": Color("8a5a2a"), "apron": Color("4a3020"), "skin": Color("e8b894")})
	urban.set_meta("spk", "SPK_URBAN")
	add_child(urban)
	urban.look_target = player
	# Bataryanın arkasındaki yol (kızağın çekildiği yer) yürünür: arazinin çarpışması yalnız topun çevresinde var
	var pad := Props.solid(self, Vector3(40.0, 0.4, 26.0), Vector3(3.0, -0.2, 121.0), Color.WHITE)
	pad.get_child(0).visible = false
	_build_stakes()
	_build_sled()
	horse = Horse.new(Color("e4e0d8"))
	add_child(horse)
	sultan = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	sultan.set_meta("spk", "SPK_FATIH")
	horse.mount(sultan)
	horse.visible = false
	for spec in [[Vector3(-40.0, 0, 123.0), Color("b3262d"), Color("2e6a3a")], [Vector3(40.0, 0, 123.0), Color("6a4a3a"), Color("f0ece0")]]:
		walls.field.formation(spec[0], spec[1], 8, 4, spec[2])
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


static func gy(x: float, z: float) -> float:
	return SiegeField.ground(x, z)


# ================================================================ sahne

## Kazık yığını ve siperin ardında dört delik (kazık çit, setin hemen gerisinde)
func _build_stakes() -> void:
	var pile := Vector3(18.0, 0, 120.5)
	pile.y = gy(pile.x, pile.z)
	for i in 7:
		Props.cyl(self, 0.09, 2.2, pile + Vector3(-0.6 + (i % 4) * 0.4, 0.15 + (i / 4) * 0.2, 0), Color("8a6a44"), Vector3(90, 0, 90), 6)
	Props.interactable(self, "stakes", Vector3(2.0, 1.2, 1.4), pile + Vector3(0, 0.5, 0))
	for i in STAKES:
		var h := Node3D.new()
		add_child(h)
		var x := 2.5 + i * 4.2
		h.global_position = Vector3(x, gy(x, 114.6), 114.6)
		Props.cyl(h, 0.22, 0.04, Vector3(0, 0.02, 0), Color("3a2a1a"), Vector3.ZERO, 8)
		Props.interactable(h, "hole_%d" % i, Vector3(1.2, 1.2, 1.2), Vector3(0, 0.5, 0))
		_holes.append(h)


## Kızak: kalın kirişler, üstünde iki parçalı tunç namlu; altında üç makara kütüğü. +X yönüne çekilir.
func _build_sled() -> void:
	sled = Node3D.new()
	add_child(sled)
	var wood := Color("6a4a2c")
	Props.box(sled, Vector3(9.0, 0.45, 2.4), Vector3(0, 0.75, 0), wood)
	for x: float in [-3.6, 0.0, 3.6]:
		Props.box(sled, Vector3(0.4, 0.3, 2.8), Vector3(x, 1.0, 0), wood.darkened(0.25))
	var bronze := Color("8c5e26")
	Props.cyl(sled, 0.62, 4.6, Vector3(-1.9, 1.75, 0), bronze, Vector3(0, 0, 90), 14)
	Props.cyl(sled, 0.52, 3.8, Vector3(2.3, 1.68, 0), bronze.lightened(0.05), Vector3(0, 0, 90), 14, 0.48)
	Props.cyl(sled, 0.7, 0.3, Vector3(0.38, 1.75, 0), bronze.darkened(0.2), Vector3(0, 0, 90), 14)
	Props.ring(sled, 0.32, 0.52, Vector3(4.22, 1.68, 0), bronze.darkened(0.3), Vector3(0, 0, 90))
	for x: float in [-3.0, 0.0, 3.0]:
		_rollers.append(_roller(sled, Vector3(x, 0.26, 0)))
	# Çeken bölükler: kızağın önünde iki sıra halat, adamlar geriye yaslanmış (+X'e çeker)
	for row: float in [-1.6, 1.6]:
		var rope := Props.cyl(sled, 0.035, 14.0, Vector3(11.5, 0.9, row), Color("b89a6a"), Vector3(0, 0, 90), 4)
		rope.rotation_degrees = Vector3(0, 0, 90)
		for k in 6:
			var s := Soldier.new([Color("b3262d"), Color("6a4a3a"), Color("e8e0d0"), Color("2f5fa8")][(k + int(row)) % 4], "pull",
				["bork", "turban", "azap"][k % 3])
			s.set_meta("no_talk", true)
			s.set_meta("climber", true)
			s.position = Vector3(6.5 + k * 1.8, 0, row * 1.15)
			s.rotation.y = -PI * 0.5          # kızağa (−X) bakar, geriye yaslanır
			sled.add_child(s)
			_teams.append(s)
	Props.interactable(sled, "roller_back", Vector3(1.4, 1.2, 3.0), Vector3(-5.2, 0.6, 0))
	Props.interactable(sled, "roller_front", Vector3(1.4, 1.2, 3.0), Vector3(5.2, 0.6, 0))
	_place_sled()


func _roller(parent: Node3D, pos: Vector3) -> Node3D:
	var r := Props.cyl(parent, 0.26, 3.0, pos, Color("8a6a44"), Vector3(90, 0, 0), 10)
	return r


func _place_sled() -> void:
	sled.global_position = Vector3(haul_x, gy(haul_x, HAUL_Z), HAUL_Z)
	# Kütükler kızakla birlikte döner (yuvarlanma)
	for r in _rollers:
		if is_instance_valid(r):
			r.rotation.x = PI * 0.5
			r.rotation.y = -haul_x / 0.26


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH28O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH28O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	Audio.ambience("amb_wall_day")
	urban.global_position = Vector3(14.0, gy(14.0, 121.0), 121.0)
	player.global_position = Vector3(16.0, gy(16.0, 123.0) + 0.05, 123.0)
	player.face(urban.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D28O_N_01")
	await hud.say("SPK_URBAN", "D28O_U_01")
	await hud.say("SPK_TOLGA", "D28O_T_01")
	await _stakes_phase()
	await _haul_phase()
	await _first_shot()
	await _end_chapter()


## 1. Kazıklar (6 Nisan). Arada surdan bir gülle düşer.
func _stakes_phase() -> void:
	phase = "stakes"
	player.frozen = false
	_update_objective()
	while stakes < STAKES:
		await get_tree().process_frame
		if GameState.autotest:
			if carrying == "":
				_on_interact("stakes")
			else:
				_on_interact("hole_%d" % stakes)
	player.frozen = true
	_drop()
	hud.set_objective("")
	hud.set_prompt("")
	await hud.say("SPK_URBAN", "D28O_U_STAKES")
	await hud.say("SPK_TOLGA", "D28O_T_STAKES")


## 2. Şahi'yi çekmek (11 Nisan)
func _haul_phase() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH28O_HAUL"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	phase = "haul"
	sled.visible = true
	player.global_position = Vector3(haul_x - 0.8, gy(haul_x - 0.8, HAUL_Z + 2.4) + 0.05, HAUL_Z + 2.4)
	player.face(sled.global_position + Vector3(0, 1.5, 0))
	urban.global_position = Vector3(haul_x + 2.0, gy(haul_x + 2.0, HAUL_Z + 3.4), HAUL_Z + 3.4)
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_URBAN", "D28O_U_HAUL")
	player.frozen = false
	meter.enabled = true
	_update_objective()
	var bot := 0.0
	while haul_x < HAUL_TO:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		if GameState.autotest:
			bot -= dt
			if bot <= 0.0:
				bot = 0.5
				if need_roller and not (GameState.autotest_variant == "lose" and slips == 0):
					if not roller_held:
						player.global_position = sled.to_global(Vector3(-5.6, 0.05, 2.0))
						_on_interact("roller_back")
					else:
						player.global_position = sled.to_global(Vector3(5.6, 0.05, 2.0))
						_on_interact("roller_front")
				else:
					_heave(true)
		elif Input.is_action_just_pressed("jump") and not player.frozen:
			var good := meter.phase >= RowMeter.WIN_A and meter.phase <= RowMeter.WIN_B
			meter.press()
			_heave(good)
		# Urban kızağın yanında yürür
		urban.global_position = Vector3(haul_x + 2.0, gy(haul_x + 2.0, HAUL_Z + 3.4), HAUL_Z + 3.4)
	meter.enabled = false
	player.frozen = true
	_drop()
	hud.set_objective("")
	hud.set_prompt("")
	await hud.say("SPK_URBAN", "D28O_U_PLACED" if slips == 0 else "D28O_U_PLACED_SLIP")


## Bir "hey-yap": iyi çekişte kızak STEP ilerler. Kütük öne alınmadan çekilirse kızak kayar (geri gider).
func _heave(good: bool) -> void:
	if need_roller:
		slips += 1
		haul_x = maxf(HAUL_FROM, haul_x - 1.5)
		_place_sled()
		Fx.trauma(0.4)
		Audio.sfx("land_thud", -2.0, 0.7)
		hud.bark("SPK_URBAN", "D28O_U_SLIP", 3.0)
		return
	if not good:
		Audio.sfx("pick_tap", -14.0, 0.6)
		return
	Audio.sfx("ship_haul", -8.0, randf_range(0.9, 1.1))
	var tw := create_tween()
	var to := minf(haul_x + STEP, HAUL_TO)
	tw.tween_method(_set_haul, haul_x, to, 0.35)
	if to >= HAUL_FROM + _next_roller and to < HAUL_TO - 0.5:
		_next_roller += ROLLER_EVERY
		need_roller = true
		hud.bark("SPK_URBAN", "D28O_U_ROLLER", 3.0)
		_update_objective()


func _set_haul(x: float) -> void:
	haul_x = x
	_place_sled()


## 3. İlk atış (12 Nisan): topu doldur, nişan al. Gülle sağlam sura iner; ilk toz bulutu tespit edilir.
func _first_shot() -> void:
	await hud.fade_to(1.0, 0.8)
	phase = "shot"
	sled.visible = false
	for s in _teams:
		s.visible = false
	gun.visible = true
	gun = walls.build_great_gun()
	_setup_gun_crew()
	urban.global_position = gun.position + Vector3(4.8, 0, 4.4)
	horse.visible = true
	horse.global_position = gun.position + Vector3(-6.0, 0, 9.0)
	horse.rotation.y = PI
	player.global_position = gun.position + Vector3(3.0, 0.05, 6.0)
	player.face(LandWalls.BREACH + Vector3(0, 4.0, 0))
	await hud.card([[tr("UI_CH28O_SHOT"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_FATIH", "D28O_F_01")
	await hud.say("SPK_URBAN", "D28O_U_SHOT")
	hud.set_objective(tr("UI_OBJ28O_LOAD"))
	drill.start(0.25, 0.16)
	while drill.active:
		await get_tree().process_frame
	hud.set_objective("")
	if not drill.physical:
		walls.fire_flash()
		Audio.sfx("cannon", 2.0, 0.75)
		Vfx.explosion(self, gun.position + Vector3(0, 1.6, -5.0), 1.6)
		player.shake(1.0)
		await get_tree().create_timer(1.6).timeout
	hit = _acc >= 0.5
	var at := LandWalls.BREACH + Vector3(randf_range(-1.5, 1.5), 3.5, 1.2) if hit else LandWalls.BREACH + Vector3(randf_range(-10.0, 10.0), 0.8, 7.0)
	if drill.physical and drill.last_impact != Vector3.INF:
		at = drill.last_impact
	walls.impact(at)
	Audio.sfx("explosion_big", -8.0)
	if hit:
		_scar(at)
	await hud.say("SPK_URBAN", "D28O_U_HIT" if hit else "D28O_U_MISS")
	# Tespit: surdaki ilk toz bulutu (vurmadıysa da kaydedilir: ilk atış)
	var target := Node3D.new()
	add_child(target)
	target.global_position = at + Vector3(0, 1.5, 0)
	Vfx.dust(self, at, 2.2)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ28O_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege28o")
	hud.add_child(cam)
	cam.max_dist = 140.0
	cam.cone_deg = 10.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 30.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_FATIH", "D28O_F_02")
	await hud.say("SPK_URBAN", "D28O_U_SEVEN")
	await hud.say("SPK_TOLGA", "D28O_T_END")
	await hud.say("SPK_NIHAT", "D28O_N_END")
	if hit:
		GameState.bump_stat("first_shot", 1, true)
	_outcome = "28O.1" if slips == 0 else "28O.2"
	Siege.record(28, _photo, "SIEGE_NOTE_28O_%s" % _outcome.split(".")[1])


## Sağlam surda ilk gülle yarası: koyu oyuk, çatlaklar
func _scar(at: Vector3) -> void:
	var p := Vector3(at.x, clampf(at.y, 1.5, LandWalls.OUTER_H - 1.0), LandWalls.OUTER_Z1 + 0.02)
	Props.box(self, Vector3(1.8, 1.5, 0.03), p, Color("5e584e"), Vector3(0, 0, randf_range(-20, 20)))
	Props.box(self, Vector3(1.0, 0.9, 0.04), p + Vector3(0, 0, 0.01), Color("2e2a25"), Vector3(0, 0, 45))
	for k in 5:
		var a := randf_range(-PI, PI)
		Props.box(self, Vector3(0.06, randf_range(1.0, 2.2), 0.03), p + Vector3(cos(a) * 1.2, sin(a) * 1.2, 0.015), Color("2e2a25"), Vector3(0, 0, rad_to_deg(a) + 90.0))


func _setup_gun_crew() -> void:
	gun_crew = CannonCrew.new()
	add_child(gun_crew)
	gun_crew.player = player
	gun_crew.hud = hud
	gun_crew.pivot = gun.get_node("Pivot")
	gun_crew.muzzle = gun.get_node("Pivot/Muzzle")
	gun_crew.recoil_node = gun
	gun_crew.aim_spot = gun.to_global(Vector3(0, 0, 8.5))
	gun_crew.aim_back = 13.5
	gun_crew.supplies = {"powder": gun.to_global(Vector3(-2.7, 0, 2.2)), "ball": gun.to_global(Vector3(3.8, 0, -0.5)),
		"wad": gun.to_global(Vector3(-2.8, 0, 5.6)), "rammer": gun.to_global(Vector3(2.8, 0, 5.6))}
	gun_crew.spawn = ["wad"]
	gun_crew.target = func() -> Vector3: return LandWalls.BREACH + Vector3(0, 4.0, 0)
	gun_crew.hit_radius = 5.0
	gun_crew.tolerance = 16.0
	gun_crew.ground_y = 0.0
	gun_crew.load_radius = 3.2
	gun_crew.design_elev = 5.0
	gun_crew.pitch_min = -2.0
	gun_crew.pitch_max = 14.0
	gun_crew.yaw_limit = 6.0
	gun_crew.before_fire = func():
		await get_tree().create_timer(walls.gun_screen(true, 0.7 if not GameState.autotest else 0.02)).timeout
		walls.fire_flash()
	gun_crew.after_fire = func():
		pass
	gun_crew.setup()
	drill.bind(gun_crew)


# ================================================================ etkileşim

func _update_objective() -> void:
	match phase:
		"stakes":
			var look: Variant = null
			if carrying == "" :
				look = Vector3(18.0, gy(18.0, 120.5) + 1.0, 120.5)
			elif stakes < STAKES:
				look = _holes[stakes].global_position + Vector3(0, 1.0, 0)
			hud.set_objective(tr("UI_OBJ28O_STAKES") % [stakes, STAKES], look)
		"haul":
			if need_roller:
				hud.set_objective(tr("UI_OBJ28O_ROLLER"), sled.to_global(Vector3(-5.2 if not roller_held else 5.2, 1.0, 0)))
			else:
				hud.set_objective(tr("UI_OBJ28O_HAUL"), sled.global_position + Vector3(0, 2.0, 0))


func _on_focus(id: String) -> void:
	_focus = id
	var k := ""
	match phase:
		"stakes":
			if id == "stakes" and carrying == "":
				k = "UI_PROMPT28O_TAKE"
			elif id.begins_with("hole_") and carrying == "stake":
				k = "UI_PROMPT28O_PLANT"
		"haul":
			if id == "roller_back" and need_roller and not roller_held:
				k = "UI_PROMPT28O_ROLLER_TAKE"
			elif id == "roller_front" and roller_held:
				k = "UI_PROMPT28O_ROLLER_PUT"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	match phase:
		"stakes":
			if id == "stakes" and carrying == "":
				_pick("stake")
			elif id.begins_with("hole_") and carrying == "stake":
				var i := int(id.trim_prefix("hole_"))
				var h := _holes[i]
				if h.has_meta("done"):
					return
				h.set_meta("done", true)
				_drop()
				Props.cyl(h, 0.09, 2.2, Vector3(0, 0.9, 0.15), Color("8a6a44"), Vector3(-18, 0, 0), 6, 0.02)
				Audio.sfx("pick_tap", -4.0, 0.8)
				stakes += 1
				_update_objective()
		"haul":
			if id == "roller_back" and need_roller and not roller_held:
				roller_held = true
				_pick("roller")
				_update_objective()
			elif id == "roller_front" and roller_held:
				roller_held = false
				need_roller = false
				_drop()
				Audio.sfx("land_thud", -8.0, 1.2)
				hud.bark("SPK_TOLGA", "D28O_T_ROLLER", 2.0)
				_update_objective()


func _pick(what: String) -> void:
	carrying = what
	_carry = Node3D.new()
	_carry.position = Vector3(0.4, -0.55, -1.0)
	player.camera.add_child(_carry)
	if what == "stake":
		Props.cyl(_carry, 0.07, 1.8, Vector3.ZERO, Color("8a6a44"), Vector3(70, 0, 0), 6, 0.02)
		player.speed_mult = 0.85
	else:
		Props.cyl(_carry, 0.22, 1.6, Vector3.ZERO, Color("8a6a44"), Vector3(0, 0, 90), 10)
		player.speed_mult = 0.65
	Props.strip_outlines(_carry)
	Audio.sfx("land_pot", -10.0, 0.7)
	hud.set_prompt("")
	_update_objective()


func _drop() -> void:
	carrying = ""
	player.speed_mult = 1.0
	if is_instance_valid(_carry):
		_carry.queue_free()
	_carry = null


func _process(delta: float) -> void:
	_t += delta
	# 6 Nisan: surdaki Bizans topları arada bir atar; gülle siperin önüne ya da ardına düşer
	if phase == "stakes" and not player.frozen:
		_ball_t -= delta
		if _ball_t <= 0.0:
			_ball_t = randf_range(6.0, 9.0)
			var at := player.global_position + Vector3(randf_range(-14.0, 14.0), 0, randf_range(-12.0, -5.0))
			at.y = gy(at.x, at.z)
			hud.bark("SPK_SOLDIER", "D28O_S_BALL", 1.6)
			get_tree().create_timer(1.2).timeout.connect(func():
				if is_inside_tree():
					Vfx.explosion(self, at, 0.6)
					Vfx.dust(self, at, 1.2)
					Audio.sfx("explosion_small", -6.0)
					Fx.trauma(0.25))
	# Kızağı çeken bölük "hey-yap"la birlikte yaslanır
	if phase == "haul":
		for s in _teams:
			s.rotation.z = sin(_t * 2.0 + s.position.x) * 0.04


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(28, _outcome)
	await Siege.show_page(hud, 28)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(28)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW28O_TITLE")
	c.nodes = [
		{"id": "stakes", "key": "FLOW28O_STAKES", "pos": Vector2(0.5, 0.12)},
		{"id": "28O.1", "key": "FLOW_28O_1", "pos": Vector2(0.3, 0.34), "outcome": true},
		{"id": "28O.2", "key": "FLOW_28O_2", "pos": Vector2(0.7, 0.34), "outcome": true},
		{"id": "shot", "key": "FLOW28O_SHOT", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["stakes", "28O.1"], ["stakes", "28O.2"], ["28O.1", "shot"], ["28O.2", "shot"]]
	for k in ["stakes", _outcome, "shot"]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH28O_STATS") % [slips, tr("UI_CH28O_HIT") if hit else tr("UI_CH28O_NOHIT"), Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "28O.1", "lose": "28O.2"}.get(v, "28O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("28", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and stakes == STAKES and haul_x >= HAUL_TO
	ok = ok and (slips >= 1 if v == "lose" else slips == 0)
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s)" % [expected, _outcome, not page.is_empty(), cam != null and cam.done])
	print("AUTOTEST %s chapter=28o variant=%s outcome=%s stakes=%d slips=%d hit=%s" % ["PASS" if ok else "FAIL", v, _outcome, stakes, slips, hit])
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
	haul_x = -2.0
	_place_sled()
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(haul_x - 9.0, gy(haul_x, HAUL_Z) + 4.5, HAUL_Z + 11.0)
	cv.look_at(sled.global_position + Vector3(5.0, 1.5, -2.0), Vector3.UP)
	cv.fov = 55.0
	cv.make_current()
	await get_tree().create_timer(0.6).timeout
	await _shot_png("c28o_cover.png")
	get_tree().quit()
