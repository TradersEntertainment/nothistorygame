extends Node3D
## Bölüm 7 — Saha Çalışması (Nihat · 24 Nisan 1453). CHAPTERS Bölüm 7, §4.3.
##
## Nihat, Büro'nun kapısından 1453'e iner ve Tolga'nın Paradoks İzlerini tarayıcıyla takip eder.
## Tolga'nın Bölüm 6'da hangi yolda olduğuna göre:
##   7a · Ordugâh (6a): mutfak, tercüman çadırı, topçu, pazar izleri; Kadri, Lütfi, Urban,
##        Hasan ile Hüseyin (⏱ çay molası: 7.4). Lütfi'ye form doldurtmak: Sadakat +10.
##   7b · Bizans (6b): kançılarya, surlar, saray, zindan, kapı izleri; Niko, Theodoros
##        (meslek sohbeti: 7.3), Giustiniani, İmparator.
## Gün 12:00'de başlar, 17:00'de güneş batar: her konuşma ve tarama saat harcar.
## Rapor: şüphelinin konumu doğruysa 7.1, yanlışsa 7.2 (Büro Baskısı +2).
## Raporu bekletmek isterken Sadakat < 35 ise ⏱ Yönetmelik Duvarı: formu yırt (7.5a) ya da yırtma (7.5b).
##   --autotest[=tea|lost|form|wall|wallkeep|byz|byzniko|byzcell]   (varsayılan: 7.1, ordugâh, mutfak)

const START_HOUR := 12.0
const SUNSET := 17.0
const TALK_COST := 0.5
const SCAN_COST := 1.0
const WALL_PRESSES := 22
const WALL_SECONDS := 7.0
const CAMP_LOCS := ["kitchen", "tent", "artillery", "market", "otag"]
const BYZ_LOCS := ["chancery", "walls", "palace", "cell", "outside"]
const ROUTE_LOC := {"A": "kitchen", "B": "tent", "C": "artillery", "Y": "market"}
const SPEAKERS := {"kadri": "SPK_KADRI", "lutfi": "SPK_LUTFI", "urban": "SPK_URBAN", "guards": "SPK_HASAN",
	"niko": "SPK_NIKO", "theodoros": "SPK_THEODOROS", "giustiniani": "SPK_GIUST", "emperor": "SPK_EMPEROR"}

var day: CampDay
var city: ByzCity
var player: Player
var hud: Hud
var branch := "7a"
var phase := "intro"
var _outcome := ""
var _busy := false
var _hour := START_HOUR
var _truth := ""
var _route := "A"
var _traces: Dictionary = {}        # konum -> {"node", "kind": hot / warm / cold}
var _scanned: Dictionary = {}
var _talked: Dictionary = {}
var _reporting := false
var hasan: Soldier
var huseyin: Soldier
var door: Node3D
var theodoros: Person
var _wall_layer: Control
var _wall_form_l: ColorRect
var _wall_form_r: ColorRect
var _wall_bar: ColorRect


func _ready() -> void:
	GameState.snapshot(7)
	_apply_autotest_setup()
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	player.hand_style = "nihat"
	add_child(player)
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(_on_focus)
	player.frozen = true
	hud.set_nihat_mode(true)
	hud.set_fez(false)
	hud.meters.loyalty = _loyalty()
	hud.meters._shown_loyalty = _loyalty()
	var ch6: String = GameState.chapter_outcomes.get(6, "6a.1")
	branch = "7b" if ch6.begins_with("6b") else "7a"
	if branch == "7a":
		_route = {"6a.1": "A", "6a.2": "B", "6a.3": "C", "6a.4": "Y"}.get(ch6, GameState.flags.get("route", "A"))
		_truth = ROUTE_LOC[_route]
		_build_camp()
	else:
		_truth = "cell" if ch6 == "6b.3" else "outside"
		_build_city()
	_build_door()
	player.show_remote(true)
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


## Otomatik test ve doğrudan başlatma için önceki bölümlerin sonuçları.
func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	var v := GameState.autotest_variant
	match v:
		"tea", "lost":
			GameState.chapter_outcomes[4] = "4a.2"
		"form":
			GameState.chapter_outcomes[6] = "6a.2"
		"wall", "wallkeep":
			GameState.flags["sadakat"] = 30
		"byz":
			GameState.chapter_outcomes[4] = "4b.1"
			GameState.chapter_outcomes[6] = "6b.1"
		"byzniko":
			GameState.chapter_outcomes[4] = "4b.1"
			GameState.chapter_outcomes[6] = "6b.2"
			GameState.flags["niko_friend"] = true
		"byzcell":
			GameState.chapter_outcomes[4] = "4b.1"
			GameState.chapter_outcomes[6] = "6b.3"


func _process(_delta: float) -> void:
	if hud == null or player == null:
		return
	if phase != "free":
		hud.set_chase("", 0.0)
		player.set_scanner(0.0)
		return
	var best := 999.0
	for loc in _traces:
		if _scanned.has(loc):
			continue
		var d := player.global_position.distance_to((_traces[loc]["node"] as Node3D).global_position)
		best = minf(best, d)
	var v := clampf(1.0 - best / 22.0, 0.0, 1.0)
	hud.set_chase(tr("UI_SCANNER"), v)
	player.set_scanner(v)


func _loyalty() -> float:
	return float(GameState.flags.get("sadakat", 60))


func _add_loyalty(d: int) -> void:
	GameState.flags["sadakat"] = clampi(int(_loyalty()) + d, 0, 100)
	hud.meters.set_loyalty(_loyalty())


# ================================================================ sahne kurulumu

