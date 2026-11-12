class_name IstKiliseHarabe
extends RefCounted
## Mezarlık, nymphaion kalıntısı, harabe tipleri (yıkık tonoz, tek kemer, sütun sırası, mozaik döşeme, sarmaşıklı duvar).
## Harabenin içi de kurulur: moloz, ot, düşmüş taşlar. Her tırmanma yolu basamak ≤ 0,42 m'dir.


## Dairesel kemer taşları: merkez c (x, y), iç yarıçap r, kalınlık t, derinlik d (z), açı aralığı [a0, a1] derece.
static func _arch(b: IstKB, cx: float, cy: float, cz: float, r: float, t: float, d: float, a0: float, a1: float, n: int, col: Color) -> void:
	for i in n:
		var th := deg_to_rad(a0 + (a1 - a0) * (i + 0.5) / n)
		var rr := r + t * 0.5
		var arc := rr * deg_to_rad((a1 - a0) / n)
		b.sr(Vector3(cx + cos(th) * rr, cy + sin(th) * rr, cz), Vector3(arc * 1.18, t, d), col, "ashlar", Vector3(0, 0, rad_to_deg(th) - 90.0))


## ---------------------------------------------------------------- mezarlik
static func mezarlik(b: IstKB) -> void:
	var st := b.stone
	var w := maxf(b.S(15.0), 12.0)
	var l := maxf(b.S(13.0), 11.0)
	var wh := 1.1
	var wt := 0.5
	b.set_pivot(Vector3(0, 0, 0))
	var gap := 2.4                                  # güney kapı boşluğu
	if b.lod == 2:
		b.sb(Vector3(0, 0, -l * 0.5), Vector3(w, wh, wt), st)
		for i in 3:
			b.sb(Vector3(-3.5 + i * 3.5, 0, 0), Vector3(2.2, 1.2, 1.0), IstKB.MARBLE)
		return
	# duvar: K, D, B tam; G iki kanat (kapı boşluğu)
	b.sb(Vector3(0, 0, -l * 0.5), Vector3(w, wh, wt), st, "rubble")
	b.sb(Vector3(-w * 0.5, 0, 0), Vector3(wt, wh, l - wt), st, "rubble")
	b.sb(Vector3(w * 0.5, 0, 0), Vector3(wt, wh, l - wt), st, "rubble")
	var wing := (w - gap) * 0.5
	for s in [-1.0, 1.0]:
		b.sb(Vector3(s * (gap * 0.5 + wing * 0.5), 0, l * 0.5), Vector3(wing, wh, wt), st, "rubble")
		b.sb(Vector3(s * (gap * 0.5 + 0.4), 0, l * 0.5), Vector3(0.8, 2.1, 0.8), IstKB.STONE_D, "ashlar")        # kapı direkleri
		b.sb(Vector3(s * (gap * 0.5 + 0.4), 2.1, l * 0.5), Vector3(0.95, 0.2, 0.95), IstKB.MARBLE, "marble")
		b.vb(Vector3(s * (gap * 0.5 + 0.4), 2.3, l * 0.5), Vector3(0.12, 0.45, 0.12), IstKB.GOLD)
	b.sb(Vector3(0, 0, 0), Vector3(w - 1.0, 0.05, l - 1.0), IstKB.SOIL, "plaster")
	# duvara çıkış basamakları (iç tarafta)
	b.sb(Vector3(w * 0.5 - 1.1, 0, -l * 0.25), Vector3(1.2, 0.4, 1.4), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(w * 0.5 - 0.65, 0, -l * 0.25), Vector3(0.8, 0.8, 1.4), IstKB.STONE_D, "ashlar")
	b.add_climb(Vector3(w * 0.5 - 3.0, 0, -l * 0.25), Vector3(w * 0.5 - 0.3, wh, -l * 0.25), "basamak")
	# lahitler: gövde + beşik kapak, 3 × 2 düzen (aralık ≥ 2 m)
	var gx := [-w * 0.3, 0.0, w * 0.3]
	var gz := [-l * 0.18, l * 0.14]
	var n := 0
	for xx: float in gx:
		for zz: float in gz:
			var yaw := b.rng.randf_range(-8.0, 8.0)
			var lw := 2.2
			var lb := 0.9
			b.sb(Vector3(xx, 0, zz), Vector3(lb, 0.85, lw), IstKB.MARBLE, "marble", yaw)
			var lid := b.gable(Vector3(xx, 0.85, zz), lb + 0.12, 0.45, lw + 0.12, IstKB.STONE_D, true, "ashlar")
			if lid:
				(lid as Node3D).rotation_degrees.y = yaw
			if b.detail():
				b.vb(Vector3(xx, 0.45, zz) + Vector3(sin(deg_to_rad(yaw)), 0, cos(deg_to_rad(yaw))) * 0.0 + Vector3(lb * 0.5 + 0.02, 0, 0), Vector3(0.03, 0.4, 0.4), IstKB.DARK)
			n += 1
	# lahit yanına basamak taşı (kapağa çıkış)
	b.sb(Vector3(gx[2] + 1.5, 0, gz[1]), Vector3(0.8, 0.4, 0.8), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(gx[2] + 0.95, 0, gz[1]), Vector3(0.4, 0.8, 0.8), IstKB.STONE_D, "ashlar")
	b.add_climb(Vector3(gx[2] + 3.0, 0, gz[1]), Vector3(gx[2] + 0.75, 0.85, gz[1]), "basamak")
	b.add_perch(Vector3(gx[1], 1.3, gz[0]))
	# kemikevi (ossuary): küçük taş yapı, beşik çatı, kuzeyde
	var ow := 3.4
	var ol := 4.0
	b.sb(Vector3(-w * 0.5 + 2.6, 0, -l * 0.5 + 3.2), Vector3(ow, 2.8, ol), st, "ashlar")
	b.gable(Vector3(-w * 0.5 + 2.6, 2.8, -l * 0.5 + 3.2), ow + 0.4, 1.2, ol + 0.4, IstKB.TILE, true)
	b.add_perch(Vector3(-w * 0.5 + 2.6, 4.0, -l * 0.5 + 3.2))
	if b.lod == 1:
		return
	b.door(Vector3(-w * 0.5 + 2.6, 0, -l * 0.5 + 3.2 + ol * 0.5), Vector3(0, 0, 1), 1.1, 1.9)
	b.win(Vector3(-w * 0.5 + 2.6 + ow * 0.5, 1.5, -l * 0.5 + 3.2), Vector3(1, 0, 0), 0.4, 0.6)
	b.cross(Vector3(-w * 0.5 + 2.6, 4.0, -l * 0.5 + 3.2), 0.8)
	# mezar taşları (stel) ve selviler
	for i in 8:
		var sx := b.rng.randf_range(-w * 0.45, w * 0.45)
		var sz := b.rng.randf_range(-l * 0.3, l * 0.4)
		if absf(sx) < 3.0 and absf(sz) < 1.2:
			continue
		var near := false
		for xx2: float in gx:
			for zz2: float in gz:
				if absf(sx - xx2) < 1.6 and absf(sz - zz2) < 2.0:
					near = true
		if near or (sx < -w * 0.5 + 5.5 and sz < -l * 0.5 + 6.0):
			continue
		b.sb(Vector3(sx, 0, sz), Vector3(0.5, 1.1, 0.16), IstKB.MARBLE, "marble", b.rng.randf_range(-12.0, 12.0))
		b.vb(Vector3(sx, 1.1, sz), Vector3(0.1, 0.3, 0.06), IstKB.GOLD)
	for p in [Vector2(-w * 0.5 + 2.2, l * 0.35), Vector2(w * 0.5 - 2.0, l * 0.35), Vector2(w * 0.5 - 2.4, -l * 0.35), Vector2(0, -l * 0.5 + 1.6)]:
		b.tree_cypress(Vector3(p.x, 0, p.y), 6.0)
	b.grass_patch(Vector3(-2.0, 0, l * 0.3), 2.2, 1.6)
	b.grass_patch(Vector3(w * 0.2, 0, -l * 0.1), 1.8, 1.4)
	b.flush()


