class_name IstOrdugahDonanma
extends RefCounted
## Donanma ve kıyı gereçleri: Çifte Sütunlar (Diplokionion, Beşiktaş) tersane kıyısı, gemilerin karadan yürütüldüğü kızak yolu
## (22 Nisan 1453; Tophane → Kasımpaşa), Haliç'te fıçı köprüsü. Su düzeyi y = 0. Deniz yerel −z yönünde (Diplokionion).

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const B = K.Bld
const Y = preload("res://scripts/world/ist/ordugah_yapi.gd")


## Kızakta/stokta duran kadırga gövdesi (gemiler oturumunun gerçek gemileri ayrıdır; bu, kıyı sahnesidir).
static func _govde(b: B, w: B, p: Vector3, yaw: float, boy := 24.0, en := 5.0, tam := true) -> void:
	var c := Vector3(p.x, 0, p.z)
	var yy := p.y
	# gövde bloğu: dar omurga tabanı → geniş küpeşte
	var f := func(v: Vector3) -> Vector3:
		return c + v.rotated(Vector3.UP, deg_to_rad(yaw))
	# üç dilim: pruva, orta, kıç
	var parts := [[-boy * 0.38, boy * 0.24, 0.8, 0.6], [0.0, boy * 0.52, 1.0, 1.0], [boy * 0.38, boy * 0.24, 0.8, 0.5]]
	for pr in parts:
		var cx: float = pr[0]
		var ln: float = pr[1]
		var wd := en * (pr[2] as float)
		var hh := 2.3 if cx == 0.0 else 2.9
		var bw := 1.2
		var pts := [Vector3(-ln / 2, yy + 0.6, -bw / 2), Vector3(ln / 2, yy + 0.6, -bw / 2), Vector3(ln / 2, yy + 0.6, bw / 2), Vector3(-ln / 2, yy + 0.6, bw / 2),
			Vector3(-ln / 2, yy + 0.6 + hh, -wd / 2), Vector3(ln / 2, yy + 0.6 + hh, -wd / 2), Vector3(ln / 2, yy + 0.6 + hh, wd / 2), Vector3(-ln / 2, yy + 0.6 + hh, wd / 2)]
		var wp: Array = []
		for q in pts:
			wp.append(f.call(Vector3(q.x + cx, q.y, q.z)))
		var cc: Vector3 = f.call(Vector3(cx, yy + 0.6 + hh / 2, 0))
		var fcs := [[0, 1, 2, 3], [4, 7, 6, 5], [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3], [3, 7, 4, 0]]
		for fi in fcs.size():
			var q2: Array = []
			var m := Vector3.ZERO
			for jj in fcs[fi]:
				q2.append(wp[jj])
				m += wp[jj]
			m /= 4.0
			var col := K.AHSAP.lerp(Color("2e4a6a"), 0.35 if fi in [2, 3] else 0.0)
			if fi == 1:
				col = K.AHSAP_A
			w.poly(q2, m - cc, col.darkened(0.04 * (fi % 3)))
		w.solid_hull(PackedVector3Array(wp))
	# pruva bodoslama, kıç yükseltisi, direk, seren
	w.rod(f.call(Vector3(-boy / 2 - 0.4, yy + 1.4, 0)), f.call(Vector3(-boy / 2 - 1.4, yy + 4.2, 0)), 0.3, K.AHSAP2)
	w.box(f.call(Vector3(boy / 2 - 1.2, yy + 4.2, 0)), Vector3(4.0, 0.3, en * 0.8), K.AHSAP_A, yaw)
	b.cylp(f.call(Vector3(-1.0, yy + 8.8, 0)), 0.22, 11.0, K.AHSAP2, 6)
	b.rod(f.call(Vector3(-9.0, yy + 12.0, 0)), f.call(Vector3(8.0, yy + 6.5, 0)), 0.14, K.AHSAP_A)
	b.solid_cyl(f.call(Vector3(-1.0, yy + 8.8, 0)), 0.25, 11.0)
	# kürek sırası (kalın hat)
	for i in 10:
		var x := -boy * 0.3 + i * 2.0
		b.rod(f.call(Vector3(x, yy + 3.3, en * 0.5)), f.call(Vector3(x + 0.6, yy + 1.0, en * 0.5 + 2.8)), 0.1, K.AHSAP_A)
		b.rod(f.call(Vector3(x, yy + 3.3, -en * 0.5)), f.call(Vector3(x + 0.6, yy + 1.0, -en * 0.5 - 2.8)), 0.1, K.AHSAP_A)
	# yan destek kütükleri (stok)
	for i in 5:
		var x2 := -boy * 0.4 + i * (boy * 0.2)
		w.box(f.call(Vector3(x2, yy + 0.2, 0)), Vector3(0.5, 0.4, en + 2.0), K.AHSAP2, yaw)
		w.box(f.call(Vector3(x2, yy + 1.2, en * 0.5 + 0.9)), Vector3(0.2, 2.0, 0.2), K.AHSAP2, yaw, Vector3(15, 0, 0))
		w.box(f.call(Vector3(x2, yy + 1.2, -en * 0.5 - 0.9)), Vector3(0.2, 2.0, 0.2), K.AHSAP2, yaw, Vector3(-15, 0, 0))


