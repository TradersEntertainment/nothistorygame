class_name IstGeo
extends RefCounted
## İstanbul v2 coğrafyası (docs/_ajan/gorev/_ist2_ortak.md, DONDURULMUŞ ARAYÜZ).
## Gerçek koordinat: Ayasofya kubbesi (0,0), doğu e, kuzey n (metre). Dünya: x = e × S, z = −n × S, y = yükseklik × S.
## Kıyı: OpenStreetMap ilçe sınırları (Fatih, Beyoğlu, Üsküdar, Kadıköy, Eyüpsultan, Beşiktaş, …; Nominatim) bugünkü
## kıyıdır; 1453 kıyısı için dolgular geri alındı (kıyı boyu 60 m, Marmara 100 m, Eminönü 190 m, Harem/Haydarpaşa
## 220 m, Yenikapı–Yedikule elle çizilen sur hattı). Yükseklik: kıyıya uzaklık + yedi tepe, Lykos vadisi, Galata/Pera,
## Çamlıca (kestirim). Izgara verisi: assets/ist2/arazi_h.res (RF) ve arazi_b.res (L8), 10 m dünya hücresi.
## Üretici: tests/_ist/geo_veri.py (Python) + tests/_ist/geo_veri.gd (Godot dönüştürücü).

## TEK ölçek sabiti (0,25–0,5 arası değiştirilebilir; bütün tablolar gerçek koordinatta tutulur ve S ile türer).
const S := 0.35
const LAT0 := 41.0086
const LON0 := 28.9802
const KY := 111132.0                       # m / derece enlem
const KX := 84006.1                        # m / derece boylam (41,0086°)
## Arazi ızgarası GERÇEK koordinatta: (i, j) hücresi e = GE0 + i × GST, n = GN0 − j × GST; değerler VERI_S ölçeğinde
## saklı yükseklik (gerçek yükseklik × VERI_S). Dünya karşılıkları (X0, Z0, ST) S'den türer.
const GE0 := -12000.0
const GN0 := 11000.0
const GST := 20.0
const VERI_S := 0.5
const NX := 1201
const NZ := 1001
## Dünya ızgarası (S'den türer; dunya.gd ve öbür dosyalar okur)
static var X0 := GE0 * S
static var Z0 := -GN0 * S
static var ST := GST * S
const _HK := S / VERI_S                    # saklı yükseklik → dünya yüksekliği
## Bölge kodları (arazi_b)
const B_DENIZ := 0
const B_YARIMADA := 1
const B_GALATA := 2
const B_TRAKYA := 3
const B_ANADOLU := 4

## gerçek (e, n) çoklu nokta → dünya (x, z)
static func _wl(r: PackedVector2Array) -> PackedVector2Array:
	var o := PackedVector2Array()
	o.resize(r.size())
	for i in r.size():
		o[i] = Vector2(r[i].x * S, -r[i].y * S)
	return o

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
	var yv := a + (b - a) * tz                     # saklı (VERI_S) ölçek
	if kiyi_yumusat and absf(yv) < KIYI_YV:
		yv = _kiyi_duzelt(x / S, -z / S, yv)
	return yv * _HK

## Kıyı yumuşatma: ızgara verisi kıyıyı 20 m'lik raster maskeden aldığı için kıyı çizgisi basamaklıydı. Kıyı şeridinde
## (gerçek ≤ KIYI_BANT m) yükseklik, kıyı çokgenine (yarımada, Trakya, Anadolu; yalnız denize bakan kenarlar) işaretli
## uzaklıkla yeniden kurulur: kıyı çizgisi çokgeni izler (S'den bağımsız, gerçek metre).
## false: kıyı yumuşatması kapalı (yalnız ÖNCE/SONRA sınaması için; gezi kiyi=0)
static var kiyi_yumusat := true
const KIYI_YV := 12.0                       # saklı yükseklik |y| bundan küçükse kıyı adayı
const KIYI_BANT := 70.0                    # gerçek m
const KIYI_IC := 40.0                      # bu uzaklığın içinde tamamen çokgen profili
const KIYI_HUCRE := 80.0
static var _kseg := PackedVector2Array()   # a, b çiftleri (gerçek e,n)
static var _kyon := PackedFloat32Array()   # kara tarafı işareti (+1: segment yönünün solu kara)
static var _kizg := {}
static var _kiyi_hazir := false

static func _kiyi_kur() -> void:
	_kiyi_hazir = true
	for poly in [R_YARIMADA, R_TRAKYA, R_ANADOLU]:
		var n: int = poly.size()
		for i in n:
			var a: Vector2 = poly[i]
			var b: Vector2 = poly[(i + 1) % n]
			var L := a.distance_to(b)
			if L < 0.5 or L > 2000.0:
				continue
			var m := (a + b) * 0.5
			var nl := Vector2(-(b - a).y, (b - a).x) / L        # sol normal
			var hl := _veri(m + nl * 60.0)
			var hr := _veri(m - nl * 60.0)
			if (hl < 0.0) == (hr < 0.0):
				continue                                     # denize bakmayan kenar (kara suru, veri sınırı)
			var idx := _kyon.size()
			_kseg.append(a); _kseg.append(b)
			_kyon.append(1.0 if hl >= 0.0 else -1.0)
			var lo := Vector2(minf(a.x, b.x), minf(a.y, b.y)) - Vector2.ONE * KIYI_BANT
			var hi := Vector2(maxf(a.x, b.x), maxf(a.y, b.y)) + Vector2.ONE * KIYI_BANT
			for ci in range(floori(lo.x / KIYI_HUCRE), floori(hi.x / KIYI_HUCRE) + 1):
				for cj in range(floori(lo.y / KIYI_HUCRE), floori(hi.y / KIYI_HUCRE) + 1):
					var key := Vector2i(ci, cj)
					if not _kizg.has(key):
						_kizg[key] = PackedInt32Array()
					var l: PackedInt32Array = _kizg[key]
					l.append(idx)
					_kizg[key] = l

## Ham ızgara değeri (saklı ölçek, gerçek e,n; düzeltmesiz)
static func _veri(r: Vector2) -> float:
	var fx := clampf((r.x - GE0) / GST, 0.0, NX - 1.001)
	var fz := clampf((GN0 - r.y) / GST, 0.0, NZ - 1.001)
	var i := int(fx)
	var j := int(fz)
	var k := j * NX + i
	var a := _h[k] + (_h[k + 1] - _h[k]) * (fx - i)
	var b := _h[k + NX] + (_h[k + NX + 1] - _h[k + NX]) * (fx - i)
	return a + (b - a) * (fz - j)

static func _kiyi_duzelt(e: float, n: float, yv: float) -> float:
	if not _kiyi_hazir:
		_kiyi_kur()
	var l = _kizg.get(Vector2i(floori(e / KIYI_HUCRE), floori(n / KIYI_HUCRE)))
	if l == null:
		return yv
	var p := Vector2(e, n)
	var best := INF
	var yon := 1.0
	for idx in (l as PackedInt32Array):
		var a := _kseg[idx * 2]
		var b := _kseg[idx * 2 + 1]
		var q := Geometry2D.get_closest_point_to_segment(p, a, b)
		var d := p.distance_squared_to(q)
		if d < best:
			best = d
			var ab := b - a
			var cr := ab.x * (p.y - a.y) - ab.y * (p.x - a.x)    # >0: solda
			yon = _kyon[idx] * (1.0 if cr >= 0.0 else -1.0)
	var d := sqrt(best)
	if d >= KIYI_BANT:
		return yv
	# hedef profil (gerçek m; SÜREKLİ: sıfır çizgisi ağ hücresine değil kıyı çokgenine düşsün): kıyıdan 5 m içeri %30 dik
	# (dalga ±0,25 m dünyanın üstüne çabuk çıksın), ötesi kara %12 / deniz %8
	var hedef := minf(d, 5.0) * 0.3 + maxf(d - 5.0, 0.0) * (0.12 if yon > 0.0 else 0.08)
	hedef *= yon
	hedef *= VERI_S
	var wt := 1.0 - smoothstep(KIYI_IC, KIYI_BANT, d)
	return lerpf(yv, hedef, wt)

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

