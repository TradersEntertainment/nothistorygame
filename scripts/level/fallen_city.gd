class_name FallenCity
extends Node3D
## 29 Mayıs 1453, öğleden sonra: kara surlarının iç kapısından (Aziz Romanos) Mese'ye uzanan cadde. Bölüm 26'da
## Sultan'ın alayı buradan geçer, oyuncu alayın yanında serbestçe dolaşır. LandWalls koordinatları: x sur boyunca,
## -z şehrin içine doğru.
##   · Caddenin iki yanında iki katlı evler: kurum lekeli, yanmış (çatısız, kömürleşmiş kirişler, içi köz),
##     çökmüş (duvar dişleri, sokağa taşan moloz). Kapıları kırık; bazı pencerelerde askerlerin diktiği sancaklar
##     (kaynaklar: yağmacılar girdikleri evi bayrakla işaretlerdi).
##   · Sol yanda kapısı açık bir kilise (önünde yaşlı bir papaz, içeriden sandık taşıyan askerler), sağda damı yanmış,
##     kemerli bir saray cephesi ve devrik sütunlu revak: Sultan burada durur.
##   · Sokakta devrik araba, kırık küpler, düşmüş kirişler; molozların üstünde tüten ateşler; ufukta duman sütunları ve
##     Ayasofya'nın kubbesi.
##   · Yan sokaklar molozla kapalı (görünmez sınır); caddenin sonunda yeniçeri sırası.

const STREET := 4.5            # caddenin yarı genişliği (evlerin cephesi x ±4.5)
const Z0 := -4.4
const Z1 := -86.0
const PALACE := Vector3(4.5, 0.0, -64.0)     # saray cephesinin ortası (sağ)
const CHURCH := Vector3(-4.5, 0.0, -40.0)    # kilisenin cephesinin ortası (sol)
const STOP := Vector3(1.2, 0.0, -63.0)       # Sultan'ın durduğu yer (sarayın önü)

var rng := RandomNumberGenerator.new()
var looters: Array[Person] = []
var fires: Array[Node3D] = []
var _d: Dressing
var _houses := 0


## Surların ovası/şehir silueti (SiegeField): caddenin üstüne düşen uzak evler, serviler, kiliseler gizlenir.
var field: Node3D

func _ready() -> void:
	rng.seed = 1453529
	_clear_field()
	_d = Dressing.new(529)
	_ground()
	for side: float in [-1.0, 1.0]:
		_row(side)
	_church()
	_palace()
	_street_clutter()
	_end_line()
	_d.build(self)
	_skyline()
	_people()


## Fetih günü havası: dumanlı pus, turuncuya çalan güneş, koyu ufuk.
static func mood(env: Environment, sun: DirectionalLight3D) -> void:
	if env == null:
		return
	var sm := env.sky.sky_material as ProceduralSkyMaterial
	if sm:
		sm.sky_top_color = Color("6a7a8c")
		sm.sky_horizon_color = Color("b8a088")
		sm.ground_horizon_color = Color("8a7462")
	env.fog_enabled = true
	env.fog_light_color = Color("8a7a6a")
	env.fog_density = 0.011
	env.ambient_light_color = Color("b8aca0")
	env.ambient_light_energy = 0.7
	if sun:
		sun.light_color = Color("ffd8a8")
		sun.light_energy = 1.0


func _clear_field() -> void:
	if field == null:
		return
	var area := Rect2(-40.0, -104.0, 80.0, 64.0)
	for n in field.find_children("*", "", true, false):
		if n is MultiMeshInstance3D:
			var mmi := n as MultiMeshInstance3D
			var mm := mmi.multimesh
			if mm == null:
				continue
			for i in mm.instance_count:
				var g := mmi.global_transform * mm.get_instance_transform(i).origin
				if area.has_point(Vector2(g.x, g.z)):
					mm.set_instance_transform(i, Transform3D(Basis().scaled(Vector3.ONE * 0.0001), mm.get_instance_transform(i).origin))
		elif n is MeshInstance3D:
			var gp := (n as MeshInstance3D).global_position
			if area.has_point(Vector2(gp.x, gp.z)) and gp.y > 0.5:
				(n as MeshInstance3D).visible = false


