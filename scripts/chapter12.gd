extends Node3D
## Bölüm 12 — Huzur (Tolga · 26 Nisan 1453, sabah). CHAPTERS Bölüm 12, GDD §9.6, STORY_BRANCHES Son 1–5.
##
## Otağın içinde, Fatih'in karşısında bir diyalog bulmacası. Ekranın köşesinde İkna olasılığı %
## (Merak 0: %10 · 1: %40 · 2: %70 · 3+: %100). Merak gelir:
##   dürüst itiraftan ("Aslında hiçbir şey bilmiyorum"), ilginç eşyadan (📱 🧊 📘),
##   doğru bir mühendislik yorumundan (Urban'ın topu), İmparator'un mektubunu teslim etmekten.
## Yanındakiler sahneyi değiştirir: pijamalı Hikmet (8.4), Nihat (11.3).
## ⏱ Kilit soru: "Madem gelecektensin, söyle bakalım. Bu şehir alınacak mı?"
##   12.1 Tarih Yerinde (W1) · 12.2 Leblebipolis (W2) · 12.3 İki Hükümdar (W3)
##   12.4 Sultan'ın Tamiri (W4) · 12.5 Mutfağa gönderildi (bir kez yeniden denenir) · 12.6 Mühendisler Meclisi
## Dürüst bir cevap `honest_with_sultan` bayrağını açar (Bölüm 15'teki "Bilmiyorum").
##   --autotest[=leblebi|twokings|repair|kitchen|retry|hikmet|nihat|urban]   (varsayılan: 12.1)

const PERCENT := [10, 40, 70, 100]
const MAX_ITEMS := 3

var hall: OtagHall
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _merak := 0
var _tries := 0
var _shown: Dictionary = {}
var _letter_delivered := false
var _envoy := false
var hikmet: Hikmet
var nihat: Person


func _ready() -> void:
	GameState.snapshot(12)
	_apply_autotest_setup()
	var ch6: String = GameState.chapter_outcomes.get(6, "6a.1")
	# İmparator'un mektubu: Bizans yolunda (6b.1/6b.2) ya da heyette (10H.1) Tolga'ya verildi
	_envoy = (ch6.begins_with("6b") and ch6 != "6b.3") or GameState.flags.get("byz_letter", false)
	_merak = int(GameState.flags.get("merak", 0))
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	player.show_remote(true)
	hall = OtagHall.new()
	add_child(hall)
	if GameState.chapter_outcomes.get(8, "") == "8.4" and GameState.chapter_outcomes.get(11, "") != "11.1":
		hikmet = Hikmet.new()
		hikmet.position = OtagHall.HIKMET_SPOT
		hikmet.rotation.y = PI
		add_child(hikmet)
		hikmet.carry_gun()
	if String(GameState.chapter_outcomes.get(10, "")).begins_with("10B"):
		# Urban'ın çırağı yolu: Sultan topun başında görüp çağırttı, usta da yanında gelir (kapıda sıra beklenmez)
		var urban := Person.new({"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "hat": "kalpak", "face": "urban", "mustache": true,
			"beard": true, "hair": Color("6a5040")})
		urban.set_meta("spk", "SPK_URBAN")
		urban.position = OtagHall.TOLGA_SPOT + Vector3(-1.2, 0, 1.6)
		add_child(urban)
		urban.look_target = hall.fatih
	if GameState.flags.get("nihat_joined", false):
		nihat = Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
			"hair": Color("3a2a1e"), "skin": Color("ecb892")})
		nihat.position = OtagHall.NIHAT_SPOT
		nihat.rotation.y = PI
		add_child(nihat)
	if hikmet or nihat:
		GameState.flags["fatih_name"] = true      # yanındakiler ona adıyla seslenir
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
		"leblebi":
			GameState.flags["leblebi_given"] = true
			GameState.paradox = 50
			if not "book" in GameState.bag:
				GameState.bag.append("book")
		"twokings":
			GameState.chapter_outcomes[6] = "6b.1"
			GameState.paradox = 45
		"repair":
			for id in ["tape", "cube", "phone"]:
				if not id in GameState.bag:
					GameState.bag.append(id)
		"hikmet":
			GameState.chapter_outcomes[8] = "8.4"
		"nihat":
			GameState.flags["nihat_joined"] = true
		"urban":
			GameState.chapter_outcomes[10] = "10B.1"      # Urban'ın çırağı yolu (Usta otağda, giriş repliği farklı)


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH12_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH12_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = OtagHall.ENTRY + Vector3(0, 0.05, 0)
	player.face(hall.fatih.global_position + Vector3(0, 1.6, 0))
	await hud.fade_to(0.0, 1.0)
	var tw := create_tween()
	tw.tween_property(player, "global_position", OtagHall.TOLGA_SPOT + Vector3(0, 0.05, 0), 3.0 if not GameState.autotest else 0.05)
	await tw.finished
	player.face(hall.fatih.global_position + Vector3(0, 1.7, 0))
	hall.fatih.look_target = player
	await _t(_enter_key())
	if hikmet:
		# Hikmet sabahtan beri otağda: Tolga onu görür, konuşmadan geçmez (eskiden hiç tepki vermiyordu)
		await _t("D12_T_SEE_HIKMET")
		await _say("SPK_HIKMET", "D12_H_ALREADY")
	await _f(_opening_key())
	_show_persuade()
	await _companions()
	while _outcome == "":
		await _audience()
	await _ending()
	await _end_chapter()


