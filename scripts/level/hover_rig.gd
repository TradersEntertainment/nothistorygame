class_name HoverRig
extends Node3D
## Nihat'ın Kaldırma Formu Z-9 (Büro teknolojisi): ayağının altında havada duran, lamine edilmiş dev bir form;
## kenarları turkuaz ışıkla parlar, ortasında kırmızı "ONAYLANDI" damgası, altında pirinç çerçeve ve dört itici
## (turkuaz alev ve ışık), arkasında uçuşan küçük kâğıtlar ve kıvılcımlardan iz. Taşıyan düğümün çocuğu olur;
## kişi bunun üstünde ayakta durur (Person.set_activity("hover")).

const TEAL := Color("6ff2d8")
var _t := 0.0
var _glow: Array[MeshInstance3D] = []
var _light: OmniLight3D


static func make(parent: Node3D) -> HoverRig:
	var h := HoverRig.new()
	parent.add_child(h)
	h._build()
	h.scale = Vector3.ONE * 1.25
	return h


func _mat(col: Color, em := 0.0, unshaded := false, alpha := 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(col.r, col.g, col.b, alpha)
	if alpha < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if em > 0.0:
		m.emission_enabled = true
		m.emission = col
		m.emission_energy_multiplier = em
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


func _box(size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = pos
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


func _build() -> void:
	# Form: krem kâğıt, üstte başlık bandı, satırlar, kırmızı damga; altında pirinç çerçeve
	_box(Vector3(0.95, 0.03, 1.25), Vector3(0, -0.02, 0), _mat(Color("f2ecd8"), 0.15))
	_box(Vector3(0.95, 0.032, 0.16), Vector3(0, -0.018, -0.5), _mat(Color("2e4a6a")))
	for i in 5:
		_box(Vector3(0.7, 0.033, 0.018), Vector3(-0.05, -0.017, -0.3 + i * 0.13), _mat(Color("8a8a90")))
	var stamp := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.16
	cm.bottom_radius = 0.16
	cm.height = 0.035
	cm.radial_segments = 16
	stamp.mesh = cm
	stamp.position = Vector3(0.22, -0.016, 0.33)
	stamp.material_override = _mat(Color("c8262f"), 0.3)
	add_child(stamp)
	_box(Vector3(1.05, 0.05, 1.35), Vector3(0, -0.06, 0), _mat(Color("b08a3a"), 0.0))
	# Kenar ışığı (turkuaz, parlar)
	for e in [[Vector3(1.07, 0.02, 0.03), Vector3(0, -0.035, 0.68)], [Vector3(1.07, 0.02, 0.03), Vector3(0, -0.035, -0.68)],
			[Vector3(0.03, 0.02, 1.37), Vector3(0.53, -0.035, 0)], [Vector3(0.03, 0.02, 1.37), Vector3(-0.53, -0.035, 0)]]:
		_glow.append(_box(e[0], e[1], _mat(TEAL, 3.0, true)))
	# İticiler: pirinç nozullar ve turkuaz alev konileri
	for sx in [-0.38, 0.38]:
		for sz in [-0.48, 0.48]:
			var nz := MeshInstance3D.new()
			var nm := CylinderMesh.new()
			nm.top_radius = 0.07
			nm.bottom_radius = 0.1
			nm.height = 0.12
			nm.radial_segments = 10
			nz.mesh = nm
			nz.position = Vector3(sx, -0.14, sz)
			nz.material_override = _mat(Color("8a6a2a"))
			add_child(nz)
			var fl := MeshInstance3D.new()
			var fm := CylinderMesh.new()
			fm.top_radius = 0.08
			fm.bottom_radius = 0.0
			fm.height = 0.55
			fm.radial_segments = 10
			fl.mesh = fm
			fl.position = Vector3(sx, -0.47, sz)
			fl.material_override = _mat(TEAL, 4.0, true, 0.7)
			fl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(fl)
			_glow.append(fl)
	_light = OmniLight3D.new()
	_light.light_color = TEAL
	_light.light_energy = 2.5
	_light.omni_range = 4.0
	_light.position = Vector3(0, -0.4, 0)
	add_child(_light)
	# İz: uçuşan kâğıtlar ve turkuaz kıvılcımlar (dünyada kalır)
	var papers := CPUParticles3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(0.16, 0.22)
	papers.mesh = qm
	papers.material_override = _mat(Color("f2ecd8"), 0.2)
	papers.amount = 18
	papers.lifetime = 2.2
	papers.local_coords = false
	papers.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	papers.emission_box_extents = Vector3(0.4, 0.05, 0.5)
	papers.direction = Vector3(0, -0.3, 1)
	papers.spread = 40.0
	papers.initial_velocity_min = 0.6
	papers.initial_velocity_max = 1.6
	papers.gravity = Vector3(0, -0.6, 0)
	papers.angular_velocity_min = -180.0
	papers.angular_velocity_max = 180.0
	papers.position = Vector3(0, -0.1, 0)
	add_child(papers)
	var sparks := CPUParticles3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.035
	sm.height = 0.07
	sm.radial_segments = 6
	sm.rings = 3
	sparks.mesh = sm
	sparks.material_override = _mat(TEAL, 4.0, true)
	sparks.amount = 60
	sparks.lifetime = 0.9
	sparks.local_coords = false
	sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	sparks.emission_box_extents = Vector3(0.4, 0.02, 0.5)
	sparks.direction = Vector3(0, -1, 0)
	sparks.spread = 18.0
	sparks.initial_velocity_min = 2.0
	sparks.initial_velocity_max = 3.5
	sparks.gravity = Vector3.ZERO
	sparks.scale_amount_min = 0.4
	sparks.scale_amount_max = 1.0
	sparks.position = Vector3(0, -0.5, 0)
	add_child(sparks)


func _process(delta: float) -> void:
	_t += delta
	var pulse := 0.85 + sin(_t * 9.0) * 0.15
	for g in _glow:
		(g.material_override as StandardMaterial3D).emission_energy_multiplier = 4.5 * pulse
	_light.light_energy = 2.4 * pulse
