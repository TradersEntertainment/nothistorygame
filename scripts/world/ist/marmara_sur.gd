class_name IstMarmaraSur
extends RefCounted
## Marmara deniz surları: tek sıra sur (≈ 12 m), denize taşan kuleler, küçük deniz kapıları, şehir yüzünde yürüme yolu
## merdiveni. `build_run` parametrelidir (şehir kurucusu bütün kıyı boyunca bununla döşer).
## Eksenler: sur +x (doğu) boyunca uzanır; deniz +z (güney), şehir -z (kuzey). Merkez: sur parçasının tabanının ortası.
## k yalnız kütleyi ölçekler: yükseklik, kalınlık, kule boyu, kule aralığı. Kapı, basamak, korkuluk, yürüme yolu ≥ 1,4 m gerçek boyda.

const RISE := 0.34          # merdiven basamağı yüksekliği (STEP_H = 0,42 altında)
const RUN := 0.46
const GATE_W := 3.6         # kapı açıklığı (gerçek boy)
const GATE_H := 4.4


## TUR-14: yakın ve orta katmanda görünüş deniz suru kalemiyle (scripts/world/ist/deniz_set.gd; şehirdeki Haliç dilimi,
## SeaWalls, 18b/38o kesimi ile AYNI işlevler). Şehirde Haliç hattının çoğu (96 m'lik modüle sığmayan dilimler) ve bütün
## Marmara kıyısı buradan kurulur; eskiden kutu gövde, kutu kule, kutu diş, düz tuğla bant. Çarpışma kutuları birebir aynı
## (ağları gizli, `wall` metası; tests/_ist/tur14_marmara_sonda); yalnız görünen kutu süsler (kule kornişi, kutu diş, korkuluk
## kapağı, kutu kemer, mermer söve/lento kutusu, devşirme levha, oluk, yosun bandı, kaide) kurulmaz. Pencereli kurulumda
## (sehir.gd _pencere_is: 7 m'lik pencereler) yeni görünüş de pencereye kırpılır. `--eskisur` (çıplak) eskisini kurar.
static var _yeni := false
static var _gizlenecek: Array = []


static func _S(p: Node3D, size: Vector3, base: Vector3, col: Color, pat := "", rot_y := 0.0) -> StaticBody3D:
	var b := IstMk.S(p, size, base, col, pat, rot_y)
	if _yeni and b != IstMk._bos_s:
		_gizlenecek.append(b)
	return b


static func dims(k: float) -> Dictionary:
	var h := maxf(12.0 * k, 4.8)
	var t := maxf(3.4 * k, 2.7)
	var tw := maxf(8.0 * k, 4.8)
	var proj := maxf(4.2 * k, 2.4)
	var dh := maxf(2.5 * k, 1.2)
	var nst := int(ceil(dh / 0.3))
	var spacing := maxf(58.0 * k, tw + 2.0 * nst * 0.5 + 10.0)
	return {"H": h, "T": t, "TW": tw, "PROJ": proj, "DH": dh, "NST": nst, "S": spacing, "TH": h + dh}


## Kule merkezlerinin x konumu (sur parçası -L/2…+L/2)
static func tower_xs(length: float, k: float) -> Array:
	var d := dims(k)
	var xs: Array = []
	var s: float = d["S"]
	var n := maxi(int(floor(length / s)), 1)
	var x0 := -length * 0.5 + (length - (n - 1) * s) * 0.5
	for i in n:
		xs.append(x0 + i * s)
	return xs


## Merdivenin alt ucu (x) ve üst ucu: ilk iki kule arasındaki aralığın ortasında; tek kuleli parçada kulenin doğusunda.
static func stair_pos(length: float, k: float, opts := {}) -> Dictionary:
	var d := dims(k)
	var xs := tower_xs(length, k)
	var h: float = d["H"]
	var n := int(ceil(h / RISE))
	var l := n * RUN
	var mid: float
	if xs.size() >= 2:
		mid = (float(xs[0]) + float(xs[1])) * 0.5
	else:
		mid = float(xs[0]) + float(d["S"]) * 0.5
	if opts.has("stair_mid"):
		mid = float(opts["stair_mid"])
	mid = clampf(mid, -length * 0.5 + l * 0.5 + 1.0, length * 0.5 - l * 0.5 - 1.0)
	return {"n": n, "x_top": mid + l * 0.5, "x_foot": mid - l * 0.5, "len": l}


