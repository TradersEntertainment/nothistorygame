class_name IstMarmaraLiman
extends RefCounted
## Limanlar (Nisan 1453): Kontoskalion (kapalı havuz, mendirek, kadırga tezgâhları), dolmuş Eleutherios/Theodosius limanı =
## Langa bostanları, Sophia (Iulianos) limanı kalıntısı. Eksenler: +x doğu, -z kuzey, +z güney = deniz.
## Çukurların (havuz) yürünür tabanı ve basamaklı çıkışı vardır; su yüzeyi görseldir (sığ, içinden yürünür).

const Q := 5.0              # rıhtım genişliği (gerçek boy)
const FLOOR_Y := -2.4


# =========================================================== KONTOSKALION ======================================
static func kd(k: float) -> Dictionary:
	return {"W": maxf(80.0 * k, 36.0), "L": maxf(70.0 * k, 30.0), "MOLE": maxf(60.0 * k, 30.0), "MOUTH": 14.0}


static func build_kontoskalion(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var d := kd(k)
	var W: float = d["W"]
	var L: float = d["L"]
	var MO: float = d["MOLE"]
	var MW: float = d["MOUTH"]
	var root := IstMk.root(host, "Kontoskalion")
	var ox := W * 0.5 + Q * 0.5        # doğu/batı rıhtım merkezi
	var oz := L * 0.5 + Q * 0.5        # kuzey/güney rıhtım merkezi
	# taban (havuz zemini): yürünür
	IstMk.S(root, Vector3(W + 0.2, 0.5, L + 0.2), Vector3(0, FLOOR_Y - 0.5, 0), IstMk.SAND, "flagstone" if lod == 0 else "")
	# rıhtım halkası: batı, doğu, kuzey tam; güney iki yanı ağız bırakır
	var qh := -FLOOR_Y + 0.08
	var wallc := IstMk.STONE
	IstMk.S(root, Vector3(Q, qh, L + 2.0 * Q), Vector3(-ox, FLOOR_Y, 0), wallc, "ashlar")
	IstMk.S(root, Vector3(Q, qh, L + 2.0 * Q), Vector3(ox, FLOOR_Y, 0), wallc, "ashlar")
	IstMk.S(root, Vector3(W, qh, Q), Vector3(0, FLOOR_Y, -oz), wallc, "ashlar")
	var sw := (W - MW) * 0.5
	IstMk.S(root, Vector3(sw, qh, Q), Vector3(-(MW * 0.5 + sw * 0.5), FLOOR_Y, oz), wallc, "ashlar")
	IstMk.S(root, Vector3(sw, qh, Q), Vector3((MW * 0.5 + sw * 0.5), FLOOR_Y, oz), wallc, "ashlar")
	# ağız zemini: dışarıya doğru 12 m yükselen rampa (-2,4 → 0)
	var rl := 12.0
	var ramp := Props.solid(root, Vector3(MW, 0.4, sqrt(rl * rl + 2.4 * 2.4)), Vector3(0, FLOOR_Y * 0.5 - 0.2, L * 0.5 + Q + rl * 0.5), IstMk.SAND)
	ramp.rotation.x = atan2(-FLOOR_Y, rl) * -1.0
	Props.set_pattern(ramp, IstMk.SAND, "flagstone")
	# mendirek (doğu kolu): güneye ve doğuya uzar; kule ucunda ateş
	var mz := L * 0.5 + Q
	var mx0 := MW * 0.5
	IstMk.S(root, Vector3(MO, qh, 5.0), Vector3(mx0 + MO * 0.5 + sw, FLOOR_Y, mz + 7.0), IstMk.STONE_DK, "ashlar")
	if lod >= 2:
		return
	# su yüzeyi (sığ, görsel)
	IstMk.WATER_PLANE(root, Vector2(W, L), Vector3(0, -0.95, 0))
	# rıhtım üst levha ve kenar bordürü
	if lod == 1:
		return
	_basin_details(root, d, k)


static func _basin_details(root: Node3D, d: Dictionary, k: float) -> void:
	var W: float = d["W"]
	var L: float = d["L"]
	var MO: float = d["MOLE"]
	var MW: float = d["MOUTH"]
	var ox := W * 0.5 + Q * 0.5
	var oz := L * 0.5 + Q * 0.5
	var qh := -FLOOR_Y + 0.08
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453 + 7
	# kenar taşları (bordür) ve bağlama babaları
	IstMk.V(root, Vector3(0.5, 0.18, L + 2.0 * Q), Vector3(-W * 0.5 - 0.25, 0.08, 0), IstMk.STONE_DK, "ashlar")
	IstMk.V(root, Vector3(0.5, 0.18, L + 2.0 * Q), Vector3(W * 0.5 + 0.25, 0.08, 0), IstMk.STONE_DK, "ashlar")
	for i in int(L / 6.0):
		for sx: float in [-1.0, 1.0]:
			IstMk.CY(root, 0.17, 0.6, Vector3(sx * (W * 0.5 + 0.8), 0.08, -L * 0.5 + 3.0 + i * 6.0), IstMk.STONE_DK, "marble", 8, true)
	# --- kadırga tezgâhları: batı rıhtımında üç kızak (tersane); her biri suya inen rampa + yarım kadırga gövdesi
	for i in 3:
		var z := -L * 0.22 + i * (L * 0.2)
		var slope_len := 11.0
		var x_top := -W * 0.5
		var rampb := Props.solid(root, Vector3(3.6, 0.3, sqrt(slope_len * slope_len + 2.4 * 2.4)), Vector3(x_top + slope_len * 0.5, FLOOR_Y * 0.5 + 0.08 - 0.15, z), IstMk.WOOD)
		rampb.rotation.z = atan2(2.4, slope_len)
		Props.set_pattern(rampb, IstMk.WOOD, "wood")
		# gövde: yarım tamamlanmış kadırga (kıçı tahtalı, pruva kaburgalı)
		var hx := x_top + 1.5
		var hz := z
		var hy := 0.08 + 0.25
		IstMk.S(root, Vector3(9.0, 0.5, 2.4), Vector3(hx + 4.5, hy + 0.1, hz), IstMk.WOOD_LT, "wood")
		IstMk.S(root, Vector3(9.0, 0.9, 0.35), Vector3(hx + 4.5, hy + 0.6, hz - 1.0), IstMk.WOOD, "wood", 0.0)
		IstMk.S(root, Vector3(9.0, 0.9, 0.35), Vector3(hx + 4.5, hy + 0.6, hz + 1.0), IstMk.WOOD, "wood", 0.0)
		# kaburgalar (pruva yarısı; tahtasız)
		var rib: Array = []
		for j in 5:
			rib.append([Vector3(hx + 5.2 + j * 0.8, hy + 1.2, hz - 1.0), 0.0])
			rib.append([Vector3(hx + 5.2 + j * 0.8, hy + 1.2, hz + 1.0), 0.0])
		IstMk.MM(root, Vector3(0.14, 1.2, 0.2), rib, IstMk.WOOD_DK, "wood")
		# kızak payandaları ve palamar halatı
		for j in 3:
			IstMk.V(root, Vector3(0.3, 0.9, 3.0), Vector3(hx + 1.0 + j * 3.0, 0.0, hz), IstMk.WOOD_DK, "wood")
		# direk (yatık, yedek)
		IstMk.CYR(root, 0.14, 8.0, Vector3(hx + 4.5, hy + 2.3, hz + 2.4), IstMk.WOOD_LT, Vector3(0, 0, 90), "wood", 7)
	# --- rıhtım ekipmanı: tahta yığını (basamak), katran kazanı, fıçılar, çıkrık vinç
	var sx0 := W * 0.5 + 2.0
	for i in 3:
		IstMk.S(root, Vector3(2.4, 0.3 * (i + 1) + 0.1, 1.2), Vector3(sx0, 0.0, -L * 0.35 + i * 1.25), IstMk.WOOD_LT, "wood")
	IstMk.CY(root, 0.55, 0.7, Vector3(sx0 + 0.4, 0.0, -L * 0.1), IstMk.DARK, "", 10, true)
	Flame.add(root, Vector3(sx0 + 0.4, 0.75, -L * 0.1), 0.45, 0.7)
	for i in 4:
		IstMk.CY(root, 0.38, 0.9, Vector3(sx0 - 0.6 + (i % 2) * 0.8, 0.0, L * 0.1 + (i / 2) * 0.8), IstMk.WOOD, "wood", 10, true)
	# vinç: iki dikme, çapraz kiriş, bom, kasnak
	var cx := W * 0.5 + 3.0
	var cz := L * 0.3
	IstMk.S(root, Vector3(0.5, 7.0, 0.5), Vector3(cx, 0.0, cz - 1.0), IstMk.WOOD_DK, "wood")
	IstMk.S(root, Vector3(0.5, 7.0, 0.5), Vector3(cx, 0.0, cz + 1.0), IstMk.WOOD_DK, "wood")
	IstMk.S(root, Vector3(0.4, 0.4, 2.6), Vector3(cx, 7.0, cz), IstMk.WOOD, "wood")
	IstMk.V(root, Vector3(4.5, 0.3, 0.3), Vector3(cx - 2.0, 7.4, cz), IstMk.WOOD, "wood")
	IstMk.V(root, Vector3(0.05, 4.2, 0.05), Vector3(cx - 4.0, 3.2, cz), IstMk.ROPE)
	IstMk.S(root, Vector3(0.6, 0.6, 0.6), Vector3(cx - 4.0, 2.6, cz), IstMk.WOOD_LT, "wood")
	# çıkrık tekerleği (yürüme çarkı): katı disk
	var wh := IstMk.CYR(root, 1.5, 0.5, Vector3(cx + 0.9, 1.5, cz), IstMk.WOOD, Vector3(0, 0, 90), "wood", 12, true)
	# --- mendirek üstü: korkuluk + fener kulesi
	var mx := MW * 0.5 + (W - MW) * 0.5 + MO * 0.5
	var mz := L * 0.5 + Q + 7.0
	IstMk.S(root, Vector3(MO, 1.0, 0.45), Vector3(mx, 0.08, mz + 2.3), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(MO, 0.5, 0.45), Vector3(mx, 0.08, mz - 2.3), IstMk.STONE, "ashlar")
	var tx := mx + MO * 0.5 - 2.0
	IstMk.S(root, Vector3(3.2, 5.0, 3.2), Vector3(tx, 0.08, mz), IstMk.STONE_DK, "ashlar")
	IstMk.S(root, Vector3(3.6, 0.3, 3.6), Vector3(tx, 5.08, mz), IstMk.BRICK, "brick")
	IstMk.S(root, Vector3(3.6, 1.0, 0.4), Vector3(tx, 5.38, mz - 1.6), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(3.6, 1.0, 0.4), Vector3(tx, 5.38, mz + 1.6), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(0.4, 1.0, 2.8), Vector3(tx - 1.6, 5.38, mz), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(0.4, 1.0, 2.8), Vector3(tx + 1.6, 5.38, mz), IstMk.STONE, "ashlar")
	IstMk.CY(root, 0.4, 0.5, Vector3(tx, 5.38, mz), IstMk.DARK, "", 8, true)
	Flame.add(root, Vector3(tx, 5.9, mz), 0.7, 1.1)
	# kule merdiveni (mendirekten dama): 5 m
	IstMk.FLIGHT(root, Vector3(tx - 9.0, 0.08, mz), Vector3(1, 0, 0), 5.3, 1.6, [1.0, -1.0], IstMk.STONE, "ashlar")
	# mendirek kıyısında kaya yığını
	for i in 7:
		IstMk.ROCKB(root, Vector3(mx - MO * 0.5 + rng.randf_range(0.0, MO), -0.9, mz + 3.6 + rng.randf_range(0.0, 2.0)), Vector3(rng.randf_range(0.6, 1.2), 0.5, 0.8), IstMk.ROCK, false)
	# havuz çıkışları: kuzeyde ve güney köşede 2,4 m basamak (suya girenlerin çıkışı)
	# kuzey rıhtımına çıkan basamak: havuz içinde, duvara bitişik
	var f2 := IstMk.FLIGHT(root, Vector3(W * 0.2, FLOOR_Y, -L * 0.5 + 0.0 + 3.8), Vector3(0, 0, -1), 2.48, 2.0, [1.0, -1.0], IstMk.STONE, "ashlar")
	var f3 := IstMk.FLIGHT(root, Vector3(-W * 0.2, FLOOR_Y, -L * 0.5 + 0.0 + 3.8), Vector3(0, 0, -1), 2.48, 2.0, [1.0, -1.0], IstMk.STONE, "ashlar")
	# kuzey rıhtımında: ambar (kadırga ambarı) — kapalı kutu, çatılı, kapı boşluğu
	var wz := -L * 0.5 - Q * 0.5 - 4.0
	IstMk.S(root, Vector3(14.0, 4.2, 7.0), Vector3(-W * 0.25, 0.0, wz - 1.0), IstMk.STONE_DK, "ashlar")
	IstMk.ROOF(root, Vector3(8.0, 2.4, 15.0), Vector3(-W * 0.25, 4.2, wz - 1.0), IstMk.TILE, "tiles", 90.0)
	IstMk.DOOR_DARK(root, Vector3(-W * 0.25, 0.0, wz + 2.55), 3.0, 2.8)


## Zemin çukuru: havuz içi + ağızdan açığa uzanan rampa şeridi (yerel dikdörtgenler: Rect2(x, z, en, boy))
static func pits_kontoskalion(k: float) -> Array:
	var d := kd(k)
	var W: float = d["W"]
	var L: float = d["L"]
	var MW: float = d["MOUTH"]
	return [Rect2(-W * 0.5, -L * 0.5, W, L), Rect2(-MW * 0.5, L * 0.5, MW, Q + 12.0)]


static func perches_kontoskalion(k: float = 0.5) -> Array:
	var d := kd(k)
	var W: float = d["W"]
	var L: float = d["L"]
	var MO: float = d["MOLE"]
	var MW: float = d["MOUTH"]
	var mx := MW * 0.5 + (W - MW) * 0.5 + MO * 0.5
	var mz := L * 0.5 + Q + 7.0
	return [Vector3(mx + MO * 0.5 - 2.0, 5.38, mz - 1.0), Vector3(W * 0.5 + 3.0, 7.4, L * 0.3)]


static func climbs_kontoskalion(k: float = 0.5) -> Array:
	var d := kd(k)
	var W: float = d["W"]
	var L: float = d["L"]
	var MO: float = d["MOLE"]
	var MW: float = d["MOUTH"]
	var mx := MW * 0.5 + (W - MW) * 0.5 + MO * 0.5
	var mz := L * 0.5 + Q + 7.0
	var tx := mx + MO * 0.5 - 2.0
	return [
		[Vector3(tx - 9.8, 0.08, mz), Vector3(tx - 0.7, 5.38, mz), "merdiven"],
		[Vector3(W * 0.2, FLOOR_Y, -L * 0.5 + 4.6), Vector3(W * 0.2, 0.08, -L * 0.5 - 1.5), "merdiven"],
	]


# =============================================================== LANGA ============================================
static func ld(k: float) -> Dictionary:
	return {"W": maxf(90.0 * k, 48.0), "L": maxf(60.0 * k, 36.0)}


static func build_langa(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var d := ld(k)
	var W: float = d["W"]
	var L: float = d["L"]
	var root := IstMk.root(host, "Langa")
	var rng := RandomNumberGenerator.new()
	rng.seed = 1000 + int(k * 100)
	if lod >= 2:
		IstMk.V(root, Vector3(W, 0.05, L), Vector3.ZERO, IstMk.SOIL)
		IstMk.V(root, Vector3(W * 0.3, 0.6, L * 0.5), Vector3(-W * 0.2, 0.05, 0), IstMk.GRASS)
		return
	IstMk.V(root, Vector3(W, 0.03, L), Vector3(0, 0.0, 0), IstMk.SOIL)
	# tarlalar: 4 sıra × n yükseltilmiş sebze tarhı (0,25 m, katı; basamaklıdır, yürünür)
	var rows := 4
	var bw := 6.0
	var gap := 1.6
	var bx0 := -W * 0.5 + 15.0
	var nx := int(floor((W * 0.5 - 4.0 - bx0) / (bw + gap)))
	var xf_cab: Array = []
	var xf_leek: Array = []
	var xf_bean: Array = []
	for r in rows:
		var z := -L * 0.5 + 5.0 + r * ((L - 22.0) / (rows - 1)) if rows > 1 else 0.0
		for i in nx:
			var x := bx0 + bw * 0.5 + i * (bw + gap)
			IstMk.S(root, Vector3(bw, 0.25, 2.4), Vector3(x, 0.0, z), IstMk.SOIL, "")
			if lod >= 1:
				continue
			var kind := (r + i) % 3
			for j in 6:
				var px := x - bw * 0.5 + 0.5 + j * 1.0
				for sz: float in [-0.6, 0.6]:
					match kind:
						0:
							xf_cab.append([Vector3(px, 0.25 + 0.15, z + sz), 0.0])
						1:
							xf_leek.append([Vector3(px, 0.25 + 0.28, z + sz), 0.0])
						_:
							pass
			if kind == 2:
				for j in 4:
					xf_bean.append([Vector3(x - bw * 0.5 + 0.8 + j * 1.4, 0.25 + 0.8, z), 0.0])
	if lod == 0:
		IstMk.MMC(root, 0.2, 0.3, xf_cab, Color("6f9a4a"), 7)
		IstMk.MMC(root, 0.05, 0.56, xf_leek, Color("8ab050"), 5)
		IstMk.MMC(root, 0.04, 1.6, xf_bean, Color("8a6a40"), 5)
		var bean_leaf: Array = []
		for t in xf_bean:
			var p: Vector3 = t[0]
			bean_leaf.append([p + Vector3(0, 0.1, 0), 0.0])
		IstMk.MM(root, Vector3(0.5, 1.2, 0.5), bean_leaf, Color("5f8a3c"))
	# sulama arkları (görsel su şeridi) tarh sıraları arasında
	for r in rows - 1:
		var z := -L * 0.5 + 5.0 + r * ((L - 22.0) / (rows - 1)) + (L - 22.0) / (rows - 1) * 0.5
		IstMk.V(root, Vector3(W - 14.0, 0.04, 0.5), Vector3(0, 0.0, z), Color("4a86a0"))
	# --- dolap (kovalı çıkrık): dik çerçeve, katı çark diski, boru, bir ayrık direk
	var dx := W * 0.5 - 8.0
	var dz := -L * 0.25
	IstMk.S(root, Vector3(0.4, 3.6, 0.4), Vector3(dx - 1.4, 0.0, dz), IstMk.WOOD_DK, "wood")
	IstMk.S(root, Vector3(0.4, 3.6, 0.4), Vector3(dx + 1.4, 0.0, dz), IstMk.WOOD_DK, "wood")
	IstMk.S(root, Vector3(3.4, 0.35, 0.5), Vector3(dx, 3.6, dz), IstMk.WOOD, "wood")
	IstMk.CYR(root, 1.5, 0.3, Vector3(dx, 2.0, dz), IstMk.WOOD_LT, Vector3(90, 0, 0), "wood", 14, true)
	IstMk.CY(root, 0.9, 0.9, Vector3(dx, 0.0, dz + 3.0), IstMk.STONE, "ashlar", 12, true)
	# öküz yürüme yolu: çemberin ortasında direk
	IstMk.CY(root, 0.18, 1.6, Vector3(dx + 4.0, 0.0, dz + 3.0), IstMk.WOOD_DK, "wood", 7, true)
	IstMk.S(root, Vector3(0.18, 0.18, 4.0), Vector3(dx + 4.0, 1.4, dz + 3.0), IstMk.WOOD, "wood")
	# --- kuyular
	for i in 3:
		var wx := -W * 0.5 + 12.0 + i * (W * 0.3)
		var wz := L * 0.5 - 6.0 - (i % 2) * 3.0
		IstMk.CY(root, 0.85, 0.95, Vector3(wx, 0.0, wz), IstMk.STONE, "ashlar", 12, true)
		IstMk.S(root, Vector3(0.18, 2.1, 0.18), Vector3(wx - 1.0, 0.0, wz), IstMk.WOOD_DK, "wood")
		IstMk.S(root, Vector3(0.18, 2.1, 0.18), Vector3(wx + 1.0, 0.0, wz), IstMk.WOOD_DK, "wood")
		IstMk.V(root, Vector3(2.3, 0.14, 0.14), Vector3(wx, 2.1, wz), IstMk.WOOD, "wood")
		IstMk.CYR(root, 0.1, 1.6, Vector3(wx, 1.5, wz), IstMk.WOOD_LT, Vector3(0, 0, 90), "wood", 6)
		IstMk.CY(root, 0.17, 0.3, Vector3(wx + 1.3, 0.0, wz + 0.2), IstMk.WOOD, "wood", 8, true)
	# --- bostancı kulübeleri (ikisi); kulübe 1'in doğu yüzüne 0,4 m'lik kasa basamakları (2,4 m'ye) çıkar
	for i in 2:
		var hx := -W * 0.5 + 6.0 + i * 9.0
		var hz := -L * 0.5 + 3.0
		IstMk.S(root, Vector3(3.4, 2.4, 3.0), Vector3(hx, 0.0, hz), IstMk.STONE_DK, "rubble")
		IstMk.ROOF(root, Vector3(3.0, 1.2, 4.2), Vector3(hx, 2.4, hz), IstMk.THATCH, "", 90.0)
		IstMk.DOOR_DARK(root, Vector3(hx, 0.0, hz - 1.53), 1.0, 2.0)
	var fl := IstMk.FLIGHT(root, Vector3(-W * 0.5 + 6.0, 0.0, -L * 0.5 + 3.0 + 1.5 + 8 * 0.46 + 0.02), Vector3(0, 0, -1), 2.4, 1.4, [], IstMk.WOOD_LT, "wood")
	# --- çit: hasır çit, çevrenin güney ve doğu kenarında
	var fp: Array = []
	for i in int(W / 1.2):
		fp.append([Vector3(-W * 0.5 + 0.5 + i * 1.2, 0.5, L * 0.5 - 0.2), 0.0])
	IstMk.MMC(root, 0.05, 1.0, fp, IstMk.WOOD, 5)
	IstMk.S(root, Vector3(W - 1.0, 0.9, 0.12), Vector3(0, 0.0, L * 0.5 - 0.2), IstMk.THATCH, "wood")
	# --- ağaçlar: incir, nar, selvi (gövde katı, taç görsel + katı hull)
	for i in 8:
		var tx := rng.randf_range(-W * 0.5 + 3.0, W * 0.5 - 3.0)
		var tz := rng.randf_range(-L * 0.5 + 3.0, L * 0.5 - 4.0)
		if absf(tx - dx) < 6.0 and absf(tz - dz) < 6.0:
			continue
		if i % 3 == 0:
			IstMk.CY(root, 0.4, 7.0, Vector3(tx, 0.0, tz), Color("2e5030"), "", 7, true, 0.05)
		else:
			IstMk.CY(root, 0.18, 1.8, Vector3(tx, 0.0, tz), IstMk.WOOD_DK, "wood", 7, true, 0.12)
			var cr := Props.ball(root, 1.7, Vector3(tx, 2.7, tz), Color("5b7d36") if i % 3 == 1 else Color("6d9040"), Vector3(1.2, 0.8, 1.2), 8)
			Props.make_solid(cr, 0.75)
	# --- eski liman izi: batıda yarı gömülü rıhtım taşları ve bağlama halkaları (ay-şekilli sıra)
	for i in 8:
		var a := PI * (0.2 + 0.6 * i / 7.0)
		var px := -W * 0.5 + 2.0 + cos(a) * 3.0
		var pz := sin(a) * (L * 0.45)
		IstMk.S(root, Vector3(1.6, 0.35, 0.9), Vector3(px, 0.0, pz), IstMk.STONE_DK, "ashlar", rad_to_deg(a))
	# gölcük: eski havzanın son suyu (sığ; görsel su ince, çevresi taş)
	var pw := 14.0
	var pl := 8.0
	IstMk.WATER_PLANE(root, Vector2(pw, pl), Vector3(W * 0.5 - 14.0, 0.05, L * 0.5 - 12.0))
	var rg: Array = []
	for i in 22:
		var a := TAU * i / 22.0
		rg.append([Vector3(W * 0.5 - 14.0 + cos(a) * (pw * 0.5 + 0.2), 0.12, L * 0.5 - 12.0 + sin(a) * (pl * 0.5 + 0.2)), rad_to_deg(-a)])
	IstMk.MM(root, Vector3(0.9, 0.25, 0.7), rg, IstMk.ROCK, "rubble")
	# kamışlık
	var reeds: Array = []
	for i in 40:
		reeds.append([Vector3(W * 0.5 - 14.0 + rng.randf_range(-8.0, 8.0), 0.9, L * 0.5 - 12.0 + (4.5 if rng.randf() < 0.5 else -4.5) * rng.randf_range(0.9, 1.3)), 0.0])
	IstMk.MMC(root, 0.025, 1.8, reeds, Color("8a9a4a"), 4)
	IstMk.TUFTS(root, rng, Rect2(-W * 0.5, -L * 0.5, W, L), 90, 0.0, IstMk.GRASS, 0.4)


static func perches_langa(k: float = 0.5) -> Array:
	var d := ld(k)
	var W: float = d["W"]
	var L: float = d["L"]
	return [Vector3(W * 0.5 - 8.0, 3.95, -L * 0.25), Vector3(-W * 0.5 + 6.0, 3.6, -L * 0.5 + 3.0)]


static func climbs_langa(k: float = 0.5) -> Array:
	var d := ld(k)
	var W: float = d["W"]
	var L: float = d["L"]
	return [[Vector3(-W * 0.5 + 6.0, 0.0, -L * 0.5 + 3.0 + 1.5 + 8 * 0.46 + 0.9), Vector3(-W * 0.5 + 6.0, 3.55, -L * 0.5 + 3.0), "sandik"]]


# =========================================================== SOPHIA LİMANI ======================================
static func build_sophia(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var root := IstMk.root(host, "SophiaLimani")
	var W := maxf(60.0 * k, 30.0)
	var L := maxf(40.0 * k, 22.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 911
	if lod >= 2:
		IstMk.S(root, Vector3(W, 2.6, 2.0), Vector3(0, 0, -L * 0.5), IstMk.STONE_DK, "ashlar")
		IstMk.S(root, Vector3(W * 0.5, 1.2, 4.0), Vector3(W * 0.15, 0, L * 0.5), IstMk.ROCK, "rubble")
		return
	# kuzey: yıkık ambar duvarı (kemerli, kırık üst kenar)
	var zN := -L * 0.5
	var xs := -W * 0.5
	var seg := 4.0
	var n := int(W / seg)
	var hs: Array = []
	for i in n:
		hs.append(clampf(3.2 - 0.0 - absf(i - n * 0.3) * 0.0 - rng.randf() * 2.2, 1.0, 3.2))
	for i in n:
		var h: float = hs[i]
		IstMk.S(root, Vector3(seg + 0.02, h, 1.8), Vector3(xs + seg * (i + 0.5), 0.0, zN), IstMk.STONE_DK, "ashlar")
		if lod == 0 and i % 2 == 0 and h > 2.6:
			IstMk.ARCH(root, Vector3(xs + seg * (i + 0.5), 1.9, zN + 0.93), 0.9, 0.35, 0.1, IstMk.BRICK_DK, "brick", 9)
			IstMk.V(root, Vector3(1.8, 1.9, 0.05), Vector3(xs + seg * (i + 0.5), 0.0, zN + 0.91), IstMk.DARK)
	# yıkık deniz kapısı: iki ayak + lento (kapalı katı), geçit 3,6 m
	var gx := W * 0.12
	IstMk.S(root, Vector3(2.4, 5.0, 2.4), Vector3(gx - 3.0, 0.0, L * 0.25), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(2.4, 5.0, 2.4), Vector3(gx + 3.0, 0.0, L * 0.25), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(8.4, 1.4, 2.4), Vector3(gx, 3.6, L * 0.25), IstMk.STONE, "ashlar")
	if lod == 0:
		IstMk.ARCH(root, Vector3(gx, 3.6, L * 0.25 + 1.25), 1.8, 0.45, 0.1, IstMk.MARBLE, "marble", 11)
		IstMk.V(root, Vector3(3.6, 1.8, 0.05), Vector3(gx, 3.6, L * 0.25 + 1.2), IstMk.DARK)
		# çatlak ve yosun
		IstMk.V(root, Vector3(0.1, 2.0, 0.06), Vector3(gx - 3.4, 1.0, L * 0.25 + 1.22), IstMk.DARK)
		IstMk.TUFTS(root, rng, Rect2(gx - 4.0, L * 0.25 - 1.0, 8.0, 2.0), 8, 5.0, IstMk.MOSS, 0.4)
	# basamaklı moloz yığını (dama çıkış): 0,35'lik adımlarla ~2,8 m'ye
	for i in 8:
		var hh := 0.35 * (i + 1)
	var mound_x := -W * 0.5 + 2.0
	for i in 8:
		var hh2 := 0.35 * (i + 1)
		IstMk.S(root, Vector3(1.1, hh2, 3.0), Vector3(mound_x + i * 1.0, 0.0, zN + 2.4), IstMk.ROCK, "rubble")
	# batık rıhtım: su içinde sıra taş + yarı batık sütun gövdeleri
	IstMk.WATER_PLANE(root, Vector2(W * 0.8, L * 0.4), Vector3(0, 0.05, L * 0.1))
	for i in 9:
		IstMk.S(root, Vector3(1.6, 0.3, 1.0), Vector3(-W * 0.4 + i * (W * 0.8 / 8.0), 0.0, L * 0.3 + rng.randf_range(-0.5, 0.5)), IstMk.STONE_DK, "ashlar")
	for i in 5:
		IstMk.CYR(root, 0.34, rng.randf_range(2.0, 3.0), Vector3(rng.randf_range(-W * 0.4, W * 0.4), 0.34, rng.randf_range(-L * 0.1, L * 0.25)), IstMk.MARBLE, Vector3(0, rng.randf_range(0, 180), 90), "marble", 10, true)
	# kırık mendirek kütükleri
	for i in 4:
		IstMk.ROCKB(root, Vector3(W * 0.35 + i * 1.8, 0.0, L * 0.5 - 1.0 - i * 0.6), Vector3(1.4, 0.8, 1.2), IstMk.ROCK, true)
	# batık kayık enkazı
	IstMk.S(root, Vector3(1.2, 0.45, 3.8), Vector3(-W * 0.15, 0.0, L * 0.05), IstMk.WOOD, "wood", 25.0)
	for i in 14:
		IstMk.ROCKB(root, Vector3(rng.randf_range(-W * 0.5, W * 0.5), 0.0, rng.randf_range(-L * 0.3, L * 0.5)), Vector3(rng.randf_range(0.3, 0.6), 0.25, 0.4), IstMk.ROCK, false)
	var reeds: Array = []
	for i in 30:
		reeds.append([Vector3(rng.randf_range(-W * 0.4, W * 0.4), 0.9, L * 0.4 + rng.randf_range(-1.0, 1.0) - L * 0.2), 0.0])
	IstMk.MMC(root, 0.025, 1.8, reeds, Color("8a9a4a"), 4)
	IstMk.TUFTS(root, rng, Rect2(-W * 0.5, -L * 0.5, W, L), 60, 0.0, IstMk.GRASS, 0.4)


static func perches_sophia(k: float = 0.5) -> Array:
	var W := maxf(60.0 * k, 30.0)
	var L := maxf(40.0 * k, 22.0)
	return [Vector3(W * 0.12, 4.3, L * 0.25), Vector3(-W * 0.5 + 2.0, 3.2, -L * 0.5)]


static func climbs_sophia(k: float = 0.5) -> Array:
	var W := maxf(60.0 * k, 30.0)
	var L := maxf(40.0 * k, 22.0)
	var mx := -W * 0.5 + 2.0
	return [[Vector3(mx - 0.5, 0.0, -L * 0.5 + 2.4), Vector3(mx + 7.0, 2.8, -L * 0.5 + 2.4), "basamak"]]
