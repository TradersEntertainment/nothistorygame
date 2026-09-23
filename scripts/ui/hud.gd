class_name Hud
extends CanvasLayer
## Oyun arayüzü: altyazılar, seçimler, hedef, çanta, tuş takımı, telsiz,
## kırmızı düğme, fes görünümü, karartma, başlık kartları, akış şeması, duraklatma.
## Sahneyi yöneten betik (chapter1.gd) buradaki async fonksiyonları `await` ile çağırır.

signal _choice_made(index: int)

const C_PANEL := Color(0.06, 0.07, 0.1, 0.82)
const C_ACCENT := Color("6ff2c8")
const SPEAKER_COLORS := {
	"SPK_HIKMET": Color("ffc98a"),
	"SPK_TOLGA": Color("8ecbff"),
}
const VOICE := {"SPK_HIKMET": 140.0, "SPK_TOLGA": 210.0}
const ART := "res://assets/art/"

var mumble: Mumble
var fez: FezOverlay
var bag_locked := false

var _crosshair: ColorRect
var _prompt: Label
var _objective_box: PanelContainer
var _objective: Label
var _sub_box: PanelContainer
var _sub_speaker: Label
var _sub_text: Label
var _sub_hint: Label
var _choice_box: VBoxContainer
var _choice_timer: ColorRect
var _bag_box: PanelContainer
var _bag_list: VBoxContainer
var _bag_strip: HBoxContainer
var _signal_box: HBoxContainer
var _signal_bars: Array[ColorRect] = []
var _red_bar: ColorRect
var _red_label: Label
var _keypad_box: PanelContainer
var _keypad_display: Label
var _keypad_value := ""
var _keypad_active := false
var _fade: ColorRect
var _card: VBoxContainer
var _pause_box: PanelContainer
var _controls: Label
var _bark_id := 0
var _portrait: TextureRect
var _qte: Label
var _chase_box: VBoxContainer
var _chase_bar: ColorRect
var _underwater: ColorRect
var _tolga_fez := false


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	mumble = Mumble.new()
	add_child(mumble)

	# Kenarlarda hafif karartma (bütün sahnelerde)
	var vig := ColorRect.new()
	vig.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vm := ShaderMaterial.new()
	vm.shader = load("res://assets/shaders/vignette.gdshader")
	vig.material = vm
	add_child(vig)

	fez = FezOverlay.new()
	fez.visible = false
	add_child(fez)

	_crosshair = ColorRect.new()
	_crosshair.color = Color(1, 1, 1, 0.8)
	_crosshair.size = Vector2(6, 6)
	_crosshair.set_anchors_preset(Control.PRESET_CENTER)
	_crosshair.position = Vector2(-3, -3)
	_crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_crosshair)

	_prompt = _label("", 22, Color.WHITE)
	_prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.custom_minimum_size = Vector2(700, 30)
	_prompt.position = Vector2(-350, 36)
	add_child(_prompt)

	# Hedef (sol üst)
	_objective_box = _panel()
	_objective_box.position = Vector2(24, 70)
	var ov := VBoxContainer.new()
	_objective_box.add_child(ov)
	ov.add_child(_label("", 14, C_ACCENT))
	_objective = _label("", 20, Color.WHITE)
	ov.add_child(_objective)
	_objective_box.visible = false
	add_child(_objective_box)

	# Altyazı (alt orta)
	_sub_box = _panel()
	_sub_box.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_sub_box.custom_minimum_size = Vector2(900, 0)
	var sh := HBoxContainer.new()
	sh.add_theme_constant_override("separation", 16)
	_sub_box.add_child(sh)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(112, 112)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sh.add_child(_portrait)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 4)
	sh.add_child(sv)
	_sub_speaker = _label("", 18, Color.WHITE)
	sv.add_child(_sub_speaker)
	_sub_text = _label("", 24, Color.WHITE)
	_sub_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sub_text.custom_minimum_size = Vector2(730, 0)
	sv.add_child(_sub_text)
	_sub_hint = _label("", 13, Color(1, 1, 1, 0.5))
	_sub_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sv.add_child(_sub_hint)
	_sub_box.visible = false
	add_child(_sub_box)

	# Seçimler (orta)
	_choice_box = VBoxContainer.new()
	_choice_box.set_anchors_preset(Control.PRESET_CENTER)
	_choice_box.custom_minimum_size = Vector2(520, 0)
	_choice_box.add_theme_constant_override("separation", 10)
	_choice_box.visible = false
	add_child(_choice_box)

	# Çanta şeridi (sağ üst) ve çanta paneli
	_bag_strip = HBoxContainer.new()
	_bag_strip.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_bag_strip.add_theme_constant_override("separation", 6)
	_bag_strip.visible = false
	add_child(_bag_strip)
	_bag_box = _panel()
	_bag_box.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_bag_list = VBoxContainer.new()
	_bag_list.add_theme_constant_override("separation", 6)
	_bag_box.add_child(_bag_list)
	_bag_box.visible = false
	add_child(_bag_box)

	# Telsiz sinyali (sağ alt)
	_signal_box = HBoxContainer.new()
	_signal_box.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_signal_box.add_theme_constant_override("separation", 4)
	_signal_box.alignment = BoxContainer.ALIGNMENT_END
	var sl := _label(tr("UI_SIGNAL"), 14, C_ACCENT)
	sl.size_flags_vertical = Control.SIZE_SHRINK_END
	_signal_box.add_child(sl)
	for i in 5:
		var bar := ColorRect.new()
		bar.custom_minimum_size = Vector2(8, 8 + i * 6)
		bar.size_flags_vertical = Control.SIZE_SHRINK_END
		_signal_box.add_child(bar)
		_signal_bars.append(bar)
	_signal_box.visible = false
	add_child(_signal_box)

	# Kırmızı düğme basılı tutma çubuğu
	_red_label = _label(tr("UI_RED_HOLD"), 16, Color("ff5a4a"))
	_red_label.set_anchors_preset(Control.PRESET_CENTER)
	_red_label.position = Vector2(-60, 70)
	_red_label.visible = false
	add_child(_red_label)
	_red_bar = ColorRect.new()
	_red_bar.color = Color("ff3b30")
	_red_bar.set_anchors_preset(Control.PRESET_CENTER)
	_red_bar.position = Vector2(-100, 96)
	_red_bar.size = Vector2(0, 8)
	add_child(_red_bar)

	# Tuş takımı
	_keypad_box = _panel()
	_keypad_box.set_anchors_preset(Control.PRESET_CENTER)
	var kv := VBoxContainer.new()
	kv.add_theme_constant_override("separation", 10)
	_keypad_box.add_child(kv)
	kv.add_child(_label(tr("UI_KEYPAD_TITLE"), 18, C_ACCENT))
	_keypad_display = _label("----", 72, C_ACCENT)
	_keypad_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_keypad_display.custom_minimum_size = Vector2(420, 90)
	kv.add_child(_keypad_display)
	kv.add_child(_label(tr("UI_KEYPAD_HINT"), 14, Color(1, 1, 1, 0.6)))
	_keypad_box.visible = false
	add_child(_keypad_box)

	# Kontroller ipucu (alt)
	_controls = _label("", 14, Color(1, 1, 1, 0.55))
	_controls.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_controls.position = Vector2(24, -34)
	_controls.visible = false
	add_child(_controls)

	# QTE uyarısı (büyük, sarı)
	_qte = _label("", 40, Color("ffd60a"))
	_qte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_qte.custom_minimum_size = Vector2(900, 60)
	_qte.visible = false
	add_child(_qte)

	# Kovalamaca çubuğu (üst orta)
	_chase_box = VBoxContainer.new()
	_chase_box.add_theme_constant_override("separation", 4)
	var cl := _label("", 14, Color("ff8a7a"))
	cl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_chase_box.add_child(cl)
	var track := ColorRect.new()
	track.color = Color(1, 1, 1, 0.15)
	track.custom_minimum_size = Vector2(360, 10)
	_chase_box.add_child(track)
	_chase_bar = ColorRect.new()
	_chase_bar.color = Color("ff5a4a")
	_chase_bar.size = Vector2(0, 10)
	track.add_child(_chase_bar)
	_chase_box.visible = false
	add_child(_chase_box)

	# Su altı
	_underwater = ColorRect.new()
	_underwater.color = Color(0.1, 0.35, 0.45, 0.55)
	_underwater.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_underwater.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_underwater.visible = false
	add_child(_underwater)
	# Fes püskülünün hemen üstünde, yazıların ve arayüzün altında durur
	move_child(_underwater, fez.get_index() + 1)

	# Karartma ve kartlar (en üstte)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 1)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	_card = VBoxContainer.new()
	_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_card.alignment = BoxContainer.ALIGNMENT_CENTER
	_card.add_theme_constant_override("separation", 18)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_card)

	# Duraklatma
	_pause_box = _panel()
	_pause_box.set_anchors_preset(Control.PRESET_CENTER)
	_pause_box.visible = false
	add_child(_pause_box)

	get_viewport().size_changed.connect(_relayout)
	_relayout()


