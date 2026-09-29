class_name CityPanorama
extends RefCounted
## Ordugâhın (CampDay) kara surlarının ardındaki Konstantinopolis: Nihat'ın uçarak gittiği şehir manzarası.
## Yedi tepe (yumuşak tümsekler) üstünde binlerce ev (tek MultiMesh), tepelerde yapılar:
##   Ayasofya (kubbesine konulur), Hipodrom (spina: Dikilitaş, Yılanlı Sütun, Örme Dikilitaş), Konstantin Sütunu,
##   Havariyun Kilisesi (beş kubbe), Bozdoğan Kemeri, Blakherna Sarayı; kuzeyde Haliç ve ağzında zincir (kütükler),
##   zincirin içinde Hristiyan gemileri, karşıda Galata ve Galata Kulesi; güneyde Marmara ve deniz surları,
##   doğuda Boğaz, Osmanlı donanması ve Asya kıyısı. Coğrafya sıkıştırılmıştır (uçuşla 1-2 dakikalık şehir).
## Koordinatlar: surlar z = WALL_Z boyunca, şehir +z yönünde; x < 0 Haliç tarafı, x > 0 Marmara tarafı.

const WALL_Z := 118.0
const HORN_X := -236.0
const SEA_X := 246.0
const TIP_Z := 452.0
## Yedi tepe: [x, z, yarıçap, yükseklik]
const HILLS := [
	[40.0, 392.0, 72.0, 14.0], [66.0, 300.0, 60.0, 15.0], [-20.0, 334.0, 62.0, 18.0], [-64.0, 240.0, 72.0, 20.0],
	[-146.0, 262.0, 60.0, 14.0], [-192.0, 158.0, 55.0, 12.0], [126.0, 198.0, 72.0, 16.0],
]
const GALATA_HILL := [-420.0, 410.0, 90.0, 30.0]

const AYA := Vector3(40.0, 0, 392.0)
const HIPPO := Vector3(138.0, 0, 360.0)
const COLUMN := Vector3(66.0, 0, 300.0)
const APOSTLES := Vector3(-64.0, 0, 240.0)
const AQUEDUCT_Z := 288.0
const BLACHERNAE := Vector3(-200.0, 0, 150.0)
const GALATA_TOWER := Vector3(-420.0, 0, 398.0)
const CHAIN_Z := 458.0

const C_GROUND := Color("8a7c5c")
const C_BRICK := Color("9a4e36")
const C_STONE := Color("c8b898")
const C_LEAD := Color("5c6a7c")
const C_WATER := Color("3e6e8e")


## Döndür, sonra yerel ölçekle (Scenery._t küresel ölçekler; döndürülmüş kutular eğrilir)
static func _tx(pos: Vector3, rot := Vector3.ZERO, scl := Vector3.ONE) -> Transform3D:
	return Transform3D(Basis.from_euler(rot) * Basis.from_scale(scl), pos)


static func hill_h(x: float, z: float) -> float:
	var h := 0.0
	for hl in HILLS + [GALATA_HILL]:
		var d := Vector2(x - hl[0], z - hl[1]).length()
		if d < hl[2]:
			h = maxf(h, hl[3] / hl[2] * sqrt(hl[2] * hl[2] - d * d))
	return h


static func _on(p: Vector3) -> Vector3:
	return Vector3(p.x, hill_h(p.x, p.z), p.z)


## Kurar; seyir noktalarını parent'ın yerel koordinatında döndürür: [[id, konum, yarıçap], ...]
## Gece ışıkları (pencereler, Ayasofya'nın kandilleri) "night" adlı düğümde, gizli başlar.
static func build(parent: Node3D, base_y: float) -> Array:
	var root := Node3D.new()
	root.name = "CityPanorama"
	root.position = Vector3(0, base_y, 0)
	parent.add_child(root)
	var night := Node3D.new()
	night.name = "night"
	night.visible = false
	root.add_child(night)
	_terrain(root)
	_water(root)
	var windows: Array = []
	_houses(root, windows)
	var aya := _on(AYA)
	Scenery.hagia_sophia(root, aya, 1.0, true, true)
	_aya_night(night, aya)
	_hippodrome(root, _on(HIPPO))
	_column(root, _on(COLUMN))
	_apostles(root, _on(APOSTLES))
	_aqueduct(root)
	_blachernae(root, _on(BLACHERNAE), windows)
	_horn(root)
	_galata(root, windows)
	_bosphorus(root)
	_sea_walls(root)
	_window_lights(night, windows)
	var y := base_y
	return [
		["AYASOFYA", aya + Vector3(0, 46 + y, 0), 48.0],
		["HIPODROM", _on(HIPPO) + Vector3(0, 12 + y, 0), 60.0],
		["KONSTANTIN", _on(COLUMN) + Vector3(0, 30 + y, 0), 26.0],
		["HAVARIYUN", _on(APOSTLES) + Vector3(0, 24 + y, 0), 38.0],
		["BOZDOGAN", Vector3(-10, 26 + y, AQUEDUCT_Z), 34.0],
		["ZINCIR", Vector3((HORN_X - 350.0) * 0.5, 8 + y, CHAIN_Z), 45.0],
		["GALATA", _on(GALATA_TOWER) + Vector3(0, 40 + y, 0), 34.0],
		["BLAKHERNA", _on(BLACHERNAE) + Vector3(0, 16 + y, 0), 34.0],
		["SURLAR", Vector3(0, 18 + y, WALL_Z + 9.0), 30.0],
	]


