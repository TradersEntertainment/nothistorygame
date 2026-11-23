extends RefCounted
## TAŞIMA 11: DENİZ SURU SETİ — ortak görünüş kalemi (çarpışmasız). Şehirdeki Haliç dilimi (IstHalicSur.build), SeaWalls
## (4b, 17, 19, 19o, 29, 29o), Haliç suru kesimi (18b, 38o) ve komşu devam (Horn._sea_wall, HornWorld._wall_run) AYNI
## işlevleri çağırır: deniz surunun görünüşünü burada değiştirmek hepsini birden değiştirir. Çarpışma her yerde eski
## kutulardır (bu dosya çarpışma KURMAZ); eski kutuların ağı gizlenir, gövde `wall` metası taşır (gizle()).
##
## Kalem (blak_set / Mesoteikhion dili; deniz suru sur_doku tur 1: kaba gri, moloz yamalı, seyrek hatıl, dipte yosun):
##   · gövde: su altına inen temel + su çizgisinde yosunlu kaide (0,3 m çıkıntı, pahlı üst), düz gövde; dış yüzde taş taş
##     ton farkı (onarım yaması: köşe rengi); kapı açıklıklarında söve iç yüzü, tavan, eşik taşı
##   · korkuluk (ince taş örgü: köşe alfası 0,9) + KULE.disler_ag dişleri (örülmüş gövde, eşek sırtı harpuşta) — diş adımı
##     ve fazı bölümün eski dişleriyle aynı
##   · konsol (sur yolu gövdeden denize taşıyorsa: 18b, 38o): yol taşının ön ve alt yüzü, kademeli taş bingiler
##   · kule: pahlı kare plan (pah 0: kule ayak izi oyuncunun yürüdüğü yerdeyse), su altına inen kaide, isteğe bağlı şev,
##     silme, ok yarıkları, üç kademe konsol, mazgallı teras (KULE._disler)
##   · rıhtım: kesme taş ön yüz (üstte ince örgülü kenar taşı sırası), döşeme (sur_doku yatay yüzü), yosunlu dip
##   · deniz kapısı: mermer söve ve lento, üstünde dönüşümlü tuğla/taş boşaltma kemeri, kör timpan
## Kesit sözlüğü g: zf (deniz yüzü z), s (deniz yönü: +1 deniz +z, −1 deniz −z), T (gövde kalınlığı), H (gövde tepesi y),
##   dip (temel dibi y; su altında), su (su y), lod (0 yakın, 1 orta, 2 uzak), kaide (çıkıntı, 0,3), kaide_y (su üstü, 0,45).
## class_name YOK (preload/load ile).

const SURKULE := preload("res://scripts/world/ist/sur_kule.gd")
const SURDOKU := preload("res://scripts/world/ist/sur_doku.gd")
const BLAK := preload("res://scripts/world/ist/blak_set.gd")

const TAS := Color("c9b89a")          # eski deniz suru taşı (SeaWalls, Haliç dilimi)
const ORGU := Color(1, 1, 1, 0.9)     # sur_doku: ince taş örgü (korkuluk, bingi, kenar taşı; TUR-11)
const MERMER := Color("d8d0bf")
const PT := 0.5                       # korkuluk kalınlığı (varsayılan)
const PH := 0.5                       # korkuluk yüksekliği (varsayılan)


static func _h(a: float, b: float, c: float) -> float:
	return fposmod(sin(a * 12.9898 + b * 78.233 + c * 37.719) * 43758.5453, 1.0)


## Taş taş ton (onarım yaması): hücrelerin %22'si 0,85–0,93 tonunda (köşe rengi; sur_doku taban rengiyle çarpar)
static func _ton(x: float, y: float, tohum: float) -> Color:
	var h := _h(floorf(x / 3.6), floorf(y / 3.1), tohum)
	if h < 0.22:
		var v := 0.85 + h * 0.36
		return Color(v, v * 0.985, v * 0.94)
	return Color.WHITE


static func _mat(lod: int, col := TAS) -> Material:
	return SURKULE._tas_mat(col, lod)


# ------------------------------------------------------------------ gövde

