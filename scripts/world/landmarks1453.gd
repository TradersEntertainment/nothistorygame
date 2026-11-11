class_name Landmarks1453
extends RefCounted
## 1453'te ayakta olan tarihî yapılar (docs/CITY_LIFE.md §2): veri ve low-poly modeller (Dressing ilkelleri; birleşik
## ağlar WorldWalk ile katılaşır). Dünya koordinatında (World1453.LANDMARKS). Bir kısmı başka yerde kurulur ("var"):
## Ayasofya, Hipodrom'un duvarları ve dikilitaşı, Konstantin Sütunu, Büyük Saray terasları (HornWorld), Havariyun ve
## Bozdoğan Kemeri (HornWorld._monuments), Tekfur Sarayı (HornWorld._blachernae), Galata Kulesi (GalataView); burada
## onlara yalnız eksik parçalar eklenir (Hipodrom'un oturma basamakları, Örme Dikilitaş, sphendone; sarayın yıkıntıları;
## Konstantin Forumu'nun revakı).
## CityPlan anıtların tabanını (r ya da box) sokaktan ve evden boş bırakır. Bölümün oynanış alanına (keep) giren yapı
## kurulmaz.

const BRICK := Color("b46a4e")
const BRICK2 := Color("a85c44")
const WARM := Color("c88a64")
const STONE := Color("cdbd9e")
const LIGHT := Color("e2d6bc")
const MARBLE := Color("e8e2d4")
const LEAD := Color("7a8594")
const TILE := Color("a0503a")
const BRONZE := Color("8a6a3a")
const GOLD := Color("d8b040")
const DARK := Color("2a2228")
const WOOD := Color("6a4a2c")
const PORPHYRY := Color("7a3040")

## [anahtar, LANDMARKS anahtarı, taban yarıçapı, kurulu mu (başka yerde), gözcü noktası yüksekliği (yoksa 0)]
const DATA := [
	["ayasofya", "ayasofya", 42.0, true, 50.4],
	["aya_irini", "aya_irini", 26.0, false, 0.0],
	["augustaion", "augustaion", 22.0, false, 31.0],
	["cistern", "cistern", 7.0, false, 0.0],
	["hippodrome", "hippodrome", 60.0, true, 0.0],
	["great_palace", "great_palace", 40.0, true, 0.0],
	["forum_constantine", "column", 24.0, true, 34.0],
	["forum_tauri", "forum_tauri", 28.0, false, 34.4],
	["aqueduct", "aqueduct_a", 20.0, true, 0.0],
	["apostles", "apostles", 28.0, true, 0.0],
	["pantokrator", "pantokrator", 30.0, false, 0.0],
	["khora", "khora", 18.0, false, 0.0],
	["pammakaristos", "pammakaristos", 18.0, false, 0.0],
	["studios", "studios", 30.0, false, 0.0],
	["golden_gate", "golden_gate", 24.0, false, 0.0],
	["harbor_theodosius", "harbor_theodosius", 30.0, false, 0.0],
	["harbor_kontoskalion", "harbor_kontoskalion", 30.0, false, 0.0],
	["quay_venice", "quay_venice", 26.0, false, 0.0],
	["quay_amalfi", "quay_amalfi", 26.0, false, 0.0],
	["quay_genoa", "quay_genoa", 26.0, false, 0.0],
	["tekfur", "blachernae", 18.0, true, 0.0],
	["blachernae_palace", "blachernae_palace", 18.0, false, 0.0],
	["galata_tower", "galata_tower", 8.0, true, 0.0],
]
## Marmara kıyı surunun yönü (kara surlarının güney ucundan burna) ve denize bakan normali
const SHORE_DIR := Vector2(-0.6071, -0.7946)
const SEA_N := Vector2(0.7946, -0.6071)


## Bütün yapılar: {"key", "name_key", "info_key", "pos": Vector3 (y = görünen yüzey), "r": float} ve varsa
## "view": Vector3 (gözcü noktası: tepesinde durulan yer, dünya)
static func all() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for d: Array in DATA:
		var p := _pos(d[0], d[1])
		var y := World1453.surface_h(p.x, p.z)
		var e := {"key": d[0], "name_key": "LM_%s_NAME" % String(d[0]).to_upper(), "info_key": "LM_%s_INFO" % String(d[0]).to_upper(),
			"pos": Vector3(p.x, y, p.z), "r": d[2]}
		if float(d[4]) > 0.0:
			e["view"] = Vector3(p.x, y + float(d[4]), p.z)
		if d[0] == "galata_tower":
			e["view"] = Vector3(p.x, World1453.galata_top(p) - 1.2, p.z)
		elif d[0] == "aqueduct":
			e["view"] = Vector3(p.x, 20.3, p.z)
		out.append(e)
	return out


static func _pos(key: String, lm: String) -> Vector3:
	if key == "aqueduct":
		return ((World1453.LANDMARKS["aqueduct_a"] as Vector3) + (World1453.LANDMARKS["aqueduct_b"] as Vector3)) * 0.5
	return World1453.LANDMARKS[lm]


## Şehir planı için tabanlar (dünya x, z): {"c": Vector2, "r": float} ya da yönlü dikdörtgen "box": [orta, u, yarı u, yarı v]
static func footprints() -> Array:
	var out: Array = []
	for d: Array in DATA:
		var p := _pos(d[0], d[1])
		if not World1453.in_city(p.x, p.z):
			continue
		var c := Vector2(p.x, p.z)
		var f := {"key": d[0], "c": c, "r": d[2]}
		match String(d[0]):
			"ayasofya":
				f["box"] = [c, Vector2.RIGHT, 40.0, 44.0]
			"hippodrome":
				f["box"] = [c + Vector2(0, -14.0), Vector2.RIGHT, 48.0, 134.0]
			"great_palace":
				f["box"] = [Vector2(-548.0, -1611.0), Vector2.RIGHT, 32.0, 46.0]
			"apostles":
				f["box"] = [c, Vector2.RIGHT, 26.0, 26.0]
			"aqueduct":
				var a: Vector3 = World1453.LANDMARKS["aqueduct_a"]
				var b: Vector3 = World1453.LANDMARKS["aqueduct_b"]
				var u := Vector2(b.x - a.x, b.z - a.z)
				f["box"] = [c, u.normalized(), u.length() * 0.5 + 4.0, 5.0]
			"studios":
				f["box"] = [c, SHORE_DIR, 32.0, 15.0]
			"golden_gate":
				f["box"] = [c + Vector2(0, -2.0), Vector2.RIGHT, 24.0, 10.0]
		out.append(f)
	return out


# ---------------------------------------------------------------- kurulum

## Yeni yapıları kurar (free(x, z, pay): bölümün oynanış alanı dışı mı). Döner: dünyada duran yapıların anahtarları
## (başka yerde kurulanlar dahil); parent'a "landmarks1453" metası olarak da yazılır.
static func build(parent: Node3D, free: Callable, region := "") -> Array[String]:
	var d := Dressing.new(1453)
	d.chunk = 240.0
	var built: Array[String] = []
	for e: Dictionary in all():
		var key: String = e["key"]
		var p: Vector3 = e["pos"]
		var existing := false
		for row: Array in DATA:
			if row[0] == key:
				existing = row[3]
		# Başka yerde kurulanlar (bölümün kendi sahnesindekiler dahil) hep durur; Tekfur'u Blakherna bölümü kendi kurar
		if existing:
			if key != "tekfur" or region != "blachernae":
				built.append(key)
			if not (key in ["hippodrome", "great_palace", "forum_constantine"]):
				continue
		# Büyük tabanlarda keep'e uzaklık yapının kendi genişliğiyle ölçülür (Hipodrom'un duvarları ±44 m)
		if not free.call(p.x, p.z, minf(float(e["r"]), 40.0)):
			continue
		var ok := not existing
		match key:
			"aya_irini":
				_aya_irini(d, p)
			"augustaion":
				_augustaion(d, p)
			"cistern":
				_cistern(d, p)
			"hippodrome":
				_hippodrome(d, p)
			"great_palace":
				_palace_ruins(d, p, free)
			"forum_constantine":
				_forum_constantine(d, p)
			"forum_tauri":
				_forum_tauri(d, p)
			"pantokrator":
				_pantokrator(d, p)
			"khora":
				_khora(d, p)
			"pammakaristos":
				_pammakaristos(d, p)
			"studios":
				_studios(d, p)
			"golden_gate":
				_golden_gate(d, p)
			"harbor_theodosius", "harbor_kontoskalion":
				_harbor(d, p, key == "harbor_kontoskalion")
			"quay_venice":
				_quay(d, p, "venice")
			"quay_amalfi":
				_quay(d, p, "amalfi")
			"quay_genoa":
				_quay(d, p, "genoa")
			"blachernae_palace":
				_blachernae_palace(d, p)
		if ok:
			built.append(key)
	_furnish(d, free)
	d.build(parent)
	_place_quay_ships(parent)
	parent.set_meta("landmarks1453", built)
	return built


## Tabanın en alçak ve en yüksek yüzeyi (r yarıçapında)
static func _ground(c: Vector3, r: float) -> Vector2:
	var lo := INF
	var hi := -INF
	for k in 9:
		var o := Vector2.ZERO if k == 0 else Vector2.from_angle(TAU * k / 8.0) * r
		var y := World1453.surface_h(c.x + o.x, c.z + o.y)
		lo = minf(lo, y)
		hi = maxf(hi, y)
	return Vector2(lo, hi)


## Yapının çerçevesi: taban yüksekliği (yamaçta en yüksek köşe ile en alçak arası) ve gerekiyorsa taş kaide
static func _frame(d: Dressing, c: Vector3, r: float, yaw := 0.0, size := Vector2.ZERO) -> float:
	var g := _ground(c, r)
	var y0 := lerpf(g.x, g.y, 0.6)
	d.at(Vector3(c.x, y0, c.z), yaw)
	if g.y - g.x > 0.6:
		var s := size if size != Vector2.ZERO else Vector2(r * 1.6, r * 1.6)
		var bot := g.x - 1.0 - y0
		d.box(Vector3(s.x, 0.25 - bot, s.y), Vector3(0, (0.25 + bot) * 0.5, 0), STONE.darkened(0.12))
	return y0


## Kasnaklı kubbe: kasnak, kurşun kubbe, tepe haçı (yerel çerçevede)
static func _dome(d: Dressing, p: Vector3, r: float, drum: float, flat := 0.62, cross := true) -> void:
	d.cyl(r, drum, p + Vector3(0, drum * 0.5, 0), LIGHT.darkened(0.08), Vector3.ZERO, 14)
	d.cyl(r + 0.08, drum * 0.3, p + Vector3(0, drum * 0.55, 0), DARK, Vector3.ZERO, 14)      # pencere dizisi
	d.ball(r * 1.04, p + Vector3(0, drum, 0), LEAD, Vector3(1, flat, 1), 14)
	if cross:
		var top := drum + r * 1.04 * flat
		d.box(Vector3(0.25, 1.6, 0.25), p + Vector3(0, top + 0.7, 0), GOLD)
		d.box(Vector3(0.9, 0.22, 0.22), p + Vector3(0, top + 1.0, 0), GOLD)


static func _apse(d: Dressing, p: Vector3, r: float, h: float, col: Color) -> void:
	d.cyl(r, h, p + Vector3(0, h * 0.5, 0), col, Vector3.ZERO, 12)
	d.ball(r * 1.02, p + Vector3(0, h, 0), LEAD, Vector3(1, 0.5, 1), 12)


# ---------------------------------------------------------------- yapılar

## Aya İrini: bazilika gövdesi, büyük kubbe ve onun batısında basık ikinci kubbe, apsis, avlu
static func _aya_irini(d: Dressing, p: Vector3) -> void:
	_frame(d, p, 24.0, 0.0, Vector2(30.0, 54.0))
	d.box(Vector3(22, 13, 40), Vector3(0, 6.5, 0), BRICK)
	d.box(Vector3(22.4, 0.5, 40.4), Vector3(0, 13.2, 0), TILE)
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(5, 9, 36), Vector3(sx * 13.5, 4.5, 1), BRICK.darkened(0.06))
		for k in 6:
			d.box(Vector3(0.2, 2.6, 1.4), Vector3(sx * 16.05, 4.5, -14 + k * 6), DARK)
	_apse(d, Vector3(0, 0, -20), 7.0, 11.0, BRICK.darkened(0.03))
	_dome(d, Vector3(0, 13.4, -6), 7.5, 4.0)
	_dome(d, Vector3(0, 13.4, 10), 6.0, 1.6, 0.45, false)
	# Avlu (atrium)
	d.box(Vector3(24, 5, 1.2), Vector3(0, 2.5, 34), BRICK.lightened(0.06))
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(1.2, 5, 14), Vector3(sx * 11.4, 2.5, 27), BRICK.lightened(0.06))


## Augustaion: Justinianus Sütunu (bronz kaplı gövde, tepesinde doğuya bakan atlı imparator)
static func _augustaion(d: Dressing, p: Vector3) -> void:
	_frame(d, p, 6.0, 0.0, Vector2(10.0, 10.0))
	d.box(Vector3(9, 1.2, 9), Vector3(0, 0.6, 0), MARBLE.darkened(0.06))
	d.box(Vector3(6.6, 1.0, 6.6), Vector3(0, 1.7, 0), MARBLE.darkened(0.02))
	d.box(Vector3(4.6, 3.2, 4.6), Vector3(0, 3.8, 0), MARBLE)
	d.cyl(1.35, 24.0, Vector3(0, 17.4, 0), Color("a07a4a"), Vector3.ZERO, 12)
	for k in 6:
		d.cyl(1.47, 0.35, Vector3(0, 7.4 + k * 4.2, 0), BRONZE.darkened(0.2), Vector3.ZERO, 12)
	d.box(Vector3(3.6, 1.4, 3.6), Vector3(0, 30.1, 0), MARBLE)
	# At (−z'ye, doğuya bakar) ve süvari: elinde haçlı küre
	var y := 30.8
	d.box(Vector3(1.4, 1.5, 3.8), Vector3(0, y + 2.4, 0), BRONZE)
	for lx: float in [-0.45, 0.45]:
		d.cyl(0.2, 1.8, Vector3(lx, y + 0.9, 1.4), BRONZE.darkened(0.1), Vector3.ZERO, 6)
	d.cyl(0.2, 1.8, Vector3(-0.45, y + 0.9, -1.4), BRONZE.darkened(0.1), Vector3.ZERO, 6)
	d.cyl(0.2, 1.6, Vector3(0.45, y + 1.6, -2.0), BRONZE.darkened(0.1), Vector3(-60, 0, 0), 6)   # kalkık ön ayak
	d.box(Vector3(0.7, 2.0, 1.0), Vector3(0, y + 3.6, -2.0), BRONZE, Vector3(-35, 0, 0))
	d.box(Vector3(0.6, 0.7, 1.5), Vector3(0, y + 4.4, -2.7), BRONZE, Vector3(25, 0, 0))
	d.box(Vector3(0.3, 1.6, 0.3), Vector3(0, y + 2.2, 2.2), BRONZE.darkened(0.1), Vector3(30, 0, 0))
	d.cyl(0.55, 2.0, Vector3(0, y + 4.1, 0.2), BRONZE.lightened(0.05), Vector3.ZERO, 8)
	d.ball(0.42, Vector3(0, y + 5.5, 0.2), BRONZE.lightened(0.05), Vector3.ONE, 8)
	d.cyl(0.25, 0.9, Vector3(0, y + 6.3, 0.2), GOLD, Vector3.ZERO, 6, 2.2)              # tüylü miğfer (toupha)
	d.box(Vector3(0.28, 0.28, 1.6), Vector3(0.6, y + 4.6, -0.6), BRONZE)
	d.ball(0.4, Vector3(0.6, y + 4.9, -1.5), GOLD, Vector3.ONE, 8)
	d.box(Vector3(0.1, 0.6, 0.1), Vector3(0.6, y + 5.5, -1.5), GOLD)


