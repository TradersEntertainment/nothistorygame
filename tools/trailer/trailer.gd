extends Node3D
## Steam fragmanı, 1 dakikalık hızlı kurgu. Sert kesmeler; karartma yalnız en sonda (başlık). Her çekim 1–3 sn.
##   1 Garaj (0:00)      makine döner · Hikmet: "Takıldı! Tekme lazım!" · tekme · beyaz ışık
##   2 Dünya (0:05)      "İSTANBUL · 1453": ordugâh vinç çekimi, gün batımında Ayasofya
##   3 Kızak (0:09)      yağlı yokuşta Tolga, arkasında kadırga · "Frenk casusu!" · "sigortacıyım!" · "Sigortacı ne?"
##   4 Otağ (0:17)       Fatih: "Bu şehir alınacak mı?" · Tolga: "Evet. 29 Mayıs'ta. Salı günü."
##   5 Kuşatma (0:24)    "KUŞATMA": gece son hücum, gedikte Tolga savunucuların arasında ("İmza istemiyorum, alın!"),
##                       hendek kıyısında sura koşanların üstünde Nihat: "Büro personeli ölmez... Madde 9." — ve gündüz
##                       Urban'ın büyük topu ateşler, gülle Tolga'nın başının üstünde patlar ("Kulağımda çınlama var.")
##   6 Büyük Atış (0:40) "KULAKLARI TIKAYIN!" · "...Hmm." · "Bu 'hmm' iyi bir 'hmm' mi?" · ağır çekimde herkes uçar
##                       · Fatih: "Urban." · "Efendim." · "Urban'ın topunu sigortalamış mıydın?" · "Hayır." · "Yazık."
##   7 Son (0:55)        başlık, "27 bölüm · 23 final · kuşatma iki taraftan", "Steam'de istek listene ekle" · tavuk
## Kayıt (docs/STEAM.md):
##   godot --path . --write-movie fragman.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn
## İngilizce (İngilizce ses, altyazı ve kartlar; İngilizce sesi olmayan replik yalnız altyazıyla geçer):
##   godot --path . --write-movie fragman_en.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn -- en
## Tek bölüm önizleme: -- only=garage|world|slipway|otag|siege|boom|end
## Yalnız patlama (site GIF'i, altyazısız): -- boom

var VOICE_DIR := "res://assets/audio/voice/tr/"
var _en := false
const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const CANNON := Vector3(3.0, 0.0, -21.0)
const URBAN_AT := Vector3(5.8, 0.0, -23.6)
const TOLGA_AT := Vector3(5.4, 0.0, -16.0)
const FATIH_AT := Vector3(11.0, 0.0, -16.2)
const GOAT_TENT := Vector3(19.0, 0.0, -12.0)
const TOLGA := {"face": "tolga", "coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")}
const FATIH := {"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true, "robe": Color("c8323a"),
	"hair": Color("2a1e14"), "skin": Color("e0b08a")}
const URBAN := {"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "hat": "kalpak", "face": "urban", "mustache": true, "beard": true,
	"hair": Color("8a5a2a"), "apron": Color("4a3020"), "skin": Color("e8b894")}

## Seslendirme kayıtlarının başındaki sessizlik (sn, ffmpeg silencedetect): fragmanda boş bekleme olmasın.
## Savaş gürültüsü altında kalan replikler: ses biraz yükseltilir, efektler (SFX) replik boyunca kısılır
const VOICE_DB := {"D20_T_DROP_2": 3.0, "D26_L_WAVE_1": 2.0}
const DUCK_SFX := {"D20_T_DROP_2": -9.0, "D26_L_WAVE_1": -6.0}
const LEAD_SILENCE := {"tr:D10B_T_B3_2": 2.05, "tr:D10B_T_B3_AIR": 0.12}

var cam: Camera3D
var level: Node3D
var _cam_tw: Tween
var fade: ColorRect
var title: Label
var tagline: Label
var overlay: Label
var sub_box: PanelContainer
var sub_name: Label
var sub_text: Label
var voice: AudioStreamPlayer
var _font_title: Font
var _only_boom := false


func _ready() -> void:
	GameState.autotest = false
	if "en" in OS.get_cmdline_user_args():
		_en = true
		TranslationServer.set_locale("en")
		VOICE_DIR = "res://assets/audio/voice/en/"
	set_meta("cinematic", true)   # karakterleri kaydırma, kendi aralarında sohbete daldırma
	_font_title = load(Hud.FONT_TITLE)
	var cl := CanvasLayer.new()
	cl.layer = 50
	add_child(cl)
	fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cl.add_child(fade)
	title = _big_label(104)
	cl.add_child(title)
	tagline = _big_label(38)
	tagline.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	tagline.offset_bottom = -150
	cl.add_child(tagline)
	# Çekimin üstüne binen büyük yazı (siyah ara kart yerine): sol üstte, kalın dış çizgili
	overlay = _big_label(84)
	overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	overlay.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	overlay.offset_left = 90
	overlay.offset_top = 70
	overlay.add_theme_constant_override("outline_size", 14)
	cl.add_child(overlay)
	sub_box = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.55)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 10
	sb.content_margin_bottom = 12
	sub_box.add_theme_stylebox_override("panel", sb)
	sub_box.anchor_left = 0.5
	sub_box.anchor_right = 0.5
	sub_box.anchor_top = 1.0
	sub_box.anchor_bottom = 1.0
	sub_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	sub_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	sub_box.offset_bottom = -60
	sub_box.visible = false
	var vb := VBoxContainer.new()
	sub_box.add_child(vb)
	sub_name = Label.new()
	sub_name.add_theme_font_size_override("font_size", 26)
	vb.add_child(sub_name)
	sub_text = Label.new()
	sub_text.add_theme_font_size_override("font_size", 36)
	sub_text.add_theme_color_override("font_color", Color("f6f1e4"))
	sub_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub_text.custom_minimum_size = Vector2(900, 0)
	sub_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(sub_text)
	cl.add_child(sub_box)
	voice = AudioStreamPlayer.new()
	voice.bus = "Voice"
	voice.volume_db = 2.0
	add_child(voice)
	Audio.ambience("")
	_run()


# ---------------------------------------------------------------- yardımcılar

func _t(tr_text: String, en_text: String) -> String:
	return en_text if _en else tr_text


func _big_label(size: int) -> Label:
	var l := Label.new()
	l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_override("font", _font_title)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("f2e6c9"))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 8)
	l.modulate.a = 0.0
	return l


func _wait(t: float) -> void:
	await get_tree().create_timer(t).timeout


