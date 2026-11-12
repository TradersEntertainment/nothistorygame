class_name IstOrdugahYapi2
extends RefCounted
## Ordugâh yapıları (2): mescit çadırı, pazar, mutfak (kazanlar), at–deve bağı, siper hattı (sedde + kazık çit + hendek şeridi).
## Gereçler gerçek boyda; k yalnız alan büyüklüğünü ölçekler.

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const B = K.Bld
const Y = preload("res://scripts/world/ist/ordugah_yapi.gd")
const KS = preload("res://scripts/world/ist/ordugah_kisi.gd")


# ------------------------------------------------------------------ Mescit çadırı

static func build_mescit(host: Node3D, k: float, lod: int, tohum := 3) -> void:
	var c := B.new("plaster")
	var w := B.new("wood")
	var m := B.new("")
	var L := 14.0
	var Wd := 9.0
	# halı safları (kıble: −z yönü; kuzey değil, sur karşısı = yerel +z olsun diye kıble +z)
	c.box(Vector3(0, 0.06, 0), Vector3(L - 0.6, 0.1, Wd - 0.6), Color("9a2f2a"))
	for i in 5:
		c.box(Vector3(0, 0.12, -Wd / 2 + 1.2 + i * 1.5), Vector3(L - 1.4, 0.03, 0.9), K.KREM if i % 2 == 0 else K.LACI)
	c.solid_box(Vector3(0, 0.05, 0), Vector3(L - 0.6, 0.1, Wd - 0.6))
	# direkler (altı) ve çatı: yeşil-beyaz şeritli, sırt x boyunca
	for ix in [-1, 0, 1]:
		for sz in [-1, 1]:
			w.cylp(Vector3(ix * (L / 2 - 0.5), 1.9, sz * (Wd / 2 - 0.3)), 0.11, 3.8, K.AHSAP2, 6)
			w.solid_cyl(Vector3(ix * (L / 2 - 0.5), 1.9, sz * (Wd / 2 - 0.3)), 0.13, 3.8)
	c.prism(B.xf(Vector3(0, 3.7, 0)), Vector3(L + 1.0, 2.0, Wd + 1.2), K.YESIL)
	for i in 7:
		c.box(Vector3(-L / 2 + 0.6 + i * (L - 1.2) / 6.0, 4.73, 0), Vector3(0.7, 0.05, 0.1), K.KREM)
	c.solid_box(Vector3(0, 4.3, 0), Vector3(L + 0.8, 1.4, Wd + 1.0))          # çatı kütlesi (katı)
	# kıble (yerel +z) duvarı: kumaş perde ve mihrap nişi
	c.box(Vector3(0, 1.7, Wd / 2 - 0.1), Vector3(L, 3.4, 0.1), K.KREM)
	c.box(Vector3(0, 1.4, Wd / 2 - 0.16), Vector3(1.6, 2.4, 0.06), K.LACI)
	c.box(Vector3(0, 2.8, Wd / 2 - 0.16), Vector3(1.1, 1.1, 0.06), K.LACI, 0.0, Vector3(0, 0, 45))
	c.solid_box(Vector3(0, 1.7, Wd / 2 - 0.05), Vector3(L, 3.4, 0.16))
	# yan perdeler yarım (rüzgâr)
	for sd in [-1, 1]:
		c.box(Vector3(sd * (L / 2 - 0.08), 0.9, 0), Vector3(0.08, 1.8, Wd - 0.6), K.KREM.darkened(0.04))
		c.solid_box(Vector3(sd * (L / 2 - 0.08), 0.9, 0), Vector3(0.12, 1.8, Wd - 3.0))
	# sancak + alem
	var sf := B.new()
	Y.sancak(w, sf, Vector3(L / 2 + 0.6, 0, -Wd / 2 - 0.4), 6.0, K.YESIL)
	w.solid_cyl(Vector3(L / 2 + 0.6, 3.0, -Wd / 2 - 0.4), 0.08, 6.0)
	# abdest teknesi
	if lod <= 1:
		w.box(Vector3(-L / 2 - 2.2, 0.5, -1.5), Vector3(0.8, 1.0, 3.4), K.AHSAP)
		w.solid_box(Vector3(-L / 2 - 2.2, 0.5, -1.5), Vector3(0.8, 1.0, 3.4))
		for i in 4:
			m.cylp(Vector3(-L / 2 - 2.2, 1.12, -2.9 + i * 0.9), 0.17, 0.25, K.BRONZ, 8)
	c.done(host, "bez")
	w.done(host, "ahsap")
	m.done(host, "bakir")
	sf.done(host, "bayrak")


