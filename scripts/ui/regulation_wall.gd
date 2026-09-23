class_name RegulationWall
extends Control
## ⏱ Yönetmelik Duvarı (CHAPTERS §4.3): ekranı kaplayan madde madde yönetmelik, ortada bir form.
## Oyuncu formu yırtmak için tuşa art arda basar. run() yırtıldıysa true döner.
## Bölüm 7 (rapor) ve Bölüm 11 (yardım et) kullanır.

const PRESSES := 22
const SECONDS := 7.0

var _form_l: ColorRect
var _form_r: ColorRect
var _bar: ColorRect


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.06, 0.05, 0.93)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var text := Label.new()
	var lines := PackedStringArray()
	for i in 34:
		lines.append(tr("UI_CH7_WALL_LINE") % [7, i + 1, i * 3 + 2])
	text.text = "\n".join(lines)
	text.add_theme_font_size_override("font_size", 15)
	text.add_theme_color_override("font_color", Color(0.85, 0.35, 0.3, 0.55))
	text.position = Vector2(40, 10)
	add_child(text)
	var head := Label.new()
	head.text = tr("UI_CH7_WALL_TITLE")
	head.add_theme_font_size_override("font_size", 38)
	head.add_theme_color_override("font_color", Color("ff7a6a"))
	head.position = Vector2(300, 70)
	add_child(head)
	_form_l = _paper(Vector2(380, 190), Vector2(260, 330), "UI_CH7_WALL_FORM", Color("efe6cf"))
	_form_r = _paper(Vector2(640, 190), Vector2(0, 330), "UI_CH7_WALL_FORM2", Color("e8dfc6"))
	var back := ColorRect.new()
	back.color = Color(1, 1, 1, 0.15)
	back.size = Vector2(520, 12)
	back.position = Vector2(380, 560)
	add_child(back)
	_bar = ColorRect.new()
	_bar.color = Color("ff5a4a")
	_bar.size = Vector2(0, 12)
	_bar.position = Vector2(380, 560)
	add_child(_bar)


func _paper(pos: Vector2, pivot: Vector2, key: String, color: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.size = Vector2(260, 330)
	r.position = pos
	r.pivot_offset = pivot
	add_child(r)
	var l := Label.new()
	l.text = tr(key)
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", Color("2a2a30"))
	l.position = Vector2(22, 24)
	r.add_child(l)
	return r


func set_progress(v: float) -> void:
	_bar.size.x = 520.0 * v
	_form_l.rotation = -v * 0.25
	_form_r.rotation = v * 0.25
	_form_l.position.x = 380.0 - v * 60.0
	_form_r.position.x = 640.0 + v * 60.0


## Duvarı gösterir, tuşa basışları sayar, kaybolur. auto: otomatik test (true = yırt, false = yırtma).
static func run(hud: Hud, player: Player, auto := false) -> bool:
	var w := RegulationWall.new()
	hud.add_child(w)
	w.move_to_front()
	var presses := 0
	var t := 0.0
	hud.set_qte(w.tr("UI_CH7_TEAR"))
	while t < SECONDS and presses < PRESSES:
		await w.get_tree().process_frame
		var dt := w.get_process_delta_time()
		t += dt
		if GameState.autotest:
			if auto and fmod(t, 0.2) < dt:
				presses += 1
		elif Input.is_action_just_pressed("advance") or Input.is_action_just_pressed("interact"):
			presses += 1
			player.shake(0.05)
		w.set_progress(float(presses) / PRESSES)
	hud.set_qte("")
	var tw := w.create_tween()
	tw.tween_property(w, "modulate:a", 0.0, 0.6)
	await tw.finished
	w.queue_free()
	return presses >= PRESSES
