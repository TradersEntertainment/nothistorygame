class_name IstKiliseTipleri
extends RefCounted
## Kilise tipleri: kapalı Yunan haçı (tek kubbe), dört sütunlu orta kilise, bazilika, şapel.
## Her işlev IstKB (b) alır; b.dry iken yalnız perches / climbs hesaplanır.


## ---------------------------------------------------------------- kilise_kucuk
static func kucuk(b: IstKB) -> void:
	var st := b.stone
	var cw := maxf(b.S(4.4), 3.2)         # merkez kare
	var aw := maxf(b.S(3.8), 2.6)         # kol genişliği
	var al := maxf(b.S(2.8), 2.0)         # kol uzunluğu (merkezin ötesi)
	var cH := b.Hs(6.4, 4.6)
	var aH := cH * 0.76
	var nd := maxf(b.S(3.0), 2.4)         # narteks derinliği
	var nH := maxf(cH * 0.62, 3.1)
	var nw := cw + 2.0 * al               # narteks genişliği
	var rise := clampf(b.S(1.7), 0.9, cH - aH - 0.6)
	var ap_r := aw * 0.5
	var z_s := cw * 0.5 + al              # güney kolun ucu
	var z_n := -(cw * 0.5 + al)
	var total_n := z_n - ap_r
	var total_s := z_s + nd
	b.set_pivot(Vector3(0, 0, -(total_n + total_s) * 0.5))
	var apex_y := cH
	# ---- lod 2: siluet
	if b.lod == 2:
		b.sb(Vector3(0, 0, 0), Vector3(cw, cH, cw), st)
		b.sb(Vector3(0, 0, 0), Vector3(nw, aH, aw), st)
		b.sb(Vector3(0, 0, 0), Vector3(aw, aH, cw + 2.0 * al), st)
		b.sb(Vector3(0, 0, z_s + nd * 0.5), Vector3(nw, nH, nd), st)
		var r2 := cw * 0.46
		b.sc(Vector3(0, cH, 0), r2, maxf(b.S(2.8), 1.5), st, "", 8)
		b.dome(Vector3(0, cH + maxf(b.S(2.8), 1.5), 0), r2 * 1.05, r2 * 0.65, 8, 0.9)
		return
	# ---- ana kütleler
	b.sb(Vector3(0, 0, 0), Vector3(cw, cH, cw), st, "ashlar")
	b.sb(Vector3(0, 0, z_n * 0.5 - 0.1), Vector3(aw, aH, al + cw * 0.5 + 0.2), st, "ashlar")                # kuzey kol (apsis tarafı)
	b.sb(Vector3(0, 0, z_s * 0.5 + 0.1), Vector3(aw, aH, al + cw * 0.5 + 0.2), st, "ashlar")                # güney kol
	b.sb(Vector3(-(cw * 0.5 + al) * 0.5 - 0.1, 0, 0), Vector3(al + cw * 0.5 + 0.2, aH, aw), st, "ashlar")   # batı kol
	b.sb(Vector3((cw * 0.5 + al) * 0.5 + 0.1, 0, 0), Vector3(al + cw * 0.5 + 0.2, aH, aw), st, "ashlar")    # doğu kol
	# kolların beşik çatıları (mahya kol boyunca); merkez duvarın altına girer
	var ov := 0.35
	b.gable(Vector3(0, aH, z_n * 0.5 - 0.1), aw + ov, rise, al + cw * 0.5 + 0.2, IstKB.TILE, true)
	b.gable(Vector3(0, aH, z_s * 0.5 + 0.1), aw + ov, rise, al + cw * 0.5 + 0.2, IstKB.TILE, true)
	b.gable(Vector3(-(cw * 0.5 + al) * 0.5 - 0.1, aH, 0), aw + ov, rise, al + cw * 0.5 + 0.2, IstKB.TILE, false)
	b.gable(Vector3((cw * 0.5 + al) * 0.5 + 0.1, aH, 0), aw + ov, rise, al + cw * 0.5 + 0.2, IstKB.TILE, false)
	# apsis: 9 kenarlı yarım silindir + koni çatı
	var ap_h := aH * 0.9
	b.sc(Vector3(0, 0, z_n), ap_r, ap_h, st, "ashlar", 9)
	b.sc(Vector3(0, ap_h, z_n), ap_r + 0.12, 1.1, IstKB.TILE, "tiles", 9, 0.05)
	# kasnak, kubbe
	var dr := cw * 0.46
	var dH := maxf(b.S(2.8), 1.5)
	b.sc(Vector3(0, cH, 0), dr, dH, st, "ashlar", 8)
	b.sc(Vector3(0, cH + dH - 0.05, 0), dr * 1.1, 0.18, IstKB.STONE_D, "", 8)          # saçak halkası
	var apex := b.dome(Vector3(0, cH + dH + 0.12, 0), dr * 1.06, dr * 0.66, 12, clampf(b.S(2.4), 0.9, 1.4))
	apex_y = apex.y
	# ---- narteks (düz çatı, yürünebilir) + kenarlık
	var nz := z_s + nd * 0.5
	b.sb(Vector3(0, 0, nz), Vector3(nw, nH - 0.12, nd), st, "ashlar")
	b.sb(Vector3(0, nH - 0.12, nz), Vector3(nw + 0.2, 0.12, nd + 0.2), IstKB.TILE, "tiles")
	var kerb := 0.35
	# kenarlık: güney ve doğu; batıda merdiven girişi açık, kuzey kol duvarına yaslı
	b.sb(Vector3(0, nH, z_s + nd - 0.1), Vector3(nw + 0.2, kerb, 0.2), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(nw * 0.5, nH, nz), Vector3(0.2, kerb, nd + 0.2), IstKB.STONE_D, "ashlar")
	# merdiven (batıdan narteks damına)
	var run := b.stair_run(nH)
	var sx0 := -nw * 0.5 - 0.1 - run
	var sres := b.stair(Vector3(sx0, 0, nz), Vector3.RIGHT, 1.5, nH, IstKB.STONE_D)
	b.add_climb(sres[0], Vector3(-nw * 0.5 + 0.8, nH, nz), "basamak")
	b.add_perch(Vector3(nw * 0.25, nH, nz))
	b.add_perch(apex + Vector3(0.2, 0.0, 0.0))
	if b.lod == 1:
		return
	# ---- ayrıntı
	b.door(Vector3(0, 0, z_s + nd), Vector3(0, 0, 1), 1.4, 2.0)
	for s in [-1.0, 1.0]:
		b.win(Vector3(s * (nw * 0.5 - 0.9), 1.3, z_s + nd), Vector3(0, 0, 1), 0.5, 1.0)
	# kolların uç duvarlarında çifte pencere, güney kolun üst kısmında (narteks üstünde)
	b.win(Vector3(-(cw * 0.5 + al), 1.4, 0.0), Vector3(-1, 0, 0), 0.55, 1.5)
	b.win(Vector3((cw * 0.5 + al), 1.4, 0.0), Vector3(1, 0, 0), 0.55, 1.5)
	b.win(Vector3(0, nH + 0.7, z_s), Vector3(0, 0, 1), 0.6, 1.2)
	# kasnak pencereleri (12 yön değil 8 yüz; yüz ortalarında, Godot silindir yüz düzenine göre)
	for i in 8:
		var a := (i + 0.5) * TAU / 8.0
		var d := Vector3(sin(a), 0, cos(a))
		b.win(Vector3(0, cH + 0.3, 0) + d * (dr * cos(PI / 8.0) + 0.0), d, 0.42, dH * 0.6)
	# apsis pencereleri (9 kenar: 140/180/220°)
	for ad in [140.0, 180.0, 220.0]:
		var a2 := deg_to_rad(ad)
		var d2 := Vector3(sin(a2), 0, cos(a2))
		b.win(Vector3(0, 1.1, z_n) + d2 * (ap_r * cos(PI / 9.0)), d2, 0.4, 1.3)
	# tuğla bantları (opus mixtum): merkez duvarın üst kısmı, narteks, apsis üstü
	b.band_ring(Vector3(0, 0, 0), cw * 0.5, cw * 0.5, cH - 0.42)
	b.band_ring(Vector3(0, 0, nz), nw * 0.5, nd * 0.5, 0.9, 0.14, false)
	b.band_ring(Vector3(0, 0, nz), nw * 0.5, nd * 0.5, nH - 0.55, 0.14, false)
	# mahya taşları
	b.ridge(Vector3(0, aH + rise, z_n * 0.5 - 0.1), al + cw * 0.5 + 0.2)
	b.ridge(Vector3(0, aH + rise, z_s * 0.5 + 0.1), al + cw * 0.5 + 0.2)
	b.ridge(Vector3(-(cw * 0.5 + al) * 0.5 - 0.1, aH + rise, 0), al + cw * 0.5 + 0.2, false)
	b.ridge(Vector3((cw * 0.5 + al) * 0.5 + 0.1, aH + rise, 0), al + cw * 0.5 + 0.2, false)
	# semantron (narteks batı ucunda, duvardan sarkan tahta çan)
	b.semantron(Vector3(-nw * 0.5 + 1.2, nH - 0.4, z_s + nd), Vector3(0, 0, 1))
	# ölü yosun ve ot dibinde
	b.grass_patch(Vector3(nw * 0.5 + 0.8, 0, nz + 0.4), 0.8, 1.4)
	b.flush()


