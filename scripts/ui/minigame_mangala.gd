class_name MiniGameMangala
extends MiniGame
## Mangala (Kalah kuralları), Konstantinos'la: 6 çukur × 2, her çukurda 4 taş.
## Oyuncunun çukurları 0-5 (alt, soldan sağa), hazinesi 6; rakibinki 7-12 (üst, sağdan sola), hazinesi 13.
## Son taş kendi hazinene düşerse bir daha oynarsın; kendi boş çukuruna düşerse karşıdakini de alırsın.
## 1-6 ya da fareyle çukur seç.

var _b: Array[int] = []
var _turn := "player"          # player, ai, over
var _ai_t := 0.0
var _msg := ""
var _pits: Array[Rect2] = []   # 0-13 için tıklama/çizim alanları


func setup() -> void:
	heading(tr("MG_MAN_TITLE"))
	footer(tr("MG_MAN_HELP"))
	for i in 14:
		_b.append(0 if i == 6 or i == 13 else 4)
	_msg = tr("MG_MAN_YOUR_TURN")
	area.draw.connect(_draw_area)
	area.gui_input.connect(_on_area_input)
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	_layout()


func _layout() -> void:
	var w := area.size.x
	var h := area.size.y
	var pw := (w - 200.0) / 6.0
	_pits.resize(14)
	for i in 6:
		_pits[i] = Rect2(100 + i * pw + 6, h * 0.55, pw - 12, h * 0.3)
		_pits[12 - i] = Rect2(100 + i * pw + 6, h * 0.12, pw - 12, h * 0.3)
	_pits[6] = Rect2(w - 90, h * 0.12, 80, h * 0.73)
	_pits[13] = Rect2(10, h * 0.12, 80, h * 0.73)


func _on_area_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _turn == "player":
		for i in 6:
			if _pits[i].has_point(event.position):
				_player_move(i)


func _process(delta: float) -> void:
	if _turn == "over":
		if Input.is_action_just_pressed("advance"):
			finish(_b[6], _b[6] > _b[13])
		return
	if _turn == "player":
		for i in 6:
			if Input.is_action_just_pressed("choice_%d" % (i + 1)):
				_player_move(i)
	elif _turn == "ai":
		_ai_t -= delta
		if _ai_t <= 0.0:
			_ai_move()
	area.queue_redraw()


func _player_move(i: int) -> void:
	if _b[i] == 0:
		_msg = tr("MG_MAN_EMPTY")
		return
	var again := _sow(_b, i, true)
	Audio.sfx("ui_select", -8.0)
	if _check_end():
		return
	if again:
		_msg = tr("MG_MAN_AGAIN")
	else:
		_turn = "ai"
		_ai_t = 0.9
		_msg = tr("MG_MAN_AI_THINK")


func _ai_move() -> void:
	var best := -1
	var best_v := -999.0
	for i in range(7, 13):
		if _b[i] == 0:
			continue
		var sim := _b.duplicate()
		var again := _sow(sim, i, false)
		var v := float(sim[13] - sim[6]) + (3.0 if again else 0.0) + randf() * 0.5
		if v > best_v:
			best_v = v
			best = i
	var again2 := _sow(_b, best, false)
	Audio.sfx("ui_select", -10.0, 0.8)
	if _check_end():
		return
	if again2:
		_ai_t = 0.9
		_msg = tr("MG_MAN_AI_AGAIN")
	else:
		_turn = "player"
		_msg = tr("MG_MAN_YOUR_TURN")


## Taşları dağıtır. Dönüş: son taş kendi hazinesine düştü mü (bir daha oynar).
static func _sow(b: Array, pit: int, player: bool) -> bool:
	var n: int = b[pit]
	b[pit] = 0
	var i := pit
	var skip := 13 if player else 6
	while n > 0:
		i = (i + 1) % 14
		if i == skip:
			continue
		b[i] += 1
		n -= 1
	var store := 6 if player else 13
	if i == store:
		return true
	var mine := (i >= 0 and i <= 5) if player else (i >= 7 and i <= 12)
	if mine and b[i] == 1 and b[12 - i] > 0:
		b[store] += b[12 - i] + 1
		b[12 - i] = 0
		b[i] = 0
	return false


func _check_end() -> bool:
	var p := 0
	var a := 0
	for i in 6:
		p += _b[i]
		a += _b[12 - i]
	if p > 0 and a > 0:
		return false
	for i in 6:
		_b[6] += _b[i]
		_b[i] = 0
		_b[13] += _b[12 - i]
		_b[12 - i] = 0
	_turn = "over"
	if _b[6] > _b[13]:
		_msg = tr("MG_MAN_WIN") % [_b[6], _b[13]]
	elif _b[6] < _b[13]:
		_msg = tr("MG_MAN_LOSE") % [_b[6], _b[13]]
	else:
		_msg = tr("MG_MAN_DRAW") % [_b[6], _b[13]]
	Audio.sfx("stamp", -6.0)
	area.queue_redraw()
	return true


func _draw_area() -> void:
	var font := ThemeDB.fallback_font
	var wood := Color("8a6440")
	area.draw_rect(Rect2(0, area.size.y * 0.08, area.size.x, area.size.y * 0.82), wood.darkened(0.35))
	for i in 14:
		var r := _pits[i]
		var store := i == 6 or i == 13
		var col := Color("5a3a22") if store else Color("6b4428")
		if i <= 5 and _turn == "player" and _b[i] > 0:
			col = col.lightened(0.12)
		area.draw_rect(r, col)
		area.draw_rect(r, Color("1d2330"), false, 2.0)
		# Taşlar: küçük noktalar (en fazla 12), üstünde sayı
		var rng := RandomNumberGenerator.new()
		rng.seed = i * 31 + _b[i]
		for s in mini(_b[i], 14):
			var p := r.position + Vector2(rng.randf_range(10, r.size.x - 10), rng.randf_range(24, r.size.y - 10))
			area.draw_circle(p, 5.0, [Color("e8e0cc"), Color("c8a0d8"), Color("6ff2c8"), Color("e0b85a")][s % 4])
		area.draw_string(font, r.position + Vector2(0, 20), str(_b[i]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 18, C_CREAM)
		if i <= 5:
			area.draw_string(font, r.position + Vector2(0, r.size.y + 18), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 15, C_DIM)
	area.draw_string(font, Vector2(0, area.size.y * 0.06), tr("SPK_EMPEROR"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("d9a8ff"))
	area.draw_string(font, Vector2(0, area.size.y * 0.06), tr("MG_MAN_YOUR_STORE"), HORIZONTAL_ALIGNMENT_RIGHT, area.size.x, 16, C_ACCENT)
	area.draw_string(font, Vector2(0, area.size.y - 4), _msg, HORIZONTAL_ALIGNMENT_CENTER, area.size.x, 20, C_GOLD)
