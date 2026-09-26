class_name Street2026
extends RefCounted
## 2026 İstanbul sokağı (gece): Hikmet'in garajı üç katlı bir apartmanın zemin katında; iki yanında bitişik
## apartmanlar, zemin katlarında kepenkli dükkânlar; balkonlar, klimalar, çanak antenler, çamaşır ipleri,
## park etmiş araba, çöp konteyneri, kedi. Yalnız görsel (çarpışma yok): garajın içinden görünmez.
## front_z: garajın dış cephesinin z'si (Bölüm 5: Garage.D / 2 + 0.2).

const FLOOR_H := 3.0
const PLASTERS := [Color("c9b79c"), Color("b8a58a"), Color("d4c4a8"), Color("a89880"), Color("c2a88a"), Color("9fa3a0"), Color("d8c0a0")]


static func build(parent: Node3D, front_z: float, seed := 2026) -> Node3D:
	var root := Node3D.new()
	root.name = "Street2026"
	parent.add_child(root)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	# Hikmet'in apartmanı: garajın üstünde iki kat (garaj cephesi 8.6 m, yüksekliği 3.8 m)
	var gw := Garage.W + 0.6
	var gh := Garage.H + 0.6
	_upper(root, 0.0, gw, gh, 2, Color("cbb89a"), front_z, rng, true)
	# Sol ve sağ: bitişik apartmanlar (sokak boyunca)
	var x := -gw / 2.0
	var shops := ["BAKKAL", "BERBER", "EMLAK", "KUAFÖR", "TERZİ", "ELEKTRİKÇİ"]
	var si := 0
	for side in [-1, 1]:
		x = side * gw / 2.0
		for k in 3:
			var w := rng.randf_range(7.0, 9.5)
			var floors := rng.randi_range(3, 5)
			var cx: float = x + side * w / 2.0
			var col: Color = PLASTERS[rng.randi() % PLASTERS.size()]
			_shop(root, cx, w, col, front_z, shops[si % shops.size()], rng)
			si += 1
			_upper(root, cx, w, FLOOR_H + 0.4, floors - 1, col, front_z, rng, false)
			# Binalar arasında ince derz (bitişik nizam)
			Props.box(root, Vector3(0.12, (floors) * FLOOR_H + 0.6, 0.3), Vector3(x + side * w, (floors * FLOOR_H + 0.6) / 2.0, front_z + 0.05), col.darkened(0.35))
			x += side * w
	_street_life(root, front_z, rng)
	Props.strip_outlines(root)
	return root


## Zemin katta kepenkli dükkân (gece kapalı), tabela, yanında apartman kapısı.
static func _shop(root: Node3D, cx: float, w: float, col: Color, z: float, sign_text: String, rng: RandomNumberGenerator) -> void:
	var h := FLOOR_H + 0.4
	Props.box(root, Vector3(w, h, 8.0), Vector3(cx, h / 2.0, z - 4.0), col.darkened(0.12))
	# Kepenk (yatay oluklu) ve kilit
	var sw := w * 0.58
	var sx := cx - w * 0.14
	for i in 8:
		Props.box(root, Vector3(sw, 0.3, 0.05), Vector3(sx, 0.18 + i * 0.33, z + 0.06), Color("8d959f") if i % 2 == 0 else Color("7f8791"))
	Props.box(root, Vector3(sw + 0.2, 0.3, 0.2), Vector3(sx, 2.85, z + 0.1), Color("5a6068"))
	Props.box(root, Vector3(0.12, 0.08, 0.06), Vector3(sx, 0.2, z + 0.1), Color("c8a040"))
	# Tabela (ışıksız: gece kapalı), grafiti
	Props.box(root, Vector3(sw, 0.55, 0.08), Vector3(sx, 3.25, z + 0.08), Color("2a3a5a") if rng.randf() < 0.5 else Color("6a2a2a"))
	Props.label(root, sign_text, Vector3(sx, 3.25, z + 0.13), 44, Color("f2e6c9"), Vector3.ZERO, sw * 0.9)
	if rng.randf() < 0.5:
		Props.box(root, Vector3(0.9, 0.35, 0.02), Vector3(sx + rng.randf_range(-0.8, 0.8), 1.0, z + 0.1), [Color("3a8a5a"), Color("c8503a"), Color("3a5aa8")][rng.randi() % 3], Vector3(0, 0, rng.randf_range(-8, 8)))
	# Apartman kapısı: camlı alüminyum, üstünde numara ve lamba
	var dx := cx + w * 0.34
	Props.box(root, Vector3(1.1, 2.3, 0.08), Vector3(dx, 1.15, z + 0.05), Color("3a3f48"))
	var glass := Props.box(root, Vector3(0.8, 1.7, 0.02), Vector3(dx, 1.25, z + 0.1), Color("ffd08a"), Vector3.ZERO, 0.6)
	glass.material_override = Props.mat(Color("f0c070"), 0.5, false, "", false)
	Props.box(root, Vector3(0.3, 0.2, 0.03), Vector3(dx, 2.55, z + 0.1), Color("2a5a9a"))
	Props.label(root, "No: %d" % rng.randi_range(3, 41), Vector3(dx, 2.55, z + 0.12), 20, Color.WHITE, Vector3.ZERO, 0.28)
	Props.box(root, Vector3(1.4, 0.12, 0.6), Vector3(dx, 0.06, z + 0.3), Color("9a968c"))


