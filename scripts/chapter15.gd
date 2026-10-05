extends Node3D
## Bölüm 15 — Pazartesi (final). CHAPTERS Bölüm 15, §5 (kaderler), §7 (adlandırılmış finaller).
##
## Bütün kaderlerin birleştiği yer. Dört sahne:
##   1. Hikmet'in garajı (H1 / H2 / H3, N4 ortaklığı, W4 portresi, Pijamalı Kurtarma)
##   2. Nihat'ın masası (N1 / N2 / N3 / N4)
##   3. Servis durağı ve ofis (T1 / T2 / T4 × dünya). T1/T4 + honest_with_sultan: "Bilmiyorum" anı
##      T3 (Bölüm 13'te yanlış yıl): 1977, düğünün ertesi sabahı. Oynanır: gazete, iş ilanı, Emniyet Sigorta'da
##      mülakat; telsizde 2026'dan Hikmet'in kayan frekansı. Karar: kırmızı düğme (Geri Çağrı → 49 Yıl Geç) ya da
##      telsizi kapatıp kalmak (Başka Bir Yıl: Tolga 1977'de sigortacı olur, ilk poliçesini genç Hikmet'e yazar).
##   4. Final kartı: adlandırılmış final ve kaderlerin özeti
## Oyuncu çoğunlukla izleyicidir: kamera sahneden sahneye geçer. Seçim ve oynanış yalnız T3'ün 1977 sahnesindedir.
##   --autotest[=missed|wrong|wrong_recall|wrong_stay|recruit|w4|forge|resign|newmodel|pyjama|stay|leblebi|fixed|liar|card]  (card: 23'te İsmail'e verilen kartvizit Sinop'tan çıkar)
##   --autotest=people|people_osm   (İnsanların Akıbeti: Bizans tarafında on kişi iki kâğıtta, Osmanlı tarafında beş kişi)
##   (wrong = wrong_recall: T3, geri çağrılır)

var garage: Garage
var bureau: Bureau
var monday: Monday
var street: Street1977
var recalled := false      # T3: 1977'den kırmızı düğmeyle geri çağrıldı (49 Yıl Geç)
var _tuned := false        # T3: Hikmet garajda 1977 frekansını kilitledi (geri çağrı penceresi uzar)
var player: Player
var hud: Hud
var T := "T1"
var H := "H1"
var N := "N1"
var W := "W1"
var fixed := false
var final_id := ""
var _card_found := false   # Bölüm 23'te İsmail'e verilen kartvizit Sinop'tan çıktı (ofiste anılır)
var _people_pages := 0     # İnsanların Akıbeti kâğıt sayısı (autotest raporu)


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
		"wrong", "wrong_recall", "wrong_stay": f["tolga_fate"] = "T3"
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
		"evening":
			GameState.chapter_outcomes[12] = "12B.1"
			f["direnc"] = 1
			f["byz_reasserted"] = true
			f["world10"] = "W1"
		"eaves":
			for k in {17: "17.1", 24: "24.1", 27: "27.1"}.keys():
				GameState.chapter_outcomes[k] = {17: "17.1", 24: "24.1", 27: "27.1"}[k]
		"water":
			for k in {17: "17O.1", 22: "22O.1", 24: "24O.1"}.keys():
				GameState.chapter_outcomes[k] = {17: "17O.1", 22: "22O.1", 24: "24O.1"}[k]
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
		"leblebi":
			GameState.chapter_outcomes[12] = "12.2"
			f["nihat_fate"] = "N2"
		"fixed":
			GameState.chapter_outcomes[12] = "12.2"
			f["world_fixed"] = true
		"liar": f["honest_with_sultan"] = false
		"card":
			# 23'te elçi İsmail'e kartvizit verildi; kuşatmaya tanıklık edildi
			f["ismail_card"] = true
			f["siege_done"] = true
		"people", "people_osm":
			_people_setup(GameState.autotest_variant == "people_osm")
		"sealed":
			f["tolga_fate"] = "T2"
			f["machine"] = "confiscated"
			GameState.chapter_outcomes[13] = "13.2"
		"fates":
			# Eşyaların Akıbeti: bant üç yere, leblebi dört avuç (biter), küp Hüseyin'de, kolonya bir fıs
			for u in ["guards_tape_4a", "urban_cannon_6a", "breach_20"]:
				GameState.spend("tape", u)
			for u in ["kadri_leb_6a", "aga_leb_10o", "truce_10l", "mirko_leb_21"]:
				GameState.spend("chickpeas", u)
			GameState.give("cube", "guards", "cube_huseyin_4a")
			GameState.spend("cologne", "lutfi_cologne_6a")
			# Cep ve hediye zincirleri (M2): Haliç'in yedek fesi Hüseyin'e, Misafir İzni cepte; çakmak Giustiniani'ye
			# gidip 26'da geri gelir
			GameState.pocket_add("spare_fez", "fez_halic_2")
			GameState.pocket_give("spare_fez", "huseyin", "fez_huseyin_4a")
			GameState.pocket_add("guest_pass", "permit_6b")
			GameState.bag.append("lighter")
			GameState.give("lighter", "giustiniani", "lighter_giust_6b")
			GameState.gain("lighter", "giust_back_26")
			# M2b: izin üç kez işe yaradı (10H kefalet, 23 ikinci mühür, 25 İmparator'un helalliği); tezkire Fatih'ten,
			# 25'te nöbetçiye, 26'da Isidoros'u çıkardı; termos Kadri'de, 10Z'de tabağı, 24o'da çorbayı kurtardı
			for u in ["pass_10h", "pass_23", "pass_25"]:
				GameState.pocket_use("guest_pass", u)
			GameState.pocket_add("tezkire", "tezkire_12")
			for u in ["tezkire_25", "isidore_26"]:
				GameState.pocket_use("tezkire", u)
			if not "thermos" in GameState.bag:
				GameState.bag.append("thermos")
			GameState.give("thermos", "kadri", "thermos_kadri_6a")
			GameState.note_use("thermos", "kadri_dish_10z")
			GameState.note_use("thermos", "kadri_soup_24o")


## İnsanların Akıbeti testi (M5). Bizans tarafı: ikizler (fes, kefil), Kadri (yamaklık), Niko (zincir, fener, gedik,
## sel), Giustiniani (uyarıldı, dinlemedi), iki denizci, brigantin (tezkire, kaçış oyu, Morosini), Kasım (güven, kafile),
## İsmail (mektup), Marco (saçak, mum), Isidoros (Kasım'ın sözüyle Roma'ya): on kişi, iki kâğıt. Osmanlı tarafı:
## ikizler (köprü, kule), Kadri (ziyafet, kova, çorba, su), Urban (ad, bant), Ali (fusta, nişan), Cenevizli (şarap).
## Final sıradan pazartesi kalır (17.2 / 17O.2: tanığın iki tarafının finalleri oluşmaz).
func _people_setup(osm: bool) -> void:
	var f := GameState.flags
	var o := GameState.chapter_outcomes
	f["guards_like_tolga"] = true
	f["siege_side"] = "O" if osm else "B"
	if osm:
		o[10] = "10Z.1"
		f["ch10z_menu"] = [1, 2, 1]
		f["huseyin_carried"] = true
		f["cannon_name"] = 0
		f["gun_tape_20o"] = true
		f["siege_gun_hit"] = true
		f["toll_gift"] = "refuse"
		f["toll_hidden"] = true
		for k in {17: "17O.2", 18: "18.1", 20: "20O.1", 22: "22O.1", 24: "24O.1", 26: "26O.1", 27: "27.1", 32: "32O.1"}.keys():
			o[k] = {17: "17O.2", 18: "18.1", 20: "20O.1", 22: "22O.1", 24: "24O.1", 26: "26O.1", 27: "27.1", 32: "32O.1"}[k]
		return
	GameState.pocket_add("spare_fez", "fez_halic_2")
	GameState.pocket_give("spare_fez", "huseyin", "fez_huseyin_4a")
	f["huseyin_vouched"] = true
	f["niko_friend"] = true
	f["chain_watch"] = true
	f["giust_warned"] = true
	f["dawn_warned"] = true
	f["siege_saved"] = 2
	f["brig_vote"] = 1
	f["brig_tezkire"] = true
	f["siege21_talk"] = "talk"
	f["isidore_freed"] = true
	f["isidore_by"] = "kasim"
	f["met_isidore"] = true
	f["siege_kid"] = true
	f["siege_candle"] = true
	f["letter_delivered"] = true
	for k in {17: "17.2", 19: "19.1", 20: "20.1", 21: "21.1", 23: "23.1", 24: "24.1", 25: "25.1", 26: "26.1", 27: "27.2"}.keys():
		o[k] = {17: "17.2", 19: "19.1", 20: "20.1", 21: "21.1", 23: "23.1", 24: "24.1", 25: "25.1", 26: "26.1", 27: "27.2"}[k]


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
	# T3'te final 1977'deki karara bağlı: orada belirlenir (görülen finallere erken yazılmasın)
	if T != "T3":
		GameState.set_last_final(final_id)


