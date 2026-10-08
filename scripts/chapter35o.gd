extends Node3D
## Bölüm 35 (yalnız Osmanlı tarafı) — Edirne Yolu (Tolga · Şubat–Mart 1453, Trakya). docs/OTTOMAN_NEW_A.md §3.
##
##   1. Taşkın: köprünün kirişinde dengede (A/D) yürü (W/S); dülgerlerin sürdüğü altı kalası direğe iki bağla bağla
##      (yeşilde E, iki kez; ıska = gevşek, dönüp yeniden bağlanır). Dere yukarısından kütük gelir: halkaya girince
##      sırıkla it (E); kaçan kütük sehpaya çarpar, son kalasın bir bağı çözülür. Kirişten düşen dereye düşer, ipe tutunur.
##      ≥2 gevşek kalas → konvoy geçerken teker dereye iner (köprü kırıldı).
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
	urban.position = _gy(Vector3(-4.0, 0, -14.0))
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
		c.position = _gy(Vector3(-2.2 + k * 2.2, 0, -10.6))
		c.look_target = player if k == 0 else null
		carpenters.append(c)
	carpenters[2].set_activity("hammer")


func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH35O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH35O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = _gy(Vector3(-0.9, 0, -9.6)) + Vector3(0, 0.1, 0)
	player.face(Vector3(0, 0, 10))
	player.show_remote(false)
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

var _plank_i := 0                 # sıradaki kalas
var _plank_state: Array = ["", "", "", "", "", ""]   # "" | "sliding" | "set" | "tight" | "loose"
var _lash_target := -1            # bağlanan kalas
var _lash_presses := 0
var _lash_bad := false
var _beam_z := -9.6
var _logs: Array[Dictionary] = []
var _log_t := 7.0
var _log_said := false
var _ring: MeshInstance3D
var _bridge_bot_t := 0.0
var _slip_bad_left := 0


func _bridge() -> void:
	phase = "bridge"
	player.frozen = true
	# Kirişte yürüyüşü bölüm sürer ama fare donmaz: etrafa bakılır (eskiden kamera kilitliydi, "bir şey yapamıyorum")
	player.free_look = true
	_beam_z = -9.6
	_ring = Props.ring(self, 1.2, 1.5, Vector3(-3.4, ThraceRoad.WATER_Y + 0.06, 0), Color("40e060"), Vector3.ZERO, 1.2)
	_ring.visible = false
	var left := BRIDGE_TIME
	var all_t := 0.0
	var bot_fell := false
	_slip_bad_left = 2 if _variant() == "slip" else 0
	_slide_plank(0)
	while left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		_bridge_move(dt)
		_tick_logs(dt)
		# Sıradaki kalas: bir öncekisi oturunca kızakla sürülür
		if _plank_i < 6 and _plank_state[_plank_i] == "" and (_plank_i == 0 or _plank_state[_plank_i - 1] in ["tight", "loose"]):
			_slide_plank(_plank_i)
		var placed := _plank_state.count("tight") + _plank_state.count("loose")
		var n_loose := _plank_state.count("loose")
		hud.set_objective(tr("UI_OBJ35O_LASH") % [placed, 6], _focus_post())
		if placed == 6:
			all_t += dt
			if n_loose == 0 or all_t > 25.0:
				break
		if GameState.autotest:
			_bridge_bot(dt)
			if _variant() == "slip" and not bot_fell and placed >= 2:
				bot_fell = true
				await _fall_in()
	if _lash_target >= 0:
		_finish_lash()
	# Süre bitti: dülgerler kalanları gevşek döşer
	for i in 6:
		if _plank_state[i] in ["", "sliding", "set"]:
			level.set_plank(i)
			_plank_state[i] = "loose"
			level.lash_rings(i, 1, true)
	meter.enabled = false
	balance.visible = false
	_ring.visible = false
	player.free_look = false
	hud.set_prompt("")
	hud.set_qte("")
	hud.set_objective("")
	loose = _plank_state.count("loose")
	hud.bark("SPK_TOLGA", "D35O_T_BRIDGE", 4.0)
	await get_tree().create_timer(2.0).timeout


func _focus_post() -> Vector3:
	for i in 6:
		if _plank_state[i] == "loose" and _plank_i >= 6:
			return level.lash_posts[i]
	return level.lash_posts[mini(_plank_i, 5)]


