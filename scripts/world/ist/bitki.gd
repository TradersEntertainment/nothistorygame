class_name IstBitki
extends RefCounted
## İstanbul, Nisan 1453: bitki örtüsü kiti (tek ağaç/öğe). Alan doldurma: IstBitkiYama.
## Bitkiler GERÇEK boyda kurulur (k yalnız kütleyi ölçekler; ağaçta k kullanılmaz).
## Gövde katı, taç ve çalı çarpışmasız. Hepsi tek köşe-renkli ağ (düşük poligon, çizgi film).
## Oyuncu: zıplama 3,6²/(2·9,8) ≈ 0,66 m, basamak 0,42 m (player.gd JUMP, STEP_H).

static var _cache := {}
static var _mat_cache: StandardMaterial3D

# ------------------------------------------------------------------ türler
## Ağaç tanımı: gövde yüksekliği/yarıçapı/rengi + taçlar [merkez(y gövde tepesinden), yarıçap xyz, renk1, renk2]
const AGAC := {
	"erguvan": {"ad": "Erguvan", "th": 2.0, "tr": 0.16, "tc": Color("4a3428"), "boy": 5.0,
		"cicek": Color("b02c80"), "cicek2": Color("d85aa8"),
		"taclar": [[Vector3(0, 1.2, 0), Vector3(2.0, 1.4, 2.0), Color("8c3a74"), Color("b05c98")],
			[Vector3(1.1, 0.5, 0.4), Vector3(1.3, 1.0, 1.3), Color("843068"), Color("a85490")],
			[Vector3(-1.0, 0.7, -0.5), Vector3(1.4, 1.0, 1.3), Color("943e7c"), Color("b86ca0")]]},
	"badem": {"ad": "Badem (çiçekte)", "th": 1.8, "tr": 0.15, "tc": Color("4e3a2c"), "boy": 4.6,
		"cicek": Color("fbe6ec"), "cicek2": Color("f4b8c8"),
		"taclar": [[Vector3(0, 1.1, 0), Vector3(1.7, 1.3, 1.7), Color("f4d4de"), Color("fff0f4")],
			[Vector3(0.9, 0.4, -0.4), Vector3(1.1, 0.9, 1.1), Color("eec4d2"), Color("fce4ec")]]},
	"kiraz": {"ad": "Kiraz (çiçekte)", "th": 2.2, "tr": 0.18, "tc": Color("5a3e30"), "boy": 6.0,
		"cicek": Color("fffafa"), "cicek2": Color("f8d8e0"),
		"taclar": [[Vector3(0, 1.6, 0), Vector3(2.2, 1.8, 2.2), Color("f6e4ea"), Color("ffffff")],
			[Vector3(-1.2, 0.6, 0.6), Vector3(1.3, 1.1, 1.3), Color("f0dae2"), Color("fdf0f4")]]},
	"cinar": {"ad": "Çınar", "th": 7.0, "tr": 0.7, "tc": Color("8a7e6a"), "boy": 17.0,
		"cicek": Color("a8d060"), "cicek2": Color("86b848"),
		"taclar": [[Vector3(0, 4.5, 0), Vector3(6.0, 4.2, 6.0), Color("6a9a34"), Color("a4cc58")],
			[Vector3(3.6, 1.8, 1.0), Vector3(3.2, 2.4, 3.2), Color("5e8e30"), Color("98c050")],
			[Vector3(-3.4, 2.4, -1.4), Vector3(3.4, 2.6, 3.4), Color("689836"), Color("a0c858")]]},
	"servi": {"ad": "Servi", "th": 0.8, "tr": 0.14, "tc": Color("3a2c22"), "boy": 11.0, "konik": true,
		"taclar": [[Vector3(0, 4.6, 0), Vector3(1.1, 5.0, 1.1), Color("1e3a24"), Color("2e5434")]]},
	"incir": {"ad": "İncir (yeni sürgün)", "th": 1.2, "tr": 0.2, "tc": Color("8a7a68"), "boy": 5.0,
		"cicek": Color("a8d058"), "cicek2": Color("c8e078"),
		"taclar": [[Vector3(0, 1.4, 0), Vector3(2.6, 1.5, 2.6), Color("8cb448"), Color("b8d870")],
			[Vector3(1.6, 0.6, 0.8), Vector3(1.6, 1.0, 1.6), Color("80a840"), Color("acd068")]]},
	"defne": {"ad": "Defne", "th": 0.6, "tr": 0.1, "tc": Color("4a3a2c"), "boy": 4.0,
		"taclar": [[Vector3(0, 1.4, 0), Vector3(1.7, 1.9, 1.7), Color("2c5a2c"), Color("48803c")]]},
	"nar": {"ad": "Nar (yeni yaprak)", "th": 0.7, "tr": 0.1, "tc": Color("6a4e3a"), "boy": 3.2,
		"cicek": Color("d83a28"), "cicek2": Color("f08850"),
		"taclar": [[Vector3(0, 1.0, 0), Vector3(1.3, 1.2, 1.3), Color("78a838"), Color("a0c850")]]},
	"zeytin": {"ad": "Zeytin", "th": 1.5, "tr": 0.28, "tc": Color("6e6252"), "boy": 5.0,
		"taclar": [[Vector3(0, 1.4, 0), Vector3(2.4, 1.3, 2.4), Color("7c8c62"), Color("a8b488")],
			[Vector3(1.3, 0.6, 0.5), Vector3(1.5, 0.9, 1.5), Color("74845a"), Color("9cac80")]]},
	"dut": {"ad": "Dut", "th": 2.0, "tr": 0.24, "tc": Color("66503c"), "boy": 6.2,
		"cicek": Color("8ec050"), "cicek2": Color("b0d468"),
		"taclar": [[Vector3(0, 1.8, 0), Vector3(2.5, 2.0, 2.5), Color("78a840"), Color("a4cc60")],
			[Vector3(-1.4, 0.8, 0.8), Vector3(1.5, 1.2, 1.5), Color("6c9c38"), Color("98c458")]]},
}

