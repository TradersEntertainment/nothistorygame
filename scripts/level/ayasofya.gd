class_name Ayasofya
extends RefCounted
## Ayasofya, 1453 (kilise; son ayin 28 Mayıs). İçi gezilebilir: dış kabuk 1 m kalın duvarlar, şehre bakan yüzde
## narteks ve İmparator Kapısı (kapı alınlığında VI. Leon mozaiği), ana eksende nef:
##   altın kubbe (40 pencere, dibinde ışık halkası), köşe pandantiflerde altı kanatlı serafimler, iki yarım kubbe ve
##   eksedralar, dört dev ayak, yeşil (verde antico) sütunlu kemerler ve üstte galeriler, porfir sütunlar,
##   apsis yarım kubbesinde Meryem ve Çocuk (Theotokos, 867) mozaiği, sentronon, altar ve gümüş kiborion,
##   gümüş kaplı templon (ikonlarla), ortada ambon ve solea, döşemede Omphalion (taç giyme yeri) ve
##   "cennet ırmakları" yeşil mermer şeritleri, asılı polikandela (kandil halkaları), mermer kaplamalar,
##   kuzey nefte Terleyen Sütun (Aziz Gregorios), dua edenler ve bir papaz.
## Koordinatlar Ayasofya merkezine (ByzCity.AYA) göre; +z şehre bakan yüz (narteks), -z apsis.

const GOLD := Color("d9b24a")
const GOLD_DARK := Color("a8822e")
const MARBLE := Color("e8e4da")
const VERDE := Color("3f6a4e")
const PORPHYRY := Color("6e2a3a")
const SILVER := Color("c8ccd4")

static var _gold_mat: StandardMaterial3D
static var _mosaic_mat: StandardMaterial3D


static func build(city: Node3D) -> void:
	var o: Vector3 = ByzCity.AYA
	var root := Node3D.new()
	root.name = "AyasofyaInterior"
	root.position = o
	city.add_child(root)
	_shell_walls(root)
	_narthex(root)
	_floor(root)
	_piers_and_arcades(root)
	_domes(root)
	_apse(root)
	_templon_ambo(root)
	_lamps(root)
	_people(root)
	# Uzaktan çizilmesin (içeri girince görünür): kabuk dışındaki her şey iç mekân
	for n in root.find_children("*", "GeometryInstance3D", true, false):
		var gi := n as GeometryInstance3D
		if not gi.has_meta("exterior"):
			gi.visibility_range_end = 70.0
	_dim_inside(city, root)


## İçeri girince göz alışır: ortam ışığı ve pozlama yavaşça düşer (dışarıdaki gök ışığı nefi bembeyaz yapmasın),
## çıkınca geri döner. Seslendirme de kilise yankısına geçer.
static func _dim_inside(city: Node3D, root: Node3D) -> void:
	var env = city.get("_env")
	var sun = city.get("_sun")
	if not (env is Environment):
		return
	var area := Area3D.new()
	area.collision_mask = 1
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(32.0, 14.0, 44.0)
	cs.shape = bs
	area.position = Vector3(0, 7.0, 0.0)
	area.add_child(cs)
	root.add_child(area)
	var saved := {}
	var tw_ref := [null]
	area.body_entered.connect(func(b: Node3D):
		if not (b is Player):
			return
		var e := env as Environment
		saved["amb"] = e.ambient_light_energy
		saved["exp"] = e.tonemap_exposure
		if sun is DirectionalLight3D:
			saved["sun"] = (sun as DirectionalLight3D).light_energy
		if tw_ref[0] and (tw_ref[0] as Tween).is_valid():
			(tw_ref[0] as Tween).kill()
		var tw := area.create_tween().set_parallel(true)
		tw.tween_property(e, "ambient_light_energy", 0.12, 1.2)
		tw.tween_property(e, "tonemap_exposure", 0.6, 1.2)
		if sun is DirectionalLight3D:
			tw.tween_property(sun, "light_energy", float(saved["sun"]) * 0.15, 1.2)
		tw_ref[0] = tw
		Audio.voice_space("hall"))
	area.body_exited.connect(func(b: Node3D):
		if not (b is Player) or saved.is_empty():
			return
		var e := env as Environment
		if tw_ref[0] and (tw_ref[0] as Tween).is_valid():
			(tw_ref[0] as Tween).kill()
		var tw := area.create_tween().set_parallel(true)
		tw.tween_property(e, "ambient_light_energy", float(saved["amb"]), 1.0)
		tw.tween_property(e, "tonemap_exposure", float(saved["exp"]), 1.0)
		if sun is DirectionalLight3D and saved.has("sun"):
			tw.tween_property(sun, "light_energy", float(saved["sun"]), 1.0)
		tw_ref[0] = tw
		Audio.voice_space("outdoor"))


static func _gold() -> StandardMaterial3D:
	if _gold_mat == null:
		_gold_mat = Props.mat(GOLD, 0.28, false, "", false)
		_gold_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		_gold_mat.metallic = 0.4
		_gold_mat.roughness = 0.45
	return _gold_mat


## Kubbe mozaiği: ışıktan bağımsız altın (tesseralar ışığı her açıdan yansıtır), çift yüzlü.
static func _mosaic() -> StandardMaterial3D:
	if _mosaic_mat == null:
		_mosaic_mat = StandardMaterial3D.new()
		_mosaic_mat.albedo_color = Color("e8b84a")
		_mosaic_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_mosaic_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _mosaic_mat


## Kalın duvar (çarpışmalı), dış yüzü tuğla; iç yüzüne ayrıca mermer ve altın kaplama konur.
static func _wall(root: Node3D, size: Vector3, pos: Vector3) -> void:
	var b := Props.solid(root, size, pos, Color.WHITE)
	Props.set_pattern(b, Color("fff0e6"), "brick")
	(b.get_child(0) as MeshInstance3D).set_meta("exterior", true)