## Mahalle (ikinci tur, kalite notu 0 ve 0b): surların içi baştan sona yerleşik doku; bostan/bağ/meyve bahçesi/harabe/
## manastır adaları dokunun İÇİNDE (≤ ~120 × 120 m dünya); açık sarnıç bostanları ("sarnic"), Hipodrom ("hipodrom"),
## Büyük Saray harabesi ("saray") ayrı tür. Galata surlarına kadar dolu. Sur dışı: "ordugah" / "kir" (sur önü hendek
## ve ova); karşı kıyılar: "koy" / "bag" / "orman" / "kir". Bütün eşikler GERÇEK metre (S'den bağımsız).
## {"ad", "tur": "carsi|sik|seyrek|bostan|harabe|liman|sur_dibi|kir|sarnic|hipodrom|saray|ordugah|koy|bag|orman",
##  "yogunluk": 0..1, "alt": "" | "bag|meyve|bostan|manastir|harabe|mezarlik|cayir|tarla|cadir|hendek"}
static func mahalle(x: float, z: float) -> Dictionary:
	var p := Vector2(x, z)
	var r := real(x, z)
	if su(x, z):
		return _m("deniz", "kir", 0.0)
	if galata_ici(x, z):
		if h_ham(x, z) < 8.0 * S:
			return _m("Galata iskelesi", "liman", 0.85)
		if cizgi_uzak(p, Y_GALATA) / S < 63.0:
			return _m("Galata sur dibi", "sur_dibi", 0.8)
		return _m("Galata (Pera)", "carsi" if r.distance_to(Vector2(-560, 1700)) < 260.0 else "sik", 0.9)
	if not sehir_ici(x, z):
		return _mahalle_dis(p, r)
	for m in MAH_OZEL:
		if r.distance_to(m[1]) < m[2]:
			return _m(m[0], m[3], m[4], m[5])
	var dr := 1.0 / S                                   # dünya metresi → gerçek metre
	var d_kara := cizgi_uzak(p, Y_KARA) * dr
	var d_mese := minf(cizgi_uzak(p, Y_MESE), minf(cizgi_uzak(p, Y_MESE_K), cizgi_uzak(p, Y_MESE_G))) * dr
	var d_halic := cizgi_uzak(p, Y_HALIC) * dr
	var d_marm := cizgi_uzak(p, Y_MARMARA) * dr
	var d_ay := r.length()
	# Mese boyu çarşı (dükkânlı sıra evler)
	if d_mese < 70.0:
		return _m("Mese çarşısı", "carsi", 0.95)
	# Haliç iskeleleri (Latin mahalleleri dahil)
	if d_halic < 110.0 and r.x > -3100.0:
		return _m(_ad(r), "liman", 0.9)
	# kara surlarının iç yüzüne yaslı sıra evler (savunma yolu 4–6 m sokak dokusunda bırakılır)
	if d_kara < 110.0:
		return _m("sur dibi (" + _ad(r) + ")", "sur_dibi", 0.75)
	if d_marm < 70.0:
		return _m("deniz suru dibi (" + _ad(r) + ")", "sur_dibi", 0.7)
	# dokunun içindeki adalar (bostan, bağ, meyve bahçesi, harabe, manastır)
	var ada := _ada(r, d_mese, d_kara)
	if not ada.is_empty():
		return ada
	# yoğunluk: çekirdek (Ayasofya–Mese–Haliç) sık; batiya doğru orta yoğunlukta sıra ev + avlu/bahçe, ama boş değil
	var yog := clampf(0.92 - maxf(d_ay - 900.0, 0.0) / 6500.0, 0.6, 0.92)
	if d_halic < 300.0:
		yog = maxf(yog, 0.85)
	if d_marm < 220.0:
		yog = maxf(yog, 0.7)
	if d_ay < 650.0:
		return _m("Ayasofya çevresi", "sik", 0.88)
	return _m(_ad(r), "sik", yog)

static func _m(ad: String, tur: String, yog: float, alt := "") -> Dictionary:
	return {"ad": ad, "tur": tur, "yogunluk": yog, "alt": alt}

## Ada ızgarası: gerçek ADA_HUCRE m hücreler; seçilen hücrenin içinde yarıçapı ≤ 125 m gerçek (S = 0,35'te ≤ 88 m çap;
## komşu adalar birleşmez: merkez kayması ≤ %20)
## bir ada. Batıda (kara surlarına, Lykos'a yakın) daha sık; Mese ve çarşı üstüne düşmez.
const ADA_HUCRE := 420.0
static func _ada(r: Vector2, d_mese: float, d_kara: float) -> Dictionary:
	if d_mese < 140.0:
		return {}
	var ci := floori(r.x / ADA_HUCRE)
	var cj := floori(r.y / ADA_HUCRE)
	var lykos := cizgi_uzak(w2(r.x, r.y), Y_LYKOS) / S
	for dj in [-1, 0, 1]:
		for di in [-1, 0, 1]:
			var hx: int = ci + di
			var hz: int = cj + dj
			var hs := _hash(hx, hz)
			var mx: float = (hx + 0.5 + (_hash(hx + 71, hz - 13) - 0.5) * 0.4) * ADA_HUCRE
			var mz: float = (hz + 0.5 + (_hash(hx - 29, hz + 57) - 0.5) * 0.4) * ADA_HUCRE
			var c := Vector2(mx, mz)
			var bati := clampf((-c.x - 1500.0) / 3000.0, 0.0, 1.0)
			var olas := 0.1 + 0.32 * bati + (0.25 if lykos < 300.0 else 0.0)
			if hs > olas:
				continue
			var rad := 75.0 + 50.0 * _hash(hx + 5, hz + 9)
			# ada biçimi: hafif yamuk (eliptik) — dikdörtgen bostan kenarı sokakla hizalanır
			var q := (r - c).rotated(_hash(hx + 3, hz + 3) * PI)
			if Vector2(q.x / rad, q.y / (rad * 0.75)).length() > 1.0:
				continue
			var t := _hash(hx * 3 + 1, hz * 7 + 2)
			if lykos < 300.0:
				return _m("Lykos bostanları", "bostan", 0.12, "bostan")
			if t < 0.3:
				return _m(_ad(r) + " bostanı", "bostan", 0.12, "bostan")
			if t < 0.5:
				return _m(_ad(r) + " bağı", "bostan", 0.1, "bag")
			if t < 0.68:
				return _m(_ad(r) + " meyve bahçesi", "bostan", 0.12, "meyve")
			if t < 0.84:
				return _m(_ad(r) + " harabeleri", "harabe", 0.15, "harabe")
			return _m(_ad(r) + " manastırı", "seyrek", 0.35, "manastir")
	return {}

static func _hash(i: int, j: int) -> float:
	var hsh := (i * 73856093) ^ (j * 19349663) ^ 0x5bd1e995
	hsh = (hsh ^ (hsh >> 13)) * 1274126177
	hsh = hsh ^ (hsh >> 16)
	return float(hsh & 0xffff) / 65535.0

## Sur dışı ve karşı kıyılar (gerçek metre)
static func _mahalle_dis(p: Vector2, r: Vector2) -> Dictionary:
	var b := bolge(p.x, p.y)
	var g := _gurultu(r.x, r.y)
	for k in KOYLER:
		if r.distance_to(k[1]) < k[2]:
			return _m(k[0], "koy", k[3])
	if b == B_ANADOLU:
		var dk := r.distance_to(Vector2(2900, 1900))
		if dk < 2600.0 or r.y < 1000.0:
			return _m("Üsküdar bağları" if r.y > 0.0 else "Kadıköy bağları", "bag" if g < 0.62 else "kir", 0.1,
				"bag" if g < 0.62 else "tarla")
		return _m("Anadolu tepeleri", "orman" if g > 0.4 else "kir", 0.08, "" if g > 0.4 else "tarla")
	var d_kara := cizgi_uzak(p, Y_KARA) / S
	var trakya_bati := r.x < -4300.0 and r.y < 4200.0
	if trakya_bati and d_kara < 150.0:
		return _m("sur önü (hendek ve ova)", "kir", 0.0, "hendek")
	if trakya_bati and d_kara < 2600.0:
		# Osmanlı ordugâhı: otağdan Marmara'ya ve Haliç'e çadır denizi
		var yo := clampf(1.0 - (d_kara - 300.0) / 2300.0, 0.15, 0.9)
		return _m("Osmanlı ordugâhı", "ordugah", yo, "cadir")
	if r.distance_to(Vector2(-3880, 5160)) < 2000.0:
		return _m("Eyüp bağları", "bag", 0.1, "bag")
	# Galata'nın arkası: bağ ve bahçe; Pera sırtının ötesi ormanlık tepeler ve tarlalar
	if r.x > -3000.0 and r.y > 1500.0 and r.y < 5200.0:
		if g < 0.6:
			return _m("Pera bağları", "bag", 0.1, "bag")
		return _m("Pera tarlaları", "kir", 0.05, "tarla")
	if g > 0.55:
		return _m("Trakya korulukları", "orman", 0.05)
	return _m("Trakya tarlaları", "kir", 0.03, "tarla" if g < 0.35 else "cayir")

