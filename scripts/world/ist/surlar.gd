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
const C_ROOF := Color("5c4840")          # SUR-4: kule çatısı soluk eski kiremit (doygun turuncu değil)
const C_EARTH := Color("7a6a4c")
const C_GRASS := Color("6a7b3c")
const ZEMIN := preload("res://scripts/world/ist/sur_zemin.gd")
const KULE := preload("res://scripts/world/ist/sur_kule.gd")
const OTURTMA := preload("res://scripts/world/ist/sur_oturtma.gd")
const OTAG := preload("res://scripts/world/ist/sur_oturtma_ag.gd")
const C_DARK := Color("1c1814")

const PARAPET_H := 1.2
const PARAPET_T := 0.45
const STEP_RISE := 0.26
const SPAN_NAME := "IstSurlar"
## lod 0'da durağan görsel parçalar tek ağda birleştirilir (çizim çağrısı azalır). Denetim kapatır (kütle kutusu bakar).
static var bake := true
## Kurulum penceresi (ŞEHİR-3, zaman dilimi): yalnız ortası x ∈ [pencere.x, pencere.y) olan parçalar kurulur. Şehir
## kurucusu uzun dilimin yakın katmanını pencere pencere ayrı karelerde kurar (tek iş ≤ 6 ms). Varsayılan: hepsi.
static var pencere := Vector2(-1e9, 1e9)
## SUR-5: true iken _s yalnız çarpışma kutusu kurar (görünen ağ başka yerde)
static var carp_only := false
## SUR-5 (D): gedik eni (m) ve kurulan gediklerin dünya konumları (süreklilik ölçütü "belgeli gedik" sayar)
const GEDIK_W := 8.0
## SUR-OYUN: poterna (dış surun küçük kapısı) boşluğu; yalnız o["poterna"] verilince oyulur
const POTERNA_W := 1.4
const POTERNA_H := 2.3
static var gedik_dunya: Array = []

static func _ic(x: float) -> bool:
	return x >= pencere.x and x < pencere.y


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
	if size.x < 0.001 or size.y < 0.001 or size.z < 0.001 or not _ic((lo.x + hi.x) * 0.5):
		return null
	var pos := (lo + hi) * 0.5
	if carp_only:
		# SUR-5: yalnız çarpışma (görünen ağ ayrı kurulur: hendek kesiti, yıkık korkuluk)
		if lod >= 2:
			return null
		var body := StaticBody3D.new()
		body.position = pos
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = size
		cs.shape = bs
		body.add_child(cs)
		if nc:
			body.set_meta("no_climb", true)
		p.add_child(body)
		return body
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
	if size.x < 0.001 or size.y < 0.001 or size.z < 0.001 or not _ic((lo.x + hi.x) * 0.5):
		return null
	var m := Props.box(p, size, (lo + hi) * 0.5, col)
	if pat != "":
		m.material_override = Props.mat(col, 0.0, false, pat)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return m


## Köşegen kama (yükselen eğim, katı). Taban merkezi `base`, +x yönünde (yaw ile döner) `rise` kadar yükselir.
static func _wedge(p: Node3D, base: Vector3, length: float, rise: float, width: float, yaw_deg: float, col: Color, pat := "ashlar") -> MeshInstance3D:
	if not _ic(base.x):
		return null
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
	# SUR-5: üst çizgi cetvel değil: uzun kesimlerde yer yer YIKIK korkuluk (görünen alçalmış, üstünde düşmüş taşlar;
	# çarpışma tam boy kalır: sur üstü yürüyüşte düşme olmasın)
	var yik := Vector2(1e9, -1e9)
	if lod == 0 and x1 - x0 > 14.0:
		var hh := fposmod(sin(x0 * 0.731 + z * 2.17 + y * 0.37) * 4373.17, 1.0)
		if hh < 0.45:
			var xc := lerpf(x0 + 4.0, x1 - 4.0, fposmod(hh * 7.31, 1.0))
			var yw := 2.0 + hh * 4.0
			yik = Vector2(xc - yw, xc + yw)
	if yik.x < yik.y:
		for sg in _segs(x0, x1, [[yik.x, yik.y]]):
			_s(p, Vector3(sg[0], y, z - PARAPET_T * 0.5), Vector3(sg[1], y + PARAPET_H, z + PARAPET_T * 0.5), col, "ashlar", lod)
		carp_only = true
		_s(p, Vector3(yik.x, y, z - PARAPET_T * 0.5), Vector3(yik.y, y + PARAPET_H, z + PARAPET_T * 0.5), col, "ashlar", lod)
		carp_only = false
		if _ic((yik.x + yik.y) * 0.5):
			var ag = KULE.Ag.new()
			var rng := RandomNumberGenerator.new()
			rng.seed = int(absf(yik.x * 13.0 + z * 7.0))
			# kırık profil: dört basamaklı alçak kalıntı
			var n := 4
			for i in n:
				var xa := lerpf(yik.x, yik.y, float(i) / n)
				var xb := lerpf(yik.x, yik.y, float(i + 1) / n)
				var hk := PARAPET_H * (0.2 + 0.5 * absf(float(i) - 1.5) / 1.5) + rng.randf_range(-0.08, 0.1)
				ag.kutu(Vector3((xa + xb) * 0.5, y, z - PARAPET_T * 0.5), Vector3.RIGHT, Vector3.BACK, xb - xa, hk, PARAPET_T)
			for i in 5:
				KULE._moloz_tas(ag, Vector3(rng.randf_range(yik.x, yik.y), y, z + rng.randf_range(-0.9, 0.3)), rng)
			ag.mesh_ekle(p, KULE._tas_mat(col, 0), "YikikKorkuluk")
	else:
		_s(p, Vector3(x0, y, z - PARAPET_T * 0.5), Vector3(x1, y + PARAPET_H, z + PARAPET_T * 0.5), col, "ashlar", lod)
	if lod == 0:
		# dişler insan boyunda (SUR-4: 1,0 m en, korkulukla 1,8 m; 1,8 m arayla); bin yıllık surda yer yer eksik diş
		var m := floori((x1 - x0) / 1.8)
		var off := ((x1 - x0) - m * 1.8) * 0.5
		for i in m:
			var xx := x0 + off + 0.9 + i * 1.8
			if absf(fposmod(xx * 0.37 + z * 1.3, 11.0)) < 0.8 or (xx > yik.x - 0.6 and xx < yik.y + 0.6):
				continue
			mer.append(Transform3D(Basis.from_scale(Vector3(1.0, 0.6, PARAPET_T)), Vector3(xx, y + PARAPET_H + 0.3, z)))


