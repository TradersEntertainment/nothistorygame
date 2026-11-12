class_name HornWorld
extends Node3D
## Tek haritanın (World1453) kara surları kuşağı dışında kalan her şeyi: SiegeField'in içinde, dünya koordinatında.
##   · Su: Haliç (iç kolu surların dışında +z'ye uzanır), Boğaz (burnun ötesi), Marmara (surların güney ucu ve şehrin
##     güney kıyısı). Su yalnız su olan yerlere döşenir (kara surlarının hendeği kuru kalır).
##   · Şehir kıyı surları: Haliç boyunca (kuleler, Petrion kapısı, ağızda Eugenius kulesi), Marmara boyunca, burunda.
##   · Şehrin doğu yarısı (z −560…−1700): evler, kiliseler, serviler, Ayasofya, Hipodrom ve dikilitaş, Konstantin
##     sütunu, Büyük Saray'ın teraslı kalıntıları. Gece pencereler.
##   · Kuzey kıyı: Galata (GalataView: sur, evler, kule), Kasımpaşa sırtları, Pınarlar Vadisi'nde karaya çekilmiş
##     Osmanlı kadırgaları ve kızak yolu, kıyı boyunca çadırlar ve ateşler.
##   · Zincir (ağızda yüzen kütükler) ve ardında Haliç'teki Hıristiyan gemileri; Boğaz'ın ve Marmara'nın karşı kıyıları.
##   · Blakherna (bölge Blakherna değilse uzak siluet): tek yüksek sur, kuleler, Tekfur Sarayı.
##   · Uzak siluet (Landmarks1453.skyline): pusu delen düz renkli anıt kütleleri; suda kayıklar, yelkenliler, devriye
##     kadırgaları ve martılar (_water_life); Diplokionion'da demirli Osmanlı donanması; Khalkedon köyü.
##   · Tarih: Pınarlar Vadisi'ndeki kadırgalar ve kızak yolu 22 Nisan'dan önceki sayfalarda yok (Landmarks1453).
## Uzak görünüm; oynanış alanı değil. Bölgenin keep dikdörtgenlerine bir şey koymaz.

const STONE := Color("cdbd9e")
const DARK_ARCH := Color("3a3034")     # kemer açıklıkları, pencereler (uzaktan karanlık iç)

var region_name := ""
var keep: Array = []
var night := true                  # gündüz bölgelerinde pencereler yanmaz (Galata)
var _night: Array[Node3D] = []
var _day: Array[Node3D] = []
var rng := RandomNumberGenerator.new()
## Uçuş (WorldFlight): Dressing ağıyla kurulan kıyı surlarının kaba kutuları [Transform3D, boyut]
var flight_boxes: Array = []
var _wall_men: Array = []          # kıyı surlarının ve Blakherna'nın savunanları (Garrison.far_men)


func build() -> void:
	rng.seed = 145321
	var t := Time.get_ticks_msec()
	var prof := func(label: String) -> void:
		if OS.get_environment("WORLD_PROF") != "":
			print("PROF horn.", label, " ", Time.get_ticks_msec() - t, "ms")
		t = Time.get_ticks_msec()
	_water()
	prof.call("water")
	_north_shore()
	prof.call("north_shore")
	_city_east()
	prof.call("city_east")
	_horn_walls()
	_horn_shore()
	prof.call("horn_walls")
	_marmara_walls()
	prof.call("marmara_walls")
	_chain()
	prof.call("chain")
	if region_name != "blachernae":
		_blachernae()
	_far_shores()
	prof.call("far_shores")
	_monuments()
	prof.call("monuments")
	_water_life()
	_skyline = Landmarks1453.skyline(self, _free, region_name, keep)
	prof.call("water_life+skyline")
	if not _wall_men.is_empty():
		var root := Node3D.new()
		root.name = "WallMen"
		add_child(root)
		Garrison.far_men(root, _wall_men, Garrison.COATS)
		prof.call("wall_men")


func set_mode(mode: String) -> void:
	for n in _night:
		n.visible = mode != "day"
	for n in _day:
		n.visible = mode != "night"


func _free(x: float, z: float, margin := 4.0) -> bool:
	for r in keep:
		if (r as Rect2).grow(margin).has_point(Vector2(x, z)):
			return false
	return true


# ---------------------------------------------------------------- su

func _plane(x0: float, x1: float, z0: float, z1: float, sub := 0) -> void:
	var m := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(x1 - x0, z1 - z0)
	if sub > 0:
		pm.subdivide_width = int((x1 - x0) / sub)
		pm.subdivide_depth = int((z1 - z0) / sub)
	m.mesh = pm
	m.position = Vector3((x0 + x1) * 0.5, -1.6, (z0 + z1) * 0.5)
	if _water_mat == null:
		_water_mat = ShaderMaterial.new()
		_water_mat.shader = load("res://assets/shaders/water.gdshader")
		_water_mat.set_shader_parameter("foam_width", 0.0)
	m.material_override = _water_mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(m)


var _water_mat: ShaderMaterial


func _water() -> void:
	# Haliç (kuzey kıyının toprağı suyun üstüne biner)
	_plane(-1000.0, World1453.HORN_S_X, -1700.0, 560.0, 4)
	# Boğaz ve burnun ötesi: akıntı güneye (dünya +x), suda uzun köpük izleri
	_plane(-3200.0, 3600.0, -4200.0, -1700.0)
	var bm := (_water_mat as ShaderMaterial).duplicate() as ShaderMaterial
	var fw := global_transform.basis * Vector3(0.6, 0.0, 0.0) if is_inside_tree() else Vector3(0.6, 0.0, 0.0)
	bm.set_shader_parameter("flow", Vector2(fw.x, fw.z))
	bm.set_shader_parameter("streaks", 0.25)
	(get_child(get_child_count() - 1) as MeshInstance3D).material_override = bm
	# Marmara: şehrin güney kıyısı (şehir zemini suyun üstünde) ve surların güney ucunun ötesi
	_plane(-560.0, 3600.0, -1700.0, -12.0)
	_plane(700.0, 3600.0, -12.0, 1600.0)


# ---------------------------------------------------------------- kuzey kıyı

## raw: bölgenin düz alanlarını yok say (bölgenin kendi arazisi kenarında dünyayla buluşsun diye)
static func north_h(x: float, z: float, raw := false) -> float:
	if not raw:
		for r in SiegeField.flat_rects:
			if (r as Rect2).has_point(Vector2(x, z)):
				return SiegeField.flat_y - SiegeField.flat_sink()
	var shore := World1453.horn_n_x(z)
	if z < World1453.TIP.z + 40.0:
		shore = minf(shore, World1453.HORN_N_X - (World1453.TIP.z + 40.0 - z) * 0.8)
	var d := shore - x                          # kıyıdan içeri (+)
	var h := 2.0 + 42.0 * smoothstep(10.0, 520.0, d) * (0.65 + 0.35 * sin(z * 0.0042 + 0.7))
	# Pınarlar Vadisi: sırtlar arasında çukur
	h *= 1.0 - 0.65 * exp(-pow((z + 900.0) / 130.0, 2.0))
	# Galata tepesi
	var g: Vector3 = World1453.LANDMARKS["galata_center"]
	h += 26.0 * exp(-(pow((x - g.x) / 170.0, 2.0) + pow((z - g.z) / 150.0, 2.0)))
	# Kıyı: suya iner
	var y := lerpf(-4.0, h, smoothstep(-6.0, 14.0, d))
	return y if raw else SiegeField.flat_mix(y, x, z, SiegeField.flat_y)


## Görünen arazinin yüzeyi (kuzey kıyı 40 m, doğu şehri 30 m, Asya 80 m ızgara): yapılar, çadırlar, ağaçlar, gemiler
## buna oturur (analitik yükseklik ızgara köşeleri arasında görünenden metrelerce sapabiliyordu)
static func north_surf(x: float, z: float) -> float:
	return LowPoly.surface_y(x, z, -2600.0, -700.0, -2100.0, 900.0, 48, 75, func(px: float, pz: float) -> float: return north_h(px, pz))


static func east_surf(x: float, z: float) -> float:
	return LowPoly.surface_y(x, z, -760.0, 760.0, -1780.0, -700.0, 52, 36, func(px: float, pz: float) -> float: return World1453.city_ground(px, pz))


static func asia_surf(x: float, z: float) -> float:
	return LowPoly.surface_y(x, z, -3000.0, 1800.0, -3700.0, -2050.0, 60, 40, func(px: float, pz: float) -> float: return asia_h(px, pz))


