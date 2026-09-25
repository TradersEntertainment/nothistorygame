class_name Scenery
## Derin, dolu manzara için yardımcılar: yüzlerce çadır, ağaç, uzak insan, duman sütunu ve ufuk.
## Tekrarlayan nesneler MultiMesh ile çizilir (tek çizim çağrısı), yani yüzlerce tane ucuzdur.
## Hiçbir haritada ufuk boş kalmasın (kullanıcı isteği).


## Birkaç ilkel parçayı tek bir köşe renkli ağ örgüsünde birleştirir. parts: [[Mesh, Transform3D, Color], ...]
static func merged(parts: Array) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for part in parts:
		var mesh: Mesh = part[0]
		var xf: Transform3D = part[1]
		var col: Color = part[2]
		var arrays := mesh.surface_get_arrays(0)
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var norms: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		if idx.is_empty():
			for i in verts.size():
				idx.append(i)
		for i in idx:
			st.set_color(col)
			st.set_normal((xf.basis * norms[i]).normalized())
			st.add_vertex(xf * verts[i])
	return st.commit()


static func _vc_mat() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return m


## MultiMesh: aynı ağ örgüsünü verilen dönüşümler ve renk çarpanlarıyla çoğaltır.
static func scatter(parent: Node3D, mesh: Mesh, xforms: Array, colors: Array = [], material: Material = null) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = not colors.is_empty()
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i])
		if mm.use_colors:
			mm.set_instance_color(i, colors[i])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	if material:
		mi.material_override = material
	else:
		var mat := _vc_mat()
		if mm.use_colors:
			# Örnek rengi köşe rengiyle çarpılır: gövde tonları çeşitlenir
			mat.vertex_color_use_as_albedo = true
		mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


static func _cyl(r: float, h: float, top := -1.0, seg := 10) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.bottom_radius = r
	c.top_radius = r if top < 0.0 else top
	c.height = h
	c.radial_segments = seg
	c.rings = 1
	return c


static func _ball(r: float) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 8
	s.rings = 5
	return s


