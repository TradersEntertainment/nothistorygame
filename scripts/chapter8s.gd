extends "res://scripts/chapter8y.gd"
## Sürgün (docs/SENARYO_KURAL_CIGNEME.md §6.3). Hükümdarına el kaldıran Tolga karşı tarafa sürülür: BAYRAKSIZ, beyaz bez
## de yok. Ara Bölüm "Beyaz Havlu"nun (chapter8y) kapısı, ölü bölgesi, siperi ve kişileri aynen kullanılır; yön
## sürgüne göre:
##   B2O  İmparator'un muhafızları şehrin içinden kapıya götürür, nöbetçi kapıyı açar, Tolga ovaya salınır; siperde
##        Hasan ile Hüseyin yakalar ("seni karşıdan yolladılar").
##   O2B  Sultan'ın askerleri (Hasan ile Hüseyin) siperin geçidinden ovaya salar; surdaki gözcü durdurur, nöbetçi
##        kapıyı açar, Niko karşılar.
## Ovada kural: eller havada, yavaş. Eller inikken (E ile kaldırılır/indirilir) WARN_GRACE sn, koşarken ya da koridorun
## kenarına sapınca uyarı oku ayağının dibine saplanır, o taraf bağırır. Üst üste HIT_AFTER uyarıdan sonra ok sıyırır:
## Tolga yere (ölüm yok), son siper sırasına (geri dönüş noktası) döner. Siperin (terk edilmiş perde sırası) dibinde
## durmak sayacı sıfırlar ("siper almak").
## Bitince: taraf değişir (flags.siege_side), sürgün kaydı (flags.surgun_log) yazılır, Nihat telsizden köprü sözü,
## akış şeması, karşı tarafın sıradaki sayfası (Huzur.start_walk'ın hesapladığı to_path) açılır.
## Kayıt: bu sahne kendi başlangıç kaydını almaz (yürüyüşün ortasında çıkılırsa hükümdarlı bölümün başına dönülür);
## karşı tarafın sayfası açılınca onun kaydı alınır (taraf ve sürgün kaydı içinde).
##   --chapter=8s --autotest[=b2o|warn|hit|next|save|b2o_next|b2o_save]   (varsayılan: O2B, 28o'dan 29'a)

const Huzur := preload("res://scripts/level/huzur.gd")
const NO_S := 81
## ---- ayar sabitleri (rapor2 §ayarlar)
const HANDS_L := Vector3(-0.3, 0.05, -0.42)
const HANDS_R := Vector3(0.3, 0.05, -0.42)
const WARN_GRACE := 2.5           # eller inikken uyarıya kadar
const HIT_AFTER := 3              # üst üste bu kadar uyarı: ok sıyırır (geri dönüş noktası)
const STREAK_CALM := 6.0          # eller havada bu kadar sn yürürse üst üste sayacı sıfırlanır
const COVER_DIST := 1.6           # perde sırasına bu kadar yakın durmak "siper almak"
const O_START := Vector3(0.0, 0.0, 113.5)
const O_HALT_Z := 40.0
const O_GATE_Z := 17.5
const B_MEET_AT := Vector3(0.0, 0.0, 15.6)

var walk: Dictionary = {}
var dir := "B2O"
var _hands := false
var _streak := 0
var _calm_t := 0.0
var _hits := 0
var _checkpoint := Vector3.ZERO
var _bot_hands_down := false
var _sbot_running := false


func _ready() -> void:
	walk = GameState.flags.get("surgun_walk", {})
	if walk.is_empty():
		# Doğrudan açılış (--chapter=8s, test): Osmanlı tarafından (28o, Şahi'nin ilk atışı) Bizans'a; b2o: Bizans
		# tarafından (30, Blakherna) Osmanlı'ya
		var b2o := _tv().begins_with("b2o")
		GameState.flags["siege_side"] = "B" if b2o else "O"
		walk = {"from_ch": 30 if b2o else 28, "from": "B" if b2o else "O", "to": "O" if b2o else "B",
			"ruler": "emperor" if b2o else "fatih"}
		walk["to_ch"] = Huzur.next_on(int(walk["from_ch"]), String(walk["to"]))
		walk["to_path"] = Siege.scene_path(int(walk["to_ch"]), String(walk["to"]))
		GameState.flags["surgun_walk"] = walk
		GameState.flags["surgun_n"] = int(GameState.flags.get("surgun_n", 0)) + 1
	dir = "B2O" if String(walk.get("from", "B")) == "B" else "O2B"
	_deported = false
	_letter = false
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
	_build_sky()
	World1453.REGIONS[REGION] = Transform3D(Basis.IDENTITY, Vector3(GATE_X, 0.0, 0.0))
	world = World1453.build(self, REGION, KEEP, false)
	_build_ground()
	_build_bounds()
	_build_gate()
	_build_people()
	_build_field()
	_build_lines()
	_adapt_people()
	if GameState.autotest:
		Engine.time_scale = 2.5
	_srun()


