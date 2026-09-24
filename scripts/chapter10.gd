extends Node3D
## Bölüm 10 — Dal bölümü (Tolga · 25 Nisan 1453). CHAPTERS Bölüm 10, GDD §5.8, §9.6.
##
## Şu an oynanabilen dal: **10 · Otağ Kapısı** (9.6, bütün teklifler reddedildi).
## Kapıda Sorucu Ağa, Holy Grail'deki köprü bekçisi gibi üç soru sorar:
##   1. "Adın ne?"  2. "Buraya niye geldin?"  3. Saçma soru (deve / otağın direkleri / kavuğun boyu)
## Her soru ⏱ süreli. Yalan ya da yanlış cevapta Hasan ile Hüseyin seni hafifçe dışarı taşır.
## Sıradaki insanlar (deveci, derviş, Venedikli terzi) üçüncü sorunun cevabını bilir.
## "Bilmiyorum" dürüst bir cevaptır: geçersin, Merak +1 (Fatih dürüst "bilmiyorum"u ödüllendirir).
## Eşyalar: 🥜 birinci soruyu geçirir, 🤳 "asa" sayılır ve bir soru atlanır.
## Bizans'tan mektupla gelenler resmî elçi töreniyle geçer; Ağa üçüncü soru için arkalarından koşar.
##   10O.1 Kapı geçildi → Bölüm 12 · 10O.2 Üç denemede geçilemedi → mutfağa (Bölüm 12'ye Yol A gibi)
##   --autotest[=fail|honest|selfie|byz|retry]   (varsayılan: 10O.1)

const GATE_Z := -52.5
const AGA_POS := Vector3(0.0, 0.0, -51.2)
const START := Vector3(0.3, 0.0, -37.0)
const CAMEL_POS := Vector3(-3.4, 0.0, -45.5)
const DERVISH_POS := Vector3(2.6, 0.0, -44.0)
const TAILOR_POS := Vector3(-2.2, 0.0, -41.0)
const MAX_TRIES := 3
const Q_TIME := 9.0
const Q3_IDS := ["camel", "poles", "kavuk"]
const Q3_SOURCE := {"camel": "cameleer", "poles": "dervish", "kavuk": "tailor"}
const SPEAKERS := {"aga": "SPK_AGA", "cameleer": "SPK_CAMELEER", "dervish": "SPK_DERVISH", "tailor": "SPK_TAILOR",
	"guards": "SPK_HASAN"}

var day: CampDay
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _busy := false
var _tries := 0
var _know: Dictionary = {}          # öğrenilen üçüncü soru cevapları
var _shown: Dictionary = {}         # Ağa'ya gösterilen eşyalar
var _q3 := "camel"
var _envoy := false
var aga: Person
var cameleer: Person
var dervish: Person
var tailor: Person
var hasan: Soldier
var huseyin: Soldier
var fatih: Person
var _gate_l: Node3D
var _gate_r: Node3D


func _ready() -> void:
	GameState.snapshot(10)
	_apply_autotest_setup()
	var ch6: String = GameState.chapter_outcomes.get(6, "6a.1")
	_envoy = ch6.begins_with("6b") and ch6 != "6b.3"
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.interacted.connect(_on_interact)
	player.item_handler = _on_item_used
	player.focus_changed.connect(_on_focus)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	player.show_remote(true)
	day = CampDay.new()
	add_child(day)
	day.goat.chase = player
	if day.ring_node:
		day.ring_node.queue_free()
	_build_gate()
	_q3 = "camel" if GameState.autotest else Q3_IDS[randi() % Q3_IDS.size()]
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	GameState.chapter_outcomes[9] = "9.6"
	match GameState.autotest_variant:
		"selfie":
			if not "selfie" in GameState.bag:
				GameState.bag.append("selfie")
		"byz":
			GameState.chapter_outcomes[4] = "4b.1"
			GameState.chapter_outcomes[6] = "6b.1"


func _process(delta: float) -> void:
	if dervish:
		dervish.rotation.y += delta * 2.4


