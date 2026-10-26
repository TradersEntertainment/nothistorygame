extends Node3D
## Bölüm 9 — Teklifler (Tolga · 25 Nisan 1453). CHAPTERS Bölüm 9, STORY_BRANCHES Matris 1 (D2–D6).
##
## Ordugâhta bir sabah. Yol değiştiren teklifler gelir; her yola en az biri:
##   A · Kadri:    "Ziyafeti sen pişir."            (menü denemesi)  → 9.1 · Ziyafet
##   C · Urban:    "Kal, top dökelim."              (açı hesabı)     → 9.2 · Büyük Atış
##   Y · Çandarlı: "Bu mektubu Galata'ya götür."    (Y'de garanti; 6a.5'te mektup alındıysa her yolda)
##                  Galata → 9.3 · ya da Fatih'e götür (Merak +1) → Otağ kapısı
##   B · Lütfi:    "Heyete Frenk danışman olarak gel." (selam denemesi) → 9.4 · Heyet
##   Bz · Theodoros (Labirent kusursuzsa, 6b.1): eksik çıkış formu için beyaz bayrakla ordugâha gelir,
##                  "Arşivde kal." → 9.5 · Arşiv
##   Hepsini reddet, otağ kapısında bekle → 9.6 · Otağ Kapısı
## Hikmet 8.4'te makineye bindiyse pazarda pijamayla bir keçiden kaçarken karşımıza çıkar.
##   --autotest[=b|c|y|arch|none|fatih|cell|hikmet]   (varsayılan: 9.1)

const GATE_POS := Vector3(0.0, 0.0, -52.5)
const PASHA_POS := Vector3(10.6, 0.0, 21.0)
const THEO_POS := Vector3(-1.6, 0.0, 19.2)   # pazarın girişi, Bizans yolundan gelenin önünde
const HIKMET_POS := Vector3(-5.5, 0.0, 12.5)
const BYZ_SPAWN := Vector3(0.0, 0.0, 22.0)
const MINER_POS := Vector3(-7.5, 0.0, -25.0)
const SPEAKERS := {"kadri": "SPK_KADRI", "lutfi": "SPK_LUTFI", "urban": "SPK_URBAN", "pasha": "SPK_PASHA",
	"theodoros": "SPK_THEODOROS", "guards": "SPK_HASAN", "hikmet": "SPK_HIKMET", "candarli": "SPK_CANDARLI", "miner": "SPK_MINER"}
const RESULT := {"kadri": "9.1", "urban": "9.2", "pasha": "9.3", "lutfi": "9.4", "theodoros": "9.5", "miner": "9.7"}
## Oynanabilir dal bölümleri (diğerleri "yakında")
const NEXT_SCENE := {"9.1": "res://scenes/chapter10z.tscn", "9.2": "res://scenes/chapter10b.tscn", "9.3": "res://scenes/chapter10g.tscn", "9.4": "res://scenes/chapter10h.tscn", "9.5": "res://scenes/chapter10a.tscn", "9.7": "res://scenes/chapter10l.tscn", "9.6": "res://scenes/chapter10.tscn"}

var day: CampDay
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _busy := false
var _route := ""                 # A, B, C, Y ya da "" (Bizans'tan gelen)
var _byz := false
var _offers: Array = []          # teklif veren karakterler
var _declined: Dictionary = {}
var _trial: Dictionary = {}
var pasha: Person
var _cur_npc := ""
var _gate_seen := false
var theodoros: Person
var hikmet_npc: Hikmet
var hasan: Soldier
var huseyin: Soldier
var miner: Person


func _ready() -> void:
	GameState.snapshot(9)
	_apply_autotest_setup()
	var ch6: String = GameState.chapter_outcomes.get(6, "6a.1")
	_byz = ch6.begins_with("6b")
	if not _byz:
		_route = {"6a.1": "A", "6a.2": "B", "6a.3": "C", "6a.4": "Y"}.get(ch6, GameState.flags.get("route", "A"))
	match _route:
		"A": _offers.append("kadri")
		"B": _offers.append("lutfi")
		"C": _offers.append("urban")
		"Y": _offers.append("pasha")
	if _route != "Y" and not _byz and GameState.flags.get("candarli_letter", false):
		_offers.append("pasha")
	if ch6 == "6b.1":
		_offers.append("theodoros")
	# Lağımcılar her ordugâh yolunda kazmacı arar (Novo Brdo'lu madenciler, tarihî)
	if not _byz:
		_offers.append("miner")
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
	day = CampDay.new()
	add_child(day)
	day.goat.chase = player
	day.kadri.look_target = player
	day.lutfi.look_target = player
	day.urban.look_target = player
	if day.ring_node:
		day.ring_node.queue_free()
	_build_extras()
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
		"b": GameState.chapter_outcomes[6] = "6a.2"
		"c": GameState.chapter_outcomes[6] = "6a.3"
		"y": GameState.chapter_outcomes[6] = "6a.4"
		"arch": GameState.chapter_outcomes[6] = "6b.1"
		"cell": GameState.chapter_outcomes[6] = "6b.3"
		"fatih": GameState.flags["candarli_letter"] = true
		"hikmet": GameState.chapter_outcomes[8] = "8.4"
		"cube": GameState.give("cube", "guards", "cube_huseyin_4a")     # 4a'da küp Hüseyin'de kaldı: kapıda geri gelir
		"gifts":
			# 4a'da küp Hüseyin'de, termos ikisinde kaldı: kapıda ikisi de geri gelir (çantada iki göz boş)
			GameState.bag.erase("cologne")
			GameState.bag.append("thermos")
			GameState.give("cube", "guards", "cube_huseyin_4a")
			GameState.give("thermos", "guards", "thermos_guards_4a")


func _process(_delta: float) -> void:
	if hud and phase == "free" and not _busy and Input.is_action_just_pressed("fez"):
		var on: bool = not GameState.flags.get("fez", true)
		GameState.flags["fez"] = on
		hud.set_fez(on)


# ================================================================ sahne

