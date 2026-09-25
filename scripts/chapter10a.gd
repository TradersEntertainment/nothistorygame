extends Node3D
## Bölüm 10A — Arşiv (Tolga · 25 Nisan 1453). CHAPTERS Bölüm 10, STORY_BRANCHES Son 9.
##
## 9.5'te Theodoros'un teklifi kabul edildi: Tolga Bizans arşivinde "meslektaş".
##   1. Arşiv düzeni: masadaki dosyaları renk koduna göre üç rafa yerleştir (plaza yöntemi; 🧊 varsa
##      Rubik küpünün renkleri). Yanlış raf: Theodoros iç çeker.
##   2. Nihat belirir, arşivde Form Z-1'i görür: Zaman Bürosu'nun kuruluş belgesi. İmza yeri boş: "T."
##   3. "Yerel makam onayı": Nihat Tolga'yı otağa götürür, Fatih formu okur ve imzalar:
##      "Bürokrasinin en iyisi, kısa olanıdır."
##   4. ⏱ Tolga imzalar ("T.") → 10A.1 Büronun Kuruluşu (W8): ilk Büro toplantısı, gündem maddesi 1
##      ya da son anda reddeder ("Ben sigortacıyım.") → 10A.2 → Bölüm 11 → 12
##   --autotest[=refuse|next]   (varsayılan: 10A.1)

const TABLE := Vector3(0.0, 0.0, -2.0)
const SHELVES := {"red": Vector3(-6.2, 0.0, -8.0), "blue": Vector3(0.0, 0.0, -10.6), "green": Vector3(6.2, 0.0, -8.0)}
const SHELF_COLORS := {"red": Color("c8323a"), "blue": Color("2f5fa8"), "green": Color("3a8a4a")}
const DOCS := ["red", "blue", "green", "blue", "red", "green"]
const FORM_AT := Vector3(-7.9, 2.2, -2.0)
const SHELF_PLANKS := [0.9, 1.8, 2.7]    # renk kodlu rafların kat yükseklikleri
const HEN_AT := Vector3(0.6, 3.53, -10.2) # "Rafta bir tavuk var": mavi rafın tepesinde, 1204'ten beri
const OTAG_OFFSET := Vector3(300.0, 0.0, 0.0)

var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _busy := false
var _doc := -1                  # elimdeki dosyanın indeksi (-1 yok)
var _placed := 0
var _mistakes := 0
var theodoros: Person
var nihat: Person
var archive: Node3D
var _env: WorldEnvironment
var hall: OtagHall
var _pile: Array[MeshInstance3D] = []
var _on_shelf := {}


func _ready() -> void:
	GameState.snapshot(10)
	_apply_autotest_setup()
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(_on_focus)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	player.show_remote(true)
	_build_archive()
	theodoros = Person.new({"coat": Color("5a3a6a"), "pants": Color("3a2a4a"), "hat": "kamelaukion", "robe": Color("5a3a6a"),
		"beard": true, "hair": Color("6a6a6a"), "skin": Color("e0b08a")})
	theodoros.position = TABLE + Vector3(-2.0, 0, 0.8)
	theodoros.look_target = player
	archive.add_child(theodoros)
	nihat = Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
		"hair": Color("3a2a1e"), "skin": Color("ecb892")})
	nihat.visible = false
	add_child(nihat)
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	GameState.chapter_outcomes[9] = "9.5"
	GameState.chapter_outcomes[6] = "6b.1"
	GameState.chapter_outcomes[4] = "4b.1"


func _d(sec: float) -> float:
	return 0.05 if GameState.autotest else sec


func _wait(sec: float) -> void:
	await get_tree().create_timer(_d(sec)).timeout


# ================================================================ sahne

func _make_env() -> void:
	_env = WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("1a1410")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("c89868")
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.4
	_env.environment = e
	add_child(_env)


