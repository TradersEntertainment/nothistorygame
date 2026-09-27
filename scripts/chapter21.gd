extends Node3D
## Bölüm 21 — Lağım (Tolga · 16 Mayıs 1453, Mesoteichion ve toprağın altı). docs/SIEGE.md §3.
##
## Zağanos Paşa'nın Novo Brdo'lu madencileri surların altına lağım kazar; mühendis Johannes Grant karşı lağımla
## bulur (ilki 16 Mayıs gecesi; kaynaklar yere konan su kaplarının kazı titreşimiyle dalgalandığını anlatır).
## Oynanış 1: Peribolosta dört su kabı. Tolga'nın telefonundaki deprem uygulaması (şarjı powerbank'ten) sıcak-soğuk
##   gösterir; kabı toprağa koy (E), en çok dalgalanan kabın altı lağımdır. Tespit karesi: Grant'in su kapları.
## Oynanış 2: Karşı lağım: mum ışığında dar tünel. Kazı yüzünü dinle; duvar açılır, karşıda bir madenci.
##   Madencinin (Mirko) arkasından bir yeniçeri seslenir; süreli seçim: sus işareti (leblebi) ya da kaç ve Grant'e bağır.
##   Susarsa madenci kendi tarafına "kaya çıktı" diye yalan söyler, çekilir. Kaçarsa arbede: yeniçeri koşar, Grant ateş
##   kabı atar. İki yolda da Grant'in adamları tüneli ateşle kapatır.
## Oynanış 3: 23 Mayıs. Grant'in adamları bir Osmanlı lağımında lağımcıbaşı Kasım'ı esir aldı (kaynaklar: esirler
##   işkence altında öbür lağımların yerini söyledi). Türkçe bilen Tolga tercümandır: Grant'in sözlerini aynen ya da
##   yumuşatarak çevirir. Güven kurulursa Kasım adamlarının çıkarılması sözüyle konuşur; kurulamazsa Grant onu içeri
##   götürür, kapı kapanır (ekranda gösterilmez), sabah yerler bellidir.
##   21.1 Lağımı Tolga'nın kabı buldu · 21.2 Kaplar tükendi, Grant kendisi buldu
##   --autotest[=grant|fight]   (varsayılan: 21.1, sus, konuşur · fight: kaç, sert çeviri, kapı kapanır)

const MINE := Vector3(-9.0, 0.0, 7.0)
const BOWLS := 4
const FOUND_R := 2.6
const TUN := Vector3(60.0, -30.0, 0.0)
const TUN_LEN := 16.0
const CAP := Vector3(60.0, -30.0, 40.0)      # 23 Mayıs: Grant'in karşı lağımının başındaki oda

var walls: LandWalls
var player: Player
var hud: Hud
var grant: Person
var miner: Person
var phase := "intro"
var _outcome := ""
var bowls_left := BOWLS
var bowls: Array = []           # {node, ripple, strength}
var found := false
var found_by_bowl := false
var _photo := ""
var cam: TespitCam
var _meter: Control
var _heat := 0.0
var _face: Node3D
var _tunnel_lights: Array = []
var _t := 0.0
var _candle: Node3D
var _candle_flame: MeshInstance3D
var _candle_light: OmniLight3D
var _taps_on := false
var _tunnel_way := ""            # "hush" | "leb" | "fight"
var _talk := ""                  # "talk" (güvenle konuştu) | "iron" (içeri götürüldü)
var _trust := 0
var jan: Person                  # madencinin arkasındaki yeniçeri
var _jan_lamp: OmniLight3D
var kasim: Person
var _ropes: Array[Node3D] = []
var _tap_t := 1.5


func _ready() -> void:
	GameState.snapshot(21)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	walls = LandWalls.new()
	add_child(walls)
	walls.set_repair(LandWalls.STAGES)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	grant = Person.new({"coat": Color("5a5a62"), "pants": Color("3a3a40"), "hat": "none", "beard": true, "hair": Color("8a5a2a"),
		"apron": Color("3a3028"), "skin": Color("e8b894")})
	grant.set_meta("spk", "SPK_GRANT")
	grant.position = Vector3(-4.0, 0, 3.0)
	add_child(grant)
	grant.look_target = player
	# Grant'in kendi kapları (sırada bekleyen, boş)
	for i in 4:
		Props.cyl(self, 0.22, 0.12, Vector3(-5.2 + i * 0.5, 0.06, 1.8), Color("9a6a40"), Vector3.ZERO, 10, 0.27)
	# Telefon deprem ölçeri (sağ alt): titreşim çizgisi ve sıcaklık çubuğu
	_meter = Control.new()
	_meter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_meter.visible = false
	_meter.draw.connect(_draw_meter)
	hud.add_child(_meter)
	_build_tunnel()
	# Garnizon: surlarda nöbetçiler; peribolosun uçlarında ateş başında yedekler (lağım dinlenen yerden uzak)
	Garrison.land_walls(self, [], [Vector2(-32.0, 32.0)], [], 21)
	for spec in [[Vector3(-23.0, 0, 9.0), 5], [Vector3(22.0, 0, 8.0), 4]]:
		walls.lights.append(Garrison.fire_ring(self, spec[0], spec[1], 2100 + int(spec[0].x)))


