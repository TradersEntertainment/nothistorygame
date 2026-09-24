class_name MiniGameCauldron
extends MiniGame
## Kadri'nin kazanı: dört malzeme oluğu; yukarıdan düşen malzemeyi kazanın ağzına geldiğinde doğru tuşla (1-4) at.
## Tam zamanında %100, yakın %60, kaçırma %0. Puan = başarı yüzdesi.
## Önce tarif seçilir: üç tarif (Çırak, Kalfa, Aşçıbaşı) ya da Kadri'yle düello (Kadri de aynı tarifi pişirir;
## onun puanını geçmek gerekir). Kadri sol kartta yorum yapar.

## Tarifler: oluklardaki malzemeler (MiniGame.ingredient türleri), hız, nota sayısı, aralık, çift nota olasılığı.
const RECIPES := [
	{"name": "MG_CAUL_R0", "desc": "MG_CAUL_R0_D", "lanes": [0, 1, 4, 3], "speed": 250.0, "count": 24, "gap": 0.82, "double": 0.0, "stars": 1},
	{"name": "MG_CAUL_R1", "desc": "MG_CAUL_R1_D", "lanes": [4, 1, 2, 3], "speed": 320.0, "count": 34, "gap": 0.62, "double": 0.08, "stars": 2},
	{"name": "MG_CAUL_R2", "desc": "MG_CAUL_R2_D", "lanes": [2, 1, 5, 3], "speed": 410.0, "count": 44, "gap": 0.5, "double": 0.16, "stars": 3},
	{"name": "MG_CAUL_R3", "desc": "MG_CAUL_R3_D", "lanes": [0, 2, 5, 3], "speed": 340.0, "count": 36, "gap": 0.58, "double": 0.12, "stars": 2},
]
const ING_NAMES := ["MG_CAUL_L0", "MG_CAUL_L1", "MG_CAUL_L2", "MG_CAUL_L3", "MG_CAUL_L4", "MG_CAUL_L5"]
const ING_COLORS := [Color("e8c078"), Color("c878b8"), Color("d86a50"), Color("d8902a"), Color("f4f0e4"), Color("e0402a")]
const PERFECT := 0.09
const GOOD := 0.18

var duel := false
var kadri_score := 0
var _recipe: Dictionary = RECIPES[0]
var _state := "pick"     # pick, count, play, result
var _notes: Array = []   # [{lane, t, hit, score}]
var _now := -3.0
var _speed := 320.0
var _points := 0.0
var _judged := 0
var _combo := 0
var _best_combo := 0
var _miss_run := 0
var _flash: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _result_t := 0.0
var _parts: Array = []   # sıçrayan damlalar: {p, v, life, col}
var _broth := Color("8a5a2a")
var _k_hits := 0.0       # düelloda Kadri'nin biriken puanı
var _cards: Array[Rect2] = []
var _hover := -1
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	host_speaker = "SPK_KADRI"


func setup() -> void:
	_rng.randomize()
	heading(tr("MG_CAUL_TITLE"))
	area.draw.connect(_draw_area)
	area.gui_input.connect(_on_input)
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	say("MG_CAUL_K_PICK")
	keys([["1", "MG_CAUL_R0"], ["2", "MG_CAUL_R1"], ["3", "MG_CAUL_R2"], ["4", "MG_CAUL_R3"]])
	var best := int(GameState.stats.get("cauldron_best", 0))
	status(tr("MG_CAUL_BEST") % best if best > 0 else "")
	records([["MG_REC_BEST", best], ["MG_REC_DUEL_WINS", int(GameState.stats.get("kadri_duel_wins", 0))]])


func _on_input(e: InputEvent) -> void:
	if _state != "pick":
		return
	if e is InputEventMouseMotion:
		_hover = -1
		for i in _cards.size():
			if _cards[i].has_point(e.position):
				_hover = i
	elif e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		for i in _cards.size():
			if _cards[i].has_point(e.position):
				_start(i)
				return


func _start(i: int) -> void:
	_recipe = RECIPES[i]
	duel = i == 3
	_speed = _recipe["speed"]
	var t := 0.0
	for k in int(_recipe["count"]):
		t += float(_recipe["gap"]) * _rng.randf_range(0.8, 1.25)
		var lane := _rng.randi() % 4
		_notes.append({"lane": lane, "t": t, "hit": false})
		if _rng.randf() < float(_recipe["double"]):
			_notes.append({"lane": (lane + 1 + _rng.randi() % 3) % 4, "t": t, "hit": false})
	_now = -3.0
	_state = "count"
	say("MG_CAUL_K_START_%d" % i)
	var kl: Array = []
	for n in 4:
		kl.append([str(n + 1), ING_NAMES[int(_recipe["lanes"][n])]])
	keys(kl)
	Audio.sfx("ui_confirm", -6.0)