## Yerebatan Sarnıcı girişi: dört sütunlu, piramit çatılı köşk; ortasında aşağı inen merdivenin karanlık ağzı
static func _cistern(d: Dressing, p: Vector3) -> void:
	_frame(d, p, 5.0, 0.0, Vector2(10.0, 10.0))
	d.box(Vector3(9, 0.8, 9), Vector3(0, 0.4, 0), MARBLE.darkened(0.12))
	for cx: float in [-3.6, 3.6]:
		for cz: float in [-3.6, 3.6]:
			d.cyl(0.35, 4.2, Vector3(cx, 2.9, cz), MARBLE, Vector3.ZERO, 8)
	d.box(Vector3(8.4, 0.7, 8.4), Vector3(0, 5.35, 0), MARBLE.darkened(0.04))
	d.cyl(6.3, 2.6, Vector3(0, 7.0, 0), TILE, Vector3(0, 45, 0), 4, 0.04)
	d.box(Vector3(2.4, 0.05, 4.0), Vector3(0, 0.83, 0.8), Color("141014"))
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(0.3, 0.9, 4.0), Vector3(sx * 1.35, 1.25, 0.8), MARBLE.darkened(0.08))


## Hipodrom'a eklenenler: Örme Dikilitaş, Yılanlı Sütun'un başları, yıkık oturma basamakları, güney ucunda sphendone
static func _hippodrome(d: Dressing, p: Vector3) -> void:
	var hy := HornWorld.east_surf(p.x, p.z)
	d.at(Vector3.ZERO)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3301
	# Örme Dikilitaş (kaba taş, bronz levhaları sökülmüş)
	d.box(Vector3(3.4, 1.6, 3.4), Vector3(p.x, hy + 0.8, p.z - 70.0), STONE.darkened(0.1))
	d.cyl(1.6, 22.0, Vector3(p.x, hy + 12.6, p.z - 70.0), Color("9a8a70"), Vector3(0, 45, 0), 4, 0.3)
	# Yılanlı Sütun'un üç yılan başı
	for k in 3:
		var a := TAU * k / 3.0
		d.ball(0.45, Vector3(p.x + cos(a) * 0.9, hy + 18.3, p.z + 20.0 + sin(a) * 0.9), BRONZE.darkened(0.1), Vector3(1.3, 0.7, 1.3), 6)
	# Oturma basamakları: duvarların iç yüzüne yaslı, yer yer yıkık
	for sx: float in [-1.0, 1.0]:
		var z := p.z - 104.0
		while z < p.z + 100.0:
			var L := rng.randf_range(10.0, 22.0)
			L = minf(L, p.z + 104.0 - z)
			if rng.randf() < 0.3:
				z += L
				continue
			var broken := rng.randf_range(0.45, 1.0)
			for k in 3:
				var hh := (4.2 - k * 1.3) * broken
				d.box(Vector3(2.4, hh + 0.5, L), Vector3(p.x + sx * (34.7 - k * 2.4), hy + hh * 0.5 - 0.25, z + L * 0.5), STONE.darkened(0.06 + 0.04 * k))
			z += L + rng.randf_range(0.5, 3.0)
	# Sphendone: güney ucun yarım elips biçimli yüksek duvarı
	var n := 12
	for s in n:
		var a0 := PI * s / n
		var a1 := PI * (s + 1) / n
		var q0 := Vector2(p.x + 40.0 * cos(a0), p.z - 110.0 - 24.0 * sin(a0))
		var q1 := Vector2(p.x + 40.0 * cos(a1), p.z - 110.0 - 24.0 * sin(a1))
		var m := (q0 + q1) * 0.5
		var h := 9.6 if rng.randf() > 0.25 else rng.randf_range(3.0, 6.0)
		var yaw := rad_to_deg(atan2(q1.x - q0.x, q1.y - q0.y))
		d.box(Vector3(8.0, h + 1.0, q0.distance_to(q1) + 0.6), Vector3(m.x, hy + h * 0.5 - 0.5, m.y), STONE.darkened(0.16), Vector3(0, yaw, 0))


## Büyük Saray: terasların üstünde yıkık duvarlar ve ayakta kalmış sütunlar
static func _palace_ruins(d: Dressing, p: Vector3, free: Callable) -> void:
	d.at(Vector3.ZERO)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3302
	for k: int in [0, 2]:
		var q := p + Vector3(k * 8.0, 0, -k * 14.0)
		if not free.call(q.x, q.z, 20.0):
			continue
		var top := HornWorld.east_surf(q.x, q.z) + 8.0 + k
		var h1 := rng.randf_range(4.0, 7.0)
		d.box(Vector3(1.4, h1, 16), Vector3(q.x - 10.0, top + h1 * 0.5 - 0.3, q.z + 4.0), BRICK2)
		for w in 3:
			d.box(Vector3(1.6, 2.2, 1.4), Vector3(q.x - 10.0, top + h1 - 2.4, q.z - 1.0 + w * 5.0), DARK)
		var h2 := rng.randf_range(3.0, 6.0)
		d.box(Vector3(12, h2, 1.4), Vector3(q.x - 3.0, top + h2 * 0.5 - 0.3, q.z - 12.0), BRICK2.darkened(0.05))
		for i in 5:
			var ch := rng.randf_range(2.5, 6.0)
			d.cyl(0.45, ch, Vector3(q.x + 5.0, top + ch * 0.5 - 0.2, q.z - 12.0 + i * 5.0), MARBLE, Vector3.ZERO, 8)
		d.cyl(0.45, 0.9, Vector3(q.x + 8.0, top + 0.25, q.z + 6.0), MARBLE.darkened(0.1), Vector3(0, 0, 90), 8)   # devrik sütun


## Konstantin Forumu: sütunun çevresinde yuvarlak revak (sütun dizisi, üstünde arşitrav), Mese'nin girdiği iki kapı
static func _forum_constantine(d: Dressing, p: Vector3) -> void:
	_colonnade(d, p, 20.5, 28, [Vector2(-528.0, -1370.0), Vector2(-430.0, -1215.0)])


static func _colonnade(d: Dressing, p: Vector3, r: float, n: int, exits: Array) -> void:
	d.at(Vector3.ZERO)
	var gaps: Array = []
	for x: Vector2 in exits:
		gaps.append(atan2(x.y - p.z, x.x - p.x))
	var pts: Array = []
	for i in n:
		var a := TAU * i / n
		var skip := false
		for g: float in gaps:
			if absf(angle_difference(a, g)) < deg_to_rad(16.0):
				skip = true
		if skip:
			pts.append(null)
			continue
		var q := Vector2(p.x, p.z) + Vector2.from_angle(a) * r
		var y := World1453.surface_h(q.x, q.y) - 0.2
		d.cyl(0.55, 7.7, Vector3(q.x, y + 3.85, q.y), MARBLE, Vector3.ZERO, 8)
		d.box(Vector3(1.4, 0.6, 1.4), Vector3(q.x, y + 7.9, q.y), MARBLE.darkened(0.05))
		pts.append(Vector3(q.x, y, q.y))
	for i in n:
		var a: Variant = pts[i]
		var b: Variant = pts[(i + 1) % n]
		if a == null or b == null:
			continue
		var pa: Vector3 = a
		var pb: Vector3 = b
		var m := (pa + pb) * 0.5
		var yaw := rad_to_deg(atan2(pb.x - pa.x, pb.z - pa.z))
		d.box(Vector3(1.1, 0.9, pa.distance_to(pb) + 0.6), Vector3(m.x, maxf(pa.y, pb.y) + 8.6, m.z), LIGHT, Vector3(0, yaw, 0))
	# Kapılar: Mese'nin girdiği yerde iki ayak ve kemer
	for g: float in gaps:
		var ends: Array = []
		for s: float in [-1.0, 1.0]:
			var q := Vector2(p.x, p.z) + Vector2.from_angle(g + s * deg_to_rad(17.0)) * r
			var y := World1453.surface_h(q.x, q.y) - 0.3
			d.box(Vector3(2.6, 11.5, 2.6), Vector3(q.x, y + 5.75, q.y), MARBLE.darkened(0.04), Vector3(0, -rad_to_deg(g), 0))
			ends.append(Vector3(q.x, y, q.y))
		var e0: Vector3 = ends[0]
		var e1: Vector3 = ends[1]
		var mm := (e0 + e1) * 0.5
		d.box(Vector3(2.0, 2.4, e0.distance_to(e1) + 2.6), Vector3(mm.x, maxf(e0.y, e1.y) + 12.4, mm.z), MARBLE.darkened(0.08),
			Vector3(0, rad_to_deg(atan2(e1.x - e0.x, e1.z - e0.z)), 0))


## Tauri (Theodosius) Forumu: Mese üstünde üç gözlü zafer takı, ortada sarmal kabartmalı Theodosius Sütunu
static func _forum_tauri(d: Dressing, p: Vector3) -> void:
	# Sütun
	var y0 := _frame(d, p, 4.0, 0.0, Vector2(8.0, 8.0))
	d.box(Vector3(7.5, 1.0, 7.5), Vector3(0, 0.5, 0), MARBLE.darkened(0.08))
	d.box(Vector3(5.0, 4.0, 5.0), Vector3(0, 3.0, 0), MARBLE)
	d.cyl(2.0, 28.0, Vector3(0, 19.0, 0), MARBLE.darkened(0.03), Vector3.ZERO, 12)
	for k in 9:
		d.cyl(2.1, 0.55, Vector3(0, 7.0 + k * 3.0, 0), Color("b8ac94"), Vector3(9, k * 40.0, 0), 12)
	d.box(Vector3(4.6, 1.4, 4.6), Vector3(0, 33.7, 0), MARBLE)       # heykelsiz başlık (1453'te heykel yoktu)
	# Zafer takı: Mese'nin Philadelphion yönündeki çıkışında, geçit Mese boyunca
	var nx := Vector2(-330.0, -1065.0) - Vector2(p.x, p.z)
	var dir := nx.normalized()
	var c := Vector2(p.x, p.z) + dir * 22.0
	var ac := Vector3(c.x, 0, c.y)
	_frame(d, ac, 11.0, atan2(dir.x, dir.y), Vector2(25.0, 7.0))
	for px: float in [-10.5, -4.5, 4.5, 10.5]:
		d.box(Vector3(2.6, 13.0, 5.0), Vector3(px, 6.5, 0), MARBLE)
		for sz: float in [-1.0, 1.0]:
			d.cyl(0.5, 12.0, Vector3(px, 6.0, sz * 3.0), MARBLE.darkened(0.06), Vector3.ZERO, 8)
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(3.4, 4.0, 4.8), Vector3(sx * 7.5, 11.0, 0), MARBLE.darkened(0.04))
	d.box(Vector3(24.2, 5.0, 5.6), Vector3(0, 15.5, 0), MARBLE.darkened(0.02))
	d.box(Vector3(24.8, 0.6, 6.2), Vector3(0, 18.3, 0), LIGHT.darkened(0.1))
	d.at(Vector3(p.x, y0, p.z))


## Pantokrator Manastırı (Zeyrek): yan yana üç kilise (kuzey, ortada şapel, güney), ortak narteks
static func _pantokrator(d: Dressing, p: Vector3) -> void:
	_frame(d, p, 26.0, 0.0, Vector2(52.0, 44.0))
	for ch: Array in [[-17.5, 30.0, [-3.0], 12.0], [0.0, 26.0, [-5.0, 5.0], 10.0], [17.5, 34.0, [-5.0], 13.0]]:
		var ox: float = ch[0]
		var L: float = ch[1]
		var h: float = ch[3]
		var cz := 16.0 - L * 0.5
		var col := BRICK if ox != 0.0 else BRICK2
		d.box(Vector3(13, h, L), Vector3(ox, h * 0.5, cz), col)
		# Haç kollarının beşik çatıları (enine ve boyuna) ve kubbeler
		d.prism(Vector3(13.4, 2.6, L + 0.4), Vector3(ox, h + 1.3, cz), TILE)
		d.prism(Vector3(13.4, 2.6, 9.0), Vector3(ox, h + 1.3, cz - 3.0), TILE.darkened(0.06), Vector3(0, 90, 0))
		for dz: float in ch[2]:
			_dome(d, Vector3(ox, h + 1.0, cz + dz), 4.6 if ox != 0.0 else 3.6, 4.5)
		_apse(d, Vector3(ox, 0, cz - L * 0.5), 4.0, h - 2.0, col.darkened(0.04))
		for sx: float in [-1.0, 1.0]:
			for k in 4:
				d.box(Vector3(0.2, 2.6, 1.3), Vector3(ox + sx * 6.55, h * 0.6, cz - L * 0.3 + k * L * 0.2), DARK)
		for k in 3:
			d.box(Vector3(1.4, 2.4, 0.2), Vector3(ox - 3.0 + k * 3.0, 4.0, 23.95), DARK)
	d.box(Vector3(49, 8.5, 8), Vector3(0, 4.25, 19.9), BRICK.lightened(0.05))
	d.prism(Vector3(8.4, 2.0, 49.4), Vector3(0, 9.5, 19.9), TILE, Vector3(0, 90, 0))


## Khora (Kariye): kubbeli naos, iç ve dış narteks (küçük kubbeler), güneyde uzun parekklesion
static func _khora(d: Dressing, p: Vector3) -> void:
	_frame(d, p, 14.0, 0.0, Vector2(24.0, 30.0))
	d.box(Vector3(12, 11, 12), Vector3(0, 5.5, 0), WARM)
	_dome(d, Vector3(0, 11, 0), 3.8, 4.5)
	_apse(d, Vector3(0, 0, -6), 3.6, 9.0, WARM.darkened(0.05))
	d.box(Vector3(14, 8, 4), Vector3(0, 4, 8), WARM.lightened(0.04))
	d.box(Vector3(18, 7, 4.5), Vector3(0, 3.5, 12.2), WARM.lightened(0.08))
	for sx: float in [-5.0, 5.0]:
		_dome(d, Vector3(sx, 7, 12.2), 1.8, 1.2, 0.6, false)
	d.box(Vector3(5.5, 8.5, 20), Vector3(9.1, 4.25, 1), WARM.darkened(0.03))
	_dome(d, Vector3(9.1, 8.5, -2), 2.2, 2.0, 0.6, false)
	for k in 5:
		d.box(Vector3(1.2, 2.0, 0.2), Vector3(-6.0 + k * 3.0, 3.0, 14.5), DARK)


## Pammakaristos (Fethiye): bantlı tuğla duvarlar, ana kubbe, güneyde kubbeli parekklesion, kuzeyde dehliz
static func _pammakaristos(d: Dressing, p: Vector3) -> void:
	_frame(d, p, 14.0, 0.0, Vector2(30.0, 30.0))
	d.box(Vector3(14, 11, 18), Vector3(0, 5.5, 0), BRICK2)
	for hh: float in [3.0, 6.5, 9.5]:
		d.box(Vector3(14.3, 0.45, 18.3), Vector3(0, hh, 0), LIGHT)
	_dome(d, Vector3(0, 11, -1), 4.0, 4.0)
	_apse(d, Vector3(0, 0, -9), 3.6, 9.0, BRICK2.darkened(0.04))
	d.box(Vector3(7, 8.5, 15), Vector3(10.6, 4.25, -0.5), BRICK2.lightened(0.04))
	for hh: float in [3.3, 6.3]:
		d.box(Vector3(7.3, 0.4, 15.3), Vector3(10.6, hh, -0.5), LIGHT)
	_dome(d, Vector3(10.6, 8.5, -2), 2.4, 2.5)
	_apse(d, Vector3(10.6, 0, -8), 2.4, 7.0, BRICK2)
	d.box(Vector3(4, 7, 18), Vector3(-9.1, 3.5, 0), BRICK2.darkened(0.04))
	d.box(Vector3(26, 7.5, 5), Vector3(2.0, 3.75, 11.4), BRICK2.lightened(0.02))
	for sx: float in [-3.0, 7.0]:
		_dome(d, Vector3(sx, 7.5, 11.4), 1.7, 1.2, 0.6, false)


