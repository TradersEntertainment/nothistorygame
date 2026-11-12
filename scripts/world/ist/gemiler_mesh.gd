class_name IstGemilerMesh
extends RefCounted
## İstanbul v2 gemileri: köşe renkli tek ağ üreticileri (lod 0 / 1 / 2). Yerel çerçeve: +z baş, +x sancak tarafı,
## y = 0 su yüzü; güverte DÜZ ve y = TIPLER[tip]["D"] (yürünür), bordalar güvertenin üstünde ≥ 0,9 m.
## Gövde ve donanım yardımcıları Landmarks1453'ten (değiştirilmeden) alınır. Yelkenler limanda sarılı (açık = true: dolu).
## Bayraklar: Bizans (altın zemin, çift başlı kartal), Venedik (kırmızı zemin, altın aslan), Ceneviz (beyaz üstüne
## kırmızı haç), Katalan (sarı-kırmızı şeritler), Osmanlı (kırmızı ya da yeşil sancak, altın alem).

const SH_HULL := Color("5a3e28")
const SH_TAR := Color("2e241e")
const SH_DECK := Color("9a7a50")
const SH_ROPE := Color("3a3026")
const SH_SAIL := Color("e6dcc2")
const SH_WOOD := Color("4a3220")

## L boy, B en, D güverte yüksekliği (su yüzünden), R bordanın (küpeşte) orta yüksekliği, SH baş-kıç yükselmesi,
## T su çekimi (draft), SW kıç genişliği
const TIPLER := {
	"karaka": {"ad": "Karaka (yüksek bordalı nef)", "L": 26.0, "B": 8.0, "D": 2.6, "R": 1.2, "SH": 1.8, "T": 1.9, "SW": 0.62},
	"kog": {"ad": "Kog (tüccar gemisi)", "L": 18.0, "B": 6.0, "D": 1.9, "R": 1.1, "SH": 1.2, "T": 1.4, "SW": 0.6},
	"kadirga": {"ad": "Kadırga", "L": 34.0, "B": 5.0, "D": 1.15, "R": 0.95, "SH": 0.7, "T": 0.8, "SW": 0.45},
	"kalyata": {"ad": "Kalyata", "L": 25.0, "B": 3.8, "D": 1.0, "R": 0.95, "SH": 0.55, "T": 0.65, "SW": 0.45},
	"fusta": {"ad": "Fusta", "L": 19.0, "B": 3.0, "D": 0.9, "R": 0.95, "SH": 0.45, "T": 0.55, "SW": 0.4},
	"parandarya": {"ad": "Parandarya (at nakliye gemisi)", "L": 27.0, "B": 7.0, "D": 1.5, "R": 1.0, "SH": 0.8, "T": 1.0, "SW": 0.6},
	"balikci": {"ad": "Balıkçı teknesi", "L": 8.0, "B": 2.4, "D": 0.6, "R": 0.45, "SH": 0.4, "T": 0.5, "SW": 0.4},
	"sandal": {"ad": "Sandal / kayık", "L": 5.6, "B": 1.7, "D": 0.45, "R": 0.35, "SH": 0.25, "T": 0.35, "SW": 0.5},
}

## Bayrak adı → [gövde boya bandı, yan şerit]
const BOYA := {
	"bizans": [Color("7a2430"), Color("d8a21c")],
	"venedik": [Color("a8242a"), Color("d8b040")],
	"ceneviz": [Color("c9c0a8"), Color("b02028")],
	"katalan": [Color("d8b030"), Color("b02028")],
	"osmanli": [Color("8a2b22"), Color("d8c8a0")],
	"osmanli_yesil": [Color("2e5a3a"), Color("d8c8a0")],
	"tuccar": [Color("3e5478"), Color("c8b890")],
	"balik": [Color("3e6a5a"), Color("d8d0b8")],
}

static var _onbellek := {}

# ------------------------------------------------------------------ ölçü ve istasyonlar

static func deck_y(tip: String) -> float:
	return float((TIPLER[tip] as Dictionary)["D"])


## İstasyonlar [z, yarı genişlik w, bordanın üstü yt, omurga yb] (kıçtan başa 11 istasyon)
static func istasyon(tip: String) -> Array:
	var d: Dictionary = TIPLER[tip]
	var L: float = d["L"]
	var B: float = d["B"]
	var yd: float = d["D"]
	var rail: float = d["R"]
	var sh: float = d["SH"]
	var T: float = d["T"]
	var sw: float = d["SW"]
	var st: Array = []
	for i in 11:
		var t := float(i) / 10.0
		var z := lerpf(-L * 0.5, L * 0.5, t)
		var w := B * 0.5 * maxf(pow(sin(PI * clampf(t * 0.94 + 0.03, 0.0, 1.0)), 0.6), sw * (1.0 - t * 2.0))
		if t >= 1.0:
			w = 0.05
		var yt := yd + rail + sh * pow(absf(t - 0.45) * 2.0, 2.0)
		var yb := -T * (1.0 - pow(absf(t - 0.5) * 2.0, 3.0) * 0.7)
		st.append([z, w, yt, yb])
	return st


static func boya(bay: String) -> Array:
	return BOYA.get(bay, BOYA["tuccar"])


# ------------------------------------------------------------------ gövde

