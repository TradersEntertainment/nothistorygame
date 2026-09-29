class_name OuterWorld
extends RefCounted
## Uçuşta ufuk boş kalmasın: oynanan haritanın çevresini kilometrelerce dolduran dış dünya.
## Kaba ızgaralı arazi (40 m): içteki haritaların altında gizlenir, dışarıda kıyıdan uzaklaştıkça tepelere,
## ufukta dağlara yükselir; renkleri tarla lekeleri (buğday, çayır, sürülmüş toprak, zeytinlik), yamaçta orman,
## kıyıda kum. Deniz bölgeleri su düzlemi (ve suya inen Nihat'ı kaldıran alan) alır. Üstünde ağaçlar, köyler
## (kırmızı kiremitli ev kümeleri, küçük kilise), Osmanlı ordugâhları (çadırlar, sancaklar, duman) dağılır.
## Nihat bu arazinin her yerine konabilir (HeightMap çarpışması).
##
## cfg: y0 (harita zemini), wl (su yüksekliği, y0'a göre), inner: [Rect2] (içte zemini olan bölgeler),
##   water: [Rect2] (deniz), camps: [Rect2] (çadır bölgeleri), towns: [[Vector2, yarıçap, adet]], seed,
##   center: Vector2 (dağların uzaklığı buradan), extent (yarı genişlik, m)

const STEP := 40.0

var cfg: Dictionary
var _noise := FastNoiseLite.new()
var _noise2 := FastNoiseLite.new()


static func build(parent: Node3D, c: Dictionary) -> OuterWorld:
	var ow := OuterWorld.new()
	ow.cfg = c
	ow._noise.seed = int(c.get("seed", 1453))
	ow._noise.frequency = 0.0022
	ow._noise.fractal_octaves = 4
	ow._noise2.seed = int(c.get("seed", 1453)) + 7
	ow._noise2.frequency = 0.012
	var root := Node3D.new()
	root.name = "OuterWorld"
	parent.add_child(root)
	ow._terrain(root)
	ow._waters(root)
	ow._trees(root)
	ow._towns(root)
	ow._camps(root)
	return ow


func _in_rects(x: float, z: float, rects: Array, grow := 0.0) -> bool:
	for r in rects:
		if (r as Rect2).grow(grow).has_point(Vector2(x, z)):
			return true
	return false


func _dist_rects(x: float, z: float, rects: Array) -> float:
	var d := INF
	var p := Vector2(x, z)
	for r in rects:
		var rr := r as Rect2
		var dx := maxf(maxf(rr.position.x - x, 0.0), x - rr.end.x)
		var dz := maxf(maxf(rr.position.y - z, 0.0), z - rr.end.y)
		d = minf(d, Vector2(dx, dz).length())
	return d


func is_water(x: float, z: float) -> bool:
	return _in_rects(x, z, cfg.get("water", [])) and not _in_rects(x, z, cfg.get("inner", []))


## Dış arazinin yüksekliği (dünya y'si).
func height(x: float, z: float) -> float:
	var y0: float = cfg.get("y0", 0.0)
	var inner: Array = cfg.get("inner", [])
	var water: Array = cfg.get("water", [])
	if _in_rects(x, z, inner):
		# Gizli kısım iç haritanın gerçek zemininin altında kalmalı: ordugâhın ortası y=0'da, dış dünya y0=3.4'te;
		# 2.5'te kalınca alçaktan uçan Nihat ordugâhın zemini yerine soluk kum rengi bir düzlem görüyordu.
		# inner_floor (x, z → zemin) verilmişse 40 m ızgaranın komşu noktalarındaki en alçak zeminin 0.9 m altı.
		var f := y0
		var fl: Callable = cfg.get("inner_floor", Callable())
		if fl.is_valid():
			for dx in [-STEP, 0.0, STEP]:
				for dz in [-STEP, 0.0, STEP]:
					f = minf(f, float(fl.call(x + dx, z + dz)))
		return f - 0.9
	if _in_rects(x, z, water):
		return y0 + float(cfg.get("wl", 0.0)) - 4.0
	# İç haritanın hemen dışı: zeminin 3 cm altında düz etek (kenarda çukur ya da basamak görünmesin)
	if _in_rects(x, z, inner, STEP * 1.05):
		return y0 - 0.03
	var d := minf(_dist_rects(x, z, inner), _dist_rects(x, z, water))
	var ramp := smoothstep(0.0, 320.0, d)
	var c: Vector2 = cfg.get("center", Vector2.ZERO)
	var far := smoothstep(1400.0, 3200.0, Vector2(x, z).distance_to(c))
	var n := _noise.get_noise_2d(x, z) * 0.5 + 0.5
	var hills := 8.0 + n * 46.0
	var mountains := far * (60.0 + n * 190.0)
	var wshore := smoothstep(0.0, 60.0, _dist_rects(x, z, water))
	return y0 + 0.25 + (ramp * hills + mountains) * wshore


