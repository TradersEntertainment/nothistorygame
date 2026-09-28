extends Node3D
## Bölüm 27 — Ahitname (Tolga · 1 Haziran 1453, Galata). Kuşatmanın son sayfası ve Büro'da kapanış.
##
## Şehir düştükten üç gün sonra Galata: Ceneviz'in surlu kasabası kapılarını açmıştır, rıhtımda gemiye yetişmeye
## çalışanlar var. Tolga kararsız üç tanıdıkla konuşur (şarapçı Spinola, noter, balıkçı; Bölüm 10G'den): "kal" ya da
## "git" der. Tavsiye tarihi değiştirmez, sayfanın notunu değiştirir. Sonra kule meydanında Zağanos Paşa
## Sultan'ın Galata'ya verdiği ahitnameyi okur (tarihteki şartlar: mal ve can güvencesi, kiliseler kalır ama çan
## çalınmaz, haraç, serbest ticaret, gidenler dönerse malları iade, kendi kethüdaları). Tespit karesi: ahitname,
## paşa ve podesta Lomellino aynı karede. Ardından Büro'da kuşatma dosyası kapanır (eskiden Bölüm 26'nın sonuydu).
##   27.1 Kalanlar (en az iki kişiye "kal" dendi) · 27.2 Gidenler
##   --autotest[=leave]   (varsayılan: 27.1)

const SPEAKERS := {"wine": "SPK_WINE", "notary": "SPK_NOTARY", "fishmonger": "SPK_FISHMONGER", "captain": "SPK_CAPTAIN",
	"double": "SPK_DOUBLE"}
const UNDECIDED := ["wine", "notary", "fishmonger"]
const KEY := {"wine": "W", "notary": "NT", "fishmonger": "F"}
## Tören: kulenin önündeki meydan
const CER := Vector3(8.0, 0.0, -50.8)

var galata: Galata
var extra: Node3D                 # rıhtım kalabalığı ve tören (Büro'ya geçerken birlikte silinir)
var bureau: Bureau
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _busy := false
var _advised: Dictionary = {}     # id -> "stay" / "go"
var stayed := 0
var zaganos: Person
var podesta: Person
var scroll: Node3D
var cam: TespitCam
var _photo := ""


func _ready() -> void:
	GameState.snapshot(27)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(_on_focus)
	player.frozen = true
	hud.set_fez(false)
	hud.set_signal(0)
	galata = Galata.new()
	add_child(galata)
	extra = Node3D.new()
	add_child(extra)
	_dress_galata()
	_build_ceremony()
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


## 10G'nin Galata'sı, üç gün sonrası: Sultan'ın burundaki görüntüsü, çocuk ve pazarlık yok; rıhtımda gemiye
## sıra bekleyenler, bohçalar, sandıklar.
func _dress_galata() -> void:
	galata.fatih.visible = false
	for n in galata.get_children():
		if n is Soldier and (n as Node3D).global_position.distance_to(Galata.FATIH_POINT) < 4.0:
			n.visible = false
		elif n.is_in_group("cat_owner"):
			n.queue_free()
	for id in ["npc:kid", "mg:haggle_wine", "mg:haggle_double"]:
		var it := galata.get_node_or_null("Interact_" + id)
		if it:
			it.queue_free()
	for id in galata.npcs:
		(galata.npcs[id] as Person).look_target = player
	# Gemiye sıra: iskeleye doğru bohçalı, sandıklı bir kuyruk
	var cols := [Color("7a5a3a"), Color("5a6a4a"), Color("4a5a7a"), Color("6a2a3a"), Color("8a6a4a"), Color("3a4a5a"), Color("6a5a3a"), Color("5a3a4a")]
	for i in 8:
		var p := Person.new({"coat": cols[i], "pants": Color("3a3a3a"), "hat": ["plume", "none", "none", "plume"][i % 4],
			"skirt": i % 3 == 1, "mustache": i % 2 == 0, "hair": [Color("3a2a1e"), Color("5a3a1e"), Color("6a6a6a")][i % 3], "n": 60 + i})
		p.set_meta("no_talk", true)
		p.set_meta("no_chat", true)
		p.position = Vector3(6.5 + i * 1.25, 0, -1.4 + (i % 2) * 0.35)
		p.rotation.y = -PI / 2.0
		extra.add_child(p)
		var sack := Props.ball(extra, 0.28, p.position + Vector3(0.1, 0.25, 0.45), Color("b8a27a"), Vector3(1.0, 0.8, 1.1), 7)
		sack.rotation.y = i * 0.7
		if i % 3 == 0:
			Props.box(extra, Vector3(0.7, 0.45, 0.45), p.position + Vector3(-0.3, 0.23, 0.55), Color("6a4a2c"))
	# İskelenin dibinde yüklenmeyi bekleyen sandıklar ve dürülmüş halılar
	for k in 5:
		Props.box(extra, Vector3(0.8, 0.55, 0.55), Galata.GANGWAY + Vector3(-2.2 + (k % 3) * 0.9, 0.28 + (k / 3) * 0.55, -1.8), Color("5a3a22"))
	for k in 3:
		Props.cyl(extra, 0.16, 1.6, Galata.GANGWAY + Vector3(-5.2, 0.16 + k * 0.3, -2.6), [Color("8a2a2a"), Color("2a4a6a"), Color("8a6a2a")][k], Vector3(0, 0, 90), 8)