## Gövde: katran dibi, su kuşağı, boyalı kuşak, düz güverte (tahta çizgili), iç duvar ve bordanın üst kenarı
static func _govde(k: MeshKit, tip: String, bay: String, gunes_tahta := true) -> void:
	var st := istasyon(tip)
	var yd := deck_y(tip)
	var pal := boya(bay)
	var paint: Color = pal[0]
	var trim: Color = pal[1]
	var hull := SH_HULL
	var N := st.size() - 1
	for s: float in [-1.0, 1.0]:
		for i in N:
			var p: Array = []
			for j in [i, i + 1]:
				var z: float = st[j][0]
				var w: float = st[j][1]
				var yt: float = st[j][2]
				var yb: float = st[j][3]
				p.append([Vector3(0, yb, z), Vector3(s * w * 0.8, yb * 0.35, z), Vector3(s * w, 0.15, z),
					Vector3(s * w * 1.02, yd * 0.55 + yt * 0.45, z), Vector3(s * w * 0.96, yt, z)])
			var cols := [SH_TAR, SH_TAR.lightened(0.1), hull, paint]
			for b in 4:
				var out := Vector3(s, -0.6 if b == 0 else 0.0, 0)
				Landmarks1453._oq(k, p[0][b], p[1][b], p[1][b + 1], p[0][b + 1], cols[b], out)
			# kuşak şeridi (üst kenara yakın)
			var a0: Vector3 = (p[0][3] as Vector3).lerp(p[0][4], 0.72)
			var a1: Vector3 = (p[1][3] as Vector3).lerp(p[1][4], 0.72)
			var b0: Vector3 = (p[0][3] as Vector3).lerp(p[0][4], 0.88)
			var b1: Vector3 = (p[1][3] as Vector3).lerp(p[1][4], 0.88)
			Landmarks1453._oq(k, a0 * Vector3(1.012, 1, 1), a1 * Vector3(1.012, 1, 1), b1 * Vector3(1.012, 1, 1), b0 * Vector3(1.012, 1, 1), trim, Vector3(s, 0, 0))
			# bordanın üst kenarı ve iç duvarı, güverte
			var z0: float = st[i][0]
			var z1: float = st[i + 1][0]
			var w0: float = st[i][1]
			var w1: float = st[i + 1][1]
			var t0: float = st[i][2]
			var t1: float = st[i + 1][2]
			var o0 := Vector3(s * w0 * 0.96, t0, z0)
			var o1 := Vector3(s * w1 * 0.96, t1, z1)
			var n0 := Vector3(s * w0 * 0.88, t0, z0)
			var n1 := Vector3(s * w1 * 0.88, t1, z1)
			var d0 := Vector3(s * w0 * 0.88, yd, z0)
			var d1 := Vector3(s * w1 * 0.88, yd, z1)
			Landmarks1453._oq(k, o0, o1, n1, n0, hull.lightened(0.15), Vector3.UP)
			Landmarks1453._oq(k, n0, n1, d1, d0, hull.darkened(0.12), Vector3(-s, 0, 0))
			var dc := SH_DECK if (i % 2 == 0 or not gunes_tahta) else SH_DECK.darkened(0.07)
			Landmarks1453._oq(k, d0, d1, Vector3(0, yd, z1), Vector3(0, yd, z0), dc, Vector3.UP)
	# Kıç aynası ve baş
	var s0: Array = st[0]
	var tr := [Vector3(0, s0[3], s0[0]), Vector3(s0[1] * 0.8, s0[3] * 0.35, s0[0]), Vector3(s0[1], 0.15, s0[0]),
		Vector3(s0[1] * 1.02, yd * 0.55 + (s0[2] as float) * 0.45, s0[0]), Vector3(s0[1] * 0.96, s0[2], s0[0])]
	var c0 := Vector3(0, ((s0[2] as float) + (s0[3] as float)) * 0.5, s0[0])
	for s: float in [-1.0, 1.0]:
		for b in 4:
			var a: Vector3 = tr[b] * Vector3(s, 1, 1)
			var e: Vector3 = tr[b + 1] * Vector3(s, 1, 1)
			Landmarks1453._ot(k, c0, a, e, hull.darkened(0.1) if b > 1 else SH_TAR, Vector3(0, 0, -1))
		Landmarks1453._ot(k, c0, tr[4] * Vector3(s, 1, 1), Vector3(0, s0[2], s0[0]), paint.darkened(0.1), Vector3(0, 0, -1))
	# Kıç aynasında kapak (üstü bordayla aynı yükseklikte kapalı): iç yüz
	var yt0: float = s0[2]
	Landmarks1453._oq(k, Vector3(-(s0[1] as float) * 0.88, yd, s0[0] + 0.02), Vector3((s0[1] as float) * 0.88, yd, s0[0] + 0.02),
		Vector3((s0[1] as float) * 0.88, yt0, s0[0] + 0.02), Vector3(-(s0[1] as float) * 0.88, yt0, s0[0] + 0.02), hull.darkened(0.12), Vector3(0, 0, 1))
	Landmarks1453._oq(k, Vector3(-(s0[1] as float) * 0.96, yt0, s0[0]), Vector3((s0[1] as float) * 0.96, yt0, s0[0]),
		Vector3((s0[1] as float) * 0.88, yt0, s0[0] + 0.02), Vector3(-(s0[1] as float) * 0.88, yt0, s0[0] + 0.02), hull.lightened(0.15), Vector3.UP)


static func _rod(k: MeshKit, a: Vector3, b: Vector3, r: float, col: Color) -> void:
	Landmarks1453._rod(k, a, b, r, col)


## a'dan b'ye silindir (yuvarlak kesit; sarılı yelken, direk)
static func _sil(k: MeshKit, a: Vector3, b: Vector3, r: float, col: Color, seg := 6) -> void:
	var up := b - a
	var len := up.length()
	if len < 0.01:
		return
	var y := up / len
	var x := y.cross(Vector3.FORWARD if absf(y.z) < 0.9 else Vector3.RIGHT).normalized()
	var z := x.cross(y)
	k.cyl(Transform3D(Basis(x, y, z), a), r, len, col, seg)