func _process(delta: float) -> void:
	_update_parts(delta)
	area.queue_redraw()
	if _state == "pick":
		for i in 4:
			if Input.is_action_just_pressed("choice_%d" % (i + 1)):
				_start(i)
				return
		return
	if _state == "result":
		_result_t += delta
		if _result_t > 2.6 or (_result_t > 0.4 and Input.is_action_just_pressed("advance")):
			var score := int(round(_points))
			finish(score, score > kadri_score if duel else score >= 80)
		return
	_now += delta
	for i in 4:
		_flash[i] = maxf(0.0, _flash[i] - delta * 3.0)
	if _state == "count":
		if _now >= 0.0:
			_state = "play"
			big("MG_CAUL_GO", C_ACCENT)
		_status_line()
		return
	for i in 4:
		if Input.is_action_just_pressed("choice_%d" % (i + 1)):
			_press(i)
	for n in _notes:
		if not n["hit"] and _now - float(n["t"]) > GOOD:
			n["hit"] = true
			n["score"] = 0.0
			_judge(false)
	if _judged >= _notes.size():
		_end()
	_status_line()


func _status_line() -> void:
	if duel:
		status(tr("MG_CAUL_DUEL_SCORE") % [_current(), _kadri_now()])
	else:
		status(tr("MG_CAUL_STATUS") % [_current(), _combo])


func _current() -> int:
	var s := 0.0
	for n in _notes:
		s += float(n.get("score", 0.0))
	return int(round(s / maxf(1.0, float(_notes.size()))))


func _kadri_now() -> int:
	return int(round(_k_hits / maxf(1.0, float(_notes.size()))))


func _judge(hit: bool) -> void:
	_judged += 1
	if duel:
		# Kadri de aynı notayı pişirir: çoğunlukla tam, bazen yakın, nadiren kaçırır
		var r := _rng.randf()
		_k_hits += 100.0 if r < 0.66 else (60.0 if r < 0.9 else 0.0)
	if hit:
		_combo += 1
		_miss_run = 0
		_best_combo = maxi(_best_combo, _combo)
		if _combo in [8, 16, 24, 32]:
			say("MG_CAUL_K_COMBO_%d" % (1 + _rng.randi() % 3))
			big(tr("MG_CAUL_COMBO") % _combo, C_ACCENT)
	else:
		_combo = 0
		_miss_run += 1
		if _miss_run == 3:
			say("MG_CAUL_K_MISS_%d" % (1 + _rng.randi() % 3))
			big("MG_CAUL_MISS", C_RED)


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
		big("MG_CAUL_WRONG", C_RED)
		return
	best["hit"] = true
	best["score"] = 100.0 if bd <= PERFECT else 60.0
	_judge(true)
	var kind: int = _recipe["lanes"][lane]
	_broth = _broth.lerp(ING_COLORS[kind].darkened(0.35), 0.12)
	_splash(lane, ING_COLORS[kind])
	if _combo % 8 != 0:
		if bd <= PERFECT:
			big("MG_CAUL_PERFECT", C_GOLD)
		else:
			big("MG_CAUL_GOOD", C_CREAM)
	Audio.sfx("ui_select", -10.0, 1.0 + lane * 0.12)


func _end() -> void:
	_state = "result"
	_points = float(_current())
	kadri_score = _kadri_now()
	var score := int(round(_points))
	if duel:
		say("MG_CAUL_K_DUEL_WIN" if score > kadri_score else "MG_CAUL_K_DUEL_LOSE")
		big(tr("MG_CAUL_DUEL_SCORE") % [score, kadri_score], C_GOLD if score > kadri_score else C_RED)
	else:
		say("MG_CAUL_K_GREAT" if score >= 80 else ("MG_CAUL_K_OK" if score >= 45 else "MG_CAUL_K_BAD"))
		big(tr("MG_CAUL_SCORE") % score, C_GOLD)
	keys([["E", "MG_CONTINUE"]])
	Audio.sfx("stamp", -6.0)


# ---------------------------------------------------------------- yerleşim ve çizim

func _chute_rect() -> Rect2:
	var w := minf(area.size.x * 0.56, 560.0)
	return Rect2((area.size.x - w) * 0.5, 0, w, _hit_y())


func _hit_y() -> float:
	return area.size.y - 130.0


func _lane_x(lane: int) -> float:
	var r := _chute_rect()
	return r.position.x + (lane + 0.5) * r.size.x / 4.0


