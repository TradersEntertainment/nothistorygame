class_name CityPlan
extends RefCounted
## Şehrin planı (docs/CITY_LIFE.md §1): Mese, kapı yolları, ara sokaklar, meydanlar ve sokak kenarına dizilen evler.
## Deterministik (sabit tohum), statik ve önbellekli; dünya koordinatında (World1453). Düğümlerin y'si görünen yüzey
## (World1453.surface_h): bölümün düz alanı (SiegeField.flat_rects) değişince yeniden hesaplanır.
##   · Mese (11 m): Augustaion → Milion → Konstantin Forumu → Tauri → Philadelphion; kuzey kolu Havariyun → Harisios,
##     güney kolu Bovis → Arkadios → Altınkapı. Philadelphion'un doğusu revaklı.
##   · Kapı yolları (6 m): kara surlarının kapılarından, Haliç ve Marmara kapılarından Mese'ye.
##   · Ara sokaklar: hafif kıvrık bir ızgara (enine ~50 m, boyuna ~60 m); her üçüncü enine sokak 5 m, ötekiler 3,6 m.
##     Ana yolu kesen ara sokak kesilir, ucu en yakın ana yol düğümüne bağlanır. Anıtların ve meydanların tabanı boş.
##   · Evler: sokağın iki yanına, cephesi sokağa bakan sıra hâlinde; aralarda bahçe boşlukları, blokların içi bostan.
## Kurulum: HornWorld (z < −700) ve SiegeField (z −700…−3) evleri houses_in ile alır; döşemeyi HornWorld kurar.

const MESE := 0
const ROAD := 1
const LANE := 2
const W_MESE := 11.0
const W_ROAD := 6.0
const W_SIDE := 5.0           # her üçüncü enine sokak (kıyıya inen)
const W_LANE := 3.6
const ROW := 50.0             # ızgara: enine sokaklar arası (z)
const COL := 60.0             # boyuna sokaklar arası (x)
const CELL := 32.0            # sokak ve ev arama ızgarası
const PORTICO_Z := -960.0     # Mese bunun doğusunda (z daha küçük) revaklı
const PORTICO_D := 4.2        # revakın derinliği: evler bu kadar geri çekilir
const SEED := 145301

## Ana yollar: [tür, noktalar (x, z)]. Mese'nin köşeleri meydanların ortası; kapı yolları Mese düğümünde biter.
const MAIN := [
	[MESE, [Vector2(-555.0, -1405.0), Vector2(-528.0, -1370.0), Vector2(-470.0, -1300.0), Vector2(-430.0, -1215.0),
		Vector2(-390.0, -1130.0), Vector2(-330.0, -1065.0), Vector2(-265.0, -1005.0)]],
	[MESE, [Vector2(-265.0, -1005.0), Vector2(-275.0, -925.0), Vector2(-290.0, -845.0), Vector2(-282.0, -760.0),
		Vector2(-300.0, -680.0), Vector2(-330.0, -560.0), Vector2(-370.0, -420.0), Vector2(-405.0, -280.0),
		Vector2(-435.0, -140.0), Vector2(-460.0, -6.0)]],
	[MESE, [Vector2(-265.0, -1005.0), Vector2(-180.0, -905.0), Vector2(-90.0, -800.0), Vector2(10.0, -690.0),
		Vector2(110.0, -580.0), Vector2(220.0, -440.0), Vector2(340.0, -300.0), Vector2(450.0, -180.0),
		Vector2(560.0, -80.0), Vector2(650.0, -6.0)]],
	# Haliç kapıları
	[ROAD, [Vector2(-690.0, -260.0), Vector2(-600.0, -272.0), Vector2(-500.0, -292.0), Vector2(-405.0, -280.0)]],
	[ROAD, [Vector2(-690.0, -520.0), Vector2(-560.0, -532.0), Vector2(-450.0, -548.0), Vector2(-330.0, -560.0)]],
	[ROAD, [Vector2(-690.0, -650.0), Vector2(-560.0, -662.0), Vector2(-430.0, -676.0), Vector2(-300.0, -680.0)]],
	[ROAD, [Vector2(-690.0, -900.0), Vector2(-600.0, -885.0), Vector2(-480.0, -860.0), Vector2(-380.0, -850.0), Vector2(-290.0, -845.0)]],
	[ROAD, [Vector2(-690.0, -1180.0), Vector2(-580.0, -1168.0), Vector2(-480.0, -1150.0), Vector2(-390.0, -1130.0)]],
	[ROAD, [Vector2(-690.0, -1450.0), Vector2(-630.0, -1425.0), Vector2(-555.0, -1405.0)]],
	# Marmara kapıları (Kontoskalion, Theodosius limanı, batıdaki kapı)
	[ROAD, [Vector2(-331.0, -1329.0), Vector2(-380.0, -1290.0), Vector2(-430.0, -1215.0)]],
	[ROAD, [Vector2(32.0, -852.0), Vector2(-30.0, -828.0), Vector2(-90.0, -800.0)]],
	[ROAD, [Vector2(409.0, -384.0), Vector2(340.0, -300.0)]],
	# Kara surlarının kapıları: Pempton, Romanos, Rhegion, Pege, Silivri yanındaki kapı
	[ROAD, [Vector2(-230.0, -6.0), Vector2(-235.0, -160.0), Vector2(-255.0, -330.0), Vector2(-275.0, -500.0), Vector2(-300.0, -680.0)]],
	[ROAD, [Vector2(37.0, -6.0), Vector2(30.0, -150.0), Vector2(0.0, -300.0), Vector2(-40.0, -460.0), Vector2(-70.0, -640.0), Vector2(-90.0, -800.0)]],
	[ROAD, [Vector2(170.0, -6.0), Vector2(165.0, -170.0), Vector2(150.0, -330.0), Vector2(135.0, -460.0), Vector2(110.0, -580.0)]],
	[ROAD, [Vector2(340.0, -6.0), Vector2(335.0, -150.0), Vector2(340.0, -300.0)]],
	[ROAD, [Vector2(520.0, -6.0), Vector2(500.0, -110.0), Vector2(450.0, -180.0)]],
]

