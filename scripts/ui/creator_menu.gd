class_name CreatorMenu
extends Control
## Gizli Yaratıcı Menüsü (başlıkta "yarat"): kapaklı, fareyle tıklanan, kaydırılabilir bölüm kartları.
## Bölümler: ana hikâye (1–16 ve dal bölümleri), kuşatma Bizans tarafı, kuşatma Osmanlı tarafı, Sonsuz Kuşatma.
## Seçim picked(scene_path, setup) ile bildirilir; Esc: "" (geri).

signal picked(scene: String, setup: Dictionary)

const STORY := [
	["chapter1", 1], ["chapter2", 2], ["chapter3", 3], ["chapter4", 4], ["chapter5", 5], ["chapter6", 6],
	["chapter7", 7], ["chapter8", 8], ["chapter9", 9], ["chapter10", 10], ["chapter10b", 10], ["chapter10z", 10],
	["chapter10l", 10], ["chapter10g", 10], ["chapter10h", 10], ["chapter10a", 10], ["chapter11", 11],
	["chapter12", 12], ["chapter12b", 12], ["chapter13", 13], ["chapter14", 14], ["chapter15", 15], ["chapter16", 16],
]
const C_CREAM := Color("f2e6c9")
const C_ACCENT := Color("ffd60a")

var _font: Font


func _init(title_font: Font = null) -> void:
	_font = title_font


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.04, 0.96)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 40
	root.offset_right = -40
	root.offset_top = 20
	root.offset_bottom = -20
	root.add_theme_constant_override("separation", 8)
	add_child(root)
	var title := _label(tr("UI_DEV_TITLE"), 44, C_ACCENT)
	if _font:
		title.add_theme_font_override("font", _font)
	root.add_child(title)
	root.add_child(_label(tr("UI_DEV_CLICK"), 16, Color(1, 1, 1, 0.65)))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 10)
	scroll.add_child(col)
	# Sonsuz Kuşatma ve kuşatmanın iki tarafı en üstte (yeni içerik)
	col.add_child(_section(tr("UI_MENU_ARENA")))
	var g0 := _grid(col)
	_card(g0, "res://assets/art/covers/ch20.png", tr("UI_MENU_ARENA_B"), "res://scenes/arena.tscn", {"arena": "B"})
	_card(g0, "res://assets/art/covers/ch26o.png", tr("UI_MENU_ARENA_O"), "res://scenes/arena.tscn", {"arena": "O"})
	col.add_child(_section(tr("UI_DEV_SIEGE_B")))
	var gb := _grid(col)
	_card(gb, "res://assets/art/covers/ch17.png", tr("UI_DEV_BUREAU"), Siege.PROLOGUE, {"siege": ""})
	for ch: int in Siege.ORDER:
		_siege_card(gb, ch, "b")
	col.add_child(_section(tr("UI_DEV_SIEGE_O")))
	var go := _grid(col)
	for ch: int in Siege.ORDER:
		_siege_card(go, ch, "o")
	col.add_child(_section(tr("UI_DEV_STORY")))
	var gs := _grid(col)
	for e in STORY:
		var scene: String = e[0]
		var n: int = e[1]
		var cover := _cover_for(scene)
		_card(gs, cover, "%s  %s" % [scene.trim_prefix("chapter").to_upper(), GameMenu.chapter_title(n, "res://scenes/%s.tscn" % scene)],
			"res://scenes/%s.tscn" % scene, {"chapter": n})
	var back := Button.new()
	back.text = tr("UI_MENU_BACK")
	back.add_theme_font_size_override("font_size", 20)
	back.pressed.connect(func(): picked.emit("", {}))
	root.add_child(back)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		picked.emit("", {})


func _siege_card(grid: HFlowContainer, ch: int, side: String) -> void:
	var own := "res://scenes/chapter%d%s.tscn" % [ch, side]
	var scene := own if ResourceLoader.exists(own) else "res://scenes/chapter%d.tscn" % ch
	if not ResourceLoader.exists(scene):
		return          # bu tarafta yok (28o, 31o yalnız Osmanlı)
	var key := "UI_CH%d%s_TITLE" % [ch, side.to_upper()]
	var t := String(TranslationServer.translate(key))
	if t == key:
		t = tr("UI_CH%d_TITLE" % ch)
	if "—" in t:
		t = t.split("—")[-1].strip_edges()
	_card(grid, _cover_for(scene.get_file().get_basename()), "%d  %s" % [ch, t], scene, {"siege": side.to_upper()})


func _cover_for(scene_base: String) -> String:
	var own := "res://assets/art/covers/ch%s.png" % scene_base.trim_prefix("chapter")
	if ResourceLoader.exists(own):
		return own
	var n := scene_base.trim_prefix("chapter").to_int()
	var alt := "res://assets/art/covers/%s.png" % GameMenu.COVERS.get(n, "ch%d" % n)
	return alt if ResourceLoader.exists(alt) else ""


func _section(text: String) -> Label:
	var l := _label(text, 24, C_ACCENT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	return l


func _grid(parent: Control) -> HFlowContainer:
	var g := HFlowContainer.new()
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	g.add_theme_constant_override("h_separation", 12)
	g.add_theme_constant_override("v_separation", 12)
	parent.add_child(g)
	return g


func _card(grid: HFlowContainer, cover: String, text: String, scene: String, setup: Dictionary) -> void:
	var b := Button.new()
	b.custom_minimum_size = Vector2(240, 172)
	b.clip_text = true
	b.focus_mode = Control.FOCUS_ALL
	grid.add_child(b)
	var v := VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 6
	v.offset_right = -6
	v.offset_top = 6
	v.offset_bottom = -6
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)
	var pic := TextureRect.new()
	pic.custom_minimum_size = Vector2(228, 128)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if cover != "" and ResourceLoader.exists(cover):
		pic.texture = load(cover)
	v.add_child(pic)
	var l := _label(text, 16, C_CREAM)
	l.clip_text = true
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(l)
	b.pressed.connect(func(): picked.emit(scene, setup))


func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


## Seçilen bölümü hazırlar ve açar (varsayılan çanta ve önceki sonuçlarla).
static func launch(scene: String, setup: Dictionary) -> void:
	if setup.has("arena"):
		GameState.flags["arena_side"] = setup["arena"]
	elif setup.has("siege"):
		GameState.ensure_defaults_for(12)
		GameState.flags["siege_return"] = "res://scenes/chapter13.tscn"
		if String(setup["siege"]) != "":
			GameState.flags["siege_side"] = setup["siege"]
		# Doğrudan bir kuşatma bölümü açılıyorsa Büro geçilmiş sayılır (Bölüm 17 önsözü atlar)
		GameState.flags["siege_bureau_done"] = scene != Siege.PROLOGUE
	elif setup.has("chapter"):
		GameState.ensure_defaults_for(int(setup["chapter"]))
	GameState.change_scene(scene)