## Karşı lağım: dar, destekli, mumlu bir tünel ve sonunda kazı yüzü.
func _build_tunnel() -> void:
	var t := TUN
	Props.solid(self, Vector3(2.6, 0.2, TUN_LEN + 6.0), t + Vector3(0, -0.1, -TUN_LEN * 0.5), Color("4a3828"))
	Props.solid(self, Vector3(2.6, 0.2, TUN_LEN + 6.0), t + Vector3(0, 2.3, -TUN_LEN * 0.5), Color("2a1e14"))
	for sx: float in [-1.2, 1.2]:
		Props.set_pattern(Props.solid(self, Vector3(0.2, 2.4, TUN_LEN + 6.0), t + Vector3(sx, 1.1, -TUN_LEN * 0.5), Color.WHITE), Color("5a4430"), "plaster")
	Props.solid(self, Vector3(2.6, 2.4, 0.3), t + Vector3(0, 1.1, 2.8), Color("3a2a1e"))
	var z := 0.0
	while z > -TUN_LEN:
		for sx: float in [-1.0, 1.0]:
			Props.cyl(self, 0.08, 2.2, t + Vector3(sx, 1.1, z), Color("6a4a2c"), Vector3.ZERO, 5)
		Props.box(self, Vector3(2.2, 0.16, 0.16), t + Vector3(0, 2.15, z), Color("6a4a2c"))
		z -= 2.5
	for i in 4:
		var cp := t + Vector3(-0.95 if i % 2 == 0 else 0.95, 1.2, -1.5 - i * 4.0)
		Props.cyl(self, 0.03, 0.18, cp, Color("f4ecd0"), Vector3.ZERO, 5)
		var fl := Props.ball(self, 0.03, cp + Vector3(0, 0.12, 0), Color("ffc860"), Vector3(1, 1.6, 1), 5, 3.0)
		fl.material_override = Props.mat(Color("ffc860"), 3.0, false, "", false)
		var l := OmniLight3D.new()
		l.position = cp + Vector3(0, 0.3, 0)
		l.light_color = Color("ffb060")
		l.light_energy = 1.4
		l.omni_range = 5.0
		add_child(l)
		_tunnel_lights.append(l)
	_face = Node3D.new()
	_face.position = t + Vector3(0, 0, -TUN_LEN - 0.2)
	add_child(_face)
	Props.set_pattern(Props.solid(_face, Vector3(2.4, 2.4, 0.4), Vector3(0, 1.1, 0), Color.WHITE), Color("5a4430"), "plaster")
	Props.interactable(_face, "face", Vector3(2.0, 2.0, 0.8), Vector3(0, 1.1, 0.5))
	# Kazı yüzünün ardı: kısa Osmanlı lağımı (kapalı, karanlık), madenci
	var ot := t + Vector3(0, 0, -TUN_LEN - 3.4)
	Props.solid(self, Vector3(2.4, 0.2, 6.0), ot + Vector3(0, -0.1, 0), Color("3a2a1e"))
	Props.solid(self, Vector3(2.4, 0.2, 6.0), ot + Vector3(0, 2.3, 0), Color("22180f"))
	for sx: float in [-1.1, 1.1]:
		Props.solid(self, Vector3(0.2, 2.4, 6.0), ot + Vector3(sx, 1.1, 0), Color("3a2a1e"))
	Props.solid(self, Vector3(2.4, 2.4, 0.2), ot + Vector3(0, 1.1, -3.0), Color("22180f"))
	for bz: float in [-1.5, 0.5, 2.5]:
		Props.box(self, Vector3(2.0, 0.14, 0.14), ot + Vector3(0, 2.1, bz), Color("5a3e26"))
	# Kazı yüzünün ardı: Osmanlı lağımı ve madenci (duvar açılınca görünür)
	# Sultan'ın lağımcısı (Novo Brdo'lu Sırp madenci): Balkan kalpağı, kırmızı-kahve kaftan, bıyıklı, sakalsız;
	# Grant'ten (başı açık, sakallı, gri) ilk bakışta ayrılsın
	miner = Person.new({"coat": Color("8a3a26"), "pants": Color("d8ccb0"), "hat": "kalpak", "beard": false, "mustache": true,
		"hair": Color("2a1e14"), "skin": Color("c89070")})
	miner.set_meta("spk", "SPK_NOVOMINER")
	miner.position = t + Vector3(0.2, 0, -TUN_LEN - 2.2)
	miner.visible = false
	add_child(miner)
	# Madencinin ardında, Osmanlı lağımının dibinde bir yeniçeri (başta görünmez; kandil ışığı önce gelir)
	jan = Person.new({"coat": Color("b3262d"), "pants": Color("3a3028"), "hat": "bork", "mustache": true, "beard": false, "n": 2170})
	jan.set_meta("spk", "SPK_JANISSARY")
	jan.position = t + Vector3(-0.4, 0, -TUN_LEN - 5.8)
	jan.visible = false
	add_child(jan)
	jan.equip("spear")
	_jan_lamp = OmniLight3D.new()
	_jan_lamp.position = t + Vector3(0, 1.4, -TUN_LEN - 5.6)
	_jan_lamp.light_color = Color("ffa050")
	_jan_lamp.light_energy = 0.0
	_jan_lamp.omni_range = 4.0
	add_child(_jan_lamp)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH21_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH21_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = Vector3(-2.0, 0.05, 5.0)
	player.face(grant.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_GRANT", "D21_G_01")
	await hud.say("SPK_TOLGA", "D21_T_01")
	await hud.say("SPK_GRANT", "D21_G_02")
	await hud.say("SPK_NIHAT", "D21_N_01")
	phase = "bowls"
	_meter.visible = true
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		_auto_bowls()
	while phase == "bowls":
		await get_tree().process_frame
	player.frozen = true
	await _found()
	await _tunnel()
	await _end_chapter()


func _update_objective() -> void:
	if phase == "bowls":
		hud.set_objective(tr("UI_OBJ21_BOWLS") % bowls_left)


func _place_bowl(at: Vector3) -> void:
	if bowls_left <= 0 or phase != "bowls":
		return
	bowls_left -= 1
	var b := Node3D.new()
	b.position = Vector3(at.x, 0.0, at.z)
	add_child(b)
	Props.cyl(b, 0.22, 0.12, Vector3(0, 0.06, 0), Color("9a6a40"), Vector3.ZERO, 10, 0.27)
	var water := Props.cyl(b, 0.2, 0.01, Vector3(0, 0.115, 0), Color("4a78a8"), Vector3.ZERO, 12)
	var ripple := Props.ring(b, 0.05, 0.08, Vector3(0, 0.125, 0), Color("c8e0f8"), Vector3(90, 0, 0))
	var d := Vector2(at.x - MINE.x, at.z - MINE.z).length()
	var strength := clampf(1.0 - d / 10.0, 0.0, 1.0)
	bowls.append({"node": b, "water": water, "ripple": ripple, "strength": strength})
	player.hand_gesture("reach")
	Audio.sfx("splash", -18.0, 1.6)
	if d <= FOUND_R:
		found = true
		found_by_bowl = true
		phase = "found"
	elif bowls_left <= 0:
		found = true
		phase = "found"
	else:
		var key := "D21_T_WARM" if strength > 0.55 else ("D21_T_TEPID" if strength > 0.25 else "D21_T_COLD")
		hud.bark("SPK_TOLGA", key, 2.5)
	_update_objective()


func _found() -> void:
	hud.set_objective("")
	if found_by_bowl:
		await get_tree().create_timer(0.6).timeout
		await hud.say("SPK_GRANT", "D21_G_FOUND")
	else:
		await hud.say("SPK_GRANT", "D21_G_SELF")
		var b := Node3D.new()
		b.position = MINE
		add_child(b)
		Props.cyl(b, 0.22, 0.12, Vector3(0, 0.06, 0), Color("9a6a40"), Vector3.ZERO, 10, 0.27)
		var water := Props.cyl(b, 0.2, 0.01, Vector3(0, 0.115, 0), Color("4a78a8"), Vector3.ZERO, 12)
		var ripple := Props.ring(b, 0.05, 0.08, Vector3(0, 0.125, 0), Color("c8e0f8"), Vector3(90, 0, 0))
		bowls.append({"node": b, "water": water, "ripple": ripple, "strength": 1.0})
	# Tespit karesi: dalgalanan kap
	var best: Dictionary = bowls[0]
	for bw in bowls:
		if bw["strength"] > best["strength"]:
			best = bw
	var target: Node3D = best["node"]
	player.frozen = false
	hud.set_objective(tr("UI_OBJ21_PHOTO"), target.global_position + Vector3(0, 0.3, 0))
	cam = TespitCam.new(player, hud, target, "siege21")
	hud.add_child(cam)
	cam.max_dist = 6.0
	cam.cone_deg = 16.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	_meter.visible = false
	await hud.say("SPK_GRANT", "D21_G_DIG")


func _w(sec: float) -> void:
	await get_tree().create_timer(0.05 if GameState.autotest else sec).timeout


## Karşı lağım. Tolga elinde mumla iner (Grant: mum yanarken hava vardır); yüze yaklaştıkça alev küçülür. Tavandan
## su damlar, uzaktan kazma sesleri gelir ve her vuruşta tavandan toz dökülür. Yüzü dinler: üç vuruş, sessizlik;
## sonra kazma ucu toprağı deler, delikten kandil ışığı sızar, duvar yıkılır: karşıda elinde kandil bir madenci.
## Ayrılınca Grant'in adamları çalı demetleri ve ziftle yüzü doldurur, Grant meşaleyi atar; ateş direkleri yakar,
## tavan çöker ve lağım kapanır.
func _tunnel() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH21_TUNNEL"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	phase = "tunnel"
	var e := walls.env.environment
	e.ambient_light_color = Color("5a3a24")
	e.ambient_light_energy = 0.12
	walls.moon.light_energy = 0.0
	Audio.ambience("amb_tunnel")
	player.global_position = TUN + Vector3(0, 0.05, 1.5)
	player.face(TUN + Vector3(0, 1.2, -TUN_LEN))
	grant.global_position = TUN + Vector3(0.6, 0, 2.2)
	grant.rotation.y = PI
	grant.look_target = null
	_give_candle()
	_build_tunnel_life()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_GRANT", "D21_G_TUNNEL")
	await hud.say("SPK_NIHAT", "D21_N_MAP")
	await hud.say("SPK_TOLGA", "D21_T_MAP")
	player.frozen = false
	_taps_on = true
	hud.set_objective(tr("UI_OBJ21_FACE"), _face.global_position + Vector3(0, 1.2, 0))
	if GameState.autotest:
		_on_interact("face")
	while phase == "tunnel":
		await get_tree().process_frame
	player.frozen = true
	_taps_on = false
	hud.set_objective("")
	await _breakthrough()
	await hud.say("SPK_NOVOMINER", "D21_M_1")
	await hud.say("SPK_TOLGA", "D21_T_FACE")
	await hud.say("SPK_NIHAT", "D21_N_WHO")
	# Madencinin ardında, Osmanlı lağımının karanlığında bir kandil yaklaşır: yeniçeri seslenir
	var jl := create_tween()
	jl.tween_property(_jan_lamp, "light_energy", 1.2, _d(1.2))
	await hud.say("SPK_JANISSARY", "D21_J_CALL")
	miner.emote("surprise")
	await hud.say("SPK_NIHAT", "D21_N_DANGER")
	var has_leb := "chickpeas" in GameState.bag
	var fight_v := GameState.autotest_variant == "fight"
	var c := await hud.choose(["UI_C21_LEB_HUSH" if has_leb else "UI_C21_HUSH", "UI_C21_RUN"], 8.0, 1 if fight_v else 0)
	if c == 0:
		_tunnel_way = "leb" if has_leb else "hush"
		await _tunnel_peace(has_leb)
	else:
		_tunnel_way = "fight"
		if c < 0:
			await hud.say("SPK_TOLGA", "D21_T_FREEZE")      # süre doldu: Tolga donup kalır, madenci bağırır
		else:
			await hud.say("SPK_TOLGA", "D21_T_SHOUT")
		await _tunnel_fight()
	await _seal_with_fire()
	await hud.say("SPK_GRANT", "D21_G_FIRE")
	await hud.say("SPK_TOLGA", "D21_T_END")
	await _capture()
	await hud.say("SPK_NIHAT", "D21_N_END")
	_outcome = "21.1" if found_by_bowl else "21.2"
	GameState.flags["siege21_tunnel"] = _tunnel_way
	GameState.flags["siege21_talk"] = _talk
	Siege.record(21, _photo, "SIEGE_NOTE_21_%s_%s" % [_outcome.split(".")[1], "T" if _talk == "talk" else "I"])


## Sus işareti: madenci bakar, anlar; arkasındaki yeniçeriye "kaya çıktı" diye bağırır (kendi tarafına yalan), çekilir.
func _tunnel_peace(leb: bool) -> void:
	if leb:
		await hud.say("SPK_TOLGA", "D21_T_LEB")
		await hud.say("SPK_NOVOMINER", "D21_M_LEB2")
	await hud.say("SPK_TOLGA", "D21_T_HUSH")
	await hud.say("SPK_NOVOMINER", "D21_M_HUSH")
	miner.face_toward(miner.global_position + Vector3(0, 0, -4.0))     # kendi lağımına döner, bağırır
	await hud.say("SPK_NOVOMINER", "D21_M_LIE")
	await hud.say("SPK_JANISSARY", "D21_J_OK")
	var jl := create_tween()
	jl.tween_property(_jan_lamp, "light_energy", 0.0, _d(1.6))
	miner.face_toward(player.global_position)
	miner.emote("nod")
	await hud.say("SPK_NIHAT", "D21_N_LIE")
	# Madenci geri geri çekilir; kandilinin ışığı karanlıkta küçülür
	var back := create_tween()
	back.tween_property(miner, "global_position", TUN + Vector3(0.2, 0, -TUN_LEN - 5.4), _d(3.2))
	var ml := miner.find_child("Light", true, false) as OmniLight3D
	if ml:
		back.parallel().tween_property(ml, "light_energy", 0.25, _d(3.2))
	await hud.say("SPK_NOVOMINER", "D21_M_WAVE")
	await hud.say("SPK_GRANT", "D21_G_BACK")
	if back.is_running():
		await back.finished
	miner.visible = false


## Arbede: madenci bağırır, yeniçeri mızrağıyla koşar; Grant arkadan yetişir, "Yere yat!" der ve ateş kabını gediğe
## atar. Alev duvarı iki tarafı ayırır; madenci ile yeniçeri dumanın içinde geri çekilir.
func _tunnel_fight() -> void:
	miner.emote("surprise")
	await hud.say("SPK_NOVOMINER", "D21_M_SHOUT")
	jan.visible = true
	jan.face_toward(player.global_position)
	var run := create_tween()
	run.tween_property(jan, "global_position", TUN + Vector3(-0.5, 0, -TUN_LEN - 2.6), _d(1.4))
	var gr := create_tween()
	grant.look_target = null
	grant.global_position = player.global_position + Vector3(0.7, -0.05, 6.0)
	grant.rotation.y = PI
	gr.tween_property(grant, "global_position", player.global_position + Vector3(0.6, -0.05, 1.3), _d(1.3))
	hud.bark("SPK_JANISSARY", "D21_J_ATTACK", 2.2)
	await _w(1.2)
	await hud.say("SPK_GRANT", "D21_G_POT")
	# Tolga yere çöker; kap başının üstünden gediğe uçar
	var duck := create_tween()
	duck.tween_property(player, "eye_height", 0.9, _d(0.25))
	var pot := Props.ball(self, 0.13, grant.global_position + Vector3(0, 1.5, 0), Color("8a5a38"), Vector3(1, 1.1, 1), 8)
	var p0 := pot.global_position
	var p1 := _face.global_position + Vector3(0.1, 0.9, -0.6)
	Audio.sfx("whoosh_fly", -6.0, 0.9)
	var fly := create_tween()
	fly.tween_method(func(k: float): pot.global_position = p0.lerp(p1, k) + Vector3(0, sin(k * PI) * 0.4, 0), 0.0, 1.0, _d(0.6))
	await fly.finished
	pot.queue_free()
	Audio.sfx("land_pot", -4.0, 0.7)
	Audio.sfx("fuse_burn", -2.0, 0.8)
	player.shake(0.5)
	var wall_fire := Vfx.fire(self, p1 - Vector3(0, 0.8, 0), 1.2, Vector3(0, 0, -0.6))
	# Madenci ve yeniçeri alevin ardında, dumanın içinde geri kaçar
	for m: Person in [miner, jan]:
		var away := create_tween()
		away.tween_property(m, "global_position", TUN + Vector3(0.0, 0, -TUN_LEN - 6.0), _d(1.8))
	var ml := miner.find_child("Light", true, false) as OmniLight3D
	if ml:
		create_tween().tween_property(ml, "light_energy", 0.0, _d(1.8))
	create_tween().tween_property(_jan_lamp, "light_energy", 0.0, _d(1.8))
	await _w(2.0)
	miner.visible = false
	jan.visible = false
	var up := create_tween()
	up.tween_property(player, "eye_height", Player.EYE, _d(0.6))
	await hud.say("SPK_GRANT", "D21_G_HARD")
	await hud.say("SPK_TOLGA", "D21_T_FIGHT")
	var dim := create_tween()
	dim.tween_property(wall_fire, "scale", Vector3.ONE * 0.1, _d(1.2))
	await dim.finished
	wall_fire.queue_free()


# ================================================================ 23 Mayıs: sorgu

## Grant'in karşı lağımının başındaki oda: toprak duvarlar, direkler, masa (harita, kandil), direğe bağlı lağımcıbaşı,
## kapıda iki Bizans askeri. Tolga masanın karşısında, Grant yanında.
func _build_capture_room() -> void:
	var c := CAP
	Props.solid(self, Vector3(7.0, 0.2, 7.0), c + Vector3(0, -0.1, 0), Color("4a3828"))
	Props.solid(self, Vector3(7.0, 0.2, 7.0), c + Vector3(0, 2.7, 0), Color("2a1e14"))
	for spec in [[Vector3(0.3, 2.8, 7.0), Vector3(-3.4, 1.3, 0)], [Vector3(0.3, 2.8, 7.0), Vector3(3.4, 1.3, 0)],
			[Vector3(7.0, 2.8, 0.3), Vector3(0, 1.3, -3.4)], [Vector3(7.0, 2.8, 0.3), Vector3(0, 1.3, 3.4)]]:
		Props.set_pattern(Props.solid(self, spec[0], c + spec[1], Color.WHITE), Color("5a4430"), "plaster")
	for x: float in [-2.2, 0.0, 2.2]:
		Props.box(self, Vector3(0.18, 0.18, 6.8), c + Vector3(x, 2.5, 0), Color("5a3e26"))
	for p: Vector3 in [Vector3(-3.1, 0, -3.1), Vector3(3.1, 0, -3.1), Vector3(-3.1, 0, 3.1), Vector3(3.1, 0, 3.1)]:
		Props.cyl(self, 0.1, 2.6, c + p + Vector3(0, 1.3, 0), Color("6a4a2c"), Vector3.ZERO, 6)
	# Kapı (kuzey): kalas kapı, iki asker
	Props.box(self, Vector3(1.2, 2.1, 0.12), c + Vector3(-1.8, 1.05, -3.22), Color("5a3e26"))
	for i in 2:
		var g := Person.new({"coat": Color("6a2a2a"), "pants": Color("3a3028"), "hat": "helm", "beard": i == 0, "mustache": true, "n": 2190 + i})
		g.set_meta("no_talk", true)
		g.position = c + Vector3(-2.6 + i * 1.6, 0, -2.6)
		add_child(g)
		g.equip("spear")
	# Masa: harita (surun krokisi), kandil, kalem
	Props.solid(self, Vector3(1.6, 0.08, 0.9), c + Vector3(1.6, 0.78, 0.4), Color("6b4428"))
	for sx: float in [-0.7, 0.7]:
		for sz: float in [-0.35, 0.35]:
			Props.box(self, Vector3(0.07, 0.76, 0.07), c + Vector3(1.6 + sx, 0.38, 0.4 + sz), Color("5a3a22"))
	Props.box(self, Vector3(0.9, 0.01, 0.6), c + Vector3(1.5, 0.83, 0.4), Color("e8dcc0"))
	Props.box(self, Vector3(0.7, 0.012, 0.05), c + Vector3(1.5, 0.84, 0.3), Color("5a3a2a"))      # sur çizgisi
	var lamp := OmniLight3D.new()
	lamp.position = c + Vector3(1.9, 1.3, 0.3)
	lamp.light_color = Color("ffb060")
	lamp.light_energy = 1.8
	lamp.omni_range = 7.0
	add_child(lamp)
	var fl := Props.ball(self, 0.035, c + Vector3(1.9, 0.95, 0.3), Color("ffd070"), Vector3(1, 2, 1), 6, 3.0)
	fl.material_override = Props.mat(Color("ffd070"), 4.0, false, "", false)
	Props.ball(self, 0.08, c + Vector3(1.9, 0.87, 0.3), Color("a0603a"), Vector3(1.0, 0.55, 1.25), 8)
	# Direk ve tabure; lağımcıbaşı direğe bağlı oturur (eller arkada)
	Props.cyl(self, 0.11, 2.6, c + Vector3(-0.6, 1.3, -1.25), Color("5a3e26"), Vector3.ZERO, 8)
	Props.solid(self, Vector3(0.45, 0.45, 0.45), c + Vector3(-0.6, 0.225, -0.95), Color("6b4428"))
	kasim = Person.new({"coat": Color("4a5a3a"), "pants": Color("3a3028"), "hat": "turban", "beard": true, "mustache": true,
		"hair": Color("2a1e14"), "skin": Color("c89070"), "n": 2195})
	kasim.set_meta("spk", "SPK_KASIM")
	kasim.position = c + Vector3(-0.6, 0.2, -0.95)
	add_child(kasim)
	kasim.set_activity("sit")
	for y: float in [1.05, 1.25]:
		var rope := Props.cyl(self, 0.24, 0.045, c + Vector3(-0.6, y + 0.2, -1.02), Color("8a7450"), Vector3.ZERO, 12)
		rope.scale = Vector3(1.0, 1.0, 0.9)
		_ropes.append(rope)


func _bind_kasim() -> void:
	if kasim.rig:
		kasim.rig.lock += 1
	kasim._arm_l.rotation = Vector3(0.55, 0, -0.18)
	kasim._arm_r.rotation = Vector3(0.55, 0, 0.18)
	kasim._elbow_l.rotation = Vector3(-0.5, 0, 0)
	kasim._elbow_r.rotation = Vector3(-0.5, 0, 0)


## 23 Mayıs. Tolga tercüman: Grant'in her sözünü aynen ya da yumuşatarak çevirir. Güven (_trust) 2'ye ulaşırsa Kasım,
## adamları çıkarılmadan tünellerin yakılmayacağı sözüyle konuşur; ulaşmazsa Grant onu içeri götürür (kapı kapanır).
func _capture() -> void:
	await hud.fade_to(1.0, 0.8)
	_build_capture_room()
	for l in _tunnel_lights:
		(l as OmniLight3D).light_energy = 0.0
	await hud.card([[tr("UI_CH21_CAPTURE"), 26, Color("f2e6c9")]], 2.4)
	hud.clear_card()
	player.eye_height = Player.EYE
	player.global_position = CAP + Vector3(-0.4, 0.05, 1.0)
	grant.visible = true
	grant.global_position = CAP + Vector3(0.7, 0, 0.3)
	grant.look_target = kasim
	await _w(0.4)
	_bind_kasim()
	kasim.look_target = player
	player.face(kasim.global_position + Vector3(0, 1.1, 0))
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D21_N_CAP")
	await hud.say("SPK_GRANT", "D21_G_CAP1")
	var fight_v := GameState.autotest_variant == "fight"
	# 1. tur: tehdit
	await hud.say("SPK_GRANT", "D21_G_Q1")
	var a1 := await hud.choose(["UI_C21_Q1_A", "UI_C21_Q1_B", "UI_C21_Q1_C"], 0.0, 0 if fight_v else 1)
	match a1:
		1:
			_trust += 1
			await hud.say("SPK_TOLGA", "D21_T_Q1_B")
			await hud.say("SPK_KASIM", "D21_K_B1")
			await hud.say("SPK_TOLGA", "D21_T_B1")
		2:
			_trust += 1
			await hud.say("SPK_TOLGA", "D21_T_Q1_C")
			await hud.say("SPK_KASIM", "D21_K_C1")
		_:
			await hud.say("SPK_TOLGA", "D21_T_Q1_A")
			await hud.say("SPK_KASIM", "D21_K_A1")
	# Tüneldeki gece: Mirko ona anlatmış
	match _tunnel_way:
		"leb":
			_trust += 1
			await hud.say("SPK_KASIM", "D21_K_MIRKO_LEB")
		"hush":
			_trust += 1
			await hud.say("SPK_KASIM", "D21_K_MIRKO_HUSH")
		_:
			await hud.say("SPK_KASIM", "D21_K_FIRE")
	# 2. tur: kızgın demir
	await hud.say("SPK_GRANT", "D21_G_Q2")
	var a2 := await hud.choose(["UI_C21_Q2_A", "UI_C21_Q2_B"], 0.0, 0 if fight_v else 1)
	if a2 == 1:
		_trust += 1
		await hud.say("SPK_TOLGA", "D21_T_Q2_B")
		await hud.say("SPK_KASIM", "D21_K_B2")
	else:
		await hud.say("SPK_TOLGA", "D21_T_Q2_A")
		await hud.say("SPK_KASIM", "D21_K_A2")
	if _trust >= 2:
		_talk = "talk"
		await hud.say("SPK_TOLGA", "D21_T_PROMISE")
		await hud.say("SPK_GRANT", "D21_G_PROMISE")
		kasim.emote("nod")
		await hud.say("SPK_KASIM", "D21_K_TELL")
		await hud.say("SPK_NIHAT", "D21_N_TALK")
	else:
		_talk = "iron"
		await hud.say("SPK_GRANT", "D21_G_TAKE")
		# Askerler onu kapıya götürür; kapı kapanır. Ekranda gösterilmez: kararır, Tolga dışarıda bekler.
		kasim.look_target = null
		for r in _ropes:
			r.visible = false            # ipler çözülür, kolları arkada bağlı kalır
		# Ayağa kaldırılır: oturuş bırakılır, kollar arkada bağlı kalır
		if kasim.rig:
			kasim.rig.lock = maxi(0, kasim.rig.lock - 1)
		kasim.set_activity("")
		kasim.position.y = CAP.y
		await _w(0.4)
		_bind_kasim()
		var drag := create_tween()
		drag.tween_property(kasim, "global_position", CAP + Vector3(-1.8, 0, -3.0), _d(2.2))
		await _w(1.4)
		await hud.fade_to(1.0, 0.8)
		Audio.sfx("door_metal", -6.0, 0.6)
		kasim.visible = false
		await _w(1.2)
		await hud.say("SPK_TOLGA", "D21_T_WAIT")
		grant.global_position = CAP + Vector3(0.6, 0, 0.0)
		grant.look_target = player
		player.face(grant.global_position + Vector3(0, 1.5, 0))
		await hud.fade_to(0.0, 1.0)
		await hud.say("SPK_GRANT", "D21_G_MAP")
		await hud.say("SPK_NIHAT", "D21_N_TORTURE")


func _d(sec: float) -> float:
	return 0.05 if GameState.autotest else sec


## Tolga'nın mumu: elde (kameraya bağlı), küçük pirinç tabakta; alev titrer, ışığı yakını aydınlatır.
func _give_candle() -> void:
	_candle = Node3D.new()
	_candle.position = Vector3(0.26, -0.3, -0.55)
	_candle.scale = Vector3.ONE * 0.7
	player.camera.add_child(_candle)
	Props.cyl(_candle, 0.07, 0.015, Vector3.ZERO, Color("b8903a"), Vector3.ZERO, 10)
	Props.cyl(_candle, 0.022, 0.12, Vector3(0, 0.065, 0), Color("f0e6c8"), Vector3.ZERO, 8)
	_candle_flame = Props.ball(_candle, 0.018, Vector3(0, 0.15, 0), Color("ffd070"), Vector3(1, 2.2, 1), 6, 3.0)
	_candle_flame.material_override = Props.mat(Color("ffd070"), 4.0, false, "", false)
	_candle_light = OmniLight3D.new()
	_candle_light.position = Vector3(0, 0.2, 0)
	_candle_light.light_color = Color("ffb868")
	_candle_light.light_energy = 1.2
	_candle_light.omni_range = 4.5
	_candle.add_child(_candle_light)
	Props.strip_outlines(_candle)


## Tünelin canlılığı: tavandan damlayan su (ince çizgi damlalar), yerde küçük su birikintileri, yüzün yanında
## sepetler ve kürekler (kazılan toprak), direklerde kandil isi.
func _build_tunnel_life() -> void:
	var drop := SphereMesh.new()
	drop.radius = 0.015
	drop.height = 0.06
	var dm := StandardMaterial3D.new()
	dm.albedo_color = Color(0.7, 0.8, 0.9, 0.8)
	dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dm.metallic = 0.5
	dm.roughness = 0.1
	drop.material = dm
	for z: float in [-3.2, -7.8, -11.4]:
		var d := CPUParticles3D.new()
		d.amount = 3
		d.lifetime = 0.9
		d.mesh = drop
		d.direction = Vector3.DOWN
		d.spread = 0.0
		d.initial_velocity_min = 0.2
		d.initial_velocity_max = 0.4
		d.gravity = Vector3(0, -9.8, 0)
		d.position = TUN + Vector3(0.4 - absf(z) * 0.03, 2.18, z)
		add_child(d)
		d.emitting = true
		var puddle := Props.cyl(self, 0.35, 0.01, TUN + Vector3(0.4 - absf(z) * 0.03, 0.005, z), Color("3a4450"), Vector3.ZERO, 12)
		puddle.material_override = Props.mat(Color("3a4450"), 0.0, false, "", false)
	for i in 2:
		Props.cyl(self, 0.22, 0.3, TUN + Vector3(-0.8, 0.15, -TUN_LEN + 1.6 + i * 0.6), Color("8a6a40"), Vector3.ZERO, 8, 0.26)
	Props.cyl(self, 0.025, 1.3, TUN + Vector3(0.85, 0.65, -TUN_LEN + 2.2), Color("6a4a2c"), Vector3(0, 0, 12), 5)
	Props.box(self, Vector3(0.25, 0.02, 0.3), TUN + Vector3(0.98, 0.04, -TUN_LEN + 2.2), Color("5a5a60"), Vector3(0, 0, 12))


## Yüzün ardındaki kazı: kazma vuruşu, yüzden ve tavandan toz; Tolga'ya yaklaştıkça yüksek.
func _tap(strong := false) -> void:
	var d := player.global_position.distance_to(_face.global_position)
	Audio.sfx("pick_tap", clampf(-4.0 - d * 1.1, -24.0, 0.0) + (4.0 if strong else 0.0), randf_range(0.85, 1.15))
	var at := _face.global_position + Vector3(randf_range(-0.6, 0.6), 2.1, 0.8)
	Vfx.dust(self, at, 0.25 if not strong else 0.5)
	if d < 6.0:
		player.shake(0.06 if not strong else 0.2)


func _breakthrough() -> void:
	# Tolga kulağını yüze dayar: üç net vuruş, sonra sessizlik
	var lean := create_tween()
	lean.tween_property(player, "global_position", _face.global_position + Vector3(-0.3, 0.05, 1.0), _d(0.8))
	await lean.finished
	player.face(_face.global_position + Vector3(0, 1.3, 0))
	hud.bark("SPK_TOLGA", "D21_T_LISTEN", 2.5)
	for i in 3:
		_tap(true)
		Vfx.dust(self, _face.global_position + Vector3(0.2, 1.3, 0.3), 0.3)
		await _w(0.75)
	await _w(1.1)
	# Çatlak yayılır
	for k in 5:
		var a := randf_range(-60.0, 60.0)
		Props.box(_face, Vector3(0.03, randf_range(0.3, 0.7), 0.02), Vector3(0.2 + randf_range(-0.4, 0.4), 1.3 + randf_range(-0.4, 0.4), 0.21), Color("1a120c"), Vector3(0, 0, a))
	_tap(true)
	await _w(0.4)
	# Kazma ucu delip çıkar, geri çekilir
	var tip := Node3D.new()
	add_child(tip)
	tip.global_position = _face.global_position + Vector3(0.2, 1.35, -0.2)
	Props.box(tip, Vector3(0.05, 0.06, 0.5), Vector3(0, 0, 0), Color("4a4a50"))
	var poke := create_tween()
	poke.tween_property(tip, "global_position:z", _face.global_position.z + 0.55, _d(0.12))
	Audio.sfx("land_thud", -2.0, 1.4)
	Vfx.dust(self, _face.global_position + Vector3(0.2, 1.35, 0.5), 0.5)
	await poke.finished
	# Delikten kandil ışığı sızar
	var glow := OmniLight3D.new()
	glow.light_color = Color("ffb060")
	glow.light_energy = 0.0
	glow.omni_range = 3.0
	add_child(glow)
	glow.global_position = _face.global_position + Vector3(0.2, 1.35, 0.3)
	var gl := create_tween()
	gl.tween_property(glow, "light_energy", 1.6, _d(0.6))
	await _w(0.7)
	tip.queue_free()
	await _w(0.6)
	# Duvar yıkılır: parçalar yuvarlanıp Tolga'nın ayaklarına dökülür
	Audio.sfx("cave_in", -4.0, 1.3)
	player.shake(0.5)
	_face.visible = false
	for ch in _face.get_children():
		if ch is StaticBody3D:
			ch.queue_free()
	var rng := RandomNumberGenerator.new()
	rng.seed = 2116
	for k in 14:
		var from := _face.global_position + Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(0.3, 2.0), 0.1)
		var chunk := Props.box(self, Vector3(rng.randf_range(0.2, 0.45), rng.randf_range(0.15, 0.3), rng.randf_range(0.2, 0.4)), from, Color("5a4430").darkened(rng.randf_range(0.0, 0.3)))
		var to := Vector3(from.x * 0.7 + _face.global_position.x * 0.3, TUN.y + 0.1, _face.global_position.z + rng.randf_range(0.2, 1.6))
		var ft := create_tween().set_parallel()
		ft.tween_property(chunk, "global_position", to, _d(rng.randf_range(0.35, 0.6))).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		ft.tween_property(chunk, "rotation_degrees", Vector3(rng.randf_range(-90, 90), rng.randf_range(-90, 90), rng.randf_range(-90, 90)), _d(0.5))
	for k in 3:
		Vfx.dust(self, _face.global_position + Vector3(rng.randf_range(-0.8, 0.8), rng.randf_range(0.5, 1.8), 0.5), 1.0)
	glow.queue_free()
	# Karşıda madenci: bir elinde kandil (göğüs hizasında kaldırmış), öbüründe kazma
	miner.visible = true
	miner.global_position = TUN + Vector3(0.2, 0, -TUN_LEN - 1.4)
	miner.face_toward(player.global_position)
	if miner.find_child("Lamp", true, false) == null:
		miner.equip("lamp")
		miner.equip("pick")
	if miner.rig:
		miner.rig.lock += 1
		miner._arm_r.rotation = Vector3(-1.05, 0, 0.1)
		miner._elbow_r.rotation = Vector3(-0.9, 0, 0)
	player.face(miner.global_position + Vector3(0, 1.5, 0))
	await _w(1.0)