func _ground() -> void:
	# Surun iç yüzünden caddenin sonuna (LandWalls'ın şehir zemini z -44'e kadar)
	# Üst yüzü ovanın zemininden 1 cm yukarıda (aynı düzlemde çimenle çakışmasın)
	Props.set_pattern(Props.solid(self, Vector3(70, 0.4, 52), Vector3(0, -0.19, -68.0), Color.WHITE), Color("7a6a54"), "cobble")
	# Cadde taşları: ortada daha açık, iki yanda oluk
	Props.set_pattern(Props.box(self, Vector3(STREET * 2.0 - 1.0, 0.02, absf(Z1 - Z0)), Vector3(0, 0.01, (Z0 + Z1) * 0.5), Color.WHITE), Color("b0a080"), "cobble")
	for sx: float in [-1.0, 1.0]:
		Props.box(self, Vector3(0.25, 0.03, absf(Z1 - Z0)), Vector3(sx * (STREET - 0.6), 0.015, (Z0 + Z1) * 0.5), Color("4a4236"))


## Bir yanın evleri: sur dibinden caddenin sonuna, aralarda (molozla kapalı) dar sokaklar.
func _row(side: float) -> void:
	var z := Z0 - 1.0
	while z > Z1 + 3.0:
		var length := rng.randf_range(5.0, 7.5)
		var zc := z - length * 0.5
		# Kilise (sol) ve saray (sağ) kendi yerlerinde
		var feat: Vector3 = CHURCH if side < 0.0 else PALACE
		var feat_half := 6.5 if side < 0.0 else 8.0
		if absf(zc - feat.z) < feat_half + length * 0.5:
			z = feat.z - feat_half - 1.2
			continue
		var r := rng.randf()
		var state := "burnt" if r < 0.45 else ("collapsed" if r < 0.66 else "sooted")
		_house(Vector3(side * (STREET + 3.0), 0, zc), side, length, rng.randf_range(6.0, 7.6), state)
		z -= length
		# Dar sokak: moloz yığını, üstünde kırık kiriş; arkası görünmez sınır
		var gap := rng.randf_range(1.2, 1.8)
		var az := z - gap * 0.5
		if z - gap > Z1 + 3.0:
			_d.at(Vector3(side * (STREET + 1.2), 0, az), 0.0)
			for k in 4:
				_d.box(Vector3(rng.randf_range(0.5, 0.9), rng.randf_range(0.3, 0.6), rng.randf_range(0.5, 0.9)),
					Vector3(side * rng.randf_range(0.2, 1.2), 0.2 + k * 0.15, rng.randf_range(-gap * 0.3, gap * 0.3)), Color("8a7a60").darkened(rng.randf_range(0.0, 0.3)),
					Vector3(rng.randf_range(-20, 20), rng.randf_range(0, 90), rng.randf_range(-20, 20)))
			_d.box(Vector3(0.18, 0.18, gap + 0.8), Vector3(side * 0.9, 0.9, 0), Color("2a2220"), Vector3(0, 0, side * 25))
			var blk := Props.solid(self, Vector3(1.2, 4.0, gap + 0.4), Vector3(side * (STREET + 1.6), 2.0, az), Color.WHITE)
			blk.get_child(0).visible = false
			blk.set_meta("no_climb", true)
		z -= gap


