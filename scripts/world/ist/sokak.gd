class_name IstSokak
extends RefCounted
## İstanbul v2 sokak ağı ve mahalle dokusu (VERİ; düğümleri IstSehir.attach_v2 ve IstMahalleDoku kurar).
##
## Dünya koordinatı IstGeo'dan (x = doğu × S, z = −kuzey × S). Evler ve sokaklar gerçek boyda (1:1).
## 1. Doluluk ızgarası (2 m): 0 boş, 1 yol, 2 ev, 3 anıt/sur bandı, 4 şehir dışı/deniz, 5 doku (bostan, harabe, kilise,
##    meydan), 6 avlu (ev sırasının arkasındaki duvarlı iç bahçe).
## 2. Sokaklar: Mese ve iki kolu (15 m; taş döşeme), kapılardan Mese'ye inen yollar (6 m; kaldırım taşı), Haliç/Marmara
##    deniz kapılarından yokuşlar, surların iç yüzü boyunca savunma yolu (4 m; sur ile ev sırası arası ~5–6 m), mahalle
##    içi organik sokaklar (rastgele yürüyüş, ızgara değil; 4–5 m; sıkıştırılmış toprak), yamaçta basamaklı sokak.
## 3. Evler: sokak kenarında bitişik sıra (ortak duvar, aralık 0); sıralar arası ya 0 (bitişik) ya ≥ 1,4 m geçit
##    (taban dikdörtgenleri arasındaki en kısa uzaklıkla, kesin); cephe (+z) sokağa. Tip ve kat mahalleye göre
##    (IstEvler.ornekler): çoğu 1–2 katlı; 3 katlı yalnız çarşıda ve Latin mahallelerinde; yoksul kulübe, avlulu konak,
##    han, fırın, demirci, ambar, harap ev. Sıranın arkasında avlu (duvar + kapı ağzı + ağaç/kuyu: IstMahalleDoku).
## 4. Doku: boş kalan 40 m'lik karelere bostan, bağ, tarla, bahçe, harabe, mahalle kilisesi/şapel, meydan/kuyu; evsiz
##    her kareye en az bir öğe (oge: kuyu, ağıl ve sürü, çiftlik evi, mezarlık, ayrıntı köşeleri…).
## Oynanış: her sıranın ilk evi sokaktan çatıya yol taşır (dükkân: sandık → tente; teras/kule: dış merdiven;
## sundurmalı ev: sıra → sundurma). Avlunun kapı ağzı var (çukur değil).

const G := 2.0
const MESE_W := 15.0
const YOL_W := 6.0
const SOKAK_W := 4.0
const SAVUNMA_W := 4.0
const GECIT := 1.4

var x0 := 0.0
var z0 := 0.0
var nx := 0
var nz := 0
var occ := PackedByteArray()
var rid := PackedInt32Array()         # hücredeki yolun kimliği (−1 yok)
var streets: Array = []               # {pts: PackedVector2Array, w, tur, ad}
var houses: Array = []                # {c: Vector2, yaw, v, tip, sira: int, on: Vector2}
var doku: Array = []                  # {tur, c: Vector2, alan: Vector2, yaw, tohum, mt}
var meydan: Array = []                # {c: Vector2, yaw, tohum}
var avlu: Array = []                  # {c, u, v, hx, hz, kapi: int (0 sol, 1 sağ, 2 arka), tohum, h: duvar yüksekliği, mt}
var oge: Array = []                   # {tur, c: Vector2, yaw, tohum} (IstMahalleDoku kurar)
var eser_meydan: Array = []           # [{id, c, r0 (taban), R (meydan dış), unlu}] (DOKU-3)
var zemin_ek: Array = []              # [{c, r, tur}] döşeli meydan diskleri (Augustaion, forumlar, kapı/iskele önleri)
var rows := 0
var _mcache := {}
var _rects := {}                      # Vector2i(16 m) → [[PackedVector2Array, sıra]]
var _halic := PackedVector2Array()
var stats := {}
var _son_red := ""
var _sira_bilgi: Array = []           # avlu için: [merkez, d, nrm, boy, derinlik, tür, sıra]


# ---------------------------------------------------------------- ızgara

func _ix(x: float, z: float) -> int:
	var i := int(floor((x - x0) / G))
	var j := int(floor((z - z0) / G))
	if i < 0 or j < 0 or i >= nx or j >= nz:
		return -1
	return j * nx + i


func cell(x: float, z: float) -> int:
	var k := _ix(x, z)
	return 4 if k < 0 else occ[k]


func cell_c(i: int, j: int) -> Vector2:
	return Vector2(x0 + (i + 0.5) * G, z0 + (j + 0.5) * G)


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
func _rect_cells(c: Vector2, u: Vector2, v: Vector2, hx: float, hz: float, pay := 0.0) -> PackedInt32Array:
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
			if absf(d.dot(u)) <= hx + pay and absf(d.dot(v)) <= hz + pay:
				out.append(j * nx + i)
	return out


static func _poly(c: Vector2, u: Vector2, v: Vector2, hx: float, hz: float) -> PackedVector2Array:
	return PackedVector2Array([c - u * hx - v * hz, c + u * hx - v * hz, c + u * hx + v * hz, c - u * hx + v * hz])


## Kesin aralık kuralı: yeni dikdörtgen başka sıraların/avluların dikdörtgenleriyle ya bitişik (≤ 5 cm, iç içe değil)
## ya da ≥ 1,4 m uzak. own: aynı sıra (bitişik sayılır)
func _gap_ok(pg: PackedVector2Array, own: int) -> bool:
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for p in pg:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	for j in range(floori((lo.y - 2.0) / 16.0), floori((hi.y + 2.0) / 16.0) + 1):
		for i in range(floori((lo.x - 2.0) / 16.0), floori((hi.x + 2.0) / 16.0) + 1):
			for r: Array in _rects.get(Vector2i(i, j), []):
				if int(r[1]) == own:
					continue
				var qlo: Vector2 = r[2]
				var qhi: Vector2 = r[3]
				if qlo.x > hi.x + GECIT or qlo.y > hi.y + GECIT or qhi.x < lo.x - GECIT or qhi.y < lo.y - GECIT:
					continue
				var q: PackedVector2Array = r[0]
				var ov := Geometry2D.intersect_polygons(pg, q)
				var alan := 0.0
				for o: PackedVector2Array in ov:
					alan += absf(_area(o))
				if alan > 0.02:
					_son_red = "ortusme_%s" % ("ayni_sokak" if int(r[1]) >= 0 else "x")
					stats["red_" + _son_red] = int(stats.get("red_" + _son_red, 0)) + (1 if own >= 0 else 0)
					return false
				var d := poly_gap(pg, q) if alan <= 0.02 else 0.0
				if d > 0.05 and d < GECIT:
					if own >= 0:
						stats["red_dar_%d" % int(d * 10.0)] = int(stats.get("red_dar_%d" % int(d * 10.0), 0)) + 1
					return false
	return true


static func _area(p: PackedVector2Array) -> float:
	var a := 0.0
	for i in p.size():
		a += p[i].cross(p[(i + 1) % p.size()])
	return a * 0.5


func _rect_add(pg: PackedVector2Array, own: int) -> void:
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for p in pg:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	for j in range(floori(lo.y / 16.0), floori(hi.y / 16.0) + 1):
		for i in range(floori(lo.x / 16.0), floori(hi.x / 16.0) + 1):
			var k := Vector2i(i, j)
			if not _rects.has(k):
				_rects[k] = []
			_rects[k].append([pg, own, lo, hi])


# ---------------------------------------------------------------- kurulum

