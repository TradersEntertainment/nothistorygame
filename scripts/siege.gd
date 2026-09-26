class_name Siege
extends RefCounted
## Perde IV · Hasar Tespit (docs/SIEGE.md): kuşatma bölümlerinin ortak parçaları.
## Tolga, Büro'nun geçici tanığı olarak kuşatmanın olaylarını sırayla "tespit eder": her bölümün bir
## tespit karesi (telefonla doğru anda doğru şeyin fotoğrafı) ve sonunda Hasar Tespit Dosyası'na bir sayfası vardır.

const FIRST := 17
const LAST := 26


static func scene_path(ch: int) -> String:
	return "res://scenes/chapter%d.tscn" % ch


## Perdenin sıradaki (yapılmış) bölümü; yoksa "".
static func next_path(ch: int) -> String:
	for n in range(ch + 1, LAST + 1):
		if ResourceLoader.exists(scene_path(n)):
			return scene_path(n)
	return ""


## Dosyaya sayfa: fotoğraf yolu (yoksa ""), Tolga'nın notu (çeviri anahtarı).
static func record(ch: int, photo: String, note_key: String) -> void:
	var d: Dictionary = GameState.flags.get("dossier", {})
	d[str(ch)] = {"photo": photo, "note": note_key}
	GameState.flags["dossier"] = d


static func page_count() -> int:
	return (GameState.flags.get("dossier", {}) as Dictionary).size()


## Hasar Tespit Tutanağı: kâğıt sayfa, fotoğraf, not ve "KAYNAK" damgası. Etkileşim tuşuyla ya da 7 sn sonra kapanır.
static func show_page(hud: Hud, ch: int) -> void:
	var d: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get(str(ch), {})
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.05, 0.07, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	var paper := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("efe6cf")
	sb.border_color = Color("2a2622")
	sb.set_border_width_all(2)
	sb.set_content_margin_all(26)
	paper.add_theme_stylebox_override("panel", sb)
	paper.custom_minimum_size = Vector2(820, 0)
	paper.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	paper.rotation = -0.012
	root.add_child(paper)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	paper.add_child(col)
	var ink := Color("2a2622")
	var head := _l(hud.tr("UI_SIEGE_PAGE_HEAD") % [ch - FIRST + 1, LAST - FIRST + 1], 15, Color("7a6f60"))
	col.add_child(head)
	col.add_child(_l(hud.tr("SIEGE_DATE_%d" % ch), 26, ink))
	col.add_child(_l(hud.tr("SIEGE_EV_%d" % ch), 18, Color("4a4038")))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	col.add_child(row)
	var pic := PanelContainer.new()
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color("f8f4ea")
	psb.set_content_margin_all(8)
	pic.add_theme_stylebox_override("panel", psb)
	pic.rotation = 0.03
	row.add_child(pic)
	var photo: String = d.get("photo", "")
	if photo != "" and FileAccess.file_exists(photo):
		var tex := TextureRect.new()
		tex.texture = ImageTexture.create_from_image(Image.load_from_file(photo))
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.custom_minimum_size = Vector2(340, 214)
		pic.add_child(tex)
	else:
		var none := _l(hud.tr("UI_SIEGE_NO_PHOTO"), 16, Color("7a6f60"))
		none.custom_minimum_size = Vector2(340, 214)
		none.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		none.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pic.add_child(none)
	var note := _l(hud.tr(String(d.get("note", ""))), 18, ink)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size = Vector2(380, 0)
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(note)
	col.add_child(_l(hud.tr("UI_SIEGE_PAGE_SIGN"), 14, Color("7a6f60")))
	# Damga
	var stamp := _l(hud.tr("UI_SIEGE_STAMP"), 40, Color("c8262f"))
	stamp.add_theme_color_override("font_outline_color", Color("c8262f"))
	stamp.add_theme_constant_override("outline_size", 2)
	root.add_child(stamp)
	paper.modulate.a = 0.0
	stamp.modulate.a = 0.0
	await hud.get_tree().process_frame
	var vs := hud.get_viewport().get_visible_rect().size
	paper.position = (vs - paper.size) * 0.5
	stamp.pivot_offset = stamp.size * 0.5
	stamp.position = paper.position + Vector2(paper.size.x - stamp.size.x - 40, paper.size.y - stamp.size.y - 30)
	stamp.rotation = -0.22
	if GameState.autotest:
		root.queue_free()
		return
	Audio.sfx("paper_tear", -14.0, 1.4)
	var tw := hud.create_tween()
	tw.tween_property(paper, "modulate:a", 1.0, 0.4)
	await tw.finished
	await hud.get_tree().create_timer(0.8).timeout
	stamp.scale = Vector2.ONE * 2.2
	var st := hud.create_tween().set_parallel()
	st.tween_property(stamp, "modulate:a", 0.9, 0.12)
	st.tween_property(stamp, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Audio.sfx("stamp", -2.0)
	var t := 0.0
	while t < 7.0:
		await hud.get_tree().process_frame
		t += hud.get_process_delta_time()
		if t > 1.2 and (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept")):
			break
	var out := hud.create_tween()
	out.tween_property(root, "modulate:a", 0.0, 0.35)
	await out.finished
	root.queue_free()


static func _l(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l
