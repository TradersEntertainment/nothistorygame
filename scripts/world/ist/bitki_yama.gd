class_name IstBitkiYama
extends RefCounted
## İstanbul, Nisan 1453: alan doldurucular (MultiMesh) ve yer öğeleri (duvar, çit, yol, dere, köprü, pınar).
## build_patch_<tur>(host, alan: Vector2, k, lod, tohum): alan (x=doğu-batı, y=kuzey-güney) host merkezli.
## Zemin yamaları dokulu (köşe-renk + üretilmiş doku); lod 2'de yalnız doku. k yalnız kütleyi ölçekler.

const TURLER := {
	"bag": ["Bağ (teraslı)", Vector2(24, 24)],
	"bostan": ["Bostan tarhları", Vector2(20, 20)],
	"bugday": ["Buğday tarlası (yeşil)", Vector2(30, 30)],
	"cayir": ["Çayır ve kır çiçekleri", Vector2(24, 24)],
	"bahce": ["Meyve bahçesi", Vector2(30, 30)],
	"sazlik": ["Sazlık", Vector2(16, 16)],
	"kumsal": ["Kıyı kumu ve çakıl", Vector2(30, 10)],
	"kaya": ["Kaya yığını", Vector2(10, 10)],
	"mezarlik": ["Mezarlık (servili)", Vector2(24, 24)],
	"patika": ["Patika", Vector2(40, 1.2)],
	"toprak_yol": ["Toprak yol", Vector2(40, 3.5)],
	"tas_yol": ["Taş döşeme yol", Vector2(40, 4.0)],
}

static var _items := {}
static var _gmats := {}
static var _wmat: StandardMaterial3D


static func catalog() -> Array:
	var out: Array = []
	for id: String in TURLER.keys():
		var t: Array = TURLER[id]
		var a: Vector2 = t[1]
		var e := IstBitki._kayit(id, t[0], Vector3(a.x, 2.0, a.y), "bahar")
		e["yama"] = true
		out.append(e)
	var tekil := [["bahce_duvari", "Kuru taş bahçe duvarı", Vector3(10, 0.9, 0.5)], ["cit", "Çalı çit", Vector3(10, 1.2, 0.2)],
		["dere", "Dere (Lykos)", Vector3(40, 0.5, 5)], ["kopru", "Küçük taş köprü", Vector3(6, 0.9, 2.4)],
		["pinar", "Kaynak / pınar", Vector3(2.4, 1.3, 2.0)], ["sarmasik", "Harabe duvarı, sarmaşık ve ot", Vector3(5, 3.0, 0.8)]]
	for t: Array in tekil:
		out.append(IstBitki._kayit(t[0], t[1], t[2], "bahar"))
	return out


# ------------------------------------------------------------------ doku
static func _hh(x: int, y: int, s: int) -> float:
	return IstBitki.hash_f(float(x), float(y), 0.5, s)


## 128x128 dönemli doku, 4 m'lik karo (32 px/m). Satırlar +x boyunca uzanır; satır aralığı 2 m (64 px).
static func ground_tex(tur: String) -> ImageTexture:
	var img := Image.create(128, 128, false, Image.FORMAT_RGB8)
	var s := tur.hash() & 0xfff
	for y in 128:
		for x in 128:
			var n1 := _hh(x / 4 % 32, y / 4 % 32, s)
			var n2 := _hh(x / 2 % 64, y / 2 % 64, s + 3)
			var n3 := _hh(x, y, s + 5)
			var c: Color
			match tur:
				"bag":
					var ry := absf(float((y + 32) % 64) - 32.0) / 32.0     # 0 sıra ekseni, 1 sıra arası
					c = Color("6a4c30").lerp(Color("7a5c3a"), n1)
					if ry < 0.14:
						c = Color("523a26").lerp(Color("624630"), n2)       # sırta sürülmüş koyu toprak
					elif ry > 0.45:
						c = Color("5c7a34").lerp(Color("82994a"), n2 * 0.9 + n3 * 0.2)  # sıra arası ot
						if n3 > 0.9:
							c = Color("e8c838")                              # karahindiba
				"bostan":
					var ry2 := absf(float((y + 32) % 64) - 32.0) / 32.0
					if ry2 < 0.42:
						c = Color("5a4028").lerp(Color("6e5030"), n2)        # kabarık tarla
						if int(x / 6 + 3) % 5 != 0 and absf(float((y + 32) % 64) - 32.0) < 6.0:
							c = Color("5c9a3a").lerp(Color("8cc050"), n3)    # sıradaki fide
					else:
						c = Color("3e2c1c").lerp(Color("4a3622"), n1)        # çizi
				"bugday":
					c = Color("5a8a32").lerp(Color("86b244"), n1 * 0.7 + n2 * 0.4)
					if (x / 3) % 5 == 0:
						c = c.darkened(0.14)                                  # ekin şeritleri
				"cayir":
					c = Color("5a8c34").lerp(Color("8cb050"), n1 * 0.8 + n2 * 0.3)
					if n3 > 0.985:
						c = Color("d8341c")                                   # gelincik
					elif n3 > 0.972:
						c = Color("f6f2e0")                                   # papatya
					elif n3 > 0.962:
						c = Color("f0d03a")
				"bahce":
					c = Color("608a34").lerp(Color("8ab04c"), n1 * 0.8 + n2 * 0.3)
					if n3 > 0.975:
						c = Color("f6f2e0")
					elif n3 > 0.96:
						c = Color("f2d640")
				"sazlik":
					c = Color("5a5a34").lerp(Color("7c7a44"), n1)
					if n2 > 0.7:
						c = Color("44502c")
					if n3 > 0.9:
						c = Color("3a4a54")                                   # su gözleri
				"kumsal":
					c = Color("c8b488").lerp(Color("e2d0a4"), n1 * 0.7 + n3 * 0.3)
					if n3 > 0.93:
						c = Color("8a8272")                                   # çakıl
					elif n2 > 0.9:
						c = Color("a69874")
				"kaya":
					c = Color("6e6a58").lerp(Color("8a8470"), n1)
					if n2 > 0.75:
						c = Color("5a7a38")
				"mezarlik":
					c = Color("6a8a3c").lerp(Color("90a85a"), n1 * 0.7 + n2 * 0.3)
					if n3 > 0.97:
						c = Color("e8dc98")
				"patika":
					c = Color("8c7048").lerp(Color("a28458"), n1)
					if n3 > 0.93:
						c = Color("6a5030")
				"toprak_yol":
					c = Color("86683e").lerp(Color("a08258"), n1 * 0.7 + n3 * 0.3)
					var wheel := absf(float(y) - 38.0) < 5.0 or absf(float(y) - 90.0) < 5.0
					if wheel:
						c = c.darkened(0.2)                                   # tekerlek izi
					if n2 > 0.92:
						c = Color("7a8a4a")
				"tas_yol":
					var cx := (x + (y / 16 % 2) * 8) % 16
					var edge := cx < 1 or y % 16 < 1
					c = Color("8a8272").lerp(Color("b2a88e"), _hh(x / 16 + (y / 16) * 11, y / 16, s))
					if edge:
						c = Color("3e3a30")                                   # derz
						if n3 > 0.8:
							c = Color("5a7a34")                               # derz otu
				_:
					c = Color("6a8a3c")
			img.set_pixel(x, y, c)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