## Sur gövdesi x0…x1. acik: [{a, b, y0, y1}] gövdeyi baştan başa delen açıklıklar (kapı: a…b, eşik y0, tavan y1).
## g ek: "ic_dip" (kara yüzünün dibi; varsayılan dip), "ust" (tepe yüzü; konsol varsa false), "uclar" (uç yüzleri).
static func govde(n: Node3D, x0: float, x1: float, g: Dictionary, acik: Array = [], ad := "DenizSur") -> MeshInstance3D:
	var ag = SURKULE.Ag.new()
	var s: float = g["s"]
	var zf: float = g["zf"]
	var zb: float = zf - s * float(g["T"])
	var H: float = g["H"]
	var dip: float = g["dip"]
	var su: float = g["su"]
	var lod: int = g.get("lod", 0)
	var kd: float = g.get("kaide", 0.3)
	var ky: float = su + float(g.get("kaide_y", 0.45))
	var tohum: float = float(g.get("tohum", 11))
	var prof: Array = [[dip, kd], [ky, kd], [ky + 0.22, 0.0], [H, 0.0]]
	# yatay bantlar (ton hücreleri; uzakta tek bant)
	var ys: Array = []
	for p: Array in prof:
		ys.append(float(p[0]))
	if lod == 0:
		var yy := ky + 0.22 + 3.1
		while yy < H - 0.5:
			ys.append(yy)
			yy += 3.1
	for o: Dictionary in acik:
		ys.append(float(o["y0"]))
		ys.append(float(o["y1"]))
	ys.sort()
	var off := func(y: float) -> float:
		for k in prof.size() - 1:
			var ya: float = prof[k][0]
			var yb: float = prof[k + 1][0]
			if y <= yb + 1e-4:
				return lerpf(float(prof[k][1]), float(prof[k + 1][1]), clampf((y - ya) / maxf(yb - ya, 1e-4), 0.0, 1.0))
		return 0.0
	# x parçaları (ton hücreleri ve açıklık kenarları)
	var xs: Array = [x0, x1]
	var xx := x0 + 3.6
	if lod < 2:
		while xx < x1 - 0.5:
			xs.append(xx)
			xx += 3.6
	for o: Dictionary in acik:
		xs.append(clampf(float(o["a"]), x0, x1))
		xs.append(clampf(float(o["b"]), x0, x1))
	xs.sort()
	var ns := Vector3(0, 0, s)
	var ic_dip: float = g.get("ic_dip", dip)
	for i in xs.size() - 1:
		var xa: float = xs[i]
		var xb: float = xs[i + 1]
		if xb - xa < 0.01:
			continue
		var xm := (xa + xb) * 0.5
		var ac: Dictionary = {}
		for o: Dictionary in acik:
			if xm > float(o["a"]) and xm < float(o["b"]):
				ac = o
		for j in ys.size() - 1:
			var ya: float = ys[j]
			var yb: float = ys[j + 1]
			if yb - ya < 0.005:
				continue
			if not ac.is_empty() and ya >= float(ac["y0"]) - 1e-3 and yb <= float(ac["y1"]) + 1e-3:
				continue
			var col := _ton(xm, (ya + yb) * 0.5, tohum)
			var oa: float = off.call(ya)
			var ob: float = off.call(yb)
			var nrm := ns
			if absf(oa - ob) > 1e-4:
				nrm = Vector3(0, oa - ob, s * (yb - ya)).normalized()
			# deniz yüzü
			ag.quad(Vector3(xa, ya, zf + s * oa), Vector3(xb, ya, zf + s * oa), Vector3(xb, yb, zf + s * ob), Vector3(xa, yb, zf + s * ob), nrm, col)
			# kara yüzü (iç; düz)
			if yb > ic_dip:
				var yi := maxf(ya, ic_dip)
				ag.quad(Vector3(xa, yi, zb), Vector3(xb, yi, zb), Vector3(xb, yb, zb), Vector3(xa, yb, zb), -ns, col)
	# kaide üstü yatay kenar (kaidenin tepesi pahlı: yüz yukarı bakar, sarımda yer alır); tepe
	if g.get("ust", true):
		ag.quad(Vector3(x0, H, zf), Vector3(x1, H, zf), Vector3(x1, H, zb), Vector3(x0, H, zb), Vector3.UP)
	# uçlar (kesit çokgeni: kara dibi, kara tepesi, deniz tepesi, profil aşağı)
	if g.get("uclar", true):
		for sx: float in [-1.0, 1.0]:
			var xe := x1 if sx > 0.0 else x0
			var pol: Array = [Vector2(zb, ic_dip), Vector2(zb, H), Vector2(zf, H)]
			for k in range(prof.size() - 1, -1, -1):
				pol.append(Vector2(zf + s * float(prof[k][1]), float(prof[k][0])))
			var c := Vector2.ZERO
			for p: Vector2 in pol:
				c += p
			c /= pol.size()
			for k in pol.size():
				var p0: Vector2 = pol[k]
				var p1: Vector2 = pol[(k + 1) % pol.size()]
				ag.tri(Vector3(xe, c.y, c.x), Vector3(xe, p0.y, p0.x), Vector3(xe, p1.y, p1.x), Vector3(sx, 0, 0))
	# açıklıklar: söve iç yüzleri, tavan, eşik
	for o: Dictionary in acik:
		var a: float = o["a"]
		var b: float = o["b"]
		var y0: float = o["y0"]
		var y1: float = o["y1"]
		ag.quad(Vector3(a, y0, zf), Vector3(a, y0, zb), Vector3(a, y1, zb), Vector3(a, y1, zf), Vector3.RIGHT)
		ag.quad(Vector3(b, y0, zf), Vector3(b, y0, zb), Vector3(b, y1, zb), Vector3(b, y1, zf), Vector3.LEFT)
		ag.quad(Vector3(a, y1, zf), Vector3(b, y1, zf), Vector3(b, y1, zb), Vector3(a, y1, zb), Vector3.DOWN)
		if o.get("esik", true):
			ag.quad(Vector3(a, y0 + 0.004, zf + s * 0.1), Vector3(b, y0 + 0.004, zf + s * 0.1), Vector3(b, y0 + 0.004, zb), Vector3(a, y0 + 0.004, zb), Vector3.UP, ORGU)
	return ag.mesh_ekle(n, _mat(lod, g.get("tas", TAS)), ad)


