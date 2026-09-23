class_name BalanceMeter
extends Control
## Zincirde denge: ibre ortada kalmalı. Kenarlara yaklaştıkça kırmızılaşır.
## value: -1 (sol) .. 1 (sağ). |value| >= 1 düşüş demektir.

var value := 0.0
var label_text := ""


func _init() -> void:
	custom_minimum_size = Vector2(420, 70)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var w := size.x
	var bar := Rect2(0, 34, w, 18)
	draw_rect(bar.grow(4), Color(0.06, 0.07, 0.1, 0.85))
	var steps := 21
	for i in steps:
		var f := float(i) / (steps - 1) * 2.0 - 1.0
		var c := Color("3fbf6a").lerp(Color("e2483b"), clampf(absf(f) * 1.3 - 0.2, 0.0, 1.0))
		draw_rect(Rect2(bar.position + Vector2(w * i / steps, 0), Vector2(w / steps - 2, bar.size.y)), c)
	draw_rect(Rect2(w / 2 - 1, bar.position.y - 6, 2, bar.size.y + 12), Color(1, 1, 1, 0.6))
	var x := w * (clampf(value, -1.0, 1.0) * 0.5 + 0.5)
	var pts := PackedVector2Array([Vector2(x, bar.position.y - 2), Vector2(x - 9, bar.position.y - 16), Vector2(x + 9, bar.position.y - 16)])
	draw_colored_polygon(pts, Color.WHITE)
	draw_rect(Rect2(x - 2, bar.position.y - 2, 4, bar.size.y + 4), Color.WHITE)
	if label_text != "":
		var ts := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
		draw_string_outline(font, Vector2((w - ts.x) / 2.0, 16), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, 6, Color(0, 0, 0, 0.8))
		draw_string(font, Vector2((w - ts.x) / 2.0, 16), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("ffd60a"))
