extends RefCounted
## OTURTMA: kara surunu araziye TEK yer olarak oturtur. Sur kuşağının arazi yüksekliği tek kaynaktan gelir:
## IstGeo.h (geo.gd'nin düzlük kayıtları, IstGeo.duzle). Her dilim / kapı koşusu için kesit boyunca dört kuşak kaydedilir:
##   şehir önü (iç sur şehir yüzünden 16 m, doğal araziye 10 m'de yumuşak geçiş), iç kuşak (iç sur + peribolos: dilim
##   tabanı), dış kuşak (dış sur dışı parateikhion terası: taban + dış kademe), hendek dış omzu (taban + dış kademe; 12 m'de
##   doğala geçer) ve en son hendek tabanı oyması (yalnız çarpışma ve yerleşim için; görünen arazi hendek bandında KESİLİR).
## Arazi ağı (IstDunya) hendek bandının üstünden geçmez: `kes_ucgen` üçgenleri bandın dikdörtgenleriyle kırpar (yeni köşe
## yüksekliği IstGeo.h'den: kıyıda arazi harpuşta düzeyinde biter, çukura sarkmaz).
## Kuşak maskesi (`kusakta`): hendek ve sur dibindeki 12 m'lik kuşakta yabancı süs (ot piramidi, oyuncak ağaç, kutu) çıkmaz.

const K_SUR := 1.0
const Y_MIN := 2.0             # kuşak zemininin alt sınırı (deniz düzlemi y = 0; zemin gölgelendiricisi 0–4 m'yi kıyı/ıslak boyar)
const IZG := 32.0
## Hendek bandı (dilim yerel z): iç yaka duvarının dış yüzü … karşı yaka duvarının dış yüzü
static var bantlar: Array = []          # [A: Vector2, d: Vector2, o: Vector2, t0, t1, c0, c1]
static var _bizg := {}                  # Vector2i → Array[int] (bant)
## Sur kuşağı (maske ve renk): [A, d, o, t0, t1, cmin, cmax, y_ic, y_dis]
static var kusak: Array = []
static var _kizg := {}
static var dy_kayit: Array = []         # [Vector2 (dilim kökü), dy]
static var sayac := {}


static func temizle() -> void:
	bantlar.clear()
	_bizg.clear()
	kusak.clear()
	_kizg.clear()
	dy_kayit.clear()
	sayac.clear()


## Dilim kökünün (dünya) kayıtlı dış kademesi; yoksa NAN
static func dy_bul(p: Vector3) -> float:
	var q := Vector2(p.x, p.z)
	for e: Array in dy_kayit:
		if (e[0] as Vector2).distance_squared_to(q) < 0.25:
			return float(e[1])
	return NAN


static func _izg_ekle(izg: Dictionary, idx: int, pts: Array) -> void:
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for p: Vector2 in pts:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	for cx in range(floori(lo.x / IZG), floori(hi.x / IZG) + 1):
		for cz in range(floori(lo.y / IZG), floori(hi.y / IZG) + 1):
			var k := Vector2i(cx, cz)
			if not izg.has(k):
				izg[k] = []
			(izg[k] as Array).append(idx)


static func _dikd(b: Array) -> Array:
	var A: Vector2 = b[0]
	var d: Vector2 = b[1]
	var o: Vector2 = b[2]
	return [A + d * float(b[3]) + o * float(b[5]), A + d * float(b[4]) + o * float(b[5]),
		A + d * float(b[4]) + o * float(b[6]), A + d * float(b[3]) + o * float(b[6])]