func _color(x: float, z: float, h: float) -> Color:
	var y0: float = cfg.get("y0", 0.0)
	var rel := h - y0
	if rel < 0.0:
		return Color("c8b888")
	if _dist_rects(x, z, cfg.get("water", [])) < 45.0 and rel < 6.0:
		return Color("d0c090")     # kumsal
	var fields := [Color("c8b060"), Color("7a9048"), Color("8a7048"), Color("8a9a58"), Color("a8a060")]
	var f := _noise2.get_noise_2d(x, z) * 0.5 + 0.5
	var col: Color = fields[clampi(int(f * fields.size()), 0, fields.size() - 1)]
	# Yamaçta orman, dağda kayalık ve çayır
	col = col.lerp(Color("4f6a3a"), smoothstep(30.0, 60.0, rel))
	col = col.lerp(Color("7a7a6a"), smoothstep(110.0, 200.0, rel))
	# İç haritanın kenarında onun zemin rengine karışır (kenar çizgisi görünmesin)
	var inner: Array = cfg.get("inner", [])
	var ic: Array = cfg.get("inner_colors", [])
	for i in mini(inner.size(), ic.size()):
		var d := _dist_rects(x, z, [inner[i]])
		if d < 260.0:
			col = col.lerp(ic[i], 1.0 - smoothstep(0.0, 260.0, d))
	return col


func _terrain(root: Node3D) -> void:
	var ext: float = cfg.get("extent", 4000.0)
	var c: Vector2 = cfg.get("center", Vector2.ZERO)
	var x0 := c.x - ext
	var z0 := c.y - ext
	var n := int(ext * 2.0 / STEP) + 1
	var verts := PackedVector3Array()
	var cols := PackedColorArray()
	var hs := PackedFloat32Array()
	verts.resize(n * n)
	cols.resize(n * n)
	hs.resize(n * n)
	for j in n:
		for i in n:
			var x := x0 + i * STEP
			var z := z0 + j * STEP
			var h := height(x, z)
			var id := j * n + i
			hs[id] = h
			verts[id] = Vector3(x, h, z)
			cols[id] = _color(x, z, h)
	var norms := PackedVector3Array()
	norms.resize(n * n)
	for j in n:
		for i in n:
			var hl := hs[j * n + maxi(i - 1, 0)]
			var hr := hs[j * n + mini(i + 1, n - 1)]
			var hd := hs[maxi(j - 1, 0) * n + i]
			var hu := hs[mini(j + 1, n - 1) * n + i]
			norms[j * n + i] = Vector3(hl - hr, 2.0 * STEP, hd - hu).normalized()
	var idx := PackedInt32Array()
	idx.resize((n - 1) * (n - 1) * 6)
	var k := 0
	for j in n - 1:
		for i in n - 1:
			var a := j * n + i
			idx[k] = a
			idx[k + 1] = a + 1
			idx[k + 2] = a + n
			idx[k + 3] = a + 1
			idx[k + 4] = a + n + 1
			idx[k + 5] = a + n
			k += 6
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_COLOR] = cols
	arr[Mesh.ARRAY_INDEX] = idx
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	# Yalnız üst yüz: iç haritanın zemini bu arazinin gizli kısmından alçaktaysa (ordugâh y=0, dış dünya y0-0.9)
	# alt yüz yerden bakana gökyüzünü tavan gibi örtüyordu
	mat.cull_mode = BaseMaterial3D.CULL_BACK
	mat.roughness = 1.0
	var mi := MeshInstance3D.new()
	mi.mesh = am
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.name = "Terrain"
	root.add_child(mi)
	var hm := HeightMapShape3D.new()
	hm.map_width = n
	hm.map_depth = n
	var scaled := PackedFloat32Array()
	scaled.resize(hs.size())
	for i in hs.size():
		scaled[i] = hs[i] / STEP
	hm.map_data = scaled
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = hm
	cs.scale = Vector3.ONE * STEP
	body.position = Vector3(c.x, 0, c.y)
	body.add_child(cs)
	root.add_child(body)


