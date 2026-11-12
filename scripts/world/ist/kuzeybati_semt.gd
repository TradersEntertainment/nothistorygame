class_name IstKbSemt
extends RefCounted
## Kuzeybati: Aetios açık sarnıcı (bostan), Kaligaria ayakkabıcı sokağı, Ayvansaray iskelesi.

static func catalog() -> Array:
	return [
		{"id": "aetios", "ad": "Aetios Açık Sarnıcı (bostan)", "dogu_m": -3050.0, "kuzey_m": 2650.0,
			"gercek_olcu": Vector3(244.0, 12.0, 85.0), "yon_derece": 100.0, "durum": "bostan", "tur": "ayrinti",
			"bakis": Vector3(0, 22.0, 0), "bakis_r": 60.0, "gorev": false},
		{"id": "kaligaria", "ad": "Kaligaria (ayakkabıcı sokağı)", "dogu_m": -3300.0, "kuzey_m": 2740.0,
			"gercek_olcu": Vector3(34.0, 8.0, 20.0), "yon_derece": 60.0, "durum": "saglam", "tur": "ev",
			"bakis": Vector3(0, 14.0, 0), "bakis_r": 24.0, "gorev": false},
		{"id": "ayvansaray_iskele", "ad": "Ayvansaray (Blakhernai) İskelesi", "dogu_m": -3050.0, "kuzey_m": 3300.0,
			"gercek_olcu": Vector3(16.0, 3.0, 26.0), "yon_derece": 50.0, "durum": "saglam", "tur": "liman",
			"bakis": Vector3(0, 12.0, 0), "bakis_r": 22.0, "gorev": false},
	]


# ----------------------------------------------------------------------------------------------------------------
## AETİOS AÇIK SARNICI (Çukurbostan). 244 × 85 m (kaynak: yaygın ölçü; derinlik kestirim ≈ 9 m). 1453'te kuru,
## içi sebze bostanı ve bağ; çevre duvarı yer yer çökmüş. Taban y = 0; duvar tepesi ve çevre set y = derinlik.

