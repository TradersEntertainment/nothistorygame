class_name CreatorMenu
extends Control
## Gizli Yaratıcı Menüsü (başlıkta "yarat"): oyunun bütün bölümleri, oynanış sırasıyla, kapaklı kartlar.
## Sıra oyundaki gibi: Başlangıç ve Perde I (0–4) · Perde II (5–12 ve dallar) · Kuşatma, Bizans tarafı (Büro ve
## sayfalar) · Kuşatma, Osmanlı tarafı · Dönüş ve final · Sonsuz Kuşatma. v0.92: kartlarda oyundaki bölüm numarası
## (kuşatma 13'ten başlar, taraf başına; dönüş ve final kuşatmanın ardından, iki tarafın numarasıyla), kuşatmada
## tarih, ana hikâyede kim ve ne zaman, son eklenen bölümlerde "YENİ" rozeti; üstte bölüm sekmeleri (tıkla: kayar).
## Eskiden kuşatma iç numaralarıyla (33, 34, 35, 28, 37, 29, 17…) ve ana hikâyeden önce diziliyordu, Bölüm 0 yoktu.
## Seçim picked(scene_path, setup) ile bildirilir; Esc / B: "" (geri).

signal picked(scene: String, setup: Dictionary)

## Ana hikâye: [sahne, iç numara, rozet]
const ACT1 := [["chapter0", 0, "0"], ["chapter1", 1, "1"], ["chapter2", 2, "2"], ["chapter3", 3, "3"], ["chapter4", 4, "4"]]
const ACT2 := [["chapter5", 5, "5"], ["chapter6", 6, "6"], ["chapter7", 7, "7"], ["chapter8", 8, "8"], ["chapter9", 9, "9"],
	["chapter10", 10, "10"], ["chapter10b", 10, "10B"], ["chapter10z", 10, "10Z"], ["chapter10l", 10, "10L"],
	["chapter10g", 10, "10G"], ["chapter10h", 10, "10H"], ["chapter10a", 10, "10A"], ["chapter11", 11, "11"],
	["chapter12", 12, "12"], ["chapter12b", 12, "12B"]]
const FINALE := [["chapter13", 13], ["chapter14", 14], ["chapter15", 15], ["chapter16", 16]]
## Ana hikâyede kim oynanır ve ne zaman: [kim, gün, ay, yıl] (gün 0: yalnız yıl; yıl 0: "Büro")
const WHEN := {
	"chapter0": ["Tolga", 29, 5, 1453], "chapter1": ["Tolga", 0, 0, 2026], "chapter2": ["Tolga", 22, 4, 1453],
	"chapter3": ["Nihat", 0, 0, 2026], "chapter4": ["Tolga", 22, 4, 1453], "chapter5": ["Hikmet", 0, 0, 2026],
	"chapter6": ["Tolga", 23, 4, 1453], "chapter7": ["Nihat", 24, 4, 1453], "chapter8": ["Hikmet", 0, 0, 2026],
	"chapter9": ["Tolga", 25, 4, 1453], "chapter10": ["Tolga", 25, 4, 1453], "chapter10b": ["Tolga", 25, 4, 1453],
	"chapter10z": ["Tolga", 25, 4, 1453], "chapter10l": ["Tolga", 25, 4, 1453], "chapter10g": ["Tolga", 25, 4, 1453],
	"chapter10h": ["Tolga", 25, 4, 1453], "chapter10a": ["Tolga", 25, 4, 1453], "chapter11": ["Nihat · Tolga", 25, 4, 1453],
	"chapter12": ["Tolga", 26, 4, 1453], "chapter12b": ["Tolga", 26, 4, 1453], "chapter13": ["Hikmet", 0, 0, 2026],
	"chapter14": ["Nihat", 0, 0, 0], "chapter15": ["Tolga · Hikmet · Nihat", 0, 0, 2026], "chapter16": ["Sinerji", 0, 0, 1453],
}
const MONTHS := {"tr": ["", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran"], "en": ["", "January", "February", "March",
	"April", "May", "June"]}
## v0.53–v0.62'de eklenen bölümler: "YENİ" rozeti
const NEW := ["chapter28o", "chapter29", "chapter29o", "chapter30", "chapter30o", "chapter31o", "chapter32o", "chapter33o",
	"chapter34o", "chapter35o", "chapter37o", "chapter38o", "chapter39o"]
