class_name GameMenu
extends Control
## Ana menü (Hikmet'in garajında) ve duraklatma menüsü: devam, yeni oyun, bölümler,
## kayıt yuvaları, ayarlar. Seçim picked sinyaliyle bildirilir; sahne değişimini Hud yapar.
##   main  : continue, new, load(slot), chapter(n), quit
##   pause : resume, chapter(n), load(slot), main_menu, quit

signal picked(action: String, arg: int)

const C_CREAM := Color("f2e6c9")
const C_ACCENT := Color("6ff2c8")
const C_DIM := Color(1, 1, 1, 0.6)
const COVERS := {1: "ch1", 2: "ch2", 3: "ch3", 4: "ch4a", 5: "ch5", 6: "ch6a", 7: "ch7", 8: "ch8", 9: "ch9",
	10: "ch10", 11: "ch11", 12: "ch12", 13: "ch13", 14: "ch14", 15: "ch15"}

var mode := "main"
var title_font: Font
var _panel: PanelContainer
var _box: VBoxContainer
var _on_root := true
var _auto: Dictionary = {}


func _init(p_mode := "main") -> void:
	mode = p_mode


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Arka plan: ana menüde soldan karartan degrade (garaj sağda görünür), duraklatmada düz karartma
	if mode == "main":
		if ResourceLoader.exists("res://assets/art/covers/menu_bg.png"):
			var pic := TextureRect.new()
			pic.texture = load("res://assets/art/covers/menu_bg.png")
			pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pic.modulate.a = 0.0
			add_child(pic)
			create_tween().tween_property(pic, "modulate:a", 1.0, 0.8)
		var g := Gradient.new()
		g.set_color(0, Color(0.03, 0.03, 0.05, 0.92))
		g.set_color(1, Color(0.03, 0.03, 0.05, 0.0))
		var gt := GradientTexture2D.new()
		gt.gradient = g
		gt.fill_from = Vector2(0.25, 0)
		gt.fill_to = Vector2(0.75, 0)
		var bg := TextureRect.new()
		bg.texture = gt
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg)
	else:
		var dim := ColorRect.new()
		dim.color = Color(0, 0, 0, 0.6)
		dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(dim)
	_panel = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.06, 0.09, 0.0 if mode == "main" else 0.9)
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(28)
	_panel.add_theme_stylebox_override("panel", sb)
	add_child(_panel)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 10)
	_panel.add_child(_box)
	get_viewport().size_changed.connect(_layout)
	if mode == "main":
		_auto = GameState.read_auto()
	show_root()


func _layout() -> void:
	var vs := get_viewport().get_visible_rect().size
	_panel.reset_size()
	var ps := _panel.get_combined_minimum_size()
	var x := 80.0 if (mode == "main" and _on_root) else (vs.x - ps.x) * 0.5
	var sb := _panel.get_theme_stylebox("panel") as StyleBoxFlat
	sb.bg_color.a = 0.0 if (mode == "main" and _on_root) else 0.92
	_panel.position = Vector2(x, maxf(20.0, (vs.y - ps.y) * 0.5))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		if not _on_root:
			Audio.sfx("ui_select", -10.0)
			show_root()
		elif mode == "pause":
			picked.emit("resume", 0)


# ---------------------------------------------------------------- yapı taşları

func _clear(root: bool) -> void:
	_on_root = root
	for c in _box.get_children():
		_box.remove_child(c)
		c.queue_free()


func _label(text: String, size: int, color := C_CREAM, font: Font = null) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_y", 2)
	if font != null:
		l.add_theme_font_override("font", font)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(l)
	return l