## 8y'nin kişileri sürgüne göre: Niko'nun sırığı (havlu) yok; B2O'da Niko yok (Bizans'ta kalır), O2B'de kapının içinde
## bekler (kapı açılınca çıkar). Hasan ile Hüseyin O2B'de ovaya değil oyuncuya (ordugâha) bakar.
func _adapt_people() -> void:
	if is_instance_valid(_niko_pole):
		_niko_pole.queue_free()
		_niko_pole = null
	niko.set_meta("armed", false)
	if dir == "B2O":
		niko.visible = false
		niko.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		niko.global_position = NIKO_GATE + Vector3(-1.0, _gy(NIKO_GATE.x - 1.0, NIKO_GATE.z), -0.6)
		niko.look_target = null
		Stage.face(niko, Vector3(0, 0, 20.0))
		hasan.rotation.y = 0.0
		huseyin.rotation.y = 0.0


func _d2(sec: float) -> float:
	return 0.05 if Stage.fast() else sec


# ================================================================ akış

func _srun() -> void:
	_t_start = Time.get_ticks_msec()
	hud.set_fade(1.0)
	var to_ch := int(walk.get("to_ch", 0))
	await hud.card([[tr("UI_CH8S_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH8S_SUB_" + dir), 20, Color(1, 1, 1, 0.7)],
		[tr("SIEGE_DATE_%d" % int(walk.get("from_ch", 0))) if int(walk.get("from_ch", 0)) in Siege.ORDER else "", 18,
		Color(1, 1, 1, 0.55)]], 2.6)
	hud.clear_card()
	if dir == "B2O":
		player.global_position = START + Vector3(0, 0.05, 0)
		player.face(guard.global_position + Vector3(0, 1.5, 0))
	else:
		player.global_position = O_START + Vector3(0, _gy(O_START.x, O_START.z) + 0.05, 0)
		hasan.look_target = player
		huseyin.look_target = player
		player.face((hasan.global_position + huseyin.global_position) * 0.5 + Vector3(0, 1.5, 0))
	_checkpoint = player.global_position
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	_log_s("start dir=%s from=%d to=%d path=%s" % [dir, int(walk.get("from_ch", 0)), to_ch, String(walk.get("to_path", ""))])
	if dir == "B2O":
		guard.look_target = player
		await _say("SPK_CITY_GUARD", "HZR_GATE_B")
		await _t("HZR_T_GATE_TOWEL" if GameState.flags.get("ch8y_done", false) else "HZR_T_GATE")
		phase = "peri"
		hud.set_objective(tr("UI_OBJ8S_GATE"), Vector3(0, 1.6, 12.6))
	else:
		await _say("SPK_HUSEYIN", "HZR_HUSEYIN_OUT")
		await _say("SPK_HASAN", "HZR_HASAN_OUT")
		await _t("HZR_T_GATE_TOWEL" if GameState.flags.get("ch8y_done", false) else "HZR_T_GATE")
		hasan.look_target = null
		huseyin.look_target = null
		_set_hands(true)
		phase = "field"
		_warn_cd = 2.0
		_start_field_s()
		hud.set_objective(tr("UI_OBJ8S_WALLS"), Vector3(0, 2.0, O_GATE_Z))
	player.frozen = false
	if GameState.autotest:
		_sauto()
	while _outcome == "":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	await _end_walk()


func _log_s(s: String) -> void:
	if GameState.autotest:
		print("SURGUN " + s)