## İki katlı ev: taban kesme taş, üstü sıvalı. state: "sooted" (çatılı, pencere üstleri kurumlu), "burnt" (çatısız,
## üst kenarı kömür, içi köz, kirişler), "collapsed" (yarı yıkık, sokağa taşan moloz).
func _house(center: Vector3, side: float, length: float, h: float, state: String) -> void:
	_houses += 1
	var depth := 6.0
	var plasters := [Color("e8c890"), Color("d89a78"), Color("efe0c4"), Color("c8a0a0"), Color("b8c4c0"), Color("e0b070")]
	var plaster: Color = (plasters[_houses % plasters.size()] as Color).darkened(0.38)
	var shutter: Color = [Color("3a6a5a"), Color("3a5a8a"), Color("6a3a2a"), Color("5a6a3a")][_houses % 4]
	var soot := Color("1e1a18")
	# Cephe caddeye bakar: yerel +z = -side yönü, yerel x cadde boyunca
	var face := center + Vector3(-side * depth * 0.5, 0, 0)
	_d.at(face, -side * PI * 0.5)
	var hh := h if state != "collapsed" else rng.randf_range(2.6, 3.4)
	_d.box(Vector3(length, hh, depth), Vector3(0, hh * 0.5, -depth * 0.5), plaster)
	_d.solid(Vector3(length, hh, depth), Vector3(0, hh * 0.5, -depth * 0.5))
	_d.box(Vector3(length + 0.02, minf(3.0, hh), 0.06), Vector3(0, minf(3.0, hh) * 0.5, 0.02), Color("cdbd9e").darkened(0.08))
	match state:
		"sooted":
			_d.house_face(length, h, true, shutter)
			_d.prism(Vector3(depth + 0.8, 1.5, length + 0.6), Vector3(0, h + 0.75, -depth * 0.5), Color("b8603a"), Vector3(0, 90, 0))
			# Pencere üstlerinde kurum dilleri
			for k in 3:
				var x := -length * 0.5 + (k + 0.5) * length / 3.0
				if rng.randf() < 0.6:
					_d.box(Vector3(0.7, 1.4, 0.03), Vector3(x, 5.2, 0.05), soot, Vector3(0, 0, rng.randf_range(-6, 6)))
		"burnt":
			_d.house_face(length, h, true, soot.lightened(0.1))
			# Üst kenar kömürleşmiş, dam yok: duvar dişleri ve içeride köz
			_d.box(Vector3(length + 0.04, 1.6, 0.08), Vector3(0, h - 0.8, 0.03), soot)
			_d.box(Vector3(length - 0.4, 0.3, depth - 0.4), Vector3(0, h + 0.05, -depth * 0.5), Color("2a2220"))
			for k in 5:
				var x := -length * 0.5 + rng.randf() * length
				_d.box(Vector3(0.22, rng.randf_range(0.4, 1.4), 0.5), Vector3(x, h + 0.5, -0.25), soot.lightened(0.05))
			# Kömürleşmiş kirişler, göğe uzanan
			for k in 4:
				var x := -length * 0.4 + k * length * 0.27
				_d.box(Vector3(0.16, 0.16, depth * rng.randf_range(0.5, 1.1)), Vector3(x, h + 0.4, -depth * 0.5), Color("141010"),
					Vector3(rng.randf_range(-25, 25), rng.randf_range(-15, 15), 0))
			# Pencerelerde köz ışığı
			for k in 2:
				_d.glow(Vector3(0.55, 0.3, 0.02), Vector3(-length * 0.25 + k * length * 0.5, 4.0, 0.03), Color("ff6a2a"))
			if fires.size() < 7 and rng.randf() < 0.7:
				var sm := Vfx.smolder(self, center + Vector3(0, h, 0), 1.2)
				fires.append(sm)
		"collapsed":
			# Duvar dişleri ve caddeye taşan moloz
			for k in 5:
				var x := -length * 0.5 + (k + 0.5) * length / 5.0
				var th := rng.randf_range(0.5, 3.0)
				_d.box(Vector3(length / 5.0 - 0.1, th, 0.5), Vector3(x, hh + th * 0.5, -0.25), plaster.darkened(0.1))
			for k in 9:
				_d.box(Vector3(rng.randf_range(0.4, 1.0), rng.randf_range(0.25, 0.6), rng.randf_range(0.4, 1.0)),
					Vector3(rng.randf_range(-length * 0.45, length * 0.45), rng.randf_range(0.1, 0.5), rng.randf_range(0.2, 1.4)),
					Color("cdbd9e").darkened(rng.randf_range(0.0, 0.35)), Vector3(rng.randf_range(-25, 25), rng.randf_range(0, 90), rng.randf_range(-25, 25)))
			_d.box(Vector3(0.18, 0.18, 3.2), Vector3(rng.randf_range(-1.0, 1.0), 0.8, 0.8), Color("3a2a20"), Vector3(35, rng.randf_range(-30, 30), 0))
			_d.solid(Vector3(length - 0.6, 0.6, 1.0), Vector3(0, 0.3, 0.6))
	# Duman izi: pencerelerden yukarı uzanan kurum dilleri, saçak altında kararma
	if state != "collapsed":
		for k in 4:
			if rng.randf() < (0.8 if state == "burnt" else 0.45):
				var x := -length * 0.5 + (k + 0.5) * length / 4.0
				_d.box(Vector3(rng.randf_range(0.6, 1.1), rng.randf_range(1.6, 2.6), 0.03), Vector3(x, h - 1.4, 0.06), soot, Vector3(0, 0, rng.randf_range(-8, 8)))
		_d.box(Vector3(length + 0.04, 0.7, 0.05), Vector3(0, h - 0.35, 0.07), soot.lightened(0.08))
	# Kırık kapı: kanat yerde, eşikte
	if state != "collapsed":
		var dx := rng.randf_range(-length * 0.25, length * 0.25)
		_d.box(Vector3(1.0, 1.9, 0.08), Vector3(dx, 0.95, 0.04), Color("0e0c0a"))
		_d.box(Vector3(1.0, 0.08, 1.9), Vector3(dx + 0.2, 0.05, 1.1), Color("5a3a22"), Vector3(0, rng.randf_range(-25, 25), 0))
	# Askerlerin diktiği sancak (evi alan asker işaret koyar)
	if state != "collapsed" and rng.randf() < 0.45:
		var x := rng.randf_range(-length * 0.3, length * 0.3)
		_d.cyl(0.035, 2.2, Vector3(x, 4.8, 0.7), Color("4a3420"), Vector3(55, 0, 0), 5)
		_d.box(Vector3(0.9, 0.7, 0.03), Vector3(x + 0.45, 5.35, 1.5), Color("b3262d") if rng.randf() < 0.6 else Color("2e6a3a"), Vector3(55, 0, 0))


