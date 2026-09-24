class_name MiniGame
extends Control
## Mini oyunların tabanı: ekranı dolduran süslü çerçeve, üstte başlık ve durum, solda ev sahibinin portresi ve
## konuşma balonu (say), altta tuş rozetleri (keys), ortada oyunun çizim alanı (area). Bitince finished(score, won).
## Oyuncu (Player._start_minigame) donar, fare görünür; oyun bitince sonuç repliği gelir.
## Başlatma: seviyede Props.interactable(..., "mg:<id>", ...) ve Player bu önekli kimliği kendisi yakalar.

signal finished(score: int, won: bool)

const C_PANEL := Color(0.075, 0.06, 0.05, 0.96)
const C_CREAM := Color("f2e6c9")
const C_ACCENT := Color("6ff2c8")
const C_GOLD := Color("ffd24a")
const C_DIM := Color(1, 1, 1, 0.6)
const C_FRAME := Color("c9a24a")
const C_INK := Color("2a1c12")
const C_RED := Color("e0503a")

var title_font: Font
## Ev sahibi (SPK_*): solda portresi ve konuşma balonu. Boşsa çizim alanı tüm genişliği alır.
var host_speaker := ""
## Portre dosyası (Hud.ART altında); boşsa Hud.PORTRAITS[host_speaker].
var host_pic := ""
var panel: Control             # çerçeve (başlık, alan, rozetler bunun içinde)
var area: Control              # oyunun çizim alanı
var _bg: Control
var _bubble: Label
var _bubble_box: PanelContainer
var _host_img: TextureRect
var _status: Label
var _chips: HBoxContainer
var _big: Label
var _tail: Control
var _voice: AudioStreamPlayer
var _records: Control
var _record_rows: Array = []
var _card: Control
var _big_tw: Tween
var _done := false
var _time := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var vs := get_viewport().get_visible_rect().size
	_bg = Control.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg.draw.connect(_draw_bg)
	add_child(_bg)
	var m := clampf(vs.x * 0.018, 10.0, 26.0)
	panel = Control.new()
	panel.position = Vector2(m, m)
	panel.size = vs - Vector2(m, m) * 2.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.draw.connect(_draw_frame)
	add_child(panel)
	var side_w := 0.0
	if host_speaker != "":
		side_w = clampf(panel.size.x * 0.21, 170.0, 270.0)
		_build_host(side_w)
	area = Control.new()
	area.position = Vector2(side_w + (40.0 if side_w > 0.0 else 26.0), 78)
	area.size = Vector2(panel.size.x - area.position.x - 26.0, panel.size.y - 78.0 - 62.0)
	area.clip_contents = true
	panel.add_child(area)
	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 20)
	_status.add_theme_color_override("font_color", C_GOLD)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_status.position = Vector2(panel.size.x * 0.45, 24)
	_status.size = Vector2(panel.size.x * 0.55 - 28.0, 32)
	panel.add_child(_status)
	_chips = HBoxContainer.new()
	_chips.add_theme_constant_override("separation", 14)
	_chips.position = Vector2(26, panel.size.y - 48)
	_chips.size = Vector2(panel.size.x - 52, 34)
	_chips.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(_chips)
	_big = Label.new()
	_big.add_theme_font_size_override("font_size", 46)
	_big.add_theme_color_override("font_color", C_GOLD)
	_big.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_big.add_theme_constant_override("outline_size", 10)
	_big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_big.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_big.size = Vector2(area.size.x, 80)
	_big.position = Vector2(0, area.size.y * 0.3)
	_big.pivot_offset = _big.size * 0.5
	_big.modulate.a = 0.0
	_big.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(_big)
	setup()
	if title_font:
		_big.add_theme_font_override("font", title_font)
	area.move_child(_big, area.get_child_count() - 1)


func _physics_process(delta: float) -> void:
	_time += delta
	if _bg:
		_bg.queue_redraw()


## Alt sınıf: arayüzü kurar.
func setup() -> void:
	pass


# ---------------------------------------------------------------- çerçeve

