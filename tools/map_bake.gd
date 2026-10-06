extends Node
## Haritayı pişirir (v0.90): World1453'ün su, kara, şehir ve tepe verisinden; CityPlan'ın sokak, meydan ve evlerinden;
## anıtların tabanlarından ve surlardan (kapılar boşluk) tek bir doku üretir: assets/ui/map1453.png. Oyunda MiniMap (sağ
## alt) ve WorldMap (M) bu dokuyu kullanır; dünyadan haritaya dönüşüm MapView'dadır (kuzey yukarı: dünya −x yukarı,
## −z sağa).
##     godot --headless --path . res://tools/map_bake.tscn
## (sahne olarak: dünya kodu autoload'lara, GameState ve Audio'ya dayanır; --script kipinde onlar yok)
## Dünya değişirse (kıyı, sur, sokak ağı) yeniden pişirilir; MAPCHECK (tests/map_check) dokunun dünyayla uyuştuğunu sınar.

const OUT := "res://assets/ui/map1453.png"

# Parşömen renkleri: eski bir haritanın sıcaklığı, oyunun gündüz renklerine yakın
const C_SEA := Color("57849c")
const C_SHALLOW := Color("74a0b2")
const C_LAND := Color("c4bb8e")
const C_ASIA := Color("bbb88c")
const C_CITY := Color("ddd0ad")
const C_HOUSE := Color("b48f68")
const C_LANE := Color("ebe1c4")
const C_ROAD := Color("f3ead2")
const C_MESE := Color("faf3e0")
const C_PLAZA := Color("e9ddbb")
const C_MONUMENT := Color("9a6a52")
const C_MONUMENT_FILL := Color("dcbb94")
const C_WALL := Color("5a4636")
const C_TOWER := Color("46362a")
const C_MOAT := Color("7d8a62")
const C_CHAIN := Color("33302c")
const C_BRIDGE := Color("7a5a3a")
const C_TENT := Color("e8dcc0")
const C_OTAG := Color("b8423a")

const GATE_GAP := 9.0       # kapının surda bıraktığı boşluk (m)

