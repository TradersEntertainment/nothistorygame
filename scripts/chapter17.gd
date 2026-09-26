extends Node3D
## Bölüm 17 — Kundak (Tolga · 28 Nisan 1453, şafaktan iki saat önce). docs/SIEGE.md §3, Perde IV'ün ilk bölümü.
##
## Önsöz (Salı, Zaman Bürosu): Vikipedi'deki kuşatma sayfası "kaynak belirtilmeli" ile dolmuştur. Nihat, Tolga'ya
## Geçici Tanık Sözleşmesi (Form Z-1453/GT) imzalatır: olayları değiştirmeyecek, tespit edecektir.
## Haliç: Venedikli Giacomo Coco, Osmanlı gemilerini yakmak için gece baskınına çıkar. Tolga Trevisano'nun
## kadırgasında kürek çeker (ritim). Galata'da bir ışık yanar (tespit karesi; kimin yaktığını kaynaklar tartışır).
## Osmanlı topları açılır, Coco'nun fustası vurulup batar. Tolga suya düşen denizcileri kayığa çeker.
##   17.1 Üç denizci kurtarıldı · 17.2 Bir kısmı kurtarıldı · 17.3 Tolga da suya düştü (tayfa çekti)
##   --autotest[=two|fall|nophoto]   (varsayılan: 17.1)

const PATH := [Vector3(-14, 0, 9), Vector3(-40, 0, 50), Vector3(-66, 0, 96), Vector3(-84, 0, 126), Vector3(-92, 0, 140)]
const REST_BACK := 13.0        # kayık, Coco'nun vurulduğu yerin bu kadar gerisinde durur
const LIGHT_AT := 58.0         # yol üzerinde Galata ışığının yandığı yer (m)
const GALATA_LIGHT := Vector3(-30, 37.6, 190)
const RESCUE_TIME := 40.0
const DECK_Y := 0.95
const ROWER_Z := [-3.2, -1.6, 1.6, 3.2]

var walls: SeaWalls
var bureau: Bureau
var player: Player
var hud: Hud
var meter: RowMeter
var cam: TespitCam
var phase := "intro"
var _outcome := ""
var _saved := 0
var _fell := false
var _photo := ""
var _total := 0.0

var boat: Node3D
var boat_d := 0.0
var _speed := 0.0
var rowers: Array[Person] = []
var oars: Array[Node3D] = []
var my_oar: Node3D
var trevisano: Person
var coco_boat: Node3D
var coco_d := 14.0
var coco: Person
var coco_rowers: Array[Person] = []
var ships: Array[Node3D] = []
var lantern: Node3D
var _lantern_light: OmniLight3D
var batteries: Array[Vector3] = []
var swimmers: Array = []        # {node: Person, body: StaticBody3D, saved: bool}
var nihat: Person
var _t := 0.0
var _gun_t := 0.0
var _rescue_t := 0.0


func _ready() -> void:
	GameState.snapshot(17)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	meter = RowMeter.new()
	hud.add_child(meter)
	meter.stroke.connect(_on_stroke)
	for i in PATH.size() - 1:
		_total += (PATH[i] as Vector3).distance_to(PATH[i + 1])
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ yol

## Yol üzerindeki d metredeki nokta ve yön.
func _along(d: float) -> Array:
	d = clampf(d, 0.0, _total)
	for i in PATH.size() - 1:
		var a: Vector3 = PATH[i]
		var b: Vector3 = PATH[i + 1]
		var l := a.distance_to(b)
		if d <= l or i == PATH.size() - 2:
			return [a.lerp(b, clampf(d / l, 0.0, 1.0)), (b - a).normalized()]
		d -= l
	return [PATH[-1], Vector3.FORWARD]


func _place_boat(n: Node3D, d: float, bob_phase := 0.0) -> void:
	var at: Array = _along(d)
	var p: Vector3 = at[0]
	var dir: Vector3 = at[1]
	n.global_position = p + Vector3(0, sin(_t * 1.3 + bob_phase) * 0.05, 0)
	n.look_at(p + dir, Vector3.UP)
	n.rotation.z = sin(_t * 0.9 + bob_phase) * 0.02


# ================================================================ sahne

func _build_horn() -> void:
	walls = SeaWalls.new()
	add_child(walls)
	walls.niko.visible = false
	boat = _galley(12.0, 1.35, Color("4a3524"), Color("7a2a24"), true)
	coco_boat = _galley(9.0, 1.1, Color("3e2c1e"), Color("2a4a7a"), false)
	for i in 2:
		ships.append(_merchant())
	_build_fleet()
	_build_lantern()
	_place_boat(boat, 0.0)
	_place_boat(coco_boat, coco_d, 1.0)
	_place_ships()


