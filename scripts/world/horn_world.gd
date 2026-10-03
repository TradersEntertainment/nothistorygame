class_name HornWorld
extends Node3D
## Tek haritanın (World1453) kara surları kuşağı dışında kalan her şeyi: SiegeField'in içinde, dünya koordinatında.
##   · Su: Haliç (iç kolu surların dışında +z'ye uzanır), Boğaz (burnun ötesi), Marmara (surların güney ucu ve şehrin
##     güney kıyısı). Su yalnız su olan yerlere döşenir (kara surlarının hendeği kuru kalır).
##   · Şehir kıyı surları: Haliç boyunca (kuleler, Petrion kapısı, ağızda Eugenius kulesi), Marmara boyunca, burunda.
##   · Şehrin doğu yarısı (z −560…−1700): evler, kiliseler, serviler, Ayasofya, Hipodrom ve dikilitaş, Konstantin
##     sütunu, Büyük Saray'ın teraslı kalıntıları. Gece pencereler.
##   · Kuzey kıyı: Galata (GalataView: sur, evler, kule), Kasımpaşa sırtları, Pınarlar Vadisi'nde karaya çekilmiş
##     Osmanlı kadırgaları ve kızak yolu, kıyı boyunca çadırlar ve ateşler.
##   · Zincir (ağızda yüzen kütükler) ve ardında Haliç'teki Hıristiyan gemileri; Boğaz'ın ve Marmara'nın karşı kıyıları.
##   · Blakherna (bölge Blakherna değilse uzak siluet): tek yüksek sur, kuleler, Tekfur Sarayı.
## Uzak görünüm; oynanış alanı değil. Bölgenin keep dikdörtgenlerine bir şey koymaz.

const STONE := Color("cdbd9e")

var region_name := ""
var keep: Array = []
var night := true                  # gündüz bölgelerinde pencereler yanmaz (Galata)
var _night: Array[Node3D] = []
var _day: Array[Node3D] = []
var rng := RandomNumberGenerator.new()
## Uçuş (WorldFlight): Dressing ağıyla kurulan kıyı surlarının kaba kutuları [Transform3D, boyut]
var flight_boxes: Array = []


func build() -> void:
	rng.seed = 145321
	_water()
	_north_shore()
	_city_east()
	_horn_walls()
	_marmara_walls()
	_chain()
	if region_name != "blachernae":
		_blachernae()
	_far_shores()
	_monuments()


func set_mode(mode: String) -> void:
	for n in _night:
		n.visible = mode != "day"
	for n in _day:
		n.visible = mode != "night"


func _free(x: float, z: float, margin := 4.0) -> bool:
	for r in keep:
		if (r as Rect2).grow(margin).has_point(Vector2(x, z)):
			return false
	return true


# ---------------------------------------------------------------- su

func _plane(x0: float, x1: float, z0: float, z1: float, sub := 0) -> void:
	var m := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(x1 - x0, z1 - z0)
	if sub > 0:
		pm.subdivide_width = int((x1 - x0) / sub)
		pm.subdivide_depth = int((z1 - z0) / sub)
	m.mesh = pm
	m.position = Vector3((x0 + x1) * 0.5, -1.6, (z0 + z1) * 0.5)
	if _water_mat == null:
		_water_mat = ShaderMaterial.new()
		_water_mat.shader = load("res://assets/shaders/water.gdshader")
		_water_mat.set_shader_parameter("foam_width", 0.0)
	m.material_override = _water_mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(m)


var _water_mat: ShaderMaterial


func _water() -> void:
	# Haliç (kuzey kıyının toprağı suyun üstüne biner)
	_plane(-1000.0, World1453.HORN_S_X, -1700.0, 560.0, 4)
	# Boğaz ve burnun ötesi
	_plane(-3200.0, 3600.0, -4200.0, -1700.0)
	# Marmara: şehrin güney kıyısı (şehir zemini suyun üstünde) ve surların güney ucunun ötesi
	_plane(-560.0, 3600.0, -1700.0, -12.0)
	_plane(700.0, 3600.0, -12.0, 1600.0)


