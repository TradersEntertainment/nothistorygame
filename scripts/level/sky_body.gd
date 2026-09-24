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
var _spot_mat: StandardMaterial3D
var _eclipse := 0.0   # 0: dolunay, 1: tam tutulma (bakır kırmızısı "kanlı ay")


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
		_spot_mat = dark
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
		var mc := Color("f4f0dc").lerp(Color("8a3a26"), _eclipse)
		_core_mat.albedo_color = mc
		_core_mat.emission = mc
		_core_mat.emission_energy_multiplier = lerpf(1.6, 1.1, _eclipse)
		if _spot_mat:
			var sc := Color(0.62, 0.63, 0.6).lerp(Color("5a2418"), _eclipse)
			_spot_mat.albedo_color = sc
			_spot_mat.emission = sc
	else:
		var core := Color(1.0, 0.97, 0.88).lerp(c, 0.35)
		_core_mat.albedo_color = core
		_core_mat.emission = core
		_core_mat.emission_energy_multiplier = 3.0
	for k in _halo_mats.size():
		var hc := (Color("c8d4ff") if is_moon else c)
		if is_moon:
			hc = hc.lerp(Color("c86a4a"), _eclipse)
		hc.a = [0.22, 0.09, 0.04][k] * (0.8 if is_moon else 1.0) * (1.0 - _eclipse * 0.6)
		_halo_mats[k].albedo_color = hc


## Ay tutulması: ay yavaşça bakır kırmızısına döner, hale söner, ay ışığı zayıflar. Tween döner.
func eclipse(on: bool, seconds := 5.0) -> Tween:
	var tw := create_tween().set_parallel()
	tw.tween_property(self, "_eclipse", 1.0 if on else 0.0, seconds).set_trans(Tween.TRANS_SINE)
	if is_instance_valid(light):
		var e0 := light.light_energy
		tw.tween_property(light, "light_energy", e0 * (0.35 if on else 1.0 / 0.35), seconds)
	return tw
