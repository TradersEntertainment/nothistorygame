extends Node3D
## Bölüm 41 (yalnız Osmanlı tarafı) — Talim (Tolga · 17 Nisan 1453, ordugâhın talim meydanı, öğleden sonra).
##
## İlk büyük hücumdan (18 Nisan gecesi, Bölüm 37o) bir gün önce Urban kâtibini azaplara ödünç verir; Azap Bölükbaşı
## Turgut "kılıç tutmayı bilmeyen kâtibi barikata göndermem" der ve onu talim meydanına götürür. Meydanda bölükler
## tahta kılıçla talim eder, okçular samana atar; uzakta, ovanın ucunda Kostantiniyye'nin surları.
## Kullanıcı: "ara sahne değil de bence ortak bi bölüm olsun biri bize savaşmayı öğretsin osmanlı kampında ve surların
## içinde farklı bölümler". Arkadaşın notu: "Ne yapmam gerektiğini anlamadım" (30o merdiveninde üç kez düştü).
##   1-5 Kılıç dersleri (Drill): yön, siper, karşılama, tekme, bitirici (saman kukla ve azap Hızır)
##   6 Merdiven talimi: iskeleye dayalı merdivene tırman. Üstteki azap kum torbası atar: torba düşerken DUR (W'yi bırak).
##     Öbürü su döker: kap sallanınca A ya da D ile merdivenin yanına sarkıl. Torba ya da su isabet ederse "Taş
##     olsaydı…", "Kaynar yağ olsaydı…"; yeniden tırmanılır. Tepeye çıkınca iner.
##   7 Serbest talim: Hızır gerçekten dövüşür (dört temiz darbe). Tespit karesi: talim eden bölük ve Turgut.
##   41O.1 Talimi geçti (serbest talimde Hızır'ı yendi) · 41O.2 Talimde dayak yedi (Turgut "yarın arkamda dur" der)
## Dallanma: Bölüm 37o (İlk Hücum) Turgut'un ilk sözü talimi hatırlar (41O.1 öne, 41O.2 arkasına alır).
##   37o'da Hızır huruçta yanında dövüşür ve sürüklenen yaralı odur (hizir_fell: çekiş aksarsa yetişemez); sonraki
##   çarpışmalarda sağsa unutulan tekmeyi/bitiriciyi hatırlatır (Mentor); Bölüm 15 İnsanların Akıbeti'nde yazılır.
##   --autotest[=lose]   (varsayılan: 41O.1; lose: serbest talimde bot savunmasız durur)

const YARD_AT := Vector3(-72.0, 0.0, 134.0)
const TURGUT_AT := Vector3(3.4, 0.0, 6.2)          # yerel: halkanın girişinin yanında
const HIZIR_LOOK := {"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "azap", "mustache": true, "beard": false,
	"skin": Color("d8a07a")}