## Otağa nasıl gelindi: kapıdan (Sorucu Ağa), Urban'ın topunun başından, mutfaktan, arşivden, mektupla...
func _route() -> String:
	return String(GameState.chapter_outcomes.get(10, ""))


func _enter_key() -> String:
	var r := _route()
	if r.begins_with("10B"):
		return "D12_T_ENTER_URBAN"       # topun başında görüldü, Urban'ın ardından girer (kapıda yeniden sıra beklemez)
	if r.begins_with("10Z"):
		return "D12_T_ENTER_KITCHEN"
	if r.begins_with("10A"):
		return "D12_T_ENTER_ARCHIVE"
	return "D12_T_ENTER"


## Sultan'ın ilk sözü: oraya nasıl gelindiğini ve "gelecekten" geldiğini nereden bildiğini söyler (eskiden her yolda
## "Sorucu Ağa senin için 'soruya soruyla cevap veriyor' dedi" diyordu: kapıdan gelmeyen, doğru cevap veren için de).
func _opening_key() -> String:
	if hikmet:
		return "D12_F_01_HIKMET"         # ihtiyar sabahtan beri anlatıyor
	var r := _route()
	if r.begins_with("10B"):
		return "D12_F_01_URBAN"
	if r.begins_with("10Z"):
		return "D12_F_01_KITCHEN"
	if r.begins_with("10A"):
		return "D12_F_01_ARCHIVE"
	if r.begins_with("10G"):
		return "D12_F_01_LETTER"
	if r.begins_with("10L"):
		return "D12_F_01_MINE"
	if r.begins_with("10H"):
		return "D12_F_01_HEYET"          # heyetle surların içine girdi (Lütfi anlattı)
	if r == "10O.2":
		return "D12_F_01_GATEFAIL"
	if r.begins_with("10O"):
		if GameState.flags.get("ch10_twist", false):
			return "D12_F_01_TWIST"      # gerçekten soruya soruyla cevap verdi
		if GameState.flags.get("ch10_honest", false):
			return "D12_F_01_HONEST"
		return "D12_F_01_RIGHT"
	return "D12_F_01_POCKETS"


