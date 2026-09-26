class_name StaminaRing
extends Control
## Nefes halkası: tırmanırken nişangâhın sağında. Dolu ve kullanılmıyorken kaybolur;
## azalınca sarı, tükenince kırmızı yanıp söner.

var value := 1.0
var tired := false
var _want := false
var _alpha := 0.0
var _t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = 30.0
	offset_right = 74.0
	offset_top = -22.0
	offset_bottom = 22.0
	modulate.a = 0.0


func show_value(v: float, on: bool, is_tired: bool) -> void:
	value = clampf(v, 0.0, 1.0)
	tired = is_tired
	_want = on


func _process(delta: float) -> void:
	_t += delta
	_alpha = move_toward(_alpha, 1.0 if _want else 0.0, delta * (5.0 if _want else 1.6))
	modulate.a = _alpha
	visible = _alpha > 0.01
	if visible:
		queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var r := 14.0
	draw_arc(c, r, 0.0, TAU, 40, Color(0, 0, 0, 0.45), 8.0, true)
	var col := Color("7ee07a")
	if tired or value < 0.2:
		col = Color("ff5a4a")
		if tired:
			col.a = 0.55 + 0.45 * sin(_t * 12.0)
	elif value < 0.5:
		col = Color("ffcf4a")
	if value > 0.001:
		draw_arc(c, r, -PI / 2.0, -PI / 2.0 + TAU * value, 40, col, 5.0, true)
