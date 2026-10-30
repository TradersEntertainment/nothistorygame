class_name PhoneScreen
extends Node3D
## Elde tutulan telefonun ekranı (kullanıcı: "telefon ekranı boş olmasın, sekme değişebilsin yerine göre"). Küçük bir
## SubViewport'ta durum çubuğu (saat ya da yıl, sinyal, %14 pil: Tolga'nın "yüzde on dört" şakası), içerik ve alt sekme
## çubuğu. Elde dururken sekmeler kendiliğinden döner. İçerik bölüme göre değişir: harita sekmesinde bölümün tarihi ve
## yeri (UI_CH<n>_SUB), notlarda o anki hedef, mesajlarda annesi, operatör, sigorta şubesi. Telefon kullanılınca (fener)
## fener sekmesi açılır. Items.build("phone") modelinin ekran yüzüne (+Y) oturur.

const TABS := ["map", "notes", "msg", "torch"]
const TAB_KEYS := {"map": "UI_PHONE_MAP", "notes": "UI_PHONE_NOTES", "msg": "UI_PHONE_MSG", "torch": "UI_PHONE_TORCH"}
const W := 180
const H := 334
const ROTATE_S := 6.0

var tab := "map"
var _vp: SubViewport
var _t := 0.0
var _poll := 0.0
var _torch_t := 0.0
var _place := ""
var _time := ""
var _past := true
var _note := ""
var _msg_i := 0


func _init() -> void:
	name = "PhoneScreen"


func _ready() -> void:
	_vp = SubViewport.new()
	_vp.size = Vector2i(W, H)
	_vp.gui_disable_input = true
	_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(_vp)
	var q := QuadMesh.new()
	q.size = Vector2(0.14, 0.26)
	var mi := MeshInstance3D.new()
	mi.mesh = q
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_texture = _vp.get_texture()
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Dörtgen +Z'ye bakar: ekran yüzüne (+Y) çevrilir, üst kenarı telefonun üstüne (-Z)
	mi.position = Vector3(0, 0.0245, 0)
	mi.rotation_degrees = Vector3(-90, 0, 0)
	add_child(mi)
	_read_place()
	_note = _objective()
	tab = "notes" if _note != "" else "map"
	_draw()


## Bölümün tarihi ve yeri bölüm kartından (UI_CH9_SUB: "Tolga · 25 Nisan 1453, sabah")
func _read_place() -> void:
	var sc := get_tree().current_scene if is_inside_tree() else null
	var f := sc.scene_file_path.get_file().get_basename() if sc else ""
	var key := "UI_CH%s_SUB" % f.trim_prefix("chapter").to_upper()
	var s := tr(key) if f.begins_with("chapter") else ""
	if s == key:
		s = ""
	_place = s.get_slice(" · ", 1) if " · " in s else s
	_past = not f in ["chapter0", "chapter1"]
	var rx := RegEx.create_from_string("\\d\\d:\\d\\d")
	var mt := rx.search(_place)
	_time = mt.get_string() if mt else ("1453" if _past else "--:--")


func _objective() -> String:
	var hud := get_tree().get_first_node_in_group("hud") if is_inside_tree() else null
	var o = hud.get("_objective") if hud else null
	return (o as Label).text if o is Label and (o as Label).is_visible_in_tree() else ""


## Telefonu kullanınca: fener sekmesi (secs sonra eski içeriğe döner)
func show_torch(secs: float) -> void:
	_torch_t = secs
	tab = "torch"
	_draw()


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	if _torch_t > 0.0:
		_torch_t -= delta
		if _torch_t <= 0.0:
			_t = 0.0
			tab = "map"
			_draw()
		return
	_t += delta
	_poll -= delta
	if _poll <= 0.0:
		_poll = 1.0
		var n := _objective()
		if n != _note:
			_note = n
			if tab == "notes":
				_draw()
	if _t >= ROTATE_S:
		_t = 0.0
		var order := ["map", "notes", "msg"]
		tab = order[(order.find(tab) + 1) % order.size()]
		_draw()


