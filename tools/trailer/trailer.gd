extends Node3D
## Steam fragmanı (sesli, altyazılı, ~70 sn): garajda başlangıç, 1453'e düşüş, kızak kaçışı, manzaralar,
## kanlı ay, Fatih'in huzuru, TOP PATLAMASI (ağır çekimde herkes uçar), tavuk kovalamacası, kapanış kartı.
## Seslendirme assets/audio/voice/tr, müzik assets/audio/music. Arayüz yok; altyazı ve başlık kartları kendi katmanında.
## Kayıt (docs/STEAM.md):
##   godot --path . --write-movie fragman.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn

const FADE := 0.35
const VOICE_DIR := "res://assets/audio/voice/tr/"
const CANNON := Vector3(3.0, 0.0, -21.0)
const URBAN_AT := Vector3(5.8, 0.0, -23.6)
const TOLGA_AT := Vector3(5.4, 0.0, -16.0)
const FATIH_AT := Vector3(11.0, 0.0, -16.2)
const GOAT_TENT := Vector3(19.0, 0.0, -12.0)
const TOLGA := {"coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")}
const FATIH := {"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "turban", "mustache": true, "robe": Color("c8323a"),
	"hair": Color("2a1e14"), "skin": Color("e0b08a")}
const NIHAT := {"coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true, "hair": Color("3a2a1e"), "skin": Color("ecb892")}

var cam: Camera3D
var fade: ColorRect
var title: Label
var tagline: Label
var sub_box: PanelContainer
var sub_name: Label
var sub_text: Label
var voice: AudioStreamPlayer
var _font_title: Font


func _ready() -> void:
	GameState.autotest = false
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
	sub_box.visible = true
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


# ---------------------------------------------------------------- akış

func _run() -> void:
	# 1. Garaj, gece üç: Hikmet'in buluşu
	Audio.music("garage", 0.3)
	# Hikmet makinenin önünde, Tolga karşısında; kamera yanda, ikisinin yüzü ve dönen halkalar kadrajda
	var hk := Garage.HIKMET_POS
	var tp := hk + Vector3(1.6, 0, 0.9)
	await _shot(Garage.new(), hk + Vector3(0.6, 1.5, 3.2), hk + Vector3(0.9, 1.45, 2.5), hk + Vector3(0.5, 1.35, 0), (hk + tp) * 0.5 + Vector3(0, 1.4, 0), 7.6,
		func(l):
			var h := Hikmet.new()
			l.add_child(h)
			h.global_position = hk
			h.look_at_from_position(hk, Vector3(tp.x, 0, tp.z), Vector3.UP)
			h.rotate_y(PI)
			_person(l, TOLGA, tp, hk), 50.0,
		[[0.2, func(): _say("SPK_HIKMET", "D1_H_04")],
		 [3.0, func(): _say("SPK_TOLGA", "D1_T_07")]])
	# 2. Işık, 1453
	Audio.sfx("whoosh_fly", 0.0)
	fade.color = Color(1, 1, 1, 1)
	create_tween().tween_property(fade, "color", Color(0, 0, 0, 1), 0.9).set_trans(Tween.TRANS_EXPO)
	await _wait(0.9)
	Audio.music("theme", 0.2)
	_card("1453 · İSTANBUL", 1.8, true)
	await _wait(2.4)
	# 3. Kızak kaçışı: gemiler karadan yürütülüyor
	var slip := Slipway.new()
	add_child(slip)
	await _shot(slip, slip.s_to_world(4.0, 7.0, 3.2), slip.s_to_world(34.0, 6.0, 2.6), slip.s_to_world(30.0, 0.0, 0.5), slip.s_to_world(70.0, 0.0, 0.0), 5.2,
		Callable(), 62.0,
		[[0.3, func(): _say("SPK_SOLDIER", "D2_S_06")],
		 [2.9, func(): _say("SPK_HIKMET", "D2_H_07")],
		 [3.6, func(): _card("Bir sigortacı. Bir zaman makinesi.", 1.3)]])
	# 4. Haliç'e düşüş: sudan surlara bakış
	var sw := Slipway.new()
	add_child(sw)
	var st := sw.swim_start()
	var to_chain := (sw.chain_point() - st).normalized()
	await _shot(sw, Vector3(st.x, sw.water_y + 0.25, st.z), Vector3(st.x, sw.water_y + 0.6, st.z) + to_chain * 6.0,
		sw.chain_point() + Vector3(0, 2.0, 0), sw.chain_point() + Vector3(0, 4.0, 0), 3.6, Callable(), 62.0,
		[[0.2, func(): _say("SPK_TOLGA", "D2_T_08")]])
	# 5. Manzara: ordugâhın çadır denizi, ufukta surlar ve Ayasofya
	await _shot(CampDay.new(), Vector3(-6, 3.0, 30), Vector3(4, 9.0, 24), Vector3(0, 6, 118), Vector3(0, 12, 140), 4.4,
		Callable(), 55.0, [[0.6, func(): _card("Ve bir fetih.", 1.6)]])
	# 6. Bizans sokakları, gün batımı
	await _shot(ByzCity.new(), Vector3(-18.8, 1.7, -15.8), Vector3(-20.8, 1.6, -17.4), Vector3(-24, 1.2, -20.5), Vector3(-24, 1.1, -20.6), 3.4,
		func(l): l.make_sunset())
	# 7. Kanlı ay: deniz surlarında tutulma
	var md := Basis.from_euler(Vector3(deg_to_rad(-30), deg_to_rad(20), 0)).z
	var qa := Vector3(15.5, 1.8, -1.6)
	var qb := Vector3(11.0, 1.7, -1.4)
	await _shot(SeaWalls.new(), qa, qb, qa + md * 100.0 + Vector3(0, -24, 0), qb + md * 100.0 + Vector3(0, -18, 0), 4.6,
		func(l):
			for c in l.get_children():
				if c is SkyBody:
					(c as SkyBody).eclipse(true, 3.8), 42.0,
		[[0.4, func(): _say("SPK_NIKO", "D4B_N_ECLIPSE_1", 2.9, "Bak! Yukarı bak! Ay kararıyor!")]])
	# 8. Fatih'in huzuru: fes, gecelik, form
	# Yandan: solda üçlü (fes, gecelik, fötr), sağda tahtta Fatih; kamera ağır ağır Fatih'e yaklaşır
	await _shot(OtagHall.new(), OtagHall.THRONE + Vector3(4.2, 1.6, 2.2), OtagHall.THRONE + Vector3(3.2, 1.6, 1.4), OtagHall.THRONE + Vector3(-0.6, 1.3, 1.9),
		OtagHall.THRONE + Vector3(-0.3, 1.5, 0.6), 6.2,
		func(l):
			var f := _person(l, FATIH, OtagHall.THRONE + Vector3(0, 0, 0.3), OtagHall.THRONE + Vector3(0, 0, 5))
			f.scale = Vector3.ONE * 1.06
			var z := OtagHall.THRONE.z + 3.2
			_person(l, TOLGA, Vector3(-0.9, 0, z), OtagHall.THRONE)
			var h := Hikmet.new()
			l.add_child(h)
			h.global_position = Vector3(0.1, 0, z + 0.2)
			h.rotation.y = PI
			_person(l, NIHAT, Vector3(1.1, 0, z), OtagHall.THRONE), 50.0,
		[[0.4, func(): _say("SPK_FATIH", "D12_F_ALL")]])
	# 9. BÜYÜK ATIŞ
	await _boom()
	# 10. Tavuk kovalamacası
	await _chicken()
	# 11. Kapanış
	fade.color = Color(0, 0, 0, 1)
	Audio.music("credits", 0.5)
	title.text = "Gerçek Tarih Bu Değil"
	tagline.text = "Steam'de İstek Listene Ekle"
	var tw := create_tween().set_parallel(true)
	tw.tween_property(title, "modulate:a", 1.0, 0.8)
	tw.tween_property(tagline, "modulate:a", 1.0, 1.2).set_delay(0.6)
	await _wait(5.0)
	get_tree().quit()


## Top patlaması: Urban'ın "hmm"u, beyaz ışık, ağır çekim, herkes uçar; Fatih'in yüzünde tek is lekesi.
func _boom() -> void:
	var day := CampDay.new()
	add_child(day)
	var urban := day.urban
	urban.set_activity("")
	urban.position = URBAN_AT
	urban.look_at_from_position(URBAN_AT, Vector3(TOLGA_AT.x, 0, TOLGA_AT.z), Vector3.UP)
	urban.rotate_y(PI)
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
	# a) Urban: "Kulakları tıkayın!" ... "Hmm." / Tolga: "İyi bir 'hmm' mi?"
	cam = Camera3D.new()
	add_child(cam)
	cam.current = true
	cam.fov = 45.0
	# Urban yakın plan: topun yanında, fitil elinde
	var u2t := (TOLGA_AT - URBAN_AT).normalized()
	cam.global_position = URBAN_AT + u2t * 2.6 + Vector3(0, 1.75, 0) + u2t.cross(Vector3.UP) * 0.9
	cam.look_at(URBAN_AT + Vector3(0, 1.6, 0))
	await _wait(0.5)
	create_tween().tween_property(fade, "color:a", 0.0, FADE)
	Audio.sfx("fuse_burn", -6.0)
	await _wait(_say("SPK_URBAN", "D10B_U_EARS") + 0.2)
	urban.emote("surprise")
	await _wait(_say("SPK_URBAN", "D10B_U_B3_1") + 0.3)
	# Tolga yakın plan (karşıdan); kameranın önüne giren ordugâh halkı bu çekimde gizlenir
	cam.global_position = TOLGA_AT - u2t * 1.7 + Vector3(0, 1.75, 0) - u2t.cross(Vector3.UP) * 0.4
	cam.look_at(TOLGA_AT + Vector3(0, 1.55, 0))
	var hidden := _clear_view(cam.global_position, TOLGA_AT, [tolga, urban])
	await _wait(_say("SPK_TOLGA", "D10B_T_B3_2") + 0.2)
	for n in hidden:
		if is_instance_valid(n):
			n.visible = true
	# b) BOOM: geniş plan, beyaz ışık, ağır çekim
	cam.fov = 64.0
	cam.global_position = CANNON + Vector3(-11.0, 3.4, 4.0)
	cam.look_at(CANNON + Vector3(2.0, 3.6, -0.5), Vector3.UP)
	sub_box.visible = false
	if ResourceLoader.exists("res://assets/audio/sfx/explosion_big.ogg"):
		Audio.sfx("explosion_big", 2.0)
	else:
		Audio.sfx("cannon", 2.0, 0.55)
	_flash(Color.WHITE, 0.6)
	Vfx.explosion(day, CANNON + Vector3(0, 1.3, 0), 1.3)
	day.cannon.visible = false
	Audio.music("explosion_slowmo", 0.05)
	Engine.time_scale = 0.22
	var kitchen := Vector3(-13.0, 0, -8.8)
	var flights: Array = [
		[tolga, FATIH_AT + Vector3(-1.4, 0, -0.8), 9.0, 2.0],
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
		_fly(day, fl[0], fl[1], fl[2], fl[3], dur)
	Audio.sfx("whoosh_fly", -4.0)
	Audio.sfx("crowd_gasp", -8.0)
	# Kamera uçan Tolga'yı izler (ağır çekimde replikler gerçek hızda)
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
	Audio.music("theme", 1.0)
	# c) Fatih: kıpırdamamış, yüzünde tek is lekesi. "...Urban."
	Vfx.soot(fatih, 1.62, false)
	for p in [tolga, urban, hasan, huseyin] + gunners:
		Vfx.soot(p)
	# İkisi yan yana: dimdik Fatih ve is içinde, yere çakılmış Tolga
	cam.fov = 40.0
	var f2c := (Vector3(CANNON.x, 0, CANNON.z) - FATIH_AT).normalized()
	var mid := FATIH_AT + Vector3(-0.7, 0, -0.4)
	cam.global_position = mid + f2c * 3.6 + Vector3(0, 1.7, 0) - f2c.cross(Vector3.UP) * 1.0
	cam.look_at(mid + Vector3(0, 1.35, 0))
	_clear_view(cam.global_position, mid, [tolga, fatih])
	await _wait(1.4)
	await _wait(_say("SPK_FATIH", "D10B_F_B3_1", 0.0, "...Urban.") + 0.7)
	await _wait(_say("SPK_KADRI", "D10B_KADRI_B3") + 0.3)
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 1.0, FADE)
	await tw.finished
	cam.queue_free()
	day.queue_free()
	await get_tree().process_frame


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


func _fly(parent: Node3D, node: Node3D, to: Vector3, peak: float, spin: float, dur: float) -> void:
	var from := node.global_position
	var rot0 := node.rotation
	var tw := create_tween()
	tw.tween_method(func(k: float):
		var p := from.lerp(to, k)
		p.y += sin(k * PI) * peak
		node.global_position = p
		node.rotation = Vector3(rot0.x + sin(k * TAU) * 0.6 * spin * (1.0 - k), rot0.y + k * spin * TAU * (1.0 - k * 0.5), rot0.z + k * spin * 1.4 * (1.0 - k)), 0.0, 1.0, dur)
	tw.tween_callback(func():
		node.rotation = rot0
		Vfx.dust(parent, to, 0.5)
		Audio.sfx("land_thud", -8.0))


## Tavuk kovalamacası: Sinerji kaçar, Hasan ile Hüseyin peşinde.
func _chicken() -> void:
	var day := CampDay.new()
	add_child(day)
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
		s.look_at_from_position(s.global_position, b, Vector3.UP)
		s.rotate_y(PI)
	chicken.look_at_from_position(a, b, Vector3.UP)
	cam = Camera3D.new()
	add_child(cam)
	cam.current = true
	cam.fov = 50.0
	cam.global_position = Vector3(1.0, 1.2, 11.0)
	cam.look_at(Vector3(1.0, 0.6, 3.5))
	await _wait(0.5)
	create_tween().tween_property(fade, "color:a", 0.0, FADE)
	Audio.music("chicken", 0.3)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(chicken, "global_position", b, 3.6)
	tw.tween_property(hasan, "global_position", b + Vector3(-2.2, 0, 0.6), 3.6)
	tw.tween_property(huseyin, "global_position", b + Vector3(-2.6, 0, -0.6), 3.6)
	tw.tween_property(cam, "global_position", Vector3(3.0, 1.2, 10.0), 3.6)
	await _wait(0.3)
	_say("SPK_HASAN", "D16_G_CATCH_1", 0.0, "Tavuk! Hüseyin, tavuk kaçıyor!")
	Audio.sfx("chicken", -4.0)
	await _wait(3.4)
	tw = create_tween()
	tw.tween_property(fade, "color:a", 1.0, FADE)
	await tw.finished
	cam.queue_free()
	day.queue_free()
	await get_tree().process_frame
