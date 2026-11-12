class_name IstKbSaray
extends RefCounted
## Kuzeybati: Tekfur Sarayı (Porphyrogennetos), Anemas zindanları ve kuleleri, Kynegion (harap arena).
## Model çerçevesi: cephe +z'ye bakar, sur arkada (-z). Yerel çerçeve pusula hizalıdır (yon_derece pivot'ta uygulanır).

const GENIS := Color("e6d4ac")


static func catalog() -> Array:
	return [
		{"id": "tekfur", "ad": "Tekfur Sarayı (Porphyrogennetos)", "dogu_m": -3560.0, "kuzey_m": 3010.0,
			"gercek_olcu": Vector3(20.0, 17.0, 11.0), "yon_derece": 20.0, "durum": "saglam", "tur": "anit",
			"bakis": Vector3(0, 25.0, 0), "bakis_r": 36.0, "gorev": true},
		{"id": "anemas", "ad": "Anemas Zindanları ve Kuleleri", "dogu_m": -3300.0, "kuzey_m": 3150.0,
			"gercek_olcu": Vector3(34.0, 24.0, 13.0), "yon_derece": 20.0, "durum": "saglam", "tur": "sur",
			"bakis": Vector3(0, 32.0, 0), "bakis_r": 36.0, "gorev": true},
		{"id": "kynegion", "ad": "Kynegion (harap arena)", "dogu_m": -3200.0, "kuzey_m": 3060.0,
			"gercek_olcu": Vector3(34.0, 6.0, 26.0), "yon_derece": 0.0, "durum": "harap", "tur": "anit",
			"bakis": Vector3(0, 12.0, 0), "bakis_r": 28.0, "gorev": false},
	]


# ----------------------------------------------------------------------------------------------------------------
## TEKFUR SARAYI
## Kaynaklar: Wikipedia "Palace of the Porphyrogenitus", Byzantine Legacy: üç katlı dikdörtgen yapı, kuzeye (avluya)
## açık cephe, kırmızı tuğla + beyaz mermerle geometrik desen, mermer pencere çerçeveleri ve avlu girişinde mermer
## sütunlar. Boyut kestirim (kaynaklar 10×15 iç ölçü ve 17–25 m yükseklik der): 20 × 11 × 17 m.