## ---------------------------------------------------------------- nymphaion
## Yarım daire çeşme duvarı (niş sırası), önünde havuz, çökmüş üst kısım ve moloz; moloz yığınından duvar tepesine çıkılır.
static func nymphaion(b: IstKB) -> void:
	var st := b.stone
	var R := maxf(b.S(4.0), 3.6)
	var nseg := 9
	var hmax := b.Hs(5.0, 4.6)
	var wt := 1.0
	b.set_pivot(Vector3(0, 0, 0))
	# duvar yükseklikleri (batıdan doğuya: yıkık, orta sağlam, doğu daha alçak)
	var hs := [2.0, 2.6, 3.8, hmax, hmax, hmax * 0.9, 3.0, 1.9, 1.4]
	if b.lod == 2:
		b.sb(Vector3(0, 0, -R * 0.5), Vector3(R * 2.2, hmax * 0.8, wt), st)
		b.sc(Vector3(0, 0, R * 0.5), 3.0, 0.6, IstKB.MARBLE, "", 10)
		return
	for i in nseg:
		var a := deg_to_rad(-90.0 + 180.0 * (i + 0.5) / nseg)     # -90 (batı) .. +90 (doğu), merkezden kuzeye bakan yay
		var cx := sin(a) * R
		var cz := -cos(a) * R
		var chord := 2.0 * R * sin(deg_to_rad(90.0 / nseg)) * 1.14
		var yaw := rad_to_deg(a)
		b.sb(Vector3(cx, 0, cz), Vector3(chord, hs[i], wt), st, "ashlar", -yaw)
		if b.detail():
			var nrm := Vector3(-sin(a), 0, cos(a))      # yayın içine (merkeze) bakan yön
			nrm = Vector3(-cx, 0, -cz).normalized()
			if hs[i] > 3.0:
				b.win(Vector3(cx, 0.9, cz) + nrm * (wt * 0.5), nrm, 0.9, minf(hs[i] - 2.0, 2.2))
		var nrm2 := Vector3(-cx, 0, -cz).normalized()
		if hs[i] <= 2.7:
			pass
	# havuz: basamaklı mermer kaide (dolu), üstünde su yüzeyi
	b.sc(Vector3(0, 0, R * 0.25), R * 1.25, 0.3, IstKB.STONE_D, "flagstone", 14)
	b.sc(Vector3(0, 0.3, R * 0.25), R * 0.85, 0.35, IstKB.MARBLE, "marble", 14)
	b.sc(Vector3(0, 0.65, R * 0.25), R * 0.7, 0.04, IstKB.WATER, "", 14)
	b.add_perch(Vector3(0, 0.69, R * 0.3))
	# moloz yığını: batı uçta duvara yaslı, tepe duvarın alçak ucu (2,0 m) ile birleşir
	var hx := sin(deg_to_rad(-90.0 + 180.0 * 0.5 / nseg)) * R
	var hz := -cos(deg_to_rad(-90.0 + 180.0 * 0.5 / nseg)) * R
	b.rubble_heap(Vector3(hx - 1.2, 0, hz + 2.0), 2.6, 1.8, IstKB.STONE_D)
	b.add_climb(Vector3(hx - 4.4, 0, hz + 4.0), Vector3(hx + 0.1, hs[0], hz - 0.1), "sandik")
	# düşmüş sütun gövdeleri
	b.sc(Vector3(2.6, 0.0, R * 0.9), 0.35, 0.7, IstKB.MARBLE, "marble", 8)
	var drum := b.vc(Vector3(-3.4, 0.38, R * 1.3), 0.38, 1.1, IstKB.MARBLE, 8, Vector3(0, 0, 90), -1.0, true)
	if drum:
		drum.set_meta("dekor", false)
		Props.make_solid(drum as MeshInstance3D)
	if b.lod == 1:
		return
	# bezeme: mermer silme, aslan başı oluğu (kutu), yosun, sarmaşık
	for i in nseg:
		if hs[i] > 3.0:
			var aa := deg_to_rad(-90.0 + 180.0 * (i + 0.5) / nseg)
			var inward := Vector3(-sin(aa), 0, cos(aa))
			var c0 := Vector3(sin(aa) * R, 0, -cos(aa) * R) + inward * (wt * 0.5 + 0.05)
			b.vb(c0 + Vector3(0, 0.55, 0), Vector3(0.3, 0.3, 0.2), IstKB.MARBLE, "marble", Vector3(0, -rad_to_deg(aa), 0))
			b.vb(c0 + Vector3(0, 0.15, 0) + inward * 0.1, Vector3(0.2, 0.1, 0.5), IstKB.DARK, "", Vector3(0, -rad_to_deg(aa), 0))
	for i in 14:
		var ai := b.rng.randf_range(-80.0, 80.0)
		var rr := R + 0.55
		b.ivy(Vector3(sin(deg_to_rad(ai)) * (R - 0.5) * 1.0, b.rng.randf_range(1.0, 3.2), -cos(deg_to_rad(ai)) * (R - 0.5)), b.rng.randf_range(0.3, 0.6))
	b.grass_patch(Vector3(-R * 0.8, 0, R * 0.9), 1.8, 1.4)
	b.grass_patch(Vector3(R * 0.9, 0, R * 0.6), 1.5, 1.2)
	b.flush()