## Kilise (sol): tuğla-taş bantlı gövde, pencereli kasnak ve kurşun kubbe; kapısı ardına kadar açık, içi karanlık.
func _church() -> void:
	var c := CHURCH + Vector3(-5.0, 0, 0)
	var body := Props.solid(self, Vector3(10.0, 8.0, 12.0), c + Vector3(0, 4.0, 0), Color.WHITE)
	Props.set_pattern(body, Color("fff0e6"), "brick")
	body.set_meta("facade", true)
	Props.set_pattern(Props.cyl(self, 2.8, 2.4, c + Vector3(0, 9.2, 0), Color("d8a488"), Vector3.ZERO, 12), Color("fff0e6"), "brick")
	for k in 8:
		var a := TAU * k / 8.0
		Props.box(self, Vector3(0.4, 1.0, 0.1), c + Vector3(sin(a) * 2.82, 9.3, cos(a) * 2.82), Color("2a2a30"), Vector3(0, rad_to_deg(a), 0))
	Props.ball(self, 2.9, c + Vector3(0, 10.4, 0), Color("7a8594"), Vector3(1, 0.7, 1), 14)
	# Kubbede sancak (kilise ele geçirildi)
	Props.cyl(self, 0.05, 3.0, c + Vector3(0, 13.4, 0), Color("4a3420"), Vector3.ZERO, 5)
	Props.box(self, Vector3(1.4, 0.9, 0.03), c + Vector3(0.7, 14.4, 0), Color("b3262d"))
	# Cephe (caddeye bakan, x = -4.5): kemerli açık kapı, üstünde üç pencere, mermer söve
	var fx := CHURCH.x + 0.02
	Props.box(self, Vector3(0.06, 3.4, 2.2), Vector3(fx, 1.7, CHURCH.z), Color("0c0a08"))
	Props.cyl(self, 1.1, 0.06, Vector3(fx, 3.4, CHURCH.z), Color("0c0a08"), Vector3(0, 0, 90), 12)
	for sz: float in [-1.0, 1.0]:
		Props.box(self, Vector3(0.25, 3.6, 0.3), Vector3(fx + 0.1, 1.8, CHURCH.z + sz * 1.25), Color("ece2d0"))
	for k in 3:
		Props.box(self, Vector3(0.06, 1.2, 0.6), Vector3(fx, 5.6, CHURCH.z - 2.4 + k * 2.4), Color("2a2a30"))
	# Kapı kanatları sökülmüş, basamakta
	Props.box(self, Vector3(1.6, 0.3, 4.0), Vector3(fx + 0.8, 0.15, CHURCH.z), Color("b0a48c"))
	Props.box(self, Vector3(0.1, 2.2, 1.1), Vector3(fx + 1.6, 0.35, CHURCH.z + 1.9), Color("5a3a22"), Vector3(0, 20, 78))
	# Önünde dökülmüş şamdanlar ve kitap sayfaları
	for k in 5:
		_d.at(Vector3(fx + 1.0 + rng.randf() * 1.6, 0, CHURCH.z + rng.randf_range(-2.0, 2.0)), rng.randf() * TAU)
		_d.box(Vector3(0.3, 0.01, 0.22), Vector3(0, 0.3, 0), Color("efe6cf"))
	_d.at(Vector3(fx + 2.4, 0, CHURCH.z - 1.2), 0.0)
	_d.cyl(0.04, 0.9, Vector3(0, 0.08, 0), Color("c8a040"), Vector3(0, 0, 88), 6)


