class_name IstSurlar
extends RefCounted
## İstanbul, Nisan 1453: Theodosius kara surları (iç sur, peribolos, dış sur, parateikhion, hendek) ve kapıları.
##
## YEREL ÇERÇEVE (bütün öğelerde aynı): sur boyunca eksen = yerel +x; dış yüz (ova, hendek) = +z; şehir = -z.
## z = 0 iç surun kalınlığının ortası; zemin y = 0. `yon_derece` = yerel +x ekseninin kuzeyden saat yönü açısıdır
## (sur güneyden kuzeye gidiyorsa +x güneye bakar; dış yüz batıya düşer). Şehir kurucusu host'u bu açıyla döndürür.
## Kesit (k = 1, metre): şehir tarafı → iç sur 5 kalın / 12 yüksek, kuleler 9 × 6 çıkıntı / 19 → peribolos 15 → dış sur
## 2,5 kalın / 8,5 yüksek, kuleler 4,5 × 4 / 13 → parateikhion terası 10 + alçak sur → hendek 20 geniş / 6 derin.
## Kapılar kendi dosyalarında (IstSurlarKapi); Nisan 1453 izleri IstSurlarAyrinti'da.
##
## ÖLÇEK: k yalnız kütleyi ölçekler. İnsan ölçüsü sabit: kapı ≥ 2,3 m, basamak ≤ 0,28 m, korkuluk 1,2 m, yürüme yolu
## ≥ 1,7 m. Bu yüzden k küçükken kalınlıklar ve sur boyu alt sınırlara oturur (dims()).

const C_STONE := Color("cdbd9e")
const C_BRICK := Color("96503a")
const C_MARBLE := Color("e6dfcf")
const C_WOOD := Color("7a5634")
const C_TILE := Color("b4532f")
const C_EARTH := Color("7a6a4c")
const C_GRASS := Color("6a7b3c")
const C_DARK := Color("1c1814")

const PARAPET_H := 1.2
const PARAPET_T := 0.45
const STEP_RISE := 0.26
const SPAN_NAME := "IstSurlar"


# ------------------------------------------------------------------ ölçüler

static func dims(k: float) -> Dictionary:
	var d := {}
	d["k"] = k
	d["T"] = maxf(5.0 * k, 3.0)             # iç sur kalınlığı
	d["OH"] = maxf(8.5 * k, 3.6)            # dış sur yüksekliği
	d["HW"] = maxf(12.0 * k, d["OH"] + 2.4) # iç sur yüksekliği
	d["TW"] = maxf(9.0 * k, 4.4)            # iç kule eni
	d["TP"] = maxf(6.0 * k, 3.0)            # iç kule çıkıntısı
	d["HT"] = maxf(19.0 * k, d["HW"] + 3.4) # iç kule tepesi
	d["PW"] = maxf(15.0 * k, 6.8)           # peribolos eni
	d["OT"] = maxf(2.5 * k, 2.6)            # dış sur kalınlığı
	d["OTW"] = maxf(4.5 * k, 3.2)
	d["OTP"] = maxf(4.0 * k, 2.0)
	d["OTH"] = d["OH"] + maxf(4.5 * k, 1.6)
	d["PTW"] = maxf(10.0 * k, 6.0)          # dış surdan hendek ağzına teras
	d["MW"] = maxf(20.0 * k, 7.0)           # hendek eni
	d["MD"] = maxf(6.0 * k, 3.0)            # hendek derinliği
	d["S"] = maxf(55.0 * k, 22.0)           # kule aralığı
	d["zi0"] = -d["T"] * 0.5
	d["zi1"] = d["T"] * 0.5
	d["zo0"] = d["zi1"] + d["PW"]
	d["zo1"] = d["zo0"] + d["OT"]
	d["zm0"] = d["zo1"] + d["PTW"]
	d["zm1"] = d["zm0"] + d["MW"]
	return d


## Hendeğin kapladığı alan (yerel): şehir zemini bu şeridi oymalıdır. [z0, z1] ve derinlik.
static func moat_strip(k: float) -> Dictionary:
	var d := dims(k)
	return {"z0": d["zm0"] - 0.9, "z1": d["zm1"] + 0.9, "derinlik": d["MD"]}


# ------------------------------------------------------------------ yerleşim (build, perches ve climbs ortak)

static func _layout(L: float, k: float, seed: int, o: Dictionary) -> Dictionary:
	var d := dims(k)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var S: float = d["S"]
	var n := maxi(2, roundi(L / S))
	var step := L / n
	var gw: float = o.get("gw", 0.0)
	var bw: float = d["TW"] * float(o.get("bigw", 1.3))
	var bp: float = d["TP"] * float(o.get("bigp", 1.2))
	var gx := gw * 0.5 + bw * 0.5 + 0.9
	var itx: Array = []
	for i in n:
		var x := -L * 0.5 + step * (i + 0.5) + rng.randf_range(-0.08, 0.08) * step
		if gw > 0.0 and absf(x) < gx + step * 0.45:
			continue
		itx.append({"x": x, "w": d["TW"], "p": d["TP"]})
	if gw > 0.0:
		itx.append({"x": -gx, "w": bw, "p": bp})
		itx.append({"x": gx, "w": bw, "p": bp})
	itx.sort_custom(func(a, b): return a["x"] < b["x"])
	var otx: Array = []
	for i in range(itx.size() - 1):
		var xm: float = 0.5 * (float(itx[i]["x"]) + float(itx[i + 1]["x"]))
		if gw > 0.0 and absf(xm) < gx + float(d["OTW"]):
			continue
		otx.append(xm)
	var lay := {"d": d, "L": L, "itx": itx, "otx": otx, "gw": gw, "gx": gx, "rng_seed": seed}
	# Şehir tarafı iç merdiven: kapıyı içermeyen ilk boşluk
	var HW: float = d["HW"]
	var n_in := ceili(HW / STEP_RISE)
	lay["in_n"] = n_in
	for i in range(itx.size() - 1):
		var a: float = float(itx[i]["x"]) + float(itx[i]["w"]) * 0.5 + 1.0
		var b: float = float(itx[i + 1]["x"]) - float(itx[i + 1]["w"]) * 0.5 - 3.0
		if gw > 0.0 and a < 0.0 and b > 0.0:
			continue
		if b - a < n_in * 0.28:
			continue
		var tread := clampf((b - a) / n_in, 0.28, 0.42)
		lay["in_x0"] = a
		lay["in_tread"] = tread
		lay["in_x1"] = a + tread * n_in
		break
	# Peribolostan dış sur üstüne merdiven: iki dış kule arasının ortasında biter
	var OH: float = d["OH"]
	var n_out := ceili(OH / STEP_RISE)
	lay["out_n"] = n_out
	var ban: float = gw * 0.5 + 1.8 if gw > 0.0 else -1.0
	for i in range(otx.size() - 1):
		var xe: float = 0.5 * (float(otx[i]) + float(otx[i + 1]))
		var xs: float = xe - 0.42 * n_out
		if gw > 0.0 and xs < ban and xe + 1.0 > -ban:
			continue
		lay["out_x1"] = xe
		lay["out_x0"] = xs
		lay["out_tread"] = 0.42
		break
	if not lay.has("out_x1") and otx.size() > 0:
		var xe2: float = float(otx[otx.size() - 1]) + float(d["OTW"]) * 0.5 + ceili(float(d["OTH"] - d["OH"]) / STEP_RISE) * 0.42 + 2.5
		lay["out_x1"] = xe2
		lay["out_x0"] = xe2 - 0.42 * n_out
		lay["out_tread"] = 0.42
	# Hendek rampaları: yakın yaka (+x'e yükselir) ve uzak yaka (-x'e yükselir)
	var MD: float = d["MD"]
	lay["ramp_len"] = MD / 0.36
	lay["ramp_a_x"] = -L * 0.32 + (L * 0.0)
	lay["ramp_b_x"] = L * 0.32
	return lay


