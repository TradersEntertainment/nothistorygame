extends Node3D
## Steam fragmanı (sesli, altyazılı, ~100 sn). Kurgu: her çekimde bir espri, sert kesmeler, müzik perdeleri.
##   0 Garaj: "Zamanatör 3000" · "yirmi belgesel" · "Takıldı! Tekme lazım!" -> beyaz ışık
##   1 Kızak: yağlı yokuş, arkada gemi · "Frenk casusu!" · "sigortacıyım!" · "Sigortacı ne?"
##   2 Dünya: ordugâh ("pazartesi bütçe toplantım var"), gün batımında Ayasofya, Galata, Giustiniani'ye
##     "kuşatma hariç" poliçe, kanlı ay ("alamet değil, telefon")
##   3 Fatih'in huzuru: "gecelikle, formla ve fesle?" · "Bu şehir alınacak mı?" · "29 Mayıs. Salı."
##   4 BÜYÜK ATIŞ: barut, "sıcak kutu", "şaka olarak söylemiştim", ağır çekimde herkes uçar; Fatih: "Urban."
##     "Efendim." · "sigortalamış mıydın?" · "Hayır." · "Yazık."; Kadri: "KİM BUNLARI ÇORBAYA ATTI?!"
##   5 Nihat: "Denetçiler koşmaz" · tavuk kovalamacası · başlık · pazartesi 09:00 toplantısı (açılışa dönüş)
## Seslendirme assets/audio/voice/tr, müzik assets/audio/music. Arayüz yok; altyazı ve başlık kartları kendi katmanında.
## Kayıt (docs/STEAM.md):
##   godot --path . --write-movie fragman.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn
## İngilizce fragman (İngilizce seslendirme, altyazı ve kartlar):
##   godot --path . --write-movie fragman_en.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn -- en
## Yalnız patlama (site GIF'i, altyazısız):
##   godot --path . --write-movie kare.png --fixed-fps 20 --resolution 800x450 res://tools/trailer/trailer.tscn -- boom

const FADE := 0.35
var VOICE_DIR := "res://assets/audio/voice/tr/"
var _en := false
const CANNON := Vector3(3.0, 0.0, -21.0)
const URBAN_AT := Vector3(5.8, 0.0, -23.6)
const TOLGA_AT := Vector3(5.4, 0.0, -16.0)
const FATIH_AT := Vector3(11.0, 0.0, -16.2)
const GOAT_TENT := Vector3(19.0, 0.0, -12.0)
const TOLGA := {"face": "tolga", "coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")}
const FATIH := {"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true, "robe": Color("c8323a"),
	"hair": Color("2a1e14"), "skin": Color("e0b08a")}
const NIHAT := {"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true, "hair": Color("3a2a1e"), "skin": Color("ecb892")}

var cam: Camera3D
var fade: ColorRect
var title: Label
var tagline: Label
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
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cl.add_child(fade)
	title = _big_label(96)
	cl.add_child(title)
	tagline = _big_label(40)
	tagline.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	tagline.offset_bottom = -170
	cl.add_child(tagline)
	# Altyazı: alt ortada, konuşanın adı renkli
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


## Fragmanın dile göre sabit metinleri (kartlar, kısaltılmış altyazılar)
func _t(tr_text: String, en_text: String) -> String:
	return en_text if _en else tr_text


func _big_label(size: int) -> Label:
	var l := Label.new()
	l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", _font_title)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("f2e6c9"))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 6)
	l.modulate.a = 0.0
	return l


# ---------------------------------------------------------------- yardımcılar

func _wait(t: float) -> void:
	await get_tree().create_timer(t).timeout


## Seslendirme + altyazı. cut > 0: o kadar saniye sonra ses kısılır (uzun replikten bir parça).
## Döner: süre (bekleme çağırana kalmış).
func _say(spk: String, key: String, cut := 0.0, text_override := "") -> float:
	var path := VOICE_DIR + key + ".mp3"
	var dur := 1.8
	if ResourceLoader.exists(path):
		var s: AudioStream = load(path)
		voice.stream = s
		voice.volume_db = 2.0
		voice.play()
		dur = s.get_length()
	var txt := text_override if text_override != "" else tr(key)
	# Sahne notlarını (parantez içleri) altyazıdan at
	var rx := RegEx.new()
	rx.compile("\\([^)]*\\)")
	txt = rx.sub(txt, "", true).strip_edges().replace("  ", " ")
	sub_name.text = tr(spk).to_upper()
	sub_name.add_theme_color_override("font_color", Hud.SPEAKER_COLORS.get(spk, Color("ffd24a")))
	sub_text.text = txt
	sub_box.visible = not _only_boom
	if cut > 0.0 and cut < dur:
		dur = cut
		var tw := create_tween()
		tw.tween_interval(maxf(cut - 0.35, 0.0))
		tw.tween_property(voice, "volume_db", -40.0, 0.35)
	var my := sub_text.text
	get_tree().create_timer(dur + 0.25).timeout.connect(func():
		if sub_text.text == my:
			sub_box.visible = false)
	return dur


func _card(text: String, hold: float, big := false) -> void:
	var l := title if big else tagline
	l.text = text
	var tw := create_tween()
	tw.tween_property(l, "modulate:a", 1.0, 0.3)
	tw.tween_interval(hold)
	tw.tween_property(l, "modulate:a", 0.0, 0.3)


func _flash(color := Color.WHITE, t := 0.5) -> void:
	fade.color = Color(color.r, color.g, color.b, 1.0)
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 0.0, t)
	tw.tween_callback(func(): fade.color = Color(0, 0, 0, 0))