# ---------------------------------------------------------------- kuzey kıyı

## raw: bölgenin düz alanlarını yok say (bölgenin kendi arazisi kenarında dünyayla buluşsun diye)
static func north_h(x: float, z: float, raw := false) -> float:
	if not raw:
		for r in SiegeField.flat_rects:
			if (r as Rect2).has_point(Vector2(x, z)):
				return SiegeField.flat_y - SiegeField.flat_sink()
	var shore := World1453.horn_n_x(z)
	if z < World1453.TIP.z + 40.0:
		shore = minf(shore, World1453.HORN_N_X - (World1453.TIP.z + 40.0 - z) * 0.8)
	var d := shore - x                          # kıyıdan içeri (+)
	var h := 2.0 + 42.0 * smoothstep(10.0, 520.0, d) * (0.65 + 0.35 * sin(z * 0.0042 + 0.7))
	# Pınarlar Vadisi: sırtlar arasında çukur
	h *= 1.0 - 0.65 * exp(-pow((z + 900.0) / 130.0, 2.0))
	# Galata tepesi
	var g: Vector3 = World1453.LANDMARKS["galata_center"]
	h += 26.0 * exp(-(pow((x - g.x) / 170.0, 2.0) + pow((z - g.z) / 150.0, 2.0)))
	# Kıyı: suya iner
	var y := lerpf(-4.0, h, smoothstep(-6.0, 14.0, d))
	return y if raw else SiegeField.flat_mix(y, x, z, SiegeField.flat_y)


func _north_shore() -> void:
	var hf := func(x: float, z: float) -> float: return north_h(x, z)
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		var c := Color("5e6a3e").lerp(Color("7a7048"), clampf(0.5 + 0.5 * sin(x * 0.011 + z * 0.007), 0.0, 1.0) * 0.5)
		if y < 0.4:
			c = Color("8a7a58")
		return c.darkened(clampf(steep * 0.5, 0.0, 0.25))
	add_child(LowPoly.terrain(-2600.0, -760.0, -2100.0, 900.0, 46, 75, hf, cf))
	# Galata (Ceneviz kasabası): sur, evler, kule
	var tw: Vector3 = World1453.LANDMARKS["galata_tower"]
	var gc: Vector3 = World1453.LANDMARKS["galata_center"]
	var top := World1453.galata_top(tw)
	GalataView.build(self, hf, Vector2(tw.x, tw.z), top, Vector2(gc.x, gc.z), 150.0, -1.6, 1453, night, keep)
	# Osmanlı yakası: çadırlar, ateşler (Galata'nın çevresi boş)
	var d := Dressing.new(331)
	d.chunk = 240.0
	var nd := Dressing.new(332)
	nd.chunk = 240.0
	for i in 420:
		var z := rng.randf_range(-1250.0, 760.0)
		var shore := World1453.horn_n_x(z)
		var x := shore - rng.randf_range(40.0, 900.0)
		if Vector2(x - gc.x, z - gc.z).length() < 230.0 or not _free(x, z):
			continue
		var y := north_h(x, z)
		var c: Color = [Color("e8dcc0"), Color("d8c8a0"), Color("c8262f"), Color("e0d4b8")][i % 4]
		d.prism(Vector3(5.0, 3.6, 5.0), Vector3(x, y + 1.8, z), c)
		if i % 3 == 0:
			nd.glow(Vector3(1.0, 1.2, 1.0), Vector3(x + 4.0, y + 0.8, z), Color("ffa040"))
	# Pınarlar Vadisi: kıyıya çekilmiş kadırgalar (kızak yolundan gelenler) ve kızak yolu
	var sp: Vector3 = World1453.LANDMARKS["springs"]
	for i in 34:
		var z := sp.z - 170.0 + i * 10.0
		var x := World1453.HORN_N_X + rng.randf_range(-6.0, 18.0)
		var y := -1.2 if x > World1453.HORN_N_X else north_h(x, z) - 0.2
		var yaw := deg_to_rad(rng.randf_range(-8.0, 8.0))
		d.box(Vector3(22.0, 1.6, 3.6), Vector3(x - 8.0, y + 0.6, z), Color("4a3220"), Vector3(0, 90.0 + rad_to_deg(yaw), 0))
		d.box(Vector3(18.0, 0.3, 3.0), Vector3(x - 8.0, y + 1.5, z), Color("8a6a40"), Vector3(0, 90.0 + rad_to_deg(yaw), 0))
		d.cyl(0.18, 11.0, Vector3(x - 8.0, y + 6.5, z), Color("5a3e26"), Vector3.ZERO, 5)
		d.box(Vector3(0.1, 0.1, 9.0), Vector3(x - 8.0, y + 11.0, z), Color("5a3e26"), Vector3(30, 0, 0))
	# Kızak yolu: Boğaz yakasından sırtı aşan, yağlanmış kütükler
	var a := Vector3(-1500.0, 0, -1720.0)
	var b := Vector3(sp.x - 40.0, 0, sp.z - 60.0)
	for k in 70:
		var p := a.lerp(b, k / 69.0)
		p.y = north_h(p.x, p.z) + 0.15
		d.box(Vector3(5.0, 0.3, 0.4), p, Color("6a4a2c"), Vector3(0, rad_to_deg(atan2(b.x - a.x, b.z - a.z)) + 90.0, 0))
	d.build(self)
	_night.append(nd.build(self))
	# Kuzey kıyıda ağaçlar ve serviler
	Scenery.trees(self, Vector3(-1500.0, 0, -300.0), 120.0, 900.0, 160, [Rect2(gc.x - 220.0, gc.z - 220.0, 440.0, 440.0)], hf, 3321)


