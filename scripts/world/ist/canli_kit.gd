extends RefCounted
## Ortak canlı kiti (CANLI; kalite notu 32 "KUTU YASAĞI"). class_name YOK (yeni class_name yasak): kullanan dosya
##   const CK = preload("res://scripts/world/ist/canli_kit.gd")
## ile çağırır. Hiçbir canlı kutu parçasından kurulmaz: gövde, boyun, baş, bacak, kuyruk KESİT HALKALARINDAN örülmüş
## tüplerdir (her halka elips: yan yarıçap rx, üst ryt, alt ryb; renk), uçları yumuşak kubbe ile kapanır, normaller
## halkanın elips normalidir (yumuşak). Küçük parçalar (göz, burun deliği, toynak, hörgüç, yün) aynı üreticiden elipsoit.
## Renk: düz renk + hafif ton farkı (sırt koyu, karın açık; burun, toynak, boynuz ayrı ton) köşe rengine yazılır,
## malzeme oyunun toon malzemesidir (Props.mat dili: DIFFUSE_TOON + dış hat).
##
## Türler: okuz, manda, at, katir, esek, deve, koyun, keci, kopek, kedi (dört ayaklı); tavuk, marti, guvercin (kuş).
## Yön: +Z ileri, ayak y = 0, gövde ortası x = z = 0. Ölçüler gerçek (metre): öküz cidago 1,42 / gövde+baş 2,4;
## at 1,5; deve hörgüç 2,05; koyun 0,7.
##
## Katmanlar (lod): 0 yakın (≤ 1 400 üçgen; eklemli), 1 orta (≤ 300), 2 uzak (≤ 90; dört bacak + boyun + baş silueti).
## Parçalar (eklem): govde (kök), boyun → bas → kulak_l/kulak_r, kuyruk, b0..b3 (omuz/kalça) → d0..d3 (diz/bilek).
## Bacak sırası Ox/Horse ile aynı: 0 sol ön, 1 sağ ön, 2 sol arka, 3 sağ arka (sol = −x).
##
## Kullanım:
##   CK.mesh(tur, lod, opt)            → ArrayMesh (durağan duruş; önbellekli)
##   CK.dugum(tur, opt)                → {"root": Node3D, "p": {parça adı: Node3D}} (eklemli; yakın katman)
##   CK.bld_ekle(b, tur, pos, yaw, opt) ordugâhın Bld'sine (köşe renkli birleşik ağ) ekler
##   CK.ucgen(tur, lod)                → üçgen sayısı (rapor/test)
## opt: renk (Color, post), poz ("dur" | "otla" | "yat" | "yuru" | "uc" | "bak"), bas_yaw (derece), adim (0..1 yürüyüş
##      evresi), tohum (int), takim (Array: "boyunduruk", "yular", "semer", "yuk", "eyer", "cul"), lod.

const SEG := [10, 6, 4]        # gövde/baş halka kesimi
const SEG_L := [8, 3, 3]       # bacak
const SEG_K := [8, 3, 3]       # küçük (kulak, boynuz, kuyruk)
## Katmana göre en çok halka sayısı (gövde b, boyun n, baş h, bacak l, küçük k); yakında hepsi
const HALKA := {"b": [99, 5, 4], "u": [99, 5, 5], "n": [99, 3, 2], "h": [99, 4, 2], "l": [99, 3, 2], "k": [99, 2, 2]}

static var _mesh_cache := {}
static var _mat: StandardMaterial3D


# ================================================================ birikimci (üçgen listesi)

class Acc:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var c := PackedColorArray()

	func tri(a: Vector3, b: Vector3, d: Vector3, na: Vector3, nb: Vector3, nd: Vector3, ca: Color, cb: Color, cd: Color) -> void:
		var g := (b - a).cross(d - a)
		if g.length_squared() < 1e-14:
			return
		# Godot önyüzü saat yönü (CW) sayar: geometrik normal köşe normaliyle AYNI yöndeyse sıra ters çevrilir
		if g.dot(na + nb + nd) > 0.0:
			v.append(a); v.append(d); v.append(b)
			n.append(na); n.append(nd); n.append(nb)
			c.append(ca); c.append(cd); c.append(cb)
		else:
			v.append(a); v.append(b); v.append(d)
			n.append(na); n.append(nb); n.append(nd)
			c.append(ca); c.append(cb); c.append(cd)

	func tris() -> int:
		return v.size() / 3

	func add(o: Acc, xf: Transform3D) -> void:
		var nb := xf.basis.inverse().transposed()
		for i in o.v.size():
			v.append(xf * o.v[i])
			n.append((nb * o.n[i]).normalized())
			c.append(o.c[i])

	func mesh() -> ArrayMesh:
		var m := ArrayMesh.new()
		if v.is_empty():
			return m
		var arr := []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = v
		arr[Mesh.ARRAY_NORMAL] = n
		arr[Mesh.ARRAY_COLOR] = c
		m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
		return m


# ================================================================ ilkel: halka tüpü, elipsoit

## Ton: sırt biraz koyu, karın açık (toon gölgesinin üstüne hafif boya farkı)
static func _ton(col: Color, nrm: Vector3, ton := 1.0) -> Color:
	var up := clampf(nrm.y, 0.0, 1.0)
	var dn := clampf(-nrm.y, 0.0, 1.0)
	return col.darkened(0.09 * up * ton).lightened(0.13 * dn * ton)


## Halkalar: [merkez, rx, ryt, ryb, renk]. Yan eksen dünya X'ine (yoksa Z'ye) en yakın dik; üst eksen = T × yan.
## arc: [a0, a1] (radyan) açık şerit (örtü); boş = tam halka. pur: yün/kıl pürüzü (yarıçap oranı).
static func _tube(acc: Acc, rings: Array, segs: int, cap0: bool, cap1: bool, ton := 1.0, arc := [], pur := 0.0, yan_ref := Vector3.RIGHT) -> void:
	var nr := rings.size()
	if nr < 2:
		return
	var full := arc.is_empty()
	var cols := segs if full else segs + 1
	var P: Array = []
	var N: Array = []
	var C: Array = []
	var Ts: Array = []
	for i in nr:
		var r: Array = rings[i]
		var c: Vector3 = r[0]
		var a: Vector3 = (rings[maxi(i - 1, 0)] as Array)[0]
		var b: Vector3 = (rings[mini(i + 1, nr - 1)] as Array)[0]
		var t := b - a
		if t.length_squared() < 1e-10:
			t = Vector3.FORWARD
		t = t.normalized()
		var ref := yan_ref
		if absf(t.dot(ref)) > 0.92:
			ref = Vector3.BACK if absf(t.dot(Vector3.BACK)) < 0.92 else Vector3.UP
		var s := (ref - t * t.dot(ref)).normalized()
		var u := t.cross(s).normalized()
		if u.y < -0.2 or (absf(u.y) <= 0.2 and u.z < 0.0):
			u = -u            # üst eksen yukarı/ileri baksın (ryt üstte kalsın)
		var rx: float = r[1]
		var ryt: float = r[2]
		var ryb: float = r[3]
		var col: Color = r[4]
		var pr: Array = []
		var nn: Array = []
		var cc: Array = []
		for k in cols:
			var ang: float = TAU * k / segs if full else lerpf(arc[0], arc[1], float(k) / segs)
			var ca := cos(ang)
			var sa := sin(ang)
			var ry := ryt if sa >= 0.0 else ryb
			var q := 1.0
			if pur > 0.0:
				q = 1.0 + pur * (sin(k * 2.7 + i * 1.9) * 0.6 + sin(k * 5.3 - i * 3.1) * 0.4)
			var pos := c + s * (ca * rx * q) + u * (sa * ry * q)
			var nrm := (s * (ca / maxf(rx, 0.001)) + u * (sa / maxf(ry, 0.001))).normalized()
			pr.append(pos)
			nn.append(nrm)
			cc.append(_ton(col, nrm, ton))
		P.append(pr)
		N.append(nn)
		C.append(cc)
		Ts.append(t)
	for i in nr - 1:
		var r0: Array = rings[i]
		var r1: Array = rings[i + 1]
		if ((r0[0] as Vector3) - (r1[0] as Vector3)).length_squared() < 1e-10 and absf(float(r0[1]) - float(r1[1])) < 1e-5:
			continue          # renk dikişi (aynı yerde iki halka)
		for k in (segs if full else segs):
			var k2 := (k + 1) % cols if full else k + 1
			acc.tri(P[i][k], P[i + 1][k], P[i + 1][k2], N[i][k], N[i + 1][k], N[i + 1][k2], C[i][k], C[i + 1][k], C[i + 1][k2])
			acc.tri(P[i][k], P[i + 1][k2], P[i][k2], N[i][k], N[i + 1][k2], N[i][k2], C[i][k], C[i + 1][k2], C[i][k2])
	if not full:
		return
	for e in 2:
		if (e == 0 and not cap0) or (e == 1 and not cap1):
			continue
		var i := 0 if e == 0 else nr - 1
		var r: Array = rings[i]
		var t: Vector3 = Ts[i] * (-1.0 if e == 0 else 1.0)
		var depth := minf(float(r[1]), (float(r[2]) + float(r[3])) * 0.5) * 0.55
		var pole: Vector3 = (r[0] as Vector3) + t * depth
		var pc := _ton(r[4], t, ton)
		for k in segs:
			var k2 := (k + 1) % segs
			acc.tri(pole, P[i][k], P[i][k2], t, N[i][k], N[i][k2], pc, C[i][k], C[i][k2])


