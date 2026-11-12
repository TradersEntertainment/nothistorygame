class_name IstHayatMesh
extends RefCounted
## İstanbul v2 yaşam katmanı: düşük poligonlu figür ağları (köşe renkli; MeshKit ile).
## Köşe rengi alfa kodu (ist_insan.gdshader): 1,0 = gömlek/tunik rengi (örnek başına), 0,5 = başlık rengi, 0,25 = alet (mızrak/sopa),
## 0,0 = sabit renk (ten, çizme, boynuz …). İnsan yüzü −z'ye bakar, ayak y = 0, boy 1,7 m.

static var _c := {}


static func _am(k: MeshKit) -> ArrayMesh:
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, k.arrays())
	return am


static func _xf(p: Vector3) -> Transform3D:
	return Transform3D(Basis.IDENTITY, p)


static func _box(k: MeshKit, p: Vector3, s: Vector3, col: Color) -> void:
	k.box(_xf(p), s, col)


## Yakın insan: bacaklar, gövde (tunik), kollar, kafa, başlık ve alet (≈ 70 üçgen)
static func insan() -> ArrayMesh:
	if _c.has("insan"):
		return _c["insan"]
	var k := MeshKit.new()
	var hose := Color(0.2, 0.17, 0.14, 0.0)
	var skin := Color(0.86, 0.66, 0.52, 0.0)
	var tun := Color(1, 1, 1, 1.0)
	var cap := Color(1, 1, 1, 0.5)
	for sx: float in [-1.0, 1.0]:
		_box(k, Vector3(sx * 0.1, 0.4, 0), Vector3(0.14, 0.8, 0.17), hose)
		_box(k, Vector3(sx * 0.1, 0.04, -0.05), Vector3(0.15, 0.08, 0.27), Color(0.16, 0.11, 0.08, 0.0))   # çizme/pabuç
	_box(k, Vector3(0, 1.12, 0), Vector3(0.42, 0.62, 0.25), tun)
	_box(k, Vector3(0, 0.84, 0), Vector3(0.45, 0.2, 0.28), tun.darkened(0.12))    # tunik eteği
	for sx: float in [-1.0, 1.0]:
		_box(k, Vector3(sx * 0.28, 1.12, 0), Vector3(0.1, 0.56, 0.13), tun.darkened(0.06))
		_box(k, Vector3(sx * 0.28, 0.8, 0), Vector3(0.09, 0.1, 0.11), skin)       # el
	_box(k, Vector3(0, 1.52, 0), Vector3(0.2, 0.23, 0.2), skin)
	_box(k, Vector3(0, 1.68, 0.0), Vector3(0.25, 0.11, 0.25), cap)
	# alet: sağ elde uzun sap (mızrak/sopa; alet işareti yoksa gölgelendirici sıfıra çökertir)
	_box(k, Vector3(0.34, 1.05, -0.06), Vector3(0.04, 2.1, 0.04), Color(0.45, 0.32, 0.2, 0.25))
	_box(k, Vector3(0.34, 2.18, -0.06), Vector3(0.06, 0.2, 0.06), Color(0.7, 0.72, 0.75, 0.25))
	var m := _am(k)
	_c["insan"] = m
	return m


## Uzak insan: tek gövde + kafa (≈ 20 üçgen)
static func insan_uzak() -> ArrayMesh:
	if _c.has("insan_uzak"):
		return _c["insan_uzak"]
	var k := MeshKit.new()
	_box(k, Vector3(0, 0.55, 0), Vector3(0.3, 1.1, 0.22), Color(0.2, 0.17, 0.14, 0.0))
	_box(k, Vector3(0, 1.2, 0), Vector3(0.44, 0.7, 0.26), Color(1, 1, 1, 1.0))
	_box(k, Vector3(0, 1.6, 0), Vector3(0.24, 0.28, 0.24), Color(1, 1, 1, 0.5))
	var m := _am(k)
	_c["insan_uzak"] = m
	return m


