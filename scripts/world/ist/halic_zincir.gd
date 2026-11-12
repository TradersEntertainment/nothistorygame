class_name IstHalicZincir
extends RefCounted
const K = preload("res://scripts/world/ist/halic_kit.gd")
## Eugenios (Kentenarion) Kulesi ve Haliç Zinciri. Kule kıyının doğu ucunda; zincir kütükler üstünde kuzeye
## (-z), Galata kıyısına doğru uzanır. Yerel: merkez kulenin tabanı, deniz -z, zemin y=0.

const QUAY_Y := 0.4


static func dims(k: float) -> Dictionary:
	var kk := clampf(k, 0.2, 1.0)
	return {"W": maxf(7.0, 10.0 * kk), "H": maxf(9.0, 22.0 * kk), "chain": maxf(50.0, 120.0 * kk), "wall_H": maxf(5.4, 9.0 * kk)}


static func build(host: Node3D, k: float, lod: int) -> void:
	var d := dims(k)
	var W: float = d["W"]
	var H: float = d["H"]
	var root := Node3D.new()
	root.name = "HalicEugenios"
	host.add_child(root)
	var col := Color("bfae90")
	if lod >= 2:
		K.slab(root, -W * 0.5, W * 0.5, -W * 0.5, W * 0.5, 0, H, col)
		K.slab(root, -W * 0.5, W * 0.5, -d["chain"], -d["chain"] + 0.5, -0.1, 0.3, Color("4a3a2a"))
		return
	# Kule: iki kat gövde, taş + tuğla bant, üstte çıkıntılı kenar (machicolation) görseli, mazgallı tepe
	var b := K.slab(root, -W * 0.5, W * 0.5, -W * 0.5, W * 0.5, 0, H, col, "ashlar")
	b.name = "KuleGovde"
	for y in [2.0, H * 0.4, H * 0.7, H - 1.2]:
		for s in [-1.0, 1.0]:
			Props.box(root, Vector3(W + 0.06, 0.32, 0.05), Vector3(0, y, s * (W * 0.5 + 0.03)), K.BRICK)
			Props.box(root, Vector3(0.05, 0.32, W + 0.06), Vector3(s * (W * 0.5 + 0.03), y, 0), K.BRICK)
	# Tepe kenarı: 0,5 m taşan sağlam kuşak (çıkıntı, katı) + siper
	K.slab(root, -W * 0.5 - 0.5, W * 0.5 + 0.5, -W * 0.5 - 0.5, W * 0.5 + 0.5, H, H + 0.3, Color("a99a7c"), "ashlar")
	var top := H + 0.3
	var e := W * 0.5 + 0.5
	K.slab(root, -e, e, -e, -e + 0.5, top, top + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, -e, -e + 0.5, -e + 0.5, e - 0.5, top, top + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, e - 0.5, e, -e + 0.5, e - 0.5, top, top + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, -e, -1.0, e - 0.5, e, top, top + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, 1.0, e, e - 0.5, e, top, top + 1.05, Color("cdbd9f"), "ashlar")
	K.merlons(root, -e, e, -e + 0.25, top + 1.05, Color("cdbd9f"), 1.4)
	# Tepe: sancak direği ve fener ocağı
	Props.cyl(root, 0.07, 5.0, Vector3(e - 1.2, top + 2.5, -e + 1.2), Color("3a2a1a"), Vector3.ZERO, 6)
	Props.box(root, Vector3(1.8, 1.1, 0.04), Vector3(e - 0.3, top + 4.3, -e + 1.2), Color("a82a2a"))
	Props.box(root, Vector3(0.14, 0.8, 0.05), Vector3(e - 0.3, top + 4.3, -e + 1.2), Color("d9b43a"))
	Props.box(root, Vector3(0.5, 0.14, 0.05), Vector3(e - 0.3, top + 4.4, -e + 1.2), Color("d9b43a"))
	K.blk(root, Vector3(0.6, 0.5, 0.6), Vector3(-e + 1.0, top + 0.25, e - 1.6), Color("4a4a4a"))
	Flame.add(root, Vector3(-e + 1.0, top + 0.5, e - 1.6), 0.35, 0.7)
	# Zincir çıkış penceresi/kirişi: deniz yüzünde iri demir halka ve ağır kiriş
	Props.box(root, Vector3(0.5, 0.5, 0.6), Vector3(0, 1.6, -W * 0.5 - 0.3), Color("2e3034"))
	Props.ring(root, 0.2, 0.34, Vector3(0, 1.6, -W * 0.5 - 0.62), K.IRON, Vector3(90, 0, 0))
	# Konsol (corbel) sırası: üst kuşağın altında dört yüzde taş çıkma dişleri
	var cb: Array = []
	var nb := int(W / 0.9)
	for i in nb:
		var t := -W * 0.5 + 0.45 + i * (W - 0.9) / maxf(1.0, nb - 1.0)
		cb.append(Transform3D(Basis.IDENTITY, Vector3(t, H - 0.35, -W * 0.5 - 0.25)))
		cb.append(Transform3D(Basis.IDENTITY, Vector3(t, H - 0.35, W * 0.5 + 0.25)))
		cb.append(Transform3D(Basis.from_euler(Vector3(0, PI * 0.5, 0)), Vector3(-W * 0.5 - 0.25, H - 0.35, t)))
		cb.append(Transform3D(Basis.from_euler(Vector3(0, PI * 0.5, 0)), Vector3(W * 0.5 + 0.25, H - 0.35, t)))
	K.multi(root, K.box_mesh(Vector3(0.5, 0.7, 0.5)), cb, Color("a99a7c"), "ashlar")
	# Köşe kuleciklerı: kuşak üstünde dört yuvarlak ocak, konik kiremit başlık (katı)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var tx: float = sx * (e - 0.95)
			var tz: float = sz * (e - 0.95)
			var tc := Props.cyl(root, 0.7, 3.0, Vector3(tx, top + 1.5, tz), Color("c4b494"), Vector3.ZERO, 10)
			Props.make_solid(tc, 0.97)
			Props.set_pattern(tc, Color("c4b494"), "ashlar")
			var cap := Props.prism(root, Vector3(1.7, 1.3, 1.7), Vector3(tx, top + 3.0 + 0.65, tz), Color("96462f"), Vector3(0, 45, 0))
			Props.make_solid(cap, 0.9)
			Props.box(root, Vector3(0.2, 0.9, 0.06), Vector3(tx, top + 1.6, tz - 0.71 * sz), Color("17130f"))
	# Deniz yüzünde mermer haç levhası ve iki başlı kartal (Palaiologos) tabelası
	Props.box(root, Vector3(1.6, 2.2, 0.1), Vector3(0, H * 0.78, -W * 0.5 - 0.07), Color("e6dfd0"))
	Props.box(root, Vector3(0.2, 1.8, 0.12), Vector3(0, H * 0.78, -W * 0.5 - 0.12), Color("b8932f"))
	Props.box(root, Vector3(1.0, 0.2, 0.12), Vector3(0, H * 0.78 + 0.3, -W * 0.5 - 0.12), Color("b8932f"))
	# Okçu mazgalları
	for yy in [H * 0.3, H * 0.55, H * 0.8]:
		for s in [-1.0, 0.0, 1.0]:
			Props.box(root, Vector3(0.2, 1.0, 0.06), Vector3(s * W * 0.28, yy, -W * 0.5 - 0.04), Color("17130f"))
			Props.box(root, Vector3(0.06, 1.0, 0.2), Vector3(W * 0.5 + 0.04, yy, s * W * 0.28), Color("17130f"))
	# Kule merdiveni (şehir yüzü, tepeye): üst basamak tepe kuşağına biter
	var n := int(ceil(top / K.STEP_RISE))
	K.stair(root, Vector3(0, 0, e + 0.34 * n - 0.0), Vector3(0, 0, -1), top, 1.8, Color("b4a384"))
	# Kuleden iki yana sur kolları (Haliç suruna bağlanır) ve rıhtım
	var wh: float = d["wall_H"]
	for s in [-1.0, 1.0]:
		var x0: float = s * W * 0.5
		var x1: float = s * (W * 0.5 + 14.0)
		K.slab(root, minf(x0, x1), maxf(x0, x1), -1.4, 1.4, 0, wh, Color("c9b89a"), "ashlar").name = "SurKol"
		var mid: float = (x0 + x1) * 0.5
		K.slab(root, minf(x0, x1), maxf(x0, x1), -1.4, -1.0, wh, wh + 1.05, Color("cdbd9f"), "ashlar")
		K.slab(root, minf(x0, x1), maxf(x0, x1), 1.0, 1.4, wh, wh + 1.05, Color("cdbd9f"), "ashlar")
		K.merlons(root, minf(x0, x1), maxf(x0, x1), -1.2, wh + 1.05, Color("cdbd9f"))
		# kuleden sur yürüme yoluna geçit yok: sur kolu tepesine kule içinden çıkılmaz; kola merdiven
		var sn := int(ceil(wh / K.STEP_RISE))
		K.stair(root, Vector3(x1 + s * 0.0, 0, 1.4 + 0.34 * sn), Vector3(0, 0, -1), wh, 1.8, Color("b4a384"))
		Props.cyl(root, 0.06, 1.0, Vector3(mid, wh + 0.5, 0), Color("3a2a1a"), Vector3.ZERO, 6)
	# Sur kolu merdivenine bırakılan parapet boşluğu: şehir yüzü parapet kolunda merdiven başında 2 m açık kalmalı
	# (parapet yalnız kolun ucuna kadar değil, merdiven hizasına kadar kısaltılmıştır)
	# Rıhtım: kule önünde taş mol (kuleye gelen yük için) ve suya iniş basamakları
	var qz0 := -W * 0.5 - 7.0
	K.slab(root, -W * 0.5 - 14.0, W * 0.5 + 14.0, qz0, -W * 0.5, -1.6, QUAY_Y, Color("a89a80"), "flagstone").name = "Mol"
	var sn2 := int(ceil((QUAY_Y + 1.6) / K.STEP_RISE))
	K.stair(root, Vector3(-W * 0.5 - 8.0, -1.6, qz0 - 0.34 * sn2), Vector3(0, 0, 1), QUAY_Y + 1.6, 2.0, Color("958870"))
	# Deniz: tüm zincir hattı
	var cl: float = d["chain"]
	K.sea(root, -cl * 0.55, cl * 0.55, -cl - 8.0, qz0, 1.6)
	if lod >= 1:
		return
	_chain(root, d, qz0)
	_winch(root, d, qz0)