## Seslendirme + altyazı. cut > 0: o kadar saniye sonra ses kısılır (uzun replikten bir parça).
## Ses dosyası yoksa (ör. İngilizce sesi henüz üretilmemiş replik) süre metnin uzunluğundan tahmin edilir.
func _say(spk: String, key: String, cut := 0.0, text_override := "") -> float:
	var txt := text_override if text_override != "" else tr(key)
	var rx := RegEx.new()
	rx.compile("\\([^)]*\\)")
	txt = rx.sub(txt, "", true).strip_edges().replace("  ", " ")
	var path := VOICE_DIR + key + ".mp3"
	var dur := clampf(txt.length() * 0.065, 1.2, 4.5)
	var s: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if s == null and ResourceLoader.exists(path):
		push_warning("Fragman: ses yüklenemedi (içe aktarılmamış?): " + path)
	if s != null:
		voice.stream = s
		voice.volume_db = 2.0 + float(VOICE_DB.get(key, 0.0))
		# Kaydın başındaki sessizlik atlanır (ör. "Bu 'hmm' iyi bir 'hmm' mi?" 2 sn susup başlıyor)
		var skip: float = LEAD_SILENCE.get(("en:" if _en else "tr:") + key, 0.0)
		voice.play(skip)
		dur = s.get_length() - skip
	if DUCK_SFX.has(key):
		var sb := AudioServer.get_bus_index("SFX")
		if sb >= 0:
			var base := AudioServer.get_bus_volume_db(sb)
			var dk: float = DUCK_SFX[key]
			var dt := create_tween()
			dt.tween_method(func(v: float): AudioServer.set_bus_volume_db(sb, v), base, base + dk, 0.15)
			dt.tween_interval(maxf(dur - 0.3, 0.1))
			dt.tween_method(func(v: float): AudioServer.set_bus_volume_db(sb, v), base + dk, base, 0.4)
	sub_name.text = tr(spk).to_upper()
	sub_name.add_theme_color_override("font_color", Hud.SPEAKER_COLORS.get(spk, Color("ffd24a")))
	sub_text.text = txt
	sub_box.visible = not _only_boom
	if cut > 0.0 and cut < dur:
		dur = cut
		var tw := create_tween()
		tw.tween_interval(maxf(cut - 0.25, 0.0))
		tw.tween_property(voice, "volume_db", -40.0, 0.25)
	var my := sub_text.text
	get_tree().create_timer(dur + 0.15).timeout.connect(func():
		if sub_text.text == my:
			sub_box.visible = false)
	return dur


## Konuşan karakterin ağzı oynar; süre kadar bekler (+ boşluk).
func _line(who: Node, spk: String, key: String, gap := 0.08, cut := 0.0, text := "") -> void:
	var d := _say(spk, key, cut, text)
	var r = who.get("rig") if who and is_instance_valid(who) else null
	if r is Rig:
		r.mood = Rig.mood_of(spk, text if text != "" else tr(key))
	if who and is_instance_valid(who) and "talking" in who:
		who.talking = true
	await _wait(d + gap)
	if who and is_instance_valid(who) and "talking" in who:
		who.talking = false
	if r is Rig and is_instance_valid(who):
		r.mood = ""


## Çekimin üstünde büyük yazı: hızla belirir, hold kadar kalır, söner (arka plan kararmaz).
func _over(text: String, hold: float) -> void:
	overlay.text = text
	var tw := create_tween()
	tw.tween_property(overlay, "modulate:a", 1.0, 0.12)
	tw.tween_interval(hold)
	tw.tween_property(overlay, "modulate:a", 0.0, 0.2)


func _flash(color := Color.WHITE, t := 0.5) -> void:
	fade.color = Color(color.r, color.g, color.b, 1.0)
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 0.0, t)


func _person(parent: Node3D, look: Dictionary, pos: Vector3, face_to := Vector3.INF) -> Person:
	var p := Person.new(look)
	parent.add_child(p)
	p.global_position = pos
	if face_to != Vector3.INF:
		p.look_at_from_position(pos, Vector3(face_to.x, pos.y, face_to.z), Vector3.UP)
		p.rotate_y(PI)
	return p


func _face(n: Node3D, at: Vector3) -> void:
	n.look_at_from_position(n.global_position, Vector3(at.x, n.global_position.y, at.z), Vector3.UP)
	n.rotate_y(PI)


## Sert kesme: yeni mekânı kurar, eskisini atar. Arada boş ya da siyah kare olmaz.
func _cut(l: Node3D) -> Node3D:
	add_child(l)
	if level and is_instance_valid(level):
		level.queue_free()
	level = l
	sub_box.visible = false
	fade.color.a = 0.0
	return l


func _cam(pos: Vector3, look: Vector3, fov := 50.0) -> void:
	if _cam_tw and _cam_tw.is_valid():
		_cam_tw.kill()
	cam.fov = fov
	cam.global_position = pos
	cam.look_at(look)


## Kamera yolu (bekletmez): a->b, bakış la->lb, yumuşak.
func _pan(a: Vector3, b: Vector3, la: Vector3, lb: Vector3, secs: float, fov := 50.0) -> void:
	_cam(a, la, fov)
	_cam_tw = create_tween()
	_cam_tw.tween_method(func(k: float):
		var e := smoothstep(0.0, 1.0, k)
		cam.global_position = a.lerp(b, e)
		cam.look_at(la.lerp(lb, e)), 0.0, 1.0, secs)


## Kameranın dibindeki küçük nesneleri (tabela, direk, sandık) gizler: kadrajın önünü kapatmasın.
func _hide_near(r := 2.5) -> void:
	for n in level.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if not mi.visible or mi.mesh == null:
			continue
		var bb := mi.global_transform * mi.get_aabb()
		if bb.size.length() > 6.0:
			continue
		if bb.get_center().distance_to(cam.global_position) < r:
			mi.visible = false


## Kamera ile hedef arasındaki kalabalığı gizler.
func _clear_view(from: Vector3, to: Vector3, keep: Array) -> void:
	for n in find_children("*", "Node3D", true, false):
		if not (n is Person or n is Soldier):
			continue
		var nd := n as Node3D
		if nd in keep or not nd.visible:
			continue
		var p := nd.global_position + Vector3(0, 1.0, 0)
		var seg := to + Vector3(0, 1.0, 0) - from
		var t := clampf((p - from).dot(seg) / seg.length_squared(), 0.0, 1.0)
		if (from + seg * t).distance_to(p) < 1.1:
			nd.visible = false


## Havada dönerek uçuş. lie: sırtüstü döner ve yere yatarak düşer.
func _fly(parent: Node3D, node: Node3D, to: Vector3, peak: float, spin: float, dur: float, lie := false) -> void:
	var from := node.global_position
	var rot0 := node.rotation
	var land := to + (Vector3(0, 0.18, 0) if lie else Vector3.ZERO)
	var tw := create_tween()
	tw.tween_method(func(k: float):
		var p := from.lerp(land, k)
		p.y += sin(k * PI) * peak
		node.global_position = p
		var rx := rot0.x + sin(k * TAU) * 0.6 * spin * (1.0 - k)
		if lie:
			rx = lerpf(rot0.x, -PI / 2.0, smoothstep(0.1, 0.8, k)) + sin(k * PI) * 0.4
		node.rotation = Vector3(rx, rot0.y + k * spin * TAU * (1.0 - k * 0.5), rot0.z + k * spin * 1.4 * (1.0 - k)), 0.0, 1.0, dur)
	tw.tween_callback(func():
		node.rotation = Vector3(-PI / 2.0, rot0.y + spin * PI, 0.0) if lie else rot0
		Vfx.dust(parent, land, 0.5)
		Audio.sfx("land_thud", -8.0))


# ---------------------------------------------------------------- akış