## Kapı konumları (varsayılan: ikinci aralığın ortası; yalnız 3+ kuleli parçada).
static func gate_xs(length: float, k: float, opts: Dictionary) -> Array:
	if opts.has("kapi"):
		return opts["kapi"]
	var xs := tower_xs(length, k)
	if xs.size() >= 3:
		return [(float(xs[1]) + float(xs[2])) * 0.5]
	return []


static func build_run(host: Node3D, length: float, k: float, lod: int, opts := {}) -> void:
	var d := dims(k)
	var H: float = d["H"]
	var T: float = d["T"]
	var TW: float = d["TW"]
	var PROJ: float = d["PROJ"]
	var TH: float = d["TH"]
	var DH: float = d["DH"]
	var NST: int = d["NST"]
	var root := IstMk.root(host, "MarmaraSur")
	var xs := tower_xs(length, k)
	var gates := gate_xs(length, k, opts)
	var x0 := -length * 0.5
	var x1 := length * 0.5
	_yeni = lod < 2 and not SurSet.eski_istendi("")
	_gizlenecek = []
	if lod >= 2:
		IstMk.S(root, Vector3(length, H, T), Vector3(0, 0, 0), IstMk.STONE, "ashlar")
		for x: float in xs:
			IstMk.S(root, Vector3(TW, TH, T + PROJ), Vector3(x, 0, PROJ * 0.5), IstMk.STONE_DK, "ashlar")
		return
	# --- sur gövdesi: kapı aralıklarında bölünür; kapı üstü lento
	var cuts: Array = [x0]
	for gx: float in gates:
		cuts.append(gx - GATE_W * 0.5)
		cuts.append(gx + GATE_W * 0.5)
	cuts.append(x1)
	var i := 0
	while i < cuts.size():
		var a: float = cuts[i]
		var b: float = cuts[i + 1]
		if b - a > 0.05:
			_S(root, Vector3(b - a, H, T), Vector3((a + b) * 0.5, 0, 0), IstMk.STONE, "ashlar")
		i += 2
	for gx: float in gates:
		_gate(root, gx, H, T, lod)
	# --- kuleler
	for x: float in xs:
		_tower(root, x, d, lod)
	# --- yürüme yolu: parapetler, mazgallar
	var gap_x0 := -1e9
	var gap_x1 := -1e9
	var st := stair_pos(length, k, opts)
	var stair_on: bool = opts.get("merdiven", true)
	if stair_on:
		gap_x0 = float(st["x_top"]) - 3.0 * RUN - 0.8
		gap_x1 = float(st["x_top"])
	_parapets(root, d, x0, x1, xs, gap_x0, gap_x1, lod)
	# --- merdiven (şehir yüzü)
	if stair_on:
		_stair(root, d, st, lod)
	if lod >= 1:
		_plinth(root, length, d)
	if lod == 0:
		_details(root, length, d, xs, gates, opts)
	if _yeni:
		for b: StaticBody3D in _gizlenecek:
			DENIZ.gizle(b)
		_yeni_gorunus(root, length, d, xs, gates, gap_x0, gap_x1, lod)
	_yeni = false
	_gizlenecek = []


const DENIZ := preload("res://scripts/world/ist/deniz_set.gd")


## Pencere (IstMk.pencere) ile x0…x1'in kesişimi; boşsa Vector2(1, 0)
static func _kirp(a: float, b: float) -> Vector2:
	return Vector2(maxf(a, IstMk.pencere.x), minf(b, IstMk.pencere.y))