## §7: birden fazla tutarsa üstteki kazanır.
func _named_final() -> String:
	var pyjama: bool = GameState.chapter_outcomes.get(13, "") == "13.4"
	if T == "T2" and H == "H3":
		return "two_neighbours"
	# Makineye el konulmuş (3.1) ve pencere kaçmışsa (13.2): Boş Masa'dan önce gelir (H2 ancak T2 ile oluşur;
	# aşağıda sırası gelse ulaşılamazdı)
	if T == "T2" and H == "H2":
		return "sealed_garage"
	if T == "T2":
		return "empty_desk"
	if T == "T3":
		return "late_by_49_years" if GameState.flags.get("recalled_1977", false) else "another_year"
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
	# Bizans'a yardım edildi ama kuşatmada tutmadı: fetih 1453'te oldu (Siege.resolve)
	if GameState.flags.get("byz_reasserted", false):
		return "one_evening"
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
	# Dünya değişti (Leblebipolis ya da Tavuk Sigorta) ve düzeltilmedi: kimse fark etmez
	if W in ["W2", "W3"] and not fixed:
		return "nobody_noticed"
	# Kuşatmada kimseyi bırakmadı: tanığın iki tarafının kendi finali (Bölüm 17, 22/24, 27)
	if eaves_child(GameState.chapter_outcomes):
		return "eaves_child"
	if water_bearer(GameState.chapter_outcomes):
		return "water_bearer"
	if N == "N2":
		return "off_the_books"
	if fixed:
		return "fixed_mostly"
	return "ordinary_monday"


## Bizans tarafı: üç denizciyi sudan çekti (17.1), seldeki çocuğu saçağa aldı (24.1), Galata'da insanlara "kal" dedi (27.1).
static func eaves_child(o: Dictionary) -> bool:
	return o.get(17, "") == "17.1" and o.get(24, "") == "24.1" and o.get(27, "") == "27.1"


## Osmanlı tarafı: kadırganın yangınını kova zinciriyle çabuk söndürdü (17O.1), yanan kuleden marangozları indirdi
## (22O.1), kanlı ay gecesi üç ateşin başındaki askerleri Kadri'nin çorbasıyla yatıştırdı (24O.1).
static func water_bearer(o: Dictionary) -> bool:
	return o.get(17, "") == "17O.1" and o.get(22, "") == "22O.1" and o.get(24, "") == "24O.1"


# ================================================================ sahneler

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH15_TITLE"), 48, Color("f2e6c9")], [tr("UI_CH15_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	await _scene_garage()
	await _scene_nihat()
	if T == "T3":
		await _scene_1977()
	else:
		await _scene_monday()
	await _item_fates()
	await _people_fates()
	await _final_card()
	if not _rewinding:
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
		# Garajda taburesinde oturur (çay, radyo); "(Kalkar)" deyince ayağa kalkar
		Props.cyl(garage, 0.2, 0.42, Garage.HIKMET_POS + Vector3(0, 0.21, -0.2), Color("6b4428"), Vector3.ZERO, 10)
		hikmet.rig.activity = "sit"
	_tea_table()          # H3: garaj boş, çay soğumuş (buharsız)
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
		"one_evening":
			key = "D15_G_EVENING" if _wall_tape() else "D15_G_EVENING_PLAIN"
		"eaves_child":
			key = "D15_G_EAVES"
		"water_bearer":
			key = "D15_G_WATER"
		"sealed_garage":
			m.visible = false
			Props.label(garage, "ZAMANATÖR 3001", Garage.PLATFORM_POS + Vector3(0, 0.05, 0), 36, Color("6ff2c8"), Vector3(-90, 0, 0), 1.4)
			key = "D15_G_H2"
	if H == "H3" and final_id != "two_neighbours":
		key = "D15_G_H3"
	if T == "T3":
		# Boş çerçevede 1977 düğününün fotoğrafı: başta mendilli genç Hikmet, kuyrukta fesli biri (Bölüm 13)
		garage.frame_inner.visible = false
		Props.picture(garage, "res://assets/art/posters/wedding_1977.svg", 0.72, Vector3(-2.6, 1.9, -Garage.D / 2 + 0.06))
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
	key = _peas_key(key)
	if GameState.flags.get("sinerji_2026", false):
		# Sinerji eklentisi: hangi final olursa olsun garajda bir tavuk
		var ch := Chicken.new()
		ch.position = Garage.HIKMET_POS + Vector3(0.9, 0, 0.9)
		add_child(ch)
	if key == "D15_G_H1" and W == "W1":
		Props.box(garage, Vector3(0.05, 1.3, 0.5), Vector3(Garage.W / 2.0 - 0.3, 1.2, 1.4), Color("7a3a8a"))
	await hud.fade_to(0.0, 0.8)
	if T == "T3" and hikmet:
		await _garage_1977(hikmet)
	else:
		if hikmet:
			hikmet.talking = true
			if key == "D15_G_H1":
				hikmet.emote("stir_cup")
		await hud.say("SPK_HIKMET", key)
		if hikmet:
			hikmet.talking = false
	if final_id == "pyjama_rescue":
		await hud.say("SPK_TOLGA", "D15_G_PYJAMA_T")
		# Radyoda o düğünün şarkısı (Bölüm 13'teki klarnet)
		Audio.music("wedding_1977", 1.5)
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
		# Masasında, sandalyesinde oturur (masanın içinde ayakta durmasın)
		nihat.position = Vector3(0.0, 0, 5.2)
		nihat.rotation.y = PI
		nihat.set_meta("no_unclip", true)
		add_child(nihat)
		nihat.set_activity("sit")
	_desk_files()
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
	if T == "T3" and nihat:
		# Masaya yeni bir dosya düşer: aynı fes, başka bir yıl
		var fp := Vector3(0.05, 0.83, 3.98)
		Props.box(bureau, Vector3(0.36, 0.02, 0.26), fp, Color("c8b07a"), Vector3(0, -8, 0))
		Props.label(bureau, "VAKA 1977-T", fp + Vector3(0, 0.012, 0.04), 30, Color("3a2a18"), Vector3(-90, 180 - 8, 0), 0.3)
		Props.label(bureau, "HALAY", fp + Vector3(0, 0.013, -0.06), 34, Color("c8262f"), Vector3(-90, 180 + 10, 0), 0.2)
		Audio.sfx("paper_tear", -16.0, 1.6)
		nihat.talking = true
		await hud.say("SPK_NIHAT", "D15_N_T3")
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
	monday.final_id = final_id
	add_child(monday)
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
		await hud.say("SPK_TOLGA", _peas_key("D15_S_" + ({"W2": "W2", "W3": "W3", "W5": "W5", "W5B": "W5B", "W6": "W6", "W7": "W7", "W8": "W8", "W13": "W13", "W10": "W10", "W11": "W11", "W12": "W12"}.get(W, "W1") if not fixed else "FIXED")))
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
			await hud.say("SPK_TOLGA", "D15_O_T2_1453" if "tape" in GameState.bag else "D15_O_T2_1453_TEA")
	else:
		_cam(Monday.MEET_CAM, monday.manager.global_position + Vector3(0, 1.2, 0))
		await hud.fade_to(0.0, 0.8)
		monday.manager.talking = true
		if W in ["W6", "W10", "W11", "W12"] and not fixed:
			# Takvim değişti; ofiste kimse şaşırmıyor
			await hud.say("SPK_COWORKER_A", "D15_O_%s_A" % W)
			await hud.say("SPK_COWORKER_B", "D15_O_%s_B" % W)
		elif final_id in ["one_evening", "eaves_child", "water_bearer"]:
			# Kuşatmanın izi: ofiste biri anlatır, Tolga kulaklıklıdır
			var k: String = {"one_evening": "EVENING", "eaves_child": "EAVES", "water_bearer": "WATER"}[final_id]
			await hud.say("SPK_COWORKER_A", "D15_O_EVENING_A_PLAIN" if k == "EVENING" and not _wall_tape() else "D15_O_%s_A" % k)
			await hud.say("SPK_COWORKER_B", "D15_O_%s_B" % k)
		await hud.say("SPK_MANAGER", "D15_O_Q")
		monday.manager.talking = false
		for c in monday.colleagues:
			c.look_target = player          # herkes Tolga'ya döner
		if GameState.flags.get("honest_with_sultan", false):
			await hud.say("SPK_TOLGA", "D15_O_IDK")
			await _wait(1.2)
			await hud.say("SPK_MANAGER", "D15_O_IDK_2")
		else:
			await hud.say("SPK_TOLGA", "D15_O_DOCS")
			await hud.say("SPK_MANAGER", "D15_O_DOCS_2")
		for c in monday.colleagues:
			c.look_target = monday.manager
		if T == "T4":
			await hud.say("SPK_TOLGA", "D15_O_T4")
		# Bölüm 23: elçi İsmail'e verilen kartvizit (ismail_card) beş yüz yıl sonra Sinop'ta bir yazmanın arasından çıkar
		if GameState.flags.get("ismail_card", false):
			_card_found = true
			await hud.say("SPK_COWORKER_B", "D15_O_CARD")
			await hud.say("SPK_TOLGA", "D15_O_CARD_T")
		await _siege_question()
	await hud.fade_to(1.0, 0.6)


