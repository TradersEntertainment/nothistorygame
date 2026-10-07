extends Node
## Oynanış fragmanının yöneticisi (bkz. gameplay.gd). Sahne değişse de yaşar (kökün çocuğu).
## Her çekim: bölüm + test botu varyantı + "ne zaman" koşulu (Expression; aşağıdaki yardımcılarla) + süre + başlık.
## Koşul sağlanana dek ekran kara, ses kapalı, zaman SKIP_SPEED katı hızlı; sağlanınca kesme, pencere süresince oyun
## gerçek hızında oynar. Kesim listesi stdout'a: "MONTAGE seg=i in=<kare> out=<kare>".

const SKIP_SPEED := 4.0
const FADE := 0.18

## ch: --chapter değeri (ya da "arena"); v: --autotest varyantı; when: koşul; dur: pencere (sn); lead: koşuldan sonra
## pencere başlamadan beklenen (sn); cap: [TR, EN] üst yazı; wait: koşul için en fazla bekleme (oyun sn)
const CLIPS := [
	{"ch": "20", "v": "", "when": "on('Duel', 'active')", "lead": 0.6, "dur": 7.0,
		"cap": ["KILIÇ: YÖNÜ OKU, SAVUŞTUR", "READ THE BLADE. PARRY."]},
	{"ch": "20o", "v": "", "when": "on('CannonCrew', 'state', 'ball')", "lead": 0.0, "dur": 10.0,
		"cap": ["TOPU KENDİN DOLDUR, KENDİN NİŞANLA", "LOAD IT. AIM IT. FIRE IT."]},
	{"ch": "20", "v": "", "when": "busy('Handgun')", "lead": 0.0, "dur": 7.0,
		"cap": ["FİTİLLİ TÜFEK: BARUT, KURŞUN, HARBİ", "MATCHLOCK: POWDER, BALL, RAMROD"]},
	{"ch": "38o", "v": "", "when": "sv('phase') == 'row'", "lead": 4.0, "dur": 6.0,
		"cap": ["HALİÇ'TE KÜREK ÇEK", "ROW ACROSS THE GOLDEN HORN"]},
	{"ch": "7", "v": "", "when": "flyable()", "lead": 3.0, "dur": 7.0, "drive": "fly", "bot": false, "wait": 1200.0,
		"cap": ["UÇ. GÖRÜNMEZ OL.", "FLY. TURN INVISIBLE."]},
	{"ch": "31o", "v": "", "when": "walking(4.0)", "lead": 0.0, "dur": 6.0,
		"cap": ["1453 İSTANBUL'UNU GEZ", "WALK 1453 CONSTANTINOPLE"]},
	{"ch": "arena", "v": "osm", "when": "on('Duel', 'active')", "lead": 1.0, "dur": 7.0,
		"cap": ["SONSUZ KUŞATMA: İKİ TARAF", "ENDLESS SIEGE: BOTH SIDES"]},
]

var _en := false
var _only: Array = []
var _shots := ""
var _layer: CanvasLayer
var _black: ColorRect
var _cap: Label
var _title: Label
var _tag: Label
var _t := 0.0               # çekimin sahnesi yüklendiğinden beri oyun saniyesi
var _fps := 30.0            # kayıt --fixed-fps 30 ile: pencere kare sayısıyla ölçülür (Godot bu argümanı betiğe
                            # vermez); fps=N ile değişir; kare önizlemede (shots=) duvar saati
var _skip_speed := SKIP_SPEED
var _dur := 0.0
var _skipping := true
var _cache := {}
var _walk_t := 0.0
var _last_p := Vector3.INF
var _seg := 0
var _drive := ""
var _drive_t := 0.0
var _cloak_done := false
var _drive_y0 := INF


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		if a == "en":
			_en = true
		elif a.begins_with("only="):
			_only = Array(a.trim_prefix("only=").split(",")).map(func(x): return int(x))
		elif a.begins_with("dur="):
			_dur = float(a.trim_prefix("dur="))     # önizleme: bütün pencereler bu uzunlukta
		elif a.begins_with("fps="):
			_fps = float(a.trim_prefix("fps="))
		elif a.begins_with("shots="):
			_shots = a.trim_prefix("shots=")
			_fps = 0.0
			DirAccess.make_dir_recursive_absolute(_shots)
	if _en:
		GameState.locale = "en"
		TranslationServer.set_locale("en")
	_build_ui()
	_run()


