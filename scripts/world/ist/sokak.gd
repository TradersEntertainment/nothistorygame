class_name IstSokak
extends RefCounted
## İstanbul v2 sokak ağı ve mahalle dokusu (yalnız VERİ: düğüm kurmaz; IstSehir.attach_v2 kurar).
##
## Dünya koordinatı (IstGeo: x = doğu × 0,5, z = −kuzey × 0,5). Evler ve sokaklar gerçek boyda (1:1).
## 1. Doluluk ızgarası (2 m): 0 boş, 1 yol, 2 ev, 3 anıt/sur bandı, 4 şehir dışı/deniz, 5 doku (bostan, harabe, kilise).
## 2. Sokaklar: Mese ve iki kolu (12–15 m), kapılardan Mese'ye inen yollar (6 m), Haliç kapılarından çıkan yokuşlar,
##    mahalle içi organik sokaklar (rastgele yürüyüş, ızgara değil; 3,5–5 m), yamaçta basamaklı sokak (eğim > %14).
## 3. Evler: sokak kenarında bitişik sıra (ortak duvar, aralık 0); sıralar arası ≥ 1,4 m geçit; cephe (+z) sokağa.
##    Yoğunluk IstGeo.mahalle'den: çarşı/sık/liman sıra ev, seyrek tek ev + bahçe, bostan/harabe/kır neredeyse boş.
## 4. Doku: boş kalan 40 m'lik karelere bostan, bağ, tarla, harabe, mahalle kilisesi/şapel, meydan/çeşme.
## Oynanış: her sıranın bir ucunda dükkânlı ev (sandık 1,0 → tente 2,2 → üst kat duvarı → çatı: IstEvler.climbs).

const G := 2.0
const MESE_W := 15.0
const YOL_W := 6.0
const SOKAK_W := 4.0

var x0 := 0.0
var z0 := 0.0
var nx := 0
var nz := 0
var occ := PackedByteArray()
var rid := PackedInt32Array()         # hücredeki yolun kimliği (−1 yok)
var streets: Array = []               # {pts: PackedVector2Array, w, tur, ad}
var houses: Array = []                # {c: Vector2, yaw, v, tip, sira: int}
var doku: Array = []                  # {tur, c: Vector2, alan: Vector2, yaw, tohum, mt}
var meydan: Array = []                # {c: Vector2, yaw, tohum}
var rows := 0
var _mcache := {}
var stats := {}


# ---------------------------------------------------------------- ızgara

func _ix(x: float, z: float) -> int:
	var i := int((x - x0) / G)
	var j := int((z - z0) / G)
	if i < 0 or j < 0 or i >= nx or j >= nz:
		return -1
	return j * nx + i


func cell(x: float, z: float) -> int:
	var k := _ix(x, z)
	return 4 if k < 0 else occ[k]


## Çokgeni tarama çizgisiyle doldur (val), yalnız 'from' değerli hücreleri değiştirir
func _fill_poly(poly: PackedVector2Array, val: int, from: int) -> void:
	for j in nz:
		var z := z0 + (j + 0.5) * G
		var xs: Array = []
		for a in poly.size():
			var p := poly[a]
			var q := poly[(a + 1) % poly.size()]
			if (p.y <= z and q.y > z) or (q.y <= z and p.y > z):
				xs.append(p.x + (z - p.y) / (q.y - p.y) * (q.x - p.x))
		xs.sort()
		for b in range(0, xs.size() - 1, 2):
			var i0 := maxi(0, int(ceil((float(xs[b]) - x0) / G - 0.5)))
			var i1 := mini(nx - 1, int(floor((float(xs[b + 1]) - x0) / G - 0.5)))
			for i in range(i0, i1 + 1):
				if occ[j * nx + i] == from:
					occ[j * nx + i] = val