func _build_extras() -> void:
	# Otağ kapısında onur muhafızı: Hasan ile Hüseyin, saçağın altında kapının iki yanında. Saçak direkleri x ±1,6'da
	# (CampDay._build_otag): eskiden muhafızlar x ±1,7'de, direğin tam üstündeydi; direk gövdelerinin içinden geçiyordu
	var gy := _ground_y(GATE_POS.z - 0.4)
	hasan = Soldier.new(Color("b3262d"), "stand", "bork")
	hasan.set_meta("spk", "SPK_HASAN")
	hasan.position = GATE_POS + Vector3(-1.05, gy, -0.4)
	add_child(hasan)
	huseyin = Soldier.new(Color("2f5fa8"), "stand", Soldier.huseyin_hat())
	huseyin.set_meta("spk", "SPK_HUSEYIN")
	huseyin.position = GATE_POS + Vector3(1.05, gy, -0.4)
	add_child(huseyin)
	Props.interactable(self, "guards", Vector3(4.6, 2.2, 1.4), GATE_POS + Vector3(0, gy + 1.1, 0))
	# Çandarlı Halil Paşa: pazarın arkasında, kılık değiştirmiş (ama sarığı fazla büyük)
	if "pasha" in _offers:
		pasha = Person.new({"face": "candarli", "coat": Color("3a4a3a"), "pants": Color("2a2a24"), "hat": "vizier", "beard": true, "mustache": true,
			"hair": Color("8a8a8a"), "robe": Color("3a4a3a"), "skin": Color("d9a07a")})
		pasha.set_meta("spk", "SPK_PASHA")     # Çandarlı kılık değiştirmiş: "paşa" diye konuşur, yüzü yine onun
		pasha.position = PASHA_POS
		pasha.rotation.y = PI * 0.9
		pasha.scale = Vector3(1.05, 1.05, 1.05)
		pasha.look_target = player
		add_child(pasha)
		Props.interactable(self, "pasha", Vector3(1.2, 2.0, 1.2), PASHA_POS + Vector3(0, 1.0, 0))
		# Kukuletalı adam Paşa'nın arkasında bekler (önünde, Paşa'ya giden yolun üstündeydi: koyu cüppesi kadrajı örtüyordu)
		var cpos := PASHA_POS + Vector3(1.3, 0, 1.5)
		day.candarli.position = cpos
		day.candarli.rotation.y = pasha.rotation.y
		var ci := day.get_node_or_null("Interact_candarli") as Node3D
		if ci:
			ci.position = cpos + Vector3(0, 1.0, 0)
	# Theodoros: beyaz bayrakla, elinde form
	if "theodoros" in _offers or GameState.chapter_outcomes.get(6, "") == "6b.3":
		theodoros = Person.new({"coat": Color("5a3a6a"), "pants": Color("3a2a4a"), "hat": "kamelaukion", "robe": Color("5a3a6a"),
			"beard": true, "hair": Color("6a6a6a"), "skin": Color("e0b08a")})
		theodoros.set_meta("spk", "SPK_THEODOROS")
		theodoros.position = THEO_POS
		theodoros.rotation.y = 0.0     # gelen oyuncuya dönük (tezgâhın tentesinin altında, sırtı yola dönüktü)
		theodoros.look_target = player
		add_child(theodoros)
		Props.cyl(theodoros, 0.02, 2.2, Vector3(0.35, 1.1, 0.1), Color("6a5030"), Vector3.ZERO, 5)
		Props.box(theodoros, Vector3(0.02, 0.5, 0.7), Vector3(0.35, 1.95, 0.45), Color("f4f1ea"))
		Props.interactable(self, "theodoros", Vector3(1.2, 2.0, 1.2), THEO_POS + Vector3(0, 1.0, 0))
	# Lağımcı Dragan: toprak içinde, elinde kazma; yanında bir lağım ağzı
	if "miner" in _offers:
		miner = Person.new({"coat": Color("6a5a48"), "pants": Color("3a3028"), "hat": "none", "beard": true, "mustache": true,
			"hair": Color("4a3a2a"), "apron": Color("4a3a2a"), "skin": Color("c89070")})
		miner.set_meta("spk", "SPK_MINER")
		miner.position = MINER_POS + Vector3(0, _ground_y(MINER_POS.z), 0)
		miner.look_target = player
		add_child(miner)
		Props.cyl(miner, 0.025, 1.1, Vector3(0.35, 0.9, 0.2), Color("6a4a2c"), Vector3(0, 0, 20), 5)
		Props.box(miner, Vector3(0.45, 0.08, 0.06), Vector3(0.52, 1.42, 0.2), Color("5a5a60"), Vector3(0, 0, 20))
		var mouth := MINER_POS + Vector3(-1.8, _ground_y(MINER_POS.z), -1.2)
		# Lağım ağzı, dikmeler ve hafriyat yığını katı (içlerinden yürünüyordu)
		# Ağız bir toprak yamacına açılır: arkada hafriyat tepesi, önde içe doğru kararan oyuk (dikili siyah levha gibiydi)
		Props.make_solid(Props.ball(self, 1.0, mouth + Vector3(0, 0.2, -1.9), Color("6a5438"), Vector3(2.4, 1.9, 1.8), 8))
		Props.make_solid(Props.box(self, Vector3(1.6, 1.6, 0.4), mouth + Vector3(0, 0.6, -0.05), Color("0c0a08")))
		Props.box(self, Vector3(1.6, 0.06, 1.0), mouth + Vector3(0, 0.03, 0.3), Color("4a3a28"), Vector3(-8, 0, 0))
		for sx in [-0.9, 0.9]:
			Props.make_solid(Props.cyl(self, 0.09, 1.9, mouth + Vector3(sx, 0.95, 0.2), Color("6a4a2c"), Vector3.ZERO, 5))
		Props.box(self, Vector3(2.0, 0.18, 0.25), mouth + Vector3(0, 1.9, 0.2), Color("6a4a2c"))
		for i in 6:
			Props.make_solid(Props.ball(self, 0.5, mouth + Vector3(-1.6 + i * 0.6, 0.2, 1.0 + (i % 2) * 0.4), Color("6a5438"), Vector3(1.3, 0.6, 1.0), 6))
		Props.interactable(self, "miner", Vector3(1.2, 2.0, 1.2), MINER_POS + Vector3(0, _ground_y(MINER_POS.z) + 1.0, 0))
	# Hikmet (8.4): pijamayla, pazarda, keçiden kaçıyor
	if GameState.chapter_outcomes.get(8, "") == "8.4":
		hikmet_npc = Hikmet.new()
		hikmet_npc.position = HIKMET_POS
		hikmet_npc.look_target = player
		add_child(hikmet_npc)
		hikmet_npc.carry_gun()
		Props.interactable(hikmet_npc, "hikmet", Vector3(1.2, 2.0, 1.2), Vector3(0, 1.0, 0))
	# Keçi: 8.4'te pijamalı Hikmet'i kovalar ("Bir keçi beni kovalıyor": eskiden yalnız Tolga'dan kaçıyordu);
	# 6a'da yakalanıp tüccara götürüldüyse pazarın doğu ucunda, tüccarın yerinde durur (yeniden kaçak değil)
	if hikmet_npc:
		day.goat.chase = null
		day.goat.follow = hikmet_npc
		day.goat.position = HIKMET_POS + Vector3(2.4, 0, 1.2)
		_hikmet_flee()
	elif GameState.flags.get("goat_caught", false):
		day.goat.chase = null
		day.goat.position = Vector3(9.1, 0, 13.4)
		day.goat.bounds = Rect2(8.4, 12.7, 1.4, 1.4)
		day.goat.call("_pick_target")


