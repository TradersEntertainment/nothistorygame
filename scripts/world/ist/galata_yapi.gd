class_name IstGalataYapi
extends RefCounted
## Galata yapıları: kiliseler, Palazzo del Comune, loca, ev, rıhtım, ambar, tersane, bağ, mezarlık.
const O := preload("res://scripts/world/ist/galata_ortak.gd")


static func build(id: String, h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	match id:
		"san_domenico": _church(h, k, lod, out, {"w": 16.0, "l": 32.0, "eave": 12.0, "tower": "spire", "tw": 6.0, "th": 26.0, "plaster": O.STONE, "roof": O.TILE})
		"san_francesco": _church(h, k, lod, out, {"w": 12.0, "l": 24.0, "eave": 9.0, "tower": "spire", "tw": 4.5, "th": 18.0, "plaster": O.PLASTER2, "roof": O.TILE_D})
		"san_michele": _church(h, k, lod, out, {"w": 10.0, "l": 20.0, "eave": 8.0, "tower": "bellgable", "tw": 0.0, "th": 0.0, "plaster": O.PLASTER, "roof": O.TILE})
		"san_benedetto": _church(h, k, lod, out, {"w": 9.0, "l": 18.0, "eave": 8.0, "tower": "square", "side": 1.0, "tw": 4.0, "th": 14.0, "plaster": O.STONE, "roof": O.TILE_D})
		"palazzo_comune": _palazzo(h, k, lod, out)
		"galata_loca": _loca(h, k, lod, out)
		"ceneviz_evi": _ev(h, k, lod, out)
		"galata_rihtim": _rihtim(h, k, lod, out)
		"galata_ambar": _ambar(h, k, lod, out)
		"galata_tersane": _tersane(h, k, lod, out)
		"galata_bag": _bag(h, k, lod, out)
		"galata_mezarlik": _mezarlik(h, k, lod, out)


# ------------------------------------------------------------------ kilise
static func _church(h: Node3D, k: float, lod: int, out: Dictionary, p: Dictionary) -> void:
	var W := maxf(p["w"] * k, 5.6)
	var L := maxf(p["l"] * k, 10.0)
	var E := maxf(p["eave"] * k, 5.0)
	var rise := W * 0.34
	var wc: Color = p["plaster"]
	var kind: String = p["tower"]
	var tw := maxf(p["tw"] * k, 3.4) if kind != "bellgable" else 0.0
	var th := maxf(p["th"] * k, E + 3.0) if kind != "bellgable" else 0.0
	var side: float = p.get("side", -1.0)
	var tx := side * (W * 0.5 + tw * 0.5 - 0.6) if tw > 0.0 else 0.0
	var tz := L * 0.5 - tw * 0.5
	var tall := th
	var spire_h := tw * (1.7 if kind == "spire" else 0.8)
	# merdiven: doğu yan duvar boyunca eğik saçağa
	var sn := ceili(E / 0.3)
	var sx := W * 0.5 + 0.75
	var sz0 := L * 0.5 - 2.0 if side < 0.0 or tw == 0.0 else L * 0.5 - tw - 0.8
	out["climbs"].append([Vector3(sx, 0, sz0 + 0.5), Vector3(sx, E, sz0 - (sn - 0.5) * 0.36), "basamak"])
	if kind == "spire":
		out["perches"].append(Vector3(tx, th + spire_h + 0.25, tz))
	elif kind == "square":
		out["perches"].append(Vector3(tx, th + spire_h * 0.6 + 0.25, tz))
	out["perches"].append(Vector3(0, E + rise + 0.32, -L * 0.2))
	if lod >= 3:
		return
	if lod == 1 or lod == 2:
		O.sol(h, Vector3(W, E, L), Vector3.ZERO, wc)
		O.vis(h, Vector3(W + 0.6, rise, L + 0.6), Vector3(0, E, 0), p["roof"])
		if tw > 0.0:
			O.sol(h, Vector3(tw, th, tw), Vector3(tx, 0, tz), wc)
			O.cyl(h, tw * 0.72, spire_h, Vector3(tx, th, tz), p["roof"], "", 4, 0.1, false, 45.0)
		return
	# gövde
	O.sol(h, Vector3(W, E, L), Vector3.ZERO, wc, "plaster" if wc != O.STONE else "ashlar")
	O.vis(h, Vector3(W + 0.3, 0.5, L + 0.3), Vector3(0, 0, 0), O.STONE_D, "ashlar")
	O.vis(h, Vector3(W + 0.2, 0.3, L + 0.2), Vector3(0, E - 0.3, 0), O.LIGHT, "ashlar")
	O.gable(h, W, L, Vector3(0, E, 0), rise, p["roof"], false, 0.5, wc)
	O.sol(h, Vector3(0.4, 0.3, L), Vector3(0, E + rise, 0), O.TILE_D)
	# apsis: yarım silindir (çokgen), konik çatı
	var ar := W * 0.5
	O.cyl(h, ar, E, Vector3(0, 0, -L * 0.5), wc, "ashlar", 10)
	O.cyl(h, ar + 0.4, rise * 0.9, Vector3(0, E, -L * 0.5), p["roof"], "tiles", 10, 0.3)
	# alın: sivri portal, gül pencere, kapı
	var fz := L * 0.5
	O.vis(h, Vector3(2.8, 3.4, 0.4), Vector3(0, 0, fz), O.LIGHT, "ashlar")
	O.vis(h, Vector3(1.6, 2.4, 0.3), Vector3(0, 0, fz + 0.2), O.WOOD_D, "wood")
	Props.set_pattern(Props.prism(h, Vector3(2.8, 1.6, 0.4), Vector3(0, 3.4 + 0.8, fz + 0.0), O.LIGHT), O.LIGHT, "ashlar")
	Props.set_pattern(Props.prism(h, Vector3(1.6, 0.9, 0.3), Vector3(0, 2.4 + 0.45, fz + 0.2), O.WOOD_D), O.WOOD_D, "wood")
	for st in 2:
		O.sol(h, Vector3(3.2, 0.2 * (st + 1), 0.45), Vector3(0, 0, fz + 0.4 + st * 0.45), O.STONE_D, "ashlar")
	var rr := clampf(W * 0.14, 0.8, 1.6)
	var ry := E + rise * 0.38
	Props.cyl(h, rr, 0.14, Vector3(0, ry, fz + 0.1), O.DARK, Vector3(90, 0, 0), 14)
	Props.ring(h, rr - 0.1, rr + 0.18, Vector3(0, ry, fz + 0.15), O.LIGHT, Vector3(90, 0, 0))
	for sdx: float in [-1.0, 1.0]:
		O.lancet(h, Vector3(sdx * (W * 0.5 - 1.3), 2.2, fz), 0.0, 0.6, 1.9)
	# yan duvarlar: payandalar (batı), sivri pencereler (iki yan)
	var nb := maxi(2, int((L - 3.0) / 4.5))
	for i in nb:
		var z := -L * 0.5 + 2.0 + (i + 0.5) * (L - 4.0) / nb
		O.sol(h, Vector3(0.7, E * 0.85, 0.9), Vector3(-W * 0.5 - 0.35, 0, z), wc, "ashlar")
		O.vis(h, Vector3(0.9, 0.5, 1.1), Vector3(-W * 0.5 - 0.35, E * 0.85, z), O.LIGHT, "ashlar")
		O.lancet(h, Vector3(-W * 0.5 - 0.02, 2.4, z + (L - 4.0) / nb * 0.5), -90.0, 0.7, 2.2)
		if i < nb - 1 or true:
			O.lancet(h, Vector3(W * 0.5 + 0.02, 2.4, z + (L - 4.0) / nb * 0.5), 90.0, 0.7, 2.2)
	# kule
	if kind == "spire" or kind == "square":
		O.sol(h, Vector3(tw, th, tw), Vector3(tx, 0, tz), wc, "ashlar")
		O.vis(h, Vector3(tw + 0.3, 0.4, tw + 0.3), Vector3(tx, th - 2.6, tz), O.LIGHT, "ashlar")
		O.vis(h, Vector3(tw + 0.3, 0.4, tw + 0.3), Vector3(tx, th * 0.4, tz), O.LIGHT, "ashlar")
		var bells: Array = []
		for j in 4:
			var a := TAU * j / 4.0
			bells.append(O.xf(a, tw * 0.5 + 0.04, th - 1.5) * Transform3D(Basis(), Vector3.ZERO))
			bells[bells.size() - 1].origin += Vector3(tx, 0, tz)
		O.mm(h, Vector3(0.8, 1.7, 0.2), bells, O.DARK)
		var bt: Array = []
		for j in 4:
			bt.append(O.xf(TAU * j / 4.0, tw * 0.5 + 0.04, th - 0.55))
			bt[bt.size() - 1].origin += Vector3(tx, 0, tz)
		O.mm(h, Vector3(0.8, 0.5, 0.2), bt, O.DARK)
		# kule çanı (görünür çan) ve saçak
		Props.cyl(h, 0.35, 0.6, Vector3(tx, th - 1.6, tz), Color("8a6a3a"), Vector3.ZERO, 8, 0.15)
		O.sol(h, Vector3(tw + 0.5, 0.35, tw + 0.5), Vector3(tx, th, tz), O.LIGHT, "ashlar")
		O.cyl(h, tw * 0.5 * 1.41 + 0.2, spire_h, Vector3(tx, th + 0.35, tz), p["roof"], "tiles", 4, 0.12, true, 45.0)
		O.cyl(h, 0.4, 0.3, Vector3(tx, th + spire_h + 0.1, tz), O.STONE_D, "", 6)
		Props.box(h, Vector3(0.08, 1.0, 0.08), Vector3(tx, th + spire_h + 0.85, tz), Color("d8b040"))
		Props.box(h, Vector3(0.5, 0.08, 0.08), Vector3(tx, th + spire_h + 1.05, tz), Color("d8b040"))
		for j in 4:
			O.lancet(h, Vector3(tx + (tw * 0.5 + 0.03) * [0, 1, 0, -1][j], 2.5, tz + (tw * 0.5 + 0.03) * [1, 0, -1, 0][j]), [0.0, 90.0, 180.0, 270.0][j], 0.5, 1.8)
	else:
		# çan çatısı (campanile a vela): alın duvarında iki gözlü çan alınlığı
		O.sol(h, Vector3(W * 0.55, 2.2, 0.6), Vector3(0, E + rise - 0.6, fz - 0.5), wc, "ashlar")
		Props.prism(h, Vector3(W * 0.55, 1.0, 0.6), Vector3(0, E + rise + 2.1, fz - 0.5), p["roof"])
		for sdx: float in [-1.0, 1.0]:
			Props.box(h, Vector3(0.5, 1.1, 0.7), Vector3(sdx * W * 0.12, E + rise + 0.0, fz - 0.5), O.DARK)
		Props.cyl(h, 0.25, 0.4, Vector3(-W * 0.12, E + rise - 0.2, fz - 0.5), Color("8a6a3a"), Vector3.ZERO, 8, 0.12)
	# merdiven ve dış tırmanış
	O.stair(h, Vector3(sx, 0, sz0 + 0.0 + 0.0), Vector3(0, 0, -1), E, 1.5, O.STONE_D, "ashlar")
	O.cargo(h, Vector3(sx + 1.8, 0, sz0 + 1.2), 3)
	# bahçe duvarı ve mum
	Flame.add(h, Vector3(-1.5, 1.8, fz + 0.6), 0.25, 0.4)
	Flame.add(h, Vector3(1.5, 1.8, fz + 0.6), 0.25, 0.4)


# ------------------------------------------------------------------ Palazzo del Comune
static func _palazzo(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var W := maxf(26.0 * k, 14.0)
	var D := maxf(16.0 * k, 9.0)
	var H := maxf(14.0 * k, 7.0)
	var sn := ceili(H / 0.3)
	var sx := W * 0.5 + 0.75
	var sz0 := D * 0.5 - 1.0
	out["climbs"].append([Vector3(sx, 0, sz0 + 0.5), Vector3(sx, H, sz0 - (sn - 0.5) * 0.36), "basamak"])
	out["perches"].append(Vector3(W * 0.5 - 0.25, H + 1.15, D * 0.5 - 0.25))
	out["perches"].append(Vector3(-W * 0.3, H + 5.6, -D * 0.2 + 0.0))
	if lod >= 3:
		return
	if lod == 1 or lod == 2:
		O.sol(h, Vector3(W, H, D), Vector3.ZERO, O.STONE)
		O.sol(h, Vector3(2.6, 5.0, 2.6), Vector3(-W * 0.3, H, -D * 0.2), O.STONE_D)
		return
	O.sol(h, Vector3(W, H, D), Vector3.ZERO, O.STONE, "ashlar")
	O.vis(h, Vector3(W + 0.4, 0.5, D + 0.4), Vector3(0, 0, 0), O.STONE_D, "ashlar")
	# kat kornişleri
	O.vis(h, Vector3(W + 0.3, 0.35, D + 0.3), Vector3(0, H * 0.4, 0), O.LIGHT, "ashlar")
	O.vis(h, Vector3(W + 0.3, 0.35, D + 0.3), Vector3(0, H * 0.78, 0), O.LIGHT, "ashlar")
	O.vis(h, Vector3(W + 0.5, 0.6, D + 0.5), Vector3(0, H - 0.6, 0), O.LIGHT, "ashlar")
	# teras: katı korkuluk (4 kenar) + mazgal
	var py := H
	O.sol(h, Vector3(W, 1.1, 0.5), Vector3(0, py, -D * 0.5 + 0.25), O.STONE, "ashlar")
	O.sol(h, Vector3(W, 1.1, 0.5), Vector3(0, py, D * 0.5 - 0.25), O.STONE, "ashlar")
	O.sol(h, Vector3(0.5, 1.1, D - 1.0), Vector3(-W * 0.5 + 0.25, py, 0), O.STONE, "ashlar")
	O.sol(h, Vector3(0.5, 1.1, D - 1.0), Vector3(W * 0.5 - 0.25, py, 0), O.STONE, "ashlar")
	O.merlons_rect(h, W - 0.5, D - 0.5, py + 1.1, O.STONE)
	# giriş: üç sivri kemer (koyu) ve yan kemerlerin üstünde arma
	for i in 3:
		var x := (i - 1) * W / 3.0
		Props.box(h, Vector3(2.4, 2.6, 0.3), Vector3(x, 1.3, D * 0.5 + 0.02), O.DARK)
		Props.prism(h, Vector3(2.4, 1.0, 0.3), Vector3(x, 2.6 + 0.5, D * 0.5 + 0.02), O.DARK)
		if i != 1:
			Props.box(h, Vector3(0.9, 1.0, 0.12), Vector3(x, 4.5, D * 0.5 + 0.07), O.WHITE)
			Props.box(h, Vector3(0.14, 1.0, 0.14), Vector3(x, 4.5, D * 0.5 + 0.13), O.RED)
			Props.box(h, Vector3(0.9, 0.14, 0.14), Vector3(x, 4.5, D * 0.5 + 0.13), O.RED)
	# giriş kapısı (orta)
	O.vis(h, Vector3(1.6, 2.4, 0.3), Vector3(0, 0, D * 0.5 + 0.17), O.WOOD_D, "wood")
	for st in 3:
		O.sol(h, Vector3(5.0, 0.2 * (st + 1), 0.5), Vector3(0, 0, D * 0.5 + 0.4 + st * 0.5), O.STONE_D, "ashlar")
	# üst kat: çift gözlü sivri pencereler, balkon
	var nw := maxi(4, int(W / 3.4))
	for i in nw:
		var x := -W * 0.5 + (i + 0.5) * W / nw
		O.lancet(h, Vector3(x, H * 0.4 + 1.1, D * 0.5 + 0.02), 0.0, 0.7, 1.6)
		O.lancet(h, Vector3(x, H * 0.4 + 1.1, -D * 0.5 - 0.02), 180.0, 0.7, 1.6)
		if H > 9.0:
			O.lancet(h, Vector3(x, H * 0.78 + 1.2, D * 0.5 + 0.02), 0.0, 0.6, 1.4)
	O.sol(h, Vector3(3.2, 0.3, 1.4), Vector3(0, 3.9, D * 0.5 + 0.7), O.WOOD, "wood")
	O.vis(h, Vector3(3.2, 1.0, 0.1), Vector3(0, 4.2, D * 0.5 + 1.35), O.WOOD_D, "wood")
	# çatıda çan kulesi (katı), küçük külah
	O.sol(h, Vector3(2.6, 3.4, 2.6), Vector3(-W * 0.3, H, -D * 0.2), O.STONE, "ashlar")
	O.cyl(h, 2.1, 1.8, Vector3(-W * 0.3, H + 3.4, -D * 0.2), O.TILE_D, "tiles", 4, 0.1, true, 45.0)
	O.sol(h, Vector3(0.7, 0.3, 0.7), Vector3(-W * 0.3, H + 5.2, -D * 0.2), O.STONE_D)
	Props.box(h, Vector3(0.9, 1.1, 0.2), Vector3(-W * 0.3, H + 2.2, -D * 0.2 + 1.32), O.DARK)
	O.flag(h, Vector3(W * 0.5 - 1.2, H, -D * 0.5 + 1.0), 5.0, 2.2, 1.4)
	O.flag(h, Vector3(-W * 0.5 + 1.2, H, D * 0.5 - 1.0), 5.0, 2.2, 1.4)
	O.stair(h, Vector3(sx, 0, sz0), Vector3(0, 0, -1), H, 1.5, O.STONE_D, "ashlar")
	O.cargo(h, Vector3(sx + 2.0, 0, sz0 + 1.5), 9)
	Flame.add(h, Vector3(-2.6, 3.2, D * 0.5 + 0.5), 0.3, 0.5)
	Flame.add(h, Vector3(2.6, 3.2, D * 0.5 + 0.5), 0.3, 0.5)


# ------------------------------------------------------------------ loca (açık revak)
static func _loca(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var W := maxf(18.0 * k, 11.0)
	var D := maxf(11.0 * k, 7.0)
	var bays := maxi(4, roundi(W / 2.6))
	var sp := W / bays
	var colh := 3.4
	var top := colh + 0.5
	var sn := ceili(top / 0.3)
	var sx := W * 0.5 + 0.75
	var sz0 := -D * 0.5 + 1.0 + sn * 0.36
	out["climbs"].append([Vector3(sx, 0, sz0 + 0.5), Vector3(sx, top, sz0 - (sn - 0.5) * 0.36), "basamak"])
	out["perches"].append(Vector3(0, top + 1.15, D * 0.5 - 0.25))
	if lod >= 3:
		return
	var fz := D * 0.5
	O.sol(h, Vector3(W, 0.35, D), Vector3.ZERO, O.STONE_D, "flagstone")
	if lod == 1 or lod == 2:
		O.sol(h, Vector3(W, top, 0.8), Vector3(0, 0, -D * 0.5 + 0.4), O.STONE)
		O.sol(h, Vector3(W, 0.6, D), Vector3(0, colh, 0), O.STONE)
		return
	# arka duvar ve yan duvarlar
	O.sol(h, Vector3(W, colh, 0.8), Vector3(0, 0.35, -D * 0.5 + 0.4), O.PLASTER2, "plaster")
	O.sol(h, Vector3(0.8, colh, D - 0.8), Vector3(-W * 0.5 + 0.4, 0.35, 0.4), O.PLASTER2, "plaster")
	O.sol(h, Vector3(0.8, colh, D - 0.8), Vector3(W * 0.5 - 0.4, 0.35, 0.4), O.PLASTER2, "plaster")
	# sütunlar (ön sıra) ve ara sıra; kemer ayakları arasından ≥1,4 m geçit
	for r in 2:
		var z := fz - 0.5 - r * (D * 0.5 - 0.5)
		for i in range(1, bays):
			var x := -W * 0.5 + i * sp
			O.cyl(h, 0.32, colh, Vector3(x, 0.35, z), O.PLASTER3, "marble", 10)
			O.vis(h, Vector3(0.9, 0.3, 0.9), Vector3(x, 0.35 + colh - 0.3, z), O.LIGHT, "ashlar")
	# kirişler ve düz katı teras
	O.sol(h, Vector3(W, top - colh - 0.35 + 0.35, D), Vector3(0, colh + 0.35 - 0.35, 0), O.STONE, "ashlar")
	# teras korkuluğu (dört kenar, merdiven yanı açık)
	O.sol(h, Vector3(W, 1.1, 0.5), Vector3(0, top, fz - 0.25), O.STONE, "ashlar")
	O.sol(h, Vector3(W, 1.1, 0.5), Vector3(0, top, -fz + 0.25), O.STONE, "ashlar")
	O.sol(h, Vector3(0.5, 1.1, D - 1.0), Vector3(-W * 0.5 + 0.25, top, 0), O.STONE, "ashlar")
	O.sol(h, Vector3(0.5, 0.35, D - 1.0), Vector3(W * 0.5 - 0.25, top, 0), O.STONE, "ashlar")
	O.merlons_rect(h, W - 0.5, D - 0.5, top + 1.1, O.STONE)
	# sivri kemer dolgusu (ön yüzde prizma süsü), bank, sandık
	var ar: Array = []
	for i in bays:
		ar.append(Transform3D(Basis(), Vector3(-W * 0.5 + (i + 0.5) * sp, colh + 0.35 - 0.3, fz - 0.45)))
	O.mm(h, Vector3(sp - 0.7, 0.5, 0.25), ar, O.STONE_D, "ashlar")
	for i in 3:
		O.sol(h, Vector3(1.8, 0.5, 0.6), Vector3(-W * 0.3 + i * W * 0.3, 0.35, -D * 0.5 + 1.1), O.WOOD, "wood")
	O.sol(h, Vector3(1.8, 0.9, 1.0), Vector3(0, 0.35, 0), O.WOOD_D, "wood")   # tüccar sehpası (ortada)
	O.flag(h, Vector3(-W * 0.5 + 1.0, top, -D * 0.5 + 1.0), 4.5, 2.0, 1.3)
	O.stair(h, Vector3(sx, 0, sz0), Vector3(0, 0, -1), top, 1.5, O.STONE_D, "ashlar")


# ------------------------------------------------------------------ Ceneviz evi
static func _ev(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var W := maxf(7.0 * k, 4.8)
	var D := maxf(8.0 * k, 5.4)
	var nf := 2 if k < 0.8 else 3
	var fh := 3.0
	var E := fh * nf
	var sn := ceili(E / 0.3)
	var sx := W * 0.5 + 0.75
	var sz0 := D * 0.5 - 0.5
	out["climbs"].append([Vector3(sx, 0, sz0 + 0.5), Vector3(sx, E, sz0 - (sn - 0.5) * 0.36), "basamak"])
	out["perches"].append(Vector3(0, E + W * 0.3 + 0.32, 0))
	if lod >= 3:
		return
	var rise := W * 0.3
	if lod == 1 or lod == 2:
		O.sol(h, Vector3(W, E, D), Vector3.ZERO, O.PLASTER)
		O.vis(h, Vector3(W + 0.6, rise, D + 0.6), Vector3(0, E, 0), O.TILE)
		return
	# zemin kat taş, üst katlar sıvalı ahşap iskelet (çıkma)
	O.sol(h, Vector3(W, fh, D), Vector3.ZERO, O.STONE, "ashlar")
	for f in range(1, nf):
		O.sol(h, Vector3(W + 0.5, fh, D + 0.5), Vector3(0, fh * f, 0), [O.PLASTER, O.PLASTER2, O.PLASTER3][f % 3], "plaster")
		# ahşap iskelet kuşakları
		O.vis(h, Vector3(W + 0.6, 0.18, D + 0.6), Vector3(0, fh * f - 0.02, 0), O.WOOD_D, "wood")
		O.vis(h, Vector3(W + 0.6, 0.18, D + 0.6), Vector3(0, fh * (f + 1) - 0.2, 0), O.WOOD_D, "wood")
		for dx: float in [-1.0, 0.0, 1.0]:
			O.vis(h, Vector3(0.16, fh - 0.3, 0.1), Vector3(dx * W * 0.4, fh * f + 0.1, (D + 0.5) * 0.5 + 0.03), O.WOOD_D, "wood")
		# pencereler ve kepenkler
		for dx: float in [-0.5, 0.5]:
			var wx := dx * W * 0.5
			Props.box(h, Vector3(0.7, 1.1, 0.1), Vector3(wx, fh * f + 1.6, (D + 0.5) * 0.5 + 0.05), O.DARK)
			Props.box(h, Vector3(0.32, 1.1, 0.08), Vector3(wx - 0.52, fh * f + 1.6, (D + 0.5) * 0.5 + 0.07), O.GREEN_D)
			Props.box(h, Vector3(0.32, 1.1, 0.08), Vector3(wx + 0.52, fh * f + 1.6, (D + 0.5) * 0.5 + 0.07), O.GREEN_D)
	# kapı (taş söve, yuvarlak kemer), zemin kat dar pencereleri
	O.vis(h, Vector3(1.9, 2.6, 0.35), Vector3(0, 0, D * 0.5), O.LIGHT, "ashlar")
	O.vis(h, Vector3(1.3, 2.3, 0.2), Vector3(0, 0, D * 0.5 + 0.18), O.WOOD_D, "wood")
	Props.cyl(h, 0.65, 0.2, Vector3(0, 2.3, D * 0.5 + 0.18), O.WOOD_D, Vector3(90, 0, 0), 10)
	for dx: float in [-1.0, 1.0]:
		Props.box(h, Vector3(0.35, 0.9, 0.1), Vector3(dx * W * 0.32, 1.5, D * 0.5 + 0.04), O.DARK)
	# çatı (doğu-batı sırtlı), baca, ahşap saçak balkonu
	O.gable(h, W, D, Vector3(0, E, 0), rise, O.TILE if k > 0.45 else O.TILE_D, false, 0.4, O.PLASTER)
	O.sol(h, Vector3(0.4, 0.3, D), Vector3(0, E + rise, 0), O.TILE_D)
	O.sol(h, Vector3(0.7, 1.6, 0.7), Vector3(W * 0.22, E + rise * 0.45, -D * 0.2), O.STONE, "ashlar")
	if nf >= 2:
		O.sol(h, Vector3(1.6, 0.25, 0.8), Vector3(0, fh, D * 0.5 + 0.7), O.WOOD, "wood")
	Flame.add(h, Vector3(1.4, 2.2, D * 0.5 + 0.35), 0.25, 0.4)
	O.stair(h, Vector3(sx, 0, sz0), Vector3(0, 0, -1), E, 1.4, O.WOOD, "wood")
	O.cargo(h, Vector3(-W * 0.5 - 0.72, 0, D * 0.5 - 1.0), 21)


# ------------------------------------------------------------------ rıhtım
static func _rihtim(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var W := maxf(70.0 * k, 36.0)
	var Dq := 8.0
	var qh := 1.2
	var out_z := 22.0
	out["climbs"].append([Vector3(-W * 0.25, 0, ceili(qh / 0.3) * 0.36 + 0.5), Vector3(-W * 0.25, qh, 0.18), "basamak"])
	out["perches"].append(Vector3(-W * 0.3, qh + 3.1, -2.0))
	if lod >= 3:
		return
	# deniz yüzeyi (görsel, zemin üstünde 12 cm; yürünür sığ taban)
	var sea := O.vis(h, Vector3(W + 20.0, 0.1, out_z), Vector3(0, 0.0, out_z * 0.5), O.SEA)
	sea.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	O.sol(h, Vector3(W, qh, Dq), Vector3(0, 0, -Dq * 0.5), O.STONE_D, "flagstone")
	if lod == 1 or lod == 2:
		O.sol(h, Vector3(4.0, qh, 18.0), Vector3(0, 0, 9.0), O.WOOD)
		return
	# rıhtım ön yüzü: kesme taş kuşak ve halka-babalar
	O.vis(h, Vector3(W, 0.3, 0.3), Vector3(0, qh - 0.3, 0.1), O.LIGHT, "ashlar")
	var bol: Array = []
	for i in 12:
		bol.append(Transform3D(Basis(), Vector3(-W * 0.5 + (i + 0.5) * W / 12.0, qh + 0.3, 0.6)))
	O.mm(h, Vector3(0.35, 0.6, 0.35), bol, O.WOOD_D, "wood")
	# iskeleler: üç ahşap dolu iskele, direkler görsel
	for px: float in [-W * 0.3, 0.0, W * 0.3]:
		O.sol(h, Vector3(3.2, qh, 16.0), Vector3(px, 0, 8.0), O.WOOD, "wood")
		var piles: Array = []
		for j in 7:
			piles.append(Transform3D(Basis(), Vector3(px - 1.7, qh * 0.5, 1.0 + j * 2.4)))
			piles.append(Transform3D(Basis(), Vector3(px + 1.7, qh * 0.5, 1.0 + j * 2.4)))
		O.mm(h, Vector3(0.3, qh + 1.0, 0.3), piles, O.WOOD_D, "wood")
		O.vis(h, Vector3(0.3, 0.8, 0.3), Vector3(px, qh, 16.0), O.WOOD_D, "wood")
	# demirli kadırga (katı gövde), direk ve sarılı yelken
	var gx := W * 0.15
	O.sol(h, Vector3(3.0, 1.6, 15.0), Vector3(gx, 0.0, 9.0), O.WOOD_D, "wood")
	Props.prism(h, Vector3(3.0, 2.0, 2.0), Vector3(gx, 1.0 + 0.2, 17.5), O.WOOD_D, Vector3(90, 0, 0))
	O.vis(h, Vector3(2.4, 0.15, 14.0), Vector3(gx, 1.6, 9.0), O.WOOD, "wood")
	Props.cyl(h, 0.12, 8.0, Vector3(gx, 5.6, 9.0), O.WOOD_D, Vector3.ZERO, 6)
	Props.cyl(h, 0.08, 9.0, Vector3(gx, 8.0, 9.5), O.WOOD, Vector3(0, 0, 90) + Vector3(0, 90, 0), 6)
	Props.box(h, Vector3(0.2, 0.5, 8.0), Vector3(gx, 7.6, 9.5), O.WHITE)
	O.flag(h, Vector3(gx, 1.6, 2.2), 3.0, 1.2, 0.8)
	# vinç: ahşap ayak, çarkı ve kol
	var vx := -W * 0.4
	O.sol(h, Vector3(0.5, 6.0, 0.5), Vector3(vx - 1.1, qh, -0.5), O.WOOD_D, "wood")
	O.sol(h, Vector3(0.5, 6.0, 0.5), Vector3(vx + 1.1, qh, -0.5), O.WOOD_D, "wood")
	O.vis(h, Vector3(0.4, 0.4, 4.6), Vector3(vx, qh + 5.6, 1.2), O.WOOD, "wood")
	Props.ring(h, 1.3, 1.6, Vector3(vx, qh + 2.4, -0.5), O.WOOD, Vector3(0, 0, 90))
	Props.box(h, Vector3(0.02, 2.5, 0.02), Vector3(vx, qh + 4.3, 3.2), Color("8a7a5a"))
	O.sol(h, Vector3(0.9, 0.9, 0.9), Vector3(vx, qh, -2.0), O.WOOD, "wood")
	# gümrük kulübesi, çuval ve fıçı yığınları
	O.sol(h, Vector3(6.0, 3.2, 4.0), Vector3(W * 0.38, qh, -Dq * 0.5), O.PLASTER, "plaster")
	O.gable(h, 6.0, 4.0, Vector3(W * 0.38, qh + 3.2, -Dq * 0.5), 1.6, O.TILE, false, 0.4, O.PLASTER)
	O.vis(h, Vector3(1.2, 2.3, 0.2), Vector3(W * 0.38, qh, -Dq * 0.5 + 2.05), O.WOOD_D, "wood")
	for i in 5:
		O.cargo(h, Vector3(-W * 0.15 + i * 2.2, qh, -2.0 - (i % 2) * 1.5), 30 + i)
	# basamaklı iniş: sahile taş basamaklar
	O.stair(h, Vector3(-W * 0.25, 0, ceili(qh / 0.3) * 0.36), Vector3(0, 0, -1), qh, 2.0, O.STONE, "ashlar")
	Flame.add(h, Vector3(W * 0.38 + 3.3, qh + 2.0, -Dq * 0.5 + 2.0), 0.3, 0.5)


# ------------------------------------------------------------------ ambar
static func _ambar(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var W := maxf(30.0 * k, 16.0)
	var D := maxf(12.0 * k, 8.0)
	var E := maxf(8.0 * k, 5.0)
	var rise := D * 0.3
	var sn := ceili(E / 0.3)
	var sx := W * 0.5 + 0.75
	var sz0 := D * 0.5 - 0.5
	out["climbs"].append([Vector3(sx, 0, sz0 + 0.5), Vector3(sx, E, sz0 - (sn - 0.5) * 0.36), "basamak"])
	out["perches"].append(Vector3(0, E + rise + 0.32, 0))
	if lod >= 3:
		return
	O.sol(h, Vector3(W, E, D), Vector3.ZERO, O.STONE, "ashlar")
	if lod == 1 or lod == 2:
		O.vis(h, Vector3(W + 0.6, rise, D + 0.6), Vector3(0, E, 0), O.TILE_D)
		return
	O.gable(h, D, W, Vector3(0, E, 0), rise, O.TILE_D, true, 0.5, O.STONE)
	O.sol(h, Vector3(W, 0.3, 0.4), Vector3(0, E + rise, 0), O.TILE_D)
	# büyük kemerli kapılar (ön), yüksek hava delikleri, sıvasız taş
	var nd := 2 if W < 22.0 else 3
	for i in nd:
		var x := (i - (nd - 1) * 0.5) * W / (nd + 0.4)
		O.vis(h, Vector3(3.4, 3.4, 0.4), Vector3(x, 0, D * 0.5), O.LIGHT, "ashlar")
		O.vis(h, Vector3(2.8, 3.2, 0.3), Vector3(x, 0, D * 0.5 + 0.18), O.WOOD_D, "wood")
		Props.cyl(h, 1.4, 0.3, Vector3(x, 3.2, D * 0.5 + 0.18), O.WOOD_D, Vector3(90, 0, 0), 12)
		Props.box(h, Vector3(0.35, 0.9, 0.1), Vector3(x + 2.4, E - 1.2, D * 0.5 + 0.03), O.DARK)
	for i in range(nd + 1):
		var px := (i - nd * 0.5) * W / (nd + 0.4)
		O.sol(h, Vector3(0.7, E * 0.92, 0.5), Vector3(px, 0, D * 0.5 + 0.25), O.STONE_D, "ashlar")
	var hoist := O.vis(h, Vector3(1.6, 2.2, 0.15), Vector3(0, 0, 0), O.WOOD_D, "wood")
	hoist.position = Vector3(-W * 0.5 - 0.05, E * 0.55 + 1.1, 0.0)
	hoist.rotation_degrees = Vector3(0, 90, 0)
	var vents: Array = []
	for i in 8:
		vents.append(Transform3D(Basis(), Vector3(-W * 0.5 + (i + 0.5) * W / 8.0, E - 1.2, -D * 0.5 - 0.03)))
	O.mm(h, Vector3(0.35, 0.9, 0.1), vents, O.DARK)
	# yük kirişi (kasnak) alında, sandık yığını
	Props.box(h, Vector3(0.3, 0.3, 2.6), Vector3(W * 0.5 - 1.0, E + rise * 0.55, D * 0.5 + 1.0), O.WOOD_D)
	Props.cyl(h, 0.25, 0.2, Vector3(W * 0.5 - 1.0, E + rise * 0.55 - 0.4, D * 0.5 + 2.2), O.WOOD, Vector3(0, 0, 90), 8)
	O.cargo(h, Vector3(-W * 0.2, 0, D * 0.5 + 1.6), 41)
	O.cargo(h, Vector3(W * 0.2, 0, D * 0.5 + 1.8), 42)
	O.stair(h, Vector3(sx, 0, sz0), Vector3(0, 0, -1), E, 1.5, O.STONE_D, "ashlar")


# ------------------------------------------------------------------ tersane
static func _tersane(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var W := maxf(40.0 * k, 24.0)
	var D := maxf(34.0 * k, 22.0)
	var hull_l := minf(W * 0.8, 22.0)
	var deck_y := 3.0
	var sn := ceili(deck_y / 0.3)
	var zs := hull_l * 0.45
	out["climbs"].append([Vector3(3.0, 0, zs + sn * 0.36 + 0.5), Vector3(3.0, deck_y, zs - 0.18), "basamak"])
	out["perches"].append(Vector3(0, 3.0, hull_l * 0.5 - 0.5))
	if lod >= 3:
		return
	# zemin: kızak (tahta), taş kuru zemin
	O.sol(h, Vector3(W, 0.15, D), Vector3(0, 0, 0), O.WOOD_D, "wood")
	if lod == 1 or lod == 2:
		O.sol(h, Vector3(4.2, 2.8, hull_l), Vector3(0, 0.15, 0), O.WOOD)
		O.sol(h, Vector3(8.0, 0.3, 8.0), Vector3(-W * 0.3, 3.75, -D * 0.3), O.WOOD)
		return
	# yapım aşamasındaki kadırga: kademeli katı karina (4 kat), baş/kıç, yarı kaplanmış kaburgalar, direk kütüğü
	var hl := hull_l
	O.sol(h, Vector3(4.2, 2.8, hl), Vector3(0, 0.15, 0), O.WOOD, "wood")
	for sdx: float in [-1.0, 1.0]:
		O.sol(h, Vector3(0.15, 0.9, hl - 1.0), Vector3(sdx * 2.0, 2.95, 0.0), O.WOOD_D, "wood")
	O.sol(h, Vector3(4.2, 1.3, 3.2), Vector3(0, 2.95, -hl * 0.5 + 1.7), O.WOOD_D, "wood")        # kıç kasarası
	var stem := Props.box(h, Vector3(0.35, 3.4, 0.5), Vector3(0, 2.3, hl * 0.5 + 0.55), O.WOOD_D, Vector3(-20, 0, 0))
	Props.set_pattern(stem, O.WOOD_D, "wood")
	O.sol(h, Vector3(1.6, 2.4, 1.6), Vector3(0, 0.15, hl * 0.5 + 0.8), O.WOOD, "wood")             # baş kütüğü
	var ribs: Array = []
	for i in int((hl - 5.0) / 1.1):
		var z := -hl * 0.5 + 4.2 + i * 1.1
		ribs.append(Transform3D(Basis(Vector3(0, 0, 1), -0.25), Vector3(2.0, 3.7, z)))
		ribs.append(Transform3D(Basis(Vector3(0, 0, 1), 0.25), Vector3(-2.0, 3.7, z)))
	O.mm(h, Vector3(0.16, 1.6, 0.16), ribs, O.WOOD_D, "wood")
	O.cyl(h, 0.35, 5.0, Vector3(0, 2.95, 0.0), O.WOOD_D, "wood", 8)                                 # direk kütüğü
	O.vis(h, Vector3(0.3, 0.3, 9.0), Vector3(0, 6.5, 0.0), O.WOOD, "wood").rotation_degrees = Vector3(0, 90, 0)
	# iskele: gövdeye bitişik güverte (yan yana, aralıksız), direkler, merdiven
	var sx := 0.4
	O.sol(h, Vector3(1.9, deck_y, hl * 0.9), Vector3(sx + 2.6, 0, 0), O.WOOD, "wood")
	O.vis(h, Vector3(0.1, 1.0, hl * 0.9), Vector3(sx + 3.5, deck_y, 0), O.WOOD_D, "wood")
	O.stair(h, Vector3(sx + 2.6, 0, hl * 0.45 + sn * 0.36), Vector3(0, 0, -1), deck_y, 1.9, O.WOOD, "wood")
	# kereste istifleri (basamak), testere çukuru yerine tezgâh, kazan (zift)
	for i in 3:
		O.sol(h, Vector3(5.0, 0.4 * (i + 1), 1.0), Vector3(-W * 0.3, 0.15, D * 0.3 - i * 1.0), O.WOOD, "wood")
	O.sol(h, Vector3(4.0, 0.9, 1.0), Vector3(-W * 0.3 + 6.6, 0.15, D * 0.3), O.WOOD_D, "wood")
	O.cyl(h, 0.8, 1.0, Vector3(-W * 0.3 + 10.5, 0.15, D * 0.3), Color("2a2228"), "", 10)
	Flame.add(h, Vector3(-W * 0.3 + 10.5, 1.4, D * 0.3), 0.5, 0.8)
	# hangar: açık, direkli çatı (altı geçit, ≥ 2,6 m), tahta tavan
	var hx := -W * 0.3
	var hz := -D * 0.3
	for dx: float in [-3.0, 3.0]:
		for dz: float in [-3.0, 3.0]:
			O.cyl(h, 0.2, 3.6, Vector3(hx + dx, 0.15, hz + dz), O.WOOD_D, "wood", 6)
	O.sol(h, Vector3(8.0, 0.3, 8.0), Vector3(hx, 3.75, hz), O.WOOD, "wood")
	O.gable(h, 8.0, 8.0, Vector3(hx, 4.05, hz), 1.6, O.TILE_D, false, 0.5, O.WOOD)
	O.cargo(h, Vector3(hx, 0.15, hz), 55)
	O.flag(h, Vector3(W * 0.5 - 1.5, 0.15, -D * 0.5 + 1.5), 5.0, 2.0, 1.3)


# ------------------------------------------------------------------ bağ (sur dışı yamaç)
static func _bag(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var W := maxf(50.0 * k, 30.0)
	var D := maxf(40.0 * k, 26.0)
	out["climbs"].append([Vector3(0, 0, D * 0.5 + 0.8), Vector3(0, 1.2, -D / 3.0), "basamak"])
	out["perches"].append(Vector3(W * 0.32, 5.95, -D * 0.2))
	if lod >= 3:
		return
	# üç kademe sıralı teras: 0,4 m'lik basamaklar, her kademe 6 m derin
	for t in 3:
		O.sol(h, Vector3(W, 0.4 * (t + 1), D / 3.0), Vector3(0, 0, D * 0.5 - D / 6.0 - t * D / 3.0), O.GREEN_D.lerp(O.STONE_D, 0.5), "rubble")
	if lod == 1 or lod == 2:
		return
	var vines: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 91
	for t in 3:
		var y := 0.4 * (t + 1)
		var z := D * 0.5 - D / 6.0 - t * D / 3.0
		for i in int(W / 2.2):
			var x := -W * 0.5 + 3.0 + i * 2.2
			if x > W * 0.25 and t == 1:
				continue
			vines.append(Transform3D(Basis(Vector3.UP, rng.randf() * 3.0).scaled(Vector3(1.0, 0.8, 1.0)), Vector3(x, y + 0.5, z + 1.8)))
			vines.append(Transform3D(Basis(Vector3.UP, rng.randf() * 3.0), Vector3(x, y + 0.5, z - 1.8)))
	O.mm_ball(h, 0.6, vines, Color("4a6e30"))
	var posts: Array = []
	for t in 3:
		var y := 0.4 * (t + 1)
		var z := D * 0.5 - D / 6.0 - t * D / 3.0
		for i in int(W / 4.4):
			posts.append(Transform3D(Basis(), Vector3(-W * 0.5 + 3.0 + i * 4.4, y + 0.9, z + 1.8)))
	O.mm(h, Vector3(0.1, 1.8, 0.1), posts, O.WOOD_D, "wood")
	# üzüm ezme kulübesi (taş, kiremitli), kapı, fıçılar
	var kx := W * 0.32
	var kz := -D * 0.2
	O.sol(h, Vector3(5.0, 3.0, 4.0), Vector3(kx, 1.2, kz), O.STONE, "rubble")
	O.gable(h, 5.0, 4.0, Vector3(kx, 4.2, kz), 1.5, O.TILE, false, 0.4, O.STONE)
	O.vis(h, Vector3(1.2, 2.2, 0.2), Vector3(kx, 1.2, kz + 2.05), O.WOOD_D, "wood")
	O.cargo(h, Vector3(kx - 3.4, 1.2, kz + 1.5), 66)
	# sur dışı yamaç: zeytin/selvi ağacı
	for i in 4:
		var p := Vector3(-W * 0.4 + i * W * 0.25, 1.2, -D * 0.35 + (i % 2) * 2.0)
		O.cyl(h, 0.25, 2.2, p, O.WOOD_D, "wood", 6, 0.18)
		Props.ball(h, 1.4, p + Vector3(0, 3.0, 0), O.GREEN_D, Vector3(1, 0.8, 1))


# ------------------------------------------------------------------ mezarlık
static func _mezarlik(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var W := maxf(36.0 * k, 22.0)
	var D := maxf(30.0 * k, 20.0)
	out["climbs"].append([Vector3(-W * 0.5 - 3.0, 0, 6.0), Vector3(-W * 0.5, 0.9, 6.0), "basamak"])
	out["perches"].append(Vector3(2.0, 3.0, 0.0))
	if lod >= 3:
		return
	# çevre duvarı (kapı aralığı 2,6 m, güney yüz)
	var wh := 0.9
	O.sol(h, Vector3(W, wh, 0.5), Vector3(0, 0, -D * 0.5), O.STONE, "rubble")
	O.sol(h, Vector3(0.5, wh, D), Vector3(-W * 0.5, 0, 0), O.STONE, "rubble")
	O.sol(h, Vector3(0.5, wh, D), Vector3(W * 0.5, 0, 0), O.STONE, "rubble")
	var gl := (W - 2.6) * 0.5
	O.sol(h, Vector3(gl, wh, 0.5), Vector3(-W * 0.5 + gl * 0.5, 0, D * 0.5), O.STONE, "rubble")
	O.sol(h, Vector3(gl, wh, 0.5), Vector3(W * 0.5 - gl * 0.5, 0, D * 0.5), O.STONE, "rubble")
	if lod == 1 or lod == 2:
		return
	var sn2 := ceili(wh / 0.3)
	O.stair(h, Vector3(-W * 0.5 - 0.25 - sn2 * 0.36, 0, 6.0), Vector3(1, 0, 0), wh, 1.2, O.STONE_D, "ashlar")
	O.stair(h, Vector3(-W * 0.5 + 0.25 + sn2 * 0.36, 0, 6.0), Vector3(-1, 0, 0), wh, 1.2, O.STONE_D, "ashlar")
	for s: float in [-1.0, 1.0]:
		O.sol(h, Vector3(0.6, 2.4, 0.6), Vector3(s * 1.5, 0, D * 0.5), O.LIGHT, "ashlar")
		Props.ball(h, 0.3, Vector3(s * 1.5, 2.7, D * 0.5), O.LIGHT)
	# mezar taşları: sıra sıra, hafif eğik; haç/dikme stel
	var st: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for r in 5:
		for c in int(W / 2.6) - 1:
			if absf(-W * 0.5 + 2.2 + c * 2.6) < 1.8 and r > 2:
				continue
			var b := Basis(Vector3.UP, rng.randf_range(-0.2, 0.2)) * Basis(Vector3.RIGHT, rng.randf_range(-0.08, 0.08))
			st.append(Transform3D(b, Vector3(-W * 0.5 + 2.2 + c * 2.6, 0.5, -D * 0.5 + 3.0 + r * 3.8)))
	O.mm(h, Vector3(0.55, 1.0, 0.16), st, Color("cfc7b4"), "marble")
	# selvi ağaçları (gövde katı)
	for i in 6:
		var p := Vector3(-W * 0.4 + i * W * 0.16, 0, -D * 0.2 + (i % 3) * 5.0)
		O.cyl(h, 0.25, 1.0, p, O.WOOD_D, "wood", 6)
		O.cyl(h, 0.9, 6.0, p + Vector3(0, 1.0, 0), Color("2c4a2a"), "", 8, 0.08, true)
	# küçük mezarlık şapeli (taş, kiremitli)
	O.sol(h, Vector3(4.0, 3.2, 5.0), Vector3(0, 0, -D * 0.5 + 3.0), O.PLASTER3, "plaster")
	O.gable(h, 4.0, 5.0, Vector3(0, 3.2, -D * 0.5 + 3.0), 1.5, O.TILE_D, false, 0.4, O.PLASTER3)
	O.vis(h, Vector3(1.2, 2.2, 0.2), Vector3(0, 0, -D * 0.5 + 5.55), O.WOOD_D, "wood")