# ------------------------------------------------------------------ küçük yardımcılar

static func _s(p: Node3D, lo: Vector3, hi: Vector3, col: Color, pat := "ashlar", lod := 0, nc := false) -> Node3D:
	var size := hi - lo
	if size.x < 0.001 or size.y < 0.001 or size.z < 0.001:
		return null
	var pos := (lo + hi) * 0.5
	if lod <= 1:
		var b := Props.solid(p, size, pos, Color.WHITE)
		Props.set_pattern(b, col, pat)
		if nc:
			b.set_meta("no_climb", true)
		return b
	var m := Props.box(p, size, pos, col)
	m.material_override = Props.mat(col, 0.0, false, "ashlar_far" if pat == "ashlar" else pat)
	return m


## Yalnız görünen (çarpışmasız) ince ayrıntı
static func _d(p: Node3D, lo: Vector3, hi: Vector3, col: Color, pat := "") -> MeshInstance3D:
	var size := hi - lo
	if size.x < 0.001 or size.y < 0.001 or size.z < 0.001:
		return null
	var m := Props.box(p, size, (lo + hi) * 0.5, col)
	if pat != "":
		m.material_override = Props.mat(col, 0.0, false, pat)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return m


## Köşegen kama (yükselen eğim, katı). Taban merkezi `base`, +x yönünde (yaw ile döner) `rise` kadar yükselir.
static func _wedge(p: Node3D, base: Vector3, length: float, rise: float, width: float, yaw_deg: float, col: Color, pat := "ashlar") -> MeshInstance3D:
	var pm := PrismMesh.new()
	pm.left_to_right = 1.0
	pm.size = Vector3(length, rise, width)
	var mi := MeshInstance3D.new()
	mi.mesh = pm
	mi.material_override = Props.mat(col, 0.0, false, pat)
	mi.position = base + Vector3(0, rise * 0.5, 0)
	mi.rotation_degrees = Vector3(0, yaw_deg, 0)
	p.add_child(mi)
	Props.make_solid(mi)
	return mi


## x boyunca merdiven: a = ilk basamağın başlangıç noktası (zemin y), yön dir (+1/-1), her basamak tread uzun.
## Dolgu kama + üstte basamak blokları (görünüm). zc = z ortası, w = genişlik. Son basamağın üstü = y0 + rise.
static func _stairs_x(p: Node3D, x0: float, dir: float, zc: float, w: float, y0: float, rise: float, n: int, tread: float, col: Color, lod := 0) -> void:
	if n <= 0:
		return
	var h := rise / n
	var length := tread * n
	var cx := x0 + dir * length * 0.5
	if lod <= 1:
		var yaw := 0.0 if dir > 0.0 else 180.0
		_wedge(p, Vector3(cx, y0, zc), length - 0.02, rise - 0.02, w - 0.04, yaw, col.darkened(0.12))
	for i in n:
		var top := y0 + h * (i + 1)
		var xa := x0 + dir * tread * i
		var xb := x0 + dir * tread * (i + 1)
		var lo := Vector3(minf(xa, xb), top - h, zc - w * 0.5)
		var hi := Vector3(maxf(xa, xb), top, zc + w * 0.5)
		_s(p, lo, hi, col, "flagstone", lod)


static func _segs(x0: float, x1: float, cut: Array) -> Array:
	## [x0,x1] aralığından cut ([[a,b], …]) aralıklarını çıkarır
	var segs: Array = [[x0, x1]]
	for c in cut:
		var ca: float = c[0]
		var cb: float = c[1]
		var out: Array = []
		for s in segs:
			var sa: float = s[0]
			var sb: float = s[1]
			if cb <= sa or ca >= sb:
				out.append(s)
				continue
			if ca > sa:
				out.append([sa, ca])
			if cb < sb:
				out.append([cb, sb])
		segs = out
	return segs


## Korkuluk: katı alçak duvar + (lod 0) üstünde mazgal çıkıntıları (MultiMesh listesine)
static func _parapet_x(p: Node3D, x0: float, x1: float, z: float, y: float, col: Color, lod: int, mer: Array) -> void:
	if x1 - x0 < 0.3:
		return
	_s(p, Vector3(x0, y, z - PARAPET_T * 0.5), Vector3(x1, y + PARAPET_H, z + PARAPET_T * 0.5), col, "ashlar", lod)
	if lod == 0:
		var m := floori((x1 - x0) / 1.6)
		var off := ((x1 - x0) - m * 1.6) * 0.5
		for i in m:
			mer.append(Transform3D(Basis.from_scale(Vector3(0.9, 0.55, PARAPET_T)), Vector3(x0 + off + 0.8 + i * 1.6, y + PARAPET_H + 0.255, z)))