## Dış kabuk (ByzCity'nin iki dolu kütlesinin yerine): kuzey (apsis) duvarında apsis açıklığı, güneyde (narteks)
## üç kapı. Güneybatıdaki rampa kulesinin kuzey ve doğu duvarları da bu kabuktur.
static func _shell_walls(root: Node3D) -> void:
	# Apsis ucu (z -17..-16): ortada 10 m genişliğinde, 15.5 m yüksekliğinde açıklık (yarım kubbe nefden görünür)
	_wall(root, Vector3(12.0, 16.0, 1.0), Vector3(-11.0, 8.0, -16.5))
	_wall(root, Vector3(12.0, 16.0, 1.0), Vector3(11.0, 8.0, -16.5))
	_wall(root, Vector3(10.0, 0.5, 1.0), Vector3(0.0, 15.75, -16.5))
	# Doğu ve batı
	_wall(root, Vector3(1.0, 16.0, 34.0), Vector3(16.5, 8.0, 0.0))
	_wall(root, Vector3(1.0, 16.0, 25.0), Vector3(-16.5, 8.0, -4.5))
	# Rampa kulesinin kuzey ve doğu duvarları
	_wall(root, Vector3(9.0, 16.0, 1.0), Vector3(-12.5, 8.0, 7.5))
	_wall(root, Vector3(1.0, 16.0, 9.0), Vector3(-7.5, 8.0, 12.5))
	# Güney (narteks tarafı): İmparator Kapısı (x 0, 3.2 x 6 m) ve iki yan kapı (x -4.5 ve 4.5, 2.4 x 4.5 m)
	var z := 16.5
	_wall(root, Vector3(1.9, 16.0, 1.0), Vector3(-6.95, 8.0, z))
	_wall(root, Vector3(2.1, 16.0, 1.0), Vector3(-2.65, 8.0, z))
	_wall(root, Vector3(2.1, 16.0, 1.0), Vector3(2.65, 8.0, z))
	_wall(root, Vector3(10.3, 16.0, 1.0), Vector3(10.85, 8.0, z))
	_wall(root, Vector3(3.2, 10.0, 1.0), Vector3(0.0, 11.0, z))
	for sx in [-4.5, 4.5]:
		_wall(root, Vector3(2.4, 11.5, 1.0), Vector3(sx, 10.25, z))
	# Çatı: yürünebilir (çarpışma yalnız; görünür çatı ByzCity'deki kurşun örtüler), kubbenin altı içeriden açık
	var roof := StaticBody3D.new()
	root.add_child(roof)
	for spec in [[Vector3(34, 0.4, 34), Vector3(0, 15.8, 0)]]:
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = spec[0]
		cs.shape = bs
		cs.position = spec[1]
		roof.add_child(cs)
	# İç yüzler: 7.5 m'ye kadar damarlı mermer kaplama, üstü altın mozaik
	for spec in [[Vector3(11.0, 7.4, 0.06), Vector3(-10.5, 3.7, -15.97), 0.0], [Vector3(11.0, 7.4, 0.06), Vector3(10.5, 3.7, -15.97), 0.0],
			[Vector3(0.06, 7.4, 32.0), Vector3(15.97, 3.7, 0), 0.0],
			[Vector3(0.06, 7.4, 23.0), Vector3(-15.97, 3.7, -4.5), 0.0]]:
		var m := Props.box(root, spec[0], spec[1], MARBLE)
		m.material_override = Props.mat(Color("d4cab8"), 0.0, false, "marble", false)
	for spec in [[Vector3(11.0, 8.4, 0.06), Vector3(-10.5, 11.9, -15.96)], [Vector3(11.0, 8.4, 0.06), Vector3(10.5, 11.9, -15.96)],
			[Vector3(10.0, 0.6, 0.06), Vector3(0, 15.8, -15.96)], [Vector3(0.06, 8.4, 32.0), Vector3(15.96, 11.9, 0)],
			[Vector3(0.06, 8.4, 23.0), Vector3(-15.96, 11.9, -4.5)], [Vector3(24.0, 8.4, 0.06), Vector3(4.0, 11.9, 15.96)]]:
		Props.box(root, spec[0], spec[1], GOLD).material_override = _gold()
	# İçeriden pencereler (dışarıdaki koyu pencerelerin hizasında): gün ışığı süzülür
	for side in [[Vector3(15.92, 0, 0), 90.0], [Vector3(-15.92, 0, 0), -90.0]]:
		for i in 7:
			var zz := -10.8 + i * 3.6
			if side[1] < 0.0 and zz > 5.0:
				continue
			for wy in [4.4, 11.8]:
				var w := Props.box(root, Vector3(0.05, 2.6 if wy > 8.0 else 3.0, 1.1), (side[0] as Vector3) + Vector3(0, wy, zz), Color("fff4d8"))
				w.material_override = Props.mat(Color("fff0c8"), 1.6, false, "", false)


