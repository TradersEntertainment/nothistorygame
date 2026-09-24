class_name MiniGameMangala
extends MiniGame
## Mangala (Kalah kuralları), Konstantinos'la: 6 çukur × 2, her çukurda 4 taş.
## Oyuncunun çukurları 0-5 (alt, soldan sağa), hazinesi 6 (sağ); rakibinki 7-12 (üst, sağdan sola), hazinesi 13 (sol).
## Son taş kendi hazinene düşerse bir daha oynarsın; kendi boş çukuruna düşerse karşıdakini de alırsın.
## 1-6 ya da fareyle çukur seç. Konstantinos sol kartta yorum yapar.

const STONE_COLS := [Color("e8e0cc"), Color("c8a0d8"), Color("6ff2c8"), Color("e0b85a"), Color("e07a6a")]

var _b: Array[int] = []
var _turn := "player"          # player, ai, over
var _ai_t := 0.0
var _msg := ""
var _pits: Array[Rect2] = []   # 0-13 için tıklama/çizim alanları
var _glow: Array[float] = []   # taş sayısı değişen çukurlar kısa süre parlar
var _hover := -1
var _last_pit := -1
var _board := Rect2()


func _init() -> void:
	host_speaker = "SPK_EMPEROR"


func setup() -> void:
	heading(tr("MG_MAN_TITLE"))
	keys([["1–6", "MG_MAN_K_PIT"]])
	records([["MG_REC_WINS", int(GameState.stats.get("mangala_wins", 0))], ["MG_REC_TO_WIN", "25+"]])
	for i in 14:
		_b.append(0 if i == 6 or i == 13 else 4)
		_glow.append(0.0)
	_msg = tr("MG_MAN_YOUR_TURN")
	say("MG_MAN_E_OPEN")
	area.draw.connect(_draw_area)
	area.gui_input.connect(_on_area_input)
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	_layout()
	_update_status()


func _update_status() -> void:
	status(tr("MG_MAN_SCORE") % [_b[6], _b[13]])


func _layout() -> void:
	var w := area.size.x
	var h := area.size.y
	var bw := minf(w - 40.0, 1000.0)
	var bh := minf(h * 0.62, bw * 0.42)
	_board = Rect2((w - bw) * 0.5, h * 0.16, bw, bh)
	var store_w := bw * 0.11
	var inner := bw - store_w * 2.0 - 40.0
	var pw := inner / 6.0
	_pits.resize(14)
	for i in 6:
		var x := _board.position.x + 20.0 + store_w + i * pw
		_pits[i] = Rect2(x + 6, _board.position.y + bh * 0.53, pw - 12, bh * 0.4)
		_pits[12 - i] = Rect2(x + 6, _board.position.y + bh * 0.07, pw - 12, bh * 0.4)
	_pits[6] = Rect2(_board.end.x - 10.0 - store_w, _board.position.y + bh * 0.07, store_w, bh * 0.86)
	_pits[13] = Rect2(_board.position.x + 10.0, _board.position.y + bh * 0.07, store_w, bh * 0.86)


func _on_area_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_hover = -1
		for i in 6:
			if _pits[i].has_point(event.position):
				_hover = i
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _turn == "over":
			finish(_b[6], _b[6] > _b[13])
			return
		if _turn == "player":
			for i in 6:
				if _pits[i].has_point(event.position):
					_player_move(i)


func _process(delta: float) -> void:
	for i in 14:
		_glow[i] = maxf(0.0, _glow[i] - delta * 1.6)
	area.queue_redraw()
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


## Hamle öncesi/sonrası tahtayı karşılaştırıp değişen çukurları parlatır.
func _mark(before: Array) -> void:
	for i in 14:
		if before[i] != _b[i]:
			_glow[i] = 1.0
	_update_status()