## Kalın çizgi (genişlik w) hücrelerine val yaz; yol ise kimliğini de
func _stamp_seg(a: Vector2, b: Vector2, w: float, val: int, id := -1, only_free := false) -> void:
	var r := w * 0.5
	var lo := Vector2(minf(a.x, b.x) - r, minf(a.y, b.y) - r)
	var hi := Vector2(maxf(a.x, b.x) + r, maxf(a.y, b.y) + r)
	var i0 := maxi(0, int((lo.x - x0) / G))
	var i1 := mini(nx - 1, int((hi.x - x0) / G))
	var j0 := maxi(0, int((lo.y - z0) / G))
	var j1 := mini(nz - 1, int((hi.y - z0) / G))
	for j in range(j0, j1 + 1):
		for i in range(i0, i1 + 1):
			var c := Vector2(x0 + (i + 0.5) * G, z0 + (j + 0.5) * G)
			if c.distance_to(Geometry2D.get_closest_point_to_segment(c, a, b)) <= r:
				var k := j * nx + i
				if only_free and occ[k] != 0:
					continue
				if occ[k] == 4 and val != 3:
					continue
				occ[k] = val
				if id >= 0:
					rid[k] = id


func _stamp_disc(c: Vector2, r: float, val: int) -> void:
	_stamp_seg(c, c + Vector2(0.01, 0), r * 2.0, val)


## Döndürülmüş dikdörtgen (merkez c, eksenler u (en), v (derinlik), yarı boylar hx, hz) içindeki hücreler
func _rect_cells(c: Vector2, u: Vector2, v: Vector2, hx: float, hz: float) -> PackedInt32Array:
	var out := PackedInt32Array()
	var ext := absf(u.x) * hx + absf(v.x) * hz
	var ezt := absf(u.y) * hx + absf(v.y) * hz
	var i0 := maxi(0, int((c.x - ext - x0) / G))
	var i1 := mini(nx - 1, int((c.x + ext - x0) / G))
	var j0 := maxi(0, int((c.y - ezt - z0) / G))
	var j1 := mini(nz - 1, int((c.y + ezt - z0) / G))
	if c.x - ext < x0 or c.y - ezt < z0 or c.x + ext > x0 + nx * G or c.y + ezt > z0 + nz * G:
		out.append(-1)
	for j in range(j0, j1 + 1):
		for i in range(i0, i1 + 1):
			var d := Vector2(x0 + (i + 0.5) * G, z0 + (j + 0.5) * G) - c
			if absf(d.dot(u)) <= hx and absf(d.dot(v)) <= hz:
				out.append(j * nx + i)
	return out


# ---------------------------------------------------------------- kurulum

