extends Node3D
## Bölüm 21 (Osmanlı tarafı) — Lağım (Tolga · 16 Mayıs 1453, toprağın altı).
##
## Zağanos Paşa'nın emrinde Novo Brdo'lu madenciler surların altına lağım kazar. Tolga Lağımcı Dragan'ın yanındadır:
##   kaz (E basılı) · destek koy (E) sırayla; madencilerin karesi (tespit). Altıncı bölümde kazı yüzünün öbür
##   yanında kazma sesi: karşı lağım. Duvar açılır, iki taraf karanlıkta bir an durur, ikisi de geri çekilir.
##   Sonra Rum ateşinin dumanı gelir: girişe koş (süre, duman kalınlaşır).
##   21O.1 Dumandan önce çıkıldı · 21O.2 Dumana yakalandı, Dragan çekip çıkardı
##   Yarı yolda karşı lağımcı baskını (dar tünelde düello; yenilgide bir bölüm çöker).
##   10L'de toprağı dinleyip karşı lağımı duyan Tolga (ch10l_heard) sesi bu kez Dragan'dan önce duyar.
##   --autotest[=smoke|lose|ear]   (varsayılan: 21O.1)

const SEG := 2.5
const GOAL := 6
const DIG_TIME := 1.4
const ESCAPE_TIME := 14.0
const RAID_AT := 3                 # yarı yolda yan duvardan karşı lağımcılar dalar

var player: Player
var hud: Hud
var dragan: Person
var zaganos: Person
var digger: Person
var enemy: Person
var env: Environment
var face: Node3D
var phase := "intro"
var _outcome := ""
var dug := 0
var need_support := false
var _dig := 0.0
var _photo := ""
var cam: TespitCam
var _escape_t := 0.0
var escaped := false
var _lights: Array = []
var _t := 0.0
var raided := false
var raid_won := true
var _heard_first := false       # 10L'de toprağı dinlemeyi öğrenen Tolga sesi Dragan'dan önce duydu


func _ready() -> void:
	GameState.snapshot(21)
	if GameState.autotest and GameState.autotest_variant == "ear":
		GameState.flags["ch10l_heard"] = true        # 10L: karşı lağımın sesi duyuldu
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
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	var we := WorldEnvironment.new()
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("0a0806")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("5a3a24")
	env.ambient_light_energy = 0.25
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("1a120c")
	env.fog_density = 0.04
	env.glow_enabled = true
	we.environment = env
	add_child(we)
	# Giriş kuyusu (gün ışığı sızar) ve ilk bölüm
	Props.solid(self, Vector3(3.0, 0.2, 5.0), Vector3(0, -0.1, 1.5), Color("4a3828"))
	Props.solid(self, Vector3(3.0, 3.0, 0.3), Vector3(0, 1.5, 4.0), Color("3a2a1e"))
	for sx: float in [-1.0, 1.0]:     # kuyunun yan duvarları: yana yürüyüp karanlığa düşülmesin
		Props.solid(self, Vector3(0.3, 3.0, 4.0), Vector3(sx * 1.35, 1.5, 2.0), Color("3a2a1e"))
	var sun := SpotLight3D.new()
	sun.position = Vector3(0, 6, 2.5)
	sun.rotation_degrees = Vector3(-90, 0, 0)
	sun.spot_angle = 20.0
	sun.spot_range = 8.0
	sun.light_energy = 3.0
	sun.light_color = Color("fff0d0")
	add_child(sun)
	Props.box(self, Vector3(1.4, 4.0, 1.4), Vector3(0, 4.6, 2.5), Color("ffe8b0"), Vector3.ZERO, 0.8)
	for i in GOAL + 3:
		_segment(i)
	face = Node3D.new()
	add_child(face)
	Props.set_pattern(Props.solid(face, Vector3(2.4, 2.4, 0.4), Vector3(0, 1.1, 0), Color.WHITE), Color("5a4430"), "plaster")
	Props.interactable(face, "face", Vector3(2.0, 2.0, 0.8), Vector3(0, 1.1, 0.5))
	_place_face()
	# Destek direkleri yığını
	for i in 4:
		Props.cyl(self, 0.08, 2.2, Vector3(1.0, 0.3 + i * 0.17, 2.4 - i * 0.1), Color("6a4a2c"), Vector3(0, 0, 90), 5)
	Props.interactable(self, "supports", Vector3(1.2, 1.2, 1.2), Vector3(1.0, 0.6, 2.4))
	dragan = Person.new({"coat": Color("6a5a48"), "pants": Color("3a3028"), "hat": "none", "beard": true, "mustache": true,
		"hair": Color("4a3a2a"), "apron": Color("4a3a2a"), "skin": Color("c89070")})
	dragan.set_meta("spk", "SPK_MINER")
	add_child(dragan)
	dragan.look_target = player
	digger = Person.new({"coat": Color("7a6a58"), "pants": Color("3a3028"), "hat": "none", "mustache": true, "apron": Color("4a3a2a"), "skin": Color("d9a07a")})
	digger.set_meta("no_talk", true)
	add_child(digger)
	digger.set_activity("chop")
	zaganos = Person.new({"coat": Color("2f4a6a"), "pants": Color("2a2a30"), "hat": "turban", "beard": true, "mustache": true, "robe": Color("2f4a6a"),
		"skin": Color("d9a07a"), "face": {"nose": "hook", "brow": 1.3, "brow_tilt": 8.0, "beard": "short", "head": Vector3(0.98, 1.08, 0.98)}})
	zaganos.set_meta("spk", "SPK_ZAGANOS")
	zaganos.position = Vector3(-0.7, 0, 3.0)
	zaganos.rotation.y = PI
	add_child(zaganos)
	enemy = Person.new({"coat": Color("7a6a58"), "pants": Color("3a3028"), "hat": "helm", "mustache": true, "skin": Color("d9a07a")})
	enemy.visible = false
	enemy.set_meta("no_talk", true)
	add_child(enemy)
	_place_crew()


