extends Node
## Arayüz taşma denetimi (v0.99.11; arkadaş notu: "eşyaların açıklamaları ekrana sığmıyor"). Oyunun en dar mantıksal
## genişliği 1280 (stretch canvas_items + expand). İki dilde en uzun metinler arayüze verilir:
##   * garajda eşya istemi: "[E] Al: …" ve altında yan görevin adı ve açıklaması (bütün eşyalar);
##   * açık çanta: en uzun adlı beş eşya ve şarjları, cep;
##   * eldeki eşya yazısı (her eşya);
##   * eşya bildirimleri: verildi / bitti / kayıp, her kullanım yeriyle (USE_*);
##   * menüdeki yan görev listesi (albümde fotoğraflarla).
## Görünen her Control'ün ekrandaki dikdörtgeni görüntü alanının içinde olmalı. Sonuç: UIFIT PASS/FAIL.

var ok := true
var hud: Hud
var vs: Vector2


func _ready() -> void:
	GameState.autotest = true
	# Başsız koşuda pencere kare açılır; oyunun tasarım boyutu 1280x720
	get_window().size = Vector2i(1280, 720)
	await _frames()
	vs = get_viewport().get_visible_rect().size
	print("UIFIT ekran %s" % vs)
	for loc in ["tr", "en"]:
		TranslationServer.set_locale(loc)
		await _check_hud(loc)
		await _check_menu(loc)
	print("UIFIT %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)


func _fail(msg: String) -> void:
	printerr("UIFIT " + msg)
	ok = false


func _frames(n := 2) -> void:
	for i in n:
		await get_tree().process_frame


## Control ve görünen çocukları ekranın içinde mi.
func _inside(c: Control, what: String) -> void:
	if not c.is_visible_in_tree():
		return
	var r := c.get_global_rect()
	if r.position.x < -1 or r.position.y < -1 or r.end.x > vs.x + 1 or r.end.y > vs.y + 1:
		_fail("%s taşıyor: %s (ekran %s) «%s»" % [what, r, vs, _text_of(c).left(90)])
		return
	# Kaydırılan liste: içerik dikeyde uzayabilir, yatayda kaydırma kapalıysa genişliği aşan metin kesilir
	if c is ScrollContainer:
		for ch in c.get_children():
			if ch is Control and ch.visible and ch.size.x > c.size.x + 1:
				_fail("%s yatayda kesiliyor: içerik %d > liste %d «%s»" % [what, ch.size.x, c.size.x, _text_of(ch).left(90)])
		return
	for ch in c.get_children():
		if ch is Control:
			_inside(ch, what)


func _text_of(c: Control) -> String:
	if c is Label:
		return c.text
	for ch in c.get_children():
		if ch is Control:
			var t := _text_of(ch)
			if t != "":
				return t
	return ""


func _check_hud(loc: String) -> void:
	hud = Hud.new()
	add_child(hud)
	await _frames()
	# Garaj istemi (scripts/chapter1.gd _on_focus ile aynı biçim)
	for it in Items.IDS:
		hud.set_prompt(tr("UI_PROMPT_TAKE") % tr(Items.name_key(it)) + "\n" + tr("UI_PROMPT_QUEST") % [tr(Quests.title_key(it)), tr(Quests.hint_key(it))])
		await _frames()
		_inside(hud._prompt, "%s istem (%s)" % [loc, it])
	hud.set_prompt("")
	# Çanta: en uzun adlı beş eşya, cepte üç 1453 eşyası
	var ids: Array = Items.IDS.duplicate()
	ids.sort_custom(func(a, b): return tr(Items.name_key(a)).length() > tr(Items.name_key(b)).length())
	GameState.bag.clear()
	for id in ids.slice(0, 5):
		GameState.bag.append(id)
	GameState.flags["pocket"] = Items.POCKET_IDS.duplicate()
	hud.update_bag(GameState.bag)
	hud.toggle_bag(true)
	await _frames(3)
	_inside(hud._bag_box, "%s çanta" % loc)
	# Garajda çanta açıkken eşyaya bakılır: istem çantanın üstüne binmez
	for it in Items.IDS:
		hud.set_prompt(tr("UI_PROMPT_TAKE") % tr(Items.name_key(it)) + "\n" + tr("UI_PROMPT_QUEST") % [tr(Quests.title_key(it)), tr(Quests.hint_key(it))])
		await _frames()
		_inside(hud._prompt, "%s istem, çanta açık (%s)" % [loc, it])
		if hud._prompt.get_global_rect().intersects(hud._bag_box.get_global_rect()):
			_fail("%s istem çantanın üstüne biniyor (%s)" % [loc, it])
	hud.set_prompt("")
	hud.toggle_bag(false)
	# Eldeki eşya
	for i in GameState.bag.size():
		hud.set_held(i + 1, GameState.bag[i])
		await _frames()
		_inside(hud._held_label, "%s elde (%s)" % [loc, GameState.bag[i]])
	# Eşya bildirimleri: en uzun ad ve her kullanım yeri
	var longest: String = ids[0]
	var nm := tr(Items.name_key(longest))
	for key in _use_keys():
		for fmt in ["UI_ITEM_GIVEN", "UI_ITEM_EMPTY", "UI_ITEM_LOST"]:
			hud._toast(tr(fmt) % [nm, tr(key)], Color.WHITE, 0.1)
			await _frames()
			for t in hud._toasts.duplicate():
				_inside(t, "%s bildirim (%s, %s)" % [loc, fmt, key])
				t.free()
	GameState.flags.erase("pocket")
	GameState.bag.clear()
	hud.queue_free()
	await _frames()


func _use_keys() -> Array:
	var out: Array = []
	var f := FileAccess.open("res://i18n/strings.csv", FileAccess.READ)
	while not f.eof_reached():
		var k := f.get_line().get_slice(",", 0)
		if k.begins_with("USE_"):
			out.append(k)
	return out


## Albümde fotoğraf varken sayfa uzar ("Geri" 720p'de ekranın altında kalıyordu): albüm boşsa geçici beş kare yazılır.
func _check_menu(loc: String) -> void:
	var tmp: Array[String] = []
	if Quests.album().size() < 5:
		DirAccess.make_dir_recursive_absolute(Quests.ALBUM_DIR)
		var img := Image.create(64, 40, false, Image.FORMAT_RGB8)
		img.fill(Color(0.4, 0.3, 0.2))
		for i in 5:
			var path := Quests.ALBUM_DIR + "uifit_tmp_%d.png" % i
			img.save_png(path)
			tmp.append(path)
	var m := GameMenu.new()
	m.mode = "pause"
	add_child(m)
	await _frames()
	m.show_quests()
	await _frames(3)
	_inside(m, "%s menü yan görevler" % loc)
	m.queue_free()
	await _frames()
	for path in tmp:
		DirAccess.remove_absolute(path)
