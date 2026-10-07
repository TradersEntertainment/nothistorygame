class_name Journey
extends Control
## Final yolculuğu (Detroit: Become Human'ın akış şeması gibi): oyun bitince bütün oyunun şeması açılır, kamera oyuncunun
## yolunu baştan finale izler. Geçilen bölümler kapak resmi ve mavi başlıkla, seçilen sonuçlar mavi kutuyla sırayla yanar;
## gidilmeyen dallar kilitli ("[…]"), önceki oyunlarda görülenler soluk yazılıdır. Sonunda final kartı altın renkle
## parlar, kamera geri çekilir; oyuncu şemayı sürükleyip gezebilir. Boşluk/E/tık: önce atla (sona gel), sonra devam.
## Veri: assets/data/journey.json (tools/journey_data.py; sitenin hikâye haritasıyla aynı kaynak).
##   var j := Journey.new(); j.final_id = "two_neighbours"; hud.add_child(j); await j.finished

signal finished

const DATA := "res://assets/data/journey.json"
const THUMBS := "res://assets/art/journey/%s.jpg"
const COL_W := 290.0          # sütun aralığı (haritanın bir satırı = bir sütun)
const ACT_W := 120.0          # perde ayracı
const LANE_H := 340.0         # şerit aralığı
const TOP := 150.0
const LEFT := 80.0
const CARD := Vector2(210, 118)
const SKEW := 26.0
const BAR_H := 28.0
const OUT_H := 24.0
const OUT_GAP := 4.0
const STEP_T := 0.95          # yoldaki her bölüm (sn)
const ZOOM_WALK := 0.92
const ZOOM_END := 0.42

const C_BG := Color("e7e9ec")
const C_TRI := Color(0.0, 0.0, 0.0, 0.035)
const C_BLUE := Color("1f6fd6")
const C_BLUE_D := Color("164f9a")
const C_GREY := Color("cfd2d6")
const C_GREY_D := Color("9a9fa6")
const C_TEXT := Color("2b2f36")
const C_LOCK := Color("e8552b")
const C_GOLD := Color("f2b632")
const C_LINE := Color("b4b8be")

var final_id := ""
## Testte ve "yeniden izle"de verilebilir; boşsa GameState'ten
var outcomes: Dictionary = {}
var side := ""
var fast := false             # otomatik test: animasyon anında biter

var _data: Dictionary = {}
var _loc := "tr"
var _cards: Dictionary = {}   # id -> {rect, bar, lane, col, state, out, outs: [{id, text, rect, state}], reveal, out_reveal}
var _edges: Array = []        # {pts, taken, skip, reveal}
var _acts: Array = []         # {x, kicker, title}
var _path: Array[String] = []
var _thumbs: Dictionary = {}
var _font: Font
var _font_title: Font
var _t := 0.0
var _step := -1
var _done := false            # yol açıldı
var _cam := Vector2.ZERO
var _zoom := ZOOM_WALK
var _cam_to := Vector2.ZERO
var _zoom_to := ZOOM_WALK
var _drag := false
var _caption := ""
var _act_caption := ""
var _act_t := 0.0
var _world_size := Vector2.ZERO
var _decisions := 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	_font = ThemeDB.fallback_font
	_font_title = load(Hud.FONT_TITLE)
	_loc = "tr" if TranslationServer.get_locale().begins_with("tr") else "en"
	if outcomes.is_empty():
		outcomes = GameState.chapter_outcomes.duplicate()
	if side == "":
		side = Siege.side()
	var f := FileAccess.open(DATA, FileAccess.READ)
	if f:
		var parsed: Variant = JSON.parse_string(f.get_as_text())
		if parsed is Dictionary:
			_data = parsed
	if _data.is_empty():
		push_warning("Journey: veri yok")
		finished.emit.call_deferred()
		return
	_layout()
	_mark_path()
	_route_edges()
	if not _path.is_empty():
		_cam = _center_of(_path[0])
		_cam_to = _cam
	if GameState.autotest:
		_report()
	if fast:
		_finish_reveal()
	grab_focus.call_deferred()


func _text(v: Variant) -> String:
	if v is Dictionary:
		return String((v as Dictionary).get(_loc, (v as Dictionary).get("tr", "")))
	return str(v)


func _lane_y(l: float) -> float:
	return TOP + l * LANE_H