func _build_camp() -> void:
	day = CampDay.new()
	add_child(day)
	day.goat.chase = player
	day.kadri.look_target = player
	day.lutfi.look_target = player
	day.urban.look_target = player
	if day.ring_node:
		day.ring_node.queue_free()
	# Hasan ile Hüseyin: otağ yolunda çay molası
	var g := Vector3(5.2, 0, -26.5)
	hasan = Soldier.new(Color("b3262d"), "stand", "bork")
	hasan.position = g
	hasan.rotation.y = PI * 0.75
	add_child(hasan)
	huseyin = Soldier.new(Color("2f5fa8"), "stand", "bork")
	huseyin.position = g + Vector3(1.4, 0, -0.3)
	huseyin.rotation.y = -PI * 0.8
	add_child(huseyin)
	Props.cyl(self, 0.35, 0.05, g + Vector3(0.7, 0.35, 0.6), Color("8a6440"), Vector3.ZERO, 10)
	Props.cyl(self, 0.05, 0.35, g + Vector3(0.45, 0.17, 0.6), Color("5a4028"), Vector3.ZERO, 5)
	Props.cyl(self, 0.1, 0.16, g + Vector3(0.7, 0.46, 0.6), Color("b87a3a"), Vector3.ZERO, 8, 0.06)
	for i in 3:
		Props.cyl(self, 0.03, 0.06, g + Vector3(0.52 + i * 0.16, 0.41, 0.78), Color("c8603a"), Vector3.ZERO, 6, 0.024)
	Props.interactable(self, "guards", Vector3(3.0, 2.0, 1.6), g + Vector3(0.7, 1.0, 0))
	# İzler
	_trace("kitchen", CampDay.KADRI_POS + Vector3(2.6, 0, 1.8), "shells")
	_trace("tent", CampDay.LUTFI_POS + Vector3(-2.6, 0, 1.8), "page")
	_trace("artillery", CampDay.URBAN_POS + Vector3(3.4, 0, 2.2), "soot")
	_trace("market", Vector3(1.5, 0, 10.5), "thread")
	_trace("otag", Vector3(0.0, 0, -36.0), "none")


func _build_city() -> void:
	city = ByzCity.new()
	add_child(city)
	city.niko.look_target = player
	# Nihat artık oyuncu: Bölüm 6'daki kamera arkası görünüşü kaldırılır
	if city.nihat:
		city.nihat.queue_free()
	var cam_int := city.get_node_or_null("Interact_nihat")
	if cam_int:
		cam_int.queue_free()
	theodoros = city.clerks[6]
	theodoros.look_target = player
	city.giustiniani.look_target = player
	city.emperor.look_target = player
	# Zindan: evin cephesinde demir parmaklıklı kapı
	var cz := Vector3(-4.2, 0, 12.0)
	Props.box(self, Vector3(0.12, 2.2, 1.5), cz + Vector3(0.0, 1.1, 0), Color("2a2622"))
	for i in 6:
		Props.cyl(self, 0.03, 2.1, cz + Vector3(0.1, 1.05, -0.6 + i * 0.24), Color("5a5a60"), Vector3.ZERO, 5)
	for y in [0.5, 1.9]:
		Props.box(self, Vector3(0.06, 0.06, 1.5), cz + Vector3(0.1, y, 0), Color("5a5a60"))
	Props.label(self, "ΦΥΛΑΚΗ", cz + Vector3(0.14, 2.45, 0), 34, Color("5a2a2a"), Vector3(0, 90, 0), 1.6)
	# İzler
	_trace("chancery", Vector3(-2.2, 0, -26.5), "ink")
	_trace("walls", ByzCity.GIUST_POS + Vector3(-3.5, 0, 2.5), "thread")
	_trace("palace", ByzCity.EMPEROR_POS + Vector3(3.2, 0, 2.5), "wax")
	_trace("cell", cz + Vector3(0.9, 0, 0), "shells")
	_trace("outside", ByzCity.EXIT_POS + Vector3(-3.2, 0, -1.5), "flag")


## Büro'nun kapısı: tarlanın ortasında tek başına duran gri bir kapı. Rapor burada yazılır.
func _build_door() -> void:
	door = Node3D.new()
	var base := CampDay.SPAWN + Vector3(0, 0, 2.6) if branch == "7a" else ByzCity.START + Vector3(0, 0, 2.6)
	door.position = base
	add_child(door)
	var frame := Color("8a8f98")
	Props.box(door, Vector3(0.14, 2.4, 0.2), Vector3(-0.62, 1.2, 0), frame)
	Props.box(door, Vector3(0.14, 2.4, 0.2), Vector3(0.62, 1.2, 0), frame)
	Props.box(door, Vector3(1.38, 0.14, 0.2), Vector3(0, 2.4, 0), frame)
	Props.box(door, Vector3(1.1, 2.3, 0.06), Vector3(0, 1.15, 0.02), Color("5a6470"))
	Props.ball(door, 0.04, Vector3(0.4, 1.1, -0.04), Color("d8b070"), Vector3.ONE, 6)
	Props.box(door, Vector3(0.5, 0.22, 0.02), Vector3(0, 1.8, -0.02), Color("efe6cf"))
	Props.label(door, "ZAMAN BÜROSU\nSAHA KAPISI", Vector3(0, 1.8, -0.035), 14, Color("2a2a30"), Vector3(0, 180, 0), 0.48)
	# Kapının önünde daktilo masası
	Props.box(door, Vector3(0.8, 0.05, 0.5), Vector3(1.4, 0.75, -0.3), Color("6a4a30"))
	for k in 4:
		Props.cyl(door, 0.025, 0.75, Vector3(1.1 + (k % 2) * 0.6, 0.375, -0.5 + (k / 2) * 0.4), Color("4a3020"), Vector3.ZERO, 4)
	Props.box(door, Vector3(0.36, 0.12, 0.26), Vector3(1.4, 0.84, -0.3), Color("2a2a30"))
	Props.box(door, Vector3(0.3, 0.2, 0.01), Vector3(1.4, 1.0, -0.2), Color("f4f1ea"), Vector3(-15, 0, 0))
	Props.interactable(door, "report", Vector3(2.6, 2.4, 1.2), Vector3(0.7, 1.2, -0.3))


