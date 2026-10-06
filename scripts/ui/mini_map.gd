class_name MiniMap
extends Control
## GTA tarzı mini harita (v0.90): sağ altta yuvarlak; kameranın baktığı yön yukarı, harita onunla döner. Ortada oyuncunun
## oku (gövdenin yönü), hedef altın baklava (yarıçapın dışındaysa kenarda), kenarda kuzey ("K"). Yalnız 1453 dünyası
## kurulan bölümlerde görünür (MapView.field); ara sahnede, kararmada, menüde, foto modunda gizli. Konuşma altyazısının
## üstüne binerse soluklaşır. Ayar: "minimap". M (kolda D-pad aşağı): büyük harita (WorldMap).

const RANGE_M := 140.0        # yarıçapın gösterdiği uzaklık (m)
const GOLD := Color("ffd24a")
const INK := Color("2a2018")

var hud: Hud
var _rect: ColorRect          # dokuyu döndürerek çizen gölgelendirici
var _over: Control            # ok, hedef, kuzey (dokunun üstünde)
var _mat: ShaderMaterial
var _field: Node3D
var _field_t := 0.0
var _obj: Variant = null      # hedefin dünyadaki (x, z)'si ya da null
var _obj_t := 0.0
var _pos := Vector2.ZERO      # oyuncunun dünyadaki (x, z)'si
var _heading := 0.0           # kameranın yönü (kuzeyden saat yönünde)
var _body := 0.0              # gövdenin yönü
var _font: Font

const SHADER := """
shader_type canvas_item;
uniform sampler2D map_tex : filter_linear, repeat_disable;
uniform vec2 center_uv = vec2(0.5);
uniform float angle = 0.0;
uniform vec2 span_uv = vec2(0.05);
uniform vec4 outside : source_color = vec4(0.34, 0.52, 0.61, 1.0);
uniform vec4 rim_col : source_color = vec4(0.16, 0.12, 0.09, 1.0);
uniform float night = 0.0;
void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float c = cos(angle);
	float s = sin(angle);
	vec2 q = vec2(c * p.x - s * p.y, s * p.x + c * p.y);
	vec2 uv = center_uv + q * span_uv;
	vec4 col = outside;
	if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 && uv.y <= 1.0) {
		col = texture(map_tex, uv);
	}
	col.rgb = mix(col.rgb, col.rgb * vec3(0.55, 0.62, 0.82), night);
	col.rgb = mix(col.rgb, rim_col.rgb, smoothstep(0.90, 0.93, r));
	col.a = 1.0 - smoothstep(0.975, 1.0, r);
	COLOR = col;
}
"""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = ThemeDB.fallback_font
	_rect = ColorRect.new()
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var sh := Shader.new()
	sh.code = SHADER
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_mat.set_shader_parameter("map_tex", MapView.texture())
	_mat.set_shader_parameter("span_uv", Vector2(RANGE_M / (MapView.W * MapView.MPP), RANGE_M / (MapView.H * MapView.MPP)))
	_rect.material = _mat
	add_child(_rect)
	_over = Control.new()
	_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_over.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_over.draw.connect(_draw_over)
	add_child(_over)
	visible = false


## Haritanın görünmesi gereken an mı; görünürse oyuncunun yeri ve yönü güncellenir
func _wanted(delta: float) -> bool:
	if not GameState.settings.get("minimap", true) or MapView.texture() == null or hud == null:
		return false
	if hud.cinematic or hud.is_faded() or not hud.map_free():
		return false
	_field_t -= delta
	if _field_t <= 0.0 or not is_instance_valid(_field) or not _field.is_inside_tree():
		_field_t = 0.5
		_field = MapView.field(get_tree())
	if _field == null:
		return false
	var pl := get_tree().get_first_node_in_group("player") as Node3D
	var cam := get_viewport().get_camera_3d()
	if pl == null or cam == null:
		return false
	_pos = MapView.to_world(_field, pl.global_position)
	if not MapView.inside(_pos):
		return false
	_heading = MapView.heading(_field, cam.global_transform.basis)
	_body = MapView.heading(_field, pl.global_transform.basis)
	return true


