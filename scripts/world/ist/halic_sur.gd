class_name IstHalicSur
extends RefCounted
const K = preload("res://scripts/world/ist/halic_kit.gd")
## Haliç deniz suru: alçak tek sur, kuleler, çok kapı (Drungarii / Perama tipi kemerli kapı + yan kapı), kıyı rıhtımı,
## sur üstü yürüme yolu, iki merdiven. Yerel: merkez surun ortası, deniz -z, şehir +z, zemin y=0.
## Ölçek: k yalnız kütleyi (sur boyu, yükseklik) ölçekler; kapı 3,0 x 3,4, yürüme yolu 1,8, parapet 1,05 sabit.

const L_REAL := 96.0
const QUAY_W := 5.0
const QUAY_Y := 0.4


static func dims(k: float) -> Dictionary:
	var kk := clampf(k, 0.2, 1.0)
	return {
		"L": maxf(60.0, L_REAL * kk if kk > 0.6 else 64.0 + 32.0 * kk),
		"H": maxf(5.4, 9.0 * kk),
		"T": maxf(2.8, 3.0 * kk),
		"TW": maxf(5.0, 7.0 * kk),
		"TD": maxf(4.8, 7.0 * kk),
		"TH": maxf(2.6, 5.0 * kk),
	}


static func tower_xs(L: float) -> Array:
	return [-L * 0.44, -L * 0.15, L * 0.15, L * 0.44]


static func build(host: Node3D, k: float, lod: int) -> void:
	var d := dims(k)
	var L: float = d["L"]
	var H: float = d["H"]
	var T: float = d["T"]
	var root := Node3D.new()
	root.name = "HalicSur"
	host.add_child(root)
	var col := Color("c9b89a")
	if lod >= 2:
		K.slab(root, -L * 0.5, L * 0.5, -T * 0.5, T * 0.5, 0, H, col)
		for tx: float in tower_xs(L):
			K.slab(root, tx - d["TW"] * 0.5, tx + d["TW"] * 0.5, -d["TD"] * 0.5, d["TD"] * 0.5, 0, H + d["TH"], col)
		return
	var gate_w := 3.0
	var gate_h := 3.4
	var gates := [0.0, -L * 0.29]       # ana kapı (Perama tipi) + yan kapı (Hicanatissa tipi)
	var gw := [gate_w, 2.0]
	# Duvar parçaları (kapı aralıkları dışında) + kapı lentoları
	var cuts: Array = []
	for i in gates.size():
		cuts.append(Vector2(gates[i] - gw[i] * 0.5, gates[i] + gw[i] * 0.5))
	cuts.sort_custom(func(a, b): return a.x < b.x)
	var x := -L * 0.5
	for c: Vector2 in cuts:
		_wall_piece(root, x, c.x, T, H, col)
		x = c.y
	_wall_piece(root, x, L * 0.5, T, H, col)
	for i in gates.size():
		var gx: float = gates[i]
		var w: float = gw[i]
		var gh := gate_h if i == 0 else 2.6
		K.slab(root, gx - w * 0.5, gx + w * 0.5, -T * 0.5, T * 0.5, gh, H, col, "ashlar")
		_gate_dressing(root, gx, w, gh, T, i == 0)
	# Tuğla bantlar (deniz yüzü)
	for y in [1.9, 3.6, H - 0.9]:
		K.band(root, -L * 0.5, L * 0.5, y, -T * 0.5 - 0.02, T, K.BRICK, 0.3)
	# Yürüme yolu parapetleri (deniz yüzü sürekli, şehir yüzü merdiven boşluğuyla)
	_parapets(root, d, gates, gw)
	# Kuleler
	for tx: float in tower_xs(L):
		_tower(root, tx, d, col, tx > 0.0)
	# Yürüme yolu merdiveni (şehir yüzü) ve rıhtım
	var sx := -L * 0.29 - 8.0
	K.stair(root, Vector3(sx, 0, T * 0.5 + 0.34 * ceil(H / K.STEP_RISE)), Vector3(0, 0, -1), H, 1.8, Color("b4a384"))
	_quay(root, L, T, lod)
	# Fenerler ana kapının iki yanında
	for s in [-1.0, 1.0]:
		var fx: float = 2.6 * s
		K.blk(root, Vector3(0.3, 0.2, 0.3), Vector3(fx, 3.6, T * 0.5 + 0.2), Color("5e4e3e"))
		Flame.add(root, Vector3(fx, 3.75, T * 0.5 + 0.2), 0.22, 0.4)
	# Bayraklı direk: ana kapının üstünde (Bizans: kırmızı zemin altın haç)
	if lod == 0:
		_banner(root, Vector3(0, H, 0), H)