func _slide_plank(i: int) -> void:
	_plank_state[i] = "sliding"
	var p: Node3D = level.planks[i]
	var to := Vector3(0, ThraceRoad.BEAM_Y + 0.05, ThraceRoad.PLANKS[i])
	# Dülgerler kızağı iter (öne eğik), uçtan toz
	for c: Person in carpenters.slice(0, 2):
		c.set_activity("lean")
	var tw := p.create_tween()
	tw.tween_property(p, "position", Vector3(0, ThraceRoad.BEAM_Y + 0.05, -9.0), 0.6)
	tw.tween_property(p, "position", to, 1.4 + i * 0.25).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_plank_landed.bind(i))


func _plank_landed(i: int) -> void:
	level.set_plank(i)
	_plank_state[i] = "set"
	Vfx.dust(self, (level.planks[i] as Node3D).global_position, 0.3)
	Audio.sfx("land_thud", -10.0, 1.3)
	for c: Person in carpenters.slice(0, 2):
		c.set_activity("")


## Kirişte yürüyüş: W/S boyunca, A/D denge. Bağlı kalasın üstünde denge gerekmez; gevşekte hafif oynar.
func _bridge_move(dt: float) -> void:
	if _falling:
		return
	var fwd := Input.get_axis("move_back", "move_forward")
	# W bakılan yöne: dereye arkasını dönüp geri bakan oyuncu W'ye basınca geri yürür
	var look_z := -player.camera.global_transform.basis.z.z
	_beam_z = clampf(_beam_z + fwd * (1.0 if look_z > -0.3 else -1.0) * 2.2 * dt, -9.8, 9.8)
	var on_beam := absf(_beam_z) < ThraceRoad.BEAM_Z - 0.3
	var over := -1
	for i in 6:
		if absf(_beam_z - float(ThraceRoad.PLANKS[i])) < ThraceRoad.PLANK_LEN * 0.5 and _plank_state[i] in ["tight", "loose"]:
			over = i
	var need: bool = on_beam and (over < 0 or _plank_state[over] == "loose")
	balance.visible = need
	if need and not GameState.autotest:
		var k := 0.35 if over >= 0 else 1.0
		balance.value += (signf(balance.value) * 0.55 + randf_range(-0.9, 0.9)) * k * dt
		balance.value -= Input.get_axis("move_left", "move_right") * 1.6 * dt
		if absf(balance.value) >= 1.0:
			_fall_in()
			return
	elif not need:
		balance.value = move_toward(balance.value, 0.0, dt)
	var y := ThraceRoad.BEAM_Y + 0.1 if on_beam else ThraceRoad.ground_y(-0.9, _beam_z) + 0.1
	player.global_position = Vector3(-ThraceRoad.BEAM_X + balance.value * 0.12, y, _beam_z)
	# Bağlama ve itme istemi
	var pr := ""
	if _log_in_ring() != {}:
		pr = "UI_PROMPT35O_PUSH"
	elif _lash_target < 0 and _post_near() >= 0:
		pr = "UI_PROMPT35O_LASH"
	# İstem yoksa kirişin tuşları görünür (W/S yürü, A/D denge, fare bak, E bağla/it)
	hud.set_prompt(tr(pr) if pr != "" else tr("UI_HINT35O_BEAM"))


func _post_near() -> int:
	for i in 6:
		if _plank_state[i] in ["set", "loose"] and absf(_beam_z - float(ThraceRoad.PLANKS[i])) < 1.2:
			return i
	return -1


func _bridge_input() -> void:
	var lg := _log_in_ring()
	if lg != {}:
		_push_log(lg)
		return
	if _lash_target >= 0:
		meter.press()
		return
	var i := _post_near()
	if i >= 0:
		_start_lash(i)


func _start_lash(i: int) -> void:
	_lash_target = i
	_lash_presses = 0
	_lash_bad = false
	meter.phase = 0.0
	meter.enabled = true
	hud.set_qte(tr("UI_PROMPT35O_LASH"))


func _lash_stroke(good: bool) -> void:
	_lash_presses += 1
	if not good:
		_lash_bad = true
	level.lash_rings(_lash_target, _lash_presses, false)
	Audio.sfx("ship_haul", -10.0, 1.4)
	if _lash_presses >= 2:
		_finish_lash()


func _finish_lash() -> void:
	var i := _lash_target
	meter.enabled = false
	hud.set_qte("")
	_lash_target = -1
	if i < 0:
		return
	var tight := not _lash_bad and _lash_presses >= 2
	_plank_state[i] = "tight" if tight else "loose"
	level.lash_rings(i, maxi(_lash_presses, 1), not tight)
	hud.bark("SPK_DULGER", "D35O_D_LASH_OK" if tight else "D35O_D_LASH_BAD", 3.0)
	if i == _plank_i:
		_plank_i += 1