const GOLD := Color("ffd24a")
const CREAM := Color("f2e6c9")
const INK := Color("17130e")
const DIM := Color(1, 1, 1, 0.55)
## Bölüm renkleri: başlık çizgisi, sekme, kart kenarı, numara rozeti
const C_ACT1 := Color("6ff2c8")
const C_ACT2 := Color("8fd6ff")
const C_BYZ := Color("c39bff")
const C_OTT := Color("ff7a64")
const C_FIN := Color("ffd24a")
const C_ARENA := Color("ffa040")
## Kart genişliği ekrana göre: sığan sütun sayısı CARD_MIN'den, kartlar satırı tam doldurur (720p'de 5 sütun)
const CARD_MIN := 216.0
const CARD_MAX := 300.0
const GAP := 14
const PIC_RATIO := 0.56

## Testin okuduğu kart listesi: {"scene", "setup", "no", "section", "title", "sub", "cover"}
var cards: Array[Dictionary] = []
var _font: Font
var _scroll: ScrollContainer
var _col: VBoxContainer
var _heads := {}           # bölüm kimliği -> başlık düğümü (sekme oraya kaydırır)
var _tabs := {}            # bölüm kimliği -> sekme (kaydırdıkça bulunulan bölümünki dolu)
var _buttons: Array[Button] = []
var _fit_w := -1.0
var _first: Button


func _init(title_font: Font = null) -> void:
	_font = title_font


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	if _font == null and ResourceLoader.exists(Hud.FONT_TITLE):
		_font = load(Hud.FONT_TITLE)
	_background()
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 36
	root.offset_right = -36
	root.offset_top = 18
	root.offset_bottom = -14
	root.add_theme_constant_override("separation", 10)
	add_child(root)
	var head_row := HBoxContainer.new()
	root.add_child(head_row)
	var tbox := VBoxContainer.new()
	tbox.add_theme_constant_override("separation", 0)
	tbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_row.add_child(tbox)
	var title := _label(tr("UI_DEV_TITLE"), 46, GOLD, _font, HORIZONTAL_ALIGNMENT_LEFT)
	title.add_theme_constant_override("outline_size", 8)
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	tbox.add_child(title)
	tbox.add_child(_label(tr("UI_DEV_SUB"), 15, DIM, null, HORIZONTAL_ALIGNMENT_LEFT))
	var count := _label("", 15, Color(1, 1, 1, 0.7))
	count.size_flags_vertical = Control.SIZE_SHRINK_END
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	head_row.add_child(count)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	root.add_child(tabs)
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	root.add_child(_scroll)
	_col = VBoxContainer.new()
	_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_col.add_theme_constant_override("separation", 12)
	_scroll.add_child(_col)
	_col.resized.connect(_fit)
	_scroll.get_v_scroll_bar().value_changed.connect(_on_scrolled)
	# Bölümler oynanış sırasıyla
	var g := _section("act1", tr("UI_DEV_ACT1"), tr("UI_DEV_RANGE") % ["0", "4"], C_ACT1)
	for e: Array in ACT1:
		_story_card(g, e, C_ACT1, "act1")
	g = _section("act2", tr("UI_DEV_ACT2"), tr("UI_DEV_RANGE") % ["5", "12"] + "  ·  " + tr("UI_DEV_BRANCHES"), C_ACT2)
	for e: Array in ACT2:
		_story_card(g, e, C_ACT2, "act2")
	for sd: String in ["B", "O"]:
		var list := Siege.chapters(sd)
		var c := C_BYZ if sd == "B" else C_OTT
		var sub := tr("UI_DEV_RANGE") % [str(Siege.NUMBER_BASE + 1), str(Siege.NUMBER_BASE + list.size())] + "  ·  " + \
			tr("UI_DEV_PAGES") % list.size() + "  ·  " + tr("SIEGE_DATE_%d" % list[0]).split(",")[0] + " – " + \
			tr("SIEGE_DATE_%d" % list[-1]).split(",")[0]
		g = _section("siege_" + sd, tr("UI_DEV_SIEGE_" + sd), sub, c)
		if sd == "B":
			_card(g, {"scene": Siege.PROLOGUE, "setup": {"siege": ""}, "no": "§", "title": tr("UI_DEV_BUREAU_T"),
				"sub": tr("UI_DEV_BUREAU_SUB"), "date": "", "cover": "res://assets/art/covers/ch17.png", "color": c,
				"section": "siege_B"})
		for ch: int in list:
			_siege_card(g, ch, sd, c)
	var nb := Siege.chapters("B").size()
	var no := Siege.chapters("O").size()
	g = _section("finale", tr("UI_DEV_FINALE"), tr("UI_DEV_FINALE_SUB") % [Siege.NUMBER_BASE + nb + 1, Siege.NUMBER_BASE + nb + 3,
		Siege.NUMBER_BASE + no + 1, Siege.NUMBER_BASE + no + 3], C_FIN)
	for e: Array in FINALE:
		var n: int = e[1]
		var badge := "G" if n == 16 else "%d·%d" % [Siege.number_of(n, "B"), Siege.number_of(n, "O")]
		_story_card(g, [e[0], n, badge], C_FIN, "finale")
	g = _section("arena", tr("UI_MENU_ARENA"), tr("UI_DEV_ARENA_SUB"), C_ARENA)
	for sd: String in ["B", "O"]:
		_card(g, {"scene": "res://scenes/arena.tscn", "setup": {"arena": sd}, "no": "∞",
			"title": tr("UI_MENU_ARENA_" + sd), "sub": tr("UI_ARENA_BEST") % int(GameState.stats.get("arena_best_" + sd, 0)),
			"date": "", "cover": "res://assets/art/covers/%s.png" % ("ch20" if sd == "B" else "ch26o"),
			"color": C_ARENA, "section": "arena"})
	# Sekmeler: her bölümün başlığına kayar
	for t: Array in [["act1", "UI_DEV_TAB_ACT1", C_ACT1], ["act2", "UI_DEV_TAB_ACT2", C_ACT2], ["siege_B", "UI_DEV_TAB_B", C_BYZ],
			["siege_O", "UI_DEV_TAB_O", C_OTT], ["finale", "UI_DEV_TAB_FINALE", C_FIN], ["arena", "UI_MENU_ARENA", C_ARENA]]:
		var tb := _tab(tr(t[1]), t[0], t[2])
		tabs.add_child(tb)
		_tabs[t[0]] = tb
	var news := 0
	for cd: Dictionary in cards:
		if String(cd["scene"]).get_file().get_basename() in NEW:
			news += 1
	count.text = tr("UI_DEV_COUNT") % [cards.size(), news]
	# Alt satır: geri ve ipucu
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 16)
	root.add_child(foot)
	var back := Button.new()
	back.text = "  " + tr("UI_MENU_BACK") + "  "
	back.add_theme_font_size_override("font_size", 19)
	_pill(back, Color(1, 1, 1, 0.5))
	back.pressed.connect(func(): picked.emit("", {}))
	foot.add_child(back)
	var hint := _label(tr("UI_DEV_CLICK"), 15, DIM)
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	foot.add_child(hint)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if _first:
		_first.grab_focus.call_deferred()