## Surların iç yüzünün hattan uzaklığı (sur kesiti 1:1: iç sur yarı kalınlığı + iç merdiven payı)
const SUR_IC := {"kara_suru": 2.6, "blakherna_suru": 2.4, "marmara_suru": 1.8, "halic_suru": 1.6, "galata_suru": 1.8}

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
	_halic = IstGeo.yol("halic_suru")
	_fill_poly(poly, 0, 4)
	if gal.size() >= 3:
		_fill_poly(gal, 0, 4)
	# Deniz (kıyı çokgeni ile arazinin uyuşmadığı yerler) kapalı
	for j in range(0, nz, 3):
		for i in range(0, nx, 3):
			var k := j * nx + i
			if occ[k] != 0:
				continue
			var c := cell_c(i + 1, j + 1)
			if IstGeo.su(c.x, c.y) or IstGeo.h(c.x, c.y) < 0.4:
				for b in 3:
					for a in 3:
						if j + b < nz and i + a < nx:
							occ[(j + b) * nx + i + a] = 4
	# Sur bantları; iç yanda iç yüzden 1 m ötesi yeniden açılır (sur dibi evleri yaslanacak), köşe kuleleri kapalı
	for b: Array in bands:
		var pl: PackedVector2Array = b[0]
		for i in pl.size() - 1:
			_stamp_seg(pl[i], pl[i + 1], float(b[1]) * 2.0, 3)
	_sur_ic_ac(bands)
	if not _taban_kayitlardan():
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
	_galata_yollari()
	# 1c) Surların iç yüzü boyunca savunma yolu
	for ad: String in SUR_IC:
		_savunma_yolu(ad)
	# 2) Kapılardan Mese'ye inen yollar ve deniz kapılarından yokuşlar
	for g: Array in gates:
		_gate_road(g[0] as Vector2, String(g[1]), rng)
	# 3) Mahalle içi organik sokaklar (üç kuşak) ve boş kalan yerleri dolduran ek sokaklar
	var n0 := streets.size()
	for s in range(0, n0):
		_lanes_from(s, rng, 0)
	var n1 := streets.size()
	for s in range(n0, n1):
		_lanes_from(s, rng, 1)
	for pass_i in 3:
		_dolgu_sokaklari(rng, pass_i)
	stats["sokak"] = streets.size()
	stats["sokak_ms"] = Time.get_ticks_msec() - t0
	# 3b) Mahalle kiliseleri ve meydanları için yer (evlerden önce: sık dokuda da kalsın)
	_kilise_yerleri(rng)
	# 3c) Eser çevresi meydanları (DOKU-3, kalite notu 13): ünlü eserlerin çevresi evden önce ayrılır (döşeli meydan/avlu)
	_eser_meydanlari()
	# 4) Evler: önce savunma yolu ve büyük yollar (sıralar sura ve caddeye yaslansın), sonra sokaklar
	var order: Array = []
	for s in streets.size():
		order.append(s)
	var pri := {"savunma": 0, "mese": 1, "yol": 2, "sokak": 3, "basamak": 3}
	order.sort_custom(func(a: int, b: int) -> bool: return int(pri.get(String(streets[a]["tur"]), 3)) < int(pri.get(String(streets[b]["tur"]), 3)))
	for s: int in order:
		_houses_along(s, rng)
	# ikinci geçiş: kısa kalan yerlere (sokak sonlarında) tek ev / kısa sıra
	for s: int in order:
		_houses_along(s, rng, true)
	# avlular bütün sıralardan sonra (karşı sıranın derinliğini çalmasın)
	for sb: Array in _sira_bilgi:
		_avlu_ekle(sb[0], sb[1], sb[2], sb[3], sb[4], sb[5], sb[6], rng)
	stats["ev"] = houses.size()
	stats["sira"] = rows
	stats["avlu"] = avlu.size()
	# 5) Doku ve meydanlar
	_meydanlar(foot)
	_eser_meydan_doldur()
	_doku(rng)
	_ogeler(rng)
	stats["doku"] = doku.size()
	stats["oge"] = oge.size()
	stats["ms"] = Time.get_ticks_msec() - t0
	katman_bagla()


## Anıt tabanları: IstSehir v2 kayıtlarından (salt okunur) döndürülmüş dikdörtgen = gerçek ölçü × k + 6 m pay. Sınır
## çemberi (r) uzun/ince yapılarda (Bozdoğan kemeri r 158 m, zincir r 129 m) koca mahalleleri boşaltıyordu.
## Kayıt yoksa (eski çağrı) false: çağıran çemberleri damgalar.
func _taban_kayitlardan() -> bool:
	var s: Node = IstSehir.active
	if s == null or not is_instance_valid(s) or not IstSehir.v2:
		return false
	var n := 0
	for it: Dictionary in s.items:
		if it.has("hat"):
			continue
		var id := String(it["id"])
		var p: Vector3 = it["pos"]
		var c := Vector2(p.x, p.z)
		var r := float(it["r"])
		if id == "zincir" or id.begins_with("doku_") or id.begins_with("meydan_"):
			continue
		if id == "bozdogan":
			var pl := IstGeo.yol("bozdogan")
			for i in pl.size() - 1:
				_stamp_seg(pl[i], pl[i + 1], 16.0, 3)
			n += 1
			continue
		if id.begins_with("mese_"):
			_stamp_disc(c, r * 0.3, 3)
			n += 1
			continue
		var dt: Dictionary = it.get("data", {})
		var go: Vector3 = dt.get("gercek_olcu", Vector3.ZERO)
		var k := float(it.get("k", 1.0))
		if go.x <= 0.0 or go.z <= 0.0 or id == "ayasofya":
			_stamp_disc(c, r + 4.0, 3)
			n += 1
			continue
		var yaw := float(it.get("yaw", 0.0))
		var u := Vector2(cos(yaw), -sin(yaw))
		var v := Vector2(sin(yaw), cos(yaw))
		var hx := minf(go.x * k * 0.5 + 6.0, r + 4.0)
		var hz := minf(go.z * k * 0.5 + 6.0, r + 4.0)
		for kk in _rect_cells(c, u, v, hx, hz, 1.0):
			if kk >= 0 and occ[kk] != 4:
				occ[kk] = 3
		n += 1
	# Bölümlerin oynanış alanları (boş kalır)
	if s.has_method("oyun_alanlari"):
		for a: Rect2 in s.oyun_alanlari():
			var cc := a.get_center()
			for kk in _rect_cells(cc, Vector2.RIGHT, Vector2.DOWN, a.size.x * 0.5 + 2.0, a.size.y * 0.5 + 2.0):
				if kk >= 0 and occ[kk] != 4:
					occ[kk] = 3
	stats["taban"] = n
	return n > 0


func _sur_ic_ac(bands: Array) -> void:
	for ad: String in SUR_IC:
		var pl := IstGeo.yol(ad)
		if pl.size() < 2:
			continue
		var hw := 0.0
		for b: Array in bands:
			var bp: PackedVector2Array = b[0]
			if bp.size() == pl.size() and bp[0].is_equal_approx(pl[0]):
				hw = float(b[1])
		if hw <= 0.0:
			continue
		var face: float = SUR_IC[ad] + 1.0
		var gal := ad == "galata_suru"
		for i in pl.size() - 1:
			var a := pl[i]
			var b := pl[i + 1]
			var r := hw + 2.0
			var i0 := maxi(0, int((minf(a.x, b.x) - r - x0) / G))
			var i1 := mini(nx - 1, int((maxf(a.x, b.x) + r - x0) / G))
			var j0 := maxi(0, int((minf(a.y, b.y) - r - z0) / G))
			var j1 := mini(nz - 1, int((maxf(a.y, b.y) + r - z0) / G))
			for j in range(j0, j1 + 1):
				for ii in range(i0, i1 + 1):
					var k := j * nx + ii
					if occ[k] != 3:
						continue
					var c := cell_c(ii, j)
					var q := Geometry2D.get_closest_point_to_segment(c, a, b)
					var d := c.distance_to(q)
					if d <= face or d > hw + 1.0:
						continue
					if _sur_mesafe(c, ad, pl) <= face:
						continue
					var ic := IstGeo.galata_ici(c.x, c.y) if gal else IstGeo.sehir_ici(c.x, c.y)
					if ic and not IstGeo.su(c.x, c.y):
						occ[k] = 0
		# köşe kuleleri (IstSehir._sade köşeleri) kapalı kalsın
		var sade := _sade(pl)
		for p in sade:
			_stamp_disc(p, 9.5, 3)


func _sur_mesafe(c: Vector2, ad: String, pl: PackedVector2Array) -> float:
	return IstGeo.cizgi_uzak(c, pl)


static func _sade(pl: PackedVector2Array) -> PackedVector2Array:
	if pl.size() < 3:
		return pl
	var out := PackedVector2Array([pl[0]])
	var last := pl[0]
	for i in range(1, pl.size() - 1):
		var a := (pl[i] - last).normalized()
		var b := (pl[i + 1] - pl[i]).normalized()
		if absf(a.angle_to(b)) > deg_to_rad(7.0) or last.distance_to(pl[i]) > 260.0:
			out.append(pl[i])
			last = pl[i]
	out.append(pl[pl.size() - 1])
	return out


## Surun iç yüzüne paralel savunma yolu: yolun ekseni iç yüzden 3 m içeride (sur ile ev sırası arası ~5–6 m)
func _savunma_yolu(ad: String) -> void:
	var pl := IstGeo.yol(ad)
	if pl.size() < 2:
		return
	var gal := ad == "galata_suru"
	var dense := _densify(pl, 8.0)
	var off: float = SUR_IC[ad] + 3.0
	var run := PackedVector2Array()
	for i in dense.size():
		var a := dense[maxi(i - 1, 0)]
		var b := dense[mini(i + 1, dense.size() - 1)]
		var d := (b - a).normalized()
		var n := Vector2(-d.y, d.x)
		var t := dense[i] + n * 25.0
		var ic := IstGeo.galata_ici(t.x, t.y) if gal else IstGeo.sehir_ici(t.x, t.y)
		if not ic:
			n = -n
		var q := dense[i] + n * off
		var ok := cell(q.x, q.y) == 0 and IstGeo.cizgi_uzak(q, pl) > off - 1.5
		if ok:
			run.append(q)
		if (not ok or i == dense.size() - 1) and run.size() > 0:
			if run.size() >= 3:
				_add_street(run, SAVUNMA_W, "savunma", ad)
			run = PackedVector2Array()