func _companions() -> void:
	if hikmet:
		await _f("D12_F_HIKMET_1")
		await _say("SPK_HIKMET", "D12_H_02")
		await _f("D12_F_HIKMET_3")
	if nihat:
		await _say("SPK_NIHAT", "D12_N_01")
		await _f("D12_F_NIHAT_2")
		await _say("SPK_NIHAT", "D12_N_03")
	if hikmet and nihat:
		await _f("D12_F_ALL")


## Bir huzur turu: soru, eşyalar, mühendislik, mektup, kilit soru.
func _audience() -> void:
	# 1. Kimsin?
	await _f("D12_F_WHO" if _tries == 0 else "D12_F_AGAIN")
	var v := GameState.autotest_variant
	var pick := 2
	if v == "kitchen" or (v == "retry" and _tries == 0):
		pick = 1
	var c := await hud.choose(["UI_CH12_WHO_A", "UI_CH12_WHO_B", "UI_CH12_WHO_C"], 0.0, pick)
	match c:
		0:
			await _t("D12_T_WHO_A")
			GameState.flags["fatih_name"] = true
			await _f("D12_F_WHO_A")
		1:
			await _t("D12_T_WHO_B")
			await _f("D12_F_WHO_B")
		_:
			await _t("D12_T_WHO_C")
			await _f("D12_F_WHO_C")
			if not GameState.flags.get("ch12_idk", false):
				GameState.flags["ch12_idk"] = true
				_add_merak(1)
			GameState.flags["honest_with_sultan"] = true
	# 2. Eşyalar (en fazla üç)
	await _items(c == 1 and not hikmet)
	if c == 1 and not hikmet:
		await _f("D12_F_FRANK")         # "Frenk elçisi" cevabından sonra "gelecekten gelen adam" demeden önce
	# 3. Mühendislik sorusu
	if not GameState.flags.get("ch12_cannon", false):
		await _f("D12_F_CANNON")
		var cp := 0 if v != "kitchen" and not (v == "retry" and _tries == 0) else 2
		var cc := await hud.choose(["UI_CH12_CANNON_A", "UI_CH12_CANNON_B", "UI_CH12_CANNON_C", "UI_CH12_CANNON_D"], 0.0, cp)
		await _t("D12_T_CANNON_" + ["A", "B", "C", "D"][maxi(cc, 0)])
		await _f("D12_F_CANNON_" + ["A", "B", "C", "D"][maxi(cc, 0)])
		if cc == 0:
			GameState.flags["ch12_cannon"] = true
			_add_merak(1)
		elif cc == 3:
			GameState.flags["honest_with_sultan"] = true
	# 4. Mektuplar
	await _letters()
	# Hikmet makineden bahseder
	if hikmet and not GameState.flags.get("ch12_hikmet_machine", false):
		GameState.flags["ch12_hikmet_machine"] = true
		await _say("SPK_HIKMET", "D12_H_MACHINE")
		await _f("D12_F_MACHINE")
		await _t("D12_T_JEALOUS")
		_add_merak(1)
	# Yeterince merak yoksa: mutfağa
	if _merak < 1:
		await _kitchen()
		return
	await _key_question()