func _person(parent: Node3D, look: Dictionary, pos: Vector3, face_to := Vector3.INF) -> Person:
	var p := Person.new(look)
	parent.add_child(p)
	p.global_position = pos
	if face_to != Vector3.INF:
		p.look_at_from_position(pos, Vector3(face_to.x, pos.y, face_to.z), Vector3.UP)
		p.rotate_y(PI)
	return p


## Kamera çekimi: a->b ve bakış la->lb, süre boyunca yumuşak geçiş. events: [[saniye, Callable], ...]
func _shot(level: Node3D, a: Vector3, b: Vector3, la: Vector3, lb: Vector3, secs: float, prep := Callable(), fov := 62.0, events: Array = []) -> void:
	if level.get_parent() == null:
		add_child(level)
	if prep.is_valid():
		prep.call(level)
	cam = Camera3D.new()
	cam.fov = fov
	add_child(cam)
	cam.current = true
	cam.global_position = a
	cam.look_at(la)
	await get_tree().create_timer(0.5).timeout
	var t := 0.0
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 0.0, FADE)
	var ev := events.duplicate()
	while t < secs:
		var k := smoothstep(0.0, 1.0, t / secs)
		cam.global_position = a.lerp(b, k)
		cam.look_at(la.lerp(lb, k))
		while not ev.is_empty() and t >= float(ev[0][0]):
			(ev.pop_front()[1] as Callable).call()
		await get_tree().process_frame
		t += get_process_delta_time()
	tw = create_tween()
	tw.tween_property(fade, "color:a", 1.0, FADE)
	await tw.finished
	cam.queue_free()
	level.queue_free()
	await get_tree().process_frame


# ---------------------------------------------------------------- sahne yönetimi

var level: Node3D
var _cam_tw: Tween


## Sert kesme: yeni mekânı kurar, eskisini atar (arada boş kare olmaz).
func _cut(l: Node3D) -> Node3D:
	add_child(l)
	if level and is_instance_valid(level):
		level.queue_free()
	level = l
	sub_box.visible = false
	return l


func _cam(pos: Vector3, look: Vector3, fov := 50.0) -> void:
	if _cam_tw and _cam_tw.is_valid():
		_cam_tw.kill()
	cam.fov = fov
	cam.global_position = pos
	cam.look_at(look)


## Kamera yolu (bekletmez): a->b, bakış la->lb, yumuşak.
func _pan(a: Vector3, b: Vector3, la: Vector3, lb: Vector3, secs: float) -> void:
	_cam(a, la, cam.fov)
	_cam_tw = create_tween()
	_cam_tw.tween_method(func(k: float):
		var e := smoothstep(0.0, 1.0, k)
		cam.global_position = a.lerp(b, e)
		cam.look_at(la.lerp(lb, e)), 0.0, 1.0, secs)


## Konuşan karakterin ağzı ve elleri oynar; süre kadar bekler (+ boşluk).
func _line(who: Node, spk: String, key: String, gap := 0.12, cut := 0.0, text := "") -> void:
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


func _black(t := 0.25) -> void:
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 1.0, t)
	await tw.finished


