class_name MiniGameHaggle
extends MiniGame
## Pazarlık. Satıcılar:
##   wine   Galata şarapçısı: bir fıçı şarap; sabırsız, ucuz başlar.
##   double Galata'nın çifte tüccarı: "iki tarafa da" barut; sabırlı, pahalı başlar.
##   urban  Urban (ordugâh, topçu alanı): hatıra gülle; çok pahalı, düşük teklife patlar ama övgüye bayılır.
##   niko   Niko (Bizans, kançılarya önü): kuzeninin kayığı bir günlüğüne; çok sabırlı ama inatçı.
## 1 düşük teklif, 2 makul teklif, 3 fiyatı kabul, 4 tatlı dil (sabır kazandırır, en fazla iki kez); kartlara tıklanabilir.
## Satıcının sabrı (fitil) biterse pazarlık biter. Fiyat ilk fiyatın %60'ına ya da altına inerse kazanılır.

const M := {
	"wine": {"spk": "SPK_WINE", "start": 40, "low": 34.0, "fair": 12.0, "sweet": 22.0, "floor": [0.45, 0.55], "scene": "galata", "goods": "barrel"},
	"double": {"spk": "SPK_DOUBLE", "start": 60, "low": 20.0, "fair": 8.0, "sweet": 22.0, "floor": [0.45, 0.55], "scene": "galata", "goods": "keg"},
	"urban": {"spk": "SPK_URBAN", "start": 90, "low": 45.0, "fair": 14.0, "sweet": 38.0, "floor": [0.42, 0.52], "scene": "foundry", "goods": "ball"},
	"niko": {"spk": "SPK_NIKO", "start": 50, "low": 16.0, "fair": 6.0, "sweet": 16.0, "floor": [0.5, 0.58], "scene": "harbor", "goods": "boat"},
}
const CARD_KEYS := ["MG_HAG_C_LOW", "MG_HAG_C_FAIR", "MG_HAG_C_ACCEPT", "MG_HAG_C_SWEET"]

var merchant := "wine"
var _cfg: Dictionary
var _start := 40
var _ask := 40.0
var _floor := 20.0
var _patience := 100.0
var _sweet := 2
var _round := 0
var _over := false
var _deal := false
var _log: Array = []       # [[teklif, satıcının yeni fiyatı]]
var _cards: Array[Rect2] = []
var _hover := -1
var _sign_bump := 0.0
var _result_key := ""


func _init() -> void:
	host_speaker = "SPK_WINE"


func setup() -> void:
	_cfg = M.get(merchant, M["wine"])
	host_speaker = _cfg["spk"]
	_start = _cfg["start"]
	_ask = float(_start)
	_floor = _start * randf_range(_cfg["floor"][0], _cfg["floor"][1])
	heading(tr("MG_HAG_TITLE_" + merchant.to_upper()))
	say("MG_HAG_%s_OPEN" % merchant.to_upper())
	keys([["1", "MG_HAG_C_LOW"], ["2", "MG_HAG_C_FAIR"], ["3", "MG_HAG_C_ACCEPT"], ["4", "MG_HAG_C_SWEET"]])
	area.draw.connect(_draw_area)
	area.gui_input.connect(_on_input)
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	records([["MG_REC_HAGGLE_WINS", int(GameState.stats.get("haggle_wins", 0))], ["MG_REC_START", tr("MG_HAG_AKCE") % _start]])
	_refresh()


func _ready() -> void:
	# Ev sahibi (portre) kurulmadan önce bilinmeli
	host_speaker = M.get(merchant, M["wine"])["spk"]
	if merchant == "double":
		host_pic = "portraits/tailor.svg"
	super._ready()


func _refresh() -> void:
	status(tr("MG_HAG_ROUND") % [mini(_round + 1, 7), int(_start * 0.6)])


func _on_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion:
		_hover = -1
		for i in _cards.size():
			if _cards[i].has_point(e.position):
				_hover = i
	elif e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		if _over:
			_finish_now()
			return
		for i in _cards.size():
			if _cards[i].has_point(e.position):
				_act(i)
				return


func _process(delta: float) -> void:
	_sign_bump = maxf(0.0, _sign_bump - delta * 3.0)
	area.queue_redraw()
	if _over:
		if Input.is_action_just_pressed("advance") or Input.is_action_just_pressed("choice_1"):
			_finish_now()
		return
	for i in 4:
		if Input.is_action_just_pressed("choice_%d" % (i + 1)):
			_act(i)