func _build_host(w: float) -> void:
	var card := Control.new()
	card.position = Vector2(26, 78)
	card.size = Vector2(w, panel.size.y - 78.0 - 62.0)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.draw.connect(func():
		var r := Rect2(Vector2.ZERO, Vector2(w, w * 1.02))
		card.draw_rect(r, Color(0.16, 0.11, 0.08))
		# Kemer: portrenin üstünde sivri kemer süsü
		var pts := PackedVector2Array()
		for i in 17:
			var a := PI + PI * i / 16.0
			pts.append(Vector2(w * 0.5 + cos(a) * w * 0.5, w * 0.36 + sin(a) * w * 0.3))
		card.draw_polyline(pts, C_FRAME.darkened(0.2), 2.0)
		card.draw_rect(r.grow(-3), C_FRAME, false, 2.0)
		card.draw_rect(r.grow(1), C_FRAME.darkened(0.5), false, 1.0)
		var font := title_font if title_font else ThemeDB.fallback_font
		card.draw_string(font, Vector2(0, w * 1.02 + 30), tr(host_speaker), HORIZONTAL_ALIGNMENT_CENTER, w, 22, C_CREAM)
		var y := w * 1.02 + 40
		card.draw_line(Vector2(w * 0.2, y), Vector2(w * 0.8, y), C_FRAME.darkened(0.3), 1.5)
		_diamond(card, Vector2(w * 0.5, y), 5.0, C_FRAME))
	panel.add_child(card)
	_host_img = TextureRect.new()
	_host_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_host_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_host_img.position = Vector2(6, 6)
	_host_img.size = Vector2(w - 12, w * 1.02 - 12)
	_host_img.pivot_offset = _host_img.size * Vector2(0.5, 1.0)
	var pic: String = host_pic if host_pic != "" else Hud.PORTRAITS.get(host_speaker, "")
	if pic != "" and ResourceLoader.exists(Hud.ART + pic):
		_host_img.texture = load(Hud.ART + pic)
	card.add_child(_host_img)
	_bubble_box = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("f4ead2")
	sb.set_corner_radius_all(12)
	sb.border_color = C_FRAME.darkened(0.25)
	sb.set_border_width_all(2)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	_bubble_box.add_theme_stylebox_override("panel", sb)
	_bubble_box.position = Vector2(0, w * 1.02 + 56)
	_bubble_box.size = Vector2(w, 10)
	_bubble_box.custom_minimum_size = Vector2(w, 0)
	_bubble_box.pivot_offset = Vector2(w * 0.5, 0)
	card.add_child(_bubble_box)
	_bubble = Label.new()
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.add_theme_font_size_override("font_size", 16 if card.size.y > 420 else 14)
	_bubble.add_theme_color_override("font_color", C_INK)
	_bubble.custom_minimum_size = Vector2(w - 24, 0)
	_bubble_box.add_child(_bubble)
	_bubble_box.visible = false
	# Balonun kuyruğu (portreye doğru); PanelContainer çocuklarını yerleştirdiği için karta eklenir
	_tail = Control.new()
	_tail.position = _bubble_box.position + Vector2(w * 0.5 - 10, -10)
	_tail.visible = false
	_tail.draw.connect(func():
		_tail.draw_colored_polygon(PackedVector2Array([Vector2(0, 12), Vector2(10, 0), Vector2(20, 12)]), Color("f4ead2"))
		_tail.draw_polyline(PackedVector2Array([Vector2(0, 11), Vector2(10, 0), Vector2(20, 11)]), C_FRAME.darkened(0.25), 2.0))
	card.add_child(_tail)
	# Kartın altı: rekorlar kutusu (records ile doldurulur)
	_records = Control.new()
	_records.size = Vector2(w, 0)
	_records.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_records.draw.connect(_draw_records)
	card.add_child(_records)
	_card = card


