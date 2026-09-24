class_name SkyBody
extends Node3D
## Gökteki güneş ya da ay: bağlı olduğu DirectionalLight3D'nin geldiği yönde, kameradan hep aynı uzaklıkta
## (sonsuzda gibi) durur; sisten etkilenmez, halesiyle parlar. Işık döndürülürse (12B gün batımı) o da iner.
## Rengi ışığın renginden gelir (gün batımında turuncuya döner).

var light: DirectionalLight3D
var is_moon := false
var dist := 700.0
var _core: MeshInstance3D
var _halos: Array[MeshInstance3D] = []
var _core_mat: StandardMaterial3D
var _halo_mats: Array[StandardMaterial3D] = []


## Işığa bağlı bir güneş/ay ekler. size: çekirdek yarıçapı (metre, 700 m uzaklıkta).
static func attach(parent: Node3D, l: DirectionalLight3D, moon := false) -> SkyBody:
	var b := SkyBody.new()
	b.light = l
	b.is_moon = moon
	parent.add_child(b)
	return b


func _ready() -> void:
	var r := 28.0 if is_moon else 16.0
	_core_mat = _mat(Color.WHITE, 1.0)
	_core = _sphere(r, _core_mat)
	if is_moon:
		# Ay lekeleri (denizler)
		var dark := _mat(Color(0.62, 0.63, 0.6), 1.0)
		# Kameraya bakan yüzde (yerel -Z): look_at ile hep kameraya döner
		for o in [Vector3(-0.3, 0.25, -0.8), Vector3(0.28, -0.1, -0.85), Vector3(-0.05, -0.4, -0.8)]:
			var sp := _sphere(r * 0.28, dark)
			sp.position = o * r * 0.82
	for k in 3:
		var hm := _mat(Color.WHITE, 0.0)
		hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_halo_mats.append(hm)
		_halos.append(_sphere(r * (1.6 + k * 1.3), hm))
	_update()


func _mat(c: Color, emission: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = c
	m.disable_fog = true
	m.disable_receive_shadows = true
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emission
	return m


func _sphere(r: float, m: StandardMaterial3D) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	sm.radial_segments = 24
	sm.rings = 12
	mi.mesh = sm
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


func _process(_delta: float) -> void:
	_update()


func _update() -> void:
	if not is_instance_valid(light):
		queue_free()
		return
	var cam := get_viewport().get_camera_3d() if is_inside_tree() else null
	var origin := cam.global_position if cam else Vector3.ZERO
	# Işık -Z yönüne yayılır: kaynak +Z yönündedir
	var dir := light.global_transform.basis.z.normalized() if light.is_inside_tree() else light.transform.basis.z.normalized()
	global_position = origin + dir * dist
	if is_moon and absf(dir.dot(Vector3.UP)) < 0.99:
		look_at(origin, Vector3.UP)
	var c := light.light_color
	if is_moon:
		_core_mat.albedo_color = Color("f4f0dc")
		_core_mat.emission = Color("f4f0dc")
		_core_mat.emission_energy_multiplier = 1.6
	else:
		var core := Color(1.0, 0.97, 0.88).lerp(c, 0.35)
		_core_mat.albedo_color = core
		_core_mat.emission = core
		_core_mat.emission_energy_multiplier = 3.0
	for k in _halo_mats.size():
		var hc := (Color("c8d4ff") if is_moon else c)
		hc.a = [0.22, 0.09, 0.04][k] * (0.8 if is_moon else 1.0)
		_halo_mats[k].albedo_color = hc
