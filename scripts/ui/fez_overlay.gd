class_name FezOverlay
extends Control
## Birinci şahıs fes görünümü: ekranın üst kenarında fesin kenarı ve
## oyuncu yürüdükçe sallanan püskül. Fes takılıyken görünür.

var motion := 0.0      # oyuncunun yatay hızı (0..~5)
var _t := 0.0
var _swing := 0.0
var _swing_v := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_t += delta
	# Basit yay-sönüm: yürüdükçe püskül sallanır
	var drive := sin(_t * (3.0 + motion)) * (0.12 + motion * 0.09)
	_swing_v += (drive - _swing) * 18.0 * delta
	_swing_v *= 0.92
	_swing += _swing_v * delta * 6.0
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var cx := w * 0.5
	# Fesin ön kenarı: ekranın üstünde koyu kırmızı bir yay
	var brim := PackedVector2Array()
	var steps := 24
	for i in steps + 1:
		var f := float(i) / steps
		var x := lerpf(w * 0.08, w * 0.92, f)
		var y := 18.0 + sin(f * PI) * 34.0
		brim.append(Vector2(x, y))
	brim.append(Vector2(w * 0.92, 0))
	brim.append(Vector2(w * 0.08, 0))
	draw_colored_polygon(brim, Color("a51d25"))
	# Kenarda ince gölge
	for i in steps:
		var f0 := float(i) / steps
		var f1 := float(i + 1) / steps
		draw_line(Vector2(lerpf(w * 0.08, w * 0.92, f0), 18.0 + sin(f0 * PI) * 34.0),
			Vector2(lerpf(w * 0.08, w * 0.92, f1), 18.0 + sin(f1 * PI) * 34.0), Color("6e1016"), 3.0)
	# Püskül ipi ve püskül
	var anchor := Vector2(cx + w * 0.12, 30.0)
	var length := 95.0
	var ang := 0.35 + _swing
	var tip := anchor + Vector2(sin(ang), cos(ang)) * length
	draw_line(anchor, tip, Color("141414"), 3.0)
	for k in 7:
		var a2 := ang + (k - 3) * 0.08
		draw_line(tip, tip + Vector2(sin(a2), cos(a2)) * 38.0, Color("111111"), 4.0)
	draw_circle(tip, 7.0, Color("1c1c1c"))
