class_name ObjectiveMarker
extends Control
## Hedef işaretçisi: hedefin ekrandaki yerinde altın bir baklava ve uzaklık ("12 m").
## Hedef ekranın dışında ya da arkadaysa kenara yapışır ve hedefi gösteren bir oka döner.
## Hedef: Node3D (yerinden izlenir) ya da Vector3. Yakına gelince (HIDE_NEAR) kaybolur.

const GOLD := Color("ffd24a")
const EDGE := 46.0
const HIDE_NEAR := 2.2

var target: Variant = null          # Node3D | Vector3 | Callable (-> Node3D/Vector3/null) | null
var height := 1.6                   # Node3D hedeflerde baklavanın yerden yüksekliği
var _screen := Vector2.ZERO
var _arrow := false
var _angle := 0.0
var _dist := 0.0
var _font: Font


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = ThemeDB.fallback_font


func set_target(t: Variant, h := 1.6) -> void:
	target = t
	height = h
	queue_redraw()


func _world_pos() -> Variant:
	if target is Callable:
		# Değişen hedef (ör. en yakın kalan ipucu): her karede sorulur; Node3D, Vector3 ya da null döner
		var r = (target as Callable).call() if (target as Callable).is_valid() else null
		if r is Node3D:
			return (r as Node3D).global_position + Vector3(0, height, 0) if is_instance_valid(r) and (r as Node3D).is_inside_tree() else null
		return r
	if target is Node3D:
		if not is_instance_valid(target) or not (target as Node3D).is_inside_tree():
			return null
		return (target as Node3D).global_position + Vector3(0, height, 0)
	if target is Vector3:
		return target
	return null


func _process(_delta: float) -> void:
	var was := visible
	visible = _update()
	if visible or was:
		queue_redraw()


func _update() -> bool:
	if not GameState.settings.get("markers", true) or target == null:
		return false
	var hud := get_parent() as Hud
	if hud and (hud.cinematic or hud.is_faded()):
		return false
	var p = _world_pos()
	var cam := get_viewport().get_camera_3d()
	if p == null or cam == null:
		return false
	var pos: Vector3 = p
	var flat := Vector2(pos.x - cam.global_position.x, pos.z - cam.global_position.z).length()
	if flat < HIDE_NEAR:
		return false
	_dist = cam.global_position.distance_to(pos)
	var size := get_viewport_rect().size
	var center := size / 2.0
	var behind := cam.is_position_behind(pos)
	var sp := cam.unproject_position(pos)
	if behind:
		sp = center - (sp - center) * 1000.0
	var inner := Rect2(Vector2(EDGE, EDGE), size - Vector2(EDGE, EDGE) * 2.0)
	_arrow = behind or not inner.has_point(sp)
	if _arrow:
		var d := sp - center
		if d.length() < 1.0:
			d = Vector2(0, 1)
		# Kenardaki kesişim noktası
		var k := minf(absf((inner.size.x / 2.0) / d.x) if d.x != 0.0 else INF,
			absf((inner.size.y / 2.0) / d.y) if d.y != 0.0 else INF)
		sp = center + d * k
		_angle = d.angle()
	_screen = sp
	return true


func _draw() -> void:
	if not visible:
		return
	var c := GOLD
	var shadow := Color(0, 0, 0, 0.55)
	if _arrow:
		var pts := PackedVector2Array([Vector2(16, 0), Vector2(-9, -11), Vector2(-4, 0), Vector2(-9, 11)])
		var big := Transform2D(_angle, Vector2(1.3, 1.3), 0.0, _screen)
		draw_colored_polygon(big * pts, shadow)
		draw_colored_polygon(big * PackedVector2Array([Vector2(14, 0), Vector2(-8, -9), Vector2(-3, 0), Vector2(-8, 9)]), c)
	else:
		var r := 13.0
		var dia := PackedVector2Array([_screen + Vector2(0, -r), _screen + Vector2(r * 0.72, 0), _screen + Vector2(0, r), _screen + Vector2(-r * 0.72, 0)])
		var big := PackedVector2Array()
		for q in dia:
			big.append(_screen + (q - _screen) * 1.35)
		draw_colored_polygon(big, shadow)
		draw_colored_polygon(dia, c)
	var txt := "%d m" % int(round(_dist))
	var fs := 18
	var w := _font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var tp := _screen + Vector2(-w / 2.0, 36.0)
	if _arrow:
		tp = _screen - Vector2.from_angle(_angle) * 40.0 + Vector2(-w / 2.0, 6.0)
	draw_string_outline(_font, tp, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 5, Color(0, 0, 0, 0.75))
	draw_string(_font, tp, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, c)