## ------------------------------------------------------------- harabe_tonoz
## Yıkık tonoz: iki yan duvar (tepeleri düzensiz), kuzey ucunda hâlâ ayakta kalan kemer halkaları, ortası moloz.
static func tonoz(b: IstKB) -> void:
	var st := b.stone
	var span := maxf(b.S(4.4), 3.2)
	var L := maxf(b.S(11.0), 8.0)
	var hw := b.Hs(4.2, 3.6)
	var wt := 1.4
	b.set_pivot(Vector3(0, 0, 0))
	var wx := span * 0.5 + wt * 0.5
	if b.lod == 2:
		for s in [-1.0, 1.0]:
			b.sb(Vector3(s * wx, 0, 0), Vector3(wt, hw, L), st)
		return
	# yan duvarlar: 5 parça, güneye doğru alçalır
	var f := [1.0, 0.92, 0.78, 0.58, 0.42]
	var seg := L / f.size()
	for s in [-1.0, 1.0]:
		for i in f.size():
			var jit := 0.0 if s < 0.0 else 0.12 * (i % 2)
			var hh: float = hw * f[i] * (1.0 - jit)
			b.sb(Vector3(s * wx, 0, -L * 0.5 + seg * (i + 0.5)), Vector3(wt, hh, seg), st, "ashlar")
	# kuzey uç duvarı (apsis eli): kemer duvarı
	b.sb(Vector3(0, 0, -L * 0.5 - 0.5), Vector3(span + 2.0 * wt, hw * 1.0, 1.0), st, "ashlar")
	# ayakta kalan kemer halkaları (kuzeyde iki halka, güney halkası yarım)
	_arch(b, 0.0, hw, -L * 0.5 + 1.2, span * 0.5, 0.8, 1.2, 0.0, 180.0, 9, st)
	_arch(b, 0.0, hw, -L * 0.5 + 3.6, span * 0.5, 0.8, 1.2, 0.0, 180.0, 9, st)
	# halkaları taşıyan "tavan örtüsü": halkaların üstü kapalı kaplama (üstten düşülmesin)
	b.sb(Vector3(0, hw + span * 0.5 + 0.8 - 0.2, -L * 0.5 + 2.4), Vector3(span * 0.55, 0.4, 3.6), st, "ashlar")
	# güneyde yarım kalmış halka (yalnız doğu yarısı)
	_arch(b, 0.0, hw * 0.78, -L * 0.5 + 6.2, span * 0.5, 0.8, 1.2, 0.0, 75.0, 4, st)
	# ortada moloz yığını (doğu duvara yaslı; tepe duvar parçası 3 ile birleşir)
	var hh3: float = hw * f[3]
	b.rubble_heap(Vector3(span * 0.5 - 0.3, 0, L * 0.12), 2.2, hh3 - 0.15, IstKB.STONE_D)
	b.add_climb(Vector3(-0.8, 0, L * 0.12 + 3.2), Vector3(wx, hh3 * 1.0, -L * 0.5 + seg * 3.5 + 0.0), "sandik")
	b.add_perch(Vector3(wx, hw * f[0], -L * 0.5 + seg * 0.5))
	b.add_perch(Vector3(-wx, hw * f[0], -L * 0.5 + seg * 0.5))
	if b.lod == 1:
		return
	# düşmüş kemer taşları, yosun, ot, sarmaşık
	for i in 6:
		var px := b.rng.randf_range(-span * 0.4, span * 0.4)
		var pz := b.rng.randf_range(L * 0.0, L * 0.45)
		b.vb(Vector3(px, 0, pz), Vector3(0.5, 0.35, 0.8), IstKB.STONE_D, "ashlar", Vector3(0, b.rng.randf() * 90.0, 0))
	for i in 18:
		b.ivy(Vector3((wx - wt * 0.5 - 0.05) * (1.0 if i % 2 == 0 else -1.0), b.rng.randf_range(0.6, hw * 0.8), -L * 0.5 + b.rng.randf() * L * 0.8), b.rng.randf_range(0.3, 0.55))
	b.grass_patch(Vector3(-1.0, 0, L * 0.3), 1.4, 2.2)
	b.grass_patch(Vector3(1.0, 0, L * 0.45), 1.2, 1.0)
	b.band_ring(Vector3(0, 0, 0), wx + wt * 0.5, L * 0.5, hw * 0.35, 0.16, false)
	b.flush()