## Bizans arşivi: tavana kadar raflar, rulolar, mum ışığı, pencereden süzülen gün ışığı.
func _build_archive() -> void:
	archive = Node3D.new()
	add_child(archive)
	Audio.voice_space("hall")
	_make_env()
	var a := archive
	Props.set_pattern(Props.solid(a, Vector3(18, 0.2, 26), Vector3(0, -0.1, -2), Color.WHITE), Color("b8a888"), "marble")
	for w in [[Vector3(18, 7, 0.3), Vector3(0, 3.5, -13)], [Vector3(0.3, 7, 26), Vector3(-9, 3.5, -2)], [Vector3(0.3, 7, 26), Vector3(9, 3.5, -2)],
			[Vector3(18, 7, 0.3), Vector3(0, 3.5, 9)]]:
		Props.set_pattern(Props.solid(a, w[0], w[1], Color.WHITE), Color("d8c8a8"), "plaster")
	Props.box(a, Vector3(18, 0.3, 26), Vector3(0, 7.0, -2), Color("6a4a30"))
	for x in [-6.0, -2.0, 2.0, 6.0]:
		Props.box(a, Vector3(0.3, 0.4, 26), Vector3(x, 6.7, -2), Color("4a3020"))
	# Duvar rafları, rulolar
	var rng := RandomNumberGenerator.new()
	rng.seed = 1204
	for side in [-1, 1]:
		for z in range(-11, 8, 3):
			Props.box(a, Vector3(0.6, 5.6, 2.6), Vector3(side * 8.5, 2.8, z), Color("5a3a24"))
			for shelf in 5:
				for k in 4:
					var col: Color = [Color("efe6cf"), Color("e0d4b0"), Color("d8c8a0")][rng.randi() % 3]
					Props.cyl(a, 0.12, 0.5, Vector3(side * 8.25, 0.5 + shelf * 1.1, z - 0.9 + k * 0.6), col, Vector3(0, 0, 90), 6)
	# Üç renk kodlu raf (Tolga'nın sistemi)
	# Açık raf: arka pano, yan dikmeler, üç kat; üstlerinde eski dosyalar ve rulolar (boş duvar gibi durmasın)
	for id in SHELVES:
		var p: Vector3 = SHELVES[id]
		var wood := Color("6a4a2c")
		var body := Props.solid(a, Vector3(3.0, 3.2, 0.1), p + Vector3(0, 1.6, -0.35), wood.darkened(0.25))
		for sx in [-1.45, 1.45]:
			Props.box(a, Vector3(0.1, 3.2, 0.8), p + Vector3(sx, 1.6, 0), wood)
		for py: float in SHELF_PLANKS:
			Props.box(a, Vector3(2.9, 0.06, 0.75), p + Vector3(0, py, 0), wood.lightened(0.05))
		Props.box(a, Vector3(3.0, 0.08, 0.8), p + Vector3(0, 3.2, 0), wood)
		# Alt ve üst katlarda eski dosyalar, rulolar; orta kat Tolga'nın sistemine boş bırakılır
		for py: float in [SHELF_PLANKS[0], SHELF_PLANKS[2]]:
			for k in 7:
				var x := -1.2 + k * 0.4
				if rng.randf() < 0.55:
					Props.box(a, Vector3(0.08, 0.34, 0.5), p + Vector3(x, py + 0.2, 0), [Color("8a6a44"), Color("6a4a30"), Color("a88a5a")][rng.randi() % 3], Vector3(0, 0, rng.randf_range(-8, 8)))
				else:
					Props.cyl(a, 0.08, 0.5, p + Vector3(x, py + 0.11, 0), Color("efe6cf"), Vector3(90, 0, 0), 6)
		var lbl := Props.box(a, Vector3(3.1, 0.35, 0.05), p + Vector3(0, 3.35, 0.42), SHELF_COLORS[id])
		lbl.material_override = Props.mat(SHELF_COLORS[id], 0.6)
		Props.interactable(a, "shelf_" + id, Vector3(3.0, 3.0, 1.4), p + Vector3(0, 1.5, 0.5))
	# 1204'ten beri rafta oturan tavuk
	var hen := Chicken.new()
	hen.position = HEN_AT
	hen.rotation.y = 0.4
	hen.scale = Vector3.ONE * 1.5
	a.add_child(hen)
	# Masa, mühür, dosya yığını
	Props.solid(a, Vector3(3.2, 0.9, 1.6), TABLE + Vector3(0, 0.45, 0), Color("6a4a30"))
	Props.cyl(a, 0.1, 0.12, TABLE + Vector3(1.1, 0.96, 0.3), Color("8a2b22"), Vector3.ZERO, 8)
	for i in DOCS.size():
		var d := Props.box(a, Vector3(0.55, 0.06, 0.4), TABLE + Vector3(-0.5, 0.94 + i * 0.07, -0.1), SHELF_COLORS[DOCS[i]].lightened(0.25))
		_pile.append(d)
	Props.interactable(a, "table", Vector3(3.2, 1.2, 1.8), TABLE + Vector3(0, 0.8, 0))
	# Form Z-1: çerçeveli, duvarda (Büro'nun odasındakinin aslı)
	Props.box(a, Vector3(0.08, 1.5, 1.1), FORM_AT, Color("c8a040"))
	if ResourceLoader.exists("res://assets/art/posters/form_z1.svg"):
		Props.picture(a, "res://assets/art/posters/form_z1.svg", 0.9, FORM_AT + Vector3(0.06, 0, 0), Vector3(0, 90, 0))
	else:
		Props.box(a, Vector3(0.02, 1.3, 0.9), FORM_AT + Vector3(0.05, 0, 0), Color("efe6cf"))
	# Mumlar ve pencere ışığı
	for p in [TABLE + Vector3(-1.3, 1.0, 0.5), TABLE + Vector3(1.3, 1.0, -0.5), Vector3(-6.5, 2.2, 4.0), Vector3(6.5, 2.2, 4.0)]:
		Props.cyl(a, 0.04, 0.2, p, Color("f4f1ea"), Vector3.ZERO, 6)
		var fl := Props.ball(a, 0.04, p + Vector3(0, 0.14, 0), Color("ffd070"), Vector3(1, 1.6, 1), 6, 3.0)
		fl.material_override = Props.mat(Color("ffd070"), 3.0, false, "", false)
		var l := OmniLight3D.new()
		l.position = p + Vector3(0, 0.3, 0)
		l.light_color = Color("ffc070")
		l.light_energy = 1.0
		l.omni_range = 6.0
		a.add_child(l)
	var shaft := SpotLight3D.new()
	shaft.position = Vector3(0, 6.6, -2)
	shaft.rotation_degrees = Vector3(-90, 0, 0)
	shaft.spot_angle = 40.0
	shaft.spot_range = 10.0
	shaft.light_energy = 2.0
	shaft.light_color = Color("fff0d8")
	a.add_child(shaft)


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	Audio.music("byzantium")
	await hud.card([[tr("UI_CH10A_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH10A_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = TABLE + Vector3(0.8, 0.1, 3.0)
	player.face(theodoros.global_position + Vector3(0, 1.5, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _th("D10A_TH_01")
	player.face(HEN_AT + Vector3(0, 0.2, 0))
	await _t("D10A_T_02")
	await _th("D10A_TH_03")
	player.face(theodoros.global_position + Vector3(0, 1.5, 0))
	var cube := "cube" in GameState.bag
	await _t("D10A_T_04_CUBE" if cube else "D10A_T_04")
	await _th("D10A_TH_05")
	phase = "free"
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		await _auto_sort()
	while phase == "free":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	await _nihat_arrives()
	await _otag()
	await _sign()
	await _end_chapter()


func _update_objective() -> void:
	var line := tr("UI_OBJ10A") % [_placed, DOCS.size()]
	if _doc >= 0:
		line += "\n" + tr("UI_OBJ10A_HOLD") % tr("UI_CH10A_COLOR_" + String(DOCS[_doc]).to_upper())
	# Elde dosya yokken masayı göster; rafı bulmak (renk eşleştirme) oyuncuda
	hud.set_objective(line, hud.spot("table") if _doc < 0 else null, 0.3)


# ---------------------------------------------------------------- dosya düzeni

func _take() -> void:
	if _doc >= 0 or _placed >= DOCS.size():
		return
	# Yığının en üstünden alınır (alttan alınca üsttekiler havada kalıyordu)
	_doc = DOCS.size() - 1 - _placed
	_pile[_doc].visible = false
	Audio.sfx("paper_tear", -16.0, 1.6)
	_update_objective()


func _place(shelf: String) -> void:
	if _doc < 0:
		hud.bark("SPK_THEODOROS", "D10A_TH_EMPTY", 2.5)
		return
	var want: String = DOCS[_doc]
	if shelf != want:
		_mistakes += 1
		hud.bark("SPK_THEODOROS", "D10A_TH_WRONG_%d" % mini(_mistakes, 3), 3.0)
		return
	var p: Vector3 = SHELVES[shelf]
	var n: int = _on_shelf.get(shelf, 0)
	_on_shelf[shelf] = n + 1
	# Orta katta, yan yana dik duran klasörler; yerine süzülerek oturur
	var spot := p + Vector3(-0.8 + n * 0.55, SHELF_PLANKS[1] + 0.2, 0.05)
	var doc := Props.box(archive, Vector3(0.1, 0.36, 0.5), spot + Vector3(0, 0.25, 0.5), SHELF_COLORS[shelf].lightened(0.25))
	var tw := create_tween()
	tw.tween_property(doc, "position", spot, _d(0.25)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	Vfx.dust(archive, spot + Vector3(0, 0.05, 0.2), 0.35)
	Audio.sfx("stamp", -10.0)
	_placed += 1
	_doc = -1
	_update_objective()
	if _placed == 2:
		hud.bark("SPK_THEODOROS", "D10A_TH_PROGRESS", 3.5)
	if _placed >= DOCS.size():
		_busy = true
		player.frozen = true
		hud.set_objective("")
		await _th("D10A_TH_DONE_%s" % ("CLEAN" if _mistakes == 0 else "MESSY"))
		await _t("D10A_T_DONE")
		phase = "sorted"
		_busy = false


func _auto_sort() -> void:
	for i in DOCS.size():
		_take()
		await _wait(0.1)
		await _place(String(DOCS[_doc]))
		await _wait(0.1)


# ---------------------------------------------------------------- Nihat ve Form Z-1

func _nihat_arrives() -> void:
	nihat.visible = true
	nihat.position = Vector3(0, 0, 7.5)
	nihat.look_target = player
	player.face(nihat.global_position + Vector3(0, 1.5, 0))
	Audio.sfx("door_metal", -8.0)
	await _n("D10A_N_01")
	await _t("D10A_T_N_02")
	await _n("D10A_N_03")
	var tw := create_tween()
	tw.tween_property(nihat, "position", FORM_AT * Vector3(1, 0, 1) + Vector3(1.4, 0, 0.6), _d(2.0))
	await tw.finished
	nihat.look_target = null
	nihat.face_toward(FORM_AT)
	player.face(FORM_AT)
	await _n("D10A_N_FORM_1")
	await _wait(1.0)
	await _n("D10A_N_FORM_2")
	nihat.look_target = player
	player.face(nihat.global_position + Vector3(0, 1.5, 0))
	await _n("D10A_N_FORM_3")
	await _t("D10A_T_FORM_4")
	await _th("D10A_TH_FORM_5")
	await _n("D10A_N_FORM_6")


## "Yerel makam onayı": otağda Fatih formu okur ve imzalar.
func _otag() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH10A_OTAG"), 28, Color("f2e6c9")], [tr("UI_CH10A_OTAG_SUB"), 18, Color(1, 1, 1, 0.7)]], 2.2)
	hud.clear_card()
	archive.visible = false
	_env.queue_free()
	hall = OtagHall.new()
	hall.position = OTAG_OFFSET
	add_child(hall)
	nihat.position = OTAG_OFFSET + OtagHall.NIHAT_SPOT
	player.global_position = OTAG_OFFSET + OtagHall.TOLGA_SPOT + Vector3(0, 0.05, 0)
	player.face(hall.fatih.global_position + Vector3(0, 1.7, 0))
	hall.fatih.look_target = player
	nihat.look_target = hall.fatih
	await hud.fade_to(0.0, 0.8)
	await _n("D10A_N_OTAG_1")
	hall.fatih.talking = true
	await hud.say("SPK_FATIH", "D10A_F_1")
	hall.fatih.talking = false
	await _wait(1.6)
	hall.fatih.talking = true
	await hud.say("SPK_FATIH", "D10A_F_2")
	hall.fatih.talking = false
	Audio.sfx("stamp", -4.0)
	await _n("D10A_N_OTAG_2")
	hall.fatih.talking = true
	await hud.say("SPK_FATIH", "D10A_F_3")
	hall.fatih.talking = false


## Kurucunun imzası: "T."
func _sign() -> void:
	await _n("D10A_N_SIGN")
	var pick := 1 if GameState.autotest_variant == "refuse" else 0
	var c := await hud.choose(["UI_CH10A_SIGN", "UI_CH10A_REFUSE"], 10.0, pick)
	if c == 1:
		await _t("D10A_T_REFUSE")
		await _n("D10A_N_REFUSE")
		hall.fatih.talking = true
		await hud.say("SPK_FATIH", "D10A_F_REFUSE")
		hall.fatih.talking = false
		await hud.fade_to(1.0, 0.8)
		await hud.card([[tr("UI_CH10A_GIUST"), 24, Color("f2e6c9")]], 2.6)
		hud.clear_card()
		GameState.flags["refused_bureau"] = true
		_outcome = "10A.2"
		return
	await _t("D10A_T_SIGN")
	Audio.sfx("typewriter_bell", -6.0)
	GameState.flags["form_z1_signed"] = true
	# İlk Büro toplantısı: arşivde, mum ışığında
	await hud.fade_to(1.0, 0.8)
	hall.queue_free()
	_make_env()
	archive.visible = true
	nihat.position = TABLE + Vector3(1.8, 0, 0.9)
	theodoros.position = TABLE + Vector3(-1.8, 0, 0.9)
	player.global_position = TABLE + Vector3(0, 0.1, 2.4)
	player.face(TABLE + Vector3(0, 1.0, 0))
	nihat.look_target = player
	await hud.card([[tr("UI_CH10A_MEETING"), 28, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	await hud.fade_to(0.0, 0.8)
	await _n("D10A_N_MEET_1")
	await _th("D10A_TH_MEET_2")
	await _t("D10A_T_MEET_3")
	await _n("D10A_N_MEET_4")
	Audio.sfx("radio_static", -4.0)
	await hud.say("SPK_HIKMET", "D10A_H_RADIO")
	await _t("D10A_T_RADIO")
	await _n("D10A_N_MEET_5")
	GameState.flags["world10"] = "W8"
	GameState.paradox += 10
	GameState.chapter_outcomes[11] = "11.2"
	_outcome = "10A.1"


# ================================================================ bölüm sonu

func _next_scene() -> String:
	return "res://scenes/chapter13.tscn" if _outcome == "10A.1" else "res://scenes/chapter11.tscn"


func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	GameState.set_outcome(10, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=10a -> %s outcome=%s" % [_next_scene().get_file(), _outcome])
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file(_next_scene())
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file(_next_scene())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW10A_TITLE")
	c.nodes = [
		{"id": "sort", "key": "FLOW10A_SORT", "pos": Vector2(0.15, 0.16)},
		{"id": "form", "key": "FLOW10A_FORM", "pos": Vector2(0.4, 0.16)},
		{"id": "otag", "key": "FLOW10A_OTAG", "pos": Vector2(0.65, 0.16)},
		{"id": "10A.1", "key": "FLOW_10A_1", "pos": Vector2(0.4, 0.48), "outcome": true},
		{"id": "10A.2", "key": "FLOW_10A_2", "pos": Vector2(0.8, 0.48), "outcome": true},
	]
	c.edges = [["sort", "form"], ["form", "otag"], ["otag", "10A.1"], ["otag", "10A.2"]]
	for id in ["sort", "form", "otag", _outcome]:
		c.taken[id] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH10A_STATS") % [_placed, _mistakes, GameState.paradox],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW10A_NEXT_1") if _outcome == "10A.1" else tr("UI_FLOW10A_NEXT_2"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase == "free":
		if id == "table" and _doc < 0 and _placed < DOCS.size():
			p = tr("UI_PROMPT10A_TAKE")
		elif id.begins_with("shelf_"):
			p = tr("UI_PROMPT10A_SHELF") % tr("UI_CH10A_COLOR_" + id.trim_prefix("shelf_").to_upper())
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy or phase != "free":
		return
	if id == "table":
		_take()
	elif id.begins_with("shelf_"):
		await _place(id.trim_prefix("shelf_"))
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _th(key: String) -> void:
	theodoros.talking = true
	await hud.say("SPK_THEODOROS", key)
	theodoros.talking = false


func _n(key: String) -> void:
	nihat.talking = true
	await hud.say("SPK_NIHAT", key)
	nihat.talking = false


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "10A.1", "refuse": "10A.2", "next": "10A.1"}[v]
	var ok: bool = _outcome == expected and GameState.chapter_outcomes.get(10, "") == _outcome and _placed == DOCS.size()
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=10a variant=%s outcome=%s placed=%d mistakes=%d" % ["PASS" if ok else "FAIL", v, _outcome, _placed, _mistakes])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(file_name: String) -> void:
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(file_name))
	print("shot: ", file_name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	await get_tree().create_timer(0.8).timeout
	player.global_position = TABLE + Vector3(2.5, 0.1, 4.0)
	player.face(SHELVES["blue"] + Vector3(-1.0, 1.8, 0))
	phase = "free"
	_placed = 2
	_doc = 2
	_update_objective()
	hud.bark("SPK_THEODOROS", "D10A_TH_PROGRESS", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c10a_01_arsiv.png")
	hud.set_objective("")
	nihat.visible = true
	nihat.position = FORM_AT * Vector3(1, 0, 1) + Vector3(1.4, 0, 0.6)
	nihat.face_toward(FORM_AT)
	player.global_position = FORM_AT * Vector3(1, 0, 1) + Vector3(4.2, 0.1, 1.6)
	player.face(FORM_AT + Vector3(0, -0.2, 0))
	hud.bark("SPK_NIHAT", "D10A_N_FORM_3", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c10a_02_form_z1.png")
	get_tree().quit()