## Kürekli kadırga: gövde, güverte (katı), korkuluk, sıralar, kürekçiler ve kürekler.
func _galley(length: float, w: float, hull: Color, band: Color, is_ours: bool) -> Node3D:
	var g := Node3D.new()
	add_child(g)
	var h := length * 0.5
	g.add_child(LowPoly.hull([
		{"z": -h - 0.6, "w": 0.06, "top": 1.7, "bottom": 0.9},
		{"z": -h * 0.6, "w": w, "top": 1.25, "bottom": -0.25},
		{"z": 0.0, "w": w * 1.1, "top": 1.2, "bottom": -0.35},
		{"z": h * 0.6, "w": w, "top": 1.3, "bottom": -0.25},
		{"z": h + 0.4, "w": w * 0.55, "top": 1.8, "bottom": 0.5},
	], hull, band, 1.15))
	Props.box(g, Vector3(w * 1.7, 0.08, length * 0.95), Vector3(0, DECK_Y - 0.04, 0), Color("a8845a"))
	if is_ours:
		var deck := Props.solid(g, Vector3(w * 1.7, 0.2, length * 0.95), Vector3(0, DECK_Y - 0.1, 0), Color("a8845a"))
		deck.get_child(0).visible = false
		for s in [-1.0, 1.0]:
			var rail := Props.solid(g, Vector3(0.12, 0.55, length * 0.9), Vector3(s * (w * 0.88), DECK_Y + 0.28, 0), Color("5a3e26"))
			rail.set_meta("no_climb", true)
		for z in [-h * 0.95, h * 0.95]:
			Props.solid(g, Vector3(w * 1.7, 0.55, 0.12), Vector3(0, DECK_Y + 0.28, z), Color("5a3e26")).set_meta("no_climb", true)
	else:
		for s in [-1.0, 1.0]:
			Props.box(g, Vector3(0.1, 0.4, length * 0.9), Vector3(s * (w * 0.88), DECK_Y + 0.2, 0), Color("5a3e26"))
	# Sıralar ve kürekçiler (kürekçiler kıça bakar: Person +Z'ye bakar)
	var zs: Array = ROWER_Z if is_ours else [-2.2, 0.0, 2.2]
	for z: float in zs:
		Props.box(g, Vector3(w * 1.6, 0.08, 0.3), Vector3(0, DECK_Y + 0.42, z + 0.25), Color("7a5a3a"))
		for s in [-1.0, 1.0]:
			if is_ours and s < 0.0 and is_equal_approx(z, 1.6):
				continue   # Tolga'nın yeri
			var r := Person.new({"coat": [Color("6a5040"), Color("5a6a7a"), Color("7a4a3a"), Color("8a7a5a")][rowers.size() % 4],
				"pants": Color("3a3028"), "mustache": rowers.size() % 2 == 0})
			r.set_meta("no_talk", true)
			r.position = Vector3(s * w * 0.45, DECK_Y, z)
			g.add_child(r)
			r.set_activity("row")
			(coco_rowers if not is_ours else rowers).append(r)
			var oar := _oar(g, Vector3(s * w * 0.95, DECK_Y + 0.55, z), s)
			if is_ours:
				oars.append(oar)
	if is_ours:
		my_oar = _oar(g, Vector3(-w * 0.95, DECK_Y + 0.55, 1.6), -1.0)
		trevisano = Person.new({"face": {"nose": "long", "brow": 1.2, "beard": "short", "head": Vector3(1.0, 1.05, 1.0)},
			"coat": Color("6a1e22"), "pants": Color("2a2226"), "hat": "berretta", "beard": true, "skin": Color("e0b08a")})
		trevisano.set_meta("spk", "SPK_TREVISANO")
		trevisano.position = Vector3(0, DECK_Y, h * 0.8)
		trevisano.rotation.y = PI
		g.add_child(trevisano)
	else:
		coco = Person.new({"face": {"nose": "hook", "brow": 1.4, "brow_tilt": 6.0, "beard": "short", "head": Vector3(1.04, 1.0, 1.0)},
			"coat": Color("2a3a6a"), "pants": Color("2a2226"), "hat": "berretta", "beard": true, "mustache": true, "skin": Color("dcae88")})
		coco.set_meta("spk", "SPK_COCO")
		coco.position = Vector3(0, DECK_Y, -h * 0.75)
		coco.rotation.y = PI
		g.add_child(coco)
	return g


func _oar(g: Node3D, lock: Vector3, side: float) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = lock
	pivot.set_meta("side", side)
	g.add_child(pivot)
	# Sap içeride (0.9 m), kürek dışarıda (3.2 m), palası suda
	Props.cyl(pivot, 0.04, 4.1, Vector3(side * 1.15, 0, 0), Color("c9a878"), Vector3(0, 0, 90), 5)
	Props.box(pivot, Vector3(0.7, 0.03, 0.22), Vector3(side * 3.0, 0, 0), Color("b8905a"))
	pivot.rotation.z = side * 0.28
	return pivot


