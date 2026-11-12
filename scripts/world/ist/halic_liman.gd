class_name IstHalicLiman
extends RefCounted
## Limanlar ve kıyı işleri: Neorion (kumlanmış eski liman), ticaret iskeleleri (skala) + ahşap vinçler + demirli nao,
## balık pazarı. Yerel: merkez kıyı hattının ortası, deniz -z, zemin y=0, rıhtım üstü y=0,4.

const K = preload("res://scripts/world/ist/halic_kit.gd")
const QY := 0.4


static func _boat(p: Node3D, pos: Vector3, yaw: float, sc: float, hull_col: Color) -> void:
	var boat := Node3D.new()
	boat.position = pos
	boat.rotation.y = yaw
	boat.scale = Vector3.ONE * sc
	p.add_child(boat)
	boat.add_child(LowPoly.hull([
		{"z": -2.8, "w": 0.05, "top": 0.75, "bottom": 0.35},
		{"z": -1.8, "w": 0.6, "top": 0.55, "bottom": -0.05},
		{"z": 0.5, "w": 0.75, "top": 0.5, "bottom": -0.1},
		{"z": 2.0, "w": 0.6, "top": 0.55, "bottom": -0.05},
		{"z": 2.6, "w": 0.35, "top": 0.7, "bottom": 0.2},
	], hull_col, Color("3a5a8a"), 0.4))
	Props.box(boat, Vector3(1.1, 0.06, 0.3), Vector3(0, 0.4, 0.3), Color("7a5a38"))
	Props.box(boat, Vector3(1.0, 0.06, 0.3), Vector3(0, 0.4, -0.9), Color("7a5a38"))
	# katı gövde: suya batmış, rıhtıma yaslı kayık (kutu hacmi; üstü 0,5*sc)
	var sb := Props.solid(p, Vector3(1.4 * sc, 0.62 * sc, 5.0 * sc), pos + Vector3(0, 0.2 * sc, 0), hull_col, Vector3(0, rad_to_deg(yaw), 0))
	sb.visible = false


# =========================== İSKELE ===========================
static func build_iskele(host: Node3D, k: float, lod: int) -> void:
	var root := Node3D.new()
	root.name = "HalicIskele"
	host.add_child(root)
	var span := 32.0 + 24.0 * clampf(k, 0.3, 1.0)
	var qz1 := -2.0
	var qz0 := -8.0
	if lod >= 2:
		K.slab(root, -span, span, qz0, qz1, -1.6, QY, Color("a89a80"))
		K.slab(root, -3, 3, qz0 - 20, qz0, 0.0, 0.4, Color("7a5a38"))
		return
	K.slab(root, -span, span, qz0, qz1, -1.6, QY, Color("a89a80"), "flagstone").name = "Rihtim"
	K.sea(root, -span - 20.0, span + 20.0, qz0 - 48.0, qz0, 1.6)
	# Beş iskele (skala): dikdörtgen ahşap, suya 14-20 m
	var jx := [-span * 0.8, -span * 0.4, 0.0, span * 0.4, span * 0.8]
	var jl := [14.0, 20.0, 18.0, 15.0, 12.0]
	for i in 5:
		K.jetty(root, qz0, qz0 - jl[i], jx[i], QY, 2.4)
	# Vinçler: iki ahşap çıkrıklı vinç (insan gücüyle), rıhtım ucunda
	_crane(root, Vector3(-span * 0.6, QY, qz0 + 1.8))
	_crane(root, Vector3(span * 0.6, QY, qz0 + 1.8))
	# Yığınlar
	K.barrel_stack(root, Vector3(-span * 0.25, QY, qz0 + 2.0), 3, 2, 2)
	K.bale_stack(root, Vector3(span * 0.22, QY, qz0 + 2.0), 3, 2, 2)
	K.barrel_stack(root, Vector3(span * 0.95, QY, qz0 + 2.0), 2, 2, 1)
	K.bale_stack(root, Vector3(-span * 0.92, QY, qz0 + 2.0), 2, 1, 3, Color("c9b68a"))
	K.crate_steps(root, Vector3(-span * 0.1, QY, qz1 - 0.6), Vector3(0, 0, -1), 3)
	# Demirli nao (iskele 1'in sağında): gövde, direk, seren, toplanmış yelken, halat
	_ship(root, Vector3(jx[1] + 6.0 + 1.2, 0.0, qz0 - 11.0), jx[1] + 1.2)
	# Rıhtıma ve iskelelere şehir tarafı: taş merdiven çıkışı (rıhtım y=0.4 -> zemin 0 -> 2 basamak 0,2)
	# Düşük cephe: rıhtımın şehir yüzü 0,4 m basamak
	K.stair(root, Vector3(0, 0, qz1 + 0.34 * 2), Vector3(0, 0, -1), QY, 3.0, Color("b0a080"))


