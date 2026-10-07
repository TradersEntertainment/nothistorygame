extends Node3D
## Bölüm 23 — Elçi (Tolga · 21 Mayıs 1453, Blakherna Sarayı). docs/SIEGE.md §3.
##
## Sultan son bir teklif gönderir (İsmail Hamza): şehir teslim edilirse İmparator'a Mora, halka can ve mal güvencesi.
## İmparator reddeder: "Şehri teslim etmek ne benim elimde ne de burada yaşayan kimsenin..."
## Sarayın Rum tercümanı hastadır; iki dili de bilen Tolga çevirir. Tolga'nın işi ikna etmek değil, doğru
## çevirmektir: yumuşatmak ya da kendinden eklemek "tercüman sapması" göstergesini doldurur. Sonuç değişmez.
## Tespit karesi: iki heyet aynı karede.
##   23.1 Sadık tercüme (sapma 0) · 23.2 "Yaratıcı" tercüme (sapma ≥ 1; Paradoks hafifçe artar)
##   Bölüm 22'de kulenin ateşinde kaşları yanan Tolga'ya Theodoros takılır (tolga_singed); Bölüm 12'de İmparator'un
##   mektubunu Sultan'a götürdüyse (letter_delivered) İsmail teklifin o mektubun cevabı olduğunu söyler.
##   --autotest[=creative|pass|singed|letter]   (varsayılan: 23.1)

const HALL := ByzCity.EMPEROR_POS
const SPEAKERS := {"SPK_EMPEROR": "emperor", "SPK_ISMAIL": "ismail", "SPK_THEODOROS": "theodoros"}

var city: ByzCity
var player: Player
var hud: Hud
var ismail: Person
var aide: Person
var theodoros: Person
var phase := "intro"
var _outcome := ""
var deviation := 0
var _card_given := false
var _singed := false            # Theodoros yanık kaşları fark etti (Bölüm 22)
var _letter := false            # İsmail Nisan'daki mektubu andı (Bölüm 12)
var _photo := ""
var cam: TespitCam
var _meter: Control
var _meter_bar: ColorRect


