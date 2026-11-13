extends RefCounted
## OTURTMA: sur dibi temas kuşağı (surlar.gd _run çağırır; dilim yerel çerçevesi: x sur boyunca, +z dışarı, y 0 = dilim
## tabanı, dış bölge y = dy). Kutu / piramit YOK (kalite notu 32).
##  - etek: her duvar yüzünün ve her kule kaidesinin dibinde 3–6 m'lik yığılmış toprak / moloz eteği (0,3–0,8 m, düzensiz;
##    iç ucu duvarın içinden çıkar, dış ucu arazinin 3 cm altına iner: dikiş yok). Köşe rengi: duvar dibinde koyu temas
##    gölgesi (sahte AO), taş tozu, çıplak toprak; uçta arazinin kendi köşe rengi (aynı 6 m ızgaradan, aynı malzeme).
##  - dip bandı: duvarın alt 1,5 m'si toprak sıçraması, nem ve yosunla koyulaşır (yukarı doğru seyrelen benekli geçiş).
##  - sur dibi bitkisi ve döküntü: ot öbeği (ince yapraklı tutam), düşmüş taş (düzensiz kaya), çalı (düzensiz yuvarlak öbek),
##    çamur lekesi (etek köşe renginde).

const OTURTMA := preload("res://scripts/world/ist/sur_oturtma.gd")
const KULE := preload("res://scripts/world/ist/sur_kule.gd")

static var _ot: ArrayMesh
static var _cali: ArrayMesh
static var _bant_mat: ShaderMaterial
static var _ot_mat: StandardMaterial3D
static var _tas_mat: StandardMaterial3D
static var _etek_mat: ShaderMaterial


## Arazinin malzemesi (aynı palet / desen) ama kıyı bandı kapalı: etek ağı dilimin yerel uzayında (y ≈ 0), gölgelendirici
## onu deniz kıyısı sanıp ıslak/köpüklü boyuyordu
static func etek_malzeme() -> ShaderMaterial:
	if _etek_mat == null:
		_etek_mat = (load("res://scripts/level/zemin.gd").v2_malzeme() as ShaderMaterial).duplicate()
		_etek_mat.set_shader_parameter("su_y", -10000.0)
		# yerel uzaydaki aşınma maskesi ve kıyı ipucu etekte anlamsız (dilim yerel y ≈ 0): kapalı
		_etek_mat.set_shader_parameter("asinma_acik", 0.0)
	return _etek_mat
static var sayac := {"etek": 0, "ucgen": 0}


static func _h(a: int, b: int) -> float:
	var h := (a * 73856093) ^ (b * 19349663)
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return float(h & 0xffff) / 65535.0


## Arazinin LOD 0 ağındaki köşe rengi (aynı 6 m ızgara, aynı üçgen bölümü, aynı ışık düzeltmesi): etek ucu araziyle dikişsiz
static func arazi_renk(x: float, z: float) -> Color:
	var cell := 6.0
	var i := floori(x / cell)
	var j := floori(z / cell)
	var fx := x / cell - i
	var fz := z / cell - j
	var c00 := _kose(i * cell, j * cell)
	var c10 := _kose((i + 1) * cell, j * cell)
	var c01 := _kose(i * cell, (j + 1) * cell)
	var c11 := _kose((i + 1) * cell, (j + 1) * cell)
	# üçgenler: (a, a+1, a+W) ve (a+1, a+W+1, a+W): köşegen (i+1, j) – (i, j+1)
	if fx + fz <= 1.0:
		return c00 + (c10 - c00) * fx + (c01 - c00) * fz
	return c11 + (c01 - c11) * (1.0 - fx) + (c10 - c11) * (1.0 - fz)


static func _kose(x: float, z: float) -> Color:
	var kr: Array = OTURTMA.renk(x, z)
	var c: Color = kr[0] if float(kr[1]) > 0.0 else OTURTMA.R_TOPRAK
	# TUR-6: etek çıplak toprak (köşe alfası = çıplaklık; arazinin aynı ipucu)
	var cp := float(kr[2]) if kr.size() > 2 and float(kr[1]) > 0.0 else 0.9
	return Color.from_hsv(c.h, clampf(c.s * 1.25, 0.0, 1.0), c.v * 0.8, 1.0 - maxf(cp, 0.8))


static func _isik(c: Color) -> Color:
	return Color.from_hsv(c.h, clampf(c.s * 1.25, 0.0, 1.0), c.v * 0.8)