## Meydanlar: [ad, x, z, yarıçap, tür]
const PLAZAS := [
	["Augustaion", -555.0, -1405.0, 22.0, "forum"],
	["Forum Constantini", -470.0, -1300.0, 24.0, "forum"],
	["Forum Tauri", -390.0, -1130.0, 28.0, "forum"],
	["Philadelphion", -265.0, -1005.0, 18.0, "forum"],
	["Forum Bovis", -90.0, -800.0, 20.0, "forum"],
	["Forum Arcadii", 110.0, -580.0, 22.0, "forum"],
	["Havariyun", -282.0, -760.0, 14.0, "market"],
	["Kontoskalion", -331.0, -1329.0, 14.0, "harbor"],
	["Theodosius Limanı", 32.0, -852.0, 14.0, "harbor"],
	["Venedik İskelesi", -684.0, -900.0, 12.0, "harbor"],
	["Amalfi İskelesi", -684.0, -1180.0, 12.0, "harbor"],
	["Ceneviz İskelesi", -684.0, -1450.0, 12.0, "harbor"],
]
## Mahalle pazarları: bu noktalara en yakın ara sokak kavşağında
const MARKETS := [Vector2(-560.0, -1250.0), Vector2(-160.0, -1060.0), Vector2(-560.0, -780.0), Vector2(-120.0, -400.0),
	Vector2(250.0, -200.0), Vector2(-540.0, -320.0), Vector2(40.0, -470.0)]

const HOUSE_COLS := [Color("e8d8c0"), Color("d8c0a0"), Color("c8a888"), Color("e0ccb0"), Color("b89a80")]

static var _ok := false
static var _p := PackedVector2Array()          # düğümler (x, z)
static var _e: Array[Vector2i] = []
static var _w := PackedFloat32Array()
static var _k := PackedInt32Array()
static var _adj: Array = []                    # düğüm → kenar listesi
static var _keys := {}                         # yuvarlanmış konum → düğüm (yolların ortak düğümleri)
static var _ecell := {}                        # hücre → kenarlar
static var _plz: Array = []                    # {name, c: Vector2, r, kind}
static var _foot: Array = []                   # anıt tabanları: {c, r, box: [c, u, half] ya da yok}
static var _houses: Array = []                 # {c, yaw, s: Vector3 (derinlik, yükseklik, cephe), away, col}
static var _hcell := {}
static var _ncell := {}
static var _sig := ""
static var _graph := {}
static var _plazas_out: Array[Dictionary] = []
static var _astar: AStar3D
static var _hc := {}                          # arazi ızgarası köşe yükseklikleri (görünen yüzey için)


# ---------------------------------------------------------------- API

## Sokak ağı: {"nodes": PackedVector3Array (y = görünen yüzey), "edges": Array[Vector2i], "width": PackedFloat32Array,
## "kind": PackedInt32Array (0 Mese, 1 yol, 2 sokak)}. Paylaşılan önbellek: değiştirilmez.
static func graph() -> Dictionary:
	_sync()
	return _graph


## Meydanlar: {"name", "pos": Vector3, "r": float, "kind": "forum"|"market"|"harbor"}
static func plazas() -> Array[Dictionary]:
	_sync()
	return _plazas_out


## (x, z) bir sokağın ya da meydanın üstünde mi (kenarından margin metre içeride sayılır)
static func on_street(x: float, z: float, margin := 0.0) -> bool:
	_ensure()
	var p := Vector2(x, z)
	for pl: Dictionary in _plz:
		if p.distance_to(pl["c"]) < float(pl["r"]) + margin:
			return true
	for ei: int in _edges_near(p, margin + 6.0):
		var e := _e[ei]
		if _seg_dist(p, _p[e.x], _p[e.y]) < _w[ei] * 0.5 + margin:
			return true
	return false


## (x, z) bir sokağın üstünde mi (meydanlar sayılmaz)
static func on_road(x: float, z: float, margin := 0.0) -> bool:
	_ensure()
	var p := Vector2(x, z)
	for ei: int in _edges_near(p, margin + 6.0):
		var e := _e[ei]
		if _seg_dist(p, _p[e.x], _p[e.y]) < _w[ei] * 0.5 + margin:
			return true
	return false


## (x, z) bir meydanda mı
static func on_plaza(x: float, z: float, margin := 0.0) -> bool:
	_ensure()
	return _in_plaza(Vector2(x, z), margin)


## (x, z) Mese dışındaki bir yolun ya da sokağın üstünde mi (revak kavşakta açılır)
static func on_side_street(x: float, z: float, margin := 0.0) -> bool:
	_ensure()
	var p := Vector2(x, z)
	for ei: int in _edges_near(p, margin + 6.0):
		if _k[ei] == MESE:
			continue
		var e := _e[ei]
		if _seg_dist(p, _p[e.x], _p[e.y]) < _w[ei] * 0.5 + margin:
			return true
	return false


## Ev, ağaç, kilise konamaz: sokak, meydan, anıt tabanı ya da ev
static func blocked(x: float, z: float, margin := 0.0) -> bool:
	if on_street(x, z, margin):
		return true
	var p := Vector2(x, z)
	for f: Dictionary in _foot:
		if _foot_dist(f, p) < margin:
			return true
	return in_house(x, z, margin)


## (x, z) bir evin tabanında mı (margin kadar genişletilmiş)
static func in_house(x: float, z: float, margin := 0.0) -> bool:
	_ensure()
	var p := Vector2(x, z)
	var c0 := _cell(p - Vector2.ONE * (margin + 8.0))
	var c1 := _cell(p + Vector2.ONE * (margin + 8.0))
	for i in range(c0.x, c1.x + 1):
		for j in range(c0.y, c1.y + 1):
			for hi: int in _hcell.get(Vector2i(i, j), []):
				var h: Dictionary = _houses[hi]
				if _pt_rect_dist(h["obb"], p) < margin:
					return true
	return false