## Üst katlar: pencereler (bazısı ışıklı, perdeli), balkonlar, klimalar, çatıda çanak anten ve su deposu.
static func _upper(root: Node3D, cx: float, w: float, base_y: float, floors: int, col: Color, z: float,
		rng: RandomNumberGenerator, hikmet: bool) -> void:
	var h := floors * FLOOR_H
	var body := Props.box(root, Vector3(w, h, 8.0), Vector3(cx, base_y + h / 2.0, z - 4.0), col)
	body.material_override = Props.mat(col, 0.0, false, "plaster", false)
	# Kat silmeleri
	for f in floors + 1:
		Props.box(root, Vector3(w + 0.1, 0.14, 0.2), Vector3(cx, base_y + f * FLOOR_H, z + 0.05), col.lightened(0.15))
	var n := maxi(2, int(w / 2.4))
	for f in floors:
		var fy := base_y + f * FLOOR_H + 1.55
		var balcony := (f == 0 and hikmet) or rng.randf() < 0.35
		if balcony:
			var bw := w * 0.6
			Props.box(root, Vector3(bw, 0.15, 1.0), Vector3(cx, fy - 1.45, z + 0.5), Color("9a968c"))
			for b in int(bw / 0.14):
				Props.box(root, Vector3(0.03, 0.9, 0.03), Vector3(cx - bw / 2.0 + 0.07 + b * 0.14, fy - 0.95, z + 0.98), Color("2a2c30"))
			Props.box(root, Vector3(bw, 0.05, 0.05), Vector3(cx, fy - 0.5, z + 0.98), Color("2a2c30"))
			if rng.randf() < 0.6 or hikmet:
				# Çamaşır ipi ve çamaşırlar
				Props.cyl(root, 0.006, bw * 0.9, Vector3(cx, fy + 0.35, z + 0.8), Color("d0d0d0"), Vector3(0, 0, 90), 3)
				for c in 4:
					Props.box(root, Vector3(0.35, 0.45, 0.02), Vector3(cx - bw * 0.35 + c * bw * 0.22, fy + 0.1, z + 0.8),
						[Color("e8e0d0"), Color("5a7ab0"), Color("c84a3a"), Color("e8c050")][(c + f) % 4])
			if hikmet:
				# Hikmet'in balkonu: saksıda sardunya, eski sandalye
				for p in 3:
					Props.cyl(root, 0.12, 0.2, Vector3(cx - 1.2 + p * 0.5, fy - 1.28, z + 0.75), Color("b8603a"), Vector3.ZERO, 8, 0.15)
					Props.ball(root, 0.16, Vector3(cx - 1.2 + p * 0.5, fy - 1.05, z + 0.75), Color("3a7a3a"), Vector3(1, 0.8, 1), 6)
					Props.ball(root, 0.06, Vector3(cx - 1.2 + p * 0.5, fy - 0.92, z + 0.78), Color("d8303a"), Vector3.ONE, 5)
				Props.box(root, Vector3(0.45, 0.05, 0.45), Vector3(cx + 1.0, fy - 1.0, z + 0.55), Color("6b4428"))
		for k in n:
			var wx := cx - w / 2.0 + (k + 0.5) * w / n
			var lit := rng.randf() < (0.35 if hikmet and f == 0 else 0.18)
			var wc := Color("ffcf7a") if lit else Color("1c2230")
			var win := Props.box(root, Vector3(1.1, 1.4, 0.05), Vector3(wx, fy, z + 0.03), wc)
			win.material_override = Props.mat(wc, 1.4 if lit else 0.0, false, "", false)
			Props.box(root, Vector3(1.24, 0.08, 0.14), Vector3(wx, fy - 0.74, z + 0.08), Color("e8e4dc"))
			Props.box(root, Vector3(0.05, 1.4, 0.07), Vector3(wx, fy, z + 0.07), Color("e8e4dc"))
			if lit and rng.randf() < 0.6:
				Props.box(root, Vector3(0.5, 1.3, 0.02), Vector3(wx - 0.28, fy, z + 0.06), Color("c88a5a"))
			if rng.randf() < 0.25 and not balcony:
				# Klima dış ünitesi
				Props.box(root, Vector3(0.8, 0.55, 0.3), Vector3(wx + 0.2, fy - 1.1, z + 0.18), Color("e4e4e0"))
				Props.cyl(root, 0.2, 0.02, Vector3(wx + 0.05, fy - 1.1, z + 0.34), Color("6a6a6a"), Vector3(90, 0, 0), 10)
	# Çatı: kiremit ya da düz dam (su deposu, çanak anten)
	var top := base_y + h
	if rng.randf() < 0.55 or hikmet:
		var roof := MeshInstance3D.new()
		var pm := PrismMesh.new()
		pm.size = Vector3(w + 0.4, 1.6, 8.4)
		roof.mesh = pm
		roof.position = Vector3(cx, top + 0.8, z - 4.0)
		roof.material_override = Props.mat(Color("a8503a"), 0.0, false, "tiles", false)
		root.add_child(roof)
	else:
		Props.box(root, Vector3(w, 0.8, 0.2), Vector3(cx, top + 0.4, z + 0.0), col.darkened(0.1))
		Props.cyl(root, 0.5, 1.0, Vector3(cx + w * 0.25, top + 0.5, z - 2.0), Color("d8d8d0"), Vector3(90, 0, 0), 10)
	# Çanak anten
	var dish := Vector3(cx - w * 0.3, top + 0.9, z - 0.6)
	Props.ball(root, 0.35, dish, Color("dcdcd8"), Vector3(1, 1, 0.3), 8)
	Props.cyl(root, 0.02, 0.5, dish + Vector3(0, -0.4, -0.1), Color("6a6a6a"), Vector3.ZERO, 4)
	if hikmet:
		# Hikmet'in çatısı: kendi yaptığı tel anten (radyocu)
		Props.cyl(root, 0.025, 2.4, Vector3(cx + 2.0, top + 2.0, z - 3.0), Color("8a8f99"), Vector3.ZERO, 4)
		for a in 3:
			Props.cyl(root, 0.012, 1.4, Vector3(cx + 2.0, top + 2.6 + a * 0.4, z - 3.0), Color("8a8f99"), Vector3(0, a * 60, 90), 3)