# ------------------------------------------------------------------ Pazar

static func build_pazar(host: Node3D, k: float, lod: int, tohum := 21) -> void:
	var r := K.rr(tohum)
	var c := B.new("plaster")
	var w := B.new("wood")
	var m := B.new("")
	var rows := 2
	var cols := int(clampf(4 + k * 4, 4, 8))
	for ri in rows:
		for ci in cols:
			var p := Vector3((ci - (cols - 1) * 0.5) * 7.0, 0, (ri - 0.5) * 11.0)
			var yaw := 0.0 if ri == 0 else 180.0
			var col: Color = [K.KIRMIZI2, K.LACI, K.YESIL, K.ALTIN.darkened(0.15), K.BEZ][r.randi() % 5]
			# tezgâh (0,95 m), arka direkler, saçak (2,4 m) bantlı
			w.box(p + Vector3(0, 0.47, 0), Vector3(3.4, 0.94, 1.0), K.AHSAP, yaw)
			w.solid_box(p + Vector3(0, 0.47, 0), Vector3(3.4, 0.94, 1.0), yaw)
			for sx in [-1.7, 1.7]:
				w.cylp(p + Vector3(sx, 1.25, -0.5).rotated(Vector3.UP, deg_to_rad(yaw)), 0.06, 2.5, K.AHSAP2, 5)
				w.cylp(p + Vector3(sx, 1.1, 0.7).rotated(Vector3.UP, deg_to_rad(yaw)), 0.06, 2.2, K.AHSAP2, 5)
			c.box(p + Vector3(0, 2.38, 0.1).rotated(Vector3.UP, deg_to_rad(yaw)), Vector3(3.8, 0.07, 2.4), col, yaw, Vector3(-12, 0, 0))
			for q in 6:
				c.box(p + Vector3(-1.5 + q * 0.6, 2.4, 1.05).rotated(Vector3.UP, deg_to_rad(yaw)), Vector3(0.3, 0.06, 0.25), K.KREM, yaw, Vector3(-12, 0, 0))
			# mal: çuvallar, küpler, kumaş balyaları
			if lod <= 1:
				for q in 4:
					var gp := p + Vector3(-1.3 + q * 0.85, 1.1, 0.0).rotated(Vector3.UP, deg_to_rad(yaw))
					match (q + ri + ci) % 3:
						0: c.box(gp, Vector3(0.5, 0.3, 0.4), K.SAMAN, yaw)
						1: m.cylp(gp + Vector3(0, 0.05, 0), 0.2, 0.36, K.TOPRAK, 8, 0.12)
						2: c.box(gp, Vector3(0.55, 0.28, 0.4), [K.KIRMIZI2, K.LACI, K.YESIL][q % 3], yaw)
				# yere kasa ve fıçı
				w.box(p + Vector3(2.4, 0.3, 0.9).rotated(Vector3.UP, deg_to_rad(yaw)), Vector3(0.7, 0.6, 0.7), K.AHSAP_A, yaw + 12.0)
				w.solid_box(p + Vector3(2.4, 0.3, 0.9).rotated(Vector3.UP, deg_to_rad(yaw)), Vector3(0.7, 0.6, 0.7), yaw + 12.0)
	# orta yol halıları / tabela direği
	c.done(host, "bez")
	w.done(host, "ahsap")
	m.done(host, "kap")


# ------------------------------------------------------------------ Mutfak: kazanlar, ocak, odun

