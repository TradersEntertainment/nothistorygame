class_name IstHalicMahalle
extends RefCounted
## Latin mahalleleri (şehir yüzü, sur z=0'da varsayılır; mahalle +z tarafında): Venedik, Pisa+Amalfi, Ceneviz (harap),
## Yahudi/Vigla debbağlar. Her yapı kapalı katı kütle; çatıda durulur; sokaktan çatıya merdiven/sandık yolu vardır.
## Yerel: merkez mahallenin sur önündeki ortası, zemin y=0, +z şehir içi.

const K = preload("res://scripts/world/ist/halic_kit.gd")


## Yardımcı: ev. cx,cz merkez; w (x), d (z), h toplam yükseklik; face: +1 cephe +z'ye, -1 cephe -z'ye.
static func house(p: Node3D, cx: float, cz: float, w: float, d: float, h: float, ci: int, face: float = -1.0, shop := false, stone_all := false) -> Dictionary:
	var pl: Color = K.PLASTER[ci % K.PLASTER.size()]
	var sh: Color = K.SHUTTER[(ci * 3) % K.SHUTTER.size()]
	var gf := minf(3.0, h * 0.45)
	var g := K.blk(p, Vector3(w, gf, d), Vector3(cx, gf * 0.5, cz), Color("e9dcc2"), "ashlar")
	g.name = "EvAlt"
	var up_h := h - gf
	var over := 0.0 if stone_all else 0.5
	var ud := d + over
	var uz := cz + face * over * 0.5
	var u := K.blk(p, Vector3(w, up_h, ud), Vector3(cx, gf + up_h * 0.5, uz), pl, "plaster")
	u.name = "EvUst"
	var fz := cz + face * d * 0.5                 # alt cephe
	var uz_face := uz + face * ud * 0.5           # üst cephe
	# Cumba altı payandalar ve kuşak
	if over > 0.0:
		var nb := maxi(2, int(w / 2.2))
		for i in nb:
			var x := cx - w * 0.5 + (i + 0.5) * w / nb
			Props.box(p, Vector3(0.12, 0.12, 0.8), Vector3(x, gf - 0.2, fz + face * 0.3), Color("5e4e3e"), Vector3(-face * 40, 0, 0))
		Props.box(p, Vector3(w + 0.1, 0.2, 0.18), Vector3(cx, gf + 0.05, uz_face - face * 0.03), Color("5e4e3e"))
	Props.box(p, Vector3(w + 0.1, 0.16, 0.18), Vector3(cx, h - 0.1, uz_face - face * 0.03), Color("a86a4e"))
	# Kapı ve pencereler (cephe z yönüne bakar: dir_z = face)
	var dx := cx + (w * 0.25 if ci % 2 == 0 else -w * 0.25)
	K.door(p, Vector3(dx, 0, fz), face, 1.2, 2.2)
	var cols := maxi(1, int(w / 2.6))
	for i in cols:
		var x2 := cx - w * 0.5 + (i + 0.5) * w / cols
		if absf(x2 - dx) > 1.2:
			K.window(p, Vector3(x2, 1.5, fz + face * 0.0), 0.6, 0.8, sh, face)
		K.window(p, Vector3(x2, gf + up_h * 0.5, uz_face), 0.6, 0.9, sh, face)
	# Yan duvarlarda (x yüzleri) iki kat pencere; arka yüzde kapı ve pencere
	var nz := maxi(1, int(d / 3.0))
	for sx in [-1.0, 1.0]:
		for i in nz:
			var zz := cz - d * 0.5 + (i + 0.5) * d / nz
			Props.box(p, Vector3(0.05, 0.9, 0.6), Vector3(cx + sx * (w * 0.5 + 0.02), 1.6, zz), Color("1d1a18"))
			Props.box(p, Vector3(0.05, 0.08, 0.8), Vector3(cx + sx * (w * 0.5 + 0.03), 2.1, zz), Color("5e4e3e"))
			Props.box(p, Vector3(0.05, 1.0, 0.6), Vector3(cx + sx * (w * 0.5 + 0.02 + (over * 0.0)), gf + up_h * 0.5, zz), Color("1d1a18"))
			Props.box(p, Vector3(0.06, 0.08, 0.8), Vector3(cx + sx * (w * 0.5 + 0.03), gf + up_h * 0.5 + 0.55, zz), Color("5e4e3e"))
	var bz := cz - face * d * 0.5
	K.door(p, Vector3(cx - w * 0.2, 0, bz), -face, 1.1, 2.1)
	for i in maxi(1, int(w / 3.0)):
		K.window(p, Vector3(cx - w * 0.5 + (i + 0.5) * w / maxi(1, int(w / 3.0)), gf + up_h * 0.5, bz - face * 0.25 * 0.0), 0.6, 0.9, sh, -face)
	# Köşe taşları (quoin): zemin kat köşelerinde dönüşümlü iri blok
	var qx: Array = []
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			for i in int(gf / 0.5):
				var wq := 0.5 if i % 2 == 0 else 0.34
				qx.append(Transform3D(Basis.IDENTITY, Vector3(cx + sx * (w * 0.5 - wq * 0.5 + 0.03), 0.25 + i * 0.5, cz + sz * (d * 0.5 + 0.03))))
	K.multi(p, K.box_mesh(Vector3(0.5, 0.46, 0.08)), qx, Color("d8cab0"), "ashlar")
	# Kapı üstü bez sundurma (tente) ve kapı yanında küp/saksı
	var awn_c: Color = K.SHUTTER[(ci + 1) % 4].lightened(0.3)
	Props.box(p, Vector3(1.9, 0.05, 1.0), Vector3(dx, 2.7, fz + face * 0.55), awn_c, Vector3(face * 14, 0, 0))
	for s2 in [-1.0, 1.0]:
		Props.cyl(p, 0.03, 2.7, Vector3(dx + s2 * 0.9, 1.35, fz + face * 1.0), K.TIMBER_D, Vector3.ZERO, 5)
	Props.cyl(p, 0.22, 0.4, Vector3(dx + 1.5, 0.2, fz + face * 0.4), Color("a8703a"), Vector3.ZERO, 8, 0.17)
	Props.ball(p, 0.26, Vector3(dx + 1.5, 0.52, fz + face * 0.4), Color("4f7f33"), Vector3.ONE, 6)
	# Üst katta ahşap balkon (cephede, dar; katı: yürünmez 0,35 m çıkıntı yerine çıkma kirişi)
	if ci % 2 == 1 and w > 8.0:
		Props.box(p, Vector3(w * 0.4, 0.1, 0.4), Vector3(cx, gf + 1.0, uz_face + face * 0.2), K.TIMBER)
		Props.box(p, Vector3(w * 0.4, 0.8, 0.06), Vector3(cx, gf + 1.5, uz_face + face * 0.38), K.TIMBER_D)
	# Çatı
	var rise := minf(2.2, ud * 0.22)
	K.gable_roof(p, cx, h, uz, w + 0.8, ud + 0.8, rise, K.TILE, false)
	# Baca
	Props.box(p, Vector3(0.6, 1.4, 0.6), Vector3(cx + w * 0.3, h + rise + 0.2, uz), Color("8a5a40"))
	Props.box(p, Vector3(0.75, 0.12, 0.75), Vector3(cx + w * 0.3, h + rise + 0.95, uz), Color("a98a70"))
	# Çatı merdiveni: sokak tarafında (cephenin çevresinde) cumbaya kadar çıkan dış merdiven yan duvardan yapılır
	return {"roof_y": h, "x": cx, "z_edge": uz + face * (ud * 0.5 + 0.4), "face": face, "w": w, "z": cz}


