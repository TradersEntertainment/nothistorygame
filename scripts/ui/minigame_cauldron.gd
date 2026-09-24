class_name MiniGameCauldron
extends MiniGame
## Kadri'nin kazanı: dört malzeme şeridi; yukarıdan düşen malzemeyi çizgiye geldiğinde doğru tuşla (1-4) at.
## Tam zamanında %100, yakın %60, kaçırma %0. Puan = başarı yüzdesi. Önce zorluk seçilir (1/2/3).

const LANES := ["MG_CAUL_L0", "MG_CAUL_L1", "MG_CAUL_L2", "MG_CAUL_L3"]
const COLORS := [Color("e0b85a"), Color("c8a0d8"), Color("c8503a"), Color("6aa84a")]
const PERFECT := 0.09
const GOOD := 0.18

var _state := "pick"     # pick, count, play, result
var _notes: Array = []   # [{lane, t, hit}]
var _now := -3.0
var _speed := 320.0
var _points := 0.0
var _judged := 0
var _flash: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _last := ""
var _info: Label
var _result_t := 0.0


func setup() -> void:
	heading(tr("MG_CAUL_TITLE"))
	footer(tr("MG_CAUL_HELP"))
	_info = text_label(tr("MG_CAUL_PICK"), 22, C_CREAM)
	_info.position = Vector2(0, area.size.y * 0.35)
	_info.size = Vector2(area.size.x, 60)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	area.draw.connect(_draw_area)


func _start(level: int) -> void:
	_speed = [260.0, 330.0, 420.0][level]
	var count: int = [26, 34, 44][level]
	var gap: float = [0.8, 0.62, 0.48][level]
	var t := 0.0
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in count:
		t += gap * rng.randf_range(0.8, 1.25)
		_notes.append({"lane": rng.randi() % 4, "t": t, "hit": false})
	_now = -3.0
	_state = "count"


func _process(delta: float) -> void:
	if _state == "pick":
		for i in 3:
			if Input.is_action_just_pressed("choice_%d" % (i + 1)):
				_start(i)
		return
	if _state == "result":
		_result_t += delta
		if _result_t > 2.2 or Input.is_action_just_pressed("advance"):
			var score := int(round(_points))
			finish(score, score >= 80)
		return
	_now += delta
	for i in 4:
		_flash[i] = maxf(0.0, _flash[i] - delta * 3.0)
	if _state == "count":
		_info.text = tr("MG_CAUL_READY") % int(ceil(-_now))
		if _now >= 0.0:
			_state = "play"
			_info.text = ""
	else:
		for i in 4:
			if Input.is_action_just_pressed("choice_%d" % (i + 1)):
				_press(i)
		for n in _notes:
			if not n["hit"] and _now - float(n["t"]) > GOOD:
				n["hit"] = true
				_judged += 1
				_last = tr("MG_CAUL_MISS")
		if _judged >= _notes.size():
			_points = 0.0
			for n in _notes:
				_points += float(n.get("score", 0.0))
			_points /= float(_notes.size())
			_state = "result"
			_info.text = tr("MG_CAUL_SCORE") % int(round(_points))
	area.queue_redraw()


func _press(lane: int) -> void:
	_flash[lane] = 1.0
	var best: Dictionary = {}
	var bd := 99.0
	for n in _notes:
		if n["hit"] or int(n["lane"]) != lane:
			continue
		var d := absf(float(n["t"]) - _now)
		if d < bd:
			bd = d
			best = n
	if best.is_empty() or bd > GOOD:
		_last = tr("MG_CAUL_WRONG")
		return
	best["hit"] = true
	best["score"] = 100.0 if bd <= PERFECT else 60.0
	_judged += 1
	_last = tr("MG_CAUL_PERFECT") if bd <= PERFECT else tr("MG_CAUL_GOOD")
	Audio.sfx("ui_select", -10.0, 1.0 + lane * 0.12)


func _draw_area() -> void:
	var w := area.size.x / 4.0
	var hit_y := area.size.y - 60.0
	var font := ThemeDB.fallback_font
	for i in 4:
		var x := i * w
		area.draw_rect(Rect2(x + 4, 0, w - 8, area.size.y - 30), Color(1, 1, 1, 0.04 + _flash[i] * 0.12))
		area.draw_string(font, Vector2(x, area.size.y - 8), "%d · %s" % [i + 1, tr(LANES[i])], HORIZONTAL_ALIGNMENT_CENTER, w, 16, COLORS[i])
	# Kazan çizgisi
	area.draw_rect(Rect2(0, hit_y - 3, area.size.x, 6), Color("b87a3a"))
	if _state == "pick":
		return
	for n in _notes:
		if n["hit"]:
			continue
		var y := hit_y - (float(n["t"]) - _now) * _speed
		if y < -30.0 or y > area.size.y:
			continue
		var cx := (int(n["lane"]) + 0.5) * w
		area.draw_circle(Vector2(cx, y), 20.0, COLORS[int(n["lane"])])
		area.draw_arc(Vector2(cx, y), 20.0, 0, TAU, 20, Color("1d2330"), 3.0)
	if _last != "":
		area.draw_string(font, Vector2(0, 40), _last, HORIZONTAL_ALIGNMENT_CENTER, area.size.x, 26, C_GOLD)