# ---------------------------------------------------------------- şehrin doğu yarısı

func _city_east() -> void:
	var hf := func(x: float, z: float) -> float: return SiegeField.city_ground(x, z)
	var ccf := func(x: float, z: float, y: float, steep: float) -> Color:
		var c := Color("7a7050").lerp(Color("5a6a40"), clampf(0.5 + 0.5 * sin(x * 0.05 - z * 0.04), 0.0, 1.0) * 0.6)
		if y < -0.6:
			c = Color("8a7a58")
		return c.darkened(clampf(steep * 0.5, 0.0, 0.25))
	add_child(LowPoly.terrain(-760.0, 760.0, -1780.0, -700.0, 52, 36, hf, ccf))
	var houses: Array = []
	var hcols: Array = []
	var nd := Dressing.new(341)
	nd.chunk = 240.0
	for i in 1500:
		var x := rng.randf_range(-700.0, 700.0)
		var z := rng.randf_range(-1700.0, -560.0)
		if not World1453.in_city(x, z, 14.0) or not _free(x, z):
			continue
		var ay: Vector3 = World1453.LANDMARKS["ayasofya"]
		var hp: Vector3 = World1453.LANDMARKS["hippodrome"]
		if Vector2(x - ay.x, z - ay.z).length() < 70.0 or (absf(x - hp.x) < 50.0 and absf(z - hp.z) < 120.0):
			continue
		if _near_monument(x, z):
			continue
		var y := SiegeField.city_ground(x, z)
		var s := Vector3(rng.randf_range(5.0, 11.0), rng.randf_range(4.5, 11.0), rng.randf_range(5.0, 10.0))
		houses.append(Scenery._t(Vector3(x, y - 0.4, z), Vector3(0, rng.randf_range(-0.3, 0.3), 0), s))
		hcols.append([Color("e8d8c0"), Color("d8c0a0"), Color("c8a888"), Color("e0ccb0"), Color("b89a80")][i % 5])
		if i % 4 == 0:
			nd.glow(Vector3(0.6, 0.8, 0.1), Vector3(x, y + s.y * 0.5, z + s.z * 0.5 + 0.05), Color("ffc870"))
	Scenery.scatter(self, Scenery.house_mesh(), houses, hcols)
	_night.append(nd.build(self))
	# Kiliseler
	for i in 22:
		var x := rng.randf_range(-650.0, 600.0)
		var z := rng.randf_range(-1650.0, -600.0)
		if not World1453.in_city(x, z, 30.0) or not _free(x, z, 12.0):
			continue
		var p := Vector3(x, SiegeField.city_ground(x, z) - 0.3, z)
		var r := rng.randf_range(5.0, 8.5)
		Props.box(self, Vector3(r * 2.4, r * 1.3, r * 2.0), p + Vector3(0, r * 0.65, 0), Color("b87060"))
		Props.cyl(self, r * 0.62, r * 0.55, p + Vector3(0, r * 1.55, 0), Color("c8a890"), Vector3.ZERO, 12)
		Props.ball(self, r * 0.64, p + Vector3(0, r * 1.82, 0), Color("8a98a8"), Vector3(1, 0.7, 1), 14)
	# Ayasofya, Hipodrom ve dikilitaş, Konstantin sütunu, Büyük Saray terasları
	var ay2: Vector3 = World1453.LANDMARKS["ayasofya"]
	if _free(ay2.x, ay2.z, 60.0):
		Scenery.hagia_sophia(self, Vector3(ay2.x, SiegeField.city_ground(ay2.x, ay2.z) - 1.0, ay2.z), 1.0)
	var hp2: Vector3 = World1453.LANDMARKS["hippodrome"]
	var hy := SiegeField.city_ground(hp2.x, hp2.z)
	var d := Dressing.new(342)
	d.chunk = 240.0
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(8.0, 9.0, 220.0), Vector3(hp2.x + sx * 40.0, hy + 4.5, hp2.z), STONE.darkened(0.15))
	d.box(Vector3(88.0, 9.0, 10.0), Vector3(hp2.x, hy + 4.5, hp2.z + 110.0), STONE.darkened(0.2))
	d.box(Vector3(70.0, 0.2, 210.0), Vector3(hp2.x, hy + 0.1, hp2.z), Color("a89878"))
	d.box(Vector3(2.0, 1.2, 160.0), Vector3(hp2.x, hy + 0.6, hp2.z), STONE)
	d.cyl(1.4, 20.0, Vector3(hp2.x, hy + 10.0, hp2.z - 30.0), Color("c8a888"), Vector3.ZERO, 4, 0.3)
	d.cyl(1.0, 18.0, Vector3(hp2.x, hy + 9.0, hp2.z + 20.0), Color("8a6a50"), Vector3.ZERO, 8)
	var col: Vector3 = World1453.LANDMARKS["column"]
	if region_name != "byz_aya":            # Ayasofya parçası kendi sütununu kurar (ev:column)
		d.cyl(3.0, 34.0, Vector3(col.x, SiegeField.city_ground(col.x, col.z) + 17.0, col.z), Color("b06a50"), Vector3.ZERO, 12)
	var gp: Vector3 = World1453.LANDMARKS["great_palace"]
	for k in 4:
		var p := gp + Vector3(k * 8.0, 0, -k * 14.0)
		if not _free(p.x, p.z, 20.0):
			continue
		d.box(Vector3(30.0, 8.0 + k * 2.0, 40.0), Vector3(p.x, SiegeField.city_ground(p.x, p.z) + 4.0, p.z), Color("b8a888").darkened(0.05 * k))
	d.build(self)
	# Serviler
	var cyp: Array = []
	for i in 500:
		var x := rng.randf_range(-700.0, 700.0)
		var z := rng.randf_range(-1700.0, -560.0)
		if not World1453.in_city(x, z, 16.0) or not _free(x, z):
			continue
		cyp.append(Scenery._t(Vector3(x, SiegeField.city_ground(x, z) - 0.2, z), Vector3.ZERO, Vector3.ONE * rng.randf_range(0.9, 1.5)))
	Scenery.scatter(self, Scenery.cypress_mesh(), cyp)


