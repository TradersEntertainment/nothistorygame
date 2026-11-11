class_name Horn
## Haliç'in iç ucu, Mayıs 1453 (Bölüm 18 ve 18b): Osmanlı kıyısı z < 0'da, su 0'dan wall_z'ye, karşıda Haliç surları
## ve ardında Blakherna yamacına tırmanan şehir. Her iki bölüm aynı coğrafyayı iki yandan görür.
##   · Osmanlı kıyısı: kumsal, çalışma alanının ardında tepelere yayılan ordugâh, ağaçlar; kıyı boyunca fıçı yığınları,
##     kalas istifleri, halat, marangoz tezgâhları, arabalar, çalışan ve bekleyen askerler; demirli kadırgalar, kayıklar
##   · Haliç surları: taş gövde, mazgallar, kuleler (wall_gap aralığı bölümün kendi sur parçasına bırakılır)
##   · şehir: evler, kiliseler, serviler, Blakherna sarayı (tuğla-taş bantlı), Kariye'nin kubbesi
## work: Osmanlı kıyısında düz kalacak oynanış alanı (x, z); boşsa yok.
## Tek harita (world := true): yalnız bölümün çevresi (x ±WORLD_E) kurulur; uzak şehir, karşı kıyının ötesi, Haliç'in
## devamı World1453'ten gelir (bölüm World1453.build'i ayrıca çağırır). shore := false: Osmanlı kıyısı kurulmaz (karşı
## kıyı uzaktadır, dünyanınkidir); no_city: karşıda şehir suru yok (31o Eyüp: karşı kıyı da surların dışı).

const WOOD := Color("7a5634")
const STONE := Color("cdbd9e")
const COATS := [Color("b3262d"), Color("2f5fa8"), Color("3a6b3a"), Color("8a6a4a"), Color("6a4a3a"), Color("c98a3a")]
const WORLD_E := 220.0


static func build(parent: Node3D, wall_z: float, work: Rect2, wall_gap := Vector2.ZERO, seed := 18, world := false, no_city := false, with_shore := true) -> void:
	var E := WORLD_E if world else 700.0
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var shore := func(x: float, z: float) -> float:
		var hills := 0.35 + smoothstep(-8.0, -120.0, z) * (12.0 + 7.0 * sin(x * 0.012 + 0.4) + 4.0 * cos(x * 0.027 + z * 0.013))
		hills += smoothstep(-160.0, -460.0, z) * 24.0
		hills = lerpf(hills, -1.2, clampf((z + 6.0) / 6.0, 0.0, 1.0))      # kumsal suya iner
		if work.size == Vector2.ZERO:
			return hills
		var d := maxf(maxf(work.position.x - x, x - work.end.x), maxf(work.position.y - z, z - work.end.y))
		return lerpf(0.29, hills, smoothstep(0.0, 24.0, d))
	var byz := func(x: float, z: float) -> float:
		return 0.6 + smoothstep(wall_z + 8.0, wall_z + 170.0, z) * (20.0 + 6.0 * sin(x * 0.01 + 1.0)) + smoothstep(wall_z + 200.0, wall_z + 520.0, z) * 16.0
	# --- Su (tek haritada dünyanın Haliç suyu; aynı gölgelendirici, dalgalar dünya koordinatında sürer)
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	var wl := wall_z + 14.0
	pm.size = Vector2(E * 2.0, wl)
	pm.subdivide_width = int(E * 0.37)
	pm.subdivide_depth = int(wl / 5.0)
	w.mesh = pm
	var sh := ShaderMaterial.new()
	sh.shader = load("res://assets/shaders/water.gdshader")
	w.material_override = sh
	w.position = Vector3(0, 0.03 if world else 0.0, wl * 0.5 - 10.0)
	w.name = "Water"
	if not world:
		parent.add_child(w)
	else:
		w.free()
	# --- Arazi: Osmanlı kıyısı ve karşı yamaç
	var scf := func(x: float, z: float, y: float, steep: float) -> Color:
		var g := Color("5e7040").lerp(Color("8a8050"), clampf(0.5 + 0.5 * sin(x * 0.037 + z * 0.029), 0.0, 1.0) * 0.5)
		g = g.darkened(clampf(steep * 0.6, 0.0, 0.3))
		if y < 0.6 and z > -8.0:
			g = Color("9a8660")                     # kumsal
		if work.size != Vector2.ZERO:
			# Çalışma alanı çiğnenmiş toprak; kenarında çimene karışır
			var d := maxf(maxf(work.position.x - x, x - work.end.x), maxf(work.position.y - z, z - work.end.y))
			g = Color("6e5e42").lerp(g, smoothstep(-4.0, 22.0, d))
		return g.lerp(Color("8a9a98"), smoothstep(-240.0, -520.0, z) * 0.5)    # uzak tepeler havaya karışır
	var shore_side := not world or with_shore
	if shore_side:
		parent.add_child(LowPoly.solid(LowPoly.terrain(-E, E, -E if world else -520.0, 0.5, int(E / 10.0), 40 if not world else 22, shore, scf)))
	var bcf := func(x: float, z: float, y: float, steep: float) -> Color:
		# Şehir zemini: toprak sokaklar, arada bostan ve bahçe lekeleri
		return Color("8e7c5c").lerp(Color("6a7446"), clampf(0.5 + 0.5 * sin(x * 0.05 - z * 0.04), 0.0, 1.0) * 0.4).darkened(clampf(steep * 0.5, 0.0, 0.25))
	if not world:
		parent.add_child(LowPoly.terrain(-700.0, 700.0, wall_z + 2.0, wall_z + 560.0, 56, 28, byz, bcf))
	if not no_city:
		_sea_wall(parent, wall_z, wall_gap, rng, E)
	if not world:
		_city(parent, wall_z, byz, rng)
	if shore_side:
		# Çadırlar, ağaçlar, eşyalar görünen kıyı arazisine oturur (ızgara köşeleri arasında analitik yükseklik sapar)
		var sz0 := -E if world else -520.0
		var snx := int(E / 10.0)
		var snz := 40 if not world else 22
		var surf := func(x: float, z: float) -> float:
			return LowPoly.surface_y(x, z, -E, E, sz0, 0.5, snx, snz, shore)
		_ottoman_shore(parent, work, surf, rng, world)