## Çatıya dış merdiven: cephenin önünden başlayıp çatı saçağına biter. Döner: climbs girdisi.
static func roof_stair(p: Node3D, info: Dictionary, xoff: float) -> Array:
	var face: float = info["face"]
	var h: float = info["roof_y"]
	var n := int(ceil(h / K.STEP_RISE))
	var x: float = info["x"] + xoff
	var ze: float = info["z_edge"] + face * 0.0
	var dir := Vector3(0, 0, -face)
	var base := Vector3(x, 0, ze + face * 0.34 * n)
	K.stair(p, base, dir, h, 1.8, Color("b8a688"))
	# merdiven yanı korkuluğu yok; tepe basamağı saçak köşesinde
	return [base + Vector3(0, 0, face * 0.4), Vector3(x, h, ze - face * 0.3), "merdiven"]


static func _banner(p: Node3D, pos: Vector3, red := true) -> void:
	Props.cyl(p, 0.07, 5.0, pos + Vector3(0, 2.5, 0), Color("3a2a1a"), Vector3.ZERO, 6)
	Props.box(p, Vector3(1.8, 1.1, 0.04), pos + Vector3(0.95, 4.3, 0), Color("a82a2a") if red else Color("e0b84a"))
	Props.box(p, Vector3(0.7, 0.6, 0.06), pos + Vector3(0.95, 4.3, 0), Color("d9b43a") if red else Color("2a2a2a"))


static func _well(p: Node3D, pos: Vector3) -> void:
	var w := Props.cyl(p, 0.8, 0.9, pos + Vector3(0, 0.45, 0), Color("b4a384"), Vector3.ZERO, 10)
	Props.make_solid(w)
	for s in [-1.0, 1.0]:
		Props.box(p, Vector3(0.12, 1.8, 0.12), pos + Vector3(s * 0.7, 1.8, 0), K.TIMBER_D)
	Props.box(p, Vector3(1.6, 0.12, 0.12), pos + Vector3(0, 2.7, 0), K.TIMBER_D)
	Props.cyl(p, 0.08, 1.5, pos + Vector3(0, 2.5, 0), K.TIMBER, Vector3(0, 0, 90), 6)


## Ambar: taş tabanlı, geniş yük kapılı, çatı kirişli vinç. info döner.
static func warehouse(p: Node3D, cx: float, cz: float, w: float, d: float, h: float, face: float) -> Dictionary:
	var g := K.blk(p, Vector3(w, h, d), Vector3(cx, h * 0.5, cz), Color("c9b89a"), "ashlar")
	g.name = "Ambar"
	var fz := cz + face * d * 0.5
	for i in 2:
		var dx := cx + (-0.25 + 0.5 * i) * w
		Props.box(p, Vector3(3.0, 3.4, 0.08), Vector3(dx, 1.7, fz + face * 0.03), Color("5a3a22"))
		for j in 5:
			Props.box(p, Vector3(3.0, 0.07, 0.1), Vector3(dx, 0.5 + j * 0.65, fz + face * 0.05), K.IRON)
		K.arch_front(p, dx, 0.0, fz + face * 0.02, 3.0, 3.4, Color("b6a583"))
	for yy in [h * 0.62]:
		for i in 4:
			K.window(p, Vector3(cx - w * 0.375 + i * w * 0.25, yy, fz), 0.5, 0.7, K.SHUTTER[i % 4], face)
	K.band(p, cx - w * 0.5, cx + w * 0.5, 2.4, fz + face * 0.02, 0.3)
	var rise := minf(2.4, d * 0.24)
	K.gable_roof(p, cx, h, cz, w + 0.6, d + 0.8, rise, K.TILE, false)
	# Kiriş + makara (yük çekme): çatıdan taşan ahşap kol, katı değil
	var arm_z := fz + face * 1.4
	Props.box(p, Vector3(0.18, 0.18, 2.4), Vector3(cx, h + 0.25, fz + face * 0.7), K.TIMBER_D)
	Props.cyl(p, 0.16, 0.12, Vector3(cx, h + 0.0, arm_z), K.IRON, Vector3(0, 0, 90), 8)
	Props.box(p, Vector3(0.03, 3.0, 0.03), Vector3(cx, h - 1.5, arm_z), Color("c9b68a"))
	return {"roof_y": h, "x": cx, "z_edge": cz + face * (d * 0.5 + 0.4), "face": face, "w": w, "z": cz}