## Dört ayaklı (eşek, at, keçi, köpek): yüzü −z, ayak y = 0, omuz ≈ 1,0 m, uzunluk 1,5 m
static func hayvan(yuklu := false) -> ArrayMesh:
	var key := "hayvan_y" if yuklu else "hayvan"
	if _c.has(key):
		return _c[key]
	var k := MeshKit.new()
	var body := Color(1, 1, 1, 1.0)
	var dark := Color(0.14, 0.11, 0.09, 0.0)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			_box(k, Vector3(sx * 0.14, 0.31, sz * 0.46), Vector3(0.1, 0.62, 0.1), body.darkened(0.15))
			_box(k, Vector3(sx * 0.14, 0.03, sz * 0.46), Vector3(0.11, 0.07, 0.12), dark)
	_box(k, Vector3(0, 0.84, 0.0), Vector3(0.42, 0.44, 1.0), body)
	_box(k, Vector3(0, 1.15, -0.5), Vector3(0.2, 0.46, 0.2), body.darkened(0.04))        # boyun
	_box(k, Vector3(0, 1.33, -0.68), Vector3(0.18, 0.2, 0.34), body.lightened(0.04))     # baş
	_box(k, Vector3(0, 1.26, -0.86), Vector3(0.14, 0.12, 0.1), Color(0.8, 0.72, 0.62, 0.0))   # burun
	for sx: float in [-1.0, 1.0]:
		_box(k, Vector3(sx * 0.06, 1.5, -0.6), Vector3(0.05, 0.18, 0.05), body.darkened(0.1))   # kulak
	_box(k, Vector3(0, 0.84, 0.56), Vector3(0.07, 0.34, 0.07), body.darkened(0.2))       # kuyruk
	if yuklu:
		# semer ve iki yanda çuval/küp (eşek yükü)
		_box(k, Vector3(0, 1.1, 0.0), Vector3(0.5, 0.06, 0.56), Color(0.6, 0.18, 0.15, 0.0))
		for sx: float in [-1.0, 1.0]:
			_box(k, Vector3(sx * 0.33, 1.0, 0.0), Vector3(0.24, 0.42, 0.5), Color(0.72, 0.62, 0.42, 0.0))
		_box(k, Vector3(0, 1.3, 0.05), Vector3(0.36, 0.3, 0.42), Color(0.55, 0.42, 0.26, 0.0))
	var m := _am(k)
	_c[key] = m
	return m


## Tavuk (≈ 0,35 m)
static func tavuk() -> ArrayMesh:
	if _c.has("tavuk"):
		return _c["tavuk"]
	var k := MeshKit.new()
	_box(k, Vector3(0, 0.2, 0), Vector3(0.16, 0.16, 0.26), Color(1, 1, 1, 1.0))
	_box(k, Vector3(0, 0.32, -0.12), Vector3(0.08, 0.16, 0.08), Color(1, 1, 1, 1.0))
	_box(k, Vector3(0, 0.42, -0.14), Vector3(0.05, 0.06, 0.05), Color(0.8, 0.12, 0.1, 0.0))
	_box(k, Vector3(0, 0.36, -0.19), Vector3(0.03, 0.03, 0.05), Color(0.9, 0.7, 0.2, 0.0))
	_box(k, Vector3(0, 0.3, 0.16), Vector3(0.04, 0.16, 0.1), Color(1, 1, 1, 1.0).darkened(0.25))
	_box(k, Vector3(0, 0.06, 0), Vector3(0.05, 0.12, 0.05), Color(0.8, 0.6, 0.2, 0.0))
	var m := _am(k)
	_c["tavuk"] = m
	return m


## Martı / güvercin (başı −z; Gulls'taki gibi dirsekten kırık kanat; x = ±0,06'dan öte kanat)
static func kus(guvercin := false) -> ArrayMesh:
	var key := "kus_g" if guvercin else "kus_m"
	if _c.has(key):
		return _c[key]
	var k := MeshKit.new()
	var white := Color(0.94, 0.94, 0.92) if not guvercin else Color(0.6, 0.62, 0.68)
	var wing := Color(0.9, 0.9, 0.92) if not guvercin else Color(0.5, 0.52, 0.58)
	var tip := Color(0.2, 0.2, 0.24) if not guvercin else Color(0.35, 0.36, 0.42)
	var g := Basis.from_scale(Vector3.ONE * 1.5)
	var xf := Transform3D(g, Vector3.ZERO)
	k.box(Transform3D(g, Vector3(0, 0, 0.02)), Vector3(0.13, 0.11, 0.4), white)
	k.box(Transform3D(g, Vector3(0, 0.02, -0.25)), Vector3(0.09, 0.09, 0.12), white if not guvercin else Color(0.35, 0.4, 0.5))
	k.box(Transform3D(g, Vector3(0, 0.0, -0.34)), Vector3(0.03, 0.03, 0.08), Color(0.95, 0.7, 0.2) if not guvercin else Color(0.3, 0.25, 0.2))
	k._quad(xf, Vector3(-0.06, 0.0, 0.2), Vector3(0.06, 0.0, 0.2), Vector3(0.1, 0.0, 0.42), Vector3(-0.1, 0.0, 0.42), wing.darkened(0.04))
	for sx: float in [-1.0, 1.0]:
		var wc := wing if sx < 0 else wing.darkened(0.08)
		k._quad(xf, Vector3(sx * 0.06, 0.0, -0.12), Vector3(sx * 0.5, 0.07, -0.1), Vector3(sx * 0.5, 0.07, 0.1), Vector3(sx * 0.06, 0.0, 0.16), wc)
		k._tri(xf, Vector3(sx * 0.5, 0.07, -0.1), Vector3(sx * 0.82, 0.04, 0.16), Vector3(sx * 0.5, 0.07, 0.1), wc)
		k._tri(xf, Vector3(sx * 0.7, 0.05, 0.04), Vector3(sx * 1.0, 0.03, 0.3), Vector3(sx * 0.82, 0.04, 0.16), tip)
		# alt yüz (aşağıdan da görünsün)
		k._quad(xf, Vector3(sx * 0.06, -0.001, 0.16), Vector3(sx * 0.5, 0.069, 0.1), Vector3(sx * 0.5, 0.069, -0.1), Vector3(sx * 0.06, -0.001, -0.12), wc.darkened(0.1))
	var m := _am(k)
	_c[key] = m
	return m


