class_name FinalReview
extends Control
## Final sonrası "Vaka Dosyası": oyuncu aldığı finali, kendi yolunu ve kaçırdığı finalleri görür; her kaçırılan
## final için o finale giden yolun ilk ayrıldığı bölüme tek tuşla döner (o ana kadarki seçimleri korunur).
## Amaç: finalden memnun olmayan oyuncuya diğer yolların neden ilginç olduğunu ve ne kadar yakın olduğunu göstermek.
##
## Rota: finale giden koşullar, oyundaki sırayla. Her adım bir bölüm sonucudur (ya da özel bir kural):
##   {"ch": 9, "ok": ["9.2"]}                    bu bölümde bu sonuçlardan biri
##   {"ch": 13, "not": ["13.2", "13.3"]}          bu sonuçlar dışında herhangi biri (Tolga dönmeli)
##   {"ch": 14, "nihat": true, "ok": [...]}      Nihat tarihi düzeltmemeli (seçeneği önceki bölümlerde açılır)
##   {"ch": 10, "ok": ["10H.1", "10H.2"], "direnc": 2}   heyette Bizans'a verilen yardım sayısı
## Koşullar chapter15._named_final ve bölüm geçişleriyle (chapter9/11 _next_scene) aynı olmalı.

signal finished(action: String, chapter: int)

const WINDOW := {"ch": 13, "not": ["13.2", "13.3"], "key": "UI_RV_WINDOW"}
const NIHAT := {"ch": 14, "ok": ["14.2", "14.4"], "nihat": true, "key": "UI_RV_NIHAT"}
const ROUTES := {
	"two_neighbours": [],   # bu sürümde ulaşılamıyor (T2 + H3 aynı oyunda oluşmuyor): gizli gösterilir
	"empty_desk": [{"ch": 13, "ok": ["13.2"]}],
	"another_year": [{"ch": 13, "ok": ["13.3"]}],
	"founding_member": [{"ch": 9, "ok": ["9.5"]}, {"ch": 10, "ok": ["10A.1"]}, WINDOW, {"ch": 14, "ok": ["14.3"]}],
	"night_shift": [{"ch": 11, "ok": ["11.1"]}, {"ch": 14, "ok": ["14.3"]}],
	"sultans_repair": [{"ch": 12, "ok": ["12.4", "12.6"]}, WINDOW, NIHAT],
	"missing_paperwork": [{"ch": 9, "ok": ["9.4"]}, {"ch": 10, "ok": ["10H.1", "10H.2"], "direnc": 3}, {"ch": 11, "not": ["11.1"]}, WINDOW, NIHAT],
	"long_wait": [{"ch": 9, "ok": ["9.4"]}, {"ch": 10, "ok": ["10H.1", "10H.2"], "direnc": 2}, {"ch": 11, "not": ["11.1"]}, WINDOW, NIHAT],
	"one_more_year": [{"ch": 9, "ok": ["9.4"]}, {"ch": 10, "ok": ["10H.1", "10H.2"], "direnc": 1}, {"ch": 11, "not": ["11.1"]}, WINDOW, NIHAT],
	"sultans_table": [{"ch": 9, "ok": ["9.1"]}, {"ch": 10, "ok": ["10Z.1"]}, WINDOW, NIHAT],
	"envoy_to_venice": [{"ch": 9, "ok": ["9.3"]}, {"ch": 10, "ok": ["10G.1"]}, WINDOW, NIHAT],
	"bureau_founding": [{"ch": 9, "ok": ["9.5"]}, {"ch": 10, "ok": ["10A.1"]}, WINDOW, {"ch": 14, "not": ["14.3"]}],
	"tunnel_truce": [{"ch": 9, "ok": ["9.7"]}, {"ch": 10, "ok": ["10L.1"]}, WINDOW, NIHAT],
	"big_bang": [{"ch": 9, "ok": ["9.2"]}, {"ch": 10, "ok": ["10B.3"]}, WINDOW, NIHAT],
	"master_gunner": [{"ch": 9, "ok": ["9.2"]}, {"ch": 10, "ok": ["10B.1", "10B.2"]}, WINDOW, NIHAT],
	"time_repair": [WINDOW, {"ch": 14, "ok": ["14.4"], "nihat": true}],
	"new_model": [{"ch": 14, "ok": ["14.5"]}],
	"sealed_garage": [{"ch": 3, "ok": ["3.1"]}, {"ch": 13, "ok": ["13.2"]}],
	"pyjama_rescue": [{"ch": 13, "ok": ["13.4"]}],
	"off_the_books": [WINDOW, {"ch": 14, "ok": ["14.2"], "nihat": true}],
	"fixed_mostly": [{"ch": 12, "ok": ["12.2", "12.3", "12.4", "12.6"]}, WINDOW, {"ch": 14, "ok": ["14.1"]}],
	"nobody_noticed": [],   # bu sürümde ulaşılamıyor (Bölüm 14'ün her seçeneği başka finale gider): gizli gösterilir
	"ordinary_monday": [{"ch": 12, "ok": ["12.1"]}, {"ch": 13, "ok": ["13.1"]}, {"ch": 14, "ok": ["14.1"]}],
}
## Kaçırılan finalin kartındaki kapak: o finalin asıl sahnesinin bölümü
const COVER := {"sultans_table": "ch10z", "master_gunner": "ch10b", "big_bang": "ch10b", "envoy_to_venice": "ch10g",
	"bureau_founding": "ch10a", "founding_member": "ch10a", "tunnel_truce": "ch10l", "missing_paperwork": "ch12b",
	"long_wait": "ch12b", "one_more_year": "ch12b", "sultans_repair": "ch12", "nobody_noticed": "ch12",
	"two_neighbours": "ch13", "empty_desk": "ch13", "another_year": "ch13", "pyjama_rescue": "ch13",
	"sealed_garage": "ch5", "night_shift": "ch14", "time_repair": "ch14", "new_model": "ch14", "off_the_books": "ch7",
	"fixed_mostly": "ch14", "ordinary_monday": "ch15"}