func _trace(loc: String, pos: Vector3, look: String) -> void:
	var n := Node3D.new()
	n.position = pos
	add_child(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(loc)
	match look:
		"shells":
			for i in 12:
				Props.ball(n, 0.02, Vector3(rng.randf_range(-0.3, 0.3), 0.01, rng.randf_range(-0.25, 0.25)), Color("d9b98a"), Vector3(1.2, 0.5, 1.0), 5)
		"page":
			Props.box(n, Vector3(0.22, 0.004, 0.3), Vector3(0, 0.005, 0), Color("f4f1ea"), Vector3(0, 25, 0))
			Props.box(n, Vector3(0.16, 0.005, 0.02), Vector3(0, 0.008, -0.06), Color("3a3a40"), Vector3(0, 25, 0))
		"soot":
			Props.cyl(n, 0.35, 0.01, Vector3(0, 0.006, 0), Color("2a2622"), Vector3.ZERO, 10)
		"thread":
			for i in 3:
				Props.cyl(n, 0.006, 0.3, Vector3(-0.1 + i * 0.1, 0.01, 0), Color("b3262d") if i != 1 else Color("141414"), Vector3(0, rng.randf_range(0, 180), 90), 4)
		"ink":
			Props.cyl(n, 0.2, 0.008, Vector3(0, 0.005, 0), Color("3a1a4a"), Vector3.ZERO, 9)
			Props.box(n, Vector3(0.18, 0.004, 0.24), Vector3(0.25, 0.006, 0.1), Color("efe6cf"), Vector3(0, -20, 0))
		"wax":
			Props.cyl(n, 0.06, 0.02, Vector3(0, 0.01, 0), Color("b3262d"), Vector3.ZERO, 8)
		"flag":
			Props.box(n, Vector3(0.3, 0.004, 0.2), Vector3(0, 0.005, 0), Color("f4f1ea"), Vector3(0, 40, 0))
	var kind := "cold"
	if loc == _truth:
		kind = "hot"
	elif _was_there(loc):
		kind = "warm"
	var marker := Props.ring(n, 0.24, 0.3, Vector3(0, 0.02, 0), Color("6ff2c8"), Vector3.ZERO, 1.5)
	marker.name = "Marker"
	Props.interactable(n, "trace:" + loc, Vector3(1.2, 0.8, 1.2), Vector3(0, 0.4, 0))
	_traces[loc] = {"node": n, "kind": kind}


## Tolga Bölüm 6'da buradan geçti mi? (Sıcak iz: hâlâ burada. Ilık iz: geçmiş.)
func _was_there(loc: String) -> bool:
	if branch == "7a":
		return loc == "market" or (loc == "otag" and _route != "")
	match loc:
		"chancery":
			return true
		"walls", "palace", "outside":
			return _truth != "cell"
	return false


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH7_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH7_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	var start := door.position + Vector3(0, 0.05, -1.2)
	player.global_position = start
	player.face(start + Vector3(0, 1.4, -10.0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _n("D7_N_ARRIVE")
	await _say("SPK_MUFIDE", "D7_M_BRIEF")
	await _n("D7_N_BRIEF")
	await _say("SPK_MUFIDE", "D7_M_BUDGET")
	await _n("D7_N_SCANNER")
	phase = "free"
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		await _auto()
	while _outcome == "":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	await _end_chapter()


func _update_objective() -> void:
	var h := int(_hour)
	var m := int(round((_hour - h) * 60.0))
	var clock := "%02d:%02d" % [h, m]
	hud.set_objective(tr("UI_OBJ7") % [clock, _scanned.size()])


## Saat harcar. Güneş batarsa rapor zorunlu olur.
func _spend(hours: float) -> void:
	_hour += hours
	_update_objective()
	if _hour >= SUNSET and not _reporting and _outcome == "":
		_reporting = true
		await _n("D7_N_SUNSET")
		await _report()


func _time_left() -> bool:
	return _hour < SUNSET


# ---------------------------------------------------------------- izler

func _scan(loc: String) -> void:
	if _busy or _scanned.has(loc):
		return
	_busy = true
	player.frozen = true
	var node: Node3D = _traces[loc]["node"]
	player.face(node.global_position + Vector3(0, 0.1, 0))
	for i in 5:
		hud.set_prompt(tr("UI_SCANNING") + " " + "▮".repeat(i + 1) + "▯".repeat(4 - i))
		player.set_scanner(float(i) / 4.0)
		await _wait(0.2)
	hud.set_prompt("")
	_scanned[loc] = true
	var marker := node.get_node_or_null("Marker")
	if marker:
		marker.queue_free()
	var kind: String = _traces[loc]["kind"]
	await _n("D7_N_TRACE_%s" % loc.to_upper())
	match kind:
		"hot":
			await _holo(loc)
			await _n("D7_N_HOT")
		"warm":
			await _n("D7_N_WARM")
		_:
			await _n("D7_N_COLD")
	player.frozen = false
	_busy = false
	await _spend(SCAN_COST)


## Sıcak izin hologramı: Tolga'nın burada yaptığı son şey.
func _holo(loc: String) -> void:
	var spot: Vector3 = (_traces[loc]["node"] as Node3D).global_position + Vector3(0.9, 0, -0.6)
	var p := {"coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez"}
	if _route == "A" and branch == "7a":
		p["apron"] = Color("e8e2d4")
	elif _route == "Y" and branch == "7a":
		p["robe"] = Color("7a3a8a")
	var holo := Person.new(p)
	holo.position = spot
	add_child(holo)
	await get_tree().process_frame
	Person.make_hologram(holo)
	holo.rotation.y = atan2(player.global_position.x - spot.x, player.global_position.z - spot.z) + 0.9
	player.face(spot + Vector3(0, 1.0, 0))
	hud.bark("SPK_NIHAT", "D7_N_HOLO_%s" % loc.to_upper(), 3.5)
	await _wait(0.4)
	await holo.stamp()
	await holo.stamp()
	await _wait(1.2)
	var tw := create_tween()
	tw.tween_property(holo, "scale", Vector3(1, 0.01, 1), 0.3)
	await tw.finished
	holo.queue_free()


# ---------------------------------------------------------------- ordugâh tanıkları

func _talk(npc: String, auto_pick := -1) -> void:
	if _busy or _talked.has(npc):
		if _talked.has(npc) and not _busy:
			hud.bark(SPEAKERS[npc], "D7_%s_AGAIN" % npc.to_upper(), 2.5)
		return
	_busy = true
	player.frozen = true
	var node := _npc_node(npc)
	if node:
		player.face(node.global_position + Vector3(0, 1.45, 0))
	_talked[npc] = true
	match npc:
		"kadri":
			await _say("SPK_KADRI", "D7_KADRI_HELLO")
			await _n("D7_N_KADRI_ASK")
			if _route == "A":
				await _say("SPK_KADRI", "D7_KADRI_PROTECT")
				await _n("D7_N_KADRI_FEZ")
			else:
				await _say("SPK_KADRI", "D7_KADRI_NO")
		"urban":
			await _say("SPK_URBAN", "D7_URBAN_HELLO")
			await _n("D7_N_URBAN_ASK")
			if _route == "C":
				await _say("SPK_URBAN", "D7_URBAN_DJINN")
				await _n("D7_N_URBAN_DJINN")
			else:
				await _say("SPK_URBAN", "D7_URBAN_NO")
		"lutfi":
			await _lutfi(auto_pick)
		"guards":
			await _guards(auto_pick)
		"niko":
			await _niko()
		"theodoros":
			await _theodoros(auto_pick)
		"giustiniani":
			await _giust()
		"emperor":
			await _say("SPK_EMPEROR", "D7_EMP_HELLO")
			await _n("D7_N_EMP")
			await _say("SPK_EMPEROR", "D7_EMP_FORM")
	player.frozen = false
	_busy = false
	await _spend(TALK_COST)


func _lutfi(auto_pick: int) -> void:
	await _say("SPK_LUTFI", "D7_LUTFI_HELLO")
	await _n("D7_N_LUTFI_ASK")
	await _say("SPK_LUTFI", "D7_LUTFI_FEE")
	var c := await hud.choose(["UI_CH7_FORM", "UI_CH7_LEAVE"], 0.0, auto_pick if auto_pick >= 0 else 1)
	if c != 0:
		await _n("D7_N_LUTFI_LEAVE")
		return
	# Bir tarihi kişiye form doldurtmak: Sadakat +10
	await _n("D7_N_FORM_GIVE")
	await _say("SPK_LUTFI", "D7_LUTFI_FORM")
	_add_loyalty(10)
	GameState.flags["ch7_form"] = true
	await _say("SPK_LUTFI", "D7_LUTFI_TRUTH_" + _route)
	await _n("D7_N_LUTFI_THANKS")
	_hour += 1.0


func _guards(auto_pick: int) -> void:
	var fans: bool = GameState.chapter_outcomes.get(4, "") == "4a.2"
	await _say("SPK_HASAN", "D7_HASAN_HELLO")
	await _say("SPK_HUSEYIN", "D7_HUSEYIN_HELLO")
	await _n("D7_N_GUARDS_ASK")
	if fans:
		await _say("SPK_HASAN", "D7_HASAN_FAN")
		await _say("SPK_HUSEYIN", "D7_HUSEYIN_FAN")
	# ⏱ Çay molası: katıl (Sadakat −10, 7.4) ya da reddet
	await _say("SPK_HUSEYIN", "D7_HUSEYIN_TEA")
	var pick := auto_pick if auto_pick >= 0 else 1
	var c := await hud.choose(["UI_CH7_TEA", "UI_CH7_NO_TEA"], 8.0, pick)
	if c == 0:
		await _n("D7_N_TEA")
		_add_loyalty(-10)
		GameState.flags["ch7_tea"] = true
		await _say("SPK_HASAN", "D7_HASAN_TEA")
		await _say("SPK_HUSEYIN", "D7_HUSEYIN_TRUTH_" + _route)
		await _n("D7_N_TEA_DONE")
		_hour += 1.0
		return
	await _n("D7_N_NO_TEA")
	if fans:
		# Tolga'yı severler: yanlış yeri gösterirler
		var lie := _lie_loc()
		GameState.flags["ch7_lie"] = lie
		await _say_fmt("SPK_HASAN", "D7_HASAN_LIE", tr("LOC7_" + lie.to_upper()))
		await _say("SPK_HUSEYIN", "D7_HUSEYIN_LIE")
	else:
		await _say("SPK_HASAN", "D7_HASAN_TRUTH_" + _route)
		await _say("SPK_HUSEYIN", "D7_HUSEYIN_WHO")


func _lie_loc() -> String:
	var i := CAMP_LOCS.find(_truth)
	return CAMP_LOCS[(i + 1) % 4]


# ---------------------------------------------------------------- Bizans tanıkları

func _niko() -> void:
	await _say("SPK_NIKO", "D7_NIKO_HELLO")
	await _n("D7_N_NIKO_ASK")
	if GameState.flags.get("niko_friend", false):
		# Dost casusu korur: yanlış yer
		GameState.flags["ch7_lie"] = "palace"
		await _say("SPK_NIKO", "D7_NIKO_LIE")
	elif _truth == "cell":
		await _say("SPK_NIKO", "D7_NIKO_CELL")
	else:
		await _say("SPK_NIKO", "D7_NIKO_OUTSIDE")


func _theodoros(auto_pick: int) -> void:
	await _say("SPK_THEODOROS", "D7_THEO_HELLO")
	await _n("D7_N_THEO_ASK")
	await _say("SPK_THEODOROS", "D7_THEO_FORM_Z9")
	var c := await hud.choose(["UI_CH7_THEO_CHAT", "UI_CH7_THEO_FORM", "UI_CH7_LEAVE"], 0.0, auto_pick if auto_pick >= 0 else 2)
	match c:
		0:
			# Meslek dostluğu: Sadakat −10 (7.3)
			await _n("D7_N_THEO_CHAT")
			await _say("SPK_THEODOROS", "D7_THEO_CHAT")
			await _n("D7_N_THEO_CHAT2")
			await _say("SPK_THEODOROS", "D7_THEO_CHAT2")
			_add_loyalty(-10)
			GameState.flags["ch7_theo"] = true
			await _say("SPK_THEODOROS", "D7_THEO_TRUTH_" + ("CELL" if _truth == "cell" else "OUT"))
			_hour += 1.0
		1:
			await _n("D7_N_FORM_GIVE")
			await _say("SPK_THEODOROS", "D7_THEO_FORM")
			_add_loyalty(10)
			GameState.flags["ch7_form"] = true
			await _say("SPK_THEODOROS", "D7_THEO_TRUTH_" + ("CELL" if _truth == "cell" else "OUT"))
			_hour += 1.0
		_:
			await _n("D7_N_LUTFI_LEAVE")


func _giust() -> void:
	await _say("SPK_GIUST", "D7_GIUST_HELLO")
	await _n("D7_N_GIUST_ASK")
	if _truth == "cell":
		await _say("SPK_GIUST", "D7_GIUST_NO")
		return
	await _say("SPK_GIUST", "D7_GIUST_TRUTH")
	if GameState.flags.get("giustiniani_warned", false):
		await _say("SPK_GIUST", "D7_GIUST_WARNED")
		await _n("D7_N_GIUST_WARNED")


func _npc_node(npc: String) -> Node3D:
	if day:
		match npc:
			"kadri": return day.kadri
			"lutfi": return day.lutfi
			"urban": return day.urban
			"guards": return hasan
	if city:
		match npc:
			"niko": return city.niko
			"theodoros": return theodoros
			"giustiniani": return city.giustiniani
			"emperor": return city.emperor
	return null


# ---------------------------------------------------------------- rapor

## Daktilo başında: şüphelinin konumu. Doğruysa 7.1, yanlışsa 7.2.
func _report() -> void:
	_reporting = true
	_busy = true
	phase = "report"
	player.frozen = true
	hud.set_prompt("")
	player.face(door.global_position + Vector3(1.4, 0.9, -0.3))
	await _n("D7_N_REPORT")
	var locs: Array = CAMP_LOCS if branch == "7a" else BYZ_LOCS
	var keys: Array = []
	for l in locs:
		keys.append("LOC7_" + String(l).to_upper())
	var c := await hud.choose(keys, 0.0, locs.find(_auto_answer()))
	var loc: String = locs[clampi(c, 0, locs.size() - 1)]
	GameState.flags["ch7_report"] = loc
	if loc == _truth:
		await _found(loc)
		_outcome = "7.1"
		await _file_report()
	else:
		await _lost(loc)
		_outcome = "7.2"
	_busy = false


func _auto_answer() -> String:
	match GameState.autotest_variant:
		"lost", "byzniko":
			return GameState.flags.get("ch7_lie", "palace")
	return _truth


## Doğru yer: şüpheli uzaktan görülür (ya da iz şehirden çıkar).
func _found(loc: String) -> void:
	await hud.fade_to(1.0, 0.5)
	var tolga: Person = null
	if loc == "outside":
		hud.set_fade(0.0)
		await _n("D7_N_FOUND_OUT")
		await hud.budget_map(tr("UI_CH7_MAP"), tr("UI_CH7_MAP_FROM"), tr("UI_CH7_MAP_TO"), 3.0)
		await _n("D7_N_BUDGET")
		return
	if loc == "cell":
		player.global_position = (_traces["cell"]["node"] as Node3D).global_position + Vector3(0.8, 0.05, 0.6)
		player.face(Vector3(-4.2, 1.3, 12.0))
		await hud.fade_to(0.0, 0.6)
		await _n("D7_N_FOUND_CELL")
		await _say("SPK_TOLGA", "D7_T_CELL")
		await _n("D7_N_FOUND_CELL2")
		return
	var spot: Vector3 = {"kitchen": CampDay.KADRI_POS + Vector3(1.4, 0, 0.6), "tent": CampDay.LUTFI_POS + Vector3(-1.3, 0, 0.5),
		"artillery": CampDay.URBAN_POS + Vector3(1.3, 0, 0.4), "market": Vector3(-1.5, 0, 12.5), "otag": Vector3(0, 0, -40.0)}.get(loc, Vector3.ZERO)
	var p := {"coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")}
	if _route == "A":
		p["apron"] = Color("e8e2d4")
	elif _route == "Y":
		p["robe"] = Color("7a3a8a")
	tolga = Person.new(p)
	tolga.position = spot
	add_child(tolga)
	var view := spot + Vector3(7.0, 0.05, 6.0)
	player.global_position = view
	player.face(spot + Vector3(0, 1.3, 0))
	tolga.rotation.y = atan2(view.x - spot.x, view.z - spot.z) + 1.3
	await hud.fade_to(0.0, 0.6)
	await _n("D7_N_FOUND")
	tolga.talking = true
	await _say("SPK_TOLGA", "D7_T_FAR_" + _route)
	tolga.talking = false
	await _n("D7_N_FOUND2")


## Yanlış yer: iz kaybedildi. Büro Baskısı +2.
func _lost(loc: String) -> void:
	await hud.fade_to(1.0, 0.5)
	var spot: Vector3 = (_traces[loc]["node"] as Node3D).global_position
	player.global_position = spot + Vector3(2.2, 0.05, 2.2)
	player.face(spot + Vector3(0, 0.5, 0))
	if day:
		day.goat.chase = null
		day.goat.position = spot
		day.goat.set_process(false)
	else:
		var hen := Chicken.new()
		hen.position = spot
		add_child(hen)
	await hud.fade_to(0.0, 0.6)
	await _n("D7_N_LOST_GOAT" if day else "D7_N_LOST_HEN")
	await _say("SPK_MUFIDE", "D7_M_LOST")
	GameState.flags["buro_baskisi"] = int(GameState.flags.get("buro_baskisi", 0)) + 2
	await _n("D7_N_LOST_END")


## Rapor gönderilsin mi? Bekletmek empatik bir seçim: Sadakat < 35 ise Yönetmelik Duvarı.
func _file_report() -> void:
	await hud.fade_to(1.0, 0.5)
	player.global_position = door.global_position + Vector3(1.4, 0.05, -1.3)
	player.face(door.global_position + Vector3(1.4, 0.9, -0.3))
	await hud.fade_to(0.0, 0.5)
	var loc_name := tr("LOC7_" + _truth.to_upper())
	await hud.card([[tr("UI_CH7_REPORT_HEAD"), 24, Color("f2e6c9")]], 0.1)
	await hud.typewriter(tr("UI_CH7_REPORT_TEXT") % loc_name, 0.03)
	await _wait(1.2)
	hud.clear_card()
	await _n("D7_N_SEND_Q")
	var pick := 1 if GameState.autotest_variant in ["wall", "wallkeep"] else 0
	var c := await hud.choose(["UI_CH7_SEND", "UI_CH7_DELAY"], 0.0, pick)
	if c == 0:
		_add_loyalty(5)
		await _n("D7_N_SENT")
		return
	if _loyalty() < 35.0:
		var torn := await _regulation_wall()
		if torn:
			GameState.flags["ch7_wall"] = "torn"
			GameState.flags["nihat_rulefree"] = true
			await _n("D7_N_WALL_TORN")
			await _say("SPK_MUFIDE", "D7_M_WALL_TORN")
		else:
			GameState.flags["ch7_wall"] = "kept"
			GameState.flags["sadakat"] = 50
			hud.meters.set_loyalty(50.0)
			await _n("D7_N_WALL_KEPT")
		return
	_add_loyalty(-5)
	GameState.flags["ch7_delayed"] = true
	await _n("D7_N_DELAYED")


## ⏱ Yönetmelik Duvarı: dev bir yönetmelik metni; formu yırtmak için tuşa art arda bas.
func _regulation_wall() -> bool:
	_build_wall_ui()
	await _n("D7_N_WALL")
	var presses := 0
	var t := 0.0
	var auto_tear: bool = GameState.autotest_variant == "wall"
	hud.set_qte(tr("UI_CH7_TEAR"))
	while t < WALL_SECONDS and presses < WALL_PRESSES:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		if GameState.autotest:
			if auto_tear and fmod(t, 0.2) < dt:
				presses += 1
		elif Input.is_action_just_pressed("advance") or Input.is_action_just_pressed("interact"):
			presses += 1
			player.shake(0.05)
		var v := float(presses) / WALL_PRESSES
		_wall_bar.size.x = 520.0 * v
		_wall_form_l.rotation = -v * 0.25
		_wall_form_r.rotation = v * 0.25
		_wall_form_l.position.x = 380.0 - v * 60.0
		_wall_form_r.position.x = 640.0 + v * 60.0
	hud.set_qte("")
	var torn := presses >= WALL_PRESSES
	var tw := create_tween()
	tw.tween_property(_wall_layer, "modulate:a", 0.0, 0.6)
	await tw.finished
	_wall_layer.queue_free()
	return torn


func _build_wall_ui() -> void:
	_wall_layer = Control.new()
	_wall_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_wall_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(_wall_layer)
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.06, 0.05, 0.93)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_wall_layer.add_child(bg)
	var text := Label.new()
	var lines := PackedStringArray()
	for i in 34:
		lines.append(tr("UI_CH7_WALL_LINE") % [7, i + 1, i * 3 + 2])
	text.text = "\n".join(lines)
	text.add_theme_font_size_override("font_size", 15)
	text.add_theme_color_override("font_color", Color(0.85, 0.35, 0.3, 0.55))
	text.position = Vector2(40, 10)
	_wall_layer.add_child(text)
	var head := Label.new()
	head.text = tr("UI_CH7_WALL_TITLE")
	head.add_theme_font_size_override("font_size", 38)
	head.add_theme_color_override("font_color", Color("ff7a6a"))
	head.position = Vector2(300, 70)
	_wall_layer.add_child(head)
	_wall_form_l = ColorRect.new()
	_wall_form_l.color = Color("efe6cf")
	_wall_form_l.size = Vector2(260, 330)
	_wall_form_l.position = Vector2(380, 190)
	_wall_form_l.pivot_offset = Vector2(260, 330)
	_wall_layer.add_child(_wall_form_l)
	_wall_form_r = ColorRect.new()
	_wall_form_r.color = Color("e8dfc6")
	_wall_form_r.size = Vector2(260, 330)
	_wall_form_r.position = Vector2(640, 190)
	_wall_form_r.pivot_offset = Vector2(0, 330)
	_wall_layer.add_child(_wall_form_r)
	var ft := Label.new()
	ft.text = tr("UI_CH7_WALL_FORM")
	ft.add_theme_font_size_override("font_size", 20)
	ft.add_theme_color_override("font_color", Color("2a2a30"))
	ft.position = Vector2(24, 24)
	_wall_form_l.add_child(ft)
	var ft2 := Label.new()
	ft2.text = tr("UI_CH7_WALL_FORM2")
	ft2.add_theme_font_size_override("font_size", 20)
	ft2.add_theme_color_override("font_color", Color("2a2a30"))
	ft2.position = Vector2(20, 24)
	_wall_form_r.add_child(ft2)
	var back := ColorRect.new()
	back.color = Color(1, 1, 1, 0.15)
	back.size = Vector2(520, 12)
	back.position = Vector2(380, 560)
	_wall_layer.add_child(back)
	_wall_bar = ColorRect.new()
	_wall_bar.color = Color("ff5a4a")
	_wall_bar.size = Vector2(0, 12)
	_wall_bar.position = Vector2(380, 560)
	_wall_layer.add_child(_wall_bar)
	_wall_layer.move_to_front()


# ---------------------------------------------------------------- otomatik test

func _auto() -> void:
	match GameState.autotest_variant:
		"", "wall", "wallkeep", "next":
			await _talk("kadri")
			await _scan("kitchen")
		"tea":
			await _talk("guards", 0)
		"lost":
			await _talk("guards", 1)
		"form":
			await _talk("lutfi", 0)
			await _scan("tent")
		"byz":
			await _talk("theodoros", 0)
			await _scan("outside")
		"byzniko":
			await _talk("niko")
		"byzcell":
			await _scan("cell")
	if _outcome == "":
		await _report()


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	hud.set_chase("", 0.0)
	GameState.set_outcome(7, _outcome)
	for extra in _extras():
		GameState.seen_outcomes[extra] = true
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, false)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	if result == "replay":
		get_tree().reload_current_scene()
	else:
		get_tree().quit()