# ---------------------------------------------------------------- kıyı surları

func _wall_run(a: Vector3, b: Vector3, h: float, tower_step: float, d: Dressing, merl: Array, nd: Dressing, gates: Array = []) -> void:
	var dir := (b - a)
	var len := dir.length()
	dir /= len
	var yaw := rad_to_deg(atan2(dir.x, dir.z))
	var side := Vector3(dir.z, 0, -dir.x)
	var n := int(ceil(len / 40.0))
	for k in n:
		var p0 := a.lerp(b, float(k) / n)
		var p1 := a.lerp(b, float(k + 1) / n)
		var mid := (p0 + p1) * 0.5
		if not _free(mid.x, mid.z, 6.0):
			continue
		var skip := false
		for g: Vector3 in gates:
			if mid.distance_to(g) < 22.0:
				skip = true
		var seg := p0.distance_to(p1) + 0.4
		if skip:
			# Kapı: iki ayak ve kemer
			d.box(Vector3(3.2, h, seg * 0.35), mid - dir * seg * 0.33 + Vector3(0, h * 0.5 - 1.0, 0), STONE.darkened(0.12), Vector3(0, yaw, 0))
			d.box(Vector3(3.2, h, seg * 0.35), mid + dir * seg * 0.33 + Vector3(0, h * 0.5 - 1.0, 0), STONE.darkened(0.12), Vector3(0, yaw, 0))
			d.box(Vector3(3.2, h * 0.35, seg * 0.4), mid + Vector3(0, h * 0.82 - 1.0, 0), STONE.darkened(0.18), Vector3(0, yaw, 0))
			continue
		d.box(Vector3(3.0, h + 2.0, seg), mid + Vector3(0, h * 0.5 - 1.0, 0), STONE.darkened(0.1 + 0.04 * (k % 3)), Vector3(0, yaw, 0))
		flight_boxes.append([Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)), mid + Vector3(0, h * 0.5 - 1.0, 0)), Vector3(3.0, h + 2.0, seg)])
		for m in int(seg / 3.5):
			merl.append(Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)).scaled(Vector3(1.2, 1.0, 1.0)), p0.lerp(p1, (m + 0.5) / int(seg / 3.5)) + Vector3(0, h + 1.5, 0) + side * 1.2))
	var t := tower_step * 0.5
	while t < len:
		var p := a + dir * t
		var th := h + rng.randf_range(3.0, 6.0)
		if not _free(p.x, p.z, 6.0):
			t += tower_step
			continue
		d.box(Vector3(8.0, th + 2.0, 8.0), p + Vector3(0, th * 0.5 - 1.0, 0) + side * 1.0, STONE.darkened(0.18), Vector3(0, yaw, 0))
		d.box(Vector3(8.4, 0.5, 8.4), p + Vector3(0, th + 0.2, 0) + side * 1.0, Color("9a5040"), Vector3(0, yaw, 0))
		if rng.randf() < 0.5:
			nd.glow(Vector3(0.4, 0.6, 0.4), p + Vector3(0, th + 1.0, 0), Color("ffb040"))
		t += tower_step


