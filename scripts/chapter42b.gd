extends Node3D
## Bölüm 42 (yalnız Bizans tarafı) — Talim (Tolga · 7 Nisan 1453, surların içi, Mesoteichion'un ardındaki meydan, sabah).
##
## Sultan'ın ordusu bir gün önce surların önüne geldi. Giustiniani (Ocak'ta yedi yüz adamla gelip kara surlarının
## savunmasını üstlenen Cenevizli) şehrin gönüllülerini ve tercümanını iç surun ardındaki meydanda talim ettirir.
## Bizans kayıtlarının ilk sayfası: iki gün sonra huruç (36b) var.
## Kullanıcı: "biri bize savaşmayı öğretsin osmanlı kampında ve surların içinde farklı bölümler".
##   1-5 Kılıç dersleri (Drill): yön, siper, karşılama, tekme, bitirici (adı olmayan saman kukla ve okçu Leon)
##   6 Merdiven itme: ahşap iskeleye arkadaki rampadan çık, merdivenin başına geç. Leon'un adamları tırmanır; tepeye
##     varmadan E basılı merdiveni it (merdiven devrilir, tırmanan samana düşer). İki kez; ikincisi daha hızlı. Geç
##     kalınırsa adam iskeleye çıkar, tahta kılıçla dürter: yeniden.
##   7 Serbest talim: Leon gerçekten dövüşür (dört temiz darbe). Tespit karesi: talimi izleyen Giustiniani.
##   42.1 Talimi geçti (Leon'u yendi) · 42.2 Leon onu dövdü
## Dallanma: Bölüm 36 (Huruç) Leon'un ilk sözü talimi hatırlar.
##   --autotest[=lose]   (varsayılan: 42.1; lose: serbest talimde bot savunmasız durur)

const YARD_AT := Vector3(-16.0, 0.0, -20.0)
const GIUST_AT := Vector3(3.4, 0.0, 6.2)
const LEON_LOOK := {"coat": Color("5a6a7a"), "pants": Color("3a2a22"), "hat": "helm", "mustache": true, "beard": false}
const GIUST_LOOK := {"face": "giustiniani", "coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero",
	"beard": true, "skin": Color("e0b08a")}
