class_name Drill
extends Node
## Talim yönetmeni: Bölüm 41o (Osmanlı ordugâhı, Azap Bölükbaşı Turgut) ve 42b (surların içi, Giustiniani ve Leon)
## ortak kılıç derslerini oynatır. Arkadaşın notu: "Ne yapmam gerektiğini anlamadım"; kullanıcı: "biri bize savaşmayı
## öğretsin". Her ders tek bir şeyi öğretir, ekranda ne basılacağı yazar, hoca yanlışı görünce söyler; oyuncu ölmez
## (Duel.god), takılırsa hoca bir süre sonra dersi geçirir (kilitlenme yok).
##   1 yön     kazıktaki saman kukla sopasını (muhafız) yukarıda, solda, sağda tutar: açık yerden vur (A / D / yalnız tık)
##   2 siper   talim arkadaşı yavaş vurur: sağ tık basılı, kalkan (3 darbe)
##   3 karşılama  kırmızı ok dolduğu an sağ tık (2 kez; 8 denemede olmazsa hoca geçirir)
##   4 tekme   hoca önce gösterir (arkadaşın kalkanına tekme). a) kalkan her darbeyi tutar: F ile aç, sendelerken
##             vur. b) kolu kalkmışken (kırmızı ok dolarken) tekme: sırtüstü yere serilir
##   5 bitirici   arkadaşta (tahta kılıç, ölmez; yere serilir, kalkar), öldürme kamerasında baştan sona: saplama
##             (tekme → E), kesiş (karşıla → A/D + E; A/D'siz kabza), yerde saplama (kol kalkınca tekme → yerde E)
##   6 serbest talim   arkadaş gerçekten dövüşür: dört temiz darbe ya da bir bitirici (yedi darbe yersen ya da süre
##             biterse hoca durdurur)
## Kullanıcı (v0.99.13): "tekme atma ve bitiriş animasyonunu iyice öğret".
## Anahtarlar: pre + "_H_…" (hoca), "_P_…" (talim arkadaşı), "_T_…" (Tolga); ekran yazıları UI_DRILL_* (ortak).

signal phase_changed(id: String)

const DIR_KEYS := {Duelist.DIR_TOP: "UI_DRILL_DIR_TOP", Duelist.DIR_LEFT: "UI_DRILL_DIR_LEFT", Duelist.DIR_RIGHT: "UI_DRILL_DIR_RIGHT"}

var scene: Node3D
var hud: Hud
var player: Player
var yard: TrainingYard
var teacher: Person
var teacher_spk := ""
var partner: Duelist
var partner_spk := ""
var kukla: Duelist
var duel: Duel
var blade := "kilij"
var pre := ""
var phase := ""
# Ders sonuçları
var dir_hits := 0
var guard_bumps := 0
var misses := 0
var blocks := 0
var parries := 0
var parry_ok := false
var kick_ok := false
var finisher := ""
var spar_hits := 0
var spar_taken := 0
var spar_won := false
var spar_fin := ""                 # serbest talim bitiriciyle kazanıldıysa hamlesi
var _hit_flag := false
var _bark_t := 0.0
var _t := 0.0


func setup(p_scene: Node3D, p_hud: Hud, p_player: Player, p_yard: TrainingYard, p_pre: String, p_blade: String) -> void:
	scene = p_scene
	hud = p_hud
	player = p_player
	yard = p_yard
	pre = p_pre
	blade = p_blade
	name = "Drill"
	duel = Duel.new()
	duel.god = true
	duel.wooden = true
	_snap_dir = str(GameState.flags.get("drillsnap", ""))
	if _snap_dir != "":
		DirAccess.make_dir_recursive_absolute(_snap_dir)
	hud.add_child(duel)
	duel.swung.connect(_on_swung)


func _process(delta: float) -> void:
	_t += delta
	_bark_t = maxf(0.0, _bark_t - delta)
	if _snap_dir != "":
		_snap_watch()


## Canlı çekim (--flag=drillsnap:KLASÖR, otomatik testle): dersin ana anlarında kare alınır (hocanın tekmesi,
## oyuncunun tekmesi, yere serilme, her bitiricinin öldürme kamerası). Oyunda hiçbir şey yapmaz.
var _snap_dir := ""
var _snapped := {}
var _fin_t := -1.0
var _fin_n := 0


