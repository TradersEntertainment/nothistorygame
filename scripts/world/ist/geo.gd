class_name IstGeo
extends RefCounted
## İstanbul v2 coğrafyası (docs/_ajan/gorev/_ist2_ortak.md, DONDURULMUŞ ARAYÜZ).
## Gerçek koordinat: Ayasofya kubbesi (0,0), doğu e, kuzey n (metre). Dünya: x = e × S, z = −n × S, y = yükseklik × S.
## Kıyı: OpenStreetMap ilçe sınırları (Fatih, Beyoğlu, Üsküdar, Kadıköy, Eyüpsultan, Beşiktaş, …; Nominatim) bugünkü
## kıyıdır; 1453 kıyısı için dolgular geri alındı (kıyı boyu 60 m, Marmara 100 m, Eminönü 190 m, Harem/Haydarpaşa
## 220 m, Yenikapı–Yedikule elle çizilen sur hattı). Yükseklik: kıyıya uzaklık + yedi tepe, Lykos vadisi, Galata/Pera,
## Çamlıca (kestirim). Izgara verisi: assets/ist2/arazi_h.res (RF) ve arazi_b.res (L8), 10 m dünya hücresi.
## Üretici: tests/_ist/geo_veri.py (Python) + tests/_ist/geo_veri.gd (Godot dönüştürücü).

const S := 0.5
const LAT0 := 41.0086
const LON0 := 28.9802
const KY := 111132.0                       # m / derece enlem
const KX := 84006.1                        # m / derece boylam (41,0086°)
## Izgara (dünya metre)
const X0 := -6000.0
const Z0 := -5500.0
const ST := 10.0
const NX := 1201
const NZ := 1001
## Bölge kodları (arazi_b)
const B_DENIZ := 0
const B_YARIMADA := 1
const B_GALATA := 2
const B_TRAKYA := 3
const B_ANADOLU := 4

static var _h := PackedFloat32Array()
static var _b := PackedByteArray()
static var _hazir := false
static var _yerler: Array = []
static var _duz: Array = []                # [Vector2 merkez, yarıçap, y, geçiş]
static var _duz_izg := {}                  # Vector2i(64 m hücre) → [indeks]

static func _yukle() -> void:
	if _hazir:
		return
	_hazir = true
	var ih = load("res://assets/ist2/arazi_h.res")
	var ib = load("res://assets/ist2/arazi_b.res")
	if ih is Image and ib is Image:
		_h = (ih as Image).get_data().to_float32_array()
		_b = (ib as Image).get_data()
	if _h.size() != NX * NZ or _b.size() != NX * NZ:
		push_error("IstGeo: arazi verisi okunamadı (assets/ist2/arazi_*.res)")
		_h = PackedFloat32Array(); _h.resize(NX * NZ); _h.fill(-5.0)
		_b = PackedByteArray(); _b.resize(NX * NZ)

## gerçek (doğu, kuzey m) → dünya (x, yükseklik, z)
static func w(e: float, n: float) -> Vector3:
	var x := e * S
	var z := -n * S
	return Vector3(x, h(x, z), z)

static func w2(e: float, n: float) -> Vector2:
	return Vector2(e * S, -n * S)

## enlem/boylam → dünya
static func ll(enlem: float, boylam: float) -> Vector3:
	return w((boylam - LON0) * KX, (enlem - LAT0) * KY)

## dünya → gerçek (e, n)
static func real(x: float, z: float) -> Vector2:
	return Vector2(x / S, -z / S)

## Ham ızgara yüksekliği (düzleme kayıtları hariç), çift doğrusal
static func h_ham(x: float, z: float) -> float:
	if not _hazir:
		_yukle()
	var fx := clampf((x - X0) / ST, 0.0, NX - 1.001)
	var fz := clampf((z - Z0) / ST, 0.0, NZ - 1.001)
	var i := int(fx)
	var j := int(fz)
	var tx := fx - i
	var tz := fz - j
	var k := j * NX + i
	var a := _h[k] + (_h[k + 1] - _h[k]) * tx
	var b := _h[k + NX] + (_h[k + NX + 1] - _h[k + NX]) * tx
	return a + (b - a) * tz

## Arazi yüksekliği (dünya y; su altında deniz tabanı < 0). Yapı tabanı düzleme kayıtlarını (duzle) uygular.
static func h(x: float, z: float) -> float:
	var y := h_ham(x, z)
	if _duz.is_empty():
		return y
	var c := Vector2i(floori(x / 64.0), floori(z / 64.0))
	var l = _duz_izg.get(c)
	if l == null:
		return y
	for idx in l:
		var d: Array = _duz[idx]
		var r: float = d[1]
		var g: float = d[3]
		var dist := (d[0] as Vector2).distance_to(Vector2(x, z))
		if dist <= r:
			y = d[2]
		elif dist < r + g:
			var t := (dist - r) / g
			t = t * t * (3.0 - 2.0 * t)
			y = lerpf(d[2], y, t)
	return y

## Yapı tabanı için düzlük kaydı (dünya merkez x,z; yarıçap; y). Arazi ağı bu kayıtlardan SONRA kurulmalı
## (IstDunya parçaları kayıttan sonra kurulanlar için yenilenir: IstDunya.yenile()).
static func duzle(merkez: Vector2, yaricap: float, y: float, gecis := -1.0) -> void:
	if gecis < 0.0:
		gecis = maxf(4.0, yaricap * 0.6)
	var idx := _duz.size()
	_duz.append([merkez, yaricap, y, gecis])
	var R := yaricap + gecis
	for cx in range(floori((merkez.x - R) / 64.0), floori((merkez.x + R) / 64.0) + 1):
		for cz in range(floori((merkez.y - R) / 64.0), floori((merkez.y + R) / 64.0) + 1):
			var key := Vector2i(cx, cz)
			if not _duz_izg.has(key):
				_duz_izg[key] = []
			_duz_izg[key].append(idx)

static func duzle_temizle() -> void:
	_duz.clear()
	_duz_izg.clear()

## Bölge kodu (en yakın hücre)
static func bolge(x: float, z: float) -> int:
	if not _hazir:
		_yukle()
	var i := clampi(int(roundf((x - X0) / ST)), 0, NX - 1)
	var j := clampi(int(roundf((z - Z0) / ST)), 0, NZ - 1)
	return _b[j * NX + i]

## Deniz mi (deniz düzeyi y = 0)
static func su(x: float, z: float) -> bool:
	return h_ham(x, z) < 0.0

static func _bolgede(x: float, z: float, kod: int, poly: PackedVector2Array) -> bool:
	if not _hazir:
		_yukle()
	var fx := clampf((x - X0) / ST, 0.0, NX - 1.001)
	var fz := clampf((z - Z0) / ST, 0.0, NZ - 1.001)
	var k := int(fz) * NX + int(fx)
	var a := _b[k] == kod
	if a == (_b[k + 1] == kod) and a == (_b[k + NX] == kod) and a == (_b[k + NX + 1] == kod):
		return a
	return Geometry2D.is_point_in_polygon(Vector2(x, z), poly)

## Surların içinde mi (yarımada)
static func sehir_ici(x: float, z: float) -> bool:
	return _bolgede(x, z, B_YARIMADA, K_YARIMADA)

static func galata_ici(x: float, z: float) -> bool:
	return _bolgede(x, z, B_GALATA, K_GALATA)

## Dünya (x,z) çoklu çizgi
static func yol(ad: String) -> PackedVector2Array:
	match ad:
		"kara_suru": return Y_KARA
		"marmara_suru": return Y_MARMARA
		"halic_suru": return Y_HALIC
		"galata_suru": return Y_GALATA
		"blakherna_suru": return Y_BLAKHERNA
		"mese": return Y_MESE
		"mese_kuzey": return Y_MESE_K
		"mese_guney": return Y_MESE_G
		"lykos": return Y_LYKOS
		"zincir": return Y_ZINCIR
		"bozdogan": return Y_BOZDOGAN
	push_warning("IstGeo.yol: bilinmeyen ad %s" % ad)
	return PackedVector2Array()

## Kapalı çokgen (dünya x,z)
static func kiyi(ad: String) -> PackedVector2Array:
	match ad:
		"yarimada": return K_YARIMADA
		"galata": return K_GALATA
		"anadolu": return K_ANADOLU
		"trakya": return K_TRAKYA
	push_warning("IstGeo.kiyi: bilinmeyen ad %s" % ad)
	return PackedVector2Array()

