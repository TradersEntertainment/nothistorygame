extends Node3D
## Bölüm 35 (yalnız Osmanlı tarafı) — Edirne Yolu (Tolga · Şubat–Mart 1453, Trakya). docs/OTTOMAN_NEW_A.md §3.
##
##   1. Taşkın: döşemeyi dere aldı, kirişler ve ortadaki iskele tahtası kaldı. Yürüyerek yığından kalas al (E), iskele
##      tahtasından taşı, boş yuvaya koy (E), direğe bağla (E basılı). Altı kalas, konvoy gelmeden (süre). Kütükleri sehpa
##      başındaki iki sırıkçı savuşturur. Dereye inen akıntıya kapılır, kıyıdan atılan ipe tutunur (taşıdığı kalas yığına
##      döner). Süre biterse dülgerler kalanları gevşek döşer: ≥2 gevşek kalas → konvoy geçerken teker dereye iner.
##   2. Çamur: öndeki araba batıyor; yığından çalı demeti al, tekerin önüne at (3, köprü kırıldıysa 4). Sonra hey-yap
##      (Space, yeşilde): iyi çekiş 1,5 m. Kırmızıda çekmek 1 m geri kaydırır ve halatı gerer; üçüncüde HALAT kopar:
##      0,8 sn'de kamçı alanından çık.
##   3. Yokuş: fren ipi (E basılı sık, bırak gevşet), ibre arabanın hızı. Tümsekler ve Karaca Bey'in atı ibreyi iter.
##      Yarıda ipi ikinci kazığa aktar (6 sn). Kırmızı sağda 1 sn → kayma (hendek); solda 1,5 sn iki kez → ip kopar.
##   4. Gece konağı: kurt; üç öküz ipini koparıp kaçar. İpin ucunu yakala (E), ibreyi ortada tut (A/D) 4 sn, adını söyle (E).
##      Tespit: meşaleler arasında top.
##   35O.1 toplam kayma ≤ 1 ve köprü kırılmadı · 35O.2 aksi
##   --autotest[=slip]   (varsayılan 35O.1)

const BRIDGE_TIME := 240.0
const ROW_GOAL := 12.0
const SLOPE_TIME := 75.0
const NIGHT_TIME := 120.0
const S_MUD := ThraceRoad.MUD_Z + 1.6
const S_SLOPE0 := 61.4
const S_SLOPE1 := 126.0

var level: ThraceRoad
var player: Player
var hud: Hud
var meter: RowMeter
var balance: BalanceMeter
var cam: TespitCam
var phase := "intro"
var _outcome := ""
var _photo := ""

var urban: Person
var carpenters: Array[Person] = []

# skor
var loose := 0
var swept := 0
var broke := false
var slips := 0
var snaps := 0
var logs_pushed := 0
var logs_missed := 0
var caught := 0


func _ready() -> void:
	GameState.snapshot(35)
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	meter = RowMeter.new()
	hud.add_child(meter)
	meter.stroke.connect(_on_stroke)
	balance = BalanceMeter.new()
	balance.visible = false
	hud.add_child(balance)
	balance.place_bottom()
	level = ThraceRoad.new()
	add_child(level)
	_build_people()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _variant() -> String:
	return GameState.autotest_variant if GameState.autotest else ""


func _gy(p: Vector3) -> Vector3:
	return Vector3(p.x, ThraceRoad.ground_y(p.x, p.z), p.z)