# ---------------------------------------------------------------- yerleşim

func _layout() -> void:
	var x := LEFT
	var col := 0
	var chapters: Dictionary = _data["chapters"]
	for r: Dictionary in _data["rows"]:
		if r.has("act"):
			var a: Dictionary = (_data["acts"] as Dictionary).get(r["act"], {})
			_acts.append({"x": x + ACT_W * 0.35, "kicker": _text(a.get("kicker", "")), "title": _text(a.get("title", ""))})
			x += ACT_W
			continue
		for cell: Array in r["cells"]:
			var cid: String = cell[0]
			var ln: Variant = cell[1]
			var lane := (float(ln[0]) + float(ln[-1])) * 0.5 if ln is Array else float(ln)
			var c: Dictionary = chapters.get(cid, {})
			var top := Vector2(x, _lane_y(lane))
			var card := {"id": cid, "rect": Rect2(top, CARD), "bar": Rect2(top + Vector2(0, CARD.y + 4.0), Vector2(CARD.x - 10.0, BAR_H)),
				"lane": lane, "col": col, "state": "locked", "out": "", "outs": [], "reveal": 0.0, "out_reveal": 0.0, "data": c}
			var oy := top.y + CARD.y + 4.0 + BAR_H + 8.0
			for o: Array in c.get("outs", []):
				var label: Variant = o[2] if o.size() > 2 and side == "O" else o[1]
				(card["outs"] as Array).append({"id": o[0], "text": GameState.fill_outcomes(_text(label)),
					"rect": Rect2(Vector2(x + 16.0, oy), Vector2(CARD.x - 30.0, OUT_H)), "state": "locked"})
				oy += OUT_H + OUT_GAP
			_cards[cid] = card
		x += COL_W
		col += 1
	_world_size = Vector2(x + LEFT, _lane_y(float(_data.get("lanes", 7))) + 40.0)


## Sonucun kartı: aynı kimlik iki tarafta da olabilir (26.1 hem Bizans'ın hem Osmanlı'nın Şafak'ı): oyuncunun tarafındaki
func _card_of(o: String) -> String:
	var best := ""
	for cid in _cards:
		for x: Dictionary in _cards[cid]["outs"]:
			if x["id"] != o:
				continue
			var sd := String((_cards[cid]["data"] as Dictionary).get("side", ""))
			if sd == side or sd == "both" or sd == "":
				return cid
			if best == "":
				best = cid
	return best


## Bu oyunun yolu: sonuçlardan bölüm kartları (sonuç kimliği → kart), kuşatmanın tarafı, Büro, dönüş ve final
func _mark_path() -> void:
	var taken := {}
	for ch in outcomes:
		var o := str(outcomes[ch])
		var cid := _card_of(o)
		if cid == "":
			if int(ch) != 15 and GameState.autotest:
				print("JOURNEY_MISS ch=%s o=%s" % [ch, o])
			continue
		taken[cid] = o
	var siege := false
	for cid in taken:
		var sd := String((_cards.get(cid, {"data": {}})["data"] as Dictionary).get("side", ""))
		if sd in ["B", "O", "both"]:
			siege = true
	if not taken.is_empty():
		taken["ch0"] = taken.get("ch0", "")
	if siege:
		taken["bureau"] = ""
		taken["ret"] = ""
	var late := final_id in ["another_year", "late_by_49_years"]
	if _cards.has("ch15") and final_id != "":
		taken["ch15y" if late else "ch15"] = ""
	if final_id != "" and _cards.has("fin"):
		taken["fin"] = ""
	_path.clear()
	for cid in taken:
		if _cards.has(cid):
			_path.append(cid)
	_path.sort_custom(func(a, b): return int(_cards[a]["col"]) < int(_cards[b]["col"]))
	for cid in _cards:
		var card: Dictionary = _cards[cid]
		var seen_any := false
		for o: Dictionary in card["outs"]:
			if GameState.seen_outcomes.has(o["id"]):
				o["state"] = "seen"
				seen_any = true
		if taken.has(cid):
			card["out"] = taken[cid]
			for o: Dictionary in card["outs"]:
				if o["id"] == card["out"]:
					_decisions += 1
		card["state"] = "seen" if seen_any else "locked"
		card["taken"] = taken.has(cid)


