extends Node3D
## Bölüm 6 — Ordugâh / Surların İçi (Tolga · 23 Nisan 1453). CHAPTERS Bölüm 6a/6b, GDD §9.3–9.4.
##
## 6a · Ordugâh (Bölüm 4a'dan): otağa dört yol.
##   A · Mutfak: Kadri'ye leblebi (ya da çakmak), fesi çıkar, aşçı yamağı ol (6a.1)
##   B · Tercüman: Lütfi'ye tarih kitabı / termos / kolonya, fesle "Frenk elçisi" (6a.2)
##   C · Topçu: Urban'a telefonun "cin"i / çakmak / küp; koli bandı topu bantlar (6a.3)
##   Y · Pazar: keçiyi yakala, yüzüğü bul, mektubu yaz → kaftan (6a.4)
##   Ek: Çandarlı'nın adamının gizli mektubu (6a.5)
## 6b · Surların İçi (Bölüm 4b'den): Theodoros'tan tek mühürlü Misafir İzni (Aziz Yorgi yortusu), kapıda bir
##   martı izni kapar: meydan, pazar, çamaşır ipi, tabela, sur yolu boyunca kovalamaca (leblebi atılırsa martı
##   iner). Sonra Giustiniani (⏱ uyar ya da uyarma), İmparator Konstantinos, mühürlü mektup (aç / açma).
##   6b.1 martı hiç kaçırılmadan · 6b.2 kaçırmalarla yakalandı · 6b.3 üç kaçırma, izin surların ardında, zindan
##   · ekler 6b.4–6b.6
##   --autotest[=b|c|y|letter|byz|byzmistake|byzfail]   (varsayılan: 6a.1)

## 6b serbest tırmanma: çatıda kalınacak alan (cadde boyunca iki ev sırası), çatı sırtındaki seyir noktaları
## ([sırt noktası, bakış, replik]) ve çatılara saklanan iki Tarih Defteri sayfası
const ROOF_BOUNDS := [Rect2(-10.5, -14.5, 21.0, 28.5)]
const VISTAS := [
	[Vector3(-6.65, 8.8, 3.0), Vector3(-14.0, 40.0, -82.0), "D6B_T_VISTA_2"],
	[Vector3(6.65, 8.0, -4.0), Vector3(90.0, 6.0, -14.0), "D6B_T_VISTA_3"],
	[Vector3(-6.65, 9.2, -11.0), Vector3(-60.0, 2.0, 80.0), "D6B_T_VISTA_1"],
]
const ROOF_PAGES := [Vector3(6.2, 7.6, 10.0), Vector3(-6.2, 8.6, -4.0)]
const MAX_MISTAKES := 3     # martıyı üç kez kaçıran izni kaybeder
## Martının tünekleri (ayak hizası): meydan çeşmesinin tepesi, batı pazar tentesi, caddenin çamaşır ipi, "surlar"
## tabelası, sur yolundaki su fıçısı, Giustiniani'nin sözleşme masası. Her tünekte sabır süresi (sn).
const PERCHES := [Vector3(0, 2.9, -16.0), Vector3(-4.8, 2.5, -15.2), Vector3(0.9, 5.25, 1.0), Vector3(8.5, 2.14, -18.5),
	Vector3(16.5, 1.27, -11.0), Vector3(24.6, 0.84, -12.4)]
const PATIENCE := [16.0, 14.0, 16.0, 14.0, 14.0, 0.0]
const REACH := 3.2
const NPC_KEYS := {"kadri": "KADRI", "lutfi": "LUTFI", "urban": "URBAN", "niko": "NIKO",
	"giustiniani": "GIUST", "emperor": "EMP"}
const SPEAKERS := {"kadri": "SPK_KADRI", "lutfi": "SPK_LUTFI", "urban": "SPK_URBAN", "niko": "SPK_NIKO",
	"giustiniani": "SPK_GIUST", "emperor": "SPK_EMPEROR", "clerk": "SPK_CLERK", "candarli": "SPK_CANDARLI"}
const ITEM_KEY := {"phone": "PHONE", "lighter": "LIGHTER", "book": "BOOK", "chickpeas": "CHICKPEAS",
	"powerbank": "POWERBANK", "tape": "TAPE", "thermos": "THERMOS", "selfie": "SELFIE", "cologne": "COLOGNE", "cube": "CUBE"}

var day: CampDay
var city: ByzCity
var player: Player
var hud: Hud
var branch := "6a"
var phase := "intro"
var _outcome := ""
var _busy := false
var _met: Dictionary = {}
var _open: Dictionary = {}          # açılan yollar: "A", "B", "C"
var _favors: Dictionary = {}        # goat, ring, letter
var _mistakes := 0
var _permit := false
var _giust_done := false
var _emperor_done := false
var sinerji: Chicken
var gull: ThiefGull
var _got_permit := false     # Theodoros mühürledi (martı henüz kapmadı)
var _chase := false
var _lured := false
var _chase_left := 0.0