## Bir yüz çizgisi: yerel (x0..x1) boyunca z = zf, etek s yönünde (+1 / −1) uzar; y taban; en: [en_min, en_max];
## kes: atlanacak x aralıkları
static func yuz(e: Dictionary, x0: float, x1: float, zf: float, s: float, y: float, en_min: float, en_max: float, kes: Array) -> void:
	var lod: int = e["lod"]
	var adim := 1.5 if lod == 0 else 6.0
	var n := maxi(1, int(ceil((x1 - x0) / adim)))
	var row_prev: Array = []
	var prev_ok := false
	for i in n + 1:
		var x := lerpf(x0, x1, float(i) / n)
		var ok := true
		for k: Array in kes:
			if x > float(k[0]) - 0.6 and x < float(k[1]) + 0.6:
				ok = false
		var row: Array = []
		if ok:
			var tohum: int = e["tohum"]
			var hx := _h(tohum + roundi(x * 3.0), roundi(zf * 7.0))
			var hx2 := _h(tohum * 3 + roundi(x * 1.7), 11)
			var W := lerpf(en_min, en_max, 0.5 + 0.5 * sin(x * 0.37 + tohum) * 0.6 + (hx - 0.5) * 0.5)
			W = clampf(W, en_min, en_max)
			var h0 := 0.3 + 0.5 * clampf(0.5 + 0.5 * sin(x * 0.21 + tohum * 1.3) + (hx2 - 0.5) * 0.6, 0.0, 1.0)
			for cc: float in [-0.35, 0.0, 0.35, 0.8, W * 0.45, W * 0.7, W]:
				var t := clampf(cc / W, 0.0, 1.0)
				var yy := h0 + 0.05 if cc < 0.0 else h0 * pow(1.0 - t, 1.6) * (1.0 + (_h(roundi(x * 5.0), roundi(cc * 9.0)) - 0.5) * 0.3)
				if cc >= W:
					yy = -0.03
				row.append([cc, yy])
		if ok and prev_ok and IstSurlar._ic((float(e["_px"]) + x) * 0.5):
			_serit(e, row_prev, row, float(e["_px"]), x, zf, s, y)
		row_prev = row
		prev_ok = ok
		e["_px"] = x


## Etek şeridi: iki kesit arası (yerel)
static func _serit(e: Dictionary, ra: Array, rb: Array, xa: float, xb: float, zf: float, s: float, y: float) -> void:
	var pts: Array = []
	for r: Array in [ra, rb]:
		var xx := xa if r == ra else xb
		var row: Array = []
		for p: Array in r:
			row.append(Vector3(xx, y + float(p[1]), zf + s * float(p[0])))
		pts.append(row)
	_doldur(e, pts, s)