static func _kutu(k: MeshKit, c: Vector3, s: Vector3, col: Color) -> void:
	k.box(Transform3D(Basis(), c), s, col)


# ------------------------------------------------------------------ bayraklar

const DESEN := {
	"bizans": ["#.....#.", "###.###.", ".#####..", "..####..", "...##..."],
	"venedik": [".#...##.", "###.####", ".######.", "..####..", "..#..#.."],
}


static func _bayrak_renk(bay: String, i: int, j: int, nx: int, ny: int) -> Color:
	var zemin := Color("c8262f")
	var isaret := Color("e0b840")
	match bay:
		"bizans":
			zemin = Color("d8a21c")
			isaret = Color("2a1a14")
		"venedik":
			zemin = Color("b02028")
			isaret = Color("e0b840")
		"ceneviz":
			zemin = Color("ece6d8")
			isaret = Color("b02028")
			if i == nx / 2 or j == ny / 2:
				return isaret
			return zemin
		"katalan":
			return Color("e8c030") if j % 2 == 0 else Color("b02028")
		"osmanli_yesil":
			return Color("2a7a4a")
		"osmanli":
			return Color("c8262f")
		"tuccar":
			return Color("3e5478") if j < ny / 2 else Color("e0d8c0")
		_:
			return Color("d8d0b8")
	if DESEN.has(bay):
		var rows: Array = DESEN[bay]
		var u := int(float(i) / nx * 8.0)
		var v := int(float(j) / ny * 5.0)
		if (rows[mini(v, 4)] as String)[mini(u, 7)] == "#":
			return isaret
	return zemin


## Dikey bir direk yüzünde, kıça doğru (−z) akan bayrak. bas: asılı yer (üst köşe); w boy, h yükseklik
static func _bayrak(k: MeshKit, bas: Vector3, bay: String, w: float, h: float, ayrinti := true) -> void:
	var nx := 8 if ayrinti else 2
	var ny := 5 if ayrinti else 2
	if bay.begins_with("osmanli") or bay == "ceneviz" and not ayrinti:
		nx = 2 if not ayrinti else 4
		ny = 2 if not ayrinti else 3
	if bay == "ceneviz" and ayrinti:
		nx = 7
		ny = 5
	var p := func(i: int, j: int) -> Vector3:
		var fu := float(i) / nx
		var fv := float(j) / ny
		return bas + Vector3(0.06 * sin(fu * 5.0 + fv * 2.0) * fu, -fv * h, -fu * w)
	for i in nx:
		for j in ny:
			var col := _bayrak_renk(bay, i, j, nx, ny)
			Landmarks1453._tri2(k, p.call(i, j), p.call(i, j + 1), p.call(i + 1, j + 1), col)
			Landmarks1453._tri2(k, p.call(i, j), p.call(i + 1, j + 1), p.call(i + 1, j), col)
	# Osmanlı sancağı: altın alem (küre) ve iki uçlu kuyruk
	if bay.begins_with("osmanli") and ayrinti:
		k.cyl(Transform3D(Basis(), bas + Vector3(0, 0.0, 0.0)), 0.1, 0.5, Color("d8b040"), 6, 0.0)


static func _flama(k: MeshKit, bas: Vector3, uzun: float, col: Color) -> void:
	Landmarks1453._pennant(k, bas, uzun, col)


# ------------------------------------------------------------------ karaka / kog