## Kapatma: iki adam çalı demetleri, biri zift kabı getirir; Grant meşaleyi atar. Ateş büyür, direkler kömürleşir,
## tavan çöker. Tolga girişe geri çekilmiş, yandan izler.
func _seal_with_fire() -> void:
	var face_z := TUN.z - TUN_LEN
	var back := create_tween()
	back.tween_property(player, "global_position", TUN + Vector3(-0.75, 0.05, face_z + 8.0), _d(1.6))
	await back.finished
	player.face(TUN + Vector3(0, 1.0, face_z + 2.0))
	var men: Array[Person] = []
	for i in 2:
		var m := Person.new({"coat": [Color("5a4a3a"), Color("6a5a48")][i], "pants": Color("3a3028"), "hat": "none", "mustache": true,
			"beard": i == 0, "apron": Color("4a3a2a"), "n": 2150 + i})
		m.set_meta("no_talk", true)
		m.position = TUN + Vector3(0.55, 0, face_z + 11.5 + i * 0.9)
		m.rotation.y = PI
		add_child(m)
		m.carry("sack" if i == 0 else "basket")
		men.append(m)
	# Çalı demetlerini yüze taşırlar, bırakıp dönerler
	for i in 2:
		var go := create_tween()
		go.tween_property(men[i], "global_position", TUN + Vector3(0.45 - i * 0.9, 0, face_z + 1.6 + i * 0.4), _d(4.2 + i * 0.4))
	await _w(4.8)
	var pile := Node3D.new()
	add_child(pile)
	pile.global_position = TUN + Vector3(0, 0, face_z + 0.9)
	for k in 9:
		var b := Props.cyl(pile, 0.22, 1.2, Vector3(-0.8 + (k % 3) * 0.8, 0.22 + (k / 3) * 0.32, -0.3 + (k / 3) * 0.1), Color("7a6a3a"), Vector3(0, 0, 90), 6)
		b.rotation_degrees.y = randf_range(-20, 20)
	Props.cyl(pile, 0.9, 0.02, Vector3(0, 0.01, 0.8), Color("141010"), Vector3.ZERO, 12)     # dökülen zift
	for m in men:
		for c in m._body.get_children():
			if c is Node3D and c.position.z > 0.3 and c.position.y > 0.9:
				c.queue_free()
		var ret := create_tween()
		ret.tween_property(m, "global_position", TUN + Vector3(0.6, 0, face_z + 12.5), _d(3.8))
	await _w(2.4)
	# Grant meşaleyi yakar ve atar
	var torch := Node3D.new()
	add_child(torch)
	grant.global_position = TUN + Vector3(0.7, 0, face_z + 5.0)
	grant.rotation.y = PI
	torch.global_position = grant.global_position + Vector3(0.3, 1.2, -0.3)
	Props.cyl(torch, 0.03, 0.6, Vector3.ZERO, Color("5a3a22"), Vector3.ZERO, 5)
	var tf := Props.ball(torch, 0.09, Vector3(0, 0.34, 0), Color("ffb040"), Vector3(1, 1.6, 1), 6, 3.0)
	tf.material_override = Props.mat(Color("ffb040"), 4.0, false, "", false)
	var tl := OmniLight3D.new()
	tl.light_color = Color("ff9a40")
	tl.light_energy = 2.0
	tl.omni_range = 6.0
	tl.position = Vector3(0, 0.4, 0)
	torch.add_child(tl)
	Audio.sfx("whoosh_fly", -6.0, 0.8)
	var throw := create_tween()
	var p0 := torch.global_position
	var p1 := pile.global_position + Vector3(0, 0.6, 0)
	throw.tween_method(func(k: float):
		torch.global_position = p0.lerp(p1, k) + Vector3(0, sin(k * PI) * 0.8, 0)
		torch.rotation.x = k * 8.0, 0.0, 1.0, _d(0.9))
	await throw.finished
	torch.queue_free()
	# Ateş: zift tutuşur, alevler çalıyı sarar, is tavanda Tolga'ya doğru yayılır
	Audio.sfx("fuse_burn", -2.0, 0.7)
	var fire := Vfx.fire(self, pile.global_position + Vector3(0, 0.2, 0), 1.0, Vector3(0, 0, 0.9))
	fire.scale = Vector3.ONE * 0.2
	var grow := create_tween()
	grow.tween_property(fire, "scale", Vector3.ONE * 1.35, _d(3.0)).set_ease(Tween.EASE_OUT)
	var roar := AudioStreamPlayer3D.new()
	var st := (load("res://assets/audio/sfx/fire_crackle.ogg") as AudioStreamOggVorbis).duplicate() as AudioStreamOggVorbis
	st.loop = true
	roar.stream = st
	roar.unit_size = 6.0
	roar.bus = "SFX"
	fire.add_child(roar)
	roar.play()
	for l in _tunnel_lights:
		(l as OmniLight3D).light_energy = 0.4
	await _w(3.2)
	# Direkler kömürleşir, çatırdar
	var char_mat := Props.mat(Color("1e1612"), 0.0, false, "", false)
	for n in get_children():
		if n is MeshInstance3D and (n as MeshInstance3D).global_position.z < TUN.z - TUN_LEN + 5.0 and absf((n as MeshInstance3D).global_position.x - TUN.x) < 1.3 \
				and (n as MeshInstance3D).global_position.y > TUN.y and (n as MeshInstance3D).global_position.y < TUN.y + 2.4 and (n as MeshInstance3D).mesh is CylinderMesh:
			(n as MeshInstance3D).material_override = char_mat
	Audio.sfx("land_thud", -6.0, 0.6)
	player.shake(0.2)
	await _w(1.6)
	# Tavan çöker: toprak ve kalas yüzü doldurur
	Audio.sfx("cave_in", 0.0)
	player.shake(0.9)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2117
	for k in 22:
		var from := TUN + Vector3(rng.randf_range(-1.1, 1.1), 2.2, face_z + rng.randf_range(0.2, 4.5))
		var chunk := Props.box(self, Vector3(rng.randf_range(0.4, 0.9), rng.randf_range(0.3, 0.6), rng.randf_range(0.4, 0.9)), from, Color("4a3828").darkened(rng.randf_range(0.0, 0.35)))
		var to := Vector3(from.x, TUN.y + rng.randf_range(0.2, 1.8) * (1.0 - (from.z - face_z) / 5.0), from.z)
		var ct := create_tween().set_parallel()
		ct.tween_property(chunk, "global_position", to, _d(rng.randf_range(0.3, 0.7))).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		ct.tween_property(chunk, "rotation_degrees", Vector3(rng.randf_range(-40, 40), rng.randf_range(-40, 40), rng.randf_range(-40, 40)), _d(0.6))
	for k in 5:
		Vfx.dust(self, TUN + Vector3(rng.randf_range(-0.8, 0.8), 1.2, face_z + 1.0 + k * 0.9), 1.4)
	var shrink := create_tween()
	shrink.tween_property(fire, "scale", Vector3.ONE * 0.25, _d(1.5))
	shrink.tween_property(roar, "volume_db", -30.0, _d(1.5))
	await shrink.finished
	fire.queue_free()
	# Moloz tüter
	Vfx.smolder(self, TUN + Vector3(0, 0.4, face_z + 2.0), 0.6)
	await _w(1.0)


