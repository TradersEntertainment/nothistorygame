class_name GunDrill
extends Control
## Top doldurma ve atış (kuşatmanın Osmanlı tarafı; Bizans'ın küçük topları da): barut → tapa → gülle →
## sıkıştır (E'ye art arda) → nişan (A/D ile ibreyi yeşil bandın içine al, bant yavaşça kayar) → ateş (E).
## Oyuncu donar, kamera topa bakar; adımlar sağda liste olarak görünür. fired(accuracy 0..1) yayınlanır.

signal step_done(step: String)
signal fired(accuracy: float)

const STEPS := ["powder", "wad", "ball", "ram", "aim"]
const RAM_TAPS := 6

var active := false
var step := 0
var _ram := 0
var aim := 0.0            # -1 .. 1
var target := 0.0         # bandın merkezi
var band := 0.18
var _t := 0.0
var _drift := 0.35


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func start(drift := 0.35, band_w := 0.18) -> void:
	active = true
	visible = true
	step = 0
	_ram = 0
	aim = 0.0
	_drift = drift
	band = band_w
	target = randf_range(-0.5, 0.5)
	queue_redraw()
	if GameState.autotest:
		_auto.call_deferred()


func stop() -> void:
	active = false
	visible = false


func current() -> String:
	return STEPS[step] if step < STEPS.size() else "fire"


func _process(delta: float) -> void:
	if not active:
		return
	_t += delta
	if current() == "aim":
		target = clampf(target + sin(_t * 0.9) * _drift * delta, -0.7, 0.7)
		var inp := Input.get_axis("move_left", "move_right")
		aim = clampf(aim + inp * delta * 1.2, -1.0, 1.0)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not active or GameState.autotest:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("jump"):
		press()
		get_viewport().set_input_as_handled()


func press() -> void:
	if not active:
		return
	match current():
		"powder", "wad", "ball":
			Audio.sfx("land_pot", -10.0, [0.8, 1.2, 0.6][step])
			step_done.emit(current())
			step += 1
		"ram":
			_ram += 1
			Audio.sfx("land_thud", -12.0, 1.3)
			if _ram >= RAM_TAPS:
				step_done.emit("ram")
				step += 1
		"aim":
			var acc := clampf(1.0 - absf(aim - target) / (band * 2.5), 0.0, 1.0)
			step += 1
			stop()
			fired.emit(acc)


func _auto() -> void:
	for i in 3:
		await get_tree().process_frame
		press()
	for i in RAM_TAPS:
		press()
	aim = target
	press()


func _draw() -> void:
	if not active:
		return
	var vs := size
	var font := ThemeDB.fallback_font
	# Adım listesi (sağda)
	var x := vs.x - 300.0
	var y := vs.y * 0.3
	draw_rect(Rect2(Vector2(x - 16, y - 34), Vector2(290, 30 + STEPS.size() * 30 + 36)), Color(0.05, 0.05, 0.07, 0.75))
	draw_string(font, Vector2(x, y - 10), tr("UI_GUN_TITLE"), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffd070"))
	for i in STEPS.size() + 1:
		var k: String = STEPS[i] if i < STEPS.size() else "fire"
		var col := Color("5fcf6a") if i < step else (Color("fff3d6") if i == step else Color(1, 1, 1, 0.35))
		var label := tr("UI_GUN_" + k.to_upper())
		if k == "ram" and i == step:
			label += "  %d/%d" % [_ram, RAM_TAPS]
		draw_string(font, Vector2(x, y + 22 + i * 30), ("✓ " if i < step else "• ") + label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, col)
	# Nişan göstergesi
	if current() == "aim":
		var r := Rect2(Vector2(vs.x * 0.5 - 220, vs.y * 0.64), Vector2(440, 20))
		draw_rect(r.grow(3), Color(0, 0, 0, 0.5))
		draw_rect(r, Color("2a2622"))
		var bx := r.position.x + r.size.x * (target * 0.5 + 0.5)
		draw_rect(Rect2(Vector2(bx - r.size.x * band * 0.5, r.position.y), Vector2(r.size.x * band, r.size.y)), Color("5fcf6a"))
		var nx := r.position.x + r.size.x * (aim * 0.5 + 0.5)
		draw_rect(Rect2(Vector2(nx - 3, r.position.y - 8), Vector2(6, r.size.y + 16)), Color("fff3d6"))
		draw_string(font, r.position + Vector2(0, -14), tr("UI_GUN_AIM_HINT"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("f2e6c9"))
	else:
		draw_string(font, Vector2(vs.x * 0.5 - 160, vs.y * 0.66), tr("UI_GUN_PRESS"), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f2e6c9"))