## foot: [Vector3(x, r, z)] anıt tabanları; bands: [[PackedVector2Array, yarı genişlik]] surlar (iç yanında boş şerit)
func build(foot: Array, bands: Array, gates: Array, tohum := 1453) -> void:
	var t0 := Time.get_ticks_msec()
	var poly := IstGeo.kiyi("yarimada")
	var gal := IstGeo.yol("galata_suru")
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for p in poly:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	for p in gal:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	x0 = lo.x - 20.0
	z0 = lo.y - 20.0
	nx = int((hi.x - lo.x + 40.0) / G) + 1
	nz = int((hi.y - lo.y + 40.0) / G) + 1
	occ.resize(nx * nz)
	occ.fill(4)
	rid.resize(nx * nz)
	rid.fill(-1)
	_fill_poly(poly, 0, 4)
	if gal.size() >= 3:
		_fill_poly(gal, 0, 4)
	# Deniz (kıyı çokgeni ile arazinin uyuşmadığı yerler) ve çok dik yerler (> %45: yar) kapalı
	for j in range(0, nz, 3):
		for i in range(0, nx, 3):
			var k := j * nx + i
			if occ[k] != 0:
				continue
			var x := x0 + (i + 0.5) * G
			var z := z0 + (j + 0.5) * G
			if IstGeo.su(x, z) or IstGeo.h(x, z) < 0.4:
				for b in 3:
					for a in 3:
						var kk := (j + b) * nx + i + a
						if j + b < nz and i + a < nx:
							occ[kk] = 4
	# Kıyıdan 6 m içeri (deniz surunun dibi) ve sur bantları
	for b: Array in bands:
		var pl: PackedVector2Array = b[0]
		for i in pl.size() - 1:
			_stamp_seg(pl[i], pl[i + 1], float(b[1]) * 2.0, 3)
	for f: Vector3 in foot:
		_stamp_disc(Vector2(f.x, f.z), f.y, 3)
	stats["izgara_ms"] = Time.get_ticks_msec() - t0
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum
	# 1) Mese ve kolları
	for ad: String in ["mese", "mese_kuzey", "mese_guney"]:
		var pl := IstGeo.yol(ad)
		if pl.size() >= 2:
			_add_street(_densify(pl, 14.0), MESE_W, "mese", ad, true)
	# 1b) Galata: rıhtımdan (zincirin ucu) kuleye çıkan ana yokuş ve onu kesen kıyı caddesi
	var zc := IstGeo.yol("zincir")
	var kule := IstGeo.w2(-487.0, 1890.0)
	if zc.size() >= 2:
		var rh := zc[zc.size() - 1]
		var gpts := PackedVector2Array()
		for k in 13:
			var t := k / 12.0
			var q := rh.lerp(kule, t) + Vector2(-(kule - rh).y, (kule - rh).x).normalized() * sin(t * PI * 2.0) * 12.0
			if cell(q.x, q.y) == 0:
				gpts.append(q)
		if gpts.size() >= 3:
			_add_street(gpts, YOL_W, "yol", "galata")
			var mid := gpts[gpts.size() / 2]
			var dd := (kule - rh).normalized()
			var cr := PackedVector2Array()
			for k in range(-10, 11):
				var q := mid + Vector2(-dd.y, dd.x) * k * 24.0 + dd * sin(k * 0.6) * 6.0
				if cell(q.x, q.y) == 0:
					cr.append(q)
				elif cr.size() >= 3:
					break
				else:
					cr.clear()
			if cr.size() >= 3:
				_add_street(cr, YOL_W, "yol", "galata")
	# 2) Kapılardan Mese'ye inen yollar ve Haliç yokuşları
	for g: Array in gates:
		_gate_road(g[0] as Vector2, String(g[1]), rng)
	# 3) Mahalle içi organik sokaklar (iki kuşak)
	var n0 := streets.size()
	for s in range(0, n0):
		_lanes_from(s, rng, 0)
	var n1 := streets.size()
	for s in range(n0, n1):
		_lanes_from(s, rng, 1)
	var n2 := streets.size()
	for s in range(n1, n2):
		_lanes_from(s, rng, 2)
	stats["sokak"] = streets.size()
	stats["sokak_ms"] = Time.get_ticks_msec() - t0
	# 4) Evler
	for s in streets.size():
		_houses_along(s, rng)
	stats["ev"] = houses.size()
	stats["sira"] = rows
	# 5) Doku
	_doku(rng)
	stats["doku"] = doku.size()
	stats["ms"] = Time.get_ticks_msec() - t0


func _mah(p: Vector2) -> Dictionary:
	var key := Vector2i(int(p.x / 24.0), int(p.y / 24.0))
	if not _mcache.has(key):
		_mcache[key] = IstGeo.mahalle(key.x * 24.0 + 12.0, key.y * 24.0 + 12.0)
	return _mcache[key]


