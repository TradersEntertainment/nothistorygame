class_name MiniGameArchery
extends MiniGame
## Ordugâhta okçuluk talimi, Hasan'la: 8 ok. Fareyle (ya da WASD) nişan al; nişangâh nefesle sallanır,
## Shift'e basılı tutunca nefesini tutarsın (nefes çubuğu biter). Sol tık ya da Boşluk ile at.
## 1-3. oklar rüzgârsız, 4-6. oklarda rüzgâr (bayrak gösterir, ok sürüklenir), 7-8. oklarda hedef sallanır.
## Halkalar 10/8/6/4/2; hedefin tepesindeki elmayı vurmak 10 puan ve Hasan'ın özel repliği.
## Toplam 50 ve üstü kazanır (en fazla 80).

const ARROWS := 8
const FLIGHT := 0.42

var _aim := Vector2.ZERO
var _arrow := 0              # atılan ok sayısı
var _score := 0
var _breath := 1.0
var _wind := 0.0             # px/uçuş (sağa +)
var _flying := false
var _fly_t := 0.0
var _fly_from := Vector2.ZERO
var _fly_to := Vector2.ZERO  # hedefe göre bağıl vuruş noktası
var _stuck: Array = []       # [bağıl nokta, puan]
var _apple_hit := false
var _over := false
var _last_pts := -1
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	host_speaker = "SPK_HASAN"


func setup() -> void:
	_rng.randomize()
	heading(tr("MG_ARC_TITLE"))
	keys([["WASD", "MG_ARC_K_AIM"], ["UI_KEY_SPACE", "MG_ARC_K_SHOOT"], ["Shift", "MG_ARC_K_BREATH"]])
	say("MG_ARC_H_OPEN")
	records([["MG_REC_BEST", int(GameState.stats.get("archery_best", 0))], ["MG_REC_TO_WIN", "50 / 80"]])
	area.draw.connect(_draw_area)
	area.gui_input.connect(_on_input)
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	_aim = _target_center() + Vector2(0, 60)
	_new_round()


func _target_center() -> Vector2:
	var c := Vector2(area.size.x * 0.5, area.size.y * 0.46)
	if _arrow >= 6:
		c.x += sin(_time * 1.3) * area.size.x * 0.16
	return c


func target_radius() -> float:
	return minf(area.size.y * 0.2, 110.0)


func _new_round() -> void:
	_wind = 0.0
	if _arrow >= 3:
		_wind = _rng.randf_range(35.0, 80.0) * (1.0 if _rng.randf() < 0.5 else -1.0)
	_refresh()


func _refresh() -> void:
	status(tr("MG_ARC_STATUS") % [mini(_arrow + 1, ARROWS), ARROWS, _score])


func _on_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion:
		_aim = e.position
	elif e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		if _over:
			finish(_score, _score >= 50)
		else:
			shoot()


func _process(delta: float) -> void:
	area.queue_redraw()
	if _over:
		if Input.is_action_just_pressed("advance"):
			finish(_score, _score >= 50)
		return
	var mv := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	_aim += mv * delta * 260.0
	_aim = _aim.clamp(Vector2.ZERO, area.size)
	if (Input.is_action_pressed("sprint") or Input.is_action_pressed("dive")) and _breath > 0.0:
		_breath = maxf(0.0, _breath - delta * 0.45)
	else:
		_breath = minf(1.0, _breath + delta * 0.25)
	if Input.is_action_just_pressed("jump"):
		shoot()
	if _flying:
		_fly_t += delta
		if _fly_t >= FLIGHT:
			_land()


## Nişangâhın salınımı (nefes tutulurken çok azalır).
func sway() -> Vector2:
	var amp := 16.0 if not ((Input.is_action_pressed("sprint") or Input.is_action_pressed("dive")) and _breath > 0.0) else 3.0
	return Vector2(sin(_time * 1.7) + sin(_time * 2.9) * 0.5, cos(_time * 1.3) + sin(_time * 3.7) * 0.4) * amp


func shoot() -> void:
	if _flying or _over:
		return
	var at := _aim + sway()
	_fly_from = Vector2(area.size.x * 0.5, area.size.y + 40)
	_fly_to = at + Vector2(_wind, 0) + Vector2(_rng.randf_range(-4, 4), _rng.randf_range(-4, 4)) - _target_center()
	_flying = true
	_fly_t = 0.0
	Audio.sfx("whoosh_fly", -8.0, 1.5)