## Saray (sağ): Tekfur Sarayı gibi tuğla-mermer bantlı, sivri kemerli pencereli üç katlı cephe; dam yanmış, önünde
## devrik sütunlu revak. Sultan burada durur.
func _palace() -> void:
	var c := PALACE + Vector3(4.5, 0, 0)
	var body := Props.solid(self, Vector3(9.0, 11.0, 15.0), c + Vector3(0, 5.5, 0), Color.WHITE)
	Props.set_pattern(body, Color("fff0e6"), "brick")
	body.set_meta("facade", true)
	var fx := PALACE.x - 0.02
	# Mermer bantlar ve kemerli pencereler (üç kat)
	for y: float in [3.2, 6.6, 10.2]:
		Props.box(self, Vector3(0.12, 0.35, 15.2), Vector3(fx, y, PALACE.z), Color("ece2d0"))
	for row in 2:
		for k in 5:
			var z := PALACE.z - 6.0 + k * 3.0
			var y := 4.9 + row * 3.4
			Props.box(self, Vector3(0.08, 1.8, 1.0), Vector3(fx, y, z), Color("1c1614"))
			Props.cyl(self, 0.5, 0.08, Vector3(fx, y + 0.9, z), Color("1c1614"), Vector3(0, 0, 90), 10)
			if (row + k) % 2 == 0:
				Props.box(self, Vector3(0.05, 1.3, 0.12), Vector3(fx - 0.02, y + 1.9, z), Color("141010"))     # kurum
	# Yanmış dam: kömür kenar, kirişler; tepesinden duman
	Props.box(self, Vector3(9.2, 1.4, 15.2), Vector3(c.x, 10.3, c.z), Color("221c18"))
	for k in 5:
		Props.box(self, Vector3(8.0, 0.2, 0.2), Vector3(c.x, 11.4, c.z - 6.0 + k * 3.0), Color("141010"), Vector3(rng.randf_range(-12, 12), 0, rng.randf_range(-10, 10)))
	fires.append(Vfx.smolder(self, c + Vector3(0, 11.2, 0), 2.0))
	# Revak: dört sütun, biri devrik ve kırık
	for k in 4:
		var z := PALACE.z - 5.4 + k * 3.6
		if k == 2:
			Props.cyl(self, 0.26, 3.4, Vector3(PALACE.x - 1.8, 0.28, z + 0.6), Color("d8d0c0"), Vector3(0, 30, 90), 10)
			Props.cyl(self, 0.28, 0.5, Vector3(PALACE.x - 1.6, 0.25, z), Color("d8d0c0"), Vector3.ZERO, 10)
			var col := Props.solid(self, Vector3(0.6, 0.6, 3.2), Vector3(PALACE.x - 1.8, 0.3, z + 0.6), Color.WHITE)
			col.get_child(0).visible = false
		else:
			Props.cyl(self, 0.26, 3.8, Vector3(PALACE.x - 1.6, 1.9, z), Color("d8d0c0"), Vector3.ZERO, 10)
			Props.box(self, Vector3(0.7, 0.3, 0.7), Vector3(PALACE.x - 1.6, 3.9, z), Color("ece2d0"))
			var col2 := Props.solid(self, Vector3(0.55, 3.8, 0.55), Vector3(PALACE.x - 1.6, 1.9, z), Color.WHITE)
			col2.get_child(0).visible = false
	Props.box(self, Vector3(2.2, 0.35, 12.4), Vector3(PALACE.x - 1.1, 4.2, PALACE.z - 0.1), Color("cdbd9e"))


