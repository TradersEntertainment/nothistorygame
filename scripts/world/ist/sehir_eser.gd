extends RefCounted
## ŞEHİR-3 yardımcıları (IstSehir'in eser kurucuları; catalog() yok, modül taramasına girmez):
##   palace(): Blakherna Sarayı (Tekfur Sarayı dili: üç katlı, taş-tuğla şeritli cephe, kemerli pencere sıraları,
##             zemin katta kemerli revak, üst katta balkon, kiremit kırma çatı, yan kuleler, şehir yanında avlu).
## Yerel düzen: sur iç yüzü z ≈ +2 (dış +z), saray gövdesi z −26…−16, avlu z −26…−44 (şehre bakar).

const SURDOKU := preload("res://scripts/world/ist/sur_doku.gd")
const STONE := Color("d8c8a8")
const BRICK := Color("9a5040")
const TILE := Color("a4553a")
const DARK := Color("221c18")
const LIT := Color("ffc070")

# ---------------------------------------------------------------- ESER PALETİ (ÇEVRE-4; kalite notu 21)
## Bütün eserlerin TEK paleti. Eser kurucularının (parça dosyaları, eski dünyanın Ayasofya kabuğu) renkleri kurulumdan
## sonra palet() ile bu tonlara indirilir: oyuncak doygunluğu gider, eserler evlerle aynı palete iner.
##   ton            renk      HSV doygunluk / parlaklık   kullanım
const P_TUGLA := Color("8e5646")      # 0,51 / 0,56   Bizans tuğlası: mat kiremit-kızıl (geniş harç derzi dokuda)
const P_TUGLA_K := Color("74483b")    # 0,49 / 0,45   koyu tuğla (payanda, kemer kaşı, yıkık duvar)
const P_KIREMIT := Color("94594a")    # 0,50 / 0,58   çatı kiremidi (soluk)
const P_KURSUN := Color("7a838b")     # 0,12 / 0,55   kurşun kubbe ve çatı: mavi-gri
const P_MERMER := Color("ddd4c2")     # 0,12 / 0,87   Prokonnesos mermeri: sıcak kırık beyaz
const P_TAS := Color("c2b59a")        # 0,21 / 0,76   kireçtaşı: gri-krem
const P_TAS_K := Color("a3977f")      # 0,22 / 0,64   koyu taş (söve, kaide, moloz)
const P_DOSEME := Color("c3b8a0")     # 0,18 / 0,76   meydan/avlu döşemesi: her meydanda aynı sıcak gri-krem
const P_PORFIR := Color("5c3836")     # 0,41 / 0,36   porfir: koyu erguvan-kahve (macenta değil)
const P_AHSAP := Color("6a4a30")      # 0,55 / 0,42   ahşap
const P_ALTIN := Color("b49650")      # 0,56 / 0,71   yaldız (haç, başlık)
const P_YESIL := Color("5d7046")      # 0,37 / 0,44   ot, sarmaşık, yosun
const DOYGUNLUK_EN := 0.55            # hiçbir eser rengi bunu aşmaz (bayrak, tente dâhil)

## Renk → paletteki karşılığı (ton ailesi korunur, doygunluk/parlaklık sınırlanır, ton palete çekilir)
static func ton(c: Color) -> Color:
	var h := c.h
	var s := c.s
	var v := c.v
	if s < 0.07:
		# nötr: açıklar sıcak kırık beyaza (nane-beyaz/camgöbeği beyaz gider), koyular olduğu gibi
		if v > 0.62:
			return Color.from_hsv(0.11, 0.10, minf(v, 0.84), c.a)
		return c
	if h < 0.105 or h > 0.965:
		# kızıl-turuncu-kahve: tuğla, kiremit, bayrak, ahşap
		var hh := 0.03 if h < 0.5 else 0.0
		if h < 0.105:
			hh = lerpf(h, 0.035, 0.6)
		var s2 := minf(s, 0.53)
		var v2 := minf(v, 0.70)
		if s > 0.45 and v > 0.45:
			v2 = minf(v2 * 0.93, 0.62)        # parlak turuncu tuğla / düz kırmızı çatı → mat
		return Color.from_hsv(hh, s2, v2, c.a)
	if h < 0.17:
		# krem-sarı-altın: taş, mermer, yaldız
		var s3 := minf(s, 0.24) if v > 0.7 else minf(s, DOYGUNLUK_EN)
		return Color.from_hsv(lerpf(h, 0.11, 0.5), s3, minf(v, 0.84), c.a)
	if h < 0.46:
		# yeşil: bitki, yosun
		return Color.from_hsv(lerpf(h, 0.25, 0.3), minf(s, 0.42), minf(v, 0.60), c.a)
	if h < 0.72:
		# mavi: kurşun kubbe (gök mavisi kubbe → mavi-gri), mavi boya
		if s < 0.6 or v > 0.6 or v < 0.4:
			# koyu lacivert kubbe (Khora, Pammakaristos) de kurşun: alt sınır yüksek (toon gölgede siyaha kaçmasın)
			return Color.from_hsv(0.58, minf(s, 0.08), clampf(v * 0.78, 0.44, 0.50), c.a)
		return Color.from_hsv(h, minf(s, 0.40), minf(v, 0.55), c.a)
	# mor-macenta: porfir
	return Color.from_hsv(0.99, minf(s, 0.42), minf(v, 0.42), c.a)


static var _palet_mat := {}
static var _palet_tex := {}

## Desen dokusunun paletli kopyası (dokular kendi rengini taşır: parlak turuncu tuğla dokusu da indirilir)
static func _tex_of(t: Texture2D) -> Texture2D:
	if t == null or not (t is ImageTexture) or DisplayServer.get_name() == "headless":
		return t
	var key := t.get_rid()
	if _palet_tex.has(key):
		return _palet_tex[key]
	var img := t.get_image()
	if img == null:
		_palet_tex[key] = t
		return t
	img = img.duplicate()
	if img.is_compressed():
		img.decompress()
	img.clear_mipmaps()
	var w := img.get_width()
	var hgt := img.get_height()
	for y in hgt:
		for x in w:
			var c := img.get_pixel(x, y)
			if c.s > 0.12:
				var hh := c.h
				if hh < 0.105 or hh > 0.965:
					hh = lerpf(hh if hh < 0.5 else hh - 1.0, 0.035, 0.5)
					if hh < 0.0:
						hh += 1.0
				img.set_pixel(x, y, Color.from_hsv(hh, minf(c.s, 0.46) * 0.92, c.v * (0.84 if hh < 0.12 or hh > 0.9 else 0.95)))
			else:
				# nötr pikseller sıcak gri-krem (nane-beyaz / camgöbeği gölge gitsin)
				img.set_pixel(x, y, Color(c.r * 0.97, c.g * 0.94, c.b * 0.86, c.a))
	img.generate_mipmaps()
	var nt := ImageTexture.create_from_image(img)
	_palet_tex[key] = nt
	return nt


static func _mat_of(m: Material) -> Material:
	if not (m is StandardMaterial3D):
		return m
	var sm := m as StandardMaterial3D
	if sm.vertex_color_use_as_albedo or sm.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		return m
	var key := sm.get_instance_id()
	if _palet_mat.has(key):
		return _palet_mat[key]
	var c := sm.albedo_color
	var nc := ton(c)
	if sm.albedo_texture != null and (sm.albedo_texture == Props._pattern_tex("flagstone") or sm.albedo_texture == Props._pattern_tex("cobble")):
		# döşeme: her meydanda aynı sıcak gri-krem (kalite notu 28)
		nc = P_DOSEME.lerp(nc, 0.25)
	var nt := _tex_of(sm.albedo_texture) if sm.albedo_texture != null else null
	if nt != null and nc.s > 0.2:
		# desen dokusu rengini kendisi taşır: kızıl renk × kızıl doku çarpımı doygunluğu yeniden yükseltiyordu
		# (Galata Kulesi külahı, Studios çatısı koyu kırmızı kalıyordu): renk ağırlıklı olarak açıklık verir
		nc = Color.from_hsv(nc.h, nc.s * 0.35, minf(nc.v * 1.12, 0.88), nc.a)
	if nc.is_equal_approx(c) and nt == sm.albedo_texture:
		_palet_mat[key] = m
		return m
	var d := sm.duplicate() as StandardMaterial3D
	d.albedo_color = nc
	if nt != null:
		d.albedo_texture = nt
	if sm.emission_enabled and not sm.emission.is_equal_approx(LIT):
		d.emission = ton(sm.emission)
	if nc.h > 0.46 and nc.h < 0.72 and nc.s < 0.12:
		# kurşun: mat (parlak toon yansıması gök rengini alıp kubbeyi açık maviye çeviriyordu)
		d.metallic = 0.0
		d.metallic_specular = 0.12
		d.roughness = 1.0
		d.rim_enabled = false
	_palet_mat[key] = d
	return d