## Elipsoit: merkez, yarıçaplar (yerel x,y,z), dönüş, renk. Halkaları z boyunca.
static func _ell(acc: Acc, c: Vector3, rad: Vector3, col: Color, segs: int, bas := Basis.IDENTITY, ton := 1.0, pur := 0.0) -> void:
	var m := maxi(2, segs / 2)
	var rings: Array = []
	for k in range(1, m):
		var a := PI * k / m
		var z := -cos(a) * rad.z
		var f := sin(a)
		rings.append([c + bas * Vector3(0, 0, z), rad.x * f, rad.y * f, rad.y * f, col])
	if rings.size() == 1:
		var r0: Array = rings[0]
		rings = [[c + bas * Vector3(0, 0, -rad.z * 0.4), float(r0[1]) * 0.9, float(r0[2]) * 0.9, float(r0[3]) * 0.9, col], [c + bas * Vector3(0, 0, rad.z * 0.4), float(r0[1]) * 0.9, float(r0[2]) * 0.9, float(r0[3]) * 0.9, col]]
	_tube(acc, rings, segs, true, true, ton, [], pur, bas.x)


# ================================================================ tür tanımları (dört ayaklı)

## Gövde kesit profili: [f (gövde boyu oranı, arka −0,5 … ön +0,5), üst (H oranı), alt (H − D·oran), en (W oranı)]
const PROF_SIGIR := [[-0.53, 0.90, 0.38, 0.30], [-0.45, 0.965, 0.74, 0.74], [-0.30, 0.985, 0.95, 0.93], [-0.10, 0.965, 1.05, 1.0],
	[0.12, 0.975, 1.07, 1.0], [0.32, 1.0, 1.0, 0.9], [0.45, 0.94, 0.93, 0.76], [0.54, 0.78, 0.72, 0.42]]
const PROF_AT := [[-0.53, 0.92, 0.34, 0.32], [-0.45, 0.985, 0.66, 0.78], [-0.30, 1.0, 0.84, 0.95], [-0.10, 0.965, 0.96, 1.0],
	[0.12, 0.97, 1.0, 0.98], [0.32, 1.0, 1.0, 0.88], [0.45, 0.93, 0.92, 0.74], [0.54, 0.76, 0.7, 0.42]]
const PROF_KOPEK := [[-0.53, 0.9, 0.3, 0.38], [-0.45, 0.96, 0.52, 0.78], [-0.30, 0.97, 0.56, 0.8], [-0.10, 0.96, 0.66, 0.84],
	[0.12, 0.97, 0.86, 0.95], [0.32, 1.0, 1.0, 0.96], [0.45, 0.95, 0.94, 0.8], [0.54, 0.8, 0.7, 0.5]]
const PROF_DEVE := [[-0.53, 0.86, 0.36, 0.30], [-0.45, 0.93, 0.70, 0.72], [-0.30, 0.95, 0.9, 0.9], [-0.10, 0.95, 1.0, 1.0],
	[0.12, 0.96, 1.04, 0.98], [0.32, 0.99, 1.04, 0.86], [0.45, 0.95, 0.98, 0.7], [0.54, 0.82, 0.8, 0.42]]
const PROF_KOYUN := [[-0.53, 0.86, 0.32, 0.45], [-0.45, 0.97, 0.78, 0.86], [-0.30, 1.0, 0.98, 0.97], [-0.10, 1.0, 1.04, 1.0],
	[0.12, 1.0, 1.04, 1.0], [0.32, 1.0, 1.0, 0.95], [0.45, 0.95, 0.92, 0.82], [0.54, 0.82, 0.74, 0.55]]


static func tanim(tur: String) -> Dictionary:
	match tur:
		"okuz":
			return {"H": 1.42, "L": 1.8, "W": 0.43, "D": 0.76, "prof": PROF_SIGIR, "leg": 0.1,
				"neck": [0.42, 18.0, 18.0, Vector2(0.28, 0.34), Vector2(0.17, 0.2)], "gerdan": 0.16,
				"head": [0.5, 62.0, 0.15, 0.135, 0.105, 0.095], "kulak": ["yan", 0.17, 0.07], "boynuz": ["okuz", 0.34, 0.045],
				"kuyruk": ["puskul", 0.78, 0.035], "coat": Color("8a6a4c"), "post": [Color("6e5238"), Color("a08462"), Color("8a7a6a"), Color("5a4434"), Color("b8a080")],
				"burun": Color("3a2e28"), "toynak": Color("2a2420"), "koyu": 0.18}
		"manda":
			return {"H": 1.38, "L": 1.9, "W": 0.46, "D": 0.78, "prof": PROF_SIGIR, "leg": 0.105,
				"neck": [0.38, 8.0, 8.0, Vector2(0.3, 0.34), Vector2(0.2, 0.22)], "gerdan": 0.05,
				"head": [0.52, 45.0, 0.15, 0.13, 0.11, 0.1], "kulak": ["yan", 0.15, 0.06], "boynuz": ["manda", 0.5, 0.06],
				"kuyruk": ["puskul", 0.72, 0.035], "coat": Color("34302e"), "post": [Color("2e2a28"), Color("3c3633"), Color("4a4240")],
				"burun": Color("1e1a18"), "toynak": Color("1a1614"), "koyu": 0.1}
		"at":
			return {"H": 1.5, "L": 1.62, "W": 0.34, "D": 0.68, "prof": PROF_AT, "leg": 0.078,
				"neck": [0.78, 52.0, 58.0, Vector2(0.2, 0.32), Vector2(0.12, 0.17)], "yele": 0.11,
				"head": [0.6, 52.0, 0.105, 0.12, 0.075, 0.085], "kulak": ["dik", 0.15, 0.05],
				"kuyruk": ["kil", 0.95, 0.07], "coat": Color("6a4a30"), "post": [Color("6a4a30"), Color("8a6a46"), Color("3a2e26"), Color("a88a62"), Color("c9b080"), Color("5a4434"), Color("d8d2c4")],
				"burun": Color("2e2622"), "toynak": Color("2a2420"), "koyu": 0.3, "bacak_koyu": true}
		"katir":
			return {"H": 1.38, "L": 1.45, "W": 0.31, "D": 0.62, "prof": PROF_AT, "leg": 0.07,
				"neck": [0.62, 40.0, 46.0, Vector2(0.18, 0.27), Vector2(0.11, 0.15)], "yele": 0.07,
				"head": [0.58, 50.0, 0.1, 0.11, 0.075, 0.08], "kulak": ["uzun", 0.24, 0.06],
				"kuyruk": ["kil", 0.8, 0.05], "coat": Color("5e4a3a"), "post": [Color("5e4a3a"), Color("4a3a30"), Color("7a6650")],
				"burun": Color("cfc0a8"), "toynak": Color("2a2420"), "koyu": 0.2}
		"esek":
			return {"H": 1.08, "L": 1.1, "W": 0.24, "D": 0.48, "prof": PROF_AT, "leg": 0.058,
				"neck": [0.42, 32.0, 38.0, Vector2(0.14, 0.2), Vector2(0.09, 0.12)], "yele": 0.06,
				"head": [0.5, 52.0, 0.09, 0.1, 0.07, 0.075], "kulak": ["uzun", 0.27, 0.055],
				"kuyruk": ["puskul", 0.5, 0.03], "coat": Color("7a6e62"), "post": [Color("7a6e62"), Color("8a7a66"), Color("5e5650"), Color("9a8c7c")],
				"burun": Color("d8cebc"), "toynak": Color("2a2420"), "koyu": 0.15, "karin_acik": 0.25}
		"deve":
			return {"H": 1.78, "L": 1.6, "W": 0.34, "D": 0.78, "prof": PROF_DEVE, "leg": 0.08,
				"neck": [1.05, 8.0, 88.0, Vector2(0.18, 0.3), Vector2(0.1, 0.12)],
				"head": [0.5, 12.0, 0.1, 0.11, 0.07, 0.085], "kulak": ["kucuk", 0.08, 0.05],
				"kuyruk": ["puskul", 0.5, 0.03], "hor": [[-0.02, 0.32, 0.24, 0.42]],
				"coat": Color("b49a6c"), "post": [Color("b49a6c"), Color("9a7e54"), Color("c8ae80"), Color("8a7048")],
				"burun": Color("6a5a44"), "toynak": Color("6a5a48"), "koyu": 0.08, "ince_bacak": true, "dudak": true, "nasir": true}
		"koyun":
			return {"H": 0.7, "L": 0.86, "W": 0.27, "D": 0.4, "prof": PROF_KOYUN, "leg": 0.036, "yun": 0.06,
				"neck": [0.22, 30.0, 34.0, Vector2(0.14, 0.17), Vector2(0.08, 0.09)],
				"head": [0.26, 55.0, 0.07, 0.075, 0.045, 0.05], "kulak": ["sark", 0.1, 0.04],
				"kuyruk": ["yag", 0.18, 0.08], "coat": Color("e4dccb"), "post": [Color("e4dccb"), Color("d8ceb8"), Color("c8bca4"), Color("8a7a66"), Color("3a3430")],
				"bas_renk": Color("3a3028"), "bacak_renk": Color("4a3e34"), "burun": Color("2a2420"), "toynak": Color("2a2420"), "koyu": 0.0}
		"keci":
			return {"H": 0.72, "L": 0.78, "W": 0.19, "D": 0.36, "prof": PROF_AT, "leg": 0.03,
				"neck": [0.26, 45.0, 52.0, Vector2(0.09, 0.13), Vector2(0.06, 0.07)],
				"head": [0.27, 58.0, 0.06, 0.07, 0.04, 0.045], "kulak": ["yan", 0.11, 0.035], "boynuz": ["keci", 0.24, 0.022],
				"sakal": true, "kuyruk": ["kisa", 0.12, 0.025], "coat": Color("e8e2d4"), "post": [Color("e8e2d4"), Color("3a3430"), Color("8a6a4a"), Color("5a4a3a")],
				"burun": Color("c8beb0"), "toynak": Color("3a3028"), "koyu": 0.1}
		"kopek":
			return {"H": 0.56, "L": 0.62, "W": 0.13, "D": 0.27, "prof": PROF_KOPEK, "leg": 0.03, "pati": true,
				"neck": [0.2, 40.0, 48.0, Vector2(0.08, 0.1), Vector2(0.06, 0.07)],
				"head": [0.24, 12.0, 0.07, 0.07, 0.035, 0.04], "kulak": ["kopek", 0.09, 0.045],
				"kuyruk": ["kalkik", 0.32, 0.025], "coat": Color("8a6a46"), "post": [Color("8a6a46"), Color("a89a80"), Color("5a4a3a"), Color("c8a468")],
				"burun": Color("1a1414"), "toynak": Color("3a3028"), "koyu": 0.12}
		"kedi":
			return {"H": 0.26, "L": 0.36, "W": 0.075, "D": 0.13, "prof": PROF_KOPEK, "leg": 0.016, "pati": true,
				"neck": [0.08, 40.0, 50.0, Vector2(0.05, 0.055), Vector2(0.04, 0.045)],
				"head": [0.11, 8.0, 0.05, 0.048, 0.022, 0.022], "kulak": ["kedi", 0.05, 0.03],
				"kuyruk": ["kedi", 0.3, 0.014], "coat": Color("d8843a"), "post": [Color("d8843a"), Color("6a6a70"), Color("e8e2d4"), Color("3a3430")],
				"burun": Color("d86a6a"), "toynak": Color("3a3028"), "koyu": 0.05, "kisa_bas": true}
	return tanim("okuz")