# ------------------------------------------------------------------ korkuluk, dişler, konsol

## Korkuluk: deniz kenarında; dış yüzü kz (g "kz"), s yönünde dışa; taban y (g "yol"), PT kalın, PH yüksek. kes: açık
## x aralıkları (Vector2: merdivenin mazgalı).
static func korkuluk(n: Node3D, x0: float, x1: float, g: Dictionary, kes: Array = [], ad := "DenizKorkuluk") -> MeshInstance3D:
	var ag = SURKULE.Ag.new()
	var s: float = g["s"]
	var kz: float = g["kz"]
	var pt: float = g.get("PT", PT)
	var ph: float = g.get("PH", PH)
	var y: float = g["yol"]
	var parca: Array = [Vector2(x0, x1)]
	for k: Vector2 in kes:
		var yeni: Array = []
		for p: Vector2 in parca:
			if k.y <= p.x or k.x >= p.y:
				yeni.append(p)
				continue
			if k.x > p.x:
				yeni.append(Vector2(p.x, k.x))
			if k.y < p.y:
				yeni.append(Vector2(k.y, p.y))
		parca = yeni
	for p: Vector2 in parca:
		if p.y - p.x < 0.05:
			continue
		ag.kutu(Vector3((p.x + p.y) * 0.5, y, kz - s * pt), Vector3.RIGHT, Vector3(0, 0, s), p.y - p.x, ph, pt, ORGU)
	return ag.mesh_ekle(n, _mat(g.get("lod", 0), g.get("tas", TAS)), ad)


## Dişler korkuluğun üstünde: xs merkezler (bölümün eski diş dizisi), en, boy (korkuluk üstünden). Çarpışmasız.
static func disler(n: Node3D, xs: Array, en: float, boy: float, g: Dictionary, tohum: int) -> void:
	var s: float = g["s"]
	var kz: float = g["kz"]
	var pt: float = g.get("PT", PT)
	var ph: float = g.get("PH", PH)
	var y: float = g["yol"]
	var mer: Array = []
	for x: float in xs:
		mer.append(Transform3D(Basis.from_scale(Vector3(en, boy, pt)), Vector3(x, y + ph + boy * 0.5, kz - s * pt * 0.5)))
	if not mer.is_empty():
		SURKULE.disler_ag(n, mer, (g.get("tas", TAS) as Color).darkened(0.04), tohum)


## Diş dizisi: x0'dan adımla x1'e (eski dizinin yerleri); bos: dişin kurulmadığı x aralıkları (Vector2; kule, merdiven).
static func dis_dizisi(x0: float, adim: float, x1: float, en: float, bos: Array = []) -> Array:
	var out: Array = []
	var x := x0
	while x <= x1 + 1e-3:
		var ac := false
		for b: Vector2 in bos:
			if x + en * 0.5 > b.x + 0.01 and x - en * 0.5 < b.y - 0.01:
				ac = true
		if not ac:
			out.append(x)
		x += adim
	return out


## Konsol: sur yolu gövdenin deniz yüzünden (zf) zk'ye taşar; yol taşı yk…yt. Yol yüzü (yt) zk'den kara yüzüne (g "zy")
## kadar; ön ve alt yüz; kademeli taş bingiler (xs; dört sıra, 0,3 m, çıkıntı 0,22 → 1,0 × taşma). Çarpışmasız.
static func konsol(n: Node3D, x0: float, x1: float, g: Dictionary, xs: Array, ad := "DenizKonsol") -> MeshInstance3D:
	var ag = SURKULE.Ag.new()
	var s: float = g["s"]
	var zf: float = g["zf"]
	var zk: float = g["zk"]
	var zy: float = g["zy"]
	var yk: float = g["yk"]
	var yt: float = g["yt"]
	var ov := absf(zk - zf)
	var ns := Vector3(0, 0, s)
	# yol yüzü (döşeme: sur_doku yatay), ön yüz (yol taşı sırası: ince örgü), alt yüz, uçlar
	ag.quad(Vector3(x0, yt, zk), Vector3(x1, yt, zk), Vector3(x1, yt, zy), Vector3(x0, yt, zy), Vector3.UP)
	ag.quad(Vector3(x0, yk, zk), Vector3(x1, yk, zk), Vector3(x1, yt, zk), Vector3(x0, yt, zk), ns, ORGU)
	ag.quad(Vector3(x0, yk, zk), Vector3(x1, yk, zk), Vector3(x1, yk, zf), Vector3(x0, yk, zf), Vector3.DOWN)
	for sx: float in [-1.0, 1.0]:
		var xe := x1 if sx > 0.0 else x0
		ag.quad(Vector3(xe, yk, zk), Vector3(xe, yk, zf), Vector3(xe, yt, zf), Vector3(xe, yt, zk), Vector3(sx, 0, 0), ORGU)
	var oran := [0.22, 0.45, 0.72, 1.0]
	var ch := 0.3
	for x: float in xs:
		var hh := _h(x, 3.0, 7.0)
		for k in 4:
			var ust := yk - ch * (3 - k)
			var w := 0.62 - 0.04 * k + (hh - 0.5) * 0.05
			# sıra sıra ton (bingi taşları tek tek)
			var v := 0.9 + 0.1 * _h(x, float(k), 2.0)
			ag.kutu(Vector3(x, ust - ch, zf), Vector3.RIGHT, ns, w, ch - 0.015, ov * float(oran[k]) - 0.01, Color(v, v * 0.98, v * 0.95, 0.9), true)
	return ag.mesh_ekle(n, _mat(g.get("lod", 0), g.get("tas", TAS)), ad)