func _process(delta: float) -> void:
	if hud == null or player == null:
		return
	var pz := player.global_position.z
	match phase:
		"peri":
			if not _busy and pz > GATE_TRIGGER_Z:
				_gate_b2o()
		"out":
			if not _busy and pz > BRIDGE_Z and not _fired.has("bridge"):
				_bridge_b2o()
			elif not _busy and pz > FIELD_Z and _fired.has("bridge"):
				phase = "field"
				_warn_cd = 2.0
				_start_field_s()
		"field":
			_hands_tick(delta)
			_checkpoints(pz)
			if dir == "B2O":
				_events(pz, delta)
				if not _busy and pz > HALT_Z and not _fired.has("halt"):
					_halt_b2o()
				if not _busy and pz > TRENCH_Z:
					_trench_b2o()
			else:
				if not _busy and pz < O_HALT_Z and not _fired.has("halt"):
					_halt_o2b()
				if not _busy and pz < O_GATE_Z and _fired.has("halt"):
					_gate_o2b()
		"lines":
			if not _busy and pz > END_Z - 6.0:
				_outcome = "8S.1" if _hits == 0 else "8S.2"


func _start_field_s() -> void:
	_fired["radio"] = true
	if not _hands:
		_set_hands(true)
	hud.set_prompt(GameState.tr_pad("UI_PROMPT8S_HANDS"))


# ---------------------------------------------------------------- eller havada

## Eller: iki el kadrajın üst kenarında açık (Player.hold_both, kamera yereli); inince el cebe değil yana iner
func _set_hands(up: bool) -> void:
	if up == _hands:
		return
	_hands = up
	if up:
		player.hold_both(HANDS_L, HANDS_R)
		player.speed_mult = 0.7
	else:
		player.release_both()
		player.speed_mult = 1.0
	Audio.sfx("cloth", -14.0, 1.1 if up else 0.9)


func _hands_tick(delta: float) -> void:
	if _busy:
		return
	var v := player.velocity
	var running := _sbot_running or (not player.frozen and Input.is_action_pressed("sprint") and Vector2(v.x, v.z).length() > Player.WALK + 0.4)
	_run_t = _run_t + delta if running else 0.0
	if not player.frozen and Input.is_action_just_pressed("interact"):
		_set_hands(not _hands)
	if _bot_hands_down and _hands:
		_set_hands(false)
	_down_t = _down_t + delta if (not _hands and not running) else 0.0
	# Siper: terk edilmiş perde sırasının dibinde durmak (yürümeden) ateşi keser, sayaç sıfırlanır
	var covered := _in_cover() and Vector2(v.x, v.z).length() < 0.4
	if _hands and not running:
		_calm_t += delta
		if _calm_t > STREAK_CALM:
			_streak = 0
	else:
		_calm_t = 0.0
	if covered:
		_streak = 0
		_down_t = 0.0
	_warn_cd = maxf(0.0, _warn_cd - delta)
	if _warn_cd <= 0.0 and not covered:
		if running and _run_t > 0.35:
			_warn_s("run")
		elif _down_t > WARN_GRACE:
			_warn_s("down")
		elif absf(player.global_position.x) > LANE_HALF:
			_warn_s("side")
	var pr := GameState.tr_pad("UI_PROMPT8S_HANDS") if not _hands else ""
	if pr != _prompt:
		_prompt = pr
		hud.set_prompt(pr)


func _in_cover() -> bool:
	var p := player.global_position
	for b: Array in BARRIERS:
		if p.x >= float(b[1]) - 0.5 and p.x <= float(b[2]) + 0.5 and absf(p.z - float(b[0])) < COVER_DIST:
			return true
	return false


## Geri dönüş noktası: geçilen her perde sırası (yürüme yönünde)
func _checkpoints(pz: float) -> void:
	for b: Array in BARRIERS:
		var z := float(b[0])
		if dir == "B2O" and pz > z + 2.0 and _checkpoint.z < z + 2.0:
			_checkpoint = Vector3(0.0, _gy(0.0, z + 2.5), z + 2.5)
		elif dir == "O2B" and pz < z - 2.0 and _checkpoint.z > z - 2.0:
			_checkpoint = Vector3(0.0, _gy(0.0, z - 2.5), z - 2.5)