## İki kesit satırını (aynı sayıda nokta) üçgenler; köşe rengi duvardan uzaklığa göre
static func _doldur(e: Dictionary, pts: Array, s: float) -> void:
	var st: SurfaceTool = e["st"]
	var xf: Transform3D = e["xf"]
	var dunya: bool = e["dunya"]
	var ra: Array = pts[0]
	var rb: Array = pts[1]
	var m := ra.size()
	var cols: Array = []
	for r: Array in [ra, rb]:
		var cr: Array = []
		var w0: Vector3 = r[0]
		for k in m:
			var v: Vector3 = r[k]
			var dd := Vector2(v.x - w0.x, v.z - w0.z).length() - 0.35
			var wv := xf * v
			var hz := _h(roundi(wv.x * 2.0), roundi(wv.z * 2.0))
			var col: Color
			if k == m - 1:
				col = arazi_renk(wv.x, wv.z) if dunya else _isik(OTURTMA.R_TOPRAK)
			else:
				var toz := OTURTMA.R_TOZ.lerp(OTURTMA.R_TOPRAK, hz * 0.7)
				if hz > 0.78:
					toz = toz.lerp(OTURTMA.R_KOYU, 0.6)          # çamur lekesi
				col = _isik(toz)
				var uc := arazi_renk(wv.x, wv.z) if dunya else _isik(OTURTMA.R_TOPRAK)
				col = col.lerp(uc, clampf((dd - 0.6) / 2.4, 0.0, 1.0))
				# sahte AO: duvarın dibinde koyu temas gölgesi
				var ao := lerpf(0.5, 1.0, smoothstep(0.0, 1.4, dd))
				col = Color(col.r * ao, col.g * ao, col.b * ao)
			cr.append(col)
		cols.append(cr)
	for k in m - 1:
		var a: Vector3 = ra[k]
		var b: Vector3 = ra[k + 1]
		var c: Vector3 = rb[k]
		var d: Vector3 = rb[k + 1]
		_tri(st, a, b, c, cols[0][k], cols[0][k + 1], cols[1][k])
		_tri(st, b, d, c, cols[0][k + 1], cols[1][k + 1], cols[1][k])
		e["n"] = int(e["n"]) + 2
	# saçılan döküntü ve bitki (yalnız yakın)
	if int(e["lod"]) == 0:
		var x := (ra[0] as Vector3).x
		var tohum: int = e["tohum"]
		for q in 3:
			var hz := _h(tohum + roundi(x * 7.0), q * 17 + roundi((ra[0] as Vector3).z * 3.0))
			var hz2 := _h(tohum * 5 + roundi(x * 3.0), q * 31 + 7)
			var k := clampi(1 + int(hz2 * (m - 3)), 1, m - 2)
			var p := (ra[k] as Vector3).lerp(rb[k], hz)
			var tt := (hz * 7.0) - floorf(hz * 7.0)
			if q == 0 and hz2 < 0.55:
				(e["ot"] as Array).append(Transform3D(Basis(Vector3.UP, hz * TAU).scaled(Vector3.ONE * (0.6 + 0.7 * tt)), p - Vector3(0, 0.05, 0)))
			elif q == 1 and hz2 < 0.3:
				var sc := 0.25 + 0.45 * tt
				(e["tas"] as Array).append(Transform3D(Basis.from_euler(Vector3(hz * 3.0, hz2 * 6.0, tt)).scaled(Vector3(sc * 1.3, sc * 0.65, sc)), p + Vector3(0, sc * 0.12, 0)))
			elif q == 2 and hz2 < 0.12:
				var sc2 := 0.7 + 0.8 * tt
				(e["cali"] as Array).append(Transform3D(Basis(Vector3.UP, hz2 * TAU).scaled(Vector3(sc2, sc2 * (0.7 + 0.3 * hz), sc2)), p - Vector3(0, 0.08, 0)))


static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, ca: Color, cb: Color, cc: Color) -> void:
	var n := (b - a).cross(c - a)
	if n.length_squared() < 1e-10:
		return
	if n.y > 0.0:
		var t := b
		b = c
		c = t
		var tc := cb
		cb = cc
		cc = tc
	var nn := -(b - a).cross(c - a).normalized()
	for p in [[a, ca], [b, cb], [c, cc]]:
		st.set_color(p[1])
		st.set_normal(nn)
		st.add_vertex(p[0])


## Kule kaidesinin çevresinde etek (plan çokgeni, y taban; arka kenarlar (duvarın içi) atlanır: zb'den geçen kenar)
static func kule(e: Dictionary, poly: PackedVector2Array, y: float, ic_z: float, s: float) -> void:
	var n := poly.size()
	var c2 := KULE._merkez(poly)
	if not IstSurlar._ic(c2.x):
		return
	var tohum: int = e["tohum"]
	var W := 3.2
	var lod: int = e["lod"]
	var parca := 3 if lod == 0 else 1
	for i in n:
		var a := poly[i]
		var b := poly[(i + 1) % n]
		# duvarın içinde kalan kenar (iç yüz) atlanır
		if s > 0.0 and maxf(a.y, b.y) <= ic_z + 0.01 or s < 0.0 and minf(a.y, b.y) >= ic_z - 0.01:
			continue
		var na := KULE._dis_normal(poly[(i - 1 + n) % n], a, c2).lerp(KULE._dis_normal(a, b, c2), 0.5).normalized()
		var nb := KULE._dis_normal(a, b, c2).lerp(KULE._dis_normal(b, poly[(i + 2) % n], c2), 0.5).normalized()
		for q in parca:
			var t0 := float(q) / parca
			var t1 := float(q + 1) / parca
			var pa := a.lerp(b, t0)
			var pb := a.lerp(b, t1)
			var nra := na.lerp(nb, t0).normalized()
			var nrb := na.lerp(nb, t1).normalized()
			var rows: Array = []
			for side in 2:
				var p := pa if side == 0 else pb
				var nr := nra if side == 0 else nrb
				var hx := _h(tohum + roundi(p.x * 3.0), roundi(p.y * 3.0))
				var h0 := 0.35 + 0.45 * hx
				var Wl := W * (0.8 + 0.5 * hx)
				var row: Array = []
				for c: float in [-0.5, 0.0, 0.35, 0.8, Wl * 0.5, Wl * 0.75, Wl]:
					var tt := clampf(c / Wl, 0.0, 1.0)
					var yy := h0 + 0.05 if c < 0.0 else h0 * pow(1.0 - tt, 1.6)
					if c >= Wl:
						yy = -0.03
					var pp := p + nr * c
					# SUR-OYUN 4e: merdiven ayak izinde etek yere iner (basamağa taşmaz)
					if c > 0.0 and merdiven_duzelt:
						for yr: Rect2 in e["yasak"]:
							if yr.has_point(pp):
								yy = -0.03
					row.append(Vector3(pp.x, y + yy, pp.y))
				rows.append(row)
			_doldur(e, rows, s)


