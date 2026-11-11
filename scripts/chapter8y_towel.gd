extends RefCounted
## Ara bölüm "Beyaz Havlu" (scripts/chapter8y.gd) için sırığa bağlı havlu: Niko'nun "imparatorluk havlusu".
## class_name yok: preload("res://scripts/chapter8y_towel.gd") ile kullanılır (Player.show_prop "towel_pole" de).
##
## Kök düğüm tutma noktasıdır (iki elin arası); yerel +Y sırık boyunca yukarı. Sırığın alt ucu kökün GRIP_LOW altında,
## tepesi POLE_TOP'ta. Havlu tepeye iki ip sargısıyla bağlıdır, sırıktan yerel +X'e uzanır ve kendi köşe
## gölgelendiricisiyle rüzgârda dalgalanır (Vfx.sway_material'in bayrağa göre yazılmış hâli: salınım dikine değil,
## sırıktan uzaklaştıkça büyür; serbest uç hafifçe sarkar). Havlu bayrak gibi tek kat değil, iki yüzü de görünür.
## İki elin sırıktaki yerleri: LEFT_GRIP (üstteki el) ve RIGHT_GRIP (alttaki el), kökün yerelinde.

const POLE_TOP := 1.62
const GRIP_LOW := -0.42
const POLE_R := 0.017
const CLOTH_W := 0.62
const CLOTH_H := 0.44
const LEFT_GRIP := Vector3(0.0, 0.22, 0.0)
const RIGHT_GRIP := Vector3(0.0, -0.13, 0.0)
const C_POLE := Color("7a5634")
const C_ROPE := Color("b89a6a")
const C_CLOTH := Color("eee8da")

static var _shader: Shader


## Sırık + havlu. sway: dalgalanma genliği (0: durgun). Döner: kök; meta "cloth" = havlunun MeshInstance3D'si.
static func pole_model(sway := 0.07) -> Node3D:
	var root := Node3D.new()
	root.name = "TowelPole"
	var len := POLE_TOP - GRIP_LOW
	# Kaba yontulmuş mızrak sapı: iki ton (alt ucu elden kararmış), tepede küçük topuz
	Props.cyl(root, POLE_R, len, Vector3(0, GRIP_LOW + len * 0.5, 0), C_POLE, Vector3.ZERO, 6)
	Props.cyl(root, POLE_R + 0.002, 0.42, Vector3(0, -0.02, 0), C_POLE.darkened(0.25), Vector3.ZERO, 6)
	Props.ball(root, POLE_R * 1.5, Vector3(0, POLE_TOP + 0.01, 0), C_POLE.darkened(0.15), Vector3.ONE, 6)
	# Havlunun sırığa bağlandığı iki ip sargısı ve düğüm (havlu sırıkta havada durmasın)
	var top := POLE_TOP - 0.05
	for y: float in [top, top - CLOTH_H + 0.04]:
		for k in 3:
			Props.cyl(root, POLE_R + 0.006, 0.012, Vector3(0, y - 0.016 * k, 0), C_ROPE.darkened(0.05 * k), Vector3.ZERO, 6)
		Props.ball(root, 0.014, Vector3(0.018, y - 0.02, 0.006), C_ROPE.darkened(0.15), Vector3(1.0, 0.8, 0.8), 5)
		Props.cyl(root, 0.004, 0.07, Vector3(0.022, y - 0.06, 0.012), C_ROPE.darkened(0.1), Vector3(0, 0, 12), 4)
	var cloth := MeshInstance3D.new()
	cloth.name = "Towel"
	cloth.mesh = cloth_mesh()
	cloth.position = Vector3(POLE_R * 0.6, top + 0.01, 0)
	cloth.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	var m := ShaderMaterial.new()
	m.shader = _cloth_shader()
	m.set_shader_parameter("amp", sway)
	m.set_shader_parameter("width", CLOTH_W)
	cloth.material_override = m
	root.add_child(cloth)
	root.set_meta("cloth", cloth)
	return root


