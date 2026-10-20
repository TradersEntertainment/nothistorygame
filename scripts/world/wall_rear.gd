class_name WallRear
extends RefCounted
## Kara surlarının hemen içi (1453): şehir surla başlamaz. Theodosius surlarının gerisi bostanlar, bağlar, yıkık
## kiliseler ve boş arsalarla doluydu (şehir 50 bin kişiye inmiş, mahalleler köy köy dağınık). Kuşatmada bu şerit
## savunmanın artçı düzeni olur: çadırlar, kazanlar, taş ve ok yığınları, yedek bölükler, sedyeler, at bağları,
## gediği kapatan barikatın kerestesi. Mesoteichion (Lykos vadisi, Romanos Kapısı) en kalabalığı; uzaklaştıkça seyrelir.
## Evler bu şeridin ötesinde başlar (CityPlan.depth ile aynı çizgi).

const LYKOS_X := 10.0                       # gedik (büyük topun nişanı; Giustiniani'nin barikatı)
const STOCKADE := Vector2(1.0, 19.0)         # dış surun yıkılıp barikatla kapatılan kesimi (x aralığı)
const TENT := [Color("d8ccb0"), Color("c8b898"), Color("b8a888"), Color("9a8a70")]
const SOIL := [Color("5a4430"), Color("4e3a28"), Color("6a5038")]
const CROP := [Color("5a7a3a"), Color("6a8a40"), Color("4a6a32"), Color("7a8a4a")]
const RUIN := [Color("8a5a48"), Color("7a5244"), Color("946a56"), Color("6e5a4e")]


## Evsiz şeridin derinliği (iç surdan şehre doğru, m): 65..120 arası dalgalı, kenarı düz çizgi gibi okunmasın
static func depth(x: float) -> float:
	return 92.0 + 18.0 * sin(x * 0.017 + 0.6) + 10.0 * sin(x * 0.051 + 2.0)


## (x, z) evsiz şeritte mi (Blakherna'nın kuzeyi hariç: orada surlar Haliç'e döner)
static func in_band(x: float, z: float, margin := 0.0) -> bool:
	return x > World1453.WALL_N_X and z > -depth(x) - margin and z < 4.0


## Lykos barikatı bu alanda kurulur mu (dünyanın surları ortayı da kuruyor ve bölümün kendi alanı orayı kaplamıyor)
static func stockade_on(field: SiegeField) -> bool:
	return field.world and field.fill_center and field._free(LYKOS_X, 15.0, 6.0, true)


## Askerî yoğunluk: Lykos'ta 1, kapılarda 0,8, aralarda 0,2
static func busy(x: float) -> float:
	var w := exp(-pow((x - LYKOS_X) / 170.0, 2.0))
	for g: float in World1453.LAND_GATES:
		w = maxf(w, 0.8 * exp(-pow((x - g) / 45.0, 2.0)))
	return maxf(w, 0.2)


var f: SiegeField
var rng := RandomNumberGenerator.new()
var d: Dressing
var night: Dressing
var men: Array = []         # Crowd.place öğeleri
var horses := 0
var crew: PoseCrew          # talim eden, ok atan, yük kaldıran askerler (poz döngüsü; donuk dikilmesinler)
var _group := 0
var spots: Array = []       # RearLife: kameraya yakınken gerçek askere dönüşenler ({xf, spec, do, crew|still, ...})
var _taken: Array = []      # kurulmuş öbekler: Vector3(x, z, yarıçap); komşular iç içe geçmesin


static func build(field: SiegeField) -> Node3D:
	var w := WallRear.new()
	w.f = field
	w.rng.seed = 1453529
	w.d = Dressing.new(529)
	w.d.chunk = 160.0
	w.night = Dressing.new(530)
	w.night.chunk = 160.0
	w.crew = PoseCrew.new(531)
	field.add_child(w.crew)
	w._fill()
	if stockade_on(field):
		w._stockade()
	w.d.build(field)
	var placed: Array = []
	if not w.men.is_empty():
		placed = Crowd.place(field, w.men, true, true)
	w.crew.build()
	w._still_spots(placed)
	var life := RearLife.new()
	life.field = field
	life.crew = w.crew
	life.spots = w.spots
	field.add_child(life)
	if OS.get_environment("WORLD_PROF") != "":
		print("PROF wallrear duran=%d hareketli=%d" % [w.men.size(), w.crew.size()])
	return w.night.build(field)


## Duran (Crowd) askerler de yakından canlansın: oturan, karıştıran, çekiçleyen, bekleyen. Yatan yaralılar figür kalır.
## Her birinin çoklu ağdaki kopyaları (yakın ve uzak) bulunur ki canlanınca gizlensin.
func _still_spots(placed: Array) -> void:
	var at := {}
	for n in placed:
		var mmi := n as MultiMeshInstance3D
		if mmi == null:
			continue
		for i in mmi.multimesh.instance_count:
			var o := mmi.multimesh.get_instance_transform(i).origin
			var k := Vector2i(roundi(o.x * 10.0), roundi(o.z * 10.0))
			if not at.has(k):
				at[k] = []
			(at[k] as Array).append([mmi, i])
	for it: Array in men:
		var xf: Transform3D = it[0]
		if xf.basis.y.y < 0.5:
			continue
		var spec: Dictionary = it[1]
		var k := Vector2i(roundi(xf.origin.x * 10.0), roundi(xf.origin.z * 10.0))
		var pose := str(spec.get("pose", ""))
		var role := str(spec.get("role", ""))
		var sp := {"xf": xf, "spec": spec, "do": role if role != "" else (pose if pose != "" else "stand"), "still": at.get(k, [])}
		if spec.has("visit"):
			sp["visit"] = spec["visit"]
		spots.append(sp)