## En yakın düğüm
static func nearest_node(p: Vector3) -> int:
	_ensure()
	var q := Vector2(p.x, p.z)
	var c := _cell(q)
	var best := -1
	var bd := INF
	var ring := 0
	while ring < 80:
		for i in range(c.x - ring, c.x + ring + 1):
			for j in range(c.y - ring, c.y + ring + 1):
				if maxi(absi(i - c.x), absi(j - c.y)) != ring:
					continue
				for n: int in _ncell.get(Vector2i(i, j), []):
					var d := q.distance_squared_to(_p[n])
					if d < bd:
						bd = d
						best = n
		# Bu halkanın ötesindeki hücreler en az ring·CELL uzakta
		if best >= 0 and sqrt(bd) <= ring * CELL:
			break
		ring += 1
	return best


## İki düğüm (ya da iki dünya noktası: en yakın düğümleri) arasında sokak ağından en kısa yol (A*); y görünen yüzey
static func path(a, b) -> PackedVector3Array:
	_sync()
	var ia: int = a if a is int else nearest_node(a as Vector3)
	var ib: int = b if b is int else nearest_node(b as Vector3)
	if ia < 0 or ib < 0:
		return PackedVector3Array()
	return _astar.get_point_path(ia, ib)


## Bir z aralığındaki evler (kurulum: HornWorld z < −700, SiegeField z −700…0). Her biri:
## {"c": Vector2 taban ortası, "yaw": float, "s": Vector3(derinlik, çatı dahil yükseklik, cephe), "away": Vector2
## (sokaktan dışarı), "col": Color, "v": CityHouses örneği}. Dönüşüm: Basis(UP, yaw), yerel x sokaktan dışarı, yerel z
## sokak boyunca.
static func houses_in(z0: float, z1: float) -> Array:
	_ensure()
	var out: Array = []
	for h: Dictionary in _houses:
		var c: Vector2 = h["c"]
		if c.y >= z0 and c.y < z1:
			out.append(h)
	return out


static func house_count() -> int:
	_ensure()
	return _houses.size()


## Mese'nin revaklı kenarları mı (kenar indisi)
static func portico(ei: int) -> bool:
	_ensure()
	if _k[ei] != MESE:
		return false
	var m := (_p[_e[ei].x] + _p[_e[ei].y]) * 0.5
	return m.y < PORTICO_Z


## Şehrin görünen yüzeyi (World1453.surface_h ile aynı, şehir içinde): arazi ızgarasının köşeleri önbellekte
static func surf(x: float, z: float) -> float:
	if not World1453.in_city(x, z) or z > -3.0:
		return World1453.surface_h(x, z)
	if z < -700.0:
		return _grid_y(x, z, -760.0, -1780.0, 1520.0 / 52.0, 1080.0 / 36.0, 0)
	return _grid_y(x, z, -700.0, -700.0, 1400.0 / 56.0, 697.0 / 28.0, 1)


static func _grid_y(x: float, z: float, x0: float, z0: float, dx: float, dz: float, g: int) -> float:
	var fx := (x - x0) / dx
	var fz := (z - z0) / dz
	var i := floori(fx)
	var j := floori(fz)
	var u := fx - i
	var v := fz - j
	var hb := _corner(i + 1, j, x0, z0, dx, dz, g)
	var hc := _corner(i, j + 1, x0, z0, dx, dz, g)
	if u + v <= 1.0:
		var ha := _corner(i, j, x0, z0, dx, dz, g)
		return ha + (hb - ha) * u + (hc - ha) * v
	var hd := _corner(i + 1, j + 1, x0, z0, dx, dz, g)
	return hd + (hc - hd) * (1.0 - u) + (hb - hd) * (1.0 - v)


static func _corner(i: int, j: int, x0: float, z0: float, dx: float, dz: float, g: int) -> float:
	var k := Vector3i(i, j, g)
	if not _hc.has(k):
		_hc[k] = SiegeField.city_ground(x0 + i * dx, z0 + j * dz)
	return _hc[k]


# ---------------------------------------------------------------- kurulum

static func _ensure() -> void:
	if not _ok:
		_build()


## Düğümlerin yüksekliği: bölümün düz alanı ve rampası (SiegeField statikleri) değişince yeniden
static func _sync() -> void:
	_ensure()
	var sig := var_to_str([SiegeField.flat_rects, SiegeField.flat_y, SiegeField.flat_blend, SiegeField.blend_rects, SiegeField.world_on])
	if sig == _sig and not _graph.is_empty():
		return
	_sig = sig
	_hc.clear()
	var nodes := PackedVector3Array()
	nodes.resize(_p.size())
	for i in _p.size():
		nodes[i] = Vector3(_p[i].x, surf(_p[i].x, _p[i].y), _p[i].y)
	_graph = {"nodes": nodes, "edges": _e, "width": _w, "kind": _k}
	_plazas_out.clear()
	for pl: Dictionary in _plz:
		var c: Vector2 = pl["c"]
		_plazas_out.append({"name": pl["name"], "pos": Vector3(c.x, surf(c.x, c.y), c.y), "r": pl["r"], "kind": pl["kind"]})
	if _astar == null:
		_astar = AStar3D.new()
		_astar.reserve_space(_p.size())
		for i in _p.size():
			_astar.add_point(i, nodes[i])
		for e in _e:
			_astar.connect_points(e.x, e.y)
	else:
		for i in _p.size():
			_astar.set_point_position(i, nodes[i])