## Kuşatmaya tanıklık ettiyse: müdür bir tuhaflık sezer (Büro'da bir ay, burada bir gece)
func _siege_question() -> void:
	if not GameState.flags.get("siege_done", false):
		return
	monday.manager.talking = true
	await hud.say("SPK_MANAGER", "D26_MG_ASK")
	monday.manager.talking = false
	var c := await hud.choose(["UI_C26_HONEST", "UI_C26_INSURER", "UI_C26_SILENT"], 0.0, 0)
	await hud.say("SPK_TOLGA", ["D26_T_HONEST", "D26_T_INSURER", "D26_T_SILENT"][c])
	monday.manager.talking = true
	await hud.say("SPK_MANAGER", ["D26_MG_HONEST", "D26_MG_INSURER", "D26_MG_SILENT"][c])
	monday.manager.talking = false
	GameState.flags["act4_answer"] = c


## 3b. Eşyaların Akıbeti: garajdan çıkan her eşyanın yolculuğu ve 2026'daki izi (ItemFates).
func _item_fates() -> void:
	var rows := ItemFates.rows()
	if rows.size() <= 2:
		return
	if GameState.autotest:
		for id in ItemFates.items():
			var j := ItemFates.journey(id)
			print("FATES %s end=%s steps=%s trace=%s" % [id, j["end"], ",".join(j["steps"]), ItemFates.trace(id) != ""])
	await _paper(rows, 9.0, 820.0)


## 3c. İnsanların Akıbeti: Tolga'nın yolunu değiştirdiği insanlar ve 2026'daki izleri (PeopleFates). Kişi çoksa iki kâğıt.
func _people_fates() -> void:
	var pages := PeopleFates.pages()
	if GameState.autotest:
		for p: Dictionary in PeopleFates.people():
			print("PEOPLE %s steps=%s trace=%s" % [p["name"], ",".join(p["steps"]), p["trace"]])
		_people_pages = pages.size()
	for rows: Array in pages:
		await _paper(rows, 9.0, 820.0)


## 4. Final kartı
func _final_card() -> void:
	Audio.music("credits", 2.0)
	hud.fade_to(0.72, 0.8)   # final kartı açık renk ofisin üstünde okunsun
	var lines := [[tr("UI_CH15_FINAL_" + final_id.to_upper()), 50, Color("ffd24a")],
		[tr(_final_sub_key()), 20, Color(1, 1, 1, 0.8)],
		["", 12, Color.WHITE],
		[tr("UI_CH15_FATE_T") % tr("FATE_T3_BACK" if T == "T3" and recalled else "FATE_" + T), 20, Color("8ecbff")],
		[tr("UI_CH15_FATE_H") % tr("FATE_" + H), 20, Color("ffc98a")],
		[tr("UI_CH15_FATE_N") % tr("FATE_" + N), 20, Color("c9b8ff")],
		[tr("UI_CH15_FATE_W") % (tr("FATE_" + W) + (tr("UI_CH15_FIXED") if fixed else "")), 20, Color("f2e6c9")]]
	if GameState.flags.get("flying_legend", false):
		lines.append([tr("UI_CH15_LEGEND"), 17, Color("c9b8ff")])
	if GameState.flags.get("nihat_seyyah", false):
		lines.append([tr("UI_CH15_SEYYAH"), 17, Color("6ff2c8")])
	if Quests.is_done("forms"):
		lines.append([tr("UI_CH15_FORMS"), 17, Color("ffe08a")])
	if GameState.flags.get("honest_with_sultan", false) and T in ["T1", "T4"]:
		lines.append([tr("UI_CH15_IDK_BADGE"), 18, Color("6ff2c8")])
	await hud.card(lines, 6.0)
	GameState.flags["final"] = final_id
	GameState.set_outcome(15, final_id)
	await _wait(1.0)
	hud.clear_card()
	await hud.card([[tr("UI_CH15_THE_END"), 40, Color("f2e6c9")]], 1.6)
	hud.clear_card()
	await _review()


## 5. Vaka Dosyası: bu final, oyuncunun yolu, kaçırılan finaller ve her birine doğrudan dönüş
var _rewinding := false


func _review() -> void:
	var r := FinalReview.new()
	r.final_id = final_id
	hud.add_child(r)
	if GameState.autotest:
		# Testte ekran kurulur (hata yakalanır) ve kapanır
		await get_tree().process_frame
		print("AUTOTEST review cards=%d" % r.find_children("*", "PanelContainer", true, false).size())
		r.queue_free()
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var res: Array = await r.finished
	r.queue_free()
	if res[0] == "rewind":
		_rewinding = true
		GameState.rewind_to(int(res[1]))


func _finish() -> void:
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	get_tree().change_scene_to_file("res://scenes/main.tscn")


# ================================================================ T3: 1977

const PHOTO := Vector3(-2.6, 1.9, -Garage.D / 2 + 0.06)
const RECALL_WINDOW := 5.0          # kırmızı düğme penceresi (sn); Hikmet frekansı kilitlediyse +4