static func ground_mat(tur: String, alan: Vector2) -> StandardMaterial3D:
	var key := "%s|%.1f|%.1f" % [tur, alan.x, alan.y]
	if _gmats.has(key):
		return _gmats[key]
	var m := StandardMaterial3D.new()
	m.albedo_texture = ground_tex(tur)
	m.uv1_scale = Vector3(alan.x / 4.0, alan.y / 4.0, 1.0)
	m.texture_repeat = true
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	_gmats[key] = m
	return m


static func _ground(root: Node3D, tur: String, alan: Vector2, y := 0.03) -> void:
	var pm := PlaneMesh.new()
	pm.size = alan
	var mi := MeshInstance3D.new()
	mi.mesh = pm
	mi.name = "zemin_doku"
	mi.material_override = ground_mat(tur, alan)
	mi.position.y = y
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mi)


# ------------------------------------------------------------------ öğe ağları
static func _blade(m: Dictionary, base: Vector3, h: float, w: float, lean: Vector3, c0: Color, c1: Color) -> void:
	var side := Vector3(-lean.z, 0, lean.x).normalized() * w if lean.length() > 0.001 else Vector3(w, 0, 0)
	var tip := base + lean + Vector3(0, h, 0)
	IstBitki.tri(m, base - side, base + side, tip, c0, c0, c1, base + Vector3(0, h * 0.5, 0) + lean * 0.5 + side.cross(Vector3.UP) * 5.0)