func _ok(x: float, z: float, r: float) -> bool:
	if x < World1453.HORN_S_X + r + 2.0 or x > World1453.marmara_x(z) - r - 2.0:
		return false
	if absf(x) < 56.0 and z > -46.0 and not f.fill_center:
		return false                         # LandWalls'ın kendi kesiti (bölümün seviyesi)
	if not f._free(x, z, r, true):
		return false
	for t: Vector3 in _taken:
		if Vector2(x - t.x, z - t.y).length() < r + t.z:
			return false
	# Sokağa yalnız kenarı değmesin (surun ardındaki yol boyunca dizilir); evlere ve yapılara tam pay
	return not CityPlan.on_street(x, z, minf(r, 2.5)) and not CityPlan.blocked(x, z, minf(r, 1.0)) and not CityPlan.in_house(x, z, r)


func _claim(p: Vector3, r: float) -> void:
	_taken.append(Vector3(p.x, p.z, r))


func _y(x: float, z: float) -> float:
	return SiegeField.city_surf(x, z)


func _fill() -> void:
	var x0 := maxf(World1453.WALL_N_X, f.wall_x_min) + 12.0
	var x1 := World1453.marmara_x(-10.0) - 14.0
	# Talim alanları ve okçu talimi: Lykos'ta ve kapıların gerisinde (önce kurulur, rastgele öbekler etrafına dizilir)
	for ax: float in [LYKOS_X - 70.0, LYKOS_X + 100.0, 175.0, -230.0, 340.0, -460.0, 520.0]:
		for tries in 4:
			if _drill_yard(Vector3(ax + rng.randf_range(-15.0, 15.0), 0, rng.randf_range(-38.0, -46.0))):
				break
	for ax: float in [LYKOS_X + 55.0, -150.0, 270.0, -380.0, 430.0]:
		for tries in 4:
			if _archery(Vector3(ax + rng.randf_range(-15.0, 15.0), 0, rng.randf_range(-30.0, -34.0))):
				break
	# Surun dibi (z −12..−50): artçı düzen, üç sıra; sur dibindeki yolun iki yanı
	var x := x0
	while x < x1:
		var w := busy(x)
		var placed := false
		for row: Vector3 in [Vector3(-13.0, -20.0, 1.15), Vector3(-25.0, -35.0, 0.95), Vector3(-39.0, -48.0, 0.7)]:
			if rng.randf() < w * row.z:
				placed = _post(Vector3(x + rng.randf_range(-4.0, 4.0), 0, rng.randf_range(row.x, row.y)), w) or placed
		if not placed and rng.randf() < 0.6:
			var p := Vector3(x + rng.randf_range(-6.0, 6.0), 0, rng.randf_range(-7.5, -10.0))
			if _ok(p.x, p.z, 2.0):
				p.y = _y(p.x, p.z)
				_stones(p)
		x += rng.randf_range(14.0, 20.0) if w > 0.5 else rng.randf_range(20.0, 28.0)
	# Gerisi: bostan, bağ, meyve bahçesi, harabe
	x = x0
	while x < x1:
		var z := -54.0 - rng.randf_range(0.0, 6.0)
		var lim := -depth(x) + 8.0
		while z > lim:
			var r := rng.randf()
			var px := x + rng.randf_range(-2.0, 2.0)
			if r < 0.5:
				z -= _plot(Vector3(px, 0, z))
			elif r < 0.68:
				z -= _orchard(Vector3(px, 0, z))
			elif r < 0.8:
				z -= _ruin(Vector3(px, 0, z))
			else:
				z -= rng.randf_range(8.0, 16.0)       # boş arsa (çayır)
			z -= rng.randf_range(2.0, 6.0)
		x += rng.randf_range(22.0, 30.0)


# ---------------------------------------------------------------- artçı düzen

func _post(p: Vector3, w: float) -> bool:
	var r := rng.randf()
	var near_gate := false
	for g: float in World1453.LAND_GATES:
		if absf(p.x - g) < 40.0:
			near_gate = true
	if w > 0.7 and r < 0.14:
		return _reserve(p)
	if near_gate and r < 0.42 and horses < 16:
		return _horses(p)
	if r < 0.6:
		return _tents(p)
	if r < 0.75:
		return _aid(p)
	if r < 0.88:
		return _depot(p)
	return _repairs(p)