## -------------------------------------------------------------------- sapel
static func sapel(b: IstKB) -> void:
	var st := b.stone
	var w := maxf(b.S(4.6), 3.0)
	var l := maxf(b.S(6.8), 4.4)
	var h := b.Hs(4.2, 3.4)
	var rise := clampf(b.S(2.2), 1.0, 2.2)
	var ap_r := w * 0.42
	var pd := maxf(b.S(2.2), 1.9)              # sundurma derinliği (giriş revağı)
	var ph := 2.7                              # sundurma damı yüksekliği (insana göre)
	b.set_pivot(Vector3(0, 0, -(-(l * 0.5 + ap_r) + (l * 0.5 + pd)) * 0.5))
	if b.lod == 2:
		b.sb(Vector3(0, 0, 0), Vector3(w, h, l), st)
		b.gable(Vector3(0, h, 0), w + 0.3, rise, l + 0.3, IstKB.TILE, true, "")
		return
	b.sb(Vector3(0, 0, 0), Vector3(w, h, l), st, "ashlar")
	b.gable(Vector3(0, h, 0), w + 0.5, rise, l + 0.5, IstKB.TILE, true)
	# apsis çıkıntısı
	b.sc(Vector3(0, 0, -l * 0.5), ap_r, h * 0.82, st, "ashlar", 9)
	b.sc(Vector3(0, h * 0.82, -l * 0.5), ap_r + 0.1, 0.9, IstKB.TILE, "tiles", 9, 0.05)
	# güney sundurma: ahşap-taş sundurma, düz damı yürünebilir (merdivenle)
	var pz := l * 0.5 + pd * 0.5
	b.sb(Vector3(-w * 0.5 + 0.35, 0, l * 0.5 + pd - 0.35), Vector3(0.7, ph, 0.7), st, "ashlar")      # sütun payeleri
	b.sb(Vector3(w * 0.5 - 0.35, 0, l * 0.5 + pd - 0.35), Vector3(0.7, ph, 0.7), st, "ashlar")
	b.sb(Vector3(0, ph, pz), Vector3(w + 0.3, 0.25, pd + 0.1), IstKB.TILE, "tiles")                 # sundurma damı
	# yan duvarlar: sundurmanın yanlarını kapat (sundurma içine girilir; iki pay arası ≥ 1,4)
	var run := b.stair_run(ph + 0.25)
	var sres := b.stair(Vector3(w * 0.5 + 0.1 + run, 0, pz), Vector3.LEFT, 1.4, ph + 0.25, IstKB.STONE_D)
	b.add_climb(sres[0], Vector3(w * 0.5 - 0.8, ph + 0.25, pz), "basamak")
	var apex := Vector3(0, h + rise + 0.1, 0)
	b.add_perch(Vector3(0, ph + 0.25, pz))
	b.add_perch(apex)
	b.sb(apex - Vector3(0, 0.1, 0) + Vector3(0, 0, l * 0.5 + 0.1), Vector3(0.5, 0.35, 0.5), IstKB.STONE_D)   # alın üstü taş haç kaidesi
	if b.lod == 1:
		return
	b.cross(apex + Vector3(0, 0.3, l * 0.5 + 0.1), 0.9)
	b.door(Vector3(0, 0, l * 0.5), Vector3(0, 0, 1), 1.3, 2.0)
	for s in [-1.0, 1.0]:
		b.win(Vector3(s * w * 0.5, 1.5, -0.6), Vector3(s, 0, 0), 0.45, 1.1)
		b.win(Vector3(s * w * 0.5, 1.5, 1.2), Vector3(s, 0, 0), 0.45, 1.1)
	b.win(Vector3(0, 1.3, -l * 0.5 - ap_r * cos(PI / 9.0)), Vector3(0, 0, -1), 0.4, 1.2)
	b.band_ring(Vector3(0, 0, 0), w * 0.5, l * 0.5, h - 0.5)
	b.ridge(Vector3(0, h + rise, 0), l + 0.5)
	b.semantron(Vector3(w * 0.5 - 0.3, ph - 0.15, l * 0.5 + pd), Vector3(0, 0, 1))
	b.lamp(Vector3(-w * 0.5 + 0.6, 1.5, l * 0.5 + pd - 0.05), 0.8)
	b.tree_cypress(Vector3(-w * 0.5 - 2.2, 0, 0.5), 5.0)
	b.flush()