static func _parapet_z(p: Node3D, z0: float, z1: float, x: float, y: float, col: Color, lod: int, mer: Array) -> void:
	if z1 - z0 < 0.3:
		return
	_s(p, Vector3(x - PARAPET_T * 0.5, y, z0), Vector3(x + PARAPET_T * 0.5, y + PARAPET_H, z1), col, "ashlar", lod)
	if lod == 0:
		var m := floori((z1 - z0) / 1.6)
		var off := ((z1 - z0) - m * 1.6) * 0.5
		for i in m:
			mer.append(Transform3D(Basis.from_scale(Vector3(PARAPET_T, 0.55, 0.9)), Vector3(x, y + PARAPET_H + 0.255, z0 + off + 0.8 + i * 1.6)))


## Tepe çevresi korkuluğu; gap_x: x kenarlarında ortada bırakılan geçit (merdivenin indiği yer) [genişlik] ya da 0
static func _roof_ring(p: Node3D, x0: float, x1: float, z0: float, z1: float, y: float, col: Color, lod: int, mer: Array, gap := 0.0, gz := -1e9) -> void:
	var t := PARAPET_T * 0.5
	_parapet_x(p, x0, x1, z0 + t, y, col, lod, mer)
	_parapet_x(p, x0, x1, z1 - t, y, col, lod, mer)
	var zm := (z0 + z1) * 0.5 if gz < -1e8 else gz
	if gap > 0.0:
		_parapet_z(p, z0 + PARAPET_T, zm - gap * 0.5, x0 + t, y, col, lod, mer)
		_parapet_z(p, zm + gap * 0.5, z1 - PARAPET_T, x0 + t, y, col, lod, mer)
		_parapet_z(p, z0 + PARAPET_T, zm - gap * 0.5, x1 - t, y, col, lod, mer)
		_parapet_z(p, zm + gap * 0.5, z1 - PARAPET_T, x1 - t, y, col, lod, mer)
	else:
		_parapet_z(p, z0 + PARAPET_T, z1 - PARAPET_T, x0 + t, y, col, lod, mer)
		_parapet_z(p, z0 + PARAPET_T, z1 - PARAPET_T, x1 - t, y, col, lod, mer)


# ------------------------------------------------------------------ kuleler

static func _inner_tower(p: Node3D, d: Dictionary, tw: Dictionary, lod: int, mer: Array, o: Dictionary) -> void:
	var cx: float = tw["x"]
	var w: float = tw["w"]
	var proj: float = tw["p"]
	var T: float = d["T"]
	var HW: float = d["HW"]
	var HT: float = d["HT"]
	var x0 := cx - w * 0.5
	var x1 := cx + w * 0.5
	var zb := -T * 0.5 - 0.15
	var zf: float = T * 0.5 + proj
	var yf := HW + 0.03
	var stone: Color = o.get("tas", C_STONE)
	# Kütle (taban döşeme yüksekliğine kadar), eteğinde hafif eğik kaide
	_s(p, Vector3(x0, 0, zb), Vector3(x1, yf, zf), stone.darkened(0.03), "ashlar", lod, true)
	if lod == 2:
		_s(p, Vector3(x0, yf, zb), Vector3(x1, HT, zf), stone, "ashlar", lod)
		return
	if lod == 1:
		_s(p, Vector3(x0, yf, zb), Vector3(x1, HT, zf), stone, "ashlar", lod)
		return
	_s(p, Vector3(x0 - 0.25, 0, zb - 0.25), Vector3(x1 + 0.25, 0.9, zf + 0.25), stone.darkened(0.12), "ashlar", lod, false)
	# Oda: dört duvar (yan duvarlarda kapı), tavan/çatı levhası
	var wt := 0.7
	var yc := HT - 0.5
	_s(p, Vector3(x0, yf, zf - wt), Vector3(x1, yc, zf), stone, "ashlar", lod)          # ön
	_s(p, Vector3(x0, yf, zb), Vector3(x1, yc, zb + wt), stone, "ashlar", lod)          # arka
	var dz0 := -0.9
	var dz1 := 0.9
	var door_h := 2.4
	for sx in [0, 1]:
		var xa: float = x0 if sx == 0 else x1 - wt
		var xb: float = x0 + wt if sx == 0 else x1
		var za := zb + wt
		var zz := zf - wt
		if dz0 - za > 0.3:
			_s(p, Vector3(xa, yf, za), Vector3(xb, yc, dz0), stone, "ashlar", lod)
		else:
			dz0 = za
		if zz - dz1 > 0.3:
			_s(p, Vector3(xa, yf, dz1), Vector3(xb, yc, zz), stone, "ashlar", lod)
		_s(p, Vector3(xa, yf + door_h, dz0), Vector3(xb, yc, dz1), stone, "ashlar", lod)
		# kapı lento ve kemer süsü (tuğla)
		var fx := xa - 0.03 if sx == 0 else xb + 0.03
		var fx2 := xa if sx == 0 else xb
		_d(p, Vector3(minf(fx, fx2), yf + door_h - 0.05, dz0 - 0.2), Vector3(maxf(fx, fx2), yf + door_h + 0.3, dz1 + 0.2), C_BRICK, "brick")
	# Çatı levhası
	_s(p, Vector3(x0 - 0.15, yc, zb - 0.1), Vector3(x1 + 0.15, HT, zf + 0.15), stone.lightened(0.04), "ashlar", lod)
	_roof_ring(p, x0 - 0.15, x1 + 0.15, zb - 0.1, zf + 0.15, HT, stone.darkened(0.04), lod, mer)
	# Süs: tuğla kuşağı, ok yarıkları, konsol sırası (Alman sur kulelerindeki gibi)
	var yb := HW * 0.55
	_d(p, Vector3(x0 - 0.04, yb, zf + 0.0), Vector3(x1 + 0.04, yb + 0.22, zf + 0.04), C_BRICK, "brick")
	_d(p, Vector3(x0 - 0.04, yb, zb - 0.04), Vector3(x1 + 0.04, yb + 0.22, zb + 0.0), C_BRICK, "brick")
	for sx2 in [x0 - 0.04, x1]:
		_d(p, Vector3(sx2, yb, zb), Vector3(sx2 + 0.04, yb + 0.22, zf), C_BRICK, "brick")
	for i in 3:
		var sx3 := cx - w * 0.25 + i * w * 0.25
		_d(p, Vector3(sx3 - 0.08, 2.6, zf), Vector3(sx3 + 0.08, 3.8, zf + 0.05), C_DARK)
		_d(p, Vector3(sx3 - 0.08, HW * 0.5 + 1.2, zf), Vector3(sx3 + 0.08, HW * 0.5 + 2.4, zf + 0.05), C_DARK)
		_d(p, Vector3(sx3 - 0.14, yf + 1.1, zf - wt - 0.0), Vector3(sx3 + 0.14, yf + 2.0, zf - wt + 0.03), C_DARK)
	# üst oda ön yüzünde kemerli pencere (kör) ve konsol sırası
	var m := floori(w / 0.9)
	for i in m:
		var kx := x0 + 0.45 + i * ((w - 0.9) / maxf(1.0, m - 1))
		_d(p, Vector3(kx - 0.2, yf - 0.55, zf), Vector3(kx + 0.2, yf, zf + 0.35), stone.darkened(0.3))
	# şehir yüzünde kör kapı (kule tabanı)
	_d(p, Vector3(cx - 0.8, 0, zb - 0.04), Vector3(cx + 0.8, 2.3, zb), C_DARK)
	_d(p, Vector3(cx - 1.0, 2.3, zb - 0.05), Vector3(cx + 1.0, 2.65, zb), C_BRICK, "brick")