func _street_clutter() -> void:
	# Devrik araba (yan yatmış), kopmuş tekerlek
	_d.at(Vector3(-2.6, 0, -22.0), 0.3)
	_d.box(Vector3(1.4, 0.7, 2.4), Vector3(0, 0.55, 0), Color("6a4a2c"), Vector3(0, 0, 70))
	_d.cyl(0.55, 0.1, Vector3(0.9, 0.3, 0.6), Color("4a3420"), Vector3(90, 0, 0), 12)
	_d.cyl(0.55, 0.1, Vector3(1.6, 0.06, -1.4), Color("4a3420"), Vector3(0, 0, 0), 12)
	_d.solid(Vector3(1.6, 1.2, 2.6), Vector3(0.3, 0.6, 0))
	# Kırık küpler, dağılmış eşya, düşmüş kirişler (caddenin kenarlarında: alayın yolu açık)
	for k in 26:
		var sx := -1.0 if k % 2 == 0 else 1.0
		var p := Vector3(sx * rng.randf_range(2.6, 4.1), 0, rng.randf_range(Z1 + 4.0, Z0 - 3.0))
		_d.at(p, rng.randf() * TAU)
		match k % 6:
			0: _d.amphora(Vector3.ZERO, rng.randf_range(60, 90))
			1: _d.sack(Vector3.ZERO)
			2: _d.box(Vector3(0.18, 0.18, 2.4), Vector3(0, 0.1, 0), Color("2a2220"))
			3: _d.basket(Vector3.ZERO)
			4: _d.rubble(Vector3.ZERO)
			5: _d.box(Vector3(0.7, 0.05, 0.5), Vector3(0, 0.03, 0), [Color("8a2b22"), Color("2a4a7a"), Color("c8a040")][rng.randi() % 3])
	# Yerde is lekeleri (yanan eşyanın izi)
	for k in 14:
		_d.at(Vector3(rng.randf_range(-3.8, 3.8), 0, rng.randf_range(Z1 + 4.0, Z0 - 3.0)), rng.randf() * TAU)
		_d.cyl(rng.randf_range(0.6, 1.4), 0.015, Vector3(0, 0.02, 0), Color("2a2420"), Vector3.ZERO, 10)
	# Molozların üstünde tüten ateşler (caddenin kenarı)
	for p: Vector3 in [Vector3(-3.6, 0, -16.0), Vector3(3.7, 0, -31.0), Vector3(-3.5, 0, -55.0), Vector3(3.4, 0, -76.0),
			Vector3(3.6, 0, -11.0), Vector3(-3.7, 0, -27.0), Vector3(3.5, 0, -48.0), Vector3(-3.6, 0, -70.0)]:
		_d.at(p, rng.randf() * TAU)
		_d.rubble(Vector3.ZERO)
		var f := Vfx.fire(self, p + Vector3(0, 0.3, 0), 0.6, Vector3(0.2, 0, 0))
		fires.append(f)
		var l := OmniLight3D.new()
		l.light_color = Color("ff8a3a")
		l.light_energy = 1.2
		l.omni_range = 5.0
		l.position = p + Vector3(0, 1.0, 0)
		add_child(l)


## Caddenin sonu: yeniçeri sırası (sınır) ve ardında şehrin devamı.
func _end_line() -> void:
	var blk := Props.solid(self, Vector3(STREET * 2.0, 4.0, 0.4), Vector3(0, 2.0, Z1 + 1.5), Color.WHITE)
	blk.get_child(0).visible = false
	blk.set_meta("no_climb", true)


