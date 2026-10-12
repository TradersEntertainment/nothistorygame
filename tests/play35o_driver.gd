extends Node
## İnsan gibi oynayan sürücü, Bölüm 35o köprüsü (tests/play35o_check.gd kurar). Otomatik testin botu dengeyi atlar ve
## kirişte doğrudan ışınlanır; bu sürücü oyuncunun gördüğünü okur, tuşlara basar:
##   * ibre sağa kaçınca A, sola kaçınca D (ibreyi ortaya çeker; 0,2 sn tepki süresi);
##   * W/S ile sıradaki direğe yürür, E ile bağlamaya başlar, ibre yeşil pencerenin ortasındayken E;
##   * halkaya giren kütüğü E ile iter.
## Arkadaş notu (v0.99.11): "nehirde köprü yapma bölümü bozuk". A/D ters çalışıyordu: bu sürücü 130 sn'de 10 kez dereye
## düşüp hiç ilerleyemiyordu. Sonuç: PLAYCHECK PASS/FAIL.

const MAX_SWEPT := 1
var t := 0.0
var react := 0.0
var adv_t := 0.0
var e_cool := 0.0
var ok := true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


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
	for a in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(a)
	print("PLAYCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)


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
	if t > 360.0:
		_fail("süre doldu: köprü bitmedi (faz %s, düşüş %d, kalaslar %s)" % [ch.phase, ch.swept, ch._plank_state])
		_finish()
		return
	if ch.phase != "bridge":
		if ch.phase in ["crossing", "mud"]:
			print("PLAYCHECK 35o köprü %.0f sn, düşüş %d, gevşek %d, kalaslar %s" % [t, ch.swept, ch.loose, ch._plank_state])
			if ch.swept > MAX_SWEPT:
				_fail("A/D ile dengede kalan oyuncu %d kez dereye düştü" % ch.swept)
			if ch.loose > 1:
				_fail("%d kalas gevşek kaldı: köprü konvoy geçerken kırılır" % ch.loose)
			_finish()
		return
	if not has_meta("faced"):
		set_meta("faced", true)
		var fz: float = -ch.player.camera.global_transform.basis.z.z
		if fz < 0.5:
			_fail("kirişin başında yüz köprüye dönük değil (bakış z %.2f): W kirişte ilerletmez" % fz)
	e_cool -= dt
	react -= dt
	if react <= 0.0:
		react = 0.2
		var bal: float = ch.balance.value
		var want := ""
		if ch.balance.visible and absf(bal) > 0.12:
			want = "move_left" if bal > 0.0 else "move_right"
		for a in ["move_left", "move_right"]:
			_hold(a, a == want)
	var target := -1
	for i in 6:
		if ch._plank_state[i] == "set":
			target = i
			break
	if ch._log_in_ring() != {}:
		if e_cool <= 0.0:
			e_cool = 0.4
			_tap("interact")
	elif ch._lash_target >= 0:
		_hold("move_forward", false)
		_hold("move_back", false)
		var ph: float = ch.meter.phase
		if ph > RowMeter.WIN_A + 0.03 and ph < RowMeter.WIN_B - 0.03 and not ch.meter._pressed_this and e_cool <= 0.0:
			e_cool = 0.3
			_tap("interact")
	elif target >= 0:
		var tz: float = ThraceRoad.PLANKS[target]
		var bz: float = ch._beam_z
		_hold("move_forward", bz < tz - 0.4)
		_hold("move_back", bz > tz + 0.4)
		if absf(bz - tz) < 0.8 and e_cool <= 0.0 and ch._post_near() >= 0:
			e_cool = 0.5
			_tap("interact")
	else:
		_hold("move_forward", false)
		_hold("move_back", false)