static func build_mutfak(host: Node3D, k: float, lod: int, tohum := 4) -> void:
	var r := K.rr(tohum)
	var m := B.new("")
	var t := B.new("rubble")
	var w := B.new("wood")
	var c := B.new("plaster")
	var n := 6
	for i in n:
		var p := Vector3((i - (n - 1) * 0.5) * 3.4, 0, 0)
		# taş ocak halkası + kazan + kapak
		t.cylp(p + Vector3(0, 0.3, 0), 1.2, 0.6, K.TAS.darkened(0.15), 10)
		t.solid_cyl(p + Vector3(0, 0.3, 0), 1.2, 0.6)
		m.cylp(p + Vector3(0, 1.05, 0), 0.95, 0.9, K.BRONZ.lightened(0.06), 12, 1.05)
		m.cylp(p + Vector3(0, 1.52, 0), 1.08, 0.12, K.BRONZ.darkened(0.2), 12)
		m.solid_cyl(p + Vector3(0, 1.0, 0), 1.0, 2.0)
		m.sph(p + Vector3(0, 1.58, 0), 0.9, K.BRONZ.darkened(0.1), 8, Vector3(1, 0.1, 1))
		if lod <= 1:
			m.cylp(p + Vector3(1.0, 0.95, 0.0), 0.06, 0.4, K.DEMIR, 5, -1.0, Vector3(0, 0, 90))      # kulp
			m.cylp(p + Vector3(-1.0, 0.95, 0.0), 0.06, 0.4, K.DEMIR, 5, -1.0, Vector3(0, 0, 90))
			# odun yığını
			for q in 6:
				w.cylp(p + Vector3(-0.7 + q * 0.28, 0.12 + (q % 2) * 0.2, 1.8), 0.1, 1.0, K.AHSAP_A, 5, -1.0, Vector3(0, 0, 90))
			w.solid_box(p + Vector3(0, 0.25, 1.8), Vector3(1.9, 0.5, 0.8))
	if lod <= 1:
		# su fıçıları, un çuvalları, uzun masa
		for i in 4:
			w.cylp(Vector3(-9.0 + i * 0.9, 0.5, -3.4), 0.4, 1.0, K.AHSAP, 8)
			w.solid_cyl(Vector3(-9.0 + i * 0.9, 0.5, -3.4), 0.4, 1.0)
		for i in 7:
			c.box(Vector3(8.0 + (i % 3) * 0.7, 0.2 + (i / 3) * 0.4, -3.4), Vector3(0.6, 0.35, 0.4), K.SAMAN, r.randf_range(-10, 10))
		c.solid_box(Vector3(8.7, 0.5, -3.4), Vector3(2.2, 1.0, 0.8))
		w.box(Vector3(0, 0.46, -3.4), Vector3(8.0, 0.1, 1.0), K.AHSAP_A)
		for sx in [-3.6, 3.6]:
			w.box(Vector3(sx, 0.23, -3.4), Vector3(0.1, 0.46, 0.8), K.AHSAP2)
		w.solid_box(Vector3(0, 0.23, -3.4), Vector3(8.0, 0.46, 1.0))
	# yaş yanık tandır höyüğü
	t.sph(Vector3(13.0, 0.0, 1.0), 1.5, K.TOPRAK2, 7, Vector3(1, 0.7, 1))
	t.solid_cyl(Vector3(13.0, 0.5, 1.0), 1.4, 1.0)
	# kazan ateşleri (gece/gündüz) tek çoklu ağ (ORDUGÂH-4: önce kazan başına 3 çizim)
	if lod <= 1:
		var fp: Array = []
		for i in n:
			fp.append(Vector2((i - (n - 1) * 0.5) * 3.4, 1.3))
		K.ateslar(host, fp, lod, 0.45, true, 0.35, 0.55)
		# aşçılar ve odun taşıyan (gerçek model / figür)
		var kisi: Array = []
		for i in n:
			kisi.append([Vector3((i - (n - 1) * 0.5) * 3.4 + 0.2, 0, -1.25), 0.0, "asci"])
		kisi.append([Vector3(-10.5, 0, -2.2), PI / 2.0, "saka"])
		kisi.append([Vector3(9.5, 0, -2.4), -PI / 2.0, "balta"])
		for q in 6:
			kisi.append([Vector3(-6.0 + q * 2.4, 0, -5.6), 0.0, "otur"])
		for kk: Array in kisi:
			var p0: Vector3 = kk[0]
			p0.y = K.gy(p0.x, p0.z)
			kk[0] = p0
		KS.kur(host, kisi, lod)
	m.done(host, "kazan")
	t.done(host, "ocak")
	w.done(host, "ahsap")
	c.done(host, "bez")


# ------------------------------------------------------------------ At ve deve bağı

static func _at(b: B, p: Vector3, yaw: float, col: Color, deve := false) -> void:
	# CANLI (kalite notu 32): at ve ayakta deve canli_kit'ten (kesit halkalı gövde, eklemli bacak, yele, kuyruk); kutu yok.
	const CK = preload("res://scripts/world/ist/canli_kit.gd")
	var hs := absi(int(p.x * 11.0 + p.z * 5.0))
	var pz: String = ["dur", "otla", "dur", "dur", "otla"][hs % 5]
	if deve:
		CK.bld_ekle(b, "deve", p, yaw, {"renk": col, "poz": pz, "bas_yaw": float(hs % 3 - 1) * 15.0, "takim": ["yular"], "tohum": hs})
	else:
		CK.bld_ekle(b, "at", p, yaw, {"renk": col, "poz": pz, "bas_yaw": float(hs % 5 - 2) * 10.0, "takim": ["cul", "yular"], "tohum": hs})
	var h := 1.5 if deve else 1.15
	var ln := 2.2 if deve else 1.9
	b.solid_box(p + Vector3(0, h * 0.5 + 0.1, 0.2).rotated(Vector3.UP, deg_to_rad(yaw)), Vector3(0.9, h + 0.4, ln + 1.0), yaw)