func _style(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(8)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	s.border_width_left = 4
	s.border_color = border
	return s


func _button(text: String, cb: Callable, enabled := true, parent: Control = null, size := 24) -> Button:
	var b := Button.new()
	b.text = text
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(420, 0)
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", C_CREAM)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_focus_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.3))
	b.add_theme_stylebox_override("normal", _style(Color(1, 1, 1, 0.05), Color(0, 0, 0, 0)))
	b.add_theme_stylebox_override("hover", _style(Color(1, 1, 1, 0.14), C_ACCENT))
	b.add_theme_stylebox_override("focus", _style(Color(1, 1, 1, 0.14), C_ACCENT))
	b.add_theme_stylebox_override("pressed", _style(Color(0.43, 0.95, 0.78, 0.25), C_ACCENT))
	b.add_theme_stylebox_override("disabled", _style(Color(1, 1, 1, 0.02), Color(0, 0, 0, 0)))
	b.disabled = not enabled
	b.pressed.connect(func():
		Audio.sfx("ui_confirm", -8.0)
		cb.call())
	b.mouse_entered.connect(func():
		if not b.disabled:
			b.grab_focus())
	b.focus_entered.connect(func(): Audio.sfx("ui_select", -16.0))
	(parent if parent != null else _box).add_child(b)
	return b


func _spacer(h: float) -> void:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	_box.add_child(c)


func _finish_page() -> void:
	_layout.call_deferred()
	for c in _box.get_children():
		if c is Button and not (c as Button).disabled:
			(c as Button).grab_focus.call_deferred()
			return


## Bölüm adı; dal bölümlerinde (chapter10b gibi) sahne adından.
static func chapter_title(n: int, scene := "") -> String:
	var keys: Array = ["UI_CH%d_TITLE" % n, "UI_CH%dA_TITLE" % n, "UI_CH%dO_TITLE" % n]
	var base := scene.get_file().get_basename()
	if base.begins_with("chapter") and not base.trim_prefix("chapter").is_valid_int():
		keys.push_front("UI_CH%s_TITLE" % base.trim_prefix("chapter").to_upper())
	for k in keys:
		var t: String = String(TranslationServer.translate(k))
		if t != k:
			# "BÖLÜM 9 — TEKLİFLER" → "Teklifler"
			if "—" in t:
				t = t.split("—")[-1].strip_edges()
			if t != t.to_upper():
				return t
			var out := t.substr(0, 1)
			for i in range(1, t.length()):
				var prev: String = t[i - 1]
				out += t[i] if (prev.is_valid_int() or prev == "-") else t[i].to_lower()
			return out
	return "%d" % n


static func _time_text(sec: float) -> String:
	var m := int(sec / 60.0)
	return "%d:%02d" % [m / 60, m % 60]


# ---------------------------------------------------------------- sayfalar

func show_root() -> void:
	_clear(true)
	if mode == "main":
		var logo := TextureRect.new()
		logo.texture = load("res://assets/art/posters/fez.svg")
		logo.custom_minimum_size = Vector2(0, 90)
		logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		_box.add_child(logo)
		_label(tr("UI_TITLE"), 44, C_CREAM, title_font).autowrap_mode = TextServer.AUTOWRAP_OFF
		_spacer(14)
		if not _auto.is_empty():
			var n := int(_auto["chapter"])
			_button(tr("UI_MENU_CONTINUE") + "   ·   " + chapter_title(n, _scene_of(_auto, n)), func(): picked.emit("continue", 0))
		_button(tr("UI_MENU_NEW"), func():
			if _auto.is_empty():
				picked.emit("new", 0)
			else:
				_confirm(tr("UI_MENU_NEW_CONFIRM"), func(): picked.emit("new", 0)))
		_button(tr("UI_MENU_CHAPTERS"), func(): show_chapters(_auto), GameState.reached_chapters(_auto).size() > 1)
		_button(tr("UI_MENU_LOAD"), func(): show_slots(false), _any_slot())
		_button(tr("UI_MENU_QUESTS") + "   ·   %d/%d" % [GameState.quests_ever.size(), Quests.LIST.size()], show_quests)
		_button(tr("UI_MENU_SETTINGS"), show_settings)
		_button(tr("UI_MENU_QUIT"), func(): picked.emit("quit", 0))
		_spacer(18)
		_label(tr("SPK_HIKMET") + ": " + tr(_hikmet_line()), 18, Color("ffc98a"))
		_label(tr("UI_MENU_KEYS"), 14, C_DIM)
	else:
		_label(tr("UI_PAUSE"), 36, C_ACCENT, title_font)
		_label(chapter_title(GameState.current_chapter, _scene_of(GameState.run_data(), GameState.current_chapter)) + "   ·   " + _time_text(GameState.play_time), 16, C_DIM)
		_spacer(6)
		_button(tr("UI_MENU_RESUME"), func(): picked.emit("resume", 0))
		_button(tr("UI_MENU_RESTART"), func():
			_confirm(tr("UI_MENU_RESTART_CONFIRM"), func(): picked.emit("chapter", GameState.current_chapter)))
		_button(tr("UI_MENU_CHAPTERS"), func(): show_chapters(GameState.run_data()), GameState.current_chapter > 1)
		_button(tr("UI_MENU_SAVE"), func(): show_slots(true), not GameState._saving_disabled())
		_button(tr("UI_MENU_LOAD"), func(): show_slots(false), _any_slot())
		_button(tr("UI_MENU_QUESTS") + "   ·   %d/%d" % [Quests.done_count(), Quests.LIST.size()], show_quests)
		_button(tr("UI_MENU_SETTINGS"), show_settings)
		_button(tr("UI_MENU_MAIN"), func(): _confirm(tr("UI_MENU_MAIN_CONFIRM"), func(): picked.emit("main_menu", 0)))
		_button(tr("UI_MENU_QUIT"), func(): picked.emit("quit", 0))
		_spacer(8)
		var c := _label(tr("UI_CONTROLS"), 14, C_DIM)
		c.custom_minimum_size = Vector2(420, 0)
	_finish_page()


static func _scene_of(data: Dictionary, n: int) -> String:
	if data.is_empty() or not (data["snapshots"] as Dictionary).has(n):
		return ""
	return String((data["snapshots"][n] as Dictionary).get("scene", ""))


func _any_slot() -> bool:
	for i in range(1, GameState.SLOTS + 1):
		if not GameState.read_slot(i).is_empty():
			return true
	return false


## Ana menüde Hikmet'in cümlesi: son finale göre (CHAPTERS §10).
func _hikmet_line() -> String:
	match GameState.last_final:
		"":
			return "UI_MENU_H_MID" if not _auto.is_empty() else "UI_MENU_H_FIRST"
		"empty_desk", "two_neighbours":
			return "UI_MENU_H_T2"
		"another_year":
			return "UI_MENU_H_T3"
		"time_repair":
			return "UI_MENU_H_N4"
		"night_shift":
			return "UI_MENU_H_T4"
		"sultans_repair":
			return "UI_MENU_H_W4"
		"red_button":
			return "UI_MENU_H_RED"
	return "UI_MENU_H_DONE"


func _confirm(text: String, yes: Callable) -> void:
	_clear(false)
	var l := _label(text, 22)
	l.custom_minimum_size = Vector2(460, 0)
	_spacer(8)
	_button(tr("UI_MENU_NO"), show_root)
	_button(tr("UI_MENU_YES"), yes)
	_finish_page()


## Bölümler: bu oyunda ulaşılan bölümler, kapaklarıyla. Seçilen bölümün başına dönülür.
func show_chapters(data: Dictionary) -> void:
	_clear(false)
	_label(tr("UI_MENU_CHAPTERS"), 34, C_CREAM, title_font)
	var note := _label(tr("UI_MENU_CHAPTERS_NOTE"), 16, C_DIM)
	note.custom_minimum_size = Vector2(1060, 0)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	_box.add_child(grid)
	var reached := GameState.reached_chapters(data)
	var first: Button = null
	for n in range(1, GameState.LATEST_CHAPTER + 1):
		var open := n in reached
		var card := VBoxContainer.new()
		card.add_theme_constant_override("separation", 4)
		grid.add_child(card)
		var pic := TextureRect.new()
		pic.custom_minimum_size = Vector2(200, 112)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var path := "res://assets/art/covers/%s.png" % COVERS.get(n, "")
		if open and ResourceLoader.exists(path):
			pic.texture = load(path)
		else:
			var ph := GradientTexture2D.new()
			var g := Gradient.new()
			g.set_color(0, Color("2a2f3c") if open else Color("15171c"))
			g.set_color(1, Color("1a1d26") if open else Color("0e0f12"))
			ph.gradient = g
			pic.texture = ph
		card.add_child(pic)
		var title := chapter_title(n, _scene_of(data, n))
		var b := _button(("%d  " % n) + (title if open else "· · ·"), func():
			_confirm(tr("UI_MENU_REWIND_CONFIRM") % title, func(): picked.emit("chapter", n)), open, card, 14)
		b.custom_minimum_size = Vector2(200, 0)
		b.clip_text = true
		if open and first == null:
			first = b
	_spacer(6)
	_button(tr("UI_MENU_BACK"), show_root)
	_layout.call_deferred()
	if first != null:
		first.grab_focus.call_deferred()


## Kayıt yuvaları: kaydet (save = true) ya da yükle.
func show_slots(save: bool) -> void:
	_clear(false)
	_label(tr("UI_MENU_SAVE") if save else tr("UI_MENU_LOAD"), 34, C_CREAM, title_font)
	_label(tr("UI_MENU_SAVE_NOTE"), 16, C_DIM)
	for i in range(1, GameState.SLOTS + 1):
		var d := GameState.read_slot(i)
		var text := tr("UI_MENU_SLOT") % i + "   ·   "
		if d.is_empty():
			text += tr("UI_MENU_SLOT_EMPTY")
		else:
			text += "%s   ·   %s   ·   %s" % [chapter_title(int(d["chapter"]), _scene_of(d, int(d["chapter"]))), str(d.get("date", "")).substr(0, 16).replace("T", " "), _time_text(float(d.get("play_time", 0.0)))]
		var slot := i
		if save:
			_button(text, func():
				var do_save := func():
					GameState.save_slot(slot)
					Audio.sfx("save", -6.0)
					Audio.sfx("stamp", -6.0)
					show_slots(true)
					_label(tr("UI_MENU_SAVED"), 18, C_ACCENT)
				if d.is_empty():
					do_save.call()
				else:
					_confirm(tr("UI_MENU_OVERWRITE"), do_save), true, null, 20)
		else:
			_button(text, func(): picked.emit("load", slot), not d.is_empty(), null, 20)
	_spacer(6)
	_button(tr("UI_MENU_BACK"), show_root)
	_finish_page()


## Yan görevler: her eşyanın görevi, bu oyundaki ilerleme, daha önce tamamlananlar (★) ve selfie albümü.
func show_quests() -> void:
	_clear(false)
	_label(tr("UI_MENU_QUESTS"), 34, C_CREAM, title_font)
	var in_run := mode == "pause"
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_theme_constant_override("v_separation", 3)
	_box.add_child(grid)
	for id in Quests.LIST:
		var need := int(Quests.LIST[id]["need"])
		var got := Quests.progress_of(id) if in_run else 0
		var ever := GameState.quests_ever.has(id)
		var head := Label.new()
		head.text = ("★ " if ever else "☆ ") + tr(Quests.title_key(id)) + "  ·  " + tr(Items.name_key(id))
		head.add_theme_font_size_override("font_size", 18)
		head.add_theme_color_override("font_color", Color("ffd24a") if ever else C_CREAM)
		grid.add_child(head)
		var info := Label.new()
		info.text = tr(Quests.hint_key(id)) + (("   %d/%d" % [mini(got, need), need]) if in_run else "")
		info.add_theme_font_size_override("font_size", 15)
		info.add_theme_color_override("font_color", C_ACCENT if got >= need else C_DIM)
		info.custom_minimum_size = Vector2(430, 0)
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		grid.add_child(info)
	var pics := Quests.album()
	_spacer(6)
	_label(tr("UI_QUEST_ALBUM") % pics.size(), 20, C_CREAM)
	if pics.is_empty():
		_label(tr("UI_QUEST_ALBUM_EMPTY"), 15, C_DIM)
	else:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		_box.add_child(row)
		for path in pics.slice(0, 5):
			var img := Image.load_from_file(ProjectSettings.globalize_path(path))
			if img == null:
				continue
			var t := TextureRect.new()
			t.texture = ImageTexture.create_from_image(img)
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			t.custom_minimum_size = Vector2(128, 80)
			row.add_child(t)
		_button(tr("UI_QUEST_ALBUM_OPEN"), func(): OS.shell_open(ProjectSettings.globalize_path(Quests.ALBUM_DIR)), true, null, 18)
	_spacer(6)
	_button(tr("UI_MENU_BACK"), show_root)
	_finish_page()


func show_settings() -> void:
	_clear(false)
	_label(tr("UI_MENU_SETTINGS"), 34, C_CREAM, title_font)
	for spec in [["UI_SET_MUSIC", "music", 0.0, 1.0], ["UI_SET_SFX", "sfx", 0.0, 1.0], ["UI_SET_VOICE", "voice", 0.0, 1.0],
			["UI_SET_MOUSE", "mouse", 0.3, 2.5]]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		_box.add_child(row)
		var l := Label.new()
		l.text = tr(spec[0])
		l.custom_minimum_size = Vector2(240, 0)
		l.add_theme_font_size_override("font_size", 20)
		l.add_theme_color_override("font_color", C_CREAM)
		row.add_child(l)
		var s := HSlider.new()
		s.min_value = spec[2]
		s.max_value = spec[3]
		s.step = 0.05
		s.value = float(GameState.settings[spec[1]])
		s.custom_minimum_size = Vector2(260, 28)
		var key: String = spec[1]
		s.value_changed.connect(func(v: float):
			GameState.set_setting(key, v)
			if key == "sfx":
				Audio.sfx("ui_select", -6.0))
		row.add_child(s)
	var fs := CheckButton.new()
	fs.text = tr("UI_SET_FULLSCREEN")
	fs.add_theme_font_size_override("font_size", 20)
	fs.add_theme_color_override("font_color", C_CREAM)
	fs.button_pressed = bool(GameState.settings["fullscreen"])
	fs.toggled.connect(func(on: bool): GameState.set_setting("fullscreen", on))
	_box.add_child(fs)
	_button(tr("UI_SET_LANG"), func():
		GameState.toggle_locale()
		show_settings(), true, null, 20)
	_spacer(6)
	_button(tr("UI_MENU_BACK"), show_root)
	_finish_page()
