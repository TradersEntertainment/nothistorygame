extends Node3D
## Bölüm 19 (Osmanlı tarafı) — Devriye (Tolga · 3 Mayıs gecesi ve 23 Mayıs şafağı, Haliç'in ağzı).
##
## Bölüm 19'un öbür yüzü: Hamza Bey'in donanmasından bir devriye kayığı zincirin dışında dolaşır. Tolga kürektedir.
##   Gece zincirin açıklığından sarıklı, Osmanlı sancaklı bir brigantin çıkar. Devriye yanaşır; Tolga bir şey fark eder
##   (sarıklar ters sarılmış, kaptanın "aleyküm"ü İtalyanca). Reise söyler ya da susar; brigantin her durumda geçer.
##   Tespit: sancaklı brigantin açığa giderken. Yirmi gün sonra, şafakta aynı gemi geri döner; devriye kovalar
##   (kürek ritmi), brigantin zincirin ardına girer. Tarih yine aynı.
##   19O.1 Reise söyledi (inanmadı) · 19O.2 Sustu
##   --autotest[=silent]   (varsayılan: 19O.1)

const PATROL_PATH := [Vector3(76, 0, 92), Vector3(52, 0, 70), Vector3(30, 0, 54), Vector3(18, 0, 50)]
const BRIG_PATH := [Vector3(-12, 0, 10), Vector3(-4, 0, 30), Vector3(6, 0, 40), Vector3(14, 0, 44), Vector3(40, 0, 58), Vector3(120, 0, 80)]
const CHASE_PATH := [Vector3(90, 0, 96), Vector3(56, 0, 74), Vector3(34, 0, 62), Vector3(18, 0, 56)]
const MEET_BRIG := 38.0     # brigantinin yolu üzerinde karşılaşma noktası (m)
const SPOT_AT := 0.55
const DECK_Y := 0.75
const BRIG_DECK := 1.0

var walls: SeaWalls
var player: Player
var hud: Hud
var meter: RowMeter
var cam: TespitCam
var boat: Node3D
var reis: Soldier
var rowers: Array[Person] = []
var oars: Array[Node3D] = []
var ship: Node3D
var captain: Person
var brig_crew: Array[Person] = []
var fleet: Array[Node3D] = []
var phase := "intro"
var _outcome := ""
var told := false
var gun_shots := 0
var gun_hits := 0
var brig_slow := 0.0
var _spotted := false
var _path: Array = PATROL_PATH
var _total := 0.0
var boat_d := 0.0
var brig_d := 0.0
var _speed := 0.0
var gap := 0.0
var _photo := ""
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(19)
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
	walls.niko.visible = false
	boat = _kayik(true)
	for i in 2:
		fleet.append(_kayik(false))
		fleet[i].visible = false
	_build_ship()
	# Hamza Bey'in donanması: Haliç'in ağzının dışında demirli kadırgalar (fenerleri yanık), aralarında kayıklar
	var rng := RandomNumberGenerator.new()
	rng.seed = 1903
	for i in 16:
		var gp := Vector3(rng.randf_range(150.0, 330.0), 0, rng.randf_range(60.0, 230.0))
		Horn.galley(self, gp, rng.randf_range(-0.6, 0.6) + PI * 0.5, true)
	for i in 6:
		Horn.rowboat(self, Vector3(rng.randf_range(130.0, 260.0), 0, rng.randf_range(70.0, 200.0)), rng.randf() * TAU)
	_set_path(PATROL_PATH)
	_place(boat, _path, 0.0)
	_place(ship, BRIG_PATH, 0.0)
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ yol

static func _length(path: Array) -> float:
	var l := 0.0
	for i in path.size() - 1:
		l += (path[i] as Vector3).distance_to(path[i + 1])
	return l


static func _along(path: Array, d: float) -> Array:
	d = clampf(d, 0.0, _length(path))
	for i in path.size() - 1:
		var a: Vector3 = path[i]
		var b: Vector3 = path[i + 1]
		var l := a.distance_to(b)
		if d <= l or i == path.size() - 2:
			return [a.lerp(b, clampf(d / l, 0.0, 1.0)), (b - a).normalized()]
		d -= l
	return [path[-1], Vector3.FORWARD]