var img: Image


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	var w := MapView.W
	var h := MapView.H
	img = Image.create(w, h, false, Image.FORMAT_RGB8)
	# 1. Zemin: su, kara, şehir; yükseklik (tepe gölgesi için)
	var hgt := PackedFloat32Array()
	hgt.resize(w * h)
	var kind := PackedByteArray()          # 0 su, 1 kara, 2 şehir, 3 Asya
	kind.resize(w * h)
	for py in h:
		if py % 200 == 0:
			print("satır %d/%d (%d ms)" % [py, h, Time.get_ticks_msec() - t0])
		for px in w:
			var p := MapView.pixel_world(Vector2(px + 0.5, py + 0.5))
			var i := py * w + px
			if World1453.is_water(p.x, p.y):
				kind[i] = 0
				continue
			kind[i] = 2 if World1453.in_city(p.x, p.y) else (3 if p.y < World1453.asia_z(p.x) else 1)
			hgt[i] = World1453.ground_h(p.x, p.y)
	print("zemin %d ms" % (Time.get_ticks_msec() - t0))
	for py in h:
		for px in w:
			var i := py * w + px
			var k := kind[i]
			if k == 0:
				# Kıyıya 4 piksel (6 m) yakın su açık renk
				var near := false
				for d: Vector2i in [Vector2i(-4, 0), Vector2i(4, 0), Vector2i(0, -4), Vector2i(0, 4), Vector2i(-2, -2), Vector2i(2, 2),
						Vector2i(-2, 2), Vector2i(2, -2)]:
					var qx := clampi(px + d.x, 0, w - 1)
					var qy := clampi(py + d.y, 0, h - 1)
					if kind[qy * w + qx] != 0:
						near = true
						break
				img.set_pixel(px, py, C_SHALLOW if near else C_SEA)
				continue
			var base: Color = [C_SEA, C_LAND, C_CITY, C_ASIA][k]
			# Tepe gölgesi: ışık kuzeybatıdan (haritada sol üst)
			var hl := hgt[py * w + maxi(px - 1, 0)]
			var hu := hgt[maxi(py - 1, 0) * w + px]
			var hr := hgt[py * w + mini(px + 1, w - 1)]
			var hd := hgt[mini(py + 1, h - 1) * w + px]
			var s := clampf(1.0 + 0.35 * ((hl - hr) + (hu - hd)), 0.8, 1.16)
			img.set_pixel(px, py, Color(base.r * s, base.g * s, base.b * s))
	print("gölge %d ms" % (Time.get_ticks_msec() - t0))
	# 2. Galata (Ceneviz kasabası), ordugâh ve otağ
	var gc: Vector3 = World1453.LANDMARKS["galata_center"]
	_disc_land(Vector2(gc.x, gc.z), 150.0, C_CITY)
	_ring(Vector2(gc.x, gc.z), 150.0, 3.0, C_WALL)          # Galata'nın suru
	var rng := RandomNumberGenerator.new()
	rng.seed = 90
	for i in 260:
		var a := rng.randf() * TAU
		var r := sqrt(rng.randf()) * 140.0
		var c := Vector2(gc.x + cos(a) * r, gc.z + sin(a) * r)
		if not World1453.is_water(c.x, c.y):
			_box(c, Vector2(cos(a), sin(a)), rng.randf_range(2.6, 4.2), rng.randf_range(2.6, 4.0), C_HOUSE)
	for i in 900:
		var c := Vector2(rng.randf_range(-480.0, 640.0), rng.randf_range(180.0, 900.0))
		if Vector2(c.x - 30.0, c.y - 480.0).length() > 40.0 and not World1453.is_water(c.x, c.y):
			_disc(c, rng.randf_range(2.0, 3.4), C_TENT)
	_disc(Vector2(30.0, 480.0), 14.0, C_OTAG)
	print("galata ve ordugâh %d ms" % (Time.get_ticks_msec() - t0))
	# 3. Evler (yönlü dikdörtgen), anıt tabanları
	for hs: Dictionary in CityPlan.houses_in(-INF, INF):
		var sz: Vector3 = hs["s"]
		var yaw: float = hs["yaw"]
		_box(hs["c"], Vector2(cos(yaw), -sin(yaw)), sz.x * 0.5, sz.z * 0.5, C_HOUSE)
	print("evler %d ms" % (Time.get_ticks_msec() - t0))
	# 4. Sokaklar ve meydanlar: önce ara sokaklar, sonra yollar, en üstte Mese
	var g := CityPlan.graph()
	var nodes: PackedVector3Array = g["nodes"]
	var edges: Array = g["edges"]
	var widths: PackedFloat32Array = g["width"]
	var kinds: PackedInt32Array = g["kind"]
	for pass_k: int in [CityPlan.LANE, CityPlan.ROAD, CityPlan.MESE]:
		for ei in edges.size():
			if kinds[ei] != pass_k:
				continue
			var e: Vector2i = edges[ei]
			var a := Vector2(nodes[e.x].x, nodes[e.x].z)
			var b := Vector2(nodes[e.y].x, nodes[e.y].z)
			var col: Color = {CityPlan.MESE: C_MESE, CityPlan.ROAD: C_ROAD, CityPlan.LANE: C_LANE}[pass_k]
			_seg(a, b, maxf(widths[ei], 2.4), col)
	for pl: Dictionary in CityPlan.plazas():
		var p: Vector3 = pl["pos"]
		_disc(Vector2(p.x, p.z), pl["r"], C_PLAZA)
	# Anıtlar plan gibi: açık dolgu, koyu çizgi (yalnız karada); Ayasofya'nın kubbesi, Hipodrom'un spinası
	for f: Dictionary in Landmarks1453.footprints():
		if f.has("box"):
			var bx: Array = f["box"]
			var c: Vector2 = bx[0]
			var u: Vector2 = bx[1]
			var hu: float = bx[2]
			var hv: float = bx[3]
			_box(c, u, hu, hv, C_MONUMENT_FILL, true)
			var v := Vector2(-u.y, u.x)
			var k := [c + u * hu + v * hv, c - u * hu + v * hv, c - u * hu - v * hv, c + u * hu - v * hv]
			for j in 4:
				_seg_land(k[j], k[(j + 1) % 4], 1.8, C_MONUMENT)
			match String(f["key"]):
				"ayasofya":
					_disc(c, 15.0, C_MONUMENT)
				"hippodrome":
					var long := u if hu > hv else v
					_seg_land(c - long * maxf(hu, hv) * 0.7, c + long * maxf(hu, hv) * 0.7, 3.0, C_MONUMENT)
		else:
			_disc(f["c"], float(f["r"]) * 0.6, C_MONUMENT_FILL)
			_ring(f["c"], float(f["r"]) * 0.6, 1.8, C_MONUMENT)
	for l: Dictionary in Landmarks1453.all():
		var p: Vector3 = l["pos"]
		if not World1453.in_city(p.x, p.z):
			_disc(Vector2(p.x, p.z), 7.0, C_MONUMENT)
	print("sokaklar %d ms" % (Time.get_ticks_msec() - t0))
	# 5. Surlar. Kara surları: hendek (z 20–36), dış sur (z 15), iç sur ve kuleleri (z −2,3); kapılar boşluk, hendeğin
	# üstünde geçit
	var wx0 := World1453.WALL_N_X
	var gates: Array = World1453.LAND_GATES
	_wall_x(28.0, wx0, 700.0, 14.0, C_MOAT, gates)
	_wall_x(15.0, wx0, 700.0, 3.0, C_WALL, gates)
	_wall_x(-2.3, wx0, 700.0, 5.0, C_WALL, gates)
	var tx := wx0 + 20.0
	while tx <= 690.0:
		if _clear_of(tx, gates, GATE_GAP + 6.0):
			_disc(Vector2(tx, -2.3), 5.0, C_TOWER)
		tx += 55.0
	for gx: float in gates:
		_seg(Vector2(gx, 20.0), Vector2(gx, 36.0), 5.0, C_LAND)          # hendeğin üstündeki geçit
	# Blakherna: kara surlarının kuzey ucundan Haliç'e
	_seg(Vector2(World1453.HORN_S_X + 4.0, World1453.HORN_IN_Z), Vector2(wx0, 0.0), 5.0, C_WALL)
	# Haliç surları (kapılar: HORN_GATE_Z ve Petrion), burnun dönüşü, Marmara surları (kesir kapıları)
	var hx := World1453.HORN_S_X + 4.0
	var hgates: Array = World1453.HORN_GATE_Z.duplicate()
	hgates.append((World1453.LANDMARKS["petrion_gate"] as Vector3).z)
	_wall_z(hx, World1453.HORN_IN_Z, World1453.SHORE_END_Z, 3.5, C_WALL, hgates)
	var tip := Vector2(World1453.TIP.x, World1453.TIP.z + 6.0)
	_seg(Vector2(hx, World1453.SHORE_END_Z), tip, 3.5, C_WALL)
	var m0 := Vector2(700.0 - 5.0, 0.0)
	var marm_gaps: Array = []
	for f: float in World1453.MARMARA_GATES:
		marm_gaps.append(f)
	var steps := 60
	for j in steps:
		var f0 := float(j) / steps
		var f1 := float(j + 1) / steps
		var gap := false
		for gf: float in marm_gaps:
			if absf((f0 + f1) * 0.5 - gf) < 0.006:
				gap = true
		if not gap:
			_seg(m0.lerp(tip, f0), m0.lerp(tip, f1), 3.5, C_WALL)
	# Zincir (kesik çizgi) ve Osmanlı köprüsü
	var c0: Vector3 = World1453.LANDMARKS["chain_s"]
	var c1: Vector3 = World1453.LANDMARKS["chain_n"]
	var n := 16
	for j in n:
		if j % 2 == 0:
			_seg(Vector2(c0.x, c0.z).lerp(Vector2(c1.x, c1.z), float(j) / n),
				Vector2(c0.x, c0.z).lerp(Vector2(c1.x, c1.z), float(j + 1) / n), 2.5, C_CHAIN)
	var bz := -90.0
	_seg(Vector2(World1453.HORN_S_X, bz), Vector2(World1453.horn_n_x(bz), bz), 4.0, C_BRIDGE)
	print("surlar %d ms" % (Time.get_ticks_msec() - t0))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/ui"))
	img.save_png(OUT)
	print("MAPBAKE %dx%d %s (%d ms)" % [w, h, OUT, Time.get_ticks_msec() - t0])
	get_tree().quit(0)


