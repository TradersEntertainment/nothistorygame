class_name CityPanorama
extends RefCounted
## Ordugâhın (CampDay) kara surlarının ardındaki Konstantinopolis: Nihat'ın uçarak gittiği şehir manzarası.
## Yedi tepe (gerçek arazi: görüntü ızgarası + HeightMap çarpışması, üstünde yürünür) üstünde sokak ızgarasına
## dizilmiş ~1500 ev; evlerin yakın ayrıntısı Nihat yaklaştıkça CityStream ile yüklenir. Tepelerde yapılar:
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
## Galata tepesi: Ceneviz kasabası kıyıdan kuleye doğru tırmanır
const GALATA_HILL := [-500.0, 400.0, 170.0, 38.0]
const GALATA_SHORE := -362.0
## Ceneviz surları: kuleden kıyıya inen iki kol ve kıyı suru (üçgen kasaba)
const GALATA_A := Vector3(-362.0, 0, 282.0)
const GALATA_B := Vector3(-362.0, 0, 492.0)
const PODESTA := Vector3(-384.0, 0, 386.0)
const SAN_PAOLO := Vector3(-385.0, 0, 350.0)
const SAN_FRANCESCO := Vector3(-385.0, 0, 440.0)
## Arazi ızgarası (görüntü + HeightMap çarpışması)
const TERR_X0 := -720.0
const TERR_X1 := 252.0
const TERR_Z0 := 122.0
const TERR_Z1 := 546.0
const TERR_STEP := 4.0

const AYA := Vector3(40.0, 0, 392.0)
const HIPPO := Vector3(138.0, 0, 360.0)
const COLUMN := Vector3(66.0, 0, 300.0)
const APOSTLES := Vector3(-64.0, 0, 240.0)
const AQUEDUCT_Z := 288.0
const BLACHERNAE := Vector3(-200.0, 0, 150.0)
const GALATA_TOWER := Vector3(-452.0, 0, 396.0)
const CHAIN_Z := 458.0

const C_GROUND := Color("8a7c5c")
const C_BRICK := Color("9a4e36")
const C_STONE := Color("c8b898")
const C_LEAD := Color("5c6a7c")
const C_WATER := Color("3e6e8e")


## Döndür, sonra yerel ölçekle (Scenery._t küresel ölçekler; döndürülmüş kutular eğrilir)
static func _tx(pos: Vector3, rot := Vector3.ZERO, scl := Vector3.ONE) -> Transform3D:
	return Transform3D(Basis.from_euler(rot) * Basis.from_scale(scl), pos)


const TONES := [Color("e8d8c0"), Color("d8c0a0"), Color("e0ccb0"), Color("d0a888"), Color("c8b89c"), Color("e8c8a8"), Color("b8a898"), Color("dcc4a4")]
const STONES := [Color("b8aa8c"), Color("a89a80"), Color("c0b090"), Color("b0a488")]
const TILES := [Color("b5563a"), Color("a84a32"), Color("c0653f"), Color("9a4a36"), Color("b86848")]
const SHUTTERS := [Color("3a5a3a"), Color("4a3a2a"), Color("2e4a6a"), Color("6a3a2a"), Color("5a6a4a"), Color("7a6a4a")]


## Tepeler: çan eğrisi (kenarda eğim sıfır, arazi ızgarası yumuşak okunur)
static func hill_h(x: float, z: float) -> float:
	var h := 0.0
	for hl in HILLS + [GALATA_HILL]:
		var d := Vector2(x - hl[0], z - hl[1]).length()
		if d < hl[2]:
			h = maxf(h, hl[3] * 0.5 * (1.0 + cos(PI * d / hl[2])))
	return h


## 0 = deniz, 1 = kara (kıyıda 8 m'lik geçiş). Şehir: Haliç ile Marmara arası, burna kadar; Galata: kıyı çizgisinin batısı.
static func land(x: float, z: float) -> float:
	var dc := minf(minf(x - HORN_X, SEA_X - x), TIP_Z - z)
	var dg := GALATA_SHORE - x
	return clampf(maxf(dc, dg) / 8.0, 0.0, 1.0)


static func ground_h(x: float, z: float) -> float:
	var base := 0.6 * clampf((z - TERR_Z0) / 4.0, 0.0, 1.0)
	return lerpf(-4.0, base + hill_h(x, z), land(x, z))


static func _on(p: Vector3) -> Vector3:
	return Vector3(p.x, ground_h(p.x, p.z), p.z)


## Kurar; seyir noktalarını parent'ın yerel koordinatında döndürür: [[id, konum, yarıçap], ...]
## Gece ışıkları (Ayasofya'nın kandilleri, saray pencereleri) "night" adlı düğümde, gizli başlar; evlerin camları
## "Stream" (CityStream.set_night) ile yanar.
static func build(parent: Node3D, base_y: float) -> Array:
	var root := Node3D.new()
	root.name = "CityPanorama"
	root.position = Vector3(0, base_y, 0)
	parent.add_child(root)
	var night := Node3D.new()
	night.name = "night"
	night.visible = false
	root.add_child(night)
	terrain(root, TERR_X0, TERR_X1, TERR_Z0, TERR_Z1)
	# Deniz düzlemleri ve suya inme alanları: OuterWorld (CampDay kurar)
	var stream := CityStream.new()
	stream.name = "Stream"
	root.add_child(stream)
	_city_lots(stream, root)
	_galata_lots(stream)
	stream.finish()
	var windows: Array = []
	var aya := _on(AYA)
	Scenery.hagia_sophia(root, aya, 1.0, true, true)
	_aya_night(night, aya)
	_hippodrome(root, _on(HIPPO))
	_column(root, _on(COLUMN))
	_apostles(root, _on(APOSTLES))
	_aqueduct(root)
	_blachernae(root, _on(BLACHERNAE), windows)
	_horn(root)
	_galata(root, night)
	_galata_people(root)
	_bosphorus(root)
	_sea_walls(root)
	_window_lights(night, windows)
	# Martılar (Haliç, Galata, burun) ve bacalardan tüten dumanlar
	Gulls.make(root, Vector3((HORN_X + GALATA_SHORE) * 0.5, 0, 380.0), 12, 55.0, 26.0, 1)
	Gulls.make(root, _on(GALATA_TOWER), 7, 22.0, 58.0, 2)
	Gulls.make(root, Vector3(60.0, 0, TIP_Z + 20.0), 10, 60.0, 22.0, 3)
	for sp in [Vector3(-120, 0, 200), Vector3(90, 0, 250), Vector3(-30, 0, 410), Vector3(180, 0, 330), Vector3(-450, 0, 440)]:
		Scenery.smoke_column(root, _on(sp) + Vector3(0, 6.0, 0))
	var y := base_y
	return [
		["AYASOFYA", aya + Vector3(0, 46 + y, 0), 48.0],
		["HIPODROM", _on(HIPPO) + Vector3(0, 12 + y, 0), 60.0],
		["KONSTANTIN", _on(COLUMN) + Vector3(0, 30 + y, 0), 26.0],
		["HAVARIYUN", _on(APOSTLES) + Vector3(0, 24 + y, 0), 38.0],
		["BOZDOGAN", Vector3(-10, 26 + y, AQUEDUCT_Z), 34.0],
		["ZINCIR", Vector3((HORN_X + GALATA_SHORE) * 0.5, 8 + y, CHAIN_Z), 45.0],
		["GALATA", _on(GALATA_TOWER) + Vector3(0, 50 + y, 0), 36.0],
		["BLAKHERNA", _on(BLACHERNAE) + Vector3(0, 16 + y, 0), 34.0],
		["SURLAR", Vector3(0, 18 + y, WALL_Z + 9.0), 30.0],
	]