func _galata_yollari() -> void:
	var zc := IstGeo.yol("zincir")
	var kule := IstGeo.w2(-487.0, 1890.0)
	if zc.size() < 2:
		return
	var rh := zc[zc.size() - 1]
	var gpts := PackedVector2Array()
	for k in 13:
		var t := k / 12.0
		var q := rh.lerp(kule, t) + Vector2(-(kule - rh).y, (kule - rh).x).normalized() * sin(t * PI * 2.0) * 12.0
		if cell(q.x, q.y) == 0:
			gpts.append(q)
	if gpts.size() < 3:
		return
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


func _mah(p: Vector2) -> Dictionary:
	var key := Vector2i(floori(p.x / 24.0), floori(p.y / 24.0))
	if not _mcache.has(key):
		_mcache[key] = IstGeo.mahalle(key.x * 24.0 + 12.0, key.y * 24.0 + 12.0)
	return _mcache[key]


## Mahalle türü (dünya dalının türlerine ek: yoğunluğa göre "orta"): carsi, sik, liman, orta, seyrek, bostan, harabe,
## sur_dibi, kir
func _tur(p: Vector2) -> String:
	var m := _mah(p)
	var t := String(m["tur"])
	var y := float(m["yogunluk"])
	match t:
		"seyrek":
			return "orta" if y >= 0.4 else "seyrek"
		"sik":
			return "orta" if y < 0.75 else "sik"
		"sarnic":
			return "bostan"
		"saray", "hipodrom":
			return "harabe"
		"ordugah", "koy", "bag", "orman":
			return "kir"
	return t


## Adanın alt türü (dünya dalı: "bag|meyve|bostan|manastir|harabe|mezarlik|cayir|tarla|…"; yoksa "")
func _alt(p: Vector2) -> String:
	return String(_mah(p).get("alt", ""))


func _yog(p: Vector2) -> float:
	var m := _mah(p)
	var t := String(m["tur"])
	var y := float(m["yogunluk"])
	# Sur içi sura kadar dolu (kalite notu 0b): yerleşik türlerde en az orta yoğunluk
	match t:
		"carsi": return maxf(y, 0.9)
		"sik", "liman": return maxf(y, 0.6)
		"seyrek": return maxf(y, 0.35)
		"sur_dibi": return maxf(y, 0.7)
		"harabe", "saray": return clampf(y, 0.12, 0.25)
		"bostan", "sarnic": return clampf(y, 0.05, 0.15)
		"hipodrom": return 0.0
	return y


func _latin(p: Vector2) -> bool:
	if IstGeo.galata_ici(p.x, p.y):
		return true
	var r := IstGeo.real(p.x, p.y)
	return r.x > -1250.0 and r.x < -200.0 and _halic.size() >= 2 and IstGeo.cizgi_uzak(p, _halic) < 520.0 * IstGeo.S


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
	var steep := false
	if tur == "sokak":
		for i in pts.size() - 1:
			var dh := absf(IstGeo.h(pts[i].x, pts[i].y) - IstGeo.h(pts[i + 1].x, pts[i + 1].y))
			if dh / maxf(pts[i].distance_to(pts[i + 1]), 0.1) > 0.14:
				steep = true
	streets.append({"pts": pts, "w": w, "tur": "basamak" if steep else tur, "ad": ad})
	for i in pts.size() - 1:
		_stamp_seg(pts[i], pts[i + 1], w + 0.4, 1, id, not force)
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


func _nearest_mese(p: Vector2) -> Vector2:
	var best := Vector2.INF
	var bd := INF
	for s: Dictionary in streets:
		if String(s["tur"]) != "mese":
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
	var target := _nearest_mese(g)
	if target == Vector2.INF:
		return
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
			head = want + (0.6 if rng.randf() < 0.5 else -0.6)
			q = p + Vector2.from_angle(head) * 10.0
			c = cell(q.x, q.y)
			if c == 4 or c == 3:
				break
		pts.append(q)
		total += 10.0
		p = q
		var near := _road_near(q, w + 4.0, -1)
		if near >= 0 and total > 30.0 and String(streets[near]["tur"]) != "savunma":
			break
		if q.distance_to(target) < 8.0:
			pts.append(target)
			break
		if tur == "halic" and total > 160.0 and _road_near(q, 14.0, -1) >= 0:
			break
	if pts.size() >= 3:
		_add_street(pts, w, "yol", "kapi_" + tur)
		# kapı önü: döşeli meydan ve ayrıntı köşesi
		zemin_ek.append({"c": pts[0], "r": 9.0, "tur": "yol"})
		oge.append({"tur": "set_sur_onarim_santiyesi" if tur == "kara" else ("set_balikci_iskelesi" if tur in ["halic", "marmara"] else "set_pazar_kosesi"),
			"c": pts[0], "yaw": (pts[1] - pts[0]).angle(), "tohum": rng.randi() % 9973, "yer": "kapi"})


## Sokak aralığı (m): yoğunluğa göre (ada derinliği ≈ aralık: iki sıra + avlu)
func _aralik(tur: String, yog: float) -> float:
	match tur:
		"carsi": return 30.0
		"sik", "liman": return 36.0
		"orta", "sur_dibi": return 44.0
		"seyrek": return 46.0 if yog >= 0.3 else 60.0
		"harabe": return 70.0
		"bostan": return 110.0
	return 9999.0


## Bir sokağın kenarından organik dallar
func _lanes_from(s: int, rng: RandomNumberGenerator, kusak: int) -> void:
	var st: Dictionary = streets[s]
	var pl: PackedVector2Array = st["pts"]
	var w := float(st["w"])
	var acc := rng.randf_range(5.0, 25.0)
	var side := 1.0 if rng.randf() < 0.5 else -1.0
	var savunma := String(st["tur"]) == "savunma"
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
			var yog := _yog(p)
			var tur := _tur(p)
			var spacing := _aralik(tur, yog) * (1.0 + 0.15 * kusak)
			if tur == "kir" or yog < 0.05:
				t += 20.0
				continue
			acc -= minf(L - t, 6.0)
			t += 6.0
			if acc > 0.0:
				continue
			acc = spacing * rng.randf_range(0.8, 1.2)
			side = -side
			var nrm := Vector2(-d.y, d.x) * side
			if savunma:
				# savunma yolundan yalnız şehrin içine
				var q := p + nrm * 20.0
				if cell(q.x, q.y) != 0:
					nrm = -nrm
			var head := (nrm.rotated(rng.randf_range(-0.35, 0.35))).angle()
			var start := p + nrm * (w * 0.5 + 1.0)
			var maxlen := (80.0 + yog * 220.0) * rng.randf_range(0.6, 1.2)
			_walk_lane(start, head, maxlen, s, rng, yog)


func _walk_lane(start: Vector2, head: float, maxlen: float, parent: int, rng: RandomNumberGenerator, yog: float) -> bool:
	var pts := PackedVector2Array([start])
	var p := start
	var total := 0.0
	var ph := rng.randf() * TAU
	var wl := SOKAK_W + (1.0 if yog > 0.8 else 0.0)
	var joined := false
	while total < maxlen:
		head += rng.randf_range(-0.07, 0.07) + sin(total * 0.035 + ph) * 0.045
		var q := p + Vector2.from_angle(head) * 7.0
		var c := cell(q.x, q.y)
		if c == 4 or c == 3 or c == 2 or c == 5 or c == 6:
			break
		var near := _road_near(q, wl * 0.5 + 3.0, parent)
		if near >= 0 and total > 10.0:
			pts.append(q)
			joined = true
			break
		if near >= 0 and total <= 10.0:
			break
		# 12 m içinde başka yol: ona doğru gidiyorsa sürsün (birleşir), paralel koşuyorsa dur
		if total > 14.0:
			var yk := _road_near(q + Vector2.from_angle(head) * 9.0, 4.0, parent)
			var yan := _road_near(q, 11.0, parent)
			if yan >= 0 and yk < 0:
				break
		pts.append(q)
		p = q
		total += 7.0
	if (pts.size() >= 3 and total >= 18.0) or (joined and pts.size() >= 3):
		_add_street(pts, wl, "sokak", "sokak")
		return true
	return false