static func _wall_piece(root: Node3D, x0: float, x1: float, T: float, H: float, col: Color) -> void:
	if x1 - x0 < 0.1:
		return
	var b := K.slab(root, x0, x1, -T * 0.5, T * 0.5, 0.0, H, col, "ashlar")
	b.name = "Sur"


static func _gate_dressing(root: Node3D, gx: float, w: float, gh: float, T: float, grand: bool) -> void:
	var stone := Color("b6a583")
	# Kapı çerçevesi iki yüzde de: kemer görseli
	for zz in [-T * 0.5 - 0.06, T * 0.5 + 0.06]:
		K.arch_front(root, gx, 0.0, zz, w, gh, stone)
	# Açık kapı kanatları geçit duvarlarına yaslı (geçişi daraltmaz, görsel)
	if grand:
		for s in [-1.0, 1.0]:
			Props.box(root, Vector3(0.12, gh - 0.4, 1.3), Vector3(gx + s * (w * 0.5 - 0.07), gh * 0.5 - 0.1, -T * 0.5 + 0.8), Color("5a3a22"))
		# lentoda mermer kitabe + haç
		Props.box(root, Vector3(2.2, 0.6, 0.08), Vector3(gx, gh + 0.9, T * 0.5 + 0.06), Color("e6dfd0"))
		Props.box(root, Vector3(0.12, 0.5, 0.1), Vector3(gx, gh + 0.9, T * 0.5 + 0.1), Color("b8932f"))
		Props.box(root, Vector3(0.36, 0.1, 0.1), Vector3(gx, gh + 0.95, T * 0.5 + 0.1), Color("b8932f"))
		# eşik taşı
		Props.set_pattern(Props.solid(root, Vector3(w, 0.1, T + 0.2), Vector3(gx, 0.05, 0), Color("a89878")), Color("a89878"), "flagstone")


static func _parapets(root: Node3D, d: Dictionary, gates: Array, gw: Array) -> void:
	var L: float = d["L"]
	var H: float = d["H"]
	var T: float = d["T"]
	var tows: Array = tower_xs(L)
	# kule aralıkları: [x0, x1] arası parapet; kule içi atlanır
	var segs: Array = []
	var edges: Array = [-L * 0.5]
	for tx: float in tows:
		edges.append(tx - d["TW"] * 0.5)
		edges.append(tx + d["TW"] * 0.5)
	edges.append(L * 0.5)
	for i in range(0, edges.size(), 2):
		segs.append(Vector2(edges[i], edges[i + 1]))
	var zs: float = -T * 0.5 + 0.25
	var zl: float = T * 0.5 - 0.25
	var stair_x: float = -L * 0.29 - 8.0
	for sg: Vector2 in segs:
		if sg.y - sg.x < 0.3:
			continue
		K.slab(root, sg.x, sg.y, zs - 0.25, zs + 0.25, H, H + 1.05, Color("cdbd9f"), "ashlar").name = "ParapetDeniz"
		K.merlons(root, sg.x, sg.y, zs, H + 1.05, Color("cdbd9f"))
		# şehir yüzü: merdiven başında 2 m boşluk
		var cuts: Array = []
		if stair_x > sg.x and stair_x < sg.y:
			cuts.append(Vector2(stair_x - 1.0, stair_x + 1.0))
		var xx: float = sg.x
		for c: Vector2 in cuts:
			K.slab(root, xx, c.x, zl - 0.25, zl + 0.25, H, H + 1.05, Color("cdbd9f"), "ashlar")
			xx = c.y
		K.slab(root, xx, sg.y, zl - 0.25, zl + 0.25, H, H + 1.05, Color("cdbd9f"), "ashlar")