## Başka haritalar için (ByzCity): karşı kıyıda Galata (arazisi, evleri, surları, yapıları, insanları).
## pos: kıyı çizgisinin ortası (dünya), yaw: kasabanın kıyıya bakan yüzünün dönüşü (0 = +x'e bakar).
## Kulenin tepesini (dünya) döndürür.
static func galata_view(parent: Node3D, pos: Vector3, yaw: float) -> Vector3:
	var n := Node3D.new()
	n.name = "GalataView"
	n.rotation.y = yaw
	parent.add_child(n)
	n.position = pos - n.basis * Vector3(GALATA_SHORE, 0, 385.0)
	terrain(n, TERR_X0, GALATA_SHORE + 26.0, 126.0, TERR_Z1)
	var stream := CityStream.new()
	stream.name = "Stream"
	n.add_child(stream)
	_galata_lots(stream)
	stream.finish()
	var night := Node3D.new()
	night.name = "night"
	night.visible = false
	n.add_child(night)
	_galata(n, night)
	_galata_people(n)
	Gulls.make(n, _on(GALATA_TOWER), 7, 22.0, 58.0, 2)
	Gulls.make(n, Vector3(GALATA_SHORE + 60.0, 0, 390.0), 10, 50.0, 24.0, 4)
	return n.to_global(_on(GALATA_TOWER) + Vector3(0, 58, 0))


## Arazi: ızgara ağ örgüsü (köşe renkli: şehirde toprak, tepelerde ve sur dışında çayır, su altında kum) ve aynı
## yüksekliklerden HeightMap çarpışması (Nihat her yere konar, sokaklarda yürür).
## hf/cf verilmezse CityPanorama'nın kendi arazisi (ground_h) ve renkleri kullanılır.
static func terrain(root: Node3D, x0: float, x1: float, z0: float, z1: float, hf := Callable(), cf := Callable()) -> void:
	var nx := int(round((x1 - x0) / TERR_STEP)) + 1
	var nz := int(round((z1 - z0) / TERR_STEP)) + 1
	var verts := PackedVector3Array()
	var cols := PackedColorArray()
	var hs := PackedFloat32Array()
	hs.resize(nx * nz)
	verts.resize(nx * nz)
	cols.resize(nx * nz)
	var dust := C_GROUND
	var grass := Color("74844c")
	var sand := Color("b8a878")
	for j in nz:
		for i in nx:
			var x := x0 + i * TERR_STEP
			var z := z0 + j * TERR_STEP
			var h: float = hf.call(x, z) if hf.is_valid() else ground_h(x, z)
			var id := j * nx + i
			hs[id] = h
			verts[id] = Vector3(x, h, z)
			var l := land(x, z)
			var wild := x < GALATA_SHORE and not _in_galata(Vector3(x, 0, z))
			# Galata surlarının dışı: çayır değil, bağ, bostan ve kuru toprak lekeleri (1453 Pera sırtları)
			var patch := 0.5 + 0.5 * sin(x * 0.047 + cos(z * 0.031) * 2.0) * cos(z * 0.053)
			var c := Color("8c8558").lerp(Color("9c8a66"), patch).lerp(Color("6f7446"), clampf(patch - 0.7, 0.0, 0.3) * 2.0) if wild \
				else dust.lerp(grass, clampf(hill_h(x, z) / 40.0, 0.0, 0.35))
			if x < GALATA_SHORE and not wild:
				c = Color("9a8c72")     # Galata'nın taş döşeli sokakları
			c = c.darkened(0.06 * (sin(x * 0.13) * cos(z * 0.11) + 0.5))
			cols[id] = cf.call(x, z, h) if cf.is_valid() else sand.lerp(c, l)
	var norms := PackedVector3Array()
	norms.resize(nx * nz)
	for j in nz:
		for i in nx:
			var hl := hs[j * nx + maxi(i - 1, 0)]
			var hr := hs[j * nx + mini(i + 1, nx - 1)]
			var hd := hs[maxi(j - 1, 0) * nx + i]
			var hu := hs[mini(j + 1, nz - 1) * nx + i]
			norms[j * nx + i] = Vector3(hl - hr, 2.0 * TERR_STEP, hd - hu).normalized()
	var idx := PackedInt32Array()
	for j in nz - 1:
		for i in nx - 1:
			var a := j * nx + i
			for v in [a, a + 1, a + nx, a + 1, a + nx + 1, a + nx]:
				idx.append(v)
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
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.roughness = 1.0
	var mi := MeshInstance3D.new()
	mi.mesh = am
	mi.material_override = mat
	mi.name = "Terrain"
	root.add_child(mi)
	var hm := HeightMapShape3D.new()
	hm.map_width = nx
	hm.map_depth = nz
	var scaled := PackedFloat32Array()
	scaled.resize(hs.size())
	for i in hs.size():
		scaled[i] = hs[i] / TERR_STEP
	hm.map_data = scaled
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = hm
	cs.scale = Vector3.ONE * TERR_STEP
	body.position = Vector3((x0 + x1) * 0.5, 0, (z0 + z1) * 0.5)
	body.add_child(cs)
	root.add_child(body)