func _center_of(cid: String) -> Vector2:
	var c: Dictionary = _cards[cid]
	var r: Rect2 = c["rect"]
	return r.position + Vector2(CARD.x * 0.5 + 30.0, CARD.y * 0.9)


func _out_rect(cid: String, oid: String) -> Rect2:
	for o: Dictionary in _cards[cid]["outs"]:
		if o["id"] == oid:
			return o["rect"]
	return Rect2()


## Bölümler arası çizgiler: kaynağın sağından (seçilen sonuçtan) şeride, şerit boyunca, hedefin soluna
func _route_edges() -> void:
	var pairs := {}
	for i in range(1, _path.size()):
		pairs[_path[i - 1] + ">" + _path[i]] = i
	var drawn := {}
	for e: Dictionary in _data["edges"]:
		var a: String = e["from"]
		var b: String = e["to"]
		if not (_cards.has(a) and _cards.has(b)):
			continue
		var key := a + ">" + b
		var taken := pairs.has(key)
		drawn[key] = true
		_edges.append({"pts": _edge_points(a, b, float(e["lr"]), taken), "taken": taken, "skip": e.get("skip", false),
			"step": int(pairs.get(key, -1)), "reveal": 0.0})
	# Haritada doğrudan bağlantısı olmayan ardışık iki durak (atlanan bölümler): kesik düz çizgi
	for key: String in pairs:
		if drawn.has(key):
			continue
		var ab := key.split(">")
		_edges.append({"pts": _edge_points(ab[0], ab[1], float(_cards[ab[1]]["lane"]), true), "taken": true, "skip": true,
			"step": int(pairs[key]), "reveal": 0.0})


func _edge_points(a: String, b: String, run_lane: float, taken: bool) -> PackedVector2Array:
	var ca: Dictionary = _cards[a]
	var cb: Dictionary = _cards[b]
	var bar_a: Rect2 = ca["bar"]
	var p0 := Vector2(bar_a.end.x, bar_a.get_center().y)
	if taken and String(ca["out"]) != "":
		var orc := _out_rect(a, ca["out"])
		if orc.size != Vector2.ZERO:
			p0 = Vector2(orc.end.x, orc.get_center().y)
	var bar_b: Rect2 = cb["bar"]
	var p3 := Vector2(bar_b.position.x, bar_b.get_center().y)
	var y_run := _lane_y(run_lane) + CARD.y + 4.0 + BAR_H * 0.5
	var x1 := maxf(bar_a.end.x + 18.0, p0.x + 14.0)
	var x2 := p3.x - 18.0
	var pts := PackedVector2Array([p0, Vector2(x1, p0.y)])
	if absf(y_run - p0.y) > 0.5:
		pts.append(Vector2(x1, y_run))
	if absf(y_run - p3.y) > 0.5:
		pts.append(Vector2(x2, y_run))
		pts.append(Vector2(x2, p3.y))
	pts.append(p3)
	return pts


# ---------------------------------------------------------------- akış

func _process(delta: float) -> void:
	if _data.is_empty():
		return
	_t += delta
	_act_t = maxf(0.0, _act_t - delta)
	if not _done:
		var want := int(floor((_t - 0.8) / STEP_T))
		while _step < mini(want, _path.size() - 1):
			_step += 1
			_light(_step)
		if _step >= _path.size() - 1 and _t - 0.8 > _path.size() * STEP_T + 0.6:
			_finish_reveal()
	# Açılma: kart, sonra seçilen sonucu, çizgi kartla birlikte
	for i in range(0, _step + 1):
		var c: Dictionary = _cards[_path[i]]
		c["reveal"] = minf(1.0, float(c["reveal"]) + delta * 3.2)
		if float(c["reveal"]) >= 0.6:
			c["out_reveal"] = minf(1.0, float(c["out_reveal"]) + delta * 3.0)
	for e: Dictionary in _edges:
		if e["taken"] and int(e["step"]) >= 0 and int(e["step"]) <= _step:
			e["reveal"] = minf(1.0, float(e["reveal"]) + delta * 3.6)
	# Kamera durağa yetişir: şeritler arası uzun sıçramada da (11'e geçerken kart kadrajın kenarında kalıyordu)
	var far := clampf(_cam.distance_to(_cam_to) / (COL_W * 2.0), 0.0, 1.0)
	var k := 1.0 - exp(-delta * lerpf(3.2, 6.0, far))
	_cam = _cam.lerp(_cam_to, k)
	_zoom = lerpf(_zoom, _zoom_to, 1.0 - exp(-delta * 1.8))
	queue_redraw()