## Sur dışı köyler (gerçek e, n; yarıçap gerçek m; yoğunluk)
const KOYLER := [
	["Üsküdar (Skutari)", Vector2(2950, 1900), 520.0, 0.45], ["Khalkedon (Kadıköy)", Vector2(3760, -2070), 650.0, 0.45],
	["Kuzguncuk", Vector2(4180, 2930), 260.0, 0.35], ["Beylerbeyi", Vector2(5360, 3930), 280.0, 0.3],
	["Kandilli", Vector2(6600, 7800), 300.0, 0.3], ["Diplokionion (Beşiktaş)", Vector2(2180, 3710), 380.0, 0.35],
	["Ortaköy", Vector2(3850, 4270), 300.0, 0.3], ["Arnavutköy", Vector2(5230, 6490), 300.0, 0.3],
	["Kosmidion (Eyüp)", Vector2(-3880, 5160), 450.0, 0.35], ["Kasımpaşa", Vector2(-1030, 2820), 260.0, 0.3],
	["Hasköy", Vector2(-2540, 3490), 300.0, 0.3], ["Haydarpaşa", Vector2(3300, -500), 250.0, 0.25],
]

## Boş kare sayımı (ISTBOS) için: 40 m'lik dünya karesinin kimliği ve bölgesi
static func kare40(x: float, z: float) -> Vector2i:
	return Vector2i(floori(x / 40.0), floori(z / 40.0))

