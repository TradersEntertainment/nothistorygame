class_name MeshKit
extends RefCounted
## İş parçacığında güvenle çalışan basit geometri birleştirici: kutu, çatı prizması, piramit, silindir ekler;
## sonunda tek yüzeyli (köşe renkli) dizi verir. Düğüm ya da kaynak oluşturmaz: WorkerThreadPool içinde
## üretilip ana iş parçacığında ArrayMesh'e çevrilir (şehir akışı, CityStream).

var v := PackedVector3Array()
var n := PackedVector3Array()
var c := PackedColorArray()


func _tri(xf: Transform3D, a: Vector3, b: Vector3, d: Vector3, col: Color) -> void:
	var pa := xf * a
	var pb := xf * b
	var pd := xf * d
	var nn := (pb - pa).cross(pd - pa).normalized()
	v.append(pa)
	v.append(pb)
	v.append(pd)
	for i in 3:
		n.append(nn)
		c.append(col)


func _quad(xf: Transform3D, a: Vector3, b: Vector3, d: Vector3, e: Vector3, col: Color) -> void:
	# a-b-d-e saat yönünün tersine (dışarıdan bakınca)
	_tri(xf, a, b, d, col)
	_tri(xf, a, d, e, col)


## Merkezli kutu (xf: kutunun merkezi ve yönü).
func box(xf: Transform3D, s: Vector3, col: Color) -> void:
	var h := s * 0.5
	var p := [Vector3(-h.x, -h.y, -h.z), Vector3(h.x, -h.y, -h.z), Vector3(h.x, h.y, -h.z), Vector3(-h.x, h.y, -h.z),
		Vector3(-h.x, -h.y, h.z), Vector3(h.x, -h.y, h.z), Vector3(h.x, h.y, h.z), Vector3(-h.x, h.y, h.z)]
	var top := col.lightened(0.04)
	_quad(xf, p[4], p[5], p[6], p[7], col)        # +z
	_quad(xf, p[1], p[0], p[3], p[2], col)        # -z
	_quad(xf, p[5], p[1], p[2], p[6], col.darkened(0.04))   # +x
	_quad(xf, p[0], p[4], p[7], p[3], col.darkened(0.04))   # -x
	_quad(xf, p[7], p[6], p[2], p[3], top)        # üst
	_quad(xf, p[0], p[1], p[5], p[4], col.darkened(0.2))    # alt


## İnce yüzey (yerel XY düzleminde, +z'ye bakar): pencere, kepenk, kiriş gibi duvar üstü ayrıntılar (6 köşe).
func face(xf: Transform3D, w: float, h: float, col: Color) -> void:
	_quad(xf, Vector3(-w * 0.5, -h * 0.5, 0), Vector3(w * 0.5, -h * 0.5, 0), Vector3(w * 0.5, h * 0.5, 0), Vector3(-w * 0.5, h * 0.5, 0), col)


## Beşik çatı: taban s.x × s.z, mahya x ekseni boyunca, yükseklik s.y. xf: tabanın merkezi.
func gable(xf: Transform3D, s: Vector3, col: Color) -> void:
	var hx := s.x * 0.5
	var hz := s.z * 0.5
	var a := Vector3(-hx, 0, hz)
	var b := Vector3(hx, 0, hz)
	var d := Vector3(hx, 0, -hz)
	var e := Vector3(-hx, 0, -hz)
	var r0 := Vector3(-hx, s.y, 0)
	var r1 := Vector3(hx, s.y, 0)
	_quad(xf, a, b, r1, r0, col)
	_quad(xf, d, e, r0, r1, col.darkened(0.08))
	var wall := col.darkened(0.25)
	_tri(xf, b, d, r1, wall)
	_tri(xf, e, a, r0, wall)


## Kırma çatı (dört eğimli yüz): mahya kısalır. s.y yükseklik.
func hip(xf: Transform3D, s: Vector3, col: Color) -> void:
	var hx := s.x * 0.5
	var hz := s.z * 0.5
	var ridge := maxf(0.0, hx - hz)
	var a := Vector3(-hx, 0, hz)
	var b := Vector3(hx, 0, hz)
	var d := Vector3(hx, 0, -hz)
	var e := Vector3(-hx, 0, -hz)
	var r0 := Vector3(-ridge, s.y, 0)
	var r1 := Vector3(ridge, s.y, 0)
	_quad(xf, a, b, r1, r0, col)
	_quad(xf, d, e, r0, r1, col.darkened(0.08))
	_tri(xf, b, d, r1, col.darkened(0.04))
	_tri(xf, e, a, r0, col.darkened(0.04))


## Silindir (yan yüzler + üst kapak), taban merkezi xf; top < 0 düz.
func cyl(xf: Transform3D, r: float, h: float, col: Color, seg := 10, top := -1.0) -> void:
	var rt := r if top < 0.0 else top
	for i in seg:
		var a0 := TAU * i / seg
		var a1 := TAU * (i + 1) / seg
		var p0 := Vector3(cos(a0) * r, 0, sin(a0) * r)
		var p1 := Vector3(cos(a1) * r, 0, sin(a1) * r)
		var q0 := Vector3(cos(a0) * rt, h, sin(a0) * rt)
		var q1 := Vector3(cos(a1) * rt, h, sin(a1) * rt)
		_quad(xf, p1, p0, q0, q1, col)
		if rt > 0.001:
			_tri(xf, Vector3(0, h, 0), q1, q0, col.lightened(0.04))


## Yarım küre kubbe (taban merkezi xf), yükseklik oranı k.
func dome(xf: Transform3D, r: float, col: Color, k := 0.7, seg := 12, rings := 4) -> void:
	for j in rings:
		var t0 := PI * 0.5 * j / rings
		var t1 := PI * 0.5 * (j + 1) / rings
		for i in seg:
			var a0 := TAU * i / seg
			var a1 := TAU * (i + 1) / seg
			var p00 := Vector3(cos(a0) * cos(t0) * r, sin(t0) * r * k, sin(a0) * cos(t0) * r)
			var p10 := Vector3(cos(a1) * cos(t0) * r, sin(t0) * r * k, sin(a1) * cos(t0) * r)
			var p01 := Vector3(cos(a0) * cos(t1) * r, sin(t1) * r * k, sin(a0) * cos(t1) * r)
			var p11 := Vector3(cos(a1) * cos(t1) * r, sin(t1) * r * k, sin(a1) * cos(t1) * r)
			_quad(xf, p10, p00, p01, p11, col)


func is_empty() -> bool:
	return v.is_empty()


func arrays() -> Array:
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_NORMAL] = n
	arr[Mesh.ARRAY_COLOR] = c
	return arr
