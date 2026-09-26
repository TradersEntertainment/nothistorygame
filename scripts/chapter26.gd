extends Node3D
## Bölüm 26 — Şafak (Tolga · 29 Mayıs 1453). docs/SIEGE.md §3. Perde IV'ün son bölümü ve kapanışı.
##
## Gece 01.30'da son hücum üç dalga halinde gelir (Barbaro, Kritovoulos): azaplar, Anadolu askeri, yeniçeriler.
## Tolga Mesoteichion'da Giustiniani'nin adamlarına yardım eder:
##   1. dalga: kuyudan gediğe su taşır · 2. dalga: Urban'ın topu barikatı yıkar, Tolga yeniden örer (top uyarısı) ·
##   3. dalga: Giustiniani yaralanır; Tolga poterna yolundaki fıçıları çeker, adamları onu gemiye taşır.
## Burçta sancak (Ulubatlı Hasan; uzaktan, saygıyla), İmparator'un son görüntüsü (arkası dönük, dumana yürür).
## Öğleden sonra Fatih Ayasofya'ya girer, taşa zarar veren bir askeri durdurur. Son kare: çekilir ya da çekilmez.
## Kapanış (Çarşamba): Nihat dosyayı imzalar; ofiste müdür hafta sonunu sorar.
##   26.1 Son kare çekildi · 26.2 Son kare çekilmedi ("bazı şeyler tanıkla kaydedilir")
##   --autotest[=nophoto]   (varsayılan: 26.1)

const WELL := LandWalls.DEPOT + Vector3(-4.2, 0.0, 1.6)
const POSTERN := Vector3(LandWalls.DEPOT.x + 3.5, 0.0, LandWalls.INNER_Z1 + 0.6)
const BLOCKS := [Vector3(12.6, 0.0, 3.2), Vector3(14.6, 0.0, 2.2)]
const BANNER_TOWER := Vector3(16.0, LandWalls.OUTER_H + 3.0, LandWalls.OUTER_Z1 + 1.0)
const AYA := Vector3(-14.0, 0.0, -82.0)

var walls: LandWalls
var city: ByzCity
var bureau: Bureau
var monday: Monday
var player: Player
var hud: Hud
var giust: Person
var emperor: Person
var bearers: Array[Person] = []
var defenders: Array[Person] = []
var attackers: Array[Node3D] = []
var ladders: Array[Node3D] = []
var banner: Node3D
var fatih: Person
var axeman: Node3D
var phase := "intro"
var _outcome := ""
var water := 0
var repaired := 0
var carrying := ""
var _carry: Node3D
var _cleared := 0
var _gun_t := 99.0
var _warn := false
var _knocks := 0
var _photo := ""
var cam: TespitCam
var _t := 0.0
var _fx_t := 0.0