## Hikmet keçiden kaçar: birkaç saniyede bir iki adım öteye seker, keçi peşinden gelir. Konuşurken durur.
func _hikmet_flee() -> void:
	var spots: Array[Vector3] = [HIKMET_POS, HIKMET_POS + Vector3(-1.8, 0, 0.9), HIKMET_POS + Vector3(-0.6, 0, 2.2)]
	var i := 0
	while is_instance_valid(hikmet_npc):
		await get_tree().create_timer(randf_range(3.5, 6.0), false).timeout
		if not is_instance_valid(hikmet_npc) or phase == "done":
			return
		if hikmet_npc.talking or _cur_npc == "hikmet":
			continue
		i = (i + 1) % spots.size()
		var to: Vector3 = spots[i]
		to.y = hikmet_npc.global_position.y
		var dir := to - hikmet_npc.global_position
		hikmet_npc.face_toward(to)
		var tw := create_tween()
		tw.tween_property(hikmet_npc, "global_position", to, clampf(dir.length() / 2.4, 0.4, 1.4)).set_trans(Tween.TRANS_SINE)
		await tw.finished
		if is_instance_valid(hikmet_npc) and hikmet_npc.look_target:
			hikmet_npc.face_toward(day.goat.global_position)


func _ground_y(z: float) -> float:
	return CampDay.height(0.0, z)


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH9_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH9_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	var spawn := BYZ_SPAWN if _byz else CampDay.SPAWN
	var look := spawn + Vector3(0, 1.6, -10.0)
	if _route == "A":
		spawn = CampDay.KITCHEN_SPAWN
		look = day.kadri.global_position + Vector3(0, 1.4, 0)
	elif _route == "B":
		spawn = CampDay.LUTFI_POS + Vector3(-2.6, 0, 1.8)
		spawn.y = CampDay.height(spawn.x, spawn.z)
		look = day.lutfi.global_position + Vector3(0, 1.4, 0)
	if _route == "Y" and GameState.flags.get("goat_caught", false):
		look = day.goat.global_position + Vector3(0, 0.6, 0)      # "Sigorta sattığım keçi beni görünce başını çevirdi"
	player.global_position = spawn
	player.face(look)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	if _byz:
		if GameState.chapter_outcomes.get(6, "") == "6b.3":
			await _t("D9_T_DEPORTED")
		else:
			await _t("D9_T_BYZ")
	else:
		# Y: keçi 6a'da pazarda yakalanmadıysa (kaftan Kadri'nin termos takasıyla) "sigorta sattığım keçi" yok
		await _t("D9_T_Y_PLAIN" if _route == "Y" and not GameState.flags.get("goat_caught", false) else "D9_T_" + _route)
	await _radio()
	await _t("D9_T_GOAL")
	phase = "free"
	Lore.scatter(self, "9")
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		await _auto()
	while _outcome == "":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	await _end_chapter()


## Hikmet'in telsiz çağrısı: Bölüm 8'in sonucuna göre. 8.4'te Hikmet zaten burada.
func _radio() -> void:
	var ch8: String = GameState.chapter_outcomes.get(8, "8.1")
	if ch8 == "8.4":
		if hikmet_npc:
			player.face(hikmet_npc.global_position + Vector3(0, 1.3, 0))     # "çok yakından": sesin geldiği yöne döner
		await _say("SPK_HIKMET", "D9_H_HERE")
		await _t("D9_T_HERE")
		return
	if GameState.telsiz_bag <= 0:
		await _t("D9_T_RADIO_DEAD")
		return
	await _say("SPK_HIKMET", "D9_H_CALL")
	var c := await hud.choose(["UI_CH6_ANSWER", "UI_CH6_IGNORE"], 6.0, 0)
	if c == 0:
		await _t("D9_T_ANSWER")
		var k8 := "D9_H_" + ch8.replace(".", "_")
		if ch8 == "8.2" and GameState.flags.get("ch8_reason", "") == "caught":
			k8 += "_CAUGHT"      # 8.2 yakalanarak da gelir: "parçayı bulamadım" denmez
		await _say("SPK_HIKMET", k8)
		GameState.telsiz_bag = mini(5, GameState.telsiz_bag + 1)
	else:
		await _say("SPK_HIKMET", "D9_H_NO_ANSWER")
		GameState.telsiz_bag = maxi(0, GameState.telsiz_bag - 1)
	hud.set_signal(GameState.telsiz_bag)


## İşaret ana yolu gösterir: otağ kapısı (huzura çıkış, fetih günleri). Teklifler isteğe bağlı yan
## yollardır; en yakın teklifi göstermek oyuncuyu farkında olmadan bir dala sokuyordu (ör. arşiv).
func _offer_spot() -> Callable:
	return func():
		return _npc_node("guards")