# ---------------------------------------------------------------- yardımcılar

func _label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 2)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_PANEL
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(16)
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p


func _relayout() -> void:
	var vs := get_viewport().get_visible_rect().size
	_sub_box.position = Vector2((vs.x - 900) * 0.5, vs.y - 190)
	_choice_box.position = Vector2((vs.x - 520) * 0.5, vs.y * 0.5 - 40)
	_bag_strip.position = Vector2(vs.x - 5 * 58 - 24, 24)
	_bag_box.position = Vector2(vs.x - 360, vs.y * 0.5 - 170)
	_signal_box.position = Vector2(vs.x - 140, vs.y - 70)
	_keypad_box.position = Vector2((vs.x - 452) * 0.5, vs.y * 0.5 - 130)
	_pause_box.position = Vector2(vs.x * 0.5 - 360, vs.y * 0.5 - 90)
	_controls.position = Vector2(24, vs.y - 34)
	var c := vs * 0.5
	_qte.position = c + Vector2(-450, -150)
	_chase_box.position = Vector2(c.x - 180, 24)
	_crosshair.position = c - Vector2(3, 3)
	_prompt.position = c + Vector2(-350, 36)
	_red_label.position = c + Vector2(-60, 70)
	_red_bar.position = c + Vector2(-100, 96)


