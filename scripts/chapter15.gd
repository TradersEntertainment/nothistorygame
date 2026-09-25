extends Node3D
## Bölüm 15 — Pazartesi (final). CHAPTERS Bölüm 15, §5 (kaderler), §7 (adlandırılmış finaller).
##
## Bütün kaderlerin birleştiği yer. Dört sahne:
##   1. Hikmet'in garajı (H1 / H2 / H3, N4 ortaklığı, W4 portresi, Pijamalı Kurtarma)
##   2. Nihat'ın masası (N1 / N2 / N3 / N4)
##   3. Servis durağı ve ofis (T1 / T2 / T3 / T4 × dünya). T1/T4 + honest_with_sultan: "Bilmiyorum" anı
##   4. Final kartı: adlandırılmış final ve kaderlerin özeti
## Oyuncu izleyicidir: kamera sahneden sahneye geçer, seçim yoktur.
##   --autotest[=missed|wrong|recruit|w4|forge|resign|newmodel|pyjama|stay|leblebi|fixed|liar]

var garage: Garage
var bureau: Bureau
var monday: Monday
var player: Player
var hud: Hud
var T := "T1"
var H := "H1"
var N := "N1"
var W := "W1"
var fixed := false
var final_id := ""


func _ready() -> void:
	GameState.snapshot(15)
	_apply_autotest_setup()
	_resolve_fates()
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.gravity_on = false
	hud.set_cinematic(true)
	hud.set_fez(false)
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	var f := GameState.flags
	match GameState.autotest_variant:
		"missed": f["tolga_fate"] = "T2"
		"wrong": f["tolga_fate"] = "T3"
		"recruit": f["tolga_fate"] = "T4"
		"w4": GameState.chapter_outcomes[12] = "12.4"
		"w8", "founder":
			GameState.chapter_outcomes.erase(12)
			GameState.chapter_outcomes[10] = "10A.1"
			f["world10"] = "W8"
			if GameState.autotest_variant == "founder":
				f["tolga_fate"] = "T4"
		"w13":
			GameState.chapter_outcomes.erase(12)
			GameState.chapter_outcomes[10] = "10L.1"
			f["world10"] = "W13"
		"w6":
			GameState.chapter_outcomes.erase(12)
			GameState.chapter_outcomes[10] = "10G.1"
			f["world10"] = "W6"
		"w7":
			GameState.chapter_outcomes.erase(12)
			GameState.chapter_outcomes[10] = "10Z.1"
			f["world10"] = "W7"
		"w10", "w11", "w12":
			GameState.chapter_outcomes[12] = "12B.1"
			f["world10"] = GameState.autotest_variant.to_upper()
		"boom", "gunner":
			GameState.chapter_outcomes.erase(12)
			GameState.chapter_outcomes[10] = "10B.3" if GameState.autotest_variant == "boom" else "10B.1"
			f["world10"] = "W5B" if GameState.autotest_variant == "boom" else "W5"
			f["big_bang"] = GameState.autotest_variant == "boom"
		"forge": f["nihat_fate"] = "N2"
		"resign": f["nihat_fate"] = "N4"
		"newmodel": f["nihat_fate"] = "N3"
		"pyjama": GameState.chapter_outcomes[13] = "13.4"
		"stay":
			f["tolga_fate"] = "T2"
			f["hikmet_fate"] = "H3"
		"leblebi": GameState.chapter_outcomes[12] = "12.2"
		"fixed":
			GameState.chapter_outcomes[12] = "12.2"
			f["world_fixed"] = true
		"liar": f["honest_with_sultan"] = false


## Kaderler: önceki bölümlerin bayraklarından.
func _resolve_fates() -> void:
	var f := GameState.flags
	T = f.get("tolga_fate", "T1")
	if f.get("tolga_arrested", false) and not T == "T4":
		T = "T4" if GameState.chapter_outcomes.get(14, "") == "14.3" else "T2"
	H = f.get("hikmet_fate", "H1")
	if H == "H1" and f.get("machine", "free") == "confiscated" and GameState.chapter_outcomes.get(13, "") == "13.2":
		H = "H2"
	N = f.get("nihat_fate", "N1")
	if f.get("nihat_dismissed", false):
		N = "N3"
	var ch12: String = GameState.chapter_outcomes.get(12, "")
	if (ch12 != "" and not ch12.begins_with("12B")) or not f.has("world10"):
		W = {"12.1": "W1", "12.2": "W2", "12.3": "W3", "12.4": "W4", "12.6": "W4"}.get(GameState.chapter_outcomes.get(12, "12.1"), "W1")
	else:
		# Dal bölümü Bölüm 12'yi atladıysa dünya oradan gelir (W5 Topçubaşı, W5B Büyük Patlama, ...)
		W = String(f["world10"])
	fixed = f.get("world_fixed", false) and W != "W1"
	final_id = _named_final()
	GameState.set_last_final(final_id)