static func _build() -> void:
	_ok = true
	var t0 := Time.get_ticks_msec()
	var rng := RandomNumberGenerator.new()
	rng.seed = SEED
	# Anıt tabanları
	_foot.clear()
	for lm: Dictionary in Landmarks1453.footprints():
		_foot.append(lm)
	# Meydanlar
	_plz.clear()
	for pl: Array in PLAZAS:
		_plz.append({"name": pl[0], "c": Vector2(pl[1], pl[2]), "r": pl[3], "kind": pl[4]})
	# Ana yollar: her köşe arası ~22 m'lik düğümlere bölünür (kapı yolları hafifçe kıvrılır)
	for road: Array in MAIN:
		var kind: int = road[0]
		var pts: Array = road[1]
		var w := W_MESE if kind == MESE else W_ROAD
		for s in pts.size() - 1:
			var a: Vector2 = pts[s]
			var b: Vector2 = pts[s + 1]
			var n := maxi(1, roundi(a.distance_to(b) / 22.0))
			var side := (b - a).normalized().orthogonal()
			var prev := _node(a)
			for k in range(1, n + 1):
				var q := a.lerp(b, float(k) / n)
				if k < n and kind == ROAD:
					q += side * 2.2 * sin(q.x * 0.031 + q.y * 0.027)
				var cur := _node(q)
				_add_edge(prev, cur, w, kind)
				prev = cur
	var main_nodes := _p.size()
	# Ara sokak ızgarası
	var grid := {}
	var nz := int(ceil(-World1453.TIP.z / ROW)) + 1
	var nx := int(ceil(1400.0 / COL)) + 1
	for j in nz:
		for i in nx:
			var q := Vector2(-690.0 + 22.0 + i * COL + rng.randf_range(-12.0, 12.0), -34.0 - j * ROW + rng.randf_range(-10.0, 10.0))
			if not World1453.in_city(q.x, q.y, 16.0):
				continue
			if _near_main(q, 14.0) or _foot_hit(q, 8.0) or _plaza_hit(q, 6.0):
				continue
			grid[Vector2i(i, j)] = q
	var orphans: Array = []                    # [düğüm konumu, genişlik]
	for j in nz:
		for i in nx:
			var key := Vector2i(i, j)
			if not grid.has(key):
				continue
			for nb: Vector2i in [Vector2i(i + 1, j), Vector2i(i, j + 1)]:
				var drop := rng.randf() < 0.08
				var bend := rng.randf_range(-5.0, 5.0)
				if not grid.has(nb):
					continue
				var a: Vector2 = grid[key]
				var b: Vector2 = grid[nb]
				var across := nb.x != i
				var w := (W_SIDE if j % 3 == 0 else W_LANE) if across else (4.4 if i % 4 == 0 else W_LANE)
				if drop:
					continue
				if _crosses_main(a, b):
					orphans.append([a, w])
					orphans.append([b, w])
					continue
				if _seg_blocked(a, b, 3.0):
					continue
				var m := (a + b) * 0.5 + (b - a).normalized().orthogonal() * bend
				if _crosses_main(a, m) or _crosses_main(m, b) or not World1453.in_city(m.x, m.y, 14.0):
					m = (a + b) * 0.5
				var ia := _node(a)
				var im := _node(m)
				var ib := _node(b)
				_add_edge(ia, im, w, LANE)
				_add_edge(im, ib, w, LANE)
	# Ana yolu kesen ara sokakların uçları: en yakın ana yol düğümüne bağlanır
	for o: Array in orphans:
		var a: Vector2 = o[0]
		var ia := _node(a)
		var best := -1
		var bd := 70.0
		for n in main_nodes:
			var d := a.distance_to(_p[n])
			if d < bd and not _crosses_any(a, _p[n], ia, n) and not _seg_blocked(a, _p[n], 2.0):
				bd = d
				best = n
		if best >= 0:
			_add_edge(ia, best, o[1], LANE)
	# Bağlantısız parçalar ana ağa bağlanır ya da atılır
	_connect_islands()
	# Mahalle pazarları: hedefe en yakın, ana yoldan uzak, en az üç kollu kavşak
	for t: Vector2 in MARKETS:
		var best := -1
		var bd := 160.0
		for n in range(main_nodes, _p.size()):
			if _adj[n].size() < 3:
				continue
			var d := t.distance_to(_p[n])
			if d < bd and not _near_main(_p[n], 40.0) and not _plaza_hit(_p[n], 30.0) and not _foot_hit(_p[n], 20.0):
				bd = d
				best = n
		if best >= 0:
			_plz.append({"name": "Pazar", "c": _p[best], "r": 15.0, "kind": "market"})
	_index_nodes()
	_place_houses(rng)
	if OS.get_environment("WORLD_PROF") != "":
		print("PROF cityplan nodes=%d edges=%d houses=%d plazas=%d %dms" % [_p.size(), _e.size(), _houses.size(), _plz.size(), Time.get_ticks_msec() - t0])


static func _node(q: Vector2) -> int:
	var key := Vector2i(roundi(q.x * 2.0), roundi(q.y * 2.0))
	if _keys.has(key):
		return _keys[key]
	var i := _p.size()
	_p.append(q)
	_adj.append([])
	_keys[key] = i
	return i


static func _add_edge(a: int, b: int, w: float, kind: int) -> void:
	if a == b:
		return
	for ei: int in _adj[a]:
		var e := _e[ei]
		if e.x == b or e.y == b:
			return
	var ei := _e.size()
	_e.append(Vector2i(a, b))
	_w.append(w)
	_k.append(kind)
	_adj[a].append(ei)
	_adj[b].append(ei)
	_hash_edge(ei)


static func _hash_edge(ei: int) -> void:
	var a := _p[_e[ei].x]
	var b := _p[_e[ei].y]
	var g := _w[ei] * 0.5 + 1.0
	var c0 := _cell(Vector2(minf(a.x, b.x) - g, minf(a.y, b.y) - g))
	var c1 := _cell(Vector2(maxf(a.x, b.x) + g, maxf(a.y, b.y) + g))
	for i in range(c0.x, c1.x + 1):
		for j in range(c0.y, c1.y + 1):
			var k := Vector2i(i, j)
			if not _ecell.has(k):
				_ecell[k] = []
			_ecell[k].append(ei)