static func _parapet_z(p: Node3D, z0: float, z1: float, x: float, y: float, col: Color, lod: int, mer: Array) -> void:
	if z1 - z0 < 0.3:
		return
	_s(p, Vector3(x - PARAPET_T * 0.5, y, z0), Vector3(x + PARAPET_T * 0.5, y + PARAPET_H, z1), col, "ashlar", lod)
	if lod == 0:
		var m := floori((z1 - z0) / 1.8)
		var off := ((z1 - z0) - m * 1.8) * 0.5
		for i in m:
			mer.append(Transform3D(Basis.from_scale(Vector3(PARAPET_T, 0.6, 1.0)), Vector3(x, y + PARAPET_H + 0.3, z0 + off + 0.9 + i * 1.8)))


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

static func _inner_tower(p: Node3D, d: Dictionary, tw: Dictionary, lod: int, _mer: Array, o: Dictionary, sira := 0) -> void:
	## SUR-5: kule artık kutu değil (KULE: plan çokgeni + profil; dönüşümlü kare / sekizgen / altıgen)
	var cx: float = tw["x"]
	if not _ic(cx):
		return
	var T: float = d["T"]
	var kid := int(absf(cx * 7.31 + float(o.get("tohum_k", 0)))) % 7
	var buyuk := float(tw["w"]) > float(d["TW"]) * 1.05
	var tur: int = [0, 1, 0, 2][(sira + int(o.get("tohum_k", 0))) % 4]
	if buyuk:
		tur = 1 if bool(o.get("mermer", false)) == false and String(o.get("ad", "")) in ["AzizRomanos", "Kharisios"] else 0
	if o.has("_kuleler"):
		(o["_kuleler"] as Array).append([KULE.plan_ic(cx, float(tw["w"]), -T * 0.5 - 0.15, T * 0.5 + float(tw["p"]), tur), 0.0, T * 0.5, 1.0])
	KULE.ic_kule(p, {
		"cx": cx, "w": float(tw["w"]), "zb": -T * 0.5 - 0.15, "zf": T * 0.5 + float(tw["p"]), "zi1": T * 0.5,
		"yf": float(d["HW"]) + 0.03, "HT": float(d["HT"]), "yc": float(d["HT"]) - 0.5, "tur": tur,
		"tohum": int(absf(cx * 13.7)) + sira * 31, "hasar": float(o.get("hasar", 1.0)),
		"cati": kid == 1, "yazit": kid == 3 or kid == 6, "tas": o.get("tas", C_STONE),
	}, lod)


static func _outer_tower(p: Node3D, d: Dictionary, cx: float, lod: int, _mer: Array, o: Dictionary, sira := 0) -> void:
	if not _ic(cx):
		return
	var zo0: float = d["zo0"]
	var zo1: float = d["zo1"]
	if o.has("_kuleler"):
		(o["_kuleler"] as Array).append([KULE.plan_dis(cx, float(d["OTW"]), zo0, zo1 + float(d["OTP"]), (sira + int(absf(cx))) % 2, 7), float(d.get("dis_dy", 0.0)), zo1, 1.0])
	KULE.dis_kule(p, {
		"cx": cx, "w": float(d["OTW"]), "z0": zo0, "zf": zo1 + float(d["OTP"]), "y0": float(d.get("dis_dy", 0.0)) - 2.0,
		"OH": float(d["OH"]), "OTH": float(d["OTH"]), "tur": (sira + int(absf(cx))) % 2, "tohum": int(absf(cx * 11.3)) + sira * 17,
		"hasar": float(o.get("hasar", 1.0)), "tas": (o.get("tas", C_STONE) as Color).darkened(0.04),
		"gap_z": (zo0 + zo1) * 0.5, "gap_w": 1.8,
	}, lod)


