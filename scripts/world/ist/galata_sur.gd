class_name IstGalataSur
extends RefCounted
## Galata kara surları: çift burçlu kapı, mazgallı yürüme yolu, dışında kuru hendek ve karşı sırt (kontrskarp).
## Sur kuzeye (-z) bakar; iç yüz güneyde (+z). Hendek tabanı zemin düzeyindedir, karşı kıyı sırt olarak yükselir
## (zemin düzlemini oymak yerine): kapı önünde sırt açıktır.
const O := preload("res://scripts/world/ist/galata_ortak.gd")


static func build(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var t := maxf(3.2 * k, 2.6)                 # sur kalınlığı (yürüme yolu ≥ 1,4 m)
	var Hw := maxf(10.0 * k, 5.5)
	var E := maxf(32.0 * k, 17.0)               # uç burca kadar yarı uzunluk
	var tw := maxf(7.0 * k, 4.6)                # burç kenarı
	var gate := 3.2
	var gh := 3.4
	var wm := maxf(8.0 * k, 5.0)                # hendek genişliği
	var dep := maxf(3.5 * k, 1.8)               # karşı sırt yüksekliği
	var xs := -E * 0.5                          # iç merdiven x'i
	var n := ceili(Hw / 0.3)
	var sb := Vector3(xs, 0, t * 0.5 + n * 0.36)
	out["climbs"].append([Vector3(xs, 0, sb.z + 0.5), Vector3(xs, Hw, t * 0.5 + 0.18), "basamak"])
	out["perches"].append(Vector3(-E, Hw + tw * 0.0 + 1.15, -t * 0.5 + 0.25))
	out["perches"].append(Vector3(E, Hw + 1.15, -t * 0.5 + 0.25))
	if lod >= 3:
		return
	if lod == 1 or lod == 2:
		O.sol(h, Vector3(2 * E, Hw, t), Vector3(0, 0, 0), O.STONE)
		for sx: float in [-E, E, -gate * 0.5 - tw * 0.5, gate * 0.5 + tw * 0.5]:
			O.sol(h, Vector3(tw, Hw + 2.0, tw), Vector3(sx, 0, -tw * 0.3), O.STONE_D)
		return
	# --- sur gövdesi: kapı aralığının iki yanı + lento
	for s: float in [-1.0, 1.0]:
		var x0 := gate * 0.5
		var ln := E - x0
		O.sol(h, Vector3(ln, Hw, t), Vector3(s * (x0 + ln * 0.5), 0, 0), O.STONE, "ashlar")
	O.sol(h, Vector3(gate, Hw - gh, t), Vector3(0, gh, 0), O.STONE, "ashlar")
	# kemer sövesi (sivri) ve kapı kanatları (açık)
	O.vis(h, Vector3(gate + 0.6, 0.35, t + 0.3), Vector3(0, gh - 0.1, 0), O.LIGHT, "ashlar")
	for s: float in [-1.0, 1.0]:
		O.vis(h, Vector3(0.3, gh, 1.6), Vector3(s * (gate * 0.5 + 0.1), 0, -t * 0.5 - 0.6), O.WOOD_D, "wood")
	# --- sur üstü: dış parapet (katı, 1,1 m) + mazgal; iç korkuluk iki parça (merdiven boşluğu)
	var py := Hw
	O.sol(h, Vector3(2 * E, 1.1, 0.5), Vector3(0, py, -t * 0.5 + 0.25), O.STONE, "ashlar")
	var mer: Array = []
	var nm := int(2 * E / 1.8)
	for i in nm:
		mer.append(Transform3D(Basis(), Vector3(-E + (i + 0.5) * 2 * E / nm, py + 1.1 + 0.4, -t * 0.5 + 0.25)))
	O.mm(h, Vector3(0.9, 0.8, 0.5), mer, O.STONE, "ashlar")
	var rl := xs - 1.0 + E
	O.sol(h, Vector3(rl, 1.0, 0.4), Vector3(-E + rl * 0.5, py, t * 0.5 - 0.2), O.STONE_D, "ashlar")
	var rr := E - (xs + 1.0)
	O.sol(h, Vector3(rr, 1.0, 0.4), Vector3(xs + 1.0 + rr * 0.5, py, t * 0.5 - 0.2), O.STONE_D, "ashlar")
	# --- burçlar: kapının iki yanı + uç burçlar, düz katı tepe (yürüme yoluyla aynı düzeyde) + mazgal
	var tx: Array = [-gate * 0.5 - tw * 0.5, gate * 0.5 + tw * 0.5, -E - tw * 0.5 + 0.0, E + tw * 0.5]
	for x: float in tx:
		var tz := -(t * 0.5 + tw * 0.5) + t * 0.5 + 0.0
		O.sol(h, Vector3(tw, Hw, tw + t * 0.5), Vector3(x, 0, -tw * 0.25 - t * 0.0), O.STONE, "ashlar")
		var g := Node3D.new()
		g.position = Vector3(x, Hw + 0.0, -tw * 0.25)
		h.add_child(g)
		O.sol(g, Vector3(tw, 1.1, 0.5), Vector3(0, 0, -(tw + t * 0.5) * 0.5 + 0.25), O.STONE, "ashlar")
		O.sol(g, Vector3(0.5, 1.1, tw + t * 0.5), Vector3(-tw * 0.5 + 0.25, 0, 0), O.STONE, "ashlar")
		O.sol(g, Vector3(0.5, 1.1, tw + t * 0.5), Vector3(tw * 0.5 - 0.25, 0, 0), O.STONE, "ashlar")
		O.merlons_rect(g, tw, tw + t * 0.5, 1.1, O.STONE)
		# ok yarığı
		O.vis(h, Vector3(0.25, 1.1, 0.2), Vector3(x, Hw * 0.55, -tw * 0.25 - (tw + t * 0.5) * 0.5 - 0.05), O.DARK)
		Flame.add(h, Vector3(x, Hw + 1.6, -tw * 0.25 - (tw + t * 0.5) * 0.5 + 0.7), 0.3, 0.5)
	# kapı burçlarının dış köşelerinde taş köşe kuleciği (bartizan) ve konik külah
	for sx2: float in [-1.0, 1.0]:
		var bx: float = sx2 * (gate * 0.5 + tw - 1.0)
		var bzz := -tw * 0.25 - (tw + t * 0.5) * 0.5 + 0.9
		O.cyl(h, 1.0, 3.7, Vector3(bx, Hw, bzz), O.STONE, "ashlar", 10)
		O.cyl(h, 1.35, 1.8, Vector3(bx, Hw + 3.7, bzz), O.TILE_D, "tiles", 10, 0.1, false)
		O.vis(h, Vector3(0.3, 0.9, 0.2), Vector3(bx, Hw + 2.0, bzz - 1.0), O.DARK)
	# ok yarıkları, kuşak ve payandalar (dış yüz)
	var slits: Array = []
	for i in int(2 * E / 4.0):
		slits.append(Transform3D(Basis(), Vector3(-E + 2.0 + i * 4.0, Hw * 0.58, -t * 0.5 - 0.02)))
	O.mm(h, Vector3(0.2, 1.0, 0.2), slits, O.DARK)
	O.vis(h, Vector3(2 * E, 0.35, t + 0.3), Vector3(0, Hw - 0.8, 0), O.LIGHT, "ashlar")
	for i in int(2 * E / 9.0):
		var px := -E + 4.5 + i * 9.0
		if absf(px) > gate * 0.5 + tw + 0.5:
			O.sol(h, Vector3(1.0, Hw * 0.8, 0.5), Vector3(px, 0, -t * 0.5 - 0.25), O.STONE, "ashlar")
	# bayrak (sağ kapı burcu)
	O.flag(h, Vector3(gate * 0.5 + tw * 0.5 - 0.8, Hw, -tw * 0.25 + 0.8), 4.5, 2.0, 1.3)
	# --- merdiven (iç yüz)
	O.stair(h, sb, Vector3(0, 0, -1), Hw, 1.5, O.STONE_D, "ashlar")
	# --- hendek: dış kıyı sırtı (kapı aralığı boş) + iki yüzünde rampa
	var bz := -(t * 0.5 + wm)
	var gl := 2.0
	for s: float in [-1.0, 1.0]:
		var x0 := gl
		var ln := E + tw - x0
		var cx := s * (x0 + ln * 0.5)
		O.sol(h, Vector3(ln, dep, 2.0), Vector3(cx, 0, bz - 1.0), O.STONE_D, "rubble")
		var rz := bz - 2.0
		O.ramp(h, Vector3(cx, 0, rz - 3.2 * dep), Vector3(0, 0, 1), 3.2 * dep, dep, ln, Color("7d6e4c"))
		O.ramp(h, Vector3(cx, 0, bz + 3.2 * dep), Vector3(0, 0, -1), 3.2 * dep, dep, ln, Color("7d6e4c"))
	# kapı önünde ahşap köprü/ geçit (zemin düzeyinde yürüme tahtası)
	O.vis(h, Vector3(gl * 2 - 0.2, 0.05, wm + 1.0), Vector3(0, 0.0, -(t * 0.5 + wm * 0.5)), O.WOOD, "wood")
	# --- tepeye çıkılamayan dış yüz için düz taş; yan tarafta sur dibinde moloz
	O.cargo(h, Vector3(xs - 3.0, 0, t * 0.5 + 1.4), 5)