static func build_ahir(host: Node3D, k: float, lod: int, tohum := 6) -> void:
	var r := K.rr(tohum)
	var a := B.new("")
	var w := B.new("wood")
	var s := B.new("")
	var n := 10
	var span := 3.0
	# bağ kazığı hattı + ip
	for i in n + 1:
		var x := (i - n * 0.5) * span
		w.cylp(Vector3(x, 0.8, 0), 0.07, 1.6, K.AHSAP2, 5)
	w.box(Vector3(0, 1.25, 0), Vector3(n * span, 0.04, 0.04), K.DERI.darkened(0.2))
	for i in n:
		var x2 := (i - n * 0.5 + 0.5) * span
		var deve := i % 4 == 3
		var col: Color = [Color("6a4a30"), Color("8a6a46"), Color("3a2e26"), Color("a88a62"), Color("c9b080")][r.randi() % 5]
		if deve:
			col = Color("b49a6c")
		_at(a, Vector3(x2, 0, 1.6), 90.0 + r.randf_range(-6, 6), col, deve)
		# yem
		s.cylp(Vector3(x2 + 0.0, 0.3, -1.0), 0.8, 0.6, K.SAMAN, 8, 0.1)
	# su tekneleri
	w.box(Vector3(-6.0, 0.35, -3.6), Vector3(4.0, 0.7, 0.9), K.AHSAP)
	w.solid_box(Vector3(-6.0, 0.35, -3.6), Vector3(4.0, 0.7, 0.9))
	w.box(Vector3(6.0, 0.35, -3.6), Vector3(4.0, 0.7, 0.9), K.AHSAP)
	w.solid_box(Vector3(6.0, 0.35, -3.6), Vector3(4.0, 0.7, 0.9))
	# semer sehpası
	for i in 3:
		w.box(Vector3(-2.0 + i * 2.0, 0.55, -3.6), Vector3(0.1, 1.1, 0.6), K.AHSAP2)
		w.box(Vector3(-2.0 + i * 2.0, 1.1, -3.6), Vector3(0.9, 0.12, 0.5), K.AHSAP)
	a.done(host, "hayvan")
	w.done(host, "ahsap")
	s.done(host, "saman")


# ------------------------------------------------------------------ Siper hattı

## Hattın sağ eli (yön d için (−d.y, d.x)'in ters işareti) ÖN'dür: hat ön yüzü yerel +z'ye bakar biçimde verilirse
## "sol" = ön alınır; çağıran sur yönünü dot ile denetleyip hattı çevirir. line: host yerel (x,z), tipik 60–110 m.
static func front_of(d: Vector2) -> Vector2:
	return Vector2(-d.y, d.x)