## Boş kalan geniş yerlere ek sokak: yerleşik türlerde 30 × 30 m'den büyük boşluklar en yakın yola bağlanır
func _dolgu_sokaklari(rng: RandomNumberGenerator, pass_i: int) -> void:
	var step := 22.0
	var n := 0
	var j := 0.0
	while z0 + j < z0 + nz * G:
		var i := 0.0
		while x0 + i < x0 + nx * G:
			var p := Vector2(x0 + i + step * 0.5 + rng.randf_range(-5, 5), z0 + j + step * 0.5 + rng.randf_range(-5, 5))
			i += step
			if cell(p.x, p.y) != 0:
				continue
			var tur := _tur(p)
			var yog := _yog(p)
			if tur in ["kir", "bostan"] or yog < 0.18:
				continue
			var hal := _aralik(tur, yog) * 0.62
			# karenin büyük kısmı boş mu
			var cells := _rect_cells(p, Vector2.RIGHT, Vector2.DOWN, hal, hal)
			if cells.has(-1):
				continue
			var free := 0
			for k in cells:
				if occ[k] == 0:
					free += 1
			if float(free) / maxf(cells.size(), 1) < 0.85:
				continue
			# en yakın yol (8 yön, 90 m)
			var best := Vector2.INF
			var bdir := Vector2.ZERO
			for a in 8:
				var dv := Vector2.from_angle(a * TAU / 8.0 + rng.randf() * 0.3)
				for s in range(2, 46):
					var q := p + dv * s * 2.0
					var c := cell(q.x, q.y)
					if c == 1:
						if best == Vector2.INF or q.distance_to(p) < best.distance_to(p):
							best = q
							bdir = dv
						break
					if c != 0:
						break
			var start := p
			var head := rng.randf() * TAU
			if best != Vector2.INF:
				start = best - bdir * (SOKAK_W * 0.5 + 2.5)
				head = (-bdir).angle()
			if _walk_lane(start, head, 70.0 + yog * 160.0, _road_near(best, 3.0, -1) if best != Vector2.INF else -1, rng, yog):
				n += 1
		j += step
	stats["dolgu_%d" % pass_i] = n


# ---------------------------------------------------------------- evler

## Mahalleye göre ev seçimi: [v, tip]. idx: sıradaki yeri (0 ilk ev: sokaktan çatıya yolu taşır), onceki: önceki evin
## katı (sıra boyunca kat farkı ≤ 1)
func _sec(tur: String, latin: bool, idx: int, onceki: int, kalan: float, rng: RandomNumberGenerator, maxd := 99.0) -> Array:
	var r := rng.randf()
	var kat := 1
	var tip := "sira"
	match tur:
		"carsi":
			kat = 3 if r < 0.3 else (2 if r < 0.92 else 1)
		"liman":
			kat = (3 if r < 0.45 else 2) if latin else (2 if r < 0.7 else 1)
		"sik":
			kat = 3 if latin and r < 0.35 else (2 if r < 0.6 else 1)
		"orta", "sur_dibi":
			kat = 2 if r < 0.4 else 1
		"seyrek":
			kat = 2 if r < 0.2 else (1 if r < 0.8 else 0)
		"harabe", "bostan":
			kat = 1 if r < 0.55 else 0
		_:
			kat = 1
	if onceki >= 0 and absi(kat - onceki) > 1:
		kat = onceki + signi(kat - onceki)
	var r2 := rng.randf()
	var minw := 0.0
	if idx == 0:
		# sıranın ilk evi: sokaktan çatıya yol
		if tur in ["carsi", "liman", "sik"] or (tur == "orta" and r2 < 0.4):
			tip = "dukkan"
			kat = maxi(kat, 1)
			minw = 6.0
		elif tur == "sur_dibi" and r2 < 0.35:
			tip = "kule"
			kat = 3
			minw = 6.0
		else:
			tip = "teras"
			kat = 1
			minw = 5.0
	elif rng.randf() < (0.3 if tur == "harabe" else 0.045):
		# 1453: terk edilmiş / harap ev
		tip = "harap"
		kat = clampi(kat, 1, 2)
	elif latin and kat >= 2 and rng.randf() < 0.55:
		tip = "latin"
	else:
		if tur == "carsi" and r2 < 0.45 and kat >= 1:
			tip = "dukkan"; minw = 6.0
		elif tur in ["carsi", "liman"] and r2 < 0.5 and kat == 2 and rng.randf() < 0.08:
			tip = "han"; minw = 10.0
		elif tur == "liman" and r2 < 0.18:
			tip = "ambar"; kat = maxi(kat, 1); minw = 7.0
		elif latin and kat >= 2 and r2 < 0.5:
			tip = "latin"
		elif tur in ["sik", "orta"] and r2 < 0.04 and kat >= 1:
			tip = "konak"; kat = 2; minw = 10.0
		elif tur in ["sik", "orta", "carsi"] and r2 < 0.09:
			tip = "firin"; kat = 1; minw = 6.0
		elif tur in ["sik", "orta", "sur_dibi"] and r2 < 0.13:
			tip = "demirci"; kat = 1; minw = 6.0
		elif tur in ["sik", "liman"] and r2 < 0.22 and kat >= 1:
			tip = "dukkan"; minw = 6.0
		elif r2 < (0.35 if tur == "harabe" else 0.06):
			tip = "harap"; kat = clampi(kat, 1, 2)
		elif kat == 0:
			tip = "kulube"
		elif kat == 1 and r2 < 0.2:
			tip = "teras"
	var maxw := 10.0 if tip in ["han", "konak"] else 9.0
	if tip in ["han", "konak"]:
		maxw = 12.0
	var cand := IstEvler.ornekler(kat, minw, minf(maxw, kalan), maxd)
	if cand.is_empty() and tip in ["han", "konak"]:
		tip = "sira"
		cand = IstEvler.ornekler(kat, 0.0, minf(9.0, kalan), maxd)
	if cand.is_empty() and kat >= 2:
		kat = 1
		if tip in ["latin", "ambar"]:
			tip = "sira"
		cand = IstEvler.ornekler(kat, minw, kalan, maxd)
	if cand.is_empty():
		cand = IstEvler.ornekler(kat, 0.0, kalan, maxd)
	if cand.is_empty() and kat == 1 and maxd >= 5.0:
		tip = "kulube"
		cand = IstEvler.ornekler(0, 0.0, kalan, maxd)
	if cand.is_empty():
		return []
	return [cand[rng.randi() % cand.size()], tip]


func _houses_along(s: int, rng: RandomNumberGenerator, ikinci := false) -> void:
	var st: Dictionary = streets[s]
	var pl: PackedVector2Array = st["pts"]
	var w := float(st["w"])
	var stur := String(st["tur"])
	for side: float in [1.0, -1.0]:
		var runs := _straight_runs(pl, 0.2)
		for r: Array in runs:
			var a: Vector2 = r[0]
			var b: Vector2 = r[1]
			var L := a.distance_to(b)
			if L < 4.0:
				continue
			var d := (b - a) / L
			var nrm := Vector2(-d.y, d.x) * side          # sokaktan uzağa
			var t := 0.5
			while t < L - 3.0:
				var p := a + d * t
				var q := p + nrm * 10.0
				var yog := _yog(q)
				var tur := _tur(q)
				if stur == "savunma":
					tur = "sur_dibi" if tur in ["bostan", "harabe", "kir", "seyrek"] else tur
					yog = maxf(yog, 0.9)
				var dolu := clampf(yog * 1.5, 0.0, 1.0)
				if ikinci:
					dolu = clampf(yog, 0.0, 0.9)
				if rng.randf() > dolu:
					t += rng.randf_range(3.0, 8.0) / maxf(yog, 0.2)
					continue
				var maxrow := 60.0 if tur == "carsi" else (48.0 if tur in ["sik", "liman", "sur_dibi"] else (36.0 if tur == "orta" else (16.0 if tur == "seyrek" else 10.0)))
				if stur == "savunma":
					maxrow = 54.0
				var rowlen := minf(L - t - 0.5, maxrow * rng.randf_range(0.6, 1.0))
				var used := _row(a + d * t, d, nrm, w, rowlen, tur, _latin(q), rng)
				if used <= 0.0:
					t += 2.0
					continue
				var dense := tur in ["carsi", "sik", "liman", "sur_dibi", "orta"]
				if dense and rng.randf() < 0.7:
					t += used                           # sıra bitişik sürer (aralık 0)
				elif dense:
					t += used + rng.randf_range(GECIT + 0.2, 3.6)
				else:
					t += used + rng.randf_range(5.0, 16.0)