static func item(key: String) -> ArrayMesh:
	if _items.has(key):
		return _items[key]
	var m := IstBitki.new_mesh_data()
	var rng := RandomNumberGenerator.new()
	rng.seed = key.hash()
	match key:
		"ot":
			for i in 7:
				var a := TAU * float(i) / 7.0 + rng.randf_range(-0.3, 0.3)
				var d := Vector3(cos(a), 0, sin(a))
				_blade(m, d * rng.randf_range(0.01, 0.08), rng.randf_range(0.22, 0.46), 0.022, d * rng.randf_range(0.04, 0.14), Color("3c5e24"), Color("a2c456"))
		"bugday":
			for i in 11:
				var a := TAU * float(i) / 11.0 + rng.randf_range(-0.3, 0.3)
				var d := Vector3(cos(a), 0, sin(a))
				_blade(m, d * rng.randf_range(0.02, 0.18), rng.randf_range(0.28, 0.42), 0.02, d * rng.randf_range(0.02, 0.1), Color("3e6a24"), Color("8cc04a"))
		"gelincik":
			for i in 3:
				var b := Vector3(rng.randf_range(-0.12, 0.12), 0, rng.randf_range(-0.12, 0.12))
				var h := rng.randf_range(0.3, 0.5)
				_blade(m, b, h, 0.008, Vector3(0.02, 0, 0.02), Color("3e6a24"), Color("5e8a34"))
				var c := b + Vector3(0, h, 0)
				IstBitki.add_blob(m, c, Vector3(0.07, 0.035, 0.07), i, Color("d62c1c"), Color("f05a30"), 5, 2, 0.8, 0.1)
				IstBitki.add_blob(m, c + Vector3(0, 0.03, 0), Vector3(0.02, 0.015, 0.02), i, Color("181010"), Color("181010"), 4, 2, 1.0, 0.0)
		"papatya":
			for i in 3:
				var b := Vector3(rng.randf_range(-0.12, 0.12), 0, rng.randf_range(-0.12, 0.12))
				var h := rng.randf_range(0.25, 0.4)
				_blade(m, b, h, 0.008, Vector3(0.0, 0, 0.03), Color("3e6a24"), Color("5e8a34"))
				IstBitki.add_blob(m, b + Vector3(0, h, 0.03), Vector3(0.07, 0.02, 0.07), i, Color("f8f6ea"), Color("ffffff"), 6, 2, 1.0, 0.05)
				IstBitki.add_blob(m, b + Vector3(0, h + 0.015, 0.03), Vector3(0.025, 0.015, 0.025), i, Color("f0c820"), Color("f0c820"), 4, 2, 1.0, 0.0)
		"bakla":
			for i in 3:
				var b := Vector3(rng.randf_range(-0.1, 0.1), 0, rng.randf_range(-0.1, 0.1))
				var h := rng.randf_range(0.5, 0.72)
				_blade(m, b, h, 0.014, Vector3(0.03, 0, 0), Color("4a7a34"), Color("6e9e46"))
				for j in 4:
					var yy := h * (0.3 + 0.17 * j)
					IstBitki.add_blob(m, b + Vector3(0.05 * (j % 2 * 2 - 1), yy, 0), Vector3(0.1, 0.03, 0.06), i * 5 + j, Color("7fa65e"), Color("a4c682"), 5, 2, 0.8, 0.15)
				IstBitki.add_blob(m, b + Vector3(0, h * 0.82, 0.04), Vector3(0.035, 0.03, 0.03), i, Color("f4f2f0"), Color("2a2428"), 4, 2, 0.8, 0.0)
		"sogan":
			for i in 6:
				var a := TAU * float(i) / 6.0
				var d := Vector3(cos(a), 0, sin(a))
				_blade(m, d * 0.03, rng.randf_range(0.2, 0.3), 0.022, d * 0.04, Color("5a8e34"), Color("92c85c"))
		"marul":
			for i in 6:
				var a := TAU * float(i) / 6.0
				var d := Vector3(cos(a), 0, sin(a))
				IstBitki.add_blob(m, d * 0.07 + Vector3(0, 0.07, 0), Vector3(0.11, 0.05, 0.08), i, Color("7ab048"), Color("b4dc78"), 5, 2, 0.8, 0.15)
			IstBitki.add_blob(m, Vector3(0, 0.1, 0), Vector3(0.08, 0.05, 0.08), 9, Color("a4d070"), Color("d0ec98"), 5, 2, 0.8, 0.1)
		"asma":
			# bükük kütük + üç çubuk + taze yaprak öbekleri; kazığa bağlı
			IstBitki.add_frustum(m, Vector3.ZERO, 0.09, 0.06, 0.55, 6, Color("4a3a2c"), Color("5e4a38"), Vector3(0.1, 0, 0.0), true)
			for i in 3:
				var a := TAU * float(i) / 3.0
				var d := Vector3(cos(a), 0, sin(a))
				IstBitki.add_frustum(m, Vector3(0.1, 0.55, 0), 0.03, 0.015, 0.4, 4, Color("5e4a38"), Color("7a6448"), d * 0.28, true)
				IstBitki.add_blob(m, Vector3(0.1, 0.95, 0) + d * 0.3, Vector3(0.22, 0.15, 0.22), i, Color("5e9a30"), Color("9acc50"), 6, 3, 0.8, 0.2)
			IstBitki.add_box(m, Vector3(-0.18, 0.7, 0), Vector3(0.06, 1.4, 0.06), Color("8a6a44"))
		"kazik":
			IstBitki.add_box(m, Vector3(0, 0.8, 0), Vector3(0.07, 1.6, 0.07), Color("8a6a44"))
		"kamis":
			for i in 9:
				var a := TAU * float(i) / 9.0 + rng.randf_range(-0.3, 0.3)
				var d := Vector3(cos(a), 0, sin(a))
				var h := rng.randf_range(1.5, 2.3)
				_blade(m, d * rng.randf_range(0.02, 0.2), h, 0.03, d * rng.randf_range(0.1, 0.35), Color("5a6a2c"), Color("cdb872"))
			IstBitki.add_blob(m, Vector3(0.05, 2.0, 0), Vector3(0.07, 0.2, 0.07), 1, Color("8a6a40"), Color("b08a54"), 5, 3, 0.8, 0.1)
		"kaya":
			IstBitki.add_blob(m, Vector3(0, 0.22, 0), Vector3(0.5, 0.34, 0.45), 3, Color("6a665a"), Color("9c9684"), 7, 4, 0.55, 0.25)
			IstBitki.add_blob(m, Vector3(0.1, 0.5, 0.0), Vector3(0.28, 0.12, 0.26), 4, Color("5e8a38"), Color("86ae4c"), 6, 2, 0.8, 0.2)   # tepede yosun
		"cali":
			IstBitki.add_blob(m, Vector3(0, 0.38, 0), Vector3(0.62, 0.46, 0.58), 5, Color("3e6a2c"), Color("7aa844"), 7, 4, 0.55, 0.22)
		"tas":
			IstBitki.add_blob(m, Vector3(0, 0.04, 0), Vector3(0.12, 0.05, 0.1), 7, Color("7a766a"), Color("b0aa96"), 5, 2, 0.7, 0.25)
		"yassi_tas":
			IstBitki.add_box(m, Vector3(0, 0.02, 0), Vector3(0.5, 0.06, 0.42), Color("9a927e"), Color("b2aa94"))
		"mezar":
			IstBitki.add_box(m, Vector3(0, 0.45, 0), Vector3(0.28, 0.9, 0.1), Color("d6ceb8"), Color("e4dcc6"))
			IstBitki.add_blob(m, Vector3(0, 0.98, 0), Vector3(0.17, 0.12, 0.12), 2, Color("e2dac2"), Color("f4eed8"), 6, 3, 0.85, 0.05)
			IstBitki.add_box(m, Vector3(0, 0.08, 0.35), Vector3(0.4, 0.16, 0.9), Color("c4bca8"))
		"yaprak_sarmasik":
			IstBitki.add_blob(m, Vector3(0, 0.1, 0), Vector3(0.28, 0.2, 0.18), 6, Color("2e5a2c"), Color("5a8c3c"), 6, 3, 0.7, 0.25)
		"odun":
			IstBitki.add_frustum(m, Vector3(0, 0.08, 0), 0.08, 0.07, 0.9, 6, Color("6a4e34"), Color("8a6a48"), Vector3(0.85, 0, 0), true)
		"cakil":
			IstBitki.add_blob(m, Vector3(0, 0.02, 0), Vector3(0.07, 0.03, 0.06), 8, Color("8a8478"), Color("d6ccb4"), 5, 2, 0.7, 0.25)
	var am := IstBitki.finish(m)
	_items[key] = am
	return am


# ------------------------------------------------------------------ MultiMesh
static func _mm(parent: Node3D, mesh: Mesh, xf: Array, cols: Array, name := "mm") -> void:
	if xf.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = mesh
	mm.instance_count = xf.size()
	for i in xf.size():
		mm.set_instance_transform(i, xf[i])
		mm.set_instance_color(i, cols[i])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.name = name
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)


static func _jc(rng: RandomNumberGenerator, v := 0.12) -> Color:
	var g := 1.0 + rng.randf_range(-v, v)
	return Color(g, g * (1.0 + rng.randf_range(-v * 0.3, v * 0.3)), g, 1.0)


class Acc:
	var xf: Array = []
	var cols: Array = []
	func add(p: Vector3, yaw: float, sc: float, c: Color, sy := 1.0) -> void:
		var b := Basis(Vector3.UP, yaw).scaled(Vector3(sc, sc * sy, sc))
		xf.append(Transform3D(b, p))
		cols.append(c)