## Ana yol (otağ kapısı) altın işaretle; açık teklifler her biri kendi renginde işaretlenir (hepsi aynı anda görünür,
## kenardakiler renkli okla), adları hedef kutusunun altında aynı renklerle. Geri çevrilenler yalnız yazıda (✗).
func _update_objective() -> void:
	var declined := PackedStringArray()
	var choices: Array = []
	for o in _offers:
		var label := tr("UI_OFFER9_" + String(o).to_upper())
		if _declined.has(o):
			declined.append("✗ " + label)
		else:
			var who := String(o)
			choices.append([func(): return _npc_node(who), label])
	var head := tr("UI_OBJ9")
	if _offers.is_empty():
		head = tr("UI_OBJ9_NONE")
	var gate := tr("FLOW_9_6").get_slice(":", tr("FLOW_9_6").get_slice_count(":") - 1).strip_edges()
	hud.set_objective(head + ("\n" + "   ".join(declined) if not declined.is_empty() else ""), _offer_spot(), 1.6, choices, gate)


# ---------------------------------------------------------------- teklifler

func _talk(npc: String, auto := -1) -> void:
	if _busy or _outcome != "":
		return
	_busy = true
	_cur_npc = npc
	player.frozen = true
	var node := _npc_node(npc)
	if node and GameState.autotest:
		# Oyunda konuşma yanına yürüyünce başlar: test de oyuncuyu onun önüne koyar (görüş denetimi gerçek mesafeden)
		var away := player.global_position - node.global_position
		away.y = 0.0
		if away.length() > 3.0:
			player.global_position = _approach_point(node, away.normalized())
	if node:
		player.face(node.global_position + Vector3(0, 1.45, 0))
	match npc:
		"kadri", "lutfi", "urban", "miner":
			if npc in _offers:
				await _offer(npc, auto)
			else:
				await _say(SPEAKERS[npc], "D9_%s_BUSY" % npc.to_upper())
		"pasha":
			await _pasha(auto)
		"theodoros":
			await _theodoros(auto)
		"guards":
			await _gate(auto)
		"hikmet":
			await _hikmet()
		"candarli":
			# Paşa'ya yalnız teklifi açıkken yönlendirir (başka yolda pazarın arkasında kimse beklemiyordu)
			var waiting: bool = "pasha" in _offers and GameState.flags.get("letter_route", "") != "fatih" and _outcome == ""
			await _say("SPK_CANDARLI", "D9_C_NOBODY" if waiting else "D9_C_NOBODY_GONE")
	_update_objective()
	Lore.scatter(self, "9")
	player.frozen = false
	_cur_npc = ""
	_busy = false


## Kadri / Lütfi / Urban: teklif, küçük bir deneme, kabul ya da ret.
func _offer(npc: String, auto: int) -> void:
	var up := npc.to_upper()
	var spk: String = SPEAKERS[npc]
	if _declined.has(npc):
		await _say(spk, "D9_%s_AGAIN" % up)
	else:
		# Teklif, Bölüm 6'da gerçekten olana göre: Urban'ın topu bantlandı mı, ona küp gösterildi mi, Kadri'ye leblebi verildi mi
		var o1 := "D9_%s_OFFER_1" % up
		var o2 := "D9_%s_OFFER_2" % up
		if npc == "urban":
			if not GameState.flags.get("cannon_taped", false):
				o1 += "_PLAIN"
			if not GameState.showed("urban", "cube"):
				o2 += "_PLAIN"
		elif npc == "kadri" and not GameState.flags.get("leblebi_given", false):
			o2 += "_FIRE"
		await _say(spk, o1)
		await _t("D9_T_%s_Q" % up)
		await _say(spk, o2)
		if not _trial.has(npc):
			await _say(spk, "D9_%s_TRIAL" % up)
			var t := await hud.choose(["UI_CH9_%s_T1" % up, "UI_CH9_%s_T2" % up, "UI_CH9_%s_T3" % up], 0.0, 1)
			t = clampi(t, 0, 2)
			_trial[npc] = t
			GameState.flags["ch9_trial_" + npc] = t
			if npc == "miner" and t == 2:
				# "Karşıdan biri kazıyor": toprağın altından uzak kazma tıkırtısı gerçekten duyulur
				for k in 3:
					get_tree().create_timer(0.4 + k * 0.55, false).timeout.connect(Audio.sfx.bind("pick_tap", -20.0, 0.7))
			await _trial_action(npc, t)
			await _say(spk, "D9_%s_TR%d" % [up, t + 1])
	var pick := 0 if _auto_accepts(npc) else 1
	var c := await hud.choose(["UI_CH9_ACCEPT_" + up, "UI_CH9_DECLINE"], 0.0, pick)
	if c == 0 and not await _sure():
		return      # "Dur, bir düşüneyim": karar verilmedi; reddetmek değil (veda edip ✗ yazıyordu)
	if c == 0:
		await _say(spk, "D9_%s_YES" % up)
		await _accept_action(npc)
		await _t("D9_T_%s_YES" % up)
		_set_outcome(RESULT[npc])
	else:
		_declined[npc] = true
		await _say(spk, "D9_%s_NO" % up)