## Kartları satırı tam dolduracak genişliğe getirir: sığan sütun sayısı CARD_MIN'den, kapak oranı sabit. Sütun
## yerleşince (ve her yeniden dizilişte) sekmelerin durumu da yenilenir: açılışta başlıkların hepsi 0'dayken son sekme
## dolu görünüyordu.
func _fit() -> void:
	_on_scrolled.call_deferred()
	var w := _col.size.x - 2.0
	if w < CARD_MIN or absf(w - _fit_w) < 0.5:
		return
	_fit_w = w
	var cols := maxi(1, int((w + GAP) / (CARD_MIN + GAP)))
	var cw := floorf(minf((w - (cols - 1) * GAP) / cols, CARD_MAX))
	for b in _buttons:
		_layout_card(b, cw)


## Sekmeler: kaydırınca bulunulan bölümün sekmesi dolu (en alta inince son bölüm)
func _on_scrolled(_v := 0.0) -> void:
	var y := float(_scroll.scroll_vertical) + 60.0
	var active := ""
	for id: String in _heads:
		if (_heads[id] as Control).position.y <= y:
			active = id
	var bar := _scroll.get_v_scroll_bar()
	if bar.max_value > bar.page and bar.value >= bar.max_value - bar.page - 2.0:
		active = _heads.keys()[-1]
	for id: String in _tabs:
		(_tabs[id] as Button).set_pressed_no_signal(id == active)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed
			and (event as InputEventJoypadButton).button_index == JOY_BUTTON_B):
		get_viewport().set_input_as_handled()
		picked.emit("", {})


