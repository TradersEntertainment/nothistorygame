extends Node
## QUIPCHECK (v0.92): ayarlarda Tolga'nın yorumları.
##  - Her ayarın her kovası (kapalı / en yüksek / ara değer, açık / kapalı, kalite ve zorluk düzeyleri, dil, tuşlar,
##    açılış) en az iki replikli; DSET_T_ anahtarlarının hepsi bir kovaya bağlı (boşta replik yok)
##  - Ayarlar ilk açılınca Tolga konuşur
##  - Kaydırıcı: art arda değerler tek yorum alır, son değerin kovasından (0,4 → 0 : MUSIC_OFF)
##  - Ters eksen açılınca INVERT_ON; zorluk düğmesine art arda üç basış tek yorum, son düzeyin kovası
##  - Aynı kova art arda altı kez: hiçbir replik arka arkaya gelmez, kovanın bütün replikleri söylenir
##  - Ana sayfaya dönünce Tolga susar

var _fail := ""


func _ready() -> void:
	GameState.autotest = true
	var keep: Dictionary = GameState.settings.duplicate(true)
	_coverage()
	var menu := GameMenu.new("main")
	add_child(menu)
	await _frames(2)
	menu.show_settings()
	var q: TolgaQuips = menu._quips
	if q == null:
		_bad("ayarlar açılınca Tolga kurulmadı")
	else:
		await _said(q, 1)
		_expect(q, 0, "DSET_T_OPEN_")
		# Kaydırıcı: müzik 0,4 sonra 0 (aynı karede): tek yorum, MUSIC_OFF
		var sl: Array = menu.find_children("*", "HSlider", true, false)
		(sl[0] as HSlider).value = 0.4
		(sl[0] as HSlider).value = 0.0
		await _said(q, 2)
		_expect(q, 1, "DSET_T_MUSIC_OFF_")
		# Ters eksen
		for c: CheckButton in menu.find_children("*", "CheckButton", true, false):
			if c.text == tr("UI_SET_INVERT"):
				c.button_pressed = not c.button_pressed
				await _said(q, 3)
				_expect(q, 2, "DSET_T_INVERT_%s_" % ("ON" if c.button_pressed else "OFF"))
		# Zorluk düğmesine art arda üç basış: tek yorum, son düzey
		var d0 := int(GameState.settings["difficulty"])
		for b: Button in menu.find_children("*", "Button", true, false):
			if b.text == tr(["UI_SET_DIFF0", "UI_SET_DIFF1", "UI_SET_DIFF2"][d0]):
				for i in 3:
					b.pressed.emit()
				break
		await _said(q, 4)
		_expect(q, 3, "DSET_T_DIFF_D%d_" % int(GameState.settings["difficulty"]))
		await get_tree().create_timer(1.0).timeout
		if q.said.size() != 4:
			_bad("art arda değişikliklere birden çok yorum: %s" % str(q.said))
		# Aynı kova altı kez
		var keys: Array[String] = []
		for i in 6:
			menu._quip("fps", true)
			await _said(q, q.said.size() + 1)
			keys.append(q.said.back())
		for i in range(1, keys.size()):
			if keys[i] == keys[i - 1]:
				_bad("aynı replik art arda: %s" % keys[i])
		var all := TolgaQuips.lines("FPS_ON")
		for k in all:
			if not k in keys:
				_bad("kovanın repliği hiç söylenmedi: %s (%s)" % [k, str(keys)])
		# Ana sayfa: susar
		menu.show_root()
		await get_tree().create_timer(0.8).timeout
		if q.visible and q.modulate.a > 0.05:
			_bad("ana sayfada Tolga susmadı")
	GameState.settings = keep
	GameState.apply_settings()
	print("QUIPCHECK %s%s" % ["PASS" if _fail == "" else "FAIL", "" if _fail == "" else ": " + _fail])
	get_tree().quit(0 if _fail == "" else 1)


func _coverage() -> void:
	var vals := {"music": [0.0, 0.5, 1.0], "sfx": [0.0, 0.5, 1.0], "voice": [0.0, 0.5, 1.0], "fx": [0.0, 0.5, 1.0],
		"mouse": [0.3, 1.0, 2.5], "pad_sens": [0.3, 1.0, 2.5], "fov": [60.0, 80.0, 100.0], "subs": [0.8, 1.0, 1.6],
		"quality": [0, 1, 2, 3], "difficulty": [0, 1, 2], "lang": ["tr", "en"], "keys": ["rebind", "reset"], "open": [true]}
	var reach := {}
	for key: String in TolgaQuips.ACTION:
		for v in vals.get(key, [true, false]):
			var b := TolgaQuips.bucket(key, v)
			reach[b] = true
			var n := TolgaQuips.lines(b).size()
			if n < 2:
				_bad("%s=%s kovası %s: %d replik" % [key, str(v), b, n])
	var f := FileAccess.open("res://i18n/strings.csv", FileAccess.READ)
	while f and not f.eof_reached():
		var row := f.get_csv_line()
		if row.size() > 0 and row[0].begins_with("DSET_T_"):
			var b := row[0].trim_prefix("DSET_T_")
			b = b.substr(0, b.rfind("_"))
			if not reach.has(b):
				_bad("boşta replik (hiçbir ayar söyletmez): %s" % row[0])
	print("QUIPCHECK kovalar=%d" % reach.size())


func _said(q: TolgaQuips, n: int) -> void:
	var t := 0.0
	while q.said.size() < n and t < 6.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	if q.said.size() < n:
		_bad("Tolga konuşmadı (%d. yorum bekleniyordu, söylenen: %s)" % [n, str(q.said)])


func _expect(q: TolgaQuips, i: int, prefix: String) -> void:
	if q.said.size() <= i or not q.said[i].begins_with(prefix):
		_bad("%d. yorum %s* bekleniyordu: %s" % [i + 1, prefix, str(q.said)])


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _bad(why: String) -> void:
	printerr("QUIPCHECK: " + why)
	if _fail == "":
		_fail = why
