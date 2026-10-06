class_name WorldMap
extends Control
## Büyük harita (v0.90, M / kolda D-pad aşağı): oyun durur, 1453 İstanbul'u ekranı doldurur. Oyuncunun yeri ve yönü,
## hedef, bölge adları, tarihî yapılar (keşfedilenler adıyla, keşfedilmeyenler "?"; adlar yakınlaşınca, uzaktayken imlecin
## yanındaki yapının adı). Tekerlek / tetikler yakınlaştırır (imlecin altında), sürükleme / sol çubuk kaydırır, Boşluk / A
## oyuncuya ortalar, M / Esc / B kapatır.

signal closed

const ZOOM_MIN := 1.0          # harita ekrana sığar
const ZOOM_MAX := 6.0
const NAMES_AT := 2.2          # bu yakınlıktan sonra bütün yapı adları yazılır
const GOLD := Color("ffd24a")
const INK := Color("2a2018")
const PAPER := Color("efe4c6")
const FRAME := Color("6a4e34")

var hud: Hud
var title_font: Font
var _font: Font
var _view: Control
var _field: Node3D
var _zoom := 1.0
var _center := Vector2(MapView.W, MapView.H) * 0.5     # görünümün ortasındaki harita pikseli
var _drag := false
var _player_px := Vector2.ZERO
var _player_ang := 0.0
var _obj_px: Variant = null
var _marks: Array = []
var _hover := -1
var _t := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = ThemeDB.fallback_font
	if title_font == null:
		title_font = _font
	_view = Control.new()
	_view.clip_contents = true
	_view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS   # uzaklaşınca sokaklar titremesin
	_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_view.draw.connect(_draw_view)
	add_child(_view)
	_field = MapView.field(get_tree())
	var pl := get_tree().get_first_node_in_group("player") as Node3D
	if _field and pl:
		_player_px = MapView.world_pixel(MapView.to_world(_field, pl.global_position))
		_player_ang = MapView.heading(_field, pl.global_transform.basis)
		var t = hud.marker.target_position() if hud and hud.marker else null
		if t is Vector3:
			_obj_px = MapView.world_pixel(MapView.to_world(_field, t))
	_marks = MapView.landmarks()
	# Açılışta oyuncunun çevresi: yapı adlarının yazıldığı yakınlıkta, oyuncu ortada
	_zoom = NAMES_AT
	_center = _player_px
	_layout()
	get_viewport().size_changed.connect(_layout)


func _layout() -> void:
	var vs := get_viewport_rect().size
	_view.position = Vector2(40, 74)
	_view.size = vs - Vector2(80, 74 + 64)
	_clamp_center()
	queue_redraw()
	_view.queue_redraw()


## Ekran ölçeği: harita pikseli başına ekran pikseli
func _scale() -> float:
	return minf(_view.size.x / MapView.W, _view.size.y / MapView.H) * _zoom


func _to_view(px: Vector2) -> Vector2:
	return _view.size * 0.5 + (px - _center) * _scale()


func _from_view(vp: Vector2) -> Vector2:
	return _center + (vp - _view.size * 0.5) / _scale()


func _clamp_center() -> void:
	var half := _view.size * 0.5 / _scale()
	var lo := Vector2(minf(half.x, MapView.W * 0.5), minf(half.y, MapView.H * 0.5))
	var hi := Vector2(MapView.W, MapView.H) - lo
	_center = Vector2(clampf(_center.x, lo.x, maxf(lo.x, hi.x)), clampf(_center.y, lo.y, maxf(lo.y, hi.y)))


func _zoom_at(vp: Vector2, factor: float) -> void:
	var before := _from_view(vp)
	_zoom = clampf(_zoom * factor, ZOOM_MIN, ZOOM_MAX)
	var after := _from_view(vp)
	_center += before - after
	_clamp_center()


func _close() -> void:
	set_process(false)
	closed.emit()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		var vp := mb.position - _view.position
		if mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at(vp, 1.15)
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at(vp, 1.0 / 1.15)
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			_drag = mb.pressed
		accept_event()
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _drag:
			_center -= mm.relative / _scale()
			_clamp_center()
		_pick_hover(mm.position - _view.position)
		accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("map") or event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel") \
			or (event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed
				and (event as InputEventJoypadButton).button_index == JOY_BUTTON_B):
		get_viewport().set_input_as_handled()
		_close()
	elif event.is_action_pressed("jump") or (event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed
			and (event as InputEventJoypadButton).button_index == JOY_BUTTON_A):
		get_viewport().set_input_as_handled()
		_center = _player_px
		_clamp_center()


func _process(delta: float) -> void:
	_t += delta
	# Kol: sol çubuk kaydırır, tetikler yakınlaştırır; klavye: WASD / oklar kaydırır
	var mv := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if mv.length() > 0.15:
		_center += mv * delta * 700.0 / _scale()
		_clamp_center()
		_pick_hover(_view.size * 0.5)
	var zin := Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT)
	var zout := Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT)
	if zin > 0.2 or zout > 0.2:
		_zoom_at(_view.size * 0.5, pow(1.8, (zin - zout) * delta * 2.0))
	queue_redraw()
	_view.queue_redraw()