func _ready() -> void:
	GameState.snapshot(26)
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	walls = LandWalls.new()
	add_child(walls)
	walls.set_repair(LandWalls.STAGES)
	_build_walls_scene()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build_walls_scene() -> void:
	giust = Person.new({"face": "giustiniani", "coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero",
		"beard": true, "skin": Color("e0b08a")})
	giust.position = LandWalls.BREACH + Vector3(-1.8, 0, -2.6)
	add_child(giust)
	giust.look_target = player
	for i in 6:
		var d := Person.new({"coat": [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96")][i % 3], "pants": Color("3a2a22"), "hat": "helm",
			"beard": i % 2 == 0, "mustache": true})
		d.set_meta("no_talk", true)
		d.position = LandWalls.BREACH + Vector3(-3.2 + i * 1.3, 0, -1.6 - (i % 2) * 0.8)
		d.rotation.y = 0.0
		add_child(d)
		defenders.append(d)
	# Su fıçısı (kuyu): kova buradan doldurulur
	Props.cyl(self, 0.55, 1.1, WELL + Vector3(0, 0.55, 0), Color("6a4a2c"), Vector3.ZERO, 12)
	Props.cyl(self, 0.5, 0.04, WELL + Vector3(0, 1.1, 0), Color("4a78a8"), Vector3.ZERO, 12)
	for k in 3:
		Props.cyl(self, 0.16, 0.3, WELL + Vector3(0.8, 0.15, -0.3 + k * 0.35), Color("8a6440"), Vector3.ZERO, 8, 1.2)
	Props.interactable(self, "well", Vector3(1.8, 1.6, 1.8), WELL + Vector3(0.2, 0.8, 0))
	# Poterna yolunu kapatan fıçılar (3. dalgada çekilir)
	for i in BLOCKS.size():
		var b := Node3D.new()
		b.name = "Block%d" % i
		b.position = BLOCKS[i]
		add_child(b)
		Props.cyl(b, 0.42, 1.0, Vector3(0, 0.5, 0), Color("6a4a2c"), Vector3.ZERO, 10)
		Props.cyl(b, 0.43, 0.06, Vector3(0, 0.85, 0), Color("3a3634"), Vector3.ZERO, 10)
		var s := Props.solid(b, Vector3(0.9, 1.0, 0.9), Vector3(0, 0.5, 0), Color.WHITE)
		s.get_child(0).visible = false
		Props.interactable(b, "block_%d" % i, Vector3(1.2, 1.4, 1.2), Vector3(0, 0.7, 0))
	# Dış surun önüne dayanan merdivenler (hücumda görünür)
	for i in 5:
		var l := Node3D.new()
		l.position = Vector3(-14.0 + i * 6.5, 0, LandWalls.OUTER_Z1 + 1.6)
		l.rotation.x = deg_to_rad(-16)
		l.visible = false
		add_child(l)
		for sx: float in [-0.35, 0.35]:
			Props.cyl(l, 0.05, 9.0, Vector3(sx, 4.5, 0), Color("6a4a2c"), Vector3.ZERO, 5)
		for k in 12:
			Props.box(l, Vector3(0.75, 0.05, 0.05), Vector3(0, 0.5 + k * 0.72, 0), Color("6a4a2c"))
		ladders.append(l)
	# Burçtaki sancak (Ulubatlı Hasan): başta görünmez, 3. dalgada yükselir
	banner = Node3D.new()
	banner.position = BANNER_TOWER + Vector3(0, -4.0, 0)
	banner.visible = false
	add_child(banner)
	Props.cyl(banner, 0.05, 4.0, Vector3(0, 2.0, 0), Color("5a3e26"), Vector3.ZERO, 5)
	Props.box(banner, Vector3(0.04, 1.2, 1.8), Vector3(0, 3.3, 0.92), Color("b3262d"))
	emperor = Person.new({"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "stemma", "face": "emperor", "beard": true,
		"mustache": true, "hair": Color("6a6a6a"), "robe": Color("5a2a6a")})
	emperor.visible = false
	add_child(emperor)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH26_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH26_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = LandWalls.SPAWN
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.2)
	await hud.say("SPK_NIHAT", "D26_N_01")
	await hud.say("SPK_TOLGA", "D26_T_01")
	await hud.say("SPK_GIUST", "D26_G_01")
	await _wave1()
	await _wave2()
	await _wave3()
	await _aya()
	await _epilogue()
	await _end_chapter()


func _wave_start(n: int) -> void:
	Audio.sfx("crowd_camp", 0.0, 0.8 + n * 0.1)
	for i in ladders.size():
		ladders[i].visible = i < n + 2
	_spawn_attackers(4 + n * 3, n)
	hud.bark("SPK_LOOKOUT", "D26_L_WAVE_%d" % n, 3.5)


func _spawn_attackers(count: int, wave: int) -> void:
	for a in attackers:
		a.queue_free()
	attackers.clear()
	var coat: Color = [Color("8a6a4a"), Color("6a4a3a"), Color("2f5fa8")][wave - 1]
	for i in count:
		var s := Soldier.new(coat, "stand", "bork" if wave == 3 else "turban")
		s.position = Vector3(randf_range(-16, 20), 0, randf_range(40, 70))
		s.rotation.y = PI
		add_child(s)
		attackers.append(s)


func _wave1() -> void:
	phase = "wave1"
	_wave_start(1)
	await hud.say("SPK_GIUST", "D26_G_WAVE1")
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		for i in 3:
			_on_interact("well")
			_on_interact("breach")
			await get_tree().process_frame
	while water < 3:
		await get_tree().process_frame
	player.frozen = true
	_drop()
	await _repelled("D26_G_REPELLED_1")