## Deniz: koyu mavi-yeşil, yarı mat. Parlak (pürüzsüzlük 0.15, yansıma 0.8) iken güneş yakındaki bütün denizi
## bembeyaz parlatıyordu. Kendi malzemesi: Props.mat önbelleği paylaşılınca başka yüzeyler de parlıyordu.
static func water_mat() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("2f5d78")
	mat.roughness = 0.55
	mat.metallic_specular = 0.25
	return mat


static func _water_plane(root: Node3D, size: Vector2, center: Vector3) -> void:
	var m := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = size
	m.mesh = pm
	m.position = center
	m.material_override = water_mat()
	root.add_child(m)


## Suya inen Nihat: formlar ıslanmaz, Büro donanımı onu yeniden havalandırır (NihatPowers.on_water).
static func water_catch(root: Node3D, size: Vector3, center: Vector3) -> void:
	var area := Area3D.new()
	area.monitorable = false
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	area.add_child(cs)
	area.position = center
	area.body_entered.connect(func(b: Node3D):
		if b is Player and (b as Player).powers:
			(b as Player).powers.on_water())
	root.add_child(area)


static func _blocked(keep: Array, p: Vector3, grow: float) -> bool:
	for r in keep:
		if (r as Rect2).grow(grow).has_point(Vector2(p.x, p.z)):
			return true
	return false


static func _lot(rng: RandomNumberGenerator, c: Vector3, rot: float, size: float, gen: bool) -> Dictionary:
	var fl: int = ([2, 3, 3, 4] if gen else [1, 2, 2, 2, 3, 3])[rng.randi() % (4 if gen else 6)]
	return {
		"p": Vector3(c.x, ground_h(c.x, c.z) - 0.15, c.z), "rot": rot + rng.randf_range(-0.03, 0.03),
		"w": size - rng.randf_range(0.4, 1.4), "d": size - rng.randf_range(0.4, 1.4), "floors": fl,
		"style": "gen" if gen else "byz", "tone": TONES[rng.randi() % TONES.size()], "stone": STONES[rng.randi() % STONES.size()],
		"tile": TILES[rng.randi() % TILES.size()], "shutter": SHUTTERS[rng.randi() % SHUTTERS.size()],
		"seed": rng.randi(), "lit": rng.randf() < 0.4,
	}


## Konstantinopolis: hafif dönük sokak ızgarası (19 m aralık, 15 m ada, adada dört ev); büyük yapıların çevresi
## boş kalır; arada bir ada semt kilisesi ya da bahçe olur.
static func _city_lots(stream: CityStream, root: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var keep := [
		Rect2(AYA.x - 45, AYA.z - 92, 90, 134), Rect2(HIPPO.x - 30, HIPPO.z - 76, 74, 152),
		Rect2(COLUMN.x - 18, COLUMN.z - 15, 36, 30), Rect2(APOSTLES.x - 36, APOSTLES.z - 34, 90, 68),
		Rect2(-56, AQUEDUCT_Z - 5, 94, 10), Rect2(BLACHERNAE.x - 26, BLACHERNAE.z - 14, 60, 28),
		Rect2(160, 392, 80, 60),   # Büyük Saray
	]
	var a := 0.08
	var basis := Basis(Vector3.UP, a)
	var pitch := 19.0
	var blk := 15.0
	var c0 := Vector3((HORN_X + SEA_X) * 0.5, 0, (WALL_Z + TIP_Z) * 0.5)
	for gi in range(-16, 17):
		for gj in range(-11, 12):
			var bc := c0 + basis * Vector3(gi * pitch, 0, gj * pitch)
			if bc.z < WALL_Z + 20.0 or bc.z > TIP_Z - 12.0 or bc.x < HORN_X + 12.0 or bc.x > SEA_X - 14.0:
				continue
			if _blocked(keep, bc, 8.0):
				continue
			if rng.randf() < 0.035:
				_parish(root, _on(bc), a, rng)
				continue
			for q in 4:
				var sx := -1.0 if q % 2 == 0 else 1.0
				var sz := -1.0 if q < 2 else 1.0
				var c := bc + basis * Vector3(sx * blk * 0.25, 0, sz * blk * 0.25)
				if land(c.x, c.z) < 1.0 or _blocked(keep, c, 4.0):
					continue
				var lot := _lot(rng, c, a + (0.0 if sz > 0.0 else PI), blk * 0.5, false)
				if rng.randf() < 0.07:
					lot.style = "garden"
				stream.add_lot(lot)


## Başka haritalar için: dikdörtgen bir bölgeyi sokak ızgarasıyla evlere böler (hf: zemin yüksekliği).
static func region_lots(stream: CityStream, root: Node3D, rect: Rect2, angle: float, pitch: float, blk: float, hf: Callable, keep: Array, seed: int, parish := 0.03) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var basis := Basis(Vector3.UP, angle)
	var c0 := Vector3(rect.get_center().x, 0, rect.get_center().y)
	var ni := int(rect.size.x / pitch * 0.5) + 2
	var nj := int(rect.size.y / pitch * 0.5) + 2
	for gi in range(-ni, ni + 1):
		for gj in range(-nj, nj + 1):
			var bc := c0 + basis * Vector3(gi * pitch, 0, gj * pitch)
			if not rect.grow(-blk * 0.5).has_point(Vector2(bc.x, bc.z)) or _blocked(keep, bc, blk * 0.5):
				continue
			if rng.randf() < parish:
				_parish(root, Vector3(bc.x, hf.call(bc.x, bc.z), bc.z), angle, rng)
				continue
			for q in 4:
				var sx := -1.0 if q % 2 == 0 else 1.0
				var sz := -1.0 if q < 2 else 1.0
				var c := bc + basis * Vector3(sx * blk * 0.25, 0, sz * blk * 0.25)
				var lot := _lot(rng, c, angle + (0.0 if sz > 0.0 else PI), blk * 0.5, false)
				lot.p.y = float(hf.call(c.x, c.z)) - 0.15
				if rng.randf() < 0.07:
					lot.style = "garden"
				stream.add_lot(lot)


## Semt kilisesi: tuğla gövde, pencereli kasnak, kurşun kubbe, yanında servi.
static func _parish(root: Node3D, p: Vector3, a: float, rng: RandomNumberGenerator) -> void:
	var r := rng.randf_range(3.5, 5.5)
	var n := Node3D.new()
	n.position = p
	n.rotation.y = a
	root.add_child(n)
	Props.box(n, Vector3(r * 2.6, r * 1.4 + 2.0, r * 2.2), Vector3(0, r * 0.7 - 1.0, 0), C_BRICK.lightened(0.1))
	Props.cyl(n, r * 0.62, r * 0.5, Vector3(0, r * 1.65, 0), Color("c8a890"), Vector3.ZERO, 12)
	Props.ball(n, r * 0.64, Vector3(0, r * 1.9, 0), C_LEAD.lightened(0.2), Vector3(1, 0.7, 1), 12)
	Props.box(n, Vector3(0.25, 1.6, 0.25), Vector3(0, r * 2.35 + 0.8, 0), Color("d9b24a"))
	Props.box(n, Vector3(0.9, 0.2, 0.2), Vector3(0, r * 2.35 + 1.1, 0), Color("d9b24a"))
	Props.cyl(n, 0.6, 7.5, Vector3(r * 1.7, 3.75, r), Color("2e4a2a"), Vector3.ZERO, 7, 0.05)
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(r * 2.6, r * 2.4, r * 2.2)
	cs.shape = bs
	cs.position = Vector3(0, r * 0.7, 0)
	body.add_child(cs)
	n.add_child(body)


static func _in_galata(p: Vector3) -> bool:
	var t := Vector2(GALATA_TOWER.x, GALATA_TOWER.z)
	var a := Vector2(GALATA_A.x, GALATA_A.z)
	var b := Vector2(GALATA_B.x, GALATA_B.z)
	return Geometry2D.point_is_inside_triangle(Vector2(p.x, p.z), t, a, b)


static func _wall_dist(p: Vector3) -> float:
	var q := Vector2(p.x, p.z)
	var t := Vector2(GALATA_TOWER.x, GALATA_TOWER.z)
	var a := Vector2(GALATA_A.x, GALATA_A.z)
	var b := Vector2(GALATA_B.x, GALATA_B.z)
	var d := INF
	for seg in [[t, a], [t, b], [a, b]]:
		d = minf(d, q.distance_to(Geometry2D.get_closest_point_to_segment(q, seg[0], seg[1])))
	return d


## Galata: surların içinde sık Ceneviz evleri (taş, 2-4 kat, revaklı), dışında bağ-bahçe arasında seyrek evler.
static func _galata_lots(stream: CityStream) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1348
	var a := 0.3
	var basis := Basis(Vector3.UP, a)
	var pitch := 16.0
	var blk := 12.5
	var c0 := Vector3(-440.0, 0, 390.0)
	var spots := [[GALATA_TOWER, 17.0], [PODESTA, 22.0], [SAN_PAOLO, 26.0], [SAN_FRANCESCO, 24.0]]
	for gi in range(-18, 13):
		for gj in range(-16, 17):
			var bc := c0 + basis * Vector3(gi * pitch, 0, gj * pitch)
			if bc.x > GALATA_SHORE - 9.0 or bc.x < -680.0 or bc.z < 140.0 or bc.z > 540.0:
				continue
			var inside := _in_galata(bc)
			if not inside and rng.randf() > 0.3:
				continue
			for q in 4:
				var sx := -1.0 if q % 2 == 0 else 1.0
				var sz := -1.0 if q < 2 else 1.0
				var c := bc + basis * Vector3(sx * blk * 0.25, 0, sz * blk * 0.25)
				if land(c.x, c.z) < 1.0 or _wall_dist(c) < 6.5:
					continue
				var bad := false
				for sp in spots:
					if Vector2(c.x - sp[0].x, c.z - sp[0].z).length() < sp[1]:
						bad = true
				if bad:
					continue
				var lot := _lot(rng, c, a + (0.0 if sz > 0.0 else PI), blk * 0.5, inside and rng.randf() < 0.75)
				if not inside and rng.randf() < 0.3:
					lot.style = "garden"
				stream.add_lot(lot)


static func _roty(a: float) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, a), Vector3.ZERO)