## Oyuncunun yolunda gösterilen bölümler (kararın finali etkilediği yerler)
const KEY_CHAPTERS := [2, 3, 5, 7, 9, 10, 11, 12, 13, 14]
const FINALS_ORDER := ["two_neighbours", "empty_desk", "another_year", "founding_member", "night_shift", "sultans_repair",
	"missing_paperwork", "long_wait", "one_more_year", "sultans_table", "envoy_to_venice", "bureau_founding", "tunnel_truce",
	"big_bang", "master_gunner", "time_repair", "new_model", "sealed_garage", "pyjama_rescue", "off_the_books",
	"fixed_mostly", "nobody_noticed", "ordinary_monday"]
const WORLD_FINAL := {"W4": "sultans_repair", "W5": "master_gunner", "W5B": "big_bang", "W6": "envoy_to_venice", "W7": "sultans_table",
	"W10": "one_more_year", "W11": "long_wait", "W12": "missing_paperwork", "W13": "tunnel_truce", "W2": "nobody_noticed", "W3": "nobody_noticed"}

const C_PAPER := Color("efe6cf")
const C_PAPER2 := Color("e4d8b9")
const C_INK := Color("2a2622")
const C_MUTED := Color("6f6553")
const C_STAMP := Color("c8262f")
const C_GOLD := Color("ffd24a")
const C_OK := Color("3f7a3a")

var final_id := ""
var outcomes: Dictionary = {}
var flags: Dictionary = {}
var _font_title: Font
var _first_btn: Button
var _primary: Button


## Bir finale giden rotada bu oyunun ilk tutmayan adımı (-1: hepsi tuttu). outcomes/flags: bu oyunun sonuçları.
static func first_gap(route: Array, outs: Dictionary, fl: Dictionary) -> int:
	for i in route.size():
		if not step_ok(route[i], outs, fl):
			return i
	return -1


