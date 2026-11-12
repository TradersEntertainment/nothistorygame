class_name LowPoly
## Kodla üretilen low-poly geometriler: arazi (düz gölgeli, köşe renkli) ve
## kesitlerden örülen gövdeler (gemi, kayık).

static var _vc_mat: StandardMaterial3D


## Köşe renklerini kullanan, çizgi film gölgeli ortak malzeme.
static func vertex_color_material() -> StandardMaterial3D:
	if _vc_mat == null:
		_vc_mat = StandardMaterial3D.new()
		_vc_mat.vertex_color_use_as_albedo = true
		_vc_mat.vertex_color_is_srgb = true
		_vc_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
		_vc_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		_vc_mat.roughness = 1.0
	return _vc_mat


## Izgara arazi. height(x, z) -> float, color(x, z, y, slope) -> Color (dünya koordinatı).
## Her üçgen kendi köşelerine sahiptir: yüzeyler köşeli (low-poly) görünür.
static func terrain(x0: float, x1: float, z0: float, z1: float, nx: int, nz: int, height: Callable, color: Callable) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var dx := (x1 - x0) / nx
	var dz := (z1 - z0) / nz
	var hs: Array = []
	for j in nz + 1:
		var row: Array = []
		for i in nx + 1:
			var x := x0 + i * dx
			var z := z0 + j * dz
			row.append(Vector3(x, height.call(x, z), z))
		hs.append(row)
	# ZEMİN: renk köşe başına (ızgara köşesinde bir kez; eğim komşu yüksekliklerden): yüz başına düz renk keskin
	# kenarlı çokgen yamalar veriyordu; köşe rengi yumuşak geçer, zemin gölgelendiricisi geçişi gürültüyle büker.
	var cs: Array = []
	for j in nz + 1:
		var row: Array = []
		for i in nx + 1:
			var v: Vector3 = hs[j][i]
			var l: Vector3 = hs[j][maxi(i - 1, 0)]
			var r: Vector3 = hs[j][mini(i + 1, nx)]
			var u: Vector3 = hs[maxi(j - 1, 0)][i]
			var d: Vector3 = hs[mini(j + 1, nz)][i]
			var gx := (r.y - l.y) / maxf(r.x - l.x, 0.001)
			var gz := (d.y - u.y) / maxf(d.z - u.z, 0.001)
			var ny := 1.0 / sqrt(1.0 + gx * gx + gz * gz)
			row.append(color.call(v.x, v.z, v.y, 1.0 - ny))
		cs.append(row)
	for j in nz:
		for i in nx:
			var a: Vector3 = hs[j][i]
			var b: Vector3 = hs[j][i + 1]
			var c: Vector3 = hs[j + 1][i]
			var d: Vector3 = hs[j + 1][i + 1]
			var ca: Color = cs[j][i]
			var cb: Color = cs[j][i + 1]
			var cc: Color = cs[j + 1][i]
			var cd: Color = cs[j + 1][i + 1]
			for tri in [[a, b, c, ca, cb, cc], [b, d, c, cb, cd, cc]]:
				var n: Vector3 = (tri[2] - tri[0]).cross(tri[1] - tri[0]).normalized()
				for k in 3:
					st.set_color(tri[3 + k])
					st.set_normal(n if n.y >= 0.0 else -n)
					st.add_vertex(tri[k])
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	# Dokulu arazi (Nature/ground.gdshader): yüz rengine lekeler, çimen sapları, çakıl
	mi.material_override = Nature.ground_material()
	# ZEMİN yer örtüsü (ot tutamı, çiçek öbeği, taş, dal, birikinti): ayrıntılı arazide oyuncunun çevresinde akışlı
	if dx <= 5.0 and dz <= 5.0:
		var sy := func(x: float, z: float) -> float: return surface_y(x, z, x0, x1, z0, z1, nx, nz, height)
		var ip := func(x: float, z: float) -> Color: return color.call(x, z, sy.call(x, z), 0.0)
		load("res://scripts/level/zemin.gd").ortu_ekle(mi, Rect2(x0, z0, x1 - x0, z1 - z0), sy, ip)
	mi.set_meta("terrain", true)          # WorldWalk: görünen arazi çarpışmaya üçgen üçgen alınır
	mi.add_to_group("lp_terrain")         # Player: dünyanın dışındaki çarpışmasız araziler kendiliğinden katılaşır
	return mi