## Studios Manastırı: şehrin en eski bazilikası; beşik çatılı orta nef, yan nefler, apsis, revaklı avlu
static func _studios(d: Dressing, p: Vector3) -> void:
	# Uzun ekseni kıyı boyunca: apsis (yerel −z) burna, avlu (yerel +z) kara surlarına bakar
	var yaw := atan2(-SHORE_DIR.x, -SHORE_DIR.y)
	_frame(d, p, 22.0, yaw, Vector2(30.0, 66.0))
	d.box(Vector3(14, 15, 36), Vector3(0, 7.5, -4), BRICK)
	d.prism(Vector3(14.6, 4.5, 36.6), Vector3(0, 17.25, -4), TILE)
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(6, 9, 34), Vector3(sx * 10, 4.5, -4), BRICK.darkened(0.06))
		d.box(Vector3(6.8, 0.4, 34.6), Vector3(sx * 10, 9.4, -4), TILE, Vector3(0, 0, -sx * 12.0))
		for k in 7:
			d.box(Vector3(0.2, 3.0, 1.6), Vector3(sx * 7.05, 12.0, -19 + k * 5.0), DARK)
	_apse(d, Vector3(0, 0, -22), 6.5, 12.0, BRICK.darkened(0.04))
	d.box(Vector3(26, 9, 4), Vector3(0, 4.5, 16), BRICK.lightened(0.04))
	# Avlu: üç yanda duvar, iki sıra sütun, ortada kuyu
	d.box(Vector3(26, 5, 1), Vector3(0, 2.5, 33), BRICK.lightened(0.08))
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(1, 5, 16), Vector3(sx * 12.5, 2.5, 25.5), BRICK.lightened(0.08))
		for i in 5:
			d.cyl(0.4, 4.4, Vector3(sx * 9.5, 2.2, 19.5 + i * 3.2), MARBLE, Vector3.ZERO, 8)
	d.well(Vector3(0, 0, 26))


## Altınkapı: iç surun önünde iki mermer kule ve üç gözlü zafer takı (yaldızlı kapı)
static func _golden_gate(d: Dressing, p: Vector3) -> void:
	var gx: float = World1453.LAND_GATES[World1453.LAND_GATES.size() - 1]
	var y := SiegeField.city_surf(gx, -10.0) - 0.4
	d.at(Vector3(gx, y, 0.0))
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(12, 22, 12), Vector3(sx * 16.0, 11.0, -9.7), MARBLE)
		d.box(Vector3(12.6, 0.8, 12.6), Vector3(sx * 16.0, 22.3, -9.7), MARBLE.darkened(0.08))
		for k in 4:
			d.box(Vector3(1.4, 1.2, 1.4), Vector3(sx * 16.0 - 4.5 + k * 3.0, 23.3, -15.6), MARBLE.darkened(0.06))
	for px: float in [-4.65, 4.65]:
		d.box(Vector3(1.5, 12.5, 10.8), Vector3(px, 6.25, -9.3), MARBLE.darkened(0.03))
	d.box(Vector3(20, 6, 10.8), Vector3(0, 15.5, -9.3), MARBLE.darkened(0.02))
	d.box(Vector3(20.4, 0.6, 11.2), Vector3(0, 18.8, -9.3), GOLD.darkened(0.15))
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(5.0, 1.2, 10.6), Vector3(sx * 7.5, 9.0, -9.3), MARBLE.darkened(0.06))
	# Yaldızlı kapı kanatları (açık, iki yana yaslı)
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(0.25, 9.0, 3.2), Vector3(sx * 3.7, 4.5, -13.0), GOLD.darkened(0.25))


## Marmara limanı: surun dışında rıhtım, iki mendirek ve dalgakıran, demirli kayıklar; surun içinde ambar
static func _harbor(d: Dressing, p: Vector3, small: bool) -> void:
	var g := Vector2(p.x, p.z) + SEA_N * 22.0                       # surdaki kapı
	var yaw := atan2(SHORE_DIR.x, SHORE_DIR.y)                     # yerel z kıyı boyunca, yerel −x deniz
	var half := 36.0 if small else 45.0
	var out := 46.0 if small else 55.0
	d.at(Vector3(g.x, 0.0, g.y), yaw)
	d.box(Vector3(10.4, 4.3, half * 2.0), Vector3(-6.8, -1.85, 0), STONE.darkened(0.2))
	for sz: float in [-1.0, 1.0]:
		d.box(Vector3(out - 3.0, 3.6, 6), Vector3(-(out + 3.0) * 0.5, -1.0, sz * half), STONE.darkened(0.28))
		d.box(Vector3(6, 3.6, half - 13.0), Vector3(-out, -1.0, sz * (half + 13.0) * 0.5), STONE.darkened(0.3))
		d.cyl(1.4, 4.0, Vector3(-out, 1.2, sz * 13.5), STONE.darkened(0.12), Vector3.ZERO, 8)      # fener ayağı
	for k in int(half * 2.0 / 10.0):
		d.bollard(Vector3(-11.0, 0.45, -half + 5.0 + k * 10.0))
	var rng := RandomNumberGenerator.new()
	rng.seed = 3310 + int(small)
	for k in 7:
		var bp := Vector3(rng.randf_range(-out + 10.0, -16.0), -1.35, rng.randf_range(-half + 8.0, half - 8.0))
		_boat(d, bp, rng.randf_range(-20.0, 20.0), rng.randf() < 0.5, CLOTHS[k % CLOTHS.size()])
	# Ambar (surun içi)
	var wp := Vector2(p.x, p.z) - SEA_N * 4.0 + SHORE_DIR * 28.0
	_frame(d, Vector3(wp.x, 0, wp.y), 12.0, yaw, Vector2(12.0, 26.0))
	_warehouse(d, Vector3.ZERO, 24.0, 10.0, 8.0)
	d.at(Vector3.ZERO)


const CLOTHS := [Color("e8e0d0"), Color("c8a868"), Color("a8483a"), Color("d8cfb8")]


## Kayık: gövde, burun, oturaklar; mast: direk ve latin yelkeni (yerel çerçevede, gövde yerel z boyunca)
static func _boat(d: Dressing, p: Vector3, yaw_deg: float, mast: bool, sail: Color) -> void:
	var r := Basis(Vector3.UP, deg_to_rad(yaw_deg))
	d.box(Vector3(2.4, 1.1, 7.0), p + r * Vector3(0, 0.3, 0), Color("5a3e26"), Vector3(0, yaw_deg, 0))
	d.prism(Vector3(2.4, 1.1, 1.8), p + r * Vector3(0, 0.3, 4.3), Color("5a3e26"), Vector3(90, yaw_deg, 0))
	d.box(Vector3(2.0, 0.12, 6.4), p + r * Vector3(0, 0.82, 0), Color("8a6a40"), Vector3(0, yaw_deg, 0))
	if mast:
		d.cyl(0.12, 7.0, p + r * Vector3(0, 4.2, 0.6), Color("4a3220"), Vector3.ZERO, 5)
		d.prism(Vector3(0.06, 5.0, 4.0), p + r * Vector3(0, 4.8, 0.9), sail, Vector3(0, yaw_deg, 0))


## Ambar: uzun, iki katlı, kiremit çatılı; uzun kenarında kemerli kapılar (yerel z boyunca uzun)
static func _warehouse(d: Dressing, p: Vector3, L: float, w: float, h: float) -> void:
	d.box(Vector3(w, h, L), p + Vector3(0, h * 0.5, 0), Color("c8b090"))
	d.prism(Vector3(w + 0.6, 2.8, L + 0.6), p + Vector3(0, h + 1.4, 0), TILE)
	for sx: float in [-1.0, 1.0]:
		for k in int(L / 6.0):
			var z := -L * 0.5 + 3.0 + k * 6.0
			d.box(Vector3(0.2, 3.2, 2.4), p + Vector3(sx * (w * 0.5 + 0.02), 1.6, z), Color("3a2a1e"))
			d.box(Vector3(0.2, 1.2, 1.2), p + Vector3(sx * (w * 0.5 + 0.02), h - 2.0, z), DARK)


## Haliç iskelesi (Venedik, Amalfi, Ceneviz): surun içinde iki ambar ve sancak, dışında iskele ve gemiler
static func _quay(d: Dressing, p: Vector3, who: String) -> void:
	var flag: Color = {"venice": Color("a8242a"), "amalfi": Color("2a4a8a"), "genoa": Color("ece6d8")}[who]
	var cross: Color = {"venice": GOLD, "amalfi": Color("ece6d8"), "genoa": Color("b02028")}[who]
	for sz: float in [-1.0, 1.0]:
		var c := Vector3(p.x + 2.0, 0, p.z + sz * 18.0)
		_frame(d, c, 12.0, PI * 0.5, Vector2(11.0, 25.0))
		_warehouse(d, Vector3.ZERO, 22.0, 10.0, 9.0 if sz > 0.0 else 8.0)
	var y := World1453.surface_h(p.x + 10.0, p.z)
	d.at(Vector3(p.x + 10.0, y, p.z - 10.0))
	d.cyl(0.14, 12.0, Vector3(0, 6.0, 0), WOOD, Vector3.ZERO, 6)
	d.box(Vector3(0.1, 1.8, 3.0), Vector3(0, 11.0, 1.6), flag)
	d.box(Vector3(0.14, 1.8, 0.4), Vector3(0, 11.0, 1.6), cross)
	d.box(Vector3(0.14, 0.35, 3.0), Vector3(0, 11.0, 1.6), cross)
	# Surun dışında iskele ve gemiler (kapının yanında)
	var px := World1453.HORN_S_X
	d.at(Vector3(px, World1453.SEA_Y, p.z + 16.0))
	d.box(Vector3(40, 3.0, 6), Vector3(-32.0, 0.1, 0), WOOD.darkened(0.1))
	for k in 8:
		for sz: float in [-1.0, 1.0]:
			d.cyl(0.25, 4.0, Vector3(-14.0 - k * 5.0, 0.2, sz * 3.2), WOOD.darkened(0.25), Vector3.ZERO, 5)
	for k in 2:
		# Nefler 24 m: ikisi iç içe binmesin (eskiden 14 m arayla); biri iskelenin bir yanında, öteki öbür yanında
		_quay_ships.append([who, Transform3D(Basis(Vector3.UP, -PI * 0.5 + (k - 0.5) * 0.12),
			Vector3(px - 28.0 - k * 44.0, World1453.SEA_Y, p.z + 16.0 + (9.0 if k == 0 else -11.0)))])
	d.at(Vector3.ZERO)


## Tüccar gemisi (yerel x boyunca, su yüzü y 0)
static var _quay_ships: Array = []


## İskelelerdeki tüccar gemileri (ship_mesh: Venedik, Ceneviz nefleri; Amalfi düz boyalı), türe göre birer çoklu ağ
static func _place_quay_ships(parent: Node3D) -> void:
	var by := {}
	for q: Array in _quay_ships:
		var kind: String = {"venice": "carrack_venice", "genoa": "carrack_genoa"}.get(q[0], "carrack")
		if not by.has(kind):
			by[kind] = []
		by[kind].append(q[1])
	_quay_ships.clear()
	for kind: String in by:
		var mi := Scenery.scatter(parent, ship_mesh(kind), by[kind], [], ship_material())
		mi.name = "QuayShips"
		mi.visibility_range_end = 1400.0


static func _ship(d: Dressing, p: Vector3, flag: Color) -> void:
	d.box(Vector3(14, 2.6, 4.2), p + Vector3(0, 0.6, 0), Color("4a3222"))
	d.box(Vector3(4, 2.0, 4.0), p + Vector3(5.5, 2.6, 0), Color("5a3a26"))
	d.box(Vector3(13, 0.3, 3.8), p + Vector3(0, 1.95, 0), Color("8a6a40"))
	d.cyl(0.22, 13.0, p + Vector3(-0.5, 8.0, 0), Color("4a3220"), Vector3.ZERO, 5)
	d.box(Vector3(5.0, 6.0, 0.1), p + Vector3(-0.5, 9.0, 0), Color("e8e0d0"))
	d.box(Vector3(1.4, 0.9, 0.08), p + Vector3(-1.0, 15.0, 0), flag)


## Blakherna Sarayı: Haliç'e bakan bantlı tuğla saray, köşede kule, şehre bakan sütunlu loca
static func _blachernae_palace(d: Dressing, p: Vector3) -> void:
	_frame(d, p, 15.0, 0.0, Vector2(30.0, 22.0))
	d.box(Vector3(26, 16, 14), Vector3(0, 8, 0), BRICK2)
	for hh: float in [5.0, 10.5, 15.7]:
		d.box(Vector3(26.3, 0.5, 14.3), Vector3(0, hh, 0), LIGHT)
	for row: float in [7.6, 13.0]:
		for k in 5:
			d.box(Vector3(0.2, 2.4, 1.6), Vector3(13.05, row, -5.0 + k * 2.5), DARK)
			d.box(Vector3(1.6, 2.4, 0.2), Vector3(-9.0 + k * 4.5, row, 7.05), DARK)
	d.box(Vector3(8, 26, 8), Vector3(-9, 13, -9), BRICK2.darkened(0.05))
	d.box(Vector3(8.6, 0.8, 8.6), Vector3(-9, 26.4, -9), LIGHT.darkened(0.08))
	d.cyl(6.2, 3.2, Vector3(-9, 28.4, -9), TILE, Vector3(0, 45, 0), 4, 0.04)
	d.box(Vector3(4, 0.6, 14), Vector3(15.0, 6.3, 0), LIGHT.darkened(0.06))
	for k in 4:
		d.cyl(0.35, 6.0, Vector3(16.5, 3.0, -6.0 + k * 4.0), MARBLE, Vector3.ZERO, 8)


# ---------------------------------------------------------------- meydanların donanımı