## Yün ve pamuk çuvallarıyla kaplı iki büyük gemi (top güllesine karşı; Barbaro'da geçer).
func _merchant() -> Node3D:
	var g := Node3D.new()
	add_child(g)
	g.add_child(LowPoly.hull([
		{"z": -10.0, "w": 0.1, "top": 4.2, "bottom": 2.2},
		{"z": -6.0, "w": 2.8, "top": 3.4, "bottom": -0.8},
		{"z": 0.0, "w": 3.2, "top": 3.2, "bottom": -1.0},
		{"z": 6.0, "w": 2.8, "top": 3.8, "bottom": -0.6},
		{"z": 9.0, "w": 2.0, "top": 5.2, "bottom": 1.2},
	], Color("4a3322"), Color("5a2a22"), 2.6))
	Props.box(g, Vector3(5.2, 0.12, 16.0), Vector3(0, 3.0, 0), Color("9a7a52"))
	Props.cyl(g, 0.22, 16.0, Vector3(0, 11.0, -1.0), Color("5a3e26"), Vector3.ZERO, 6)
	Props.box(g, Vector3(6.0, 0.14, 0.14), Vector3(0, 15.0, -1.0), Color("5a3e26"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 28 + ships.size()
	for s in [-1.0, 1.0]:
		for i in 14:
			var z := -7.0 + i * 1.1
			Props.ball(g, 0.5, Vector3(s * 3.1, 2.8 + rng.randf_range(-0.2, 0.3), z), Color("e6dcc4").darkened(rng.randf_range(0.0, 0.25)), Vector3(0.9, 1.1, 1.0), 6)
	return g


func _place_ships() -> void:
	for i in ships.size():
		var d := maxf(boat_d - 18.0 - i * 8.0, 0.0)
		var at: Array = _along(d)
		var dir: Vector3 = at[1]
		var side := dir.cross(Vector3.UP).normalized() * (13.0 if i == 0 else -11.0)
		var p: Vector3 = at[0] + side
		ships[i].global_position = p + Vector3(0, sin(_t * 0.8 + i) * 0.08, 0)
		ships[i].look_at(p + dir, Vector3.UP)


## Kuzey kıyısında (Kasımpaşa, Pınarlar Vadisi) demirli Osmanlı kadırgaları, fenerleri ve kıyı topları.
func _build_fleet() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	for i in 9:
		var p := Vector3(-150.0 + i * 11.0, 0, 158.0 + rng.randf_range(-2, 3))
		var g := Node3D.new()
		g.position = p + Vector3(0, -0.3, 0)
		g.rotation.y = deg_to_rad(80 + rng.randf_range(-10, 10))
		add_child(g)
		g.add_child(LowPoly.hull([
			{"z": -9.0, "w": 0.06, "top": 2.3, "bottom": 1.4},
			{"z": -6.0, "w": 1.3, "top": 1.9, "bottom": 0.3},
			{"z": 0.0, "w": 1.7, "top": 1.85, "bottom": 0.2},
			{"z": 5.0, "w": 1.4, "top": 2.0, "bottom": 0.4},
			{"z": 7.0, "w": 0.8, "top": 2.7, "bottom": 1.0},
		], Color("3a2a1c"), Color("7e2420"), 1.78))
		Props.cyl(g, 0.14, 9.0, Vector3(0, 6.2, -1.5), Color("4a3420"), Vector3.ZERO, 6)
		Props.cyl(g, 0.2, 7.5, Vector3(0, 8.0, -1.6), Color("c8bfa8"), Vector3(55, 0, 0), 7)
		if i % 3 == 1:
			var f := Props.ball(g, 0.2, Vector3(0, 3.0, 6.5), Color("ffb040"), Vector3.ONE, 5, 3.0)
			f.material_override = Props.mat(Color("ffb040"), 3.0, false, "", false)
			var l := OmniLight3D.new()
			l.position = Vector3(0, 3.2, 6.5)
			l.light_color = Color("ffb060")
			l.light_energy = 1.2
			l.omni_range = 9.0
			g.add_child(l)
	for x: float in [-128.0, -104.0, -80.0]:
		var bp := Vector3(x, 3.0, 171.0)
		batteries.append(bp)
		Props.box(self, Vector3(4.0, 1.2, 2.0), bp + Vector3(0, -0.9, 0.6), Color("4a4236"))
		Props.cyl(self, 0.35, 2.6, bp + Vector3(0, 0, -0.4), Color("3a3a3e"), Vector3(80, 0, 0), 8)


func _build_lantern() -> void:
	lantern = Node3D.new()
	lantern.position = GALATA_LIGHT
	add_child(lantern)
	var m := Props.ball(lantern, 0.8, Vector3.ZERO, Color("ffd070"), Vector3.ONE, 6, 4.0)
	m.material_override = Props.mat(Color("ffd070"), 5.0, false, "", false)
	_lantern_light = OmniLight3D.new()
	_lantern_light.light_color = Color("ffc060")
	_lantern_light.light_energy = 6.0
	_lantern_light.omni_range = 40.0
	lantern.add_child(_lantern_light)
	lantern.visible = false


func _build_bureau() -> void:
	bureau = Bureau.new()
	add_child(bureau)
	nihat = Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
		"hair": Color("3a2a1e"), "skin": Color("ecb892")})
	nihat.position = Vector3(1.1, 0, -0.9)
	nihat.rotation.y = deg_to_rad(200)
	bureau.add_child(nihat)
	nihat.look_target = player
	# Duvardaki ekran: Vikipedi sayfası, her paragrafın yanında kırmızı [kaynak belirtilmeli]
	var board := Node3D.new()
	board.position = Vector3(-2.9, 1.65, 1.0)
	board.rotation.y = PI / 2.0
	bureau.add_child(board)
	Props.box(board, Vector3(1.7, 1.2, 0.06), Vector3.ZERO, Color("f4f4f0"))
	Props.label(board, tr("PROP17_WIKI_TITLE"), Vector3(-0.35, 0.44, 0.035), 28, Color("202122"), Vector3.ZERO)
	for i in 5:
		var y := 0.22 - i * 0.18
		Props.box(board, Vector3(0.9, 0.045, 0.005), Vector3(-0.3, y, 0.035), Color("a2a9b1"))
		Props.label(board, tr("PROP17_WIKI_CN"), Vector3(0.46, y, 0.036), 13, Color("cc2a2a"), Vector3.ZERO)
	player.global_position = Bureau.SPAWN_POS + Vector3(0, 0.05, 0)
	player.face(nihat.global_position + Vector3(0, 1.5, 0))


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_ACT4_TITLE"), 38, Color("f2e6c9")], [tr("UI_ACT4_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	await _prologue()
	await hud.fade_to(1.0, 0.6)
	Audio.sfx("machine_jump", -4.0)
	bureau.queue_free()
	bureau = null
	nihat = null
	await get_tree().process_frame
	_build_horn()
	await hud.card([[tr("UI_CH17_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH17_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.pinned = true
	player.show_remote(false)
	_seat_player()
	player.face(boat.global_position + (-boat.global_transform.basis.z) * 20.0 + Vector3(0, 1.0, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	phase = "brief"
	await hud.say("SPK_TREVISANO", "D17_TR_01")
	await hud.say("SPK_TOLGA", "D17_T_01")
	await hud.say("SPK_TREVISANO", "D17_TR_02")
	await hud.say("SPK_TOLGA", "D17_T_02")
	await hud.say("SPK_COCO", "D17_CO_01")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ17_ROW"))
	hud.bark("SPK_TOLGA", "D17_HINT_ROW", 5.0)
	meter.enabled = true
	phase = "row"
	while phase == "row":
		await get_tree().process_frame
		if boat_d >= LIGHT_AT:
			break
	await _light()
	phase = "row2"
	hud.set_objective(tr("UI_OBJ17_ROW"))
	meter.enabled = true
	while boat_d < _total - REST_BACK - 26.0:
		await get_tree().process_frame
	phase = "guns"
	hud.bark("SPK_TREVISANO", "D17_TR_GUNS", 3.0)
	while coco_d < _total - 0.5:
		await get_tree().process_frame
	await _coco_hit()
	await _rescue()
	await _dawn()
	await _end_chapter()


func _prologue() -> void:
	_build_bureau()
	await hud.card([[tr("UI_CH17_PRO"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 0.8)
	_capture_mouse()
	await hud.say("SPK_NIHAT", "D17_N_01")
	await hud.say("SPK_NIHAT", "D17_N_02")
	if GameState.flags.get("tolga_fate", "T1") == "T2":
		await hud.say("SPK_TOLGA", "D17_T_T2")
		await hud.say("SPK_NIHAT", "D17_N_T2")
	await hud.say("SPK_TOLGA", "D17_T_PRO_1")
	await hud.say("SPK_NIHAT", "D17_N_03")
	await hud.say("SPK_NIHAT", "D17_N_04")
	var pick := await hud.choose(["UI_C17_SIGN", "UI_C17_READ", "UI_C17_POLICY"], 0.0, 0)
	match pick:
		1:
			await hud.say("SPK_TOLGA", "D17_T_READ")
			await hud.say("SPK_NIHAT", "D17_N_READ")
		2:
			await hud.say("SPK_TOLGA", "D17_T_POLICY")
			await hud.say("SPK_NIHAT", "D17_N_POLICY")
	Audio.sfx("stamp", -4.0)
	GameState.flags["siege_contract"] = true
	await hud.say("SPK_NIHAT", "D17_N_05")
	await hud.say("SPK_TOLGA", "D17_T_05")
	await hud.say("SPK_NIHAT", "D17_N_06")
	await hud.say("SPK_NIHAT", "D17_N_07")
	await hud.say("SPK_TOLGA", "D17_T_07")
	await hud.say("SPK_NIHAT", "D17_N_08")


## Galata'da ışık: kürekler durur, Tolga tespit eder (ya da kaçırır).
func _light() -> void:
	phase = "light"
	meter.enabled = false
	lantern.visible = true
	Audio.sfx("radio_beep", -10.0)
	await hud.say("SPK_TREVISANO", "D17_TR_LIGHT")
	hud.bark("SPK_NIHAT", "D17_N_RADIO_LIGHT", 5.0)
	hud.set_objective(tr("UI_OBJ17_LIGHT"), GALATA_LIGHT)
	cam = TespitCam.new(player, hud, lantern, "siege17")
	hud.add_child(cam)
	cam.max_dist = 260.0
	cam.cone_deg = 8.0
	cam.taken.connect(func(path: String): _photo = path)
	if not (GameState.autotest and GameState.autotest_variant == "nophoto"):
		cam.start()
	var t := 0.0
	var limit := 4.0 if GameState.autotest else 22.0
	while not cam.done and t < limit:
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	hud.set_objective("")
	if cam.done:
		await hud.say("SPK_TOLGA", "D17_T_SHOT")
		await hud.say("SPK_NIHAT", "D17_N_SHOT")
	else:
		await hud.say("SPK_NIHAT", "D17_N_MISSED")
	lantern.visible = false
	await hud.say("SPK_COCO", "D17_CO_GO")


func _coco_hit() -> void:
	phase = "hit"
	meter.enabled = false
	var hitp := coco_boat.global_position
	Audio.sfx("cannon", 2.0)
	Vfx.explosion(self, hitp + Vector3(0, 0.6, 0), 1.2)
	Audio.sfx("explosion_big", -2.0)
	player.shake(0.6)
	var fire := OmniLight3D.new()
	fire.light_color = Color("ff8a3a")
	fire.light_energy = 5.0
	fire.omni_range = 18.0
	fire.position = Vector3(0, 2.0, 0)
	coco_boat.add_child(fire)
	for i in 5:
		var fl := Props.cyl(coco_boat, 0.3 + i * 0.05, 1.4, Vector3(randf_range(-0.6, 0.6), DECK_Y + 0.7, -2.0 + i), Color("ffb040"), Vector3.ZERO, 6, 0.05, 3.0)
		fl.material_override = Props.mat(Color("ff9a30"), 3.5, false, "", false)
	for r in coco_rowers:
		r.visible = false
	coco.visible = false
	hud.say("SPK_TREVISANO", "D17_TR_HIT")
	var tw := create_tween().set_parallel()
	tw.tween_property(coco_boat, "rotation:x", deg_to_rad(-24), 5.0)
	tw.tween_property(coco_boat, "rotation:z", deg_to_rad(18), 5.0)
	tw.tween_property(coco_boat, "global_position:y", -3.2, 7.0).set_ease(Tween.EASE_IN)
	tw.tween_property(fire, "light_energy", 0.0, 7.0)
	# Kayık kalan yolu gider ve durur
	while boat_d < _total - REST_BACK:
		boat_d = move_toward(boat_d, _total - REST_BACK, 3.0 * get_process_delta_time())
		await get_tree().process_frame
	await get_tree().create_timer(1.2).timeout
	await hud.say("SPK_TOLGA", "D17_T_HIT")


func _rescue() -> void:
	phase = "rescue"
	_spawn_swimmers()
	player.pinned = false
	player.eye_height = Player.EYE
	player.global_position = boat.to_global(Vector3(-0.3, DECK_Y + 0.05, 1.6))
	await hud.say("SPK_TREVISANO", "D17_TR_RESCUE")
	hud.set_objective(tr("UI_OBJ17_RESCUE") % [_saved, swimmers.size()])
	hud.bark("SPK_TOLGA", "D17_HINT_RESCUE", 4.0)
	_rescue_t = RESCUE_TIME
	if GameState.autotest:
		_auto_rescue()
	while _rescue_t > 0.0 and _saved < swimmers.size():
		await get_tree().process_frame
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	hud.set_objective("")
	player.frozen = true


func _spawn_swimmers() -> void:
	var spots := [Vector3(-2.7, 0, -2.6), Vector3(2.7, 0, 1.2), Vector3(-2.6, 0, 3.9)]
	for i in spots.size():
		var s := Person.new({"coat": [Color("5a6a7a"), Color("7a4a3a"), Color("6a5a40")][i], "pants": Color("3a3028"), "mustache": i != 1})
		s.set_meta("no_talk", true)
		add_child(s)
		s.global_position = boat.to_global(spots[i]) + Vector3(0, -1.25, 0)
		s.look_at(boat.global_position * Vector3(1, 0, 1) + Vector3(0, s.global_position.y, 0), Vector3.UP)
		s.rotate_y(PI)
		s.set_activity("swim")
		var side := signf(spots[i].x)
		var body := Props.interactable(boat, "swim_%d" % i, Vector3(1.9, 2.8, 1.8), spots[i] + Vector3(-side * 0.4, 1.3, 0))
		swimmers.append({"node": s, "body": body, "saved": false, "base": s.global_position})


func _pull(i: int) -> void:
	var sw: Dictionary = swimmers[i]
	if sw["saved"] or phase != "rescue":
		return
	sw["saved"] = true
	(sw["body"] as Node).queue_free()
	_saved += 1
	var s: Person = sw["node"]
	player.hand_gesture("reach")
	Audio.sfx("splash", -4.0)
	var seat := boat.to_global(Vector3(0.0, DECK_Y, -4.4 + _saved * 1.3))
	var tw := create_tween()
	tw.tween_property(s, "global_position", s.global_position.lerp(seat, 0.5) + Vector3(0, 1.4, 0), 0.5).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "global_position", seat, 0.4).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		s.set_activity("sit")
		s.emote("nod"))
	hud.set_objective(tr("UI_OBJ17_RESCUE") % [_saved, swimmers.size()])
	hud.bark("SPK_TOLGA", "D17_T_PULL_%d" % _saved, 2.5)


func _auto_rescue() -> void:
	await get_tree().create_timer(0.5).timeout
	match GameState.autotest_variant:
		"two":
			_pull(0)
			_pull(1)
			_rescue_t = 0.01
		"fall":
			player.global_position = boat.to_global(Vector3(3.5, 1.0, 0.0))
			await get_tree().create_timer(2.0).timeout
			_pull(0)
			_pull(1)
			_pull(2)
		_:
			for i in swimmers.size():
				_pull(i)


func _dawn() -> void:
	phase = "dawn"
	await hud.say("SPK_TREVISANO", "D17_TR_BACK")
	await hud.fade_to(1.0, 1.0)
	await hud.card([[tr("UI_CH17_DAWN"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	# Rıhtım, şafak: kayık surun dibinde
	boat_d = 0.0
	_place_boat(boat, 0.0)
	player.global_position = Vector3(-8.0, SeaWalls.QUAY_Y + 0.05, -1.2)
	player.face(boat.global_position + Vector3(0, 1.2, 0))
	for sw in swimmers:
		(sw["node"] as Node3D).visible = sw["saved"]
	await hud.fade_to(0.0, 1.0)
	if _saved > 0:
		await hud.say("SPK_TREVISANO", "D17_TR_THANKS")
	await hud.say("SPK_TREVISANO", "D17_TR_COCO")
	await hud.say("SPK_TOLGA", "D17_T_END")
	await hud.say("SPK_NIHAT", "D17_N_END")
	_outcome = "17.3" if _fell else ("17.1" if _saved >= 3 else "17.2")
	GameState.flags["siege_saved"] = _saved
	Siege.record(17, _photo, "SIEGE_NOTE_17_%s" % _outcome.split(".")[1])


# ================================================================ kare kare

func _process(delta: float) -> void:
	_t += delta
	if boat == null:
		return
	match phase:
		"row", "row2", "guns":
			var target := (2.0 + 4.2 * meter.speed_factor()) if meter.enabled else 0.6
			_speed = move_toward(_speed, target, delta * 1.5)
			boat_d = minf(boat_d + _speed * delta, _total - REST_BACK)
			# Coco önden gider; toplar açılınca aceleyle öne atılır (Barbaro: ötekileri beklemedi)
			if phase == "guns":
				coco_d = minf(coco_d + 5.5 * delta, _total)
			else:
				coco_d = minf(maxf(coco_d, boat_d + 14.0), _total)
			if Input.is_action_just_pressed("jump") and not player.frozen:
				meter.press()
		"light":
			_speed = move_toward(_speed, 0.4, delta * 2.0)
			boat_d += _speed * delta
			coco_d = maxf(coco_d, boat_d + 14.0)
	if phase in ["intro", "brief", "row", "row2", "light", "guns", "hit"]:
		_place_boat(boat, boat_d)
		if phase != "hit":
			_place_boat(coco_boat, coco_d, 1.0)
		_seat_player()
	_place_ships()
	_animate_oars()
	if lantern and lantern.visible:
		_lantern_light.light_energy = 6.0 if fmod(_t, 1.2) < 0.7 else 1.0
	if phase in ["guns", "hit", "rescue"]:
		_guns(delta)
	if phase == "rescue":
		_rescue_tick(delta)


func _seat_player() -> void:
	if not player.pinned:
		return
	player.eye_height = 1.15
	player.global_position = boat.to_global(Vector3(-0.55, DECK_Y + 0.05, 1.6))


func _animate_oars() -> void:
	var ph := meter.phase if meter.enabled else fmod(_t * 0.3, 1.0)
	var moving := meter.enabled
	for r in rowers + coco_rowers:
		if r.rig:
			r.rig.row_phase = ph if moving or r in coco_rowers else -1.0
	var all := oars.duplicate()
	if my_oar:
		all.append(my_oar)
	for o: Node3D in all:
		var side: float = o.get_meta("side")
		var sweep := sin(ph * TAU) * 0.45 if moving else 0.0
		var lift := (0.28 if ph >= 0.5 or not moving else 0.12)
		o.rotation = Vector3(0, side * sweep, side * lift)


func _guns(delta: float) -> void:
	_gun_t -= delta
	if _gun_t > 0.0:
		return
	_gun_t = randf_range(1.6, 3.2)
	var bp: Vector3 = batteries[randi() % batteries.size()]
	var flash := OmniLight3D.new()
	flash.position = bp + Vector3(0, 0.5, -1.5)
	flash.light_color = Color("ffb060")
	flash.light_energy = 12.0
	flash.omni_range = 30.0
	add_child(flash)
	create_tween().tween_property(flash, "light_energy", 0.0, 0.4).finished.connect(flash.queue_free)
	Vfx.explosion(self, bp + Vector3(0, 0, -1.8), 0.5)
	Audio.sfx("cannon", -8.0, randf_range(0.9, 1.1))
	# Gülle suya düşer: su sütunu
	var near := boat.global_position + Vector3(randf_range(-14, 14), 0, randf_range(6, 22))
	get_tree().create_timer(0.7).timeout.connect(func(): _splash(near))


func _splash(p: Vector3) -> void:
	var col := Props.cyl(self, 0.6, 1.0, p, Color("dfe8f0"), Vector3.ZERO, 8, 0.2)
	col.scale = Vector3(1, 0.1, 1)
	var tw := create_tween()
	tw.tween_property(col, "scale", Vector3(1.4, 5.0, 1.4), 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_property(col, "scale", Vector3(2.0, 0.05, 2.0), 0.7).set_ease(Tween.EASE_IN)
	tw.tween_callback(col.queue_free)
	Audio.sfx("splash", -6.0, 0.8)
	if p.distance_to(player.global_position) < 16.0:
		player.shake(0.25)


func _rescue_tick(delta: float) -> void:
	_rescue_t -= delta
	hud.set_chase(tr("UI_CH17_TIME") % maxi(0, int(ceil(_rescue_t))), 1.0 - _rescue_t / RESCUE_TIME)
	for sw in swimmers:
		if not sw["saved"]:
			var s: Person = sw["node"]
			s.global_position = (sw["base"] as Vector3) + Vector3(sin(_t * 0.7 + s.get_instance_id()) * 0.3, sin(_t * 2.2) * 0.08, 0)
	# Güverteden suya düşen Tolga: tayfa çeker, zaman kaybı
	if player.global_position.y < -0.6 and not player.frozen:
		_fell = true
		_rescue_t -= 6.0
		Audio.sfx("splash", 0.0)
		player.frozen = true
		hud.bark("SPK_TREVISANO", "D17_TR_FELL", 3.0)
		get_tree().create_timer(1.2).timeout.connect(func():
			player.global_position = boat.to_global(Vector3(0.0, DECK_Y + 0.1, 0.0))
			player.velocity = Vector3.ZERO
			player.frozen = false
			hud.bark("SPK_TOLGA", "D17_T_FELL", 3.0))


func _on_stroke(good: bool) -> void:
	if not good and meter.noise > 0.85 and not hud.is_talking():
		hud.bark("SPK_TREVISANO", "D17_TR_NOISE", 2.5)
		meter.noise = 0.5


func _on_focus(id: String) -> void:
	if id.begins_with("swim_"):
		hud.set_prompt(tr("UI_PROMPT17_PULL"))
	elif phase == "rescue":
		hud.set_prompt("")


func _on_interact(id: String) -> void:
	if id.begins_with("swim_"):
		_pull(int(id.trim_prefix("swim_")))


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	meter.enabled = false
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
	c.title_text = tr("UI_FLOW17_TITLE")
	c.nodes = [
		{"id": "sign", "key": "FLOW17_SIGN", "pos": Vector2(0.5, 0.14)},
		{"id": "light", "key": "FLOW17_LIGHT", "pos": Vector2(0.3, 0.32)},
		{"id": "nolight", "key": "FLOW17_NOLIGHT", "pos": Vector2(0.7, 0.32)},
		{"id": "17.1", "key": "FLOW_17_1", "pos": Vector2(0.2, 0.58), "outcome": true},
		{"id": "17.2", "key": "FLOW_17_2", "pos": Vector2(0.5, 0.58), "outcome": true},
		{"id": "17.3", "key": "FLOW_17_3", "pos": Vector2(0.8, 0.58), "outcome": true},
	]
	c.edges = [["sign", "light"], ["sign", "nolight"], ["light", "17.1"], ["light", "17.2"], ["light", "17.3"],
		["nolight", "17.1"], ["nolight", "17.2"], ["nolight", "17.3"]]
	c.taken["sign"] = true
	c.taken["light" if _photo != "" or (GameState.autotest and cam and cam.done) else "nolight"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH17_STATS") % [_saved, swimmers.size(), Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "17.1", "two": "17.2", "fall": "17.3", "nophoto": "17.1"}.get(v, "17.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("17", {})
	var shot_ok: bool = (cam != null and cam.done) == (v != "nophoto")
	var ok: bool = _outcome == expected and not page.is_empty() and shot_ok and GameState.flags.get("siege_contract", false)
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s, kare=%s)" % [expected, _outcome, not page.is_empty(), shot_ok])
	print("AUTOTEST %s chapter=17 variant=%s outcome=%s saved=%d fell=%s shot=%s" % ["PASS" if ok else "FAIL", v, _outcome,
		_saved, _fell, cam != null and cam.done])
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
	_build_bureau()
	await get_tree().create_timer(0.5).timeout
	player.face(Vector3(-2.9, 1.6, 1.0))
	hud.bark("SPK_NIHAT", "D17_N_02", 30.0)
	await _shot("c17_01_bureau.png")
	hud.bark("SPK_NIHAT", "", 0.01)
	bureau.queue_free()
	bureau = null
	await get_tree().process_frame
	_build_horn()
	player.pinned = true
	player.show_remote(false)
	boat_d = 30.0
	coco_d = 44.0
	phase = "row"
	meter.enabled = true
	meter.streak = 4
	await get_tree().create_timer(0.6).timeout
	player.face(coco_boat.global_position + Vector3(0, 1.0, 0))
	hud.set_objective(tr("UI_OBJ17_ROW"))
	await _shot("c17_02_row.png")
	phase = "light"
	meter.enabled = false
	lantern.visible = true
	cam = TespitCam.new(player, hud, lantern, "siege17")
	hud.add_child(cam)
	cam.max_dist = 260.0
	cam.active = true
	player.face(GALATA_LIGHT)
	hud.set_objective(tr("UI_OBJ17_LIGHT"), GALATA_LIGHT)
	await _shot("c17_03_light.png")
	cam.stop()
	lantern.visible = false
	hud.set_objective("")
	hud.set_prompt("")
	phase = "guns"
	boat_d = _total - REST_BACK
	coco_d = _total
	await get_tree().create_timer(0.3).timeout
	phase = "hit"
	_coco_hit_fx()
	await get_tree().create_timer(1.2).timeout
	_spawn_swimmers()
	player.pinned = false
	player.global_position = boat.to_global(Vector3(-0.9, DECK_Y + 0.05, -2.4))
	player.face((swimmers[0]["node"] as Node3D).global_position + Vector3(0, 1.3, 0))
	phase = "rescue"
	_rescue_t = 24.0
	hud.set_objective(tr("UI_OBJ17_RESCUE") % [1, 3])
	hud.set_prompt(tr("UI_PROMPT17_PULL"))
	await _shot("c17_04_rescue.png")
	var top := Camera3D.new()
	add_child(top)
	top.global_position = boat.to_global(Vector3(0, 9.0, 7.0))
	top.look_at(boat.global_position, Vector3.UP)
	top.make_current()
	await _shot("c17_06_top.png")
	# Kapak: yanan fusta, önde kadırgamızın kürekleri, arkada Galata (yazısız)
	hud.visible = false
	top.global_position = boat.to_global(Vector3(-2.2, 2.6, 5.5))
	top.look_at(coco_boat.global_position + Vector3(0, 1.5, 0), Vector3.UP)
	top.fov = 55.0
	await _shot("c17_cover.png")
	hud.visible = true
	player.camera.make_current()
	hud.set_prompt("")
	hud.set_chase("", 0.0)
	hud.set_objective("")
	Siege.record(17, "", "SIEGE_NOTE_17_1")
	var page := func(): await Siege.show_page(hud, 17)
	page.call()
	await get_tree().create_timer(2.2).timeout
	await _shot("c17_05_page.png")
	get_tree().quit()


## Yalnız görüntü: vurulan fusta (ekran görüntüsü için, sesiz ve beklemesiz).
func _coco_hit_fx() -> void:
	Vfx.explosion(self, coco_boat.global_position + Vector3(0, 0.6, 0), 1.2)
	var fire := OmniLight3D.new()
	fire.light_color = Color("ff8a3a")
	fire.light_energy = 5.0
	fire.omni_range = 18.0
	fire.position = Vector3(0, 2.0, 0)
	coco_boat.add_child(fire)
	for i in 5:
		var fl := Props.cyl(coco_boat, 0.3 + i * 0.05, 1.4, Vector3(randf_range(-0.6, 0.6), DECK_Y + 0.7, -2.0 + i), Color("ffb040"), Vector3.ZERO, 6, 0.05, 3.0)
		fl.material_override = Props.mat(Color("ff9a30"), 3.5, false, "", false)
	coco_boat.rotation.x = deg_to_rad(-14)
	coco_boat.global_position.y = -0.8