func _pasha(auto: int) -> void:
	if not "pasha" in _offers:
		return
	if GameState.flags.get("letter_route", "") == "fatih":
		# Fatih'e götürmeye söz verildi: teklif kapandı (seçim her konuşmada yeniden açılıyor, Merak her seferinde artıyordu)
		await _say("SPK_PASHA", "D9_P_AGAIN_FATIH")
		return
	# Mektup kimde: 6a'da kukuletalı adamdan alındıysa Tolga'da, yoksa Paşa'nın elinde ("Bu mektup...")
	var has_letter: bool = GameState.flags.get("candarli_letter", false)
	if _declined.has("pasha"):
		if not has_letter:
			pasha.hold_item(_letter_model(), false, false)
		await _say("SPK_PASHA", "D9_P_AGAIN_LETTER" if has_letter else "D9_P_AGAIN")
	else:
		# Mektup alındıysa Paşa onu bilir, ilk kez tanıtmaz (D9_P_LETTER_*). Y'de kaftan pazar tüccarından (keçi dahil
		# bütün işler bitti) ya da Kadri'den termos takasıyla gelir
		var p1 := "D9_P_1_ALT"
		if has_letter:
			p1 = "D9_P_LETTER_1"
		elif _route == "Y":
			var src: String = GameState.flags.get("kaftan_src", "merchant" if GameState.flags.get("goat_caught", false) else "kadri")
			p1 = "D9_P_1_KAFTAN" if src == "kadri" else "D9_P_1"
		await _say("SPK_PASHA", p1)
		await _t("D9_T_P_2")
		if not has_letter:
			pasha.hold_item(_letter_model(), false, false)
		await _say("SPK_PASHA", "D9_P_LETTER_3" if has_letter else "D9_P_3")
		await _t("D9_T_P_4")
		await _say("SPK_PASHA", "D9_P_5" if _route == "Y" else "D9_P_5_PLAIN")   # kaftan yalnız pazar yolunda
	var pick := 1 if GameState.autotest_variant == "fatih" else (0 if _auto_accepts("pasha") else 2)
	if auto >= 0:
		pick = auto
	var c := await hud.choose(["UI_CH9_GALATA", "UI_CH9_TO_FATIH", "UI_CH9_DECLINE"], 0.0, pick)
	if c == 0 and not await _sure():
		pasha.release_item()
		return      # "Dur, bir düşüneyim": karar yok
	if c in [0, 1] and not has_letter:
		# Paşa mektubu uzatır, Tolga alır
		await _take_from(pasha, _letter_model(), "letter")
		GameState.flags["candarli_letter"] = true
	match c:
		0:
			await _say("SPK_PASHA", "D9_P_GALATA")
			await _t("D9_T_GALATA")
			GameState.flags["letter_route"] = "galata"
			_set_outcome("9.3")
		1:
			# D4: dürüstlük. Mektup Fatih'e gider (Merak +1), yol otağ kapısına çıkar.
			await _say("SPK_PASHA", "D9_P_FATIH")
			await _t("D9_T_FATIH")
			GameState.flags["letter_route"] = "fatih"
			GameState.flags["merak"] = int(GameState.flags.get("merak", 0)) + 1
			_declined["pasha"] = true
		_:
			_declined["pasha"] = true
			if has_letter:
				# "Mektubumu geri ver": Tolga mektubu Paşa'nın eline verir; artık Paşa'da ("Mektup hâlâ bende")
				player.hand_gesture("show")
				await _pass_to(pasha, _letter_model())
				GameState.flags["candarli_letter"] = false
				await _say("SPK_PASHA", "D9_P_NO_LETTER")
			else:
				await _say("SPK_PASHA", "D9_P_NO")
			pasha.release_item()


func _theodoros(auto: int) -> void:
	if not "theodoros" in _offers:
		# Labirent başarısız: başvurusu açık, teklif yok
		await _say("SPK_THEODOROS", "D9_THEO_OPEN")
		await _t("D9_T_THEO_OPEN")
		return
	if _declined.has("theodoros"):
		await _say("SPK_THEODOROS", "D9_THEO_AGAIN")
	else:
		await _say("SPK_THEODOROS", "D9_THEO_1")
		await _t("D9_T_THEO_2")
		await _say("SPK_THEODOROS", "D9_THEO_3")
		await _t("D9_T_THEO_4")
		await _say("SPK_THEODOROS", "D9_THEO_5")
	var pick := 0 if _auto_accepts("theodoros") else 1
	if auto >= 0:
		pick = auto
	var c := await hud.choose(["UI_CH9_ACCEPT_THEODOROS", "UI_CH9_DECLINE"], 0.0, pick)
	if c == 0 and not await _sure():
		return
	if c == 0:
		await _say("SPK_THEODOROS", "D9_THEO_YES")
		player.hand_gesture("write")      # arşiv kaydına Tolga da imza atar
		Audio.sfx("paper_tear", -16.0, 1.4)
		await _wait(0.8)
		await _t("D9_T_THEO_YES")
		_set_outcome("9.5")
	else:
		_declined["theodoros"] = true
		await _say("SPK_THEODOROS", "D9_THEO_NO")


## Bir teklifi kabul etmek hikâyeyi başka bir dala sokar: oyuncu bilerek seçsin.
func _sure() -> bool:
	return await hud.choose(["UI_CH9_BRANCH_SURE", "UI_CH9_BRANCH_BACK"], 0.0, 0) == 0


## Otağ kapısı: teklifleri reddedip huzura çıkmayı beklemek (9.6).
func _gate(auto: int) -> void:
	if _gate_seen:
		await _say("SPK_HASAN", "D9_G_AGAIN")      # ikinci gelişte tanışma baştan oynamaz
	else:
		_gate_seen = true
		await _say("SPK_HASAN", "D9_G_1")
		await _say("SPK_HUSEYIN", "D9_G_2")
	await _cube_back()
	await _thermos_back()
	var open := 0
	for o in _offers:
		if not _declined.has(o):
			open += 1
	if open > 0:
		await _t("D9_T_GATE_OPEN")
	var pick := 0 if auto < 0 else auto
	if GameState.autotest and not GameState.autotest_variant in ["none", "fatih", "cell", "next"]:
		pick = 1
	var c := await hud.choose(["UI_CH9_WAIT_GATE", "UI_CH9_NOT_YET"], 0.0, pick)
	if c != 0:
		await _say("SPK_HUSEYIN", "D9_G_LATER")
		return
	for o in _offers:
		_declined[o] = true
	await _say("SPK_HASAN", "D9_G_WAIT")
	await _t("D9_T_GATE_" + ("LETTER" if GameState.flags.get("letter_route", "") == "fatih" else ("BYZ" if _byz else "WAIT")))
	_set_outcome("9.6")