## Forumlarda çeşme ve tezgâhlar, pazarlarda tezgâh halkası, limanlarda sandık, fıçı, ağ; Arkadios Forumu'nda sütun
static func _furnish(d: Dressing, free: Callable) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3320
	for pl: Dictionary in CityPlan.plazas():
		var c: Vector3 = pl["pos"]
		var r: float = pl["r"]
		if not free.call(c.x, c.z, r + 2.0):
			continue
		var kind: String = pl["kind"]
		var name: String = pl["name"]
		# Philadelphion'un porfir Tetrarkları ve Bovis'in tunç öküz başı 1204'te (Haçlılar) götürüldü/eritildi: 1453'te yok
		match name:
			"Forum Arcadii":
				d.at(Vector3(c.x, World1453.surface_h(c.x, c.z) - 0.2, c.z))
				d.box(Vector3(6.0, 4.0, 6.0), Vector3(0, 2.0, 0), MARBLE)
				d.cyl(1.7, 24.0, Vector3(0, 16.0, 0), MARBLE.darkened(0.03), Vector3.ZERO, 12)
				for k in 7:
					d.cyl(1.8, 0.5, Vector3(0, 6.0 + k * 3.0, 0), Color("b8ac94"), Vector3(9, k * 40.0, 0), 12)
				d.box(Vector3(4.0, 1.2, 4.0), Vector3(0, 28.6, 0), MARBLE)
		# Çeşme (sütunlu forumlarda kenarda)
		if kind == "forum" or kind == "market":
			var fq := Vector2(c.x, c.z)
			if name in ["Forum Constantini", "Forum Tauri", "Augustaion", "Forum Arcadii", "Philadelphion"] or CityPlan.on_road(fq.x, fq.y, 1.5):
				for k in 8:
					var q := Vector2(c.x, c.z) + Vector2.from_angle(0.9 + k * TAU / 8.0) * r * 0.55
					if not CityPlan.on_road(q.x, q.y, 2.5):
						fq = q
						break
			if not CityPlan.on_road(fq.x, fq.y, 1.5):
				d.at(Vector3(fq.x, World1453.surface_h(fq.x, fq.y) - 0.1, fq.y))
				d.cyl(2.2, 0.8, Vector3(0, 0.4, 0), MARBLE.darkened(0.06), Vector3.ZERO, 12)
				d.cyl(1.9, 0.05, Vector3(0, 0.78, 0), Color("4a7a9a"), Vector3.ZERO, 12)
				d.cyl(0.35, 2.2, Vector3(0, 1.4, 0), MARBLE, Vector3.ZERO, 8)
				d.ball(0.6, Vector3(0, 2.6, 0), MARBLE, Vector3(1, 0.6, 1), 8)
		# Tezgâhlar: halkada, meydanın ortasına bakar, yolların üstüne konmaz
		var n := 0
		if kind == "market":
			n = 7
		elif kind == "forum":
			n = 5
		for k in n:
			var a := TAU * k / n + rng.randf_range(-0.2, 0.2)
			var q := Vector2(c.x, c.z) + Vector2.from_angle(a) * (r - 3.0)
			if CityPlan.on_road(q.x, q.y, 2.0) or CityPlan.in_house(q.x, q.y, 1.0):
				continue
			var yaw := atan2(c.x - q.x, c.z - q.y)
			d.at(Vector3(q.x, World1453.surface_h(q.x, q.y) - 0.05, q.y), yaw).stall(Vector3.ZERO, Dressing.CLOTH[rng.randi() % Dressing.CLOTH.size()])
		if kind == "harbor":
			for k in 6:
				var a := TAU * k / 6.0 + rng.randf_range(-0.3, 0.3)
				var q := Vector2(c.x, c.z) + Vector2.from_angle(a) * rng.randf_range(r * 0.5, r - 2.0)
				if CityPlan.on_road(q.x, q.y, 1.5):
					continue
				d.at(Vector3(q.x, World1453.surface_h(q.x, q.y) - 0.05, q.y), rng.randf() * TAU)
				match k % 4:
					0:
						d.crates(Vector3.ZERO)
					1:
						d.barrels(Vector3.ZERO)
					2:
						d.sacks(Vector3.ZERO)
					_:
						d.net(Vector3.ZERO)
	d.at(Vector3.ZERO)


# ---------------------------------------------------------------- tarih (bölümün kuşatmadaki yeri)

## Bölümün kuşatma sayfaları arasındaki sırası (Siege.ORDER tarih sırasıdır); kuşatma sayfası değilse −1 (Perde I–III,
## fetih sonrası ana hikâye, testler: onlarda dünyanın varsayılanı değişmez).
static func siege_index(n: Node) -> int:
	var ch := CityLife.chapter_of(n)
	return -1 if ch == "" else Siege.ORDER.find(ch.to_int())


## Osmanlı kadırgaları Haliç'te mi: kızaklarla 22 Nisan'da girdiler. Kuşatma sayfalarından 28 Nisan'dan (17) öncekiler
## (7–20 Nisan: 42, 36, 28, 41, 37, 29) ve 1452–Mart 1453 sayfaları onları görmez; kızak yolu da henüz yok.
static func fleet_in_horn(n: Node) -> bool:
	var i := siege_index(n)
	return i < 0 or i >= Siege.ORDER.find(17)


## Ayasofya'nın kubbesinde haç: 1 Haziran (27, ilk cuma namazı) sayfasında yok; 29–31 Mayıs sayfaları değişmez.
static func aya_cross(n: Node) -> bool:
	var i := siege_index(n)
	return i < 0 or i < Siege.ORDER.find(27)


## Zincirin içindeki İtalyan gemileri 29 Mayıs öğleden sonra kaçtı: 30 Mayıs – 1 Haziran (31o) sayfasında yoklar. 27'de
## (1 Haziran, Galata) gemiler sahnenin konusu (kalkan gemilere bakılır): orada dokunulmaz.
static func italian_ships(n: Node) -> bool:
	return siege_index(n) != Siege.ORDER.find(31)


# ---------------------------------------------------------------- uzak siluet (skyline)

## Uzak siluet: şehrin yedi tepesi ve üstlerindeki kiremit çatılı mahalleler, tepelerin üstünde tanınır yapılar
## (Ayasofya, Havariyun, Pantokrator, Konstantin Sütunu, Bozdoğan Kemeri) ve Galata Kulesi; tek ağ, tek çizim.
## Ortamın üstel pusu 1 km ötesini neredeyse tamamen yutar (ordugâhtan, surlardan şehir görünmüyordu): siluet pusu
## kendisi hesaplar (motorun pusu kapalı), sıcak ve açık tonlu, pustan bir iki kademe koyu kalır (en çok SK_MAX_FOG).
## Sahne ölçeği: NEAR'dan uzakta tepeler yükselir (yedi tepe hissi), anıtlar SK_MON_SCALE katına büyür ve altlarındaki
## tepeyle birlikte kalkar; NEAR..NEAR+RAMP arasında yumuşakça. NEAR'dan yakında köşeler tek noktaya iner (gizlenir),
## asıl model devralır (Ayasofya'nın birleşik ağı NEAR'ın ötesinde gizlenir: iki model üst üste çizilmez). Uzaklık her
## parçanın tabanından ölçülür (UV: taban x, z; UV2.x: taban y; UV2.y: tepe parçası −1, anıt için altındaki tepenin
## yüksekliği). Katı değil (WorldWalk gölgelendirici malzemeyi ve "no_walk"u almaz; uçuşta "soft"), gölge vermez.
const SK_NEAR := 650.0
const SK_RAMP := 500.0
const SK_FAR_K := 0.08
const SK_MAX_FOG := 0.55
const SK_MON_SCALE := 2.3
const SK_SHADER := """
shader_type spatial;
render_mode unshaded, fog_disabled, cull_back, shadows_disabled, depth_draw_opaque;
uniform vec3 fog_col : source_color = vec3(0.8, 0.82, 0.85);
uniform float dens = 0.0024;
uniform float near_d = 650.0;
uniform float ramp = 500.0;
uniform float far_k = 0.08;
uniform float max_fog = 0.55;
uniform float tint = 1.0;
uniform float mon_scale = 2.3;
uniform float hill_amp = 1.3;
uniform float base_fade = 46.0;
uniform float base_haze = 0.95;
varying float f;
varying float rel;
varying float hill;
void vertex() {
	vec3 base = vec3(UV.x, UV2.x, UV.y);
	vec3 cam = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz;
	float d = distance(cam.xz, base.xz);
	float k = smoothstep(near_d, near_d + ramp, d);
	if (d < near_d) {
		VERTEX = vec3(0.0);
	} else if (UV2.y < -0.5) {
		VERTEX.y = base.y + (VERTEX.y - base.y) * k * hill_amp;
	} else {
		VERTEX = base + (VERTEX - base) * (1.0 + (mon_scale - 1.0) * k);
		VERTEX.y += UV2.y * k * hill_amp;
	}
	float e = dens * (near_d + far_k * max(d - near_d, 0.0));
	f = min(1.0 - exp(-e), max_fog);
	rel = VERTEX.y - base.y - (UV2.y < -0.5 ? 0.0 : UV2.y * k * hill_amp);      // anıtın altındaki tepenin yükselişi hariç
	hill = UV2.y < -0.5 ? 1.0 : 0.0;
}
void fragment() {
	// Motorun pusu kapalı (fog_disabled), kendi pusu: rengi pus rengine kendisi karıştırır. Tepenin alt kenarı (tabandan
	// base_fade metre) pusa karışır: tepe havada asılı kahverengi bir leke gibi durmaz; tepe rengi de pus tonuna yaklaşır.
	float lo = 1.0 - smoothstep(0.0, base_fade, rel);
	float ff = clamp(f + (1.0 - f) * lo * base_haze * (0.8 + 0.2 * hill), 0.0, 1.0);
	vec3 c = COLOR.rgb * tint;
	c = mix(c, fog_col, 0.35 + 0.1 * hill);
	ALBEDO = mix(c, fog_col, ff);
}
"""
const SK_BRICK := Color("a2624a")
const SK_LEAD := Color("6e7a8a")
const SK_STONE := Color("b0a088")
const SK_HILL := Color("d2b48a")
const SK_WALLS := [Color("e2cfae"), Color("d6bc96"), Color("e8d8bc"), Color("cdb08c")]
const SK_ROOFS := [Color("c6745a"), Color("b8664c"), Color("d08a66"), Color("b26a50")]
## Yedi tepe: [x, z, yarıçap, sahne yüksekliği] (dünya koordinatı; şehrin kendi arazisi alçak, siluet abartılı)
const SK_HILLS := [
	[-560.0, -1500.0, 120.0, 20.0],      # I: Akropolis, Ayasofya
	[-470.0, -1300.0, 120.0, 24.0],      # II: Konstantin Forumu
	[-390.0, -1120.0, 150.0, 30.0],      # III: Tauri Forumu
	[-330.0, -770.0, 160.0, 32.0],       # IV: Havariyun
	[-575.0, -470.0, 130.0, 28.0],       # V: Pammakaristos
	[-560.0, -140.0, 120.0, 24.0],       # VI: Blakherna'nın yamacı
	[250.0, -450.0, 170.0, 24.0],        # VII: Kseròlophos
]
static var _sk_mat: ShaderMaterial


static func skyline_material() -> ShaderMaterial:
	if _sk_mat == null:
		var sh := Shader.new()
		sh.code = SK_SHADER
		_sk_mat = ShaderMaterial.new()
		_sk_mat.shader = sh
		_sk_mat.set_shader_parameter("near_d", SK_NEAR)
		_sk_mat.set_shader_parameter("ramp", SK_RAMP)
		_sk_mat.set_shader_parameter("far_k", SK_FAR_K)
		_sk_mat.set_shader_parameter("max_fog", SK_MAX_FOG)
		_sk_mat.set_shader_parameter("mon_scale", SK_MON_SCALE)
	return _sk_mat


## Ortamın pusuna uyar (HornWorld her yarım saniyede çağırır): pus rengi, yoğunluğu; gece (koyu pus) kütle koyulaşır.
static func skyline_sync(env: Environment) -> void:
	var m := skyline_material()
	if env == null or not env.fog_enabled:
		m.set_shader_parameter("dens", 0.0)
		return
	m.set_shader_parameter("fog_col", env.fog_light_color)
	m.set_shader_parameter("dens", env.fog_density)
	m.set_shader_parameter("tint", 0.3 if env.fog_light_color.get_luminance() < 0.25 else 1.0)


## Parça, bölgenin oynanış alanındaki HER noktadan SK_NEAR'ın içinde mi: gölgelendirici onu hep tek noktaya indirir (hiç
## görünmez), kurmaya değmez. Ölçüt: alanın en uzak köşesi bile SK_NEAR'ın %90'ından yakın. Yalnız ağır bölgelerde işe
## yarar (alan büyük ve parça yakınsa); alan dışına uçuşta kamera bu eşiği aşabilir, o yüzden %10 pay bırakılır.
static func _sk_never(c: Vector3, keep: Array) -> bool:
	if keep.is_empty():
		return false
	for r: Rect2 in keep:
		for q: Vector2 in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
			if Vector2(c.x - q.x, c.z - q.y).length() > SK_NEAR * 0.9:
				return false
	return true


## Bir noktanın altındaki siluet tepesinin yüksekliği (anıtlar tepeyle birlikte kalkar)
static func _sk_lift(x: float, z: float) -> float:
	var best := 0.0
	for hl: Array in SK_HILLS:
		var rho := Vector2(x - hl[0], z - hl[1]).length() / float(hl[2])
		if rho < 1.0:
			best = maxf(best, float(hl[3]) * sqrt(1.0 - rho * rho))
	return best