static func _outer_tower(p: Node3D, d: Dictionary, cx: float, lod: int, mer: Array, o: Dictionary) -> void:
	var w: float = d["OTW"]
	var zo0: float = d["zo0"]
	var zo1: float = d["zo1"]
	var OTP: float = d["OTP"]
	var OTH: float = d["OTH"]
	var OH: float = d["OH"]
	var stone: Color = o.get("tas", C_STONE).darkened(0.04)
	var x0 := cx - w * 0.5
	var x1 := cx + w * 0.5
	var zf := zo1 + OTP
	_s(p, Vector3(x0, 0, zo0), Vector3(x1, OTH, zf), stone, "ashlar", lod, true)
	if lod >= 1:
		return
	_s(p, Vector3(x0 - 0.2, 0, zo0 - 0.0), Vector3(x1 + 0.2, 0.7, zf + 0.2), stone.darkened(0.12), "ashlar", lod)
	_roof_ring(p, x0, x1, zo0 - 0.0, zf, OTH, stone, lod, mer, 1.8, (zo0 + zo1) * 0.5)
	# Tuğla bant ve ok yarıkları
	_d(p, Vector3(x0 - 0.04, OH * 0.5, zf), Vector3(x1 + 0.04, OH * 0.5 + 0.2, zf + 0.04), C_BRICK, "brick")
	for i in 2:
		var sx := cx - w * 0.2 + i * w * 0.4
		_d(p, Vector3(sx - 0.07, OH * 0.35, zf), Vector3(sx + 0.07, OH * 0.35 + 1.0, zf + 0.05), C_DARK)
		_d(p, Vector3(sx - 0.07, OH * 0.75, zf), Vector3(sx + 0.07, OH * 0.75 + 0.9, zf + 0.05), C_DARK)


# ------------------------------------------------------------------ sur dilimi

