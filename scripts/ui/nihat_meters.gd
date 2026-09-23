class_name NihatMeters
extends Control
## Nihat'ın göstergeleri (CHAPTERS §4.3, §4.1):
## - Kural Sadakati: köşede bir "ONAY" damgası. Sadakat düştükçe soluklaşır ve çatlar.
## - Doğruyu söyletme olasılığı %: sorguda canlı değişen yüzde.
## Değişince kısa bir parlama ve "+10" / "−15" gibi uçan bir fark yazısı çıkar.

var loyalty := 60.0
var persuade := -1.0          # < 0: gizli
var _shown_loyalty := 60.0
var _shown_persuade := 0.0
var _pops: Array = []         # [{text, color, t, row}]
var _loy_label := ""
var _per_label := ""


func _init() -> void:
	custom_minimum_size = Vector2(300, 150)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_loyalty(v: float) -> void:
	var d := v - loyalty
	loyalty = clampf(v, 0.0, 100.0)
	if absf(d) > 0.1:
		_pops.append({"text": ("%+d" % int(d)), "color": Color("8ff0b0") if d > 0 else Color("ff8a7a"), "t": 0.0, "row": 0})


func set_persuade(v: float) -> void:
	if v < 0.0:
		persuade = -1.0
		return
	var d := v - maxf(persuade, 0.0)
	if persuade < 0.0:
		_shown_persuade = v
		d = 0.0
	persuade = clampf(v, 0.0, 100.0)
	if absf(d) > 0.1:
		_pops.append({"text": ("%+d%%" % int(d)), "color": Color("8ff0b0") if d > 0 else Color("ff8a7a"), "t": 0.0, "row": 1})


func _process(delta: float) -> void:
	_shown_loyalty = move_toward(_shown_loyalty, loyalty, delta * 30.0)
	if persuade >= 0.0:
		_shown_persuade = move_toward(_shown_persuade, persuade, delta * 40.0)
	for p in _pops:
		p["t"] += delta
	_pops = _pops.filter(func(p): return p["t"] < 1.4)
	_loy_label = tr("UI_LOYALTY")
	_per_label = tr("UI_PERSUADE")
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var w := size.x
	var rows := 2 if persuade >= 0.0 else 1
	draw_rect(Rect2(0, 0, w, 70 * rows + 10), Color(0.06, 0.07, 0.1, 0.78))
	# Damga
	var c := Vector2(42, 42)
	var f := clampf(_shown_loyalty / 100.0, 0.0, 1.0)
	var ink := Color("c8323a")
	ink.a = lerpf(0.25, 1.0, f)
	draw_arc(c, 28, 0, TAU, 40, ink, 5.0)
	draw_arc(c, 21, 0, TAU, 40, ink, 2.0)
	var stamp := tr("UI_STAMP")
	var ts := font.get_string_size(stamp, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	draw_string(font, c + Vector2(-ts.x / 2, 5), stamp, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ink)
	# Çatlaklar: 50 altı bir, 35 altı üç
	var crack := Color(0.06, 0.07, 0.1, 0.95)
	if _shown_loyalty < 50.0:
		draw_polyline(PackedVector2Array([c + Vector2(-6, -30), c + Vector2(2, -12), c + Vector2(-4, 2), c + Vector2(6, 14)]), crack, 3.0)
	if _shown_loyalty < 35.0:
		draw_polyline(PackedVector2Array([c + Vector2(30, 4), c + Vector2(12, 8), c + Vector2(4, -2)]), crack, 3.0)
		draw_polyline(PackedVector2Array([c + Vector2(-26, 18), c + Vector2(-12, 10), c + Vector2(-2, 16)]), crack, 3.0)
	draw_string(font, Vector2(84, 30), _loy_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("6ff2c8"))
	draw_string(font, Vector2(84, 58), "%d" % roundi(_shown_loyalty), HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
	# Doğruyu söyletme olasılığı
	if persuade >= 0.0:
		var y := 80.0
		draw_string(font, Vector2(14, y + 18), _per_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("6ff2c8"))
		draw_string(font, Vector2(14, y + 50), "%%%d" % roundi(_shown_persuade), HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("ffd60a"))
		var bar := Rect2(96, y + 30, w - 112, 14)
		draw_rect(bar, Color(1, 1, 1, 0.12))
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * _shown_persuade / 100.0, bar.size.y)), Color("ffd60a"))
	# Uçan farklar
	for p in _pops:
		var t: float = p["t"]
		var col: Color = p["color"]
		col.a = clampf(1.4 - t, 0.0, 1.0)
		var py := (58.0 if p["row"] == 0 else 130.0) - t * 22.0
		draw_string_outline(font, Vector2(200, py), p["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 5, Color(0, 0, 0, col.a * 0.7))
		draw_string(font, Vector2(200, py), p["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, col)
