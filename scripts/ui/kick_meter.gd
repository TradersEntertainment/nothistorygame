class_name KickMeter
extends Control
## Tekme gücü çubuğu: imleç gidip gelir, oyuncu yeşil bölgede basar.
## Sol: zayıf (gri), orta-sağ: tam (yeşil), en sağ: fazla sert (kırmızı).

const WEAK_END := 0.55
const SWEET_END := 0.85

var value := 0.0          # imleç konumu 0..1
var label_text := ""
var flash := 0.0          # basıldığında imleç parlar


func _init() -> void:
	custom_minimum_size = Vector2(420, 74)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE


static func zone(v: float) -> String:
	if v < WEAK_END:
		return "weak"
	if v < SWEET_END:
		return "sweet"
	return "strong"


func _process(delta: float) -> void:
	flash = maxf(0.0, flash - delta * 3.0)
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var w := size.x
	var bar := Rect2(0, 30, w, 26)
	draw_rect(bar.grow(4), Color(0.08, 0.1, 0.14, 0.85))
	draw_rect(Rect2(bar.position, Vector2(w * WEAK_END, bar.size.y)), Color("5b6270"))
	draw_rect(Rect2(bar.position + Vector2(w * WEAK_END, 0), Vector2(w * (SWEET_END - WEAK_END), bar.size.y)), Color("3fbf6a"))
	draw_rect(Rect2(bar.position + Vector2(w * SWEET_END, 0), Vector2(w * (1.0 - SWEET_END), bar.size.y)), Color("e2483b"))
	var x := w * clampf(value, 0.0, 1.0)
	var cursor := Color.WHITE.lerp(Color("ffd60a"), flash)
	draw_rect(Rect2(x - 4, bar.position.y - 8, 8, bar.size.y + 16), cursor)
	if label_text != "":
		var ts := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22)
		draw_string_outline(font, Vector2((w - ts.x) / 2.0, 20), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, Color(0, 0, 0, 0.8))
		draw_string(font, Vector2((w - ts.x) / 2.0, 20), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("ffd60a"))