func _set_path(p: Array) -> void:
	_path = p
	_total = _length(p)


func _place(n: Node3D, path: Array, d: float, flip := false) -> void:
	var at: Array = _along(path, d)
	var p: Vector3 = at[0]
	var dir: Vector3 = at[1] * (-1.0 if flip else 1.0)
	n.global_position = p + Vector3(0, sin(_t * 1.3 + n.get_index()) * 0.05, 0)
	n.look_at(p + dir, Vector3.UP)
	n.rotation.z = sin(_t * 0.9 + n.get_index()) * 0.02


# ================================================================ sahne

## Devriye kayığı: dar gövde, iki çift kürek, pruvada fener, kıçta reis. Tolga sol arka kürekte.
func _kayik(ours: bool) -> Node3D:
	var g := Node3D.new()
	add_child(g)
	g.add_child(LowPoly.hull([
		{"z": -4.4, "w": 0.06, "top": 1.3, "bottom": 0.6},
		{"z": -2.0, "w": 1.0, "top": 1.0, "bottom": -0.2},
		{"z": 1.0, "w": 1.1, "top": 0.95, "bottom": -0.25},
		{"z": 3.8, "w": 0.7, "top": 1.3, "bottom": 0.3},
	], Color("3a2a1c"), Color("7e2420"), 0.9))
	Props.box(g, Vector3(1.8, 0.06, 7.0), Vector3(0, DECK_Y - 0.03, 0), Color("8a6a4a"))
	for z: float in [-1.2, 1.0]:
		Props.box(g, Vector3(1.8, 0.08, 0.3), Vector3(0, DECK_Y + 0.4, z + 0.25), Color("6a4a2c"))
		for s: float in [-1.0, 1.0]:
			# Tolga sağ sırada: brigantin sağdan yanaşır, reise bakarken yanında kürekçi olmaz
			var mine := ours and s > 0.0 and z > 0.0
			if not mine:
				var r := Person.new({"coat": [Color("6a5040"), Color("5a6a7a"), Color("7a4a3a")][(rowers.size() + int(z)) % 3],
					"pants": Color("e8e0d0"), "hat": "bork" if s > 0.0 else "turban", "mustache": true})
				r.set_meta("no_talk", true)
				r.position = Vector3(s * 0.45, DECK_Y, z)
				g.add_child(r)
				r.set_activity("row")
				rowers.append(r)
			var pivot := Node3D.new()
			pivot.position = Vector3(s * 0.95, DECK_Y + 0.5, z)
			pivot.set_meta("side", s)
			g.add_child(pivot)
			Props.cyl(pivot, 0.035, 3.4, Vector3(s * 0.9, 0, 0), Color("c9a878"), Vector3(0, 0, 90), 5)
			Props.box(pivot, Vector3(0.55, 0.03, 0.2), Vector3(s * 2.4, 0, 0), Color("b8905a"))
			pivot.rotation.z = s * 0.28
			oars.append(pivot)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.0, -3.4)
	lamp.light_color = Color("ffb060")
	lamp.light_energy = 2.0
	lamp.omni_range = 12.0
	g.add_child(lamp)
	Props.cyl(g, 0.03, 1.2, Vector3(0, DECK_Y + 0.8, -3.4), Color("5a3e26"), Vector3.ZERO, 4)
	var lm := Props.ball(g, 0.16, Vector3(0, 1.95, -3.4), Color("ffb040"), Vector3.ONE, 6, 3.0)
	lm.material_override = Props.mat(Color("ffb040"), 3.0, false, "", false)
	if ours:
		reis = Soldier.new(Color("2f5fa8"), "stand", "bork")
		reis.position = Vector3(0, DECK_Y, 3.0)
		reis.rotation.y = PI
		g.add_child(reis)
	return g


