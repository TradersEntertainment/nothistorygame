extends RefCounted
## SUR-5: Theodosius sur kuleleri ve beden süsleri (kalite notu 32, KUTU YASAĞI; sahibinin "kuleler kutu" sözü).
## Kule artık düz küp + eğik kırmızı levha değil: plan çokgeni (iç sur dönüşümlü KARE / SEKİZGEN / ALTIGEN; dış sur
## KARE / U), kesit profili halka halka örülür:
##   kaide (çıkıntılı, eğik üst) → hafif içe yatık gövde (şev) → kat silmesi → üst oda (kemerli mazgal pencereleri,
##   yürüme yolu kapıları) → silme → konsol sırası (üç kademe) → mazgallı teras (dişler insan boyu, bazıları kırık/eksik)
## Köşeler pahlı; halkaların köşeleri taş sırası kadar oynatılır (siluet cetvelle çekilmiş değil). Yıpranma: onarım yaması
## (farklı tonda taş: köşe rengi), çatlak, eksik blok (karanlık oyuk), dipte düşmüş taşlar; bazı kulelerde ahşap kırma
## çatı (gerçek çatı biçimi: dört/sekiz yüzlü, saçaklı), yazıt levhası, kule kapısı.
## Görünen ağ (SurfaceTool) ile çarpışma ayrı: çarpışma plan çokgeninin dışbükey prizması + oda duvarları (kapı boşluklu)
## + teras korkuluğu kenar kenar (eski kutu çarpışmasıyla aynı yürüme yolu; sur üstü yürüyüş bozulmaz).
## Katman bütçesi (üçgen): yakın ≤ 2 500, orta ≤ 300, uzak ≤ 60.
## class_name yok (preload ile kullanılır).

const C_STONE := Color("cdbd9e")
const C_DARK := Color("1a1612")
const C_BRICK := Color("6a4a3e")
const C_WOOD := Color("6e4e30")
const C_ROOF := Color("6e5446")          # soluk, eskimiş kiremit (doygun kırmızı değil)
const C_MARBLE := Color("b4ac9c")
const PARAPET_H := 1.2

static var _mat_cache := {}


# ------------------------------------------------------------------ malzeme

## lod 0–1: köşe rengi (onarım yaması) × taban rengi, "ashlar" desenli (şehir kurucusu sur taşı gölgelendiricisine çevirir).
## lod 2: uzak pişirici köşe rengini okumaz: taban rengi malzemede, desen "ashlar_far".
static func _tas_mat(col: Color, lod: int) -> StandardMaterial3D:
	var key := "%s|%d" % [col.to_html(), mini(lod, 2)]
	if _mat_cache.has(key):
		return _mat_cache[key]
	var m := Props.mat(col, 0.0, false, "ashlar" if lod < 2 else "ashlar_far")
	_mat_cache[key] = m
	return m


# ------------------------------------------------------------------ ağ yardımcıları

class Ag:
	var st := SurfaceTool.new()
	var n := 0
	func _init() -> void:
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
	## Üçgen; nrm: istenen dış normal (sarım ona göre çevrilir)
	func tri(a: Vector3, b: Vector3, c: Vector3, nrm: Vector3, col := Color.WHITE) -> void:
		var cr := (b - a).cross(c - a)
		if cr.length_squared() < 1e-10:
			return
		# Godot: ön yüz saat yönünde (normal tarafından bakınca)
		if cr.dot(nrm) > 0.0:
			var t := b
			b = c
			c = t
		var nn := nrm.normalized()
		for v: Vector3 in [a, b, c]:
			st.set_color(col)
			st.set_normal(nn)
			st.add_vertex(v)
		n += 1
	func quad(a: Vector3, b: Vector3, c: Vector3, d: Vector3, nrm: Vector3, col := Color.WHITE) -> void:
		tri(a, b, c, nrm, col)
		tri(a, c, d, nrm, col)
	## Düz yüzün normalini kendisi bulur; dis: yüzün dışa baktığı yaklaşık yön
	func quad_auto(a: Vector3, b: Vector3, c: Vector3, d: Vector3, dis: Vector3, col := Color.WHITE) -> void:
		var nrm := (b - a).cross(d - a)
		if nrm.dot(dis) < 0.0:
			nrm = -nrm
		quad(a, b, c, d, nrm, col)
	## Kenar çerçeveli kutu (yerel eksenler: t yatay, nrm dışa, yukarı Y)
	func kutu(o: Vector3, t: Vector3, nrm: Vector3, w: float, h: float, dp: float, col := Color.WHITE, alt := false) -> void:
		var a := o - t * w * 0.5
		var b := o + t * w * 0.5
		var u := Vector3.UP * h
		var f := nrm * dp
		quad(a + f, b + f, b + f + u, a + f + u, nrm, col)                 # ön
		quad(a, b, b + u, a + u, -nrm, col)                                # arka
		quad(a + u, b + u, b + u + f, a + u + f, Vector3.UP, col)          # üst
		quad(a, a + f, a + f + u, a + u, -t, col)                          # sol
		quad(b, b + f, b + f + u, b + u, t, col)                           # sağ
		if alt:
			quad(a, b, b + f, a + f, Vector3.DOWN, col)
	func mesh_ekle(p: Node3D, mat: Material, ad: String, golge := true) -> MeshInstance3D:
		if n == 0:
			return null
		var mi := MeshInstance3D.new()
		mi.name = ad
		mi.mesh = st.commit()
		mi.material_override = mat
		mi.set_meta("no_walk", true)
		if not golge:
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		p.add_child(mi)
		return mi


static func _merkez(poly: PackedVector2Array) -> Vector2:
	var c := Vector2.ZERO
	for v in poly:
		c += v
	return c / maxf(1.0, poly.size())


## Dışbükey çokgeni d kadar dışa (d < 0: içe) öteler; köşe sayısı korunur
static func _otele(poly: PackedVector2Array, d: float) -> PackedVector2Array:
	if absf(d) < 1e-5:
		return poly
	var c := _merkez(poly)
	var out := PackedVector2Array()
	var n := poly.size()
	for i in n:
		var a := poly[(i - 1 + n) % n]
		var b := poly[i]
		var e := poly[(i + 1) % n]
		var n1 := _dis_normal(a, b, c)
		var n2 := _dis_normal(b, e, c)
		var bis := (n1 + n2)
		if bis.length() < 1e-4:
			bis = n1
		bis = bis.normalized()
		var k := maxf(bis.dot(n1), 0.35)
		out.append(b + bis * (d / k))
	return out