# ------------------------------------------------------------------ sur dilimi

## Düğümün dünya dönüşümü: ağaçtaysa global; değilse (uzak katman ağaç dışında kurulur) IstSehir'in verdiği dönüşüm ×
## üst düğümlerin yerel dönüşümü. [var mı, Transform3D]
static func _dunya_xf(n: Node3D) -> Array:
	if n.is_inside_tree():
		return [true, n.global_transform]
	if not ZEMIN.xf_var:
		return [false, Transform3D()]
	var acc := n.transform
	var q := n.get_parent()
	while q is Node3D:
		acc = (q as Node3D).transform * acc
		q = q.get_parent()
	return [true, ZEMIN.xf_dunya * acc]


## Dış bölgenin (hendek kuşağı) kademesi: hendeğin dış yakasında arazi dilim tabanından ne kadar aşağıda (ortanca;
## 0 … −14 m; 1,5 m'den azsa 0). xf: dilim kökünün dünya dönüşümü.
static func dis_dy(xf: Transform3D, L: float, k: float) -> float:
	# OTURTMA: kuşak arazisi düzlenmeden önce ölçülüp kaydedilen kademe (düzlenmiş araziden yeniden ölçülmez: tek kaynak)
	var kd := OTURTMA.dy_bul(xf.origin)
	if not is_nan(kd):
		return kd
	var d := dims(k)
	var hs: Array = []
	for t: float in [-0.35, 0.0, 0.35]:
		for zz: float in [float(d["zm0"]) + 4.0, float(d["zm1"]) + 3.0, float(d["zm1"]) + 9.0]:
			var w := xf * Vector3(L * t, 0.0, zz)
			hs.append(IstGeo.h(w.x, w.z) - w.y)
	hs.sort()
	var med := float(hs[hs.size() / 2])
	if med > -1.5:
		return 0.0
	return clampf(med + 0.6, -14.0, 0.0)

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
	o["_kuleler"] = []
	var closed: bool = bool(o.get("kapali", false))
	var open_gate := gw > 0.0 and not closed
	var stone: Color = o.get("tas", C_STONE)
	var mer: Array = []
	var x0 := -L * 0.5
	var x1 := L * 0.5
	var apr := 12.0
	# ---- zemin: şehir önü kaldırımı, sur altı, peribolos, dış sur altı, teras
	# OTURTMA: zemin artık arazinin kendisi (kuşak düzlük kayıtları: arazi dilim tabanında). Şehir önü kaldırımı, peribolos ve
	# teras levhaları kalktı (düz gri levha / kalınlığı görünen yatay yüzey olmasın); yerlerinde arazinin 0,12 m altında
	# yalnız dikiş arkalığı. Duvar altları 3 m'lik temel (arazi dilim ucunda komşu tabana geçerken alt kenar görünmesin).
	_s(root, Vector3(x0, -3.0, zi0 - 4.0), Vector3(x1, -0.12, zi0), Color("7a6650"), "dirt", lod)
	# (temel levhaları duvar yüzlerinden 0,15 m içeride: dış kademe uzatmasıyla aynı düzlemde z-çakışması yapıp dış
	# surun dışında "beyaz/gri levha" bandı çiziyordu)
	_s(root, Vector3(x0, -3.5, zi0 + 0.15), Vector3(x1, -0.02, zi1 - 0.15), stone.darkened(0.2), "dirt", lod)
	_s(root, Vector3(x0, -3.0, zi1), Vector3(x1, -0.12, zo0), C_EARTH, "dirt", lod)
	_s(root, Vector3(x0, -3.5, zo0 + 0.15), Vector3(x1, -0.02, zo1 - 0.15), stone.darkened(0.2), "dirt", lod)
	# SUR-4: dış bölge (parateikhion, hendek, set) araziye iner: dilim tabanı iç surun hattındaki ortanca yükseklikte;
	# arazi dışa doğru düşüyorsa hendek kuşağı 6 m'lik oyuk yerine yerden yüksek bir set üstünde kalıyordu (sahip_03).
	# Dış sur ve kuleleri bu kademe kadar aşağı uzar (dışarıdan bakınca daha yüksek dış sur; içte peribolos aynı).
	var dy := 0.0
	var xw: Array = _dunya_xf(root)
	if xw[0] and o.get("hendek", true):
		dy = dis_dy(xw[1], L, k)
	var dis := Node3D.new()
	dis.name = "Dis"
	dis.position.y = dy
	root.add_child(dis)
	if dy < 0.0:
		_s(root, Vector3(x0, dy - 2.5, zo0), Vector3(x1, 0.05, zo1), stone.darkened(0.06), "ashlar", lod, true)
		lay["dis_dy"] = dy
		d["dis_dy"] = dy
	# parateikhion terası: çiğnenmiş toprak (SUR-4: yeşil kutu yamaçta keskin kenarlı prizma okunuyordu; taban derin)
	_s(dis, Vector3(x0, -4.0, zo1), Vector3(x1, -0.12, zm0 - 0.9), Color("857158"), "dirt", lod)
	# ---- hendek
	if o.get("hendek", true):
		_build_moat(dis, lay, lod, stone, open_gate, mer, o)
	else:
		ZEMIN.set_(dis, x0, x1, zm0 - 0.9, lod, int(lay["rng_seed"]), pencere)
	# ---- iç sur (kapı boşluğu varsa kesilir)
	var in_cut: Array = []
	if open_gate:
		in_cut.append([-gw * 0.5, gw * 0.5])
	# OTURTMA: duvar gövdesi tabanın 1 m altından başlar (komşu dilim geçişinde arazi taban altına inse de yüz sürer)
	for s in _segs(x0, x1, in_cut):
		_s(root, Vector3(s[0], -1.0, zi0), Vector3(s[1], HW, zi1), stone, "ashlar", lod, true)
	if open_gate:
		_s(root, Vector3(-gw * 0.5, gh, zi0), Vector3(gw * 0.5, HW, zi1), stone, "ashlar", lod, true)
	elif gw > 0.0:
		_s(root, Vector3(-gw * 0.5, 0, zi0), Vector3(gw * 0.5, HW, zi1), stone, "ashlar", lod, true)
	# ---- dış sur
	var out_cut: Array = []
	if open_gate:
		out_cut.append([-gw * 0.5, gw * 0.5])
	# SUR-5 (D): Mesoteikhion gedikleri (kuşatma hasarı): dış sur yıkık, gedikte moloz + fıçı/kazıklı stauroma
	var gedikler: Array = o.get("gedik", [])
	for gx in gedikler:
		out_cut.append([float(gx) - GEDIK_W * 0.5, float(gx) + GEDIK_W * 0.5])
	# SUR-OYUN (seçenekle; şehir kurucusu vermez → görünüş aynı): oyun gediğinde stauroma kurulmaz (onarım aşamalarını
	# sur_oyun_parca kurar); dış surda poterna boşluğu (kanat ve çerçeve sur_oyun_parca'da)
	var sade_g: Array = o.get("gedik_sade", [])
	for gx in gedikler:
		_gedik(root, lay, float(gx), lod, stone, sade_g.has(gx))
	if o.has("poterna"):
		var ptx := float(o["poterna"])
		out_cut.append([ptx - POTERNA_W * 0.5, ptx + POTERNA_W * 0.5])
		_s(root, Vector3(ptx - POTERNA_W * 0.5, POTERNA_H, zo0), Vector3(ptx + POTERNA_W * 0.5, OH, zo1), stone.darkened(0.04), "ashlar", lod, true)
	for s in _segs(x0, x1, out_cut):
		_s(root, Vector3(s[0], -1.0, zo0), Vector3(s[1], OH, zo1), stone.darkened(0.04), "ashlar", lod, true)
	if open_gate:
		_s(root, Vector3(-gw * 0.5, gh, zo0), Vector3(gw * 0.5, OH, zo1), stone.darkened(0.04), "ashlar", lod, true)
	# ---- kuleler
	var itx: Array = lay["itx"]
	var otx: Array = lay["otx"]
	for ti in itx.size():
		_inner_tower(root, d, itx[ti], lod, mer, o, ti)
	for ti in otx.size():
		var yakin := false
		for gx in gedikler:
			if absf(float(gx) - float(otx[ti])) < GEDIK_W * 0.5 + float(d["OTW"]) * 0.5 + 1.0:
				yakin = true
		if yakin:
			continue                      # gedikte dış kule de yıkık (moloz yığınının içinde)
		_outer_tower(root, d, float(otx[ti]), lod, mer, o, ti)
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
		var gcut: Array = []
		for gx in gedikler:
			gcut.append([float(gx) - GEDIK_W * 0.5, float(gx) + GEDIK_W * 0.5])
		o_cut2.append_array(gcut)
		for s in _segs(x0, x1, ocut + gcut + ([[-gw * 0.5, gw * 0.5]] if open_gate else [])):
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
	mer = mer.filter(func(t) -> bool: return t is Transform3D and _ic((t as Transform3D).origin.x))
	if lod == 0 and mer.size() > 0:
		# SUR-5: MultiMesh dişleri sur taşı gölgelendiricisinde dokusuz BEYAZ KÜP okunuyordu (kara_03_ust_a/b; sonda
		# --set=kimust: SurDilimi/@MultiMeshInstance3D ölçek 1,0×0,6×0,45). Artık pişen gerçek ağ: boyu oynak, kırık/eksik.
		KULE.disler_ag(root, mer, stone.darkened(0.06), int(lay["rng_seed"]))
	# ---- OTURTMA: sur dibi temas kuşağı (etek, dip bandı, döküntü ve bitki)
	var kes := {}
	var kp: Array = [[-gw * 0.5 - 0.6, gw * 0.5 + 0.6]] if open_gate else []
	kes["kapi"] = kp
	kes["sehir"] = kp + ([[float(lay["in_x0"]) - 1.0, float(lay["in_x1"]) + 1.8]] if lay.has("in_x0") else [])
	kes["peri"] = kp + ([[float(lay["out_x0"]) - 1.0, float(lay["out_x1"]) + 1.4]] if lay.has("out_x0") else [])
	var ki: Array = []
	for tw in itx:
		ki.append([float(tw["x"]) - float(tw["w"]) * 0.5, float(tw["x"]) + float(tw["w"]) * 0.5])
	var kd: Array = []
	for cx4 in otx:
		kd.append([float(cx4) - float(d["OTW"]) * 0.5, float(cx4) + float(d["OTW"]) * 0.5])
	var gk: Array = []
	for gx in gedikler:
		gk.append([float(gx) - GEDIK_W * 0.5 - 1.0, float(gx) + GEDIK_W * 0.5 + 1.0])
	kes["kule_ic"] = ki
	kes["kule_dis"] = kd
	# SUR-OYUN 4e (§3.4): taş merdivenlerin ayak izi (+1 m): kule kaidesi eteği burada yere iner (iç kulenin eteği
	# merdivenin ilk basamağının üstüne taşıyordu: 0,28 m etek > 0,255 m basamak → oyuncu basamağın 0,5 m önünde takılıyordu)
	var yasak: Array = []
	if lay.has("in_x0"):
		yasak.append(Rect2(float(lay["in_x0"]) - 1.2, zi0 - 3.2, float(lay["in_x1"]) - float(lay["in_x0"]) + 3.2, 3.4))
	if lay.has("out_x0"):
		yasak.append(Rect2(float(lay["out_x0"]) - 1.2, zo0 - 3.2, float(lay["out_x1"]) - float(lay["out_x0"]) + 2.8, 3.4))
	kes["yasak"] = yasak
	kes["gedik"] = gk
	kes["peri"] = (kes["peri"] as Array) + gk
	if lay.has("ramp_a_x"):
		kes["para"] = kp + [[float(lay["ramp_a_x"]) - 2.6, float(lay["ramp_a_x"]) + 1.6]] + gk
	# SUR-OYUN (seçenekle): poterna ve parateikhion geçitlerinin önünde etek kurulmaz (girişte takılma olmasın)
	if o.has("poterna"):
		# dış kuşak aşağıdaysa poternanın önünde +x'e inen taş basamak var (sur_oyun_parca): etek onun da önünden kalkar
		var pdx := POTERNA_W * 0.5 + 0.8
		if dy + -0.12 < -0.3:
			pdx = POTERNA_W * 0.5 + 0.4 + ceili((-0.02 - (dy - 0.12)) / STEP_RISE) * 0.32 + 1.2
		var ptr := [[float(o["poterna"]) - POTERNA_W * 0.5 - 0.8, float(o["poterna"]) + pdx]]
		kes["peri"] = (kes["peri"] as Array) + ptr
		kes["gedik"] = (kes["gedik"] as Array) + ptr
	for pg in o.get("para_gecit", []):
		kes["para"] = (kes.get("para", []) as Array) + [[float(pg[0]) - float(pg[1]) * 0.5 - 0.6, float(pg[0]) + float(pg[1]) * 0.5 + 0.6]]
	OTAG.kur(root, lay, lod, xw, dy, o["_kuleler"], kes, bool(o.get("hendek", true)))
	# ---- kapı ve ayrıntı
	if gw > 0.0:
		IstSurlarKapi.build(root, lay, lod, o)
	if lod == 0:
		IstSurlarAyrinti.build(root, lay, o)
		_wall_niches(root, lay, mer_niche_dummy())
		if bake and root.is_inside_tree():
			Props.bake_static(root, [root])
	return root