func _fast() -> bool:
	return GameState.autotest


# ---------------------------------------------------------------- oyun içi

func set_objective(text: String) -> void:
	_objective_box.visible = text != ""
	(_objective_box.get_child(0).get_child(0) as Label).text = tr("UI_OBJECTIVE")
	_objective.text = text


func set_prompt(text: String) -> void:
	_prompt.text = text


func show_crosshair(on: bool) -> void:
	_crosshair.visible = on


func show_controls(on: bool) -> void:
	_controls.text = tr("UI_CONTROLS")
	_controls.visible = on


func set_fez(on: bool) -> void:
	fez.visible = on
	_tolga_fez = on


func set_signal(level: int) -> void:
	_signal_box.visible = true
	for i in _signal_bars.size():
		_signal_bars[i].color = C_ACCENT if i < level else Color(1, 1, 1, 0.18)


func set_qte(text: String) -> void:
	_qte.text = text
	_qte.visible = text != ""


## Kovalayanın yakınlığı: 0 (uzak) .. 1 (yakaladı)
func set_chase(label_text: String, v: float) -> void:
	_chase_box.visible = label_text != ""
	(_chase_box.get_child(0) as Label).text = label_text
	_chase_bar.size = Vector2(360.0 * clampf(v, 0.0, 1.0), 10)
	_chase_bar.color = Color("ff5a4a") if v > 0.6 else Color("ffb13b")


func set_underwater(on: bool) -> void:
	_underwater.visible = on


## "Bütçe yetmedi" haritası: ok çizilir, Hikmet yorum yapar.
func budget_map(title_text: String, from_text: String, to_text: String, seconds := 3.0) -> void:
	var m := BudgetMap.new()
	m.title = title_text
	m.from_label = from_text
	m.to_label = to_text
	add_child(m)
	move_child(m, _fade.get_index())
	if _fast():
		m.progress = 1.0
		await get_tree().process_frame
		m.queue_free()
		return
	var tw := create_tween()
	tw.tween_property(m, "progress", 1.0, seconds * 0.7)
	await get_tree().create_timer(seconds).timeout
	m.queue_free()


