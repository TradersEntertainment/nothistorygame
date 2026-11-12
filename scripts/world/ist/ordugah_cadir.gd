extends RefCounted
## ORDUGÂH-5: KUMAŞ çadır ağları (docs/ORDUGAH_1453.md §2.2 tür tablosu, §2.3 ip-kazık, §2.5 renk). Kulübe değil:
##   - çatı direk tepesinden duvar direklerine SARKAR (içbükey kesit, düz piramit yok), direkler arasında saçak çöker,
##     çatı panelleri ayrı ayrı (dikiş: panel başına ayrı normal ve ton), yer yer yama ve su lekesi;
##   - saçak taraklı (direkler arası kavisli alt kenar), saçakta ince renk şeridi (türe göre; kırmızı yalnız paşa/otağ);
##   - duvar eteği yere yakın gevşek ve dalgalı, alt şerit çamur lekeli;
##   - her duvar direğinden yere 45° gergi ipi ve kazık; orta direk tepede çıkar, ucunda topuz/alem (BACA YOK);
##   - kapı: bir perde yana toplanıp bağlanmış, öbürü yarı açık sarkar; içerisi karanlık ama derinlikli (iç yüzler koyu,
##     yerde kilim, minder, sandık, orta direk).
## Yakın ağ ≤ 900, orta ≤ 120, uzak ≤ 40 üçgen (ORDUGÂH-5 görev E). Bütün ağlar birim ölçekte: yuvarlaklar yarıçap 1
## (örnek ölçeği x,z = yarıçap m), dikdörtgenler ±0,5 (ölçek = boy, en); y metre (ölçek = boy katsayısı). Taban y 0,1
## (çağıranlar örneği zeminin 0,1 m altına koyar). Kapı +z yönünde. Köşe rengi örnek rengiyle çarpılır (bez beyaza yakın).
## class_name YOK (ortak kural): preload ile erişilir.

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const B = K.Bld

const ZEMIN := 0.1
const IPC := Color(0.62, 0.55, 0.42)          # kenevir ip
const KAZIK := Color(0.42, 0.32, 0.22)
const DIREK := Color(0.45, 0.34, 0.22)
const PIRINC := Color(0.86, 0.7, 0.36)       # topuz/alem (küre; hilal YOK)
const IC := 0.34                             # iç yüzlerin karanlığı

static var _cache := {}


## Tür adları: "koni", "can", "catma", "buyuk", "pasa", "kil", "barinak"; katman öneki: "" yakın, "orta_", "uzak_"
static func mesh(kind: String) -> ArrayMesh:
	if _cache.has(kind):
		return _cache[kind]
	var b := B.new()
	var lod := 0
	var k := kind
	if k.begins_with("orta_"):
		lod = 1
		k = k.substr(5)
	elif k.begins_with("uzak_"):
		lod = 2
		k = k.substr(5)
	var o := _tur(k, lod)
	if k == "barinak":
		_barinak(b, lod)
	else:
		_govde(b, o, lod)
		if k == "pasa" and lod <= 1:
			_sayeban(b, o, lod)
	var m := K.bld_mesh(b)
	_cache[kind] = m
	return m


static func tris(kind: String) -> int:
	return K.mesh_tris(mesh(kind))


