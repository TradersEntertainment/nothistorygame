class_name PlaytestSend
extends Control
## Oyun testi çıkış kartı (GameState.quit_game): gönderilmemiş cevap varsa oyuncu çıkarken çıkar. Oyuncu dosya aramaz:
## "Kopyala" bütün cevapları panoya alır (GameState.playtest_clip_text), oyuncu WhatsApp/Discord/e-postaya yapıştırır.
## "Çık" oyundan çıkar, "Geri" (ya da Esc) çıkıştan vazgeçer. Oyun duraklatılmışken çalışır; kolla da gezilir.
## Bittiğinde done("quit" | "back") yayar.

signal done(result: String)

var _status: Label
var _copy: Button
var _quit: Button


func _init() -> void:
	name = "PlaytestSend"
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _style(bg: Color, border := Color("e0b45a")) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	s.set_content_margin_all(14)
	return s


func _label(parent: Control, text: String, size: int, col := Color("f2e6c9")) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(l)
	return l


func _button(parent: Control, text: String, primary := false) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 22)
	b.custom_minimum_size = Vector2(150, 52)
	var bg := Color(0.3, 0.22, 0.08, 0.95) if primary else Color(0.14, 0.13, 0.12, 0.95)
	b.add_theme_stylebox_override("normal", _style(bg, Color("e0b45a") if primary else Color(1, 1, 1, 0.2)))
	b.add_theme_stylebox_override("hover", _style(Color(0.4, 0.3, 0.1, 0.95)))
	b.add_theme_stylebox_override("focus", _style(Color(0.4, 0.3, 0.1, 0.95)))
	b.add_theme_stylebox_override("pressed", _style(Color(0.5, 0.36, 0.1, 0.95)))
	parent.add_child(b)
	return b


func _ready() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(Color(0.07, 0.07, 0.09, 0.96)))
	panel.custom_minimum_size = Vector2(640, 0)
	center.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	_label(col, tr("UI_PT_HEAD"), 15, Color(1, 1, 1, 0.6))
	_label(col, tr("UI_PT_OUT_HEAD"), 26)
	_label(col, tr("UI_PT_OUT_BODY"), 19)
	_status = _label(col, "", 18, Color("9fe0a0"))
	_status.visible = false
	var acts := HBoxContainer.new()
	acts.alignment = BoxContainer.ALIGNMENT_CENTER
	acts.add_theme_constant_override("separation", 14)
	col.add_child(acts)
	_copy = _button(acts, tr("UI_PT_OUT_COPY"), true)
	_copy.pressed.connect(_do_copy)
	_quit = _button(acts, tr("UI_PT_OUT_QUIT"))
	_quit.pressed.connect(func(): _finish("quit"))
	var back := _button(acts, tr("UI_PT_OUT_BACK"))
	back.pressed.connect(func(): _finish("back"))
	_copy.grab_focus.call_deferred()


func _do_copy() -> void:
	var r: Array = GameState.playtest_clip_text()
	_status.text = tr("UI_PT_OUT_COPIED") % int(r[1])
	_status.visible = true
	_copy.text = tr("UI_PT_OUT_AGAIN")
	_quit.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_finish("back")


func _finish(result: String) -> void:
	done.emit(result)
	queue_free()
