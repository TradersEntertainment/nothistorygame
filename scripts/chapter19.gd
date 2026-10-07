extends Node3D
## Bölüm 19 — Brigantin (Tolga · 3 Mayıs gecesi → 23 Mayıs 1453). docs/SIEGE.md §3.
##
## Türk kılığına girmiş küçük bir gemi (on iki kişi, sarık ve Osmanlı sancağı) gece Haliç'ten çıkar; Venedik
## donanmasını aramaya gider (Barbaro). Ege'de yirmi gün: tek yelken yok. Tayfa oylar: kaçıp kurtulmak mı, şehre
## dönmek mi? Tarihte döndüler; döneriz. Tolga'nın oyu yalnız kendi sayfasını değiştirir.
## Oynanış: zincirin açıklığından çıkış; bir Osmanlı devriye kayığı yanaşır: Tolga "tercüman" olur (seçim).
## Ege: güverte serbest; boş ufkun karesi (tespit). Şafakta oylama. 23 Mayıs gecesi Haliç'e dönüş.
##   19.1 Dönmek için oy · 19.2 Kaçmak için oy (tayfa yine döner)
##   Sultan'ın tezkiresi cepteyse (Bölüm 12) devriyeye tuğra gösterilebilir: şüphe doğmaz, ama tayfa da görür
##   (brig_tezkire: oylama, dönüş ve Bölüm 27'de Galata rıhtımı).
##   Bölüm 17'de Haliç'te sudan çekilen denizcilerden biri bu tayfadadır (siege_saved): oylamada dönmekten yana konuşur.
##   Dallanma v3: 20 Nisan'da (29) imparatorluğun tahıl gemisinde olan tayfa Tolga'yı Cattaneo'nun güvertesinden
##   hatırlar. Gemi bütün girdiyse (29.1) oyu Tolga'nınkini izler; yaralı girdiyse (29.2) Tolga'nın oyunu yarım sayar.
##   --autotest[=flee|tezkire|saved|ship_ok|ship_bad|ship_ok_flee]   (varsayılan: 19.1; ship_ok: 29.1, ship_bad: 29.2)

const PATH := [Vector3(-12, 0, 10), Vector3(-4, 0, 30), Vector3(6, 0, 40), Vector3(26, 0, 52), Vector3(70, 0, 62)]
const PATROL_AT := 0.62
const DECK_Y := 1.0

var walls: SeaWalls
var _fez_was_on := true
var sea: Node3D
var player: Player
var hud: Hud
var ship: Node3D
var crew: Array[Person] = []
var captain: Person
var patrol: Node3D
var patrol_reis: Soldier
var _patrol_rowers: Array = []
var phase := "intro"
var _outcome := ""
var _d := 0.0
var _total := 0.0
var _suspicion := 0
var _tezkire := false          # devriyeye Sultan'ın tezkiresi gösterildi
var _saved_aboard := false     # Bölüm 17'de sudan çekilen denizci tayfada
var _vote := 0
var _grain := 0               # 20 Nisan (29): 1 tahıl gemisinin tayfası Tolga'nın oyunu izler, −1 yarım sayar
var _photo := ""
var cam: TespitCam
var horizon: Node3D
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(19)
	if GameState.autotest and GameState.autotest_variant == "captive18":
		GameState.flags["siege_captive_18"] = true       # 17.3 → 18 (Osmanlı, esir) → buraya dönüş
	if GameState.autotest and GameState.autotest_variant == "tezkire":
		GameState.pocket_add("tezkire", "tezkire_12")
	if GameState.autotest and GameState.autotest_variant == "saved":
		GameState.flags["siege_saved"] = 3            # Bölüm 17: üç denizci de kurtarıldı
	if GameState.autotest and GameState.autotest_variant.begins_with("ship_"):
		GameState.chapter_outcomes[29] = "29.2" if GameState.autotest_variant == "ship_bad" else "29.1"
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	# Gemi Türk kılığında: fes takılır (Nihat'ın brifingi takılmadan önceki duruma göre konuşur)
	_fez_was_on = GameState.flags.get("fez", true)
	hud.set_fez(true)
	GameState.flags["fez"] = true
	hud.set_signal(0)
	for i in PATH.size() - 1:
		_total += (PATH[i] as Vector3).distance_to(PATH[i + 1])
	walls = SeaWalls.new()
	walls.in_world = true
	add_child(walls)
	_build_ship()
	_build_patrol()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


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