## Haliç surları: su kenarından yükselen tek sur, mazgallar, 45 m arayla kuleler.
static func _sea_wall(parent: Node3D, wall_z: float, gap: Vector2, rng: RandomNumberGenerator, E := 700.0) -> void:
	var h := 9.6
	var d := Dressing.new(181)
	d.chunk = 160.0
	var merl: Array = []
	for seg in [[-E, gap.x], [gap.y, E]]:
		var a: float = seg[0]
		var b: float = seg[1]
		if b - a < 1.0:
			continue
		var cx := (a + b) * 0.5
		Props.set_pattern(Props.box(parent, Vector3(b - a, h + 1.0, 3.0), Vector3(cx, (h - 1.0) * 0.5, wall_z + 1.5), Color.WHITE), STONE, "ashlar")
		Props.box(parent, Vector3(b - a, 1.2, 3.2), Vector3(cx, -0.1, wall_z + 1.5), STONE.darkened(0.35))   # su çizgisinde yosun
		var x := a + 1.0
		while x < b - 0.5:
			merl.append(Transform3D(Basis.from_scale(Vector3(1.2, 1.1, 0.6)), Vector3(x, h + 0.55, wall_z + 0.3)))
			x += 2.5
	var tx := -E + rng.randf_range(0.0, 20.0)
	while tx < E:
		if tx < gap.x - 6.0 or tx > gap.y + 6.0:
			var th := rng.randf_range(14.0, 17.0)
			var t := Props.box(parent, Vector3(7.0, th + 1.0, 7.0), Vector3(tx, (th - 1.0) * 0.5, wall_z + 1.2), Color.WHITE)
			Props.set_pattern(t, STONE.darkened(0.04), "ashlar")
			d.box(Vector3(7.8, 0.5, 7.8), Vector3(tx, th + 0.25, wall_z + 1.2), STONE.darkened(0.12))
			for k in 8:
				d.box(Vector3(1.1, 1.0, 1.0), Vector3(tx - 3.3 + (k % 4) * 2.2, th + 1.0, wall_z + 1.2 + (-3.3 if k < 4 else 3.3)), STONE.darkened(0.08))
			for k in 2:
				d.box(Vector3(0.7, 1.2, 0.1), Vector3(tx - 1.5 + k * 3.0, h + 2.0, wall_z - 2.33), Color("1c1814"))
			if rng.randf() < 0.5:
				d.box(Vector3(0.1, 3.0, 0.1), Vector3(tx, th + 2.3, wall_z + 1.2), Color("3a2a1e"))
				d.box(Vector3(1.6, 1.0, 0.03), Vector3(tx + 0.8, th + 3.3, wall_z + 1.2), Color("d8b040") if rng.randf() < 0.5 else Color("8a1a2a"))
		tx += 45.0 + rng.randf_range(-4.0, 4.0)
	Scenery.scatter(parent, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(STONE.darkened(0.08)))
	# Surun üstünde savunanlar (uzak siluet)
	var men: Array = []
	var x2 := -minf(500.0, E)
	while x2 < minf(500.0, E):
		if x2 < gap.x - 4.0 or x2 > gap.y + 4.0:
			men.append(Transform3D(Basis(Vector3.UP, PI), Vector3(x2, h, wall_z + 1.0)))
		x2 += rng.randf_range(10.0, 26.0)
	Garrison.far_men(parent, men, Garrison.COATS)
	d.build(parent)