## sehir.gd (_hatlar_v2) çağırır: kara surunun dilimleri, kapı koşuları ve köşe dolguları kurulduktan sonra.
## s: IstSehir. Dönen: alan (arazi ağının yenileneceği dünya dikdörtgeni)
static func kur(s: Node, ad: String) -> Rect2:
	var t0 := Time.get_ticks_usec()
	var d := IstSurlar.dims(K_SUR)
	var zi0 := float(d["zi0"])
	var zm0 := float(d["zm0"])
	var zm1 := float(d["zm1"])
	var MD := float(d["MD"])
	var pl: PackedVector2Array = IstSehir._sade(IstGeo.yol(ad))
	var S: Array = [0.0]
	for i in pl.size() - 1:
		S.append(float(S[i]) + pl[i].distance_to(pl[i + 1]))
	var liste: Array = []
	for it: Dictionary in s.hat_items + s.items:
		var on := String(it.get("hat", "")) == ad or String(it.get("kapi_hat", "")) == ad
		var id := String(it["id"])
		if not on or not it.has("a2") or not it.has("s0") or id.begins_with("kose_") or id.begins_with("kdolgu_"):
			continue
		if liste.has(it):
			continue
		liste.append(it)
	liste.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["s0"]) < float(b["s0"]))
	# 1) dış kademe (arazi düzlenmeden ÖNCE ölçülür; dilimin kendi kurulumu da bu kaydı okur: IstSurlar.dis_dy)
	var ogeler: Array = []
	for it: Dictionary in liste:
		var id := String(it["id"])
		var hendek := not (id in ["kaligaria", "kerkoporta"])
		var L := float(it.get("len", it.get("glen", 0.0)))
		if L <= 0.0:
			continue
		var p: Vector3 = it["pos"]
		var xf := Transform3D(Basis(Vector3.UP, float(it["yaw"])), p)
		var dy := IstSurlar.dis_dy(xf, L, K_SUR) if hendek else 0.0
		# kuşak zemini deniz düzeyinin üstünde kalır (Lykos vadisi, Marmara ucu: taban −0,65 m'ye inebiliyor; arazi o
		# düzeye düzlenince deniz düzlemi şehir yanını ve terası basıyordu). Dilim tabanı aşağıdaysa temel gömülür.
		dy = maxf(dy, Y_MIN - p.y) if hendek else 0.0
		var a: Vector2 = it["a2"]
		var b: Vector2 = it["b2"]
		var dv := (b - a).normalized()
		var o := IstSehir._out(dv, (a + b) * 0.5, ad)
		ogeler.append({"it": it, "a": a, "b": b, "d": dv, "o": o, "L": a.distance_to(b), "y": maxf(p.y, Y_MIN), "dy": dy - maxf(Y_MIN - p.y, 0.0), "hendek": hendek})
	for g: Dictionary in ogeler:
		# kayıt dilim kökü tabanına göre (dilim y'si sabit): dış zemin = kök y + kayıt
		var py := float((g["it"]["pos"] as Vector3).y)
		var rel := float(g["y"]) + float(g["dy"]) - py
		dy_kayit.append([Vector2((g["it"]["pos"] as Vector3).x, (g["it"]["pos"] as Vector3).z), rel])
		(g["it"] as Dictionary)["oturtma_dy"] = rel
	# 2) düzlük kayıtları (tek yükseklik kaynağı). Bölümlerin önceden kaydettiği düzlükler (hub) şehir önünde korunur.
	var onceki: Array = IstGeo._duz.duplicate()
	var alan := Rect2()
	var n_duz := 0
	var ekle := func(g: Dictionary, c: float, r: float, y: float, gecis: float, adim: float, u0: float, u1: float, koru: bool) -> int:
		var a: Vector2 = g["a"]
		var dv: Vector2 = g["d"]
		var o: Vector2 = g["o"]
		var n := maxi(1, int(ceil((u1 - u0) / adim)))
		var k := 0
		for j in n + 1:
			var q := a + dv * lerpf(u0, u1, float(j) / n) + o * c
			# denizin üstüne düşen düzlük kurulmaz (kuzey ucunda arazi Haliç'e dil gibi uzuyordu); hendek oyması hariç
			if y > 0.0 and IstGeo.h_ham(q.x, q.y) < 0.0:
				continue
			if koru:
				var dolu := false
				for e: Array in onceki:
					if (e[0] as Vector2).distance_to(q) < float(e[1]) + r * 0.5:
						dolu = true
						break
				if dolu:
					continue
			IstGeo.duzle(q, r, y, gecis)
			k += 1
		return k
	for g: Dictionary in ogeler:
		var L: float = g["L"]
		var y: float = g["y"]
		n_duz += int(ekle.call(g, zi0 - 5.5, 8.0, y, 10.0, 8.0, -2.0, L + 2.0, true))
		if g["hendek"]:
			# dış omzun doğaya geçişi (12 m)
			n_duz += int(ekle.call(g, zm1 + 12.0, 4.0, y + float(g["dy"]), 12.0, 8.0, 0.0, L, false))
	for g: Dictionary in ogeler:
		if g["hendek"]:
			var Lt := float(g["L"])
			n_duz += int(ekle.call(g, 25.0, 6.5, float(g["y"]) + float(g["dy"]), 2.0, 6.0, minf(4.0, Lt * 0.5), maxf(Lt - 4.0, Lt * 0.5), false))
	# hendek dış kıyısı: dilimin kendi harpuşta düzeyi (dar, 1 m geçiş: komşu dilimin düzeyi kıyıya taşmasın; basamak bent
	# duvarının hizasında)
	for g: Dictionary in ogeler:
		if g["hendek"]:
			n_duz += int(ekle.call(g, zm1 + 4.4, 4.0, float(g["y"]) + float(g["dy"]), 1.0, 4.0, minf(3.5, float(g["L"]) * 0.5), maxf(float(g["L"]) - 3.5, float(g["L"]) * 0.5), false))
	# iç kuşak: kenarı (tarak dişi dahil) dış surun içinde 18,1 … 19,0 m'de; dış kademe kenarı 19,2 m'den dışarıda tam
	for g: Dictionary in ogeler:
		# (merkezler uçlardan 7 m içeride: komşu dilimin peribolosuna en çok 2,6 m taşar; kademe dilim ekleminde kalır)
		var Lg := float(g["L"])
		n_duz += int(ekle.call(g, 9.0, 9.6, float(g["y"]), 0.4, 6.0, minf(7.0, Lg * 0.5), maxf(Lg - 7.0, Lg * 0.5), false))
	# hendek tabanı oyması (yalnız çarpışma / yerleşim): bandın 1,6 m içinde kalır, uçlardan 12 m içeride
	for g: Dictionary in ogeler:
		if g["hendek"] and float(g["L"]) > 25.0:
			n_duz += int(ekle.call(g, (zm0 + zm1) * 0.5, 8.6, float(g["y"]) + float(g["dy"]) - MD - 0.3, 0.3, 5.0, 12.0, float(g["L"]) - 12.0, false))
	# 3) hendek bandı (görünen arazinin kesildiği yer): hendekli öğelerin yay aralıkları birleşir (≤ 30 m'lik köşe aralığı dahil)
	var ara: Array = []
	for g: Dictionary in ogeler:
		if not g["hendek"]:
			continue
		var s0 := float(g["it"]["s0"])
		var s1 := float(g["it"]["s1"])
		if ara.size() > 0 and s0 - float(ara[ara.size() - 1][1]) <= 30.0:
			ara[ara.size() - 1][1] = maxf(float(ara[ara.size() - 1][1]), s1)
		else:
			ara.append([s0, s1])
	var c0 := zm0 - 0.9
	var c1 := zm1 + 0.9
	# iki bant: hendek (iç yaka duvarının dış yüzü … karşı yaka duvarının dış yüzü) ve dış sur gövdesinin içi (iç kuşak
	# tabanı ile dış kademe arasındaki basamak duvarın içinde kalsın: 6 m'lik arazi üçgeni basamağı terasa eğim olarak taşımasın)
	_bant_kur(pl, S, ara, ad, c0, c1)
	_bant_kur(pl, S, ara, ad, float(d["zo0"]) + 0.3, float(d["zo1"]) - 0.3)
	# 4) kuşak (maske ve sur dibi rengi): şehir yüzünden 20 m içeri … hendek dış kıyısından ATES m dışarı (ateş alanı:
	# çiğnenmiş toprak, ağaçsız). kb[6]: hendek dış kıyısı (hendeksizde dış sur dış yüzü)
	for g: Dictionary in ogeler:
		var kb := [g["a"], g["d"], g["o"], -3.0, float(g["L"]) + 3.0, zi0 - 20.0, c1 if g["hendek"] else float(d["zo1"]), float(g["y"]), float(g["y"]) + float(g["dy"]), ATES + 8.0]
		kusak.append(kb)
		var kd := [kb[0], kb[1], kb[2], kb[3], kb[4], kb[5], float(kb[6]) + float(kb[9])]
		_izg_ekle(_kizg, kusak.size() - 1, _dikd(kd))
		for q: Vector2 in _dikd(kd):
			alan = Rect2(q, Vector2.ZERO) if alan.size == Vector2.ZERO and alan.position == Vector2.ZERO else alan.expand(q)
	sayac = {"oge": ogeler.size(), "duz": n_duz, "bant": bantlar.size(), "kusak": kusak.size(),
		"ms": (Time.get_ticks_usec() - t0) / 1000.0}
	print("OTURTMA kur oge=%d duz=%d bant=%d ms=%.1f" % [ogeler.size(), n_duz, bantlar.size(), float(sayac["ms"])])
	return alan.grow(40.0)