## Sivri kemerli pencere (yüzey): koyu açıklık + üstte 45° dönük kare (sivri kemer izlenimi).
static func _ogive(k: MeshKit, t: Transform3D, w: float, h: float, frame: Color) -> void:
	k.face(t.translated_local(Vector3(0, 0.1, -0.01)), w + 0.3, h + 0.5, frame)
	k.face(t, w, h, Color("2a2228"))
	k.face(t.translated_local(Vector3(0, h * 0.5, 0)) * Transform3D(Basis(Vector3.BACK, PI * 0.25), Vector3.ZERO), w * 0.707, w * 0.707, Color("2a2228"))


## Galata'nın yapıları: Galata (İsa) Kulesi (1348; seyir galerisine konulur), kuleden kıyıya inen mazgallı Ceneviz
## surları ve burçları, kıyı surunda kapılar, Podesta Sarayı (Palazzo del Comune: revak, sivri pencereler,
## kırlangıç kuyruğu mazgallar, köşe çan kulesi, Cenova arması), San Paolo (Dominikenler; çan kuleli bazilika),
## San Francesco (revaklı avlu), rıhtım, iskeleler, Ceneviz gemileri ve sancaklar. Tek MeshKit örgüsü + çarpışma.
static func _galata(root: Node3D, night: Node3D) -> void:
	CityStream.materials()
	var k := MeshKit.new()
	var body := StaticBody3D.new()
	root.add_child(body)
	var stone := Color("b8aa8c")
	var dark := Color("2a2228")
	var marble := Color("e8e0d0")
	var addbox := func(xf: Transform3D, size: Vector3):
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = size
		cs.shape = bs
		cs.transform = xf
		body.add_child(cs)
	var addcyl := func(pos: Vector3, r: float, h: float):
		var cs := CollisionShape3D.new()
		var c := CylinderShape3D.new()
		c.radius = r
		c.height = h
		cs.shape = c
		cs.position = pos
		body.add_child(cs)
	# --- Galata Kulesi
	var t := _on(GALATA_TOWER)
	var tx := Transform3D(Basis(), t)
	k.cyl(tx.translated_local(Vector3(0, -4, 0)), 8.8, 5.0, stone.darkened(0.12), 28)
	k.cyl(tx, 8.2, 44.0, stone, 28, 7.4)
	for yy in [11.0, 22.0, 33.0]:
		k.cyl(tx.translated_local(Vector3(0, yy, 0)), 8.35 - yy * 0.018, 0.45, stone.darkened(0.15), 28)
	for i in 18:
		var ang := i * 1.1
		var yy := 5.0 + i * 2.0
		var r := 8.2 - yy * 0.018 + 0.03
		_ogive(k, tx.translated_local(Vector3(cos(ang) * r, yy, sin(ang) * r)) * _roty(PI * 0.5 - ang), 0.6, 1.3, stone.lightened(0.1))
	_ogive(k, tx.translated_local(Vector3(8.26, 1.7, 0)) * _roty(PI * 0.5), 1.8, 3.0, stone.lightened(0.15))
	for i in 28:
		var ang := TAU * i / 28.0
		k.box(tx.translated_local(Vector3(cos(ang) * 7.9, 43.4, sin(ang) * 7.9)) * _roty(-ang), Vector3(1.4, 1.4, 0.6), stone.darkened(0.08))
	k.cyl(tx.translated_local(Vector3(0, 44.0, 0)), 9.0, 0.6, stone.darkened(0.05), 28)
	# Galeri korkuluğu: bel hizasında (seyir için), aralıklı mazgal dişleri
	for i in 28:
		var ang := TAU * i / 28.0
		k.box(tx.translated_local(Vector3(cos(ang) * 8.75, 44.95, sin(ang) * 8.75)) * _roty(-ang), Vector3(0.5, 0.7, 2.0), stone)
		if i % 2 == 0:
			k.box(tx.translated_local(Vector3(cos(ang) * 8.75, 45.45, sin(ang) * 8.75)) * _roty(-ang), Vector3(0.5, 0.3, 0.9), stone)
	k.cyl(tx.translated_local(Vector3(0, 44.6, 0)), 6.0, 7.0, stone.lightened(0.05), 20)
	for i in 8:
		var ang := TAU * i / 8.0
		_ogive(k, tx.translated_local(Vector3(cos(ang) * 6.03, 47.8, sin(ang) * 6.03)) * _roty(PI * 0.5 - ang), 0.9, 1.8, marble)
	k.cyl(tx.translated_local(Vector3(0, 51.4, 0)), 6.9, 11.0, C_LEAD, 20, 0.15)
	k.box(tx.translated_local(Vector3(0, 63.4, 0)), Vector3(0.35, 2.6, 0.35), Color("d9b24a"))
	k.box(tx.translated_local(Vector3(0, 63.9, 0)), Vector3(1.5, 0.3, 0.3), Color("d9b24a"))
	addcyl.call(t + Vector3(0, 20.3, 0), 8.3, 48.6)
	addcyl.call(t + Vector3(0, 48.1, 0), 6.0, 7.0)
	addcyl.call(t + Vector3(0, 55.5, 0), 4.0, 8.0)
	# Kulede gece: galeride nöbetçi fenerleri
	for i in 4:
		var ang := TAU * i / 4.0 + 0.4
		Props.ball(night, 0.35, t + Vector3(cos(ang) * 8.4, 46.8, sin(ang) * 8.4), Color("ffc060"), Vector3.ONE, 8, 4.0)
	# --- Surlar ve burçlar
	var towers: Array = []
	for seg in [[GALATA_TOWER, GALATA_A], [GALATA_TOWER, GALATA_B], [GALATA_A, GALATA_B]]:
		var a: Vector3 = seg[0]
		var b: Vector3 = seg[1]
		var dir := Vector3(b.x - a.x, 0, b.z - a.z)
		var len_ := dir.length()
		dir /= len_
		var yaw := atan2(dir.x, dir.z)
		var s0 := 10.0 if a == GALATA_TOWER else 0.0
		var s := s0
		while s < len_:
			var q := a + dir * (s + 3.0)
			var g := maxf(ground_h(q.x, q.z), 0.9)
			var wx := Transform3D(Basis(Vector3.UP, yaw), Vector3(q.x, g + 3.0, q.z))
			k.box(wx, Vector3(2.6, 12.0, 6.2), stone.darkened(0.04))
			addbox.call(wx, Vector3(2.6, 12.0, 6.2))
			# Taş sıraları ve seyrek tuğla bantları, dipte yosun (iki yüzde)
			for sd in [-1, 1]:
				var fw := wx * _roty(sd * PI * 0.5)
				for row in [-4.5, -1.5, 1.5, 4.5]:
					k.face(fw.translated_local(Vector3(0, row, 1.31)), 6.2, 0.12, stone.darkened(0.2))
				k.face(fw.translated_local(Vector3(0, 3.0, 1.32)), 6.2, 0.45, Color("9a5a42"))
				k.face(fw.translated_local(Vector3(0, -5.3, 1.32)), 6.2, 1.2, stone.darkened(0.3))
			for m in 3:
				k.box(wx.translated_local(Vector3(0, 6.6, -2.0 + m * 2.0)), Vector3(2.6, 1.2, 1.0), stone)
			s += 6.0
		var ts := 36.0 if a == GALATA_TOWER else 0.0
		while ts <= len_ + 0.1:
			towers.append(a + dir * ts)
			ts += 36.0
	for tp in towers:
		var g := maxf(ground_h(tp.x, tp.z), 0.9)
		var bx := Transform3D(Basis(), Vector3(tp.x, g + 5.0, tp.z))
		k.box(bx, Vector3(7.0, 18.0, 7.0), stone.darkened(0.08))
		addbox.call(bx, Vector3(7.0, 18.0, 7.0))
		for i in 4:
			for sx in [-1, 1]:
				var off := Vector3(sx * 2.6, 9.7, 3.3) if i < 2 else Vector3(3.3, 9.7, sx * 2.6)
				if i % 2 == 1:
					off = Vector3(-off.x, off.y, -off.z)
				k.box(bx.translated_local(off), Vector3(1.1, 1.4, 1.1), stone)
		# Cenova sancağı: beyaz zemin, kırmızı haç
		var fp := bx.translated_local(Vector3(0, 9.0, 0))
		k.box(fp.translated_local(Vector3(0, 3.0, 0)), Vector3(0.15, 6.0, 0.15), Color("4a3a2a"))
		var fl := fp.translated_local(Vector3(0, 5.2, 1.3))
		k.box(fl, Vector3(0.05, 1.6, 2.4), Color("f2efe6"))
		k.box(fl.translated_local(Vector3(0.03, 0, 0)), Vector3(0.05, 1.6, 0.4), Color("c8262f"))
		k.box(fl.translated_local(Vector3(0.03, 0, 0)), Vector3(0.05, 0.35, 2.4), Color("c8262f"))
	# Kıyı surunda kapılar (Haliç'e bakan yüz)
	for gz in [322.0, 388.0, 452.0]:
		var gx := Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(GALATA_SHORE + 1.35, 0.9, gz))
		k.face(gx.translated_local(Vector3(0, 2.0, 0.02)), 3.2, 4.0, dark)
		k.cyl(gx.translated_local(Vector3(0, 4.0, 0.02)) * Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3.ZERO), 1.6, 0.04, dark, 12)
		k.cyl(gx.translated_local(Vector3(0, 4.0, 0.0)) * Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3.ZERO), 2.1, 0.04, marble, 12)
	# --- Podesta Sarayı (kıyıya bakar)
	var pp := _on(PODESTA)
	var px := Transform3D(Basis(Vector3.UP, PI * 0.5), pp)
	k.box(px.translated_local(Vector3(0, 7.0, 0)), Vector3(26, 18, 16), Color("c8a888"))
	addbox.call(px.translated_local(Vector3(0, 7.0, 0)), Vector3(26, 18, 16))
	for i in 5:
		var ax := -10.4 + i * 5.2
		k.face(px.translated_local(Vector3(ax, 1.7, 8.02)), 3.2, 3.4, dark)
		k.cyl(px.translated_local(Vector3(ax, 3.4, 8.02)) * Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3.ZERO), 1.6, 0.03, dark, 12)
		k.cyl(px.translated_local(Vector3(ax, 3.4, 8.0)) * Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3.ZERO), 2.15, 0.03, marble, 12)
	for f in 2:
		k.box(px.translated_local(Vector3(0, 5.6 + f * 5.0, 8.05)), Vector3(26.2, 0.35, 0.3), marble)
		for i in 7:
			_ogive(k, px.translated_local(Vector3(-10.8 + i * 3.6, 7.8 + f * 5.0, 8.03)), 1.1, 2.2, marble)
	# Cenova arması (beyaz kalkan, kırmızı haç) cephenin ortasında
	var arms := px.translated_local(Vector3(0, 14.6, 8.04))
	k.face(arms, 2.0, 2.4, Color("f2efe6"))
	k.face(arms.translated_local(Vector3(0, 0, 0.01)), 0.45, 2.4, Color("c8262f"))
	k.face(arms.translated_local(Vector3(0, 0.1, 0.01)), 2.0, 0.45, Color("c8262f"))
	var m2 := 0.0
	while m2 < 26.0:
		for sz in [-1, 1]:
			var mz := px.translated_local(Vector3(-12.6 + m2, 16.7, sz * 7.7))
			k.box(mz.translated_local(Vector3(-0.22, 0, 0)), Vector3(0.35, 1.4, 0.5), Color("c8a888"))
			k.box(mz.translated_local(Vector3(0.22, 0, 0)), Vector3(0.35, 1.4, 0.5), Color("c8a888"))
			k.box(mz.translated_local(Vector3(0, -0.45, 0)), Vector3(0.8, 0.5, 0.5), Color("c8a888"))
		m2 += 1.6
	var bt := px.translated_local(Vector3(11.0, 0, -5.0))
	k.box(bt.translated_local(Vector3(0, 12.0, 0)), Vector3(5, 28, 5), Color("c0a080"))
	addbox.call(bt.translated_local(Vector3(0, 12.0, 0)), Vector3(5, 28, 5))
	for i in 4:
		var bf := bt.translated_local(Vector3(0, 23.5, 0)) * _roty(PI * 0.5 * i)
		k.face(bf.translated_local(Vector3(0, 0, 2.52)), 1.6, 2.6, dark)
	k.hip(bt.translated_local(Vector3(0, 26.0, 0)), Vector3(5.6, 4.0, 5.6), Color("a84a32"))
	# --- San Paolo (Dominikenler): üç nefli bazilika, sivri pencereler, gül pencere, çan kulesi
	var sp := _on(SAN_PAOLO)
	var sx_ := Transform3D(Basis(Vector3.UP, PI * 0.5), sp)
	k.box(sx_.translated_local(Vector3(0, 5.5, 0)), Vector3(12, 15, 36), Color("c8b8a0"))
	addbox.call(sx_.translated_local(Vector3(0, 5.5, 0)), Vector3(12, 15, 36))
	k.gable(sx_.translated_local(Vector3(0, 13.0, 0)) * _roty(PI * 0.5), Vector3(37, 5.0, 13), Color("a84a32"))
	for sgn in [-1, 1]:
		k.box(sx_.translated_local(Vector3(sgn * 8.5, 3.0, 0)), Vector3(5, 10, 34), Color("c0b098"))
		addbox.call(sx_.translated_local(Vector3(sgn * 8.5, 3.0, 0)), Vector3(5, 10, 34))
		k.box(sx_.translated_local(Vector3(sgn * 8.5, 8.2, 0)) * Transform3D(Basis(Vector3.BACK, sgn * -0.35), Vector3.ZERO), Vector3(5.6, 0.3, 34.5), Color("a84a32"))
		for i in 6:
			_ogive(k, sx_.translated_local(Vector3(sgn * 6.03, 10.0, -14 + i * 5.6)) * _roty(sgn * PI * 0.5), 0.9, 2.2, marble)
			_ogive(k, sx_.translated_local(Vector3(sgn * 11.03, 3.5, -14 + i * 5.6)) * _roty(sgn * PI * 0.5), 0.9, 2.0, marble)
	k.cyl(sx_.translated_local(Vector3(0, 10.5, 18.02)) * Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3.ZERO), 2.0, 0.05, marble, 16)
	k.cyl(sx_.translated_local(Vector3(0, 10.5, 18.05)) * Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3.ZERO), 1.6, 0.05, Color("3a3050"), 16)
	_ogive(k, sx_.translated_local(Vector3(0, 2.0, 18.03)), 2.2, 3.6, marble)
	k.cyl(sx_.translated_local(Vector3(0, -2.0, -18.0)), 5.8, 13.0, Color("c0b098"), 16)
	k.dome(sx_.translated_local(Vector3(0, 11.0, -18.0)), 5.9, Color("a84a32"), 0.6, 16, 3)
	var cp := sx_.translated_local(Vector3(-9.5, 0, -12.0))
	k.box(cp.translated_local(Vector3(0, 14.0, 0)), Vector3(6, 32, 6), Color("b8a888"))
	addbox.call(cp.translated_local(Vector3(0, 14.0, 0)), Vector3(6, 32, 6))
	for i in 4:
		var bf := cp.translated_local(Vector3(0, 26.0, 0)) * _roty(PI * 0.5 * i)
		for sx in [-1, 1]:
			_ogive(k, bf.translated_local(Vector3(sx * 1.2, 0, 3.02)), 0.9, 2.6, marble)
	k.hip(cp.translated_local(Vector3(0, 30.0, 0)), Vector3(6.6, 6.0, 6.6), Color("a84a32"))
	# --- San Francesco: tek nef, cephe üstünde çan duvarı, yanında revaklı avlu (klostr)
	var sf := _on(SAN_FRANCESCO)
	var fx := Transform3D(Basis(Vector3.UP, PI * 0.5), sf)
	k.box(fx.translated_local(Vector3(0, 5.0, 0)), Vector3(12, 14, 30), Color("d0c0a4"))
	addbox.call(fx.translated_local(Vector3(0, 5.0, 0)), Vector3(12, 14, 30))
	k.gable(fx.translated_local(Vector3(0, 12.0, 0)) * _roty(PI * 0.5), Vector3(31, 4.5, 13), Color("b5563a"))
	k.box(fx.translated_local(Vector3(0, 17.0, 15.0)), Vector3(4, 4, 0.8), Color("d0c0a4"))
	k.face(fx.translated_local(Vector3(0, 17.0, 15.42)), 1.2, 1.8, dark)
	_ogive(k, fx.translated_local(Vector3(0, 2.0, 15.03)), 2.0, 3.2, marble)
	k.cyl(fx.translated_local(Vector3(0, 9.5, 15.02)) * Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3.ZERO), 1.6, 0.05, Color("3a3050"), 16)
	var cl := fx.translated_local(Vector3(14.0, 0, 0))
	k.box(cl.translated_local(Vector3(0, 0.05, 0)), Vector3(12, 0.1, 16), Color("5a7a3a"))
	for i in 5:
		for sz in [-1, 1]:
			k.cyl(cl.translated_local(Vector3(-5.0 + i * 2.5, 0, sz * 7.0)), 0.25, 3.2, marble, 8)
			k.cyl(cl.translated_local(Vector3(sz * 5.5, 0, -5.6 + i * 2.8)), 0.25, 3.2, marble, 8)
	for sz in [-1, 1]:
		k.box(cl.translated_local(Vector3(0, 3.5, sz * 7.8)), Vector3(12, 0.6, 2.6), Color("a84a32"))
		k.box(cl.translated_local(Vector3(sz * 6.3, 3.5, 0)), Vector3(2.6, 0.6, 16), Color("a84a32"))
	k.cyl(cl, 0.9, 0.9, marble, 12)
	# --- Rıhtım ve iskeleler (kıyı surunun önünde)
	var qx := Transform3D(Basis(), Vector3(GALATA_SHORE + 7.0, -0.6, (GALATA_A.z + GALATA_B.z) * 0.5))
	k.box(qx, Vector3(12, 3.0, GALATA_B.z - GALATA_A.z), stone.darkened(0.15))
	addbox.call(qx, Vector3(12, 3.0, GALATA_B.z - GALATA_A.z))
	for pz in [300.0, 344.0, 404.0, 440.0, 476.0]:
		var px2 := Transform3D(Basis(), Vector3(GALATA_SHORE + 23.0, 0.75, pz))
		k.box(px2, Vector3(20, 0.3, 3.0), Color("6a4a2a"))
		addbox.call(px2, Vector3(20, 0.3, 3.0))
		for i in 4:
			for sz in [-1, 1]:
				k.cyl(Transform3D(Basis(), Vector3(GALATA_SHORE + 15.0 + i * 5.0, -2.0, pz + sz * 1.4)), 0.18, 3.0, Color("4a3222"), 6)
	# Rıhtımda yük: fıçılar, balyalar, sandıklar
	var rng := RandomNumberGenerator.new()
	rng.seed = 1261
	for i in 26:
		var bz := rng.randf_range(GALATA_A.z + 6.0, GALATA_B.z - 6.0)
		var bxp := Transform3D(Basis(Vector3.UP, rng.randf() * TAU), Vector3(GALATA_SHORE + rng.randf_range(3.0, 11.0), 0.9, bz))
		if rng.randf() < 0.5:
			k.cyl(bxp, 0.4, 1.0, Color("6a4a2a"), 8)
		else:
			k.box(bxp.translated_local(Vector3(0, 0.45, 0)), Vector3(1.1, 0.9, 0.8), [Color("c8b088"), Color("8a6a44"), Color("d8ccb0")][i % 3])
	var mi := MeshInstance3D.new()
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, k.arrays())
	am.surface_set_material(0, CityStream._mat)
	mi.mesh = am
	mi.name = "Galata"
	root.add_child(mi)
	# Ceneviz gemileri (koka: yüksek borda, kıç ve baş kasarası, tek direk, kırmızı haçlı kare yelken) ve kayıklar
	for i in 5:
		_cog(root, Vector3(GALATA_SHORE + rng.randf_range(38.0, 70.0), 0.15, GALATA_A.z + 20.0 + i * 40.0 + rng.randf_range(-6.0, 6.0)), rng.randf_range(-0.3, 0.3))
	for i in 8:
		var bp := Vector3(GALATA_SHORE + rng.randf_range(14.0, 32.0), 0.15, rng.randf_range(GALATA_A.z, GALATA_B.z))
		var boat := Node3D.new()
		boat.position = bp
		boat.rotation.y = rng.randf() * TAU
		root.add_child(boat)
		Props.box(boat, Vector3(1.4, 0.5, 4.2), Vector3(0, 0.2, 0), Color("5a3a22"))
		Props.box(boat, Vector3(1.1, 0.1, 3.8), Vector3(0, 0.46, 0), Color("8a6a44"))