static func _run(host: Node3D, L: float, k: float, lod: int, seed: int, o: Dictionary) -> Node3D:
	var lay := _layout(L, k, seed, o)
	var d: Dictionary = lay["d"]
	var root := Node3D.new()
	root.name = String(o.get("ad", "IstSurlar"))
	host.add_child(root)
	var T: float = d["T"]
	var HW: float = d["HW"]
	var OH: float = d["OH"]
	var OT: float = d["OT"]
	var zi0: float = d["zi0"]
	var zi1: float = d["zi1"]
	var zo0: float = d["zo0"]
	var zo1: float = d["zo1"]
	var zm0: float = d["zm0"]
	var zm1: float = d["zm1"]
	var MD: float = d["MD"]
	var PTW: float = d["PTW"]
	var gw: float = lay["gw"]
	var gh: float = minf(float(o.get("gh", 3.6)), OH - 1.0)
	o = o.duplicate()
	o["gh"] = gh
	var closed: bool = bool(o.get("kapali", false))
	var open_gate := gw > 0.0 and not closed
	var stone: Color = o.get("tas", C_STONE)
	var mer: Array = []
	var x0 := -L * 0.5
	var x1 := L * 0.5
	var apr := 12.0
	# ---- zemin: şehir önü kaldırımı, sur altı, peribolos, dış sur altı, teras
	_s(root, Vector3(x0, -1.5, zi0 - apr), Vector3(x1, 0, zi0), Color("8a7a60"), "cobble", lod)
	_s(root, Vector3(x0, -1.5, zi0), Vector3(x1, 0, zi1), stone.darkened(0.2), "dirt", lod)
	_s(root, Vector3(x0, -1.5, zi1), Vector3(x1, 0, zo0), C_EARTH, "dirt", lod)
	_s(root, Vector3(x0, -1.5, zo0), Vector3(x1, 0, zo1), stone.darkened(0.2), "dirt", lod)
	_s(root, Vector3(x0, -1.5, zo1), Vector3(x1, 0, zm0 - 0.9), C_GRASS.darkened(0.1), "dirt", lod)
	# ---- hendek
	if o.get("hendek", true):
		_build_moat(root, lay, lod, stone, open_gate, mer, o)
	else:
		_s(root, Vector3(x0, -1.5, zm0 - 0.9), Vector3(x1, 0, zm0 + 12.0), C_GRASS.darkened(0.1), "dirt", lod)
	# ---- iç sur (kapı boşluğu varsa kesilir)
	var in_cut: Array = []
	if open_gate:
		in_cut.append([-gw * 0.5, gw * 0.5])
	for s in _segs(x0, x1, in_cut):
		_s(root, Vector3(s[0], 0, zi0), Vector3(s[1], HW, zi1), stone, "ashlar", lod, true)
	if open_gate:
		_s(root, Vector3(-gw * 0.5, gh, zi0), Vector3(gw * 0.5, HW, zi1), stone, "ashlar", lod, true)
	elif gw > 0.0:
		_s(root, Vector3(-gw * 0.5, 0, zi0), Vector3(gw * 0.5, HW, zi1), stone, "ashlar", lod, true)
	# ---- dış sur
	var out_cut: Array = []
	if open_gate:
		out_cut.append([-gw * 0.5, gw * 0.5])
	for s in _segs(x0, x1, out_cut):
		_s(root, Vector3(s[0], 0, zo0), Vector3(s[1], OH, zo1), stone.darkened(0.04), "ashlar", lod, true)
	if open_gate:
		_s(root, Vector3(-gw * 0.5, gh, zo0), Vector3(gw * 0.5, OH, zo1), stone.darkened(0.04), "ashlar", lod, true)
	# ---- kuleler
	var itx: Array = lay["itx"]
	var otx: Array = lay["otx"]
	for tw in itx:
		_inner_tower(root, d, tw, lod, mer, o)
	for cx in otx:
		_outer_tower(root, d, float(cx), lod, mer, o)
	# ---- iç sur üstü: korkuluklar (kule aralarında)
	if lod == 0:
		var tcut: Array = []
		for tw in itx:
			tcut.append([float(tw["x"]) - float(tw["w"]) * 0.5, float(tw["x"]) + float(tw["w"]) * 0.5])
		var city_cut := tcut.duplicate()
		if lay.has("in_x1"):
			city_cut.append([float(lay["in_x1"]) - float(lay["in_tread"]) - 0.4, float(lay["in_x1"]) + 1.4])
		for s in _segs(x0, x1, city_cut):
			_parapet_x(root, s[0], s[1], zi0 + PARAPET_T * 0.5, HW, stone.darkened(0.03), lod, mer)
		for s in _segs(x0, x1, tcut):
			_parapet_x(root, s[0], s[1], zi1 - PARAPET_T * 0.5, HW, stone.darkened(0.03), lod, mer)
		# ---- dış sur üstü: korkuluklar; merdivenle kule tepelerine çıkış
		var ocut: Array = []
		var lt := ceili(float(d["OTH"] - OH) / STEP_RISE)
		var ltread := 0.42
		for cx2 in otx:
			ocut.append([float(cx2) - float(d["OTW"]) * 0.5, float(cx2) + float(d["OTW"]) * 0.5])
		var o_cut2 := ocut.duplicate()
		if lay.has("out_x1"):
			o_cut2.append([float(lay["out_x1"]) - 0.5, float(lay["out_x1"]) + 1.0])
		if open_gate:
			o_cut2.append([-gw * 0.5, gw * 0.5])
		for s in _segs(x0, x1, ocut + ([[-gw * 0.5, gw * 0.5]] if open_gate else [])):
			_parapet_x(root, s[0], s[1], zo1 - PARAPET_T * 0.5, OH, stone.darkened(0.06), lod, mer)
		for s in _segs(x0, x1, o_cut2):
			_parapet_x(root, s[0], s[1], zo0 + PARAPET_T * 0.5, OH, stone.darkened(0.06), lod, mer)
		for cx3 in otx:
			var ow: float = d["OTW"]
			var zc := (zo0 + zo1) * 0.5
			var wz: float = OT - 2.0 * PARAPET_T
			var rise: float = d["OTH"] - OH
			_stairs_x(root, float(cx3) - ow * 0.5 - lt * ltread, 1.0, zc, wz, OH, rise, lt, ltread, stone.lightened(0.05), lod)
			_stairs_x(root, float(cx3) + ow * 0.5 + lt * ltread, -1.0, zc, wz, OH, rise, lt, ltread, stone.lightened(0.05), lod)
	# ---- merdivenler: şehirden iç sur üstüne, peribolostan dış sur üstüne
	if lod <= 1:
		if lay.has("in_x0"):
			var n_in: int = lay["in_n"]
			_stairs_x(root, float(lay["in_x0"]), 1.0, zi0 - 0.9, 1.8, 0.0, HW, n_in, float(lay["in_tread"]), stone.lightened(0.06), lod)
			# üst sahanlık: duvar kenarına yaslı, duvar üstüyle aynı yükseklik
			_s(root, Vector3(float(lay["in_x1"]), 0, zi0 - 1.8), Vector3(float(lay["in_x1"]) + 1.4, HW, zi0), stone.lightened(0.06), "flagstone", lod)
		if lay.has("out_x0"):
			var n_out: int = lay["out_n"]
			_stairs_x(root, float(lay["out_x0"]), 1.0, zo0 - 0.9, 1.8, 0.0, OH, n_out, 0.42, stone.lightened(0.06), lod)
			_s(root, Vector3(float(lay["out_x1"]), 0, zo0 - 1.8), Vector3(float(lay["out_x1"]) + 1.0, OH, zo0), stone.lightened(0.06), "flagstone", lod)
	# ---- mazgallar (tek MultiMesh)
	if lod == 0 and mer.size() > 0:
		Scenery.scatter(root, Scenery._boxm(Vector3.ONE), mer, [], Props.mat(stone.darkened(0.06), 0.0, false, "ashlar"))
	# ---- kapı ve ayrıntı
	if gw > 0.0:
		IstSurlarKapi.build(root, lay, lod, o)
	if lod == 0:
		IstSurlarAyrinti.build(root, lay, o)
	elif lod == 1:
		pass
	return root