func _snap(name: String, delay := 0.0) -> void:
	if _snap_dir == "" or _snapped.has(name):
		return
	_snapped[name] = true
	if delay > 0.0:
		await scene.get_tree().create_timer(delay, false).timeout
	await RenderingServer.frame_post_draw
	scene.get_viewport().get_texture().get_image().save_png(_snap_dir.path_join("%s_%s.png" % [pre, name]))


func _snap_watch() -> void:
	if duel == null:
		return
	Engine.time_scale = 1.0
	if duel.pstate == Duel.P.KICK and duel._pt > 0.17:
		_snap("kick_fp_%s" % phase)
	if phase == "kick" and partner and partner.state == Duelist.St.DOWN:
		_snap("kick_down", 0.25)
	if duel.active and not duel.killcam and duel._finish_ready():
		_snap("fin_hint_%s" % duel.finish_kind())
	if duel.killcam:
		if _fin_t < 0.0:
			_fin_t = 0.0
			_fin_n += 1
		_fin_t += scene.get_process_delta_time()
		for at: float in [0.12, 0.35, 0.6, 0.9, 1.25]:
			if _fin_t >= at:
				_snap("fin%d_%s_%03d" % [_fin_n, duel.last_finisher, int(at * 100)])
	else:
		_fin_t = -1.0


## Anahtar: önek + büyük harfli ek ("h_dir_1" → D41O_H_DIR_1). Ekler kodda küçük harfle yazılır: anahtar denetimi
## (tests/check_keys.py) yarım anahtarı eksik metin saymasın
func _key(k: String) -> String:
	return pre + "_" + k.to_upper()


func _say_h(k: String) -> void:
	await hud.say(teacher_spk, _key("h_" + k))


func _bark_h(k: String, secs := 2.6) -> void:
	if _bark_t > 0.0:
		return
	_bark_t = 3.5
	hud.bark(teacher_spk, _key("h_" + k), secs)


func _set_phase(id: String) -> void:
	phase = id
	phase_changed.emit(id)
	if GameState.autotest:
		print("DRILL phase=%s" % id)


## Oyuncuyu meydanda yerel bir noktaya koyar, birine döndürür (sahne başında ve dersler arasında). Talim arkadaşı
## da yerine döner (perde kapalıyken): ders dışında oyuncunun peşine takılıp iskeleye yürüyordu, sonra konuşurken
## merdivenin dibindeki gönüllünün arkasında kalıyordu (42b VISAUDIT personhidden)
func place_player(local: Vector3, look: Node3D) -> void:
	var to := yard.at(local) + Vector3(0, 0.05, 0)
	if not GameState.autotest and player.global_position.distance_to(to) > 0.6:
		hud.set_fade(0.0)
		await hud.fade_to(1.0, 0.25)
		_home_partner()
		player.global_position = to
		player.velocity = Vector3.ZERO
		if look:
			player.face(look.global_position + Vector3(0, 1.45, 0))
		await hud.fade_to(0.0, 0.3)
	else:
		_home_partner()
		player.global_position = to
		if look:
			player.face(look.global_position + Vector3(0, 1.45, 0))


func _home_partner() -> void:
	if partner == null or not is_instance_valid(partner) or duel.active:
		return
	partner.target = null
	var home := yard.at(TrainingYard.PARTNER)
	if partner.global_position.distance_to(home) > 0.8:
		partner.global_position = home
	partner.state = Duelist.St.IDLE


func _start_duel(list: Array[Duelist]) -> void:
	if duel.active:
		duel.stop()
	duel.start(player, list, blade)
	TrainingYard.woodify(duel.sword)
	player.frozen = false


func _on_swung(dir: int, result: String, e: Duelist) -> void:
	if GameState.autotest:
		print("DRILL swing phase=%s dir=%d result=%s on=%s" % [phase, dir, result, "kukla" if e == kukla else ("partner" if e == partner else "-")])
	if e == kukla and is_instance_valid(kukla):
		match result:
			"hit", "kill":
				dir_hits += 1
				yard.kukla_hit(dir, true)
				_hit_flag = true
			"blocked":
				guard_bumps += 1
				yard.kukla_hit(dir, false)
				if phase == "dir":
					_bark_h("dir_blocked")
			"miss":
				misses += 1
				if phase in ["dir", "finish"]:
					_bark_h("near")
	elif e == partner and is_instance_valid(partner):
		match result:
			"hit":
				if phase == "spar":
					spar_hits += 1
					hud.set_objective(tr("UI_DRILL_SPAR") % [mini(spar_hits, 4), 4])
				elif phase == "kick" and partner.state in [Duelist.St.STAGGER, Duelist.St.FLINCH]:
					_kick_hit = true
			"blocked":
				if phase == "kick":
					_bark_h("kick_hint")