## x boyunca uzanan sur (sabit z): gates'teki x'lerde boşluk
func _wall_x(z: float, xa: float, xb: float, width_m: float, col: Color, gates: Array) -> void:
	var x := xa
	var step := 4.0
	while x < xb:
		var x2 := minf(x + step, xb)
		if _clear_of((x + x2) * 0.5, gates, GATE_GAP * 0.5):
			_seg(Vector2(x, z), Vector2(x2, z), width_m, col)
		x = x2


## z boyunca uzanan sur (sabit x): gates'teki z'lerde boşluk (za > zb)
func _wall_z(x: float, za: float, zb: float, width_m: float, col: Color, gates: Array) -> void:
	var z := za
	var step := 4.0
	while z > zb:
		var z2 := maxf(z - step, zb)
		if _clear_of((z + z2) * 0.5, gates, GATE_GAP * 0.5):
			_seg(Vector2(x, z), Vector2(x, z2), width_m, col)
		z = z2


## Halka (çevre çizgisi), yalnız karada
func _ring(c: Vector2, r_m: float, width_m: float, col: Color) -> void:
	var n := maxi(24, int(TAU * r_m / 2.0))
	for j in n:
		var a0 := TAU * j / n
		var a1 := TAU * (j + 1) / n
		_seg_land(c + Vector2(cos(a0), sin(a0)) * r_m, c + Vector2(cos(a1), sin(a1)) * r_m, width_m, col)