## İmlecin (ya da kolda ortanın) yanındaki yapı: uzaktayken yalnız onun adı yazılır
func _pick_hover(vp: Vector2) -> void:
	_hover = -1
	var best := 26.0
	for i in _marks.size():
		var d := _to_view(_marks[i]["px"]).distance_to(vp)
		if d < best:
			best = d
			_hover = i


func _draw() -> void:
	var vs := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0.04, 0.03, 0.02, 0.86))
	# Başlık ve çerçeve
	var title := tr("UI_MAP_TITLE")
	var ts := title_font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 34)
	draw_string(title_font, Vector2((vs.x - ts.x) * 0.5, 52), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, PAPER)
	var fr := Rect2(_view.position - Vector2(6, 6), _view.size + Vector2(12, 12))
	draw_rect(fr, FRAME, false, 6.0)
	draw_rect(fr.grow(-3.0), Color(PAPER, 0.5), false, 1.0)
	# Alt satır: keşif sayısı ve tuşlar
	var seen := 0
	for m: Dictionary in _marks:
		if m["seen"]:
			seen += 1
	var info := tr("UI_MAP_FOUND") % [seen, _marks.size()]
	draw_string(_font, Vector2(46, vs.y - 26), info, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(PAPER, 0.85))
	var hint := tr("UI_MAP_HINT_PAD" if GameState.pad else "UI_MAP_HINT")
	var hs := _font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	draw_string(_font, Vector2(vs.x - 46 - hs.x, vs.y - 26), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(PAPER, 0.7))


func _label(c: Control, text: String, at: Vector2, fs: int, col: Color, ang := 0.0) -> void:
	var sz := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	c.draw_set_transform(at, ang)
	var o := Vector2(-sz.x * 0.5, fs * 0.35)
	c.draw_string_outline(_font, o, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(PAPER, 0.85))
	c.draw_string(_font, o, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
	c.draw_set_transform(Vector2.ZERO, 0.0)


func _draw_view() -> void:
	var v := _view
	var tex := MapView.texture()
	# Haritanın dışı koyu (deniz rengi olursa ovanın ve Asya'nın ötesi denizmiş gibi görünüyordu)
	v.draw_rect(Rect2(Vector2.ZERO, v.size), Color("1d1812"))
	if tex:
		var tr_rect := Rect2(_to_view(Vector2.ZERO), Vector2(MapView.W, MapView.H) * _scale())
		v.draw_texture_rect(tex, tr_rect, false)
		v.draw_rect(tr_rect, Color(INK, 0.8), false, 2.0)
	var k := clampf(_zoom / 2.0, 0.8, 1.5)
	# Bölge adları
	for r: Array in MapView.REGION_LABELS:
		var p := _to_view(MapView.world_pixel(r[1]))
		_label(v, tr(r[0]), p, int(float(r[2]) * k), Color(INK, 0.75), float(r[3]))
	# Tarihî yapılar
	for i in _marks.size():
		var m: Dictionary = _marks[i]
		var p := _to_view(m["px"])
		if not Rect2(Vector2(-40, -40), v.size + Vector2(80, 80)).has_point(p):
			continue
		if m["seen"]:
			v.draw_circle(p, 5.0, Color("9a3a2a"))
			v.draw_arc(p, 5.0, 0.0, TAU, 16, PAPER, 1.5, true)
			if _zoom >= NAMES_AT or i == _hover:
				_label(v, tr(m["name_key"]), p + Vector2(0, -14), int(14 * k), INK)
		else:
			v.draw_circle(p, 7.0, Color(INK, 0.55))
			_label(v, "?", p + Vector2(0, 1), 13, PAPER)
			if i == _hover:
				_label(v, tr("UI_MAP_UNKNOWN"), p + Vector2(0, -16), int(13 * k), Color(INK, 0.8))
	# Hedef
	if _obj_px is Vector2:
		var p := _to_view(_obj_px)
		var dm := PackedVector2Array([p + Vector2(0, -11), p + Vector2(9, 0), p + Vector2(0, 11), p + Vector2(-9, 0)])
		v.draw_colored_polygon(dm, GOLD)
		dm.append(dm[0])
		v.draw_polyline(dm, INK, 2.0, true)
	# Oyuncu: yönlü ok ve nabız halkası
	var pp := _to_view(_player_px)
	var pulse := fmod(_t, 1.4) / 1.4
	v.draw_arc(pp, 8.0 + pulse * 18.0, 0.0, TAU, 32, Color(1, 1, 1, 0.6 * (1.0 - pulse)), 2.0, true)
	var fwd := Vector2(sin(_player_ang), -cos(_player_ang))
	var rt := Vector2(-fwd.y, fwd.x)
	var arrow := PackedVector2Array([pp + fwd * 12.0, pp - fwd * 8.0 + rt * 8.0, pp - fwd * 4.0, pp - fwd * 8.0 - rt * 8.0])
	v.draw_colored_polygon(arrow, Color.WHITE)
	arrow.append(arrow[0])
	v.draw_polyline(arrow, INK, 2.0, true)