static var _palet_ag := {}

## Köşe renkli ağ (parçanın kendi pişirmesi, ör. Galata): köşe renkleri palete indirilmiş kopya (ağ başına önbellek)
static func _ag_of(m: Mesh) -> Mesh:
	if not (m is ArrayMesh):
		return m
	var key := m.get_rid()
	if _palet_ag.has(key):
		return _palet_ag[key]
	var am := ArrayMesh.new()
	var renk := {}
	for si in m.get_surface_count():
		var arr := m.surface_get_arrays(si)
		var cols = arr[Mesh.ARRAY_COLOR]
		if cols is PackedColorArray and (cols as PackedColorArray).size() > 0:
			var pc := cols as PackedColorArray
			for i in pc.size():
				var c: Color = pc[i]
				if not renk.has(c):
					renk[c] = ton(c)
				pc[i] = renk[c]
			arr[Mesh.ARRAY_COLOR] = pc
		am.add_surface_from_arrays(m.surface_get_primitive_type(si), arr)
		am.surface_set_material(si, m.surface_get_material(si))
	_palet_ag[key] = am
	return am


static func _vc_mat(m: Material) -> Material:
	if not (m is StandardMaterial3D) or (m as StandardMaterial3D).albedo_texture == null:
		return m
	var key := m.get_instance_id()
	if _palet_mat.has(key):
		return _palet_mat[key]
	var nt := _tex_of((m as StandardMaterial3D).albedo_texture)
	var d: Material = m
	if nt != (m as StandardMaterial3D).albedo_texture:
		d = m.duplicate()
		(d as StandardMaterial3D).albedo_texture = nt
	_palet_mat[key] = d
	return d


## Bir eserin kurulu katmanını palete indirir (pişirmeden önce). Köşe renkli ağların köşe renkleri de indirilir.
static func palet(n: Node) -> int:
	var k := 0
	for c in n.find_children("*", "GeometryInstance3D", true, false):
		var gi := c as GeometryInstance3D
		if gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null:
			var am0 := gi.material_override if gi.material_override != null else (gi as MeshInstance3D).get_active_material(0)
			if am0 is BaseMaterial3D and (am0 as BaseMaterial3D).vertex_color_use_as_albedo:
				var mi0 := gi as MeshInstance3D
				mi0.mesh = _ag_of(mi0.mesh)
				# köşe renkli ağın desen dokusu da (kiremit/tuğla dokusu kendi rengini taşır)
				if gi.material_override != null:
					gi.material_override = _vc_mat(gi.material_override)
				else:
					for si in mi0.mesh.get_surface_count():
						var smv := mi0.get_active_material(si)
						if smv != null and _vc_mat(smv) != smv:
							mi0.set_surface_override_material(si, _vc_mat(smv))
				k += 1
				continue
		if gi.material_override != null:
			var nm := _mat_of(gi.material_override)
			if nm != gi.material_override:
				gi.material_override = nm
				k += 1
			continue
		if gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null:
			var mi := gi as MeshInstance3D
			for si in mi.mesh.get_surface_count():
				var om := mi.get_surface_override_material(si)
				var sm := om if om != null else mi.mesh.surface_get_material(si)
				if sm == null:
					continue
				var nm2 := _mat_of(sm)
				if nm2 != sm:
					mi.set_surface_override_material(si, nm2)
					k += 1
	return k


static func _sol(n: Node3D, size: Vector3, pos: Vector3, col: Color, pat: String, lod: int) -> void:
	if lod == 0:
		var b := Props.solid(n, size, pos, Color.WHITE)
		Props.set_pattern(b, col, pat)
	else:
		Props.box(n, size, pos, col)


## Kemerli açıklık (cephede): koyu dikdörtgen + yarım daire tepe + tuğla kemer çerçevesi. nz: cephenin dış normali (±x ya da ±z)
static func _arch(n: Node3D, c: Vector3, w: float, h: float, nrm: Vector3, lit: bool, gece: bool, lod: int) -> void:
	var along_x := absf(nrm.z) > 0.5
	var off := nrm * 0.03
	var rot := Vector3(90, 0, 0) if along_x else Vector3(0, 0, 90)
	var dsz := Vector3(w, h - w * 0.5, 0.06) if along_x else Vector3(0.06, h - w * 0.5, w)
	var col := DARK
	var em := 0.0
	if lit:
		col = LIT
		em = 2.2 if gece else 0.35
	var body := c + Vector3(0, (h - w * 0.5) * 0.5, 0) + off
	var mi := Props.box(n, dsz, body, col)
	if lit:
		mi.material_override = Props.mat(LIT, em, false, "", false)
	if lod <= 1:
		var top := Props.cyl(n, w * 0.5, 0.06, c + Vector3(0, h - w * 0.5, 0) + off, col, rot, 10)
		if lit:
			top.material_override = Props.mat(LIT, em, false, "", false)
		# tuğla kemer (dış yay) ve eşik
		Props.cyl(n, w * 0.5 + 0.28, 0.04, c + Vector3(0, h - w * 0.5, 0) + nrm * 0.015, BRICK, rot, 10)
		var sill := Vector3(w + 0.4, 0.18, 0.3) if along_x else Vector3(0.3, 0.18, w + 0.4)
		Props.box(n, sill, c + Vector3(0, -0.09, 0) + nrm * 0.12, STONE.lightened(0.1))