func _horn_walls() -> void:
	var d := Dressing.new(351)
	d.chunk = 240.0
	var nd := Dressing.new(352)
	nd.chunk = 240.0
	var merl: Array = []
	var a := Vector3(World1453.HORN_S_X, 0.0, World1453.HORN_IN_Z)
	var e: Vector3 = World1453.LANDMARKS["eugenius"]
	var b := Vector3(World1453.HORN_S_X, 0.0, World1453.SHORE_END_Z)
	_wall_run(a, b, 10.0, 44.0, d, merl, nd, [World1453.LANDMARKS["petrion_gate"]])
	# Eugenius kulesi (zincirin şehir ucu) ve burna dönen sur
	if _free(e.x, e.z, 8.0):
		d.cyl(7.0, 22.0, Vector3(e.x, 10.0, e.z), STONE.darkened(0.2), Vector3.ZERO, 14)
		d.cyl(7.4, 0.6, Vector3(e.x, 21.3, e.z), Color("9a5040"), Vector3.ZERO, 14)
	_wall_run(b, World1453.TIP, 9.0, 60.0, d, merl, nd)
	d.build(self)
	_night.append(nd.build(self))
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(STONE.darkened(0.2), 0.0, false, "ashlar"))


func _marmara_walls() -> void:
	var d := Dressing.new(361)
	d.chunk = 240.0
	var nd := Dressing.new(362)
	nd.chunk = 240.0
	var merl: Array = []
	_wall_run(Vector3(700.0, 0.0, -14.0), World1453.TIP + Vector3(0, 0, 4.0), 9.0, 58.0, d, merl, nd)
	# Kıyı kayalıkları
	for i in 60:
		var t := rng.randf()
		var p := Vector3(700.0, 0, -14.0).lerp(World1453.TIP, t)
		var side := Vector3(0.8, 0, 0.6).normalized()
		d.ball(rng.randf_range(1.5, 3.5), p + side * rng.randf_range(4.0, 12.0) + Vector3(0, -1.4, 0), Color("6a6458"), Vector3(1.4, 0.6, 1.0), 6)
	d.build(self)
	_night.append(nd.build(self))
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(STONE.darkened(0.15), 0.0, false, "ashlar"))