## Ev sahibinin konuşma balonu (çeviri anahtarı ya da düz metin). Portre hafifçe zıplar.
func say(text: String) -> void:
	if _bubble == null:
		return
	_bubble.text = tr(text)
	Hud._audit(host_speaker, text)
	# Seslendirme varsa balonla birlikte çalar (Hud.voice_stream: o anki dilin dosyası)
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	var vs := hud.voice_stream(text) if hud else null
	if vs:
		if _voice == null:
			_voice = AudioStreamPlayer.new()
			_voice.bus = "Voice" if AudioServer.get_bus_index("Voice") >= 0 else "Master"
			add_child(_voice)
		_voice.stream = vs
		_voice.play()
	_bubble_box.visible = true
	_tail.visible = true
	_bubble_box.reset_size()
	_bubble_box.scale = Vector2(0.92, 0.92)
	var tw := create_tween().set_parallel()
	tw.tween_property(_bubble_box, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if _host_img:
		_host_img.scale = Vector2(1.0, 0.96)
		tw.tween_property(_host_img, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Portre kartının altındaki rekorlar kutusu: [["En iyi puan", "82"], ...]
func records(rows: Array) -> void:
	if _records == null:
		return
	_record_rows = rows
	var h := 44.0 + rows.size() * 26.0
	_records.size = Vector2(_card.size.x, h)
	_records.position = Vector2(0, _card.size.y - h)
	_records.queue_redraw()


func _draw_records() -> void:
	if _record_rows.is_empty():
		return
	var r := Rect2(Vector2.ZERO, _records.size)
	_records.draw_rect(r, Color(0.16, 0.11, 0.08, 0.9))
	_records.draw_rect(r.grow(-3), C_FRAME.darkened(0.3), false, 1.5)
	var font := ThemeDB.fallback_font
	var tf := title_font if title_font else font
	_records.draw_string(tf, Vector2(0, 26), tr("MG_RECORDS"), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 17, C_GOLD)
	for i in _record_rows.size():
		var y := 54.0 + i * 26.0
		var row: Array = _record_rows[i]
		_diamond(_records, Vector2(16, y - 5), 4.0, C_FRAME)
		_records.draw_string(font, Vector2(28, y), tr(str(row[0])), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 90, 15, C_CREAM)
		_records.draw_string(font, Vector2(0, y), str(row[1]), HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 14, 16, C_ACCENT)


## Sağ üstteki durum yazısı (puan, fiyat, sıra...).
func status(text: String) -> void:
	_status.text = text


## Alttaki tuş rozetleri: [["1", "Leblebi"], ["E", "Devam"], ...]
func keys(list: Array) -> void:
	for c in _chips.get_children():
		c.queue_free()
	for k in list:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 6)
		var kp := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = C_FRAME
		sb.set_corner_radius_all(6)
		sb.content_margin_left = 8
		sb.content_margin_right = 8
		sb.content_margin_top = 1
		sb.content_margin_bottom = 1
		sb.shadow_color = Color(0, 0, 0, 0.5)
		sb.shadow_offset = Vector2(0, 2)
		sb.shadow_size = 1
		kp.add_theme_stylebox_override("panel", sb)
		var kl := Label.new()
		kl.text = tr(GameState.key_hint(str(k[0])))
		kl.add_theme_font_size_override("font_size", 16)
		kl.add_theme_color_override("font_color", C_INK)
		kp.add_child(kl)
		h.add_child(kp)
		var tl := Label.new()
		tl.text = tr(str(k[1]))
		tl.add_theme_font_size_override("font_size", 16)
		tl.add_theme_color_override("font_color", C_CREAM)
		h.add_child(tl)
		_chips.add_child(h)


## Alanın ortasında büyük, sönen yazı (TAM KIVAMINDA!, İsabet!...).
func big(text: String, color := C_GOLD) -> void:
	_big.text = tr(text)
	_big.add_theme_color_override("font_color", color)
	_big.modulate.a = 1.0
	_big.scale = Vector2(0.6, 0.6)
	if _big_tw:
		_big_tw.kill()
	_big_tw = create_tween()
	_big_tw.tween_property(_big, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_big_tw.tween_interval(0.5)
	_big_tw.tween_property(_big, "modulate:a", 0.0, 0.35)


func heading(text: String) -> void:
	var l := text_label(text, 32, C_CREAM, panel)
	if title_font:
		l.add_theme_font_override("font", title_font)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_y", 2)
	l.position = Vector2(28, 16)


## Eski yardım satırı: artık tuş rozetleri kullanılıyor; metin rozet satırının üstünde küçük yazı olarak kalır.
func footer(text: String) -> Label:
	var l := text_label(text, 13, C_DIM, panel)
	l.position = Vector2(26, panel.size.y - 70)
	l.size = Vector2(panel.size.x - 52, 20)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.clip_text = true
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


# ---------------------------------------------------------------- çizim yardımcıları

func _draw_bg() -> void:
	var s := _bg.size
	_bg.draw_rect(Rect2(Vector2.ZERO, s), Color(0.02, 0.015, 0.01, 0.72))


func _draw_frame() -> void:
	var s := panel.size
	var r := Rect2(Vector2.ZERO, s)
	panel.draw_rect(r, C_PANEL)
	# Silik geometrik desen: sekiz köşeli yıldızlar
	var step := 64.0
	var col := Color(C_FRAME, 0.05)
	var y := 32.0
	while y < s.y:
		var x := 32.0 + (step * 0.5 if int(y / step) % 2 == 1 else 0.0)
		while x < s.x:
			_star(panel, Vector2(x, y), 14.0, col)
			x += step
		y += step
	# Başlık bandı
	panel.draw_rect(Rect2(0, 0, s.x, 64), Color(0.2, 0.12, 0.07, 0.9))
	panel.draw_line(Vector2(14, 64), Vector2(s.x - 14, 64), C_FRAME.darkened(0.2), 2.0)
	# Çift altın kenar ve köşe gülleri
	panel.draw_rect(r.grow(-4), C_FRAME, false, 3.0)
	panel.draw_rect(r.grow(-10), C_FRAME.darkened(0.45), false, 1.5)
	for c in [Vector2(10, 10), Vector2(s.x - 10, 10), Vector2(10, s.y - 10), Vector2(s.x - 10, s.y - 10)]:
		_star(panel, c, 12.0, C_FRAME)
		panel.draw_circle(c, 4.0, C_INK)
	# Alt rozet bandı
	panel.draw_rect(Rect2(14, s.y - 56, s.x - 28, 44), Color(0, 0, 0, 0.25))


static func _star(ci: CanvasItem, c: Vector2, r: float, col: Color) -> void:
	for k in 2:
		var pts := PackedVector2Array()
		for i in 4:
			var a := k * PI / 4.0 + i * PI / 2.0
			pts.append(c + Vector2(cos(a), sin(a)) * r)
		ci.draw_colored_polygon(pts, col)


static func _diamond(ci: CanvasItem, c: Vector2, r: float, col: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)]), col)


