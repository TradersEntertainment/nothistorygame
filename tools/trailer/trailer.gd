extends Node3D
## Fragman kaydı: 1453 sahnelerinde on kamera çekimi ve kapanış kartı. Oyuncu yok, arayüz yok.
## Godot'nun film kaydedicisiyle video üretir (docs/STEAM.md):
##   godot --path . --write-movie fragman.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn
## Her çekim: [sahne, kamera başlangıcı, kamera sonu, bakış başlangıcı, bakış sonu, süre, hazırlık]

const FADE := 0.45
var cam: Camera3D
var fade: ColorRect
var title: Label


func _ready() -> void:
	GameState.autotest = false
	var cl := CanvasLayer.new()
	cl.layer = 50
	add_child(cl)
	fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cl.add_child(fade)
	title = Label.new()
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", load(Hud.FONT_TITLE))
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color("f2e6c9"))
	title.modulate.a = 0.0
	cl.add_child(title)
	_run()


func _shot(level: Node3D, a: Vector3, b: Vector3, la: Vector3, lb: Vector3, secs: float, prep := Callable(), fov := 62.0) -> void:
	add_child(level)
	if prep.is_valid():
		prep.call(level)
	cam = Camera3D.new()
	cam.fov = fov
	add_child(cam)
	cam.current = true
	cam.global_position = a
	cam.look_at(la)
	# Dolgu ve yürüyen halk kurulsun
	await get_tree().create_timer(0.6).timeout
	var t := 0.0
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 0.0, FADE)
	while t < secs:
		var k := smoothstep(0.0, 1.0, t / secs)
		cam.global_position = a.lerp(b, k)
		cam.look_at(la.lerp(lb, k))
		await get_tree().process_frame
		t += get_process_delta_time()
	tw = create_tween()
	tw.tween_property(fade, "color:a", 1.0, FADE)
	await tw.finished
	cam.queue_free()
	level.queue_free()
	await get_tree().process_frame


func _run() -> void:
	var slip := Slipway.new()
	add_child(slip)
	var a := slip.s_to_world(4.0, 7.0, 3.2)
	var b := slip.s_to_world(34.0, 6.0, 2.6)
	var la := slip.s_to_world(30.0, 0.0, 0.5)
	var lb := slip.s_to_world(70.0, 0.0, 0.0)
	remove_child(slip)
	await _shot(slip, a, b, la, lb, 4.5)
	await _shot(CampDay.new(), Vector3(-6, 2.0, 12), Vector3(5, 7.5, 6), Vector3(0, 1.2, -20), Vector3(0, 1.0, -30), 4.5)
	await _shot(CampDay.new(), Vector3(-11.0, 1.9, -3.2), Vector3(-12.2, 1.7, -4.3), Vector3(-13, 1.3, -7), Vector3(-13.2, 1.2, -6.8), 3.5)
	await _shot(CampDay.new(), Vector3(12.5, 1.4, 10.5), Vector3(8.0, 1.8, 10.0), Vector3(9, 0.7, 6), Vector3(9, 0.6, 6), 3.5)
	await _shot(Galata.new(), Vector3(8, 1.7, -30.5), Vector3(8, 2.4, -43), Vector3(8, 6, -58), Vector3(8, 24, -58), 4.5)
	await _shot(ByzCity.new(), Vector3(0, 1.8, 8), Vector3(0.5, 2.4, -5), Vector3(0, 1.6, -20), Vector3(0, 1.8, -24), 4.5)
	await _shot(ByzCity.new(), Vector3(-18.8, 1.7, -15.8), Vector3(-20.8, 1.6, -17.4), Vector3(-24, 1.2, -20.5), Vector3(-24, 1.1, -20.6), 4.0,
		func(l): l.make_sunset())
	# Kanlı ay: kamera rıhtımdan ayın yönüne, ufuk ve kayıklar kadrajda; dar açı (ay büyük görünsün)
	var md := Basis.from_euler(Vector3(deg_to_rad(-30), deg_to_rad(20), 0)).z
	var qa := Vector3(15.5, 1.8, -1.6)
	var qb := Vector3(11.0, 1.7, -1.4)
	await _shot(SeaWalls.new(), qa, qb, qa + md * 100.0 + Vector3(0, -24, 0), qb + md * 100.0 + Vector3(0, -18, 0), 5.5,
		func(l):
			for c in l.get_children():
				if c is SkyBody:
					(c as SkyBody).eclipse(true, 4.5), 42.0)
	await _shot(CampDay.new(), Vector3(1.8, 2.0, 4), Vector3(1.8, 6.5, -2), Vector3(0, 2.0, -45), Vector3(0, 1.0, -60), 5.0,
		func(l): l.make_night(true))
	await _shot(OtagHall.new(), OtagHall.ENTRY + Vector3(0, 1.7, 0), Vector3(0, 1.6, 1.8), OtagHall.THRONE + Vector3(0, 1.5, 0), OtagHall.THRONE + Vector3(0, 1.4, 0), 4.0)
	# Kapanış kartı
	title.text = tr("UI_TITLE") if tr("UI_TITLE") != "UI_TITLE" else "Gerçek Tarih Bu Değil"
	var tw := create_tween()
	tw.tween_property(title, "modulate:a", 1.0, 0.8)
	await get_tree().create_timer(3.5).timeout
	get_tree().quit()