# ================================================================ parça kurucu

## Parça: {ad, ust (ebeveyn adı), pv (pivot, model uzayı), g: [[lods, tür, ...]]}
static func _p(parts: Dictionary, ad: String, ust: String, pv: Vector3) -> Dictionary:
	var p := {"ad": ad, "ust": ust, "pv": pv, "g": []}
	parts[ad] = p
	return p


static func _tb(p: Dictionary, lods: Array, rings: Array, sk := "b", cap0 := false, cap1 := true, ton := 1.0, pur := 0.0, arc := [], yan := Vector3.RIGHT) -> void:
	(p["g"] as Array).append([lods, "t", rings, sk, cap0, cap1, ton, pur, arc, yan])


static func _el(p: Dictionary, lods: Array, c: Vector3, rad: Vector3, col: Color, sk := "k", bas := Basis.IDENTITY, pur := 0.0) -> void:
	(p["g"] as Array).append([lods, "e", c, rad, col, sk, bas, pur])


static func _rg(c: Vector3, rx: float, ry: float, col: Color, ryb := -1.0) -> Array:
	return [c, rx, ry, ry if ryb < 0.0 else ryb, col]


static func _renk(T: Dictionary, opt: Dictionary) -> Color:
	if opt.has("renk"):
		return opt["renk"]
	var post: Array = T["post"]
	var sd: int = int(opt.get("tohum", 0))
	if sd == 0:
		return T["coat"]
	return post[absi(sd * 7 + 3) % post.size()]