static func mer_niche_dummy() -> int:
	return 0


## Sur yüzlerinde sıralı ok yarığı/niş (MultiMesh): iç surun ova yüzünde ve dış surun ova yüzünde
static func _wall_niches(root: Node3D, lay: Dictionary, _unused: int) -> void:
	var d: Dictionary = lay["d"]
	var L: float = lay["L"]
	var gw: float = lay["gw"]
	var dark: Array = []
	var lint: Array = []
	var rows: Array = [[float(d["zi1"]) + 0.02, float(d["HW"]) - 1.9, 1.0], [float(d["zo1"]) + 0.02, float(d["OH"]) * 0.5, 0.9]]
	for r in rows:
		var z: float = r[0]
		var y: float = r[1]
		var x := -L * 0.5 + 3.0
		while x < L * 0.5 - 2.0:
			var skip := gw > 0.0 and absf(x) < gw * 0.5 + 2.5
			for tw in lay["itx"]:
				if absf(float(tw["x"]) - x) < float(tw["w"]) * 0.5 + 0.8:
					skip = true
			if not skip and _ic(x):
				dark.append(Transform3D(Basis.from_scale(Vector3(0.5, float(r[2]) * 1.1, 0.06)), Vector3(x, y, z)))
				lint.append(Transform3D(Basis.from_scale(Vector3(0.85, 0.16, 0.08)), Vector3(x, y + float(r[2]) * 0.55 + 0.1, z)))
			x += 3.4
	if dark.size() > 0:
		Scenery.scatter(root, Scenery._boxm(Vector3.ONE), dark, [], Props.mat(C_DARK, 0.0, false, ""))
		Scenery.scatter(root, Scenery._boxm(Vector3.ONE), lint, [], Props.mat(C_BRICK, 0.0, false, "brick"))


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
	# SUR-5 (C): görünen hendek tek ağ (yumuşak kesit, taş kaplı yanlar, çamur taban, yer yer kayma); kutular yalnız çarpışma
	carp_only = true
	_s(root, Vector3(x0, -MD - 0.4, zm0 - 0.9), Vector3(x1, 0, zm0), scarp, "ashlar", lod, true)
	_s(root, Vector3(x0, -MD - 1.2, zm0), Vector3(x1, -MD, zm1), ZEMIN.CAMUR, "dirt", lod)
	_s(root, Vector3(x0, -MD - 0.4, zm1), Vector3(x1, 0, zm1 + 0.9), scarp, "ashlar", lod, true)
	carp_only = false
	ZEMIN.hendek_kesit(root, x0, x1, zm0 - 0.9, zm1 + 0.9, MD, lod, int(lay["rng_seed"]), pencere)
	# dış yaka: OTURTMA — ayrı toprak set ağı (arazinin üstüne konmuş ikinci zemin, kendi renkleri) kalktı; dış omuz
	# arazinin kendisi (kuşak düzlük kaydı: hendek kıyısında harpuşta düzeyi, 12 m'de doğal araziye yumuşak geçiş)
	# parateikhion: terasın ucunda alçak sur; rampa başında ve kapı önünde geçit
	var pcut: Array = [[float(lay["ramp_a_x"]) - 2.2, float(lay["ramp_a_x"]) + 1.2]]
	if gw > 0.0:
		pcut.append([-gw * 0.5 - 1.2, gw * 0.5 + 1.2])
	for pg in o.get("para_gecit", []):
		pcut.append([float(pg[0]) - float(pg[1]) * 0.5, float(pg[0]) + float(pg[1]) * 0.5])
	for sg in _segs(x0, x1, pcut):
		_s(root, Vector3(sg[0], 0, zm0 - 1.8), Vector3(sg[1], 1.6, zm0 - 0.9), stone.darkened(0.08), "ashlar", lod, true)
		if lod == 0 and sg[1] - sg[0] > 1.0:
			_d(root, Vector3(sg[0], 1.6, zm0 - 1.75), Vector3(sg[1], 1.72, zm0 - 0.95), stone.darkened(0.04), "ashlar")
			# mazgallı hendek duvarı (SUR-4): dişler 1,0 × 0,6 m, 1,8 m arayla
			var mn := floori((float(sg[1]) - float(sg[0])) / 1.8)
			for mi2 in mn:
				var mx: float = float(sg[0]) + 0.9 + mi2 * 1.8
				mer.append(Transform3D(Basis.from_scale(Vector3(1.0, 0.6, 0.8)), Vector3(mx, 1.72 + 0.3, zm0 - 1.35)))
	# uç dolguları (tam yükseklik): hendek bölmesi/geçit
	var cw := 3.0
	_s(root, Vector3(x0, -MD, zm0), Vector3(x0 + cw, 0, zm1), scarp.lightened(0.04), "ashlar", lod, true)
	_s(root, Vector3(x1 - cw, -MD, zm0), Vector3(x1, 0, zm1), scarp.lightened(0.04), "ashlar", lod, true)
	# kapı önü: hendek köprüsü KALDIRILMIŞ/YIKIK (kuşatma; SUR-4 madde 6): iki yakada taş ayaklar, arası açık; ortada
	# kırık kalaslar (yalnız görünüm)
	if gw > 0.0:
		var half := gw * 0.5 + 1.2
		var ay := 4.5
		# SUR-5: ayaklar kesme kutu değil: yıkık köprü ayağı (görünen: kademeli kırık taş sıraları, gedik yanına doğru
		# alçalır, üstünde düşmüş bloklar); çarpışma eski kutu
		carp_only = true
		_s(root, Vector3(-half, -MD, zm0), Vector3(half, 0, zm0 + ay), stone.darkened(0.1), "ashlar", lod, true)
		_s(root, Vector3(-half, -MD, zm1 - ay), Vector3(half, 0, zm1), stone.darkened(0.1), "ashlar", lod, true)
		carp_only = false
		if _ic(0.0):
			var ag = KULE.Ag.new()
			var rng := RandomNumberGenerator.new()
			rng.seed = int(lay["rng_seed"]) + 91
			for side: float in [1.0, -1.0]:
				var zb := zm0 if side > 0.0 else zm1
				var nk := 5
				for k in nk:
					# yakadan gediğe: her sıra biraz daha alçak ve dar (kırık uç)
					var t := float(k) / nk
					var dz := ay / nk
					var z0k := zb + side * dz * k
					var w := half * 2.0 * (1.0 - 0.12 * t) + rng.randf_range(-0.4, 0.2)
					var yt := lerpf(0.0, -MD * 0.55, t * t) + rng.randf_range(-0.25, 0.1)
					var n2 := 3
					for m in n2:
						var xa := -w * 0.5 + w * float(m) / n2
						var xb := -w * 0.5 + w * float(m + 1) / n2
						var yy := yt - rng.randf_range(0.0, 0.5) * t
						ag.kutu(Vector3((xa + xb) * 0.5, -MD - 0.2, z0k if side > 0.0 else z0k - dz), Vector3.RIGHT, Vector3.BACK, xb - xa - 0.04, yy + MD + 0.2, dz - 0.04)
				for k2 in 6 if lod == 0 else 0:
					KULE._moloz_tas(ag, Vector3(rng.randf_range(-half, half), -MD, zb + side * (ay + rng.randf_range(0.3, 2.5))), rng)
			ag.mesh_ekle(root, KULE._tas_mat(stone.darkened(0.1), lod), "YikikKopru")
		if lod == 0:
			for k in 3:
				var kx := -half + 0.6 + k * (half * 2.0 - 1.2) / 2.0
				var kb := Basis.from_euler(Vector3(0.35 + k * 0.12, 0.0, 0.0))
				var km := Props.box(root, Vector3(0.35, 0.25, 4.0), Vector3(kx, -0.9 - k * 0.6, zm0 + ay + 1.6), C_WOOD.darkened(0.2))
				km.basis = kb
			for k2 in 2:
				var kx2 := -half + 1.0 + k2 * (half * 2.0 - 2.0)
				var km2 := Props.box(root, Vector3(0.35, 0.25, 3.2), Vector3(kx2, -MD + 0.4, (zm0 + zm1) * 0.5 + k2 * 1.5), C_WOOD.darkened(0.3))
				km2.basis = Basis.from_euler(Vector3(0.0, 0.4 - k2 * 0.9, 0.08))
	if lod >= 2:
		return
	# rampalar: yakın yakadan dibe, dipten karşı yakaya
	var ramp_len: float = lay["ramp_len"]
	var ax: float = lay["ramp_a_x"]
	var bx: float = lay["ramp_b_x"]
	var w1 := _wedge(root, Vector3(ax - ramp_len * 0.5, -MD, zm0 + 1.3), ramp_len, MD, 2.6, 0.0, stone.darkened(0.1))
	var w2 := _wedge(root, Vector3(bx + ramp_len * 0.5, -MD, zm1 - 1.3), ramp_len, MD, 2.6, 180.0, stone.darkened(0.1))
	# SUR-5: kama yalnız çarpışma; görünen toprak döküm rampa (uçtan bakınca "yeşil piramit" okunuyordu)
	for wm in [w1, w2]:
		if wm != null:
			(wm as MeshInstance3D).visible = false
	if w1 != null:
		ZEMIN.rampa(root, ax - ramp_len, ax, zm0 + 1.3, -MD, MD, 2.6, int(lay["rng_seed"]))
	if w2 != null:
		ZEMIN.rampa(root, bx + ramp_len, bx, zm1 - 1.3, -MD, MD, 2.6, int(lay["rng_seed"]) + 5)
	# kuru çamur tabanında yer yer su birikintisi ve saz (SUR-4; eskiden boydan boya tek su levhası)
	if lod == 0 and _ic(0.0):
		# bütün dilim için tek pencerede (pencere başına iki MultiMesh çizimi olmasın)
		ZEMIN.hendek_dibi(root, x0 + cw, x1 - cw, zm0, zm1, -MD, int(lay["rng_seed"]))