func _label(p: Control, text: String, size: int, col: Color, pos: Vector2, w := 0.0, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.horizontal_alignment = align
	if w <= 0.0:
		l.position = pos
		p.add_child(l)
		return l
	# Sabit genişlik bir kapsayıcıyla: kapsayıcısız etiket satır kaydırmayıp metin boyuna uzuyordu
	var box := VBoxContainer.new()
	box.position = pos
	box.size = Vector2(w, 0)
	p.add_child(box)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(l)
	return l


func _rect(p: Control, pos: Vector2, size: Vector2, col: Color) -> ColorRect:
	var r := ColorRect.new()
	r.position = pos
	r.size = size
	r.color = col
	p.add_child(r)
	return r


func _draw() -> void:
	if _vp == null:
		return
	for c in _vp.get_children():
		c.queue_free()
	var root := Control.new()
	root.size = Vector2(W, H)
	_vp.add_child(root)
	var dark := tab == "torch"
	_rect(root, Vector2.ZERO, Vector2(W, H), Color("0d0f14") if dark else Color("f4f6fa"))
	# Durum çubuğu
	var bar_c := Color("e8ecf2") if dark else Color("1b1e26")
	_label(root, _time, 13, bar_c, Vector2(10, 4))
	_label(root, tr("UI_PHONE_NOSIGNAL") if _past else "▂▄▆", 11, Color("e05050") if _past else bar_c, Vector2(62, 6))
	_rect(root, Vector2(W - 34, 8), Vector2(20, 10), bar_c)
	_rect(root, Vector2(W - 33, 9), Vector2(18, 8), Color("0d0f14") if dark else Color("f4f6fa"))
	_rect(root, Vector2(W - 33, 9), Vector2(3, 8), Color("e05050"))          # %14
	_rect(root, Vector2(W - 14, 11), Vector2(2, 4), bar_c)
	var top := 28.0
	var body_h := H - top - 34.0
	match tab:
		"map":
			_label(root, tr("UI_PHONE_MAP"), 20, Color("1b1e26"), Vector2(12, top))
			var m := Control.new()
			m.position = Vector2(10, top + 26)
			m.size = Vector2(W - 20, 170)
			m.clip_contents = true
			root.add_child(m)
			_rect(m, Vector2.ZERO, m.size, Color("e9e1c9"))
			_rect(m, Vector2(0, 112), Vector2(m.size.x, 58), Color("8cbbe0"))          # deniz
			_rect(m, Vector2(96, 0), Vector2(22, 118), Color("8cbbe0"))                # Haliç
			for k in 4:
				_rect(m, Vector2(8 + k * 22, 0), Vector2(3, 112), Color("d6cba9"))     # sokaklar
			_rect(m, Vector2(0, 52), Vector2(96, 3), Color("d6cba9"))
			_rect(m, Vector2(0, 104), Vector2(96, 6), Color("8a7a5a"))                 # sur
			_rect(m, Vector2(52, 58), Vector2(16, 16), Color("e04040"))                # konum
			_rect(m, Vector2(58, 74), Vector2(4, 10), Color("e04040"))
			_label(root, _place, 16, Color("1b1e26"), Vector2(12, top + 202), W - 24)
			if _past:
				_label(root, tr("UI_PHONE_GPS"), 13, Color("7a8090"), Vector2(12, top + 244), W - 24)
		"notes":
			_label(root, tr("UI_PHONE_NOTES"), 20, Color("1b1e26"), Vector2(12, top))
			_rect(root, Vector2(10, top + 26), Vector2(W - 20, body_h - 30), Color("fff6c8"))
			_label(root, _note if _note != "" else tr("UI_PHONE_NO_NOTES"), 19, Color("3a3320"), Vector2(18, top + 34), W - 36)
		"msg":
			_label(root, tr("UI_PHONE_MSG"), 20, Color("1b1e26"), Vector2(12, top))
			# İki mesaj görünür; her dönüşte sıradaki ikili (üç mesaj döner)
			var y := top + 30.0
			for k in 2:
				var i := (_msg_i + k) % 3
				_rect(root, Vector2(10, y), Vector2(W - 24, 112), Color("dfe7f3") if i != 1 else Color("e6f4e1"))
				_label(root, tr("UI_PHONE_MSG_%d" % (i + 1)), 15, Color("1b1e26"), Vector2(16, y + 4), W - 36)
				y += 122.0
			_msg_i += 1
		"torch":
			_rect(root, Vector2(W * 0.5 - 40, top + 60), Vector2(80, 80), Color("fff8d8"))
			_rect(root, Vector2(W * 0.5 - 30, top + 70), Vector2(60, 60), Color("ffffff"))
			_label(root, tr("UI_PHONE_TORCH_ON"), 15, Color("e8ecf2"), Vector2(0, top + 160), W, HORIZONTAL_ALIGNMENT_CENTER)
	# Sekme çubuğu: etkin sekme vurgulu
	_rect(root, Vector2(0, H - 34), Vector2(W, 34), Color("1b1e26") if dark else Color("e3e7ee"))
	var cw := W / float(TABS.size())
	for i in TABS.size():
		var on: bool = TABS[i] == tab
		if on:
			_rect(root, Vector2(i * cw + 4, H - 31), Vector2(cw - 8, 28), Color("3d7be0"))
		_label(root, tr(TAB_KEYS[TABS[i]]), 10, Color.WHITE if on else (Color("9aa3b3") if dark else Color("4a5060")),
			Vector2(i * cw, H - 25), cw, HORIZONTAL_ALIGNMENT_CENTER)
	_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