static func _dis_normal(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	var e := (b - a).normalized()
	var nn := Vector2(e.y, -e.x)
	if nn.dot((a + b) * 0.5 - c) < 0.0:
		nn = -nn
	return nn


static func _v3(p: Vector2, y: float) -> Vector3:
	return Vector3(p.x, y, p.y)


# ------------------------------------------------------------------ plan çokgenleri

## İç sur kulesi planı. tur: 0 kare (pahlı), 1 sekizgen, 2 altıgen
static func plan_ic(cx: float, w: float, zb: float, zf: float, tur: int) -> PackedVector2Array:
	var x0 := cx - w * 0.5
	var x1 := cx + w * 0.5
	var p := PackedVector2Array()
	p.append(Vector2(x0, zb))
	p.append(Vector2(x1, zb))
	match tur:
		1:
			var c := w * 0.3
			p.append(Vector2(x1, zf - c))
			p.append(Vector2(x1 - c, zf))
			p.append(Vector2(x0 + c, zf))
			p.append(Vector2(x0, zf - c))
		2:
			var a := w * 0.42
			p.append(Vector2(x1, zf - a))
			p.append(Vector2(cx + w * 0.26, zf))
			p.append(Vector2(cx - w * 0.26, zf))
			p.append(Vector2(x0, zf - a))
		_:
			var c2 := 0.45
			p.append(Vector2(x1, zf - c2))
			p.append(Vector2(x1 - c2, zf))
			p.append(Vector2(x0 + c2, zf))
			p.append(Vector2(x0, zf - c2))
	return p


## Dış sur kulesi planı. tur: 0 kare (pahlı), 1 U (yarım yuvarlak ön)
static func plan_dis(cx: float, w: float, z0: float, zf: float, tur: int, seg := 7) -> PackedVector2Array:
	var x0 := cx - w * 0.5
	var x1 := cx + w * 0.5
	var p := PackedVector2Array()
	p.append(Vector2(x0, z0))
	p.append(Vector2(x1, z0))
	if tur == 1:
		var r := w * 0.5
		var zc := zf - r
		for i in seg + 1:
			var a := PI * float(i) / float(seg)
			p.append(Vector2(cx + r * cos(a), zc + r * sin(a)))
	else:
		var c := 0.35
		p.append(Vector2(x1, zf - c))
		p.append(Vector2(x1 - c, zf))
		p.append(Vector2(x0 + c, zf))
		p.append(Vector2(x0, zf - c))
	return p


# ------------------------------------------------------------------ profil örücü

## Halka halka gövde. prof: [[y, öteleme], …]; ardışık iki nokta bir bant (y eşitse yatay basamak).
## kapi: {kenar_indeksi: [[t0, t1, y_ust], …]} (kenar boyunca 0–1 aralığı; bant y'si y_ust'ten aşağıdaysa boşluk).
## tint: Callable(kenar, y, t) -> Color (onarım yaması; null ise beyaz). sall: köşe oynatma genliği.
static func _or(ag: Ag, poly: PackedVector2Array, prof: Array, kapi: Dictionary, tint: Callable, sall: float, seed: int, bolum := 1, atla_arka := false) -> void:
	var c := _merkez(poly)
	var n := poly.size()
	var rings: Array = []
	for k in prof.size():
		var pr: Array = prof[k]
		var ring := _otele(poly, float(pr[1]))
		if sall > 0.0 and k > 0 and k < prof.size() - 1:
			# taş sırası girinti-çıkıntısı (yalnız köşeler; kenar çizgisi kırılır)
			var r2 := PackedVector2Array()
			for i in n:
				var h := fposmod(sin(float(i) * 12.9898 + float(k) * 78.233 + float(seed) * 0.37) * 43758.5453, 1.0)
				var dn := (ring[i] - c).normalized()
				r2.append(ring[i] + dn * (h - 0.5) * sall)
			ring = r2
		rings.append(ring)
	for k in range(prof.size() - 1):
		var ya: float = prof[k][0]
		var yb: float = prof[k + 1][0]
		var A: PackedVector2Array = rings[k]
		var B: PackedVector2Array = rings[k + 1]
		for i in n:
			var j := (i + 1) % n
			if atla_arka and i == 0:
				continue
			var nrm2 := _dis_normal(poly[i], poly[j], c)
			var nrm := Vector3(nrm2.x, 0.0, nrm2.y)
			if absf(ya - yb) < 1e-4:
				# yatay basamak: dışa çıkıyorsa alt yüz (aşağı bakar), içe giriyorsa üst yüz
				var up := float(prof[k + 1][1]) < float(prof[k][1])
				ag.quad(_v3(A[i], ya), _v3(A[j], ya), _v3(B[j], yb), _v3(B[i], yb), Vector3.UP if up else Vector3.DOWN)
				continue
			var gaps: Array = kapi.get(i, [])
			var parcalar: Array = [[0.0, 1.0]]
			for g: Array in gaps:
				if minf(ya, yb) >= float(g[3]) - 0.01 and maxf(ya, yb) <= float(g[2]) + 0.01:
					parcalar = IstSurlar._segs(0.0, 1.0, [[float(g[0]), float(g[1])]])
			# yükseklik bölümü (onarım yaması için)
			var nb := maxi(1, bolum) if not tint.is_null() else 1
			var elen := poly[i].distance_to(poly[j])
			var nc := maxi(1, int(ceil(elen / 3.2))) if not tint.is_null() else 1
			for pc: Array in parcalar:
				var t0: float = pc[0]
				var t1: float = pc[1]
				for r in nb:
					var y0 := lerpf(ya, yb, float(r) / nb)
					var y1 := lerpf(ya, yb, float(r + 1) / nb)
					for s in nc:
						var u0 := lerpf(t0, t1, float(s) / nc)
						var u1 := lerpf(t0, t1, float(s + 1) / nc)
						var a0 := A[i].lerp(A[j], u0).lerp(B[i].lerp(B[j], u0), float(r) / nb)
						var a1 := A[i].lerp(A[j], u1).lerp(B[i].lerp(B[j], u1), float(r) / nb)
						var b0 := A[i].lerp(A[j], u0).lerp(B[i].lerp(B[j], u0), float(r + 1) / nb)
						var b1 := A[i].lerp(A[j], u1).lerp(B[i].lerp(B[j], u1), float(r + 1) / nb)
						var col := Color.WHITE
						if not tint.is_null():
							col = tint.call(i, (y0 + y1) * 0.5, (u0 + u1) * 0.5)
						ag.quad_auto(_v3(a0, y0), _v3(a1, y0), _v3(b1, y1), _v3(b0, y1), nrm, col)


## Yatay kapak (yelpaze): çokgen y'de, normal up/down
static func _kapak(ag: Ag, poly: PackedVector2Array, y: float, up := true) -> void:
	var c := _merkez(poly)
	for i in poly.size():
		var j := (i + 1) % poly.size()
		ag.tri(_v3(c, y), _v3(poly[i], y), _v3(poly[j], y), Vector3.UP if up else Vector3.DOWN)


## İki çokgen arasında yatay halka (korkuluk tepesi)
static func _halka(ag: Ag, dis: PackedVector2Array, ic: PackedVector2Array, y: float, atla: Dictionary = {}) -> void:
	for i in dis.size():
		var j := (i + 1) % dis.size()
		if atla.has(i):
			continue
		ag.quad(_v3(dis[i], y), _v3(dis[j], y), _v3(ic[j], y), _v3(ic[i], y), Vector3.UP)


## Mazgal dişleri: korkuluk çokgeni (dış, iç) kenarları boyunca; boşluklu kenarlar (gap) atlanır
static func _disler(ag: Ag, dis: PackedVector2Array, ic: PackedVector2Array, y: float, seed: int, gaps: Dictionary, hasar: float, uzun := true) -> void:
	var c := _merkez(dis)
	var n := dis.size()
	var sayac := 0
	for i in n:
		var j := (i + 1) % n
		var L := dis[i].distance_to(dis[j])
		if L < 1.4:
			continue
		var t2 := (dis[j] - dis[i]) / L
		var nrm2 := _dis_normal(dis[i], dis[j], c)
		var dp := (dis[i] - ic[i]).dot(nrm2)
		var m := maxi(1, floori((L - 0.4) / 1.8))
		var off := (L - (m - 1) * 1.8) * 0.5
		for k in m:
			var s := off + k * 1.8
			var tt := s / L
			var kesik := false
			for g: Array in gaps.get(i, []):
				if tt > float(g[0]) - 0.9 / L and tt < float(g[1]) + 0.9 / L:
					kesik = true
			if kesik:
				continue
			sayac += 1
			var h := fposmod(sin(float(sayac) * 3.17 + float(seed) * 1.71) * 9137.13, 1.0)
			if h < 0.08 * hasar:
				continue                                  # eksik diş
			var yuk := 0.75 if uzun else 0.6
			if h < 0.2 * hasar:
				yuk = 0.32 + h                            # kırık diş
			var o2 := dis[i] + t2 * s - nrm2 * dp
			var w := 0.95 + (h - 0.5) * 0.12
			ag.kutu(_v3(o2, y), Vector3(t2.x, 0, t2.y), Vector3(nrm2.x, 0, nrm2.y), w, yuk, dp)


# ------------------------------------------------------------------ pencere, kapı, çatlak

## Kemerli açıklık: koyu iç (dikdörtgen + yarım daire yelpaze) yüzün dpk kadar içinde, çevresinde taş söve ve tuğla
## kemer taşları (yüzden dışa çıkar: derinlik gölgesi). o: açıklığın alt orta noktası yüz düzleminde.
static func _kemer(tas: Ag, koyu: Ag, tug: Ag, o: Vector3, t: Vector3, nrm: Vector3, w: float, h: float, lod: int) -> void:
	var r := w * 0.5
	var hy := h - r
	var f := nrm * 0.03
	# koyu iç
	var a := o - t * r + f
	var b := o + t * r + f
	koyu.quad(a, b, b + Vector3.UP * hy, a + Vector3.UP * hy, nrm)
	var segs := 6 if lod == 0 else 3
	var cen := o + Vector3.UP * hy + f
	for i in segs:
		var a0 := PI * float(i) / segs
		var a1 := PI * float(i + 1) / segs
		koyu.tri(cen, cen + (t * cos(a0) + Vector3.UP * sin(a0)) * r, cen + (t * cos(a1) + Vector3.UP * sin(a1)) * r, nrm)
	if lod > 0:
		return
	# söve (iki yan), denizlik, kemer taşları (yüzden 0,22 m çıkar; açıklığın içi gölgede kalır)
	var dp := 0.22
	tas.kutu(o - t * (r + 0.13), t, nrm, 0.26, hy, dp)
	tas.kutu(o + t * (r + 0.13), t, nrm, 0.26, hy, dp)
	tas.kutu(o - Vector3.UP * 0.16, t, nrm, w + 0.6, 0.16, dp + 0.06)
	for i in 7:
		var am := PI * (float(i) + 0.5) / 7.0
		var rm := r + 0.17
		var p := cen - f + (t * cos(am) + Vector3.UP * sin(am)) * rm - Vector3.UP * 0.13
		var tt := (t * -sin(am) + Vector3.UP * cos(am)).normalized()
		# kemer taşı: yönlendirilmiş küçük kutu (tuğla)
		var hb := tt * 0.2
		var rb := (t * cos(am) + Vector3.UP * sin(am)) * 0.17
		var q0 := p - hb - rb
		var q1 := p + hb - rb
		var q2 := p + hb + rb
		var q3 := p - hb + rb
		var ff := nrm * (dp - 0.02)
		tug.quad(q0 + ff, q1 + ff, q2 + ff, q3 + ff, nrm)
		tug.quad(q3, q2, q2 + ff, q3 + ff, (rb).normalized())
		tug.quad(q0, q1, q1 + ff, q0 + ff, -(rb).normalized())


## Ok yarığı (gövdede): dar koyu açıklık, üstünde lento taşı
static func _yarik(tas: Ag, koyu: Ag, o: Vector3, t: Vector3, nrm: Vector3, h: float, lod: int) -> void:
	var f := nrm * 0.04
	koyu.quad(o - t * 0.09 + f, o + t * 0.09 + f, o + t * 0.09 + Vector3.UP * h + f, o - t * 0.09 + Vector3.UP * h + f, nrm)
	if lod == 0:
		tas.kutu(o + Vector3.UP * h, t, nrm, 0.7, 0.22, 0.12)


## Çatlak: yüzde kırık çizgi (zikzak, koyu ince şerit)
static func _catlak(koyu: Ag, o: Vector3, t: Vector3, nrm: Vector3, boy: float, seed: int) -> void:
	var f := nrm * 0.035
	var p := o
	var y := 0.0
	var k := 0
	while y < boy:
		var dx := (fposmod(sin(float(k + seed) * 4.1) * 731.7, 1.0) - 0.5) * 1.1
		var dy := 0.8 + fposmod(sin(float(k * 3 + seed) * 2.3) * 113.1, 1.0) * 0.9
		var q := p + t * dx + Vector3.UP * dy
		var wd := 0.07 * (1.0 - y / boy) + 0.025
		var s := ((q - p).cross(nrm)).normalized() * wd
		koyu.quad(p - s + f, p + s + f, q + s + f, q - s + f, nrm)
		p = q
		y += dy
		k += 1


## Şev (batter): kaide üstünde (1,1 m) bat kadar dışarıda, beden üstünde (yf) 0
static func _sev(bat: float, yf: float, y: float) -> float:
	return lerpf(bat, 0.0, clampf((y - 1.1) / (yf - 1.1), 0.0, 1.0))


static func _sev2(bat: float, OTH: float, y: float) -> float:
	return lerpf(bat, 0.0, clampf((y - 0.85) / (OTH - 0.5 - 0.85), 0.0, 1.0))


# ------------------------------------------------------------------ İÇ SUR KULESİ

## p: dilim kökü (yerel çerçeve: +x sur boyu, +z dışa). Kule ağları ve çarpışması p'ye eklenir.
## g: {cx, w, zb, zf, yf (beden/yürüme yolu), HT (teras), yc (oda tavanı), tur, tohum, hasar, cati, yazit, tas, kapi_z0, kapi_z1, kapi_h}
static func ic_kule(p: Node3D, g: Dictionary, lod: int) -> void:
	var cx: float = g["cx"]
	var w: float = g["w"]
	var zb: float = g["zb"]
	var zf: float = g["zf"]
	var yf: float = g["yf"]
	var HT: float = g["HT"]
	var yc: float = g["yc"]
	var tur: int = g["tur"]
	var seed: int = g["tohum"]
	var hasar: float = g.get("hasar", 1.0)
	var stone: Color = g.get("tas", C_STONE)
	var poly := plan_ic(cx, w, zb, zf, tur)
	var c2 := _merkez(poly)
	var tas := Ag.new()
	var koyu := Ag.new()
	var tug := Ag.new()
	var ahs := Ag.new()
	var ys1 := 0.9 + (yf - 0.9) * 0.5
	var y_base := -2.0
	var bat := 0.3                                    # şev: dipte 0,3 m dışa
	# yürüme yolu kapıları (yan kenarlar, yf … yf+kh): kenar indeksleri x0 (5) ve x1 (1) tarafı
	var kz0: float = g.get("kapi_z0", -1.1)
	var kz1: float = g.get("kapi_z1", 1.1)
	var kh: float = g.get("kapi_h", 3.0)
	var kapi := {}
	for ei in [1, poly.size() - 1]:
		var a := poly[ei]
		var b := poly[(ei + 1) % poly.size()]
		var ta := (kz0 - a.y) / (b.y - a.y)
		var tb := (kz1 - a.y) / (b.y - a.y)
		kapi[ei] = [[minf(ta, tb), maxf(ta, tb), yf + kh, yf]]
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var yamalar: Array = []
	for i in 3 + int(hasar * 2.0):
		yamalar.append([rng.randi_range(0, poly.size() - 1), rng.randf_range(1.0, HT - 3.0), rng.randf_range(0.2, 0.8), rng.randf_range(1.2, 3.0), rng.randf_range(0.84, 0.93)])
	var tint := func(e: int, y: float, t: float) -> Color:
		for ym: Array in yamalar:
			if int(ym[0]) == e and absf(y - float(ym[1])) < float(ym[3]) and absf(t - float(ym[2])) < 0.3:
				var v: float = ym[4]
				return Color(v, v * 0.98, v * 0.93)
		return Color.WHITE
	if lod == 0:
		var prof: Array = [
			[y_base, bat + 0.35], [0.7, bat + 0.35], [1.1, bat],
			[ys1, _sev(bat, yf, ys1)], [ys1, _sev(bat, yf, ys1) + 0.16], [ys1 + 0.32, _sev(bat, yf, ys1) + 0.16], [ys1 + 0.32, _sev(bat, yf, ys1 + 0.32)],
			[yf, 0.0], [yf + kh, 0.0], [yf + kh, 0.15], [yf + kh + 0.34, 0.15], [yf + kh + 0.34, 0.0],
			[HT - 0.95, 0.0], [HT - 0.95, 0.16], [HT - 0.65, 0.16], [HT - 0.65, 0.32], [HT - 0.35, 0.32], [HT - 0.35, 0.46],
			[HT + PARAPET_H, 0.46],
		]
		_or(tas, poly, prof, kapi, tint, 0.06, seed, 3, false)
		# korkuluk tepesi ve iç yüzü, teras
		var pd := _otele(poly, 0.46)
		var pi := _otele(poly, 0.0)
		_halka(tas, pd, pi, HT + PARAPET_H)
		_or(tas, pi, [[HT + PARAPET_H, 0.0], [HT, 0.0]], {}, Callable(), 0.0, seed)
		# iç yüz normal içe: örücü dışa bakar; iç yüz için ters çokgen yerine ayrı: korkuluğun iç yüzü
		_ic_yuz(tas, pi, HT, HT + PARAPET_H)
		_kapak(tas, pi, HT, true)
		_disler(tas, pd, pi, HT + PARAPET_H, seed, {}, hasar)
		# üst oda içi: iç duvarlar (kapı boşluklu), tavan, döşeme; kapı söveleri (eski kutu odasıyla aynı yerde)
		var ici := _otele(poly, -0.7)
		_ic_yuz(tas, ici, yf, yc, kapi)
		_kapak(tas, ici, yc, false)
		_kapak(tas, ici, yf + 0.02, true)
		for ei: int in kapi:
			var gp: Array = kapi[ei][0]
			var a := poly[ei]
			var b := poly[(ei + 1) % poly.size()]
			var ai := ici[ei]
			var bi := ici[(ei + 1) % ici.size()]
			for tt: float in [float(gp[0]), float(gp[1])]:
				var po := a.lerp(b, tt)
				var pin := ai.lerp(bi, tt)
				var dz := 1.0 if tt == float(gp[0]) else -1.0
				var e2 := (b - a).normalized() * dz
				tas.quad(_v3(po, yf), _v3(pin, yf), _v3(pin, yf + kh), _v3(po, yf + kh), Vector3(e2.x, 0, e2.y))
			var p0 := a.lerp(b, float(gp[0]))
			var p1 := a.lerp(b, float(gp[1]))
			var q0 := ai.lerp(bi, float(gp[0]))
			var q1 := ai.lerp(bi, float(gp[1]))
			tas.quad(_v3(p0, yf + kh), _v3(p1, yf + kh), _v3(q1, yf + kh), _v3(q0, yf + kh), Vector3.DOWN)
			# kapı kemeri (tuğla şerit), dış yüzde
			var nn := _dis_normal(a, b, c2)
			var te := (b - a).normalized()
			for kk in 5:
				var am := PI * (float(kk) + 0.5) / 5.0
				var pm := (p0 + p1) * 0.5 + te * cos(am) * ((p1 - p0).length() * 0.5 + 0.12)
				tug.kutu(_v3(pm, yf + kh + sin(am) * 0.45 - 0.1), Vector3(te.x, 0, te.y), Vector3(nn.x, 0, nn.y), 0.34, 0.22, 0.12)
		# pencereler: üst oda ön ve yan-ön kenarlarında kemerli mazgal pencereleri; gövdede ok yarıkları
		var n := poly.size()
		for i in n:
			var a := poly[i]
			var b := poly[(i + 1) % n]
			var L := a.distance_to(b)
			var nn := _dis_normal(a, b, c2)
			if nn.y < -0.5:
				# şehir yüzü: kule kapısı (dipte, kemerli) ve bir pencere
				var mid := (a + b) * 0.5
				var te := (b - a) / L
				_kemer(tas, koyu, tug, _v3(mid + nn * (bat + 0.36), 0.0), Vector3(te.x, 0, te.y), Vector3(nn.x, 0, nn.y), 1.5, 2.6, lod)
				continue
			var mid2 := (a + b) * 0.5
			if mid2.y < float(g.get("zi1", 2.5)) + 0.6 and absf(nn.x) > 0.9:
				continue                                   # bedenin içinde kalan yan kenar
			var te2 := (b - a) / L
			var t3 := Vector3(te2.x, 0, te2.y)
			var n3 := Vector3(nn.x, 0, nn.y)
			# yan kenarda pencereyi beden dışında kalan parçaya kaydır
			var pm := mid2
			if absf(nn.x) > 0.9:
				var t_dis := clampf((float(g.get("zi1", 2.5)) + 0.4 - a.y) / (b.y - a.y), 0.0, 1.0)
				pm = a.lerp(b, lerpf(t_dis, 1.0, 0.5) if b.y > a.y else lerpf(0.0, t_dis, 0.5))
			var k := 2 if L > 5.5 and absf(nn.x) < 0.9 else 1
			for q in k:
				var off := (float(q) - (k - 1) * 0.5) * L * 0.42
				var po := pm + te2 * off
				if L >= 2.0:
					_kemer(tas, koyu, tug, _v3(po, yf + kh + 0.9), t3, n3, 0.95, 1.9, lod)
				var oy: float = _sev(bat, yf, 4.5)
				_yarik(tas, koyu, _v3(po + nn * oy, 3.2), t3, n3, 1.2, lod)
				_yarik(tas, koyu, _v3(po + nn * _sev(bat, yf, ys1 + 1.6), ys1 + 1.0), t3, n3, 1.1, lod)
		# çatlak ve eksik blok (bazı kulelerde)
		if seed % 3 == 1 or hasar > 1.5:
			var ei2 := 2 + seed % maxi(1, n - 3)
			var a := poly[ei2]
			var b := poly[(ei2 + 1) % n]
			var nn := _dis_normal(a, b, c2)
			var te := (b - a).normalized()
			var po := a.lerp(b, 0.35) + nn * 0.2
			_catlak(koyu, _v3(po, 1.3), Vector3(te.x, 0, te.y), Vector3(nn.x, 0, nn.y), yf + 2.0, seed)
		for i in 2 + int(hasar):
			var ei3 := rng.randi_range(1, n - 1)
			var a := poly[ei3]
			var b := poly[(ei3 + 1) % n]
			var nn := _dis_normal(a, b, c2)
			var te := (b - a).normalized()
			var yy := rng.randf_range(2.0, yf - 1.0)
			var po := a.lerp(b, rng.randf_range(0.2, 0.8)) + nn * (_sev(bat, yf, yy) + 0.02)
			koyu.quad(_v3(po - te * 0.4, yy), _v3(po + te * 0.4, yy), _v3(po + te * 0.4, yy + 0.4), _v3(po - te * 0.4, yy + 0.4), Vector3(nn.x, 0, nn.y))
		# dipte düşmüş taşlar (düzensiz blok, kutu değil: eğik, farklı boy)
		for i in 3 + int(hasar * 2.0):
			var ei4 := rng.randi_range(1, n - 1)
			var a := poly[ei4]
			var b := poly[(ei4 + 1) % n]
			var nn := _dis_normal(a, b, c2)
			if nn.y < -0.5:
				continue
			var po := a.lerp(b, rng.randf_range(0.1, 0.9)) + nn * rng.randf_range(0.9, 2.2)
			_moloz_tas(tas, _v3(po, 0.0), rng)
		# yazıt levhası (bazı kulelerde): mermer levha, çerçeveli; yazı yok (dönem kuralı: tabela/yazı yok), oyma çizgiler
		if bool(g.get("yazit", false)):
			var a := poly[3]
			var b := poly[4]
			var nn := _dis_normal(a, b, c2)
			var te := (b - a).normalized()
			var po := (a + b) * 0.5 + nn * _sev(bat, yf, ys1 - 1.6)
			var mer := Ag.new()
			mer.kutu(_v3(po, ys1 - 2.4), Vector3(te.x, 0, te.y), Vector3(nn.x, 0, nn.y), 2.4, 1.0, 0.08)
			for li in 3:
				koyu.quad(_v3(po - te * 0.95, ys1 - 2.15 + li * 0.25) + Vector3(nn.x, 0, nn.y) * 0.09, _v3(po + te * 0.95, ys1 - 2.15 + li * 0.25) + Vector3(nn.x, 0, nn.y) * 0.09, _v3(po + te * 0.95, ys1 - 2.1 + li * 0.25) + Vector3(nn.x, 0, nn.y) * 0.09, _v3(po - te * 0.95, ys1 - 2.1 + li * 0.25) + Vector3(nn.x, 0, nn.y) * 0.09, Vector3(nn.x, 0, nn.y))
			mer.mesh_ekle(p, Props.mat(C_MARBLE, 0.0, false, "marble"), "KuleYazit")
		# ahşap kırma çatı (bazı kulelerde): teras üstünde direkler, saçaklı dört/çok yüzlü çatı
		if bool(g.get("cati", false)):
			_cati(ahs, pi, HT, tur)
	elif lod == 1:
		var prof1: Array = [[y_base, bat + 0.3], [1.0, bat], [yf, 0.0], [yf, 0.15], [yf + 0.35, 0.15], [yf + 0.35, 0.0],
			[HT - 0.6, 0.0], [HT - 0.6, 0.4], [HT + PARAPET_H, 0.4]]
		_or(tas, poly, prof1, {}, Callable(), 0.05, seed)
		var pd1 := _otele(poly, 0.4)
		var pi1 := _otele(poly, -0.05)
		_halka(tas, pd1, pi1, HT + PARAPET_H)
		_kapak(tas, pi1, HT + 0.3, true)
		_disler_orta(tas, pd1, pi1, HT + PARAPET_H, seed, hasar)
		var n1 := poly.size()
		for i in n1:
			var a := poly[i]
			var b := poly[(i + 1) % n1]
			var nn := _dis_normal(a, b, c2)
			var L := a.distance_to(b)
			if nn.y < 0.3 or L < 2.0:
				continue
			var te := (b - a) / L
			_kemer(tas, koyu, tug, _v3((a + b) * 0.5, yf + 2.2), Vector3(te.x, 0, te.y), Vector3(nn.x, 0, nn.y), 1.0, 2.0, 1)
		if bool(g.get("cati", false)):
			_cati(ahs, pi1, HT, tur, true)
	else:
		var prof2: Array = [[y_base, bat + 0.2], [HT - 0.6, 0.0], [HT - 0.6, 0.38], [HT + PARAPET_H, 0.38]]
		_or(tas, poly, prof2, {}, Callable(), 0.0, seed, 1, false)
		_kapak(tas, _otele(poly, 0.38), HT + PARAPET_H, true)
		# TUR-7: uzak katmanda da diş silueti (mazgalsız düz kutu değil; aynı ağ, ek çizim yok)
		_disler_orta(tas, _otele(poly, 0.38), _otele(poly, -0.2), HT + PARAPET_H, seed, hasar)
		var a := poly[3]
		var b := poly[4]
		var nn := _dis_normal(a, b, c2)
		var te := (b - a).normalized()
		var mid := (a + b) * 0.5 + nn * 0.16
		koyu.quad(_v3(mid - te * 0.5, yf + 1.2), _v3(mid + te * 0.5, yf + 1.2), _v3(mid + te * 0.5, yf + 3.0), _v3(mid - te * 0.5, yf + 3.0), Vector3(nn.x, 0, nn.y))
	tas.mesh_ekle(p, _tas_mat(stone.darkened(0.02), lod), "Kule")
	koyu.mesh_ekle(p, Props.mat(C_DARK), "KuleKoyu", false)
	tug.mesh_ekle(p, Props.mat(C_BRICK, 0.0, false, "brick"), "KuleTugla")
	ahs.mesh_ekle(p, Props.mat(C_ROOF, 0.0, false, ""), "KuleCati")
	if bool(g.get("cati", false)) and lod <= 1:
		var dir := Ag.new()
		for q: Vector2 in _otele(poly, -0.5):
			dir.kutu(_v3(q, HT), Vector3.RIGHT, Vector3.BACK, 0.22, PARAPET_H + 1.3, 0.22)
		dir.mesh_ekle(p, Props.mat(C_WOOD, 0.0, false, "wood"), "KuleDirek")
	# çarpışma
	if lod <= 1:
		_carp_prizma(p, _otele(poly, 0.1), 0.0, yf if lod == 0 else HT, true)
		if lod == 0:
			_carp_oda(p, poly, yf, yc, HT, kapi, kh)


## Korkuluğun iç yüzü (içe bakan normal), kapı boşluklu olabilir
static func _ic_yuz(ag: Ag, poly: PackedVector2Array, y0: float, y1: float, kapi: Dictionary = {}) -> void:
	var c := _merkez(poly)
	var n := poly.size()
	for i in n:
		var j := (i + 1) % n
		var nrm2 := -_dis_normal(poly[i], poly[j], c)
		var nrm := Vector3(nrm2.x, 0, nrm2.y)
		var parcalar: Array = [[0.0, 1.0]]
		var ust := y1
		if kapi.has(i):
			var g: Array = kapi[i][0]
			parcalar = IstSurlar._segs(0.0, 1.0, [[float(g[0]), float(g[1])]])
			# kapı üstü (lento üstündeki duvar) tam boy
			var ky: float = g[2]
			ag.quad(_v3(poly[i], ky), _v3(poly[j], ky), _v3(poly[j], y1), _v3(poly[i], y1), nrm)
			ust = ky
		for pc: Array in parcalar:
			var a := poly[i].lerp(poly[j], float(pc[0]))
			var b := poly[i].lerp(poly[j], float(pc[1]))
			ag.quad(_v3(a, y0), _v3(b, y0), _v3(b, ust), _v3(a, ust), nrm)


## Orta katman mazgal dişleri: yalnız ön, üst ve iki yan (arka yüz yok)
static func _disler_orta(ag: Ag, dis: PackedVector2Array, ic: PackedVector2Array, y: float, seed: int, hasar: float) -> void:
	var c := _merkez(dis)
	var n := dis.size()
	var sayac := 0
	for i in n:
		var j := (i + 1) % n
		var L := dis[i].distance_to(dis[j])
		if L < 1.4:
			continue
		var t2 := (dis[j] - dis[i]) / L
		var nrm2 := _dis_normal(dis[i], dis[j], c)
		if nrm2.y < -0.5:
			continue
		var m := maxi(1, floori((L - 0.4) / 1.8))
		var off := (L - (m - 1) * 1.8) * 0.5
		for k in m:
			sayac += 1
			var h := fposmod(sin(float(sayac) * 3.17 + float(seed) * 1.71) * 9137.13, 1.0)
			if h < 0.08 * hasar:
				continue
			var o := _v3(dis[i] + t2 * (off + k * 1.8), y)
			var t := Vector3(t2.x, 0, t2.y)
			var nn := Vector3(nrm2.x, 0, nrm2.y)
			var yuk := 0.75 if h >= 0.2 * hasar else 0.4
			var a := o - t * 0.48
			var b := o + t * 0.48
			var u := Vector3.UP * yuk
			var f := -nn * 0.45
			ag.quad(a, b, b + u, a + u, nn)
			ag.quad(a + u, b + u, b + u + f, a + u + f, Vector3.UP)
			ag.quad(a, a + f, a + f + u, a + u, -t)
			ag.quad(b, b + f, b + f + u, b + u, t)


## Kırma çatı: teras çokgeninin içinde direkler üstünde; saçak dışa taşar, mahya ortada (kare: dört yüz; çokgen: n yüz)
static func _cati(ag: Ag, poly: PackedVector2Array, HT: float, tur: int, orta := false) -> void:
	var c := _merkez(poly)
	var sac := _otele(poly, 0.35)
	var y0 := HT + PARAPET_H + 1.3
	var tepe := 2.6 if tur != 0 else 2.2
	var n := sac.size()
	for i in n:
		var j := (i + 1) % n
		var a := _v3(sac[i], y0)
		var b := _v3(sac[j], y0)
		var t := _v3(c, y0 + tepe)
		var nrm := (b - a).cross(t - a)
		var dis2 := _dis_normal(sac[i], sac[j], c)
		if nrm.dot(Vector3(dis2.x, 0, dis2.y)) < 0.0:
			nrm = -nrm
		ag.tri(a, b, t, nrm)
		# saçak altı (aşağı bakan)
		ag.tri(a, b, _v3(c, y0 - 0.15), Vector3.DOWN)
		if not orta:
			# saçak kalınlığı (kiremit kenarı)
			ag.quad(a, b, b - Vector3.UP * 0.14, a - Vector3.UP * 0.14, Vector3(dis2.x, 0, dis2.y))


## Moloz taşı: düzensiz, eğik, köşeleri kırık blok (kesme taş parçası; çıplak kutu değil)
static func _moloz_tas(ag: Ag, o: Vector3, rng: RandomNumberGenerator) -> void:
	var s := Vector3(rng.randf_range(0.35, 0.8), rng.randf_range(0.22, 0.45), rng.randf_range(0.3, 0.6))
	var b := Basis.from_euler(Vector3(rng.randf_range(-0.35, 0.35), rng.randf_range(0, TAU), rng.randf_range(-0.35, 0.35)))
	var pts: Array = []
	for i in 8:
		var v := Vector3(s.x * (1 if i & 1 else -1), s.y * (1 if i & 2 else -1), s.z * (1 if i & 4 else -1)) * 0.5
		v *= rng.randf_range(0.7, 1.0)              # köşe kırık
		pts.append(o + b * v + Vector3.UP * s.y * 0.35)
	var yuz := [[0, 1, 3, 2, Vector3.DOWN], [4, 5, 7, 6, Vector3.UP], [0, 1, 5, 4, Vector3.BACK * -1], [2, 3, 7, 6, Vector3.BACK],
		[0, 2, 6, 4, Vector3.LEFT], [1, 3, 7, 5, Vector3.RIGHT]]
	var cen := Vector3.ZERO
	for q: Vector3 in pts:
		cen += q
	cen /= 8.0
	for f: Array in yuz:
		var a: Vector3 = pts[f[0]]
		var bb: Vector3 = pts[f[1]]
		var c: Vector3 = pts[f[2]]
		var d: Vector3 = pts[f[3]]
		var dis := ((a + bb + c + d) * 0.25 - cen)
		ag.tri(a, bb, c, dis)
		ag.tri(a, c, d, dis)


# ------------------------------------------------------------------ DIŞ SUR KULESİ

## g: {cx, w, z0 (dış surun şehir yüzü), zf, y0 (dip), OH (beden), OTH (teras), tur (0 kare, 1 U), tohum, hasar, tas,
##     gap_z (korkuluk geçidi merkezi), gap_w}
static func dis_kule(p: Node3D, g: Dictionary, lod: int) -> void:
	var cx: float = g["cx"]
	var w: float = g["w"]
	var z0: float = g["z0"]
	var zf: float = g["zf"]
	var y0: float = g["y0"]
	var OH: float = g["OH"]
	var OTH: float = g["OTH"]
	var tur: int = g["tur"]
	var seed: int = g["tohum"]
	var hasar: float = g.get("hasar", 1.0)
	var stone: Color = g.get("tas", C_STONE)
	var poly := plan_dis(cx, w, z0, zf, tur, 7 if lod == 0 else (5 if lod == 1 else 3))
	var c2 := _merkez(poly)
	var tas := Ag.new()
	var koyu := Ag.new()
	var bat := 0.22
	var ys := OH * 0.5
	# korkuluk geçidi (merdivenin indiği yer): yan kenarlar (1 ve son)
	var gz: float = g.get("gap_z", (z0 + z0 + 2.6) * 0.5)
	var gw: float = g.get("gap_w", 1.8)
	var gaps := {}
	for ei in [1, poly.size() - 1]:
		var a := poly[ei]
		var b := poly[(ei + 1) % poly.size()]
		if absf(b.y - a.y) < 0.1:
			continue
		var ta := (gz - gw * 0.5 - a.y) / (b.y - a.y)
		var tb := (gz + gw * 0.5 - a.y) / (b.y - a.y)
		gaps[ei] = [[minf(ta, tb), maxf(ta, tb), OTH + PARAPET_H + 1.0, OTH]]
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	if lod == 0:
		var prof: Array = [[y0, bat + 0.3], [0.6, bat + 0.3], [0.85, bat], [ys, _sev2(bat, OTH, ys)], [ys, _sev2(bat, OTH, ys) + 0.14],
			[ys + 0.28, _sev2(bat, OTH, ys) + 0.14], [ys + 0.28, _sev2(bat, OTH, ys + 0.28)], [OTH - 0.55, 0.0], [OTH - 0.55, 0.16],
			[OTH - 0.3, 0.16], [OTH - 0.3, 0.3], [OTH, 0.3]]
		var tint := func(e: int, y: float, t: float) -> Color:
			var h := fposmod(sin(float(e) * 7.1 + floor(y / 2.0) * 3.3 + floor(t * 3.0) * 1.9 + seed) * 4371.3, 1.0)
			return Color(0.78, 0.76, 0.72) if h < 0.1 else Color.WHITE
		_or(tas, poly, prof, {}, tint, 0.05, seed, 2, false)
		# korkuluk (geçitli): dış yüz, tepe, iç yüz, geçit uçları
		var pd := _otele(poly, 0.3)
		var pi := _otele(poly, -0.15)
		_or(tas, pd, [[OTH, 0.0], [OTH + PARAPET_H, 0.0]], gaps, Callable(), 0.0, seed, 1, true)
		var n := pd.size()
		for i in n:
			if i == 0:
				continue
			var j := (i + 1) % n
			var parcalar: Array = [[0.0, 1.0]]
			if gaps.has(i):
				var gg: Array = gaps[i][0]
				parcalar = IstSurlar._segs(0.0, 1.0, [[float(gg[0]), float(gg[1])]])
			var nrm2 := _dis_normal(poly[i], poly[j], c2)
			for pc: Array in parcalar:
				var a := pd[i].lerp(pd[j], float(pc[0]))
				var b := pd[i].lerp(pd[j], float(pc[1]))
				var ai := pi[i].lerp(pi[j], float(pc[0]))
				var bi := pi[i].lerp(pi[j], float(pc[1]))
				tas.quad(_v3(a, OTH + PARAPET_H), _v3(b, OTH + PARAPET_H), _v3(bi, OTH + PARAPET_H), _v3(ai, OTH + PARAPET_H), Vector3.UP)
				tas.quad(_v3(ai, OTH), _v3(bi, OTH), _v3(bi, OTH + PARAPET_H), _v3(ai, OTH + PARAPET_H), -Vector3(nrm2.x, 0, nrm2.y))
				if gaps.has(i):
					for q: Array in [[a, ai, pc[0]], [b, bi, pc[1]]]:
						if float(q[2]) > 0.001 and float(q[2]) < 0.999:
							var e := (pd[j] - pd[i]).normalized()
							tas.quad_auto(_v3(q[0], OTH), _v3(q[1], OTH), _v3(q[1], OTH + PARAPET_H), _v3(q[0], OTH + PARAPET_H), Vector3(e.x, 0, e.y) * (1.0 if float(q[2]) == float(pc[0]) else -1.0))
		_kapak(tas, pi, OTH, true)
		_disler(tas, pd, pi, OTH + PARAPET_H, seed, gaps, hasar, false)
		# ok yarıkları ve silme altı pencere
		for i in poly.size():
			var a := poly[i]
			var b := poly[(i + 1) % poly.size()]
			var nn := _dis_normal(a, b, c2)
			var L := a.distance_to(b)
			if nn.y < 0.4 or L < 0.9:
				continue
			var te := (b - a) / L
			var mid := (a + b) * 0.5
			_yarik(tas, koyu, _v3(mid + nn * _sev2(bat, OTH, 2.6), 2.2), Vector3(te.x, 0, te.y), Vector3(nn.x, 0, nn.y), 1.1, lod)
			if L > 1.6:
				_yarik(tas, koyu, _v3(mid + nn * _sev2(bat, OTH, ys + 1.4), ys + 1.0), Vector3(te.x, 0, te.y), Vector3(nn.x, 0, nn.y), 1.0, lod)
		# düşmüş taşlar
		for i in 2 + int(hasar):
			var ei := rng.randi_range(2, poly.size() - 2)
			var a := poly[ei]
			var b := poly[(ei + 1) % poly.size()]
			var nn := _dis_normal(a, b, c2)
			_moloz_tas(tas, _v3(a.lerp(b, rng.randf_range(0.1, 0.9)) + nn * rng.randf_range(0.7, 1.8), 0.0), rng)
		if seed % 4 == 2:
			var a := poly[2]
			var b := poly[3]
			var nn := _dis_normal(a, b, c2)
			_catlak(koyu, _v3(a.lerp(b, 0.5) + nn * 0.25, 1.0), Vector3((b - a).normalized().x, 0, (b - a).normalized().y), Vector3(nn.x, 0, nn.y), OH, seed)
	elif lod == 1:
		var prof1: Array = [[y0, bat + 0.2], [0.85, bat], [OTH - 0.4, 0.0], [OTH - 0.4, 0.3], [OTH + PARAPET_H, 0.3]]
		_or(tas, poly, prof1, {}, Callable(), 0.0, seed, 1, false)
		var pd1 := _otele(poly, 0.3)
		var pi1 := _otele(poly, -0.15)
		_halka(tas, pd1, pi1, OTH + PARAPET_H, {0: true})
		_kapak(tas, pi1, OTH + 0.2, true)
		_disler_orta(tas, pd1, pi1, OTH + PARAPET_H, seed, hasar)
	else:
		_or(tas, poly, [[y0, bat], [OTH - 0.4, 0.0], [OTH - 0.4, 0.28], [OTH + PARAPET_H, 0.28]], {}, Callable(), 0.0, seed, 1, false)
		_kapak(tas, _otele(poly, 0.28), OTH + PARAPET_H, true)
		_disler_orta(tas, _otele(poly, 0.28), _otele(poly, -0.2), OTH + PARAPET_H, seed, hasar)
	tas.mesh_ekle(p, _tas_mat(stone, lod), "DisKule")
	koyu.mesh_ekle(p, Props.mat(C_DARK), "DisKuleKoyu", false)
	if lod <= 1:
		_carp_prizma(p, _otele(poly, 0.05), y0, OTH, true)
		if lod == 0:
			# korkuluk: kenar kenar (geçit boşluklu)
			var pd2 := _otele(poly, 0.3)
			var pi2 := _otele(poly, -0.15)
			for i in pd2.size():
				if i == 0:
					continue
				var j := (i + 1) % pd2.size()
				var parcalar: Array = [[0.0, 1.0]]
				if gaps.has(i):
					var gg: Array = gaps[i][0]
					parcalar = IstSurlar._segs(0.0, 1.0, [[float(gg[0]), float(gg[1])]])
				for pc: Array in parcalar:
					_carp_duvar(p, pd2[i].lerp(pd2[j], float(pc[0])), pd2[i].lerp(pd2[j], float(pc[1])), pi2[i].lerp(pi2[j], float(pc[0])), OTH, OTH + PARAPET_H)


# ------------------------------------------------------------------ çarpışma

static func _carp_prizma(p: Node3D, poly: PackedVector2Array, y0: float, y1: float, no_climb: bool) -> void:
	var pts := PackedVector3Array()
	for q in poly:
		pts.append(_v3(q, y0))
		pts.append(_v3(q, y1))
	var sh := ConvexPolygonShape3D.new()
	sh.points = pts
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = sh
	body.add_child(cs)
	if no_climb:
		body.set_meta("no_climb", true)
	p.add_child(body)


## Kenar boyunca duvar kutusu: a→b dış çizgi, ai (a'nın iç karşılığı) kalınlığı verir
static func _carp_duvar(p: Node3D, a: Vector2, b: Vector2, ai: Vector2, y0: float, y1: float) -> void:
	var L := a.distance_to(b)
	if L < 0.05:
		return
	var t := (b - a) / L
	var nrm := Vector2(t.y, -t.x)
	var th := absf((a - ai).dot(nrm))
	if (ai - a).dot(nrm) > 0.0:
		nrm = -nrm
	var cen := (a + b) * 0.5 - nrm * th * 0.5
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(L, y1 - y0, maxf(th, 0.2))
	cs.shape = bs
	body.add_child(cs)
	body.transform = Transform3D(Basis(Vector3.UP, atan2(-t.y, t.x)), Vector3(cen.x, (y0 + y1) * 0.5, cen.y))
	p.add_child(body)


## Üst oda: duvarlar (yan kenarlarda kapı boşluğu), tavan/teras döşemesi, teras korkuluğu
static func _carp_oda(p: Node3D, poly: PackedVector2Array, yf: float, yc: float, HT: float, kapi: Dictionary, kh: float) -> void:
	var ici := _otele(poly, -0.7)
	var n := poly.size()
	for i in n:
		var j := (i + 1) % n
		var parcalar: Array = [[0.0, 1.0]]
		if kapi.has(i):
			var g: Array = kapi[i][0]
			parcalar = IstSurlar._segs(0.0, 1.0, [[float(g[0]), float(g[1])]])
			_carp_duvar(p, poly[i].lerp(poly[j], float(g[0])), poly[i].lerp(poly[j], float(g[1])), ici[i].lerp(ici[j], float(g[0])), yf + kh, yc)
		for pc: Array in parcalar:
			_carp_duvar(p, poly[i].lerp(poly[j], float(pc[0])), poly[i].lerp(poly[j], float(pc[1])), ici[i].lerp(ici[j], float(pc[0])), yf, yc)
	_carp_prizma(p, poly, yc, HT, false)
	var pd := _otele(poly, 0.46)
	for i in n:
		var j := (i + 1) % n
		_carp_duvar(p, pd[i], pd[j], poly[i], HT, HT + PARAPET_H)


# ------------------------------------------------------------------ yuvarlak/düzensiz nesneler (kutu yasağı)

static var _kaya: ArrayMesh

## Düzensiz kaya ağı (birim boy; MultiMesh için): köşeleri oynatılmış alçak küre
static func kaya_mesh() -> ArrayMesh:
	if _kaya != null:
		return _kaya
	var sm := SphereMesh.new()
	sm.radius = 0.5
	sm.height = 1.0
	sm.radial_segments = 7
	sm.rings = 4
	var arr := sm.get_mesh_arrays()
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	for i in vs.size():
		var v := vs[i]
		var h := fposmod(sin(snappedf(v.x, 0.01) * 12.9 + snappedf(v.y, 0.01) * 78.2 + snappedf(v.z, 0.01) * 37.7) * 43758.5, 1.0)
		vs[i] = v * (0.78 + 0.34 * h)
	arr[Mesh.ARRAY_VERTEX] = vs
	var st := SurfaceTool.new()
	st.create_from_arrays(arr)
	st.generate_normals()
	_kaya = st.commit()
	return _kaya


## Beden mazgal dişleri (eski MultiMesh dönüşümleri): her biri gerçek ağ; boy ±%12, %9'u kırık (alçak, eğik üst)
static func disler_ag(p: Node3D, mer: Array, col: Color, seed: int) -> void:
	var ag := Ag.new()
	var i := 0
	for t: Transform3D in mer:
		i += 1
		var sz := t.basis.get_scale()
		var h := fposmod(sin(t.origin.x * 3.71 + t.origin.z * 1.37 + float(seed) * 0.11) * 4375.85, 1.0)
		var yuk := sz.y * (0.9 + 0.25 * h)
		if h < 0.09:
			yuk = sz.y * 0.45
		var along_x := sz.x >= sz.z
		var tt := Vector3.RIGHT if along_x else Vector3.BACK
		var nn := Vector3.BACK if along_x else Vector3.RIGHT
		var w := sz.x if along_x else sz.z
		var dp := sz.z if along_x else sz.x
		var o := t.origin - Vector3.UP * sz.y * 0.5 - nn * dp * 0.5
		ag.kutu(o, tt, nn, w * (0.94 + 0.1 * h), yuk, dp)
	ag.mesh_ekle(p, _tas_mat(col, 0), "MazgalDis")


# ------------------------------------------------------------------ KÖŞE KULESİ (hat kırıklarında)

## Sekizgen köşe kulesi: tepe yürüme yolu hizasında (walk), temel zemine iner (dip). yonler: yürüme yolunun köşeye
## girdiği/çıktığı yönler (dünya xz, birim): o yöne bakan kenarlarda korkuluk açık. Yerel çerçeve dünya eksenleri.
static func kose(p: Node3D, sz: float, walk: float, dip: float, lod: int, yonler: Array, seed: int) -> void:
	var h := sz * 0.5
	var c := sz * 0.29
	var poly := PackedVector2Array([Vector2(-h + c, -h), Vector2(h - c, -h), Vector2(h, -h + c), Vector2(h, h - c),
		Vector2(h - c, h), Vector2(-h + c, h), Vector2(-h, h - c), Vector2(-h, -h + c)])
	var tas := Ag.new()
	var y0 := -dip - 0.3
	var acik := {}
	for i in poly.size():
		var nn := _dis_normal(poly[i], poly[(i + 1) % poly.size()], Vector2.ZERO)
		for yv in yonler:
			if nn.dot(yv as Vector2) > 0.45:
				acik[i] = true
	if lod == 0:
		var ys := walk * 0.5
		var prof: Array = [[y0, 0.5], [0.6, 0.5], [0.9, 0.24], [ys, 0.1], [ys, 0.24], [ys + 0.3, 0.24], [ys + 0.3, 0.08],
			[walk - 0.6, 0.0], [walk - 0.6, 0.15], [walk - 0.3, 0.15], [walk - 0.3, 0.3], [walk, 0.3]]
		var tint := func(e: int, y: float, t: float) -> Color:
			var hh := fposmod(sin(float(e) * 5.3 + floor(y / 2.5) * 2.1 + floor(t * 2.0) * 1.3 + seed) * 3711.7, 1.0)
			return Color(0.76, 0.74, 0.7) if hh < 0.12 else Color.WHITE
		_or(tas, poly, prof, {}, tint, 0.06, seed, 2)
	else:
		_or(tas, poly, [[y0, 0.4], [walk - 0.4, 0.0], [walk - 0.4, 0.3], [walk, 0.3]], {}, Callable(), 0.0, seed)
	var top := _otele(poly, 0.3)
	_kapak(tas, top, walk, true)
	# korkuluk ve dişler (yürüme yönlerinde açık)
	var ic := _otele(poly, -0.15)
	for i in top.size():
		if acik.has(i):
			continue
		var j := (i + 1) % top.size()
		var a := top[i]
		var b := top[j]
		var L := a.distance_to(b)
		var t2 := (b - a) / L
		var nn := _dis_normal(a, b, Vector2.ZERO)
		var o := (a + b) * 0.5 - nn * 0.45
		tas.kutu(_v3(o, walk), Vector3(t2.x, 0, t2.y), Vector3(nn.x, 0, nn.y), L, PARAPET_H, 0.45)
		if lod <= 1:
			var m := maxi(1, floori((L - 0.3) / 1.8))
			for k in m:
				var hh := fposmod(sin(float(i * 7 + k) * 3.1 + seed) * 917.3, 1.0)
				if hh < 0.1:
					continue
				var s := (float(k) - (m - 1) * 0.5) * 1.8
				tas.kutu(_v3(o + t2 * s, walk + PARAPET_H), Vector3(t2.x, 0, t2.y), Vector3(nn.x, 0, nn.y), 0.95, 0.7 if hh > 0.22 else 0.35, 0.45)
		if lod == 0:
			_carp_duvar(p, a, b, ic[i], walk, walk + PARAPET_H)
	tas.mesh_ekle(p, _tas_mat(C_STONE.darkened(0.03), lod), "KoseKule")
	if lod <= 1:
		_carp_prizma(p, top, y0, walk, lod == 0)