static func _build_moat(root: Node3D, lay: Dictionary, lod: int, stone: Color, open_gate: bool, mer: Array, o: Dictionary) -> void:
	var d: Dictionary = lay["d"]
	var L: float = lay["L"]
	var x0 := -L * 0.5
	var x1 := L * 0.5
	var zm0: float = d["zm0"]
	var zm1: float = d["zm1"]
	var MD: float = d["MD"]
	var gw: float = lay["gw"]
	var scarp := stone.darkened(0.18)
	# yakın yaka istinat duvarı ve hendek dibi, karşı yaka duvarı, ova
	_s(root, Vector3(x0, -MD - 0.4, zm0 - 0.9), Vector3(x1, 0, zm0), scarp, "ashlar", lod, true)
	_s(root, Vector3(x0, -MD - 1.2, zm0), Vector3(x1, -MD, zm1), Color("4a4436"), "dirt", lod)
	_s(root, Vector3(x0, -MD - 0.4, zm1), Vector3(x1, 0, zm1 + 0.9), scarp, "ashlar", lod, true)
	_s(root, Vector3(x0, -1.5, zm1 + 0.9), Vector3(x1, 0, zm1 + 14.0), C_GRASS.darkened(0.15), "dirt", lod)
	# parateikhion: terasın ucunda alçak sur; rampa başında ve kapı önünde geçit
	var pcut: Array = [[float(lay["ramp_a_x"]) - 2.2, float(lay["ramp_a_x"]) + 1.2]]
	if gw > 0.0:
		pcut.append([-gw * 0.5 - 1.2, gw * 0.5 + 1.2])
	for sg in _segs(x0, x1, pcut):
		_s(root, Vector3(sg[0], 0, zm0 - 1.8), Vector3(sg[1], 1.6, zm0 - 0.9), stone.darkened(0.08), "ashlar", lod, true)
		if lod == 0 and sg[1] - sg[0] > 1.0:
			_d(root, Vector3(sg[0], 1.6, zm0 - 1.75), Vector3(sg[1], 1.72, zm0 - 0.95), stone.darkened(0.04))
	# uç dolguları (tam yükseklik): hendek bölmesi/geçit
	var cw := 3.0
	_s(root, Vector3(x0, -MD, zm0), Vector3(x0 + cw, 0, zm1), scarp.lightened(0.04), "ashlar", lod, true)
	_s(root, Vector3(x1 - cw, -MD, zm0), Vector3(x1, 0, zm1), scarp.lightened(0.04), "ashlar", lod, true)
	# kapı geçidi (toprak-taş set) ya da kapalı kapıda hendek bölmesi
	if gw > 0.0:
		var half := gw * 0.5 + 1.2
		_s(root, Vector3(-half, -MD, zm0), Vector3(half, 0, zm1), stone.darkened(0.1), "ashlar", lod, true)
	if lod >= 2:
		return
	# rampalar: yakın yakadan dibe, dipten karşı yakaya
	var ramp_len: float = lay["ramp_len"]
	var ax: float = lay["ramp_a_x"]
	var bx: float = lay["ramp_b_x"]
	_wedge(root, Vector3(ax - ramp_len * 0.5, -MD, zm0 + 1.3), ramp_len, MD, 2.6, 0.0, stone.darkened(0.1))
	_wedge(root, Vector3(bx + ramp_len * 0.5, -MD, zm1 - 1.3), ramp_len, MD, 2.6, 180.0, stone.darkened(0.1))
	# su birikintisi (yalnız görünüm)
	_d(root, Vector3(x0 + cw, -MD + 0.0, zm0 + 1.0), Vector3(x1 - cw, -MD + 0.04, zm1 - 1.0), Color("3a4a4a"))


# ------------------------------------------------------------------ KAYIT

## Gerçek konumlar: CityGeo.ANCHORS (romanos, pege, golden_gate, harisios) ve aralarındaki doğrusal kestirimler.
static func catalog() -> Array:
	var bearing := func(a: Vector2, b: Vector2) -> float:
		# a'dan b'ye giden hattın (güneyden kuzeye gidiş) tersi: +x ekseni güneye bakar
		var v := b - a
		var br := rad_to_deg(atan2(v.x, v.y))
		return fposmod(br + 180.0, 360.0)
	var gg := Vector2(-4838.49, -1636.40)
	var pg := Vector2(-5241.70, -434.15)
	var rm := Vector2(-4939.29, 1113.20)
	var hz := Vector2(-3771.67, 2337.72)
	var yon_s: float = bearing.call(gg, pg)
	var yon_m: float = bearing.call(pg, rm)
	var yon_k: float = bearing.call(rm, hz)
	var out: Array = []
	out.append(_cat("sur", "Theodosius kara surları (hat)", pg.x, pg.y + 300.0, Vector3(50.0, 19.0, 5700.0), yon_m, "saglam", "sur", Vector3(0, 28.0, 0), 60.0, true))
	out.append(_cat("altin_kapi", "Altın Kapı (Chryseia Pyle)", gg.x, gg.y, Vector3(44.0, 21.0, 50.0), yon_s, "kapali", "kapi", Vector3(0, 30.0, 4.0), 40.0, true))
	out.append(_cat("ksylokerkos", "Ksylokerkos Kapısı (Belgrad)", lerpf(gg.x, pg.x, 0.45), lerpf(gg.y, pg.y, 0.45), Vector3(40.0, 19.0, 50.0), yon_s, "kapali", "kapi", Vector3(0, 28.0, 4.0), 36.0, false))
	out.append(_cat("pege", "Pege Kapısı (Silivri)", pg.x, pg.y, Vector3(40.0, 19.0, 50.0), yon_m, "saglam", "kapi", Vector3(0, 28.0, 4.0), 36.0, true))
	out.append(_cat("rhegion", "Rhegion Kapısı (Mevlevihane)", lerpf(pg.x, rm.x, 0.45), lerpf(pg.y, rm.y, 0.45), Vector3(40.0, 19.0, 50.0), yon_m, "saglam", "kapi", Vector3(0, 28.0, 4.0), 36.0, false))
	out.append(_cat("mesoteikhion", "Mesoteikhion (Lykos vadisi, alçalan kesim)", rm.x + 60.0, rm.y - 170.0, Vector3(80.0, 19.0, 50.0), yon_m, "harap", "sur", Vector3(0, 28.0, 0), 50.0, true))
	out.append(_cat("romanos", "Aziz Romanos Kapısı (Topkapı)", rm.x, rm.y, Vector3(48.0, 21.0, 50.0), yon_k, "harap", "kapi", Vector3(0, 30.0, 4.0), 44.0, true))
	out.append(_cat("pempton", "Pempton Kapısı (Sulukule)", lerpf(rm.x, hz.x, 0.45), lerpf(rm.y, hz.y, 0.45), Vector3(36.0, 19.0, 50.0), yon_k, "harap", "kapi", Vector3(0, 28.0, 4.0), 36.0, false))
	out.append(_cat("kharisios", "Kharisios Kapısı (Edirnekapı)", hz.x, hz.y, Vector3(48.0, 22.0, 52.0), yon_k, "harap", "kapi", Vector3(0, 30.0, 4.0), 44.0, true))
	out.append(_cat("kaligaria", "Kaligaria Kapısı (Eğrikapı)", hz.x + 180.0, hz.y + 360.0, Vector3(30.0, 18.0, 22.0), yon_k + 20.0, "saglam", "kapi", Vector3(0, 26.0, 2.0), 30.0, false))
	out.append(_cat("kerkoporta", "Kerkoporta (küçük kapı)", hz.x + 90.0, hz.y + 170.0, Vector3(20.0, 16.0, 22.0), yon_k + 10.0, "saglam", "kapi", Vector3(0, 24.0, 2.0), 26.0, true))
	return out