# ------------------------------------------------------------------ GEDİK (Mesoteikhion)

## Dış surda top gediği: beden 0,8 m'ye kadar yıkık (kırık profil, uçlara doğru yükselir); gedikten peribolosa ve
## parateikhion terasına yayılan moloz yığını (düzensiz kaya + toprak tümsek, kutu değil); gedikte stauroma: toprak dolu
## fıçılar, kazıklı toprak set, savunmacılar için sehpalar üstünde kalas yürüme tahtası (dış sur yürüme yolu hizasında,
## iki yandaki sur üstüne bağlanır; çarpışmalı).
static func _gedik(root: Node3D, lay: Dictionary, gx: float, lod: int, stone: Color, sade := false) -> void:
	if not _ic(gx):
		return
	var d: Dictionary = lay["d"]
	var zo0: float = d["zo0"]
	var zo1: float = d["zo1"]
	var OH: float = d["OH"]
	var h := GEDIK_W * 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = int(absf(gx * 17.0)) + 5
	var ag = KULE.Ag.new()
	var n := 6
	for i in n:
		var xa := gx - h + GEDIK_W * float(i) / n
		var xb := gx - h + GEDIK_W * float(i + 1) / n
		var t := absf((xa + xb) * 0.5 - gx) / h
		var hk := lerpf(0.8, OH * 0.7, t * t) + rng.randf_range(-0.3, 0.3)
		ag.kutu(Vector3((xa + xb) * 0.5, -0.5, zo0), Vector3.RIGHT, Vector3.BACK, xb - xa, hk + 0.5, zo1 - zo0)
	if lod <= 1:
		carp_only = true
		_s(root, Vector3(gx - h, 0, zo0), Vector3(gx + h, 1.0, zo1), stone, "ashlar", lod, true)
		carp_only = false
	# moloz yığını: alçak toprak-taş tümsek (yarım elips koni) + düzensiz taşlar
	var tm = KULE.Ag.new()
	var zc := (zo0 + zo1) * 0.5
	var seg := 10
	for side: float in [-1.0, 1.0]:
		for i in seg:
			var a0 := PI * float(i) / seg
			var a1 := PI * float(i + 1) / seg
			var p0 := Vector3(gx + cos(a0) * (h + 1.5), 0.0, zc + side * sin(a0) * 6.5)
			var p1 := Vector3(gx + cos(a1) * (h + 1.5), 0.0, zc + side * sin(a1) * 6.5)
			tm.tri(p0, p1, Vector3(gx, 1.6, zc), Vector3(0, 1.0, side * 0.6))
	tm.mesh_ekle(root, Props.mat(Color("7c705c"), 0.0, false, "rubble"), "GedikMoloz")
	if lod >= 2:
		ag.mesh_ekle(root, KULE._tas_mat(stone.darkened(0.05), 2), "GedikBeden")
		return
	var kl: Array = []
	for i in (34 if lod == 0 else 10):
		var r := rng.randf_range(0.0, 1.0)
		var ang := rng.randf_range(0.0, TAU)
		var px := gx + cos(ang) * r * (h + 1.0)
		var pz := zc + sin(ang) * r * 6.0
		var sc := rng.randf_range(0.35, 1.1)
		var yy := 1.6 * (1.0 - r) + sc * 0.2
		kl.append(Transform3D(Basis.from_euler(Vector3(rng.randf_range(-0.6, 0.6), rng.randf() * TAU, rng.randf_range(-0.6, 0.6))).scaled(Vector3(sc * 1.3, sc * 0.7, sc)), Vector3(px, yy, pz)))
	Scenery.scatter(root, KULE.kaya_mesh(), kl, [], Props.mat(stone.darkened(0.12), 0.0, false, "ashlar_far"))
	ag.mesh_ekle(root, KULE._tas_mat(stone.darkened(0.05), lod), "GedikBeden")
	if lod == 1 or sade:
		if sade and root.is_inside_tree():
			gedik_dunya.append(root.global_transform * Vector3(gx, 0.0, zo1))
		return
	# stauroma: dış surun peribolos yüzü boyunca toprak dolu fıçılar, arkada kazıklı toprak set
	var zs := zo0 - 1.4
	var bx := gx - h + 0.6
	while bx < gx + h - 0.4:
		IstSurlarAyrinti._barrel(root, Vector3(bx, 0.0, zs + rng.randf_range(-0.15, 0.15)))
		bx += 0.95
	var tset := Props.ball(root, 0.5, Vector3(gx, 0.5, zs - 1.3), Color("5e4c36"), Vector3(GEDIK_W + 1.0, 1.4, 2.6), 8)
	tset.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for i in int(GEDIK_W / 0.55):
		var kx := gx - h + 0.3 + i * 0.55
		Props.cyl(root, 0.07, 2.4, Vector3(kx, 1.4, zs + 0.7), C_WOOD.darkened(0.2), Vector3(-28.0 + rng.randf_range(-5.0, 5.0), 0, rng.randf_range(-4.0, 4.0)), 5, 0.02)
	# yürüme tahtası
	var yk := OH
	for sx: float in [-1.0, 0.0, 1.0]:
		var px2 := gx + sx * (h - 0.8)
		for sz: float in [zo0 + 0.4, zo1 - 0.4]:
			Props.cyl(root, 0.09, yk, Vector3(px2, yk * 0.5, sz), C_WOOD.darkened(0.1), Vector3.ZERO, 6)
		Props.box(root, Vector3(0.18, 0.22, zo1 - zo0), Vector3(px2, yk - 0.22, (zo0 + zo1) * 0.5), C_WOOD.darkened(0.15))
	for i in 7:
		var pz2 := zo0 + 0.25 + i * (zo1 - zo0 - 0.5) / 6.0
		Props.box(root, Vector3(GEDIK_W + 0.6, 0.07, 0.3), Vector3(gx + rng.randf_range(-0.1, 0.1), yk - 0.07, pz2), C_WOOD.lightened(0.04 * (i % 2)), Vector3(0, rng.randf_range(-0.8, 0.8), 0))
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(GEDIK_W + 0.6, 0.12, zo1 - zo0)
	cs.shape = bs
	body.add_child(cs)
	body.position = Vector3(gx, yk - 0.06, (zo0 + zo1) * 0.5)
	root.add_child(body)
	if root.is_inside_tree():
		gedik_dunya.append(root.global_transform * Vector3(gx, 0.0, zo1))


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