# ---------------------------------------------------------------- parçalar

## Garajın resmi, koyulaştırılmış; üstte ve altta karartma
func _background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.05)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	if ResourceLoader.exists("res://assets/art/covers/menu_bg.png"):
		var pic := TextureRect.new()
		pic.texture = load("res://assets/art/covers/menu_bg.png")
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		pic.modulate = Color(0.32, 0.3, 0.36)
		add_child(pic)
	var g := Gradient.new()
	g.set_color(0, Color(0.02, 0.02, 0.04, 0.55))
	g.set_color(1, Color(0.02, 0.02, 0.04, 0.95))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	var shade := TextureRect.new()
	shade.texture = gt
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)


## Bölüm başlığı (renkli çizgi, ad, alt satır) ve kart ızgarası
func _section(id: String, title: String, sub: String, color: Color) -> HFlowContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_col.add_child(row)
	_heads[id] = row
	var bar := ColorRect.new()
	bar.color = color
	bar.custom_minimum_size = Vector2(6, 44)
	row.add_child(bar)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	row.add_child(v)
	v.add_child(_label(title, 26, color, _font, HORIZONTAL_ALIGNMENT_LEFT))
	v.add_child(_label(sub, 14, DIM, null, HORIZONTAL_ALIGNMENT_LEFT))
	# Başlığın sağında bölümün rengiyle ince, sönen bir çizgi
	var line := TextureRect.new()
	var lg := Gradient.new()
	lg.set_color(0, Color(color, 0.45))
	lg.set_color(1, Color(color, 0.0))
	var lt := GradientTexture2D.new()
	lt.gradient = lg
	lt.height = 2
	line.texture = lt
	line.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	line.stretch_mode = TextureRect.STRETCH_SCALE
	line.custom_minimum_size = Vector2(0, 2)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(line)
	var g := HFlowContainer.new()
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	g.add_theme_constant_override("h_separation", GAP)
	g.add_theme_constant_override("v_separation", GAP)
	_col.add_child(g)
	return g