func _unblack(t := 0.2) -> void:
	create_tween().tween_property(fade, "color:a", 0.0, t)


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


func _face(n: Node3D, at: Vector3) -> void:
	n.look_at_from_position(n.global_position, Vector3(at.x, n.global_position.y, at.z), Vector3.UP)
	n.rotate_y(PI)


# ---------------------------------------------------------------- akış

func _run() -> void:
	cam = Camera3D.new()
	add_child(cam)
	cam.current = true
	for a in OS.get_cmdline_user_args():
		if a.begins_with("only="):
			# Tek perde önizlemesi: -- only=world (garage, slipway, world, fatih, boom, finale)
			fade.color = Color(0, 0, 0, 0)
			await call("_act_" + a.trim_prefix("only="))
			get_tree().quit()
			return
	if "boom" in OS.get_cmdline_user_args():
		_only_boom = true
		await _act_boom()
		get_tree().quit()
		return
	await _act_garage()
	await _act_slipway()
	await _act_world()
	await _act_fatih()
	await _act_boom()
	await _act_finale()
	get_tree().quit()


## 0. Garaj, gece üç: Hikmet'in buluşu, Tolga'nın aklı, tekme, ışık.
func _act_garage() -> void:
	var g := _cut(Garage.new()) as Garage
	var hk := Garage.HIKMET_POS
	var tp := hk + Vector3(1.6, 0, 0.9)
	var h := Hikmet.new()
	g.add_child(h)
	h.global_position = hk
	_face(h, tp)
	var tolga := _person(g, TOLGA, tp, hk)
	Audio.music("garage", 0.0)
	Audio.sfx("machine_spin", -6.0)
	var m := Garage.PLATFORM_POS
	# Makine: alttan, dönen halkalara yaklaşan kamera
	_pan(m + Vector3(-0.9, 0.35, 2.5), m + Vector3(-0.5, 0.5, 1.8), m + Vector3(0, 1.4, 0), m + Vector3(0, 1.5, 0), 3.2)
	cam.fov = 48.0
	await _wait(0.3)
	_unblack(0.5)
	await _line(h, "SPK_HIKMET", "D1_H_04", 0.25)
	# İkili: Tolga'nın büyük fikri
	_pan(hk + Vector3(0.6, 1.5, 3.2), hk + Vector3(0.9, 1.45, 2.6), hk + Vector3(0.5, 1.35, 0), (hk + tp) * 0.5 + Vector3(0, 1.4, 0), 6.0)
	cam.fov = 50.0
	tolga.emote("cheer")
	await _line(tolga, "SPK_TOLGA", "D1_T_07", 0.15)
	# Hikmet yakın: tek sorun
	var hf := hk + Vector3(0, 1.55, 0)
	_pan(tp + Vector3(-0.2, 1.62, 0.2), tp + Vector3(-0.4, 1.6, 0.05), hf, hf, 4.4)
	cam.fov = 38.0
	await _line(h, "SPK_HIKMET", "D1_H_06", 0.1)
	# Takıldı! Tekme.
	_cam(m + Vector3(2.4, 1.3, 2.4), m + Vector3(-0.3, 0.9, 0), 55.0)
	g.spin = 0.2
	await _line(h, "SPK_HIKMET", "D1_H_26", 0.0)
	h.kick(g.panel_node.global_position, g.panel_node.global_position + Vector3(0.8, 0, 0.4))
	await _wait(0.55)
	Audio.sfx("kick_metal", 0.0)
	g.spin = 6.0
	Audio.sfx("machine_jump", 0.0)
	await _wait(0.35)
	Audio.sfx("whoosh_fly", 0.0)
	fade.color = Color(1, 1, 1, 1)
	await _wait(0.35)
	create_tween().tween_property(fade, "color", Color(0, 0, 0, 1), 0.5)
	await _wait(0.4)
	_card("1453", 0.7, true)
	await _wait(1.1)