static func _crane(p: Node3D, pos: Vector3) -> void:
	# Taban kasası + iki dikme + çıkrık tekerleği (insan basar) + yatay kiriş; iki katı dikme arası ≥ 2,4 m
	var base := K.blk(p, Vector3(5.0, 0.6, 4.0), pos + Vector3(0, 0.3, 0), Color("7a5a38"), "wood")
	base.name = "VincTaban"
	var by := pos.y + 0.6
	for s in [-1.0, 1.0]:
		K.blk(p, Vector3(0.4, 6.0, 0.4), pos + Vector3(s * 1.8, by - pos.y + 3.0, -1.2), K.TIMBER_D, "wood")
		K.blk(p, Vector3(0.4, 6.0, 0.4), pos + Vector3(s * 1.8, by - pos.y + 3.0, 1.2), K.TIMBER_D, "wood")
	# Çıkrık tekerleği (dikey halka, yarıçap 2.2, kollar) iki dikme arasında, yarısı yere gömülü değil: zeminden 0.7 üstte
	var wheel_c := pos + Vector3(0, by - pos.y + 2.9, 0)
	Props.ring(p, 1.9, 2.2, wheel_c, K.TIMBER, Vector3(0, 90, 0))
	for a in 6:
		Props.box(p, Vector3(0.1, 0.1, 4.2), wheel_c, K.TIMBER, Vector3(a * 30, 0, 0)).rotation_degrees = Vector3(a * 30, 90, 0)
	Props.cyl(p, 0.18, 3.6, wheel_c, K.TIMBER_D, Vector3(0, 0, 90), 8)
	# Kol (jib): kuleden denize taşan ahşap kol, ucunda makara ve sarkan halat+kanca
	var jib_start := pos + Vector3(0, by - pos.y + 6.2, 0)
	Props.box(p, Vector3(0.3, 0.3, 7.5), jib_start + Vector3(0, 0, -2.8), K.TIMBER_D, Vector3(-4, 0, 0))
	Props.box(p, Vector3(0.18, 0.18, 4.0), jib_start + Vector3(0, -1.6, -1.0), K.TIMBER, Vector3(-38, 0, 0))
	Props.box(p, Vector3(0.03, 5.6, 0.03), jib_start + Vector3(0, -2.8, -6.2), Color("c9b68a"))
	Props.cyl(p, 0.2, 0.15, jib_start + Vector3(0, 0.0, -6.2), K.IRON, Vector3(0, 0, 90), 8)