const ATES := 60.0            # hendek dış kıyısından ateş alanı (ağaçsız, çiğnenmiş toprak; SUR-4 / ORDUGÂH sınırı)

static func _bant_kur(pl: PackedVector2Array, S: Array, ara: Array, ad: String, c0: float, c1: float) -> void:
	for i in pl.size() - 1:
		var A := pl[i]
		var B := pl[i + 1]
		var Ls := A.distance_to(B)
		var dv := (B - A) / Ls
		var o := IstSehir._out(dv, (A + B) * 0.5, ad)
		for r: Array in ara:
			var u0 := maxf(float(r[0]), float(S[i])) - float(S[i])
			var u1 := minf(float(r[1]), float(S[i + 1])) - float(S[i])
			if u1 - u0 < 0.5:
				continue
			# iç kırıklarda gönye payı (bant komşu bandın kesitine kadar uzar; yalnız aralığın içindeki uçlarda)
			if u0 < 0.01 and i > 0 and float(r[0]) < float(S[i]) - 0.5:
				var dp := (A - pl[i - 1]).normalized()
				u0 -= minf(25.0, c1 * tan(absf(dp.angle_to(dv)) * 0.5) + 1.5)
			if u1 > Ls - 0.01 and i < pl.size() - 2 and float(r[1]) > float(S[i + 1]) + 0.5:
				var dn := (pl[i + 2] - B).normalized()
				u1 += minf(25.0, c1 * tan(absf(dv.angle_to(dn)) * 0.5) + 1.5)
			var bnt := [A, dv, o, u0, u1, c0, c1]
			bantlar.append(bnt)
			_izg_ekle(_bizg, bantlar.size() - 1, _dikd(bnt))