func _ready() -> void:
	GameState.snapshot(23)
	if GameState.autotest and GameState.autotest_variant == "pass":
		GameState.pocket_add("guest_pass", "permit_6b")        # 6b'de Theodoros'un verdiği yortu izni
	if GameState.autotest and GameState.autotest_variant == "singed":
		GameState.flags["tolga_singed"] = true                  # Bölüm 22: kule yanarken kaşlar da yandı
	if GameState.autotest and GameState.autotest_variant == "letter":
		GameState.flags["letter_delivered"] = true              # Bölüm 12: İmparator'un mektubu Sultan'a verildi
		GameState.chapter_outcomes[12] = "12.1"                 # (kuşatma testleri Bölüm 12'nin sonucunu kurmaz)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(false)
	hud.set_signal(0)
	city = ByzCity.new()
	add_child(city)
	city.niko.visible = false
	# Saray avlusunun köşesindeki konsey (yan sahne) kabul töreninde yok: saray erkânının sırasına denk geliyordu
	for n in city.get_children():
		if n is Person and str(n.get_meta("spk", "")) in ["SPK_NOTARAS", "SPK_ISIDORE", "SPK_BAILO"]:
			n.visible = false
	var ci := city.get_node_or_null("Interact_ev:council")
	if ci:
		ci.queue_free()
	_build()
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	var c := HALL
	# İsmail Hamza (Sinop beyi, Sultan'ın elçisi) ve yanında bir kâtip; karşıda Theodoros
	ismail = Person.new({"coat": Color("2f5a4a"), "pants": Color("2a3a30"), "hat": "turban", "beard": true, "mustache": true,
		"hair": Color("4a4a4a"), "robe": Color("2f5a4a"), "skin": Color("d9a07a"),
		"face": {"nose": "long", "brow": 1.1, "brow_tilt": 4.0, "beard": "long", "head": Vector3(0.96, 1.1, 0.98), "blush": false}})
	ismail.set_meta("spk", "SPK_ISMAIL")
	ismail.position = c + Vector3(1.5, 0, 1.4)
	add_child(ismail)
	aide = Person.new({"coat": Color("8a6a3a"), "pants": Color("4a3a2a"), "hat": "turban", "mustache": true, "robe": Color("a8804a")})
	aide.set_meta("no_talk", true)
	aide.position = c + Vector3(2.3, 0, 2.3)
	add_child(aide)
	theodoros = Person.new({"coat": Color("5a3a6a"), "pants": Color("3a2a4a"), "hat": "kamelaukion", "robe": Color("5a3a6a"),
		"beard": true, "hair": Color("6a6a6a"), "skin": Color("e0b08a")})
	theodoros.set_meta("spk", "SPK_THEODOROS")
	theodoros.position = c + Vector3(1.0, 0, -1.8)
	add_child(theodoros)
	for p: Person in [ismail, aide]:
		p.look_at_from_position(p.position, city.emperor.global_position, Vector3.UP)
		p.rotate_y(PI)
	theodoros.look_target = player
	# Heyetin yürüdüğü yol: altın bordürlü kırmızı halı (İmparator'un önüne kadar), iki yanında uzun şamdanlar
	var ep := city.emperor.global_position
	var run := Props.box(self, Vector3(9.0, 0.02, 1.6), Vector3((ep.x + c.x + 8.0) * 0.5 + 0.4, 0.012, ep.z), Color("8a1c22"))
	run.material_override = Props.mat(Color("8a1c22"), 0.0, false, "", false)
	for sz: float in [-0.74, 0.74]:
		Props.box(self, Vector3(9.0, 0.022, 0.1), Vector3(run.position.x, 0.014, ep.z + sz), Color("c49a45"))
	for sz: float in [-1.3, 1.3]:
		var cp := ep + Vector3(0.9, 0, sz)
		Props.cyl(self, 0.18, 0.1, Vector3(cp.x, 0.05, cp.z), Color("b08a38"), Vector3.ZERO, 10)
		Props.cyl(self, 0.04, 1.6, Vector3(cp.x, 0.85, cp.z), Color("c49a45"), Vector3.ZERO, 8)
		Props.cyl(self, 0.12, 0.05, Vector3(cp.x, 1.66, cp.z), Color("c49a45"), Vector3.ZERO, 10)
		Props.cyl(self, 0.035, 0.22, Vector3(cp.x, 1.8, cp.z), Color("f4eed8"), Vector3.ZERO, 8)
		var fl := Props.ball(self, 0.04, Vector3(cp.x, 1.95, cp.z), Color("ffc050"), Vector3(1, 1.8, 1), 6, 3.0)
		fl.material_override = Props.mat(Color("ffc050"), 3.0, false, "", false)
	# Kabul töreni: heyetin geçtiği yolun iki yanında mızrak-kalkanlı muhafız sırası (içe bakar), arkalarında
	# saray erkânı; mangala masasının önü boş
	var k := 0
	for x: float in [0.4, 2.2, 4.0, 5.8, 7.6]:
		Garrison.man(self, c + Vector3(x, 0, -4.9), 0.0, 230 + k, "spear_shield")
		k += 1
	for x: float in [2.4, 4.2, 6.0, 7.8]:
		Garrison.man(self, c + Vector3(x, 0, 5.3), PI, 230 + k, "spear_shield")
		k += 1
	for i in 5:
		var cx := Person.new({"coat": [Color("5a3a6a"), Color("2a4a6a"), Color("6a2a2a"), Color("4a5a3a"), Color("6a5a3a")][i],
			"pants": Color("2a2a30"), "hat": "kamelaukion" if i % 2 == 0 else "none", "robe": [Color("5a3a6a"), Color("2a4a6a"), Color("6a2a2a"), Color("4a5a3a"), Color("6a5a3a")][i],
			"beard": i != 2, "hair": [Color("6a6a6a"), Color("3a2a1e")][i % 2], "n": i})
		cx.set_meta("no_talk", true)
		cx.set_meta("no_chat", true)
		cx.position = c + Vector3(1.2 + i * 1.7, 0, -6.4 if i % 2 == 0 else 6.7)
		cx.rotation.y = 0.0 if i % 2 == 0 else PI
		add_child(cx)
	# Sapma göstergesi (sağ üst): tercümanın sözden ne kadar saptığı
	_meter = VBoxContainer.new()
	_meter.anchor_left = 1.0
	_meter.anchor_right = 1.0
	_meter.offset_left = -300.0
	_meter.offset_right = -24.0
	_meter.offset_top = 90.0
	_meter.offset_bottom = 140.0
	_meter.visible = false
	hud.add_child(_meter)
	var l := Label.new()
	l.text = tr("UI_CH23_METER")
	l.add_theme_font_size_override("font_size", 16)
	_meter.add_child(l)
	var back := ColorRect.new()
	back.color = Color(0, 0, 0, 0.5)
	back.custom_minimum_size = Vector2(270, 10)
	_meter.add_child(back)
	_meter_bar = ColorRect.new()
	_meter_bar.color = Color("ffb13b")
	_meter_bar.size = Vector2(0, 10)
	back.add_child(_meter_bar)


