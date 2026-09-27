class_name GalataView
extends RefCounted
## Uzaktan (80–200 m) görülen Galata (1453): tepeye tırmanan Ceneviz kasabası. Sıkışık evler (kiremit çatı, gece
## yanan pencereler), yamaca tırmanan surlar ve burçlar, rıhtım ve direkler, tepede Galata Kulesi (Christea Turris:
## taş gövde, mazgallı şerefe, konik külah, Ceneviz bayrağı). Bütün parçalar tek birleşik ağda (Dressing): ucuz.
##
## hf(x, z): zemin yüksekliği. tower_xz: kulenin yeri; top_y: kule ucundaki fenerin yüksekliği (tespit noktası).
## center_xz / radius: kasabanın merkezi ve yarıçapı (surlar bu çemberde); sea_y: deniz seviyesi (rıhtım için).

const STONE := Color("6e6a64")
const STONE_DARK := Color("4e4b48")
const ROOF := Color("7a3a2c")
const WIN := Color("ffc870")


static func build(parent: Node3D, hf: Callable, tower_xz: Vector2, top_y: float, center_xz: Vector2, radius: float,
		sea_y := 0.0, seed := 1453, night := true) -> void:
	var d := Dressing.new(seed)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var plasters := [Color("8a8272"), Color("7e6e5e"), Color("927a66"), Color("857e70"), Color("6e6658")]
	if not night:
		plasters = [Color("e8d8b8"), Color("d8b890"), Color("c8a888"), Color("e0c8a8"), Color("d0b8a0")]
	# --- Evler: merkezden dışa, zemin denizin üstündeyse; kuleye çok yakın olmasın
	var placed := 0
	var tries := 0
	while placed < 240 and tries < 3000:
		tries += 1
		var a := rng.randf() * TAU
		var r := sqrt(rng.randf()) * radius * 0.95
		var x := center_xz.x + cos(a) * r
		var z := center_xz.y + sin(a) * r
		var gy: float = hf.call(x, z)
		if gy < sea_y + 0.6:
			continue
		if Vector2(x, z).distance_to(tower_xz) < 7.0:
			continue
		var w := rng.randf_range(3.5, 6.0)
		var dp := rng.randf_range(3.5, 6.0)
		var h := rng.randf_range(4.5, 9.0)
		var yaw := rng.randf_range(-12, 12) + (90.0 if rng.randf() < 0.5 else 0.0)
		var c: Color = plasters[rng.randi() % plasters.size()]
		var base := gy - 1.5          # yamaçta gömülsün (alt boşluk kalmasın)
		var hh := h + 1.5
		d.box(Vector3(w, hh, dp), Vector3(x, base + hh * 0.5, z), c, Vector3(0, yaw, 0))
		d.prism(Vector3(w + 0.6, 1.6, dp + 0.6), Vector3(x, base + hh + 0.8, z), ROOF.lightened(rng.randf() * 0.1), Vector3(0, yaw, 0))
		# Pencereler: gece bir kısmı yanar (sıcak ışık), gündüz koyu
		var wn := rng.randi_range(1, 3)
		var fb := Basis(Vector3.UP, deg_to_rad(yaw))
		for k in wn:
			var side := 1.0 if rng.randf() < 0.5 else -1.0
			var off := fb * Vector3(rng.randf_range(-w * 0.35, w * 0.35), 0, side * (dp * 0.5 + 0.03))
			var wy := base + 1.5 + rng.randf_range(1.2, h - 1.5)
			if night and rng.randf() < 0.55:
				d.glow(Vector3(0.6, 0.8, 0.6) * Vector3(1, 1, 0.1) + Vector3(0, 0, 0.05), Vector3(x, wy, z) + off, WIN)
			else:
				d.box(Vector3(0.6, 0.8, 0.08), Vector3(x, wy, z) + off, Color("1a1814"), Vector3(0, yaw, 0))
		placed += 1
	# --- Surlar: kasabayı çeviren çember (yamaca tırmanır), her 22 m'de bir burç; denizde kalan dilimler atlanır
	var seg := 40
	for i in seg:
		var a0 := TAU * i / seg
		var a1 := TAU * (i + 1) / seg
		var p0 := center_xz + Vector2(cos(a0), sin(a0)) * radius
		var p1 := center_xz + Vector2(cos(a1), sin(a1)) * radius
		var mid := (p0 + p1) * 0.5
		var gy: float = hf.call(mid.x, mid.y)
		if gy < sea_y - 0.5:
			continue
		var gy0 := maxf(gy, sea_y)
		var ln := p0.distance_to(p1) + 0.4
		var yaw := rad_to_deg(atan2(p1.x - p0.x, p1.y - p0.y)) + 90.0
		var wh := 4.5
		d.box(Vector3(ln, wh + 2.0, 1.8), Vector3(mid.x, gy0 - 2.0 + (wh + 2.0) * 0.5, mid.y), STONE, Vector3(0, yaw, 0))
		# Mazgallar
		var dirv := (p1 - p0).normalized()
		for k in int(ln / 1.6):
			var q := p0 + dirv * (0.8 + k * 1.6)
			d.box(Vector3(0.7, 0.8, 1.9), Vector3(q.x, gy0 + wh + 0.4, q.y), STONE, Vector3(0, yaw, 0))
		if i % 3 == 0:
			d.box(Vector3(3.6, wh + 4.0, 3.6), Vector3(p0.x, gy0 - 2.0 + (wh + 4.0) * 0.5, p0.y), STONE_DARK, Vector3(0, yaw, 0))
			for k in 4:
				var o := Basis(Vector3.UP, deg_to_rad(yaw)) * Vector3(-1.4 + (k % 2) * 2.8, 0, -1.4 + (k / 2) * 2.8)
				d.box(Vector3(0.8, 0.8, 0.8), Vector3(p0.x, gy0 + wh + 2.4, p0.y) + o, STONE_DARK)
			if night and rng.randf() < 0.6:
				d.glow(Vector3(0.5, 0.5, 0.5), Vector3(p0.x, gy0 + wh + 3.3, p0.y), Color("ffb050"))
	# --- Rıhtım: deniz kıyısında ahşap iskele, fenerler, demirli gemilerin direkleri
	var quay := 0
	for i in 72:
		var a := TAU * i / 72.0
		var p := center_xz + Vector2(cos(a), sin(a)) * radius * 1.12
		var gy: float = hf.call(p.x, p.y)
		if absf(gy - sea_y) > 1.5 or quay > 14:
			continue
		quay += 1
		d.box(Vector3(6.0, 0.4, 2.2), Vector3(p.x, sea_y + 0.5, p.y), Color("4a3422"), Vector3(0, rad_to_deg(-a), 0))
		if night and quay % 3 == 0:
			d.glow(Vector3(0.35, 0.45, 0.35), Vector3(p.x, sea_y + 1.8, p.y), Color("ffc060"))
		if quay % 2 == 0:
			var mp := center_xz + Vector2(cos(a), sin(a)) * (radius * 1.12 + rng.randf_range(6.0, 12.0))
			d.cyl(0.18, 11.0, Vector3(mp.x, sea_y + 5.5, mp.y), Color("2e2620"), Vector3.ZERO, 5)
			d.box(Vector3(0.12, 0.12, 5.0), Vector3(mp.x, sea_y + 8.5, mp.y), Color("2e2620"), Vector3(0, rad_to_deg(-a) + rng.randf_range(-20, 20), 20))
			d.box(Vector3(9.0, 1.4, 2.6), Vector3(mp.x, sea_y + 0.4, mp.y), Color("2a1e16"), Vector3(0, rad_to_deg(-a) + 90.0, 0))
	# --- Galata Kulesi: taş gövde, şerefe (çıkma + mazgal), konik külah, bayrak; fener top_y'de (külah altında, şerefede)
	var ty: float = hf.call(tower_xz.x, tower_xz.y) - 1.0
	var gallery_y := top_y - 1.2
	var body_h := gallery_y - ty
	d.cyl(4.2, body_h, Vector3(tower_xz.x, ty + body_h * 0.5, tower_xz.y), STONE, Vector3.ZERO, 14)
	for k in 3:   # kat bantları
		d.cyl(4.35, 0.4, Vector3(tower_xz.x, ty + body_h * (0.3 + k * 0.22), tower_xz.y), STONE_DARK, Vector3.ZERO, 14)
	for k in 8:   # dar pencereler (gece bazıları yanar)
		var a := TAU * k / 8.0 + 0.3
		var wp := Vector3(tower_xz.x + cos(a) * 4.22, ty + body_h * (0.45 + (k % 3) * 0.14), tower_xz.y + sin(a) * 4.22)
		if night and k % 2 == 0:
			d.glow(Vector3(0.5, 1.2, 0.5), wp, WIN)
		else:
			d.box(Vector3(0.5, 1.2, 0.5), wp, Color("1a1814"))
	d.cyl(5.2, 1.0, Vector3(tower_xz.x, gallery_y - 0.5, tower_xz.y), STONE_DARK, Vector3.ZERO, 16)   # şerefe çıkması
	for k in 14:
		var a := TAU * k / 14.0
		d.box(Vector3(0.9, 1.1, 0.5), Vector3(tower_xz.x + cos(a) * 5.0, gallery_y + 0.55, tower_xz.y + sin(a) * 5.0), STONE, Vector3(0, rad_to_deg(-a) + 90.0, 0))
	d.cyl(3.6, 3.0, Vector3(tower_xz.x, gallery_y + 1.5, tower_xz.y), STONE, Vector3.ZERO, 14)          # şerefe odası
	d.cyl(4.4, 7.5, Vector3(tower_xz.x, gallery_y + 3.0 + 3.75, tower_xz.y), Color("3c4250"), Vector3.ZERO, 14, 0.02)   # külah
	d.cyl(0.08, 3.0, Vector3(tower_xz.x, gallery_y + 11.5, tower_xz.y), Color("2a2a2a"), Vector3.ZERO, 4)
	d.box(Vector3(0.04, 1.2, 1.9), Vector3(tower_xz.x, gallery_y + 12.3, tower_xz.y + 0.95), Color("f0ece4"))   # Ceneviz bayrağı
	d.box(Vector3(0.05, 1.2, 0.26), Vector3(tower_xz.x, gallery_y + 12.3, tower_xz.y + 0.95), Color("c8262f"))
	d.box(Vector3(0.05, 0.24, 1.9), Vector3(tower_xz.x, gallery_y + 12.3, tower_xz.y + 0.95), Color("c8262f"))
	d.build(parent)