const MEN := [
	{"coat": Color("7a2a24"), "pants": Color("3a2a22"), "hat": "helm", "mustache": true},
	{"coat": Color("8a8e96"), "pants": Color("2a2a30"), "hat": "helm", "beard": true},
	{"coat": Color("4a3a2e"), "pants": Color("4a3a2a"), "hat": "", "mustache": true, "beard": true},
	{"coat": Color("3a4a6a"), "pants": Color("3a2a22"), "hat": "helm"},
	{"coat": Color("6a5a48"), "pants": Color("2a2a30"), "hat": "", "beard": true},
	{"coat": Color("d8d0c0"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true},
]
const PUSH_HOLD := 0.8

var walls: LandWalls
var yard: TrainingYard
var player: Player
var hud: Hud
var drill: Drill
var giust: Person
var leon: Duelist
var kukla: Duelist
var cam: TespitCam
var climber: Person
var phase := "intro"
var _outcome := ""
var _photo := ""
var pushed := 0
var late := 0
var _hold := 0.0
var _climb_t := -1.0                # tırmananın merdivendeki yüksekliği (m); < 0 merdivende değil


func _ready() -> void:
	GameState.snapshot(42)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(false)
	hud.set_signal(0)
	walls = LandWalls.new()
	walls.intact = true                 # 7 Nisan: bombardıman başlamadı
	add_child(walls)
	walls.set_repair(LandWalls.STAGES)
	walls.make_day()
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ kurulum

func _build() -> void:
	yard = TrainingYard.new("B")
	add_child(yard)
	yard.global_position = YARD_AT
	yard.rotation.y = PI                # iskele iç sura dönük (yerel -z = dünya +z), giriş şehir tarafında
	giust = Person.new(GIUST_LOOK)
	giust.set_meta("spk", "SPK_GIUST")
	giust.set_meta("no_yield", true)
	add_child(giust)
	giust.global_position = yard.at(GIUST_AT)
	giust.face_toward(yard.at(TrainingYard.RING))
	kukla = yard.make_kukla("B")
	kukla.npc_killed = true
	leon = Duelist.new(LEON_LOOK, "spathion", 0.4, true)
	leon.name_key = "SPK_DEFENDER"
	leon.body.set_meta("spk", "SPK_DEFENDER")
	leon.drill = true
	leon.max_hp = 99999.0
	leon.hp = leon.max_hp
	leon.damage = 6.0
	leon.set_meta("no_finish", true)
	add_child(leon)
	leon.global_position = yard.at(TrainingYard.PARTNER)
	TrainingYard.woodify(leon.sword)
	# Meydanın canlısı: iki çift talimde, iki okçu hedefe atar, iki gönüllü balyada sırasını bekler
	yard.add_sparring_pair(Vector3(7.6, 0, -2.0), [MEN[0], MEN[1]], "spathion")
	yard.add_sparring_pair(Vector3(-7.4, 0, 8.6), [MEN[2], MEN[3]], "spathion")
	for k in 2:
		var a := Person.new(MEN[4 + k])
		a.set_meta("no_talk", true)
		add_child(a)
		a.global_position = yard.at(Vector3(-8.5 + k * 1.2, 0, 4.5 + k * 0.6))
		a.face_toward(yard.at(Vector3(-8.5, 0, -3.5)))
		a.equip("bow")
		var loop := preload("res://scripts/npc/archer_loop.gd").new()
		loop.reach = Vector2(7.0, 9.5)
		a.add_child(loop)
	for k in 2:
		var s := Person.new(MEN[(k + 2) % MEN.size()])
		s.set_meta("no_talk", true)
		add_child(s)
		s.global_position = yard.at(TrainingYard.RING + Vector3(-TrainingYard.RING_R - 1.6, 0.7, -1.0 + k * 1.0))
		s.face_toward(yard.at(TrainingYard.RING))
		s.set_activity("sit")
	# Merdivene tırmanacak gönüllü (Leon'un adamı): merdivenin dibinde bekler
	climber = Person.new(MEN[5])
	climber.set_meta("no_talk", true)
	climber.set_meta("climber", true)
	add_child(climber)
	_climber_home()
	drill = Drill.new()
	add_child(drill)
	drill.setup(self, hud, player, yard, "D42B", "spathion")
	drill.teacher = giust
	drill.teacher_spk = "SPK_GIUST"
	drill.partner = leon
	drill.partner_spk = "SPK_DEFENDER"
	drill.kukla = kukla


func _climber_home() -> void:
	if climber.get_parent() != self:
		climber.reparent(self)
	climber.rotation = Vector3.ZERO
	climber.global_position = yard.at(yard.ladder_foot() + Vector3(0.9, 0, 0.4))
	climber.face_toward(yard.ladder.global_position)
	if climber.rig:
		climber.rig.activity = ""
	_climb_t = -1.0


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH42B_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH42B_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = yard.at(TrainingYard.START) + Vector3(0, 0.05, 0)
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.2)
	giust.look_target = player
	await hud.say("SPK_NIHAT", "D42B_N_01")
	await hud.say("SPK_GIUST", "D42B_H_HELLO")
	await hud.say("SPK_TOLGA", "D42B_T_01")
	await hud.say("SPK_GIUST", "D42B_H_02")
	await hud.say("SPK_DEFENDER", "D42B_P_HELLO")
	await hud.say("SPK_TOLGA", "D42B_T_02")
	await hud.say("SPK_GIUST", "D42B_H_03")
	await drill.directions()
	await drill.blocking()
	await drill.parrying()
	await drill.kicking()
	await drill.finishing()
	await _push_drill()
	var won := await drill.spar(GameState.autotest_variant == "lose")
	_outcome = "42.1" if won else "42.2"
	await _after_spar(won)
	await _photo_phase()
	await _end_talk(won)
	await _end_chapter()