## (x, z) sur kuşağında mı: iç sur şehir yüzünden pay m içeri … hendek dış kıyısından pay_dis m dışarı (varsayılan pay)
static func kusakta(x: float, z: float, pay := 12.0, pay_dis := -1.0) -> bool:
	var l = _kizg.get(Vector2i(floori(x / IZG), floori(z / IZG)))
	if l == null:
		return false
	if pay_dis < 0.0:
		pay_dis = pay
	var q := Vector2(x, z)
	var zi0 := float(IstSurlar.dims(K_SUR)["zi0"])
	for idx: int in l:
		var b: Array = kusak[idx]
		var v := q - (b[0] as Vector2)
		var u := v.dot(b[1])
		var c := v.dot(b[2])
		if u >= float(b[3]) and u <= float(b[4]) and c >= zi0 - pay and c <= float(b[6]) + pay_dis:
			return true
	return false


## Sur dibi rengi ağırlığı ve rengi: (renk, ağırlık 0..1). Ağırlık 1: arazinin rengi tamamen sur kuşağının (taş tozu,
## çıplak / çiğnenmiş toprak, ot lekeleri); kuşak dışına doğru doğal renge yumuşak geçer.
static func renk(x: float, z: float) -> Array:
	var l = _kizg.get(Vector2i(floori(x / IZG), floori(z / IZG)))
	if l == null:
		return [Color.BLACK, 0.0]
	var q := Vector2(x, z)
	var d := IstSurlar.dims(K_SUR)
	var best := INF
	var w := 0.0
	var c_en := 0.0
	var dis_c := 0.0
	for idx: int in l:
		var b: Array = kusak[idx]
		var v := q - (b[0] as Vector2)
		var u := v.dot(b[1])
		var c := v.dot(b[2])
		if u < float(b[3]) - 6.0 or u > float(b[4]) + 6.0:
			continue
		# çekirdek: şehir yüzünden 8 m içeri … hendek dış kıyısından 6 m (tam kuşak rengi); dışında ateş alanı
		var lo := float(d["zi0"]) - 8.0
		var hi := float(b[6]) + 6.0
		var dis := maxf(lo - c, c - hi)
		if c > hi:
			dis = 0.0 if c < float(b[6]) + ATES else c - float(b[6]) - ATES
		if dis < best:
			best = dis
			c_en = c
			dis_c = c - float(b[6])
	if best == INF:
		return [Color.BLACK, 0.0]
	w = clampf(1.0 - best / 8.0, 0.0, 1.0)
	if w <= 0.0:
		return [Color.BLACK, 0.0]
	# TUR-6: üçüncü öğe çıplaklık (zemin_v2: 1 ezilmiş toprak). Hendek omzu 0–8 m: ot seyrelir, çıplak toprak, moloz,
	# ayak izi (jilet gibi biten çimen yok); ateş alanı çiğnenmiş (top, asker, at); sur dibi çıplak.
	var n3 := _gur(x + 71.0, z - 5.0, 0.19)
	if dis_c > 6.0:
		# ateş alanı: çiğnenmiş toprak, ot lekeleri, ~25 m'de devriye izi; dışa doğru doğal renge (ağırlık 0,75 → 0)
		var wa := w * 0.8 * clampf(1.0 - (dis_c - ATES + 10.0) / 18.0, 0.0, 1.0)
		return [_ates_renk(x, z, dis_c), wa, clampf(0.62 + (n3 - 0.5) * 0.5 + clampf(1.0 - (dis_c - 6.0) / 10.0, 0.0, 1.0) * 0.25, 0.3, 0.95)]
	var cp := 0.92
	if dis_c > -1.0:
		# hendek dış omzu (0 … 6 m): kıyıda tamamen çıplak, dışa doğru ot öbekleri (düzensiz kenar)
		cp = clampf(1.0 - maxf(dis_c, 0.0) / 9.0 * (0.4 + n3 * 0.6), 0.55, 1.0)
	elif _yuz_uzak(c_en) > 4.0:
		cp = clampf(0.62 + (n3 - 0.5) * 0.6, 0.35, 0.9)       # peribolos / teras ortası: yer yer ot
	return [_kusak_renk(x, z, c_en), w, cp]