# =========================== VENEDİK ===========================
static func build_venedik(host: Node3D, k: float, lod: int) -> void:
	var root := Node3D.new()
	root.name = "HalicVenedik"
	host.add_child(root)
	var ks := clampf(k, 0.3, 1.0)
	var span := 44.0 + 36.0 * ks            # yarım genişlik
	if lod >= 2:
		K.slab(root, -span, span, 6.0, 32.0, 0, 8.0, Color("d8c8a8"))
		return
	var zrow := 30.0
	# Bailo evi: 3 kat, çıkmalı, pazar meydanına bakar (cephe -z)
	var bailo := house(root, -span * 0.55, zrow, 14.0, 12.0, 11.0, 0, -1.0, false, false)
	# bailo balkonu (taş korkuluklu), sancak ve aslan levhası
	var bx: float = -span * 0.55
	K.blk(root, Vector3(6.0, 0.3, 1.4), Vector3(bx, 5.6, zrow - 6.0 - 1.1), Color("d8c8a8"), "ashlar")
	Props.box(root, Vector3(6.0, 1.05, 0.15), Vector3(bx, 6.4, zrow - 6.0 - 1.7), Color("d8c8a8"))
	for s in [-1.0, 1.0]:
		Props.cyl(root, 0.15, 1.0, Vector3(bx + s * 2.6, 5.2, zrow - 6.0 - 1.2), Color("b6a583"), Vector3.ZERO, 8)
	Props.box(root, Vector3(1.2, 1.2, 0.1), Vector3(bx, 8.4, zrow - 6.0 - 0.55), Color("a82a2a"))
	Props.box(root, Vector3(0.8, 0.7, 0.12), Vector3(bx, 8.4, zrow - 6.0 - 0.6), Color("d9b43a"))
	_banner(root, Vector3(bx + 5.0, 11.0, zrow), true)
	# Bailo avlusu: bahçe duvarı yok (açık); meydan: kuyu + taş döşeme
	var plaza := K.slab(root, -span * 0.3, span * 0.15, 6.0, 24.0, -0.02, 0.06, Color("a89878"), "flagstone")
	plaza.name = "Meydan"
	_well(root, Vector3(-span * 0.07, 0.06, 15.0))
	# San Marco kilisesi: haç planlı, kubbe + çan kulesi
	_san_marco(root, span * 0.5, zrow - 3.0)
	# Loca: sütunlu açık sundurma, bailo evinin yanında
	var loc := _loca(root, -span * 0.2, 11.0)
	# Ambarlar (surun arkası, iki sıra)
	var wh1 := warehouse(root, -span * 0.85, 12.0, 22.0, 9.0, 6.4, -1.0)
	var wh2 := warehouse(root, span * 0.1, zrow + 14.0, 24.0, 9.0, 6.4, -1.0)
	# Sandık-fıçı yığınları meydanda, balya
	K.barrel_stack(root, Vector3(-span * 0.35, 0.06, 8.0), 2, 2, 2)
	K.bale_stack(root, Vector3(span * 0.05, 0.06, 8.0), 2, 2, 2)
	K.crate_steps(root, Vector3(-span * 0.62, 0.0, 6.5), Vector3(0, 0, 1), 3)
	# Sıra evler (iki yan sokak): Venedikli tüccar evleri
	var cx2 := -span * 0.85
	for i in 3:
		house(root, span * 0.7 + i * 0.0, 14.0 + i * 0.0, 12.0, 8.0, 7.5 + i, i + 1, -1.0)
		break
	house(root, span * 0.85, 22.0, 9.0, 8.0, 8.0, 3, -1.0)
	# Sokak lambaları
	for lx in [-span * 0.3, span * 0.15]:
		Props.cyl(root, 0.06, 2.8, Vector3(lx, 1.4, 6.5), K.TIMBER_D, Vector3.ZERO, 6)
		Flame.add(root, Vector3(lx, 2.8, 6.5), 0.18, 0.3)


