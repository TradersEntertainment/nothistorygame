class_name IstMarmaraBukoleon
extends RefCounted
## Bukoleon Sarayı (Boukoleon) deniz cephesi, Nisan 1453: Büyük Saray'ın Marmara'ya bakan kalıntısı (harap).
## Eksen: cephe doğu-batı (+x), deniz +z (güney). Merkez: cephenin tabanının ortası (zemin y = 0).
## Kurulum: gövde kitlesi, kıyı rıhtımı, üç büyük mermer çerçeveli pencere + balkonlar, deniz kapısı tüneli, aslan-boğa
## heykelleri, saray iskelesi (ahşap), batıda kiremitli salon + kurşun kubbe, doğuda yıkık tonoz ve kubbe kasnağı.
## Doğu ucundaki dış merdiven rıhtımdan teras çatıya çıkar.


static func dims(k: float) -> Dictionary:
	var w := maxf(64.0 * k, 34.0)
	var d := maxf(20.0 * k, 11.0)
	var h := maxf(17.0 * k, 8.6)
	return {"W": w, "D": d, "H": h, "QD": 7.0}


static func stair_info(k: float) -> Dictionary:
	var dm := dims(k)
	var n := int(ceil(float(dm["H"]) / 0.34))
	var l := n * 0.46
	var zt := -float(dm["D"]) * 0.5 + 3.0
	return {"n": n, "len": l, "z_top": zt, "z_foot": zt + l, "x": float(dm["W"]) * 0.5 + 1.0}


