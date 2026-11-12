extends RefCounted
## ORDUGÂH-5: ocak başı, duman sütunu, gece ışığı ve çiğnenmiş zemin (docs/ORDUGAH_1453.md §2.4-6, §3.3, §5.3, §6, §7a-5/8).
##   ocak(): taş halka (yuvarlak taşlar), çatılmış odun, kor, kül lekesi; sacayağında kazan ya da şişte et; yanında odun
##           yığını ve balta. Alev oyunun gerçek alevi (Flame, K.ateslar), küp ateş YOK.
##   duman(): yükselen ince duman sütunları (host başına TEK çoklu ağ; gündüz açık gri, gece koyu ve soluk). Uzak katmana
##            pişmez (ShaderMaterial), orta ve yakın katmanda görünür: 70 m'den ordugâhın üstünde onlarca sütun.
##   isik(): gece yakın katmanda sınırlı sayıda gerçek ışık (OmniLight, gölgesiz), gerisi alevin halesi.
##   Zemin: yumuşak kenarlı (köşe saydamlığı) çiğnenmiş toprak lekeleri, tekerlek izli yollar, isli ocak çevresi.
## class_name YOK (ortak kural): preload ile erişilir.

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const B = K.Bld

const TAS_R := [Color("8a8274"), Color("767064"), Color("9a9080"), Color("6a6458")]


