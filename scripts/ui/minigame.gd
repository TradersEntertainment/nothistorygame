class_name MiniGame
extends Control
## Mini oyunların tabanı: ortada koyu panel, başlık, alt bilgi; bitince finished(score, won).
## Oyuncu (Player._start_minigame) donar, fare görünür; oyun bitince sonuç repliği gelir.
## Başlatma: seviyede Props.interactable(..., "mg:<id>", ...) ve Player bu önekli kimliği kendisi yakalar.

signal finished(score: int, won: bool)

const C_PANEL := Color(0.06, 0.07, 0.1, 0.93)
const C_CREAM := Color("f2e6c9")
const C_ACCENT := Color("6ff2c8")
const C_GOLD := Color("ffd24a")
const C_DIM := Color(1, 1, 1, 0.6)

var title_font: Font
var panel: Panel
var area: Control             # oyunun çizim alanı (panel içi)
var _done := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	panel = Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_PANEL
	sb.set_corner_radius_all(14)
	sb.border_color = Color(1, 1, 1, 0.12)
	sb.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", sb)
	add_child(panel)
	var vs := get_viewport().get_visible_rect().size
	var size_px := Vector2(minf(880.0, vs.x - 40.0), minf(560.0, vs.y - 40.0))
	panel.size = size_px
	panel.position = (vs - size_px) * 0.5
	area = Control.new()
	area.position = Vector2(24, 70)
	area.size = size_px - Vector2(48, 120)
	panel.add_child(area)
	setup()


## Alt sınıf: arayüzü kurar.
func setup() -> void:
	pass


func heading(text: String) -> void:
	var l := text_label(text, 30, C_CREAM, panel)
	if title_font:
		l.add_theme_font_override("font", title_font)
	l.position = Vector2(24, 16)


func footer(text: String) -> Label:
	var l := text_label(text, 14, C_DIM, panel)
	l.position = Vector2(24, panel.size.y - 40)
	l.size = Vector2(panel.size.x - 48, 36)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	return l


func text_label(text: String, size: int, color: Color, parent: Control = null) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	(parent if parent else area).add_child(l)
	return l


func finish(score: int, won: bool) -> void:
	if _done:
		return
	_done = true
	finished.emit(score, won)
