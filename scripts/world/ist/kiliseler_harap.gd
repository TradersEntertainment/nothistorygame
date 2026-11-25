extends RefCounted
## G21 — Harap kilise (Lykos şeridi; 43o'da Sultan: "harap kiliseler"). class_name yok: IstKiliseler._run preload eder.
## Kapalı Yunan haçı planlı küçük kilisenin yıkıntısı (IstKiliseHarabe ile aynı dil: ashlar taş, tuğla bantlar, sarmaşık,
## moloz): parça parça yan duvarlar (tepeleri basamaklı, yer yer gedik), yarım kalmış batı cephesi ve kapı kemeri parçası,
## apsis yarım halkası, kubbeyi taşıyan dört payeden ikisi ve aralarındaki kemer; kubbe kasnağı çökmüş: pencereli kasnak
## parçaları ortadaki moloz yığınının çevresinde yerde, kurşun kubbe kabuğu parçası yere düşmüş; ayakta iki sütun, devrik
## iki sütun. Eksen IstKB kuralı: uzun eksen z, apsis −z, giriş +z. Taban ortası yerel başlangıç, zemin y 0.

const Harabe := preload("res://scripts/world/ist/kiliseler_harabe.gd")


static func harap_kilise(b: IstKB) -> void:
	var st := b.stone
	var W := maxf(b.S(12.0), 9.0)           # dış en
	var L := maxf(b.S(17.0), 13.0)          # nef boyu (apsis hariç)
	var wt := 0.95                          # duvar kalınlığı
	var H := b.Hs(6.6, 4.6)                 # en yüksek kalan duvar
	var ap := W * 0.32                      # apsis yarıçapı
	b.set_pivot(Vector3(0, 0, ap * 0.5))
	var wx := W * 0.5 - wt * 0.5
	if b.lod == 2:
		b.sb(Vector3(-wx, 0, 0), Vector3(wt, H * 0.7, L), st)
		b.sb(Vector3(wx, 0, L * 0.1), Vector3(wt, H * 0.35, L * 0.8), st)
		b.sc(Vector3(0, 0, -L * 0.5), ap, H * 0.55, st, "", 8)
		return
	# taban: alçak döşeme kaidesi (kırık kenarlı: iki parça)
	b.sb(Vector3(0, 0, -L * 0.1), Vector3(W - 0.2, 0.22, L * 0.8), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(-W * 0.2, 0, L * 0.38), Vector3(W * 0.55, 0.22, L * 0.22), IstKB.STONE_D, "ashlar")
	# yan duvarlar: 2,1 m'lik parçalar; kuzey (−x) duvarı apsise doğru yüksek, güney (+x) duvarında gedikler
	var seg := 2.1
	var n := int(L / seg)
	var tops := {}                          # en yüksek parça (konak) için
	for s in [-1.0, 1.0]:
		for i in n:
			var z := -L * 0.5 + seg * (i + 0.5)
			var f := 1.0 - float(i) / n                       # apsis yanında 1, girişte 0
			var hh := H * (0.35 + 0.65 * f) if s < 0.0 else H * (0.15 + 0.55 * f)
			hh *= b.rng.randf_range(0.75, 1.05)
			if s > 0.0 and (i == 2 or i == n - 2 or b.rng.randf() < 0.18):
				# gedik: duvar diz boyuna kadar yıkık, önünde moloz
				hh = b.rng.randf_range(0.35, 0.8)
				if b.lod == 0:
					b.rubble_heap(Vector3(s * (wx + 1.3), 0, z), 1.2, 0.7, IstKB.STONE_D)
			hh = maxf(hh, 0.35)
			b.sb(Vector3(s * wx, 0, z), Vector3(wt, hh, seg), st, "ashlar")
			if hh > tops.get("h", 0.0):
				tops = {"h": hh, "p": Vector3(s * wx, hh, z)}
			if b.lod == 0:
				# tuğla bantları (yalnız parçanın boyu yetiyorsa) ve pencere (yüksek parçalarda, kemerli)
				for by: float in [1.4, 2.9, 4.4]:
					if by + 0.25 < hh:
						b.vb(Vector3(s * (wx + wt * 0.5 + 0.01), by, z), Vector3(0.04, 0.22, seg - 0.05), IstKB.BRICK)
						b.vb(Vector3(s * (wx - wt * 0.5 - 0.01), by, z), Vector3(0.04, 0.22, seg - 0.05), IstKB.BRICK)
				if hh > 4.2 and i % 2 == 1:
					b.win(Vector3(s * (wx + wt * 0.5), 2.4, z), Vector3(s, 0, 0), 0.55, 1.4)
					b.win(Vector3(s * (wx - wt * 0.5), 2.4, z), Vector3(-s, 0, 0), 0.55, 1.4)
	# batı cephesi (+z): kapının iki payesi, yarım kalmış kapı kemeri, köşelere doğru alçalan duvar
	var zf := L * 0.5 - wt * 0.5
	var dw := 1.5
	var ph := b.Hs(3.4, 3.0)
	b.sb(Vector3(-(dw * 0.5 + 0.6), 0, zf), Vector3(1.2, ph + 0.8, wt), st, "ashlar")
	b.sb(Vector3(dw * 0.5 + 0.6, 0, zf), Vector3(1.2, ph * 0.72, wt), st, "ashlar")
	Harabe._arch(b, 0.0, ph * 0.72, zf, dw * 0.5, 0.55, wt, 0.0, 100.0, 5, st)
	var cw := (W - dw - 2.4) * 0.5
	b.sb(Vector3(-(dw * 0.5 + 1.2 + cw * 0.5), 0, zf), Vector3(cw, ph * 0.9, wt), st, "ashlar")
	b.sb(Vector3(dw * 0.5 + 1.2 + cw * 0.5, 0, zf), Vector3(cw, 0.9, wt), st, "ashlar")
	# apsis (−z): yarım halka, kuzeyde yüksek, güneye doğru alçalır; ortasında yarım pencere
	var zc := -L * 0.5
	var na := 7
	for i in na:
		var a := PI + PI * (i + 0.5) / na                 # π..2π: −z yarısı
		var q := Vector3(cos(a) * (ap - wt * 0.5), 0, zc + sin(a) * (ap - wt * 0.5))
		var hh := H * lerpf(0.95, 0.32, float(i) / (na - 1)) * b.rng.randf_range(0.9, 1.0)
		var segw := 2.0 * ap * sin(PI / na / 2.0) * 2.0 + 0.15
		b.sb(q, Vector3(segw, hh, wt), st, "ashlar", -rad_to_deg(a) - 90.0)
		if b.lod == 0 and hh > 2.6:
			b.vb(q + Vector3(0, 1.6, 0), Vector3(segw + 0.02, 0.2, wt + 0.04), IstKB.BRICK, "", Vector3(0, -rad_to_deg(a) - 90.0, 0), true)
	if b.lod == 0:
		b.win(Vector3(0, 2.2, zc - ap), Vector3(0, 0, -1), 0.5, 1.3)
	# kubbeyi taşıyan dört paye (ikisi ayakta, ikisi kırık) ve kuzey payeleri arasındaki kemer
	var cz := -L * 0.12
	var pr := 2.4
	var hp := b.Hs(5.0, 4.0)
	var piers := [[Vector2(-pr, cz - pr), hp], [Vector2(pr, cz - pr), hp * 0.94], [Vector2(-pr, cz + pr), 2.1], [Vector2(pr, cz + pr), 0.9]]
	for p: Array in piers:
		var v: Vector2 = p[0]
		b.sb(Vector3(v.x, 0, v.y), Vector3(1.2, float(p[1]), 1.2), st, "ashlar")
	var ka := hp * 0.94
	Harabe._arch(b, 0.0, ka, cz - pr, pr - 0.6, 0.6, 1.2, 0.0, 180.0, 9, st)
	b.add_perch(Vector3(-pr, hp, cz - pr))
	if tops.has("p"):
		b.add_perch(tops["p"])
	if b.lod == 1:
		return
	# çökmüş kubbe kasnağı: ortada moloz yığını, çevresinde yerde pencereli kasnak parçaları (biri eğik), kubbe kabuğu
	b.rubble_heap(Vector3(0.3, 0, cz + 0.4), 2.3, 1.05, IstKB.STONE_D)
	var nr := 12
	for i in nr:
		if i in [1, 4, 5, 8, 10]:
			continue                                      # kayıp parçalar
		var a := TAU * i / nr + 0.2
		var q := Vector3(cos(a) * 3.3, 0, cz + 0.4 + sin(a) * 3.3)
		q.y = _zemin(q.x, q.z, W, L)
		var hh := b.rng.randf_range(0.9, 1.7)
		var rot := -rad_to_deg(a) + 90.0
		if i == 6:
			b.sr(q + Vector3(0, hh * 0.5 + 0.12, 0), Vector3(1.5, hh, 0.55), st, "ashlar", Vector3(0, rot, 14.0))
		else:
			b.sb(q, Vector3(1.5, hh, 0.55), st, "ashlar", rot)
			if hh > 1.2:
				b.win(q + Vector3(cos(a) * 0.28, 0.25, sin(a) * 0.28), Vector3(cos(a), 0, sin(a)), 0.35, 0.75)
		b.vb(q + Vector3(0, hh, 0), Vector3(1.5, 0.12, 0.6), IstKB.BRICK, "", Vector3(0, rot, 0))
	b.vball(Vector3(-2.2, 0.47, cz + 3.6), 1.7, IstKB.LEAD, Vector3(1.0, 0.32, 0.8), 10)       # düşmüş kubbe kabuğu
	b.vball(Vector3(2.6, 0.4, cz - 0.8), 1.0, IstKB.LEAD.darkened(0.1), Vector3(1.0, 0.28, 0.7), 8)
	# sütunlar: ikisi ayakta (biri başlıklı), ikisi devrik (katı)
	for c: Array in [[Vector3(-2.9, 0.22, L * 0.22), 4.0, true], [Vector3(2.9, 0.22, L * 0.22), 2.6, false]]:
		var cp: Vector3 = c[0]
		b.sb(cp, Vector3(0.8, 0.3, 0.8), IstKB.MARBLE, "marble")
		b.sc(cp + Vector3(0, 0.3, 0), 0.3, float(c[1]), IstKB.MARBLE, "marble", 10)
		if bool(c[2]):
			b.sb(cp + Vector3(0, 0.3 + float(c[1]), 0), Vector3(0.8, 0.35, 0.8), IstKB.MARBLE, "marble")
	for i in 2:
		var d := b.vc(Vector3(3.6 - i * 7.4, 0.52, L * 0.1 + i * 0.9), 0.3, 1.6, IstKB.MARBLE, 10, Vector3(0, 0, 90), -1.0, true)
		if d:
			d.rotation_degrees.y = 25.0 + i * 70.0
			d.set_meta("dekor", false)
			Props.make_solid(d as MeshInstance3D)
	# düşmüş taşlar, sarmaşık, ot, duvar tepesinde incir fidanı
	for i in 9:
		var sx := b.rng.randf_range(-W * 0.4, W * 0.4)
		var sz := b.rng.randf_range(-L * 0.4, L * 0.45)
		b.vb(Vector3(sx, _zemin(sx, sz, W, L), sz), Vector3(0.6, 0.35, 0.45), IstKB.STONE_D, "ashlar", Vector3(0, b.rng.randf() * 90.0, 0))
	for i in 26:
		var s := -1.0 if i % 3 != 0 else 1.0
		b.ivy(Vector3(s * (wx + wt * 0.5 + 0.05), b.rng.randf_range(0.5, H * 0.6), b.rng.randf_range(-L * 0.45, L * 0.2)), b.rng.randf_range(0.3, 0.6))
	for i in 6:
		var a := PI + PI * b.rng.randf()
		b.ivy(Vector3(cos(a) * (ap + 0.05), b.rng.randf_range(0.4, 2.6), zc + sin(a) * (ap + 0.05)), b.rng.randf_range(0.3, 0.5))
	b.grass_patch(Vector3(-2.0, 0.22, L * 0.12), 2.6, 3.0)
	b.grass_patch(Vector3(2.2, 0.22, -L * 0.3), 1.8, 2.2)
	b.grass_patch(Vector3(0.0, 0.22, L * 0.4), 2.0, 1.4)
	if tops.has("p"):
		var tp: Vector3 = tops["p"]
		b.vc(tp, 0.07, 1.0, IstKB.WOOD_D, 5)
		b.vball(tp + Vector3(0, 1.0, 0), 0.55, Color("5b8a3a"), Vector3(1, 0.8, 1), 7)
	b.tree_cypress(Vector3(W * 0.5 + 2.4, 0, -L * 0.35), 6.5)
	b.flush()


## Döşeme kaidesinin üstü mü (0,22 m) yoksa toprak mı (0): yerdeki parçalar gömülmesin, havada kalmasın
static func _zemin(x: float, z: float, W: float, L: float) -> float:
	if absf(x) < (W - 0.2) * 0.5 - 0.3 and z > -L * 0.5 + 0.3 and z < L * 0.3 - 0.3:
		return 0.22
	if x > -W * 0.2 - W * 0.275 + 0.3 and x < -W * 0.2 + W * 0.275 - 0.3 and z > L * 0.27 + 0.3 and z < L * 0.49 - 0.3:
		return 0.22
	return 0.0