# ---------------------------------------------------------------- zincir ve gemiler

func _chain() -> void:
	var d := Dressing.new(371)
	d.chunk = 240.0
	var a: Vector3 = World1453.LANDMARKS["chain_s"]
	var b: Vector3 = World1453.LANDMARKS["chain_n"]
	var yaw := rad_to_deg(atan2(b.x - a.x, b.z - a.z))
	var n := int(a.distance_to(b) / 6.0)
	for k in n:
		var p := a.lerp(b, (k + 0.5) / n)
		d.cyl(0.45, 5.2, Vector3(p.x, -1.35, p.z), Color("5a4030"), Vector3(90, yaw, 0), 8)
	# Zincirin ardında (Haliç'in içinde) Venedik ve Ceneviz gemileri
	for i in 9:
		var p := Vector3(rng.randf_range(-890.0, -730.0), -1.6, a.z + 40.0 + i * 18.0)
		d.box(Vector3(6.0, 3.0, 24.0), p + Vector3(0, 1.4, 0), Color("4a3222"))
		d.box(Vector3(5.0, 2.2, 5.0), p + Vector3(0, 4.0, -9.0), Color("5a3a26"))
		d.cyl(0.25, 20.0, p + Vector3(0, 12.0, 0), Color("5a3e26"), Vector3.ZERO, 5)
		d.box(Vector3(0.1, 7.0, 9.0), p + Vector3(0, 13.0, 1.0), Color("e8e0d0"))
	d.build(self)


# ---------------------------------------------------------------- Blakherna (uzak siluet)

func _blachernae() -> void:
	var bp: Vector3 = World1453.LANDMARKS["blachernae"]
	# Zemin: Theodosius surlarının bittiği yerden Haliç'e (ova ile şehir arasındaki boşluk kalmasın)
	Props.box(self, Vector3(124.0, 0.6, 46.0), Vector3(-640.0, -0.3, 14.0), Color("6e6452"))
	var wall := Props.box(self, Vector3(124.0, 16.0, 4.0), Vector3(-640.0, 7.0, 0.0), Color.WHITE)
	Props.set_pattern(wall, STONE.darkened(0.08), "ashlar")
	for k in 6:
		var t := Props.box(self, Vector3(10.0, 22.0, 10.0), Vector3(-695.0 + k * 22.0, 10.0, 1.0), Color.WHITE)
		Props.set_pattern(t, STONE.darkened(0.14), "ashlar")
	# Blakherna surunun Haliç'e inen kısmı (köşeden kıyı suruna)
	var w2 := Props.box(self, Vector3(4.0, 14.0, World1453.HORN_IN_Z + 2.0), Vector3(World1453.HORN_S_X + 2.0, 6.0, World1453.HORN_IN_Z * 0.5), Color.WHITE)
	Props.set_pattern(w2, STONE.darkened(0.1), "ashlar")
	# Tekfur Sarayı: tuğla-taş bantlı üç katlı cephe
	var pal := Props.box(self, Vector3(30.0, 22.0, 14.0), bp + Vector3(0, 11.0, 0), Color.WHITE)
	Props.set_pattern(pal, Color("b07050"), "tekfur")


