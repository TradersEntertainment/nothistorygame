class_name IstOrdugahOtag
extends RefCounted
## Otağ-ı hümayun kompleksi (ORDUGÂH-4, docs/ORDUGAH_1453.md §2.2, §5.2, §7d-5): kırmızı-altın ana otağ, önünde sayebân,
## çevresinde dikdörtgen KUMAŞ ZOKAK (beyaz, lacivert bant, mazgallı üst; kazık çit değil), içinde divan (iki kırmızı),
## hazine, kilar, mutfak (turuncu, duman delikli), kurba (hamam), namazgâh; kapı önünde tuğ grubu (7) ve mehterhane;
## zokak dışında çeşitli boyda yeniçeri orta çadırları halkası (önlerinde kazan, oturanlar). Kırmızı YALNIZ otağ, divan
## ve sayebânda. Hilal YOK (alem küre). Yerel: ön (kapı) = +z (sura).
## Konma noktaları IstOrdugah.perches_otag ile aynı yerde: alem (0, 11.7, 0), gözcü kulesi (−17·kz, 6.6, −14),
## kapı sancağı (−7,5, 9,1, 17,5).

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const CD = preload("res://scripts/world/ist/ordugah_cadir.gd")
const OC = preload("res://scripts/world/ist/ordugah_ocak.gd")
const B = K.Bld
const Y = preload("res://scripts/world/ist/ordugah_yapi.gd")
const KS = preload("res://scripts/world/ist/ordugah_kisi.gd")
const OB = preload("res://scripts/world/ist/ordugah_oba.gd")

const ZX := 38.0         # zokak yarı eni (x)
const ZZ := 30.0         # zokak yarı derinliği (z)
const ZH := 3.0
const TURUNCU := Color("c87a2e")