func _straight_runs(pl: PackedVector2Array, tol: float) -> Array:
	var out: Array = []
	var i := 0
	while i < pl.size() - 1:
		var a := pl[i]
		var j := i + 1
		var d0 := (pl[j] - a).normalized()
		while j + 1 < pl.size() and absf((pl[j + 1] - pl[j]).normalized().angle_to(d0)) < tol and a.distance_to(pl[j + 1]) < 80.0:
			j += 1
		out.append([a, pl[j]])
		i = j
	return out


## Sokak kenarında bitişik sıra: p0 sıranın sokak cephesindeki başlangıcı, d sokak yönü, nrm sokaktan uzağa.
## Dönen: kullanılan cephe boyu (0: konmadı)
func _row(p0: Vector2, d: Vector2, nrm: Vector2, w: float, rowlen: float, tur: String, latin: bool, rng: RandomNumberGenerator) -> float:
	var vs: Array = []                     # [v, tip]
	var total := 0.0
	var onceki := -1
	var front0 := w * 0.5 + 0.9
	# arkadaki boş derinlik (sıra boyunca üç örnek): ev derinliği buna göre; arkada ≥ 1,4 m geçit kalır
	var maxd := 12.0
	for tt: float in [0.5, rowlen * 0.5, maxf(rowlen - 0.5, 0.5)]:
		var q0 := p0 + d * tt + nrm * front0
		var dd := 0.0
		while dd < 13.5:
			var qq := q0 + nrm * (dd + 0.5)
			var cv := cell(qq.x, qq.y)
			if cv != 0 and not (cv == 1 and dd < 2.0):
				break
			dd += 1.0
		maxd = minf(maxd, dd - (0.0 if dd >= 13.5 else 1.8))
	if maxd < 4.9:
		return 0.0
	while total < rowlen:
		var sec := _sec(tur, latin, vs.size(), onceki, rowlen - total, rng, maxd)
		if sec.is_empty():
			break
		var dm := IstEvler.dims(int(sec[0]))
		if total + dm.x > rowlen + 0.01:
			break
		vs.append(sec)
		total += dm.x
		onceki = 0 if dm.y < 3.0 else (1 if dm.y < 4.6 else (2 if dm.y < 7.0 else 3))
	if vs.is_empty():
		return 0.0
	var front := w * 0.5 + 0.9                     # cephe sokak kenarından 0,4 m geride; çıkma 0,7 taşar
	var yaw := atan2(-nrm.x, -nrm.y)
	# Dış taş merdivenli ev (teras/kule): merdiven evin yerel +x yanında; sıranın DIŞ ucuna gelsin, sıra içinde 1,0 m pay
	var lx := Vector2(cos(yaw), -sin(yaw))
	var merd := String((vs[0] as Array)[1]) in ["teras", "kule"]
	var merd_son := merd and lx.dot(d) > 0.0
	if merd_son:
		vs.append(vs.pop_front())
	var bas_pay := 1.0 if merd and not merd_son else 0.0
	var son_pay := 1.0 if merd_son else 0.0
	while not vs.is_empty():
		if merd_son and String((vs[vs.size() - 1] as Array)[1]) not in ["teras", "kule"]:
			son_pay = 0.0
		if merd and not merd_son and String((vs[0] as Array)[1]) not in ["teras", "kule"]:
			bas_pay = 0.0
		var dep := 0.0
		for sv: Array in vs:
			dep = maxf(dep, IstEvler.dims(int(sv[0])).z)
		var tl := total + bas_pay + son_pay
		var c := p0 + d * (tl * 0.5) + nrm * (front + dep * 0.5)
		var cells := _rect_cells(c, d, nrm, tl * 0.5, dep * 0.5, -0.45)
		var ok := not cells.has(-1)
		if ok:
			for k in cells:
				if occ[k] != 0:
					ok = false
					break
		var pgs: Array = []
		if ok:
			var x0_ := bas_pay
			for sv: Array in vs:
				var dm0 := IstEvler.dims(int(sv[0]))
				var hc0 := p0 + d * (x0_ + dm0.x * 0.5) + nrm * (front + dm0.z * 0.5)
				var pg0 := _poly(hc0, d, nrm, dm0.x * 0.5, dm0.z * 0.5)
				pgs.append(pg0)
				x0_ += dm0.x
				if not _gap_ok(pg0, -2):
					ok = false
					break
			# merdiven payı (1,0 m × ev derinliği): sıranın ucunda, komşuya ya bitişik ya ≥ 1,4 m
			if ok and (bas_pay > 0.0 or son_pay > 0.0):
				var mx := 0.5 if bas_pay > 0.0 else tl - 0.5
				var mdep := IstEvler.dims(int((vs[0] if bas_pay > 0.0 else vs[vs.size() - 1])[0])).z
				var pgm := _poly(p0 + d * mx + nrm * (front + mdep * 0.5), d, nrm, 0.5, mdep * 0.5)
				pgs.append(pgm)
				if not _gap_ok(pgm, -2):
					ok = false
		if ok:
			# Eğim sınırı: sıra boyunca 2,4 m'den fazla düşü yok; arka köşeler cephe tabanından en çok 1,0 m yüksek
			var ha := IstGeo.h(p0.x + nrm.x * front, p0.y + nrm.y * front)
			var hb := IstGeo.h(p0.x + d.x * tl + nrm.x * front, p0.y + d.y * tl + nrm.y * front)
			if absf(ha - hb) > 2.4:
				ok = false
			var back := front + dep
			for tt in [0.0, tl]:
				var hq := IstGeo.h(p0.x + d.x * tt + nrm.x * back, p0.y + d.y * tt + nrm.y * back)
				if hq - minf(ha, hb) > 1.0:
					ok = false
		if ok:
			for k in _rect_cells(c, d, nrm, tl * 0.5, dep * 0.5, -0.2):
				occ[k] = 2
			for pg0: PackedVector2Array in pgs:
				_rect_add(pg0, rows)
			var x := bas_pay
			for sv: Array in vs:
				var v: int = sv[0]
				var dm := IstEvler.dims(v)
				var hc := p0 + d * (x + dm.x * 0.5) + nrm * (front + dm.z * 0.5)
				var fr := p0 + d * (x + dm.x * 0.5) + nrm * front
				houses.append({"c": hc, "yaw": yaw, "v": v, "tip": String(sv[1]), "sira": rows, "on": fr})
				x += dm.x
			_sira_bilgi.append([c, d, nrm, tl, dep, tur, rows])
			rows += 1
			return tl
		# küçült: merdivenli ev (sokaktan çatıya yol) sırada kalsın
		var ci := vs.size() - 1
		if merd_son and vs.size() > 1:
			ci = vs.size() - 2
		total -= IstEvler.dims(int((vs[ci] as Array)[0])).x
		vs.remove_at(ci)
	return 0.0


## Sıranın arkasında avlu: duvar (sık dokuda 2,4 m, seyrekte 1,0 m) + kapı ağzı (1,6 m) + içte ağaç/kuyu/ayrıntı
func _avlu_ekle(c: Vector2, d: Vector2, nrm: Vector2, total: float, dep: float, tur: String, row: int, rng: RandomNumberGenerator) -> void:
	if tur in ["kir"] or total < 5.0:
		return
	var dense := tur in ["carsi", "sik", "liman", "sur_dibi", "orta"]
	# arkadaki boş derinlik (iki örnek): avlu bloğun içini doldursun, karşıdaki yapıyla arada ≥ 1,4 m kalsın
	var bos := 16.0
	for tt: float in [-0.35, 0.35]:
		var q0 := c + d * (total * tt) + nrm * (dep * 0.5)
		var dd := 0.0
		while dd < 16.0:
			var qq := q0 + nrm * (dd + 0.5)
			if cell(qq.x, qq.y) != 0:
				break
			dd += 1.0
		bos = minf(bos, dd - (0.0 if dd >= 16.0 else 1.7))
	var hz_list: Array = []
	var az0 := minf(bos, 14.0 if dense else 16.0)
	while az0 >= 2.5:
		hz_list.append(az0)
		az0 -= 1.25
	var denemeler: Array = []
	for az: float in hz_list:
		for ic: float in [0.0, 2.0]:
			denemeler.append([az, ic])
	for dn: Array in denemeler:
		var az: float = dn[0]
		var ic: float = dn[1]
		if az < 2.5 or az > bos + 0.01 or total * 0.5 - ic < 3.0:
			continue
		var ac := c + nrm * (dep * 0.5 + az * 0.5)
		var cells := _rect_cells(ac, d, nrm, total * 0.5 - ic, az * 0.5, -0.45)
		if cells.has(-1):
			continue
		var ok := true
		for k in cells:
			if occ[k] != 0:
				ok = false
				break
		if not ok:
			stats["avlu_red_hucre"] = int(stats.get("avlu_red_hucre", 0)) + 1
			continue
		var pg := _poly(ac, d, nrm, total * 0.5 - ic, az * 0.5)
		if not _gap_ok(pg, row):
			stats["avlu_red_aralik"] = int(stats.get("avlu_red_aralik", 0)) + 1
			continue
		# yamaç: avlunun arka kenarı en çok 1,6 m yüksekte (duvar ve kapı ağzı oturur)
		var hf := IstGeo.h(ac.x - nrm.x * az * 0.5, ac.y - nrm.y * az * 0.5)
		var hb := IstGeo.h(ac.x + nrm.x * az * 0.5, ac.y + nrm.y * az * 0.5)
		if absf(hb - hf) > 1.6:
			stats["avlu_red_egim"] = int(stats.get("avlu_red_egim", 0)) + 1
			continue
		for k in cells:
			occ[k] = 6
		_rect_add(pg, row)
		avlu.append({"c": ac, "u": d, "v": nrm, "hx": total * 0.5 - ic, "hz": az * 0.5, "kapi": rng.randi() % 3,
			"tohum": rng.randi() % 9973, "h": 2.4 if dense else 1.0, "mt": tur})
		return


