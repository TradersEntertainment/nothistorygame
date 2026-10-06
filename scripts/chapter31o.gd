extends Node3D
## Bölüm 31 (yalnız Osmanlı tarafı) — Cuma (Tolga · 30 Mayıs – 1 Haziran 1453). docs/OTTOMAN_NEW_B.md §4.
##
## Fethin ertesi üç gün, üç yer (biri kurulurken öbürü silinir):
##   1. 30 Mayıs, cadde (FallenCity, gündüz): yanık evde mahsur kalan azap ve çocuk. Harap saray cephesine tırman,
##      kömürleşmiş kirişte yürü (denge), kirişi kaldır (Space ritmi, köz yağmuru), çocuğu iple indir (Kadri tutar).
##   2. 31 Mayıs, Eyüp (Horn kıyısı, rivayet): Akşemseddin'in üç işareti (yarık çınar, taştan akan su, el izli taş),
##      kazı (E basılı, üç katman, kökler Space ile). Güneş batar (gerçek sayaç: ışık turuncuya döner).
##   3. 1 Haziran, Ayasofya: geçici şerefe iskelesi (iki merdiven + duvara serbest tırmanma), üç bağ (sar + düğüm),
##      esinti (denge, C çömel).
##   4. Nef: hasır rulolarını ser, kıble ipine paralel çevir (A/D), sabitle; saflar oturur. Tespit: kubbenin altında
##      çapraz saflar. Kamette telefon cebe; Tolga kapının yanına oturur.
##   31O.1 dört fazın en az üçü sayaç bitmeden · 31O.2 başkaları yetişti
##   --autotest[=late]   (varsayılan: 31O.1)

const HOUSE_TIME := 180.0
const SUN_TIME := 180.0
const SCAFF_TIME := 210.0
const MAT_TIME := 150.0
const MATS := 8
const QIBLA_DEG := 30.0

# Yanık ev (FallenCity koordinatları; saray cephesinin güneyinde, sağ sıra)
const HX0 := 4.5
const HX1 := 11.5
const HZ0 := -80.6
const HZ1 := -72.2
const ROOM_Y := 3.4
const LEDGE_Y := 4.38
const BEAM_A := Vector3(3.2, 4.42, -69.6)
const BEAM_B := Vector3(5.6, 3.48, -74.6)
const WINDOW := Vector3(4.5, ROOM_Y, -77.6)

var player: Player
var hud: Hud
var meter: RowMeter
var balance: BalanceMeter
var cam: TespitCam
var phase := "intro"
var _outcome := ""
var _photo := ""
var _strokes: Array = []
var _stage: Node3D
var _lore: Lore
var _env: WorldEnvironment
var _sun: DirectionalLight3D

var kadri: Person
var azap: Person
var child: Person
var aksem: Person
var dervish: Person
var carpenter: Person

# skor
var house_left := 0.0
var house_ok := false
var beam_falls := 0
var signs_found := 0
var wrong_signs := 0
var sun_ok := false
var lashes := 0
var lash_misses := 0
var scaff_ok := false
var mats_done := 0
var mats_ok := false
var mat_err_sum := 0.0


func _ready() -> void:
	GameState.snapshot(31)
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
	balance.visible = false
	hud.add_child(balance)
	balance.place_bottom()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH31O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH31O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	await _house_phase()
	await _eyup_phase()
	await _scaffold_phase()
	await _mats_phase()
	await _end_chapter()


func _late() -> bool:
	return GameState.autotest_variant == "late"


## Bir aşamanın kökünü siler (sahnenin kendisi değil: oyuncu, hud ve sayaçlar kalır)
func _clear_stage() -> void:
	# Sahne (zemini ile) kaldırılırken oyuncu yerinde tutulur: bir sonraki evre onu yeni zemine koyar. Eskiden kararmış
	# ekranda zeminsiz kalıp boşlukta tutuluyordu (WARN_VOID_TELEPORT)
	if not player.pinned:
		player.pinned = true
		get_tree().create_timer(1.0).timeout.connect(func():
			if is_instance_valid(player):
				player.pinned = false)
	if is_instance_valid(_lore):
		_lore.queue_free()
	if is_instance_valid(_stage):
		_stage.queue_free()
	_stage = null
	_env = null
	_sun = null
	await get_tree().process_frame
	await get_tree().process_frame


# ================================================================ 1. yanık ev (30 Mayıs)

var walls: LandWalls
var city: FallenCity
var _beam: Node3D
var _fallen_beam: Node3D
var _embers: Array = []


