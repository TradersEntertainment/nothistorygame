class_name IstOrdugahCephe
extends RefCounted
## Ön hat (ORDUGÂH-4, docs/ORDUGAH_1453.md §1.3, §4.4, §7b 41–50): siperin (sedde + kazık perde) arkasında ve önünde
## asker, işçi ve gereç. Hendekten itibaren ilk 60 m SUR-4'ün "ateş alanı" zemini; siper hattı (d ≈ 112) o sınırda, öğeler
## siperin ARKASINA (sura uzak yana) dizilir; perdenin önüne yalnız yere saplanmış oklar ve kırık kalkanlar.
##   siper(host, line, lod, tohum)      siper dilimi boyunca: okçu/mızraklı sırası, kazan işçiler, merdiven/kalas istifi,
##                                      çalı-tomruk (hendek doldurma) yığını, gülle yığını, meşale direkleri
##   batarya(host, n, buyuk, lod, tohum) top başında doldurma ekibi, nöbetçi, taşıyıcılar; Şahi'de öküz sırası
## Yerel çerçeve: siper için çizgi host yerelinde; batarya Y.build_batarya ile aynı (ön = +z).

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const B = K.Bld
const KS = preload("res://scripts/world/ist/ordugah_kisi.gd")
const Y = preload("res://scripts/world/ist/ordugah_yapi.gd")


static func siper(host: Node3D, line: PackedVector2Array, lod: int, tohum := 8) -> void:
	if line.size() < 2 or lod >= 2:
		return
	var r := K.rr(tohum + 77)
	var wd := B.new("wood")
	var e := B.new("rubble") if lod == 0 else wd
	var m := B.new("") if lod == 0 else wd
	var kisi: Array = []
	var fires: Array = []
	var acc := 0.0
	var next_grp := r.randf_range(2.0, 6.0)
	var next_ist := r.randf_range(10.0, 20.0)
	var next_mes := 9.0
	var k_ist := 0
	for i in line.size() - 1:
		var a := line[i]
		var b2 := line[i + 1]
		var d := b2 - a
		var L := d.length()
		if L < 0.1:
			continue
		var dn := d / L
		var fr := Vector2(-dn.y, dn.x)          # ön (sura doğru): IstOrdugahYapi2.front_of
		var back := -fr
		var yaw_f := atan2(fr.x, fr.y)
		var s := 0.0
		while s < L:
			var p := a + dn * s
			var at := acc + s
			# kişi kümesi: perdenin hemen arkasında okçu/mızraklı, seddenin arkasında işçi
			if at >= next_grp:
				next_grp += r.randf_range(4.5, 7.5)
				var n := r.randi_range(2, 4)
				for q in n:
					var off := dn * r.randf_range(-1.6, 1.6)
					var pq := p + back * r.randf_range(2.6, 3.4) + off
					var tp := "okcu" if r.randf() < 0.55 else ("azap" if r.randf() < 0.7 else "nobet")
					kisi.append([Vector3(pq.x, K.gy(pq.x, pq.y), pq.y), yaw_f + r.randf_range(-0.25, 0.25), tp])
				# seddenin arkasında kazan / taşıyan işçi
				if r.randf() < 0.7:
					var pw := p + back * r.randf_range(6.0, 9.0) + dn * r.randf_range(-2.0, 2.0)
					var tp2 := "kazma" if r.randf() < 0.6 else "saka"
					kisi.append([Vector3(pw.x, K.gy(pw.x, pw.y), pw.y), yaw_f + (0.0 if tp2 == "kazma" else r.randf_range(1.2, 2.0)), tp2])
			# istif: merdiven / çalı-tomruk / gülle / kalas, sırayla
			if at >= next_ist:
				next_ist += r.randf_range(14.0, 22.0)
				var pi_ := p + back * r.randf_range(10.0, 13.0)
				var y := K.gy(pi_.x, pi_.y)
				var yd := rad_to_deg(atan2(-dn.y, dn.x))
				match k_ist % 4:
					0: _merdivenler(wd, Vector3(pi_.x, y, pi_.y), yd, r)
					1: _cali_tomruk(wd, e, Vector3(pi_.x, y, pi_.y), yd, r)
					2: Y._gulle_piramit(m, Vector3(pi_.x, y, pi_.y), 0.3, 3, K.TAS)
					3: _kalas(wd, Vector3(pi_.x, y, pi_.y), yd)
				k_ist += 1
				# yığının başında iş yapan
				if r.randf() < 0.6:
					var pk := pi_ + back * 2.8
					kisi.append([Vector3(pk.x, K.gy(pk.x, pk.y), pk.y), yaw_f, "balta" if k_ist % 4 == 2 else "kazma"])
			# meşale direği (gece alev)
			if at >= next_mes:
				next_mes += 22.0
				var pm := p + back * 4.6
				var ym := K.gy(pm.x, pm.y)
				wd.cylp(Vector3(pm.x, ym + 1.3, pm.y), 0.05, 2.6, K.AHSAP2, 5)
				wd.cylp(Vector3(pm.x, ym + 2.65, pm.y), 0.12, 0.25, Color("3a2a1a"), 6, 0.08)
				fires.append(Vector2(pm.x, pm.y))
			# perdenin önü: yere saplanmış oklar, kırık kalkan (lod 0)
			if lod == 0 and r.randf() < 0.18:
				var pa := p + fr * r.randf_range(8.0, 12.0)
				var ya := K.gy(pa.x, pa.y)
				for q in r.randi_range(2, 5):
					var o := Vector3(pa.x + r.randf_range(-1.2, 1.2), ya, pa.y + r.randf_range(-1.2, 1.2))
					wd.rod(o, o + Vector3(fr.x * 0.35 + r.randf_range(-0.1, 0.1), 0.62, fr.y * 0.35), 0.025, K.AHSAP_A)
				if r.randf() < 0.3:
					wd.cylp(Vector3(pa.x + 1.0, ya + 0.06, pa.y), 0.35, 0.05, K.AHSAP.darkened(0.2), 7, -1.0, Vector3(r.randf_range(-10, 10), 0, 8))
			s += 1.5
		acc += L
	wd.done(host, "cephe_ahsap")
	if lod == 0:
		e.done(host, "cephe_toprak")
		m.done(host, "cephe_gulle")
	KS.kur(host, kisi, lod)
	K.ateslar(host, fires, lod, 2.75)


