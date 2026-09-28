extends Node3D
## Bölüm 25 — Son Akşam (Tolga · 27–28 Mayıs 1453). docs/SIEGE.md §3.
##
## İlk yarı (Osmanlı ordugâhı, 27 Mayıs gecesi): ordugâh kandillerle aydınlanmıştır. Tolga aşçı yamağıdır; otağa
## şerbet götürür, sonra otağın arka duvarının dibinde meclisi dinler: Çandarlı Halil barıştan (Batı'dan yardım
## gelir korkusu), Zağanos Paşa hücumdan yana; Sultan kararını verir: yarın oruç ve dinlenme, ertesi gün hücum.
## Nöbetçiler otağın çevresinde döner: görülen yamak mutfağa geri gönderilir. İki kez görülürse meclisin sonu kaçar.
## Tespit karesi: kandillerle ordugâh.
## İkinci yarı (Ayasofya, 28 Mayıs akşamı): Rum ve Latin aynı mekânda son ayin. İmparator helallik ister.
## Tolga bir mum yakabilir. Fotoğraf yok.
##   25.1 Meclis sonuna kadar dinlendi · 25.2 Meclisin sonu kaçtı (nöbetçiler)
##   --autotest[=caught]   (varsayılan: 25.1)

const OTAG := CampDay.OTAG_POS
const LISTEN_R := 7.7
const GUARD_R := 9.6
const COUNCIL := ["D25_H_1", "D25_Z_1", "D25_H_2", "D25_Z_2", "D25_F_1", "D25_F_2"]
const COUNCIL_SPK := ["SPK_HALIL", "SPK_ZAGANOS", "SPK_HALIL", "SPK_ZAGANOS", "SPK_FATIH", "SPK_FATIH"]
const LISTEN_TIME := 26.0
const AYA := Vector3(-14.0, 0.0, -82.0)

var day: CampDay
var city: ByzCity
var player: Player
var hud: Hud
var kadri: Person
var guards: Array[Soldier] = []
var _guard_a := [0.0, PI]
var door_guard: Soldier
var tray: Node3D
var phase := "intro"
var _outcome := ""
var _listen := 0.0
var _line := 0
var caught := 0
var _cool := 0.0
var _heard_all := false
var candle_lit := false
var _photo := ""
var cam: TespitCam
var emperor: Person
var _t := 0.0
## Bizans tarafı: ilk yarı ordugâhta değil, kara surlarında (27 Mayıs gecesi ordugâhın ışıkları surdan görülür)
var byz := false
var walls: LandWalls
var _night: Node3D


func _ready() -> void:
	GameState.snapshot(25)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_signal(0)
	var v := GameState.autotest_variant
	byz = Siege.side() != "O" and not v.begins_with("osm")
	if byz:
		hud.set_fez(false)
		_build_walls_night()
	else:
		hud.set_fez(true)
		day = CampDay.new()
		add_child(day)
		day.make_night(true)
		_build_camp()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _gy(p: Vector3) -> Vector3:
	return Vector3(p.x, CampDay.height(p.x, p.z), p.z)


func _build_camp() -> void:
	# Otağın duvarı katı: içeri girilmez (dışarıdan dinlenir)
	var wall := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 7.15
	cyl.height = 6.0
	cs.shape = cyl
	wall.position = _gy(OTAG) + Vector3(0, 3.0, 0)
	wall.set_meta("no_climb", true)
	wall.add_child(cs)
	add_child(wall)
	kadri = Person.new({"face": "kadri", "coat": Color("f0e8d8"), "pants": Color("5a4028"), "hat": "cook", "mustache": true,
		"apron": Color("f0e8d8"), "skin": Color("d9a07a")})
	kadri.position = _gy(CampDay.KADRI_FRONT)
	add_child(kadri)
	kadri.look_target = player
	# Nöbetçiler: ikisi otağın çevresinde döner, biri kapıda durur
	for i in 2:
		var g := Soldier.new(Color("2f5fa8"), "stand", "bork")
		add_child(g)
		guards.append(g)
	door_guard = Soldier.new(Color("2f5fa8"), "stand", "bork")
	door_guard.position = _gy(OTAG + Vector3(1.8, 0, 9.6))
	add_child(door_guard)
	Props.interactable(self, "otag_door", Vector3(2.4, 2.4, 1.6), _gy(OTAG + Vector3(0, 0, 9.2)) + Vector3(0, 1.2, 0))
	# Dinleme yerleri: otağın arkası (kapının tersi); küçük kazık işaretleri
	for a: float in [150.0, 180.0, 210.0]:
		var r := deg_to_rad(a)
		var p := _gy(OTAG + Vector3(sin(r) * LISTEN_R, 0, cos(r) * LISTEN_R))
		Props.cyl(self, 0.05, 0.6, p + Vector3(0, 0.3, 0), Color("6a4a2c"), Vector3.ZERO, 5)
	_place_guards(0.0)