func _land() -> void:
	_flying = false
	_arrow += 1
	var r := target_radius()
	var apple := Vector2(0, -r - 22)
	var pts := 0
	if not _apple_hit and _fly_to.distance_to(apple) < 16.0:
		pts = 10
		_apple_hit = true
		say("MG_ARC_H_APPLE")
		big("MG_ARC_BIG_APPLE", C_RED)
	else:
		var d := _fly_to.length() / r
		if d <= 1.0:
			pts = [10, 8, 6, 4, 2][mini(int(d * 5.0), 4)]
		if pts == 10:
			say("MG_ARC_H_BULL_%d" % (1 + _rng.randi() % 3))
			big("MG_ARC_BIG_BULL", C_GOLD)
		elif pts == 0:
			say("MG_ARC_H_MISS_%d" % (1 + _rng.randi() % 3))
			big("MG_ARC_BIG_MISS", C_RED)
		else:
			big(tr("MG_ARC_PTS") % pts, C_CREAM)
	_last_pts = pts
	_score += pts
	if pts > 0:
		_stuck.append([_fly_to, pts])
	Audio.sfx("land_thud" if pts > 0 else "ui_confirm", -6.0, 1.4)
	if _arrow == 3:
		say("MG_ARC_H_WIND")
	elif _arrow == 6:
		say("MG_ARC_H_MOVE")
	if _arrow >= ARROWS:
		_over = true
		say("MG_ARC_H_WIN" if _score >= 50 else "MG_ARC_H_LOSE")
		big(tr("MG_ARC_FINAL") % _score, C_GOLD if _score >= 50 else C_RED)
		keys([["E", "MG_CONTINUE"]])
		Audio.sfx("stamp", -6.0)
	else:
		_new_round()
	_refresh()


# ---------------------------------------------------------------- çizim

