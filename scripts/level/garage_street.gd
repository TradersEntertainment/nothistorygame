class_name GarageStreet
extends RefCounted
## Bölüm 1: garaj kapısının altından görünen yağmurlu İstanbul sokağı (gece 03.00).
## Oyuncu garajın içinde her yere gidip kapı açıklığına her açıdan bakabilir; bu yüzden dış dünya tek bir cephe
## değil, her yöne kapanan bir sokaktır: iki yöne giden yol ve kaldırım, uçlarda yol sonunu kapatan bina ve kavşak,
## karşıda farklı boyda apartmanlar (aralarında aralık ve ağaç), garajın iki yanında komşu binalar, arkada iki sıra
## şehir silueti, minareler, camiler ve bulutlu bir gök kubbesi. Hepsi birkaç büyük ağda toplanır (çizim çağrısı az).
## Canlı ve yuvarlak şeyler (kedi, araba, lamba, ağaç, saksı) kutudan değil, yuvarlak formlardan kurulur.

const SKY_SHADER := """
shader_type spatial;
render_mode unshaded, cull_front, fog_disabled;
uniform vec3 zenith : source_color = vec3(0.050, 0.062, 0.125);
uniform vec3 horizon : source_color = vec3(0.400, 0.270, 0.260);
uniform vec3 cloud_lit : source_color = vec3(0.620, 0.400, 0.320);
uniform vec3 cloud_dark : source_color = vec3(0.110, 0.125, 0.205);
varying vec3 dir;
void vertex() { dir = VERTEX; }
float h21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float vn(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1.0, 0.0)), f.x), mix(h21(i + vec2(0.0, 1.0)), h21(i + vec2(1.0, 1.0)), f.x), f.y);
}
float fbm(vec2 p) {
	float a = 0.5; float s = 0.0;
	for (int i = 0; i < 4; i++) { s += a * vn(p); p = p * 2.03 + vec2(17.1, 3.7); a *= 0.5; }
	return s;
}
void fragment() {
	vec3 d = normalize(dir);
	float up = clamp(d.y, 0.0, 1.0);
	vec3 col = mix(horizon, zenith, pow(up, 0.45));
	vec2 uv = d.xz / (max(d.y, 0.0) + 0.22) * 1.2;
	float c = fbm(uv + vec2(3.0, 1.0));
	float dens = smoothstep(0.40, 0.76, c);
	float glow = clamp(1.0 - up * 1.5, 0.0, 1.0);
	vec3 ccol = mix(cloud_dark, cloud_lit, glow * smoothstep(0.25, 0.75, fbm(uv * 2.1 + 8.0)));
	col = mix(col, ccol, dens * 0.9 * smoothstep(0.0, 0.12, d.y + 0.05));
	ALBEDO = col;
}
"""


# ============================================================ yığın (batch): tek ağda birçok parça