static func _cat(id: String, ad: String, e: float, n: float, olcu: Vector3, yon: float, durum: String, tur: String, bakis: Vector3, r: float, gorev: bool) -> Dictionary:
	return {
		"id": id, "ad": ad, "dogu_m": e, "kuzey_m": n, "gercek_olcu": olcu, "yon_derece": yon,
		"durum": durum, "tur": tur, "bakis": bakis, "bakis_r": r, "gorev": gorev,
	}


## Hat boyunca dayanak noktaları (gerçek doğu, kuzey) — şehir kurucusu sur dilimlerini bunların arasına dizer.
static func route() -> Array:
	return [
		["marmara", Vector2(-4838.49, -2100.0)], ["altin_kapi", Vector2(-4838.49, -1636.40)],
		["pege", Vector2(-5241.70, -434.15)], ["romanos", Vector2(-4939.29, 1113.20)],
		["kharisios", Vector2(-3771.67, 2337.72)], ["blakherna", Vector2(-3326.46, 2816.40)],
	]


# ------------------------------------------------------------------ DİLİM (hat)

static func build_run(host: Node3D, uzunluk: float = 110.0, k: float = 0.5, lod: int = 0, tohum: int = 1453) -> void:
	_run(host, uzunluk, k, lod, tohum, {"ad": "SurDilimi"})