func _ready() -> void:
	GameState.snapshot(6)
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
	var ch4: String = GameState.chapter_outcomes.get(4, "4a.1")
	if GameState.autotest_variant.begins_with("byz"):
		ch4 = "4b.1"
	branch = "6b" if ch4.begins_with("4b") else "6a"
	if branch == "6a":
		day = CampDay.new()
		add_child(day)
		day.goat.chase = player
	else:
		city = ByzCity.new()
		add_child(city)
		set_meta("ambience", "amb_city_day")     # şehir: uzak kalabalık ve kuşlar (ordugâhın at ve bağrışı değil)
		city.niko.look_target = player
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _process(_delta: float) -> void:
	if hud == null:
		return
	if branch == "6b":
		_process_roof()
	hud.fez.motion = player.horizontal_speed() * 0.6
	if phase == "free" and not _busy and Input.is_action_just_pressed("fez"):
		var on: bool = not GameState.flags.get("fez", true)
		GameState.flags["fez"] = on
		hud.set_fez(on)
		_update_objective()
	# Mühürlü izinle kançılaryadan çıkınca martı kapar
	if branch == "6b" and _got_permit and not _chase and not _permit and not _busy and _outcome == "" \
			and player.global_position.z > ByzCity.HALL_Z0 + 0.6:
		_gull_chase()


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	var title := "UI_CH6A_TITLE" if branch == "6a" else "UI_CH6B_TITLE"
	var sub := "UI_CH6A_SUB" if branch == "6a" else "UI_CH6B_SUB"
	hud.cover_override = "ch6a" if branch == "6a" else "ch6b"
	if branch != "6a":
		Audio.music("byzantium")
	await hud.card([[tr(title), 44, Color("f2e6c9")], [tr(sub), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	if branch == "6a":
		await _run_6a()
	else:
		await _run_6b()
	await _end_chapter()


# ---------------------------------------------------------------- 6a · ordugâh

func _run_6a() -> void:
	var kitchen: bool = GameState.chapter_outcomes.get(4, "") == "4a.3"
	player.global_position = CampDay.KITCHEN_SPAWN if kitchen else CampDay.SPAWN
	player.face(day.kadri.global_position + Vector3(0, 1.4, 0) if kitchen else Vector3(0, 3.0, CampDay.OTAG_POS.z))
	day.kadri.look_target = player
	day.lutfi.look_target = player
	day.urban.look_target = player
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	if kitchen:
		# Bulaşıktan gelenler Kadri'yi zaten tanır: mutfak yolu açık
		_open["A"] = true
		_met["kadri"] = true
		await _say("SPK_KADRI", "D6A_KADRI_KITCHEN")
	await _t("D6A_T_01")
	await _radio_call()
	phase = "free"
	Lore.scatter(self, branch)
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		await _auto_6a()
	while _outcome == "":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame


## Hikmet'in telsiz çağrısı (Bölüm 5'te frekans bulunduysa). ⏱ cevap ver / verme.
func _radio_call() -> void:
	if GameState.chapter_outcomes.get(5, "5.1") == "5.4":
		await _t("D6_T_RADIO_DEAD")
		return
	await _h("D6_H_CALL")
	var c := await hud.choose(["UI_CH6_ANSWER", "UI_CH6_IGNORE"], 5.0, 0)
	if c == 0:
		GameState.telsiz_bag = mini(5, GameState.telsiz_bag + 1)
		await _t("D6_T_ANSWER")
		await _h("D6_H_ANSWER")
	else:
		GameState.telsiz_bag = maxi(0, GameState.telsiz_bag - 1)
		await _h("D6_H_NO_ANSWER")
	hud.set_signal(GameState.telsiz_bag)


## 6a: yolu henüz açılmamış en yakın kapı (A Kadri, B Lütfi, C Urban)
func _route_spot() -> Callable:
	return func():
		var best: Node3D = null
		var bd := INF
		for pair in [["A", "kadri"], ["B", "lutfi"], ["C", "urban"]]:
			if _open.has(pair[0]):
				continue
			var n := _npc_node(pair[1])
			if n and is_instance_valid(n):
				var d := player.global_position.distance_to(n.global_position)
				if d < bd:
					bd = d
					best = n
		return best


func _update_objective() -> void:
	if branch == "6a":
		var parts: Array = []
		for r in ["A", "B", "C"]:
			parts.append(r + (" ✓" if _open.has(r) else ""))
		parts.append("Y %d/3" % _favors.size())
		hud.set_objective(tr("UI_OBJ6A") % "  ·  ".join(parts), _route_spot())
		return
	if not _permit and not _met.has("niko"):
		# İlk iş: Niko. Hedef ve işaret olmadan oyuncu şehirde ne yapacağını bilmiyordu.
		hud.set_objective(tr("UI_OBJ6B_NIKO"), _npc_node("niko"))
		return
	if _chase:
		var t := tr("UI_OBJ6B_CHASE") % [_mistakes, MAX_MISTAKES]
		if _chase_left > 0.0:
			t += "  ·  ⏱ %d" % ceili(_chase_left)
		if "chickpeas" in GameState.bag and not _lured:
			t += "\n" + tr("UI_OBJ6B_LURE")
		hud.set_objective(t, gull)
		return
	if not _permit and not _got_permit:
		hud.set_objective(tr("UI_OBJ6B_THEO"), city.clerks[6])
	elif not _permit:
		# Mühürlü izin elde: kapıdan çık (martı kapıda bekliyor)
		hud.set_objective(tr("UI_OBJ6B_OUT"), Vector3(0, 1.4, ByzCity.HALL_Z0 + 1.0))
	elif not _giust_done:
		hud.set_objective(tr("UI_OBJ6B_GIUST"), _npc_node("giustiniani"))
	elif not _emperor_done:
		hud.set_objective(tr("UI_OBJ6B_EMPEROR"), _npc_node("emperor"))
	else:
		hud.set_objective(tr("UI_OBJ6B_EXIT"), hud.spot("exit"), 0.2)


## Bir karakterle konuş: eşya göster, yol sor ya da vazgeç. Otomatik testte seçim verilir.
func _talk(npc: String, auto_pick := -1) -> void:
	if _busy:
		return
	_busy = true
	player.frozen = true
	var node := _npc_node(npc)
	if node:
		player.face(node.global_position + Vector3(0, 1.45, 0))
	var spk: String = SPEAKERS[npc]
	var key: String = NPC_KEYS[npc]
	if not _met.has(npc):
		_met[npc] = true
		GameState.meet(npc)
		await _say(spk, "D6_%s_HELLO" % key)
	# Açık yolu tamamlama kontrolü (fes şartı)
	if await _try_complete(npc):
		_busy = false
		return
	var keys: Array = []
	for id in GameState.bag:
		keys.append(Items.name_key(id))
	keys.append("UI_CH6_ASK")
	keys.append("UI_CH4_NOTHING")
	var c := await hud.choose(keys, 0.0, auto_pick if auto_pick >= 0 else keys.size() - 1)
	if c >= 0 and c < GameState.bag.size():
		await _give(npc, GameState.bag[c])
	elif c == GameState.bag.size():
		await _say(spk, "D6_%s_ASK" % key)
	await _try_complete(npc)
	_update_objective()
	Lore.scatter(self, branch)
	player.frozen = false
	_busy = false


func _npc_node(npc: String) -> Node3D:
	if day:
		match npc:
			"kadri": return day.kadri
			"lutfi": return day.lutfi
			"urban": return day.urban
			"candarli": return day.candarli
	if city:
		match npc:
			"niko": return city.niko
			"giustiniani": return city.giustiniani
			"emperor": return city.emperor
	return null


## Eldeki eşyayı doğrudan bir karaktere göstermek (sağ tık): menüdeki "göster" ile aynı etki.
func _on_item_used(target: String, item: String) -> bool:
	if not SPEAKERS.has(target) or not NPC_KEYS.has(target) or _busy or phase != "free":
		return false
	_busy = true
	player.frozen = true
	var node := _npc_node(target)
	if node:
		player.face(node.global_position + Vector3(0, 1.45, 0))
	await _give(target, item)
	await _try_complete(target)
	_update_objective()
	Lore.scatter(self, branch)
	player.frozen = false
	_busy = false
	return true


## Eşya göster: tepki ve etkisi.
func _give(npc: String, item: String) -> void:
	var shown: Dictionary = GameState.flags.get("shown", {})
	if not shown.has(npc):
		shown[npc] = []
	if not item in shown[npc]:
		shown[npc].append(item)
	GameState.flags["shown"] = shown
	var spk: String = SPEAKERS[npc]
	var key := "D6_%s_%s" % [NPC_KEYS[npc], ITEM_KEY[item]]
	if npc == "niko":
		key = "D4B_NIKO_" + ITEM_KEY[item]
	if tr(key) == key:
		key = "REACT_GENERIC"      # tepkisi yazılmamış eşya: ham anahtar ekrana çıkmasın
	await _say(spk, key)
	var tk := key + "_T"
	if tr(tk) != tk:
		await _t(tk)
	var tk2 := key + "_2"
	if tr(tk2) != tk2:
		await _say(spk, tk2)
	match npc:
		"kadri":
			if item == "chickpeas":
				_open["A"] = true
				GameState.flags["leblebi_given"] = true
				GameState.paradox += 10
			elif item == "lighter":
				_open["A"] = true
			elif item == "thermos":
				GameState.flags["has_kaftan"] = true
				await _complete("Y")
		"lutfi":
			if item in ["book", "thermos", "cologne"]:
				_open["B"] = true
				if item == "book":
					GameState.paradox += 5
		"urban":
			if item in ["phone", "lighter", "cube", "tape"]:
				_open["C"] = true
			if item == "phone":
				GameState.paradox += 5
			if item == "tape":
				GameState.flags["cannon_taped"] = true
				GameState.paradox += 20
				_tape_cannon()
			if item == "cube":
				GameState.flags["urban_friend"] = true
		"niko":
			if item == "chickpeas":
				GameState.flags["niko_friend"] = true
		"giustiniani", "emperor":
			if npc == "emperor" and item == "chickpeas":
				GameState.flags["niko_friend"] = true
				GameState.paradox += 5


func _tape_cannon() -> void:
	var crack := day.cannon.get_node_or_null("Crack")
	if crack:
		Props.box(day.cannon, Vector3(0.1, 0.6, 1.1), Vector3(0.92, 1.6, -0.6), Garage.C_TAPE, Vector3(0, 0, 25))


## Açık bir yolu tamamla. Fes şartı: mutfak fessiz, tercüman fesli.
func _try_complete(npc: String) -> bool:
	var fez_on: bool = GameState.flags.get("fez", true)
	match npc:
		"kadri":
			if _open.has("A"):
				if fez_on:
					await _say("SPK_KADRI", "D6_KADRI_FEZ_OFF")
					return false
				await _say("SPK_KADRI", "D6_KADRI_DONE" if GameState.flags.get("leblebi_given", false) else "D6_KADRI_DONE_FIRE")
				await _complete("A")
				return true
		"lutfi":
			if _open.has("B"):
				if not fez_on:
					await _say("SPK_LUTFI", "D6_LUTFI_FEZ_ON")
					return false
				await _say("SPK_LUTFI", "D6_LUTFI_DONE")
				await _complete("B")
				return true
		"urban":
			if _open.has("C"):
				await _say("SPK_URBAN", "D6_URBAN_DONE")
				await _complete("C")
				return true
	return false


func _favor(id: String) -> void:
	if _busy or _favors.has(id) or _outcome != "":
		return
	_busy = true
	player.frozen = true
	match id:
		"goat":
			day.goat.caught = true
			GameState.flags["goat_caught"] = true
			await _t("D6A_T_GOAT")
			day.goat.visible = false
		"ring":
			day.ring_node.visible = false
			await _t("D6A_T_RING")
		"letter":
			player.face(day.letter_soldier.global_position + Vector3(0, 1.5, 0))
			await _say("SPK_SOLDIER", "D6A_S_LETTER")
			var c := await hud.choose(["UI_CH6A_LETTER_1", "UI_CH6A_LETTER_2", "UI_CH6A_LETTER_3"], 0.0, 0)
			await _say("SPK_SOLDIER", "D6A_S_LETTER_R%d" % (clampi(c, 0, 2) + 1))
			# Annenin cevabı (Bölüm 7, 9) Tolga'nın yazdığına göre gelir
			GameState.flags["letter_written"] = true
			GameState.flags["letter_choice"] = clampi(c, 0, 2)
	_favors[id] = true
	_update_objective()
	if _favors.size() >= 3:
		await _t("D6A_T_KAFTAN")
		GameState.flags["has_kaftan"] = true
		await _complete("Y")
	Lore.scatter(self, branch)
	player.frozen = false
	_busy = false


func _candarli() -> void:
	if _busy or GameState.flags.has("candarli_met"):
		return
	_busy = true
	player.frozen = true
	GameState.flags["candarli_met"] = true
	player.face(day.candarli.global_position + Vector3(0, 1.45, 0))
	await _say("SPK_CANDARLI", "D6A_C_01")
	await _t("D6A_T_C_02")
	await _say("SPK_CANDARLI", "D6A_C_03")
	var pick := 0 if GameState.autotest_variant == "letter" else 1
	var c := await hud.choose(["UI_CH6A_TAKE_LETTER", "UI_CH6A_REFUSE_LETTER"], 0.0, pick)
	if c == 0:
		GameState.flags["candarli_letter"] = true
		GameState.paradox += 10
		await _say("SPK_CANDARLI", "D6A_C_TAKEN")
		await _t("D6A_T_C_TAKEN")
	else:
		await _say("SPK_CANDARLI", "D6A_C_REFUSED")
	Lore.scatter(self, branch)
	player.frozen = false
	_busy = false


## Yol tamamlandı: otağ yoluna yürüyüş.
func _complete(route: String) -> void:
	if _outcome != "":
		return
	_outcome = {"A": "6a.1", "B": "6a.2", "C": "6a.3", "Y": "6a.4"}[route]
	GameState.flags["route"] = route
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	await hud.fade_to(1.0, 0.8)
	var road := Vector3(0.6, 0.05, CampDay.ROAD_Z - 4.0)
	road.y = 0.05
	player.global_position = road
	player.face(CampDay.OTAG_POS + Vector3(0, 6.0, 0))
	await hud.fade_to(0.0, 0.8)
	await _t("D6A_T_ROAD_" + route)


func _auto_6a() -> void:
	var v := GameState.autotest_variant
	var bag := GameState.bag
	match v:
		"b":
			await _talk("lutfi", bag.find("cologne"))
		"c":
			await _talk("urban", bag.find("phone"))
		"y":
			for f in ["goat", "ring", "letter"]:
				await _favor(f)
		_:
			if v == "letter":
				await _candarli()
			GameState.flags["fez"] = true
			await _talk("kadri", bag.find("chickpeas"))
			GameState.flags["fez"] = false
			hud.set_fez(false)
			await _talk("kadri")


# ---------------------------------------------------------------- 6b · surların içi

func _run_6b() -> void:
	var cell: bool = GameState.chapter_outcomes.get(4, "") == "4b.3"
	player.global_position = ByzCity.CELL_START if cell else ByzCity.START
	player.face(city.niko.global_position + Vector3(0, 1.5, 0))
	if GameState.flags.get("sinerji", false):
		sinerji = Chicken.new()
		city.add_child(sinerji)
		sinerji.global_position = player.global_position + Vector3(0.8, 0, 1.0)
		sinerji.follow = player
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	if cell:
		await _say("SPK_NIKO", "D6B_N_CELL_MORNING")
	await _t("D6B_T_01")
	await _radio_call()
	# Niko kançılaryanın önünde bekler
	phase = "free"
	# Serbest tırmanma: cadde boyunca evlerin duvarları ve çatıları (sınır: iki ev sırası)
	player.enable_climb(ROOF_BOUNDS)
	_vistas()
	Lore.scatter(self, branch, ROOF_PAGES)
	player.frozen = false
	_update_objective()
	hud.bark("SPK_NIKO", "D6B_N_CALL", 4.0)
	if GameState.autotest:
		await _auto_6b()
	while _outcome == "":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame


var vistas_seen := 0
var _roof_joke := false


func _vistas() -> void:
	for i in VISTAS.size():
		var v: Array = VISTAS[i]
		var vs := Vista.make(self, "6b", i + 1, v[0], v[1], v[2])
		vs.seen.connect(_on_vista)


func _on_vista(_id: String) -> void:
	vistas_seen += 1
	await hud.card([[tr("UI_VISTA_FOUND") % [Vista.count("6b", VISTAS.size()), VISTAS.size()], 24, Color("ffd070")]], 1.6)
	hud.clear_card()


func _process_roof() -> void:
	# İlk kez çatıya çıkınca Nihat telsizden takılır
	if not _roof_joke and phase == "free" and player.global_position.y > 5.5 and player.is_on_floor():
		_roof_joke = true
		hud.bark("SPK_NIKO", "D6B_NK_ROOF", 4.5)     # Nihat henüz 1453'te değil; aşağıdan Niko bağırır


func _niko_talk(auto_pick := -1) -> void:
	if _busy:
		return
	_busy = true
	player.frozen = true
	player.face(city.niko.global_position + Vector3(0, 1.45, 0))
	if not _met.has("niko"):
		_met["niko"] = true
		await _say("SPK_NIKO", "D6B_N_PERMIT")
		_update_objective()
	var keys: Array = ["UI_CH6B_HINT"]
	for id in GameState.bag:
		keys.append(Items.name_key(id))
	keys.append("UI_CH4_NOTHING")
	var c := await hud.choose(keys, 0.0, auto_pick if auto_pick >= 0 else keys.size() - 1)
	if c == 0:
		await _say("SPK_NIKO", "D6B_N_HINT")
	elif c >= 1 and c < 1 + GameState.bag.size():
		await _give("niko", GameState.bag[c - 1])
	_update_objective()
	Lore.scatter(self, branch)
	player.frozen = false
	_busy = false


## Memurlar: altısı bugün yalnız sayar (yortu); Theodoros (Η) tek mühürle izni verir.
func _clerk(i: int, _auto_pick := 0) -> void:
	if _busy or _permit or _got_permit or _outcome != "":
		return
	_busy = true
	player.frozen = true
	player.face(city.clerks[i].global_position + Vector3(0, 1.45, 0))
	if i != 6:
		await _say("SPK_CLERK", "D6B_C_FEAST")
	else:
		await _say("SPK_THEODOROS", "D6B_THEO_GRANT")
		await city.clerks[i].stamp()
		_got_permit = true
		await _t("D6B_T_GOT_PERMIT")
	_update_objective()
	Lore.scatter(self, branch)
	player.frozen = false
	_busy = false


# ---------------------------------------------------------------- martı kovalamacası

## Kapıda martı izni kapar; tünekten tüneğe kovalanır. Tünekte sabır süresi dolmadan yanına (REACH) varılamazsa
## kaçırma sayılır ve martı bir sonraki tüneğe geçer; üç kaçırmada surların üstünden uçar (6b.3). Leblebi atılırsa
## (yakınken) martı yere iner ve izni bırakır. Son tünek Giustiniani'nin sözleşme masası: orada yakalanır.
func _gull_chase() -> void:
	_chase = true
	_busy = true
	player.frozen = true
	gull = ThiefGull.new()
	city.add_child(gull)
	gull.global_position = Vector3(0.6, 7.45, ByzCity.HALL_Z0 + 1.4)
	gull.paper.visible = false
	var hand := player.global_position + Vector3(0, 1.3, 0) - player.global_transform.basis.z * 0.5
	player.face(gull.global_position)
	Audio.sfx("chicken", -6.0, 1.9)
	await gull.fly_to(hand, 12.0)
	gull.paper.visible = true
	gull.flying = true
	Audio.sfx("chicken", -4.0, 2.1)
	player.shake(0.3)
	gull.fly_to(PERCHES[0], 7.0)
	await _t("D6B_T_GULL")
	await _say("SPK_NIKO", "D6B_N_GULL")
	if gull.flying:
		await gull.landed
	player.frozen = false
	_busy = false
	var item_cb := func(_target: String, item: String):
		if item == "chickpeas" and _chase and not _lured and gull and not gull.flying and _hdist(gull.global_position) < 9.0:
			_lured = true
	player.item_used.connect(item_cb)
	var i := 0
	while i < PERCHES.size():
		var last := i == PERCHES.size() - 1
		if i > 0:
			hud.bark("SPK_TOLGA", "D6B_T_CHASE_%d" % mini(i, 4), 3.0)
			await gull.fly_to(PERCHES[i], 7.0)
		_chase_left = PATIENCE[i]
		var reached := false
		var shown := -1
		while true:
			if GameState.autotest:
				_auto_chase_step(i)
			if _lured:
				break
			if _hdist(gull.global_position) < REACH and player.global_position.y > gull.global_position.y - 6.0:
				reached = true
				break
			if not last:
				_chase_left -= get_process_delta_time()
				if _chase_left <= 0.0:
					break
			if ceili(_chase_left) != shown:
				shown = ceili(_chase_left)
				_update_objective()
			await get_tree().process_frame
		_chase_left = 0.0
		if _lured:
			await _gull_lure()
			break
		if reached and last:
			await _gull_caught(true)
			break
		if not reached:
			_mistakes += 1
			Audio.sfx("chicken", -6.0, 2.2)
			if _mistakes >= MAX_MISTAKES:
				await _gull_lost()
				break
			hud.bark("SPK_TOLGA" if _mistakes % 2 == 1 else "SPK_NIKO", "D6B_T_MISS" if _mistakes % 2 == 1 else "D6B_N_MISS", 3.0)
		else:
			Audio.sfx("chicken", -8.0, 1.8)
		i += 1
	player.item_used.disconnect(item_cb)
	_chase = false
	_update_objective()


func _hdist(p: Vector3) -> float:
	return Vector2(p.x - player.global_position.x, p.z - player.global_position.z).length()


## Otomatik test: tünek başına ya kaçır (sabrı bitir) ya da yanına ışınlan.
func _auto_chase_step(i: int) -> void:
	var v := GameState.autotest_variant
	var miss := (v == "byzmistake" and i == 1) or (v == "byzfail" and i < 3)
	if miss and i < PERCHES.size() - 1:
		_chase_left = 0.0001
	else:
		player.global_position = Vector3(PERCHES[i].x + 1.0, 0.05, PERCHES[i].z + 1.5)


func _gull_lure() -> void:
	_busy = true
	player.frozen = true
	await _t("D6B_T_LURE")
	var ground := player.global_position - player.global_transform.basis.z * 1.6
	ground.y = player.global_position.y
	player.face(ground)
	await gull.fly_to(ground, 9.0)
	await _gull_caught(false)


## Martı izni bırakır; kâğıt alınır. Masada yakalandıysa Giustiniani konuşmaya başlar.
func _gull_caught(at_table: bool) -> void:
	_busy = true
	player.frozen = true
	var pp := gull.drop_paper()
	Audio.sfx("chicken", -6.0, 2.0)
	_gull_leave(Vector3(-40, 30, -60))
	await _wait(0.9)
	if is_instance_valid(pp):
		pp.queue_free()
	Audio.sfx("newspaper", -8.0)
	await _t("D6B_T_CAUGHT")
	await _permit_done()
	if at_table:
		await _say("SPK_GIUST", "D6B_G_GULL")
	player.frozen = false
	_busy = false
	if at_table:
		await _giust()


func _gull_leave(to: Vector3) -> void:
	var g := gull
	gull = null
	await g.fly_to(to, 12.0)
	g.queue_free()


func _gull_lost() -> void:
	_busy = true
	player.frozen = true
	player.face(gull.global_position)
	_gull_leave(Vector3(46, 26, -14))
	await _t("D6B_T_LOST")
	await _labyrinth_fail()
	_busy = false


func _permit_done() -> void:
	_permit = true
	_outcome = ""
	GameState.flags["labyrinth_mistakes"] = _mistakes
	_update_objective()


func _labyrinth_fail() -> void:
	_outcome = "6b.3"
	phase = "done"
	player.frozen = true
	# İzinsiz yabancı: sur yolundaki muhafız yakalar
	var guard := Person.new({"coat": Color("7a2a24"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true, "beard": true})
	city.add_child(guard)
	var gp := player.global_position - player.global_transform.basis.z * 1.8
	guard.global_position = Vector3(gp.x, player.global_position.y, gp.z)
	guard.look_target = player
	guard.set_meta("spk", "SPK_CITY_GUARD")
	guard.talking = true
	await hud.say("SPK_CITY_GUARD", "D6B_GUARD_FAIL")
	guard.talking = false
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH6B_DUNGEON"), 30, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	# Zindan gerçekten görünsün: hücrede uyanır, Niko parmaklığın önünde (karanlıkta konuşulmasın)
	player.global_position = ByzCity.CELL_START + Vector3(0, 0.05, 0)
	city.niko.position = ByzCity.CELL_START + Vector3(0.4, 0, 2.6)
	city.niko.look_target = player
	player.face(city.niko.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	# "İkinci zindanım", "Yine mi?": yalnız Bölüm 4'te denize düşüp hücreye girdiyse (4b.3)
	var again: bool = GameState.chapter_outcomes.get(4, "") == "4b.3"
	await _t("D6B_T_DUNGEON" if again else "D6B_T_DUNGEON_FIRST")
	await _say("SPK_NIKO", "D6B_N_DUNGEON" if again else "D6B_N_DUNGEON_FIRST")


func _giust(auto := false) -> void:
	if _busy or not _permit or _giust_done:
		if not _permit and not _busy:
			hud.bark("SPK_GIUST", "D6_GIUST_NO_PERMIT", 3.0)
		return
	_busy = true
	player.frozen = true
	player.face(city.giustiniani.global_position + Vector3(0, 1.45, 0))
	await _say("SPK_GIUST", "D6_GIUST_HELLO")
	await _t("D6B_T_INSURANCE")
	await _say("SPK_GIUST", "D6B_G_INSURANCE")
	await _t("D6B_T_INSURANCE2")
	await _say("SPK_GIUST", "D6B_G_INSURANCE2")
	# Kitap çantadaysa göstermek oyuncunun seçimi; gösterilirse elde gerçekten açılır
	var show_book := false
	if "book" in GameState.bag:
		show_book = await hud.choose(["UI_CH6B_SHOW_BOOK", "UI_CH6B_KEEP_BOOK"], 0.0, 0) == 0
	if show_book:
		player.show_prop("book", 3.0)
		await _t("D6B_T_BOOK")
		await _say("SPK_GIUST", "D6_GIUST_BOOK")
	else:
		await _t("D6B_T_KNOW")
	# ⏱ Uyar ya da uyarma
	var pick := 0 if GameState.autotest_variant == "byzmistake" else 1
	var c := await hud.choose(["UI_CH6B_WARN", "UI_CH6B_SILENT"], 6.0, pick)
	if c == 0:
		GameState.flags["giustiniani_warned"] = true
		GameState.paradox += 30
		GameState.flags["buro_baskisi"] = int(GameState.flags.get("buro_baskisi", 0)) + 2
		await _t("D6B_T_WARN")
		await _say("SPK_GIUST", "D6B_G_WARN")
		player.shake(0.6)
		hud.bark("SPK_NIHAT", "D6B_NIHAT_ALARM", 3.5)
	else:
		await _t("D6B_T_SILENT")
		await _say("SPK_GIUST", "D6B_G_SILENT")
	_giust_done = true
	_update_objective()
	Lore.scatter(self, branch)
	player.frozen = false
	_busy = false


func _emperor() -> void:
	if _busy or not _giust_done or _emperor_done:
		if not _giust_done and not _busy:
			hud.bark("SPK_NIKO", "D6B_N_NOT_YET", 3.0)
		return
	_busy = true
	player.frozen = true
	# Niko tercüman olarak yanına gelir
	city.niko.position = ByzCity.EMPEROR_POS + Vector3(1.0, 0, -1.4)     # mangala masasının içinde değil, karşı yanda
	player.global_position = ByzCity.EMPEROR_POS + Vector3(1.8, 0.05, 0)
	player.face(city.emperor.global_position + Vector3(0, 1.5, 0))
	await _say("SPK_EMPEROR", "D6B_E_01")
	await _say("SPK_NIKO", "D6B_N_E_01")
	await _t("D6B_T_E_02")
	await _say("SPK_EMPEROR", "D6B_E_03")
	await _say("SPK_NIKO", "D6B_N_E_03")
	await _say("SPK_EMPEROR", "D6B_E_04")
	await _say("SPK_NIKO", "D6B_N_E_04")
	GameState.flags["letter"] = true
	if GameState.flags.get("niko_friend", false):
		GameState.flags["niko_friend_6b"] = true
		await _say("SPK_NIKO", "D6B_N_FRIEND")
	_emperor_done = true
	_update_objective()
	Lore.scatter(self, branch)
	player.frozen = false
	_busy = false


## Kapı: mektubu aç ya da açma (iki kez onay), sonra beyaz bayrakla çıkış.
func _exit() -> void:
	if _busy or not _emperor_done or _outcome != "":
		return
	_busy = true
	player.frozen = true
	await _t("D6B_T_LETTER")
	var open_pick := 0 if GameState.autotest_variant == "byzmistake" else 1
	var c := await hud.choose(["UI_CH6B_OPEN", "UI_CH6B_KEEP"], 0.0, open_pick)
	if c == 0:
		var sure := await hud.choose(["UI_CH6B_OPEN_SURE", "UI_CH6B_KEEP"], 0.0, 0)
		if sure == 0:
			await _read_letter()
	if not GameState.flags.get("letter_opened", false):
		await _t("D6B_T_SEALED")
	# Beyaz bayrak
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH6B_FLAG"), 28, Color("f2e6c9")]], 1.6)
	hud.clear_card()
	await _say("SPK_NIKO", "D6B_N_BYE")
	_outcome = "6b.1" if _mistakes == 0 else "6b.2"
	phase = "done"
	_busy = false


## Mektup açılırsa: Tolga'nın oyundaki tek ciddi anı. Sonra tavuk gagalar.
func _read_letter() -> void:
	GameState.flags["letter_opened"] = true
	GameState.paradox += 15
	await hud.fade_to(0.7, 0.8)
	await hud.card([[tr("UI_CH6B_LETTER_HEAD"), 22, Color("f2e6c9")], [tr("UI_CH6B_LETTER_TEXT"), 20, Color(1, 1, 1, 0.9)]], 5.0)
	hud.clear_card()
	await _wait(3.2)
	await hud.fade_to(0.0, 0.6)
	if sinerji:
		await _t("D6B_T_PECK")
	else:
		await _t("D6B_T_AFTER_LETTER")


func _auto_6b() -> void:
	var v := GameState.autotest_variant
	if v == "byzclimb":
		await _auto_climb()
	await _niko_talk(0)
	await _clerk(2)
	await _clerk(6)
	player.global_position = Vector3(0, 0.05, ByzCity.HALL_Z0 + 2.0)
	while not _chase:
		await get_tree().process_frame
	while _chase:
		await get_tree().process_frame
	if v == "byzfail":
		return
	while _busy:
		await get_tree().process_frame
	if not _giust_done:
		await _giust()
	await _emperor()
	await _exit()


## Bot: ara sokakta evin yan duvarına gerçek tuşlarla tutunur (Space), tırmanır (W), çatıya çıkar, sırttaki seyir
## noktasına yürür, sonra caddeye iner. Traversal, katı çatı ve Vista birlikte denenir.
var climb_top := 0.0


func _auto_climb() -> void:
	var start := Vector3(-5.6, 0.05, -0.55)
	player.global_position = start
	player.face(start + Vector3(0, 1.6, 2.0))
	await get_tree().create_timer(0.3).timeout
	Input.action_press("move_forward")
	Input.action_press("jump")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("jump")
	var t := 0.0
	while t < 20.0 and not (player.traversal.state == "" and player.is_on_floor() and player.global_position.y > 5.0):
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		climb_top = maxf(climb_top, player.global_position.y)
		if player.traversal.state == "" and player.is_on_floor() and player.global_position.y < 1.0 and t > 1.0:
			# Tutunamadıysa yeniden dene
			Input.action_press("jump")
			await get_tree().physics_frame
			Input.action_release("jump")
	print("CLIMB6B t=%.1f y=%.2f state=%s climbs=%d mantles=%d" % [t, player.global_position.y, player.traversal.state,
		player.traversal.climbs, player.traversal.mantles])
	# Çatıda sırttaki seyir noktasına yürü
	var vp: Vector3 = VISTAS[0][0]
	t = 0.0
	while t < 12.0 and vistas_seen < 1:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		climb_top = maxf(climb_top, player.global_position.y)
		var flat := Vector3(vp.x, player.global_position.y + 1.6, vp.z)
		player.face(flat)
		if Vector2(player.global_position.x - vp.x, player.global_position.z - vp.z).length() < 0.6:
			Input.action_release("move_forward")
	Input.action_release("move_forward")
	while vistas_seen < 1 and t < 20.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	print("VISTA6B seen=%d at=%s" % [vistas_seen, player.global_position.snapped(Vector3.ONE * 0.1)])
	player.traversal.cancel()
	player.global_position = Vector3(0, 0.05, -2.0)
	await get_tree().create_timer(0.3).timeout


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	GameState.set_outcome(6, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=6 -> 7 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter7.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter7.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	if branch == "6a":
		c.title_text = tr("UI_FLOW6A_TITLE")
		c.nodes = [
			{"id": "morning", "key": "FLOW6A_MORNING", "pos": Vector2(0.5, 0.16)},
			{"id": "A", "key": "FLOW6A_A", "pos": Vector2(0.14, 0.32)},
			{"id": "B", "key": "FLOW6A_B", "pos": Vector2(0.38, 0.32)},
			{"id": "C", "key": "FLOW6A_C", "pos": Vector2(0.62, 0.32)},
			{"id": "Y", "key": "FLOW6A_Y", "pos": Vector2(0.86, 0.32)},
			{"id": "6a.1", "key": "FLOW_6A_1", "pos": Vector2(0.14, 0.48), "outcome": true},
			{"id": "6a.2", "key": "FLOW_6A_2", "pos": Vector2(0.38, 0.48), "outcome": true},
			{"id": "6a.3", "key": "FLOW_6A_3", "pos": Vector2(0.62, 0.48), "outcome": true},
			{"id": "6a.4", "key": "FLOW_6A_4", "pos": Vector2(0.86, 0.48), "outcome": true},
			{"id": "6a.5", "key": "FLOW_6A_5", "pos": Vector2(0.5, 0.62), "outcome": true},
		]
		c.edges = [["morning", "A"], ["morning", "B"], ["morning", "C"], ["morning", "Y"],
			["A", "6a.1"], ["B", "6a.2"], ["C", "6a.3"], ["Y", "6a.4"], ["morning", "6a.5"]]
		c.taken["morning"] = true
		c.taken[GameState.flags.get("route", "A")] = true
		if GameState.flags.get("candarli_letter", false):
			c.taken["6a.5"] = true
	else:
		c.title_text = tr("UI_FLOW6B_TITLE")
		c.nodes = [
			{"id": "maze", "key": "FLOW6B_MAZE", "pos": Vector2(0.5, 0.16)},
			{"id": "6b.1", "key": "FLOW_6B_1", "pos": Vector2(0.2, 0.3), "outcome": true},
			{"id": "6b.2", "key": "FLOW_6B_2", "pos": Vector2(0.5, 0.3), "outcome": true},
			{"id": "6b.3", "key": "FLOW_6B_3", "pos": Vector2(0.8, 0.3), "outcome": true},
			{"id": "giust", "key": "FLOW6B_GIUST", "pos": Vector2(0.35, 0.44)},
			{"id": "emperor", "key": "FLOW6B_EMPEROR", "pos": Vector2(0.35, 0.56)},
			{"id": "6b.4", "key": "FLOW_6B_4", "pos": Vector2(0.12, 0.7), "outcome": true},
			{"id": "6b.5", "key": "FLOW_6B_5", "pos": Vector2(0.37, 0.7), "outcome": true},
			{"id": "6b.6", "key": "FLOW_6B_6", "pos": Vector2(0.62, 0.7), "outcome": true},
		]
		c.edges = [["maze", "6b.1"], ["maze", "6b.2"], ["maze", "6b.3"], ["6b.1", "giust"], ["6b.2", "giust"],
			["giust", "emperor"], ["giust", "6b.5"], ["emperor", "6b.4"], ["emperor", "6b.6"]]
		c.taken["maze"] = true
		if _outcome != "6b.3":
			c.taken["giust"] = true
			c.taken["emperor"] = true
		if GameState.flags.get("niko_friend", false):
			c.taken["6b.4"] = true
		if GameState.flags.get("giustiniani_warned", false):
			c.taken["6b.5"] = true
		if GameState.flags.get("letter_opened", false):
			c.taken["6b.6"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_FLOW_STATS") % GameState.telsiz_bag + "     ·     " + tr("UI_PARADOX") % GameState.paradox + "     ·     " + ("Fes: ✓" if GameState.flags.get("fez", true) else "Fes: ✗"),
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW6_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase == "free":
		if id in ["kadri", "lutfi", "urban", "niko", "giustiniani", "emperor", "candarli", "nihat"]:
			p = tr("UI_PROMPT3_TALK") % tr(SPEAKERS.get(id, "SPK_NIHAT"))
		elif id.begins_with("clerk:"):
			p = tr("UI_PROMPT6_CLERK") % ByzCity.GREEK[int(id.trim_prefix("clerk:"))]
		elif id in ["goat", "ring", "letter"] and not _favors.has(id):
			p = tr("UI_PROMPT6_" + id.to_upper())
		elif id == "cannon":
			p = tr("UI_PROMPT3_LOOK")
		elif id == "exit" and _emperor_done:
			p = tr("UI_PROMPT6_EXIT")
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy or phase != "free":
		return
	match id:
		"kadri", "lutfi", "urban":
			_talk(id)
		"candarli":
			_candarli()
		"goat":
			if player.global_position.distance_to(day.goat.global_position) < 2.2:
				_favor("goat")
			else:
				hud.bark("SPK_TOLGA", "D6A_T_GOAT_MISS", 2.0)
		"ring", "letter":
			_favor(id)
		"cannon":
			hud.bark("SPK_TOLGA", "D6A_T_CANNON", 4.0)
		"niko":
			_niko_talk()
		"nihat":
			hud.bark("SPK_NIHAT", "D6B_NIHAT_CAMEO", 5.0)
		"giustiniani":
			_giust()
		"emperor":
			_emperor()
		"exit":
			_exit()
		_:
			if id.begins_with("clerk:"):
				_clerk(int(id.trim_prefix("clerk:")))
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _h(key: String) -> void:
	await hud.say("SPK_HIKMET", key)


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


## Biçimlendirmeli replik: çevirinin içindeki %s doldurulur (hud.say, çevrilmiş metni olduğu gibi gösterir).
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


# ================================================================ otomatik test

func _autotest_report() -> void:
	var expected: String = {"": "6a.1", "b": "6a.2", "c": "6a.3", "y": "6a.4", "letter": "6a.1",
		"byz": "6b.1", "byzmistake": "6b.2", "byzfail": "6b.3", "next": "6a.1", "byzclimb": "6b.1"}[GameState.autotest_variant]
	var ok := _outcome == expected
	if GameState.autotest_variant == "letter" and not GameState.flags.get("candarli_letter", false):
		ok = false
	if GameState.autotest_variant == "byzmistake" and not (GameState.flags.get("giustiniani_warned", false) and GameState.flags.get("letter_opened", false)):
		ok = false
	# Serbest tırmanma: bot gerçekten çatıya çıkmış ve seyir noktasını görmüş olmalı
	if GameState.autotest_variant == "byzclimb" and (climb_top < 6.0 or vistas_seen < 1 or not _roof_joke):
		printerr("AUTOTEST: tırmanma tepe=%.1f seyir=%d şaka=%s" % [climb_top, vistas_seen, _roof_joke])
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen sonuç %s, gelen %s" % [expected, _outcome])
	if GameState.chapter_outcomes.get(6, "") != _outcome:
		ok = false
	print("AUTOTEST %s chapter=6 variant=%s branch=%s outcome=%s paradox=%d mistakes=%d telsiz=%d" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, branch, _outcome, GameState.paradox, _mistakes, GameState.telsiz_bag])
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
	if branch == "6a":
		phase = "free"
		_update_objective()
		player.global_position = Vector3(0.5, 0.05, 6.0)
		player.face(Vector3(0, 4.0, CampDay.OTAG_POS.z))
		hud.bark("SPK_TOLGA", "D6A_T_01", 30.0)
		await _shot("c6_01_ordugah.png")
		player.global_position = CampDay.KADRI_FRONT + Vector3(1.8, 0.05, 2.6)
		player.face(day.kadri.global_position + Vector3(0, 1.3, 0))
		day.kadri.look_target = player
		hud.bark("SPK_KADRI", "D6_KADRI_CHICKPEAS", 30.0)
		await get_tree().create_timer(0.3).timeout
		await _shot("c6_02_kadri.png")
		player.global_position = CampDay.URBAN_POS + Vector3(2.2, 0.05, 3.2)
		player.face(day.urban.global_position + Vector3(-1.2, 1.3, 0))
		day.urban.look_target = player
		hud.bark("SPK_URBAN", "D6_URBAN_PHONE", 30.0)
		await get_tree().create_timer(0.3).timeout
		await _shot("c6_03_urban.png")
		player.global_position = Vector3(-1.0, 0.05, 6.5)
		player.face(Vector3(1.0, 0.6, 13.0))
		hud.bark("SPK_TOLGA", "D6A_T_GOAT_MISS", 30.0)
		await _shot("c6_04_pazar.png")
		get_tree().quit()
		return
	phase = "free"
	_update_objective()
	player.global_position = Vector3(0.5, 0.05, 4.0)
	player.face(Vector3(0, 3.0, -30.0))
	hud.bark("SPK_NIKO", "D6B_N_CALL", 30.0)
	await _shot("c6_05_sehir.png")
	# Martı kovalamacası: izin gagada, meydan çeşmesinin tepesinde; Tolga çeşmenin önünde
	_chase = true
	_chase_left = 11.0
	gull = ThiefGull.new()
	city.add_child(gull)
	gull.global_position = PERCHES[0]
	gull.rotation.y = PI * 0.8
	_update_objective()
	player.global_position = Vector3(-1.6, 0.05, -11.2)
	player.face(PERCHES[0] + Vector3(0, 0.3, 0))
	hud.bark("SPK_TOLGA", "D6B_T_CHASE_1", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c6_06_marti.png")
	gull.global_position = PERCHES[2]
	player.global_position = Vector3(-0.8, 0.05, 5.5)
	player.face(PERCHES[2] + Vector3(0, 0.3, 0))
	hud.bark("SPK_TOLGA", "D6B_T_CHASE_3", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c6_06b_ip.png")
	gull.queue_free()
	_chase = false
	_permit = true
	_update_objective()
	player.global_position = ByzCity.GIUST_POS + Vector3(-2.6, 0.05, 1.2)
	player.face(city.giustiniani.global_position + Vector3(0, 1.4, 0))
	city.giustiniani.look_target = player
	hud.bark("SPK_GIUST", "D6B_G_INSURANCE", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c6_07_giustiniani.png")
	_giust_done = true
	_update_objective()
	city.niko.position = ByzCity.EMPEROR_POS + Vector3(1.0, 0, -1.4)     # mangala masasının içinde değil, karşı yanda
	player.global_position = ByzCity.EMPEROR_POS + Vector3(2.4, 0.05, 0.6)
	player.face(city.emperor.global_position + Vector3(0, 1.5, 0))
	hud.bark("SPK_NIKO", "D6B_N_E_04", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c6_08_imparator.png")
	get_tree().quit()
