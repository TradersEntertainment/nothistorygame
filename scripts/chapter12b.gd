extends Node3D
## Bölüm 12B — Son Akşam (Tolga · 26 Nisan 1453, gün batımı). EXPANSION §2.5.
##
## Bizans'ı Kurtar yolunda (Direniş ≥ 1) Bölüm 12'nin (Fatih'in huzuru) yerine oynanır.
## Konstantinos surlarda, gün batımında Tolga'yla konuşur. Espri yok: Fatih'in huzurundaki
## "Bunu size söyleyemem" sahnesinin aynası.
##   ⏱ "Yaptığın şey yetecek mi?"
##     12B.1 "Bunu size söyleyemem." (dürüst) · 12B.2 "Yetecek." (iyi niyetli yalan) · 12B.3 "Belki bir yıl."
## Dünya Direniş'ten gelir: 1 → W10 (1454), 2 → W11 (1455), 3 → W12 (Ertelendi).
##   --autotest[=lie|year|d2|d3|next]   (varsayılan: 12B.1, Direniş 1)

const WALL_TOP := Vector3(33.3, 12.05, -11.2)
const EMP_AT := Vector3(34.75, 12.0, -8.6)
const SPH_AT := Vector3(33.4, 12.0, -6.4)
const DOOR := Vector3(33.4, 12.0, -5.2)
const WORLDS := {1: "W10", 2: "W11", 3: "W12"}

var city: ByzCity
var player: Player
var hud: Hud
var _outcome := ""
var _direnc := 1
var sphrantzes: Person
var _fires: Array[Node3D] = []
var _torches: Array[Node3D] = []


func _ready() -> void:
	GameState.snapshot(12)
	_apply_autotest_setup()
	_direnc = clampi(int(GameState.flags.get("direnc", 1)), 1, 3)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	hud.set_cinematic(true)
	player.show_remote(true)
	city = ByzCity.new()
	add_child(city)
	city.make_sunset()
	# Güneş ordugâhın üstüne batar (kara surlarının batısı; "Güneş Sultan'ın çadırlarının üstüne batıyor")
	var sun = city.get("_sun")
	if sun:
		sun.rotation_degrees = Vector3(-5, 85, 0)
		sun.light_energy = 1.05
	# Daha geç bir saat: gök koyulaşır, ufuk kızıl, ordugâh alacakaranlıkta (ateşler görünsün)
	var sky = city.get("_sky_mat")
	if sky:
		sky.sky_top_color = Color("262a5c")
		sky.sky_horizon_color = Color("e07840")
		sky.ground_horizon_color = Color("6a4030")
	var env = city.get("_env")
	if env:
		env.fog_light_color = Color("b86a48")
		env.fog_density = 0.006
		env.ambient_light_energy = 0.28
	# İmparator surun üstünde, iki mazgalın arasından dışarıya (ordugâha) bakar
	city.emperor.position = EMP_AT
	city.emperor.rotation.y = PI / 2.0
	city.emperor.look_target = null
	_build_camp_view()
	_build_wall_walk()
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