## Narteks: şehre bakan uzun giriş holü; dışa beş kapı, içe (nefe) İmparator Kapısı. Kapı alınlığında
## VI. Leon'un İsa'nın önünde diz çöktüğü mozaik.
static func _narthex(root: Node3D) -> void:
	var z0 := 17.0
	var z1 := 21.4
	var x0 := -8.0
	var x1 := 16.0
	var h := 10.0
	# Dış duvar (z1) beş kapıyla: kapılar x = -5, 0, 5, 10 (2.4 m), orta 3 m
	var doors := [[-5.0, 2.4], [0.0, 3.0], [5.0, 2.4], [10.0, 2.4]]
	var x := x0
	for d in doors:
		var left: float = d[0] - d[1] / 2.0
		if left > x:
			_wall(root, Vector3(left - x, h, 0.9), Vector3((x + left) / 2.0, h / 2.0, z1 - 0.45))
		_wall(root, Vector3(d[1], h - 4.2, 0.9), Vector3(d[0], 4.2 + (h - 4.2) / 2.0, z1 - 0.45))
		x = d[0] + d[1] / 2.0
	_wall(root, Vector3(x1 - x, h, 0.9), Vector3((x + x1) / 2.0, h / 2.0, z1 - 0.45))
	# Uç duvarlar ve çatı
	_wall(root, Vector3(0.9, h, z1 - z0), Vector3(x0 + 0.45, h / 2.0, (z0 + z1) / 2.0))
	_wall(root, Vector3(0.9, h, z1 - z0), Vector3(x1 - 0.45, h / 2.0, (z0 + z1) / 2.0))
	var roof := Props.solid(root, Vector3(x1 - x0, 0.5, z1 - z0), Vector3((x0 + x1) / 2.0, h + 0.25, (z0 + z1) / 2.0), Color("8a929c"))
	(roof.get_child(0) as MeshInstance3D).set_meta("exterior", true)
	var pr := Props.prism(root, Vector3(x1 - x0 + 0.4, 1.6, z1 - z0 + 0.4), Vector3((x0 + x1) / 2.0, h + 1.3, (z0 + z1) / 2.0), Color("8a929c"))
	pr.set_meta("exterior", true)
	# Dış cephe: kapı söveleri, kemerler, tabela
	for d in doors:
		var dx: float = d[0]
		for s in [-1.0, 1.0]:
			var jamb := Props.box(root, Vector3(0.3, 4.4, 0.3), Vector3(dx + s * (d[1] / 2.0 + 0.1), 2.2, z1 + 0.05), MARBLE)
			jamb.set_meta("exterior", true)
		var arch := Props.ball(root, d[1] * 0.5 + 0.2, Vector3(dx, 4.3, z1 + 0.02), Color("3a2e34"), Vector3(1, 0.6, 0.08), 12)
		arch.set_meta("exterior", true)
	# Tunç kapı kanatları (içe açık)
	for d in doors:
		for s in [-1.0, 1.0]:
			var leaf := Props.box(root, Vector3(d[1] / 2.0, 4.0, 0.1), Vector3(d[0] + s * (d[1] / 2.0 + 0.05), 2.0, z1 - 1.2), Color("7a5a2a"), Vector3(0, s * 80.0, 0))
			leaf.material_override = Props.mat(Color("8a6a30"), 0.05, false, "", false)
	# İçeride: mermer döşeme, altın tonoz, kandiller
	Props.box(root, Vector3(x1 - x0 - 1.8, 0.04, z1 - z0 - 0.2), Vector3((x0 + x1) / 2.0, 0.02, (z0 + z1) / 2.0), MARBLE).material_override = Props.mat(Color("f0ece4"), 0.0, false, "marble", false)
	Props.box(root, Vector3(x1 - x0 - 1.8, 0.06, z1 - z0 - 0.2), Vector3((x0 + x1) / 2.0, h - 0.05, (z0 + z1) / 2.0), GOLD).material_override = _gold()
	for i in 5:
		var lx := x0 + 2.5 + i * 4.8
		Props.cyl(root, 0.01, 3.0, Vector3(lx, h - 1.5, (z0 + z1) / 2.0), Color("3a3a3a"), Vector3.ZERO, 3)
		var lamp := Props.ball(root, 0.12, Vector3(lx, h - 3.1, (z0 + z1) / 2.0), Color("ffc860"), Vector3.ONE, 6)
		lamp.material_override = Props.mat(Color("ffc860"), 3.0, false, "", false)
	var nl := OmniLight3D.new()
	nl.position = Vector3(4.0, 6.0, (z0 + z1) / 2.0)
	nl.light_color = Color("ffc890")
	nl.light_energy = 1.4
	nl.omni_range = 14.0
	root.add_child(nl)
	# İmparator Kapısı üstündeki alınlık mozaiği (narteks tarafı): tahtta İsa, önünde diz çöken imparator
	var lz := 15.94
	var lun := Props.ball(root, 2.1, Vector3(0, 6.6, z0 - 0.02 + 0.03), GOLD, Vector3(1, 1, 0.05), 16)
	lun.material_override = _gold()
	lun.position.z = z0 + 0.02
	var pan := Node3D.new()
	pan.position = Vector3(0, 6.2, z0 + 0.09)
	root.add_child(pan)
	_throne_figure(pan, Vector3(0, 0, 0), 0.8, Color("2a3a6a"), Color("e8d8b8"), true)
	# Diz çöken imparator (Leon VI): küçük, sağ altta, mor-altın
	Props.ball(pan, 0.22, Vector3(-1.1, -0.7, 0.02), Color("5a2a6a"), Vector3(1.2, 0.8, 0.2), 8)
	Props.ball(pan, 0.1, Vector3(-0.85, -0.58, 0.03), Color("e8c8a0"), Vector3(1, 1, 0.3), 8)
	Props.ball(pan, 0.1, Vector3(-0.83, -0.46, 0.03), GOLD, Vector3(1, 0.5, 0.3), 8)
	# Madalyonlarda Meryem ve Başmelek
	for s in [-1.0, 1.0]:
		Props.cyl(pan, 0.3, 0.02, Vector3(s * 1.35, 0.55, 0.02), Color("3a4a7a"), Vector3(90, 0, 0), 12)
		Props.ball(pan, 0.1, Vector3(s * 1.35, 0.57, 0.04), Color("e8c8a0"), Vector3(1, 1.2, 0.3), 8)
	var _unused := lz


## Tahtta oturan figür (mozaik): koyu cübbe, altın hale, yüz; kucakta çocuk (Meryem) ya da açık kitap (İsa).
static func _throne_figure(p: Node3D, at: Vector3, s: float, robe: Color, face: Color, book: bool) -> void:
	# Taht ve yastık
	Props.box(p, Vector3(1.3 * s, 1.5 * s, 0.03), at + Vector3(0, -0.2 * s, -0.01), Color("c8a040"))
	Props.box(p, Vector3(1.0 * s, 0.25 * s, 0.035), at + Vector3(0, -0.35 * s, 0.0), Color("8a2a2a"))
	# Hale
	Props.cyl(p, 0.36 * s, 0.02, at + Vector3(0, 0.62 * s, 0.01), Color("f4d878"), Vector3(90, 0, 0), 16)
	# Gövde (cübbe) ve baş
	Props.ball(p, 0.5 * s, at + Vector3(0, -0.1 * s, 0.03), robe, Vector3(1.0, 1.35, 0.15), 12)
	Props.ball(p, 0.19 * s, at + Vector3(0, 0.6 * s, 0.05), face, Vector3(0.9, 1.1, 0.25), 10)
	Props.ball(p, 0.2 * s, at + Vector3(0, 0.66 * s, 0.035), robe.darkened(0.2), Vector3(1.0, 1.1, 0.18), 10)
	if book:
		Props.box(p, Vector3(0.28 * s, 0.34 * s, 0.03), at + Vector3(0.15 * s, -0.05 * s, 0.08), Color("f2ead8"))
		Props.box(p, Vector3(0.02 * s, 0.34 * s, 0.035), at + Vector3(0.15 * s, -0.05 * s, 0.085), Color("8a2a2a"))
	else:
		# Kucakta Çocuk İsa: altın giysi, küçük hale
		Props.ball(p, 0.2 * s, at + Vector3(0, -0.05 * s, 0.1), GOLD.lightened(0.15), Vector3(0.9, 1.2, 0.3), 10)
		Props.ball(p, 0.1 * s, at + Vector3(0, 0.2 * s, 0.13), face, Vector3(1, 1.1, 0.4), 8)
		Props.cyl(p, 0.14 * s, 0.02, at + Vector3(0, 0.22 * s, 0.1), Color("f4d878"), Vector3(90, 0, 0), 12)
	# Çıplak ayaklar ve basamak
	Props.box(p, Vector3(0.7 * s, 0.1 * s, 0.03), at + Vector3(0, -0.95 * s, 0.02), Color("c8a040").darkened(0.2))


## Döşeme: Prokonnesos mermeri, "cennet ırmakları" (dört yeşil şerit), Omphalion (taç giyme dairesi).
static func _floor(root: Node3D) -> void:
	var f := Props.box(root, Vector3(31.8, 0.03, 31.8), Vector3(0, 0.015, 0), MARBLE)
	f.material_override = Props.mat(Color("cfc6b4"), 0.0, false, "marble", false)
	for zz in [-9.0, -3.0, 3.0, 9.0]:
		Props.box(root, Vector3(22.0, 0.035, 0.7), Vector3(0, 0.02, zz), VERDE)
	# Omphalion: kare içinde 32 küçük daire, ortada büyük granit daire
	var om := Vector3(6.0, 0.03, -6.5)
	Props.box(root, Vector3(5.2, 0.02, 5.2), om, Color("d8d0c0"))
	var cols := [PORPHYRY, VERDE, Color("5a5a62"), Color("b88a5a")]
	var k := 0
	for ix in 6:
		for iz in 6:
			if ix in [2, 3] and iz in [2, 3]:
				continue
			var cp := om + Vector3(-2.1 + ix * 0.84, 0.005, -2.1 + iz * 0.84)
			Props.cyl(root, 0.34, 0.012, cp, cols[k % cols.size()], Vector3.ZERO, 14)
			k += 1
	Props.cyl(root, 1.05, 0.015, om + Vector3(0, 0.008, 0), Color("4a4a52"), Vector3.ZERO, 24)
	Props.interactable(root, "ev:omphalion", Vector3(2.6, 1.2, 2.6), om + Vector3(0, 0.6, 0))


