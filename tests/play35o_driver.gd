extends Node
## İnsan gibi oynayan sürücü, Bölüm 35o köprüsü (tests/play35o_check.gd kurar). Otomatik testin botu oyuncuyu
## ışınlar; bu sürücü oyuncunun gördüğünü okur ve yürür:
##   * hedefe döner (yaw), W basılı yürür; köprüye ortadaki iskele tahtasının başından girer, tahtanın ortasından gider;
##   * yığının yanında E ile kalas alır, ilk boş yuvanın önünde E ile koyar, direğin yanında E basılı bağlar.
## Arkadaş notları: v0.99.11 "nehirde köprü yapma bölümü bozuk" (A/D ters), v0.99.12 "dere bölümü aynı hala bozuk":
## bölüm baştan yazıldı (yürüyerek kalas taşı, koy, bağla). Sonuç: PLAYCHECK PASS/FAIL.
## PLAYSHOTS=dizin verilirse (xvfb) 1,5 sn'de bir ekran görüntüsü kaydeder.

const MAX_SWEPT := 0
var t := 0.0
var adv_t := 0.0
var e_cool := 0.0
var ok := true
var shots := OS.get_environment("PLAYSHOTS")
var shot_t := 0.0
var shot_n := 0
var stuck_t := 0.0
var stuck_at := Vector3.INF
var moved := 0.0
var holding_e := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)


func _fail(msg: String) -> void:
	printerr("PLAYCHECK 35o " + msg)
	ok = false


func _tap(action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event.call_deferred(up)


func _hold(action: String, on: bool) -> void:
	if on:
		Input.action_press(action)
	else:
		Input.action_release(action)


func _finish() -> void:
	for a in ["move_left", "move_right", "move_forward", "move_back", "interact"]:
		Input.action_release(a)
	print("PLAYCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)


func _shot() -> void:
	shot_n += 1
	get_viewport().get_texture().get_image().save_png(shots.path_join("p%03d.png" % shot_n))


func _process(dt: float) -> void:
	t += dt
	var ch := get_tree().current_scene
	if ch == null or not "phase" in ch:
		return
	var hud: Hud = ch.hud
	adv_t += dt
	if hud.line_open and adv_t > 1.2:
		adv_t = 0.0
		_tap("advance")
	if shots != "" and ch.phase in ["bridge", "crossing"]:
		shot_t += dt
		if shot_t > 1.5:
			shot_t = 0.0
			_shot()
	if t > 400.0:
		_fail("süre doldu: köprü bitmedi (faz %s, düşüş %d, kalaslar %s)" % [ch.phase, ch.swept, ch._plank_state])
		_finish()
		return
	if ch.phase != "bridge":
		if ch.phase in ["crossing", "mud"]:
			print("PLAYCHECK 35o köprü %.0f sn, düşüş %d, gevşek %d, kalaslar %s" % [t, ch.swept, ch.loose, ch._plank_state])
			if ch.swept > MAX_SWEPT:
				_fail("iskele tahtasının ortasından yürüyen oyuncu %d kez dereye düştü" % ch.swept)
			if ch.loose > 0:
				_fail("%d kalas bağlanamadı: süre yetmedi ya da bağ tutmadı" % ch.loose)
			_finish()
		return
	var pl: Player = ch.player
	if pl.frozen:
		_hold("move_forward", false)
		return
	if not has_meta("faced"):
		set_meta("faced", true)
		var fwd: Vector3 = -pl.camera.global_transform.basis.z
		if fwd.z < 0.3:
			_fail("başta yüz köprüye dönük değil (bakış %s)" % fwd)
	e_cool -= dt
	# Ne yapılacak, nerede durulacak
	var st: Array = ch._plank_state
	var stand := Vector3.INF
	var act := ""
	var idx := -1
	if ch._carry_plank != null:
		idx = ch._first_empty()
		stand = Vector3(0, 0, float(ThraceRoad.PLANKS[idx]) - 1.3)
		act = "place"
	else:
		for i in 6:
			if st[i] == "set":
				idx = i
				break
		if idx >= 0:
			stand = Vector3(0, 0, float(ThraceRoad.PLANKS[idx]))
			act = "lash"
		else:
			stand = ThraceRoad.PILE + Vector3(2.1, 0, 0)
			act = "take"
	# Köprüye ortadaki tahtanın başından girilir/çıkılır
	var pp := pl.global_position
	var on_span := absf(pp.z) < ThraceRoad.BEAM_Z + 0.8
	var goal_span := absf(stand.z) < ThraceRoad.BEAM_Z + 0.8
	var way := stand
	var head := Vector3(0, 0, -ThraceRoad.BEAM_Z - 1.6)
	if on_span and not goal_span:
		way = head                 # köprüden önce tahtanın başına çıkılır (yanlardan inilmez)
	elif goal_span and not on_span and absf(pp.x) > 0.3:
		way = head                 # tahtanın başına, sonra tahta boyunca dümdüz
	var d := Vector2(way.x - pp.x, way.z - pp.z)
	var arrived := way == stand and d.length() < 0.35
	# Bağlarken E basılı tutulur
	var lash_ok: bool = act == "lash" and ch._lash_near() == idx
	if lash_ok and (arrived or d.length() < 0.8):
		_hold("move_forward", false)
		if not holding_e:
			holding_e = true
			_hold("interact", true)
		return
	if holding_e:
		holding_e = false
		_hold("interact", false)
	if arrived:
		_hold("move_forward", false)
		if e_cool <= 0.0:
			if act == "take" and ch._near_pile():
				e_cool = 0.5
				_tap("interact")
			elif act == "place" and ch._slot_near() == idx:
				e_cool = 0.5
				_tap("interact")
		stuck_t = 0.0
		moved = 0.0
		stuck_at = Vector3.INF
		return
	pl.face(Vector3(way.x, pp.y + 1.5, way.z))
	_hold("move_forward", true)
	if OS.get_environment("PDBG") == "1" and int(t * 2.0) != int((t - dt) * 2.0):
		var col := pl.get_last_slide_collision()
		var cn := ""
		if col:
			for k in col.get_collision_count():
				var o := col.get_collider(k) as Node
				cn += " [%s %s n=%s]" % [o.get_path() if o else "?", col.get_position(k), col.get_normal(k)]
		print("PDBG t=%.1f pp=%s way=%s act=%s vel=%s floor=%s%s" % [t, pp, way, act, pl.velocity, pl.is_on_floor(), cn])
	# Takılma: W basılıyken 4 sn'de 0,5 m'den az yol alan (aynı noktadan iki kez geçmek takılma sayılmaz)
	if stuck_at != Vector3.INF:
		moved += Vector2(pp.x - stuck_at.x, pp.z - stuck_at.z).length()
	stuck_at = pp
	stuck_t += dt
	if stuck_t > 4.0:
		if moved < 0.5:
			_fail("takıldı: %s → %s (%s)" % [pp, way, act])
			_finish()
			return
		stuck_t = 0.0
		moved = 0.0