## Çadır öbeği: 2–3 sırtlı çadır, ortada ocak ve kazan (aşçı karıştırır), bağdaş kurmuş askerler; gece ateş
func _tents(p: Vector3) -> bool:
	if not _ok(p.x, p.z, 8.0):
		return false
	_claim(p, 8.0)
	p.y = _y(p.x, p.z)
	var n := rng.randi_range(2, 3)
	for i in n:
		var a := -0.9 + i * 0.9 + rng.randf_range(-0.15, 0.15)
		var q := p + Vector3(cos(a + PI * 0.5) * 5.6, 0, -sin(a + PI * 0.5) * 5.6 - 1.0)
		q.y = _y(q.x, q.z)
		var c: Color = TENT[rng.randi() % TENT.size()]
		var yaw := rad_to_deg(a) + rng.randf_range(-12.0, 12.0)
		d.at(q, deg_to_rad(yaw))
		d.prism(Vector3(4.0, 2.6, 5.2), Vector3(0, 1.3, 0), c)
		d.box(Vector3(1.0, 1.6, 0.04), Vector3(0, 0.8, 2.6), c.darkened(0.45))       # açık kapı (gölge)
		d.cyl(0.04, 3.0, Vector3(0, 1.5, 2.65), Color("5a3a22"), Vector3.ZERO, 4)
		d.solid(Vector3(4.0, 2.6, 5.2), Vector3(0, 1.3, 0))
	d.at(Vector3.ZERO)
	d.hearth(p)
	night.glow(Vector3(0.6, 0.8, 0.6), p + Vector3(0, 0.45, 0), Color("ffa030"))
	men.append(_man(p + Vector3(0.9, 0, 0.5), atan2(-0.9, -0.5), "stir"))
	for k in rng.randi_range(2, 4):
		var a := rng.randf_range(0.6, TAU - 0.6)
		var q := p + Vector3(cos(a), 0, sin(a)) * 1.9
		men.append(_man(q, atan2(p.x - q.x, p.z - q.z), "sit_ground"))
	if rng.randf() < 0.6:
		d.spear_rack(p + Vector3(-3.0, 0, 3.0))
	return true


## Yedek bölük: 3x5 dizili, sura (+z) bakar; önde subay ve sancak (imparatorluk ya da Ceneviz)
func _reserve(p: Vector3) -> bool:
	if not _ok(p.x, p.z, 6.0):
		return false
	_claim(p, 6.0)
	_loose_drill(p, rng.randi_range(6, 9), p + Vector3(0, 0, 6.0))
	var sg := p + Vector3(rng.randf_range(-1.0, 1.0), 0, 4.2)
	var sm := _man(sg, PI, "", "spear")
	(sm[1] as Dictionary)["role"] = "instructor"
	(sm[1] as Dictionary)["visit"] = [p]
	men.append(sm)
	var fp := p + Vector3(4.6, 0, 1.8)
	fp.y = _y(fp.x, fp.z)
	if absf(p.x - LYKOS_X) < 120.0 and rng.randf() < 0.6:
		_genoese(fp)
	else:
		d.banner_pole(fp, Color("8a1a3a"))
		d.ball(0.2, fp + Vector3(0.47, 3.55, 0.03), Color("d8b040"), Vector3(1, 1, 0.2), 8)   # çift başlı kartalın altını
	return true


## Dağınık talim kümesi (dizili bölük değil): n kişi bir öbekte, her biri kendi temposunda mızrak dürter ya da
## kalkanın altına çöker; yüzleri aşağı yukarı eğitmene (face) dönük, aralarında düzensiz boşluk.
func _loose_drill(p: Vector3, n: int, face: Vector3) -> void:
	var placed: Array = []
	for k in n * 4:
		if placed.size() >= n:
			break
		var a := rng.randf() * TAU
		var q := p + Vector3(cos(a), 0, sin(a)) * rng.randf_range(0.0, 3.2)
		var clash := false
		for o: Vector3 in placed:
			if Vector2(o.x - q.x, o.z - q.z).length() < 1.3:
				clash = true
		if clash:
			continue
		placed.append(q)
		q.y = _y(q.x, q.z)
		var shield := rng.randf() < 0.35
		var yaw := atan2(face.x - q.x, face.z - q.z) + rng.randf_range(-0.5, 0.5)
		_crew(Transform3D(Basis(Vector3.UP, yaw), q), {"side": "B", "coat": Crowd.BYZ_COATS[rng.randi() % Crowd.BYZ_COATS.size()],
			"arm": "spear_shield" if shield else "spear"}, "cover" if shield else "thrust", -1, Vector2(16.0, 32.0),
			{"beat": rng.randf_range(3.2, 5.4), "off": rng.randf() * 5.0})


