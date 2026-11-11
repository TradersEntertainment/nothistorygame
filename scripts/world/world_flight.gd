class_name WorldFlight
extends RefCounted
## Tek haritada Nihat'ın uçuşu (Bölüm 7, 11): dünyanın görüntüsü çarpışmasız kurulur (uzak manzara); uçuşlu bölümler
## için buraya çarpışma eklenir:
##   · Zemin: World1453.ground_h'den tek HeightMapShape3D (20 m ızgara). Bölgelerin düz alanında bölgenin zemini.
##   · Su: Haliç, Boğaz ve Marmara üstünde su yakalayıcılar (suya inen Nihat yeniden havalanır).
##   · Yapılar: dünyanın Props ilkelleri "far_scenery" ile katılaşır (NihatPowers.ensure_flight_solids); Dressing ağıyla
##     kurulan kıyı surları için kaba kutular; konma noktaları (Ayasofya kubbesi, Galata Kulesi şerefesi, Konstantin
##     Sütunu) için açık gövdeler.

const STEP := 20.0
const X0 := -2600.0
const X1 := 1800.0
const Z0 := -2700.0
const Z1 := 1000.0


static func attach(world: SiegeField) -> void:
	if world == null or world.has_meta("flight"):
		return
	world.set_meta("flight", true)
	world.set_meta("far_scenery", true)
	_ground(world)
	_water(world)
	_landmark_bodies(world)
	if world.horn:
		var body := StaticBody3D.new()
		body.name = "FlightWalls"
		world.horn.add_child(body)
		for fb: Array in world.horn.flight_boxes:
			var cs := CollisionShape3D.new()
			var bs := BoxShape3D.new()
			bs.size = fb[1]
			cs.shape = bs
			cs.transform = fb[0]
			body.add_child(cs)


static func _ground(world: SiegeField) -> void:
	# Ölçekli HeightMapShape3D geniş evrede delikli çıkıyordu (şehrin ortası ve dönük bölgelerde uzak kenarlar
	# çarpışmasızdı): ızgara sahne çerçevesinde (dünyanın ebeveyni) örneklenir, 16×16 hücrelik üçgen döşemelerine
	# bölünür (ConcavePolygonShape3D, ölçeksiz). Yükseklik dünyadan okunur.
	var parent := world.get_parent() as Node3D
	var to_w := world.transform.affine_inverse()          # ebeveyn yereli → dünya
	var a := world.transform * Vector3(X0, 0, Z0)
	var b := world.transform * Vector3(X1, 0, Z1)
	var x0 := minf(a.x, b.x)
	var z0 := minf(a.z, b.z)
	var w := int(absf(b.x - a.x) / STEP) + 1
	var d := int(absf(b.z - a.z) / STEP) + 1
	var hs := PackedFloat32Array()
	hs.resize(w * d)
	var y0 := to_w.origin.y
	for j in d:
		for i in w:
			var wp := to_w * Vector3(x0 + i * STEP, 0.0, z0 + j * STEP)
			hs[j * w + i] = World1453.ground_h(wp.x, wp.z) - y0
	var body := StaticBody3D.new()
	body.name = "FlightGround"
	const T := 16
	for tj in range(0, d - 1, T):
		for ti in range(0, w - 1, T):
			var faces := PackedVector3Array()
			for j in range(tj, mini(tj + T, d - 1)):
				for i in range(ti, mini(ti + T, w - 1)):
					var p00 := Vector3(x0 + i * STEP, hs[j * w + i], z0 + j * STEP)
					var p10 := Vector3(x0 + (i + 1) * STEP, hs[j * w + i + 1], z0 + j * STEP)
					var p01 := Vector3(x0 + i * STEP, hs[(j + 1) * w + i], z0 + (j + 1) * STEP)
					var p11 := Vector3(x0 + (i + 1) * STEP, hs[(j + 1) * w + i + 1], z0 + (j + 1) * STEP)
					faces.append_array([p00, p10, p01, p10, p11, p01])
			var shape := ConcavePolygonShape3D.new()
			shape.backface_collision = true
			shape.set_faces(faces)
			var cs := CollisionShape3D.new()
			cs.shape = shape
			body.add_child(cs)
	parent.add_child(body)
	world.set_meta("flight_ground", body)


static func _water(world: SiegeField) -> void:
	var sea := World1453.SEA_Y
	# Haliç, Boğaz, Marmara (HornWorld._water düzlemleriyle aynı)
	for r: Rect2 in [Rect2(-1000.0, -1700.0, World1453.HORN_S_X + 1000.0, 2260.0), Rect2(-3200.0, -4200.0, 6800.0, 2500.0),
			Rect2(-560.0, -1700.0, 4160.0, 1688.0), Rect2(700.0, -12.0, 2900.0, 1612.0)]:
		CityPanorama.water_catch(world, Vector3(r.size.x, 1.2, r.size.y), Vector3(r.get_center().x, sea - 0.2, r.get_center().y))


static func _landmark_bodies(world: SiegeField) -> void:
	var ay: Vector3 = World1453.LANDMARKS["ayasofya"]
	if world.region_name != "byz_aya":
		Scenery.hagia_body(world, Vector3(ay.x, HornWorld.east_surf(ay.x, ay.z) - 1.0, ay.z), 1.0)
	var tw: Vector3 = World1453.LANDMARKS["galata_tower"]
	if world.region_name != "galata":
		var base := HornWorld.north_surf(tw.x, tw.z) - 1.0
		var gallery := World1453.galata_top(tw) - 1.2
		_cyl(world, 5.2, Vector3(tw.x, base, tw.z), gallery)           # şerefe halkasına kadar (üstüne konulur)
		_cyl(world, 3.6, Vector3(tw.x, gallery, tw.z), gallery + 10.5)  # şerefe odası ve külah
	var col: Vector3 = World1453.LANDMARKS["column"]
	if world.region_name != "byz_aya":
		var g := HornWorld.east_surf(col.x, col.z)
		_cyl(world, 3.0, Vector3(col.x, g, col.z), g + 34.0)


static func _cyl(parent: Node3D, r: float, base: Vector3, top_y: float) -> void:
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var cy := CylinderShape3D.new()
	cy.radius = r
	cy.height = top_y - base.y
	cs.shape = cy
	body.position = Vector3(base.x, (base.y + top_y) * 0.5, base.z)
	body.add_child(cs)
	parent.add_child(body)
