extends RefCounted
## Sur oyun parçalarının ortak ağ yardımcıları (moloz/dolgu tümseği, boy kesiti). class_name YOK.
const KULE := preload("res://scripts/world/ist/sur_kule.gd")


## Durağan parçanın ağlarını tek ağa pişirir (çizim çağrısı: pişmeden parçalar kesime +700 çağrı ekliyordu)
static func pis(n: Node3D) -> void:
	if n != null and n.is_inside_tree():
		Props.bake_static(n, [n])


## Gedik molozunun boy kesiti (yerel z → y). Profil noktaları gedik ortasından (x = gx) geçen eğri; en 7 m.
static func moloz_profil(a: RefCounted) -> Dictionary:
	var d: Dictionary = a.d
	var zo0 := float(d["zo0"])
	var zo1 := float(d["zo1"])
	var zm0 := float(d["zm0"])
	var dy: float = a.dy
	var MD := float(d["MD"])
	var pts := [
		Vector2(zo0 - 7.0, a.y_peri() - 0.02),
		Vector2(zo0 - 1.4, 0.78),
		Vector2(zo0, 1.12),
		Vector2((zo0 + zo1) * 0.5, 1.30),
		Vector2(zo1, 1.12),
		# terasa iniş bütün terasa yayılır (dış kademe dy aşağıdaysa şev ≤ ~30°; Mesoteikhion dy −3,7)
		Vector2(lerpf(zo1, zm0 - 1.0, 0.5), lerpf(1.12, dy + 0.15, 0.55)),
		Vector2(zm0 - 1.0, dy + 0.15),
		Vector2(zm0 + 0.2, dy + 0.02),
		Vector2(zm0 + 13.0, dy - MD + 0.02),
	]
	return {"pts": pts, "peri_z": zo0 - 5.0, "peri_y": _profil_y(pts, zo0 - 5.0), "tepe_y": 1.30, "teras_z": zo1 + 6.0,
		"teras_y": _profil_y(pts, zo1 + 6.0), "dip_z": zm0 + 14.5}


static func _profil_y(pts: Array, z: float) -> float:
	for i in pts.size() - 1:
		var p: Vector2 = pts[i]
		var q: Vector2 = pts[i + 1]
		if z >= p.x and z <= q.x:
			return lerpf(p.y, q.y, (z - p.x) / maxf(q.x - p.x, 0.001))
	return (pts[0] as Vector2).y if z < (pts[0] as Vector2).x else (pts[pts.size() - 1] as Vector2).y


## Boy kesiti verilen tümsek: üst yüz (en `w`, kenarlara doğru `omuz` m'de alçalır) + yan etekler `taban(z)`a kadar.
## Görünen ağ ve aynı üçgenlerden çarpışma (trimesh). pts: Vector2(z, y); x merkezde.
static func _tumsek(p: Node3D, x: float, pts: Array, w: float, omuz: float, taban: Callable, col: Color, ad: String, rng: RandomNumberGenerator) -> Array:
	var ag = KULE.Ag.new()
	var tris := PackedVector3Array()
	var hw := w * 0.5
	var ekle := func(a: Vector3, b: Vector3, c: Vector3, nrm: Vector3) -> void:
		ag.tri(a, b, c, nrm)
		tris.append_array([a, b, c])
	# boyuna ince adım (0,8 m), yanlara 4 şerit: orta düz, omuzlar alçalır; hafif oynak (moloz)
	var zs: Array = []
	for i in pts.size() - 1:
		var p0: Vector2 = pts[i]
		var p1: Vector2 = pts[i + 1]
		var nn := maxi(1, ceili((p1.x - p0.x) / 0.8))
		for k in nn:
			zs.append(lerpf(p0.x, p1.x, float(k) / nn))
	zs.append((pts[pts.size() - 1] as Vector2).x)
	var xs := [-hw - omuz, -hw, -hw * 0.35, hw * 0.35, hw, hw + omuz]
	var rows: Array = []
	for z: float in zs:
		var yc := _profil_y(pts, z)
		var tb: float = taban.call(z)
		var row: Array = []
		for j in xs.size():
			var xx: float = x + float(xs[j])
			var yy := yc
			if j == 0 or j == xs.size() - 1:
				yy = tb - 0.05
			elif j == 1 or j == xs.size() - 2:
				yy = lerpf(yc, tb, 0.35) + rng.randf_range(-0.05, 0.08)
			else:
				yy = yc + rng.randf_range(-0.04, 0.06)
			row.append(Vector3(xx, maxf(yy, tb - 0.05), z))
		rows.append(row)
	for i in rows.size() - 1:
		for j in xs.size() - 1:
			var a0: Vector3 = rows[i][j]
			var a1: Vector3 = rows[i][j + 1]
			var b0: Vector3 = rows[i + 1][j]
			var b1: Vector3 = rows[i + 1][j + 1]
			var nrm := (a1 - a0).cross(b0 - a0)
			# dış yön: orta şeritlerde yukarı, omuzlarda yana (yan yüzler içe dönük kalmasın: güneşte beyaz okunuyordu)
			var mx := (a0.x + a1.x) * 0.5 - x
			var dis := Vector3(signf(mx) * (1.0 if absf(mx) > hw * 0.5 else 0.0), 0.6, 0.0)
			if nrm.dot(dis) < 0.0:
				nrm = -nrm
			ekle.call(a0, a1, b1, nrm)
			ekle.call(a0, b1, b0, nrm)
	# uçlar kapalı (ilk ve son kesit: yelpaze)
	for uc in [0, rows.size() - 1]:
		var row: Array = rows[uc]
		var dz := -1.0 if uc == 0 else 1.0
		var tb2: float = taban.call((row[0] as Vector3).z)
		for j in xs.size() - 1:
			var p0: Vector3 = row[j]
			var p1: Vector3 = row[j + 1]
			if p0.y - tb2 < 0.03 and p1.y - tb2 < 0.03:
				continue
			ekle.call(p0, p1, Vector3(p1.x, tb2 - 0.05, p1.z), Vector3(0, 0, dz))
			ekle.call(p0, Vector3(p1.x, tb2 - 0.05, p1.z), Vector3(p0.x, tb2 - 0.05, p0.z), Vector3(0, 0, dz))
	var mi: MeshInstance3D = ag.mesh_ekle(p, Props.mat(col, 0.0, false, "rubble"), ad)
	if mi:
		mi.remove_meta("no_walk")
	var body := StaticBody3D.new()
	body.name = ad + "_Carp"
	var cs := CollisionShape3D.new()
	var sh := ConcavePolygonShape3D.new()
	sh.backface_collision = true
	sh.set_faces(tris)
	cs.shape = sh
	body.add_child(cs)
	p.add_child(body)
	return [mi, body]