## Hocanın yüzü oyuncuya, yanında durur, arada başını sallar
func _teacher_watch() -> void:
	if teacher and is_instance_valid(teacher):
		teacher.look_target = player


# ================================================================ 1 yön

func directions() -> void:
	_set_phase("dir")
	_teacher_watch()
	await place_player(TrainingYard.DRILL_AT, kukla)
	_start_duel([kukla] as Array[Duelist])
	player.frozen = true
	await _say_h("dir_1")
	await _say_h("dir_2")
	player.frozen = false
	for g: int in [Duelist.DIR_TOP, Duelist.DIR_LEFT, Duelist.DIR_RIGHT]:
		kukla.drill_guard = g
		yard.set_guard_visual(g)
		hud.set_objective(GameState.tr_pad(DIR_KEYS[g]))
		_hit_flag = false
		var t := 0.0
		while not _hit_flag and t < 45.0:
			await scene.get_tree().process_frame
			if scene.get_tree().paused:      # duraklatmada sayaç akmaz
				continue
			t += scene.get_process_delta_time()
			if t > 14.0 and not _hit_flag and _bark_t <= 0.0:
				_bark_h("dir_help", 3.4)
		if teacher:
			teacher.emote("nod")
		hud.bark(teacher_spk, _key("h_dir_ok_%d" % g), 2.0)
		await scene.get_tree().create_timer(0.6, false).timeout
	hud.set_objective("")
	duel.stop()


# ================================================================ 2 siper, 3 karşılama

func _partner_front() -> Vector3:
	return TrainingYard.PARTNER + Vector3(0, 0, 2.3)


func blocking() -> void:
	_set_phase("block")
	partner.drill = true
	partner.drill_guard = Duelist.DIR_TOP
	await place_player(_partner_front(), partner)
	_start_duel([partner] as Array[Duelist])
	player.frozen = true
	await hud.say(partner_spk, _key("p_block"))
	await _say_h("block_1")
	player.frozen = false
	var need := 3
	var b0 := duel.blocks + duel.parries
	var h0 := duel.hits_taken
	var gap := 1.0
	var t := 0.0
	while duel.blocks + duel.parries - b0 < need and t < 70.0:
		await scene.get_tree().process_frame
		if scene.get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		var dt := scene.get_process_delta_time()
		t += dt
		hud.set_objective(GameState.tr_pad("UI_DRILL_BLOCK") % [duel.blocks + duel.parries - b0, need])
		if partner.state == Duelist.St.IDLE:
			gap -= dt
			if gap <= 0.0:
				gap = 1.6
				partner.drill_attack(randi() % 3, 1.3)
		if duel.hits_taken > h0:
			h0 = duel.hits_taken
			_bark_h("block_miss")
	blocks = duel.blocks + duel.parries - b0
	hud.set_objective("")
	await _wait_idle()
	player.frozen = true
	await _say_h("block_ok")
	# Kalkanın arkasına gömülen oyuncuyu usta rakip tekmeler (Duel.player_kicked): hoca önceden söyler
	await _say_h("block_turtle")
	player.frozen = false


func parrying() -> void:
	_set_phase("parry")
	player.frozen = true
	await _say_h("parry_1")
	await _say_h("parry_2")
	player.frozen = false
	var need := 2
	var p0 := duel.parries
	var tries := 0
	var gap := 1.2
	var t := 0.0
	while duel.parries - p0 < need and tries < 8 and t < 80.0:
		await scene.get_tree().process_frame
		if scene.get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		var dt := scene.get_process_delta_time()
		t += dt
		hud.set_objective(GameState.tr_pad("UI_DRILL_PARRY") % [duel.parries - p0, need])
		if partner.state == Duelist.St.IDLE:
			gap -= dt
			if gap <= 0.0:
				gap = 1.9
				tries += 1
				partner.drill_attack(randi() % 3, 1.05)
				# Erken kaldırılan kalkan karşılamaz, yalnız tutar: hoca söyler
				_watch_early(duel.parries, duel.blocks)
	parries = duel.parries - p0
	parry_ok = parries >= need
	hud.set_objective("")
	await _wait_idle()
	if parry_ok:
		hud.bark(teacher_spk, _key("h_parry_ok"), 2.2)
	else:
		await _say_h("parry_soft")