## free(x, z, pay): bölümün alanı dışı mı (HornWorld._free). Yalnız dünyada gerçekten duran yapıların silueti kurulur.
static func skyline(parent: Node3D, free: Callable, region: String, keep: Array = []) -> MeshInstance3D:
	var k := MeshKit.new()
	var st := {"uv": PackedVector2Array(), "uv2": PackedVector2Array()}
	var S := Vector3(1.03, 1.02, 1.03)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7071453
	# Yedi tepe: alçak kubbe (sıcak toprak rengi) ve üstünde kat kat kiremit çatılı evler
	for hl: Array in SK_HILLS:
		var hc := Vector3(hl[0], 0, hl[1])
		if not free.call(hc.x, hc.z, 40.0) or _sk_never(hc, keep):
			continue
		var r: float = hl[2]
		var H: float = hl[3]
		var by := World1453.surface_h(hc.x, hc.z) - 3.0
		var i0 := k.v.size()
		k.dome(Transform3D(Basis(), Vector3(hc.x, by, hc.z)), r, SK_HILL, (H + 3.0) / r, 14, 4)
		for q in 70:
			var a := rng.randf() * TAU
			var rho := sqrt(rng.randf()) * 0.9
			var x := hc.x + cos(a) * rho * r
			var z := hc.z + sin(a) * rho * r
			if not free.call(x, z, 6.0):
				continue
			var y := by + (H + 3.0) * sqrt(1.0 - rho * rho)
			var w := rng.randf_range(7.0, 12.0)
			var dd := rng.randf_range(6.0, 10.0)
			var hh := rng.randf_range(4.0, 7.0) + rho * 3.0
			var b := Basis(Vector3.UP, rng.randf() * TAU)
			k.box(Transform3D(b, Vector3(x, y + hh * 0.5 - 1.5, z)), Vector3(w, hh, dd), SK_WALLS[q % SK_WALLS.size()])
			k.gable(Transform3D(b, Vector3(x, y + hh - 1.5, z)), Vector3(w + 0.8, 2.4, dd + 0.8), SK_ROOFS[q % SK_ROOFS.size()])
		_sk_mark(k, st, i0, Vector3(hc.x, by, hc.z), -1.0)
	# Ayasofya (Scenery.hagia_sophia ile aynı ölçüler)
	var ay: Vector3 = World1453.LANDMARKS["ayasofya"]
	if region != "byz_aya" and free.call(ay.x, ay.z, 60.0) and not _sk_never(ay, keep):
		var i0 := k.v.size()
		var p := Vector3(ay.x, HornWorld.east_surf(ay.x, ay.z) - 1.0, ay.z)
		var b := Transform3D(Basis.from_scale(S), p)
		k.box(b * _sk_at(0, 13, 0), Vector3(70, 26, 76), SK_BRICK)
		for q in 4:
			k.box(b * _sk_at((q % 2 - 0.5) * 60.0, 17, (q / 2 - 0.5) * 26.0), Vector3(10, 34, 10), SK_BRICK.darkened(0.08))
		k.cyl(b * _sk_at(0, 33.5, 0), 17.2, 7.2, SK_BRICK.lightened(0.08), 20)
		k.dome(b * _sk_at(0, 40.5, 0), 17.7, SK_LEAD, 0.63, 20, 4)
		for side: float in [-1.0, 1.0]:
			k.cyl(b * _sk_at(0, 26.0, side * 17.0), 16.2, 4.0, SK_LEAD, 16)
			k.dome(b * _sk_at(0, 30.0, side * 17.0), 16.3, SK_LEAD, 0.56, 16, 3)
			for q: float in [-1.0, 1.0]:
				k.dome(b * _sk_at(q * 11.0, 25.0, side * 30.0), 7.3, SK_LEAD, 0.57, 12, 2)
		_sk_mark(k, st, i0, p, _sk_lift(p.x, p.z))
	# Iustinianus Sütunu (Augustaion; atlı heykelin kaba kütlesi)
	var au: Vector3 = World1453.LANDMARKS["augustaion"]
	if region != "byz_aya" and free.call(au.x, au.z, 22.0) and not _sk_never(au, keep):
		var i0 := k.v.size()
		var g := _ground(au, 6.0)
		var p := Vector3(au.x, lerpf(g.x, g.y, 0.6), au.z)
		k.cyl(Transform3D(Basis(), p), 1.5, 31.0, SK_STONE.darkened(0.15), 8)
		k.box(Transform3D(Basis(), p + Vector3(0, 33.0, 0)), Vector3(1.6, 3.0, 4.0), SK_BRICK.darkened(0.2))
		_sk_mark(k, st, i0, p, _sk_lift(p.x, p.z))
	# Havariyun (HornWorld._monuments)
	var ap: Vector3 = World1453.LANDMARKS["apostles"]
	if free.call(ap.x, ap.z, 30.0) and not _sk_never(ap, keep):
		var i0 := k.v.size()
		var c := Vector3(ap.x, HornWorld.east_surf(ap.x, ap.z) - 0.5, ap.z)
		var b := Transform3D(Basis.from_scale(S), c)
		k.box(b * _sk_at(0, 7, 0), Vector3(46, 14, 14), SK_BRICK)
		k.box(b * _sk_at(0, 7, 0), Vector3(14, 14, 46), SK_BRICK)
		for o: Vector3 in [Vector3.ZERO, Vector3(16, 0, 0), Vector3(-16, 0, 0), Vector3(0, 0, 16), Vector3(0, 0, -16)]:
			var r := 6.0 if o == Vector3.ZERO else 4.8
			k.cyl(b * _sk_at(o.x, 14.0, o.z), r + 0.1, 4.0, SK_BRICK.lightened(0.08), 12)
			k.dome(b * _sk_at(o.x, 18.0, o.z), r + 0.4, SK_LEAD, 0.64, 12, 3)
		_sk_mark(k, st, i0, c, _sk_lift(c.x, c.z))
	# Pantokrator (Landmarks1453._pantokrator: üç kilise, narteks)
	var pk: Vector3 = World1453.LANDMARKS["pantokrator"]
	if free.call(pk.x, pk.z, 30.0) and not _sk_never(pk, keep):
		var i0 := k.v.size()
		var g := _ground(pk, 26.0)
		var c := Vector3(pk.x, lerpf(g.x, g.y, 0.6), pk.z)
		var b := Transform3D(Basis.from_scale(S), c)
		for ch: Array in [[-17.5, 30.0, [-3.0], 12.0], [0.0, 26.0, [-5.0, 5.0], 10.0], [17.5, 34.0, [-5.0], 13.0]]:
			var ox: float = ch[0]
			var L: float = ch[1]
			var h: float = ch[3]
			var cz := 16.0 - L * 0.5
			k.box(b * _sk_at(ox, (h + 2.8) * 0.5 - 0.5, cz - 1.0), Vector3(13.8, h + 3.8, L + 2.4), SK_BRICK)
			for dz: float in ch[2]:
				var r := 4.6 if ox != 0.0 else 3.6
				k.cyl(b * _sk_at(ox, h + 1.0, cz + dz), r + 0.2, 4.6, SK_BRICK.lightened(0.08), 10)
				k.dome(b * _sk_at(ox, h + 5.5, cz + dz), r * 1.04 + 0.25, SK_LEAD, 0.64, 10, 3)
		k.box(b * _sk_at(0, 5.0, 19.9), Vector3(49.6, 11.0, 8.6), SK_BRICK.lightened(0.04))
		_sk_mark(k, st, i0, c, _sk_lift(c.x, c.z))
	# Konstantin Sütunu (porfir)
	var col: Vector3 = World1453.LANDMARKS["column"]
	if region != "byz_aya" and free.call(col.x, col.z, 24.0) and not _sk_never(col, keep):
		var i0 := k.v.size()
		var y := HornWorld.east_surf(col.x, col.z)
		k.cyl(Transform3D(Basis(), Vector3(col.x, y - 0.5, col.z)), 3.15, 35.0, Color("8a4a4a"), 8)
		k.box(Transform3D(Basis(), Vector3(col.x, y + 35.5, col.z)), Vector3(0.6, 3.0, 0.6), SK_STONE)
		k.box(Transform3D(Basis(), Vector3(col.x, y + 36.2, col.z)), Vector3(2.0, 0.5, 0.5), SK_STONE)
		_sk_mark(k, st, i0, Vector3(col.x, y - 0.5, col.z), _sk_lift(col.x, col.z))
	# Bozdoğan Kemeri (HornWorld._monuments: ayaklar ve iki kuşak); tepeler arasındaki vadiyi aşar
	var a: Vector3 = World1453.LANDMARKS["aqueduct_a"]
	var e: Vector3 = World1453.LANDMARKS["aqueduct_b"]
	var mid := (a + e) * 0.5
	if free.call(mid.x, mid.z, 6.0) and not _sk_never(mid, keep):
		var i0 := k.v.size()
		var n := int(a.distance_to(e) / 9.0)
		var yb := Basis(Vector3.UP, atan2(e.x - a.x, e.z - a.z))
		for q in n + 1:
			var p := a.lerp(e, float(q) / n)
			if not free.call(p.x, p.z, 6.0):
				continue
			var g := HornWorld.east_surf(p.x, p.z)
			k.box(Transform3D(yb, Vector3(p.x, (20.0 + g) * 0.5 - 1.0, p.z)), Vector3(3.45, 20.0 - g + 2.2, 3.25), SK_STONE)
		for lvl: float in [11.0, 19.5]:
			k.box(Transform3D(yb, Vector3(mid.x, lvl, mid.z)), Vector3(3.6, 1.8, a.distance_to(e) + 3.4), SK_STONE.darkened(0.06))
		_sk_mark(k, st, i0, Vector3(mid.x, HornWorld.east_surf(mid.x, mid.z), mid.z), _sk_lift(mid.x, mid.z))
	# Galata Kulesi (GalataView: gövde, şerefe, külah)
	var tw: Vector3 = World1453.LANDMARKS["galata_tower"]
	if free.call(tw.x, tw.z, 2.0) and not _sk_never(tw, keep):
		var i0 := k.v.size()
		var ty := HornWorld.north_surf(tw.x, tw.z) - 1.0
		var gy := World1453.galata_top(tw) - 1.2
		var base := Transform3D(Basis(), Vector3(tw.x, ty, tw.z))
		k.cyl(base, 4.4, gy + 3.1 - ty, SK_STONE, 12)
		k.cyl(base * _sk_at(0, gy - 1.1 - ty, 0), 5.45, 1.3, SK_STONE.darkened(0.1), 12)
		k.cyl(base * _sk_at(0, gy + 3.0 - ty, 0), 4.6, 7.8, SK_LEAD.darkened(0.15), 12, 0.0)
		_sk_mark(k, st, i0, Vector3(tw.x, ty, tw.z), 0.0)
	if k.is_empty():
		return null
	var arr := front_faces(k.arrays())
	arr[Mesh.ARRAY_TEX_UV] = st["uv"]
	arr[Mesh.ARRAY_TEX_UV2] = st["uv2"]
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var mi := MeshInstance3D.new()
	mi.name = "Skyline"
	mi.mesh = am
	mi.material_override = skyline_material()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Gölgelendirici köşeleri yükseltir ve büyütür: görünürlük kutusu buna yetsin
	mi.extra_cull_margin = 120.0
	mi.set_meta("no_walk", true)
	mi.set_meta("soft", true)
	parent.add_child(mi)
	return mi


## MeshKit üçgenleri dışarıdan saat yönünün tersine dizer; Godot'nun ön yüzü saat yönü (CityStream bu yüzden yüz
## ayıklamayı kapatır). Arka yüz ayıklamalı kendi gölgelendiricilerimiz için her üçgenin iki köşesi yer değiştirir.
static func front_faces(arr: Array) -> Array:
	for a: int in [Mesh.ARRAY_VERTEX, Mesh.ARRAY_NORMAL, Mesh.ARRAY_COLOR]:
		var src = arr[a]
		for i in range(0, src.size() - 2, 3):
			var t = src[i + 1]
			src[i + 1] = src[i + 2]
			src[i + 2] = t
		arr[a] = src
	return arr


static func _sk_at(x: float, y: float, z: float) -> Transform3D:
	return Transform3D(Basis(), Vector3(x, y, z))


## i0'dan bu yana eklenen köşelere parçanın tabanını ve türünü yazar (gölgelendirici uzaklığı parça başına ölçer)
static func _sk_mark(k: MeshKit, st: Dictionary, i0: int, base: Vector3, lift: float) -> void:
	for i in k.v.size() - i0:
		st["uv"].append(Vector2(base.x, base.z))
		st["uv2"].append(Vector2(base.y, lift))


# ---------------------------------------------------------------- gemiler (görünüş)

## Gemi ağları: yerel +z baş, su yüzü y 0; köşe renkli, tek ağ. Tek kurucu: zincirin ardındaki ve iskelelerdeki tüccar
## gemileri, Diplokionion'daki kadırgalar, Haliç'te dolaşan tekneler. Yalnız görünüş (oynanışta kullanılan gemiler
## bölümlerin kendi sahnesindedir, dokunulmaz).
##   carrack_genoa / carrack_venice / carrack: kalın gövdeli nef: kıç ve baş kasarası, iki direk ve kıçta latin direği,
##     şişkin kare yelkenler (Ceneviz: beyaz üstüne kırmızı haç; Venedik: kırmızı-krem şeritler), halatlar, flama
##   galley / galley_ott: uzun alçak kadırga, mahmuzlu baş, kürek dizisi, latin yelken, kıçta köşk, sancak
##   fisher: latin yelkenli balıkçı teknesi; row: kayık ve iki kürekçi
##   "_w" eki: hareket eden tekne (pruvada köpük, kıçta dümen suyu izi)
static var _ships := {}

const SH_TAR := Color("2e241e")
const SH_HULL := Color("5a3e28")
const SH_DECK := Color("9a7a50")
const SH_ROPE := Color("3a3026")
const SH_SAIL := Color("ece4d0")
const SH_FOAM := Color("eef2f2")


static var _ship_mat: StandardMaterial3D


## Gemi malzemesi: köşe renkli, toon; DIŞ ÇİZGİ YOK. (Dressing._material'ın dış çizgisi ters yüz kabuğu çizer: ince çift
## yüzlü yelkenlerde ve kürek çubuklarında uzaktan siyah benekler/lekeler çıkarıyordu: gemiler "koyu küme" gibi okunuyordu.)
static func ship_material() -> StandardMaterial3D:
	if _ship_mat == null:
		_ship_mat = StandardMaterial3D.new()
		_ship_mat.vertex_color_use_as_albedo = true
		_ship_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		_ship_mat.specular_mode = BaseMaterial3D.SPECULAR_TOON
		_ship_mat.roughness = 0.9
		_ship_mat.metallic_specular = 0.2
		_ship_mat.rim_enabled = true
		_ship_mat.rim = 0.2
		_ship_mat.rim_tint = 0.6
	return _ship_mat


static func ship_mesh(kind: String) -> ArrayMesh:
	if _ships.has(kind):
		return _ships[kind]
	var k := MeshKit.new()
	var wake := kind.ends_with("_w")
	var base := kind.trim_suffix("_w")
	var L := 6.0
	match base:
		"carrack_genoa", "carrack_venice", "carrack":
			L = _carrack(k, base)
		"galley", "galley_ott":
			L = _galley(k, base)
		"fisher":
			L = _fisher(k)
		_:
			L = _rowboat(k)
	if wake:
		_wake(k, L)
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, front_faces(k.arrays()))
	_ships[kind] = am
	return am


## Yönlü üçgen: dış yüz out yönüne bakacak sırayla (MeshKit kuralı: dışarıdan saat yönünün tersi)
static func _ot(k: MeshKit, a: Vector3, b: Vector3, c: Vector3, col: Color, out: Vector3) -> void:
	if (b - a).cross(c - a).dot(out) < 0.0:
		k._tri(Transform3D.IDENTITY, a, c, b, col)
	else:
		k._tri(Transform3D.IDENTITY, a, b, c, col)


static func _oq(k: MeshKit, a: Vector3, b: Vector3, c: Vector3, d: Vector3, col: Color, out: Vector3) -> void:
	_ot(k, a, b, c, col, out)
	_ot(k, a, c, d, col, out)


## İki yüzlü üçgen (yelken, flama)
static func _tri2(k: MeshKit, a: Vector3, b: Vector3, c: Vector3, col: Color) -> void:
	k._tri(Transform3D.IDENTITY, a, b, c, col)
	k._tri(Transform3D.IDENTITY, a, c, b, col.darkened(0.1))


## a'dan b'ye kare kesitli çubuk (direk, seren, halat, kürek)
static func _rod(k: MeshKit, a: Vector3, b: Vector3, r: float, col: Color) -> void:
	var up := b - a
	var len := up.length()
	if len < 0.01:
		return
	var y := up / len
	var x := y.cross(Vector3.FORWARD if absf(y.z) < 0.9 else Vector3.RIGHT).normalized()
	var z := x.cross(y)
	k.box(Transform3D(Basis(x * r * 2.0, y * len, z * r * 2.0), (a + b) * 0.5), Vector3.ONE, col)


## Gövde: istasyonlar boyunca (kıçtan başa) yarı genişlik, güverte ve omurga yüksekliği; kuşaklar: alt (katran), gövde,
## boya kuşağı, küpeşte. Döndürür: [güvertenin yüksekliği (orta), istasyonlar [z, w, yt]]
static func _hull(k: MeshKit, L: float, B: float, D: float, T: float, sheer: float, stern_w: float, paint: Color, hull := SH_HULL) -> Array:
	var N := 10
	var st: Array = []
	for i in N + 1:
		var t := float(i) / N
		var z := lerpf(-L * 0.5, L * 0.5, t)
		var w := B * 0.5 * maxf(pow(sin(PI * clampf(t * 0.94 + 0.03, 0.0, 1.0)), 0.6), stern_w * (1.0 - t * 2.0))
		if t >= 1.0:
			w = 0.05
		var yt := D + sheer * pow(absf(t - 0.45) * 2.0, 2.0)
		var yb := -T * (1.0 - pow(absf(t - 0.5) * 2.0, 3.0) * 0.7)
		st.append([z, w, yt, yb])
	for s: float in [-1.0, 1.0]:
		for i in N:
			var p: Array = []
			for j in [i, i + 1]:
				var z: float = st[j][0]
				var w: float = st[j][1]
				var yt: float = st[j][2]
				var yb: float = st[j][3]
				p.append([Vector3(0, yb, z), Vector3(s * w * 0.8, yb * 0.35, z), Vector3(s * w, 0.15, z),
					Vector3(s * w * 1.02, yt * 0.6, z), Vector3(s * w * 0.96, yt, z)])
			var cols := [SH_TAR, SH_TAR.lightened(0.1), hull, paint]
			for b in 4:
				var out := Vector3(s, -0.6 if b == 0 else 0.0, 0)
				_oq(k, p[0][b], p[1][b], p[1][b + 1], p[0][b + 1], cols[b], out)
			# Küpeştenin iç yüzü ve güverte
			var d0 := Vector3(s * (st[i][1] as float) * 0.88, (st[i][2] as float) - 0.35, st[i][0])
			var d1 := Vector3(s * (st[i + 1][1] as float) * 0.88, (st[i + 1][2] as float) - 0.35, st[i + 1][0])
			_oq(k, p[0][4], p[1][4], d1, d0, hull.darkened(0.2), Vector3(-s, 0.3, 0))
			_oq(k, d0, d1, Vector3(0, d1.y, d1.z), Vector3(0, d0.y, d0.z), SH_DECK, Vector3.UP)
	# Kıç aynası ve baş bodoslaması
	var s0: Array = st[0]
	var tr := [Vector3(0, s0[3], s0[0]), Vector3(s0[1] * 0.8, s0[3] * 0.35, s0[0]), Vector3(s0[1], 0.15, s0[0]),
		Vector3(s0[1] * 1.02, s0[2] * 0.6, s0[0]), Vector3(s0[1] * 0.96, s0[2], s0[0])]
	var c0 := Vector3(0, (s0[2] as float) * 0.5, s0[0])
	for s: float in [-1.0, 1.0]:
		for b in 4:
			var a: Vector3 = tr[b] * Vector3(s, 1, 1)
			var e: Vector3 = tr[b + 1] * Vector3(s, 1, 1)
			_ot(k, c0, a, e, hull.darkened(0.1) if b > 1 else SH_TAR, Vector3(0, 0, -1))
		_ot(k, c0, tr[4] * Vector3(s, 1, 1), Vector3(0, s0[2], s0[0]), paint.darkened(0.1), Vector3(0, 0, -1))
	return [(st[5][2] as float) - 0.35, st]