func _process(delta: float) -> void:
	_t += delta
	for bw in bowls:
		var s: float = bw["strength"]
		var r: MeshInstance3D = bw["ripple"]
		var k := fmod(_t * (0.8 + s * 2.2), 1.0)
		r.scale = Vector3.ONE * (0.4 + k * 2.2 * (0.3 + s))
		(bw["water"] as Node3D).position.y = 0.115 + sin(_t * 30.0) * 0.004 * s
	if phase == "bowls":
		var d := Vector2(player.global_position.x - MINE.x, player.global_position.z - MINE.z).length()
		_heat = lerpf(_heat, clampf(1.0 - d / 14.0, 0.0, 1.0), delta * 3.0)
		_meter.queue_redraw()
	if phase in ["tunnel"]:
		for i in _tunnel_lights.size():
			(_tunnel_lights[i] as OmniLight3D).light_energy = 1.3 + sin(_t * 7.0 + i) * 0.15
	if _candle_light:
		# Mum titrer; yüze yaklaştıkça (hava azaldıkça) alev küçülür ve söner gibi olur
		var d := player.global_position.distance_to(_face.global_position) if _face else 10.0
		var air := clampf(d / 10.0, 0.35, 1.0)
		var flick := 0.85 + sin(_t * 23.0) * 0.08 + sin(_t * 37.0) * 0.06 + randf() * 0.05
		_candle_light.light_energy = 1.25 * air * flick
		_candle_flame.scale = Vector3(1.0, 2.2 * air * flick, 1.0)
	if _taps_on:
		_tap_t -= delta
		if _tap_t <= 0.0:
			_tap_t = randf_range(1.2, 2.2)
			_tap()