## Yeni görünüş (deniz suru kalemi): gövde (kapı açıklıkları, su çizgisinde kaide), deniz korkuluğu + dişler, şehir
## korkuluğu (merdiven ağzı açık), kuleler (eski kutu kulenin ayak izi ve tepesi; teras korkuluğu ve dişleri), kapı süsleri
## (iki yüzde söve, lento, boşaltma kemeri). Deniz +z, şehir −z.
static func _yeni_gorunus(root: Node3D, length: float, d: Dictionary, xs: Array, gates: Array, gap_x0: float, gap_x1: float, lod: int) -> void:
	var H: float = d["H"]
	var T: float = d["T"]
	var TW: float = d["TW"]
	var NST: int = d["NST"]
	var x0 := -length * 0.5
	var x1 := length * 0.5
	var tam := IstMk.pencere.x < -1e8 and IstMk.pencere.y > 1e8
	var g := {"zf": T * 0.5, "s": 1.0, "T": T, "H": H, "dip": -0.6, "su": 0.0, "ic_dip": 0.0, "lod": lod,
		"tohum": 211, "kaide": 0.55, "kaide_y": 0.6, "uclar": tam, "kz": T * 0.5, "PT": 0.5, "PH": 1.9 if lod == 0 else 1.4, "yol": H}
	var gh := minf(GATE_H, H - 1.3)
	var acik: Array = []
	for gx: float in gates:
		acik.append({"a": gx - GATE_W * 0.5, "b": gx + GATE_W * 0.5, "y0": 0.0, "y1": gh, "esik": false})
	var kg := _kirp(x0, x1)
	if kg.y - kg.x > 0.05:
		var ak: Array = []
		for a: Dictionary in acik:
			if float(a["b"]) > kg.x and float(a["a"]) < kg.y:
				var a2 := a.duplicate()
				a2["a"] = maxf(float(a["a"]), kg.x)
				a2["b"] = minf(float(a["b"]), kg.y)
				ak.append(a2)
		DENIZ.govde(root, kg.x, kg.y, g, ak, "MarmaraSurGovde")
	# korkuluklar (eski _parapets ile aynı bölme: kule + kule basamakları dışında kalan şeritler)
	var gs := g.duplicate()
	gs["s"] = -1.0
	gs["kz"] = -T * 0.5
	gs["PT"] = 0.4
	gs["PH"] = 1.05
	var blocks: Array = []
	for x: float in xs:
		blocks.append([x - TW * 0.5 - NST * 0.5, x + TW * 0.5 + NST * 0.5])
	var segs: Array = []
	var cur := x0
	for bl in blocks:
		if float(bl[0]) > cur:
			segs.append([cur, minf(float(bl[0]), x1)])
		cur = maxf(cur, float(bl[1]))
	if cur < x1:
		segs.append([cur, x1])
	var si := 0
	for sg in segs:
		si += 1
		var a: float = sg[0]
		var b: float = sg[1]
		if b - a < 0.4:
			continue
		var k2 := _kirp(a, b)
		if k2.y - k2.x > 0.05:
			DENIZ.korkuluk(root, k2.x, k2.y, g, [], "MarmaraKorkulukDeniz")
			DENIZ.korkuluk(root, k2.x, k2.y, gs, [Vector2(gap_x0, gap_x1)], "MarmaraKorkulukSehir")
		if lod == 0:
			var n := int(floor((b - a) / 1.7))
			var mx: Array = []
			for i in n:
				var px := a + (i + 0.5) * (b - a) / n
				if IstMk._ic(px):
					mx.append(px)
			DENIZ.disler(root, mx, 0.95, 0.8, g, 2110 + si)
	# kuleler (eski kutu kulenin ayak izi: x ± TW/2, z −T/2 … T/2 + PROJ; tepe TH)
	var ti := 0
	for x: float in xs:
		ti += 1
		if not IstMk._ic(x):
			continue
		DENIZ.kule(root, {"cx": x, "w": TW, "zi": -T * 0.5, "zo": T * 0.5 + float(d["PROJ"]), "HT": float(d["TH"]), "yb": H,
			"pah": 0.0, "bat": 0.0, "tohum": 2130 + ti * 13, "yarik": 3}, g, "MarmaraKule")
	if lod == 0:
		for gx: float in gates:
			if not IstMk._ic(gx):
				continue
			DENIZ.kapi_kemer(root, gx, GATE_W * 0.5, 0.0, gh, g, {"soveler": true})
			DENIZ.kapi_kemer(root, gx, GATE_W * 0.5, 0.0, gh, gs, {"soveler": true, "kitabe": true})


static func _plinth(root: Node3D, length: float, d: Dictionary) -> void:
	var T: float = d["T"]
	# deniz yüzünde kaya ayak (talus): sur tabanına yaslı, 1,2 m yüksek, 0,55 m öne taşan
	_S(root, Vector3(length, 1.2, 0.55), Vector3(0, 0, T * 0.5 + 0.275), IstMk.ROCK, "rubble")