static func _ates_renk(x: float, z: float, dc: float) -> Color:
	var n1 := _gur(x, z, 0.07)
	var n2 := _gur(x - 13.0, z + 29.0, 0.23)
	var col := R_TOPRAK.lerp(R_OT, clampf(0.05 + n1 * 0.55 + dc / ATES * 0.3, 0.0, 0.6))
	var iz := clampf(1.0 - absf(dc - 25.0) / 3.5, 0.0, 1.0)
	col = col.lerp(R_KOYU, iz * 0.5)
	if n2 > 0.78:
		col = col.lerp(Color("4e4438"), (n2 - 0.78) * 2.5)
	return col


## Duvar yüzlerinden uzaklık (yerel kesit c): iç sur iki yüzü, dış sur iki yüzü
static func _yuz_uzak(c: float) -> float:
	var d := IstSurlar.dims(K_SUR)
	var m := INF
	for f: float in [float(d["zi0"]), float(d["zi1"]), float(d["zo0"]), float(d["zo1"])]:
		m = minf(m, absf(c - f))
	if c > float(d["zi0"]) and c < float(d["zi1"]) or c > float(d["zo0"]) and c < float(d["zo1"]):
		m = 0.0
	return m


static func _gur(x: float, z: float, f: float) -> float:
	# düşük frekanslı değer gürültüsü (0..1)
	var gx := x * f
	var gz := z * f
	var ix := floori(gx)
	var iz := floori(gz)
	var fx := gx - ix
	var fz := gz - iz
	fx = fx * fx * (3.0 - 2.0 * fx)
	fz = fz * fz * (3.0 - 2.0 * fz)
	var a := _h2(ix, iz)
	var b := _h2(ix + 1, iz)
	var c := _h2(ix, iz + 1)
	var e := _h2(ix + 1, iz + 1)
	return lerpf(lerpf(a, b, fx), lerpf(c, e, fx), fz)