static func parcalar(tur: String, opt := {}) -> Dictionary:
	if tur in ["tavuk", "marti", "guvercin"]:
		return _kus(tur, opt)
	var T := tanim(tur)
	if opt.has("H"):           # boy ayarı (oyunun eski sınıf ölçüsüne oturtmak için; oran korunur)
		var k := float(opt["H"]) / float(T["H"])
		for key in ["L", "W", "D"]:
			T[key] = float(T[key]) * lerpf(1.0, k, 0.8)
		T["H"] = opt["H"]
	var parts := {}
	var H: float = T["H"]
	var L: float = T["L"]
	var W: float = T["W"]
	var D: float = T["D"]
	var coat := _renk(T, opt)
	var koyu := coat.darkened(float(T["koyu"]))
	var karin := coat.lightened(float(T.get("karin_acik", 0.1)))
	var yun: float = T.get("yun", 0.0)
	var takim: Array = opt.get("takim", [])
	# --- gövde
	var g := _p(parts, "govde", "", Vector3.ZERO)
	var rings: Array = []
	var prof: Array = T["prof"]
	for pr: Array in prof:
		var f: float = pr[0]
		var top: float = H * float(pr[1])
		var bot: float = H - D * float(pr[2])
		var cy := (top + bot) * 0.5
		var ry := (top - bot) * 0.5
		var rx := W * float(pr[3])
		var col := coat
		rings.append([Vector3(0, cy, f * L), rx + yun * 0.4, ry + yun * 0.3, ry * 1.04 + yun * 0.3, col])
	if T.has("hor"):
		_tb(g, [0, 1], rings, "b", true, true)
		# uzak katman: hörgüç ayrı elipsoit yerine gövde kesitinde (üçgen bütçesi)
		var hp0: Array = (T["hor"] as Array)[0]
		var rh: Array = (rings[3] as Array).duplicate()
		rh[0] = (rh[0] as Vector3) + Vector3(0, float(hp0[1]) * 0.5, 0)
		rh[2] = float(rh[2]) + float(hp0[1]) * 0.5
		_tb(g, [2], [rings[0], rings[2], rh, rings[5], rings[7]], "u", true, true)
	else:
		_tb(g, [0, 1, 2], rings, "b", true, true, 1.0, 0.035 if yun > 0.0 else 0.0)
	# karın açık tonu: alt yarıya ince ikinci kabuk yerine halka rengini karın tarafında açığa çeken şerit (yalnız yakın)
	if not yun > 0.0:
		var kr: Array = []
		for i in range(2, 6):
			var r: Array = rings[i]
			kr.append([(r[0] as Vector3) + Vector3(0, -0.004, 0), float(r[1]) * 1.004, float(r[3]) * 1.004, float(r[3]) * 1.004, karin])
		_tb(g, [0], kr, "b", false, false, 1.0, 0.0, [PI * 1.18, PI * 1.82])
	# hörgüç (deve) / sırt
	for hp: Array in T.get("hor", []):
		var z: float = float(hp[0]) * L
		_el(g, [0, 1], Vector3(0, H * 0.985 + float(hp[1]) * 0.45, z), Vector3(float(hp[2]), float(hp[1]) * 0.85, float(hp[3])), coat, "k")
	# --- boyun
	var nk: Array = T["neck"]
	var nlen: float = nk[0]
	var a0: float = deg_to_rad(nk[1])
	var a1: float = deg_to_rad(nk[2])
	var nr0: Vector2 = nk[3]
	var nr1: Vector2 = nk[4]
	var base := Vector3(0, H - D * 0.32, L * 0.38)
	if tur == "deve":
		base = Vector3(0, H - D * 0.42, L * 0.42)
	var bn := _p(parts, "boyun", "govde", base)
	var npts: Array = []
	var p := base
	var steps := 5
	npts.append(p)
	for i in steps:
		var tt := (i + 0.5) / steps
		var a := lerpf(a0, a1, tt)
		if tur == "deve":
			a = lerpf(-deg_to_rad(22.0), a1, pow(tt, 1.25))
		p += Vector3(0, sin(a), cos(a)) * (nlen / steps)
		npts.append(p)
	var poll: Vector3 = npts[-1]
	var nrings: Array = []
	for i in npts.size():
		var tt := float(i) / (npts.size() - 1)
		var rr := nr0.lerp(nr1, pow(tt, 0.8))
		nrings.append(_rg(npts[i], rr.x + yun * 0.3 * (1.0 - tt), rr.y + yun * 0.3 * (1.0 - tt), coat))
	# boyun kökü gövdeye gömülü (göğüs içinden başlar)
	var into := (npts[0] as Vector3) + Vector3(0, -0.05, -L * 0.12)
	nrings.insert(0, _rg(into, nr0.x * 0.95, nr0.y * 0.95, coat))
	_tb(bn, [0, 1, 2], nrings, "n", false, false)
	if T.has("yele"):
		var yh: float = T["yele"]
		var mane := Color("2a2220") if coat.get_luminance() > 0.35 or tur == "at" else coat.darkened(0.45)
		if coat.get_luminance() > 0.6:
			mane = coat.darkened(0.15)
		var mr: Array = []
		for i in range(2, npts.size()):
			var tt := float(i) / (npts.size() - 1)
			var rr := nr0.lerp(nr1, pow(tt, 0.8))
			mr.append(_rg((npts[i] as Vector3) + Vector3(0, rr.y * 0.85 + yh * 0.3, -0.03), 0.03, yh * (0.7 + 0.4 * (1.0 - tt)), mane, yh * 0.3))
		_tb(bn, [0], mr, "k", true, true)
	if T.has("gerdan"):
		var gd: float = T["gerdan"]
		var gr: Array = []
		for i in 4:
			var tt := float(i) / 3.0
			var q := (npts[0] as Vector3).lerp(npts[-2], tt) + Vector3(0, -nr0.y * (1.0 - tt) - nr1.y * tt - gd * 0.25 * sin(tt * PI) + 0.06, 0.02)
			gr.append(_rg(q, 0.05, 0.03, coat.darkened(0.04), gd * sin(PI * (0.15 + tt * 0.7))))
		_tb(bn, [0], gr, "k", true, true)
	# --- baş
	var hd: Array = T["head"]
	var hl: float = hd[0]
	var ha: float = deg_to_rad(hd[1])
	var hw: float = hd[2]
	var hdp: float = hd[3]
	var mw: float = hd[4]
	var md: float = hd[5]
	var hdir := Vector3(0, -sin(ha), cos(ha))
	var hup := Vector3(0, cos(ha), sin(ha))
	var bs := _p(parts, "bas", "boyun", poll)
	var bas_renk: Color = T.get("bas_renk", coat)
	var burun: Color = T["burun"]
	var muz := bas_renk.lerp(burun, 0.35) if tur in ["at", "okuz", "manda", "keci", "kopek", "kedi"] else burun
	if tur in ["katir", "esek"]:
		muz = burun
	var hr: Array = []
	hr.append(_rg(poll - hdir * hl * 0.08 + hup * hdp * 0.05, hw * 0.72, hdp * 0.72, bas_renk))
	hr.append(_rg(poll + hdir * hl * 0.16, hw, hdp * 0.95, bas_renk, hdp * 1.05))
	hr.append(_rg(poll + hdir * hl * 0.42, hw * 0.8, hdp * 0.82, bas_renk, hdp * (0.95 if tur in ["at", "katir", "esek"] else 0.85)))
	hr.append(_rg(poll + hdir * hl * 0.72, lerpf(hw * 0.8, mw, 0.6), lerpf(hdp * 0.82, md, 0.6), bas_renk.lerp(muz, 0.3)))
	hr.append(_rg(poll + hdir * hl * 0.9, mw, md, muz))
	hr.append(_rg(poll + hdir * hl * 1.0 - hup * md * 0.08, mw * 0.84, md * 0.78, muz))
	if T.get("kisa_bas", false):
		hr[0] = _rg(poll - hdir * hl * 0.25, hw * 0.8, hdp * 0.8, bas_renk)
	_tb(bs, [0, 1, 2], hr, "h", true, true)
	var side := Vector3.RIGHT
	for sx: float in [-1.0, 1.0]:
		# göz
		var ep: Vector3 = poll + hdir * hl * 0.2 + side * sx * hw * 0.86 + hup * hdp * 0.18
		_el(bs, [0], ep, Vector3(hw * 0.12, hw * 0.12, hw * 0.12), Color("15110e"), "g")
		# burun deliği
		var np: Vector3 = poll + hdir * hl * 0.985 + side * sx * mw * 0.42 + hup * md * 0.2
		_el(bs, [0], np, Vector3(mw * 0.16, mw * 0.12, mw * 0.08), Color("120e0c"), "g")
		if T.get("dudak", false):
			_el(bs, [0, 1], poll + hdir * hl * 0.97 + side * sx * mw * 0.45 - hup * md * 0.55, Vector3(mw * 0.55, md * 0.4, mw * 0.6), muz, "g")
	if T.get("sakal", false):
		_tb(bs, [0, 1], [_rg(poll + hdir * hl * 0.7 - hup * hdp * 0.7, 0.02, 0.015, coat.darkened(0.25)), _rg(poll + hdir * hl * 0.66 - hup * hdp * 1.5, 0.012, 0.01, coat.darkened(0.3))], "k", true, true)
	if yun > 0.0:
		_el(bs, [0, 1], poll + hdir * hl * 0.02 + hup * hdp * 0.55, Vector3(hw * 1.1, hdp * 0.7, hl * 0.28), coat, "k", Basis.IDENTITY, 0.08)
	if tur == "at":
		_el(bs, [0], poll + hdir * hl * 0.1 + hup * hdp * 0.95, Vector3(0.035, 0.03, 0.09), Color("2a2220") if coat.get_luminance() < 0.6 else coat.darkened(0.15), "k", Basis(Vector3.RIGHT, -ha))
	# boynuz
	if T.has("boynuz"):
		var bt: Array = T["boynuz"]
		var bl: float = bt[1]
		var br: float = bt[2]
		var hc := Color("e6dcc4") if bt[0] == "okuz" else (Color("4a4440") if bt[0] == "manda" else Color("8a7a62"))
		for sx: float in [-1.0, 1.0]:
			var r0 := poll + hdir * hl * 0.06 + hup * hdp * 0.7 + side * sx * hw * 0.62
			var pts: Array = []
			match bt[0]:
				"okuz":         # lir biçimi: yana, sonra yukarı ve öne
					pts = [r0, r0 + Vector3(sx * bl * 0.45, bl * 0.05, -bl * 0.05), r0 + Vector3(sx * bl * 0.75, bl * 0.35, 0.0), r0 + Vector3(sx * bl * 0.78, bl * 0.65, bl * 0.18)]
				"manda":        # yassı, geriye ve yana kıvrık hilal
					pts = [r0, r0 + Vector3(sx * bl * 0.4, -bl * 0.02, -bl * 0.15), r0 + Vector3(sx * bl * 0.7, bl * 0.08, -bl * 0.45), r0 + Vector3(sx * bl * 0.55, bl * 0.25, -bl * 0.75)]
				_:              # keçi: yukarı ve geriye kıvrık
					pts = [r0, r0 + Vector3(sx * bl * 0.1, bl * 0.4, -bl * 0.15), r0 + Vector3(sx * bl * 0.18, bl * 0.65, -bl * 0.5), r0 + Vector3(sx * bl * 0.22, bl * 0.6, -bl * 0.85)]
			var hrr: Array = []
			for i in pts.size():
				var tt := float(i) / (pts.size() - 1)
				var rr := br * (1.0 - tt * 0.82)
				hrr.append(_rg(pts[i], rr * (1.5 if bt[0] == "manda" else 1.0), rr, hc.darkened(0.35 * tt * tt) if bt[0] == "okuz" else hc))
			_tb(bs, [0, 1], hrr, "k", false, true)
	# kulaklar (ayrı parça: oynar)
	var kl: Array = T["kulak"]
	for sx: float in [-1.0, 1.0]:
		var kad := "kulak_l" if sx < 0.0 else "kulak_r"
		var kb := poll + hdir * hl * 0.02 + hup * hdp * 0.45 + side * sx * hw * 0.62
		var kdir: Vector3
		match kl[0]:
			"dik":
				kdir = (Vector3(sx * 0.25, 1.0, 0.25)).normalized()
			"uzun":
				kdir = (Vector3(sx * 0.35, 1.0, -0.05)).normalized()
			"sark":
				kdir = (Vector3(sx * 1.0, -0.45, 0.1)).normalized()
				kb = poll + hdir * hl * 0.06 + hup * hdp * 0.2 + side * sx * hw * 0.8
			"kopek":
				kdir = (Vector3(sx * 0.45, 1.0, 0.1)).normalized()
			"kedi":
				kdir = (Vector3(sx * 0.4, 1.0, 0.05)).normalized()
			"kucuk":
				kdir = (Vector3(sx * 0.7, 0.7, -0.2)).normalized()
			_:
				kdir = (Vector3(sx * 1.0, 0.1, -0.15)).normalized()
				kb = poll + hdir * hl * 0.08 + hup * hdp * 0.3 + side * sx * hw * 0.85
		var kk := _p(parts, kad, "bas", kb)
		var klen: float = kl[1]
		var kw: float = kl[2]
		var kc := bas_renk.darkened(0.05)
		var pointy: bool = kl[0] in ["dik", "kopek", "kedi", "uzun"]
		var kr: Array = [_rg(kb, kw * 0.35, kw * 0.6, kc), _rg(kb + kdir * klen * 0.45, kw * 0.3, kw, kc), _rg(kb + kdir * klen * (0.85 if pointy else 0.9), kw * 0.2, kw * (0.45 if pointy else 0.8), kc)]
		_tb(kk, [0, 1], kr, "k", true, true, 0.6, 0.0, [], Vector3.BACK if absf(kdir.x) < 0.8 else Vector3.UP)
	# --- kuyruk
	var ky: Array = T["kuyruk"]
	var kyb := Vector3(0, H * 0.93, -L * 0.53)
	var kt := _p(parts, "kuyruk", "govde", kyb)
	var klen2: float = ky[1]
	var kr2: float = ky[2]
	var kpts: Array = []
	var kcol := coat.darkened(0.1)
	match ky[0]:
		"kil":
			var mcol := Color("2a2220") if coat.get_luminance() < 0.6 else coat.darkened(0.12)
			if tur == "at" and coat.get_luminance() > 0.5 and coat.get_luminance() < 0.6:
				mcol = coat.darkened(0.4)
			kpts = [_rg(kyb, kr2 * 0.5, kr2 * 0.6, coat), _rg(kyb + Vector3(0, -0.06, -0.12), kr2 * 0.8, kr2, mcol), _rg(kyb + Vector3(0, -klen2 * 0.4, -0.2), kr2 * 1.05, kr2 * 1.2, mcol), _rg(kyb + Vector3(0, -klen2 * 0.75, -0.18), kr2 * 0.9, kr2 * 1.0, mcol), _rg(kyb + Vector3(0, -klen2, -0.12), kr2 * 0.4, kr2 * 0.4, mcol)]
		"yag":
			kpts = [_rg(kyb + Vector3(0, -0.02, 0.02), kr2 * 0.6, kr2 * 0.6, coat), _rg(kyb + Vector3(0, -klen2 * 0.5, -0.06), kr2, kr2 * 0.9, coat), _rg(kyb + Vector3(0, -klen2, -0.05), kr2 * 0.6, kr2 * 0.5, coat)]
		"kalkik":
			kpts = [_rg(kyb, kr2, kr2, coat), _rg(kyb + Vector3(0, klen2 * 0.35, -klen2 * 0.35), kr2 * 0.9, kr2 * 0.9, coat), _rg(kyb + Vector3(0, klen2 * 0.75, -klen2 * 0.45), kr2 * 0.7, kr2 * 0.7, coat), _rg(kyb + Vector3(0, klen2 * 0.95, -klen2 * 0.3), kr2 * 0.3, kr2 * 0.3, coat.lightened(0.1))]
		"kedi":
			kpts = [_rg(kyb, kr2, kr2, coat), _rg(kyb + Vector3(0, -klen2 * 0.2, -klen2 * 0.35), kr2, kr2, coat), _rg(kyb + Vector3(0, -klen2 * 0.05, -klen2 * 0.7), kr2, kr2, coat), _rg(kyb + Vector3(0, klen2 * 0.25, -klen2 * 0.85), kr2 * 0.6, kr2 * 0.6, coat.darkened(0.2))]
		"kisa":
			kpts = [_rg(kyb, kr2, kr2, coat), _rg(kyb + Vector3(0, klen2 * 0.5, -klen2 * 0.6), kr2 * 0.8, kr2, coat), _rg(kyb + Vector3(0, klen2 * 0.7, -klen2), kr2 * 0.3, kr2 * 0.4, coat.darkened(0.2))]
		_:   # püsküllü (sığır, deve, eşek)
			kpts = [_rg(kyb, kr2 * 1.5, kr2 * 1.6, coat), _rg(kyb + Vector3(0, -klen2 * 0.25, -0.06), kr2, kr2, kcol), _rg(kyb + Vector3(0, -klen2 * 0.7, -0.07), kr2 * 0.75, kr2 * 0.75, kcol), _rg(kyb + Vector3(0, -klen2 * 0.82, -0.065), kr2 * 1.7, kr2 * 1.9, Color("2a2420") if coat.get_luminance() > 0.25 else coat.darkened(0.3)), _rg(kyb + Vector3(0, -klen2, -0.06), kr2 * 0.6, kr2 * 0.7, Color("2a2420"))]
	_tb(kt, [0, 1], kpts, "k", false, true)
	# --- bacaklar
	var lr: float = T["leg"]
	var hoof: Color = T["toynak"]
	var bacak_renk: Color = T.get("bacak_renk", coat)
	var alt_renk := bacak_renk.darkened(0.08) if not T.get("bacak_koyu", false) else bacak_renk.lerp(Color("2a2220"), 0.55)
	if coat.get_luminance() < 0.25:
		alt_renk = bacak_renk.darkened(0.15)
	var belly := H - D * 1.02
	var pati: bool = T.get("pati", false)
	var ince: bool = T.get("ince_bacak", false)
	for i in 4:
		var on := i < 2
		var sx := -1.0 if i % 2 == 0 else 1.0
		var z := L * (0.36 if on else -0.36)
		var x := sx * W * (0.55 if on else 0.6)
		var pv := Vector3(x, H - D * (0.45 if on else 0.4), z)
		var ust := _p(parts, "b%d" % i, "govde", pv)
		var knee_y := belly * (0.44 if on else 0.47)
		var kz := z + (0.0 if on else -L * 0.07)
		var knee := Vector3(x, knee_y, kz)
		var ur: Array = []
		if on:
			ur = [_rg(pv, lr * 1.5, lr * 1.9, coat), _rg(Vector3(x, belly + 0.02, z + 0.01), lr * 1.15, lr * 1.35, bacak_renk),
				_rg(Vector3(x, lerpf(belly, knee_y, 0.6), z), lr * (0.75 if ince else 0.85), lr * 0.95, bacak_renk), _rg(knee, lr * 0.78, lr * 0.85, bacak_renk)]
		else:
			ur = [_rg(pv, lr * 1.8, lr * 2.3, coat), _rg(Vector3(x, belly - 0.01, z + L * 0.05), lr * 1.25, lr * 1.6, bacak_renk),
				_rg(Vector3(x, lerpf(belly, knee_y, 0.55), z - L * 0.02), lr * 0.85, lr * 1.0, bacak_renk), _rg(knee, lr * 0.68, lr * 0.85, bacak_renk)]
		_tb(ust, [0, 1], ur, "l", false, false)
		# uzak katman: tek parça bacak (omuzdan yere)
		_tb(ust, [2], [_rg(Vector3(x, belly + 0.08, z), lr * 1.1, lr * 1.2, bacak_renk), _rg(Vector3(x, 0.0, z), lr * 0.6, lr * 0.6, alt_renk)], "l", false, false)
		var alt := _p(parts, "d%d" % i, "b%d" % i, knee)
		var fz := z + (0.0 if on else -L * 0.04)
		var fet := maxf(0.06, H * 0.075)
		var dr: Array = [_rg(knee + Vector3(0, -0.005, 0), lr * (0.74 if on else 0.66), lr * 0.8, bacak_renk),
			_rg(Vector3(x, lerpf(knee_y, fet, 0.5), (kz + fz) * 0.5), lr * 0.55, lr * 0.62, bacak_renk.lerp(alt_renk, 0.3)),
			_rg(Vector3(x, fet, fz), lr * 0.62, lr * 0.66, alt_renk)]
		if pati:
			_tb(alt, [0, 1], dr, "l", false, false)
			_el(alt, [0, 1], Vector3(x, lr * 0.55, fz + lr * 0.5), Vector3(lr * 0.85, lr * 0.55, lr * 1.25), alt_renk, "k")
		else:
			dr.append(_rg(Vector3(x, fet * 0.6, fz + 0.01), lr * 0.6, lr * 0.62, alt_renk))
			dr.append(_rg(Vector3(x, fet * 0.6, fz + 0.01), lr * 0.6, lr * 0.62, hoof))
			dr.append(_rg(Vector3(x, 0.004, fz + lr * 0.25), lr * 0.78, lr * 0.85, hoof))
			_tb(alt, [0, 1], dr, "l", false, true, 0.5)
		if T.get("nasir", false) and on:
			_el(alt, [0], knee + Vector3(0, 0, lr * 0.55), Vector3(lr * 0.7, lr * 0.75, lr * 0.4), coat.darkened(0.25), "k")
	# --- koşum takımı (ayrı parçalar; gövdeye/boyna bağlı)
	for tk in takim:
		match tk:
			"boyunduruk":
				var yb := (npts[1] as Vector3) + Vector3(0, nr0.y * 0.62 + 0.03, 0.06)
				_tb(bn, [0, 1, 2], [_rg(yb + Vector3(-0.55, 0, 0), 0.06, 0.065, Color("6e4a2c")), _rg(yb + Vector3(0, 0.04, 0), 0.075, 0.08, Color("7a5634")), _rg(yb + Vector3(0.55, 0, 0), 0.06, 0.065, Color("6e4a2c"))], "k", true, true, 0.5, 0.0, [], Vector3.BACK)
				for sx: float in [-1.0, 1.0]:      # boyun kavisi (çatal)
					var lp: Array = []
					for k in 4:
						var a := PI * (0.5 + k / 3.0 * 0.5) if sx < 0 else PI * (0.5 - k / 3.0 * 0.5)
						lp.append(_rg((npts[1] as Vector3) + Vector3(cos(a) * (nr0.x + 0.04), sin(a) * 0.05 - (1.0 - sin(a)) * nr0.y * 1.1 + nr0.y * 0.7, 0.02), 0.022, 0.022, Color("5e4228")))
					_tb(bn, [0], lp, "k", false, false, 0.5)
			"yular":
				var hcol := Color("4a2a18")
				for tt: float in [0.82, 0.12]:
					var c0 := poll + hdir * hl * tt
					var rx: float = (mw if tt > 0.5 else hw) * 1.08
					var ry: float = (md if tt > 0.5 else hdp) * 1.06
					var lp2: Array = []
					for k in 9:
						var a := TAU * k / 8.0
						lp2.append(_rg(c0 + side * cos(a) * rx + hup * sin(a) * ry, 0.014, 0.014, hcol))
					_tb(bs, [0], lp2, "k", false, false, 0.3)
			"semer", "yuk", "cul":
				var sc := Color("8a3a2a") if tk == "semer" else (Color("7a3a3a") if tk == "cul" else Color("6a4a2c"))
				if opt.has("cul_renk") and tk == "cul":
					sc = opt["cul_renk"]
				var ss: Array = []
				for i in range(2, 7):
					var r: Array = rings[i]
					ss.append([(r[0] as Vector3), float(r[1]) * 1.06 + 0.012, float(r[2]) * 1.05 + 0.012, float(r[2]) * 1.05, sc])
				_tb(g, [0, 1], ss, "b", false, false, 0.6, 0.0, [-0.35, PI + 0.35])
				if tk == "yuk":
					for sx: float in [-1.0, 1.0]:
						_el(g, [0, 1, 2], Vector3(sx * (W + 0.14), H - D * 0.35, 0.0), Vector3(0.16, 0.24, 0.32), Color("b8a070").darkened(0.1 * (sx + 1.0)), "k", Basis.IDENTITY, 0.06)
					_el(g, [0, 1], Vector3(0, H + 0.12, -0.05), Vector3(W * 0.9, 0.12, 0.3), Color("c8ac5c"), "k", Basis.IDENTITY, 0.05)
				elif tk == "semer":
					_el(g, [0, 1, 2], Vector3(0, H * 1.005 + 0.06, L * 0.0), Vector3(W * 0.75, 0.1, L * 0.2), Color("5a3a22"), "k")
			"eyer":
				_el(g, [0, 1, 2], Vector3(0, H * 0.97 + 0.07, L * 0.05), Vector3(W * 0.62, 0.08, L * 0.17), Color("5a2a18"), "k")
				_el(g, [0], Vector3(0, H * 0.97 + 0.13, L * 0.17), Vector3(W * 0.42, 0.08, 0.05), Color("5a2a18"), "k")
	return parts