func _build_people() -> void:
	urban = Person.new({"coat": Color("4a3a2a"), "pants": Color("3a2a22"), "hat": "kalpak", "beard": true, "mustache": true, "hair": Color("6a5040"), "face": "urban"})
	urban.set_meta("spk", "SPK_URBAN")
	add_child(urban)
	urban.position = _gy(Vector3(-6.4, 0, -14.8))
	urban.look_target = player
	var specs := [[Color("6a4a2a"), "turban", true], [Color("7a6a50"), "bork", false], [Color("5a4a3a"), "bork", false]]
	for k in 3:
		var s: Array = specs[k]
		var c := Person.new({"coat": s[0], "pants": Color("e8e0d0"), "hat": s[1], "mustache": true, "beard": s[2], "skin": Color("c89070")})
		if k == 0:
			c.set_meta("spk", "SPK_DULGER")
		else:
			c.set_meta("no_talk", true)
		add_child(c)
		c.position = _gy(Vector3(-5.6, 0, -10.2))
		c.look_target = player if k == 0 else null
		carpenters.append(c)
	# İki sırıkçı: dere yukarısına bakan sehpa başlarında (kütük gelirse kancayla açıklığa iter)
	for k in [1, 2]:
		var pm: Person = carpenters[k]
		pm.position = Vector3(-1.95, ThraceRoad.BEAM_Y - 0.17, -4.8 if k == 1 else 4.8)
		pm.face_toward(pm.position + Vector3(-5, 0, 0))
		pm.set_activity("thrust_a")
		_pole_men.append(pm)
		_poles.append(_make_pole())
	# Karşı kıyı ayağında çivi çakan dülger
	var hm := Person.new({"coat": Color("6a5a40"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("c89070")})
	hm.set_meta("no_talk", true)
	add_child(hm)
	hm.position = Vector3(1.7, ThraceRoad.BEAM_Y, ThraceRoad.BEAM_Z + 1.0)
	hm.face_toward(hm.position + Vector3(0, 0, -3))
	hm.set_activity("hammer")
	carpenters.append(hm)


func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH35O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH35O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = _gy(Vector3(1.2, 0, -12.6)) + Vector3(0, 0.1, 0)
	_face_bridge()
	player.show_remote(true)             # Tolga'nın eli açık (bölüm boyunca kapalıydı)
	_capture_mouse()
	Audio.ambience("amb_shore_day")
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D35O_N_01")
	await hud.say("SPK_TOLGA", "D35O_T_01")
	await hud.say("SPK_DULGER", "D35O_D_01")
	Lore.scatter(self, "35o", [_gy(Vector3(-5.0, 0, -12.0)) + Vector3(0, 0.3, 0), _gy(Vector3(7.0, 0, 16.0)) + Vector3(0, 0.3, 0),
		_gy(Vector3(-8.0, 0, 132.0)) + Vector3(0, 0.3, 0)])
	await _bridge()
	await _crossing()
	await _mud()
	await _slope()
	await _night()
	await _end_chapter()


# ================================================================ 1. taşkın
# Taşkın döşemeyi aldı, kirişler ve dülgerlerin ortadaki iskele tahtası kaldı. Oyuncu yürür (kilit yok): yığından kalas
# alır (E), iskele tahtasından taşır, boş yuvaya koyar (E), direğe bağlar (E basılı). Kütükleri sehpa başındaki iki
# sırıkçı karşılar. Konvoy gelene kadar bağlanmamış kalasları dülgerler gevşek döşer.

const LASH_TIME := 1.8

var _plank_state: Array = ["", "", "", "", "", ""]   # "" | "set" | "tight" | "loose"
var _lash_p: Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var _carry_plank: Node3D          # taşınan kalas (yığından alınan düğüm, taşınırken gizli)
var _held_plank: Node3D           # kameradaki omuz yükü
var _ghost: MeshInstance3D        # kalasın gideceği yuvanın hayaleti
var _bridge_left := 0.0
var _lash_sfx_t := 0.0
var _lash_said := 0
var _logs: Array[Dictionary] = []
var _log_t := 9.0
var _log_said := false
var _pole_men: Array[Person] = []
var _poles: Array[Node3D] = []
var _bridge_bot_t := 0.0
var _bot_hold := false


func _bridge() -> void:
	phase = "bridge"
	player.frozen = false
	player.free_look = false
	_make_ghost()
	_bridge_left = BRIDGE_TIME
	hud.set_qte(tr("UI_HINT35O_BEAM"))
	get_tree().create_timer(8.0, false).timeout.connect(func():
		if phase == "bridge":
			hud.set_qte(""))
	var bot_fell := false
	while _bridge_left > 0.0:
		await get_tree().process_frame
		if get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		var dt := get_process_delta_time()
		_bridge_left -= dt
		_tick_logs(dt)
		if _falling:
			continue
		var tight := _plank_state.count("tight")
		if tight == 6:
			break
		hud.set_objective(tr("UI_OBJ35O_LASH") % [tight, 6, int(ceil(_bridge_left))], _bridge_target())
		if GameState.autotest:
			_bridge_bot(dt)
			if _variant() == "slip" and not bot_fell and tight >= 2:
				bot_fell = true
				await _fall_in()
				continue
		if _check_fall():
			continue
		_bridge_interact(dt)
	hud.set_prompt("")
	hud.set_qte("")
	hud.set_objective("")
	hud.set_red_progress(0.0)
	_ghost.visible = false
	if _carry_plank != null:
		_drop_carried()
	# Süre bitti: dülgerler kalanları gevşek döşer (yığındakileri de boş yuvalara)
	var late := false
	for i in 6:
		if _plank_state[i] == "":
			var nd := level.pile_top()
			if nd:
				level.set_plank(i, nd)
		if _plank_state[i] != "tight":
			_plank_state[i] = "loose"
			level.lash_rings(i, 1, true)
			late = true
	loose = _plank_state.count("loose")
	for c: Person in carpenters:
		c.set_activity("")
	if late:
		# Usta kıyıdan bağırır (oyuncu köprünün neresindeyse; yüzü görünmeyebilir)
		hud.bark("SPK_DULGER", "D35O_D_LASH_BAD", 6.0)
		await get_tree().create_timer(4.0, false).timeout
	else:
		hud.bark("SPK_TOLGA", "D35O_T_BRIDGE", 4.0)
		await get_tree().create_timer(2.0, false).timeout
	player.frozen = true


## Hedef işareti: taşırken boş yuva, bağlanmamış kalas varsa direği, yoksa yığın
func _bridge_target() -> Vector3:
	if _carry_plank != null:
		var s := _first_empty()
		return Vector3(0, ThraceRoad.BEAM_Y + 0.1, ThraceRoad.PLANKS[maxi(s, 0)])
	for i in 6:
		if _plank_state[i] == "set":
			return level.lash_posts[i]
	return ThraceRoad.PILE + Vector3(0, 0.9, 0)


func _first_empty() -> int:
	for i in 6:
		if _plank_state[i] == "":
			return i
	return -1


func _near_pile() -> bool:
	var d := Vector2(player.global_position.x - ThraceRoad.PILE.x, player.global_position.z - ThraceRoad.PILE.z)
	return absf(d.x) < 2.6 and absf(d.y) < 2.6


## Kalasın konabileceği yuva: köprünün üstünde (ya da başında) ve yuvaya yakın
func _slot_near() -> int:
	var pp := player.global_position
	if absf(pp.x) > 1.8 or absf(pp.z) > ThraceRoad.BEAM_Z + 1.4 or pp.y < ThraceRoad.BEAM_Y - 0.6:
		return -1
	var best := -1
	var bd := 2.1
	for i in 6:
		if _plank_state[i] == "":
			var d := absf(pp.z - float(ThraceRoad.PLANKS[i]))
			if d < bd:
				bd = d
				best = i
	return best


## Bağlanacak kalas: direğe 2,2 m'den yakın, yuvada duran (bağı bitmemiş)
func _lash_near() -> int:
	var pp := player.global_position
	for i in 6:
		if _plank_state[i] == "set":
			var lp: Vector3 = level.lash_posts[i]
			if Vector2(pp.x - lp.x, pp.z - lp.z).length() < 2.2 and absf(pp.y - lp.y) < 1.6:
				return i
	return -1


func _bridge_interact(dt: float) -> void:
	var pr := ""
	var e_now := Input.is_action_just_pressed("interact")
	var e_held := Input.is_action_pressed("interact") or _bot_hold
	_lash_sfx_t -= dt
	if _carry_plank == null:
		var li := _lash_near()
		if li >= 0:
			pr = "UI_PROMPT35O_LASH"
			if e_held:
				_lash_tick(li, dt)
			else:
				hud.set_red_progress(0.0)
		else:
			hud.set_red_progress(0.0)
			if _near_pile() and level.pile_top() != null:
				pr = "UI_PROMPT35O_TAKE"
				if e_now:
					_take_plank()
		_ghost.visible = false
	else:
		var s := _slot_near()
		_ghost.visible = s >= 0
		if s >= 0:
			_ghost.position = Vector3(0, ThraceRoad.BEAM_Y + 0.06, ThraceRoad.PLANKS[s])
			pr = "UI_PROMPT35O_PLACE"
			if e_now:
				_place_plank(s)
	hud.set_prompt(tr(pr) if pr != "" else "")


func _make_ghost() -> void:
	_ghost = MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(2.9, 0.1, ThraceRoad.PLANK_LEN - 0.08)
	_ghost.mesh = bm
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(0.55, 1.0, 0.6, 0.28)
	_ghost.material_override = m
	_ghost.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ghost.name = "SlotGhost"
	_ghost.set_meta("no_occlude", true)
	_ghost.visible = false
	add_child(_ghost)


func _take_plank() -> void:
	var nd := level.pile_top()
	if nd == null or _carry_plank != null:
		return
	_carry_plank = nd
	nd.visible = false
	level.update_pile()
	# Omuzda: sol omuzdan öne uzanan kalas (ucu görüşün sol altında), sol el altından tutar (havada asılıydı);
	# sağ elde eşya kalır
	_held_plank = Node3D.new()
	player.camera.add_child(_held_plank)
	_held_plank.position = Vector3(-0.46, -0.36, -0.25)
	_held_plank.rotation_degrees = Vector3(-3, 7, -4)
	player.free_hold = Vector3(-0.42, -0.42, -0.62)
	Props.box(_held_plank, Vector3(0.2, 0.05, 2.5), Vector3(0, 0, -1.0), Color("8a6440"))
	Props.box(_held_plank, Vector3(0.21, 0.01, 0.025), Vector3(0, 0.03, -0.5), Color("5a4024"))
	Props.strip_outlines(_held_plank)
	player.speed_mult = 0.75
	Audio.sfx("land_thud", -12.0, 1.4)


func _place_plank(s: int) -> void:
	var nd := _carry_plank
	_carry_plank = null
	if is_instance_valid(_held_plank):
		_held_plank.queue_free()
	player.free_hold = Vector3.INF
	player.speed_mult = 1.0
	_ghost.visible = false
	_plank_state[s] = "set"
	level.set_plank(s, nd, false)
	# Omuzdan yuvaya iner (tutulduğu yerden), sonra dülger çakar
	var to := nd.position
	nd.global_position = player.global_position + Vector3(0, 1.0, 0) + (Vector3(0, 0, to.z) - Vector3(0, 0, player.global_position.z)).limit_length(0.6)
	nd.rotation.y = 0.25
	var tw := nd.create_tween().set_parallel(true)
	tw.tween_property(nd, "position", to, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(nd, "rotation:y", 0.0, 0.35)
	tw.chain().tween_callback(func():
		# İndikten sonra katı olur (inerken katı olsa oyuncuyu iskele tahtasının içinden aşağı itiyordu)
		level.set_plank(s)
		var pp := player.global_position
		if absf(pp.z - float(ThraceRoad.PLANKS[s])) < ThraceRoad.PLANK_LEN * 0.5 + 0.4 and absf(pp.x) < 1.8 and pp.y < ThraceRoad.BEAM_Y + 0.11:
			player.global_position.y = ThraceRoad.BEAM_Y + 0.12
		Vfx.dust(self, nd.global_position, 0.3)
		Audio.sfx("land_thud", -6.0, 1.2))
	if GameState.autotest:
		print("PLANK set %d" % s)


## Taşınan kalas elden gider (dereye düşünce): aşağıdaki adamlar yakalar, yığına geri konur
func _drop_carried() -> void:
	player.free_hold = Vector3.INF
	if is_instance_valid(_held_plank):
		_held_plank.queue_free()
	player.speed_mult = 1.0
	if _carry_plank != null:
		_carry_plank.visible = true
		_carry_plank = null
		level.update_pile()


func _lash_tick(i: int, dt: float) -> void:
	var before: float = _lash_p[i]
	_lash_p[i] = minf(1.0, before + dt / LASH_TIME)
	hud.set_red_progress(_lash_p[i], tr("UI_LASH35O_BAR"))
	if _lash_sfx_t <= 0.0:
		_lash_sfx_t = 0.45
		Audio.sfx("ship_haul", -12.0, 1.4)
	if before < 0.5 and _lash_p[i] >= 0.5:
		level.lash_rings(i, 1, false)
	if _lash_p[i] >= 1.0:
		_plank_state[i] = "tight"
		level.lash_rings(i, 2, false)
		hud.set_red_progress(0.0)
		Audio.sfx("land_pot", -10.0, 1.2)
		# Usta ilk bağda ve sonuncuda konuşur (her bağda aynı söz yorardı)
		_lash_said += 1
		if _lash_said == 1 or _plank_state.count("tight") == 6:
			hud.bark("SPK_DULGER", "D35O_D_LASH_OK", 3.0)
		if GameState.autotest:
			print("PLANK tight %d" % i)


## Bot (otomatik test): yığına gider kalas alır, ilk boş yuvaya koyar, bağlar. =slip: iki kalası bağlamadan bırakır
## ve bir kez dereye düşer (süre biter, dülgerler gevşek döşer → köprü kırılır).
func _bridge_bot(dt: float) -> void:
	_bridge_bot_t += dt
	_bot_hold = false
	if _bridge_bot_t < 0.35:
		return
	var slip := _variant() == "slip"
	if _carry_plank == null:
		for i in 6:
			if _plank_state[i] == "set" and not (slip and i >= 4):
				player.global_position = Vector3(-0.2, ThraceRoad.BEAM_Y + 0.12, ThraceRoad.PLANKS[i])
				_bot_hold = true
				return
		if level.pile_top() != null:
			_bridge_bot_t = 0.0
			player.global_position = ThraceRoad.PILE + Vector3(2.2, 0.1, 0)
			_take_plank()
		elif slip:
			_bridge_left = minf(_bridge_left, 0.5)
	else:
		var s := _first_empty()
		if s >= 0:
			_bridge_bot_t = 0.0
			player.global_position = Vector3(0, ThraceRoad.BEAM_Y + 0.12, float(ThraceRoad.PLANKS[s]) - 1.5)
			_place_plank(s)


# ---- kütükler: sehpa başındaki sırıkçılar savuşturur

func _tick_logs(dt: float) -> void:
	_log_t -= dt
	if _log_t <= 0.0:
		_log_t = randf_range(13.0, 19.0)
		_spawn_log()
	for lg: Dictionary in _logs.duplicate():
		var n: Node3D = lg["n"]
		lg["t"] = float(lg["t"]) + dt
		n.position.x += float(lg["v"]) * dt
		n.position.z = move_toward(n.position.z, float(lg["tz"]), float(lg["vz"]) * dt)
		n.position.y = ThraceRoad.WATER_Y + 0.05 + 0.05 * sin(float(lg["t"]) * 2.3)
		n.rotation.y = lerp_angle(n.rotation.y, 0.0, dt * 2.0)
		if not lg["warned"] and n.position.x > -26.0:
			lg["warned"] = true
			Audio.sfx("splash", -8.0, 0.7)
			if not _log_said:
				_log_said = true
				hud.bark("SPK_DULGER", "D35O_D_LOG", 2.5)
				get_tree().create_timer(3.2, false).timeout.connect(func():
					if phase == "bridge":
						hud.bark("SPK_TOLGA", "D35O_T_LOG", 4.0))
		if not lg["pushed"] and n.position.x > -5.2:
			_pole_push(lg)
		if n.position.x > 70.0:
			n.queue_free()
			_logs.erase(lg)


func _spawn_log() -> void:
	var n := Node3D.new()
	add_child(n)
	if randf() < 0.65:
		Props.cyl(n, 0.32, 4.2, Vector3.ZERO, Color("5a4030"), Vector3(0, 0, 90), 8)
		Props.cyl(n, 0.07, 1.1, Vector3(0.9, 0.25, 0.18), Color("4a3424"), Vector3(30, 0, 40), 5)
	else:
		for k in 5:
			Props.cyl(n, 0.07, 2.4, Vector3(randf_range(-0.6, 0.6), 0.1, randf_range(-0.3, 0.3)), Color("5a4a30"), Vector3(randf_range(-12, 12), randf_range(-15, 15), 90), 5)
	var side := -1 if randf() < 0.5 else 1
	n.position = Vector3(-62.0, ThraceRoad.WATER_Y + 0.05, side * 4.8 + randf_range(-0.4, 0.4))
	n.rotation.y = randf_range(-0.4, 0.4)
	_logs.append({"n": n, "v": 3.6, "vz": 0.0, "tz": n.position.z, "side": side, "pushed": false, "warned": false, "t": 0.0})


## Sırıkçı uzanır, kancayla kütüğü sehpa ayağından açıklığa iter (iki sehpanın arasından geçer)
func _pole_push(lg: Dictionary) -> void:
	lg["pushed"] = true
	logs_pushed += 1
	var man: Person = _pole_men[0 if int(lg["side"]) < 0 else 1] if _pole_men.size() == 2 else null
	lg["tz"] = float(lg["side"]) * 3.2
	lg["vz"] = 2.0
	lg["v"] = 2.6
	var n: Node3D = lg["n"]
	if man:
		# Kanca kütüğe uzanır, adam ileri abanır, sonra geri çekilir
		man.set_activity("thrust_b")
		man.set_meta("pole_tgt", n.global_position + Vector3(0, 0.3, 0))
		get_tree().create_timer(0.8, false).timeout.connect(func():
			if is_instance_valid(man):
				man.set_activity("thrust_a")
				man.remove_meta("pole_tgt"))
	get_tree().create_timer(0.35, false).timeout.connect(func():
		if is_instance_valid(n):
			Vfx.dust(self, n.global_position + Vector3(0, 0.3, 0), 0.4)
			Audio.sfx("splash", -6.0, 1.2))


## Kancalı sırık: elde değil sahnede durur, her karede sağ bilekten hedefe (dere yukarısında su ya da kütük) uzanır.
## Ele takılı sırık kolun pozuyla dönüp köprüye ya da göğe bakıyordu.
func _make_pole() -> Node3D:
	var pole := Node3D.new()
	add_child(pole)
	Props.cyl(pole, 0.026, 3.4, Vector3(0, 1.2, 0), Color("7a5a36"), Vector3.ZERO, 6)
	Props.cyl(pole, 0.032, 0.14, Vector3(0, 2.86, 0), Color("3a3634"), Vector3.ZERO, 6, 0.0)
	Props.box(pole, Vector3(0.022, 0.13, 0.022), Vector3(0.045, 2.92, 0), Color("3a3634"), Vector3(0, 0, -38))
	return pole


func _process(_delta: float) -> void:
	for k in mini(_pole_men.size(), _poles.size()):
		var pm := _pole_men[k]
		var hand := pm.global_position + Vector3(-0.35, 1.0, 0.18)
		var er: Node3D = pm.get("_elbow_r")
		if er:
			var wr := er.find_child("Wrist", false, false) as Node3D
			hand = (wr if wr else er).global_position + (Vector3.ZERO if wr else Vector3(0, -0.28, 0))
		var tgt: Vector3 = pm.get_meta("pole_tgt", Vector3(pm.global_position.x - 2.9, ThraceRoad.WATER_Y + 0.15, pm.global_position.z))
		var y := (tgt - hand).normalized()
		var x := y.cross(Vector3.FORWARD if absf(y.z) < 0.9 else Vector3.RIGHT).normalized()
		_poles[k].global_transform = Transform3D(Basis(x, y, x.cross(y)), hand)


# ---- dereye düşüş

var _falling := false


## Köprüden ya da kıyıdan dereye inen oyuncu (su yüzünün altına inince) akıntıya kapılır
func _check_fall() -> bool:
	var pp := player.global_position
	if pp.y < ThraceRoad.WATER_Y + 0.35 and absf(pp.z) < ThraceRoad.BEAM_Z + 0.6:
		_fall_in()
		return true
	return false


func _fall_in() -> void:
	if _falling:
		return
	_falling = true
	swept += 1
	print("SWEPT %d" % swept) if GameState.autotest else null
	player.frozen = true
	hud.set_prompt("")
	hud.set_red_progress(0.0)
	_ghost.visible = false
	var lost := _carry_plank != null
	_drop_carried()
	var start := player.global_position
	var water := Vector3(start.x - 0.4, ThraceRoad.WATER_Y - 0.6, clampf(start.z, -6.0, 6.0))
	Audio.sfx("splash", 0.0, 0.9)
	Vfx.dust(self, Vector3(start.x, ThraceRoad.WATER_Y, start.z), 0.8)
	player.hurt(10.0, Vector3.INF, true)
	var tw := create_tween()
	tw.tween_property(player, "global_position", water, 0.45)
	tw.tween_property(player, "global_position", water + Vector3(12.0, 0.2, 0), 2.6).set_trans(Tween.TRANS_SINE)
	await tw.finished
	# Yakın kıyıdan ip atılır
	var bank := Vector3(water.x + 13.0, ThraceRoad.ground_y(water.x + 13.0, -9.6) + 0.1, -9.6)
	var rope := Bogaz.make_rope(self, Color("c8b080"), 0.03)
	Bogaz.rope(rope, bank + Vector3(0, 1.0, 0), player.global_position + Vector3(0, 0.6, 0))
	hud.set_prompt(tr("UI_PROMPT35O_GRAB"))
	var t := 0.0
	while t < 6.0:
		await get_tree().process_frame
		if get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		t += get_process_delta_time()
		player.global_position += Vector3(0.5, 0, 0) * get_process_delta_time()
		Bogaz.rope(rope, bank + Vector3(0, 1.0, 0), player.global_position + Vector3(0, 0.6, 0))
		if Input.is_action_just_pressed("interact") or (GameState.autotest and t > 0.6):
			break
	hud.set_prompt("")
	var t2 := 0.0
	while t2 < 2.0:
		await get_tree().process_frame
		t2 += get_process_delta_time()
		player.global_position = player.global_position.lerp(bank, minf(1.0, get_process_delta_time() * 2.5))
		Bogaz.rope(rope, bank + Vector3(0, 1.0, 0), player.global_position + Vector3(0, 0.6, 0))
	rope.queue_free()
	hud.bark("SPK_DULGER" if lost else "SPK_TOLGA", "D35O_D_FISHED" if lost else "D35O_T_SWEPT", 4.0)
	# Köprü başına (yığının yanına) dönülür, yüz köprüye
	player.global_position = _gy(Vector3(1.2, 0, -11.2)) + Vector3(0, 0.1, 0)
	_face_bridge()
	player.frozen = false
	_falling = false


## Yüz köprüye döner (açılışta ve dereden çıkınca)
func _face_bridge() -> void:
	player.face(Vector3(0, player.global_position.y, 0))


# ---- konvoy geçer

func _crossing() -> void:
	phase = "crossing"
	player.global_position = _gy(Vector3(5.0, 0, 13.0)) + Vector3(0, 0.05, 0)
	player.face(Vector3(0, 1.0, -6.0))
	level.update_convoy(ThraceRoad.CONVOY_WAIT)
	hud.bark("SPK_DROVER", "D35O_DR_01", 4.0)
	var s := ThraceRoad.CONVOY_WAIT
	var creaked := false
	while s < S_MUD:
		await get_tree().process_frame
		if get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		var dt := get_process_delta_time()
		s += dt * 3.2
		level.update_convoy(s)
		level.spin_wheels(dt * 3.2)
		# Öndeki araba köprü ortasına gelince gevşek kalaslar gıcırdar
		var wz := s - 1.6
		if not creaked and wz > 0.0:
			creaked = true
			if loose >= 2:
				await _bridge_breaks(s)
			elif loose == 1:
				Audio.sfx("ship_haul", -2.0, 0.7)
				hud.bark("SPK_DULGER", "D35O_D_CREAK", 3.5)
	level.update_convoy(S_MUD)


func _bridge_breaks(s: float) -> void:
	broke = true
	slips += 1
	print("BRIDGE broke") if GameState.autotest else null
	# Kalas döner, teker dereye iner; herkes ipe
	var bad := -1
	for i in 6:
		if _plank_state[i] == "loose":
			bad = i
	var p: Node3D = level.planks[maxi(bad, 0)]
	var rest_rot: Vector3 = p.rotation
	var rest_pos: Vector3 = p.position
	var tw := p.create_tween()
	tw.tween_property(p, "rotation:x", 1.2, 0.4)
	tw.parallel().tween_property(p, "position:y", ThraceRoad.WATER_Y, 0.6)
	Audio.sfx("splash", 2.0, 0.8)
	Fx.trauma(0.5)
	level.update_convoy(s, 0.2)
	hud.bark("SPK_DULGER", "D35O_D_BREAK", 4.5)
	for m: Person in level.men:
		m.set_activity("lean")
	await get_tree().create_timer(3.5, false).timeout
	for m: Person in level.men:
		m.set_activity("")
	# Teker çıkarılır, kalas yeniden çakılır: konvoy bu açıklıktan artık sağlam kalasın üstünden geçer
	var fix := p.create_tween()
	fix.tween_property(p, "rotation", rest_rot, 0.8)
	fix.parallel().tween_property(p, "position", rest_pos, 0.8)
	Audio.sfx("ship_haul", -4.0, 1.2)
	await fix.finished
	level.update_convoy(s, 0.0)


# ================================================================ 2. çamur

var _bundles_needed := 3
var _bundles_set := 0
var _carry := false
var _held: Node3D
var _row := 0.0
var _tension := 0
var _whip_t := -1.0
var _mud_t := 0.0
var _taken := 0


func _mud() -> void:
	phase = "mud"
	_bundles_needed = 4 if broke else 3
	_mud_t = 0.0
	player.frozen = false
	hud.bark("SPK_URBAN", "D35O_U_01", 4.5)
	urban.global_position = _gy(Vector3(-3.6, 0, S_MUD + 2.0))
	get_tree().create_timer(5.0, false).timeout.connect(func(): hud.bark("SPK_TOLGA", "D35O_T_MUD", 3.5))
	meter.enabled = true
	meter.phase = 0.0
	var bot_t := 0.0
	var bad_left := 3 if _variant() == "slip" else 0
	while _row < ROW_GOAL:
		await get_tree().process_frame
		if get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		var dt := get_process_delta_time()
		_mud_t += dt
		level.sink = 0.45 * minf(1.0, _mud_t / 30.0) if _bundles_set < _bundles_needed else level.sink
		level.update_convoy(S_MUD + _row)
		# Otomatik test: RowMeter kendiliğinden basar; demetler yerleşmeden çekmesin
		if GameState.autotest:
			meter.enabled = _bundles_set >= _bundles_needed
		var wheel := _front_wheel()
		if _bundles_set < _bundles_needed:
			hud.set_objective(tr("UI_OBJ35O_BUNDLE") % [_bundles_set, _bundles_needed], wheel if _carry else ThraceRoad.BUNDLES + Vector3(0, 1.0, 0))
		else:
			hud.set_objective(tr("UI_OBJ35O_HEAVE") % [int(_row), int(ROW_GOAL)])
		var pr := ""
		if _carry and player.global_position.distance_to(wheel) < 2.4:
			pr = "UI_PROMPT35O_WHEEL"
		elif not _carry and _bundles_set < _bundles_needed and player.global_position.distance_to(_gy(ThraceRoad.BUNDLES)) < 2.6:
			pr = "UI_PROMPT35O_BUNDLE"
		hud.set_prompt(tr(pr) if pr != "" else "")
		if Input.is_action_just_pressed("jump"):
			meter.press()
		# Kopan halat: kamçı alanından çık
		if _whip_t >= 0.0:
			_whip_t -= dt
			if _whip_t < 0.0:
				_snap_resolve()
		if GameState.autotest:
			bot_t += dt
			if _bundles_set < _bundles_needed:
				if bot_t > 0.5:
					bot_t = 0.0
					if not _carry:
						player.global_position = _gy(ThraceRoad.BUNDLES + Vector3(-1.2, 0, 0)) + Vector3(0, 0.05, 0)
						_take_bundle()
					else:
						player.global_position = wheel + Vector3(-1.4, -wheel.y + ThraceRoad.ground_y(wheel.x - 1.4, wheel.z) + 0.05, 0.6)
						_place_bundle()
			else:
				if _whip_t >= 0.0:
					player.global_position = _gy(Vector3(-5.5, 0, S_MUD + _row - 6.0)) + Vector3(0, 0.05, 0)
				elif bad_left > 0 and meter.phase > 0.25 and meter.phase < 0.45 and not meter._pressed_this:
					bad_left -= 1
					player.global_position = _gy(Vector3(-1.6, 0, S_MUD + _row - 0.5)) + Vector3(0, 0.05, 0)
					meter.press()
				else:
					player.global_position = _gy(Vector3(-5.5, 0, S_MUD + _row - 4.0)) + Vector3(0, 0.05, 0)
	meter.enabled = false
	hud.set_prompt("")
	hud.set_objective("")
	hud.set_qte("")
	hud.bark("SPK_URBAN", "D35O_U_FREE", 3.5)
	await get_tree().create_timer(2.5, false).timeout
	player.frozen = true


func _front_wheel() -> Vector3:
	var w: Node3D = level.wagons[0]
	return w.global_position + Vector3(-1.2, 0.0, 1.6)


func _take_bundle() -> void:
	if _carry or _taken >= 6:
		return
	var b := level.bundle_node(5 - _taken)
	if b:
		b.visible = false
		if b.has_meta("body") and is_instance_valid(b.get_meta("body")):
			(b.get_meta("body") as Node).queue_free()
	_taken += 1
	_carry = true
	_held = Node3D.new()
	player.camera.add_child(_held)
	_held.position = Vector3(-0.25, -0.45, -0.8)
	player.free_hold = Vector3(-0.25, -0.36, -0.72)       # çalı demeti sol elde (havada asılıydı)
	Props.cyl(_held, 0.28, 1.2, Vector3.ZERO, Color("7a6a3a"), Vector3(0, 0, 80), 7)
	Props.strip_outlines(_held)
	player.speed_mult = 0.7
	Audio.sfx("land_pot", -10.0, 0.8)


func _place_bundle() -> void:
	if not _carry:
		return
	_carry = false
	_held.queue_free()
	player.free_hold = Vector3.INF
	player.speed_mult = 1.0
	_bundles_set += 1
	var w := _front_wheel()
	var at := Vector3(w.x + randf_range(-0.2, 0.2), ThraceRoad.ground_y(w.x, w.z + 0.9) + 0.08, w.z + 0.7 + _bundles_set * 0.15)
	for k in 4:
		Props.cyl(self, 0.05, 1.3, at + Vector3(randf_range(-0.3, 0.3), 0, randf_range(-0.2, 0.2)), Color("8a7a40"), Vector3(randf_range(-10, 10), randf_range(0, 180), 90), 5)
	Audio.sfx("land_pot", -6.0, 0.6)
	if _bundles_set >= _bundles_needed:
		level.sink = maxf(0.15, level.sink - 0.2)
		meter.phase = 0.0


func _on_stroke(good: bool) -> void:
	match phase:
		"mud":
			_heave(good)


func _heave(good: bool) -> void:
	if _whip_t >= 0.0:
		return
	if _bundles_set < _bundles_needed or not good:
		# Demetsiz ya da kırmızıda: geri kayar; kırmızıda halat gerilir
		slips += 1
		print("SLIP %d" % slips) if GameState.autotest else null
		_row = maxf(0.0, _row - 1.0)
		Audio.sfx("land_thud", -6.0, 0.6)
		hud.bark("SPK_URBAN", "D35O_U_SLIP", 2.5)
		if not good:
			_tension += 1
			if _tension == 2:
				hud.bark("SPK_URBAN", "D35O_U_ROPE", 3.0)
			if _tension >= 3:
				_tension = 0
				_whip_t = 0.8
				hud.set_qte(tr("UI_HINT35O_SNAP"))
				hud.bark("SPK_URBAN", "D35O_U_SNAP", 2.0)
				Audio.sfx("kick_metal", 0.0, 0.5)
		return
	var step := 1.5 if level.sink < 0.44 else 1.0
	_row += step
	level.spin_wheels(step)
	for m: Person in level.men:
		m.set_activity("lean")
	get_tree().create_timer(0.6, false).timeout.connect(_men_idle)
	for o: Ox in level.oxen:
		if randf() < 0.3:
			o.bellow()
	Vfx.dust(self, _front_wheel(), 0.5)
	Audio.sfx("ship_haul", -6.0, 0.9)
	if int(_row / 1.5) == 2:
		hud.bark("SPK_URBAN", "D35O_U_HEAVE", 3.0)


func _men_idle() -> void:
	for m: Person in level.men:
		if is_instance_valid(m) and phase == "mud":
			m.set_activity("")


## Halat koptu: kamçı alanındaysan (öndeki arabanın yanı) −20 can ve yere düşersin; 6 sn kayıp
func _snap_resolve() -> void:
	snaps += 1
	print("ROPE_SNAP %d" % snaps) if GameState.autotest else null
	hud.set_qte("")
	var w: Node3D = level.wagons[0]
	var p := player.global_position
	if absf(p.x - w.global_position.x) < 3.0 and absf(p.z - w.global_position.z) < 4.5:
		player.hurt(20.0, w.global_position)
		player.stagger(1.5)
	else:
		hud.bark("SPK_TOLGA", "D35O_T_SNAP", 3.5)
	for m: Person in level.men:
		m.set_activity("fall")
	await get_tree().create_timer(6.0, false).timeout
	for m: Person in level.men:
		m.set_activity("")


# ================================================================ 3. yokuş

var _post := 1
var _red_r := 0.0
var _red_l := 0.0
var _tight_warned := false
var _brake_rope: MeshInstance3D


func _slope() -> void:
	phase = "slope_intro"
	if is_instance_valid(_held):          # çamur bitti: elde kalan demet bırakılır (yokuşta sağ altta asılı kalıyordu)
		_held.queue_free()
		_carry = false
		player.free_hold = Vector3.INF
		player.speed_mult = 1.0
	await hud.fade_to(1.0, 0.6)
	level.make_afternoon()
	await hud.card([[tr("UI_CH35O_SLOPE"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	var s := S_SLOPE0
	level.sink = 0.0
	level.update_convoy(s)
	player.global_position = _gy(ThraceRoad.POST1 + Vector3(0.8, 0, -1.2)) + Vector3(0, 0.05, 0)
	player.face(_gy(Vector3(0, 0, 70)) + Vector3(0, 1.0, 0))
	urban.global_position = _gy(Vector3(6.4, 0, 46.5))
	_brake_rope = Bogaz.make_rope(self, Color("c8b080"), 0.035)
	await hud.fade_to(0.0, 0.6)
	await hud.say("SPK_URBAN", "D35O_U_SLOPE")
	await hud.say("SPK_TOLGA", "D35O_T_SLOPE")
	phase = "slope"
	player.frozen = true
	balance.visible = true
	balance.show_keys = false
	balance.value = 0.0
	var t := 0.0
	var bump_t := 3.5
	var karaca_done := false
	var transfer_t := -1.0
	var horse: Horse
	var slips_before := slips
	var smoke_t := 0.0
	while t < SLOPE_TIME and s < S_SLOPE1:
		await get_tree().process_frame
		if get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		var dt := get_process_delta_time()
		t += dt
		# İbre: yerçekimi sağa iter; E basılıyken sola (sık)
		var holding := Input.is_action_pressed("interact")
		if GameState.autotest:
			holding = balance.value > 0.0
		if transfer_t >= 0.0:
			holding = false
			balance.value += 0.18 * dt
		else:
			balance.value += (0.22 + randf_range(-0.1, 0.1)) * dt
			if holding:
				balance.value -= 0.6 * dt
				smoke_t -= dt
				if smoke_t <= 0.0:
					smoke_t = 0.35
					Vfx.dust(self, _post_pos() + Vector3(0, 0.8, 0), 0.15)
		bump_t -= dt
		if bump_t <= 0.0:
			bump_t = randf_range(3.0, 5.0)
			balance.value += 0.28
			Audio.sfx("land_thud", -14.0, 0.8)
		balance.value = clampf(balance.value, -1.2, 1.2)
		s += (0.85 + 0.55 * balance.value) * dt
		level.update_convoy(s)
		level.spin_wheels((0.85 + 0.55 * balance.value) * dt)
		var rear: Node3D = level.wagons[5]
		Bogaz.rope(_brake_rope, _post_pos() + Vector3(0, 0.7, 0), rear.global_position + Vector3(0, 0.55, -1.4))
		# Karaca Bey geçer: atın ürkmesi ibreyi bir kez sert iter
		if not karaca_done and t > 14.0:
			karaca_done = true
			horse = _karaca()
		# Aktarma
		if _post == 1 and t > 30.0 and transfer_t < 0.0:
			transfer_t = 0.0
			hud.bark("SPK_URBAN", "D35O_U_POST", 3.0)
			player.frozen = false
		if transfer_t >= 0.0:
			transfer_t += dt
			var near := player.global_position.distance_to(_gy(ThraceRoad.POST2)) < 2.0
			hud.set_objective(tr("UI_OBJ35O_POST") % maxi(0, ceili(6.0 - transfer_t)), ThraceRoad.POST2 + Vector3(0, 1.4, 0))
			hud.set_prompt(tr("UI_PROMPT35O_POST") if near else "")
			var bot_go := GameState.autotest and transfer_t > (8.0 if _variant() == "slip" else 2.5)
			if bot_go:
				player.global_position = _gy(ThraceRoad.POST2 + Vector3(0.8, 0, -1.0)) + Vector3(0, 0.05, 0)
				near = true
			if (near and Input.is_action_just_pressed("interact")) or bot_go or transfer_t > 10.0:
				_post = 2
				transfer_t = -1.0
				player.frozen = true
				hud.set_prompt("")
				Audio.sfx("ship_haul", -6.0, 1.1)
		else:
			hud.set_objective(tr("UI_OBJ35O_BRAKE"), _post_pos() + Vector3(0, 1.4, 0))
		# Kırmızı bölgeler
		if balance.value > 0.8:
			_red_r += dt
			if _red_r > 0.3 and _red_r - dt <= 0.3:
				hud.bark("SPK_URBAN", "D35O_U_RUN", 2.0)
			if _red_r >= 1.0:
				await _slide(s)
		else:
			_red_r = 0.0
		if balance.value < -0.8:
			_red_l += dt
			if _red_l >= 1.5:
				_red_l = 0.0
				for o: Ox in level.oxen:
					o.bellow()
				if not _tight_warned:
					_tight_warned = true
					hud.bark("SPK_URBAN", "D35O_U_TIGHT", 3.0)
					balance.value = 0.0
				else:
					slips += 1
					snaps += 1
					print("ROPE_SNAP %d" % snaps) if GameState.autotest else null
					hud.bark("SPK_URBAN", "D35O_U_SNAP", 2.5)
					await _slide(s)
		else:
			_red_l = 0.0
	# Sona
	var tw := create_tween()
	tw.tween_method(func(v: float): level.update_convoy(v), s, S_SLOPE1, 2.0)
	await tw.finished
	balance.visible = false
	hud.set_objective("")
	hud.set_prompt("")
	_brake_rope.queue_free()
	if horse:
		horse.queue_free()
	if slips == slips_before and slips <= 1:
		hud.bark("SPK_URBAN", "D35O_U_SLOPE_OK", 4.0)
	await get_tree().create_timer(2.5, false).timeout


func _post_pos() -> Vector3:
	return _gy(ThraceRoad.POST1 if _post == 1 else ThraceRoad.POST2)


func _karaca() -> Horse:
	var h := Horse.new(Color("3a2a1a"), Color("2a4a8a"))
	add_child(h)
	var r := Person.new({"coat": Color("2a4a8a"), "pants": Color("e8e0d0"), "hat": "kalpak", "beard": true, "mustache": true, "skin": Color("c89070")})
	r.set_meta("spk", "SPK_KARACA")
	h.mount(r)
	h.position = _gy(Vector3(-6.0, 0, 95.0))
	h.rotation.y = PI
	h.speed = 2.0
	var tw := h.create_tween()
	tw.tween_method(func(k: float): h.position = _gy(Vector3(-6.0, 0, lerpf(95.0, 30.0, k))), 0.0, 1.0, 26.0)
	hud.bark("SPK_KARACA", "D35O_K_01", 4.5)
	get_tree().create_timer(4.8, false).timeout.connect(func(): hud.bark("SPK_URBAN", "D35O_U_K1", 4.0))
	get_tree().create_timer(9.2, false).timeout.connect(func(): hud.bark("SPK_KARACA", "D35O_K_02", 3.5))
	get_tree().create_timer(3.0, false).timeout.connect(_spook)
	return h


func _spook() -> void:
	if phase == "slope":
		balance.value += 0.45


## Kayma: araba yan hendeğe kayar, 10° yatar; adamlar halata asılır, çıkarılır
func _slide(s: float) -> void:
	slips += 1
	print("SLIP %d" % slips) if GameState.autotest else null
	_red_r = 0.0
	Fx.trauma(0.6)
	Audio.sfx("rumble", -2.0, 0.8)
	hud.bark("SPK_URBAN", "D35O_U_SLIDE", 4.0)
	level.update_convoy(s, 0.17)
	for m: Person in level.men:
		m.set_activity("lean")
	await get_tree().create_timer(5.0, false).timeout
	level.update_convoy(s, 0.0)
	for m: Person in level.men:
		m.set_activity("")
	balance.value = 0.0


# ================================================================ 4. gece konağı

var _runners: Array[Dictionary] = []
var _hold: Dictionary = {}
var _hold_t := 0.0
var _mudfall_said := false
var _down_t := 0.0


func _night() -> void:
	phase = "night_intro"
	await hud.fade_to(1.0, 0.8)
	level.make_night()
	level.light_camp()
	level.update_convoy(S_SLOPE1 + 2.0)
	for o: Ox in level.oxen:
		o.lie(true)
	Audio.ambience("night_camp")
	await hud.card([[tr("UI_CH35O_NIGHT"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	player.global_position = _gy(ThraceRoad.CAMP + Vector3(-3.0, 0, 4.0)) + Vector3(0, 0.05, 0)
	player.face(_gy(Vector3(-6.0, 0, ThraceRoad.STAKES_Z)) + Vector3(0, 1.0, 0))
	level.drover.global_position = _gy(ThraceRoad.CAMP + Vector3(-6.0, 0, 9.0))
	urban.global_position = _gy(ThraceRoad.CAMP + Vector3(4.0, 0, -2.0))
	await hud.fade_to(0.0, 0.8)
	await get_tree().create_timer(1.5, false).timeout
	Audio.sfx("rumble", -14.0, 1.6)
	hud.bark("SPK_DROVER", "D35O_DR_SPOOK", 5.0)
	# Dört öküz ipini koparır: üçü oyuncuya (ateş, çadırlar, koru), biri arabacıya
	var goals := [level.fires[0].position, level.tents[1].position, ThraceRoad.GROVE, ThraceRoad.CAMP + Vector3(14.0, 0, 30.0)]
	var names := ["Sarıkız", "Karabaş", "Benekli", ""]
	for k in 4:
		var o: Ox = level.camp_oxen[1 + k * 2]
		var rope := Bogaz.make_rope(self, Color("b89a6a"), 0.025)
		var end := Node3D.new()
		add_child(end)
		Props.ball(end, 0.08, Vector3.ZERO, Color("b89a6a"), Vector3.ONE, 6)
		_runners.append({"o": o, "goal": goals[k], "state": "run", "rope": rope, "end": end, "name": names[k], "drover": k == 3, "t": 0.0})
		o.bellow()
	phase = "night"
	player.frozen = false
	var left := NIGHT_TIME
	var bot_t := 0.0
	while left > 0.0 and caught < 3:
		await get_tree().process_frame
		if get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		var dt := get_process_delta_time()
		left -= dt
		_tick_runners(dt)
		hud.set_objective(tr("UI_OBJ35O_OXEN") % [caught, 3], _nearest_runner_pos())
		if GameState.autotest and _hold.is_empty() and _down_t <= 0.0:
			bot_t += dt
			if bot_t > 0.6:
				bot_t = 0.0
				for r: Dictionary in _runners:
					if r["state"] == "run" and not r["drover"]:
						player.global_position = _gy((r["end"] as Node3D).global_position + Vector3(0.6, 0, 0)) + Vector3(0, 0.05, 0)
						_grab()
						break
	balance.visible = false
	_hold = {}
	hud.set_prompt("")
	for r: Dictionary in _runners:
		if r["state"] != "calm":
			r["state"] = "calm"
	player.frozen = true
	hud.set_objective("")
	hud.bark("SPK_DROVER", "D35O_DR_03", 4.5)
	await get_tree().create_timer(3.0, false).timeout
	for o: Ox in level.camp_oxen:
		o.lie(true)
	await _photo_gun()


func _nearest_runner_pos() -> Vector3:
	var best := Vector3.ZERO
	var bd := INF
	for r: Dictionary in _runners:
		if r["state"] == "calm" or r["drover"]:
			continue
		var p: Vector3 = (r["o"] as Node3D).global_position
		var d := p.distance_to(player.global_position)
		if d < bd:
			bd = d
			best = p + Vector3(0, 2.0, 0)
	return best


func _tick_runners(dt: float) -> void:
	var prompt := ""
	if _down_t > 0.0:
		_down_t -= dt
		if _down_t <= 0.0:
			player.frozen = false
	for r: Dictionary in _runners:
		var o: Ox = r["o"]
		var end: Node3D = r["end"]
		r["t"] = float(r["t"]) + dt
		match String(r["state"]):
			"run":
				var g: Vector3 = r["goal"]
				var to := Vector3(g.x, 0, g.z) - Vector3(o.position.x, 0, o.position.z)
				var spd := 2.0 if to.length() > 3.0 else 0.6
				var dir := to.normalized() if to.length() > 0.5 else Vector3(sin(float(r["t"])), 0, cos(float(r["t"])))
				var np := o.position + dir * spd * dt
				o.position = _gy(np)
				o.rotation.y = atan2(dir.x, dir.z)
				if r["drover"] and float(r["t"]) > 7.0:
					r["state"] = "calm"
					o.bellow()
				elif not r["drover"] and player.global_position.distance_to(end.global_position) < 1.6:
					prompt = "UI_PROMPT35O_OX"
			"held":
				# Tutulan öküz yavaşlar; oyuncu ipin ucunda
				var g2: Vector3 = r["goal"]
				var dir2 := (Vector3(g2.x, 0, g2.z) - Vector3(o.position.x, 0, o.position.z)).normalized()
				o.position = _gy(o.position + dir2 * 0.5 * dt)
		var back := -Vector3(sin(o.rotation.y), 0, cos(o.rotation.y))
		var tail := o.global_position + back * 2.4
		end.global_position = _gy(tail) + Vector3(0, 0.08, 0)
		if r["state"] != "calm":
			Bogaz.rope(r["rope"], o.global_position + Vector3(0, 1.0, 0) - back * 1.2, end.global_position)
			(r["rope"] as Node3D).visible = true
		else:
			(r["rope"] as Node3D).visible = false
	if not _hold.is_empty():
		_hold_tick(dt)
	else:
		hud.set_prompt(tr(prompt) if prompt != "" else "")


func _grab() -> void:
	if not _hold.is_empty() or _down_t > 0.0:
		return
	for r: Dictionary in _runners:
		if r["state"] == "run" and not r["drover"] and player.global_position.distance_to((r["end"] as Node3D).global_position) < 1.6:
			r["state"] = "held"
			_hold = r
			_hold_t = 0.0
			balance.visible = true
			balance.show_keys = true
			balance.value = randf_range(-0.2, 0.2)
			player.frozen = true
			hud.bark("SPK_DROVER", "D35O_DR_GOT", 3.0)
			return


func _hold_tick(dt: float) -> void:
	var o: Ox = _hold["o"]
	var back := -Vector3(sin(o.rotation.y), 0, cos(o.rotation.y))
	player.global_position = _gy(o.global_position + back * 2.8) + Vector3(0, 0.05, 0)
	player.face(o.global_position + Vector3(0, 1.0, 0))
	if not GameState.autotest:
		balance.value += randf_range(-1.3, 1.3) * dt + signf(balance.value) * 0.4 * dt
		balance.value += Input.get_axis("move_left", "move_right") * 1.7 * dt
	else:
		balance.value = move_toward(balance.value, 0.0, dt)
	if absf(balance.value) < 0.4:
		_hold_t += dt
	hud.set_prompt(tr("UI_PROMPT35O_NAME") if _hold_t >= 4.0 else "")
	if _hold_t >= 4.0 and (Input.is_action_just_pressed("interact") or GameState.autotest):
		_hold["state"] = "calm"
		caught += 1
		o.bellow()
		Vfx.steam(self, o.global_position + Vector3(0, 1.4, 0) - back * 1.5)
		# Her öküzün kendi adı var (Sarıkız, Karabaş, Benekli): onu çağırarak sakinleştirir
		var calm_lines := {"Sarıkız": "D35O_T_CALM", "Karabaş": "D35O_T_CALM_KARABAS", "Benekli": "D35O_T_CALM_BENEKLI"}
		hud.bark("SPK_TOLGA", calm_lines.get(str(_hold.get("name", "")), "D35O_T_CALM"), 3.0)
		balance.visible = false
		_hold = {}
		player.frozen = false
		return
	if balance.value > 0.95:
		# Fazla gevşek: ip elden çıkar
		_hold["state"] = "run"
		_hold = {}
		balance.visible = false
		player.frozen = false
		Audio.sfx("ship_haul", -6.0, 1.5)
	elif balance.value < -0.95:
		# Fazla sert: yüzüstü çamura
		_hold["state"] = "run"
		_hold = {}
		balance.visible = false
		player.hurt(10.0, Vector3.INF, true)
		Vfx.dust(self, player.global_position, 0.6)
		_down_t = 3.0
		if not _mudfall_said:
			_mudfall_said = true
			hud.bark("SPK_TOLGA", "D35O_T_MUDFALL", 4.0)


func _photo_gun() -> void:
	player.frozen = false
	var target := Node3D.new()
	level.gun.add_child(target)
	target.position = Vector3(0, 0.8, 3.6)
	hud.set_objective(tr("UI_OBJ35O_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege35o")
	hud.add_child(cam)
	cam.max_dist = 40.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and (t < 3.0 or not GameState.autotest):
		await get_tree().process_frame
		if get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		t += get_process_delta_time()
		if GameState.autotest:
			player.global_position = _gy(target.global_position + Vector3(3.0, 0, 6.0)) + Vector3(0, 0.05, 0)
			player.face(target.global_position)
		if t > 60.0:
			break
	cam.stop()
	hud.set_objective("")
	player.frozen = true
	if not _photo.is_empty():
		hud.bark("SPK_TOLGA", "D35O_T_PHOTO", 4.0)
		await get_tree().create_timer(2.5, false).timeout
	_outcome = "35O.1" if slips <= 1 and not broke else "35O.2"
	urban.global_position = _gy(player.global_position + Vector3(-1.8, 0, -1.2))
	urban.look_target = player
	await hud.say("SPK_URBAN", "D35O_U_DAY")
	await hud.say("SPK_TOLGA", "D35O_T_DAY")
	await hud.say("SPK_URBAN", "D35O_U_END_OK" if _outcome == "35O.1" else "D35O_U_END_BAD")
	await hud.say("SPK_NIHAT", "D35O_N_END")
	await hud.say("SPK_TOLGA", "D35O_T_END")
	Siege.record(35, _photo, "SIEGE_NOTE_35O_%s" % _outcome.split(".")[1])


# ================================================================ giriş

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	match phase:
		"mud":
			var wheel := _front_wheel()
			if _carry and player.global_position.distance_to(wheel) < 2.4:
				_place_bundle()
			elif not _carry and _bundles_set < _bundles_needed and player.global_position.distance_to(_gy(ThraceRoad.BUNDLES)) < 2.6:
				_take_bundle()
		"night":
			if _hold.is_empty():
				_grab()


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(35, _outcome)
	await Siege.show_page(hud, 35)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(35)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			GameState.replay_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW35O_TITLE")
	c.nodes = [
		{"id": "bridge", "key": "FLOW35O_BRIDGE", "pos": Vector2(0.5, 0.12)},
		{"id": "mud", "key": "FLOW35O_MUD", "pos": Vector2(0.5, 0.26)},
		{"id": "slope", "key": "FLOW35O_SLOPE", "pos": Vector2(0.5, 0.40)},
		{"id": "camp", "key": "FLOW35O_CAMP", "pos": Vector2(0.5, 0.54)},
		{"id": "35O.1", "key": "FLOW_35O_1", "pos": Vector2(0.3, 0.70), "outcome": true},
		{"id": "35O.2", "key": "FLOW_35O_2", "pos": Vector2(0.7, 0.70), "outcome": true},
	]
	c.edges = [["bridge", "mud"], ["mud", "slope"], ["slope", "camp"], ["camp", "35O.1"], ["camp", "35O.2"]]
	for k in ["bridge", "mud", "slope", "camp"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		Grade.finish("35o"),
		tr("UI_CH35O_STATS") % [loose, swept, slips, caught, 3, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		GameState.tr_pad("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "35O.1", "slip": "35O.2"}.get(v, "35O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("35", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null
	match v:
		"":
			ok = ok and loose == 0 and swept == 0 and not broke and slips == 0 and snaps == 0 and caught == 3 and cam.done
		"slip":
			ok = ok and broke and swept >= 1 and snaps >= 1 and slips >= 2
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s gevşek=%d düşüş=%d kırık=%s kayma=%d kopma=%d kütük=%d/%d öküz=%d foto=%s)" % [
			expected, _outcome, not page.is_empty(), loose, swept, broke, slips, snaps, logs_pushed, logs_missed, caught, cam != null and cam.done])
	print("AUTOTEST %s chapter=35o variant=%s outcome=%s loose=%d swept=%d broke=%s slips=%d snaps=%d logs=%d/%d oxen=%d" % [
		"PASS" if ok else "FAIL", v, _outcome, loose, swept, broke, slips, snaps, logs_pushed, logs_missed, caught])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot_png(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	hud.visible = false
	player.show_remote(false)
	var cv := Camera3D.new()
	add_child(cv)
	cv.fov = 60.0
	cv.make_current()
	# Kapak: yokuşta konvoy (öküzler, arabalar, top), arkada vadi
	level.make_afternoon()
	level.update_convoy(84.0)
	cv.global_position = Vector3(9.0, ThraceRoad.ground_y(9.0, 92.0) + 3.4, 92.0)
	cv.look_at(Vector3(-1.0, ThraceRoad.ground_y(0.0, 72.0) + 1.0, 72.0), Vector3.UP)
	await get_tree().create_timer(1.2, false).timeout
	await _shot_png("c35o_cover.png")
	# Köprü: yarım köprü ve kalaslar
	level.make_day()
	for i in 3:
		level.set_plank(i)
		level.lash_rings(i, 2, false)
	level.update_convoy(ThraceRoad.CONVOY_WAIT)
	cv.global_position = Vector3(-7.0, 1.6, 9.0)
	cv.look_at(Vector3(0.0, 0.0, -2.0), Vector3.UP)
	await get_tree().create_timer(0.6, false).timeout
	await _shot_png("c35o_01_bridge.png")
	if OS.get_environment("SHOTS35_DETAIL") == "1":
		# Sırıkçılar (dere yukarısından) ve köprü başı (kıyıdan)
		_spawn_log()
		(_logs[0]["n"] as Node3D).position = Vector3(-7.0, ThraceRoad.WATER_Y + 0.05, -4.6)
		cv.global_position = Vector3(-9.0, 2.2, -1.0)
		cv.look_at(Vector3(-1.5, 0.0, -3.5), Vector3.UP)
		await get_tree().create_timer(0.6, false).timeout
		await _shot_png("c35o_d1_polemen.png")
		_pole_men[0].set_activity("thrust_b")
		await get_tree().create_timer(0.6, false).timeout
		await _shot_png("c35o_d2_push.png")
		cv.global_position = Vector3(3.0, 1.8, -14.5)
		cv.look_at(Vector3(-1.0, 0.0, -6.0), Vector3.UP)
		await get_tree().create_timer(0.4, false).timeout
		await _shot_png("c35o_d3_head.png")
		cv.global_position = Vector3(-2.6, 0.7, -8.0)
		cv.look_at(Vector3(-1.55, 0.3, -6.5), Vector3.UP)
		await get_tree().create_timer(0.4, false).timeout
		await _shot_png("c35o_d4_lash.png")
		for i in 6:
			level.set_plank(i)
		level.update_convoy(4.0)
		cv.global_position = Vector3(14.0, 3.0, 2.0)
		cv.look_at(Vector3(0.0, 0.5, 0.0), Vector3.UP)
		await get_tree().create_timer(0.4, false).timeout
		await _shot_png("c35o_d5_cross.png")
		level.update_convoy(ThraceRoad.CONVOY_WAIT)
	# Çamur
	level.update_convoy(S_MUD)
	level.sink = 0.35
	level.update_convoy(S_MUD)
	cv.global_position = Vector3(6.0, 2.2, S_MUD + 6.0)
	cv.look_at(Vector3(0.0, 0.8, S_MUD - 3.0), Vector3.UP)
	await get_tree().create_timer(0.6, false).timeout
	await _shot_png("c35o_02_mud.png")
	# Gece konağı
	level.make_night()
	level.light_camp()
	level.update_convoy(S_SLOPE1 + 2.0)
	for o: Ox in level.oxen:
		o.lie(true)
	cv.global_position = Vector3(10.0, ThraceRoad.ground_y(10.0, ThraceRoad.CAMP.z - 12.0) + 3.0, ThraceRoad.CAMP.z - 12.0)
	cv.look_at(Vector3(-6.0, ThraceRoad.ground_y(-6.0, ThraceRoad.CAMP.z + 6.0) + 0.8, ThraceRoad.CAMP.z + 6.0), Vector3.UP)
	await get_tree().create_timer(1.0, false).timeout
	await _shot_png("c35o_03_night.png")
	get_tree().quit()