## Surun yürüyüş yolu (iki kule arası): dış kenarda mazgallar, kulede Palaiologos sancağı, kuleye açılan kapı,
## söndürülmüş meşaleler (sahne sonunda yakılır), uzakta seyrek nöbetçiler (beş bin kişiyle yirmi iki kilometre sur),
## İmparator'un yanında kâtibi ve dostu Yorgi Sfrancis, elinde sayım listesi.
func _build_wall_walk() -> void:
	var x_out := 35.3
	var z := -14.6
	while z < -5.2:
		var m := Props.solid(self, Vector3(0.45, 1.15, 0.75), Vector3(x_out, 12.575, z), Color.WHITE)
		Props.set_pattern(m, Color("e8d8bc"), "ashlar")
		m.set_meta("no_climb", true)
		z += 1.5
	# Kuleye açılan kapı (sahne sonunda İmparator ile Sfrancis buradan içeri girer)
	Props.box(self, Vector3(1.1, 2.2, 0.06), DOOR + Vector3(0, 1.1, 0.17), Color("1c1614"))
	Props.ball(self, 0.55, DOOR + Vector3(0, 2.2, 0.17), Color("1c1614"), Vector3(1, 0.6, 0.12), 10)
	# Palaiologos sancağı: kırmızı zemin, altın haç, haçın dört köşesinde dört B (Basileus basileon basileuon basileuonton)
	var fp := Vector3(34.0, 16.9, -2.0)
	Props.cyl(self, 0.06, 5.0, fp + Vector3(0, 2.5, 0), Color("5a4028"), Vector3.ZERO, 6)
	var flag := Node3D.new()
	flag.position = fp + Vector3(0, 4.1, -0.05)
	add_child(flag)
	Props.box(flag, Vector3(0.04, 1.4, 2.0), Vector3(0, 0, -1.0), Color("b0202a"))
	Props.box(flag, Vector3(0.05, 1.3, 0.14), Vector3(0.01, 0, -1.0), Color("e0b030"))
	Props.box(flag, Vector3(0.05, 0.14, 1.9), Vector3(0.01, 0, -1.0), Color("e0b030"))
	for q in [Vector2(-0.4, -0.45), Vector2(-0.4, -1.55), Vector2(0.38, -0.45), Vector2(0.38, -1.55)]:
		Props.label(flag, "B", Vector3(0.035, q.x, q.y), 40, Color("e0b030"), Vector3(0, 90, 0), 0.3)
		Props.label(flag, "B", Vector3(-0.035, q.x, q.y), 40, Color("e0b030"), Vector3(0, -90, 0), 0.3)
	var ftw := flag.create_tween().set_loops()
	ftw.tween_property(flag, "rotation:y", 0.12, 1.6).set_trans(Tween.TRANS_SINE)
	ftw.tween_property(flag, "rotation:y", -0.08, 1.6).set_trans(Tween.TRANS_SINE)
	# Söndürülmüş meşaleler (iç kenarda)
	for tz: float in [-14.2, -7.4, -5.8]:
		var t := Node3D.new()
		t.position = Vector3(32.75, 12.0, tz)
		add_child(t)
		Props.cyl(t, 0.05, 1.7, Vector3(0, 0.85, 0), Color("4a3020"), Vector3.ZERO, 5)
		Props.cyl(t, 0.09, 0.2, Vector3(0, 1.72, 0), Color("2a2a2a"), Vector3.ZERO, 6)
		var fl := Props.cyl(t, 0.1, 0.35, Vector3(0, 1.97, 0), Color("ffb030"), Vector3.ZERO, 5, 0.0)
		fl.material_override = Props.mat(Color("ffc050"), 3.0, false, "", false)
		fl.visible = false
		fl.name = "Flame"
		var l := OmniLight3D.new()
		l.position = Vector3(0, 2.2, 0)
		l.light_color = Color("ff9a40")
		l.light_energy = 0.0
		l.omni_range = 7.0
		l.name = "Light"
		t.add_child(l)
		_torches.append(t)
	# Seyrek nöbetçiler: yolun ucunda biri, kule tepelerinde birer gözcü (koca surda bir avuç insan)
	Garrison.man(self, Vector3(33.9, 12.0, -14.2), PI * 0.5, 1210, "spear")
	Garrison.man(self, Vector3(34.6, 16.0, -18.0), PI * 0.5, 1211, "bow")
	Garrison.man(self, Vector3(34.6, 16.0, -1.2), PI * 0.5, 1212, "spear")
	# Sfrancis: koyu mavi kaftan, sakallı; elinde sayım listesi (rulo)
	sphrantzes = Person.new({"coat": Color("2a3a5a"), "robe": Color("2a3a5a"), "pants": Color("2a2a30"), "beard": true, "mustache": true,
		"hair": Color("5a4a3a"), "hat": "skiadion", "skin": Color("e0b894")})
	sphrantzes.position = SPH_AT
	sphrantzes.set_meta("no_talk", true)
	add_child(sphrantzes)
	sphrantzes.face_toward(EMP_AT)
	var arm: Node3D = sphrantzes.rig.arm_r if sphrantzes.rig else null
	if arm:
		Props.cyl(arm, 0.05, 0.34, Vector3(0.02, -0.6, 0.1), Color("efe6cf"), Vector3(0, 0, 90), 8)