# ================================================================ kuşlar

static func _kus(tur: String, opt: Dictionary) -> Dictionary:
	var parts := {}
	var g := _p(parts, "govde", "", Vector3.ZERO)
	if tur == "tavuk":
		var c: Color = opt.get("renk", Color("f6f2e8"))
		var dark := c.darkened(0.2)
		_tb(g, [0, 1, 2], [_rg(Vector3(0, 0.3, -0.17), 0.05, 0.05, c), _rg(Vector3(0, 0.27, -0.09), 0.11, 0.11, c), _rg(Vector3(0, 0.25, 0.02), 0.13, 0.12, c, 0.13),
			_rg(Vector3(0, 0.27, 0.11), 0.1, 0.11, c), _rg(Vector3(0, 0.36, 0.15), 0.06, 0.06, c), _rg(Vector3(0, 0.42, 0.14), 0.05, 0.05, c)], "b", true, false)
		# kuyruk tüyü (yelpaze)
		_tb(g, [0, 1], [_rg(Vector3(0, 0.3, -0.15), 0.035, 0.05, c), _rg(Vector3(0, 0.38, -0.22), 0.03, 0.08, dark), _rg(Vector3(0, 0.46, -0.24), 0.015, 0.05, dark)], "k", false, true, 0.6, 0.0, [], Vector3.RIGHT)
		for sx: float in [-1.0, 1.0]:
			_tb(g, [0, 1, 2], [_rg(Vector3(sx * 0.05, 0.16, 0.02), 0.012, 0.012, Color("e0a020")), _rg(Vector3(sx * 0.05, 0.005, 0.03), 0.01, 0.01, Color("e0a020"))], "k", false, false)
			for k in 3:
				_tb(g, [0], [_rg(Vector3(sx * 0.05, 0.006, 0.03), 0.006, 0.005, Color("e0a020")), _rg(Vector3(sx * 0.05 + (k - 1) * 0.03, 0.006, 0.09), 0.004, 0.004, Color("e0a020"))], "k", false, true)
			var w := _p(parts, "kanat_l" if sx < 0 else "kanat_r", "govde", Vector3(sx * 0.12, 0.29, 0.02))
			_el(w, [0, 1], Vector3(sx * 0.125, 0.26, -0.01), Vector3(0.03, 0.08, 0.13), c.darkened(0.06), "k", Basis(Vector3.RIGHT, 0.25))
		var h := _p(parts, "bas", "govde", Vector3(0, 0.42, 0.14))
		_el(h, [0, 1, 2], Vector3(0, 0.44, 0.15), Vector3(0.05, 0.055, 0.06), c, "k")
		_tb(h, [0, 1, 2], [_rg(Vector3(0, 0.435, 0.2), 0.018, 0.014, Color("e0a020")), _rg(Vector3(0, 0.425, 0.24), 0.003, 0.003, Color("e0a020"))], "k", false, true)
		_tb(h, [0, 1], [_rg(Vector3(0, 0.49, 0.11), 0.01, 0.02, Color("d8262d")), _rg(Vector3(0, 0.515, 0.15), 0.012, 0.03, Color("d8262d")), _rg(Vector3(0, 0.495, 0.19), 0.008, 0.015, Color("d8262d"))], "k", true, true, 0.4, 0.0, [], Vector3.RIGHT)
		_el(h, [0, 1], Vector3(0, 0.39, 0.18), Vector3(0.012, 0.025, 0.015), Color("d8262d"), "k")
		for sx: float in [-1.0, 1.0]:
			_el(h, [0], Vector3(sx * 0.043, 0.45, 0.17), Vector3(0.01, 0.01, 0.01), Color("141414"), "k")
		return parts
	# martı / güvercin (başı +z; kanat pivotu omuzda)
	var guv := tur == "guvercin"
	var c2: Color = opt.get("renk", Color("f4f2ec") if not guv else Color("8a8e98"))
	var wing := Color("9aa4ae") if not guv else Color("6a6e78")
	var tip := Color("2a2a2e") if not guv else Color("4a4c56")
	var bk := Color("f0c030") if not guv else Color("3a3430")
	_tb(g, [0, 1, 2], [_rg(Vector3(0, 0.23, -0.3), 0.04, 0.025, wing), _rg(Vector3(0, 0.22, -0.18), 0.1, 0.09, c2), _rg(Vector3(0, 0.22, -0.02), 0.14, 0.13, c2, 0.15),
		_rg(Vector3(0, 0.24, 0.14), 0.11, 0.12, c2), _rg(Vector3(0, 0.3, 0.22), 0.07, 0.075, c2)], "b", false, false)
	_tb(g, [0, 1, 2], [_rg(Vector3(0, 0.23, -0.29), 0.05, 0.012, wing), _rg(Vector3(0, 0.22, -0.4), 0.07, 0.01, tip), _rg(Vector3(0, 0.22, -0.44), 0.05, 0.006, tip)], "k", false, true, 0.4, 0.0, [], Vector3.RIGHT)
	for sx: float in [-1.0, 1.0]:
		_tb(g, [0, 1], [_rg(Vector3(sx * 0.06, 0.12, 0.02), 0.012, 0.012, Color("e8a040")), _rg(Vector3(sx * 0.06, 0.005, 0.03), 0.01, 0.01, Color("e8a040"))], "k", false, false)
		_el(g, [0], Vector3(sx * 0.06, 0.006, 0.07), Vector3(0.035, 0.006, 0.045), Color("e8a040"), "k")
		var w2 := _p(parts, "kanat_l" if sx < 0 else "kanat_r", "govde", Vector3(sx * 0.1, 0.27, 0.0))
		# kanat: omuzdan uca yassı, sivrilen tüp (kiriş z, kalınlık y), uçta koyu
		_tb(w2, [0, 1, 2], [_rg(Vector3(sx * 0.1, 0.27, 0.0), 0.11, 0.018, wing), _rg(Vector3(sx * 0.3, 0.275, -0.02), 0.1, 0.014, wing),
			_rg(Vector3(sx * 0.47, 0.275, -0.05), 0.075, 0.011, wing), _rg(Vector3(sx * 0.5, 0.275, -0.06), 0.07, 0.01, tip), _rg(Vector3(sx * 0.66, 0.272, -0.1), 0.03, 0.006, tip)], "k", false, true, 0.3, 0.0, [], Vector3.BACK)
	var h2 := _p(parts, "bas", "govde", Vector3(0, 0.36, 0.2))
	_el(h2, [0, 1, 2], Vector3(0, 0.36, 0.25), Vector3(0.075, 0.08, 0.09), c2 if not guv else Color("5a6070"), "k")
	_tb(h2, [0, 1, 2], [_rg(Vector3(0, 0.35, 0.32), 0.02, 0.022, bk), _rg(Vector3(0, 0.345, 0.38), 0.014, 0.016, bk), _rg(Vector3(0, 0.335, 0.42), 0.004, 0.006, bk)], "k", false, true)
	if not guv:
		_el(h2, [0], Vector3(0, 0.335, 0.39), Vector3(0.01, 0.01, 0.01), Color("d83a2a"), "k")
	for sx: float in [-1.0, 1.0]:
		_el(h2, [0], Vector3(sx * 0.066, 0.375, 0.28), Vector3(0.012, 0.012, 0.012), Color("1a1a1a"), "k")
	return parts