## Bot (otomatik test): sıradaki kalasın direğine yürür, bağlar; halkaya giren kütüğü iter
func _bridge_bot(dt: float) -> void:
	_bridge_bot_t += dt
	var lg := _log_in_ring()
	if lg != {}:
		if _variant() == "slip" and logs_missed == 0 and logs_pushed == 0:
			return              # =slip: ilk kütüğü kaçırır
		_push_log(lg)
		return
	if _lash_target >= 0:
		# =slip: iki kalasın ilk bağını erken basar
		if _slip_bad_left > 0 and _lash_presses == 0 and (_lash_target == 1 or _lash_target == 3) and meter.phase > 0.2 and meter.phase < 0.4 and not meter._pressed_this:
			_slip_bad_left -= 1
			meter.press()
		return
	var target := -1
	for i in 6:
		if _plank_state[i] == "set" or (_plank_state[i] == "loose" and _plank_i >= 6 and _variant() != "slip"):
			target = i
			break
	if target < 0:
		return
	var tz: float = ThraceRoad.PLANKS[target]
	_beam_z = move_toward(_beam_z, tz, dt * 6.0)
	if absf(_beam_z - tz) < 0.3 and _bridge_bot_t > 0.5:
		_bridge_bot_t = 0.0
		_start_lash(target)


# ---- kütükler

func _tick_logs(dt: float) -> void:
	_log_t -= dt
	if _log_t <= 0.0:
		_log_t = randf_range(8.0, 12.0)
		_spawn_log()
	var show_ring := false
	for lg: Dictionary in _logs.duplicate():
		var n: Node3D = lg["n"]
		n.position.x += float(lg["v"]) * dt
		n.position.z += float(lg["vz"]) * dt
		n.rotation.y += dt * 0.4
		if not lg["warned"] and n.position.x > -24.0:
			lg["warned"] = true
			hud.set_qte(tr("UI_HINT35O_LOG"))
			Audio.sfx("splash", -6.0, 0.7)
			if not _log_said:
				_log_said = true
				hud.bark("SPK_DULGER", "D35O_D_LOG", 2.5)
				get_tree().create_timer(3.0).timeout.connect(func(): hud.bark("SPK_TOLGA", "D35O_T_LOG", 3.5))
		if lg["warned"] and not lg["pushed"] and not lg["hit"] and n.position.x < -1.8:
			show_ring = true
			_ring.position = Vector3(-3.4, ThraceRoad.WATER_Y + 0.06, n.position.z)
		if not lg["pushed"] and not lg["hit"] and n.position.x >= -1.8 and absf(n.position.z) < 6.5:
			_log_hit(lg)
		if n.position.x > 70.0:
			n.queue_free()
			_logs.erase(lg)
	_ring.visible = show_ring
	if not show_ring and hud.has_method("set_qte") and _lash_target < 0:
		hud.set_qte("")


func _spawn_log() -> void:
	var n := Node3D.new()
	add_child(n)
	var big := randf() < 0.6
	if big:
		Props.cyl(n, 0.35, 4.5, Vector3.ZERO, Color("5a4030"), Vector3(0, 0, 90), 8)
		Props.cyl(n, 0.08, 1.2, Vector3(1.0, 0.3, 0.2), Color("4a3424"), Vector3(30, 0, 40), 5)
	else:
		for k in 5:
			Props.cyl(n, 0.07, 2.4, Vector3(randf_range(-0.6, 0.6), 0.1, randf_range(-0.4, 0.4)), Color("5a4a30"), Vector3(randf_range(-20, 20), randf_range(0, 180), 90), 5)
	var z: float = TRESTLES_Z.pick_random() + randf_range(-0.8, 0.8)
	n.position = Vector3(-62.0, ThraceRoad.WATER_Y + 0.05, z)
	_logs.append({"n": n, "v": 4.2, "vz": 0.0, "warned": false, "pushed": false, "hit": false})


const TRESTLES_Z := [-4.8, -1.6, 1.6, 4.8]


func _log_in_ring() -> Dictionary:
	for lg: Dictionary in _logs:
		var n: Node3D = lg["n"]
		if not lg["pushed"] and not lg["hit"] and absf(n.position.x + 3.4) < 1.7 and player.global_position.distance_to(n.position) < 6.0:
			return lg
	return {}