static func build_diplokionion(host: Node3D, k: float, lod: int, tohum := 12) -> void:
	var r := K.rr(tohum)
	var t := B.new("ashlar")
	var w := B.new("wood")
	var m := B.new("")
	var c := B.new("plaster")
	var kz := Y.kk(k)
	# Çifte Sütunlar: iki yüksek sütun, ortak kaide ve basamak (KESTİRİM: Bizans dönemi sütunlu liman yapısı, biçim belirsiz)
	for sx in [-1, 1]:
		var cx: float = sx * 4.0
		t.box(Vector3(cx, 0.7, 6.0), Vector3(2.4, 1.4, 2.4), K.TAS)
		t.solid_box(Vector3(cx, 0.7, 6.0), Vector3(2.4, 1.4, 2.4))
		t.cylp(Vector3(cx, 1.4 + 3.8, 6.0), 0.58, 7.6, K.TAS.lightened(0.08), 12, 0.52)
		t.solid_cyl(Vector3(cx, 1.4 + 3.8, 6.0), 0.6, 7.6)
		t.box(Vector3(cx, 9.3, 6.0), Vector3(1.7, 0.5, 1.7), K.TAS.lightened(0.12))
		t.box(Vector3(cx, 9.75, 6.0), Vector3(1.5, 0.45, 1.5), K.TAS)
		t.solid_box(Vector3(cx, 9.55, 6.0), Vector3(1.7, 0.95, 1.7))        # başlık: Nihat konma noktası
	t.box(Vector3(0, 9.2, 6.0), Vector3(6.4, 0.5, 1.1), K.TAS.darkened(0.06))
	t.solid_box(Vector3(0, 9.2, 6.0), Vector3(6.4, 0.5, 1.1))
	for i in 3:
		t.box(Vector3(0, 0.1 + i * 0.22, 3.6 - i * 0.7), Vector3(11.0 - i * 1.2, 0.22, 1.6), K.TAS.darkened(0.04 * i))
		t.solid_box(Vector3(0, 0.1 + i * 0.22, 3.6 - i * 0.7), Vector3(11.0 - i * 1.2, 0.22, 1.6))
	# iskele: suya uzanan ahşap rıhtım (güverte y = 0,85), kazıklar
	var L := 34.0 * kz
	w.box(Vector3(0, 0.85, -L / 2), Vector3(4.0, 0.14, L), K.AHSAP_A)
	w.solid_box(Vector3(0, 0.75, -L / 2), Vector3(4.0, 0.34, L))
	for i in int(L / 3.0):
		for sx in [-1.9, 1.9]:
			w.cylp(Vector3(sx, 0.2, -1.5 - i * 3.0), 0.16, 1.6, K.AHSAP2, 6)
	# kara ucu basamak (sahil kotu 0–1 m: iki basamak rampa)
	w.box(Vector3(0, 0.32, 1.9), Vector3(4.0, 0.64, 1.4), K.AHSAP)
	w.solid_box(Vector3(0, 0.32, 1.9), Vector3(4.0, 0.64, 1.4))
	# kızakta iki gemi (stok)
	if lod <= 1:
		for i in 2:
			var gp := Vector3(-20.0 + i * 38.0, 0, 15.0)
			_govde(m, w, Vector3(gp.x, 0.1, gp.z), 90.0 + i * 6.0, 24.0, 5.2)
	else:
		w.box(Vector3(-20.0, 2.0, 15.0), Vector3(5.0, 4.0, 24.0), K.AHSAP)
		w.box(Vector3(18.0, 2.0, 15.0), Vector3(5.0, 4.0, 24.0), K.AHSAP)
	# depo çadırı, kereste yığınları, halat makarası, katran kazanı
	var tr: Array = []
	var tc: Array = []
	for i in 3:
		var p := Vector3(-12.0 + i * 12.0, 0, 32.0)
		tr.append(Transform3D(Basis.from_euler(Vector3(0, r.randf() * TAU, 0)).scaled(Vector3(2.6, 1.3, 2.6)), p))
		tc.append(K.BEZ2)
		c.solid_cyl(p + Vector3(0, 1.5, 0), 2.55, 3.0)
	K.mm(host, K.tent_mesh("yuvarlak"), tr, tc, "depo", "plaster", true)
	for i in 4:
		for q in 5 - i:
			w.cylp(Vector3(-30.0 + i * 0.8, 0.22 + i * 0.4, 6.0 + q * 0.5 - 1.0), 0.2, 6.0, K.AHSAP_A, 6, -1.0, Vector3(0, 0, 90), 6.0)
	w.solid_box(Vector3(-28.8, 0.9, 6.0), Vector3(6.4, 1.8, 3.0))
	m.cylp(Vector3(24.0, 0.7, 36.0), 0.7, 0.9, K.DEMIR, 10, 0.9)
	m.solid_cyl(Vector3(24.0, 0.7, 36.0), 0.75, 1.4)
	if lod <= 1:
		Flame.add(host, Vector3(24.0, 1.2, 36.0), 0.45, 0.7)
		w.cylp(Vector3(30.0, 1.0, 34.0), 0.5, 2.0, K.AHSAP2, 8)         # çıkrık
		w.cylp(Vector3(30.0, 2.2, 34.0), 0.12, 2.6, K.AHSAP, 6, -1.0, Vector3(0, 0, 90))
		w.solid_cyl(Vector3(30.0, 1.0, 34.0), 0.6, 2.0)
	var sf := B.new()
	Y.sancak(w, sf, Vector3(-4.0, 0, 9.5), 7.0, K.KIRMIZI)
	t.done(host, "sutun")
	w.done(host, "ahsap")
	m.done(host, "gemi")
	c.done(host, "bez")
	sf.done(host, "bayrak")