func _north_shore() -> void:
	var hf := func(x: float, z: float) -> float: return north_surf(x, z)
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		var c := Color("5e6a3e").lerp(Color("7a7048"), clampf(0.5 + 0.5 * sin(x * 0.011 + z * 0.007), 0.0, 1.0) * 0.5)
		if y < 0.4:
			c = Color("8a7a58")
		return c.darkened(clampf(steep * 0.5, 0.0, 0.25))
	# x −700'e kadar: kara surları ovasının arazisiyle birleşir (Haliç'in ucunun kuzeyinde boşluk kalmasın)
	add_child(LowPoly.terrain(-2600.0, -700.0, -2100.0, 900.0, 48, 75, hf, cf))
	# Galata (Ceneviz kasabası): sur, evler, kule
	var tw: Vector3 = World1453.LANDMARKS["galata_tower"]
	var gc: Vector3 = World1453.LANDMARKS["galata_center"]
	var top := World1453.galata_top(tw)
	# Evler kutu değil, şehrin ve Galata bölümünün Kit evleri (CityHouses: yakın tam model, orta sade, uzak kutu)
	var gnd := Dressing.new(333)
	gnd.chunk = 240.0
	GalataView.build(self, hf, Vector2(tw.x, tw.z), top, Vector2(gc.x, gc.z), 150.0, -1.6, 1453, night, keep,
		func(list: Array) -> void: CityHouses.build(self, list, func(px: float, pz: float) -> float: return north_surf(px, pz), _free, gnd))
	_night.append(gnd.build(self))
	# Osmanlı yakası: çadırlar, ateşler (Galata'nın çevresi boş)
	var d := Dressing.new(331)
	d.chunk = 240.0
	var nd := Dressing.new(332)
	nd.chunk = 240.0
	for i in 420:
		var z := rng.randf_range(-1250.0, 760.0)
		var shore := World1453.horn_n_x(z)
		var x := shore - rng.randf_range(40.0, 900.0)
		if Vector2(x - gc.x, z - gc.z).length() < 230.0 or not _free(x, z):
			continue
		var y := north_surf(x, z)
		var c: Color = [Color("e8dcc0"), Color("d8c8a0"), Color("c8262f"), Color("e0d4b8")][i % 4]
		# Osmanlı çadırı (Night.tent biçimi: yuvarlak keçe gövde, sivri tepe, bant): eskiden üçgen prizma kutular
		d.cyl(2.4, 1.6, Vector3(x, y + 0.8, z), c, Vector3.ZERO, 8)
		d.cyl(2.55, 2.0, Vector3(x, y + 2.6, z), c.darkened(0.08), Vector3.ZERO, 8, 0.05)
		if i % 3 == 0:
			nd.glow(Vector3(1.0, 1.2, 1.0), Vector3(x + 4.0, y + 0.8, z), Color("ffa040"))
	# Pınarlar Vadisi: kıyıya çekilmiş kadırgalar (kızak yolundan gelenler) ve kızak yolu; 22 Nisan'dan önce yoklar
	var sp: Vector3 = World1453.LANDMARKS["springs"]
	var fleet := Landmarks1453.fleet_in_horn(self)
	for i in 34:
		var z := sp.z - 170.0 + i * 10.0
		var x := World1453.HORN_N_X + rng.randf_range(-6.0, 18.0)
		if not _free(x - 8.0, z, 12.0):
			continue          # bölgenin (Bölüm 2'nin kızağı) içi
		var y := -1.2 if x > World1453.HORN_N_X else north_surf(x, z) - 0.2
		var yaw := deg_to_rad(rng.randf_range(-8.0, 8.0))      # rastgele sıra her tarihte aynı kalsın: önce çekilir
		if not fleet:
			continue
		d.box(Vector3(22.0, 1.6, 3.6), Vector3(x - 8.0, y + 0.6, z), Color("4a3220"), Vector3(0, 90.0 + rad_to_deg(yaw), 0))
		d.box(Vector3(18.0, 0.3, 3.0), Vector3(x - 8.0, y + 1.5, z), Color("8a6a40"), Vector3(0, 90.0 + rad_to_deg(yaw), 0))
		d.cyl(0.18, 11.0, Vector3(x - 8.0, y + 6.5, z), Color("5a3e26"), Vector3.ZERO, 5)
		d.box(Vector3(0.1, 0.1, 9.0), Vector3(x - 8.0, y + 11.0, z), Color("5a3e26"), Vector3(30, 0, 0))
	# Kızak yolu: Boğaz yakasından sırtı aşan, yağlanmış kütükler
	var a := Vector3(-1500.0, 0, -1720.0)
	var b := Vector3(World1453.SLIP_TOP.x, 0, World1453.SLIP_TOP.z)      # Bölüm 2'nin kızağının tepesi
	for k in (70 if fleet else 0):
		var p := a.lerp(b, k / 69.0)
		if not _free(p.x, p.z):
			continue
		p.y = north_surf(p.x, p.z) + 0.15
		d.box(Vector3(5.0, 0.3, 0.4), p, Color("6a4a2c"), Vector3(0, rad_to_deg(atan2(b.x - a.x, b.z - a.z)) + 90.0, 0))
	d.build(self)
	_night.append(nd.build(self))
	# Kuzey kıyıda ağaçlar ve serviler
	Scenery.trees(self, Vector3(-1500.0, 0, -300.0), 120.0, 900.0, 160, [Rect2(gc.x - 220.0, gc.z - 220.0, 440.0, 440.0)], hf, 3321)


# ---------------------------------------------------------------- şehrin doğu yarısı