func _push_log(lg: Dictionary) -> void:
	lg["pushed"] = true
	logs_pushed += 1
	lg["vz"] = 2.4 * (1.0 if (lg["n"] as Node3D).position.z > 0.0 else -1.0)
	lg["v"] = 3.0
	Vfx.dust(self, (lg["n"] as Node3D).position + Vector3(0, 0.3, 0), 0.4)
	Audio.sfx("splash", -4.0, 1.2)
	player.shake(0.15)
	_ring.visible = false
	hud.set_qte("")


func _log_hit(lg: Dictionary) -> void:
	lg["hit"] = true
	logs_missed += 1
	lg["v"] = 1.5
	Fx.trauma(0.45)
	Audio.sfx("land_thud", 0.0, 0.6)
	balance.value += 0.6 * (1.0 if randf() < 0.5 else -1.0)
	for t: Node3D in level.trestle_nodes:
		var tw := t.create_tween()
		tw.tween_property(t, "position:x", 0.12, 0.08)
		tw.tween_property(t, "position:x", -0.08, 0.1)
		tw.tween_property(t, "position:x", 0.0, 0.15)
	# Son bağlanan kalasın bir bağı çözülür (sıkı bağ yoksa çözülecek bir şey de yok: dülger yalnız uyarır; eskiden
	# hiç kalas bağlanmamışken de "son bağ gevşedi" diyordu)
	var undone := false
	for i in range(5, -1, -1):
		if _plank_state[i] == "tight":
			_plank_state[i] = "loose"
			level.lash_rings(i, 1, true)
			undone = true
			break
	hud.bark("SPK_DULGER", "D35O_D_HITLOG" if undone else "D35O_D_HITLOG0", 3.0)


# ---- dereye düşüş

var _falling := false


func _fall_in() -> void:
	if _falling:
		return
	_falling = true
	swept += 1
	print("SWEPT %d" % swept) if GameState.autotest else null
	balance.visible = false
	meter.enabled = false
	_lash_target = -1
	hud.set_qte("")
	var start := player.global_position
	var water := Vector3(start.x - 0.6, ThraceRoad.WATER_Y - 0.6, start.z)
	Audio.sfx("splash", 0.0, 0.9)
	Vfx.dust(self, Vector3(start.x, ThraceRoad.WATER_Y, start.z), 0.8)
	player.hurt(15.0, Vector3.INF, true)
	var tw := create_tween()
	tw.tween_property(player, "global_position", water, 0.5)
	tw.tween_property(player, "global_position", water + Vector3(15.0, 0.2, 0), 3.0).set_trans(Tween.TRANS_SINE)
	await tw.finished
	# Kıyıdan ip atılır
	var bank := Vector3(water.x + 15.0, 0.2, -8.8)
	var rope := Bogaz.make_rope(self, Color("c8b080"), 0.03)
	Bogaz.rope(rope, bank + Vector3(0, 1.0, 0), player.global_position + Vector3(0, 0.6, 0))
	hud.set_prompt(tr("UI_PROMPT35O_GRAB"))
	var t := 0.0
	while t < 6.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		player.global_position += Vector3(0.6, 0, 0) * get_process_delta_time()
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
	hud.bark("SPK_TOLGA", "D35O_T_SWEPT", 4.0)
	_beam_z = -9.6
	balance.value = 0.0
	player.global_position = _gy(Vector3(-0.9, 0, -9.6)) + Vector3(0, 0.1, 0)
	_falling = false


# ---- konvoy geçer

