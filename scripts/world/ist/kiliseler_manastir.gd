class_name IstKiliseManastir
extends RefCounted
## Manastır külliyesi, ayazma, münzevi kulesi, yol kenarı ikona nişi.
## Eksen: giriş (kapı kulesi) +z, katholikon kuzeyde apsisle -z'ye bakar.


## ------------------------------------------------------------------ manastir
static func manastir(b: IstKB) -> void:
	var st := b.stone
	var E := maxf(b.S(30.0), 17.0)                 # çevre duvarı yarı boyu (eksen ortasından)
	var wt := 1.4                                  # yürüme yolu genişliği
	var par := 0.5                                 # dış korkuluk kalınlığı
	var wh := b.Hs(4.5, 3.6)
	var inner := E - (wt + par) * 0.5              # iç yüz
	var wall_c := E
	if b.lod == 2:
		for sgn in [-1.0, 1.0]:
			b.sb(Vector3(0, 0, sgn * E), Vector3(2.0 * E + 2.0, wh, 1.9), st)
			b.sb(Vector3(sgn * E, 0, 0), Vector3(1.9, wh, 2.0 * E - 1.9), st)
		var ks := b.sub("kilise_kucuk", Vector3(0, 0, -E * 0.18))
		IstKiliseTipleri.kucuk(ks)
		b.adopt(ks, Vector3(0, 0, -E * 0.18))
		b.sb(Vector3(-E * 0.78, 0, 0), Vector3(4.0, 3.2, E), st)
		b.sb(Vector3(E * 0.55, 0, E * 0.15), Vector3(7.0, 4.2, 14.0), st)
		return
	# ---- zemin döşemesi (avlu)
	b.sb(Vector3(0, 0, 0), Vector3(2.0 * inner - 0.4, 0.06, 2.0 * inner - 0.4), IstKB.STONE_D, "flagstone")
	# ---- çevre duvarı: K ve G tam boy, D ve B kısaltılmış (köşe çakışması yok)
	var full := 2.0 * E + wt + par
	var gate_w := 2.9                                 # kapı geçidi genişliği
	var tw := maxf(b.S(7.0), 5.4)                     # kule genişliği
	var td := 5.0                                     # kule derinliği (z)
	var th := wh + maxf(b.S(4.0), 3.0)
	var arch_h := 3.3
	# kuzey duvarı
	b.sb(Vector3(0, 0, -E), Vector3(full, wh, wt + par), st, "ashlar")
	b.sb(Vector3(0, wh, -E - wt * 0.5), Vector3(full, 1.05, par), IstKB.STONE_D, "ashlar")
	# doğu / batı duvarı
	for sgn in [-1.0, 1.0]:
		b.sb(Vector3(sgn * E, 0, 0), Vector3(wt + par, wh, 2.0 * E - (wt + par)), st, "ashlar")
		b.sb(Vector3(sgn * (E + wt * 0.5), wh, 0), Vector3(par, 1.05, 2.0 * E - (wt + par)), IstKB.STONE_D, "ashlar")
	# güney duvarı: kule + iki kanat (geçit boş)
	var wing := (full - tw) * 0.5
	for sgn in [-1.0, 1.0]:
		b.sb(Vector3(sgn * (tw * 0.5 + wing * 0.5), 0, E), Vector3(wing, wh, wt + par), st, "ashlar")
		b.sb(Vector3(sgn * (tw * 0.5 + wing * 0.5), wh, E + wt * 0.5), Vector3(wing, 1.05, par), IstKB.STONE_D, "ashlar")
	# kapı kulesi: iki yan kütle + geçit üstü kemer kütlesi
	var jamb := (tw - gate_w) * 0.5
	for sgn in [-1.0, 1.0]:
		b.sb(Vector3(sgn * (gate_w * 0.5 + jamb * 0.5), 0, E), Vector3(jamb, th, td), st, "ashlar")
	b.sb(Vector3(0, arch_h, E), Vector3(gate_w + 0.02, th - arch_h, td), st, "ashlar")
	# kule çatısı: yürünebilir düz tepe + kenarlık değil; ince kiremit alın
	b.sb(Vector3(0, th, E), Vector3(tw + 0.3, 0.3, td + 0.3), IstKB.TILE, "tiles")
	b.add_perch(Vector3(0, th + 0.3, E))
	# duvar yürüme yolu merdiveni (kuzey duvarına doğru, batı yarıda)
	var run := b.stair_run(wh)
	var nx := -E * 0.4
	var ns := b.stair(Vector3(nx, 0, -E + (wt + par) * 0.5 - 0.1 + run), Vector3(0, 0, -1), 1.5, wh, IstKB.STONE_D)
	b.add_climb(ns[0], Vector3(nx, wh, -E + 0.1), "basamak")
	# güney duvarı yürüme yolu merdiveni (doğu yarıda)
	var ss := b.stair(Vector3(E * 0.45, 0, E - (wt + par) * 0.5 + 0.1 - run), Vector3(0, 0, 1), 1.5, wh, IstKB.STONE_D)
	b.add_climb(ss[0], Vector3(E * 0.45, wh, E - 0.1), "basamak")
	b.add_perch(Vector3(-E + 0.9, wh, -E + 0.9))
	b.add_perch(Vector3(E * 0.45, wh, E))
	# ---- katholikon (kapalı haç kilise) avlunun kuzey-ortasında
	var kz := -E * 0.2
	var ks := b.sub("kilise_kucuk", Vector3(0, 0, kz))
	IstKiliseTipleri.kucuk(ks)
	b.adopt(ks, Vector3(0, 0, kz))
	# ---- hücre sırası (batı): iki sıra, önünde revak
	var cd := maxf(b.S(4.2), 3.6)                      # hücre bloğu derinliği (x)
	var ch := b.Hs(3.4, 3.2)
	var cx0 := -E + (wt + par) * 0.5 + 2.4              # duvar iç yüzünden ≥ 2,4 m boşluk (yaklaşım)
	var clen := minf(E * 1.1, 2.0 * E - 14.0)
	var cz := E * 0.12
	b.sb(Vector3(cx0 + cd * 0.5, 0, cz), Vector3(cd, ch - 0.14, clen), st, "ashlar")
	b.sb(Vector3(cx0 + cd * 0.5, ch - 0.14, cz), Vector3(cd + 0.3, 0.14, clen + 0.3), IstKB.TILE, "tiles")
	# revak: sütun sırası + düz dam
	var rv := 2.0
	var ncol := maxi(3, int(floor(clen / 2.8)) + 1)
	for i in ncol:
		var zz := cz - clen * 0.5 + 0.4 + (clen - 0.8) * float(i) / (ncol - 1)
		b.sb(Vector3(cx0 + cd + rv - 0.35, 0, zz), Vector3(0.55, 2.5, 0.55), st, "ashlar")
	b.sb(Vector3(cx0 + cd + rv * 0.5, 2.5, cz), Vector3(rv + 0.05, 0.25, clen), IstKB.TILE, "tiles")
	# hücre damına merdiven (güney uçtan)
	var cs := b.stair(Vector3(cx0 + cd * 0.5, 0, cz + clen * 0.5 + b.stair_run(ch) + 0.2), Vector3(0, 0, -1), 1.5, ch, IstKB.STONE_D)
	b.add_climb(cs[0], Vector3(cx0 + cd * 0.5, ch, cz + clen * 0.5 - 0.8), "basamak")
	b.add_perch(Vector3(cx0 + cd * 0.5, ch, cz - clen * 0.25))
	# ---- yemekhane (trapeza): doğu tarafta, apsisli uzun yapı
	var rw := maxf(b.S(7.0), 5.4)
	var rl := maxf(b.S(16.0), 10.0)
	var rh := b.Hs(5.0, 3.8)
	var rx := E * 0.5
	var rz := E * 0.16
	b.sb(Vector3(rx, 0, rz), Vector3(rw, rh, rl), st, "ashlar")
	b.gable(Vector3(rx, rh, rz), rw + 0.5, clampf(b.S(2.4), 1.2, 2.4), rl + 0.5, IstKB.TILE, true)
	b.sc(Vector3(rx, 0, rz - rl * 0.5), rw * 0.4, rh * 0.8, st, "ashlar", 9)
	b.sc(Vector3(rx, rh * 0.8, rz - rl * 0.5), rw * 0.4 + 0.1, 1.0, IstKB.TILE, "tiles", 9, 0.05)
	# yemekhane damına dış merdiven: duvar kenarına yaslı yan sundurma (düz basamaklı)
	var rrun := b.stair_run(2.4)
	var rs := b.stair(Vector3(rx + rw * 0.5 + 0.1 + rrun + 0.0, 0, rz + rl * 0.5 - 1.6), Vector3.LEFT, 1.4, 2.4, IstKB.STONE_D)
	b.sb(Vector3(rx + rw * 0.5 - 0.7, 0, rz + rl * 0.5 - 1.6), Vector3(1.4, 2.4, 1.4), IstKB.STONE_D, "ashlar")         # sahanlık
	b.add_climb(rs[0], Vector3(rx + rw * 0.5 - 0.7, 2.4, rz + rl * 0.5 - 1.6), "basamak")
	# ---- phiale (pınar köşkü): meydanın güneyinde
	var px := 0.0
	var pz := E * 0.55
	b.sc(Vector3(px, 0, pz), 1.3, 0.85, IstKB.MARBLE, "marble", 12)                         # havuz (dolu)
	var wmesh := b.sc(Vector3(px, 0.85, pz), 1.05, 0.05, IstKB.WATER, "", 12)
	var pr := 3.2
	for i in 6:
		var a := TAU * i / 6.0 + 0.2
		b.sc(Vector3(px + cos(a) * pr, 0, pz + sin(a) * pr), 0.16, 3.0, IstKB.MARBLE, "marble", 8)
	b.sc(Vector3(px, 3.0, pz), pr + 0.5, 1.1, IstKB.TILE, "tiles", 12, 0.12)
	b.add_perch(Vector3(px, 4.1, pz))
	# ---- bostan yatakları (kuzey duvar dibi), selvi ve zeytin
	for i in 4:
		b.sb(Vector3(-E * 0.3 + i * 3.4, 0, -E + 3.3), Vector3(2.8, 0.3, 1.2), IstKB.SOIL)
	b.tree_cypress(Vector3(E * 0.8, 0, -E * 0.7), 6.5)
	b.tree_cypress(Vector3(E * 0.8, 0, -E * 0.45), 6.0)
	b.tree_cypress(Vector3(-E * 0.8, 0, -E * 0.75), 6.5)
	b.tree_plane(Vector3(-E * 0.3, 0, E * 0.55), 6.0)
	if b.lod == 1:
		return
	# ---- ayrıntılar
	# kapı geçidi kemeri (dış ve iç yüzde), kule penceresi, taş çerçeve
	for zz in [E + td * 0.5 + 0.03, E - td * 0.5 - 0.03]:
		var nrm := Vector3(0, 0, 1.0 if zz > E else -1.0)
		b.vc(Vector3(0, arch_h - 0.05, zz), gate_w * 0.5 + 0.2, 0.06, IstKB.MARBLE, 14, Vector3(90, 0, 0), -1.0, true)
		b.vc(Vector3(0, arch_h - 0.05, zz + nrm.z * 0.03), gate_w * 0.5, 0.06, IstKB.DARK, 14, Vector3(90, 0, 0), -1.0, true)
		b.vb(Vector3(0, 0, zz + nrm.z * 0.015), Vector3(gate_w + 0.4, arch_h - 0.05, 0.03), IstKB.MARBLE, "")
		b.vb(Vector3(0, 0, zz + nrm.z * 0.03), Vector3(gate_w, arch_h - 0.05, 0.03), IstKB.DARK, "")
	for sgn in [-1.0, 1.0]:
		b.win(Vector3(sgn * (gate_w * 0.5 + jamb * 0.5), arch_h + 0.5, E + td * 0.5), Vector3(0, 0, 1), 0.5, 1.2)
		b.win(Vector3(sgn * (gate_w * 0.5 + jamb * 0.5), arch_h + 0.5, E - td * 0.5), Vector3(0, 0, -1), 0.5, 1.2)
		# açık kapı kanatları (geçidin iç yüzüne yaslı, çarpışmasız görsel)
		b.vb(Vector3(sgn * (gate_w * 0.5 - 0.06), 0, E + td * 0.5 - 0.8), Vector3(0.1, 3.0, 1.5), IstKB.WOOD, "wood")
	b.band_ring(Vector3(0, 0, E), tw * 0.5, td * 0.5, th - 0.6, 0.16)
	b.band_ring(Vector3(0, 0, E), tw * 0.5, td * 0.5, arch_h + 0.2, 0.14)
	b.cross(Vector3(0, th + 0.3, E), 1.0)
	b.lamp(Vector3(gate_w * 0.5 + 0.2, 2.4, E + td * 0.5 + 0.07), 0.9)
	# duvar bantları ve payandalar (dışta)
	b.band_ring(Vector3(0, 0, 0), E + 0.7, E + 0.7, wh * 0.5, 0.18, true)
	# hücre cephesi: kapılar ve pencereler (revağın arkasında)
	var ncell := int(floor(clen / 4.0))
	for i in ncell:
		var zz2 := cz - clen * 0.5 + 2.0 + 4.0 * i
		b.vb(Vector3(cx0 + cd + 0.03, 0, zz2 - 0.8), Vector3(0.05, 2.0, 0.9), IstKB.WOOD_D, "wood")
		b.win(Vector3(cx0 + cd, 1.3, zz2 + 0.9), Vector3(1, 0, 0), 0.4, 0.9)
	# yemekhane: pencereler
	for i in 4:
		for s in [-1.0, 1.0]:
			b.win(Vector3(rx + s * rw * 0.5, 1.8, rz - rl * 0.5 + 2.2 + (rl - 4.4) * i / 3.0), Vector3(s, 0, 0), 0.5, minf(rh - 2.7, 1.7))
	b.door(Vector3(rx - rw * 0.5, 0, rz + rl * 0.2), Vector3(-1, 0, 0), 1.3, 2.0)
	b.ridge(Vector3(rx, rh + clampf(b.S(2.4), 1.2, 2.4), rz), rl + 0.5)
	b.band_ring(Vector3(rx, 0, rz), rw * 0.5, rl * 0.5, rh - 0.5, 0.16)
	# kuyu başı vb.: avluda taş ağızlıklı kuyu + gülle yığını yerine küp (testi) dizisi
	b.sc(Vector3(-E * 0.55, 0, E * 0.4), 0.8, 0.9, IstKB.STONE_D, "ashlar", 10)
	b.sc(Vector3(-E * 0.55, 0.9, E * 0.4), 0.6, 0.05, IstKB.DARK, "", 10)
	b.grass_patch(Vector3(E * 0.8, 0, E * 0.5), 3.0, 2.0)
	b.grass_patch(Vector3(-E * 0.75, 0, -E * 0.3), 2.0, 2.6)
	b.flush()