## Bu saldırı karşılanmadan tutulduysa (kalkan erken kalktı) hoca "erken" der
func _watch_early(p_before: int, b_before: int) -> void:
	await scene.get_tree().create_timer(1.25, false).timeout
	if not is_instance_valid(partner) or phase != "parry":
		return
	if duel.parries == p_before and duel.blocks > b_before:
		_bark_h("parry_early")
	elif duel.parries == p_before:
		_bark_h("parry_late")


func _wait_idle() -> void:
	var t := 0.0
	while is_instance_valid(partner) and partner.state != Duelist.St.IDLE and t < 3.0:
		await scene.get_tree().process_frame
		if scene.get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		t += scene.get_process_delta_time()


# ================================================================ 4 tekme, 5 bitirici

## Talim arkadaşı tahta kılıçla: bitirici onu öldürmez (aynı hamle oynanır, yere serilir, kalkar)
func _prep_partner() -> void:
	partner.practice = true
	partner.drill = true


## Hoca tekmeyi gösterir: talim arkadaşının yanına yürür, kalkanına tekme atar (arkadaş sendeler, kalkanı savrulur),
## yerine döner. Oyuncu durur ve izler. Hoca arkadaşın yanına, oyuncunun bakışına dik geçer: tekme yandan (profilden)
## görünür. Eskiden hocanın gözü oyuncudaydı (look_target): tekmeyi oyuncuya doğru atıyordu, arkadaş da önceki dersten
## kalma bir yerde duruyordu.
func _demo_kick() -> void:
	if teacher == null or not is_instance_valid(teacher) or partner == null:
		return
	var home := teacher.global_position
	var looked: Node3D = teacher.look_target
	teacher.look_target = null
	var to_p := partner.global_position - player.global_position
	to_p.y = 0.0
	var side := to_p.normalized().cross(Vector3.UP)
	var spot := partner.global_position + side * 1.15
	if teacher.global_position.distance_to(partner.global_position - side * 1.15) < teacher.global_position.distance_to(spot):
		spot = partner.global_position - side * 1.15
	partner.target = null
	partner.drill_guard = Duelist.DIR_TOP
	var w := Walker.go(teacher, spot, 1.6)
	if w:
		await w.arrived
	teacher.face_toward(partner.global_position)
	var f := teacher.global_position - partner.global_position
	partner.rotation.y = atan2(f.x, f.z)
	player.face((teacher.global_position + partner.global_position) * 0.5 + Vector3(0, 1.1, 0))
	await scene.get_tree().create_timer(0.35, false).timeout
	_snap("kick_demo_0", 0.08)
	_snap("kick_demo_1", LimbAnim.KICK_HIT + 0.02)
	_snap("kick_demo_2", LimbAnim.KICK_HIT + 0.3)
	partner.target = teacher          # tekmeyi yiyince savrulsun (hedefsiz düellocu kıpırdamıyor)
	await Duelist.person_kick(teacher, partner)
	await scene.get_tree().create_timer(0.5, false).timeout
	partner.target = null
	await hud.say(partner_spk, _key("p_kick_demo"))
	var w2 := Walker.go(teacher, home, 1.6)
	if w2:
		await w2.arrived
	teacher.look_target = looked
	await _wait_idle()