func _process(delta: float) -> void:
	var on := _wanted(delta)
	if on != visible:
		visible = on
		hud.relayout_corner()
	if not on:
		return
	var uv := MapView.world_pixel(_pos) / Vector2(MapView.W, MapView.H)
	_mat.set_shader_parameter("center_uv", uv)
	_mat.set_shader_parameter("angle", _heading)
	_mat.set_shader_parameter("night", 1.0 if bool(_field.get("night_build")) else 0.0)
	_obj_t -= delta
	if _obj_t <= 0.0:
		_obj_t = 0.2
		_obj = null
		var t = hud.marker.target_position() if hud.marker else null
		if t is Vector3:
			_obj = MapView.to_world(_field, t)
	# Konuşma altyazısının üstüne binerse soluk (küçük ekranlarda altyazı kutusu sağ alta uzanır)
	modulate.a = 0.35 if hud.subtitle_overlaps(get_global_rect()) else 1.0
	_over.queue_redraw()


## Dünyadaki (x, z) farkı → mini haritada ekran farkı (piksel)
func _to_screen(d_world: Vector2, scale: float) -> Vector2:
	var du := -d_world.y           # haritada sağ = dünya −z
	var dv := d_world.x            # haritada aşağı = dünya +x
	var c := cos(_heading)
	var s := sin(_heading)
	return Vector2(c * du + s * dv, -s * du + c * dv) * scale


func _draw_over() -> void:
	var r := size.x * 0.5
	var ctr := size * 0.5
	var scale := r / RANGE_M
	# Dış çizgi (gölgelendiricinin kenarının üstünde ince koyu halka)
	_over.draw_arc(ctr, r - 1.0, 0.0, TAU, 64, Color(0, 0, 0, 0.5), 2.0, true)
	# Kuzey: haritanın yukarısı, kamera döndükçe kenarda döner
	var n_dir := Vector2(-sin(_heading), -cos(_heading))
	var np := ctr + n_dir * (r - 11.0)
	_over.draw_circle(np, 9.0, INK)
	var nl := tr("UI_MAP_NORTH")
	var fs := 13
	var ts := _font.get_string_size(nl, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	_over.draw_string(_font, np + Vector2(-ts.x * 0.5, ts.y * 0.32), nl, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	# Hedef: yarıçapın içinde baklava, dışında kenarda ok başı
	if _obj is Vector2:
		var off := _to_screen((_obj as Vector2) - _pos, scale)
		var lim := r - 13.0
		if off.length() > lim:
			var dir := off.normalized()
			var tip := ctr + dir * (lim + 6.0)
			var side := Vector2(-dir.y, dir.x)
			_over.draw_colored_polygon(PackedVector2Array([tip, tip - dir * 12.0 + side * 7.0, tip - dir * 12.0 - side * 7.0]), GOLD)
		else:
			var p := ctr + off
			var dm := PackedVector2Array([p + Vector2(0, -8), p + Vector2(7, 0), p + Vector2(0, 8), p + Vector2(-7, 0)])
			_over.draw_colored_polygon(dm, GOLD)
			dm.append(dm[0])
			_over.draw_polyline(dm, INK, 1.5, true)
	# Oyuncu: ortada ok; kamera yukarı bakar, ok gövdenin yönünü gösterir (kendine bakarken arkaya döner)
	var a := _body - _heading
	var fwd := Vector2(sin(a), -cos(a))
	var rt := Vector2(-fwd.y, fwd.x)
	var arrow := PackedVector2Array([ctr + fwd * 10.0, ctr - fwd * 7.0 + rt * 7.0, ctr - fwd * 3.5, ctr - fwd * 7.0 - rt * 7.0])
	_over.draw_colored_polygon(arrow, Color.WHITE)
	arrow.append(arrow[0])
	_over.draw_polyline(arrow, INK, 2.0, true)
