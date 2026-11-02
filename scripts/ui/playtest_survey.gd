class_name PlaytestSurvey
extends Control
## Oyun testi bölüm sonu anketi (GameState "playtest" ayarı açıksa, Hud.playtest_survey): "Bu bölüm ne kadar
## eğlenceliydi?" 1-5, isteğe bağlı iki satır (en çok güldüğün an, en çok sıkıldığın an), Gönder / Geç. Oyun duraklatılmış
## iken çalışır; kolla da gezilir (düğmeler odaklanır). Bittiğinde done(cevap) yayar: {"fun": 0-5, "laugh", "bored"}.

signal done(answers: Dictionary)

var _fun := 0
var _buttons: Array[Button] = []
var _laugh: LineEdit
var _bored: LineEdit
var _send: Button


func _init() -> void:
	name = "PlaytestSurvey"
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


func _ready() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(Color(0.07, 0.07, 0.09, 0.96)))
	panel.custom_minimum_size = Vector2(600, 0)
	center.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)
	_label(col, tr("UI_PT_HEAD"), 15, Color(1, 1, 1, 0.6))
	_label(col, tr("UI_PT_FUN"), 24)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(row)
	for i in 5:
		var b := Button.new()
		b.text = str(i + 1)
		b.custom_minimum_size = Vector2(72, 56)
		b.add_theme_font_size_override("font_size", 24)
		b.add_theme_stylebox_override("normal", _style(Color(0.14, 0.13, 0.12, 0.95), Color(1, 1, 1, 0.2)))
		b.add_theme_stylebox_override("hover", _style(Color(0.22, 0.18, 0.1, 0.95)))
		b.add_theme_stylebox_override("focus", _style(Color(0.22, 0.18, 0.1, 0.95)))
		b.add_theme_stylebox_override("pressed", _style(Color(0.4, 0.3, 0.1, 0.95)))
		b.toggle_mode = true
		b.pressed.connect(_pick.bind(i + 1))
		row.add_child(b)
		_buttons.append(b)
	var ends := HBoxContainer.new()
	col.add_child(ends)
	var lo := _label(ends, tr("UI_PT_LOW"), 14, Color(1, 1, 1, 0.6))
	lo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var hi := _label(ends, tr("UI_PT_HIGH"), 14, Color(1, 1, 1, 0.6))
	hi.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(col, tr("UI_PT_LAUGH"), 18)
	_laugh = _line(col)
	_label(col, tr("UI_PT_BORED"), 18)
	_bored = _line(col)
	var acts := HBoxContainer.new()
	acts.alignment = BoxContainer.ALIGNMENT_END
	acts.add_theme_constant_override("separation", 12)
	col.add_child(acts)
	var skip := Button.new()
	skip.text = tr("UI_PT_SKIP")
	skip.add_theme_font_size_override("font_size", 20)
	skip.pressed.connect(func(): _finish(false))
	acts.add_child(skip)
	_send = Button.new()
	_send.text = tr("UI_PT_SEND")
	_send.add_theme_font_size_override("font_size", 20)
	_send.disabled = true
	_send.pressed.connect(func(): _finish(true))
	acts.add_child(_send)
	_buttons[2].grab_focus.call_deferred()


func _line(parent: Control) -> LineEdit:
	var e := LineEdit.new()
	e.max_length = 200
	e.add_theme_font_size_override("font_size", 18)
	e.placeholder_text = tr("UI_PT_OPTIONAL")
	parent.add_child(e)
	return e


func _pick(n: int) -> void:
	_fun = n
	for i in _buttons.size():
		_buttons[i].set_pressed_no_signal(i + 1 == n)
	_send.disabled = false


func _finish(send: bool) -> void:
	var ans := {"fun": _fun if send else 0, "laugh": _laugh.text.strip_edges() if send else "",
		"bored": _bored.text.strip_edges() if send else "", "skipped": not send}
	done.emit(ans)
	queue_free()