static func palace(n: Node3D, lod: int, gece: bool) -> void:
	var z0 := -26.0
	var z1 := -16.0
	var W := 26.0
	var H := 16.0
	var zc := (z0 + z1) * 0.5
	# Gövde (üç kat) ve kat şeritleri (tuğla), saçak silmesi
	_sol(n, Vector3(W, H, z1 - z0), Vector3(0, H * 0.5, zc), STONE, "tekfur", lod)
	for y: float in [5.2, 10.4]:
		Props.box(n, Vector3(W + 0.12, 0.45, z1 - z0 + 0.12), Vector3(0, y, zc), BRICK)
	Props.box(n, Vector3(W + 0.6, 0.5, z1 - z0 + 0.6), Vector3(0, H - 0.1, zc), STONE.darkened(0.08))
	if lod <= 1:
		# taş-tuğla şeritler (her katta iki ince tuğla bandı)
		for y: float in [2.0, 7.6, 12.8]:
			Props.box(n, Vector3(W + 0.08, 0.22, z1 - z0 + 0.08), Vector3(0, y, zc), BRICK.lightened(0.06))
	# Kırma çatı (kiremit) + mahya
	Props.prism(n, Vector3(z1 - z0 + 1.0, 3.6, W + 1.0), Vector3(0, H + 0.15 + 1.8, zc), TILE, Vector3(0, 90, 0))
	Props.box(n, Vector3(W + 1.0, 0.25, 0.35), Vector3(0, H + 3.85, zc), TILE.darkened(0.25))
	for sx: float in [-1.0, 1.0]:
		# kalkan uçlarında küçük kırma (çatı yüzü kapalı)
		Props.prism(n, Vector3(z1 - z0 + 1.0, 3.6, 1.2), Vector3(sx * (W * 0.5 + 0.3), H + 0.15 + 1.8, zc), TILE.darkened(0.08), Vector3(0, 90, 0))
	if lod <= 1:
		# Kiremit sıraları (çatı yüzünde ince çizgiler)
		for k in 7:
			var t := (k + 0.5) / 7.0
			var yy := H + 0.15 + 3.6 * (1.0 - t)
			var dz := (z1 - z0 + 1.0) * 0.5 * t
			for sd: float in [-1.0, 1.0]:
				Props.box(n, Vector3(W + 0.9, 0.08, 0.12), Vector3(0, yy + 0.06, zc + sd * dz), TILE.darkened(0.18))
	# Cepheler: uzun yüzlerde (z1 sur yanı, z0 avlu yanı) zemin katta kemerli revak, üst iki katta kemerli pencereler
	for side: float in [1.0, -1.0]:
		var zf := z1 if side > 0.0 else z0
		var nrm := Vector3(0, 0, side)
		for k in 6:
			var x := -10.0 + k * 4.0
			var lit := gece and (k + int(side)) % 3 != 0
			if lod <= 1:
				_arch(n, Vector3(x, 1.0, zf), 2.4, 3.4, nrm, false, gece, lod)
			_arch(n, Vector3(x, 6.4, zf), 1.5, 2.8, nrm, lit, gece, lod)
			_arch(n, Vector3(x, 11.6, zf), 1.5, 2.8, nrm, gece and not lit, gece, lod)
		if lod == 0:
			# revak sütunları (kemerlerin arası)
			for k in 7:
				Props.cyl(n, 0.28, 3.0, Vector3(-12.0 + k * 4.0, 1.5, zf + side * 0.35), Color("e6dccb"), Vector3.ZERO, 8)
	# Kısa yüzler: katta iki pencere
	for sx: float in [-1.0, 1.0]:
		for k in 2:
			for row in 2:
				_arch(n, Vector3(sx * W * 0.5, 6.4 + row * 5.2, zc - 2.4 + k * 4.8), 1.4, 2.6, Vector3(sx, 0, 0), gece and (k + row) % 2 == 0, gece, lod)
	# Balkon (üst kat, avlu yanı; Tekfur Sarayı'nın doğu balkonu): döşeme, konsollar, korkuluk
	var bz := z0 - 0.9
	_sol(n, Vector3(9.0, 0.3, 1.8), Vector3(0, 10.35, bz), STONE.lightened(0.05), "flagstone", lod)
	for k in 4:
		Props.box(n, Vector3(0.35, 0.9, 1.6), Vector3(-3.6 + k * 2.4, 9.75, bz + 0.1), STONE.darkened(0.12))
	if lod <= 1:
		Props.box(n, Vector3(9.0, 0.12, 0.12), Vector3(0, 11.5, bz - 0.84), Color("6a4a30"))
		for k in 13:
			Props.box(n, Vector3(0.06, 1.0, 0.06), Vector3(-4.4 + k * 0.733, 11.0, bz - 0.84), Color("6a4a30"))
		for sx: float in [-4.45, 4.45]:
			Props.box(n, Vector3(0.12, 0.12, 1.7), Vector3(sx, 11.5, bz), Color("6a4a30"))
	# Yan kuleler: şeritli gövde, mazgallı teras, piramit külah
	for sx: float in [-1.0, 1.0]:
		var ox := sx * (W * 0.5 + 2.4)
		_sol(n, Vector3(5.4, 20.0, 5.4), Vector3(ox, 10.0, zc + 1.0), STONE.darkened(0.03), "tekfur", lod)
		for y: float in [4.0, 9.0, 14.0, 19.0]:
			Props.box(n, Vector3(5.52, 0.45, 5.52), Vector3(ox, y, zc + 1.0), BRICK)
		Props.box(n, Vector3(6.0, 0.4, 6.0), Vector3(ox, 20.2, zc + 1.0), STONE.darkened(0.1))
		Props.prism(n, Vector3(5.6, 3.2, 5.6), Vector3(ox, 20.4 + 1.6, zc + 1.0), TILE.darkened(0.1))
		for k in 2:
			_arch(n, Vector3(ox, 6.0 + k * 6.0, zc + 1.0 + 2.7), 1.0, 2.0, Vector3(0, 0, 1), false, gece, lod)
			_arch(n, Vector3(ox + sx * 2.7, 6.0 + k * 6.0, zc + 1.0), 1.0, 2.0, Vector3(sx, 0, 0), gece and k == 1, gece, lod)
		if lod == 0:
			for k in 4:
				for sd: float in [-1.0, 1.0]:
					Props.box(n, Vector3(0.7, 0.8, 0.5), Vector3(ox - 1.9 + k * 1.27, 20.8, zc + 1.0 + sd * 2.75), STONE.darkened(0.06))
	# Altın haç (çatı ortası) ve imparatorluk sancağı
	if lod <= 1:
		Props.cyl(n, 0.12, 2.2, Vector3(0, H + 4.9, zc), Color("d8b040"), Vector3.ZERO, 6)
		Props.box(n, Vector3(1.2, 0.14, 0.14), Vector3(0, H + 5.4, zc), Color("d8b040"))
		for sx: float in [-1.0, 1.0]:
			Props.cyl(n, 0.07, 4.0, Vector3(sx * (W * 0.5 + 2.4), 23.6 + 2.0, zc + 1.0), Color("6a4a30"), Vector3.ZERO, 5)
			Props.box(n, Vector3(0.05, 1.3, 2.0), Vector3(sx * (W * 0.5 + 2.4), 26.6, zc + 2.0), Color("8a1c24"))
	# Avlu (şehir yanı): döşeli zemin, alçak duvar, kapı, kuyu, iki servi
	var a0 := -44.0
	Props.box(n, Vector3(W + 6.0, 0.1, z0 - a0), Vector3(0, 0.05, (z0 + a0) * 0.5), Color("bfb39a")).set_meta("no_walk", true)
	if lod == 0:
		var fl := n.get_child(n.get_child_count() - 1)
		Props.set_pattern(fl, Color("c8bba0"), "flagstone")
	var aw := 3.4
	for sx: float in [-1.0, 1.0]:
		_sol(n, Vector3(0.8, 4.0, z0 - a0), Vector3(sx * (W * 0.5 + 3.0), 2.0, (z0 + a0) * 0.5), STONE.darkened(0.06), "ashlar", lod)
		var seg := (W + 6.0) * 0.5 - aw * 0.5
		_sol(n, Vector3(seg, 4.0, 0.8), Vector3(sx * (aw * 0.5 + seg * 0.5), 2.0, a0), STONE.darkened(0.06), "ashlar", lod)
		Props.box(n, Vector3(seg + 0.2, 0.3, 1.0), Vector3(sx * (aw * 0.5 + seg * 0.5), 4.15, a0), BRICK)
	# kapı kemeri (üstten geçiş: başlık 4,6 m'de)
	Props.box(n, Vector3(aw + 1.6, 1.0, 1.0), Vector3(0, 4.9, a0), STONE.darkened(0.1))
	for sx: float in [-1.0, 1.0]:
		_sol(n, Vector3(0.8, 4.4, 1.0), Vector3(sx * (aw * 0.5 + 0.4), 2.2, a0), STONE.darkened(0.1), "ashlar", lod)
	Props.cyl(n, 1.0, 0.9, Vector3(-6.0, 0.45, -35.0), STONE.darkened(0.15), Vector3.ZERO, 10)
	if lod <= 1:
		Props.box(n, Vector3(0.12, 1.6, 0.12), Vector3(-6.8, 1.2, -35.0), Color("5a3a20"))
		Props.box(n, Vector3(0.12, 1.6, 0.12), Vector3(-5.2, 1.2, -35.0), Color("5a3a20"))
		Props.box(n, Vector3(1.8, 0.12, 0.12), Vector3(-6.0, 2.0, -35.0), Color("5a3a20"))
		for p: Vector3 in [Vector3(9.0, 0, -31.0), Vector3(-10.0, 0, -40.5), Vector3(10.0, 0, -40.5)]:
			Props.cyl(n, 0.18, 1.6, p + Vector3(0, 0.8, 0), Color("5a3a20"), Vector3.ZERO, 5)
			Props.cyl(n, 0.9, 6.0, p + Vector3(0, 4.4, 0), Color("2f4a2a"), Vector3.ZERO, 7, 0.05)
	if lod == 0:
		# kapılar: sur yanı ve avlu yanı (orta kemerin altı, koyu kanat)
		for side: float in [1.0, -1.0]:
			Props.box(n, Vector3(2.0, 2.6, 0.12), Vector3(0, 1.3, (z1 if side > 0 else z0) + side * 0.07), Color("4a3020"))