## Uyarı oku (8y'nin oku): bakışın önüne saplanır; hangi taraf atar: yakın olan (surdan ya da siperden)
func _warn_s(reason: String) -> void:
	_warn_cd = WARN_GAP
	_warnings += 1
	_streak += 1
	if reason == "down":
		_lowered += 1
	_log_s("warn reason=%s n=%d streak=%d z=%.1f" % [reason, _warnings, _streak, player.global_position.z])
	var pp := player.global_position
	var fwd := -player.camera.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized() if fwd.length() > 0.01 else Vector3.BACK
	var from_wall := pp.z < 70.0
	if _streak >= HIT_AFTER:
		await _graze(from_wall)
		return
	var land := pp + fwd * 6.0 + fwd.cross(Vector3.UP) * -1.4
	land.y = _gy(land.x, land.z)
	var back := 1.0 if from_wall else -1.0
	_shoot_arrow(land + Vector3((1.2 if _warnings % 2 == 0 else -1.2), 10.0, -12.0 * back), land)
	var line: Array
	if reason == "run":
		line = ["SPK_LOOKOUT", "D8Y_WALL_WARN_2"] if from_wall else ["SPK_HUSEYIN", "D8Y_HUSEYIN_WARN_2"]
	else:
		line = ["SPK_LOOKOUT", "HZR_WALL_WARN_HANDS"] if from_wall else ["SPK_HASAN", "HZR_TRENCH_WARN_HANDS"]
	var answers := [["SPK_TOLGA", "HZR_T_WARN_HANDS"], ["SPK_TOLGA", "D8Y_T_WARN_2"], ["SPK_TOLGA", "D8Y_T_WARN_3"]]
	_warn_lines(line, answers[(_warnings - 1) % answers.size()])


## Ok sıyırır: Tolga yere (Player.down: Nihat'ın sözü), kararır, son siper sırasında eller havada kalkar
func _graze(from_wall: bool) -> void:
	_busy = true
	_hits += 1
	_streak = 0
	_log_s("graze n=%d checkpoint=%s" % [_hits, str(_checkpoint)])
	var pp := player.global_position
	var src := pp + Vector3(1.0, 9.0, -12.0 if from_wall else 12.0)
	_shoot_arrow(src, pp + Vector3(0.5, 0.0, 0.3))
	await get_tree().create_timer(_d2(0.4), false).timeout
	player.frozen = true
	player.shake(1.0)
	hud.bark("SPK_LOOKOUT" if from_wall else "SPK_HASAN", "HZR_WALL_HIT" if from_wall else "HZR_TRENCH_HIT", 3.0, true)
	await player.down()
	await hud.fade_to(1.0, 0.5)
	player.global_position = _checkpoint + Vector3(0, 0.05, 0)
	player.face(player.global_position + Vector3(0, 1.6, 12.0 if dir == "B2O" else -12.0))
	_set_hands(true)
	_down_t = 0.0
	_warn_cd = WARN_GAP
	await hud.fade_to(0.0, 0.6)
	await _t("HZR_T_HIT")
	player.frozen = false
	_busy = false


# ---------------------------------------------------------------- B2O: şehirden ordugâha

func _gate_b2o() -> void:
	_busy = true
	phase = "gate"
	player.frozen = true
	hud.set_objective("")
	guard.look_target = player
	player.face(guard.global_position + Vector3(0, 1.5, 0))
	await _say("SPK_CITY_GUARD", "HZR_GATE_B2")
	await _open_gate()
	player.face(Vector3(0, 1.6, 30.0))
	for a: Soldier in _archers:
		a.look_target = player
	phase = "out"
	hud.set_objective(tr("UI_OBJ8S_FIELD"), Vector3(0, 1.6, 104.0))
	_set_hands(true)
	player.frozen = false
	_busy = false


func _bridge_b2o() -> void:
	_fired["bridge"] = true
	_busy = true
	player.frozen = true
	lookout.look_target = player
	player.face(Vector3(0.4, 9.3, 15.0))
	await _say("SPK_LOOKOUT", "HZR_WALL_OUT")
	_lower_bows()
	player.face(player.global_position + Vector3(0, 1.5, 12.0))
	player.frozen = false
	_busy = false