func _city_east() -> void:
	var hf := func(x: float, z: float) -> float: return World1453.city_ground(x, z)
	var ccf := func(x: float, z: float, y: float, steep: float) -> Color:
		var c := Color("7a7050").lerp(Color("5a6a40"), clampf(0.5 + 0.5 * sin(x * 0.05 - z * 0.04), 0.0, 1.0) * 0.6)
		if y < -0.6:
			c = Color("8a7a58")
		return c.darkened(clampf(steep * 0.5, 0.0, 0.25))
	add_child(LowPoly.terrain(-760.0, 760.0, -1780.0, -700.0, 52, 36, hf, ccf))
	# Sokaklar ve meydanlar (CityPlan): döşeme bütün şehir için burada; evler sokak kenarında, cephesi sokağa bakar
	var tp := Time.get_ticks_msec()
	var sub := func(label: String) -> void:
		if OS.get_environment("WORLD_PROF") != "":
			print("PROF horn.city.", label, " ", Time.get_ticks_msec() - tp, "ms")
		tp = Time.get_ticks_msec()
	CityPlan.graph()
	sub.call("plan")
	CityPlan.build_paving(self, _free)
	sub.call("paving")
	var surf := func(px: float, pz: float) -> float:
		return LowPoly.surface_y(px, pz, -760.0, 760.0, -1780.0, -700.0, 52, 36, hf)
	var nd := Dressing.new(341)
	nd.chunk = 240.0
	CityHouses.build(self, CityPlan.houses_in(-INF, -700.0), surf, _free, nd)
	_night.append(nd.build(self))
	sub.call("houses")
	# Kiliseler (sokakların, evlerin ve anıtların dışında: blokların içi): haç planlı, kasnaklı kubbe, apsis, kiremit
	# beşik çatılar (eskiden kutu + silindir + top: havadan "küp küp"); birleşik ağ
	var cd := Dressing.new(344)
	cd.chunk = 240.0
	var placed := 0
	for i in 90:
		var x := rng.randf_range(-650.0, 600.0)
		var z := rng.randf_range(-1650.0, -700.0)
		var r := rng.randf_range(5.0, 8.5)
		if placed >= 22 or not World1453.in_city(x, z, 30.0) or not _free(x, z, 12.0) or CityPlan.blocked(x, z, r * 1.6):
			continue
		placed += 1
		_church(cd, Vector3(x, east_surf(x, z) - 0.3, z), r)
	cd.build(self)
	# Tarihî yapılar (Landmarks1453): Aya İrini, Augustaion, forumlar, manastırlar, limanlar, Altınkapı...
	Landmarks1453.build(self, _free, region_name)
	sub.call("landmarks")
	# Mese'nin revakları
	_porticoes()
	sub.call("porticoes")
	# Ayasofya, Hipodrom ve dikilitaş, Konstantin sütunu, Büyük Saray terasları
	var ay2: Vector3 = World1453.LANDMARKS["ayasofya"]
	if _free(ay2.x, ay2.z, 60.0):
		# Yerdeki Ayasofya'nın kendisi (ByzCity.aya_exterior, bölümlerin Ayasofya'sı; World1453.far_aya): eskiden ayrı, iki
		# kat büyük, koyu kızıl bir model (Scenery.hagia_merged). Uzakta uzak siluet (Landmarks1453.skyline) yerini alır.
		var fa := World1453.far_aya(self)
		(fa.get_node("FarAyasofyaLo") as GeometryInstance3D).visibility_range_end = Landmarks1453.SK_NEAR + 60.0
	var hp2: Vector3 = World1453.LANDMARKS["hippodrome"]
	var hy := east_surf(hp2.x, hp2.z)
	var d := Dressing.new(342)
	d.chunk = 240.0
	# Hipodrom (eskiden iki düz kutu duvar): dışta iki kat kemerli galeri (ayaklar, kemer açıklıkları, kuşak silmesi),
	# kuzey ucunda kapılı başlangıç binası (carceres) ve kuleleri, doğu yanında imparator locası (kathisma), ortada
	# spina üstünde Mısır Dikilitaşı (kaidesiyle) ve Yılanlı Sütun
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(8.0, 9.0, 220.0), Vector3(hp2.x + sx * 40.0, hy + 4.5, hp2.z), STONE.darkened(0.15))
		d.box(Vector3(8.6, 0.6, 220.6), Vector3(hp2.x + sx * 40.0, hy + 9.2, hp2.z), STONE.darkened(0.05))
		d.box(Vector3(8.5, 0.4, 220.4), Vector3(hp2.x + sx * 40.0, hy + 4.6, hp2.z), STONE.darkened(0.02))
		var zz := -104.0
		while zz <= 104.0:
			for lv: float in [0.0, 4.6]:
				d.box(Vector3(0.3, 3.4, 3.2), Vector3(hp2.x + sx * 44.05, hy + lv + 1.95, hp2.z + zz), DARK_ARCH)
			zz += 8.0
	d.box(Vector3(88.0, 9.0, 10.0), Vector3(hp2.x, hy + 4.5, hp2.z + 110.0), STONE.darkened(0.2))
	d.box(Vector3(88.6, 0.6, 10.6), Vector3(hp2.x, hy + 9.2, hp2.z + 110.0), STONE.darkened(0.08))
	for k in 12:
		var gx := hp2.x - 33.0 + k * 6.0
		d.box(Vector3(3.6, 4.6, 0.3), Vector3(gx, hy + 2.3, hp2.z + 104.9), DARK_ARCH)
	for sx: float in [-1.0, 1.0]:
		d.box(Vector3(9.0, 15.0, 9.0), Vector3(hp2.x + sx * 40.0, hy + 7.5, hp2.z + 110.0), STONE.darkened(0.12))
		d.cyl(5.2, 2.4, Vector3(hp2.x + sx * 40.0, hy + 16.2, hp2.z + 110.0), Landmarks1453.LEAD, Vector3(0, 45, 0), 4, 0.05)
	# Kathisma: doğu duvarına yaslı, kemerli cepheli, kubbeli loca
	var kx := hp2.x + 46.0
	d.box(Vector3(10.0, 14.0, 22.0), Vector3(kx, hy + 7.0, hp2.z + 10.0), Landmarks1453.BRICK)
	for k in 3:
		d.box(Vector3(0.3, 4.0, 3.4), Vector3(kx - 5.05, hy + 9.5, hp2.z + 3.0 + k * 7.0), DARK_ARCH)
	Landmarks1453._dome(d, Vector3(kx, hy + 14.0, hp2.z + 10.0), 4.2, 2.4)
	d.box(Vector3(70.0, 0.2, 210.0), Vector3(hp2.x, hy + 0.1, hp2.z), Color("a89878"))
	d.box(Vector3(2.0, 1.2, 160.0), Vector3(hp2.x, hy + 0.6, hp2.z), STONE)
	d.box(Vector3(4.2, 2.6, 4.2), Vector3(hp2.x, hy + 1.3, hp2.z - 30.0), Landmarks1453.MARBLE.darkened(0.06))
	d.cyl(1.4, 20.0, Vector3(hp2.x, hy + 12.6, hp2.z - 30.0), Color("c8a888"), Vector3(0, 45, 0), 4, 0.3)
	d.cyl(0.42, 1.2, Vector3(hp2.x, hy + 23.2, hp2.z - 30.0), Landmarks1453.GOLD, Vector3(0, 45, 0), 4, 0.0)
	d.cyl(1.0, 18.0, Vector3(hp2.x, hy + 9.0, hp2.z + 20.0), Color("8a6a50"), Vector3.ZERO, 8)
	var col: Vector3 = World1453.LANDMARKS["column"]
	if region_name != "byz_aya":            # Ayasofya parçası kendi sütununu kurar (ev:column)
		# Yerdeki Konstantin Sütunu'nun biçimi (ByzCity.COLUMN: kaide, porfir gövde, altın halkalar)
		ByzCity.column_parts(func(kind: String, sz: Vector3, at: Vector3, c: Color, _solid: bool) -> void:
			var q := Vector3(col.x, east_surf(col.x, col.z), col.z) + at
			if kind == "box":
				d.box(sz, q, c)
			else:
				d.cyl(sz.x, sz.y, q, c, Vector3.ZERO, 12))
	# Büyük Saray: yamaca basamaklanan teraslar (eskiden düz kutular): kemerli destek duvarları (alt yapı), korkuluk
	# silmesi, üstte bahçe ve döşeme; yıkıntılar Landmarks1453._palace_ruins
	var gp: Vector3 = World1453.LANDMARKS["great_palace"]
	for k in 4:
		var p := gp + Vector3(k * 8.0, 0, -k * 14.0)
		if not _free(p.x, p.z, 20.0):
			continue
		var th := 8.0 + k * 2.0
		var gy := east_surf(p.x, p.z)
		var tc := Color("b8a888").darkened(0.05 * k)
		d.box(Vector3(30.0, th, 40.0), Vector3(p.x, gy + 4.0, p.z), tc)
		d.box(Vector3(30.4, 0.5, 40.4), Vector3(p.x, gy + 4.0 + th * 0.5 + 0.25, p.z), tc.lightened(0.12))
		d.box(Vector3(26.0, 0.1, 30.0), Vector3(p.x, gy + 4.0 + th * 0.5 + 0.52, p.z + 3.0), Color("6a7a48") if k % 2 == 0 else Color("8a7e62"))
		for side: float in [-1.0, 1.0]:
			for a in 6:
				var az := p.z - 15.0 + a * 6.0
				d.box(Vector3(0.3, th * 0.55, 3.0), Vector3(p.x + side * 15.05, gy + 4.0 - th * 0.12, az), DARK_ARCH)
		for a in 5:
			var ax := p.x - 12.0 + a * 6.0
			d.box(Vector3(3.0, th * 0.55, 0.3), Vector3(ax, gy + 4.0 - th * 0.12, p.z - 20.05), DARK_ARCH)
	d.build(self)
	# Serviler ve çınarlar: blokların içindeki bahçelerde (sokaklara, evlere değmez)
	var cyp: Array = []
	var pln: Array = []
	for i in 1600:
		var x := rng.randf_range(-700.0, 700.0)
		var z := rng.randf_range(-1700.0, -700.0)
		var big := i % 5 == 0
		if not World1453.in_city(x, z, 16.0) or not _free(x, z) or CityPlan.blocked(x, z, 4.5 if big else 1.5):
			continue
		var t := Scenery._t(Vector3(x, east_surf(x, z) - 0.2, z), Vector3(0, rng.randf() * TAU, 0), Vector3.ONE * rng.randf_range(0.9, 1.5))
		if big:
			pln.append(t)
		else:
			cyp.append(t)
	Scenery.scatter(self, Scenery.plane_tree_mesh(), pln)
	Scenery.scatter(self, Scenery.cypress_mesh(), cyp)


## Mahalle kilisesi (kapalı Yunan haçı planı, Bizans orta dönemi): kare naos, haç kollarının kiremit beşik çatıları,
## ortada pencereli kasnak ve kurşun kubbe, doğuda apsis, batıda alçak narteks, yanlarda kemerli pencereler. Yönü yerinden
## (rastgele sıra tüketmez). r: eski kutunun ölçüsü (5–8,5 m).
func _church(d: Dressing, p: Vector3, r: float) -> void:
	var yaw := fposmod(p.x * 0.37 + p.z * 0.11, 1.0) * 0.6 - 0.3
	d.at(p, yaw)
	var w := r * 2.0
	var L := r * 2.4
	var h := r * 1.15
	var col := Color("b87060").lerp(Color("c8906a"), fposmod(p.x * 0.013 - p.z * 0.007, 1.0))
	var tile := Landmarks1453.TILE
	d.box(Vector3(w, h, L), Vector3(0, h * 0.5, 0), col)
	d.box(Vector3(w + 0.12, 0.3, L + 0.12), Vector3(0, h * 0.6, 0), Landmarks1453.LIGHT)
	d.prism(Vector3(w * 0.5, r * 0.45, L + 0.5), Vector3(0, h + r * 0.225, 0), tile)
	d.prism(Vector3(w * 0.5, r * 0.45, w + 0.5), Vector3(0, h + r * 0.225, 0), tile.darkened(0.06), Vector3(0, 90, 0))
	Landmarks1453._dome(d, Vector3(0, h + r * 0.35, 0), r * 0.42, r * 0.5)
	Landmarks1453._apse(d, Vector3(0, 0, -L * 0.5), r * 0.42, h * 0.75, col.darkened(0.05))
	d.box(Vector3(w * 0.9, h * 0.62, r * 0.7), Vector3(0, h * 0.31, L * 0.5 + r * 0.35), col.lightened(0.05))
	d.prism(Vector3(w * 0.94, r * 0.3, r * 0.8), Vector3(0, h * 0.62 + r * 0.15, L * 0.5 + r * 0.35), tile, Vector3(0, 90, 0))
	for sx: float in [-1.0, 1.0]:
		for k in 3:
			var zz := -L * 0.3 + k * L * 0.3
			d.box(Vector3(0.15, r * 0.4, r * 0.18), Vector3(sx * (w * 0.5 + 0.02), h * 0.55, zz), DARK_ARCH)
	d.at(Vector3.ZERO)


## Mese'nin Philadelphion'un doğusundaki kesimi revaklı: iki yanda sütun dizisi ve üstünde düz çatı (kavşaklarda
## ve meydanlarda açık)
func _porticoes() -> void:
	var g := CityPlan.graph()
	var nodes: PackedVector3Array = g["nodes"]
	var edges: Array = g["edges"]
	var d := Dressing.new(343)
	d.chunk = 240.0
	for ei in edges.size():
		if not CityPlan.portico(ei):
			continue
		var a: Vector3 = nodes[(edges[ei] as Vector2i).x]
		var b: Vector3 = nodes[(edges[ei] as Vector2i).y]
		var dir := Vector2(b.x - a.x, b.z - a.z)
		var len := dir.length()
		dir /= len
		var n := dir.orthogonal()
		var hw: float = (g["width"] as PackedFloat32Array)[ei] * 0.5
		var yaw := rad_to_deg(atan2(dir.x, dir.y))
		for side: float in [-1.0, 1.0]:
			var t := 2.25
			var run: Array = []
			while t < len:
				var q := Vector2(a.x, a.z) + dir * t
				var cq := q + n * side * (hw + 0.6)
				var open := not _free(cq.x, cq.y, 2.0) or CityPlan.on_plaza(cq.x, cq.y, 1.0) or CityPlan.on_side_street(cq.x, cq.y, 1.2)
				if not open:
					var y := World1453.surface_h(cq.x, cq.y)
					d.box(Vector3(0.8, 0.4, 0.8), Vector3(cq.x, y + 0.1, cq.y), Color("b8b0a0"), Vector3(0, yaw, 0))
					d.cyl(0.26, 4.4, Vector3(cq.x, y + 2.3, cq.y), Color("cfc8b8"), Vector3.ZERO, 8)
					d.box(Vector3(0.75, 0.35, 0.75), Vector3(cq.x, y + 4.55, cq.y), Color("b8b0a0"), Vector3(0, yaw, 0))
					run.append(Vector3(cq.x, y, cq.y))
				if open or t + 4.5 >= len:
					_portico_roof(d, run, n * side, yaw)
					run = []
				t += 4.5
	d.build(self)