## Görünen araziyi katılaştırır (üçgenleri birebir): bölümün kendi arazisi yürünür olsun (ordugâh tepeleri, kıyılar)
static func solid(mi: MeshInstance3D) -> MeshInstance3D:
	mi.set_meta("solid_terrain", true)
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var shape := ConcavePolygonShape3D.new()
	shape.backface_collision = true
	shape.set_faces(mi.mesh.get_faces())
	cs.shape = shape
	body.add_child(cs)
	mi.add_child(body)
	return mi


## Arazide duran kutu (ev) için oturma: tabanın dört köşesinde ve ortasında görünen yüzey (surf: x, z → y). Döner:
## Vector2(taban y, ek yükseklik): taban en alçak köşenin biraz altında (havada kalmaz), ek yükseklik kadar uzayan
## gövde en yüksek köşede de gömülü kalmaz.
static func seat(x: float, z: float, hx: float, hz: float, surf: Callable) -> Vector2:
	var lo := INF
	var hi := -INF
	for o: Vector2 in [Vector2.ZERO, Vector2(hx, hz), Vector2(-hx, hz), Vector2(hx, -hz), Vector2(-hx, -hz)]:
		var y: float = surf.call(x + o.x, z + o.y)
		lo = minf(lo, y)
		hi = maxf(hi, y)
	return Vector2(lo - 0.35, hi - lo)


## terrain() ile kurulan arazinin (x, z)'deki görünen yüzeyi: ızgara köşelerinde height, aralarda terrain()'in
## üçgenleriyle doğrusal. Nesne ve karakterleri araziye oturtmak için: height'ın kendisi köşeler arasında görünen
## yüzeyden sapar (tepede eşya havada kalır ya da toprağa gömülür). Izgaranın dışında height'ın kendisi.
static func surface_y(x: float, z: float, x0: float, x1: float, z0: float, z1: float, nx: int, nz: int, height: Callable) -> float:
	var dx := (x1 - x0) / nx
	var dz := (z1 - z0) / nz
	var fx := (x - x0) / dx
	var fz := (z - z0) / dz
	if fx < 0.0 or fz < 0.0 or fx > nx or fz > nz:
		return height.call(x, z)
	var i := mini(int(fx), nx - 1)
	var j := mini(int(fz), nz - 1)
	var u := fx - i
	var v := fz - j
	var xa := x0 + i * dx
	var za := z0 + j * dz
	var hb: float = height.call(xa + dx, za)
	var hc: float = height.call(xa, za + dz)
	if u + v <= 1.0:
		var ha: float = height.call(xa, za)
		return ha + (hb - ha) * u + (hc - ha) * v
	var hd: float = height.call(xa + dx, za + dz)
	return hd + (hc - hd) * (1.0 - u) + (hb - hd) * (1.0 - v)


## Kesitlerden gövde örer (gemi, kayık). sections: [{z, w (yarı genişlik), top, bottom}]
## Kesit: üst kenar (±w, top), bel (±0.85w, orta), omurga (0, bottom).
## band_y üstünde kalan yüzler band_color, altı hull_color olur.
static func hull(sections: Array, hull_color: Color, band_color: Color, band_y: float) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array = []
	for s in sections:
		var w: float = s["w"]
		var top: float = s["top"]
		var bottom: float = s["bottom"]
		var mid := lerpf(bottom, top, 0.55)
		var z: float = s["z"]
		rings.append([Vector3(-w, top, z), Vector3(-w * 0.85, mid, z), Vector3(0, bottom, z), Vector3(w * 0.85, mid, z), Vector3(w, top, z)])
	for k in rings.size() - 1:
		var r0: Array = rings[k]
		var r1: Array = rings[k + 1]
		for i in 4:
			var q := [r0[i], r0[i + 1], r1[i + 1], r1[i]]
			for tri in [[q[0], q[1], q[2]], [q[0], q[2], q[3]]]:
				var n: Vector3 = (tri[2] - tri[0]).cross(tri[1] - tri[0]).normalized()
				var cy: float = (tri[0].y + tri[1].y + tri[2].y) / 3.0
				var col := band_color if cy > band_y else hull_color
				for v in tri:
					st.set_color(col)
					st.set_normal(n)
					st.add_vertex(v)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var m := vertex_color_material().duplicate() as StandardMaterial3D
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = m
	return mi