# ------------------------------------------------------------------ kayıt
static func _kayit(id: String, ad: String, olcu: Vector3, durum := "saglam") -> Dictionary:
	return {"id": id, "ad": ad, "dogu_m": 0.0, "kuzey_m": 0.0, "gercek_olcu": olcu, "yon_derece": 0.0,
		"durum": durum, "tur": "bitki"}


## Kayıt: konum alanları 0; şehir kurucusu yerleştirir. Alan doldurucular "yama": true taşır.
static func catalog() -> Array:
	var out: Array = []
	for id: String in AGAC.keys():
		var d: Dictionary = AGAC[id]
		var r := 1.0
		for t: Array in d["taclar"]:
			r = maxf(r, maxf((t[1] as Vector3).x, absf((t[0] as Vector3).x) + (t[1] as Vector3).x * 0.6))
		out.append(_kayit(id, d["ad"], Vector3(r * 2.0, d["boy"], r * 2.0), "bahar"))
	out.append_array(IstBitkiYama.catalog())
	return out


# ------------------------------------------------------------------ malzeme ve ağ yardımcıları
static func mat() -> StandardMaterial3D:
	if _mat_cache == null:
		var m := StandardMaterial3D.new()
		m.vertex_color_use_as_albedo = true
		m.vertex_color_is_srgb = true
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		m.roughness = 1.0
		m.albedo_color = Color(0.8, 0.8, 0.78)
		_mat_cache = m
	return _mat_cache


static func new_mesh_data() -> Dictionary:
	return {"v": PackedVector3Array(), "n": PackedVector3Array(), "c": PackedColorArray()}


static func tri(m: Dictionary, a: Vector3, b: Vector3, c: Vector3, ca: Color, cb: Color, cc: Color, hint: Vector3) -> void:
	var n := (c - a).cross(b - a)
	if n.length_squared() < 1e-10:
		return
	n = n.normalized()
	if n.dot((a + b + c) / 3.0 - hint) < 0.0:
		n = -n
	var pv: PackedVector3Array = m["v"]
	var pn: PackedVector3Array = m["n"]
	var pc: PackedColorArray = m["c"]
	pv.append(a)
	pv.append(b)
	pv.append(c)
	pn.append(n)
	pn.append(n)
	pn.append(n)
	pc.append(ca)
	pc.append(cb)
	pc.append(cc)
	m["v"] = pv
	m["n"] = pn
	m["c"] = pc