# ------------------------------------------------------------------ kule

## Kule planı: x cx ± w/2, kara yüzü zi, deniz yüzü zo; deniz köşeleri pah kadar kırık (0: düz köşe)
static func _plan(cx: float, w: float, zi: float, zo: float, pah: float) -> PackedVector2Array:
	var s := signf(zo - zi)
	var x0 := cx - w * 0.5
	var x1 := cx + w * 0.5
	var p := PackedVector2Array()
	p.append(Vector2(x0, zi))
	p.append(Vector2(x1, zi))
	if pah > 0.01:
		p.append(Vector2(x1, zo - s * pah))
		p.append(Vector2(x1 - pah, zo))
		p.append(Vector2(x0 + pah, zo))
		p.append(Vector2(x0, zo - s * pah))
	else:
		p.append(Vector2(x1, zo))
		p.append(Vector2(x0, zo))
	return p


## Kule (çarpışmasız; eski kutu kulenin ayak izi ve tepesi). k: cx, w, zi (kara yüzü), zo (deniz yüzü), HT (tepe = eski kutu
## tepesi), yb (silme: sur yolu düzeyi), pah, bat (şev: kaide üstünde dışa, yb'de 0), tohum, yarik (ok yarığı sayısı),
## isik_yuz (bool). g: dip, su, lod, tas. Teras korkuluğu ve dişler eski tepenin üstünde (görünüş).
static func kule(n: Node3D, k: Dictionary, g: Dictionary, ad := "DenizKule") -> void:
	var lod: int = g.get("lod", 0)
	var cx: float = k["cx"]
	var w: float = k["w"]
	var zi: float = k["zi"]
	var zo: float = k["zo"]
	var s := signf(zo - zi)
	var HT: float = k["HT"]
	var yb: float = k.get("yb", HT * 0.65)
	var pah: float = k.get("pah", 0.45)
	var bat: float = k.get("bat", 0.0)
	var seed: int = k.get("tohum", 7)
	var dip: float = g["dip"]
	var su: float = g["su"]
	var kd: float = g.get("kaide", 0.3)
	var ky: float = su + float(g.get("kaide_y", 0.45))
	var tas = SURKULE.Ag.new()
	var koyu = SURKULE.Ag.new()
	var poly := _plan(cx, w, zi, zo, pah)
	var ys1 := ky + 0.22
	# gecit: sur yolunun kuleden geçtiği koridor (Vector3: z0, z1, boy; yb'den): yan yüzlerde açıklık + koridor duvarları
	var gecit: Vector3 = k.get("gecit", Vector3.ZERO)
	# teras_kapi: kara yüzündeki teras korkuluğunda merdiven ağzı (Vector2: x0, x1)
	var tk: Vector2 = k.get("teras_kapi", Vector2.ZERO)
	var prof: Array = [[dip, kd + bat], [ky, kd + bat], [ys1, bat], [yb, 0.0]]
	if lod == 0:
		prof += [[yb, 0.12], [yb + 0.28, 0.12], [yb + 0.28, 0.0]]
		if gecit.z > 0.3:
			prof += [[yb + gecit.z, 0.0]]
		prof += [[HT - 0.95, 0.0], [HT - 0.95, 0.14], [HT - 0.65, 0.14], [HT - 0.65, 0.28], [HT - 0.35, 0.28], [HT - 0.35, 0.42],
			[HT, 0.42], [HT + SURKULE.PARAPET_H, 0.42]]
	else:
		if gecit.z > 0.3:
			prof += [[yb + gecit.z, 0.0]]
		prof += [[HT - 0.6, 0.0], [HT - 0.6, 0.3], [HT, 0.3], [HT + SURKULE.PARAPET_H, 0.3]]
	var kapi := {}
	var pn := poly.size()
	if gecit.z > 0.3:
		for i in pn:
			var a := poly[i]
			var b := poly[(i + 1) % pn]
			if absf(a.x - b.x) < 1e-3 and absf(b.y - a.y) > 1e-3:
				var t0 := (gecit.x - a.y) / (b.y - a.y)
				var t1 := (gecit.y - a.y) / (b.y - a.y)
				kapi[i] = [[clampf(minf(t0, t1), 0.0, 1.0), clampf(maxf(t0, t1), 0.0, 1.0), yb + gecit.z, yb]]
	var tk_t := Vector2.ZERO
	if tk.y - tk.x > 0.1:
		tk_t = Vector2((tk.x - poly[0].x) / (poly[1].x - poly[0].x), (tk.y - poly[0].x) / (poly[1].x - poly[0].x))
		kapi[0] = [[minf(tk_t.x, tk_t.y), maxf(tk_t.x, tk_t.y), HT + SURKULE.PARAPET_H, HT]]
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var yamalar: Array = []
	for i in 4:
		yamalar.append([rng.randi_range(0, poly.size() - 1), rng.randf_range(1.0, HT - 3.0), rng.randf_range(0.2, 0.8), rng.randf_range(1.2, 3.0), rng.randf_range(0.84, 0.93)])
	var tint := func(e: int, y: float, t: float) -> Color:
		for ym: Array in yamalar:
			if int(ym[0]) == e and absf(y - float(ym[1])) < float(ym[3]) and absf(t - float(ym[2])) < 0.3:
				var v: float = ym[4]
				return Color(v, v * 0.98, v * 0.93)
		return Color.WHITE
	SURKULE._or(tas, poly, prof, kapi, tint if lod == 0 else Callable(), (0.05 if kapi.is_empty() else 0.0) if lod == 0 else 0.0, seed, 3 if lod == 0 else 1)
	var po: float = float(prof[prof.size() - 1][1])
	var pd := SURKULE._otele(poly, po)
	var pi := poly
	var ytp := HT + SURKULE.PARAPET_H
	var atla := {}
	var ic_kapi := {}
	var dis_bos := {}
	if tk_t != Vector2.ZERO:
		atla[0] = true
		ic_kapi[0] = [[minf(tk_t.x, tk_t.y), maxf(tk_t.x, tk_t.y), ytp, HT]]
		dis_bos[0] = [[minf(tk_t.x, tk_t.y), maxf(tk_t.x, tk_t.y)]]
		# kara kenarının korkuluk tepesi iki parça (merdiven ağzı açık); ağzın iki yanağı
		for pr: Vector2 in [Vector2(0.0, minf(tk_t.x, tk_t.y)), Vector2(maxf(tk_t.x, tk_t.y), 1.0)]:
			var a0 := pd[0].lerp(pd[1], pr.x)
			var a1 := pd[0].lerp(pd[1], pr.y)
			var b0 := pi[0].lerp(pi[1], pr.x)
			var b1 := pi[0].lerp(pi[1], pr.y)
			tas.quad(Vector3(a0.x, ytp, a0.y), Vector3(a1.x, ytp, a1.y), Vector3(b1.x, ytp, b1.y), Vector3(b0.x, ytp, b0.y), Vector3.UP)
		for tt: float in [minf(tk_t.x, tk_t.y), maxf(tk_t.x, tk_t.y)]:
			var a2 := pd[0].lerp(pd[1], tt)
			var b2 := pi[0].lerp(pi[1], tt)
			tas.quad(Vector3(a2.x, HT, a2.y), Vector3(b2.x, HT, b2.y), Vector3(b2.x, ytp, b2.y), Vector3(a2.x, ytp, a2.y), Vector3.RIGHT)
	SURKULE._halka(tas, pd, pi, ytp, atla)
	SURKULE._ic_yuz(tas, pi, HT, ytp, ic_kapi)
	SURKULE._kapak(tas, pi, HT, true)
	if gecit.z > 0.3:
		# koridor: iki duvar, tavan, döşeme (sur yolunun devamı)
		var x0 := cx - w * 0.5 - 0.13
		var x1 := cx + w * 0.5 + 0.13
		var yg := yb + gecit.z
		var zl := minf(gecit.x, gecit.y)
		var zh := maxf(gecit.x, gecit.y)
		tas.quad(Vector3(x0, yb, zl), Vector3(x1, yb, zl), Vector3(x1, yg, zl), Vector3(x0, yg, zl), Vector3.BACK, ORGU)
		tas.quad(Vector3(x0, yb, zh), Vector3(x1, yb, zh), Vector3(x1, yg, zh), Vector3(x0, yg, zh), Vector3.FORWARD, ORGU)
		tas.quad(Vector3(x0, yg, zl), Vector3(x1, yg, zl), Vector3(x1, yg, zh), Vector3(x0, yg, zh), Vector3.DOWN)
		tas.quad(Vector3(x0, yb + 0.005, zl), Vector3(x1, yb + 0.005, zl), Vector3(x1, yb + 0.005, zh), Vector3(x0, yb + 0.005, zh), Vector3.UP)
	if lod == 0:
		SURKULE._disler(tas, pd, pi, ytp, seed, dis_bos, 0.6)
		# ok yarıkları: deniz yüzünde, sur yolunun üstünde (şev bitmiş: yüz düz)
		var ny: int = k.get("yarik", 2)
		for i in ny:
			var dx := (float(i) - (ny - 1) * 0.5) * w * 0.34
			SURKULE._yarik(tas, koyu, Vector3(cx + dx, yb + 1.3, zo + s * 0.002), Vector3.RIGHT, Vector3(0, 0, s), 1.0, lod)
		if yb - ys1 > 4.0:
			SURKULE._yarik(tas, koyu, Vector3(cx, (ys1 + yb) * 0.5, zo + s * (bat * 0.5 + 0.002)), Vector3.RIGHT, Vector3(0, 0, s), 0.9, lod)
	tas.mesh_ekle(n, _mat(lod, (g.get("tas", TAS) as Color).darkened(0.03)), ad)
	koyu.mesh_ekle(n, Props.mat(SURKULE.C_DARK), ad + "Koyu", false)