## Dip bandı (nem, toprak sıçraması, yosun): yüz çizgisi boyunca dikey şerit; gölgelendirici benekli seyreltir
static func bant(e: Dictionary, a: Vector2, b: Vector2, nr: Vector2, y: float, ofs := 0.03, ust := 1.6) -> void:
	var bst: SurfaceTool = e["bst"]
	var L := a.distance_to(b)
	if L < 0.2:
		return
	# pencereli kurulum: yalnız bu pencerenin x aralığındaki parçalar (dilim birkaç işte kurulur)
	if L > 2.5:
		var n := int(ceil(L / 2.0))
		for k in n:
			bant(e, a.lerp(b, float(k) / n), a.lerp(b, float(k + 1) / n), nr, y, ofs, ust)
		return
	if not IstSurlar._ic((a.x + b.x) * 0.5):
		return
	var n3 := Vector3(nr.x, 0, nr.y)
	var p0 := Vector3(a.x, y - 0.3, a.y) + n3 * ofs
	var p1 := Vector3(b.x, y - 0.3, b.y) + n3 * ofs
	var u := Vector3(0, ust + 0.3, 0)
	var vs := [p0, p1, p1 + u, p0 + u]
	var uv := [Vector2(0, 0), Vector2(L, 0), Vector2(L, ust + 0.3), Vector2(0, ust + 0.3)]
	for ix: int in [0, 1, 2, 0, 2, 3]:
		bst.set_normal(n3)
		bst.set_uv(uv[ix])
		bst.add_vertex(vs[ix])
	# sarım: normal tarafından saat yönü; n3'e göre çevir
	e["bn"] = int(e["bn"]) + 2