func kicking() -> void:
	_set_phase("kick")
	_prep_partner()
	partner.drill_guard = Duelist.DIR_TOP
	# Gösteri için düello durur: arkadaş yerine döner (place_player), hoca onun yanına geçer
	await _wait_idle()
	if duel.active:
		duel.stop()
	# Gösteriyi bir adım geriden izler (ikisi birden kadraja girsin)
	await place_player(_partner_front() + Vector3(0, 0, 1.2), partner)
	player.frozen = true
	await hud.say(partner_spk, _key("p_kick"))
	await _say_h("kick_demo")
	await _demo_kick()
	await place_player(_partner_front(), partner)
	_start_duel([partner] as Array[Duelist])
	player.frozen = true
	await _say_h("kick_1")
	player.frozen = false
	# 4a: kalkanı tekmeyle aç, sendelerken vur (açık kalan yere)
	hud.set_objective(GameState.tr_pad("UI_DRILL_KICK"))
	var k0 := duel.kicks
	var follow_ok := false
	var t := 0.0
	var opened := false
	var open_t := 0.0
	_kick_hit = false
	while not follow_ok and t < 70.0:
		await scene.get_tree().process_frame
		if scene.get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		var dt := scene.get_process_delta_time()
		t += dt
		# kalkan her yöne yetişir: kılıç işlemez (sendelerken muhafız tutmaz)
		partner.drill_guard = duel.aim
		if duel.kicks > k0 and not opened:
			opened = true
			open_t = 0.0
			hud.set_objective(GameState.tr_pad("UI_DRILL_KICK_FOLLOW"))
			_bark_h("kick_follow", 1.6)
		if opened:
			open_t += dt
			if _kick_hit:
				follow_ok = true
			elif partner.state != Duelist.St.STAGGER and open_t > 0.5:
				# Sersemlik geçti, kalkan kapandı: yeniden
				opened = false
				k0 = duel.kicks
				hud.set_objective(GameState.tr_pad("UI_DRILL_KICK"))
				_bark_h("kick_late")
		if t > 16.0 and duel.kicks == 0:
			_bark_h("kick_hint")
		if GameState.autotest:
			_bot_kick_follow(opened)
	kick_ok = duel.kicks > 0
	hud.set_objective("")
	if GameState.autotest:
		print("DRILL kick ok=%s follow=%s kicks=%d t=%.1f" % [kick_ok, follow_ok, duel.kicks, t])
	await _wait_idle()
	player.frozen = true
	if follow_ok:
		await hud.say(partner_spk, _key("p_kick_ouch"))
		await _say_h("kick_follow_ok")
	else:
		await _say_h("kick_soft")
	# 4b: kolu kalkmışken tekme yere serer
	await _say_h("kick_down_1")
	player.frozen = false
	var need_down := false
	var tries := 0
	var gap := 1.2
	t = 0.0
	partner.drill_guard = Duelist.DIR_TOP
	while not need_down and tries < 7 and t < 80.0:
		await scene.get_tree().process_frame
		if scene.get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		var dt := scene.get_process_delta_time()
		t += dt
		hud.set_objective(GameState.tr_pad("UI_DRILL_KICK_DOWN") % [mini(tries, 7), 7])
		if partner.state == Duelist.St.DOWN:
			need_down = true
			break
		if partner.state == Duelist.St.IDLE:
			gap -= dt
			if gap <= 0.0:
				gap = 2.2
				tries += 1
				partner.drill_attack(randi() % 3, 1.6)       # yavaş: kol havada uzun kalır
		if GameState.autotest:
			_bot_kick_down()
	kick_down = need_down
	hud.set_objective("")
	if GameState.autotest:
		print("DRILL kick_down ok=%s tries=%d t=%.1f" % [need_down, tries, t])
	await scene.get_tree().create_timer(0.8, false).timeout
	player.frozen = true
	if need_down:
		await _say_h("kick_down_ok")
		await hud.say("SPK_TOLGA", _key("t_kick_down"))
	else:
		await _say_h("kick_down_soft")
	await _wait_idle()
	partner.drill_guard = Duelist.DIR_TOP


var kick_down := false
var _kick_hit := false


## Test botu: tekme menziline girer, tekmeler, kalkan açılınca vurur
func _bot_kick_follow(opened: bool) -> void:
	if duel.pstate != Duel.P.IDLE or duel.killcam:
		return
	player.face(partner.global_position + Vector3(0, 1.45, 0))
	var to := partner.global_position - player.global_position
	to.y = 0.0
	if opened:
		if partner.state == Duelist.St.STAGGER and to.length() < Duel.REACH - 0.1:
			duel.attack(Duelist.DIR_TOP)
		elif partner.state == Duelist.St.STAGGER:
			player.global_position = partner.global_position - to.normalized() * (Duel.REACH - 0.6)
		return
	if duel._kick_cd <= 0.0:
		if to.length() > Duel.KICK_REACH - 0.3:
			player.global_position = partner.global_position - to.normalized() * (Duel.KICK_REACH - 0.5)
		duel.kick()