# ---------------------------------------------------------------- meydanlar, doku, öğeler

## Anıt çevresi döşeme ve ayrıntı (kalite notu 6, 7): Ayasofya (Augustaion, patrikhane ek yapıları, mumcular), forumlar
func _meydanlar(foot: Array) -> void:
	var anit := {"ayasofya": Vector2(0, 0), "augustaion": Vector2(-40.0, -150.0), "konstantin": Vector2(-756.0, -11.0),
		"tauri": Vector2(-1554.0, 211.0), "arkadius": Vector2(-3419.0, -678.0), "bovis": Vector2(-2705.0, -11.0),
		"amastrianon": Vector2(-2370.0, 100.0), "philadelphion": Vector2(-1739.0, 545.0)}
	var n := 0
	for ad: String in anit:
		var r: Vector2 = anit[ad]
		var w := IstGeo.w2(r.x, r.y)
		var fr := 0.0
		for f: Vector3 in foot:
			if Vector2(f.x, f.z).distance_to(w) < 30.0:
				fr = maxf(fr, f.y)
		var rad := fr + (26.0 if ad == "ayasofya" else 16.0)
		zemin_ek.append({"c": w, "r": rad, "tur": "mese"})
		# çevrede ayrıntı köşeleri (boş hücrelere)
		if ad == "ayasofya":
			_patrikhane(w, rad)
		if ad != "ayasofya":
			_kare_doldur(w, maxf(fr - 2.0, 0.0), rad, ad, n * 101)
		var sets := ["set_pazar_kosesi", "set_ayin_alayi", "set_meyhane_onu"] if ad != "ayasofya" else ["set_ayin_alayi", "set_pazar_kosesi", "mumcu", "set_manastir_avlusu", "mumcu"]
		for k in sets.size():
			var ang := k * TAU / sets.size() + 0.4
			var p := w + Vector2.from_angle(ang) * (fr + 10.0)
			if cell(p.x, p.y) in [0, 1]:
				oge.append({"tur": String(sets[k]), "c": p, "yaw": ang + PI, "tohum": n * 37 + k, "yer": ad})
				_stamp_disc(p, 5.0, 5)
		n += 1


## DOKU-3: ünlü eserlerin (yan görev eserleri, UNLU listesi, k ≥ 0,6 kiliseler/anıtlar) çevresinde evden ÖNCE meydan halkası
## ayrılır (boş hücre → 5): taş döşeme (zemin_ek), sonra (_meydanlar) köşe grupları, ağaç kümesi, kuyu/çeşme (meydan kaydı:
## ŞEHİR kurar; IstHayatYakin gezinenleri buraya da doğar). Ayasofya: 30 m'lik meydan (Augustaion + atrium + kuzey avlu).
const ESER_ATLA := ["zincir", "bozdogan", "hipodrom", "buyuk_saray", "bukoleon", "zeuksippos", "kontoskalion", "langa", "sophia",
	"aetios", "aspar", "mokios", "halic_neorion", "halic_iskele", "augustaion"]
func _eser_meydanlari() -> void:
	var s: Node = IstSehir.active
	if s == null or not is_instance_valid(s) or not IstSehir.v2:
		return
	for it: Dictionary in s.items:
		if it.has("hat"):
			continue
		var id := String(it["id"])
		if id in ESER_ATLA or id.begins_with("doku_") or id.begins_with("meydan_") or id.begins_with("mese_"):
			continue
		var dt: Dictionary = it.get("data", {})
		var tur := String(dt.get("tur", ""))
		if tur in ["kapi", "sur", "liman", "ev", "ayrinti", "bitki", "su", "gemi"]:
			continue
		var unlu: bool = id == "ayasofya" or id in IstSehir.UNLU or bool(dt.get("gorev", false))
		if not unlu and float(it.get("k", 0.0)) < 0.6:
			continue
		var r := float(it["r"])
		if r > 95.0 and id != "ayasofya":
			continue
		var p: Vector3 = it["pos"]
		var c := Vector2(p.x, p.z)
		if not (IstGeo.sehir_ici(c.x, c.y) or IstGeo.galata_ici(c.x, c.y)):
			continue
		var pay := 30.0 if id == "ayasofya" else (14.0 if unlu else 9.0)
		var R := r + 4.0 + pay
		var n := 0
		# Ayasofya: taban dairesi (r + 4 = 64 m) binadan çok geniş; gövde karesinin (yarı 31 m, yönüyle) dışı meydan olur
		# (oyun alanları ve öbür anıtların çekirdeği hariç)
		var aya_yaw := float(it.get("yaw", 0.0))
		var au := Vector2(cos(aya_yaw), -sin(aya_yaw))
		var av := Vector2(sin(aya_yaw), cos(aya_yaw))
		var alanlar: Array = s.oyun_alanlari() if s.has_method("oyun_alanlari") else []
		var komsu: Array = []
		if id == "ayasofya":
			for o: Dictionary in s.items:
				if o == it or o.has("hat"):
					continue
				var op: Vector3 = o["pos"]
				if Vector2(op.x, op.z).distance_to(c) < R + float(o["r"]):
					komsu.append([Vector2(op.x, op.z), float(o["r"]) * 0.7 + 3.0])
		for j in range(maxi(0, int((c.y - R - z0) / G)), mini(nz, int((c.y + R - z0) / G) + 1)):
			for i in range(maxi(0, int((c.x - R - x0) / G)), mini(nx, int((c.x + R - x0) / G) + 1)):
				var k := j * nx + i
				var q := cell_c(i, j)
				if q.distance_to(c) > R:
					continue
				if occ[k] == 0:
					occ[k] = 5
					n += 1
				elif occ[k] == 3 and id == "ayasofya":
					var dq := q - c
					if absf(dq.dot(au)) < 31.0 and absf(dq.dot(av)) < 31.0:
						continue
					var serbest := true
					for a: Rect2 in alanlar:
						if a.grow(2.0).has_point(q):
							serbest = false
					for o: Array in komsu:
						if (o[0] as Vector2).distance_to(q) < float(o[1]):
							serbest = false
							break
					if serbest:
						occ[k] = 5
						n += 1
		if n == 0:
			continue
		zemin_ek.append({"c": c, "r": R, "tur": "mese"})
		eser_meydan.append({"id": id, "c": c, "r0": r + 4.0, "R": R, "unlu": unlu})
	stats["eser_meydan"] = eser_meydan.size()


## Eser meydanlarının içini doldurur (evlerden sonra): köşe grupları, ağaç kümesi, kuyu/çeşme + gezinme noktaları
func _eser_meydan_doldur() -> void:
	var nset := 0
	for e: Dictionary in eser_meydan:
		var c: Vector2 = e["c"]
		var r0 := float(e["r0"])
		var R := float(e["R"])
		var aya := String(e["id"]) == "ayasofya"
		var sets: Array = ["mumcu", "set_ayin_alayi", "set_pazar_kosesi", "agac_kumesi", "mumcu", "set_manastir_avlusu", "agac_kumesi",
			"set_pazar_kosesi", "kuyu", "agac_kumesi", "set_meyhane_onu", "mumcu"] if aya else (
			["mumcu", "set_pazar_kosesi", "agac_kumesi", "set_ayin_alayi"] if bool(e["unlu"]) else ["agac_kumesi", "mumcu"])
		var rr := (r0 + R) * 0.5
		var h0 := absi(hash(String(e["id"]))) % 997
		for k in sets.size():
			var ang := k * TAU / sets.size() + 0.3 + (h0 % 7) * 0.1
			for dr: float in [0.0, 4.0, -4.0]:
				var q := c + Vector2.from_angle(ang) * (rr + dr)
				var ok := true
				for a in 5:
					var qq := q + Vector2.from_angle(a * 1.2566) * (3.5 if a > 0 else 0.0)
					if not cell(qq.x, qq.y) in [0, 1, 5]:
						ok = false
						break
				if not ok:
					continue
				oge.append({"tur": String(sets[k]), "c": q, "yaw": ang + PI, "tohum": h0 * 13 + k, "yer": String(e["id"])})
				_stamp_disc(q, 4.0, 5)
				nset += 1
				break
		nset += _kare_doldur(c, r0, R, String(e["id"]), h0)
		# gezinme ve kuyu/çeşme noktaları (meydan kaydı)
		var nm := 4 if aya else 2
		for k in nm:
			var ang := (k + 0.5) * TAU / nm + 0.3
			var q := c + Vector2.from_angle(ang) * (r0 + 5.0)
			if cell(q.x, q.y) in [0, 1, 5]:
				meydan.append({"c": q, "yaw": ang + PI, "tohum": h0 * 7 + k})
	stats["eser_oge"] = nset