static func _gate(root: Node3D, gx: float, H: float, T: float, lod: int) -> void:
	var gh := minf(GATE_H, H - 1.3)
	# lento (kapı üstü sur gövdesi)
	_S(root, Vector3(GATE_W + 0.02, H - gh, T), Vector3(gx, gh, 0), IstMk.STONE, "ashlar")
	if lod >= 1:
		return
	if _yeni:
		# kapı süsü deniz kaleminden (kapi_kemer); açık kanatlar tahta tahta (IstSurlarKapi.kanat_ag), eşik taşı aynı
		IstMk.V(root, Vector3(GATE_W + 0.6, 0.04, T + 1.2), Vector3(gx, 0.0, 0), IstMk.STONE_DK, "flagstone")
		if IstMk._ic(gx):
			var tahta = DENIZ.SURKULE.Ag.new()
			var demir = DENIZ.SURKULE.Ag.new()
			for sx: float in [-1.0, 1.0]:
				# kanat yerel x boyunca (−0,625 … 0,625), kalınlık z (−0,09 … 0,09); dünyada z boyunca, iç yüzü geçide
				var b := Basis(Vector3.UP, deg_to_rad(90.0 * sx))
				var o := Vector3(gx + sx * (GATE_W * 0.5 - 0.09), 0.0, T * 0.5 - 0.7)
				var ta = DENIZ.SURKULE.Ag.new()
				var de = DENIZ.SURKULE.Ag.new()
				IstSurlarKapi.kanat_ag(ta, de, -0.625, 0.625, gh - 0.3, -0.09, 0.18, gx * 1.7 + sx * 5.0)
				for pair: Array in [[ta, tahta], [de, demir]]:
					var src: Mesh = (pair[0] as RefCounted).st.commit()
					if src.get_surface_count() > 0:
						var arr := src.surface_get_arrays(0)
						var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
						var ns: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
						var cs: PackedColorArray = arr[Mesh.ARRAY_COLOR]
						for vi in vs.size():
							(pair[1] as RefCounted).st.set_color(cs[vi])
							(pair[1] as RefCounted).st.set_normal(b * ns[vi])
							(pair[1] as RefCounted).st.add_vertex(o + b * vs[vi])
						(pair[1] as RefCounted).n += vs.size() / 3
			tahta.mesh_ekle(root, IstSurlarKapi.kanat_mat(), "Ahsap_KanatTahta")
			demir.mesh_ekle(root, Props.mat(IstMk.DARK, 0.0, false, ""), "Demir_KanatKusak", false)
		return
	# mermer lento kirişi + boşaltma kemeri + dolgu (tympanum)
	IstMk.V(root, Vector3(GATE_W + 0.7, 0.4, 0.14), Vector3(gx, gh - 0.4, T * 0.5 + 0.07), IstMk.MARBLE, "marble")
	IstMk.V(root, Vector3(GATE_W + 0.7, 0.4, 0.14), Vector3(gx, gh - 0.4, -T * 0.5 - 0.07), IstMk.MARBLE, "marble")
	var ar := (GATE_W + 0.5) * 0.5
	for sgn: float in [1.0, -1.0]:
		var zf: float = sgn * (T * 0.5 + 0.06)
		IstMk.V(root, Vector3(ar * 2.0, ar, 0.1), Vector3(gx, gh, zf), IstMk.DARK, "")
		IstMk.ARCH(root, Vector3(gx, gh, zf), ar, 0.45, 0.2, IstMk.BRICK, "brick", 13)
		# kapı yanlarında devşirme mermer söve
		for sx: float in [-1.0, 1.0]:
			IstMk.V(root, Vector3(0.4, gh, 0.16), Vector3(gx + sx * (GATE_W * 0.5 + 0.2), 0, zf * 1.0), IstMk.MARBLE, "marble")
	# kapı kanatları açık: yanlara yaslı (yolu kapatmaz)
	for sx: float in [-1.0, 1.0]:
		IstMk.V(root, Vector3(0.18, gh - 0.3, 1.25), Vector3(gx + sx * (GATE_W * 0.5 - 0.09), 0, T * 0.5 - 0.7), IstMk.WOOD, "wood")
		IstMk.V(root, Vector3(0.2, 0.12, 1.28), Vector3(gx + sx * (GATE_W * 0.5 - 0.09), 1.0, T * 0.5 - 0.7), IstMk.DARK, "")
		IstMk.V(root, Vector3(0.2, 0.12, 1.28), Vector3(gx + sx * (GATE_W * 0.5 - 0.09), 2.6, T * 0.5 - 0.7), IstMk.DARK, "")
	# eşik taşı: zeminde kaldırım levhası
	IstMk.V(root, Vector3(GATE_W + 0.6, 0.04, T + 1.2), Vector3(gx, 0.0, 0), IstMk.STONE_DK, "flagstone")
	# tabelalık: kapı üstünde sur yüzüne gömülü haç kabartması
	IstMk.V(root, Vector3(0.16, 0.9, 0.08), Vector3(gx, gh + ar + 0.8, T * 0.5 + 0.04), IstMk.MARBLE)
	IstMk.V(root, Vector3(0.6, 0.16, 0.08), Vector3(gx, gh + ar + 1.25, T * 0.5 + 0.04), IstMk.MARBLE)