func _items(frank := false) -> void:
	await _f("D12_F_ITEMS_B" if frank else "D12_F_ITEMS")
	var n := 0
	var plan: Array = {"": ["cube", "phone"], "repair": ["tape", "cube", "phone"], "leblebi": ["book", "chickpeas"],
		"hikmet": ["cube"], "nihat": ["cube", "phone"], "retry": ["cube", "phone"], "twokings": ["cube"], "next": ["cube", "phone"]}.get(GameState.autotest_variant, [])
	if GameState.autotest_variant == "retry" and _tries == 0:
		plan = []
	while n < MAX_ITEMS:
		var keys: Array = ["UI_CH12_ENOUGH"]
		var ids: Array = [""]
		for id in GameState.bag:
			if not _shown.has(id):
				keys.append(Items.name_key(id))
				ids.append(id)
		if ids.size() == 1:
			break
		var auto_i := 0
		for want in plan:
			if ids.has(want):
				auto_i = ids.find(want)
				break
		var c := await hud.choose(keys, 0.0, auto_i)
		if c <= 0:
			break
		var id: String = ids[c]
		_shown[id] = true
		n += 1
		# Eşya gerçekten el değiştirir: Tolga uzatır, Fatih alır ve inceler (konuşurken elinde döner)
		var model := Items.build(id)
		model.scale = Vector3.ONE * 0.34
		Props.strip_outlines(model)
		await _give_to_fatih(model)
		await _f("D12_F_ITEM_" + id.to_upper())
		match id:
			"phone":
				GameState.flags["phone_shown_sultan"] = true
				_add_merak(1)
			"book":
				GameState.flags["book_shown_sultan"] = true
				GameState.paradox += 10
				_add_merak(1)
			"cube":
				await _t("D12_T_CUBE")
				await _f("D12_F_CUBE_2")
				GameState.flags["cube_solved_sultan"] = true
				_add_merak(1)
			"tape":
				GameState.flags["tape_shown_sultan"] = true
				GameState.spend("tape", "fatih_12")          # Fatih bir şerit koparıp dener
			"chickpeas":
				GameState.spend("chickpeas", "fatih_leb_12")
			"thermos":
				GameState.spend("thermos", "fatih_tea_12")
			"powerbank":
				await _t("D12_T_POWERBANK")
				await _f("D12_F_POWERBANK_2")
				GameState.paradox += 5
			"cologne":
				await _t("D12_T_COLOGNE")
				GameState.spend("cologne", "fatih_cologne_12")
			"selfie":
				await _f("D12_F_SELFIE_2")
		hall.fatih.release_item()


func _letters() -> void:
	if GameState.flags.get("letter_route", "") == "fatih" and not GameState.flags.get("ch12_candarli", false):
		GameState.flags["ch12_candarli"] = true
		await _t("D12_T_CANDARLI")
		await _f("D12_F_CANDARLI")
	if _envoy and not _letter_delivered:
		_letter_delivered = true
		GameState.flags["letter_delivered"] = true
		await _t("D12_T_LETTER")
		# Mektubu uzatır; Fatih mührü görür, açar ve okur (okurken mektup yüzünün önünde)
		await _give_to_fatih(_letter_model(GameState.flags.get("letter_opened", false)), true)
		await _f("D12_F_LETTER")
		_add_merak(1)
		if GameState.flags.get("letter_opened", false):
			await _f("D12_F_SEAL")
			var c := await hud.choose(["UI_CH12_CONFESS", "UI_CH12_HIDE"], 8.0, 0)
			if c == 0:
				await _t("D12_T_CONFESS")
				await _f("D12_F_CONFESS")
				GameState.flags["honest_with_sultan"] = true
				_add_merak(1)
			else:
				await _t("D12_T_HIDE")
				await _f("D12_F_HIDE")
				_add_merak(-1)
		hall.fatih.release_item()