func _gy(z: float) -> float:
	return CampDay.height(0.0, z)


func _at(p: Vector3) -> Vector3:
	return Vector3(p.x, _gy(p.z), p.z)


# ================================================================ sahne

func _build_gate() -> void:
	var gz := GATE_Z - 1.2
	var gy := _gy(gz)
	# Ahşap kapı çerçevesi, sancaklar, kapı kanatları
	for s in [-1, 1]:
		Props.cyl(self, 0.18, 4.4, Vector3(s * 2.2, gy + 2.2, gz), Color("6a4028"), Vector3.ZERO, 8)
		Props.ball(self, 0.26, Vector3(s * 2.2, gy + 4.5, gz), Color("d8b040"), Vector3.ONE, 8)
		Props.box(self, Vector3(0.04, 1.6, 0.9), Vector3(s * 2.2, gy + 3.2, gz + 0.5), Color("b3262d"))
	Props.box(self, Vector3(4.8, 0.4, 0.3), Vector3(0, gy + 4.2, gz), Color("8a2b22"))
	Props.label(self, "DERGÂH-I ÂLÎ", Vector3(0, gy + 4.2, gz + 0.17), 34, Color("d8b040"), Vector3.ZERO, 3.6)
	for s in [-1, 1]:
		var leaf := Node3D.new()
		leaf.position = Vector3(s * 2.05, gy, gz)
		add_child(leaf)
		Props.box(leaf, Vector3(1.9, 3.4, 0.1), Vector3(-s * 0.95, 1.7, 0), Color("7a5a38"))
		for k in 3:
			Props.box(leaf, Vector3(1.9, 0.08, 0.12), Vector3(-s * 0.95, 0.6 + k * 1.1, 0), Color("4a3020"))
		var col := Props.solid(leaf, Vector3(1.9, 3.4, 0.2), Vector3(-s * 0.95, 1.7, 0), Color(0, 0, 0, 0))
		col.get_child(0).visible = false
		if s < 0:
			_gate_l = leaf
		else:
			_gate_r = leaf
	# Çitler: kapıdan başka yerden girilemez
	for s in [-1, 1]:
		Props.solid(self, Vector3(8.0, 1.2, 0.2), Vector3(s * 6.2, gy + 0.6, gz), Color("7a5a38"))
	# Sorucu Ağa: kocaman bıyık, asa, kırmızı kaftan
	aga = Person.new({"coat": Color("8a2b22"), "pants": Color("4a2a20"), "hat": "turban", "mustache": true, "robe": Color("8a2b22"),
		"hair": Color("2a1e14"), "skin": Color("d9a07a")})
	aga.position = _at(AGA_POS)
	aga.scale = Vector3(1.12, 1.12, 1.12)
	aga.look_target = player
	add_child(aga)
	Props.cyl(aga, 0.03, 2.1, Vector3(0.42, 1.05, 0.1), Color("5a4028"), Vector3.ZERO, 5)
	Props.ball(aga, 0.07, Vector3(0.42, 2.12, 0.1), Color("d8b040"), Vector3.ONE, 6)
	Props.interactable(self, "aga", Vector3(1.4, 2.2, 1.4), _at(AGA_POS) + Vector3(0, 1.1, 0))
	hasan = Soldier.new(Color("b3262d"), "stand", "bork")
	hasan.position = _at(Vector3(-1.7, 0, GATE_Z - 0.4))
	add_child(hasan)
	huseyin = Soldier.new(Color("2f5fa8"), "stand", "bork")
	huseyin.position = _at(Vector3(1.7, 0, GATE_Z - 0.4))
	add_child(huseyin)
	# Sıradakiler
	cameleer = Person.new({"coat": Color("a8804a"), "pants": Color("5a4028"), "hat": "turban", "beard": true, "robe": Color("a8804a"), "skin": Color("c89070")})
	cameleer.position = _at(CAMEL_POS + Vector3(1.2, 0, 0.3))
	cameleer.look_target = player
	add_child(cameleer)
	_camel(_at(CAMEL_POS))
	Props.interactable(self, "cameleer", Vector3(1.2, 2.0, 1.2), cameleer.position + Vector3(0, 1.0, 0))
	dervish = Person.new({"coat": Color("efe6cf"), "pants": Color("e8e0cc"), "hat": "cook", "beard": true, "robe": Color("efe6cf"), "skin": Color("e0b08a")})
	dervish.position = _at(DERVISH_POS)
	add_child(dervish)
	Props.interactable(self, "dervish", Vector3(1.2, 2.0, 1.2), dervish.position + Vector3(0, 1.0, 0))
	tailor = Person.new({"coat": Color("6a1a2a"), "pants": Color("2a2a30"), "hat": "plume", "mustache": true, "glasses": true, "skin": Color("e8b894")})
	tailor.position = _at(TAILOR_POS)
	tailor.rotation.y = PI * 0.4
	tailor.look_target = player
	add_child(tailor)
	Props.box(tailor, Vector3(0.02, 0.02, 0.9), Vector3(0.35, 1.0, 0.3), Color("d8c040"))
	Props.interactable(self, "tailor", Vector3(1.2, 2.0, 1.2), tailor.position + Vector3(0, 1.0, 0))
	# Otağın içinde, perde arkasında: gölge
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "turban", "mustache": true, "robe": Color("c8323a"),
		"hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.position = CampDay.OTAG_POS + Vector3(0, _gy(CampDay.OTAG_POS.z), 3.4)
	fatih.visible = false
	add_child(fatih)
	# Otağın girişinde koyu perde: gölge onun önünde belirir
	var cp := _at(CampDay.OTAG_POS + Vector3(0, 0, 7.05))
	Props.box(self, Vector3(2.4, 3.3, 0.06), cp + Vector3(0, 1.65, 0), Color("4a1418"))
	Props.box(self, Vector3(2.6, 0.2, 0.1), cp + Vector3(0, 3.3, 0.02), Color("d8b040"))