static func _tower(root: Node3D, x: float, d: Dictionary, lod: int) -> void:
	var H: float = d["H"]
	var T: float = d["T"]
	var TW: float = d["TW"]
	var PROJ: float = d["PROJ"]
	var TH: float = d["TH"]
	var NST: int = d["NST"]
	var DH: float = d["DH"]
	var zc := PROJ * 0.5
	var depth := T + PROJ
	# gövde (denize doğru taşan dikdörtgen kule)
	_S(root, Vector3(TW, TH, depth), Vector3(x, 0, zc), IstMk.STONE_DK, "ashlar")
	if lod >= 1:
		if not _yeni:
			IstMk.V(root, Vector3(TW + 0.3, 0.4, depth + 0.3), Vector3(x, TH - 0.4, zc), IstMk.STONE, "ashlar")
		return
	# tepe kornişi (tuğla dişli) ve üst platform çevresi parapet
	if not _yeni:
		IstMk.V(root, Vector3(TW + 0.5, 0.18, depth + 0.5), Vector3(x, TH - 0.5, zc), IstMk.BRICK, "brick")
		IstMk.V(root, Vector3(TW + 0.3, 0.3, depth + 0.3), Vector3(x, TH - 0.32, zc), IstMk.STONE, "ashlar")
	var zs := T * 0.5 + PROJ - 0.25
	var zn := -T * 0.5 + 0.2
	# parapet çarpışmaları (üç dış yan); kule üstü derinlik boyunca
	_S(root, Vector3(TW, 1.6, 0.5), Vector3(x, TH, zs), IstMk.STONE, "ashlar")
	_S(root, Vector3(0.5, 1.6, depth - 0.0), Vector3(x - TW * 0.5 + 0.25, TH, zc), IstMk.STONE, "ashlar")
	_S(root, Vector3(0.5, 1.6, depth - 0.0), Vector3(x + TW * 0.5 - 0.25, TH, zc), IstMk.STONE, "ashlar")
	# kuzey (şehir) tarafı: alçak korkuluk, ortası açık değil, sağ-sol yürüme yolu merdiveniyle birleşir
	_S(root, Vector3(TW, 1.0, 0.4), Vector3(x, TH, zn), IstMk.STONE, "ashlar")
	# mazgal dişleri
	var xf: Array = []
	var n := int(floor(TW / 1.6))
	for i in n:
		var px := x - TW * 0.5 + (i + 0.5) * TW / n
		xf.append([Vector3(px, TH + 1.6 + 0.4, zs), 0.0])
	for sx: float in [-1.0, 1.0]:
		var m := int(floor(depth / 1.6))
		for j in m:
			var pz := T * 0.5 + PROJ - 0.25 - (j + 0.5) * (depth - 0.5) / m
			xf.append([Vector3(x + sx * (TW * 0.5 - 0.25), TH + 1.6 + 0.4, pz), 90.0])
	if not _yeni:
		IstMk.MM(root, Vector3(0.9, 0.8, 0.52), xf, IstMk.STONE, "ashlar")
	# yürüme yolundan kule üstüne çıkan basamaklar (iki yan): kule yanlarında, sur üstü şeridi içinde
	var wwid := T - 0.9
	var zwc := (-T * 0.5 + 0.4 + (T * 0.5 - 0.5)) * 0.5
	for sx: float in [-1.0, 1.0]:
		var foot := Vector3(x + sx * (TW * 0.5 + NST * 0.5), H, zwc)
		var dir := Vector3(-sx, 0, 0)
		var rise := DH / NST
		# basamak üstleri H + rise … H + DH; kule gövdesine dayanır
		for i in NST:
			var top := rise * (i + 1)
			var c := foot + dir * (0.5 * (i + 0.5))
			IstMk.V(root, Vector3(0.5 + 0.02, top, wwid), Vector3(c.x, H, c.z), IstMk.STONE, "ashlar")
		# Çarpışma: basamak ortalarından geçen tek rampa (ŞEHİR-3: oyuncu kutu basamakların önünde takılıyordu)
		if IstMk._ic(foot.x):
			rampa(root, foot + Vector3(0, rise * 0.5, 0), foot + dir * (0.5 * NST - 0.25) + Vector3(0, rise * NST, 0), wwid)
	if _yeni:
		# ok yarıkları, kornişler, dişler deniz kaleminin kulesinde; bayrak direği teras döşemesinden (eskisi korkuluk
		# boyu kadar havadaydı), kazan aynı
		IstMk.CY(root, 0.05, 4.4, Vector3(x - TW * 0.5 + 0.9, TH, zc), IstMk.WOOD_DK, "", 5)
		IstMk.V(root, Vector3(0.04, 0.7, 1.2), Vector3(x - TW * 0.5 + 0.9, TH + 1.6 + 1.9, zc + 0.65), IstMk.GOLD)
		IstMk.V(root, Vector3(0.05, 0.7, 0.35), Vector3(x - TW * 0.5 + 0.9, TH + 1.6 + 1.9, zc + 0.2), IstMk.RED)
		IstMk.CY(root, 0.3, 0.45, Vector3(x + TW * 0.25, TH, zc + 0.2), IstMk.DARK, "", 8, true)
		return
	# ok yarıkları ve pencere: deniz yüzünde iki sıra
	var slit: Array = []
	for sx: float in [-0.3, 0.0, 0.3]:
		slit.append([Vector3(x + sx * TW, H * 0.55, T * 0.5 + PROJ + 0.01), 0.0])
	IstMk.MM(root, Vector3(0.16, 1.1, 0.06), slit, IstMk.DARK)
	var win: Array = []
	win.append([Vector3(x, H + DH * 0.0 + (TH - H) * 0.0 + H * 0.2, T * 0.5 + PROJ + 0.01), 0.0])
	IstMk.MM(root, Vector3(0.5, 0.9, 0.06), win, IstMk.DARK)
	# bayrak direği (bayrak yalnız kuzey ucundaki kulelerde değil, her kulede kırmızı-altın)
	IstMk.CY(root, 0.05, 2.8, Vector3(x - TW * 0.5 + 0.9, TH + 1.6, zc), IstMk.WOOD_DK, "", 5)
	IstMk.V(root, Vector3(0.04, 0.7, 1.2), Vector3(x - TW * 0.5 + 0.9, TH + 1.6 + 1.9, zc + 0.65), IstMk.GOLD)
	IstMk.V(root, Vector3(0.05, 0.7, 0.35), Vector3(x - TW * 0.5 + 0.9, TH + 1.6 + 1.9, zc + 0.2), IstMk.RED)
	# yağ ocağı: bakır kazan + odun (ateş yalnız kule başına bir)
	IstMk.CY(root, 0.3, 0.45, Vector3(x + TW * 0.25, TH, zc + 0.2), IstMk.DARK, "", 8, true)
	# duvar kandili
	IstMk.V(root, Vector3(0.1, 0.18, 0.1), Vector3(x, TH + 1.15, zs - 0.28), IstMk.DARK)
	# sur yüzünde devşirme: kule köşesinde mermer sütun kütüğü
	IstMk.CYR(root, 0.28, 1.0, Vector3(x - TW * 0.5 + 0.7, TH * 0.4, T * 0.5 + PROJ + 0.1), IstMk.MARBLE, Vector3(90, 0, 0), "marble", 8)