## 1. Kızak: yağlı yokuş, arkadan gelen kadırga, casus sanan askerler.
func _act_slipway() -> void:
	var sl := _cut(Slipway.new()) as Slipway
	Audio.music("chase", 0.0)
	var tolga := _person(sl, TOLGA, sl.s_to_world(14.0), sl.s_to_world(40.0))
	var ship_s := -4.0
	sl.set_ship_s(ship_s)
	# Tolga yokuş aşağı kayar, kadırga arkasından gelir (kamera aşağıdan, yokuşa bakar)
	var slide := create_tween().set_parallel(true)
	slide.tween_method(func(s: float):
		tolga.global_position = sl.s_to_world(s)
		sl.set_ship_s(s - 16.0), 14.0, 40.0, 11.0)
	# Kamera Tolga'nın önünde, onunla birlikte kayar: yüzü ve arkasında büyüyen kadırga
	var track := func(k: float):
		var s := lerpf(14.0, 22.0, k)
		cam.global_position = sl.s_to_world(s + 4.2, 1.3, 1.7)
		cam.look_at(sl.s_to_world(s - 3.0, 0.2, 2.2))
	_cam_tw = create_tween()
	_cam_tw.tween_method(track, 0.0, 1.0, 5.2)
	cam.fov = 58.0
	_unblack(0.15)
	tolga.emote("surprise")
	await _line(tolga, "SPK_TOLGA", "D2_T_03", 0.1)
	# Asker: yokuşun kenarında, gösteriyor
	var sol := Soldier.new(Color("b3262d"), "point", "bork")
	sl.add_child(sol)
	var sp := sl.s_to_world(33.0, 4.6, 0.0)
	sol.global_position = sp
	_face(sol, tolga.global_position)
	_cam(sp + (tolga.global_position - sp).normalized() * 2.2 + Vector3(0.6, 1.75, 0), sp + Vector3(0, 1.7, 0), 42.0)
	await _line(sol, "SPK_SOLDIER", "D2_S_14", 0.05)
	# Tolga yakın, kayarken
	var tf := tolga.global_position + Vector3(0, 1.55, 0)
	var dn := (sl.s_to_world(40.0) - sl.s_to_world(20.0)).normalized()
	_cam(tf + dn * 2.2 + Vector3(0, 0.25, 0) + dn.cross(Vector3.UP) * 0.5, tf, 40.0)
	await _line(tolga, "SPK_TOLGA", "D2_T_15", 0.05)
	# Asker, şaşkın
	var st := (tolga.global_position - sp)
	st.y = 0
	_cam(sp + st.normalized() * 1.9 + Vector3(0, 1.72, 0) + st.normalized().cross(Vector3.UP) * 0.4, sp + Vector3(0, 1.68, 0), 36.0)
	sol.pose = "stand"
	await _line(sol, "SPK_SOLDIER", "D2_S_16", 0.7)
	slide.kill()