static func _boxm(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b


static func _t(pos: Vector3, rot := Vector3.ZERO, scl := Vector3.ONE) -> Transform3D:
	return Transform3D(Basis.from_euler(rot).scaled(scl), pos)


# ---------------------------------------------------------------- hazır modeller

## Yuvarlak ordugâh çadırı (1 m yarıçap): gövde, koni tepe, bant, tepe direği.
static func tent_mesh(band := Color("8a2b22")) -> ArrayMesh:
	return merged([
		[_cyl(1.0, 1.4), _t(Vector3(0, 0.7, 0)), Color.WHITE],
		[_cyl(1.05, 1.3, 0.05), _t(Vector3(0, 2.05, 0)), Color(0.9, 0.9, 0.88)],
		[_cyl(1.01, 0.18), _t(Vector3(0, 1.3, 0)), band],
		[_cyl(0.03, 0.8, -1.0, 4), _t(Vector3(0, 3.0, 0)), Color("4a3020")],
		[_boxm(Vector3(0.9, 1.2, 0.05)), _t(Vector3(0, 0.6, 1.0)), Color("2a2018")],
	])


## Sivri tepeli yüksek çadır (ağa çadırı): dar gövde, uzun külah, tepede alem.
static func tall_tent_mesh(band := Color("8a2b22")) -> ArrayMesh:
	return merged([
		[_cyl(0.85, 1.5), _t(Vector3(0, 0.75, 0)), Color.WHITE],
		[_cyl(0.92, 2.1, 0.02), _t(Vector3(0, 2.55, 0)), Color(0.92, 0.9, 0.86)],
		[_cyl(0.86, 0.14), _t(Vector3(0, 1.45, 0)), band],
		[_cyl(0.87, 0.1), _t(Vector3(0, 0.4, 0)), band],
		[_ball(0.08), _t(Vector3(0, 3.7, 0)), Color("d8b040")],
		[_boxm(Vector3(0.7, 1.1, 0.05)), _t(Vector3(0, 0.55, 0.85)), Color("2a2018")],
	])


## Uzun sırtlı çadır (asker koğuşu): üçgen kesitli, iki ucunda direk.
static func ridge_tent_mesh(band := Color("8a2b22")) -> ArrayMesh:
	var pr := PrismMesh.new()
	pr.size = Vector3(1.8, 1.4, 2.8)
	return merged([
		[pr, _t(Vector3(0, 0.7, 0)), Color.WHITE],
		[_boxm(Vector3(1.82, 0.12, 2.82)), _t(Vector3(0, 0.12, 0)), band],
		[_cyl(0.03, 1.8, -1.0, 4), _t(Vector3(0, 0.9, 1.45)), Color("4a3020")],
		[_cyl(0.03, 1.8, -1.0, 4), _t(Vector3(0, 0.9, -1.45)), Color("4a3020")],
		[_boxm(Vector3(0.6, 0.9, 0.04)), _t(Vector3(0, 0.45, 1.41)), Color("2a2018")],
	])


## Büyük çizgili köşk çadırı (paşa çadırı).
static func pavilion_mesh() -> ArrayMesh:
	return merged([
		[_boxm(Vector3(6.0, 2.6, 4.0)), _t(Vector3(0, 1.3, 0)), Color.WHITE],
		[_cyl(3.8, 1.8, 0.2, 4), _t(Vector3(0, 3.5, 0), Vector3(0, PI / 4.0, 0), Vector3(1.1, 1, 0.78)), Color(0.85, 0.2, 0.2)],
		[_boxm(Vector3(6.05, 0.3, 4.05)), _t(Vector3(0, 2.3, 0)), Color("d8b040")],
	])


## Servi ağacı.
static func cypress_mesh() -> ArrayMesh:
	return merged([
		[_cyl(0.18, 1.2, -1.0, 5), _t(Vector3(0, 0.6, 0)), Color("5a4028")],
		[_cyl(0.9, 6.0, 0.05, 7), _t(Vector3(0, 4.0, 0)), Color("2f5a34")],
	])


## Yuvarlak ağaç (çınar).
static func plane_tree_mesh() -> ArrayMesh:
	return merged([
		[_cyl(0.3, 3.0, 0.22, 6), _t(Vector3(0, 1.5, 0)), Color("6a5038")],
		[_ball(2.2), _t(Vector3(0, 4.4, 0), Vector3.ZERO, Vector3(1, 0.85, 1)), Color("4a7a3a")],
		[_ball(1.5), _t(Vector3(1.2, 3.8, 0.4)), Color("3f6e34")],
	])


## Uzak insan silueti (asker ya da ordugâh halkı): gövde, baş, börk.
static func figure_mesh() -> ArrayMesh:
	return merged([
		[_cyl(0.22, 1.1, 0.16, 6), _t(Vector3(0, 0.75, 0)), Color.WHITE],
		[_ball(0.14), _t(Vector3(0, 1.45, 0)), Color("e0b08a")],
		[_cyl(0.1, 0.3, 0.07, 5), _t(Vector3(0, 1.68, 0)), Color("f0ece0")],
		[_cyl(0.08, 0.5, -1.0, 4), _t(Vector3(-0.07, 0.25, 0)), Color("2a2a30")],
		[_cyl(0.08, 0.5, -1.0, 4), _t(Vector3(0.07, 0.25, 0)), Color("2a2a30")],
	])


## At (basit).
static func horse_mesh() -> ArrayMesh:
	var parts := [
		[_boxm(Vector3(0.5, 0.6, 1.5)), _t(Vector3(0, 1.3, 0)), Color.WHITE],
		[_boxm(Vector3(0.3, 0.7, 0.35)), _t(Vector3(0, 1.75, 0.8), Vector3(-0.6, 0, 0)), Color.WHITE],
		[_boxm(Vector3(0.25, 0.3, 0.55)), _t(Vector3(0, 2.05, 1.05)), Color.WHITE],
	]
	for p in [Vector3(-0.18, 0.5, 0.55), Vector3(0.18, 0.5, 0.55), Vector3(-0.18, 0.5, -0.55), Vector3(0.18, 0.5, -0.55)]:
		parts.append([_cyl(0.07, 1.0, -1.0, 4), _t(p), Color.WHITE.darkened(0.2)])
	return merged(parts)


## Uzaktaki kule ya da ev (ufuk dolgusu).
static func house_mesh() -> ArrayMesh:
	return merged([
		[_boxm(Vector3(1, 1, 1)), _t(Vector3(0, 0.5, 0)), Color.WHITE],
		[_cyl(0.75, 0.4, 0.02, 4), _t(Vector3(0, 1.2, 0), Vector3(0, PI / 4.0, 0), Vector3(1, 1, 1)), Color(0.75, 0.32, 0.25)],
	])


# ---------------------------------------------------------------- sahne parçaları

## Ordugâh: halka biçiminde yüzlerce çadır, köşkler, ağaçlar, uzak askerler, atlar ve duman sütunları.
## avoid: Rect2 listesi (x, z) — oynanan alan ve yollar boş kalır.
static func camp(parent: Node3D, center: Vector3, r0: float, r1: float, count: int, avoid: Array, height: Callable, seed := 1453, night := false) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var bands := [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a"), Color("c98a3a")]
	var groups: Array = [[], [], [], []]
	var gcols: Array = [[], [], [], []]
	var tries := 0
	var placed := 0
	while placed < count and tries < count * 8:
		tries += 1
		var a := rng.randf() * TAU
		var r := sqrt(rng.randf_range(r0 * r0, r1 * r1))
		var p := center + Vector3(sin(a) * r, 0, cos(a) * r)
		if _blocked(p, avoid):
			continue
		p.y = height.call(p.x, p.z) - 0.1
		var s := rng.randf_range(1.5, 3.0)
		var g := rng.randi() % 4
		groups[g].append(_t(p, Vector3(0, rng.randf() * TAU, 0), Vector3(s, s * rng.randf_range(0.9, 1.1), s)))
		gcols[g].append([Color("e0d4b8"), Color("d8cbb0"), Color("c8b894"), Color("ece2cc"), Color("b8a888")][rng.randi() % 5])
		placed += 1
	for g in 4:
		if groups[g].is_empty():
			continue
		# Aynı grupta üç biçim: yuvarlak çadır, sivri tepeli yüksek çadır, uzun sırtlı çadır
		var by_kind: Array = [[[], []], [[], []], [[], []]]
		for i in groups[g].size():
			var k: int = (i * 7 + g) % 5
			k = 0 if k < 3 else (1 if k == 3 else 2)
			by_kind[k][0].append(groups[g][i])
			by_kind[k][1].append(gcols[g][i])
		var meshes := [tent_mesh(bands[g]), tall_tent_mesh(bands[g]), ridge_tent_mesh(bands[g])]
		for k in 3:
			if not by_kind[k][0].is_empty():
				scatter(parent, meshes[k], by_kind[k][0], by_kind[k][1])
	# Paşa köşkleri
	var pav: Array = []
	for i in 8:
		var a := TAU * i / 8.0 + 0.3
		var p := center + Vector3(sin(a) * (r1 * 0.7), 0, cos(a) * (r1 * 0.7))
		if _blocked(p, avoid):
			continue
		p.y = height.call(p.x, p.z) - 0.1
		pav.append(_t(p, Vector3(0, a, 0)))
	if not pav.is_empty():
		scatter(parent, pavilion_mesh(), pav, [])
	# Sancak direkleri ve tuğlar
	for i in 18:
		var a := rng.randf() * TAU
		var r := rng.randf_range(r0, r1)
		var p := center + Vector3(sin(a) * r, 0, cos(a) * r)
		if _blocked(p, avoid):
			continue
		p.y = height.call(p.x, p.z)
		Props.cyl(parent, 0.07, 7.0, p + Vector3(0, 3.5, 0), Color("5a4028"), Vector3.ZERO, 5)
		Props.box(parent, Vector3(0.03, 1.2, 1.8), p + Vector3(0, 6.2, 0.9), [Color("b3262d"), Color("2f5fa8"), Color("3a6b3a")][i % 3])
	# Uzak askerler ve ordugâh halkı (duran, küçük kümeler hâlinde)
	var figs: Array = []
	var fcols: Array = []
	for i in count:
		var a := rng.randf() * TAU
		var r := rng.randf_range(r0 * 0.85, r1)
		var p := center + Vector3(sin(a) * r, 0, cos(a) * r)
		if _blocked(p, avoid):
			continue
		for k in rng.randi_range(1, 3):
			var q := p + Vector3(rng.randf_range(-1.2, 1.2), 0, rng.randf_range(-1.2, 1.2))
			q.y = height.call(q.x, q.z)
			figs.append(_t(q, Vector3(0, rng.randf() * TAU, 0)))
			fcols.append([Color("b3262d"), Color("2f5fa8"), Color("7a5a3a"), Color("3a6b3a"), Color("c98a3a"), Color("8a6a4a")][rng.randi() % 6])
	scatter(parent, figure_mesh(), figs, fcols)
	# At sıraları
	var horses: Array = []
	var hcols: Array = []
	for line in 5:
		var a := rng.randf() * TAU
		var r := rng.randf_range(r0 * 1.2, r1 * 0.9)
		var base := center + Vector3(sin(a) * r, 0, cos(a) * r)
		if _blocked(base, avoid):
			continue
		for k in 8:
			var q := base + Vector3(cos(a) * k * 1.3, 0, -sin(a) * k * 1.3)
			q.y = height.call(q.x, q.z)
			horses.append(_t(q, Vector3(0, a + PI / 2.0, 0)))
			hcols.append([Color("6a4a2c"), Color("3a2a1e"), Color("c8b8a0"), Color("8a6a4a")][rng.randi() % 4])
	scatter(parent, horse_mesh(), horses, hcols)
	# Duman sütunları (ocaklar)
	for i in 10:
		var a := rng.randf() * TAU
		var r := rng.randf_range(r0, r1 * 0.8)
		var p := center + Vector3(sin(a) * r, 0, cos(a) * r)
		if _blocked(p, avoid):
			continue
		p.y = height.call(p.x, p.z)
		smoke_column(parent, p, night)


static func _blocked(p: Vector3, avoid: Array) -> bool:
	for rect in avoid:
		if (rect as Rect2).has_point(Vector2(p.x, p.z)):
			return true
	return false


## İnce, yükselen duman sütunu (uzaktan görünen ocak dumanı).
static func smoke_column(parent: Node3D, pos: Vector3, night := false) -> void:
	var p := CPUParticles3D.new()
	p.position = pos + Vector3(0, 1.0, 0)
	p.amount = 12
	p.lifetime = 7.0
	p.preprocess = 7.0
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.16, 0.17, 0.22, 0.35) if night else Color(0.85, 0.83, 0.8, 0.45)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var s := _ball(0.7)
	s.material = m
	p.mesh = s
	p.direction = Vector3.UP
	p.spread = 6.0
	p.initial_velocity_min = 1.0
	p.initial_velocity_max = 1.4
	p.gravity = Vector3(0.25, 0.1, 0)
	p.scale_amount_min = 0.8
	p.scale_amount_max = 2.6
	var sc := Curve.new()
	sc.add_point(Vector2(0, 0.4))
	sc.add_point(Vector2(1, 1.6))
	p.scale_amount_curve = sc
	p.add_to_group("scenery_smoke")
	parent.add_child(p)


## Ağaç kümeleri (servi ve çınar) bir halka üzerinde.
static func trees(parent: Node3D, center: Vector3, r0: float, r1: float, count: int, avoid: Array, height: Callable, seed := 7) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var cyp: Array = []
	var pla: Array = []
	var tries := 0
	while cyp.size() + pla.size() < count and tries < count * 6:
		tries += 1
		var a := rng.randf() * TAU
		var r := sqrt(rng.randf_range(r0 * r0, r1 * r1))
		var p := center + Vector3(sin(a) * r, 0, cos(a) * r)
		if _blocked(p, avoid):
			continue
		p.y = height.call(p.x, p.z) - 0.1
		var s := rng.randf_range(0.8, 1.4)
		var xf := _t(p, Vector3(0, rng.randf() * TAU, 0), Vector3(s, s * rng.randf_range(0.9, 1.3), s))
		if rng.randf() < 0.6:
			cyp.append(xf)
		else:
			pla.append(xf)
	if not cyp.is_empty():
		scatter(parent, cypress_mesh(), cyp, [])
	if not pla.is_empty():
		scatter(parent, plane_tree_mesh(), pla, [])


## Uzak tepeler: ufku kapatan büyük, alçak, çok köşeli tepeler.
static func hills(parent: Node3D, center: Vector3, radius: float, count: int, color: Color, seed := 3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for i in count:
		var a := TAU * i / count + rng.randf_range(-0.1, 0.1)
		var r := radius + rng.randf_range(-20.0, 30.0)
		var size := rng.randf_range(40.0, 75.0)
		var p := center + Vector3(sin(a) * r, -size * 0.55, cos(a) * r)
		Props.ball(parent, size, p, color.darkened(rng.randf_range(0.0, 0.15)), Vector3(1.5, 0.5, 1.1), 10)


## Konstantinopolis silueti: kuleli kara surları, arkasında evler, kubbeler, serviler.
## along_x: surlar x ekseni boyunca uzanır (z = line); length metre.
static func city_walls(parent: Node3D, line_z: float, length: float, facing := 1.0, seed := 1204) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var stone := Color("b8a888")
	var tower := Color("a89878")
	# Dış sur (alçak), iç sur (yüksek), hendek
	Props.box(parent, Vector3(length, 0.3, 10), Vector3(0, 0.1, line_z - facing * 8.0), Color("5a6a4a"))
	Props.set_pattern(Props.box(parent, Vector3(length, 7.0, 3.0), Vector3(0, 3.5, line_z), Color.WHITE), stone, "ashlar_far")
	Props.set_pattern(Props.box(parent, Vector3(length, 13.0, 4.0), Vector3(0, 6.5, line_z + facing * 9.0), Color.WHITE), stone.darkened(0.05), "ashlar_far")
	var x := -length * 0.5
	# Mazgallar: iki surun tepesinde dişler (siluet "kumaş" değil, sur gibi okunsun)
	var merl: Array = []
	var mx := -length * 0.5
	while mx < length * 0.5:
		merl.append(_t(Vector3(mx, 7.45, line_z), Vector3.ZERO, Vector3(1.1, 0.9, 3.1)))
		merl.append(_t(Vector3(mx + 0.9, 13.45, line_z + facing * 9.0), Vector3.ZERO, Vector3(1.2, 0.9, 4.1)))
		mx += 2.2
	scatter(parent, _boxm(Vector3.ONE), merl, [], Props.mat(stone.darkened(0.08)))
	while x < length * 0.5:
		var h := rng.randf_range(16.0, 20.0)
		var tz := line_z + facing * 9.0
		Props.set_pattern(Props.box(parent, Vector3(7.0, h, 7.0), Vector3(x, h * 0.5, tz), Color.WHITE), tower, "ashlar_far")
		# Kule tepesi: taşan korkuluk ve dört köşede diş, bazılarında ahşap külah
		Props.box(parent, Vector3(7.8, 0.6, 7.8), Vector3(x, h + 0.3, tz), tower.darkened(0.12))
		for k in 4:
			Props.box(parent, Vector3(1.3, 1.1, 1.3), Vector3(x + (k % 2 - 0.5) * 6.2, h + 1.15, tz + (k / 2 - 0.5) * 6.2), tower.darkened(0.08))
		if rng.randf() < 0.35:
			Props.prism(parent, Vector3(6.6, 3.2, 6.6), Vector3(x, h + 2.2, tz), Color("7a4a32"))
		Props.box(parent, Vector3(0.2, 0.6, 7.1), Vector3(x, h * 0.4, tz), Color("8a4a36"))
		# Dipte yosun/kir: sur yere otursun
		Props.box(parent, Vector3(7.1, 1.4, 7.1), Vector3(x, 0.7, tz), tower.darkened(0.25))
		x += rng.randf_range(20.0, 26.0)
	# Surların ardında şehir: evler, kiliseler, kubbeler, serviler
	var hx: Array = []
	var hc: Array = []
	for i in 160:
		var p := Vector3(rng.randf_range(-length * 0.5, length * 0.5), 0, line_z + facing * rng.randf_range(18.0, 90.0))
		var s := Vector3(rng.randf_range(5.0, 10.0), rng.randf_range(5.0, 12.0) + absf(p.z - line_z) * 0.08, rng.randf_range(5.0, 10.0))
		hx.append(_t(p, Vector3(0, rng.randf() * 0.4, 0), s))
		hc.append([Color("e8d8c0"), Color("d8c0a0"), Color("c8a888"), Color("e0ccb0")][i % 4])
	scatter(parent, house_mesh(), hx, hc)
	for i in 5:
		var p := Vector3(-length * 0.35 + i * length * 0.18, 0, line_z + facing * rng.randf_range(35.0, 70.0))
		if i == 2:
			hagia_sophia(parent, p, 1.0)
			continue
		# Kilise: gövde, pencereli kasnak, kurşun kubbe
		var r := rng.randf_range(5.0, 8.0)
		Props.box(parent, Vector3(r * 2.4, r * 1.3, r * 2.0), p + Vector3(0, r * 0.65, 0), Color("c08068"))  # tuğla
		Props.cyl(parent, r * 0.62, r * 0.55, p + Vector3(0, r * 1.55, 0), Color("c8a890"), Vector3.ZERO, 12)
		Props.ball(parent, r * 0.64, p + Vector3(0, r * 1.82, 0), Color("8a98a8"), Vector3(1, 0.7, 1), 14)
	var cyp: Array = []
	for i in 120:
		var p := Vector3(rng.randf_range(-length * 0.5, length * 0.5), 0, line_z + facing * rng.randf_range(16.0, 95.0))
		var sc := rng.randf_range(0.9, 1.5)
		cyp.append(_t(p, Vector3.ZERO, Vector3(sc, sc * 1.2, sc)))
	scatter(parent, cypress_mesh(), cyp, [])


## Ayasofya silueti (uzak manzara): kare gövde, payandalar, pencereli kasnak, büyük kurşun kubbe,
## doğu-batıda iki yarım kubbe ve onların eteğinde küçük yarım kubbeler. s: ölçek (1 = gerçek boyutun kabası).
static func hagia_sophia(parent: Node3D, p: Vector3, s := 1.0) -> void:
	var wall := Color("9a3e2a")  # Ayasofya'nın kızıl tuğlası (uzakta pusla açılır, koyu seçildi)
	var lead := Color("4a5a70")
	Props.box(parent, Vector3(70, 26, 76) * s, p + Vector3(0, 13, 0) * s, wall)
	for k in 4:
		Props.box(parent, Vector3(10, 34, 10) * s, p + Vector3((k % 2 - 0.5) * 60, 17, (k / 2 - 0.5) * 26) * s, wall.darkened(0.06))
	Props.cyl(parent, 17.0 * s, 7.0 * s, p + Vector3(0, 37, 0) * s, wall.lightened(0.05), Vector3.ZERO, 20)
	# Kasnaktaki pencere dizisi
	Props.cyl(parent, 17.1 * s, 2.2 * s, p + Vector3(0, 37.5, 0) * s, Color("3a3438"), Vector3.ZERO, 20)
	Props.ball(parent, 17.5 * s, p + Vector3(0, 40.5, 0) * s, lead, Vector3(1, 0.62, 1), 20)
	for side in [-1, 1]:
		Props.ball(parent, 16.0 * s, p + Vector3(0, 30, side * 17) * s, lead, Vector3(1, 0.55, 1), 16)
		for q in [-1, 1]:
			Props.ball(parent, 7.0 * s, p + Vector3(q * 11, 25, side * 30) * s, lead, Vector3(1, 0.55, 1), 12)


## Yakın zemin ayrıntısı: çimen öbekleri, taşlar, kuru çalı (çarpışmasız; oynanışı engellemez).
static func ground_detail(parent: Node3D, area: Rect2, count: int, height: Callable, grass := Color("5a8a3a"), seed := 21) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var tx: Array = []
	var tc: Array = []
	var rocks: Array = [[], [], []]
	for i in count:
		var p := Vector3(rng.randf_range(area.position.x, area.end.x), 0, rng.randf_range(area.position.y, area.end.y))
		p.y = height.call(p.x, p.z)
		if rng.randf() < 0.88:
			# Rüzgârda salınan çimen öbeği (Nature.tuft): koyu zeytin - saman arası tonlar
			var s := rng.randf_range(0.7, 1.5)
			tx.append(_t(p, Vector3(0, rng.randf() * TAU, 0), Vector3(s, s * rng.randf_range(0.8, 1.3), s)))
			tc.append(grass.darkened(0.12).lerp(Color("b0a468"), rng.randf() * 0.45))
		else:
			# Köşeli kaya, yarısı toprağa gömülü
			var s := rng.randf_range(0.25, 0.9)
			var v := rng.randi() % 3
			(rocks[v] as Array).append([_t(p + Vector3(0, -0.06 * s, 0), Vector3(rng.randf_range(-0.2, 0.2), rng.randf() * TAU, rng.randf_range(-0.2, 0.2)), Vector3(s * rng.randf_range(0.9, 1.5), s, s * rng.randf_range(0.9, 1.4))),
				Color("8e8878").lerp(Color("b4aa98"), rng.randf())])
	var gi := scatter(parent, Nature.tuft(), tx, tc, Nature.grass_material())
	gi.visibility_range_end = 70.0
	for v in 3:
		var xs: Array = []
		var cs: Array = []
		for r in rocks[v]:
			xs.append(r[0])
			cs.append(r[1])
		if not xs.is_empty():
			var ri := scatter(parent, Nature.rock(v), xs, cs, Nature.rock_material())
			ri.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


## Ordugâh eşyası: saman balyaları, sandıklar, fıçılar, el arabaları (çarpışmasız dekor).
static func camp_clutter(parent: Node3D, spots: Array, seed := 5) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var hay := merged([[_cyl(0.5, 0.9, -1.0, 10), _t(Vector3(0, 0.5, 0), Vector3(0, 0, PI / 2.0)), Color("d8c078")]])
	var crate := merged([[_boxm(Vector3(0.8, 0.7, 0.8)), _t(Vector3(0, 0.35, 0)), Color("8a6440")],
		[_boxm(Vector3(0.82, 0.08, 0.82)), _t(Vector3(0, 0.55, 0)), Color("5a3a24")]])
	var cart := merged([[_boxm(Vector3(1.4, 0.4, 2.2)), _t(Vector3(0, 0.8, 0)), Color("7a5a38")],
		[_cyl(0.5, 0.1, -1.0, 10), _t(Vector3(0.75, 0.5, 0), Vector3(0, 0, PI / 2.0)), Color("4a3020")],
		[_cyl(0.5, 0.1, -1.0, 10), _t(Vector3(-0.75, 0.5, 0), Vector3(0, 0, PI / 2.0)), Color("4a3020")],
		[_boxm(Vector3(0.08, 0.08, 1.6)), _t(Vector3(0, 0.7, 1.8)), Color("5a4028")]])
	var sets := [[hay, []], [crate, []], [cart, []]]
	for p in spots:
		var k := rng.randi() % 3
		(sets[k][1] as Array).append(_t(p, Vector3(0, rng.randf() * TAU, 0)))
	for st in sets:
		if not (st[1] as Array).is_empty():
			scatter(parent, st[0], st[1], [])


## Gündüz dumanlarını geceye uygun koyu tona çevirir (CampDay.make_night).
static func darken_smoke(tree: SceneTree) -> void:
	for n in tree.get_nodes_in_group("scenery_smoke"):
		var p := n as CPUParticles3D
		var m := (p.mesh as SphereMesh).material as StandardMaterial3D
		m.albedo_color = Color(0.16, 0.17, 0.22, 0.35)