## Şişkin kare yelken: genişlik W, yükseklik H, üst kenarın ortası top, z'de karına doğru şişer (iki yüzlü, ızgara)
static func _square_sail(k: MeshKit, top: Vector3, W: float, H: float, bulge: float, base: Color, pattern: String) -> void:
	var nu := 5
	var nv := 3
	var pt := func(u: int, v: int) -> Vector3:
		var fu := float(u) / nu * 2.0 - 1.0
		var fv := float(v) / nv
		return top + Vector3(fu * W * 0.5 * (1.0 - fv * 0.08), -fv * H, bulge * (1.0 - fu * fu) * sin(fv * PI * 0.9 + 0.15))
	for u in nu:
		for v in nv:
			var col := base
			match pattern:
				"cross":
					if u == 2 or v == 1:
						col = Color("b02028")
				"stripes":
					col = Color("a8242a") if u % 2 == 0 else base
			_tri2(k, pt.call(u, v), pt.call(u + 1, v), pt.call(u + 1, v + 1), col)
			_tri2(k, pt.call(u, v), pt.call(u + 1, v + 1), pt.call(u, v + 1), col)


## Latin yelken: seren a (alt, önde) → b (üst, arkada) boyunca, yelkenin alt köşesi c; ortası şişer
static func _lateen(k: MeshKit, a: Vector3, b: Vector3, c: Vector3, bulge: Vector3, col: Color) -> void:
	var m1 := (a + b) * 0.5
	var m2 := (b + c) * 0.5 + bulge * 0.6
	var m3 := (a + c) * 0.5 + bulge * 0.6
	var mid := (a + b + c) / 3.0 + bulge
	for tri: Array in [[a, m1, mid], [m1, b, mid], [b, m2, mid], [m2, c, mid], [c, m3, mid], [m3, a, mid]]:
		_tri2(k, tri[0], tri[1], tri[2], col)


## Flama: direğin tepesinden rüzgâr yönünde uzun ince üçgen
static func _pennant(k: MeshKit, top: Vector3, len: float, col: Color) -> void:
	_tri2(k, top, top + Vector3(0, -0.7, 0), top + Vector3(0.3, -0.45, -len), col)


static func _carrack(k: MeshKit, kind: String) -> float:
	var L := 24.0
	var paint := Color("b8963e") if kind == "carrack_venice" else (Color("a8242a") if kind == "carrack_genoa" else Color("3e5478"))
	var h := _hull(k, L, 7.4, 3.0, 1.6, 1.6, 0.62, paint)
	var dy: float = h[0]
	# Kıç kasarası (iki kat) ve baş kasarası (üçgen çıkıntı)
	k.box(Transform3D(Basis(), Vector3(0, dy + 1.6, -L * 0.36)), Vector3(6.0, 3.2, 5.6), SH_HULL.lightened(0.05))
	k.box(Transform3D(Basis(), Vector3(0, dy + 3.6, -L * 0.40)), Vector3(5.0, 1.0, 3.8), paint)
	k.box(Transform3D(Basis(), Vector3(0, dy + 1.4, L * 0.36)), Vector3(4.2, 2.4, 4.0), SH_HULL.lightened(0.05))
	k.box(Transform3D(Basis(), Vector3(0, dy + 2.8, L * 0.37)), Vector3(4.4, 0.4, 4.2), paint)
	# Direkler: ana direk, baş direği, kıçta latin direği; serenler
	var main := Vector3(0, dy, 0.5)
	var fore := Vector3(0, dy, L * 0.3)
	var miz := Vector3(0, dy, -L * 0.3)
	_rod(k, main, main + Vector3(0, 19.0, 0), 0.28, SH_HULL.darkened(0.2))
	_rod(k, fore, fore + Vector3(0, 13.0, 0), 0.2, SH_HULL.darkened(0.2))
	_rod(k, miz, miz + Vector3(0, 11.0, 0), 0.18, SH_HULL.darkened(0.2))
	k.cyl(Transform3D(Basis(), main + Vector3(0, 16.5, 0)), 1.0, 1.0, SH_HULL, 8)          # gabya (direk sepeti)
	_rod(k, main + Vector3(-6.0, 15.4, 0.4), main + Vector3(6.0, 15.4, 0.4), 0.14, SH_HULL.darkened(0.25))
	_rod(k, fore + Vector3(-4.0, 11.6, 0.3), fore + Vector3(4.0, 11.6, 0.3), 0.12, SH_HULL.darkened(0.25))
	var pat := "cross" if kind == "carrack_genoa" else ("stripes" if kind == "carrack_venice" else "")
	_square_sail(k, main + Vector3(0, 15.2, 0.6), 11.6, 10.0, 2.2, SH_SAIL, pat)
	_square_sail(k, fore + Vector3(0, 11.4, 0.5), 7.6, 6.6, 1.4, SH_SAIL, "")
	_lateen(k, miz + Vector3(0, 3.0, 3.2), miz + Vector3(0, 12.0, -4.2), miz + Vector3(0, 2.6, -3.6), Vector3(1.0, 0, 0), SH_SAIL.darkened(0.04))
	_rod(k, miz + Vector3(0, 3.0, 3.2), miz + Vector3(0, 12.0, -4.2), 0.1, SH_HULL.darkened(0.25))
	# Cıvadra (bowsprit), halatlar: baş ve kıç istinga, iki yanda çarmıh
	var bow := Vector3(0, dy + 2.6, L * 0.5)
	_rod(k, bow, bow + Vector3(0, 2.4, 6.0), 0.15, SH_HULL.darkened(0.2))
	_rod(k, main + Vector3(0, 18.6, 0), bow + Vector3(0, 2.2, 5.4), 0.05, SH_ROPE)
	_rod(k, main + Vector3(0, 18.6, 0), Vector3(0, dy + 3.8, -L * 0.44), 0.05, SH_ROPE)
	_rod(k, fore + Vector3(0, 12.6, 0), bow + Vector3(0, 2.3, 5.8), 0.04, SH_ROPE)
	for s: float in [-1.0, 1.0]:
		for dz: float in [-1.2, 0.0, 1.2]:
			_rod(k, main + Vector3(0, 16.0, 0), Vector3(s * 3.6, dy + 0.4, 0.5 + dz), 0.04, SH_ROPE)
		_rod(k, fore + Vector3(0, 11.0, 0), Vector3(s * 3.0, dy + 0.4, L * 0.3), 0.04, SH_ROPE)
	# Flama ve sancak
	var flag := Color("ece6d8") if kind == "carrack_genoa" else (Color("a8242a") if kind == "carrack_venice" else Color("2a4a8a"))
	_pennant(k, main + Vector3(0, 19.0, 0), 5.0, flag)
	_pennant(k, Vector3(0, dy + 6.4, -L * 0.42), 2.6, flag)
	if kind == "carrack_genoa":
		_tri2(k, Vector3(0, dy + 5.9, -L * 0.44), Vector3(0, dy + 6.2, -L * 0.44 - 0.5), Vector3(0, dy + 5.6, -L * 0.44 - 1.6), Color("b02028"))
	elif kind == "carrack_venice":
		_tri2(k, Vector3(0, dy + 5.9, -L * 0.44), Vector3(0, dy + 6.2, -L * 0.44 - 0.5), Vector3(0, dy + 5.6, -L * 0.44 - 1.6), Color("d8b040"))
	return L


static func _galley(k: MeshKit, kind: String) -> float:
	var L := 30.0
	var ott := kind == "galley_ott"
	var paint := Color("8a2b22") if ott else Color("2a4a6a")
	var h := _hull(k, L, 4.6, 1.5, 0.8, 0.5, 0.45, paint)
	var dy: float = h[0]
	# Mahmuz (baştaki çıkıntı) ve kıç köşkü
	_rod(k, Vector3(0, 0.9, L * 0.5 - 0.5), Vector3(0, 1.2, L * 0.5 + 4.0), 0.22, SH_HULL.darkened(0.15))
	k.box(Transform3D(Basis(), Vector3(0, dy + 1.1, -L * 0.38)), Vector3(3.6, 2.2, 4.2), paint.lightened(0.1))
	k.box(Transform3D(Basis(), Vector3(0, dy + 2.35, -L * 0.38)), Vector3(4.0, 0.3, 4.6), paint.darkened(0.1))
	# Kürekler: iki yanda 12'şer, suya eğik
	for s: float in [-1.0, 1.0]:
		for q in 12:
			var z := -L * 0.3 + q * (L * 0.6 / 11.0)
			_rod(k, Vector3(s * 1.6, dy + 0.5, z), Vector3(s * 7.4, -0.4, z - 0.8), 0.06, SH_DECK.darkened(0.25))
	# Direk, latin seren ve yelken, sancak
	var m := Vector3(0, dy, L * 0.12)
	_rod(k, m, m + Vector3(0, 13.0, 0), 0.2, SH_HULL.darkened(0.2))
	var ya := m + Vector3(0, 3.0, 9.0)
	var yb := m + Vector3(0, 16.0, -9.5)
	_rod(k, ya, yb, 0.12, SH_HULL.darkened(0.25))
	_lateen(k, ya, yb, m + Vector3(0, 2.4, -7.0), Vector3(1.4, 0, 0), SH_SAIL if not ott else Color("efe6d2"))
	_rod(k, m + Vector3(0, 12.6, 0), Vector3(0, dy + 1.0, L * 0.47), 0.04, SH_ROPE)
	_rod(k, m + Vector3(0, 12.6, 0), Vector3(0, dy + 1.0, -L * 0.42), 0.04, SH_ROPE)
	_pennant(k, m + Vector3(0, 13.0, 0), 4.5, Color("c8262f") if ott else Color("ece6d8"))
	_pennant(k, Vector3(0, dy + 4.2, -L * 0.44), 2.4, Color("c8262f") if ott else Color("a8242a"))
	_rod(k, Vector3(0, dy + 2.4, -L * 0.44), Vector3(0, dy + 4.3, -L * 0.44), 0.05, SH_HULL)
	return L


static func _fisher(k: MeshKit) -> float:
	var L := 8.0
	var h := _hull(k, L, 2.4, 0.9, 0.5, 0.4, 0.4, Color("3e6a5a"))
	var dy: float = h[0]
	var m := Vector3(0, dy, 1.2)
	_rod(k, m, m + Vector3(0, 6.5, 0), 0.08, SH_HULL.darkened(0.2))
	var ya := m + Vector3(0, 1.0, 3.4)
	var yb := m + Vector3(0, 7.6, -3.4)
	_rod(k, ya, yb, 0.06, SH_HULL.darkened(0.25))
	_lateen(k, ya, yb, m + Vector3(0, 0.7, -2.8), Vector3(0.7, 0, 0), SH_SAIL.darkened(0.06))
	k.box(Transform3D(Basis(), Vector3(0, dy + 0.5, -2.2)), Vector3(0.45, 0.9, 0.35), Color("94382c"))
	k.box(Transform3D(Basis(), Vector3(0, dy + 1.1, -2.2)), Vector3(0.3, 0.3, 0.3), Color("d8b090"))
	k.box(Transform3D(Basis(), Vector3(0.4, dy + 0.2, -0.6)), Vector3(0.9, 0.3, 0.9), Color("7a6a50"))      # ağ yığını
	return L


static func _rowboat(k: MeshKit) -> float:
	var L := 5.6
	var h := _hull(k, L, 1.7, 0.6, 0.35, 0.25, 0.5, Color("7a5a3a"))
	var dy: float = h[0]
	for z: float in [-0.9, 0.9]:
		k.box(Transform3D(Basis(), Vector3(0, dy + 0.5, z)), Vector3(0.45, 0.9, 0.35), Color("7a4a32") if z < 0.0 else Color("3e5478"))
		k.box(Transform3D(Basis(), Vector3(0, dy + 1.1, z)), Vector3(0.3, 0.3, 0.3), Color("d8b090"))
		for s: float in [-1.0, 1.0]:
			_rod(k, Vector3(s * 0.7, dy + 0.5, z), Vector3(s * 2.6, -0.3, z - 0.3), 0.05, SH_DECK.darkened(0.2))
	return L


## Hareket eden teknenin köpüğü: pruvada iki yana açılan bıyık, kıçta uzayan dümen suyu (su yüzünün hemen üstünde)
static func _wake(k: MeshKit, L: float) -> void:
	var y := 0.06
	var bz := L * 0.5
	for s: float in [-1.0, 1.0]:
		_ot(k, Vector3(0, y, bz + 0.3), Vector3(s * L * 0.12, y, bz - L * 0.25), Vector3(s * L * 0.22, y, bz - L * 0.55), SH_FOAM, Vector3.UP)
	# Kıçta dümen suyu: eskiden tek parça, 2,2 gemi boyunda düz beyaz bir bıçak (uzaktan suyun üstünde yatık beyaz "T"/bıçak
	# gibi okunuyordu). Şimdi kopuk köpük yamaları: ortada üç küçülen leke, iki yanda açılan "V" izinin kesik parçaları
	var sz := -L * 0.5
	var foam := Color("e2eaeb")
	for i in 3:
		var z0 := sz - 0.05 * L - i * 0.38 * L
		var hw := L * 0.07 * (1.0 - i * 0.25)
		_oq(k, Vector3(-hw, y, z0), Vector3(hw, y, z0), Vector3(hw * 0.8, y, z0 - 0.28 * L), Vector3(-hw * 0.8, y, z0 - 0.28 * L), foam.darkened(0.03 * i), Vector3.UP)
	for sd: float in [-1.0, 1.0]:
		for i in 4:
			var t0 := 0.15 + i * 0.5
			var t1 := t0 + 0.3
			var x0 := sd * L * (0.08 + 0.11 * t0)
			var x1 := sd * L * (0.08 + 0.11 * t1)
			var w := L * 0.018 * (1.0 + i * 0.2)
			_oq(k, Vector3(x0 - w, y, sz - t0 * L), Vector3(x0 + w, y, sz - t0 * L), Vector3(x1 + w, y, sz - t1 * L), Vector3(x1 - w, y, sz - t1 * L), foam.darkened(0.04 * i), Vector3.UP)


# ---------------------------------------------------------------- Haliç kıyısı (alçak rıhtım + toprak yamaç)
## Şehir kıyı suru yamacın tepesinde durur; sudan surun dibine kadar inen yamaç artık taş kaplı değil:
##   · su çizgisinde alçak (≈2 m) taş rıhtım: ıslak koyu taş, yosun bandı, sıra taş; üstünde dar rıhtım yolu (bağlama
##     babaları, fıçı, sandık, balya, ağ, balıkçı barakası, çekili kayık), aralıklarla suya inen basamaklar
##   · rıhtımın üstü toprak ve kaya: köşe renkli (toprak, kuru ot, zeytin, yeşil) kaplama, kaya, çalı, servi, incir,
##     bostan sekileri (istinat duvarı + tarla), surdaki kapılara ve yan kapılara tırmanan patikalar ve taş merdivenler
## Hepsi görünüş: arazi yüksekliği ve çarpışma değişmez (düğümler no_walk). 240 m'lik parça başına tek köşe renkli ağ.