## ⏱ Kilit soru.
func _key_question() -> void:
	await _f("D12_F_KEY")
	if "book" in GameState.bag:
		await _book_rummage()
	var keys := ["UI_CH12_KEY_A", "UI_CH12_KEY_B", "UI_CH12_KEY_C"]
	var ids := ["a", "b", "c"]
	if hikmet and _merak >= 2:
		keys.append("UI_CH12_KEY_D")
		ids.append("d")
	var repair_ok: bool = GameState.flags.get("tape_shown_sultan", false) and GameState.flags.get("cube_solved_sultan", false) \
		and GameState.flags.get("phone_shown_sultan", false) and _merak >= 3 and GameState.paradox < 60
	if repair_ok:
		keys.append("UI_CH12_KEY_E")
		ids.append("e")
	var want: String = {"leblebi": "b", "twokings": "c", "repair": "e", "hikmet": "d", "kitchen": "b"}.get(GameState.autotest_variant, "a")
	if GameState.autotest_variant == "retry" and _tries == 0:
		want = "b"
	var c := await hud.choose(keys, 12.0, maxi(0, ids.find(want)))
	var ans: String = "a" if c < 0 else ids[c]
	if c < 0:
		await _f("D12_F_KEY_SILENT")
	match ans:
		"a":
			await _t("D12_T_KEY_A")
			GameState.flags["honest_with_sultan"] = true
			if GameState.flags.get("leblebi_given", false) and GameState.flags.get("book_shown_sultan", false) and GameState.paradox >= 60:
				_outcome = "12.2"
			else:
				_outcome = "12.1"
		"b":
			await _t("D12_T_KEY_B" if "book" in GameState.bag else "D12_T_KEY_B_NOBOOK")
			GameState.paradox += 20
			if GameState.flags.get("leblebi_given", false) and GameState.flags.get("book_shown_sultan", false):
				_outcome = "12.2"
			else:
				await _f("D12_F_KEY_B_NO")
				await _kitchen()
		"c":
			await _t("D12_T_KEY_C")
			if _envoy and _letter_delivered and GameState.paradox >= 40:
				_outcome = "12.3"
			else:
				await _f("D12_F_KEY_C_NO")
				await _kitchen()
		"d":
			await _t("D12_T_KEY_D")
			_outcome = "12.6"
		"e":
			await _t("D12_T_KEY_E")
			_outcome = "12.4"


## Kibarca mutfağa: "danışman". Bir kez yeniden denenir; ikincisinde sonuç 12.5.
func _kitchen() -> void:
	await _f("D12_F_KITCHEN")
	_tries += 1
	if _tries >= 2:
		await _t("D12_T_KITCHEN_END")
		_outcome = "12.5"
		return
	await hud.fade_to(1.0, 0.6)
	# Mutfak arası: kart arka planda kalır (sahne kurulmadan kara ekranda konuşulmasın)
	await hud.card([[tr("UI_CH12_KITCHEN"), 28, Color("f2e6c9")]], 1.4)
	await _say("SPK_KADRI", "D12_K_01")
	await _t("D12_T_K_02")
	await _say("SPK_KADRI", "D12_K_03")
	hud.clear_card()
	await hud.fade_to(0.0, 0.6)
	await _f("D12_F_RETRY")


func _ending() -> void:
	var up := _outcome.replace(".", "_")
	for i in 3:
		var k := "D12_END_%s_%d" % [up, i + 1]
		if tr(k) == k:
			break
		await hud.say(_end_speaker(_outcome, i), _end_variant(k))
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH12_END_" + up), 34, Color("f2e6c9")], [tr("UI_CH12_END_" + up + "_SUB"), 20, Color(1, 1, 1, 0.75)]], 3.0)
	hud.clear_card()
	GameState.flags["world"] = {"12.1": "W1", "12.2": "W2", "12.3": "W3", "12.4": "W4", "12.6": "W4"}.get(_outcome, "")
	if _outcome == "12.1":
		GameState.flags["has_kaftan"] = true      # "hediyeler, bir kaftan ve iyi dileklerle yolcu edildin"


## Son sözlerde Fatih Tolga'ya adıyla seslenir: adı kapıda, topun başında ya da huzurda söylenmediyse "yabancı".
## Gecelikli ihtiyarı (Hikmet) yalnız otağda gördüyse anar.
func _end_variant(k: String) -> String:
	if k == "D12_END_12_5_3" and hikmet == null:
		return k + "_NOH"
	if not GameState.flags.get("fatih_name", false) and tr(k + "_NONAME") != k + "_NONAME":
		return k + "_NONAME"
	return k