func _portico_roof(d: Dressing, run: Array, out: Vector2, yaw: float) -> void:
	if run.size() < 2:
		return
	var p0: Vector3 = run[0]
	var p1: Vector3 = run[run.size() - 1]
	var y := -INF
	for p: Vector3 in run:
		y = maxf(y, p.y)
	var m := (p0 + p1) * 0.5 + Vector3(out.x, 0, out.y) * 1.9
	d.box(Vector3(4.4, 0.45, p0.distance_to(p1) + 1.2), Vector3(m.x, y + 4.8, m.z), Color("b06048"), Vector3(0, yaw, 0))


# ---------------------------------------------------------------- kıyı surları

func _wall_run(a: Vector3, b: Vector3, h: float, tower_step: float, d: Dressing, merl: Array, nd: Dressing, gates: Array = []) -> void:
	var dir := (b - a)
	var len := dir.length()
	dir /= len
	var yaw := rad_to_deg(atan2(dir.x, dir.z))
	var side := Vector3(dir.z, 0, -dir.x)
	# Oynanış alanının kenarında parçalar kısalır (8 m): ucu alana giren 40 m'lik parça bölümün kendi surunun arkasından
	# geçip kapısını kapatıyordu (her yer yürünür)
	var cuts: Array = []
	var n := int(ceil(len / 40.0))
	for k in n:
		var q0 := a.lerp(b, float(k) / n)
		var q1 := a.lerp(b, float(k + 1) / n)
		if _free(q0.x, q0.z, 6.0) and _free(q1.x, q1.z, 6.0):
			cuts.append([q0, q1])
		else:
			var m := int(ceil(q0.distance_to(q1) / 8.0))
			for j in m:
				cuts.append([q0.lerp(q1, float(j) / m), q0.lerp(q1, float(j + 1) / m)])
	for k in cuts.size():
		var p0: Vector3 = cuts[k][0]
		var p1: Vector3 = cuts[k][1]
		var mid := (p0 + p1) * 0.5
		if not _free(mid.x, mid.z, 6.0) or not _free(p0.x, p0.z, 2.0) or not _free(p1.x, p1.z, 2.0):
			continue
		var skip := false
		for g: Vector3 in gates:
			if mid.distance_to(g) < 22.0:
				skip = true
		var seg := p0.distance_to(p1) + 0.4
		# Sur kıyıdan, şehrin kenarının üstüne yükselir (şehir zemini kıyının 10 m içinde 10–20 m yüksekte: eskiden 9 m'lik
		# sur yamacın içinde kalıyor, Galata'dan kıyı çıplak yeşil bir yamaç görünüyordu)
		var hh := _wall_top(mid, side, h)
		if skip:
			# Kapı: iki ayak ve kemer
			d.box(Vector3(3.2, hh + 3.0, seg * 0.35), mid - dir * seg * 0.33 + Vector3(0, (hh - 3.0) * 0.5, 0), STONE.darkened(0.12), Vector3(0, yaw, 0))
			d.box(Vector3(3.2, hh + 3.0, seg * 0.35), mid + dir * seg * 0.33 + Vector3(0, (hh - 3.0) * 0.5, 0), STONE.darkened(0.12), Vector3(0, yaw, 0))
			d.box(Vector3(3.2, hh * 0.35, seg * 0.4), mid + Vector3(0, hh * 0.82, 0), STONE.darkened(0.18), Vector3(0, yaw, 0))
			continue
		d.box(Vector3(3.0, hh + 3.0, seg), mid + Vector3(0, (hh - 3.0) * 0.5, 0), STONE.darkened(0.1 + 0.04 * (k % 3)), Vector3(0, yaw, 0))
		# Tuğla hatıllar (dış yüzde iki kırmızı bant)
		for bh: float in [hh * 0.45, hh * 0.75]:
			d.box(Vector3(0.2, 0.7, seg), mid + Vector3(0, bh, 0) + side * 1.52, Color("9a4e36"), Vector3(0, yaw, 0))
		flight_boxes.append([Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)), mid + Vector3(0, (hh - 3.0) * 0.5, 0)), Vector3(3.0, hh + 3.0, seg)])
		# Savunanlar (dışa, suya bakar) ve gece nöbet ateşleri
		var face := atan2(side.x, side.z)
		var nm := int(seg / 4.5)
		for m in nm:
			if rng.randf() < 0.75:
				var mp := p0.lerp(p1, (m + rng.randf_range(0.2, 0.8)) / nm) + Vector3(0, hh, 0) - side * 0.4
				_wall_men.append(Transform3D(Basis(Vector3.UP, face + rng.randf_range(-0.3, 0.3)), mp))
		if k % 2 == 0:
			nd.glow(Vector3(0.35, 0.5, 0.35), mid + Vector3(0, hh + 1.3, 0) + side * 0.9, Color("ffb040"))
		for m in int(seg / 3.5):
			merl.append(Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)).scaled(Vector3(1.2, 1.0, 1.0)), p0.lerp(p1, (m + 0.5) / int(seg / 3.5)) + Vector3(0, hh + 1.5, 0) + side * 1.2))
	var t := tower_step * 0.5
	while t < len:
		var p := a + dir * t
		var th := _wall_top(p, side, h) + rng.randf_range(3.0, 6.0)
		if not _free(p.x, p.z, 6.0):
			t += tower_step
			continue
		d.box(Vector3(8.0, th + 3.0, 8.0), p + Vector3(0, (th - 3.0) * 0.5, 0) + side * 1.0, STONE.darkened(0.18), Vector3(0, yaw, 0))
		for q in 4:
			d.box(Vector3(1.4, 1.3, 1.4), p + side * 1.0 + Basis(Vector3.UP, deg_to_rad(yaw)) * Vector3((q % 2 - 0.5) * 6.6, th + 1.0, (q / 2 - 0.5) * 6.6), STONE.darkened(0.14), Vector3(0, yaw, 0))
		d.box(Vector3(8.4, 0.5, 8.4), p + Vector3(0, th + 0.2, 0) + side * 1.0, Color("9a5040"), Vector3(0, yaw, 0))
		if rng.randf() < 0.5:
			nd.glow(Vector3(0.4, 0.6, 0.4), p + Vector3(0, th + 1.0, 0), Color("ffb040"))
		t += tower_step


## Kıyı surunun tepesi: iki yandaki görünen zeminin 5 m üstü (en az h); bölümün kendi sur parçasının yanında (keep) eski
## yüksekliğe iner (bölümün suruyla birleşsin)
func _wall_top(p: Vector3, side: Vector3, h: float) -> float:
	var gy := maxf(World1453.surface_h(p.x + side.x * 12.0, p.z + side.z * 12.0), World1453.surface_h(p.x - side.x * 12.0, p.z - side.z * 12.0))
	var top := maxf(h, gy + 5.0)
	var kd := INF
	for r: Rect2 in keep:
		var dx := maxf(maxf(r.position.x - p.x, 0.0), p.x - r.end.x)
		var dz := maxf(maxf(r.position.y - p.z, 0.0), p.z - r.end.y)
		kd = minf(kd, Vector2(dx, dz).length())
	return lerpf(h, top, smoothstep(10.0, 70.0, kd))


func _horn_walls() -> void:
	# Haliç kıyı suru tek kurucudan (SeaWalls.horn_wall_parts): bölümlerin (17, 19, 29, 39o) kendi dilimleri dahil aynı
	# parçalar, aynı yerde, aynı ölçüde; burada birleşik ağ (240 m'lik parça ve desen başına tek çizim). Aktif bölgenin kendi
	# dilimi (SPANS) bölümde kurulur; Horn.build'in suruyla oynanan bölgelerde (18, 18b, 31o, 38o) o dilim atlanır ve
	# komşu sur Horn'un yüksekliğine iner.
	var nd := Dressing.new(352)
	nd.chunk = 240.0
	var merl: Array = []
	var parts: Array = []
	var skip: Array = []
	var ease: Array = []
	if SeaWalls.SPANS.has(region_name):
		skip.append(SeaWalls.SPANS[region_name])
	else:
		for r: Rect2 in keep:
			if r.position.x <= World1453.HORN_S_X + 3.0 and r.end.x >= World1453.HORN_S_X - 3.0:
				skip.append(Vector2(r.position.y, r.end.y))
				ease.append(Vector2(r.position.y, r.end.y))
	var emit := func(kind: String, size: Vector3, xf: Transform3D, color: Color, pattern: String, solid: bool) -> void:
		match kind:
			"merlon":
				merl.append(Transform3D(xf.basis * Basis.from_scale(size), xf.origin))
			"torch":
				if int(absf(xf.origin.z)) % 2 == 0:
					nd.glow(Vector3(0.4, 0.6, 0.4), xf.origin + Vector3(0, 0.5, 0), Color("ffb040"))
			"man":
				_wall_men.append(xf)
			_:
				parts.append([kind, size, xf, color, pattern])
				if solid and kind == "box" and size.y > 3.0:
					flight_boxes.append([xf, size])
	SeaWalls.horn_wall_parts(emit, Vector2.INF, skip, ease)
	SeaWalls.bake_parts(parts, self, "HornWall")
	_night.append(nd.build(self))
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(SeaWalls.C_MERL, 0.0, false, "ashlar"))