## -------------------------------------------------------------------- ayazma
## Kubbeli küçük ayazma: üç yanı duvar, güneye açık; içinde mermer pınar ve niş; dam yürünebilir, merdivenle çıkılır.
static func ayazma(b: IstKB) -> void:
	var st := b.stone
	var w := maxf(b.S(5.0), 4.2)
	var l := maxf(b.S(5.2), 4.4)
	var h := b.Hs(3.8, 3.5)
	var wt := 0.9
	b.set_pivot(Vector3(0, 0, 0))
	if b.lod == 2:
		b.sb(Vector3(0, 0, 0), Vector3(w, h, l), st)
		b.dome(Vector3(0, h, 0), w * 0.3, w * 0.22, 8, 0.9)
		return
	# zemin + üç duvar
	b.sb(Vector3(0, 0, 0), Vector3(w - 0.4, 0.1, l - 0.4), IstKB.STONE_D, "flagstone")
	b.sb(Vector3(0, 0, -l * 0.5 + wt * 0.5), Vector3(w, h - 0.2, wt), st, "ashlar")                   # arka
	for s in [-1.0, 1.0]:
		b.sb(Vector3(s * (w * 0.5 - wt * 0.5), 0, 0), Vector3(wt, h - 0.2, l), st, "ashlar")          # yan
	# dam: düz yürünebilir levha, kenarlık, ortada kasnak ve küçük kubbe
	b.sb(Vector3(0, h - 0.2, 0), Vector3(w + 0.3, 0.2, l + 0.3), IstKB.TILE, "tiles")
	var kerb := 0.35
	b.sb(Vector3(0, h, l * 0.5 + 0.05), Vector3(w + 0.3, kerb, 0.2), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(0, h, -l * 0.5 - 0.05), Vector3(w + 0.3, kerb, 0.2), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(w * 0.5 + 0.05, h, 0), Vector3(0.2, kerb, l + 0.3), IstKB.STONE_D, "ashlar")
	var dr := minf(w, l) * 0.27
	var dH := 1.1
	b.sc(Vector3(0, h, -0.4), dr, dH, st, "ashlar", 8)
	var apex := b.dome(Vector3(0, h + dH, -0.4), dr * 1.08, dr * 0.7, 8, 1.0)
	b.add_perch(apex + Vector3(0.15, 0, 0))
	b.add_perch(Vector3(0, h, l * 0.3))
	# pınar kovuğu: arka duvarda mermer niş + oluk + havuz (dolu mermer blok: içine düşülmez)
	b.sb(Vector3(0, 0.1, -l * 0.5 + wt + 0.55), Vector3(1.6, 0.7, 1.0), IstKB.MARBLE, "marble")
	b.sb(Vector3(0, 0.8, -l * 0.5 + wt + 0.55), Vector3(1.3, 0.05, 0.7), IstKB.WATER)
	# batı merdiveni (dama)
	var run := b.stair_run(h)
	var sres := b.stair(Vector3(-w * 0.5 - 0.2 - run, 0, 0.6), Vector3.RIGHT, 1.5, h, IstKB.STONE_D)
	b.add_climb(sres[0], Vector3(-w * 0.5 + 0.9, h, 0.6), "basamak")
	# dışarıda hayvan suluğu (taş yalak, dolu)
	b.sb(Vector3(w * 0.5 + 2.0, 0, l * 0.5 + 1.0), Vector3(1.8, 0.65, 0.7), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(w * 0.5 + 2.0, 0.65, l * 0.5 + 1.0), Vector3(1.5, 0.04, 0.45), IstKB.WATER)
	b.tree_plane(Vector3(w * 0.5 + 4.2, 0, -1.0), 7.0)
	if b.lod == 1:
		return
	# ön yüz: kemerli açıklık çerçevesi (taş sövenin iki yanı), pınar nişi, ikona, kandil
	for s in [-1.0, 1.0]:
		b.vb(Vector3(s * (w * 0.5 - wt - 0.1), 0, l * 0.5 + 0.03), Vector3(0.35, h - 0.2, 0.06), IstKB.MARBLE, "marble")
	b.vb(Vector3(0, h - 0.8, l * 0.5 + 0.03), Vector3(w - 2.0 * wt, 0.5, 0.06), IstKB.MARBLE, "marble")
	b.vc(Vector3(0, 2.3, -l * 0.5 + wt + 0.04), 0.7, 0.06, IstKB.DARK, 12, Vector3(90, 0, 0), -1.0, true)
	b.vc(Vector3(0, 2.3, -l * 0.5 + wt + 0.06), 0.75, 0.04, IstKB.MARBLE, 12, Vector3(90, 0, 0), -1.0, true)
	b.vb(Vector3(0, 0.0, -l * 0.5 + wt + 0.04), Vector3(1.4, 2.3, 0.05), IstKB.DARK)
	b.vb(Vector3(0, 1.1, -l * 0.5 + wt + 0.08), Vector3(0.7, 1.0, 0.04), Color("5f3a22"))              # ikona tahtası
	b.vc(Vector3(0, 1.9, -l * 0.5 + wt + 0.1), 0.22, 0.03, IstKB.GOLD, 10, Vector3(90, 0, 0), -1.0, true) # hale
	b.vb(Vector3(0, 0.95, -l * 0.5 + wt + 0.12), Vector3(0.06, 0.3, 0.05), IstKB.GOLD)
	b.lamp(Vector3(-0.8, 1.2, -l * 0.5 + wt + 0.35), 0.9)
	b.lamp(Vector3(0.8, 1.2, -l * 0.5 + wt + 0.35), 0.9)
	b.win(Vector3(0, 2.2, 0.0) + Vector3(w * 0.5, 0, 0), Vector3(1, 0, 0), 0.5, 1.0)
	b.band_ring(Vector3(0, 0, 0), w * 0.5, l * 0.5, h - 0.7, 0.16, true)
	# dama haç ve çarşaf (adak bezleri) ağacı: çınarın dallarına bağlı kırmızı-beyaz şeritler
	for i in 7:
		var col := Color("c0392b") if i % 2 == 0 else Color("f0e6d2")
		b.vb(Vector3(w * 0.5 + 3.4 + (i % 3) * 0.5, 2.0 + (i % 4) * 0.35, -1.0 + (i % 5) * 0.4), Vector3(0.05, 0.4, 0.14), col)
	b.grass_patch(Vector3(w * 0.5 + 3.0, 0, 1.6), 2.0, 1.6)
	b.flush()