static func _karaka(k: MeshKit, tip: String, bay: String, lod: int, acik: bool) -> void:
	var d: Dictionary = TIPLER[tip]
	var L: float = d["L"]
	var yd: float = d["D"]
	var sc := L / 26.0
	var pal := boya(bay)
	var paint: Color = pal[0]
	var trim: Color = pal[1]
	var det := lod == 0
	_govde(k, tip, bay)
	# Kıç kasarası (iki kat) ve baş kasarası; katı kütle (çarpışma kutuları aynı ölçüde)
	var ks := _kasaralar(tip)
	for kas: Dictionary in ks:
		var c: Vector3 = kas["c"]
		var s: Vector3 = kas["s"]
		_kutu(k, c, s, SH_HULL.lightened(0.05))
		_kutu(k, c + Vector3(0, s.y * 0.5 + 0.1, 0), Vector3(s.x + 0.4, 0.2, s.z + 0.4), paint)
		if det:
			# kasara kenarında kalkan sırası
			for q in 4:
				var zz := c.z - s.z * 0.5 + (q + 0.5) * s.z / 4.0
				for sx: float in [-1.0, 1.0]:
					_kutu(k, Vector3(c.x + sx * (s.x * 0.5 + 0.04), c.y + 0.1, zz), Vector3(0.08, 0.55, 0.55), trim if q % 2 == 0 else paint.lightened(0.1))
	if det:
		# kıç aynası pencereleri ve sancak tahtası
		for q in 3:
			_kutu(k, Vector3(-1.4 + q * 1.4, yd + 1.7 * sc, -L * 0.5 - 0.02), Vector3(0.7, 0.6, 0.06), Color("e0c060"))
	# Direkler (ana, baş, kıçta latin direği)
	var main := Vector3(0, yd, 0.6 * sc)
	var fore := Vector3(0, yd, L * 0.3)
	var miz := Vector3(0, yd, -L * 0.3)
	var hm := 19.0 * sc
	_sil(k, main, main + Vector3(0, hm, 0), 0.3 * sc, SH_WOOD.lightened(0.05), 7)
	_sil(k, fore, fore + Vector3(0, 13.0 * sc, 0), 0.22 * sc, SH_WOOD.lightened(0.05), 6)
	_sil(k, miz, miz + Vector3(0, 11.0 * sc, 0), 0.2 * sc, SH_WOOD.lightened(0.05), 6)
	# Sepet (gabya)
	k.cyl(Transform3D(Basis(), main + Vector3(0, hm * 0.87, 0)), 1.0 * sc, 0.9, SH_HULL, 8, 1.25 * sc)
	var pattern := "cross" if bay == "ceneviz" else ("stripes" if bay == "venedik" else "")
	var yard_m := main + Vector3(0, hm * 0.8, 0.5)
	var yard_f := fore + Vector3(0, 11.4 * sc, 0.4)
	var wm := 12.0 * sc
	var wf := 8.0 * sc
	_rod(k, yard_m + Vector3(-wm * 0.5, 0, 0), yard_m + Vector3(wm * 0.5, 0, 0), 0.15, SH_WOOD)
	_rod(k, yard_f + Vector3(-wf * 0.5, 0, 0), yard_f + Vector3(wf * 0.5, 0, 0), 0.12, SH_WOOD)
	if acik:
		Landmarks1453._square_sail(k, yard_m - Vector3(0, 0.15, 0), wm * 0.95, 10.0 * sc, 2.2, SH_SAIL, pattern)
		Landmarks1453._square_sail(k, yard_f - Vector3(0, 0.15, 0), wf * 0.95, 6.6 * sc, 1.4, SH_SAIL, "")
		Landmarks1453._lateen(k, miz + Vector3(0, 3.0, 3.2), miz + Vector3(0, 12.0 * sc, -4.2), miz + Vector3(0, 2.6, -3.6), Vector3(1.0, 0, 0), SH_SAIL.darkened(0.04))
	else:
		# sarılı yelken: seren boyunca kalın, soluk kenevir demet ve bağ ipleri
		_sil(k, yard_m + Vector3(-wm * 0.46, -0.45, 0.1), yard_m + Vector3(wm * 0.46, -0.45, 0.1), 0.5 * sc, SH_SAIL.darkened(0.12), 6)
		_sil(k, yard_f + Vector3(-wf * 0.46, -0.35, 0.1), yard_f + Vector3(wf * 0.46, -0.35, 0.1), 0.38 * sc, SH_SAIL.darkened(0.12), 6)
		if det:
			for q in 5:
				var xx := lerpf(-wm * 0.4, wm * 0.4, q / 4.0)
				_rod(k, yard_m + Vector3(xx, -0.9, 0.1), yard_m + Vector3(xx, 0.0, 0.1), 0.05, SH_ROPE)
		_rod(k, miz + Vector3(0, 3.0, 3.2), miz + Vector3(0, 12.0 * sc, -4.2), 0.1, SH_WOOD)
		_sil(k, miz + Vector3(0.2, 3.4, 2.6), miz + Vector3(0.2, 11.4 * sc, -3.8), 0.3, SH_SAIL.darkened(0.15), 6)
	# Cıvadra
	var bow := Vector3(0, yd + 1.2, L * 0.5)
	_rod(k, bow, bow + Vector3(0, 2.6, 5.5), 0.16, SH_WOOD)
	if det:
		# Çarmıh: ana ve baş direğin iki yanında
		for sx: float in [-1.0, 1.0]:
			for dz: float in [-1.2, 0.0, 1.2]:
				_rod(k, main + Vector3(0, hm * 0.85, 0), Vector3(sx * 3.5, yd + 0.5, main.z + dz), 0.04, SH_ROPE)
			_rod(k, fore + Vector3(0, 11.0 * sc, 0), Vector3(sx * 2.9, yd + 0.5, fore.z), 0.04, SH_ROPE)
		_rod(k, main + Vector3(0, hm * 0.95, 0), bow + Vector3(0, 2.4, 4.8), 0.05, SH_ROPE)
		# demir (baş omuzluğunda) ve zincir deliği
		_kutu(k, Vector3(2.9 * sc, yd + 0.9, L * 0.32), Vector3(0.4, 0.8, 0.14), Color("2a2a30"))
		_kutu(k, Vector3(-2.9 * sc, yd + 0.9, L * 0.32), Vector3(0.4, 0.8, 0.14), Color("2a2a30"))
		# güvertede ambar kapağı ve kapı
		_kutu(k, Vector3(0, yd + 0.12, 3.2 * sc), Vector3(2.4, 0.24, 3.0), SH_HULL.darkened(0.2))
		_kutu(k, Vector3(0, yd + 0.12, -2.2 * sc), Vector3(2.0, 0.24, 2.2), SH_HULL.darkened(0.12))
	# Kalkan sırası (bordanın dışında, ortada)
	if det:
		for sx: float in [-1.0, 1.0]:
			for q in 9:
				var zz := lerpf(-L * 0.28, L * 0.28, q / 8.0)
				var st := istasyon(tip)
				var w := _w_at(st, zz)
				var yy := yd + (d["R"] as float) * 0.45
				_kutu(k, Vector3(sx * (w * 0.96 + 0.06), yy, zz), Vector3(0.1, 0.6, 0.6), trim if q % 2 == 0 else paint.lightened(0.15))
	# Bayraklar
	_bayrak(k, main + Vector3(0.0, hm + 0.2, 0.0), bay, 3.4 * sc, 2.0 * sc, det)
	_bayrak(k, Vector3(0, yd + 6.6 * sc, -L * 0.46), bay, 2.4 * sc, 1.5 * sc, det)
	_flama(k, fore + Vector3(0, 13.0 * sc, 0), 3.5, trim)
	_sil(k, Vector3(0, yd + 4.2 * sc, -L * 0.46), Vector3(0, yd + 6.8 * sc, -L * 0.46), 0.05, SH_WOOD, 5)