func _draw_meter() -> void:
	var vs := _meter.size
	var r := Rect2(Vector2(vs.x - 330, vs.y - 230), Vector2(300, 120))
	_meter.draw_rect(r, Color(0.05, 0.06, 0.08, 0.85))
	_meter.draw_rect(r, Color("7fd3ff"), false, 2.0)
	_meter.draw_string(ThemeDB.fallback_font, r.position + Vector2(10, 22), tr("UI_CH21_APP"), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("7fd3ff"))
	var pts := PackedVector2Array()
	for i in 60:
		var x := r.position.x + 10 + i * 4.7
		var amp := 4.0 + _heat * 34.0
		var y := r.position.y + 70 + sin(_t * 18.0 + i * 0.9) * amp * (0.4 + 0.6 * sin(i * 0.37 + _t * 3.0))
		pts.append(Vector2(x, y))
	_meter.draw_polyline(pts, Color("5fcf6a").lerp(Color("ff5a4a"), _heat), 2.0)
	_meter.draw_rect(Rect2(r.position + Vector2(10, 100), Vector2(280 * _heat, 8)), Color("ff9a4a"))


func _unhandled_input(event: InputEvent) -> void:
	# Kabı toprağa koymak: bakılan bir şey yokken E
	if phase == "bowls" and event.is_action_pressed("interact") and player.focus_id == "" and not player.frozen:
		var fwd := -player.global_transform.basis.z
		fwd.y = 0.0
		_place_bowl(player.global_position + fwd.normalized() * 0.9)
		get_viewport().set_input_as_handled()