static func build(host: Node3D, k: float, lod: int) -> void:
	var r := K.rr(1453)
	var cloth := B.new("plaster")
	var wood := B.new("wood")
	var earth := B.new("rubble")
	var met := B.new("")
	cloth.no_climb = true
	var R := 8.5
	var kz := Y.kk(k)
	var kisi: Array = []
	var fires: Array = []
	var duman_pts: Array = []
	# --- zemin: zokak içi çiğnenmiş toprak + halı yolları
	earth.box(Vector3(0, 0.08, 0), Vector3(ZX * 2.0 - 1.0, 0.16, ZZ * 2.0 - 1.0), Color("8d7a58"))
	earth.solid_box(Vector3(0, 0.08, 0), Vector3(ZX * 2.0 - 1.0, 0.16, ZZ * 2.0 - 1.0))
	# --- ana otağ (kırmızı-altın, alem küre)
	# ORDUGÂH-5: kumaş otağ (sarkık kırmızı çatı, taraklı altın saçak, ip-kazık, açık kapı ve içi; ordugah_cadir.gd "otag")
	CD.ekle(host, "otag", Transform3D(Basis().scaled(Vector3(R, 1.0, R)), Vector3(0, 0.06, 0)), Color.WHITE, lod, "otag_cadiri")
	cloth.cylp(Vector3(0, 9.6, 0), 0.09, 2.6, K.ALTIN, 6)
	cloth.sph(Vector3(0, 11.0, 0), 0.4, K.ALTIN, 6)
	cloth.sph(Vector3(0, 11.62, 0), 0.14, K.ALTIN, 4)
	cloth.box(Vector3(-1.4, 1.9, R + 0.08), Vector3(0.28, 3.8, 0.12), K.ALTIN)
	cloth.box(Vector3(1.4, 1.9, R + 0.08), Vector3(0.28, 3.8, 0.12), K.ALTIN)
	cloth.box(Vector3(0, 3.7, R + 0.08), Vector3(3.1, 0.28, 0.12), K.ALTIN)
	if lod <= 1:
		for i in 16:
			var a := TAU * (i + 0.5) / 16.0
			if absf(a - PI / 2.0) < 0.28:
				continue
			var wp := Vector3(cos(a) * (R + 0.03), 2.6, sin(a) * (R + 0.03))
			var yaw := -rad_to_deg(a) + 90.0
			cloth.box(wp, Vector3(1.5, 2.8, 0.06), K.KREM, yaw)
			cloth.box(wp, Vector3(1.0, 2.0, 0.08), K.LACI, yaw)
			cloth.box(wp + Vector3(0, 1.0, 0), Vector3(0.7, 0.7, 0.09), K.ALTIN, yaw, Vector3(0, 0, 45))
	cloth.solid_cyl(Vector3(0, 3.0, 0), R + 0.1, 6.0)
	cloth.solid_cyl(Vector3(0, 8.0, 0), 4.0, 4.0)
	cloth.solid_cyl(Vector3(0, 11.0, 0), 0.5, 1.2)
	# --- sayebân (önde, 8 × 6 m, altı altın direk, lacivert bordür ve şemse)
	for sx in [-3.6, 0.0, 3.6]:
		for sz in [R + 1.2, R + 6.6]:
			wood.cylp(Vector3(sx, 1.9, sz), 0.09, 3.8, K.ALTIN, 6)
			if lod == 0:
				wood.solid_cyl(Vector3(sx, 1.9, sz), 0.11, 3.8)
	cloth.box(Vector3(0, 3.85, R + 3.9), Vector3(8.0, 0.1, 6.2), K.KIRMIZI, 0.0, Vector3(-4, 0, 0))
	cloth.box(Vector3(0, 3.55, R + 7.0), Vector3(8.0, 0.5, 0.05), K.LACI)
	cloth.cylp(Vector3(0, 3.55, R + 7.04), 0.32, 0.03, K.ALTIN, 12, -1.0, Vector3(90, 0, 0))
	for i in 5:
		var cc: Color = [K.KIRMIZI2, K.LACI, K.YESIL, K.KIRMIZI2, K.LACI][i]
		cloth.box(Vector3(0, 0.18 + i * 0.002, R + 2.0 + i * 1.3), Vector3(4.2 - i * 0.25, 0.03, 1.2), cc)
		cloth.box(Vector3(0, 0.185 + i * 0.002, R + 2.0 + i * 1.3), Vector3(3.2 - i * 0.25, 0.03, 0.5), K.KREM)
	# --- zokak: kumaş duvar, mazgallı (dendanlı) üst, lacivert bant; ön kapı 7 m, arka kapı 3 m
	_zokak(cloth, wood, lod)
	# --- divan çadırları (iki yan, kırmızı çatma)
	for sx2 in [-18.0, 18.0]:
		var pos := Vector3(sx2, 0, 6.0)
		CD.ekle(host, "pasa", Transform3D(Basis().scaled(Vector3(9.0, 0.82, 5.6)), pos + Vector3(0, 0.06, 0)), Color.WHITE, lod, "divan")
		cloth.solid_box(pos + Vector3(0, 2.3, 0), Vector3(9.2, 4.6, 5.8))
		kisi.append([pos + Vector3(-1.6, 0, 3.6), 0.0, "nobet"])
		kisi.append([pos + Vector3(1.6, 0, 3.6), 0.0, "nobet"])
	# --- hazine (krem yuvarlak, sırma bant), kilar (krem çatma), kurba (koyu küçük kubbe), mutfak (turuncu, duman deliği)
	var tp := Vector3(0, 0, -R - 9.0)
	CD.ekle(host, "can", Transform3D(Basis().scaled(Vector3(3.6, 1.15, 3.6)), tp + Vector3(0, 0.06, 0)), K.KREM, lod, "hazine")
	cloth.solid_cyl(tp + Vector3(0, 2.2, 0), 3.7, 4.4)
	kisi.append([tp + Vector3(-1.2, 0, 4.4), 0.0, "nobet"])
	kisi.append([tp + Vector3(1.2, 0, 4.4), 0.0, "nobet"])
	var kl := Vector3(26.0, 0, -14.0)
	CD.ekle(host, "catma", Transform3D(Basis().scaled(Vector3(8.0, 1.15, 5.0)), kl + Vector3(0, 0.06, 0)), Color("e4d8b8"), lod, "kilar")
	cloth.solid_box(kl + Vector3(0, 1.8, 0), Vector3(8.2, 3.6, 5.2))
	var hm := Vector3(26.0, 0, 6.0) if false else Vector3(28.0, 0, -24.0)
	cloth.cylp(hm + Vector3(0, 1.0, 0), 2.6, 2.0, Color("8f8064"), 12)
	cloth.sph(hm + Vector3(0, 2.0, 0), 2.6, Color("7a6c54"), 10, Vector3(1, 0.6, 1))
	cloth.solid_cyl(hm + Vector3(0, 1.5, 0), 2.7, 3.0)
	var mu := Vector3(-26.0, 0, -16.0)
	CD.ekle(host, "buyuk", Transform3D(Basis().scaled(Vector3(10.0, 1.0, 6.0)), mu + Vector3(0, 0.06, 0)), TURUNCU.lightened(0.15), lod, "mutfak")
	duman_pts.append(mu + Vector3(0, 3.4, 0))      # tepe ortasında duman (mutfak)
	cloth.solid_box(mu + Vector3(0, 2.2, 0), Vector3(10.2, 4.4, 6.2))
	for i in 3:
		var kp := mu + Vector3(-3.4 + i * 3.4, 0, 5.2)
		earth.cylp(kp + Vector3(0, 0.3, 0), 1.0, 0.6, K.TAS.darkened(0.15), 10)
		met.cylp(kp + Vector3(0, 0.95, 0), 0.8, 0.8, K.BRONZ.lightened(0.06), 12, 0.9)
		met.cylp(kp + Vector3(0, 1.38, 0), 0.92, 0.1, K.BRONZ.darkened(0.2), 12)
		earth.solid_cyl(kp + Vector3(0, 0.7, 0), 1.0, 1.4)
		fires.append(Vector2(kp.x, kp.z + 0.9))
		kisi.append([kp + Vector3(0, 0, 1.15), PI, "asci"])
	kisi.append([mu + Vector3(5.8, 0, 3.0), -PI / 2.0, "saka"])
	kisi.append([mu + Vector3(-6.2, 0, 2.0), PI / 2.0, "balta"])
	# namazgâh (ak-yeşil küçük çadır, önünde saf)
	var nz := Vector3(-27.0, 0, 8.0)
	CD.ekle(host, "catma", Transform3D(Basis().scaled(Vector3(6.0, 1.0, 4.0)), nz + Vector3(0, 0.06, 0)), Color("f1ead6"), lod, "namazgah")
	cloth.solid_box(nz + Vector3(0, 1.8, 0), Vector3(6.2, 3.6, 4.2))
	for i in 5:
		kisi.append([nz + Vector3(-2.4 + i * 1.2, 0, 3.6), 0.0, "namaz"])
	# --- gözcü kulesi (konma noktası korunur) ve kapı sancakları
	Y._kule_ahsap(wood, Vector3(-17.0 * kz, 0, -14.0), 6.4, lod)
	var sb := B.new()
	var sf := B.new()
	Y.sancak(sb, sf, Vector3(-7.5, 0, R + 9.0), 9.0, K.KIRMIZI)
	Y.sancak(sb, sf, Vector3(7.5, 0, R + 9.0), 9.0, K.YESIL)
	sb.solid_cyl(Vector3(-7.5, 4.5, R + 9.0), 0.1, 9.0)
	# --- kapı önünde tuğ grubu (7, yay biçimli) ve mehterhane (açık tente, davullar)
	for i in 7:
		var a := lerpf(-0.5, 0.5, i / 6.0)
		var tpos := Vector3(sin(a) * 9.0, 0, ZZ + 4.0 + cos(a) * 2.0)
		OB._sancak(sb, sf, tpos, 6.5 + (0.8 if i == 3 else 0.0), K.KIRMIZI, lod, true)
	var mh := Vector3(18.0, 0, ZZ + 8.0)
	for sx3 in [-3.0, 3.0]:
		for sz3 in [-2.4, 2.4]:
			wood.cylp(mh + Vector3(sx3, 1.5, sz3), 0.07, 3.0, K.AHSAP2, 5)
	cloth.box(mh + Vector3(0, 3.0, 0), Vector3(6.6, 0.08, 5.4), K.KIRMIZI2)
	cloth.box(mh + Vector3(0, 2.8, 2.72), Vector3(6.6, 0.4, 0.05), K.ALTIN)
	for i in 4:
		met.cylp(mh + Vector3(-2.2 + i * 1.5, 0.45, 0.6), 0.42 if i % 2 == 0 else 0.3, 0.6, Color("8a5a34"), 10)
		met.cylp(mh + Vector3(-2.2 + i * 1.5, 0.76, 0.6), 0.43 if i % 2 == 0 else 0.31, 0.03, Color("e8dcc0"), 10)
	for i in 4:
		kisi.append([mh + Vector3(-2.2 + i * 1.5, 0, -0.5), 0.0, "otur"])
	# --- kapı nöbeti, sayebânda kâtip/divan bekleyenleri
	for sx4 in [-4.5, -2.8, 2.8, 4.5]:
		kisi.append([Vector3(sx4, 0, ZZ + 0.9), 0.0, "nobet"])
	for sx5 in [-6.0, 6.0]:
		kisi.append([Vector3(sx5, 0, R + 5.0), PI if sx5 > 0 else 0.0, "sipahi"])
	# --- yeniçeri halkası: zokak dışında, çeşitli boy (5–7,5 m), önlerinde kazan ve oturanlar
	var ring_x: Array = []
	var ring_c: Array = []
	var shapes: Array = []
	var pal: Array = OB.PALET["yeniceri"]
	var n := 26
	for i in n:
		var a := TAU * (i + 0.5) / n
		var dir := Vector2(cos(a), sin(a))
		# dikdörtgen zokağın dışında: kenara uzaklık 9–14 m
		var tt := minf(absf((ZX + 11.0) / maxf(absf(dir.x), 0.001)), absf((ZZ + 11.0) / maxf(absf(dir.y), 0.001)))
		var p2 := dir * (tt + r.randf_range(-2.0, 3.0))
		if p2.y > ZZ and absf(p2.x) < 22.0:
			continue          # kapı önü açık (tuğ ve mehterhane)
		var cap := r.randf_range(5.0, 7.6)
		var hs := r.randf_range(0.95, 1.15)
		# ORDUGÂH-5: çan çadır (yeniçeri orta çadırı), kapı (+z) dışa, kazana bakar
		ring_x.append(Transform3D(Basis(Vector3.UP, atan2(dir.x, dir.y)).scaled(Vector3(cap * 0.5, hs, cap * 0.5)), Vector3(p2.x, K.gy(p2.x, p2.y) - 0.1, p2.y)))
		ring_c.append(K.ton(OB._sec(r, pal), r, 0.03))
		shapes.append(Vector3(p2.x, cap * 0.5, p2.y))
		if i % 2 == 0:
			var kp2 := p2 + dir * (cap * 0.5 + 3.0)
			var ky := K.gy(kp2.x, kp2.y)
			earth.cylp(Vector3(kp2.x, ky + 0.1, kp2.y), 0.75, 0.22, K.TAS.darkened(0.25), 8)
			met.cylp(Vector3(kp2.x, ky + 0.62, kp2.y), 0.5, 0.62, K.BRONZ.lightened(0.08), 10, 0.58)
			fires.append(kp2)
			var a0 := r.randf() * TAU
			for q in 5:
				var aa := a0 + q * TAU / 5.0
				var pp := kp2 + Vector2.from_angle(aa) * 2.1
				var fc := kp2 - pp
				kisi.append([Vector3(pp.x, K.gy(pp.x, pp.y), pp.y), atan2(fc.x, fc.y), "otur" if q != 0 else "asci"])
	K.mm(host, K.tent_lod("can", lod), ring_x, ring_c, "ring", "", lod == 0)
	if lod == 0:
		for s: Vector3 in shapes:
			cloth.solid_cyl(Vector3(s.x, K.gy(s.x, s.z) + 1.6, s.z), s.y * 0.97, 3.2)
	# bütün iç kişiler zeminde (zokak içi düz toprak 0,16 m)
	for kk: Array in kisi:
		var p0: Vector3 = kk[0]
		var inside := absf(p0.x) < ZX and absf(p0.z) < ZZ
		p0.y = 0.16 if inside else K.gy(p0.x, p0.z)
		kk[0] = p0
	cloth.done(host, "bez")
	wood.done(host, "ahsap")
	earth.done(host, "zemin")
	met.done(host, "bakir")
	sb.done(host, "dir")
	sf.done(host, "flama")
	KS.kur(host, kisi, lod)
	K.ateslar(host, fires, lod, 0.22, true)
	for f2: Vector2 in fires:
		duman_pts.append(Vector3(f2.x, K.gy(f2.x, f2.y), f2.y))
	OC.duman(host, duman_pts, lod, r)
	if K.gece and lod <= 1:
		var fx: Array = []
		for i in 8:
			var a3 := TAU * i / 8.0
			fx.append(Vector2(cos(a3) * (ZX - 2.0), sin(a3) * (ZZ - 2.0)))
		K.ateslar(host, fx, lod, 1.9)