## 2. Dünya: ordugâh, Ayasofya, Galata, surlarda Giustiniani, kanlı ay.
func _act_world() -> void:
	# Ordugâh: çadır denizinin üstünden yükselen vinç çekimi
	_cut(CampDay.new())
	Audio.music("theme", 0.0)
	_pan(Vector3(6, 9, -6), Vector3(4, 13, 6), Vector3(2, 5, 60), Vector3(5, 16, 150), 5.8)
	cam.fov = 50.0
	await _line(null, "SPK_TOLGA", "D4A_T_03", 0.2)
	# Gün batımında Ayasofya
	var byz := _cut(ByzCity.new()) as ByzCity
	byz.make_sunset()
	_pan(Vector3(24, 20, -38), Vector3(20, 25, -56), Vector3(-14, 10, -84), Vector3(-14, 14, -82), 3.4)
	_card(_t("KONSTANTİNOPOLİS", "CONSTANTINOPLE"), 2.2)
	await _wait(3.0)
	# Galata Kulesi
	_cut(Galata.new())
	_pan(Vector3(24, 9, -30), Vector3(22, 12, -34), Vector3(8, 17, -58), Vector3(8, 20, -58), 2.0)
	cam.fov = 55.0
	await _wait(1.8)
	# Surlar: Giustiniani'ye sigorta
	byz = _cut(ByzCity.new()) as ByzCity
	var gp := ByzCity.GIUST_POS
	var g := byz.giustiniani
	var tp := gp + Vector3(-2.2, 0, 0.4)
	var tolga := _person(byz, TOLGA, tp, gp)
	_face(g, tp)
	var mid := (gp + tp) * 0.5
	_pan(mid + Vector3(0.3, 1.6, 3.4), mid + Vector3(0.1, 1.6, 2.8), mid + Vector3(0, 1.4, 0), mid + Vector3(0, 1.45, 0), 5.0)
	cam.fov = 45.0
	await _line(tolga, "SPK_TOLGA", "D6B_T_INSURANCE", 0.05)
	var gf := g.global_position + Vector3(0, 1.62, 0)
	_cam(tp + Vector3(0.25, 1.7, 0.55), gf, 34.0)
	await _line(g, "SPK_GIUST", "D6B_G_INSURANCE", 0.15)
	var tf := tp + Vector3(0, 1.55, 0)
	_cam(gp + Vector3(-0.3, 1.7, 0.7), tf, 36.0)
	await _line(tolga, "SPK_TOLGA", "D6B_T_INSURANCE2", 0.35)
	# Kanlı ay: surlarda tutulma, telefon ışığı
	var sw := _cut(SeaWalls.new())
	Audio.music("walls_night", 0.0)
	for c in sw.get_children():
		if c is SkyBody:
			(c as SkyBody).eclipse(true, 2.6)
	var md := Basis.from_euler(Vector3(deg_to_rad(-30), deg_to_rad(20), 0)).z
	var qa := Vector3(15.5, 1.8, -1.6)
	_pan(qa, Vector3(13.0, 1.7, -1.5), qa + md * 100.0 + Vector3(0, -24, 0), Vector3(13.0, 1.7, -1.5) + md * 100.0 + Vector3(0, -20, 0), 3.2)
	cam.fov = 42.0
	await _line(null, "SPK_NIKO", "D4B_N_ECLIPSE_1", 0.05, 2.9, _t("Bak! Yukarı bak! Ay kararıyor!", "Look! Look up! The moon is going dark!"))
	var ty := SeaWalls.QUAY_Y + SeaWalls.WALL_H
	var tpos := Vector3(6.0, ty, SeaWalls.WALL_Z - 1.2)
	var t2 := _person(sw, TOLGA, tpos, tpos + Vector3(0, 0, -3))
	# Telefon Tolga'nın elinde; ekranın ışığı yüzüne vurur
	t2.emote("phone")
	_cam(tpos + Vector3(-0.6, 1.62, -1.9), tpos + Vector3(0, 1.45, 0), 40.0)
	await _line(t2, "SPK_TOLGA", "D4B_T_ECLIPSE_3", 0.3)


## 3. Fatih'in huzuru.
func _act_fatih() -> void:
	# Perde arası: seçimler
	fade.color = Color(0, 0, 0, 1)
	sub_box.visible = false
	Audio.sfx("whoosh_fly", -8.0)
	_card(_t("HER SEÇİM TARİHİ DEĞİŞTİRİR", "EVERY CHOICE CHANGES HISTORY"), 0.9)
	await _wait(1.5)
	var o := _cut(OtagHall.new())
	Audio.music("audience", 0.0)
	var f := _person(o, FATIH, OtagHall.THRONE + Vector3(0, 0, 0.3), OtagHall.THRONE + Vector3(0, 0, 5))
	f.scale = Vector3.ONE * 1.06
	var z := OtagHall.THRONE.z + 3.2
	var tolga := _person(o, TOLGA, Vector3(-0.9, 0, z), OtagHall.THRONE)
	var h := Hikmet.new()
	o.add_child(h)
	h.global_position = Vector3(0.1, 0, z + 0.2)
	h.rotation.y = PI
	var nihat := _person(o, NIHAT, Vector3(1.1, 0, z), OtagHall.THRONE)
	for n in [o.get("fatih"), o.get("scribe")]:
		if n is Node3D:
			(n as Node3D).visible = false
	var th := OtagHall.THRONE
	_unblack(0.15)
	_pan(th + Vector3(4.2, 1.6, 2.2), th + Vector3(3.2, 1.6, 1.4), th + Vector3(-0.6, 1.3, 1.9), th + Vector3(-0.3, 1.5, 0.6), 5.0)
	cam.fov = 50.0
	await _line(f, "SPK_FATIH", "D12_F_ALL", 0.25)
	var ff := f.global_position + Vector3(0, 1.85, 0)
	_pan(Vector3(-0.5, 1.95, z - 0.6), Vector3(-0.4, 1.95, z - 1.0), ff, ff, 4.0)
	cam.fov = 42.0
	await _line(f, "SPK_FATIH", "D12_F_KEY", 0.1)
	var tf := tolga.global_position + Vector3(0, 1.55, 0)
	_cam(th + Vector3(-0.6, 1.8, 1.4), tf, 34.0)
	await _line(tolga, "SPK_TOLGA", "D12_T_KEY_B", 0.1)
	# Fatih'in sessiz bakışı
	_cam(Vector3(-0.3, 1.9, z - 1.0), ff, 40.0)
	await _wait(0.9)
	nihat.visible = true