## Halkada (r0 < d < R) öğesiz kalan 40 m'lik kareler (büyük meydanlar, forumlar): ağaç kümesi / mumcu / kuyu
func _kare_doldur(c: Vector2, r0: float, R: float, yer: String, h0: int) -> int:
	var nset := 0
	var dolu := {}
	for o: Dictionary in oge:
		var oc: Vector2 = o["c"]
		if oc.distance_to(c) < R + 60.0:
			dolu[Vector2i(floori(oc.x / DT), floori(oc.y / DT))] = true
	for h: Dictionary in houses:
		var hc: Vector2 = h["c"]
		if hc.distance_to(c) < R + 60.0:
			dolu[Vector2i(floori(hc.x / DT), floori(hc.y / DT))] = true
	for j in range(floori((c.y - R) / DT), floori((c.y + R) / DT) + 1):
		for i in range(floori((c.x - R) / DT), floori((c.x + R) / DT) + 1):
			if dolu.has(Vector2i(i, j)):
				continue
			var sc := Vector2((i + 0.5) * DT, (j + 0.5) * DT)
			var best := Vector2.INF
			for dd: float in [0.0, 8.0, 14.0]:
				for a in 6:
					var q := sc + Vector2.from_angle(a * 1.047) * dd
					var dq := q.distance_to(c)
					if dq < r0 + 3.0 or dq > R - 2.0:
						continue
					var ok := true
					for b in 5:
						var qq := q + Vector2.from_angle(b * 1.2566) * (3.0 if b > 0 else 0.0)
						if not cell(qq.x, qq.y) in [0, 1, 5]:
							ok = false
							break
					if ok:
						best = q
						break
					if dd == 0.0:
						break
				if best != Vector2.INF:
					break
			if best == Vector2.INF:
				continue
			oge.append({"tur": ["agac_kumesi", "mumcu", "kuyu", "agac_kumesi"][(i + j * 3) & 3], "c": best, "yaw": float(i * 1.7 + j), "tohum": h0 * 11 + i * 31 + j, "yer": yer})
			_stamp_disc(best, 3.5, 5)
			dolu[Vector2i(i, j)] = true
			nset += 1
	return nset


## Patrikhane ek yapıları: Ayasofya'nın güney ve güneybatısında, ona bakan avlulu konak/han yapıları (kestirim)
func _patrikhane(w: Vector2, rad: float) -> void:
	var n := 0
	for ang_d: float in [100.0, 125.0, 150.0, 75.0, 175.0]:
		if n >= 3:
			break
		var ang := deg_to_rad(ang_d)
		var dir := Vector2(cos(ang), sin(ang))            # +z güney
		var cand := IstEvler.ornekler(2, 10.0, 12.0)
		if cand.is_empty():
			return
		var v: int = cand[n % cand.size()]
		var dm := IstEvler.dims(v)
		for rr: float in [rad + 4.0, rad + 10.0, rad + 18.0]:
			var c := w + dir * (rr + dm.z * 0.5)
			var nrm := dir                                   # cephe (-nrm) Ayasofya'ya
			var d := Vector2(-nrm.y, nrm.x)
			var cells := _rect_cells(c, d, nrm, dm.x * 0.5, dm.z * 0.5, -0.45)
			if cells.has(-1):
				continue
			var ok := true
			for k in cells:
				if not occ[k] in [0, 1, 5]:
					ok = false
			var pg := _poly(c, d, nrm, dm.x * 0.5, dm.z * 0.5)
			if not ok or not _gap_ok(pg, -2):
				continue
			for k in _rect_cells(c, d, nrm, dm.x * 0.5, dm.z * 0.5, -0.2):
				occ[k] = 2
			_rect_add(pg, rows)
			var fr := c - nrm * dm.z * 0.5
			houses.append({"c": c, "yaw": atan2(-nrm.x, -nrm.y), "v": v, "tip": "konak" if n != 1 else "han", "sira": rows, "on": fr})
			rows += 1
			n += 1
			break
	stats["patrikhane"] = n


const DT := 40.0
const KILISE_ARA := 150.0

## Her ~150 m'lik karede (yerleşik türlerde) sokağa bakan 24 × 24 m'lik bir yer: mahalle kilisesi/şapel + önünde meydan
func _kilise_yerleri(rng: RandomNumberGenerator) -> void:
	var n := 0
	for j in range(floori(z0 / KILISE_ARA), floori((z0 + nz * G) / KILISE_ARA) + 1):
		for i in range(floori(x0 / KILISE_ARA), floori((x0 + nx * G) / KILISE_ARA) + 1):
			var c0 := Vector2((i + 0.5) * KILISE_ARA, (j + 0.5) * KILISE_ARA)
			var tur := _tur(c0)
			if not tur in ["carsi", "sik", "liman", "orta", "sur_dibi", "seyrek"]:
				continue
			for deneme in 8:
				var p := c0 + Vector2(rng.randf_range(-55, 55), rng.randf_range(-55, 55))
				var cells := _rect_cells(p, Vector2.RIGHT, Vector2.DOWN, 9.0, 9.0)
				if cells.has(-1):
					continue
				var ok := true
				for k in cells:
					if occ[k] != 0:
						ok = false
						break
				if not ok or _road_near(p, 14.0, -1) < 0:
					continue
				for k in cells:
					occ[k] = 5
				var pick: String = ["kilise_kucuk", "sapel", "kilise_kucuk"][rng.randi() % 3]
				doku.append({"tur": pick, "c": p, "alan": Vector2(16.0, 16.0), "yaw": rng.randf_range(-0.2, 0.2), "tohum": rng.randi() % 9973, "mt": tur})
				zemin_ek.append({"c": p, "r": 11.0, "tur": "mese"})
				n += 1
				break
	stats["kilise_yeri"] = n