static func _san_marco(root: Node3D, cx: float, cz: float) -> void:
	var col := Color("dccfb0")
	var W := 11.0
	var D := 20.0
	var H := 9.0
	# Nef (z yönünde uzun), apsis doğu ucunda; haç kolları
	var nave := K.blk(root, Vector3(W, H, D), Vector3(cx, H * 0.5, cz), col, "ashlar")
	nave.name = "Nef"
	K.blk(root, Vector3(D - 2.0, H - 1.0, 6.0), Vector3(cx, (H - 1.0) * 0.5, cz), Color("d3c4a2"), "ashlar")   # transept
	for s in [-1.0, 1.0]:
		K.band(root, cx - W * 0.5, cx + W * 0.5, 2.2, cz + s * D * 0.5 - s * 0.0 + s * 0.03, 0.3)
	K.band(root, cx - W * 0.5, cx + W * 0.5, 2.2, cz - D * 0.5 - 0.03, 0.3)
	K.band(root, cx - W * 0.5, cx + W * 0.5, 5.4, cz - D * 0.5 - 0.03, 0.3)
	# Ön cephe (-z): kemerli portal, gül pencere, alınlık
	K.arch_front(root, cx, 0.0, cz - D * 0.5 - 0.04, 2.4, 3.2, Color("b6a583"))
	Props.box(root, Vector3(2.0, 3.0, 0.08), Vector3(cx, 1.5, cz - D * 0.5 - 0.04), Color("5a3a22"))
	Props.cyl(root, 1.0, 0.1, Vector3(cx, 6.2, cz - D * 0.5 - 0.06), Color("b6a583"), Vector3(90, 0, 0), 12)
	Props.cyl(root, 0.7, 0.12, Vector3(cx, 6.2, cz - D * 0.5 - 0.1), Color("5a7aa0"), Vector3(90, 0, 0), 12)
	for s in [-1.0, 1.0]:
		K.window(root, Vector3(cx + s * 3.4, 3.8, cz - D * 0.5 - 0.02), 0.6, 1.4, K.SHUTTER[1], -1.0)
	# Yan cepheler: pencere sıraları
	for s in [-1.0, 1.0]:
		for i in 5:
			Props.box(root, Vector3(0.06, 1.6, 0.6), Vector3(cx + s * (W * 0.5 + 0.03), 4.8, cz - D * 0.5 + 2.5 + i * 3.8), Color("2a3a5a"))
	# Çatı: beşik (nef) + haç kolu
	K.gable_roof(root, cx, H, cz, W + 0.7, D + 0.8, 2.4, Color("a8503a"), true)
	# Kubbe: kasnak (sekizgen) + kurşun kaplama kubbe + haç. Kasnak çatı sırtının üstünde değil, haç kesişiminde: nef çatısının
	# üstüne oturan tabla (düz katı) taşır.
	var drum_y := H + 2.4 * 0.5
	K.blk(root, Vector3(5.2, 2.4, 5.2), Vector3(cx, H + 2.4 + 0.0, cz), Color("d3c4a2"), "ashlar")  # kasnak taşıyıcı kütle (çatı sırtı üstünde)
	var drum := Props.cyl(root, 2.5, 2.6, Vector3(cx, H + 3.7 + 1.3, cz), Color("d8c8a8"), Vector3.ZERO, 12)
	Props.make_solid(drum, 0.97)
	for a in 8:
		var ang := a * TAU / 8.0
		Props.box(root, Vector3(0.5, 1.2, 0.08), Vector3(cx + sin(ang) * 2.52, H + 5.0, cz + cos(ang) * 2.52), Color("20283a"), Vector3(0, rad_to_deg(ang), 0))
	var dome := Props.ball(root, 2.6, Vector3(cx, H + 7.0, cz), Color("8a919a"), Vector3(1, 0.85, 1), 16)
	Props.make_solid(dome, 0.97)
	for a in 8:
		var ang2 := a * TAU / 8.0
		Props.box(root, Vector3(0.1, 0.06, 2.6), Vector3(cx + sin(ang2) * 1.1, H + 8.4, cz + cos(ang2) * 1.1), Color("6f767e"), Vector3(-25, rad_to_deg(ang2) + 90, 0))
	Props.cyl(root, 0.35, 0.4, Vector3(cx, H + 9.3, cz), Color("b8932f"), Vector3.ZERO, 8)
	Props.box(root, Vector3(0.12, 1.2, 0.12), Vector3(cx, H + 10.1, cz), Color("b8932f"))
	Props.box(root, Vector3(0.7, 0.12, 0.12), Vector3(cx, H + 10.3, cz), Color("b8932f"))
	# Çan kulesi: kilisenin ön solunda (kule tabanı dolu; tepe odası dolu çan taşıyıcı)
	var tx := cx - W * 0.5 - 2.0
	var tz := cz - D * 0.5 + 2.5
	var th := 19.0
	K.blk(root, Vector3(4.0, th, 4.0), Vector3(tx, th * 0.5, tz), Color("d3c4a2"), "ashlar").name = "CanKulesi"
	K.band(root, tx - 2.0, tx + 2.0, 4.0, tz - 2.04, 0.3)
	K.band(root, tx - 2.0, tx + 2.0, 9.0, tz - 2.04, 0.3)
	for s in [-1.0, 1.0]:
		for yy in [6.5, 12.5]:
			Props.box(root, Vector3(0.4, 1.2, 0.06), Vector3(tx + s * 0.8, yy, tz - 2.04), Color("1c1814"))
	# çan odası (açık kemerler görsel) + piramit çatı
	for s in [-1.0, 1.0]:
		Props.box(root, Vector3(0.9, 2.2, 0.08), Vector3(tx + s * 1.0, th + 1.2, tz - 2.04), Color("1c1814"))
		Props.box(root, Vector3(0.08, 2.2, 0.9), Vector3(tx + s * 2.04, th + 1.2, tz + s * 1.0), Color("1c1814"))
	K.blk(root, Vector3(4.0, 2.4, 4.0), Vector3(tx, th + 1.2, tz), Color("d3c4a2"), "ashlar")
	var pyr := Props.prism(root, Vector3(4.6, 3.6, 4.6), Vector3(tx, th + 2.4 + 1.8, tz), Color("a8503a"), Vector3(0, 45, 0))
	Props.make_solid(pyr, 0.9)
	Props.cyl(root, 0.06, 1.4, Vector3(tx, th + 5.8, tz), Color("b8932f"), Vector3.ZERO, 6)
	# Kule merdiveni (dış, kilise duvarına yaslı, kule tabanından kilise çatısına) -> climbs
	# Ön avlu: sütun + aslan sütunu (San Marco simgesi)
	var col_p := Props.cyl(root, 0.4, 5.5, Vector3(cx + 6.5, 2.75, cz - D * 0.5 - 4.0), Color("e6dfd0"), Vector3.ZERO, 10)
	Props.make_solid(col_p)
	Props.box(root, Vector3(1.0, 0.8, 1.6), Vector3(cx + 6.5, 5.9, cz - D * 0.5 - 4.0), Color("b8932f"))
	Props.ball(root, 0.45, Vector3(cx + 6.5, 6.5, cz - D * 0.5 - 4.2), Color("b8932f"), Vector3(1, 1, 1.4), 8)
	# Kilise çatısına: dış merdiven (cephe önünden, yan duvar)
	var n := int(ceil(H / K.STEP_RISE))
	K.stair(root, Vector3(cx + W * 0.5 + 0.34 * n, 0, cz + D * 0.25), Vector3(-1, 0, 0), H, 1.8, Color("b8a688"))


