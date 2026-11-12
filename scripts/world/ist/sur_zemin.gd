extends RefCounted
## SUR-4: sur dibi arazisi (madde 3; sahibinin "o yeşil alan yükseltileri ne öyle" sözü).
##   set_(): hendeğin dış yakasındaki toprak set (glacis): eskiden 14 m'lik düz yeşil KUTU (surlar.gd _build_moat), dilimin
##           tabanı yamaçta yerden yüksekte kalınca keskin köşeli parlak yeşil prizma olarak görünüyordu. Şimdi sur boyunca
##           4 m'lik bölmelerle düzensiz tepeli, dışa doğru 1:3 eğimle araziye inen çiğnenmiş toprak + solgun ot yaması.
##   ates_alani(): kara surunun dışında hendekten 60 m'lik "ateş alanı" (ORDUGÂH-4 ile sınır: ilk 60 m bu dosyanın):
##           araziyi izleyen örtü (çiğnenmiş toprak, solgun ot, yanık), top güllesi çukurları, taş gülle, kırık merdiven,
##           ok, kalkan, kazık parçaları (MultiMesh). Ağaç yok.
## catalog() yok; class_name yok.

const TOPRAK := Color("66523c")
const TOPRAK2 := Color("554534")
const OT := Color("5e6a3a")
const YANIK := Color("4e4438")
const CAMUR := Color("4a4032")


static func _hash(a: int, b: int) -> float:
	var h := (a * 73856093) ^ (b * 19349663)
	h = (h ^ (h >> 13)) * 1274126177
	return float(h & 0xffff) / 65535.0


## Hendek dış yakası toprak seti. Yerel çerçeve (surlar.gd): sur boyunca x, dış +z. z0: setin başladığı (karşı yaka
## duvarının dış yüzü), y = 0 zemin. Katı (lod 0: çarpışmalı). tohum: dilim tohumu (komşu dilimler ayrı desen).
## Dünya dönüşümü (ağaçta olmayan uzak katman kurulumunda IstSehir verir): set eteği araziye iner
static var xf_dunya := Transform3D()
static var xf_var := false

static func set_(p: Node3D, x0: float, x1: float, z0: float, lod: int, tohum: int, pencere := Vector2(-1e9, 1e9)) -> void:
	var adim := 4.0 if lod == 0 else 12.0
	var n := maxi(1, int(ceil((x1 - x0) / adim)))
	# kesit: (z, y) — yaka düzü, alçak tümsek, dışa 1:2,5 eğim; etek araziye iner (dilim tabanı yamaçta yerden yüksek
	# kaldığında altı açık kalmasın). Dünya dönüşümü yoksa sabit 28 m'lik etek.
	var xf := Transform3D()
	var arazi := false
	if p.is_inside_tree():
		xf = p.global_transform
		arazi = true
	elif xf_var:
		xf = xf_dunya
		arazi = true
	var prof := [[0.0, 0.0], [2.5, 0.35], [6.0, 0.55], [10.0, 0.1], [18.0, -2.6], [28.0, -6.5]]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cols := []
	var pts := []
	for i in n + 1:
		var x := x0 + (x1 - x0) * i / n
		var row := []
		var crow := []
		var pr := prof
		if arazi:
			var zend := 90.0
			var yend := 0.1 - (90.0 - 10.0) / 2.5
			var zz := 12.0
			while zz <= 90.0:
				var wq := xf * Vector3(x, 0.0, z0 + zz)
				var tt := IstGeo.h(wq.x, wq.z) - wq.y - 0.45
				var ys := 0.1 - (zz - 10.0) / 2.5
				if ys <= tt:
					zend = zz
					yend = maxf(tt, ys - 1.0)
					break
				zz += 3.0
			pr = [[0.0, 0.0], [2.5, 0.35], [6.0, 0.55], [10.0, 0.1], [lerpf(10.0, zend, 0.5), lerpf(0.1, yend, 0.5) - 0.3], [zend + 3.0, yend - 0.8]]
		for j in pr.size():
			var hz := _hash(tohum * 31 + i, j)
			var y: float = pr[j][1]
			if j >= 1 and j <= 3:
				y += (hz - 0.4) * 0.7
			var z: float = z0 + pr[j][0] + (hz - 0.5) * (2.0 if j >= 3 else 0.0)
			row.append(Vector3(x, y, z))
			var t := _hash(tohum + i * 7, j * 13)
			var c := TOPRAK.lerp(OT, clampf(t * 1.3 - 0.2, 0.0, 1.0) * (0.8 if j >= 2 else 0.3))
			if t > 0.85:
				c = c.lerp(TOPRAK2, 0.6)
			crow.append(c)
		pts.append(row)
		cols.append(crow)
	var any := false
	for i in n:
		var xm := (float(pts[i][0].x) + float(pts[i + 1][0].x)) * 0.5
		if xm < pencere.x or xm >= pencere.y:
			continue
		any = true
		for j in prof.size() - 1:
			var a: Vector3 = pts[i][j]
			var b: Vector3 = pts[i + 1][j]
			var c: Vector3 = pts[i + 1][j + 1]
			var d: Vector3 = pts[i][j + 1]
			_ucgen(st, a, d, b, cols[i][j], cols[i][j + 1], cols[i + 1][j])
			_ucgen(st, b, d, c, cols[i + 1][j], cols[i][j + 1], cols[i + 1][j + 1])
	if not any:
		return
	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = _mat()
	mi.name = "ToprakSet"
	p.add_child(mi)
	if lod == 0:
		var body := StaticBody3D.new()
		body.name = "ToprakSetGovde"
		var cs := CollisionShape3D.new()
		cs.shape = mesh.create_trimesh_shape()
		body.add_child(cs)
		p.add_child(body)