static func _zokak(c: B, w: B, lod: int) -> void:
	var beyaz := Color("ddd2b4")        # ağartılmamış keten (parlak beyaz değil, §7c)
	var kenar := [[Vector2(-ZX, ZZ), Vector2(-3.5, ZZ)], [Vector2(3.5, ZZ), Vector2(ZX, ZZ)], [Vector2(ZX, ZZ), Vector2(ZX, -ZZ)],
		[Vector2(ZX, -ZZ), Vector2(1.5, -ZZ)], [Vector2(-1.5, -ZZ), Vector2(-ZX, -ZZ)], [Vector2(-ZX, -ZZ), Vector2(-ZX, ZZ)]]
	for e: Array in kenar:
		var a: Vector2 = e[0]
		var b: Vector2 = e[1]
		var d := b - a
		var L := d.length()
		var mid := (a + b) * 0.5
		var yaw := -rad_to_deg(atan2(d.y, d.x))
		c.box(Vector3(mid.x, ZH * 0.5, mid.y), Vector3(L, ZH, 0.08), beyaz, yaw)
		c.box(Vector3(mid.x, ZH - 0.7, mid.y), Vector3(L + 0.02, 0.45, 0.1), K.LACI, yaw)
		c.box(Vector3(mid.x, 0.35, mid.y), Vector3(L + 0.02, 0.3, 0.1), K.KIRMIZI2.darkened(0.2), yaw)
		c.solid_box(Vector3(mid.x, ZH * 0.5, mid.y), Vector3(L, ZH, 0.2), yaw)
		# mazgallı üst (dendan) ve direkler
		var nd := int(L / 1.2)
		for q in nd:
			var t := (q + 0.5) / nd
			var p := a.lerp(b, t)
			if q % 2 == 0:
				c.box(Vector3(p.x, ZH + 0.25, p.y), Vector3(0.6, 0.5, 0.08), beyaz, yaw)
			if lod == 0 and q % 2 == 1:
				c.box(Vector3(p.x, ZH - 0.7, p.y), Vector3(0.28, 0.28, 0.12), K.ALTIN, yaw, Vector3(0, 0, 45))
		var np := int(L / 4.0) + 1
		for q in np:
			var p2 := a.lerp(b, float(q) / maxf(1.0, np - 1))
			w.cylp(Vector3(p2.x, ZH * 0.5 + 0.3, p2.y), 0.06, ZH + 0.6, K.AHSAP2, 5)
	# kapı direkleri ve üst bant
	for sx in [-3.6, 3.6]:
		w.cylp(Vector3(sx, 2.3, ZZ), 0.14, 4.6, K.ALTIN.darkened(0.1), 6)
	c.box(Vector3(0, 4.3, ZZ), Vector3(7.6, 0.6, 0.12), K.KIRMIZI)
	c.box(Vector3(0, 4.3, ZZ + 0.07), Vector3(5.0, 0.3, 0.04), K.ALTIN)