## Yumuşak dikey geçiş (üst → alt renk).
static func vgrad(ci: CanvasItem, r: Rect2, top: Color, bottom: Color, bands := 24) -> void:
	var h := r.size.y / bands
	for i in bands:
		ci.draw_rect(Rect2(r.position.x, r.position.y + i * h, r.size.x, h + 1.0), top.lerp(bottom, i / float(bands - 1)))


## Elips (doldurulmuş ya da çizgi).
static func ellipse(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color, filled := true, width := 2.0, seg := 36) -> void:
	var pts := PackedVector2Array()
	for i in seg + (1 if not filled else 0):
		var a := TAU * i / seg
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	if filled:
		ci.draw_colored_polygon(pts, col)
	else:
		ci.draw_polyline(pts, col, width, true)


## Parlak taş/boncuk: gölge, gövde, parıltı.
static func gem(ci: CanvasItem, c: Vector2, r: float, col: Color) -> void:
	ci.draw_circle(c + Vector2(1.5, 2.0), r, Color(0, 0, 0, 0.35))
	ci.draw_circle(c, r, col.darkened(0.25))
	ci.draw_circle(c - Vector2(r, r) * 0.15, r * 0.8, col)
	ci.draw_circle(c - Vector2(r, r) * 0.38, r * 0.3, Color(1, 1, 1, 0.7))