## Son sahnesinde kimin konuştuğu (satır sırasına göre).
func _end_speaker(outcome: String, i: int) -> String:
	var table := {
		"12.1": ["SPK_FATIH", "SPK_TOLGA", "SPK_FATIH"],
		"12.2": ["SPK_FATIH", "SPK_TOLGA", "SPK_FATIH"],
		"12.3": ["SPK_FATIH", "SPK_TOLGA", "SPK_FATIH"],
		"12.4": ["SPK_FATIH", "SPK_TOLGA", "SPK_FATIH"],
		"12.5": ["SPK_FATIH", "SPK_TOLGA", "SPK_FATIH"],
		"12.6": ["SPK_FATIH", "SPK_HIKMET", "SPK_FATIH"],
	}
	return table.get(outcome, ["SPK_FATIH"])[mini(i, 2)]


func _add_merak(d: int) -> void:
	_merak = maxi(0, _merak + d)
	GameState.flags["merak"] = _merak
	_show_persuade()


func _show_persuade() -> void:
	var p: int = PERCENT[mini(_merak, 3)]
	hud.set_chase(tr("UI_CH12_PERSUADE") % p, p / 100.0)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_chase("", 0.0)
	GameState.set_outcome(12, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		var nxt := Siege.gate("res://scenes/chapter13.tscn")
		print("AUTOTEST chapter=12 -> %s outcome=%s" % [nxt.get_file().get_basename().trim_prefix("chapter"), _outcome])
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
	c.title_text = tr("UI_FLOW12_TITLE")
	c.nodes = [
		{"id": "enter", "key": "FLOW12_ENTER", "pos": Vector2(0.5, 0.13)},
		{"id": "merak", "key": "FLOW12_MERAK", "pos": Vector2(0.5, 0.27)},
		{"id": "key", "key": "FLOW12_KEY", "pos": Vector2(0.5, 0.41)},
		{"id": "12.1", "key": "FLOW_12_1", "pos": Vector2(0.1, 0.6), "outcome": true},
		{"id": "12.2", "key": "FLOW_12_2", "pos": Vector2(0.27, 0.72), "outcome": true},
		{"id": "12.3", "key": "FLOW_12_3", "pos": Vector2(0.44, 0.6), "outcome": true},
		{"id": "12.4", "key": "FLOW_12_4", "pos": Vector2(0.61, 0.72), "outcome": true},
		{"id": "12.6", "key": "FLOW_12_6", "pos": Vector2(0.78, 0.6), "outcome": true},
		{"id": "12.5", "key": "FLOW_12_5", "pos": Vector2(0.88, 0.27), "outcome": true},
	]
	c.edges = [["enter", "merak"], ["merak", "key"], ["merak", "12.5"], ["key", "12.1"], ["key", "12.2"],
		["key", "12.3"], ["key", "12.4"], ["key", "12.6"], ["key", "12.5"]]
	c.taken["enter"] = true
	c.taken["merak"] = true
	if _outcome != "12.5" or _tries > 0:
		c.taken["key"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH12_STATS") % [_merak, GameState.paradox, "✓" if GameState.flags.get("honest_with_sultan", false) else "✗"],
		tr("UI_FLOW_LEGEND"),
		Siege.next_line("UI_FLOW12_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ yardımcılar

## Tolga eşyayı uzatır (birinci şahıs el), eşya Fatih'in eline geçer.
func _give_to_fatih(model: Node3D, read := false) -> void:
	player.hand_gesture("show")
	var from := player.camera.global_transform * Vector3(0.1, -0.2, -0.6)
	await hall.fatih.receive_item(model, from, read)


## Bizans mührüyle kapatılmış mektup; açıldıysa mühür ikiye kırık.
static func _letter_model(broken: bool) -> Node3D:
	var n := Node3D.new()
	Props.box(n, Vector3(0.24, 0.004, 0.32), Vector3.ZERO, Color("efe2c4"))
	for k in 6:
		Props.box(n, Vector3(0.17 - (k % 2) * 0.03, 0.002, 0.008), Vector3(-0.01, 0.003, -0.1 + k * 0.035), Color("4a3a2a"))
	if broken:
		for sx in [-1.0, 1.0]:
			Props.cyl(n, 0.022, 0.008, Vector3(sx * 0.018, 0.005, 0.11), Color("a8182a"), Vector3(0, 0, sx * 12.0), 8)
	else:
		Props.cyl(n, 0.028, 0.01, Vector3(0, 0.006, 0.11), Color("a8182a"), Vector3.ZERO, 12)
	Props.strip_outlines(n)
	return n


## Kitap çantadaysa Tolga hemen cevap vermez: "Hmm..." der, lise tarih kitabını çıkarıp sayfaları karıştırır;
## Fatih bekler ve cevabın kitaptan değil ondan gelmesini ister. Sonra seçim gelir.
func _book_rummage() -> void:
	var book := Items.open_book()
	player.camera.add_child(book)
	book.position = Vector3(0.03, -0.3, -0.5)
	book.rotation = Vector3(1.05, 0.0, 0.0)
	book.scale = Vector3.ONE * 0.9
	player.hand_gesture("show")
	Audio.sfx("newspaper", -8.0)
	Items.flip_pages(book, 9, 0.28)
	await _t("D12_T_KEY_HMM")
	await _f("D12_F_KEY_BOOK")
	var tw := create_tween()
	tw.tween_property(book, "position", Vector3(0.03, -0.75, -0.45), 0.35)
	tw.tween_callback(book.queue_free)


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _f(key: String) -> void:
	hall.fatih.talking = true
	await hud.say("SPK_FATIH", key)
	hall.fatih.talking = false


func _say(speaker: String, key: String) -> void:
	var who: Node3D = null
	if speaker == "SPK_NIHAT":
		who = nihat
	elif speaker == "SPK_HIKMET":
		who = hikmet
	if who and who is Person:
		(who as Person).talking = true
	elif who and who is Hikmet:
		(who as Hikmet).talking = true
	await hud.say(speaker, key)
	if who is Person:
		(who as Person).talking = false
	elif who is Hikmet:
		(who as Hikmet).talking = false


func _autotest_report() -> void:
	var expected: String = {"": "12.1", "leblebi": "12.2", "twokings": "12.3", "repair": "12.4", "kitchen": "12.5",
		"retry": "12.1", "hikmet": "12.6", "nihat": "12.1", "urban": "12.1", "next": "12.1"}[GameState.autotest_variant]
	var ok := _outcome == expected
	match GameState.autotest_variant:
		"retry":
			ok = ok and _tries == 1
		"", "nihat":
			ok = ok and GameState.flags.get("honest_with_sultan", false)
	if GameState.chapter_outcomes.get(12, "") != _outcome:
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=12 variant=%s outcome=%s merak=%d paradox=%d tries=%d honest=%s" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, _outcome, _merak, GameState.paradox, _tries,
		str(GameState.flags.get("honest_with_sultan", false))])
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
	player.global_position = OtagHall.ENTRY + Vector3(0, 0.05, -0.5)
	player.face(hall.fatih.global_position + Vector3(0, 1.4, 0))
	hud.bark("SPK_TOLGA", "D12_T_ENTER", 30.0)
	await get_tree().create_timer(0.4).timeout
	await _shot("c12_01_otag.png")
	player.global_position = OtagHall.TOLGA_SPOT + Vector3(0, 0.05, 0)
	player.face(hall.fatih.global_position + Vector3(0, 1.8, 0))
	hall.fatih.look_target = player
	hall.fatih.talking = true
	_merak = 2
	_show_persuade()
	hud.bark("SPK_FATIH", "D12_F_ITEM_CUBE", 30.0)
	await get_tree().create_timer(0.5).timeout
	await _shot("c12_02_fatih.png")
	hud.bark("SPK_FATIH", "D12_F_KEY", 30.0)
	hud.choose(["UI_CH12_KEY_A", "UI_CH12_KEY_B", "UI_CH12_KEY_C"], 12.0, 0)
	await get_tree().create_timer(0.8).timeout
	await _shot("c12_03_kilit.png")
	get_tree().quit()
