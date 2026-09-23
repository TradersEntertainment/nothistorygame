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
	for j in nz:
		for i in nx:
			var a: Vector3 = hs[j][i]
			var b: Vector3 = hs[j][i + 1]
			var c: Vector3 = hs[j + 1][i]
			var d: Vector3 = hs[j + 1][i + 1]
			for tri in [[a, b, c], [b, d, c]]:
				var n: Vector3 = (tri[2] - tri[0]).cross(tri[1] - tri[0]).normalized()
				var center: Vector3 = (tri[0] + tri[1] + tri[2]) / 3.0
				var col: Color = color.call(center.x, center.z, center.y, 1.0 - absf(n.y))
				for v in tri:
					st.set_color(col)
					st.set_normal(n if n.y >= 0.0 else -n)
					st.add_vertex(v)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = vertex_color_material()
	return mi


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