## Kısa bölüm, iki ucu da karadaysa
func _seg_land(a: Vector2, b: Vector2, width_m: float, col: Color) -> void:
	var m := (a + b) * 0.5
	if not World1453.is_water(m.x, m.y):
		_seg(a, b, width_m, col)


func _clear_of(v: float, gates: Array, r: float) -> bool:
	for gv: float in gates:
		if absf(v - gv) < r:
			return false
	return true


## Dünyadaki (x, z) bölümü haritada kalın çizgi olarak (genişlik metre)
func _seg(a: Vector2, b: Vector2, width_m: float, col: Color) -> void:
	var pa := MapView.world_pixel(a)
	var pb := MapView.world_pixel(b)
	var r := maxf(width_m / MapView.MPP * 0.5, 0.6)
	var steps := maxi(1, int(pa.distance_to(pb) * 2.0))
	for s in steps + 1:
		_dot(pa.lerp(pb, float(s) / steps), r, col)


func _disc(c: Vector2, r_m: float, col: Color) -> void:
	_dot(MapView.world_pixel(c), maxf(r_m / MapView.MPP, 0.6), col)


## Yalnız karaya düşen pikselleri boyayan daire (kıyıdaki kasaba denize taşmasın)
func _disc_land(c: Vector2, r_m: float, col: Color) -> void:
	var p := MapView.world_pixel(c)
	var r := r_m / MapView.MPP
	for y in range(maxi(int(p.y - r), 0), mini(int(p.y + r) + 1, img.get_height())):
		for x in range(maxi(int(p.x - r), 0), mini(int(p.x + r) + 1, img.get_width())):
			if Vector2(x + 0.5, y + 0.5).distance_to(p) <= r:
				var q := MapView.pixel_world(Vector2(x + 0.5, y + 0.5))
				if not World1453.is_water(q.x, q.y):
					img.set_pixel(x, y, col)


func _dot(p: Vector2, r: float, col: Color) -> void:
	for y in range(maxi(int(floor(p.y - r)), 0), mini(int(ceil(p.y + r)) + 1, img.get_height())):
		for x in range(maxi(int(floor(p.x - r)), 0), mini(int(ceil(p.x + r)) + 1, img.get_width())):
			if Vector2(x + 0.5, y + 0.5).distance_to(p) <= r:
				img.set_pixel(x, y, col)


## Yönlü dikdörtgen: orta c (dünya x, z), u yönü (birim), yarı boylar hu (u boyunca) ve hv; land: yalnız karaya
func _box(c: Vector2, u: Vector2, hu: float, hv: float, col: Color, land := false) -> void:
	var v := Vector2(-u.y, u.x)
	var ext := Vector2(absf(u.x) * hu + absf(v.x) * hv, absf(u.y) * hu + absf(v.y) * hv)
	var p0 := MapView.world_pixel(c - ext)
	var p1 := MapView.world_pixel(c + ext)
	var lo := Vector2(minf(p0.x, p1.x), minf(p0.y, p1.y))
	var hi := Vector2(maxf(p0.x, p1.x), maxf(p0.y, p1.y))
	for y in range(maxi(int(floor(lo.y)), 0), mini(int(ceil(hi.y)) + 1, img.get_height())):
		for x in range(maxi(int(floor(lo.x)), 0), mini(int(ceil(hi.x)) + 1, img.get_width())):
			var w := MapView.pixel_world(Vector2(x + 0.5, y + 0.5))
			var q := w - c
			if absf(q.dot(u)) <= hu and absf(q.dot(v)) <= hv and not (land and World1453.is_water(w.x, w.y)):
				img.set_pixel(x, y, col)