const TURGUT_LOOK := {"coat": Color("b3262d"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": true,
	"skin": Color("c89070")}
const AZAPS := [
	{"coat": Color("6a4a3a"), "pants": Color("e8e0d0"), "hat": "azap", "mustache": true},
	{"coat": Color("3a6b3a"), "pants": Color("d8d0c0"), "hat": "azap", "beard": true},
	{"coat": Color("c98a3a"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": true},
	{"coat": Color("8a2b22"), "pants": Color("d8d0c0"), "hat": "azap", "mustache": true},
	{"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "turban", "beard": true},
	{"coat": Color("6a5a3a"), "pants": Color("d8d0c0"), "hat": "azap"},
]
const BAG_AT := Vector3(-1.3, 0.0, 0.5)     # iskelenin üstünde kum torbası atan azap (iskeleye göre)
const POT_AT := Vector3(1.3, 0.0, 0.5)      # su döken azap

var walls: LandWalls
var yard: TrainingYard
var player: Player
var hud: Hud
var drill: Drill
var turgut: Person
var hizir: Duelist
var kukla: Duelist
var cam: TespitCam
var bag_man: Person
var pot_man: Person
var _pot: Node3D
var phase := "intro"
var _outcome := ""
var _photo := ""
var bag_hits := 0
var water_hits := 0
var bags := 0
var _bag_falling := false
var _water := ""                   # "" | "warn" | "pour"
var _water_done := false
var climbs := 0


func _ready() -> void:
	GameState.snapshot(41)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	walls = LandWalls.new()
	walls.field_keep = [Rect2(YARD_AT.x - 13.0, YARD_AT.z - 15.0, 26.0, 30.0)]
	add_child(walls)
	walls.set_repair(3)
	walls.make_day()
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ kurulum

func _yard_y() -> float:
	# Talim meydanı ovanın en yüksek köşesine oturur (eğimde kum zemin havada kalmasın, kenarı toprağa gömülür)
	var y := -INF
	for dx: float in [-12.0, 0.0, 12.0]:
		for dz: float in [-15.0, 0.0, 13.0]:
			y = maxf(y, SiegeField.surf(YARD_AT.x + dx, YARD_AT.z + dz))
	return y + 0.02


func _build() -> void:
	yard = TrainingYard.new("O")
	add_child(yard)
	yard.global_position = Vector3(YARD_AT.x, _yard_y(), YARD_AT.z)
	turgut = Person.new(TURGUT_LOOK)
	turgut.set_meta("spk", "SPK_AZAPBASI")
	add_child(turgut)
	turgut.global_position = yard.at(TURGUT_AT)
	turgut.face_toward(yard.at(TrainingYard.RING))
	# Saman kukla ve talim arkadaşı Hızır (hasır kalkanlı azap)
	kukla = yard.make_kukla("O")
	kukla.npc_killed = true            # kuklanın "ölümü" oyuncunun hanesine yazılmaz
	hizir = Duelist.new(HIZIR_LOOK, "kilij", 0.4, true)
	hizir.name_key = "SPK_AZAP"
	hizir.body.set_meta("spk", "SPK_AZAP")
	hizir.drill = true
	hizir.max_hp = 99999.0
	hizir.hp = hizir.max_hp
	hizir.damage = 6.0
	hizir.set_meta("no_finish", true)
	add_child(hizir)
	hizir.global_position = yard.at(TrainingYard.PARTNER)
	TrainingYard.woodify(hizir.sword)
	# Meydanın canlısı: iki çift tahta kılıçla talimde, iki okçu samana atar, balyalarda oturan azaplar
	yard.add_sparring_pair(Vector3(7.6, 0, -2.0), [AZAPS[0], AZAPS[1]], "kilij")
	yard.add_sparring_pair(Vector3(-7.4, 0, 8.6), [AZAPS[2], AZAPS[3]], "kilij")
	for k in 2:
		var a := Person.new(AZAPS[4 + k])
		a.set_meta("no_talk", true)
		add_child(a)
		a.global_position = yard.at(Vector3(-8.5 + k * 1.2, 0, 4.5 + k * 0.6))
		a.face_toward(yard.at(Vector3(-8.5, 0, -3.5)))
		a.equip("bow")
		var loop := preload("res://scripts/npc/archer_loop.gd").new()
		loop.reach = Vector2(7.0, 9.5)
		a.add_child(loop)
	for k in 2:
		var s := Person.new(AZAPS[(k + 3) % AZAPS.size()])
		s.set_meta("no_talk", true)
		add_child(s)
		s.global_position = yard.at(TrainingYard.RING + Vector3(-TrainingYard.RING_R - 1.6, 0.7, -1.0 + k * 1.0))
		s.face_toward(yard.at(TrainingYard.RING))
		s.set_activity("sit")
	# İskelenin üstünde kum torbası ve su kabıyla bekleyen iki azap
	bag_man = _top_man(BAG_AT, AZAPS[0])
	pot_man = _top_man(POT_AT, AZAPS[5])
	_pot = Node3D.new()
	add_child(_pot)
	Props.cyl(_pot, 0.22, 0.42, Vector3(0, 0.21, 0), Color("b8743a"), Vector3.ZERO, 12, 0.17)
	Props.ring(_pot, 0.15, 0.2, Vector3(0, 0.42, 0), Color("8a4a24"))
	_pot.global_position = pot_man.global_position + Vector3(0, 0.95, 0.42)
	drill = Drill.new()
	add_child(drill)
	drill.setup(self, hud, player, yard, "D41O", "kilij")
	drill.teacher = turgut
	drill.teacher_spk = "SPK_AZAPBASI"
	drill.partner = hizir
	drill.partner_spk = "SPK_AZAP"
	drill.kukla = kukla


func _top_man(off: Vector3, look: Dictionary) -> Person:
	var m := Person.new(look)
	m.set_meta("no_talk", true)
	add_child(m)
	m.global_position = yard.at(TrainingYard.TOWER + off + Vector3(0, TrainingYard.TOWER_H + 0.14, 0))
	m.face_toward(yard.at(TrainingYard.TOWER + off + Vector3(0, 0, 6.0)))
	return m


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH41O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH41O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = yard.at(TrainingYard.START) + Vector3(0, 0.05, 0)
	player.face(turgut.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.2)
	turgut.look_target = player
	await hud.say("SPK_NIHAT", "D41O_N_01")
	await hud.say("SPK_AZAPBASI", "D41O_H_HELLO")
	await hud.say("SPK_TOLGA", "D41O_T_01")
	await hud.say("SPK_AZAPBASI", "D41O_H_02")
	await hud.say("SPK_TOLGA", "D41O_T_02")
	turgut.emote("point")
	await hud.say("SPK_AZAPBASI", "D41O_H_03")
	Lore.scatter(self, "41o")
	await drill.directions()
	await drill.blocking()
	await drill.parrying()
	await drill.kicking()
	await drill.finishing()
	await _ladder_drill()
	var won := await drill.spar(GameState.autotest_variant == "lose")
	_outcome = "41O.1" if won else "41O.2"
	await _after_spar(won)
	await _photo_phase()
	await _end_talk(won)
	await _end_chapter()


func _after_spar(won: bool) -> void:
	phase = "after"
	if won:
		hizir.body.emote("laugh")
		await hud.say("SPK_AZAP", "D41O_P_SPAR_WIN")
		await hud.say("SPK_AZAPBASI", "D41O_H_SPAR_WIN")
	else:
		await hud.say("SPK_AZAPBASI", "D41O_H_SPAR_STOP")
		await hud.say("SPK_AZAP", "D41O_P_SPAR_LOSE")
		await hud.say("SPK_TOLGA", "D41O_T_SPAR_LOSE")


# ================================================================ merdiven talimi

## İskeleye dayalı merdiven: W ile tırman. Kum torbası düşerken dur; su kabı sallanınca A/D ile yana sarkıl.
func _ladder_drill() -> void:
	phase = "ladder"
	drill.phase = "ladder"
	await drill.place_player(yard.ladder_foot(), null)
	player.face(yard.ladder.point_at(2.4))
	player.frozen = true
	turgut.look_target = player
	await hud.say("SPK_AZAPBASI", "D41O_H_LADDER_1")
	await hud.say("SPK_AZAPBASI", "D41O_H_LADDER_2")
	await hud.say("SPK_TOLGA", "D41O_T_LADDER")
	hud.set_objective(tr("UI_OBJ41O_CLIMB"), yard.ladder.point_at(TrainingYard.LADDER_H))
	player.frozen = false
	var hz := 1.2
	var t := 0.0
	var was_on := false
	var top_y := yard.global_position.y + TrainingYard.TOWER_H - 0.3
	while not (player.ladder == null and player.global_position.y > top_y):
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var on := player.ladder == yard.ladder
		if on and not was_on:
			climbs += 1
		was_on = on
		if on and not _water_done and _water == "" and not _bag_falling and player._ladder_t > TrainingYard.LADDER_H * 0.45:
			_pour()
		if on and _water == "" and player._ladder_t > 0.6:
			hz -= dt
			if hz <= 0.0:
				hz = randf_range(1.6, 2.3)
				_drop_bag()
		if not on and player.global_position.y < top_y - 2.0 and t > 1.0:
			hud.set_objective(tr("UI_OBJ41O_CLIMB"), yard.ladder.point_at(TrainingYard.LADDER_H))
		if GameState.autotest:
			_bot_climb(t)
	if GameState.autotest:
		for a in ["move_forward", "move_left", "move_right"]:
			Input.action_release(a)
	hud.set_qte("")
	hud.set_objective("")
	player.frozen = true
	turgut.emote("nod")
	await hud.say("SPK_AZAPBASI", "D41O_H_LADDER_TOP" if bag_hits + water_hits == 0 else "D41O_H_LADDER_TOP_2")
	await drill.place_player(TrainingYard.START + Vector3(0, 0, -3.0), turgut)


## Test botu insan gibi tırmanır: torba düşerken durur, su kabı sallanırken sola sarkar
func _bot_climb(t: float) -> void:
	if player.ladder == null and player._ladder_cool <= 0.0:
		player.face(yard.ladder.point_at(2.4))
	elif player.ladder:
		player.face(yard.ladder.point_at(clampf(player._ladder_t + 2.0, 0.0, TrainingYard.LADDER_H)))
	var stop := _bag_falling or _water != ""
	if stop:
		Input.action_release("move_forward")
	else:
		Input.action_press("move_forward")
	if _water != "":
		Input.action_press("move_left")
	else:
		Input.action_release("move_left")
	if t > 60.0:
		player.global_position = yard.ladder.top_exit()


## Kum torbası: azap torbayı başının üstüne kaldırır, merdivenin önünden aşağı atar. Oyuncunun biraz üstüne düşer;
## tırmanmayı sürdüren torbanın altına girer (eskiden 30o'da taş "nereden geldi" anlaşılmıyordu).
func _drop_bag() -> void:
	var l := yard.ladder
	var t_h: float = player._ladder_t + 1.1
	if t_h > l.height - 0.3 or bags >= 5:
		return
	bags += 1
	_bag_falling = true
	hud.set_qte(tr("UI_QTE41O_BAG"))
	if bag_man.rig:
		bag_man.rig.activity = "throw_up"
	var bag := Node3D.new()
	add_child(bag)
	Props.box(bag, Vector3(0.36, 0.22, 0.26), Vector3.ZERO, Color("b89a6a"))
	Props.box(bag, Vector3(0.05, 0.24, 0.27), Vector3(0.1, 0, 0), Color("6a4a2c"))
	bag.global_position = bag_man.global_position + Vector3(0, 2.15, 0.15)
	Audio.sfx("cloth", -8.0, 0.8)
	await get_tree().create_timer(0.5).timeout
	if bag_man.rig:
		bag_man.rig.activity = "throw_down"
	var at := l.point_at(t_h) + l.front_dir() * 0.4
	Audio.sfx("whoosh_fly", -6.0, 0.6)
	var tw := bag.create_tween()
	tw.tween_property(bag, "global_position", at, 0.75).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(bag, "rotation", Vector3(1.6, 0.8, 0.4), 0.75)
	await tw.finished
	var hit := player.ladder == l and absf(player._ladder_t - t_h) < 0.75
	if hit:
		bag_hits += 1
		Audio.sfx("land_thud", -2.0, 1.1)
		Vfx.dust(self, bag.global_position, 0.5)
		player.shake(0.5)
		# Torba çarptı: merdivenden düşülür (talimde yalnız gurur kırılır)
		player.ladder = null
		player.velocity = l.front_dir() * 2.4 + Vector3.UP * 1.0
		hud.bark("SPK_AZAPBASI", "D41O_H_LADDER_HIT", 2.8)
	_bag_falling = false
	hud.set_qte("")
	if bag_man.rig:
		bag_man.rig.activity = ""
	var tw2 := bag.create_tween()
	tw2.tween_property(bag, "global_position", l.global_position + l.front_dir() * 1.3 + Vector3(0, 0.12, 0), 0.45).set_ease(Tween.EASE_IN)
	tw2.tween_callback(func(): Audio.sfx_at("land_thud", bag, -10.0))
	tw2.tween_interval(4.0)
	tw2.tween_callback(bag.queue_free)


## Su: azap kabı kaldırır, sallar (uyarı), merdivenin ortasından aşağı boşaltır. Ortada kalan ıslanır.
func _pour() -> void:
	_water = "warn"
	hud.set_qte(tr("UI_QTE41O_WATER"))
	if pot_man.rig:
		pot_man.rig.activity = "lean_down"
	var l := yard.ladder
	var top := l.point_at(l.height) + l.front_dir() * 0.25 + Vector3(0, 0.25, 0)
	var tw := _pot.create_tween()
	tw.tween_property(_pot, "global_position", top, 0.4)
	for i in 4:
		tw.tween_property(_pot, "rotation:z", 0.25, 0.15)
		tw.tween_property(_pot, "rotation:z", -0.25, 0.15)
	await tw.finished
	_water = "pour"
	var tip := _pot.create_tween()
	tip.tween_property(_pot, "rotation:x", 1.9, 0.25)
	Audio.sfx("splash", -6.0, 1.3)
	# Su şeridi: kabın ağzından merdivenin önünden aşağı (yarı saydam mavi)
	var stream := Node3D.new()
	add_child(stream)
	var a := top
	var b := l.point_at(0.0) + l.front_dir() * 0.45
	var mid := (a + b) * 0.5
	var m := Props.box(stream, Vector3(0.22, (a - b).length(), 0.06), Vector3.ZERO, Color(0.55, 0.75, 0.95, 0.55))
	(m.material_override if m.material_override else m.get_active_material(0)).set("transparency", BaseMaterial3D.TRANSPARENCY_ALPHA)
	stream.global_position = mid
	stream.look_at(b, Vector3.FORWARD)
	stream.rotate_object_local(Vector3.RIGHT, PI * 0.5)
	var wet := false
	var t := 0.0
	while t < 1.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		if not wet and player.ladder == l and absf(player.ladder_side) < 0.3:
			wet = true
	if wet:
		water_hits += 1
		hud.wet(2.5)
		Audio.sfx("splash", -2.0, 1.0)
		hud.bark("SPK_AZAPBASI", "D41O_H_LADDER_WET", 2.8)
	else:
		hud.bark("SPK_AZAPBASI", "D41O_H_LADDER_DRY", 2.2)
	Vfx.splash(self, b, 0.5)
	stream.queue_free()
	var back := _pot.create_tween()
	back.tween_property(_pot, "rotation", Vector3.ZERO, 0.3)
	back.tween_property(_pot, "global_position", pot_man.global_position + Vector3(0, 0.95, 0.42), 0.4)
	if pot_man.rig:
		pot_man.rig.activity = ""
	hud.set_qte("")
	_water = ""
	_water_done = true


# ================================================================ tespit, son

func _photo_phase() -> void:
	phase = "photo"
	player.frozen = true
	await hud.say("SPK_NIHAT", "D41O_N_PHOTO")
	player.frozen = false
	var target := Node3D.new()
	yard.add_child(target)
	target.position = Vector3(7.6, 1.4, -2.0)
	hud.set_objective(tr("UI_OBJ41O_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege41o")
	hud.add_child(cam)
	cam.max_dist = 30.0
	cam.cone_deg = 20.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	hud.set_objective("")


func _end_talk(won: bool) -> void:
	player.frozen = true
	turgut.look_target = player
	player.face(turgut.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_AZAPBASI", "D41O_H_END_1" if won else "D41O_H_END_2")
	await hud.say("SPK_TOLGA", "D41O_T_END")
	await hud.say("SPK_NIHAT", "D41O_N_END")


func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(41, _outcome)
	Siege.record(41, _photo, "SIEGE_NOTE_41O_%s" % _outcome.split(".")[1])
	await Siege.show_page(hud, 41)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	drill.cleanup()
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(41)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			GameState.replay_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW41O_TITLE")
	c.nodes = [
		{"id": "lend", "key": "FLOW41O_LEND", "pos": Vector2(0.5, 0.1)},
		{"id": "sword", "key": "FLOW41O_SWORD", "pos": Vector2(0.5, 0.26)},
		{"id": "ladder", "key": "FLOW41O_LADDER", "pos": Vector2(0.5, 0.42)},
		{"id": "41O.1", "key": "FLOW_41O_1", "pos": Vector2(0.3, 0.62), "outcome": true},
		{"id": "41O.2", "key": "FLOW_41O_2", "pos": Vector2(0.7, 0.62), "outcome": true},
	]
	c.edges = [["lend", "sword"], ["sword", "ladder"], ["ladder", "41O.1"], ["ladder", "41O.2"]]
	for k in ["lend", "sword", "ladder"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	var s := drill.summary()
	c.footer_lines = [
		tr("UI_CH41O_STATS") % [int(s["parries"]), int(s["spar_hits"]), bag_hits + water_hits, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "41O.1", "lose": "41O.2"}.get(v, "41O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("41", {})
	var s := drill.summary()
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	ok = ok and int(s["dir"]) >= 3 and int(s["blocks"]) >= 3 and bool(s["kick"]) and bool(s["kick_down"]) and int(s["finishers"]) >= 3
	ok = ok and climbs >= 1 and _water_done
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s ders=%s tırmanış=%d su=%s)" % [expected, _outcome,
			not page.is_empty(), cam != null and cam.done, s, climbs, _water_done])
	print("AUTOTEST %s chapter=41 variant=%s outcome=%s dir=%d bumps=%d blocks=%d parries=%d kick=%s down=%s fins=%s spar=%d/%d bags=%d/%d water=%d" % [
		"PASS" if ok else "FAIL", v, _outcome, int(s["dir"]), int(s["bumps"]), int(s["blocks"]), int(s["parries"]), s["kick"],
		s["kick_down"], s["fin_kinds"], int(s["spar_hits"]), int(s["spar_taken"]), bag_hits, bags, water_hits])
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
	await get_tree().create_timer(2.5).timeout
	player.global_position = yard.at(TrainingYard.START) + Vector3(0, 0.05, 0)
	player.face(yard.at(TrainingYard.RING) + Vector3(0, 1.2, 0))
	await _shot("c41o_01_yard.png")
	player.global_position = yard.at(TrainingYard.DRILL_AT) + Vector3(0, 0.05, 0)
	player.face(kukla.global_position + Vector3(0, 1.45, 0))
	drill._start_duel([kukla] as Array[Duelist])
	kukla.drill_guard = Duelist.DIR_LEFT
	yard.set_guard_visual(Duelist.DIR_LEFT)
	await get_tree().create_timer(0.6).timeout
	await _shot("c41o_02_kukla.png")
	drill.duel.stop()
	player.global_position = yard.at(drill._partner_front()) + Vector3(0, 0.05, 0)
	player.face(hizir.global_position + Vector3(0, 1.45, 0))
	drill._start_duel([hizir] as Array[Duelist])
	hizir.drill_attack(Duelist.DIR_RIGHT, 1.6)
	await get_tree().create_timer(1.1).timeout
	await _shot("c41o_03_block.png")
	drill.duel.stop()
	player.global_position = yard.at(yard.ladder_foot()) + Vector3(0, 0.05, 0)
	player.face(yard.ladder.point_at(3.5))
	await _shot("c41o_04_ladder.png")
	player.global_position = yard.at(TrainingYard.START + Vector3(-3.0, 0, 2.0)) + Vector3(0, 0.05, 0)
	player.face(yard.at(Vector3(7.6, 1.2, -2.0)))
	await _shot("c41o_05_sparring.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = yard.at(Vector3(9.0, 6.0, 14.0))
	cv.look_at(yard.at(Vector3(-1.0, 1.0, -2.0)), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c41o_cover.png")
	get_tree().quit()