## Brigantin: bölüm 19'dakinin aynısı (sarıklı tayfa, direkte Osmanlı sancağı; kılık).
func _build_ship() -> void:
	ship = Node3D.new()
	add_child(ship)
	ship.add_child(LowPoly.hull([
		{"z": -7.0, "w": 0.08, "top": 2.0, "bottom": 1.0},
		{"z": -4.0, "w": 1.5, "top": 1.35, "bottom": -0.3},
		{"z": 0.0, "w": 1.8, "top": 1.3, "bottom": -0.4},
		{"z": 4.0, "w": 1.5, "top": 1.5, "bottom": -0.2},
		{"z": 5.6, "w": 0.9, "top": 2.0, "bottom": 0.6},
	], Color("4a3322"), Color("7a2a24"), 1.2))
	Props.box(ship, Vector3(3.0, 0.08, 10.5), Vector3(0, BRIG_DECK - 0.03, -0.5), Color("a8845a"))
	for spec in [[Vector3(0, 0, -2.0), 8.0], [Vector3(0, 0, 2.2), 6.5]]:
		var mp: Vector3 = spec[0]
		var h: float = spec[1]
		Props.cyl(ship, 0.1, h, mp + Vector3(0, BRIG_DECK + h * 0.5, 0), Color("5a3e26"), Vector3.ZERO, 6)
		Props.cyl(ship, 0.06, h * 1.1, mp + Vector3(0, BRIG_DECK + h * 0.7, 0.2), Color("6a4a2c"), Vector3(55, 0, 0), 5)
		# Yelken baş hizasının üstünde (alt kenarı güverteden ~2.6 m yukarıda): güvertede konuşanları örtmesin
		Props.box(ship, Vector3(0.04, h * 0.55, h * 0.55), mp + Vector3(0.12, BRIG_DECK + h * 0.68, 0.9), Color("e8dcc0"), Vector3(-20, 0, 0))
		Props.box(ship, Vector3(0.04, 0.8, 1.3), mp + Vector3(0, BRIG_DECK + h + 0.4, 0.6), Color("b3262d"))
		Props.crescent(ship, mp + Vector3(0, BRIG_DECK + h + 0.4, 0.55), 0.22, Color("b3262d"))
	for i in 5:
		var c := Person.new({"coat": [Color("6a5040"), Color("5a6a7a"), Color("7a4a3a"), Color("8a7a5a"), Color("4a4a5a")][i], "pants": Color("3a3028"),
			"hat": "turban", "beard": i % 2 == 0, "mustache": true})
		c.set_meta("no_talk", true)
		# Reisin (x 1, z 0.6) devriyeye (-X) bakan hattı boş kalır: sonuncusu kıça geçer
		c.position = Vector3(-0.8 + (i % 2) * 1.6, BRIG_DECK, -4.2 + i * 1.2 if i < 4 else 2.6)
		ship.add_child(c)
		brig_crew.append(c)
	captain = Person.new({"coat": Color("2a3a6a"), "pants": Color("2a2226"), "hat": "turban", "beard": true, "mustache": true, "skin": Color("dcae88"),
		"face": {"nose": "long", "brow": 1.2, "beard": "short", "head": Vector3(1.0, 1.05, 1.0)}})
	captain.set_meta("spk", "SPK_BRIG")
	captain.position = Vector3(1.0, BRIG_DECK, 0.6)
	captain.rotation.y = -PI * 0.5
	ship.add_child(captain)


func _world_env() -> Environment:
	for c in walls.get_children():
		if c is WorldEnvironment:
			return (c as WorldEnvironment).environment
	return null