func _build_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 120
	add_child(_layer)
	_black = ColorRect.new()
	_black.color = Color.BLACK
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(_black)
	var font: Font = load(Hud.FONT_TITLE)
	_cap = Label.new()
	_cap.add_theme_font_override("font", font)
	_cap.add_theme_font_size_override("font_size", 50)
	_cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cap.custom_minimum_size = Vector2(980, 0)
	_cap.add_theme_color_override("font_color", Color("ffd24a"))
	_cap.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_cap.add_theme_constant_override("outline_size", 14)
	_cap.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_cap.position = Vector2(80, 60)
	_cap.modulate.a = 0.0
	_layer.add_child(_cap)
	for big in [true, false]:
		var l := Label.new()
		l.add_theme_font_override("font", font)
		l.add_theme_font_size_override("font_size", 100 if big else 36)
		l.add_theme_color_override("font_color", Color("f2e6c9"))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER if big else VERTICAL_ALIGNMENT_BOTTOM
		l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		if not big:
			l.offset_bottom = -150
		l.modulate.a = 0.0
		_layer.add_child(l)
		if big:
			_title = l
		else:
			_tag = l


func _tx(pair: Array) -> String:
	return pair[1] if _en else pair[0]


func _process(delta: float) -> void:
	_t += delta
	if _skipping:
		if Engine.time_scale > 0.05:
			Engine.time_scale = _skip_speed
	elif Engine.time_scale > 1.0:
		Engine.time_scale = 1.0       # bölümün test hızı (2,5-3x) kayıtta gerçek hıza; Fx'in ağır çekimi (<1) kalır
	var p := _player()
	if p and _drive != "":
		_drive_step(p, delta)
	if p:
		var pos := p.global_position
		if _last_p != Vector3.INF and Vector2(pos.x - _last_p.x, pos.z - _last_p.z).length() > 0.01 and not p.frozen:
			_walk_t += delta
		else:
			_walk_t = 0.0
		_last_p = pos


func _wait(t: float) -> void:
	await get_tree().create_timer(t, true, false, false).timeout


func _mute(on: bool) -> void:
	AudioServer.set_bus_mute(0, on)


func _mark(what: String) -> void:
	print("MONTAGE %s seg=%d frame=%d" % [what, _seg, Engine.get_process_frames()])


# ---------------------------------------------------------------- akış

func _run() -> void:
	await get_tree().process_frame
	_skipping = false
	Engine.time_scale = 1.0
	# Açılış kartı (kara zemin, yazı): kayıtta tutulur
	_mark("in")
	Audio.music("tension", 0.0)
	await _card(_tx(["1453.", "1453."]), _tx(["Oynanış", "Gameplay"]), 2.2)
	_mark("out")
	_seg += 1
	for i in CLIPS.size():
		if not _only.is_empty() and not (i in _only):
			continue
		await _clip(CLIPS[i])
		_seg += 1
	# Kapanış kartı: bölüm kaldırılır (sesi sussun), başlık ve istek listesi
	_skipping = true
	_mute(true)
	_black.color.a = 1.0
	GameState.changing = false
	get_tree().change_scene_to_file("res://tools/trailer/blank.tscn")
	await _wait(0.6)
	_skipping = false
	Engine.time_scale = 1.0
	_mute(false)
	Audio.music("credits", 0.0)
	_mark("in")
	await _card(_tx(["Gerçek Tarih Bu Değil", "Not a History Game"]),
		_tx(["27 bölüm · 26 final · kuşatma iki taraftan\nSteam'de istek listene ekle",
			"27 chapters · 26 endings · the siege from both sides\nWishlist it on Steam"]), 3.4)
	_mark("out")
	print("MONTAGE done")
	get_tree().quit()