static func _loca(root: Node3D, cx: float, cz: float) -> Dictionary:
	# Loca (tüccar sundurması): sütunlu açık zemin kat, arkada duvar, üstte teras (parapetli, düz katı)
	var w := 18.0
	var d := 6.0
	var h := 4.2
	K.blk(root, Vector3(w, h, 1.0), Vector3(cx, h * 0.5, cz + d * 0.5 - 0.5), Color("d8c8a8"), "ashlar").name = "LocaArka"
	var n := 7
	for i in n:
		var x := cx - w * 0.5 + 0.5 + i * (w - 1.0) / (n - 1)
		var c := Props.cyl(root, 0.3, h - 0.3, Vector3(x, (h - 0.3) * 0.5, cz - d * 0.5 + 0.5), Color("e6dfd0"), Vector3.ZERO, 10)
		Props.make_solid(c)
		Props.cyl(root, 0.4, 0.3, Vector3(x, h - 0.15, cz - d * 0.5 + 0.5), Color("d0c4a8"), Vector3.ZERO, 10)
	K.blk(root, Vector3(w, 0.6, d), Vector3(cx, h + 0.3, cz), Color("d8c8a8"), "ashlar").name = "LocaTeras"
	K.blk(root, Vector3(w, 1.05, 0.3), Vector3(cx, h + 0.6 + 0.52, cz - d * 0.5 + 0.15), Color("cdbd9f"), "ashlar")
	K.blk(root, Vector3(0.3, 1.05, d - 0.3), Vector3(cx - w * 0.5 + 0.15, h + 0.6 + 0.52, cz + 0.15), Color("cdbd9f"), "ashlar")
	K.blk(root, Vector3(0.3, 1.05, d - 0.3), Vector3(cx + w * 0.5 - 0.15, h + 0.6 + 0.52, cz + 0.15), Color("cdbd9f"), "ashlar")
	K.blk(root, Vector3(w, 1.05, 0.3), Vector3(cx, h + 0.6 + 0.52, cz + d * 0.5 - 0.15), Color("cdbd9f"), "ashlar")
	# Taban zemini içinde yürünür (sütunlar arası 2,6 m); içte bank
	K.blk(root, Vector3(w - 2.0, 0.5, 0.7), Vector3(cx, 0.25, cz + 0.6), Color("8a6a40"), "wood")
	var n2 := int(ceil((h + 0.6) / K.STEP_RISE))
	K.stair(root, Vector3(cx + w * 0.5 + 0.34 * n2, 0, cz), Vector3(-1, 0, 0), h + 0.6, 1.8, Color("b8a688"))
	return {"cx": cx, "cz": cz, "w": w, "top": h + 0.6, "stair_x": cx + w * 0.5 + 0.34 * n2}


static func perches_venedik(k: float) -> Array:
	var span := 44.0 + 36.0 * clampf(k, 0.3, 1.0)
	return [Vector3(span * 0.5, 9.0 + 7.0 + 3.6, 27.0), Vector3(span * 0.5 - 14.0, 9.0 + 19.0 + 2.4, 27.0 - 10.0 + 2.5)]


static func climbs_venedik(k: float) -> Array:
	var span := 44.0 + 36.0 * clampf(k, 0.3, 1.0)
	var cx := span * 0.5
	var n := int(ceil(9.0 / K.STEP_RISE))
	var out: Array = []
	out.append([Vector3(cx + 5.5 + 0.34 * n + 0.4, 0, 30.0 - 3.0 + 20.0 * 0.25), Vector3(cx + 5.5, 9.0, 27.0 + 5.0 - 0.5), "merdiven"])
	var n2 := int(ceil(4.8 / K.STEP_RISE))
	out.append([Vector3(-span * 0.2 + 9.0 + 0.34 * n2 + 0.4, 0, 11.0), Vector3(-span * 0.2 + 9.0, 4.8, 11.0), "merdiven"])
	return out


# =========================== PİSA + AMALFİ ===========================
static func build_pisa_amalfi(host: Node3D, k: float, lod: int) -> void:
	var root := Node3D.new()
	root.name = "HalicPisaAmalfi"
	host.add_child(root)
	var ks := clampf(k, 0.3, 1.0)
	var span := 38.0 + 30.0 * ks
	if lod >= 2:
		K.slab(root, -span, span, 6.0, 30.0, 0, 8.0, Color("d8c8a8"))
		return
	# Pisa tarafı (batı): siyah-beyaz bantlı küçük San Pietro kilisesi + kule ev; Amalfi (doğu): beyaz kubbeli kapelle
	var info := _pisa_church(root, -span * 0.5, 20.0)
	_amalfi_chapel(root, span * 0.5, 20.0)
	# Sıra evler iki yanda + ortada iskeleye inen sokak (x=0, genişlik 4)
	var hs: Array = []
	var xs := [-span * 0.95, -span * 0.2, span * 0.15, span * 0.85]
	for i in xs.size():
		var hh := house(root, xs[i], 14.0 + (i % 2) * 8.0, 9.0 + (i % 3) * 1.5, 8.0, 7.0 + (i % 3), i + 2, -1.0)
		hs.append(hh)
	warehouse(root, -span * 0.2, 28.0, 18.0, 8.0, 6.0, -1.0)
	K.barrel_stack(root, Vector3(0.0, 0.0, 8.0), 2, 1, 2)
	K.bale_stack(root, Vector3(-span * 0.45, 0, 8.0), 2, 1, 2, Color("cfc09a"))
	_well(root, Vector3(span * 0.35, 0, 9.0))
	_banner(root, Vector3(-span * 0.5 + 6.0, 9.0, 20.0), false)


