class_name BudgetMap
extends Control
## "Bütçe nedeniyle..." sahnesi (GDD §4): pahalı bir yolculuk, eski bir haritada
## kesik çizgili bir okla geçiştirilir.

var progress := 0.0
var title := ""
var from_label := ""
var to_label := ""

const C_PAPER := Color("e9dcb8")
const C_INK := Color("3b2e22")
const C_SEA := Color("8fb4c4")
const C_RED := Color("b3262d")


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	queue_redraw()


func _p(x: float, y: float) -> Vector2:
	# Harita koordinatları (0..1) -> ekran
	var m := Vector2(size.x * 0.12, size.y * 0.14)
	return m + Vector2(x, y) * (size - m * 2.0)


func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), Color("201a14"))
	draw_rect(Rect2(_p(0, 0), _p(1, 1) - _p(0, 0)), C_PAPER)
	# Haliç (kıvrık bir deniz kolu) ve Boğaz
	var horn := PackedVector2Array([_p(0.0, 0.62), _p(0.2, 0.55), _p(0.42, 0.42), _p(0.62, 0.36), _p(0.8, 0.4),
		_p(1.0, 0.5), _p(1.0, 0.62), _p(0.8, 0.52), _p(0.62, 0.48), _p(0.44, 0.54), _p(0.22, 0.68), _p(0.0, 0.76)])
	draw_colored_polygon(horn, C_SEA)
	draw_polyline(horn, C_INK, 2.0, true)
	# Şehir surları (güneyde)
	var walls := PackedVector2Array([_p(0.05, 0.84), _p(0.25, 0.74), _p(0.45, 0.62), _p(0.62, 0.58), _p(0.82, 0.62), _p(0.95, 0.72)])
	draw_polyline(walls, C_INK, 4.0)
	for i in walls.size():
		draw_rect(Rect2(walls[i] - Vector2(6, 6), Vector2(12, 12)), C_INK)
	draw_string(font, _p(0.4, 0.8), "Konstantinopolis", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, C_INK)
	draw_string(font, _p(0.62, 0.22), "Galata", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, C_INK)
	# Kesik çizgili ok
	var a := _p(0.36, 0.3)
	var b := _p(0.12, 0.9)
	var ctrl := _p(-0.05, 0.45)
	var steps := 40
	var shown := int(steps * clampf(progress, 0.0, 1.0))
	var prev := a
	for i in range(1, shown + 1):
		var t := float(i) / steps
		var q := a.lerp(ctrl, t).lerp(ctrl.lerp(b, t), t)
		if i % 2 == 0:
			draw_line(prev, q, C_RED, 5.0)
		prev = q
	if progress >= 1.0:
		var dir := (b - ctrl).normalized()
		var side := Vector2(-dir.y, dir.x)
		draw_colored_polygon(PackedVector2Array([b + dir * 14, b - dir * 12 + side * 12, b - dir * 12 - side * 12]), C_RED)
	draw_circle(a, 8.0, C_RED)
	draw_string(font, a + Vector2(14, -8), from_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, C_RED)
	draw_string(font, b + Vector2(18, 6), to_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, C_RED)
	draw_string(font, Vector2(0, size.y * 0.09), title, HORIZONTAL_ALIGNMENT_CENTER, size.x, 26, Color("f2e6c9"))