# ---------------------------------------------------------------- karşı kıyılar

func _far_shores() -> void:
	var d := Dressing.new(391)
	d.chunk = 400.0
	# Boğaz'ın Asya yakası (Khrysopolis/Üsküdar, Khalkedon): kıyı burnun ~400 m karşısında; Marmara'nın güney kıyısı, Adalar
	var af := func(x: float, z: float) -> float: return asia_h(x, z)
	var acf := func(x: float, z: float, y: float, steep: float) -> Color:
		var c := Color("6a7a4a").lerp(Color("7e7a52"), clampf(0.5 + 0.5 * sin(x * 0.007 + z * 0.005), 0.0, 1.0) * 0.5)
		if y < 0.6:
			c = Color("8a7a58")
		return c.darkened(clampf(steep * 0.5, 0.0, 0.25))
	add_child(LowPoly.terrain(-3000.0, 1800.0, -3700.0, -2050.0, 60, 40, af, acf))
	for p: Vector3 in [Vector3(2600.0, 0, -1300.0), Vector3(3100.0, 0, -500.0), Vector3(2900.0, 0, -2100.0)]:
		d.ball(160.0, p + Vector3(0, -120.0, 0), Color("6a7a5a").lerp(Color("8a9aa0"), 0.45), Vector3(1.3, 0.8, 1.0), 10)
	d.build(self)


## Asya yakası: kıyıdan içeri yükselen tepeler, Üsküdar sırtı
static func asia_h(x: float, z: float) -> float:
	var d := World1453.asia_z(x) - z                 # kıyıdan içeri (+)
	var h := 3.0 + 48.0 * smoothstep(20.0, 700.0, d) * (0.7 + 0.3 * sin(x * 0.005 + 1.1))
	var u: Vector3 = World1453.LANDMARKS["uskudar"]
	h += 10.0 * exp(-(pow((x - u.x) / 160.0, 2.0) + pow((z - u.z) / 120.0, 2.0)))
	return lerpf(-4.0, h, smoothstep(-6.0, 14.0, d))


func _near_monument(x: float, z: float) -> bool:
	var ap: Vector3 = World1453.LANDMARKS["apostles"]
	if Vector2(x - ap.x, z - ap.z).length() < 32.0:
		return true
	var a: Vector3 = World1453.LANDMARKS["aqueduct_a"]
	var b: Vector3 = World1453.LANDMARKS["aqueduct_b"]
	var ab := Vector2(b.x - a.x, b.z - a.z)
	var t := clampf(Vector2(x - a.x, z - a.z).dot(ab) / ab.length_squared(), 0.0, 1.0)
	return Vector2(x, z).distance_to(Vector2(a.x, a.z) + ab * t) < 10.0