func _tab(text: String, id: String, color: Color) -> Button:
	var b := Button.new()
	b.text = "  " + text + "  "
	b.toggle_mode = true
	b.add_theme_font_size_override("font_size", 16)
	_pill(b, color)
	b.pressed.connect(func():
		var h: Control = _heads.get(id)
		if h:
			var tw := create_tween()
			tw.tween_property(_scroll, "scroll_vertical", int(h.position.y) - 6, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tw.tween_callback(_on_scrolled.bind(0.0)))
	return b


## Hap biçimli düğme (sekmeler, geri): renkli kenar, üstüne gelince dolar; bulunulan bölümün sekmesi dolu
func _pill(b: Button, color: Color) -> void:
	for st: String in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.set_corner_radius_all(16)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 4
		sb.content_margin_bottom = 4
		sb.set_border_width_all(2)
		sb.border_color = Color(color, 0.85 if st != "normal" else 0.5)
		sb.bg_color = Color(color, {"normal": 0.08, "hover": 0.28, "pressed": 0.42, "hover_pressed": 0.5, "focus": 0.28}[st])
		b.add_theme_stylebox_override(st, sb)
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_focus_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_hover_pressed_color", Color.WHITE)


func _story_card(grid: HFlowContainer, e: Array, color: Color, section: String) -> void:
	var scene: String = "res://scenes/%s.tscn" % e[0]
	if not ResourceLoader.exists(scene):
		return
	var n: int = e[1]
	var t := _title_of(["UI_CH%s_TITLE" % String(e[0]).trim_prefix("chapter").to_upper(), "UI_CH%d_TITLE" % n, "UI_CH%dA_TITLE" % n])
	if n == 0:
		t = [tr("UI_DEV_CH0"), ""]
	_card(grid, {"scene": scene, "setup": {"chapter": n}, "no": str(e[2]), "title": t[0], "sub": _when(e[0]),
		"date": "", "cover": _cover_for(e[0]), "color": color, "section": section})


func _siege_card(grid: HFlowContainer, ch: int, side: String, color: Color) -> void:
	var scene := Siege.scene_path(ch, side)
	if not ResourceLoader.exists(scene):
		return
	var base := scene.get_file().get_basename()
	var t := _title_of(["UI_CH%d%s_TITLE" % [ch, side], "UI_CH%d_TITLE" % ch])
	# Alt satır: yer ("28 Nisan 1453 · Haliç · şafaktan önce" → "Haliç"); eskiden sahnenin iç adı (17, 18b, 33o) yazıyordu
	var sub := _place_of(base, ch)
	if sub == "":
		sub = String(t[1])
	_card(grid, {"scene": scene, "setup": {"siege": side}, "no": str(Siege.number_of(ch, side)), "title": t[0],
		"sub": sub, "date": tr("SIEGE_DATE_%d" % ch), "cover": _cover_for(base), "color": color, "section": "siege_" + side})


## Bölümün yeri: açılış kartının alt satırının ortası (tarih · YER · saat)
func _place_of(scene_base: String, ch: int) -> String:
	for k: String in ["UI_CH%s_SUB" % scene_base.trim_prefix("chapter").to_upper(), "UI_CH%d_SUB" % ch]:
		var t := String(TranslationServer.translate(k))
		if t == k:
			continue
		var parts := t.split(" · ")
		if parts.size() < 2:
			return ""
		var p := parts[1].strip_edges()
		return p.substr(0, 1).to_upper() + p.substr(1)
	return ""


## Başlık: "BÖLÜM {N} — KUNDAK (ORDUGÂH)" → ["KUNDAK", "Ordugâh"] (ayraç içi alt satıra)
func _title_of(keys: Array) -> Array:
	for k: String in keys:
		var t := String(TranslationServer.translate(k))
		if t == k:
			continue
		if "—" in t:
			t = t.split("—")[-1].strip_edges()
		var paren := ""
		var i := t.find(" (")
		if i > 0 and t.ends_with(")"):
			paren = t.substr(i + 2, t.length() - i - 3)
			t = t.substr(0, i)
			paren = paren.substr(0, 1) + paren.substr(1).to_lower() if paren == paren.to_upper() else paren
		return [t, paren]
	return ["?", ""]


## "Tolga · 25 Nisan 1453" (yalnız yıl ya da Büro)
func _when(scene_base: String) -> String:
	var w: Array = WHEN.get(scene_base, [])
	if w.is_empty():
		return scene_base.trim_prefix("chapter")
	var lang := "en" if TranslationServer.get_locale().begins_with("en") else "tr"
	var when := ""
	if int(w[3]) == 0:
		when = tr("UI_DEV_BUREAU_SHORT")
	elif int(w[1]) == 0:
		when = str(w[3])
	else:
		var m: String = MONTHS[lang][int(w[2])]
		when = ("%s %d, %d" % [m, w[1], w[3]]) if lang == "en" else ("%d %s %d" % [w[1], m, w[3]])
	return "%s  ·  %s" % [w[0], when]


func _cover_for(scene_base: String) -> String:
	var own := "res://assets/art/covers/ch%s.png" % scene_base.trim_prefix("chapter")
	if ResourceLoader.exists(own):
		return own
	var n := scene_base.trim_prefix("chapter").to_int()
	var alt := "res://assets/art/covers/%s.png" % GameMenu.COVERS.get(n, "ch%d" % n)
	return alt if ResourceLoader.exists(alt) else ""


## Kart: kapak, sol üstte numara, sağ üstte "YENİ", kapağın altında tarih, altta başlık ve alt satır. Üstüne gelince
## ya da kolla seçilince altın kenar ve hafif büyüme.
func _card(grid: HFlowContainer, d: Dictionary) -> void:
	var color: Color = d["color"]
	var b := Button.new()
	b.focus_mode = Control.FOCUS_ALL
	for st: String in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.set_corner_radius_all(10)
		sb.bg_color = {"normal": Color(0.07, 0.07, 0.09, 0.94), "hover": Color(0.11, 0.1, 0.13, 1.0),
			"pressed": Color(0.04, 0.04, 0.05, 1.0), "focus": Color(0.11, 0.1, 0.13, 1.0)}[st]
		sb.set_border_width_all(2 if st == "normal" else 3)
		sb.border_color = Color(color, 0.4) if st == "normal" else GOLD
		b.add_theme_stylebox_override(st, sb)
	grid.add_child(b)
	var parts := {}
	var pic := TextureRect.new()
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cover: String = d["cover"]
	if cover != "" and ResourceLoader.exists(cover):
		pic.texture = load(cover)
	else:
		pic.modulate = color.darkened(0.6)
		pic.texture = PlaceholderTexture2D.new()
	b.add_child(pic)
	parts["pic"] = pic
	# Kapağın alt yarısı koyulaşır: tarih okunsun
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.0))
	g.set_color(1, Color(0, 0, 0, 0.88))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill_from = Vector2(0.5, 0.45)
	gt.fill_to = Vector2(0.5, 1.0)
	var shade := TextureRect.new()
	shade.texture = gt
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(shade)
	parts["shade"] = shade
	var top := HBoxContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(top)
	parts["top"] = top
	top.add_child(_chip(String(d["no"]), color, INK, 17, _font))
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(gap)
	if String(d["scene"]).get_file().get_basename() in NEW:
		top.add_child(_chip(tr("UI_DEV_NEW_TAG"), Color("e8423a"), Color.WHITE, 12))
	if String(d["date"]) != "":
		var dl := _label(d["date"], 13, Color(1, 0.97, 0.9, 0.95), null, HORIZONTAL_ALIGNMENT_LEFT)
		dl.clip_text = true
		dl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		dl.add_theme_constant_override("outline_size", 4)
		dl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
		b.add_child(dl)
		parts["date"] = dl
	var tl := _label(d["title"], 16, CREAM, _font, HORIZONTAL_ALIGNMENT_LEFT)
	tl.clip_text = true
	tl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	b.add_child(tl)
	parts["title"] = tl
	var sl := _label(d["sub"], 13, DIM, null, HORIZONTAL_ALIGNMENT_LEFT)
	sl.clip_text = true
	sl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	b.add_child(sl)
	parts["sub"] = sl
	b.set_meta("parts", parts)
	_buttons.append(b)
	_layout_card(b, CARD_MIN + 10.0)
	b.mouse_entered.connect(_lift.bind(b, true))
	b.mouse_exited.connect(_lift.bind(b, false))
	b.focus_entered.connect(_lift.bind(b, true))
	b.focus_exited.connect(_lift.bind(b, false))
	var scene: String = d["scene"]
	var setup: Dictionary = d["setup"]
	b.pressed.connect(func(): picked.emit(scene, setup))
	cards.append({"scene": scene, "setup": setup, "no": d["no"], "section": d["section"], "title": d["title"],
		"sub": d["sub"], "cover": cover})
	if _first == null:
		_first = b