static func _pisa_church(root: Node3D, cx: float, cz: float) -> Dictionary:
	var W := 8.0
	var D := 14.0
	var H := 7.0
	var b := K.blk(root, Vector3(W, H, D), Vector3(cx, H * 0.5, cz), Color("ece6d6"), "ashlar")
	b.name = "PisaKilise"
	# Siyah-beyaz yatay bantlar (Pisa mermer işi), dört yüzde
	for i in 5:
		var y := 0.8 + i * 1.3
		for s in [-1.0, 1.0]:
			Props.box(root, Vector3(W + 0.06, 0.4, 0.05), Vector3(cx, y, cz + s * (D * 0.5 + 0.03)), Color("2a2a2e"))
			Props.box(root, Vector3(0.05, 0.4, D + 0.06), Vector3(cx + s * (W * 0.5 + 0.03), y, cz), Color("2a2a2e"))
	K.arch_front(root, cx, 0.0, cz - D * 0.5 - 0.06, 2.0, 3.0, Color("2a2a2e"))
	Props.box(root, Vector3(1.6, 2.8, 0.08), Vector3(cx, 1.4, cz - D * 0.5 - 0.06), Color("5a3a22"))
	# Cephede kör kemer galerisi
	for i in 5:
		Props.box(root, Vector3(0.5, 0.9, 0.06), Vector3(cx - 2.8 + i * 1.4, 5.4, cz - D * 0.5 - 0.05), Color("3a3a42"))
	K.gable_roof(root, cx, H, cz, W + 0.6, D + 0.8, 2.0, Color("a8503a"), true)
	# Çan kulesi (eğik değil)
	var tx := cx + W * 0.5 + 1.6
	K.blk(root, Vector3(3.2, 12.0, 3.2), Vector3(tx, 6.0, cz - D * 0.5 + 2.0), Color("e6dfd0"), "ashlar")
	for i in 5:
		Props.box(root, Vector3(3.26, 0.35, 3.26), Vector3(tx, 1.6 + i * 2.2, cz - D * 0.5 + 2.0), Color("2a2a2e"))
	var pr := Props.prism(root, Vector3(3.8, 2.6, 3.8), Vector3(tx, 13.3, cz - D * 0.5 + 2.0), Color("a8503a"), Vector3(0, 45, 0))
	Props.make_solid(pr, 0.9)
	Props.box(root, Vector3(0.1, 1.0, 0.1), Vector3(tx, 15.0, cz - D * 0.5 + 2.0), Color("b8932f"))
	var n := int(ceil(H / K.STEP_RISE))
	K.stair(root, Vector3(cx - W * 0.5 - 0.34 * n, 0, cz + 2.0), Vector3(1, 0, 0), H, 1.8, Color("b8a688"))
	return {"cx": cx}


static func _amalfi_chapel(root: Node3D, cx: float, cz: float) -> void:
	var W := 8.0
	var D := 10.0
	var H := 6.0
	var b := K.blk(root, Vector3(W, H, D), Vector3(cx, H * 0.5, cz), Color("f0e8d8"), "plaster")
	b.name = "AmalfiSapel"
	K.arch_front(root, cx, 0.0, cz - D * 0.5 - 0.04, 1.8, 2.8, Color("c4b494"))
	Props.box(root, Vector3(1.5, 2.6, 0.08), Vector3(cx, 1.3, cz - D * 0.5 - 0.04), Color("5a3a22"))
	K.window(root, Vector3(cx, 4.4, cz - D * 0.5 - 0.02), 0.6, 1.0, K.SHUTTER[2], -1.0)
	# Düz teras çatı + kasnaklı küçük çini kaplı kubbe (Amalfi'ye özgü sarı-yeşil kiremit)
	K.blk(root, Vector3(W + 0.4, 0.4, D + 0.4), Vector3(cx, H + 0.2, cz), Color("e0d8c8"), "ashlar").name = "SapelTeras"
	var drum := Props.cyl(root, 2.0, 1.8, Vector3(cx, H + 0.4 + 0.9, cz), Color("efe8d8"), Vector3.ZERO, 10)
	Props.make_solid(drum, 0.97)
	var dome := Props.ball(root, 2.1, Vector3(cx, H + 2.2, cz), Color("c8b050"), Vector3(1, 0.9, 1), 12)
	Props.make_solid(dome, 0.97)
	for a in 10:
		var ang := a * TAU / 10.0
		Props.box(root, Vector3(0.08, 0.05, 2.0), Vector3(cx + sin(ang) * 1.0, H + 3.3, cz + cos(ang) * 1.0), Color("4a8a6a"), Vector3(-30, rad_to_deg(ang) + 90, 0))
	Props.box(root, Vector3(0.1, 1.0, 0.1), Vector3(cx, H + 4.6, cz), Color("b8932f"))
	Props.box(root, Vector3(0.5, 0.1, 0.1), Vector3(cx, H + 4.8, cz), Color("b8932f"))
	# Teras parapeti (1,05) ve dış merdiven
	for s in [-1.0, 1.0]:
		K.blk(root, Vector3(W + 0.4, 1.05, 0.3), Vector3(cx, H + 0.4 + 0.52, cz + s * (D * 0.5 + 0.05)), Color("e0d8c8"), "ashlar")
		K.blk(root, Vector3(0.3, 1.05, D - 0.4), Vector3(cx + s * (W * 0.5 + 0.05), H + 0.4 + 0.52, cz), Color("e0d8c8"), "ashlar")
	var n := int(ceil((H + 0.4) / K.STEP_RISE))
	K.stair(root, Vector3(cx - W * 0.5 - 1.0 - 0.34 * n, 0, cz + 2.0), Vector3(1, 0, 0), H + 0.4, 1.8, Color("b8a688"))