## Talim meydanı (Osmanlı ordugâhındaki gibi): çiğnenmiş toprak, tahta kılıçla dövüşen çiftler, saman kuklaya vuranlar,
## dağınık mızrak çalışanlar, aralarında dolaşıp gösteren eğitmen, kütükte oturup izleyenler, silah sehpası, su fıçısı.
func _drill_yard(p: Vector3) -> bool:
	if not _ok(p.x, p.z, 13.0):
		return false
	_claim(p, 13.0)
	var yaw0 := rng.randf_range(-0.4, 0.4)
	var b := Basis(Vector3.UP, yaw0)
	var gy := _y(p.x, p.z)
	d.box(Vector3(24.0, 0.05, 17.0), Vector3(p.x, gy + 0.02, p.z), Color("6a5c44"), Vector3(0, rad_to_deg(yaw0), 0))
	var visit: Array = []
	var used: Array = []
	# Çiftler (2–3): yönleri karışık
	for k in rng.randi_range(2, 3):
		var c := _free_in(p, b, used, 3.6)
		if c == Vector3.INF:
			continue
		used.append(c)
		visit.append(c)
		var ax := Basis(Vector3.UP, rng.randf() * TAU) * Vector3.RIGHT
		var ends: Array = []
		for i in 2:
			var q := c + ax * (-1.0 + i * 2.0)
			q.y = _y(q.x, q.z)
			ends.append(q)
		var ids: Array = []
		for i in 2:
			var q: Vector3 = ends[i]
			var o: Vector3 = ends[1 - i]
			crew.add(Transform3D(Basis(Vector3.UP, atan2(o.x - q.x, o.z - q.z)), q),
				{"side": "B", "coat": Crowd.BYZ_COATS[rng.randi() % Crowd.BYZ_COATS.size()], "arm": "spear_shield"}, "thrust")
			ids.append(crew.size() - 1)
		spots.append({"xf": Transform3D(Basis.IDENTITY, c), "do": "spar", "pair": ids, "ends": ends,
			"spec": {"coat": Crowd.BYZ_COATS[rng.randi() % Crowd.BYZ_COATS.size()]}, "crew": -1})
	# Saman kuklalar (1–2) ve vuranları
	for k in rng.randi_range(1, 2):
		var c := _free_in(p, b, used, 2.6)
		if c == Vector3.INF:
			continue
		used.append(c)
		c.y = _y(c.x, c.z)
		_dummy(c)
		var a := rng.randf() * TAU
		var q := c + Vector3(cos(a), 0, sin(a)) * 1.5
		q.y = _y(q.x, q.z)
		_crew(Transform3D(Basis(Vector3.UP, atan2(c.x - q.x, c.z - q.z)), q),
			{"side": "B", "coat": Crowd.BYZ_COATS[rng.randi() % Crowd.BYZ_COATS.size()], "arm": "spear"}, "thrust", -1,
			Vector2(16.0, 32.0), {"beat": rng.randf_range(2.6, 3.6), "off": rng.randf() * 4.0})
		visit.append(c)
	# Dağınık mızrak çalışanlar
	var gc := _free_in(p, b, used, 3.8)
	if gc != Vector3.INF:
		used.append(gc)
		visit.append(gc)
		_loose_drill(gc, rng.randi_range(5, 7), p)
	# Kenarda: kütük ve oturup izleyenler, silah sehpası, su fıçısı, sancak
	var side := p + b * Vector3(10.0, 0, rng.randf_range(-4.0, 4.0))
	side.y = _y(side.x, side.z)
	d.cyl(0.22, 2.6, side + Vector3(0, 0.22, 0), Color("6a4a2e"), Vector3(90, rad_to_deg(yaw0), 0), 8)
	d.solid(Vector3(0.5, 0.45, 2.6), side + Vector3(0, 0.22, 0), rad_to_deg(yaw0))
	for k in rng.randi_range(2, 3):
		var q := side + b * Vector3(-0.7, 0, -0.9 + k * 0.9)
		men.append(_man(q, yaw0 - PI * 0.5 + rng.randf_range(-0.4, 0.4), "sit_ground"))
	d.spear_rack(p + b * Vector3(-10.5, 0, -3.0))
	d.barrel(p + b * Vector3(-10.0, 0, 3.0))
	var fp := p + b * Vector3(-10.8, 0, 5.8)
	fp.y = _y(fp.x, fp.z)
	if absf(p.x - LYKOS_X) < 120.0:
		_genoese(fp)
	else:
		d.banner_pole(fp, Color("8a1a3a"))
	# Eğitmen: çiftlerin, kuklaların ve öbeğin arasında dolaşır (yakında; uzakta duran figür)
	var ip := p + b * Vector3(0, 0, 5.5)
	ip.y = _y(ip.x, ip.z)
	var it := _man(ip, PI + yaw0, "", "")
	(it[1] as Dictionary)["role"] = "instructor"
	(it[1] as Dictionary)["visit"] = visit
	men.append(it)
	return true


## Talim meydanında boş bir yer (yerel kutu ±9 x ±6), öncekilerden en az gap uzakta
func _free_in(p: Vector3, b: Basis, used: Array, gap: float) -> Vector3:
	for k in 20:
		var q := p + b * Vector3(rng.randf_range(-8.0, 8.0), 0, rng.randf_range(-5.5, 5.0))
		var ok := true
		for o: Vector3 in used:
			if Vector2(o.x - q.x, o.z - q.z).length() < gap * 2.0:
				ok = false
		if ok:
			return q
	return Vector3.INF


## Saman kukla: kazık, çapraz ayak, çuval gövde, baş, kol sopası
func _dummy(c: Vector3) -> void:
	for r: float in [0.0, 90.0]:
		d.box(Vector3(0.9, 0.1, 0.12), c + Vector3(0, 0.05, 0), Color("5a3e26"), Vector3(0, r, 0))
	d.cyl(0.05, 1.9, c + Vector3(0, 0.95, 0), Color("5a3e26"), Vector3.ZERO, 6)
	d.cyl(0.23, 0.75, c + Vector3(0, 1.15, 0), Color("d8b860"), Vector3.ZERO, 10, 0.2)
	d.box(Vector3(1.1, 0.07, 0.07), c + Vector3(0, 1.42, 0), Color("7a5634"))
	d.ball(0.17, c + Vector3(0, 1.72, 0), Color("c8b080"), Vector3(1.0, 1.1, 1.0), 10)
	d.solid(Vector3(0.5, 1.9, 0.5), c + Vector3(0, 0.95, 0))