# ================================================================ duruş

## Duruş: parça adı → Vector3 (euler, radyan); "_govde_y": gövde inişi. adim: yürüyüş evresi (0..1).
static func poz(tur: String, ad: String, opt := {}) -> Dictionary:
	var r := {}
	var yaw := deg_to_rad(float(opt.get("bas_yaw", 0.0)))
	var kus := tur in ["tavuk", "marti", "guvercin"]
	if kus:
		if ad == "uc":
			r["kanat_l"] = Vector3(0, 0, 0.25)
			r["kanat_r"] = Vector3(0, 0, -0.25)
		elif tur != "tavuk":
			r["kanat_l"] = Vector3(0, -1.3, 0.1)
			r["kanat_r"] = Vector3(0, 1.3, -0.1)
		if ad == "otla":
			r["bas"] = Vector3(0.7, 0, 0)
		return r
	var T := tanim(tur)
	var H: float = T["H"]
	var D: float = T["D"]
	match ad:
		"otla":
			r["boyun"] = Vector3(deg_to_rad(55.0 if tur != "deve" else 40.0), yaw * 0.3, 0)
			r["bas"] = Vector3(deg_to_rad(20.0), 0, 0)
			r["b0"] = Vector3(-0.08, 0, 0)
		"yat":
			var drop := H - D * 1.02 - 0.06
			r["_govde_y"] = -drop
			for i in 4:
				if i < 2:
					r["b%d" % i] = Vector3(-1.35, 0, 0)
					r["d%d" % i] = Vector3(2.75, 0, 0)
				else:
					r["b%d" % i] = Vector3(-1.2, 0, (0.25 if i == 2 else -0.25))
					r["d%d" % i] = Vector3(2.55, 0, 0)
			r["boyun"] = Vector3(deg_to_rad(-8.0 if tur != "deve" else 6.0), yaw, 0)
			r["kuyruk"] = Vector3(0.6, 0, 0.3)
		"yuru":
			var ph := TAU * float(opt.get("adim", 0.25))
			var a := sin(ph) * 0.38
			r["b0"] = Vector3(a, 0, 0)
			r["b3"] = Vector3(a, 0, 0)
			r["b1"] = Vector3(-a, 0, 0)
			r["b2"] = Vector3(-a, 0, 0)
			r["d0"] = Vector3(maxf(0.0, -a) * 1.2, 0, 0)
			r["d1"] = Vector3(maxf(0.0, a) * 1.2, 0, 0)
			r["d2"] = Vector3(-maxf(0.0, a) * 0.6, 0, 0)
			r["d3"] = Vector3(-maxf(0.0, -a) * 0.6, 0, 0)
			r["boyun"] = Vector3(0.05, yaw, 0)
			r["kuyruk"] = Vector3(0.08, 0, 0.1)
		_:
			r["boyun"] = Vector3(0, yaw, 0)
			r["kuyruk"] = Vector3(0.05, 0, float(opt.get("tohum", 0) % 5 - 2) * 0.08)
			r["kulak_l"] = Vector3(0, 0, 0.15 * float(opt.get("tohum", 0) % 3 - 1))
	return r