## Test botu: kol kalkınca (hazırlığın ortasında) tekmeler
func _bot_kick_down() -> void:
	if duel.pstate != Duel.P.IDLE or duel._kick_cd > 0.0:
		return
	if partner.state == Duelist.St.WINDUP and partner.windup_progress() > 0.35:
		var to := partner.global_position - player.global_position
		to.y = 0.0
		player.face(partner.global_position + Vector3(0, 1.45, 0))
		if to.length() > Duel.KICK_REACH - 0.3:
			player.global_position = partner.global_position - to.normalized() * (Duel.KICK_REACH - 0.5)
		duel.kick()


## Bitirici dersi: üç hamle talim arkadaşında (tahta kılıç, ölmez): saplama (tekme → E), kesiş (karşıla → A/D + E;
## A/D'siz kabza), yerde saplama (kol kalkınca tekme → yerdeyken E). Her biri öldürme kamerasında baştan sona oynar.
## Takılan oyuncuyu hoca bir süre sonra bir sonrakine geçirir.
const FIN_STEPS := ["thrust", "slash", "ground"]
var fin_done: Array[String] = []


func finishing() -> void:
	_set_phase("finish")
	_prep_partner()
	partner.remove_meta("no_finish")
	partner.drill_guard = Duelist.DIR_TOP
	await _wait_idle()
	await place_player(_partner_front(), partner)
	if not duel.active:
		_start_duel([partner] as Array[Duelist])
	player.frozen = true
	await _say_h("fin_1")
	fin_done.clear()
	var got := {"kind": ""}
	var cb := func(k: String, _e: Duelist): got["kind"] = k
	duel.finished_move.connect(cb)
	for step: String in FIN_STEPS:
		player.frozen = true
		await _say_h("fin_" + step)
		player.frozen = false
		duel.bot_no_kick = step != "thrust"         # kol kalkınca tekmeyi yerde saplama dersinde _bot_finish atar
		duel.bot_no_attack = step != "thrust"
		var kind := ""
		var wrong := 0
		var t := 0.0
		var gap := 1.4
		var told := false
		while t < 60.0:
			got["kind"] = ""
			while got["kind"] == "" and t < 60.0:
				await scene.get_tree().process_frame
				if scene.get_tree().paused:      # duraklatmada sayaç akmaz
					continue
				var dt := scene.get_process_delta_time()
				t += dt
				hud.set_objective(GameState.tr_pad("UI_DRILL_FIN_" + step.to_upper()))
				if duel.killcam:
					continue
				var open := partner.state == Duelist.St.STAGGER or partner.state == Duelist.St.DOWN
				# Saplama dersinde kalkan her yöne yetişir (tekme şart); ötekilerde arkadaş yavaş saldırır
				partner.drill_guard = duel.aim if step == "thrust" else -1
				if step != "thrust" and partner.state == Duelist.St.IDLE:
					gap -= dt
					if gap <= 0.0:
						gap = 2.0
						partner.drill_attack(randi() % 3, 1.15 if step == "slash" else 1.6)
				if open and duel._finish_ready() and not told:
					told = true
					_bark_h("fin_now", 1.6)
				elif not open:
					told = false
				if GameState.autotest:
					_bot_finish(step)
			while duel.killcam:
				await scene.get_tree().process_frame
			kind = got["kind"]
			# Dersin hamlesi mi (kesiş dersinde kabza da sayılır: ikisi de karşılamanın ardından)
			if kind == "" or kind == step or (step == "slash" and kind == "bash") or wrong >= 2:
				break
			wrong += 1
			await _wait_up()
			_bark_h("fin_wrong_" + step, 3.0)
		hud.set_objective("")
		if kind != "":
			fin_done.append(kind)
			finisher = kind
		if GameState.autotest:
			print("DRILL finisher step=%s kind=%s wrong=%d" % [step, kind, wrong])
		await scene.get_tree().create_timer(0.6, false).timeout
		player.frozen = true
		if kind == "":
			await _say_h("fin_skip")
		else:
			await hud.say(partner_spk, _key("p_fin_" + step))
			if step == "slash" and kind == "bash":
				await _say_h("fin_bash")
		await _wait_up()
	duel.finished_move.disconnect(cb)
	duel.bot_no_kick = false
	duel.bot_no_attack = false
	partner.set_meta("no_finish", true)
	await _say_h("fin_ok" if fin_done.size() >= 2 else "fin_soft")
	if duel.active:
		duel.stop()
	partner.target = null          # ders dışında oyuncunun peşine takılmaz