## Dört dev ayak, yan neflerle nef arasında yeşil sütunlu kemerler, üstte galeri korkulukları ve daha ince sütunlar,
## eksedralarda porfir sütunlar, galeri tavanları (altın). Kuzey nefte Terleyen Sütun.
static func _piers_and_arcades(root: Node3D) -> void:
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var pp := Vector3(sx * 11.5, 8.0, sz * 9.5)
			var pier := Props.solid(root, Vector3(3.0, 16.0, 3.6), pp, Color.WHITE)
			(pier.get_child(0) as MeshInstance3D).material_override = Props.mat(Color("d8cfbe"), 0.0, false, "marble", false)
			Props.box(root, Vector3(3.1, 0.3, 3.7), pp + Vector3(0, -0.5, 0), Color("d8d0c0"))
	# Yan nef kemerleri (x = ±11): zeminde dört yeşil sütun, galeride altı ince sütun
	for sx in [-1.0, 1.0]:
		var x: float = sx * 11.0
		for zz in [-4.5, -1.5, 1.5, 4.5]:
			_column(root, Vector3(x, 0, zz), 0.38, 6.2, VERDE, true)
		# Zemin kemerleri ve galeri döşemesi (yan nefin tavanı)
		for i in 5:
			var az := -6.0 + i * 3.0
			var a := Props.ball(root, 1.5, Vector3(x, 6.5, az), MARBLE, Vector3(0.12, 0.55, 1.0), 12)
			a.material_override = Props.mat(Color("d8d0c0"), 0.0, false, "marble", false)
		Props.box(root, Vector3(0.9, 1.1, 12.0), Vector3(x, 7.05, 0), MARBLE)
		var z_end := 7.0 if sx < 0.0 else 16.0
		var gl := Props.box(root, Vector3(4.6, 0.3, z_end + 16.0), Vector3(sx * 13.7, 7.5, (z_end - 16.0) / 2.0), GOLD)
		gl.material_override = _gold()
		# Galeri korkuluğu (mermer levhalar) ve ince sütunlar
		Props.box(root, Vector3(0.25, 1.0, 12.0), Vector3(x, 8.1, 0), Color("ece6da"))
		for i in 6:
			_column(root, Vector3(x, 7.6, -5.0 + i * 2.0), 0.2, 3.6, VERDE, false)
		# Galerinin üstündeki timpanon duvarı: iki sıra pencere (ışık süzülür)
		var tw := Props.box(root, Vector3(0.6, 4.4, 12.4), Vector3(x, 13.4, 0), GOLD)
		tw.material_override = _gold()
		for row in 2:
			for i in 7:
				var w := Props.box(root, Vector3(0.66, 1.0, 0.5), Vector3(x, 12.4 + row * 1.9, -4.8 + i * 1.6), Color("fff4d8"))
				w.material_override = Props.mat(Color("fff0c8"), 1.8, false, "", false)
	# Eksedralarda porfir sütunlar (köşegen uçlar)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			for k in 2:
				_column(root, Vector3(sx * (5.5 + k * 2.2), 0, sz * (13.2 - k * 0.6)), 0.34, 6.0, PORPHYRY, true)
	# Terleyen Sütun (Aziz Gregorios): bronz kaplı, ortasında başparmak deliği
	var wc := Vector3(-13.6, 0, 3.0)
	_column(root, wc, 0.42, 6.2, Color("8a8070"), true)
	for yy in [1.0, 1.6, 2.2]:
		Props.cyl(root, 0.45, 0.12, wc + Vector3(0, yy, 0), Color("a8783a"), Vector3.ZERO, 12)
	Props.cyl(root, 0.05, 0.05, wc + Vector3(0, 1.3, 0.43), Color("1a1410"), Vector3(90, 0, 0), 8)
	Props.interactable(root, "ev:weeping_column", Vector3(1.2, 2.2, 1.2), wc + Vector3(0, 1.1, 0))


static func _column(root: Node3D, at: Vector3, r: float, h: float, col: Color, solid: bool) -> void:
	var shaft := Props.cyl(root, r, h, at + Vector3(0, h / 2.0, 0), col, Vector3.ZERO, 12)
	shaft.material_override = Props.mat(col, 0.0, false, "marble", false)
	Props.cyl(root, r * 1.35, 0.35, at + Vector3(0, 0.17, 0), Color("e8e0d0"), Vector3.ZERO, 12)
	# Sepet başlık (Ayasofya'nın oyma başlıkları)
	Props.cyl(root, r * 1.5, 0.5, at + Vector3(0, h - 0.1, 0), Color("ece6d6"), Vector3.ZERO, 12, r * 1.05)
	Props.box(root, Vector3(r * 3.2, 0.18, r * 3.2), at + Vector3(0, h + 0.2, 0), Color("ece6d6"))
	if solid:
		var b := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var cy := CylinderShape3D.new()
		cy.radius = r * 1.1
		cy.height = h
		cs.shape = cy
		b.position = at + Vector3(0, h / 2.0, 0)
		b.add_child(cs)
		root.add_child(b)