const SH_STEP := 15.0           # çizgi aralığı (z)
const SH_Q := 4.5               # rıhtım yolunun genişliği
const SH_OFF := 0.6             # kaplama arazinin üstünde (uzakta derinlik çakışması olmasın)
const SH_WALL_X := -701.5       # kıyı surunun dış yüzü
const SH_RIB := [0.0, 0.14, 0.3, 0.48, 0.66, 0.84, 1.0]
const QY_BLOCK := [Color("8c826b"), Color("7d735d"), Color("968c75"), Color("71694e"), Color("857a61"), Color("a0967d")]
const QY_MOSS := Color("4e5c32")
const QY_WET := Color("393e34")
const SH_SOIL := Color("7a6746")
const SH_DRY := Color("8c8052")
const SH_OLIVE := Color("6c733f")
const SH_GREEN := Color("557039")
const SH_ROCK := Color("9a9282")
const SH_CLAY := Color("89613f")


static func _sh_hash(x: float, z: float) -> float:
	return fposmod(sin(x * 12.9898 + z * 78.233) * 43758.5453, 1.0)


static func _sh_color(x: float, z: float, rel: float, steep: float) -> Color:
	var n := 0.5 + 0.2 * sin(z * 0.043 + x * 0.11) + 0.2 * sin(z * 0.017 - x * 0.07 + 2.1) + 0.15 * sin(z * 0.11 + x * 0.05)
	var m := 0.5 + 0.5 * sin(z * 0.13 + x * 0.21 + 0.7)
	var c := SH_SOIL.lerp(SH_CLAY, (1.0 - smoothstep(0.0, 0.2, n - 0.2)))
	c = c.lerp(SH_DRY, smoothstep(0.3, 0.45, n))
	c = c.lerp(SH_OLIVE, smoothstep(0.5, 0.62, n))
	c = c.lerp(SH_GREEN, smoothstep(0.62, 0.78, n) * (1.0 - 0.5 * rel))
	if (steep > 0.55 and m > 0.45) or m > 0.86:
		c = c.lerp(SH_ROCK, 0.7)
	var j := _sh_hash(x, z)
	return c.darkened(0.1 * j).lightened(0.05 * (1.0 - j))


## Su çizgisinin x'i (z'deki arazi suyun altından üstüne çıktığı yer); yoksa INF
static func shore_xw(z: float, sea_y: float, vis: Callable) -> float:
	var x := -770.0
	if float(vis.call(x, z)) > sea_y + 0.02:
		return -770.0
	while x < -703.0:
		var x2 := minf(x + 3.0, -702.0)
		if float(vis.call(x2, z)) > sea_y + 0.02:
			var lo := x
			var hi := x2
			for _j in 5:
				var mid := (lo + hi) * 0.5
				if float(vis.call(mid, z)) > sea_y + 0.02:
					hi = mid
				else:
					lo = mid
			return hi
		x = x2
	return INF


## i. çizgi (z = z_top − 15 i): su çizgisi, rıhtım yolu yüksekliği, yamaç kaplamasının köşeleri ve renkleri
static func shore_line(i: int, z_top: float, sea_y: float, vis: Callable, cache: Dictionary) -> Dictionary:
	if cache.has(i):
		return cache[i]
	var z := z_top - SH_STEP * i
	var r := {"z": z, "ok": false}
	var xw := shore_xw(z, sea_y, vis)
	if xw > -758.0 and xw < SH_WALL_X - 6.0:
		var xf := xw + 0.1
		var xb := xf + clampf((SH_WALL_X - xw) * 0.4, 2.2, SH_Q)      # dar kıyıda (surun dibine 6-11 m) rıhtım yolu da daralır
		var ys := 0.0
		for dz: float in [-7.5, 0.0, 7.5]:
			ys += float(vis.call(xb, z + dz))
		var yq := clampf(ys / 3.0 + 0.1, sea_y + 1.5, sea_y + 2.4)
		var rib := PackedVector3Array()
		var rc := PackedColorArray()
		var x_end := SH_WALL_X - 0.1
		for c in SH_RIB.size():
			var x := lerpf(xb, x_end, float(SH_RIB[c]))
			var y := float(vis.call(x, z)) + SH_OFF
			if c == 0:
				y = maxf(y, yq)
			rib.append(Vector3(x, y, z))
		for c in rib.size():
			var c2 := mini(c + 1, rib.size() - 1)
			var c1 := c2 - 1 if c == rib.size() - 1 else c
			var steep := (rib[c2].y - rib[c1].y) / maxf(rib[c2].x - rib[c1].x, 0.1)
			rc.append(_sh_color(rib[c].x, z, float(SH_RIB[c]), steep))
		r = {"z": z, "ok": true, "xw": xw, "xf": xf, "xb": xb, "yq": yq, "rib": rib, "rc": rc}
	cache[i] = r
	return r


static func _sh_tri(k: MeshKit, a: Vector3, b: Vector3, c: Vector3, ca: Color, cb: Color, cc: Color, out: Vector3) -> void:
	var nn := (b - a).cross(c - a)
	if nn.length_squared() < 1e-9:
		return
	if nn.dot(out) < 0.0:
		var t := b
		b = c
		c = t
		var tc := cb
		cb = cc
		cc = tc
		nn = -nn
	nn = nn.normalized()
	k.v.append(a)
	k.v.append(b)
	k.v.append(c)
	for q in 3:
		k.n.append(nn)
	k.c.append(ca)
	k.c.append(cb)
	k.c.append(cc)


static func _sh_quad(k: MeshKit, a: Vector3, b: Vector3, c: Vector3, d: Vector3, ca: Color, cb: Color, cc: Color, cd: Color, out: Vector3) -> void:
	_sh_tri(k, a, b, c, ca, cb, cc, out)
	_sh_tri(k, a, c, d, ca, cc, cd, out)


static func _sh_flat(k: MeshKit, a: Vector3, b: Vector3, c: Vector3, col: Color, ctr: Vector3) -> void:
	_sh_tri(k, a, b, c, col, col, col, (a + b + c) / 3.0 - ctr)


## Düzensiz kaya: taban halkası, orta halka, tepe (15 üçgen)
static func _sh_rock(k: MeshKit, p: Vector3, r: float, h: float, col: Color, rng: RandomNumberGenerator) -> void:
	var n := 5
	var base: Array[Vector3] = []
	var mid: Array[Vector3] = []
	var a0 := rng.randf() * TAU
	for i in n:
		var a := a0 + TAU * i / n + rng.randf_range(-0.25, 0.25)
		var rr := r * rng.randf_range(0.8, 1.2)
		base.append(p + Vector3(cos(a) * rr, -0.4, sin(a) * rr))
		mid.append(p + Vector3(cos(a + 0.3) * rr * 0.62, h * rng.randf_range(0.55, 0.8), sin(a + 0.3) * rr * 0.62))
	var apex := p + Vector3(rng.randf_range(-0.2, 0.2) * r, h, rng.randf_range(-0.2, 0.2) * r)
	var ctr := p + Vector3(0, h * 0.4, 0)
	for i in n:
		var j := (i + 1) % n
		var cc := col.lightened(rng.randf_range(-0.08, 0.08))
		_sh_flat(k, base[i], base[j], mid[j], cc, ctr)
		_sh_flat(k, base[i], mid[j], mid[i], cc, ctr)
		_sh_flat(k, mid[i], mid[j], apex, col.lightened(0.12 + rng.randf() * 0.06), ctr)


## Çalı / ağaç tepesi / servi: taban halkası (r0), orta halka (r1, yükseklik h·mid), tepe (15 üçgen)
static func _sh_blob(k: MeshKit, p: Vector3, r0: float, r1: float, h: float, mid: float, col: Color, rng: RandomNumberGenerator) -> void:
	var n := 5
	var a0 := rng.randf() * TAU
	var base: Array[Vector3] = []
	var ring: Array[Vector3] = []
	for i in n:
		var a := a0 + TAU * i / n
		base.append(p + Vector3(cos(a) * r0, -0.1, sin(a) * r0))
		ring.append(p + Vector3(cos(a + 0.2) * r1, h * mid, sin(a + 0.2) * r1))
	var apex := p + Vector3(0, h, 0)
	var ctr := p + Vector3(0, h * 0.35, 0)
	for i in n:
		var j := (i + 1) % n
		var cc := col.lightened(rng.randf_range(-0.05, 0.05))
		_sh_flat(k, base[i], base[j], ring[j], cc.darkened(0.08), ctr)
		_sh_flat(k, base[i], ring[j], ring[i], cc.darkened(0.08), ctr)
		_sh_flat(k, ring[i], ring[j], apex, cc.lightened(0.08), ctr)


## Yamaç kaplamasının (i. ve i+1. çizgi) herhangi bir noktasındaki yüksekliği: f çizgiler arası (0 = üst, 1 = alt), u sütun (0..1)
static func _sh_rib_at(L0: Dictionary, L1: Dictionary, f: float, u: float) -> Vector3:
	var rb0: PackedVector3Array = L0.rib
	var rb1: PackedVector3Array = L1.rib
	var s := clampf(u, 0.0, 1.0) * (rb0.size() - 1)
	var c := mini(int(s), rb0.size() - 2)
	var t := s - c
	var p0 := rb0[c].lerp(rb0[c + 1], t)
	var p1 := rb1[c].lerp(rb1[c + 1], t)
	return p0.lerp(p1, f)


## Patika: kıyı yolundan surdaki kapıya iki viraj ve son 11 m taş merdiven. wide: ana kapı (geniş merdiven)
static func _sh_path(k: MeshKit, zg: float, sgn: float, wide: bool, L: Dictionary, vis: Callable) -> void:
	var xe := SH_WALL_X - 0.15
	var xb: float = L.xb
	var pts: Array[Vector2] = [Vector2(xb + 0.4, zg + 8.0 * sgn), Vector2(lerpf(xb, xe, 0.38), zg - 8.0 * sgn), Vector2(lerpf(xb, xe, 0.7), zg + 6.0 * sgn), Vector2(xe - 11.5, zg)]
	var up := Vector3(0, SH_OFF + 0.3, 0)
	var hw := 0.9
	var prev_l := Vector3.ZERO
	var prev_r := Vector3.ZERO
	var have := false
	var pi_ := 0
	for li in pts.size() - 1:
		var a := pts[li]
		var b := pts[li + 1]
		var dir := (b - a).normalized()
		var nrm := Vector2(-dir.y, dir.x)
		var steps := maxi(2, int(a.distance_to(b) / 3.0))
		for s in steps + (1 if li == pts.size() - 2 else 0):
			var q := a.lerp(b, float(s) / steps)
			var yl := float(vis.call(q.x + nrm.x * hw, q.y + nrm.y * hw))
			var yr := float(vis.call(q.x - nrm.x * hw, q.y - nrm.y * hw))
			var pl := Vector3(q.x + nrm.x * hw, yl, q.y + nrm.y * hw) + up
			var pr := Vector3(q.x - nrm.x * hw, yr, q.y - nrm.y * hw) + up
			if have:
				var col := Color("a79975").darkened(0.05 * (pi_ % 3)).lightened(0.02 * (pi_ % 2))
				_sh_quad(k, prev_l, prev_r, pr, pl, col, col, col, col, Vector3.UP)
				pi_ += 1
			prev_l = pl
			prev_r = pr
			have = true
	# Taş merdiven: x ekseni boyunca, 1,05 m'lik basamaklar (açık tırabzan, koyu yükselti)
	var sw := 1.8 if wide else 1.25
	var x := xe - 11.5
	var j := 0
	while x < xe - 0.05:
		var x1 := minf(x + 1.05, xe)
		var ya := float(vis.call(x, zg)) + SH_OFF + 0.35
		var yb := float(vis.call(x1, zg)) + SH_OFF + 0.35
		var tc := Color("9d947d") if j % 2 == 0 else Color("847d67")
		_sh_quad(k, Vector3(x, ya, zg + sw), Vector3(x1 - 0.14, yb - 0.1, zg + sw), Vector3(x1 - 0.14, yb - 0.1, zg - sw), Vector3(x, ya, zg - sw), tc, tc, tc, tc, Vector3.UP)
		_sh_quad(k, Vector3(x1 - 0.14, yb - 0.1, zg + sw), Vector3(x1, yb, zg + sw), Vector3(x1, yb, zg - sw), Vector3(x1 - 0.14, yb - 0.1, zg - sw), Color("4e483c"), Color("4e483c"), Color("4e483c"), Color("4e483c"), Vector3.UP)
		x = x1
		j += 1


## Rıhtım yolundaki küçük yük/eşya öbeği; p: rıhtım yolunun üstü (y = yol yüzü)
static func _sh_cluster(k: MeshKit, kind: int, p: Vector3, rng: RandomNumberGenerator) -> void:
	match kind:
		0:     # fıçılar
			for q in 2 + rng.randi() % 2:
				var o := Vector3(rng.randf_range(-0.9, 0.9), 0, rng.randf_range(-1.1, 1.1))
				k.cyl(Transform3D(Basis(), p + o), 0.4, 0.85, Color("7a5534").darkened(rng.randf_range(0.0, 0.2)), 6, 0.34)
		1:     # sandıklar
			for q in 2:
				var o := Vector3(rng.randf_range(-0.8, 0.8), 0.4, rng.randf_range(-1.0, 1.0))
				k.box(Transform3D(Basis(Vector3.UP, rng.randf() * 1.2), p + o), Vector3(0.85, 0.8, 0.85), Color("89693c").darkened(rng.randf_range(0.0, 0.15)))
			_sh_blob(k, p + Vector3(0.6, 0, 1.2), 0.5, 0.45, 0.7, 0.55, Color("c8b989"), rng)
		2:     # balyalar
			for q in 2:
				var o := Vector3(rng.randf_range(-0.6, 0.6), 0.35 + 0.65 * q, rng.randf_range(-0.4, 0.4))
				k.box(Transform3D(Basis(Vector3.UP, rng.randf_range(-0.2, 0.2)), p + o), Vector3(1.3, 0.65, 0.9), Color("b7a05f").darkened(0.06 * q))
		3:     # ağ yığını ve şamandıra
			var cc := Color("6b7a57")
			k.box(Transform3D(Basis(Vector3.UP, rng.randf() * 0.5), p + Vector3(0, 0.18, 0)), Vector3(1.7, 0.36, 1.2), cc)
			k.box(Transform3D(Basis(Vector3.UP, 0.4), p + Vector3(0.5, 0.45, 0.2)), Vector3(0.35, 0.3, 0.35), Color("af492f"))
		_:
			pass


## Balıkçı barakası: rıhtım yolunun gerisinde, kapısı suya bakar
static func _sh_hut(k: MeshKit, p: Vector3, rng: RandomNumberGenerator) -> void:
	var wall := [Color("997a50"), Color("d2c5a7"), Color("a7895f")][rng.randi() % 3] as Color
	var roof := [Color("995a3c"), Color("897a48")][rng.randi() % 2] as Color
	k.box(Transform3D(Basis(), p + Vector3(0, 1.1, 0)), Vector3(3.0, 2.2, 3.8), wall)
	k.gable(Transform3D(Basis(Vector3.UP, PI * 0.5), p + Vector3(0, 2.2, 0)), Vector3(4.4, 1.1, 3.6), roof)
	var dc := Color("392a1b")
	_sh_quad(k, p + Vector3(-1.53, 0, 0.55), p + Vector3(-1.53, 0, -0.55), p + Vector3(-1.53, 1.8, -0.55), p + Vector3(-1.53, 1.8, 0.55), dc, dc, dc, dc, Vector3(-1, 0, 0))