# ------------------------------------------------------------------ rıhtım

## Rıhtım x0…x1: deniz kenarı ze, sur tarafı zi, üst y_ust, dip (su altında). Kesme taş ön yüz (sur taşı), üstte ince örgülü
## kenar taşı sırası (0,4 m), döşeme (sur_doku yatay yüzü: tam y_ust), uç yüzleri (uclar: [sol, sağ]).
static func rihtim(n: Node3D, x0: float, x1: float, ze: float, zi: float, y_ust: float, dip: float, g: Dictionary, uclar := [true, true], ad := "DenizRihtim") -> MeshInstance3D:
	var ag = SURKULE.Ag.new()
	var s := signf(ze - zi)
	var ns := Vector3(0, 0, s)
	var tohum: float = float(g.get("tohum", 5)) + 3.0
	var xs: Array = [x0]
	var x := x0 + 3.6
	while x < x1 - 0.5:
		xs.append(x)
		x += 3.6
	xs.append(x1)
	var yk := y_ust - 0.4
	for i in xs.size() - 1:
		var xa: float = xs[i]
		var xb: float = xs[i + 1]
		var col := _ton((xa + xb) * 0.5, 1.0, tohum)
		ag.quad(Vector3(xa, dip, ze), Vector3(xb, dip, ze), Vector3(xb, yk, ze), Vector3(xa, yk, ze), ns, col)
		ag.quad(Vector3(xa, yk, ze + s * 0.03), Vector3(xb, yk, ze + s * 0.03), Vector3(xb, y_ust, ze + s * 0.03), Vector3(xa, y_ust, ze + s * 0.03), ns, Color(col.r, col.g, col.b, 0.9))
		ag.quad(Vector3(xa, yk, ze), Vector3(xb, yk, ze), Vector3(xb, yk, ze + s * 0.03), Vector3(xa, yk, ze + s * 0.03), Vector3.DOWN, ORGU)
	ag.quad(Vector3(x0, y_ust, ze + s * 0.03), Vector3(x1, y_ust, ze + s * 0.03), Vector3(x1, y_ust, zi), Vector3(x0, y_ust, zi), Vector3.UP)
	for k in 2:
		if not uclar[k]:
			continue
		var xe := x0 if k == 0 else x1
		var sx := -1.0 if k == 0 else 1.0
		ag.quad(Vector3(xe, dip, zi), Vector3(xe, dip, ze), Vector3(xe, y_ust, ze), Vector3(xe, y_ust, zi), Vector3(sx, 0, 0))
	return ag.mesh_ekle(n, _mat(g.get("lod", 0), (g.get("tas", TAS) as Color).darkened(0.06)), ad)