## Küp Bölüm 4a'da Hüseyin'de kaldıysa (çözmeye çalışıyordu): kapıda, bir yüzü çözülmüş olarak geri verir.
## Çanta doluysa Hüseyin'de kalır. Küp geri gelmezse Bölüm 10B'de açı hesabı ve 12'de Sultan'ın tamiri küpsüz.
func _cube_back() -> void:
	if GameState.given_to("cube") != "guards":
		return
	huseyin.rig.hold_item(_item_model("cube"), false, false)       # küp Hüseyin'in elinde, "Al, kutun"
	await _say("SPK_HUSEYIN", "D9_HU_CUBE_BACK")
	await _say("SPK_HASAN", "D9_HA_CUBE_BACK")
	if GameState.gain("cube", "cube_back_9"):
		GameState.flags["cube_one_face"] = true
		await _take_from(huseyin, _item_model("cube"), "cube")
		await _t("D9_T_CUBE_BACK")
	else:
		await _t("D9_T_CUBE_KEEP")
		huseyin.rig.release_item()


## 4a'da çay molası verdiren termos ikizlerde kaldı (7'de "Bize termos vermedi" derken arkalarında parlıyordu): kapıda
## bir bardağı bırakıp geri verirler. Çanta doluysa onlarda kalır.
func _thermos_back() -> void:
	if GameState.given_to("thermos") != "guards":
		return
	hasan.rig.hold_item(_item_model("thermos"), false, false)          # "Al, sihirli testin"
	await _say("SPK_HASAN", "D9_HA_THERMOS_BACK")
	await _say("SPK_HUSEYIN", "D9_HU_THERMOS_BACK")
	if GameState.bag.size() < GameState.BAG_MAX:
		var c: Dictionary = GameState.flags.get("charges", {})
		c["thermos"] = 1
		GameState.flags["charges"] = c
	if GameState.gain("thermos", "thermos_back_9"):
		await _take_from(hasan, _item_model("thermos"), "thermos")
		await _t("D9_T_THERMOS_BACK")
	else:
		await _t("D9_T_THERMOS_KEEP")
		hasan.rig.release_item()


func _hikmet() -> void:
	if GameState.flags.get("ch9_met_hikmet", false):
		await _say("SPK_HIKMET", "D9_H2_AGAIN")
		return
	GameState.flags["ch9_met_hikmet"] = true
	await _t("D9_T_H2_1")
	await _say("SPK_HIKMET", "D9_H2_2")
	await _t("D9_T_H2_3")
	await _say("SPK_HIKMET", "D9_H2_4")
	# Babadan kalma çifte (Bölüm 8'de duvardan indirdi)
	await _t("D9_T_H2_GUN")
	await _say("SPK_HIKMET", "D9_H2_GUN")
	await _t("D9_T_H2_GUN2")
	await _say("SPK_HIKMET", "D9_H2_GUN2")
	await _t("D9_T_H2_5")
	await _say("SPK_HIKMET", "D9_H2_6")


## Otomatik test: konuşulacak kişinin önünde, onu açıkça gören (arada duvar ya da görünür ağ olmayan) bir nokta.
## Oyuncunun geldiği yönden başlar, bulamazsa 30'ar derece döner.
func _approach_point(node: Node3D, dir: Vector3) -> Vector3:
	var space := get_world_3d().direct_space_state
	var head := node.global_position + Vector3(0, 1.5, 0)
	for k in 12:
		var a := floorf((k + 1) / 2.0) * deg_to_rad(30.0) * (1.0 if k % 2 == 0 else -1.0)
		var p := node.global_position + dir.rotated(Vector3.UP, a) * 2.4
		var eye := p + Vector3(0, 1.6, 0)
		# Başka bir kişinin dibinde durulmaz (Paşa'nın yanındaki kukuletalı adamın koyu cüppesi kadrajın yarısını örtüyordu)
		var crowded := false
		for o: Node3D in [day.candarli, day.kadri, day.lutfi, day.urban, pasha, theodoros, hasan, huseyin, miner, hikmet_npc]:
			if o and o != node and is_instance_valid(o) and Vector2(o.global_position.x - p.x, o.global_position.z - p.z).length() < 1.3:
				crowded = true
		if crowded:
			continue
		var q := PhysicsRayQueryParameters3D.create(eye, head)
		q.exclude = [player.get_rid()]
		var h := space.intersect_ray(q)
		if not h.is_empty() and not node.is_ancestor_of(h["collider"]) and h["collider"] != node \
				and not String((h["collider"] as Node).name).begins_with("Interact_"):
			continue
		var down := space.intersect_ray(PhysicsRayQueryParameters3D.create(eye, p + Vector3(0, -1.0, 0)))
		if down.is_empty() or absf((down["position"] as Vector3).y - node.global_position.y) > 0.4:
			continue
		if hud._mesh_between(self, player, node, eye, head) != null:
			continue
		return (down["position"] as Vector3) + Vector3(0, 0.1, 0)
	return node.global_position + dir * 2.4 + Vector3(0, 0.1, 0)


func _auto_accepts(npc: String) -> bool:
	if not GameState.autotest:
		return false
	return GameState.autotest_variant not in ["none", "fatih", "cell", "next"] and npc == _auto_target()


func _auto_target() -> String:
	match GameState.autotest_variant:
		"b": return "lutfi"
		"c": return "urban"
		"y": return "pasha"
		"arch": return "theodoros"
		"lagim": return "miner"
	return "kadri"


func _npc_node(npc: String) -> Node3D:
	match npc:
		"kadri": return day.kadri
		"lutfi": return day.lutfi
		"urban": return day.urban
		"candarli": return day.candarli
		"pasha": return pasha
		"theodoros": return theodoros
		"guards": return hasan
		"hikmet": return hikmet_npc
		"miner": return miner
	return null


# ---------------------------------------------------------------- otomatik test