static func _edges_near(p: Vector2, r: float) -> Array:
	var out := {}
	var c0 := _cell(p - Vector2.ONE * r)
	var c1 := _cell(p + Vector2.ONE * r)
	for i in range(c0.x, c1.x + 1):
		for j in range(c0.y, c1.y + 1):
			for ei: int in _ecell.get(Vector2i(i, j), []):
				out[ei] = true
	return out.keys()


static func _edges_box(a: Vector2, b: Vector2, g: float) -> Array:
	var out := {}
	var c0 := _cell(Vector2(minf(a.x, b.x) - g, minf(a.y, b.y) - g))
	var c1 := _cell(Vector2(maxf(a.x, b.x) + g, maxf(a.y, b.y) + g))
	for i in range(c0.x, c1.x + 1):
		for j in range(c0.y, c1.y + 1):
			for ei: int in _ecell.get(Vector2i(i, j), []):
				out[ei] = true
	return out.keys()


static func _cell(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / CELL), floori(p.y / CELL))


static func _near_main(q: Vector2, margin: float) -> bool:
	for ei: int in _edges_near(q, margin + W_MESE):
		if _k[ei] != LANE and _seg_dist(q, _p[_e[ei].x], _p[_e[ei].y]) < _w[ei] * 0.5 + margin:
			return true
	return false


static func _crosses_main(a: Vector2, b: Vector2) -> bool:
	for ei: int in _edges_box(a, b, W_MESE):
		if _k[ei] == LANE:
			continue
		var c := _p[_e[ei].x]
		var d := _p[_e[ei].y]
		# Ana yolun içinden geçen (kesmeden yanından sürten) de sayılır
		if _seg_cross(a, b, c, d) or _seg_seg_dist(a, b, c, d) < _w[ei] * 0.5 + 1.5:
			return true
	return false


## a–b, düğümleri ia/ib olan yeni kenar: mevcut bir kenarı (ortak düğüm hariç) kesiyor mu
static func _crosses_any(a: Vector2, b: Vector2, ia: int, ib: int) -> bool:
	for ei: int in _edges_box(a, b, 2.0):
		var e := _e[ei]
		if e.x == ia or e.y == ia or e.x == ib or e.y == ib:
			continue
		if _seg_cross(a, b, _p[e.x], _p[e.y]) or _seg_seg_dist(a, b, _p[e.x], _p[e.y]) < _w[ei] * 0.5 + 1.0:
			return true
	return false


static func _foot_hit(q: Vector2, margin: float) -> bool:
	for f: Dictionary in _foot:
		if _foot_dist(f, q) < margin:
			return true
	return false


## Anıt tabanına uzaklık (içindeyse 0'ın altı)
static func _foot_dist(f: Dictionary, q: Vector2) -> float:
	if f.has("box"):
		return _pt_rect_dist(f["box"], q)
	return q.distance_to(f["c"]) - float(f["r"])


static func _plaza_hit(q: Vector2, margin: float) -> bool:
	for pl: Dictionary in _plz:
		if q.distance_to(pl["c"]) < float(pl["r"]) + margin:
			return true
	return false


## Parça bir anıtın ya da meydanın içinden geçiyor mu
static func _seg_blocked(a: Vector2, b: Vector2, margin: float) -> bool:
	for f: Dictionary in _foot:
		if f.has("box"):
			if _seg_rect_dist(f["box"], a, b) < margin:
				return true
		elif _seg_dist(f["c"], a, b) < float(f["r"]) + margin:
			return true
	for pl: Dictionary in _plz:
		if _seg_dist(pl["c"], a, b) < float(pl["r"]) + margin * 0.5:
			return true
	return false


static func _connect_islands() -> void:
	var comp := PackedInt32Array()
	comp.resize(_p.size())
	comp.fill(-1)
	var ncomp := 0
	for s in _p.size():
		if comp[s] >= 0:
			continue
		var stack := [s]
		comp[s] = ncomp
		while not stack.is_empty():
			var n: int = stack.pop_back()
			for ei: int in _adj[n]:
				var e := _e[ei]
				var o := e.y if e.x == n else e.x
				if comp[o] < 0:
					comp[o] = ncomp
					stack.append(o)
		ncomp += 1
	# Bileşen 0: Mese. Ötekiler en yakın 0 düğümüne (90 m içinde, kesişmeden) bağlanır; olmazsa atılır
	var main := 0
	for c in range(1, ncomp):
		var best := Vector2i(-1, -1)
		var bd := 90.0
		for n in _p.size():
			if comp[n] != c:
				continue
			for m in _p.size():
				if comp[m] != main:
					continue
				var d := _p[n].distance_to(_p[m])
				if d < bd and not _crosses_any(_p[n], _p[m], n, m) and not _seg_blocked(_p[n], _p[m], 2.0):
					bd = d
					best = Vector2i(n, m)
		if best.x >= 0:
			_add_edge(best.x, best.y, W_LANE, LANE)
			for n in _p.size():
				if comp[n] == c:
					comp[n] = main
	if OS.get_environment("WORLD_PROF") != "":
		var lost := 0
		for n in _p.size():
			if comp[n] != main:
				lost += 1
		print("PROF cityplan comps=%d lost_nodes=%d" % [ncomp, lost])
	# Kalan adalar: düğümleri ve kenarları atılır (dizin yeniden kurulur)
	var keep_e: Array[Vector2i] = []
	var keep_w := PackedFloat32Array()
	var keep_k := PackedInt32Array()
	var remap := PackedInt32Array()
	remap.resize(_p.size())
	var np := PackedVector2Array()
	for n in _p.size():
		if comp[n] == main:
			remap[n] = np.size()
			np.append(_p[n])
		else:
			remap[n] = -1
	for ei in _e.size():
		var e := _e[ei]
		if remap[e.x] >= 0 and remap[e.y] >= 0:
			keep_e.append(Vector2i(remap[e.x], remap[e.y]))
			keep_w.append(_w[ei])
			keep_k.append(_k[ei])
	_p = np
	_e = keep_e
	_w = keep_w
	_k = keep_k
	_adj.clear()
	for n in _p.size():
		_adj.append([])
	for ei in _e.size():
		_adj[_e[ei].x].append(ei)
		_adj[_e[ei].y].append(ei)
	_ecell.clear()
	for ei in _e.size():
		_hash_edge(ei)
	_keys.clear()