func _auto_bowls() -> void:
	await get_tree().create_timer(0.3).timeout
	if GameState.autotest_variant == "grant":
		for p: Vector3 in [Vector3(8, 0, 4), Vector3(10, 0, 2), Vector3(6, 0, 10), Vector3(12, 0, 8)]:
			_place_bowl(p)
	else:
		_place_bowl(Vector3(2, 0, 4))
		_place_bowl(MINE + Vector3(1.2, 0, 0.5))


func _on_focus(id: String) -> void:
	hud.set_prompt(tr("UI_PROMPT21_FACE") if id == "face" and phase == "tunnel" else "")


func _on_interact(id: String) -> void:
	if id == "face" and phase == "tunnel":
		phase = "breach"
		Audio.sfx("timer_tick", -6.0, 0.6)
		hud.bark("SPK_TOLGA", "D21_T_LISTEN", 2.5)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(21, _outcome)
	await Siege.show_page(hud, 21)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(21)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW21_TITLE")
	c.nodes = [
		{"id": "bowls", "key": "FLOW21_BOWLS", "pos": Vector2(0.5, 0.15)},
		{"id": "21.1", "key": "FLOW_21_1", "pos": Vector2(0.3, 0.27), "outcome": true},
		{"id": "21.2", "key": "FLOW_21_2", "pos": Vector2(0.7, 0.27), "outcome": true},
		{"id": "tunnel", "key": "FLOW21_TUNNEL", "pos": Vector2(0.5, 0.39)},
		{"id": "peace", "key": "FLOW21_PEACE", "pos": Vector2(0.3, 0.51)},
		{"id": "fight", "key": "FLOW21_FIGHT", "pos": Vector2(0.7, 0.51)},
		{"id": "capture", "key": "FLOW21_CAPTURE", "pos": Vector2(0.5, 0.63)},
		{"id": "talk", "key": "FLOW21_TALK", "pos": Vector2(0.3, 0.75)},
		{"id": "iron", "key": "FLOW21_IRON", "pos": Vector2(0.7, 0.75)},
	]
	c.edges = [["bowls", "21.1"], ["bowls", "21.2"], ["21.1", "tunnel"], ["21.2", "tunnel"], ["tunnel", "peace"], ["tunnel", "fight"],
		["peace", "capture"], ["fight", "capture"], ["capture", "talk"], ["capture", "iron"]]
	for k in ["bowls", "tunnel", _outcome, "fight" if _tunnel_way == "fight" else "peace", "capture", _talk]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH21_STATS") % [BOWLS - bowls_left, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "21.1", "grant": "21.2", "fight": "21.1"}.get(v, "21.1")
	var exp_talk := "iron" if v == "fight" else "talk"
	var exp_way := "fight" if v == "fight" else ("leb" if "chickpeas" in GameState.bag else "hush")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("21", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and _talk == exp_talk and _tunnel_way == exp_way \
		and tr(String(page.get("note", ""))) != String(page.get("note", ""))
	if not ok:
		printerr("AUTOTEST: beklenen %s/%s/%s, gelen %s/%s/%s (sayfa=%s)" % [expected, exp_way, exp_talk, _outcome, _tunnel_way, _talk, page])
	print("AUTOTEST %s chapter=21 variant=%s outcome=%s bowls=%d tunnel=%s talk=%s trust=%d" % ["PASS" if ok else "FAIL", v, _outcome,
		BOWLS - bowls_left, _tunnel_way, _talk, _trust])
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
	phase = "bowls"
	_meter.visible = true
	_place_bowl(Vector3(-5.0, 0, 6.0))
	_place_bowl(MINE + Vector3(3.5, 0, 0.0))
	player.global_position = MINE + Vector3(4.2, 0.05, 2.4)
	await get_tree().create_timer(0.8).timeout
	player.face(MINE + Vector3(3.5, 0.0, 0.0))
	_heat = 0.7
	await _shot("c21_01_bowls.png")
	_meter.visible = false
	phase = "shots"
	player.global_position = TUN + Vector3(0, 0.05, -TUN_LEN + 1.6)
	var e := walls.env.environment
	e.ambient_light_color = Color("5a3a24")
	e.ambient_light_energy = 0.2
	walls.moon.light_energy = 0.0
	_face.visible = false
	miner.visible = true
	miner.global_position = TUN + Vector3(0.2, 0, -TUN_LEN - 1.4)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0.3, 1.3, 0.4)
	lamp.light_color = Color("ffb060")
	lamp.light_energy = 1.6
	lamp.omni_range = 5.0
	miner.add_child(lamp)
	miner.face_toward(player.global_position)
	await get_tree().create_timer(0.4).timeout
	player.face(miner.global_position + Vector3(0, 1.5, 0))
	await _shot("c21_02_miner.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = TUN + Vector3(0.7, 1.5, -TUN_LEN + 3.0)
	cv.look_at(miner.global_position + Vector3(0, 1.3, 0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c21_cover.png")
	get_tree().quit()