func _crossing() -> void:
	phase = "crossing"
	player.global_position = _gy(Vector3(5.0, 0, 13.0)) + Vector3(0, 0.05, 0)
	player.face(Vector3(0, 1.0, -6.0))
	level.update_convoy(-40.0)
	hud.bark("SPK_DROVER", "D35O_DR_01", 4.0)
	var s := -40.0
	var creaked := false
	while s < S_MUD:
		await get_tree().process_frame
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
	var tw := p.create_tween()
	tw.tween_property(p, "rotation:x", 1.2, 0.4)
	tw.parallel().tween_property(p, "position:y", ThraceRoad.WATER_Y, 0.6)
	Audio.sfx("splash", 2.0, 0.8)
	Fx.trauma(0.5)
	level.update_convoy(s, 0.2)
	hud.bark("SPK_DULGER", "D35O_D_BREAK", 4.5)
	for m: Person in level.men:
		m.set_activity("lean")
	await get_tree().create_timer(3.5).timeout
	for m: Person in level.men:
		m.set_activity("")
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
	get_tree().create_timer(5.0).timeout.connect(func(): hud.bark("SPK_TOLGA", "D35O_T_MUD", 3.5))
	meter.enabled = true
	meter.phase = 0.0
	var bot_t := 0.0
	var bad_left := 3 if _variant() == "slip" else 0
	while _row < ROW_GOAL:
		await get_tree().process_frame
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
	await get_tree().create_timer(2.5).timeout
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
	_held.position = Vector3(0.25, -0.45, -0.8)
	Props.cyl(_held, 0.28, 1.2, Vector3.ZERO, Color("7a6a3a"), Vector3(0, 0, 80), 7)
	Props.strip_outlines(_held)
	player.speed_mult = 0.7
	Audio.sfx("land_pot", -10.0, 0.8)


func _place_bundle() -> void:
	if not _carry:
		return
	_carry = false
	_held.queue_free()
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
		"bridge":
			if _lash_target >= 0:
				_lash_stroke(good)
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
	get_tree().create_timer(0.6).timeout.connect(_men_idle)
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
	await get_tree().create_timer(6.0).timeout
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
	await get_tree().create_timer(2.5).timeout


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
	get_tree().create_timer(4.8).timeout.connect(func(): hud.bark("SPK_URBAN", "D35O_U_K1", 4.0))
	get_tree().create_timer(9.2).timeout.connect(func(): hud.bark("SPK_KARACA", "D35O_K_02", 3.5))
	get_tree().create_timer(3.0).timeout.connect(_spook)
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
	await get_tree().create_timer(5.0).timeout
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
	await get_tree().create_timer(1.5).timeout
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
	await get_tree().create_timer(3.0).timeout
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
		balance.value -= Input.get_axis("move_left", "move_right") * 1.7 * dt
	else:
		balance.value = move_toward(balance.value, 0.0, dt)
	if absf(balance.value) < 0.4:
		_hold_t += dt
	hud.set_prompt(tr("UI_PROMPT35O_OX") if _hold_t >= 4.0 else "")
	if _hold_t >= 4.0 and (Input.is_action_just_pressed("interact") or GameState.autotest):
		_hold["state"] = "calm"
		caught += 1
		o.bellow()
		Vfx.steam(self, o.global_position + Vector3(0, 1.4, 0) - back * 1.5)
		hud.bark("SPK_TOLGA", "D35O_T_CALM", 3.0)
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
		await get_tree().create_timer(2.5).timeout
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
		"bridge":
			_bridge_input()
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
			get_tree().reload_current_scene()
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
		tr("UI_FLOW_CONTINUE"),
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
	await get_tree().create_timer(1.2).timeout
	await _shot_png("c35o_cover.png")
	# Köprü: yarım köprü ve kalaslar
	level.make_day()
	for i in 3:
		level.set_plank(i)
		level.lash_rings(i, 2, false)
	level.update_convoy(-30.0)
	cv.global_position = Vector3(-7.0, 1.6, 9.0)
	cv.look_at(Vector3(0.0, 0.0, -2.0), Vector3.UP)
	await get_tree().create_timer(0.6).timeout
	await _shot_png("c35o_01_bridge.png")
	# Çamur
	level.update_convoy(S_MUD)
	level.sink = 0.35
	level.update_convoy(S_MUD)
	cv.global_position = Vector3(6.0, 2.2, S_MUD + 6.0)
	cv.look_at(Vector3(0.0, 0.8, S_MUD - 3.0), Vector3.UP)
	await get_tree().create_timer(0.6).timeout
	await _shot_png("c35o_02_mud.png")
	# Gece konağı
	level.make_night()
	level.light_camp()
	level.update_convoy(S_SLOPE1 + 2.0)
	for o: Ox in level.oxen:
		o.lie(true)
	cv.global_position = Vector3(10.0, ThraceRoad.ground_y(10.0, ThraceRoad.CAMP.z - 12.0) + 3.0, ThraceRoad.CAMP.z - 12.0)
	cv.look_at(Vector3(-6.0, ThraceRoad.ground_y(-6.0, ThraceRoad.CAMP.z + 6.0) + 0.8, ThraceRoad.CAMP.z + 6.0), Vector3.UP)
	await get_tree().create_timer(1.0).timeout
	await _shot_png("c35o_03_night.png")
	get_tree().quit()