func _after_spar(won: bool) -> void:
	phase = "after"
	if won:
		leon.body.emote("laugh")
		await hud.say("SPK_DEFENDER", "D42B_P_SPAR_WIN")
		await hud.say("SPK_GIUST", "D42B_H_SPAR_WIN")
	else:
		await hud.say("SPK_GIUST", "D42B_H_SPAR_STOP")
		await hud.say("SPK_DEFENDER", "D42B_P_SPAR_LOSE")
		await hud.say("SPK_TOLGA", "D42B_T_SPAR_LOSE")


# ================================================================ merdiven itme

func _head() -> Vector3:
	return yard.at(yard.ladder_head())


## İskeleye çık, merdivenin başına geç; gönüllü tırmanırken E basılı merdiveni it. İki tur.
func _push_drill() -> void:
	phase = "push"
	drill.phase = "push"
	player.frozen = true
	await drill.place_player(TrainingYard.START + Vector3(2.2, 0, -6.0), giust)
	await hud.say("SPK_GIUST", "D42B_H_LADDER_1")
	await hud.say("SPK_GIUST", "D42B_H_LADDER_2")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ42_UP"), _head())
	if GameState.autotest:
		player.global_position = _head() + Vector3(0, 0.05, 0)
	var t := 0.0
	while not _on_head() and t < 90.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	if not _on_head():
		await drill.place_player(yard.ladder_head(), null)
	hud.set_objective("")
	player.face(yard.ladder.point_at(1.0))
	for round_i in 2:
		var spd := 0.55 if round_i == 0 else 0.85
		var ok := false
		var tries := 0
		while not ok and tries < 4:
			tries += 1
			ok = await _climb_round(spd)
			if not ok:
				late += 1
				hud.bark("SPK_GIUST", "D42B_H_PUSH_LATE", 2.8)
				await get_tree().create_timer(1.6).timeout
				_climber_home()
				_raise_ladder(true)
				await get_tree().create_timer(0.8).timeout
		if round_i == 0:
			await hud.say("SPK_GIUST", "D42B_H_PUSH_OK")
			await hud.say("SPK_GIUST", "D42B_H_PUSH_TWO")
	player.frozen = true
	await drill.place_player(TrainingYard.START + Vector3(0, 0, -3.0), giust)


func _on_head() -> bool:
	var h := _head()
	var p := player.global_position
	return Vector2(p.x - h.x, p.z - h.z).length() < 1.6 and p.y > h.y - 0.6


## Bir tur: gönüllü merdivene tutunur, tırmanır. Tepeye varmadan itilirse true. Oyuncu merdivenin başında E basılı.
func _climb_round(speed: float) -> bool:
	var l := yard.ladder
	climber.reparent(l)
	_climb_t = 0.0
	hud.bark("SPK_DEFENDER", "D42B_P_CLIMB_%d" % (pushed % 2 + 1), 2.2)
	_hold = 0.0
	var step_acc := 0.0
	while _climb_t < l.height - 0.4:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		_climb_t += speed * dt
		step_acc += speed * dt
		_place_climber()
		if step_acc > 0.42:
			step_acc = 0.0
			if climber.rig:
				climber.rig.activity = "climb_b" if climber.rig.activity == "climb_a" else "climb_a"
		var near := _on_head()
		var press := Input.is_action_pressed("interact")
		if GameState.autotest:
			press = _climb_t > l.height * 0.45
		if near:
			hud.set_prompt(tr("UI_PROMPT42_PUSH"))
		else:
			hud.set_prompt("")
		if near and press:
			_hold += dt
			hud.set_chase(tr("UI_CH42_PUSH"), _hold / PUSH_HOLD)
			if _hold >= PUSH_HOLD:
				hud.set_prompt("")
				hud.set_chase("", 0.0)
				await _push()
				return true
		else:
			_hold = 0.0
			hud.set_chase("", 0.0)
	# Geç kalındı: gönüllü iskeleye çıkar, tahta kılıçla oyuncuyu dürter
	hud.set_prompt("")
	hud.set_chase("", 0.0)
	climber.reparent(self)
	climber.rotation = Vector3.ZERO
	var tw := climber.create_tween()
	tw.tween_property(climber, "global_position", l.top_exit(), 0.4)
	await tw.finished
	if climber.rig:
		climber.rig.activity = ""
	climber.face_toward(player.global_position)
	climber.emote("point")
	player.shake(0.3)
	Audio.sfx("kick_metal", -8.0, 1.2)
	return false