## -------------------------------------------------------------- harabe_kemer
static func kemer(b: IstKB) -> void:
	var st := b.stone
	var span := maxf(b.S(5.4), 3.4)
	var hp := b.Hs(4.6, 3.2)
	var pw := 1.8
	var pd := 1.6
	b.set_pivot(Vector3(0, 0, 0))
	var px := span * 0.5 + pw * 0.5
	if b.lod == 2:
		for s in [-1.0, 1.0]:
			b.sb(Vector3(s * px, 0, 0), Vector3(pw, hp, pd), st)
		b.sb(Vector3(0, hp, 0), Vector3(span + 2.0 * pw, span * 0.5 + 0.8, pd), st)
		return
	for s in [-1.0, 1.0]:
		b.sb(Vector3(s * px, 0, 0), Vector3(pw, hp, pd), st, "ashlar")
	_arch(b, 0.0, hp, 0.0, span * 0.5, 0.8, pd, 0.0, 180.0, 11, st)
	# kemer üstündeki duvar kalıntısı: sivri üçgen dolgu (kemerin kenarlarından yukarı)
	b.sb(Vector3(px, hp, 0), Vector3(pw, span * 0.5 + 0.8 + 0.2, pd), st, "ashlar")
	b.sb(Vector3(-px, hp, 0), Vector3(pw, span * 0.5 + 0.2, pd), st, "ashlar")
	# duvar kalıntısı kolları (doğuya uzanan 3,6 m, batıya 2,2 m), tepeleri basamaklı
	var wl := [Vector2(1.0, 2.6), Vector2(1.0, 2.0), Vector2(1.0, 1.4)]
	for i in 3:
		b.sb(Vector3(px + pw * 0.5 + 0.5 + i * 1.0, 0, 0), Vector3(1.0, wl[i].y * hp / 3.2, pd * 0.6), st, "ashlar")
	for i in 2:
		b.sb(Vector3(-px - pw * 0.5 - 0.5 - i * 1.0, 0, 0), Vector3(1.0, (2.4 - i * 0.9) * hp / 3.2, pd * 0.6), st, "ashlar")
	# moloz yığını doğu duvar kolundan 2,6 m'lik uca çıkış
	b.rubble_heap(Vector3(px + pw * 0.5 + 0.5, 0, pd * 0.6 + 1.2), 2.2, 2.3, IstKB.STONE_D)
	b.add_climb(Vector3(px + 0.5, 0, pd * 0.6 + 4.2), Vector3(px + pw * 0.5 + 0.5, 2.6 * hp / 3.2, 0.0), "sandik")
	b.add_perch(Vector3(-px, hp + span * 0.5 + 0.2, 0.0))
	b.add_perch(Vector3(px, hp + span * 0.5 + 0.2, 0.0))
	if b.lod == 1:
		return
	# tuğla dizisi, sarmaşık, tepede incir fidanı, düşmüş kemer taşları
	b.band_ring(Vector3(px, 0, 0), pw * 0.5, pd * 0.5, hp * 0.6, 0.16)
	b.band_ring(Vector3(-px, 0, 0), pw * 0.5, pd * 0.5, hp * 0.6, 0.16)
	for i in 22:
		b.ivy(Vector3(-px + b.rng.randf_range(-0.7, 0.7), b.rng.randf_range(0.4, hp + 1.5), pd * 0.5 + 0.05), b.rng.randf_range(0.25, 0.5))
	b.vc(Vector3(-px, hp + span * 0.5 + 0.2, 0), 0.07, 1.0, IstKB.WOOD_D, 5)
	b.vball(Vector3(-px, hp + span * 0.5 + 1.2, 0), 0.5, Color("5b8a3a"), Vector3(1, 0.8, 1), 7)
	for i in 4:
		b.vb(Vector3(b.rng.randf_range(-span * 0.35, span * 0.35), 0, b.rng.randf_range(-pd, pd) * 1.5), Vector3(0.7, 0.4, 0.5), IstKB.STONE_D, "ashlar", Vector3(0, b.rng.randf() * 90.0, 0))
	b.grass_patch(Vector3(0, 0, 1.2), 2.0, 1.2)
	b.flush()