func _run() -> void:
	cam = Camera3D.new()
	add_child(cam)
	cam.current = true
	for a in OS.get_cmdline_user_args():
		if a.begins_with("only="):
			await call("_b_" + a.trim_prefix("only="))
			get_tree().quit()
			return
	if "boom" in OS.get_cmdline_user_args():
		_only_boom = true
		await _b_boom()
		get_tree().quit()
		return
	await _b_cold()
	await _b_garage()
	await _b_slipway()
	await _b_otag()
	await _b_siege()
	await _b_boom()
	await _b_end()
	get_tree().quit()


## 0. Soğuk açılış (oyunun ilk dakikası gibi): gece gedik, ok yağmuru altında kovayla koşan Tolga, "Büyük top!",
## patlama, kare donar (sepya, TOLGA), "Evet. Bu benim...", Nihat "Geri sarıyoruz", kaset gibi geri sarma.
var _vortex: CanvasLayer
var _freeze_mat: ShaderMaterial


func _b_cold() -> void:
	var w := LandWalls.new()
	w.assault_mode = true
	_cut(w)
	w.set_repair(LandWalls.STAGES - 2)
	var a := Assault.new()
	a.keep = Rect2(-40.0, -10.0, 80.0, 36.0)
	a.live_span = 12.0
	w.add_child(a)
	a.build()
	_defenders(w, LandWalls.on_rubble(LandWalls.BREACH + Vector3(0, 0, -2.2)))
	# Gerçek savaş: surda kazanlar, taş/kova taşıyanlar, gedikte örenler, kalkanını başına kaldırıp koşanlar,
	# ok yiyip düşenler, yerde yatanlar (Bölüm 0 ile aynı kalabalık)
	Garrison.land_walls(w, [Vector2(13.0, 19.0), Vector2(-10.4, -6.8), Vector2(6.8, 10.4)], [Vector2(-30.0, 30.0)], [], 26, 30.0, false)
	var fight := WallFight.new()
	w.add_child(fight)
	fight.add_cauldron(Vector3(-8.6, LandWalls.OUTER_H, 15.0), 2639)
	fight.add_builders(LandWalls.BREACH + Vector3(0, 0, -2.6), 2, 2660)
	var bx := BattleExtras.new()
	w.add_child(bx)
	bx.assault = a
	bx.populate(Vector3(-16, 0, 4.4), Vector3(18, 0, 4.4), 2.6, 12, 6, 8, 31)
	var bx2 := BattleExtras.new()
	w.add_child(bx2)
	bx2.assault = a
	bx2.populate(Vector3(-16, 0, 12.9), Vector3(18, 0, 12.9), 0.9, 9, 5, 0, 47)
	var stage := Vector3(3.0, 0.0, 8.6)
	a.quiet_x = stage.x + 7.3      # gözcünün çekimi: önüne gülle tozu düşmesin
	for b: BattleExtras in [bx, bx2]:
		b.avoid(stage + Vector3(-2.0, 0, 0.9), 4.5)
	# 1) Ok yağmuru: Tolga elinde kovayla peribolos boyunca kameraya doğru koşar (gerçek koşu adımı), oklar
	#    çevresine saplanır; kamera önünde geri geri çekilerek onu izler.
	var run_from := stage + Vector3(13.6, 0, -1.0)
	var run_to := stage + Vector3(0.4, 0, -0.1)
	var tolga := _person(w, TOLGA, run_from, run_to)
	_clear_view(run_from + Vector3(0, 0, 0.6), run_to + Vector3(-3.4, 0, 1.3), [tolga])
	for n in w.find_children("*", "Node3D", true, false):
		if (n is Person or n is Soldier) and n != tolga:
			var np := (n as Node3D).global_position
			var seg := Geometry3D.get_closest_point_to_segment(np, run_from, run_to + Vector3(-3.6, 0, 1.3))
			if absf(np.y - seg.y) < 2.0 and Vector2(np.x - seg.x, np.z - seg.z).length() < 1.3:
				(n as Node3D).visible = false
	# Kamera yolunun dibindeki küçük nesneler (siper tahtası, fıçı) kadrajı kapatmasın
	var c0 := run_from + Vector3(-3.6, 1.3, 1.35)
	var c1 := run_to + Vector3(-3.1, 1.15, 1.35)
	for n in w.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh == null or tolga.is_ancestor_of(mi):
			continue
		var bb := mi.global_transform * mi.get_aabb()
		if bb.size.length() > 6.0:
			continue
		var cc := bb.get_center()
		if cc.distance_to(Geometry3D.get_closest_point_to_segment(cc, c0, c1)) < 1.4 + bb.size.length() * 0.5:
			mi.visible = false
	var bucket := Node3D.new()
	var rg: Rig = tolga.rig
	if rg and rg.elbow_r:
		rg.elbow_r.add_child(bucket)
		bucket.position = Vector3(0, -0.5, 0.06)
	else:
		tolga.add_child(bucket)
		bucket.position = Vector3(0.3, 0.55, 0.25)
	# Sağ elde ok demeti (okçulara); sol elde başının üstünde kalkan
	var bdl := BattleExtras.arrow_bundle(bucket)
	bdl.rotation = Vector3(0.3, 0, 0)
	# Sol elde kalkan, başının üstünde (oklara karşı); sağ elde kova
	var shield := BattleExtras.overhead_shield(tolga, Color("7a2a24"), true)
	Audio.music("tension", 0.0)
	Audio.sfx("cannon", -4.0)
	# 0) Açılış: Osmanlı hücumu. Hendeğin karşı kıyısından, aşağıda: dalga dalga sura koşan askerler kameranın iki
	#    yanından geçip hendeğe atlar; merdivenler, surdan inen oklar; gözcünün haykırışı, ordunun uğultusu.
	Audio.sfx("crowd_camp", -3.0)
	Audio.sfx("crowd_gasp", -2.0, 0.7)
	_over(_t("29 MAYIS 1453 · 01.30", "29 MAY 1453 · 1:30 AM"), 1.8)
	for k in 3:
		get_tree().create_timer(0.3 + k * 0.7).timeout.connect(func(): a.volley(Vector3(3.0 + k * 2.0, 0, 30.0), 7.0, 30))
	_pan(Vector3(10.0, 3.4, 50.0), Vector3(7.0, 2.6, 42.0), Vector3(4.0, 0.5, 30.0), Vector3(1.0, 3.5, 16.0), 2.9, 60.0)
	var tm_a := get_tree().create_timer(2.9)     # oyun zamanı (film kaydında gerçek saat yavaş akar)
	await _line(null, "SPK_LOOKOUT", "D26_L_WAVE_1", 0.0, 2.9)
	if tm_a.time_left > 0.0:
		await tm_a.timeout
	# Koşu, Tolga'nın repliği bitene (kesmeye) kadar sürer: kesmeden önce durup beklemez
	var run_t := 3.0
	var run := create_tween()
	run.tween_property(tolga, "global_position", run_to, run_t)
	if _cam_tw and _cam_tw.is_valid():
		_cam_tw.kill()
	cam.fov = 54.0
	var steps := [0.0]
	_cam_tw = create_tween()
	_cam_tw.tween_method(func(k: float):
		var tp := tolga.global_position
		cam.global_position = tp + Vector3(-3.6 + k * 0.5, 1.3 - k * 0.15, 1.35)
		cam.look_at(tp + Vector3(0.9, 1.15, -0.1))
		if k * run_t - float(steps[0]) > 0.27:
			steps[0] = k * run_t
			Audio.sfx("footstep_stone_%d" % (randi() % 4 + 1), -10.0), 0.0, 1.0, run_t)
	# Oklar tam o anda, koşunun önüne ve yanına iner
	for k in 5:
		var at := run_from.lerp(run_to, clampf((k * 0.5 + 0.55) / run_t, 0.0, 1.0))
		get_tree().create_timer(k * 0.5).timeout.connect(func(): a.volley(at + Vector3(0, 0, 0.3), 2.4, 9, true, 0.55))
	Audio.sfx("whoosh_fly", -12.0, 1.3)
	# Kalkana saplanan oklar: gökten iner, "tak" diye kalkanda kalır, kalkan sarsılır
	for t: float in [0.55, 1.15, 1.5, 2.0]:
		get_tree().create_timer(t).timeout.connect(_arrow_to.bind(shield))
	# Tolga, kalkanına oklar saplanırken: "Bu işi her gece mi yapıyorsunuz? Her gece?"
	var tm_b := get_tree().create_timer(run_t - 0.05)
	await _line(tolga, "SPK_TOLGA", "D20_T_DROP_2", 0.3, run_t - 0.35)
	if tm_b.time_left > 0.0:
		await tm_b.timeout
	# 2) Surdaki gözcü dışarıyı gösterip bağırır; sur ardında büyük topun dumanı ve ateşi
	var look_p := Vector3(stage.x + 7.3, LandWalls.OUTER_H, 14.9)
	var lookout := _person(w, {"coat": Color("5a6a7a"), "pants": Color("3a2a22"), "hat": "helm", "beard": true, "mustache": false, "armor": "mail", "n": 377},
		look_p, look_p + Vector3(-2.0, 0, -10.0))
	lookout.set_meta("no_talk", true)
	for n in w.find_children("*", "Node3D", true, false):
		var lp: Vector3 = (n as Node3D).global_position
		if (n is Person or n is Soldier) and n != lookout and Vector2(lp.x - look_p.x, lp.z - look_p.z).length() < 3.6:
			(n as Node3D).visible = false
	w.auto_cover = false
	w.fire_flash()
	Audio.sfx("cannon", -9.0)
	BattleExtras.all_take_cover(w, [tolga, lookout])
	_pan(look_p + Vector3(-2.2, 1.6, -3.0), look_p + Vector3(-1.7, 1.4, -2.5), look_p + Vector3(0.3, 1.4, 1.0), look_p + Vector3(0.6, 1.9, 3.0), 1.9, 50.0)
	lookout.emote("wave")
	await _line(lookout, "SPK_LOOKOUT", "D20_L_WARN_2", 0.0)
	# 3) Tolga durur, başını kaldırıp gökyüzüne bakar: gülle geliyor
	run.kill()
	var up := tolga.global_position + Vector3(0, 1.55, 0)
	for b: BattleExtras in [bx, bx2]:
		b.hide_near(up + Vector3(-2.6, -1.5, 1.2), 3.0)
	_clear_view(up + Vector3(-2.6, -0.2, 1.2), tolga.global_position, [tolga])
	_pan(up + Vector3(-2.6, -0.2, 1.2), up + Vector3(-2.3, -0.3, 1.05), up + Vector3(0, -0.1, 0), up + Vector3(0, 0.05, 0), 0.8, 46.0)
	tolga.look_at_from_position(tolga.global_position, Vector3(stage.x - 10.0, 0, stage.z + 1.0), Vector3.UP)
	tolga.rotate_y(PI)
	Audio.sfx("whoosh_fly", 0.0, 0.6)
	await _wait(0.75)
	if bucket.get_parent() != tolga:
		bucket.reparent(tolga, false)
	# 2) Patlama ve donan kare
	run.kill()
	var tp := stage + Vector3(0, 0.6, 0)
	var cam_p := stage + Vector3(-4.2, 1.55, 0.9)
	_clear_view(cam_p, stage, [tolga])
	for n in w.find_children("*", "Node3D", true, false):
		if (n is Person or n is Soldier) and n != tolga:
			var np := (n as Node3D).global_position
			var bl := stage + Vector3(5.8, 0.2, 1.3)
			var sg := Geometry3D.get_closest_point_to_segment(np, Vector3(cam_p.x, 0, cam_p.z), bl)
			if np.distance_to(bl) < 3.0 or Vector2(np.x - sg.x, np.z - sg.z).length() < 1.9:
				(n as Node3D).visible = false
			elif np.distance_to(bl) < 7.5 and (n as Node3D).visible:
				# Patlamanın yanındakiler de savrulur (havada, patlamadan uzağa devrilmiş)
				var away := Vector3(np.x - bl.x, 0, np.z - bl.z).normalized()
				(n as Node3D).global_position = np + Vector3(0, randf_range(0.5, 1.1), 0) + away * 0.6
				(n as Node3D).rotate(Vector3.UP.cross(away).normalized(), randf_range(0.5, 0.9))
				var nr: Variant = n.get("rig")
				if nr is Rig:
					(nr as Rig).activity = "fall"
	tolga.global_position = tp
	var to_cam := cam_p - tp
	tolga.rotation = Vector3(0, atan2(to_cam.x, to_cam.z), 0)
	tolga.rotate_object_local(Vector3.RIGHT, 0.3)
	tolga.rotate_object_local(Vector3.FORWARD, -0.12)
	# Kollar tam patlama karesinde havaya (önceden kalkmaz): kalkan ve kova elden uçar
	if rg:
		rg.shield_up = 0
		rg.shield_node = null
		rg.arm_l.scale = Vector3.ONE
		rg.lock += 1
		rg.arm_l.rotation = Vector3(-2.9, 0, -0.55)
		rg.arm_r.rotation = Vector3(-2.9, 0, 0.55)
		if rg.elbow_l:
			rg.elbow_l.rotation.x = -0.25
			rg.elbow_r.rotation.x = -0.25
		rg.mood = "surprised"
	# Kameranın dibinde havada asılı kalacak oklar kadrajı kapatmasın
	for n in a.get_children():
		if n is MeshInstance3D and (n as MeshInstance3D).mesh == Assault.arrow_mesh() and (n as Node3D).global_position.distance_to(cam_p) < 4.5:
			(n as Node3D).visible = false
	shield.reparent(tolga, false)
	shield.position = Vector3(-0.9, 2.5, 0.4)
	shield.rotation = Vector3(-0.4, 0.6, 0.9)
	bucket.position = Vector3(-0.3, 2.3, 0.6)
	bucket.rotation = Vector3(0.6, 0.3, 1.1)
	_cam(cam_p, stage + Vector3(0.9, 1.45, -0.1), 52.0)
	Vfx.explosion(w, stage + Vector3(5.8, 0.2, 1.3), 1.0)
	Vfx.frozen_blast(w, stage + Vector3(5.8, 0.2, 1.3), 1.0, 0.12, Vector3(-10.0, 0, -0.4).normalized())
	Audio.sfx("explosion_big", 2.0)
	Audio.music("", 0.0)
	_flash(Color(1.0, 0.75, 0.4), 0.2)
	await _wait(0.14)
	# Işınlanmayı yürüme sanıp gidiş yönüne dönmüş olabilir: donmadan hemen önce yüzü yeniden kameraya
	tolga.global_position = tp
	tolga.rotation = Vector3(0, atan2(to_cam.x, to_cam.z), 0)
	tolga.rotate_object_local(Vector3.RIGHT, 0.3)
	tolga.rotate_object_local(Vector3.FORWARD, -0.12)
	w.process_mode = Node.PROCESS_MODE_DISABLED
	for n in w.find_children("*", "CPUParticles3D", true, false):
		(n as CPUParticles3D).speed_scale = 0.0
	for n in w.find_children("*", "GPUParticles3D", true, false):
		(n as GPUParticles3D).speed_scale = 0.0
	Audio.sfx("stamp", 0.0)
	_freeze_fx(true)
	title.text = "TOLGA"
	title.add_theme_color_override("font_color", Color("ffd24a"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.offset_left = 80
	title.modulate.a = 1.0
	await _wait(0.35)
	await _line(tolga, "SPK_TOLGA", "D0_T_FREEZE_1", 0.05)
	title.modulate.a = 0.0
	await _line(null, "SPK_NIHAT", "D0_N_FREEZE", 0.05)
	# 3) Geri sarma → beyaz
	Audio.sfx("machine_spin", -2.0, 2.2)
	var rw := create_tween().set_parallel(true)
	rw.tween_method(func(v: float): _freeze_mat.set_shader_parameter("rewind", v), 0.0, 1.0, 0.35)
	rw.tween_property(cam, "global_position", cam_p + Vector3(-5.0, 2.5, 1.0), 0.9)
	await _wait(0.8)
	fade.color = Color(1, 1, 1, 0)
	var wt := create_tween()
	wt.tween_property(fade, "color:a", 1.0, 0.2)
	await wt.finished
	_freeze_fx(false)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = 0
	title.add_theme_color_override("font_color", Color("f2e6c9"))


## Kalkana bir ok: surun dışından (üstten, +Z yönünden) 0,35 s'de iner, kalkanın üst yüzüne saplanıp orada kalır.
func _arrow_to(sh: Node3D) -> void:
	if not is_instance_valid(sh):
		return
	var mi := MeshInstance3D.new()
	mi.mesh = Assault.arrow_mesh()
	add_child(mi)
	var off := Vector3(randf_range(-0.14, 0.14), 0.0, randf_range(-0.14, 0.14))
	var from := sh.global_position + Vector3(randf_range(-1.5, 1.5), 7.5, 4.5)
	var fly := func(k: float) -> void:
		if not is_instance_valid(sh):
			return
		var to := sh.global_position + sh.global_basis * off + Vector3(0, 0.03, 0)
		var p := from.lerp(to, k)
		var dir := (to - from).normalized()
		mi.global_transform = Transform3D(Basis.looking_at(-dir, Vector3.UP), p - dir * 0.38)
	var tw := create_tween()
	tw.tween_method(fly, 0.0, 1.0, 0.35)
	tw.tween_callback(func():
		if is_instance_valid(sh) and is_instance_valid(mi):
			mi.reparent(sh)
			Audio.sfx("pick_tap", -4.0, randf_range(0.8, 1.1)))


## Donan kare efekti (sepya, kenar kararması) ve geri sarma parazitleri (Bölüm 0'ın gölgelendiricisi).
func _freeze_fx(on: bool) -> void:
	var rect := get_node_or_null("FreezeFxLayer/FreezeFx") as ColorRect
	if not on:
		if rect:
			rect.get_parent().queue_free()
		return
	var cl := CanvasLayer.new()
	cl.layer = 40
	add_child(cl)
	rect = ColorRect.new()
	cl.add_child(rect)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float amount = 1.0;
uniform float rewind = 0.0;
void fragment() {
	vec2 uv = SCREEN_UV;
	float band = step(0.5, fract(uv.y * 70.0 + TIME * 24.0));
	uv.x += rewind * (sin(uv.y * 38.0 + TIME * 55.0) * 0.012 + (band - 0.5) * 0.006);
	vec3 c = texture(screen_tex, uv).rgb;
	float g = dot(c, vec3(0.3, 0.59, 0.11));
	// Ateş (parlak, sıcak) renginde kalır: sepyanın içinde patlama parlar
	float fire = smoothstep(0.35, 0.6, c.r - c.b) * smoothstep(0.8, 0.97, c.r);
	c = mix(c, vec3(g * 1.1, g * 0.96, g * 0.78), amount * 0.8 * (1.0 - fire * 0.85));
	vec2 d = SCREEN_UV - 0.5;
	c *= 1.0 - dot(d, d) * 1.1 * amount;
	c += rewind * 0.1 * band;
	COLOR = vec4(c, 1.0);
}
"""
	_freeze_mat = ShaderMaterial.new()
	_freeze_mat.shader = sh
	rect.material = _freeze_mat
	cl.name = "FreezeFxLayer"
	rect.name = "FreezeFx"


## 1. Garaj ("Beş hafta önce"): makine, "Takıldı! Tekme lazım!", tekme, zaman tüneli.
func _b_garage() -> void:
	var gg := Garage.new()
	gg.outside = true
	var g := _cut(gg) as Garage
	_flash(Color.WHITE, 0.35)
	_over(_t("BEŞ HAFTA ÖNCE", "FIVE WEEKS EARLIER"), 1.3)
	var m := Garage.PLATFORM_POS
	var pn := g.panel_node.global_position
	# Hikmet panelin yanında (tekmeye iki adım), Tolga makinenin platformunda: ikisi de kadrajda
	var h := Hikmet.new()
	g.add_child(h)
	h.global_position = pn + Vector3(-0.3, 0, 1.15)
	var tolga := _person(g, TOLGA, m + Vector3(0.1, 0.08, 0.35), m + Vector3(0.9, 0, 3.0))
	tolga.rig.mood = "worried"
	_face(h, tolga.global_position)
	h.look_target = tolga
	Audio.music("garage", 0.0)
	Audio.sfx("machine_spin", -6.0)
	g.spin = 0.2
	# Makineye yaklaşan alt açı
	_pan(m + Vector3(-0.9, 0.35, 2.6), m + Vector3(-0.5, 0.55, 1.7), m + Vector3(0, 1.4, 0), m + Vector3(0, 1.5, 0), 1.0, 48.0)
	await _wait(0.9)
	_cam(m + Vector3(-1.3, 1.45, 3.5), m + Vector3(0.7, 1.05, 0.9), 55.0)
	await _line(h, "SPK_HIKMET", "D1_H_26", 0.0)
	h.kick(pn, pn + Vector3(0.1, 0, 0.75))
	await h.kick_hit
	Audio.sfx("kick_metal", 0.0)
	tolga.rig.mood = "surprised"
	tolga.rig.emote("surprise")
	g.spin = 8.0
	Audio.sfx("machine_jump", 0.0)
	_cam(m + Vector3(1.2, 1.2, 1.6), m + Vector3(0, 1.3, 0), 62.0)
	await _wait(0.35)
	# Zaman tüneli: garaj girdaba döner, yıl sayacı 2026 → 1453; Hikmet arkadan seslenir
	_vortex = preload("res://scripts/ui/time_vortex.gd").new()
	add_child(_vortex)
	_say("SPK_HIKMET", "D1_H_30")
	await _vortex.play(2026, 1453, 2.6)


## 2. Dünya: beyaz ışıktan ordugâha açılır; üç hızlı kare.
func _b_world() -> void:
	_cut(CampDay.new())
	_flash(Color.WHITE, 0.45)
	Audio.music("chase", 0.0)
	_pan(Vector3(6, 8, -6), Vector3(4, 12, 4), Vector3(2, 5, 60), Vector3(5, 14, 150), 2.0, 52.0)
	_over(_t("İSTANBUL · 1453", "ISTANBUL · 1453"), 1.3)
	await _wait(1.6)
	var byz := _cut(ByzCity.new()) as ByzCity
	byz.make_sunset()
	_pan(Vector3(24, 20, -38), Vector3(21, 23, -50), Vector3(-14, 10, -84), Vector3(-14, 13, -82), 1.4, 50.0)
	await _wait(1.3)


## 3. Kızak: yağlı yokuş, kadırga, "Frenk casusu!" / "sigortacıyım!" / "Sigortacı ne?"
func _b_slipway() -> void:
	var sl := _cut(Slipway.new()) as Slipway
	if _vortex and is_instance_valid(_vortex):
		_vortex.queue_free()
		_flash(Color.WHITE, 0.4)
	var tolga := _person(sl, TOLGA, sl.s_to_world(16.0), sl.s_to_world(40.0))
	var slide := create_tween()
	slide.tween_method(func(s: float):
		tolga.global_position = sl.s_to_world(s)
		sl.set_ship_s(s - 14.0), 16.0, 34.0, 8.0)
	_cam_tw = create_tween()
	_cam_tw.tween_method(func(k: float):
		var s := lerpf(16.0, 20.0, k)
		cam.global_position = sl.s_to_world(s + 4.2, 1.3, 1.7)
		cam.look_at(sl.s_to_world(s - 3.0, 0.2, 2.2)), 0.0, 1.0, 1.4)
	cam.fov = 58.0
	tolga.emote("surprise")
	await _wait(1.1)
	var sol := Soldier.new(Color("b3262d"), "point", "bork")
	sl.add_child(sol)
	var sp := sl.s_to_world(33.0, 4.6, 0.0)
	sol.global_position = sp
	_face(sol, tolga.global_position)
	_cam(sp + (tolga.global_position - sp).normalized() * 2.2 + Vector3(0.6, 1.75, 0), sp + Vector3(0, 1.7, 0), 42.0)
	await _line(sol, "SPK_SOLDIER", "D2_S_14", 0.0)
	# Tolga yakın: kamera onunla birlikte kayar (sabit kalırsa Tolga ve arkasındaki gemi kameranın içinden geçer)
	var dn := (sl.s_to_world(40.0) - sl.s_to_world(20.0)).normalized()
	cam.fov = 40.0
	_cam_tw = create_tween()
	_cam_tw.tween_method(func(_k: float):
		var tf := tolga.global_position + Vector3(0, 1.55, 0)
		cam.global_position = tf + dn * 2.2 + Vector3(0, 0.25, 0) + dn.cross(Vector3.UP) * 0.5
		cam.look_at(tf), 0.0, 1.0, 3.2)
	await _line(tolga, "SPK_TOLGA", "D2_T_15", 0.0)
	var st := tolga.global_position - sp
	st.y = 0
	_cam(sp + st.normalized() * 1.9 + Vector3(0, 1.72, 0) + st.normalized().cross(Vector3.UP) * 0.4, sp + Vector3(0, 1.68, 0), 36.0)
	sol.pose = "stand"
	await _line(sol, "SPK_SOLDIER", "D2_S_16", 0.35)
	slide.kill()


## 4. Otağ: "Bu şehir alınacak mı?" / "Evet. 29 Mayıs'ta. Salı günü."
func _b_otag() -> void:
	var o := _cut(OtagHall.new())
	Audio.music("audience", 0.0)
	for n in [o.get("fatih"), o.get("scribe")]:
		if n is Node3D:
			(n as Node3D).visible = false
	var th := OtagHall.THRONE
	var f := _person(o, FATIH, th + Vector3(0, 0, 0.3), th + Vector3(0, 0, 5))
	f.scale = Vector3.ONE * 1.06
	var z := th.z + 3.2
	var tolga := _person(o, TOLGA, Vector3(-0.6, 0, z), th)
	var ff := f.global_position + Vector3(0, 1.85, 0)
	_pan(Vector3(-0.5, 1.95, z - 0.4), Vector3(-0.4, 1.95, z - 0.9), ff, ff, 3.6, 40.0)
	await _line(f, "SPK_FATIH", "D12_F_KEY", 0.05)
	# Cevap vermez: "Hmm..." der, lise tarih kitabını çıkarıp karıştırır. Fatih bekler (cevap fragmanda yok).
	# Kitap iki elde: kollar öne uzanır, kitap iki elin tam ortasında durur (havada asılı kalmaz)
	var book := Items.open_book()
	tolga.add_child(book)
	book.rotation = Vector3(0.75, 0.0, 0.0)
	book.scale = Vector3.ONE * 1.1
	var rg: Rig = tolga.rig
	rg.lock += 1
	rg.arm_l.rotation = Vector3(-0.85, 0.0, 0.32)
	rg.arm_r.rotation = Vector3(-0.85, 0.0, -0.32)
	rg.elbow_l.rotation = Vector3(-0.95, 0.0, 0.0)
	rg.elbow_r.rotation = Vector3(-0.95, 0.0, 0.0)
	if rg.head:
		rg.head.rotation.x = 0.3
	var hold := func():
		if is_instance_valid(book):
			var hl := tolga.to_local(rg.elbow_l.global_transform * Vector3(0, -0.3, 0.04))
			var hr := tolga.to_local(rg.elbow_r.global_transform * Vector3(0, -0.3, 0.04))
			book.position = (hl + hr) * 0.5 + Vector3(0, 0.03, 0.02)
	hold.call()
	get_tree().process_frame.connect(hold)
	_cam(Vector3(-0.45, 2.0, z - 1.45), tolga.global_position + Vector3(0, 1.35, 0), 48.0)
	Items.flip_pages(book, 9, 0.24)
	Audio.sfx("newspaper", -8.0)
	await _line(tolga, "SPK_TOLGA", "D12_T_KEY_HMM", 0.1, 3.2,
		_t("Hmm... Bir saniye... Bin dört yüz elli üç...", "Hmm... One second... Fourteen fifty-three..."))
	_cam(Vector3(-0.3, 2.0, z - 0.9), ff, 34.0)
	await _wait(1.0)
	get_tree().process_frame.disconnect(hold)


## 5. Kuşatma: gece hücumu, hendek kıyısı, gedik, Urban'ın büyük topu, "Madde 9".
func _b_siege() -> void:
	var w := LandWalls.new()
	w.assault_mode = true
	_cut(w)
	w.set_repair(LandWalls.STAGES - 3)
	var a := Assault.new()
	a.keep = Rect2(-3.0, 60.0, 6.0, 4.0)
	w.add_child(a)
	a.build()
	var tolga := _person(w, TOLGA, LandWalls.BREACH + Vector3(-1.2, 0, -7.0), LandWalls.BREACH + Vector3(-2.0, 0, 0))
	_defenders(w, LandWalls.BREACH + Vector3(-1.2, 0, -7.0))
	Audio.music("tension", 0.0)
	Audio.sfx("cannon", -2.0)
	_pan(Vector3(30, 15, 76), Vector3(16, 11, 58), Vector3(-2, 6, 16), Vector3(0, 6, 15), 3.0, 56.0)
	_over(_t("KUŞATMA", "THE SIEGE"), 1.6)
	await _wait(0.4)
	await _line(null, "SPK_LOOKOUT", "D26_L_WAVE_1", 0.0, 2.2, _t("Davullar! Azaplar geliyor!", "Drums! The irregulars are coming!"))
	# Gedik: Tolga, savunucuların arasında
	var th := tolga.global_position + Vector3(0, 1.6, 0)
	_pan(th + Vector3(0.7, 0.1, 2.0), th + Vector3(0.5, 0.1, 1.6), th, th, 2.6, 40.0)
	await _line(tolga, "SPK_TOLGA", "D20_T_DUEL", 0.05)
	# Nihat'ın sesi hendek kıyısından, sura koşan dalgaların, merdivenlerin üstünde: Madde 9
	_pan(Vector3(9, 2.2, 40), Vector3(4, 3.0, 34), Vector3(-2, 5, 15), Vector3(-7, 6, 15), 5.6, 52.0)
	await _line(null, "SPK_NIHAT", "D17_N_POLICY", 0.0)
	# ...ve gündüz Urban'ın büyük topu, güllesi tam Tolga'nın başının üstüne
	var d := LandWalls.new()
	_cut(d)
	d.make_day()
	d.field.bombard = true
	d.set_repair(LandWalls.STAGES)
	var gun := d.build_great_gun()
	var urban := _person(d, URBAN, gun.position + Vector3(3.2, 0, 3.4), gun.position + Vector3(-2, 0, 8))
	urban.emote("cheer")
	# Tolga gediğin içinde, barikatın arkasında, sırtı sura dönük; yanında savunucular
	var tp := LandWalls.on_rubble(LandWalls.BREACH + Vector3(-2.5, 0, -4.2))
	var t2 := _person(d, TOLGA, tp, tp + Vector3(0, 0, -10))
	_defenders(d, tp)
	_cam(gun.position + Vector3(2.6, 3.2, 9.0), LandWalls.BREACH + Vector3(0, 5, 0), 50.0)
	# Siperlik halatlarla kalkar, sonra ateş
	await _wait(d.gun_screen(true, 0.55))
	d.fire_flash()
	Audio.sfx("cannon", 0.0)
	_flash(Color(1, 0.9, 0.7), 0.3)
	await _wait(0.6)
	var tt := t2.global_position + Vector3(0, 1.5, 0)
	_cam(tt + Vector3(0.9, 0.15, -2.4), tt + Vector3(-0.3, 0.9, 0), 52.0)
	d.impact(LandWalls.BREACH + Vector3(-5.2, 6.0, 0.4))
	Audio.sfx("explosion_big", -2.0)
	t2.emote("surprise")
	var shake := create_tween()
	for i in 6:
		shake.tween_property(cam, "h_offset", 0.12 * (1 if i % 2 == 0 else -1), 0.05)
	shake.tween_property(cam, "h_offset", 0.0, 0.05)
	await _wait(0.5)
	Audio.sfx("ear_ring", -12.0)
	await _line(t2, "SPK_TOLGA", "D20_T_KNOCK_3", 0.1, 1.35, _t("Kulağımda çınlama var.", "My ears are ringing."))


## Bizans savunucuları (miğferli, mızraklı): Tolga surda yalnız durmasın.
func _defenders(parent: Node3D, around: Vector3) -> void:
	var spots := [Vector3(-2.2, 0, 1.2), Vector3(1.8, 0, 1.6), Vector3(-3.4, 0, -0.8), Vector3(3.0, 0, -0.4), Vector3(0.4, 0, 2.6)]
	for i in spots.size():
		var p := LandWalls.on_rubble(around + spots[i])
		var d := _person(parent, {"coat": [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96")][i % 3], "pants": Color("3a2a22"), "hat": "helm",
			"beard": i % 2 == 0, "mustache": true, "n": 300 + i}, p, p + Vector3(0, 0, 10))
		d.set_meta("no_talk", true)


## 6. Büyük atış: "KULAKLARI TIKAYIN!", "Hmm", ağır çekim, Fatih kıpırdamaz; sigorta.
func _b_boom() -> void:
	var day := _cut(CampDay.new()) as CampDay
	var urban := day.urban
	urban.set_activity("")
	urban.position = URBAN_AT
	_face(urban, TOLGA_AT)
	var tolga := _person(day, TOLGA, TOLGA_AT, CANNON)
	var fatih := _person(day, FATIH, FATIH_AT, CANNON)
	fatih.scale = Vector3.ONE * 1.06
	var hasan := Soldier.new(Color("b3262d"), "stand", "bork")
	var huseyin := Soldier.new(Color("2f5fa8"), "stand", "bork")
	day.add_child(hasan)
	day.add_child(huseyin)
	hasan.global_position = FATIH_AT + Vector3(-1.2, 0, 1.0)
	huseyin.global_position = FATIH_AT + Vector3(1.2, 0, 1.0)
	var gunners: Array = []
	for i in 3:
		var gn := Soldier.new(Color("7a5a2a"), "stand", "turban")
		day.add_child(gn)
		gn.global_position = CANNON + Vector3(-3.0 + i * 1.3, 0, -3.0 - (i % 2) * 0.8)
		gn.rotation.y = PI * 0.2
		gunners.append(gn)
	day.goat.position = CANNON + Vector3(-2.5, 0, -3.5)
	var chicken := Chicken.new()
	day.add_child(chicken)
	chicken.position = CANNON + Vector3(4.0, 0, 3.0)
	var u2t := (TOLGA_AT - URBAN_AT).normalized()
	var side := u2t.cross(Vector3.UP)
	var uf := URBAN_AT + Vector3(0, 1.62, 0)
	var tf := TOLGA_AT + Vector3(0, 1.55, 0)
	if not _only_boom:
		Audio.music("tension", 0.0)
		Audio.sfx("fuse_burn", -4.0)
		_cam(URBAN_AT + u2t * 2.0 + Vector3(0, 1.7, 0) - side * 0.6, uf, 42.0)
		_hide_near(1.2)
		urban.emote("surprise")
		await _line(urban, "SPK_URBAN", "D10B_U_EARS", 0.1)
		_cam(URBAN_AT + u2t * 1.6 + Vector3(0, 1.7, 0) + side * 0.3, uf, 30.0)
		await _line(urban, "SPK_URBAN", "D10B_U_B3_1", 0.25)
		_cam(TOLGA_AT - u2t * 1.5 + Vector3(0, 1.72, 0) - side * 0.35, tf, 34.0)
		_clear_view(cam.global_position, TOLGA_AT, [tolga, urban])
		await _line(tolga, "SPK_TOLGA", "D10B_T_B3_2", 0.0, 3.2 if not _en else 2.6)
	# BOOM: geniş plan, beyaz ışık, ağır çekim
	_cam(CANNON + Vector3(-11.0, 3.4, 4.0), CANNON + Vector3(2.0, 3.6, -0.5), 64.0)
	Audio.music("", 0.0)
	Audio.sfx("explosion_big", 3.0)
	_flash(Color.WHITE, 0.5)
	Vfx.explosion(day, CANNON + Vector3(0, 1.3, 0), 1.3)
	day.cannon.visible = false
	Audio.music("explosion_slowmo", 0.05)
	Engine.time_scale = 0.28
	var kitchen := Vector3(-13.0, 0, -8.8)
	var tolga_land := FATIH_AT + Vector3(-1.6, 0, -1.0)
	var flights: Array = [
		[tolga, tolga_land, 9.0, 2.0],
		[hasan, kitchen + Vector3(-1.8, 0.45, 0), 12.0, 3.0],
		[huseyin, kitchen + Vector3(0.0, 0.45, 0), 12.5, -3.0],
		[urban, CANNON + Vector3(3.2, 0.4, 1.8), 7.0, 1.5],
		[day.goat, GOAT_TENT + Vector3(0, 2.75, 0), 10.0, 4.0],
		[chicken, CANNON + Vector3(-6.0, 0, 9.0), 14.0, 6.0],
	]
	for i in gunners.size():
		flights.append([gunners[i], CANNON + Vector3(-9.0 + i * 5.0, 0, -9.0 + i * 3.0), 8.0 + i * 2.0, 2.5])
	var dur := 1.1
	for fl in flights:
		_fly(day, fl[0], fl[1], fl[2], fl[3], dur, fl[0] == tolga)
	Audio.sfx("whoosh_fly", -4.0)
	Audio.sfx("crowd_gasp", -8.0)
	create_tween().tween_method(func(k: float):
		cam.global_position = CANNON + Vector3(-11.0, 3.4, 4.0).lerp(Vector3(-9.0, 8.5, 13.0), k)
		cam.look_at(tolga.global_position + Vector3(0, 1.0, 0), Vector3.UP), 0.0, 1.0, dur)
	await get_tree().create_timer(dur * 0.35).timeout
	_say("SPK_TOLGA", "D10B_T_B3_AIR")
	await get_tree().create_timer(dur * 0.7).timeout
	Engine.time_scale = 1.0
	Audio.sfx("ear_ring", -10.0)
	Audio.music("", 0.0)
	# Sonrası: Fatih kıpırdamamış, yüzünde tek is lekesi; Tolga sırtüstü yerde
	Vfx.soot(fatih, 1.62, false)
	for p in [tolga, urban, hasan, huseyin] + gunners:
		Vfx.soot(p)
	tolga.rotation = Vector3(-PI / 2.0, tolga.rotation.y, 0)
	tolga.global_position.y = 0.18
	var f2c := (Vector3(CANNON.x, 0, CANNON.z) - FATIH_AT).normalized()
	var mid := FATIH_AT + Vector3(-0.8, 0, -0.5)
	_cam(FATIH_AT + f2c * 3.6 + Vector3(0, 1.4, 0) + f2c.cross(Vector3.UP) * 0.7, FATIH_AT + Vector3(-0.5, 0.9, 0) + f2c * 0.8, 50.0)
	_hide_near(2.0)
	_clear_view(cam.global_position, mid, [tolga, fatih])
	if _only_boom:
		await _wait(1.8)
		return
	await _wait(0.3)
	await _line(fatih, "SPK_FATIH", "D10B_F_B3_1", 0.2, 0.0, _t("...Urban.", "...Urban."))
	var up := urban.global_position
	var ufw := urban.global_transform.basis.z
	ufw.y = 0
	_cam(up + ufw.normalized() * 2.0 + Vector3(0.3, 1.4, 0), up + Vector3(0, 1.2, 0), 42.0)
	_hide_near(1.2)
	await _line(urban, "SPK_URBAN", "D10B_U_B3_4", 0.15, 0.0, _t("Efendim.", "My Sultan."))
	var ff := fatih.global_position + Vector3(0, 1.75, 0)
	_face(fatih, tolga_land)
	_cam(ff + f2c * 1.8 + Vector3(0, 0.05, 0) + f2c.cross(Vector3.UP) * 0.4, ff, 36.0)
	await _line(fatih, "SPK_FATIH", "D10B_F_B3_4", 0.05)
	var head := tolga.global_position + tolga.global_transform.basis.y * 1.5
	_cam(head + Vector3(0, 1.6, 0.4), head, 50.0)
	await _line(tolga, "SPK_TOLGA", "D10B_T_B3_5", 0.1)
	_cam(ff + f2c * 1.8 + f2c.cross(Vector3.UP) * 0.4, ff, 36.0)
	await _line(fatih, "SPK_FATIH", "D10B_F_B3_5", 0.3, 0.0, _t("Yazık.", "A pity."))


## 7. Son: başlık ve bilgiler, sonra tavuk.
func _b_end() -> void:
	fade.color = Color(0, 0, 0, 1)
	sub_box.visible = false
	Audio.music("credits", 0.0)
	Audio.sfx("cannon", -6.0)
	title.text = _t("Gerçek Tarih Bu Değil", "Not a History Game")
	tagline.text = _t("27 bölüm · 23 final · kuşatma iki taraftan\nSteam'de istek listene ekle",
		"27 chapters · 23 endings · the siege from both sides\nWishlist it on Steam")
	var tt := create_tween().set_parallel(true)
	tt.tween_property(title, "modulate:a", 1.0, 0.25)
	tt.tween_property(tagline, "modulate:a", 1.0, 0.4).set_delay(0.35)
	await _wait(2.9)
	title.modulate.a = 0.0
	tagline.modulate.a = 0.0
	# Tavuk: kaçar, iki asker peşinde
	var day := _cut(CampDay.new())
	var chicken := Chicken.new()
	day.add_child(chicken)
	var a := Vector3(-4.0, 0, 6.0)
	var b := Vector3(8.0, 0, 1.2)
	chicken.global_position = a
	var hasan := Soldier.new(Color("b3262d"), "stand", "bork")
	var huseyin := Soldier.new(Color("2f5fa8"), "stand", "bork")
	day.add_child(hasan)
	day.add_child(huseyin)
	for s in [hasan, huseyin]:
		s.global_position = a + Vector3(-2.5, 0, 0.6 if s == hasan else -0.6)
		_face(s, b)
	chicken.look_at_from_position(a, b, Vector3.UP)
	chicken.rotate_y(PI)
	chicken.flapping = true
	var run := 3.2
	_cam_tw = create_tween()
	_cam_tw.tween_method(func(k: float):
		var cp := a.lerp(b, k)
		cam.global_position = cp + Vector3(0.6, 0.55, 3.4)
		cam.look_at(cp + Vector3(-1.6, 0.6, 0)), 0.0, 1.0, run)
	cam.fov = 50.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(chicken, "global_position", b, run)
	tw.tween_property(hasan, "global_position", b + Vector3(-2.2, 0, 0.6), run)
	tw.tween_property(huseyin, "global_position", b + Vector3(-2.6, 0, -0.6), run)
	Audio.sfx("chicken", -4.0)
	await _line(hasan, "SPK_HASAN", "D16_G_CATCH_1", 0.1, 0.0, _t("Tavuk! Hüseyin, tavuk kaçıyor!", "Chicken! Hüseyin, the chicken's getting away!"))
	fade.color = Color(0, 0, 0, 1)
	sub_box.visible = false
	title.text = _t("Gerçek Tarih Bu Değil", "Not a History Game")
	title.modulate.a = 1.0
	await _wait(1.0)