## Duman/buhar dörtgeni (kameraya döner; ölçek örnek dönüşümünde)
static func puf() -> QuadMesh:
	if _c.has("puf"):
		return _c["puf"]
	var q := QuadMesh.new()
	q.size = Vector2(1, 1)
	_c["puf"] = q
	return q


## Bez (sancak/çamaşır): üst kenarı y = 0, aşağı doğru −1; x ∈ [−0,5, 0,5]; 8 × 4 bölmeli (dalga için)
static func bez() -> ArrayMesh:
	if _c.has("bez"):
		return _c["bez"]
	var nx := 8
	var ny := 4
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var uv := PackedVector2Array()
	var idx := PackedInt32Array()
	for j in ny + 1:
		for i in nx + 1:
			var u := float(i) / nx
			var w := float(j) / ny
			v.append(Vector3(u - 0.5, -w, 0))
			n.append(Vector3(0, 0, 1))
			uv.append(Vector2(u, w))
	for j in ny:
		for i in nx:
			var a := j * (nx + 1) + i
			var b := a + 1
			var c := a + nx + 1
			var d := c + 1
			idx.append_array([a, c, b, b, c, d])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_NORMAL] = n
	arr[Mesh.ARRAY_TEX_UV] = uv
	arr[Mesh.ARRAY_INDEX] = idx
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	_c["bez"] = am
	return am


## Birim kutu (merkezli, 1 m³; beyaz köşe rengi; örnek rengi boyar): baca, direk, ip, kasa
static func kutu() -> ArrayMesh:
	if _c.has("kutu"):
		return _c["kutu"]
	var k := MeshKit.new()
	_box(k, Vector3.ZERO, Vector3.ONE, Color.WHITE)
	var m := _am(k)
	_c["kutu"] = m
	return m


## Otağ/çadır: kare gövde + dört yüzlü piramit çatı (yerde y = 0; taban 4 × 4, duvar 1,5, tepe 3,4 m); ucuz (≈ 18 üçgen)
static func cadir() -> ArrayMesh:
	if _c.has("cadir"):
		return _c["cadir"]
	var k := MeshKit.new()
	var w := Color(1, 1, 1)
	_box(k, Vector3(0, 0.75, 0), Vector3(4.0, 1.5, 4.0), w)
	var xf := Transform3D.IDENTITY
	var t := Vector3(0, 3.4, 0)
	var p0 := Vector3(-2.2, 1.5, -2.2)
	var p1 := Vector3(2.2, 1.5, -2.2)
	var p2 := Vector3(2.2, 1.5, 2.2)
	var p3 := Vector3(-2.2, 1.5, 2.2)
	k._tri(xf, p3, p2, t, w.darkened(0.04))
	k._tri(xf, p2, p1, t, w.darkened(0.12))
	k._tri(xf, p1, p0, t, w.darkened(0.02))
	k._tri(xf, p0, p3, t, w.darkened(0.14))
	_box(k, Vector3(0, 3.55, 0), Vector3(0.1, 0.6, 0.1), Color(0.8, 0.65, 0.2))
	var m := _am(k)
	_c["cadir"] = m
	return m