func _splash(lane: int, col: Color) -> void:
	for i in 10:
		_parts.append({"p": Vector2(_lane_x(lane), _hit_y() + 6), "v": Vector2(_rng.randf_range(-120, 120), _rng.randf_range(-260, -120)),
			"life": 0.7, "col": col if i % 2 == 0 else _broth.lightened(0.3)})


func _update_parts(delta: float) -> void:
	for p in _parts:
		p["v"] += Vector2(0, 600) * delta
		p["p"] += p["v"] * delta
		p["life"] -= delta
	_parts = _parts.filter(func(p): return p["life"] > 0.0)


func _draw_area() -> void:
	var s := area.size
	var font := ThemeDB.fallback_font
	# Çadır mutfağı: kanvas duvar, dikiş çizgileri, asılı bakır tencereler ve sarımsak
	vgrad(area, Rect2(Vector2.ZERO, s), Color("6b4a2e"), Color("22150c"))
	var x := 0.0
	while x < s.x:
		area.draw_line(Vector2(x, 0), Vector2(x + 30, s.y), Color(0, 0, 0, 0.1), 2.0)
		x += 90.0
	area.draw_line(Vector2(0, 22), Vector2(s.x, 30), Color("3a2414"), 3.0)
	for i in int(s.x / 110.0):
		var px := 40.0 + i * 110.0
		var sw := sin(_time * 1.2 + i) * 2.0
		area.draw_line(Vector2(px, 26), Vector2(px + sw, 44), Color("2a1a10"), 2.0)
		if i % 3 == 1:
			for g in 4:
				area.draw_circle(Vector2(px + sw, 50 + g * 12), 6.0, Color("efe6d0"))
		else:
			ellipse(area, Vector2(px + sw, 58), 20, 14, Color("b8683a") if i % 2 == 0 else Color("a8783a"))
			ellipse(area, Vector2(px + sw - 6, 54), 7, 4, Color(1, 1, 1, 0.25))
	# Yan raflar: kavanozlar ve malzemeler (boş duvar kalmasın)
	var cr := _chute_rect()
	var shelf_w := cr.position.x - 40.0
	for side in [0, 1]:
		var sx := 16.0 if side == 0 else cr.end.x + 24.0
		if shelf_w < 80.0 or _state == "pick" or (duel and side == 1):
			continue
		for row in 3:
			var sy := 130.0 + row * 110.0
			if sy > s.y - 170.0:
				break
			area.draw_rect(Rect2(sx, sy, shelf_w, 10), Color("5a3a22"))
			area.draw_rect(Rect2(sx, sy + 10, shelf_w, 3), Color(0, 0, 0, 0.3))
			for j in int(shelf_w / 46.0):
				var jc := Vector2(sx + 24 + j * 46, sy - 22)
				var kind: int = (row * 3 + j + side * 2) % 6
				if (j + row) % 3 == 2:
					ingredient(area, kind, jc + Vector2(0, 4), 15.0)
				else:
					area.draw_rect(Rect2(jc.x - 15, jc.y - 18, 30, 36), Color(ING_COLORS[kind], 0.55))
					area.draw_rect(Rect2(jc.x - 15, jc.y - 18, 30, 36), Color(1, 1, 1, 0.25), false, 1.5)
					area.draw_rect(Rect2(jc.x - 12, jc.y - 24, 24, 7), Color("7a5232"))
	if _state == "pick":
		_draw_pick()
		return
	# Oluklar
	var hy := _hit_y()
	for i in 4:
		var lx := _lane_x(i)
		var lw := cr.size.x / 4.0 - 12.0
		var kind: int = _recipe["lanes"][i]
		area.draw_rect(Rect2(lx - lw * 0.5, 0, lw, hy), Color(0, 0, 0, 0.28))
		area.draw_rect(Rect2(lx - lw * 0.5, 0, lw, hy), Color(ING_COLORS[kind], 0.05 + _flash[i] * 0.25))
		area.draw_line(Vector2(lx - lw * 0.5, 0), Vector2(lx - lw * 0.5, hy), Color("8a6440", 0.6), 2.0)
		area.draw_line(Vector2(lx + lw * 0.5, 0), Vector2(lx + lw * 0.5, hy), Color("8a6440", 0.6), 2.0)
		ingredient(area, kind, Vector2(lx, 90), 16.0)
		area.draw_string(font, Vector2(lx - 50, 128), tr(ING_NAMES[kind]), HORIZONTAL_ALIGNMENT_CENTER, 100, 14, Color(ING_COLORS[kind], 0.9))
	# Kazan: ateş, gövde, ağız, et suyu, kabarcıklar, buhar
	var cw := cr.size.x * 0.5 + 60.0
	var cc := Vector2(s.x * 0.5, hy)
	for f in 7:
		var fx := cc.x - cw * 0.9 + f * cw * 0.3
		var fh := 34.0 + sin(_time * 9.0 + f * 1.7) * 10.0
		area.draw_colored_polygon(PackedVector2Array([Vector2(fx - 16, s.y), Vector2(fx + sin(_time * 7 + f) * 5, s.y - fh), Vector2(fx + 16, s.y)]), Color("e8702a"))
		area.draw_colored_polygon(PackedVector2Array([Vector2(fx - 8, s.y), Vector2(fx, s.y - fh * 0.6), Vector2(fx + 8, s.y)]), Color("ffd24a"))
	ellipse(area, cc + Vector2(0, 64), cw, 96, Color("1a1612"))
	ellipse(area, cc + Vector2(-cw * 0.45, 50), cw * 0.2, 36, Color(1, 1, 1, 0.05))
	ellipse(area, cc, cw, 26, Color("2a2420"))
	ellipse(area, cc + Vector2(0, 3), cw - 10, 19, _broth)
	for b in 9:
		var ph := fmod(_time * 0.9 + b * 0.37, 1.0)
		var bp := cc + Vector2((b / 8.0 - 0.5) * (cw - 30) * 1.7, 4 - ph * 6)
		area.draw_arc(bp, 3.0 + ph * 5.0, PI, TAU, 8, _broth.lightened(0.35), 2.0)
	ellipse(area, cc, cw, 26, Color("c9a24a"), false, 4.0)
	for i in 4:
		var mc := Vector2(_lane_x(i), hy)
		area.draw_arc(mc, 26.0, 0, TAU, 24, Color(1, 1, 1, 0.35 + _flash[i] * 0.6), 3.0)
		area.draw_string(font, mc + Vector2(-20, 58), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, 40, 22, C_GOLD)
	for k in 6:
		var ph2 := fmod(_time * 0.35 + k / 6.0, 1.0)
		area.draw_circle(cc + Vector2(sin(k * 2.1 + _time) * cw * 0.5, -20 - ph2 * 220), 14.0 + ph2 * 26.0, Color(1, 1, 1, 0.1 * (1.0 - ph2)))
	# Düşen malzemeler
	for n in _notes:
		if n["hit"]:
			continue
		var y := hy - (float(n["t"]) - _now) * _speed
		if y < 140.0 or y > s.y:
			continue
		var p := Vector2(_lane_x(int(n["lane"])), y)
		area.draw_circle(p + Vector2(3, 4), 22.0, Color(0, 0, 0, 0.25))
		ingredient(area, int(_recipe["lanes"][int(n["lane"])]), p, 22.0)
	for p in _parts:
		area.draw_circle(p["p"], 4.0 * clampf(p["life"] / 0.4, 0.3, 1.0), p["col"])
	# Tarif ilerlemesi (üstte)
	var prog := _judged / maxf(1.0, float(_notes.size()))
	area.draw_rect(Rect2(cr.position.x, 6, cr.size.x, 8), Color(0, 0, 0, 0.4))
	area.draw_rect(Rect2(cr.position.x, 6, cr.size.x * prog, 8), C_ACCENT)
	if duel:
		_draw_duel_bars(cr)
	if _state == "count":
		area.draw_string(title_font if title_font else font, Vector2(0, s.y * 0.42), tr("MG_CAUL_READY") % int(ceil(-_now)), HORIZONTAL_ALIGNMENT_CENTER, s.x, 34, C_CREAM)