static func quad(m: Dictionary, a: Vector3, b: Vector3, c: Vector3, d: Vector3, col: Color, hint: Vector3) -> void:
	tri(m, a, b, c, col, col, col, hint)
	tri(m, a, c, d, col, col, col, hint)


static func finish(m: Dictionary) -> ArrayMesh:
	var am := ArrayMesh.new()
	if (m["v"] as PackedVector3Array).is_empty():
		return am
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = m["v"]
	arr[Mesh.ARRAY_NORMAL] = m["n"]
	arr[Mesh.ARRAY_COLOR] = m["c"]
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	am.surface_set_material(0, mat())
	return am


static func hash_f(x: float, y: float, z: float, s: int) -> float:
	return fposmod(sin(x * 12.9898 + y * 78.233 + z * 37.719 + float(s) * 4.1414) * 43758.5453, 1.0)


## Kabaca küre (köşeleri itilmiş, yüzleri düz gölgeli); tepe açık, alt koyu. flat: y'de basıklık için alt kesme.
static func add_blob(m: Dictionary, c: Vector3, rad: Vector3, seed: int, c1: Color, c2: Color, seg := 8, rings := 5, bottom_dark := 0.7, jitter := 0.22) -> void:
	var pts: Array = []
	for j in rings + 1:
		var row: Array = []
		var phi := PI * float(j) / rings
		for i in seg:
			var th := TAU * float(i) / seg
			var u := Vector3(sin(phi) * cos(th), cos(phi), sin(phi) * sin(th))
			if j == 0 or j == rings:
				u = Vector3(0, cos(phi), 0)
			var k := 1.0 + (hash_f(u.x * 5.0, u.y * 5.0, u.z * 5.0, seed) - 0.5) * 2.0 * jitter
			if j > 0 and j < rings:
				k = 1.0 + (hash_f(float(i), float(j), 1.0, seed) - 0.5) * 2.0 * jitter
			row.append(c + Vector3(u.x * rad.x, u.y * rad.y, u.z * rad.z) * k)
		pts.append(row)
	for j in rings:
		for i in seg:
			var i2 := (i + 1) % seg
			var a: Vector3 = pts[j][i]
			var b: Vector3 = pts[j][i2]
			var cc: Vector3 = pts[j + 1][i]
			var d: Vector3 = pts[j + 1][i2]
			var h := float(j) / rings
			var t := hash_f(float(i), float(j), 2.0, seed)
			var col := c1.lerp(c2, clampf((1.0 - h) * 0.8 + (t - 0.5) * 0.7, 0.0, 1.0))
			if h > 0.6:
				col = col.darkened((h - 0.6) * (1.0 - bottom_dark) * 2.0)
			var t2 := hash_f(float(i), float(j), 3.0, seed)
			var col2 := c1.lerp(c2, clampf((1.0 - h) * 0.8 + (t2 - 0.5) * 0.7, 0.0, 1.0))
			if j == 0:
				tri(m, a, cc, d, col, col, col, c)
			elif j == rings - 1:
				tri(m, a, cc, b, col, col, col, c)
			else:
				tri(m, a, cc, d, col, col, col, c)
				tri(m, a, d, b, col2, col2, col2, c)


## Kesik koni (taban b, tepe b + (0,h,0)); kapak: üst kapalı.
static func add_frustum(m: Dictionary, b: Vector3, r0: float, r1: float, h: float, seg: int, c0: Color, c1: Color, lean := Vector3.ZERO, cap := true) -> void:
	var axis := b + Vector3(0, h * 0.5, 0) + lean * 0.5
	for i in seg:
		var a0 := TAU * float(i) / seg
		var a1 := TAU * float(i + 1) / seg
		var p0 := b + Vector3(cos(a0) * r0, 0, sin(a0) * r0)
		var p1 := b + Vector3(cos(a1) * r0, 0, sin(a1) * r0)
		var q0 := b + lean + Vector3(cos(a0) * r1, h, sin(a0) * r1)
		var q1 := b + lean + Vector3(cos(a1) * r1, h, sin(a1) * r1)
		quad(m, p0, p1, q1, q0, c0.lerp(c1, 0.5 + 0.2 * sin(a0 * 3.0)), axis)
		if cap and r1 > 0.0:
			tri(m, q0, q1, b + lean + Vector3(0, h, 0), c1, c1, c1, axis)