## -------------------------------------------------------------- harabe_sutun
static func sutun(b: IstKB) -> void:
	var cr := 0.38
	var sp := 3.2
	var n := 7
	var hfull := b.Hs(5.4, 4.2)
	b.set_pivot(Vector3(0, 0, 0))
	var L := sp * (n - 1) + 2.4
	var heights := [hfull, hfull, hfull * 0.8, hfull * 0.52, 1.7, 0.9, 0.35]
	if b.lod == 2:
		b.sb(Vector3(0, 0, 0), Vector3(3.2, 0.5, L), IstKB.STONE_D)
		for i in 4:
			b.sc(Vector3(0, 0.5, -L * 0.5 + 1.2 + i * sp), cr, heights[i], IstKB.MARBLE, "", 6)
		return
	# stylobate: 0,5 m kaide (iki basamak: 0,25 + 0,25)
	b.sb(Vector3(0, 0, 0), Vector3(3.6, 0.25, L + 0.6), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(0, 0.25, 0), Vector3(3.0, 0.25, L), IstKB.STONE_D, "ashlar")
	for i in n:
		var z := -L * 0.5 + 1.2 + i * sp
		var h: float = heights[i]
		b.sb(Vector3(0, 0.5, z), Vector3(0.95, 0.3, 0.95), IstKB.MARBLE, "marble")          # kaide
		b.sc(Vector3(0, 0.8, z), cr, h - 0.3 - (0.4 if i < 3 else 0.0), IstKB.MARBLE, "marble", 10)
		if i < 3:
			b.sb(Vector3(0, 0.8 + h - 0.7, z), Vector3(0.95, 0.4, 0.95), IstKB.MARBLE, "marble")   # başlık
	# alınlık (mimari) parçası: ilk iki sütunun başlığı üstünde
	var top := 0.8 + hfull - 0.3
	b.sb(Vector3(0, top, -L * 0.5 + 1.2 + sp * 0.5), Vector3(0.9, 0.7, sp + 1.2), IstKB.MARBLE, "marble")
	b.add_perch(Vector3(0, top + 0.7, -L * 0.5 + 1.2 + sp * 0.5))
	b.add_perch(Vector3(0, 0.8 + heights[2] - 0.3 + 0.0, -L * 0.5 + 1.2 + 2 * sp) + Vector3(0, 0.0, 0.0))
	# kırık sütun 5 (1,7 m) tepesine çıkış: üç basamaklı mermer blok (0,4 m)
	var z4 := -L * 0.5 + 1.2 + 4 * sp
	b.sb(Vector3(0, 0.5, z4 + 2.4), Vector3(1.0, 0.4, 1.0), IstKB.MARBLE, "marble")
	b.sb(Vector3(0, 0.5, z4 + 1.4), Vector3(1.0, 0.8, 1.0), IstKB.MARBLE, "marble")
	b.add_climb(Vector3(0, 0.5, z4 + 4.2), Vector3(0, 0.8 + heights[4] - 0.3, z4), "basamak")
	if b.lod == 1:
		return
	# yerde yatan gövde parçaları (katı) ve düşmüş başlıklar
	for i in 3:
		var side := 2.6 if i != 1 else -2.8
		var zz := -L * 0.5 + 2.4 + i * 5.0
		var d := b.vc(Vector3(side, cr, zz), cr, 1.1, IstKB.MARBLE, 10, Vector3(90 if i == 0 else 0, 0, 0 if i == 0 else 90), -1.0, true)
		if d:
			d.set_meta("dekor", false)
			Props.make_solid(d as MeshInstance3D)
		b.vb(Vector3(side + 1.4, 0, zz + 0.5), Vector3(0.9, 0.5, 0.9), IstKB.MARBLE, "marble", Vector3(0, 20.0 * i, 0))
	b.grass_patch(Vector3(2.8, 0, L * 0.3), 1.4, 3.0)
	b.grass_patch(Vector3(-2.8, 0, -L * 0.1), 1.2, 3.0)
	b.ivy(Vector3(0.0, 0.7, -L * 0.5 + 1.2 + 5 * sp), 0.5)
	b.flush()