static func _merdivenler(w: B, p: Vector3, yaw: float, r: RandomNumberGenerator) -> void:
	for i in r.randi_range(3, 5):
		var o := Vector3(0, 0.12 + i * 0.14, i * 0.15)
		var L := r.randf_range(7.0, 9.0)
		for sd in [-0.32, 0.32]:
			w.box(p + Vector3(0, 0, sd).rotated(Vector3.UP, deg_to_rad(yaw)) + o.rotated(Vector3.UP, deg_to_rad(yaw)), Vector3(L, 0.1, 0.08), K.AHSAP_A, yaw)
		for q in int(L / 0.6):
			w.box(p + Vector3(-L * 0.5 + 0.3 + q * 0.6, 0, 0).rotated(Vector3.UP, deg_to_rad(yaw)) + o.rotated(Vector3.UP, deg_to_rad(yaw)), Vector3(0.06, 0.06, 0.7), K.AHSAP, yaw)
	w.solid_box(p + Vector3(0, 0.45, 0.3).rotated(Vector3.UP, deg_to_rad(yaw)), Vector3(8.0, 0.9, 1.2), yaw)


static func _cali_tomruk(w: B, e: B, p: Vector3, yaw: float, r: RandomNumberGenerator) -> void:
	for i in 7:
		var o := Vector3(r.randf_range(-2.0, 2.0), 0.25 + (i % 3) * 0.3, r.randf_range(-0.8, 0.8)).rotated(Vector3.UP, deg_to_rad(yaw))
		w.cylp(p + o, 0.2, r.randf_range(3.0, 4.5), K.AHSAP.darkened(0.1 * (i % 3)), 6, -1.0, Vector3(0, 0, 90), yaw + r.randf_range(-12, 12))
	# çalı demetleri (hendek doldurma)
	for i in 6:
		var o2 := Vector3(-2.5 + i * 1.0, 0.45, 1.6).rotated(Vector3.UP, deg_to_rad(yaw))
		e.sph(p + o2, 0.55, Color("6a5a3a").lerp(Color("4a4428"), r.randf()), 5, Vector3(1.0, 0.75, 1.3))
	w.solid_box(p + Vector3(0, 0.55, 0.4).rotated(Vector3.UP, deg_to_rad(yaw)), Vector3(5.5, 1.1, 3.0), yaw)