## "sehir_ici" | "galata" | "sur_disi_600" (kara suruna 600 m dünya kuşağı) | "karsi_kiyi" | "deniz" | "uzak"
static func bos_bolge(x: float, z: float) -> String:
	if su(x, z):
		return "deniz"
	if sehir_ici(x, z):
		return "sehir_ici"
	if galata_ici(x, z):
		return "galata"
	var b := bolge(x, z)
	if b == B_TRAKYA and cizgi_uzak(Vector2(x, z), Y_KARA) < 600.0 and real(x, z).x < -4300.0:
		return "sur_disi_600"
	if (b == B_ANADOLU or b == B_TRAKYA) and Vector2(x, z).length() < 3000.0:
		return "karsi_kiyi"
	return "uzak"

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
## Özel alanlar (gerçek e,n; yarıçap gerçek m): ad, merkez, yarıçap, tür, yoğunluk, alt
const MAH_OZEL := [
	["Hipodrom", Vector2(-378, -289), 150.0, "hipodrom", 0.0, ""],
	["Büyük Saray harabeleri", Vector2(-120, -520), 300.0, "saray", 0.05, "harabe"],
	["Bukoleon", Vector2(-90, -830), 110.0, "saray", 0.05, "harabe"],
	["Aetios sarnıcı (bostan)", Vector2(-3335, 1880), 125.0, "sarnic", 0.0, "bostan"],
	["Aspar sarnıcı (bostan)", Vector2(-2705, 1930), 105.0, "sarnic", 0.0, "bostan"],
	["Mokios sarnıcı (bostan)", Vector2(-3670, -70), 120.0, "sarnic", 0.0, "bostan"],
	["Langa bostanı (dolmuş Eleutherios limanı)", Vector2(-2250, -560), 165.0, "bostan", 0.12, "bostan"],
	["Kontoskalion limanı", Vector2(-1200, -700), 110.0, "liman", 0.8, ""],
	["Mangana / Akropolis bahçeleri", Vector2(380, 420), 160.0, "seyrek", 0.4, "meyve"],
	["Havariyun nekropolü", Vector2(-2450, 1150), 90.0, "seyrek", 0.3, "mezarlik"],
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

static var R_YARIMADA := PackedVector2Array([Vector2(-4837.3,-1772), Vector2(-4854.9,-1773.7), Vector2(-4875.2,-1704.9), Vector2(-4857.3,-1697.8), Vector2(-4881.1,-1631.3), Vector2(-4889.7,-1637), Vector2(-4936.6,-1540.5), Vector2(-5027.3,-1007.5), Vector2(-5033.7,-869.2), Vector2(-4978,-603), Vector2(-4945.7,-396.6), Vector2(-4932.4,-279.7), Vector2(-4889,-47.5), Vector2(-4861.4,-37.3), Vector2(-4856,39), Vector2(-4880.6,43), Vector2(-4880.4,77.8), Vector2(-4865.1,78.5), Vector2(-4860.4,336.5), Vector2(-4897.2,460.8), Vector2(-4909.7,524), Vector2(-4873.5,769.9), Vector2(-4854.2,835.5), Vector2(-4786.8,1035.4), Vector2(-4779.4,1031.6), Vector2(-4710.5,1200.2), Vector2(-4699,1194.2), Vector2(-4619.5,1357.1), Vector2(-4540.7,1437.7), Vector2(-4548.6,1445.6), Vector2(-4536.8,1465.4), Vector2(-4275.9,1777.1), Vector2(-4250.7,1754.2), Vector2(-4224.8,1794.1), Vector2(-4067,1992.2), Vector2(-4026.2,2051.2), Vector2(-3802.4,2304.4), Vector2(-3759.5,2366.4), Vector2(-3753.5,2383.9), Vector2(-3758.1,2412.2), Vector2(-3701.8,2527.7), Vector2(-3374.5,2746.8), Vector2(-3356.2,2780.4), Vector2(-3350.2,2881.6), Vector2(-3397,2890.9), Vector2(-3451.9,2930.6), Vector2(-3426.7,3065.2), Vector2(-3429.5,3118.9), Vector2(-3445.4,3199.6), Vector2(-3429,3254.8), Vector2(-3364.8,3286.3), Vector2(-3338.2,3293.4), Vector2(-3264.2,3385), Vector2(-3256.6,3382.3), Vector2(-3233.9,3459.6), Vector2(-3170.8,3472.1), Vector2(-3161.4,3487.1), Vector2(-3095.8,3436.1), Vector2(-3030.2,3524.8), Vector2(-3023.7,3522.4), Vector2(-2905.3,3267.1), Vector2(-2900.4,3231.2), Vector2(-2880.8,3195.7), Vector2(-2843,3101.8), Vector2(-2795.6,3039.9), Vector2(-2736.9,3005.4), Vector2(-2701.1,2993.2), Vector2(-2664.8,2953.4), Vector2(-2660.9,2920.5), Vector2(-2671.4,2879.3), Vector2(-2665.9,2820.6), Vector2(-2645.6,2774.4), Vector2(-2629.1,2757.9), Vector2(-2607.9,2745.6), Vector2(-2614.9,2708.3), Vector2(-2607.9,2615.8), Vector2(-2596.3,2592), Vector2(-2540.3,2511.3), Vector2(-2521.8,2491.6), Vector2(-2475,2459.8), Vector2(-2396.3,2431.3), Vector2(-2362.8,2428.4), Vector2(-2356.5,2420), Vector2(-2369,2397.1), Vector2(-2374.3,2371.8), Vector2(-2369.8,2337.6), Vector2(-2331.1,2270.2), Vector2(-2295.2,2236.7), Vector2(-2120.7,2179), Vector2(-2014.2,2158.2), Vector2(-1967.2,2157.8), Vector2(-1957.7,2126.5), Vector2(-1932.4,2077.9), Vector2(-1854.6,1998.3), Vector2(-1788.5,1949.8), Vector2(-1785.5,1884.5), Vector2(-1759.7,1822.3), Vector2(-1702,1730.4), Vector2(-1641.2,1650.9), Vector2(-1613.5,1625.4), Vector2(-1541,1582.6), Vector2(-1498,1549.2), Vector2(-1470.9,1537.4), Vector2(-1460.4,1523.2), Vector2(-1466.5,1500), Vector2(-1534.5,1500), Vector2(-1538.8,1496.3), Vector2(-1531.1,1426.1), Vector2(-1501.7,1361.3), Vector2(-1467.6,1320.5), Vector2(-1428.5,1286.2), Vector2(-1383.7,1258.8), Vector2(-1324.4,1231), Vector2(-1312.5,1189.6), Vector2(-1295.7,1159.2), Vector2(-1275.6,1135.4), Vector2(-1250.7,1115.4), Vector2(-1216.5,1097), Vector2(-1175.6,1086.9), Vector2(-1142.8,1086.6), Vector2(-1110.9,1092.6), Vector2(-1051.8,1078), Vector2(-953.3,1077.3), Vector2(-920.9,1045.5), Vector2(-798.9,964.7), Vector2(-694.8,932.4), Vector2(-653,932.1), Vector2(-607.8,940), Vector2(-573.2,926.5), Vector2(-517.4,891.8), Vector2(-476.9,876.3), Vector2(-447.7,856.9), Vector2(-388.6,830.2), Vector2(-339.7,795.8), Vector2(-282.7,777.4), Vector2(-232.2,779.1), Vector2(-147.4,767.3), Vector2(23.8,769.5), Vector2(57.4,766), Vector2(128.5,772.1), Vector2(174,784.7), Vector2(267.1,836.2), Vector2(349.9,870.3), Vector2(404.2,880.6), Vector2(438.9,871.5), Vector2(498.8,567.7), Vector2(532.1,464.6), Vector2(534,429.9), Vector2(523.7,303.5), Vector2(527.9,300), Vector2(593.2,300), Vector2(584.2,193.3), Vector2(504.7,-4.9), Vector2(457.5,-184.8), Vector2(439.5,-221.1), Vector2(402.2,-269.7), Vector2(268.9,-371), Vector2(221.8,-414.4), Vector2(107.5,-579.2), Vector2(63.1,-620.7), Vector2(9.4,-656.6), Vector2(-25.8,-672.2), Vector2(-138,-697.2), Vector2(-159.7,-706.1), Vector2(-186.1,-729.1), Vector2(-201.1,-758.2), Vector2(-217.8,-759.5), Vector2(-219.1,-773.4), Vector2(-381,-764.8), Vector2(-412.5,-770.8), Vector2(-438.5,-786.4), Vector2(-576.3,-780.6), Vector2(-601.9,-783.2), Vector2(-769.6,-738.1), Vector2(-937.6,-677.4), Vector2(-1055,-663.6), Vector2(-1059.1,-636.3), Vector2(-1068,-628.1), Vector2(-1080.1,-625), Vector2(-1330.1,-625), Vector2(-1345.7,-630.5), Vector2(-1354.9,-647.4), Vector2(-1361,-650.2), Vector2(-1394.7,-640.8), Vector2(-1444.3,-642.6), Vector2(-1468.9,-652.1), Vector2(-1488.1,-666.7), Vector2(-1509.2,-670.4), Vector2(-1550.3,-664.1), Vector2(-1578.9,-671.2), Vector2(-1627.7,-701.3), Vector2(-1650.4,-735.5), Vector2(-1780.9,-699.9), Vector2(-1812.1,-698.8), Vector2(-1841.2,-684.3), Vector2(-1929.5,-661.9), Vector2(-1964.9,-664.2), Vector2(-1998,-681.1), Vector2(-2030.1,-671.1), Vector2(-2047.7,-653.6), Vector2(-2070.5,-641.2), Vector2(-2116.3,-636.7), Vector2(-2185,-649.1), Vector2(-2222.4,-673.7), Vector2(-2251.5,-680.1), Vector2(-2274.1,-693.4), Vector2(-2338.5,-776.8), Vector2(-2348.9,-799.7), Vector2(-2352.7,-824.1), Vector2(-3249.9,-860), Vector2(-3477.9,-878.2), Vector2(-3473.1,-853.5), Vector2(-3474.9,-830.9), Vector2(-3465.5,-821.8), Vector2(-3462.3,-801.5), Vector2(-3469.8,-779.8), Vector2(-3481.1,-764.4), Vector2(-3498.3,-774.2), Vector2(-3502.4,-782.6), Vector2(-3532.1,-762.1), Vector2(-3556.6,-752.5), Vector2(-3582.5,-750.4), Vector2(-3620,-755.4), Vector2(-3643,-763.2), Vector2(-3683.1,-788.8), Vector2(-3723.7,-827), Vector2(-3741.4,-859.1), Vector2(-3784.8,-881.1), Vector2(-3838.2,-930.9), Vector2(-3884.3,-993), Vector2(-3934.4,-1102.8), Vector2(-4199.9,-1419.9), Vector2(-4449.9,-1639.9), Vector2(-4700.1,-1780), Vector2(-4846.7,-1821.1)])
static var K_YARIMADA := _wl(R_YARIMADA)
static var R_GALATA := PackedVector2Array([Vector2(-870,1880), Vector2(-849.4,1885.3), Vector2(-828.8,1890.6), Vector2(-808.1,1895.9), Vector2(-787.5,1901.2), Vector2(-766.9,1906.6), Vector2(-746.2,1911.9), Vector2(-725.6,1917.2), Vector2(-705,1922.5), Vector2(-684.4,1927.8), Vector2(-663.8,1933.1), Vector2(-643.1,1938.4), Vector2(-622.5,1943.8), Vector2(-601.9,1949.1), Vector2(-581.2,1954.4), Vector2(-560.6,1959.7), Vector2(-540,1965), Vector2(-518.2,1962.3), Vector2(-496.4,1959.5), Vector2(-474.5,1956.8), Vector2(-452.7,1954.1), Vector2(-430.9,1951.4), Vector2(-409.1,1948.6), Vector2(-387.3,1945.9), Vector2(-365.5,1943.2), Vector2(-343.6,1940.5), Vector2(-321.8,1937.7), Vector2(-300,1935), Vector2(-281.7,1923.8), Vector2(-263.3,1912.5), Vector2(-245,1901.2), Vector2(-226.7,1890), Vector2(-208.3,1878.8), Vector2(-190,1867.5), Vector2(-171.7,1856.2), Vector2(-153.3,1845), Vector2(-135,1833.8), Vector2(-116.7,1822.5), Vector2(-98.3,1811.2), Vector2(-80,1800), Vector2(-67.4,1788.1), Vector2(-54.8,1776.2), Vector2(-42.3,1764.3), Vector2(-29.7,1752.3), Vector2(-45.7,1738.4), Vector2(-61.7,1724.5), Vector2(-77.7,1710.6), Vector2(-93.7,1696.6), Vector2(-109.7,1682.7), Vector2(-125.8,1668.8), Vector2(-141.8,1654.9), Vector2(-157.8,1641), Vector2(-173.8,1627), Vector2(-189.8,1613.1), Vector2(-205.8,1599.2), Vector2(-221.8,1585.3), Vector2(-238.5,1579.3), Vector2(-255.2,1573.3), Vector2(-272.1,1561.7), Vector2(-288.9,1550.1), Vector2(-305.7,1538.4), Vector2(-322.6,1526.8), Vector2(-336.4,1526.9), Vector2(-350.2,1526.9), Vector2(-370.5,1522.3), Vector2(-390.9,1517.6), Vector2(-411.2,1512.9), Vector2(-423.5,1519.2), Vector2(-435.7,1525.4), Vector2(-453.9,1531.8), Vector2(-472.2,1538.2), Vector2(-491.5,1540.7), Vector2(-502.7,1539.8), Vector2(-513.9,1538.9), Vector2(-529.5,1541.4), Vector2(-545.1,1543.9), Vector2(-560.7,1542.1), Vector2(-576.4,1540.2), Vector2(-591.7,1534.4), Vector2(-607,1528.6), Vector2(-627.6,1534.8), Vector2(-648.2,1541), Vector2(-668.8,1547.2), Vector2(-689.4,1553.4), Vector2(-708.8,1553.7), Vector2(-728.3,1554), Vector2(-747.7,1554.3), Vector2(-764.8,1566.2), Vector2(-781.9,1578.2), Vector2(-796.5,1582.4), Vector2(-811.1,1586.7), Vector2(-825.7,1591), Vector2(-839.8,1607.7), Vector2(-853.9,1624.3), Vector2(-867.9,1641), Vector2(-882,1657.6), Vector2(-896.1,1674.2), Vector2(-910.2,1690.9), Vector2(-924.2,1707.5), Vector2(-938.3,1724.1), Vector2(-952.4,1740.8), Vector2(-966.5,1757.4), Vector2(-980.5,1774.1), Vector2(-964.8,1789.2), Vector2(-949,1804.3), Vector2(-933.2,1819.5), Vector2(-917.4,1834.6), Vector2(-901.6,1849.7), Vector2(-885.8,1864.9)])
static var K_GALATA := _wl(R_GALATA)
static var R_ANADOLU := PackedVector2Array([Vector2(2258,1514), Vector2(2339.9,1683.6), Vector2(2428,1808), Vector2(2497.7,1872.5), Vector2(2656.1,1895.4), Vector2(2736.6,1881.3), Vector2(2809.3,1905.5), Vector2(2866,1982.7), Vector2(2932.4,2030.3), Vector2(2980.6,2108.1), Vector2(3046.9,2137), Vector2(3177.2,2329.1), Vector2(3371.8,2489.2), Vector2(3453.7,2501.1), Vector2(3570,2567.6), Vector2(4017.3,2986.6), Vector2(4233.5,3132.3), Vector2(4360.5,3268.8), Vector2(4440.9,3293.3), Vector2(4509.5,3360.1), Vector2(4668,3437.1), Vector2(4807.4,3566.7), Vector2(4829,3611.6), Vector2(5131.1,3836), Vector2(5312,3882.5), Vector2(5379.2,3955.7), Vector2(5520.4,4044), Vector2(5861.4,4249.7), Vector2(5983.8,4292.6), Vector2(6103.1,4400.8), Vector2(6135.2,4553.1), Vector2(6111.4,4678.1), Vector2(6043.6,4752.9), Vector2(6041.2,4830.4), Vector2(6071.3,4968.1), Vector2(6060.7,5053.5), Vector2(6101.8,5235.8), Vector2(6197.4,5437.8), Vector2(6127.5,5866.6), Vector2(6148.1,5907.8), Vector2(6263,6015.4), Vector2(6507.3,6424.8), Vector2(6494.9,6558), Vector2(6520.8,6682.8), Vector2(6473.7,6851.6), Vector2(6432.6,6921.6), Vector2(6374.1,7190.1), Vector2(6400.2,7256), Vector2(6523.6,7258), Vector2(6658.7,7289.3), Vector2(6838,7384.7), Vector2(6940.5,7470.5), Vector2(7056.6,7495.6), Vector2(7130.6,7626.8), Vector2(7123.2,7715.9), Vector2(7175.2,7821.5), Vector2(7197.4,7970.6), Vector2(7264.5,8015.9), Vector2(7288.5,8061.3), Vector2(7267.3,8148.3), Vector2(7312.5,8244.1), Vector2(7344,8504.8), Vector2(7283.7,8704.3), Vector2(7273.3,8830.1), Vector2(7247.8,8880.1), Vector2(7290.8,9235.4), Vector2(7235.8,9328.9), Vector2(7233.1,9377.6), Vector2(7238.5,9407), Vector2(7311.9,9429.7), Vector2(7361.9,9480.3), Vector2(7384.8,9547.7), Vector2(7347,9620.4), Vector2(7183.6,9702.2), Vector2(7132,9905.9), Vector2(7259.6,10259.3), Vector2(7275.1,10429.7), Vector2(7485.7,10617.8), Vector2(7674,10738.8), Vector2(7769.6,10843.8), Vector2(7837.2,10880.3), Vector2(7946.7,10846.5), Vector2(8132.5,10893.4), Vector2(8229.3,10953.8), Vector2(8250.6,11000), Vector2(8298.4,11000), Vector2(8328.3,10948.1), Vector2(8494.6,10886), Vector2(8568.8,10919.8), Vector2(8608.4,11000), Vector2(12000,11000), Vector2(12000,-9000), Vector2(11361.3,-9000), Vector2(11193.3,-8681.3), Vector2(11234.5,-8593), Vector2(11227.5,-8531.7), Vector2(10679.4,-7706), Vector2(10673.8,-7655.2), Vector2(10760,-7410.5), Vector2(10737.8,-7323), Vector2(10689.6,-7264.3), Vector2(10517.6,-7155.9), Vector2(10441.7,-7134.4), Vector2(10358.7,-7150.8), Vector2(10072,-6670.7), Vector2(9668.2,-6251.5), Vector2(9515.7,-6185.8), Vector2(9251.3,-6287.5), Vector2(9224.8,-6212.6), Vector2(9061.3,-5973.1), Vector2(9002.1,-5943.2), Vector2(8888.7,-5922.6), Vector2(8826.1,-5923.8), Vector2(8689.1,-5966.3), Vector2(8653.7,-6001.3), Vector2(8636.8,-6065.9), Vector2(8556.7,-6086.7), Vector2(8505.1,-6073.4), Vector2(8379.1,-5924.9), Vector2(8300.1,-5882.4), Vector2(8269.6,-5809.8), Vector2(8177.2,-5724.1), Vector2(8054.3,-5665.6), Vector2(7980.4,-5671.9), Vector2(7935.8,-5702.5), Vector2(7705.6,-5556.1), Vector2(7708.8,-5459.7), Vector2(7668.1,-5334.1), Vector2(7473.7,-5077.2), Vector2(7400.3,-5039), Vector2(7327,-5046.7), Vector2(7277.3,-5017.3), Vector2(7178.2,-5012.1), Vector2(7067.6,-5030.8), Vector2(6907,-5110.2), Vector2(6794.3,-5032.7), Vector2(6643,-5031.8), Vector2(6625.8,-4939.1), Vector2(6553.8,-4864.9), Vector2(6455.3,-4830.6), Vector2(6376.1,-4851.9), Vector2(6252.2,-4680.1), Vector2(6234.4,-4586.4), Vector2(6149.2,-4493.2), Vector2(6053.2,-4447.3), Vector2(5978.4,-4460.7), Vector2(5944.8,-4415.4), Vector2(5776.8,-4320.5), Vector2(5565.9,-4267.2), Vector2(5451.7,-4286.5), Vector2(5388.5,-4376.1), Vector2(5345.9,-4571), Vector2(5162.9,-4711.6), Vector2(5117.6,-4706), Vector2(5099.7,-4557.1), Vector2(5056.2,-4472), Vector2(4890.9,-4375), Vector2(4808.3,-4366.1), Vector2(4881.1,-4304.4), Vector2(4941.9,-4185.6), Vector2(4937.6,-4073.1), Vector2(4903.6,-3978.7), Vector2(4892.7,-3875), Vector2(4864,-3824.6), Vector2(5034.2,-3732.2), Vector2(5063.6,-3681.8), Vector2(5063.8,-3628.6), Vector2(5025.2,-3568.5), Vector2(4981.2,-3425.3), Vector2(4934.3,-3382.4), Vector2(4926.6,-3314.6), Vector2(4866.5,-3214.8), Vector2(4547,-2890), Vector2(4500.7,-2879.2), Vector2(4456,-2892.8), Vector2(4334.9,-3048.1), Vector2(4233.8,-3082.2), Vector2(4125.2,-3153.5), Vector2(4052,-3159), Vector2(4006.2,-3193.6), Vector2(3919.4,-3132.7), Vector2(3719.7,-3165.4), Vector2(3664.1,-3198.7), Vector2(3621,-3265.3), Vector2(3540.1,-3299.3), Vector2(3436.9,-3153.2), Vector2(3391.2,-3045.8), Vector2(3442.9,-2803.1), Vector2(3415,-2570.6), Vector2(3169.2,-2097.2), Vector2(3125.4,-1965.3), Vector2(3229.6,-1957.7), Vector2(3283.7,-1998.6), Vector2(3364.8,-2002.3), Vector2(3501.1,-1925), Vector2(3625.8,-1882.5), Vector2(3736.3,-1710.2), Vector2(3740.6,-1603.2), Vector2(3710,-1500), Vector2(3820.1,-1493.9), Vector2(3649.2,-1282.7), Vector2(3479.4,-1221.8), Vector2(3393.6,-1211.8), Vector2(3074,-782.8), Vector2(3014.1,-747.2), Vector2(2917.4,-729.7), Vector2(2941,-653.1), Vector2(2932.6,-579.3), Vector2(2807.9,-348.9), Vector2(2730.4,-304.7), Vector2(2601.5,-285.3), Vector2(2658.1,-219.2), Vector2(2678.8,-144.7), Vector2(2669.2,-71.4), Vector2(2615.4,40), Vector2(2746.6,397.1), Vector2(2752.9,542.1), Vector2(2716.9,771.2), Vector2(2639.4,964.8), Vector2(2536.2,1086.1), Vector2(2544.2,1197.8), Vector2(2440.7,1200), Vector2(2315.5,1353.1)])
static var K_ANADOLU := _wl(R_ANADOLU)
static var R_TRAKYA := PackedVector2Array([Vector2(6487.9,11000), Vector2(6446.6,10903.1), Vector2(6422.2,10773.7), Vector2(6384.7,10706.9), Vector2(6370.6,10589.6), Vector2(6243.4,10366.6), Vector2(6226.7,10205.1), Vector2(6190.4,10127.7), Vector2(6125.1,10073.5), Vector2(6110.6,10025.4), Vector2(6147.4,9929.1), Vector2(6191.1,9882.8), Vector2(6150.4,9811), Vector2(6144.6,9563.7), Vector2(6196.2,9422.2), Vector2(6278.5,9278.3), Vector2(6371.7,9183.1), Vector2(6388.3,9125.7), Vector2(6405.6,8911.7), Vector2(6389.2,8807.9), Vector2(6415.4,8656.2), Vector2(6382.6,8288.8), Vector2(6310.5,8159.4), Vector2(6174.9,8062.9), Vector2(6035.3,7990.9), Vector2(5934.3,7984.3), Vector2(5715.1,7908.6), Vector2(5549.7,7888.1), Vector2(5454.3,7784.5), Vector2(5393.4,7769.8), Vector2(5339.8,7704.9), Vector2(5321.4,7627), Vector2(5338.5,7540.3), Vector2(5306.7,7372.1), Vector2(5378.2,7169.5), Vector2(5409.6,6936.6), Vector2(5502.8,6737.4), Vector2(5498.3,6621.2), Vector2(5300,6548.5), Vector2(5237,6548.9), Vector2(5178.5,6509), Vector2(5077.7,6333.7), Vector2(5034.9,6059.2), Vector2(4796.7,5864.1), Vector2(4687.5,5690.3), Vector2(4624.9,5284.6), Vector2(4511.8,4931.3), Vector2(4377,4619.5), Vector2(4228.8,4584.2), Vector2(4038.8,4473.2), Vector2(3947.4,4335.3), Vector2(3859.8,4376.9), Vector2(3737.3,4352.8), Vector2(3393,4178.2), Vector2(3279.6,4116.1), Vector2(3153.1,4023.7), Vector2(3125.6,3977.1), Vector2(3039.2,3924.8), Vector2(2488.6,3690.7), Vector2(2294.9,3681.7), Vector2(2255.4,3651.1), Vector2(2187.6,3634.7), Vector2(2071.4,3530), Vector2(1361,3260.7), Vector2(1219.9,3130.4), Vector2(1095.1,2969.2), Vector2(1089.5,2758.5), Vector2(968.9,2710.1), Vector2(932.6,2652.2), Vector2(790.5,2526.5), Vector2(651.4,2274.8), Vector2(642.7,2214.6), Vector2(152.5,1912.3), Vector2(-28.9,1753), Vector2(-299.6,1935.9), Vector2(-540,1966), Vector2(-870.4,1880.9), Vector2(-981.2,1774.8), Vector2(-1070.2,1952.9), Vector2(-1096.7,2120.8), Vector2(-1120.3,2162.2), Vector2(-1065.9,2259), Vector2(-1058.4,2343), Vector2(-1102.7,2456.1), Vector2(-1160,2526), Vector2(-1213.8,2553.6), Vector2(-1273,2540.8), Vector2(-1666.1,2864), Vector2(-1754.9,2853.7), Vector2(-1894.2,2876), Vector2(-1956.2,2851.2), Vector2(-2014.8,2859.2), Vector2(-2053.1,2888.7), Vector2(-2118.2,2891), Vector2(-2157.7,2925.8), Vector2(-2251.9,2951.4), Vector2(-2267.8,3029.8), Vector2(-2441.2,3299), Vector2(-2474.4,3438), Vector2(-2544.2,3561.6), Vector2(-2635.8,3659.2), Vector2(-2645,3726.9), Vector2(-2696.7,3804.6), Vector2(-2771.1,3877.7), Vector2(-2954.4,4004.3), Vector2(-3071,4051.9), Vector2(-3203.7,4141.3), Vector2(-3219.3,4212.2), Vector2(-3290.8,4290.2), Vector2(-3396.1,4554), Vector2(-3374.8,4728.1), Vector2(-3310.6,4836.7), Vector2(-3050.1,5015), Vector2(-2699.9,5162.3), Vector2(-2671.2,5200.8), Vector2(-2607.1,5393.4), Vector2(-2630.1,5630), Vector2(-2693.2,5805), Vector2(-2705.4,5926.2), Vector2(-2700.4,5996), Vector2(-2662.2,6066.1), Vector2(-2667.9,6131.7), Vector2(-2736,6183.9), Vector2(-2780.3,6179.8), Vector2(-2820.2,6151.5), Vector2(-2850.7,6159.6), Vector2(-2904.1,6286.2), Vector2(-2952.8,6304.3), Vector2(-3015.7,6291.7), Vector2(-3058.7,6230.6), Vector2(-3058.8,6094.9), Vector2(-2952,5823.7), Vector2(-2858.8,5426.6), Vector2(-2925.3,5424.8), Vector2(-3023,5367.3), Vector2(-3127.4,5371.2), Vector2(-3239.5,5311.9), Vector2(-3387.4,5273), Vector2(-3523.5,5210.5), Vector2(-3722.5,4982.5), Vector2(-3786.2,4883.3), Vector2(-3815.9,4807.8), Vector2(-3848.7,4586.9), Vector2(-3834.7,4537.8), Vector2(-3650.6,4279), Vector2(-3587.2,4223.5), Vector2(-3561.3,3972.1), Vector2(-3447.2,3731.4), Vector2(-3340.5,3655.7), Vector2(-3031.1,3525.2), Vector2(-3096,3437.5), Vector2(-3161.2,3488.1), Vector2(-3234.5,3460.4), Vector2(-3257.3,3383.6), Vector2(-3338.8,3294.3), Vector2(-3429.8,3255.3), Vector2(-3446.4,3199.6), Vector2(-3427.7,3065.3), Vector2(-3452.9,2930.5), Vector2(-3397.5,2890), Vector2(-3351.3,2880.8), Vector2(-3375.2,2747.5), Vector2(-3702.6,2528.3), Vector2(-3759,2412.5), Vector2(-3760.4,2366.9), Vector2(-3803.2,2305), Vector2(-4026.9,2051.9), Vector2(-4250.9,1755.8), Vector2(-4275.7,1778.1), Vector2(-4292.3,1761.4), Vector2(-4620.3,1357.7), Vector2(-4812.8,970.6), Vector2(-4874.5,770), Vector2(-4910.7,524.1), Vector2(-4861.4,336.3), Vector2(-4866.1,79.4), Vector2(-4881.3,78.2), Vector2(-4881.6,43), Vector2(-4857,38.2), Vector2(-4862.3,-36.6), Vector2(-4889.9,-47.3), Vector2(-5034.7,-869.1), Vector2(-5028.3,-1007.6), Vector2(-4937.6,-1540.7), Vector2(-4858.6,-1697.2), Vector2(-4876.2,-1704.9), Vector2(-4855.9,-1774.1), Vector2(-4838.5,-1773.1), Vector2(-4847.7,-1821.4), Vector2(-4959.8,-1849.7), Vector2(-4960,-2245), Vector2(-5296.5,-2246.4), Vector2(-5489.2,-2326.6), Vector2(-5774.1,-2481.3), Vector2(-6081.2,-2967.9), Vector2(-6544.1,-3218.7), Vector2(-6732.4,-3235.8), Vector2(-6969.6,-3138.8), Vector2(-7020.4,-3153.1), Vector2(-7074.4,-3210.8), Vector2(-7138.3,-3182.1), Vector2(-7188.5,-3126.7), Vector2(-7309.2,-3113.2), Vector2(-7421.2,-3132.2), Vector2(-7473.3,-3164.5), Vector2(-7540.8,-3129.6), Vector2(-7665.9,-3158.7), Vector2(-7911.4,-3337.4), Vector2(-7991.2,-3445.6), Vector2(-8062.5,-3480.5), Vector2(-8179.8,-3489.1), Vector2(-8446,-3719.3), Vector2(-8592,-3790.2), Vector2(-8638.4,-3847), Vector2(-8648.7,-3892.3), Vector2(-8631.1,-4013.8), Vector2(-8572.7,-4097.7), Vector2(-8843.1,-4367.8), Vector2(-8951.5,-4371.7), Vector2(-8967.5,-4288.9), Vector2(-9033.1,-4249), Vector2(-9336,-4256.2), Vector2(-9394.9,-4283.1), Vector2(-9544.3,-4284.2), Vector2(-9545.8,-3898.1), Vector2(-9567.2,-3852.1), Vector2(-9609.6,-3825.1), Vector2(-9978.1,-3762.9), Vector2(-10112.5,-3757.9), Vector2(-10194.6,-3783.9), Vector2(-10260.6,-3768.4), Vector2(-10451.5,-3773.9), Vector2(-10627.9,-3723.4), Vector2(-10769,-3735.8), Vector2(-10830.4,-3760.5), Vector2(-11017.8,-3912.3), Vector2(-11045.4,-3974.8), Vector2(-11046.8,-4067.3), Vector2(-11141.4,-4099.3), Vector2(-11239.9,-4172.3), Vector2(-11376,-4371.2), Vector2(-11410.2,-4528.7), Vector2(-11369,-4622.5), Vector2(-11457.7,-4755.9), Vector2(-11520.2,-4898.3), Vector2(-11541.9,-5000.3), Vector2(-11651.6,-5229.2), Vector2(-11709,-5272.7), Vector2(-11796.6,-5442.9), Vector2(-11888,-5561.8), Vector2(-11910.2,-5629.8), Vector2(-12000,-5597), Vector2(-12000,11000)])
static var K_TRAKYA := _wl(R_TRAKYA)
static var R_KARA := PackedVector2Array([Vector2(-4875.2,-1704.9), Vector2(-4857.3,-1697.8), Vector2(-4881.1,-1631.3), Vector2(-4889.7,-1637), Vector2(-4936.6,-1540.5), Vector2(-5027.3,-1007.5), Vector2(-5033.7,-869.2), Vector2(-4978,-603), Vector2(-4932.4,-279.7), Vector2(-4889,-47.5), Vector2(-4861.4,-37.3), Vector2(-4856,39), Vector2(-4880.6,43), Vector2(-4880.4,77.8), Vector2(-4865.1,78.5), Vector2(-4860.4,336.5), Vector2(-4909.7,524), Vector2(-4873.5,769.9), Vector2(-4811.8,970.3), Vector2(-4786.8,1035.4), Vector2(-4779.4,1031.6), Vector2(-4710.5,1200.2), Vector2(-4699,1194.2), Vector2(-4619.5,1357.1), Vector2(-4540.7,1437.7), Vector2(-4548.6,1445.6), Vector2(-4536.8,1465.4), Vector2(-4291.6,1760.7), Vector2(-4275.9,1777.1), Vector2(-4250.7,1754.2), Vector2(-4026.2,2051.2), Vector2(-3802.4,2304.4), Vector2(-3759.5,2366.4), Vector2(-3753.5,2383.9), Vector2(-3758.1,2412.2), Vector2(-3701.8,2527.7), Vector2(-3374.5,2746.8), Vector2(-3356.2,2780.4), Vector2(-3350.2,2881.6), Vector2(-3397,2890.9), Vector2(-3451.9,2930.6), Vector2(-3426.7,3065.2), Vector2(-3429.5,3118.9), Vector2(-3445.4,3199.6), Vector2(-3429,3254.8), Vector2(-3338.2,3293.4), Vector2(-3264.2,3385), Vector2(-3256.6,3382.3), Vector2(-3233.9,3459.6), Vector2(-3170.8,3472.1), Vector2(-3161.4,3487.1), Vector2(-3095.8,3436.1)])
static var Y_KARA := _wl(R_KARA)
static var R_BLAKHERNA := PackedVector2Array([Vector2(-3427.6,2913), Vector2(-3451.9,2930.6), Vector2(-3426.7,3065.2), Vector2(-3429.5,3118.9), Vector2(-3445.4,3199.6), Vector2(-3429,3254.8), Vector2(-3338.2,3293.4), Vector2(-3264.2,3385), Vector2(-3256.6,3382.3), Vector2(-3233.9,3459.6), Vector2(-3170.8,3472.1), Vector2(-3161.4,3487.1), Vector2(-3095.8,3436.1)])
static var Y_BLAKHERNA := _wl(R_BLAKHERNA)
static var R_MARMARA := PackedVector2Array([Vector2(-4869.4,-1703.2), Vector2(-4850.6,-1767.3), Vector2(-4836.2,-1766.1), Vector2(-4831.6,-1770.2), Vector2(-4839,-1812.7), Vector2(-4702.3,-1774.4), Vector2(-4453.5,-1635.1), Vector2(-4204.2,-1415.7), Vector2(-3939.5,-1099.6), Vector2(-3889.5,-990), Vector2(-3842.7,-926.9), Vector2(-3788.5,-876.3), Vector2(-3745.8,-854.6), Vector2(-3728.2,-823), Vector2(-3686.8,-784.1), Vector2(-3621.1,-749.5), Vector2(-3555.2,-746.7), Vector2(-3503.1,-775.3), Vector2(-3484,-759.1), Vector2(-3477.2,-759.8), Vector2(-3456.3,-801.2), Vector2(-3459.9,-823.8), Vector2(-3469,-833.6), Vector2(-3471.4,-871.7), Vector2(-3250.1,-854), Vector2(-2357.2,-818.3), Vector2(-2343.6,-773.6), Vector2(-2277.7,-688.6), Vector2(-2253.4,-674.4), Vector2(-2224.8,-668), Vector2(-2187.2,-643.6), Vector2(-2117.3,-630.8), Vector2(-2068.3,-635.6), Vector2(-2027.4,-665.7), Vector2(-1998.5,-674.7), Vector2(-1966.5,-658.4), Vector2(-1928.6,-655.9), Vector2(-1839.1,-678.7), Vector2(-1810.6,-692.9), Vector2(-1779.3,-694.1), Vector2(-1653,-728.6), Vector2(-1631.9,-697), Vector2(-1581.5,-665.8), Vector2(-1550.6,-658.1), Vector2(-1509.3,-664.3), Vector2(-1490.1,-660.9), Vector2(-1445.6,-636.7), Vector2(-1394.3,-634.8), Vector2(-1363.2,-643.3), Vector2(-1349.2,-625.7), Vector2(-1330.1,-619), Vector2(-1080.1,-619), Vector2(-1054.4,-632.6), Vector2(-1049.7,-658.2), Vector2(-936.2,-671.6), Vector2(-767.8,-732.3), Vector2(-601,-777.2), Vector2(-440.1,-780.4), Vector2(-414.7,-765.2), Vector2(-381.4,-758.8), Vector2(-224.6,-767.1), Vector2(-222,-755.3), Vector2(-204.9,-752.5), Vector2(-190.9,-725.4), Vector2(-162.7,-701), Vector2(-27.7,-666.5), Vector2(6.5,-651.4), Vector2(59.3,-616), Vector2(102.9,-575.3), Vector2(217.3,-410.5), Vector2(265.3,-366.2), Vector2(397.9,-265.4), Vector2(434.4,-217.9), Vector2(451.9,-182.7), Vector2(499.2,-2.7), Vector2(578.3,194.7), Vector2(586.7,294.3), Vector2(522.8,297.6), Vector2(517.8,302.1), Vector2(526.1,463.9), Vector2(492.9,566.5), Vector2(437.5,842.8)])
static var Y_MARMARA := _wl(R_MARMARA)
static var R_HALIC := PackedVector2Array([Vector2(437.5,843.1), Vector2(433.6,866.7), Vector2(404,874.4), Vector2(351.7,864.6), Vector2(269.6,830.8), Vector2(161.4,773.4), Vector2(73.3,760.7), Vector2(-147.5,761.3), Vector2(-232.5,773), Vector2(-283.5,771.4), Vector2(-342.1,790.3), Vector2(-391.7,825.1), Vector2(-609,933.8), Vector2(-695.4,926.4), Vector2(-801.2,959.2), Vector2(-924.2,1040.5), Vector2(-955.8,1071.3), Vector2(-1052.6,1072), Vector2(-1111.3,1086.5), Vector2(-1176.4,1081), Vector2(-1220.9,1092.3), Vector2(-1260.3,1114.9), Vector2(-1307.5,1166.5), Vector2(-1329.2,1226.8), Vector2(-1431.9,1281.2), Vector2(-1506.7,1357.9), Vector2(-1536.9,1424.8), Vector2(-1544.6,1498), Vector2(-1539.7,1502.3), Vector2(-1471.2,1505.8), Vector2(-1467,1521.9), Vector2(-1474.8,1532.5), Vector2(-1501.3,1544.1), Vector2(-1544.4,1577.6), Vector2(-1617.1,1620.6), Vector2(-1645.9,1647.3), Vector2(-1707.1,1727.2), Vector2(-1765,1819.6), Vector2(-1791.3,1883.2), Vector2(-1794.4,1946.6), Vector2(-1858.6,1993.8), Vector2(-1937.1,2074.1), Vector2(-1971.1,2151.9), Vector2(-2014.8,2152.2), Vector2(-2121.9,2173.1), Vector2(-2298.3,2231.5), Vector2(-2336,2266.7), Vector2(-2375.5,2335.7), Vector2(-2380.2,2372.2), Vector2(-2363.3,2419), Vector2(-2366,2422.7), Vector2(-2397.9,2425.5), Vector2(-2477.6,2454.4), Vector2(-2541.4,2502.8), Vector2(-2613.7,2614.1), Vector2(-2620.9,2708.4), Vector2(-2614.5,2743.1), Vector2(-2652.3,2773.4), Vector2(-2674.2,2830.4), Vector2(-2676.8,2888.2), Vector2(-2667,2921), Vector2(-2670.5,2950.8), Vector2(-2704.5,2988), Vector2(-2739.4,2999.9), Vector2(-2799.6,3035.4), Vector2(-2848.2,3098.8), Vector2(-2906.1,3229.3), Vector2(-2911.1,3265.4), Vector2(-3028.1,3517.5), Vector2(-3091,3432.5)])
static var Y_HALIC := _wl(R_HALIC)
static var R_GALATA_SUR := PackedVector2Array([Vector2(-870,1880), Vector2(-849.4,1885.3), Vector2(-828.8,1890.6), Vector2(-808.1,1895.9), Vector2(-787.5,1901.2), Vector2(-766.9,1906.6), Vector2(-746.2,1911.9), Vector2(-725.6,1917.2), Vector2(-705,1922.5), Vector2(-684.4,1927.8), Vector2(-663.8,1933.1), Vector2(-643.1,1938.4), Vector2(-622.5,1943.8), Vector2(-601.9,1949.1), Vector2(-581.2,1954.4), Vector2(-560.6,1959.7), Vector2(-540,1965), Vector2(-518.2,1962.3), Vector2(-496.4,1959.5), Vector2(-474.5,1956.8), Vector2(-452.7,1954.1), Vector2(-430.9,1951.4), Vector2(-409.1,1948.6), Vector2(-387.3,1945.9), Vector2(-365.5,1943.2), Vector2(-343.6,1940.5), Vector2(-321.8,1937.7), Vector2(-300,1935), Vector2(-281.7,1923.8), Vector2(-263.3,1912.5), Vector2(-245,1901.2), Vector2(-226.7,1890), Vector2(-208.3,1878.8), Vector2(-190,1867.5), Vector2(-171.7,1856.2), Vector2(-153.3,1845), Vector2(-135,1833.8), Vector2(-116.7,1822.5), Vector2(-98.3,1811.2), Vector2(-80,1800), Vector2(-67.4,1788.1), Vector2(-54.8,1776.2), Vector2(-42.3,1764.3), Vector2(-29.7,1752.3), Vector2(-45.7,1738.4), Vector2(-61.7,1724.5), Vector2(-77.7,1710.6), Vector2(-93.7,1696.6), Vector2(-109.7,1682.7), Vector2(-125.8,1668.8), Vector2(-141.8,1654.9), Vector2(-157.8,1641), Vector2(-173.8,1627), Vector2(-189.8,1613.1), Vector2(-205.8,1599.2), Vector2(-221.8,1585.3), Vector2(-238.5,1579.3), Vector2(-255.2,1573.3), Vector2(-272.1,1561.7), Vector2(-288.9,1550.1), Vector2(-305.7,1538.4), Vector2(-322.6,1526.8), Vector2(-336.4,1526.9), Vector2(-350.2,1526.9), Vector2(-370.5,1522.3), Vector2(-390.9,1517.6), Vector2(-411.2,1512.9), Vector2(-423.5,1519.2), Vector2(-435.7,1525.4), Vector2(-453.9,1531.8), Vector2(-472.2,1538.2), Vector2(-491.5,1540.7), Vector2(-502.7,1539.8), Vector2(-513.9,1538.9), Vector2(-529.5,1541.4), Vector2(-545.1,1543.9), Vector2(-560.7,1542.1), Vector2(-576.4,1540.2), Vector2(-591.7,1534.4), Vector2(-607,1528.6), Vector2(-627.6,1534.8), Vector2(-648.2,1541), Vector2(-668.8,1547.2), Vector2(-689.4,1553.4), Vector2(-708.8,1553.7), Vector2(-728.3,1554), Vector2(-747.7,1554.3), Vector2(-764.8,1566.2), Vector2(-781.9,1578.2), Vector2(-796.5,1582.4), Vector2(-811.1,1586.7), Vector2(-825.7,1591), Vector2(-839.8,1607.7), Vector2(-853.9,1624.3), Vector2(-867.9,1641), Vector2(-882,1657.6), Vector2(-896.1,1674.2), Vector2(-910.2,1690.9), Vector2(-924.2,1707.5), Vector2(-938.3,1724.1), Vector2(-952.4,1740.8), Vector2(-966.5,1757.4), Vector2(-980.5,1774.1), Vector2(-964.8,1789.2), Vector2(-949,1804.3), Vector2(-933.2,1819.5), Vector2(-917.4,1834.6), Vector2(-901.6,1849.7), Vector2(-885.8,1864.9), Vector2(-870,1880)])
static var Y_GALATA := _wl(R_GALATA_SUR)
static var R_MESE := PackedVector2Array([Vector2(-230,-30), Vector2(-480,-20), Vector2(-756,-11), Vector2(-1100,90), Vector2(-1554,211), Vector2(-1900,520)])
static var Y_MESE := _wl(R_MESE)
static var R_MESE_K := PackedVector2Array([Vector2(-1900,520), Vector2(-2150,800), Vector2(-2450,1150), Vector2(-2950,1750), Vector2(-3646.6,2564.6)])
static var Y_MESE_K := _wl(R_MESE_K)
static var R_MESE_G := PackedVector2Array([Vector2(-1900,520), Vector2(-2250,250), Vector2(-2540,-70), Vector2(-2950,-250), Vector2(-3330,-450), Vector2(-4000,-1050), Vector2(-4857.3,-1697.8)])
static var Y_MESE_G := _wl(R_MESE_G)
static var R_LYKOS := PackedVector2Array([Vector2(-6800,2500), Vector2(-5600,1700), Vector2(-4600,1150), Vector2(-4200,950), Vector2(-3600,600), Vector2(-2900,250), Vector2(-2350,-150), Vector2(-2250,-500), Vector2(-2230,-900)])
static var Y_LYKOS := _wl(R_LYKOS)
static var R_ZINCIR := PackedVector2Array([Vector2(-379.4,816.4), Vector2(-513.9,1538.9)])
static var Y_ZINCIR := _wl(R_ZINCIR)
static var R_BOZDOGAN := PackedVector2Array([Vector2(-2460,1000), Vector2(-1600,730)])
static var Y_BOZDOGAN := _wl(R_BOZDOGAN)
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