## Kule meydanı: masa, üstünde açılmış ahitname (Rumca metin, üstte tuğra, altta kırmızı mühür), paşa, podesta,
## iki yanda yeniçeri, karşıda Ceneviz ileri gelenleri ve halk.
func _build_ceremony() -> void:
	var table := Props.solid(extra, Vector3(1.6, 0.8, 0.8), CER + Vector3(0, 0.4, -0.6), Color("5a3a22"))
	table.name = "CerTable"
	Props.box(extra, Vector3(1.7, 0.02, 0.9), CER + Vector3(0, 0.81, -0.6), Color("7a1c22"))
	scroll = Node3D.new()
	scroll.position = CER + Vector3(0, 0.84, -0.6)
	extra.add_child(scroll)
	Props.box(scroll, Vector3(0.62, 0.012, 0.86), Vector3.ZERO, Color("efe3c2"), Vector3(0, 8, 0))
	Props.cyl(scroll, 0.035, 0.66, Vector3(0, 0.03, -0.44), Color("e0d2ae"), Vector3(0, 0, 90), 8)
	Props.cyl(scroll, 0.035, 0.66, Vector3(0, 0.03, 0.44), Color("e0d2ae"), Vector3(0, 0, 90), 8)
	for k in 9:
		Props.box(scroll, Vector3(0.44 - (k % 3) * 0.05, 0.002, 0.018), Vector3(0.0, 0.008, -0.22 + k * 0.055), Color("3a3028"), Vector3(0, 8, 0))
	Props.ball(scroll, 0.07, Vector3(0.0, 0.01, -0.33), Color("c9a24a"), Vector3(1.6, 0.1, 1.0), 8)      # tuğra
	var seal := Props.cyl(scroll, 0.05, 0.02, Vector3(0.12, 0.012, 0.36), Color("a8201a"), Vector3.ZERO, 10)
	seal.material_override = Props.mat(Color("a8201a"), 0.2, false, "", false)
	zaganos = Person.new({"coat": Color("2f4a6a"), "pants": Color("2a2a30"), "hat": "turban", "beard": true, "mustache": true, "robe": Color("2f4a6a"),
		"skin": Color("d9a07a"), "face": {"nose": "hook", "brow": 1.3, "brow_tilt": 8.0, "beard": "short", "head": Vector3(0.98, 1.08, 0.98)}})
	zaganos.set_meta("spk", "SPK_ZAGANOS")
	zaganos.position = CER + Vector3(-0.6, 0, -1.5)
	extra.add_child(zaganos)
	podesta = Person.new({"coat": Color("6a1a2a"), "pants": Color("2a2a30"), "hat": "none", "beard": true, "hair": Color("8a8a8a"),
		"robe": Color("6a1a2a"), "skin": Color("e8c0a0"), "n": 91})
	podesta.set_meta("spk", "SPK_PODESTA")
	podesta.position = CER + Vector3(1.5, 0, -0.2)
	extra.add_child(podesta)
	# Zağanos yüzünü meydana, podesta paşaya döner
	zaganos.look_at_from_position(zaganos.position, CER + Vector3(0, 0, 8), Vector3.UP)
	zaganos.rotate_y(PI)
	podesta.look_at_from_position(podesta.position, zaganos.position, Vector3.UP)
	podesta.rotate_y(PI)
	# Paşanın iki yanında börklü yeniçeriler
	for x: float in [-2.6, -1.8, 2.6, 3.4]:
		var g := Soldier.new(Color("b3262d") if x < 0.0 else Color("2f5fa8"), "stand", "bork")
		g.position = CER + Vector3(x, 0, -1.9)
		extra.add_child(g)
	# Ceneviz ileri gelenleri (podestanın arkasında) ve meydandaki halk
	for i in 3:
		var e := Person.new({"coat": [Color("3a3a5a"), Color("5a4a2a"), Color("2a4a3a")][i], "pants": Color("2a2a30"), "hat": "plume",
			"beard": i != 1, "hair": Color("6a6a6a"), "robe": [Color("3a3a5a"), Color("5a4a2a"), Color("2a4a3a")][i], "n": 95 + i})
		e.set_meta("no_talk", true)
		e.set_meta("no_chat", true)
		e.position = CER + Vector3(2.4 + i * 0.8, 0, 0.8 + (i % 2) * 0.5)
		e.look_at_from_position(e.position, zaganos.position, Vector3.UP)
		e.rotate_y(PI)
		extra.add_child(e)
	for i in 10:
		var c := Person.new({"coat": Galata.GAL_PEOPLE[i % 6]["coat"], "pants": Color("3a3a3a"), "skirt": i % 4 == 1,
			"mustache": i % 2 == 0, "hat": ["none", "plume", "none", "none", "plume"][i % 5], "n": 120 + i})
		c.set_meta("no_talk", true)
		c.set_meta("no_chat", true)
		# İki yanda toplanır, ortada oyuncunun durduğu yere doğru bir koridor kalır
		var side := -1.0 if i % 2 == 0 else 1.0
		c.position = CER + Vector3(side * (1.9 + (i / 2 % 3) * 0.9), 0, 2.2 + (i / 6) * 1.2 + (i / 2 % 3) * 0.35)
		c.look_at_from_position(c.position, zaganos.position, Vector3.UP)
		c.rotate_y(PI)
		extra.add_child(c)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH27_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH27_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = Galata.SPAWN + Vector3(0, 0.1, 0)
	player.face(Galata.GANGWAY + Vector3(0, 1.6, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D27_N_01")
	await _t("D27_T_01")
	await hud.say("SPK_NIHAT", "D27_N_02")
	phase = "free"
	Lore.scatter(self, "27")
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		for id in UNDECIDED:
			await _talk(id)
		await _talk("double")
	while _advised.size() < UNDECIDED.size() or _busy:
		await get_tree().process_frame
	await _to_square()
	await _ceremony()
	_outcome = "27.1" if stayed >= 2 else "27.2"
	Siege.record(27, _photo, "SIEGE_NOTE_27_%s" % _outcome.split(".")[1])
	await Siege.show_page(hud, 27)
	await _epilogue()
	await _end_chapter()


func _update_objective() -> void:
	if phase == "free":
		for id in UNDECIDED:
			if not _advised.has(id):
				hud.set_objective(tr("UI_OBJ27_TALK") % [_advised.size(), UNDECIDED.size()], galata.npcs[id])
				return
	hud.set_objective("")


func _talk(id: String) -> void:
	if _busy or phase != "free":
		return
	_busy = true
	player.frozen = true
	hud.set_prompt("")
	var p: Person = galata.npcs[id]
	player.face(p.global_position + Vector3(0, 1.5, 0))
	var spk: String = SPEAKERS[id]
	if id in UNDECIDED and not _advised.has(id):
		var k: String = KEY[id]
		await _say(spk, "D27_%s_1" % k)
		var pick := 1 if GameState.autotest_variant == "leave" else 0
		var c := await hud.choose(["UI_C27_STAY", "UI_C27_GO"], 0.0, pick)
		if c == 0:
			stayed += 1
			_advised[id] = "stay"
			await _t("D27_T_%s_STAY" % k)
			await _say(spk, "D27_%s_STAY" % k)
		else:
			_advised[id] = "go"
			await _t("D27_T_%s_GO" % k)
			await _say(spk, "D27_%s_GO" % k)
			p.leave(player.global_position, 4.0, 2.5)
		if _advised.size() == 1:
			await hud.say("SPK_NIHAT", "D27_N_ADVICE")
	elif id in UNDECIDED:
		await _say(spk, "D27_%s_AGAIN" % KEY[id])
	elif id == "captain":
		await _say(spk, "D27_C_1")
	elif id == "double":
		await _say(spk, "D27_D_1")
		await _t("D27_T_D_2")
	_busy = false
	_update_objective()
	# Üç kararsız da dinlendiyse oyuncu bırakılmaz: meydana çağrı hemen gelir
	if phase == "free" and _advised.size() < UNDECIDED.size():
		player.frozen = false


## Kararsızlar dinlendi: meydandan davul sesi, Tolga kuleye çıkar. Oyuncu yürür; 90 sn'de gelmezse kararır ve
## meydana alınır (sokakta kaybolan oyuncu töreni kaçırmasın).
func _to_square() -> void:
	phase = "walk"
	hud.set_objective("")
	await hud.say("SPK_NIHAT", "D27_N_SQUARE")
	hud.set_objective(tr("UI_OBJ27_SQUARE"), CER + Vector3(0, 1.6, 0))
	player.frozen = false
	var t := 0.0
	var limit := 0.5 if GameState.autotest else 90.0
	while t < limit and Vector2(player.global_position.x - CER.x, player.global_position.z - CER.z).length() > 11.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	player.frozen = true
	hud.set_objective("")
	if Vector2(player.global_position.x - CER.x, player.global_position.z - CER.z).length() > 11.0:
		await hud.fade_to(1.0, 0.6)
		player.global_position = CER + Vector3(0.0, 0.1, 5.8)
		await hud.fade_to(0.0, 0.6)
	player.face(zaganos.global_position + Vector3(0, 1.5, 0))


func _ceremony() -> void:
	phase = "ceremony"
	Audio.sfx("crowd_gasp", -12.0)
	await _say("SPK_ZAGANOS", "D27_Z_01")
	await _say("SPK_ZAGANOS", "D27_Z_02")
	await _say("SPK_ZAGANOS", "D27_Z_03")
	await _say("SPK_ZAGANOS", "D27_Z_04")
	await _say("SPK_PODESTA", "D27_P_01")
	await _t("D27_T_GREEK")
	await _say("SPK_ZAGANOS", "D27_Z_05")
	# Tespit karesi: ahitname masada, paşa ile podesta başında
	hud.set_objective(tr("UI_OBJ27_PHOTO"), scroll.global_position + Vector3(0, 0.3, 0))
	player.frozen = false
	await hud.say("SPK_NIHAT", "D27_N_PHOTO")
	cam = TespitCam.new(player, hud, scroll, "siege27")
	hud.add_child(cam)
	cam.max_dist = 16.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 45.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	if cam.done:
		await _say("SPK_PODESTA", "D27_P_FLASH")
	await hud.say("SPK_NIHAT", "D27_N_END_STAY" if stayed >= 2 else "D27_N_END_GO")
	await _t("D27_T_END")
	await hud.say("SPK_NIHAT", "D27_N_LONDON")


## Kuşatmanın kapanışı: Büro'da dosya teslim edilir, Tolga 26 Nisan öğlesine döner.
func _epilogue() -> void:
	phase = "epilogue"
	await hud.fade_to(1.0, 0.8)
	galata.queue_free()
	galata = null
	extra.queue_free()
	for c in get_children():
		if c is Lore:
			c.queue_free()
	zaganos = null
	podesta = null
	await get_tree().process_frame
	bureau = Bureau.new()
	add_child(bureau)
	Audio.music("bureau")
	Audio.ambience("fluorescent")
	var nihat := Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
		"hair": Color("3a2a1e"), "skin": Color("ecb892")})
	nihat.position = Bureau.NIHAT_OFFICE_POS
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
	await hud.say("SPK_NIHAT", "D26_N_RETURN")
	await hud.say("SPK_TOLGA", "D26_T_RETURN")
	GameState.flags["siege_done"] = true
	GameState.flags["act4_done"] = true
	await hud.fade_to(1.0, 1.0)
	Audio.sfx("machine_jump", -4.0)
	await hud.card([[tr("UI_ACT4_END"), 34, Color("f2e6c9")], [tr("UI_ACT4_END_SUB") % [pages, total], 18, Color(1, 1, 1, 0.75)]], 3.5)
	hud.clear_card()


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase == "free" and SPEAKERS.has(id):
		p = tr("UI_PROMPT3_TALK") % tr(SPEAKERS[id])
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy or phase != "free":
		return
	if SPEAKERS.has(id):
		await _talk(id)
	_on_focus(player.focus_id)


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _npc(speaker: String) -> Person:
	match speaker:
		"SPK_ZAGANOS":
			return zaganos
		"SPK_PODESTA":
			return podesta
	if galata:
		for id in SPEAKERS:
			if SPEAKERS[id] == speaker:
				return galata.npcs[id]
	return null