func _segment(i: int) -> void:
	var z := -SEG * (i + 0.5)
	Props.solid(self, Vector3(2.6, 0.2, SEG), Vector3(0, -0.1, z), Color("4a3828"))
	Props.solid(self, Vector3(2.6, 0.2, SEG), Vector3(0, 2.3, z), Color("2a1e14"))
	for sx: float in [-1.2, 1.2]:
		Props.set_pattern(Props.solid(self, Vector3(0.2, 2.4, SEG), Vector3(sx, 1.1, z), Color.WHITE), Color("5a4430"), "plaster")
	if i % 2 == 0 and i < GOAL:
		var l := OmniLight3D.new()
		l.position = Vector3(0.9, 1.3, z)
		l.light_color = Color("ffb060")
		l.light_energy = 1.3
		l.omni_range = 5.0
		add_child(l)
		_lights.append(l)
		Props.cyl(self, 0.03, 0.18, Vector3(0.95, 1.1, z), Color("f4ecd0"), Vector3.ZERO, 5)


## Yeni destek: kazılmış bölümün tavanına direk
func _support(i: int) -> void:
	var z := -SEG * (i + 0.2)
	for sx: float in [-1.0, 1.0]:
		Props.cyl(self, 0.08, 2.2, Vector3(sx, 1.1, z), Color("6a4a2c"), Vector3.ZERO, 5)
	Props.box(self, Vector3(2.2, 0.16, 0.16), Vector3(0, 2.15, z), Color("6a4a2c"))


func _place_face() -> void:
	face.position = Vector3(0, 0, -SEG * (dug + 1) - 0.2)