## --------------------------------------------------------------- kilise_orta
## Dört sütunlu orta kilise: çapraz beşik çatılı gövde, kasnaklı kubbe, üç apsis, düz damlı narteks.
static func orta(b: IstKB) -> void:
	var st := b.stone
	var rc := maxf(b.S(2.9), 1.6)
	var rs := maxf(b.S(1.8), 1.1)
	var gs := maxf(b.S(1.5), 1.5)             # apsisler arası açık aralık (≥ 1,4 m)
	var sx := rc + gs + rs
	var W := maxf(b.S(15.0), 2.0 * (sx + rs) + 0.4)
	var L := maxf(b.S(14.0), 6.5)
	var hb := b.Hs(7.0, 5.0)
	var gw := maxf(b.S(6.0), 3.4)
	var gr := clampf(b.S(2.6), 1.2, 2.6)
	var nd := maxf(b.S(4.5), 2.8)
	var nH := maxf(hb * 0.66, 3.4)
	b.set_pivot(Vector3(0, 0, -(nd - rc) * 0.5))
	var dr := gw * 0.46
	var dH := maxf(b.S(4.0), 2.2)
	if b.lod == 2:
		b.sb(Vector3(0, 0, 0), Vector3(W, hb, L), st)
		b.gable(Vector3(0, hb, 0), gw + 0.5, gr, L + 0.4, IstKB.TILE, true, "")
		b.gable(Vector3(0, hb, 0), gw + 0.5, gr, W + 0.4, IstKB.TILE, false, "")
		b.sb(Vector3(0, 0, L * 0.5 + nd * 0.5), Vector3(W, nH, nd), st)
		b.sc(Vector3(0, hb + gr - 0.25, 0), dr, dH, st, "", 8)
		b.dome(Vector3(0, hb + gr - 0.25 + dH, 0), dr * 1.06, dr * 0.68, 8, 1.2)
		b.sc(Vector3(0, 0, -L * 0.5), rc, hb * 0.85, st, "", 9)
		return
	# gövde + çapraz çatılar
	b.sb(Vector3(0, 0, 0), Vector3(W, hb, L), st, "ashlar")
	b.gable(Vector3(0, hb, 0), gw + 0.5, gr, L + 0.5, IstKB.TILE, true)
	b.gable(Vector3(0, hb, 0), gw + 0.5, gr, W + 0.5, IstKB.TILE, false)
	# kasnak ve kubbe
	var by := hb + gr - 0.25
	b.sc(Vector3(0, by, 0), dr, dH, st, "ashlar", 12)
	b.sc(Vector3(0, by + dH - 0.05, 0), dr * 1.1, 0.2, IstKB.STONE_D, "", 12)
	var apex := b.dome(Vector3(0, by + dH + 0.15, 0), dr * 1.07, dr * 0.68, 12, clampf(b.S(2.6), 0.9, 1.5))
	# apsisler: orta büyük, iki yan küçük; aralarında ≥ 1,4 m açık yer
	var ah := hb * 0.85
	b.sc(Vector3(0, 0, -L * 0.5), rc, ah, st, "ashlar", 9)
	b.sc(Vector3(0, ah, -L * 0.5), rc + 0.12, 1.5, IstKB.TILE, "tiles", 9, 0.05)
	for s in [-1.0, 1.0]:
		var sh := hb * 0.62
		b.sc(Vector3(s * sx, 0, -L * 0.5), rs, sh, st, "ashlar", 9)
		b.sc(Vector3(s * sx, sh, -L * 0.5), rs + 0.1, 1.0, IstKB.TILE, "tiles", 9, 0.05)
	# narteks (düz çatı, yürünebilir) + kenarlık + batı merdiveni
	var nz := L * 0.5 + nd * 0.5
	b.sb(Vector3(0, 0, nz), Vector3(W, nH - 0.12, nd), st, "ashlar")
	b.sb(Vector3(0, nH - 0.12, nz), Vector3(W + 0.2, 0.12, nd + 0.2), IstKB.TILE, "tiles")
	b.sb(Vector3(0, nH, L * 0.5 + nd - 0.1), Vector3(W + 0.2, 0.35, 0.2), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(W * 0.5, nH, nz), Vector3(0.2, 0.35, nd + 0.2), IstKB.STONE_D, "ashlar")
	var run := b.stair_run(nH)
	var sres := b.stair(Vector3(-W * 0.5 - 0.1 - run, 0, nz), Vector3.RIGHT, 1.5, nH, IstKB.STONE_D)
	b.add_climb(sres[0], Vector3(-W * 0.5 + 0.8, nH, nz), "basamak")
	b.add_perch(Vector3(W * 0.25, nH, nz))
	b.add_perch(apex + Vector3(0.2, 0, 0))
	if b.lod == 1:
		return
	b.door(Vector3(0, 0, L * 0.5 + nd), Vector3(0, 0, 1), 1.7, 2.1)
	for s in [-1.0, 1.0]:
		b.win(Vector3(s * W * 0.31, 1.3, L * 0.5 + nd), Vector3(0, 0, 1), 0.55, 1.1)
		b.win(Vector3(s * W * 0.5, 1.3, nz), Vector3(s, 0, 0), 0.55, 1.1)
	# gövde güney yüzünde (narteks üstü) üçlü pencere
	if hb - nH > 1.9:
		for dx in [-0.9, 0.0, 0.9]:
			b.win(Vector3(dx, nH + 0.5, L * 0.5), Vector3(0, 0, 1), 0.45 if dx != 0.0 else 0.55, hb - nH - 1.1 if dx == 0.0 else hb - nH - 1.5)
	# yan duvar pencereleri
	for s in [-1.0, 1.0]:
		for zz in [-0.28, 0.0, 0.28]:
			b.win(Vector3(s * W * 0.5, 1.8, L * zz), Vector3(s, 0, 0), 0.5, minf(hb - 3.1, 2.2))
	# kasnak penceleri (12 yüz)
	for i in 12:
		var a := (i + 0.5) * TAU / 12.0
		var d := Vector3(sin(a), 0, cos(a))
		b.win(Vector3(0, by + 0.35, 0) + d * (dr * cos(PI / 12.0)), d, 0.5, dH * 0.6)
	# apsis pencereleri
	for ad in [140.0, 180.0, 220.0]:
		var a2 := deg_to_rad(ad)
		var d2 := Vector3(sin(a2), 0, cos(a2))
		b.win(Vector3(0, 1.4, -L * 0.5) + d2 * (rc * cos(PI / 9.0)), d2, 0.45, ah - 2.4)
		for s in [-1.0, 1.0]:
			if ad == 180.0:
				b.win(Vector3(s * sx, 1.3, -L * 0.5) + d2 * (rs * cos(PI / 9.0)), d2, 0.4, hb * 0.62 - 2.1)
	b.band_ring(Vector3(0, 0, 0), W * 0.5, L * 0.5, 1.2, 0.16, true)
	b.band_ring(Vector3(0, 0, 0), W * 0.5, L * 0.5, hb - 0.5, 0.16, true)
	b.band_ring(Vector3(0, 0, nz), W * 0.5, nd * 0.5, 0.9, 0.14)
	b.band_ring(Vector3(0, 0, nz), W * 0.5, nd * 0.5, nH - 0.55, 0.14)
	b.ridge(Vector3(0, hb + gr, 0), L + 0.5)
	b.ridge(Vector3(0, hb + gr, 0), W + 0.5, false)
	b.semantron(Vector3(-W * 0.5 + 1.4, nH - 0.4, L * 0.5 + nd), Vector3(0, 0, 1))
	b.lamp(Vector3(1.4, 1.7, L * 0.5 + nd + 0.07), 0.9)
	b.tree_cypress(Vector3(-W * 0.5 - 3.4, 0, nz + 1.5), 6.0)
	b.tree_cypress(Vector3(W * 0.5 + 3.0, 0, nz + 2.0), 5.5)
	b.flush()