func _finish_now() -> void:
	var price := int(round(_ask))
	var won := price <= int(_start * 0.6)
	finish(clampi(int(round((1.0 - price / float(_start)) * 100.0)), 0, 100) if _deal else 0, won and _deal)


func _act(i: int) -> void:
	_round += 1
	var key := ""
	var before := _ask
	match i:
		0:
			var offer := _ask * 0.6
			_patience -= float(_cfg["low"])
			if offer >= _floor:
				_ask = lerpf(_ask, offer, 0.5)
			key = "LOW"
			_log.append([int(round(offer)), int(round(_ask))])
		1:
			var offer := _ask * 0.85
			_patience -= float(_cfg["fair"])
			_ask = maxf(_floor, lerpf(_ask, offer, 0.7))
			key = "FAIR"
			_log.append([int(round(offer)), int(round(_ask))])
		2:
			_deal = true
			_end("WIN" if _ask <= _start * 0.6 else "DEAL")
			return
		3:
			if _sweet <= 0:
				key = "NOSWEET"
				_patience -= 6.0
			else:
				_sweet -= 1
				_patience = minf(100.0, _patience + float(_cfg["sweet"]))
				key = "SWEET"
	if _patience <= 0.0:
		_patience = 0.0
		_deal = false
		_end("LOSE")
		return
	if _round >= 7:
		_deal = true
		_end("WIN" if _ask <= _start * 0.6 else "DEAL")
		return
	if int(round(_ask)) != int(round(before)):
		_sign_bump = 1.0
	say("MG_HAG_%s_%s" % [merchant.to_upper(), key])
	Audio.sfx("ui_confirm", -12.0)
	_refresh()


func _end(key: String) -> void:
	_over = true
	_result_key = key
	_refresh()
	say("MG_HAG_%s_%s" % [merchant.to_upper(), key])
	if _deal:
		big(tr("MG_HAG_BIG_DEAL") % int(round(_ask)), C_GOLD if key == "WIN" else C_CREAM)
	else:
		big("MG_HAG_BIG_NONE", C_RED)
	keys([["E", "MG_CONTINUE"]])
	Audio.sfx("stamp" if key == "WIN" else "ui_confirm", -6.0)


# ---------------------------------------------------------------- çizim