## §7: birden fazla tutarsa üstteki kazanır.
func _named_final() -> String:
	var pyjama: bool = GameState.chapter_outcomes.get(13, "") == "13.4"
	if T == "T2" and H == "H3":
		return "two_neighbours"
	if T == "T2":
		return "empty_desk"
	if T == "T3":
		return "another_year"
	if T == "T4" and W == "W8":
		return "founding_member"
	if T == "T4":
		return "night_shift"
	if W == "W4" and not fixed:
		return "sultans_repair"
	if W == "W12" and not fixed:
		return "missing_paperwork"
	if W == "W11" and not fixed:
		return "long_wait"
	if W == "W10" and not fixed:
		return "one_more_year"
	if W == "W7" and not fixed:
		return "sultans_table"
	if W == "W6" and not fixed:
		return "envoy_to_venice"
	if W == "W8":
		return "bureau_founding"
	if W == "W13" and not fixed:
		return "tunnel_truce"
	if W == "W5B" and not fixed:
		return "big_bang"
	if W == "W5" and not fixed:
		return "master_gunner"
	if N == "N4":
		return "time_repair"
	if N == "N3":
		return "new_model"
	if H == "H2":
		return "sealed_garage"
	if pyjama:
		return "pyjama_rescue"
	if N == "N2":
		return "off_the_books"
	if fixed:
		return "fixed_mostly"
	if W in ["W2", "W3"]:
		return "nobody_noticed"
	return "ordinary_monday"


# ================================================================ sahneler

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH15_TITLE"), 48, Color("f2e6c9")], [tr("UI_CH15_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	await _scene_garage()
	await _scene_nihat()
	await _scene_monday()
	await _final_card()
	_finish()


func _cam(pos: Vector3, look: Vector3) -> void:
	player.global_position = pos
	player.face(look)