static func _chain(root: Node3D, d: Dictionary, qz0: float) -> void:
	var cl: float = d["chain"]
	var W: float = d["W"]
	# Zincir -z yönünde: kütükler 6 m arayla (uzunluk 4, çap 0,7), zincir kütükler üstünden
	var logs: Array = []
	var links: Array = []
	var z := qz0 - 6.0
	var zend := -cl
	while z > zend:
		logs.append(Transform3D(Basis.from_euler(Vector3(0, PI * 0.5 + 0.05 * sin(z), PI * 0.5)), Vector3(sin(z * 0.37) * 0.2, -0.15, z)))
		z -= 6.0
	K.multi(root, K.cyl_mesh(0.35, 4.0, 8), logs, Color("5a3d22"), "wood")
	# Kütük bağlama kayışları (demir bantlar)
	var bands: Array = []
	for t: Transform3D in logs:
		bands.append(Transform3D(Basis.IDENTITY, t.origin + Vector3(0, 0.0, 0)))
	K.multi(root, K.cyl_mesh(0.37, 0.1, 8), bands, K.IRON)
	# Zincir halkaları: kulenin halkasından başlayıp kütüklere kadar iner, sonra z boyunca 0,45 m arayla
	var y_hi := 1.6
	var zc := -W * 0.5 - 0.7
	var i := 0
	while zc > zend:
		var t2 := clampf((-W * 0.5 - 0.7 - zc) / 7.0, 0.0, 1.0)
		var y := lerpf(y_hi, 0.3, t2)
		var basis := Basis.from_euler(Vector3(0, 0, (PI * 0.5) if i % 2 == 0 else 0.0))
		links.append(Transform3D(basis, Vector3(0, y, zc)))
		zc -= 0.42
		i += 1
	K.multi(root, K.box_mesh(Vector3(0.34, 0.1, 0.4)), links, K.IRON)
	# Zincirin uzak ucu: Galata tarafı (kule modelinde bitiş babası)
	Props.cyl(root, 0.4, 1.2, Vector3(0, 0.4, zend - 1.0), K.TIMBER_D, Vector3.ZERO, 8)
	# Kütüklerin demirlendiği şamandıra kazıkları
	var piles: Array = []
	var zp := qz0 - 12.0
	while zp > zend:
		piles.append(Transform3D(Basis.IDENTITY, Vector3(2.4, 0.0, zp)))
		piles.append(Transform3D(Basis.IDENTITY, Vector3(-2.4, 0.0, zp)))
		zp -= 18.0
	K.multi(root, K.cyl_mesh(0.14, 3.2, 6), piles, K.TIMBER_D, "wood")