## Surların dışı: ovada Osmanlı ordugâhı. Gün batımında çadırlar ve yanmaya başlayan ateşler (boş ufuk yok).
func _build_camp_view() -> void:
	# Şehrin 400 m'lik dolgu zemininin (üstü y=-0.02) üstünde kalsın: ova surdan dışarıda
	var ground := Props.box(self, Vector3(420, 0.2, 360), Vector3(247, -0.08, -10), Color("6a6440"))
	ground.material_override = Props.mat(Color("6a6440"), 0.0, false, "", false)
	# Ön hat: hendeğin karşısında kazık çit (palisad) ve toprak tabyalarda büyük toplar
	var zp := -70.0
	while zp < 60.0:
		Props.cyl(self, 0.12, 2.2, Vector3(62.0, 1.1, zp), Color("5a4028"), Vector3(0, 0, randf_range(-4, 4)), 5)
		zp += 0.6
	for bz: float in [-30.0, -8.0, 16.0]:
		Props.box(self, Vector3(4.0, 1.4, 8.0), Vector3(66.0, 0.7, bz), Color("7a6440"))
		Props.cyl(self, 0.55, 5.5, Vector3(66.5, 1.9, bz), Color("8a6a3a"), Vector3(0, 0, 90), 12)
		Props.cyl(self, 0.35, 0.2, Vector3(63.7, 1.9, bz), Color("1a1410"), Vector3(0, 0, 90), 12)
	# Hendek ve dış sur
	Props.box(self, Vector3(8, 0.3, 120), Vector3(44, -0.25, -10), Color("3a4a3a"))
	Props.set_pattern(Props.box(self, Vector3(2.0, 7.0, 120.0), Vector3(50, 3.5, -10), Color.WHITE), Color("e8d8c0"), "ashlar")
	for z in [-60.0, -40.0, -20.0, 0.0, 20.0, 40.0]:
		Props.set_pattern(Props.box(self, Vector3(5.0, 10.0, 5.0), Vector3(50, 5.0, z), Color.WHITE), Color("e0d0b8"), "ashlar")
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var colors := [Color("d8cbb0"), Color("c8b894"), Color("e0d4b8"), Color("b8a888")]
	var bands := [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a"), Color("c98a3a")]
	for i in 170:
		var p := Vector3(rng.randf_range(72.0, 300.0), 0, rng.randf_range(-150.0, 130.0))
		var t := Night.tent(self, p, rng.randf_range(1.8, 3.4), colors[i % 4], bands[i % 4])
		t.rotation.y = rng.randf() * TAU
	# Otağ: uzakta, kırmızı-altın
	Props.cyl(self, 9.0, 6.0, Vector3(170, 3.0, -10), Color("b3262d"), Vector3.ZERO, 16)
	Props.cyl(self, 9.4, 5.0, Vector3(170, 8.5, -10), Color("c8323a"), Vector3.ZERO, 16, 0.4)
	Props.ball(self, 0.8, Vector3(170, 11.5, -10), Color("d8b040"), Vector3.ONE, 8)
	# Ateşler: sıcak ışık noktaları ve ince duman
	for i in 64:
		# Yakındakiler daha seyrek, ordugâhın içi daha sık: ateş sayısı ordunun büyüklüğünü anlatır
		var x := 66.0 + pow(rng.randf(), 0.8) * 214.0
		var p := Vector3(x, 0.0, rng.randf_range(-140.0, 120.0))
		var fire := Node3D.new()
		fire.position = p
		add_child(fire)
		var sz := 1.0 + (x - 66.0) / 214.0 * 1.6        # uzaktakiler de seçilsin
		var fl := Props.ball(fire, 0.7 * sz, Vector3(0, 0.7 * sz, 0), Color("ffa040"), Vector3(1.0, 1.7, 1.0), 6, 5.0)
		fl.material_override = Props.mat(Color("ffa040"), 5.0, false, "", false)
		var core := Props.ball(fire, 0.4 * sz, Vector3(0, 0.55 * sz, 0), Color("fff0a0"), Vector3(1.0, 1.5, 1.0), 6, 6.0)
		core.material_override = Props.mat(Color("fff0a0"), 6.0, false, "", false)
		fire.scale = Vector3.ONE * 0.01       # akşam yaklaştıkça birer birer yanar (_light_fires)
		_fires.append(fire)
		if i % 5 == 0:
			var l := OmniLight3D.new()
			l.position = Vector3(0, 1.5, 0)
			l.light_color = Color("ff9a4a")
			l.light_energy = 2.5
			l.omni_range = 16.0
			fire.add_child(l)
	# Uzakta tepeler (ufuk kapanır)
	for i in 9:
		var hp := Vector3(330.0 + rng.randf_range(-20.0, 20.0), -6.0, -200.0 + i * 50.0)
		Props.ball(self, rng.randf_range(40.0, 70.0), hp, Color("6a6048"), Vector3(1.0, 0.45, 1.3), 10)


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	GameState.chapter_outcomes[10] = "10H.1"
	var f := GameState.flags
	f["direnc"] = {"d2": 2, "d3": 3}.get(GameState.autotest_variant, 1)
	f["breach_taped"] = true


func _wait(sec: float) -> void:
	await get_tree().create_timer(0.05 if GameState.autotest else sec).timeout


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	Audio.music("byzantium_evening" if ResourceLoader.exists("res://assets/audio/music/byzantium_evening.ogg") else "tender")
	await hud.card([[tr("UI_CH12B_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH12B_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.gravity_on = false
	player.global_position = WALL_TOP
	player.face(Vector3(90.0, 8.0, -12.0))
	await hud.fade_to(0.0, 1.4)
	await _wait(1.5)
	player.face(city.emperor.global_position + Vector3(0, 1.5, 0))
	city.emperor.look_target = player
	await _k("D12B_K_01")
	await _t("D12B_T_02")
	# Gece yapılanları İmparator biliyor
	var f := GameState.flags
	if f.get("breach_taped", false) or _direnc >= 1:
		await _k("D12B_K_DONE_%d" % _direnc)
	# Dört gün önce: gemiler karadan Haliç'e (Tolga o kızaklardan birinden kaymıştı, Bölüm 2)
	await _k("D12B_K_SHIPS")
	await _t("D12B_T_SHIPS")
	# Güneş ordugâhın üstüne batar; şehirde akşam duası için çanlar çalar
	city.emperor.look_target = null
	city.emperor.face_toward(Vector3(90.0, 12.0, -8.6))
	player.face(Vector3(90.0, 9.0, -10.0))
	Audio.sfx("church_bell", -8.0, 0.9)
	await _k("D12B_K_03")
	_light_fires(9.0)
	await _t("D12B_T_04")
	# Sfrancis'in sayımı: surları tutacak adamlar (kuşatmadan önce, gizli)
	sphrantzes.emote("nod")
	player.face(city.emperor.global_position + Vector3(0, 1.5, 0))
	await _k("D12B_K_COUNT")
	await _t("D12B_T_COUNT")
	await _k("D12B_K_COUNT2")
	city.emperor.look_target = player
	await _k("D12B_K_Q")
	var pick: int = {"lie": 1, "year": 2}.get(GameState.autotest_variant, 0)
	var c := await hud.choose(["UI_CH12B_CANT_SAY", "UI_CH12B_LIE", "UI_CH12B_YEAR"], 12.0, pick)
	match c:
		1:
			await _t("D12B_T_LIE")
			await _k("D12B_K_LIE")
			_outcome = "12B.2"
		2:
			await _t("D12B_T_YEAR")
			await _k("D12B_K_YEAR")
			_outcome = "12B.3"
		_:
			await _t("D12B_T_CANT_SAY")
			await _k("D12B_K_CANT_SAY")
			GameState.flags["honest_with_sultan"] = true
			GameState.flags["byz_honest"] = true
			_outcome = "12B.1"
	await _wait(1.0)
	await _k("D12B_K_END")
	# Her akşamki gibi: İmparator ile Sfrancis surları dolaşmaya gider; arkalarında meşaleler yakılır
	city.emperor.look_target = sphrantzes
	await _k("D12B_K_WALK")
	city.emperor.look_target = null
	var tw := create_tween().set_parallel(true)
	tw.tween_property(city.emperor, "position", DOOR + Vector3(0.35, 0, -0.9), _d(3.2))
	tw.tween_property(sphrantzes, "position", DOOR + Vector3(-0.35, 0, -1.3), _d(2.8))
	player.face(DOOR + Vector3(0, 1.5, 0))
	_light_torches()
	await tw.finished
	for n in [city.emperor, sphrantzes]:
		var t2 := create_tween()
		t2.tween_property(n, "position", DOOR + Vector3(0, 0, 0.4), _d(0.9))
	await _wait(1.0)
	city.emperor.visible = false
	sphrantzes.visible = false
	player.face(Vector3(90.0, 7.0, -10.0))
	await _wait(2.2)
	await hud.fade_to(1.0, 1.4)
	await hud.say("SPK_HIKMET", "D12B_H_RADIO")
	await _t("D12B_T_RADIO")
	GameState.flags["world10"] = WORLDS[_direnc]
	GameState.flags["world"] = WORLDS[_direnc]
	await _end_chapter()


func _d(sec: float) -> float:
	return 0.05 if GameState.autotest else sec


## Ordugâhın ateşleri birer birer yanar (dur süresinde hepsi).
func _light_fires(dur: float) -> void:
	var order := _fires.duplicate()
	order.shuffle()
	for i in order.size():
		var fire: Node3D = order[i]
		var t := create_tween()
		t.tween_interval(_d(dur) * float(i) / order.size())
		t.tween_property(fire, "scale", Vector3.ONE, _d(0.6))


## Surdaki meşaleler: bir nöbetçi sırayla yakıyormuş gibi, arka arkaya.
func _light_torches() -> void:
	for i in _torches.size():
		var t := _torches[i]
		var tw := create_tween()
		tw.tween_interval(_d(0.9 + i * 0.9))
		tw.tween_callback(func():
			(t.get_node("Flame") as Node3D).visible = true
			Audio.sfx("fire_crackle", -18.0, 1.2))
		tw.tween_property(t.get_node("Light"), "light_energy", 2.2, _d(0.5))


func _k(key: String) -> void:
	city.emperor.talking = true
	await hud.say("SPK_EMPEROR", key)
	city.emperor.talking = false


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	GameState.set_outcome(12, _outcome)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		var nxt := Siege.gate("res://scenes/chapter13.tscn")
		print("AUTOTEST chapter=12b -> %s outcome=%s" % [nxt.get_file().get_basename().trim_prefix("chapter"), _outcome])
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file(nxt)
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file(Siege.gate("res://scenes/chapter13.tscn"))
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW12B_TITLE")
	c.nodes = [
		{"id": "walls", "key": "FLOW12B_WALLS", "pos": Vector2(0.5, 0.14)},
		{"id": "12B.1", "key": "FLOW_12B_1", "pos": Vector2(0.18, 0.42), "outcome": true},
		{"id": "12B.2", "key": "FLOW_12B_2", "pos": Vector2(0.5, 0.42), "outcome": true},
		{"id": "12B.3", "key": "FLOW_12B_3", "pos": Vector2(0.82, 0.42), "outcome": true},
		{"id": "W10", "key": "FLOW12B_W10", "pos": Vector2(0.18, 0.7)},
		{"id": "W11", "key": "FLOW12B_W11", "pos": Vector2(0.5, 0.7)},
		{"id": "W12", "key": "FLOW12B_W12", "pos": Vector2(0.82, 0.7)},
	]
	c.edges = [["walls", "12B.1"], ["walls", "12B.2"], ["walls", "12B.3"], ["12B.1", "W10"], ["12B.2", "W11"], ["12B.3", "W12"]]
	c.taken["walls"] = true
	c.taken[_outcome] = true
	c.taken[WORLDS[_direnc]] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH12B_STATS") % [_direnc, tr("FATE_" + String(WORLDS[_direnc]))],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW12B_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "12B.1", "lie": "12B.2", "year": "12B.3", "d2": "12B.1", "d3": "12B.1", "next": "12B.1"}[v]
	var world: String = GameState.flags.get("world10", "")
	var want_world: String = {"d2": "W11", "d3": "W12"}.get(v, "W10")
	var ok: bool = _outcome == expected and world == want_world and GameState.chapter_outcomes.get(12, "") == _outcome
	if not ok:
		printerr("AUTOTEST: beklenen %s/%s, gelen %s/%s" % [expected, want_world, _outcome, world])
	print("AUTOTEST %s chapter=12b variant=%s outcome=%s world=%s honest=%s" % ["PASS" if ok else "FAIL", v, _outcome, world,
		str(GameState.flags.get("honest_with_sultan", false))])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.gravity_on = false
	# 1) İmparator ve Sfrancis, arkada ordugâhın ateşleri yanıyor
	_light_fires(0.1)
	player.global_position = WALL_TOP + Vector3(-0.2, 0, -1.6)
	player.face(city.emperor.global_position + Vector3(2.0, 1.3, 0.4))
	await get_tree().create_timer(0.8).timeout
	hud.bark("SPK_EMPEROR", "D12B_K_COUNT2", 30.0)
	await _snap("c12b_01_son_aksam.png")
	# 2) Mazgalın arasından ordugâh: çit, toplar, ateşler
	player.global_position = WALL_TOP + Vector3(1.2, 0, 0.2)
	player.face(Vector3(80.0, 6.0, -14.0))
	hud.bark("SPK_EMPEROR", "D12B_K_03", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _snap("c12b_02_ordugah.png")
	# 3) Gel, Yorgi: kuleye yürüyüş, meşaleler yanmış
	_light_torches()
	await get_tree().create_timer(3.8).timeout
	city.emperor.position = DOOR + Vector3(0.35, 0, -1.6)
	city.emperor.face_toward(DOOR)
	sphrantzes.position = DOOR + Vector3(-0.35, 0, -2.0)
	sphrantzes.face_toward(DOOR)
	player.global_position = WALL_TOP
	player.face(DOOR + Vector3(0, 1.2, 0))
	hud.bark("SPK_EMPEROR", "D12B_K_WALK", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _snap("c12b_03_yorgi.png")
	get_tree().quit()


func _snap(name: String) -> void:
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)