func _auto() -> void:
	var v := GameState.autotest_variant
	if v == "hikmet":
		await _talk("hikmet")
	match v:
		"none", "next":
			for o in _offers:
				await _talk(o)
			await _talk("guards", 0)
		"fatih":
			await _talk("pasha")
			await _talk("kadri")
			await _talk("guards", 0)
		"cell":
			await _talk("theodoros")
			await _talk("guards", 0)
		_:
			var target := _auto_target()
			await _talk("guards", 1)
			await _talk(target)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	GameState.set_outcome(9, _outcome)
	await _farewell()
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var can_go := NEXT_SCENE.has(_outcome)
	var result := await hud.show_flowchart(chart, can_go)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=9 -> 10 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file(NEXT_SCENE.get(_outcome, "res://scenes/chapter10.tscn"))
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file(NEXT_SCENE.get(_outcome, "res://scenes/chapter10.tscn"))
		"replay":
			GameState.replay_scene()
		_:
			get_tree().quit()


## Bölümün son kartı: hangi dala gidildiği.
func _farewell() -> void:
	await hud.fade_to(1.0, 0.6)
	var key := "UI_CH9_END_" + _outcome.replace(".", "_")
	await hud.card([[tr(key), 30, Color("f2e6c9")], [tr(key + "_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW9_TITLE")
	c.nodes = [
		{"id": "morning", "key": "FLOW9_MORNING", "pos": Vector2(0.5, 0.14)},
		{"id": "9.1", "key": "FLOW_9_1", "pos": Vector2(0.1, 0.36), "outcome": true},
		{"id": "9.2", "key": "FLOW_9_2", "pos": Vector2(0.26, 0.5), "outcome": true},
		{"id": "9.3", "key": "FLOW_9_3", "pos": Vector2(0.42, 0.36), "outcome": true},
		{"id": "9.4", "key": "FLOW_9_4", "pos": Vector2(0.58, 0.5), "outcome": true},
		{"id": "9.5", "key": "FLOW_9_5", "pos": Vector2(0.74, 0.36), "outcome": true},
		{"id": "9.6", "key": "FLOW_9_6", "pos": Vector2(0.9, 0.5), "outcome": true},
		{"id": "9.7", "key": "FLOW_9_7", "pos": Vector2(0.1, 0.68), "outcome": true},
		{"id": "fatih", "key": "FLOW9_LETTER_FATIH", "pos": Vector2(0.9, 0.68)},
	]
	c.edges = [["morning", "9.1"], ["morning", "9.2"], ["morning", "9.3"], ["morning", "9.4"], ["morning", "9.5"],
		["morning", "9.6"], ["9.6", "fatih"], ["morning", "9.7"]]
	c.taken["morning"] = true
	c.taken[_outcome] = true
	if GameState.flags.get("letter_route", "") == "fatih" and _outcome == "9.6":
		c.taken["fatih"] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH9_STATS") % [GameState.telsiz_bag, GameState.paradox, int(GameState.flags.get("merak", 0))],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW9_NEXT_" + _outcome.replace(".", "_")) if NEXT_SCENE.has(_outcome) else tr("UI_FLOW9_NEXT_SOON"),
		GameState.tr_pad("UI_FLOW_CONTINUE") if NEXT_SCENE.has(_outcome) else tr("UI_FLOW2_REPLAY"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase == "free" and SPEAKERS.has(id):
		p = tr("UI_PROMPT3_TALK") % tr(SPEAKERS[id] if id != "guards" else "UI_CH7_GUARDS")
	elif not _busy and phase == "free" and id in ["goat", "cannon", "letter"]:
		p = tr("UI_PROMPT3_LOOK")     # keçi, top, mektup askeri: E ile bakılır (istem yoktu)
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy or phase != "free":
		return
	if SPEAKERS.has(id):
		_talk(id)
	elif id == "goat":
		# "Poliçesi": keçiyi 6a'da pazarda kendisi yakaladıysa (goat_caught). 6a.4 yetmez: kaftan termos takasıyla da gelir
		if GameState.flags.get("goat_caught", false):
			day.goat.look_at(Vector3(player.global_position.x, day.goat.global_position.y, player.global_position.z), Vector3.UP, true)
		hud.bark("SPK_TOLGA", "D9_T_GOAT" if GameState.flags.get("goat_caught", false) else "D9_T_GOAT_PLAIN", 2.5)
	elif id == "cannon":
		hud.bark("SPK_TOLGA", "D6A_T_CANNON", 3.5)
	elif id == "letter":
		hud.bark("SPK_SOLDIER", GameState.letter_reply_key(), 3.5)
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


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


func _wait(s: float) -> void:
	if _instant():      # PACE çekiminde beklemeler gerçek
		await get_tree().process_frame
		return
	await get_tree().create_timer(s, false).timeout      # duraklatmada beklemez


## Teklif kabul edilir. Fatih'e mektup sözü verilmişken başka bir teklif kabul edilirse söz düşer (mektup Fatih'e
## gitmez: Merak geri alınır, akış şeması Fatih'i işaretlemez; Bölüm 10/12 letter_route'a bakar).
func _set_outcome(o: String) -> void:
	if o != "9.6" and GameState.flags.get("letter_route", "") == "fatih":
		GameState.flags["letter_route"] = ""
		GameState.flags["merak"] = maxi(0, int(GameState.flags.get("merak", 0)) - 1)
	_outcome = o


## Denemede Tolga'nın hareketi: Urban'a telefonla hesap, Dragan için toprağa kulak, Lütfi'ye selamla eğilme.
func _trial_action(npc: String, t: int) -> void:
	match npc:
		"urban":
			player.show_prop("phone", 2.2)
			if t < 2:
				Audio.sfx("ui_select", -14.0, 1.3)      # tuşlara basılır; üçüncüde telefon kapanır (ses yok)
			await _wait(0.9)
		"miner":
			player.duck(0.75, 1.8)          # çömelip kulağını toprağa verir
			player.hand_gesture("ear")
			await _wait(1.2)
		"lutfi":
			player.duck(0.25, 0.9)          # selamla birlikte hafif eğilme
			await _wait(0.6)
		"kadri":
			player.hand_gesture("show")     # menüyü parmakla sayar gibi
			await _wait(0.4)


## Kabulde elden ele: Kadri önlüğü uzatır ("Önlüğü giy").
func _accept_action(npc: String) -> void:
	if npc == "kadri":
		await _take_from(day.kadri, _apron_model(), "apron")


func _apron_model() -> Node3D:
	var n := Node3D.new()
	Props.box(n, Vector3(0.28, 0.06, 0.2), Vector3.ZERO, Color("f3efe4"))
	Props.box(n, Vector3(0.3, 0.012, 0.02), Vector3(0, 0.035, -0.06), Color("c9bfa8"))
	Props.strip_outlines(n)
	return n


func _instant() -> bool:
	return GameState.autotest and not GameState.pace


## Karşıdaki bir eşyayı uzatır, Tolga alır: önce onun elinde görünür, Tolga'ya doğru gelir, sonra Tolga'nın elinde
## (Bölüm 6'daki gibi; Person ve muhafız askerler).
func _take_from(node: Node3D, model: Node3D, kind: String) -> void:
	var rg: Rig = null
	if node is Person:
		rg = (node as Person).rig
	elif node is Soldier:
		rg = (node as Soldier).rig
	if rg and not _instant():
		rg.hold_item(model, false, false)
		await _wait(0.9)
		var gt := model.global_transform
		model.get_parent().remove_child(model)
		add_child(model)
		model.global_transform = gt
		rg.release_item()
		var tw := create_tween()
		tw.tween_property(model, "global_position", player.camera.global_transform * Vector3(0.0, -0.25, -0.8), 0.4).set_trans(Tween.TRANS_SINE)
		await tw.finished
	elif rg:
		rg.release_item()
	model.queue_free()
	Audio.sfx("paper_tear" if kind == "letter" else "cloth", -12.0, 1.3)
	player.show_prop(kind, 1.8)
	await _wait(1.2)


## Model Tolga'nın önünden karşıdakinin eline geçer.
func _pass_to(node: Node3D, model: Node3D) -> void:
	var from := player.camera.global_transform * Vector3(0.05, -0.2, -0.6)
	if node is Person:
		await (node as Person).receive_item(model, from)
	else:
		model.queue_free()


func _item_model(id: String) -> Node3D:
	var m := Items.build(id)
	m.scale = Vector3.ONE * 0.6
	return m


## Mektup: mühürlü katlanmış kâğıt (Paşa'nın elinde, sonra Tolga'nın).
func _letter_model() -> Node3D:
	var n := Node3D.new()
	Props.box(n, Vector3(0.22, 0.14, 0.006), Vector3.ZERO, Color("efe2c4"))
	Props.cyl(n, 0.022, 0.008, Vector3(0, -0.01, 0.005), Color("a8182a"), Vector3(90, 0, 0), 12)
	Props.strip_outlines(n)
	return n


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var expected: String = {"next": "9.6", "": "9.1", "b": "9.4", "c": "9.2", "y": "9.3", "arch": "9.5", "none": "9.6",
		"fatih": "9.6", "cell": "9.6", "hikmet": "9.1", "lagim": "9.7", "cube": "9.1", "gifts": "9.1"}[GameState.autotest_variant]
	var ok := _outcome == expected
	match GameState.autotest_variant:
		"fatih":
			ok = ok and GameState.flags.get("letter_route", "") == "fatih" and int(GameState.flags.get("merak", 0)) >= 1
		"hikmet":
			ok = ok and GameState.flags.get("ch9_met_hikmet", false)
		"cube":
			# Küp kapıda Hüseyin'den geri geldi (bir yüzü çözülmüş)
			ok = ok and "cube" in GameState.bag and GameState.given_to("cube") == "" and GameState.flags.get("cube_one_face", false)
		"gifts":
			# Küp ve termos (bir bardağı kalmış) kapıda geri geldi
			ok = ok and "cube" in GameState.bag and "thermos" in GameState.bag and GameState.charge("thermos") == 1 \
				and GameState.given_to("thermos") == ""
	if GameState.chapter_outcomes.get(9, "") != _outcome:
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=9 variant=%s route=%s byz=%s offers=%s outcome=%s telsiz=%d merak=%d" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, _route, str(_byz), str(_offers), _outcome,
		GameState.telsiz_bag, int(GameState.flags.get("merak", 0))])
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
	if _byz:
		player.global_position = THEO_POS + Vector3(1.2, 0.05, -2.6)
		player.face(theodoros.global_position + Vector3(0, 1.4, 0))
		theodoros.talking = true
		hud.bark("SPK_THEODOROS", "D9_THEO_1", 30.0)
		await get_tree().create_timer(0.4).timeout
		await _shot("c9_04_theodoros.png")
		get_tree().quit()
		return
	player.global_position = CampDay.KADRI_FRONT + Vector3(1.6, 0.05, 2.6)
	player.face(day.kadri.global_position + Vector3(0, 1.3, 0))
	day.kadri.talking = true
	hud.bark("SPK_KADRI", "D9_KADRI_OFFER_1", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c9_01_kadri.png")
	day.kadri.talking = false
	if pasha:
		player.global_position = PASHA_POS + Vector3(-1.4, 0.05, -2.4)
		player.face(pasha.global_position + Vector3(0, 1.4, 0))
		pasha.talking = true
		hud.bark("SPK_PASHA", "D9_P_3", 30.0)
		await get_tree().create_timer(0.4).timeout
		await _shot("c9_02_candarli.png")
	if hikmet_npc:
		day.goat.chase = null
		day.goat.set_process(false)
		day.goat.position = HIKMET_POS + Vector3(1.0, 0, 0.6)
		player.global_position = HIKMET_POS + Vector3(1.6, 0.05, -2.8)
		player.face(hikmet_npc.global_position + Vector3(0, 1.3, 0))
		hud.bark("SPK_HIKMET", "D9_H2_2", 30.0)
		await get_tree().create_timer(0.4).timeout
		await _shot("c9_03_hikmet.png")
	var gy := _ground_y(GATE_POS.z)
	player.global_position = GATE_POS + Vector3(0.3, gy + 0.05, 4.5)
	player.face(GATE_POS + Vector3(0, gy + 2.2, -6.0))
	hud.bark("SPK_HUSEYIN", "D9_G_2", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c9_05_otag.png")
	get_tree().quit()