class Batch:
	static func _sp(x: float, e: float) -> float:
		return signf(x) * pow(absf(x), e)

	var st := SurfaceTool.new()
	var tris := 0

	func _init() -> void:
		st.begin(Mesh.PRIMITIVE_TRIANGLES)

	func _v(p: Vector3, n: Vector3, c: Color) -> void:
		st.set_normal(n)
		st.set_color(c)
		st.add_vertex(p)

	## p0..p3: n tarafından bakınca saat yönünün tersi.
	func quad(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, n: Vector3, c: Color) -> void:
		_v(p0, n, c)
		_v(p2, n, c)
		_v(p1, n, c)
		_v(p0, n, c)
		_v(p3, n, c)
		_v(p2, n, c)
		tris += 2

	## Yerel +z'ye bakan düz levha (pencere camı, tabela): xf'in orijininde, w x h.
	func plate(xf: Transform3D, w: float, h: float, c: Color) -> void:
		quad(xf * Vector3(-w * 0.5, -h * 0.5, 0), xf * Vector3(w * 0.5, -h * 0.5, 0), xf * Vector3(w * 0.5, h * 0.5, 0),
			xf * Vector3(-w * 0.5, h * 0.5, 0), (xf.basis * Vector3(0, 0, 1)).normalized(), c)

	## Köşe renkli düz parça (yansıma çizgisi, ışık havuzu).
	func quadc(p: Array, n: Vector3, cs: Array) -> void:
		if ((p[1] as Vector3) - (p[0] as Vector3)).cross((p[2] as Vector3) - (p[0] as Vector3)).dot(n) < 0.0:
			p = [p[0], p[3], p[2], p[1]]
			cs = [cs[0], cs[3], cs[2], cs[1]]
		_v(p[0], n, cs[0])
		_v(p[2], n, cs[2])
		_v(p[1], n, cs[1])
		_v(p[0], n, cs[0])
		_v(p[3], n, cs[3])
		_v(p[2], n, cs[2])
		tris += 2

	## skip: atlanacak yüzler (bit f: 0 +x, 1 +y, 2 +z, 3 -x, 4 -y, 5 -z; yerel eksenlerde). Varsayılan: alt yüz.
	func box(xf: Transform3D, size: Vector3, c: Color, skip := 16) -> void:
		var h := size * 0.5
		for f in 6:
			var ax := f % 3
			var sgn := 1.0 if f < 3 else -1.0
			if (skip >> f) & 1 == 1:
				continue
			var a1 := (ax + 1) % 3
			var a2 := (ax + 2) % 3
			if sgn < 0.0:
				var t := a1
				a1 = a2
				a2 = t
			var n := Vector3.ZERO
			n[ax] = sgn
			var u := Vector3.ZERO
			u[a1] = 1.0
			var v := Vector3.ZERO
			v[a2] = 1.0
			var ctr := n * h[ax]
			var hu: float = h[a1]
			var hv: float = h[a2]
			quad(xf * (ctr - u * hu - v * hv), xf * (ctr + u * hu - v * hv), xf * (ctr + u * hu + v * hv),
				xf * (ctr - u * hu + v * hv), (xf.basis * n).normalized(), c)

	## Gövde yüzeyi (ızgara): P[satır][sütun]. wrap: sütunlar kapanır. Normaller komşulardan; dışa bakan yön
	## (kapalı şekilde merkeze göre, açıkta `ref` yönüne göre) seçilir.
	func grid(P: Array, wrap: bool, c: Color, ref := Vector3.ZERO, colfn := Callable()) -> void:
		var R := P.size()
		var S: int = (P[0] as PackedVector3Array).size()
		var cen := Vector3.ZERO
		var cnt := 0
		for r in P:
			for p in (r as PackedVector3Array):
				cen += p
				cnt += 1
		cen /= float(cnt)
		var N: Array = []
		var sum := 0.0
		for i in R:
			var row := PackedVector3Array()
			row.resize(S)
			for j in S:
				var j0 := (j - 1 + S) % S if wrap else maxi(j - 1, 0)
				var j1 := (j + 1) % S if wrap else mini(j + 1, S - 1)
				var i0 := maxi(i - 1, 0)
				var i1 := mini(i + 1, R - 1)
				var pij: Vector3 = (P[i] as PackedVector3Array)[j]
				var tj: Vector3 = (P[i] as PackedVector3Array)[j1] - (P[i] as PackedVector3Array)[j0]
				var ti: Vector3 = (P[i1] as PackedVector3Array)[j] - (P[i0] as PackedVector3Array)[j]
				var n := ti.cross(tj)
				if n.length() < 1e-9:
					n = pij - cen
				n = n.normalized()
				row[j] = n
				sum += n.dot(ref if ref != Vector3.ZERO else (pij - cen))
			N.append(row)
		var s := 1.0 if sum >= 0.0 else -1.0
		var jmax := S if wrap else S - 1
		for i in R - 1:
			for j in jmax:
				var j2 := (j + 1) % S
				var A: Vector3 = (P[i] as PackedVector3Array)[j]
				var B: Vector3 = (P[i] as PackedVector3Array)[j2]
				var C: Vector3 = (P[i + 1] as PackedVector3Array)[j]
				var D: Vector3 = (P[i + 1] as PackedVector3Array)[j2]
				var nA: Vector3 = (N[i] as PackedVector3Array)[j] * s
				var nB: Vector3 = (N[i] as PackedVector3Array)[j2] * s
				var nC: Vector3 = (N[i + 1] as PackedVector3Array)[j] * s
				var nD: Vector3 = (N[i + 1] as PackedVector3Array)[j2] * s
				var cc := c
				if colfn.is_valid():
					cc = colfn.call(i, j)
				if s > 0.0:
					_v(A, nA, cc)
					_v(B, nB, cc)
					_v(D, nD, cc)
					_v(A, nA, cc)
					_v(D, nD, cc)
					_v(C, nC, cc)
				else:
					_v(A, nA, cc)
					_v(D, nD, cc)
					_v(B, nB, cc)
					_v(A, nA, cc)
					_v(C, nC, cc)
					_v(D, nD, cc)
				tris += 2

	## Süperelipsoid: e1 = 1, e2 = 1 elipsoid; küçük değerler yuvarlatılmış kutu.
	func sup(xf: Transform3D, r: Vector3, e1: float, e2: float, c: Color, seg := 14, rings := 8) -> void:
		var P: Array = []
		for i in rings + 1:
			var phi := -PI / 2.0 + PI * float(i) / float(rings)
			var cf := _sp(cos(phi), e1)
			var sf := _sp(sin(phi), e1)
			var row := PackedVector3Array()
			for j in seg:
				var th := TAU * float(j) / float(seg)
				row.append(xf * Vector3(r.x * cf * _sp(cos(th), e2), r.y * sf, r.z * cf * _sp(sin(th), e2)))
			P.append(row)
		grid(P, true, c)

	func ball(xf: Transform3D, r: Vector3, c: Color, seg := 12, rings := 7) -> void:
		sup(xf, r, 1.0, 1.0, c, seg, rings)

	## Dönel gövde: profil (yarıçap, yükseklik) noktaları, y ekseni etrafında.
	func lathe(xf: Transform3D, prof: Array, c: Color, sides := 10) -> void:
		var P: Array = []
		for pt in prof:
			var row := PackedVector3Array()
			for j in sides:
				var th := TAU * float(j) / float(sides)
				row.append(xf * Vector3((pt as Vector2).x * cos(th), (pt as Vector2).y, (pt as Vector2).x * sin(th)))
			P.append(row)
		grid(P, true, c)

	## Boru: yol noktaları ve yarıçaplar; ucu yarıçap 0 ise kapanır.
	func tube(xf: Transform3D, pts: Array, radii: Array, c: Color, sides := 6) -> void:
		var P: Array = []
		var n := pts.size()
		for i in n:
			var t: Vector3 = (pts[mini(i + 1, n - 1)] as Vector3) - (pts[maxi(i - 1, 0)] as Vector3)
			t = t.normalized()
			var up := Vector3.UP if absf(t.y) < 0.9 else Vector3.RIGHT
			var a := t.cross(up).normalized()
			var b := t.cross(a).normalized()
			var row := PackedVector3Array()
			for j in sides:
				var th := TAU * float(j) / float(sides)
				row.append(xf * ((pts[i] as Vector3) + (a * cos(th) + b * sin(th)) * float(radii[i])))
			P.append(row)
		grid(P, true, c)

	## Yatay yassı elips (su birikintisi, rögar kapağı gölgesi).
	func disc(xf: Transform3D, r: float, c: Color, sides := 14) -> void:
		var n := (xf.basis * Vector3.UP).normalized()
		for j in sides:
			var a0 := TAU * float(j) / float(sides)
			var a1 := TAU * float(j + 1) / float(sides)
			var p0 := xf * Vector3.ZERO
			var p1 := xf * Vector3(cos(a0) * r, 0.0, sin(a0) * r)
			var p2 := xf * Vector3(cos(a1) * r, 0.0, sin(a1) * r)
			_v(p0, n, c)
			_v(p1, n, c)
			_v(p2, n, c)
			tris += 1

	func commit(parent: Node3D, mat: Material, pos := Vector3.ZERO) -> MeshInstance3D:
		var mi := MeshInstance3D.new()
		mi.mesh = st.commit()
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.position = pos
		parent.add_child(mi)
		return mi


static func _sp(x: float, e: float) -> float:
	return signf(x) * pow(absf(x), e)


static func _at(xf: Transform3D, pos: Vector3, rot_deg := Vector3.ZERO) -> Transform3D:
	return xf * Transform3D(Basis.from_euler(rot_deg * (PI / 180.0)), pos)


# ============================================================ malzemeler