static func build_sur(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	build_run(host, maxf(110.0 * k, 90.0), k, lod, 1453)


static func perches_sur(k: float = 0.5) -> Array:
	return _perches(maxf(110.0 * k, 90.0), k, 1453, {})


static func climbs_sur(k: float = 0.5) -> Array:
	return _climbs(maxf(110.0 * k, 90.0), k, 1453, {})


static func _perches(L: float, k: float, seed: int, o: Dictionary) -> Array:
	var lay := _layout(L, k, seed, o)
	var d: Dictionary = lay["d"]
	var out: Array = []
	var itx: Array = lay["itx"]
	if itx.size() > 0:
		out.append(Vector3(float(itx[0]["x"]), float(d["HT"]) + 0.02, 0.5 * (float(d["T"]) * 0.5 + float(d["TP"]) - float(d["T"]) * 0.5)))
	if itx.size() > 1:
		var last: Dictionary = itx[itx.size() - 1]
		out.append(Vector3(float(last["x"]), float(d["HT"]) + 0.02, 0.5 * float(d["TP"])))
	var otx: Array = lay["otx"]
	if otx.size() > 0:
		out.append(Vector3(float(otx[0]), float(d["OTH"]) + 0.02, float(d["zo0"]) + 0.5 * (float(d["OT"]) + float(d["OTP"]))))
	out.append(Vector3(0.0, float(d["HW"]) + 0.02, 0.0))
	return out


static func _climbs(L: float, k: float, seed: int, o: Dictionary) -> Array:
	var lay := _layout(L, k, seed, o)
	var d: Dictionary = lay["d"]
	var out: Array = []
	var zi0: float = d["zi0"]
	var zo0: float = d["zo0"]
	if lay.has("in_x0"):
		out.append([Vector3(float(lay["in_x0"]) - 0.6, 0.0, zi0 - 0.9), Vector3(float(lay["in_x1"]) + 0.7, float(d["HW"]), zi0 - 0.9), "basamak"])
		out.append([Vector3(float(lay["in_x1"]) + 0.7, float(d["HW"]), zi0 - 0.9), Vector3(float(lay["in_x1"]) + 0.7, float(d["HW"]), 0.0), "basamak"])
	if lay.has("out_x0"):
		out.append([Vector3(float(lay["out_x0"]) - 0.6, 0.0, zo0 - 0.9), Vector3(float(lay["out_x1"]) + 0.5, float(d["OH"]), zo0 - 0.9), "basamak"])
		out.append([Vector3(float(lay["out_x1"]) + 0.5, float(d["OH"]), zo0 - 0.9), Vector3(float(lay["out_x1"]) + 0.5, float(d["OH"]), (zo0 + float(d["zo1"])) * 0.5), "basamak"])
	# dış kule tepesine sur üstünden merdiven
	var otx: Array = lay["otx"]
	if otx.size() > 0:
		var cx := float(otx[0])
		var lt := ceili(float(d["OTH"] - d["OH"]) / STEP_RISE)
		var zc := (zo0 + float(d["zo1"])) * 0.5
		out.append([Vector3(cx - float(d["OTW"]) * 0.5 - lt * 0.42 - 0.4, float(d["OH"]), zc), Vector3(cx, float(d["OTH"]), zc), "basamak"])
	# hendek: dipten teras ve karşı yakaya rampalar
	if not o.get("hendek", true):
		return out
	var zm0: float = d["zm0"]
	var zm1: float = d["zm1"]
	var MD: float = d["MD"]
	var rl: float = lay["ramp_len"]
	var ax: float = lay["ramp_a_x"]
	var bx: float = lay["ramp_b_x"]
	out.append([Vector3(ax - rl + 1.0, -MD, zm0 + 1.3), Vector3(ax - 0.3, -0.05, zm0 + 1.3), "basamak"])
	out.append([Vector3(bx + rl - 1.0, -MD, zm1 - 1.3), Vector3(bx + 0.3, -0.05, zm1 - 1.3), "basamak"])
	return out


# ------------------------------------------------------------------ KAPILAR VE ÖZEL KESİMLER

const OPTS := {
	"altin_kapi": {"ad": "AltinKapi", "gw": 6.4, "gh": 5.2, "kapali": true, "mermer": true, "bigw": 1.5, "bigp": 1.3, "tas": Color("e0d7c3"), "hasar": 0.3},
	"ksylokerkos": {"ad": "Ksylokerkos", "gw": 3.6, "gh": 3.4, "kapali": true, "bigw": 1.1, "bigp": 1.0, "hasar": 0.7},
	"pege": {"ad": "Pege", "gw": 4.2, "gh": 4.2, "bigw": 1.3, "bigp": 1.2, "hasar": 1.0},
	"rhegion": {"ad": "Rhegion", "gw": 4.0, "gh": 4.0, "bigw": 1.2, "bigp": 1.5, "hasar": 0.6},
	"romanos": {"ad": "AzizRomanos", "gw": 5.0, "gh": 4.6, "bigw": 1.5, "bigp": 1.4, "koridor": true, "hasar": 2.0},
	"pempton": {"ad": "Pempton", "gw": 3.6, "gh": 3.6, "bigw": 1.0, "bigp": 1.0, "hasar": 2.2},
	"kharisios": {"ad": "Kharisios", "gw": 5.0, "gh": 4.4, "bigw": 1.3, "bigp": 1.7, "hasar": 1.6},
	"kaligaria": {"ad": "Kaligaria", "gw": 3.4, "gh": 3.4, "bigw": 0.9, "bigp": 0.9, "hendek": false, "hasar": 0.6},
	"kerkoporta": {"ad": "Kerkoporta", "gw": 2.6, "gh": 2.8, "bigw": 0.8, "bigp": 0.8, "hendek": false, "hasar": 0.4},
	"mesoteikhion": {"ad": "Mesoteikhion", "hasar": 3.0},
}


static func _gate_len(id: String, k: float) -> float:
	return maxf(150.0 * k, 90.0) if id != "mesoteikhion" else maxf(190.0 * k, 110.0)


static func _build_id(host: Node3D, id: String, k: float, lod: int) -> void:
	_run(host, _gate_len(id, k), k, lod, 1000 + id.hash() % 997, OPTS[id])


static func _perches_id(id: String, k: float) -> Array:
	return _perches(_gate_len(id, k), k, 1000 + id.hash() % 997, OPTS[id])


static func _climbs_id(id: String, k: float) -> Array:
	return _climbs(_gate_len(id, k), k, 1000 + id.hash() % 997, OPTS[id])


static func build_altin_kapi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_build_id(host, "altin_kapi", k, lod)
static func perches_altin_kapi(k: float = 0.5) -> Array:
	return _perches_id("altin_kapi", k)
static func climbs_altin_kapi(k: float = 0.5) -> Array:
	return _climbs_id("altin_kapi", k)

static func build_ksylokerkos(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_build_id(host, "ksylokerkos", k, lod)
static func perches_ksylokerkos(k: float = 0.5) -> Array:
	return _perches_id("ksylokerkos", k)
static func climbs_ksylokerkos(k: float = 0.5) -> Array:
	return _climbs_id("ksylokerkos", k)

static func build_pege(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_build_id(host, "pege", k, lod)
static func perches_pege(k: float = 0.5) -> Array:
	return _perches_id("pege", k)
static func climbs_pege(k: float = 0.5) -> Array:
	return _climbs_id("pege", k)

static func build_rhegion(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_build_id(host, "rhegion", k, lod)
static func perches_rhegion(k: float = 0.5) -> Array:
	return _perches_id("rhegion", k)
static func climbs_rhegion(k: float = 0.5) -> Array:
	return _climbs_id("rhegion", k)

static func build_romanos(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_build_id(host, "romanos", k, lod)
static func perches_romanos(k: float = 0.5) -> Array:
	return _perches_id("romanos", k)
static func climbs_romanos(k: float = 0.5) -> Array:
	return _climbs_id("romanos", k)

static func build_pempton(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_build_id(host, "pempton", k, lod)
static func perches_pempton(k: float = 0.5) -> Array:
	return _perches_id("pempton", k)
static func climbs_pempton(k: float = 0.5) -> Array:
	return _climbs_id("pempton", k)

static func build_kharisios(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_build_id(host, "kharisios", k, lod)
static func perches_kharisios(k: float = 0.5) -> Array:
	return _perches_id("kharisios", k)
static func climbs_kharisios(k: float = 0.5) -> Array:
	return _climbs_id("kharisios", k)

static func build_kaligaria(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_build_id(host, "kaligaria", k, lod)
static func perches_kaligaria(k: float = 0.5) -> Array:
	return _perches_id("kaligaria", k)
static func climbs_kaligaria(k: float = 0.5) -> Array:
	return _climbs_id("kaligaria", k)

static func build_kerkoporta(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_build_id(host, "kerkoporta", k, lod)
static func perches_kerkoporta(k: float = 0.5) -> Array:
	return _perches_id("kerkoporta", k)
static func climbs_kerkoporta(k: float = 0.5) -> Array:
	return _climbs_id("kerkoporta", k)

static func build_mesoteikhion(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_build_id(host, "mesoteikhion", k, lod)
static func perches_mesoteikhion(k: float = 0.5) -> Array:
	return _perches_id("mesoteikhion", k)
static func climbs_mesoteikhion(k: float = 0.5) -> Array:
	return _climbs_id("mesoteikhion", k)


## Kimlikle çağrı (önizleme ve şehir kurucusu için)
static func build_by_id(host: Node3D, id: String, k: float = 0.5, lod: int = 0) -> void:
	if id == "sur":
		build_sur(host, k, lod)
	else:
		_build_id(host, id, k, lod)