## 4. Büyük atış: barut, sıcak kutu, "Hmm", ağır çekim, herkes uçar; sonrası.
func _act_boom() -> void:
	var day := _cut(CampDay.new()) as CampDay
	Audio.music("tension", 0.0)
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
		# Geniş: top, Urban, çırak ve arkada Sultan
		_pan(CANNON + Vector3(-6.5, 2.2, 7.5), CANNON + Vector3(-5.5, 2.0, 6.5), CANNON + Vector3(2.5, 1.2, 0), CANNON + Vector3(3.5, 1.3, 0), 3.4)
		cam.fov = 55.0
		_hide_near(4.0)
		await _line(urban, "SPK_URBAN", "D10B_U_POWDER", 0.05)
		_cam(URBAN_AT + u2t * 2.4 + Vector3(0, 1.75, 0) + side * 0.8, uf, 40.0)
		await _line(urban, "SPK_URBAN", "D10B_U_POWDER_3", 0.05)
		_cam(TOLGA_AT - u2t * 1.7 + Vector3(0, 1.72, 0) - side * 0.4, tf, 38.0)
		var hidden := _clear_view(cam.global_position, TOLGA_AT, [tolga, urban])
		await _line(tolga, "SPK_TOLGA", "D10B_T_POWDER_3", 0.1)
		for n in hidden:
			if is_instance_valid(n):
				n.visible = true
		_cam(URBAN_AT + u2t * 2.0 + Vector3(0, 1.7, 0) - side * 0.6, uf, 44.0)
		Audio.sfx("fuse_burn", -4.0)
		await _line(urban, "SPK_URBAN", "D10B_U_EARS", 0.15)
		urban.emote("surprise")
		_cam(URBAN_AT + u2t * 1.6 + Vector3(0, 1.7, 0) + side * 0.3, uf, 32.0)
		await _line(urban, "SPK_URBAN", "D10B_U_B3_1", 0.2)
		_cam(TOLGA_AT - u2t * 1.5 + Vector3(0, 1.72, 0) - side * 0.35, tf, 34.0)
		hidden = _clear_view(cam.global_position, TOLGA_AT, [tolga, urban])
		await _line(tolga, "SPK_TOLGA", "D10B_T_B3_2", 0.15)
		for n in hidden:
			if is_instance_valid(n):
				n.visible = true
	else:
		_unblack(0.1)
	# BOOM: geniş plan, beyaz ışık, ağır çekim
	_cam(CANNON + Vector3(-11.0, 3.4, 4.0), CANNON + Vector3(2.0, 3.6, -0.5), 64.0)
	Audio.music("", 0.0)
	Audio.sfx("explosion_big", 3.0)
	_flash(Color.WHITE, 0.6)
	Vfx.explosion(day, CANNON + Vector3(0, 1.3, 0), 1.3)
	day.cannon.visible = false
	Audio.music("explosion_slowmo", 0.05)
	Engine.time_scale = 0.22
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
	var dur := 1.3
	for fl in flights:
		_fly(day, fl[0], fl[1], fl[2], fl[3], dur, fl[0] == tolga)
	Audio.sfx("whoosh_fly", -4.0)
	Audio.sfx("crowd_gasp", -8.0)
	var follow := func(k: float):
		cam.global_position = CANNON + Vector3(-11.0, 3.4, 4.0).lerp(Vector3(-9.0, 8.5, 13.0), k)
		cam.look_at(tolga.global_position + Vector3(0, 1.0, 0), Vector3.UP)
	create_tween().tween_method(follow, 0.0, 1.0, dur)
	await get_tree().create_timer(dur * 0.3).timeout
	_say("SPK_TOLGA", "D10B_T_B3_AIR")
	await get_tree().create_timer(dur * 0.45).timeout
	_say("SPK_HIKMET", "D10B_H_B3_AIR")
	await get_tree().create_timer(dur * 0.3).timeout
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
	# Önden: dimdik Fatih, önünde sırtüstü yatan Tolga
	_cam(FATIH_AT + f2c * 3.6 + Vector3(0, 1.4, 0) + f2c.cross(Vector3.UP) * 0.7, FATIH_AT + Vector3(-0.5, 0.9, 0) + f2c * 0.8, 50.0)
	_hide_near(2.0)
	_clear_view(cam.global_position, mid, [tolga, fatih])
	await _wait(1.3)
	if _only_boom:
		await _wait(0.6)
		return
	await _line(fatih, "SPK_FATIH", "D10B_F_B3_1", 0.3, 0.0, _t("...Urban.", "...Urban."))
	var up := urban.global_position
	var ufw := urban.global_transform.basis.z
	ufw.y = 0
	_cam(up + ufw.normalized() * 2.0 + Vector3(0.3, 1.4, 0), up + Vector3(0, 1.2, 0), 42.0)
	_hide_near(1.2)
	await _line(urban, "SPK_URBAN", "D10B_U_B3_4", 0.25, 0.0, _t("Efendim.", "My Sultan."))
	Audio.music("theme", 1.5)
	var ff := fatih.global_position + Vector3(0, 1.75, 0)
	_cam(ff + f2c * 1.8 + Vector3(0, 0.05, 0) + f2c.cross(Vector3.UP) * 0.4, ff, 36.0)
	await _line(fatih, "SPK_FATIH", "D10B_F_B3_2", 0.25)
	_face(fatih, tolga_land)
	await _line(fatih, "SPK_FATIH", "D10B_F_B3_4", 0.1)
	# Tolga yerde, yukarıdan
	var tl := tolga.global_position
	var head := tl + (tolga.global_transform.basis.y) * 1.5
	_cam(head + Vector3(0, 1.6, 0.4), head, 50.0)
	await _line(tolga, "SPK_TOLGA", "D10B_T_B3_5", 0.35)
	_cam(ff + f2c * 1.8 + f2c.cross(Vector3.UP) * 0.4, ff, 36.0)
	await _line(fatih, "SPK_FATIH", "D10B_F_B3_5", 0.4, 0.0, _t("Yazık.", "A pity."))
	# Mutfak: kazanlara düşen Hasan ile Hüseyin, Kadri
	var kcam := kitchen + Vector3(0.2, 1.65, -4.2)
	day.kadri.global_position = kitchen + Vector3(1.7, 0, 0.2)
	for n in [day.kadri, hasan, huseyin]:
		_face(n, kcam)
	_cam(kcam, kitchen + Vector3(0.3, 1.1, 0), 50.0)
	_hide_near(1.5)
	day.kadri.emote("surprise")
	await _line(day.kadri, "SPK_KADRI", "D10B_KADRI_B3", 0.3, 0.0, _t("KİM BUNLARI ÇORBAYA ATTI?!", "WHO THREW THESE TWO IN MY SOUP?!"))