func _player_move(i: int) -> void:
	if _b[i] == 0:
		_msg = tr("MG_MAN_EMPTY")
		return
	var before := _b.duplicate()
	var store_before := _b[6]
	var again := _sow(_b, i, true)
	_last_pit = i
	_mark(before)
	Audio.sfx("ui_select", -8.0)
	if _b[6] - store_before >= 4 and not again:
		say("MG_MAN_E_OUCH_%d" % (1 + randi() % 3))
	if _check_end():
		return
	if again:
		_msg = tr("MG_MAN_AGAIN")
		big("MG_MAN_BIG_AGAIN", C_ACCENT)
	else:
		_turn = "ai"
		_ai_t = 1.0
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
	var before := _b.duplicate()
	var store_before := _b[13]
	var again2 := _sow(_b, best, false)
	_last_pit = best
	_mark(before)
	Audio.sfx("ui_select", -10.0, 0.8)
	if _b[13] - store_before >= 4 and not again2:
		say("MG_MAN_E_CAPTURE_%d" % (1 + randi() % 3))
	if _check_end():
		return
	if again2:
		_ai_t = 1.0
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
	_update_status()
	if _b[6] > _b[13]:
		_msg = tr("MG_MAN_WIN") % [_b[6], _b[13]]
		big("MG_MAN_BIG_WIN", C_GOLD)
		say("MG_MAN_E_WIN")
	elif _b[6] < _b[13]:
		_msg = tr("MG_MAN_LOSE") % [_b[6], _b[13]]
		big("MG_MAN_BIG_LOSE", C_RED)
		say("MG_MAN_E_LOSE")
	else:
		_msg = tr("MG_MAN_DRAW") % [_b[6], _b[13]]
		big("MG_MAN_BIG_DRAW", C_CREAM)
	keys([["E", "MG_CONTINUE"]])
	Audio.sfx("stamp", -6.0)
	area.queue_redraw()
	return true


# ---------------------------------------------------------------- çizim