func _waters(root: Node3D) -> void:
	var y: float = cfg.get("y0", 0.0) + float(cfg.get("wl", 0.0))
	var mat := CityPanorama.water_mat()
	for r in cfg.get("water", []):
		var rr := r as Rect2
		var m := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = rr.size
		m.mesh = pm
		m.position = Vector3(rr.get_center().x, y, rr.get_center().y)
		m.material_override = mat
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(m)
		CityPanorama.water_catch(root, Vector3(rr.size.x, 5.6, rr.size.y), Vector3(rr.get_center().x, y - 3.3, rr.get_center().y))


func _land_ok(x: float, z: float) -> bool:
	return not _in_rects(x, z, cfg.get("inner", []), 25.0) and not _in_rects(x, z, cfg.get("water", []), 15.0)


func _trees(root: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(cfg.get("seed", 1453)) + 3
	var c: Vector2 = cfg.get("center", Vector2.ZERO)
	var cyp: Array = []
	var pla: Array = []
	var tries := 0
	while cyp.size() + pla.size() < 3200 and tries < 20000:
		tries += 1
		var a := rng.randf() * TAU
		var r := sqrt(rng.randf()) * 2600.0
		var x := c.x + cos(a) * r
		var z := c.y + sin(a) * r
		if not _land_ok(x, z):
			continue
		var h := height(x, z)
		if h - float(cfg.get("y0", 0.0)) > 120.0:
			continue
		# Ağaçlar kümelenir (koru, bahçe): gürültü eşiği
		if _noise2.get_noise_2d(x * 3.0, z * 3.0) < -0.05:
			continue
		var sc := rng.randf_range(1.4, 2.6)
		var t := Transform3D(Basis.from_scale(Vector3(sc, sc * 1.2, sc)), Vector3(x, h - 0.3, z))
		if rng.randf() < 0.45:
			cyp.append(t)
		else:
			pla.append(t)
	Scenery.scatter(root, Scenery.cypress_mesh(), cyp, [])
	Scenery.scatter(root, Scenery.plane_tree_mesh(), pla, [])


## Köyler: kiremit çatılı ev kümeleri, ortada küçük kubbeli kilise ya da mescit, çevrede bahçe duvarları.
func _towns(root: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(cfg.get("seed", 1453)) + 11
	var xf: Array = []
	var cols: Array = []
	var tones := [Color("e8d8c0"), Color("d8c0a0"), Color("e0ccb0"), Color("c8b89c")]
	var towns: Array = cfg.get("towns", [])
	# Rastgele köyler de ekle (tarlaların arasında)
	var c: Vector2 = cfg.get("center", Vector2.ZERO)
	for i in 26:
		var a := rng.randf() * TAU
		var r := rng.randf_range(700.0, 2800.0)
		var p := Vector2(c.x + cos(a) * r, c.y + sin(a) * r)
		if _land_ok(p.x, p.y):
			towns.append([p, rng.randf_range(35.0, 70.0), rng.randi_range(14, 34)])
	for t in towns:
		var ctr: Vector2 = t[0]
		var rad: float = t[1]
		for i in int(t[2]):
			var a := rng.randf() * TAU
			var r := sqrt(rng.randf()) * rad
			var x := ctr.x + cos(a) * r
			var z := ctr.y + sin(a) * r
			if not _land_ok(x, z):
				continue
			var s := Vector3(rng.randf_range(5.0, 9.0), rng.randf_range(4.0, 7.5), rng.randf_range(5.0, 9.0))
			xf.append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU) * Basis.from_scale(s), Vector3(x, height(x, z) - 0.5, z)))
			cols.append(tones[rng.randi() % tones.size()])
		if _land_ok(ctr.x, ctr.y):
			var cp := Vector3(ctr.x, height(ctr.x, ctr.y), ctr.y)
			Props.box(root, Vector3(9, 8, 12), cp + Vector3(0, 3.0, 0), Color("c08068"))
			Props.cyl(root, 3.2, 2.5, cp + Vector3(0, 8.2, 0), Color("c8a890"), Vector3.ZERO, 10)
			Props.ball(root, 3.4, cp + Vector3(0, 9.4, 0), Color("7a8898"), Vector3(1, 0.7, 1), 10)
	Scenery.scatter(root, Scenery.house_mesh(), xf, cols)