func _house_phase() -> void:
	phase = "house"
	_stage = Node3D.new()
	add_child(_stage)
	walls = LandWalls.new()
	walls.near_works = false
	_stage.add_child(walls)
	walls.make_day()
	walls.open_inner_gate()
	city = FallenCity.new()
	city.field = walls.field
	city.quiet = true
	city.reserve_right = Vector2(HZ1 + 0.4, HZ0 - 0.2)
	_stage.add_child(city)
	FallenCity.mood(walls.env.environment, walls.moon)
	# Fethin ertesi sabah: duman inceldi, ışık daha açık
	walls.env.environment.fog_density = 0.006
	walls.moon.light_energy = 1.15
	_build_burnt_house()
	_build_street_people()
	_lore = Lore.scatter(self, "31o", [Vector3(-3.2, 0.3, -30.0), Vector3(3.0, 0.3, -52.0), Vector3(-2.6, 0.3, -82.0)])
	player.global_position = Vector3(0.8, 0.05, -10.0)
	player.face(Vector3(0, 1.6, -40.0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	Audio.ambience("amb_city_day")
	await hud.say("SPK_NIHAT", "D31O_N_01")
	await hud.say("SPK_TOLGA", "D31O_T_01")
	# Caddeden aşağı yürü: Kadri'nin kazanı (bark), tellal (yürüyerek gelir, bark)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ31O_WALK"), PALACE_FRONT + Vector3(0, 1.6, 0))
	var t := 0.0
	var said_k := false
	var said_h := false
	while player.global_position.z > -56.0 and t < 60.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		if not said_k and player.global_position.z < -40.0:
			said_k = true
			hud.bark("SPK_KADRI", "D31O_K_LADLE", 3.5)
		if not said_h and player.global_position.z < -46.0:
			said_h = true
			hud.bark("SPK_HERALD", "D31O_HR_01", 5.0)
		if GameState.autotest:
			player.global_position = player.global_position.move_toward(Vector3(1.0, 0.05, -57.0), dt * 6.0)
	player.frozen = true
	hud.set_objective("")
	Audio.sfx("crowd_gasp", -6.0, 1.0)
	await hud.say("SPK_AZAP", "D31O_AZ_TRAPPED")
	player.face(Vector3(HX0, 4.0, (HZ0 + HZ1) * 0.5))
	await hud.say("SPK_TOLGA", "D31O_T_02")
	# Köz sayacı: tırman, kirişten geç, kirişi kaldır, çocuğu indir
	house_left = HOUSE_TIME
	player.enable_climb([Rect2(2.0, -72.5, 3.8, 17.0)])
	player.frozen = false
	var ok := await _house_loop()
	player.disable_climb()
	balance.visible = false
	meter.enabled = false
	hud.set_qte("")
	hud.set_objective("")
	player.frozen = true
	player.camera.rotation.z = 0.0
	house_ok = ok
	if not ok:
		Audio.sfx("cave_in", 0.0, 0.8)
		Fx.trauma(0.8)
		Vfx.dust(self, Vector3((HX0 + HX1) * 0.5, ROOM_Y + 1.0, (HZ0 + HZ1) * 0.5), 3.0)
		await hud.fade_to(1.0, 0.5)
		player.global_position = Vector3(2.0, 0.05, -76.0)
		child.global_position = Vector3(2.6, 0.0, -78.4)
		azap.global_position = Vector3(1.6, 0.0, -79.0)
		await hud.fade_to(0.0, 0.5)
		await hud.say("SPK_KADRI", "D31O_K_CAVEIN")
	else:
		await hud.fade_to(1.0, 0.5)
		# Azap topallayarak kirişten geçti (Tolga önden, onu bekleyerek)
		player.global_position = Vector3(2.0, 0.05, -75.0)
		azap.set_activity("sit_ground")
		azap.global_position = Vector3(1.4, 0.0, -73.6)
		azap.rotation = Vector3.ZERO
		await hud.fade_to(0.0, 0.5)
		await hud.say("SPK_KADRI", "D31O_K_CATCH")
	player.face(azap.global_position + Vector3(0, 1.0, 0))
	await hud.say("SPK_AZAP", "D31O_AZ_01")
	await hud.say("SPK_TOLGA", "D31O_T_AZ")
	await hud.say("SPK_AZAP", "D31O_AZ_02")
	if GameState.flags.has("emperor_answer"):
		await hud.say("SPK_AZAP", "D31O_AZ_EMP")
	await hud.say("SPK_KADRI", "D31O_K_01")
	await hud.fade_to(1.0, 0.8)
	await _clear_stage()


const PALACE_FRONT := Vector3(3.0, 0.0, -66.0)


## Yanık ev: zemin kat dolu (kapısı çökük), üst katta yarı çökük oda (çatı yok, közler); öne bakan duvarda
## sarayın yanında yanık bir delik (kiriş oradan girer) ve indirme penceresi. Sarayın revak üstü katı bir çıkıntı.
func _build_burnt_house() -> void:
	var c := Color("8a7a66")
	var soot := Color("2a2420")
	var w := HX1 - HX0
	var d := HZ1 - HZ0
	var zc := (HZ0 + HZ1) * 0.5
	Props.set_pattern(Props.solid(_stage, Vector3(w, ROOM_Y, d), Vector3(HX0 + w * 0.5, ROOM_Y * 0.5, zc), Color.WHITE), c, "plaster")
	Props.box(_stage, Vector3(0.1, 2.3, 1.4), Vector3(HX0 - 0.02, 1.15, zc), soot)                 # çökük kapı
	for k in 6:
		Props.box(_stage, Vector3(randf_range(0.4, 0.9), randf_range(0.3, 0.6), randf_range(0.4, 0.8)), Vector3(HX0 - 0.6 - randf() * 0.8, 0.25, zc + randf_range(-1.0, 1.0)),
			Color("6a5a48").darkened(randf() * 0.3), Vector3(randf_range(-20, 20), randf() * 90.0, randf_range(-20, 20)))
	var up := 3.0
	var top := ROOM_Y + up
	# Arka ve yan duvarlar (üst kat)
	Props.set_pattern(Props.solid(_stage, Vector3(0.25, up, d), Vector3(HX1 - 0.12, ROOM_Y + up * 0.5, zc), Color.WHITE), c.darkened(0.2), "plaster")
	for z: float in [HZ0 + 0.12, HZ1 - 0.12]:
		Props.set_pattern(Props.solid(_stage, Vector3(w, up, 0.25), Vector3(HX0 + w * 0.5, ROOM_Y + up * 0.5, z), Color.WHITE), c.darkened(0.2), "plaster")
	# Ön duvar: delik (z HZ1-2.2..HZ1-0.25, tam boy), pencere (z WINDOW.z ±0.55, y +0.5..+1.7)
	var fx := HX0 + 0.12
	for seg: Array in [[HZ0 + 0.25, WINDOW.z - 0.55, ROOM_Y, top], [WINDOW.z + 0.55, HZ1 - 2.2, ROOM_Y, top],
			[WINDOW.z - 0.55, WINDOW.z + 0.55, ROOM_Y, ROOM_Y + 0.5], [WINDOW.z - 0.55, WINDOW.z + 0.55, ROOM_Y + 1.7, top]]:
		var zz: float = (seg[0] + seg[1]) * 0.5
		var hh: float = seg[3] - seg[2]
		Props.set_pattern(Props.solid(_stage, Vector3(0.25, hh, seg[1] - seg[0]), Vector3(fx, seg[2] + hh * 0.5, zz), Color.WHITE), c.darkened(0.25), "plaster")
	# Kömür lekeleri ve yanık üst kenar
	Props.box(_stage, Vector3(w + 0.3, 0.4, d + 0.3), Vector3(HX0 + w * 0.5, top, zc), soot)
	for k in 4:
		Props.box(_stage, Vector3(w, 0.22, 0.22), Vector3(HX0 + w * 0.5, top - 0.3, HZ0 + 1.5 + k * 2.0), Color("181412"), Vector3(randf_range(-10, 10), 0, randf_range(-14, 14)))
	_embers.append(Vfx.smolder(_stage, Vector3(HX0 + w * 0.6, ROOM_Y + 0.4, zc - 1.0), 1.4))
	_embers.append(Vfx.smolder(_stage, Vector3(HX1 - 1.2, ROOM_Y + 0.2, HZ0 + 1.6), 0.9))
	Scenery.smoke_column(_stage, Vector3(HX0 + w * 0.5, top, zc), false)
	# Sarayın revak üstü: katı çıkıntı (cephe tırmanışının ilk durağı)
	var ledge := Props.solid(_stage, Vector3(2.2, 0.35, 12.4), Vector3(FallenCity.PALACE.x - 1.1, LEDGE_Y - 0.175, FallenCity.PALACE.z - 0.1), Color.WHITE)
	ledge.get_child(0).visible = false
	# Kömürleşmiş kiriş: çıkıntının ucundan evin deliğine (iki kiriş yan yana, biri kırık)
	_beam = Node3D.new()
	_stage.add_child(_beam)
	_beam.position = BEAM_A
	var len := BEAM_A.distance_to(BEAM_B)
	_beam.look_at_from_position(BEAM_A, BEAM_B, Vector3.UP)
	Props.box(_beam, Vector3(0.26, 0.24, len), Vector3(0, -0.12, -len * 0.5), Color("221a16"))
	Props.box(_beam, Vector3(0.2, 0.2, len * 0.6), Vector3(0.45, -0.3, -len * 0.3), Color("1a1412"), Vector3(0, 0, 18))
	# İçeride: devrik kirişin altında azap, köşede çocuk
	azap = Person.new({"coat": Color("8a3a2e"), "pants": Color("e8e0d0"), "hat": "azap", "mustache": true, "skin": Color("c89070")})
	azap.set_meta("spk", "SPK_AZAP")
	azap.set_meta("no_talk", true)
	_stage.add_child(azap)
	azap.position = Vector3(8.0, ROOM_Y + 0.12, -77.2)
	azap.rotation = Vector3(-PI * 0.5, PI * 0.5, 0)
	child = Person.new({"coat": Color("6a5a7a"), "pants": Color("3a3028"), "child": true, "hair": Color("3a2a1e")})
	child.set_meta("no_talk", true)
	_stage.add_child(child)
	child.position = Vector3(6.4, ROOM_Y, -79.4)
	child.rotation.y = PI * 0.25
	child.set_activity("sit_ground")
	_fallen_beam = Node3D.new()
	_stage.add_child(_fallen_beam)
	_fallen_beam.position = Vector3(7.4, ROOM_Y + 0.2, -76.0)
	Props.box(_fallen_beam, Vector3(0.3, 0.3, 4.6), Vector3(0, 0, -1.2), Color("221a16"), Vector3(0, 30, 0))
	Props.interactable(azap, "azap", Vector3(1.6, 1.4, 1.6), Vector3(0, 0, 0))
	Props.interactable(child, "child", Vector3(1.2, 1.2, 1.2), Vector3(0, 0.6, 0))


## Caddede: Kadri kazanının başında (kepçeyle karıştırır, kuyruk), tellal caddenin öbür ucundan yürür, halk
func _build_street_people() -> void:
	var pot := Vector3(-2.6, 0.0, -44.0)
	Props.cyl(_stage, 0.62, 0.8, pot + Vector3(0, 0.6, 0), Color("3a3634"), Vector3.ZERO, 14, 0.7)
	Props.cyl(_stage, 0.56, 0.04, pot + Vector3(0, 1.0, 0), Color("c89a50"), Vector3.ZERO, 14)
	Vfx.fire(_stage, pot + Vector3(0, 0.1, 0), 0.5)
	Scenery.smoke_column(_stage, pot + Vector3(0, 1.2, 0), false)
	kadri = Person.new({"coat": Color("e8e0d0"), "pants": Color("6a4a3a"), "hat": "cook", "mustache": true, "beard": true, "skin": Color("c89070")})
	kadri.set_meta("spk", "SPK_KADRI")
	_stage.add_child(kadri)
	kadri.position = pot + Vector3(-0.9, 0, 0.2)
	kadri.rotation.y = PI * 0.5
	kadri.set_activity("stir")
	for i in 5:
		var q := Person.new({"coat": [Color("6a5040"), Color("4a5a6a"), Color("7a4a3a"), Color("5a5040"), Color("3a5a3a")][i], "pants": Color("2a2a30"),
			"beard": i % 2 == 0, "skin": Color("d8b090"), "skirt": i == 3, "hat": "bun" if i == 3 else "none"})
		q.set_meta("no_talk", true)
		_stage.add_child(q)
		q.position = pot + Vector3(0.4 + i * 0.75, 0, 1.2 + (i % 2) * 0.3)
		q.rotation.y = PI * 1.25
	var herald := Person.new({"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("c89070")})
	herald.set_meta("spk", "SPK_HERALD")
	herald.set_meta("no_talk", true)
	_stage.add_child(herald)
	herald.position = Vector3(1.0, 0, FallenCity.Z1 + 4.0)
	var tw := herald.create_tween()
	tw.tween_property(herald, "position:z", -50.0, 26.0)


## Yanık ev döngüsü: tırmanış → kiriş → kirişi kaldır → çocuğu indir. Sayaç biterse ya da can sıfırlanırsa false.
func _house_loop() -> bool:
	var stage := "climb"
	var s := 0.0                   # kiriş üstünde ilerleme (0..1)
	var bal := 0.0
	var lift := 0
	var lower := 0.0
	var ember_t := 3.0
	var creaks := 0
	var fell := false
	var bot_t := 0.0
	while house_left > 0.0 and player.hp > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		house_left -= dt
		var p := player.global_position
		match stage:
			"climb":
				hud.set_objective(tr("UI_OBJ31O_HOUSE") % ceili(house_left), BEAM_A + Vector3(0, 1.2, 0))
				if p.y > LEDGE_Y - 0.3 and p.distance_to(BEAM_A) < 1.6:
					stage = "beam"
					s = 0.0
					bal = 0.0
					player.disable_climb()          # tırmanış kirişte ve odada oyuncuyu duvara yapıştırmasın
					player.frozen = true
					hud.bark("SPK_TOLGA", "D31O_T_BEAM_CREAK", 3.0)
				if GameState.autotest:
					bot_t += dt
					if bot_t > 1.0:
						player.global_position = BEAM_A + Vector3(0, 0.05, 0.6)
			"beam":
				hud.set_objective(tr("UI_OBJ31O_BEAM"), BEAM_B + Vector3(0, 1.2, 0))
				balance.visible = true
				balance.label_text = tr("UI_OBJ31O_BEAM")
				var input := Input.get_axis("move_left", "move_right")
				var fwd := Input.get_axis("move_back", "move_forward")
				if GameState.autotest:
					input = -signf(bal) * 0.9 if absf(bal) > 0.12 else 0.0
					if _late() and beam_falls == 0:
						input = 1.0
					fwd = 1.0
				var wob := sin(Time.get_ticks_msec() * 0.0021) * 0.35 + sin(Time.get_ticks_msec() * 0.0057) * 0.2
				bal += (wob * 0.6 + input * 1.5) * dt * (1.0 + s * 0.6)
				s = clampf(s + maxf(fwd, 0.0) * dt / 5.0, 0.0, 1.0)
				# İki çatırdama: kiriş 10 cm çöker, ibre sıçrar, kıvılcım
				if creaks < 2 and s > 0.3 + creaks * 0.35:
					creaks += 1
					bal += randf_range(-0.45, 0.45)
					_beam.position.y -= 0.1
					Audio.sfx("wood_creak", -2.0, 0.7)
					Vfx.dust(self, BEAM_A.lerp(BEAM_B, s), 0.4)
					Fx.trauma(0.25)
				balance.value = bal
				var on := BEAM_A.lerp(BEAM_B, s) + Vector3(0, 0.05 - 0.1 * creaks, 0)
				var side := (BEAM_B - BEAM_A).cross(Vector3.UP).normalized()
				player.global_position = on + side * bal * 0.25
				player.face(BEAM_B + (BEAM_B - BEAM_A).normalized() * 3.0 + Vector3(0, 1.3, 0))
				player.camera.rotation.z = -bal * 0.12
				if absf(bal) >= 1.0:
					# Düşüş: moloza, −25 can; yeniden tırman
					beam_falls += 1
					balance.visible = false
					player.camera.rotation.z = 0.0
					player.global_position = on + side * signf(bal) * 1.4 + Vector3(0, -1.0, 0)
					player.frozen = false
					Audio.sfx("land_thud", -2.0, 0.7)
					await get_tree().create_timer(0.7).timeout
					player.hurt(25.0, Vector3.INF, true)
					player.enable_climb([Rect2(2.0, -72.5, 3.8, 17.0)])
					stage = "climb"
					bot_t = 0.0
				elif s >= 1.0:
					balance.visible = false
					player.camera.rotation.z = 0.0
					player.global_position = BEAM_B + Vector3(1.0, 0.1, -0.6)
					player.frozen = false
					stage = "room"
					hud.bark("SPK_AZAP", "D31O_S_EMBER", 2.5)
			"room":
				hud.set_objective(tr("UI_OBJ31O_LIFT") % lift, azap.global_position + Vector3(0, 1.0, 0))
				if _lift_req or (GameState.autotest and p.distance_to(azap.global_position) < 6.0):
					_lift_req = false
					stage = "lift"
					player.frozen = true
					player.face(_fallen_beam.global_position + Vector3(0, 0.5, 0))
					_strokes.clear()
					meter.enabled = true
					hud.set_qte(tr("UI_PROMPT31O_LIFT"))
					if azap.rig:
						azap.rig.lock += 1
						azap.rig.arm_r.rotation = Vector3(-2.2, 0, 0.2)
				if GameState.autotest:
					player.global_position = azap.global_position + Vector3(-1.2, 0.05, 0.8)
			"lift":
				hud.set_objective(tr("UI_OBJ31O_LIFT") % lift, _fallen_beam.global_position + Vector3(0, 1.0, 0))
				if Input.is_action_just_pressed("jump"):
					meter.press()
				while _strokes.size() > 0:
					var good: bool = _strokes.pop_front() or (GameState.autotest and not _late())   # yavaş karede bot ıskalamasın
					if good and not (_late() and lift == 1 and not fell):
						lift += 1
						var tw := _fallen_beam.create_tween()
						tw.tween_property(_fallen_beam, "rotation:z", deg_to_rad(12.0 * lift), 0.3)
						tw.parallel().tween_property(_fallen_beam, "position:y", ROOM_Y + 0.2 + 0.3 * lift, 0.3)
						Fx.trauma(0.2)
						Audio.sfx("wood_creak", -4.0, 0.9)
					else:
						fell = true
						var tw2 := _fallen_beam.create_tween()
						tw2.tween_property(_fallen_beam, "position:y", ROOM_Y + 0.2, 0.15)
						tw2.parallel().tween_property(_fallen_beam, "rotation:z", 0.0, 0.15)
						lift = 0
						Vfx.dust(self, _fallen_beam.global_position, 0.6)
						Audio.sfx("land_thud", -6.0, 0.9)
				if lift >= 3:
					meter.enabled = false
					hud.set_qte("")
					var tw3 := _fallen_beam.create_tween()
					tw3.tween_property(_fallen_beam, "position", _fallen_beam.position + Vector3(1.6, -0.1, 0), 0.5)
					tw3.parallel().tween_property(_fallen_beam, "rotation:z", deg_to_rad(80.0), 0.5)
					if azap.rig:
						azap.rig.lock = maxi(azap.rig.lock - 1, 0)
					azap.rotation = Vector3.ZERO
					azap.position = Vector3(8.6, ROOM_Y, -76.4)
					azap.set_activity("sit_ground")
					stage = "child"
					player.frozen = false
			"child":
				hud.set_objective(tr("UI_OBJ31O_LOWER"), WINDOW + Vector3(0, 1.0, 0))
				if p.distance_to(WINDOW + Vector3(0.9, 0, 0)) < 1.8 and (_child_taken or GameState.autotest):
					stage = "lower"
					lower = 0.0
					bal = 0.0
					player.frozen = true
					player.face(WINDOW + Vector3(-3.0, -1.0, 0))
					child.set_activity("")
					kadri.position = Vector3(WINDOW.x - 1.4, 0.0, WINDOW.z)
					kadri.set_activity("")
					kadri.rotation.y = PI * 0.5
					kadri.look_target = child
				if GameState.autotest:
					player.global_position = player.global_position.move_toward(WINDOW + Vector3(0.9, 0.05, 0), dt * 4.0)
					_child_taken = true
				if _child_taken and child.get_parent() == _stage:
					child.global_position = player.global_position + (-player.global_transform.basis.z) * 0.5 + Vector3(0, 0.2, 0)
			"lower":
				balance.visible = true
				balance.label_text = tr("UI_OBJ31O_LOWER")
				hud.set_objective(tr("UI_OBJ31O_LOWER"), kadri.global_position + Vector3(0, 1.6, 0))
				var hold := Input.is_action_pressed("interact") or GameState.autotest
				var input2 := Input.get_axis("move_left", "move_right")
				if GameState.autotest:
					input2 = -signf(bal) * 0.9 if absf(bal) > 0.1 else 0.0
				bal += (sin(house_left * 2.3) * 0.5 + input2 * 1.4) * dt
				balance.value = bal
				if absf(bal) >= 1.0:
					bal = 0.0
					house_left -= 4.0
					Audio.sfx("cloth", -4.0, 0.8)
				if hold:
					lower = minf(lower + dt / 6.0, 1.0)
				child.global_position = Vector3(WINDOW.x - 0.5, lerpf(ROOM_Y + 0.6, 0.6, lower), WINDOW.z) + Vector3(0, 0, bal * 0.2)
				if lower >= 1.0:
					balance.visible = false
					child.global_position = kadri.global_position + Vector3(0.4, 0, 0.3)
					child.set_activity("")
					return true
		# Köz yağmuru: odada ve kirişte, önce kızıl gölge
		if stage in ["room", "lift", "child", "beam"]:
			ember_t -= dt
			if ember_t <= 0.0:
				ember_t = randf_range(3.0, 5.0)
				# Oyuncunun çevresine (gölgeyi görüp kaçabilir); otomatik testte bot kaçmaz, közler yanına düşer
				var off := Vector3(randf_range(-0.6, 0.6), 0, randf_range(-0.6, 0.6))
				if GameState.autotest:
					off = Vector3(1.4, 0, 0).rotated(Vector3.UP, randf() * TAU)
				_ember_drop(player.global_position + off)
	return false


var _lift_req := false
var _child_taken := false


func _ember_drop(at: Vector3) -> void:
	var y0 := at.y + 4.0
	var g := Props.cyl(self, 0.45, 0.02, at + Vector3(0, 0.02, 0), Color(0.6, 0.15, 0.05), Vector3.ZERO, 12)
	g.material_override = Props.mat(Color(0.8, 0.2, 0.05), 1.2, false, "", false)
	var e := Props.ball(self, 0.12, Vector3(at.x, y0, at.z), Color("ff7a20"), Vector3.ONE, 6, 3.0)
	var tw := e.create_tween()
	tw.tween_property(e, "position:y", at.y + 0.1, 0.9).set_ease(Tween.EASE_IN)
	await tw.finished
	if is_instance_valid(g):
		g.queue_free()
	Vfx.dust(self, at, 0.3)
	if is_instance_valid(e):
		e.queue_free()
	if Vector2(player.global_position.x - at.x, player.global_position.z - at.z).length() < 0.6 and phase == "house":
		player.hurt(15.0, at + Vector3(0, 3, 0), true)
		hud.bark("SPK_AZAP", "D31O_S_EMBER", 1.5)


# ================================================================ 2. Eyüp (31 Mayıs, rivayet)

const DIG := Vector3(6.0, 0.29, -32.0)
var _signs: Dictionary = {}           # id → [konum, doğru mu, tür]
var _found: Dictionary = {}
var _dig_req := false
var _root_missed := false
var _pit: MeshInstance3D
var _mound: MeshInstance3D


func _eyup_phase() -> void:
	phase = "eyup"
	_stage = Node3D.new()
	add_child(_stage)
	_day_env(_stage, Vector3(-30, 160, 0))
	# Tek harita: surların dışında güney kıyı; karşıda Haliç'in iç kolu ve kuzey kıyı (şehir suru yok)
	Horn.build(_stage, 150.0, Rect2(-40, -60, 80, 60), Vector2.ZERO, 3101, true, true)
	World1453.build(_stage, "eyup", [Rect2(-Horn.WORLD_E, -Horn.WORLD_E, Horn.WORLD_E * 2.0, Horn.WORLD_E + 140.0)], false)
	_build_eyup()
	player.global_position = Vector3(-4.0, 0.35, -8.0)
	player.face(aksem.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D31O_N_03")
	await hud.say("SPK_DERVISH", "D31O_DV_01")
	await hud.say("SPK_AKSEMSEDDIN", "D31O_AK_01")
	await hud.say("SPK_TOLGA", "D31O_T_03")
	player.frozen = false
	var left := SUN_TIME
	var bot_t := 0.0
	var order: Array = []
	for id: String in _signs:
		order.append(id)
	# Güneş: ikindiden gün batımına (gerçek sayaç)
	var sun_tw := create_tween()
	sun_tw.tween_property(_sun, "rotation_degrees", Vector3(-4, 205, 0), SUN_TIME / maxf(Engine.time_scale, 1.0))
	sun_tw.parallel().tween_property(_sun, "light_color", Color("ff9a50"), SUN_TIME / maxf(Engine.time_scale, 1.0))
	while signs_found < 3 and left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		hud.set_objective(tr("UI_OBJ31O_SIGNS") % [signs_found, ceili(left)])
		if GameState.autotest:
			bot_t += dt
			if bot_t > 1.2:
				bot_t = 0.0
				# =late: önce iki yanlış işarete bakar, son işareti güneş batarken bulur (dalgın)
				var want_wrong := _late() and wrong_signs < 2
				if _late() and signs_found >= 2 and left > 2.0:
					continue
				for id: String in order:
					var sg: Array = _signs[id]
					if _found.has(id) or bool(sg[1]) == want_wrong:
						continue
					player.global_position = (sg[0] as Vector3) + Vector3(1.2, 0.1, 1.2)
					_on_interact(id)
					break
	hud.set_objective("")
	# Akşemseddin üç işaretin arasında durur
	player.frozen = true
	aksem.look_target = null
	var tw := aksem.create_tween()
	tw.tween_property(aksem, "global_position", DIG + Vector3(-1.2, 0, 1.0), 2.0)
	await get_tree().create_timer(1.0).timeout
	aksem.look_target = player
	await hud.say("SPK_AKSEMSEDDIN", "D31O_AK_03")
	# Kazı: üç katman, her katmanda bir kök (Space ile kes)
	_pit = Props.cyl(_stage, 0.9, 0.02, DIG + Vector3(0, 0.02, 0), Color("3a2a1c"), Vector3.ZERO, 16)
	_mound = Props.ball(_stage, 0.5, DIG + Vector3(1.6, 0.0, 0.4), Color("6a5034"), Vector3(1.0, 0.3, 1.0), 8)
	Props.interactable(_stage, "dig", Vector3(2.0, 1.4, 2.0), DIG + Vector3(0, 0.6, 0))
	player.frozen = false
	var layer := 0
	var prog := 0.0
	var root_on := false
	var root_done := false
	while layer < 3 and left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		hud.set_objective((tr("UI_OBJ31O_DIG") % [layer + 1]) if not root_on else tr("UI_OBJ31O_ROOTS"), DIG + Vector3(0, 1.0, 0))
		var near := player.global_position.distance_to(DIG) < 2.6
		var hold := (Input.is_action_pressed("interact") and near) or GameState.autotest
		if GameState.autotest and not near:
			player.global_position = DIG + Vector3(1.3, 0.1, 1.3)
		if root_on:
			if Input.is_action_just_pressed("jump"):
				meter.press()
			while _strokes.size() > 0:
				var good: bool = _strokes.pop_front() or GameState.autotest
				if good and not (_late() and layer == 1 and not _root_missed):
					root_on = false
					root_done = true
					meter.enabled = false
					hud.set_qte("")
					Audio.sfx("chop", -4.0, 1.1)
				else:
					_root_missed = true
					prog = maxf(prog - 0.3, 0.0)          # yan toprak çöker; kök yerinde
					Vfx.dust(self, DIG + Vector3(0, 0.3, 0), 0.6)
					Audio.sfx("land_thud", -8.0, 0.8)
			continue
		if hold:
			prog += dt / 7.0
			if fmod(prog * 10.0, 1.0) < dt * 1.5:
				Audio.sfx("pick_tap", -8.0, 0.8)
				Vfx.dust(self, DIG + Vector3(0, 0.3, 0), 0.25)
			_pit.scale = Vector3(1.0, 1.0 + (layer + prog) * 8.0, 1.0)
			_pit.position.y = DIG.y + 0.02 - (layer + prog) * 0.08
			_mound.scale = Vector3.ONE * (1.0 + (layer + prog) * 0.35)
			if prog > 0.55 and not root_on and not root_done:
				root_on = true
				_strokes.clear()
				meter.enabled = true
				hud.set_qte(tr("UI_OBJ31O_ROOTS"))
				Props.cyl(_stage, 0.04, 1.4, DIG + Vector3(0, 0.1 - layer * 0.2, 0), Color("5a3a20"), Vector3(0, randf() * 180.0, 90), 5)
			if prog >= 1.0:
				prog = 0.0
				layer += 1
				root_done = false
	meter.enabled = false
	hud.set_qte("")
	hud.set_objective("")
	player.frozen = true
	sun_ok = layer >= 3
	# Levha: üstündeki toprak silinir, yazı belirir
	var slab := Props.box(_stage, Vector3(1.0, 0.08, 0.6), DIG + Vector3(0, 0.06, 0), Color("e8e4da"))
	for k in 3:
		Props.box(_stage, Vector3(0.7, 0.01, 0.04), DIG + Vector3(0, 0.11, -0.15 + k * 0.15), Color("3a3028"))
	slab.scale = Vector3(0.6, 1.0, 0.6)
	slab.create_tween().tween_property(slab, "scale", Vector3.ONE, 1.0)
	player.face(DIG + Vector3(0, 0.2, 0))
	if sun_ok:
		await hud.say("SPK_TOLGA", "D31O_T_STONE")
		await hud.say("SPK_AKSEMSEDDIN", "D31O_AK_04")
	else:
		await hud.say("SPK_AKSEMSEDDIN", "D31O_AK_SUNSET")
	dervish.set_activity("sit_ground")
	await hud.say("SPK_NIHAT", "D31O_N_04")
	await hud.fade_to(1.0, 0.8)
	sun_tw.kill()
	await _clear_stage()


## Gün ışığı: Night.environment'ı alır, gündüz renklerine çevirir. sun_rot: güneşin başlangıç açısı.
func _day_env(parent: Node3D, sun_rot: Vector3) -> void:
	_sun = Night.environment(parent, 0.0)
	_sun.rotation_degrees = sun_rot
	_sun.light_color = Color("fff0d8")
	_sun.light_energy = 1.2
	for c in parent.get_children():
		if c is WorldEnvironment:
			_env = c
	if _env:
		var e := _env.environment
		var sm := e.sky.sky_material as ProceduralSkyMaterial
		if sm:
			sm.sky_top_color = Color("4a86c8")
			sm.sky_horizon_color = Color("e8d0b0")
			sm.ground_horizon_color = Color("a89878")
		e.ambient_light_color = Color("c8ccd4")
		e.ambient_light_energy = 0.8
		e.tonemap_exposure = 0.92      # gündüz bölümlerinin pozlaması (gece ortamınınki 1.1)
		e.fog_density = 0.002


## Eyüp yamacı: çınarlar (biri yıldırımla yarık), pınarlar (biri taştan su akıtır), eski taşlar (biri el izli);
## mezar taşları, devrik sütun; Akşemseddin (bastonlu), iki derviş.
func _build_eyup() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3105
	# Doğru işaretler kazı yerinin çevresinde; yanlışlar yamaca dağılır
	var specs := [
		["tree_1", DIG + Vector3(-5.0, 0, -4.0), true, "tree"], ["tree_2", Vector3(-22.0, 0.29, -18.0), false, "tree"], ["tree_3", Vector3(24.0, 0.29, -44.0), false, "tree"],
		["spring_1", DIG + Vector3(5.0, 0, -3.0), true, "spring"], ["spring_2", Vector3(-14.0, 0.29, -46.0), false, "spring"], ["spring_3", Vector3(28.0, 0.29, -14.0), false, "spring"],
		["stone_1", DIG + Vector3(0.0, 0, 5.0), true, "stone"], ["stone_2", Vector3(-28.0, 0.29, -34.0), false, "stone"], ["stone_3", Vector3(16.0, 0.29, -54.0), false, "stone"],
	]
	for sp: Array in specs:
		var at: Vector3 = sp[1]
		var right: bool = sp[2]
		match String(sp[3]):
			"tree":
				_plane_tree(at, right, rng)
			"spring":
				Props.make_solid(Props.box(_stage, Vector3(1.4, 0.6, 0.8), at + Vector3(0, 0.3, 0), Color("a89a80")))
				Props.box(_stage, Vector3(1.0, 0.04, 0.5), at + Vector3(0, 0.62, 0), Color("3e6e8e") if right else Color("6a5a48"))
				if right:
					var tr_ := Props.box(_stage, Vector3(0.06, 0.6, 0.06), at + Vector3(0, 0.9, -0.38), Color("8ac8e8"))
					tr_.material_override = Props.mat(Color("8ac8e8"), 0.6, true, "", false)
					Props.make_solid(Props.box(_stage, Vector3(1.6, 1.4, 0.4), at + Vector3(0, 0.7, -0.6), Color("8a8270")))
			"stone":
				var st := Props.box(_stage, Vector3(0.7, 1.1, 0.25), at + Vector3(0, 0.5, 0), Color("b8b0a0"), Vector3(-8, rng.randf() * 40.0, 6))
				Props.make_solid(st)
				if right:
					for k in 5:
						Props.box(st, Vector3(0.04, 0.16 + (k % 3) * 0.04, 0.02), Vector3(-0.12 + k * 0.06, 0.15 + (0.04 if k in [1, 2, 3] else 0.0), 0.13), Color("5a5246"))
					Props.box(st, Vector3(0.2, 0.14, 0.02), Vector3(0, 0.0, 0.13), Color("5a5246"))
		_signs[sp[0]] = [at, right, sp[3]]
		Props.interactable(_stage, sp[0], Vector3(2.2, 2.4, 2.2), at + Vector3(0, 1.0, 0))
	# Mezar taşları, devrik sütun, çalılar
	for i in 18:
		var p := Vector3(rng.randf_range(-36.0, 36.0), 0.29, rng.randf_range(-58.0, -6.0))
		if p.distance_to(DIG) < 6.0:
			continue
		Props.box(_stage, Vector3(0.35, rng.randf_range(0.6, 1.1), 0.12), p + Vector3(0, 0.4, 0), Color("c8c0b0").darkened(rng.randf() * 0.3), Vector3(rng.randf_range(-12, 12), rng.randf() * 180.0, rng.randf_range(-10, 10)))
	Props.cyl(_stage, 0.35, 3.6, Vector3(-10.0, 0.6, -26.0), Color("d8d0c0"), Vector3(0, 40, 90), 10)
	aksem = Person.new({"coat": Color("e8e0d0"), "pants": Color("d8d0c0"), "robe": Color("6a7a5a"), "hat": "turban", "beard": true, "hair": Color("e0e0d8"),
		"skin": Color("d8b090")})
	aksem.set_meta("spk", "SPK_AKSEMSEDDIN")
	_stage.add_child(aksem)
	aksem.position = Vector3(-1.0, 0.29, -12.0)
	aksem.look_target = player
	Props.cyl(aksem, 0.025, 1.4, Vector3(0.35, 0.7, 0.2), Color("6a4a2c"), Vector3(0, 0, -6), 5)
	dervish = Person.new({"coat": Color("6a5a48"), "pants": Color("4a4038"), "robe": Color("6a5a48"), "hat": "turban", "beard": true, "skin": Color("c89070")})
	dervish.set_meta("spk", "SPK_DERVISH")
	_stage.add_child(dervish)
	dervish.position = Vector3(-2.6, 0.29, -10.6)
	dervish.look_target = player
	for k in 2:
		var dv := Person.new({"coat": Color("7a6a50"), "pants": Color("4a4038"), "robe": Color("7a6a50"), "hat": "turban", "beard": k == 0, "skin": Color("d8b090")})
		dv.set_meta("no_talk", true)
		_stage.add_child(dv)
		dv.position = DIG + Vector3(-3.0 + k * 6.0, 0, 3.0)
		dv.rotation.y = PI


func _plane_tree(at: Vector3, split: bool, rng: RandomNumberGenerator) -> void:
	var trunk := Color("6a5a48")
	if split:
		for sx: float in [-1.0, 1.0]:
			Props.make_solid(Props.cyl(_stage, 0.32, 5.0, at + Vector3(sx * 0.35, 2.4, 0), trunk, Vector3(0, 0, -sx * 9.0), 8, 0.22))
			Props.ball(_stage, 2.0, at + Vector3(sx * 1.8, 5.6, 0), Color("4a6a32"), Vector3(1.2, 0.8, 1.2), 8)
		Props.box(_stage, Vector3(0.12, 3.0, 0.5), at + Vector3(0, 2.0, 0.2), Color("1a1410"))            # yanık yarık
	else:
		Props.make_solid(Props.cyl(_stage, 0.42, 5.0, at + Vector3(0, 2.5, 0), trunk, Vector3.ZERO, 8, 0.3))
		Props.ball(_stage, 3.0, at + Vector3(0, 6.0, 0), Color("4a6a32").darkened(rng.randf() * 0.15), Vector3(1.2, 0.8, 1.2), 8)


# ================================================================ 3. şerefe iskelesi (1 Haziran sabahı)

var bcity: ByzCity
var _coil: Node3D
var _lash_points: Array = []
var _platform_y := 0.0


func _aya() -> Vector3:
	return ByzCity.AYA


func _scaffold_phase() -> void:
	phase = "scaff"
	_stage = Node3D.new()
	add_child(_stage)
	bcity = ByzCity.new()
	bcity.part = "aya"            # tek harita: Ayasofya'nın gerçek yeri (iç mekân _ready'de kurulur)
	_stage.add_child(bcity)
	var a := _aya()
	# Narteksin dış yüzü (yerel z 21.4): iki kat iskele, merdivenler; ana duvar (z 17) tırmanılır; çatıda şerefe tahtası
	var fz := a.z + 21.4
	var sx := a.x + 12.5
	var deck1 := Props.solid(_stage, Vector3(3.6, 0.2, 2.0), Vector3(sx, 5.2, fz + 1.0), Color.WHITE)
	Props.set_pattern(deck1, Color("8a6440"), "wood")
	for dx: float in [-1.6, 1.6]:
		for dz: float in [0.2, 1.8]:
			Props.cyl(_stage, 0.07, 5.2, Vector3(sx + dx, 2.6, fz + dz), Color("6a4a2c"), Vector3.ZERO, 6)
	var l1 := Ladder.new(5.6, 12.0, Color("6a4a2c"))
	l1.position = Vector3(sx - 0.8, 0.0, fz + 2.0 + 5.6 * sin(deg_to_rad(12.0)) + 0.1)
	_stage.add_child(l1)
	var l2 := Ladder.new(5.6, 10.0, Color("6a4a2c"))
	l2.position = Vector3(sx + 0.8, 5.3, fz + 5.6 * sin(deg_to_rad(10.0)) + 0.12)
	_stage.add_child(l2)
	# Şerefe tahtası: ana çatının kenarında (y 16.45), dışa taşan 2x3 m platform, üç bağ noktası (dikme + kiriş)
	_platform_y = 16.55
	var pc := Vector3(sx, _platform_y, a.z + 15.4)
	var deck := Props.solid(_stage, Vector3(3.0, 0.16, 2.6), pc + Vector3(0, -0.08, 0.6), Color.WHITE)
	Props.set_pattern(deck, Color("8a6440"), "wood")
	for k in 3:
		var lp := pc + Vector3(-1.2 + k * 1.2, 0, 1.75)
		Props.cyl(_stage, 0.06, 1.3, lp + Vector3(0, 0.65, 0), Color("6a4a2c"), Vector3.ZERO, 6)
		_lash_points.append(lp)
		Props.interactable(_stage, "lash_%d" % k, Vector3(0.9, 1.4, 0.9), lp + Vector3(0, 0.7, 0))
	Props.box(_stage, Vector3(3.0, 0.1, 0.1), pc + Vector3(0, 1.2, 1.75), Color("6a4a2c"))
	# İp kangalı (iskelenin dibinde), marangoz platformda çekiç vuruyor
	_coil = Node3D.new()
	_stage.add_child(_coil)
	_coil.position = Vector3(sx - 2.6, 0.2, fz + 3.2)
	for k in 4:
		Props.ring(_coil, 0.18, 0.24, Vector3(0, k * 0.06, 0), Color("b89a6a"))
	Props.interactable(_coil, "coil", Vector3(1.0, 1.0, 1.0), Vector3(0, 0.3, 0))
	carpenter = Person.new({"coat": Color("6a5040"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": true, "skin": Color("c89070")})
	carpenter.set_meta("spk", "SPK_SOLDIER")
	_stage.add_child(carpenter)
	carpenter.position = Vector3(sx - 2.0, 0.0, fz + 3.0)
	carpenter.look_target = player
	# Avluda bekleyen cemaat
	var items: Array = []
	for i in 40:
		items.append([Transform3D(Basis(Vector3.UP, PI + randf_range(-0.4, 0.4)), Vector3(a.x - 10.0 + (i % 10) * 2.2, 0, fz + 9.0 + (i / 10) * 1.6)),
			{"side": "C" if i % 3 == 0 else "O", "coat": [Color("6a5040"), Color("2e4a7a"), Color("e8e0d0"), Color("7a2a24")][i % 4], "hat": "turban" if i % 2 == 0 else "bork", "arm": ""}])
	Crowd.place(_stage, items)
	player.global_position = Vector3(sx - 4.0, 0.05, fz + 6.0)
	player.face(carpenter.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D31O_N_05")
	await hud.say("SPK_SOLDIER", "D31O_CARP_01")
	await hud.say("SPK_TOLGA", "D31O_T_04")
	player.enable_climb([Rect2(a.x - 17.0, a.z + 13.0, 34.0, 12.0)])
	player.frozen = false
	var left := SCAFF_TIME
	var have_coil := false
	var stage := "coil"
	var wrap := 0
	var gust_t := 8.0
	var gust := 0.0
	var bal := 0.0
	var bot_t := 0.0
	while lashes < 3 and left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		var p := player.global_position
		match stage:
			"coil":
				hud.set_objective(tr("UI_OBJ31O_SCAFF") % ceili(left), _coil.global_position + Vector3(0, 0.8, 0))
				if _coil_taken or GameState.autotest:
					have_coil = true
					_coil.reparent(player.camera)
					_coil.position = Vector3(0.3, -0.6, 0.2)
					stage = "climb"
			"climb":
				hud.set_objective(tr("UI_OBJ31O_SCAFF") % ceili(left), pc + Vector3(0, 1.4, 0.6))
				if p.y > _platform_y - 0.3 and Vector2(p.x - pc.x, p.z - (pc.z + 0.6)).length() < 2.2:
					stage = "lash"
					hud.bark("SPK_TOLGA", "D31O_T_TOP", 4.0)
				if GameState.autotest:
					bot_t += dt
					# Basamak basamak: merdiven 1, iskele, merdiven 2, narteks çatısı, ana çatı (her durak 1 sn)
					var stops := [Vector3(sx - 0.8, 2.0, fz + 2.6), Vector3(sx, 5.35, fz + 1.0), Vector3(sx + 0.8, 8.0, fz + 1.4),
						Vector3(sx, 10.8, fz - 2.0), pc + Vector3(0, 0.1, 0.4)]
					var k := mini(int(bot_t / 1.0), stops.size() - 1)
					player.global_position = stops[k]
			"lash":
				var i := lashes
				var lp: Vector3 = _lash_points[i]
				hud.set_objective(tr("UI_OBJ31O_LASH") % lashes, lp + Vector3(0, 1.0, 0))
				# Esinti: platformda denge
				gust_t -= dt
				if gust_t <= 0.0:
					gust_t = randf_range(7.0, 9.0)
					gust = 1.0
					hud.bark("SPK_SOLDIER", "D31O_CARP_GUST", 2.0)
					Audio.sfx("cloth", -2.0, 0.7)
				gust = maxf(0.0, gust - dt * 0.4)
				var crouch := Input.is_action_pressed("dive") or (GameState.autotest and gust > 0.0)
				var input := Input.get_axis("move_left", "move_right")
				if GameState.autotest:
					input = -signf(bal) * 0.9 if absf(bal) > 0.1 else 0.0
				bal += (gust * sin(left * 3.0) * (0.4 if crouch else 1.2) + input * 1.4) * dt
				bal = move_toward(bal, 0.0, dt * 0.1)
				balance.visible = gust > 0.05 or absf(bal) > 0.15
				balance.label_text = tr("UI_OBJ31O_WIND")
				balance.value = bal
				player.camera.rotation.z = -bal * 0.1
				if absf(bal) >= 1.0:
					# Düşüş: narteks çatısına, −25 can; oradan yeniden tırman
					bal = 0.0
					balance.visible = false
					player.camera.rotation.z = 0.0
					player.global_position = Vector3(sx, 10.8, fz - 2.0)
					player.hurt(25.0, Vector3.INF, true)
					Audio.sfx("land_thud", -2.0, 0.8)
					stage = "climb"
					bot_t = 3.0
					continue
				if crouch:
					continue
				var near := p.distance_to(lp) < 1.8
				if GameState.autotest and not near:
					player.global_position = lp + Vector3(0, 0.1, -0.9)
					near = true
				var hold := (Input.is_action_pressed("interact") and near) or GameState.autotest
				if hold and not meter.enabled:
					wrap_t += dt
					if wrap_t > 0.7:
						wrap_t = 0.0
						wrap += 1
						_wrap_ring(lp, wrap)
						Audio.sfx("cloth", -8.0, 1.2)
						if wrap >= 3:
							_strokes.clear()
							meter.enabled = true
							hud.set_qte(tr("UI_OBJ31O_LASH") % lashes)
				if meter.enabled:
					if Input.is_action_just_pressed("jump"):
						meter.press()
					while _strokes.size() > 0:
						var good: bool = _strokes.pop_front() or GameState.autotest
						meter.enabled = false
						hud.set_qte("")
						if good and not (_late() and lashes == 1 and lash_misses == 0):
							lashes += 1
							hud.bark("SPK_SOLDIER", "D31O_CARP_KNOT_OK", 2.0)
							Props.ball(_stage, 0.08, lp + Vector3(0, 0.9, 0.05), Color("b89a6a"), Vector3.ONE, 6)
						else:
							lash_misses += 1
							hud.bark("SPK_SOLDIER", "D31O_CARP_KNOT_BAD", 2.0)
							for r in _rings:
								if is_instance_valid(r):
									r.queue_free()
							_rings.clear()
						wrap = 0
						break
	balance.visible = false
	meter.enabled = false
	hud.set_qte("")
	hud.set_objective("")
	player.camera.rotation.z = 0.0
	player.disable_climb()
	player.frozen = true
	scaff_ok = lashes >= 3
	if is_instance_valid(_coil):
		_coil.queue_free()
	if not scaff_ok:
		await hud.say("SPK_SOLDIER", "D31O_CARP_LATE")
	await hud.fade_to(1.0, 0.6)


var _coil_taken := false
var wrap_t := 0.0
var _rings: Array = []


func _wrap_ring(lp: Vector3, n: int) -> void:
	var r := Props.ring(_stage, 0.07, 0.1, lp + Vector3(0, 0.55 + n * 0.12, 0), Color("b89a6a"))
	_rings.append(r)


# ================================================================ 4. hasır ve saf (1 Haziran öğle)

var _mat_slots: Array = []         # [konum, Node3D (hayalet), serildi mi]
var _carry_mat: Node3D
var _active_mat: Node3D
var _active_slot := -1
var _mat_yaw := 0.0
var _rows: Array = []
var _walkers_n := 0


func _mats_phase() -> void:
	phase = "mats"
	var a := _aya()
	var q := deg_to_rad(QIBLA_DEG)
	# Kıble ipi: iki çivi arasında kırmızı ip, nef eksenine 30° sağa
	var rope_c := a + Vector3(0, 0.04, -2.0)
	var rope := Props.box(_stage, Vector3(0.03, 0.02, 14.0), rope_c, Color("c8262f"), Vector3(0, -QIBLA_DEG, 0))
	rope.material_override = Props.mat(Color("c8262f"), 0.4, false, "", false)
	for sgn: float in [-1.0, 1.0]:
		Props.cyl(_stage, 0.03, 0.2, rope_c + Vector3(sin(-q) * 7.0 * sgn, 0.06, cos(q) * 7.0 * sgn), Color("6a6a6a"), Vector3.ZERO, 6)
	# Hasır yerleri: ipe dik sıralar (iki sıra x dört), hayalet dikdörtgen
	var across := Vector3(cos(q), 0, sin(q))          # ipe dik (saf yönü)
	var along := Vector3(-sin(q), 0, cos(q))
	for i in MATS:
		var row := i / 4
		var col := i % 4
		var c := rope_c + across * (-4.5 + col * 3.0) + along * (2.0 - row * 2.2)
		var ghost := Props.box(_stage, Vector3(2.6, 0.02, 1.2), c + Vector3(0, 0.02, 0), Color(1, 1, 1, 0.25), Vector3(0, -QIBLA_DEG, 0))
		ghost.material_override = Props.mat(Color(1, 1, 1, 0.22), 0.2, true, "", false)
		_mat_slots.append([c, ghost, false])
		Props.interactable(_stage, "slot_%d" % i, Vector3(2.4, 1.0, 1.6), c + Vector3(0, 0.4, 0))
	# Narteks'te rulolar
	var pile := a + Vector3(4.0, 0.0, 19.2)
	for k in MATS:
		Props.cyl(_stage, 0.18, 1.2, pile + Vector3(0, 0.2 + (k / 4) * 0.36, -0.6 + (k % 4) * 0.4), Color("b8a060"), Vector3(0, 0, 90), 8)
	Props.interactable(_stage, "mats", Vector3(1.6, 1.4, 2.0), pile + Vector3(0, 0.6, 0))
	dervish = Person.new({"coat": Color("6a5a48"), "pants": Color("4a4038"), "robe": Color("6a5a48"), "hat": "turban", "beard": true, "skin": Color("c89070")})
	dervish.set_meta("spk", "SPK_DERVISH")
	_stage.add_child(dervish)
	dervish.position = rope_c + Vector3(-2.0, 0, 4.0)
	dervish.look_target = player
	player.global_position = a + Vector3(2.0, 0.05, 13.0)
	player.face(rope_c + Vector3(0, 1.0, 0))
	await hud.fade_to(0.0, 0.8)
	Audio.ambience("amb_church")
	await hud.say("SPK_DERVISH", "D31O_DV_02")
	await hud.say("SPK_TOLGA", "D31O_T_05")
	player.frozen = false
	var left := MAT_TIME
	var bot_t := 0.0
	var walkers_t := 2.0
	while mats_done < MATS and left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		hud.set_objective(tr("UI_OBJ31O_MAT") % [mats_done, MATS] + ("\n" + tr("UI_OBJ31O_TURN") if _active_mat else ""),
			(_mat_slots[_next_slot()][0] as Vector3) + Vector3(0, 1.0, 0) if _carry_mat else pile + Vector3(0, 1.2, 0))
		# İçeri akan cemaat (yolu keser)
		walkers_t -= dt
		if walkers_t <= 0.0 and _walkers_n < 14:
			_walkers_n += 1
			walkers_t = 3.0
			_walker(a)
		if _active_mat:
			# Döndür: A/D; ipe paralel (±4°) olunca ip yeşil
			var input := Input.get_axis("move_left", "move_right")
			_mat_yaw = clampf(_mat_yaw + input * 30.0 * dt, -40.0, 40.0)
			if GameState.autotest:
				_mat_yaw = move_toward(_mat_yaw, 10.0 if _late() else 0.0, 30.0 * dt)      # yavaş karede de aşmaz
			_active_mat.rotation.y = deg_to_rad(-QIBLA_DEG + _mat_yaw)
			var ok := absf(_mat_yaw) <= 4.0
			rope.material_override = Props.mat(Color("3ac85a") if ok else Color("c8262f"), 0.5, false, "", false)
			if GameState.autotest and absf(_mat_yaw - (10.0 if _late() else 0.0)) < 1.0:
				_fix_mat()
			continue
		if GameState.autotest and not (_late() and mats_done >= 5):
			bot_t += dt
			if bot_t > 0.8:
				bot_t = 0.0
				if not _carry_mat:
					player.global_position = pile + Vector3(-1.4, 0.05, 0)
					_on_interact("mats")
				else:
					var sl := _next_slot()
					player.global_position = (_mat_slots[sl][0] as Vector3) + Vector3(0, 0.05, 1.6)
					_on_interact("slot_%d" % sl)
	hud.set_objective("")
	mats_ok = mats_done >= MATS
	if is_instance_valid(_carry_mat):
		_carry_mat.queue_free()
	player.frozen = true
	if not mats_ok:
		await hud.say("SPK_DERVISH", "D31O_DV_FIXED")
	# Saflar dolar; Tespit (kamet öncesi)
	await hud.say("SPK_NIHAT", "D31O_N_PHOTO")
	var target := Node3D.new()
	_stage.add_child(target)
	target.global_position = rope_c + Vector3(0, 1.0, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ31O_PHOTO"), target.global_position + Vector3(0, 1.0, 0))
	cam = TespitCam.new(player, hud, target, "siege31o")
	hud.add_child(cam)
	cam.max_dist = 30.0
	cam.cone_deg = 16.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 60.0):
		await get_tree().process_frame
		t += get_process_delta_time()
		if GameState.autotest:
			player.global_position = a + Vector3(2.0, 0.05, 11.0)
			player.face(target.global_position)
	cam.stop()
	# Kare alındı: hedef kalkar, konuşmalar akar; oyuncu hedefsiz serbest kalmasın
	player.frozen = true
	hud.set_objective("")
	if not _photo.is_empty():
		await hud.say("SPK_NIHAT", "D31O_N_PHOTO_OK")
	# Yangından çıkan azap da cemaatte: Tolga'yı kapının yanına o oturtur (replik onu anlatıyor; kartta da kendi yüzü)
	var az := Person.new({"coat": Color("8a3a2e"), "pants": Color("e8e0d0"), "hat": "azap", "mustache": true, "skin": Color("c89070")})
	az.set_meta("spk", "SPK_AZAP")
	_stage.add_child(az)
	az.global_position = a + Vector3(3.0, 0.0, 14.6)
	az.look_target = player
	player.face(az.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_AZAP", "D31O_AZ_03")
	az.global_position = a + Vector3(2.7, 0.0, 15.6)
	az.look_target = null
	az.set_activity("sit_ground")
	# Kapının yanına otur; kamet: saflar kalkar, rükû
	player.frozen = true
	player.global_position = a + Vector3(1.6, 0.05, 15.4)
	player.eye_height = 0.95
	player.face(rope_c + Vector3(0, 1.0, 0))
	await hud.say("SPK_NIHAT", "D31O_N_KHUTBE")
	for r in _rows:
		if is_instance_valid(r):
			(r as Person).set_activity("")
	await get_tree().create_timer(1.2).timeout
	for r in _rows:
		if is_instance_valid(r) and (r as Person).rig:
			var pr := r as Person
			pr.rig.lock += 1
			var tw := pr.create_tween()
			tw.tween_property(pr.rig.body if pr.rig.body else pr, "rotation:x", -0.9, 0.8 + randf() * 0.3)
			tw.tween_interval(1.6)
			tw.tween_property(pr.rig.body if pr.rig.body else pr, "rotation:x", 0.0, 0.8)
	await hud.say("SPK_TOLGA", "D31O_T_06")
	await get_tree().create_timer(2.0).timeout
	player.eye_height = Player.EYE
	await hud.say("SPK_TOLGA", "D31O_T_END")
	await hud.say("SPK_NIHAT", "D31O_N_END")
	var on_time := int(house_ok) + int(sun_ok) + int(scaff_ok) + int(mats_ok)
	_outcome = "31O.1" if on_time >= 3 else "31O.2"
	Siege.record(31, _photo, "SIEGE_NOTE_31O_%s" % _outcome.split(".")[1])


func _next_slot() -> int:
	for i in _mat_slots.size():
		if not bool(_mat_slots[i][2]):
			return i
	return 0


var _seats: Array[Vector3] = []     # içeri akan cemaatin seçtiği oturma yerleri (iki kişi aynı yere gitmesin)

func _walker(a: Vector3) -> void:
	var w := Person.new({"coat": [Color("6a5040"), Color("2e4a7a"), Color("e8e0d0")][randi() % 3], "pants": Color("e8e0d0"), "hat": "turban", "beard": randf() < 0.5})
	w.set_meta("no_talk", true)
	_stage.add_child(w)
	# Kapının içinde, payelerin ve önceki gelenlerin dışında bir yerde belirir (eskiden kapının yanındaki payenin içinde doğabiliyordu)
	w.global_position = a + Vector3(0, 0, 16.0)
	for k in 12:
		var s := a + Vector3(randf_range(-3.0, 3.0), 0, 16.0)
		if not Unclip.in_solid(w, s, 0.25) and not Unclip.crowded(w, s, 0.8):
			w.global_position = s
			break
	# Oturacağı yer: payelerin, kürsünün, başkasının (oturmuş ya da oraya yürüyen) olmadığı, kapıdan düz yürünen bir nokta.
	# Eskiden rastgele bir noktaya düz tween'le kayıyordu: payenin içinden, birbirinin içinden geçip oturuyorlardı.
	var to := a + Vector3(randf_range(-10.0, 10.0), 0, randf_range(-8.0, -12.0))
	for k in 16:
		var c := a + Vector3(randf_range(-10.0, 10.0), 0, randf_range(-8.0, -12.0))
		var taken := false
		for st in _seats:
			if st.distance_to(c) < 1.1:
				taken = true
				break
		if not taken and not Unclip.in_solid(w, c, 0.3) and not Unclip.crowded(w, c, 1.0) and _clear_line(w.global_position, c):
			to = c
			break
	_seats.append(to)
	var wk := Walker.go(w, to, 1.3)
	wk.arrived.connect(func():
		if is_instance_valid(w):
			w.set_activity("sit_ground"))


## İki nokta arası yürünür mü: diz, bel ve omuz hizasında, ortada ve iki yanda düz çizgi açık.
func _clear_line(from: Vector3, to: Vector3) -> bool:
	var space := get_world_3d().direct_space_state
	var side := (to - from).normalized().cross(Vector3.UP) * 0.3
	for off: Vector3 in [Vector3.ZERO, side, -side]:
		for hy: float in [0.4, 0.9, 1.4]:
			var q := PhysicsRayQueryParameters3D.create(from + off + Vector3(0, hy, 0), to + off + Vector3(0, hy, 0), 1, [player.get_rid()])
			if not space.intersect_ray(q).is_empty():
				return false
	return true


func _fix_mat() -> void:
	if not _active_mat:
		return
	var i := _active_slot
	_mat_slots[i][2] = true
	(_mat_slots[i][1] as Node3D).visible = false
	mat_err_sum += absf(_mat_yaw)
	mats_done += 1
	hud.bark("SPK_DERVISH", "D31O_DV_OK" if absf(_mat_yaw) <= 4.0 else "D31O_DV_TURN", 2.0)
	# Hasırın üstüne bir saf yürüyerek gelir, oturur
	var c: Vector3 = _mat_slots[i][0]
	var q := deg_to_rad(QIBLA_DEG)
	var across := Vector3(cos(q), 0, sin(q))
	for k in 3:
		var pr := Person.new({"coat": [Color("e8e0d0"), Color("6a5040"), Color("2e4a7a")][k], "pants": Color("e8e0d0"), "hat": "turban" if k != 1 else "bork",
			"beard": k == 0, "mustache": true})
		pr.set_meta("no_talk", true)
		_stage.add_child(pr)
		# Kapıdan sırayla (aynı noktada doğup iç içe başlamasınlar), saf yerine yürüyerek (yoldakilerin içinden geçmez)
		pr.global_position = _aya() + Vector3(-1.6 + k * 1.6, 0, 15.0)
		var dst := c + across * (-0.8 + k * 0.8)
		var wk := Walker.go(pr, dst, 1.6)
		wk.arrived.connect(func():
			if is_instance_valid(pr):
				var at := Vector3(dst.x, pr.global_position.y, dst.z)
				if not Unclip.in_solid(pr, at) and not Unclip.crowded(pr, at, 0.45):
					pr.global_position = at       # yürüyüş kısa kaldıysa yerine oturur (kürsünün, başkasının içine değil)
				pr.rotation.y = PI - q
				pr.set_activity("sit_ground"))
		_rows.append(pr)
	_active_mat = null
	_active_slot = -1
	_mat_yaw = 0.0
	player.frozen = false


func _on_focus(id: String) -> void:
	var k := ""
	match phase:
		"house":
			if id == "azap":
				k = "UI_PROMPT31O_LIFT"
			elif id == "child":
				k = "UI_PROMPT31O_ROPE"
		"eyup":
			if id in _signs:
				k = "UI_PROMPT31O_LOOK"
			elif id == "dig":
				k = "UI_PROMPT31O_DIG"
		"scaff":
			if id == "coil":
				k = "UI_PROMPT31O_COIL"
			elif id.begins_with("lash_"):
				k = "UI_PROMPT31O_WRAP"
		"mats":
			if id == "mats" and not _carry_mat:
				k = "UI_PROMPT31O_MAT"
			elif id.begins_with("slot_") and _carry_mat:
				k = "UI_PROMPT31O_LAY"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	match phase:
		"house":
			if id == "azap":
				_lift_req = true
			elif id == "child":
				_child_taken = true
		"eyup":
			if id in _signs and not _found.has(id):
				var sg: Array = _signs[id]
				if bool(sg[1]):
					_found[id] = true
					signs_found += 1
					Audio.sfx("ui_confirm", -8.0, 1.0)
					var mk := Props.ball(_stage, 0.1, (sg[0] as Vector3) + Vector3(0, 2.6, 0), Color("ffd24a"), Vector3.ONE, 6, 1.5)
					mk.name = "mark"
				else:
					wrong_signs += 1
					hud.bark("SPK_AKSEMSEDDIN", "D31O_AK_NO", 2.5)
		"scaff":
			if id == "coil":
				_coil_taken = true
		"mats":
			if id == "mats" and not _carry_mat:
				_carry_mat = Node3D.new()
				player.camera.add_child(_carry_mat)
				_carry_mat.position = Vector3(0.35, -0.55, -0.6)
				Props.cyl(_carry_mat, 0.16, 1.1, Vector3.ZERO, Color("b8a060"), Vector3(0, 90, 90), 8)
				Props.strip_outlines(_carry_mat)
			elif id.begins_with("slot_") and _carry_mat and not _active_mat:
				var i := int(id.trim_prefix("slot_"))
				if bool(_mat_slots[i][2]):
					return
				_carry_mat.queue_free()
				_carry_mat = null
				_active_slot = i
				var c: Vector3 = _mat_slots[i][0]
				_active_mat = Node3D.new()
				_stage.add_child(_active_mat)
				_active_mat.global_position = c + Vector3(0, 0.03, 0)
				_mat_yaw = randf_range(-25.0, 25.0)
				_active_mat.rotation.y = deg_to_rad(-QIBLA_DEG + _mat_yaw)
				var m := Props.box(_active_mat, Vector3(2.6, 0.03, 1.2), Vector3.ZERO, Color("c8b070"))
				m.scale = Vector3(0.1, 1.0, 1.0)
				m.create_tween().tween_property(m, "scale", Vector3.ONE, 0.6)      # açılarak yayılır
				for k in 5:
					Props.box(_active_mat, Vector3(2.6, 0.035, 0.03), Vector3(0, 0, -0.5 + k * 0.25), Color("a89050"))
				player.frozen = true
			elif _active_mat and id.begins_with("slot_"):
				_fix_mat()


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(31, _outcome)
	await Siege.show_page(hud, 31)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(31)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW31O_TITLE")
	c.nodes = [
		{"id": "house", "key": "FLOW31O_HOUSE", "pos": Vector2(0.5, 0.1)},
		{"id": "eyup", "key": "FLOW31O_EYUP", "pos": Vector2(0.5, 0.22)},
		{"id": "scaff", "key": "FLOW31O_SCAFF", "pos": Vector2(0.5, 0.34)},
		{"id": "mats", "key": "FLOW31O_MATS", "pos": Vector2(0.5, 0.46)},
		{"id": "friday", "key": "FLOW31O_FRIDAY", "pos": Vector2(0.5, 0.58)},
		{"id": "31O.1", "key": "FLOW_31O_1", "pos": Vector2(0.3, 0.72), "outcome": true},
		{"id": "31O.2", "key": "FLOW_31O_2", "pos": Vector2(0.7, 0.72), "outcome": true},
	]
	c.edges = [["house", "eyup"], ["eyup", "scaff"], ["scaff", "mats"], ["mats", "friday"], ["friday", "31O.1"], ["friday", "31O.2"]]
	for k in ["house", "eyup", "scaff", "mats", "friday"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		Grade.finish("31o"),
		tr("UI_CH31O_STATS") % [int(maxf(house_left, 0.0)), signs_found, lashes, mats_done, MATS, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "31O.1", "late": "31O.2"}.get(v, "31O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("31", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null
	if v == "":
		ok = ok and house_ok and sun_ok and scaff_ok and mats_ok and beam_falls == 0 and wrong_signs == 0 and cam.done
	else:
		ok = ok and beam_falls >= 1 and wrong_signs >= 2 and lash_misses >= 1
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s ev=%s güneş=%s iskele=%s hasır=%s düşüş=%d yanlış=%d ıska=%d foto=%s)" % [expected, _outcome,
			not page.is_empty(), house_ok, sun_ok, scaff_ok, mats_ok, beam_falls, wrong_signs, lash_misses, cam != null and cam.done])
	print("AUTOTEST %s chapter=31o variant=%s outcome=%s house=%s(%.0f) falls=%d signs=%d wrong=%d sun=%s lashes=%d miss=%d scaff=%s mats=%d/%d err=%.0f" % [
		"PASS" if ok else "FAIL", v, _outcome, house_ok, house_left, beam_falls, signs_found, wrong_signs, sun_ok, lashes, lash_misses, scaff_ok, mats_done, MATS, mat_err_sum])
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
	hud.visible = false
	_stage = Node3D.new()
	add_child(_stage)
	walls = LandWalls.new()
	walls.near_works = false
	_stage.add_child(walls)
	walls.make_day()
	walls.open_inner_gate()
	city = FallenCity.new()
	city.field = walls.field
	city.quiet = true
	city.reserve_right = Vector2(HZ1 + 0.4, HZ0 - 0.2)
	_stage.add_child(city)
	FallenCity.mood(walls.env.environment, walls.moon)
	walls.env.environment.fog_density = 0.006
	_build_burnt_house()
	_build_street_people()
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(-2.4, 5.2, -82.0)
	cv.look_at(Vector3(5.0, 4.2, -74.0), Vector3.UP)
	cv.fov = 62.0
	cv.make_current()
	await get_tree().create_timer(0.8).timeout
	await _shot_png("c31o_cover.png")
	cv.global_position = Vector3(-1.2, 1.8, -30.0)
	cv.look_at(Vector3(1.0, 2.6, -60.0), Vector3.UP)
	await get_tree().create_timer(0.4).timeout
	await _shot_png("c31o_01_street.png")
	get_tree().quit()