## Tür parametreleri. ex/ez yarı boyutlar, m süperelips üssü (2 daire, 5–6 dikdörtgene yakın), direk: sırt direkleri x'leri,
## P duvar direği (panel), nc panel sütunu, nr çatı halkası, hw duvar boyu, H direk tepesi, rs sırt sarkması, sp çatı
## sarkma üssü, es saçak çökmesi, ov saçak taşması, val saçak boyu, serit saçak şeridi rengi, bez ana bez rengi,
## ip ip boyu (birim, dışa), acik ön yüz açık (kıl çadırı).
static func _tur(k: String, lod: int) -> Dictionary:
	var o := {"ex": 1.0, "ez": 1.0, "m": 2.0, "direk": [0.0], "P": 10, "nc": 3, "nr": 4, "hw": 0.95, "H": 2.85, "rs": 0.0,
		"sp": 1.55, "es": 0.11, "ov": 0.04, "val": 0.14, "serit": Color(0.55, 0.45, 0.32), "bez": Color(0.97, 0.95, 0.9),
		"ip": 0.42, "acik": false, "kapi": true, "skal": 2, "sx": 2.4, "sz": 2.4}
	match k:
		"koni":
			o.merge({"nc": 2, "skal": 1}, true)
		"can":
			o.merge({"P": 12, "nc": 2, "hw": 1.45, "H": 3.25, "sp": 1.35, "nr": 4, "es": 0.09, "ov": 0.07, "val": 0.3,
				"serit": Color(0.32, 0.38, 0.55), "skal": 1}, true)
		"catma":
			o.merge({"ex": 0.5, "ez": 0.5, "m": 5.0, "direk": [-0.3, 0.3], "P": 10, "nc": 2, "nr": 4, "hw": 0.85, "H": 2.05,
				"rs": 0.12, "sp": 1.3, "es": 0.08, "ov": 0.03, "val": 0.1, "ip": 0.16, "sx": 5.0, "sz": 3.6}, true)
		"buyuk":
			o.merge({"ex": 0.5, "ez": 0.5, "m": 2.6, "direk": [-0.2, 0.2], "P": 12, "nc": 2, "nr": 4, "hw": 1.5, "H": 3.6,
				"rs": 0.14, "sp": 1.4, "es": 0.1, "ov": 0.06, "val": 0.32, "serit": Color(0.3, 0.36, 0.52), "ip": 0.17, "skal": 1, "sx": 8.0, "sz": 5.5}, true)
		"pasa":
			o.merge({"ex": 0.5, "ez": 0.5, "m": 2.8, "direk": [-0.3, 0.0, 0.3], "P": 10, "nc": 2, "nr": 3, "hw": 1.9, "H": 4.5,
				"rs": 0.3, "sp": 1.4, "es": 0.1, "ov": 0.05, "val": 0.4, "serit": Color(0.84, 0.66, 0.24),
				"bez": Color(0.62, 0.16, 0.15), "ip": 0.12, "skal": 1, "sx": 12.0, "sz": 8.0}, true)
		"kil":
			o.merge({"ex": 0.5, "ez": 0.5, "m": 6.0, "direk": [-0.4, -0.13, 0.13, 0.4], "P": 12, "nc": 2, "nr": 3, "hw": 0.7,
				"H": 1.75, "rs": 0.38, "sp": 1.1, "es": 0.12, "ov": 0.02, "val": 0.0, "bez": Color(0.3, 0.25, 0.21), "ip": 0.22,
				"acik": true, "kapi": false, "sx": 7.0, "sz": 3.8, "topuz": false}, true)
	if lod == 1:
		o["P"] = 7 if float(o["ex"]) == float(o["ez"]) and o["direk"].size() == 1 else 8
		o["nc"] = 2 if o["direk"].size() == 1 else 1
		o["nr"] = 3 if o["direk"].size() == 1 else 3
		o["val"] = 0.0
	elif lod == 2:
		o["P"] = 5
		o["nc"] = 1
		o["nr"] = 2
		o["val"] = 0.0
	return o


# ------------------------------------------------------------------ yüzey yardımcıları (yumuşak normal)

## Tek üçgen: normaller dış yöne bakacak biçimde sarım (Bld.poly ile aynı: ön yüz, çapraz çarpım dışa ters)
static func _tri(b: B, a: Vector3, c1: Vector3, c2: Vector3, na: Vector3, n1: Vector3, n2: Vector3, col: Color) -> void:
	var cr := (c1 - a).cross(c2 - a)
	if cr.length_squared() < 1e-12:
		return
	if cr.dot(na + n1 + n2) < 0.0:
		b.v.append(a); b.v.append(c1); b.v.append(c2)
		b.n.append(na); b.n.append(n1); b.n.append(n2)
	else:
		b.v.append(a); b.v.append(c2); b.v.append(c1)
		b.n.append(na); b.n.append(n2); b.n.append(n1)
	b.c.append(col); b.c.append(col); b.c.append(col)
	b.tris += 1


## Izgara: G[i][j] (i satır, j sütun). colf(i, j) dörtgen rengi. ref(p) dış yön. ic = içe bakan yüz (normal ters).
static func _grid(b: B, G: Array, colf: Callable, ref: Callable, ic := false) -> void:
	var R := G.size()
	var C := (G[0] as Array).size()
	var N: Array = []
	for i in R:
		var row: Array = []
		for j in C:
			var p: Vector3 = G[i][j]
			var du: Vector3 = (G[mini(i + 1, R - 1)][j] as Vector3) - (G[maxi(i - 1, 0)][j] as Vector3)
			var dv: Vector3 = (G[i][mini(j + 1, C - 1)] as Vector3) - (G[i][maxi(j - 1, 0)] as Vector3)
			var nn := du.cross(dv)
			var rf: Vector3 = ref.call(p)
			if nn.length_squared() < 1e-10:
				nn = rf
			nn = nn.normalized()
			if nn.dot(rf) < 0.0:
				nn = -nn
			row.append(-nn if ic else nn)
		N.append(row)
	for i in R - 1:
		for j in C - 1:
			var col: Color = colf.call(i, j)
			_tri(b, G[i][j], G[i + 1][j], G[i + 1][j + 1], N[i][j], N[i + 1][j], N[i + 1][j + 1], col)
			_tri(b, G[i][j], G[i + 1][j + 1], G[i][j + 1], N[i][j], N[i + 1][j + 1], N[i][j + 1], col)


