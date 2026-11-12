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


## Dört ayaklı (eşek, at, keçi, köpek): yüzü −z, ayak y = 0, omuz ≈ 1,0 m, uzunluk 1,5 m.
## CANLI (kalite notu 32): canli_kit eşeği (orta katman, kesit halkalı gövde, uzun kulak, eklemli bacak); kutu yok.
## Köşe rengi alfa kodu korunur: post (açık gri) alfa 1 = örnek rengi × parlaklık; toynak, burun, yük alfa 0 (sabit).
## Gölgelendirici kuralları korunur: bacak y < 0,64 (0,62'den döner), baş z < −0,4 ve y > 0,9 (otlarken iner).
static func hayvan(yuklu := false) -> ArrayMesh:
	var key := "hayvan_y" if yuklu else "hayvan"
	if _c.has(key):
		return _c[key]
	var m := _canli("esek", 1, {"renk": Color(0.9, 0.9, 0.9), "takim": ["yuk"] if yuklu else [], "H": 1.0}, 1.0, 0.0, true)
	_c[key] = m
	return m


## Tavuk (≈ 0,35 m)
static func tavuk() -> ArrayMesh:
	if _c.has("tavuk"):
		return _c["tavuk"]
	var m := _canli("tavuk", 1, {"renk": Color(0.95, 0.95, 0.95)}, 0.85, 0.0, true)
	_c["tavuk"] = m
	return m


## Martı / güvercin (başı −z; kanatlar açık, uçuşta; ist_kus kanadı |x| ile çırpar). Uzak katman siluet (≤ 90 üçgen).
static func kus(guvercin := false) -> ArrayMesh:
	var key := "kus_g" if guvercin else "kus_m"
	if _c.has(key):
		return _c[key]
	var m := _canli("guvercin" if guvercin else "marti", 2, {"poz": "uc"}, 1.5, -0.24, false)
	_c[key] = m
	return m


## canli_kit ağını bu katmanın düzenine çevirir: 180° (yüz −z), ölçek, dikey kaydırma; kod=true ise renk alfa kodu
static func _canli(tur: String, lod: int, opt: Dictionary, olcek: float, dy: float, kod: bool) -> ArrayMesh:
	var acc = preload("res://scripts/world/ist/canli_kit.gd").birikim(tur, lod, opt)
	var xf := Transform3D(Basis(Vector3.UP, PI).scaled(Vector3.ONE * olcek), Vector3(0, dy, 0))
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var c := PackedColorArray()
	for i in acc.v.size():
		v.append(xf * acc.v[i])
		n.append((xf.basis * acc.n[i]).normalized())
		var cc: Color = acc.c[i]
		if kod:
			var gri := absf(cc.r - cc.g) < 0.05 and absf(cc.g - cc.b) < 0.06 and cc.get_luminance() > 0.45
			cc = Color(clampf(cc.get_luminance() * 1.12, 0.0, 1.0), 0, 0, 1.0) if gri else Color(cc.r, cc.g, cc.b, 0.0)
		c.append(cc)
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_NORMAL] = n
	arr[Mesh.ARRAY_COLOR] = c
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return am


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