## ------------------------------------------------------------ harabe_mozaik
## Mozaik döşeme parçası: üstünde kodla çizilmiş tesserae dokusu olan alçak kaide, kopuk kenarlar, alçak duvar kalıntısı.
static func mozaik(b: IstKB) -> void:
	var w := 7.0
	var l := 9.0
	b.set_pivot(Vector3(0, 0, 0))
	if b.lod == 2:
		b.sb(Vector3(0, 0, 0), Vector3(w, 0.15, l), IstKB.STONE_D)
		return
	b.sb(Vector3(0, 0, 0), Vector3(w + 1.2, 0.1, l + 1.2), IstKB.SOIL, "plaster")           # toprak/harç tabanı
	b.sb(Vector3(0, 0.1, 0), Vector3(w, 0.1, l), IstKB.STONE_D)                              # mozaik tabanı (kaide)
	# alçak duvar kalıntısı (0,4 m) iki kenarda, 1 uçta kopuk
	b.sb(Vector3(-w * 0.5 - 0.3, 0, -1.0), Vector3(0.6, 0.4, l - 3.0), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(0, 0, -l * 0.5 - 0.3), Vector3(w * 0.55, 0.4, 0.6), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(w * 0.5 + 0.3, 0, 1.5), Vector3(0.6, 0.4, 3.0), IstKB.STONE_D, "ashlar")
	# mermer plakalar ve sütun kaidesi
	b.sb(Vector3(w * 0.5 + 1.2, 0, -2.6), Vector3(1.0, 0.38, 1.0), IstKB.MARBLE, "marble")
	b.sb(Vector3(-w * 0.5 - 1.6, 0, 2.6), Vector3(1.6, 0.18, 0.9), IstKB.MARBLE, "marble", 15.0)
	b.add_perch(Vector3(0, 0.2, 0))
	b.add_climb(Vector3(0, 0, l * 0.5 + 3.0), Vector3(0, 0.2, l * 0.5 - 1.0), "basamak")
	if b.lod == 1:
		return
	# mozaik dokusu: kaide üstünde ince düzlem
	var tex := _mosaic_tex()
	var pm := PlaneMesh.new()
	pm.size = Vector2(w - 0.2, l - 0.2)
	var mi := MeshInstance3D.new()
	mi.mesh = pm
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.specular_mode = BaseMaterial3D.SPECULAR_TOON
	m.roughness = 0.9
	mi.material_override = m
	mi.position = Vector3(0, 0.2 + 0.02, 0)
	mi.set_meta("dekor", true)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	b.host.add_child(mi)
	# kopuk kenar: dağınık tesserae taşları (küçük çok renkli kutular, MultiMesh yerine yerinde birkaç adet), ot ve yosun
	for i in 14:
		var side := i % 4
		var ex := b.rng.randf_range(-w * 0.5, w * 0.5)
		var ez := b.rng.randf_range(-l * 0.5, l * 0.5)
		if side == 0:
			ez = l * 0.5 + b.rng.randf_range(0.1, 0.6)
		elif side == 1:
			ex = w * 0.5 + b.rng.randf_range(0.1, 0.5)
		elif side == 2:
			ex = -w * 0.5 - b.rng.randf_range(0.1, 0.5)
		else:
			ez = -l * 0.5 - b.rng.randf_range(0.1, 0.5)
		var cols := [Color("c9562f"), Color("e0c78a"), Color("3d5f86"), Color("4e7a3d")]
		b.vb(Vector3(ex, 0.1, ez), Vector3(0.18, 0.06, 0.18), cols[i % 4], "", Vector3(0, b.rng.randf() * 90.0, 0))
	b.grass_patch(Vector3(-w * 0.5 + 0.6, 0.1, -l * 0.5 + 0.8), 1.2, 1.6)
	b.grass_patch(Vector3(w * 0.5 - 0.5, 0.1, l * 0.5 - 0.6), 1.0, 1.0)
	b.ivy(Vector3(-w * 0.5 - 0.3, 0.45, -3.0), 0.35)
	b.flush()