## İnce ip/direk: üçgen kesitli ince prizma (her yönden görünür, 6 üçgen)
static func _ip(b: B, p0: Vector3, p1: Vector3, w: float, col: Color, sx := 1.0, sz := 1.0) -> void:
	var d := (p1 - p0).normalized()
	var s1 := d.cross(Vector3.UP).normalized()
	if s1.length_squared() < 1e-8:
		s1 = Vector3(1, 0, 0)
	var s2 := d.cross(s1).normalized()
	var o: Array = []
	for i in 3:
		var a := TAU * i / 3.0
		var oo := (s1 * cos(a) + s2 * sin(a)) * w
		o.append(Vector3(oo.x / sx, oo.y, oo.z / sz))
	for i in 3:
		var j := (i + 1) % 3
		var oi: Vector3 = o[i]
		var oj: Vector3 = o[j]
		b.poly([p0 + oi, p1 + oi, p1 + oj, p0 + oj], (oi + oj) * 0.5, col)


## Eşit olmayan örnek ölçeğini dengeleyen ince çubuk (metre yarıçap r; sx, sz: birim başına metre)
static func _cubuk(b: B, p0: Vector3, p1: Vector3, r: float, sx: float, sz: float, col: Color, n := 5, r1 := -1.0) -> void:
	if r1 < 0.0:
		r1 = r
	var d := (p1 - p0).normalized()
	var u := d.cross(Vector3.UP if absf(d.y) < 0.9 else Vector3.RIGHT).normalized()
	var w := d.cross(u).normalized()
	var A: Array = []
	var Bq: Array = []
	for i in n:
		var a := TAU * i / n
		var o := u * cos(a) + w * sin(a)
		var e := Vector3(o.x / sx, o.y, o.z / sz)
		A.append(p0 + e * r)
		Bq.append(p1 + e * r1)
	for i in n:
		var j := (i + 1) % n
		var mid := ((A[i] as Vector3) + (A[j] as Vector3)) * 0.5 - p0
		b.poly([A[i], A[j], Bq[j], Bq[i]], Vector3(mid.x * sx * sx, mid.y, mid.z * sz * sz), col.darkened(0.06 * (i % 2)))


## Kazık: üç yüzlü sivri, yere eğik çakılı
static func _kazik(b: B, p: Vector3, dis: Vector3, sx: float, sz: float) -> void:
	var tip := p + Vector3(0, -0.02, 0)
	var top := p + Vector3(0, 0.12, 0) - Vector3(dis.x * 0.08 / sx, 0, dis.z * 0.08 / sz)
	var r := 0.035
	var q: Array = []
	for i in 3:
		var a := TAU * i / 3.0
		q.append(top + Vector3(cos(a) * r / sx, 0, sin(a) * r / sz))
	for i in 3:
		var j := (i + 1) % 3
		var mid := ((q[i] as Vector3) + (q[j] as Vector3)) * 0.5 - top
		b.poly([q[i], q[j], tip], mid + Vector3(0, 0.0, 0), KAZIK.darkened(0.08 * i))


# ------------------------------------------------------------------ gövde (yuvarlak ve sırtlı çadırlar)

static func _sg(x: float, e: float) -> float:
	return signf(x) * pow(absf(x), e)


## Çevre noktası (yay uzunluğuna göre eşit aralıklı): s ∈ [0,1), s = 0,25 kapı ortası (+z)
static func _cevre_tablo(o: Dictionary) -> Array:
	var key := "%s|%s|%s" % [o["ex"], o["ez"], o["m"]]
	var ck := "cevre|" + key
	if _cache.has(ck):
		return _cache[ck]
	var n := 256
	var pts: Array = []
	var cum: Array = [0.0]
	var e := 2.0 / float(o["m"])
	for i in n + 1:
		var a := TAU * i / n
		pts.append(Vector2(float(o["ex"]) * _sg(cos(a), e), float(o["ez"]) * _sg(sin(a), e)))
		if i > 0:
			cum.append(float(cum[i - 1]) + (pts[i] as Vector2).distance_to(pts[i - 1]))
	var t := [pts, cum]
	_cache[ck] = t
	return t


static func _cevre(o: Dictionary, s: float) -> Vector2:
	var t := _cevre_tablo(o)
	var pts: Array = t[0]
	var cum: Array = t[1]
	var L: float = cum[cum.size() - 1]
	var x := fposmod(s, 1.0) * L
	var lo := 0
	var hi := cum.size() - 1
	while hi - lo > 1:
		var mid := (lo + hi) / 2
		if float(cum[mid]) <= x:
			lo = mid
		else:
			hi = mid
	var f := (x - float(cum[lo])) / maxf(float(cum[hi]) - float(cum[lo]), 1e-6)
	return (pts[lo] as Vector2).lerp(pts[hi], f)