## Garaj (T3): servis geldi gitti, evlât yok. Hikmet duvardaki düğün fotoğrafında kendini (halayın başında) ve
## kuyruktaki fesliyi görür; kalkar, frekansı 1977'ye ayarlar (oynanır: A/D, E) ve telsizden seslenir.
func _garage_1977(hikmet: Hikmet) -> void:
	hikmet.talking = true
	hikmet.emote("stir_cup")
	await hud.say("SPK_HIKMET", "D15_G_T3_1")
	_cam(Vector3(-1.9, 0.0, -1.25), PHOTO)
	await _wait(0.6)
	await hud.say("SPK_HIKMET", "D15_G_T3_2")
	await hud.say("SPK_HIKMET", "D15_G_T3_3")
	hikmet.talking = false
	# Kalkar, panelin başına geçer (platformun önünden dolaşarak)
	_cam(Garage.SPAWN_POS + Vector3(0.4, 0.0, 0.4), Garage.PLATFORM_POS + Vector3(0.4, 1.1, 0.4))
	hikmet.rig.activity = ""
	var front := garage.panel_node.global_position + garage.panel_node.global_transform.basis.z * 0.6
	front.y = 0.0
	for p: Vector3 in [Vector3(0.0, 0.0, 0.3), front]:
		hikmet.face_toward(p)
		var tw := create_tween()
		tw.tween_property(hikmet, "position", p, 0.05 if GameState.autotest else hikmet.position.distance_to(p) / 1.3)
		await tw.finished
	hikmet.face_toward(garage.panel_node.global_position)
	hikmet.talking = true
	await hud.say("SPK_HIKMET", "D15_G_T3_4")
	hikmet.talking = false
	_tuned = await _tune_1977()
	garage.panel_screen.text = "1977"
	if _tuned:
		var stw := create_tween()
		stw.tween_property(garage, "spin", 1.5, 1.2)
		garage.machine_light.light_energy = 1.6
	hikmet.talking = true
	await hud.say("SPK_HIKMET", "D15_G_T3_TUNED" if _tuned else "D15_G_T3_DRIFT")
	Audio.sfx("radio_static", -10.0)
	await hud.say("SPK_HIKMET", "D15_G_T3_CALL")
	hikmet.talking = false


## Zaman frekansı 1977'ye: Bölüm 13'teki kadran, ama hedef kayar (1977'nin sinyali bir yerde durmaz).
## Kilitlenmezse de oyun sürer: frekans kayık kalır, geri çağrı penceresi kısalır.
func _tune_1977() -> bool:
	var tuner := RadioTuner.new()
	tuner.label_text = tr("UI_CH15_TUNER")
	tuner.hint_text = tr("UI_TUNER_HINT")
	tuner.freq = 91.0
	hud.add_child(tuner)
	var vp := get_viewport().get_visible_rect().size
	tuner.position = Vector2((vp.x - tuner.size.x) / 2.0, vp.y * 0.1)
	var seconds := 16.0
	var left := seconds
	var t := 0.0
	var ok := false
	var prev_music := Audio.current_music()
	Audio.music("countdown", 0.5)
	while left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		t += dt
		tuner.target = 99.2 + sin(t * 0.7) * 2.2
		tuner.time_left = clampf(left / seconds, 0.0, 1.0)
		var dir := Input.get_axis("move_left", "move_right")
		if GameState.autotest:
			dir = 0.0
			tuner.freq = tuner.target
		tuner.freq = clampf(tuner.freq + dir * 4.0 * dt, 88.0, 108.0)
		var holding := Input.is_action_pressed("interact") or GameState.autotest
		if holding and tuner.strength() > 0.75:
			tuner.lock = minf(1.0, tuner.lock + dt * 1.0)
		else:
			tuner.lock = maxf(0.0, tuner.lock - dt * 0.5)
		if tuner.lock >= 1.0:
			ok = true
			break
	tuner.queue_free()
	Audio.music(prev_music, 1.0)
	return ok


## 1977, düğünün ertesi sabahı (Kurtuluş). Oynanır: gazete al, iş ilanlarına bak, Emniyet Sigorta'ya git.
## Yolda kahvehanenin radyosu ve cepteki telsiz cızırdar (2026'dan Hikmet). Mülakattan sonra telsiz net çeker: karar.
func _scene_1977() -> void:
	await _title("UI_CH15_S3_1977")
	street = Street1977.new()
	add_child(street)
	hud.set_cinematic(false)
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	player.gravity_on = true
	player.global_position = Street1977.SPAWN + Vector3(0, 0.05, 0)
	player.face(Vector3(-5.0, 1.5, 0.0))
	Audio.music("tender", 2.0)
	Audio.ambience("amb_city_day")
	await hud.fade_to(0.0, 1.0)
	await _t("D15_Y_T_01")
	await _t("D15_Y_T_02")
	# 1. Gazete: güney kaldırımındaki kulübe
	_free_walk(true)
	hud.set_objective(tr("UI_OBJ15_PAPER"), Street1977.KIOSK + Vector3(0, 1.5, 0))
	await _wait_interact("y_kiosk", "UI_PROMPT_Y_PAPER", Street1977.KIOSK + Vector3(0, 0, -1.3))
	_free_walk(false)
	hud.set_objective("")
	player.face(street.newsagent.global_position + Vector3(0, 1.55, 0))
	await _say("SPK_NEWSAGENT", "D15_Y_K_01", street.newsagent)
	await _t("D15_Y_T_03")
	await _say("SPK_NEWSAGENT", "D15_Y_K_02", street.newsagent)
	Audio.sfx("newspaper", -6.0)
	await _paper(ads_rows(), 5.0)
	await _t("D15_Y_T_04")
	# 2. Acente; kahvehanenin önünden geçerken telsiz cızırdar
	_free_walk(true)
	hud.set_objective(tr("UI_OBJ15_AGENCY"), Street1977.AGENCY_DOOR + Vector3(0, 2.2, 0))
	var heard := [false]
	Props.trigger(street, Street1977.KAHVE + Vector3(0, 1.0, 1.5), Vector3(7.0, 2.0, 3.0), func():
		heard[0] = true
		_kahve_radio())
	await _wait_near(Street1977.AGENCY_DOOR + Vector3(0, 0, -0.9), 1.0, Street1977.KAHVE + Vector3(0, 0, 1.5))
	if not heard[0]:
		heard[0] = true
		_kahve_radio()
	_free_walk(false)
	hud.set_objective("")
	# Mülakat: ziyaretçi sandalyesinde, Ferit Bey'in karşısında
	var ferit := street.ferit
	player.face(ferit.global_position + Vector3(0, 1.25, 0))
	await _say("SPK_AGENCY", "D15_Y_F_01", ferit)
	await hud.fade_to(1.0, 0.35)
	player.global_position = Street1977.VISITOR
	player.sit_view(true)
	await _wait(0.5)
	player.face(ferit.global_position + Vector3(0, 1.2, 0))
	await hud.fade_to(0.0, 0.4)
	await _t("D15_Y_T_05")
	await _say("SPK_AGENCY", "D15_Y_F_02", ferit)
	await _t("D15_Y_T_06")
	await _say("SPK_AGENCY", "D15_Y_F_03", ferit)
	await _t("D15_Y_T_07")
	await _say("SPK_AGENCY", "D15_Y_F_04", ferit)
	await _t("D15_Y_T_08")
	ferit.emote("laugh")
	await _say("SPK_AGENCY", "D15_Y_F_05", ferit)
	# Telsiz: bu sefer net. Hikmet frekansı tutuyor
	Audio.sfx("radio_static", -6.0)
	player.show_remote(true)
	hud.set_signal(4 if _tuned else 2)
	await hud.say("SPK_HIKMET", "D15_Y_H_RADIO_CALL" if _tuned else "D15_Y_H_RADIO_CALL_DRIFT")
	ferit.look_target = player
	await _say("SPK_AGENCY", "D15_Y_F_RADIO", ferit)
	await _t("D15_Y_T_RADIO")
	var want := 1 if GameState.autotest_variant == "wrong_stay" else 0
	var pick := await hud.choose(["UI_CH15_C_RECALL", "UI_CH15_C_STAY"], 12.0, want)
	var missed := false
	if pick == 0:
		recalled = await _recall_button()
		missed = not recalled
	GameState.flags["recalled_1977"] = recalled
	final_id = _named_final()
	GameState.set_last_final(final_id)
	if recalled:
		await _recall_ending()
	else:
		await _stay_ending(missed)
	hud.set_cinematic(true)