## Uçarak varılan anıtlar (Props ilkelleri: uçuşta katı olur): Havariyun Kilisesi, Bozdoğan Kemeri, Kız Kulesi, Üsküdar
func _monuments() -> void:
	var wall := Color("c89478")
	var lead := Color("7a8594")
	# Havariyun: haç planlı, beş kubbeli
	var ap: Vector3 = World1453.LANDMARKS["apostles"]
	if _free(ap.x, ap.z, 30.0):
		var g := SiegeField.city_ground(ap.x, ap.z) - 0.5
		var c := Vector3(ap.x, g, ap.z)
		Props.box(self, Vector3(46, 14, 14), c + Vector3(0, 7, 0), wall)
		Props.box(self, Vector3(14, 14, 46), c + Vector3(0, 7, 0), wall)
		for o: Vector3 in [Vector3.ZERO, Vector3(16, 0, 0), Vector3(-16, 0, 0), Vector3(0, 0, 16), Vector3(0, 0, -16)]:
			var r := 6.0 if o == Vector3.ZERO else 4.8
			Props.cyl(self, r, 4.0, c + o + Vector3(0, 16, 0), wall.lightened(0.05), Vector3.ZERO, 14)
			Props.ball(self, r + 0.3, c + o + Vector3(0, 18.0, 0), lead, Vector3(1, 0.62, 1), 14)
		Props.box(self, Vector3(0.5, 3.0, 0.5), c + Vector3(0, 23.5, 0), Color("d8b040"))
	# Bozdoğan Kemeri: iki katlı kemer sırası (ayaklar ve kuşaklar)
	var a: Vector3 = World1453.LANDMARKS["aqueduct_a"]
	var b: Vector3 = World1453.LANDMARKS["aqueduct_b"]
	var n := int(a.distance_to(b) / 9.0)
	var yaw := rad_to_deg(atan2(b.x - a.x, b.z - a.z))
	for k in n + 1:
		var p := a.lerp(b, float(k) / n)
		if not _free(p.x, p.z, 6.0):
			continue
		var g := SiegeField.city_ground(p.x, p.z)
		var top := 20.0
		Props.box(self, Vector3(3.2, top - g + 2.0, 3.0), Vector3(p.x, (top + g) * 0.5 - 1.0, p.z), Color("b89a78"), Vector3(0, yaw, 0))
	var mid := (a + b) * 0.5
	for lvl: float in [11.0, 19.5]:
		Props.box(self, Vector3(3.4, 1.6, a.distance_to(b) + 3.0), Vector3(mid.x, lvl, mid.z), Color("a88a68"), Vector3(0, yaw, 0))
	# Kız Kulesi (Damalis): adacık, kule, kubbe
	var dm: Vector3 = World1453.LANDMARKS["damalis"]
	Props.ball(self, 9.0, dm + Vector3(0, -3.0, 0), Color("8a8270"), Vector3(1.3, 0.6, 1.0), 10)
	Props.box(self, Vector3(12, 3, 9), dm + Vector3(0, 0.5, 0), STONE.darkened(0.1))
	Props.box(self, Vector3(5, 16, 5), dm + Vector3(0, 9.0, 0), STONE)
	Props.ball(self, 2.8, dm + Vector3(0, 17.0, 0), lead, Vector3(1, 0.8, 1), 10)
	# Üsküdar: sırtta evler ve kubbeli kilise
	var u: Vector3 = World1453.LANDMARKS["uskudar"]
	var houses: Array = []
	var hcols: Array = []
	for i in 160:
		var x := u.x + rng.randf_range(-170.0, 170.0)
		var z := u.z + rng.randf_range(-120.0, 110.0)
		if z > World1453.asia_z(x) - 10.0 or Vector2(x - u.x, z - u.z).length() < 16.0:
			continue
		var s := Vector3(rng.randf_range(5.0, 9.0), rng.randf_range(4.5, 8.0), rng.randf_range(5.0, 8.0))
		houses.append(Scenery._t(Vector3(x, asia_h(x, z) - 0.4, z), Vector3(0, rng.randf_range(-0.3, 0.3), 0), s))
		hcols.append([Color("e8d8c0"), Color("d8c0a0"), Color("c8a888"), Color("e0ccb0")][i % 4])
	Scenery.scatter(self, Scenery.house_mesh(), houses, hcols)
	var ug := asia_h(u.x, u.z)
	Props.box(self, Vector3(16, 10, 20), Vector3(u.x, ug + 5.0, u.z), wall)
	Props.cyl(self, 4.6, 3.0, Vector3(u.x, ug + 11.5, u.z), wall.lightened(0.05), Vector3.ZERO, 12)
	Props.ball(self, 4.9, Vector3(u.x, ug + 13.0, u.z), lead, Vector3(1, 0.62, 1), 12)