func _light(i: int) -> void:
	var cid := _path[i]
	var c: Dictionary = _cards[cid]
	_cam_to = _center_of(cid)
	_caption = _card_caption(cid)
	if not fast:
		Audio.sfx("ui_select", -10.0, 0.9 + 0.02 * float(i % 8))
		if String(c["out"]) != "":
			get_tree().create_timer(0.3).timeout.connect(func():
				if is_inside_tree():
					Audio.sfx("stamp", -16.0, 1.4))
	# Perde değişti: üstte perde adı
	var x: float = (c["rect"] as Rect2).position.x
	for a: Dictionary in _acts:
		if float(a["x"]) < x and float(a["x"]) > x - COL_W - ACT_W:
			_act_caption = "%s · %s" % [a["kicker"], a["title"]]
			_act_t = 2.6


func _card_caption(cid: String) -> String:
	var c: Dictionary = _cards[cid]
	var d: Dictionary = c["data"]
	var num := _num(d)
	var t := _text(d.get("title", ""))
	if cid == "fin":
		return tr("UI_JOURNEY_FINAL") + " · " + tr("UI_CH15_FINAL_" + final_id.to_upper())
	return ("%s · %s" % [tr("UI_RV_CHAPTER") % num, t]) if num != "" else t


func _num(d: Dictionary) -> String:
	var n: Dictionary = d.get("num", {})
	if n.has("all"):
		return String(n["all"])
	return String(n.get(side, n.get("B", n.get("O", ""))))


func _finish_reveal() -> void:
	_done = true
	_step = _path.size() - 1
	for cid in _path:
		_cards[cid]["reveal"] = 1.0
		_cards[cid]["out_reveal"] = 1.0
	for e: Dictionary in _edges:
		if e["taken"]:
			e["reveal"] = 1.0
	if not _path.is_empty():
		_cam_to = _center_of(_path[-1]) - Vector2(COL_W * 2.2, 0)
		_zoom_to = ZOOM_END
		_caption = _card_caption(_path[-1])
	if not fast:
		Audio.sfx("ui_confirm", -6.0, 0.8)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_zoom_to = clampf(_zoom_to * 1.12, 0.12, 1.4)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_zoom_to = clampf(_zoom_to / 1.12, 0.12, 1.4)
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			_drag = mb.pressed and _done
			if mb.pressed and not _done:
				_finish_reveal()
	elif event is InputEventMouseMotion and _drag:
		_cam_to -= (event as InputEventMouseMotion).relative / maxf(_zoom, 0.05)
		_cam = _cam_to
	if event is InputEventMouse:
		accept_event()           # tuşlar _unhandled_input'a geçsin (Boşluk/E: atla, devam)


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("jump") or event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") \
			or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if not _done:
			_finish_reveal()
		elif _t > 0.5:
			finished.emit()
	elif _done and event is InputEventKey and event.pressed:
		var pan := Vector2.ZERO
		match (event as InputEventKey).keycode:
			KEY_LEFT, KEY_A: pan.x = -1.0
			KEY_RIGHT, KEY_D: pan.x = 1.0
			KEY_UP, KEY_W: pan.y = -1.0
			KEY_DOWN, KEY_S: pan.y = 1.0
		if pan != Vector2.ZERO:
			_cam_to += pan * 260.0 / maxf(_zoom, 0.05)
			get_viewport().set_input_as_handled()