static func add_box(m: Dictionary, c: Vector3, s: Vector3, col: Color, top_col := Color(0, 0, 0, 0)) -> void:
	var h := s * 0.5
	var tc: Color = col if top_col.a == 0.0 else top_col
	var v := [Vector3(-h.x, -h.y, -h.z), Vector3(h.x, -h.y, -h.z), Vector3(h.x, -h.y, h.z), Vector3(-h.x, -h.y, h.z),
		Vector3(-h.x, h.y, -h.z), Vector3(h.x, h.y, -h.z), Vector3(h.x, h.y, h.z), Vector3(-h.x, h.y, h.z)]
	for i in 8:
		v[i] += c
	quad(m, v[4], v[5], v[6], v[7], tc, c)
	quad(m, v[0], v[1], v[5], v[4], col.darkened(0.08), c)
	quad(m, v[1], v[2], v[6], v[5], col.darkened(0.14), c)
	quad(m, v[2], v[3], v[7], v[6], col.darkened(0.08), c)
	quad(m, v[3], v[0], v[4], v[7], col.darkened(0.14), c)
	quad(m, v[0], v[1], v[2], v[3], col.darkened(0.3), c)


## Yaprak/çiçek benekleri: tepe küre yüzeyine dağılmış küçük renkli dörtgenler.
static func add_flecks(m: Dictionary, c: Vector3, rad: Vector3, n: int, size: float, col1: Color, col2: Color, seed: int) -> void:
	for i in n:
		var u := Vector3(hash_f(float(i), 1.0, 0.0, seed) - 0.5, hash_f(float(i), 2.0, 0.0, seed) - 0.15, hash_f(float(i), 3.0, 0.0, seed) - 0.5)
		if u.length() < 0.05:
			continue
		u = u.normalized()
		var p := c + Vector3(u.x * rad.x, u.y * rad.y, u.z * rad.z) * 1.2
		var t := u.cross(Vector3.UP)
		if t.length() < 0.1:
			t = Vector3.RIGHT
		t = t.normalized() * size
		var b := u.cross(t).normalized() * size
		var col := col1.lerp(col2, hash_f(float(i), 4.0, 0.0, seed))
		quad(m, p - t - b, p + t - b, p + t + b, p - t + b, col, c)