func _npc(speaker: String) -> Person:
	match speaker:
		"SPK_EMPEROR":
			return city.emperor
		"SPK_ISMAIL":
			return ismail
		"SPK_THEODOROS":
			return theodoros
	return null


func _say(speaker: String, key: String) -> void:
	var who := _npc(speaker)
	if who:
		who.talking = true
	await hud.say(speaker, key)
	if who and is_instance_valid(who):
		who.talking = false


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _deviate(n: int) -> void:
	deviation += n
	_meter_bar.size = Vector2(270.0 * clampf(deviation / 4.0, 0.0, 1.0), 10)
	_meter_bar.color = Color("ff5a4a") if deviation >= 3 else Color("ffb13b")
	if n > 0:
		Audio.sfx("radio_static", -14.0)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	Audio.music("byzantium")
	await hud.card([[tr("UI_CH23_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH23_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	# Osmanlı tarafının tanığı İsmail'in heyetiyle gelir: elçinin yanında durur
	var osm := Siege.side() == "O" or GameState.autotest_variant == "osm"
	# Tercüman iki heyetin arasında ama biraz geride: ikisini de görür, kimse kameranın dibinde durmaz
	player.global_position = HALL + (Vector3(5.6, 0.05, 0.9) if osm else Vector3(5.6, 0.05, -0.3))
	player.face(city.emperor.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	if osm:
		await hud.say("SPK_NIHAT", "D23O_N_01")
		await _say("SPK_ISMAIL", "D23O_I_01")
	else:
		await hud.say("SPK_NIHAT", "D23_N_01")
	await _say("SPK_THEODOROS", "D23_TH_01")
	await _t("D23_T_01")
	# Bölüm 22: kule yanarken Tolga'nın kaşları da yandı. Theodoros fark eder
	if not osm and GameState.flags.get("tolga_singed", false):
		_singed = true
		await _say("SPK_THEODOROS", "D23_TH_SINGED")
		await _t("D23_T_SINGED")
	# Misafir İzni (6b): Theodoros yortu iznindeki tek mührünü tanır, ikincisini basar: "saray tercümanı". Bölüm 25'teki
	# son ayinde Tolga saray halkının arasında durur; İmparator helalliği ona ayrıca söyler
	if not osm and GameState.in_pocket("guest_pass"):
		player.show_prop("guest_pass", 2.4)
		GameState.pocket_use("guest_pass", "pass_23")
		await _say("SPK_THEODOROS", "D23_TH_PASS")
		await _t("D23_T_PASS")
		GameState.flags["pass_palace"] = true
	var met_emperor: bool = String(GameState.chapter_outcomes.get(10, "")).begins_with("10H") or GameState.flags.get("byz_letter", false)
	var met_sultan: bool = GameState.chapter_outcomes.has(12)
	if met_emperor:
		await _say("SPK_EMPEROR", "D23_K_KNOWN")
	if met_sultan:
		await _say("SPK_ISMAIL", "D23_I_KNOWN")
		# Bölüm 12: İmparator'un mektubunu Sultan'a Tolga götürdü; bugünkü teklif o mektubun cevabı
		if GameState.flags.get("letter_delivered", false):
			_letter = true
			await _say("SPK_ISMAIL", "D23_I_LETTER")
	_meter.visible = true
	phase = "translate"
	var v := GameState.autotest_variant
	# 1. Teklif
	await _say("SPK_ISMAIL", "D23_I_OFFER_1")
	await _say("SPK_ISMAIL", "D23_I_OFFER_2")
	var c := await hud.choose(["UI_C23_1_TRUE", "UI_C23_1_SOFT", "UI_C23_1_ADD"], 0.0, 1 if v == "creative" else 0)
	match c:
		0:
			await _t("D23_T_1_TRUE")
			await _say("SPK_EMPEROR", "D23_K_1_TRUE")
		1:
			_deviate(1)
			await _t("D23_T_1_SOFT")
			await _say("SPK_THEODOROS", "D23_TH_1_SOFT")
			await _t("D23_T_1_FIX")
		2:
			_deviate(2)
			await _t("D23_T_1_ADD")
			await _say("SPK_EMPEROR", "D23_K_1_ADD")
			await _t("D23_T_1_FIX")
	# 2. İmparator'un cevabı (tarihteki söz)
	await _say("SPK_EMPEROR", "D23_K_ANSWER_1")
	await _say("SPK_EMPEROR", "D23_K_ANSWER_2")
	c = await hud.choose(["UI_C23_2_TRUE", "UI_C23_2_SOFT", "UI_C23_2_ADD"], 0.0, 2 if v == "creative" else 0)
	match c:
		0:
			await _t("D23_T_2_TRUE")
			await _say("SPK_ISMAIL", "D23_I_2_TRUE")
		1:
			_deviate(1)
			await _t("D23_T_2_SOFT")
			await _say("SPK_ISMAIL", "D23_I_2_SOFT")
		2:
			_deviate(2)
			await _t("D23_T_2_ADD")
			await _say("SPK_ISMAIL", "D23_I_2_ADD")
	# 3. Elçinin tercümana söylediği: Sultan kararlı
	await _say("SPK_ISMAIL", "D23_I_ASIDE")
	c = await hud.choose(["UI_C23_3_TELL", "UI_C23_3_KEEP"], 0.0, 0)
	if c == 0:
		await _t("D23_T_3_TELL")
		await _say("SPK_EMPEROR", "D23_K_3_TELL")
	else:
		_deviate(1)
		await _t("D23_T_3_KEEP")
	await _say("SPK_EMPEROR", "D23_K_DISMISS")
	await _say("SPK_ISMAIL", "D23_I_FAREWELL")
	_meter.visible = false
	await _photo_step()
	await _card_step()
	if osm:
		await _say("SPK_ISMAIL", "D23O_I_END")
		await _t("D23O_T_END")
	await _delegation_leaves()
	await hud.say("SPK_NIHAT", "D23_N_END_TRUE" if deviation == 0 else "D23_N_END_CREATIVE")
	_outcome = "23.1" if deviation == 0 else "23.2"
	if deviation > 0:
		GameState.paradox += 5
	GameState.flags["ch23_deviation"] = deviation
	Siege.record(23, _photo, "SIEGE_NOTE_23_%s" % _outcome.split(".")[1])
	await _end_chapter()


## Tespit karesi: iki heyet aynı karede (hedef: İmparator ile elçinin ortası; ikisi de kadrajda olmalı).
func _photo_step() -> void:
	var target := Node3D.new()
	add_child(target)
	target.global_position = (city.emperor.global_position + ismail.global_position) * 0.5 + Vector3(0, 1.4, 0)
	Lore.scatter(self, "23")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ23_PHOTO"), target.global_position)
	await _say("SPK_THEODOROS", "D23_TH_PHOTO")
	cam = TespitCam.new(player, hud, target, "siege23")
	hud.add_child(cam)
	cam.max_dist = 14.0
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
		await _say("SPK_ISMAIL", "D23_I_FLASH")


func _card_step() -> void:
	player.face(ismail.global_position + Vector3(0, 1.5, 0))
	var c := await hud.choose(["UI_C23_CARD", "UI_C23_NOCARD"], 0.0, 0)
	if c == 0:
		_card_given = true
		GameState.flags["ismail_card"] = true
		await _t("D23_T_CARD")
		await _say("SPK_ISMAIL", "D23_I_CARD")


## Heyet salondan çıkar: tahttan uzağa, tercümanın yanından meydana (eskiden oyuncudan uzağa yürüyordu: oyuncu salonun
## girişinde durduğu için bu, tahtın ardındaki saray cephesinin içine demekti; Osmanlı tarafında İsmail son sözünü
## binanın içinden söylüyor, kartında yüzü yerine duvar görünüyordu).
func _delegation_leaves() -> void:
	var ep := city.emperor.global_position
	ismail.leave(ep, 7.0, 3.0, true)
	aide.leave(ep, 7.0, 3.0, true)
	await get_tree().create_timer(1.0).timeout


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(23, _outcome)
	await Siege.show_page(hud, 23)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(23)
			if nxt != "":
				GameState.change_scene(nxt)
			else:
				hud.set_fade(1.0)
				await hud.card([[tr("UI_SIEGE_TBC"), 30, Color("f2e6c9")], [tr("UI_SIEGE_TBC_SUB"), 18, Color(1, 1, 1, 0.7)]], 3.5)
				GameState.change_scene("res://scenes/main.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW23_TITLE")
	c.nodes = [
		{"id": "offer", "key": "FLOW23_OFFER", "pos": Vector2(0.5, 0.14)},
		{"id": "refusal", "key": "FLOW23_REFUSAL", "pos": Vector2(0.5, 0.32)},
		{"id": "23.1", "key": "FLOW_23_1", "pos": Vector2(0.3, 0.56), "outcome": true},
		{"id": "23.2", "key": "FLOW_23_2", "pos": Vector2(0.7, 0.56), "outcome": true},
	]
	c.edges = [["offer", "refusal"], ["refusal", "23.1"], ["refusal", "23.2"]]
	c.taken["offer"] = true
	c.taken["refusal"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH23_STATS") % [deviation, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "23.1", "creative": "23.2", "pass": "23.1"}.get(v, "23.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("23", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and _card_given
	# Yortu izni ikinci mührü aldı (saray tercümanı); izinsiz yolda bayrak hiç kurulmaz
	if GameState.flags.get("pass_palace", false) != (v == "pass"):
		printerr("AUTOTEST: saray tercümanı=%s" % GameState.flags.get("pass_palace", false))
		ok = false
	if _singed != (v == "singed") or _letter != (v == "letter"):
		printerr("AUTOTEST: kaş=%s mektup=%s" % [_singed, _letter])
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=23 variant=%s outcome=%s deviation=%d card=%s singed=%s letter=%s" % ["PASS" if ok else "FAIL", v, _outcome,
		deviation, _card_given, _singed, _letter])
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
	player.global_position = HALL + Vector3(5.6, 0.05, -0.3)
	await get_tree().create_timer(0.6).timeout
	player.face((city.emperor.global_position + ismail.global_position) * 0.5 + Vector3(0, 1.4, 0))
	_meter.visible = true
	_deviate(1)
	hud.bark("SPK_EMPEROR", "D23_K_ANSWER_1", 30.0)
	await _shot("c23_01_answer.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = HALL + Vector3(6.5, 2.2, 3.5)
	cv.look_at(HALL + Vector3(0.5, 1.4, -0.5), Vector3.UP)
	cv.fov = 55.0
	cv.make_current()
	await _shot("c23_cover.png")
	get_tree().quit()