static var _mosaic_cache: ImageTexture


static func _mosaic_tex() -> ImageTexture:
	if _mosaic_cache != null:
		return _mosaic_cache
	var n := 96
	var img := Image.create(n, n, false, Image.FORMAT_RGB8)
	var cream := Color("e8d9b0")
	var red := Color("b6452a")
	var blue := Color("35567a")
	var green := Color("5a7f43")
	var gold := Color("d1a53b")
	var dark := Color("2a2622")
	for y in n:
		for x in n:
			var u := (x + 0.5) / n * 2.0 - 1.0
			var v := (y + 0.5) / n * 2.0 - 1.0
			var r := sqrt(u * u + v * v)
			var edge := maxf(absf(u), absf(v))
			var c := cream
			if edge > 0.9:
				c = dark
			elif edge > 0.82:
				c = red
			elif edge > 0.62:
				# Yunan kıvrımı (meander): dönüşümlü bloklar
				var m := (int(floor((u + 1.0) * 8.0)) + int(floor((v + 1.0) * 8.0))) % 2
				c = blue if m == 0 else cream
				if edge > 0.7 and edge < 0.74:
					c = gold
			elif r < 0.16:
				c = gold
			elif r < 0.3:
				c = red
			elif r < 0.5:
				var ang := atan2(v, u)
				var pet := int(floor((ang + PI) / TAU * 8.0))
				c = green if pet % 2 == 0 else blue
				if r > 0.44:
					c = cream
			else:
				c = cream
				if absf(u) < 0.04 or absf(v) < 0.04:
					c = red
			# tessera gürültüsü (taş taş görünüm)
			var h := float(((x * 73856093) ^ (y * 19349663)) % 97) / 97.0
			c = c.darkened(h * 0.12)
			if (x % 3 == 0) or (y % 3 == 0):
				c = c.darkened(0.12)
			img.set_pixel(x, y, c)
	_mosaic_cache = ImageTexture.create_from_image(img)
	return _mosaic_cache