# ------------------------------------------------------------------ deniz kapısı

## Deniz kapısı süsü (yüzde, çarpışmasız): mermer söveler ve lento, üstünde dönüşümlü tuğla/taş boşaltma kemeri, kemer
## içinde kör timpan (bir ton koyu). gx, hw (açıklığın yarı eni), y0 (eşik), h (açıklık yüksekliği); g: zf, s.
## opt: "kitabe" (bool: lentonun üstünde mermer kitabe levhası yeri; yazı çağıranda), "soveler" (bool).
static func kapi_kemer(n: Node3D, gx: float, hw: float, y0: float, h: float, g: Dictionary, opt := {}) -> void:
	var s: float = g["s"]
	var zf: float = g["zf"] + s * float(opt.get("yuz", 0.0))
	var ns := Vector3(0, 0, s)
	var mer = SURKULE.Ag.new()
	var tug = SURKULE.Ag.new()
	var tas = SURKULE.Ag.new()
	var yl := y0 + h
	if opt.get("soveler", true):
		for sx: float in [-1.0, 1.0]:
			mer.kutu(Vector3(gx + sx * (hw + 0.14), y0, zf), Vector3.RIGHT, ns, 0.28, h, 0.09)
	mer.kutu(Vector3(gx, yl, zf), Vector3.RIGHT, ns, hw * 2.0 + 0.7, 0.42, 0.12)
	# boşaltma kemeri: lentonun üstünde; timpan kör, bir ton koyu
	# TUR-14: kemer kara surunun Romanos kemeriyle AYNI kalem (IstSurlarKapi.arch_ag: kesme taş kama taşları + üçer tuğla
	# demeti, dış tuğla halkası, harç yatağı; sur taşı gölgelendiricisi). Eskisi 11 iri dilim, yarısı Props tuğla (parlak
	# turuncu toon) — yakından oyuncak.
	var r := hw + 0.2
	var cy := yl + 0.42
	var nk := 11
	for i in nk:
		var a0 := PI * float(i) / nk
		var a1 := PI * float(i + 1) / nk
		var c0 := Vector3(gx, cy, zf)
		var p0 := c0 + Vector3(-cos(a0), sin(a0), 0) * r
		var p1 := c0 + Vector3(-cos(a1), sin(a1), 0) * r
		# timpan dilimi (geri çekik değil: yüzün 1 cm önünde, koyu ton)
		tas.tri(c0 + ns * 0.01, p0 + ns * 0.01, p1 + ns * 0.01, ns, Color(0.8, 0.78, 0.74))
	var kem = SURKULE.Ag.new()
	IstSurlarKapi.arch_ag(kem, gx, cy, r, zf, s, IstSurlarKapi.C_BRICK, 0.14)
	kem.mesh_ekle(n, SURDOKU.mat(1, Color.WHITE, true), "DenizKapiKemer", false)
	if opt.get("kitabe", false):
		mer.kutu(Vector3(gx, cy + r + IstSurlarKapi.HALKA + 0.17 + 0.15, zf), Vector3.RIGHT, ns, 2.4, 0.5, 0.06)
	mer.mesh_ekle(n, Props.mat(SURKULE.C_MARBLE, 0.0, false, "marble"), "DenizKapiMermer")
	tug.mesh_ekle(n, Props.mat(SURKULE.C_BRICK, 0.0, false, "brick"), "DenizKapiTugla")
	tas.mesh_ekle(n, _mat(g.get("lod", 0), g.get("tas", TAS)), "DenizKapiTas")