## İstasyon z'sinde yarı genişlik (doğrusal)
static func _w_at(st: Array, z: float) -> float:
	for i in st.size() - 1:
		var z0: float = st[i][0]
		var z1: float = st[i + 1][0]
		if z >= z0 and z <= z1:
			var t := (z - z0) / maxf(z1 - z0, 0.001)
			return lerpf(st[i][1], st[i + 1][1], t)
	return 0.5


## Kasara kutuları (yerel): [{"c": merkez, "s": boyut}]; çarpışma da aynılarını kullanır
static func _kasaralar(tip: String) -> Array:
	var d: Dictionary = TIPLER[tip]
	var L: float = d["L"]
	var yd: float = d["D"]
	match tip:
		"karaka":
			var sc := L / 26.0
			return [
				{"c": Vector3(0, yd + 1.1, -L * 0.36), "s": Vector3(6.0 * sc, 2.2, 5.6 * sc)},
				{"c": Vector3(0, yd + 0.9, L * 0.34), "s": Vector3(4.6 * sc, 1.8, 4.0 * sc)},
			]
		"kog":
			return [
				{"c": Vector3(0, yd + 0.9, -L * 0.34), "s": Vector3(4.4, 1.8, 4.4)},
				{"c": Vector3(0, yd + 0.7, L * 0.34), "s": Vector3(3.6, 1.4, 3.4)},
			]
		"kadirga":
			return [{"c": Vector3(0, yd + 0.7, -L * 0.38), "s": Vector3(3.2, 1.4, 4.2)}]
		"parandarya":
			return [{"c": Vector3(0, yd + 0.6, -L * 0.4), "s": Vector3(4.2, 1.2, 4.0)}]
	return []


static func _kog(k: MeshKit, bay: String, lod: int, acik: bool) -> void:
	var d: Dictionary = TIPLER["kog"]
	var L: float = d["L"]
	var yd: float = d["D"]
	var pal := boya(bay)
	var paint: Color = pal[0]
	var trim: Color = pal[1]
	var det := lod == 0
	_govde(k, "kog", bay)
	for kas: Dictionary in _kasaralar("kog"):
		var c: Vector3 = kas["c"]
		var s: Vector3 = kas["s"]
		_kutu(k, c, s, SH_HULL.lightened(0.05))
		_kutu(k, c + Vector3(0, s.y * 0.5 + 0.1, 0), Vector3(s.x + 0.4, 0.2, s.z + 0.4), paint)
	var main := Vector3(0, yd, 1.0)
	_sil(k, main, main + Vector3(0, 15.0, 0), 0.26, SH_WOOD.lightened(0.05), 6)
	var yard := main + Vector3(0, 12.4, 0.4)
	_rod(k, yard + Vector3(-5.0, 0, 0), yard + Vector3(5.0, 0, 0), 0.13, SH_WOOD)
	if acik:
		Landmarks1453._square_sail(k, yard - Vector3(0, 0.15, 0), 9.2, 8.2, 1.8, SH_SAIL, "cross" if bay == "ceneviz" else "")
	else:
		_sil(k, yard + Vector3(-4.6, -0.4, 0.1), yard + Vector3(4.6, -0.4, 0.1), 0.42, SH_SAIL.darkened(0.12), 6)
	var bow := Vector3(0, yd + 1.0, L * 0.5)
	_rod(k, bow, bow + Vector3(0, 2.0, 4.2), 0.14, SH_WOOD)
	if det:
		for sx: float in [-1.0, 1.0]:
			for dz: float in [-1.0, 0.0, 1.0]:
				_rod(k, main + Vector3(0, 13.0, 0), Vector3(sx * 2.6, yd + 0.4, main.z + dz), 0.04, SH_ROPE)
		_kutu(k, Vector3(0, yd + 0.12, 2.8), Vector3(2.2, 0.24, 2.6), SH_HULL.darkened(0.2))
		_kutu(k, Vector3(0, yd + 0.5, -1.0), Vector3(1.2, 1.0, 1.0), Color("6a4a2c"))        # ambar sandıkları
		_kutu(k, Vector3(0.9, yd + 0.4, -1.0), Vector3(0.8, 0.8, 0.8), Color("7a6a50"))
	_bayrak(k, main + Vector3(0, 15.2, 0), bay, 2.8, 1.6, det)
	_bayrak(k, Vector3(0, yd + 4.8, -L * 0.46), bay, 2.0, 1.3, det)
	_sil(k, Vector3(0, yd + 3.2, -L * 0.46), Vector3(0, yd + 5.0, -L * 0.46), 0.05, SH_WOOD, 5)


# ------------------------------------------------------------------ kürekli gemiler