## 1. Hikmet'in garajı
func _scene_garage() -> void:
	await _title("UI_CH15_S1")
	garage = Garage.new()
	add_child(garage)
	garage.spin = 0.0
	for id in garage.items:
		(garage.items[id]["body"] as StaticBody3D).collision_layer = 0
	var hikmet: Hikmet = null
	if H != "H3":
		hikmet = Hikmet.new()
		hikmet.position = Garage.HIKMET_POS
		add_child(hikmet)
	_cam(Garage.SPAWN_POS + Vector3(0.4, 0.0, 0.4), Garage.PLATFORM_POS + Vector3(-0.6, 1.2, 0))
	var m := garage.get_node("Zamanator") as Node3D
	var key := "D15_G_H1"
	match final_id:
		"two_neighbours":
			key = "D15_G_TWO"
		"time_repair":
			var nihat := _nihat_person()
			nihat.position = Garage.HIKMET_POS + Vector3(1.2, 0, 0.3)
			add_child(nihat)
			Props.box(garage, Vector3(2.2, 0.35, 0.05), Vector3(0, 2.7, Garage.D / 2.0 - 0.05), Color("20252e"))
			Props.label(garage, "HİKMET & NİHAT · ZAMAN TAMİR SERVİSİ", Vector3(0, 2.7, Garage.D / 2.0 - 0.08), 30, Color("ffc98a"), Vector3(0, 180, 0), 2.1)
			key = "D15_G_N4"
		"pyjama_rescue":
			var t := _tolga_person(true)
			t.position = Garage.HIKMET_POS + Vector3(1.0, 0, 0.6)
			add_child(t)
			key = "D15_G_PYJAMA"
		"sealed_garage":
			m.visible = false
			Props.label(garage, "ZAMANATÖR 3001", Garage.PLATFORM_POS + Vector3(0, 0.05, 0), 36, Color("6ff2c8"), Vector3(-90, 0, 0), 1.4)
			key = "D15_G_H2"
	if H == "H3" and final_id != "two_neighbours":
		key = "D15_G_H3"
	if W == "W4" and not fixed:
		# Duvarda: Fatih'in, makineyi elinde tutarken yapılmış portresi
		var fp := Vector3(-Garage.W / 2.0 + 0.06, 1.8, -1.0)
		Props.box(garage, Vector3(0.05, 1.1, 0.85), fp, Color("d8b040"))
		Props.box(garage, Vector3(0.06, 0.95, 0.7), fp + Vector3(0.01, 0, 0), Color("6a1418"))
		Props.ball(garage, 0.16, fp + Vector3(0.05, 0.25, 0), Color("f4f1ea"), Vector3(0.3, 1, 1), 8)
		Props.box(garage, Vector3(0.02, 0.35, 0.3), fp + Vector3(0.05, -0.15, 0), Color("c8323a"))
		if key == "D15_G_H1":
			key = "D15_G_W4"
	if key == "D15_G_H1" and W in ["W5", "W5B", "W6", "W7", "W8", "W13", "W10", "W11", "W12"] and not fixed:
		key = "D15_G_" + W
	if GameState.flags.get("sinerji_2026", false):
		# Sinerji eklentisi: hangi final olursa olsun garajda bir tavuk
		var ch := Chicken.new()
		ch.position = Garage.HIKMET_POS + Vector3(0.9, 0, 0.9)
		add_child(ch)
	if key == "D15_G_H1" and W == "W1":
		Props.box(garage, Vector3(0.05, 1.3, 0.5), Vector3(Garage.W / 2.0 - 0.3, 1.2, 1.4), Color("7a3a8a"))
	await hud.fade_to(0.0, 0.8)
	if hikmet:
		hikmet.talking = true
	await hud.say("SPK_HIKMET", key)
	if hikmet:
		hikmet.talking = false
	if final_id == "pyjama_rescue":
		await hud.say("SPK_TOLGA", "D15_G_PYJAMA_T")
		await hud.say("SPK_HIKMET", "D15_G_PYJAMA_2")
		if hikmet:
			var tw := hikmet.create_tween().set_loops(3)
			tw.tween_property(hikmet, "rotation:y", 0.6, 0.35)
			tw.tween_property(hikmet, "rotation:y", -0.6, 0.35)
			await _wait(2.2)
	await hud.fade_to(1.0, 0.6)
	garage.queue_free()
	garage = null
	if hikmet:
		hikmet.queue_free()
	for c in get_children():
		if c is Person or c is Chicken:
			c.queue_free()


## 2. Nihat'ın masası
func _scene_nihat() -> void:
	await _title("UI_CH15_S2")
	bureau = Bureau.new()
	add_child(bureau)
	var nihat: Person = null
	if N != "N4":
		nihat = _nihat_person()
		nihat.position = Vector3(0.0, 0, 4.9)
		nihat.rotation.y = PI
		add_child(nihat)
	_cam(Vector3(0.9, 0.0, 1.8), Vector3(0, 1.3, 4.6))
	await hud.fade_to(0.0, 0.8)
	var key: String = {"N1": "D15_N_N1", "N2": "D15_N_N2", "N3": "D15_N_N3", "N4": "D15_N_N4"}[N]
	if T == "T4":
		key = "D15_N_T4"
	if nihat:
		nihat.talking = true
		if N == "N1":
			nihat.stamp()
	await hud.say("SPK_NIHAT" if N != "N4" else "SPK_MUFIDE", key)
	if nihat:
		nihat.talking = false
	await hud.fade_to(1.0, 0.6)
	bureau.queue_free()
	bureau = null
	if nihat:
		nihat.queue_free()