static func _ship(p: Node3D, pos: Vector3, plank_x: float) -> void:
	var ship := Node3D.new()
	ship.position = pos
	ship.rotation.y = PI * 0.5
	ship.scale = Vector3.ONE * 3.4
	p.add_child(ship)
	ship.add_child(LowPoly.hull([
		{"z": -2.9, "w": 0.2, "top": 1.1, "bottom": 0.2},
		{"z": -2.0, "w": 0.7, "top": 0.75, "bottom": -0.1},
		{"z": 0.0, "w": 0.85, "top": 0.6, "bottom": -0.25},
		{"z": 2.0, "w": 0.7, "top": 0.7, "bottom": -0.1},
		{"z": 2.8, "w": 0.4, "top": 0.95, "bottom": 0.15},
	], Color("5a3a22"), Color("c8a850"), 0.45))
	# Güverte tahtaları, kıç kasarası (kale), pruva kasarası
	Props.box(ship, Vector3(1.4, 0.04, 4.8), Vector3(0, 0.6, 0), Color("8a6a40"))
	Props.box(ship, Vector3(1.2, 0.5, 1.1), Vector3(0, 0.88, 1.9), Color("6a4a2c"))
	Props.box(ship, Vector3(1.0, 0.4, 0.9), Vector3(0, 0.85, -2.1), Color("6a4a2c"))
	# Direkler (ana + mizan), seren, toplanmış yelken
	Props.cyl(ship, 0.04, 3.4, Vector3(0, 2.3, -0.3), K.TIMBER_D, Vector3.ZERO, 6)
	Props.cyl(ship, 0.03, 2.2, Vector3(0, 1.7, 1.7), K.TIMBER_D, Vector3.ZERO, 6)
	Props.cyl(ship, 0.025, 2.2, Vector3(0, 3.4, -0.3), K.TIMBER, Vector3(0, 0, 90), 6)
	Props.cyl(ship, 0.06, 1.9, Vector3(0, 3.28, -0.3), Color("e8e0c8"), Vector3(0, 0, 90), 8)
	Props.box(ship, Vector3(0.03, 0.5, 0.01), Vector3(0, 3.7, -0.3), Color("a82a2a"))
	# Halat (sancaktan pruvaya)
	Props.box(ship, Vector3(0.012, 0.012, 3.2), Vector3(0, 2.0, -1.8), Color("3a2a1a"), Vector3(-36, 0, 0))
	# Katı: gövde hacmi (kutu), güverte 1,56 m
	var deck_top := 0.6 * 3.4
	var hull_block := Props.solid(p, Vector3(16.0, deck_top + 0.5, 4.2), pos + Vector3(0, (deck_top - 0.5) * 0.5, 0), Color("5a3a22"))
	hull_block.visible = false
	# Mizen kasarası ve pruva kasarası güverteden yükselir: üst yüzler katı kutu
	Props.solid(p, Vector3(3.6, 0.7, 3.0), pos + Vector3(0, deck_top + 0.4, 0) + Vector3(5.5, 0, 0), Color("6a4a2c")).visible = true
	# Rampa (iskele -> güverte): 1,6 m genişlik
	var a := Vector3(plank_x, QY, pos.z + 4.0)
	var b := Vector3(pos.x - 4.0, deck_top, pos.z + 2.1)
	b.x = a.x
	Props.ramp(p, a, Vector3(a.x, deck_top, pos.z + 2.2), 1.6, Color("7a5a38"))


static func perches_iskele(k: float) -> Array:
	var span := 32.0 + 24.0 * clampf(k, 0.3, 1.0)
	return [Vector3(-span * 0.6, 0.6 + 6.0 + 0.2, -8.0 + 1.8), Vector3(span * 0.6, 0.6 + 6.0 + 0.2, -8.0 + 1.8)]


static func climbs_iskele(k: float) -> Array:
	var span := 32.0 + 24.0 * clampf(k, 0.3, 1.0)
	return [[Vector3(-span * 0.1, 0, -1.0), Vector3(-span * 0.1, QY + 1.5, -3.5), "sandik"],
		[Vector3(-span * 0.4, QY, -8.5), Vector3(-span * 0.4, QY + 1.2, -16.0), "basamak"]]