## Bir 240 m'lik parçanın rıhtım + yamaç ağı. segs: segment sıraları (i: i. ve i+1. çizgi arası). vis(x, z): görünen arazi yüksekliği.
## sfree(x, z): oynanış alanı dışında mı; qfree: su kenarındaki eşya/kayık için (kayıkla oynanan bölge 500 m'si hariç).
## avoid: yan kapı açılmayacak z'ler (kuleler, ana kapılar, iskeleler); piers: iskelelerin z'si (yanlarına eşya konmaz); gates: ana kapı açıklıklarının z'si. boats: {"row": [], "fisher": []}
static func shore_mesh(segs: Array, z_top: float, sea_y: float, vis: Callable, sfree: Callable, qfree: Callable, avoid: Array, piers: Array, gates: Array, cache: Dictionary, boats: Dictionary) -> ArrayMesh:
	var k := MeshKit.new()
	var okc := {}
	var seg_ok := func(j: int) -> bool:
		if okc.has(j):
			return okc[j]
		var a := shore_line(j, z_top, sea_y, vis, cache)
		var b := shore_line(j + 1, z_top, sea_y, vis, cache)
		var v: bool = bool(a.ok) and bool(b.ok) and bool(sfree.call(-715.0, (float(a.z) + float(b.z)) * 0.5))
		okc[j] = v
		return v
	var row_bb := Landmarks1453.ship_mesh("row").get_aabb()
	for j: int in segs:
		if not seg_ok.call(j):
			continue
		var L0 := shore_line(j, z_top, sea_y, vis, cache)
		var L1 := shore_line(j + 1, z_top, sea_y, vis, cache)
		var z0: float = L0.z
		var z1: float = L1.z
		var zc := (z0 + z1) * 0.5
		var rng := RandomNumberGenerator.new()
		rng.seed = 7700 + j * 31
		var xf0: float = L0.xf
		var xf1: float = L1.xf
		var xb0: float = L0.xb
		var xb1: float = L1.xb
		var yq0: float = L0.yq
		var yq1: float = L1.yq
		var NX := Vector3(-1, 0, 0)
		# --- rıhtım yüzü: ıslak taş, yosun, 1-2 sıra kesme taş
		var lv := func(L: Dictionary, r: int, st: int) -> float:
			var yq: float = L.yq
			match r:
				0: return sea_y - 0.5
				1: return sea_y + 0.55
				2: return sea_y + 1.1
				_:
					return lerpf(sea_y + 1.1, yq, float(r - 2) / float(st))
		var stone_rows := 2 if (yq0 + yq1) * 0.5 - sea_y - 1.1 > 1.0 else 1
		var row_cnt := 2 + stone_rows
		for r in row_cnt:
			var f := 0.0
			var nb := 2 if r == 0 else (3 if r == 1 else 4)
			var off := 0.5 if r >= 3 else 0.0
			while f < 0.999:
				var f2 := minf(f + (1.0 / nb) * rng.randf_range(0.8, 1.2) + (off * 0.5 / nb if f == 0.0 and off > 0.0 else 0.0), 1.0)
				if 1.0 - f2 < 0.12:
					f2 = 1.0
				var col: Color
				if r == 0:
					col = QY_WET.lightened(rng.randf_range(-0.04, 0.05))
				elif r == 1:
					col = QY_MOSS.lerp(QY_WET, rng.randf_range(0.0, 0.5)).lightened(rng.randf_range(-0.03, 0.06))
				else:
					col = (QY_BLOCK[rng.randi() % QY_BLOCK.size()] as Color).darkened(rng.randf_range(0.0, 0.05) + 0.03 * (r - 2))
				var xa := lerpf(xf0, xf1, f)
				var xbb := lerpf(xf0, xf1, f2)
				var ya0 := lerpf(float(lv.call(L0, r, stone_rows)), float(lv.call(L1, r, stone_rows)), f)
				var ya1 := lerpf(float(lv.call(L0, r + 1, stone_rows)), float(lv.call(L1, r + 1, stone_rows)), f)
				var yb0 := lerpf(float(lv.call(L0, r, stone_rows)), float(lv.call(L1, r, stone_rows)), f2)
				var yb1 := lerpf(float(lv.call(L0, r + 1, stone_rows)), float(lv.call(L1, r + 1, stone_rows)), f2)
				var za := lerpf(z0, z1, f)
				var zb := lerpf(z0, z1, f2)
				_sh_quad(k, Vector3(xa, ya0, za), Vector3(xbb, yb0, zb), Vector3(xbb, yb1, zb), Vector3(xa, ya1, za), col, col, col, col, NX)
				f = f2
		# köpük çizgisi (su kenarı)
		var foam := Color("eef2f2").darkened(0.03 * (j % 3))
		var fw := 1.2 + 0.5 * (j % 2)
		_sh_quad(k, Vector3(xf0 - fw, sea_y + 0.06, z0), Vector3(xf1 - fw, sea_y + 0.06, z1), Vector3(xf1 - 0.05, sea_y + 0.06, z1), Vector3(xf0 - 0.05, sea_y + 0.06, z0), foam, foam, foam, foam, Vector3.UP)
		# --- rıhtım yolu: kenar taşı (açık) ve toprak-taş yol
		var cp := Color("aaa087").darkened(0.04 * (j % 3))
		_sh_quad(k, Vector3(xf0, yq0, z0), Vector3(xf1, yq1, z1), Vector3(xf1 + 0.55, yq1, z1), Vector3(xf0 + 0.55, yq0, z0), cp, cp, cp, cp, Vector3.UP)
		var xmid0 := xf0 + 0.55 + (xb0 - xf0 - 0.55) * 0.5
		var xmid1 := xf1 + 0.55 + (xb1 - xf1 - 0.55) * 0.5
		var rd := Color("8e8466").darkened(0.05 * ((j + 1) % 3))
		var rd2 := Color("847a5d").darkened(0.05 * (j % 2))
		_sh_quad(k, Vector3(xf0 + 0.55, yq0, z0), Vector3(xf1 + 0.55, yq1, z1), Vector3(xmid1, yq1, z1), Vector3(xmid0, yq0, z0), rd, rd, rd, rd, Vector3.UP)
		_sh_quad(k, Vector3(xmid0, yq0, z0), Vector3(xmid1, yq1, z1), Vector3(xb1, yq1, z1), Vector3(xb0, yq0, z0), rd2, rd2, rd2, rd2, Vector3.UP)
		# rıhtım ucu (komşu parça yoksa kapat)
		for side in 2:
			var nj := j - 1 if side == 0 else j + 1
			if nj >= 0 and seg_ok.call(nj):
				continue
			var Lc := L0 if side == 0 else L1
			var cz: float = Lc.z
			var yb_c := minf(float(vis.call(float(Lc.xb), cz)) - 0.3, float(Lc.yq) - 0.2)
			var oz := Vector3(0, 0, 1.0 if side == 0 else -1.0)
			var cs := QY_BLOCK[0] as Color
			_sh_quad(k, Vector3(float(Lc.xf), sea_y - 0.4, cz), Vector3(float(Lc.xb), yb_c, cz), Vector3(float(Lc.xb), float(Lc.yq), cz), Vector3(float(Lc.xf), float(Lc.yq), cz), cs, cs, cs, cs, oz)
		# --- rıhtım yolunun gerisi: istinat (yamaç yoldan yüksekse) ve yamaç kaplaması
		var rb0: PackedVector3Array = L0.rib
		var rb1: PackedVector3Array = L1.rib
		var rc0: PackedColorArray = L0.rc
		var rc1: PackedColorArray = L1.rc
		if rb0[0].y > yq0 + 0.1 or rb1[0].y > yq1 + 0.1:
			var rcol := (QY_BLOCK[(j * 7) % QY_BLOCK.size()] as Color).darkened(0.12)
			_sh_quad(k, Vector3(xb0, yq0, z0), Vector3(xb1, yq1, z1), Vector3(xb1, rb1[0].y, z1), Vector3(xb0, rb0[0].y, z0), rcol, rcol, rcol, rcol, NX)
		for c in rb0.size() - 1:
			_sh_quad(k, rb0[c], rb0[c + 1], rb1[c + 1], rb1[c], rc0[c], rc0[c + 1], rc1[c + 1], rc1[c], Vector3.UP)
		# --- bostan sekisi: üç çizgilik gruplarda istinat duvarı ve tarla
		var grp := int(floor(j / 3.0))
		if _sh_hash(grp * 1.7, 31.0) < 0.5:
			var ci := 2 + int(_sh_hash(grp * 3.1, 5.0) * 3.0)
			var A0 := rb0[ci]
			var A1 := rb1[ci]
			var bw := minf(3.2, SH_WALL_X - 0.4 - A0.x)
			if bw > 1.5:
				var sc := (QY_BLOCK[(grp * 3) % QY_BLOCK.size()] as Color).lightened(0.06)
				var hh := 1.1
				_sh_quad(k, A0 + Vector3(0, -0.4, 0), A1 + Vector3(0, -0.4, 0), A1 + Vector3(0, hh, 0), A0 + Vector3(0, hh, 0), sc, sc, sc, sc, NX)
				var bc := Color("6b5a39") if grp % 2 == 0 else Color("5c7135")
				var B0 := Vector3(A0.x + bw, maxf(A0.y + hh, float(vis.call(A0.x + bw, z0)) + SH_OFF + 0.05), z0)
				var B1 := Vector3(A1.x + bw, maxf(A1.y + hh, float(vis.call(A1.x + bw, z1)) + SH_OFF + 0.05), z1)
				_sh_quad(k, A0 + Vector3(0, hh, 0), A1 + Vector3(0, hh, 0), B1, B0, bc, bc, bc, bc, Vector3.UP)
		# --- yan kapı (poterne) ve patika
		var path_here := false
		for gz: float in gates:
			if gz <= z0 and gz > z1:
				path_here = true
				_sh_path(k, gz, 1.0 if _sh_hash(gz, 3.0) > 0.5 else -1.0, true, shore_line(int(round((z_top - gz) / SH_STEP)), z_top, sea_y, vis, cache), vis)
		if not path_here and j % 7 == 3:
			var near := false
			for az: float in avoid:
				near = near or absf(az - zc) < 15.0
			if not near:
				path_here = true
				_sh_path(k, zc, 1.0 if j % 2 == 0 else -1.0, false, L0, vis)
				var dy := float(vis.call(SH_WALL_X, zc)) + SH_OFF
				var dx := SH_WALL_X - 0.12
				var fr := Color("8c826b")
				_sh_quad(k, Vector3(dx, dy, zc + 1.4), Vector3(dx, dy, zc - 1.4), Vector3(dx, dy + 3.0, zc - 1.4), Vector3(dx, dy + 3.0, zc + 1.4), fr, fr, fr, fr, NX)
				var dk := Color("25201b")
				_sh_quad(k, Vector3(dx - 0.05, dy, zc + 0.95), Vector3(dx - 0.05, dy, zc - 0.95), Vector3(dx - 0.05, dy + 2.4, zc - 0.95), Vector3(dx - 0.05, dy + 2.4, zc + 0.95), dk, dk, dk, dk, NX)
		# --- suya inen basamaklar (rıhtım yüzünde, öne doğru)
		var pier_near := false
		for ppz: float in piers:
			pier_near = pier_near or absf(ppz - zc) < 14.0
		if j % 9 == 5 and not pier_near and bool(qfree.call(xf0, zc)):
			var sz := zc
			var sx0 := (xf0 + xf1) * 0.5
			var syq := (yq0 + yq1) * 0.5
			var nst := 6
			for si in nst:
				var xa := sx0 - 0.55 * si
				var ya := lerpf(syq, sea_y - 0.1, float(si) / nst)
				var yb := lerpf(syq, sea_y - 0.1, float(si + 1) / nst)
				var tc := Color("a29982") if si % 2 == 0 else Color("89806b")
				_sh_quad(k, Vector3(xa, ya, sz + 1.2), Vector3(xa - 0.55, ya, sz + 1.2), Vector3(xa - 0.55, ya, sz - 1.2), Vector3(xa, ya, sz - 1.2), tc, tc, tc, tc, Vector3.UP)
				_sh_quad(k, Vector3(xa - 0.55, ya, sz + 1.2), Vector3(xa - 0.55, yb, sz + 1.2), Vector3(xa - 0.55, yb, sz - 1.2), Vector3(xa - 0.55, ya, sz - 1.2), Color("4e483c"), Color("4e483c"), Color("4e483c"), Color("4e483c"), NX)
		# --- rıhtım yolundaki eşyalar
		var quay_ok: bool = bool(qfree.call(xf0, zc)) and not pier_near and not path_here and xb0 - xf0 > 4.2 and xb1 - xf1 > 4.2
		if quay_ok:
			var f_b := rng.randf_range(0.2, 0.8)
			var pq := Vector3(lerpf(xf0, xf1, f_b), lerpf(yq0, yq1, f_b), lerpf(z0, z1, f_b))
			var roll := rng.randf()
			if rng.randf() < 0.45:      # bağlama babası
				var pb := Vector3(pq.x + 0.3, pq.y, lerpf(z0, z1, 0.15))
				k.cyl(Transform3D(Basis(), pb), 0.2, 0.55, Color("3c342b"), 5, 0.3)
			if roll < 0.22:
				_sh_hut(k, Vector3(xb0 - 1.7, lerpf(yq0, yq1, 0.5), zc), rng)
			elif roll < 0.7:
				_sh_cluster(k, int(roll * 7.0) % 4, Vector3(pq.x + 1.8, pq.y, pq.z), rng)
			elif roll < 0.84:
				var bt := Transform3D(Basis(Vector3.UP, (0.0 if rng.randf() < 0.5 else PI) + rng.randf_range(-0.15, 0.15)).rotated(Vector3.FORWARD, rng.randf_range(-0.08, 0.08)), Vector3(pq.x + 2.1, pq.y - row_bb.position.y + 0.05, pq.z))
				(boats["row" if rng.randf() < 0.6 else "fisher"] as Array).append(bt)
		# --- yamaç: kaya, çalı, servi, incir (patika ve kapı çevresi hariç)
		var near_path := path_here
		for gz: float in gates:
			near_path = near_path or absf(gz - zc) < 14.0
		if not near_path:
			var uu := rng.randf_range(0.12, 0.95)
			if rng.randf() < 0.55:
				var pr := _sh_rib_at(L0, L1, rng.randf(), uu)
				_sh_rock(k, pr, rng.randf_range(1.5, 3.6), rng.randf_range(1.2, 3.0), SH_ROCK.darkened(rng.randf_range(0.0, 0.2)), rng)
			for q in 2 + rng.randi() % 3:
				var pr2 := _sh_rib_at(L0, L1, rng.randf(), rng.randf_range(0.1, 0.95))
				var bcol := [Color("557039"), Color("697a3c"), Color("7a8948"), Color("5f7039"), Color("898450")][rng.randi() % 5] as Color
				var br := rng.randf_range(1.4, 2.8)
				_sh_blob(k, pr2, br, br * 0.95, br * 1.0, 0.55, bcol, rng)
			if rng.randf() < 0.2:
				var pc := _sh_rib_at(L0, L1, rng.randf(), rng.randf_range(0.35, 0.9))
				_sh_blob(k, pc, 1.1, 1.3, rng.randf_range(9.0, 14.0), 0.4, Color("32502f").lightened(rng.randf_range(0.0, 0.08)), rng)
			if rng.randf() < 0.10:
				var pf := _sh_rib_at(L0, L1, rng.randf(), rng.randf_range(0.3, 0.85))
				k.cyl(Transform3D(Basis(), pf + Vector3(0, -0.2, 0)), 0.3, 2.4, Color("5a4632"), 4, 0.15)
				_sh_blob(k, pf + Vector3(0, 1.9, 0), 2.7, 3.0, 2.8, 0.5, [Color("6b893c"), Color("7a9343")][rng.randi() % 2] as Color, rng)
	var am := ArrayMesh.new()
	if k.is_empty():
		return am
	# Köşe renkleri doğrusal okunur: yazılan renkler ekrandaki renk olsun
	for ci in k.c.size():
		k.c[ci] = k.c[ci].srgb_to_linear()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, front_faces(k.arrays()))
	return am