static func _parapets(root: Node3D, d: Dictionary, x0: float, x1: float, xs: Array, gap_x0: float, gap_x1: float, lod: int) -> void:
	var H: float = d["H"]
	var T: float = d["T"]
	var TW: float = d["TW"]
	var NST: int = d["NST"]
	# parapet aralıkları: kuleler (gövde + basamaklar) dışında kalan şeritler
	var blocks: Array = []        # [a, b] kapalı aralıklar (kule+basamak)
	for x: float in xs:
		blocks.append([x - TW * 0.5 - NST * 0.5, x + TW * 0.5 + NST * 0.5])
	var segs: Array = []
	var cur := x0
	for bl in blocks:
		if float(bl[0]) > cur:
			segs.append([cur, minf(float(bl[0]), x1)])
		cur = maxf(cur, float(bl[1]))
	if cur < x1:
		segs.append([cur, x1])
	var merl: Array = []
	for sg in segs:
		var a: float = sg[0]
		var b: float = sg[1]
		if b - a < 0.4:
			continue
		var cx := (a + b) * 0.5
		# deniz parapeti (kalın, mazgallı)
		var hsea := 1.9 if lod == 0 else 1.4
		_S(root, Vector3(b - a, hsea, 0.5), Vector3(cx, H, T * 0.5 - 0.25), IstMk.STONE, "ashlar")
		if lod == 0:
			var n := int(floor((b - a) / 1.7))
			for i in n:
				merl.append([Vector3(a + (i + 0.5) * (b - a) / n, H + 1.9 + 0.4, T * 0.5 - 0.25), 0.0])
		# şehir parapeti (alçak, merdiven ağzında kesik)
		var segs2: Array = [[a, b]]
		if gap_x1 > a and gap_x0 < b:
			segs2 = []
			if gap_x0 > a + 0.3:
				segs2.append([a, gap_x0])
			if gap_x1 < b - 0.3:
				segs2.append([gap_x1, b])
		for s2 in segs2:
			var a2: float = s2[0]
			var b2: float = s2[1]
			_S(root, Vector3(b2 - a2, 1.05, 0.4), Vector3((a2 + b2) * 0.5, H, -T * 0.5 + 0.2), IstMk.STONE, "ashlar")
			if lod == 0 and not _yeni:
				IstMk.V(root, Vector3(b2 - a2 + 0.1, 0.1, 0.55), Vector3((a2 + b2) * 0.5, H + 1.05, -T * 0.5 + 0.2), IstMk.STONE_DK)
	if lod == 0 and merl.size() > 0 and not _yeni:
		IstMk.MM(root, Vector3(0.95, 0.8, 0.52), merl, IstMk.STONE, "ashlar")