## Çoklu çizgiye uzaklık (dünya metre)
static func cizgi_uzak(p: Vector2, c: PackedVector2Array) -> float:
	var best := INF
	for i in c.size() - 1:
		var q := Geometry2D.get_closest_point_to_segment(p, c[i], c[i + 1])
		best = minf(best, p.distance_squared_to(q))
	return sqrt(best)

## Mahalle (docs/ISTANBUL_PLAN.md §2'nin v2 karşılığı; gerçek yerleriyle)
## {"ad", "tur": "carsi|sik|seyrek|bostan|harabe|liman|sur_dibi|kir", "yogunluk": 0..1}
static func mahalle(x: float, z: float) -> Dictionary:
	var p := Vector2(x, z)
	if su(x, z):
		return {"ad": "deniz", "tur": "kir", "yogunluk": 0.0}
	if galata_ici(x, z):
		var dk := cizgi_uzak(p, Y_ZINCIR)
		if h_ham(x, z) < 4.0:
			return {"ad": "Galata iskelesi", "tur": "liman", "yogunluk": 0.7}
		return {"ad": "Galata (Pera)", "tur": "sik", "yogunluk": 0.85 if dk > 60.0 else 0.75}
	if not sehir_ici(x, z):
		var b := bolge(x, z)
		if b == B_ANADOLU:
			var du := p.distance_to(w2(2900.0, 1900.0))
			if du < 450.0:
				return {"ad": "Üsküdar (Skutari)", "tur": "seyrek", "yogunluk": 0.3}
			return {"ad": "Anadolu yakası", "tur": "kir", "yogunluk": 0.03}
		if p.distance_to(w2(-3880.0, 5160.0)) < 500.0:
			return {"ad": "Kosmidion (Eyüp)", "tur": "seyrek", "yogunluk": 0.1}
		if cizgi_uzak(p, Y_KARA) < 120.0:
			return {"ad": "sur önü (hendek ve ova)", "tur": "kir", "yogunluk": 0.0}
		if x < -1000.0 and z > -2200.0:
			return {"ad": "kuşatma ovası", "tur": "kir", "yogunluk": 0.0}
		return {"ad": "Pera bağları", "tur": "kir", "yogunluk": 0.05}
	var r := real(x, z)
	for m in MAH_OZEL:
		if r.distance_to(m[1]) < m[2]:
			return {"ad": m[0], "tur": m[3], "yogunluk": m[4]}
	var d_kara := cizgi_uzak(p, Y_KARA)
	if d_kara < 60.0:
		return {"ad": "sur dibi", "tur": "sur_dibi", "yogunluk": 0.15}
	var d_mese := minf(cizgi_uzak(p, Y_MESE), minf(cizgi_uzak(p, Y_MESE_K), cizgi_uzak(p, Y_MESE_G)))
	if d_mese < 30.0:
		return {"ad": "Mese çarşısı", "tur": "carsi", "yogunluk": 0.95}
	var d_halic := cizgi_uzak(p, Y_HALIC)
	if d_halic < 45.0 and r.x > -2900.0:
		return {"ad": _ad(r), "tur": "liman", "yogunluk": 0.8}
	if r.distance_to(Vector2.ZERO) < 480.0:
		return {"ad": "Ayasofya çevresi", "tur": "sik", "yogunluk": 0.85}
	if cizgi_uzak(p, Y_LYKOS) < 120.0:
		return {"ad": "Lykos vadisi", "tur": "bostan", "yogunluk": 0.1}
	if d_halic < 160.0 and r.x > -2900.0:
		return {"ad": _ad(r), "tur": "sik", "yogunluk": 0.8}
	var d_marm := cizgi_uzak(p, Y_MARMARA)
	if d_marm < 70.0:
		return {"ad": _ad(r), "tur": "sik", "yogunluk": 0.6}
	# batıya doğru seyrelir; sur içi şeridi bostan/bağ/harabe/seyrek köy
	var yog := clampf(1.0 - (-r.x - 600.0) / 3200.0, 0.1, 0.8)
	if d_kara < 450.0:
		var g := _gurultu(r.x, r.y)
		if g < 0.35:
			return {"ad": "sur içi bostanları", "tur": "bostan", "yogunluk": 0.08}
		if g < 0.55:
			return {"ad": "sur içi bağları", "tur": "bostan", "yogunluk": 0.05}
		if g < 0.7:
			return {"ad": "eski mahalle harabeleri", "tur": "harabe", "yogunluk": 0.1}
		return {"ad": _ad(r), "tur": "seyrek", "yogunluk": 0.2}
	if yog < 0.45:
		var g2 := _gurultu(r.x, r.y)
		if g2 < 0.3:
			return {"ad": _ad(r) + " bostanları", "tur": "bostan", "yogunluk": 0.08}
		return {"ad": _ad(r), "tur": "seyrek", "yogunluk": yog}
	return {"ad": _ad(r), "tur": "sik" if yog > 0.6 else "seyrek", "yogunluk": yog}

static func _gurultu(e: float, n: float) -> float:
	var v := sin(e * 0.0061 + 1.7) * sin(n * 0.0049 + 0.3) + 0.6 * sin(e * 0.0137 - n * 0.0101)
	return clampf(v * 0.31 + 0.5, 0.0, 1.0)

static func _ad(r: Vector2) -> String:
	var best := ""
	var bd := INF
	for m in MAH_AD:
		var d := r.distance_squared_to(m[1])
		if d < bd:
			bd = d
			best = m[0]
	return best

## Özel alanlar (gerçek e,n; yarıçap gerçek m): ad, merkez, yarıçap, tür, yoğunluk
const MAH_OZEL := [
	["Büyük Saray harabeleri", Vector2(-120, -480), 330.0, "harabe", 0.05],
	["Bukoleon", Vector2(-90, -830), 120.0, "harabe", 0.05],
	["Hipodrom", Vector2(-378, -289), 140.0, "harabe", 0.0],
	["Langa bostanı (dolmuş Eleutherios limanı)", Vector2(-2250, -560), 300.0, "bostan", 0.05],
	["Kontoskalion limanı", Vector2(-1200, -700), 110.0, "liman", 0.6],
	["Aetios sarnıcı (bostan)", Vector2(-3335, 1880), 125.0, "bostan", 0.0],
	["Aspar sarnıcı (bostan)", Vector2(-2705, 1930), 105.0, "bostan", 0.0],
	["Mokios sarnıcı (bostan)", Vector2(-3670, -70), 120.0, "bostan", 0.0],
	["Mangana / Akropolis bahçeleri", Vector2(330, 360), 230.0, "seyrek", 0.2],
	["Blakherna", Vector2(-3300, 3300), 220.0, "seyrek", 0.35],
	["Havariyun nekropolü", Vector2(-2450, 1150), 110.0, "seyrek", 0.2],
]
const MAH_AD := [
	["Sfendone", Vector2(-450, -550)], ["Augustaion", Vector2(-40, 40)], ["Chalkoprateia", Vector2(-300, 250)],
	["Neorion", Vector2(-700, 900)], ["Venedik mahallesi", Vector2(-1100, 1100)], ["Amalfi/Pisa iskeleleri", Vector2(-500, 850)],
	["Vlanga", Vector2(-1500, -500)], ["Kontoskalion", Vector2(-1150, -700)], ["Konstantin Forumu", Vector2(-760, 0)],
	["Tauri", Vector2(-1550, 210)], ["Zeugma (Unkapanı)", Vector2(-2000, 1600)], ["Pantokrator", Vector2(-2010, 1210)],
	["Havariyun", Vector2(-2450, 1150)], ["Petra (Fener)", Vector2(-2480, 2210)], ["Fener", Vector2(-2700, 2400)],
	["Blakherna", Vector2(-3300, 3300)], ["Kariye (Khora)", Vector2(-3440, 2490)], ["Psamathia", Vector2(-3800, -900)],
	["Studios", Vector2(-4490, -1600)], ["Xerolophos", Vector2(-3400, -480)], ["Deuteron", Vector2(-3900, 1300)],
	["Aksaray (Bous)", Vector2(-2540, -70)], ["Kyparission", Vector2(-3200, 300)], ["Mangana", Vector2(330, 360)],
	["Arkadianai", Vector2(400, 0)], ["Hormisdas", Vector2(-500, -800)],
]

## ISTANBUL_YERLER.csv satırları: {ad, tur, e, n, w: Vector3, satir, e_csv, n_csv, not}
## Kapılar sur hatlarına oturtuldu (CSV'deki deniz suru kapılarının konumu kaba; sıra korunur).
static func yerler() -> Array:
	if _yerler.is_empty():
		for r in YERLER_HAM:
			_yerler.append({"ad": r[0], "tur": r[1], "e": r[2], "n": r[3], "w": w(r[2], r[3]), "satir": r[6],
				"e_csv": r[4], "n_csv": r[5], "not": r[7]})
	return _yerler