## Sokak: park etmiş araba, çöp konteyneri, kedi, elektrik direği ve kabloları.
static func _street_life(root: Node3D, z: float, rng: RandomNumberGenerator) -> void:
	# Araba (garajın solunda, kaldırım kenarında)
	var car := Node3D.new()
	car.position = Vector3(-9.5, 0, z + 2.9)
	root.add_child(car)
	var cc: Color = [Color("8a2b22"), Color("2f4f7a"), Color("d8d4c8")][rng.randi() % 3]
	Props.box(car, Vector3(4.2, 0.7, 1.75), Vector3(0, 0.6, 0), cc)
	Props.box(car, Vector3(2.3, 0.6, 1.6), Vector3(-0.2, 1.2, 0), cc.darkened(0.05))
	for sx in [-1, 1]:
		Props.box(car, Vector3(0.05, 0.45, 1.5), Vector3(sx * 1.15 - 0.2, 1.22, 0), Color("1a2230"), Vector3(0, 0, sx * -18))
		for sz in [-1, 1]:
			Props.cyl(car, 0.33, 0.24, Vector3(sx * 1.35, 0.33, sz * 0.8), Color("15171c"), Vector3(90, 0, 0), 10)
	Props.box(car, Vector3(2.2, 0.45, 0.04), Vector3(-0.2, 1.22, 0.8), Color("1a2230"))
	Props.box(car, Vector3(2.2, 0.45, 0.04), Vector3(-0.2, 1.22, -0.8), Color("1a2230"))
	# Çöp konteyneri
	Props.box(root, Vector3(1.4, 1.1, 1.0), Vector3(7.2, 0.6, z + 2.5), Color("3a5a3a"))
	Props.box(root, Vector3(1.45, 0.08, 1.05), Vector3(7.2, 1.2, z + 2.45), Color("2a4a2a"), Vector3(-10, 0, 0))
	# Kedi (konteynerin üstünde)
	var cat := Vector3(7.0, 1.36, z + 2.5)
	Props.ball(root, 0.16, cat, Color("d8883a"), Vector3(1.0, 0.7, 1.5), 8)
	Props.ball(root, 0.1, cat + Vector3(0.22, 0.1, 0), Color("d8883a"), Vector3.ONE, 6)
	# Elektrik direği ve sarkan kablolar
	Props.cyl(root, 0.12, 8.0, Vector3(5.0, 4.0, z + 2.0), Color("5a4a3a"), Vector3.ZERO, 6)
	Props.box(root, Vector3(1.6, 0.1, 0.1), Vector3(5.0, 7.6, z + 2.0), Color("5a4a3a"))
	for k in 3:
		Props.cyl(root, 0.01, 14.0, Vector3(-2.0, 7.3 - k * 0.3, z + 2.0 - k * 0.1), Color("1a1a1a"), Vector3(0, 0, 90 - k * 1.5), 3)