# ---------------------------------------------------------------- uzak sur katmanı (kalite notu 11)

## Uzak sur ağının malzemesi: köşe rengi (kireçtaşı krem / tuğla) + dikey yüzlerde dünya yüksekliğine bağlı tuğla
## şeritleri (Theodosius surlarının taş-tuğla şeridi: ~1,9 m'de bir 0,45 m'lik beş sıra tuğla) ve ince taş sırası
## çizgileri; yatay yüzler (yürüme yolu, kule terası) düz taş. Işık oyunun toon diliyle (gece ay ışığında da taş rengi).
static var _sur_uzak_mat: ShaderMaterial

static func sur_uzak_mat(tur := 0) -> ShaderMaterial:
	# SUR-4: uzak katman yakınla AYNI sur taşı gölgelendiricisi (sur_doku.gd: blok sıraları + ince tuğla hatılı;
	# eski düz şerit gölgelendiricisi uzaktan "çizgili kutu"/kereste okunuyordu). Köşe rengi pişmiş ağda.
	return SURDOKU.mat(tur, Color.WHITE, false)


## Pişmiş uzak sur ağına mazgal dişleri: yerel eksene hizalı, yukarı bakan geniş üst yüzlerin (sur yürüme yolu,
## kule terası; y > ymin) dış kenarları boyunca 2,1 m'de bir diş (1,0 × 1,1 × 0,7). st'ye xf ile eklenir.
static func mazgal(st: SurfaceTool, m: Mesh, xf: Transform3D, ymin: float) -> int:
	if m == null:
		return 0
	var seen := {}
	var n := 0
	var col := Color("cbbd9e")
	for si in m.get_surface_count():
		var arr := m.surface_get_arrays(si)
		var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var ia = arr[Mesh.ARRAY_INDEX]
		var idx: PackedInt32Array = ia if ia is PackedInt32Array else PackedInt32Array()
		var cnt := idx.size() if idx.size() > 0 else vs.size()
		for t in range(0, cnt - 2, 3):
			var a: Vector3 = vs[idx[t] if idx.size() > 0 else t]
			var b: Vector3 = vs[idx[t + 1] if idx.size() > 0 else t + 1]
			var c: Vector3 = vs[idx[t + 2] if idx.size() > 0 else t + 2]
			if absf(a.y - b.y) > 0.05 or absf(a.y - c.y) > 0.05 or a.y < ymin:
				continue
			var lo := Vector2(minf(a.x, minf(b.x, c.x)), minf(a.z, minf(b.z, c.z)))
			var hi := Vector2(maxf(a.x, maxf(b.x, c.x)), maxf(a.z, maxf(b.z, c.z)))
			var sz := hi - lo
			var area := absf((b - a).cross(c - a).y) * 0.5
			# eksene hizalı dikdörtgenin yarısı (üçgen alanı ≈ kutunun yarısı)
			if sz.x < 1.6 or sz.y < 1.6 or absf(area - sz.x * sz.y * 0.5) > sz.x * sz.y * 0.05:
				continue
			var key := "%d|%d|%d|%d|%d" % [roundi(lo.x * 4), roundi(lo.y * 4), roundi(hi.x * 4), roundi(hi.y * 4), roundi(a.y * 4)]
			if seen.has(key):
				continue
			seen[key] = true
			var y := a.y
			var kare := minf(sz.x, sz.y) > 3.5 and maxf(sz.x, sz.y) < minf(sz.x, sz.y) * 1.8
			# uzun kenarlar (kule terasında dört kenar)
			var edges: Array = []
			if sz.x >= sz.y or kare:
				edges.append([Vector2(lo.x, lo.y + 0.35), Vector2(hi.x, lo.y + 0.35)])
				edges.append([Vector2(lo.x, hi.y - 0.35), Vector2(hi.x, hi.y - 0.35)])
			if sz.y > sz.x or kare:
				edges.append([Vector2(lo.x + 0.35, lo.y), Vector2(lo.x + 0.35, hi.y)])
				edges.append([Vector2(hi.x - 0.35, lo.y), Vector2(hi.x - 0.35, hi.y)])
			for e: Array in edges:
				var p0: Vector2 = e[0]
				var p1: Vector2 = e[1]
				var L := p0.distance_to(p1)
				var k := maxi(int(L / 2.1), 1)
				var bas := Basis(Vector3.UP, 0.0 if absf(p1.y - p0.y) < 0.01 else PI * 0.5)
				for i in k:
					var q := p0.lerp(p1, (i + 0.5) / k)
					IstSehir._box_st(st, xf * Vector3(q.x, y, q.y), xf.basis * bas, Vector3(1.0, 1.1, 0.7), col)
					n += 1
	return n


# ---------------------------------------------------------------- manastır avlusu (Khora, Pammakaristos)