## Kahvehanenin önü: radyo cızırdar, cepteki telsizden kırık bir ses; kahveci söylenir. Akış beklemez.
func _kahve_radio() -> void:
	street.radio_flicker(true)
	Audio.sfx("radio_static", -8.0)
	hud.bark("SPK_HIKMET", "D15_Y_H_RADIO_1", 3.0)
	await _wait(3.0)
	if street == null:
		return
	hud.bark("SPK_TOLGA", "D15_Y_T_RADIO_2", 3.0)
	await _wait(3.0)
	if street == null:
		return
	street.kahveci.talking = true
	hud.bark("SPK_KAHVECI", "D15_Y_KV_3", 3.0)
	await _wait(2.5)
	if street != null:
		street.kahveci.talking = false


## Geri çağrı: pencere açıkken kırmızı düğme basılı tutulur (Bölüm 13'teki gibi); Hikmet 2026'da frekansı tutar.
func _recall_button() -> bool:
	var window := RECALL_WINDOW + (4.0 if _tuned else 0.0)
	var left := window
	var hold := 0.0
	const HOLD := 1.2
	hud.set_qte(tr("UI_CH13_PRESS"))
	hud.bark("SPK_HIKMET", "D15_Y_H_HOLD", 3.0)
	while left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		hud.set_chase(tr("UI_CH13_WINDOW") % ceili(left), left / window)
		var down := Input.is_action_pressed("red_button") or (GameState.autotest and left < window - 0.3)
		if down:
			hold += dt
			player.press_red(hold / HOLD)
		else:
			hold = maxf(0.0, hold - dt * 2.0)
			player.press_red(0.0)
		hud.set_red_progress(hold / HOLD)
		if hold >= HOLD:
			break
	hud.set_qte("")
	hud.set_chase("", 0.0)
	hud.set_red_progress(0.0)
	player.press_red(0.0)
	return hold >= HOLD


## Geri Çağrı (49 Yıl Geç): garaja iner, servis çoktan gitmiş; duvardaki düğün fotoğrafı yerinde kalır.
## Ofiste toplantının sonuna yetişir. Müdürün babası 1977'de Emniyet Sigorta'nın müdürüymüş.
func _recall_ending() -> void:
	await _t("D15_R_T_GO")
	await hud.fade_to(1.0, 0.6, Color.WHITE)
	street.queue_free()
	street = null
	player.sit_view(false)
	player.show_remote(false)
	player.gravity_on = false
	hud.set_cinematic(true)
	Audio.ambience("")
	garage = Garage.new()
	add_child(garage)
	garage.spin = 2.0
	for id in garage.items:
		(garage.items[id]["body"] as StaticBody3D).collision_layer = 0
	garage.frame_inner.visible = false
	Props.picture(garage, "res://assets/art/posters/wedding_1977.svg", 0.72, PHOTO)
	garage.panel_screen.text = "1977"
	# Bölüm 13'teki dönüş gibi: Tolga platformda, Hikmet karşısında (kapı tarafında), yüzü platforma
	var hikmet := Hikmet.new()
	hikmet.position = Garage.SPAWN_POS + Vector3(0, 0, -0.3)
	add_child(hikmet)
	hikmet.face_toward(Garage.PLATFORM_POS)
	_cam(Garage.PLATFORM_POS + Vector3(0, 0.12, 0), Garage.SPAWN_POS + Vector3(0, 1.4, 0))
	hikmet.look_target = player
	Audio.sfx("machine_jump", -6.0)
	await hud.fade_to(0.0, 1.2, Color.WHITE)
	var tw := create_tween()
	tw.tween_property(garage, "spin", 0.0, 2.0)
	await _say("SPK_HIKMET", "D15_R_H_1", hikmet)
	await _t("D15_R_T_2")
	await _say("SPK_HIKMET", "D15_R_H_3", hikmet)
	# Platformdan iner, duvardaki fotoğrafa bakar
	await hud.fade_to(1.0, 0.3)
	_cam(Vector3(-1.5, 0.0, -0.5), PHOTO + Vector3(0.35, -0.2, 0))
	hikmet.position = Vector3(-2.0, 0, -2.4)
	hikmet.face_toward(PHOTO)
	await hud.fade_to(0.0, 0.4)
	await _wait(0.8)
	await _t("D15_R_T_4")
	await _say("SPK_HIKMET", "D15_R_H_5", hikmet)
	await hud.fade_to(1.0, 0.6)
	garage.queue_free()
	garage = null
	hikmet.queue_free()
	# Ofis: toplantının sonu
	await _title("UI_CH15_S3_LATE")
	monday = Monday.new(W, fixed)
	monday.final_id = final_id
	add_child(monday)
	_cam(Monday.MEET_CAM, monday.manager.global_position + Vector3(0, 1.2, 0))
	await hud.fade_to(0.0, 0.8)
	for c in monday.colleagues:
		c.look_target = player          # geç kalan herkesin bakışını toplar
	await _say("SPK_MANAGER", "D15_R_M_1", monday.manager)
	await _t("D15_R_T_6")
	await _say("SPK_MANAGER", "D15_R_M_2", monday.manager)
	await _t("D15_R_T_7")
	await _say("SPK_MANAGER", "D15_R_M_3", monday.manager)
	for c in monday.colleagues:
		c.look_target = monday.manager
	await _siege_question()
	await hud.fade_to(1.0, 0.6)