static func _h2(i: int, j: int) -> float:
	var h := (i * 374761393 + j * 668265263) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return float(h & 0xffff) / 65535.0


const R_TOZ := Color("a08a68")        # taş tozu (kireç harcı + kumtaşı kırığı)
const R_TOPRAK := Color("94784f")     # çıplak / çiğnenmiş toprak
const R_KOYU := Color("6e5a40")       # nemli toprak, çamur
const R_OT := Color("7a8a45")         # seyrek, tozlu ot
const R_OT2 := Color("8e9450")

static func _kusak_renk(x: float, z: float, c: float) -> Color:
	var yz := _yuz_uzak(c)
	var n1 := _gur(x, z, 0.11)
	var n2 := _gur(x + 37.0, z - 11.0, 0.29)
	# temel: çiğnenmiş toprak + ot lekeleri (peribolos ve teras sıkışmış toprak/ot)
	var col := R_TOPRAK.lerp(R_OT, clampf(0.25 + (n1 - 0.4) * 1.5, 0.0, 0.7))
	col = col.lerp(R_OT2, clampf((n2 - 0.6) * 2.0, 0.0, 0.5))
	# sur dibine yaklaşınca taş tozu ve çıplak toprak (0–6 m)
	var t := clampf(1.0 - yz / 6.0, 0.0, 1.0)
	col = col.lerp(R_TOZ.lerp(R_TOPRAK, n2 * 0.6), t * t * (3.0 - 2.0 * t) * 0.75)
	# nemli çamur lekeleri
	if n2 > 0.72:
		col = col.lerp(R_KOYU, (n2 - 0.72) * 2.5)
	return col


## ------------------------------------------------------------------ arazi ağı kırpma (IstDunya)

## Dörtgen (dünya xz dikdörtgeni) hendek bandına değiyor mu (aday bant dizinleri; boşsa değmiyor)
static func adaylar(x0: float, z0: float, x1: float, z1: float) -> Array:
	if bantlar.is_empty():
		return []
	var o: Array = []
	for cx in range(floori(x0 / IZG), floori(x1 / IZG) + 1):
		for cz in range(floori(z0 / IZG), floori(z1 / IZG) + 1):
			var l = _bizg.get(Vector2i(cx, cz))
			if l == null:
				continue
			for idx: int in l:
				if not o.has(idx):
					o.append(idx)
	return o