func _draw_area() -> void:
	var s := area.size
	var font := ThemeDB.fallback_font
	# Gökyüzü, tepeler, çadırlar, çimen
	vgrad(area, Rect2(0, 0, s.x, s.y * 0.55), Color("5a9ad0"), Color("d8e8ee"))
	for k in 3:
		var cx := fmod(k * 380.0 + _time * 8.0, s.x + 200.0) - 100.0
		for b in 3:
			area.draw_circle(Vector2(cx + b * 34, 60 + k * 26 + (b % 2) * 8), 26.0 - (b % 2) * 6, Color(1, 1, 1, 0.8))
	var hills := PackedVector2Array([Vector2(0, s.y * 0.55)])
	for k in 13:
		hills.append(Vector2(k * s.x / 12.0, s.y * (0.44 + sin(k * 1.3) * 0.04)))
	hills.append(Vector2(s.x, s.y * 0.55))
	area.draw_colored_polygon(hills, Color("7a9a5a"))
	for k in 9:
		var tx := k * s.x / 8.0 + (k % 2) * 30.0
		var ty := s.y * 0.53
		var tc: Color = [Color("e0d4b8"), Color("d8cbb0"), Color("c8b894")][k % 3]
		area.draw_colored_polygon(PackedVector2Array([Vector2(tx - 34, ty), Vector2(tx, ty - 40), Vector2(tx + 34, ty)]), tc)
		area.draw_line(Vector2(tx - 30, ty - 6), Vector2(tx + 30, ty - 6), [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a")][k % 3], 3.0)
		area.draw_line(Vector2(tx, ty - 40), Vector2(tx, ty - 52), Color("5a4028"), 2.0)
	vgrad(area, Rect2(0, s.y * 0.55, s.x, s.y * 0.45), Color("6e8a44"), Color("4b6a30"), 10)
	for k in 60:
		var gx := fmod(k * 73.0, s.x)
		var gy := s.y * 0.58 + fmod(k * 41.0, s.y * 0.4)
		area.draw_line(Vector2(gx, gy), Vector2(gx + 3, gy - 8), Color("8aa85a"), 2.0)
	# Saman balyaları ve ok sepeti
	for k in 2:
		var hx := s.x * (0.12 if k == 0 else 0.84)
		area.draw_rect(Rect2(hx - 50, s.y * 0.66, 100, 46), Color("d8b860"))
		area.draw_rect(Rect2(hx - 50, s.y * 0.66, 100, 46), Color("a88a3a"), false, 2.0)
		for l in 4:
			area.draw_line(Vector2(hx - 46, s.y * 0.67 + l * 11), Vector2(hx + 46, s.y * 0.67 + l * 11), Color("b8983a"), 1.0)
	var qx := s.x * 0.12
	area.draw_rect(Rect2(qx - 16, s.y * 0.66 - 50, 32, 50), Color("6a3a22"))
	for k in ARROWS - _arrow:
		area.draw_line(Vector2(qx - 12 + k * 3.4, s.y * 0.66 - 50), Vector2(qx - 16 + k * 3.4, s.y * 0.66 - 80), Color("c8a868"), 2.0)
		area.draw_colored_polygon(PackedVector2Array([Vector2(qx - 16 + k * 3.4, s.y * 0.66 - 80), Vector2(qx - 20 + k * 3.4, s.y * 0.66 - 90), Vector2(qx - 12 + k * 3.4, s.y * 0.66 - 88)]), Color("f2e6c9"))
	# Rüzgâr bayrağı
	var fp := Vector2(s.x * 0.86, s.y * 0.2)
	area.draw_line(fp, fp + Vector2(0, s.y * 0.46), Color("5a4028"), 4.0)
	var ws := _wind / 80.0
	var flag := PackedVector2Array()
	for k in 8:
		var t := k / 7.0
		flag.append(fp + Vector2(t * 70.0 * (ws if absf(ws) > 0.05 else 0.15), t * 40.0 * (1.0 - absf(ws)) + sin(_time * 8.0 + t * 4.0) * 4.0 * absf(ws)))
	for k in range(7, -1, -1):
		var t := k / 7.0
		flag.append(fp + Vector2(t * 70.0 * (ws if absf(ws) > 0.05 else 0.15), 24 + t * 40.0 * (1.0 - absf(ws)) + sin(_time * 8.0 + t * 4.0) * 4.0 * absf(ws)))
	area.draw_colored_polygon(flag, Color("c8262f"))
	area.draw_string(font, fp + Vector2(-60, -12), tr("MG_ARC_WIND") % [("→ " if _wind > 0 else "← ") if _wind != 0 else "", int(absf(_wind) / 8.0)], HORIZONTAL_ALIGNMENT_CENTER, 120, 15, C_INK)
	# Hedef: sehpa, halkalar, elma, saplanan oklar
	var tc2 := _target_center()
	var r := target_radius()
	area.draw_line(tc2 + Vector2(-r * 0.6, r * 0.6), tc2 + Vector2(-r * 0.9, r * 1.9), Color("5a3a22"), 7.0)
	area.draw_line(tc2 + Vector2(r * 0.6, r * 0.6), tc2 + Vector2(r * 0.9, r * 1.9), Color("5a3a22"), 7.0)
	area.draw_circle(tc2 + Vector2(6, 8), r + 8, Color(0, 0, 0, 0.25))
	area.draw_circle(tc2, r + 8, Color("d8b860"))
	var rings := [Color("f4f0e4"), Color("2a2a2a"), Color("2f5fa8"), Color("c8262f"), Color("ffd24a")]
	for k in 5:
		area.draw_circle(tc2, r * (1.0 - k * 0.2), rings[k])
	if not _apple_hit:
		area.draw_circle(tc2 + Vector2(0, -r - 22), 14.0, Color("c8262f"))
		area.draw_circle(tc2 + Vector2(-4, -r - 26), 4.0, Color(1, 1, 1, 0.5))
		area.draw_line(tc2 + Vector2(0, -r - 36), tc2 + Vector2(3, -r - 42), Color("5a3a22"), 2.0)
	for st in _stuck:
		var p: Vector2 = tc2 + st[0]
		area.draw_line(p, p + Vector2(10, 22), Color("6a4a2a"), 3.0)
		area.draw_colored_polygon(PackedVector2Array([p + Vector2(8, 18), p + Vector2(16, 28), p + Vector2(6, 26)]), Color("f2e6c9"))
		area.draw_circle(p, 3.0, Color("1a1a1a"))
	# Uçan ok
	if _flying:
		var t := _fly_t / FLIGHT
		var to := tc2 + _fly_to
		var p2 := _fly_from.lerp(to, t) + Vector2(0, -sin(t * PI) * 60.0)
		var len := lerpf(90.0, 22.0, t)
		var dir := (to - _fly_from).normalized()
		area.draw_line(p2, p2 - dir * len, Color("6a4a2a"), lerpf(6.0, 2.0, t))
		area.draw_circle(p2, lerpf(5.0, 2.0, t), Color("3a3a3a"))
	# Nişangâh
	if not _over:
		var a := _aim + sway()
		var hold := (Input.is_action_pressed("sprint") or Input.is_action_pressed("dive")) and _breath > 0.0
		var col := C_ACCENT if hold else Color(1, 1, 1, 0.9)
		area.draw_arc(a, 20.0, 0, TAU, 32, col, 2.5)
		for d in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
			area.draw_line(a + d * 10.0, a + d * 30.0, col, 2.0)
		area.draw_circle(a, 2.5, col)
	# Nefes çubuğu ve ok sayacı
	var bb := Rect2(20, s.y - 34, 200, 14)
	area.draw_rect(bb, Color(0, 0, 0, 0.45))
	area.draw_rect(Rect2(bb.position, Vector2(bb.size.x * _breath, bb.size.y)), C_ACCENT)
	area.draw_rect(bb, C_FRAME, false, 2.0)
	area.draw_string(font, bb.position + Vector2(0, -6), tr("MG_ARC_BREATH"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, C_CREAM)
	for k in ARROWS:
		var dot := Vector2(s.x - 30 - (ARROWS - 1 - k) * 22, s.y - 26)
		area.draw_circle(dot, 7.0, (C_GOLD if k < _arrow else Color(1, 1, 1, 0.25)))