## Haliç kıyısı (surun dışı): su çizgisinde alçak taş rıhtım ve rıhtım yolu (bağlama babaları, fıçı, sandık, balya, ağ, balıkçı
## barakaları, çekili kayıklar, suya inen basamaklar), üstünde toprak ve kaya yamaç (çalı, servi, incir, bostan sekileri,
## surdaki kapılara tırmanan patikalar ve taş merdivenler; Landmarks1453.shore_mesh); aralıklarla ahşap iskeleler, üstlerinde
## fıçı, sandık, çuval, ağ; iskelelere bağlı kayıklar ve balıkçı tekneleri. Uzakta çizilmez (900 m): kara surları ve ordugâh
## bölgelerine yük olmaz.
func _horn_shore() -> void:
	# Kıyı kaplaması ve süsleri zeminin üstünde görünüş (no_walk): yürünen yüzey arazinin kendisi. Bölümlerin kendi kayıklarına
	# binilen sayfalar (Haliç kıyısı: 38o, 18, 18b, 31o, zincir) bölgenin 500 m'si içinde su kenarına iskele, eşya, baraka ve
	# kayık konmaz (kayıktaki adam iskeleye basıyordu: VISAUDIT float)
	var d := Dressing.new(353)
	d.chunk = 240.0
	var ro := World1453.region(region_name).origin if World1453.REGIONS.has(region_name) else Vector3(INF, 0, INF)
	var boating := region_name in ["horn_wall_o", "horn_bridge", "eyup", "horn_chain", "petrion"]
	var boats := {"row": [], "fisher": []}
	var vis := func(x: float, z: float) -> float:
		return east_surf(x, z) if z < -700.0 else SiegeField.city_surf(x, z)
	var sfree := func(x: float, z: float) -> bool:
		return _free(x, z, 12.0)
	var qfree := func(x: float, z: float) -> bool:
		return _free(x, z, 12.0) and not (boating and Vector2(-750.0 - ro.x, z - ro.z).length() < 500.0)
	# Kıyı suru: kule ve kapı açıklıklarının z'si (yan kapılar ve eşya bunlardan uzak durur). Tek kaynak: surun kurucusu
	# (SeaWalls._runs, ilk koşu x −700 boyunca): kule ızgarası, kapılar ve kapıların iki yanındaki kuleler aynı yerde
	var avoid: Array = []
	var gates: Array = []
	var run0: Array = SeaWalls._runs()[0]
	var ra: Vector3 = run0[0]
	for ts: float in run0[4]:
		avoid.append(ra.z - ts)
	for g: Array in run0[5]:
		var gz: float = ra.z - float(g[0])
		gates.append(gz)
		avoid.append_array([gz - 14.0, gz, gz + 14.0])
	# İskele konumları (Venedik, Amalfi, Ceneviz iskelelerinin ve kapıların yanı hariç)
	var piers: Array = []
	var pz := -380.0
	while pz > World1453.SHORE_END_Z + 30.0:
		var near := false
		for q: float in [-900.0, -1180.0, -1450.0]:
			near = near or absf(pz - q) < 45.0
		if boating and Vector2(-750.0 - ro.x, pz - ro.z).length() < 500.0:
			near = true
		if not near and _free(-750.0, pz, 30.0):
			piers.append(pz)
		pz -= 115.0
	avoid.append_array(piers)
	# Rıhtım ve yamaç: 15 m'lik dilimler, 240 m'lik parça başına tek ağ
	var z_top := -320.0
	var nseg := int((z_top - (World1453.SHORE_END_Z + 20.0)) / Landmarks1453.SH_STEP)
	var by_chunk := {}
	for j in nseg:
		var qk := int(floorf((z_top - Landmarks1453.SH_STEP * (j + 0.5)) / 240.0))
		if not by_chunk.has(qk):
			by_chunk[qk] = []
		(by_chunk[qk] as Array).append(j)
	var cache := {}
	for qk: int in by_chunk:
		var qm := MeshInstance3D.new()
		qm.name = "QuayStone"
		qm.mesh = Landmarks1453.shore_mesh(by_chunk[qk], z_top, World1453.SEA_Y, vis, sfree, qfree, avoid, piers, gates, cache, boats)
		qm.material_override = Landmarks1453.ship_material()          # dış çizgisiz (ince üst yüzlerde ters yüz kabuğu leke yapar)
		qm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		qm.visibility_range_end = 900.0
		qm.set_meta("no_walk", true)
		add_child(qm)
	# İskeleler: rıhtımın önünden suya uzanır
	var pi := 0
	for pz2: float in piers:
		var xw := Landmarks1453.shore_xw(pz2, World1453.SEA_Y, vis)
		if is_inf(xw) or xw < -758.0:
			continue
		var y := World1453.SEA_Y + 1.1
		d.box(Vector3(34.0, 0.45, 4.0), Vector3(xw - 15.0, y, pz2), Color("7a5634"))
		for j in 6:
			for sz: float in [-1.0, 1.0]:
				d.cyl(0.22, 4.0, Vector3(xw - 1.0 - j * 5.8, y - 1.6, pz2 + sz * 1.8), Color("4a3422"), Vector3.ZERO, 5)
		d.at(Vector3(xw - 9.0, y + 0.22, pz2 + 0.8))
		match pi % 4:
			0:
				d.barrels(Vector3.ZERO)
			1:
				d.crates(Vector3.ZERO)
			2:
				d.sacks(Vector3.ZERO)
			_:
				d.net(Vector3.ZERO)
		d.at(Vector3(xw - 24.0, y + 0.22, pz2 - 0.9))
		d.fish_basket(Vector3.ZERO)
		d.at(Vector3.ZERO)
		boats["row" if pi % 2 == 0 else "fisher"].append(Transform3D(Basis(Vector3.UP, PI * 0.5 + 0.1 * (pi % 3)), Vector3(xw - 20.0, World1453.SEA_Y, pz2 + 4.6)))
		if pi % 3 == 0:
			boats["row"].append(Transform3D(Basis(Vector3.UP, -PI * 0.5), Vector3(xw - 26.0, World1453.SEA_Y, pz2 - 4.4)))
		pi += 1
	var root := d.build(self)
	for mi in root.find_children("*", "MeshInstance3D", false, false):
		(mi as MeshInstance3D).visibility_range_end = 900.0
	for kind: String in boats:
		if not (boats[kind] as Array).is_empty():
			var bm := Scenery.scatter(self, Landmarks1453.ship_mesh(kind), boats[kind], [], Landmarks1453.ship_material())
			bm.name = "MooredBoats"
			bm.visibility_range_end = 900.0


func _marmara_walls() -> void:
	var d := Dressing.new(361)
	d.chunk = 240.0
	var nd := Dressing.new(362)
	nd.chunk = 240.0
	var merl: Array = []
	var ma := Vector3(700.0, 0.0, -14.0)
	var mb := World1453.TIP + Vector3(0, 0, 4.0)
	var mg: Array = []
	for f: float in World1453.MARMARA_GATES:
		mg.append(ma.lerp(mb, f))
	_wall_run(ma, mb, 9.0, 58.0, d, merl, nd, mg)
	# Kıyı kayalıkları
	for i in 60:
		var t := rng.randf()
		var p := Vector3(700.0, 0, -14.0).lerp(World1453.TIP, t)
		var side := Vector3(0.8, 0, 0.6).normalized()
		d.ball(rng.randf_range(1.5, 3.5), p + side * rng.randf_range(4.0, 12.0) + Vector3(0, -1.4, 0), Color("6a6458"), Vector3(1.4, 0.6, 1.0), 6)
	d.build(self)
	_night.append(nd.build(self))
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(STONE.darkened(0.15), 0.0, false, "ashlar"))


# ---------------------------------------------------------------- zincir ve gemiler

func _chain() -> void:
	var d := Dressing.new(371)
	d.chunk = 240.0
	var a: Vector3 = World1453.LANDMARKS["chain_s"]
	var b: Vector3 = World1453.LANDMARKS["chain_n"]
	var yaw := rad_to_deg(atan2(b.x - a.x, b.z - a.z))
	var n := int(a.distance_to(b) / 6.0)
	for k in n:
		var p := a.lerp(b, (k + 0.5) / n)
		d.cyl(0.45, 5.2, Vector3(p.x, -1.35, p.z), Color("5a4030"), Vector3(90, yaw, 0), 8)
	# Zincirin ardında (Haliç'in içinde) Venedik ve Ceneviz gemileri (29 Mayıs'ta kaçtılar: 31o'da yoklar)
	var ships := Landmarks1453.italian_ships(self)
	var by := {"carrack_genoa": [], "carrack_venice": []}
	# Gemiler iç içe geçmesin: 3 sütun x 3 sıra ızgara (sütunlar 60 m, sıralar 52 m arayla, kayma en çok 5 m): her gemi
	# komşusundan en az 46 m (iki gemi boyu) uzakta. Ortak rastgele dizi eskisi kadar (9) tüketilir: sonraki yapılar değişmez.
	for i in 9:
		rng.randf()
	var cr := RandomNumberGenerator.new()
	cr.seed = 1453371
	var n_sh := 0
	for i in 9:
		var p := Vector3(-885.0 + (i % 3) * 60.0 + cr.randf_range(-5.0, 5.0), -1.6, a.z + 46.0 + (i / 3) * 52.0 + cr.randf_range(-3.0, 3.0))
		if not ships or not _free(p.x, p.z, 14.0):
			continue
		by["carrack_genoa" if n_sh % 2 == 0 else "carrack_venice"].append(Transform3D(Basis(Vector3.UP, PI + (n_sh % 3 - 1) * 0.15), p))
		n_sh += 1
	d.build(self)
	for kind: String in by:
		if not (by[kind] as Array).is_empty():
			var mi := Scenery.scatter(self, Landmarks1453.ship_mesh(kind), by[kind], [], Landmarks1453.ship_material())
			mi.name = "ChainShips"
			mi.visibility_range_end = 1400.0