static func _index_nodes() -> void:
	_ncell.clear()
	for n in _p.size():
		var c := _cell(_p[n])
		if not _ncell.has(c):
			_ncell[c] = []
		_ncell[c].append(n)


# ---------------------------------------------------------------- evler

## Sokakların iki yanına sıra evler: önce Mese, sonra yollar, sonra sokaklar (köşede önce gelen kalır)
static func _place_houses(rng: RandomNumberGenerator) -> void:
	_houses.clear()
	_hcell.clear()
	# Meydanların çevresi: cephesi meydana bakan evler (forum ve pazar kapalı bir avlu gibi okunsun)
	for pl: Dictionary in _plz:
		if pl["kind"] == "harbor":
			continue
		var pc: Vector2 = pl["c"]
		var a := rng.randf() * TAU
		var end := a + TAU
		while a < end:
			var v: int = CityHouses.BY_KIND[ROAD][rng.randi() % CityHouses.BY_KIND[ROAD].size()]
			var sz := CityHouses.size(v)
			var rr := float(pl["r"]) + 3.2 + sz.x * 0.5
			var dir := Vector2.from_angle(a)
			var c := pc + dir * rr
			var obb := [c, dir.orthogonal(), sz.z * 0.5 + 0.1, sz.x * 0.5]
			var step := (sz.z + 0.8) / rr
			if _house_fits(obb):
				var hi := _houses.size()
				_houses.append({"c": c, "yaw": atan2(dir.x, dir.y) - PI * 0.5, "s": Vector3(sz.x, CityHouses.height(v), sz.z),
					"away": dir, "col": HOUSE_COLS[v % HOUSE_COLS.size()], "obb": obb, "v": v})
				_hash_house(hi)
				a += step
			else:
				a += 3.0 / rr
	var order: Array = []
	for kind in [MESE, ROAD, LANE]:
		for ei in _e.size():
			if _k[ei] == kind:
				order.append(ei)
	for ei: int in order:
		var a := _p[_e[ei].x]
		var b := _p[_e[ei].y]
		var len := a.distance_to(b)
		if len < 6.0:
			continue
		var dir := (b - a) / len
		var nrm := dir.orthogonal()
		var kind := _k[ei]
		var back := PORTICO_D if portico(ei) else 0.7
		for side: float in [-1.0, 1.0]:
			var t := rng.randf_range(0.5, 3.0)
			var tries := 0
			while t < len - 4.0 and tries < 40:
				tries += 1
				var gap := rng.randf()
				if gap < (0.03 if kind == MESE else 0.13):
					t += rng.randf_range(6.0, 15.0)      # bahçe, bostan
					continue
				# Örnek ev (CityHouses): sokak türüne göre; sığmazsa en küçükleri denenir
				var pool: Array = CityHouses.BY_KIND[kind]
				var tries_v: Array = [pool[rng.randi() % pool.size()], 0, 4]
				var placed := false
				for v: int in tries_v:
					var sz := CityHouses.size(v)
					var front := sz.z
					var depth := sz.x
					if t + front > len + 2.0:
						continue
					var away := nrm * side
					var c := a + dir * (t + front * 0.5) + away * (_w[ei] * 0.5 + back + depth * 0.5)
					var obb := [c, dir, front * 0.5 + 0.1, depth * 0.5]
					if _house_fits(obb):
						var hi := _houses.size()
						_houses.append({"c": c, "yaw": atan2(away.x, away.y) - PI * 0.5, "s": Vector3(depth, CityHouses.height(v), front),
							"away": away, "col": HOUSE_COLS[v % HOUSE_COLS.size()], "obb": obb, "v": v})
						_hash_house(hi)
						t += front + rng.randf_range(0.2, 1.4)
						placed = true
						break
				if not placed:
					t += 2.5


static func _house_fits(obb: Array) -> bool:
	var c: Vector2 = obb[0]
	var u: Vector2 = obb[1]
	var v := u.orthogonal()
	var hu: float = obb[2]
	var hv: float = obb[3]
	if not World1453.in_city(c.x, c.y, 12.0):
		return false
	for cx: float in [-1.0, 1.0]:
		for cz: float in [-1.0, 1.0]:
			var q := c + u * hu * cx + v * hv * cz
			if not World1453.in_city(q.x, q.y, 8.0):
				return false
	var rad := sqrt(hu * hu + hv * hv)
	for ei: int in _edges_near(c, rad + 2.0):
		var e := _e[ei]
		if _seg_rect_dist(obb, _p[e.x], _p[e.y]) < _w[ei] * 0.5 + 0.5:
			return false
	for pl: Dictionary in _plz:
		if _pt_rect_dist(obb, pl["c"]) < float(pl["r"]) + 1.0:
			return false
	for f: Dictionary in _foot:
		if f.has("box"):
			if _obb_overlap(obb, f["box"], 3.0):
				return false
		elif _pt_rect_dist(obb, f["c"]) < float(f["r"]) + 3.0:
			return false
	var c0 := _cell(c - Vector2.ONE * (rad + 1.0))
	var c1 := _cell(c + Vector2.ONE * (rad + 1.0))
	for i in range(c0.x, c1.x + 1):
		for j in range(c0.y, c1.y + 1):
			for hi: int in _hcell.get(Vector2i(i, j), []):
				if _obb_overlap(obb, _houses[hi]["obb"], 0.25):
					return false
	return true