static func step_ok(step: Dictionary, outs: Dictionary, fl: Dictionary) -> bool:
	var got: String = str(outs.get(int(step["ch"]), ""))
	if step.has("direnc") and int(fl.get("direnc", 0)) != int(step["direnc"]):
		return false
	if step.has("ok"):
		return got in step["ok"]
	if step.has("not"):
		return got != "" and not (got in step["not"])
	return true


## Bu adımı değiştirmek için dönülecek bölüm. Nihat adımı: seçenek hiç açılmadıysa açıldığı bölüme (5) dönülür.
## Adımın bölümüne bu oyunda hiç gelinmediyse (dal başarıyla bitince 11/12 atlanır) yol ayrımı olan Bölüm 9'a dönülür.
static func rewind_chapter(step: Dictionary, fl: Dictionary, reached: Array) -> int:
	var ch := int(step["ch"])
	if step.get("nihat", false) and int(fl.get("hn_rel", 0)) < 1 and not fl.get("nihat_rulefree", false):
		ch = 5
	if not (ch in reached) and ch >= 10:
		ch = 9
	var best := 1
	for r in reached:
		if int(r) <= ch and int(r) > best:
			best = int(r)
	return best


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font_title = load(Hud.FONT_TITLE)
	if outcomes.is_empty():
		outcomes = GameState.chapter_outcomes.duplicate()
	if flags.is_empty():
		flags = GameState.flags.duplicate()
	_build()