func _draw_area() -> void:
	var s := area.size
	var font := ThemeDB.fallback_font
	var tf := title_font if title_font else font
	_draw_scene(s)
	# Tezgâh: tente, direkler, tezgâh tahtası, mallar
	var stall := Rect2(s.x * 0.04, 40, s.x * 0.64, s.y * 0.6)
	var aw_h := 46.0
	var stripes := 10
	var sw := stall.size.x / stripes
	var aw_cols := [Color("b3262d"), Color("f2e6c9")] if merchant != "niko" else [Color("2f5fa8"), Color("f2e6c9")]
	if merchant == "urban":
		aw_cols = [Color("5a4a3a"), Color("c98a3a")]
	for i in stripes:
		area.draw_rect(Rect2(stall.position.x + i * sw, stall.position.y, sw, aw_h), aw_cols[i % 2])
		area.draw_circle(Vector2(stall.position.x + i * sw + sw * 0.5, stall.position.y + aw_h), sw * 0.5, aw_cols[i % 2])
	area.draw_rect(Rect2(stall.position.x - 6, stall.position.y - 6, stall.size.x + 12, 8), Color("4a3020"))
	var counter_y := stall.end.y - 30.0
	for px in [stall.position.x + 6, stall.end.x - 14]:
		area.draw_rect(Rect2(px, stall.position.y, 8, counter_y - stall.position.y), Color("5a3a22"))
	_draw_goods(Rect2(stall.position.x + 30, counter_y - 110, stall.size.x - 60, 110))
	area.draw_rect(Rect2(stall.position.x - 10, counter_y, stall.size.x + 20, 22), Color("8a6440"))
	area.draw_rect(Rect2(stall.position.x - 10, counter_y + 22, stall.size.x + 20, 40), Color("6b4428"))
	for k in 6:
		area.draw_line(Vector2(stall.position.x - 10 + k * stall.size.x / 5.0, counter_y + 22), Vector2(stall.position.x - 10 + k * stall.size.x / 5.0, counter_y + 62), Color("4a2e1a"), 2.0)
	# Asılı fiyat tabelası
	var sc := Vector2(stall.position.x + stall.size.x * 0.5, stall.position.y + aw_h + 60)
	var bump := 1.0 + _sign_bump * 0.12
	var sgw := 230.0 * bump
	var sgh := 88.0 * bump
	area.draw_line(sc + Vector2(-70, -60), sc + Vector2(-70, -sgh * 0.5), Color("2a1a10"), 2.0)
	area.draw_line(sc + Vector2(70, -60), sc + Vector2(70, -sgh * 0.5), Color("2a1a10"), 2.0)
	area.draw_rect(Rect2(sc - Vector2(sgw, sgh) * 0.5 + Vector2(4, 5), Vector2(sgw, sgh)), Color(0, 0, 0, 0.35))
	area.draw_rect(Rect2(sc - Vector2(sgw, sgh) * 0.5, Vector2(sgw, sgh)), Color("c8a868"))
	area.draw_rect(Rect2(sc - Vector2(sgw, sgh) * 0.5, Vector2(sgw, sgh)).grow(-5), Color("7a5232"), false, 2.0)
	area.draw_string(font, sc + Vector2(-sgw * 0.5, -14), tr("MG_HAG_ITEM_" + merchant.to_upper()), HORIZONTAL_ALIGNMENT_CENTER, sgw, 14, Color("4a2e1a"))
	area.draw_string(tf, sc + Vector2(-sgw * 0.5, 26), tr("MG_HAG_AKCE") % int(round(_ask)), HORIZONTAL_ALIGNMENT_CENTER, sgw, int(34 * bump), C_INK)
	for k in 3:
		gem(area, sc + Vector2(-sgw * 0.5 + 16, 24 - k * 7), 8.0, Color("e0b85a"))
		gem(area, sc + Vector2(sgw * 0.5 - 16, 24 - k * 7), 8.0, Color("e0b85a"))
	# Sabır fitili: sağa doğru yanan ip, uçta kıvılcım
	var fy := stall.end.y + 58.0
	var fx0 := stall.position.x
	var fx1 := stall.end.x
	area.draw_string(font, Vector2(fx0, fy - 12), tr("MG_HAG_PATIENCE"), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, C_CREAM)
	var fl := fx0 + (fx1 - fx0) * _patience / 100.0
	area.draw_line(Vector2(fx0, fy), Vector2(fx1, fy), Color(0, 0, 0, 0.5), 7.0)
	var pts := PackedVector2Array()
	var x := fx0
	while x < fl:
		pts.append(Vector2(x, fy + sin(x * 0.12) * 2.0))
		x += 6.0
	if pts.size() > 1:
		area.draw_polyline(pts, Color("c8a868"), 5.0)
	if not _over or _deal:
		for k in 6:
			var a := _time * 13.0 + k
			area.draw_line(Vector2(fl, fy), Vector2(fl, fy) + Vector2(cos(a), sin(a)) * (6.0 + fmod(a, 5.0)), Color("ffd24a"), 2.0)
		area.draw_circle(Vector2(fl, fy), 5.0, Color("e8702a"))
	# Teklif kartları
	_draw_cards(Rect2(0, fy + 22, s.x, s.y - fy - 26))
	# Pazarlık defteri (sağ sütun)
	var lg := Rect2(s.x * 0.71, 40, s.x * 0.29 - 6, stall.size.y + 30)
	area.draw_rect(Rect2(lg.position + Vector2(4, 5), lg.size), Color(0, 0, 0, 0.3))
	area.draw_rect(lg, Color("efe2c2"))
	for k in int((lg.size.y - 70.0) / 26.0):
		area.draw_line(Vector2(lg.position.x + 10, lg.position.y + 60 + k * 26), Vector2(lg.end.x - 10, lg.position.y + 60 + k * 26), Color("c8b894"), 1.0)
	area.draw_line(Vector2(lg.position.x + 34, lg.position.y + 40), Vector2(lg.position.x + 34, lg.end.y - 8), Color("d88a7a"), 1.5)
	area.draw_string(tf, lg.position + Vector2(0, 30), tr("MG_HAG_LOG"), HORIZONTAL_ALIGNMENT_CENTER, lg.size.x, 18, C_INK)
	area.draw_string(font, lg.position + Vector2(40, 54), tr("MG_HAG_LOG_START") % _start, HORIZONTAL_ALIGNMENT_LEFT, lg.size.x - 50, 14, Color("5a3a22"))
	for k in _log.size():
		var row: Array = _log[k]
		var ry := lg.position.y + 80 + k * 26
		if ry > lg.end.y - 10:
			break
		area.draw_string(font, Vector2(lg.position.x + 10, ry), str(k + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b8402e"))
		area.draw_string(font, Vector2(lg.position.x + 40, ry), tr("MG_HAG_LOG_ROW") % [row[0], row[1]], HORIZONTAL_ALIGNMENT_LEFT, lg.size.x - 50, 14, C_INK)
	var tgt_y := lg.end.y - 16
	area.draw_string(font, Vector2(lg.position.x, tgt_y), tr("MG_HAG_TARGET") % int(_start * 0.6), HORIZONTAL_ALIGNMENT_CENTER, lg.size.x, 14, Color("2a6a4a"))
	if _over and _result_key != "":
		var stamp_c := Color("2a8a4a") if _result_key == "WIN" else (Color("8a6a2a") if _deal else Color("b3262d"))
		var sp := lg.position + lg.size * Vector2(0.5, 0.62)
		area.draw_set_transform(sp, -0.25, Vector2.ONE)
		area.draw_rect(Rect2(-80, -26, 160, 52), Color(stamp_c, 0.85), false, 4.0)
		area.draw_string(tf, Vector2(-80, 10), tr("MG_HAG_STAMP_" + _result_key), HORIZONTAL_ALIGNMENT_CENTER, 160, 24, stamp_c)
		area.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_cards(r: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var gap := 12.0
	var cw := (r.size.x - gap * 3) / 4.0
	var ch := clampf(r.size.y, 60.0, 110.0)
	_cards.resize(4)
	var amounts := [int(round(_ask * 0.6)), int(round(_ask * 0.85)), int(round(_ask)), _sweet]
	for i in 4:
		var c := Rect2(r.position + Vector2(i * (cw + gap), 0), Vector2(cw, ch))
		_cards[i] = c
		var dis := _over or (i == 3 and _sweet <= 0)
		if _hover == i and not dis:
			c.position.y -= 4.0
		area.draw_rect(Rect2(c.position + Vector2(3, 4), c.size), Color(0, 0, 0, 0.35))
		area.draw_rect(c, Color("3a2a1c") if not dis else Color("2a221c"))
		area.draw_rect(c.grow(-3), C_FRAME if _hover == i and not dis else C_FRAME.darkened(0.45), false, 2.0)
		var b := Rect2(c.position + Vector2(10, 10), Vector2(26, 26))
		area.draw_rect(b, C_FRAME if not dis else C_FRAME.darkened(0.5))
		area.draw_string(font, b.position + Vector2(0, 20), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, 26, 18, C_INK)
		area.draw_string(font, c.position + Vector2(44, 30), tr(CARD_KEYS[i]), HORIZONTAL_ALIGNMENT_LEFT, cw - 50, 16, C_CREAM if not dis else C_DIM)
		var sub := tr("MG_HAG_AKCE") % amounts[i] if i < 3 else tr("MG_HAG_C_SWEET_N") % _sweet
		area.draw_string(font, c.position + Vector2(10, ch - 16), sub, HORIZONTAL_ALIGNMENT_LEFT, cw - 20, 22, (C_GOLD if i < 3 else C_ACCENT) if not dis else C_DIM)


func _draw_scene(s: Vector2) -> void:
	match _cfg["scene"]:
		"foundry":
			vgrad(area, Rect2(Vector2.ZERO, s), Color("3a2a22"), Color("1a120c"))
			for k in 5:
				var ph := fmod(_time * 0.12 + k * 0.21, 1.0)
				area.draw_circle(Vector2(s.x * (0.1 + k * 0.2) + sin(_time + k) * 20, s.y * (0.7 - ph * 0.7)), 40.0 + ph * 60.0, Color(0.3, 0.28, 0.26, 0.25 * (1.0 - ph)))
			# Döküm ocağı: tuğla fırın, kızgın ağız, arkada dev top namlusu
			var fz := Vector2(s.x * 0.82, s.y * 0.62)
			area.draw_circle(fz, 160.0, Color(1.0, 0.45, 0.1, 0.1 + sin(_time * 3.0) * 0.03))
			area.draw_rect(Rect2(fz.x - 90, fz.y - 120, 180, 260), Color("5a2a1a"))
			for by in 10:
				for bx in 4:
					area.draw_rect(Rect2(fz.x - 90 + bx * 45 + (by % 2) * 22, fz.y - 120 + by * 26, 43, 24), Color("6a3422").darkened(0.1 * ((bx + by) % 3)))
			ellipse(area, fz + Vector2(0, 30), 50, 40, Color("ff8a2a"))
			ellipse(area, fz + Vector2(0, 36), 34, 24, Color("ffd24a").lerp(Color("ff8a2a"), 0.5 + sin(_time * 7.0) * 0.3))
			area.draw_set_transform(Vector2(s.x * 0.12, s.y * 0.3), -0.18, Vector2.ONE)
			area.draw_rect(Rect2(0, -40, s.x * 0.5, 80), Color("8a6a3a"))
			area.draw_rect(Rect2(s.x * 0.5 - 10, -48, 20, 96), Color("7a5a2a"))
			area.draw_rect(Rect2(40, -46, 16, 92), Color("7a5a2a"))
			area.draw_rect(Rect2(0, -40, s.x * 0.5, 14), Color(1, 1, 1, 0.12))
			area.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			for k in 8:
				area.draw_colored_polygon(PackedVector2Array([Vector2(k * s.x / 7.0 - 60, s.y), Vector2(k * s.x / 7.0, s.y * 0.72 + (k % 3) * 18), Vector2(k * s.x / 7.0 + 60, s.y)]), Color("241810"))
		"harbor":
			vgrad(area, Rect2(0, 0, s.x, s.y * 0.55), Color("7ab4dc"), Color("d8e8ee"))
			vgrad(area, Rect2(0, s.y * 0.55, s.x, s.y * 0.45), Color("2a6a8a"), Color("163a4e"), 12)
			for k in 14:
				var wx := fmod(k * 97.0 + _time * 18.0, s.x + 60.0) - 30.0
				area.draw_line(Vector2(wx, s.y * 0.6 + (k % 5) * 30), Vector2(wx + 26, s.y * 0.6 + (k % 5) * 30), Color(1, 1, 1, 0.35), 2.0)
			for k in 6:
				var hx := k * s.x / 5.0
				area.draw_rect(Rect2(hx - 30, s.y * 0.35 - (k % 3) * 20, 70, s.y * 0.2 + (k % 3) * 20), Color("d8c8a8").darkened(0.05 * (k % 3)))
				area.draw_colored_polygon(PackedVector2Array([Vector2(hx - 36, s.y * 0.35 - (k % 3) * 20), Vector2(hx + 5, s.y * 0.26 - (k % 3) * 20), Vector2(hx + 46, s.y * 0.35 - (k % 3) * 20)]), Color("b85a3a"))
			ellipse(area, Vector2(s.x * 0.86, s.y * 0.28), 30, 30, Color("d8b040"))
			area.draw_rect(Rect2(s.x * 0.86 - 22, s.y * 0.28, 44, s.y * 0.27), Color("d8c8a8"))
		_:
			vgrad(area, Rect2(0, 0, s.x, s.y * 0.6), Color("8ec0e0"), Color("f0e4c8"))
			area.draw_rect(Rect2(0, s.y * 0.6, s.x, s.y * 0.4), Color("8a7a62"))
			for k in 30:
				area.draw_rect(Rect2((k * 53) % int(s.x), s.y * 0.62 + (k * 37) % int(s.y * 0.36), 26, 12), Color(0, 0, 0, 0.06))
			# Galata evleri ve kule
			area.draw_rect(Rect2(s.x * 0.58, s.y * 0.05, 64, s.y * 0.55), Color("c8b894"))
			area.draw_colored_polygon(PackedVector2Array([Vector2(s.x * 0.58 - 6, s.y * 0.05), Vector2(s.x * 0.58 + 32, -s.y * 0.06), Vector2(s.x * 0.58 + 70, s.y * 0.05)]), Color("7a4a3a"))
			for k in 7:
				var hx := k * s.x / 6.0 - 20.0
				var hh := s.y * (0.28 + (k % 3) * 0.06)
				var hc: Color = [Color("e8d8b8"), Color("d8a878"), Color("c8c0a8")][k % 3]
				area.draw_rect(Rect2(hx, s.y * 0.6 - hh, s.x / 6.0 - 8, hh), hc)
				area.draw_colored_polygon(PackedVector2Array([Vector2(hx - 6, s.y * 0.6 - hh), Vector2(hx + s.x / 12.0, s.y * 0.6 - hh - 26), Vector2(hx + s.x / 6.0, s.y * 0.6 - hh)]), Color("b8503a"))
				for wy in 2:
					for wx in 2:
						area.draw_rect(Rect2(hx + 14 + wx * 40, s.y * 0.6 - hh + 20 + wy * 44, 16, 22), Color("4a5a6a"))


func _draw_goods(r: Rect2) -> void:
	match _cfg["goods"]:
		"barrel":
			for k in 4:
				var c := Vector2(r.position.x + r.size.x * (0.14 + k * 0.24), r.end.y - 44)
				ellipse(area, c, 38, 46, Color("8a5a2a"))
				area.draw_line(c + Vector2(-36, -20), c + Vector2(36, -20), Color("3a3a3a"), 4.0)
				area.draw_line(c + Vector2(-36, 20), c + Vector2(36, 20), Color("3a3a3a"), 4.0)
				ellipse(area, c + Vector2(-12, -8), 8, 24, Color(1, 1, 1, 0.08))
			for k in 3:
				var bc := Vector2(r.position.x + r.size.x * (0.26 + k * 0.24), r.end.y - 100)
				area.draw_rect(Rect2(bc.x - 6, bc.y - 34, 12, 34), Color("3a5a2a"))
				area.draw_rect(Rect2(bc.x - 3, bc.y - 46, 6, 14), Color("3a5a2a"))
		"keg":
			for k in 5:
				var c := Vector2(r.position.x + r.size.x * (0.1 + k * 0.2), r.end.y - 36)
				area.draw_rect(Rect2(c.x - 30, c.y - 36, 60, 72), Color("2a2a2a"))
				area.draw_rect(Rect2(c.x - 30, c.y - 16, 60, 6), Color("6a5a3a"))
				area.draw_rect(Rect2(c.x - 30, c.y + 12, 60, 6), Color("6a5a3a"))
				area.draw_string(ThemeDB.fallback_font, c + Vector2(-30, 4), ["☪", "☩"][k % 2], HORIZONTAL_ALIGNMENT_CENTER, 60, 18, Color("c8a868"))
		"ball":
			var n := 0
			for row in 4:
				for k in 4 - row:
					var c := Vector2(r.position.x + r.size.x * 0.5 + (k - (3 - row) * 0.5) * 50, r.end.y - 22 - row * 40)
					gem(area, c, 22.0, Color("6a6a70"))
					n += 1
			gem(area, Vector2(r.position.x + 40, r.end.y - 14), 12.0, Color("b8863a"))
			gem(area, Vector2(r.end.x - 40, r.end.y - 14), 12.0, Color("b8863a"))
		"boat":
			var c := Vector2(r.position.x + r.size.x * 0.5, r.end.y - 30)
			area.draw_colored_polygon(PackedVector2Array([c + Vector2(-150, -30), c + Vector2(150, -30), c + Vector2(110, 26), c + Vector2(-110, 26)]), Color("8a5a2a"))
			area.draw_line(c + Vector2(-150, -30), c + Vector2(150, -30), Color("5a3a1a"), 5.0)
			area.draw_line(c + Vector2(-130, -4), c + Vector2(130, -4), Color("a8783a"), 3.0)
			area.draw_line(c + Vector2(-60, -60), c + Vector2(40, 20), Color("c8a868"), 5.0)
			ellipse(area, c + Vector2(-66, -66), 10, 20, Color("c8a868"))
			area.draw_string(ThemeDB.fallback_font, c + Vector2(-60, 12), "ΝΙΚΟΣ ΙΙ", HORIZONTAL_ALIGNMENT_CENTER, 120, 14, Color("f2e6c9"))