func _draw_duel_bars(cr: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var h := _hit_y() - 200.0
	for k in 2:
		var bx := cr.end.x + 40.0 + k * 56.0
		var v := float(_current() if k == 0 else _kadri_now()) / 100.0
		area.draw_rect(Rect2(bx, 170, 34, h), Color(0, 0, 0, 0.55))
		area.draw_rect(Rect2(bx, 170 + h * (1.0 - v), 34, h * v), C_ACCENT if k == 0 else Color("e8702a"))
		area.draw_rect(Rect2(bx, 170, 34, h), C_FRAME, false, 2.0)
		area.draw_string(font, Vector2(bx - 20, 160), tr("MG_CAUL_YOU") if k == 0 else "Kadri", HORIZONTAL_ALIGNMENT_CENTER, 74, 15, C_CREAM)


func _draw_pick() -> void:
	var s := area.size
	var font := ThemeDB.fallback_font
	var tf := title_font if title_font else font
	var cols := 4 if s.x > 760 else 2
	var gap := 16.0
	var cw := (s.x - gap * (cols + 1)) / cols
	var ch := s.y - 90.0 if cols == 4 else (s.y - 90.0) * 0.5
	var top := 64.0
	_cards.resize(4)
	for i in 4:
		var r: Dictionary = RECIPES[i]
		var rect := Rect2(Vector2(gap + (i % cols) * (cw + gap), top + (i / cols) * (ch + gap)), Vector2(cw, ch))
		_cards[i] = rect
		if _hover == i:
			rect.position.y -= 6.0
		area.draw_rect(Rect2(rect.position + Vector2(4, 6), rect.size), Color(0, 0, 0, 0.35))
		area.draw_rect(rect, Color("efe2c2") if i < 3 else Color("f2d2a8"))
		area.draw_rect(rect.grow(-5), Color("b8904a"), false, 2.0)
		if i == 3:
			area.draw_rect(rect.grow(-9), C_RED, false, 1.5)
		var badge := Rect2(rect.position + Vector2(12, 12), Vector2(30, 30))
		area.draw_rect(badge, C_INK)
		area.draw_string(font, badge.position + Vector2(0, 22), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, 30, 20, C_GOLD)
		var stars := ""
		for k in 3:
			stars += "★" if k < int(r["stars"]) else "☆"
		area.draw_string(font, rect.position + Vector2(0, 34), stars, HORIZONTAL_ALIGNMENT_RIGHT, cw - 14, 20, Color("b8402e"))
		var fs := 20
		while fs > 12 and tf.get_string_size(tr(r["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > cw - 20:
			fs -= 1
		area.draw_string(tf, rect.position + Vector2(10, 80), tr(r["name"]), HORIZONTAL_ALIGNMENT_CENTER, cw - 20, fs, C_INK)
		var ir := minf(18.0, cw * 0.07)
		for k in 4:
			ingredient(area, int(r["lanes"][k]), rect.position + Vector2(cw * (0.5 + (k - 1.5) * 0.22), 128), ir)
		area.draw_line(rect.position + Vector2(20, 158), rect.position + Vector2(cw - 20, 158), Color("b8904a"), 1.0)
		var lines := wrap_text(tr(r["desc"]), font, 14, cw - 28)
		for li in mini(lines.size(), int((ch - 176) / 19.0)):
			area.draw_string(font, rect.position + Vector2(14, 182 + li * 19), lines[li], HORIZONTAL_ALIGNMENT_LEFT, cw - 28, 14, Color("5a3a22"))
		# Kase (tarifin rengiyle, buharı tüten) ve alt bilgi: malzeme sayısı, süre
		var text_end := rect.position.y + 182 + lines.size() * 19
		var bowl := Vector2(rect.position.x + cw * 0.5, lerpf(text_end, rect.end.y - 40, 0.55))
		var bw := cw * 0.34
		ellipse(area, bowl + Vector2(0, 26), bw * 0.45, 8, Color(0, 0, 0, 0.15))
		area.draw_colored_polygon(PackedVector2Array([bowl + Vector2(-bw, 0), bowl + Vector2(bw, 0), bowl + Vector2(bw * 0.55, 24), bowl + Vector2(-bw * 0.55, 24)]), Color("8a5a2a"))
		area.draw_line(bowl + Vector2(-bw * 0.8, 10), bowl + Vector2(bw * 0.8, 10), Color("c9a24a"), 2.0)
		ellipse(area, bowl, bw, 12, Color("6b4428"))
		ellipse(area, bowl + Vector2(0, 1), bw - 5, 8, [Color("d8a050"), Color("f0e8d0"), Color("a8402a"), Color("c8502a")][i])
		for k in 3:
			var ph := fmod(_time * 0.5 + k * 0.33, 1.0)
			var sx := -bw * 0.4 + k * bw * 0.4
			area.draw_polyline(PackedVector2Array([bowl + Vector2(sx, -8 - ph * 30), bowl + Vector2(sx + 5, -16 - ph * 30), bowl + Vector2(sx, -24 - ph * 30)]), Color(0.4, 0.3, 0.2, 0.45 * (1.0 - ph)), 2.0)
		var secs := int(float(r["count"]) * float(r["gap"]))
		area.draw_string(font, Vector2(rect.position.x, rect.end.y - 16), tr("MG_CAUL_CARD_INFO") % [int(r["count"]), secs], HORIZONTAL_ALIGNMENT_CENTER, cw, 13, Color("7a5a3a"))
	area.draw_string(tf, Vector2(0, 36), tr("MG_CAUL_PICK"), HORIZONTAL_ALIGNMENT_CENTER, s.x, 24, C_CREAM)
