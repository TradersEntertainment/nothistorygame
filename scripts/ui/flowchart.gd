class_name Flowchart
extends Control
## Bölüm sonu akış şeması (Detroit tarzı, CHAPTERS §9).
## Düğümler: bu oyunda seçilen (dolu), daha önce görülmüş (çerçeve), kilitli (?).
## Zaman Bürosu'nun resmî belgesi gibi görünür.

## nodes: [{id, key, pos: Vector2 (0..1 oran), outcome: bool}]
## edges: [[from_id, to_id]]
var nodes: Array = []
var edges: Array = []
var taken: Dictionary = {}      # id -> true (bu oyunda)
var seen: Dictionary = {}       # id -> true (önceki oyunlarda)
var title_text := ""
var footer_lines: Array[String] = []
## Bölümün akış şeridi (assets/art/flow/chN.png): sol üstte antet gibi durur
var strip: Texture2D

const C_BG := Color("efe6cf")
const C_INK := Color("2a2622")
const C_TAKEN := Color("c8262f")
const C_SEEN := Color("7a6f60")
const C_LOCKED := Color("b8ad96")
const NODE_SIZE := Vector2(280, 46)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _node_rect(n: Dictionary) -> Rect2:
	var p: Vector2 = n["pos"]
	var center := Vector2(p.x * size.x, p.y * size.y)
	return Rect2(center - NODE_SIZE * 0.5, NODE_SIZE)


func _find(id: String) -> Dictionary:
	for n in nodes:
		if n["id"] == id:
			return n
	return {}


func _state(id: String) -> String:
	if taken.has(id):
		return "taken"
	if seen.has(id):
		return "seen"
	return "locked"


func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), C_BG)
	# Kâğıt dokusu: ince yatay çizgiler
	var y := 0.0
	while y < size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), Color(0, 0, 0, 0.03), 1.0)
		y += 24.0
	if strip != null:
		var sh := 72.0
		var sw := sh * strip.get_width() / float(strip.get_height())
		draw_texture_rect(strip, Rect2(Vector2(24, 16), Vector2(sw, sh)), false)
		draw_rect(Rect2(Vector2(24, 16), Vector2(sw, sh)), C_INK, false, 2.0)
	# Başlık
	draw_string(font, Vector2(0, 52), title_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 30, C_INK)
	draw_line(Vector2(size.x * 0.2, 66), Vector2(size.x * 0.8, 66), C_INK, 2.0)

	# Kenarlar
	for e in edges:
		var a := _find(e[0])
		var b := _find(e[1])
		if a.is_empty() or b.is_empty():
			continue
		var ra := _node_rect(a)
		var rb := _node_rect(b)
		var from := Vector2(ra.get_center().x, ra.end.y)
		var to := Vector2(rb.get_center().x, rb.position.y)
		var both := taken.has(e[0]) and taken.has(e[1])
		var col := C_TAKEN if both else C_LOCKED
		var mid_y := (from.y + to.y) * 0.5
		draw_polyline(PackedVector2Array([from, Vector2(from.x, mid_y), Vector2(to.x, mid_y), to]), col, 3.0 if both else 2.0)

	# Düğümler
	for n in nodes:
		var r := _node_rect(n)
		var st := _state(n["id"])
		var text: String = tr(n["key"])
		match st:
			"taken":
				draw_rect(r, C_TAKEN)
				draw_string(font, r.position + Vector2(0, 30), text, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 18, Color.WHITE)
			"seen":
				draw_rect(r, C_BG)
				draw_rect(r, C_SEEN, false, 2.0)
				draw_string(font, r.position + Vector2(0, 30), text, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 18, C_SEEN)
			_:
				draw_rect(r, Color("ddd3bc"))
				draw_rect(r, C_LOCKED, false, 2.0)
				draw_string(font, r.position + Vector2(0, 32), "?", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 26, C_LOCKED)
		if n.get("outcome", false):
			# Sonuç düğümleri yuvarlak köşeli bir işaretle ayrılır
			draw_circle(r.position + Vector2(12, r.size.y * 0.5), 5.0, Color.WHITE if st == "taken" else C_LOCKED)

	# Alt bilgiler
	var fy := size.y - 118.0
	for line in footer_lines:
		draw_string(font, Vector2(0, fy), line, HORIZONTAL_ALIGNMENT_CENTER, size.x, 18, C_INK)
		fy += 26.0

	# Damga (eğik)
	var stamp_center := Vector2(size.x - 240, 150)
	draw_set_transform(stamp_center, -0.18, Vector2.ONE)
	draw_rect(Rect2(Vector2(-210, -34), Vector2(420, 60)), Color(0.78, 0.15, 0.18, 0.75), false, 3.0)
	draw_string(font, Vector2(-205, 2), tr("UI_FLOW_STAMP"), HORIZONTAL_ALIGNMENT_CENTER, 410, 12, Color(0.78, 0.15, 0.18, 0.85))
	draw_string(font, Vector2(-205, 20), "ZAMAN BÜROSU · FORM Z-0", HORIZONTAL_ALIGNMENT_CENTER, 410, 14, Color(0.78, 0.15, 0.18, 0.85))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