# ---------------------------------------------------------------- Blakherna (uzak siluet)

func _blachernae() -> void:
	var bp: Vector3 = World1453.LANDMARKS["blachernae"]
	# Zemin: Theodosius surlarının bittiği yerden Haliç'e (ova ile şehir arasındaki boşluk kalmasın)
	# (bölümün kendi zemini gibi: içeride arnavut kaldırımı avlu, dışarıda toprak yamaç; eskiden düz gri levha)
	Props.set_pattern(Props.box(self, Vector3(124.0, 0.6, 46.0), Vector3(-640.0, -0.3, 14.0), Color.WHITE), Color("4e4a36"), "dirt")
	# Sur, kuleler, mazgallar ve Tekfur Sarayı: bölümün (30, 30o) kendi kabuğu, aynı ölçü ve desenle (Blachernae.shell_parts,
	# bölümün Props kurucusu sahne dışında, sonra World1453.bake ile tek ağa); eskiden ayrı kutular: 16 m sur, altı kule,
	# pencerisiz saray kütlesi. Işıklı pencereler gece yanar (ayrı ışık ağı).
	var o := World1453.to_world("blachernae", Vector3.ZERO)
	var tb := Blachernae.new()
	tb.in_world = false
	var bn := Dressing.new(362)
	bn.chunk = 400.0
	var emit := func(kind: String, size: Vector3, pos: Vector3, col: Color, pat: String, solid: bool, tag: String) -> void:
		if kind == "glass":
			bn.glow(size, o + pos, col)
		elif kind == "merl":
			Props.set_pattern(Props.box(tb, size, pos, Color.WHITE), col, pat)
		else:
			tb._emit(kind, size, pos, col, pat, solid, tag)
	for part: String in ["wall", "palace", "join"]:
		Blachernae.shell_parts(emit, part)
	World1453.bake(tb.find_children("*", "MeshInstance3D", true, false), tb, Transform3D(Basis.IDENTITY, o), self, "FarBlachernae")
	tb.free()
	_night.append(bn.build(self))
	# Blakherna surunun Haliç'e inen kısmı (köşeden kıyı suruna)
	var w2 := Props.box(self, Vector3(4.0, 14.0, World1453.HORN_IN_Z + 2.0), Vector3(World1453.HORN_S_X + 2.0, 6.0, World1453.HORN_IN_Z * 0.5), Color.WHITE)
	Props.set_pattern(w2, STONE.darkened(0.1), "ashlar")
	# Surun üstünde savunanlar (ovaya bakar)
	var x := -698.0
	while x < -582.0:
		if rng.randf() < 0.8:
			_wall_men.append(Transform3D(Basis(Vector3.UP, rng.randf_range(-0.3, 0.3)), Vector3(x, Blachernae.WALK_Y, 0.6)))
		x += rng.randf_range(2.8, 4.2)


# ---------------------------------------------------------------- karşı kıyılar

func _far_shores() -> void:
	var d := Dressing.new(391)
	d.chunk = 400.0
	# Boğaz'ın Asya yakası (Khrysopolis/Üsküdar, Khalkedon): kıyı burnun ~400 m karşısında; Marmara'nın güney kıyısı, Adalar
	var af := func(x: float, z: float) -> float: return asia_h(x, z)
	var acf := func(x: float, z: float, y: float, steep: float) -> Color:
		var c := Color("6a7a4a").lerp(Color("7e7a52"), clampf(0.5 + 0.5 * sin(x * 0.007 + z * 0.005), 0.0, 1.0) * 0.5)
		if y < 0.6:
			c = Color("8a7a58")
		return c.darkened(clampf(steep * 0.5, 0.0, 0.25))
	add_child(LowPoly.terrain(-3000.0, 1800.0, -3700.0, -2050.0, 60, 40, af, acf))
	for p: Vector3 in [Vector3(2600.0, 0, -1300.0), Vector3(3100.0, 0, -500.0), Vector3(2900.0, 0, -2100.0)]:
		d.ball(160.0, p + Vector3(0, -120.0, 0), Color("6a7a5a").lerp(Color("8a9aa0"), 0.45), Vector3(1.3, 0.8, 1.0), 10)
	d.build(self)
	# Diplokionion (Beşiktaş): Osmanlı donanması Avrupa kıyısının önünde demirli (Nisan ortasından; 7–12 Nisan sayfalarında
	# henüz yok). Kadırgalar gelişigüzel iki üç sıra, başları akıntıya.
	var si := Landmarks1453.siege_index(self)
	if si < 0 or si >= Siege.ORDER.find(41):
		var fr := RandomNumberGenerator.new()
		fr.seed = 1452
		var gx: Array = []
		for i in 120:
			if gx.size() >= 18:
				break
			var z := fr.randf_range(-2060.0, -1840.0)
			var shore := World1453.HORN_N_X - (World1453.TIP.z + 40.0 - z) * 0.8
			var x := shore + fr.randf_range(35.0, 120.0)
			if north_surf(x, z) > World1453.SEA_Y - 1.5 or not _free(x, z, 30.0) or z < World1453.asia_z(x) + 40.0:
				continue
			var ok := true
			for t: Transform3D in gx:
				# Kadırga 30 m, başı akıntıya (x boyunca): baş-kıç aralığı bir gemi boyu, yan yana en az 34 m (eskiden 16 m: iç içe)
				var dx := absf(t.origin.x - x)
				var dz := absf(t.origin.z - z)
				if (dx < 62.0 and dz < 14.0) or (dx < 36.0 and dz < 34.0):
					ok = false
			if ok:
				gx.append(Transform3D(Basis(Vector3.UP, deg_to_rad(90.0 + fr.randf_range(-12.0, 12.0))), Vector3(x, World1453.SEA_Y, z)))
		if not gx.is_empty():
			var fm := Scenery.scatter(self, Landmarks1453.ship_mesh("galley_ott"), gx, [], Landmarks1453.ship_material())
			fm.name = "Diplokionion"
			fm.visibility_range_end = 1600.0


## Asya yakası: kıyıdan içeri yükselen tepeler, Üsküdar sırtı
static func asia_h(x: float, z: float) -> float:
	var d := World1453.asia_z(x) - z                 # kıyıdan içeri (+)
	var h := 3.0 + 48.0 * smoothstep(20.0, 700.0, d) * (0.7 + 0.3 * sin(x * 0.005 + 1.1))
	var u: Vector3 = World1453.LANDMARKS["uskudar"]
	h += 10.0 * exp(-(pow((x - u.x) / 160.0, 2.0) + pow((z - u.z) / 120.0, 2.0)))
	return lerpf(-4.0, h, smoothstep(-6.0, 14.0, d))


## Bozdoğan Kemeri'nin tepesi: iki tepe arasındaki en yüksek zeminin üstünde (uzak siluet de bunu kullanır)
static func aqueduct_top() -> float:
	var a: Vector3 = World1453.LANDMARKS["aqueduct_a"]
	var b: Vector3 = World1453.LANDMARKS["aqueduct_b"]
	var gmax := -INF
	var gmin := INF
	for k in 9:
		var gp := a.lerp(b, k / 8.0)
		gmax = maxf(gmax, east_surf(gp.x, gp.z))
		gmin = minf(gmin, east_surf(gp.x, gp.z))
	return gmax + 6.0 + maxf(0.0, 14.0 - (gmax - gmin))