## Ocak gereçleri (yerel konum p: zemin noktası). tur: "kazan" (sacayağı + kazan), "sis" (şişte et), "sade" (yalnız ateş).
## det: taş/kül/kor, wd: odun, met: kazan/demir. lod 0 tam, lod 1 sade (halka + kazan).
static func ocak(det: B, wd: B, met: B, p: Vector3, lod: int, r: RandomNumberGenerator, tur := "kazan", odun_yigini := true) -> void:
	if lod >= 2:
		return              # uzak katman: ocak yalnız gece ışıyan nokta (yonetici), gereç pişmez (kurulum süresi)
	# kül ve is lekesi (alçak, yuvarlak; kesin kenar yerine iki halka)
	det.cylp(p + Vector3(0, 0.025, 0), 1.25, 0.02, Color("4a443c"), 10, 1.25)
	det.cylp(p + Vector3(0, 0.035, 0), 0.62, 0.02, Color("35302a"), 9, 0.62)
	# taş halka: yuvarlak taşlar (kutu yok)
	var n := 9 if lod == 0 else 6
	for i in n:
		var a := TAU * i / n + r.randf_range(-0.12, 0.12)
		var rr := r.randf_range(0.11, 0.16)
		det.sph(p + Vector3(cos(a) * 0.62, rr * 0.55, sin(a) * 0.62), rr, TAS_R[r.randi() % TAS_R.size()], 5 if lod == 0 else 4, Vector3(1.2, 0.8, 1.0))
	# kor (koyu kızıl, ortada) ve çatılmış odunlar (yuvarlak kesit)
	det.cylp(p + Vector3(0, 0.06, 0), 0.38, 0.05, Color("5a2a16"), 8, 0.3)
	if lod == 0:
		for i in 5:
			var a2 := TAU * i / 5.0 + 0.3
			var dp := Vector3(cos(a2) * 0.34, 0.1, sin(a2) * 0.34)
			var tip := Vector3(0, 0.48, 0)
			_kutuk(wd, p + dp, p + tip + dp * 0.15, 0.045, Color("4a3424") if i % 2 == 0 else Color("2a1e16"))
		# kor parçaları
		for i in 4:
			var a3 := r.randf() * TAU
			det.sph(p + Vector3(cos(a3) * 0.2, 0.07, sin(a3) * 0.2), 0.06, Color("a8401a"), 4, Vector3(1.2, 0.5, 1.0))
	match tur:
		"kazan":
			if lod == 0:
				for q in 3:
					var qa := q * TAU / 3.0 + 0.5
					_kutuk(wd, p + Vector3(cos(qa) * 0.95, 0.0, sin(qa) * 0.95), p + Vector3(0, 1.55, 0), 0.035, Color("4e3826"))
				met.cylp(p + Vector3(0, 1.17, 0), 0.008, 0.62, Color("2a2826"), 4)      # zincir
			# kazan: yuvarlak gövde (küre kesiti) + ağız halkası, bakır
			var kc := Color("8a5a2c").lerp(Color("6e4a26"), r.randf())
			met.sph(p + Vector3(0, 0.62, 0), 0.42, kc, 10 if lod == 0 else 6, Vector3(1.0, 0.72, 1.0))
			met.cylp(p + Vector3(0, 0.86, 0), 0.38, 0.06, kc.darkened(0.25), 10 if lod == 0 else 6, 0.4)
			met.cylp(p + Vector3(0, 0.885, 0), 0.34, 0.012, Color("6a5034"), 10 if lod == 0 else 6, 0.34)   # yemek yüzeyi
		"sis":
			if lod == 0:
				for sx in [-0.75, 0.75]:
					_kutuk(wd, p + Vector3(sx, 0.0, 0), p + Vector3(sx * 0.95, 0.85, 0), 0.03, Color("4e3826"))
				_kutuk(wd, p + Vector3(-0.95, 0.8, 0), p + Vector3(0.95, 0.8, 0), 0.016, Color("3a3a3a"))
				for i in 3:
					det.sph(p + Vector3(-0.3 + i * 0.3, 0.78, 0), 0.1, Color("7a3a22"), 5, Vector3(1.3, 0.8, 0.8))
	if odun_yigini and lod == 0:
		# odun yığını (yuvarlak kütükler) ve kütüğe saplı balta
		var o := p + Vector3(1.9, 0, -0.6)
		for i in 7:
			var row := 0 if i < 4 else (1 if i < 6 else 2)
			var k := i - (0 if row == 0 else (4 if row == 1 else 6))
			var x0 := -0.33 + k * 0.22 + row * 0.11
			_kutuk(wd, o + Vector3(x0, 0.08 + row * 0.15, -0.55), o + Vector3(x0, 0.08 + row * 0.15, 0.55), 0.075, Color("8c6a40").lerp(Color("6a4a2c"), float(i % 3) / 2.0))
		var kt := o + Vector3(0.95, 0, 0.3)
		wd.cylp(kt + Vector3(0, 0.2, 0), 0.2, 0.4, Color("7a5a38"), 7)        # kesme kütüğü
		_kutuk(wd, kt + Vector3(0.0, 0.38, 0.0), kt + Vector3(0.18, 0.95, 0.12), 0.022, Color("8a6a42"))   # balta sapı
		met.sph(kt + Vector3(0.0, 0.42, 0.0), 0.06, Color("4a4a4c"), 5, Vector3(1.6, 0.9, 0.4))         # balta başı (kütükte)


## Yuvarlak kesitli kütük/dal (a → b)
static func _kutuk(b: B, a: Vector3, c: Vector3, r: float, col: Color) -> void:
	var d := c - a
	var L := d.length()
	if L < 0.001:
		return
	var y := d / L
	var x := y.cross(Vector3.FORWARD if absf(y.dot(Vector3.UP)) > 0.9 else Vector3.UP).normalized()
	var z := x.cross(y).normalized()
	b.cyl(Transform3D(Basis(x, y, z), (a + c) * 0.5), r, L, col, 6, r * 0.9)


# ------------------------------------------------------------------ duman

static var _dmesh: ArrayMesh
static var _dmat := {}