static func _cog(root: Node3D, p: Vector3, yaw: float) -> void:
	var n := Node3D.new()
	n.position = p
	n.rotation.y = yaw
	root.add_child(n)
	Props.box(n, Vector3(6.0, 3.2, 20), Vector3(0, 1.2, 0), Color("4a3222"))
	Props.box(n, Vector3(5.6, 0.3, 19.6), Vector3(0, 2.8, 0), Color("8a6a44"))
	Props.box(n, Vector3(6.2, 2.4, 5.0), Vector3(0, 3.8, -8.0), Color("5a3a22"))
	Props.box(n, Vector3(5.4, 1.6, 3.4), Vector3(0, 3.4, 8.6), Color("5a3a22"))
	Props.cyl(n, 0.3, 18.0, Vector3(0, 11.0, 0.5), Color("5a4028"), Vector3.ZERO, 6)
	Props.box(n, Vector3(9.0, 0.25, 0.25), Vector3(0, 17.0, 0.5), Color("5a4028"))
	Props.box(n, Vector3(8.4, 7.0, 0.1), Vector3(0, 13.4, 0.7), Color("f2efe6"))
	Props.box(n, Vector3(1.2, 7.0, 0.12), Vector3(0, 13.4, 0.72), Color("c8262f"))
	Props.box(n, Vector3(8.4, 1.2, 0.12), Vector3(0, 14.2, 0.72), Color("c8262f"))
	Props.box(n, Vector3(0.05, 1.0, 1.6), Vector3(0, 20.6, 0.5), Color("f2efe6"))