func _densify(pl: PackedVector2Array, step: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in pl.size() - 1:
		var a := pl[i]
		var b := pl[i + 1]
		var n := maxi(1, int(ceil(a.distance_to(b) / step)))
		for k in n:
			out.append(a.lerp(b, float(k) / n))
	out.append(pl[pl.size() - 1])
	return out


func _add_street(pts: PackedVector2Array, w: float, tur: String, ad: String, force := false) -> int:
	var id := streets.size()
	# Eğim: basamaklı sokak
	var steep := false
	if tur == "sokak":
		for i in pts.size() - 1:
			var dh := absf(IstGeo.h(pts[i].x, pts[i].y) - IstGeo.h(pts[i + 1].x, pts[i + 1].y))
			if dh / maxf(pts[i].distance_to(pts[i + 1]), 0.1) > 0.14:
				steep = true
	streets.append({"pts": pts, "w": w, "tur": "basamak" if steep else tur, "ad": ad})
	for i in pts.size() - 1:
		_stamp_seg(pts[i], pts[i + 1], w + 1.0, 1, id, not force)
	return id


## Yolun hücresine yakın (r içinde) başka bir yol var mı: kimliğini döndür (yoksa −1)
func _road_near(p: Vector2, r: float, except: int) -> int:
	var i0 := int((p.x - r - x0) / G)
	var i1 := int((p.x + r - x0) / G)
	var j0 := int((p.y - r - z0) / G)
	var j1 := int((p.y + r - z0) / G)
	for j in range(maxi(j0, 0), mini(j1, nz - 1) + 1):
		for i in range(maxi(i0, 0), mini(i1, nx - 1) + 1):
			var k := j * nx + i
			if occ[k] == 1 and rid[k] != except and rid[k] >= 0:
				return rid[k]
	return -1


func _nearest_on(ad_list: Array, p: Vector2) -> Vector2:
	var best := Vector2.INF
	var bd := INF
	for s: Dictionary in streets:
		if not (String(s["tur"]) == "mese"):
			continue
		var pl: PackedVector2Array = s["pts"]
		for i in pl.size() - 1:
			var q := Geometry2D.get_closest_point_to_segment(p, pl[i], pl[i + 1])
			if q.distance_to(p) < bd:
				bd = q.distance_to(p)
				best = q
	return best


## Kapıdan şehre: kapı yerinden içeri doğru, Mese'ye (ya da yakın bir yola) organik bir yol
func _gate_road(g: Vector2, tur: String, rng: RandomNumberGenerator) -> void:
	var target := _nearest_on([], g)
	if target == Vector2.INF:
		return
	# Kapının iç yanında ilk boş nokta
	var dir := (target - g).normalized()
	var p := g
	var ok := false
	for k in 30:
		p = g + dir * (4.0 + k * 4.0)
		var c := cell(p.x, p.y)
		if c == 0 or c == 1:
			ok = true
			break
	if not ok:
		return
	var maxlen := 2600.0 if tur == "kara" else (700.0 if tur == "halic" else 900.0)
	var pts := PackedVector2Array([p])
	var head := (target - p).angle()
	var ph := rng.randf() * TAU
	var total := 0.0
	var w := YOL_W if tur != "halic" else 5.0
	while total < maxlen:
		var want := (target - p).angle()
		var diff := wrapf(want - head, -PI, PI)
		head += clampf(diff, -0.35, 0.35) + sin(total * 0.013 + ph) * 0.12
		var q := p + Vector2.from_angle(head) * 10.0
		var c := cell(q.x, q.y)
		if c == 4 or c == 3:
			# engel: hedefe doğrudan dön
			head = want + (0.6 if rng.randf() < 0.5 else -0.6)
			q = p + Vector2.from_angle(head) * 10.0
			c = cell(q.x, q.y)
			if c == 4 or c == 3:
				break
		pts.append(q)
		total += 10.0
		p = q
		var near := _road_near(q, w + 4.0, -1)
		if near >= 0 and total > 30.0:
			break
		if q.distance_to(target) < 8.0:
			pts.append(target)
			break
		if tur == "halic" and total > 160.0 and _road_near(q, 14.0, -1) >= 0:
			break
	if pts.size() >= 3:
		_add_street(pts, w, "yol", "kapi_" + tur)


## Bir sokağın kenarından organik dallar
func _lanes_from(s: int, rng: RandomNumberGenerator, kusak: int) -> void:
	var st: Dictionary = streets[s]
	var pl: PackedVector2Array = st["pts"]
	var w := float(st["w"])
	var acc := rng.randf_range(5.0, 25.0)
	var side := 1.0 if rng.randf() < 0.5 else -1.0
	for i in pl.size() - 1:
		var a := pl[i]
		var b := pl[i + 1]
		var L := a.distance_to(b)
		if L < 0.5:
			continue
		var d := (b - a) / L
		var t := 0.0
		while t < L:
			var p := a + d * t
			var m := _mah(p)
			var yog := float(m["yogunluk"])
			var tur := String(m["tur"])
			var spacing := 28.0 if tur == "carsi" else (34.0 if tur in ["sik", "liman"] else (80.0 if tur == "seyrek" else 170.0))
			if kusak > 0:
				spacing *= 1.35
			if kusak > 1 and not tur in ["carsi", "sik", "liman"]:
				t += 20.0
				continue
			if tur == "kir" or yog < 0.08:
				t += 20.0
				continue
			acc -= minf(L - t, 6.0)
			t += 6.0
			if acc > 0.0:
				continue
			acc = spacing * rng.randf_range(0.75, 1.3)
			side = -side
			var nrm := Vector2(-d.y, d.x) * side
			var head := (nrm.rotated(rng.randf_range(-0.45, 0.45))).angle()
			var start := p + nrm * (w * 0.5 + 1.0)
			var maxlen := (60.0 + yog * 180.0) * rng.randf_range(0.6, 1.2)
			_walk_lane(start, head, maxlen, s, rng, yog)


func _walk_lane(start: Vector2, head: float, maxlen: float, parent: int, rng: RandomNumberGenerator, yog: float) -> void:
	var pts := PackedVector2Array([start])
	var p := start
	var total := 0.0
	var ph := rng.randf() * TAU
	var wl := SOKAK_W + (1.0 if yog > 0.8 else 0.0)
	var joined := false
	while total < maxlen:
		head += rng.randf_range(-0.22, 0.22) + sin(total * 0.05 + ph) * 0.06
		var q := p + Vector2.from_angle(head) * 7.0
		var c := cell(q.x, q.y)
		if c == 4 or c == 3 or c == 2 or c == 5:
			break
		var near := _road_near(q, wl * 0.5 + 3.0, parent)
		if near >= 0 and total > 10.0:
			pts.append(q)
			joined = true
			break
		if near >= 0 and total <= 10.0:
			break
		pts.append(q)
		p = q
		total += 7.0
	if pts.size() >= 3 and total >= 18.0 or joined and pts.size() >= 3:
		_add_street(pts, wl, "sokak", "sokak")


# ---------------------------------------------------------------- evler

const VAR_WIDE := [1, 2, 3, 5, 6]

func _houses_along(s: int, rng: RandomNumberGenerator) -> void:
	var st: Dictionary = streets[s]
	var pl: PackedVector2Array = st["pts"]
	var w := float(st["w"])
	var stur := String(st["tur"])
	for side: float in [1.0, -1.0]:
		# Kısa parçaları birleştir: düzce giden bölümler (≤ 8° kırık) tek doğru boyunca
		var runs := _straight_runs(pl, 0.14)
		for r: Array in runs:
			var a: Vector2 = r[0]
			var b: Vector2 = r[1]
			var L := a.distance_to(b)
			if L < 4.0:
				continue
			var d := (b - a) / L
			var nrm := Vector2(-d.y, d.x) * side          # sokaktan uzağa
			var t := 1.5
			while t < L - 3.0:
				var p := a + d * t
				var m := _mah(p + nrm * 10.0)
				var yog := float(m["yogunluk"])
				var tur := String(m["tur"])
				if rng.randf() > yog * (1.15 if stur == "mese" else 1.0):
					t += rng.randf_range(4.0, 10.0) / maxf(yog, 0.15)
					continue
				var maxrow := 56.0 if tur == "carsi" else (36.0 if tur in ["sik", "liman"] else (10.0 if tur == "seyrek" else 9.0))
				var rowlen := minf(L - t - 0.5, maxrow * rng.randf_range(0.6, 1.0))
				var used := _row(a + d * t, d, nrm, w, rowlen, tur, rng)
				if used <= 0.0:
					t += 3.0
					continue
				t += used + (rng.randf_range(2.0, 3.5) if tur in ["carsi", "sik", "liman"] else rng.randf_range(6.0, 18.0))


func _straight_runs(pl: PackedVector2Array, tol: float) -> Array:
	var out: Array = []
	var i := 0
	while i < pl.size() - 1:
		var a := pl[i]
		var j := i + 1
		var d0 := (pl[j] - a).normalized()
		while j + 1 < pl.size() and absf((pl[j + 1] - pl[j]).normalized().angle_to(d0)) < tol and a.distance_to(pl[j + 1]) < 70.0:
			j += 1
		out.append([a, pl[j]])
		i = j
	return out


## Sokak kenarında bitişik sıra: p0 sıranın sokak cephesindeki başlangıcı, d sokak yönü, nrm sokaktan uzağa.
## Dönen: kullanılan cephe boyu (0: konmadı)
func _row(p0: Vector2, d: Vector2, nrm: Vector2, w: float, rowlen: float, tur: String, rng: RandomNumberGenerator) -> float:
	var vs: Array = []
	var total := 0.0
	var first: int = VAR_WIDE[rng.randi() % VAR_WIDE.size()]
	if tur in ["seyrek", "bostan", "harabe", "kir"]:
		first = [1, 1, 3][rng.randi() % 3]
	vs.append(first)
	total = IstEvler.dims(first).x
	while true:
		var v := rng.randi_range(0, IstEvler.variant_count() - 1)
		var wv := IstEvler.dims(v).x
		if total + wv > rowlen:
			break
		vs.append(v)
		total += wv
	if total > rowlen + 0.01 and vs.size() == 1 and rowlen < 4.0:
		return 0.0
	var front := w * 0.5 + 0.9                     # cephe sokak kenarından 0,4 m geride; cumba 0,7 taşar
	while not vs.is_empty():
		var dep := 0.0
		for v: int in vs:
			dep = maxf(dep, IstEvler.dims(v).z)
		var c := p0 + d * (total * 0.5) + nrm * (front + dep * 0.5)
		var cells := _rect_cells(c, d, nrm, total * 0.5, dep * 0.5)
		var ok := not cells.has(-1)
		if ok:
			for k in cells:
				if occ[k] != 0:
					ok = false
					break
		if ok:
			# 1,4 m'lik halka: başka ev yok (geçit ya bitişik ya ≥ 1,4)
			var ring := _rect_cells(c, d, nrm, total * 0.5 + 2.4, dep * 0.5 + 2.4)
			for k in ring:
				if k >= 0 and occ[k] == 2:
					ok = false
					break
		if ok:
			# Eğim sınırı: sıra boyunca 2,4 m'den fazla düşü yok
			var ha := IstGeo.h(p0.x + nrm.x * front, p0.y + nrm.y * front)
			var hb := IstGeo.h(p0.x + d.x * total + nrm.x * front, p0.y + d.y * total + nrm.y * front)
			if absf(ha - hb) > 2.4:
				ok = false
			# Arka köşeler cephe tabanından en çok 1,0 m yüksek (gömülü arka cephe yok)
			var back := front + dep
			for t in [0.0, total]:
				var hq := IstGeo.h(p0.x + d.x * t + nrm.x * back, p0.y + d.y * t + nrm.y * back)
				if hq - minf(ha, hb) > 1.0:
					ok = false
		if ok:
			for k in cells:
				occ[k] = 2
			var x := 0.0
			var yaw := atan2(-nrm.x, -nrm.y)
			var shop_i := 0
			for idx in vs.size():
				var v: int = vs[idx]
				var dm := IstEvler.dims(v)
				var hc := p0 + d * (x + dm.x * 0.5) + nrm * (front + dm.z * 0.5)
				var tip := "sira"
				if idx == shop_i and dm.x >= 6.0:
					tip = "dukkan"
				elif tur == "carsi" and dm.x >= 6.0 and rng.randf() < 0.5:
					tip = "dukkan"
				elif tur in ["sik", "liman"] and dm.x >= 6.0 and rng.randf() < 0.15:
					tip = "dukkan"
				var fr := p0 + d * (x + dm.x * 0.5) + nrm * front
				houses.append({"c": hc, "yaw": yaw, "v": v, "tip": tip, "sira": rows, "on": fr})
				x += dm.x
			rows += 1
			# Seyrek: evin arkasında bahçe
			if tur in ["seyrek", "bostan"] and rng.randf() < 0.7:
				var gc := c + nrm * (dep * 0.5 + 10.0)
				var gcells := _rect_cells(gc, d, nrm, 9.0, 8.0)
				var gok := not gcells.has(-1)
				for k in gcells:
					if gok and occ[k] != 0:
						gok = false
				if gok:
					for k in gcells:
						occ[k] = 5
					doku.append({"tur": "bahce", "c": gc, "alan": Vector2(16.0, 14.0), "yaw": atan2(-nrm.x, -nrm.y), "tohum": rng.randi() % 9973})
			return total
		total -= IstEvler.dims(vs.pop_back()).x
	return 0.0


# ---------------------------------------------------------------- doku (boş kareler)

const DT := 40.0

func _doku(rng: RandomNumberGenerator) -> void:
	var nkil := 0
	var nmey := 0
	for j in range(0, int(nz * G / DT)):
		for i in range(0, int(nx * G / DT)):
			var c := Vector2(x0 + (i + 0.5) * DT, z0 + (j + 0.5) * DT)
			var m := _mah(c)
			var tur := String(m["tur"])
			# Karede boş hücre oranı
			var cells := _rect_cells(c, Vector2.RIGHT, Vector2.DOWN, DT * 0.5 - 2.0, DT * 0.5 - 2.0)
			if cells.has(-1):
				continue
			var free := 0
			var road := 0
			for k in cells:
				if occ[k] == 0:
					free += 1
				elif occ[k] == 1:
					road += 1
			var fr := float(free) / maxf(cells.size(), 1)
			if fr < 0.55:
				# Sık dokunun içindeki küçük boşluk: meydan/çeşme ya da ağaçlı avlu
				if fr > 0.25 and road > 0 and tur in ["carsi", "sik", "liman"] and rng.randf() < 0.25:
					var mc := _free_spot(c, 7.0)
					if mc != Vector2.INF:
						_stamp_disc(mc, 6.0, 5)
						meydan.append({"c": mc, "yaw": rng.randf() * TAU, "tohum": rng.randi() % 9973})
						nmey += 1
				continue
			var roll := rng.randf()
			var alan := Vector2(DT - 8.0 - rng.randf() * 8.0, DT - 8.0 - rng.randf() * 8.0)
			var yaw := rng.randf_range(-0.3, 0.3)
			var u := Vector2.from_angle(-yaw)
			var v := Vector2(-u.y, u.x)
			# Kare içi tamamen boş değilse yamayı küçült
			var pc := _rect_cells(c, u, v, alan.x * 0.5, alan.y * 0.5)
			var ok := true
			for k in pc:
				if occ[k] != 0:
					ok = false
					break
			if not ok:
				alan *= 0.55
				pc = _rect_cells(c, u, v, alan.x * 0.5, alan.y * 0.5)
				ok = true
				for k in pc:
					if occ[k] != 0:
						ok = false
						break
				if not ok:
					continue
			var hs := [IstGeo.h(c.x - alan.x * 0.5, c.y - alan.y * 0.5), IstGeo.h(c.x + alan.x * 0.5, c.y - alan.y * 0.5),
				IstGeo.h(c.x - alan.x * 0.5, c.y + alan.y * 0.5), IstGeo.h(c.x + alan.x * 0.5, c.y + alan.y * 0.5)]
			var slope: float = hs.max() - hs.min()
			var pick := ""
			if tur in ["carsi", "sik", "liman"]:
				if nkil < 400 and roll < 0.35 and alan.x > 20.0:
					pick = ["kilise_kucuk", "sapel", "kilise_orta"][rng.randi() % 3]
				elif roll < 0.6:
					pick = "bahce"
				elif roll < 0.8:
					pick = "harabe"
				else:
					pick = "agaclik"
			elif tur == "seyrek":
				pick = ["bostan", "bag", "bahce", "agaclik", "harabe", "sapel"][rng.randi() % 6]
			elif tur == "harabe":
				pick = ["harabe", "harabe_tonoz", "harabe_kemer", "harabe_sutun", "harabe_sarmasik", "cayir", "agaclik"][rng.randi() % 7]
			elif tur == "bostan" or tur == "sur_dibi":
				pick = ["bostan", "bostan", "bag", "bugday", "cayir", "agaclik", "harabe", "bag"][rng.randi() % 8]
				if roll < 0.04:
					pick = "sapel"
			else:
				pick = ["cayir", "agaclik", "bugday"][rng.randi() % 3]
			if slope > 2.5 and pick in ["bostan", "bag", "bugday", "bahce", "cayir"]:
				pick = "agaclik"
			if pick in ["kilise_kucuk", "sapel", "kilise_orta"]:
				nkil += 1
			for k in pc:
				occ[k] = 5
			doku.append({"tur": pick, "c": c, "alan": alan, "yaw": yaw, "tohum": rng.randi() % 9973, "mt": tur})
	stats["kilise"] = nkil
	stats["meydan"] = nmey


func _free_spot(c: Vector2, r: float) -> Vector2:
	for k in 24:
		var p := c + Vector2.from_angle(k * 2.4) * (k * 0.8)
		var cells := _rect_cells(p, Vector2.RIGHT, Vector2.DOWN, r, r)
		var ok := not cells.has(-1)
		for q in cells:
			if ok and occ[q] != 0:
				ok = false
		if ok:
			return p
	return Vector2.INF


## Denetim için: sokak orta çizgisinin üstündeki noktalar (yürüyüş sınaması)
func street_points(step := 6.0) -> Array:
	var out: Array = []
	for s: Dictionary in streets:
		var pl: PackedVector2Array = s["pts"]
		for i in pl.size() - 1:
			var n := maxi(1, int(pl[i].distance_to(pl[i + 1]) / step))
			for k in n:
				out.append(pl[i].lerp(pl[i + 1], float(k) / n))
	return out
