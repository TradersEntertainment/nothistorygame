extends Node3D
## Bölüm 14 — Son Form (Nihat · Zaman Bürosu, zamanın dışında). CHAPTERS Bölüm 14.
##
## Nihat vaka raporunu yazar. Rapor dünyayı belirler. Daktiloda yazılabilecek raporlar Nihat'ın
## yolculuğuna göre açılır:
##   14.1 "Tarih düzeltildi."                        her zaman (Kurala sadık, N1)
##   14.2 "Rapor tahrifatı."                          Nihat Kuralsızsa (N2)
##   14.3 "Tolga Bey'in Büro'ya alınmasını öneririm."  Tolga tutuklandıysa (11.1) → T4
##   14.4 İstifa.                                     Hikmet ↔ Nihat Dost ya da Ortaksa → N4
##   14.5 (Yeni model Nihat) Rapor otomatik "düzeltildi"  Nihat görevden alındıysa (N3)
## Tutuklandıysa önce Bekleme Salonu: Tolga, 4.582.119 numaralı sırada.
##   --autotest[=forge|recruit|resign|newmodel|wrong]   (varsayılan: 14.1; wrong: Tolga 1977'de, T3)
## Nihat raporu masasında yazar: masanın arkasından dolaşıp sandalyesine oturur, daktilonun başında kalır.

var bureau: Bureau
var player: Player
var hud: Hud
var _outcome := ""
var tolga_npc: Person


func _ready() -> void:
	GameState.snapshot(14)
	_apply_autotest_setup()
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	player.hand_style = "nihat"   # Nihat oynanır: Tolga'nın çantası elde olmaz
	add_child(player)
	player.frozen = true
	hud.set_nihat_mode(true)
	hud.set_fez(false)
	hud.meters.loyalty = float(GameState.flags.get("sadakat", 60))
	hud.meters._shown_loyalty = hud.meters.loyalty
	bureau = Bureau.new()
	add_child(bureau)
	player.global_position = Bureau.SPAWN_POS + Vector3(0, 0.05, 0)
	player.face(Vector3(0, 1.2, 4.3))
	bureau.mufide.look_target = player
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	match GameState.autotest_variant:
		"forge":
			GameState.flags["nihat_rulefree"] = true
		"recruit":
			GameState.flags["tolga_arrested"] = true
			GameState.chapter_outcomes[11] = "11.1"
		"resign":
			GameState.flags["hn_rel"] = 1
		"newmodel":
			GameState.flags["nihat_dismissed"] = true
		"wrong":
			GameState.flags["tolga_fate"] = "T3"