func _place_climber() -> void:
	var l := yard.ladder
	var p := l.point_at(_climb_t) + l.front_dir() * 0.38 + Vector3(0, -0.15, 0)
	climber.global_position = p
	var f := -l.front_dir()
	f.y = 0.0
	climber.global_rotation = Vector3(0, atan2(f.x, f.z), 0)


## Merdiven devrilir; üstündeki samana düşer; balyada bir an yatar, kalkıp güler. Sonra iki gönüllü merdiveni yeniden dayar.
func _push() -> void:
	pushed += 1
	var l := yard.ladder
	Audio.sfx_at("wood_creak", l, 0.0)
	Audio.sfx("whoosh_fly", -4.0, 0.6)
	hud.bark("SPK_TOLGA", "D30_T_PUSH", 1.6)
	var tw := l.create_tween()
	tw.tween_property(l, "rotation:x", deg_to_rad(76.0), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.55).timeout
	# Gönüllü merdivenden kopar, samana düşer
	climber.reparent(self)
	if climber.rig:
		climber.rig.activity = "fall"
	var hay := yard.at(TrainingYard.TOWER + Vector3(-0.3 + (pushed % 2) * 0.8, 0.72, TrainingYard.TOWER_D * 0.5 + 4.1))
	var from := climber.global_position
	var fall := climber.create_tween()
	fall.tween_method(func(u: float):
		var p := from.lerp(hay, u)
		p.y += sin(u * PI) * 0.8 - u * 0.2
		climber.global_position = p, 0.0, 1.0, 0.7)
	await fall.finished
	Audio.sfx("land_thud", -6.0, 0.9)
	Vfx.dust(self, hay + Vector3(0, 0.2, 0), 0.5)
	climber.global_rotation = Vector3(-1.4, climber.global_rotation.y, 0)
	if tw.is_running():
		await tw.finished
	Audio.sfx_at("land_thud", l, 0.0)
	await get_tree().create_timer(0.8).timeout
	hud.bark("SPK_DEFENDER", "D42B_P_HAY", 2.4)
	climber.global_rotation = Vector3(0, climber.global_rotation.y, 0)
	climber.emote("laugh")
	await get_tree().create_timer(1.0).timeout
	_climber_home()
	_raise_ladder(false)
	await get_tree().create_timer(1.4).timeout


func _raise_ladder(instant: bool) -> void:
	var l := yard.ladder
	if instant:
		l.rotation.x = 0.0
		return
	var tw := l.create_tween()
	tw.tween_property(l, "rotation:x", 0.0, 1.2).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func(): Audio.sfx_at("land_thud", l, -6.0))


# ================================================================ tespit, son