func _camel(pos: Vector3) -> void:
	var c := Node3D.new()
	c.position = pos
	c.rotation.y = PI * 0.5
	add_child(c)
	var col := Color("c8a060")
	Props.box(c, Vector3(0.7, 0.7, 1.6), Vector3(0, 1.45, 0), col)
	Props.ball(c, 0.38, Vector3(0, 1.9, 0.1), col, Vector3(1.0, 0.9, 1.3), 8)
	Props.box(c, Vector3(0.3, 1.0, 0.3), Vector3(0, 2.0, 0.95), col, Vector3(-25, 0, 0))
	Props.box(c, Vector3(0.3, 0.3, 0.55), Vector3(0, 2.5, 1.25), col)
	for s in [-1, 1]:
		Props.ball(c, 0.04, Vector3(s * 0.15, 2.58, 1.35), Color("1d2330"), Vector3.ONE, 5)
		for z in [-0.6, 0.6]:
			Props.cyl(c, 0.08, 1.1, Vector3(s * 0.25, 0.55, z), col.darkened(0.15), Vector3.ZERO, 5)
	Props.box(c, Vector3(0.75, 0.1, 0.8), Vector3(0, 1.82, -0.3), Color("b3262d"))


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH10O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH10O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = _at(START) + Vector3(0, 0.1, 0)
	player.face(_at(AGA_POS) + Vector3(0, 1.8, 0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	if _envoy:
		await _ceremony()
	else:
		await _t("D10O_T_01")
		await _say("SPK_AGA", "D10O_A_SHOUT")
		await _t("D10O_T_02")
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
	var head := tr("UI_OBJ10O") % [MAX_TRIES - _tries]
	var hints := PackedStringArray()
	for q in _know:
		hints.append("✓ " + tr("UI_CH10O_KNOW_" + String(q).to_upper()))
	hud.set_objective(head + ("\n" + "   ".join(hints) if not hints.is_empty() else ""), hud.spot("aga"), 0.9)


# ---------------------------------------------------------------- sıradakiler

## Eldeki eşyayı Ağa'ya doğrudan göstermek (sağ tık): menüdeki gösterimle aynı etki.
func _on_item_used(target: String, item: String) -> bool:
	if target != "aga" or _busy or phase != "free" or _shown.has(item):
		return false
	_busy = true
	player.frozen = true
	player.face(aga.global_position + Vector3(0, 1.7, 0))
	_shown[item] = true
	await _say("SPK_AGA", "D10O_A_ITEM_" + item.to_upper())
	player.frozen = false
	_busy = false
	return true


func _queue_talk(who: String) -> void:
	if _busy:
		return
	_busy = true
	player.frozen = true
	var node := _npc(who)
	player.face(node.global_position + Vector3(0, 1.4, 0))
	var up := who.to_upper()
	await _say(SPEAKERS[who], "D10O_%s_1" % up)
	await _t("D10O_T_%s_ASK" % up)
	await _say(SPEAKERS[who], "D10O_%s_2" % up)
	for q in Q3_SOURCE:
		if Q3_SOURCE[q] == who:
			_know[q] = true
	_update_objective()
	player.frozen = false
	_busy = false


# ---------------------------------------------------------------- üç soru

func _trial() -> void:
	if _busy or _outcome != "":
		return
	_busy = true
	player.frozen = true
	player.face(aga.global_position + Vector3(0, 1.7, 0))
	await _say("SPK_AGA", "D10O_A_INTRO" if _tries == 0 else "D10O_A_AGAIN")
	# Eşyalar önceden (elden) gösterildiyse de geçerlidir
	var skip_q1 := _shown.has("chickpeas")
	var skip_one := _shown.has("selfie")
	# Sorulardan önce eşya gösterilebilir
	while true:
		var keys: Array = ["UI_CH10O_READY"]
		var ids: Array = [""]
		for id in GameState.bag:
			if not _shown.has(id):
				keys.append(Items.name_key(id))
				ids.append(id)
		var auto_i := 0
		if GameState.autotest_variant == "selfie" and not _shown.has("selfie"):
			auto_i = ids.find("selfie")
		var c := await hud.choose(keys, 0.0, auto_i)
		if c <= 0:
			break
		var item: String = ids[c]
		_shown[item] = true
		await _say("SPK_AGA", "D10O_A_ITEM_" + item.to_upper())
		if item == "chickpeas":
			skip_q1 = true
		elif item == "selfie":
			skip_one = true
	await _say("SPK_AGA", "D10O_A_BEGIN")
	var ok := true
	# 1. soru: Adın ne?
	if skip_q1:
		await _say("SPK_AGA", "D10O_A_Q1_SKIP")
	else:
		ok = await _question("D10O_A_Q1", ["UI_CH10O_Q1_A", "UI_CH10O_Q1_B", "UI_CH10O_Q1_C"], [true, true, false], ["D10O_A_Q1_OK", "D10O_A_Q1_OK2", "D10O_A_Q1_LIE"])
	# 2. soru: Buraya niye geldin?
	if ok:
		if skip_one:
			await _say("SPK_AGA", "D10O_A_Q2_SKIP")
		else:
			var keys := ["UI_CH10O_Q2_A", "UI_CH10O_Q2_B", "UI_CH10O_Q2_C"]
			var good := [true, true, false]
			var rep := ["D10O_A_Q2_OK", "D10O_A_Q2_OK2", "D10O_A_Q2_LIE"]
			if GameState.flags.get("letter_route", "") == "fatih":
				keys.append("UI_CH10O_Q2_D")
				good.append(true)
				rep.append("D10O_A_Q2_LETTER")
			ok = await _question("D10O_A_Q2", keys, good, rep)
			if not ok:
				GameState.paradox += 5
	# 3. soru: saçma soru
	if ok:
		ok = await _q3_ask()
	if ok:
		await _pass()
	else:
		await _thrown()
	player.frozen = false
	_busy = false


## Süreli soru. Süre dolarsa ya da yanlışsa false döner.
func _question(q_key: String, keys: Array, good: Array, replies: Array) -> bool:
	await _say("SPK_AGA", q_key)
	var pick := 0
	if GameState.autotest_variant == "fail" or (GameState.autotest_variant == "retry" and _tries == 0):
		pick = keys.size() - 1 if keys.size() == 3 else 2
	var c := await hud.choose(keys, Q_TIME, pick)
	if c < 0:
		await _say("SPK_AGA", "D10O_A_TIMEOUT")
		return false
	await _say("SPK_AGA", replies[c])
	return good[c]


func _q3_ask() -> bool:
	var up := _q3.to_upper()
	await _say("SPK_AGA", "D10O_A_Q3_" + up)
	var keys := ["UI_CH10O_Q3_%s_A" % up, "UI_CH10O_Q3_%s_B" % up, "UI_CH10O_Q3_%s_C" % up, "UI_CH10O_Q3_IDK"]
	var pick := 0
	if GameState.autotest_variant == "honest":
		pick = 3
	var c := await hud.choose(keys, Q_TIME + 3.0, pick)
	match c:
		0:
			# Doğru cevap: sıradakilerden öğrenildiyse tam isabet, değilse şans
			if _know.has(_q3) or GameState.autotest:
				await _say("SPK_AGA", "D10O_A_Q3_OK")
			else:
				await _say("SPK_AGA", "D10O_A_Q3_LUCKY")
			return true
		1:
			aga.emote("shrug")
			await _say("SPK_AGA", "D10O_A_Q3_WRONG")
			return false
		2:
			# Soruyu soruyla karşılamak: Ağa'nın kafası karışır (köprü bekçisi göndermesi)
			await _say("SPK_AGA", "D10O_A_Q3_%s_TWIST" % up)
			await _t("D10O_T_TWIST")
			GameState.flags["ch10_twist"] = true
			return true
		3:
			await _say("SPK_AGA", "D10O_A_Q3_IDK")
			GameState.flags["merak"] = int(GameState.flags.get("merak", 0)) + 1
			GameState.flags["ch10_honest"] = true
			return true
	await _say("SPK_AGA", "D10O_A_TIMEOUT")
	return false


## Yanlış cevap: Hasan ile Hüseyin seni kaldırıp birkaç adım geri koyar.
func _thrown() -> void:
	_tries += 1
	GameState.flags["ch10_tries"] = _tries
	await _say("SPK_HASAN", "D10O_G_LIFT")
	await _say("SPK_HUSEYIN", "D10O_G_LIFT2")
	player.shake(0.3)
	var from := player.global_position
	var to := _at(Vector3(0.4, 0, GATE_Z + 6.5)) + Vector3(0, 0.1, 0)
	var tw := create_tween()
	tw.tween_property(player, "global_position", from + Vector3(0, 0.7, 0), 0.3)
	tw.tween_property(player, "global_position", to + Vector3(0, 0.7, 0), 0.9 if not GameState.autotest else 0.05)
	tw.tween_property(player, "global_position", to, 0.25)
	await tw.finished
	player.face(_at(AGA_POS) + Vector3(0, 1.8, 0))
	await _say("SPK_AGA", "D10O_A_NEXT")
	if _tries >= MAX_TRIES:
		await _fail()
		return
	await _t("D10O_T_THROWN_%d" % _tries)
	_update_objective()


func _pass() -> void:
	await _say("SPK_AGA", "D10O_A_PASS")
	await _open_gate()
	await _inside()
	_outcome = "10O.1"


## Üç deneme de başarısız: Kadri gelir, mutfağa götürür (Bölüm 12'ye Yol A gibi).
func _fail() -> void:
	await hud.fade_to(1.0, 0.5)
	hud.set_fade(0.0)
	await _say("SPK_KADRI", "D10O_K_COME")
	await _t("D10O_T_KITCHEN")
	await _say("SPK_AGA", "D10O_A_BYE")
	GameState.flags["route_ch12"] = "A"
	_outcome = "10O.2"


## Bizans'tan mektupla gelen: resmî elçi töreni; Ağa üçüncü soru için arkandan koşar.
func _ceremony() -> void:
	await _t("D10O_T_ENVOY")
	await _say("SPK_HASAN", "D10O_G_ENVOY")
	await _open_gate()
	player.frozen = true
	var tw := create_tween()
	tw.tween_property(player, "global_position", _at(Vector3(0.3, 0, GATE_Z - 3.0)) + Vector3(0, 0.1, 0), 2.0 if not GameState.autotest else 0.05)
	await tw.finished
	aga.look_target = player
	player.face(aga.global_position + Vector3(0, 1.7, 0))
	await _say("SPK_AGA", "D10O_A_CHASE")
	var ok := await _q3_ask()
	if not ok:
		await _say("SPK_AGA", "D10O_A_ENVOY_WRONG")
	await _inside()
	_outcome = "10O.1"


func _open_gate() -> void:
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_gate_l, "rotation:y", -1.5, 1.2 if not GameState.autotest else 0.05)
	tw.tween_property(_gate_r, "rotation:y", 1.5, 1.2 if not GameState.autotest else 0.05)
	await tw.finished


## Kapının ardı: otağın perdesi, ardında bir gölge. "Yarın."
func _inside() -> void:
	await hud.fade_to(1.0, 0.5)
	var p := _at(CampDay.OTAG_POS + Vector3(0, 0, 9.2)) + Vector3(0, 0.1, 0)
	player.global_position = p
	player.face(fatih.global_position + Vector3(0, 1.5, 0))
	fatih.visible = true
	fatih.position = _at(CampDay.OTAG_POS + Vector3(0, 0, 7.4))
	Person.make_hologram(fatih, Color(0.1, 0.05, 0.05, 0.75))
	await hud.fade_to(0.0, 0.8)
	await _t("D10O_T_INSIDE")
	await _say("SPK_FATIH", "D10O_F_TOMORROW")
	await _t("D10O_T_END")


# ---------------------------------------------------------------- otomatik test

func _auto() -> void:
	match GameState.autotest_variant:
		"fail":
			for i in MAX_TRIES:
				if _outcome == "":
					await _trial()
		"retry":
			await _trial()
			await _queue_talk("cameleer")
			await _trial()
		_:
			await _queue_talk("cameleer")
			await _trial()


# ================================================================ bölüm sonu

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
		print("AUTOTEST chapter=10 -> 11 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter11.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter11.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW10O_TITLE")
	c.nodes = [
		{"id": "queue", "key": "FLOW10O_QUEUE", "pos": Vector2(0.3, 0.15)},
		{"id": "envoy", "key": "FLOW10O_ENVOY", "pos": Vector2(0.75, 0.15)},
		{"id": "q", "key": "FLOW10O_QUESTIONS", "pos": Vector2(0.3, 0.32)},
		{"id": "honest", "key": "FLOW10O_HONEST", "pos": Vector2(0.62, 0.42)},
		{"id": "10O.1", "key": "FLOW_10O_1", "pos": Vector2(0.3, 0.56), "outcome": true},
		{"id": "10O.2", "key": "FLOW_10O_2", "pos": Vector2(0.1, 0.72), "outcome": true},
	]
	c.edges = [["queue", "q"], ["q", "10O.1"], ["q", "10O.2"], ["q", "honest"], ["envoy", "10O.1"], ["honest", "10O.1"]]
	c.taken["envoy" if _envoy else "queue"] = true
	if not _envoy:
		c.taken["q"] = true
	if GameState.flags.get("ch10_honest", false):
		c.taken["honest"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH10O_STATS") % [_tries, int(GameState.flags.get("merak", 0)), GameState.paradox],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW10_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase == "free" and SPEAKERS.has(id) and id != "guards":
		p = tr("UI_PROMPT3_TALK") % tr(SPEAKERS[id])
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy or phase != "free":
		return
	match id:
		"aga":
			_trial()
		"cameleer", "dervish", "tailor":
			_queue_talk(id)
		"goat":
			hud.bark("SPK_TOLGA", "D9_T_GOAT", 2.5)
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _npc(who: String) -> Node3D:
	match who:
		"aga": return aga
		"cameleer": return cameleer
		"dervish": return dervish
		"tailor": return tailor
	return null


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _say(speaker: String, key: String) -> void:
	var who: Person = null
	for k in SPEAKERS:
		if SPEAKERS[k] == speaker:
			who = _npc(k) as Person
	if speaker == "SPK_FATIH":
		who = fatih
	if who:
		who.talking = true
	await hud.say(speaker, key)
	if who and is_instance_valid(who):
		who.talking = false


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var expected: String = {"": "10O.1", "fail": "10O.2", "honest": "10O.1", "selfie": "10O.1", "byz": "10O.1",
		"retry": "10O.1", "next": "10O.1"}[GameState.autotest_variant]
	var ok := _outcome == expected
	match GameState.autotest_variant:
		"honest":
			ok = ok and GameState.flags.get("ch10_honest", false)
		"selfie":
			ok = ok and _shown.has("selfie")
		"retry":
			ok = ok and _tries == 1
		"fail":
			ok = ok and _tries == MAX_TRIES
		"byz":
			ok = ok and _envoy
	if GameState.chapter_outcomes.get(10, "") != _outcome:
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=10 variant=%s outcome=%s tries=%d envoy=%s merak=%d" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, _outcome, _tries, str(_envoy), int(GameState.flags.get("merak", 0))])
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
	phase = "free"
	_update_objective()
	dervish.position = _at(DERVISH_POS + Vector3(1.4, 0, -1.0))
	player.global_position = _at(Vector3(-0.4, 0, -40.0)) + Vector3(0, 0.1, 0)
	player.face(_at(AGA_POS) + Vector3(0, 1.6, 0))
	hud.bark("SPK_AGA", "D10O_A_SHOUT", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c10_01_kapi.png")
	player.global_position = _at(CAMEL_POS + Vector3(2.4, 0, 2.6)) + Vector3(0, 0.1, 0)
	player.face(cameleer.global_position + Vector3(0, 1.4, 0))
	cameleer.talking = true
	hud.bark("SPK_CAMELEER", "D10O_CAMELEER_2", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c10_02_deveci.png")
	cameleer.talking = false
	player.global_position = _at(Vector3(0.6, 0, GATE_Z + 4.2)) + Vector3(0, 0.1, 0)
	player.face(aga.global_position + Vector3(0, 1.5, 0))
	aga.talking = true
	hud.bark("SPK_AGA", "D10O_A_Q3_CAMEL", 30.0)
	hud.choose(["UI_CH10O_Q3_CAMEL_A", "UI_CH10O_Q3_CAMEL_B", "UI_CH10O_Q3_CAMEL_C", "UI_CH10O_Q3_IDK"], 9.0, 0)
	await get_tree().create_timer(0.8).timeout
	await _shot("c10_03_soru.png")
	hud.choose_cancel()
	aga.talking = false
	_gate_l.rotation.y = -1.5
	_gate_r.rotation.y = 1.5
	var p := _at(CampDay.OTAG_POS + Vector3(0, 0, 9.2)) + Vector3(0, 0.1, 0)
	player.global_position = p
	player.face(fatih.global_position + Vector3(0, 1.5, 0))
	fatih.visible = true
	fatih.position = _at(CampDay.OTAG_POS + Vector3(0, 0, 7.4))
	Person.make_hologram(fatih, Color(0.1, 0.05, 0.05, 0.75))
	hud.set_objective("")
	hud.bark("SPK_FATIH", "D10O_F_TOMORROW", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c10_04_otag.png")
	get_tree().quit()