## Okçu talimi: bir sıra okçu şehre doğru (surdan uzağa) ok atar; karşıda saman hedefler, oklar önlerine saplanır
func _archery(p: Vector3) -> bool:
	if not _ok(p.x, p.z - 7.0, 10.0):
		return false
	_claim(p + Vector3(0, 0, -7.0), 10.0)
	for k in 7:
		var q := p + Vector3(-6.0 + k * 2.0, 0, 0)
		q.y = _y(q.x, q.z)
		_crew(Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.05, 0.05)), q),
			{"side": "B", "coat": Crowd.BYZ_COATS[rng.randi() % Crowd.BYZ_COATS.size()], "arm": "bow"}, "archer", -1, Vector2(12.0, 14.0))
	for k in 4:
		var t := p + Vector3(-6.0 + k * 4.0, 0, -14.5)
		t.y = _y(t.x, t.z)
		d.cyl(0.75, 1.3, t + Vector3(0, 0.65, 0), Color("c8b070"), Vector3(90, 0, 0), 10)
		d.cyl(0.42, 1.32, t + Vector3(0, 0.65, 0), Color("b3262d"), Vector3(90, 0, 0), 10)
		d.cyl(0.15, 1.34, t + Vector3(0, 0.65, 0), Color("f0e8d0"), Vector3(90, 0, 0), 8)
		d.box(Vector3(0.1, 1.4, 0.1), t + Vector3(-0.5, 0.7, -0.6), Color("5a3a22"), Vector3(-20, 0, 0))
		d.box(Vector3(0.1, 1.4, 0.1), t + Vector3(0.5, 0.7, -0.6), Color("5a3a22"), Vector3(-20, 0, 0))
		d.solid(Vector3(1.6, 1.4, 1.4), t + Vector3(0, 0.7, -0.2))
	men.append(_man(p + Vector3(8.0, 0, -1.0), -PI * 0.5, "", "bow"))
	return true


## Yük kaldırıp indiren (ok demeti, taş, sandık)
func _worker(q: Vector3, yaw: float) -> void:
	q.y = _y(q.x, q.z)
	# Yakından bakınca yükü sur dibine taşır (RearLife): yüklendiği yer kendi yeri, bıraktığı yer surun dibi
	var drop := Vector3(q.x + rng.randf_range(-4.0, 4.0), 0, rng.randf_range(-6.5, -8.0))
	_crew(Transform3D(Basis(Vector3.UP, yaw), q), {"side": "B", "coat": Crowd.BYZ_COATS[rng.randi() % Crowd.BYZ_COATS.size()], "arm": ""}, "pass", -1,
		Vector2(16.0, 32.0), {"drop": drop})


func _crew(xf: Transform3D, spec: Dictionary, cycle: String, group := -1, reach := Vector2(16.0, 32.0), extra := {}) -> void:
	crew.add(xf, spec, cycle, group, reach)
	var sp := {"xf": xf, "spec": spec, "do": cycle, "crew": crew.size() - 1, "group": group}
	sp.merge(extra)
	spots.append(sp)


## At bağları (kapıların yanında: haberci ve süvari)
func _horses(p: Vector3) -> bool:
	if not _ok(p.x + 2.6, p.z, 6.5):
		return false
	_claim(p, 6.5)
	p.y = _y(p.x, p.z)
	d.picket(p)
	d.picket(p + Vector3(5.2, 0, 0))
	d.hay(p + Vector3(-4.2, 0, 0.4))
	horses += 6
	_worker(p + Vector3(2.6, 0, 2.2), PI)
	return true


## Yaralılar: sedyelerde yatanlar, başlarında çömelen ve su taşıyan; bez gölgelik
func _aid(p: Vector3) -> bool:
	if not _ok(p.x, p.z, 5.0):
		return false
	_claim(p, 4.5)
	p.y = _y(p.x, p.z)
	d.at(p, 0.0)
	for sx in [-2.0, 2.0]:
		d.cyl(0.06, 2.4, Vector3(sx, 1.2, -1.6), Color("5a3a22"), Vector3.ZERO, 4)
		d.cyl(0.06, 2.4, Vector3(sx, 1.2, 1.6), Color("5a3a22"), Vector3.ZERO, 4)
	d.box(Vector3(4.4, 0.05, 3.6), Vector3(0, 2.42, 0), Color("d8d0bc"))
	d.at(Vector3.ZERO)
	for k in 3:
		var q := p + Vector3(-1.5 + k * 1.5, 0, 0)
		q.y = _y(q.x, q.z)
		for sx in [-0.32, 0.32]:
			d.cyl(0.03, 2.3, q + Vector3(sx, 0.18, 0), Color("6b4a2e"), Vector3(90, 0, 0), 4)
		d.box(Vector3(0.62, 0.04, 1.9), q + Vector3(0, 0.2, 0), Color("b8a888"))
		# Yatan yaralı: ayakta kalıbın yatırılmışı (sırtüstü, ayakları sura)
		var lie := Transform3D(Basis(Vector3.RIGHT, -PI * 0.5), q + Vector3(0, 0.36, 0.85))
		men.append([lie, {"side": "B", "coat": Crowd.BYZ_COATS[rng.randi() % Crowd.BYZ_COATS.size()], "arm": "", "pose": ""}])
		d.box(Vector3(0.3, 0.06, 0.5), q + Vector3(0, 0.33, 0.2), Color("e8e0d0"))      # sargı bezi
	d.amphorae(p + Vector3(3.2, 0, -0.6))
	men.append(_man(p + Vector3(-0.75, 0, 1.6), PI, "sit_ground"))
	_worker(p + Vector3(2.8, 0, 1.0), -PI * 0.6)
	return true