static var K_YARIMADA := PackedVector2Array([Vector2(-2418.66,885.99), Vector2(-2427.47,886.87), Vector2(-2437.58,852.44), Vector2(-2428.66,848.88), Vector2(-2440.55,815.63), Vector2(-2444.86,818.51), Vector2(-2468.32,770.23), Vector2(-2513.66,503.74), Vector2(-2516.87,434.58), Vector2(-2488.98,301.5), Vector2(-2472.86,198.3), Vector2(-2466.2,139.87), Vector2(-2444.48,23.75), Vector2(-2430.7,18.66), Vector2(-2427.99,-19.52), Vector2(-2440.3,-21.52), Vector2(-2440.21,-38.9), Vector2(-2432.55,-39.24), Vector2(-2430.21,-168.24), Vector2(-2448.6,-230.42), Vector2(-2454.87,-262.02), Vector2(-2436.77,-384.94), Vector2(-2427.1,-417.75), Vector2(-2393.39,-517.7), Vector2(-2389.72,-515.79), Vector2(-2355.25,-600.12), Vector2(-2349.48,-597.08), Vector2(-2309.76,-678.55), Vector2(-2270.36,-718.86), Vector2(-2274.29,-722.82), Vector2(-2268.42,-732.69), Vector2(-2137.93,-888.53), Vector2(-2125.36,-877.11), Vector2(-2112.38,-897.06), Vector2(-2033.48,-996.09), Vector2(-2013.1,-1025.6), Vector2(-1901.2,-1152.18), Vector2(-1879.76,-1183.21), Vector2(-1876.77,-1191.96), Vector2(-1879.05,-1206.1), Vector2(-1850.88,-1263.83), Vector2(-1687.24,-1373.42), Vector2(-1678.11,-1390.22), Vector2(-1675.11,-1440.79), Vector2(-1698.5,-1445.43), Vector2(-1725.96,-1465.31), Vector2(-1713.36,-1532.6), Vector2(-1714.73,-1559.46), Vector2(-1722.69,-1599.8), Vector2(-1714.49,-1627.38), Vector2(-1682.41,-1643.14), Vector2(-1669.12,-1646.72), Vector2(-1632.09,-1692.52), Vector2(-1628.29,-1691.17), Vector2(-1616.95,-1729.8), Vector2(-1585.42,-1736.03), Vector2(-1580.71,-1743.56), Vector2(-1547.92,-1718.03), Vector2(-1515.08,-1762.4), Vector2(-1511.87,-1761.18), Vector2(-1452.66,-1633.55), Vector2(-1450.19,-1615.59), Vector2(-1440.41,-1597.83), Vector2(-1421.49,-1550.92), Vector2(-1397.82,-1519.93), Vector2(-1368.44,-1502.69), Vector2(-1350.56,-1496.62), Vector2(-1332.39,-1476.71), Vector2(-1330.43,-1460.23), Vector2(-1335.68,-1439.65), Vector2(-1332.95,-1410.31), Vector2(-1322.79,-1387.19), Vector2(-1314.55,-1378.97), Vector2(-1303.95,-1372.81), Vector2(-1307.43,-1354.16), Vector2(-1303.97,-1307.88), Vector2(-1298.17,-1296.01), Vector2(-1270.15,-1255.63), Vector2(-1260.91,-1245.81), Vector2(-1237.52,-1229.91), Vector2(-1198.16,-1215.66), Vector2(-1181.41,-1214.2), Vector2(-1178.27,-1210.01), Vector2(-1184.48,-1198.54), Vector2(-1187.13,-1185.92), Vector2(-1184.89,-1168.81), Vector2(-1165.56,-1135.11), Vector2(-1147.6,-1118.34), Vector2(-1060.35,-1089.5), Vector2(-1007.1,-1079.1), Vector2(-983.58,-1078.91), Vector2(-978.87,-1063.25), Vector2(-966.21,-1038.94), Vector2(-927.32,-999.16), Vector2(-894.25,-974.88), Vector2(-892.74,-942.24), Vector2(-879.83,-911.16), Vector2(-850.98,-865.18), Vector2(-820.59,-825.45), Vector2(-806.77,-812.72), Vector2(-770.5,-791.3), Vector2(-749.0,-774.59), Vector2(-735.47,-768.7), Vector2(-730.21,-761.59), Vector2(-733.27,-750.0), Vector2(-767.24,-749.99), Vector2(-769.4,-748.17), Vector2(-765.54,-713.05), Vector2(-750.87,-680.63), Vector2(-733.79,-660.26), Vector2(-714.27,-643.08), Vector2(-691.86,-629.42), Vector2(-662.19,-615.51), Vector2(-656.26,-594.8), Vector2(-647.85,-579.6), Vector2(-637.79,-567.72), Vector2(-625.33,-557.72), Vector2(-608.26,-548.5), Vector2(-587.81,-543.45), Vector2(-571.41,-543.32), Vector2(-555.43,-546.29), Vector2(-525.92,-539.0), Vector2(-476.66,-538.66), Vector2(-460.43,-522.77), Vector2(-399.47,-482.36), Vector2(-347.4,-466.2), Vector2(-326.51,-466.04), Vector2(-303.9,-469.98), Vector2(-286.61,-463.23), Vector2(-258.71,-445.91), Vector2(-238.44,-438.15), Vector2(-223.85,-428.43), Vector2(-194.31,-415.11), Vector2(-169.86,-397.9), Vector2(-141.36,-388.68), Vector2(-116.11,-389.53), Vector2(-73.68,-383.64), Vector2(11.88,-384.77), Vector2(28.7,-383.02), Vector2(64.24,-386.07), Vector2(87.01,-392.37), Vector2(133.53,-418.12), Vector2(174.93,-435.17), Vector2(202.12,-440.28), Vector2(219.47,-435.77), Vector2(249.41,-283.86), Vector2(266.06,-232.32), Vector2(267.01,-214.94), Vector2(261.83,-151.75), Vector2(263.97,-150.01), Vector2(296.61,-150.0), Vector2(292.08,-96.66), Vector2(252.37,2.46), Vector2(228.75,92.42), Vector2(219.75,110.53), Vector2(201.08,134.86), Vector2(134.45,185.5), Vector2(110.92,207.21), Vector2(53.75,289.6), Vector2(31.54,310.36), Vector2(4.68,328.32), Vector2(-12.89,336.1), Vector2(-69.02,348.62), Vector2(-79.85,353.07), Vector2(-93.07,364.55), Vector2(-100.56,379.11), Vector2(-108.9,379.77), Vector2(-109.57,386.7), Vector2(-190.49,382.38), Vector2(-206.26,385.42), Vector2(-219.24,393.2), Vector2(-288.16,390.28), Vector2(-300.93,391.6), Vector2(-384.78,369.03), Vector2(-468.81,338.72), Vector2(-527.5,331.8), Vector2(-529.54,318.16), Vector2(-534.0,314.04), Vector2(-540.06,312.5), Vector2(-665.06,312.5), Vector2(-672.83,315.26), Vector2(-677.43,323.7), Vector2(-680.49,325.08), Vector2(-697.36,320.4), Vector2(-722.14,321.29), Vector2(-734.46,326.04), Vector2(-744.03,333.33), Vector2(-754.61,335.19), Vector2(-775.17,332.03), Vector2(-789.46,335.61), Vector2(-813.87,350.63), Vector2(-825.18,367.75), Vector2(-890.45,349.93), Vector2(-906.07,349.41), Vector2(-920.61,342.16), Vector2(-964.75,330.93), Vector2(-982.46,332.11), Vector2(-998.99,340.56), Vector2(-1015.07,335.55), Vector2(-1023.84,326.81), Vector2(-1035.24,320.58), Vector2(-1058.14,318.34), Vector2(-1092.49,324.57), Vector2(-1111.21,336.83), Vector2(-1125.76,340.06), Vector2(-1137.07,346.72), Vector2(-1169.26,388.4), Vector2(-1174.46,399.86), Vector2(-1176.34,412.05), Vector2(-1624.95,430.0), Vector2(-1738.93,439.11), Vector2(-1736.54,426.73), Vector2(-1737.44,415.45), Vector2(-1732.76,410.92), Vector2(-1731.14,400.74), Vector2(-1734.89,389.91), Vector2(-1740.54,382.19), Vector2(-1749.16,387.09), Vector2(-1751.2,391.28), Vector2(-1766.04,381.04), Vector2(-1778.28,376.27), Vector2(-1791.25,375.22), Vector2(-1810.0,377.69), Vector2(-1821.48,381.59), Vector2(-1841.56,394.4), Vector2(-1861.83,413.48), Vector2(-1870.71,429.55), Vector2(-1892.4,440.53), Vector2(-1919.11,465.47), Vector2(-1942.16,496.51), Vector2(-1967.18,551.39), Vector2(-2099.97,709.96), Vector2(-2224.95,819.96), Vector2(-2350.07,890.02), Vector2(-2423.37,910.54)])
static var K_GALATA := PackedVector2Array([Vector2(-435.0,-940.0), Vector2(-270.0,-982.5), Vector2(-150.0,-967.5), Vector2(-40.0,-900.0), Vector2(-14.85,-876.17), Vector2(-110.91,-792.63), Vector2(-127.61,-786.65), Vector2(-161.3,-763.4), Vector2(-175.08,-763.47), Vector2(-205.61,-756.45), Vector2(-236.08,-769.1), Vector2(-272.56,-771.95), Vector2(-288.19,-770.12), Vector2(-303.52,-764.3), Vector2(-344.68,-776.68), Vector2(-373.86,-777.14), Vector2(-390.94,-789.08), Vector2(-412.86,-795.52), Vector2(-490.27,-887.03)])
static var K_ANADOLU := PackedVector2Array([Vector2(1129.0,-757.0), Vector2(1169.95,-841.82), Vector2(1213.98,-904.01), Vector2(1248.86,-936.23), Vector2(1328.03,-947.7), Vector2(1368.32,-940.66), Vector2(1404.64,-952.76), Vector2(1432.99,-991.37), Vector2(1466.2,-1015.13), Vector2(1490.31,-1054.04), Vector2(1523.45,-1068.51), Vector2(1588.62,-1164.56), Vector2(1685.92,-1244.61), Vector2(1726.85,-1250.54), Vector2(1784.99,-1283.78), Vector2(2008.64,-1493.29), Vector2(2116.75,-1566.15), Vector2(2180.24,-1634.38), Vector2(2220.45,-1646.64), Vector2(2254.77,-1680.04), Vector2(2334.01,-1718.57), Vector2(2403.71,-1783.35), Vector2(2414.48,-1805.82), Vector2(2565.56,-1917.99), Vector2(2656.02,-1941.26), Vector2(2689.59,-1977.86), Vector2(2760.21,-2022.0), Vector2(2930.7,-2124.86), Vector2(2991.9,-2146.3), Vector2(3051.54,-2200.42), Vector2(3067.62,-2276.56), Vector2(3055.68,-2339.03), Vector2(3021.79,-2376.46), Vector2(3020.58,-2415.18), Vector2(3035.63,-2484.03), Vector2(3030.37,-2526.74), Vector2(3050.9,-2617.92), Vector2(3098.69,-2718.91), Vector2(3063.74,-2933.3), Vector2(3074.06,-2953.88), Vector2(3131.52,-3007.68), Vector2(3253.64,-3212.42), Vector2(3247.44,-3279.0), Vector2(3260.4,-3341.39), Vector2(3236.83,-3425.82), Vector2(3216.29,-3460.8), Vector2(3187.05,-3595.04), Vector2(3200.12,-3628.0), Vector2(3261.8,-3629.02), Vector2(3329.36,-3644.65), Vector2(3419.0,-3692.34), Vector2(3470.26,-3735.25), Vector2(3528.3,-3747.8), Vector2(3565.32,-3813.39), Vector2(3561.6,-3857.96), Vector2(3587.61,-3910.74), Vector2(3598.7,-3985.29), Vector2(3632.25,-4007.94), Vector2(3644.26,-4030.63), Vector2(3633.67,-4074.15), Vector2(3656.24,-4122.07), Vector2(3672.02,-4252.42), Vector2(3641.85,-4352.17), Vector2(3636.67,-4415.03), Vector2(3623.9,-4440.05), Vector2(3645.39,-4617.7), Vector2(3617.88,-4664.46), Vector2(3616.54,-4688.81), Vector2(3619.23,-4703.48), Vector2(3655.93,-4714.83), Vector2(3680.96,-4740.17), Vector2(3692.4,-4773.87), Vector2(3673.48,-4810.18), Vector2(3591.81,-4851.12), Vector2(3566.02,-4952.95), Vector2(3629.78,-5129.66), Vector2(3637.55,-5214.87), Vector2(3742.85,-5308.89), Vector2(3837.02,-5369.42), Vector2(3884.81,-5421.91), Vector2(3918.61,-5440.15), Vector2(3973.34,-5423.25), Vector2(4066.27,-5446.7), Vector2(4114.63,-5476.88), Vector2(4125.29,-5500.0), Vector2(4149.2,-5500.0), Vector2(4164.13,-5474.05), Vector2(4247.32,-5443.01), Vector2(4284.39,-5459.91), Vector2(4304.18,-5500.0), Vector2(6000.0,-5500.0), Vector2(6000.0,4500.0), Vector2(5680.66,4500.0), Vector2(5596.66,4340.63), Vector2(5617.25,4296.51), Vector2(5613.73,4265.85), Vector2(5339.69,3853.01), Vector2(5336.91,3827.6), Vector2(5380.0,3705.26), Vector2(5368.92,3661.48), Vector2(5344.78,3632.17), Vector2(5258.81,3577.97), Vector2(5220.85,3567.2), Vector2(5179.35,3575.4), Vector2(5036.02,3335.36), Vector2(4834.08,3125.74), Vector2(4757.83,3092.88), Vector2(4625.64,3143.76), Vector2(4612.39,3106.3), Vector2(4530.66,2986.55), Vector2(4501.03,2971.62), Vector2(4444.35,2961.3), Vector2(4413.03,2961.89), Vector2(4344.55,2983.16), Vector2(4326.85,3000.66), Vector2(4318.4,3032.96), Vector2(4278.33,3043.37), Vector2(4252.56,3036.69), Vector2(4189.57,2962.46), Vector2(4150.06,2941.21), Vector2(4134.78,2904.89), Vector2(4088.59,2862.05), Vector2(4027.14,2832.8), Vector2(3990.18,2835.95), Vector2(3967.9,2851.23), Vector2(3852.78,2778.07), Vector2(3854.38,2729.83), Vector2(3834.05,2667.04), Vector2(3736.86,2538.61), Vector2(3700.17,2519.48), Vector2(3663.5,2523.33), Vector2(3638.67,2508.66), Vector2(3589.11,2506.03), Vector2(3533.82,2515.42), Vector2(3453.5,2555.09), Vector2(3397.16,2516.35), Vector2(3321.48,2515.9), Vector2(3312.89,2469.54), Vector2(3276.89,2432.47), Vector2(3227.67,2415.28), Vector2(3188.05,2425.97), Vector2(3126.12,2340.06), Vector2(3117.22,2293.19), Vector2(3074.62,2246.61), Vector2(3026.58,2223.64), Vector2(2989.18,2230.34), Vector2(2972.41,2207.7), Vector2(2888.39,2160.25), Vector2(2782.94,2133.58), Vector2(2725.85,2143.23), Vector2(2694.24,2188.07), Vector2(2672.94,2285.49), Vector2(2581.45,2355.81), Vector2(2558.78,2352.99), Vector2(2549.87,2278.54), Vector2(2528.1,2235.98), Vector2(2445.45,2187.51), Vector2(2404.17,2183.04), Vector2(2440.55,2152.22), Vector2(2470.97,2092.82), Vector2(2468.79,2036.57), Vector2(2451.8,1989.36), Vector2(2446.33,1937.49), Vector2(2431.98,1912.29), Vector2(2517.12,1866.09), Vector2(2531.82,1840.89), Vector2(2531.88,1814.29), Vector2(2512.6,1784.26), Vector2(2490.62,1712.67), Vector2(2467.15,1691.2), Vector2(2463.31,1657.28), Vector2(2433.23,1607.39), Vector2(2273.49,1445.0), Vector2(2250.36,1439.61), Vector2(2227.99,1446.4), Vector2(2167.46,1524.04), Vector2(2116.89,1541.08), Vector2(2062.62,1576.75), Vector2(2026.01,1579.51), Vector2(2003.11,1596.82), Vector2(1959.7,1566.33), Vector2(1859.84,1582.69), Vector2(1832.04,1599.35), Vector2(1810.51,1632.65), Vector2(1770.03,1649.67), Vector2(1718.45,1576.62), Vector2(1695.58,1522.89), Vector2(1721.45,1401.57), Vector2(1707.49,1285.29), Vector2(1584.6,1048.59), Vector2(1562.68,982.66), Vector2(1614.82,978.83), Vector2(1641.87,999.3), Vector2(1682.38,1001.17), Vector2(1750.57,962.49), Vector2(1812.92,941.24), Vector2(1868.17,855.11), Vector2(1870.29,801.61), Vector2(1855.0,750.0), Vector2(1910.03,746.93), Vector2(1824.58,641.33), Vector2(1739.72,610.89), Vector2(1696.78,605.92), Vector2(1536.99,391.42), Vector2(1507.07,373.6), Vector2(1458.72,364.83), Vector2(1470.48,326.55), Vector2(1466.29,289.63), Vector2(1403.93,174.44), Vector2(1365.21,152.37), Vector2(1300.73,142.67), Vector2(1329.05,109.6), Vector2(1339.4,72.36), Vector2(1334.62,35.71), Vector2(1307.68,-20.02), Vector2(1373.28,-198.56), Vector2(1376.46,-271.05), Vector2(1358.47,-385.61), Vector2(1319.71,-482.41), Vector2(1268.11,-543.03), Vector2(1272.09,-598.89), Vector2(1220.35,-600.0), Vector2(1157.74,-676.57)])
static var K_TRAKYA := PackedVector2Array([Vector2(3243.95,-5500.0), Vector2(3223.32,-5451.55), Vector2(3211.1,-5386.86), Vector2(3192.36,-5353.45), Vector2(3185.32,-5294.78), Vector2(3121.68,-5183.31), Vector2(3113.37,-5102.57), Vector2(3095.22,-5063.84), Vector2(3062.54,-5036.74), Vector2(3055.31,-5012.72), Vector2(3073.71,-4964.55), Vector2(3095.57,-4941.41), Vector2(3075.21,-4905.48), Vector2(3072.3,-4781.83), Vector2(3098.09,-4711.11), Vector2(3139.27,-4639.13), Vector2(3185.86,-4591.55), Vector2(3194.15,-4562.85), Vector2(3202.78,-4455.84), Vector2(3194.62,-4403.97), Vector2(3207.72,-4328.09), Vector2(3191.28,-4144.42), Vector2(3155.27,-4079.7), Vector2(3087.45,-4031.46), Vector2(3017.65,-3995.44), Vector2(2967.14,-3992.17), Vector2(2857.57,-3954.3), Vector2(2774.83,-3944.04), Vector2(2727.13,-3892.23), Vector2(2696.71,-3884.9), Vector2(2669.91,-3852.46), Vector2(2660.7,-3813.52), Vector2(2669.27,-3770.16), Vector2(2653.36,-3686.05), Vector2(2689.09,-3584.77), Vector2(2704.8,-3468.31), Vector2(2751.4,-3368.68), Vector2(2749.13,-3310.59), Vector2(2649.98,-3274.26), Vector2(2618.5,-3274.46), Vector2(2589.27,-3254.5), Vector2(2538.85,-3166.86), Vector2(2517.45,-3029.6), Vector2(2398.34,-2932.06), Vector2(2343.73,-2845.15), Vector2(2312.46,-2642.29), Vector2(2255.89,-2465.65), Vector2(2188.52,-2309.77), Vector2(2114.41,-2292.09), Vector2(2019.41,-2236.6), Vector2(1973.68,-2167.66), Vector2(1929.9,-2188.47), Vector2(1868.63,-2176.42), Vector2(1696.52,-2089.09), Vector2(1639.79,-2058.07), Vector2(1576.57,-2011.83), Vector2(1562.8,-1988.57), Vector2(1519.62,-1962.39), Vector2(1244.28,-1845.34), Vector2(1147.43,-1840.83), Vector2(1127.72,-1825.56), Vector2(1093.79,-1817.35), Vector2(1035.71,-1765.02), Vector2(680.49,-1630.34), Vector2(609.93,-1565.21), Vector2(547.53,-1484.61), Vector2(544.77,-1379.23), Vector2(484.45,-1355.07), Vector2(466.31,-1326.09), Vector2(395.25,-1263.23), Vector2(325.7,-1137.41), Vector2(321.37,-1107.3), Vector2(76.26,-956.15), Vector2(-14.47,-876.5), Vector2(-149.79,-967.95), Vector2(-269.98,-983.0), Vector2(-435.22,-940.45), Vector2(-490.61,-887.4), Vector2(-535.09,-976.45), Vector2(-548.36,-1060.42), Vector2(-560.16,-1081.08), Vector2(-532.94,-1129.52), Vector2(-529.21,-1171.5), Vector2(-551.35,-1228.03), Vector2(-580.01,-1262.98), Vector2(-606.91,-1276.78), Vector2(-636.5,-1270.42), Vector2(-833.06,-1431.98), Vector2(-877.46,-1426.86), Vector2(-947.08,-1438.0), Vector2(-978.12,-1425.62), Vector2(-1007.38,-1429.58), Vector2(-1026.54,-1444.36), Vector2(-1059.1,-1445.49), Vector2(-1078.87,-1462.9), Vector2(-1125.93,-1475.7), Vector2(-1133.91,-1514.88), Vector2(-1220.61,-1649.51), Vector2(-1237.18,-1719.01), Vector2(-1272.1,-1780.82), Vector2(-1317.89,-1829.62), Vector2(-1322.48,-1863.43), Vector2(-1348.34,-1902.32), Vector2(-1385.54,-1938.86), Vector2(-1477.19,-2002.17), Vector2(-1535.49,-2025.94), Vector2(-1601.84,-2070.67), Vector2(-1609.64,-2106.08), Vector2(-1645.42,-2145.1), Vector2(-1698.07,-2277.02), Vector2(-1687.38,-2364.03), Vector2(-1655.29,-2418.34), Vector2(-1525.07,-2507.51), Vector2(-1349.94,-2581.14), Vector2(-1335.6,-2600.41), Vector2(-1303.56,-2696.72), Vector2(-1315.06,-2815.0), Vector2(-1346.58,-2902.49), Vector2(-1352.69,-2963.11), Vector2(-1350.22,-2997.98), Vector2(-1331.09,-3033.06), Vector2(-1333.95,-3065.83), Vector2(-1367.99,-3091.97), Vector2(-1390.15,-3089.92), Vector2(-1410.08,-3075.75), Vector2(-1425.37,-3079.78), Vector2(-1452.03,-3143.1), Vector2(-1476.38,-3152.17), Vector2(-1507.84,-3145.84), Vector2(-1529.37,-3115.3), Vector2(-1529.42,-3047.44), Vector2(-1476.02,-2911.83), Vector2(-1429.41,-2713.29), Vector2(-1462.67,-2712.39), Vector2(-1511.5,-2683.64), Vector2(-1563.7,-2685.6), Vector2(-1619.75,-2655.95), Vector2(-1693.71,-2636.52), Vector2(-1761.75,-2605.24), Vector2(-1861.24,-2491.24), Vector2(-1893.12,-2441.65), Vector2(-1907.93,-2403.89), Vector2(-1924.35,-2293.44), Vector2(-1917.35,-2268.88), Vector2(-1825.32,-2139.49), Vector2(-1793.6,-2111.76), Vector2(-1780.65,-1986.04), Vector2(-1723.62,-1865.69), Vector2(-1670.23,-1827.83), Vector2(-1515.56,-1762.6), Vector2(-1548.02,-1718.74), Vector2(-1580.62,-1744.05), Vector2(-1617.24,-1730.21), Vector2(-1628.63,-1691.82), Vector2(-1669.4,-1647.16), Vector2(-1714.9,-1627.66), Vector2(-1723.19,-1599.79), Vector2(-1713.86,-1532.63), Vector2(-1726.45,-1465.26), Vector2(-1698.73,-1444.98), Vector2(-1675.64,-1440.38), Vector2(-1687.62,-1373.77), Vector2(-1851.24,-1264.17), Vector2(-1879.52,-1206.26), Vector2(-1880.21,-1183.44), Vector2(-1901.6,-1152.49), Vector2(-2013.46,-1025.94), Vector2(-2125.46,-877.88), Vector2(-2137.85,-889.03), Vector2(-2146.16,-880.68), Vector2(-2310.16,-678.86), Vector2(-2393.86,-517.88), Vector2(-2437.25,-385.09), Vector2(-2455.37,-262.04), Vector2(-2430.71,-168.17), Vector2(-2433.04,-39.72), Vector2(-2440.67,-39.1), Vector2(-2440.8,-21.52), Vector2(-2428.52,-19.1), Vector2(-2431.17,18.3), Vector2(-2444.97,23.65), Vector2(-2517.37,434.59), Vector2(-2514.15,503.82), Vector2(-2468.81,770.31), Vector2(-2429.29,848.59), Vector2(-2438.08,852.48), Vector2(-2427.92,887.1), Vector2(-2419.27,886.56), Vector2(-2423.85,910.68), Vector2(-2649.14,950.28), Vector2(-2650.0,1123.83), Vector2(-2744.6,1163.29), Vector2(-2890.52,1243.06), Vector2(-3040.6,1483.93), Vector2(-3254.28,1602.92), Vector2(-3323.88,1619.53), Vector2(-3366.06,1617.95), Vector2(-3487.65,1569.42), Vector2(-3512.56,1578.15), Vector2(-3537.22,1605.39), Vector2(-3569.14,1591.05), Vector2(-3594.23,1563.36), Vector2(-3654.6,1556.58), Vector2(-3710.59,1566.12), Vector2(-3736.67,1582.25), Vector2(-3770.38,1564.81), Vector2(-3835.28,1580.76), Vector2(-3955.72,1668.71), Vector2(-3995.58,1722.8), Vector2(-4031.24,1740.27), Vector2(-4089.9,1744.54), Vector2(-4222.99,1859.63), Vector2(-4295.99,1895.09), Vector2(-4319.18,1923.52), Vector2(-4324.37,1946.13), Vector2(-4315.54,2006.88), Vector2(-4286.33,2048.83), Vector2(-4421.55,2183.88), Vector2(-4475.73,2185.86), Vector2(-4483.75,2144.43), Vector2(-4516.53,2124.51), Vector2(-4668.0,2128.12), Vector2(-4697.43,2141.55), Vector2(-4772.14,2142.12), Vector2(-4772.9,1949.03), Vector2(-4783.6,1926.05), Vector2(-4804.8,1912.57), Vector2(-4989.03,1881.45), Vector2(-5056.27,1878.95), Vector2(-5097.29,1891.96), Vector2(-5130.32,1884.21), Vector2(-5225.73,1886.96), Vector2(-5313.93,1861.7), Vector2(-5384.5,1867.88), Vector2(-5417.53,1881.42), Vector2(-5509.0,1956.24), Vector2(-5522.71,1987.38), Vector2(-5523.38,2033.65), Vector2(-5570.7,2049.64), Vector2(-5619.97,2086.16), Vector2(-5688.0,2185.62), Vector2(-5705.12,2264.35), Vector2(-5684.48,2311.25), Vector2(-5728.86,2377.96), Vector2(-5760.09,2449.17), Vector2(-5770.93,2500.16), Vector2(-5825.81,2614.61), Vector2(-5854.48,2636.34), Vector2(-5898.32,2721.45), Vector2(-5944.02,2780.89), Vector2(-5955.12,2814.88), Vector2(-6000.0,2798.48), Vector2(-6000.0,-5500.0)])
static var Y_KARA := PackedVector2Array([Vector2(-2437.58,852.44), Vector2(-2428.66,848.88), Vector2(-2440.55,815.63), Vector2(-2444.86,818.51), Vector2(-2468.32,770.23), Vector2(-2513.66,503.74), Vector2(-2516.87,434.58), Vector2(-2488.98,301.5), Vector2(-2466.2,139.87), Vector2(-2444.48,23.75), Vector2(-2430.7,18.66), Vector2(-2427.99,-19.52), Vector2(-2440.3,-21.52), Vector2(-2440.21,-38.9), Vector2(-2432.55,-39.24), Vector2(-2430.21,-168.24), Vector2(-2454.87,-262.02), Vector2(-2436.77,-384.94), Vector2(-2405.91,-485.16), Vector2(-2393.39,-517.7), Vector2(-2389.72,-515.79), Vector2(-2355.25,-600.12), Vector2(-2349.48,-597.08), Vector2(-2309.76,-678.55), Vector2(-2270.36,-718.86), Vector2(-2274.29,-722.82), Vector2(-2268.42,-732.69), Vector2(-2145.8,-880.34), Vector2(-2137.93,-888.53), Vector2(-2125.36,-877.11), Vector2(-2013.1,-1025.6), Vector2(-1901.2,-1152.18), Vector2(-1879.76,-1183.21), Vector2(-1876.77,-1191.96), Vector2(-1879.05,-1206.1), Vector2(-1850.88,-1263.83), Vector2(-1687.24,-1373.42), Vector2(-1678.11,-1390.22), Vector2(-1675.11,-1440.79), Vector2(-1698.5,-1445.43), Vector2(-1725.96,-1465.31), Vector2(-1713.36,-1532.6), Vector2(-1714.73,-1559.46), Vector2(-1722.69,-1599.8), Vector2(-1714.49,-1627.38), Vector2(-1669.12,-1646.72), Vector2(-1632.09,-1692.52), Vector2(-1628.29,-1691.17), Vector2(-1616.95,-1729.8), Vector2(-1585.42,-1736.03), Vector2(-1580.71,-1743.56), Vector2(-1547.92,-1718.03)])
static var Y_BLAKHERNA := PackedVector2Array([Vector2(-1713.81,-1456.52), Vector2(-1725.96,-1465.31), Vector2(-1713.36,-1532.6), Vector2(-1714.73,-1559.46), Vector2(-1722.69,-1599.8), Vector2(-1714.49,-1627.38), Vector2(-1669.12,-1646.72), Vector2(-1632.09,-1692.52), Vector2(-1628.29,-1691.17), Vector2(-1616.95,-1729.8), Vector2(-1585.42,-1736.03), Vector2(-1580.71,-1743.56), Vector2(-1547.92,-1718.03)])
static var Y_MARMARA := PackedVector2Array([Vector2(-2434.7,851.59), Vector2(-2425.29,883.64), Vector2(-2418.08,883.05), Vector2(-2415.79,885.11), Vector2(-2419.51,906.35), Vector2(-2351.16,887.2), Vector2(-2226.75,817.53), Vector2(-2102.12,707.86), Vector2(-1969.74,549.78), Vector2(-1944.75,494.99), Vector2(-1921.35,463.47), Vector2(-1894.23,438.16), Vector2(-1872.89,427.29), Vector2(-1864.1,411.52), Vector2(-1843.42,392.04), Vector2(-1810.55,374.74), Vector2(-1777.59,373.34), Vector2(-1751.57,387.65), Vector2(-1742.0,379.57), Vector2(-1738.61,379.9), Vector2(-1728.15,400.58), Vector2(-1729.93,411.92), Vector2(-1734.52,416.8), Vector2(-1735.72,435.84), Vector2(-1625.07,427.0), Vector2(-1178.6,409.14), Vector2(-1171.79,386.8), Vector2(-1138.83,344.3), Vector2(-1126.71,337.22), Vector2(-1112.39,334.02), Vector2(-1093.61,321.79), Vector2(-1058.67,315.39), Vector2(-1034.16,317.78), Vector2(-1013.69,332.84), Vector2(-999.26,337.33), Vector2(-983.26,329.22), Vector2(-964.32,327.96), Vector2(-919.56,339.35), Vector2(-905.31,346.43), Vector2(-889.66,347.04), Vector2(-826.48,364.28), Vector2(-815.96,348.48), Vector2(-790.76,332.91), Vector2(-775.31,329.03), Vector2(-754.64,332.15), Vector2(-745.04,330.46), Vector2(-722.8,318.36), Vector2(-697.16,317.41), Vector2(-681.62,321.65), Vector2(-674.59,312.83), Vector2(-665.06,309.5), Vector2(-540.06,309.5), Vector2(-527.18,316.31), Vector2(-524.87,329.09), Vector2(-468.12,335.8), Vector2(-383.88,366.16), Vector2(-300.5,388.61), Vector2(-220.04,390.19), Vector2(-207.33,382.62), Vector2(-190.69,379.38), Vector2(-112.28,383.55), Vector2(-111.0,377.63), Vector2(-102.46,376.25), Vector2(-95.43,362.7), Vector2(-81.37,350.48), Vector2(-13.87,333.26), Vector2(3.23,325.68), Vector2(29.67,308.01), Vector2(51.47,287.63), Vector2(108.66,205.24), Vector2(132.63,183.11), Vector2(198.95,132.72), Vector2(217.19,108.93), Vector2(225.93,91.36), Vector2(249.59,1.35), Vector2(289.13,-97.36), Vector2(293.36,-147.16), Vector2(261.38,-148.78), Vector2(258.91,-151.03), Vector2(263.03,-231.93), Vector2(246.46,-283.27), Vector2(218.76,-421.42)])
static var Y_HALIC := PackedVector2Array([Vector2(218.74,-421.53), Vector2(216.82,-433.36), Vector2(202.01,-437.21), Vector2(175.85,-432.29), Vector2(134.81,-415.4), Vector2(80.69,-386.71), Vector2(36.65,-380.36), Vector2(-73.75,-380.64), Vector2(-116.26,-386.52), Vector2(-141.77,-385.71), Vector2(-171.06,-395.15), Vector2(-195.85,-412.53), Vector2(-304.48,-466.92), Vector2(-347.72,-463.22), Vector2(-400.62,-479.59), Vector2(-462.08,-520.27), Vector2(-477.89,-535.66), Vector2(-526.29,-536.02), Vector2(-555.66,-543.26), Vector2(-588.22,-540.48), Vector2(-610.46,-546.15), Vector2(-630.15,-557.46), Vector2(-653.73,-583.25), Vector2(-664.62,-613.4), Vector2(-715.94,-640.59), Vector2(-753.35,-678.94), Vector2(-768.47,-712.41), Vector2(-772.29,-748.98), Vector2(-769.84,-751.13), Vector2(-735.61,-752.89), Vector2(-733.48,-760.96), Vector2(-737.41,-766.27), Vector2(-750.63,-772.07), Vector2(-772.19,-788.81), Vector2(-808.56,-810.32), Vector2(-822.97,-823.63), Vector2(-853.53,-863.58), Vector2(-882.5,-909.78), Vector2(-895.67,-941.58), Vector2(-897.18,-973.31), Vector2(-929.29,-996.9), Vector2(-968.54,-1037.04), Vector2(-985.55,-1075.93), Vector2(-1007.4,-1076.11), Vector2(-1060.93,-1086.55), Vector2(-1149.13,-1115.75), Vector2(-1168.0,-1133.36), Vector2(-1187.74,-1167.85), Vector2(-1190.12,-1186.11), Vector2(-1181.65,-1209.52), Vector2(-1183.01,-1211.33), Vector2(-1198.93,-1212.76), Vector2(-1238.82,-1227.2), Vector2(-1270.7,-1251.39), Vector2(-1306.85,-1307.06), Vector2(-1310.43,-1354.19), Vector2(-1307.23,-1371.57), Vector2(-1326.16,-1386.7), Vector2(-1337.08,-1415.19), Vector2(-1338.42,-1444.09), Vector2(-1333.48,-1460.5), Vector2(-1335.26,-1475.4), Vector2(-1352.26,-1494.02), Vector2(-1369.68,-1499.96), Vector2(-1399.81,-1517.69), Vector2(-1424.08,-1549.39), Vector2(-1453.04,-1614.64), Vector2(-1455.57,-1632.69), Vector2(-1514.05,-1758.75), Vector2(-1545.51,-1716.25)])
static var Y_GALATA := PackedVector2Array([Vector2(-435.0,-940.0), Vector2(-270.0,-982.5), Vector2(-150.0,-967.5), Vector2(-40.0,-900.0), Vector2(-14.85,-876.17), Vector2(-110.91,-792.63), Vector2(-127.61,-786.65), Vector2(-161.3,-763.4), Vector2(-175.08,-763.47), Vector2(-205.61,-756.45), Vector2(-236.08,-769.1), Vector2(-272.56,-771.95), Vector2(-288.19,-770.12), Vector2(-303.52,-764.3), Vector2(-344.68,-776.68), Vector2(-373.86,-777.14), Vector2(-390.94,-789.08), Vector2(-412.86,-795.52), Vector2(-490.27,-887.03), Vector2(-435.0,-940.0)])
static var Y_MESE := PackedVector2Array([Vector2(-115.0,15.0), Vector2(-240.0,10.0), Vector2(-378.0,5.5), Vector2(-550.0,-45.0), Vector2(-777.0,-105.5), Vector2(-950.0,-260.0)])
static var Y_MESE_K := PackedVector2Array([Vector2(-950.0,-260.0), Vector2(-1075.0,-400.0), Vector2(-1225.0,-575.0), Vector2(-1475.0,-875.0), Vector2(-1823.28,-1282.32)])
static var Y_MESE_G := PackedVector2Array([Vector2(-950.0,-260.0), Vector2(-1125.0,-125.0), Vector2(-1270.0,35.0), Vector2(-1475.0,125.0), Vector2(-1665.0,225.0), Vector2(-2000.0,525.0), Vector2(-2428.66,848.88)])
static var Y_LYKOS := PackedVector2Array([Vector2(-3400.0,-1250.0), Vector2(-2800.0,-850.0), Vector2(-2300.0,-575.0), Vector2(-2100.0,-475.0), Vector2(-1800.0,-300.0), Vector2(-1450.0,-125.0), Vector2(-1175.0,75.0), Vector2(-1125.0,250.0), Vector2(-1115.0,450.0)])
static var Y_ZINCIR := PackedVector2Array([Vector2(-189.69,-408.19), Vector2(-256.97,-769.44)])
static var Y_BOZDOGAN := PackedVector2Array([Vector2(-1230.0,-500.0), Vector2(-800.0,-365.0)])
const YERLER_HAM := [
	["Eğrikapı (Kaligaria?)", "kapi", -3353.5, 2826.5, -2940.0, 2802.0, 2, "kara suru hattına oturtuldu (414 m)"],
	["Edirnekapı", "kapi", -3646.6, 2564.6, -3545.0, 2413.0, 3, "kara suru hattına oturtuldu (182 m)"],
	["Hücum Kapısı / Sulukule", "kapi", -4199.1, 1822.6, -3906.0, 1601.0, 4, "kara suru hattına oturtuldu (367 m)"],
	["Topkapı", "kapi", -4836.7, 889.4, -4621.0, 823.0, 5, "kara suru hattına oturtuldu (226 m)"],
	["Dördüncü Askerî Kapı", "kapi", -4866.0, 357.7, -4789.0, 378.0, 6, "kara suru hattına oturtuldu (80 m)"],
	["Mevlanakapı", "kapi", -4963.3, -499.3, -4873.0, -512.0, 7, "kara suru hattına oturtuldu (91 m)"],
	["Üçüncü Askerî Kapı", "kapi", -5027.4, -839.0, -4999.0, -845.0, 8, "kara suru hattına oturtuldu (29 m)"],
	["Silivrikapı", "kapi", -4968.5, -1352.9, -5251.0, -1401.0, 9, "kara suru hattına oturtuldu (287 m)"],
	["İkinci Askerî Kapı", "kapi", -4952.6, -1446.9, -5335.0, -1512.0, 10, "kara suru hattına oturtuldu (388 m)"],
	["Belgratkapı", "kapi", -4946.8, -1480.5, -5461.0, -1568.0, 11, "kara suru hattına oturtuldu (522 m)"],
	["Yedikule Kapısı", "kapi", -4861.2, -1686.8, -4747.0, -1646.0, 12, "kara suru hattına oturtuldu (121 m)"],
	["Altınkapı", "kapi", -4857.3, -1697.8, -4797.0, -1679.0, 13, "kara suru hattına oturtuldu (63 m)"],
	["Tabakkapı", "kapi", -4857.3, -1697.8, -4663.0, -1735.0, 14, "kara suru hattına oturtuldu (198 m)"],
	["Kerkoporta", "kapi", -3350.2, 2881.6, -3150.0, 2880.0, 15, "kara suru hattına oturtuldu (200 m)"],
	["Mesoteikhion", "diger", -4495.0, 1101.0, -4495.0, 1101.0, 16, ""],
	["Lykos vadisi", "diger", -4201.0, 934.0, -4201.0, 934.0, 17, ""],
	["Blakhernai Sarayı", "saray", -3402.0, 3436.0, -3402.0, 3436.0, 18, ""],
	["Anemas Zindanları", "diger", -3360.0, 3547.0, -3360.0, 3547.0, 19, ""],
	["Tekfur Sarayı", "saray", -3612.0, 2880.0, -3612.0, 2880.0, 20, ""],
	["Balat Kapısı", "kapi", -2592.3, 2580.8, -2730.0, 2491.0, 21, "Haliç suru hattına oturtuldu (164 m)"],
	["Fener Kapısı", "kapi", -2348.0, 2287.6, -2478.0, 2213.0, 22, "Haliç suru hattına oturtuldu (150 m)"],
	["Petrion Kapısı", "kapi", -2324.3, 2255.6, -2520.0, 2046.0, 23, "Haliç suru hattına oturtuldu (287 m)"],
	["Yeni Ayakapı", "kapi", -2121.9, 2173.1, -2226.0, 1768.0, 24, "Haliç suru hattına oturtuldu (418 m)"],
	["Ayakapı", "kapi", -1748.3, 1793.0, -2142.0, 1546.0, 25, "Haliç suru hattına oturtuldu (465 m)"],
	["Odun Kapı", "kapi", -1497.8, 1348.6, -1638.0, 1212.0, 26, "Haliç suru hattına oturtuldu (196 m)"],
	["Zindan Kapı", "kapi", -1220.9, 1092.3, -1260.0, 990.0, 27, "Haliç suru hattına oturtuldu (110 m)"],
	["Cibali Kapısı", "kapi", -1765.0, 1819.6, -2184.0, 1601.0, 28, "Haliç suru hattına oturtuldu (473 m)"],
	["Unkapanı Perama", "kapi", -1761.2, 1813.5, -2100.0, 1601.0, 29, "Haliç suru hattına oturtuldu (400 m)"],
	["Hikanatissa", "kapi", -1009.0, 1071.7, -1008.0, 1212.0, 30, "Haliç suru hattına oturtuldu (140 m)"],
	["Neorion (Horaia)", "kapi", -768.7, 949.1, -756.0, 990.0, 31, "Haliç suru hattına oturtuldu (43 m)"],
	["Eugenios Kapısı", "kapi", -436.2, 847.4, -504.0, 712.0, 32, "Haliç suru hattına oturtuldu (151 m)"],
	["Eugenios Kulesi (zincir ucu)", "kule", -336.0, 878.0, -336.0, 878.0, 33, ""],
	["Galata Kastellion (zincir ucu)", "kule", -504.0, 1434.0, -504.0, 1434.0, 34, ""],
	["Zincir (Haliç ağzı)", "diger", -420.0, 1156.0, -420.0, 1156.0, 35, ""],
	["Doğu Kapısı (Ag. Barbara)", "kapi", 518.2, 300.9, 336.0, 211.0, 36, "Marmara suru hattına oturtuldu (203 m)"],
	["Değirmenkapı", "kapi", 461.8, -144.9, 588.0, -178.0, 37, "Marmara suru hattına oturtuldu (130 m)"],
	["Demirkapı", "kapi", 346.7, -304.3, 462.0, -456.0, 38, "Marmara suru hattına oturtuldu (191 m)"],
	["Balıkhane Kapısı", "kapi", 194.7, -443.1, 294.0, -512.0, 39, "Marmara suru hattına oturtuldu (121 m)"],
	["Ahırkapı", "kapi", -15.2, -661.0, 42.0, -790.0, 40, "Marmara suru hattına oturtuldu (141 m)"],
	["Aslan (Boukoleon) Kapısı", "kapi", -224.6, -767.1, -210.0, -1123.0, 41, "Marmara suru hattına oturtuldu (356 m)"],
	["Demir Kapı (Sophiae)", "kapi", -440.1, -780.4, -336.0, -1457.0, 42, "Marmara suru hattına oturtuldu (685 m)"],
	["Kontoskalion Kapısı", "kapi", -601.0, -777.2, -630.0, -1846.0, 43, "Marmara suru hattına oturtuldu (1069 m)"],
	["Yenikapı", "kapi", -2357.2, -818.3, -1932.0, -2291.0, 44, "Marmara suru hattına oturtuldu (1533 m)"],
	["Davutpaşa Kapısı", "kapi", -2845.7, -837.8, -2772.0, -2680.0, 45, "Marmara suru hattına oturtuldu (1844 m)"],
	["Psamatya Kapısı", "kapi", -4272.6, -1475.9, -3066.0, -2847.0, 46, "Marmara suru hattına oturtuldu (1826 m)"],
	["Narlıkapı", "kapi", -3075.1, -847.0, -3024.0, -2124.0, 47, "Marmara suru hattına oturtuldu (1278 m)"],
	["Ayasofya", "kilise", 0.0, -1.0, 0.0, -1.0, 48, ""],
	["Augustaion", "forum", -42.0, 44.0, -42.0, 44.0, 49, ""],
	["Iustinianus Sütunu", "sutun", -42.0, 44.0, -42.0, 44.0, 50, ""],
	["Hipodrom", "diger", -378.0, -289.0, -378.0, -289.0, 51, ""],
	["Büyük Saray", "saray", -42.0, -512.0, -42.0, -512.0, 52, ""],
	["Bukoleon Sarayı", "saray", -84.0, -956.0, -84.0, -956.0, 53, ""],
	["Konstantin Forumu", "forum", -756.0, -11.0, -756.0, -11.0, 54, ""],
	["Theodosius (Tauri) Forumu", "forum", -1554.0, 211.0, -1554.0, 211.0, 55, ""],
	["Arkadius Sütunu", "sutun", -3444.0, -956.0, -3444.0, -956.0, 56, ""],
	["Bozdoğan Kemeri", "diger", -1932.0, 878.0, -1932.0, 878.0, 57, ""],
	["Havariyun Kilisesi", "kilise", -2394.0, 1156.0, -2394.0, 1156.0, 58, ""],
	["Pantokrator Manastırı", "manastir", -2016.0, 1212.0, -2016.0, 1212.0, 59, ""],
	["Khora (Kariye)", "kilise", -3444.0, 2491.0, -3444.0, 2491.0, 60, ""],
	["Pammakaristos", "kilise", -2730.0, 2213.0, -2730.0, 2213.0, 61, ""],
	["Studios (Imrahor)", "manastir", -4495.0, -1790.0, -4495.0, -1790.0, 62, ""],
	["Peribleptos", "manastir", -2814.0, -2847.0, -2814.0, -2847.0, 63, ""],
	["Lips", "manastir", -2604.0, 878.0, -2604.0, 878.0, 64, ""],
	["Myrelaion", "kilise", -1890.0, -400.0, -1890.0, -400.0, 65, ""],
	["Venedik mahallesi", "mahalle", -1008.0, 1156.0, -1008.0, 1156.0, 66, ""],
	["Ceneviz mahallesi (eski Pera/Galata)", "mahalle", -504.0, 2046.0, -504.0, 2046.0, 67, ""],
	["Christea Turris", "kule", -487.0, 1890.0, -487.0, 1890.0, 68, ""],
	["Yahudi mahallesi (Vlanga/Haliç)", "mahalle", -1344.0, 878.0, -1344.0, 878.0, 69, ""],
	["Petra / Phanar", "mahalle", -2478.0, 2213.0, -2478.0, 2213.0, 70, ""],
	["Kontoskalion Limanı", "liman", -924.0, -1790.0, -924.0, -1790.0, 71, ""],
	["Eleutherios Limanı (dolmuş)", "liman", -2352.0, -1568.0, -2352.0, -1568.0, 72, ""],
	["Neorion Limanı", "liman", -756.0, 990.0, -756.0, 990.0, 73, ""],
	["Prosphorion Limanı", "liman", -336.0, 990.0, -336.0, 990.0, 74, ""],
	["Osmanlı Ordugâhı - Sultan'ın otağı", "ordugah", -4789.0, 1101.0, -4789.0, 1101.0, 75, ""],
	["Karaca Paşa kanadı", "ordugah", -4831.0, 1824.0, -4831.0, 1824.0, 76, ""],
	["İshak Paşa kanadı", "ordugah", -5461.0, -400.0, -5461.0, -400.0, 77, ""],
	["Zağanos Paşa kolu", "ordugah", 0.0, 2380.0, 0.0, 2380.0, 78, ""],
	["Çifte Sütunlar (Diplokionion)", "ordugah", 2352.0, 3825.0, 2352.0, 3825.0, 79, ""],
	["Şahi topu bataryası (Topkapı karşısı)", "batarya", -5125.0, 878.0, -5125.0, 878.0, 80, ""],
	["Rumeli Hisarı", "diger", 6385.0, 8496.0, 6385.0, 8496.0, 81, ""],
	["Anadolu Hisarı", "diger", 7141.0, 8496.0, 7141.0, 8496.0, 82, ""],
	["Haliç'e gemi yürütme inişi (Kasımpaşa)", "iskele", -1008.0, 2380.0, -1008.0, 2380.0, 83, ""],
	["Yüzer köprü (Haliç, Cibali-Kasımpaşa)", "kopru", -1638.0, 1768.0, -1638.0, 1768.0, 84, ""],
]