func _place_ship(d: float) -> void:
	var at: Array = _along(d)
	var p: Vector3 = at[0]
	ship.global_position = p + Vector3(0, sin(_t * 1.1) * 0.06, 0)
	ship.look_at(p + (at[1] as Vector3), Vector3.UP)
	ship.rotation.z = sin(_t * 0.8) * 0.03


## Brigantin: dar gövde, iki direk, Latin yelkenleri, direkte Osmanlı sancağı (kılık), sarıklı tayfa.
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
	var deck := Props.solid(ship, Vector3(3.0, 0.2, 10.5), Vector3(0, DECK_Y - 0.1, -0.5), Color("a8845a"))
	deck.get_child(0).visible = false
	Props.box(ship, Vector3(3.0, 0.08, 10.5), Vector3(0, DECK_Y - 0.03, -0.5), Color("a8845a"))
	for s in [-1.0, 1.0]:
		Props.solid(ship, Vector3(0.12, 0.6, 10.0), Vector3(s * 1.5, DECK_Y + 0.3, -0.5), Color("5a3e26")).set_meta("no_climb", true)
	for z: float in [-5.6, 4.6]:
		Props.solid(ship, Vector3(3.0, 0.6, 0.12), Vector3(0, DECK_Y + 0.3, z), Color("5a3e26")).set_meta("no_climb", true)
	# Küpeşteden (0,6 m) zıplayıp denize atlanmasın: üstünde görünmez sınır (denizin çarpışması yok, düşen suyun
	# içinden boşluğa iniyordu)
	for spec: Array in [[Vector3(0.12, 1.2, 10.0), Vector3(-1.5, 0, -0.5)], [Vector3(0.12, 1.2, 10.0), Vector3(1.5, 0, -0.5)],
			[Vector3(3.0, 1.2, 0.12), Vector3(0, 0, -5.6)], [Vector3(3.0, 1.2, 0.12), Vector3(0, 0, 4.6)]]:
		var g := Props.solid(ship, spec[0], (spec[1] as Vector3) + Vector3(0, DECK_Y + 1.2, 0), Color.WHITE)
		g.get_child(0).visible = false
		g.set_meta("no_climb", true)
	for spec in [[Vector3(0, 0, -2.0), 8.0], [Vector3(0, 0, 2.2), 6.5]]:
		var mp: Vector3 = spec[0]
		var h: float = spec[1]
		Props.cyl(ship, 0.1, h, mp + Vector3(0, DECK_Y + h * 0.5, 0), Color("5a3e26"), Vector3.ZERO, 6)
		Props.cyl(ship, 0.06, h * 1.1, mp + Vector3(0, DECK_Y + h * 0.7, 0.2), Color("6a4a2c"), Vector3(55, 0, 0), 5)
		# Yelken baş hizasının üstünde (alt kenarı güverteden ~2.6 m yukarıda): güvertede konuşanları örtmesin
		Props.box(ship, Vector3(0.04, h * 0.55, h * 0.55), mp + Vector3(0.12, DECK_Y + h * 0.68, 0.9), Color("e8dcc0"), Vector3(-20, 0, 0))
		Props.box(ship, Vector3(0.04, 0.8, 1.3), mp + Vector3(0, DECK_Y + h + 0.4, 0.6), Color("b3262d"))
		Props.crescent(ship, mp + Vector3(0, DECK_Y + h + 0.4, 0.55), 0.22, Color("b3262d"))
	# Tayfa: sarıklı (kılık); kaptan kıçta
	for i in 5:
		var c := Person.new({"coat": [Color("6a5040"), Color("5a6a7a"), Color("7a4a3a"), Color("8a7a5a"), Color("4a4a5a")][i], "pants": Color("3a3028"),
			"hat": "turban", "beard": i % 2 == 0, "mustache": true})
		c.set_meta("no_talk", true)
		c.position = Vector3(-0.8 + (i % 2) * 1.6, DECK_Y, -4.2 + i * 1.2 if i < 4 else 1.8)   # beşincisi oyuncunun koltuğunda (z 0,5) değil, arkasında
		ship.add_child(c)
		crew.append(c)
	captain = Person.new({"coat": Color("2a3a6a"), "pants": Color("2a2226"), "hat": "turban", "beard": true, "mustache": true, "skin": Color("dcae88"),
		"face": {"nose": "long", "brow": 1.2, "beard": "short", "head": Vector3(1.0, 1.05, 1.0)}})
	captain.set_meta("spk", "SPK_BRIG")
	# Kıçta, sancak yanında: koltuktan (x −0,7, z 0,5) bakınca kıç direği (x 0, z 2,2) tam önüne gelmesin
	captain.position = Vector3(1.1, DECK_Y, 3.8)
	captain.rotation.y = PI
	ship.add_child(captain)