## Kuleleri, kubbeleri çarpışmalı yapar: Nihat üstlerine konabilir.
static func _collide(root: Node3D, shape: Shape3D, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = shape
	body.add_child(cs)
	body.position = pos
	root.add_child(body)


static func _terrain(root: Node3D) -> void:
	for hl in HILLS + [GALATA_HILL]:
		var col := C_GROUND if hl != GALATA_HILL else Color("7a7a52")
		var b := Props.ball(root, hl[2], Vector3(hl[0], 0, hl[1]), col, Vector3(1, hl[3] / hl[2], 1), 28)
		b.material_override = Props.mat(col, 0.0, false, "", false)
	# Şehrin zemini (tepelerin arası): kuru toprak, ordugâh çayırından ayrılsın
	var g := Props.box(root, Vector3(SEA_X - HORN_X, 0.2, TIP_Z - WALL_Z - 12.0), Vector3((SEA_X + HORN_X) * 0.5, 0.02, (TIP_Z + WALL_Z + 12.0) * 0.5), C_GROUND)
	g.material_override = Props.mat(C_GROUND.darkened(0.08), 0.0, false, "", false)


static func _water_plane(root: Node3D, size: Vector2, center: Vector3) -> void:
	var m := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = size
	m.mesh = pm
	m.position = center
	var mat := Props.mat(C_WATER, 0.0, false, "", false)
	mat.roughness = 0.15
	mat.metallic_specular = 0.8
	m.material_override = mat
	root.add_child(m)


static func _water(root: Node3D) -> void:
	# Haliç (kuzey), Marmara (güney), Boğaz (doğu, şehrin burnunun önü); yükseklik zeminin 0.15 m üstü
	_water_plane(root, Vector2(140, 400), Vector3(HORN_X - 70.0, 0.15, WALL_Z + 150.0))
	_water_plane(root, Vector2(700, 900), Vector3(SEA_X + 350.0, 0.15, 300.0))
	_water_plane(root, Vector2(1500, 700), Vector3(0, 0.12, TIP_Z + 350.0))


static func _houses(root: Node3D, windows: Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var keep_out := [
		Rect2(AYA.x - 60, AYA.z - 50, 120, 100), Rect2(HIPPO.x - 26, HIPPO.z - 72, 52, 144),
		Rect2(COLUMN.x - 16, COLUMN.z - 16, 32, 32), Rect2(APOSTLES.x - 34, APOSTLES.z - 34, 68, 68),
		Rect2(-50, AQUEDUCT_Z - 5, 80, 10), Rect2(BLACHERNAE.x - 30, BLACHERNAE.z - 22, 60, 44),
		Rect2(HORN_X - 20, WALL_Z, 40, 400), Rect2(-300, WALL_Z - 2, 600, 24), Rect2(SEA_X - 16, WALL_Z, 30, 400),
		Rect2(150, 390, 90, 60),   # Büyük Saray
	]
	var xf: Array = []
	var cols: Array = []
	var tones := [Color("e8d8c0"), Color("d8c0a0"), Color("c8a888"), Color("e0ccb0"), Color("b89478"), Color("d0b8a0")]
	var tries := 0
	while xf.size() < 1700 and tries < 8000:
		tries += 1
		var x := rng.randf_range(HORN_X + 12.0, SEA_X - 10.0)
		var z := rng.randf_range(WALL_Z + 24.0, TIP_Z - 6.0)
		var blocked := false
		for r in keep_out:
			if r.has_point(Vector2(x, z)):
				blocked = true
				break
		if blocked:
			continue
		var y := hill_h(x, z)
		var s := Vector3(rng.randf_range(5.0, 11.0), rng.randf_range(4.5, 10.0), rng.randf_range(5.0, 11.0))
		var rot := rng.randf() * 0.5 + (PI * 0.5 if rng.randf() < 0.5 else 0.0)
		xf.append(_tx(Vector3(x, y - 0.6, z), Vector3(0, rot, 0), s))
		cols.append(tones[rng.randi() % tones.size()])
		if rng.randf() < 0.3:
			var face := Basis(Vector3.UP, rot) * Vector3(0, 0, s.z * 0.5 + 0.06)
			windows.append(Vector3(x, y + s.y * rng.randf_range(0.35, 0.7), z) + face)
		# Arada bir servi (MultiMesh ayrı)
	Scenery.scatter(root, Scenery.house_mesh(), xf, cols)
	var cyp: Array = []
	for i in 260:
		var x := rng.randf_range(HORN_X + 12.0, SEA_X - 10.0)
		var z := rng.randf_range(WALL_Z + 24.0, TIP_Z - 6.0)
		var sc := rng.randf_range(1.0, 1.6)
		cyp.append(_tx(Vector3(x, hill_h(x, z) - 0.3, z), Vector3.ZERO, Vector3(sc, sc * 1.3, sc)))
	Scenery.scatter(root, Scenery.cypress_mesh(), cyp, [])
	# Semt kiliseleri: küçük kurşun kubbeler (şehir kubbelerle dolu okunsun)
	for i in 22:
		var p := Vector3(rng.randf_range(HORN_X + 30.0, SEA_X - 30.0), 0, rng.randf_range(WALL_Z + 40.0, TIP_Z - 30.0))
		var bad := false
		for r in keep_out:
			if r.grow(6.0).has_point(Vector2(p.x, p.z)):
				bad = true
		if bad:
			continue
		p = _on(p)
		var r := rng.randf_range(3.5, 6.0)
		Props.box(root, Vector3(r * 2.6, r * 1.4, r * 2.2), p + Vector3(0, r * 0.7, 0), C_BRICK.lightened(0.1))
		Props.cyl(root, r * 0.62, r * 0.5, p + Vector3(0, r * 1.65, 0), Color("c8a890"), Vector3.ZERO, 12)
		Props.ball(root, r * 0.64, p + Vector3(0, r * 1.9, 0), C_LEAD.lightened(0.2), Vector3(1, 0.7, 1), 12)


## Ayasofya gece: kasnak pencereleri ve gövde pencerelerinde kandil ışığı; kubbenin üstünde hafif hale.
static func _aya_night(night: Node3D, p: Vector3) -> void:
	Props.cyl(night, 17.3, 1.6, p + Vector3(0, 37.5, 0), Color("ffc860"), Vector3.ZERO, 40, -1.0, 3.0)
	for side in [-1, 1]:
		Props.box(night, Vector3(50, 2.2, 0.3), p + Vector3(0, 18, side * 38.2), Color("ffb040"), Vector3.ZERO, 2.2)
	var l := OmniLight3D.new()
	l.light_color = Color("ffb860")
	l.light_energy = 3.0
	l.omni_range = 60.0
	l.position = p + Vector3(0, 30, 0)
	night.add_child(l)


static func _hippodrome(root: Node3D, p: Vector3) -> void:
	var ln := 130.0
	var w := 36.0
	# Kum pist ve iki uzun tribün; güney ucunda yarım daire (sphendone), kuzeyde başlangıç kapıları (carceres)
	var sand := Props.box(root, Vector3(w, 0.4, ln), p + Vector3(0, 0.2, 0), Color("d8c090"))
	sand.material_override = Props.mat(Color("d8c090"), 0.0, false, "", false)
	for sx in [-1, 1]:
		Props.set_pattern(Props.box(root, Vector3(9, 11, ln), p + Vector3(sx * (w * 0.5 + 4.5), 5.5, 0), Color.WHITE), C_STONE, "ashlar_far")
		# Basamaklar (iç yüzde üç kademe)
		for k in 3:
			Props.box(root, Vector3(2.4, 2.6 + k * 3.0, ln), p + Vector3(sx * (w * 0.5 + 1.2 + k * 2.4), 1.3 + k * 1.5, 0), C_STONE.lightened(0.08))
	for i in 9:
		var a := PI * i / 8.0
		var c := p + Vector3(cos(a) * (w * 0.5 + 4.5), 5.5, ln * 0.5 + sin(a) * (w * 0.5 + 4.5))
		Props.set_pattern(Props.box(root, Vector3(9, 11, 10), c, Color.WHITE, Vector3(0, rad_to_deg(-a), 0)), C_STONE, "ashlar_far")
	Props.set_pattern(Props.box(root, Vector3(w + 18, 12, 8), p + Vector3(0, 6, -ln * 0.5 - 4), Color.WHITE), C_BRICK, "brick")
	for i in 8:
		Props.box(root, Vector3(3, 5, 0.3), p + Vector3(-w * 0.5 + 3 + i * 4.3, 2.5, -ln * 0.5 - 0.1), Color("2a2226"))
	# Kathisma (imparator locası): doğu tribününde
	Props.box(root, Vector3(10, 16, 14), p + Vector3(w * 0.5 + 12, 8, -10), C_BRICK.lightened(0.05))
	Props.ball(root, 5.0, p + Vector3(w * 0.5 + 12, 16, -10), C_LEAD, Vector3(1, 0.6, 1), 12)
	# Spina: alçak duvar ve üstündeki anıtlar
	Props.box(root, Vector3(3, 1.2, ln * 0.7), p + Vector3(0, 0.6, 0), C_STONE.darkened(0.1))
	var ob := p + Vector3(0, 1.2, -18)
	Props.box(root, Vector3(4, 4, 4), ob + Vector3(0, 2, 0), C_STONE.lightened(0.1))
	Props.cyl(root, 1.9, 19.0, ob + Vector3(0, 13.5, 0), Color("c89a8a"), Vector3.ZERO, 4, 0.9)
	Props.prism(root, Vector3(1.3, 1.6, 1.3), ob + Vector3(0, 23.8, 0), Color("c89a8a"))
	# Yılanlı Sütun: üç yılanın sarmal bronz gövdesi
	var sc := p + Vector3(0, 1.2, 4)
	for k in 3:
		var a := TAU * k / 3.0
		Props.cyl(root, 0.28, 8.0, sc + Vector3(cos(a) * 0.3, 4.0, sin(a) * 0.3), Color("5a4a2a"), Vector3(sin(a) * 4.0, 0, cos(a) * 4.0), 6)
		Props.ball(root, 0.45, sc + Vector3(cos(a) * 0.9, 8.2, sin(a) * 0.9), Color("5a4a2a"), Vector3(1.6, 0.8, 1), 8)
	# Örme Dikilitaş: kaba taş bloklardan, daha yüksek
	var wo := p + Vector3(0, 1.2, 28)
	Props.set_pattern(Props.cyl(root, 2.6, 30.0, wo + Vector3(0, 15, 0), Color.WHITE, Vector3.ZERO, 4, 1.2), C_STONE.darkened(0.15), "ashlar_far")
	_collide(root, _box(Vector3(5, 30, 5)), wo + Vector3(0, 15, 0))


static func _box(size: Vector3) -> BoxShape3D:
	var b := BoxShape3D.new()
	b.size = size
	return b


static func _cylshape(r: float, h: float) -> CylinderShape3D:
	var c := CylinderShape3D.new()
	c.radius = r
	c.height = h
	return c


## Konstantin Sütunu: forumun ortasında, porfir tamburlar (aralarında defne çelengi bantları), tepede haç.
static func _column(root: Node3D, p: Vector3) -> void:
	# Oval forum: çevresinde revak
	for i in 20:
		var a := TAU * i / 20.0
		Props.cyl(root, 0.5, 7.0, p + Vector3(cos(a) * 15.0, 3.5, sin(a) * 12.0), C_STONE.lightened(0.12), Vector3.ZERO, 8)
	Props.ring(root, 14.0, 15.8, p + Vector3(0, 7.2, 0), C_STONE, Vector3.ZERO).scale = Vector3(1, 0.6, 0.8)
	var fl := Props.box(root, Vector3(26, 0.3, 22), p + Vector3(0, 0.15, 0), Color("d8ccb4"))
	fl.material_override = Props.mat(Color("d8ccb4"), 0.0, false, "", false)
	Props.set_pattern(Props.box(root, Vector3(7, 6, 7), p + Vector3(0, 3, 0), Color.WHITE), C_STONE, "ashlar")
	var porf := Color("6e2a3a")
	Props.cyl(root, 1.7, 30.0, p + Vector3(0, 21, 0), porf, Vector3.ZERO, 16)
	for k in 7:
		Props.cyl(root, 1.85, 0.5, p + Vector3(0, 8 + k * 4.2, 0), Color("b89040"), Vector3.ZERO, 16)
	Props.box(root, Vector3(4.4, 1.6, 4.4), p + Vector3(0, 36.8, 0), C_STONE.lightened(0.1))
	Props.box(root, Vector3(0.5, 5.0, 0.5), p + Vector3(0, 40.1, 0), Color("d9b24a"), Vector3.ZERO, 0.3)
	Props.box(root, Vector3(2.6, 0.5, 0.5), p + Vector3(0, 41.2, 0), Color("d9b24a"), Vector3.ZERO, 0.3)
	_collide(root, _cylshape(1.8, 36.0), p + Vector3(0, 19.0, 0))
	_collide(root, _box(Vector3(4.4, 1.6, 4.4)), p + Vector3(0, 36.8, 0))


## Havariyun: haç planlı büyük kilise, beş kurşun kubbe; doğusunda imparator türbesi (rotunda).
static func _apostles(root: Node3D, p: Vector3) -> void:
	for arm in [[Vector3(60, 18, 15), Vector3.ZERO], [Vector3(15, 18, 56), Vector3.ZERO]]:
		Props.set_pattern(Props.box(root, arm[0], p + Vector3(0, 9, 0), Color.WHITE), C_BRICK, "brick")
	Props.box(root, Vector3(61, 0.8, 16), p + Vector3(0, 18.3, 0), C_STONE)
	Props.box(root, Vector3(16, 0.8, 57), p + Vector3(0, 18.3, 0), C_STONE)
	for d in [Vector3.ZERO, Vector3(22, 0, 0), Vector3(-22, 0, 0), Vector3(0, 0, 20), Vector3(0, 0, -20)]:
		var r := 7.0 if d == Vector3.ZERO else 5.5
		Props.cyl(root, r * 0.9, 4.0, p + d + Vector3(0, 20.5, 0), C_BRICK.lightened(0.15), Vector3.ZERO, 16)
		for k in 8:
			var a := TAU * k / 8.0
			Props.box(root, Vector3(0.9, 2.2, 0.2), p + d + Vector3(cos(a) * r * 0.91, 20.8, sin(a) * r * 0.91), Color("2e2830"), Vector3(0, rad_to_deg(-a) + 90.0, 0))
		Props.ball(root, r, p + d + Vector3(0, 22.5, 0), C_LEAD, Vector3(1, 0.62, 1), 16)
	var rot := p + Vector3(40, 0, 0)
	Props.cyl(root, 9.0, 14.0, rot + Vector3(0, 7, 0), C_BRICK.darkened(0.05), Vector3.ZERO, 16)
	Props.ball(root, 9.2, rot + Vector3(0, 14, 0), C_LEAD, Vector3(1, 0.5, 1), 16)
	_collide(root, _box(Vector3(60, 19, 15)), p + Vector3(0, 9.5, 0))
	_collide(root, _box(Vector3(15, 19, 56)), p + Vector3(0, 9.5, 0))


## Bozdoğan (Valens) Kemeri: iki katlı kemerler, tepede su kanalı; iki tepe arasındaki vadiyi aşar.
static func _aqueduct(root: Node3D) -> void:
	var x0 := -52.0
	var x1 := 34.0
	var stone := Color("b8a078")
	var piers: Array = []
	var x := x0
	while x <= x1:
		var g := hill_h(x, AQUEDUCT_Z)
		piers.append(_tx(Vector3(x, g - 1.0 + (13.0 - g + 1.0) * 0.5, AQUEDUCT_Z), Vector3.ZERO, Vector3(2.4, 13.0 - g + 1.0, 4.2)))
		piers.append(_tx(Vector3(x, 18.5, AQUEDUCT_Z), Vector3.ZERO, Vector3(2.0, 11.0, 3.6)))
		x += 6.5
	Scenery.scatter(root, Scenery._boxm(Vector3.ONE), piers, [], Props.mat(stone))
	# Kemer sıraları: iki kat, pier aralarında kemerli açıklık (yarım silindir alın)
	for yy in [12.2, 23.4]:
		Props.box(root, Vector3(x1 - x0 + 3.0, 1.6, 4.0), Vector3((x0 + x1) * 0.5, yy + 0.8, AQUEDUCT_Z), stone.darkened(0.06))
		var ax := x0 + 3.25
		while ax < x1:
			Props.cyl(root, 2.25, 4.1, Vector3(ax, yy - 0.3, AQUEDUCT_Z), stone.darkened(0.12), Vector3(90, 0, 0), 10)
			ax += 6.5
	Props.box(root, Vector3(x1 - x0 + 3.0, 0.4, 2.0), Vector3((x0 + x1) * 0.5, 25.8, AQUEDUCT_Z), C_WATER.lightened(0.2))
	_collide(root, _box(Vector3(x1 - x0 + 3.0, 1.6, 4.0)), Vector3((x0 + x1) * 0.5, 24.2, AQUEDUCT_Z))


## Blakherna Sarayı (Tekfur cephesi): tuğla-mermer dama desenli üç katlı cephe, kemerli pencereler, kule.
static func _blachernae(root: Node3D, p: Vector3, windows: Array) -> void:
	var body := Props.box(root, Vector3(40, 20, 18), p + Vector3(0, 10, 0), Color.WHITE)
	Props.set_pattern(body, C_BRICK.lightened(0.1), "brick")
	for row in 3:
		for i in 8:
			var wp := p + Vector3(-16.8 + i * 4.8, 4.5 + row * 6.0, 9.05)
			Props.box(root, Vector3(1.8, 3.2, 0.2), wp, Color("2a2228"))
			Props.ball(root, 0.9, wp + Vector3(0, 1.6, 0), Color("2a2228"), Vector3(1, 1, 0.22), 8)
			Props.box(root, Vector3(2.6, 0.4, 0.3), wp + Vector3(0, -2.0, 0.05), Color("e8e0d0"))
			if row > 0 and i % 3 != 1:
				windows.append(wp + Vector3(0, 0, 0.12))
	# Dama desenli bant (mermer-tuğla): Tekfur Sarayı'nın imzası
	for i in 20:
		Props.box(root, Vector3(1.6, 1.6, 0.2), p + Vector3(-19.2 + i * 2.0, 19.0 - (i % 2) * 1.6, 9.1), Color("ece4d2") if i % 2 == 0 else C_BRICK)
	Props.box(root, Vector3(41, 1.0, 19), p + Vector3(0, 20.5, 0), C_STONE)
	for k in 12:
		Props.box(root, Vector3(1.4, 1.2, 1.0), p + Vector3(-19.5 + k * 3.55, 21.6, 9.2), C_STONE)
	Props.set_pattern(Props.box(root, Vector3(9, 30, 9), p + Vector3(24, 15, -2), Color.WHITE), C_STONE.darkened(0.08), "ashlar_far")
	Props.prism(root, Vector3(9.4, 5, 9.4), p + Vector3(24, 32.5, -2), Color("7a4a32"))
	# Sancak: imparatorluk kartalı (sarı zemin)
	Props.cyl(root, 0.15, 8.0, p + Vector3(24, 38.5, -2), Color("4a3a2a"), Vector3.ZERO, 5)
	Props.box(root, Vector3(0.08, 2.4, 3.6), p + Vector3(24, 41.0, -0.2), Color("d9b24a"))
	_collide(root, _box(Vector3(41, 21, 19)), p + Vector3(0, 10.5, 0))


## Başka haritalar için (ByzCity): karşı kıyıda Galata. pos: kıyı çizgisinin ortası, yaw: kasabanın kıyıya
## bakan yüzünün dönüşü (0 = +x'e bakar). Kulenin tepesini (dünya) döndürür.
static func galata_view(parent: Node3D, pos: Vector3, yaw: float) -> Vector3:
	var n := Node3D.new()
	n.name = "GalataView"
	n.rotation.y = yaw
	parent.add_child(n)
	n.position = pos - n.basis * Vector3(-362.0, 0, 385.0)
	var hl: Array = GALATA_HILL
	var b := Props.ball(n, hl[2], Vector3(hl[0], 0, hl[1]), Color("7a7a52"), Vector3(1, hl[3] / hl[2], 1), 28)
	b.material_override = Props.mat(Color("7a7a52"), 0.0, false, "", false)
	_galata(n, [])
	return n.to_global(_on(GALATA_TOWER) + Vector3(0, 40, 0))


## Zincir: a'dan b'ye yüzen kütükler ve aralarında demir halkalar; akıntıyla sag kadar sarkar (yatay).
static func chain(root: Node3D, a: Vector3, b: Vector3, sag := 10.0) -> void:
	var n := 24
	var side := Vector3(-(b - a).z, 0, (b - a).x).normalized()
	var pts: Array = []
	for i in n + 1:
		var t := float(i) / n
		pts.append(a.lerp(b, t) + side * sin(t * PI) * sag)
	for i in n + 1:
		var q: Vector3 = pts[i]
		var d := (b - a).normalized()
		Props.cyl(root, 0.55, 4.6, q + Vector3(0, 0.25, 0), Color("6a4a2a"), Vector3(0, rad_to_deg(atan2(-d.z, d.x)), 90), 8)
		if i < n:
			var nq: Vector3 = pts[i + 1]
			var dir := nq - q
			Props.box(root, Vector3(dir.length(), 0.18, 0.18), (q + nq) * 0.5 + Vector3(0, 0.75, 0), Color("2a2a2e"), Vector3(0, rad_to_deg(atan2(-dir.z, dir.x)), 0))


## Haliç: ağzında yüzen kütüklere bağlı demir zincir, içeride Hristiyan gemileri; kıyıda iskeleler.
static func _horn(root: Node3D) -> void:
	var x0 := HORN_X
	var x1 := -352.0
	chain(root, Vector3(x0, 0.15, CHAIN_Z), Vector3(x1, 0.15, CHAIN_Z), -10.0)
	# Uçlarda zincir kuleleri
	for tx in [x0 - 4.0, x1 + 4.0]:
		Props.set_pattern(Props.box(root, Vector3(8, 16, 8), Vector3(tx, 8, CHAIN_Z), Color.WHITE), C_STONE, "ashlar_far")
	var rng := RandomNumberGenerator.new()
	rng.seed = 29
	for i in 7:
		_ship(root, Vector3(rng.randf_range(x1 + 20.0, x0 - 20.0), 0.15, rng.randf_range(WALL_Z + 90.0, CHAIN_Z - 30.0)), rng.randf() * 0.6 + PI * 0.5, Color("e8e0c8"), Color("7a2a2a"))
	# İskeleler
	for i in 6:
		Props.box(root, Vector3(18, 0.6, 3), Vector3(x0 - 9, 0.6, WALL_Z + 60.0 + i * 55.0), Color("6a4a2a"))


## Kadırga: gövde, kürek sırası, direk ve latin yelken, kıçta bayrak.
static func _ship(root: Node3D, p: Vector3, yaw: float, sail: Color, flag: Color) -> void:
	var n := Node3D.new()
	n.position = p
	n.rotation.y = yaw
	root.add_child(n)
	Props.box(n, Vector3(3.6, 1.6, 22), Vector3(0, 0.6, 0), Color("4a3222"))
	Props.prism(n, Vector3(3.6, 1.6, 4), Vector3(0, 0.6, 12.5), Color("4a3222"), Vector3(90, 0, 0))
	Props.box(n, Vector3(3.2, 0.3, 21), Vector3(0, 1.5, 0), Color("8a6a44"))
	for k in 10:
		for sx in [-1, 1]:
			Props.box(n, Vector3(3.0, 0.12, 0.12), Vector3(sx * 3.2, 0.8, -8.0 + k * 1.8), Color("6a5236"), Vector3(0, 0, sx * -18.0))
	Props.cyl(n, 0.2, 14.0, Vector3(0, 8.5, 2.0), Color("5a4028"), Vector3.ZERO, 6)
	Props.prism(n, Vector3(0.1, 11.0, 9.0), Vector3(0, 9.0, 3.0), sail, Vector3(0, 90, 0))
	Props.box(n, Vector3(0.05, 1.2, 2.0), Vector3(0, 3.4, -10.0), flag)


## Galata: karşı kıyıda tepeye yaslanan Ceneviz kasabası, surları ve Galata (İsa) Kulesi.
static func _galata(root: Node3D, windows: Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1348
	var xf: Array = []
	var cols: Array = []
	for i in 420:
		var x := rng.randf_range(-500.0, -362.0)
		var z := rng.randf_range(WALL_Z + 150.0, TIP_Z + 20.0)
		if Vector2(x - GALATA_TOWER.x, z - GALATA_TOWER.z).length() < 12.0:
			continue
		var y := hill_h(x, z)
		var s := Vector3(rng.randf_range(4.5, 9.0), rng.randf_range(5.0, 11.0), rng.randf_range(4.5, 9.0))
		xf.append(_tx(Vector3(x, y - 0.6, z), Vector3(0, rng.randf() * 0.4, 0), s))
		cols.append([Color("e8d0b0"), Color("d8b894"), Color("c89a78"), Color("e0c8a0")][i % 4])
		if rng.randf() < 0.3:
			windows.append(Vector3(x, y + s.y * 0.55, z + s.z * 0.5 + 0.06))
	Scenery.scatter(root, Scenery.house_mesh(), xf, cols)
	var g := Props.box(root, Vector3(170, 0.3, 240), Vector3(-440, 0.2, WALL_Z + 270.0), Color("7a7a52"))
	g.material_override = Props.mat(Color("7a7a52"), 0.0, false, "", false)
	# Ceneviz surları: tepeden kıyıya iniş
	for seg in [[Vector3(-470, 0, 300), Vector3(-470, 0, 470)], [Vector3(-470, 0, 300), Vector3(-362, 0, 300)]]:
		var a: Vector3 = seg[0]
		var b: Vector3 = seg[1]
		var k := 0.0
		while k < 1.0:
			var q := a.lerp(b, k)
			var y := hill_h(q.x, q.z)
			Props.set_pattern(Props.box(root, Vector3(3.0 if a.x == b.x else 9.0, 8, 9.0 if a.x == b.x else 3.0), Vector3(q.x, y + 3, q.z), Color.WHITE), C_STONE.darkened(0.1), "ashlar_far")
			k += 9.0 / a.distance_to(b)
	var t := _on(GALATA_TOWER)
	Props.set_pattern(Props.cyl(root, 5.4, 34.0, t + Vector3(0, 17, 0), Color.WHITE, Vector3.ZERO, 16), Color("b8a888"), "ashlar")
	Props.cyl(root, 6.2, 1.2, t + Vector3(0, 34.4, 0), C_STONE.darkened(0.1), Vector3.ZERO, 16)
	for k in 12:
		var a := TAU * k / 12.0
		Props.box(root, Vector3(1.0, 2.4, 0.2), t + Vector3(cos(a) * 5.45, 30.0, sin(a) * 5.45), Color("2a2228"), Vector3(0, rad_to_deg(-a) + 90.0, 0))
	Props.cyl(root, 6.0, 12.0, t + Vector3(0, 41.0, 0), C_LEAD.darkened(0.1), Vector3.ZERO, 16, 0.05)
	Props.box(root, Vector3(0.3, 2.2, 0.3), t + Vector3(0, 48.0, 0), Color("d9b24a"))
	Props.box(root, Vector3(1.3, 0.3, 0.3), t + Vector3(0, 48.5, 0), Color("d9b24a"))
	_collide(root, _cylshape(6.2, 35.0), t + Vector3(0, 17.5, 0))


## Boğaz: şehrin burnunun önünde Osmanlı donanması (kırmızı sancaklı kadırgalar), karşıda Asya kıyısı.
static func _bosphorus(root: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1452
	for i in 14:
		_ship(root, Vector3(rng.randf_range(-320.0, 120.0), 0.12, rng.randf_range(TIP_Z + 90.0, TIP_Z + 260.0)), rng.randf() * TAU, Color("f0e8d8"), Color("c8262f"))
	for i in 16:
		var x := -500.0 + i * 80.0 + rng.randf_range(-20.0, 20.0)
		var r := rng.randf_range(80.0, 130.0)
		var col := Color("6a7a4a").darkened(rng.randf() * 0.2)
		var b := Props.ball(root, r, Vector3(x, -r * 0.2, TIP_Z + 560.0 + rng.randf_range(-40.0, 60.0)), col, Vector3(1.4, 0.4, 1.0), 16)
		b.material_override = Props.mat(col, 0.0, false, "", false)
	# Üsküdar: kıyıda seyrek evler
	var xf: Array = []
	for i in 160:
		var p := Vector3(rng.randf_range(-400.0, 500.0), 0, TIP_Z + rng.randf_range(460.0, 500.0))
		xf.append(_tx(p, Vector3(0, rng.randf(), 0), Vector3(rng.randf_range(5, 9), rng.randf_range(5, 9), rng.randf_range(5, 9))))
	Scenery.scatter(root, Scenery.house_mesh(), xf, [])


## Marmara deniz surları: kıyı boyunca alçak sur ve kuleler; burunda sur köşeyi döner.
static func _sea_walls(root: Node3D) -> void:
	var stone := Color("b0a080")
	Props.set_pattern(Props.box(root, Vector3(3.0, 10, TIP_Z - WALL_Z), Vector3(SEA_X - 6.0, 5, (TIP_Z + WALL_Z) * 0.5), Color.WHITE), stone, "ashlar_far")
	Props.set_pattern(Props.box(root, Vector3(SEA_X - HORN_X, 8, 3.0), Vector3((SEA_X + HORN_X) * 0.5, 4, TIP_Z + 2.0), Color.WHITE), stone, "ashlar_far")
	Props.set_pattern(Props.box(root, Vector3(3.0, 8, TIP_Z - WALL_Z - 20.0), Vector3(HORN_X + 4.0, 4, (TIP_Z + WALL_Z + 20.0) * 0.5), Color.WHITE), stone, "ashlar_far")
	var z := WALL_Z + 30.0
	while z < TIP_Z:
		Props.set_pattern(Props.box(root, Vector3(7, 14, 7), Vector3(SEA_X - 6.0, 7, z), Color.WHITE), stone.darkened(0.06), "ashlar_far")
		z += 34.0
	var x := HORN_X + 20.0
	while x < SEA_X:
		Props.set_pattern(Props.box(root, Vector3(7, 12, 7), Vector3(x, 6, TIP_Z + 2.0), Color.WHITE), stone.darkened(0.06), "ashlar_far")
		x += 40.0
	# Büyük Saray: Marmara kıyısında teraslar, revaklar ve kubbeler
	var gp := Vector3(196, 0, 420)
	for k in 3:
		Props.box(root, Vector3(60 - k * 14, 6, 40 - k * 8), gp + Vector3(0, 3 + k * 6, -k * 3), Color("e0d4bc").darkened(k * 0.05))
		for i in 8 - k * 2:
			Props.cyl(root, 0.5, 5.0, gp + Vector3(-26 + k * 7 + i * 7.0, 8.5 + k * 6, 20 - k * 7), Color("f0e8da"), Vector3.ZERO, 8)
	Props.ball(root, 7.0, gp + Vector3(8, 18, -8), C_LEAD, Vector3(1, 0.6, 1), 14)


## Gece: evlerin ve sarayın pencerelerinde kandil ışığı (tek MultiMesh, gölgesiz, ucuz).
static func _window_lights(night: Node3D, windows: Array) -> void:
	var lamp := StandardMaterial3D.new()
	lamp.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lamp.albedo_color = Color("ffc870")
	lamp.emission_enabled = true
	lamp.emission = Color("ffa840")
	lamp.emission_energy_multiplier = 2.5
	var xf: Array = []
	for w in windows:
		xf.append(Transform3D(Basis(), w))
	Scenery.scatter(night, Scenery._boxm(Vector3(0.9, 1.1, 0.9)), xf, [], lamp)