## Kemer: yarım elips biçiminde pürüzsüz altın mozaik şerit (iç yüz) ve iki kenarında mermer silme.
## ctr: kemerin ortası (zeminde), span: yarı açıklık, rise: yükseklik, base: üzengi yüksekliği, yaw: düzlem yönü.
static func _arch(root: Node3D, ctr: Vector3, span: float, rise: float, base: float, yaw: float, depth: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := 32
	var basis := Basis(Vector3.UP, yaw)
	for k in n:
		var a0 := PI * k / n
		var a1 := PI * (k + 1) / n
		var p0 := Vector3(-cos(a0) * span, sin(a0) * rise + base, 0)
		var p1 := Vector3(-cos(a1) * span, sin(a1) * rise + base, 0)
		var d := Vector3(0, 0, depth / 2.0)
		var quad := [p0 - d, p1 - d, p1 + d, p0 + d]
		for idx in [0, 1, 2, 0, 2, 3]:
			st.set_normal(basis * Vector3(cos((a0 + a1) / 2.0), -sin((a0 + a1) / 2.0), 0))
			st.add_vertex(ctr + basis * (quad[idx] as Vector3))
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = _mosaic()
	root.add_child(mi)
	for sd in [-1.0, 1.0]:
		for k in 16:
			var a := PI * (k + 0.5) / 16.0
			var pos := ctr + basis * Vector3(-cos(a) * (span + 0.15), sin(a) * (rise + 0.15) + base, sd * depth / 2.0)
			var tang := Vector2(sin(a) * span, cos(a) * rise).normalized()
			Props.box(root, Vector3(span * PI / 16.0 * 1.05, 0.3, 0.12), pos, Color("ece6d6"),
				Vector3(0, rad_to_deg(yaw), rad_to_deg(atan2(tang.y, tang.x))))


## Küresel kabuk parçası (içten görünür): merkez, yarıçap, dikey ölçek, yatay açı ve yükselti aralığı.
static func shell(root: Node3D, center: Vector3, r: float, ysc: float, az0: float, az1: float, el0: float, el1: float,
		mat: Material, seg_a := 32, seg_e := 10) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = shell_mesh(r, ysc, az0, az1, el0, el1, seg_a, seg_e, false)
	mi.material_override = mat
	mi.position = center
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	root.add_child(mi)
	return mi


## Kapaksız küresel kabuk ağı. outward: dış yüz görünür (dış kubbe), değilse iç yüz (mozaik).
static func shell_mesh(r: float, ysc: float, az0: float, az1: float, el0: float, el1: float, seg_a: int, seg_e: int,
		outward: bool) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var order := [0, 2, 1, 0, 3, 2] if outward else [0, 1, 2, 0, 2, 3]
	for i in seg_a:
		for j in seg_e:
			var a0 := lerpf(az0, az1, float(i) / seg_a)
			var a1 := lerpf(az0, az1, float(i + 1) / seg_a)
			var e0 := lerpf(el0, el1, float(j) / seg_e)
			var e1 := lerpf(el0, el1, float(j + 1) / seg_e)
			var q := [[a0, e0], [a1, e0], [a1, e1], [a0, e1]]
			var pts: Array[Vector3] = []
			var nrm: Array[Vector3] = []
			for c in q:
				var d := Vector3(cos(c[1]) * sin(c[0]), sin(c[1]) * ysc, cos(c[1]) * cos(c[0]))
				pts.append(d * r)
				var nn := Vector3(cos(c[1]) * sin(c[0]), sin(c[1]) / maxf(ysc, 0.01), cos(c[1]) * cos(c[0])).normalized()
				nrm.append(nn if outward else -nn)
			for idx in order:
				st.set_normal(nrm[idx])
				st.add_vertex(pts[idx])
	return st.commit()


## Ana kubbe (altın, ortada madalyon), 40 pencereli kasnak ve dibinde ışık halkası, pandantiflerde serafimler,
## iki yarım kubbe ve dört eksedra, köşe tonozları.
static func _domes(root: Node3D) -> void:
	var g := _mosaic()
	var base_y := 16.2
	shell(root, Vector3(0, base_y, 0), 10.8, 0.55, 0.0, TAU, 0.0, PI / 2.0, g, 48, 12)
	# Kaburgalar (40): kubbenin içinde ince koyu çizgiler, dipte pencereler
	for k in 40:
		var a := TAU * k / 40.0
		var w := Props.box(root, Vector3(0.55, 1.2, 0.08), Vector3(sin(a) * 10.72, base_y + 0.75, cos(a) * 10.72), Color("fff4d8"), Vector3(0, rad_to_deg(a), 0))
		w.material_override = Props.mat(Color("fff6d8"), 2.6, false, "", false)
		for j in 3:
			var el := 0.2 + j * 0.42
			var rr := 10.7 * cos(el)
			Props.box(root, Vector3(0.1, 0.1, 2.8), Vector3(sin(a) * rr, base_y + 10.7 * 0.55 * sin(el) - 0.05, cos(a) * rr), GOLD_DARK,
				Vector3(-rad_to_deg(atan2(0.55 * cos(el), sin(el))), rad_to_deg(a), 0))
	# Tepe madalyonu: Pantokrator (yıldızlı çember içinde, IC XC)
	var top := Vector3(0, base_y + 10.8 * 0.55 - 0.45, 0)
	for spec in [[2.6, GOLD_DARK, 0.0], [2.4, Color("22305a"), -0.02], [0.9, Color("f4d878"), -0.04]]:
		var d := Props.cyl(root, spec[0], 0.02, top + Vector3(0, spec[2], 0), spec[1], Vector3.ZERO, 32)
		d.material_override = Props.mat(spec[1], 0.35, false, "", false)
	var face := Props.ball(root, 0.5, top + Vector3(0, -0.08, 0), Color("d8b894"), Vector3(1.0, 0.2, 1.25), 12)
	face.material_override = Props.mat(Color("d8b894"), 0.25, false, "", false)
	# Pantokrator'un yüzünü çevreleyen haç-hale kolları
	for k in 4:
		var hb := Props.box(root, Vector3(0.25, 0.02, 0.5), top + Vector3(sin(k * PI / 2.0) * 0.75, -0.05, cos(k * PI / 2.0) * 0.75), Color("c8323a"), Vector3(0, k * 90.0, 0))
		hb.material_override = Props.mat(Color("c8323a"), 0.3, false, "", false)
	for s in [-1.0, 1.0]:
		var l := Props.label(root, "IC" if s < 0 else "XC", top + Vector3(s * 1.6, -0.06, 0), 64, Color("f4d878"), Vector3(90, 0, 0), 1.0)
		l.pixel_size = 0.008
	# Işık halkası: kasnağın dibinden süzülen gün ışığı (saydam, parlak)
	var halo := Props.cyl(root, 10.4, 0.8, Vector3(0, base_y + 0.7, 0), Color(1.0, 0.95, 0.8, 0.12), Vector3.ZERO, 48)
	(halo.mesh as CylinderMesh).cap_top = false
	(halo.mesh as CylinderMesh).cap_bottom = false
	var hm := Props.mat(Color(1.0, 0.95, 0.78, 0.1), 1.2, true, "", false)
	hm.cull_mode = BaseMaterial3D.CULL_DISABLED
	halo.material_override = hm
	# Gün ışığı huzmeleri (pencerelerden nefe)
	for k in 6:
		var a := TAU * k / 6.0 + 0.3
		var beam := Props.box(root, Vector3(0.9, 17.0, 0.3), Vector3(sin(a) * 5.0, base_y - 7.0, cos(a) * 5.0), Color.WHITE,
			Vector3(rad_to_deg(0.34) * cos(a), 0, -rad_to_deg(0.34) * sin(a)))
		var bm := Props.mat(Color(1.0, 0.94, 0.75, 0.06), 0.8, true, "", false)
		bm.cull_mode = BaseMaterial3D.CULL_DISABLED
		bm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		beam.material_override = bm
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Kubbe kasnağının dibi: mermer silme
	Props.ring(root, 10.5, 11.1, Vector3(0, base_y - 0.1, 0), Color("ece6d6"))
	# Pandantifler: dört köşede altın üçgen yüzey ve altı kanatlı serafim
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var c := Vector3(sx * 8.4, 13.4, sz * 7.2)
			var pd := Props.prism(root, Vector3(5.0, 4.5, 0.4), c, GOLD, Vector3(0, rad_to_deg(atan2(-sx, -sz)), 180))
			pd.material_override = _gold()
			_seraph(root, c + Vector3(-sx * 0.4, -0.2, -sz * 0.4), atan2(-sx, -sz))
	# Kubbeyi taşıyan dört büyük kemer: ayaklardan (7 m) kubbe dibine (16.2 m) yükselen mermer silmeli kuşaklar
	for spec in [[Vector3(0, 0, -9.6), 0.0], [Vector3(0, 0, 9.6), 0.0], [Vector3(-11.0, 0, 0), 90.0], [Vector3(11.0, 0, 0), 90.0]]:
		var ctr: Vector3 = spec[0]
		var span := 10.0 if spec[1] == 0.0 else 9.0
		_arch(root, ctr, span, 9.2, 7.0, deg_to_rad(spec[1]), 1.4)
	# Yarım kubbeler (ana eksen) ve eksedralar
	for s in [-1.0, 1.0]:
		var hz := Vector3(0, base_y - 0.4, s * 9.4)
		shell(root, hz, 6.9, 0.7, PI / 2.0 if s < 0 else -PI / 2.0, PI * 1.5 if s < 0 else PI / 2.0, 0.0, PI / 2.0, g, 24, 8)
		for sx in [-1.0, 1.0]:
			var ez := Vector3(sx * 6.4, 9.0, s * 12.2)
			shell(root, ez, 3.6, 0.8, 0.0, TAU, 0.0, PI / 2.0, g, 16, 6)
			Props.ring(root, 3.45, 3.85, ez, Color("ece6d6"))
	# Kubbe dibindeki düz tavan: kemerlerin üstü ve pandantif köşeleri kapansın (içeriden gökyüzü görünmesin);
	# ana kubbe ve iki yarım kubbenin altı açık
	var ceil := MeshInstance3D.new()
	ceil.mesh = _roof_grid(16.3, Vector3.DOWN)
	ceil.material_override = _mosaic()
	root.add_child(ceil)
	# Dışarıdan: aynı delikli ızgara, kurşun çatı örtüsü (kubbelerin altı dış kubbelerle örtülü)
	var lead := MeshInstance3D.new()
	lead.mesh = _roof_grid(16.45, Vector3.UP)
	lead.material_override = Props.mat(Color("6c737c"), 0.0, false, "", false)
	lead.set_meta("exterior", true)
	root.add_child(lead)
	# Yan nef üst tavanları (16 m) ve köşeler: içeriden gökyüzü görünmesin
	for spec in [[Vector3(5.5, 0.1, 32.0), Vector3(13.4, 15.9, 0)], [Vector3(5.5, 0.1, 23.0), Vector3(-13.4, 15.9, -4.5)],
			[Vector3(22.0, 0.1, 1.2), Vector3(0, 15.9, -15.6)], [Vector3(22.0, 0.1, 1.2), Vector3(4.0, 15.9, 15.6)]]:
		Props.box(root, spec[0], spec[1], GOLD).material_override = _gold()


## Kubbe dibindeki düz yüzey: ana kubbe ve iki yarım kubbenin altı açık.
static func _roof_grid(y: float, n: Vector3) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cell := 0.5
	var x := -16.0
	while x < 16.0:
		var z := -17.0
		while z < 17.0:
			var c := Vector2(x + cell / 2.0, z + cell / 2.0)
			var open := c.length() < 10.6 or (absf(c.y) >= 9.4 and (c.distance_to(Vector2(0, -9.4)) < 6.8 or c.distance_to(Vector2(0, 9.4)) < 6.8))
			if not open:
				var q := [Vector3(x, y, z), Vector3(x + cell, y, z), Vector3(x + cell, y, z + cell), Vector3(x, y, z + cell)]
				for idx in ([0, 1, 2, 0, 2, 3] if n.y > 0.0 else [0, 2, 1, 0, 3, 2]):
					st.set_normal(n)
					st.add_vertex(q[idx])
			z += cell
		x += cell
	return st.commit()


## Altı kanatlı serafim (pandantif mozaiği): iki kanat yukarı, iki yana, iki aşağı; ortada yüz.
static func _seraph(root: Node3D, at: Vector3, yaw: float) -> void:
	var s := Node3D.new()
	s.position = at
	s.rotation.y = yaw
	root.add_child(s)
	var wing := [Color("5a6a9a"), Color("c8a040"), Color("8a4a3a")]
	for k in 6:
		var ang := -150.0 + k * 60.0
		var wv := Vector2(cos(deg_to_rad(ang)), sin(deg_to_rad(ang)))
		Props.box(s, Vector3(0.28, 1.6, 0.05), Vector3(wv.x * 0.8, wv.y * 0.8, 0.05), wing[k % 3], Vector3(0, 0, ang - 90.0))
	Props.ball(s, 0.3, Vector3(0, 0, 0.1), Color("e8c8a0"), Vector3(1, 1.1, 0.3), 10)
	Props.cyl(s, 0.4, 0.02, Vector3(0, 0, 0.07), Color("f4d878"), Vector3(90, 0, 0), 12)


## Apsis: nefin kuzey ucunda dışarı taşan yarım silindir, altın yarım kubbe, Meryem ve Çocuk mozaiği, üç pencere,
## sentronon (basamaklı papaz sırası), altar ve gümüş kiborion.
static func _apse(root: Node3D) -> void:
	var c := Vector3(0, 0, -17.0)
	var r := 5.0
	# Dış yarım silindir duvarı (çarpışmalı dilimler)
	for k in 9:
		var a := PI * (k + 0.5) / 9.0 - PI / 2.0
		var p := c + Vector3(sin(a) * (r + 0.5), 5.5, -cos(a) * (r + 0.5))
		var b := Props.solid(root, Vector3(1.9, 11.0, 1.0), p, Color.WHITE, Vector3(0, -rad_to_deg(a), 0))
		Props.set_pattern(b, Color("fff0e6"), "brick")
		(b.get_child(0) as MeshInstance3D).set_meta("exterior", true)
	var cap := Props.ball(root, r + 1.0, c + Vector3(0, 11.0, 0), Color("8a929c"), Vector3(1, 0.5, 1), 16)
	cap.mesh = shell_mesh(r + 1.0, 0.8, 0.0, TAU, 0.0, PI / 2.0, 16, 6, true)
	cap.scale = Vector3.ONE
	cap.material_override = Props.mat(Color("8a929c"), 0.0, false, "", false)
	cap.set_meta("exterior", true)
	# İç: mermer kaplama, altın yarım kubbe
	# Apsis duvarı: altta mermer (0-5.2 m), üstte altın (5.2-11 m); ince yükselti aralığıyla neredeyse dik silindir
	shell(root, c + Vector3(0, 0.02, 0), r - 0.05, 21.0, PI / 2.0, PI * 1.5, 0.0, 0.05, Props.mat(Color("d8cfbe"), 0.0, false, "marble", false), 16, 1)
	shell(root, c + Vector3(0, 11.0, 0), r + 0.15, 0.92, PI / 2.0, PI * 1.5, 0.0, PI / 2.0, _mosaic(), 20, 8)
	shell(root, c + Vector3(0, 5.2, 0), r - 0.06, 23.5, PI / 2.0, PI * 1.5, 0.0, 0.05, _mosaic(), 16, 1)
	# Açıklığın üst köşeleri (dikdörtgen açıklık ile yarım kubbe arası): altın dolgu
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cell := 0.25
	var x := -5.0
	while x < 5.0:
		var y := 11.0
		while y < 15.6:
			var mid := Vector2(x + cell / 2.0, y + cell / 2.0 - 11.0)
			if pow(mid.x / (r + 0.1), 2.0) + pow(mid.y / ((r + 0.15) * 0.92 - 0.05), 2.0) > 1.0:
				var q := [Vector3(x, y, -16.02), Vector3(x + cell, y, -16.02), Vector3(x + cell, y + cell, -16.02), Vector3(x, y + cell, -16.02)]
				for idx in [0, 1, 2, 0, 2, 3]:
					st.set_normal(Vector3.BACK)
					st.add_vertex(q[idx])
			y += cell
		x += cell
	var fill := MeshInstance3D.new()
	fill.mesh = st.commit()
	fill.material_override = _mosaic()
	root.add_child(fill)
	# Üç pencere (ışıklı)
	for k in 3:
		var a := PI + (k - 1) * 0.5
		var w := Props.box(root, Vector3(0.9, 2.6, 0.1), c + Vector3(sin(a) * (r - 0.1), 7.6, cos(a) * (r - 0.1)), Color("fff4d8"), Vector3(0, rad_to_deg(a), 0))
		w.material_override = Props.mat(Color("fff0c8"), 1.8, false, "", false)
	# Meryem ve Çocuk (Theotokos, 867): yarım kubbenin ortasında
	var fig := Node3D.new()
	fig.position = c + Vector3(0, 12.0, -2.9)
	fig.rotation.x = deg_to_rad(-14)
	root.add_child(fig)
	_throne_figure(fig, Vector3.ZERO, 2.8, Color("22305a"), Color("e8c8a0"), false)
	# Sentronon: üç yarım daire basamak ve ortada patrik tahtı
	for k in 3:
		var sr := r - 0.4 - k * 0.5
		var step := shell(root, c + Vector3(0, 0.25 + k * 0.4, 0), sr, 0.01, PI / 2.0, PI * 1.5, 0.0, 0.1, Props.mat(Color("e4ded2"), 0.0, false, "marble", false), 16, 1)
		step.scale.y = 1.0
		Props.cyl(root, sr, 0.4, c + Vector3(0, 0.2 + k * 0.4, 0), Color("e4ded2"), Vector3.ZERO, 20).scale = Vector3(1, 1, 0.5)
	Props.box(root, Vector3(0.8, 1.6, 0.6), c + Vector3(0, 1.8, -3.9), Color("d8cfc0"))
	# Altar ve gümüş kiborion (dört sütun, piramit çatı, haç)
	var al := Vector3(0, 0, -13.2)
	Props.solid(root, Vector3(1.8, 1.0, 1.1), al + Vector3(0, 0.5, 0), Color("e8e0d0"))
	Props.box(root, Vector3(1.9, 0.05, 1.2), al + Vector3(0, 1.03, 0), Color("8a2a2a"))
	Props.box(root, Vector3(0.9, 0.04, 0.6), al + Vector3(0, 1.07, 0), GOLD)
	Props.box(root, Vector3(0.3, 0.4, 0.05), al + Vector3(0, 1.3, -0.2), GOLD)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var cp := al + Vector3(sx * 1.4, 0, sz * 1.2)
			Props.cyl(root, 0.12, 4.0, cp + Vector3(0, 2.0, 0), SILVER, Vector3.ZERO, 10)
	Props.box(root, Vector3(3.2, 0.3, 2.8), al + Vector3(0, 4.15, 0), SILVER)
	Props.prism(root, Vector3(3.2, 1.4, 2.8), al + Vector3(0, 5.0, 0), SILVER)
	Props.box(root, Vector3(0.08, 0.7, 0.08), al + Vector3(0, 6.0, 0), GOLD)
	Props.box(root, Vector3(0.4, 0.08, 0.08), al + Vector3(0, 6.15, 0), GOLD)
	var al_light := OmniLight3D.new()
	al_light.position = c + Vector3(0, 6.0, 1.5)
	al_light.light_color = Color("ffd89a")
	al_light.light_energy = 1.6
	al_light.omni_range = 12.0
	root.add_child(al_light)


## Gümüş kaplı templon (ikonlu), nefin ortasında ambon ve templona uzanan solea.
static func _templon_ambo(root: Node3D) -> void:
	var tz := -10.6
	# Alçak mermer parapet (çarpışmalı), ortada Kutsal Kapılar açıklığı
	for sx in [-1.0, 1.0]:
		var p := Props.solid(root, Vector3(4.8, 1.1, 0.25), Vector3(sx * 3.9, 0.55, tz), Color("ece6da"))
		(p.get_child(0) as MeshInstance3D).material_override = Props.mat(Color("f0eadc"), 0.0, false, "marble", false)
		# Levhalarda haç ve çember kabartma
		for k in 2:
			Props.cyl(p, 0.35, 0.03, Vector3(-1.2 + k * 2.4, 0.0, 0.14), SILVER, Vector3(90, 0, 0), 14)
	# Gümüş sütunlar ve arşitrav; üstünde ikonlar
	for i in 7:
		var x := -6.3 + i * 2.1
		if absf(x) < 0.5:
			continue
		Props.cyl(root, 0.1, 3.0, Vector3(x, 1.5 + 0.0, tz), SILVER, Vector3.ZERO, 10)
	Props.box(root, Vector3(13.0, 0.35, 0.35), Vector3(0, 3.15, tz), SILVER)
	var icons := [Color("7a2a2a"), Color("2a3a6a"), Color("2a5a3a"), Color("2a3a6a"), Color("7a2a2a")]
	for i in 5:
		var ix := -4.8 + i * 2.4
		Props.box(root, Vector3(0.9, 1.2, 0.06), Vector3(ix, 4.0, tz + 0.05), GOLD)
		Props.box(root, Vector3(0.7, 1.0, 0.07), Vector3(ix, 4.0, tz + 0.06), icons[i])
		Props.ball(root, 0.13, Vector3(ix, 4.25, tz + 0.1), Color("e8c8a0"), Vector3(1, 1.2, 0.3), 8)
		Props.cyl(root, 0.18, 0.02, Vector3(ix, 4.28, tz + 0.08), Color("f4d878"), Vector3(90, 0, 0), 12)
	Props.box(root, Vector3(0.1, 0.8, 0.1), Vector3(0, 4.9, tz), GOLD)
	Props.box(root, Vector3(0.5, 0.1, 0.1), Vector3(0, 5.05, tz), GOLD)
	# Ambon: nefin ortasında oval kürsü, iki yanında merdiven
	var am := Vector3(0, 0, -1.0)
	var body := Props.solid(root, Vector3(2.4, 1.7, 1.8), am + Vector3(0, 0.85, 0), Color("e8e0d0"))
	(body.get_child(0) as MeshInstance3D).material_override = Props.mat(Color("ece4d4"), 0.0, false, "marble", false)
	Props.cyl(root, 1.35, 0.25, am + Vector3(0, 1.8, 0), Color("d8cfc0"), Vector3.ZERO, 16).scale = Vector3(1, 1, 0.8)
	for sz in [-1.0, 1.0]:
		for k in 5:
			Props.box(root, Vector3(1.0, 0.34 * (k + 1), 0.35), am + Vector3(0, 0.17 * (k + 1), sz * (2.4 - k * 0.3)), Color("e0d8c8"))
	for sx in [-1.0, 1.0]:
		for k in 4:
			Props.cyl(root, 0.12, 1.6, am + Vector3(sx * 1.3, 0.8, -0.6 + k * 0.4), VERDE, Vector3.ZERO, 8)
	# Solea: ambondan templona iki alçak parapet (yürüme yolu)
	for sx in [-1.0, 1.0]:
		Props.solid(root, Vector3(0.2, 0.9, 6.0), Vector3(sx * 0.9, 0.45, (tz + am.z - 2.6) / 2.0 - 0.2), Color("ece6da"))
	# Kandil sehpası (proskynetarion) ve mumlar: kapının yanında
	var pk := Vector3(-3.5, 0, 12.5)
	Props.box(root, Vector3(0.7, 1.2, 0.5), pk + Vector3(0, 0.6, 0), Color("6b4428"), Vector3(-15, 0, 0))
	Props.box(root, Vector3(0.5, 0.65, 0.04), pk + Vector3(0, 1.3, 0.1), GOLD, Vector3(-15, 0, 0))
	Props.box(root, Vector3(0.4, 0.5, 0.05), pk + Vector3(0, 1.3, 0.12), Color("2a3a6a"), Vector3(-15, 0, 0))
	Props.cyl(root, 0.35, 0.9, pk + Vector3(1.0, 0.45, 0), Color("a8883a"), Vector3.ZERO, 12)
	for k in 9:
		var mp := pk + Vector3(1.0 + (k % 3 - 1) * 0.18, 1.0, (k / 3 - 1) * 0.18)
		Props.cyl(root, 0.015, 0.2, mp, Color("f4ecd8"), Vector3.ZERO, 5)
		Props.ball(root, 0.025, mp + Vector3(0, 0.13, 0), Color("ffb040"), Vector3(1, 1.8, 1), 5).material_override = Props.mat(Color("ffb040"), 4.0, false, "", false)
	var cl := OmniLight3D.new()
	cl.position = pk + Vector3(1.0, 1.6, 0)
	cl.light_color = Color("ffb060")
	cl.light_energy = 1.0
	cl.omni_range = 4.0
	root.add_child(cl)


## Polykandela: zincirlerle kubbeden sarkan büyük halkalar, her birinde yağ kandilleri.
static func _lamps(root: Node3D) -> void:
	var flame := Props.mat(Color("ffc860"), 4.0, false, "", false)
	var spots := [Vector3(0, 4.8, 3.5), Vector3(-5.5, 4.8, -3.0), Vector3(5.5, 4.8, -3.0), Vector3(-5.5, 4.8, 6.0), Vector3(5.5, 4.8, 6.0),
		Vector3(-13.5, 3.8, -8.0), Vector3(13.5, 3.8, -8.0), Vector3(13.5, 3.8, 8.0)]
	for i in spots.size():
		var p: Vector3 = spots[i]
		var big := i < 5
		var rr := 1.6 if big else 0.9
		Props.ring(root, rr - 0.06, rr, p, Color("a8883a"))
		var top_y := 16.0 if big else 7.4
		for k in 3:
			var a := TAU * k / 3.0
			var from := p + Vector3(sin(a) * rr, 0, cos(a) * rr)
			var mid := p + Vector3(0, 1.6, 0)
			var d := mid - from
			var ch := Props.cyl(root, 0.008, d.length(), (from + mid) / 2.0, Color("3a3a3a"), Vector3.ZERO, 3)
			ch.look_at_from_position((from + mid) / 2.0, mid, Vector3.RIGHT)
			ch.rotate_object_local(Vector3.RIGHT, PI / 2.0)
		Props.cyl(root, 0.01, top_y - p.y - 1.6, p + Vector3(0, 1.6 + (top_y - p.y - 1.6) / 2.0, 0), Color("3a3a3a"), Vector3.ZERO, 3)
		var n := 16 if big else 8
		for k in n:
			var a := TAU * k / n
			var lp := p + Vector3(sin(a) * rr, 0.08, cos(a) * rr)
			Props.cyl(root, 0.05, 0.1, lp, Color(0.9, 0.95, 1.0, 0.5), Vector3.ZERO, 6, 0.07)
			Props.ball(root, 0.03, lp + Vector3(0, 0.08, 0), Color("ffc860"), Vector3(1, 1.8, 1), 4).material_override = flame
	for p in [Vector3(0, 7.0, 3.0), Vector3(0, 7.0, -7.0), Vector3(-13.5, 4.0, 0), Vector3(13.5, 4.0, 0)]:
		var l := OmniLight3D.new()
		l.position = p
		l.light_color = Color("ffcf8a")
		l.light_energy = 2.2 if p.x == 0.0 else 1.2
		l.omni_range = 18.0 if p.x == 0.0 else 10.0
		root.add_child(l)


## İçeride: dua eden birkaç kişi, bir papaz, mum yakan kadın.
static func _people(root: Node3D) -> void:
	var specs := [
		[Vector3(-1.5, 0, -8.8), PI, {"coat": Color("1e1e22"), "robe": Color("1e1e22"), "beard": true, "hat": "kamelaukion", "hair": Color("8a8a8a")}],
		[Vector3(-3.0, 0, -6.0), PI, {"coat": Color("6a3a5a"), "robe": Color("6a3a5a"), "skirt": true, "hat": "hood"}],
		[Vector3(2.4, 0, -5.4), PI, {"coat": Color("7a6a4a"), "robe": Color("7a6a4a"), "beard": true}],
		[Vector3(-2.4, 0, 12.2), -PI / 2.0, {"coat": Color("3a5a6a"), "robe": Color("3a5a6a"), "skirt": true, "hat": "bun"}],
		[Vector3(10.0, 0, 4.0), PI * 0.8, {"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true}],
	]
	for s in specs:
		var person := Person.new(s[2])
		person.position = s[0]
		person.rotation.y = s[1]
		person.set_meta("no_unclip", true)
		root.add_child(person)