## Galata'nın insanları (tanıklar): rıhtımda tüccarlar ve hamallar, Podesta'nın önünde muhafızlar ve bir noter.
static func _galata_people(root: Node3D) -> void:
	var specs := [
		[Vector3(GALATA_SHORE + 5.0, 0.9, 330.0), {"coat": Color("6a1e22"), "robe": Color("6a1e22"), "hat": "hood", "beard": true, "skin": Color("e0b08a")}],
		[Vector3(GALATA_SHORE + 8.0, 0.9, 336.0), {"coat": Color("8a7a5a"), "pants": Color("4a3a2a"), "mustache": true, "skin": Color("c89070")}],
		[Vector3(GALATA_SHORE + 6.0, 0.9, 396.0), {"coat": Color("1e1e28"), "robe": Color("1e1e28"), "hat": "hood", "skin": Color("e8b894")}],
		[Vector3(GALATA_SHORE + 9.0, 0.9, 402.0), {"coat": Color("a86a3a"), "pants": Color("5a4028"), "beard": true, "skin": Color("d9a07a")}],
		[Vector3(GALATA_SHORE + 4.0, 0.9, 460.0), {"coat": Color("3a4a6a"), "robe": Color("3a4a6a"), "hat": "hood", "beard": true, "skin": Color("e0b08a")}],
		[PODESTA + Vector3(16.0, 0, -4.0), {"coat": Color("c8262f"), "pants": Color("f2efe6"), "hat": "helm", "mustache": true, "skin": Color("d9a07a")}],
		[PODESTA + Vector3(16.0, 0, 4.0), {"coat": Color("c8262f"), "pants": Color("f2efe6"), "hat": "helm", "beard": true, "skin": Color("c89070")}],
		[PODESTA + Vector3(19.0, 0, 0.0), {"coat": Color("2a2a30"), "robe": Color("2a2a30"), "beard": true, "hair": Color("8a8a8a"), "skin": Color("e0b08a")}],
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = 1273
	for s in specs:
		var pr := Person.new(s[1])
		var p: Vector3 = s[0]
		if p.x < GALATA_SHORE:
			p.y = ground_h(p.x, p.z)
		pr.position = p
		pr.rotation.y = rng.randf() * TAU
		root.add_child(pr)


## Uçuşan formların yerleri (CityPanorama düğümünün yerel koordinatı): kubbe, sütun ve kule tepeleri,
## hepsi yalnız uçarak (ya da konarak) ulaşılır. [[numara, konum], ...]
static func form_spots() -> Array:
	return [
		[1, _on(AYA) + Vector3(6.0, 52.4, 0)],
		[2, _on(COLUMN) + Vector3(0, 39.0, 0)],
		[3, _on(GALATA_TOWER) + Vector3(7.6, 45.8, 0)],
		[4, _on(HIPPO) + Vector3(0, 26.5, -18.0)],
		[5, Vector3(-10.0, 27.2, AQUEDUCT_Z)],
		[6, _on(APOSTLES) + Vector3(0, 28.0, 0)],
		[7, _on(BLACHERNAE) + Vector3(24.0, 37.0, -2.0)],
		[8, Vector3(HORN_X - 4.0, 17.2, CHAIN_Z)],
		[9, _on(SAN_PAOLO) + Vector3(-12.0, 37.5, 9.5)],
		[10, Vector3(150.0, 23.8, 930.0)],
		[11, Vector3(0, 14.4, WALL_Z + 9.0)],
	]


## Galata'daki formlar (ByzCity'nin GalataView düğümü için)
static func galata_form_spots() -> Array:
	return [[3, _on(GALATA_TOWER) + Vector3(7.6, 45.8, 0)], [9, _on(SAN_PAOLO) + Vector3(-12.0, 37.5, 9.5)]]


## Konma noktaları (yan görev "perch"): [[id, konum, yarıçap], ...]
static func perch_spots() -> Array:
	return [
		["aya", _on(AYA) + Vector3(0, 51.4, 0), 8.0],
		["galata", _on(GALATA_TOWER) + Vector3(0, 44.6, 0), 9.5],
		["column", _on(COLUMN) + Vector3(0, 37.6, 0), 3.5],
	]


## Kuleleri, kubbeleri çarpışmalı yapar: Nihat üstlerine konabilir.
static func _collide(root: Node3D, shape: Shape3D, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = shape
	body.add_child(cs)
	body.position = pos
	root.add_child(body)


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


## Boğaz: şehrin burnunun önünde Osmanlı donanması (kırmızı sancaklı kadırgalar), karşıda Asya kıyısı.
static func _bosphorus(root: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1452
	for i in 14:
		_ship(root, Vector3(rng.randf_range(-320.0, 120.0), 0.12, rng.randf_range(TIP_Z + 90.0, TIP_Z + 260.0)), rng.randf() * TAU, Color("f0e8d8"), Color("c8262f"))
	# Asya kıyısı ve köyleri OuterWorld'de; Boğaz ağzında Damalis kulesi (sonraki Kız Kulesi): kayalık adacık
	var kz := Vector3(150.0, 0.15, 930.0)
	var rock := Props.ball(root, 11.0, kz, Color("7a7266"), Vector3(1.3, 0.35, 1.0), 12)
	rock.material_override = Props.mat(Color("7a7266"), 0.0, false, "", false)
	Props.set_pattern(Props.cyl(root, 3.2, 14.0, kz + Vector3(0, 9.0, 0), Color.WHITE, Vector3.ZERO, 12), Color("c8b898"), "ashlar_far")
	Props.cyl(root, 3.6, 5.0, kz + Vector3(0, 18.5, 0), C_LEAD, Vector3.ZERO, 12, 0.1)
	Props.box(root, Vector3(8, 5, 6), kz + Vector3(4.5, 4.0, 0), Color("c8b898"))
	_collide(root, _cylshape(3.3, 21.0), kz + Vector3(0, 10.5, 0))


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