static func build_bukoleon(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var dm := dims(k)
	var W: float = dm["W"]
	var D: float = dm["D"]
	var H: float = dm["H"]
	var QD: float = dm["QD"]
	var root := IstMk.root(host, "Bukoleon")
	var gate_x := -W * 0.30
	var GW := 3.6
	var GH := 3.7
	if lod >= 2:
		IstMk.S(root, Vector3(W, H, D), Vector3.ZERO, IstMk.STONE, "ashlar")
		IstMk.S(root, Vector3(W + 6.0, 0.3, QD + 2.0), Vector3(0, 0, D * 0.5 + QD * 0.5), IstMk.STONE_DK, "flagstone")
		var r := maxf(4.5 * k, 2.8)
		IstMk.ROOF(root, Vector3(W * 0.4, 2.2, D - 4.0), Vector3(-W * 0.28, H, 0), IstMk.TILE, "tiles", 90.0)
		var dr := IstMk.CY(root, r, 2.0, Vector3(W * 0.14, H, 0), IstMk.STONE, "ashlar", 8, true)
		return
	# ---- gövde: kapı tünelinde bölünür; üst lento
	var segs: Array = [[-W * 0.5, gate_x - GW * 0.5], [gate_x + GW * 0.5, W * 0.5]]
	for sg in segs:
		var a: float = sg[0]
		var b: float = sg[1]
		IstMk.S(root, Vector3(b - a, H, D), Vector3((a + b) * 0.5, 0, 0), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(GW + 0.02, H - GH, D), Vector3(gate_x, GH, 0), IstMk.STONE, "ashlar")
	# ---- rıhtım (deniz önü): hafif yüksek levha (zeminle çakışmasın) + kenar duvarı denize iner
	var qx := W + 8.0
	IstMk.S(root, Vector3(qx, 0.08, QD), Vector3(0, 0, D * 0.5 + QD * 0.5), IstMk.STONE_DK, "flagstone")
	IstMk.S(root, Vector3(qx, 3.0, 0.9), Vector3(0, -3.0, D * 0.5 + QD - 0.45), IstMk.STONE_DK, "ashlar")
	IstMk.S(root, Vector3(qx, 0.35, 0.9), Vector3(0, 0.0, D * 0.5 + QD - 0.45), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(0.9, 3.3, QD), Vector3(-qx * 0.5 + 0.45, -3.0, D * 0.5 + QD * 0.5), IstMk.STONE_DK, "ashlar")
	IstMk.S(root, Vector3(0.9, 3.3, QD), Vector3(qx * 0.5 - 0.45, -3.0, D * 0.5 + QD * 0.5), IstMk.STONE_DK, "ashlar")
	if lod >= 1:
		# orta ayrıntı: ana kütleler + çatı + kubbe + merdiven + iskele
		_roofs(root, dm, k, lod)
		_stair(root, dm, k, lod)
		IstMk.S(root, Vector3(2.4, 0.2, 10.0), Vector3(-W * 0.12, 0.0, D * 0.5 + QD + 5.0), IstMk.WOOD, "wood")
		return
	_facade(root, dm, k, gate_x, GW, GH)
	_gate_tunnel(root, dm, gate_x, GW, GH)
	_roofs(root, dm, k, lod)
	_stair(root, dm, k, lod)
	_quay_details(root, dm, k)
	_lions(root, dm, gate_x, GW)
	_jetty(root, dm, k)
	_ruin_east(root, dm, k)


static func _facade(root: Node3D, dm: Dictionary, k: float, gate_x: float, GW: float, GH: float) -> void:
	var W: float = dm["W"]
	var D: float = dm["D"]
	var H: float = dm["H"]
	var zf := D * 0.5
	var yb := H * 0.42
	var hs := H * 0.20
	var wr := 1.5
	# --- ocak: tuğla-taş bant (korniş) ve alt kaide
	IstMk.V(root, Vector3(W + 0.5, 0.45, D + 0.5), Vector3(0, H - 0.6, 0), IstMk.BRICK, "brick")
	IstMk.V(root, Vector3(W + 0.4, 0.5, D + 0.4), Vector3(0, yb - 1.6, 0), IstMk.STONE_DK, "ashlar")
	# kaide: sur yüzü tabanında kaya şerit
	IstMk.V(root, Vector3(W + 0.2, 1.1, 0.4), Vector3(0, 0, zf + 0.2), IstMk.ROCK, "rubble")
	# --- zemin kat: kör kemerler (kapı hariç)
	var spacing := 6.4
	var nn := int(floor((W - 6.0) / spacing))
	var niches: Array = []
	for i in nn:
		var x := -W * 0.5 + 3.4 + i * spacing
		if absf(x - gate_x) < GW + 1.6:
			continue
		niches.append(x)
	for x: float in niches:
		IstMk.V(root, Vector3(2.6, 3.0, 0.07), Vector3(x, 0.8, zf + 0.02), IstMk.DARK)
		IstMk.ARCH(root, Vector3(x, 3.8, zf + 0.04), 1.3, 0.4, 0.14, IstMk.BRICK, "brick", 11)
		IstMk.V(root, Vector3(2.6, 0.3, 0.12), Vector3(x, 0.5, zf + 0.04), IstMk.STONE_DK, "ashlar")
	# --- üç büyük pencere + balkon
	var wxs := [-6.4, 0.0, 6.4]
	for wx: float in wxs:
		IstMk.V(root, Vector3(3.0, hs + 0.4, 0.07), Vector3(wx, yb, zf + 0.02), IstMk.DARK)
		IstMk.V(root, Vector3(3.0, 0.1, 0.1), Vector3(wx, yb - 0.05, zf + 0.04), IstMk.MARBLE, "marble")
		IstMk.ARCH(root, Vector3(wx, yb + hs, zf + 0.05), wr, 0.45, 0.2, IstMk.MARBLE, "marble", 11)
		IstMk.V(root, Vector3(2.0 * wr, wr, 0.05), Vector3(wx, yb + hs, zf + 0.02), Color("3a342c"))
		# mermer sütunçeler (yarım yuvarlak, yüzeye bitişik) ve başlıklar
		for sx: float in [-1.0, 1.0]:
			var cx := wx + sx * (wr + 0.15)
			IstMk.CY(root, 0.16, hs + 0.3, Vector3(cx, yb - 0.05, zf + 0.12), IstMk.MARBLE, "marble", 8)
			IstMk.V(root, Vector3(0.42, 0.2, 0.4), Vector3(cx, yb + hs + 0.2, zf + 0.12), IstMk.MARBLE, "marble")
			IstMk.V(root, Vector3(0.42, 0.14, 0.4), Vector3(cx, yb - 0.17, zf + 0.12), IstMk.MARBLE, "marble")
		# balkon: katı mermer levha + üç konsol + korkuluk
		IstMk.S(root, Vector3(4.6, 0.32, 1.9), Vector3(wx, yb - 0.32, zf + 0.95), IstMk.MARBLE, "marble")
		for bx: float in [-1.7, 0.0, 1.7]:
			IstMk.V(root, Vector3(0.34, 0.9, 0.9), Vector3(wx + bx, yb - 1.32, zf + 0.5), IstMk.MARBLE, "marble")
			IstMk.V(root, Vector3(0.3, 0.6, 0.6), Vector3(wx + bx, yb - 1.55, zf + 0.25), IstMk.STONE_DK, "ashlar", Vector3(0, 0, 0))
		# balkon korkuluğu: ön ve yanlar (çarpışma + babalı sütunçeler)
		IstMk.S(root, Vector3(4.6, 0.95, 0.18), Vector3(wx, yb, zf + 1.8), IstMk.MARBLE, "marble")
		IstMk.S(root, Vector3(0.18, 0.95, 1.7), Vector3(wx - 2.2, yb, zf + 0.95), IstMk.MARBLE, "marble")
		IstMk.S(root, Vector3(0.18, 0.95, 1.7), Vector3(wx + 2.2, yb, zf + 0.95), IstMk.MARBLE, "marble")
		var bal: Array = []
		for i in 9:
			bal.append([Vector3(wx - 2.0 + i * 0.5, yb + 0.1 + 0.3, zf + 1.88), 0.0])
		IstMk.MMC(root, 0.07, 0.6, bal, IstMk.MARBLE, 6, "marble")
		IstMk.V(root, Vector3(4.8, 0.1, 0.3), Vector3(wx, yb + 0.95, zf + 1.8), IstMk.MARBLE, "marble")
	# --- üst köşe: kör kemer dizisi (çerçeve altında)
	var arc: Array = []
	var na := int(floor((W - 3.0) / 3.0))
	for i in na:
		var x := -W * 0.5 + 2.0 + 1.5 + i * 3.0
		IstMk.ARCH(root, Vector3(x, H - 2.5, zf + 0.03), 0.65, 0.22, 0.1, IstMk.BRICK_DK, "brick", 7)
	IstMk.V(root, Vector3(W - 3.0, 0.2, 0.08), Vector3(0, H - 2.55, zf + 0.04), IstMk.BRICK_DK, "brick")
	# --- devşirme mermer levhalar ve sütun kütükleri
	var rng := RandomNumberGenerator.new()
	rng.seed = 1204
	var sp: Array = []
	for i in 14:
		var x := rng.randf_range(-W * 0.5 + 1.5, W * 0.5 - 1.5)
		var y := rng.randf_range(1.0, 3.2)
		if absf(x - gate_x) < GW:
			continue
		sp.append([Vector3(x, y, zf + 0.035), 0.0])
	IstMk.MM(root, Vector3(0.9, 0.55, 0.08), sp, IstMk.MARBLE, "marble")
	var drm: Array = []
	for i in 6:
		var x := rng.randf_range(-W * 0.5 + 2.0, W * 0.5 - 2.0)
		if absf(x - gate_x) < GW:
			continue
		drm.append(Transform3D(Basis(Vector3.RIGHT, deg_to_rad(90.0)), Vector3(x, rng.randf_range(1.2, 3.0), zf + 0.1)))
	IstMk.MMC(root, 0.28, 0.7, drm, IstMk.MARBLE, 8, "marble")
	# --- kuzey (şehir) yüzü: sıvasız tuğla-taş, kapı, sütunlu kapı, birkaç pencere
	var zn := -D * 0.5
	var nwin: Array = []
	for i in 7:
		nwin.append([Vector3(-W * 0.5 + 3.0 + i * (W - 6.0) / 6.0, yb + 0.6, zn - 0.02), 0.0])
	IstMk.MM(root, Vector3(1.1, 1.8, 0.06), nwin, IstMk.DARK)
	IstMk.V(root, Vector3(W + 0.5, 0.45, 0.3), Vector3(0, H - 0.6, zn - 0.15), IstMk.BRICK, "brick")
	# şehir yüzündeki kapı (ahşap, tünel ağzı)
	IstMk.V(root, Vector3(GW + 0.8, 0.45, 0.2), Vector3(gate_x, GH - 0.2, zn - 0.1), IstMk.MARBLE, "marble")
	IstMk.ARCH(root, Vector3(gate_x, GH + 0.25, zn - 0.06), GW * 0.5 + 0.2, 0.4, 0.2, IstMk.BRICK, "brick", 11)
	IstMk.V(root, Vector3(GW + 0.5, GW * 0.5 + 0.2, 0.05), Vector3(gate_x, GH + 0.25, zn - 0.04), IstMk.DARK)
	# batı ve doğu yüzler: kör kemerler
	for sx: float in [-1.0, 1.0]:
		for z: float in [-D * 0.25, D * 0.25]:
			IstMk.V(root, Vector3(0.06, 3.0, 2.2), Vector3(sx * (W * 0.5 + 0.02), 0.8, z), IstMk.DARK)


static func _gate_tunnel(root: Node3D, dm: Dictionary, gx: float, GW: float, GH: float) -> void:
	var D: float = dm["D"]
	var zf := D * 0.5
	# deniz kapısı: mermer sövesi, boşaltma kemeri, açık kanatlar
	IstMk.V(root, Vector3(GW + 0.8, 0.45, 0.2), Vector3(gx, GH - 0.2, zf + 0.1), IstMk.MARBLE, "marble")
	IstMk.ARCH(root, Vector3(gx, GH + 0.25, zf + 0.06), GW * 0.5 + 0.2, 0.45, 0.22, IstMk.MARBLE, "marble", 13)
	IstMk.V(root, Vector3(GW + 0.5, GW * 0.5 + 0.2, 0.05), Vector3(gx, GH + 0.25, zf + 0.03), IstMk.DARK)
	for sx: float in [-1.0, 1.0]:
		IstMk.V(root, Vector3(0.42, GH - 0.2, 0.22), Vector3(gx + sx * (GW * 0.5 + 0.21), 0, zf + 0.11), IstMk.MARBLE, "marble")
		IstMk.V(root, Vector3(0.18, GH - 0.4, 1.3), Vector3(gx + sx * (GW * 0.5 - 0.09), 0, zf - 0.7), IstMk.WOOD, "wood")
		IstMk.V(root, Vector3(0.2, 0.12, 1.32), Vector3(gx + sx * (GW * 0.5 - 0.09), 1.0, zf - 0.7), IstMk.DARK)
		IstMk.V(root, Vector3(0.2, 0.12, 1.32), Vector3(gx + sx * (GW * 0.5 - 0.09), 2.6, zf - 0.7), IstMk.DARK)
	# tünel zemini: taş levha (zemin üstü 3 cm)
	IstMk.V(root, Vector3(GW, 0.03, D), Vector3(gx, 0.0, 0), IstMk.STONE_DK, "flagstone")
	# kapı üstü haç ve bayrak armaları
	IstMk.V(root, Vector3(0.2, 1.0, 0.08), Vector3(gx, GH + GW * 0.5 + 0.9, zf + 0.04), IstMk.MARBLE)
	IstMk.V(root, Vector3(0.7, 0.2, 0.08), Vector3(gx, GH + GW * 0.5 + 1.3, zf + 0.04), IstMk.MARBLE)
	# iki yanda meşale
	for sx: float in [-1.0, 1.0]:
		var p := Vector3(gx + sx * (GW * 0.5 + 0.9), 2.5, zf + 0.15)
		IstMk.V(root, Vector3(0.1, 0.4, 0.1), p + Vector3(0, -0.1, 0), IstMk.DARK)
		Flame.add(root, p + Vector3(0, 0.3, 0), 0.24, 0.38)


static func _quay_details(root: Node3D, dm: Dictionary, k: float) -> void:
	var W: float = dm["W"]
	var D: float = dm["D"]
	var QD: float = dm["QD"]
	var zq := D * 0.5 + QD
	# bağlama babaları (mermer/taş), halkalar
	var xs: Array = []
	var n := int(floor((W + 6.0) / 7.0))
	for i in n:
		xs.append(-W * 0.5 - 3.0 + 3.5 + i * 7.0)
	for x: float in xs:
		IstMk.CY(root, 0.17, 0.7, Vector3(x, 0.35, zq - 0.9), IstMk.STONE_DK, "marble", 8, true)
		IstMk.CY(root, 0.24, 0.16, Vector3(x, 1.05, zq - 0.9), IstMk.STONE_DK, "marble", 8)
	# deniz yüzü merdiveni (rıhtımdan suya inen mermer basamaklar, kenar duvarına gömülü): görsel şerit
	IstMk.V(root, Vector3(3.0, 0.04, 0.7), Vector3(-W * 0.12, 0.35, zq - 0.35), IstMk.MARBLE, "marble")
	# rıhtım üstü: fıçı, urgan sarmalı, sandık
	IstMk.CY(root, 0.38, 0.9, Vector3(W * 0.28, 0, D * 0.5 + 2.2), IstMk.WOOD, "wood", 10, true)
	IstMk.CY(root, 0.38, 0.9, Vector3(W * 0.28 + 0.8, 0, D * 0.5 + 2.4), IstMk.WOOD_LT, "wood", 10, true)
	IstMk.S(root, Vector3(1.0, 0.6, 0.8), Vector3(W * 0.28 - 1.2, 0.08, D * 0.5 + 2.2), IstMk.WOOD_LT, "wood")
	IstMk.S(root, Vector3(0.9, 0.5, 0.9), Vector3(W * 0.28 - 1.2, 0.68, D * 0.5 + 2.3), IstMk.WOOD, "wood", 20.0)
	# rıhtım gediği: dökük moloz
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in 5:
		IstMk.ROCKB(root, Vector3(rng.randf_range(-W * 0.5, W * 0.5), 0.08, D * 0.5 + rng.randf_range(1.0, 4.5)), Vector3(0.35, 0.22, 0.4), IstMk.ROCK, false)


static func _lions(root: Node3D, dm: Dictionary, gx: float, GW: float) -> void:
	var D: float = dm["D"]
	var zf := D * 0.5 + 2.6
	# Bukoleon'un adı: boğayı parçalayan aslan grubu (mermer). İki yanda kaideli heykel.
	for sx: float in [-1.0, 1.0]:
		var x := gx + sx * 3.4
		var base := Vector3(x, 0.08, zf)
		IstMk.S(root, Vector3(2.0, 0.9, 1.4), base, IstMk.MARBLE_GREY, "marble")
		IstMk.S(root, Vector3(2.3, 0.2, 1.7), base, IstMk.STONE_DK, "ashlar")
		var top := 1.1
		# boğa (yatan): gövde, boyun, baş, boynuz
		IstMk.S(root, Vector3(1.5, 0.55, 0.7), base + Vector3(-sx * 0.1, top, 0.0), IstMk.MARBLE, "marble")
		IstMk.V(root, Vector3(0.5, 0.4, 0.45), base + Vector3(sx * 0.9, top + 0.1, 0.0), IstMk.MARBLE, "marble")
		IstMk.V(root, Vector3(0.08, 0.3, 0.08), base + Vector3(sx * 1.1, top + 0.45, -0.2), IstMk.MARBLE, "marble", Vector3(0, 0, sx * 30))
		IstMk.V(root, Vector3(0.08, 0.3, 0.08), base + Vector3(sx * 1.1, top + 0.45, 0.2), IstMk.MARBLE, "marble", Vector3(0, 0, sx * 30))
		# aslan (üstte): gövde, yele, baş, kuyruk, ön pençeler
		IstMk.S(root, Vector3(1.2, 0.6, 0.55), base + Vector3(-sx * 0.1, top + 0.55, 0.0), IstMk.MARBLE_GREY, "marble")
		IstMk.V(root, Vector3(0.55, 0.62, 0.62), base + Vector3(sx * 0.55, top + 0.95, 0.0), IstMk.MARBLE, "marble")
		IstMk.V(root, Vector3(0.38, 0.38, 0.4), base + Vector3(sx * 0.8, top + 0.95, 0.0), IstMk.MARBLE_GREY, "marble")
		IstMk.V(root, Vector3(0.12, 0.12, 0.7), base + Vector3(-sx * 0.8, top + 1.0, 0.0), IstMk.MARBLE_GREY, "marble", Vector3(0, 0, -sx * 40))
		IstMk.V(root, Vector3(0.2, 0.5, 0.2), base + Vector3(sx * 0.6, top + 0.5, 0.2), IstMk.MARBLE, "marble")
		IstMk.V(root, Vector3(0.2, 0.5, 0.2), base + Vector3(sx * 0.6, top + 0.5, -0.2), IstMk.MARBLE, "marble")


static func _jetty(root: Node3D, dm: Dictionary, k: float) -> void:
	var D: float = dm["D"]
	var W: float = dm["W"]
	var QD: float = dm["QD"]
	var x := -W * 0.12
	var z0 := D * 0.5 + QD
	var len := 11.0
	# güverte: katı levha (0,2 kalın, zeminin 0,08 üstünde bitişik), kazıklar
	IstMk.S(root, Vector3(2.4, 0.2, len), Vector3(x, 0.0, z0 + len * 0.5), IstMk.WOOD, "wood")
	var piles: Array = []
	for i in 6:
		for sx: float in [-1.0, 1.0]:
			piles.append([Vector3(x + sx * 1.1, -1.4, z0 + 0.8 + i * 2.0), 0.0])
	IstMk.MMC(root, 0.14, 3.2, piles, IstMk.WOOD_DK, 7, "wood")
	# kazık başları güverte üstünde bağlama direkleri
	for i in 3:
		IstMk.CY(root, 0.12, 0.5, Vector3(x - 1.1, 0.2, z0 + 3.0 + i * 3.4), IstMk.WOOD_DK, "wood", 7, true)
		IstMk.CY(root, 0.12, 0.5, Vector3(x + 1.1, 0.2, z0 + 3.0 + i * 3.4), IstMk.WOOD_DK, "wood", 7, true)
	# kenar kirişleri
	IstMk.V(root, Vector3(0.18, 0.2, len), Vector3(x - 1.28, -0.1, z0 + len * 0.5), IstMk.WOOD_DK, "wood")
	IstMk.V(root, Vector3(0.18, 0.2, len), Vector3(x + 1.28, -0.1, z0 + len * 0.5), IstMk.WOOD_DK, "wood")
	# iskele ucunda fener direği (ateş)
	IstMk.CY(root, 0.07, 2.6, Vector3(x + 1.0, 0.2, z0 + len - 0.4), IstMk.WOOD_DK, "wood", 6, true)
	IstMk.V(root, Vector3(0.3, 0.3, 0.3), Vector3(x + 1.0, 2.5, z0 + len - 0.4), IstMk.DARK)
	Flame.add(root, Vector3(x + 1.0, 2.62, z0 + len - 0.4), 0.28, 0.42)
	# bağlı kayık (iskeleye yanaşmış): gövde yarı batık, direksiz
	var bz := z0 + 6.0
	var boat := IstMk.root(root, "Kayik")
	boat.position = Vector3(x + 3.0, -0.1, bz)
	IstMk.S(boat, Vector3(1.3, 0.5, 4.4), Vector3(0, -0.15, 0), IstMk.WOOD_LT, "wood")
	IstMk.V(boat, Vector3(1.1, 0.06, 0.4), Vector3(0, 0.3, 0.9), IstMk.WOOD)
	IstMk.V(boat, Vector3(1.1, 0.06, 0.4), Vector3(0, 0.3, -0.9), IstMk.WOOD)
	IstMk.V(root, Vector3(0.04, 0.04, 2.0), Vector3(x + 1.5, 0.2, bz - 1.0), IstMk.ROPE, "", Vector3(0, 70, 0))


static func _roofs(root: Node3D, dm: Dictionary, k: float, lod: int) -> void:
	var W: float = dm["W"]
	var D: float = dm["D"]
	var H: float = dm["H"]
	var zf := D * 0.5
	# teras parapeti: deniz, batı, kuzey; doğu ucunda merdiven ağzı boşluğu
	var st := stair_info(k)
	var zt: float = st["z_top"]
	IstMk.S(root, Vector3(W, 1.1, 0.5), Vector3(0, H, zf - 0.25), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(W, 1.1, 0.5), Vector3(0, H, -zf + 0.25), IstMk.STONE, "ashlar")
	IstMk.S(root, Vector3(0.5, 1.1, D), Vector3(-W * 0.5 + 0.25, H, 0), IstMk.STONE, "ashlar")
	# doğu parapet: merdiven ağzı (z_top … z_top+2.2) açık
	var ea := -zf
	var eb := zt - 0.0
	var ec := zt + 2.4
	var ed := zf
	if eb - ea > 0.3:
		IstMk.S(root, Vector3(0.5, 1.1, eb - ea), Vector3(W * 0.5 - 0.25, H, (ea + eb) * 0.5), IstMk.STONE, "ashlar")
	if ed - ec > 0.3:
		IstMk.S(root, Vector3(0.5, 1.1, ed - ec), Vector3(W * 0.5 - 0.25, H, (ec + ed) * 0.5), IstMk.STONE, "ashlar")
	# batı salonu kiremitli beşik çatı (ana eksen x), katı prizma
	var hx := W * 0.28
	var hlen := W * 0.42
	var span := D - 4.0
	var rise := span * 0.28
	var rf := IstMk.ROOF(root, Vector3(span, rise, hlen), Vector3(-W * 0.5 + 1.5 + hlen * 0.5, H, -0.0), IstMk.TILE, "tiles", 90.0)
	# kubbe: kasnak + kurşun kubbe + haç (merkezin doğusunda)
	var r := maxf(4.4 * k, 2.8)
	var dx := W * 0.13
	var dz := -0.3
	var dh := maxf(2.8 * k, 1.8)
	IstMk.CY(root, r, dh, Vector3(dx, H, dz), IstMk.STONE, "ashlar", 12, true)
	var dm_m := Props.ball(root, r * 0.98, Vector3(dx, H + dh, dz), Color("8b9298"), Vector3(1, 0.66, 1), 14)
	Props.make_solid(dm_m, 0.95)
	var domtop := H + dh + r * 0.98 * 0.66
	if lod >= 1:
		return
	IstMk.CY(root, r + 0.12, 0.3, Vector3(dx, H + dh - 0.3, dz), IstMk.BRICK, "brick", 12)
	# kasnak pencereleri (sekiz kemer)
	for i in 8:
		var a := TAU * i / 8.0
		var pos := Vector3(dx + sin(a) * (r + 0.02), H + dh * 0.15, dz + cos(a) * (r + 0.02))
		var w := IstMk.V(root, Vector3(0.9, dh * 0.62, 0.1), pos, IstMk.DARK)
		w.rotation.y = a
	# kubbe: kurşun kaplama şeritleri (üç yatay bilezik) ve tepe başlığı
	for j in 3:
		var el := deg_to_rad(16.0 + j * 24.0)
		var rr := r * 0.98
		IstMk.CY(root, rr * cos(el) + 0.05, 0.1, Vector3(dx, H + dh + sin(el) * rr * 0.66 - 0.04, dz), Color("6e757b"), "", 14)
	# tepede haç
	IstMk.V(root, Vector3(0.14, 1.3, 0.14), Vector3(dx, domtop - 0.05, dz), IstMk.GOLD)
	IstMk.V(root, Vector3(0.7, 0.14, 0.14), Vector3(dx, domtop + 0.7, dz), IstMk.GOLD)
	# kubbe çevresi: teras üstü çatı sırtında kiremit mahya
	IstMk.V(root, Vector3(hlen + 0.4, 0.2, 0.3), Vector3(-W * 0.5 + 1.5 + hlen * 0.5, H + rise - 0.05, 0), IstMk.BRICK_DK, "brick")
	# kiremit çatı saçak olukları
	IstMk.V(root, Vector3(hlen + 0.3, 0.14, 0.2), Vector3(-W * 0.5 + 1.5 + hlen * 0.5, H, span * 0.5 + 0.0), IstMk.STONE_DK)
	IstMk.V(root, Vector3(hlen + 0.3, 0.14, 0.2), Vector3(-W * 0.5 + 1.5 + hlen * 0.5, H, -span * 0.5), IstMk.STONE_DK)


static func _stair(root: Node3D, dm: Dictionary, k: float, lod: int) -> void:
	var H: float = dm["H"]
	var st := stair_info(k)
	var foot := Vector3(float(st["x"]), 0.0, float(st["z_foot"]))
	IstMk.FLIGHT(root, foot, Vector3(0, 0, -1), H, 1.7, [1.0, -1.0], IstMk.STONE, "ashlar")
	# sahanlık değil: merdivenin hemen yanında alt ağzında taş çeşmelik değil, sandık yığını yok; kapı kemeri
	if lod >= 1:
		return
	IstMk.V(root, Vector3(2.4, 0.05, 1.5), Vector3(float(st["x"]), 0.0, float(st["z_foot"]) + 0.75), IstMk.STONE_DK, "flagstone")


static func _ruin_east(root: Node3D, dm: Dictionary, k: float) -> void:
	var W: float = dm["W"]
	var D: float = dm["D"]
	var H: float = dm["H"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 453
	var r := maxf(4.4 * k, 2.8)
	# doğuda yıkık kasnak: kırık duvar parçaları (halka yayı), yüksekliği değişken
	var cx := W * 0.5 - r - 3.0
	var cz := 1.0
	var n := 9
	for i in n:
		var a := PI * 0.15 + (TAU * 0.8) * i / n
		var h := rng.randf_range(0.8, 2.3)
		if i % 3 == 1:
			h = rng.randf_range(2.2, 3.2)
		var pos := Vector3(cx + sin(a) * (r * 0.9), H, cz + cos(a) * (r * 0.9))
		IstMk.S(root, Vector3(1.4, h, 0.7), pos, IstMk.STONE_DK, "ashlar", rad_to_deg(a))
	# yıkık tonoz kaburgası: iki kırık kemer
	for i in 2:
		IstMk.ARCH(root, Vector3(cx + 0.0, H + 0.2, cz - 4.5 + i * 0.0 - i * 2.0), 1.9, 0.5, 0.6, IstMk.BRICK_DK, "brick", 11)
	# düşmüş sütunlar, moloz yığını, otlar
	IstMk.CYR(root, 0.34, 2.8, Vector3(cx - 2.5, H + 0.34, cz + 3.2), IstMk.MARBLE, Vector3(0, 0, 90), "marble", 10, true)
	IstMk.CYR(root, 0.3, 2.2, Vector3(cx + 1.4, H + 0.3, cz - 3.5), IstMk.MARBLE, Vector3(0, 30, 90), "marble", 10, true)
	for i in 8:
		IstMk.ROCKB(root, Vector3(cx + rng.randf_range(-3.5, 3.5), H, cz + rng.randf_range(-4.0, 4.0)), Vector3(rng.randf_range(0.3, 0.7), rng.randf_range(0.2, 0.4), rng.randf_range(0.3, 0.6)), IstMk.ROCK, true)
	IstMk.TUFTS(root, rng, Rect2(cx - 4.0, cz - 5.0, 8.0, 10.0), 26, H, IstMk.GRASS, 0.5)
	# duvardan biten yabani incir: gövde + taç (kırık duvarın yanında)
	IstMk.CY(root, 0.22, 1.9, Vector3(cx + 3.2, H, cz + 2.0), IstMk.WOOD_DK, "wood", 7, true, 0.12)
	var cr := Props.ball(root, 1.3, Vector3(cx + 3.2, H + 2.4, cz + 2.0), Color("5b7d36"), Vector3(1.1, 0.8, 1.1), 8)
	Props.make_solid(cr, 0.8)
	# doğu ucu yamacı: kırık duvar dibine yığılmış moloz (kuzey-doğu köşe)
	for i in 5:
		IstMk.ROCKB(root, Vector3(W * 0.5 + 1.6 + rng.randf_range(0.0, 2.0), 0.0, -D * 0.5 + rng.randf_range(-1.0, 3.0)), Vector3(0.7, 0.4, 0.6), IstMk.ROCK, true)


# ---- kayıt işlevleri --------------------------------------------------------------------------------------------
static func perches_bukoleon(k: float = 0.5) -> Array:
	var dm := dims(k)
	var W: float = dm["W"]
	var H: float = dm["H"]
	var D: float = dm["D"]
	var r := maxf(4.4 * k, 2.8)
	var dh := maxf(2.8 * k, 1.8)
	var yb := H * 0.42
	return [
		Vector3(W * 0.13, H + dh + r * 0.98 * 0.66, -0.3),
		Vector3(0, yb, D * 0.5 + 0.95),
		Vector3(-W * 0.5 + 3.0, H, D * 0.5 - 1.2),
	]


static func climbs_bukoleon(k: float = 0.5) -> Array:
	var dm := dims(k)
	var st := stair_info(k)
	var H: float = dm["H"]
	var W: float = dm["W"]
	return [[Vector3(float(st["x"]), 0.0, float(st["z_foot"]) + 0.3), Vector3(W * 0.5 - 1.5, H, float(st["z_top"]) + 1.2), "merdiven"]]