## Cephane: taş yığını, ok sandıkları, kalkanlar, fıçılar
func _depot(p: Vector3) -> bool:
	if not _ok(p.x, p.z, 4.0):
		return false
	_claim(p, 4.0)
	p.y = _y(p.x, p.z)
	_stones(p)
	d.chests(p + Vector3(2.4, 0, -0.4))
	_shields(p + Vector3(-2.6, 0, 0.6))
	d.barrels(p + Vector3(0.4, 0, -2.4))
	_worker(p + Vector3(1.4, 0, 1.6), PI * 0.8)
	_worker(p + Vector3(-1.2, 0, 1.8), PI * 1.2)
	return true


## Barikat onarımı: kereste yığını, toprak sepetleri, öküz arabası; çekiçle çalışanlar
func _repairs(p: Vector3) -> bool:
	if not _ok(p.x, p.z, 5.0):
		return false
	_claim(p, 5.0)
	p.y = _y(p.x, p.z)
	for k in 6:
		d.cyl(0.14, 4.2, p + Vector3(-1.0 + (k % 3) * 0.3, 0.14 + (k / 3) * 0.26, 0), Color("8a6a44").darkened(rng.randf() * 0.2), Vector3(90, 90, 0), 6)
	d.solid(Vector3(4.4, 0.6, 1.2), p + Vector3(-0.7, 0.3, 0))
	for k in 4:
		d.basket(p + Vector3(1.6 + k * 0.7, 0, 1.4), Color("5a4630"))
	d.cart(p + Vector3(-3.5, 0, 2.4))
	men.append(_man(p + Vector3(0.2, 0, 1.5), PI, "hammer"))
	_worker(p + Vector3(2.4, 0, 2.6), 0.4)
	_worker(p + Vector3(3.4, 0, 0.6), PI * 0.6)
	return true


## Duvara yaslı kalkanlar (Bizans: koyu kırmızı, kahve, demir grisi; uzaktan renkli top gibi okunmasın)
func _shields(p: Vector3) -> void:
	var cols := [Color("6a2a24"), Color("5a4634"), Color("4a4e56"), Color("7a3a2a")]
	for k in 4:
		var c: Color = cols[rng.randi() % cols.size()]
		d.cyl(0.36, 0.06, p + Vector3(-0.5 + k * 0.34, 0.38, 0.12), c, Vector3(75, 0, 0), 12)
		d.cyl(0.08, 0.08, p + Vector3(-0.5 + k * 0.34, 0.4, 0.16), Color("8a7a5a"), Vector3(75, 0, 0), 8)


## Atılacak taş yığını (surun dibinde; mancınık yok, elle ve sapanla atılır)
func _stones(p: Vector3) -> void:
	var c := Color("9a9088")
	for k in 14:
		var a := rng.randf() * TAU
		var rr := rng.randf_range(0.0, 0.9) * (1.0 - k / 20.0)
		d.ball(rng.randf_range(0.16, 0.28), p + Vector3(cos(a) * rr, 0.12 + k * 0.035, sin(a) * rr), c.darkened(rng.randf() * 0.25), Vector3(1, 0.8, 1), 6)
	d.solid(Vector3(1.8, 0.7, 1.8), p + Vector3(0, 0.35, 0))


## Ceneviz sancağı: beyaz zemin, kırmızı haç (Giustiniani'nin adamları)
func _genoese(fp: Vector3) -> void:
	d.cyl(0.05, 4.4, fp + Vector3(0, 2.2, 0), Color("5a3a22"), Vector3.ZERO, 5)
	d.solid(Vector3(0.12, 4.4, 0.12), fp + Vector3(0, 2.2, 0))
	d.box(Vector3(1.2, 0.85, 0.03), fp + Vector3(0.62, 3.8, 0), Color("f0ece4"))
	d.box(Vector3(1.2, 0.17, 0.035), fp + Vector3(0.62, 3.8, 0), Color("b3262d"))
	d.box(Vector3(0.17, 0.85, 0.035), fp + Vector3(0.62, 3.8, 0), Color("b3262d"))


func _man(q: Vector3, yaw: float, pose: String, arm := "") -> Array:
	q.y = _y(q.x, q.z)
	var coat: Color = Crowd.BYZ_COATS[rng.randi() % Crowd.BYZ_COATS.size()]
	return [Transform3D(Basis(Vector3.UP, yaw), q), {"side": "B", "coat": coat, "arm": arm, "pose": pose}]


# ---------------------------------------------------------------- bostan, bağ, harabe