# =========================== NEORİON ===========================
static func build_neorion(host: Node3D, k: float, lod: int) -> void:
	var root := Node3D.new()
	root.name = "HalicNeorion"
	host.add_child(root)
	var w := 22.0 + 18.0 * clampf(k, 0.3, 1.0)
	var d := 20.0 + 12.0 * clampf(k, 0.3, 1.0)
	# Limanın çevresi: taş rıhtım halkası (3 m genişlik, 0,4 yüksek); havuz içi: yarısı kumla dolmuş (zeminle aynı), yarısı sığ su
	if lod >= 2:
		K.slab(root, -w, w, -d, d, -1.0, 0.4, Color("a89a80"))
		return
	var ring_w := 3.0
	# kuzey (deniz) ve iki yan rıhtım; güney şehir tarafı açık
	K.slab(root, -w - ring_w, w + ring_w, -d - ring_w, -d, -1.6, QY, Color("a89a80"), "flagstone").name = "RihtimKuzey"
	K.slab(root, -w - ring_w, -w, -d, d, -1.6, QY, Color("a89a80"), "flagstone").name = "RihtimBati"
	K.slab(root, w, w + ring_w, -d, d, -1.6, QY, Color("a89a80"), "flagstone").name = "RihtimDogu"
	# Havuz tabanı: batı yarı kumla dolu (y -0,05, yürünür), doğu yarı sığ su (-0,9)
	K.slab(root, -w, 0.0, -d, d, -1.6, -0.02, Color("c9b88a"), "rubble").name = "KumBati"
	K.slab(root, 0.0, w, -d, d, -1.7, -0.9, Color("6a6a5a"), "cobble").name = "TabanDogu"
	var wm := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(w, d * 2.0)
	wm.mesh = pm
	wm.material_override = Props.mat(Color(0.25, 0.45, 0.55, 0.78), 0.0, true, "", false)
	wm.position = Vector3(w * 0.5, -0.3, 0)
	root.add_child(wm)
	# Denize açılan ağız: kuzeyde 10 m; deniz
	K.sea(root, -w - ring_w, w + ring_w, -d - ring_w - 40.0, -d - ring_w, 1.6)
	# Rıhtım uçlarından basamaklar: şehir yüzünden sığ kumsala çıkış
	# Kum üzerinde çekilmiş kayıklar ve yarı gömülü bir eski teknenin iskeleti
	_boat(root, Vector3(-w * 0.55, 0.0, -d * 0.35), 0.6, 1.2, Color("5a3a22"))
	_boat(root, Vector3(-w * 0.25, 0.0, d * 0.2), 2.4, 1.1, Color("6a4a2c"))
	_boat(root, Vector3(w * 0.45, -0.2, -d * 0.3), 1.6, 1.4, Color("5a3a22"))
	# Eski tonoz kalıntısı: kuzey rıhtımda kırık kemerli tersane girişleri (3 kemer, alçak katı duvar)
	for i in 3:
		var ax := -w * 0.7 + i * w * 0.7
		K.blk(root, Vector3(1.2, 4.0 - i * 0.6, 3.0), Vector3(ax - 2.0, 2.0 - i * 0.3, -d - ring_w * 0.5), Color("b8a888"), "ashlar").name = "TersaneAyak"
		K.blk(root, Vector3(1.2, 4.0 - i * 0.6, 3.0), Vector3(ax + 2.0, 2.0 - i * 0.3, -d - ring_w * 0.5), Color("b8a888"), "ashlar").name = "TersaneAyak"
		Props.box(root, Vector3(4.8, 0.5, 3.1), Vector3(ax, 3.8 - i * 0.6 + 0.0, -d - ring_w * 0.5), Color("a99a7c"))
	# Moloz ve ot
	for j in 14:
		var rx := -w + 1.0 + fmod(j * 5.3, w - 2.0)
		Props.box(root, Vector3(0.5, 0.2, 0.4), Vector3(rx, 0.04, -d + 2.0 + fmod(j * 3.1, d * 1.6)), Color("857a60"), Vector3(0, j * 41, 0))
	# Bağlama babaları
	var xf: Array = []
	for i in 8:
		xf.append(Transform3D(Basis.IDENTITY, Vector3(-w + i * (2.0 * w) / 7.0, QY + 0.22, -d - 0.4)))
	K.multi(root, K.cyl_mesh(0.12, 0.44, 6), xf, K.TIMBER_D, "wood")


static func perches_neorion(k: float) -> Array:
	var w := 22.0 + 18.0 * clampf(k, 0.3, 1.0)
	var d := 20.0 + 12.0 * clampf(k, 0.3, 1.0)
	return [Vector3(-w + 1.0, 4.0 + 0.1, -d - 1.5)]


static func climbs_neorion(k: float) -> Array:
	var w := 22.0 + 18.0 * clampf(k, 0.3, 1.0)
	var d := 20.0 + 12.0 * clampf(k, 0.3, 1.0)
	return [[Vector3(-w - 4.0, QY, d * 0.5), Vector3(-w + 1.0, QY, d * 0.5), "basamak"]]


