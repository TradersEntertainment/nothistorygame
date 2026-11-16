class_name IstGalataKule
extends RefCounted
## Christea Turris (Galata Kulesi), 1348: taş gövde, mazgallı çıkıntılı şerefe, yukarıda daha ince sekizgen kasnak,
## konik külah (1453'te bugünkü gibi; kestirim: ahşap/kurşun kaplı), tepede haç ve Ceneviz bayrağı.
const O := preload("res://scripts/world/ist/galata_ortak.gd")


static func build(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var R := 8.2 * k
	var H1 := 40.0 * k                         # şerefe tabanı
	var Rup := 6.7 * k
	var gw := maxf(2.6 * k, 1.6)               # şerefe yürüme yolu genişliği (≥1,4 m)
	var Rg := Rup + gw
	var Hu := maxf(9.0 * k, 4.6)               # üst kasnak
	var Hc := maxf(15.0 * k, 6.0)              # külah
	var ytop := H1 + Hu + Hc
	# --- ek yapı (ambar sundurması) ve sokaktan çıkış
	var ax := R + 1.6
	var an_h := 2.8
	var stair_base := Vector3(ax, 0, 3.3 + ceili(an_h / 0.3) * 0.36)
	var stair_top := Vector3(ax, an_h, 3.3)
	out["climbs"].append([Vector3(ax, 0, stair_base.z + 0.5), stair_top, "basamak"])
	var rail_a := TAU * 0.5 / 16.0
	out["perches"].append(Vector3(sin(rail_a) * (Rg - 0.2) * cos(PI / 16.0), H1 + 1.15, cos(rail_a) * (Rg - 0.2) * cos(PI / 16.0)))
	out["perches"].append(Vector3(0, ytop + 0.35, 0))
	if lod >= 3:
		return
	if lod == 1 or lod == 2:
		O.cyl(h, R, H1, Vector3.ZERO, O.STONE, "", 8, R * 0.93)
		O.cyl(h, Rg, 3.0, Vector3(0, H1 - 3.0, 0), O.STONE_D, "", 8)
		O.cyl(h, Rup, Hu, Vector3(0, H1, 0), O.STONE, "", 8)
		O.cyl(h, Rup + 0.9, Hc, Vector3(0, H1 + Hu, 0), O.TILE_D, "", 8, 0.45)
		return
	# --- taban kaidesi ve gövde
	O.cyl(h, R * 1.07, 1.2, Vector3.ZERO, O.STONE_D, "ashlar", 16)
	var shaft := O.cyl(h, R, H1 - 3.0, Vector3(0, 0, 0), O.STONE, "ashlar", 16, R * 0.93 * 0.99)
	# şerefe altı: dışa açılan taş konsol (machicolation), üstünde döşeme
	O.cyl(h, R * 0.93, 2.0, Vector3(0, H1 - 3.0, 0), O.STONE_D, "ashlar", 16, Rg - 0.1)
	O.cyl(h, Rg, 1.0, Vector3(0, H1 - 1.0, 0), O.STONE, "flagstone", 16)
	# taş bantlar
	for f: float in [0.3, 0.55, 0.8]:
		var yb := (H1 - 3.0) * f
		var rb := lerpf(R, R * 0.93, f) + 0.07
		O.cyl(h, rb, 0.35, Vector3(0, yb, 0), Color("a89878"), "", 16, -1.0, false)
	# konsol dişleri
	var cor: Array = []
	for i in 24:
		var a := TAU * i / 24.0
		cor.append(O.xf(a, Rg - 0.35, H1 - 1.6))
	O.mm(h, Vector3(0.55, 0.9, 0.9), cor, O.STONE_D, "ashlar")
	# dar mazgal pencereler (gövde)
	var slits: Array = []
	for lv in 4:
		var f := 0.14 + 0.2 * lv
		var y := (H1 - 3.0) * f
		var rr := lerpf(R, R * 0.93, f) * cos(PI / 16.0) + 0.04
		for j in 4:
			var a := TAU * j / 4.0 + (PI * 0.25 if lv % 2 == 1 else 0.0)
			slits.append(O.xf(a, rr, y + 0.6))
	O.mm(h, Vector3(0.28, 1.2, 0.2), slits, O.DARK)
	# kapı (güney): taş söve, ahşap kanat, yuvarlak kemer
	var dz := R * 1.07 * cos(PI / 16.0) + 0.02
	O.vis(h, Vector3(2.2, 2.9, 0.5), Vector3(0, 1.2, dz), O.LIGHT, "ashlar")
	O.vis(h, Vector3(1.4, 2.3, 0.3), Vector3(0, 1.2, dz + 0.25), O.WOOD_D, "wood")
	var arch := Props.cyl(h, 0.7, 0.3, Vector3(0, 3.5, dz + 0.26), O.WOOD_D, Vector3(90, 0, 0), 12)
	for st in 2:
		O.sol(h, Vector3(3.0, 0.2 * (st + 1), 0.5), Vector3(0, 0, dz + 0.5 + st * 0.5), O.STONE_D, "ashlar")
	# üst kasnak ve dört kemerli çan penceresi
	O.cyl(h, Rup, Hu, Vector3(0, H1, 0), O.STONE, "ashlar", 16)
	var op: Array = []
	for j in 8:
		var a := TAU * j / 8.0
		op.append(O.xf(a, Rup * cos(PI / 16.0) + 0.03, H1 + 1.4))
	O.mm(h, Vector3(0.9, 2.0, 0.3), op, O.DARK)
	var capi: Array = []
	for j in 8:
		var a := TAU * j / 8.0
		capi.append(O.xf(a, Rup * cos(PI / 16.0) + 0.03, H1 + 2.4 + 0.45))
	O.mm(h, Vector3(0.9, 0.5, 0.3), capi, O.DARK)
	# kasnak başlığı (saçak)
	O.cyl(h, Rup + 0.55, 0.4, Vector3(0, H1 + Hu - 0.4, 0), O.LIGHT, "ashlar", 16)
	# külah: kiremit/kurşun bantlı, dört çatı penceresi
	O.cyl(h, Rup + 1.0, Hc, Vector3(0, H1 + Hu, 0), O.TILE_D, "tiles", 16, 0.45)
	for j in 4:
		var a := TAU * j / 4.0 + PI * 0.25
		var rc := lerpf(Rup + 1.0, 0.45, 0.3)
		var g := Node3D.new()
		g.position = Vector3(sin(a) * (rc - 0.1), H1 + Hu + Hc * 0.3, cos(a) * (rc - 0.1))
		g.rotation = Vector3(0, a, 0)
		h.add_child(g)
		Props.prism(g, Vector3(1.0, 1.2, 1.1), Vector3(0, 0.5, 0.2), O.TILE)
		Props.box(g, Vector3(0.4, 0.55, 0.1), Vector3(0, 0.3, 0.76), O.DARK)
	# tepe: taş başlık, altın top, haç
	O.cyl(h, 0.6, 0.3, Vector3(0, ytop - 0.05, 0), O.STONE_D, "", 8)
	Props.ball(h, 0.32, Vector3(0, ytop + 0.5, 0), Color("d8b040"))
	Props.box(h, Vector3(0.1, 1.3, 0.1), Vector3(0, ytop + 1.3, 0), Color("d8b040"))
	Props.box(h, Vector3(0.7, 0.1, 0.1), Vector3(0, ytop + 1.55, 0), Color("d8b040"))
	# şerefe: korkuluk (katı), mazgallar, meşale, bayrak
	O.ring_rail(h, Rg - 0.2, H1, 16, O.STONE, 1.1, 0.4)
	var mer: Array = []
	for i in 24:
		var a := TAU * (i + 0.5) / 24.0
		mer.append(O.xf(a, Rg - 0.2, H1 + 1.1 + 0.4))
	O.mm(h, Vector3(0.85, 0.8, 0.45), mer, O.STONE, "ashlar")
	for q in 4:
		var a := TAU * q / 4.0 + PI * 0.25
		var p := Vector3(sin(a) * (Rup + 0.6), H1, cos(a) * (Rup + 0.6))
		O.sol(h, Vector3(0.5, 0.9, 0.5), p, O.STONE_D, "ashlar")
		Flame.add(h, p + Vector3(0, 1.2, 0), 0.3, 0.5)
	O.flag(h, Vector3(sin(0.8) * (Rg - 0.6), H1, cos(0.8) * (Rg - 0.6)), 5.0, 2.2, 1.4)
	# ek yapı: taş ambar sundurması (düz katı çatı, korkuluk), merdiven; sandık yığını öbür yanda
	var a0 := R * 0.4
	var a1 := ax + 2.2
	O.sol(h, Vector3(a1 - a0, an_h, 6.0), Vector3((a0 + a1) * 0.5, 0, 0.3), O.PLASTER3, "plaster")
	O.vis(h, Vector3(a1 - a0 + 0.2, 0.3, 6.2), Vector3((a0 + a1) * 0.5, an_h, 0.3), O.STONE_D, "ashlar")
	O.vis(h, Vector3(1.3, 2.2, 0.15), Vector3(ax, 0.0, 3.35), O.WOOD_D, "wood")
	O.stair(h, stair_base, Vector3(0, 0, -1), an_h, 1.5, O.STONE, "ashlar")
	O.cargo(h, Vector3(-ax - 3.0, 0, 4.5), 11)