const DUMAN_SHADER := """
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;
uniform vec4 renk : source_color = vec4(0.8, 0.79, 0.77, 1.0);
uniform float yogun = 0.5;
varying float faz;
void vertex() {
	faz = MODEL_MATRIX[3].x * 0.37 + MODEL_MATRIX[3].z * 0.71;
	float h = UV.y;
	VERTEX.x += (sin(TIME * 0.55 + faz + h * 3.0) * 0.35 + h * 0.9) * h * h * 4.0;
	VERTEX.z += cos(TIME * 0.45 + faz * 1.3 + h * 2.5) * 0.3 * h * h * 4.0;
}
void fragment() {
	float h = UV.y;
	float kenar = smoothstep(0.0, 0.75, 1.0 - abs(UV.x * 2.0 - 1.0));
	float dalga = 0.6 + 0.4 * sin(h * 17.0 - TIME * 1.3 + faz) * sin(h * 6.0 - TIME * 0.8 + faz * 2.0);
	float a = kenar * smoothstep(0.0, 0.08, h) * (1.0 - smoothstep(0.35, 1.0, h)) * dalga * yogun;
	ALBEDO = renk.rgb * (0.92 + 0.08 * h);
	ALPHA = clamp(a, 0.0, 1.0);
}
"""


## Birim duman sütunu: üç çapraz dikey şerit (0°/60°/120°), 8 satır; y 0..1 (örnek ölçeği boy), en dipte 0,35 → tepede 3 m
static func duman_mesh() -> ArrayMesh:
	if _dmesh != null:
		return _dmesh
	var v := PackedVector3Array()
	var uv := PackedVector2Array()
	var rows := 8
	for k in 3:
		var a := PI * k / 3.0
		var ax := Vector3(cos(a), 0, sin(a))
		for i in rows:
			var t0 := float(i) / rows
			var t1 := float(i + 1) / rows
			var w0 := 0.2 + 2.2 * t0 * t0 + 0.4 * t0
			var w1 := 0.2 + 2.2 * t1 * t1 + 0.4 * t1
			var p00 := ax * -w0 + Vector3(0, t0, 0)
			var p10 := ax * w0 + Vector3(0, t0, 0)
			var p01 := ax * -w1 + Vector3(0, t1, 0)
			var p11 := ax * w1 + Vector3(0, t1, 0)
			v.append_array([p00, p10, p11, p00, p11, p01])
			uv.append_array([Vector2(0, t0), Vector2(1, t0), Vector2(1, t1), Vector2(0, t0), Vector2(1, t1), Vector2(0, t1)])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_TEX_UV] = uv
	_dmesh = ArrayMesh.new()
	_dmesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return _dmesh


static func duman_mat(gece: bool) -> ShaderMaterial:
	var key := "g" if gece else "d"
	if _dmat.has(key):
		return _dmat[key]
	var sh := Shader.new()
	sh.code = DUMAN_SHADER
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("renk", Color(0.2, 0.19, 0.2) if gece else Color(0.83, 0.82, 0.8))
	m.set_shader_parameter("yogun", 0.16 if gece else 0.4)
	_dmat[key] = m
	return m


## pts: yerel ocak noktaları (Vector3, zeminde). Boy 14–26 m. Host başına tek çizim.
static func duman(host: Node3D, pts: Array, lod: int, r: RandomNumberGenerator) -> void:
	if pts.is_empty() or lod >= 2:
		return
	var xs: Array = []
	for p: Vector3 in pts:
		var h := r.randf_range(14.0, 26.0)
		var s := r.randf_range(0.8, 1.2)
		xs.append(Transform3D(Basis(Vector3.UP, r.randf() * TAU).scaled(Vector3(s, h, s)), p + Vector3(0, 0.5, 0)))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = duman_mesh()
	mm.instance_count = xs.size()
	var ab := AABB()
	for i in xs.size():
		var x: Transform3D = xs[i]
		mm.set_instance_transform(i, x)
		var bb := AABB(x.origin - Vector3(8, 0, 8), Vector3(16, x.basis.get_scale().y + 2.0, 16))
		ab = bb if i == 0 else ab.merge(bb)
	mm.custom_aabb = ab
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = duman_mat(K.gece)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.name = "duman"
	mi.set_meta("no_walk", true)
	host.add_child(mi)