static func build_tekfur(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var c := IstKbCtx.create(host, "Tekfur", k, lod, 20.0, 61)
	var T := Color("e8d8b4")
	var W := Color("d8c8a4")
	# sur kesiti (arkada) ve uç kuleleri
	c.block(0, -7.5, 56, 4, 13, 0, W, "ashlar_far")
	c.block(-26, -6.5, 7, 7, 17, 0, W, "ashlar")
	c.block(26, -6.5, 7, 7, 17, 0, W, "ashlar")
	c.gable(-26, -6.5, 7, 7, 17, 2.0, true)
	c.gable(26, -6.5, 7, 7, 17, 2.0, true)
	# saray gövdesi: üç kat, "tekfur" deseni (kırmızı-beyaz geometrik)
	c.block(0, 0, 20, 11, 17, 0, T, "tekfur")
	c.gable(0, 0, 20, 11, 17, 2.2, false)
	# doğu merdiven kulesi (sur yürüme yolu ile saray çatısı arasında geçit)
	c.block(12.5, -3.5, 5, 4, 15, 0, W, "ashlar")
	# sur yürüme yolu siperliği (kuzey kenarı) ve uç kule tepeleri
	if lod < 2:
		c.parapet(-29.5, -9.5, 29.5, -9.5, 13.0 * c.k)
		c.parapet(-23.0, -5.5, 10.0, -5.5, 13.0 * c.k)
		c.parapet(19.0, -5.5, 24.5, -5.5, 13.0 * c.k)
	# cephe: zemin katta beş kemerli revak (mermer sütunlu), iki kat cephe bantları, pencereler, geometrik rozetler
	if lod == 0:
		var offs := [-8.0, -4.0, 0.0, 4.0, 8.0]
		c.windows_on(0, 0, 0, 5.5, offs, 1.7 / c.k, 2.0, 3.2, true, false)
		c.windows_on(0, 0, 0, 5.5, offs, 8.4, 0.9, 1.9)
		c.windows_on(0, 0, 0, 5.5, [-8.5, -5.7, -2.9, 0.0, 2.9, 5.7, 8.5], 14.2, 0.7, 1.4)
		c.windows_on(0, 0, 90, 10.0, [-3.0, 0.0, 3.0], 8.4, 0.8, 1.7)
		c.windows_on(0, 0, 270, 10.0, [-3.0, 0.0, 3.0], 8.4, 0.8, 1.7)
		c.windows_on(0, 0, 90, 10.0, [-3.0, 0.0, 3.0], 14.2, 0.7, 1.4)
		c.windows_on(0, 0, 270, 10.0, [-3.0, 0.0, 3.0], 14.2, 0.7, 1.4)
		c.band(0, 0, 0, 5.5, 20.4, 5.5, 0.35, IstKbCtx.MARBLE)
		c.band(0, 0, 0, 5.5, 20.4, 11.0, 0.35, IstKbCtx.MARBLE)
		c.band(0, 0, 0, 5.5, 20.4, 16.7, 0.4, IstKbCtx.MARBLE)
		# mermer sütunlar (revak): kemer aralarında, cephenin yarı içine gömülü
		for xx in [-10.0, -6.0, -2.0, 2.0, 6.0, 10.0]:
			var col := Props.cyl(c.root, 0.2, 3.2, Vector3(xx * k, 1.6, 5.5 * k + 0.12), IstKbCtx.MARBLE, Vector3.ZERO, 8)
			Props.box(c.root, Vector3(0.5, 0.15, 0.5), Vector3(xx * k, 3.3, 5.5 * k + 0.12), IstKbCtx.STONE)
			Props.box(c.root, Vector3(0.5, 0.15, 0.5), Vector3(xx * k, 0.07, 5.5 * k + 0.12), IstKbCtx.STONE)
		# geometrik rozet ve eşkenar dörtgenler (tuğla): pencereler arasında
		for fl in [8.4, 14.2]:
			for i in 9:
				var xx2 := (-9.0 + i * 2.25)
				var rz := Props.box(c.root, Vector3(0.5, 0.5, 0.05), Vector3(xx2 * k, fl * k, 5.5 * k + 0.02), IstKbCtx.BRICK, Vector3(0, 0, 45))
				rz.material_override = Props.mat(Color("b8523a"))
		c.door_on(12.5, -3.5, 0, 2.0, 0.0, 15.0)
		c.cypress(-14.0, 11.0, 9.0)
		c.cypress(15.0, 12.0, 9.5)
		c.olive(-10.0, 15.0, 0.0, 1.0)
		c.ground_patch(0, 13.0, 36.0, 16.0, Color("b8a888"), "flagstone", 0.06)
		# ön avlu kuyusu ve çamaşır/çuval ayrıntısı
		var well := Props.cyl(c.root, 0.9, 0.9, Vector3(-8.0 * k, 0.45, 13.0 * k), IstKbCtx.STONE_D, Vector3.ZERO, 10)
		Props.make_solid(well)
		Props.cyl(c.root, 0.7, 0.04, Vector3(-8.0 * k, 0.92, 13.0 * k), Color("2a3a46"), Vector3.ZERO, 10)
	# tırmanış: yerden sur yürüme yoluna dış merdiven (batıdan), sonra kuleye ve saray çatısına sandık basamakları
	var hw := 13.0 * k
	c.stair(16.0, -5.5, Vector2(0, -1), hw, 1.6, IstKbCtx.STONE_D, 0.34, 0.0)
	var n1 := maxi(1, int(ceil(2.0 * k / 0.6)))
	c.crate_steps(12.5, -5.5, Vector2(0, 1), n1, 2.0 * k / n1, hw)
	var n2 := maxi(1, int(ceil(2.0 * k / 0.6)))
	c.crate_steps(10.0, -4.5, Vector2(-1, 0), n2, 2.0 * k / n2, 15.0 * k)


# ----------------------------------------------------------------------------------------------------------------
## ANEMAS ZİNDANLARI (Blakhernai surunun kuzey ucu): sekizgen yüksek kule (Isaac Angelos tipi), kareli kule ve
## yamaçta tonozlu zindan taraçası (yedi kemerli, demir parmaklıklı küçük açıklıklar). Ölçüler kestirim.

static func build_anemas(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var c := IstKbCtx.create(host, "Anemas", k, lod, 20.0, 71)
	var W := Color("d4c3a0")
	c.block(0, 0, 34, 13, 5.2, 0, W, "ashlar")                    # tonozlu zindan taraçası
	c.tower(-12.0, -3.0, 5.2, 24.0, 0.0, W, "ashlar", 8)           # sekizgen ana kule
	c.block(11.5, -2.0, 7, 7, 15.0, 0, W, "ashlar")                 # kareli kule
	c.block(0, -8.0, 34, 3, 9.0, 0, W, "ashlar_far")                # arkadaki sur perdesi
	if lod < 2:
		# kule tepeleri: siperlik
		var ty := 24.0 * c.k
		var r := 5.0
		for i in 8:
			var a0 := TAU * i / 8.0 + PI / 8.0
			var a1 := TAU * (i + 1) / 8.0 + PI / 8.0
			c.parapet(-12.0 + cos(a0) * r, -3.0 + sin(a0) * r, -12.0 + cos(a1) * r, -3.0 + sin(a1) * r, ty)
		var sy := 15.0 * c.k
		c.parapet(8.0, -5.5, 15.0, -5.5, sy)
		c.parapet(15.0, -5.5, 15.0, 1.5, sy)
		c.parapet(8.0, 1.5, 15.0, 1.5, sy)
		c.parapet(8.0, -5.5, 8.0, -4.0, sy)
		var gh := 1.5 / c.k
		c.parapet(-16.5, 5.5, 2.25 - gh, 5.5, 5.2 * c.k)
		c.parapet(2.25 + gh, 5.5, 16.5, 5.5, 5.2 * c.k)
	if lod == 0:
		# zindan kemerleri: yedi koyu açıklık + demir parmaklık
		var offs := [-13.5, -9.0, -4.5, 0.0, 4.5, 9.0, 13.5]
		c.windows_on(0, 0, 0, 6.5, offs, 1.3 / c.k, 1.5, 1.9, true, false, true)
		c.windows_on(-12.0, -3.0, 0, 5.0, [0.0], 14.0, 0.8, 1.6)
		c.windows_on(-12.0, -3.0, 90, 5.0, [0.0], 18.0, 0.8, 1.6)
		c.windows_on(-12.0, -3.0, 270, 5.0, [0.0], 12.0, 0.8, 1.6)
		c.windows_on(11.5, -2.0, 0, 3.5, [-1.2, 1.2], 8.0, 0.7, 1.4)
		c.windows_on(11.5, -2.0, 90, 3.5, [-1.5, 1.5], 11.0, 0.7, 1.4)
		c.band(0, 0, 0, 6.5, 34, 5.0, 0.3)
		c.band(11.5, -2.0, 0, 3.5, 7, 9.0, 0.3)
		c.door_on(0, 0, 0, 6.5, 2.2, 5.2)
	c.cypress(-22.0, 6.0, 8.0)
	c.olive(20.0, 8.0, 0.0, 0.9)
	# tırmanış: batı uçtan taraça üstüne dış merdiven, taraçadan kareli kule tepesine ikinci merdiven (yan boyda)
	var th := 5.2 * k
	c.stair(2.25, 6.5, Vector2(0, -1), th, 1.6, IstKbCtx.STONE_D, 0.5, 0.0)
	var kh := (15.0 - 5.2) * k
	c.stair(8.0, -0.5, Vector2(1, 0), kh, 1.6, IstKbCtx.STONE_D, 0.33, th)


# ----------------------------------------------------------------------------------------------------------------
## KYNEGION (harap): Blakhernai yamacında yarısı yıkık eliptik taş arena; güney yarıda basamaklı oturma (kavea), kuzeyde
## yıkık dış duvar ve kemer kalıntıları, ortada kum zemin. Adı "av yeri" demektir; 1453'te taşı sökülmüş, ot bürümüş.
## Boyut kestirim: 34 × 26 m.

static func build_kynegion(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var c := IstKbCtx.create(host, "Kynegion", k, lod, 0.0, 81)
	var rx := 17.0 * k
	var rz := 13.0 * k
	var tiers := maxi(2, int(ceil(5.0 * k / 0.4)))
	var tier_h := 0.4
	var seg := 18
	# kum zemin
	var sand := Props.solid(c.root, Vector3(rx * 1.35, 0.1, rz * 1.35), Vector3(0, 0.05, 0), Color.WHITE)
	Props.set_pattern(sand, Color("cdb88a"), "flagstone")
	# güney yarı: kademeli oturma sıraları; her parça tam bitişik yamuk prizma (dışbükey), parçalar köşe paylaşır: aralık yok
	var ring_step := 0.12
	for t in tiers:
		var top := tier_h * (t + 1)
		var r_in := 0.45 + t * ring_step
		var r_out := 0.45 + (t + 1) * ring_step
		for i in seg:
			var a0 := PI * float(i) / seg
			var a1 := PI * float(i + 1) / seg
			var pts: Array = []
			for yy in [0.0, top]:
				pts.append(Vector3(cos(a0) * rx * r_in, yy, sin(a0) * rz * r_in))
				pts.append(Vector3(cos(a1) * rx * r_in, yy, sin(a1) * rz * r_in))
				pts.append(Vector3(cos(a1) * rx * r_out, yy, sin(a1) * rz * r_out))
				pts.append(Vector3(cos(a0) * rx * r_out, yy, sin(a0) * rz * r_out))
			_frustum(c.root, pts, Color("d4c4a2") if (t + i) % 5 else Color("c9b690"))
	# dış duvar kalıntısı: kuzey yarı alçak/yıkık, parça parça (kemer köklerinden kalan dikmeler)
	for i in 9:
		var a2 := PI + PI * (float(i) + 0.5) / 9.0
		var wx := cos(a2) * rx * 0.62 * 1.42
		var wz := sin(a2) * rz * 0.62 * 1.42 * 1.0
		var wh: float = [4.2, 3.0, 2.2, 3.6, 1.6, 2.8, 4.0, 2.0, 3.2][i] * maxf(k, 0.5)
		var tg := Vector3(-sin(a2) * rx, 0, cos(a2) * rz).normalized()
		var wb := Props.solid(c.root, Vector3(3.8, wh, 1.0 + maxf(k, 0.5)), Vector3(wx, wh * 0.5, wz), Color.WHITE, Vector3(0, rad_to_deg(atan2(tg.x, tg.z)), 0))
		Props.set_pattern(wb, Color("c4b290"), "rubble")
	# moloz, ot, birkaç sütun gövdesi
	var rmid := 0.45 + (tiers - 0.5) * ring_step
	c.add_climb(Vector3(0, 0.1, 0.8), Vector3(0, tier_h * tiers, rz * rmid), "basamak")
	c.add_perch(Vector3(0, tier_h * tiers + 0.05, rz * rmid))
	c.rubble(-14.0, -2.0, 14, 5.0, 0.1)
	c.rubble(13.0, -6.0, 10, 4.0, 0.1)
	c.olive(-8.0, -12.0, 0.0, 1.0)
	c.cypress(14.0, -14.0, 8.0)
	# ön sahne: kuzeyden iki basamaklı giriş boşluğu zaten açık (kuzey yarı alçak); oturma kademeleri doğal merdiven


static func _frustum(parent: Node3D, p: Array, col: Color) -> void:
	# p: 4 alt köşe (0..3), 4 üst köşe (4..7); dışbükey katı + görsel
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var faces := [[0, 2, 1], [0, 3, 2], [4, 5, 6], [4, 6, 7], [0, 1, 5], [0, 5, 4], [1, 2, 6], [1, 6, 5], [2, 3, 7], [2, 7, 6], [3, 0, 4], [3, 4, 7]]
	for f in faces:
		for q in f:
			st.add_vertex(p[q])
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = Props.mat(col, 0.0, false, "ashlar")
	parent.add_child(mi)
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var cv := ConvexPolygonShape3D.new()
	cv.points = PackedVector3Array(p)
	cs.shape = cv
	body.add_child(cs)
	mi.add_child(body)


# ----------------------------------------------------------------------------------------------------------------
static func _rise(k: float, rise: float, half_w: float) -> float:
	return minf(rise * k, (half_w * 0.5 * k + 0.35) * 0.5)


static func _nul(k: float, yon: float) -> IstKbCtx:
	var c := IstKbCtx.new()
	c.k = k
	c.yon = yon
	return c


static func _climbs(k: float, yon: float, steps: Array) -> Array:
	var c := _nul(k, yon)
	var out: Array = []
	for e in steps:
		var a: Vector3 = e[0]
		var b: Vector3 = e[1]
		out.append([c.to_local(Vector3(a.x * k, a.y, a.z * k)), c.to_local(Vector3(b.x * k, b.y, b.z * k)), e[2]])
	return out

# Tırmanış ve konma noktaları kurucudan toplanır (IstKbCtx.harvest): kurulumla birebir tutarlı.
static func perches_tekfur(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("tekfur", build_tekfur, k)[1]


static func climbs_tekfur(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("tekfur", build_tekfur, k)[0]


static func perches_anemas(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("anemas", build_anemas, k)[1]


static func climbs_anemas(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("anemas", build_anemas, k)[0]


static func perches_kynegion(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("kynegion", build_kynegion, k)[1]


static func climbs_kynegion(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("kynegion", build_kynegion, k)[0]