# ---------------------------------------------------------------- çizim

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), C_BG)
	# Detroit'in büyük soluk üçgenleri
	var w := size.x
	var h := size.y
	for i in 7:
		var cx := fposmod(float(i) * 0.31 * w - _cam.x * _zoom * 0.15, w * 1.6) - w * 0.3
		var up := i % 2 == 0
		var tri := PackedVector2Array([Vector2(cx, h if up else 0.0), Vector2(cx + w * 0.22, 0.0 if up else h), Vector2(cx + w * 0.44, h if up else 0.0)])
		draw_colored_polygon(tri, C_TRI)
	var origin := size * 0.5 - _cam * _zoom
	draw_set_transform(origin, 0.0, Vector2(_zoom, _zoom))
	var view := Rect2(-origin / _zoom, size / _zoom).grow(60.0)
	# Perde ayraçları
	for a: Dictionary in _acts:
		var ax: float = a["x"]
		if ax < view.position.x - 300.0 or ax > view.end.x + 300.0:
			continue
		draw_line(Vector2(ax, TOP - 90.0), Vector2(ax, _world_size.y - 40.0), Color(0, 0, 0, 0.08), 2.0)
		draw_string(_font_title, Vector2(ax + 12.0, TOP - 62.0), String(a["kicker"]).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, C_GREY_D)
		draw_string(_font, Vector2(ax + 12.0, TOP - 36.0), String(a["title"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, C_GREY_D)
	# Çizgiler: önce gidilmeyenler (alta), sonra yol
	for e: Dictionary in _edges:
		if not e["taken"]:
			_draw_poly(e["pts"], C_LINE, 2.0, 1.0, e["skip"])
	for e: Dictionary in _edges:
		if e["taken"]:
			_draw_poly(e["pts"], C_LINE, 2.0, 1.0, e["skip"])
			if float(e["reveal"]) > 0.0:
				_draw_poly(e["pts"], C_BLUE, 4.0, float(e["reveal"]), false)
	# Kartlar
	for cid in _cards:
		var c: Dictionary = _cards[cid]
		var r: Rect2 = c["rect"]
		if not view.intersects(Rect2(r.position, Vector2(CARD.x, CARD.y + 300.0))):
			continue
		_draw_card(cid, c)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_overlay()


func _draw_poly(pts: PackedVector2Array, col: Color, width: float, frac: float, dashed: bool) -> void:
	var total := 0.0
	for i in range(1, pts.size()):
		total += pts[i - 1].distance_to(pts[i])
	var left := total * clampf(frac, 0.0, 1.0)
	for i in range(1, pts.size()):
		var a := pts[i - 1]
		var b := pts[i]
		var seg := a.distance_to(b)
		if seg <= 0.01:
			continue
		var end := b if left >= seg else a.lerp(b, left / seg)
		if dashed:
			draw_dashed_line(a, end, col, width, 9.0)
		else:
			draw_line(a, end, col, width, true)
		left -= seg
		if left <= 0.0:
			break
	if frac >= 1.0 and pts.size() >= 2:
		# Hedefin önünde küçük ok başı
		var tip := pts[-1]
		var dir := (pts[-1] - pts[-2]).normalized()
		var n := Vector2(-dir.y, dir.x)
		draw_colored_polygon(PackedVector2Array([tip, tip - dir * 9.0 + n * 5.0, tip - dir * 9.0 - n * 5.0]), col)


func _thumb(cov: String) -> Texture2D:
	if not _thumbs.has(cov):
		var p := THUMBS % cov
		_thumbs[cov] = load(p) if ResourceLoader.exists(p) else null
	return _thumbs[cov]


func _draw_card(cid: String, c: Dictionary) -> void:
	var r: Rect2 = c["rect"]
	var d: Dictionary = c["data"]
	var lit: float = c["reveal"]
	var taken: bool = c["taken"] and lit > 0.0
	var known: bool = taken or c["state"] == "seen"
	var pts := PackedVector2Array([r.position + Vector2(SKEW, 0), r.position + Vector2(CARD.x, 0),
		r.position + Vector2(CARD.x - SKEW, CARD.y), r.position + Vector2(0, CARD.y)])
	var uvs := PackedVector2Array([Vector2(SKEW / CARD.x, 0), Vector2(1, 0), Vector2(1.0 - SKEW / CARD.x, 1), Vector2(0, 1)])
	var cov := String(d.get("cover", ""))
	var tex := _thumb(cov) if cov != "" else null
	if cid == "fin":
		_draw_final(c)
		return
	if tex and known:
		var tint := Color(1, 1, 1, 1).lerp(Color(0.62, 0.64, 0.68, 0.55), 1.0 - lit) if taken else Color(0.62, 0.64, 0.68, 0.55)
		draw_colored_polygon(pts, Color(0.75, 0.77, 0.8))
		draw_polygon(pts, PackedColorArray([tint, tint, tint, tint]), uvs, tex)
	elif known:
		# Kapaksız ara durak (Büro, dosyanın kapanışı): koyu kart, ortada adı
		draw_colored_polygon(pts, Color("3a4458").lerp(Color("24406e"), lit))
		var nm := _upper(_text(d.get("title", "")))
		draw_string(_font_title, r.position + Vector2(SKEW * 0.5, CARD.y * 0.5 + 7.0), nm, HORIZONTAL_ALIGNMENT_CENTER,
			CARD.x - SKEW, 17, Color(1, 1, 1, 0.55 + 0.45 * lit))
	else:
		draw_colored_polygon(pts, C_GREY)
		_lock(r.position + Vector2(CARD.x * 0.5 - 8.0, CARD.y * 0.5 - 12.0), 1.4)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(1, 1, 1, 0.7) if taken else Color(0, 0, 0, 0.12), 2.0)
	# Başlık çubuğu: bölüm numarası ve adı
	var bar: Rect2 = c["bar"]
	var bcol := C_GREY.lerp(C_BLUE, lit) if c["taken"] else (Color("dfe1e4") if known else C_GREY)
	draw_rect(bar, bcol)
	if taken:
		draw_rect(Rect2(bar.position, Vector2(5.0, bar.size.y)), C_BLUE_D)
	var num := _num(d)
	var title := _text(d.get("title", ""))
	var label := ("%s · %s" % [num, title]) if num != "" else title
	if not known:
		label = (num + " · [...]") if num != "" else "[...]"
	label = _upper(label)
	var fs := 15
	while fs > 10 and _font_title.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > bar.size.x - 16.0:
		fs -= 1
	draw_string(_font_title, bar.position + Vector2(10.0, bar.size.y * 0.5 + fs * 0.36), label, HORIZONTAL_ALIGNMENT_LEFT,
		bar.size.x - 14.0, fs, Color.WHITE if taken else (C_TEXT if known else C_GREY_D))
	# Sonuç düğümleri (ağaç çizgisiyle)
	var outs: Array = c["outs"]
	if outs.is_empty():
		return
	var spine_x := bar.position.x + 8.0
	var last: Rect2 = outs[-1]["rect"]
	draw_line(Vector2(spine_x, bar.end.y), Vector2(spine_x, last.get_center().y), C_LINE, 1.5)
	for o: Dictionary in outs:
		var orc: Rect2 = o["rect"]
		draw_line(Vector2(spine_x, orc.get_center().y), Vector2(orc.position.x, orc.get_center().y), C_LINE, 1.5)
		var chosen: bool = c["taken"] and o["id"] == c["out"]
		var olit: float = c["out_reveal"] if chosen else 0.0
		if chosen and olit > 0.0:
			draw_rect(orc, C_GREY.lerp(C_BLUE, olit))
			draw_rect(Rect2(orc.position - Vector2(2, 2), orc.size + Vector2(4, 4)), Color(C_BLUE, 0.35 * olit), false, 2.0)
			_out_text(orc, o["text"], Color.WHITE)
		elif o["state"] == "seen":
			draw_rect(orc, Color("f3f4f6"))
			draw_rect(orc, Color(0, 0, 0, 0.1), false, 1.0)
			_out_text(orc, o["text"], C_GREY_D)
		else:
			draw_rect(orc, Color("dcdfe3"))
			_lock(orc.position + Vector2(8.0, 5.0), 0.8)
			draw_string(_font, orc.position + Vector2(26.0, orc.size.y * 0.5 + 5.0), "[...]", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, C_GREY_D)


## Büyük harf (Türkçede i → İ, ı → I: "TEKLİFLER", "KIRMIZI")
func _upper(s: String) -> String:
	if _loc == "tr":
		s = s.replace("i", "İ").replace("ı", "I")
	return s.to_upper()


func _out_text(r: Rect2, text: String, col: Color) -> void:
	var fs := 13
	while fs > 9 and _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > r.size.x - 12.0:
		fs -= 1
	draw_string(_font, r.position + Vector2(7.0, r.size.y * 0.5 + fs * 0.36), text, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 10.0, fs, col)


## Küçük asma kilit (Detroit'in turuncu kilidi)
func _lock(at: Vector2, s: float) -> void:
	draw_arc(at + Vector2(6, 6) * s, 4.2 * s, PI, TAU, 10, C_LOCK, 2.0 * s)
	draw_rect(Rect2(at + Vector2(0, 6) * s, Vector2(12, 9) * s), C_LOCK)


func _draw_final(c: Dictionary) -> void:
	var r: Rect2 = c["rect"]
	var lit: float = c["reveal"]
	var big := Rect2(r.position + Vector2(-10, 10), Vector2(CARD.x + 60.0, CARD.y + 40.0))
	if lit <= 0.0:
		draw_rect(big, C_GREY)
		_lock(big.get_center() - Vector2(8, 12), 1.6)
		return
	var glow := 0.5 + 0.5 * sin(_t * 3.0)
	draw_rect(big.grow(6.0 + 4.0 * glow), Color(C_GOLD, 0.25 * lit))
	draw_rect(big, Color("1d2230").lerp(Color("2a2410"), 0.3))
	draw_rect(big, C_GOLD, false, 3.0)
	draw_string(_font_title, big.position + Vector2(0, 40), tr("UI_JOURNEY_FINAL"), HORIZONTAL_ALIGNMENT_CENTER, big.size.x, 18, Color(C_GOLD, 0.8))
	var name := tr("UI_CH15_FINAL_" + final_id.to_upper()) if final_id != "" else "?"
	var fs := 30
	while fs > 14 and _font_title.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > big.size.x - 20.0:
		fs -= 1
	draw_string(_font_title, big.position + Vector2(0, big.size.y * 0.5 + fs * 0.5 + 6.0), name, HORIZONTAL_ALIGNMENT_CENTER, big.size.x, fs, C_GOLD)


## Ekran üstü: başlık, sayılar, şimdiki durak, perde adı, ipucu
func _draw_overlay() -> void:
	draw_rect(Rect2(0, 0, size.x, 74), Color(1, 1, 1, 0.55))
	draw_string(_font_title, Vector2(28, 40), tr("UI_JOURNEY_TITLE"), HORIZONTAL_ALIGNMENT_LEFT, -1, 26, C_BLUE_D)
	draw_string(_font, Vector2(30, 62), tr("UI_JOURNEY_SUB") % [_path.size(), _decisions], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, C_TEXT)
	if _caption != "":
		var cw := _font_title.get_string_size(_caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		var box := Rect2(Vector2(size.x - cw - 64.0, 18), Vector2(cw + 36.0, 38))
		draw_rect(box, C_BLUE)
		draw_string(_font_title, box.position + Vector2(18, 27), _caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	if _act_t > 0.0 and _act_caption != "":
		var a := clampf(_act_t / 0.6, 0.0, 1.0)
		draw_string(_font_title, Vector2(0, 116), _act_caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, 24, Color(C_TEXT, 0.75 * a))
	# İpucu altta kendi şeridinde (kartların etiketlerinin üstüne binmesin)
	var hint := tr("UI_JOURNEY_SKIP") if not _done else tr("UI_JOURNEY_CONTINUE")
	draw_rect(Rect2(0, size.y - 42, size.x, 42), Color(1, 1, 1, 0.55))
	draw_string(_font, Vector2(0, size.y - 16), hint, HORIZONTAL_ALIGNMENT_CENTER, size.x, 15, Color(C_TEXT, 0.8))


## Test: yol, karar sayısı, eksik eşleşme (veri eskiyse JOURNEY_MISS); düğümler birbirinin üstüne binmiyor mu
func _report() -> void:
	var overlap := 0
	var boxes: Array = []
	for cid in _cards:
		var c: Dictionary = _cards[cid]
		var r: Rect2 = c["rect"]
		var outs: Array = c["outs"]
		var bottom: float = (outs[-1]["rect"] as Rect2).end.y if not outs.is_empty() else (c["bar"] as Rect2).end.y
		boxes.append([cid, Rect2(r.position, Vector2(CARD.x, bottom - r.position.y))])
	for i in boxes.size():
		for j in range(i + 1, boxes.size()):
			if (boxes[i][1] as Rect2).grow(-2.0).intersects((boxes[j][1] as Rect2).grow(-2.0)):
				overlap += 1
				print("JOURNEY_OVERLAP %s %s" % [boxes[i][0], boxes[j][0]])
	print("JOURNEY cards=%d path=%d decisions=%d edges=%d overlap=%d final=%s route=%s" % [_cards.size(), _path.size(), _decisions,
		_edges.filter(func(e): return e["taken"]).size(), overlap, final_id, ",".join(_path)])