## Kürekler: iki yanda n çift, güverteden suya eğik; apostis (dışa çıkma) şeridi
static func _kurekler(k: MeshKit, tip: String, n: int, ilk: float, son: float, uzun: float, col: Color, ayr: bool) -> void:
	var d: Dictionary = TIPLER[tip]
	var yd: float = d["D"]
	var st := istasyon(tip)
	for s: float in [-1.0, 1.0]:
		for q in n:
			var z := lerpf(ilk, son, float(q) / maxf(n - 1, 1))
			var w := _w_at(st, z)
			var a := Vector3(s * (w + 0.5), yd + 0.3, z)
			var b := Vector3(s * (w + 0.5 + uzun * 0.78), -0.25, z - 0.9)
			_rod(k, a, b, 0.05 if ayr else 0.08, col)
			if ayr:
				# kürek ağzı (kepçe)
				_kutu(k, b + Vector3(0, 0.0, -0.1), Vector3(0.1, 0.05, 0.6), col.darkened(0.1))
		# apostis: dışa taşan kürek rafı
		var w0 := _w_at(st, ilk)
		var w1 := _w_at(st, son)
		Landmarks1453._oq(k, Vector3(s * (w0 + 0.55), yd + 0.22, ilk), Vector3(s * (w1 + 0.55), yd + 0.22, son),
			Vector3(s * (w1 - 0.1), yd + 0.22, son), Vector3(s * (w0 - 0.1), yd + 0.22, ilk), SH_HULL.lightened(0.1), Vector3.UP)
		_rod(k, Vector3(s * (w0 + 0.55), yd + 0.18, ilk), Vector3(s * (w1 + 0.55), yd + 0.18, son), 0.07, SH_HULL.darkened(0.15))


## Latin direği ve sarılı yelken (açık: dolu yelken)
static func _latin(k: MeshKit, taban: Vector3, h: float, uzun: float, sail_col: Color, acik: bool, kalin := 0.2) -> void:
	_sil(k, taban, taban + Vector3(0, h, 0), kalin, SH_WOOD.lightened(0.05), 6)
	var ya := taban + Vector3(0, h * 0.2, uzun * 0.5)
	var yb := taban + Vector3(0, h * 1.08, -uzun * 0.5)
	_rod(k, ya, yb, 0.11, SH_WOOD)
	if acik:
		Landmarks1453._lateen(k, ya, yb, taban + Vector3(0, h * 0.15, -uzun * 0.37), Vector3(1.2, 0, 0), sail_col)
	else:
		_sil(k, ya + Vector3(0.18, -0.15, -0.3), yb + Vector3(0.18, -0.4, 0.3), 0.26, SH_SAIL.darkened(0.14), 6)


static func _kadirga(k: MeshKit, tip: String, bay: String, lod: int, acik: bool) -> void:
	var d: Dictionary = TIPLER[tip]
	var L: float = d["L"]
	var yd: float = d["D"]
	var det := lod == 0
	var pal := boya(bay)
	var paint: Color = pal[0]
	var trim: Color = pal[1]
	var osm := bay.begins_with("osmanli")
	_govde(k, tip, bay)
	# Mahmuz (baş çıkıntı) ve baş sahanlığı (kürsü); orta yolluk (kuršiya)
	_rod(k, Vector3(0, yd + 0.3, L * 0.5 - 0.6), Vector3(0, yd + 0.8, L * 0.5 + (4.0 if tip == "kadirga" else 2.6)), 0.2, SH_HULL.darkened(0.15))
	_kutu(k, Vector3(0, yd + 0.45, L * 0.5 - 2.0), Vector3(2.6, 0.9, 3.0), SH_HULL.lightened(0.04))
	_kutu(k, Vector3(0, yd + 1.0, L * 0.5 - 2.0), Vector3(2.8, 0.14, 3.2), paint)
	if det:
		# top namlusu (baş sahanlığında)
		_sil(k, Vector3(0, yd + 1.2, L * 0.5 - 1.2), Vector3(0, yd + 1.3, L * 0.5 + 0.7), 0.17, Color("3a3a40"), 6)
	# Sıra tahtası ve kıç köşkü
	for kas: Dictionary in _kasaralar(tip):
		var c: Vector3 = kas["c"]
		var s: Vector3 = kas["s"]
		_kutu(k, c, s, paint.lightened(0.05))
		_kutu(k, c + Vector3(0, s.y * 0.5 + 0.1, 0), Vector3(s.x + 0.5, 0.2, s.z + 0.6), paint.darkened(0.1))
		if det:
			for sx: float in [-1.0, 1.0]:
				_kutu(k, c + Vector3(sx * (s.x * 0.5 + 0.03), 0.1, 0), Vector3(0.06, 0.5, 1.2), trim)
	# Kıçta tente (renkli, dört direkli)
	var tz := -L * 0.2 if tip == "kadirga" else -L * 0.3
	if tip == "kadirga" or tip == "kalyata":
		for q in 4:
			_sil(k, Vector3(-1.2 + (q % 2) * 2.4, yd, tz - (q / 2) * 3.0), Vector3(-1.2 + (q % 2) * 2.4, yd + 2.4, tz - (q / 2) * 3.0), 0.04, SH_WOOD, 4)
		_kutu(k, Vector3(0, yd + 2.45, tz - 1.5), Vector3(3.0, 0.06, 3.4), Color("b8283a") if osm else Color("c8b890"))
	# Kürekler
	var kn := 12 if tip == "kadirga" else (10 if tip == "kalyata" else (8 if tip == "fusta" else 7))
	if not det:
		kn = maxi(kn / 2, 3)
	_kurekler(k, tip, kn, -L * 0.32, L * 0.30, 4.6 if tip == "kadirga" else 3.8, SH_DECK.darkened(0.2), det)
	# Direk ve latin yelken
	match tip:
		"kadirga":
			_latin(k, Vector3(0, yd, L * 0.1), 13.5, 19.0, SH_SAIL, acik, 0.22)
			if det:
				_latin(k, Vector3(0, yd, L * 0.38), 7.0, 9.0, SH_SAIL, false, 0.14)       # trinket (baş direği)
		"kalyata":
			_latin(k, Vector3(0, yd, L * 0.08), 10.5, 15.0, SH_SAIL, acik, 0.17)
		"fusta":
			_latin(k, Vector3(0, yd, L * 0.05), 8.0, 11.5, SH_SAIL, acik, 0.14)
		"parandarya":
			_latin(k, Vector3(0, yd, L * 0.16), 11.0, 15.0, SH_SAIL, acik, 0.2)
			_latin(k, Vector3(0, yd, -L * 0.14), 9.0, 12.0, SH_SAIL, acik, 0.17)
	# Bayrak ve flama
	var ust := {"kadirga": 13.5, "kalyata": 10.5, "fusta": 8.0, "parandarya": 11.0}[tip] as float
	var mz := {"kadirga": L * 0.1, "kalyata": L * 0.08, "fusta": L * 0.05, "parandarya": L * 0.16}[tip] as float
	_flama(k, Vector3(0, yd + ust, mz), 4.0 if tip == "kadirga" else 3.0, trim if not osm else Color("c8262f"))
	var kz := -L * 0.46
	_sil(k, Vector3(0, yd + 0.8, kz), Vector3(0, yd + 3.6, kz), 0.05, SH_WOOD, 4)
	_bayrak(k, Vector3(0, yd + 3.6, kz), bay, 2.4 if tip == "kadirga" else 1.8, 1.5 if tip == "kadirga" else 1.1, det)
	if tip == "parandarya":
		# Ortada geniş ambar kapağı ve kıçta at yükleme kapısı
		_kutu(k, Vector3(0, yd + 0.14, 1.0), Vector3(3.6, 0.28, 6.2), SH_HULL.darkened(0.25))
		for q in 5:
			_kutu(k, Vector3(0, yd + 0.3, -1.4 + q * 1.2), Vector3(3.7, 0.06, 0.12), SH_DECK.lightened(0.1))
		if det:
			_kutu(k, Vector3(0, yd + 0.5, -L * 0.5 + 0.12), Vector3(1.6, 1.0, 0.08), SH_TAR)
			# yük: at yemi balyaları
			for q in 3:
				_kutu(k, Vector3(-1.3 + q * 1.3, yd + 0.5, 5.6), Vector3(1.0, 0.8, 1.0), Color("b8a060"))
	elif det:
		# Sıra tahtaları: merkez yolluğunun iki yanında kürekçi oturakları (basit tahta sırası)
		for q in kn:
			var z := lerpf(-L * 0.32, L * 0.30, float(q) / maxf(kn - 1, 1))
			for sx: float in [-1.0, 1.0]:
				_kutu(k, Vector3(sx * 0.95, yd + 0.12, z + 0.1), Vector3(1.0, 0.14, 0.34), SH_HULL.lightened(0.08))


