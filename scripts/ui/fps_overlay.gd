class_name FpsOverlay
extends CanvasLayer
## Sol üstte küçük performans göstergesi (F3 ya da Ayarlar): FPS, kare süresi, çizim çağrısı, nesne sayısı.

var _label: Label
var _t := 0.0


static func show_overlay(host: Node, on: bool) -> void:
	var tree := host.get_tree() if host.is_inside_tree() else null
	if tree == null:
		return
	var cur := tree.root.get_node_or_null("FpsOverlay")
	if on and cur == null:
		var o := FpsOverlay.new()
		o.name = "FpsOverlay"
		tree.root.add_child.call_deferred(o)
	elif not on and cur:
		cur.queue_free()


func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	var bg := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.55)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(6)
	bg.add_theme_stylebox_override("panel", sb)
	bg.position = Vector2(8, 8)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color("6ff2c8"))
	bg.add_child(_label)


func _process(delta: float) -> void:
	_t -= delta
	if _t > 0.0:
		return
	_t = 0.25
	var fps := Engine.get_frames_per_second()
	var draws := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var objs := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)
	_label.text = "%d FPS · %.1f ms\n%d çizim · %d nesne" % [fps, 1000.0 / maxf(1.0, fps), draws, objs]
	_label.add_theme_color_override("font_color", Color("6ff2c8") if fps >= 55 else (Color("ffd24a") if fps >= 30 else Color("ff6a5a")))