## Uçarak varılan anıtlar (Props ilkelleri: uçuşta katı olur): Havariyun Kilisesi, Bozdoğan Kemeri, Kız Kulesi, Üsküdar
func _monuments() -> void:
	var wall := Color("c89478")
	var lead := Color("7a8594")
	var md := Dressing.new(394)
	md.chunk = 4000.0
	# Havariyun: haç planlı, beş kubbeli (eskiden iki kutu + beş silindir ve top). Haç kolları kiremit beşik çatılı, iki sıra
	# kemerli pencere ve tuğla hatıllı; beş kubbe pencereli kasnaklı (Landmarks1453._dome), doğu kolunun ucunda apsis,
	# batı kolunun önünde narteks; orta kubbede altın haç
	var ap: Vector3 = World1453.LANDMARKS["apostles"]
	if _free(ap.x, ap.z, 30.0):
		var g := east_surf(ap.x, ap.z) - 0.5
		md.at(Vector3(ap.x, g, ap.z))
		for arm: Vector3 in [Vector3(46, 14, 14), Vector3(14, 14, 46)]:
			md.box(arm, Vector3(0, 7, 0), wall)
			for bh: float in [4.6, 9.6]:
				md.box(arm + Vector3(0.15, -arm.y + 0.4, 0.15), Vector3(0, bh, 0), Landmarks1453.LIGHT)
		md.prism(Vector3(14.6, 4.0, 46.6), Vector3(0, 16.0, 0), Landmarks1453.TILE)
		md.prism(Vector3(14.6, 4.0, 46.6), Vector3(0, 16.0, 0), Landmarks1453.TILE.darkened(0.06), Vector3(0, 90, 0))
		for o: Vector3 in [Vector3.ZERO, Vector3(16, 0, 0), Vector3(-16, 0, 0), Vector3(0, 0, 16), Vector3(0, 0, -16)]:
			var r := 6.0 if o == Vector3.ZERO else 4.8
			Landmarks1453._dome(md, o + Vector3(0, 15.0, 0), r, 4.0, 0.62, o == Vector3.ZERO)
		# Kemerli pencereler: her kolun iki yanında ve ucunda
		for ax in 4:
			var dir := Basis(Vector3.UP, ax * PI * 0.5)
			for k in 3:
				for row: float in [3.4, 8.6]:
					var wp := dir * Vector3(-4.2 + k * 4.2, row, 23.05)
					md.box((dir * Vector3(1.4, 2.6, 0.2)).abs(), wp, DARK_ARCH)
				var sp := dir * Vector3(7.05, 8.6, 11.0 + k * 4.0)
				md.box((dir * Vector3(0.2, 2.6, 1.4)).abs(), sp, DARK_ARCH)
				md.box((dir * Vector3(0.2, 2.6, 1.4)).abs(), dir * Vector3(-7.05, 8.6, 11.0 + k * 4.0), DARK_ARCH)
		Landmarks1453._apse(md, Vector3(23.0, 0, 0), 5.0, 11.0, wall.darkened(0.05))
		md.box(Vector3(6.0, 9.0, 22.0), Vector3(-26.0, 4.5, 0), wall.lightened(0.05))
		md.prism(Vector3(6.4, 2.2, 22.4), Vector3(-26.0, 10.1, 0), Landmarks1453.TILE)
		md.at(Vector3.ZERO)
	# Bozdoğan Kemeri: iki katlı kemer dizisi (eskiden kutu ayaklar ve iki düz kuşak). Her gözde iki ayak arasında yarım
	# daire kemer (kemer taşları), üstünde dolgu; alt kat yüksek, üst kat basık; tepede su kanalı ve kapak taşları.
	var a: Vector3 = World1453.LANDMARKS["aqueduct_a"]
	var b: Vector3 = World1453.LANDMARKS["aqueduct_b"]
	var n := int(a.distance_to(b) / 9.0)
	var yaw := rad_to_deg(atan2(b.x - a.x, b.z - a.z))
	var bas := Basis(Vector3.UP, deg_to_rad(yaw))
	var ac := Color("b89a78")
	# Kemerin tepesi iki tepe arasındaki en yüksek zeminin 20 m üstü (eskiden mutlak 20 m: zemin 18–22 m, kemer toprağa
	# gömülüydü); kat hizaları da buna göre
	var top := aqueduct_top()
	var belt := top - 9.0
	var span := a.distance_to(b) / n
	for k in n + 1:
		var p := a.lerp(b, float(k) / n)
		if not _free(p.x, p.z, 6.0):
			continue
		var g := east_surf(p.x, p.z)
		md.box(Vector3(3.2, top - g + 2.0, 3.0), Vector3(p.x, (top + g) * 0.5 - 1.0, p.z), ac, Vector3(0, yaw, 0))
		if k == n:
			continue
		var q := a.lerp(b, (k + 0.5) / n)
		if not _free(q.x, q.z, 6.0):
			continue
		var gq := east_surf(q.x, q.z)
		var rr := (span - 3.0) * 0.5
		# Alt kat kemeri (üzengisi zeminin 0,55'inde), üst kat kemeri (11 m'den), aralarında dolgu ve kuşak
		for lv: Vector2 in [Vector2(lerpf(gq, belt, 0.55), belt), Vector2(belt + 4.2, top - 0.8)]:
			var spring := lv.x
			for v in 7:
				var aa := PI * (v + 0.5) / 7.0
				var vp := Vector3(q.x, spring + sin(aa) * rr, q.z) + bas * Vector3(0, 0, cos(aa) * rr)
				md.box(Vector3(3.0, 0.9, 1.1), vp, ac.darkened(0.06), Vector3(rad_to_deg(aa) - 90.0, yaw, 0))
			var fill_lo := spring + rr * 0.75
			if lv.y > fill_lo:
				md.box(Vector3(2.9, lv.y - fill_lo, span - 3.0), Vector3(q.x, (lv.y + fill_lo) * 0.5, q.z), ac.darkened(0.03), Vector3(0, yaw, 0))
	var mid := (a + b) * 0.5
	for lvl: float in [belt, top - 0.5]:
		md.box(Vector3(3.4, 1.0 if lvl < top - 2.0 else 1.6, a.distance_to(b) + 3.0), Vector3(mid.x, lvl, mid.z), Color("a88a68"), Vector3(0, yaw, 0))
	md.box(Vector3(3.6, 0.4, a.distance_to(b) + 3.2), Vector3(mid.x, top + 0.5, mid.z), Color("c8b090"), Vector3(0, yaw, 0))
	for sx: float in [-1.0, 1.0]:
		md.box(Vector3(0.5, 0.8, a.distance_to(b) + 3.0), Vector3(mid.x, top + 0.9, mid.z) + bas * Vector3(sx * 1.4, 0, 0), Color("b8a080"), Vector3(0, yaw, 0))
	md.build(self)
	# Kız Kulesi (Damalis): adacık, Bizans burcu (Komnenos dönemi kare kule, mazgallı; kubbeli köşk Osmanlı'dır)
	var dm: Vector3 = World1453.LANDMARKS["damalis"]
	Props.ball(self, 9.0, dm + Vector3(0, -3.0, 0), Color("8a8270"), Vector3(1.3, 0.6, 1.0), 10)
	Props.box(self, Vector3(12, 3, 9), dm + Vector3(0, 0.5, 0), STONE.darkened(0.1))
	Props.box(self, Vector3(5, 16, 5), dm + Vector3(0, 9.0, 0), STONE)
	Props.box(self, Vector3(5.8, 0.8, 5.8), dm + Vector3(0, 17.2, 0), STONE.darkened(0.12))
	for q in 4:
		Props.box(self, Vector3(1.3, 1.3, 1.3), dm + Vector3((q % 2 - 0.5) * 4.4, 18.2, (q / 2 - 0.5) * 4.4), STONE.darkened(0.08))
	# Üsküdar: sırtta evler ve kubbeli kilise
	var u: Vector3 = World1453.LANDMARKS["uskudar"]
	var hl: Array = []
	for i in 160:
		var x := u.x + rng.randf_range(-170.0, 170.0)
		var z := u.z + rng.randf_range(-120.0, 110.0)
		var hyaw := rng.randf_range(-PI, PI)
		var v := rng.randi() % CityHouses.VARIANTS.size()
		if z > World1453.asia_z(x) - 10.0 or Vector2(x - u.x, z - u.z).length() < 16.0:
			continue
		hl.append({"c": Vector2(x, z), "yaw": hyaw, "v": v, "away": Vector2(cos(hyaw), -sin(hyaw))})
	var und := Dressing.new(392)
	CityHouses.build(self, hl, func(px: float, pz: float) -> float:
		return LowPoly.surface_y(px, pz, -3000.0, 1800.0, -3700.0, -2050.0, 60, 40, asia_h), _free, und)
	_night.append(und.build(self))
	# Üsküdar 1453'te Osmanlı köyü: tek küçük mescit (kare taş gövde, kurşun kubbe, kısa minare)
	var ug := asia_surf(u.x, u.z)
	var mw := Color("cbbb9e")
	Props.box(self, Vector3(12, 8, 12), Vector3(u.x, ug + 3.0, u.z), mw)
	Props.cyl(self, 4.4, 1.4, Vector3(u.x, ug + 7.7, u.z), mw.darkened(0.05), Vector3.ZERO, 8)
	Props.ball(self, 4.8, Vector3(u.x, ug + 8.4, u.z), lead, Vector3(1, 0.62, 1), 12)
	var mn := Vector3(u.x + 7.4, ug, u.z - 4.6)
	Props.cyl(self, 0.9, 13.0, mn + Vector3(0, 5.5, 0), mw.lightened(0.05), Vector3.ZERO, 8)
	Props.cyl(self, 1.35, 0.5, mn + Vector3(0, 10.4, 0), mw.darkened(0.1), Vector3.ZERO, 8)
	Props.cyl(self, 1.0, 3.2, mn + Vector3(0, 13.6, 0), lead, Vector3.ZERO, 8, 0.02)
	# Khalkedon (Kadıköy): Üsküdar'ın güneyinde, Marmara'ya bakan kıyıda bir köy daha (Asya yakası ufukta bitmesin)
	var kr := RandomNumberGenerator.new()
	kr.seed = 4531
	var kc := Vector2(380.0, -2300.0)
	# Yalnız uzak katman (CityHouses'un sade kutuları, tek çoklu ağ): köy hep 1 km'den uzakta görülür; tam katmanlar
	# hücre ve örnek başına ayrı düğümdü (~60 çizim)
	var kx: Array = []
	var kcol: Array = []
	var knd := Dressing.new(393)
	knd.chunk = 4000.0
	for i in 130:
		var x := kc.x + kr.randf_range(-190.0, 190.0)
		var z := kc.y + kr.randf_range(-110.0, 110.0)
		var hyaw := kr.randf_range(-PI, PI)
		var v := kr.randi() % CityHouses.VARIANTS.size()
		if z > World1453.asia_z(x) - 14.0 or not _free(x, z, 10.0):
			continue
		var hs := CityHouses.size(v)
		var st := LowPoly.seat(x, z, hs.x * 0.4, hs.z * 0.4, func(px: float, pz: float) -> float: return asia_surf(px, pz))
		var fy := st.x + 0.35 + st.y - 0.12
		kx.append(Transform3D(Basis(Vector3.UP, hyaw) * Basis.from_scale(hs), Vector3(x, fy, z)))
		kcol.append(CityHouses.FAR_COLS[v % CityHouses.FAR_COLS.size()])
		if i % 4 == 0:
			knd.glow(Vector3(0.5, 0.7, 0.5), Vector3(x, fy + 2.3, z), Color("ffc870"))
	if not kx.is_empty():
		Scenery.scatter(self, CityHouses.far_mesh(), kx, kcol, CityHouses._far_material()).name = "Khalkedon"
	_night.append(knd.build(self))
	var kcy: Array = []
	for i in 70:
		var x := kc.x + kr.randf_range(-230.0, 230.0)
		var z := kc.y + kr.randf_range(-150.0, 120.0)
		if z > World1453.asia_z(x) - 8.0:
			continue
		var sc := kr.randf_range(0.9, 1.4)
		kcy.append(Scenery._t(Vector3(x, asia_surf(x, z) - 0.2, z), Vector3.ZERO, Vector3(sc, sc * 1.2, sc)))
	Scenery.scatter(self, Scenery.cypress_mesh(), kcy)