func _label(text: String, size: int, color: Color, parent: Control, title := false, wrap := true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if title:
		l.add_theme_font_override("font", _font_title)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(l)
	return l


func _box(bg: Color, radius := 14, border := Color(0, 0, 0, 0), bw := 0, pad := 14) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.border_color = border
	s.set_border_width_all(bw)
	s.content_margin_left = pad
	s.content_margin_right = pad
	s.content_margin_top = pad * 0.75
	s.content_margin_bottom = pad * 0.75
	return s


func _button(text: String, cb: Callable, parent: Control, strong := false, size := 13) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_font_size_override("font_size", size)
	var base := C_STAMP if strong else Color(1, 1, 1, 0.08)
	b.add_theme_color_override("font_color", Color.WHITE if strong else Color("f2e6c9"))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_focus_color", Color.WHITE)
	b.add_theme_stylebox_override("normal", _box(base, 8, Color(0, 0, 0, 0), 0, 9))
	b.add_theme_stylebox_override("hover", _box(base.lightened(0.15), 8, C_GOLD, 2, 9))
	b.add_theme_stylebox_override("focus", _box(base.lightened(0.15), 8, C_GOLD, 2, 9))
	b.add_theme_stylebox_override("pressed", _box(base.darkened(0.2), 8, C_GOLD, 2, 9))
	b.pressed.connect(func():
		Audio.sfx("ui_confirm", -8.0)
		cb.call())
	b.focus_entered.connect(func(): Audio.sfx("ui_select", -16.0))
	parent.add_child(b)
	if _first_btn == null:
		_first_btn = b
	return b


static func _outcome_label(id: String) -> String:
	var k := "FLOW_" + id.replace(".", "_").to_upper()
	var t := TranslationServer.translate(k)
	if t == k:
		return id
	return t.trim_prefix(id + " ")


static func _chapter_title(n: int, outcome_id := "") -> String:
	var key := "UI_CH%d_TITLE" % n
	for pre in ["10Z", "10B", "10G", "10H", "10A", "10L", "12B"]:
		if outcome_id.begins_with(pre):
			key = "UI_CH%s_TITLE" % pre
	if n == 10 and (outcome_id == "" or outcome_id.begins_with("10O")):
		key = "UI_CH10O_TITLE"
	var t := String(TranslationServer.translate(key))
	return _cap(t.split("—")[-1].strip_edges() if "—" in t else t)


## "BÜYÜK ATIŞ" -> "Büyük Atış" (Türkçe I/İ doğru küçülür)
static func _cap(s: String) -> String:
	var tr_ := TranslationServer.get_locale().begins_with("tr")
	var out: PackedStringArray = []
	for w in s.split(" ", false):
		if w.to_upper() != w or w.is_valid_int() or w.contains("-") and w.to_upper() == w and w.length() < 7:
			out.append(w)
			continue
		var low := (w.replace("I", "ı").replace("İ", "i") if tr_ else w).to_lower()
		var first := low.substr(0, 1)
		first = ("İ" if first == "i" else ("I" if first == "ı" else first.to_upper())) if tr_ else first.to_upper()
		out.append(first + low.substr(1))
	return " ".join(out)


## Adımın okunur hâli: "Bölüm 10 · Büyük Atış: Büyük Patlama"
func _step_text(step: Dictionary) -> String:
	var ch := int(step["ch"])
	var head := tr("UI_RV_CHAPTER") % ch
	if step.has("key"):
		return "%s · %s" % [head, tr(step["key"])]
	if step.get("nihat", false):
		var ids: Array = step["ok"]
		return "%s · %s (%s)" % [head, tr("UI_RV_NIHAT"), " / ".join(ids.map(func(i): return _outcome_label(i)))]
	if step.has("direnc"):
		return "%s · %s: %s" % [head, _chapter_title(10, "10H"), tr("UI_RV_DIRENC") % int(step["direnc"])]
	if step.has("not"):
		return "%s · %s" % [head, tr("UI_RV_NOT") % " / ".join((step["not"] as Array).map(func(i): return _outcome_label(i)))]
	var ok: Array = step["ok"]
	return "%s · %s: %s" % [head, _chapter_title(ch, ok[0]), " / ".join(ok.map(func(i): return _outcome_label(i)))]


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.09, 0.09, 0.15, 0.94)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 30)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 9)
	margin.add_child(root)

	# ---------------------------------------------------------------- başlık: bu final + ilerleme
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 18)
	root.add_child(head)
	var hl := VBoxContainer.new()
	hl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hl.add_theme_constant_override("separation", 2)
	head.add_child(hl)
	_label(tr("UI_RV_KICKER"), 10, Color(1, 1, 1, 0.55), hl)
	_label(tr("UI_CH15_FINAL_" + final_id.to_upper()), 30, C_GOLD, hl, true)
	_label(tr("UI_CH15_FINAL_" + final_id.to_upper() + "_SUB"), 13, Color(1, 1, 1, 0.8), hl)
	var hr := VBoxContainer.new()
	hr.custom_minimum_size = Vector2(240, 0)
	hr.add_theme_constant_override("separation", 6)
	head.add_child(hr)
	var total := Achievements.FINALS_TOTAL
	var seen := mini(GameState.finals_seen.size(), total)
	var cnt := _label(tr("UI_RV_SEEN") % [seen, total], 20, Color.WHITE, hr, true, false)
	cnt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var bar := ProgressBar.new()
	bar.max_value = total
	bar.value = seen
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(240, 9)
	bar.add_theme_stylebox_override("background", _box(Color(1, 1, 1, 0.12), 7, Color(0, 0, 0, 0), 0, 0))
	bar.add_theme_stylebox_override("fill", _box(C_GOLD, 7, Color(0, 0, 0, 0), 0, 0))
	hr.add_child(bar)
	var left_n := total - seen
	var sub := _label(tr("UI_RV_LEFT") % left_n if left_n > 0 else tr("UI_RV_ALL"), 11, Color(1, 1, 1, 0.65), hr)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# Büyük bir dal yaşandı ama Nihat tarihi düzeltti: bunu açıkça söyle (en sık "neden bu final?" sorusu)
	var world := str(flags.get("world10", ""))
	if final_id == "fixed_mostly" and WORLD_FINAL.has(world):
		var lost: String = WORLD_FINAL[world]
		var note := PanelContainer.new()
		note.add_theme_stylebox_override("panel", _box(Color(0.78, 0.15, 0.18, 0.22), 10, C_STAMP, 2, 10))
		root.add_child(note)
		var nv := VBoxContainer.new()
		note.add_child(nv)
		_label(tr("UI_RV_LOST_WORLD") % tr("UI_CH15_FINAL_" + lost.to_upper()), 15, Color.WHITE, nv, true)
		_label(tr("UI_RV_LOST_HOW"), 11, Color(1, 1, 1, 0.8), nv)

	# ---------------------------------------------------------------- gövde: yol + kaçırılanlar
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	root.add_child(body)
	_build_path(body)
	_build_missed(body)

	# ---------------------------------------------------------------- alt çubuk
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	root.add_child(foot)
	_label(tr("UI_RV_FOOT"), 10, Color(1, 1, 1, 0.5), foot).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(tr("UI_RV_MAP"), func(): OS.shell_open("https://tradersentertainment.github.io/nothistorygamedemo/story.html?lang=" + TranslationServer.get_locale().substr(0, 2)), foot)
	_button(tr("UI_RV_MENU"), func(): finished.emit("menu", 0), foot)
	_focus_top.call_deferred()