func set_red_progress(v: float) -> void:
	_red_label.visible = v > 0.0
	_red_bar.size = Vector2(200.0 * clampf(v, 0.0, 1.0), 8)


func update_bag(bag: Array) -> void:
	for c in _bag_strip.get_children():
		c.queue_free()
	_bag_strip.visible = true
	for i in 5:
		var slot := ColorRect.new()
		slot.custom_minimum_size = Vector2(52, 52)
		slot.color = Color(1, 1, 1, 0.08)
		if i < bag.size():
			slot.color = Color(0, 0, 0, 0)
			var ic := TextureRect.new()
			ic.texture = load(ART + "icons/%s.svg" % bag[i])
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ic.size = Vector2(52, 52)
			slot.add_child(ic)
			var l := _label(str(i + 1), 13, Color("1d2330"))
			l.remove_theme_color_override("font_shadow_color")
			slot.add_child(l)
			l.position = Vector2(8, 5)
		_bag_strip.add_child(slot)
	# Açık çanta paneli
	for c in _bag_list.get_children():
		c.queue_free()
	_bag_list.add_child(_label(tr("UI_BAG_TITLE") + "  %d/5" % bag.size(), 18, C_ACCENT))
	for i in 5:
		var txt := "%d. %s" % [i + 1, tr(Items.name_key(bag[i])) if i < bag.size() else tr("UI_BAG_EMPTY")]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var ic2 := TextureRect.new()
		ic2.custom_minimum_size = Vector2(34, 34)
		ic2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if i < bag.size():
			ic2.texture = load(ART + "icons/%s.svg" % bag[i])
		row.add_child(ic2)
		row.add_child(_label(txt, 18, Color.WHITE if i < bag.size() else Color(1, 1, 1, 0.4)))
		_bag_list.add_child(row)
	_bag_list.add_child(_label(tr("UI_BAG_LOCKED") if bag_locked else tr("UI_BAG_HINT"), 13, Color(1, 1, 1, 0.6)))


func toggle_bag(open: bool) -> void:
	_bag_box.visible = open


func is_bag_open() -> bool:
	return _bag_box.visible


# ---------------------------------------------------------------- diyalog

## Engelleyen replik: oyuncu devam tuşuna basana kadar bekler.
func say(speaker_key: String, text_key: String) -> void:
	_show_line(speaker_key, tr(text_key), true)
	if _fast():
		await get_tree().process_frame
		_sub_box.visible = false
		return
	var text_len := _sub_text.text.length()
	var dur := clampf(text_len * 0.028, 0.4, 2.2)
	mumble.speak(dur, VOICE.get(speaker_key, 180.0))
	var tw := create_tween()
	_sub_text.visible_ratio = 0.0
	tw.tween_property(_sub_text, "visible_ratio", 1.0, dur)
	await get_tree().create_timer(0.2).timeout
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("advance"):
			if _sub_text.visible_ratio < 1.0:
				tw.kill()
				_sub_text.visible_ratio = 1.0
				mumble.stop_speaking()
			else:
				break
	mumble.stop_speaking()
	_sub_box.visible = false


## Engellemeyen replik: kendi kendine kaybolur (eşya yorumları gibi).
func bark(speaker_key: String, text_key: String, seconds := 4.0) -> void:
	_bark_id += 1
	var my_id := _bark_id
	_show_line(speaker_key, tr(text_key), false)
	_sub_text.visible_ratio = 1.0
	if not _fast():
		mumble.speak(minf(1.6, _sub_text.text.length() * 0.028), VOICE.get(speaker_key, 180.0))
	await get_tree().create_timer(0.01 if _fast() else seconds).timeout
	if my_id == _bark_id:
		_sub_box.visible = false