## Kızak yolu: line = host yerel polyline (≥ 2 nokta). Düz ahşap güverte (4 m, 12 cm), iki ray, enine traversler,
## yağ lekesi, yuvarlak kütükler, halat; ilk dilimde yola çekilmiş bir gövde ("izi").
static func build_kizak(host: Node3D, k: float, lod: int, tohum := 10, line := PackedVector2Array(), gemi := false) -> void:
	if line.size() < 2:
		line = PackedVector2Array([Vector2(-50, 0), Vector2(50, 0)])
	var r := K.rr(tohum)
	var w := B.new("wood")
	var g := B.new("")
	g.cast = false
	var rp := B.new("wood")
	for i in line.size() - 1:
		var a := line[i]
		var b2 := line[i + 1]
		var d := b2 - a
		var L := d.length()
		if L < 0.1:
			continue
		var dn := d / L
		var yaw := rad_to_deg(atan2(-dn.y, dn.x))
		var nseg := maxi(int(ceil(L / 4.0)), 1)
		for s in nseg:
			var p0 := a.lerp(b2, float(s) / nseg)
			var p1 := a.lerp(b2, float(s + 1) / nseg)
			var pm := (p0 + p1) * 0.5
			var sl := p0.distance_to(p1)
			var y0 := K.gy(pm.x, pm.y)
			var zl := Vector3(pm.x, y0 + 0.08, pm.y)
			# güverte (kalas), yumuşak giriş kenarı
			w.box(zl, Vector3(sl + 0.04, 0.16, 4.4), K.AHSAP_A.darkened(0.04 * (s % 3)), yaw)
			w.solid_box(zl, Vector3(sl + 0.04, 0.16, 4.4), yaw)
			# yağ lekesi (ortada koyu şerit; üst yüzeye ≥ 2 cm pay)
			g.box(zl + Vector3(0, 0.1, 0), Vector3(sl, 0.03, 1.2), Color("2a2118"), yaw)
			# iki ray
			for sd in [-1, 1]:
				var off: Vector3 = Vector3(-dn.y, 0, dn.x) * (sd * 1.1)
				rp.box(zl + off + Vector3(0, 0.18, 0), Vector3(sl + 0.04, 0.2, 0.32), K.AHSAP2, yaw)
				rp.solid_box(zl + off + Vector3(0, 0.18, 0), Vector3(sl + 0.04, 0.2, 0.32), yaw)
			# traversler (her 1,3 m)
			if lod == 0:
				for q in 3:
					var tp := p0.lerp(p1, (q + 0.5) / 3.0)
					rp.box(Vector3(tp.x, K.gy(tp.x, tp.y) + 0.19, tp.y), Vector3(0.28, 0.06, 3.8), K.AHSAP, yaw)
				if (s + tohum) % 5 == 0:
					var lp := pm + Vector2(-dn.y, dn.x) * (r.randf_range(-3.2, 3.2))
					rp.cylp(Vector3(lp.x, K.gy(lp.x, lp.y) + 0.35, lp.y), 0.22, 3.0, K.AHSAP2, 7, -1.0, Vector3(0, 0, 90), yaw + 90.0)
	if gemi and not line.is_empty():
		var mid := (line[0] + line[line.size() - 1]) * 0.5
		var dd := (line[line.size() - 1] - line[0]).normalized()
		var yaw2 := rad_to_deg(atan2(-dd.y, dd.x))
		_govde(g, w, Vector3(mid.x, K.gy(mid.x, mid.y) + 0.35, mid.y), yaw2, 22.0, 5.0)
	w.done(host, "guverte")
	rp.done(host, "ray")
	g.done(host, "yag")