func _build_patrol() -> void:
	patrol = Node3D.new()
	add_child(patrol)
	# Osmanlı devriye kayığı: uzun, dar, kıç yüksek; kara gövde, kırmızı küpeşte; iki çift kürekçi
	patrol.add_child(LowPoly.hull([
		{"z": -4.2, "w": 0.05, "top": 1.35, "bottom": 0.75},
		{"z": -3.2, "w": 0.7, "top": 1.1, "bottom": 0.1},
		{"z": -1.2, "w": 1.05, "top": 1.0, "bottom": -0.15},
		{"z": 1.0, "w": 1.05, "top": 1.0, "bottom": -0.15},
		{"z": 2.8, "w": 0.8, "top": 1.1, "bottom": 0.05},
		{"z": 3.7, "w": 0.35, "top": 1.3, "bottom": 0.5},
	], Color("3a2a1c"), Color("7e2420"), 0.9))
	for k in 2:
		var tz := -0.6 + k * 1.4
		Props.box(patrol, Vector3(1.9, 0.07, 0.28), Vector3(0, 0.62, tz), Color("5a4028"))
		var rower := Person.new({"coat": [Color("b3262d"), Color("6a4a3a")][k], "pants": Color("e8e0d0"), "hat": "turban",
			"mustache": true, "skin": Color("d9a07a")})
		rower.set_meta("no_talk", true)
		rower.position = Vector3(0, 0.4, tz)
		patrol.add_child(rower)
		rower.rotation.y = 0.0
		rower.set_activity("row")             # Person.activity da: denetçi kürekte oturanı ayakta gömülü saymasın
		rower.rig.row_phase = Rig.ROW_REST          # bordada dururken kürek başında bekler
		_patrol_rowers.append(rower)
		# Her ele bir kürek; ıskarmoz kürekçinin yarım metre kıç tarafında (OarGrip: kürek elden çıkmaz)
		var pair: Array = []
		for sx: float in [-1.0, 1.0]:
			pair.append([OarGrip.make_oar(patrol, Vector3(sx * 0.95, 1.0, tz + 0.5), sx, 0.85, 2.0, 0.035, Vector2(0.5, 0.18), 0.12), "auto"])
		OarGrip.attach(rower, pair)
	patrol_reis = Soldier.new(Color("2f5fa8"), "stand", "bork")
	patrol_reis.set_meta("spk", "SPK_PATROL")
	patrol_reis.position = Vector3(0, 0.6, -1.5)
	patrol.add_child(patrol_reis)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.2, -2.0)
	lamp.light_color = Color("ffb060")
	lamp.light_energy = 2.0
	lamp.omni_range = 10.0
	patrol.add_child(lamp)
	var lm := Props.ball(patrol, 0.18, Vector3(0, 2.0, -2.0), Color("ffb040"), Vector3.ONE, 6, 3.0)
	lm.material_override = Props.mat(Color("ffb040"), 3.0, false, "", false)
	patrol.position = Vector3(45, 0, 70)
	patrol.visible = false


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH19_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH19_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	_place_ship(0.0)
	player.pinned = true
	player.show_remote(false)
	_seat()
	player.face(ship.global_position + (-ship.global_transform.basis.z) * 20.0 + Vector3(0, 1.0, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D19_N_01" if _fez_was_on else "D19_N_01_NOFEZ")
	# Kaza rotasından dönüş (17.3 → 18): Türklerin köprüsünde fıçı taşıyan Tolga'yı tayfa görmüştü
	if GameState.flags.get("siege_captive_18", false):
		_captive_back = true
		await hud.say("SPK_BRIG", "D19_C_01_CAPTIVE")
		await hud.say("SPK_TOLGA", "D19_T_01_CAPTIVE")
	else:
		await hud.say("SPK_BRIG", "D19_C_01")
		await hud.say("SPK_TOLGA", "D19_T_01")
	await hud.say("SPK_BRIG", "D19_C_02")
	hud.set_objective(tr("UI_OBJ19_SAIL"))
	player.frozen = false
	phase = "sail"
	while _d < _total * PATROL_AT:
		await get_tree().process_frame
	await _patrol_scene()
	phase = "sail2"
	while _d < _total - 1.0:
		await get_tree().process_frame
	await _aegean()
	await _vote_scene()
	await _return()
	await _end_chapter()


func _seat() -> void:
	if player.pinned:
		player.eye_height = Player.EYE
		player.global_position = ship.to_global(Vector3(-0.7, DECK_Y + 0.05, 0.5))   # iki direk arası: kıç yelkenin (alt kenarı ~2,1–2,7 m, z 2–5,4) altında değil


func _patrol_scene() -> void:
	phase = "patrol"
	player.frozen = true
	hud.set_objective("")
	patrol.visible = true
	# Devriye kayığı oyuncunun oturduğu bordaya (sola) yanaşır; kaptan oyuncunun yanına geçer (araya girmesin),
	# reis fenerin ışığında oyuncuya bakar
	patrol.global_position = ship.to_global(Vector3(-5.2, 0, -0.5))
	patrol.global_position.y = 0.0
	var fwd := -ship.global_transform.basis.z * Vector3(1, 0, 1)
	patrol.look_at(patrol.global_position + fwd.normalized(), Vector3.UP)      # bordaya paralel
	patrol_reis.look_target = player
	captain.position = Vector3(0.6, DECK_Y, 0.9)
	captain.look_target = patrol_reis
	player.face(patrol_reis.global_position + Vector3(0, 1.5, 0))
	Audio.sfx("radio_beep", -12.0)
	await hud.say("SPK_PATROL", "D19_P_01")
	await hud.say("SPK_BRIG", "D19_C_WHISPER")
	var opts := ["UI_C19_SALAM", "UI_C19_INSURE", "UI_C19_SILENT"]
	# Sultan'ın tezkiresi cepteyse (Bölüm 12) dördüncü cevap: tuğrayı fenerin ışığına tutmak
	if GameState.in_pocket("tezkire"):
		opts.append("UI_C19_TEZKIRE")
	var c := await hud.choose(opts, 10.0, 3 if GameState.autotest_variant == "tezkire" else 0)
	match c:
		0:
			await hud.say("SPK_TOLGA", "D19_T_SALAM")
			await hud.say("SPK_PATROL", "D19_P_SALAM")
		1:
			_suspicion += 1
			await hud.say("SPK_TOLGA", "D19_T_INSURE")
			await hud.say("SPK_PATROL", "D19_P_INSURE")
		3:
			await _show_tezkire()
		_:
			_suspicion += 1
			await hud.say("SPK_BRIG", "D19_C_BROKEN")
			await hud.say("SPK_PATROL", "D19_P_BROKEN")
	# Kayık dönüp uzaklaşır (kürekle; reis kayıkta durur)
	var away := (patrol.global_position - ship.global_position) * Vector3(1, 0, 1)
	away = away.normalized()
	patrol_reis.look_target = null
	captain.look_target = null
	patrol.look_at(patrol.global_position + away, Vector3.UP)
	for r: Person in _patrol_rowers:
		r.rig.row_phase = -1.0                  # kendi temposuyla çekip uzaklaşırlar
	var tw := create_tween()
	tw.tween_property(patrol, "global_position", patrol.global_position + away * 30.0, 6.0)
	await hud.say("SPK_BRIG", "D19_C_PASSED")
	if _tezkire:
		# Devriye eğildi ama kaptan da gördü: Venedik gemisinin tercümanının cebinde Sultan'ın kâğıdı
		captain.look_target = player
		player.face(captain.global_position + Vector3(0, 1.6, 0))
		await hud.say("SPK_BRIG", "D19_C_TEZKIRE")
		await hud.say("SPK_TOLGA", "D19_T_TEZKIRE_2")
		await hud.say("SPK_BRIG", "D19_C_TEZKIRE_2")
		captain.look_target = null
	hud.set_objective(tr("UI_OBJ19_SAIL2"))
	player.frozen = false


## Tuğralı kâğıt fenere tutulur: reis eğilir, kayık yol verir. Şüphe doğmaz; ama tayfa da görür (brig_tezkire:
## oylamada, dönüşte Niko'ya rapor verilirken ve Galata rıhtımında anılır).
func _show_tezkire() -> void:
	_tezkire = true
	GameState.flags["brig_tezkire"] = true
	GameState.pocket_use("tezkire", "brigantine_19")
	player.show_prop("tezkire", 2.6)
	await hud.say("SPK_TOLGA", "D19_T_TEZKIRE")
	patrol_reis.emote("bow")
	await hud.say("SPK_PATROL", "D19_P_TEZKIRE")


func _aegean() -> void:
	phase = "aegean"
	hud.set_objective("")
	await hud.fade_to(1.0, 1.0)
	walls.queue_free()
	walls = null
	patrol.queue_free()
	await get_tree().process_frame
	_build_sea()
	ship.global_position = Vector3(0, 0, 0)
	ship.rotation = Vector3.ZERO
	player.pinned = false
	player.global_position = ship.to_global(Vector3(0.0, DECK_Y + 0.05, -5.0))
	player.face(Vector3(0, 1.0, -200.0))
	for key in ["UI_CH19_DAY_1", "UI_CH19_DAY_2", "UI_CH19_DAY_3"]:
		await hud.card([[tr(key), 26, Color("f2e6c9")]], 1.6)
		hud.clear_card()
	if is_instance_valid(captain):
		player.face(captain.global_position + Vector3(0, 1.6, 0))      # boş denizi anlatan kaptana dönük
	await hud.fade_to(0.0, 1.2)
	await hud.say("SPK_BRIG", "D19_C_EMPTY")
	await hud.say("SPK_TOLGA", "D19_T_EMPTY")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ19_PHOTO"), horizon.global_position)
	cam = TespitCam.new(player, hud, horizon, "siege19")
	hud.add_child(cam)
	cam.max_dist = 600.0
	cam.cone_deg = 14.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 45.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_NIHAT", "D19_N_EMPTY")


## Açık deniz: gündüz, adalar, boş ufuk (tespit hedefi).
func _build_sea() -> void:
	sea = Node3D.new()
	add_child(sea)
	var we := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3a7ac8")
	sm.sky_horizon_color = Color("d8e8f4")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.9
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	we.environment = e
	sea.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 150, 0)
	sun.light_energy = 1.2
	sea.add_child(sun)
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(1200, 1200)
	pm.subdivide_width = 100
	pm.subdivide_depth = 100
	w.mesh = pm
	var sh := ShaderMaterial.new()
	sh.shader = load("res://assets/shaders/water.gdshader")
	w.material_override = sh
	sea.add_child(w)
	var rng := RandomNumberGenerator.new()
	rng.seed = 19
	for i in 5:
		var a := rng.randf_range(0.6, 2.4) * (1.0 if i % 2 == 0 else -1.0)
		var r := rng.randf_range(160.0, 320.0)
		var p := Vector3(sin(a) * r, -2.0, cos(a) * r)
		Props.cyl(sea, rng.randf_range(20.0, 45.0), rng.randf_range(14.0, 30.0), p + Vector3(0, 6.0, 0), Color("8a9a6a"), Vector3.ZERO, 9, 0.35)
	horizon = Node3D.new()
	horizon.position = Vector3(0, 2.0, -400.0)
	sea.add_child(horizon)


func _vote_scene() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH19_VOTE"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	for i in crew.size():
		crew[i].position = Vector3(-1.0 + (i % 3) * 1.0, DECK_Y, -2.2 + (i / 3) * 1.4)
		crew[i].rotation.y = PI * 0.5 if i % 2 == 0 else -PI * 0.5
	# Oylamada konuşan iki tayfa ön sırada (kartta sarıklı kılıklarıyla görünürler)
	crew[3].set_meta("spk", "SPK_SAILOR")
	crew[4].set_meta("spk", "SPK_SAILOR2")
	# Direğin yanında (arkasında değil): kaptan direğin öbür yanında görünsün
	player.global_position = ship.to_global(Vector3(-1.1, DECK_Y + 0.05, 1.0))
	player.face(captain.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_BRIG", "D19_C_VOTE")
	await hud.say("SPK_SAILOR", "D19_S_FLEE")
	await hud.say("SPK_SAILOR2", "D19_S_RETURN")
	# 20 Nisan (29): "Venedik'e derim" diyen tayfa o gün tahıl gemisindeydi; Cattaneo'nun karakasına bağlıydılar.
	# Tezkireyi gördüyse (brig_tezkire) Tolga'yı kâğıttan tanır: o zaman 20 Nisan'ı anmaz.
	if not _tezkire:
		match Siege.outcome(29):
			"29.1":
				_grain = 1
				await hud.say("SPK_SAILOR", "D19_S_GRAIN_OK")
			"29.2":
				_grain = -1
				await hud.say("SPK_SAILOR", "D19_S_GRAIN_BAD")
	# Bölüm 17: 28 Nisan gecesi Haliç'te sudan çekilen Venedikli denizcilerden biri bu tayfada
	_saved_aboard = int(GameState.flags.get("siege_saved", 0)) > 0
	if _saved_aboard:
		await hud.say("SPK_SAILOR2", "D19_S2_SAVED")
	await hud.say("SPK_BRIG", "D19_C_ASK")
	if _tezkire:
		await hud.say("SPK_SAILOR", "D19_S_TEZKIRE")       # tuğralı kâğıdı gören tayfa oyu tartar
	var c := await hud.choose(["UI_C19_RETURN", "UI_C19_FLEE"], 0.0, 1 if GameState.autotest_variant.ends_with("flee") else 0)
	_vote = c
	await hud.say("SPK_TOLGA", "D19_T_RETURN" if c == 0 else "D19_T_FLEE")
	if _grain == 1:
		await hud.say("SPK_SAILOR", "D19_S_GRAIN_RETURN" if c == 0 else "D19_S_GRAIN_FLEE")
	elif _grain == -1:
		await hud.say("SPK_BRIG", "D19_C_GRAIN_HALF")
	if _tezkire:
		if c == 0:
			await hud.say("SPK_SAILOR2", "D19_S2_TEZKIRE_RETURN")
		else:
			await hud.say("SPK_SAILOR", "D19_S_TEZKIRE_FLEE")
	await hud.say("SPK_BRIG", "D19_C_DECIDED")
	if c == 1:
		await hud.say("SPK_TOLGA", "D19_T_ASHAMED")


func _return() -> void:
	await hud.fade_to(1.0, 1.0)
	sea.queue_free()
	sea = null
	await get_tree().process_frame
	walls = SeaWalls.new()
	walls.in_world = true
	add_child(walls)
	ship.global_position = Vector3(-10.0, 0, 5.0)
	ship.rotation.y = PI * 0.5
	walls.niko.position = Vector3(-10.2, SeaWalls.QUAY_Y, -0.7)     # kulenin (x -9..-3) önünde değil, yanında
	walls.niko.look_target = player
	player.global_position = ship.to_global(Vector3(0.0, DECK_Y + 0.05, 0.0))
	player.face(walls.niko.global_position + Vector3(0, 1.5, 0))
	await hud.card([[tr("UI_CH19_BACK"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIKO", "D19_NK_01")
	await hud.say("SPK_BRIG", "D19_C_REPORT")
	if _tezkire:
		await hud.say("SPK_BRIG", "D19_C_REPORT_TEZKIRE")
		await hud.say("SPK_NIKO", "D19_NK_TEZKIRE")
	await hud.say("SPK_NIKO", "D19_NK_02")
	await hud.say("SPK_NIHAT", "D19_N_END_TEZKIRE" if _tezkire else "D19_N_END")
	_outcome = "19.1" if _vote == 0 else "19.2"
	GameState.flags["brig_vote"] = _vote
	Siege.record(19, _photo, "SIEGE_NOTE_19_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	if ship == null:
		return
	match phase:
		"sail", "sail2", "brief":
			_d = minf(_d + delta * (7.0 if GameState.autotest else 3.6), _total)
			_place_ship(_d)
			_seat()
		"patrol":
			_seat()
		"aegean":
			ship.global_position.y = sin(_t * 1.1) * 0.08
			ship.rotation.z = sin(_t * 0.8) * 0.03


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
	c.title_text = tr("UI_FLOW19_TITLE")
	c.nodes = [
		{"id": "out", "key": "FLOW19_OUT", "pos": Vector2(0.5, 0.12)},
		{"id": "empty", "key": "FLOW19_EMPTY", "pos": Vector2(0.5, 0.3)},
		{"id": "19.1", "key": "FLOW_19_1", "pos": Vector2(0.3, 0.5), "outcome": true},
		{"id": "19.2", "key": "FLOW_19_2", "pos": Vector2(0.7, 0.5), "outcome": true},
	]
	c.edges = [["out", "empty"], ["empty", "19.1"], ["empty", "19.2"]]
	for k in ["out", "empty", _outcome]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH19_STATS") % [_suspicion, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Kaza rotasından dönüş (siege_captive_18): kaptan Tolga'yı Türklerin köprüsünden tanır
var _captive_back := false


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "19.1", "flee": "19.2", "ship_ok_flee": "19.2"}.get(v, "19.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("19", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	# Tezkire yalnız cepteyken seçenek olur: gösterilince şüphe doğmaz, bayrak Galata'ya taşınır
	ok = ok and _tezkire == (v == "tezkire") and GameState.flags.get("brig_tezkire", false) == _tezkire
	ok = ok and _saved_aboard == (v == "saved") and _captive_back == (v == "captive18")
	ok = ok and _grain == {"ship_ok": 1, "ship_ok_flee": 1, "ship_bad": -1}.get(v, 0)
	if v == "tezkire":
		ok = ok and _suspicion == 0 and GameState.last_use("tezkire") == "brigantine_19"
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=19 variant=%s outcome=%s suspicion=%d tezkire=%s saved=%s grain=%d" % ["PASS" if ok else "FAIL", v, _outcome,
		_suspicion, _tezkire, _saved_aboard, _grain])
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
	_d = _total * PATROL_AT
	_place_ship(_d)
	player.pinned = true
	phase = "patrol"
	_seat()
	patrol.visible = true
	for r: Person in _patrol_rowers:
		r.rig.row_phase = Rig.ROW_REST
	var at: Array = _along(_d)
	var side := (at[1] as Vector3).cross(Vector3.UP).normalized()
	patrol.global_position = ship.global_position + side * 5.5 + (at[1] as Vector3) * 3.0
	patrol.look_at(ship.global_position, Vector3.UP)
	await get_tree().create_timer(0.6).timeout
	player.face(patrol_reis.global_position + Vector3(0, 1.5, 0))
	hud.bark("SPK_PATROL", "D19_P_01", 30.0)
	await _shot("c19_01_patrol.png")
	hud.bark("SPK_PATROL", "", 0.01)
	phase = "aegean"
	walls.queue_free()
	walls = null
	patrol.queue_free()
	await get_tree().process_frame
	_build_sea()
	ship.global_position = Vector3.ZERO
	ship.rotation = Vector3.ZERO
	player.pinned = false
	player.global_position = ship.to_global(Vector3(0.0, DECK_Y + 0.05, -5.0))
	await get_tree().create_timer(0.5).timeout
	player.face(Vector3(0, 1.0, -200.0))
	await _shot("c19_02_empty.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(9.0, 4.0, 12.0)
	cv.look_at(Vector3(0, 3.0, -2.0), Vector3.UP)
	cv.fov = 55.0
	cv.make_current()
	await _shot("c19_cover.png")
	get_tree().quit()