## 3. Servis ve ofis
func _scene_monday() -> void:
	await _title("UI_CH15_S3")
	monday = Monday.new(W, fixed)
	add_child(monday)
	if T == "T3":
		await hud.card([[tr("UI_CH15_T3"), 34, Color("f2e6c9")], [tr("UI_CH15_T3_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
		hud.clear_card()
		return
	# Durak
	_cam(Monday.STOP + Vector3(1.5, 0.0, 6.0), Monday.STOP + Vector3(2.5, 2.4, -4.2))
	if N == "N3":
		var old := _nihat_person()
		old.position = Monday.STOP + Vector3(-2.6, 0, -2.4)
		add_child(old)
	await hud.fade_to(0.0, 0.8)
	var tw := create_tween()
	tw.tween_property(monday.bus, "position", Monday.STOP + Vector3(-9.5, 0, 1.2), 2.5 if not GameState.autotest else 0.05)
	await tw.finished
	if not fixed and W != "W1":
		# Kamera Tolga'dan önce gazete standının manşetine bakar; Tolga bakmaz
		_cam(Monday.STOP + Vector3(-5.4, 0.0, -1.1), Monday.STOP + Vector3(-6.2, 1.35, -3.25))
		Audio.sfx("newspaper", -6.0)
		await _wait(1.0)
		var paper := monday.news_texture()
		if paper != null:
			await hud.spin_newspaper(paper, 2.6)
		else:
			await _wait(1.4)
		_cam(Monday.STOP + Vector3(1.5, 0.0, 6.0), Monday.STOP + Vector3(2.5, 2.4, -4.2))
	if T == "T2":
		await hud.say("SPK_DRIVER", "D15_S_T2")
	else:
		await hud.say("SPK_TOLGA", "D15_S_" + ({"W2": "W2", "W3": "W3", "W5": "W5", "W5B": "W5B", "W6": "W6", "W7": "W7", "W8": "W8", "W13": "W13", "W10": "W10", "W11": "W11", "W12": "W12"}.get(W, "W1") if not fixed else "FIXED"))
	if N == "N3":
		await hud.say("SPK_NIHAT", "D15_S_N3")
	await hud.fade_to(1.0, 0.6)
	# Ofis
	if T == "T2":
		_cam(Monday.TOLGA_DESK + Vector3(2.5, 0.0, 3.0), Monday.TOLGA_DESK + Vector3(0, 0.9, 0))
		await hud.fade_to(0.0, 0.8)
		monday.manager.talking = true
		await hud.say("SPK_MANAGER", "D15_O_T2")
		monday.manager.talking = false
		if H == "H3":
			await hud.say("SPK_TOLGA", "D15_O_T2_1453")
	else:
		_cam(Monday.OFFICE + Vector3(4.6, 0.0, 0.4), monday.manager.global_position + Vector3(0, 1.2, 0))
		await hud.fade_to(0.0, 0.8)
		monday.manager.talking = true
		if W in ["W6", "W10", "W11", "W12"] and not fixed:
			# Takvim değişti; ofiste kimse şaşırmıyor
			await hud.say("SPK_COWORKER_A", "D15_O_%s_A" % W)
			await hud.say("SPK_COWORKER_B", "D15_O_%s_B" % W)
		await hud.say("SPK_MANAGER", "D15_O_Q")
		monday.manager.talking = false
		if GameState.flags.get("honest_with_sultan", false):
			await hud.say("SPK_TOLGA", "D15_O_IDK")
			await _wait(1.2)
			await hud.say("SPK_MANAGER", "D15_O_IDK_2")
		else:
			await hud.say("SPK_TOLGA", "D15_O_DOCS")
			await hud.say("SPK_MANAGER", "D15_O_DOCS_2")
		if T == "T4":
			await hud.say("SPK_TOLGA", "D15_O_T4")
	await hud.fade_to(1.0, 0.6)


## 4. Final kartı
func _final_card() -> void:
	Audio.music("credits", 2.0)
	hud.fade_to(0.72, 0.8)   # final kartı açık renk ofisin üstünde okunsun
	var lines := [[tr("UI_CH15_FINAL_" + final_id.to_upper()), 50, Color("ffd24a")],
		[tr("UI_CH15_FINAL_" + final_id.to_upper() + "_SUB"), 20, Color(1, 1, 1, 0.8)],
		["", 12, Color.WHITE],
		[tr("UI_CH15_FATE_T") % tr("FATE_" + T), 20, Color("8ecbff")],
		[tr("UI_CH15_FATE_H") % tr("FATE_" + H), 20, Color("ffc98a")],
		[tr("UI_CH15_FATE_N") % tr("FATE_" + N), 20, Color("c9b8ff")],
		[tr("UI_CH15_FATE_W") % (tr("FATE_" + W) + (tr("UI_CH15_FIXED") if fixed else "")), 20, Color("f2e6c9")]]
	if GameState.flags.get("honest_with_sultan", false) and T in ["T1", "T4"]:
		lines.append([tr("UI_CH15_IDK_BADGE"), 18, Color("6ff2c8")])
	await hud.card(lines, 6.0)
	GameState.flags["final"] = final_id
	GameState.set_outcome(15, final_id)
	await _wait(1.0)
	hud.clear_card()
	await hud.card([[tr("UI_CH15_THE_END"), 40, Color("f2e6c9")], [tr("UI_CH15_THANKS"), 18, Color(1, 1, 1, 0.7)]], 4.0)


func _finish() -> void:
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	get_tree().change_scene_to_file("res://scenes/main.tscn")


# ================================================================ yardımcılar

func _title(key: String) -> void:
	hud.set_fade(1.0)
	await hud.card([[tr(key), 30, Color("f2e6c9")]], 1.6)
	hud.clear_card()


func _nihat_person() -> Person:
	return Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
		"hair": Color("3a2a1e"), "skin": Color("ecb892")})


func _tolga_person(pyjama := false) -> Person:
	return Person.new({"face": "tolga", "coat": Color("7fa7d6") if pyjama else Color("23262d"), "pants": Color("7fa7d6") if pyjama else Color("23262d"),
		"hat": "fez", "skin": Color("e6ad88")})


func _wait(s: float) -> void:
	if GameState.autotest:
		await get_tree().process_frame
		return
	await get_tree().create_timer(s).timeout


func _autotest_report() -> void:
	var expected: String = {"": "ordinary_monday", "missed": "empty_desk", "wrong": "another_year", "recruit": "night_shift",
		"w4": "sultans_repair", "forge": "off_the_books", "resign": "time_repair", "newmodel": "new_model",
		"pyjama": "pyjama_rescue", "stay": "two_neighbours", "leblebi": "nobody_noticed", "fixed": "fixed_mostly",
		"liar": "ordinary_monday", "boom": "big_bang", "gunner": "master_gunner",
		"w6": "envoy_to_venice", "w13": "tunnel_truce", "w8": "bureau_founding", "founder": "founding_member", "w7": "sultans_table", "w10": "one_more_year", "w11": "long_wait", "w12": "missing_paperwork"}[GameState.autotest_variant]
	var ok: bool = final_id == expected and GameState.chapter_outcomes.get(15, "") == final_id
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, final_id])
	print("AUTOTEST %s chapter=15 variant=%s final=%s T=%s H=%s N=%s W=%s fixed=%s" % ["PASS" if ok else "FAIL",
		GameState.autotest_variant, final_id, T, H, N, W, str(fixed)])
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
	monday = Monday.new("W2", false)
	add_child(monday)
	monday.bus.position = Monday.STOP + Vector3(-9.5, 0, 1.2)
	_cam(Monday.STOP + Vector3(1.5, 0.0, 6.0), Monday.STOP + Vector3(2.5, 2.4, -4.2))
	await get_tree().create_timer(0.8).timeout
	hud.bark("SPK_TOLGA", "D15_S_W2", 30.0)
	await _shot("c15_01_leblebipolis.png")
	_cam(Monday.OFFICE + Vector3(4.6, 0.0, 0.4), monday.manager.global_position + Vector3(0, 1.2, 0))
	monday.manager.talking = true
	hud.bark("SPK_TOLGA", "D15_O_IDK", 30.0)
	await get_tree().create_timer(0.5).timeout
	await _shot("c15_02_bilmiyorum.png")
	hud.bark("", "", 0.01)
	hud.set_fade(0.72)
	await hud.card([[tr("UI_CH15_FINAL_ORDINARY_MONDAY"), 50, Color("ffd24a")], [tr("UI_CH15_FINAL_ORDINARY_MONDAY_SUB"), 20, Color(1, 1, 1, 0.8)],
		["", 12, Color.WHITE], [tr("UI_CH15_FATE_T") % tr("FATE_T1"), 20, Color("8ecbff")], [tr("UI_CH15_FATE_H") % tr("FATE_H1"), 20, Color("ffc98a")],
		[tr("UI_CH15_FATE_N") % tr("FATE_N1"), 20, Color("c9b8ff")], [tr("UI_CH15_FATE_W") % tr("FATE_W1"), 20, Color("f2e6c9")]], 0.1)
	await get_tree().create_timer(0.8).timeout
	await _shot("c15_03_final.png")
	get_tree().quit()