## Yere serilen talim arkadaşı kalkana dek bekler
func _wait_up() -> void:
	var t := 0.0
	while is_instance_valid(partner) and partner.state == Duelist.St.DOWN and t < 4.0:
		await scene.get_tree().process_frame
		if scene.get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		t += scene.get_process_delta_time()
	await _wait_idle()


## Test botu: dersin hamlesini yapar (tekme / karşılama / kol kalkınca tekme), açılınca E
func _bot_finish(step: String) -> void:
	if duel.pstate != Duel.P.IDLE or duel.killcam:
		return
	player.face(partner.global_position + Vector3(0, 1.45, 0))
	var to := partner.global_position - player.global_position
	to.y = 0.0
	if duel._finish_ready():
		duel.aim = Duelist.DIR_LEFT if step == "slash" else Duelist.DIR_TOP
		duel.finish()
		return
	if to.length() > Duel.KICK_REACH - 0.3:
		player.global_position = partner.global_position - to.normalized() * (Duel.KICK_REACH - 0.5)
	match step:
		"thrust":
			if duel._kick_cd <= 0.0 and partner.state == Duelist.St.IDLE:
				duel.kick()
		"ground":
			if duel._kick_cd <= 0.0 and partner.state == Duelist.St.WINDUP and partner.windup_progress() > 0.35:
				duel.kick()
		"slash":
			# Karşılama: kırmızı ok dolmadan hemen önce kalkan
			if partner.state == Duelist.St.WINDUP and partner.time_to_impact() < duel.parry_win * 0.6:
				duel._block_t0 = duel._now
				duel.blocking = true


# ================================================================ 6 serbest talim

func spar(lose := false) -> bool:
	_set_phase("spar")
	await place_player(_partner_front() + Vector3(0, 0, 0.6), partner)
	partner.drill = false
	partner.drill_guard = -1
	partner.skill = 0.4
	partner.windup_time = lerpf(0.95, 0.5, partner.skill)
	partner.damage = 7.0
	partner.practice = true
	# Serbest talimde bitirici de olur: sersemleyen arkadaşa E talimi hemen kazandırır (yere serilir, kalkar)
	partner.remove_meta("no_finish")
	player.frozen = true
	await _say_h("spar_1")
	await hud.say(partner_spk, _key("p_spar"))
	_start_duel([partner] as Array[Duelist])
	duel.bot_idle = lose
	spar_hits = 0
	spar_fin = ""
	var h0 := duel.hits_taken
	hud.set_objective(tr("UI_DRILL_SPAR") % [0, 4])
	Audio.sfx("war_cry", -10.0, 1.1)
	var cb := func(k: String, _e: Duelist): spar_fin = k
	duel.finished_move.connect(cb)
	var t := 0.0
	while spar_hits < 4 and spar_fin == "" and duel.hits_taken - h0 < 7 and t < 75.0:
		await scene.get_tree().process_frame
		if scene.get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		t += scene.get_process_delta_time()
	duel.finished_move.disconnect(cb)
	spar_taken = duel.hits_taken - h0
	spar_won = spar_hits >= 4 or spar_fin != ""
	partner.drill = true
	partner.set_meta("no_finish", true)
	duel.bot_idle = false
	while duel.killcam:
		await scene.get_tree().process_frame
	await _wait_up()
	if duel.active:
		duel.stop()
	hud.set_objective("")
	player.frozen = true
	if GameState.autotest:
		print("DRILL spar won=%s hits=%d fin=%s taken=%d t=%.1f" % [spar_won, spar_hits, spar_fin, spar_taken, t])
	return spar_won


## Ders sonu özeti (akış şemasının alt satırı)
func summary() -> Dictionary:
	return {"dir": dir_hits, "bumps": guard_bumps, "blocks": blocks, "parries": parries, "kick": kick_ok,
		"kick_down": kick_down, "finisher": finisher, "finishers": fin_done.size(), "fin_kinds": ",".join(fin_done), "spar_hits": spar_hits,
		"spar_taken": spar_taken, "won": spar_won}


func cleanup() -> void:
	if duel and is_instance_valid(duel):
		if duel.active:
			duel.stop()
		duel.queue_free()