static func _tower(root: Node3D, tx: float, d: Dictionary, col: Color, flip: bool) -> void:
	var TW: float = d["TW"]
	var TD: float = d["TD"]
	var H: float = d["H"]
	var TH: float = d["TH"]
	var T: float = d["T"]
	var top: float = H + TH
	var tcol := Color("bfae90")
	# Alt gövde (zeminden yürüme yolu seviyesine) tam dolu
	K.slab(root, tx - TW * 0.5, tx + TW * 0.5, -TD * 0.5, TD * 0.5, 0, H, tcol, "ashlar").name = "KuleAlt"
	# Üst bölüm: yürüme yolu geçidi (1,8 m) açık; deniz ve şehir tarafı parçaları, geçit üstü lento
	var gz0 := -0.9
	var gz1 := 0.9
	K.slab(root, tx - TW * 0.5, tx + TW * 0.5, -TD * 0.5, gz0, H, top, tcol, "ashlar").name = "KuleUstDeniz"
	K.slab(root, tx - TW * 0.5, tx + TW * 0.5, gz1, TD * 0.5, H, top, tcol, "ashlar").name = "KuleUstSehir"
	K.slab(root, tx - TW * 0.5, tx + TW * 0.5, gz0, gz1, H + 2.4, top, tcol, "ashlar").name = "KuleLento"
	# Tepe: kule üstüne yürüyüş yok (üst bölüm dolu, tepe düz). Kule tepesinde siper
	K.slab(root, tx - TW * 0.5, tx + TW * 0.5, -TD * 0.5, -TD * 0.5 + 0.5, top, top + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, tx - TW * 0.5, tx - TW * 0.5 + 0.5, -TD * 0.5 + 0.5, TD * 0.5 - 0.5, top, top + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, tx + TW * 0.5 - 0.5, tx + TW * 0.5, -TD * 0.5 + 0.5, TD * 0.5 - 0.5, top, top + 1.05, Color("cdbd9f"), "ashlar")
	# şehir yüzünde merdiven boşluğu: 2 m
	K.slab(root, tx - TW * 0.5, tx - 1.0, TD * 0.5 - 0.5, TD * 0.5, top, top + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, tx + 1.0, tx + TW * 0.5, TD * 0.5 - 0.5, TD * 0.5, top, top + 1.05, Color("cdbd9f"), "ashlar")
	# Kule merdiveni (şehir yüzü, tepeye)
	var n := int(ceil(top / K.STEP_RISE))
	K.stair(root, Vector3(tx, 0, TD * 0.5 + 0.34 * n), Vector3(0, 0, -1), top, 1.8, Color("b4a384"))
	# Tuğla bantlar ve okçu mazgalları (deniz yüzü)
	for y in [2.2, H * 0.62, top - 1.0]:
		Props.box(root, Vector3(TW + 0.06, 0.3, 0.05), Vector3(tx, y, -TD * 0.5 - 0.03), K.BRICK)
		Props.box(root, Vector3(TW + 0.06, 0.3, 0.05), Vector3(tx, y, TD * 0.5 + 0.03), K.BRICK)
	for s in [-1.0, 0.0, 1.0]:
		Props.box(root, Vector3(0.18, 0.9, 0.06), Vector3(tx + s * TW * 0.28, H * 0.7, -TD * 0.5 - 0.04), Color("17130f"))
	# Tepede mazgal dişleri (siper üstünde)
	K.merlons(root, tx - TW * 0.5, tx + TW * 0.5, -TD * 0.5 + 0.25, top + 1.05, Color("cdbd9f"), 1.4)
	# Tepe dekoru: fener
	Props.cyl(root, 0.06, 1.2, Vector3(tx + TW * 0.5 - 0.7, top + 0.6, -TD * 0.5 + 1.0), Color("3a2a1a"), Vector3.ZERO, 6)