# ---------------------------------------------------------------- uzak siluet ve suda hayat

var _skyline: MeshInstance3D
var _sync_t := 0.0


func _process(delta: float) -> void:
	_sync_t -= delta
	if _sync_t > 0.0 or _skyline == null:
		return
	_sync_t = 0.5
	_harbor_haze()
	Landmarks1453.skyline_sync(get_world_3d().environment if get_world_3d() else null)
	# Yıkık şehir sahnesi (26, 31o: FallenCity) kendi ufkunu ve Ayasofya'sını kurar: siluet ikinci bir Ayasofya olmasın
	var sc := get_tree().current_scene
	var fallen := false
	if sc:
		for c in sc.get_children():
			if c is FallenCity and (c as Node3D).visible:
				fallen = true
	_skyline.visible = not fallen


## Liman bölgelerinde gündüz pus sınırı (Look'un "fog_cap"ı: geniş manzaralar için): Haliç'in karşı kıyısı, Ayasofya ve
## şehrin yamacı süt beyazı bir perdenin ardında kalmasın. Gece (koyu pus) sınır kalkar.
const HARBOR := ["galata", "horn_chain", "springs", "slipway", "horn_wall_o", "petrion", "horn_bridge", "eyup"]
const HARBOR_FOG := 0.0011
var _we: WorldEnvironment


func _harbor_haze() -> void:
	if not region_name in HARBOR:
		return
	if _we == null or not is_instance_valid(_we):
		var sc := get_tree().current_scene
		var found := sc.find_children("*", "WorldEnvironment", true, false) if sc else []
		if found.is_empty():
			return
		_we = found[0]
	var e := _we.environment
	if e == null:
		return
	var day := e.fog_light_color.get_luminance() >= 0.25
	if day and not _we.has_meta("fog_cap"):
		_we.set_meta("fog_cap", HARBOR_FOG)
		_we.set_meta("fog_cap_horn", true)
		Look.refresh(_we)
	elif not day and _we.has_meta("fog_cap_horn"):
		_we.remove_meta("fog_cap")
		_we.remove_meta("fog_cap_horn")
		Look.refresh(_we)


## Su hayatı: Haliç'te kayıklar ve yelkenli balıkçı tekneleri, Boğaz ağzında iki Osmanlı devriye kadırgası, gündüz
## martı sürüleri. Hepsi gölgelendiricide devinir (elips rotası, sallanma; işlemcide kare işi yok), uzakta çizilmez.
## Deniz savaşı sayfaları (29, 29o, 38o) kendi gemilerini kurar: orada yok. Rotalar bölümün alanından 80 m uzak.
const BOAT_SHADER := """
shader_type spatial;
render_mode diffuse_toon, specular_disabled, cull_back;
void vertex() {
	vec4 cd = INSTANCE_CUSTOM;
	float a = cd.w + cd.z * TIME;
	vec3 tg = vec3(-sin(a) * cd.x, 0.0, cos(a) * cd.y) * sign(cd.z);
	float yaw = atan(tg.x, tg.z);
	vec3 v = VERTEX;
	v.y += v.x * sin(TIME * 1.1 + cd.w * 3.0) * 0.05 + sin(TIME * 1.3 + cd.w * 5.0) * 0.12;
	float c = cos(yaw);
	float s = sin(yaw);
	VERTEX = vec3(c * v.x + s * v.z, v.y, -s * v.x + c * v.z) + vec3(cos(a) * cd.x, 0.0, sin(a) * cd.y);
	NORMAL = vec3(c * NORMAL.x + s * NORMAL.z, NORMAL.y, -s * NORMAL.x + c * NORMAL.z);
}
void fragment() {
	ALBEDO = COLOR.rgb;
}
"""
static var _boat_mat: ShaderMaterial


func _water_life() -> void:
	var ch := CityLife.chapter_of(self)
	if ch in ["29", "29o", "38o"]:
		return
	var root := Node3D.new()
	root.name = "WaterLife"
	root.set_meta("no_walk", true)
	root.set_meta("soft", true)
	add_child(root)
	if _boat_mat == null:
		var sh := Shader.new()
		sh.code = BOAT_SHADER
		_boat_mat = ShaderMaterial.new()
		_boat_mat.shader = sh
	# [tür, merkez (x, z), yön (derece), yarı eksenler (enine, boyuna), hız m/sn]
	# Haliç'in rotaları zincirin (z −1480) ve zincirin ardındaki gemilerin (z −1460…−1316) içinde değil, onların gerisinde
	var routes := [
		["row", Vector2(-805.0, -1200.0), 0.0, Vector2(20.0, 90.0), 1.4],
		["sail", Vector2(-812.0, -990.0), 0.0, Vector2(28.0, 130.0), 2.2],
		["row", Vector2(-800.0, -760.0), 0.0, Vector2(18.0, 90.0), 1.3],
		["sail", Vector2(-810.0, -560.0), 0.0, Vector2(26.0, 120.0), 2.0],
		["row", Vector2(-795.0, -330.0), 0.0, Vector2(16.0, 90.0), 1.2],
		["sail", Vector2(-120.0, -1500.0), 40.0, Vector2(40.0, 170.0), 2.4],
		["row", Vector2(-240.0, -1440.0), 40.0, Vector2(18.0, 70.0), 1.3],
		["galley", Vector2(-600.0, -1880.0), 90.0, Vector2(45.0, 240.0), 2.6],
		["galley", Vector2(-250.0, -1950.0), 75.0, Vector2(40.0, 240.0), 2.4],
	]
	var wr := RandomNumberGenerator.new()
	wr.seed = 1453529
	var lists := {"row": [], "sail": [], "galley": []}
	var cnt := 0
	for r: Array in routes:
		var kind: String = r[0]
		if night and kind != "row":
			continue          # gece yalnız kayıklar (balıkçılar, nöbetçi kayığı)
		var c: Vector2 = r[1]
		var b := Basis(Vector3.UP, deg_to_rad(r[2]))
		var ax: Vector2 = r[3]
		var ok := true
		for q in 12:
			var a := TAU * q / 12.0
			var p := Vector3(c.x, 0, c.y) + b * Vector3(cos(a) * ax.x, 0, sin(a) * ax.y)
			if not World1453.is_water(p.x, p.z) or not _free(p.x, p.z, 80.0) or World1453.surface_h(p.x, p.z) > World1453.SEA_Y - 1.0:
				ok = false
				break
		if not ok:
			continue
		var per := TAU * sqrt((ax.x * ax.x + ax.y * ax.y) * 0.5)
		var w := TAU * float(r[4]) / per * (1.0 if cnt % 2 == 0 else -1.0)
		lists[kind].append([Transform3D(b, Vector3(c.x, World1453.SEA_Y, c.y)), Color(ax.x, ax.y, w, wr.randf() * TAU)])
		cnt += 1
	for kind: String in lists:
		var items: Array = lists[kind]
		if items.is_empty():
			continue
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.use_custom_data = true
		mm.use_colors = true          # gl_compatibility: örnek rengi yoksa COLOR siyah gelir
		mm.mesh = Landmarks1453.ship_mesh({"row": "row_w", "sail": "fisher_w", "galley": "galley_ott_w"}[kind])
		mm.instance_count = items.size()
		for i in items.size():
			mm.set_instance_transform(i, items[i][0])
			mm.set_instance_custom_data(i, items[i][1])
			mm.set_instance_color(i, Color.WHITE)
		var mi := MultiMeshInstance3D.new()
		mi.name = "Boats_" + kind
		mi.set_meta("soft", true)             # uçuşta katı olmasın (örneklerin yeri gölgelendiricide)
		mi.multimesh = mm
		mi.material_override = _boat_mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var lo := Vector3(INF, -2.0, INF)
		var hi := Vector3(-INF, 22.0, -INF)
		for it: Array in items:
			var o: Vector3 = (it[0] as Transform3D).origin
			var rr: float = maxf((it[1] as Color).r, (it[1] as Color).g) + 15.0
			lo = Vector3(minf(lo.x, o.x - rr), lo.y, minf(lo.z, o.z - rr))
			hi = Vector3(maxf(hi.x, o.x + rr), hi.y, maxf(hi.z, o.z + rr))
		mi.custom_aabb = AABB(lo, hi - lo)
		mi.visibility_range_end = 1400.0
		root.add_child(mi)
	if not night:
		var tw: Vector3 = World1453.LANDMARKS["galata_tower"]
		for g: Array in [[Vector3(-800.0, World1453.SEA_Y, -1460.0), 12, 60.0, 24.0], [Vector3(-320.0, World1453.SEA_Y, -1380.0), 9, 45.0, 20.0],
				[Vector3(tw.x, World1453.galata_top(tw) - 30.0, tw.z), 7, 22.0, 36.0], [Vector3(-810.0, World1453.SEA_Y, -820.0), 8, 50.0, 22.0]]:
			Gulls.flock_mm(root, g[0], g[1], g[2], g[3], 40 + root.get_child_count())