func _skyline() -> void:
	# Evlerin ardında şehrin çatıları ve duman sütunları; ufukta Ayasofya
	var xf: Array = []
	var cols: Array = []
	for i in 140:
		var sx := -1.0 if i % 2 == 0 else 1.0
		var p := Vector3(sx * rng.randf_range(13.0, 70.0), 0, rng.randf_range(-10.0, -240.0))
		xf.append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(0.9, 1.6)), p))
		cols.append([Color("d8b89a"), Color("c8a888"), Color("b89878"), Color("e0c8a8")][i % 4])
	Scenery.scatter(self, Scenery.house_mesh(), xf, cols)
	# Koyu (yanan evlerden) ve açık (sönmekte olan) duman sütunları
	for k in 14:
		Scenery.smoke_column(self, Vector3(rng.randf_range(-80, 80), rng.randf_range(4, 10), rng.randf_range(-20, -320)), k % 3 != 0)
	Scenery.hagia_sophia(self, Vector3(-40.0, 0, -520.0), 2.2)


## Yağmacılar (kapılar arasında sandık, çuval taşır), kilisenin önünde yaşlı papaz, duvar dibinde oturan halk,
## caddenin sonunda yeniçeriler.
func _people() -> void:
	var doors: Array[Vector3] = []
	for k in 10:
		var sx := -1.0 if k % 2 == 0 else 1.0
		doors.append(Vector3(sx * 3.2, 0, rng.randf_range(Z1 + 6.0, Z0 - 6.0)))
	for i in 4:
		var p := Person.new({"coat": [Color("b3262d"), Color("2f5fa8"), Color("6a4a3a"), Color("3a6b3a")][i], "pants": Color("e8e0d0"),
			"hat": "bork" if i % 2 == 0 else "turban", "mustache": true, "beard": i == 3, "skin": Color("d9a07a"), "n": 5290 + i})
		p.set_meta("no_talk", true)
		p.set_meta("walker", true)
		p.position = doors[i * 2]
		add_child(p)
		p.carry(["crate", "sack", "basket", "sack"][i])
		var w := Walker.new()
		w.nodes = doors
		w.seed_value = 529 + i
		w.space_owner = self
		w.person = p
		add_child(w)
		looters.append(p)
	# Kilisenin basamağında yaşlı papaz; yanında bir asker nöbette
	var priest := Person.new({"coat": Color("1e1e22"), "robe": Color("1e1e22"), "beard": true, "hat": "kamelaukion", "hair": Color("c8c8c8"),
		"skin": Color("e0b08a"), "n": 5300})
	priest.set_meta("no_talk", true)
	priest.position = Vector3(CHURCH.x + 1.3, 0.3, CHURCH.z + 1.6)
	priest.rotation.y = PI * 0.5
	add_child(priest)
	priest.set_activity("sit_ground")
	Garrison.man(self, Vector3(CHURCH.x + 1.4, 0, CHURCH.z - 1.9), PI * 0.5, 5301, "spear")
	# Duvar dibinde oturan halk (sağda, sarayın öncesinde)
	for i in 3:
		var c := Person.new({"coat": [Color("6a5040"), Color("7a8a5a"), Color("5a6a7a")][i], "pants": Color("3a3028"), "skirt": i != 1,
			"hair": Color("3a2a1e"), "hat": "bun" if i == 0 else "none", "n": 5310 + i})
		c.set_meta("no_talk", true)
		c.position = Vector3(3.9, 0, -45.0 - i * 0.9)
		c.rotation.y = -PI * 0.5
		add_child(c)
		c.set_activity("sit_ground")
	# Caddenin sonunda yeniçeri sırası (alay buradan Ayasofya'ya gider)
	for k in 8:
		var s := Soldier.new([Color("b3262d"), Color("2f5fa8")][k % 2], "stand", "bork")
		s.position = Vector3(-3.5 + k * 1.0, 0, Z1 + 2.2)
		add_child(s)
		s.equip("spear")