func _run() -> void:
	hud.set_fade(1.0)
	var model: bool = GameState.flags.get("nihat_dismissed", false)
	await hud.card([[tr("UI_CH14_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH14_SUB_NEW" if model else "UI_CH14_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	await hud.fade_to(0.0, 1.0)
	if model:
		await _new_model()
	else:
		await _n("D14_N_01")
		if GameState.flags.get("tolga_arrested", false):
			await _waiting_room()
		await _desk()
	await _end_chapter()


## N3: Yeni model Nihat. Rapor kendiliğinden yazılır; eskisinin masada bir notu vardır.
func _new_model() -> void:
	_mufide_at_door()
	player.face(bureau.mufide.global_position + Vector3(0, 1.5, 0))
	await _say("SPK_MUFIDE", "D14_M_NEW_1")
	# Eskisinin notu: masada, daktilonun yanında tek kâğıt
	var np := Vector3(-0.35, 0.83, 4.15)
	Props.box(bureau, Vector3(0.16, 0.004, 0.12), np, Color("f4eed8"), Vector3(0, 8, 0))
	Props.label(bureau, "Kırmızımsı.", np + Vector3(0, 0.004, 0), 20, Color("8a2020"), Vector3(-90, 188, 0), 0.14)
	await _walk_to_chair()
	await _sit_at_desk()
	player.face(np)
	await _n("D14_NN_2")
	await _say("SPK_MUFIDE", "D14_M_NEW_3")
	await _n("D14_NN_4")
	await hud.card([[tr("UI_CH14_REPORT_HEAD"), 24, Color("f2e6c9")]], 0.1)
	await hud.typewriter(tr("UI_CH14_R_FIXED"), 0.03)
	hud.clear_card()
	await _n("D14_NN_5")
	GameState.flags["nihat_fate"] = "N3"
	GameState.flags["world_fixed"] = true
	_outcome = "14.5"


## 11.1: Bekleme Salonu. Tolga sırada.
func _waiting_room() -> void:
	await hud.fade_to(1.0, 0.5)
	player.global_position = Vector3(-0.3, 0.05, -42.6)
	player.face(Vector3(1.4, 1.0, -46.0))
	tolga_npc = Person.new({"face": "tolga", "coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")})
	tolga_npc.position = Vector3(1.4, 0, -46.0)
	tolga_npc.rotation.y = -PI / 2.0
	tolga_npc.look_target = player
	add_child(tolga_npc)
	Props.box(self, Vector3(0.5, 0.45, 2.4), Vector3(1.55, 0.22, -46.0), Color("6a4a30"))
	Props.label(self, "4.582.119", Vector3(1.9, 2.3, -46.0), 40, Color("ffd08a"), Vector3(0, -90, 0), 1.2)
	tolga_npc.rig.activity = "sit"
	_waiting_crowd()
	await hud.card([[tr("UI_CH14_WAITING"), 28, Color("f2e6c9")]], 1.2)
	hud.clear_card()
	await hud.fade_to(0.0, 0.5)
	await _t("D14_T_W1")
	await _n("D14_N_W2")
	await _t("D14_T_W3")
	await _n("D14_N_W4")
	await hud.fade_to(1.0, 0.5)
	player.global_position = Bureau.SPAWN_POS + Vector3(0, 0.05, 0)
	player.face(Vector3(0, 1.2, 4.3))
	await hud.fade_to(0.0, 0.5)


## Masanın arkası: sandalye (0, 0.48, 5.2), daktilo masanın sağında (0.45, 0.82, 4.25), tuşları sandalyeye dönük.
const CHAIR := Vector3(0.02, 0.05, 5.22)
const BEHIND_DESK := Vector3(1.5, 0.05, 5.2)


## Nihat masanın sağından dolaşıp sandalyenin yanına yürür (masanın önünde, ziyaretçi tarafında oturmasın).
func _walk_to_chair() -> void:
	for p: Vector3 in [Vector3(1.55, 0.05, 2.9), BEHIND_DESK]:
		player.face(p + Vector3(0, 1.4, 0))
		var tw := create_tween()
		tw.tween_property(player, "global_position", p, 0.05 if GameState.autotest else player.global_position.distance_to(p) / 1.6)
		await tw.finished


## Sandalyeye oturur: göz oturma yüksekliğinde, yüzü daktiloya.
func _sit_at_desk() -> void:
	var tw := create_tween()
	tw.tween_property(player, "global_position", CHAIR, 0.05 if GameState.autotest else 0.7)
	player.face(Vector3(0.45, 1.0, 4.25))
	await tw.finished
	player.sit_view(true)
	if not GameState.autotest:
		await get_tree().create_timer(0.5).timeout
	player.face(Vector3(0.45, 0.9, 4.25))


## Müfide Hanım Nihat'ın odasının kapısına gelir ("Kapıdan" der).
func _mufide_at_door() -> void:
	bureau.mufide.position = Vector3(0.15, 0, -0.15)
	bureau.mufide.face_toward(Vector3(0, 0, 3.0))
	bureau.mufide.look_target = player


## Bekleme Salonu: her çağdan sıra bekleyenler. Tolga'nın yanında 1204'ten beri bekleyen bir Haçlı şövalyesi
## ("Burada biri 1204'ten beri bekliyormuş"); karşı bankta bir keşiş, peçeli bir kadın, 1920'lerden şapkalı bir adam.
## Duvarda numaratör: şu an 117. Tolga 4.582.119.
func _waiting_crowd() -> void:
	Props.box(self, Vector3(0.5, 0.45, 2.6), Vector3(1.55, 0.22, -50.0), Color("6a4a30"))
	Props.box(self, Vector3(0.5, 0.45, 2.6), Vector3(-1.55, 0.22, -48.0), Color("6a4a30"))
	var who := [
		[Vector3(1.4, 0, -44.9), -PI / 2.0, {"coat": Color("e8e4d8"), "pants": Color("7a7a80"), "hat": "helm", "beard": true, "skin": Color("e8c0a0")}, "cross"],
		[Vector3(1.4, 0, -49.3), -PI / 2.0, {"coat": Color("3a3028"), "robe": Color("3a3028"), "pants": Color("3a3028"), "hat": "hood", "beard": true, "skin": Color("d8b090")}, ""],
		[Vector3(1.4, 0, -50.7), -PI / 2.0, {"coat": Color("2a4a6a"), "pants": Color("2a2a30"), "skirt": true, "hat": "veil", "skin": Color("e8c0a0")}, ""],
		[Vector3(-1.4, 0, -47.6), PI / 2.0, {"coat": Color("6a5a48"), "pants": Color("4a4038"), "hat": "fedora", "mustache": true, "skin": Color("e0b08a")}, "paper"],
		[Vector3(-1.4, 0, -48.6), PI / 2.0, {"coat": Color("8a2b22"), "pants": Color("2a2a30"), "hat": "fez", "mustache": true, "skin": Color("d8a070")}, ""],
	]
	for e in who:
		var p := Person.new(e[2])
		p.position = e[0]
		p.rotation.y = e[1]
		p.set_meta("no_talk", true)
		add_child(p)
		p.rig.activity = "sit"
		match e[3]:
			"cross":
				# Haçlı cüppesi: göğüste kırmızı haç
				Props.box(p, Vector3(0.07, 0.4, 0.02), Vector3(0, 1.05, 0.25), Color("b3262d"))
				Props.box(p, Vector3(0.26, 0.07, 0.02), Vector3(0, 1.13, 0.25), Color("b3262d"))
			"paper":
				var pp := Node3D.new()
				Props.box(pp, Vector3(0.36, 0.26, 0.01), Vector3.ZERO, Color("f4f1ea"))
				p.hold_item(pp, true)
	# Numaratör: kırmızı rakamlar, siyah kutu
	Props.box(self, Vector3(0.1, 0.5, 1.2), Vector3(-1.9, 2.4, -46.5), Color("15171c"))
	Props.label(self, "117", Vector3(-1.84, 2.4, -46.5), 64, Color("ff3a2a"), Vector3(0, 90, 0), 0.9)
	Props.label(self, "ŞU ANKİ NUMARA", Vector3(-1.84, 2.8, -46.5), 22, Color("f2e6c9"), Vector3(0, 90, 0), 1.2)


func _desk() -> void:
	# Müfide Hanım kapıda belirir; Nihat döner
	_mufide_at_door()
	player.face(bureau.mufide.global_position + Vector3(0, 1.5, 0))
	await _say("SPK_MUFIDE", "D14_M_02")
	# Uçarken görüldüyse: hava sahası ihlali dosyası
	if int(GameState.flags.get("nihat_seen", 0)) > 0:
		await _say("SPK_MUFIDE", "D14_M_SEEN_LEGEND" if GameState.flags.get("flying_legend", false) else "D14_M_SEEN")
		await _n("D14_N_SEEN")
	await _n("D14_N_03")
	# T3: Tolga 1453'te değil, 1977'de (Bölüm 13, yanlış yıl): rapor bunu bilerek yazılır
	if GameState.flags.get("tolga_fate", "") == "T3":
		await _say("SPK_MUFIDE", "D14_M_T3")
		await _n("D14_N_T3")
	# Masanın arkasından dolaşır; sandalyenin arkasındaki Form Z-1'e bakar, sonra oturur
	await _walk_to_chair()
	player.face(Vector3(0, 1.95, 5.8))
	await _n(_z1_key())
	await _sit_at_desk()
	# Açık raporlar
	var keys: Array = ["UI_CH14_R_FIXED_OPT"]
	var ids: Array = ["fixed"]
	if GameState.flags.get("nihat_rulefree", false):
		keys.append("UI_CH14_R_FORGE_OPT")
		ids.append("forge")
	if GameState.flags.get("tolga_arrested", false) or GameState.chapter_outcomes.get(10, "").begins_with("10A"):
		keys.append("UI_CH14_R_RECRUIT_OPT")
		ids.append("recruit")
	if int(GameState.flags.get("hn_rel", 0)) >= 1:
		keys.append("UI_CH14_R_RESIGN_OPT")
		ids.append("resign")
	await _n("D14_N_TYPE")
	var want := GameState.autotest_variant if GameState.autotest_variant in ids else "fixed"
	var c := await hud.choose(keys, 0.0, ids.find(want))
	var pick: String = ids[maxi(c, 0)]
	var text_key: String = {"fixed": "UI_CH14_R_FIXED", "forge": "UI_CH14_R_FORGE", "recruit": "UI_CH14_R_RECRUIT", "resign": "UI_CH14_R_RESIGN"}[pick]
	await hud.card([[tr("UI_CH14_REPORT_HEAD"), 24, Color("f2e6c9")]], 0.1)
	if text_key == "UI_CH14_R_FORGE" and not "chickpeas" in GameState.bag:
		text_key = "UI_CH14_R_FORGE_NOLEB"
	await hud.typewriter(tr(text_key), 0.04)
	hud.clear_card()
	if pick != "resign":
		# Mühür: raporun altına, bir kez, sert
		Audio.sfx("stamp", -4.0)
		var sp := Vector3(0.3, 0.83, 4.1)
		Props.label(bureau, "1453-T", sp, 34, Color("c8262f"), Vector3(-90, 180 - 12, 0), 0.2)
	player.face(bureau.mufide.global_position + Vector3(0, 1.5, 0))
	match pick:
		"fixed":
			await _say("SPK_MUFIDE", "D14_M_FIXED")
			await _n("D14_N_FIXED")
			GameState.flags["nihat_fate"] = "N1"
			GameState.flags["world_fixed"] = true
			_outcome = "14.1"
		"forge":
			await _say("SPK_MUFIDE", "D14_M_FORGE")
			await _n("D14_N_FORGE")
			GameState.flags["nihat_fate"] = "N2"
			_outcome = "14.2"
		"recruit":
			await _say("SPK_MUFIDE", "D14_M_RECRUIT")
			await _n("D14_N_RECRUIT")
			GameState.flags["nihat_fate"] = "N1"
			GameState.flags["tolga_fate"] = "T4"
			_outcome = "14.3"
		"resign":
			# Rozet masaya: pirinç, altı köşe
			var bp := Vector3(-0.2, 0.83, 4.0)
			Props.cyl(bureau, 0.05, 0.012, bp, Color("c49a45"), Vector3.ZERO, 6)
			Props.cyl(bureau, 0.03, 0.014, bp + Vector3(0, 0.002, 0), Color("8a6a2a"), Vector3.ZERO, 12)
			player.face(bp + Vector3(0, 0.3, 0.2))
			await _n("D14_N_RESIGN_1")
			player.face(bureau.mufide.global_position + Vector3(0, 1.5, 0))
			await _say("SPK_MUFIDE", "D14_M_RESIGN")
			await _n("D14_N_RESIGN_2")
			GameState.flags["nihat_fate"] = "N4"
			_outcome = "14.4"


func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(14, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=14 -> 15 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter15.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter15.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW14_TITLE")
	c.nodes = [
		{"id": "desk", "key": "FLOW14_DESK", "pos": Vector2(0.5, 0.15)},
		{"id": "14.1", "key": "FLOW_14_1", "pos": Vector2(0.1, 0.45), "outcome": true},
		{"id": "14.2", "key": "FLOW_14_2", "pos": Vector2(0.3, 0.6), "outcome": true},
		{"id": "14.3", "key": "FLOW_14_3", "pos": Vector2(0.5, 0.45), "outcome": true},
		{"id": "14.4", "key": "FLOW_14_4", "pos": Vector2(0.7, 0.6), "outcome": true},
		{"id": "14.5", "key": "FLOW_14_5", "pos": Vector2(0.9, 0.45), "outcome": true},
	]
	c.edges = [["desk", "14.1"], ["desk", "14.2"], ["desk", "14.3"], ["desk", "14.4"], ["desk", "14.5"]]
	c.taken["desk"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH11_STATS") % [int(GameState.flags.get("sadakat", 60)), int(GameState.flags.get("buro_baskisi", 0)), int(GameState.flags.get("hn_rel", 0))],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW14_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _n(key: String) -> void:
	await hud.say("SPK_NIHAT", key)


func _t(key: String) -> void:
	if tolga_npc:
		tolga_npc.talking = true
	await hud.say("SPK_TOLGA", key)
	if tolga_npc:
		tolga_npc.talking = false


func _say(speaker: String, key: String) -> void:
	if speaker == "SPK_MUFIDE":
		bureau.mufide.talking = true
	await hud.say(speaker, key)
	bureau.mufide.talking = false


func _autotest_report() -> void:
	var expected: String = {"": "14.1", "forge": "14.2", "recruit": "14.3", "resign": "14.4", "newmodel": "14.5", "next": "14.1", "wrong": "14.1"}[GameState.autotest_variant]
	var ok: bool = _outcome == expected and GameState.chapter_outcomes.get(14, "") == _outcome
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=14 variant=%s outcome=%s nihat=%s tolga=%s" % ["PASS" if ok else "FAIL",
		GameState.autotest_variant, _outcome, GameState.flags.get("nihat_fate", ""), GameState.flags.get("tolga_fate", "")])
	get_tree().quit(0 if ok else 1)


func _shot(file_name: String) -> void:
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(file_name))
	print("shot: ", file_name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	# Bekleme Salonu
	player.global_position = Vector3(-0.3, 0.05, -42.6)
	tolga_npc = Person.new({"face": "tolga", "coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")})
	tolga_npc.position = Vector3(1.4, 0, -46.0)
	tolga_npc.rotation.y = -PI / 2.0
	tolga_npc.look_target = player
	add_child(tolga_npc)
	Props.box(self, Vector3(0.5, 0.45, 2.4), Vector3(1.55, 0.22, -46.0), Color("6a4a30"))
	tolga_npc.rig.activity = "sit"
	_waiting_crowd()
	player.face(Vector3(1.0, 0.9, -47.5))
	await get_tree().create_timer(0.8).timeout
	hud.bark("SPK_TOLGA", "D14_T_W1", 30.0)
	await _shot("c14_00a_bekleme.png")
	# Müfide kapıda
	player.global_position = Bureau.SPAWN_POS + Vector3(0, 0.05, 0)
	_mufide_at_door()
	player.face(bureau.mufide.global_position + Vector3(0, 1.5, 0))
	await get_tree().create_timer(0.4).timeout
	hud.bark("SPK_MUFIDE", "D14_M_02", 30.0)
	await _shot("c14_00b_mufide.png")
	# Masada: sandalyede oturur, daktilonun başında
	player.global_position = CHAIR
	player.sit_view(true)
	await get_tree().create_timer(0.6).timeout
	player.face(Vector3(0.45, 0.9, 4.25))
	hud.bark("SPK_NIHAT", "D14_N_TYPE", 30.0)
	hud.choose(["UI_CH14_R_FIXED_OPT", "UI_CH14_R_FORGE_OPT", "UI_CH14_R_RECRUIT_OPT", "UI_CH14_R_RESIGN_OPT"], 0.0, 0)
	await get_tree().create_timer(0.6).timeout
	await _shot("c14_01_son_form.png")
	get_tree().quit()


## Form Z-1 repliği Nihat'ın bildiklerine göre: arşivde (10A) "T."nin kim olduğunu öğrendiyse artık merak etmez.
func _z1_key() -> String:
	if GameState.flags.get("form_z1_signed", false):
		return "D14_N_Z1_KNOWN"
	if GameState.flags.get("refused_bureau", false):
		return "D14_N_Z1_REFUSED"
	# Bölüm 3'te Nihat'ın masasındaki Form Z-1'e bakıldıysa: her sabah günaydın dediği imza
	if GameState.flags.get("seen_z1", false):
		return "D14_N_Z1_SEEN"
	return "D14_N_Z1"