func _extras() -> Array:
	var a := []
	if GameState.flags.get("ch7_theo", false):
		a.append("7.3")
	if GameState.flags.get("ch7_tea", false):
		a.append("7.4")
	match GameState.flags.get("ch7_wall", ""):
		"torn":
			a.append("7.5a")
		"kept":
			a.append("7.5b")
	return a


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW7_TITLE")
	var side_id := "7.4" if branch == "7a" else "7.3"
	c.nodes = [
		{"id": "arrive", "key": "FLOW7_ARRIVE", "pos": Vector2(0.5, 0.15)},
		{"id": "witness", "key": "FLOW7_WITNESS_A" if branch == "7a" else "FLOW7_WITNESS_B", "pos": Vector2(0.5, 0.28)},
		{"id": side_id, "key": "FLOW_7_4" if branch == "7a" else "FLOW_7_3", "pos": Vector2(0.82, 0.28), "outcome": true},
		{"id": "report", "key": "FLOW7_REPORT", "pos": Vector2(0.5, 0.42)},
		{"id": "7.1", "key": "FLOW_7_1", "pos": Vector2(0.3, 0.56), "outcome": true},
		{"id": "7.2", "key": "FLOW_7_2", "pos": Vector2(0.72, 0.56), "outcome": true},
		{"id": "wall", "key": "FLOW7_WALL", "pos": Vector2(0.3, 0.7)},
		{"id": "7.5a", "key": "FLOW_7_5A", "pos": Vector2(0.14, 0.84), "outcome": true},
		{"id": "7.5b", "key": "FLOW_7_5B", "pos": Vector2(0.46, 0.84), "outcome": true},
	]
	c.edges = [["arrive", "witness"], ["witness", side_id], ["witness", "report"], ["report", "7.1"], ["report", "7.2"],
		["7.1", "wall"], ["wall", "7.5a"], ["wall", "7.5b"]]
	c.taken["arrive"] = true
	c.taken["witness"] = true
	c.taken["report"] = true
	c.taken[_outcome] = true
	for e in _extras():
		c.taken[e] = true
	if GameState.flags.has("ch7_wall"):
		c.taken["wall"] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH7_STATS") % [int(_loyalty()), GameState.paradox, int(GameState.flags.get("buro_baskisi", 0))],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW7_NEXT"),
		tr("UI_FLOW2_REPLAY"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase == "free":
		if SPEAKERS.has(id):
			p = tr("UI_PROMPT3_TALK") % tr(SPEAKERS[id] if id != "guards" else "UI_CH7_GUARDS")
		elif id == "clerk:6":
			p = tr("UI_PROMPT3_TALK") % tr("SPK_THEODOROS")
		elif id.begins_with("trace:") and not _scanned.has(id.trim_prefix("trace:")):
			p = tr("UI_PROMPT7_SCAN")
		elif id == "report":
			p = tr("UI_PROMPT7_REPORT")
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy or phase != "free":
		return
	if id == "clerk:6":
		id = "theodoros"
	if SPEAKERS.has(id):
		_talk(id)
	elif id.begins_with("trace:"):
		_scan(id.trim_prefix("trace:"))
	elif id == "report":
		_report()
	elif id.begins_with("clerk:"):
		hud.bark("SPK_CLERK", "D7_CLERK_QUEUE", 2.5)
	else:
		match id:
			"goat":
				hud.bark("SPK_NIHAT", "D7_N_GOAT", 3.0)
			"cannon":
				hud.bark("SPK_NIHAT", "D7_N_CANNON", 3.5)
			"candarli":
				hud.bark("SPK_CANDARLI", "D7_C_NOBODY", 3.0)
			"letter":
				hud.bark("SPK_SOLDIER", "D7_S_LETTER", 3.0)
			"exit":
				hud.bark("SPK_NIHAT", "D7_N_GATE", 3.0)
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _n(key: String) -> void:
	await hud.say("SPK_NIHAT", key)


func _say(speaker: String, key: String) -> void:
	var who: Node3D = null
	for k in SPEAKERS:
		if SPEAKERS[k] == speaker:
			who = _npc_node(k)
	if who and who is Person:
		(who as Person).talking = true
	await hud.say(speaker, key)
	if who and is_instance_valid(who) and who is Person:
		(who as Person).talking = false


func _say_fmt(speaker: String, key: String, arg: String) -> void:
	await hud.say(speaker, tr(key) % arg)


func _wait(s: float) -> void:
	if GameState.autotest:
		await get_tree().process_frame
		return
	await get_tree().create_timer(s).timeout


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var expected: String = {"": "7.1", "tea": "7.1", "lost": "7.2", "form": "7.1", "wall": "7.1", "wallkeep": "7.1",
		"byz": "7.1", "byzniko": "7.2", "byzcell": "7.1", "next": "7.1"}[GameState.autotest_variant]
	var ok := _outcome == expected
	match GameState.autotest_variant:
		"tea":
			ok = ok and GameState.flags.get("ch7_tea", false)
		"form":
			ok = ok and GameState.flags.get("ch7_form", false)
		"wall":
			ok = ok and GameState.flags.get("ch7_wall", "") == "torn" and GameState.flags.get("nihat_rulefree", false)
		"wallkeep":
			ok = ok and GameState.flags.get("ch7_wall", "") == "kept" and int(_loyalty()) == 50
		"byz":
			ok = ok and GameState.flags.get("ch7_theo", false)
	if GameState.chapter_outcomes.get(7, "") != _outcome:
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=7 variant=%s branch=%s outcome=%s extras=%s sadakat=%d baski=%d hour=%.1f" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, branch, _outcome, str(_extras()), int(_loyalty()),
		int(GameState.flags.get("buro_baskisi", 0)), _hour])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(file_name: String) -> void:
	Engine.time_scale = 0.0
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(file_name))
	Engine.time_scale = 1.0
	print("shot: ", file_name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	await get_tree().create_timer(0.8).timeout
	phase = "free"
	_hour = 13.5
	_update_objective()
	if branch == "7a":
		player.global_position = door.position + Vector3(-0.6, 0.05, -2.0)
		player.face(Vector3(-2.0, 1.2, -20.0))
		hud.bark("SPK_MUFIDE", "D7_M_BRIEF", 30.0)
		await get_tree().create_timer(0.4).timeout
		await _shot("c7_01_saha.png")
		player.global_position = hasan.global_position + Vector3(-1.6, 0.05, 2.4)
		player.face(hasan.global_position + Vector3(0.8, 1.3, 0))
		hud.bark("SPK_HUSEYIN", "D7_HUSEYIN_TEA", 30.0)
		await get_tree().create_timer(0.4).timeout
		await _shot("c7_02_cay.png")
		var n: Node3D = _traces["kitchen"]["node"]
		player.global_position = n.global_position + Vector3(2.4, 0.05, 2.2)
		player.face(n.global_position)
		await get_tree().create_timer(0.3).timeout
		await _shot("c7_03_iz.png")
		phase = "scan"
		_holo_shot("kitchen")
		await get_tree().create_timer(0.6).timeout
		await _shot("c7_04_hologram.png")
		_build_wall_ui()
		_wall_bar.size.x = 300
		_wall_form_l.rotation = -0.14
		_wall_form_r.rotation = 0.14
		hud.set_qte(tr("UI_CH7_TEAR"))
		await _shot("c7_05_duvar.png")
		get_tree().quit()
		return
	player.global_position = theodoros.global_position + Vector3(0.9, 0.05, 2.6)
	player.face(theodoros.global_position + Vector3(0, 1.3, 0))
	hud.bark("SPK_THEODOROS", "D7_THEO_CHAT", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c7_06_theodoros.png")
	var cn: Node3D = _traces["cell"]["node"]
	player.global_position = cn.global_position + Vector3(1.6, 0.05, 1.4)
	player.face(Vector3(-4.2, 1.2, 12.0))
	hud.bark("SPK_NIHAT", "D7_N_TRACE_CELL", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c7_07_zindan.png")
	get_tree().quit()


func _holo_shot(loc: String) -> void:
	var spot: Vector3 = (_traces[loc]["node"] as Node3D).global_position + Vector3(0.9, 0, -0.6)
	var holo := Person.new({"coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "apron": Color("e8e2d4")})
	holo.position = spot
	add_child(holo)
	holo.rotation.y = -0.6
	await get_tree().process_frame
	Person.make_hologram(holo)
	player.face(spot + Vector3(0, 1.0, 0))
	hud.bark("SPK_NIHAT", "D7_N_HOLO_KITCHEN", 30.0)
	holo.stamp()