static func perches_pisa_amalfi(k: float) -> Array:
	var span := 38.0 + 30.0 * clampf(k, 0.3, 1.0)
	return [Vector3(-span * 0.5 + 4.0 + 1.6, 15.2, 20.0 - 7.0 + 2.0), Vector3(span * 0.5, 6.4 + 5.0, 20.0)]


static func climbs_pisa_amalfi(k: float) -> Array:
	var span := 38.0 + 30.0 * clampf(k, 0.3, 1.0)
	var n := int(ceil(7.0 / K.STEP_RISE))
	return [[Vector3(-span * 0.5 - 4.0 - 0.34 * n - 0.4, 0, 22.0), Vector3(-span * 0.5 - 4.0, 7.0, 22.0), "merdiven"]]


# =========================== CENEVİZ (HARAP) ===========================
static func build_ceneviz(host: Node3D, k: float, lod: int) -> void:
	var root := Node3D.new()
	root.name = "HalicCeneviz"
	host.add_child(root)
	var span := 24.0 + 20.0 * clampf(k, 0.3, 1.0)
	if lod >= 2:
		K.slab(root, -span, span, 6.0, 28.0, 0, 5.0, Color("b0a080"))
		return
	# Terk edilmiş, çatısı çökmüş iki ambar; duvarlar 3-5 m'de kırık, içi moloz yığınlı (basamaklı), ot tutmuş
	var cdn := Color("b0a080")
	for i in 2:
		var cx := -span * 0.5 + i * span
		var w := 18.0
		var d := 9.0
		var cz := 16.0 + i * 3.0
		# Zemin: tabanı doldurulmuş iç döşeme + dört duvar (kapı açıklığı 3 m ön yüzde)
		K.slab(root, cx - w * 0.5, cx + w * 0.5, cz - d * 0.5, cz + d * 0.5, -0.02, 0.2, Color("8f8468"), "flagstone").name = "ZeminIc"
		var wh := [5.0, 3.6, 4.4, 2.8]
		K.slab(root, cx - w * 0.5, cx + w * 0.5, cz + d * 0.5 - 0.7, cz + d * 0.5, 0, wh[0], cdn, "ashlar").name = "DuvarArka"
		K.slab(root, cx - w * 0.5, cx - w * 0.5 + 0.7, cz - d * 0.5, cz + d * 0.5, 0, wh[1], cdn, "ashlar").name = "DuvarSol"
		K.slab(root, cx + w * 0.5 - 0.7, cx + w * 0.5, cz - d * 0.5, cz + d * 0.5, 0, wh[2], cdn, "ashlar").name = "DuvarSag"
		K.slab(root, cx - w * 0.5, cx - 2.0, cz - d * 0.5, cz - d * 0.5 + 0.7, 0, 4.6, cdn, "ashlar").name = "OnSol"
		K.slab(root, cx + 2.0, cx + w * 0.5, cz - d * 0.5, cz - d * 0.5 + 0.7, 0, wh[3], cdn, "ashlar").name = "OnSag"
		# Moloz yığını iç ortada (kademeli, basamak): 0.4 / 0.8 / 1.2
		K.blk(root, Vector3(4.0, 0.4, 3.0), Vector3(cx + 1.0, 0.4, cz), Color("9a8c70"), "rubble")
		K.blk(root, Vector3(2.8, 0.8, 2.2), Vector3(cx + 1.0, 0.6, cz), Color("8f8468"), "rubble")
		K.blk(root, Vector3(1.6, 1.2, 1.4), Vector3(cx + 1.0, 0.8, cz), Color("857a60"), "rubble")
		# Çökmüş çatı kirişleri (duvardan duvara eğik, yarı çökmüş) - görsel; kısa
		for j in 4:
			Props.box(root, Vector3(0.22, 0.22, 5.5), Vector3(cx - w * 0.5 + 1.8 + j * 3.5, 3.6 - j * 0.35, cz + d * 0.5 - 3.2), K.TIMBER_D, Vector3(32 + j * 4, 0, 0))
		# Kırık kiremit parçaları ve ot
		for j in 12:
			var rx := cx - w * 0.5 + 1.4 + fmod(j * 3.7, w - 3.0)
			var rz := cz - d * 0.5 + 1.4 + fmod(j * 2.3, d - 2.8)
			Props.box(root, Vector3(0.5, 0.12, 0.35), Vector3(rx, 0.28, rz), K.TILE, Vector3(0, j * 37, (j % 3) * 8))
		for j in 9:
			var gx := cx - w * 0.5 + 0.5 + fmod(j * 4.9, w - 1.0)
			Props.cyl(root, 0.0, 0.5, Vector3(gx, 0.5, cz - d * 0.5 + 1.0 + fmod(j * 1.9, d - 2.0)), Color("5a8a3a"), Vector3(0, j * 20, 0), 5, 0.16)
		# Dış ve iç ağaç dalları
		# Girişe taş basamak (eşik 0,2 yüksek)
		# Dış duvarın kırık üstüne tırmanış: sandık basamakları dış arka duvar yanına
		K.stair(root, Vector3(cx - w * 0.5 - 0.34 * 14, 0, cz - 1.0), Vector3(1, 0, 0), 3.4, 1.8, Color("9a8c70"), "rubble")
	# İskele ve kıyıdaki yıkık rıhtım: eski Ceneviz iskelesi kazık dizisi (ahşap kazıklar)
	# Terk edilmiş bayrak direği (bayrak yok)
	Props.cyl(root, 0.07, 6.0, Vector3(0, 3.0, 8.0), Color("3a2a1a"), Vector3(0, 0, 6), 6)
	# Sarmaşık/ot saçakları
	for j in 8:
		Props.ball(root, 0.8 + (j % 3) * 0.2, Vector3(-span + j * span * 0.28, 0.3, 7.0 + (j % 4) * 3.0), Color("4f7f33"), Vector3(1.4, 0.5, 1.2), 7)