# ------------------------------------------------------------------ uzak katman (komşu devam)

## Uzak sur parçası (HornWorld/Horn devamı): a → b doğrultusunda, kesit kalınlık kal, tepe hh (zeminden), deniz yanı
## side (birim, xz). Gövde (su altına inen yosunlu kaide), korkuluk ve diş sırası tek ağda (dişler korkuluk üstünde
## seyrek çıkıntı, kutu değil: tek yüzlü kademeler). ag'a ekler (çağıran mesh_ekle ile kurar).
static func uzak_parca(ag, a: Vector3, b: Vector3, kal: float, hh: float, dip: float, side: Vector3) -> void:
	var dir := (b - a)
	dir.y = 0.0
	var L := dir.length()
	if L < 0.5:
		return
	dir /= L
	var sd := Vector3(side.x, 0, side.z).normalized()
	var ya := a.y + dip
	var yt := a.y + hh
	var fo := sd * kal * 0.5
	var bo := -sd * kal * 0.5
	var kd := sd * 0.35
	# deniz yüzü: kaide (dip → +0,9) ve gövde
	ag.quad(a + fo + kd + Vector3(0, dip, 0), b + fo + kd + Vector3(0, dip, 0), b + fo + kd + Vector3(0, 0.6, 0), a + fo + kd + Vector3(0, 0.6, 0), sd)
	ag.quad(a + fo + kd + Vector3(0, 0.6, 0), b + fo + kd + Vector3(0, 0.6, 0), b + fo + Vector3(0, 0.9, 0), a + fo + Vector3(0, 0.9, 0), (sd + Vector3.UP).normalized())
	ag.quad(a + fo + Vector3(0, 0.9, 0), b + fo + Vector3(0, 0.9, 0), b + fo + Vector3(0, hh + 1.0, 0), a + fo + Vector3(0, hh + 1.0, 0), sd)
	ag.quad(a + bo + Vector3(0, dip, 0), b + bo + Vector3(0, dip, 0), b + bo + Vector3(0, hh, 0), a + bo + Vector3(0, hh, 0), -sd)
	ag.quad(a + bo + Vector3(0, hh, 0), b + bo + Vector3(0, hh, 0), b + fo - sd * 0.5 + Vector3(0, hh, 0), a + fo - sd * 0.5 + Vector3(0, hh, 0), Vector3.UP)
	# korkuluk (0,5 m) ve dişler (2,5 m adım; deniz yüzüyle aynı düzlem)
	var ki := fo - sd * 0.5
	ag.quad(a + ki + Vector3(0, hh, 0), b + ki + Vector3(0, hh, 0), b + ki + Vector3(0, hh + 1.0, 0), a + ki + Vector3(0, hh + 1.0, 0), -sd)
	ag.quad(a + ki + Vector3(0, hh + 1.0, 0), b + ki + Vector3(0, hh + 1.0, 0), b + fo + Vector3(0, hh + 1.0, 0), a + fo + Vector3(0, hh + 1.0, 0), Vector3.UP)
	var m := int(L / 2.5)
	for i in m:
		var c := a + dir * (2.5 * (i + 0.5))
		var p0 := c - dir * 0.6
		var p1 := c + dir * 0.6
		var y0 := Vector3(0, hh + 1.0, 0)
		var y1 := Vector3(0, hh + 1.6 + 0.08 * sin(c.x * 3.1 + c.z), 0)
		ag.quad(p0 + fo + y0, p1 + fo + y0, p1 + fo + y1, p0 + fo + y1, sd)
		ag.quad(p0 + ki + y0, p1 + ki + y0, p1 + ki + y1, p0 + ki + y1, -sd)
		ag.quad(p0 + ki + y1, p1 + ki + y1, p1 + fo + y1, p0 + fo + y1, Vector3.UP)
		ag.quad(p0 + ki + y0, p0 + fo + y0, p0 + fo + y1, p0 + ki + y1, -dir)
		ag.quad(p1 + ki + y0, p1 + fo + y0, p1 + fo + y1, p1 + ki + y1, dir)