# ================================================================ çıktılar

static func _sk_seg(sk: String, lod: int) -> int:
	match sk:
		"l":
			return SEG_L[lod]
		"k":
			return SEG_K[lod]
		"n", "h":
			return [10, 5, 4][lod]
		"g":
			return [6, 3, 3][lod]
	return SEG[lod]


static func _parca_acc(prt: Dictionary, lod: int) -> Acc:
	var acc := Acc.new()
	for gg: Array in prt["g"]:
		if not (gg[0] as Array).has(lod):
			continue
		if gg[1] == "t":
			var rings: Array = gg[2]
			var hk: int = (HALKA.get(gg[3], [99, 3, 2]) as Array)[lod]
			if rings.size() > hk:
				var sec: Array = []
				for i in hk:
					sec.append(rings[roundi(float(i) * (rings.size() - 1) / (hk - 1))])
				rings = sec
			_tube(acc, rings, _sk_seg(gg[3], lod), gg[4], gg[5], gg[6], gg[8], gg[7] if lod == 0 else 0.0, gg[9])
		else:
			_ell(acc, gg[2], gg[3], gg[4], _sk_seg(gg[5], lod), gg[6], 1.0, gg[7] if lod == 0 else 0.0)
	return acc


## Parçanın dünya (model) dönüşümü: ebeveyn · T(pv) · R · T(−pv)
static func _xf(parts: Dictionary, ad: String, pz: Dictionary, memo: Dictionary) -> Transform3D:
	if memo.has(ad):
		return memo[ad]
	var p: Dictionary = parts[ad]
	var ust: String = p["ust"]
	var base := Transform3D.IDENTITY if ust == "" else _xf(parts, ust, pz, memo)
	var pv: Vector3 = p["pv"]
	var rot: Vector3 = pz.get(ad, Vector3.ZERO)
	var loc := Transform3D(Basis.from_euler(rot), Vector3.ZERO)
	var t := Transform3D(Basis.IDENTITY, pv) * loc * Transform3D(Basis.IDENTITY, -pv)
	if ust == "":
		t = Transform3D(Basis.IDENTITY, Vector3(0, float(pz.get("_govde_y", 0.0)), 0)) * t
	var out := base * t
	memo[ad] = out
	return out


## Durağan birleşik ağ birikimcisi (model uzayı)
static func birikim(tur: String, lod: int, opt := {}) -> Acc:
	var parts := parcalar(tur, opt)
	var pz := poz(tur, String(opt.get("poz", "dur")), opt)
	var memo := {}
	var acc := Acc.new()
	for ad: String in parts:
		var a := _parca_acc(parts[ad], lod)
		acc.add(a, _xf(parts, ad, pz, memo))
	return acc