static func _scatter(acc: Acc, rng: RandomNumberGenerator, alan: Vector2, per_m2: float, lod_f: float, smin: float, smax: float, jit := 0.12, y := 0.0) -> void:
	var n := int(alan.x * alan.y * per_m2 * lod_f)
	for i in n:
		acc.add(Vector3(rng.randf_range(-alan.x * 0.5, alan.x * 0.5), y, rng.randf_range(-alan.y * 0.5, alan.y * 0.5)), rng.randf() * TAU, rng.randf_range(smin, smax), _jc(rng, jit))


# ------------------------------------------------------------------ yama doldurucu
static func patch(host: Node3D, tur: String, alan: Vector2, k: float, lod: int, tohum: int) -> Node3D:
	var root := Node3D.new()
	root.name = "yama_" + tur
	host.add_child(root)
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum * 7919 + tur.hash()
	_ground(root, tur, alan)
	if lod >= 2:
		return root
	var f := 1.0 if lod == 0 else 0.3
	var sc_up := 1.0 if lod == 0 else 1.5
	var hx := alan.x * 0.5
	var hz := alan.y * 0.5
	match tur:
		"bag":
			var asma := Acc.new()
			var kz := Acc.new()
			var ot := Acc.new()
			var rows := int(alan.y / 2.0)
			for r in rows:
				var z := -hz + 1.0 + 2.0 * r
				var step := 1.3 if lod == 0 else 2.6
				var x := -hx + 0.8
				var n := 0
				while x < hx - 0.5:
					asma.add(Vector3(x, 0, z + rng.randf_range(-0.05, 0.05)), rng.randf() * 0.4 + PI * 0.5, rng.randf_range(0.9, 1.15) * sc_up, _jc(rng, 0.08))
					if n % 3 == 1:
						kz.add(Vector3(x, 0, z), 0.0, 1.0, _jc(rng, 0.05))
					x += step
					n += 1
			_scatter(ot, rng, alan, 0.9, f, 0.8, 1.3, 0.14)
			_mm(root, item("asma"), asma.xf, asma.cols, "bag_asma")
			_mm(root, item("ot"), ot.xf, ot.cols, "bag_ot")
			# teras kenarları: 28 cm kuru taş basamak (zıplamadan çıkılır), her 12 m'de bir
			var tz := -hz + 11.0
			while tz < hz - 2.0 and lod == 0:
				_solid_box(root, Vector3(alan.x, 0.28, 0.9), Vector3(0, 0.14, tz), Color("8c8470"))
				tz += 12.0
		"bostan":
			var kinds := ["bakla", "sogan", "marul"]
			var accs := [Acc.new(), Acc.new(), Acc.new()]
			var ot2 := Acc.new()
			var rows2 := int(alan.y / 2.0)
			for r in rows2:
				var z := -hz + 1.0 + 2.0 * r
				var which: int = (r + tohum) % 3
				var step := (0.45 if which == 1 else (0.55 if which == 2 else 0.5)) * (1.0 if lod == 0 else 2.2)
				var x := -hx + 0.4
				while x < hx - 0.3:
					var a: Acc = accs[which]
					a.add(Vector3(x, 0.02, z + rng.randf_range(-0.08, 0.08)), rng.randf() * TAU, rng.randf_range(0.85, 1.2) * sc_up, _jc(rng, 0.1))
					x += step
			_scatter(ot2, rng, alan, 0.25, f, 0.6, 1.0, 0.14)
			for i in 3:
				_mm(root, item(kinds[i]), (accs[i] as Acc).xf, (accs[i] as Acc).cols, "bostan_" + kinds[i])
			_mm(root, item("ot"), ot2.xf, ot2.cols, "bostan_ot")
		"bugday":
			var w := Acc.new()
			var g := Acc.new()
			_scatter(w, rng, alan, 5.0, f, 0.85, 1.25, 0.12)
			_scatter(g, rng, alan, 0.04, f, 0.9, 1.1, 0.1)
			_mm(root, item("bugday"), w.xf, w.cols, "bugday")
			_mm(root, item("gelincik"), g.xf, g.cols, "bugday_gelincik")
		"cayir":
			var o := Acc.new()
			var gl := Acc.new()
			var pa := Acc.new()
			_scatter(o, rng, alan, 1.8, f, 0.9, 1.5, 0.14)
			_scatter(gl, rng, alan, 0.7, f, 0.9, 1.3, 0.1)
			_scatter(pa, rng, alan, 0.6, f, 0.9, 1.3, 0.05)
			_mm(root, item("ot"), o.xf, o.cols, "cayir_ot")
			_mm(root, item("gelincik"), gl.xf, gl.cols, "cayir_gelincik")
			_mm(root, item("papatya"), pa.xf, pa.cols, "cayir_papatya")
		"bahce":
			_orchard(root, rng, alan, f, lod)
		"sazlik":
			var ka := Acc.new()
			var o2 := Acc.new()
			_scatter(ka, rng, alan, 1.6, f, 0.8, 1.35, 0.1)
			_scatter(o2, rng, alan, 0.8, f, 0.9, 1.3, 0.12)
			_mm(root, item("kamis"), ka.xf, ka.cols, "sazlik_kamis")
			_mm(root, item("ot"), o2.xf, o2.cols, "sazlik_ot")
		"kumsal":
			var c := Acc.new()
			var od := Acc.new()
			_scatter(c, rng, alan, 2.5, f, 0.7, 1.6, 0.15)
			_scatter(od, rng, alan, 0.03, f, 0.8, 1.2, 0.1)
			_mm(root, item("cakil"), c.xf, c.cols, "kumsal_cakil")
			_mm(root, item("odun"), od.xf, od.cols, "kumsal_odun")
		"kaya":
			var ky := Acc.new()
			var ca := Acc.new()
			_scatter(ky, rng, alan, 0.04, f if lod == 0 else 0.6, 0.8, 2.2, 0.15)
			_scatter(ca, rng, alan, 0.05, f, 0.8, 1.4, 0.1)
			_mm(root, item("kaya"), ky.xf, ky.cols, "kaya")
			_mm(root, item("cali"), ca.xf, ca.cols, "kaya_cali")
		"mezarlik":
			_graveyard(root, rng, alan, f, lod)
		"patika", "toprak_yol":
			var o3 := Acc.new()
			var t3 := Acc.new()
			for i in int(alan.x * 1.5 * f):
				var side := -1.0 if rng.randf() < 0.5 else 1.0
				o3.add(Vector3(rng.randf_range(-hx, hx), 0, side * (hz + rng.randf_range(0.05, 0.5))), rng.randf() * TAU, rng.randf_range(0.9, 1.5), _jc(rng, 0.14))
			for i in int(alan.x * 0.8 * f):
				var side2 := -1.0 if rng.randf() < 0.5 else 1.0
				t3.add(Vector3(rng.randf_range(-hx, hx), 0, side2 * (hz * rng.randf_range(0.2, 1.0))), rng.randf() * TAU, rng.randf_range(0.8, 1.4), _jc(rng, 0.1))
			_mm(root, item("ot"), o3.xf, o3.cols, "yol_ot")
			_mm(root, item("tas"), t3.xf, t3.cols, "yol_tas")
		"tas_yol":
			pass
	if tur == "tas_yol":
		var fl := Acc.new()
		var o4 := Acc.new()
		var x := -hx
		var ri := 0
		while x < hx and lod == 0:
			var z := -hz + 0.25
			while z < hz:
				var jitter := (ri % 2) * 0.22
				fl.add(Vector3(x + jitter, 0.03, z), rng.randf_range(-0.12, 0.12), rng.randf_range(0.9, 1.05), _jc(rng, 0.14))
				z += 0.5
			x += 0.5
			ri += 1
		for i in int(alan.x * 1.2 * f):
			var sd := -1.0 if rng.randf() < 0.5 else 1.0
			o4.add(Vector3(rng.randf_range(-hx, hx), 0, sd * (hz + rng.randf_range(0.05, 0.4))), rng.randf() * TAU, rng.randf_range(0.9, 1.4), _jc(rng, 0.14))
		_mm(root, item("yassi_tas"), fl.xf, fl.cols, "yol_tas_dosemesi")
		_mm(root, item("ot"), o4.xf, o4.cols, "yol_ot")
	return root