func _photo_phase() -> void:
	phase = "photo"
	player.frozen = true
	await hud.say("SPK_NIHAT", "D42B_N_PHOTO")
	player.frozen = false
	var target := Node3D.new()
	giust.add_child(target)
	target.position = Vector3(0, 1.5, 0)
	hud.set_objective(tr("UI_OBJ42_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege42")
	hud.add_child(cam)
	cam.max_dist = 25.0
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
	giust.look_target = player
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_GIUST", "D42B_H_END_1" if won else "D42B_H_END_2")
	await hud.say("SPK_TOLGA", "D42B_T_END")
	await hud.say("SPK_NIHAT", "D42B_N_END")


func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(42, _outcome)
	Siege.record(42, _photo, "SIEGE_NOTE_42_%s" % _outcome.split(".")[1])
	await Siege.show_page(hud, 42)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	drill.cleanup()
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(42)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			GameState.replay_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW42_TITLE")
	c.nodes = [
		{"id": "call", "key": "FLOW42_CALL", "pos": Vector2(0.5, 0.1)},
		{"id": "sword", "key": "FLOW42_SWORD", "pos": Vector2(0.5, 0.26)},
		{"id": "ladder", "key": "FLOW42_LADDER", "pos": Vector2(0.5, 0.42)},
		{"id": "42.1", "key": "FLOW_42_1", "pos": Vector2(0.3, 0.62), "outcome": true},
		{"id": "42.2", "key": "FLOW_42_2", "pos": Vector2(0.7, 0.62), "outcome": true},
	]
	c.edges = [["call", "sword"], ["sword", "ladder"], ["ladder", "42.1"], ["ladder", "42.2"]]
	for k in ["call", "sword", "ladder"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	var s := drill.summary()
	c.footer_lines = [
		tr("UI_CH42_STATS") % [int(s["parries"]), pushed, int(s["spar_hits"]), Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "42.1", "lose": "42.2"}.get(v, "42.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("42", {})
	var s := drill.summary()
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	ok = ok and int(s["dir"]) >= 3 and int(s["blocks"]) >= 3 and bool(s["kick"]) and bool(s["kick_down"]) and int(s["finishers"]) >= 3 and pushed >= 2
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s ders=%s itilen=%d)" % [expected, _outcome, not page.is_empty(),
			cam != null and cam.done, s, pushed])
	print("AUTOTEST %s chapter=42 variant=%s outcome=%s dir=%d bumps=%d blocks=%d parries=%d kick=%s down=%s fins=%s spar=%d/%d pushed=%d late=%d" % [
		"PASS" if ok else "FAIL", v, _outcome, int(s["dir"]), int(s["bumps"]), int(s["blocks"]), int(s["parries"]), s["kick"],
		s["kick_down"], s["fin_kinds"], int(s["spar_hits"]), int(s["spar_taken"]), pushed, late])
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
	await _shot("c42b_01_yard.png")
	player.global_position = yard.at(TrainingYard.DRILL_AT) + Vector3(0, 0.05, 0)
	player.face(kukla.global_position + Vector3(0, 1.45, 0))
	drill._start_duel([kukla] as Array[Duelist])
	kukla.drill_guard = Duelist.DIR_RIGHT
	yard.set_guard_visual(Duelist.DIR_RIGHT)
	await get_tree().create_timer(0.6).timeout
	await _shot("c42b_02_kukla.png")
	drill.duel.stop()
	player.global_position = yard.at(drill._partner_front()) + Vector3(0, 0.05, 0)
	player.face(leon.global_position + Vector3(0, 1.45, 0))
	drill._start_duel([leon] as Array[Duelist])
	leon.drill_attack(Duelist.DIR_LEFT, 1.6)
	await get_tree().create_timer(1.1).timeout
	await _shot("c42b_03_block.png")
	drill.duel.stop()
	player.global_position = _head() + Vector3(0, 0.05, 0)
	player.face(yard.ladder.point_at(0.5))
	climber.reparent(yard.ladder)
	_climb_t = 2.4
	_place_climber()
	if climber.rig:
		climber.rig.activity = "climb_a"
	await get_tree().create_timer(0.5).timeout
	await _shot("c42b_04_push.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = yard.at(Vector3(9.0, 6.0, 14.0))
	cv.look_at(yard.at(Vector3(-1.0, 1.0, -2.0)), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c42b_cover.png")
	get_tree().quit()