## İlk odak en yakın finalin "dene" düğmesinde; listeler en üstten başlar (odak kaydırması düzeltilir)
func _focus_top() -> void:
	var f := _primary if _primary else _first_btn
	if f:
		f.grab_focus()
	for i in 2:
		await get_tree().process_frame
		for sc in find_children("*", "ScrollContainer", true, false):
			(sc as ScrollContainer).scroll_vertical = 0


## Sol: bu oyunda finali etkileyen kararlar, her birinden yeniden oynama.
func _build_path(parent: Control) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(330, 0)
	panel.add_theme_stylebox_override("panel", _box(C_PAPER, 12, Color(0, 0, 0, 0), 0, 12))
	parent.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	panel.add_child(v)
	_label(tr("UI_RV_PATH"), 19, C_INK, v, true)
	_label(tr("UI_RV_PATH_SUB"), 10, C_MUTED, v)
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.follow_focus = true
	v.add_child(sc)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 3)
	sc.add_child(list)
	var reached := GameState.reached_chapters(GameState.run_data())
	for ch in KEY_CHAPTERS:
		if not outcomes.has(ch):
			continue
		var o := str(outcomes[ch])
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		list.add_child(row)
		var txt := VBoxContainer.new()
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		txt.add_theme_constant_override("separation", 0)
		row.add_child(txt)
		_label("%s · %s" % [tr("UI_RV_CHAPTER") % ch, _chapter_title(ch, o)], 10, C_MUTED, txt)
		_label("%s  %s" % [o, _outcome_label(o)], 13, C_INK, txt)
		if ch in reached:
			var b := _button("↺", func(): finished.emit("rewind", ch), row, false, 14)
			b.tooltip_text = tr("UI_RV_REPLAY")
			b.custom_minimum_size = Vector2(34, 28)
			b.add_theme_color_override("font_color", C_INK)
			b.add_theme_stylebox_override("normal", _box(C_PAPER2, 10, Color(0, 0, 0, 0), 0, 8))
		var sep := HSeparator.new()
		sep.add_theme_color_override("separator", Color(0, 0, 0, 0.08))
		list.add_child(sep)