## Gece: en çok n gerçek ışık (gölgesiz, kısa menzil); yalnız yakın katman
static func isik(host: Node3D, pts: Array, lod: int, n := 2) -> void:
	if not K.gece or lod != 0:
		return
	for i in mini(n, pts.size()):
		var p: Vector3 = pts[i]
		var l := OmniLight3D.new()
		l.light_color = Color(1.0, 0.62, 0.3)
		l.light_energy = 2.2
		l.omni_range = 11.0
		l.omni_attenuation = 1.3
		l.shadow_enabled = false
		l.position = p + Vector3(0, 0.9, 0)
		l.name = "ocak_isigi"
		host.add_child(l)


# ------------------------------------------------------------------ zemin (yumuşak kenarlı)

static var _zmat: StandardMaterial3D

static func zemin_mat() -> StandardMaterial3D:
	if _zmat == null:
		_zmat = StandardMaterial3D.new()
		_zmat.vertex_color_use_as_albedo = true
		_zmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_zmat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		_zmat.roughness = 1.0
		_zmat.cull_mode = BaseMaterial3D.CULL_BACK
		_zmat.render_priority = -1
		var nz := FastNoiseLite.new()
		nz.noise_type = FastNoiseLite.TYPE_CELLULAR
		nz.frequency = 0.09
		nz.fractal_octaves = 2
		var tx := NoiseTexture2D.new()
		tx.width = 256
		tx.height = 256
		tx.seamless = true
		tx.noise = nz
		var gr := Gradient.new()
		gr.set_color(0, Color(0.62, 0.58, 0.52))
		gr.set_color(1, Color(1.0, 1.0, 1.0))
		tx.color_ramp = gr
		_zmat.albedo_texture = tx
		_zmat.uv1_triplanar = true
		_zmat.uv1_world_triplanar = true
		_zmat.uv1_scale = Vector3(0.22, 0.22, 0.22)
	return _zmat


## Yumuşak leke: merkez + iki halka (iç halka opak, dış halka saydam), arazi izler. zemin(x,z) yerel yükseklik.
static func leke(b: B, c: Vector2, R: float, col: Color, r: RandomNumberGenerator, rot := Transform2D.IDENTITY, a_ic := 0.92, n := 14) -> void:
	var cw := rot * c
	var cy := K.gy(cw.x, cw.y) + 0.05
	var ic: Array = []
	var dis: Array = []
	for i in n:
		var a := TAU * i / n
		var rr := R * r.randf_range(0.75, 1.1)
		var p1 := rot * (c + Vector2.from_angle(a) * rr * 0.62)
		var p2 := rot * (c + Vector2.from_angle(a + r.randf_range(-0.1, 0.1)) * rr * 1.05)
		ic.append(Vector3(p1.x, K.gy(p1.x, p1.y) + 0.05, p1.y))
		dis.append(Vector3(p2.x, K.gy(p2.x, p2.y) + 0.045, p2.y))
	var c0 := Color(col.r, col.g, col.b, a_ic)
	var c2 := Color(col.r, col.g, col.b, 0.0)
	for i in n:
		var j := (i + 1) % n
		var c1 := Color(col.r, col.g, col.b, a_ic * r.randf_range(0.75, 0.95))
		_ztri(b, Vector3(cw.x, cy, cw.y), ic[i], ic[j], c0, c1, c1)
		_ztri(b, ic[i], dis[i], dis[j], c1, c2, c2)
		_ztri(b, ic[i], dis[j], ic[j], c1, c2, c1)