## ----------------------------------------------------------- harabe_sarmasik
## Sarmaşıklı duvar kalıntısı: 11 m, tepesi basamaklı yıkık, kör kemerli kapı, dayanma payandası, kalın sarmaşık.
static func sarmasik(b: IstKB) -> void:
	var st := b.stone
	var L := maxf(b.S(11.0), 8.0)
	var hmax := b.Hs(5.0, 4.0)
	var wt := 0.9
	b.set_pivot(Vector3(0, 0, 0))
	var f := [0.42, 0.55, 0.82, 1.0, 0.95, 0.68, 0.5, 0.4]
	var seg := L / f.size()
	if b.lod == 2:
		b.sb(Vector3(0, 0, 0), Vector3(L, hmax * 0.8, wt), st)
		return
	for i in f.size():
		var hh: float = hmax * f[i]
		b.sb(Vector3(-L * 0.5 + seg * (i + 0.5), 0, 0), Vector3(seg, hh, wt), st, "ashlar")
	# payanda (kuzey yüz, orta)
	b.sb(Vector3(-L * 0.5 + seg * 3.5, 0, -wt * 0.5 - 0.55), Vector3(1.4, hmax * 0.7, 1.1), st, "ashlar")
	b.sb(Vector3(-L * 0.5 + seg * 3.5, hmax * 0.7, -wt * 0.5 - 0.55), Vector3(1.4, 0.0001 + 0.15, 1.1), IstKB.STONE_D)
	# moloz rampası (batı uç: ilk segmentin tepesine) ve düşmüş taşlar
	b.rubble_heap(Vector3(-L * 0.5 + 0.2, 0, wt * 0.5 + 1.8), 2.2, hmax * f[0] - 0.1, IstKB.STONE_D)
	b.add_climb(Vector3(-L * 0.5 - 1.0, 0, wt * 0.5 + 4.6), Vector3(-L * 0.5 + seg * 0.5, hmax * f[0], 0.0), "sandik")
	b.add_perch(Vector3(-L * 0.5 + seg * 3.5, hmax * f[3], 0.0))
	b.add_perch(Vector3(-L * 0.5 + seg * 4.5, hmax * f[4], 0.0))
	if b.lod == 1:
		return
	# kör kemerli kapı (kapatılmış), pencere, tuğla sıraları
	var dx := -L * 0.5 + seg * 4.4
	b.vb(Vector3(dx, 0, wt * 0.5 + 0.03), Vector3(1.8, 2.6, 0.06), IstKB.DARK)
	b.vc(Vector3(dx, 2.6, wt * 0.5 + 0.03), 0.9, 0.06, IstKB.DARK, 12, Vector3(90, 0, 0), -1.0, true)
	b.vb(Vector3(dx, 0, wt * 0.5 + 0.06), Vector3(1.8, 1.9, 0.04), IstKB.STONE_D, "rubble")      # moloz tıkaç
	b.win(Vector3(-L * 0.5 + seg * 2.5, 2.2, wt * 0.5), Vector3(0, 0, 1), 0.7, 1.4)
	b.win(Vector3(-L * 0.5 + seg * 2.5, 2.2, -wt * 0.5), Vector3(0, 0, -1), 0.7, 1.4)
	for yy in [0.8, 1.7, 2.6, 3.5]:
		b.band(Vector3(-L * 0.5 + seg * 3.5, yy, wt * 0.5 + 0.03), Vector3(seg * 5.0, 0.14, 0.06))
		b.band(Vector3(-L * 0.5 + seg * 3.5, yy, -wt * 0.5 - 0.03), Vector3(seg * 5.0, 0.14, 0.06))
	# yoğun sarmaşık (her iki yüzde) ve sarkan dallar
	for i in 50:
		var side := 1.0 if i % 2 == 0 else -1.0
		var xi := b.rng.randf_range(-L * 0.5 + 0.4, L * 0.5 - 0.4)
		var seg_i := clampi(int((xi + L * 0.5) / seg), 0, f.size() - 1)
		var yi := b.rng.randf_range(0.5, hmax * f[seg_i])
		b.ivy(Vector3(xi, yi, side * (wt * 0.5 + 0.02)), b.rng.randf_range(0.28, 0.6), Vector3(1.0, 0.8, 0.5))
	for i in 10:
		var xi := b.rng.randf_range(-L * 0.5 + 0.6, L * 0.5 - 0.6)
		var seg_i := clampi(int((xi + L * 0.5) / seg), 0, f.size() - 1)
		b.vb(Vector3(xi, hmax * f[seg_i] - 0.9, wt * 0.5 + 0.06), Vector3(0.05, 0.9, 0.04), IstKB.IVY_D)
	# tepede kuru ot ve incir
	b.vc(Vector3(-L * 0.5 + seg * 3.5, hmax * f[3], 0.0), 0.06, 0.9, IstKB.WOOD_D, 5)
	b.vball(Vector3(-L * 0.5 + seg * 3.5, hmax * f[3] + 1.2, 0.0), 0.5, Color("5b8a3a"), Vector3(1, 0.8, 1), 7)
	b.grass_patch(Vector3(2.0, 0, 1.8), 2.4, 1.0)
	b.grass_patch(Vector3(-2.5, 0, -1.8), 2.0, 0.9)
	b.flush()