func _card(big: String, small: String, hold: float) -> void:
	_black.color.a = 1.0
	_title.text = big
	_tag.text = small
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_title, "modulate:a", 1.0, 0.3)
	tw.tween_property(_tag, "modulate:a", 1.0, 0.4).set_delay(0.3)
	await _wait(hold)
	_title.modulate.a = 0.0
	_tag.modulate.a = 0.0


func _clip(c: Dictionary) -> void:
	_skipping = true
	_mute(true)
	_black.color.a = 1.0
	_cache.clear()
	_skip_speed = float(c.get("skip", SKIP_SPEED))
	_walk_t = 0.0
	_last_p = Vector3.INF
	GameState.reset_run()
	# bot: false: botu olmayan mekanik (uçuş); bölüm normal akar, oyuncuyu pencerede bu betik yönetir
	GameState.autotest = c.get("bot", true)
	GameState.flags["trailer"] = true      # botlar görünür hızda oynar (ör. top ekibi adım adım)
	GameState.autotest_variant = c["v"]
	var path := ""
	if c["ch"] == "arena":
		path = "res://scenes/arena.tscn"
	else:
		var v: String = c["ch"]
		GameState.start_chapter = int(v)
		GameState.start_scene = "" if v.is_valid_int() else "res://scenes/chapter%s.tscn" % v
		var ch := int(v)
		path = GameState.start_scene if GameState.start_scene != "" else "res://scenes/chapter%d.tscn" % ch
		if ch in Siege.ORDER:
			GameState.ensure_defaults_for(12)
			if path.ends_with("o.tscn"):
				GameState.flags["siege_side"] = "O"
		elif ch > 1:
			GameState.ensure_defaults_for(mini(ch, GameState.LATEST_CHAPTER))
	# Fes kenarı birinci şahısta kadrajın üstünü kırmızı bir şeritle kapatıyordu: fragmanda fes yok
	GameState.flags["fez"] = false
	GameState.changing = false
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	_t = 0.0
	var ex := Expression.new()
	if ex.parse(c["when"]) != OK:
		push_error("MONTAGE koşul okunamadı: " + str(c["when"]))
		return
	var limit: float = c.get("wait", 400.0)
	var ok := false
	while _t < limit:
		await _wait(0.1)
		var r: Variant = ex.execute([], self, false)
		if not ex.has_execute_failed() and r == true:
			ok = true
			break
	print("MONTAGE seg=%d ch=%s when=%s ok=%s t=%.1f" % [_seg, c["ch"], c["when"], ok, _t])
	if not ok:
		return
	# Yönetilen mekanik koşuldan hemen sonra başlar (kara ekranda): uçuşta pencere açıldığında Nihat zaten havada
	_drive = c.get("drive", "")
	_drive_t = 0.0
	_drive_y0 = INF
	await _wait(float(c.get("lead", 0.0)))
	# Pencere: gerçek hız, ses açık, kara kalkar (sert kesme), üstte başlık
	_skipping = false
	Engine.time_scale = minf(Engine.time_scale, 1.0)
	_mute(false)
	_black.color.a = 0.0
	_mark("in")
	_cap.text = _tx(c["cap"])
	var ct := create_tween()
	ct.tween_property(_cap, "modulate:a", 1.0, 0.15)
	ct.tween_interval(2.4)
	ct.tween_property(_cap, "modulate:a", 0.0, 0.3)
	var dur: float = c["dur"] if _dur <= 0.0 else _dur
	var f0 := Engine.get_process_frames()
	var w0 := Time.get_ticks_msec()
	var real := func() -> float:
		# Kayıttaki süre: Fx'in ağır çekimi ve donması pencereyi uzatmaz/kısaltmaz
		return (Engine.get_process_frames() - f0) / _fps if _fps > 0.0 else (Time.get_ticks_msec() - w0) / 1000.0
	var next_shot := 0.0
	while real.call() < dur:
		await get_tree().process_frame
		if _shots != "" and real.call() >= next_shot:
			next_shot += float(OS.get_environment("SHOT_STEP")) if OS.has_environment("SHOT_STEP") else 1.0
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(_shots.path_join("s%02d_%04.1f.png" % [_seg, next_shot]))
	_mark("out")
	_end_drive()
	ct.kill()
	_cap.modulate.a = 0.0
	_black.color.a = 1.0
	_mute(true)