# =========================== BALIK PAZARI ===========================
static func build_balik(host: Node3D, k: float, lod: int) -> void:
	var root := Node3D.new()
	root.name = "HalicBalik"
	host.add_child(root)
	var w := 16.0 + 6.0 * clampf(k, 0.3, 1.0)
	if lod >= 2:
		K.slab(root, -w, w, 0.0, 14.0, 0, 3.0, Color("b08a5a"))
		return
	# Islak taş meydan
	K.slab(root, -w - 2.0, w + 2.0, -1.0, 15.0, -0.02, 0.06, Color("8f8e84"), "flagstone").name = "PazarZemin"
	var tcols := [Color("a8402a"), Color("3a5a8a"), Color("c8a030"), Color("5a7a3a"), Color("c8a0a0")]
	for i in 6:
		var sx := -w + 3.0 + (i % 3) * (w * 2.0 - 6.0) / 2.0
		var sz := 3.0 + (i / 3) * 7.0
		_stall(root, Vector3(sx, 0.06, sz), tcols[i % 5])
	# Merkezde taş balık havuzu/tezgâhı (sağlam, tırmanılır 0,9 yüksek)
	var tank := K.blk(root, Vector3(4.0, 0.9, 2.0), Vector3(0, 0.51, 7.0), Color("b4a384"), "ashlar")
	tank.name = "BalikTezgah"
	for j in 6:
		var fx := -1.4 + j * 0.56
		Props.ball(root, 0.2, Vector3(fx, 1.0, 7.0 + (j % 2) * 0.4 - 0.2), Color("8a9aa8") if j % 2 == 0 else Color("a8b0b8"), Vector3(1.8, 0.7, 0.7), 6)
	# Kurutma ağları: iki direk + ağ sırası
	for s in [-1.0, 1.0]:
		Props.cyl(root, 0.09, 3.0, Vector3(s * (w - 1.0), 1.5, 12.5), K.TIMBER_D, Vector3.ZERO, 6)
	Props.box(root, Vector3(w * 2.0 - 2.0, 0.08, 0.08), Vector3(0, 2.95, 12.5), K.TIMBER_D)
	for j in 10:
		Props.box(root, Vector3(1.4, 1.5, 0.03), Vector3(-w + 2.0 + j * (w * 2.0 - 4.0) / 9.0, 2.2, 12.5), Color("8a7a5a"))
	# Tabure/sepet/leğen
	for j in 7:
		Props.cyl(root, 0.32, 0.3, Vector3(-w + 1.5 + j * 4.0, 0.21, 1.2 + (j % 3) * 0.7), Color("a07a44"), Vector3.ZERO, 8, 0.26)
	K.crate_steps(root, Vector3(w + 2.5, 0.06, 6.0), Vector3(-1, 0, 0), 2)


static func _stall(p: Node3D, pos: Vector3, awn: Color) -> void:
	# Tezgâh (katı, 0,9 yüksek) + 4 direk + kumaş tente (3 m üstte) + sepetler
	var tb := K.blk(p, Vector3(3.0, 0.9, 1.1), pos + Vector3(0, 0.45, 0), Color("8a6a40"), "wood")
	tb.name = "Tezgah"
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			Props.cyl(p, 0.06, 2.9, pos + Vector3(sx * 1.55, 1.45, sz * 0.9), K.TIMBER_D, Vector3.ZERO, 6)
	Props.box(p, Vector3(3.6, 0.06, 2.2), pos + Vector3(0, 2.95, 0.0), awn, Vector3(8, 0, 0))
	for i in 6:
		Props.box(p, Vector3(0.3, 0.08, 0.5), pos + Vector3(-1.2 + i * 0.48, 0.94, 0.0), Color("9aa8b4") if i % 2 == 0 else Color("b8a890"))
	Props.cyl(p, 0.3, 0.28, pos + Vector3(1.9, 0.2, 1.0), Color("a07a44"), Vector3.ZERO, 8, 0.25)


static func perches_balik(k: float) -> Array:
	return [Vector3(0, 0.96 + 0.05, 7.0)]


static func climbs_balik(k: float) -> Array:
	return [[Vector3(0, 0, 4.4), Vector3(0, 0.96, 6.3), "basamak"]]