func _show_line(speaker_key: String, text: String, blocking: bool) -> void:
	_sub_speaker.text = tr(speaker_key)
	var pic := ""
	match speaker_key:
		"SPK_HIKMET":
			pic = "portraits/hikmet.svg"
		"SPK_TOLGA":
			pic = "portraits/tolga_fez.svg" if _tolga_fez else "portraits/tolga.svg"
	_portrait.texture = load(ART + pic) if pic != "" else null
	_portrait.visible = pic != ""
	_sub_speaker.add_theme_color_override("font_color", SPEAKER_COLORS.get(speaker_key, Color.WHITE))
	_sub_text.text = text
	_sub_hint.text = tr("UI_CONTINUE") if blocking else ""
	_sub_box.visible = true
	_relayout()


## Süreli (timeout > 0) ya da süresiz seçim. Seçilen dizini, süre dolarsa -1 döner.
func choose(option_keys: Array, timeout := 0.0, autotest_pick := 0) -> int:
	for c in _choice_box.get_children():
		c.queue_free()
	for i in option_keys.size():
		var b := Button.new()
		b.text = "%d.  %s" % [i + 1, tr(option_keys[i])]
		b.add_theme_font_size_override("font_size", 22)
		b.custom_minimum_size = Vector2(520, 52)
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(func(): _choice_made.emit(i))
		_choice_box.add_child(b)
	_choice_timer = ColorRect.new()
	_choice_timer.color = Color("ff5a4a")
	_choice_timer.custom_minimum_size = Vector2(520, 6)
	_choice_box.add_child(_choice_timer)
	_choice_timer.visible = timeout > 0.0
	_choice_box.visible = true
	if _fast():
		await get_tree().process_frame
		_choice_box.visible = false
		return autotest_pick
	var prev_mouse := Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var result := -1
	var left := timeout
	var picked := [-1]
	var cb := func(i: int): picked[0] = i
	_choice_made.connect(cb)
	while true:
		await get_tree().process_frame
		for i in option_keys.size():
			if Input.is_action_just_pressed("choice_%d" % (i + 1)):
				picked[0] = i
		if picked[0] >= 0:
			result = picked[0]
			break
		if timeout > 0.0:
			left -= get_process_delta_time()
			_choice_timer.custom_minimum_size.x = 520.0 * maxf(0.0, left / timeout)
			if left <= 0.0:
				break
	_choice_made.disconnect(cb)
	_choice_box.visible = false
	Input.mouse_mode = prev_mouse
	return result


## Açık bir seçimi kapatır (ekran görüntüsü modu için).
func choose_cancel() -> void:
	_choice_box.visible = false


# ---------------------------------------------------------------- tuş takımı

func keypad(autotest_value := "1453") -> String:
	_keypad_value = ""
	_keypad_display.text = "----"
	_keypad_box.visible = true
	if _fast():
		await get_tree().process_frame
		_keypad_box.visible = false
		return autotest_value
	_keypad_active = true
	while _keypad_active:
		await get_tree().process_frame
	_keypad_box.visible = false
	return _keypad_value


func keypad_visible(on: bool) -> void:
	_keypad_box.visible = on


func keypad_show(text: String) -> void:
	_keypad_display.text = text


func _input(event: InputEvent) -> void:
	if not _keypad_active or not (event is InputEventKey) or not event.pressed:
		return
	var k: int = event.physical_keycode
	if k >= KEY_0 and k <= KEY_9 and _keypad_value.length() < 4:
		_keypad_value += str(k - KEY_0)
	elif k >= KEY_KP_0 and k <= KEY_KP_9 and _keypad_value.length() < 4:
		_keypad_value += str(k - KEY_KP_0)
	elif k == KEY_BACKSPACE and _keypad_value.length() > 0:
		_keypad_value = _keypad_value.left(_keypad_value.length() - 1)
	elif (k == KEY_ENTER or k == KEY_KP_ENTER) and _keypad_value.length() == 4:
		_keypad_active = false
	_keypad_display.text = _keypad_value + "-".repeat(4 - _keypad_value.length())
	get_viewport().set_input_as_handled()


# ---------------------------------------------------------------- karartma ve kartlar