func _place_crew() -> void:
	var fz := face.position.z
	digger.position = Vector3(0.5, 0, fz + 1.0)
	digger.rotation.y = PI
	# Dragan kazanın bir adım gerisinde, duvar dibinde: kazı yüzüne gelen oyuncunun yüzüne yapışmasın
	dragan.position = Vector3(-0.8, 0, fz + 3.3)
	dragan.rotation.y = PI * 0.8


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH21O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH21O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = Vector3(0.3, 0.05, 2.0)
	player.face(zaganos.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_ZAGANOS", "D21O_Z_01")
	var met := GameState.has_seen("10L.1") or GameState.has_seen("10L.2") or GameState.has_seen("10L.3")
	await hud.say("SPK_MINER", "D21O_D_01K" if met else "D21O_D_01")
	await hud.say("SPK_TOLGA", "D21O_T_01")
	await hud.say("SPK_MINER", "D21O_D_02")
	zaganos.leave(player.global_position, 4.0, 1.5, true)
	# Paşa kuyudan çıkar; Tolga tünele, iş başındaki madencilere döner (karanlık köşeye bakıp kalmasın)
	player.face(digger.global_position + Vector3(0, 1.2, 0))
	# Tespit: madenciler iş başında
	player.frozen = false
	hud.set_objective(tr("UI_OBJ21O_PHOTO"), digger.global_position + Vector3(0, 1.2, 0))
	# Tünel bu anda kısa (kazı yeni başlıyor): sayfalar sabit yerlerde, kuyuda ve ilerideki bölümlerde
	Lore.scatter(self, "21o", [Vector3(1.0, 0.0, 0.9), Vector3(-0.9, 0.0, -3.6), Vector3(0.85, 0.0, -6.2)])
	cam = TespitCam.new(player, hud, digger, "siege21o")
	hud.add_child(cam)
	cam.max_dist = 8.0
	cam.cone_deg = 14.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 30.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	# Kaz ve destekle
	phase = "dig"
	_update_objective()
	if GameState.autotest:
		_auto_dig()
	while dug < GOAL:
		await get_tree().process_frame
	await _breach()
	await _escape()
	await _end_chapter()


func _update_objective() -> void:
	if phase != "dig":
		return
	if need_support:
		hud.set_objective(tr("UI_OBJ21O_SUPPORT") % [dug, GOAL], Vector3(1.0, 1.0, 2.4))
	else:
		hud.set_objective(tr("UI_OBJ21O_DIG") % [dug, GOAL], face.global_position + Vector3(0, 1.2, 0))


func _dig_done() -> void:
	dug += 1
	_place_face()
	_place_crew()
	Audio.sfx("land_thud", -8.0, 0.8)
	need_support = dug % 2 == 0 and dug < GOAL
	if dug == RAID_AT and not raided:
		_raid()
		return
	if dug < GOAL:
		hud.bark("SPK_MINER" if dug % 2 == 1 else "SPK_TOLGA", "D21O_DIG_%d" % dug, 2.5)
	_update_objective()


func _auto_dig() -> void:
	while dug < GOAL:
		await get_tree().create_timer(0.1).timeout
		if phase != "dig":
			continue
		if need_support:
			_on_interact("supports")
		else:
			_dig_done()


## Yarı yolda: yan duvar çöker, Johannes Grant'in karşı lağımcıları kandil ışığında dalar (tarihte Grant lağımları
## dinleyerek buldu, içeride göğüs göğüse çarpışıldı). Dar tünel: aynı anda tek rakip. Ölüm yok; yenilirse destek
## çöker ve bir bölüm yeniden kazılır. Sondaki sessiz karşılaşma (iki tarafın geri çekilmesi) bundan sonra gelir.
func _raid() -> void:
	raided = true
	phase = "raid"
	player.frozen = true
	hud.set_objective("")
	hud.set_prompt("")
	var fz := face.position.z
	var hole := Vector3(-1.1, 1.0, fz + 2.2)
	Audio.sfx("land_thud", 0.0, 0.6)
	Audio.sfx("cave_in", -6.0, 1.2)
	Vfx.dust(self, hole, 1.0)
	Fx.trauma(0.4)
	await hud.say("SPK_MINER", "D21O_D_RAID")
	var specs := []
	for k in 2:
		specs.append({"pos": Vector3(-0.3 + k * 0.6, 0, fz + 1.0 - k * 0.2), "blade": "spathion", "shield": false, "name": "SPK_DEFENDER",
			"look": {"coat": [Color("6a5a48"), Color("5a4a3a")][k], "pants": Color("3a3028"), "hat": "helm", "mustache": true, "beard": k == 1}})
	digger.visible = false
	player.global_position = Vector3(0.2, 0.05, fz + 3.6)
	player.face(Vector3(0, 1.5, fz + 1.0))
	player.frozen = false
	var r: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": specs, "max_active": 1, "skill": 0.4, "limit": 50.0}], "kilij")
	raid_won = r["won"]
	if raid_won:
		GameState.bump_stat("osm_sapper", 1, true)
	player.frozen = true
	digger.visible = true
	if raid_won:
		await hud.say("SPK_TOLGA", "D21O_T_RAID_WON")
	else:
		# Çarpışmada destek kırıldı: son kazılan bölüm çöker, yeniden kazılacak
		Audio.sfx("cave_in", -2.0, 0.9)
		Vfx.dust(self, Vector3(0, 1.4, fz + 1.2), 1.2)
		dug = maxi(dug - 1, 0)
		_place_face()
		_place_crew()
		await hud.say("SPK_MINER", "D21O_D_COLLAPSE")
	player.frozen = false
	phase = "dig"
	need_support = false
	_update_objective()


func _breach() -> void:
	phase = "breach"
	player.frozen = true
	hud.set_objective("")
	hud.set_prompt("")
	# Bölüm 10L: Tolga toprağı dinlemeyi Nisan'da Dragan'ın yanında öğrendi (ch10l_heard): sesi ondan önce duyar
	if GameState.flags.get("ch10l_heard", false):
		_heard_first = true
		Audio.sfx("timer_tick", -6.0, 0.6)
		await hud.say("SPK_TOLGA", "D21O_T_LISTEN_FIRST")
		await hud.say("SPK_MINER", "D21O_D_LISTEN_K")
	else:
		await hud.say("SPK_MINER", "D21O_D_LISTEN")
		Audio.sfx("timer_tick", -6.0, 0.6)
		await hud.say("SPK_TOLGA", "D21O_T_LISTEN")
	# Duvar açılır: karşıda Grant'in adamlarından biri, elinde fener
	Audio.sfx("land_thud", 0.0, 0.7)
	Vfx.dust(self, face.global_position + Vector3(0, 1.2, 0.3), 1.2)
	face.visible = false
	for c in face.get_children():
		if c is StaticBody3D:
			c.queue_free()
	enemy.visible = true
	enemy.global_position = face.global_position + Vector3(0.2, 0, -1.4)
	enemy.face_toward(player.global_position)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0.3, 1.3, 0.4)
	lamp.light_color = Color("ffd8a0")
	lamp.light_energy = 1.6
	lamp.omni_range = 5.0
	enemy.add_child(lamp)
	player.global_position = face.global_position + Vector3(0.3, 0.05, 2.2)
	player.face(enemy.global_position + Vector3(0, 1.5, 0))
	await get_tree().create_timer(0.6).timeout
	await hud.say("SPK_TOLGA", "D21O_T_FACE")
	var opts := ["UI_C21_WAVE"]
	if "chickpeas" in GameState.bag:
		opts.append("UI_C21_LEB")       # cebinde leblebi yoksa seçenek de yok
	var c := await hud.choose(opts, 0.0, 0)
	if c == 1:
		GameState.spend("chickpeas", "miner_leb_21o")
	await hud.say("SPK_TOLGA", "D21_T_LEB" if c == 1 else "D21_T_WAVE")
	enemy.leave(player.global_position, 6.0, 2.0, true)
	await get_tree().create_timer(0.8).timeout
	await hud.say("SPK_MINER", "D21O_D_FIRE")


