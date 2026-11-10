class_name Gulls
extends Node3D
## Martı sürüsü: merkez çevresinde farklı yarıçap ve yükseklikte süzülen, kanat çırpan basit kuşlar (ucuz).

var _birds: Array = []
var _t := 0.0


static func make(parent: Node3D, center: Vector3, count := 9, radius := 40.0, height := 30.0, seed := 1) -> Gulls:
	var g := Gulls.new()
	g.position = center
	parent.add_child(g)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("f4f2ec")
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	for i in count:
		var b := Node3D.new()
		g.add_child(b)
		var wings: Array = []
		for sx in [-1, 1]:
			var w := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = Vector3(0.9, 0.04, 0.3)
			w.mesh = bm
			w.material_override = mat
			var pivot := Node3D.new()
			b.add_child(pivot)
			pivot.add_child(w)
			w.position = Vector3(sx * 0.45, 0, 0)
			wings.append([pivot, sx])
		var body := MeshInstance3D.new()
		var cm := CapsuleMesh.new()
		cm.radius = 0.1
		cm.height = 0.5
		body.mesh = cm
		body.rotation.x = PI * 0.5
		body.material_override = mat
		b.add_child(body)
		g._birds.append({"node": b, "wings": wings, "r": radius * rng.randf_range(0.5, 1.2), "h": height + rng.randf_range(-8.0, 10.0),
			"sp": rng.randf_range(0.18, 0.35) * (1.0 if rng.randf() < 0.7 else -1.0), "a": rng.randf() * TAU, "ph": rng.randf() * TAU})
	return g


func _process(delta: float) -> void:
	_t += delta
	for b in _birds:
		b.a += b.sp * delta
		var p := Vector3(cos(b.a) * b.r, b.h + sin(_t * 0.7 + b.ph) * 2.0, sin(b.a) * b.r)
		var n: Node3D = b.node
		n.position = p
		n.rotation.y = -b.a + (PI if b.sp > 0.0 else 0.0)
		var flap := sin(_t * 7.0 + b.ph) * 0.5 if fmod(_t + b.ph, 5.0) < 2.2 else 0.12
		for w in b.wings:
			(w[0] as Node3D).rotation.z = flap * w[1]


## Uzak sürü (tek çizim, işlemcide iş yok): bütün kuşlar tek MultiMesh; dönüş, süzülme, kanat çırpma gölgelendiricide
## (make'deki kuşlarla aynı devinim). Örnek verisi: yarıçap, yükseklik, açısal hız (işaretli), evre.
const FLOCK_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;
uniform vec3 col : source_color = vec3(0.96, 0.95, 0.92);
void vertex() {
	vec4 cd = INSTANCE_CUSTOM;
	float a = cd.w + cd.z * TIME;
	float ph = cd.w * 7.0;
	float flap = mod(TIME + ph, 5.0) < 2.2 ? sin(TIME * 7.0 + ph) * 0.5 : 0.12;
	vec3 v = VERTEX;
	v.y += flap * abs(v.x) * 0.9;
	float yaw = -a + (cd.z > 0.0 ? 3.14159 : 0.0);
	float c = cos(yaw);
	float s = sin(yaw);
	v = vec3(c * v.x + s * v.z, v.y, -s * v.x + c * v.z);
	VERTEX = v + vec3(cos(a) * cd.x, cd.y + sin(TIME * 0.7 + ph) * 2.0, sin(a) * cd.x);
}
void fragment() {
	ALBEDO = col * COLOR.rgb;
}
"""
static var _flock_mat: ShaderMaterial
static var _flock_mesh: ArrayMesh


static func flock_mm(parent: Node3D, center: Vector3, count := 9, radius := 40.0, height := 30.0, seed := 1) -> MultiMeshInstance3D:
	if _flock_mat == null:
		var sh := Shader.new()
		sh.code = FLOCK_SHADER
		_flock_mat = ShaderMaterial.new()
		_flock_mat.shader = sh
		var k := MeshKit.new()
		# Uzaktan görünsün diye yakın sürüdekilerin (make) ~1,5 katı (sahne ölçeği). Baş −z'de (hareket yönü).
		# Eskiden düz bir kutu gövde ve iki düz dörtgen kanattı: yakından (Galata Kulesi'nin yanında) beyaz bir "T" gibi
		# okunuyordu. Şimdi martı biçimi: ince gövde, baş ve sarı gaga, kuyruk, dirsekten kırılan (M) kanatlar, koyu uç.
		var g := Basis.from_scale(Vector3.ONE * 1.5)
		var xf := Transform3D(g, Vector3.ZERO)
		var white := Color(0.96, 0.96, 0.94)
		k.box(Transform3D(g, Vector3(0, 0, 0.02)), Vector3(0.13, 0.11, 0.40), white)
		k.box(Transform3D(g, Vector3(0, 0.02, -0.25)), Vector3(0.09, 0.09, 0.12), white)
		k.box(Transform3D(g, Vector3(0, 0.0, -0.34)), Vector3(0.03, 0.03, 0.08), Color(0.95, 0.7, 0.2))
		k._quad(xf, Vector3(-0.06, 0.0, 0.2), Vector3(0.06, 0.0, 0.2), Vector3(0.1, 0.0, 0.42), Vector3(-0.1, 0.0, 0.42), Color(0.88, 0.88, 0.9))
		for sx: float in [-1.0, 1.0]:
			var shade := 1.0 if sx < 0 else 0.9
			var wc := Color(shade, shade, shade * 0.98)
			# İç kanat: gövdeden dirseğe (hafif yukarı), dış kanat: dirsekten geriye süpürülen sivri uç
			k._quad(xf, Vector3(sx * 0.06, 0.0, -0.12), Vector3(sx * 0.5, 0.07, -0.1), Vector3(sx * 0.5, 0.07, 0.1), Vector3(sx * 0.06, 0.0, 0.16), wc)
			k._tri(xf, Vector3(sx * 0.5, 0.07, -0.1), Vector3(sx * 0.82, 0.04, 0.16), Vector3(sx * 0.5, 0.07, 0.1), wc)
			k._tri(xf, Vector3(sx * 0.7, 0.05, 0.04), Vector3(sx * 1.0, 0.03, 0.3), Vector3(sx * 0.82, 0.04, 0.16), Color(0.22, 0.22, 0.26))
		var am := ArrayMesh.new()
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, k.arrays())
		_flock_mesh = am
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.use_colors = true          # gl_compatibility: örnek rengi yoksa COLOR siyah gelir
	mm.mesh = _flock_mesh
	mm.instance_count = count
	for i in count:
		mm.set_instance_transform(i, Transform3D.IDENTITY)
		mm.set_instance_color(i, Color.WHITE)
		mm.set_instance_custom_data(i, Color(radius * rng.randf_range(0.5, 1.2), height + rng.randf_range(-8.0, 10.0),
			rng.randf_range(0.18, 0.35) * (1.0 if rng.randf() < 0.7 else -1.0), rng.randf() * TAU))
	var mi := MultiMeshInstance3D.new()
	mi.name = "GullFlock"
	mi.multimesh = mm
	mi.material_override = _flock_mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.custom_aabb = AABB(Vector3(-radius * 1.3, height - 12.0, -radius * 1.3), Vector3(radius * 2.6, 26.0, radius * 2.6))
	mi.visibility_range_end = 700.0
	mi.position = center
	mi.set_meta("no_walk", true)
	mi.set_meta("soft", true)
	parent.add_child(mi)
	return mi