## Fıçı köprüsü: x ekseni boyunca [−L/2, +L/2], z = 0 ortada; güverte üstü y = 0,95; su y = 0.
static func build_fici_kopru(host: Node3D, k: float, lod: int, tohum := 15, uzunluk := 160.0) -> void:
	var r := K.rr(tohum)
	var w := B.new("wood")
	var L := uzunluk
	var W := 5.0
	# fıçılar: 5 sıra, 1 m aralık; çoklu ağ
	var barrel := B.new("wood")
	barrel.cyl(B.xf(Vector3.ZERO, 0.0, Vector3(0, 0, 90)), 0.46, 1.0, K.AHSAP, 8)
	barrel.cyl(B.xf(Vector3(0.28, 0, 0), 0.0, Vector3(0, 0, 90)), 0.47, 0.05, K.DEMIR, 8)
	barrel.cyl(B.xf(Vector3(-0.28, 0, 0), 0.0, Vector3(0, 0, 90)), 0.47, 0.05, K.DEMIR, 8)
	var bmesh := K.bld_mesh(barrel)
	var xfs: Array = []
	var step := 1.05 if lod == 0 else 2.1
	var nx := int(L / step)
	for i in nx:
		for j in 5:
			xfs.append(Transform3D(Basis.IDENTITY, Vector3(-L / 2 + (i + 0.5) * step, 0.18 + r.randf_range(-0.03, 0.03), (j - 2) * 1.0)))
	K.mm(host, bmesh, xfs, [], "fici", "wood", false)
	# güverte: 4,6 m kalas döşeme (katı), enine kalaslar
	w.box(Vector3(0, 0.88, 0), Vector3(L, 0.14, W - 0.4), K.AHSAP_A)
	w.solid_box(Vector3(0, 0.82, 0), Vector3(L, 0.26, W - 0.4))
	for sd in [-1, 1]:
		w.box(Vector3(0, 0.62, sd * (W / 2 - 0.1)), Vector3(L, 0.12, 0.3), K.AHSAP2)
	var nseg := int(L / 4.0)
	for i in nseg + 1:
		var x := -L / 2 + i * (L / nseg)
		for sd in [-1, 1]:
			w.cylp(Vector3(x, 1.45, sd * (W / 2 - 0.15)), 0.06, 1.1, K.AHSAP2, 5)
			if lod == 0:
				w.solid_cyl(Vector3(x, 1.45, sd * (W / 2 - 0.15)), 0.08, 1.1)
	if lod <= 1:
		for sd in [-1, 1]:
			w.box(Vector3(0, 1.95, sd * (W / 2 - 0.15)), Vector3(L, 0.06, 0.06), K.DERI.darkened(0.2))
			w.solid_box(Vector3(0, 1.5, sd * (W / 2 - 0.1)), Vector3(L, 1.1, 0.12))
		if lod == 0:
			for i in nx / 6:
				var xx := -L / 2 + 3.0 + i * 6.3
				w.box(Vector3(xx, 0.97, r.randf_range(-1.5, 1.5)), Vector3(0.9, 0.04, 0.12), K.AHSAP2, r.randf_range(0, 360))
	# her iki ucu: sahil rampası (güverte → zemin), 5 m
	for sd in [-1, 1]:
		Y.earth_rampa(w, Vector3(sd * (L / 2 + 5.0), 0.0, 0), Vector3(sd * (L / 2 + 0.2), 0.95, 0), W - 0.4, K.AHSAP_A, true)
	w.done(host, "guverte")