static func perches_ceneviz(k: float) -> Array:
	return [Vector3(-(24.0 + 20.0 * clampf(k, 0.3, 1.0)) * 0.5 + 9.0 - 0.35, 5.0 + 0.4, 16.0 + 4.0)]


static func climbs_ceneviz(k: float) -> Array:
	var span := 24.0 + 20.0 * clampf(k, 0.3, 1.0)
	var n := int(ceil(3.4 / K.STEP_RISE))
	return [[Vector3(-span * 0.5 - 9.0 - 0.34 * n - 0.4, 0, 15.0), Vector3(-span * 0.5 - 9.0 + 0.3, 3.6, 15.0), "merdiven"]]


# =========================== YAHUDİ İSKELESİ / VİGLA DEBBAĞLAR ===========================
static func build_yahudi(host: Node3D, k: float, lod: int) -> void:
	var root := Node3D.new()
	root.name = "HalicYahudi"
	host.add_child(root)
	var span := 26.0 + 16.0 * clampf(k, 0.3, 1.0)
	if lod >= 2:
		K.slab(root, -span, span, 4.0, 22.0, 0, 6.0, Color("d8c8a8"))
		return
	# Debbağ avlusu: taş küvetler (yükseltilmiş, üstü renkli sıvı), kurutma çerçeveleri, kireç çukuru kenarlıkları
	var vats := [Color("8a5a2a"), Color("a8402a"), Color("d0a830"), Color("5a7a3a")]
	for i in 8:
		var vx := -span * 0.6 + (i % 4) * 4.0
		var vz := 8.0 + (i / 4) * 4.2
		var v := Props.cyl(root, 1.4, 0.9, Vector3(vx, 0.45, vz), Color("a89a80"), Vector3.ZERO, 12)
		Props.make_solid(v, 0.97)
		Props.cyl(root, 1.15, 0.04, Vector3(vx, 0.93, vz), vats[i % 4], Vector3.ZERO, 12)
	# Kurutma çerçeveleri: iki direk + üst kiriş + sarkan deri (çarpışmasız deriler; direkler katı değil ama ince)
	for i in 4:
		var fx := span * 0.15 + i * 4.5
		for s in [-1.0, 1.0]:
			Props.cyl(root, 0.1, 3.2, Vector3(fx + s * 1.8, 1.6, 16.0), K.TIMBER_D, Vector3.ZERO, 6)
		Props.box(root, Vector3(3.8, 0.12, 0.12), Vector3(fx, 3.15, 16.0), K.TIMBER_D)
		for j in 3:
			Props.box(root, Vector3(0.9, 1.6, 0.04), Vector3(fx - 1.2 + j * 1.2, 2.3, 16.0), Color("a8704a") if j % 2 == 0 else Color("8a5a38"))
	# Küçük evler (alçak, tek-iki kat) ve Yahudi iskelesine inen sokak
	house(root, -span * 0.7, 20.0, 9.0, 7.0, 6.2, 4, -1.0)
	house(root, span * 0.7, 21.0, 9.0, 7.0, 6.6, 1, -1.0)
	var hi := house(root, 0.0, 22.0, 10.0, 7.0, 6.4, 5, -1.0)
	roof_stair(root, hi, 2.0)
	# Havra (sinagog) küçük, sade, doğuya bakan
	K.blk(root, Vector3(10.0, 6.0, 8.0), Vector3(span * 0.35, 3.0, 28.0), Color("ece2c8"), "plaster").name = "Havra"
	K.gable_roof(root, span * 0.35, 6.0, 28.0, 10.8, 8.8, 1.6, K.TILE, false)
	for i in 3:
		Props.box(root, Vector3(0.6, 1.8, 0.06), Vector3(span * 0.35 - 2.4 + i * 2.4, 3.6, 28.0 - 4.04), Color("20283a"))
	K.door(root, Vector3(span * 0.35, 0, 28.0 - 4.0), -1.0, 1.4, 2.4)
	# Sandık-fıçı yığını (deri balyaları, tuz) ve çatıya çıkış
	K.bale_stack(root, Vector3(-span * 0.2, 0, 6.5), 2, 1, 2, Color("b08a5a"))
	K.crate_steps(root, Vector3(span * 0.7 - 6.0, 0, 15.0), Vector3(0, 0, 1), 3)
	var n := int(ceil(6.0 / K.STEP_RISE))
	K.stair(root, Vector3(span * 0.35 - 5.2 - 0.34 * n, 0, 29.0), Vector3(1, 0, 0), 6.0, 1.8, Color("b8a688"))
	# Kısa iskele: sur dışı (-z) için uç; kayıkla geçiş yeri
	K.jetty(root, 0.0, -9.0, -span * 0.3, 0.4, 2.2)


static func perches_yahudi(k: float) -> Array:
	return [Vector3(0, 6.4 + 1.2, 22.0)]


static func climbs_yahudi(k: float) -> Array:
	var span := 26.0 + 16.0 * clampf(k, 0.3, 1.0)
	var n := int(ceil(6.0 / K.STEP_RISE))
	return [[Vector3(span * 0.35 - 5.2 - 0.34 * n - 0.4, 0, 29.0), Vector3(span * 0.35 - 5.2, 6.0, 29.0), "merdiven"],
		[Vector3(2.0, 0, 17.6 - 0.34 * int(ceil(6.4 / K.STEP_RISE)) - 0.4), Vector3(2.0, 6.4, 17.6 + 0.3), "merdiven"]]