static func build_aetios(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var c := IstKbCtx.create(host, "Aetios", k, lod, 100.0, 91)
	var L := 244.0
	var Wd := 85.0
	var dp := 9.0                      # derinlik (gerçek m)
	var t := 4.0                       # duvar kalınlığı
	var W := Color("d4c3a0")
	# çevre duvarı: dört katı blok (içeriden bakınca istinat duvarı), tepesi yürünür set
	c.block(0, -(Wd + t) * 0.5, L + t * 2.0, t, dp, 0, W, "ashlar_far")
	c.block(0, (Wd + t) * 0.5, L + t * 2.0, t, dp, 0, W, "ashlar_far")
	c.block(-(L + t) * 0.5, 0, t, Wd, dp, 0, W, "ashlar_far")
	c.block((L + t) * 0.5, 0, t, Wd, dp, 0, W, "ashlar_far")
	# çökmüş köşe/yarık: kuzey duvarında basamaklı yıkık kesim (doğal iniş yolu): iki alçak blok ile örtülmez
	if lod < 2:
		c.parapet(-(L + t * 2.0) * 0.5, -(Wd + t * 2.0) * 0.5, (L + t * 2.0) * 0.5, -(Wd + t * 2.0) * 0.5, dp * c.k)
		c.parapet(-(L + t * 2.0) * 0.5, (Wd + t * 2.0) * 0.5, (L + t * 2.0) * 0.5, (Wd + t * 2.0) * 0.5, dp * c.k)
	# zemin: bostan toprağı
	c.ground_patch(0, 0, L, Wd, Color("7a6040"), "", 0.06)
	if lod == 0:
		var rng := c.rng
		var cab: Array = []
		var vine: Array = []
		var post: Array = []
		var bed: Array = []
		# sebze tarhaları: kuzey yarı, 3 m'de bir sıra, 1,2 m'de bir lahana/marul
		var rows := int(Wd * 0.35 / 3.0 / 1.0)
		for ri in rows:
			var zz := (-Wd * 0.5 + 4.0 + ri * 3.4) * c.k
			bed.append(Transform3D(Basis(), Vector3(-20.0 * c.k, 0.1, zz)))
			var n := int(150.0 * c.k / 1.2)
			for ci in n:
				var xx := (-60.0 + ci * 1.2 / c.k * 0.5) * c.k
				if absf(xx) > (L * 0.5 - 12.0) * c.k:
					continue
				cab.append(Transform3D(Basis().scaled(Vector3(1, 0.7, 1)), Vector3(xx, 0.22, zz)))
		# bağ sırası: güney yarı, kazık + kütük
		var vrows := int(Wd * 0.3 / 3.5)
		for ri in vrows:
			var zz2 := (8.0 + ri * 3.6) * c.k
			var n2 := int(110.0 * c.k / 2.0)
			for ci in n2:
				var xx2 := (-70.0 + ci * 2.0 / c.k * 0.6) * c.k
				if absf(xx2) > (L * 0.5 - 14.0) * c.k:
					continue
				post.append(Transform3D(Basis(), Vector3(xx2, 0.7, zz2)))
				vine.append(Transform3D(Basis().scaled(Vector3(1.3, 0.8, 1.3)), Vector3(xx2, 0.9, zz2)))
		var bed_len := 150.0 * c.k
		c.mm_box(c.root, Vector3(bed_len, 0.2, 0.9), Color("6a4c30"), bed.map(func(xf: Transform3D) -> Transform3D: return Transform3D(xf.basis, xf.origin + Vector3(bed_len * 0.5 - 6.0 * c.k, 0, 0))))
		c.mm_ball(c.root, 0.25, Color("78a050"), cab)
		c.mm_box(c.root, Vector3(0.06, 1.4, 0.06), IstKbCtx.WOOD, post)
		c.mm_ball(c.root, 0.4, Color("5f8a3e"), vine)
		# sulama arkı: ince koyu şerit (çarpışmasız)
		Props.box(c.root, Vector3(L * 0.8 * c.k, 0.02, 0.5), Vector3(0, 0.07, 2.0 * c.k), Color("3a5a68"))
		# bostancı kulübeleri (sabit insan ölçüsü: 3×3×2,4), kuyu, korkuluk
		for hx in [-40.0, 55.0]:
			var hp := Vector3(hx * c.k, 0, -4.0 * c.k)
			var hb := Props.solid(c.root, Vector3(3.0, 2.4, 3.0), hp + Vector3(0, 1.2, 0), Color.WHITE)
			Props.set_pattern(hb, Color("c8b088"), "plaster")
			var hr := Props.prism(c.root, Vector3(3.8, 1.0, 3.6), hp + Vector3(0, 2.9, 0), Color("b08a4a"))
			Props.box(c.root, Vector3(0.7, 1.6, 0.05), hp + Vector3(0.6, 0.8, 1.52), IstKbCtx.WOOD)
		var well := Props.cyl(c.root, 0.9, 0.9, Vector3(10.0 * c.k, 0.45, 2.0 * c.k), IstKbCtx.STONE_D, Vector3.ZERO, 10)
		Props.make_solid(well)
		Props.cyl(c.root, 0.7, 0.04, Vector3(10.0 * c.k, 0.92, 2.0 * c.k), Color("2a3a46"), Vector3.ZERO, 10)
		for sx in [-25.0, 30.0]:
			var sp := Vector3(sx * c.k, 0, 4.0 * c.k)
			Props.cyl(c.root, 0.04, 1.9, sp + Vector3(0, 0.95, 0), IstKbCtx.WOOD_D, Vector3.ZERO, 5)
			Props.box(c.root, Vector3(1.5, 0.06, 0.06), sp + Vector3(0, 1.5, 0), IstKbCtx.WOOD_D)
			Props.ball(c.root, 0.18, sp + Vector3(0, 1.95, 0), Color("d8b860"), Vector3.ONE, 6)
		for i in 12:
			c.olive(rng.randf_range(-L * 0.45, L * 0.45), rng.randf_range(-Wd * 0.4, Wd * 0.4), 0.0, rng.randf_range(0.8, 1.1))
		for i in 8:
			c.cypress(rng.randf_range(-L * 0.45, L * 0.45), rng.randf_range(-Wd * 0.45, Wd * 0.45), 8.0)
	# giriş: batı uçta içerideki merdiven; dışarıda toprak rampa; iç taban yürünür
	var hh := dp * c.k
	c.stair(-L * 0.5, 0.0, Vector2(-1, 0), hh, 2.0, IstKbCtx.STONE_D, 0.5, 0.0)
	# dış rampa (batı duvarı dışı): zemin y=0'dan duvar tepesine, eğim ≤ 25°
	var run := maxf(hh / tan(deg_to_rad(22.0)), 6.0)
	var a := Vector3((-L * 0.5 - t * 1.5) * c.k - run, 0.0, 14.0)
	var b := Vector3((-L * 0.5 - t * 1.0) * c.k + 0.0, hh, 14.0)
	if lod < 2:
		Props.ramp(c.root, a, b, 3.0, Color("8a7a5a"))


static func perches_aetios(k: float = 0.5) -> Array:
	var c := _nul(k, 100.0)
	return [c.to_local(Vector3(-122.0 * k, 9.0 * k + 0.1, -44.0 * k)), c.to_local(Vector3(122.0 * k, 9.0 * k + 0.1, 44.0 * k))]


static func climbs_aetios(k: float = 0.5) -> Array:
	var c := _nul(k, 100.0)
	var hh := 9.0 * k
	return [[c.to_local(Vector3(-122.0 * k - 8.0, 0.0, 0.0)), c.to_local(Vector3(-122.0 * k - 1.0, hh, 0.0)), "basamak"]]


# ----------------------------------------------------------------------------------------------------------------
## KALIGARİA — ayakkabıcılar çarşısı. Dar sokağın iki yanı, tezgâhlı dükkânlar, sundurma altında asılı ayakkabılar.
## Ev ölçüleri k'den bağımsız alt sınırlı (insan ölçüsü): taban 5,5×6,5 × max(k, 0,7); k < 0,7 iken tek kat (3,8),
## değilse iki kat (6,4). Sokak genişliği 4,5 m sabit. Kestirim.

static func build_kaligaria(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var c := IstKbCtx.create(host, "Kaligaria", k, lod, 60.0, 101)
	var fk := maxf(k, 0.7)
	var hw := 5.5 * fk
	var hd := 6.5 * fk
	var two := k >= 0.7
	var gh := 3.8
	var hh := 6.4 if two else 3.8
	var lane := 4.5
	var plasters := [Color("e8c890"), Color("d89a78"), Color("efe0c4"), Color("c8a0a0"), Color("b8c4c0"), Color("e0b070")]
	var n := 5
	# sokak: taş döşeme
	var street := Props.solid(c.root, Vector3(n * hw + 4.0, 0.08, lane + 0.6), Vector3(0, 0.04, 0), Color.WHITE)
	Props.set_pattern(street, Color("b0a48c"), "cobble")
	for row in [-1, 1]:
		var zc: float = row * (lane * 0.5 + hd * 0.5)
		for i in n:
			var xc := (i - (n - 1) * 0.5) * hw
			var col: Color = plasters[(i + (3 if row > 0 else 0)) % plasters.size()]
			var b := Props.solid(c.root, Vector3(hw, hh, hd), Vector3(xc, hh * 0.5, zc), Color.WHITE)
			Props.set_pattern(b, col, "plaster")
			# alçak, ince bir ahşap cumba bandı (üst kat) ve çatı
			var rr := Props.prism(c.root, Vector3(hd + 0.9, 1.4, hw + 0.4), Vector3(xc, hh + 0.7, zc), IstKbCtx.TILE_OLD, Vector3(0, 90, 0))
			rr.material_override = Props.mat(IstKbCtx.TILE, 0.0, false, "tiles" if lod < 2 else "")
			if lod < 2:
				# çatı çarpışması: düz tabla (eğimli çatı görsel; yürünür düz yüzey çatı altında)
				var cap := Props.solid(c.root, Vector3(hw - 0.2, 0.3, hd - 0.2), Vector3(xc, hh + 0.15, zc), Color("5a3a24"))
			if lod == 0:
				var fz: float = zc - row * hd * 0.5            # sokak cephesi
				var nrm := 0.0 if row < 0 else 180.0           # cephe normali: row<0 (kuzey sıra) güneye (+z) bakar
				# dükkân tezgâhı (sabit boy)
				var tz: float = fz - row * 0.45
				var cnt := Props.solid(c.root, Vector3(hw * 0.7, 0.95, 0.6), Vector3(xc - hw * 0.1, 0.475, tz - row * 0.05), Color.WHITE)
				Props.set_pattern(cnt, IstKbCtx.WOOD, "wood")
				# sundurma: 2,2 m yükseklikte, 1,3 m çıkıntılı katı tabla (alçak sundurma = tırmanış yolu)
				var aw_y: float = minf(2.3, hh - 0.4)
				var aw := Props.solid(c.root, Vector3(hw * 0.9, 0.14, 1.4), Vector3(xc, aw_y, fz - row * 0.7), Color.WHITE)
				Props.set_pattern(aw, Color("8a5a3a"), "wood")
				# asılı ayakkabılar
				var sh: Array = []
				for q in 5:
					sh.append(Transform3D(Basis(), Vector3(xc - hw * 0.35 + q * hw * 0.17, aw_y - 0.35, fz - row * 1.15)))
				c.mm_box(c.root, Vector3(0.24, 0.12, 0.09), Color("5a3220") if i % 2 else Color("a8503a"), sh)
				Props.box(c.root, Vector3(hw * 0.8, 0.03, 0.03), Vector3(xc, aw_y - 0.18, fz - row * 1.15), IstKbCtx.WOOD_D)
				# kapı ve pencereler (kapı sabit 1,4×2,2)
				var dx := xc + hw * 0.3
				Props.box(c.root, Vector3(1.1, 2.1, 0.08), Vector3(dx, 1.05, fz - row * 0.05), IstKbCtx.WOOD)
				Props.box(c.root, Vector3(1.5, 0.12, 0.14), Vector3(dx, 2.18, fz - row * 0.07), IstKbCtx.STONE)
				if two:
					Props.box(c.root, Vector3(0.9, 1.2, 0.05), Vector3(xc - hw * 0.2, 4.7, fz - row * 0.04), IstKbCtx.DARK)
					Props.box(c.root, Vector3(0.9, 1.2, 0.05), Vector3(xc + hw * 0.2, 4.7, fz - row * 0.04), IstKbCtx.DARK)
					Props.box(c.root, Vector3(hw, 0.2, 0.7), Vector3(xc, gh + 0.1, fz - row * 0.35), Color("7a5a3a"))
				# tabela: ayakkabı biçimli
				var sg := Props.box(c.root, Vector3(0.6, 0.35, 0.05), Vector3(xc - hw * 0.45, aw_y + 0.6, fz - row * 0.05), Color("e0c080"))
				Props.box(c.root, Vector3(0.38, 0.18, 0.06), Vector3(xc - hw * 0.45 - 0.05, aw_y + 0.6, fz - row * 0.06), Color("4a2a1a"))
				# deri tabaklama çerçevesi ve kalıp yığını sokağa bakan köşede
				if i % 2 == 0:
					Props.box(c.root, Vector3(0.9, 1.4, 0.06), Vector3(xc + hw * 0.4 - 0.9, 1.0, tz - row * 0.9), Color("b88a58"))
					Props.cyl(c.root, 0.04, 1.6, Vector3(xc + hw * 0.4 - 1.35, 0.8, tz - row * 0.9), IstKbCtx.WOOD_D, Vector3.ZERO, 5)
					Props.cyl(c.root, 0.04, 1.6, Vector3(xc + hw * 0.4 - 0.45, 0.8, tz - row * 0.9), IstKbCtx.WOOD_D, Vector3.ZERO, 5)
	# sokak ayrıntısı: sandıklar, fıçı, ayak ızı: yalnız lod 0
	if lod == 0:
		var bar := Props.cyl(c.root, 0.4, 0.8, Vector3(-hw * 1.3, 0.4, 0.5), IstKbCtx.WOOD, Vector3.ZERO, 8)
		Props.make_solid(bar)
		var cr := Props.solid(c.root, Vector3(0.9, 0.7, 0.9), Vector3(hw * 1.1, 0.35, -0.8), IstKbCtx.WOOD)
		Props.set_pattern(cr, IstKbCtx.WOOD, "wood")
		c.cypress(-n * hw * 0.5 - 2.5, 0.0, 8.0)
	# çatıya yol: kuzey sıranın doğu ucunda dış merdiven (sokaktan, sıranın yan duvarına dayalı)
	var xe := (n - 1) * 0.5 * hw + hw * 0.5
	var ze := -(lane * 0.5 + hd)
	_side_stair(c, (xe + 0.9) / c.k, ze / c.k, hh)


static func _side_stair(c: IstKbCtx, x_real: float, z_back_real: float, h: float) -> void:
	# basamaklar +z yönünden (sokak) arka duvara doğru çıkar; en üst basamak z = arka cephe
	var nst := maxi(1, int(ceil(h / 0.32)))
	var rise := h / nst
	var tread := 0.34
	for i in nst:
		var top := rise * (i + 1)
		var z := z_back_real * c.k + tread * (nst - i - 0.5)
		var b := Props.solid(c.root, Vector3(1.4, top, tread), Vector3(x_real * c.k, top * 0.5, z), Color.WHITE)
		Props.set_pattern(b, IstKbCtx.WOOD, "wood")


static func perches_kaligaria(k: float = 0.5) -> Array:
	var c := _nul(k, 60.0)
	var fk := maxf(k, 0.7)
	var hh := 6.4 if k >= 0.7 else 3.8
	return [c.to_local(Vector3(0, hh + 0.05, -(4.5 * 0.5 + 6.5 * fk * 0.5))), c.to_local(Vector3(0, hh + 0.05, 4.5 * 0.5 + 6.5 * fk * 0.5))]


static func climbs_kaligaria(k: float = 0.5) -> Array:
	var c := _nul(k, 60.0)
	var fk := maxf(k, 0.7)
	var hh := 6.4 if k >= 0.7 else 3.8
	var xe := (4 * 0.5 * 5.5 * fk) + 5.5 * fk * 0.5 + 0.9
	var ze := -(4.5 * 0.5 + 6.5 * fk)
	var nst := maxi(1, int(ceil(hh / 0.32)))
	return [[c.to_local(Vector3(xe, 0, ze + 0.34 * nst + 0.4)), c.to_local(Vector3(xe, hh, ze + 0.2)), "basamak"]]


# ----------------------------------------------------------------------------------------------------------------
## AYVANSARAY İSKELESİ (Haliç, Blakhernai/Kaligaria önü). Taş rıhtım + uzun ahşap iskele, kazıklar, babalar, ağ
## çerçeveleri, balıkçı kayıkları, çuval-fıçı yığınları. Deniz: y = 0,12 (yüzeyde ince saydam plaka, çarpışmasız).
## Rıhtım y = 0,5, iskele güvertesi y = 0,9. Kestirim (1453 ahşap iskele detayları belirsiz).

static func build_ayvansaray_iskele(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var c := IstKbCtx.create(host, "AyvansarayIskele", k, lod, 50.0, 111)
	var Lp := 22.0                                   # iskele uzunluğu (k'siz kabul: yapı ince, uzunluk insan ölçüsünde yürünür)
	# su: geniş saydam levha (görsel)
	if lod < 2:
		Props.box(c.root, Vector3(40, 0.02, 40), Vector3(0, 0.12, -22.0), Color(0.22, 0.42, 0.5, 0.78))
	# rıhtım (taş, y 0–0,5) ve ona çıkan iki basamak
	var q := Props.solid(c.root, Vector3(18, 0.5, 6), Vector3(0, 0.25, 8.0), Color.WHITE)
	Props.set_pattern(q, Color("d2c3a2"), "ashlar")
	var st := Props.solid(c.root, Vector3(4.0, 0.25, 0.6), Vector3(0, 0.125, 11.3), Color.WHITE)
	Props.set_pattern(st, Color("c0b090"), "flagstone")
	# iskele güvertesi: rıhtımdan -z yönüne, katı (tabanı yere dayalı), ahşap görünüm
	var dk := Props.solid(c.root, Vector3(3.0, 0.9, Lp), Vector3(0, 0.45, 5.0 - Lp * 0.5), Color.WHITE)
	Props.set_pattern(dk, Color("8a6a44"), "wood")
	if lod == 0:
		# güverte tahta çizgileri (dekor) ve kenar kirişleri
		for i in 14:
			Props.box(c.root, Vector3(3.04, 0.02, 0.05), Vector3(0, 0.915, 4.5 - i * 1.5), Color("5a4430"))
		for sd in [-1, 1]:
			Props.box(c.root, Vector3(0.14, 0.18, Lp), Vector3(sd * 1.5, 0.82, 5.0 - Lp * 0.5), IstKbCtx.WOOD_D)
			# kazıklar: iskele yanlarında, sudan çıkan
			for i in 8:
				Props.cyl(c.root, 0.14, 1.5, Vector3(sd * 1.7, 0.5, 4.0 - i * 2.8), IstKbCtx.WOOD_D, Vector3.ZERO, 6)
			# babalar (bağlama direkleri)
			for i in 4:
				Props.cyl(c.root, 0.11, 0.55, Vector3(sd * 1.38, 1.18, 2.0 - i * 5.5), Color("3a2a1c"), Vector3.ZERO, 6)
				Props.ball(c.root, 0.14, Vector3(sd * 1.38, 1.5, 2.0 - i * 5.5), Color("3a2a1c"), Vector3.ONE, 6)
		# rıhtımda: ağ çerçevesi, fıçı, çuval, sandık yığını
		for i in 3:
			Props.cyl(c.root, 0.05, 2.4, Vector3(-6.5 + i * 1.6, 1.7, 9.5), IstKbCtx.WOOD, Vector3.ZERO, 5)
		Props.box(c.root, Vector3(3.4, 1.4, 0.03), Vector3(-5.0, 1.8, 9.5), Color("7a8a68"))
		for i in 3:
			var fb := Props.cyl(c.root, 0.38, 0.8, Vector3(5.5 + i * 0.85, 0.9, 7.5), IstKbCtx.WOOD, Vector3.ZERO, 8)
			Props.make_solid(fb)
		var cr := Props.solid(c.root, Vector3(1.0, 0.8, 1.0), Vector3(3.8, 0.9, 9.5), IstKbCtx.WOOD)
		Props.set_pattern(cr, IstKbCtx.WOOD, "wood")
		var cr2 := Props.solid(c.root, Vector3(1.0, 0.8, 1.0), Vector3(3.8, 1.7, 9.5), IstKbCtx.WOOD)
		Props.set_pattern(cr2, Color("7e5a38"), "wood")
		# kayıklar: suda, iskeleye bağlı (görsel; çarpışmasız: su seviyesinde)
		for bi in 2:
			var bx := (-3.2 if bi == 0 else 3.4)
			var bz := -6.0 - bi * 7.0
			var hull := Props.ball(c.root, 1.0, Vector3(bx, 0.22, bz), Color("7a4a2a"), Vector3(0.7, 0.32, 2.2), 8)
			Props.box(c.root, Vector3(0.9, 0.06, 0.4), Vector3(bx, 0.42, bz + 0.3), Color("a88a5a"))
			Props.cyl(c.root, 0.02, 1.8, Vector3(bx + 0.5, 0.5, bz - 0.5), IstKbCtx.WOOD_D, Vector3(0, 0, 70), 4)
		# fener: iskele ucunda (Flame)
		Props.cyl(c.root, 0.07, 1.8, Vector3(0, 1.8, 5.0 - Lp + 0.4), IstKbCtx.WOOD_D, Vector3.ZERO, 6)
		Props.box(c.root, Vector3(0.3, 0.3, 0.3), Vector3(0, 2.8, 5.0 - Lp + 0.4), Color("5a4a38"))
		c.fire(0, 2.7, 5.0 - Lp + 0.4, 0.2, 0.4)
	c.cypress(-10.0, 13.0, 7.0)


static func perches_ayvansaray_iskele(k: float = 0.5) -> Array:
	var c := _nul(k, 50.0)
	return [c.to_local(Vector3(0, 1.4, 5.0 - 22.0 + 0.4)), c.to_local(Vector3(0, 0.95, -4.0))]


static func climbs_ayvansaray_iskele(k: float = 0.5) -> Array:
	var c := _nul(k, 50.0)
	return [[c.to_local(Vector3(0, 0.0, 14.5)), c.to_local(Vector3(0, 0.9, 3.0)), "basamak"]]


static func _nul(k: float, yon: float) -> IstKbCtx:
	var c := IstKbCtx.new()
	c.k = k
	c.yon = yon
	return c