## Kilisenin çevresinde manastır külliyesi: avlu duvarı (kapılı, kiremit başlıklı), avluyu çeviren keşiş hücreleri
## sırası (revaklı, kiremit çatılı), trapeza (yemekhane), çan yerine simandron çerçevesi, şadırvan/kuyu, servi ve
## meyve ağaçları, döşeli yollar. hx, hz: avlunun yarı eni/boyu (yerel; kilise ortada). Kapı +z (batı cephesi) yanında.
static func manastir(n: Node3D, lod: int, hx: float, hz: float, seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var wall := STONE.darkened(0.08)
	var t := 0.8
	var wh := 3.6
	var gate := 3.6
	# avlu zemini: çakıl-toprak + döşeli yollar
	# (ÇEVRE-4: kalın levha; arazi avlu içinde levhanın üstüne çıkıp avluyu yeşile boğuyordu)
	var zem := Props.box(n, Vector3(hx * 2.0, 0.9, hz * 2.0), Vector3(0, 0.17 - 0.45, 0), Color("b9ab8c"))
	zem.set_meta("no_walk", true)
	if lod == 0:
		Props.set_pattern(zem, Color("bfb194"), "cobble")
	Props.box(n, Vector3(3.0, 0.1, hz - 6.0), Vector3(0, 0.2, hz * 0.5 + 3.0), Color("cfc2a8")).set_meta("no_walk", true)
	# duvarlar (kapı +z ortada, arka kapı −z)
	for sx: float in [-1.0, 1.0]:
		_sol(n, Vector3(t, wh, hz * 2.0), Vector3(sx * hx, wh * 0.5, 0), wall, "ashlar", lod)
		Props.box(n, Vector3(t + 0.3, 0.3, hz * 2.0 + 0.3), Vector3(sx * hx, wh + 0.15, 0), TILE)
		for sz: float in [-1.0, 1.0]:
			var seg := hx - gate * 0.5
			_sol(n, Vector3(seg, wh, t), Vector3(sx * (gate * 0.5 + seg * 0.5), wh * 0.5, sz * hz), wall, "ashlar", lod)
			Props.box(n, Vector3(seg + 0.3, 0.3, t + 0.3), Vector3(sx * (gate * 0.5 + seg * 0.5), wh + 0.15, sz * hz), TILE)
	# ana kapı: kemerli kapı yapısı, üstte küçük kiremit çatı
	for sx: float in [-1.0, 1.0]:
		_sol(n, Vector3(1.0, 5.0, 1.6), Vector3(sx * (gate * 0.5 + 0.5), 2.5, hz), wall.darkened(0.05), "ashlar", lod)
	Props.box(n, Vector3(gate + 2.0, 1.0, 1.6), Vector3(0, 5.0, hz), wall.darkened(0.05))
	Props.prism(n, Vector3(gate + 2.6, 1.3, 2.2), Vector3(0, 6.15, hz), TILE)
	if lod <= 1:
		Props.cyl(n, gate * 0.5, 1.62, Vector3(0, 4.5, hz), Color("2a2420"), Vector3(90, 0, 0), 10)
		Props.box(n, Vector3(0.1, 1.2, 0.1), Vector3(0, 7.3, hz), Color("d8b040"))
		Props.box(n, Vector3(0.7, 0.1, 0.1), Vector3(0, 7.55, hz), Color("d8b040"))
	# keşiş hücreleri: iki yan duvar boyunca revaklı sıra (iç yüz), kiremit eğik çatı
	var cw := 4.2
	for sx: float in [-1.0, 1.0]:
		var x := sx * (hx - t * 0.5 - cw * 0.5)
		var L := hz * 2.0 - 10.0
		_sol(n, Vector3(cw, 4.4, L), Vector3(x, 2.2, -1.0), STONE.lightened(0.04), "plaster", lod)
		Props.prism(n, Vector3(cw + 1.2, 1.6, L + 0.6), Vector3(x, 4.4 + 0.8, -1.0), TILE.darkened(0.05))
		if lod <= 1:
			var nk := int(L / 3.6)
			for k in nk:
				var z := -1.0 - L * 0.5 + (k + 0.5) * L / nk
				Props.box(n, Vector3(0.06, 1.9, 0.9), Vector3(x - sx * (cw * 0.5 + 0.03), 0.95, z), Color("3a2a1c"))
				Props.box(n, Vector3(0.06, 0.7, 0.6), Vector3(x - sx * (cw * 0.5 + 0.03), 3.0, z + 0.9), Color("221c18"))
	# trapeza (yemekhane): arka duvara yaslı uzun yapı, apsisli
	var tz := -hz + t * 0.5 + 3.0
	_sol(n, Vector3(hx * 1.1, 6.0, 6.0), Vector3(0, 3.0, tz), STONE, "ashlar", lod)
	Props.prism(n, Vector3(6.6, 2.2, hx * 1.1 + 0.6), Vector3(0, 6.0 + 1.1, tz), TILE, Vector3(0, 90, 0))
	Props.box(n, Vector3(hx * 1.1 + 0.1, 0.35, 6.1), Vector3(0, 3.2, tz), BRICK)
	if lod <= 1:
		for k in 5:
			_arch(n, Vector3(-hx * 0.44 + k * hx * 0.22, 2.4, tz + 3.0), 1.0, 2.0, Vector3(0, 0, 1), false, false, lod)
	# simandron çerçevesi (çan yerine tahta), kuyu/şadırvan
	var sx2 := hx * 0.55
	var sz2 := hz * 0.55
	for dx: float in [-0.9, 0.9]:
		Props.box(n, Vector3(0.22, 3.2, 0.22), Vector3(sx2 + dx, 1.6, sz2), Color("5a3a20"))
	Props.box(n, Vector3(2.2, 0.22, 0.22), Vector3(sx2, 3.2, sz2), Color("5a3a20"))
	Props.box(n, Vector3(1.5, 0.3, 0.12), Vector3(sx2, 2.5, sz2), Color("8a6a40"))
	Props.cyl(n, 1.1, 0.8, Vector3(-sx2, 0.4, sz2), STONE.darkened(0.12), Vector3.ZERO, 10)
	Props.cyl(n, 1.3, 0.25, Vector3(-sx2, 3.0, sz2), TILE, Vector3.ZERO, 8, 0.2)
	for dx: float in [-1.0, 1.0]:
		Props.box(n, Vector3(0.14, 2.6, 0.14), Vector3(-sx2 + dx, 1.7, sz2), Color("5a3a20"))
	# ağaçlar: serviler duvar boyu, meyve ağaçları (erik/badem çiçekte) bahçede
	for k in 8:
		var a := rng.randf() * TAU
		var p := Vector3(cos(a) * hx * 0.7, 0, sin(a) * hz * 0.7)
		if absf(p.x) < 13.0 and absf(p.z) < 13.0:
			continue
		if absf(p.x) > hx - t - cw - 1.2:
			continue
		var cyp := k % 2 == 0
		Props.cyl(n, 0.16, 1.6, p + Vector3(0, 0.8, 0), Color("5a3a20"), Vector3.ZERO, 5)
		if cyp:
			Props.cyl(n, 0.8, 6.5, p + Vector3(0, 4.6, 0), Color("27402a"), Vector3.ZERO, 7, 0.05)
		else:
			Props.ball(n, 1.6, p + Vector3(0, 2.9, 0), Color("e8c8d0") if k % 3 == 0 else Color("6a8a4a"), Vector3(1, 0.8, 1), 7)


# ---------------------------------------------------------------- Ayasofya meydanı (oyun alanı; Augustaion'un batısı)

## Oyun alanının zemini boş çayır kalmasın: sıcak gri-krem kireçtaşı döşeme (düzensiz derzli desen), kenar taşı, köşelerde
## çınarlar, bir kenarda mumcu/ikona tezgâhları, bir köşede çeşme, taş sekiler. Orta alan (bölümlerin oynanışı) boş.
## Yerel: merkez (0,0), sx × sz dünya ekseninde.
static func meydan(n: Node3D, lod: int, sx: float, sz: float) -> void:
	var tas := P_DOSEME
	# kalın levha (ÇEVRE-4): ince levhanın üstüne arazi çıkıp meydanı çimene boğuyordu
	var f := Props.box(n, Vector3(sx, 0.9, sz), Vector3(0, 0.17 - 0.45, 0), tas if lod == 0 else tas.darkened(0.3))
	f.set_meta("no_walk", true)
	if lod == 0:
		Props.set_pattern(f, tas, "flagstone")
	if lod >= 2:
		return
	for s: float in [-1.0, 1.0]:
		Props.box(n, Vector3(sx + 0.4, 0.22, 0.4), Vector3(0, 0.11, s * (sz * 0.5 + 0.2)), tas.darkened(0.15))
		Props.box(n, Vector3(0.4, 0.22, sz), Vector3(s * (sx * 0.5 + 0.2), 0.11, 0), tas.darkened(0.15))
	# köşe çınarları (gövde + iri taç)
	for c: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		var p := Vector3(c.x * (sx * 0.5 - 3.0), 0, c.y * (sz * 0.5 - 3.0))
		Props.cyl(n, 1.3, 0.5, p + Vector3(0, 0.25, 0), tas.darkened(0.2), Vector3.ZERO, 10)
		Props.cyl(n, 0.35, 5.0, p + Vector3(0, 2.6, 0), Color("6a5640"), Vector3.ZERO, 7)
		Props.ball(n, 3.6, p + Vector3(0, 7.2, 0), Color("4f7a3a"), Vector3(1.0, 0.75, 1.0), 9)
	# çeşme (kuzeybatı köşesine yakın): kemerli taş gövde, kurna
	var cp := Vector3(-sx * 0.5 + 9.0, 0, -sz * 0.5 + 2.2)
	Props.box(n, Vector3(4.0, 3.2, 1.6), cp + Vector3(0, 1.6, 0), Color("ddd2bc"))
	Props.prism(n, Vector3(4.4, 1.0, 2.0), cp + Vector3(0, 3.7, 0), TILE)
	Props.cyl(n, 0.9, 0.18, cp + Vector3(0, 2.2, 0.82), Color("8a7a66"), Vector3(90, 0, 0), 10)
	Props.box(n, Vector3(2.4, 0.6, 1.0), cp + Vector3(0, 0.3, 1.2), Color("bdb19a"))
	# mumcu ve ikona tezgâhları (güney kenarı): tezgâh, tente, mal
	for k in 4:
		var tp := Vector3(-sx * 0.5 + 8.0 + k * 9.0, 0, sz * 0.5 - 2.0)
		Props.box(n, Vector3(3.0, 0.9, 1.2), tp + Vector3(0, 0.45, 0), Color("8a6244"))
		Props.box(n, Vector3(3.4, 0.08, 2.2), tp + Vector3(0, 2.5, -0.3), [Color("b84a3a"), Color("e8d8a8"), Color("3a6a8a"), Color("c89a3a")][k], Vector3(-12, 0, 0))
		for sx2: float in [-1.6, 1.6]:
			Props.box(n, Vector3(0.1, 2.5, 0.1), tp + Vector3(sx2, 1.25, 0.5), Color("5a4030"))
			Props.box(n, Vector3(0.1, 2.3, 0.1), tp + Vector3(sx2, 1.15, -1.3), Color("5a4030"))
		for j in 5:
			if k % 2 == 0:
				Props.cyl(n, 0.05, 0.35, tp + Vector3(-1.2 + j * 0.6, 1.08, 0.0), Color("f2e6c0"), Vector3.ZERO, 5)
			else:
				Props.box(n, Vector3(0.4, 0.5, 0.05), tp + Vector3(-1.2 + j * 0.6, 1.15, 0.2), Color("c8a040"), Vector3(-15, 0, 0))
	# taş sekiler (kuzey kenarı)
	for k in 3:
		Props.box(n, Vector3(3.0, 0.45, 0.6), Vector3(-6.0 + k * 9.0, 0.22, -sz * 0.5 + 1.2), Color("d4c9b2"))


# ---------------------------------------------------------------- Ayasofya'nın dört yanı (ÇEVRE-4; kalite notu 13, 20)

## Ayasofya'nın yerel çerçevesinde (holder yaw'ı Ayasofya'nınki): +z batı (narteks, atrium), −z doğu (apsis), +x güney
## (Augustaion, patrikhane, Khalke), −x kuzey (Aya İrini). Gövde |x| < 28, −37 < z < 36.
##   döşeme   : her yanda sıcak gri-krem taş döşeme (P_DOSEME), komşu eserlerin ve oyun alanının çekirdeği hariç
##   atrium   : batı avlusu; üç yanı revaklı (mermer sütun + kiremit sundurma), ortada phiale (şadırvan) ve baldaken,
##              batıda propylon kapısı; avlu içi döşeli
##   vaftizhane (güneybatı köşesi, sekizgen, kurşun kubbe), skeuophylakion (kuzeydoğu, yuvarlak, konik kurşun çatı)
##   patrikhane (güney yanı, iki katlı, revaklı), Khalke'ye uzanan revak (güneydoğu), kuzeyde Aya İrini'ye bağlanan
##   avlu duvarı (kapılı, kiremit başlıklı), çınar ve serviler, mumcu/ikona tezgâhları, taş sekiler, kuşatma yığınları
## yh: Callable(x, z) → yerel zemin yüksekliği; bos: [[Vector2 merkez, yarıçap]] döşenmeyecek çekirdekler.
static func aya_cevre(n: Node3D, lod: int, yh: Callable, bos: Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	# --- döşeme ---
	var T := 6.0 if lod == 0 else (12.0 if lod == 1 else 24.0)
	var R := 66.0
	var i0 := int(-R / T)
	for i in range(i0, -i0 + 1):
		for j in range(i0, -i0 + 1):
			var c := Vector2(i * T, j * T)
			if c.length() > R:
				continue
			if absf(c.x) < 22.0 - T * 0.5 and c.y > -31.0 + T * 0.5 and c.y < 30.0 - T * 0.5:
				continue          # gövdenin altı
			var dis := false
			for b: Array in bos:
				if c.distance_to(b[0]) < float(b[1]):
					dis = true
					break
			if dis:
				continue
			# eğimde levha araziye gömülmesin: dört köşe ve ortanın en yükseği
			var y := float(yh.call(c.x, c.y))
			for o: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
				y = maxf(y, float(yh.call(c.x + o.x * T * 0.5, c.y + o.y * T * 0.5)))
			# uzak katman düz renk: dokunun ortalaması kadar koyu (düz yatay yüz toon ışıkta bembeyaz görünüyordu)
			var dc := P_DOSEME if lod == 0 else P_DOSEME.darkened(0.3)
			var f := Props.box(n, Vector3(T + 0.02, 1.2, T + 0.02), Vector3(c.x, y + 0.17 - 0.6, c.y), dc.darkened(rng.randf() * 0.05))
			f.set_meta("no_walk", true)
			if lod == 0:
				Props.set_pattern(f, P_DOSEME, "flagstone")
	if lod >= 2:
		# uzak: atrium ve ek yapılar kütle olarak
		Props.box(n, Vector3(46.0, 6.0, 4.0), Vector3(0, 3.0, 63.0), P_TAS)
		for sx: float in [-1.0, 1.0]:
			Props.box(n, Vector3(4.0, 6.0, 28.0), Vector3(sx * 21.0, 3.0, 50.0), P_TAS)
		Props.box(n, Vector3(11.0, 10.0, 38.0), Vector3(36.0, 5.0, -5.0), P_TAS)
		Props.cyl(n, 7.0, 9.0, Vector3(-36.0, 4.5, -30.0), P_TUGLA, Vector3.ZERO, 10)
		Props.cyl(n, 6.0, 8.0, Vector3(36.0, 4.0, 30.0), P_TUGLA, Vector3.ZERO, 8)
		return
	var y0 := float(yh.call(0.0, 50.0)) + 0.13
	# --- atrium (batı avlusu) ---
	var ax := 22.0           # yarı en
	var az0 := 37.0          # narteks önü
	var az1 := 63.0          # batı ucu
	_revak(n, lod, Vector3(-ax, y0, az0 + 1.0), Vector3(-ax, y0, az1), -1.0, rng)    # kuzey kanadı (iç yüz +x)
	_revak(n, lod, Vector3(ax, y0, az0 + 1.0), Vector3(ax, y0, az1), 1.0, rng)       # güney kanadı
	_revak(n, lod, Vector3(-ax, y0, az1), Vector3(-3.5, y0, az1), -1.0, rng)         # batı kanadı (iki yarı, ortada propylon)
	_revak(n, lod, Vector3(3.5, y0, az1), Vector3(ax, y0, az1), -1.0, rng)
	# propylon: iki ayak + kemer + kiremit alınlık
	for sx: float in [-1.0, 1.0]:
		_sol(n, Vector3(2.0, 7.5, 3.0), Vector3(sx * 3.5, y0 + 3.75, az1 + 0.4), P_TAS, "ashlar", lod)
	Props.box(n, Vector3(9.0, 1.6, 3.2), Vector3(0, y0 + 8.3, az1 + 0.4), P_TAS_K)
	Props.prism(n, Vector3(9.6, 2.2, 3.6), Vector3(0, y0 + 10.2, az1 + 0.4), P_KIREMIT)
	if lod == 0:
		Props.cyl(n, 2.5, 3.1, Vector3(0, y0 + 7.4, az1 + 0.4), DARK.lightened(0.1), Vector3(90, 0, 0), 12)
		Props.cyl(n, 2.9, 3.0, Vector3(0, y0 + 7.4, az1 + 0.45), P_TUGLA_K, Vector3(90, 0, 0), 12)
		Props.cyl(n, 2.5, 3.2, Vector3(0, y0 + 7.4, az1 + 0.4), DARK.lightened(0.1), Vector3(90, 0, 0), 12)
	# phiale: sekizgen havuz + baldaken (dört sütun, kurşun kubbecik)
	var pc := Vector3(0, y0, (az0 + az1) * 0.5 + 1.0)
	Props.cyl(n, 3.2, 0.8, pc + Vector3(0, 0.4, 0), P_MERMER.darkened(0.06), Vector3.ZERO, 8)
	Props.cyl(n, 2.7, 0.1, pc + Vector3(0, 0.78, 0), Color("4f6670"), Vector3.ZERO, 8)
	for k in 4:
		var a := TAU * (k + 0.5) / 4.0
		Props.cyl(n, 0.22, 4.2, pc + Vector3(cos(a) * 2.6, 2.1, sin(a) * 2.6), P_MERMER, Vector3.ZERO, 8)
	Props.cyl(n, 3.0, 0.45, pc + Vector3(0, 4.42, 0), P_MERMER.darkened(0.04), Vector3.ZERO, 8)
	Props.ball(n, 2.6, pc + Vector3(0, 4.6, 0), P_KURSUN, Vector3(1.0, 0.7, 1.0), 10)
	Props.cyl(n, 0.6, 1.4, pc + Vector3(0, 1.5, 0), P_MERMER, Vector3.ZERO, 8)
	# avlu içi: servi ve çınar, sekiler
	for p: Vector2 in [Vector2(-13, 44), Vector2(13, 44), Vector2(-13, 57), Vector2(13, 57)]:
		_servi(n, Vector3(p.x, y0, p.y), 7.5)
	# --- vaftizhane (güneybatı köşesi) ---
	var vb := Vector3(35.0, float(yh.call(35.0, 30.0)) + 0.13, 30.0)
	_sekizgen(n, lod, vb, 6.2, 8.0, 3.8, P_TUGLA, "brick")
	# --- skeuophylakion (kuzeydoğu, yuvarlak) ---
	var sk := Vector3(-37.0, float(yh.call(-37.0, -30.0)) + 0.13, -30.0)
	var skb := Props.cyl(n, 7.0, 10.0, sk + Vector3(0, 5.0, 0), P_TUGLA, Vector3.ZERO, 14)
	Props.make_solid(skb, 0.95)
	if lod == 0:
		Props.set_pattern(skb, P_TUGLA, "brick")
		for k in 8:
			var a2 := TAU * k / 8.0
			var w2 := Vector3(cos(a2) * 7.02, 6.6, sin(a2) * 7.02)
			Props.box(n, Vector3(0.9, 1.8, 0.9), sk + w2, DARK, Vector3(0, -rad_to_deg(a2), 0))
		for yy: float in [3.2, 9.8]:
			Props.cyl(n, 7.12, 0.35, sk + Vector3(0, yy, 0), P_TAS, Vector3.ZERO, 14)
	Props.cyl(n, 7.6, 4.0, sk + Vector3(0, 12.0, 0), P_KURSUN, Vector3.ZERO, 14, 0.4)
	# --- patrikhane (güney yanı): iki katlı, zemin katı revaklı, kiremit çatı ---
	var px := 37.5
	var pz0 := -24.0
	var pz1 := 12.0
	var py := float(yh.call(px, (pz0 + pz1) * 0.5)) + 0.13
	_sol(n, Vector3(9.0, 9.0, pz1 - pz0), Vector3(px + 1.5, py + 4.5, (pz0 + pz1) * 0.5), P_TAS, "plaster", lod)
	Props.box(n, Vector3(9.2, 0.35, pz1 - pz0 + 0.2), Vector3(px + 1.5, py + 4.6, (pz0 + pz1) * 0.5), P_TUGLA)
	Props.prism(n, Vector3(pz1 - pz0 + 1.0, 2.6, 10.2), Vector3(px + 1.5, py + 10.3, (pz0 + pz1) * 0.5), P_KIREMIT, Vector3(0, 90, 0))
	for k in 9:
		var z := pz0 + 2.0 + k * (pz1 - pz0 - 4.0) / 8.0
		_arch(n, Vector3(px - 3.0, py + 0.6, z), 2.2, 3.4, Vector3(-1, 0, 0), false, false, lod)
		_arch(n, Vector3(px - 3.0, py + 5.6, z), 1.2, 2.2, Vector3(-1, 0, 0), false, false, lod)
		_arch(n, Vector3(px + 6.0, py + 5.6, z), 1.2, 2.2, Vector3(1, 0, 0), false, false, lod)
	# --- Khalke'ye uzanan revak (güneydoğu) ---
	_revak(n, lod, Vector3(29.0, float(yh.call(29.0, -30.0)) + 0.13, -30.0), Vector3(45.0, float(yh.call(45.0, -34.0)) + 0.13, -34.0), 1.0, rng)
	# --- kuzey avlu duvarı (Aya İrini'ye bağlanır), kapılı ---
	var duvar := [[Vector2(-28.0, 30.0), Vector2(-54.0, 30.0)], [Vector2(-54.0, 30.0), Vector2(-54.0, 4.0)], [Vector2(-54.0, -6.0), Vector2(-54.0, -20.0)],
		[Vector2(-28.0, -38.0), Vector2(-46.0, -46.0)]]
	for dv: Array in duvar:
		_avlu_duvar(n, lod, dv[0], dv[1], yh)
	# kapı ayakları (−54, −1)
	for sz: float in [4.0, -6.0]:
		var gy := float(yh.call(-54.0, sz)) + 0.13
		_sol(n, Vector3(1.4, 4.4, 1.4), Vector3(-54.0, gy + 2.2, sz), P_TAS_K, "ashlar", lod)
	# --- ağaçlar, tezgâhlar, sekiler, kuşatma yığınları (döşemenin boş kalmaması) ---
	var agac := [Vector2(-40, 40), Vector2(-46, 18), Vector2(-40, -12), Vector2(-20, -52), Vector2(8, -50), Vector2(48, 22),
		Vector2(26, 50), Vector2(-30, 55), Vector2(52, -14), Vector2(-56, -38)]
	for k in agac.size():
		var p2: Vector2 = agac[k]
		var gy2 := float(yh.call(p2.x, p2.y)) + 0.13
		if k % 3 == 0:
			_servi(n, Vector3(p2.x, gy2, p2.y), 8.0)
		else:
			_cinar(n, Vector3(p2.x, gy2, p2.y), lod)
	if lod == 0:
		var tz := [Vector2(-30, 42), Vector2(-34, 47), Vector2(-26, 70), Vector2(30, 70), Vector2(44, 40), Vector2(20, -48)]
		for k in tz.size():
			var q: Vector2 = tz[k]
			_tezgah(n, Vector3(q.x, float(yh.call(q.x, q.y)) + 0.13, q.y), k)
		for q2: Vector2 in [Vector2(-34, 20), Vector2(-34, -2), Vector2(30, -40), Vector2(0, -46)]:
			Props.box(n, Vector3(3.0, 0.45, 0.6), Vector3(q2.x, float(yh.call(q2.x, q2.y)) + 0.35, q2.y), P_TAS.lightened(0.05))
		# kuşatma: sura taşınacak taş ve kereste yığınları, fıçılar (güneydoğu köşesi)
		for k in 3:
			var sp := Vector3(14.0 + k * 3.2, float(yh.call(14.0, -48.0)) + 0.13, -48.0)
			for j in 3:
				Props.box(n, Vector3(1.2 - j * 0.25, 0.45, 0.8), sp + Vector3(rng.randf_range(-0.3, 0.3), 0.22 + j * 0.45, rng.randf_range(-0.2, 0.2)), Color("857a66").darkened(j * 0.05), Vector3(0, rng.randf_range(-25, 25), 0))
		for k in 4:
			Props.cyl(n, 0.4, 1.0, Vector3(-8.0 + k * 0.9, float(yh.call(-8.0, -46.0)) + 0.63, -46.0), P_AHSAP, Vector3.ZERO, 8)


## Revak: a→b boyunca mermer sütun dizisi (3,2 m'de bir), arşitrav, arka duvar ve kiremit sundurma. ic: revakın içe
## (avluya) bakan yönü, a→b'nin solu (+1) ya da sağı (−1).
static func _revak(n: Node3D, lod: int, a: Vector3, b: Vector3, ic: float, rng: RandomNumberGenerator) -> void:
	var d := Vector3(b.x - a.x, 0, b.z - a.z)
	var L := d.length()
	if L < 2.0:
		return
	d /= L
	var yan := Vector3(-d.z, 0, d.x) * ic          # avluya doğru
	var yaw := atan2(d.x, d.z)
	var yd := rad_to_deg(yaw)
	var dz := 4.2                                   # revak derinliği
	var hh := 4.6
	var m := (a + b) * 0.5
	# arka duvar (dış yüz): taş, tepede tuğla şerit
	_sol_rot(n, Vector3(0.8, hh + 1.0, L), m + Vector3(0, (hh + 1.0) * 0.5, 0) - yan * 0.4, yd, lod)
	Props.box(n, Vector3(0.82, 0.4, L + 0.1), m + Vector3(0, hh + 0.6, 0) - yan * 0.4, P_TUGLA, Vector3(0, yd, 0))
	# sütunlar + arşitrav
	var k := maxi(2, int(L / 3.2))
	for i in k + 1:
		var p := a + d * (L * i / k) + yan * dz
		if lod == 0 or i % 2 == 0:
			Props.cyl(n, 0.28, hh - 0.4, p + Vector3(0, (hh - 0.4) * 0.5 + 0.2, 0), P_MERMER.darkened(0.1 + rng.randf() * 0.06), Vector3.ZERO, 8)
			if lod == 0:
				Props.box(n, Vector3(0.75, 0.3, 0.75), p + Vector3(0, hh - 0.05, 0), P_MERMER)
				Props.box(n, Vector3(0.7, 0.25, 0.7), p + Vector3(0, 0.12, 0), P_TAS_K)
	Props.box(n, Vector3(0.6, 0.5, L + 0.4), m + yan * dz + Vector3(0, hh + 0.35, 0), P_MERMER.darkened(0.05), Vector3(0, yd, 0))
	# sundurma (tek eğimli kiremit çatı): arka duvar tepesinden sütun sırasına
	var rr := Props.box(n, Vector3(dz + 1.6, 0.22, L + 0.6), m + yan * (dz * 0.5 - 0.2) + Vector3(0, hh + 1.0, 0), P_KIREMIT)
	rr.basis = Basis(Vector3.UP, yaw) * Basis(Vector3(0, 0, 1), atan2(0.9, dz) * ic)
	if lod == 0:
		Props.set_pattern(rr, P_KIREMIT, "tiles")
		# revak tabanı (bir basamak yüksek döşeme)
		var tb := Props.box(n, Vector3(dz + 0.6, 0.25, L), m + yan * (dz * 0.5) + Vector3(0, 0.12, 0), P_MERMER.darkened(0.12), Vector3(0, yd, 0))
		tb.set_meta("no_walk", true)


## Sekizgen kubbeli yapı (vaftizhane): gövde, kasnak, kurşun kubbe, kapı ve pencereler
static func _sekizgen(n: Node3D, lod: int, c: Vector3, r: float, h: float, kr: float, col: Color, pat: String) -> void:
	var g := Props.cyl(n, r, h, c + Vector3(0, h * 0.5, 0), col, Vector3.ZERO, 8)
	Props.make_solid(g, 0.95)
	if lod == 0:
		Props.set_pattern(g, col, pat)
		for k in 8:
			var a := TAU * (k + 0.5) / 8.0
			var w := Vector3(cos(a), 0, sin(a)) * (r * 0.93 + 0.03)
			Props.box(n, Vector3(0.9, 2.0, 0.9), c + w + Vector3(0, h * 0.62, 0), DARK, Vector3(0, -rad_to_deg(a), 0))
		Props.cyl(n, r + 0.12, 0.35, c + Vector3(0, h * 0.35, 0), P_TAS, Vector3.ZERO, 8)
	Props.cyl(n, r + 0.3, 0.5, c + Vector3(0, h + 0.25, 0), P_TAS_K, Vector3.ZERO, 8)
	Props.cyl(n, kr * 1.05, kr * 0.7, c + Vector3(0, h + 0.5 + kr * 0.35, 0), col, Vector3.ZERO, 12)
	Props.ball(n, kr, c + Vector3(0, h + 0.5 + kr * 0.7, 0), P_KURSUN, Vector3(1.0, 0.75, 1.0), 12)
	Props.box(n, Vector3(2.0, 2.8, 0.3), c + Vector3(0, 1.4, r * 0.95), DARK)


static func _avlu_duvar(n: Node3D, lod: int, a: Vector2, b: Vector2, yh: Callable) -> void:
	var L := a.distance_to(b)
	var k := maxi(1, int(L / 8.0))
	var d := (b - a) / L
	var yaw := rad_to_deg(atan2(d.x, d.y))
	for i in k:
		var m := a.lerp(b, (i + 0.5) / k)
		var y := float(yh.call(m.x, m.y)) + 0.13
		var w := _sol_rot(n, Vector3(0.8, 3.4, L / k + 0.05), Vector3(m.x, y + 1.7, m.y), yaw, lod)
		Props.box(n, Vector3(1.1, 0.3, L / k + 0.3), Vector3(m.x, y + 3.55, m.y), P_KIREMIT, Vector3(0, yaw, 0))
		w.set_meta("no_walk", false)


static func _sol_rot(n: Node3D, size: Vector3, pos: Vector3, yaw: float, lod: int) -> Node3D:
	if lod == 0:
		var b := Props.solid(n, size, pos, Color.WHITE, Vector3(0, yaw, 0))
		Props.set_pattern(b, P_TAS.darkened(0.05), "ashlar")
		return b
	return Props.box(n, size, pos, P_TAS.darkened(0.05), Vector3(0, yaw, 0))


static func _servi(n: Node3D, p: Vector3, h: float) -> void:
	Props.cyl(n, 0.2, 1.4, p + Vector3(0, 0.7, 0), P_AHSAP, Vector3.ZERO, 5)
	Props.cyl(n, 1.0, h, p + Vector3(0, 1.2 + h * 0.5, 0), Color("34492f"), Vector3.ZERO, 7, 0.08)


static func _cinar(n: Node3D, p: Vector3, lod: int) -> void:
	Props.cyl(n, 0.45, 5.0, p + Vector3(0, 2.5, 0), Color("6a5a46"), Vector3.ZERO, 7)
	Props.ball(n, 4.2, p + Vector3(0, 7.4, 0), Color("4d6a38"), Vector3(1.0, 0.72, 1.0), 9)
	if lod == 0:
		Props.ball(n, 2.8, p + Vector3(2.0, 8.4, 1.2), Color("56733f"), Vector3(1.0, 0.75, 1.0), 8)
		Props.ball(n, 2.6, p + Vector3(-1.8, 8.0, -1.4), Color("466336"), Vector3(1.0, 0.75, 1.0), 8)


## Mumcu / ikona / ekmek tezgâhı: tezgâh, tente (soluk), mal
static func _tezgah(n: Node3D, p: Vector3, k: int) -> void:
	var tente: Color = [Color("9a5a48"), Color("c8b890"), Color("5a6a78"), Color("a08850")][k % 4]
	Props.box(n, Vector3(3.0, 0.9, 1.2), p + Vector3(0, 0.45, 0), P_AHSAP)
	Props.box(n, Vector3(3.4, 0.08, 2.2), p + Vector3(0, 2.5, -0.3), tente, Vector3(-12, 0, 0))
	for sx: float in [-1.6, 1.6]:
		Props.box(n, Vector3(0.1, 2.5, 0.1), p + Vector3(sx, 1.25, 0.5), Color("5a4030"))
		Props.box(n, Vector3(0.1, 2.3, 0.1), p + Vector3(sx, 1.15, -1.3), Color("5a4030"))
	for j in 5:
		if k % 2 == 0:
			Props.cyl(n, 0.05, 0.35, p + Vector3(-1.2 + j * 0.6, 1.08, 0.0), Color("e8dcc0"), Vector3.ZERO, 5)
		else:
			Props.box(n, Vector3(0.4, 0.5, 0.05), p + Vector3(-1.2 + j * 0.6, 1.15, 0.2), P_ALTIN, Vector3(-15, 0, 0))