## Nokta hendek bandının içinde mi
static func bant_ici(x: float, z: float) -> bool:
	var l = _bizg.get(Vector2i(floori(x / IZG), floori(z / IZG)))
	if l == null:
		return false
	var q := Vector2(x, z)
	for idx: int in l:
		var b: Array = bantlar[idx]
		var v := q - (b[0] as Vector2)
		var u := v.dot(b[1])
		var c := v.dot(b[2])
		if u > float(b[3]) and u < float(b[4]) and c > float(b[5]) and c < float(b[6]):
			return true
	return false


## Dışbükey çokgeni (dünya xz noktaları, köşe dizinleri) yarım düzlemle böler: f(p) = p·n − k; içeride f ≤ 0 kalan parça
## ve dışarıda f > 0 kalan parça. Kesişimlerde yeni köşe (ek) çağrılır.
static func _bol(poly: Array, n: Vector2, k: float, ek: Callable) -> Array:
	var ic: Array = []
	var dis: Array = []
	var m := poly.size()
	for i in m:
		var a: Array = poly[i]
		var b: Array = poly[(i + 1) % m]
		var fa := (a[1] as Vector2).dot(n) - k
		var fb := (b[1] as Vector2).dot(n) - k
		if fa <= 0.0:
			ic.append(a)
		else:
			dis.append(a)
		if (fa <= 0.0) != (fb <= 0.0):
			var t := fa / (fa - fb)
			var v: Array = ek.call(a, b, t)
			ic.append(v)
			dis.append(v)
	return [ic, dis]


## Üçgeni (köşe: [dizin, xz]) aday bantlardan çıkarır; dönen: kalan dışbükey çokgenler. ek(a, b, t) → yeni köşe [dizin, xz]
static func kes_ucgen(tri: Array, aday: Array, ek: Callable) -> Array:
	var parcalar: Array = [tri]
	for idx: int in aday:
		var b: Array = bantlar[idx]
		var A: Vector2 = b[0]
		var dv: Vector2 = b[1]
		var o: Vector2 = b[2]
		var yeni: Array = []
		for pc: Array in parcalar:
			if pc.size() < 3:
				continue
			# hızlı ret: bandın dikdörtgeniyle kesişmiyorsa olduğu gibi
			var umin := INF
			var umax := -INF
			var cmin := INF
			var cmax := -INF
			for v: Array in pc:
				var q: Vector2 = (v[1] as Vector2) - A
				var u := q.dot(dv)
				var c := q.dot(o)
				umin = minf(umin, u)
				umax = maxf(umax, u)
				cmin = minf(cmin, c)
				cmax = maxf(cmax, c)
			if umax <= float(b[3]) or umin >= float(b[4]) or cmax <= float(b[5]) or cmin >= float(b[6]):
				yeni.append(pc)
				continue
			# dört yarım düzlem: c < c0 | c > c1 | u < t0 | u > t1 parçaları kalır; dikdörtgenin içi atılır
			var kalan := pc
			var hp := [[-o, -float(b[5]) - A.dot(o)], [o, float(b[6]) + A.dot(o)], [-dv, -float(b[3]) - A.dot(dv)], [dv, float(b[4]) + A.dot(dv)]]
			for h: Array in hp:
				if kalan.size() < 3:
					break
				# f = p·n − k > 0: bandın dışında kalan taraf (n dışa bakar)
				var r := _bol(kalan, h[0], float(h[1]), ek)
				if (r[1] as Array).size() >= 3:
					yeni.append(r[1])
				kalan = r[0]
		parcalar = yeni
	return parcalar