## Yol: yumuşak kenarlı şerit + iki tekerlek izi (koyu, ince), a → c yerel; parça 6 m, arazi izler
static func yol(b: B, a: Vector2, c: Vector2, w: float, col: Color, r: RandomNumberGenerator, rot := Transform2D.IDENTITY, izli := true) -> void:
	var L := a.distance_to(c)
	if L < 1.0:
		return
	var d := (c - a) / L
	var nrm := Vector2(-d.y, d.x)
	var n := maxi(1, int(L / 6.0))
	var serit := [[-0.5 - 0.35, 0.0], [-0.5, 0.85], [0.5, 0.85], [0.5 + 0.35, 0.0]]
	for i in n:
		var p0 := a + d * (L * i / n)
		var p1 := a + d * (L * (i + 1) / n)
		var mw := rot * ((p0 + p1) * 0.5)
		if K.filtre.is_valid() and not bool(K.filtre.call(mw.x, mw.y)):
			continue
		var cc := col.darkened(r.randf_range(0.0, 0.06))
		for k in serit.size() - 1:
			var e0: float = serit[k][0]
			var e1: float = serit[k + 1][0]
			var al0: float = serit[k][1]
			var al1: float = serit[k + 1][1]
			var q00 := rot * (p0 + nrm * w * e0)
			var q01 := rot * (p0 + nrm * w * e1)
			var q10 := rot * (p1 + nrm * w * e0)
			var q11 := rot * (p1 + nrm * w * e1)
			var v00 := Vector3(q00.x, K.gy(q00.x, q00.y) + 0.06, q00.y)
			var v01 := Vector3(q01.x, K.gy(q01.x, q01.y) + 0.06, q01.y)
			var v10 := Vector3(q10.x, K.gy(q10.x, q10.y) + 0.06, q10.y)
			var v11 := Vector3(q11.x, K.gy(q11.x, q11.y) + 0.06, q11.y)
			var k0 := Color(cc.r, cc.g, cc.b, al0)
			var k1 := Color(cc.r, cc.g, cc.b, al1)
			_ztri(b, v00, v10, v11, k0, k0, k1)
			_ztri(b, v00, v11, v01, k0, k1, k1)
		if izli:
			for side: float in [-0.22, 0.22]:
				var iz := Color(0.3, 0.24, 0.17, 0.55)
				var t0 := rot * (p0 + nrm * w * (side - 0.03))
				var t1 := rot * (p0 + nrm * w * (side + 0.03))
				var t2 := rot * (p1 + nrm * w * (side + 0.03))
				var t3 := rot * (p1 + nrm * w * (side - 0.03))
				var u0 := Vector3(t0.x, K.gy(t0.x, t0.y) + 0.075, t0.y)
				var u1 := Vector3(t1.x, K.gy(t1.x, t1.y) + 0.075, t1.y)
				var u2 := Vector3(t2.x, K.gy(t2.x, t2.y) + 0.075, t2.y)
				var u3 := Vector3(t3.x, K.gy(t3.x, t3.y) + 0.075, t3.y)
				_ztri(b, u0, u3, u2, iz, iz, iz)
				_ztri(b, u0, u2, u1, iz, iz, iz)


static func _ztri(b: B, a: Vector3, c1: Vector3, c2: Vector3, ka: Color, k1: Color, k2: Color) -> void:
	var cr := (c1 - a).cross(c2 - a)
	if cr.y > 0.0:
		b.v.append(a); b.v.append(c2); b.v.append(c1)
		b.c.append(ka); b.c.append(k2); b.c.append(k1)
	else:
		b.v.append(a); b.v.append(c1); b.v.append(c2)
		b.c.append(ka); b.c.append(k1); b.c.append(k2)
	b.n.append(Vector3.UP); b.n.append(Vector3.UP); b.n.append(Vector3.UP)
	b.tris += 1


## Yumuşak zemin ağını host'a ekler (tek çizim, saydam, gölgesiz). Uzak pişirmeye girmez (saydam).
static func zemin_bitir(b: B, host: Node3D, nm := "zemin_yumusak") -> void:
	if b.v.is_empty():
		return
	var mi := MeshInstance3D.new()
	mi.mesh = K.bld_mesh(b)
	mi.material_override = zemin_mat()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.name = nm
	mi.set_meta("no_walk", true)
	host.add_child(mi)