func _draw_area() -> void:
	var s := area.size
	var font := ThemeDB.fallback_font
	var tf := title_font if title_font else font
	# Saray salonu: koyu mor duvar, mermer zemin, iki yanda perde ve mumlar
	vgrad(area, Rect2(0, 0, s.x, s.y * 0.72), Color("2a1838"), Color("4a2a5a"))
	vgrad(area, Rect2(0, s.y * 0.72, s.x, s.y * 0.28), Color("d8d0c0"), Color("a89c88"), 8)
	for k in 12:
		area.draw_line(Vector2(k * s.x / 11.0, s.y * 0.72), Vector2(s.x * 0.5 + (k * s.x / 11.0 - s.x * 0.5) * 1.8, s.y), Color(0, 0, 0, 0.08), 2.0)
	for k in int(s.x / 60.0) + 1:
		MiniGame._star(area, Vector2(30 + k * 60, 26), 9.0, Color(C_FRAME, 0.18))
	for side in [0, 1]:
		var px := 0.0 if side == 0 else s.x - 70.0
		for f in 4:
			area.draw_rect(Rect2(px + f * 17, 0, 15, s.y * 0.8 - f * 6), Color("5a2a6a").darkened(0.08 * (f % 2)))
		area.draw_rect(Rect2(px, s.y * 0.8 - 30, 70, 8), C_FRAME)
		var cx := 110.0 if side == 0 else s.x - 110.0
		area.draw_rect(Rect2(cx - 4, s.y * 0.5, 8, s.y * 0.22), Color("c9a24a"))
		area.draw_rect(Rect2(cx - 7, s.y * 0.43, 14, s.y * 0.07), Color("f4ecd8"))
		var fl := sin(_time * 11.0 + side * 3.0) * 1.5
		area.draw_circle(Vector2(cx + fl, s.y * 0.43 - 10), 22.0, Color(1.0, 0.8, 0.4, 0.12))
		ellipse(area, Vector2(cx + fl, s.y * 0.43 - 9), 4.5, 9.0, Color("ffd24a"))
		ellipse(area, Vector2(cx + fl * 0.6, s.y * 0.43 - 7), 2.2, 5.0, Color("fff4d0"))
	# Tahta
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("7a5232")
	sb.set_corner_radius_all(int(_board.size.y * 0.16))
	sb.border_color = Color("4a2e1a")
	sb.set_border_width_all(4)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 14
	sb.shadow_offset = Vector2(0, 8)
	area.draw_style_box(sb, _board)
	for k in 7:
		var gy := _board.position.y + _board.size.y * (0.12 + k * 0.13)
		area.draw_line(Vector2(_board.position.x + 30, gy), Vector2(_board.end.x - 30, gy + sin(k) * 3.0), Color(0, 0, 0, 0.08), 2.0)
	area.draw_line(Vector2(_pits[13].end.x + 12, _board.get_center().y), Vector2(_pits[6].position.x - 12, _board.get_center().y), Color("4a2e1a", 0.6), 2.0)
	for i in 14:
		var r := _pits[i]
		var store := i == 6 or i == 13
		var c := r.get_center()
		var rx := r.size.x * 0.5
		var ry := r.size.y * 0.5
		ellipse(area, c + Vector2(0, 3), rx, ry, Color("3a2212"))
		ellipse(area, c + Vector2(0, 5), rx - 3, ry - 3, Color("5a3a22"))
		if i <= 5 and _turn == "player" and _b[i] > 0 and (_hover == i):
			ellipse(area, c, rx + 4, ry + 4, Color(C_ACCENT, 0.35), false, 4.0)
		if _glow[i] > 0.0:
			ellipse(area, c, rx + 2, ry + 2, Color(C_GOLD, _glow[i] * 0.8), false, 3.0)
		if i == _last_pit:
			ellipse(area, c, rx - 6, ry - 6, Color(1, 1, 1, 0.12), false, 2.0)
		# Taşlar: sabit tohumlu dağılım (sayı değişmedikçe yerinde durur)
		var rng := RandomNumberGenerator.new()
		rng.seed = i * 31 + _b[i] * 7
		var sr := clampf(minf(rx, ry) * 0.2, 5.0, 9.0)
		for k in mini(_b[i], 30):
			var a := rng.randf() * TAU
			var d := sqrt(rng.randf())
			var p := c + Vector2(cos(a) * (rx - sr - 4) * d, sin(a) * (ry - sr - 4) * d + 3)
			gem(area, p, sr, STONE_COLS[(k + i) % STONE_COLS.size()])
		var num_c := C_GOLD if store else C_CREAM
		var badge := Vector2(c.x, r.position.y - 4 if i >= 7 or store else r.end.y + 20)
		if store:
			badge = Vector2(c.x, r.end.y + 24)
		area.draw_string(tf, badge + Vector2(-30, 0), str(_b[i]), HORIZONTAL_ALIGNMENT_CENTER, 60, 22 if store else 18, num_c)
		if i <= 5:
			area.draw_string(font, Vector2(c.x - 20, _board.end.y + 32), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, 40, 16, C_DIM)
	# Hazine adları
	area.draw_string(font, Vector2(_pits[13].position.x - 30, _board.position.y - 12), tr("SPK_EMPEROR").split(" ")[0], HORIZONTAL_ALIGNMENT_CENTER, _pits[13].size.x + 60, 15, Color("d9a8ff"))
	area.draw_string(font, Vector2(_pits[6].position.x - 30, _board.position.y - 12), tr("MG_MAN_YOU"), HORIZONTAL_ALIGNMENT_CENTER, _pits[6].size.x + 60, 15, C_ACCENT)
	# Sıra bilgisi (alt, parşömen şerit)
	var bar := Rect2(s.x * 0.2, s.y - 58, s.x * 0.6, 42)
	area.draw_rect(Rect2(bar.position + Vector2(3, 4), bar.size), Color(0, 0, 0, 0.3))
	area.draw_rect(bar, Color("efe2c2"))
	area.draw_rect(bar.grow(-4), Color("b8904a"), false, 1.5)
	area.draw_string(tf, bar.position + Vector2(0, 29), _msg, HORIZONTAL_ALIGNMENT_CENTER, bar.size.x, 19, C_INK)