static func _stair(root: Node3D, d: Dictionary, st: Dictionary, lod: int) -> void:
	var H: float = d["H"]
	var T: float = d["T"]
	var n: int = st["n"]
	var xf: float = st["x_foot"]
	var zc := -T * 0.5 - 0.85
	var foot := Vector3(xf, 0.0, zc)
	var dir := Vector3(1, 0, 0)
	# n basamak, rise = H / n (sürekli artan); üst basamak üstü tam H
	var rise := H / n
	for i in n:
		var top := rise * (i + 1)
		IstMk.S(root, Vector3(RUN + 0.02, top, 1.7), Vector3(xf + RUN * (i + 0.5), 0, zc), IstMk.STONE, "ashlar")
	# dış korkuluk: eğimli katı şerit
	var total := Vector3(RUN * n, rise * n, 0)
	var length := total.length()
	var mid := Vector3(xf, 0, zc - 0.85 - 0.11) + total * 0.5 + Vector3(0, 0.55, 0)
	if not IstMk._ic(mid.x):
		return
	var b := Props.solid(root, Vector3(length, 1.1, 0.22), mid, IstMk.STONE_DK)
	b.rotation = Vector3(0, 0, atan2(total.y, total.x))
	Props.set_pattern(b, IstMk.STONE_DK, "ashlar")