## 5. Nihat, tavuk, başlık ve pazartesi.
func _act_finale() -> void:
	# Nihat: gece, ateş ışığında
	var c := _cut(Camp.new())
	Audio.music("confrontation", 0.0)
	var np := Vector3(0.0, 0, 1.5)
	var nihat := _person(c, NIHAT, np, np + Vector3(0, 0, 4))
	var fl := OmniLight3D.new()
	fl.position = np + Vector3(0.8, 1.2, 1.2)
	fl.light_color = Color("ff9a4a")
	fl.light_energy = 2.2
	fl.omni_range = 4.0
	c.add_child(fl)
	var nf := np + Vector3(0, 1.6, 0)
	_pan(np + Vector3(0.5, 1.55, 2.3), np + Vector3(0.35, 1.58, 1.8), nf, nf, 4.0)
	cam.fov = 38.0
	await _line(nihat, "SPK_NIHAT", "D11_N_RUN_FAIL", 0.2)
	# Tavuk kovalamacası
	var day := _cut(CampDay.new())
	Audio.music("chicken", 0.0)
	var chicken := Chicken.new()
	day.add_child(chicken)
	var a := Vector3(-4.0, 0, 6.0)
	var b := Vector3(6.0, 0, 2.0)
	chicken.global_position = a
	var hasan := Soldier.new(Color("b3262d"), "stand", "bork")
	var huseyin := Soldier.new(Color("2f5fa8"), "stand", "bork")
	day.add_child(hasan)
	day.add_child(huseyin)
	for s in [hasan, huseyin]:
		s.global_position = a + Vector3(-2.5, 0, 0.6 if s == hasan else -0.6)
		_face(s, b)
	chicken.look_at_from_position(a, b, Vector3.UP)
	chicken.rotate_y(PI)   # tavuğun önü +z
	chicken.flapping = true
	var ctrack := func(k: float):
		var cp := a.lerp(b, k)
		cam.global_position = cp + Vector3(0.6, 0.55, 3.4)
		cam.look_at(cp + Vector3(-1.6, 0.6, 0))
	_cam_tw = create_tween()
	_cam_tw.tween_method(ctrack, 0.0, 1.0, 3.2)
	cam.fov = 50.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(chicken, "global_position", b, 3.2)
	tw.tween_property(hasan, "global_position", b + Vector3(-2.2, 0, 0.6), 3.2)
	tw.tween_property(huseyin, "global_position", b + Vector3(-2.6, 0, -0.6), 3.2)
	Audio.sfx("chicken", -4.0)
	await _line(hasan, "SPK_HASAN", "D16_G_CATCH_1", 0.4, 0.0, _t("Tavuk! Hüseyin, tavuk kaçıyor!", "Chicken! Hüseyin, the chicken's getting away!"))
	# 23 final
	fade.color = Color(0, 0, 0, 1)
	sub_box.visible = false
	Audio.music("", 0.0)
	Audio.sfx("stamp", -2.0)
	_card(_t("23 FARKLI FİNAL", "23 ENDINGS"), 0.8, true)
	await _wait(1.4)
	# Başlık
	Audio.music("credits", 0.2)
	Audio.sfx("cannon", -6.0, 0.8)
	title.text = _t("Gerçek Tarih Bu Değil", "Not a History Game")
	tagline.text = _t("Steam'de İstek Listene Ekle", "Wishlist it on Steam")
	var tt := create_tween().set_parallel(true)
	tt.tween_property(title, "modulate:a", 1.0, 0.4)
	tt.tween_property(tagline, "modulate:a", 1.0, 0.8).set_delay(0.5)
	await _wait(3.0)
	var out := create_tween().set_parallel(true)
	out.tween_property(title, "modulate:a", 0.0, 0.3)
	out.tween_property(tagline, "modulate:a", 0.0, 0.3)
	await _wait(0.5)
	# Pazartesi 09:00: toplantı (açılıştaki "yirmi belgesel"e dönüş)
	_card(_t("PAZARTESİ · 09:00", "MONDAY · 9:00 AM"), 1.0)
	Audio.music("", 0.0)
	Audio.sfx("fluorescent", -12.0)
	await _wait(1.5)
	var mo := _cut(Monday.new()) as Monday
	var tbl := Monday.OFFICE + Vector3(5.5, 0, 4.5)
	var tolga := _person(mo, TOLGA, tbl + Vector3(0.9, 0, -1.2), tbl)
	for p in mo.colleagues:
		(p as Node3D).visible = false
	_cam(tbl + Vector3(2.6, 1.7, -1.4), tbl + Vector3(0, 1.45, 1.4), 40.0)
	_unblack(0.2)
	await _line(mo.manager, "SPK_MANAGER", "D15_O_Q", 0.15)
	var tf := tolga.global_position + Vector3(0, 1.55, 0)
	_cam(tbl + Vector3(-0.2, 1.62, 0.3), tf, 36.0)
	await _line(tolga, "SPK_TOLGA", "D15_O_DOCS", 0.2)
	_cam(tbl + Vector3(0.6, 1.6, -0.6), mo.manager.global_position + Vector3(0, 1.55, 0), 36.0)
	await _line(mo.manager, "SPK_MANAGER", "D15_O_DOCS_2", 0.5)
	fade.color = Color(0, 0, 0, 1)
	sub_box.visible = false
	Audio.music("theme", 0.0)
	title.text = _t("Gerçek Tarih Bu Değil", "Not a History Game")
	create_tween().tween_property(title, "modulate:a", 1.0, 0.2)
	await _wait(1.8)


## Kamera ile hedef arasındaki (ya da kameraya çok yakın) kalabalığı gizler; gizlenenleri döner.
func _clear_view(from: Vector3, to: Vector3, keep: Array) -> Array:
	var out: Array = []
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
			out.append(nd)
	return out


## lie: havada sırtüstü döner ve yere yatarak düşer (dik inip sonra yatmasın).
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