func _halt_b2o() -> void:
	_fired["halt"] = true
	_busy = true
	while hud.is_talking() or hud.chain_busy():
		await get_tree().process_frame
	player.frozen = true
	_set_hands(true)
	player.face(player.global_position + Vector3(0, 1.6, 12.0))
	await _say("SPK_HASAN", "HZR_HASAN_HALT")
	await get_tree().create_timer(_d2(1.2), false).timeout
	await _say("SPK_HUSEYIN", "D8Y_HUSEYIN_COME")
	player.frozen = false
	_busy = false


func _trench_b2o() -> void:
	_busy = true
	phase = "trench"
	_queue.clear()
	hud.set_prompt("")
	_prompt = ""
	while hud.chain_busy() or hud.is_talking():
		await get_tree().process_frame
	player.frozen = true
	hud.set_objective("")
	var mid := (HASAN_AT + HUSEYIN_AT) * 0.5
	hasan.look_target = player
	huseyin.look_target = player
	await Stage.walk_player(player, mid, 2.8, mid + Vector3(0, 1.5, 0))
	player.frozen = true
	var met := GameState.has_met("guards")
	await _say("SPK_HASAN", "HZR_HASAN_MEET_MET" if met else "HZR_HASAN_MEET_NEW")
	await _say("SPK_HUSEYIN", "HZR_HUSEYIN_MEET")
	await _t("HZR_T_MEET_O")
	await _say("SPK_HASAN", "HZR_HASAN_TAKE")
	GameState.meet("guards")
	_set_hands(false)
	_hasan_lead()
	huseyin.look_target = null
	phase = "lines"
	hud.set_objective(tr("UI_OBJ8Y_LINES"), hasan, 2.0)
	player.frozen = false
	_busy = false


# ---------------------------------------------------------------- O2B: ordugâhtan surlara

func _halt_o2b() -> void:
	_fired["halt"] = true
	_busy = true
	while hud.is_talking() or hud.chain_busy():
		await get_tree().process_frame
	player.frozen = true
	_set_hands(true)
	lookout.look_target = player
	player.face(Vector3(0.4, 9.3, 15.0))
	await _say("SPK_LOOKOUT", "HZR_WALL_HALT")
	await _t("HZR_T_HALT")
	await _say("SPK_LOOKOUT", "HZR_WALL_COME")
	_lower_bows()
	player.face(Vector3(0, 1.6, 0.0))
	hud.set_objective(tr("UI_OBJ8S_GATE"), Vector3(0, 1.6, GATE_Z + 1.0))
	player.frozen = false
	_busy = false


func _gate_o2b() -> void:
	_busy = true
	phase = "gate"
	player.frozen = true
	hud.set_objective("")
	hud.set_prompt("")
	_prompt = ""
	player.face(Vector3(0, 1.8, GATE_Z))
	await _open_gate()
	# Niko kapıdan çıkar, Tolga'nın önüne gelir
	await Stage.walk_on_ground(niko, B_MEET_AT + Vector3(0.6, 0, 0), Callable(self, "_gy"), 1.6, player.global_position)
	niko.look_target = player
	player.face(niko.global_position + Vector3(0, 1.5, 0))
	var met := GameState.has_met("niko")
	await _say("SPK_NIKO", "HZR_NIKO_MEET_MET" if met else "HZR_NIKO_MEET_NEW")
	await _t("HZR_T_MEET_B")
	await _say("SPK_NIKO", "HZR_NIKO_TAKE")
	GameState.meet("niko")
	_set_hands(false)
	_outcome = "8S.1" if _hits == 0 else "8S.2"
	_busy = false


# ================================================================ bitiş