static func _kalas(w: B, p: Vector3, yaw: float) -> void:
	for i in 6:
		w.box(p + Vector3(0, 0.07 + i * 0.12, (i % 2) * 0.1), Vector3(4.5, 0.1, 1.2), K.AHSAP_A.darkened(0.06 * (i % 3)), yaw)
	w.solid_box(p + Vector3(0, 0.37, 0), Vector3(4.6, 0.74, 1.4), yaw)


## Bataryanın ekibi: her topun ardında tokmakçı + manivelacı, gülle taşıyan, barut fıçısının yanında nöbetçi; sedde arkasında
## okçu. Şahi'de 14 öküz daha (toplam 20; §4.2: gerçekte 60, gerisi yolda/ağılda).
static func batarya(host: Node3D, n: int, buyuk: bool, lod: int, tohum := 7) -> void:
	if lod >= 2:
		return
	var r := K.rr(tohum + 33)
	var sp := (12.0 if buyuk else 8.5)
	var W := n * sp + 8.0
	var D := 15.0 if buyuk else 11.0
	var TH := 1.0
	var fz := D / 2.0 - 2.2
	var seg_w := (W - n * 2.6) / (n + 1.0)
	var x0 := -W / 2.0 + seg_w
	var kisi: Array = []
	var L := 8.2 if buyuk else 3.8
	for i in n:
		var gx := x0 + 1.3
		var tz := fz - 3.2        # top yatağının arka ucu
		# tokmakçı (namlu ağzına doğru, yan), manivelacı arkada, topçu başı
		kisi.append([Vector3(gx + (1.7 if buyuk else 1.3), TH, minf(tz + L * 0.3, fz - 2.7)), 0.0, "tokmak"])
		kisi.append([Vector3(gx - (1.7 if buyuk else 1.3), TH, tz - 0.6), 0.3, "manivela"])
		kisi.append([Vector3(gx + 0.4, TH, tz - 1.7), 0.0, "nobet" if i % 2 == 0 else "azap"])
		kisi.append([Vector3(gx + 2.6, TH, fz - 5.6), PI * 0.6, "saka"])
		x0 += seg_w + 2.6
	# sedde arkası okçular / mızraklılar
	for q in maxi(2, n):
		kisi.append([Vector3(-W * 0.5 + 2.0 + q * (W - 4.0) / maxf(1.0, maxi(2, n) - 1.0), TH, fz - 2.6), r.randf_range(-0.2, 0.2), "okcu"])
	# arkada: gülle arabası başında ve öküzlerin yanında
	kisi.append([Vector3(-W * 0.25 + 1.6, 0, -D / 2.0 - 3.4), PI, "kazma"])
	kisi.append([Vector3(-W * 0.25 + 4.2, 0, -D / 2.0 - 9.5), -PI / 2.0, "seyis"])
	var hay := PackedVector3Array()
	if buyuk:
		var w := B.new("wood")
		for i in 14:
			var p := Vector3(-14.0 + (i % 7) * 2.3, 0, -D / 2.0 - 14.0 - (i / 7) * 3.2)
			Y._okuz(w, p, 0.0, r)
			hay.append(p)
		w.done(host, "okuz_sirasi")
		kisi.append([Vector3(-16.0, 0, -D / 2.0 - 15.5), PI / 2.0, "seyis"])
		kisi.append([Vector3(3.0, 0, -D / 2.0 - 15.5), -PI / 2.0, "seyis"])
	for i in 2:
		hay.append(Vector3(-W * 0.25 + 2.7, 0, -D / 2.0 - 8.5 - i * 2.0))
	# yerel y: zemine oturt (teras üstündekiler TH'de)
	for k: Array in kisi:
		var p0: Vector3 = k[0]
		if p0.y < 0.5:
			p0.y = K.gy(p0.x, p0.z)
		k[0] = p0
	for i in hay.size():
		hay[i] = Vector3(hay[i].x, K.gy(hay[i].x, hay[i].z), hay[i].z)
	KS.kur(host, kisi, lod)
	host.set_meta("hayvanlar", hay)