static func _mat_flat(emit := 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.vertex_color_use_as_albedo = true
	m.albedo_color = Color(emit, emit, emit)
	return m


static func _mat_lit(outline: bool, double_sided := false) -> StandardMaterial3D:
	var m := Props.mat(Color.WHITE, 0.0, false, "", outline).duplicate() as StandardMaterial3D
	m.vertex_color_use_as_albedo = true
	if double_sided:
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


static func _mat_add(alpha_mix := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.vertex_color_use_as_albedo = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if not alpha_mix:
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	return m


static func _glow_tex() -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(0.35, Color(1, 1, 1, 0.35))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 64
	t.height = 64
	return t


# ============================================================ ana kurucu

## Dönüş: {"cat_eyes": ...} yok; yalnız düğümler eklenir. root: Garage düğümü (orijin = garajın ortası, kapı +z).
static func build(root: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var ch := Chunks.new()          # uzak bina ve silüetler (ışıksız, köşe rengi) ve yanık pencereler, x bölgelerine ayrık
	var glow := ch.g(0.0)           # lamba camı, kedi gözü
	var near := Batch.new()         # yakın kahramanlar (ışıklı, dış hatlı): Şahin, kedi, lamba
	var cloth := Batch.new()        # branda (çift yüzlü)
	var streak := Batch.new()       # ıslak yoldaki ışık yansımaları (toplamalı)
	var pud := Batch.new()          # su birikintileri (yarı saydam)

	_ground(root)
	_buildings(ch, streak, rng)
	_skyline(ch, rng)
	_trees(ch, rng)
	_lamp(near, glow, root)
	_parked(ch, rng)
	car(near, cloth, glow, Transform3D(Basis.from_euler(Vector3(0, PI / 2.0, 0)), Vector3(3.0, 0.0, 8.6)),
		Color("7a2420"), true)
	cat(near, glow, Transform3D(Basis.from_euler(Vector3(0, PI / 2.0, 0)), Vector3(3.0, 0.0, 8.6)) \
		* Transform3D(Basis.from_euler(Vector3(0, deg_to_rad(95.0), 0)), Vector3(0.1, 0.80, 1.42)))
	_puddles(pud, rng)
	_manholes_pots(ch)

	var m_far := _mat_flat(1.0)
	var m_glow := _mat_flat(1.5)
	for k in ch.far:
		(ch.far[k] as Batch).commit(root, m_far)
		(ch.glow[k] as Batch).commit(root, m_glow)
	var m_mid := _mat_lit(false)
	for k in ch.mid:
		(ch.mid[k] as Batch).commit(root, m_mid)
	near.commit(root, _mat_lit(true))
	cloth.commit(root, _mat_lit(false, true))
	streak.commit(root, _mat_add(false))
	pud.commit(root, _mat_add(true))
	_sky(root)
	_halos(root)


# ------------------------------------------------------------ yer, yol, kaldırım

static func _ground(root: Node3D) -> void:
	# Ufka kadar ıslak zemin: perdenin altında boşluk, yolun altında boşluk olmasın
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color("1a1c22")
	gm.roughness = 0.2
	gm.metallic_specular = 0.8
	var ground := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(620, 0.2, 620)
	ground.mesh = bm
	ground.material_override = gm
	ground.position = Vector3(0, -0.27, 10.0)
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(ground)
	# Islak asfalt (ana cadde ve kavşağın kuzeye giden kolu)
	var wet := StandardMaterial3D.new()
	wet.albedo_color = Color("24262a")
	wet.roughness = 0.12
	wet.metallic_specular = 0.9
	var road := Props.box(root, Vector3(112, 0.2, 10.5), Vector3(0, -0.12, 9.95), Color("24262a"))
	road.material_override = wet
	var cross := Props.box(root, Vector3(12, 0.2, 48), Vector3(37.0, -0.13, 39.0), Color("24262a"))
	cross.material_override = wet
	# Garaj tarafı kaldırımı (garajın eşiğinden yola kadar) ve bordür; karşı kaldırım
	Props.box(root, Vector3(112, 0.14, 1.7), Vector3(0, -0.02, 3.85), Color("5a5a5e"))
	Props.box(root, Vector3(112, 0.16, 0.2), Vector3(0, -0.02, 4.85), Color("7a7a7e"))
	Props.box(root, Vector3(112, 0.14, 4.0), Vector3(0, -0.025, 17.2), Color("55555a"))
	Props.box(root, Vector3(112, 0.16, 0.2), Vector3(0, -0.015, 15.05), Color("7a7a7e"))


# ------------------------------------------------------------ binalar

const FACADES := [Color("4d4658"), Color("3e4a5e"), Color("5c4e50"), Color("3f5250"), Color("52506a"), Color("5e5648")]
const BODY_SKIP := 48                     # alt ve arka yüz çizilmez
const SLAB_SKIP := 16 | 32                # alt ve arka

## Uzak ağlar x bölgelerine ayrılır: kamera yalnız baktığı bölgeyi çizer (üçgen bütçesi).
class Chunks:
	var far := {}
	var glow := {}
	var mid := {}           # ışıklı, dış hatsız (ağaç, saksı, rögar)

	func key(x: float) -> int:
		return int(floor((x + 120.0) / 16.0))

	func f(x: float) -> Batch:
		var k := key(x)
		if not far.has(k):
			far[k] = Batch.new()
			glow[k] = Batch.new()
		return far[k]

	func g(x: float) -> Batch:
		f(x)
		return glow[key(x)]

	func m(x: float) -> Batch:
		var k := key(x)
		if not mid.has(k):
			mid[k] = Batch.new()
		return mid[k]


## xf: cephe tabanının ortası (yerel +z dışa bakar). w genişlik, h yükseklik, depth derinlik, y0: gövde tabanı.
static func _bldg(ch: Chunks, streak: Batch, xf: Transform3D, w: float, h: float, depth: float,
		col: Color, rng: RandomNumberGenerator, lit_p := 0.22, shop := true, reflect_z := 0.0, y0 := 0.0) -> void:
	var far := ch.f(xf.origin.x)
	var glow := ch.g(xf.origin.x)
	var gray := (col.r + col.g + col.b) / 3.0
	col = col.lerp(Color(gray, gray, gray), 0.3) * 0.72
	far.box(_at(xf, Vector3(0, (y0 + h) * 0.5, -depth * 0.5)), Vector3(w, h - y0, depth), col * 0.82, BODY_SKIP)
	var cols := maxi(2, int(floor((w - 1.0) / 2.7)))
	var x0 := -float(cols - 1) * 1.35
	var floors := int((h - 3.9) / 3.0)
	# Saçak ve çatı
	far.box(_at(xf, Vector3(0, h - 0.18, 0.28)), Vector3(w + 0.5, 0.42, 0.9), col * 1.22, 16 | 32)
	far.box(_at(xf, Vector3(0, h + 0.28, -0.15)), Vector3(w - 0.1, 0.5, 0.25), col * 0.7, SLAB_SKIP)
	# Zemin kat: dükkân kepenkleri, camekân, yazısız tabelalar
	if shop:
		var n := maxi(1, int(floor(w / 3.4)))
		var sw := w / float(n)
		for k in n:
			var cx := -w * 0.5 + sw * (float(k) + 0.5)
			var kind := rng.randi() % 3
			far.box(_at(xf, Vector3(cx, 3.55, 0.12)), Vector3(sw - 0.2, 0.55, 0.22), col * 0.62, SLAB_SKIP)
			if kind == 0:
				far.plate(_at(xf, Vector3(cx, 1.4, 0.14)), sw - 0.5, 2.7, Color("3b424c"))
				for g in 3:
					far.plate(_at(xf, Vector3(cx, 0.7 + g * 0.8, 0.15)), sw - 0.5, 0.06, Color("232830"))
			elif kind == 1:
				far.plate(_at(xf, Vector3(cx, 1.45, 0.13)), sw - 0.5, 2.5, Color("14161c"))
				glow.plate(_at(xf, Vector3(cx, 1.5, 0.15)), sw - 0.8, 1.6, Color(0.34, 0.27, 0.16))
			else:
				far.plate(_at(xf, Vector3(cx, 1.3, 0.14)), sw - 0.5, 2.5, Color("2e343c"))
				far.plate(_at(xf, Vector3(cx + sw * 0.18, 1.1, 0.16)), 0.9, 2.1, Color("1a1d24"))
			if rng.randf() < 0.55:
				var tc: Color = [Color(0.18, 0.5, 0.42), Color(0.55, 0.2, 0.18), Color(0.5, 0.42, 0.14), Color(0.2, 0.32, 0.6)][rng.randi() % 4]
				glow.plate(_at(xf, Vector3(cx, 3.55, 0.24)), sw - 0.7, 0.42, tc * 0.8)
			if rng.randf() < 0.4:
				far.box(_at(xf, Vector3(cx, 3.15, 0.5), Vector3(-14, 0, 0)), Vector3(sw - 0.3, 0.07, 1.1), col * 0.5, 32)
	# Üst katlar
	for fl in floors:
		var y := 3.9 + float(fl) * 3.0
		far.box(_at(xf, Vector3(0, y - 0.15, 0.1)), Vector3(w + 0.1, 0.2, 0.22), col * 1.18, SLAB_SKIP)
		for k in cols:
			var cx := x0 + float(k) * 2.7
			var lit := rng.randf() < lit_p
			var wx := _at(xf, Vector3(cx, y + 1.25, 0.0))
			if lit:
				var tint := rng.randf()
				var lc := Color(1.0, 0.86, 0.55) if tint < 0.55 else (Color(1.0, 0.7, 0.4) if tint < 0.85 else Color(0.62, 0.78, 1.0))
				glow.plate(_at(wx, Vector3(0, 0, 0.07)), 0.96, 1.36, lc * (0.7 + rng.randf() * 0.3))
				if rng.randf() < 0.5:
					far.plate(_at(wx, Vector3(-0.3, 0.05, 0.09)), 0.36, 1.3, col * 0.3)       # perde
				if reflect_z != 0.0:
					_streak(streak, xf, cx, y, reflect_z, lc)
			else:
				far.plate(_at(wx, Vector3(0, 0, 0.07)), 0.96, 1.36, Color("0b0d13"))
			far.plate(_at(wx, Vector3(0, 0, 0.1)), 0.05, 1.4, col * 0.9)
			if rng.randf() < 0.3:
				# balkon: plak, korkuluk
				far.box(_at(wx, Vector3(0, -0.9, 0.45)), Vector3(2.0, 0.14, 0.9), col * 1.25, 2 | 32)
				far.plate(_at(wx, Vector3(0, -0.5, 0.9)), 2.0, 0.8, col * 0.5)
				far.plate(_at(wx, Vector3(0, -0.05, 0.9)), 2.0, 0.07, col * 1.1)
	# Çatıda su deposu / baca
	if rng.randf() < 0.6:
		far.lathe(_at(xf, Vector3(w * 0.25, h + 0.5, -depth * 0.3)), [Vector2(0.0, 0.0), Vector2(0.9, 0.0), Vector2(0.95, 1.4),
			Vector2(0.0, 1.5)], col * 0.6, 8)
	far.box(_at(xf, Vector3(-w * 0.3, h + 1.0, -depth * 0.5)), Vector3(0.7, 1.6, 0.7), col * 0.65, SLAB_SKIP)


static func _streak(streak: Batch, xf: Transform3D, cx: float, y: float, z_to: float, lc: Color) -> void:
	# Pencerenin ıslak yoldaki yansıması: cephe dibinden kameraya doğru solan dikey çizgi
	var base := xf * Vector3(cx, 0.0, 0.2)
	var out := (xf.basis * Vector3(0, 0, 1)).normalized()
	var side := (xf.basis * Vector3(1, 0, 0)).normalized()
	var hw := 0.42
	var len := minf(absf(z_to), 3.0 + y * 0.9)
	var a0 := 0.34 * (1.0 - y / 36.0)
	var cc := Color(lc.r * a0, lc.g * a0, lc.b * a0, 1.0)
	var pa := base + Vector3(0, 0.07, 0) - side * hw
	var pb := base + Vector3(0, 0.07, 0) + side * hw
	streak.quadc([pa, pb, pb + out * len, pa + out * len], Vector3.UP, [cc, cc, Color(0, 0, 0, 1), Color(0, 0, 0, 1)])


static func _buildings(ch: Chunks, streak: Batch, rng: RandomNumberGenerator) -> void:
	var face_s := Basis(Vector3.RIGHT, Vector3.UP, Vector3.BACK)               # +z'ye bakar (garaj tarafı sırası)
	var face_n := Basis(Vector3.LEFT, Vector3.UP, Vector3.FORWARD)            # -z'ye bakar (karşı sıra)
	var face_e := Basis(Vector3.FORWARD, Vector3.UP, Vector3.RIGHT)           # +x'e bakar
	var face_w := Basis(Vector3.BACK, Vector3.UP, Vector3.LEFT)               # -x'e bakar
	# Garajın iki yanı (garaj duvarı z = 3.2; komşular ona yaslı)
	var south := [
		# [x orta, genişlik, yükseklik, ön z]
		[-11.2, 14.0, 13.0, 3.25], [-27.4, 18.0, 17.5, 3.9], [-46.0, 19.0, 11.0, 3.25],
		[10.0, 11.6, 12.5, 3.75], [26.0, 20.0, 16.0, 3.3], [46.0, 20.0, 21.0, 3.6],
	]
	var i := 0
	for b in south:
		var xf := Transform3D(face_s, Vector3(b[0], 0.0, b[3]))
		_bldg(ch, streak, xf, b[1], b[2], 14.0, FACADES[i % FACADES.size()], rng, 0.18, true, 0.0)
		i += 1
	# Garajın üstü: aynı apartmanın üst katları (garaj tavanı 3.4 m'de biter)
	_bldg(ch, streak, Transform3D(face_s, Vector3(0.0, 0.0, 3.25)), 8.4, 14.0, 12.0, FACADES[5], rng, 0.2, false, 0.0, 3.45)
	# Karşı sıra (aralarında dar aralıklar; kavşak x 31..43)
	var north := [
		[-50.0, 11.0, 18.0, 17.9], [-37.0, 14.0, 19.0, 17.5], [-20.0, 16.4, 24.0, 18.3], [-6.5, 10.4, 15.5, 17.4],
		[11.2, 15.8, 27.0, 18.6], [25.4, 11.4, 17.0, 17.7], [49.5, 12.0, 20.0, 17.6],
	]
	for b in north:
		var xf := Transform3D(face_n, Vector3(b[0], 0.0, b[3]))
		var depth := 45.0 if (b[0] > 20.0) else 16.0
		_bldg(ch, streak, xf, b[1], b[2], depth, FACADES[(i * 3) % FACADES.size()], rng, 0.24, true, -10.0)
		i += 1
	# Yol sonları: iki uçta yolu kapatan bina; kavşağın kuzey kolunun ucu
	_bldg(ch, streak, Transform3D(face_e, Vector3(-56.0, 0.0, 22.0)), 38.0, 23.0, 14.0, FACADES[1], rng, 0.2, false, 0.0)
	_bldg(ch, streak, Transform3D(face_w, Vector3(56.0, 0.0, 22.0)), 38.0, 19.0, 14.0, FACADES[4], rng, 0.2, false, 0.0)
	_bldg(ch, streak, Transform3D(face_n, Vector3(37.0, 0.0, 63.0)), 12.0, 21.0, 10.0, FACADES[2], rng, 0.25, false, 0.0)
	# Aralıkların arkasını kapatan koyu arka bina
	for gb in [[-29.1, 2.6], [1.0, 5.4], [19.4, 1.6]]:
		ch.f(gb[0]).box(Transform3D(Basis.IDENTITY, Vector3(gb[0], 9.0, 27.0)), Vector3(gb[1], 18.0, 1.0), FACADES[2] * 0.4, 16 | 4)


# ------------------------------------------------------------ gök silüeti

static func _skyline(ch: Chunks, rng: RandomNumberGenerator) -> void:
	var haze := Color(0.20, 0.145, 0.165)
	for tier in 2:
		var z := 40.0 + float(tier) * 52.0
		var x := -180.0
		while x < 180.0:
			var w := rng.randf_range(10.0, 24.0)
			var h := rng.randf_range(12.0, 26.0) + float(tier) * 12.0
			var c := Color(0.075, 0.08, 0.115).lerp(haze, 0.25 + float(tier) * 0.26) * (0.8 + rng.randf() * 0.3)
			var dz := z + rng.randf_range(-6.0, 6.0)
			if tier == 0 and x + w > 29.0 and x < 45.0:
				x += w + 1.0
				continue
			var far := ch.f(x + w * 0.5)
			var glow := ch.g(x + w * 0.5)
			far.box(Transform3D(Basis.IDENTITY, Vector3(x + w * 0.5, h * 0.5, dz)), Vector3(w, h, 14.0), c, 16 | 4)
			if tier < 2:
				for fl in int(h / 3.6):
					for cx in int(w / 3.4):
						if rng.randf() < 0.07:
							glow.plate(Transform3D(Basis(Vector3.LEFT, Vector3.UP, Vector3.FORWARD), Vector3(x + 1.7 + float(cx) * 3.4, 2.0 + float(fl) * 3.6, dz - 7.05)),
								1.0, 1.3, Color(1.0, 0.82, 0.5) * (0.35 + 0.15 * float(tier == 0)))
			x += w + rng.randf_range(0.0, 3.0)
	# Cami: kubbe, yarım kubbeler, iki minare (uzakta, silüet)
	var far := ch.f(-30.0)
	_mosque(far, Vector3(-30.0, 0.0, 60.0), 1.0)
	_minaret(far, Vector3(-16.0, 0.0, 56.0), 1.0)
	_mosque(ch.f(70.0), Vector3(70.0, 0.0, 96.0), 1.3)
	_minaret(ch.f(84.0), Vector3(84.0, 0.0, 74.0), 1.15)


static func _minaret(b: Batch, p: Vector3, s: float) -> void:
	var c := Color(0.085, 0.085, 0.12)
	var xf := Transform3D(Basis.IDENTITY.scaled(Vector3(s, s, s)), p)
	b.lathe(xf, [Vector2(0.0, 0.0), Vector2(1.4, 0.0), Vector2(1.1, 3.0), Vector2(0.9, 22.0), Vector2(1.7, 22.4),
		Vector2(1.7, 23.4), Vector2(0.75, 23.8), Vector2(0.65, 29.0), Vector2(0.9, 29.4), Vector2(0.0, 36.0)], c, 10)
	b.lathe(xf, [Vector2(0.0, 36.0), Vector2(0.06, 36.0), Vector2(0.06, 38.0), Vector2(0.0, 38.0)], c, 4)
	# Şerefe ışığı
	b.lathe(xf, [Vector2(1.72, 22.5), Vector2(1.72, 23.0)], Color(0.55, 0.42, 0.2), 10)


static func _mosque(b: Batch, p: Vector3, s: float) -> void:
	var c := Color(0.09, 0.09, 0.13)
	var xf := Transform3D(Basis.IDENTITY.scaled(Vector3(s, s, s)), p)
	b.box(_at(xf, Vector3(0, 7.0, 0)), Vector3(22.0, 14.0, 20.0), c * 0.9)
	b.lathe(_at(xf, Vector3(0, 14.0, 0)), [Vector2(0.0, 0.0), Vector2(7.2, 0.0), Vector2(7.0, 4.0), Vector2(0.0, 4.0)], c, 14)
	b.sup(_at(xf, Vector3(0, 18.0, 0)), Vector3(7.4, 7.0, 7.4), 1.0, 1.0, c, 14, 8)
	b.lathe(_at(xf, Vector3(0, 24.8, 0)), [Vector2(0.0, 0.0), Vector2(0.18, 0.0), Vector2(0.1, 2.4), Vector2(0.0, 2.6)], c, 5)
	for sx in [-1.0, 1.0]:
		b.sup(_at(xf, Vector3(sx * 8.4, 14.0, 0)), Vector3(4.2, 3.6, 4.2), 1.0, 1.0, c, 10, 6)
	for sx in [-1.0, 1.0]:
		_minaret(b, p + Vector3(sx * 13.0 * s, 0.0, 9.0 * s), s * 0.9)


# ------------------------------------------------------------ ağaçlar

static func _tree(b: Batch, p: Vector3, h: float, rng: RandomNumberGenerator) -> void:
	var bark := Color(0.12, 0.10, 0.10)
	var pts: Array = []
	var rs: Array = []
	var n := 4
	for i in n:
		var t := float(i) / float(n - 1)
		pts.append(p + Vector3(sin(t * 2.4) * 0.12, t * h * 0.6, cos(t * 2.0) * 0.08))
		rs.append(lerpf(0.16, 0.07, t))
	rs[n - 1] = 0.05
	b.tube(Transform3D.IDENTITY, pts, rs, bark, 5)
	var leaf := Color(0.17, 0.33, 0.29)
	var top := p + Vector3(0, h * 0.72, 0)
	for k in 4:
		var o := Vector3(rng.randf_range(-1.1, 1.1), rng.randf_range(-0.5, 0.9), rng.randf_range(-1.1, 1.1))
		var r := rng.randf_range(0.9, 1.4)
		b.ball(Transform3D(Basis.IDENTITY, top + o), Vector3(r, r * 0.85, r), leaf * (0.8 + rng.randf() * 0.5), 8, 4)


static func _trees(ch: Chunks, rng: RandomNumberGenerator) -> void:
	for tp in [Vector3(1.0, 0.0, 16.4), Vector3(-29.1, 0.0, 16.6), Vector3(-12.4, 0.0, 16.5), Vector3(19.4, 0.0, 16.5),
			Vector3(-42.0, 0.0, 15.8), Vector3(38.0, 0.0, 15.7)]:
		_tree(ch.m(tp.x), tp, rng.randf_range(4.2, 5.6), rng)


# ------------------------------------------------------------ sokak lambası

static func _lamp(near: Batch, glow: Batch, root: Node3D) -> void:
	var lp := Vector3(-3.4, 0.0, 5.0)
	var iron := Color("3a3f48")
	var xf := Transform3D(Basis.IDENTITY, lp)
	near.lathe(xf, [Vector2(0.0, 0.0), Vector2(0.17, 0.0), Vector2(0.16, 0.5), Vector2(0.1, 0.62), Vector2(0.075, 0.8),
		Vector2(0.055, 5.2), Vector2(0.0, 5.25)], iron, 10)
	var pts: Array = []
	var rs: Array = []
	for i in 7:
		var t := float(i) / 6.0
		pts.append(Vector3(0, 5.15 + sin(t * 1.4) * 0.35, -t * 1.0))
		rs.append(0.045)
	near.tube(xf, pts, rs, iron, 6)
	var hx := _at(xf, Vector3(0, 5.42, -1.05))
	near.sup(hx, Vector3(0.2, 0.075, 0.42), 0.6, 0.6, iron, 12, 6)
	glow.sup(_at(hx, Vector3(0, -0.055, 0)), Vector3(0.16, 0.025, 0.34), 1.0, 1.0, Color("ffb060"), 10, 4)


# ------------------------------------------------------------ park etmiş araçlar

static func _parked(ch: Chunks, rng: RandomNumberGenerator) -> void:
	var cols := [Color(0.20, 0.22, 0.30), Color(0.30, 0.28, 0.20), Color(0.22, 0.30, 0.26), Color(0.32, 0.22, 0.22), Color(0.26, 0.26, 0.30)]
	var spots := [
		[Vector3(-13.0, 0.0, 6.0), 0.0], [Vector3(14.0, 0.0, 6.0), 0.0],
		[Vector3(-8.0, 0.0, 14.1), 180.0], [Vector3(20.0, 0.0, 14.1), 180.0],
	]
	var i := 0
	for s in spots:
		var yaw: float = deg_to_rad(90.0 + s[1])
		var fb := ch.f((s[0] as Vector3).x)
		car(fb, fb, fb, Transform3D(Basis.from_euler(Vector3(0, yaw, 0)), s[0]), cols[i % cols.size()], false, true, 0)
		i += 1


# ------------------------------------------------------------ araba

## Tofaş Şahin (Fiat 131 gövdesi): yuvarlatılmış gövde, eğimli camlar, tekerlek davlumbazı, isteğe bağlı branda.
## xf: arabanın dünya dönüşümü (uzunluk z, ön +z). far_mode: uzak park (parlaklık için ışıksız malzeme).
static func car(b: Batch, tarp: Batch, glow: Batch, xf: Transform3D, body: Color, covered: bool, far_mode := false, lod := 2) -> void:
	var glass := Color(0.07, 0.09, 0.14)
	var dark := Color(0.06, 0.06, 0.07)
	var chrome := Color(0.42, 0.44, 0.48)
	if far_mode:
		glass = Color(0.05, 0.06, 0.09)
	# alt gövde
	var hi := lod >= 2
	b.sup(_at(xf, Vector3(0, 0.52, 0)), Vector3(0.83, 0.28, 2.15), 0.32, 0.26, body, 16 if hi else (12 if lod == 1 else 8), 8 if hi else 5)
	# cam kafes (arkası ve ön camı eğimli): enine kesitler
	var P: Array = []
	var n := 12 if hi else 7
	var ncol := 12 if hi else 7
	var z0 := -1.32
	var z1 := 0.95
	var yb := 0.70
	for i in n + 1:
		var z := lerpf(z0, z1, float(i) / float(n))
		var top: float
		if z < -0.95:
			top = lerpf(0.74, 1.38, smoothstep(-1.32, -0.95, z))
		elif z <= 0.22:
			top = 1.38
		else:
			top = lerpf(1.38, 0.76, smoothstep(0.22, 0.95, z))
		var hw := 0.70 - 0.06 * pow(absf((z + 0.2) / 1.1), 3.0)
		var ry := maxf((top - yb) * 0.5, 0.012)
		var cy := yb + ry
		var row := PackedVector3Array()
		for j in ncol:
			var th := TAU * float(j) / float(ncol)
			row.append(xf * Vector3(hw * _sp(cos(th), 0.42), cy + ry * _sp(sin(th), 0.55), z))
		P.append(row)
	var cab_fn := func(_i: int, j: int) -> Color:
		var th := TAU * float(j) / float(ncol)
		return body if sin(th) > 0.82 else glass
	b.grid(P, true, glass, Vector3.ZERO, cab_fn)
	# tamponlar, farlar, davlumbazlar, tekerlekler
	for sz in [-1.0, 1.0]:
		if lod >= 1:
			b.sup(_at(xf, Vector3(0, 0.36, sz * 2.19)), Vector3(0.84, 0.065, 0.1), 0.6, 0.5, chrome, 10, 4)
		for sx in [-1.0, 1.0]:
			if lod < 1:
				continue
			var hx := _at(xf, Vector3(sx * 0.55, 0.62, sz * 2.12))
			if sz > 0.0:
				b.ball(hx, Vector3(0.17, 0.11, 0.07), Color(0.82, 0.78, 0.62), 10, 5)
			elif not covered:
				b.ball(hx, Vector3(0.15, 0.08, 0.06), Color(0.55, 0.1, 0.08), 8, 4)
	for sx in [-1.0, 1.0]:
		for wz in [-1.38, 1.36]:
			var wx := _at(xf, Vector3(sx * 0.84, 0.31, wz), Vector3(0, 0, 90))
			b.lathe(wx, [Vector2(0.0, -0.12), Vector2(0.36, -0.12), Vector2(0.37, 0.0), Vector2(0.36, 0.12), Vector2(0.0, 0.12)],
				dark, 14 if hi else (8 if lod == 1 else 5))
			if hi:
				b.lathe(wx, [Vector2(0.0, -0.125), Vector2(0.2, -0.125), Vector2(0.0, -0.125)], chrome * 0.7, 8)
				# davlumbaz: tekerleği çevreleyen koyu yarım halka
				b.sup(_at(xf, Vector3(sx * 0.72, 0.38, wz)), Vector3(0.1, 0.4, 0.45), 0.55, 0.6, dark, 8, 4)
	if covered:
		_tarp(tarp, xf)


## Branda: arka yarıyı örter, ön tarafı açık bırakır; kenarları dalgalı sarkar, kıvrımlı kumaş.
static func _tarp(t: Batch, xf: Transform3D) -> void:
	var prof := [Vector2(-2.32, 0.76), Vector2(-2.05, 0.88), Vector2(-1.45, 0.92), Vector2(-1.1, 1.28), Vector2(-0.85, 1.47),
		Vector2(0.0, 1.49), Vector2(0.30, 1.40)]
	var nz := 16
	var nu := 15
	var P: Array = []
	for i in nz + 1:
		var tz := float(i) / float(nz)
		var z := lerpf(-2.32, 0.30, tz)
		var yt := 1.0
		for k in prof.size() - 1:
			var a: Vector2 = prof[k]
			var bb: Vector2 = prof[k + 1]
			if z >= a.x and z <= bb.x:
				yt = lerpf(a.y, bb.y, (z - a.x) / (bb.x - a.x))
		yt += 0.05 + 0.025 * sin(z * 7.0 + 1.0)
		var in_cab := z > -1.15
		var hwt := 0.58 if in_cab else 0.70
		var yh := 0.30 + 0.07 * sin(z * 6.0 + 1.0) + 0.04 * sin(z * 13.0)
		var ragged := 0.0
		if i == nz:
			ragged = 0.0
		var row := PackedVector3Array()
		for k in nu:
			var u := lerpf(-1.0, 1.0, float(k) / float(nu - 1))
			var au := absf(u)
			var d := clampf((au - 0.42) / 0.58, 0.0, 1.0)
			var x: float = signf(u) * (hwt * minf(au / 0.42, 1.0) + (0.93 - hwt) * (1.0 - pow(1.0 - d, 2.0)))
			var y: float = yt - (yt - yh) * pow(d, 1.25) - 0.04 * au * au
			x += 0.018 * sin(u * 9.0 + z * 3.3)
			y += 0.022 * sin(u * 7.0 - z * 4.1) * (1.0 - d * 0.5)
			var zz := z
			if i == nz:
				zz = z + 0.05 * sin(u * 6.0)
			row.append(xf * Vector3(x, y + ragged, zz))
		P.append(row)
	t.grid(P, false, Color(0.22, 0.27, 0.35), (xf.basis * Vector3.UP).normalized())


# ------------------------------------------------------------ kedi

## Oturan kedi: yuvarlak gövde, baş, üçgen kulaklar, kıvrık kuyruk, parlayan gözler. xf: kedinin tabanı; yüz +z'ye bakar.
static func cat(b: Batch, glow: Batch, xf: Transform3D) -> void:
	var fur := Color(0.17, 0.165, 0.17)
	var light := Color(0.27, 0.26, 0.26)
	b.ball(_at(xf, Vector3(0, 0.155, -0.03), Vector3(-14, 0, 0)), Vector3(0.095, 0.15, 0.105), fur, 10, 6)
	b.ball(_at(xf, Vector3(0, 0.12, 0.05)), Vector3(0.062, 0.1, 0.05), light, 6, 4)          # göğüs
	for sx in [-1.0, 1.0]:
		b.ball(_at(xf, Vector3(sx * 0.082, 0.075, -0.045)), Vector3(0.062, 0.075, 0.105), fur, 7, 4)   # but
		b.lathe(_at(xf, Vector3(sx * 0.037, 0.0, 0.085)), [Vector2(0.0, 0.0), Vector2(0.026, 0.0), Vector2(0.021, 0.04),
			Vector2(0.016, 0.17), Vector2(0.0, 0.18)], fur, 5)                                  # ön bacak
		b.ball(_at(xf, Vector3(sx * 0.037, 0.012, 0.108)), Vector3(0.03, 0.016, 0.034), light, 5, 3)    # pati
	b.ball(_at(xf, Vector3(0, 0.325, 0.04)), Vector3(0.082, 0.07, 0.072), fur, 10, 6)                    # baş
	b.ball(_at(xf, Vector3(0, 0.305, 0.105)), Vector3(0.034, 0.024, 0.03), light, 6, 4)                # burun/ağız
	b.ball(_at(xf, Vector3(0, 0.318, 0.132)), Vector3(0.009, 0.007, 0.007), Color(0.5, 0.28, 0.3), 5, 3)
	for sx in [-1.0, 1.0]:
		b.lathe(_at(xf, Vector3(sx * 0.052, 0.375, 0.03), Vector3(0, 0, -sx * 14.0)), [Vector2(0.0, 0.0), Vector2(0.034, 0.0),
			Vector2(0.02, 0.05), Vector2(0.0, 0.085)], fur, 3)
		glow.ball(_at(xf, Vector3(sx * 0.033, 0.335, 0.098)), Vector3(0.0125, 0.017, 0.007), Color(0.85, 0.9, 0.35), 8, 4)
	# kuyruk: gövdenin dibinden öne doğru kıvrılır
	var pts: Array = []
	var rs: Array = []
	for i in 7:
		var t := float(i) / 6.0
		var a := t * 2.5
		pts.append(Vector3(0.09 + sin(a) * 0.1, 0.02 + sin(t * 3.0) * 0.012, -0.12 + t * 0.2 - cos(a) * 0.04))
		rs.append(lerpf(0.026, 0.018, t))
	rs[6] = 0.004
	b.tube(xf, pts, rs, fur, 6)


# ------------------------------------------------------------ rögar kapağı, saksı

static func _manholes_pots(ch: Chunks) -> void:
	for mp in [Vector3(-6.2, 0.0, 9.4), Vector3(8.5, 0.0, 12.6)]:
		var xf := Transform3D(Basis.IDENTITY, mp)
		var near := ch.m(mp.x)
		near.lathe(xf, [Vector2(0.0, -0.02), Vector2(0.42, -0.02), Vector2(0.42, 0.012), Vector2(0.37, 0.012), Vector2(0.36, 0.0),
			Vector2(0.0, 0.0)], Color(0.15, 0.15, 0.17), 12)
		for g in 2:
			near.lathe(_at(xf, Vector3(0, 0.0, 0)), [Vector2(0.1 + g * 0.16, 0.0), Vector2(0.125 + g * 0.16, 0.016),
				Vector2(0.15 + g * 0.16, 0.0)], Color(0.1, 0.1, 0.12), 12)
	# Saksılar: karşı kaldırımda dükkân önleri
	for pp in [Vector3(-4.0, 0.0, 16.2), Vector3(-3.3, 0.0, 16.3), Vector3(8.0, 0.0, 16.4), Vector3(23.0, 0.0, 16.3), Vector3(-17.0, 0.0, 16.3)]:
		var xf := Transform3D(Basis.IDENTITY, pp + Vector3(0, 0.05, 0))
		var near := ch.m(pp.x)
		near.lathe(xf, [Vector2(0.0, 0.0), Vector2(0.17, 0.0), Vector2(0.22, 0.1), Vector2(0.27, 0.42), Vector2(0.29, 0.46),
			Vector2(0.24, 0.46), Vector2(0.0, 0.42)], Color(0.38, 0.22, 0.16), 8)
		for lf in 3:
			var a := TAU * float(lf) / 3.0
			near.ball(_at(xf, Vector3(cos(a) * 0.1, 0.62 + 0.06 * float(lf % 2), sin(a) * 0.1), Vector3(0, 0, 0)),
				Vector3(0.14, 0.2, 0.1), Color(0.1, 0.24, 0.16), 6, 3)


# ------------------------------------------------------------ su birikintileri

static func _puddles(pud: Batch, rng: RandomNumberGenerator) -> void:
	var spots := [Vector3(1.0, 0.0, 10.4), Vector3(-8.0, 0.0, 7.6), Vector3(6.5, 0.0, 12.3), Vector3(-15.0, 0.0, 9.8),
		Vector3(12.0, 0.0, 8.0), Vector3(-0.8, 0.0, 13.2), Vector3(20.0, 0.0, 11.0)]
	for p in spots:
		var s := Vector3(rng.randf_range(1.0, 1.9), 1.0, rng.randf_range(0.45, 0.8))
		var xf := Transform3D(Basis.IDENTITY.scaled(s), p + Vector3(0, -0.012, 0))
		pud.disc(xf, 1.0, Color(0.16, 0.19, 0.27, 0.55), 16)


# ------------------------------------------------------------ gök ve ışık hâleleri

static func _sky(root: Node3D) -> void:
	var sm := SphereMesh.new()
	sm.radius = 290.0
	sm.height = 580.0
	sm.radial_segments = 20
	sm.rings = 10
	var sh := Shader.new()
	sh.code = SKY_SHADER
	var m := ShaderMaterial.new()
	m.shader = sh
	var mi := MeshInstance3D.new()
	mi.mesh = sm
	mi.material_override = m
	mi.position = Vector3(0, 0, 10.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.custom_aabb = AABB(Vector3(-300, -300, -300), Vector3(600, 600, 600))
	root.add_child(mi)


static func _halos(root: Node3D) -> void:
	var tex := _glow_tex()
	var hm := StandardMaterial3D.new()
	hm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	hm.albedo_texture = tex
	hm.albedo_color = Color(1.0, 0.62, 0.3, 0.55)
	hm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	hm.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	var q := QuadMesh.new()
	q.size = Vector2(4.2, 4.2)
	var halo := MeshInstance3D.new()
	halo.mesh = q
	halo.material_override = hm
	halo.position = Vector3(-3.4, 5.35, 4.05)
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(halo)
	# Yerdeki ışık havuzu
	var pm := StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	pm.albedo_texture = tex
	pm.albedo_color = Color(1.0, 0.55, 0.22, 0.32)
	pm.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	var pq := QuadMesh.new()
	pq.size = Vector2(11.0, 8.0)
	pq.orientation = PlaneMesh.FACE_Y
	var pool := MeshInstance3D.new()
	pool.mesh = pq
	pool.material_override = pm
	pool.position = Vector3(-3.4, 0.075, 6.6)
	pool.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(pool)


## Sokaktan geçen araba (Garage._drive_car oynatır): yuvarlatılmış gövde ve eğimli camlar; farlar Garage'ta.
static func passing_car(parent: Node3D) -> void:
	var b := Batch.new()
	var xf := Transform3D(Basis.from_euler(Vector3(0, PI / 2.0, 0)).scaled(Vector3(0.93, 0.93, 0.93)), Vector3.ZERO)
	car(b, b, b, xf, Color("2a2e36"), false, false, 1)
	b.commit(parent, _mat_lit(true))