# ------------------------------------------------------------------ küçük tekneler

static func _balikci(k: MeshKit, bay: String, lod: int, acik: bool) -> void:
	var L := 8.0
	_govde(k, "balikci", bay)
	var yd := deck_y("balikci")
	var m := Vector3(0, yd, 1.2)
	_sil(k, m, m + Vector3(0, 6.2, 0), 0.08, SH_WOOD.lightened(0.05), 5)
	_latin(k, m, 6.4, 7.0, SH_SAIL.darkened(0.06), acik, 0.07)
	_kutu(k, Vector3(0, yd + 0.45, -2.2), Vector3(0.45, 0.9, 0.35), Color("94382c"))
	_kutu(k, Vector3(0, yd + 1.05, -2.2), Vector3(0.3, 0.3, 0.3), Color("d8b090"))
	_kutu(k, Vector3(0.4, yd + 0.2, -0.6), Vector3(0.9, 0.3, 0.9), Color("7a6a50"))        # ağ yığını


static func _sandal(k: MeshKit, bay: String, lod: int) -> void:
	_govde(k, "sandal", bay)
	var yd := deck_y("sandal")
	for z: float in [-0.9, 0.9]:
		_kutu(k, Vector3(0, yd + 0.45, z), Vector3(0.45, 0.9, 0.35), Color("7a4a32") if z < 0.0 else Color("3e5478"))
		_kutu(k, Vector3(0, yd + 1.05, z), Vector3(0.3, 0.3, 0.3), Color("d8b090"))
		for s: float in [-1.0, 1.0]:
			_rod(k, Vector3(s * 0.7, yd + 0.5, z), Vector3(s * 2.4, -0.25, z - 0.3), 0.05, SH_DECK.darkened(0.2))


# ------------------------------------------------------------------ uzak siluet (lod 2)