## Çadırın zemini: iç haritanın düz zemininde y0, dışarıda arazi; su, oynanan alan (no_camp) ve dik yamaç olmaz (NAN).
func _camp_y(x: float, z: float) -> float:
	if _in_rects(x, z, cfg.get("no_camp", [])) or _in_rects(x, z, cfg.get("water", []), 12.0):
		return NAN
	if _in_rects(x, z, cfg.get("inner", [])):
		return float(cfg.get("y0", 0.0))
	if _in_rects(x, z, cfg.get("inner", []), STEP * 1.05):
		return NAN
	var h := height(x, z)
	if h - float(cfg.get("y0", 0.0)) > 60.0:
		return NAN
	return h


## Osmanlı ordugâhları: çadır kümeleri, sancak direkleri, duman sütunları.
func _camps(root: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(cfg.get("seed", 1453)) + 21
	var bands := [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a"), Color("c98a3a")]
	for bi in bands.size():
		var xf: Array = []
		for r in cfg.get("camps", []):
			var rr := r as Rect2
			var cnt := int(rr.get_area() / 3200.0 / bands.size())
			for i in cnt:
				var x := rng.randf_range(rr.position.x, rr.end.x)
				var z := rng.randf_range(rr.position.y, rr.end.y)
				var y := _camp_y(x, z)
				if is_nan(y):
					continue
				var sc := rng.randf_range(2.0, 3.4)
				xf.append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU) * Basis.from_scale(Vector3.ONE * sc), Vector3(x, y - 0.1, z)))
		Scenery.scatter(root, Scenery.tent_mesh(bands[bi]), xf, [])
	var poles: Array = []
	for r in cfg.get("camps", []):
		var rr := r as Rect2
		for i in int(rr.get_area() / 60000.0):
			var x := rng.randf_range(rr.position.x, rr.end.x)
			var z := rng.randf_range(rr.position.y, rr.end.y)
			var h := _camp_y(x, z)
			if is_nan(h):
				continue
			Props.cyl(root, 0.15, 9.0, Vector3(x, h + 4.5, z), Color("4a3a2a"), Vector3.ZERO, 5)
			Props.box(root, Vector3(0.05, 2.2, 3.6), Vector3(x, h + 7.6, z + 1.8), [Color("c8262f"), Color("2e7a3a"), Color("f2e6c9")][i % 3])
			if i % 3 == 0 and poles.size() < 6:
				poles.append(Vector3(x + 20.0, h, z + 10.0))
	for p in poles:
		Scenery.smoke_column(root, p)