static func _winch(root: Node3D, d: Dictionary, qz0: float) -> void:
	# Kuleye yaslı ahşap manivela kulübesi (zincir bükme çıkrığı): iki yanda
	var W: float = d["W"]
	var bx := W * 0.5 + 5.0
	K.blk(root, Vector3(3.6, 2.6, 3.2), Vector3(bx, 1.3, -W * 0.5 - 3.0), Color("7a5a38"), "wood").name = "Kulube"
	K.gable_roof(root, bx, 2.6, -W * 0.5 - 3.0, 4.2, 3.8, 1.0, K.TILE_D, false)
	Props.cyl(root, 0.35, 2.4, Vector3(bx, 1.4, -W * 0.5 - 4.8), K.TIMBER_D, Vector3(0, 0, 90), 8)
	for a in 4:
		Props.box(root, Vector3(0.1, 0.1, 2.4), Vector3(bx, 1.4, -W * 0.5 - 4.8), K.TIMBER, Vector3(a * 45, 0, 0))
	K.door(root, Vector3(bx - 0.4, 0, -W * 0.5 - 1.38), 1.0, 1.0, 2.0)


static func perches(k: float) -> Array:
	var d := dims(k)
	return [Vector3(0, d["H"] + 1.35, 0), Vector3(d["W"] * 0.5 - 0.2, d["H"] + 1.35, -d["W"] * 0.5 + 0.2)]


static func climbs(k: float) -> Array:
	var d := dims(k)
	var W: float = d["W"]
	var top: float = d["H"] + 0.3
	var e := W * 0.5 + 0.5
	var n := int(ceil(top / K.STEP_RISE))
	return [[Vector3(0, 0, e + 0.34 * n + 0.4), Vector3(0, top, e - 0.3), "basamak"]]