## Kartın içi verilen genişliğe göre: kapak (oran sabit), üstte rozetler, kapağın dibinde tarih, altta başlık ve alt satır
func _layout_card(b: Button, cw: float) -> void:
	var ph := roundf((cw - 14.0) * PIC_RATIO)
	b.custom_minimum_size = Vector2(cw, ph + 68.0)
	var p: Dictionary = b.get_meta("parts")
	var pic_rect := Rect2(7, 7, cw - 14.0, ph)
	for k: String in ["pic", "shade"]:
		(p[k] as Control).position = pic_rect.position
		(p[k] as Control).size = pic_rect.size
	(p["top"] as Control).position = pic_rect.position + Vector2(6, 6)
	(p["top"] as Control).size = Vector2(pic_rect.size.x - 12, 26)
	if p.has("date"):
		(p["date"] as Control).position = pic_rect.position + Vector2(8, pic_rect.size.y - 24)
		(p["date"] as Control).size = Vector2(pic_rect.size.x - 16, 20)
	(p["title"] as Control).position = Vector2(10, pic_rect.end.y + 5)
	(p["title"] as Control).size = Vector2(cw - 20, 24)
	(p["sub"] as Control).position = Vector2(10, pic_rect.end.y + 30)
	(p["sub"] as Control).size = Vector2(cw - 20, 20)


func _lift(b: Button, on: bool) -> void:
	b.pivot_offset = b.size * 0.5
	b.z_index = 1 if on else 0
	var tw := b.create_tween()
	tw.tween_property(b, "scale", Vector2.ONE * (1.035 if on else 1.0), 0.12)


## Küçük renkli rozet (numara, YENİ)
func _chip(text: String, bg: Color, fg: Color, size: int, font: Font = null) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(9)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := _label(text, size, fg, font)
	p.add_child(l)
	return p


func _label(text: String, size: int, color: Color, font: Font = null, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if font:
		l.add_theme_font_override("font", font)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