func _end_walk() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	hud.set_prompt("")
	_set_hands(false)
	var f := GameState.flags
	var from_ch := int(walk.get("from_ch", 0))
	var to_side := String(walk.get("to", "B"))
	# Taraf değişir; kaza rotası (sapma) sürüyorduysa kapanır: sürgün kalıcıdır
	f["siege_side"] = to_side
	f.erase("siege_detour")
	if f.has("siege_detour_back"):
		f.erase("siege_detour_back")
	var hist: Array = f.get("surgun_log", [])
	hist.append({"ch": from_ch, "from": String(walk.get("from", "")), "to": to_side, "next": int(walk.get("to_ch", 0)),
		"ruler": String(walk.get("ruler", "")), "hits": _hits, "warnings": _warnings})
	f["surgun_log"] = hist
	# 29 Mayıs şafağında (26) Bizans tarafından sürülen tanık şafağı tutamaz: şehir o sabah düşer
	if from_ch == 26 and String(walk.get("from", "")) == "B" and not f.has("siege_held"):
		Siege.resolve(false)
	f.erase("surgun_walk")
	f["surgun_last"] = hist.back()
	await hud.fade_to(1.0, 0.8)
	player.radio_listen(3.0)
	await hud.say("SPK_NIHAT", "HZR_N_RADIO_BRIDGE")
	var result := await hud.show_flowchart(_make_chart_s(), true)
	Engine.time_scale = 1.0
	var to_path := String(walk.get("to_path", ""))
	if to_path == "" or not ResourceLoader.exists(to_path):
		to_path = Siege.return_path()
	if GameState.autotest:
		var v := _tv()
		if v.ends_with("save"):
			_save_check(to_path)
			return
		if v.ends_with("next"):
			print("AUTOTEST chapter=8s -> %s outcome=%s" % [to_path.get_file(), _outcome])
			GameState.autotest_variant = ""
			GameState.flags.erase("huzur_test")
			GameState.current_chapter = int(walk.get("to_ch", 0))
			get_tree().change_scene_to_file(to_path)
			return
		_report_s(to_path)
		return
	match result:
		"replay":
			GameState.change_scene(to_path)      # yürüyüş yeniden oynanmaz (kaydı yok): karşı tarafın sayfası
		"next":
			GameState.change_scene(to_path)
		_:
			get_tree().quit()