static var _acc_cache := {}

## Önbellekli birikim (ordugâh: aynı tür/duruş/renk basamağı bir kez örülür, sonra yalnız dönüşümle eklenir)
static func birikim_ob(tur: String, lod: int, opt := {}) -> Acc:
	var o := opt.duplicate()
	if o.has("renk"):
		var c: Color = o["renk"]
		o["renk"] = Color(snappedf(c.r, 1.0 / 20.0), snappedf(c.g, 1.0 / 20.0), snappedf(c.b, 1.0 / 20.0))
	o["bas_yaw"] = snappedf(float(o.get("bas_yaw", 0.0)), 15.0)
	o["adim"] = snappedf(float(o.get("adim", 0.0)), 0.125)
	var k := _anahtar(tur, lod, o) + "|%d" % (int(o.get("tohum", 0)) % 6)
	if _acc_cache.has(k):
		return _acc_cache[k]
	if _acc_cache.size() > 600:
		_acc_cache.clear()
	var a := birikim(tur, lod, o)
	_acc_cache[k] = a
	return a


static func _anahtar(tur: String, lod: int, opt: Dictionary) -> String:
	return "%s|%d|%s|%s|%s|%s|%s" % [tur, lod, opt.get("renk", Color(0, 0, 0, 0)).to_html(), opt.get("poz", "dur"), opt.get("bas_yaw", 0.0), opt.get("takim", []), opt.get("adim", 0.0)]


static func mesh(tur: String, lod := 1, opt := {}) -> ArrayMesh:
	var k := _anahtar(tur, lod, opt) + "|%d" % int(opt.get("tohum", 0))
	if _mesh_cache.has(k):
		return _mesh_cache[k]
	var m := birikim(tur, lod, opt).mesh()
	_mesh_cache[k] = m
	return m


static func ucgen(tur: String, lod: int, opt := {}) -> int:
	return birikim(tur, lod, opt).tris()


## Oyunun toon malzemesi, köşe rengiyle (dış hat dahil)
static func mat() -> StandardMaterial3D:
	if _mat == null:
		_mat = Props.mat(Color.WHITE).duplicate() as StandardMaterial3D
		_mat.vertex_color_use_as_albedo = true
		_mat.cull_mode = BaseMaterial3D.CULL_BACK
	return _mat


static var _mat_ordu: StandardMaterial3D

## Ordugâhın Bld malzemesiyle aynı ton (albedo 0,78 çarpanı): canlı çevresindeki çadır/ahşaptan parlak durmasın
static func mat_ordu() -> StandardMaterial3D:
	if _mat_ordu == null:
		_mat_ordu = mat().duplicate() as StandardMaterial3D
		_mat_ordu.albedo_color = Color(0.8, 0.79, 0.76)
	return _mat_ordu


## Eklemli düğüm ağacı (yakın katman). Her parça bir Node3D (pivotunda) + MeshInstance3D (köşe renkli ağ).
## Döndürür {"root", "p": {ad: Node3D}}. opt.lod (varsayılan 0). opt.birlestir: ["kulak"] → kulaklar başa pişer.
static func dugum(tur: String, opt := {}) -> Dictionary:
	var lod: int = int(opt.get("lod", 0))
	var parts := parcalar(tur, opt)
	var root := Node3D.new()
	root.name = "Canli_%s" % tur
	var nodes := {}
	var birles: Array = opt.get("birlestir", [])
	var golge: bool = opt.get("golge", true)
	# önce bütün parça düğümleri
	for ad: String in parts:
		var p: Dictionary = parts[ad]
		var n := Node3D.new()
		n.name = ad
		nodes[ad] = n
	for ad: String in parts:
		var p: Dictionary = parts[ad]
		var ust: String = p["ust"]
		var n: Node3D = nodes[ad]
		var pv: Vector3 = p["pv"]
		if ust == "":
			root.add_child(n)
			n.position = pv
		else:
			(nodes[ust] as Node3D).add_child(n)
			n.position = pv - (parts[ust]["pv"] as Vector3)
	for ad: String in parts:
		var p: Dictionary = parts[ad]
		var acc := _parca_acc(p, lod)
		var hedef := ad
		for bb: String in birles:
			if ad.begins_with(bb):
				hedef = String(p["ust"])
		var pv: Vector3 = parts[hedef]["pv"]
		var a2 := Acc.new()
		a2.add(acc, Transform3D(Basis.IDENTITY, -pv))
		if a2.v.is_empty():
			continue
		var n: Node3D = nodes[hedef]
		var mi: MeshInstance3D = n.get_node_or_null("Ag") as MeshInstance3D
		if mi == null:
			mi = MeshInstance3D.new()
			mi.name = "Ag"
			mi.material_override = mat()
			mi.set_meta("canli_acc", a2)
			if not golge or ad.begins_with("kulak") or ad == "kuyruk":
				mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			n.add_child(mi)
		else:
			(mi.get_meta("canli_acc") as Acc).add(a2, Transform3D.IDENTITY)
	for ad: String in nodes:
		var mi: MeshInstance3D = (nodes[ad] as Node3D).get_node_or_null("Ag") as MeshInstance3D
		if mi:
			mi.mesh = (mi.get_meta("canli_acc") as Acc).mesh()
			mi.remove_meta("canli_acc")
	for ad: String in birles:
		for k: String in nodes.keys():
			if k.begins_with(ad):
				var n: Node3D = nodes[k]
				if n.get_child_count() == 0:
					n.get_parent().remove_child(n)
					n.free()
					nodes.erase(k)
	return {"root": root, "p": nodes}


## Ordugâhın Bld'sine (IstOrdugahKit.Bld) ekler: desensiz Bld'ye doğrudan (çizim eklenmez); desenli (ahşap) Bld'ye
## eklenen canlı ahşap dokusu almasın diye Bld'nin katı gövdesinin altına ayrı köşe renkli ağ (yakın + orta, görünürlük
## aralıklı: aynı anda biri çizilir). lod: −1 = desensizde orta, desenlide yakın/orta çifti.
static func bld_ekle(b: Object, tur: String, pos: Vector3, yaw_deg: float, opt := {}) -> void:
	var lod: int = int(opt.get("lod", -1))
	var xf := Transform3D(Basis(Vector3.UP, deg_to_rad(yaw_deg)), pos)
	var pattern: String = b.get("pattern")
	# yalnız ahşap desenli Bld ayrı ağ alır (ahşap dokusu canlıya geçmesin); öbürleri (düz, orta katmanın "rubble"
	# tek ağı) Bld'nin içine: çizim sayısı artmaz
	if pattern != "wood":
		# "rubble" deseni ordugâhın orta katman (lod ≥ 1, ≥ 120 m) tek ağıdır: orada uzak siluet yeter (bütçe)
		var L0 := lod if lod >= 0 else (2 if pattern == "rubble" else 1)
		var acc := birikim_ob(tur, L0, opt)
		var bv: PackedVector3Array = b.get("v")
		var bn: PackedVector3Array = b.get("n")
		var bc: PackedColorArray = b.get("c")
		# Bld malzemesinin albedo çarpanı (0,78) çevresiyle aynı tonu verir (oyun karesinde telafi parlak duruyordu)
		var k := 1.0
		var nb := xf.basis
		for i in acc.v.size():
			bv.append(xf * acc.v[i])
			bn.append((nb * acc.n[i]).normalized())
			var cc := acc.c[i]
			bc.append(Color(minf(cc.r * k, 1.0), minf(cc.g * k, 1.0), minf(cc.b * k, 1.0)))
		b.set("v", bv)
		b.set("n", bn)
		b.set("c", bc)
		b.set("tris", int(b.get("tris")) + acc.tris())
		return
	var body: Node3D = b.call("_body")
	var lods: Array = [0, 1] if lod < 0 else [lod]
	for L in lods:
		var nm := "Canli_l%d" % L
		var mi := body.get_node_or_null(nm) as MeshInstance3D
		if mi == null:
			mi = MeshInstance3D.new()
			mi.name = nm
			mi.material_override = mat_ordu()
			mi.set_meta("no_walk", true)
			mi.set_meta("canli_acc", Acc.new())
			if lods.size() > 1:
				if L == 0:
					mi.visibility_range_end = 32.0
				else:
					mi.visibility_range_begin = 32.0
					mi.visibility_range_end = 300.0
			if L > 0:
				mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			body.add_child(mi)
		var a: Acc = mi.get_meta("canli_acc")
		a.add(birikim_ob(tur, L, opt), xf)
		mi.mesh = a.mesh()
