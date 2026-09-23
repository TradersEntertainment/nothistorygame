class_name RadioTuner
extends Control
## Telsiz frekansı: A/D ile kadranı çevir, sinyal güçlenince E'yi basılı tutup kilitle.
## Süre çubuğu azalır (⏱). Hedef frekans gizlidir; parazit ve sinyal çubukları ipucu verir.

var freq := 96.0              # 88..108 MHz
var target := 101.3
var lock := 0.0               # 0..1 (E basılı tutuldukça dolar)
var time_left := 1.0          # 0..1
var label_text := ""
var hint_text := ""
var _t := 0.0


func _init() -> void:
	custom_minimum_size = Vector2(520, 170)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func strength() -> float:
	return clampf(1.0 - absf(freq - target) / 3.0, 0.0, 1.0)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var w := size.x
	draw_rect(Rect2(0, 0, w, size.y), Color(0.06, 0.07, 0.1, 0.88))
	draw_rect(Rect2(0, 0, w, size.y), Color("6ff2c8"), false, 2.0)
	if label_text != "":
		draw_string(font, Vector2(16, 28), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("6ff2c8"))
	# Kadran
	var dial := Rect2(16, 44, w - 32, 44)
	draw_rect(dial, Color("1a2420"))
	for i in 21:
		var x := dial.position.x + dial.size.x * i / 20.0
		var major := i % 5 == 0
		draw_line(Vector2(x, dial.end.y), Vector2(x, dial.end.y - (16 if major else 8)), Color(1, 1, 1, 0.6), 2.0)
		if major:
			draw_string(font, Vector2(x - 12, dial.position.y + 16), "%d" % (88 + i), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 1, 1, 0.7))
	var fx := dial.position.x + dial.size.x * (freq - 88.0) / 20.0
	draw_line(Vector2(fx, dial.position.y), Vector2(fx, dial.end.y), Color("ff5a4a"), 3.0)
	draw_string(font, Vector2(w - 150, 28), "%.1f MHz" % freq, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	# Sinyal: parazit dalgası sinyal güçlendikçe düzleşir
	var s := strength()
	var wave := PackedVector2Array()
	for i in 60:
		var x := 16.0 + (w * 0.55) * i / 59.0
		var noise := sin(_t * 40.0 + i * 1.7) * sin(i * 0.9 + _t * 7.0) * (1.0 - s) * 14.0
		var sig := sin(i * 0.35 + _t * 6.0) * s * 12.0
		wave.append(Vector2(x, 120.0 + noise + sig))
	draw_polyline(wave, Color("6ff2c8").lerp(Color("ffd60a"), s), 2.0)
	for i in 5:
		var on := s > (i + 1) / 5.5
		draw_rect(Rect2(w * 0.62 + i * 20, 134 - i * 8, 14, 10 + i * 8), Color("6ff2c8") if on else Color(1, 1, 1, 0.12))
	# Kilit ve süre
	draw_rect(Rect2(w * 0.62 + 110, 100, 90, 12), Color(1, 1, 1, 0.12))
	draw_rect(Rect2(w * 0.62 + 110, 100, 90 * lock, 12), Color("ffd60a"))
	draw_rect(Rect2(0, size.y - 6, w * time_left, 6), Color("ff5a4a"))
	if hint_text != "":
		draw_string(font, Vector2(16, size.y - 14), hint_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1, 0.75))