## Bostan: çitle çevrili toprak, ekin sıraları, köşede kuyu ya da kulübe. Döndürdüğü: z'de kapladığı yer
func _plot(c: Vector3) -> float:
	var w := rng.randf_range(12.0, 18.0)
	var h := rng.randf_range(9.0, 14.0)
	if not _rect_ok(c, w, h):
		return 4.0
	c.y = _y(c.x, c.z - h * 0.5)
	var mid := c + Vector3(0, 0, -h * 0.5)
	d.box(Vector3(w, 0.1, h), mid + Vector3(0, 0.02, 0), SOIL[rng.randi() % SOIL.size()])
	var crop: Color = CROP[rng.randi() % CROP.size()]
	var rows := int(h / 1.2)
	var along_x := rng.randf() < 0.5
	if along_x:
		for k in rows:
			d.box(Vector3(w - 1.2, rng.randf_range(0.25, 0.5), 0.45), mid + Vector3(0, 0.2, -h * 0.5 + 0.8 + k * 1.2), crop.lightened(rng.randf() * 0.08))
	else:
		for k in int(w / 1.2):
			d.box(Vector3(0.45, rng.randf_range(0.25, 0.5), h - 1.2), mid + Vector3(-w * 0.5 + 0.8 + k * 1.2, 0.2, 0), crop.lightened(rng.randf() * 0.08))
	# Çit (dal örgü) üç yanda, sokağa bakan yan açık
	var wc := Color("6a5236")
	d.box(Vector3(w, 0.7, 0.08), mid + Vector3(0, 0.35, -h * 0.5), wc)
	d.box(Vector3(0.08, 0.7, h), mid + Vector3(-w * 0.5, 0.35, 0), wc)
	d.box(Vector3(0.08, 0.7, h), mid + Vector3(w * 0.5, 0.35, 0), wc)
	d.solid(Vector3(w, 0.7, 0.1), mid + Vector3(0, 0.35, -h * 0.5))
	d.solid(Vector3(0.1, 0.7, h), mid + Vector3(-w * 0.5, 0.35, 0))
	d.solid(Vector3(0.1, 0.7, h), mid + Vector3(w * 0.5, 0.35, 0))
	if rng.randf() < 0.35:
		d.well(mid + Vector3(w * 0.5 + 1.6, 0, -h * 0.3))
	elif rng.randf() < 0.3:
		var s := mid + Vector3(-w * 0.5 + 1.6, 0, -h * 0.5 + 1.5)
		d.box(Vector3(2.4, 2.0, 2.0), s + Vector3(0, 1.0, 0), Color("8a7458"))
		d.prism(Vector3(2.8, 0.8, 2.4), s + Vector3(0, 2.4, 0), Color("6a5236"))
		d.solid(Vector3(2.4, 2.0, 2.0), s + Vector3(0, 1.0, 0))
	return h


## Meyve bahçesi ya da bağ: seyrek ağaçlar / asma sıraları
func _orchard(c: Vector3) -> float:
	var w := rng.randf_range(13.0, 18.0)
	var h := rng.randf_range(10.0, 16.0)
	if not _rect_ok(c, w, h):
		return 4.0
	var vine := rng.randf() < 0.45
	if vine:
		for k in int(h / 1.8):
			var z := c.z - 1.0 - k * 1.8
			var y := _y(c.x, z)
			for s in int(w / 2.5):
				var px := c.x - w * 0.5 + 1.0 + s * 2.5
				d.cyl(0.04, 1.3, Vector3(px, y + 0.65, z), Color("5a4028"), Vector3.ZERO, 4)
			d.box(Vector3(w - 1.6, 0.55, 0.5), Vector3(c.x, y + 1.0, z), Color("4e6a30").lightened(rng.randf() * 0.1))
	else:
		for k in rng.randi_range(5, 9):
			var q := Vector3(c.x + rng.randf_range(-w * 0.5 + 1.5, w * 0.5 - 1.5), 0, c.z - rng.randf_range(1.5, h - 1.5))
			q.y = _y(q.x, q.z)
			var s := rng.randf_range(0.8, 1.2)
			d.cyl(0.12 * s, 1.6 * s, q + Vector3(0, 0.8 * s, 0), Color("5a4028"), Vector3.ZERO, 5)
			d.ball(1.3 * s, q + Vector3(0, 2.3 * s, 0), Color("4a6a30").lightened(rng.randf() * 0.12), Vector3(1, 0.8, 1), 7)
			d.solid(Vector3(0.3, 1.6, 0.3), q + Vector3(0, 0.8, 0))
	return h