static func _solid_box(parent: Node3D, size: Vector3, pos: Vector3, col: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	var m := IstBitki.new_mesh_data()
	IstBitki.add_box(m, Vector3.ZERO, size, col, col.lightened(0.1))
	var mi := MeshInstance3D.new()
	mi.mesh = IstBitki.finish(m)
	body.add_child(mi)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(cs)
	parent.add_child(body)
	return body


static func _orchard(root: Node3D, rng: RandomNumberGenerator, alan: Vector2, f: float, lod: int) -> void:
	var turler := ["badem", "kiraz", "erguvan", "incir", "nar"]
	var accs := {}
	for t: String in turler:
		accs[t] = Acc.new()
	var body := StaticBody3D.new()
	body.name = "agac_govdeleri_katı"
	root.add_child(body)
	var sp := 6.0 if lod == 0 else 8.0
	var hx := alan.x * 0.5
	var hz := alan.y * 0.5
	var z := -hz + sp * 0.5
	var ri := 0
	while z < hz - 1.5:
		var x := -hx + sp * 0.5 + (ri % 2) * sp * 0.5
		while x < hx - 1.5:
			var t: String = turler[rng.randi() % turler.size()]
			var p := Vector3(x + rng.randf_range(-0.7, 0.7), 0, z + rng.randf_range(-0.7, 0.7))
			(accs[t] as Acc).add(p, rng.randf() * TAU, rng.randf_range(0.9, 1.12), _jc(rng, 0.06))
			var d: Dictionary = IstBitki.AGAC[t]
			var cs := CollisionShape3D.new()
			var cy := CylinderShape3D.new()
			cy.radius = maxf(0.2, float(d["tr"]) * 1.2)
			cy.height = float(d["th"])
			cs.shape = cy
			cs.position = p + Vector3(0, cy.height * 0.5, 0)
			body.add_child(cs)
			x += sp
		z += sp * 0.9
		ri += 1
	for t: String in turler:
		_mm(root, IstBitki.tree_mesh(t, 0 if lod == 0 else 1), (accs[t] as Acc).xf, (accs[t] as Acc).cols, "bahce_" + t)
	var o := Acc.new()
	var gl := Acc.new()
	var pa := Acc.new()
	_scatter(o, rng, alan, 1.0, f, 0.9, 1.4, 0.14)
	_scatter(gl, rng, alan, 0.25, f, 0.9, 1.3, 0.1)
	_scatter(pa, rng, alan, 0.4, f, 0.9, 1.3, 0.05)
	_mm(root, item("ot"), o.xf, o.cols, "bahce_ot")
	_mm(root, item("gelincik"), gl.xf, gl.cols, "bahce_gelincik")
	_mm(root, item("papatya"), pa.xf, pa.cols, "bahce_papatya")


static func _graveyard(root: Node3D, rng: RandomNumberGenerator, alan: Vector2, f: float, lod: int) -> void:
	var sv := Acc.new()
	var ms := Acc.new()
	var o := Acc.new()
	var body := StaticBody3D.new()
	body.name = "mezar_katı"
	root.add_child(body)
	var hx := alan.x * 0.5
	var hz := alan.y * 0.5
	var n_tree := int(alan.x * alan.y / 70.0)
	for i in n_tree:
		var p := Vector3(rng.randf_range(-hx + 1, hx - 1), 0, rng.randf_range(-hz + 1, hz - 1))
		sv.add(p, rng.randf() * TAU, rng.randf_range(0.7, 1.15), _jc(rng, 0.08))
		var cs := CollisionShape3D.new()
		var cy := CylinderShape3D.new()
		cy.radius = 0.2
		cy.height = 0.8
		cs.shape = cy
		cs.position = p + Vector3(0, 0.4, 0)
		body.add_child(cs)
	var z := -hz + 1.5
	while z < hz - 1.0:
		var x := -hx + 1.5
		while x < hx - 1.0:
			if rng.randf() < 0.55:
				var p := Vector3(x + rng.randf_range(-0.3, 0.3), 0, z + rng.randf_range(-0.3, 0.3))
				ms.add(p, PI * 0.5 + rng.randf_range(-0.08, 0.08), rng.randf_range(0.85, 1.1), _jc(rng, 0.05))
				var cs2 := CollisionShape3D.new()
				var bs := BoxShape3D.new()
				bs.size = Vector3(0.3, 1.0, 0.14)
				cs2.shape = bs
				cs2.position = p + Vector3(0, 0.5, 0)
				cs2.rotation.y = PI * 0.5
				body.add_child(cs2)
			x += 2.4
		z += 2.6
	_scatter(o, rng, alan, 1.2, f, 0.9, 1.4, 0.14)
	_mm(root, IstBitki.tree_mesh("servi", 0 if lod == 0 else 1), sv.xf, sv.cols, "mezarlik_servi")
	_mm(root, item("mezar"), ms.xf, ms.cols, "mezarlik_tas")
	_mm(root, item("ot"), o.xf, o.cols, "mezarlik_ot")


# ------------------------------------------------------------------ build_patch_* ve build_*
static func build_patch_bag(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "bag", alan, k, lod, tohum)
static func build_patch_bostan(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "bostan", alan, k, lod, tohum)
static func build_patch_bugday(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "bugday", alan, k, lod, tohum)
static func build_patch_cayir(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "cayir", alan, k, lod, tohum)
static func build_patch_bahce(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "bahce", alan, k, lod, tohum)
static func build_patch_sazlik(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "sazlik", alan, k, lod, tohum)
static func build_patch_kumsal(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "kumsal", alan, k, lod, tohum)
static func build_patch_kaya(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "kaya", alan, k, lod, tohum)
static func build_patch_mezarlik(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "mezarlik", alan, k, lod, tohum)
static func build_patch_patika(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "patika", alan, k, lod, tohum)
static func build_patch_toprak_yol(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "toprak_yol", alan, k, lod, tohum)
static func build_patch_tas_yol(host: Node3D, alan: Vector2, k: float = 0.5, lod: int = 0, tohum: int = 1) -> void: patch(host, "tas_yol", alan, k, lod, tohum)


static func _varsayilan(host: Node3D, tur: String, k: float, lod: int) -> void:
	patch(host, tur, TURLER[tur][1], k, lod, 1)


static func build_bag(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "bag", k, lod)
static func build_bostan(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "bostan", k, lod)
static func build_bugday(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "bugday", k, lod)
static func build_cayir(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "cayir", k, lod)
static func build_bahce(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "bahce", k, lod)
static func build_sazlik(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "sazlik", k, lod)
static func build_kumsal(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "kumsal", k, lod)
static func build_kaya(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "kaya", k, lod)
static func build_mezarlik(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "mezarlik", k, lod)
static func build_patika(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "patika", k, lod)
static func build_toprak_yol(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "toprak_yol", k, lod)
static func build_tas_yol(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _varsayilan(host, "tas_yol", k, lod)


# ------------------------------------------------------------------ kuru taş bahçe duvarı (üstü yürünür)
const DUVAR_H := 0.9

## Duvar +x boyunca uzanır, merkez tabanın ortası. Uçlarda 0,4 ve 0,7 m taş basamaklar (zıplama 0,66, basamak 0,42).
static func build_bahce_duvari(host: Node3D, k: float = 0.5, lod: int = 0, boy := 10.0) -> void:
	var root := Node3D.new()
	root.name = "bahce_duvari"
	host.add_child(root)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	var m := IstBitki.new_mesh_data()
	var cols := [Color("8c8470"), Color("a49c86"), Color("746e5c"), Color("b0a68c"), Color("9a8e78")]
	var courses := 6 if lod == 0 else 2
	var ch := DUVAR_H / courses
	for c in courses:
		var x := -boy * 0.5
		while x < boy * 0.5 - 0.05:
			var w := minf(rng.randf_range(0.35, 0.7), boy * 0.5 - x)
			var col: Color = cols[rng.randi() % cols.size()]
			var th := 0.5 - 0.02 * (c % 2)
			IstBitki.add_box(m, Vector3(x + w * 0.5, ch * (c + 0.5), 0), Vector3(w - 0.015, ch - 0.012, th), col, col.lightened(0.06))
			x += w
	# düz kapak: yürünebilir üst yüzey (kapak taşları, zeminde 2 cm pay yok; üst kat tek ince şerit olarak duvarın içinde kalır)
	var mi := MeshInstance3D.new()
	mi.mesh = IstBitki.finish(m)
	root.add_child(mi)
	var body := StaticBody3D.new()
	body.name = "duvar_katı"
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(boy, DUVAR_H, 0.5)
	cs.shape = bs
	cs.position = Vector3(0, DUVAR_H * 0.5, 0)
	body.add_child(cs)
	root.add_child(body)
	# basamaklar (iki uçta, duvarın -z yüzüne bitişik; birincisi 0,4 m, ikincisi 0,7 m)
	for sx in [-1.0, 1.0]:
		var xs: float = sx * (boy * 0.5 + 0.5)
		_solid_box(root, Vector3(1.0, 0.4, 1.0), Vector3(xs, 0.2, 0.0), Color("9a927e"))
		_solid_box(root, Vector3(0.5, 0.7, 1.0), Vector3(sx * (boy * 0.5 + 0.25) , 0.35, 0.0), Color("8c8470"))
	# otlar ve yeşil: duvar dibi ve üstünde (çarpışmasız)
	var o := Acc.new()
	for i in int(boy * 3.0 * (1.0 if lod == 0 else 0.3)):
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		o.add(Vector3(rng.randf_range(-boy * 0.5, boy * 0.5), 0, side * (0.28 + rng.randf_range(0.0, 0.2))), rng.randf() * TAU, rng.randf_range(0.8, 1.3), _jc(rng, 0.14))
	for i in int(boy * 0.8 * (1.0 if lod == 0 else 0.3)):
		o.add(Vector3(rng.randf_range(-boy * 0.5, boy * 0.5), DUVAR_H, rng.randf_range(-0.12, 0.12)), rng.randf() * TAU, rng.randf_range(0.5, 0.9), _jc(rng, 0.14))
	_mm(root, item("ot"), o.xf, o.cols, "duvar_ot")


static func climbs_bahce_duvari(k: float = 0.5, boy := 10.0) -> Array:
	return [[Vector3(-boy * 0.5 - 1.6, 0, 0), Vector3(-boy * 0.5 + 0.3, DUVAR_H, 0), "basamak"],
		[Vector3(boy * 0.5 + 1.6, 0, 0), Vector3(boy * 0.5 - 0.3, DUVAR_H, 0), "basamak"]]


static func perches_bahce_duvari(k: float = 0.5, boy := 10.0) -> Array:
	return [Vector3(0, DUVAR_H, 0)]


# ------------------------------------------------------------------ çalı çit (örgülü, katı)
static func build_cit(host: Node3D, k: float = 0.5, lod: int = 0, boy := 10.0) -> void:
	var root := Node3D.new()
	root.name = "cit"
	host.add_child(root)
	var m := IstBitki.new_mesh_data()
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var x := -boy * 0.5
	while x <= boy * 0.5 + 0.01:
		IstBitki.add_box(m, Vector3(x, 0.6, 0), Vector3(0.08, 1.2, 0.08), Color("6a4e34"), Color("8a6a48"))
		x += 1.6
	for r in 4:
		var y := 0.3 + 0.28 * r
		var xx := -boy * 0.5
		while xx < boy * 0.5:
			var w := rng.randf_range(0.5, 0.9)
			w = minf(w, boy * 0.5 - xx)
			IstBitki.add_box(m, Vector3(xx + w * 0.5, y + rng.randf_range(-0.03, 0.03), (r % 2) * 0.05 - 0.025), Vector3(w, 0.1, 0.1), Color("8a6c46").lerp(Color("a88a5c"), rng.randf()))
			xx += w
	var mi := MeshInstance3D.new()
	mi.mesh = IstBitki.finish(m)
	root.add_child(mi)
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(boy, 1.2, 0.2)
	cs.shape = bs
	cs.position = Vector3(0, 0.6, 0)
	body.add_child(cs)
	root.add_child(body)


# ------------------------------------------------------------------ su: dere (Lykos), köprü, pınar
static func water_mat() -> StandardMaterial3D:
	if _wmat == null:
		var m := StandardMaterial3D.new()
		m.albedo_color = Color(0.32, 0.55, 0.62, 0.78)
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		m.roughness = 0.2
		m.specular_mode = BaseMaterial3D.SPECULAR_TOON
		_wmat = m
	return _wmat


## Dere +x boyunca akar; sığ (bilek derinliği): su yüzeyi görsel, yürünür. Kıyıda taş, kamış ve ot.
static func build_dere(host: Node3D, k: float = 0.5, lod: int = 0, boy := 40.0, en := 4.0) -> void:
	var root := Node3D.new()
	root.name = "dere"
	host.add_child(root)
	# yatak: çamurlu taban + kıyı şeritleri (görsel) ve su yüzeyi
	var bed := PlaneMesh.new()
	bed.size = Vector2(boy, en + 1.6)
	var mb := MeshInstance3D.new()
	mb.mesh = bed
	var bm := StandardMaterial3D.new()
	bm.albedo_color = Color("7a6a48")
	bm.roughness = 1.0
	mb.material_override = bm
	mb.position.y = 0.03
	root.add_child(mb)
	var pm := PlaneMesh.new()
	pm.size = Vector2(boy, en)
	var mw := MeshInstance3D.new()
	mw.mesh = pm
	mw.material_override = water_mat()
	mw.position.y = 0.055
	mw.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mw)
	if lod >= 2:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 909
	var ky := Acc.new()
	var ka := Acc.new()
	var ot := Acc.new()
	var tas := Acc.new()
	var f := 1.0 if lod == 0 else 0.35
	for i in int(boy * 0.6 * f):
		var sd := -1.0 if rng.randf() < 0.5 else 1.0
		ky.add(Vector3(rng.randf_range(-boy * 0.5, boy * 0.5), 0, sd * (en * 0.5 + 0.8 + rng.randf_range(0.0, 1.2))), rng.randf() * TAU, rng.randf_range(0.8, 1.9), _jc(rng, 0.12))
	for i in int(boy * 1.5 * f):
		var sd2 := -1.0 if rng.randf() < 0.5 else 1.0
		ka.add(Vector3(rng.randf_range(-boy * 0.5, boy * 0.5), 0, sd2 * (en * 0.5 - 0.1 + rng.randf_range(0.0, 0.8))), rng.randf() * TAU, rng.randf_range(0.7, 1.2), _jc(rng, 0.1))
	for i in int(boy * 5.0 * f):
		var sd3 := -1.0 if rng.randf() < 0.5 else 1.0
		ot.add(Vector3(rng.randf_range(-boy * 0.5, boy * 0.5), 0, sd3 * (en * 0.5 + 0.3 + rng.randf_range(0.0, 2.5))), rng.randf() * TAU, rng.randf_range(0.9, 1.5), _jc(rng, 0.14))
	for i in int(boy * 4.0 * f):
		tas.add(Vector3(rng.randf_range(-boy * 0.5, boy * 0.5), 0.0, rng.randf_range(-en * 0.5 - 0.5, en * 0.5 + 0.5)), rng.randf() * TAU, rng.randf_range(0.7, 1.6), _jc(rng, 0.12))
	_mm(root, item("kaya"), ky.xf, ky.cols, "dere_kaya")
	_mm(root, item("kamis"), ka.xf, ka.cols, "dere_kamis")
	_mm(root, item("ot"), ot.xf, ot.cols, "dere_ot")
	_mm(root, item("tas"), tas.xf, tas.cols, "dere_tas")


## Küçük taş köprü: dere eksenine (x) dik, +z yönünde geçilir. Güverte 0,45 m, iki uçta eğim (≈ 12°), korkuluk 0,5 m.
static func build_kopru(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var root := Node3D.new()
	root.name = "kopru"
	host.add_child(root)
	var col := Color("9a927e")
	var h := 0.45
	_solid_box(root, Vector3(2.4, h, 3.6), Vector3(0, h * 0.5, 0), col)
	for sz in [-1.0, 1.0]:
		var body := StaticBody3D.new()
		var len := 2.2
		var ang := atan2(h, len)
		var ln := sqrt(len * len + h * h)
		body.position = Vector3(0, h * 0.5 - 0.05, sz * (1.8 + len * 0.5))
		body.rotation.x = -sz * ang * -1.0
		root.add_child(body)
		var m := IstBitki.new_mesh_data()
		IstBitki.add_box(m, Vector3.ZERO, Vector3(2.4, 0.1, ln), col, col.lightened(0.06))
		var mi := MeshInstance3D.new()
		mi.mesh = IstBitki.finish(m)
		body.add_child(mi)
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(2.4, 0.1, ln)
		cs.shape = bs
		body.add_child(cs)
	# korkuluk taş bloklar (güverte üstü 0,5 m)
	for sx in [-1.0, 1.0]:
		_solid_box(root, Vector3(0.3, 0.5, 3.6), Vector3(sx * 1.05, h + 0.25, 0), Color("a89e88"))
		# dereye giren su: köprü altı su yüzeyi dere sahnesinde


static func climbs_kopru(k: float = 0.5) -> Array:
	return [[Vector3(0, 0, -4.3), Vector3(0, 0.45, -1.8), "basamak"], [Vector3(0, 0, 4.3), Vector3(0, 0.45, 1.8), "basamak"]]


## Pınar: taş çeşme ocağı (1,4 × 1,0 m, 1,0 m yüksek), önünde yalak ve su aynası.
static func build_pinar(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var root := Node3D.new()
	root.name = "pinar"
	host.add_child(root)
	var st := Color("a49c86")
	_solid_box(root, Vector3(1.6, 1.3, 0.5), Vector3(0, 0.65, -0.75), st)
	_solid_box(root, Vector3(1.8, 0.14, 0.7), Vector3(0, 1.37, -0.75), Color("b8ae98"))   # alın
	_solid_box(root, Vector3(1.4, 0.4, 0.9), Vector3(0, 0.2, 0.0), st)                    # yalak
	var pm := PlaneMesh.new()
	pm.size = Vector2(1.1, 0.6)
	var mw := MeshInstance3D.new()
	mw.mesh = pm
	mw.material_override = water_mat()
	mw.position = Vector3(0, 0.395, 0.0)
	root.add_child(mw)
	var m := IstBitki.new_mesh_data()
	IstBitki.add_frustum(m, Vector3(0, 0.82, -0.47), 0.04, 0.04, 0.12, 6, Color("5a5a5a"), Color("5a5a5a"))
	IstBitki.add_box(m, Vector3(0, 0.6, -0.42), Vector3(0.04, 0.5, 0.04), Color("6aa8c0"))   # akan su şeridi
	var mi := MeshInstance3D.new()
	mi.mesh = IstBitki.finish(m)
	root.add_child(mi)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var o := Acc.new()
	for i in 14:
		o.add(Vector3(rng.randf_range(-1.1, 1.1), 0, rng.randf_range(-1.1, 0.5)), rng.randf() * TAU, rng.randf_range(0.9, 1.4), _jc(rng, 0.14))
	_mm(root, item("ot"), o.xf, o.cols, "pinar_ot")
	_mm(root, item("cakil"), [Transform3D(Basis().scaled(Vector3.ONE * 1.3), Vector3(0.5, 0.0, 0.7)), Transform3D(Basis(), Vector3(-0.6, 0, 0.8))], [Color.WHITE, Color.WHITE], "pinar_cakil")


# ------------------------------------------------------------------ harabe duvarı + sarmaşık
## Yıkık duvar parçası (5 × 3 m): moloz yığını, basamaklı yıkık üst, sarmaşık örtüsü, ot. Katı; yıkık üst yürünebilir.
static func build_sarmasik(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var root := Node3D.new()
	root.name = "sarmasik_harabe"
	host.add_child(root)
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	var stone := Color("a0866a")
	# basamaklı yıkık: sağdan sola 0,35 / 0,7 / 1,05 / 1,6 / 2,3 / 3,0 m (her adım ≤ 0,42..0,7: zıplamalı)
	var hs := [0.35, 0.7, 1.05, 1.6, 2.1, 2.7]
	var x0 := -2.5
	for i in 6:
		var w := 0.8 if i < 5 else 0.9
		var x := x0 + i * 0.8 + w * 0.5
		_solid_box(root, Vector3(w, hs[5 - i], 0.8), Vector3(x, hs[5 - i] * 0.5, 0), stone.lerp(Color("c4a888"), rng.randf() * 0.5))
	var o := Acc.new()
	var iv := Acc.new()
	var f := 1.0 if lod == 0 else 0.3
	for i in int(60 * f):
		var ix := rng.randf_range(-2.5, 2.3)
		var hh: float = hs[5 - clampi(int((ix + 2.5) / 0.8), 0, 5)]
		iv.add(Vector3(ix, hh * rng.randf_range(0.2, 1.0), 0.42 * (1.0 if rng.randf() < 0.5 else -1.0)), rng.randf() * TAU, rng.randf_range(0.8, 1.6), _jc(rng, 0.12), 1.0)
	for i in int(40 * f):
		var ix2 := rng.randf_range(-2.5, 2.3)
		var hh2: float = hs[5 - clampi(int((ix2 + 2.5) / 0.8), 0, 5)]
		o.add(Vector3(ix2, hh2, rng.randf_range(-0.3, 0.3)), rng.randf() * TAU, rng.randf_range(0.8, 1.4), _jc(rng, 0.14))
	for i in int(30 * f):
		o.add(Vector3(rng.randf_range(-3.0, 3.0), 0, rng.randf_range(-1.1, 1.1)), rng.randf() * TAU, rng.randf_range(0.9, 1.4), _jc(rng, 0.14))
	_mm(root, item("yaprak_sarmasik"), iv.xf, iv.cols, "sarmasik")
	_mm(root, item("ot"), o.xf, o.cols, "harabe_ot")
	_mm(root, item("tas"), [Transform3D(Basis(), Vector3(2.9, 0, 0.6)), Transform3D(Basis(), Vector3(3.1, 0, -0.3)), Transform3D(Basis(), Vector3(2.7, 0, -0.7))], [Color.WHITE, Color.WHITE, Color.WHITE], "moloz")
