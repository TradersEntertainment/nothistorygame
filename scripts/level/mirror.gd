class_name Mirror
extends Node3D
## Gerçek ayna: ikinci bir kamera oyuncunun kamerasını ayna düzlemine göre yansıtıp bir SubViewport'a çizer,
## cam o görüntüyü ekran koordinatlarıyla (yatay çevrilmiş) gösterir. Tolga birinci şahısta bedensiz olduğu için
## yalnızca aynanın gördüğü katmanda bir Tolga modeli oyuncuyu izler (fes, kaftan o anki duruma göre).
## Yerel +Z aynanın baktığı yöndür; cam yerel XY düzleminde, merkezde.

const REFLECT_LAYER := 1 << 19   # yalnızca aynada görünür (Tolga'nın yansıması)
const HIDE_LAYER := 1 << 18      # aynanın arkası (duvar, çerçeve): yansımada görünmez
const RANGE := 9.0

var size := Vector2(0.66, 1.7)
var _vp: SubViewport
var _cam: Camera3D
var _glass: MeshInstance3D
var _notifier: VisibleOnScreenNotifier3D
var _me: Person
var _me_key := ""


## pos: camın merkezi; facing: aynanın baktığı yön (yatay).
static func make(parent: Node3D, glass_size: Vector2, pos: Vector3, facing: Vector3) -> Mirror:
	var m := Mirror.new()
	m.size = glass_size
	parent.add_child(m)
	m.position = pos
	m.rotation.y = atan2(facing.x, facing.z)
	return m


## Aynanın kendi duvarını ve çerçevesini yansımadan çıkarır (düzlemin arkasında kalıp görüntüyü kapatmasın).
static func hide_from_reflection(node: Node) -> void:
	if node is VisualInstance3D:
		(node as VisualInstance3D).layers = HIDE_LAYER
	for c in node.get_children():
		hide_from_reflection(c)


func _ready() -> void:
	_vp = SubViewport.new()
	_vp.size = Vector2i(480, 270)
	_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_vp.msaa_3d = Viewport.MSAA_2X
	add_child(_vp)
	_cam = Camera3D.new()
	_cam.cull_mask = (0xFFFFF | REFLECT_LAYER) & ~HIDE_LAYER
	_vp.add_child(_cam)

	_glass = MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	_glass.mesh = q
	_glass.layers = HIDE_LAYER | 1
	_glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode unshaded, cull_back;
uniform sampler2D reflection : source_color, filter_linear, repeat_disable;
uniform bool live = false;
void fragment() {
	vec3 c = vec3(0.62, 0.74, 0.8);
	if (live) {
		c = texture(reflection, vec2(1.0 - SCREEN_UV.x, SCREEN_UV.y)).rgb * vec3(0.92, 0.96, 1.0);
	}
	// Kenarlara doğru hafif buğu
	vec2 e = abs(UV - 0.5) * 2.0;
	c *= 1.0 - 0.12 * smoothstep(0.75, 1.0, max(e.x, e.y));
	ALBEDO = c;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("reflection", _vp.get_texture())
	_glass.material_override = mat
	add_child(_glass)

	_notifier = VisibleOnScreenNotifier3D.new()
	_notifier.aabb = AABB(Vector3(-size.x / 2, -size.y / 2, -0.05), Vector3(size.x, size.y, 0.1))
	add_child(_notifier)


func _exit_tree() -> void:
	if is_instance_valid(_me):
		_me.queue_free()


func _process(_delta: float) -> void:
	var main := get_viewport().get_camera_3d()
	var p := main.get_parent() as Player if main else null
	var n := global_transform.basis.z.normalized()
	var active := p != null and main == p.camera and _notifier.is_on_screen() \
		and (main.global_position - global_position).dot(n) > 0.05 \
		and main.global_position.distance_to(global_position) < RANGE
	_update_me(p, active)
	(_glass.material_override as ShaderMaterial).set_shader_parameter("live", active)
	if not active:
		_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		return
	main.cull_mask &= ~REFLECT_LAYER
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var full := get_viewport().get_visible_rect().size
	var want := Vector2i(maxi(64, int(full.x * 0.5)), maxi(64, int(full.y * 0.5)))
	if _vp.size != want:
		_vp.size = want

	# Kamerayı düzleme göre yansıt; aynalı taban (det -1) yerine x ekseni çevrilmiş düzgün taban,
	# görüntü de camda yatay çevrilerek okunur.
	var o := global_position
	var c := main.global_position
	var b := main.global_transform.basis.orthonormalized()
	var rx := _refl(b.x, n)
	var ry := _refl(b.y, n)
	var rz := _refl(b.z, n)
	_cam.global_transform = Transform3D(Basis(-rx, ry, rz), c - 2.0 * (c - o).dot(n) * n)
	_cam.fov = main.fov
	_cam.far = main.far
	_cam.keep_aspect = main.keep_aspect
	# Yakın düzlem: camın en yakın köşesine kadar (aradaki her şey aynanın arkasındadır)
	var fwd := -_cam.global_transform.basis.z
	var nearest := INF
	var gb := global_transform.basis
	for sx in [-0.5, 0.5]:
		for sy in [-0.5, 0.5]:
			var corner: Vector3 = o + gb.x * (size.x * sx) + gb.y * (size.y * sy)
			nearest = minf(nearest, (corner - _cam.global_position).dot(fwd))
	_cam.near = maxf(0.05, nearest - 0.05)


static func _refl(v: Vector3, n: Vector3) -> Vector3:
	return v - 2.0 * v.dot(n) * n


## Aynadaki Tolga: yalnızca aynanın katmanında, oyuncunun yerinde ve yönünde.
func _update_me(p: Player, active: bool) -> void:
	if not active or p == null:
		if is_instance_valid(_me):
			_me.visible = false
		return
	var f := GameState.flags
	var key := "%s|%s" % [f.get("fez", true), f.get("has_kaftan", false)]
	if key != _me_key or not is_instance_valid(_me):
		_me_key = key
		if is_instance_valid(_me):
			_me.queue_free()
		_me = p._me_person()
		get_parent().add_child(_me)
		_me.remove_from_group("persons")
		_set_layers(_me)
		_me.set_process(true)
		# Rig bazı parçaları sonradan ekler
		get_tree().process_frame.connect(func():
			if is_instance_valid(_me):
				_set_layers(_me), CONNECT_ONE_SHOT)
	_me.visible = true
	_me.global_position = p.global_position
	_me.rotation.y = p.rotation.y + PI


static func _set_layers(node: Node) -> void:
	if node is VisualInstance3D:
		(node as VisualInstance3D).layers = REFLECT_LAYER
	for c in node.get_children():
		_set_layers(c)