static func _bant_malzeme() -> ShaderMaterial:
	if _bant_mat != null:
		return _bant_mat
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform vec3 camur : source_color = vec3(0.34, 0.29, 0.22);
uniform vec3 yosun : source_color = vec3(0.27, 0.30, 0.17);
varying vec3 wp;
float hs(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float gn(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hs(i), hs(i + vec2(1, 0)), f.x), mix(hs(i + vec2(0, 1)), hs(i + vec2(1, 1)), f.x), f.y);
}
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	float h = UV.y;                         // dipten yükseklik (m)
	vec2 q = vec2(UV.x + wp.y * 0.0, h);
	float n = gn(q * vec2(3.1, 4.3)) * 0.55 + gn(q * vec2(11.0, 13.0)) * 0.3 + gn(q * vec2(29.0, 23.0)) * 0.15;
	// yukarı doğru seyrelen benekler (toprak sıçraması), dipte tam
	// TUR-7: ince benek (iri koyu leke değil): dipte sürekli ıslak taban, yukarı doğru seyrek ve küçülen sıçrama
	float n2 = gn(q * vec2(17.0, 21.0)) * 0.6 + gn(q * vec2(41.0, 37.0)) * 0.4;
	float esik = smoothstep(0.05, 1.5, h + (gn(vec2(UV.x * 0.35, 3.0)) - 0.5) * 0.5);
	if (mix(n, n2, smoothstep(0.2, 0.8, h)) < esik * 0.97) { discard; }
	float ym = smoothstep(0.55, 0.85, gn(q * vec2(1.7, 2.3))) * (1.0 - smoothstep(0.2, 0.9, h));
	vec3 c = mix(camur, yosun, ym);
	c *= 0.85 + 0.3 * gn(q * 7.0);
	ALBEDO = c;
	ROUGHNESS = 1.0;
}
"""
	_bant_mat = ShaderMaterial.new()
	_bant_mat.shader = sh
	return _bant_mat


## Ot öbeği: 7 ince, eğik yaprak (iki yüzlü üçgen; piramit değil)
static func ot_mesh() -> ArrayMesh:
	if _ot != null:
		return _ot
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in 7:
		var a := TAU * k / 7.0 + _h(k, 3) * 0.6
		var r := 0.04 + 0.08 * _h(k, 5)
		var base := Vector3(cos(a) * r, 0.0, sin(a) * r)
		var lean := Vector3(cos(a), 0.0, sin(a)) * (0.12 + 0.18 * _h(k, 9))
		var hgt := 0.35 + 0.35 * _h(k, 7)
		var side := Vector3(-sin(a), 0.0, cos(a)) * 0.035
		var tip := base + lean + Vector3(0, hgt, 0)
		var c0 := Color(0.62, 0.66, 0.38)
		var c1 := Color(0.86, 0.84, 0.55)
		for f in 2:
			var v := [base - side, base + side, tip] if f == 0 else [base + side, base - side, tip]
			var nr := (Vector3(0, 0.4, 0) + Vector3(cos(a), 0, sin(a)) * (1.0 if f == 0 else -1.0)).normalized()
			for m in 3:
				st.set_color(c1 if m == 2 else c0)
				st.set_normal(nr)
				st.add_vertex(v[m])
	_ot = st.commit()
	return _ot


## Çalı: düzensiz, alçak yuvarlak öbek (köşeleri oynatılmış küre; birkaç tutam)
static func cali_mesh() -> ArrayMesh:
	if _cali != null:
		return _cali
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for b in 3:
		var sm := SphereMesh.new()
		sm.radius = 0.45 - b * 0.08
		sm.height = 0.7 - b * 0.12
		sm.radial_segments = 7
		sm.rings = 4
		var arr := sm.get_mesh_arrays()
		var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var ix: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
		var off := Vector3((b - 1) * 0.35, 0.25 - b * 0.03, (_h(b, 2) - 0.5) * 0.5)
		for k in ix.size():
			var v := vs[ix[k]]
			var hh := fposmod(sin(snappedf(v.x, 0.01) * 21.3 + snappedf(v.y, 0.01) * 51.1 + snappedf(v.z, 0.01) * 17.9 + b) * 9341.7, 1.0)
			var vv := v * (0.75 + 0.45 * hh) + off
			var g := 0.75 + 0.35 * hh
			st.set_color(Color(0.32 * g, 0.40 * g, 0.20 * g))
			st.add_vertex(vv)
	st.generate_normals()
	_cali = st.commit()
	return _cali


static func _mm(p: Node3D, mesh: Mesh, xfs: Array, mat: Material, ad: String) -> void:
	if xfs.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xfs.size()
	for i in xfs.size():
		mm.set_instance_transform(i, xfs[i])
	var mi := MultiMeshInstance3D.new()
	mi.name = ad
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.add_child(mi)


## SUR-OYUN 4e: merdiven ayak izinde kule eteği yere iner (yalnız ÖNCE|SONRA karşılaştırma karesi kapatır)
static var merdiven_duzelt := true

## surlar.gd _run sonunda: dilimin bütün yüzlerinde etek, kule kaidelerinde etek, dip bandı, döküntü. lay: _layout çıktısı;
## kuleler: [[plan, y, iç_z, yön]]; kes_*: atlanacak x aralıkları
static func kur(root: Node3D, lay: Dictionary, lod: int, xw: Array, dy: float, kuleler: Array, kes: Dictionary, hendek: bool) -> void:
	if lod >= 2:
		return
	var d: Dictionary = lay["d"]
	var L: float = lay["L"]
	var x0 := -L * 0.5
	var x1 := L * 0.5
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bst := SurfaceTool.new()
	bst.begin(Mesh.PRIMITIVE_TRIANGLES)
	var e := {"st": st, "bst": bst, "n": 0, "bn": 0, "lod": lod, "tohum": int(lay["rng_seed"]),
		"xf": xw[1] if xw[0] else Transform3D(), "dunya": bool(xw[0]) and not OTURTMA.kusak.is_empty(),
		"ot": [], "tas": [], "cali": [], "_px": 0.0, "yasak": kes.get("yasak", [])}
	var zi0: float = d["zi0"]
	var zi1: float = d["zi1"]
	var zo0: float = d["zo0"]
	var zo1: float = d["zo1"]
	var zm0: float = d["zm0"]
	var kule_ic: Array = kes.get("kule_ic", [])
	var kule_dis: Array = kes.get("kule_dis", [])
	# yüzler: şehir yüzü, iç surun peribolos yüzü (iç kuleler arası), dış surun peribolos yüzü, dış surun teras yüzü (dış
	# kuleler arası), parateikhion alçak duvarının teras yüzü
	yuz(e, x0, x1, zi0, -1.0, 0.0, 3.0, 6.0, kes.get("sehir", []))
	yuz(e, x0, x1, zi1, 1.0, 0.0, 3.0, 5.0, kule_ic + kes.get("kapi", []))
	yuz(e, x0, x1, zo0, -1.0, 0.0, 3.0, 5.0, kes.get("peri", []))
	if hendek:
		yuz(e, x0, x1, zo1, 1.0, dy, 2.5, 3.6, kule_dis + kes.get("kapi", []) + kes.get("gedik", []))
		yuz(e, x0, x1, zm0 - 1.8, -1.0, dy, 2.2, 3.2, kes.get("para", []))
	for k: Array in kuleler:
		kule(e, k[0], float(k[1]), float(k[2]), float(k[3]))
	# dip bandı: düz yüzler (kesik aralıklar dışında)
	var segs := func(cut: Array) -> Array:
		var out: Array = [[x0, x1]]
		for c: Array in cut:
			var nv: Array = []
			for v: Array in out:
				if float(c[1]) <= float(v[0]) or float(c[0]) >= float(v[1]):
					nv.append(v)
				else:
					if float(c[0]) > float(v[0]):
						nv.append([v[0], c[0]])
					if float(c[1]) < float(v[1]):
						nv.append([c[1], v[1]])
			out = nv
		return out
	for sg: Array in segs.call(kes.get("sehir", [])):
		bant(e, Vector2(sg[0], zi0), Vector2(sg[1], zi0), Vector2(0, -1), 0.0)
	for sg: Array in segs.call(kule_ic + kes.get("kapi", [])):
		bant(e, Vector2(sg[0], zi1), Vector2(sg[1], zi1), Vector2(0, 1), 0.0)
	for sg: Array in segs.call(kes.get("peri", [])):
		bant(e, Vector2(sg[0], zo0), Vector2(sg[1], zo0), Vector2(0, -1), 0.0)
	if hendek:
		for sg: Array in segs.call(kule_dis + kes.get("kapi", []) + kes.get("gedik", [])):
			bant(e, Vector2(sg[0], zo1), Vector2(sg[1], zo1), Vector2(0, 1), dy)
	for k: Array in kuleler:
		var poly: PackedVector2Array = k[0]
		var n := poly.size()
		var c2 := KULE._merkez(poly)
		for i in n:
			var a := poly[i]
			var b := poly[(i + 1) % n]
			var s := float(k[3])
			if s > 0.0 and maxf(a.y, b.y) <= float(k[2]) + 0.01 or s < 0.0 and minf(a.y, b.y) >= float(k[2]) - 0.01:
				continue
			bant(e, a, b, KULE._dis_normal(a, b, c2), float(k[1]), 0.36, 1.5)
	if int(e["n"]) > 0:
		var mi := MeshInstance3D.new()
		mi.name = "SurDibiEtek"
		mi.mesh = st.commit()
		mi.material_override = etek_malzeme()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(mi)
		if lod == 0:
			var body := StaticBody3D.new()
			body.name = "SurDibiEtekGovde"
			var cs := CollisionShape3D.new()
			cs.shape = mi.mesh.create_trimesh_shape()
			body.add_child(cs)
			root.add_child(body)
		sayac["etek"] = int(sayac["etek"]) + 1
		sayac["ucgen"] = int(sayac["ucgen"]) + int(e["n"])
	if int(e["bn"]) > 0 and lod == 0:
		var bm := MeshInstance3D.new()
		bm.name = "SurDibiBant"
		bm.mesh = bst.commit()
		bm.material_override = _bant_malzeme()
		bm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(bm)
	if lod == 0:
		if _ot_mat == null:
			_ot_mat = StandardMaterial3D.new()
			_ot_mat.vertex_color_use_as_albedo = true
			_ot_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			_ot_mat.roughness = 1.0
			_ot_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
			_tas_mat = StandardMaterial3D.new()
			_tas_mat.albedo_color = Color("8e8472")
			_tas_mat.roughness = 1.0
		_mm(root, ot_mesh(), e["ot"], _ot_mat, "SurDibiOt")
		_mm(root, KULE.kaya_mesh(), e["tas"], KULE._tas_mat(Color("9a8f7c"), 0), "SurDibiTas")
		_mm(root, cali_mesh(), e["cali"], _ot_mat, "SurDibiCali")