## Yukarı bakan üçgen (Godot ön yüzü saat yönünde: yukarıdan bakınca (b−a)×(c−a) aşağı bakmalı)
static func _ucgen(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, ca: Color, cb: Color, cc: Color) -> void:
	var nr := (b - a).cross(c - a)
	if nr.y > 0.0:
		var t := b
		b = c
		c = t
		var tc := cb
		cb = cc
		cc = tc
	else:
		nr = -nr
	nr = nr.normalized()
	st.set_color(ca)
	st.set_normal(nr)
	st.add_vertex(a)
	st.set_color(cb)
	st.set_normal(nr)
	st.add_vertex(b)
	st.set_color(cc)
	st.set_normal(nr)
	st.add_vertex(c)


static var _m: StandardMaterial3D

static func _mat() -> StandardMaterial3D:
	if _m == null:
		_m = StandardMaterial3D.new()
		_m.vertex_color_use_as_albedo = true
		_m.vertex_color_is_srgb = true
		_m.albedo_color = Color(0.86, 0.84, 0.8)
		_m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		_m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		_m.roughness = 1.0
		_m.albedo_texture = Props._noise("dirt")
		_m.uv1_triplanar = true
		_m.uv1_world_triplanar = true
		_m.uv1_scale = Vector3(0.25, 0.25, 0.25)
	return _m


## Hendek dibi: kuru çamur üstünde su birikintileri ve saz öbekleri (lod 0). Yerel: x0..x1, z0..z1 (dip), y = dip.
static func hendek_dibi(p: Node3D, x0: float, x1: float, z0: float, z1: float, y: float, tohum: int, pencere := Vector2(-1e9, 1e9)) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum * 17 + 3
	var su: Array = []
	var saz: Array = []
	var x := x0 + rng.randf_range(2.0, 8.0)
	while x < x1 - 3.0:
		var l := rng.randf_range(3.0, 11.0)
		var w := rng.randf_range(2.0, (z1 - z0) * 0.55)
		var zc := rng.randf_range(z0 + w * 0.5 + 1.0, z1 - w * 0.5 - 1.0)
		var xc := x + l * 0.5
		if xc >= pencere.x and xc < pencere.y and xc + l * 0.5 < x1 - 2.0:
			su.append(Transform3D(Basis.from_euler(Vector3(0, rng.randf_range(-0.2, 0.2), 0)).scaled(Vector3(l, 0.04, w)), Vector3(xc, y + 0.03, zc)))
			for k in rng.randi_range(2, 6):
				var a := rng.randf() * TAU
				var r := Vector2(l * 0.5, w * 0.5) * rng.randf_range(0.8, 1.1)
				var sp := Vector3(xc + cos(a) * r.x, y, zc + sin(a) * r.y)
				for m in rng.randi_range(3, 6):
					var h := rng.randf_range(0.6, 1.4)
					var q := sp + Vector3(rng.randf_range(-0.5, 0.5), h * 0.5, rng.randf_range(-0.5, 0.5))
					saz.append(Transform3D(Basis.from_euler(Vector3(rng.randf_range(-0.25, 0.25), rng.randf() * TAU, rng.randf_range(-0.25, 0.25))).scaled(Vector3(0.05, h, 0.05)), q))
		x += l + rng.randf_range(4.0, 16.0)
	if su.size() > 0:
		Scenery.scatter(p, _disk(), su, [], Props.mat(Color("4a4a3e"), 0.0, false, "", false))
	if saz.size() > 0:
		Scenery.scatter(p, Scenery._boxm(Vector3.ONE), saz, [], Props.mat(Color("7a7a3c"), 0.0, false, "", false))