static func build_siper(host: Node3D, k: float, lod: int, tohum := 8, line := PackedVector2Array()) -> void:
	if line.size() < 2:
		line = PackedVector2Array([Vector2(-40, 0), Vector2(40, 0)])
	var r := K.rr(tohum)
	var e := B.new("rubble")
	var w := B.new("wood")
	var strip := B.new("")
	strip.cast = false
	var total := 0.0
	for i in line.size() - 1:
		total += line[i].distance_to(line[i + 1])
	var acc := 0.0
	var gap_every := 28.0
	var next_gap := 12.0
	for i in line.size() - 1:
		var a := line[i]
		var b2 := line[i + 1]
		var d := (b2 - a)
		var L := d.length()
		if L < 0.1:
			continue
		var dn := d / L
		var fr := front_of(dn)
		var yaw := rad_to_deg(atan2(-dn.y, dn.x))
		var nseg := maxi(int(ceil(L / 3.0)), 1)
		for s in nseg:
			var t0 := float(s) / nseg
			var t1 := float(s + 1) / nseg
			var p0 := a.lerp(b2, t0)
			var p1 := a.lerp(b2, t1)
			var pm := (p0 + p1) * 0.5
			var sl := p0.distance_to(p1)
			acc += sl
			var gap := acc >= next_gap
			if gap:
				next_gap += gap_every
			var y0 := K.gy(pm.x, pm.y)
			# hendek şeridi (zemine yapışık koyu toprak, ≥ 2 cm pay): sedde ile çit arası
			var sp := pm + fr * 4.0
			strip.box(Vector3(sp.x, K.gy(sp.x, sp.y) + 0.04, sp.y), Vector3(sl + 0.05, 0.06, 3.4), K.CAMUR, yaw)
			if gap:
				continue
			# sedde: yamuk gövde (taban 3,2 / tepe 1,3, yükseklik 1,5), katı
			var base_c := Vector3(pm.x, y0 - 0.35, pm.y)
			var xf0 := Transform3D(Basis.from_euler(Vector3(0, deg_to_rad(yaw), 0)), base_c)
			var hw := sl * 0.5 + 0.03
			var pts := [Vector3(-hw, 0, -1.6), Vector3(hw, 0, -1.6), Vector3(hw, 0, 1.6), Vector3(-hw, 0, 1.6),
				Vector3(-hw, 1.85, -0.7), Vector3(hw, 1.85, -0.7), Vector3(hw, 1.85, 0.7), Vector3(-hw, 1.85, 0.7)]
			for q in pts.size():
				pts[q] = xf0 * (pts[q] as Vector3)
			# ön yön: yerel +z, ancak çağıran fr işaretini yaw ile uyumlandırır (xf0 +z = fr ise)
			var cc := base_c + Vector3(0, 0.9, 0)
			var fcs := [[0, 1, 2, 3], [4, 7, 6, 5], [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3], [3, 7, 4, 0]]
			for fi in fcs.size():
				var q2: Array = []
				var mm := Vector3.ZERO
				for jj in fcs[fi]:
					q2.append(pts[jj])
					mm += pts[jj]
				mm /= 4.0
				var col := K.TOPRAK2.darkened(0.05 * ((s + fi) % 3))
				if fi == 1:
					col = K.TOPRAK.lightened(0.05)
				e.poly(q2, mm - cc, col)
			e.solid_hull(PackedVector3Array(pts))
			# gabyon (sepet) 12 m'de bir öne dizili; tüm hat boyunca çit
			if lod <= 1 and s % 4 == 1:
				for g in 3:
					var gp := pm + fr * 1.9 + dn * (-0.95 + g * 0.95)
					e.cylp(Vector3(gp.x, K.gy(gp.x, gp.y) + 0.55, gp.y), 0.45, 1.1, K.SEPET, 8)
					e.solid_cyl(Vector3(gp.x, K.gy(gp.x, gp.y) + 0.55, gp.y), 0.45, 1.1)
			# kazık çit: iki kat, sivri uçlu eğik kazıklar (kafes), 7 m'de bir geçit — çit z=+7 önde
			if lod == 0 or s % 2 == 0:
				var cp := pm + fr * 6.6
				var cy := K.gy(cp.x, cp.y)
				w.box(Vector3(cp.x, cy + 0.65, cp.y), Vector3(sl, 1.3, 0.3), K.AHSAP2, yaw)
				w.solid_box(Vector3(cp.x, cy + 0.65, cp.y), Vector3(sl, 1.3, 0.3), yaw)
				if lod == 0:
					for q in int(sl / 0.5):
						var cq := cp + dn * (-sl / 2 + 0.25 + q * 0.5)
						w.box(Vector3(cq.x, cy + 1.35, cq.y), Vector3(0.12, 0.9, 0.12), K.AHSAP_A, yaw, Vector3(r.randf_range(-12, 12), 0, r.randf_range(-14, 14)))
	e.done(host, "sedde")
	w.done(host, "cit")
	strip.done(host, "hendek")


# ------------------------------------------------------------------ Sancak ormanı (alan süsü)

static func build_sancaklar(host: Node3D, k: float, lod: int, tohum := 14) -> void:
	var r := K.rr(tohum)
	var w := B.new("wood")
	var f := B.new("")
	for i in 5:
		var p := Vector3(i * 6.0 - 12.0, 0, r.randf_range(-2, 2))
		Y.sancak(w, f, p, r.randf_range(5.0, 8.0), [K.KIRMIZI, K.YESIL, K.LACI, K.KIRMIZI2, K.ALTIN][i], i == 2)
		w.solid_cyl(p + Vector3(0, 3.0, 0), 0.07, 6.0)
	w.done(host, "dir")
	f.done(host, "bayrak")