func _escape() -> void:
	phase = "escape"
	player.frozen = false
	_escape_t = ESCAPE_TIME
	hud.set_objective(tr("UI_OBJ21O_ESCAPE"), Vector3(0, 1.5, 2.5))
	var smoke_z := face.position.z
	if GameState.autotest:
		if GameState.autotest_variant == "smoke":
			_escape_t = 0.05
		else:
			player.global_position = Vector3(0, 0.05, 2.5)
	while _escape_t > 0.0 and not escaped:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		_escape_t -= dt
		smoke_z += dt * (SEG * GOAL / ESCAPE_TIME) * 1.05
		env.fog_density = lerpf(0.04, 0.35, 1.0 - _escape_t / ESCAPE_TIME)
		env.fog_light_color = Color("3a2a1c").lerp(Color("6a5040"), 1.0 - _escape_t / ESCAPE_TIME)
		hud.set_chase(tr("UI_CH21O_SMOKE") % maxi(0, int(ceil(_escape_t))), 1.0 - _escape_t / ESCAPE_TIME)
		if player.global_position.z > 1.5:
			escaped = true
		elif player.global_position.z < smoke_z:
			_escape_t = 0.0
	hud.set_chase("", 0.0)
	hud.set_objective("")
	player.frozen = true
	if not escaped:
		Audio.sfx("crowd_gasp", -4.0, 0.8)
		await hud.fade_to(1.0, 0.6)
		player.global_position = Vector3(0, 0.05, 2.6)
		env.fog_density = 0.08
		await hud.fade_to(0.0, 0.8)
		await hud.say("SPK_MINER", "D21O_D_PULLED")
		await hud.say("SPK_TOLGA", "D21O_T_COUGH")
	else:
		env.fog_density = 0.08
		await hud.say("SPK_MINER", "D21O_D_OUT")
	await hud.say("SPK_TOLGA", "D21O_T_END")
	await hud.say("SPK_NIHAT", "D21O_N_END")
	_outcome = "21O.1" if escaped else "21O.2"
	Siege.record(21, _photo, "SIEGE_NOTE_21O_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	for i in _lights.size():
		(_lights[i] as OmniLight3D).light_energy = 1.2 + sin(_t * 7.0 + i) * 0.15
	if phase == "dig" and not need_support:
		var near := player.focus_id == "face"
		if near and Input.is_action_pressed("interact"):
			_dig += delta
			player.shake(0.05)
			hud.set_chase(tr("UI_CH21O_DIG"), _dig / DIG_TIME)
			if _dig >= DIG_TIME:
				_dig = 0.0
				hud.set_chase("", 0.0)
				_dig_done()
		elif _dig > 0.0:
			_dig = maxf(0.0, _dig - delta)
			if _dig <= 0.0:
				hud.set_chase("", 0.0)


func _on_focus(id: String) -> void:
	match id:
		"face":
			hud.set_prompt(tr("UI_PROMPT21O_DIG") if phase == "dig" and not need_support else "")
		"supports":
			hud.set_prompt(tr("UI_PROMPT21O_SUPPORT") if phase == "dig" and need_support else "")
		_:
			hud.set_prompt("")


func _on_interact(id: String) -> void:
	if id == "supports" and phase == "dig" and need_support:
		need_support = false
		_support(dug - 1)
		Audio.sfx("land_pot", -8.0, 0.8)
		hud.bark("SPK_MINER", "D21O_D_SUPPORT", 2.0)
		_update_objective()


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(21, _outcome)
	await Siege.show_page(hud, 21)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(21)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW21O_TITLE")
	c.nodes = [
		{"id": "dig", "key": "FLOW21O_DIG", "pos": Vector2(0.5, 0.12)},
		{"id": "meet", "key": "FLOW21_TUNNEL", "pos": Vector2(0.5, 0.3)},
		{"id": "21O.1", "key": "FLOW_21O_1", "pos": Vector2(0.3, 0.52), "outcome": true},
		{"id": "21O.2", "key": "FLOW_21O_2", "pos": Vector2(0.7, 0.52), "outcome": true},
	]
	c.edges = [["dig", "meet"], ["meet", "21O.1"], ["meet", "21O.2"]]
	for k in ["dig", "meet", _outcome]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH21O_STATS") % [dug, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	c.footer_lines.insert(0, Grade.finish("21o"))
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "21O.1", "smoke": "21O.2", "lose": "21O.1"}.get(v, "21O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("21", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and dug == GOAL
	# Karşı lağımcı baskını yaşanmış olmalı; yenilgi testinde düşülmüş ve baskın kaybedilmiş olmalı
	ok = ok and raided and (raid_won != v.ends_with("lose")) and _heard_first == (v == "ear")
	if v.ends_with("lose"):
		ok = ok and player.downs >= 1
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=21o variant=%s outcome=%s dug=%d raid=%s ear=%s" % ["PASS" if ok else "FAIL", v, _outcome, dug, raid_won,
		_heard_first])
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
	dug = 3
	_place_face()
	_place_crew()
	_support(1)
	player.global_position = face.global_position + Vector3(0.4, 0.05, 3.2)
	await get_tree().create_timer(0.8).timeout
	player.face(digger.global_position + Vector3(0, 1.2, 0))
	hud.set_objective(tr("UI_OBJ21O_DIG") % [3, GOAL], face.global_position)
	await _shot_png("c21o_01_dig.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = face.global_position + Vector3(-0.7, 1.7, 4.2)
	cv.look_at(face.global_position + Vector3(0.2, 1.0, 0), Vector3.UP)
	cv.fov = 62.0
	cv.make_current()
	await _shot_png("c21o_cover.png")
	get_tree().quit()