## Birkaç düz çokgen: gövde (8 köşe, iki yüz), direk, sarılı yelken kutusu, kürekli gemide iki kürek şeridi
static func _siluet(k: MeshKit, tip: String, bay: String) -> void:
	var d: Dictionary = TIPLER[tip]
	var L: float = d["L"]
	var B: float = d["B"]
	var yd: float = d["D"]
	var pal := boya(bay)
	var paint: Color = pal[0]
	var rail: float = d["R"]
	var yt: float = yd + rail + (d["SH"] as float) * 0.3
	var T: float = d["T"]
	# Gövde: üstten kutu + yan şerit (3 kesit)
	var st := [[-0.5, 0.45], [-0.25, 0.9], [0.1, 1.0], [0.38, 0.8], [0.5, 0.05]]
	for s: float in [-1.0, 1.0]:
		for i in 4:
			var a: Array = st[i]
			var b: Array = st[i + 1]
			var pa := Vector3(s * B * 0.5 * (a[1] as float), yt, (a[0] as float) * L)
			var pb := Vector3(s * B * 0.5 * (b[1] as float), yt, (b[0] as float) * L)
			var qa := Vector3(s * B * 0.5 * (a[1] as float) * 0.8, -T * 0.5, (a[0] as float) * L)
			var qb := Vector3(s * B * 0.5 * (b[1] as float) * 0.8, -T * 0.5, (b[0] as float) * L)
			Landmarks1453._oq(k, qa, qb, pb, pa, paint if i % 2 == 0 else paint.darkened(0.1), Vector3(s, 0, 0))
			Landmarks1453._oq(k, Vector3(0, yd, (a[0] as float) * L), Vector3(0, yd, (b[0] as float) * L), Vector3(s * B * 0.5 * (b[1] as float) * 0.88, yd, (b[0] as float) * L),
				Vector3(s * B * 0.5 * (a[1] as float) * 0.88, yd, (a[0] as float) * L), SH_DECK, Vector3.UP)
	var hm := {"karaka": 19.0, "kog": 15.0, "kadirga": 13.0, "kalyata": 10.5, "fusta": 8.0, "parandarya": 11.0, "balikci": 6.2, "sandal": 0.0}[tip] as float
	if hm > 0.0:
		var mz := 0.4 if tip == "karaka" or tip == "kog" else L * 0.1
		_rod(k, Vector3(0, yd, mz), Vector3(0, yd + hm, mz), 0.2, SH_WOOD)
		var sw := {"karaka": 10.0, "kog": 8.0}.get(tip, 2.4) as float
		_rod(k, Vector3(-sw * 0.5, yd + hm * 0.8, mz), Vector3(sw * 0.5, yd + hm * 0.8, mz), 0.3, SH_SAIL.darkened(0.12))
	if tip in ["kadirga", "kalyata", "fusta", "parandarya"]:
		for s: float in [-1.0, 1.0]:
			Landmarks1453._oq(k, Vector3(s * (B * 0.5 + 0.4), yd + 0.1, -L * 0.3), Vector3(s * (B * 0.5 + 0.4), yd + 0.1, L * 0.3),
				Vector3(s * (B * 0.5 + 4.0), -0.2, L * 0.3 - 0.8), Vector3(s * (B * 0.5 + 4.0), -0.2, -L * 0.3 - 0.8), SH_DECK.darkened(0.2), Vector3(0, 1, 0))
			Landmarks1453._oq(k, Vector3(s * (B * 0.5 + 0.4), yd + 0.1, -L * 0.3), Vector3(s * (B * 0.5 + 0.4), yd + 0.1, L * 0.3),
				Vector3(s * (B * 0.5 + 4.0), -0.2, L * 0.3 - 0.8), Vector3(s * (B * 0.5 + 4.0), -0.2, -L * 0.3 - 0.8), SH_DECK.darkened(0.2), Vector3(0, -1, 0))


# ------------------------------------------------------------------ ağ

static func _kur(tip: String, bay: String, lod: int, acik: bool) -> MeshKit:
	var k := MeshKit.new()
	if lod >= 2:
		_siluet(k, tip, bay)
		return k
	match tip:
		"karaka":
			_karaka(k, "karaka", bay, lod, acik)
		"kog":
			_kog(k, bay, lod, acik)
		"kadirga", "kalyata", "fusta", "parandarya":
			_kadirga(k, tip, bay, lod, acik)
		"balikci":
			_balikci(k, bay, lod, acik)
		_:
			_sandal(k, bay, lod)
	return k


## Önbellekli ağ. lod 0: tam; 1: sade (az kürek, bayrak desensiz, halat yok); 2: siluet
static func mesh(tip: String, bay: String, lod := 0, acik := false) -> ArrayMesh:
	var key := "%s|%s|%d|%d" % [tip, bay, lod, 1 if acik else 0]
	if _onbellek.has(key):
		return _onbellek[key]
	var k := _kur(tip, bay, lod, acik)
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, Landmarks1453.front_faces(k.arrays()))
	_onbellek[key] = am
	return am


static func ucgen(tip: String, bay: String, lod: int, acik := false) -> int:
	var am := mesh(tip, bay, lod, acik)
	var n := 0
	for s in am.get_surface_count():
		n += (am.surface_get_arrays(s)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return n


# ------------------------------------------------------------------ gölgelendirici

const SALINIM := """
shader_type spatial;
render_mode diffuse_toon, specular_toon, cull_back;
uniform float genlik = 0.014;
uniform float hiz = 0.85;
varying vec3 v_renk;
void vertex() {
	vec3 org = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float ph = org.x * 0.173 + org.z * 0.231;
	float t = TIME * hiz;
	float roll = sin(t + ph) * genlik;
	float pitch = sin(t * 0.77 + ph * 1.7) * genlik * 0.6;
	VERTEX.y += VERTEX.x * roll + VERTEX.z * pitch + sin(t * 1.3 + ph) * 0.03;
	v_renk = COLOR.rgb;
}
void fragment() {
	ALBEDO = v_renk;
	ROUGHNESS = 0.92;
	SPECULAR = 0.2;
}
"""

static var _mat: ShaderMaterial


## Tek gölgelendirici, tüm gemiler için (örnek konumuna göre evre: her tekneye ayrı betik yok)
static func malzeme() -> ShaderMaterial:
	if _mat == null:
		var sh := Shader.new()
		sh.code = SALINIM
		_mat = ShaderMaterial.new()
		_mat.shader = sh
	return _mat