## Sırt noktası (çevre noktasının en yakın sırt noktası) ve o noktada direk/sırt yüksekliği
static func _sirt(o: Dictionary, pe: Vector2) -> Vector3:
	var d: Array = o["direk"]
	var x0: float = d[0]
	var x1: float = d[d.size() - 1]
	var x := clampf(pe.x, x0, x1)
	var H: float = o["H"]
	var h := H
	if d.size() > 1:
		for i in d.size() - 1:
			var a: float = d[i]
			var c: float = d[i + 1]
			if x >= a and x <= c:
				h = H - float(o["rs"]) * sin(PI * (x - a) / maxf(c - a, 1e-4))
				break
	return Vector3(x, h, 0.0)


static func _govde(b: B, o: Dictionary, lod: int) -> void:
	var P: int = o["P"]
	var nc: int = o["nc"]
	var nr: int = o["nr"]
	var hw: float = o["hw"]
	var es: float = o["es"]
	var ov: float = o["ov"]
	var sp: float = o["sp"]
	var bez: Color = o["bez"]
	var acik: bool = o["acik"]
	var kapi: bool = o["kapi"] and lod == 0
	var r := K.rr(int(hash(str(o["ex"]) + str(o["H"]) + str(P))))
	var ref_cati := func(p: Vector3) -> Vector3:
		var s := _sirt(o, Vector2(p.x, p.z))
		return Vector3(p.x - s.x, 0.0, p.z) * 1.4 + Vector3(0, 1.0, 0)
	var ref_duvar := func(p: Vector3) -> Vector3:
		var s := _sirt(o, Vector2(p.x, p.z))
		return Vector3(p.x - s.x, 0.0, p.z)
	# yama ve leke seçimi (panel, halka, sütun)
	var yamalar := {}
	if lod == 0:
		for t in 5:
			yamalar[Vector3i(r.randi() % P, 1 + r.randi() % maxi(nr - 2, 1), r.randi() % nc)] = [Color(1.04, 1.02, 0.95), Color(0.86, 0.8, 0.7), Color(0.92, 0.9, 0.84)][t % 3]
	for pj in P:
		var s0 := 0.25 + (pj - 0.5) / P
		var kapi_p := kapi and pj == 0
		var on_acik := false
		if acik:
			var pm := _cevre(o, s0 + 0.5 / P)
			on_acik = pm.y > float(o["ez"]) * 0.55
		# panel tonu: dikiş (komşu paneller ±%4), kıl çadırında açık dokuma şeritleri
		var pton := 1.0 + (0.035 if pj % 2 == 0 else -0.03) + r.randf_range(-0.015, 0.015)
		# --- çatı
		var G: Array = []
		for i in nr + 1:
			var t := float(i) / nr
			var row: Array = []
			for c in nc + 1:
				var f := float(c) / nc
				var s := s0 + f / P
				var pe := _cevre(o, s)
				var sr := _sirt(o, pe)
				var sv := Vector2(sr.x, sr.z)
				var dis := pe - sv
				var eave := sv + dis * (1.0 + ov)
				var cok := sin(PI * f)
				var ye := hw - es * cok + (0.1 if kapi_p else 0.0) + (0.25 if on_acik else 0.0)
				var q := eave.lerp(sv, t)
				q = sv + (q - sv) * (1.0 - 0.04 * cok * (1.0 - t))
				var y := ye + (sr.y - ye) * pow(t, sp) - 0.03 * cok * sin(PI * t)
				row.append(Vector3(q.x, y, q.y))
			G.append(row)
		var colf_cati := func(i: int, c: int) -> Color:
			var col := bez * pton
			if acik and c % 2 == 1:
				col = col.lerp(Color(0.62, 0.56, 0.46), 0.35)      # kıl çadırında açık dokuma şeridi
			var yk = yamalar.get(Vector3i(pj, i, c))
			if yk != null:
				col = Color(col.r * yk.r, col.g * yk.g, col.b * yk.b)
			# su lekesi: saçağa yakın halkalar hafif koyu (yağmur izi), panel ortasında daha çok
			if i == 0:
				col = col.darkened(0.06)
			return col
		_grid(b, G, colf_cati, ref_cati)
		if lod == 0:
			# çatının altı (iç): kaba, koyu; dış yüzün ALTINDA kalsın diye aşağı ve içe kaydırılmış (yoksa dış çatıya gölge
			# düşürür: ilk denemede çatılar kapkara göründü)
			var sat := [0, nr / 2, nr] if nr >= 4 else [0, nr]
			var Gi: Array = []
			for i: int in sat:
				var t2 := float(i) / nr
				var ust_row: Array = []
				for c: int in [0, nc]:
					var q2: Vector3 = G[i][c]
					var sr2 := _sirt(o, Vector2(q2.x, q2.z))
					var ic2 := Vector3(sr2.x, q2.y, 0.0) + (Vector3(q2.x, q2.y, q2.z) - Vector3(sr2.x, q2.y, 0.0)) * 0.95
					ust_row.append(ic2 - Vector3(0, 0.2 + 0.14 * t2, 0))
				Gi.append(ust_row)
			_grid(b, Gi, func(_i, _c): return bez * IC * 0.85, ref_cati, true)
		# --- saçak (taraklı alt kenar, üstte renk şeridi)
		var val: float = o["val"]
		if val > 0.0 and not on_acik:
			var skal: int = o["skal"]
			var nv := 2 * skal
			var Vt: Array = []
			var Vm: Array = []
			var Vb: Array = []
			for c in nv + 1:
				var f := float(c) / nv
				var pt: Vector3 = _cati_kenar(o, s0 + f / P, f, hw, es, ov, kapi_p)
				var dip := val * (0.55 + 0.45 * absf(cos(PI * f * skal)))
				Vt.append(pt + Vector3(0, 0.01, 0))
				Vm.append(pt - Vector3(0, val * 0.32, 0))
				Vb.append(pt - Vector3(0, dip, 0))
			var serit: Color = o["serit"]
			_grid(b, [Vt, Vm], func(_i, _c): return serit, ref_duvar)
			_grid(b, [Vm, Vb], func(_i, _c): return bez * pton * 0.97, ref_duvar)
		elif lod == 0 and float(o["ov"]) > 0.0 and not on_acik:
			pass
		# --- duvar (kapı panelinde yok; kıl çadırının ön yüzü açık)
		if kapi_p or on_acik:
			continue
		var wc := maxi(nc, 1)
		var W: Array = [[], [], []]
		for c in wc + 1:
			var f := float(c) / wc
			var s := s0 + f / P
			var pe := _cevre(o, s)
			var sr := _sirt(o, pe)
			var dis := (pe - Vector2(sr.x, sr.z)).normalized()
			var cok := sin(PI * f)
			var ust := hw - es * cok - 0.02
			var etek := 0.03 + 0.035 * cok + r.randf_range(0.0, 0.025)
			(W[0] as Array).append(Vector3(pe.x, ust, pe.y))
			var orta := pe + dis * 0.012 * cok
			(W[1] as Array).append(Vector3(orta.x, ust * 0.42, orta.y))
			var alt := pe + dis * etek
			(W[2] as Array).append(Vector3(alt.x, ZEMIN + 0.01 + 0.03 * cok, alt.y))
		if lod >= 1:
			W = [W[0], W[2]]
		var nW := W.size()
		_grid(b, W, func(i: int, c: int) -> Color:
			var col := bez * pton * (0.98 if c % 2 == 0 else 1.0)
			if i == nW - 2:
				col = col.lerp(Color(0.42, 0.34, 0.24), 0.28)      # etekte çamur lekesi
			return col, ref_duvar)
		if lod == 0:
			var ici := func(q3: Vector3, dy: float) -> Vector3:
				var sr3 := _sirt(o, Vector2(q3.x, q3.z))
				return Vector3(sr3.x, q3.y + dy, 0.0) + (q3 - Vector3(sr3.x, q3.y, 0.0)) * 0.95
			_grid(b, [[ici.call(W[0][0], -0.06), ici.call(W[0][wc], -0.06)], [ici.call(W[nW - 1][0], 0.0), ici.call(W[nW - 1][wc], 0.0)]], func(_i, _c): return bez * IC, ref_duvar, true)
	if lod >= 1:
		return
	# --- duvar direkleri, gergi ipleri, kazıklar
	var ipb: float = o["ip"]
	for pj in P:
		var s := 0.25 + (pj - 0.5) / P
		var pe := _cevre(o, s)
		var sr := _sirt(o, pe)
		var dis2 := pe - Vector2(sr.x, sr.z)
		var dn := dis2.normalized()
		var ust := hw + (0.1 if (kapi and (pj == 0 or pj == 1)) else 0.0)
		var top := Vector3(pe.x, ust + 0.06, pe.y)
		var osx: float = o["sx"]
		var osz: float = o["sz"]
		var dp := Vector3(dn.x * 0.025 / osx, 0, dn.y * 0.025 / osz)
		_cubuk(b, Vector3(pe.x, ZEMIN, pe.y) + dp, top + dp, 0.025, osx, osz, DIREK, 3)
		var stake := pe + dn * ipb
		var kp := Vector3(stake.x, ZEMIN, stake.y)
		_ip(b, top, kp + Vector3(0, 0.1, 0), 0.011, IPC, osx, osz)
		_kazik(b, kp, Vector3(dn.x, 0, dn.y), osx, osz)
	# --- orta direk(ler), topuz/alem
	for dx: float in o["direk"]:
		var hh := _sirt(o, Vector2(dx, 0)).y
		var dsx: float = o["sx"]
		var dsz: float = o["sz"]
		_cubuk(b, Vector3(dx, ZEMIN, 0), Vector3(dx, hh + 0.2, 0), 0.06, dsx, dsz, DIREK, 5, 0.05)
		_cubuk(b, Vector3(dx, hh - 0.02, 0), Vector3(dx, hh + 0.06, 0), 0.13, dsx, dsz, bez * 0.8, 6, 0.08)   # tepelik (bez yaka)
		if o.get("topuz", true):
			b.sph(Vector3(dx, hh + 0.27, 0), 1.0, PIRINC, 5, Vector3(0.075 / dsx, 0.11, 0.075 / dsz))       # topuz (küre; hilal YOK)
			_cubuk(b, Vector3(dx, hh + 0.36, 0), Vector3(dx, hh + 0.5, 0), 0.025, dsx, dsz, PIRINC, 4, 0.002)
	# --- kapı: yana toplanıp bağlanmış perde (sol), yarı açık sarkan perde (sağ); iç: kilim, minder, sandık
	if kapi:
		var sa := 0.25 - 0.5 / P
		var sb := 0.25 + 0.5 / P
		var pa := _cevre(o, sa + 0.05 / P)
		var pb := _cevre(o, sb)
		var hd := hw + 0.06
		# toplanmış perde: kalın, düzensiz kesitli bez rulosu
		var Rl: Array = []
		for i in 4:
			var y := lerpf(ZEMIN + 0.05, hd, i / 3.0)
			var rr := 0.032 + 0.014 * sin(i * 2.1) + (0.01 if i == 1 else 0.0)
			var ring: Array = []
			for c in 6:
				var a := TAU * c / 5.0
				ring.append(Vector3(pa.x + cos(a) * rr * 0.8, y, pa.y + 0.03 + sin(a) * rr * 0.6))
			Rl.append(ring)
		_grid(b, Rl, func(_i, _c): return bez * 0.93, func(p: Vector3) -> Vector3: return Vector3(p.x - pa.x, 0, p.z - pa.y - 0.03))
		var bag := Vector3(pa.x, hd * 0.55, pa.y + 0.03)
		_cubuk(b, bag - Vector3(0, 0.03, 0), bag + Vector3(0, 0.03, 0), 0.11, float(o["sx"]), float(o["sz"]), IPC.darkened(0.2), 6)
		# sarkan perde: üstten asılı, altta dışa açılmış, iki kıvrım
		var Pp: Array = []
		var pc := pb.lerp(_cevre(o, 0.25), 0.42)
		for i in 3:
			var y2 := lerpf(hd, ZEMIN + 0.18, i / 2.0)
			var row2: Array = []
			for c in 4:
				var f2 := c / 3.0
				var base := pb.lerp(pc, f2)
				var acil := 0.12 * (i / 2.0) * f2
				row2.append(Vector3(base.x + 0.0, y2, base.y + acil + 0.02 * sin(f2 * TAU * 1.5)))
			Pp.append(row2)
		_grid(b, Pp, func(_i, _c): return bez * 0.9, func(_p): return Vector3(0, 0.1, 1.0))
		var Pi: Array = []
		for row3: Array in Pp:
			var r3: Array = []
			for q4: Vector3 in row3:
				r3.append(q4 - Vector3(0, 0, 0.025))
			Pi.append(r3)
		_grid(b, Pi, func(_i, _c): return bez * IC, func(_p): return Vector3(0, 0.1, 1.0), true)
		# iç: kilim (kırmızı-lacivert, kenarlı), minderler, sandık
		var ex: float = o["ex"]
		var ez: float = o["ez"]
		var ky := ZEMIN + 0.012
		var tab: Array = []
		for i in 10:
			var pe2 := _cevre(o, float(i) / 10.0) * 0.96
			tab.append(Vector3(pe2.x, ZEMIN + 0.006, pe2.y))
		b.poly(tab, Vector3.UP, Color(0.36, 0.3, 0.22))
		b.poly([Vector3(-ex * 0.5, ky, -ez * 0.55), Vector3(ex * 0.5, ky, -ez * 0.55), Vector3(ex * 0.5, ky, ez * 0.55), Vector3(-ex * 0.5, ky, ez * 0.55)], Vector3.UP, Color(0.66, 0.5, 0.34))
		b.poly([Vector3(-ex * 0.42, ky + 0.004, -ez * 0.47), Vector3(ex * 0.42, ky + 0.004, -ez * 0.47), Vector3(ex * 0.42, ky + 0.004, ez * 0.47), Vector3(-ex * 0.42, ky + 0.004, ez * 0.47)], Vector3.UP, Color(0.5, 0.16, 0.13))
		b.poly([Vector3(-ex * 0.12, ky + 0.008, -ez * 0.2), Vector3(ex * 0.12, ky + 0.008, -ez * 0.2), Vector3(ex * 0.12, ky + 0.008, ez * 0.2), Vector3(-ex * 0.12, ky + 0.008, ez * 0.2)], Vector3.UP, Color(0.2, 0.24, 0.42))
		b.sph(Vector3(-ex * 0.42, ZEMIN + 0.1, -ez * 0.62), 0.12, Color(0.55, 0.22, 0.16), 5, Vector3(1.4, 0.7, 0.8))
		_sandik(b, Vector3(ex * 0.48, ZEMIN, -ez * 0.55), 0.16 / maxf(ex, 0.3), 0.22, 0.12 / maxf(ez, 0.3))
		b.sph(Vector3(-ex * 0.62, ZEMIN + 0.16, ez * 0.1), 0.1, Color(0.6, 0.48, 0.32), 4, Vector3(0.8, 1.5, 0.8))   # su kırbası


