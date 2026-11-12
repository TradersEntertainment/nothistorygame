class_name IstKemerHarabe
extends RefCounted
## Kemer parçasının harabeleri ve açık alanları: Aspar açık sarnıcı (bostan), Polyeuktos harabesi, Heroon (rotunda),
## Pantokrator avlusu ve hastane kalıntısı.

const KIT := preload("res://scripts/world/ist/kemer_kit.gd")


## Aspar açık sarnıcı: içi bostan/köy. Yerel zemin y = 0 sarnıç TABANIDIR; çukuru çevreleyen sed (duvar + toprak şev) k ile
## yükselir. Seddin üstü yürünür (4 m), dışarıdan rampa, içeriden basamak.
static func build_aspar(host: Node3D, k: float, lod: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var W := 152.0 * k
	var D := 97.0 * k
	var H := maxf(10.0 * k, 2.6)
	var T := 4.0
	var root := Node3D.new()
	root.name = "Aspar"
	host.add_child(root)
	# taban (bostan toprağı)
	var floor_b := KIT.blk(root, Vector3(W, 0.3, D), Vector3(0, -0.3, 0), KIT.SOIL, "")
	floor_b.get_child(0).material_override = Props.mat(Color("8a7552"), 0.0, false, "")
	# dört sed: üstü yürünür, iç yüz kesme taş, dış yüz toprak şev (ramplı)
	var ring := [
		[Vector3(W + 2 * T, H, T), Vector3(0, 0, -(D + T) * 0.5)],
		[Vector3(W + 2 * T, H, T), Vector3(0, 0, (D + T) * 0.5)],
		[Vector3(T, H, D), Vector3(-(W + T) * 0.5, 0, 0)],
		[Vector3(T, H, D), Vector3((W + T) * 0.5, 0, 0)],
	]
	for r: Array in ring:
		var b := KIT.blk(root, r[0], r[1], KIT.STONE, "ashlar")
		b.name = "Sed"
		# üstte alçak toprak/ot şeridi (yürünür, katı olmayan yeşil kaplama: görsel)
		KIT.vis(root, Vector3(r[0].x - 0.2, 0.06, r[0].z - 0.3), r[1] + Vector3(0, H, 0), KIT.MOSS)
	# iç yüz kemerli niş dizisi (görsel, MultiMesh): sarnıcın destek kemerleri
	if lod == 0:
		var xs: Array = []
		var nn := int(W / (5.0 * maxf(k, 0.5)))
		for i in nn:
			var x := -W * 0.5 + (i + 0.5) * W / nn
			xs.append(Transform3D(Basis.IDENTITY, Vector3(x, H * 0.5, -D * 0.5 + 0.06)))
			xs.append(Transform3D(Basis.IDENTITY, Vector3(x, H * 0.5, D * 0.5 - 0.06)))
		KIT.multi(root, KIT._box_mesh(Vector3(maxf(2.4 * k, 1.4), H * 0.7, 0.14)), Props.mat(KIT.STONE_D.darkened(0.3), 0.0, false, "", false), xs)
	# dış rampa: batı sedde (toprak şev), iç basamak: doğu sedde
	var rn := int(ceil(H / 0.28))
	KIT.stairs(root, Vector3(-(W * 0.5 + T + 0.0 + rn * 0.5), 0, 0), Vector3(1, 0, 0), rn, H / rn, 0.5, 2.6, Color("b9a47c"), "rubble")
	KIT.stairs(root, Vector3(W * 0.5 - rn * 0.5 - 0.0, 0, D * 0.25), Vector3(1, 0, 0), rn, H / rn, 0.5, 2.6, Color("cdb88e"), "ashlar")
	# bostan tarhaları, kuyu, kulübeler, ağaçlar
	if lod < 2:
		var nx := maxi(2, int(W / 24.0))
		var nz := maxi(2, int(D / 20.0))
		for i in nx:
			for j in nz:
				if rng.randf() < 0.18:
					continue
				var cx := -W * 0.5 + (i + 0.5) * W / nx
				var cz := -D * 0.5 + (j + 0.5) * D / nz
				if absf(cz) < 3.0 or absf(cx) < 3.0:
					continue
				KIT.plot(root, Vector3(cx, 0, cz), W / nx - 3.0, D / nz - 3.0)
		# kuyu ağzı
		var well := KIT.cylinder_solid(root, 1.1, 1.0, Vector3(W * 0.12, 0, -D * 0.1), KIT.STONE, "ashlar", 10)
		Props.cyl(root, 0.8, 0.05, Vector3(W * 0.12, 1.02, -D * 0.1), Color("2c4a6a"), Vector3.ZERO, 10)
		# bostancı kulübeleri
		for i in 3:
			var hx := rng.randf_range(-W * 0.3, W * 0.3)
			var hz := rng.randf_range(-D * 0.3, D * 0.3)
			KIT.blk(root, Vector3(4.0, 2.6, 3.4), Vector3(hx, 0, hz), Color("d8bd8c"), "plaster", rng.randf_range(0, 90))
			var rf := Props.prism(root, Vector3(4.6, 1.2, 4.0), Vector3(hx, 3.2, hz), KIT.TILE, Vector3(0, 0, 0))
			rf.material_override = Props.mat(KIT.TILE, 0.0, false, "tiles")
			var rfs := KIT.blk(root, Vector3(4.2, 0.2, 3.6), Vector3(hx, 2.6, hz), KIT.TILE.darkened(0.3))
			rfs.get_child(0).visible = false
		for i in 12:
			KIT.tree(root, Vector3(rng.randf_range(-W * 0.45, W * 0.45), 0, rng.randf_range(-D * 0.45, D * 0.45)), rng.randf_range(4.0, 7.0), "incir" if i % 3 else "selvi")


static func perches_aspar(k: float) -> Array:
	var H := maxf(10.0 * k, 2.6)
	return [Vector3(0, H, -(97.0 * k + 4.0) * 0.5), Vector3((152.0 * k + 4.0) * 0.5, H, 0)]


static func climbs_aspar(k: float) -> Array:
	var W := 152.0 * k
	var T := 4.0
	var H := maxf(10.0 * k, 2.6)
	var rn := int(ceil(H / 0.28))
	return [[Vector3(-(W * 0.5 + T + rn * 0.5) - 0.3, 0, 0), Vector3(-(W * 0.5 + T) + 0.3, H, 0), "basamak"]]


## Polyeuktos (Saraçhane): 1453'te içi yıkık, devasa temel; kırık pilye kemerleri, devrik sütun, mermer parçaları.
static func build_polyeuktos(host: Node3D, k: float, lod: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 527
	var S := 52.0 * k
	var root := Node3D.new()
	root.name = "Polyeuktos"
	host.add_child(root)
	# temel kaide (alçak podyum, üstü yürünür): bina izi
	KIT.blk(root, Vector3(S, 0.9, S), Vector3(0, 0, 0), KIT.STONE_D, "rubble")
	KIT.vis(root, Vector3(S + 0.6, 0.35, S + 0.6), Vector3(0, 0, 0), KIT.STONE)
	# sıra sıra kırık pilye kütükleri (dört sıra): nef ve yan nefler
	var pcount := maxi(3, int(S / 8.0))
	for row in 4:
		var z := -S * 0.5 + (row + 0.5) * S / 4.0
		for j in pcount:
			var x := -S * 0.5 + (j + 0.5) * S / pcount
			var h := rng.randf_range(0.8, 5.5 * clampf(k * 1.4, 0.5, 1.0))
			if rng.randf() < 0.3:
				h = rng.randf_range(0.8, 1.6)
			var pw := maxf(2.0 * k, 1.4)
			var pb := KIT.blk(root, Vector3(pw, h, pw), Vector3(x, 0.9, z), KIT.STONE, "marble")
			# bezeli başlık (oyma sepet başlık): ince kutu
			if h > 3.0 and lod == 0:
				KIT.vis(root, Vector3(pw + 0.3, 0.4, pw + 0.3), Vector3(x, 0.9 + h, z), Color("efe6d2"), "marble")
	# ayakta kalan iki kemer parçası (kırık, yan yana)
	if lod < 2:
		var ax := S * 0.25
		for sx in [0.0, 1.0]:
			var bx: float = ax + sx * 6.0 * maxf(k, 0.6)
			KIT.blk(root, Vector3(1.6, 5.0 * maxf(k, 0.6), 1.6), Vector3(bx, 0.9, S * 0.1), KIT.STONE, "ashlar")
		var span := 6.0 * maxf(k, 0.6)
		KIT.blk(root, Vector3(span + 1.6, 1.4, 1.5), Vector3(ax + span * 0.5, 0.9 + 5.0 * maxf(k, 0.6), S * 0.1), KIT.STONE, "ashlar")
	# devrik sütun gövdeleri, mermer levhalar, moloz
	for i in int(6 + 8 * k):
		var p := Vector3(rng.randf_range(-S * 0.45, S * 0.45), 0.9, rng.randf_range(-S * 0.45, S * 0.45))
		var kind := i % 3
		if kind == 0:
			var cy := Props.cyl(root, 0.55, rng.randf_range(2.5, 4.5), p + Vector3(0, 0.55, 0), Color("e2d8c4"), Vector3(0, rng.randf_range(0, 180), 90), 12)
			Props.make_solid(cy)
		elif kind == 1:
			KIT.blk(root, Vector3(2.2, 0.4, 1.4), p, Color("ece2cf"), "marble", rng.randf_range(0, 90))
		else:
			KIT.rubble(root, p, rng.randf_range(0.9, 1.7), rng.randf_range(0.5, 1.1), i)
	# kenarda basamaklı yıkık duvar (çıkış)
	for sgn in [-1.0, 1.0]:
		KIT.stairs(root, Vector3(S * 0.5 + 0.35 + 3.0 * 0.5 * 0, 0.0, sgn * S * 0.22), Vector3(-1, 0, 0), 0, 0.3, 0.5, 2.0, KIT.STONE)
	# ot ve dikenli çalı
	if lod == 0:
		for i in 14:
			Props.box(root, Vector3(rng.randf_range(0.8, 2.0), 0.18, rng.randf_range(0.8, 1.6)), Vector3(rng.randf_range(-S * 0.5, S * 0.5), 1.0, rng.randf_range(-S * 0.5, S * 0.5)), KIT.MOSS)
		for i in 5:
			KIT.tree(root, Vector3(rng.randf_range(-S * 0.6, S * 0.6), 0, S * 0.5 + rng.randf_range(1, 6)), rng.randf_range(4, 6), "incir")


static func perches_polyeuktos(k: float) -> Array:
	var S := 52.0 * k
	var pcount := maxi(3, int(S / 8.0))
	var x := -S * 0.5 + 0.5 * S / pcount
	return [Vector3(S * 0.25 + 3.0 * maxf(k, 0.6), 0.9 + 5.0 * maxf(k, 0.6) + 1.4, S * 0.1), Vector3(0, 0.9, 0)]


static func climbs_polyeuktos(k: float) -> Array:
	var S := 52.0 * k
	return [[Vector3(S * 0.5 + 0.6, 0, 0), Vector3(S * 0.5 - 0.6, 0.9, 0), "basamak"]]


## Heroon / Konstantin rotundası harabesi (Havariyun yanında): yarım yıkık dairesel duvar, zemin, moloz.
static func build_heroon(host: Node3D, pos: Vector3, k: float, seed_v := 3) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var root := Node3D.new()
	root.name = "Heroon"
	root.position = pos
	host.add_child(root)
	var R := maxf(11.0 * k, 5.0)
	var H := maxf(9.0 * k, 3.4)
	KIT.cylinder_solid(root, R + 0.8, 0.3, Vector3.ZERO, KIT.STONE, "flagstone", 20)
	var n := 16
	for i in n:
		var a := TAU * i / n
		var seg := TAU * R / n
		if i == 0 or i == 8:
			continue          # iki kapı boşluğu (≥ 2 m)
		var h := H * rng.randf_range(0.25, 1.0) if rng.randf() < 0.65 else H
		var p := Vector3(sin(a) * R, 0.3, cos(a) * R)
		KIT.blk(root, Vector3(seg + 0.15, h, 1.3), p, KIT.BRICK.lightened(0.1), "brick", rad_to_deg(a))
		if rng.randf() < 0.4:
			KIT.rubble(root, p * 1.18, 1.1, 0.7, i)
	# orta: kırık lahit (porfir)
	KIT.blk(root, Vector3(2.6, 1.1, 1.3), Vector3(0, 0.3, 0), Color("7a3d4e"), "marble", 20)
	KIT.blk(root, Vector3(2.8, 0.25, 1.5), Vector3(0, 1.4, 0), Color("6a3444"), "marble", 20)
	return root


# --- Pantokrator ek yapıları ----------------------------------------------------------------------------

## Batı avlusu: taş döşeme, kuyu başı (phiale), keşiş hücreleri sırası; hastane (xenon) kalıntısı kuzeyde.
static func build_pantokrator_court(host: Node3D, k: float, cx: float, lod: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1118
	var root := Node3D.new()
	root.name = "Avlu"
	host.add_child(root)
	var cw := 26.0 * k + 6.0
	var cd := 56.0 * k + 6.0
	var fl := KIT.blk(root, Vector3(cw, 0.12, cd), Vector3(cx - cw * 0.5, 0, 0), Color("cdbd9a"), "flagstone")
	# kuyu başı: sekizgen havuz, üstü küçük kubbecik (phiale)
	var px := cx - cw * 0.5
	var bowl := KIT.cylinder_solid(root, 1.8, 0.9, Vector3(px, 0.12, 0), Color("e6dcc8"), "marble", 8)
	Props.cyl(root, 1.4, 0.05, Vector3(px, 1.0, 0), Color("2c5a7a"), Vector3.ZERO, 8)
	if lod == 0:
		for i in 4:
			var a := TAU * i / 4.0 + TAU / 8.0
			KIT.cylinder_solid(root, 0.18, 2.6, Vector3(px + sin(a) * 1.5, 0.12, cos(a) * 1.5), Color("e6dcc8"), "marble", 8)
		Props.ball(root, 1.9, Vector3(px, 2.8, 0), KIT.LEAD, Vector3(1, 0.5, 1), 10)
		var dcap := Props.cyl(root, 1.7, 0.2, Vector3(px, 2.7, 0), KIT.STONE_D, Vector3.ZERO, 10)
		Props.make_solid(dcap)
	# keşiş hücreleri: avlunun güney kenarında sıra (alçak, kiremit çatılı)
	for i in 5:
		var x := cx - cw + 1.5 + i * 4.2
		var z := cd * 0.5 + 2.5
		KIT.blk(root, Vector3(3.6, 3.0, 4.0), Vector3(x, 0, z), Color("d9c6a0"), "plaster")
		var r := KIT.blk(root, Vector3(3.8, 0.2, 4.2), Vector3(x, 3.0, z), KIT.TILE.darkened(0.3))
		r.get_child(0).visible = false
		var pm := Props.prism(root, Vector3(4.0, 1.1, 4.4), Vector3(x, 3.6, z), KIT.TILE)
		pm.material_override = Props.mat(KIT.TILE, 0.0, false, "tiles")
		Props.box(root, Vector3(0.9, 2.0, 0.1), Vector3(x, 1.0, z - 2.03), Color("4a3524"))
	# hastane kalıntısı: uzun salon, kırık duvarlar, kemer sırası
	var hz := -cd * 0.5 - 6.0
	for side in [-1.0, 1.0]:
		var wlen := 20.0 * k + 8.0
		for j in 4:
			var h := rng.randf_range(1.2, 3.6)
			KIT.blk(root, Vector3(wlen * 0.25, h, 1.0), Vector3(cx - cw * 0.5 - wlen * 0.375 + j * wlen * 0.25, 0, hz + side * 4.0), KIT.BRICK.lightened(0.05), "brick")
	for j in 3:
		var ax := cx - cw * 0.5 - 4.0 + j * 5.0 * maxf(k, 0.7)
		KIT.blk(root, Vector3(1.2, 4.2, 1.2), Vector3(ax, 0, hz), KIT.STONE, "ashlar")
	KIT.blk(root, Vector3(11.0 * maxf(k, 0.7), 1.0, 1.4), Vector3(cx - cw * 0.5 - 4.0 + 5.0 * maxf(k, 0.7), 4.2, hz), KIT.STONE, "ashlar")
	for i in 4:
		KIT.rubble(root, Vector3(cx - cw * 0.5 + rng.randf_range(-8, 8), 0, hz + rng.randf_range(-6, 6)), rng.randf_range(1.0, 1.8), rng.randf_range(0.5, 1.1), i)
	if lod == 0:
		for i in 3:
			KIT.tree(root, Vector3(cx - cw - 2.0, 0, -cd * 0.35 + i * cd * 0.3), 6.0, "selvi")