# ------------------------------------------------------------------ ağaç ağı
static func tree_mesh(tur: String, lod: int) -> ArrayMesh:
	var key := "agac|%s|%d" % [tur, lod]
	if _cache.has(key):
		return _cache[key]
	var d: Dictionary = AGAC[tur]
	var m := new_mesh_data()
	var th: float = d["th"]
	var tr: float = d["tr"]
	var tc: Color = d["tc"]
	var seed := tur.hash() & 0xffff
	if lod >= 2:
		add_frustum(m, Vector3.ZERO, tr * 1.2, tr * 0.8, th, 4, tc, tc, Vector3.ZERO, true)
		for t: Array in d["taclar"]:
			add_blob(m, Vector3(0, th, 0) + (t[0] as Vector3), t[1], seed, t[2], t[3], 5, 3, 0.7, 0.1)
		var am2 := finish(m)
		_cache[key] = am2
		return am2
	# gövde: kök tabanı geniş, yukarı daralır + iki üç ana dal
	add_frustum(m, Vector3.ZERO, tr * 1.5, tr, th * 0.35, 7, tc.darkened(0.15), tc, Vector3.ZERO, false)
	add_frustum(m, Vector3(0, th * 0.35, 0), tr, tr * 0.8, th * 0.65, 7, tc, tc.lightened(0.08), Vector3(tr * 0.3, 0, 0), true)
	if lod == 0 and not d.get("konik", false):
		for i in 3:
			var a := TAU * float(i) / 3.0 + 0.4
			var dir := Vector3(cos(a), 0, sin(a))
			add_frustum(m, Vector3(0, th * 0.8, 0), tr * 0.5, tr * 0.25, th * 0.5 + 0.5, 5, tc, tc.lightened(0.1), dir * (th * 0.35 + 0.4), true)
	var seg := 8 if lod == 0 else 6
	var rings := 5 if lod == 0 else 4
	var ti := 0
	for t: Array in d["taclar"]:
		var c := Vector3(0, th, 0) + (t[0] as Vector3)
		var rad: Vector3 = t[1]
		if d.get("konik", false):
			add_frustum(m, Vector3(0, th, 0), rad.x * 1.1, 0.02, rad.y * 2.0, seg, t[2], t[3], Vector3.ZERO, false)
			# dilimli sırt: açık-koyu şeritler
			for i in 4:
				var h := 0.6 + float(i) * 1.1
				add_blob(m, Vector3(rad.x * 0.1 * (i % 2), th + h, 0), Vector3(rad.x * (1.0 - h / (rad.y * 2.0) * 0.9) * 1.0, 0.9, rad.x * (1.0 - h / (rad.y * 2.0) * 0.9)), seed + i, t[2], t[3], 7, 3, 0.9, 0.12)
		else:
			add_blob(m, c, rad, seed + ti, t[2], t[3], seg, rings, 0.62, 0.2)
			if lod == 0 and d.has("cicek"):
				var n := int(rad.x * rad.y * 5.0)
				add_flecks(m, c, rad, mini(n, 34), 0.17 + rad.x * 0.03, d["cicek"], d["cicek2"], seed + 7 + ti)
		ti += 1
	var am := finish(m)
	_cache[key] = am
	return am


## Tek ağaç: gövde katı (silindir), taç çarpışmasız. Ağaç, gövde tepesinde konma noktası için küçük kapak taşır.
static func _agac(host: Node3D, tur: String, k: float, lod: int) -> void:
	var d: Dictionary = AGAC[tur]
	var root := Node3D.new()
	root.name = "bitki_" + tur
	host.add_child(root)
	var mi := MeshInstance3D.new()
	mi.mesh = tree_mesh(tur, lod)
	mi.name = "govde_tac"
	root.add_child(mi)
	if lod <= 1:
		var body := StaticBody3D.new()
		body.name = "govde_katı"
		var cs := CollisionShape3D.new()
		var cy := CylinderShape3D.new()
		cy.radius = maxf(0.2, float(d["tr"]) * 1.2)
		cy.height = float(d["th"])
		cs.shape = cy
		cs.position = Vector3(0, cy.height * 0.5, 0)
		body.add_child(cs)
		root.add_child(body)


static func build_erguvan(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _agac(host, "erguvan", k, lod)
static func build_badem(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _agac(host, "badem", k, lod)
static func build_kiraz(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _agac(host, "kiraz", k, lod)
static func build_cinar(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _agac(host, "cinar", k, lod)
static func build_servi(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _agac(host, "servi", k, lod)
static func build_incir(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _agac(host, "incir", k, lod)
static func build_defne(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _agac(host, "defne", k, lod)
static func build_nar(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _agac(host, "nar", k, lod)
static func build_zeytin(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _agac(host, "zeytin", k, lod)
static func build_dut(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _agac(host, "dut", k, lod)


## Konma noktaları: gövde tepesi (çarpışma gövdenin tepesinde biter). k'den bağımsız (gerçek boy).
static func perches_agac(tur: String, k: float = 0.5) -> Array:
	var d: Dictionary = AGAC[tur]
	return [Vector3(0, d["th"], 0)]


static func perches_bitki(k: float = 0.5) -> Array:
	var out: Array = []
	for tur: String in AGAC.keys():
		out.append_array(perches_agac(tur, k))
	return out


static func climbs_bitki(k: float = 0.5) -> Array:
	return IstBitkiYama.climbs_bahce_duvari(k)