func _place_guards(delta: float) -> void:
	for i in guards.size():
		_guard_a[i] = fposmod(_guard_a[i] + delta * 0.16, TAU)
		var a: float = _guard_a[i]
		guards[i].position = _gy(OTAG + Vector3(sin(a) * GUARD_R, 0, cos(a) * GUARD_R))
		guards[i].rotation.y = a + PI * 0.5


## Tolga dinleme yerinde mi (otağın arka yarısında, duvara yakın)?
func _at_wall() -> bool:
	var p := player.global_position - OTAG
	p.y = 0.0
	var r := p.length()
	return r < LISTEN_R + 0.9 and p.z < -2.5


## Bir nöbetçi Tolga'yı görüyor mu (yakın ve önünde)?
func _seen() -> bool:
	for g in guards:
		var to := player.global_position - g.global_position
		to.y = 0.0
		if to.length() > 4.2:
			continue
		var fwd := Vector3(sin(g.rotation.y), 0, cos(g.rotation.y))
		if fwd.dot(to.normalized()) > 0.3:
			return true
	return false


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH25_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH25_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	if byz:
		await _walls_night()
		await _liturgy()
		await _end_chapter()
		return
	player.global_position = _gy(CampDay.KITCHEN_SPAWN) + Vector3(0, 0.05, 0)
	player.face(kadri.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D25_N_01")
	await hud.say("SPK_KADRI", "D25_K_01")
	await hud.say("SPK_TOLGA", "D25_T_01")
	await hud.say("SPK_KADRI", "D25_K_02")
	_give_tray()
	Lore.scatter(self, "25")
	player.frozen = false
	phase = "tray"
	hud.set_objective(tr("UI_OBJ25_TRAY"), _gy(OTAG + Vector3(0, 0, 9.2)) + Vector3(0, 1.6, 0))
	if GameState.autotest:
		_on_interact("otag_door")
	while phase == "tray":
		await get_tree().process_frame
	await _listen_phase()
	await _lights()
	# Osmanlı tarafının tanığı ayine gitmez: ordugâhta son gece, Hasan'la ateş başında
	if Siege.side() == "O" or GameState.autotest_variant in ["osm", "osm_caught"]:
		await _vigil()
	else:
		await _liturgy()
	await _end_chapter()


func _give_tray() -> void:
	tray = Node3D.new()
	tray.position = Vector3(0.0, -0.5, -0.75)
	player.camera.add_child(tray)
	Props.cyl(tray, 0.32, 0.03, Vector3.ZERO, Color("c8a040"), Vector3.ZERO, 16)
	for k in 4:
		Props.cyl(tray, 0.05, 0.1, Vector3(-0.15 + k * 0.1, 0.06, 0.05 * (k % 2)), Color("c8e0f0"), Vector3.ZERO, 8)
	Props.strip_outlines(tray)


func _listen_phase() -> void:
	phase = "listen"
	hud.set_objective(tr("UI_OBJ25_LISTEN"), _gy(OTAG + Vector3(0, 0, -LISTEN_R)) + Vector3(0, 1.4, 0))
	hud.bark("SPK_TOLGA", "D25_T_LISTEN", 3.5)
	if GameState.autotest:
		if GameState.autotest_variant in ["caught", "osm_caught"]:
			for i in 2:
				_caught_once()
		else:
			player.global_position = _gy(OTAG + Vector3(0, 0, -LISTEN_R)) + Vector3(0, 0.05, 0)
			_listen = LISTEN_TIME
			_line = COUNCIL.size()
			_heard_all = true
	while phase == "listen":
		await get_tree().process_frame
	hud.set_chase("", 0.0)
	hud.set_objective("")
	hud.set_prompt("")
	player.frozen = true


func _caught_once() -> void:
	caught += 1
	_cool = 2.0
	Audio.sfx("crowd_gasp", -8.0, 1.2)
	hud.bark("SPK_SOLDIER", "D25_G_CAUGHT_%d" % mini(caught, 2), 3.0)
	player.global_position = _gy(OTAG + Vector3(0, 0, 16.0)) + Vector3(0, 0.05, 0)
	player.face(_gy(OTAG) + Vector3(0, 2.0, 0))
	if caught >= 2:
		phase = "listened"


func _lights() -> void:
	# Meclis dağılır; Sultan ordugâhı dolaşır, kandiller yanar. Tespit karesi.
	player.global_position = _gy(OTAG + Vector3(4.0, 0, 18.0)) + Vector3(0, 0.05, 0)
	player.face(_gy(OTAG + Vector3(0, 0, 40.0)) + Vector3(0, 3.0, 0))
	await hud.say("SPK_TOLGA", "D25_T_HEARD" if _heard_all else "D25_T_HALF")
	await hud.say("SPK_NIHAT", "D25_N_LIGHTS")
	var target := Node3D.new()
	add_child(target)
	target.global_position = Vector3(0.0, 4.0, 20.0)
	Lore.scatter(self, "25")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ25_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege25")
	hud.add_child(cam)
	cam.max_dist = 200.0
	cam.cone_deg = 25.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 45.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D25_T_LIGHTS")


## Bizans tarafı, 27 Mayıs gecesi: kara surlarının yürüyüş yolu. Karşıda ordugâh baştan uca kandil ve ateşle
## aydınlanır (kaynaklar: surdakiler kampın yandığını sandı); davul ve bağırış sesleri. Yanında bir nöbetçi.
func _build_walls_night() -> void:
	walls = LandWalls.new()
	add_child(walls)
	walls.set_repair(LandWalls.STAGES)
	Garrison.land_walls(self, [Vector2(-10.6, -6.8)], [Vector2(-30.0, 10.0)], [], 25)
	_night = Node3D.new()
	add_child(_night)
	var rng := RandomNumberGenerator.new()
	rng.seed = 527
	# Kandiller: her çadırın önünde küçük ışık (uzaktan ışık tozu gibi), arada büyük ateşler
	var lamp := SphereMesh.new()
	lamp.radius = 1.1
	lamp.height = 2.2
	lamp.radial_segments = 6
	lamp.rings = 3
	var lm := StandardMaterial3D.new()
	lm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lm.albedo_color = Color("ffc060")
	lm.emission_enabled = true
	lm.emission = Color("ffb040")
	lm.emission_energy_multiplier = 7.0
	lm.disable_fog = true           # uzak ışıklar sisin içinde sönmesin
	lamp.material = lm
	var xs: Array = []
	for i in 4200:
		var centre: Vector3 = [Vector3(0, 0, 380), Vector3(-420, 0, 360), Vector3(420, 0, 360)][0 if i % 5 < 3 else (1 if i % 5 == 3 else 2)]
		var r := sqrt(rng.randf()) * (270.0 if centre.x == 0.0 else 220.0)
		var a := rng.randf() * TAU
		var p := centre + Vector3(sin(a) * r, 0, cos(a) * r)
		if p.z < 120.0:
			continue
		xs.append(Transform3D(Basis(), p + Vector3(0, rng.randf_range(0.8, 2.6), 0)))
	var mm := Scenery.scatter(_night, lamp, xs, [], lm)
	mm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var flame := CylinderMesh.new()
	flame.top_radius = 0.2
	flame.bottom_radius = 3.0
	flame.height = 9.0
	flame.radial_segments = 6
	var fm := lm.duplicate() as StandardMaterial3D
	fm.albedo_color = Color("ff8a30")
	fm.emission = Color("ff7a20")
	fm.emission_energy_multiplier = 8.0
	flame.material = fm
	var fx: Array = []
	for i in 120:
		var p := Vector3(rng.randf_range(-360.0, 360.0), 4.5, rng.randf_range(140.0, 600.0))
		fx.append(Transform3D(Basis().scaled(Vector3.ONE * rng.randf_range(0.8, 1.6)), p))
	Scenery.scatter(_night, flame, fx, [], fm).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Ufuk turuncu: gök ve sis ordugâhın ışığını yansıtır
	var e := walls.env.environment
	e.fog_light_color = Color("7a4a3a")
	var sm := e.sky.sky_material as ProceduralSkyMaterial
	if sm:
		sm.sky_horizon_color = Color("8a5a48")
		sm.ground_horizon_color = Color("6a4030")
	# Yanındaki nöbetçi (konuşur)
	var d := Garrison.man(self, Vector3(-7.4, LandWalls.OUTER_H, 14.75), 0.1, 2501, "spear")
	d.set_meta("spk", "SPK_DEFENDER")
	d.remove_meta("no_talk")
	d.remove_meta("garrison")


func _walls_night() -> void:
	phase = "walls"
	player.global_position = Vector3(-9.2, LandWalls.OUTER_H + 0.05, 14.9)
	player.face(Vector3(10.0, 6.0, 300.0))
	_capture_mouse()
	Audio.ambience("amb_wall_night")
	await hud.card([[tr("UI_CH25B_WALL"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	Audio.sfx("crowd_camp", -2.0, 0.8)
	await hud.fade_to(0.0, 1.2)
	await hud.say("SPK_NIHAT", "D25B_N_1")
	await hud.say("SPK_DEFENDER", "D25B_S_1")
	await hud.say("SPK_TOLGA", "D25B_T_1")
	Audio.sfx("crowd_camp", -1.0, 0.7)
	await hud.say("SPK_DEFENDER", "D25B_S_2")
	await hud.say("SPK_TOLGA", "D25B_T_2")
	var target := Node3D.new()
	add_child(target)
	target.global_position = Vector3(0.0, 8.0, 330.0)
	Lore.scatter(self, "25")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ25B_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege25")
	hud.add_child(cam)
	cam.max_dist = 600.0
	cam.cone_deg = 25.0
	cam.taken.connect(func(path: String): _photo = path)
	var skip: bool = GameState.autotest and GameState.autotest_variant == "caught"
	if not skip:
		cam.start()
	var t := 0.0
	while not cam.done and not skip and t < (3.0 if GameState.autotest else 45.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	_heard_all = cam.done
	await hud.say("SPK_TOLGA", "D25B_T_3")
	await hud.say("SPK_NIHAT", "D25B_N_2")


## Osmanlı tarafı: 28 Mayıs gecesi ordugâh. Oruç açılmış, kandiller sönmüş; yarın hücum. Hasan ateş başında.
func _vigil() -> void:
	await hud.fade_to(1.0, 0.8)
	if tray:
		tray.queue_free()
		tray = null
	await hud.card([[tr("UI_CH25O_VIGIL"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	var fire := Vector3(-4.0, 0, 9.0)
	var hasan := Person.new({"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")})
	hasan.set_meta("spk", "SPK_HASAN")
	hasan.position = _gy(fire + Vector3(1.3, 0, -0.6))
	var d := fire - hasan.position
	hasan.rotation.y = atan2(d.x, d.z)
	add_child(hasan)
	hasan.set_activity("sit_ground")
	player.global_position = _gy(fire + Vector3(-1.4, 0, 1.2)) + Vector3(0, 0.05, 0)
	player.face(hasan.global_position + Vector3(0, 0.9, 0))
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D25O_N_VIGIL")
	await hud.say("SPK_HASAN", "D25O_H_1")
	await hud.say("SPK_TOLGA", "D25O_T_1")
	await hud.say("SPK_HASAN", "D25O_H_2")
	var c := await hud.choose(["UI_C25O_LEB", "UI_C25O_WATER", "UI_C25O_SIT"], 0.0, 2)
	if c == 0 and "chickpeas" in GameState.bag:
		await hud.say("SPK_TOLGA", "D25O_T_LEB")
		await hud.say("SPK_HASAN", "D25O_H_LEB")
	elif c == 1:
		await hud.say("SPK_TOLGA", "D25O_T_WATER")
		await hud.say("SPK_HASAN", "D25O_H_WATER")
	else:
		await hud.say("SPK_TOLGA", "D25O_T_SIT")
		await hud.say("SPK_HASAN", "D25O_H_SIT")
	await hud.say("SPK_HASAN", "D25O_H_3")
	await hud.say("SPK_TOLGA", "D25O_T_END")
	await hud.say("SPK_NIHAT", "D25O_N_END")
	_outcome = "25.1" if _heard_all else "25.2"
	GameState.flags["siege_vigil"] = c
	Siege.record(25, _photo, "SIEGE_NOTE_25O_%s" % _outcome.split(".")[1])


## 28 Mayıs akşamı, Ayasofya: son ayin. Rum ve Latin birlikte. İmparator helallik ister.
func _liturgy() -> void:
	await hud.fade_to(1.0, 1.0)
	if tray:
		tray.queue_free()
		tray = null
	if day:
		day.queue_free()
		day = null
	if walls:
		Garrison.clear(get_tree())
		walls.queue_free()
		walls = null
	if _night:
		_night.queue_free()
		_night = null
	guards.clear()
	await get_tree().process_frame
	Audio.ambience("")          # Ayasofya: ayin sessizliği
	city = ByzCity.new()
	add_child(city)
	city.niko.visible = false
	city.emperor.visible = false
	city.make_sunset()
	hud.set_fez(false)
	var rng := RandomNumberGenerator.new()
	rng.seed = 528
	# Isidore kürsünün (ambon) sağ önünde: kapıdaki Tolga'dan görünür, İmparator'la arasına girmez
	var isi_pos := AYA + Vector3(4.5, 0, 0.5)
	# Cemaat ızgarada (1 m arayla, hafif kayık): birbirinin içinde durmasın; ambonun (orta, z -1.9..-0.1) ve Tolga ile
	# Isidore arasındaki görüşün (sağ ön çeyrek) dışında
	var spots: Array[Vector3] = []
	for gz in range(-6, 5):
		for gx in range(-6, 7):
			var sp := Vector3(gx * 1.0 + rng.randf_range(-0.15, 0.15), 0, gz * 1.0 + rng.randf_range(-0.15, 0.15))
			if absf(sp.x) < 1.9 and sp.z > -2.7 and sp.z < 0.7:
				continue
			if sp.x > 0.0 and sp.z > -0.5:
				continue
			if sp.distance_to(isi_pos - AYA) < 1.3:
				continue
			spots.append(sp)
	for k in range(spots.size() - 1, 0, -1):
		var j := rng.randi_range(0, k)
		var tmp := spots[k]
		spots[k] = spots[j]
		spots[j] = tmp
	for i in 22:
		var latin := i % 4 == 0
		var p := Person.new({"coat": ([Color("5a3a2a"), Color("3a4a5a"), Color("6a5a4a"), Color("4a3a4a")][i % 4]) if not latin else Color("2a3a6a"),
			"pants": Color("2a2a2a"), "skirt": i % 3 == 1, "hat": "berretta" if latin else "none", "hair": Color("3a2a1e"),
			"beard": i % 5 == 0, "mustache": i % 2 == 0})
		p.set_meta("no_talk", true)
		p.position = AYA + spots[i]
		p.rotation.y = PI + rng.randf_range(-0.3, 0.3)
		add_child(p)
	var isidore := Person.new({"coat": Color("b3262d"), "robe": Color("b3262d"), "hat": "galero", "face": "cardinal", "beard": true,
		"hair": Color("e8e8e8"), "skin": Color("e8c0a0")})
	isidore.position = isi_pos
	isidore.rotation.y = atan2(-8.5, 8.5)
	add_child(isidore)
	isidore.look_target = player
	# Mumluk: kum dolu tepsi, yanan ince mumlar; bir tane boş yer
	var stand := AYA + Vector3(-5.5, 0, 7.5)
	Props.cyl(self, 0.05, 1.0, stand + Vector3(0, 0.5, 0), Color("c8a040"), Vector3.ZERO, 6)
	Props.cyl(self, 0.5, 0.08, stand + Vector3(0, 1.02, 0), Color("c8a040"), Vector3.ZERO, 16)
	for k in 9:
		var a := k * TAU / 9.0
		var cp := stand + Vector3(sin(a) * 0.35, 1.15, cos(a) * 0.35)
		Props.cyl(self, 0.012, 0.2, cp, Color("f4ecd0"), Vector3.ZERO, 5)
		var fl := Props.ball(self, 0.02, cp + Vector3(0, 0.12, 0), Color("ffc860"), Vector3(1, 1.6, 1), 5, 3.0)
		fl.material_override = Props.mat(Color("ffc860"), 3.0, false, "", false)
	var cl := OmniLight3D.new()
	cl.position = stand + Vector3(0, 1.5, 0)
	cl.light_color = Color("ffc070")
	cl.light_energy = 1.2
	cl.omni_range = 5.0
	add_child(cl)
	Props.interactable(self, "candle", Vector3(1.2, 1.4, 1.2), stand + Vector3(0, 1.0, 0))
	emperor = Person.new({"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "stemma", "face": "emperor", "beard": true,
		"mustache": true, "hair": Color("6a6a6a"), "robe": Color("5a2a6a")})
	emperor.position = AYA + Vector3(0, 0, 16.0)
	emperor.rotation.y = PI
	add_child(emperor)
	player.global_position = AYA + Vector3(-4.0, 0.05, 9.0)
	player.face(AYA + Vector3(0, 5.0, -8.0))
	await hud.card([[tr("UI_CH25_AYA"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 1.5)
	Audio.sfx("church_bell", -8.0, 0.7)
	await hud.say("SPK_NIHAT", "D25_N_AYA")
	await hud.say("SPK_TOLGA", "D25_T_AYA")
	# İmparator girer, ortaya yürür
	var tw := create_tween()
	tw.tween_property(emperor, "position", AYA + Vector3(0, 0, 4.0), 5.0)
	await tw.finished
	player.face(emperor.global_position + Vector3(0, 1.6, 0))
	emperor.talking = true
	await hud.say("SPK_EMPEROR", "D25_K_1")
	await hud.say("SPK_EMPEROR", "D25_K_2")
	emperor.talking = false
	await hud.say("SPK_ISIDORE", "D25_I_1")
	player.face(isidore.global_position + Vector3(0, 1.6, 0))
	await hud.say("SPK_NIHAT", "D25_N_ISI")      # kim olduğu: Bölüm 26'da esir kafilesinde yeniden görülür
	GameState.flags["met_isidore"] = true
	# Mum: isteğe bağlı
	Lore.scatter(self, "25")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ25_CANDLE"), stand + Vector3(0, 1.4, 0))
	var t := 0.0
	if GameState.autotest:
		_on_interact("candle")
	while not candle_lit and t < 30.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	player.frozen = true
	hud.set_objective("")
	hud.set_prompt("")
	var out := create_tween()
	out.tween_property(emperor, "position", AYA + Vector3(0, 0, 20.0), 5.0)
	await hud.say("SPK_TOLGA", "D25_T_EMPEROR")
	if out.is_running():   # replik uzun okunduysa hareket çoktan bitmiştir (bitmiş tweeni beklemek sonsuza dek takılır)
		await out.finished
	emperor.visible = false
	await hud.say("SPK_NIHAT", "D25_N_END")
	_outcome = "25.1" if _heard_all else "25.2"
	GameState.flags["siege_candle"] = candle_lit
	Siege.record(25, _photo, ("SIEGE_NOTE_25B_%s" if byz else "SIEGE_NOTE_25_%s") % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	if day == null:
		return
	_place_guards(delta)
	if phase != "listen":
		return
	_cool = maxf(0.0, _cool - delta)
	if _cool <= 0.0 and _seen():
		_caught_once()
		return
	var near := _at_wall()
	hud.set_prompt(tr("UI_PROMPT25_LISTEN") if near else "")
	if near:
		_listen += delta
		hud.set_chase(tr("UI_CH25_LISTEN"), _listen / LISTEN_TIME)
		var want := int(_listen / LISTEN_TIME * COUNCIL.size())
		if want > _line and _line < COUNCIL.size():
			hud.bark(COUNCIL_SPK[_line], COUNCIL[_line], 4.2)
			_line += 1
		if _listen >= LISTEN_TIME:
			_heard_all = true
			phase = "listened"


func _on_focus(id: String) -> void:
	match id:
		"otag_door":
			hud.set_prompt(tr("UI_PROMPT25_TRAY") if phase == "tray" else "")
		"candle":
			hud.set_prompt(tr("UI_PROMPT25_CANDLE") if not candle_lit else "")
		_:
			if phase != "listen":
				hud.set_prompt("")


func _on_interact(id: String) -> void:
	match id:
		"otag_door":
			if phase != "tray":
				return
			if tray:
				tray.queue_free()
				tray = null
			hud.bark("SPK_SOLDIER", "D25_G_TRAY", 3.0)
			phase = "delivered"
		"candle":
			if candle_lit:
				return
			candle_lit = true
			player.hand_gesture("reach")
			var fl := Props.ball(self, 0.025, AYA + Vector3(-5.5, 2.27, 7.5), Color("ffc860"), Vector3(1, 1.6, 1), 5, 3.0)
			fl.material_override = Props.mat(Color("ffc860"), 3.0, false, "", false)
			Props.cyl(self, 0.012, 0.2, AYA + Vector3(-5.5, 2.15, 7.5), Color("f4ecd0"), Vector3.ZERO, 5)
			hud.bark("SPK_TOLGA", "D25_T_CANDLE", 3.0)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(25, _outcome)
	await Siege.show_page(hud, 25)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(25)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW25_TITLE")
	c.nodes = [
		{"id": "tray", "key": "FLOW25B_WALL" if byz else "FLOW25_TRAY", "pos": Vector2(0.5, 0.12)},
		{"id": "25.1", "key": "FLOW_25B_1" if byz else "FLOW_25_1", "pos": Vector2(0.3, 0.32), "outcome": true},
		{"id": "25.2", "key": "FLOW_25B_2" if byz else "FLOW_25_2", "pos": Vector2(0.7, 0.32), "outcome": true},
		{"id": "liturgy", "key": "FLOW25O_VIGIL" if GameState.flags.has("siege_vigil") and Siege.side() == "O" else "FLOW25_LITURGY", "pos": Vector2(0.5, 0.52)},
		{"id": "candle", "key": "FLOW25_CANDLE", "pos": Vector2(0.5, 0.68)},
	]
	c.edges = [["tray", "25.1"], ["tray", "25.2"], ["25.1", "liturgy"], ["25.2", "liturgy"], ["liturgy", "candle"]]
	for k in ["tray", "liturgy", _outcome]:
		c.taken[k] = true
	if candle_lit:
		c.taken["candle"] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH25_STATS") % [caught, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "25.1", "caught": "25.2", "osm": "25.1", "osm_caught": "25.2"}.get(v, "25.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("25", {})
	# Bizans tarafında "caught" = ışıklar kayda geçmedi (tespit karesi çekilmez)
	var shot_ok: bool = cam != null and (cam.done or (byz and v == "caught"))
	var ok: bool = _outcome == expected and not page.is_empty() and shot_ok and (candle_lit or v.begins_with("osm"))
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=25 variant=%s outcome=%s caught=%d candle=%s" % ["PASS" if ok else "FAIL", v, _outcome, caught, candle_lit])
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
	phase = "listen"
	player.global_position = _gy(OTAG + Vector3(2.0, 0, -LISTEN_R - 0.3)) + Vector3(0, 0.05, 0)
	await get_tree().create_timer(0.8).timeout
	player.face(guards[0].global_position + Vector3(0, 1.4, 0))
	hud.set_chase(tr("UI_CH25_LISTEN"), 0.45)
	hud.bark("SPK_ZAGANOS", "D25_Z_1", 30.0)
	await _shot("c25_01_listen.png")
	phase = "shots"
	hud.set_chase("", 0.0)
	player.global_position = _gy(OTAG + Vector3(4.0, 0, 18.0)) + Vector3(0, 0.05, 0)
	player.face(Vector3(0.0, 4.0, 20.0))
	await _shot("c25_02_lights.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = _gy(OTAG + Vector3(10.0, 0, 22.0)) + Vector3(0, 5.0, 0)
	cv.look_at(_gy(OTAG) + Vector3(0, 4.0, 0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c25_cover.png")
	get_tree().quit()