## Uzak kule (devam): pahlı kare, kaideli, silmeli, mazgallı teras (tek ağ; dişler kademeli). c: taban merkezi (y zemin).
static func uzak_kule(ag, c: Vector3, w: float, th: float, dip: float, yaw: float) -> void:
	var b := Basis(Vector3.UP, yaw)
	var hw := w * 0.5
	var pah := 0.6
	var pts: Array = [Vector3(-hw, 0, -hw + pah), Vector3(-hw + pah, 0, -hw), Vector3(hw - pah, 0, -hw), Vector3(hw, 0, -hw + pah),
		Vector3(hw, 0, hw - pah), Vector3(hw - pah, 0, hw), Vector3(-hw + pah, 0, hw), Vector3(-hw, 0, hw - pah)]
	var halkalar: Array = [[dip, 0.35], [0.6, 0.35], [0.9, 0.0], [th - 0.6, 0.0], [th - 0.6, 0.3], [th + 1.1, 0.3]]
	for k in halkalar.size() - 1:
		var ya: float = halkalar[k][0]
		var yb: float = halkalar[k + 1][0]
		var oa: float = halkalar[k][1]
		var ob: float = halkalar[k + 1][1]
		for i in pts.size():
			var p: Vector3 = pts[i]
			var q: Vector3 = pts[(i + 1) % pts.size()]
			var nn := ((p + q) * 0.5).normalized()
			var pa := c + b * (p + p.normalized() * oa + Vector3(0, ya, 0))
			var qa := c + b * (q + q.normalized() * oa + Vector3(0, ya, 0))
			var pb := c + b * (p + p.normalized() * ob + Vector3(0, yb, 0))
			var qb := c + b * (q + q.normalized() * ob + Vector3(0, yb, 0))
			if absf(ya - yb) < 1e-3:
				ag.quad(pa, qa, qb, pb, Vector3.DOWN)
			else:
				ag.quad(pa, qa, qb, pb, b * nn)
	# teras kapağı (korkuluk içi) ve köşe dişleri
	var yt := th + 1.1
	for i in pts.size():
		var p: Vector3 = pts[i]
		var q: Vector3 = pts[(i + 1) % pts.size()]
		ag.tri(c + Vector3(0, yt, 0), c + b * (p + p.normalized() * 0.3 + Vector3(0, yt, 0)), c + b * (q + q.normalized() * 0.3 + Vector3(0, yt, 0)), Vector3.UP)
	for i in [1, 3, 5, 7]:
		var p: Vector3 = pts[i]
		var o := c + b * (p + p.normalized() * 0.3)
		var t := b * Vector3(-p.z, 0, p.x).normalized()
		var nr := b * p.normalized()
		ag.kutu(o - nr * 0.5 + Vector3(0, yt, 0), t, nr, 1.0, 0.6, 0.5)


# ------------------------------------------------------------------ bağdaştırıcı yardımcıları

## Eski kutuların görünen ağını gizler: katı gövdenin çocuğu olan ağ gizlenir, gövde "görünür katı" (meta wall/ground)
## sayılır (Unclip/düellocu düşüşü eskisi gibi; TAŞIMA-9 "sonraki taşıyana" 4). Çarpışma aynen kalır.
static func gizle(body: Node, zemin := false) -> void:
	if body == null:
		return
	for c in body.get_children():
		if c is MeshInstance3D:
			(c as MeshInstance3D).visible = false
	if body is StaticBody3D:
		body.set_meta("wall", true)
		if zemin:
			body.set_meta("ground", true)


## Görünüş kökü: "ashlar" yüzeyleri deniz suru taşına (sur_doku tur 1) çevirir, malzeme × hücre birleştirir.
static func bitir(kok: Node3D, ad: String) -> int:
	SURDOKU.uygula(kok, 1)
	return BLAK.birlestir(kok, ad)


## Sahnenin bölüm adı (res://scenes/chapter18b.tscn → "18b"); ortak kurucular (Horn, HornWorld) seçimi buradan alır
static func sahne_bolumu(n: Node) -> String:
	if n == null or not n.is_inside_tree() or n.get_tree().current_scene == null:
		return ""
	return n.get_tree().current_scene.scene_file_path.get_file().get_basename().trim_prefix("chapter")


## Seçim: SurSet.eski_istendi(bolum) (`--eskisur`, `--eskisur=4,17`)
static func eski_mi(bolum: String) -> bool:
	return SurSet.eski_istendi(bolum)