func _make_dawn() -> void:
	var e := _world_env()
	if e == null:
		return
	if e.sky and e.sky.sky_material is ProceduralSkyMaterial:
		var sm := e.sky.sky_material as ProceduralSkyMaterial
		sm.sky_top_color = Color("4a5a8a")
		sm.sky_horizon_color = Color("f0a878")
		sm.ground_horizon_color = Color("a07868")
	e.ambient_light_color = Color("c8a8a0")
	e.ambient_light_energy = 0.8
	e.fog_light_color = Color("c89880")
	for c in walls.get_children():
		if c is DirectionalLight3D:
			(c as DirectionalLight3D).light_color = Color("ffc890")
			(c as DirectionalLight3D).light_energy = 0.9
			(c as DirectionalLight3D).rotation_degrees = Vector3(-12, -70, 0)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH19O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH19O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.pinned = true
	player.show_remote(false)
	_seat()
	player.face(reis.global_position + Vector3(0, 1.4, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D19O_N_01")
	await hud.say("SPK_PATROL", "D19O_R_01")
	await hud.say("SPK_TOLGA", "D19O_T_01")
	await hud.say("SPK_PATROL", "D19O_R_02")
	# Kürek: zincirin dışında devriye
	phase = "row"
	player.frozen = false
	meter.enabled = true
	hud.set_objective(tr("UI_OBJ19O_ROW"))
	while boat_d < _total * SPOT_AT:
		await get_tree().process_frame
	# Gözcülük: zincirin açıklığında bir gölge
	phase = "watch"
	meter.enabled = false
	hud.set_objective(tr("UI_OBJ19O_WATCH"))
	await hud.say("SPK_PATROL", "D19O_R_WATCH")
	if GameState.autotest:
		_spot()
	var wt := 0.0
	while not _spotted:
		await get_tree().process_frame
		wt += get_process_delta_time()
		if (Input.is_action_just_pressed("interact") and _looking_at(ship.global_position + Vector3(0, 3, 0), 12.0)) or wt > 25.0:
			_spot()
	hud.set_objective("")
	await _meet()
	await _photo_step()
	await _chase()
	await _end_chapter()


func _seat() -> void:
	if player.pinned:
		player.eye_height = 1.15
		player.global_position = boat.to_global(Vector3(0.45, DECK_Y + 0.05, 1.0))


func _looking_at(p: Vector3, cone: float) -> bool:
	var cam3 := player.camera
	var to := p - cam3.global_position
	return rad_to_deg((-cam3.global_transform.basis.z).angle_to(to.normalized())) < cone


func _spot() -> void:
	if _spotted:
		return
	_spotted = true
	hud.bark("SPK_TOLGA", "D19O_T_SPOT", 3.0)


## Yanaşma: brigantin karşılaşma noktasında, devriye yanında durur.
func _meet() -> void:
	phase = "meet"
	player.frozen = true
	# Brigantini karşılaşma noktasına getir; devriye yanına
	while brig_d < MEET_BRIG:
		brig_d = move_toward(brig_d, MEET_BRIG, 6.0 * get_process_delta_time())
		boat_d = move_toward(boat_d, _total, 3.0 * get_process_delta_time())
		await get_tree().process_frame
	var at: Array = _along(BRIG_PATH, MEET_BRIG)
	var side := (at[1] as Vector3).cross(Vector3.UP).normalized()
	var to := (at[0] as Vector3) - side * 5.0
	var tw := create_tween()
	tw.tween_property(boat, "global_position", to, 1.6)
	await tw.finished
	boat.look_at(to + (at[1] as Vector3), Vector3.UP)
	_seat()
	player.face(captain.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_PATROL", "D19_P_01")
	await hud.say("SPK_BRIG", "D19O_C_ANSWER")
	await hud.say("SPK_TOLGA", "D19O_T_NOTICE")
	var c := await hud.choose(["UI_C19O_TELL", "UI_C19O_WISH", "UI_C19O_SILENT"], 12.0, 2 if GameState.autotest_variant == "silent" else 0)
	match c:
		0:
			told = true
			await hud.say("SPK_TOLGA", "D19O_T_TELL")
			await hud.say("SPK_PATROL", "D19O_R_TELL")
			await hud.say("SPK_BRIG", "D19O_C_TELL")
		1:
			await hud.say("SPK_TOLGA", "D19O_T_WISH")
			await hud.say("SPK_BRIG", "D19O_C_WISH")
		_:
			await hud.say("SPK_PATROL", "D19O_R_SILENT")
	await hud.say("SPK_PATROL", "D19O_R_PASS")
	phase = "leave"


func _photo_step() -> void:
	var target := Node3D.new()
	ship.add_child(target)
	target.position = Vector3(0, 4.0, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ19O_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege19o")
	hud.add_child(cam)
	cam.max_dist = 120.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 30.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_NIHAT", "D19O_N_GONE")


## Yirmi gün sonra, şafak: brigantin döner; devriye ve iki kayık daha kovalar. Brigantin zincirin ardına girer.
func _chase() -> void:
	await hud.fade_to(1.0, 1.0)
	await hud.card([[tr("UI_CH19O_LATER"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	_make_dawn()
	_set_path(CHASE_PATH)
	boat_d = 0.0
	brig_d = _length(BRIG_PATH) - 30.0
	for i in fleet.size():
		fleet[i].visible = true
	phase = "chase_intro"
	_seat()
	player.face(ship.global_position + Vector3(0, 2.0, 0))
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_PATROL", "D19O_R_BACK")
	await hud.say("SPK_TOLGA", "D19O_T_BACK")
	# Kovalamacadan önce: reis tüfeği uzatır; brigantinin güvertesindeki tayfa (yelken ve kürek başındakiler).
	# Vurulan her tayfa brigantini yavaşlatır (tarih aynı: yine zincirin ardına girer, ama ara daralır).
	phase = "shoot"
	await hud.say("SPK_PATROL", "D19O_R_GUN")
	var res: Dictionary = await GunRange.run(self, hud, player, {"targets": brig_crew, "shots": 4, "limit": 22.0,
		"objective": tr("UI_OBJ19O_GUN") % 4, "look": ship.global_position + Vector3(0, 2.0, 0)})
	gun_shots = res["shots"]
	gun_hits = res["hits"]
	brig_slow = 0.45 * gun_hits
	GameState.bump_stat("osm_boat_gun", gun_hits, true)
	await hud.say("SPK_TOLGA", "D19O_T_GUN_GOOD" if gun_hits >= 2 else "D19O_T_GUN_BAD")
	phase = "chase"
	meter.enabled = true
	player.frozen = false
	hud.set_objective(tr("UI_OBJ19O_CHASE"))
	var start_gap := _gap()
	gap = start_gap
	while brig_d > 22.0:
		await get_tree().process_frame
		var g := _gap()
		gap = minf(gap, g)
		hud.set_chase(tr("UI_CH19O_GAP") % int(g), clampf(1.0 - (g - 8.0) / maxf(1.0, start_gap - 8.0), 0.0, 1.0))
	meter.enabled = false
	hud.set_chase("", 0.0)
	hud.set_objective("")
	phase = "enter"
	player.frozen = true
	# Zincir bir an indirilir, brigantin içeri süzülür
	Audio.sfx("kick_metal", -6.0, 0.5)
	await hud.say("SPK_PATROL", "D19O_R_CHAIN")
	while brig_d > 0.0:
		brig_d = move_toward(brig_d, 0.0, 6.0 * get_process_delta_time())
		await get_tree().process_frame
	if gap < 14.0:
		await hud.say("SPK_PATROL", "D19O_R_CLOSE")
	await hud.say("SPK_TOLGA", "D19O_T_END_TOLD" if told else "D19O_T_END")
	await hud.say("SPK_NIHAT", "D19O_N_END")
	_outcome = "19O.1" if told else "19O.2"
	Siege.record(19, _photo, "SIEGE_NOTE_19O_%s" % _outcome.split(".")[1])


func _gap() -> float:
	return boat.global_position.distance_to(ship.global_position)


func _process(delta: float) -> void:
	_t += delta
	match phase:
		"intro", "row", "watch":
			if phase == "row":
				var target := (2.0 + 4.2 * meter.speed_factor()) if meter.enabled else 0.6
				_speed = move_toward(_speed, target, delta * 1.5)
				boat_d = minf(boat_d + _speed * delta, _total)
				if Input.is_action_just_pressed("jump") and not player.frozen:
					meter.press()
			if phase == "watch":
				brig_d = minf(brig_d + 3.0 * delta, MEET_BRIG)
			_place(boat, _path, boat_d)
			_place(ship, BRIG_PATH, brig_d)
			_seat()
		"meet":
			_place(ship, BRIG_PATH, brig_d)
			if boat_d < _total:
				_place(boat, _path, boat_d)
			_seat()
		"leave":
			brig_d = minf(brig_d + 4.0 * delta, _length(BRIG_PATH))
			_place(ship, BRIG_PATH, brig_d)
			_seat()
		"chase_intro", "chase", "enter", "shoot":
			if phase == "shoot":
				brig_d = maxf(brig_d - 2.0 * delta, 0.0)       # brigantin ağır ağır zincire yanaşır
			if phase == "chase":
				var target := (3.0 + 5.0 * meter.speed_factor()) if meter.enabled else 1.0
				_speed = move_toward(_speed, target, delta * 1.5)
				boat_d = minf(boat_d + _speed * delta, _total)
				brig_d = maxf(brig_d - (5.2 - brig_slow) * delta, 0.0)
				if Input.is_action_just_pressed("jump") and not player.frozen:
					meter.press()
			_place(boat, _path, boat_d)
			_place(ship, BRIG_PATH, brig_d, true)
			for i in fleet.size():
				_place(fleet[i], _path, maxf(boat_d - 10.0 - i * 7.0, 0.0))
				fleet[i].global_position += Vector3(4.0 + i * 3.0, 0, -3.0)
			_seat()
	_animate_oars()


func _animate_oars() -> void:
	var moving := meter.enabled
	var ph := meter.phase if moving else fmod(_t * 0.3, 1.0)
	for r in rowers:
		if r.rig:
			r.rig.row_phase = ph if moving else -1.0
	for o: Node3D in oars:
		var side: float = o.get_meta("side")
		var sweep := sin(ph * TAU) * 0.45 if moving else 0.0
		var lift := (0.28 if ph >= 0.5 or not moving else 0.12)
		o.rotation = Vector3(0, side * sweep, side * lift)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(19, _outcome)
	await Siege.show_page(hud, 19)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(19)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW19O_TITLE")
	c.nodes = [
		{"id": "patrol", "key": "FLOW19O_PATROL", "pos": Vector2(0.5, 0.12)},
		{"id": "19O.1", "key": "FLOW_19O_1", "pos": Vector2(0.3, 0.34), "outcome": true},
		{"id": "19O.2", "key": "FLOW_19O_2", "pos": Vector2(0.7, 0.34), "outcome": true},
		{"id": "back", "key": "FLOW19O_BACK", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["patrol", "19O.1"], ["patrol", "19O.2"], ["19O.1", "back"], ["19O.2", "back"]]
	for k in ["patrol", _outcome, "back"]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH19O_STATS") % [int(gap), Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	c.footer_lines.insert(0, Grade.finish("19o"))
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "19O.1", "silent": "19O.2"}.get(v, "19O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("19", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and _spotted
	# Tüfek: en az üç atış, en az bir isabet (brigantin yavaşlamış olmalı)
	ok = ok and gun_shots >= 3 and gun_hits >= 1 and brig_slow > 0.0
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=19o variant=%s outcome=%s gap=%d gun=%d/%d" % ["PASS" if ok else "FAIL", v, _outcome, int(gap), gun_hits, gun_shots])
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
	player.pinned = true
	phase = "meet"
	brig_d = MEET_BRIG
	_set_path(PATROL_PATH)
	boat_d = _total * 0.8
	meter.enabled = true
	await get_tree().create_timer(0.6).timeout
	player.face(ship.global_position + Vector3(0, 2.0, 0))
	hud.set_objective(tr("UI_OBJ19O_ROW"))
	await _shot_png("c19o_01_row.png")
	meter.enabled = false
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	var mid := boat.global_position.lerp(ship.global_position, 0.5)
	var back := (boat.global_position - ship.global_position).normalized()
	cv.global_position = boat.global_position + back * 5.0 + back.cross(Vector3.UP) * 5.0 + Vector3(0, 3.0, 0)
	cv.look_at(mid + Vector3(0, 2.0, 0), Vector3.UP)
	cv.fov = 42.0
	cv.make_current()
	await get_tree().create_timer(0.3).timeout
	await _shot_png("c19o_cover.png")
	get_tree().quit()