## Sağ: kaçırılan finaller, en az tekrarla ulaşılabilenden başlayarak.
func _build_missed(parent: Control) -> void:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 8)
	parent.add_child(v)
	_label(tr("UI_RV_MISSED"), 19, Color.WHITE, v, true)
	_label(tr("UI_RV_MISSED_SUB"), 10, Color(1, 1, 1, 0.6), v)
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.follow_focus = true
	v.add_child(sc)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	sc.add_child(grid)
	var reached := GameState.reached_chapters(GameState.run_data())
	var items: Array = []
	for fid in FINALS_ORDER:
		if fid == final_id:
			continue
		var route: Array = ROUTES[fid]
		if route.is_empty():
			items.append({"id": fid, "gap": -2, "back": 0, "seen": GameState.finals_seen.has(fid)})
			continue
		var gap := first_gap(route, outcomes, flags)
		var back := rewind_chapter(route[maxi(gap, 0)], flags, reached) if gap >= 0 else 15
		items.append({"id": fid, "gap": gap, "back": back, "seen": GameState.finals_seen.has(fid)})
	# Görülmemişler önce; her grupta en yakın (en geç bölümden dönülen) önce
	var own: String = WORLD_FINAL.get(str(flags.get("world10", "")), "")
	items.sort_custom(func(a, b):
		if a["seen"] != b["seen"]:
			return not a["seen"]
		if (a["id"] == own) != (b["id"] == own):
			return a["id"] == own
		if (int(a["gap"]) == -2) != (int(b["gap"]) == -2):
			return int(b["gap"]) == -2
		return int(a["back"]) > int(b["back"]))
	for it in items:
		_final_card(grid, it)


func _final_card(grid: GridContainer, it: Dictionary) -> void:
	var fid: String = it["id"]
	var route: Array = ROUTES[fid]
	var gap: int = it["gap"]
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _box(Color(1, 1, 1, 0.06) if it["seen"] else Color(0.16, 0.17, 0.27, 1.0), 10, Color(1, 1, 1, 0.1), 1, 9))
	grid.add_child(card)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 9)
	card.add_child(h)
	var cov := TextureRect.new()
	cov.custom_minimum_size = Vector2(104, 58)
	cov.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cov.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var cp := "res://assets/art/covers/%s.png" % COVER.get(fid, "ch15")
	if ResourceLoader.exists(cp):
		cov.texture = load(cp)
	if it["seen"]:
		cov.modulate = Color(1, 1, 1, 0.5)
	cov.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	h.add_child(cov)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	h.add_child(v)
	var name := tr("UI_CH15_FINAL_" + fid.to_upper())
	_label(("✓ " if it["seen"] else "") + name, 15, C_GOLD if not it["seen"] else Color(1, 1, 1, 0.55), v, true)
	if not it["seen"]:
		_label(tr("UI_RV_TEASE_" + fid.to_upper()), 11, Color(1, 1, 1, 0.82), v)
	if gap == -2:
		_label(tr("UI_RV_SECRET"), 10, Color(1, 1, 1, 0.5), v)
		return
	# Rota: tutan adımlar ✓, ilk tutmayan → (değiştirilecek karar), sonrakiler ·
	for i in route.size():
		var mark := "✓" if (gap < 0 or i < gap) else ("→" if i == gap else "·")
		var col := Color(0.55, 0.85, 0.6) if mark == "✓" else (Color.WHITE if mark == "→" else Color(1, 1, 1, 0.45))
		_label("%s %s" % [mark, _step_text(route[i])], 10, col, v)
	if gap >= 0 and int(route[gap]["ch"]) >= 10 and not outcomes.has(int(route[gap]["ch"])) and int(it["back"]) == 9:
		_label(tr("UI_RV_UNREACHED") % int(route[gap]["ch"]), 10, Color(1, 0.8, 0.5), v)
	if gap >= 0 and route[gap].get("nihat", false) and int(it["back"]) == 5:
		_label(tr("UI_RV_NIHAT_HOW"), 10, Color(1, 0.8, 0.5), v)
	var back: int = it["back"]
	if gap >= 0:
		var n := 15 - back
		var b := _button(tr("UI_RV_TRY") % [back, n] if n != 1 else tr("UI_RV_TRY_1") % back, func():
			GameState.review_goal = {"final": fid, "step": _step_text(route[gap])}
			finished.emit("rewind", back), v, not it["seen"], 12)
		b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		if _primary == null and not it["seen"]:
			_primary = b