## Başka Bir Yıl: Tolga telsizi kapatır (ya da pencere kaçar) ve acentede işe başlar. Bir hafta sonra genç Hikmet
## sarı elbiseli kızla gelir: ilk poliçe. 2026'da yaşlı Hikmet tezgâhın çekmecesinde o poliçeyi bulur.
func _stay_ending(missed: bool) -> void:
	var ferit := street.ferit
	if missed:
		await hud.say("SPK_HIKMET", "D15_S7_H_RADIO_LOST")
		await _t("D15_S7_T_LOST")
	else:
		await _t("D15_S7_T_OFF")
	Audio.sfx("radio_beep", -8.0)
	hud.set_signal(0)
	player.show_remote(false)
	await _say("SPK_AGENCY", "D15_S7_F_1", ferit)
	# Bir hafta sonra: Tolga kendi masasında, daktilonun başında
	await hud.fade_to(1.0, 0.6)
	player.global_position = Street1977.TOLGA_CHAIR
	player.sit_view(true)
	await hud.card([[tr("UI_CH15_WEEK_LATER"), 30, Color("f2e6c9")]], 1.6)
	hud.clear_card()
	var young := _young_hikmet()
	young.position = Street1977.AGENCY_DOOR + Vector3(0, 0, -0.5)
	street.add_child(young)
	var girl := Person.new({"coat": Color("f0d040"), "pants": Color("f0d040"), "skirt": true, "hat": "bun", "hair": Color("5a3418"), "skin": Color("ecc0a0")})
	girl.position = Street1977.AGENCY_DOOR + Vector3(0.6, 0, -0.4)
	girl.set_meta("no_talk", true)
	girl.set_meta("no_unclip", true)
	street.add_child(girl)
	player.face(Vector3(6.75, 0.95, -7.5))
	Audio.music("wedding_1977", 2.0)
	await hud.fade_to(0.0, 0.8)
	Audio.sfx("typewriter", -8.0)
	await _wait(0.8)
	# Kapıdan girerler; Tolga döner
	var spot := Vector3(9.25, 0, -7.2)
	for who: Person in [young, girl]:
		var to := spot if who == young else Vector3(9.7, 0, -6.4)
		who.face_toward(to)
		var tw := create_tween()
		tw.tween_property(who, "position", to, 0.05 if GameState.autotest else who.position.distance_to(to) / 1.2)
	await _wait(2.6)
	young.face_toward(player.global_position)
	girl.face_toward(player.global_position)
	young.look_target = player
	player.face(young.global_position + Vector3(0, 1.5, 0))
	await _say("SPK_HIKMET", "D15_S7_YH_1", young)
	await _t("D15_S7_T_2")
	young.look_target = girl
	girl.look_target = young
	await _say("SPK_HIKMET", "D15_S7_YH_3", young)
	young.look_target = player
	await _t("D15_S7_T_4")
	await _say("SPK_HIKMET", "D15_S7_YH_5", young)
	player.face(Vector3(6.75, 0.95, -7.5))
	Audio.sfx("typewriter", -6.0)
	await _t("D15_S7_T_6")
	Audio.sfx("typewriter_bell", -8.0)
	await hud.fade_to(1.0, 0.8)
	street.queue_free()
	street = null
	player.sit_view(false)
	player.gravity_on = false
	hud.set_cinematic(true)
	Audio.ambience("")
	# 2026: Hikmet tezgâhın çekmecesini açar
	await _title("UI_CH15_S1_2026")
	garage = Garage.new()
	add_child(garage)
	garage.spin = 0.0
	for id in garage.items:
		(garage.items[id]["body"] as StaticBody3D).collision_layer = 0
	garage.frame_inner.visible = false
	Props.picture(garage, "res://assets/art/posters/wedding_1977.svg", 0.72, PHOTO)
	garage.panel_screen.text = "1977"
	# Tezgâhın altında açık çekmece, içinde sararmış bir zarf
	var dr := Vector3(-2.95, 0.66, 0.35)
	Props.box(garage, Vector3(0.5, 0.14, 0.5), dr, Color("6b4428"))
	Props.box(garage, Vector3(0.42, 0.02, 0.3), dr + Vector3(0.0, 0.08, 0.0), Color("e8d8a8"), Vector3(0, 8, 0))
	var hikmet := Hikmet.new()
	hikmet.position = Vector3(-2.3, 0, 0.35)
	add_child(hikmet)
	hikmet.face_toward(dr)
	_cam(Vector3(-1.2, 0.0, 1.75), Vector3(-2.75, 1.0, 0.3))
	await hud.fade_to(0.0, 0.8)
	await _say("SPK_HIKMET", "D15_S7_H_1", hikmet)
	Audio.sfx("paper_tear", -14.0, 1.4)
	await _paper(policy_rows(), 5.0, 520.0)
	hikmet.face_toward(player.global_position)
	await _say("SPK_HIKMET", "D15_S7_H_2", hikmet)
	hikmet.emote("laugh")
	await _say("SPK_HIKMET", "D15_S7_H_3", hikmet)


## Genç Hikmet (1977): Bölüm 13'teki gibi açık mavi gömlek, kalın gözlük, gür siyah saç ve favoriler.
func _young_hikmet() -> Person:
	var y := Person.new({"coat": Color("7fa7d6"), "pants": Color("3a3a48"), "glasses": true, "hair": Color("1a1410"), "skin": Color("e8b894")})
	y.set_meta("spk", "SPK_HIKMET")
	y.set_meta("no_unclip", true)
	var yh: Node3D = y.get("_head")
	if yh == null:
		y.ready.connect(func(): _young_hair(y), CONNECT_ONE_SHOT)
	else:
		_young_hair(y)
	# Elinde iki ince belli çay
	var tea := Node3D.new()
	Props.cyl(tea, 0.05, 0.01, Vector3.ZERO, Color("f0ece4"), Vector3.ZERO, 10)
	Props.cyl(tea, 0.028, 0.08, Vector3(0, 0.045, 0), Color("a0301a"), Vector3.ZERO, 8, 0.022)
	y.ready.connect(func(): y.hold_item(tea), CONNECT_ONE_SHOT)
	return y


func _young_hair(y: Person) -> void:
	var yh: Node3D = y.get("_head")
	if yh == null:
		return
	Props.ball(yh, 0.235, Vector3(0, 0.07, -0.04), Color("1a1410"), Vector3(1.06, 0.82, 1.1), 10)
	Props.ball(yh, 0.12, Vector3(0.05, 0.16, 0.14), Color("1a1410"), Vector3(1.6, 0.45, 0.7), 8)
	for sx: float in [-1.0, 1.0]:
		Props.box(yh, Vector3(0.05, 0.14, 0.07), Vector3(sx * 0.2, -0.04, 0.05), Color("1a1410"))


## Gazetenin iş ilanları sayfası: üstte manşet, altta ilanlar; sigorta ilanı kırmızı halkalı.
static func ads_rows() -> Array:
	return [["UI_Y_PAPER_MAST", 30, Color("1d2330"), "title"], ["UI_Y_PAPER_DATE", 13, Color("5a5040"), ""],
		["UI_Y_PAPER_HEAD", 20, Color("b3262d"), "title"], ["UI_Y_PAPER_ADS", 18, Color("1d2330"), "rule"],
		["UI_Y_AD_1", 15, Color("2a2622"), ""], ["UI_Y_AD_INS", 16, Color("1d2330"), "circle"],
		["UI_Y_AD_2", 15, Color("2a2622"), ""], ["UI_Y_AD_3", 15, Color("2a2622"), ""]]


## 1977 poliçesi: Emniyet Sigorta, sigortalı Hikmet, acente T.; özel şartta kırmızı düğme.
static func policy_rows() -> Array:
	return [["UI_Y_POL_HEAD", 26, Color("1d2a4a"), "title"], ["UI_Y_POL_NO", 13, Color("5a5040"), "rule"],
		["UI_Y_POL_1", 16, Color("2a2622"), ""], ["UI_Y_POL_2", 16, Color("2a2622"), ""],
		["UI_Y_POL_3", 16, Color("b3262d"), "circle"], ["UI_Y_POL_SIGN", 22, Color("1a2a6a"), "sign"]]