# ---------------------------------------------------------------- oyuncuyu yönetme (botu olmayan mekanikler)

## "fly": uçuşu açar, yükselir, ileri süzülür, yavaşça döner; ortada bir an görünmez olur
func _drive_step(p: Player, delta: float) -> void:
	_drive_t += delta
	if _drive == "fly" and p.powers:
		p.frozen = false
		if not p.powers.flying:
			p.powers.set_flying(true)
			_cloak_done = false
		if _drive_y0 == INF:
			_drive_y0 = p.global_position.y
		Input.action_press("move_forward")
		# Ordugâhın üstüne yükselip orada süzülür (GLIDE alçalır: koşu tuşu basılmaz)
		if p.global_position.y - _drive_y0 < 24.0:
			Input.action_press("jump")
		else:
			Input.action_release("jump")
		p.rotate_y(-0.22 * delta)
		p.camera.rotation.x = lerpf(p.camera.rotation.x, -0.12, clampf(delta * 2.0, 0.0, 1.0))
		if int(_drive_t * 2.0) != int((_drive_t - delta) * 2.0):
			print("MONTAGE fly t=%.1f y=%.1f" % [_drive_t, p.global_position.y - _drive_y0])
		if not _cloak_done and _drive_t > 6.5 and p.powers.can_cloak:
			_cloak_done = true
			p.powers.set_cloak(true)
			get_tree().create_timer(1.4).timeout.connect(func():
				if is_instance_valid(p) and p.powers:
					p.powers.set_cloak(false))


	elif _drive == "look_up":
		# Merdivende kamera yukarı: surun tepesi, düşen taş ve kaynar yağ kadrajda (botun bakışı duvara dönüktü)
		p.camera.rotation.x = lerpf(p.camera.rotation.x, 0.75, clampf(delta * 3.0, 0.0, 1.0))


func _end_drive() -> void:
	for a in ["move_forward", "jump", "sprint", "dive"]:
		Input.action_release(a)
	_drive = ""


# ---------------------------------------------------------------- koşul yardımcıları (Expression)

func _player() -> Player:
	var s := get_tree().current_scene
	if s == null:
		return null
	var p = s.get("player")
	return p if p is Player and is_instance_valid(p) else null


func _nodes(cls: String) -> Array:
	var got: Array = _cache.get(cls, [])
	got = got.filter(func(n): return is_instance_valid(n))
	if got.is_empty() and get_tree().current_scene:
		for n in get_tree().current_scene.find_children("*", "", true, false):
			var sc: Script = n.get_script()
			if sc and sc.get_global_name() == cls:
				got.append(n)
		_cache[cls] = got
	return got


## cls sınıfından bir düğümün prop'u val mi (ör. on('Duel', 'active'))
func on(cls: String, prop: String, val: Variant = true) -> bool:
	for n in _nodes(cls):
		if n.get(prop) == val:
			return true
	return false


## Etkin ve boşta olmayan (doldurma/nişan adımında) top ya da tüfek
func busy(cls: String) -> bool:
	for n in _nodes(cls):
		if n.get("state") != null and str(n.get("state")) not in ["idle", "done", ""]:
			if n.get("active") == null or n.get("active") == true:
				return true
	return false


## Nihat'ın güçleri elde ve oyuncu serbest
func flyable() -> bool:
	var p := _player()
	return p != null and p.powers != null and p.powers.can_fly and not p.frozen and _t > 3.0


## Bölüm betiğindeki bir değişken (ör. sv('_stone_falling'))
func sv(name: String) -> Variant:
	var s := get_tree().current_scene
	return s.get(name) if s else null


func ladder() -> bool:
	var p := _player()
	return p != null and p.ladder != null


func flying() -> bool:
	var p := _player()
	return p != null and p.powers != null and p.powers.flying


## Oyuncu en az secs saniyedir serbestçe yürüyor
func walking(secs: float) -> bool:
	return _walk_t >= secs


func after(secs: float) -> bool:
	return _t >= secs