func _doku(rng: RandomNumberGenerator) -> void:
	var nkil := 0
	var nmey := 0
	for j in range(0, int(nz * G / DT)):
		for i in range(0, int(nx * G / DT)):
			var c := Vector2(x0 + (i + 0.5) * DT, z0 + (j + 0.5) * DT)
			var tur := _tur(c)
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
			if fr < 0.5:
				# Sık dokunun içindeki küçük boşluk: meydan/kuyu ya da ağaçlı bahçe
				if fr > 0.15:
					var mc := _free_spot(c, 6.0)
					if mc != Vector2.INF:
						if road > 0 and tur in ["carsi", "sik", "liman", "orta"] and rng.randf() < 0.45:
							_stamp_disc(mc, 6.0, 5)
							meydan.append({"c": mc, "yaw": rng.randf() * TAU, "tohum": rng.randi() % 9973})
							zemin_ek.append({"c": mc, "r": 7.0, "tur": "mese"})
							nmey += 1
						else:
							_stamp_disc(mc, 5.0, 5)
							doku.append({"tur": "bahce", "c": mc, "alan": Vector2(10.0, 10.0), "yaw": 0.0, "tohum": rng.randi() % 9973, "mt": tur})
				continue
			var roll := rng.randf()
			var alan := Vector2(DT - 6.0 - rng.randf() * 8.0, DT - 6.0 - rng.randf() * 8.0)
			var yaw := rng.randf_range(-0.3, 0.3)
			var u := Vector2.from_angle(-yaw)
			var v := Vector2(-u.y, u.x)
			var pc := PackedInt32Array()
			var ok := false
			for sc: float in [1.0, 0.7, 0.45]:
				pc = _rect_cells(c, u, v, alan.x * 0.5 * sc, alan.y * 0.5 * sc)
				ok = true
				for k in pc:
					if occ[k] != 0:
						ok = false
						break
				if ok:
					alan *= sc
					break
			if not ok:
				# yama sığmıyor: boş bir köşeye tek öğe
				var mc := _free_spot(c, 4.0)
				if mc != Vector2.INF:
					_stamp_disc(mc, 4.0, 5)
					oge.append({"tur": ["kuyu", "agil", "agac_kumesi", "sapel_kucuk"][rng.randi() % 4], "c": mc, "yaw": rng.randf() * TAU, "tohum": rng.randi() % 9973})
				continue
			var hs := [IstGeo.h(c.x - alan.x * 0.5, c.y - alan.y * 0.5), IstGeo.h(c.x + alan.x * 0.5, c.y - alan.y * 0.5),
				IstGeo.h(c.x - alan.x * 0.5, c.y + alan.y * 0.5), IstGeo.h(c.x + alan.x * 0.5, c.y + alan.y * 0.5)]
			var slope: float = hs.max() - hs.min()
			var pick := ""
			if tur in ["carsi", "sik", "liman", "orta"]:
				if nkil < 420 and roll < 0.3 and alan.x > 18.0:
					pick = ["kilise_kucuk", "sapel", "kilise_orta"][rng.randi() % 3]
				elif roll < 0.6:
					pick = "bahce"
				elif roll < 0.78:
					pick = "harabe"
				else:
					pick = ["bag", "agaclik", "bostan"][rng.randi() % 3]
			elif tur == "seyrek":
				pick = ["bostan", "bag", "bahce", "agaclik", "harabe", "sapel", "bugday", "bag"][rng.randi() % 8]
			elif tur == "harabe":
				pick = ["harabe", "harabe_tonoz", "harabe_kemer", "harabe_sutun", "harabe_sarmasik", "bag", "agaclik"][rng.randi() % 7]
			elif tur == "bostan" or tur == "sur_dibi":
				pick = ["bostan", "bostan", "bag", "bugday", "bahce", "agaclik", "harabe", "bag"][rng.randi() % 8]
				if roll < 0.05:
					pick = "sapel"
			else:
				pick = ["bag", "agaclik", "bugday", "bostan"][rng.randi() % 4]
			match _alt(c):
				"bag": pick = "bag" if roll < 0.8 else "agaclik"
				"meyve": pick = "bahce" if roll < 0.8 else "agaclik"
				"bostan": pick = "bostan" if roll < 0.75 else ("bugday" if roll < 0.9 else "bag")
				"harabe": pick = ["harabe", "harabe_tonoz", "harabe_kemer", "harabe_sutun", "harabe_sarmasik"][rng.randi() % 5]
				"tarla": pick = "bugday"
				"manastir", "mezarlik":
					if alan.x > 24.0 and not _manastir_var(c):
						for k in pc:
							occ[k] = 5
						oge.append({"tur": "manastir" if _alt(c) == "manastir" else "mezarlik", "c": c, "yaw": yaw, "tohum": rng.randi() % 9973})
						continue
					pick = "bahce"
			if slope > 2.5 and pick in ["bostan", "bag", "bugday", "bahce", "cayir"]:
				pick = "agaclik"
			if pick in ["kilise_kucuk", "sapel", "kilise_orta"]:
				nkil += 1
			for k in pc:
				occ[k] = 5
			var dk := {"tur": pick, "c": c, "alan": alan, "yaw": yaw, "tohum": rng.randi() % 9973, "mt": tur}
			doku.append(dk)
			# yamanın kenarı: bahçe duvarı/çit (kapı ağzıyla) ve yanında bir öğe (kuyu, ağıl, kulübe…)
			if pick in ["bostan", "bag", "bugday", "bahce", "cayir"]:
				oge.append({"tur": "yama_duvar", "c": c, "yaw": yaw, "tohum": int(dk["tohum"]), "alan": alan, "yama": pick})
				var ek: String = {"bostan": "kuyu", "bag": "kulube_bag", "bugday": "agil", "bahce": "kuyu", "cayir": "agil"}[pick]
				oge.append({"tur": ek, "c": c + u * (alan.x * 0.5 - 4.0) + v * (alan.y * 0.5 - 4.0), "yaw": yaw, "tohum": int(dk["tohum"]) + 1})
	stats["kilise"] = nkil
	stats["meydan"] = nmey


## Hâlâ hiçbir şey olmayan 40 m'lik kareler (şehir içi): en az bir öğe (kalite notu 0: ISTBOS şehir içinde 0)
func _ogeler(rng: RandomNumberGenerator) -> void:
	var dolu := {}
	for h: Dictionary in houses:
		var c: Vector2 = h["c"]
		dolu[Vector2i(floori(c.x / DT), floori(c.y / DT))] = true
	for dk: Dictionary in doku:
		var c: Vector2 = dk["c"]
		var al: Vector2 = dk["alan"]
		for oy in [-0.4, 0.0, 0.4]:
			for ox in [-0.4, 0.0, 0.4]:
				dolu[Vector2i(floori((c.x + al.x * ox) / DT), floori((c.y + al.y * oy) / DT))] = true
	for o: Dictionary in oge:
		var c: Vector2 = o["c"]
		dolu[Vector2i(floori(c.x / DT), floori(c.y / DT))] = true
	for a: Dictionary in avlu:
		var c: Vector2 = a["c"]
		dolu[Vector2i(floori(c.x / DT), floori(c.y / DT))] = true
	var n := 0
	for j in range(floori(z0 / DT), floori((z0 + nz * G) / DT) + 1):
		for i in range(floori(x0 / DT), floori((x0 + nx * G) / DT) + 1):
			if dolu.has(Vector2i(i, j)):
				continue
			var c := Vector2((i + 0.5) * DT, (j + 0.5) * DT)
			var ic := IstGeo.sehir_ici(c.x, c.y) or IstGeo.galata_ici(c.x, c.y)
			if not ic or IstGeo.su(c.x, c.y):
				continue
			var mc := _free_spot(c, 3.0)
			if mc == Vector2.INF:
				continue                # anıt ya da sur bandı: dolu sayılır
			var tur := _tur(c)
			var pick := "kuyu"
			match tur:
				"carsi", "sik", "liman", "orta":
					pick = ["kuyu", "set_firin_onu", "set_demirci", "agac_kumesi", "set_dokumaci_boyaci"][rng.randi() % 5]
				"sur_dibi":
					pick = ["set_sur_onarim_santiyesi", "set_multeci_cadirlari", "agil", "kuyu"][rng.randi() % 4]
				_:
					pick = ["agil", "kuyu", "ciftlik", "mezarlik", "agac_kumesi", "set_bostan_kosesi"][rng.randi() % 6]
			_stamp_disc(mc, 4.0, 5)
			oge.append({"tur": pick, "c": mc, "yaw": rng.randf() * TAU, "tohum": rng.randi() % 9973})
			n += 1
	stats["oge_dolgu"] = n


func _manastir_var(c: Vector2) -> bool:
	for o: Dictionary in oge:
		if String(o["tur"]) == "manastir" and (o["c"] as Vector2).distance_to(c) < 90.0:
			return true
	return false


func _free_spot(c: Vector2, r: float) -> Vector2:
	for k in 30:
		var p := c + Vector2.from_angle(k * 2.4) * (k * 0.6)
		var cells := _rect_cells(p, Vector2.RIGHT, Vector2.DOWN, r, r)
		var ok := not cells.has(-1)
		for q in cells:
			if ok and occ[q] != 0:
				ok = false
		if ok:
			return p
	return Vector2.INF


## Denetim için: iki dışbükey çokgen arasındaki en kısa uzaklık (iç içe ya da değiyorsa 0)
static func poly_gap(a: PackedVector2Array, b: PackedVector2Array) -> float:
	var ov := Geometry2D.intersect_polygons(a, b)
	for o: PackedVector2Array in ov:
		if absf(_area(o)) > 0.02:
			return 0.0
	var best := INF
	for i in a.size():
		for j in b.size():
			best = minf(best, a[i].distance_to(Geometry2D.get_closest_point_to_segment(a[i], b[j], b[(j + 1) % b.size()])))
			best = minf(best, b[j].distance_to(Geometry2D.get_closest_point_to_segment(b[j], a[i], a[(i + 1) % a.size()])))
	return best


## Denetim için: doku katmanının (IstMahalleDoku) tekil öğelerinin konumları (ISTBOS sayımı)
func oge_noktalari() -> Array:
	var out: Array = []
	for o: Dictionary in oge:
		out.append(o["c"])
	for a: Dictionary in avlu:
		out.append(a["c"])
	return out


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


## IstSehir v2 kurulurken (IstSehir.active) mahalle dokusunun ikinci katmanını bağla (sokak zemini, avlular, öğeler)
func katman_bagla() -> void:
	if IstSehir.v2 and IstSehir.active != null and is_instance_valid(IstSehir.active) and IstSehir.active.is_inside_tree():
		IstMahalleDoku.attach(IstSehir.active, self, IstSehir.active.gece)