## Kâğıt (gazete sayfası, poliçe): ekranın ortasında sararmış kâğıt, satır satır. Satır: [anahtar, boyut, renk, tür]
## tür: "title" (başlık yazısı), "rule" (altı çizgili), "circle" (kırmızı halka içinde), "sign" (sağa yaslı imza).
func _paper(rows: Array, hold: float, width := 580.0) -> void:
	var root := paper_panel(rows, width)
	hud.add_child(root)
	root.modulate.a = 0.0
	await get_tree().process_frame
	var vs := get_viewport().get_visible_rect().size
	var sz := root.get_combined_minimum_size()
	root.size = sz
	root.position = (vs - sz) * 0.5
	root.pivot_offset = sz * 0.5
	root.modulate.a = 1.0
	root.rotation = -0.025
	root.scale = Vector2(0.2, 0.2)
	var tw := create_tween()
	tw.tween_property(root, "scale", Vector2.ONE, 0.05 if GameState.autotest else 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished
	await _wait(hold)
	var out := create_tween()
	out.tween_property(root, "modulate:a", 0.0, 0.05 if GameState.autotest else 0.4)
	await out.finished
	root.queue_free()


## Kâğıdın kendisi (arayüz düğümü); ekran görüntüsü betikleri de kullanır.
static func paper_panel(rows: Array, width := 580.0) -> PanelContainer:
	var root := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("efe4c8")
	sb.set_content_margin_all(26)
	sb.set_corner_radius_all(3)
	sb.shadow_size = 14
	sb.shadow_color = Color(0, 0, 0, 0.55)
	root.add_theme_stylebox_override("panel", sb)
	root.custom_minimum_size = Vector2(width, 0)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	root.add_child(v)
	for r in rows:
		var l := Label.new()
		l.text = TranslationServer.translate(r[0])
		l.add_theme_font_size_override("font_size", r[1])
		l.add_theme_color_override("font_color", r[2])
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(width - 60, 0)
		if r[3] == "title":
			l.add_theme_font_override("font", load(Hud.FONT_TITLE))
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		elif r[3] == "sign":
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		if r[3] == "circle":
			var box := PanelContainer.new()
			var bs := StyleBoxFlat.new()
			bs.bg_color = Color(1, 1, 1, 0.0)
			bs.border_color = Color("c8262f")
			bs.set_border_width_all(3)
			bs.set_corner_radius_all(18)
			bs.set_content_margin_all(10)
			box.add_theme_stylebox_override("panel", bs)
			l.custom_minimum_size.x = width - 80
			box.add_child(l)
			v.add_child(box)
		else:
			v.add_child(l)
		if r[3] == "rule":
			var line := ColorRect.new()
			line.color = Color(0.2, 0.18, 0.15, 0.6)
			line.custom_minimum_size = Vector2(width - 60, 2)
			v.add_child(line)
	return root


## Serbest yürüme (1977 sokağı): fare yakalanır, oyuncu çözülür; kapatınca donar.
func _free_walk(on: bool) -> void:
	player.frozen = not on
	if on and not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## E ile etkileşim bekler (ipucu yazısıyla). Testte oyuncu durması gereken yere konur.
func _wait_interact(id: String, prompt_key: String, stand: Vector3) -> void:
	if GameState.autotest:
		player.global_position = stand + Vector3(0, 0.05, 0)
		await get_tree().physics_frame
		return
	var got := [false]
	var on_use := func(i: String) -> void:
		if i == id:
			got[0] = true
	var on_focus := func(i: String) -> void:
		hud.set_prompt(tr(prompt_key) if i == id else "")
	player.interacted.connect(on_use)
	player.focus_changed.connect(on_focus)
	while not got[0]:
		await get_tree().process_frame
	player.interacted.disconnect(on_use)
	player.focus_changed.disconnect(on_focus)
	hud.set_prompt("")


## Bir noktaya (yatayda r metre) varılmasını bekler. Testte önce ara noktadan (via) geçirilir, sonra hedefe konur.
func _wait_near(pos: Vector3, r: float, via := Vector3.INF) -> void:
	if GameState.autotest:
		if via != Vector3.INF:
			player.global_position = via + Vector3(0, 0.05, 0)
			for i in 3:
				await get_tree().physics_frame
		player.global_position = pos + Vector3(0, 0.05, 0)
		await get_tree().physics_frame
		return
	while Vector2(player.global_position.x - pos.x, player.global_position.z - pos.z).length() > r:
		await get_tree().process_frame


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


## Konuşan sahnedeyse (kişi ya da Hikmet) konuşurken ağzı oynar.
func _say(speaker: String, key: String, who: Node3D = null) -> void:
	if who and is_instance_valid(who):
		who.set("talking", true)
	await hud.say(speaker, key)
	if who and is_instance_valid(who):
		who.set("talking", false)


# ================================================================ yardımcılar

## Hikmet'in taburesinin yanında çay (Bölüm 3'teki "Buyrun çay"ın garajdaki hali)
func _tea_table() -> void:
	# Taburenin yanında küçük sehpa: ince belli çay bardağı, tabağı, buharı
	var tp := Garage.HIKMET_POS + Vector3(0.55, 0, 0.1)
	Props.cyl(garage, 0.2, 0.03, tp + Vector3(0, 0.55, 0), Color("6b4428"), Vector3.ZERO, 12)
	Props.cyl(garage, 0.03, 0.54, tp + Vector3(0, 0.27, 0), Color("4a3020"), Vector3.ZERO, 6)
	Props.cyl(garage, 0.055, 0.01, tp + Vector3(0, 0.57, 0), Color("f0ece4"), Vector3.ZERO, 10)
	Props.cyl(garage, 0.03, 0.085, tp + Vector3(0, 0.62, 0), Color("a0301a"), Vector3.ZERO, 8, 0.024)
	if H != "H3":
		var steam := Props.ball(garage, 0.04, tp + Vector3(0, 0.74, 0), Color(1, 1, 1, 0.35), Vector3(1, 2.2, 1), 6)
		steam.material_override = Props.mat(Color(1, 1, 1, 0.3), 0.0, true, "", false)
		var stw := steam.create_tween().set_loops()
		stw.tween_property(steam, "position:y", tp.y + 0.86, 1.6).from(tp.y + 0.7)


## Nihat'ın masası: kapanan vaka (1453-T, kırmızı KAPANDI mührü) ve sıradaki vaka yığını
## (1204-K: Dördüncü Haçlı Seferi'nin Konstantinopolis'i yağmalaması; "uzun sürecek").
func _desk_files() -> void:
	var dz := 4.3
	var fz := Vector3(-0.35, 0.83, dz - 0.1)
	Props.box(bureau, Vector3(0.36, 0.02, 0.26), fz, Color("d8b878"), Vector3(0, 6, 0))
	Props.label(bureau, "VAKA 1453-T", fz + Vector3(0, 0.012, 0.05), 30, Color("3a2a18"), Vector3(-90, 180 + 6, 0), 0.3)
	if N != "N4":
		Props.label(bureau, "KAPANDI", fz + Vector3(0.02, 0.013, -0.05), 40, Color("c8262f"), Vector3(-90, 180 - 14, 0), 0.26)
	if N == "N1":
		var sp := Vector3(-0.85, 0.82, dz + 0.1)
		for k in 9:
			Props.box(bureau, Vector3(0.34, 0.035, 0.25), sp + Vector3(randf_range(-0.02, 0.02), 0.02 + k * 0.037, 0), [Color("c8a868"), Color("b89858"), Color("d8c088")][k % 3], Vector3(0, randf_range(-6, 6), 0))
		Props.box(bureau, Vector3(0.2, 0.08, 0.005), sp + Vector3(0, 0.2, -0.13), Color("f4f1ea"))
		Props.label(bureau, "1204-K\nHAÇLILAR", sp + Vector3(0, 0.2, -0.134), 24, Color("2a4a8a"), Vector3(0, 180, 0), 0.18)


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
	var expected: String = {"": "ordinary_monday", "missed": "empty_desk", "wrong": "late_by_49_years", "wrong_recall": "late_by_49_years",
		"wrong_stay": "another_year", "recruit": "night_shift",
		"w4": "sultans_repair", "forge": "off_the_books", "resign": "time_repair", "newmodel": "new_model",
		"pyjama": "pyjama_rescue", "stay": "two_neighbours", "leblebi": "nobody_noticed", "fixed": "fixed_mostly",
		"liar": "ordinary_monday", "boom": "big_bang", "gunner": "master_gunner",
		"w6": "envoy_to_venice", "w13": "tunnel_truce", "w8": "bureau_founding", "founder": "founding_member", "w7": "sultans_table", "w10": "one_more_year", "w11": "long_wait", "w12": "missing_paperwork", "sealed": "sealed_garage", "evening": "one_evening", "eaves": "eaves_child", "water": "water_bearer", "fates": "ordinary_monday", "card": "ordinary_monday",
		"people": "ordinary_monday", "people_osm": "ordinary_monday"}[GameState.autotest_variant]
	if GameState.autotest_variant == "" and T == "T3":
		expected = "late_by_49_years"     # zincirle gelen T3 (Bölüm 13 wrong_next): varsayılan seçim geri çağrı
	var ok: bool = final_id == expected and GameState.chapter_outcomes.get(15, "") == final_id
	ok = ok and _card_found == (GameState.autotest_variant == "card")
	# Eşyaların Akıbeti: bant ve leblebi bitti, küp Hüseyin'de, kolonya çantada; her birinin 2026 izi var
	if GameState.autotest_variant == "fates":
		ok = ok and ItemFates.journey("tape")["end"] == "empty" and ItemFates.journey("cube")["end"] == "given" \
			and ItemFates.journey("cologne")["end"] == "kept" and ItemFates.trace("tape") != "" and ItemFates.trace("cube") != "" \
			and ItemFates.journey("spare_fez")["end"] == "given" and ItemFates.trace("spare_fez") != "" \
			and ItemFates.journey("guest_pass")["end"] == "kept" and ItemFates.trace("guest_pass") == tr("FATE26_GUEST_PASS_PASS_25") \
			and ItemFates.journey("lighter")["end"] == "kept" and ItemFates.trace("lighter") == tr("FATE26_LIGHTER_GIUST_BACK_26") \
			and ItemFates.journey("tezkire")["end"] == "kept" and ItemFates.trace("tezkire") == tr("FATE26_TEZKIRE_ISIDORE_26") \
			and ItemFates.journey("thermos")["end"] == "given" and ItemFates.trace("thermos") == tr("FATE26_THERMOS_KADRI_SOUP_24O")
	# İnsanların Akıbeti: yalnız Tolga'nın dokunduğu kişiler, adımları oynanış sırasıyla; Bizans tarafı iki kâğıt
	var people := {}
	for p: Dictionary in PeopleFates.people():
		people[p["name"]] = p
	if GameState.autotest_variant == "people":
		ok = ok and people.size() == 10 and _people_pages == 2 and not people.has("PF_GENOESE") and not people.has("PF_ALI") \
			and people["PF_TWINS"]["steps"] == ["PF_TWINS_FRIENDS", "PF_TWINS_FEZ", "PF_TWINS_VOUCH"] \
			and people["PF_KADRI"]["steps"] == ["PF_KADRI_APPRENTICE"] \
			and people["PF_NIKO"]["steps"] == ["PF_NIKO_FRIEND", "PF_NIKO_CHAIN", "PF_NIKO_LANTERN", "PF_NIKO_BREACH", "PF_NIKO_KID"] \
			and people["PF_GIUST"]["steps"] == ["PF_GIUST_WARNED", "PF_GIUST_WARN_HURT"] and people["PF_GIUST"]["trace"] == "PF26_GIUST" \
			and people["PF_SAILORS"]["steps"].size() == 2 and people["PF_BRIG"]["trace"] == "PF26_BRIG_SAILED" \
			and people["PF_BRIG"]["steps"] == ["PF_BRIG_TEZKIRE", "PF_BRIG_FLEE", "PF_BRIG_SAILED"] \
			and people["PF_KASIM"]["steps"] == ["PF_KASIM_TALK", "PF_KASIM_FREE"] \
			and people["PF_ISMAIL"]["steps"] == ["PF_ISMAIL_LETTER"] and people["PF_ISMAIL"]["trace"] == "" \
			and people["PF_MARCO"]["steps"] == ["PF_MARCO_EAVES", "PF_MARCO_CANDLE"] \
			and people["PF_ISIDORE"]["steps"] == ["PF_ISIDORE_LITURGY", "PF_ISIDORE_KASIM", "PF_ISIDORE_ROME"] \
			and people["PF_ISIDORE"]["trace"] == "PF26_ISIDORE_KASIM"
	elif GameState.autotest_variant == "people_osm":
		ok = ok and _people_pages == 1 and not people.has("PF_NIKO") and not people.has("PF_ISIDORE") \
			and people["PF_TWINS"]["steps"] == ["PF_TWINS_FRIENDS", "PF_TWINS_BRIDGE", "PF_TWINS_TOWER"] \
			and people["PF_KADRI"]["steps"] == ["PF_KADRI_APPRENTICE", "PF_KADRI_FEAST", "PF_KADRI_BUCKETS", "PF_KADRI_SOUP", "PF_KADRI_WATER"] \
			and people["PF_URBAN"]["steps"] == ["PF_URBAN_NAME_1", "PF_URBAN_TAPE_20O"] and people["PF_URBAN"]["trace"] == "PF26_URBAN_NAME_1" \
			and people["PF_ALI"]["steps"] == ["PF_ALI_HIT", "PF_ALI_MARKSMAN"] \
			and people["PF_GENOESE"]["steps"] == ["PF_GENOESE_FOUND", "PF_GENOESE_REFUSE", "PF_GENOESE_STAYED"]
	if T == "T3" and bool(GameState.flags.get("recalled_1977", false)) != (final_id == "late_by_49_years"):
		ok = false
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
	# Garaj ve Nihat'ın masası
	garage = Garage.new()
	add_child(garage)
	garage.spin = 0.0
	var hk := Hikmet.new()
	hk.position = Garage.HIKMET_POS
	add_child(hk)
	hk.rig.activity = "sit"
	Props.cyl(garage, 0.2, 0.42, Garage.HIKMET_POS + Vector3(0, 0.21, -0.2), Color("6b4428"), Vector3.ZERO, 10)
	_tea_table()
	_cam(Garage.SPAWN_POS + Vector3(0.4, 0.0, 0.4), Garage.PLATFORM_POS + Vector3(-0.6, 1.2, 0))
	await get_tree().create_timer(0.8).timeout
	hud.bark("SPK_HIKMET", "D15_G_H1", 30.0)
	await _shot("c15_00a_garaj.png")
	garage.queue_free()
	hk.queue_free()
	bureau = Bureau.new()
	add_child(bureau)
	var nh := _nihat_person()
	nh.position = Vector3(0.0, 0, 5.2)
	nh.rotation.y = PI
	add_child(nh)
	nh.set_activity("sit")
	_desk_files()
	_cam(Vector3(0.9, 0.0, 1.8), Vector3(0, 1.3, 4.6))
	await get_tree().create_timer(0.8).timeout
	hud.bark("SPK_NIHAT", "D15_N_N1", 30.0)
	await _shot("c15_00b_nihat.png")
	bureau.queue_free()
	nh.queue_free()
	await get_tree().process_frame
	monday = Monday.new("W2", false)
	add_child(monday)
	monday.bus.position = Monday.STOP + Vector3(-9.5, 0, 1.2)
	_cam(Monday.STOP + Vector3(1.5, 0.0, 6.0), Monday.STOP + Vector3(2.5, 2.4, -4.2))
	await get_tree().create_timer(0.8).timeout
	hud.bark("SPK_TOLGA", "D15_S_W2", 30.0)
	await _shot("c15_01_leblebipolis.png")
	_cam(Monday.MEET_CAM, monday.manager.global_position + Vector3(0, 1.2, 0))
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


## Surda 570 yıllık bant: heyet gecesi gedik (10H) ya da 7 Mayıs gecesi gedik (20.2) bantlandıysa.
func _wall_tape() -> bool:
	return GameState.flags.get("breach_taped", false) or GameState.flags.get("breach_night_taped", false)


## Final kartının alt yazısı yalnız gerçekten yaşananı anar: dolaptaki kaftan, surdaki bant, leblebili pilav.
func _final_sub_key() -> String:
	var k := "UI_CH15_FINAL_" + final_id.to_upper() + "_SUB"
	var plain := false
	match final_id:
		"ordinary_monday":
			plain = not GameState.flags.get("has_kaftan", false)
		"one_evening":
			plain = not _wall_tape()
		"sultans_table":
			plain = not GameState.flags.get("leblebi_given", false)
	return k + "_PLAIN" if plain else k


## Leblebili dünya izleri yalnız leblebi gerçekten 1453'e girdiyse: Kadri'nin pilavı (Bölüm 6/10Z), tüneldeki leblebi (10L).
func _peas_key(key: String) -> String:
	if key in ["D15_G_W7", "D15_S_W7"] and not GameState.flags.get("leblebi_given", false):
		return key + "_PLAIN"
	if key == "D15_G_W13" and not GameState.flags.get("tunnel_leblebi", false):
		return key + "_PLAIN"
	return key