static func _quay(root: Node3D, L: float, T: float, lod: int) -> void:
	var z0 := -T * 0.5 - QUAY_W
	var z1 := -T * 0.5
	var q := K.slab(root, -L * 0.5 - 4.0, L * 0.5 + 4.0, z0, z1, -1.6, QUAY_Y, Color("a89a80"), "flagstone")
	q.name = "Rihtim"
	# Rıhtım ön yüzü taş sıra çizgisi ve halka
	Props.box(root, Vector3(L + 8.0, 0.2, 0.06), Vector3(0, QUAY_Y - 0.5, z0 - 0.03), Color("7a6c58"))
	K.sea(root, -L * 0.5 - 40.0, L * 0.5 + 40.0, z0 - 40.0, z0, 1.6)
	# Suya iniş basamakları (iki yer)
	for sx in [-L * 0.2, L * 0.33]:
		var n := int(ceil((QUAY_Y + 1.6) / K.STEP_RISE))
		K.stair(root, Vector3(sx, -1.6, z0 - 0.34 * n), Vector3(0, 0, 1), QUAY_Y + 1.6, 2.0, Color("958870"))
	if lod >= 1:
		return
	# Bağlama babaları (rıhtım kenarında 1,6 m arayla ikili, 0,4 m)
	var xf: Array = []
	var x := -L * 0.5
	while x < L * 0.5:
		xf.append(Transform3D(Basis.IDENTITY, Vector3(x, QUAY_Y + 0.22, z0 + 0.35)))
		x += 6.0
	K.multi(root, K.cyl_mesh(0.12, 0.44, 6), xf, K.TIMBER_D, "wood")
	# Kıyı yığınları: fıçı ve balya
	var xs := [-L * 0.36, -L * 0.07, L * 0.12, L * 0.28]
	K.barrel_stack(root, Vector3(xs[0], QUAY_Y, z0 + 1.8), 2, 2, 2)
	K.bale_stack(root, Vector3(xs[1], QUAY_Y, z0 + 1.8), 2, 2, 3)
	K.barrel_stack(root, Vector3(xs[2], QUAY_Y, z0 + 1.8), 3, 2, 1)
	K.bale_stack(root, Vector3(xs[3], QUAY_Y, z0 + 1.8), 2, 1, 2, Color("c9b68a"))
	# Yığınlara çıkış: sandık basamakları rıhtımdan
	K.crate_steps(root, Vector3(xs[1] + 4.0, QUAY_Y, z0 + 1.8), Vector3(-1, 0, 0), 3)
	# Rıhtımdan şehre: kapı önünde 0,4 m rıhtım -> zemin: eşik rampası
	Props.ramp(root, Vector3(0, QUAY_Y, z1), Vector3(0, 0, z1 + 3.0), 3.0, Color("a89878"))


static func _banner(root: Node3D, pos: Vector3, H: float) -> void:
	var pole := Props.cyl(root, 0.06, 4.0, pos + Vector3(0, 2.0, 0), Color("3a2a1a"), Vector3.ZERO, 6)
	Props.box(root, Vector3(1.6, 1.0, 0.04), pos + Vector3(0.85, 3.4, 0), Color("a82a2a"))
	Props.box(root, Vector3(0.12, 0.7, 0.05), pos + Vector3(0.85, 3.4, 0), Color("d9b43a"))
	Props.box(root, Vector3(0.5, 0.12, 0.05), pos + Vector3(0.85, 3.5, 0), Color("d9b43a"))
	pole.name = "BayrakDireki"


static func perches(k: float) -> Array:
	var d := dims(k)
	var out: Array = []
	for tx: float in tower_xs(d["L"]):
		out.append(Vector3(tx, d["H"] + d["TH"] + 1.05, -d["TD"] * 0.5 + 1.0))
	out.append(Vector3(0, d["H"] + 4.0, 0))
	return out


static func climbs(k: float) -> Array:
	var d := dims(k)
	var H: float = d["H"]
	var T: float = d["T"]
	var out: Array = []
	var L: float = d["L"]
	var sx: float = -L * 0.29 - 8.0
	out.append([Vector3(sx, 0, T * 0.5 + 0.34 * ceil(H / K.STEP_RISE) + 0.4), Vector3(sx, H, T * 0.5 - 0.3), "basamak"])
	var tw: Array = tower_xs(L)
	var top: float = H + d["TH"]
	var n := int(ceil(top / K.STEP_RISE))
	out.append([Vector3(tw[2], 0, d["TD"] * 0.5 + 0.34 * n + 0.4), Vector3(tw[2], top, d["TD"] * 0.5 - 0.3), "basamak"])
	out.append([Vector3(L * 0.33, -1.6, -T * 0.5 - QUAY_W - 0.34 * 8 - 0.4), Vector3(L * 0.33, QUAY_Y, -T * 0.5 - QUAY_W + 0.3), "basamak"])
	var z0 := -T * 0.5 - QUAY_W
	var x1: float = -L * 0.07
	out.append([Vector3(x1 + 4.4, QUAY_Y, z0 + 1.8), Vector3(x1 + 0.8, QUAY_Y + 1.5, z0 + 1.8), "sandik"])
	return out