## Yıkık kilise ya da manastır: tuğla duvar kalıntıları, yarım apsis, devrik sütun tamburları
func _ruin(c: Vector3) -> float:
	var w := rng.randf_range(10.0, 15.0)
	var h := rng.randf_range(14.0, 20.0)
	if not _rect_ok(c, w, h):
		return 4.0
	var mid := c + Vector3(0, 0, -h * 0.5)
	mid.y = _y(mid.x, mid.z) - 0.1
	var col: Color = RUIN[rng.randi() % RUIN.size()]
	d.box(Vector3(w, 0.3, h), mid + Vector3(0, 0.1, 0), col.darkened(0.35))
	# Uzun duvarlar parça parça (yükseklikleri değişen kesimler)
	for sx in [-0.5, 0.5]:
		var z := -h * 0.5
		while z < h * 0.5 - 1.0:
			var seg := rng.randf_range(2.0, 4.5)
			if rng.randf() < 0.72:
				var wh := rng.randf_range(1.0, 5.5)
				var p := mid + Vector3(sx * w, wh * 0.5, z + seg * 0.5)
				d.box(Vector3(0.9, wh, seg), p, col.darkened(rng.randf() * 0.15))
				d.solid(Vector3(0.9, wh, seg), p)
			z += seg
	# Yarım apsis (doğuda: şehre bakan uç) ve devrik sütunlar
	var ap := mid + Vector3(0, 0, -h * 0.5)
	for k in 5:
		var a := PI + k * PI / 4.0
		var q := ap + Vector3(cos(a) * w * 0.4, 0, sin(a) * w * 0.4 * 0.6)
		var hh := rng.randf_range(2.0, 6.5)
		d.box(Vector3(2.4, hh, 0.9), q + Vector3(0, hh * 0.5, 0), col, Vector3(0, -rad_to_deg(a) + 90.0, 0))
		d.solid(Vector3(2.4, hh, 0.9), q + Vector3(0, hh * 0.5, 0), -rad_to_deg(a) + 90.0)
	for k in rng.randi_range(2, 4):
		var q := mid + Vector3(rng.randf_range(-w * 0.3, w * 0.3), 0.35, rng.randf_range(-h * 0.3, h * 0.3))
		d.cyl(0.35, 1.0, q, Color("d8d0c0"), Vector3(90, rng.randf_range(0, 180), 0), 10)
	for k in 3:
		d.rubble(mid + Vector3(rng.randf_range(-w * 0.4, w * 0.4), 0, rng.randf_range(-h * 0.4, h * 0.4)))
	return h


func _rect_ok(c: Vector3, w: float, h: float) -> bool:
	for q in [Vector2(0, -h * 0.5), Vector2(-w * 0.5, 0), Vector2(w * 0.5, 0), Vector2(-w * 0.5, -h), Vector2(w * 0.5, -h), Vector2(0, -h)]:
		if not _ok(c.x + q.x, c.z + q.y, 1.5):
			return false
	return c.z - h > -depth(c.x) - 2.0


# ---------------------------------------------------------------- Lykos barikatı

## Dış surun gedikteki kesimi (STOCKADE) top atışlarıyla yıkıldı; Giustiniani'nin adamları yerine toprak dolu
## fıçılar, kazıklar, dal örgüsü ve molozdan bir barikat çekti (Barbaro, Kritovulos). SiegeField dış suru burada keser.
func _stockade() -> void:
	var a := STOCKADE.x
	var b := STOCKADE.y
	var mid := (a + b) * 0.5
	var len := b - a
	var earth := Color("6a5438")
	# Moloz yamacı (iki yüze taşar) ve toprak gövde
	for k in 26:
		var x := rng.randf_range(a - 1.0, b + 1.0)
		d.ball(rng.randf_range(0.6, 1.3), Vector3(x, rng.randf_range(0.0, 0.8), rng.randf_range(16.8, 19.0)), SiegeField.STONE.darkened(rng.randf_range(0.3, 0.55)), Vector3(1.3, 0.6, 1.0), 6)
	d.box(Vector3(len, 4.2, 3.4), Vector3(mid, 2.1, 15.0), earth)
	d.solid(Vector3(len, 6.0, 3.4), Vector3(mid, 3.0, 15.0))
	# Üstte toprak dolu fıçılar ve dal örgüsü sepetler, önünde sivri kazıklar
	var x := a + 0.6
	while x < b - 0.4:
		d.cyl(0.42, 1.1, Vector3(x, 4.75, 15.9), Color("6b4a2e").darkened(rng.randf() * 0.2), Vector3.ZERO, 10)
		d.cyl(0.43, 0.06, Vector3(x, 4.5, 15.9), Color("3a3634"), Vector3.ZERO, 10)
		d.cyl(0.4, 0.08, Vector3(x, 5.32, 15.9), earth.darkened(0.2), Vector3.ZERO, 10)
		d.cyl(0.36, 0.9, Vector3(x + 0.45, 4.65, 14.6), Color("66502f"), Vector3.ZERO, 8)
		x += 0.95
	x = a + 0.3
	while x < b:
		d.cyl(0.07, 2.4, Vector3(x, 4.9, 16.9), Color("7a5634"), Vector3(-25, 0, 0), 4, 0.1)
		d.cyl(0.07, 2.0, Vector3(x + 0.2, 1.0, 19.0), Color("7a5634"), Vector3(-35, 0, 0), 4, 0.1)
		x += 0.6
	# Dikme direkler ve çapraz kalaslar (barikatın iskeleti)
	x = a + 0.2
	while x < b:
		d.box(Vector3(0.24, 6.6, 0.24), Vector3(x, 3.3, 16.5), Color("5a3a22"))
		x += 2.4
	d.box(Vector3(len, 0.22, 0.2), Vector3(mid, 5.6, 16.55), Color("6a4a2c"))
	_genoese(Vector3(mid + 2.0, 5.3, 15.0))
	# Barikatın arkasında (peribolos) Giustiniani'nin bölüğü
	for k in 7:
		men.append(_man(Vector3(a + 1.5 + k * 2.4, 0, 12.0 + rng.randf_range(-0.6, 0.6)), 0.0, "", ["spear_shield", "spear", "bow"][k % 3]))