## ---------------------------------------------------------- münzevi kulesi
## Dört köşe taş kule: dar mazgal pencereler, tepede çıkma platform ve ahşap kulübe, makara; yer → orta sahanlık merdiven-
## payanda kütlesiyle çıkılır (kulenin tepesi çıkılmaz, Nihat konar).
static func kule(b: IstKB) -> void:
	var st := b.stone
	var tw := maxf(b.S(5.0), 3.6)
	var th := b.Hs(14.0, 9.0)
	var hb := minf(maxf(b.S(8.0), 4.4), 7.0)             # orta sahanlık yüksekliği
	var plat := tw + 1.2
	var hut := tw * 0.55
	b.set_pivot(Vector3(0, 0, 0))
	if b.lod == 2:
		b.sb(Vector3(0, 0, 0), Vector3(tw, th, tw), st)
		b.sb(Vector3(0, th, 0), Vector3(plat, 0.4, plat), IstKB.WOOD)
		b.sb(Vector3(0, th + 0.4, 0), Vector3(hut, 2.0, hut), IstKB.WOOD)
		return
	b.sb(Vector3(0, 0, 0), Vector3(tw, th, tw), st, "ashlar")
	# çıkma platform (tepede) ve ahşap kulübe
	b.sb(Vector3(0, th, 0), Vector3(plat, 0.4, plat), IstKB.WOOD, "wood")
	b.sb(Vector3(0, th + 0.4, 0), Vector3(hut, 2.2, hut), IstKB.WOOD_D, "wood")
	b.gable(Vector3(0, th + 2.6, 0), hut + 0.5, 0.9, hut + 0.5, IstKB.TILE_D, true)
	b.add_perch(Vector3(plat * 0.5 - 0.35, th + 0.4, plat * 0.5 - 0.35))
	b.add_perch(Vector3(0, th + 3.5 + 0.0, 0))
	# payanda kütlesi: güney yüzde, batı ucunda; üstü sahanlık (balkon)
	var bw := 1.8
	var bl := 3.6
	var bx := -tw * 0.5 + bl * 0.5
	var bz := tw * 0.5 + bw * 0.5
	b.sb(Vector3(bx, 0, bz), Vector3(bl, hb, bw), st, "ashlar")
	# merdiven: doğudan batıya, kulenin güney yüzü boyunca; son basamak payanda tepesiyle birleşir
	var run := b.stair_run(hb)
	var sx0 := bx + bl * 0.5 + run
	var sres := b.stair(Vector3(sx0, 0, bz), Vector3.LEFT, bw, hb, IstKB.STONE_D)
	b.add_climb(sres[0], Vector3(bx + 0.2, hb, bz), "basamak")
	b.add_perch(Vector3(bx, hb, bz))
	# sahanlık kenarlığı
	b.sb(Vector3(bx, hb, bz + bw * 0.5 - 0.1), Vector3(bl, 0.35, 0.2), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(bx - bl * 0.5 + 0.1, hb, bz), Vector3(0.2, 0.35, bw), IstKB.STONE_D, "ashlar")
	if b.lod == 1:
		return
	# mazgal pencereler (dar yarıklar), tuğla bantlar, kulübe penceresi
	for i in 4:
		var yy := 2.0 + (th - 5.0) * i / 3.0
		for sd in [Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
			b.win(Vector3(0, yy, 0) + sd * (tw * 0.5), sd, 0.28, 0.9, false)
		if yy > hb + 0.5:
			b.win(Vector3(0, yy, 0) + Vector3(0, 0, 1) * (tw * 0.5), Vector3(0, 0, 1), 0.28, 0.9, false)
	for sd in [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
		b.win(Vector3(0, th + 0.9, 0) + sd * (hut * 0.5), sd, 0.45, 0.7)
	b.band_ring(Vector3(0, 0, 0), tw * 0.5, tw * 0.5, th * 0.35, 0.16)
	b.band_ring(Vector3(0, 0, 0), tw * 0.5, tw * 0.5, th * 0.7, 0.16)
	b.band_ring(Vector3(0, 0, 0), tw * 0.5, tw * 0.5, th - 0.6, 0.16)
	# payanda kütlesinde kemerli kör nişler (süs)
	for i in 3:
		b.win(Vector3(bx - bl * 0.5 + 0.7 + i * 1.2, 0.0, bz + bw * 0.5), Vector3(0, 0, 1), 0.6, minf(hb - 1.2, 2.2))
	# makara kirişi ve sepet (tepe, doğu yüz)
	b.vb(Vector3(plat * 0.5 + 0.6, th + 1.4, 0.0), Vector3(1.8, 0.14, 0.14), IstKB.WOOD_D, "", Vector3.ZERO, true)
	b.vb(Vector3(plat * 0.5 + 1.4, th + 0.7, 0.0), Vector3(0.04, 1.4, 0.04), IstKB.WOOD, "", Vector3.ZERO, true)       # ip
	b.vc(Vector3(plat * 0.5 + 1.4, th - 0.2, 0.0), 0.32, 0.38, IstKB.WOOD, 8, Vector3.ZERO, 0.24, true)               # sepet
	b.cross(Vector3(0, th + 3.5, 0), 0.9)
	# kayalık taban: kulenin dibinde taş toprak yığınları, otlar
	b.rubble_heap(Vector3(-tw * 0.5 - 1.6, 0, -tw * 0.4), 1.4, 0.8, IstKB.STONE_D)
	b.grass_patch(Vector3(tw * 0.5 + 2.0, 0, -1.5), 1.8, 1.4)
	b.tree_cypress(Vector3(tw * 0.5 + 4.0, 0, tw * 0.5 + 3.0), 5.0)
	b.flush()


## ---------------------------------------------------------------- ikona nişi
## Yol kenarı proskynetarion: üç basamaklı kaide üstünde taş direk, içinde ikona nişi, beşik çatı, kandil.
## İnsan ölçüsünde (k'den bağımsız).
static func nisi(b: IstKB) -> void:
	var st := b.stone
	b.set_pivot(Vector3(0, 0, 0))
	# kaide: iki basamak (0,4 m), üstü 0,8 m platform
	b.sb(Vector3(0, 0, 0), Vector3(2.8, 0.4, 2.2), IstKB.STONE_D, "ashlar")
	b.sb(Vector3(0, 0.4, -0.15), Vector3(2.4, 0.4, 1.8), IstKB.STONE_D, "ashlar")
	# direk
	b.sb(Vector3(0, 0.8, -0.35), Vector3(1.0, 1.4, 0.8), st, "ashlar")
	b.gable(Vector3(0, 2.2, -0.35), 1.3, 0.5, 1.1, IstKB.TILE, true)
	b.add_climb(Vector3(0, 0, 2.2), Vector3(0, 0.8, 0.5), "basamak")
	b.add_perch(Vector3(0.7, 0.8, 0.3))
	b.sb(Vector3(0, 2.6, -0.35), Vector3(0.3, 0.3, 0.3), IstKB.STONE_D)
	b.add_perch(Vector3(0, 2.9, -0.35))
	if b.lod == 2:
		return
	if b.lod == 0:
		# niş: ön yüze 3 cm yapışık karanlık oyuk ve ikona
		b.vb(Vector3(0, 1.05, 0.06), Vector3(0.62, 0.95, 0.04), IstKB.DARK)
		b.vc(Vector3(0, 2.0, 0.065), 0.31, 0.04, IstKB.DARK, 10, Vector3(90, 0, 0), -1.0, true)
		b.vb(Vector3(0, 1.12, 0.1), Vector3(0.46, 0.7, 0.03), Color("6b4326"))
		b.vc(Vector3(0, 1.56, 0.12), 0.18, 0.03, IstKB.GOLD, 10, Vector3(90, 0, 0), -1.0, true)
		b.vb(Vector3(0, 1.24, 0.13), Vector3(0.18, 0.28, 0.02), Color("a33b2a"))
		b.vb(Vector3(0, 0.82, 0.07), Vector3(0.8, 0.08, 0.14), IstKB.MARBLE)                              # adak rafı
		b.vb(Vector3(0, 2.62, 0.0), Vector3(0.06, 0.5, 0.06), IstKB.GOLD)
		b.vb(Vector3(0, 2.8, 0.0), Vector3(0.3, 0.06, 0.06), IstKB.GOLD)
		b.lamp(Vector3(0.32, 0.9, 0.17), 0.7)
		b.vc(Vector3(-0.9, 0.8, 0.5), 0.12, 0.22, IstKB.TILE_D, 8, Vector3.ZERO, 0.08)                   # adak küpü
	b.flush()