## -------------------------------------------------------------------- bazilika
## Üç nefli bazilika: ahşap çatılı yüksek nef, tek eğimli yan nef çatıları, klerestori, apsis, ön revak ve narteks.
## host.set_meta("latin", true) ise güneybatıda çan kulesi (Latin etkili yerlerde).
static func bazilika(b: IstKB) -> void:
	var st := b.stone
	var nv := maxf(b.S(8.0), 3.4)
	var aw := maxf(b.S(4.2), 2.6)
	var L := maxf(b.S(20.0), 12.0)
	var hn := b.Hs(11.0, 6.6)
	var ha := maxf(hn * 0.55, 3.5)
	var W := nv + 0.8 + 2.0 * aw
	var rise := clampf((hn - ha) - 2.4, 0.9, (aw + 0.3) * 0.7)
	var ngr := clampf(b.S(3.6), 1.4, 3.6)
	var ap_r := nv * 0.5 + 0.4
	var nd := 2.8
	var nH := ha
	var pd := 2.6                                   # revak derinliği
	var ph := 3.1                                   # revak damı üst yüzü
	var total_s := L * 0.5 + nd + pd
	b.set_pivot(Vector3(0, 0, -(total_s - (L * 0.5 + ap_r)) * 0.5))
	var ax := nv * 0.5 + 0.4 + aw * 0.5
	if b.lod == 2:
		b.sb(Vector3(0, 0, 0), Vector3(nv + 0.8, hn, L), st)
		b.gable(Vector3(0, hn, 0), nv + 1.6, ngr, L + 0.6, IstKB.TILE, true, "")
		for s in [-1.0, 1.0]:
			b.sb(Vector3(s * ax, 0, 0), Vector3(aw, ha, L), st)
		b.sc(Vector3(0, 0, -L * 0.5), ap_r, hn * 0.8, st, "", 8)
		return
	b.sb(Vector3(0, 0, 0), Vector3(nv + 0.8, hn, L), st, "ashlar")
	b.gable(Vector3(0, hn, 0), nv + 1.6, ngr, L + 0.6, IstKB.TILE_D, true)
	for s in [-1.0, 1.0]:
		b.sb(Vector3(s * ax, 0, 0), Vector3(aw, ha, L), st, "ashlar")
		# tek eğimli çatı: yüksek kenar nef duvarında (merkeze doğru)
		b.wedge(Vector3(s * ax, ha, 0), aw + 0.2, rise, L + 0.4, IstKB.TILE, 180.0 if s > 0.0 else 0.0)
	# apsis
	var ah := hn * 0.8
	b.sc(Vector3(0, 0, -L * 0.5), ap_r, ah, st, "ashlar", 9)
	b.sc(Vector3(0, ah, -L * 0.5), ap_r + 0.12, 1.6, IstKB.TILE, "tiles", 9, 0.05)
	# narteks: bütün genişlik, yan nef yüksekliğinde, düz çatı + kenarlık + güney revak
	var nz := L * 0.5 + nd * 0.5
	b.sb(Vector3(0, 0, nz), Vector3(W, nH - 0.12, nd), st, "ashlar")
	b.sb(Vector3(0, nH - 0.12, nz), Vector3(W + 0.2, 0.12, nd + 0.2), IstKB.TILE, "tiles")
	# revak: sütun sırası + düz dam (ph); sütun aralığı ≥ 1,7 m
	var pz := L * 0.5 + nd + pd * 0.5
	var ncol := maxi(3, int(floor((W - 1.0) / 3.0)) + 1)
	var span := W - 1.4
	for i in ncol:
		var cx := -span * 0.5 + span * float(i) / (ncol - 1)
		b.sc(Vector3(cx, 0, L * 0.5 + nd + pd - 0.5), 0.34, ph - 0.28, IstKB.MARBLE, "marble", 8)
		b.sb(Vector3(cx, 0, L * 0.5 + nd + pd - 0.5), Vector3(0.9, 0.22, 0.9), IstKB.STONE_D)       # kaide
	b.sb(Vector3(0, ph - 0.28, pz), Vector3(W + 0.3, 0.28, pd + 0.2), IstKB.TILE, "tiles")
	# narteks damı: doğu ucundan merdiven
	var runn := b.stair_run(nH)
	var sn := b.stair(Vector3(W * 0.5 + 0.1 + runn, 0, nz), Vector3.LEFT, 1.5, nH, IstKB.STONE_D)
	b.add_climb(sn[0], Vector3(W * 0.5 - 0.8, nH, nz), "basamak")
	# yer → revak damı: batı ucundan merdiven
	var run := b.stair_run(ph)
	var sres := b.stair(Vector3(-W * 0.5 - 0.1 - run, 0, pz), Vector3.RIGHT, 1.5, ph, IstKB.STONE_D)
	b.add_climb(sres[0], Vector3(-W * 0.5 + 0.8, ph, pz), "basamak")
	b.add_perch(Vector3(0, ph, pz))
	b.add_perch(Vector3(0, nH, nz - 0.2))
	# mahya sonu akroter kaidesi (tepe konma noktası)
	var rtop := Vector3(0, hn + ngr, L * 0.5 + 0.2)
	b.sb(rtop - Vector3(0, 0.3, 0), Vector3(0.7, 0.5, 0.7), IstKB.STONE_D)
	b.add_perch(rtop + Vector3(0, 0.2, 0))
	# Latin etkisi: çan kulesi (güneybatı köşe, yan nefin yanında)
	var tw := maxf(b.S(3.6), 3.0)
	var th := b.Hs(16.0, 9.5)
	if b.latin:
		var tx := -W * 0.5 - tw * 0.5 - 0.6
		var tz := L * 0.5 - tw * 0.5
		b.sb(Vector3(tx, 0, tz), Vector3(tw, th, tw), st, "ashlar")
		b.sb(Vector3(tx, th, tz), Vector3(tw + 0.3, 0.3, tw + 0.3), IstKB.STONE_D)
		b.sc(Vector3(tx, th + 0.3, tz), tw * 0.78, 2.6, IstKB.TILE, "tiles", 4, 0.06)
		b.add_perch(Vector3(tx, th + 0.3, tz) + Vector3(tw * 0.5 + 0.1, 0, 0))
		if b.detail():
			for sd in [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
				b.win(Vector3(tx, th - 2.4, tz) + sd * (tw * 0.5), sd, 0.8, 1.7)
			b.band_ring(Vector3(tx, 0, tz), tw * 0.5, tw * 0.5, th * 0.5, 0.16)
	if b.lod == 1:
		return
	# ayrıntılar
	b.door(Vector3(0, 0, L * 0.5 + nd), Vector3(0, 0, 1), 2.0, 2.2)
	b.win(Vector3(-W * 0.31, 1.3, L * 0.5 + nd), Vector3(0, 0, 1), 0.55, 1.1)
	b.win(Vector3(W * 0.31, 1.3, L * 0.5 + nd), Vector3(0, 0, 1), 0.55, 1.1)
	# klerestori: nef duvarında aisle damı üstünde pencere dizisi
	var wy := ha + rise + 0.35
	var wh := minf(hn - wy - 0.5, 1.8)
	if wh > 0.7:
		var nwin := maxi(3, int(floor(L / 2.6)))
		for i in nwin:
			var zz := -L * 0.5 + 2.0 + (L - 4.0) * float(i) / (nwin - 1)
			for s in [-1.0, 1.0]:
				b.win(Vector3(s * (nv * 0.5 + 0.4), wy, zz), Vector3(s, 0, 0), 0.55, wh)
	# yan nef dış duvarlarında pencere
	var ny := maxi(3, int(floor(L / 3.4)))
	for i in ny:
		var z2 := -L * 0.5 + 2.2 + (L - 4.4) * float(i) / (ny - 1)
		for s in [-1.0, 1.0]:
			b.win(Vector3(s * (nv * 0.5 + 0.4 + aw), 1.4, z2), Vector3(s, 0, 0), 0.5, ha - 2.2 if ha > 3.6 else 1.0)
	for ad in [140.0, 180.0, 220.0]:
		var a2 := deg_to_rad(ad)
		var d2 := Vector3(sin(a2), 0, cos(a2))
		b.win(Vector3(0, 1.5, -L * 0.5) + d2 * (ap_r * cos(PI / 9.0)), d2, 0.5, ah - 2.6)
	b.band_ring(Vector3(0, 0, 0), W * 0.5, L * 0.5, 1.1, 0.16, true)
	b.band_ring(Vector3(0, 0, 0), W * 0.5, L * 0.5, ha - 0.5, 0.16, true)
	b.band_ring(Vector3(0, 0, nz), W * 0.5, nd * 0.5, nH - 0.5, 0.14)
	b.ridge(Vector3(0, hn + ngr, 0), L + 0.6)
	b.cross(rtop + Vector3(0, 0.2, 0), 1.0)
	b.semantron(Vector3(W * 0.5 - 1.6, nH - 0.45, L * 0.5 + nd), Vector3(0, 0, 1))
	b.lamp(Vector3(1.7, 1.7, L * 0.5 + nd + 0.07), 0.9)
	b.tree_cypress(Vector3(W * 0.5 + 3.2, 0, L * 0.25), 6.5)
	b.flush()