## Çatı kenarı noktası (saçak üst çizgisi)
static func _cati_kenar(o: Dictionary, s: float, f: float, hw: float, es: float, ov: float, kapi_p: bool) -> Vector3:
	var pe := _cevre(o, s)
	var sr := _sirt(o, pe)
	var sv := Vector2(sr.x, sr.z)
	var eave := sv + (pe - sv) * (1.0 + ov)
	var ye := hw - es * sin(PI * f) + (0.1 if kapi_p else 0.0)
	return Vector3(eave.x, ye, eave.y)


## Sandık: pahlı gövde + kapak + demir bant (kutu ama çıplak tek kutu değil)
static func _sandik(b: B, p: Vector3, sx: float, sy: float, sz: float) -> void:
	b.box(p + Vector3(0, sy * 0.45, 0), Vector3(sx, sy * 0.9, sz), Color(0.48, 0.32, 0.2))
	b.box(p + Vector3(0, sy * 0.95, 0), Vector3(sx * 1.04, sy * 0.14, sz * 1.04), Color(0.4, 0.26, 0.16))
	b.box(p + Vector3(0, sy * 0.5, 0), Vector3(sx * 1.02, sy * 0.08, sz * 1.02), Color(0.25, 0.24, 0.24))


## Paşa çadırının sayebânı: önde iki direkli, sarkık gölgelik, taraklı kırmızı-altın saçak, ipleri
static func _sayeban(b: B, o: Dictionary, lod: int) -> void:
	var w := 0.32
	var z0 := 0.49
	var z1 := 0.88
	var y0 := float(o["hw"]) + 0.55
	var y1 := float(o["hw"]) + 0.15
	var G: Array = []
	var nx := 4 if lod == 0 else 2
	var nz := 3 if lod == 0 else 1
	for i in nz + 1:
		var t := float(i) / nz
		var row: Array = []
		for c in nx + 1:
			var f := float(c) / nx
			var x := lerpf(-w, w, f)
			var y := lerpf(y0, y1, t) - 0.12 * sin(PI * f) * sin(PI * t) - 0.08 * sin(PI * f) * t
			row.append(Vector3(x, y, lerpf(z0, z1, t)))
		G.append(row)
	_grid(b, G, func(i: int, _c: int) -> Color: return Color(0.93, 0.88, 0.76) if i % 2 == 0 else Color(0.62, 0.16, 0.15), func(_p): return Vector3.UP)
	_grid(b, G, func(_i, _c): return Color(0.5, 0.45, 0.38), func(_p): return Vector3.UP, true)
	if lod >= 1:
		return
	var Vt: Array = []
	var Vb: Array = []
	for c in nx + 1:
		var f := float(c) / nx
		var p: Vector3 = G[nz][c]
		Vt.append(p)
		Vb.append(p - Vector3(0, 0.22 * (0.55 + 0.45 * absf(cos(PI * f * 3.0))), 0))
	_grid(b, [Vt, Vb], func(_i, _c): return Color(0.84, 0.66, 0.24), func(_p): return Vector3(0, 0, 1))
	_grid(b, [Vt, Vb], func(_i, _c): return Color(0.5, 0.14, 0.13), func(_p): return Vector3(0, 0, 1), true)
	for sx in [-w, w]:
		var top := Vector3(sx, y1 + 0.02, z1)
		_cubuk(b, Vector3(sx, ZEMIN, z1), Vector3(sx, y1 + 0.15, z1), 0.06, 12.0, 8.0, DIREK, 5)
		b.sph(top + Vector3(0, 0.2, 0), 1.0, PIRINC, 5, Vector3(0.07 / 12.0, 0.1, 0.07 / 8.0))
		var kp := Vector3(sx * 1.3, ZEMIN, z1 + 0.16)
		_ip(b, top, kp + Vector3(0, 0.1, 0), 0.011, IPC, 12.0, 8.0)
		_kazik(b, kp, Vector3(0, 0, 1), 12.0, 8.0)
	# sayebânın altında halı
	b.poly([Vector3(-w * 0.85, ZEMIN + 0.015, z0 + 0.02), Vector3(w * 0.85, ZEMIN + 0.015, z0 + 0.02), Vector3(w * 0.85, ZEMIN + 0.015, z1 - 0.04), Vector3(-w * 0.85, ZEMIN + 0.015, z1 - 0.04)], Vector3.UP, Color(0.2, 0.24, 0.45))