func _say(speaker: String, key: String) -> void:
	var who := _npc(speaker)
	if who:
		who.talking = true
	await hud.say(speaker, key)
	if who and is_instance_valid(who):
		who.talking = false


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(27, _outcome)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"replay":
			get_tree().reload_current_scene()
		"next":
			GameState.change_scene(Siege.return_path())
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW27_TITLE")
	c.nodes = [
		{"id": "harbor", "key": "FLOW27_HARBOR", "pos": Vector2(0.5, 0.12)},
		{"id": "ahd", "key": "FLOW27_AHD", "pos": Vector2(0.5, 0.3)},
		{"id": "27.1", "key": "FLOW_27_1", "pos": Vector2(0.3, 0.56), "outcome": true},
		{"id": "27.2", "key": "FLOW_27_2", "pos": Vector2(0.7, 0.56), "outcome": true},
	]
	c.edges = [["harbor", "ahd"], ["ahd", "27.1"], ["ahd", "27.2"]]
	for k in ["harbor", "ahd", _outcome]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH27_STATS") % [stayed, UNDECIDED.size(), Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "27.1", "leave": "27.2"}.get(v, "27.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("27", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and _advised.size() == 3 \
		and GameState.flags.get("siege_done", false)
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=27 variant=%s outcome=%s stayed=%d" % ["PASS" if ok else "FAIL", v, _outcome, stayed])
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
	await get_tree().create_timer(0.8).timeout
	player.global_position = Galata.SPAWN + Vector3(8.0, 0.1, 1.0)
	player.face(Galata.GANGWAY + Vector3(0, 1.6, 0))
	hud.bark("SPK_WINE", "D27_W_1", 30.0)
	await _shot("c27_01_harbor.png")
	player.global_position = CER + Vector3(0.0, 0.1, 5.8)
	player.face(zaganos.global_position + Vector3(0, 1.5, 0))
	hud.bark("SPK_ZAGANOS", "D27_Z_02", 30.0)
	await _shot("c27_02_ahd.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = CER + Vector3(0.6, 3.4, 7.0)
	cv.look_at(CER + Vector3(0.4, 1.0, -0.8), Vector3.UP)
	cv.fov = 55.0
	cv.make_current()
	await _shot("c27_cover.png")
	get_tree().quit()
