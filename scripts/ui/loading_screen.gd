class_name LoadingScreen
extends CanvasLayer
## Bölüm geçişlerinde yükleme ekranı (GameState._change_with_loader kurar ve kaldırır).
##   Arka plan: gidilen bölümün kapağı (assets/art/covers), karartılmış ve yavaşça yakınlaşan; kapağı olmayan sahnede
##   koyu degrade. Ortada bölüm adı ve tarihi; altta dönen saat çarkı, gerçek yükleme ilerlemesine bağlı çubuk ve her
##   açılışta değişen bir "tarihten" bilgisi ya da oyun ipucu (UI_LOADTIP_*).
## Eskiden düz siyah ekranda "Yükleniyor." yazıyordu (v0.99.13); oyun takıldı sanılıyordu.

const TIPS := 14
const GOLD := Color("d9b45a")

var _cover: TextureRect
var _bar_fill: ColorRect
var _bar_bg: ColorRect
var _label: Label
var _spinner: Control
var _t := 0.0
var _progress := 0.0
var _shown := 0.0


func _init(path: String) -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.025, 0.02)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	# Kapak: tam ekranı doldurur (kırparak), karartılır; _process'te yavaşça yakınlaşır
	var key: String = Hud.COVERS.get(path.get_file().get_basename(), "")
	var cp := "res://assets/art/covers/%s.png" % key
	if key != "" and ResourceLoader.exists(cp):
		_cover = TextureRect.new()
		_cover.texture = load(cp)
		_cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
		_cover.modulate = Color(0.55, 0.52, 0.48, 0.0)
		root.add_child(_cover)
	# Alttan yukarı koyulaşan perde: yazılar her kapakta okunsun
	var shade := TextureRect.new()
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.15))
	g.set_color(1, Color(0, 0, 0, 0.9))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	shade.texture = gt
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	box.offset_top = -250.0
	box.offset_bottom = -40.0
	box.offset_left = 80.0
	box.offset_right = -80.0
	box.add_theme_constant_override("separation", 10)
	root.add_child(box)
	var title := _title(path)
	if title != "":
		var tl := Label.new()
		tl.text = title
		if ResourceLoader.exists(Hud.FONT_TITLE):
			tl.add_theme_font_override("font", load(Hud.FONT_TITLE))
		tl.add_theme_font_size_override("font_size", 34)
		tl.add_theme_color_override("font_color", Color("f2e6c9"))
		tl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		tl.add_theme_constant_override("shadow_offset_y", 2)
		box.add_child(tl)
		var sub := _sub(path)
		if sub != "":
			var sl := Label.new()
			sl.text = sub
			sl.add_theme_font_size_override("font_size", 18)
			sl.add_theme_color_override("font_color", GOLD)
			box.add_child(sl)
	# İpucu / tarihten bilgi
	var tip := Label.new()
	tip.text = TranslationServer.translate("UI_LOADTIP_%d" % (1 + randi() % TIPS))
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size = Vector2(0, 52)
	tip.add_theme_font_size_override("font_size", 17)
	tip.add_theme_color_override("font_color", Color(1, 1, 1, 0.72))
	box.add_child(tip)
	# Çark + "Yükleniyor..." + ilerleme çubuğu
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	box.add_child(row)
	_spinner = Control.new()
	_spinner.custom_minimum_size = Vector2(30, 30)
	_spinner.draw.connect(_draw_spinner)
	row.add_child(_spinner)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 6)
	row.add_child(col)
	_label = Label.new()
	_label.text = TranslationServer.translate("UI_LOADING")
	_label.add_theme_font_size_override("font_size", 16)
	_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	col.add_child(_label)
	_bar_bg = ColorRect.new()
	_bar_bg.color = Color(1, 1, 1, 0.12)
	_bar_bg.custom_minimum_size = Vector2(0, 4)
	col.add_child(_bar_bg)
	_bar_fill = ColorRect.new()
	_bar_fill.color = GOLD
	_bar_fill.size = Vector2(0, 4)
	_bar_bg.add_child(_bar_fill)


## Gerçek yükleme ilerlemesi (0–1): ResourceLoader.load_threaded_get_status'tan
func set_progress(p: float) -> void:
	_progress = clampf(maxf(_progress, p), 0.0, 1.0)


func _process(delta: float) -> void:
	_t += delta
	# Çubuk ilerlemeye yumuşakça yetişir; ilerleme gelmezse de yavaşça kıpırdar (donmuş görünmesin)
	_shown = minf(lerpf(_shown, maxf(_progress, minf(0.9, 1.0 - exp(-_t * 0.25))), minf(1.0, delta * 4.0)), 1.0)
	if _bar_fill and _bar_bg:
		_bar_fill.size = Vector2(_bar_bg.size.x * _shown, _bar_bg.size.y)
	if _label:
		_label.text = TranslationServer.translate("UI_LOADING") + ".".repeat(1 + int(_t * 3.0) % 3)
	if _cover:
		_cover.modulate.a = minf(1.0, _cover.modulate.a + delta * 2.5)
		var s := 1.0 + minf(_t, 20.0) * 0.006
		_cover.pivot_offset = _cover.size * 0.5
		_cover.scale = Vector2(s, s)
	if _spinner:
		_spinner.queue_redraw()


## Saat çarkı: dönen altın yay ve içinde ters dönen kısa ibre
func _draw_spinner() -> void:
	var c := _spinner.size * 0.5
	var r := minf(c.x, c.y) - 2.0
	_spinner.draw_arc(c, r, 0.0, TAU, 40, Color(1, 1, 1, 0.12), 3.0, true)
	var a := _t * 4.0
	_spinner.draw_arc(c, r, a, a + PI * 0.7, 24, GOLD, 3.0, true)
	var h := -_t * 1.3
	_spinner.draw_line(c, c + Vector2(cos(h), sin(h)) * r * 0.55, Color(1, 1, 1, 0.7), 2.0, true)
	_spinner.draw_circle(c, 2.5, GOLD)


static func _key(path: String) -> String:
	return path.get_file().get_basename().trim_prefix("chapter").to_upper()


static func _title(path: String) -> String:
	if not path.get_file().begins_with("chapter"):
		return ""
	var k := _key(path)
	for key: String in ["UI_CH%s_TITLE" % k, "UI_CH%sA_TITLE" % k]:
		var t := String(TranslationServer.translate(key))
		if t != key:
			return Siege.fill_number(t, path).replace("  ", " ")
	return ""


static func _sub(path: String) -> String:
	var key := "UI_CH%s_SUB" % _key(path)
	var t := String(TranslationServer.translate(key))
	return t if t != key else ""