## Surun ardında şehir: Blakherna yamacı.
static func _city(parent: Node3D, wall_z: float, hf: Callable, rng: RandomNumberGenerator) -> void:
	var hx: Array = []
	var hc: Array = []
	var wd := Dressing.new(184)
	wd.chunk = 160.0
	for i in 1300:
		# İlk 560 ev sura yakın sık mahalleler; kalanı yamaca yayılır
		var x := rng.randf_range(-330.0, 330.0) if i < 560 else rng.randf_range(-680.0, 680.0)
		var z := wall_z + 12.0 + (rng.randf() * 130.0 if i < 560 else 60.0 + pow(rng.randf(), 1.3) * 420.0)
		var near := z < wall_z + 70.0
		# Sura yakın evler alçak (surun ardında kalır, çatıları görünür); uzaktakiler yamaçta yükselir
		var s := Vector3(rng.randf_range(5.0, 10.0), rng.randf_range(4.5, 7.5) if near else rng.randf_range(4.5, 10.0), rng.randf_range(5.0, 9.0))
		var yaw := rng.randf_range(-0.2, 0.2)
		var y: float = hf.call(x, z)
		hx.append(Scenery._t(Vector3(x, y - 0.4, z), Vector3(0, yaw, 0), s))
		hc.append([Color("d8c4a4"), Color("c8a888"), Color("b89a80"), Color("d0b890"), Color("c89a78"), Color("b8b0a0")][i % 6])
		if near:
			# Suya bakan cephede pencereler ve kapı
			wd.at(Vector3(x, y - 0.4, z), yaw)
			var nw := int(s.x / 2.2)
			for k in nw:
				for f in (2 if s.y > 6.0 else 1):
					wd.box(Vector3(0.7, 1.0, 0.08), Vector3(-s.x * 0.5 + (k + 0.5) * s.x / nw, 2.4 + f * 2.6, -s.z * 0.5 - 0.03), Color("3a2a20"))
			wd.box(Vector3(1.1, 2.0, 0.08), Vector3(rng.randf_range(-s.x * 0.3, s.x * 0.3), 1.4, -s.z * 0.5 - 0.03), Color("5a3a22"))
	Scenery.scatter(parent, Scenery.house_mesh(), hx, hc)
	wd.build(parent)
	for i in 12:
		var p := Vector3(rng.randf_range(-560.0, 560.0), 0, wall_z + rng.randf_range(40.0, 380.0))
		p.y = hf.call(p.x, p.z) - 0.3
		var r := rng.randf_range(5.0, 8.0)
		Props.box(parent, Vector3(r * 2.4, r * 1.3, r * 2.0), p + Vector3(0, r * 0.65, 0), Color("b87060"))
		Props.cyl(parent, r * 0.62, r * 0.55, p + Vector3(0, r * 1.55, 0), Color("c8a890"), Vector3.ZERO, 12)
		Props.ball(parent, r * 0.64, p + Vector3(0, r * 1.82, 0), Color("8a98a8"), Vector3(1, 0.7, 1), 14)
	# Blakherna sarayı (Tekfur Sarayı gibi: tuğla-taş bantlı üç katlı cephe, kemerli pencereler) ve Kariye'nin kubbesi
	var bp := Vector3(-90.0, 0, wall_z + 70.0)
	bp.y = hf.call(bp.x, bp.z) - 0.5
	Props.set_pattern(Props.box(parent, Vector3(28.0, 20.0, 14.0), bp + Vector3(0, 10.0, 0), Color.WHITE), Color("c89a78"), "tekfur")
	for k in 6:
		for f in 2:
			Props.box(parent, Vector3(1.6, 2.6, 0.2), bp + Vector3(-10.0 + k * 4.0, 8.0 + f * 6.0, -7.05), Color("2a2018"))
	Props.box(parent, Vector3(29.0, 0.8, 15.0), bp + Vector3(0, 20.2, 0), Color("a86a4a"))
	for k in 12:
		Props.box(parent, Vector3(1.2, 1.2, 1.2), bp + Vector3(-13.5 + k * 2.45, 21.2, -7.0), Color("b8906a"))
	var cp := Vector3(70.0, 0, wall_z + 150.0)
	cp.y = hf.call(cp.x, cp.z) - 0.3
	Props.box(parent, Vector3(22.0, 12.0, 18.0), cp + Vector3(0, 6.0, 0), Color("c08068"))
	Props.cyl(parent, 5.5, 4.0, cp + Vector3(0, 14.0, 0), Color("c8a890"), Vector3.ZERO, 14)
	Props.ball(parent, 5.7, cp + Vector3(0, 16.0, 0), Color("7a8898"), Vector3(1, 0.7, 1), 14)
	var cyp: Array = []
	for i in 300:
		var x := rng.randf_range(-680.0, 680.0)
		var z := wall_z + rng.randf_range(8.0, 480.0)
		var sc := rng.randf_range(0.9, 1.5)
		cyp.append(Scenery._t(Vector3(x, hf.call(x, z) - 0.1, z), Vector3.ZERO, Vector3(sc, sc * 1.2, sc)))
	Scenery.scatter(parent, Scenery.cypress_mesh(), cyp, [])