func _make_chart_s() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW8S_TITLE")
	var from_ch := int(walk.get("from_ch", 0))
	var to_ch := int(walk.get("to_ch", 0))
	c.nodes = [
		{"id": "from", "key": "FLOW8S_FROM_" + String(walk.get("from", "B")), "pos": Vector2(0.5, 0.16)},
		{"id": "counter", "key": "FLOW8S_COUNTER_" + String(walk.get("ruler", "fatih")).to_upper(), "pos": Vector2(0.5, 0.32)},
		{"id": "field", "key": "FLOW8S_FIELD", "pos": Vector2(0.5, 0.48)},
		{"id": "8S.1", "key": "FLOW_8S_1", "pos": Vector2(0.3, 0.68), "outcome": true},
		{"id": "8S.2", "key": "FLOW_8S_2", "pos": Vector2(0.7, 0.68), "outcome": true},
	]
	c.edges = [["from", "counter"], ["counter", "field"], ["field", "8S.1"], ["field", "8S.2"]]
	for k in ["from", "counter", "field", _outcome]:
		c.taken[k] = true
	var to_txt := tr("UI_FLOW8S_TO") % [GameState.display_no(to_ch) if to_ch > 0 else "", tr("SIEGE_DATE_%d" % to_ch) if to_ch > 0 else ""]
	c.footer_lines = [
		tr("UI_FLOW8S_ROUTE") % [GameState.display_no(from_ch), tr("UI_SIDE_" + String(walk.get("from", "B"))),
			tr("UI_SIDE_" + String(walk.get("to", "O")))],
		tr("UI_CH8S_STATS") % [_warnings, _hits],
		to_txt,
		GameState.tr_pad("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ otomatik test

func _sauto() -> void:
	var v := _tv().trim_prefix("b2o").trim_prefix("_").trim_prefix("huzur").trim_prefix("_")
	if dir == "B2O":
		await _bot_to(Vector3(0.0, 0.0, 9.0))
		await _wait_until(func() -> bool: return phase in ["out", "field"] and not _busy)
		await _bot_to(Vector3(0.0, 0.0, 42.0))
		await _wait_until(func() -> bool: return phase == "field" and not _busy)
		await _bot_field(v, PATH)
		await _bot_to(Vector3(0.0, 0.0, 105.0))
		await _wait_until(func() -> bool: return phase in ["lines", "done"] and not _busy)
		await _bot_to(Vector3(0.6, 0.0, 139.0))
	else:
		var back: Array = []
		for k in range(PATH.size() - 1, -1, -1):
			back.append(PATH[k])
		back.append(Vector3(0.0, 0, 38.0))
		await _bot_field(v, back)
		await _wait_until(func() -> bool: return _fired.has("halt") and not _busy)
		await _bot_to(Vector3(0.0, 0.0, 16.5))


## Ovada bot: varsayılan eller havada; warn: bir kez eller iner (uyarı), sonra kalkar; hit: eller inik kalır, ok sıyırır
func _bot_field(v: String, path: Array) -> void:
	for i in path.size():
		await _bot_to(path[i])
		if i == 0 and v == "warn":
			_bot_hands_down = true
			await _wait_until(func() -> bool: return _warnings >= 1, 20.0)
			_bot_hands_down = false
			_set_hands(true)
		if i == 0 and v == "hit":
			_bot_hands_down = true
			await _wait_until(func() -> bool: return _hits >= 1, 40.0)
			_bot_hands_down = false
			await _wait_until(func() -> bool: return not _busy, 20.0)


## Test varyantı: doğrudan açılışta --autotest=..., hükümdarlı bölümden gelindiyse Huzur'un sakladığı (huzur_...)
func _tv() -> String:
	return String(GameState.flags.get("huzur_test", GameState.autotest_variant))


func _report_s(to_path: String) -> void:
	var v := _tv().trim_prefix("b2o").trim_prefix("_").trim_prefix("huzur").trim_prefix("_")
	var f := GameState.flags
	var hist: Array = f.get("surgun_log", [])
	var ok := _outcome != "" and String(f.get("siege_side", "")) == String(walk.get("to", "")) and not hist.is_empty()
	ok = ok and ResourceLoader.exists(to_path) and not f.has("surgun_walk")
	match v:
		"warn":
			ok = ok and _warnings >= 1 and _hits == 0
		"hit":
			ok = ok and _hits >= 1
		_:
			ok = ok and _warnings == 0 and _hits == 0
	# Karşı tarafın sayfası: bu sayfadan SONRAKİ ilk sayfa (aynı tarih çizgisi)
	var from_i := Siege.ORDER.find(int(walk.get("from_ch", 0)))
	var to_i := Siege.ORDER.find(int(walk.get("to_ch", 0)))
	ok = ok and to_i > from_i
	print("SURE8S %.0f s" % ((Time.get_ticks_msec() - _t_start) / 1000.0))
	print("AUTOTEST %s chapter=8s variant=%s dir=%s from=%d to=%d path=%s outcome=%s warnings=%d hits=%d side=%s route=%s" % [
		"PASS" if ok else "FAIL", _tv(), dir, int(walk.get("from_ch", 0)), int(walk.get("to_ch", 0)),
		to_path.get_file(), _outcome, _warnings, _hits, String(f.get("siege_side", "")), str(Siege.chapters())])
	get_tree().quit(0 if ok else 1)


## Kaydet-yükle: karşı tarafın sayfası kendi başlangıç kaydını alır (bölüm _ready'sinin yaptığı gibi), oyun kaydı
## okunur ve yeniden kurulur: açılacak sahne, taraf, sürgün kaydı, bölüm numarası ve bölüm listesi doğru mu
func _save_check(to_path: String) -> void:
	var to_ch := int(walk.get("to_ch", 0))
	GameState.snapshot(to_ch)
	GameState._snapshots[to_ch]["scene"] = to_path
	var data := GameState.run_data()
	var want_side := String(walk.get("to", ""))
	var path := GameState.prepare_load(data)
	var f := GameState.flags
	var hist: Array = f.get("surgun_log", [])
	var reached := GameState.reached_chapters(data)
	var no := Siege.number(path)
	var ok := path == to_path and String(f.get("siege_side", "")) == want_side and not hist.is_empty() and no > 0
	ok = ok and to_ch in reached and GameState.display_no(to_ch) == str(no)
	print("AUTOTEST %s chapter=8s variant=%s save path=%s side=%s log=%d number=%d reached=%s route=%s" % [
		"PASS" if ok else "FAIL", _tv(), path.get_file(), String(f.get("siege_side", "")), hist.size(), no,
		str(reached), str(Siege.chapters())])
	get_tree().quit(0 if ok else 1)