func _wave2() -> void:
	phase = "wave2"
	_wave_start(2)
	# Urban'ın topu barikatı yıkar
	walls.fire_flash()
	Audio.sfx("cannon", 0.0, 0.8)
	await get_tree().create_timer(1.1).timeout
	walls.impact(LandWalls.BREACH + Vector3(0, 2.0, 0.6))
	Audio.sfx("explosion_big", -2.0)
	player.shake(0.8)
	walls.set_repair(LandWalls.STAGES - 4)
	await hud.say("SPK_GIUST", "D26_G_WAVE2")
	player.frozen = false
	_gun_t = 20.0
	_update_objective()
	if GameState.autotest:
		for i in 3:
			_pick("barrel")
			_deliver()
			await get_tree().process_frame
	while repaired < 3:
		await get_tree().process_frame
	_gun_t = 99.0
	_warn = false
	hud.set_qte("")
	player.frozen = true
	_drop()
	await _repelled("D26_G_REPELLED_2")


func _repelled(key: String) -> void:
	hud.set_objective("")
	for i in 3:
		Vfx.explosion(walls, Vector3(randf_range(-10, 12), 2.0, 26.0), 0.6)
		Audio.sfx("explosion_small", -6.0)
		await get_tree().create_timer(0.3).timeout
	for a in attackers:
		var tw := create_tween()
		tw.tween_property(a, "position:z", a.position.z + 40.0, 3.0)
	await hud.say("SPK_GIUST", key)