# ------------------------------------------------------------------ başıbozuk barınağı (çalı + yamalı örtü)

static func _barinak(b: B, lod: int) -> void:
	# birim: x ±0,5 boy, z ±0,5 derinlik; arka kenar yerde (z −0,5), ön kenar iki eğri direkte (y ≈ 1,15)
	var r := K.rr(4711)
	var nx := 4 if lod == 0 else 2
	var nz := 3 if lod == 0 else 1
	var G: Array = []
	for i in nz + 1:
		var t := float(i) / nz
		var row: Array = []
		for c in nx + 1:
			var f := float(c) / nx
			var x := lerpf(-0.5, 0.5, f)
			var y := lerpf(ZEMIN + 0.02, 1.15 - 0.12 * absf(f - 0.5), pow(t, 0.8)) - 0.13 * sin(PI * f) * sin(PI * t)
			row.append(Vector3(x + (0.03 * sin(i * 1.7 + c) if lod == 0 else 0.0), y, lerpf(-0.5, 0.42, t)))
		G.append(row)
	var renk := [Color(0.72, 0.64, 0.5), Color(0.55, 0.47, 0.36), Color(0.82, 0.76, 0.62), Color(0.62, 0.5, 0.42), Color(0.48, 0.44, 0.36)]
	var cols := {}
	for i in nz:
		for c in nx:
			cols[Vector2i(i, c)] = renk[r.randi() % renk.size()]
	_grid(b, G, func(i: int, c: int) -> Color: return cols.get(Vector2i(i, c), renk[0]), func(_p): return Vector3(0, 1, 0.6))
	if lod == 0:
		var Gb: Array = []
		for row5: Array in G:
			var r5: Array = []
			for q5: Vector3 in row5:
				r5.append(q5 - Vector3(0, 0.03, 0))
			Gb.append(r5)
		_grid(b, Gb, func(i: int, c: int) -> Color: return (cols.get(Vector2i(i, c), renk[0]) as Color) * 0.62, func(_p): return Vector3(0, 1, 0.6), true)
	if lod >= 2:
		return
	# yanlar: çalı-çırpı demetleri (yuvarlak öbekler; kutu yok)
	var cn := 3 if lod == 0 else 1
	for sx in [-0.5, 0.5]:
		for i in cn:
			var t := (i + 0.5) / cn
			var p := Vector3(sx * 0.95, ZEMIN + 0.18 + 0.25 * t, lerpf(-0.4, 0.3, t))
			b.sph(p, 0.22 - 0.04 * t, Color(0.36, 0.33, 0.2).lerp(Color(0.44, 0.38, 0.24), r.randf()), 5 if lod == 0 else 4, Vector3(0.5, 0.9, 1.3))
	if lod >= 1:
		return
	# ön direkler (eğri dal), dal uçları, önde ocak külü
	for sx in [-0.42, 0.42]:
		b.cylp(Vector3(sx, (ZEMIN + 1.15) * 0.5, 0.42), 0.022, 1.15 - ZEMIN, DIREK.darkened(0.1), 5, 0.016, Vector3(4 * signf(sx), 0, 3))
	for i in 4:
		var x0 := r.randf_range(-0.45, 0.45)
		var p0 := Vector3(x0, ZEMIN + 0.3 + r.randf() * 0.5, r.randf_range(-0.3, 0.2))
		b.cylp(p0, 0.008, 0.5, Color(0.36, 0.28, 0.18), 4, 0.004, Vector3(r.randf_range(-50, 50), 0, r.randf_range(-60, 60)))
	b.sph(Vector3(-0.2, ZEMIN + 0.08, -0.15), 0.12, Color(0.5, 0.42, 0.3), 5, Vector3(1.6, 0.6, 1.0))    # yatak (keçe rulosu)
	b.sph(Vector3(0.22, ZEMIN + 0.1, -0.05), 0.1, Color(0.62, 0.52, 0.34), 5, Vector3(1.0, 1.0, 1.0))    # torba