static func _details(root: Node3D, length: float, d: Dictionary, xs: Array, gates: Array, opts: Dictionary) -> void:
	var H: float = d["H"]
	var T: float = d["T"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	# devşirme mermer bloklar ve sütun kütükleri (kule dışı)
	var sp: Array = []
	var dr: Array = []
	var cnt := maxi(int(length / 7.0), 3)
	for i in cnt:
		var x := rng.randf_range(-length * 0.5 + 2.0, length * 0.5 - 2.0)
		var near := false
		for tx: float in xs:
			if absf(x - tx) < float(d["TW"]) * 0.5 + 1.0:
				near = true
		for gx: float in gates:
			if absf(x - gx) < GATE_W:
				near = true
		if near:
			continue
		var y := rng.randf_range(1.4, H - 2.0)
		if i % 3 == 0:
			dr.append(Transform3D(Basis(Vector3.RIGHT, deg_to_rad(90.0)), Vector3(x, y, T * 0.5 + 0.1)))
		else:
			sp.append([Vector3(x, y, T * 0.5 + 0.035), 0.0])
	if sp.size() > 0 and not _yeni:
		IstMk.MM(root, Vector3(rng.randf_range(0.7, 1.1), 0.5, 0.08), sp, IstMk.MARBLE, "marble")
	if dr.size() > 0:
		IstMk.MMC(root, 0.26, 0.6, dr, IstMk.MARBLE, 8, "marble")
	# yağmur suyu olukları (denize taşan)
	var spouts: Array = []
	for i in maxi(int(length / 12.0), 1):
		spouts.append([Vector3(-length * 0.5 + 4.0 + i * 12.0, H - 0.4, T * 0.5 + 0.3), 0.0])
	if not _yeni:
		IstMk.MM(root, Vector3(0.25, 0.2, 0.7), spouts, IstMk.STONE_DK, "ashlar")
		# su hattında yosun bandı ve midye taşı (yeni görünüşte gövdenin kaidesi)
		IstMk.V(root, Vector3(length, 0.5, 0.58), Vector3(0, 0.0, T * 0.5 + 0.28), IstMk.MOSS, "rubble")
	# şehir yüzünde: sur dibinde istif (sandık yığını) — alçak ahşap yığın, tırmanma yardımcısı
	var cx: float = opts.get("sandik_x", -length * 0.5 + 5.0)
	IstMk.S(root, Vector3(1.0, 0.5, 1.0), Vector3(cx, 0, -T * 0.5 - 0.8), IstMk.WOOD, "wood")
	IstMk.S(root, Vector3(0.9, 0.4, 0.9), Vector3(cx + 0.9, 0, -T * 0.5 - 0.8), IstMk.WOOD_LT, "wood")
	# şehir yüzünde kapı fenerleri
	for gx: float in gates:
		IstMk.V(root, Vector3(0.12, 0.3, 0.12), Vector3(gx - GATE_W * 0.5 - 0.5, 3.0, -T * 0.5 - 0.1), IstMk.DARK)
		Flame.add(root, Vector3(gx - GATE_W * 0.5 - 0.5, 3.3, -T * 0.5 - 0.1), 0.22, 0.34)


## --- kayıt işlevleri (tek parça: üç kuleli, bir kapılı, bir merdivenli koşu) -----------------------------------
static func run_len(k: float) -> float:
	return 3.0 * float(dims(k)["S"])


static func build_msur(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	build_run(host, run_len(k), k, lod, {})


static func perches_msur(k: float = 0.5) -> Array:
	var d := dims(k)
	var out: Array = []
	var zc: float = float(d["PROJ"]) * 0.5
	for x: float in tower_xs(run_len(k), k):
		out.append(Vector3(x, float(d["TH"]), zc))
	return out


static func climbs_msur(k: float = 0.5) -> Array:
	var d := dims(k)
	var st := stair_pos(run_len(k), k)
	var T: float = d["T"]
	var zc := -T * 0.5 - 0.85
	var xt: float = st["x_top"]
	return [
		[Vector3(float(st["x_foot"]) - 0.4, 0.0, zc), Vector3(xt - 0.25, float(d["H"]), zc), "merdiven"],
		[Vector3(xt - 0.2, float(d["H"]), zc), Vector3(xt - 0.2, float(d["H"]), -T * 0.5 + 0.9), "basamak"],
	]


## Yalnız çarpışma rampası: a (alt) → b (üst), üst yüzü a–b doğrusunda, en w
static func rampa(root: Node3D, a: Vector3, b: Vector3, w: float) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = "Rampa"
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	var L := a.distance_to(b)
	bs.size = Vector3(w, 0.3, L)
	cs.shape = bs
	body.add_child(cs)
	var bas := Basis.looking_at((b - a).normalized(), Vector3.UP)
	body.transform = Transform3D(bas, (a + b) * 0.5 - bas.y * 0.15)
	root.add_child(body)
	return body