func fade_to(alpha: float, seconds: float, color := Color.BLACK) -> void:
	_fade.color = Color(color.r, color.g, color.b, _fade.color.a)
	if _fast():
		_fade.color.a = alpha
		return
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", alpha, seconds)
	await tw.finished


func set_fade(alpha: float, color := Color.BLACK) -> void:
	_fade.color = Color(color.r, color.g, color.b, alpha)


## Siyah ekranda ortalanmış satırlar. lines: [[metin, boyut, renk], ...]
func card(lines: Array, hold: float) -> void:
	clear_card()
	for spec in lines:
		var l := _label(spec[0], spec[1], spec[2] if spec.size() > 2 else Color.WHITE)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.modulate.a = 0.0
		_card.add_child(l)
		if not _fast():
			create_tween().tween_property(l, "modulate:a", 1.0, 0.6)
	if not _fast():
		await get_tree().create_timer(hold).timeout


func add_card_line(text: String, font_size: int, color := Color.WHITE) -> Label:
	var l := _label(text, font_size, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card.add_child(l)
	return l


func clear_card() -> void:
	for c in _card.get_children():
		c.queue_free()


## Açılış uyarısı ve başlık (GDD §9.0). Dil L ile değiştirilebilir.
func title_screen() -> void:
	set_fade(1.0)
	await card([[tr("UI_DISCLAIMER_1"), 40]], 2.2)
	var l2 := add_card_line(tr("UI_DISCLAIMER_2"), 22, Color(1, 1, 1, 0.7))
	if not _fast():
		await get_tree().create_timer(2.0).timeout
	l2.queue_free()
	clear_card()
	if not _fast():
		await get_tree().create_timer(0.4).timeout
	var logo := TextureRect.new()
	logo.texture = load(ART + "posters/fez.svg")
	logo.custom_minimum_size = Vector2(0, 130)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_card.add_child(logo)
	var t := add_card_line(tr("UI_TITLE"), 64, Color("f2e6c9"))
	var hint := add_card_line(tr("UI_PRESS_ANY"), 20, Color(1, 1, 1, 0.7))
	var lang := add_card_line(tr("UI_LANG_HINT"), 16, C_ACCENT)
	if _fast():
		clear_card()
		return
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("language"):
			GameState.toggle_locale()
			t.text = tr("UI_TITLE")
			hint.text = tr("UI_PRESS_ANY")
			lang.text = tr("UI_LANG_HINT")
		elif Input.is_anything_pressed() and not Input.is_action_pressed("language"):
			break
	clear_card()


# ---------------------------------------------------------------- akış şeması

## Bölüm sonu akış şeması. "next", "replay" ya da "quit" döner.
func show_flowchart(chart: Flowchart, can_continue := false) -> String:
	add_child(chart)
	move_child(chart, get_child_count() - 1)
	if _fast():
		await get_tree().process_frame
		return "quit"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().create_timer(0.4).timeout
	while true:
		await get_tree().process_frame
		if can_continue and Input.is_action_just_pressed("continue"):
			chart.queue_free()
			return "next"
		if Input.is_action_just_pressed("red_button"):
			return "replay"
		if Input.is_action_just_pressed("quit"):
			return "quit"
	return "quit"


# ---------------------------------------------------------------- duraklatma

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not _keypad_active:
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()
	elif get_tree().paused:
		if event.is_action_pressed("language"):
			GameState.toggle_locale()
			_fill_pause()
		elif event.is_action_pressed("quit"):
			get_tree().quit()


func _set_paused(on: bool) -> void:
	get_tree().paused = on
	_pause_box.visible = on
	if on:
		_fill_pause()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _fill_pause() -> void:
	for c in _pause_box.get_children():
		c.queue_free()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_pause_box.add_child(v)
	v.add_child(_label(tr("UI_PAUSE"), 32, C_ACCENT))
	var controls := _label(tr("UI_CONTROLS"), 16, Color.WHITE)
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.custom_minimum_size = Vector2(680, 0)
	v.add_child(controls)
	v.add_child(_label(tr("UI_PAUSE_HINT"), 18, Color(1, 1, 1, 0.7)))