func _wave3() -> void:
	phase = "wave3"
	await hud.fade_to(1.0, 0.6)
	walls.make_dawn(0.01)
	await hud.card([[tr("UI_CH26_DAWN"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	player.global_position = LandWalls.BREACH + Vector3(4.0, 0.05, -6.0)
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	_wave_start(3)
	await hud.say("SPK_GIUST", "D26_G_WAVE3")
	# Yaralanma: yakın mesafeden atış (kaynaklarda göğüs zırhını delen kurşun)
	Audio.sfx("cannon", -6.0, 1.6)
	Vfx.dust(self, giust.global_position + Vector3(0, 1.4, 0), 0.5)
	player.shake(0.3)
	var tw := create_tween()
	tw.tween_property(giust, "rotation:x", deg_to_rad(-60), 0.5)
	tw.parallel().tween_property(giust, "position:y", -0.5, 0.5)
	await tw.finished
	await hud.say("SPK_DEFENDER", "D26_S_GIUST")
	await hud.say("SPK_GIUST", "D26_G_HURT")
	await hud.say("SPK_TOLGA", "D26_T_HURT")
	# İki adam onu kaldırır; poterna yolunu fıçılar kapatıyor
	for i in 2:
		var d: Person = defenders[i]
		d.position = giust.position + Vector3(-0.6 + i * 1.2, 0, 0.3)
		bearers.append(d)
	giust.rotation.x = deg_to_rad(-80)
	giust.position = giust.position + Vector3(0, 0.9, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ26_CLEAR") % [_cleared, BLOCKS.size()], POSTERN + Vector3(0, 1.2, 0))
	if GameState.autotest:
		for i in BLOCKS.size():
			_on_interact("block_%d" % i)
	while _cleared < BLOCKS.size():
		await get_tree().process_frame
	player.frozen = true
	hud.set_objective("")
	# Adamlar Giustiniani'yi poternadan geçirir
	var carry := create_tween().set_parallel()
	for n: Node3D in [giust] + bearers:
		carry.tween_property(n, "position:x", POSTERN.x + (n.position.x - giust.position.x), 3.0)
		carry.tween_property(n, "position:z", POSTERN.z, 3.0)
	await hud.say("SPK_DEFENDER", "D26_S_SHIP")
	await carry.finished
	for n: Node3D in [giust] + bearers:
		n.visible = false
	await hud.say("SPK_TOLGA", "D26_T_GONE")
	# Burçta sancak
	banner.visible = true
	player.face(BANNER_TOWER + Vector3(0, 2.0, 0))
	Audio.sfx("crowd_gasp", -2.0)
	var up := create_tween()
	up.tween_property(banner, "position", BANNER_TOWER, 2.4).set_trans(Tween.TRANS_SINE)
	await up.finished
	await hud.say("SPK_LOOKOUT", "D26_L_BANNER")
	await hud.say("SPK_NIHAT", "D26_N_BANNER")
	# İmparator'un son görüntüsü: arkası dönük, gediğe ve dumana yürür
	emperor.visible = true
	emperor.position = LandWalls.BREACH + Vector3(3.0, 0, -9.0)
	emperor.rotation.y = 0.0
	player.face(emperor.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_EMPEROR", "D26_K_LAST")
	var walk := create_tween()
	walk.tween_property(emperor, "position", LandWalls.BREACH + Vector3(0.5, 0, -1.4), 4.0)
	for i in 4:
		Vfx.dust(self, LandWalls.BREACH + Vector3(randf_range(-2, 2), 1.0, -1.0), 1.4)
	await walk.finished
	emperor.visible = false
	await hud.say("SPK_NIHAT", "D26_N_OUT")
	await hud.say("SPK_TOLGA", "D26_T_OUT")
	await hud.fade_to(1.0, 1.5, Color.WHITE)


## Öğleden sonra: Ayasofya. Fatih girer; taşa zarar veren bir askeri durdurur. Son kare.
func _aya() -> void:
	phase = "aya"
	walls.queue_free()
	walls = null
	for a in attackers:
		a.queue_free()
	attackers.clear()
	await get_tree().process_frame
	city = ByzCity.new()
	add_child(city)
	city.niko.visible = false
	city.emperor.visible = false
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.position = AYA + Vector3(0, 0, 18.0)
	fatih.rotation.y = PI
	add_child(fatih)
	axeman = Soldier.new(Color("2f5fa8"), "stand", "bork")
	axeman.position = AYA + Vector3(2.2, 0, 4.0)
	add_child(axeman)
	Props.cyl(axeman, 0.03, 1.0, Vector3(0.35, 0.9, 0.2), Color("5a3e26"), Vector3(0, 0, 40), 5)
	for i in 6:
		var s := Soldier.new([Color("2f5fa8"), Color("b3262d"), Color("6a4a3a")][i % 3], "stand", "bork" if i % 2 == 0 else "turban")
		s.position = AYA + Vector3(-5.0 + (i % 3) * 5.0, 0, 9.0 + (i / 3) * 3.0)
		s.rotation.y = PI
		add_child(s)
	player.global_position = AYA + Vector3(-4.5, 0.05, 6.0)
	player.face(AYA + Vector3(0, 6.0, -6.0))
	await hud.card([[tr("UI_CH26_AYA"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 1.5, Color.WHITE)
	await hud.say("SPK_TOLGA", "D26_T_AYA")
	var tw := create_tween()
	tw.tween_property(fatih, "position", AYA + Vector3(0.5, 0, 5.0), 5.0)
	player.face(fatih.global_position + Vector3(0, 1.6, 0))
	await tw.finished
	fatih.face_toward(axeman.global_position)
	await hud.say("SPK_FATIH", "D26_F_STOP")
	await hud.say("SPK_SOLDIER", "D26_S_AXE")
	await hud.say("SPK_FATIH", "D26_F_TRUST")
	fatih.face_toward(AYA + Vector3(0, 20, -10))
	await get_tree().create_timer(1.0).timeout
	await hud.say("SPK_NIHAT", "D26_N_AYA")
	var pick := await hud.choose(["UI_C26_PHOTO", "UI_C26_POCKET"], 0.0, 1 if GameState.autotest_variant == "nophoto" else 0)
	if pick == 0:
		var target := Node3D.new()
		add_child(target)
		target.global_position = fatih.global_position + Vector3(0, 2.0, -2.0)
		player.frozen = false
		hud.set_objective(tr("UI_OBJ26_PHOTO"), target.global_position)
		cam = TespitCam.new(player, hud, target, "siege26")
		hud.add_child(cam)
		cam.max_dist = 30.0
		cam.cone_deg = 14.0
		cam.taken.connect(func(path: String): _photo = path)
		cam.start()
		var t := 0.0
		while not cam.done and t < (3.0 if GameState.autotest else 40.0):
			await get_tree().process_frame
			t += get_process_delta_time()
		cam.stop()
		player.frozen = true
		hud.set_objective("")
		await hud.say("SPK_TOLGA", "D26_T_PHOTO")
	else:
		await hud.say("SPK_TOLGA", "D26_T_POCKET")
	_outcome = "26.1" if pick == 0 and cam != null and cam.done else "26.2"
	Siege.record(26, _photo if _outcome == "26.1" else "", "SIEGE_NOTE_26_%s" % _outcome.split(".")[1])
	await hud.say("SPK_NIHAT", "D26_N_LIFT")
	Audio.sfx("machine_jump", -4.0)
	await hud.fade_to(1.0, 1.0)


## Kapanış: Çarşamba. Büro'da dosya imzalanır, ofiste müdür hafta sonunu sorar.
func _epilogue() -> void:
	phase = "epilogue"
	city.queue_free()
	city = null
	fatih = null
	await get_tree().process_frame
	bureau = Bureau.new()
	add_child(bureau)
	var nihat := Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
		"hair": Color("3a2a1e"), "skin": Color("ecb892")})
	nihat.position = Vector3(1.1, 0, -0.9)
	bureau.add_child(nihat)
	nihat.look_target = player
	var pages := Siege.page_count()
	var total := Siege.LAST - Siege.FIRST + 1
	var board := Node3D.new()
	board.position = Vector3(-2.9, 1.65, 1.0)
	board.rotation.y = PI / 2.0
	bureau.add_child(board)
	Props.box(board, Vector3(1.7, 1.2, 0.06), Vector3.ZERO, Color("f4f4f0"))
	Props.label(board, tr("PROP17_WIKI_TITLE"), Vector3(-0.35, 0.44, 0.035), 28, Color("202122"), Vector3.ZERO)
	var left := total - pages
	for i in 5:
		var y := 0.22 - i * 0.18
		Props.box(board, Vector3(0.9, 0.045, 0.005), Vector3(-0.3, y, 0.035), Color("a2a9b1"))
		if i < ceili(left * 5.0 / total):
			Props.label(board, tr("PROP17_WIKI_CN"), Vector3(0.46, y, 0.036), 13, Color("cc2a2a"), Vector3.ZERO)
	player.global_position = Bureau.SPAWN_POS + Vector3(0, 0.05, 0)
	player.face(nihat.global_position + Vector3(0, 1.5, 0))
	await hud.card([[tr("UI_CH26_WED"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D26_N_EPI_1")
	await hud.say("SPK_NIHAT", "D26_N_EPI_ALL" if left == 0 else "D26_N_EPI_SOME")
	Audio.sfx("stamp", -2.0)
	await hud.say("SPK_TOLGA", "D26_T_EPI")
	await hud.say("SPK_NIHAT", "D26_N_EPI_2")
	await hud.fade_to(1.0, 0.8)
	# Ofis
	bureau.queue_free()
	bureau = null
	await get_tree().process_frame
	monday = Monday.new("W1", false)
	add_child(monday)
	player.global_position = Monday.TOLGA_DESK + Vector3(0.8, 0.05, 1.2)
	player.face(monday.manager.global_position + Vector3(0, 1.5, 0))
	await hud.card([[tr("UI_CH26_OFFICE"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	await hud.fade_to(0.0, 0.8)
	monday.manager.talking = true
	await hud.say("SPK_MANAGER", "D26_MG_ASK")
	monday.manager.talking = false
	var c := await hud.choose(["UI_C26_HONEST", "UI_C26_INSURER", "UI_C26_SILENT"], 0.0, 0)
	await hud.say("SPK_TOLGA", ["D26_T_HONEST", "D26_T_INSURER", "D26_T_SILENT"][c])
	monday.manager.talking = true
	await hud.say("SPK_MANAGER", ["D26_MG_HONEST", "D26_MG_INSURER", "D26_MG_SILENT"][c])
	monday.manager.talking = false
	GameState.flags["act4_answer"] = c
	GameState.flags["act4_done"] = true
	await hud.fade_to(1.0, 1.0)
	await hud.card([[tr("UI_ACT4_END"), 34, Color("f2e6c9")], [tr("UI_ACT4_END_SUB") % [pages, total], 18, Color(1, 1, 1, 0.75)]], 3.5)
	hud.clear_card()


# ================================================================ taşıma (1. ve 2. dalga)

func _update_objective() -> void:
	match phase:
		"wave1":
			if carrying == "water":
				hud.set_objective(tr("UI_OBJ26_WATER_GIVE") % [water, 3], LandWalls.BREACH + Vector3(0, 1.6, -2.0))
			else:
				hud.set_objective(tr("UI_OBJ26_WATER") % [water, 3], WELL + Vector3(0, 1.2, 0))
		"wave2":
			if carrying != "":
				hud.set_objective(tr("UI_OBJ26_REPAIR_PUT") % [repaired, 3], LandWalls.BREACH + Vector3(0, 2.2, -1.2))
			else:
				hud.set_objective(tr("UI_OBJ26_REPAIR") % [repaired, 3], LandWalls.DEPOT + Vector3(0, 1.2, 0))


func _pick(kind: String) -> void:
	if carrying != "":
		return
	carrying = kind
	_carry = Node3D.new()
	_carry.position = Vector3(0.3, -0.78, -1.05)
	_carry.scale = Vector3.ONE * 0.6
	player.camera.add_child(_carry)
	if kind == "water":
		Props.cyl(_carry, 0.2, 0.36, Vector3.ZERO, Color("8a6440"), Vector3.ZERO, 8, 1.2)
		Props.cyl(_carry, 0.22, 0.02, Vector3(0, 0.16, 0), Color("4a78a8"), Vector3.ZERO, 8)
	else:
		Props.cyl(_carry, 0.3, 0.8, Vector3.ZERO, LandWalls.C_WOOD, Vector3(90, 0, 0), 10)
	Props.strip_outlines(_carry)
	player.speed_mult = 0.8
	Audio.sfx("splash" if kind == "water" else "land_pot", -12.0, 1.2)
	_update_objective()


func _drop() -> void:
	carrying = ""
	if _carry:
		_carry.queue_free()
		_carry = null
	player.speed_mult = 1.0


func _deliver() -> void:
	if phase == "wave1" and carrying == "water":
		_drop()
		water += 1
		hud.bark("SPK_DEFENDER", "D26_S_WATER_%d" % water, 2.2)
	elif phase == "wave2" and carrying != "" and carrying != "water":
		_drop()
		repaired += 1
		walls.set_repair(LandWalls.STAGES - 4 + repaired)
		Audio.sfx("land_thud", -6.0, 1.2)
	_update_objective()


func _process(delta: float) -> void:
	_t += delta
	if walls == null:
		return
	# Hücum sırasında surun ötesinde ateş, patlama, toz
	if phase in ["wave1", "wave2", "wave3"]:
		_fx_t -= delta
		if _fx_t <= 0.0:
			_fx_t = randf_range(0.8, 2.0)
			Vfx.explosion(walls, Vector3(randf_range(-14, 18), randf_range(1.0, 7.0), randf_range(22.0, 30.0)), randf_range(0.3, 0.6))
			Audio.sfx("explosion_small", -16.0, randf_range(0.8, 1.2))
		for a in attackers:
			if a.position.z > 24.0 and a.visible:
				a.position.z -= delta * 2.2
	if phase == "wave2" and not player.frozen:
		_gun_t -= delta
		if not _warn and _gun_t <= 4.0:
			_warn = true
			hud.bark("SPK_LOOKOUT", "D20_L_WARN_1", 3.0)
			hud.set_qte(tr("UI_QTE20_COVER"))
		if _gun_t <= 0.0:
			_fire()


func _fire() -> void:
	_warn = false
	_gun_t = randf_range(22.0, 28.0)
	hud.set_qte("")
	walls.fire_flash()
	Audio.sfx("cannon", 0.0, 0.8)
	await get_tree().create_timer(1.1).timeout
	if walls == null:
		return
	walls.impact(LandWalls.BREACH + Vector3(randf_range(-2.5, 2.5), 2.0, 0.6))
	Audio.sfx("explosion_big", -4.0)
	player.shake(0.5)
	var p := player.global_position
	var safe := p.distance_to(LandWalls.BREACH) > 9.0 or p.distance_to(LandWalls.DEPOT) < 4.5
	for m: Vector3 in LandWalls.MANTLETS:
		if absf(p.x - m.x) < 1.5 and p.z < m.z + 0.9 and p.z > m.z - 2.2:
			safe = true
	if not safe:
		_knocks += 1
		player.stagger(1.2)
		if carrying != "":
			_drop()
			_update_objective()
		hud.bark("SPK_TOLGA", "D20_T_KNOCK_%d" % mini(_knocks, 3), 3.0)


func _on_focus(id: String) -> void:
	match id:
		"well":
			hud.set_prompt(tr("UI_PROMPT26_WATER") if phase == "wave1" and carrying == "" else "")
		"pile_barrel", "pile_earth", "pile_plank":
			hud.set_prompt(tr("UI_PROMPT20_TAKE") % tr("UI_ITEM20_" + id.trim_prefix("pile_").to_upper()) if phase == "wave2" and carrying == "" else "")
		"breach":
			hud.set_prompt(tr("UI_PROMPT26_GIVE") if carrying != "" else "")
		"block_0", "block_1":
			hud.set_prompt(tr("UI_PROMPT26_BLOCK") if phase == "wave3" else "")
		_:
			hud.set_prompt("")


func _on_interact(id: String) -> void:
	match id:
		"well":
			if phase == "wave1":
				_pick("water")
		"pile_barrel", "pile_earth", "pile_plank":
			if phase == "wave2":
				_pick(id.trim_prefix("pile_"))
		"breach":
			_deliver()
		"block_0", "block_1":
			if phase != "wave3":
				return
			var b := get_node_or_null("Block%s" % id.trim_prefix("block_")) as Node3D
			if b == null or b.has_meta("moved"):
				return
			b.set_meta("moved", true)
			for c in b.get_children():
				if c is StaticBody3D:
					c.queue_free()
			var tw := create_tween()
			tw.tween_property(b, "position", b.position + Vector3(0, 0, 2.2), 0.5)
			tw.parallel().tween_property(b, "rotation:x", deg_to_rad(90), 0.5)
			Audio.sfx("land_thud", -6.0, 0.8)
			_cleared += 1
			hud.set_objective(tr("UI_OBJ26_CLEAR") % [_cleared, BLOCKS.size()], POSTERN + Vector3(0, 1.2, 0))


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(26, _outcome)
	await Siege.show_page(hud, 26)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"replay":
			get_tree().reload_current_scene()
		_:
			GameState.change_scene("res://scenes/main.tscn")


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW26_TITLE")
	c.nodes = [
		{"id": "waves", "key": "FLOW26_WAVES", "pos": Vector2(0.5, 0.12)},
		{"id": "giust", "key": "FLOW26_GIUST", "pos": Vector2(0.5, 0.28)},
		{"id": "aya", "key": "FLOW26_AYA", "pos": Vector2(0.5, 0.44)},
		{"id": "26.1", "key": "FLOW_26_1", "pos": Vector2(0.3, 0.62), "outcome": true},
		{"id": "26.2", "key": "FLOW_26_2", "pos": Vector2(0.7, 0.62), "outcome": true},
	]
	c.edges = [["waves", "giust"], ["giust", "aya"], ["aya", "26.1"], ["aya", "26.2"]]
	for k in ["waves", "giust", "aya", _outcome]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH26_STATS") % [Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "26.1", "nophoto": "26.2"}.get(v, "26.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("26", {})
	var ok: bool = _outcome == expected and not page.is_empty() and water == 3 and repaired == 3 and _cleared == 2 and GameState.flags.get("act4_done", false)
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (su=%d onarım=%d fıçı=%d)" % [expected, _outcome, water, repaired, _cleared])
	print("AUTOTEST %s chapter=26 variant=%s outcome=%s water=%d repaired=%d cleared=%d" % ["PASS" if ok else "FAIL", v, _outcome,
		water, repaired, _cleared])
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
	phase = "wave1"
	_wave_start(1)
	player.global_position = LandWalls.BREACH + Vector3(3.5, 0.05, -7.0)
	await get_tree().create_timer(1.0).timeout
	player.face(LandWalls.BREACH + Vector3(0, 2.5, 0))
	await _shot("c26_01_assault.png")
	walls.make_dawn(0.01)
	banner.visible = true
	banner.position = BANNER_TOWER
	emperor.visible = true
	emperor.position = LandWalls.BREACH + Vector3(1.5, 0, -4.0)
	player.face(BANNER_TOWER + Vector3(-6, 1.0, 0))
	await get_tree().create_timer(0.5).timeout
	await _shot("c26_02_banner.png")
	phase = "aya"
	walls.queue_free()
	walls = null
	for a in attackers:
		a.queue_free()
	attackers.clear()
	await get_tree().process_frame
	city = ByzCity.new()
	add_child(city)
	city.niko.visible = false
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.position = AYA + Vector3(0.5, 0, 5.0)
	add_child(fatih)
	player.global_position = AYA + Vector3(-4.5, 0.05, 6.0)
	await get_tree().create_timer(1.5).timeout
	player.face(fatih.global_position + Vector3(0, 1.8, 0))
	await _shot("c26_03_aya.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = AYA + Vector3(-3.0, 1.7, 10.0)
	cv.look_at(AYA + Vector3(0.5, 4.0, 0.0), Vector3.UP)
	cv.fov = 62.0
	cv.make_current()
	await _shot("c26_cover.png")
	get_tree().quit()