## Dalgalanmanın genliği ve hızı (havlu inince ağır sarkar, kalkınca yeniden dalgalanır).
static func set_sway(pole: Node3D, amp: float, speed := 3.2) -> void:
	if pole == null or not pole.has_meta("cloth"):
		return
	var cloth := pole.get_meta("cloth") as MeshInstance3D
	if cloth == null or not (cloth.material_override is ShaderMaterial):
		return
	var m := cloth.material_override as ShaderMaterial
	m.set_shader_parameter("amp", amp)
	m.set_shader_parameter("speed", speed)


## Havlunun ağı: 10×6 ızgara (dalga ağın içinden geçsin), köşe renkleri: kırık beyaz, hafif lekeli; serbest uca yakın
## iki ince peştemal çizgisi (lacivert, kızıl) ve saçak. Yerel: x 0 sırıkta, CLOTH_W serbest uç; y 0 üst kenar, aşağı −.
static func cloth_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nx := 10
	var ny := 6
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var col := func(u: float, v: float) -> Color:
		var c := C_CLOTH.darkened(rng.randf_range(0.0, 0.06))
		if (u > 0.78 and u < 0.82) or (u > 0.86 and u < 0.88):
			c = Color("3a4c78") if u < 0.83 else Color("a8323a")
		# Sırığa yakın kenar ve alt kenar biraz kirli (elden ve çamurdan)
		c = c.darkened(0.12 * (1.0 - smoothstep(0.0, 0.18, u)) + 0.1 * smoothstep(0.75, 1.0, v))
		return c
	for j in ny:
		for i in nx:
			var u0 := float(i) / nx
			var u1 := float(i + 1) / nx
			var v0 := float(j) / ny
			var v1 := float(j + 1) / ny
			var quad := [Vector2(u0, v0), Vector2(u1, v0), Vector2(u1, v1), Vector2(u0, v0), Vector2(u1, v1), Vector2(u0, v1)]
			for q: Vector2 in quad:
				st.set_color(col.call(q.x, q.y))
				st.set_normal(Vector3(0, 0, 1))
				st.add_vertex(Vector3(q.x * CLOTH_W, -q.y * CLOTH_H, 0.0))
	# Saçak: serbest uçta kısa ipliksi şeritler
	for k in 9:
		var y := -0.03 - k * (CLOTH_H - 0.06) / 8.0
		var x0 := CLOTH_W
		var x1 := CLOTH_W + 0.035
		for q: Vector3 in [Vector3(x0, y + 0.006, 0), Vector3(x1, y + 0.004, 0), Vector3(x1, y - 0.004, 0),
				Vector3(x0, y + 0.006, 0), Vector3(x1, y - 0.004, 0), Vector3(x0, y - 0.006, 0)]:
			st.set_color(C_CLOTH.darkened(0.15))
			st.set_normal(Vector3(0, 0, 1))
			st.add_vertex(q)
	return st.commit()


static func _cloth_shader() -> Shader:
	if _shader:
		return _shader
	_shader = Shader.new()
	_shader.code = """shader_type spatial;
render_mode cull_disabled, diffuse_lambert, specular_disabled;
uniform float amp = 0.07;
uniform float speed = 3.2;
uniform float width = 0.62;
void vertex() {
	vec3 w = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float k = clamp(VERTEX.x / width, 0.0, 1.0);
	float ph = TIME * speed - VERTEX.x * 7.0 + VERTEX.y * 2.5 + w.x * 0.7 + w.z * 0.5;
	float s = sin(ph);
	VERTEX.z += s * amp * k;
	VERTEX.x -= abs(s) * amp * 0.25 * k;
	VERTEX.y -= k * k * (0.04 + amp * 0.6);
	float dz = amp * (cos(ph) * -7.0 * k + s / width);
	NORMAL = normalize(vec3(-dz, 0.0, 1.0));
}
void fragment() {
	ALBEDO = COLOR.rgb;
	if (!FRONT_FACING) { NORMAL = -NORMAL; }
	ROUGHNESS = 1.0;
}"""
	return _shader