## Osmanlı kıyısı: ordugâh tepelerde, kıyı boyunca köprü malzemesi ve çalışanlar, demirli kadırgalar ve kayıklar.
static func _ottoman_shore(parent: Node3D, work: Rect2, hf: Callable, rng: RandomNumberGenerator, world := false) -> void:
	var avoid := [Rect2(-800.0, -70.0, 1600.0, 1200.0)]      # kıyı şeridi ve su: çadır da ağaç da yok
	if work.size != Vector2.ZERO:
		avoid.append(work.grow(26.0))
	var E := WORLD_E if world else 700.0
	if world:
		# Bölümün çevresi: yakın ordugâh ve ağaçlar (ötesi dünyanın kuzey kıyısı)
		Scenery.camp(parent, Vector3(0, 0, -150), 0.0, 150.0, 260, avoid, hf, 18301, false)
		Scenery.trees(parent, Vector3(0, 0, -150), 40.0, 170.0, 90, avoid, hf, 18305)
	else:
		Scenery.camp(parent, Vector3(0, 0, -300), 0.0, 260.0, 900, avoid, hf, 18301, false)
		for sx: float in [-1.0, 1.0]:
			Scenery.camp(parent, Vector3(sx * 400.0, 0, -240), 0.0, 210.0, 380, avoid, hf, 18302 + int(sx), false)
		Scenery.trees(parent, Vector3(0, 0, -260), 40.0, 300.0, 260, avoid, hf, 18305)
		for sx: float in [-1.0, 1.0]:
			Scenery.trees(parent, Vector3(sx * 470.0, 0, -200), 20.0, 220.0, 150, avoid, hf, 18306 + int(sx))
	# Kıyı boyunca: fıçı dağları, kalas istifleri, halat, tezgâh, araba, çadır; askerler ve işçiler
	var d := Dressing.new(183)
	d.chunk = 160.0
	var men: Array = []
	var x := -minf(420.0, E - 10.0)
	while x < minf(420.0, E - 10.0):
		x += rng.randf_range(9.0, 18.0)
		var z := rng.randf_range(-40.0, -12.0)
		if work.size != Vector2.ZERO and work.grow(6.0).has_point(Vector2(x, z)):
			continue
		var p := Vector3(x, hf.call(x, z), z)
		var kind := rng.randi() % 6
		d.at(p, rng.randf() * TAU)
		match kind:
			0, 1:
				# Fıçı dağı: yatık fıçılar, üç kat
				for row in 3:
					for k in 5 - row:
						d.cyl(0.4, 1.2, Vector3(-1.6 + k * 0.82 + row * 0.41, 0.4 + row * 0.7, 0), WOOD.darkened(rng.randf() * 0.15), Vector3(90, 0, 0), 10)
						d.cyl(0.41, 0.06, Vector3(-1.6 + k * 0.82 + row * 0.41, 0.4 + row * 0.7, 0.4), Color("3a3634"), Vector3(90, 0, 0), 10)
			2:
				for i in 7:
					d.box(Vector3(0.5, 0.1, 3.6), Vector3(0, 0.1 + i * 0.12, 0), Color("9a7248").darkened((i % 3) * 0.05))
				d.rope_coil(Vector3(1.2, 0, 0.8))
			3:
				# Fıçı arabası: iki tekerlek, üstünde dikili fıçılar, oku yerde
				d.box(Vector3(1.6, 0.14, 2.6), Vector3(0, 0.75, 0), WOOD)
				for sx: float in [-0.95, 0.95]:
					d.cyl(0.6, 0.12, Vector3(sx, 0.6, 0), Color("4a3020"), Vector3(0, 0, 90), 10)
				for k in 3:
					d.cyl(0.36, 0.85, Vector3(-0.4 + (k % 2) * 0.8, 1.25, -0.7 + k * 0.7), WOOD.darkened(0.1), Vector3.ZERO, 10)
				d.box(Vector3(0.1, 0.1, 2.2), Vector3(0, 0.45, 2.3), WOOD.darkened(0.3), Vector3(-12, 0, 0))
			4:
				d.box(Vector3(2.2, 0.12, 0.9), Vector3(0, 0.8, 0), WOOD)
				for k in 4:
					d.box(Vector3(0.1, 0.8, 0.1), Vector3(-1.0 + (k % 2) * 2.0, 0.4, -0.35 + (k / 2) * 0.7), WOOD.darkened(0.3))
				d.box(Vector3(1.6, 0.08, 0.4), Vector3(0.1, 0.9, 0.1), Color("b8905a"))
			_:
				d.hay(Vector3.ZERO)
		for k in rng.randi_range(1, 3):
			var q := p + Vector3(rng.randf_range(-2.5, 2.5), 0, rng.randf_range(1.2, 2.5))
			q.y = hf.call(q.x, q.z)
			men.append([Transform3D(Basis(Vector3.UP, rng.randf() * TAU), q), COATS[rng.randi() % COATS.size()]])
	d.build(parent)
	figures(parent, men)
	# Kıyıya yakın çadırlar
	for i in 16:
		var p := Vector3(rng.randf_range(-minf(360.0, E - 10.0), minf(360.0, E - 10.0)), 0, rng.randf_range(-60.0, -44.0))
		if work.size != Vector2.ZERO and work.grow(10.0).has_point(Vector2(p.x, p.z)):
			continue
		p.y = hf.call(p.x, p.z) - 0.1
		var t := Night.tent(parent, p, rng.randf_range(2.0, 2.8), Color("e0d4b8"), [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a")][i % 3])
		t.rotation.y = rng.randf() * TAU
	# Demirli kadırgalar (kıçları kıyıya) ve Haliç'te kayıklar
	for i in 9:
		var gx := 70.0 + i * 26.0 + rng.randf_range(-4.0, 4.0)
		galley(parent, Vector3(gx, 0, 13.0 + rng.randf_range(-1.5, 1.5)), rng.randf_range(-0.08, 0.08))
	for i in 5:
		var gx := -90.0 - i * 30.0 + rng.randf_range(-4.0, 4.0)
		galley(parent, Vector3(gx, 0, 12.0 + rng.randf_range(-1.5, 1.5)), rng.randf_range(-0.08, 0.08))
	for i in 10:
		var bx := rng.randf_range(-70.0, 70.0)
		if absf(bx) < 12.0:
			bx = signf(bx if bx != 0.0 else 1.0) * rng.randf_range(12.0, 40.0)
		rowboat(parent, Vector3(bx, 0, rng.randf_range(4.0, 12.0)), rng.randf() * TAU)


## [Transform3D, kaftan rengi] listesi → her renk bir MultiMesh (uzak askerler).
static func figures(parent: Node3D, list: Array, solid := false) -> void:
	var items: Array = []
	var i := 0
	for it in list:
		items.append([it[0], {"side": "O", "coat": it[1], "hat": "bork" if i % 3 != 2 else "turban", "arm": ["spear", "", ""][i % 3]}])
		i += 1
	Crowd.place(parent, items, true, solid)


## Kadırga: uzun alçak gövde (baş +z, suya), direk ve sarılı yelken, iki yanda kürek sırası, kıçta köşk, sancak.
static func galley(parent: Node3D, p: Vector3, yaw: float, lantern := false) -> Node3D:
	var g := Node3D.new()
	g.position = p + Vector3(0, -0.4, 0)
	g.rotation.y = yaw
	parent.add_child(g)
	g.add_child(LowPoly.hull([
		{"z": -10.0, "w": 0.3, "top": 2.6, "bottom": 1.2},
		{"z": -7.0, "w": 1.5, "top": 2.0, "bottom": 0.2},
		{"z": 0.0, "w": 1.9, "top": 1.9, "bottom": 0.1},
		{"z": 6.0, "w": 1.5, "top": 2.0, "bottom": 0.3},
		{"z": 10.5, "w": 0.1, "top": 2.6, "bottom": 1.3},
	], Color("3a2a1c"), Color("7e2420"), 1.8))
	var d := Dressing.new(int(p.x * 13.0 + p.z))
	d.box(Vector3(3.2, 0.1, 15.0), Vector3(0, 1.9, 0), Color("8a6a44"))
	d.cyl(0.14, 11.0, Vector3(0, 7.3, 1.0), Color("4a3420"), Vector3.ZERO, 6)
	d.cyl(0.07, 9.0, Vector3(0, 9.5, 1.0), Color("4a3420"), Vector3(0, 0, 70), 5)
	d.cyl(0.35, 7.0, Vector3(0, 9.4, 1.0), Color("e8dcc0"), Vector3(0, 0, 70), 8)
	d.box(Vector3(2.8, 1.4, 2.6), Vector3(0, 2.6, -8.2), Color("6a2a20"))
	d.box(Vector3(3.0, 0.15, 2.8), Vector3(0, 3.35, -8.2), Color("d8b040"))
	for sx: float in [-1.0, 1.0]:
		for k in 10:
			d.box(Vector3(4.2, 0.07, 0.12), Vector3(sx * 3.2, 1.2, -6.0 + k * 1.25), Color("8a6a44"), Vector3(0, 0, sx * 18.0))
	d.cyl(0.05, 3.0, Vector3(0, 4.8, -9.0), Color("3a2a1e"), Vector3.ZERO, 5)
	d.box(Vector3(0.03, 1.0, 1.6), Vector3(0, 5.8, -9.8), Color("b3262d"))
	if lantern:
		d.glow(Vector3(0.35, 0.5, 0.35), Vector3(0, 4.2, -9.6), Color("ffb040"))
		d.glow(Vector3(0.25, 0.35, 0.25), Vector3(0, 11.5, 1.0), Color("ffc060"))
	d.build(g)
	return g


## Küçük kayık: gövde, iki kürek, bir kürekçi.
static func rowboat(parent: Node3D, p: Vector3, yaw: float) -> Node3D:
	var g := Node3D.new()
	g.position = p + Vector3(0, -0.2, 0)
	g.rotation.y = yaw
	parent.add_child(g)
	g.add_child(LowPoly.hull([
		{"z": -2.2, "w": 0.1, "top": 0.8, "bottom": 0.3},
		{"z": 0.0, "w": 0.8, "top": 0.6, "bottom": -0.1},
		{"z": 2.4, "w": 0.05, "top": 0.9, "bottom": 0.4},
	], Color("4a3422"), Color("6a4a2c"), 0.55))
	var d := Dressing.new(int(p.x * 7.0 + p.z))
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(2.2, 0.05, 0.1), Vector3(sx * 1.2, 0.45, 0.1), Color("9a7a50"), Vector3(0, sx * 10.0, sx * 14.0))
	d.build(g)
	figures(g, [[Transform3D(Basis(), Vector3(0, 0.1, 0.3)), COATS[int(absf(p.x)) % COATS.size()]]])
	return g