## Malzeme simgeleri (kazan oyunu ve tarif kartları): 0 leblebi, 1 soğan, 2 et, 3 baharat, 4 pirinç, 5 biber.
static func ingredient(ci: CanvasItem, kind: int, c: Vector2, r: float) -> void:
	match kind:
		0:
			for o in [Vector2(-0.45, 0.2), Vector2(0.45, 0.2), Vector2(0, -0.35), Vector2(0.0, 0.55)]:
				gem(ci, c + o * r, r * 0.46, Color("e8c078"))
		1:
			ellipse(ci, c + Vector2(0, r * 0.15), r * 0.8, r * 0.75, Color("9a4a8a"))
			ellipse(ci, c + Vector2(-r * 0.2, r * 0.05), r * 0.35, r * 0.5, Color("c878b8"))
			ci.draw_line(c + Vector2(0, -r * 0.55), c + Vector2(-r * 0.2, -r * 1.05), Color("6aa84a"), 3.0)
			ci.draw_line(c + Vector2(0, -r * 0.55), c + Vector2(r * 0.25, -r * 1.0), Color("6aa84a"), 3.0)
		2:
			ci.draw_line(c + Vector2(r * 0.3, r * 0.3), c + Vector2(r * 0.9, r * 0.9), Color("f0e8d8"), r * 0.28)
			ci.draw_circle(c + Vector2(r * 0.95, r * 0.8), r * 0.18, Color("f0e8d8"))
			ci.draw_circle(c + Vector2(r * 0.8, r * 0.95), r * 0.18, Color("f0e8d8"))
			ellipse(ci, c - Vector2(r * 0.15, r * 0.15), r * 0.75, r * 0.6, Color("b8402e"))
			ellipse(ci, c - Vector2(r * 0.35, r * 0.35), r * 0.3, r * 0.2, Color("d86a50"))
		3:
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.7, r * 0.9), c + Vector2(r * 0.7, r * 0.9),
				c + Vector2(r * 0.5, -r * 0.4), c + Vector2(-r * 0.5, -r * 0.4)]), Color("8a6a3a"))
			ci.draw_line(c + Vector2(-r * 0.5, -r * 0.4), c + Vector2(r * 0.5, -r * 0.4), Color("4a3020"), 3.0)
			ellipse(ci, c + Vector2(0, -r * 0.55), r * 0.45, r * 0.25, Color("d8702a"))
			for o in [Vector2(-0.2, -0.65), Vector2(0.15, -0.6), Vector2(0.0, -0.75)]:
				ci.draw_circle(c + o * r, r * 0.08, Color("a84a1a"))
		4:
			ellipse(ci, c + Vector2(0, r * 0.3), r * 0.9, r * 0.5, Color("f4f0e4"))
			for o in [Vector2(-0.4, 0.0), Vector2(0.1, -0.15), Vector2(0.45, 0.1), Vector2(-0.1, 0.25)]:
				ellipse(ci, c + o * r, r * 0.16, r * 0.08, Color("ffffff"))
		5:
			ci.draw_line(c + Vector2(-r * 0.2, -r * 0.8), c + Vector2(-r * 0.05, -r * 0.5), Color("3a7a2a"), 4.0)
			var pts := PackedVector2Array()
			for i in 12:
				var t := i / 11.0
				pts.append(c + Vector2(-r * 0.05 + sin(t * 2.4) * r * 0.5, -r * 0.5 + t * r * 1.4) + Vector2(r * 0.28 * (1.0 - t), 0))
			for i in range(11, -1, -1):
				var t := i / 11.0
				pts.append(c + Vector2(-r * 0.05 + sin(t * 2.4) * r * 0.5, -r * 0.5 + t * r * 1.4) - Vector2(r * 0.28 * (1.0 - t), 0))
			ci.draw_colored_polygon(pts, Color("d8302a"))


## Metni verilen genişliğe göre satırlara böler (draw_string ile çok satırlı yazı için).
static func wrap_text(text: String, font: Font, size: int, width: float) -> PackedStringArray:
	var out := PackedStringArray()
	var cur := ""
	for w in text.split(" "):
		var t := w if cur == "" else cur + " " + w
		if font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width and cur != "":
			out.append(cur)
			cur = w
		else:
			cur = t
	if cur != "":
		out.append(cur)
	return out