# ---------------------------------------------------------------- ateş alanı (kara surunun dışı, hendekten 60 m)

const ATES_EN := 60.0
const ATES_ADIM := 5.0

## Kara suru hattı boyunca (dünya x,z çoklu çizgi, dış yön fonksiyonu) araziyi izleyen örtü ve döküntü.
## bas: hattan dış yöne başlangıç uzaklığı (hendek dış yakası + set), en: genişlik. Dönen: kurulan düğüm.
static func ates_alani(parent: Node3D, pl: PackedVector2Array, dis: Callable, bas: float, kapilar: Array) -> Node3D:
	var root := Node3D.new()
	root.name = "SurAtesAlani"
	parent.add_child(root)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cukur: Array = []
	var cukur_c: Array = []
	var tas: Array = []
	var cubuk: Array = []
	var kalkan: Array = []
	var merdiven: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var nz := int(ATES_EN / ATES_ADIM) + 1
	var L := 0.0
	for i in pl.size() - 1:
		L += pl[i].distance_to(pl[i + 1])
	var ns := int(L / ATES_ADIM)
	var prev: Array = []
	var prev_c: Array = []
	for si in ns + 1:
		var sv := L * si / ns
		var q := _at(pl, sv)
		var p: Vector2 = q["p"]
		var d: Vector2 = q["d"]
		var o: Vector2 = dis.call(d, p)
		var row: Array = []
		var crow: Array = []
		for j in nz:
			var dz := bas + j * ATES_ADIM + (_hash(si, j) - 0.5) * 1.5
			var w := p + o * dz
			var y := IstGeo.h(w.x, w.y) + 0.12 + 0.04 * j
			row.append(Vector3(w.x, y, w.y))
			var r := IstGeo.real(w.x, w.y)
			var g := sin(r.x * 0.031 + r.y * 0.017) * sin(r.x * 0.013 - r.y * 0.029)
			var t := _hash(si * 3 + 1, j * 5 + 2)
			var c := TOPRAK.lerp(OT, clampf(0.2 + g * 0.9 + float(j) / nz * 0.45 + (t - 0.5) * 0.6, 0.0, 0.9))
			# sur boyunca çiğnenmiş yol (ikmal/devriye izi): hendekten ~25 m'de koyu toprak şerit
			if j == 4 or j == 5:
				c = c.lerp(TOPRAK2, 0.55)
			if t > 0.9:
				c = c.lerp(YANIK, 0.55)
			elif t < 0.12:
				c = c.lerp(TOPRAK2, 0.5)
			crow.append(c)
		if prev.size() > 0:
			for j in nz - 1:
				var a: Vector3 = prev[j]
				var b: Vector3 = row[j]
				var c3: Vector3 = row[j + 1]
				var e: Vector3 = prev[j + 1]
				_ucgen(st, a, b, e, prev_c[j], crow[j], prev_c[j + 1])
				_ucgen(st, b, c3, e, crow[j], crow[j + 1], prev_c[j + 1])
		prev = row
		prev_c = crow
		# döküntü (kapı önleri hariç)
		var kapida := false
		for kp: Vector2 in kapilar:
			if kp.distance_to(p) < 30.0:
				kapida = true
		if kapida:
			continue
		if rng.randf() < 0.75:
			var dz2 := bas + rng.randf_range(2.0, ATES_EN - 4.0)
			var w2 := p + o * dz2 + d * rng.randf_range(-2.0, 2.0)
			var y2 := IstGeo.h(w2.x, w2.y) + 0.14 + 0.04 * dz2 / ATES_ADIM
			var rr := rng.randf_range(1.2, 3.0)
			cukur.append(Transform3D(Basis.from_euler(Vector3(0, rng.randf() * TAU, 0)).scaled(Vector3(rr * 2.0, 0.06, rr * 1.7)), Vector3(w2.x, y2, w2.y)))
			cukur_c.append(Transform3D(Basis.from_euler(Vector3(0, rng.randf() * TAU, 0)).scaled(Vector3(rr * 2.6, 0.35, rr * 2.3)), Vector3(w2.x, y2 - 0.12, w2.y)))
			if rng.randf() < 0.5:
				var gp := w2 + Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
				var gr := rng.randf_range(0.25, 0.45)
				tas.append(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * gr * 2.0), Vector3(gp.x, IstGeo.h(gp.x, gp.y) + gr * 0.7, gp.y)))
		for k in rng.randi_range(0, 3):
			var dz3 := bas + rng.randf_range(0.0, ATES_EN * 0.6)
			var w3 := p + o * dz3 + d * rng.randf_range(-2.5, 2.5)
			var y3 := IstGeo.h(w3.x, w3.y) + 0.1
			var kind := rng.randf()
			var yaw := rng.randf() * TAU
			if kind < 0.5:
				# ok/kazık: yere saplı eğik çubuk
				var h := rng.randf_range(0.7, 1.6)
				cubuk.append(Transform3D(Basis.from_euler(Vector3(rng.randf_range(0.3, 0.7), yaw, 0)).scaled(Vector3(0.04, h, 0.04)), Vector3(w3.x, y3 + h * 0.35, w3.y)))
			elif kind < 0.75:
				kalkan.append(Transform3D(Basis.from_euler(Vector3(rng.randf_range(-0.2, 0.2), yaw, PI * 0.5 + rng.randf_range(-0.15, 0.15))).scaled(Vector3(0.9, 0.08, 0.9)), Vector3(w3.x, y3 + 0.05, w3.y)))
			elif kind < 0.9:
				# kırık merdiven: iki ray + basamaklar (yerde yatık)
				var bb := Basis.from_euler(Vector3(0, yaw, 0))
				var ln := rng.randf_range(2.5, 5.0)
				for sd: float in [-0.3, 0.3]:
					merdiven.append(Transform3D(bb.scaled(Vector3(0.09, 0.09, ln)), Vector3(w3.x, y3 + 0.05, w3.y) + bb * Vector3(sd, 0, 0)))
				for r2 in int(ln / 0.45):
					if rng.randf() < 0.75:
						merdiven.append(Transform3D(bb.scaled(Vector3(0.6, 0.06, 0.07)), Vector3(w3.x, y3 + 0.09, w3.y) + bb * Vector3(0, 0, -ln * 0.5 + 0.3 + r2 * 0.45)))
			else:
				var gr2 := rng.randf_range(0.3, 0.5)
				tas.append(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * gr2 * 2.0), Vector3(w3.x, y3 + gr2 * 0.6, w3.y)))
	var mi := MeshInstance3D.new()
	mi.name = "AtesAlaniOrtu"
	mi.mesh = st.commit()
	mi.material_override = _mat()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.set_meta("no_walk", true)
	root.add_child(mi)
	var mm: Array = []
	if cukur_c.size() > 0:
		mm.append(Scenery.scatter(root, _kure(), cukur_c, [], Props.mat(TOPRAK2.darkened(0.1), 0.0, false, "", false)))
		mm.append(Scenery.scatter(root, _disk(), cukur, [], Props.mat(YANIK.darkened(0.25), 0.0, false, "", false)))
	if tas.size() > 0:
		mm.append(Scenery.scatter(root, _kure(), tas, [], Props.mat(Color("a49a88"), 0.0, false, "", false)))
	if cubuk.size() > 0:
		mm.append(Scenery.scatter(root, Scenery._boxm(Vector3.ONE), cubuk, [], Props.mat(Color("6a5434"), 0.0, false, "", false)))
	if kalkan.size() > 0:
		mm.append(Scenery.scatter(root, _disk(), kalkan, [], Props.mat(Color("7a4a30"), 0.0, false, "", false)))
	if merdiven.size() > 0:
		mm.append(Scenery.scatter(root, Scenery._boxm(Vector3.ONE), merdiven, [], Props.mat(Color("7a6040"), 0.0, false, "", false)))
	for m in mm:
		if m is GeometryInstance3D:
			(m as GeometryInstance3D).visibility_range_end = 420.0
			(m as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.set_meta("say", {"cukur": cukur.size(), "tas": tas.size(), "cubuk": cubuk.size(), "kalkan": kalkan.size(), "merdiven": merdiven.size()})
	return root


static var _km: Mesh
static var _dm: Mesh

static func _kure() -> Mesh:
	if _km == null:
		var s := SphereMesh.new()
		s.radius = 0.5
		s.height = 1.0
		s.radial_segments = 8
		s.rings = 4
		_km = s
	return _km


static func _disk() -> Mesh:
	if _dm == null:
		var c := CylinderMesh.new()
		c.top_radius = 0.5
		c.bottom_radius = 0.5
		c.height = 1.0
		c.radial_segments = 10
		c.rings = 1
		_dm = c
	return _dm


static func _at(pl: PackedVector2Array, sv: float) -> Dictionary:
	var acc := 0.0
	for i in pl.size() - 1:
		var l := pl[i].distance_to(pl[i + 1])
		if acc + l >= sv or i == pl.size() - 2:
			var d := (pl[i + 1] - pl[i]) / maxf(l, 0.001)
			return {"p": pl[i] + d * clampf(sv - acc, 0.0, l), "d": d}
		acc += l
	return {"p": pl[0], "d": Vector2.RIGHT}