static func _hash_house(hi: int) -> void:
	var obb: Array = _houses[hi]["obb"]
	var c: Vector2 = obb[0]
	var rad: float = sqrt(float(obb[2]) * float(obb[2]) + float(obb[3]) * float(obb[3]))
	var c0 := _cell(c - Vector2.ONE * rad)
	var c1 := _cell(c + Vector2.ONE * rad)
	for i in range(c0.x, c1.x + 1):
		for j in range(c0.y, c1.y + 1):
			var k := Vector2i(i, j)
			if not _hcell.has(k):
				_hcell[k] = []
			_hcell[k].append(hi)


# ---------------------------------------------------------------- geometri (2B: x, z)

static func _seg_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var l2 := ab.length_squared()
	if l2 < 1e-6:
		return p.distance_to(a)
	var t := clampf((p - a).dot(ab) / l2, 0.0, 1.0)
	return p.distance_to(a + ab * t)


## Kesişme (uçlar ortaksa sayılmaz)
static func _seg_cross(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> bool:
	if a.distance_to(c) < 0.6 or a.distance_to(d) < 0.6 or b.distance_to(c) < 0.6 or b.distance_to(d) < 0.6:
		return false
	var r := b - a
	var s := d - c
	var den := r.cross(s)
	if absf(den) < 1e-6:
		return false
	var t := (c - a).cross(s) / den
	var u := (c - a).cross(r) / den
	return t > 0.0 and t < 1.0 and u > 0.0 and u < 1.0


static func _seg_seg_dist(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> float:
	if _seg_cross(a, b, c, d):
		return 0.0
	# Ortak uçlu parçalar birbirine "değer" ama kesişmez: yalnız ortak olmayan uçlar ölçülür
	var shared := a.distance_to(c) < 0.6 or a.distance_to(d) < 0.6 or b.distance_to(c) < 0.6 or b.distance_to(d) < 0.6
	if shared:
		return INF
	return minf(minf(_seg_dist(a, c, d), _seg_dist(b, c, d)), minf(_seg_dist(c, a, b), _seg_dist(d, a, b)))


## Yönlü dikdörtgen: [orta, u (birim), yarı u, yarı v]; v = u.orthogonal()
static func _local(obb: Array, p: Vector2) -> Vector2:
	var u: Vector2 = obb[1]
	var q: Vector2 = p - (obb[0] as Vector2)
	return Vector2(q.dot(u), q.dot(u.orthogonal()))


static func _pt_rect_dist(obb: Array, p: Vector2) -> float:
	var q := _local(obb, p)
	var dx := absf(q.x) - float(obb[2])
	var dy := absf(q.y) - float(obb[3])
	if dx <= 0.0 and dy <= 0.0:
		return maxf(dx, dy)
	return Vector2(maxf(dx, 0.0), maxf(dy, 0.0)).length()


static func _seg_rect_dist(obb: Array, a: Vector2, b: Vector2) -> float:
	var qa := _local(obb, a)
	var qb := _local(obb, b)
	var hu: float = obb[2]
	var hv: float = obb[3]
	# Kesişme: Liang–Barsky kırpma
	var t0 := 0.0
	var t1 := 1.0
	var d := qb - qa
	var hit := true
	for ax in 2:
		var p0: float = qa[ax]
		var dd: float = d[ax]
		var h: float = hu if ax == 0 else hv
		if absf(dd) < 1e-9:
			if p0 < -h or p0 > h:
				hit = false
				break
		else:
			var ta := (-h - p0) / dd
			var tb := (h - p0) / dd
			t0 = maxf(t0, minf(ta, tb))
			t1 = minf(t1, maxf(ta, tb))
			if t0 > t1:
				hit = false
				break
	if hit:
		return 0.0
	var best := minf(_pt_rect_dist(obb, a), _pt_rect_dist(obb, b))
	for cx: float in [-1.0, 1.0]:
		for cz: float in [-1.0, 1.0]:
			best = minf(best, _seg_dist(Vector2(hu * cx, hv * cz), qa, qb))
	return best


static func _obb_overlap(A: Array, B: Array, grow: float) -> bool:
	var ua: Vector2 = A[1]
	var ub: Vector2 = B[1]
	var d: Vector2 = (B[0] as Vector2) - (A[0] as Vector2)
	for ax: Vector2 in [ua, ua.orthogonal(), ub, ub.orthogonal()]:
		var ra := float(A[2]) * absf(ua.dot(ax)) + float(A[3]) * absf(ua.orthogonal().dot(ax))
		var rb := float(B[2]) * absf(ub.dot(ax)) + float(B[3]) * absf(ub.orthogonal().dot(ax))
		if absf(d.dot(ax)) > ra + rb + grow:
			return false
	return true


# ---------------------------------------------------------------- döşeme

## Sokakların, kavşakların ve meydanların taş döşemesi (görünür; çarpışmasız: yürünen zemin arazinin kendisi).
## Yüzeyi 2 m'lik örneklerle izler, kenarı arazinin altına iner. free(x, z, pay): bölümün oynanış alanı dışı mı.
## Döşenen alanın dünya y'si World1453.surface_h'tır (parent dünya çerçevesinde olmalı).
static func build_paving(parent: Node3D, free: Callable) -> void:
	_sync()
	var cols := [Color("d8d4c8"), Color("c4b8a2"), Color("ab9f88")]
	var offs := [0.09, 0.07, 0.05]
	var pats := ["flagstone", "cobble", "cobble"]
	var sts: Array = []
	for k in 3:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		sts.append(st)
	var counts := [0, 0, 0]
	# Düğümde gelen en geniş yol: dar yol onun kenarında başlar
	var nodew := PackedFloat32Array()
	var nodek := PackedInt32Array()
	nodew.resize(_p.size())
	nodek.resize(_p.size())
	nodek.fill(LANE)
	for ei in _e.size():
		for n: int in [_e[ei].x, _e[ei].y]:
			if _w[ei] > nodew[n]:
				nodew[n] = _w[ei]
			nodek[n] = mini(nodek[n], _k[ei])
	for ei in _e.size():
		var kind := _k[ei]
		var w := _w[ei]
		var a := _p[_e[ei].x]
		var b := _p[_e[ei].y]
		var len := a.distance_to(b)
		var dir := (b - a) / len
		var ta := nodew[_e[ei].x] * 0.5 if nodew[_e[ei].x] > w + 0.1 else 0.0
		var tb := nodew[_e[ei].y] * 0.5 if nodew[_e[ei].y] > w + 0.1 else 0.0
		var L := len - ta - tb
		if L < 0.5:
			continue
		var n := int(ceil(L / [2.0, 2.5, 3.0][kind]))
		var m := int(ceil((w + 1.2) / 2.5))
		# Döşeme cephelere kadar (sokak + 0,6 m), kenarı 0,6 m'de arazinin altına iner
		var pw := w + 1.2
		var offs_x: Array = [-(pw * 0.5 + 0.6)]
		for c in m + 1:
			offs_x.append(-pw * 0.5 + pw * c / m)
		offs_x.append(pw * 0.5 + 0.6)
		var rows: Array = []
		for i in n + 1:
			var p := a + dir * (ta + L * i / n)
			if _in_plaza(p, -0.5) or not free.call(p.x, p.y, 3.0):
				rows.append(null)
				continue
			var row := PackedVector3Array()
			for c in offs_x.size():
				var o: float = offs_x[c]
				var q := p + dir.orthogonal() * o
				var skirt := c == 0 or c == offs_x.size() - 1
				row.append(Vector3(q.x, surf(q.x, q.y) + (-0.3 if skirt else offs[kind]), q.y))
			rows.append(row)
		for i in n:
			if not (rows[i] is PackedVector3Array and rows[i + 1] is PackedVector3Array):
				continue
			var r0: PackedVector3Array = rows[i]
			var r1: PackedVector3Array = rows[i + 1]
			for c in r0.size() - 1:
				_tri(sts[kind], r0[c], r1[c], r0[c + 1], cols[kind])
				_tri(sts[kind], r1[c], r1[c + 1], r0[c + 1], cols[kind])
				counts[kind] += 2
	# Kavşaklar ve dönemeçler: düğümde en geniş yolun rengiyle yuvarlak
	for nd in _p.size():
		var deg: int = _adj[nd].size()
		var turn := deg != 2
		if deg == 2:
			var e0 := _e[_adj[nd][0]]
			var e1 := _e[_adj[nd][1]]
			var d0 := (_p[e0.x if e0.y == nd else e0.y] - _p[nd]).normalized()
			var d1 := (_p[e1.x if e1.y == nd else e1.y] - _p[nd]).normalized()
			turn = d0.dot(d1) > -0.96
		if not turn or _in_plaza(_p[nd], -0.5) or not free.call(_p[nd].x, _p[nd].y, 3.0):
			continue
		var kind := nodek[nd]
		counts[kind] += _disc(sts[kind], _p[nd], nodew[nd] * 0.5 + 0.6, offs[kind] + 0.005, cols[kind], 14)
	# Meydanlar (Mese rengi, biraz üstte)
	for pl: Dictionary in _plz:
		var c: Vector2 = pl["c"]
		if not free.call(c.x, c.y, float(pl["r"]) + 2.0):
			continue
		counts[MESE] += _disc(sts[MESE], c, pl["r"], 0.12, cols[MESE], 32)
	for k in 3:
		if counts[k] == 0:
			continue
		var st: SurfaceTool = sts[k]
		var mi := MeshInstance3D.new()
		mi.name = "Paving%d" % k
		mi.mesh = st.commit()
		var mat := Props.mat(Color.WHITE, 0.0, false, pats[k], false).duplicate() as StandardMaterial3D
		mat.vertex_color_use_as_albedo = true
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_walk", true)        # WorldWalk: zemin arazinin kendisi (döşeme ince kaplama)
		parent.add_child(mi)


static func _in_plaza(p: Vector2, margin: float) -> bool:
	for pl: Dictionary in _plz:
		if p.distance_to(pl["c"]) < float(pl["r"]) + margin:
			return true
	return false


static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color) -> void:
	var n := (b - a).cross(c - a).normalized()
	if n.y < 0.0:
		n = -n
	for v: Vector3 in [a, b, c]:
		st.set_color(col)
		st.set_normal(n)
		st.add_vertex(v)


## Yüzeye oturan yuvarlak (halkalar 8 m'den seyrek değil), kenarı arazinin altına iner. Döner: üçgen sayısı
static func _disc(st: SurfaceTool, c: Vector2, r: float, off: float, col: Color, seg: int) -> int:
	var rings := maxi(1, int(ceil(r / 3.0)))
	var radii: Array = []
	for k in range(1, rings + 1):
		radii.append(r * k / rings)
	radii.append(r + 0.6)
	var center := Vector3(c.x, surf(c.x, c.y) + off, c.y)
	var prev := PackedVector3Array()
	var tris := 0
	for ri in radii.size():
		var rr: float = radii[ri]
		var ring := PackedVector3Array()
		for s in seg:
			var a := TAU * s / seg
			var q := c + Vector2(cos(a), sin(a)) * rr
			ring.append(Vector3(q.x, surf(q.x, q.y) + (-0.3 if ri == radii.size() - 1 else off), q.y))
		for s in seg:
			var s1 := (s + 1) % seg
			if ri == 0:
				_tri(st, center, ring[s], ring[s1], col)
				tris += 1
			else:
				_tri(st, prev[s], ring[s], prev[s1], col)
				_tri(st, ring[s], ring[s1], prev[s1], col)
				tris += 2
		prev = ring
	return tris
