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
	d.box(Vector3(4.6, 1.4, 4.6), Vector3(0, 33.7, 0), MARBLE)
	d.cyl(0.6, 2.8, Vector3(0, 35.8, 0), BRONZE, Vector3.ZERO, 8)
	d.ball(0.5, Vector3(0, 37.6, 0), BRONZE, Vector3.ONE, 8)
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
		_ship(d, Vector3(-28.0 - k * 14.0, 0, 9.0), flag)
	d.at(Vector3.ZERO)


## Tüccar gemisi (yerel x boyunca, su yüzü y 0)
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

## Forumlarda çeşme ve tezgâhlar, pazarlarda tezgâh halkası, limanlarda sandık, fıçı, ağ; Philadelphion'da porfir
## Tetrarklar, Arkadios Forumu'nda sütun
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
		match name:
			"Philadelphion":
				for sx: float in [-1.0, 1.0]:
					var q := Vector3(c.x + sx * 6.0, 0, c.z + 8.0)
					d.at(Vector3(q.x, World1453.surface_h(q.x, q.z) - 0.2, q.z))
					d.cyl(0.7, 5.0, Vector3(0, 2.5, 0), PORPHYRY, Vector3.ZERO, 8)
					for k in 2:
						d.cyl(0.32, 1.3, Vector3(-0.35 + k * 0.7, 5.65, 0), PORPHYRY.darkened(0.1), Vector3.ZERO, 6)
						d.ball(0.24, Vector3(-0.35 + k * 0.7, 6.5, 0), PORPHYRY.darkened(0.1), Vector3.ONE, 6)
			"Forum Arcadii":
				d.at(Vector3(c.x, World1453.surface_h(c.x, c.z) - 0.2, c.z))
				d.box(Vector3(6.0, 4.0, 6.0), Vector3(0, 2.0, 0), MARBLE)
				d.cyl(1.7, 24.0, Vector3(0, 16.0, 0), MARBLE.darkened(0.03), Vector3.ZERO, 12)
				for k in 7:
					d.cyl(1.8, 0.5, Vector3(0, 6.0 + k * 3.0, 0), Color("b8ac94"), Vector3(9, k * 40.0, 0), 12)
				d.box(Vector3(4.0, 1.2, 4.0), Vector3(0, 28.6, 0), MARBLE)
			"Forum Bovis":
				d.at(Vector3(c.x + 5.0, World1453.surface_h(c.x + 5.0, c.z) - 0.2, c.z))
				d.box(Vector3(2.6, 1.6, 4.0), Vector3(0, 0.8, 0), STONE)
				d.box(Vector3(1.8, 1.6, 2.6), Vector3(0, 2.4, -0.4), BRONZE)
				for sx: float in [-0.7, 0.7]:
					d.cyl(0.15, 1.2, Vector3(sx, 3.6, -1.2), BRONZE.darkened(0.15), Vector3(0, 0, sx * 50.0), 6, 0.3)
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
