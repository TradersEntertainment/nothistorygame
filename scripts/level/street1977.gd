class_name Street1977
extends Node3D
## Bölüm 15, T3: 1977 İstanbul'unda bir mahalle caddesi, düğünün ertesi sabahı (Kurtuluş).
## Cadde x boyunca uzanır (oynanan kısım x ∈ [-20, 20]); kuzey kaldırımında kahvehane ve Emniyet Sigorta acentesi,
## güney kaldırımında gazete kulübesi ve simitçi. Yolda park etmiş yetmişler arabaları, gidip gelen sarı bir dolmuş.
## Acentenin içi: müdür Ferit Bey'in masası (kapıya dönük), ziyaretçi sandalyesi, daktilolu kâtip, boş bir masa.

const SPAWN := Vector3(-17.0, 0.0, 4.2)
const KIOSK := Vector3(-11.5, 0.0, 3.85)               # gazete kulübesi (güney kaldırımı, yüzü caddeye)
const NEWSAGENT := Vector3(-11.5, 0.0, 4.45)
const KAHVE := Vector3(-1.0, 0.0, -5.0)               # kahvehanenin ön yüzü (kuzey cephe)
const AGENCY_DOOR := Vector3(10.0, 0.0, -5.0)
const FERIT_POS := Vector3(10.0, 0.0, -10.0)          # acente müdürü, masasının arkasında oturur
const FERIT_DESK := Vector3(10.0, 0.0, -9.2)
const VISITOR := Vector3(10.0, 0.05, -8.05)           # ziyaretçi sandalyesi (Tolga burada oturur)
const TOLGA_DESK := Vector3(6.75, 0.0, -7.6)          # boş masa: batı duvarında, daktilolu
const TOLGA_CHAIR := Vector3(7.55, 0.05, -7.6)
const HALF := 20.5                                    # oynanan caddenin yarı uzunluğu (görünmez duvarlar)

const C_ROAD := Color("4e4c48")
const C_WALK := Color("a8a294")
const FACADES := [Color("d8c7a4"), Color("b98a68"), Color("c9cdb8"), Color("d8b88a"), Color("a8b4b8"), Color("caa08a")]

var newsagent: Person
var ferit: Person
var clerk: Person
var kahveci: Person
var radio_light: OmniLight3D
var dolmus: Node3D
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 1977
	Audio.voice_space("outdoor")
	_build_env()
	_build_ground()
	_build_north()
	_build_south()
	_build_street_props()
	_build_kiosk()
	_build_kahve()
	_build_agency()
	_build_people()


func _build_env() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("7aa4cc")
	sm.sky_horizon_color = Color("f0dcc0")
	sm.ground_horizon_color = Color("d8c8b0")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("b0a088")
	e.ambient_light_energy = 0.6
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.9
	e.fog_enabled = true
	e.fog_light_color = Color("e8d8c0")
	e.fog_density = 0.008
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-32, -60, 0)       # sabah güneşi: doğudan, alçak, sıcak
	sun.light_color = Color("ffe2b8")
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	add_child(sun)


func _build_ground() -> void:
	Props.set_pattern(Props.solid(self, Vector3(90, 0.2, 30), Vector3(0, -0.1, 0), C_ROAD), C_ROAD, "cobble")
	for z: float in [-4.0, 4.0]:
		Props.set_pattern(Props.box(self, Vector3(90, 0.08, 2.0), Vector3(0, 0.04, z), C_WALK), C_WALK, "concrete")
		Props.box(self, Vector3(90, 0.1, 0.12), Vector3(0, 0.05, z - signf(z) * 1.0), Color("8a867c"))
	# Orta çizgi: kesik, solgun
	for i in 22:
		Props.box(self, Vector3(1.4, 0.01, 0.1), Vector3(-42.0 + i * 4.0, 0.005, 0), Color("d8d0b0"))
	# Oynanan caddenin uçları: görünmez duvar (cadde gözle devam eder)
	for sx: float in [-1.0, 1.0]:
		var b := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(0.4, 4.0, 12.0)
		cs.shape = bs
		b.position = Vector3(sx * HALF, 2.0, 0)
		b.add_child(cs)
		b.set_meta("no_climb", true)
		add_child(b)


## Bir bina cephesi: dolu blok, pencereler, pervazlar; south=true ise yüzü kuzeye (-z) bakar.
func _block(x0: float, x1: float, h: float, face_z: float, depth: float, col: Color, from_y := 0.0) -> void:
	var dir := -1.0 if face_z > 0.0 else 1.0     # cephenin baktığı yön (z): kuzey blokları +z'ye bakar
	var cz := face_z - dir * depth * 0.5
	var body := Props.solid(self, Vector3(x1 - x0, h - from_y, depth), Vector3((x0 + x1) * 0.5, from_y + (h - from_y) * 0.5, cz), col)
	Props.set_pattern(body, col, "plaster")
	# Zemin kat: apartman kapısı (camlı, demir parmaklıklı) ve basamak
	if from_y == 0.0 and x1 - x0 > 3.0:
		var dx := (x0 + x1) * 0.5 + _rng.randf_range(-1.0, 1.0)
		Props.box(self, Vector3(1.3, 2.4, 0.06), Vector3(dx, 1.2, face_z + dir * 0.02), Color("4a3420"))
		Props.box(self, Vector3(0.9, 0.9, 0.07), Vector3(dx, 1.6, face_z + dir * 0.03), Color("3a4a58"))
		for b in 4:
			Props.box(self, Vector3(0.03, 0.9, 0.09), Vector3(dx - 0.3 + b * 0.2, 1.6, face_z + dir * 0.04), Color("2a2a2a"))
		Props.box(self, Vector3(1.6, 0.14, 0.4), Vector3(dx, 0.07, face_z + dir * 0.2), Color("b8b0a0"))
		Props.label(self, str(_rng.randi_range(3, 61)), Vector3(dx, 2.6, face_z + dir * 0.04), 26, Color("f4f1ea"), Vector3(0, 0 if dir > 0.0 else 180, 0), 0.3)
		for wx: float in [dx - 2.2, dx + 2.2]:
			if wx - 0.6 > x0 and wx + 0.6 < x1:
				Props.box(self, Vector3(1.1, 1.2, 0.06), Vector3(wx, 1.6, face_z + dir * 0.02), Color("3a4a58"))
				for b in 5:
					Props.box(self, Vector3(0.03, 1.2, 0.09), Vector3(wx - 0.44 + b * 0.22, 1.6, face_z + dir * 0.04), Color("2a2a2a"))
	# Pencereler: katlar 3 m, aralık ~2.2 m
	var floors := int((h - maxf(from_y, 3.0)) / 3.0)
	var n := int((x1 - x0) / 2.2)
	if n <= 0:
		return
	var step := (x1 - x0) / n
	for f in floors:
		var y := maxf(from_y, 3.0) + 1.0 + f * 3.0
		for i in n:
			var x := x0 + step * (i + 0.5)
			var lit := _rng.randf() < 0.25
			var win := Props.box(self, Vector3(1.0, 1.35, 0.06), Vector3(x, y + 0.55, face_z + dir * 0.02), Color("ffe0a0") if lit else Color("2e3440"))
			if lit:
				win.material_override = Props.mat(Color("ffe0a0"), 0.3, false, "", false)
			Props.box(self, Vector3(1.2, 0.1, 0.14), Vector3(x, y - 0.15, face_z + dir * 0.06), Color("efe8d8"))
			Props.box(self, Vector3(0.06, 1.35, 0.08), Vector3(x, y + 0.55, face_z + dir * 0.05), Color("efe8d8"))
			# Bazı pencerelerde panjur ya da saksı
			var r := _rng.randf()
			if r < 0.25:
				for s: float in [-1.0, 1.0]:
					Props.box(self, Vector3(0.5, 1.35, 0.05), Vector3(x + s * 0.78, y + 0.55, face_z + dir * 0.05), Color("4a6a5a"))
			elif r < 0.45:
				Props.box(self, Vector3(0.8, 0.18, 0.22), Vector3(x, y - 0.05, face_z + dir * 0.16), Color("b8683a"))
				for k in 3:
					Props.ball(self, 0.12, Vector3(x - 0.25 + k * 0.25, y + 0.1, face_z + dir * 0.16), [Color("c8323a"), Color("3f7a3a"), Color("e8a020")][k], Vector3.ONE, 6)
	# Çatı saçağı
	Props.box(self, Vector3(x1 - x0 + 0.1, 0.25, 0.5), Vector3((x0 + x1) * 0.5, h + 0.1, face_z + dir * 0.15), col.darkened(0.25))


## Kuzey cephe (z = -5, yüzü +z): binalar, kahvehane (x -4..2) ve acente (x 6..14) zemin katları açık.
func _build_north() -> void:
	var segs := [[-44.0, -28.0, 12.0], [-28.0, -16.0, 9.0], [-16.0, -4.0, 12.0], [2.0, 6.0, 9.0], [14.0, 24.0, 12.0], [24.0, 44.0, 9.0]]
	for i in segs.size():
		_block(segs[i][0], segs[i][1], segs[i][2], -5.0, 7.0, FACADES[i % FACADES.size()])
	# Kahvehanenin ve acentenin üstündeki katlar
	_block(-4.0, 2.0, 12.0, -5.0, 7.0, FACADES[2].lightened(0.1), 3.0)
	_block(6.0, 14.0, 9.0, -5.0, 7.0, FACADES[4], 3.2)
	# Balkonlar ve çamaşır ipi (kuzey cephe, birinci kat)
	for x: float in [-24.0, -10.0, 18.0, 30.0]:
		_balcony(Vector3(x, 4.0, -5.0), 1.0)


func _balcony(p: Vector3, dir: float) -> void:
	Props.box(self, Vector3(2.4, 0.12, 0.9), p + Vector3(0, -0.1, dir * 0.45), Color("d8d0c0"))
	for k in 10:
		Props.box(self, Vector3(0.03, 0.8, 0.03), p + Vector3(-1.15 + k * 0.255, 0.3, dir * 0.88), Color("3a3a40"))
	Props.box(self, Vector3(2.4, 0.05, 0.06), p + Vector3(0, 0.72, dir * 0.88), Color("3a3a40"))
	# Çamaşır: ipte renkli bezler
	Props.cyl(self, 0.008, 2.3, p + Vector3(0, 1.5, dir * 0.75), Color("e8e8e0"), Vector3(0, 0, 90), 4)
	for k in 4:
		Props.box(self, Vector3(0.35, 0.45, 0.02), p + Vector3(-0.8 + k * 0.5, 1.27, dir * 0.75), [Color("f4f1ea"), Color("8ab0d8"), Color("e8a8b8"), Color("f0d040")][k])


## Güney cephe (z = +5, yüzü -z): apartmanlar, balkonlar; zemin katta bakkal ve berber vitrinleri.
func _build_south() -> void:
	var x := -44.0
	var i := 0
	while x < 44.0:
		var w := _rng.randf_range(7.0, 11.0)
		var h := _rng.randf_range(9.0, 13.0)
		_block(x, x + w, h, 5.0, 7.0, FACADES[(i + 3) % FACADES.size()])
		if i % 2 == 1:
			_balcony(Vector3(x + w * 0.5, 4.0, 5.0), -1.0)
		x += w
		i += 1
	# Zemin kat vitrinleri: bakkal, berber (tabelalar)
	for sp in [[Vector3(-4.0, 0, 5.0), "BAKKAL · ŞEKER · ÇAY · GAZOZ", Color("2f5fa8")], [Vector3(4.5, 0, 5.0), "BERBER CEMAL · TIRAŞ 5 TL", Color("8a2b22")],
			[Vector3(15.0, 0, 5.0), "TERZİ · PANTOLON PAÇASI GENİŞLETİLİR", Color("3a6b3a")]]:
		var p: Vector3 = sp[0]
		Props.box(self, Vector3(3.6, 1.8, 0.06), p + Vector3(0, 1.4, -0.03), Color("6a8aa0"))
		Props.box(self, Vector3(3.8, 0.12, 0.1), p + Vector3(0, 0.45, -0.05), Color("efe8d8"))
		Props.box(self, Vector3(3.8, 0.5, 0.08), p + Vector3(0, 2.6, -0.06), sp[2])
		Props.label(self, sp[1], p + Vector3(0, 2.6, -0.11), 26, Color("f4f1ea"), Vector3(0, 180, 0), 3.5)
	# Duvarda afişler
	var posters := [[Vector3(-14.5, 1.7, 4.96), "SİNEMA\n'HALAYIN KUYRUĞU'\nYAKINDA", Color("c8323a")],
		[Vector3(8.5, 1.6, 4.96), "KAYIP: FES\nKIRMIZIMSI\nBULANA ÇAY", Color("2a2a30")]]
	for pp in posters:
		Props.box(self, Vector3(0.8, 1.1, 0.02), pp[0], Color("f0e6c8"))
		Props.label(self, pp[1], pp[0] + Vector3(0, 0, -0.02), 22, pp[2], Vector3(0, 180, 0), 0.7)


func _build_street_props() -> void:
	# Beton direkli sokak lambaları ve elektrik telleri
	for x in range(-36, 40, 10):
		for z: float in [-3.4, 3.4]:
			var lx := float(x) + (3.0 if z > 0.0 else 0.0)     # güneyde gazete kulübesinin önüne düşmesin
			Props.cyl(self, 0.09, 5.2, Vector3(lx, 2.6, z), Color("9a968c"), Vector3.ZERO, 6)
			Props.box(self, Vector3(0.08, 0.08, 0.9), Vector3(lx, 5.1, z - signf(z) * 0.4), Color("6a6a60"))
			var bulb := Props.box(self, Vector3(0.22, 0.12, 0.35), Vector3(lx, 5.0, z - signf(z) * 0.8), Color("f4ecd0"))
			bulb.material_override = Props.mat(Color("f4ecd0"), 0.2, false, "", false)
	for k in 3:
		Props.cyl(self, 0.012, 80.0, Vector3(0, 5.6 + k * 0.18, -3.5 + k * 0.05), Color("2a2a2a"), Vector3(0, 0, 90), 3)
	# Park etmiş arabalar (yetmişlerin kutu sedanları) ve çekçek
	_sedan(Vector3(-6.5, 0, -2.0), 0.0, Color("e8d8a8"))
	_sedan(Vector3(4.0, 0, -2.0), 0.0, Color("a8382a"))
	_sedan(Vector3(16.5, 0, 2.0), PI, Color("4a7a6a"))
	_sedan(Vector3(-22.0, 0, 2.0), PI, Color("3a5a8a"))
	# Dolmuş: sarı, damalı şeritli, tavanında tabela; cadde boyunca gidip gelir
	dolmus = Node3D.new()
	add_child(dolmus)
	_dolmus_body(dolmus)
	dolmus.position = Vector3(-42.0, 0, 0.3)
	dolmus.rotation.y = PI / 2.0
	var tw := dolmus.create_tween().set_loops()
	tw.tween_property(dolmus, "position:x", 42.0, 16.0).from(-42.0)
	tw.tween_interval(6.0)
	# Simitçi arabası (güney kaldırımı)
	var sc := Vector3(-4.2, 0, 3.6)
	Props.box(self, Vector3(1.3, 0.9, 0.7), sc + Vector3(0, 0.75, 0), Color("b3262d"))
	for wx: float in [-0.45, 0.45]:
		Props.cyl(self, 0.28, 0.08, sc + Vector3(wx, 0.28, -0.38), Color("2a2a30"), Vector3(90, 0, 0), 10)
	var glass := Props.box(self, Vector3(1.2, 0.6, 0.6), sc + Vector3(0, 1.5, 0), Color("dff0ff"))
	glass.material_override = Props.mat(Color(0.85, 0.95, 1.0, 0.25), 0.0, true, "", false)
	Props.box(self, Vector3(1.3, 0.05, 0.7), sc + Vector3(0, 1.82, 0), Color("b3262d"))
	for k in 12:
		Props.ring(self, 0.035, 0.1, sc + Vector3(-0.45 + (k % 6) * 0.18, 1.28 + (k / 6) * 0.2, 0.05 * (k % 2)), Color("c07838"), Vector3(90, 0, 0))
	Props.label(self, "SİMİT 1 TL", sc + Vector3(0, 1.0, -0.36), 34, Color("f4f1ea"), Vector3(0, 180, 0), 0.9)
	# Sokak tabelası
	Props.box(self, Vector3(1.4, 0.32, 0.04), Vector3(-15.0, 2.6, -4.97), Color("2f5fa8"))
	Props.label(self, "KURTULUŞ CAD.", Vector3(-15.0, 2.6, -4.94), 26, Color("f4f1ea"), Vector3.ZERO, 1.3)


## Yetmişlerin kutu sedanı: gövde, kabin, camlar, krom tampon, tekerler. yaw 0: burnu +x.
func _sedan(p: Vector3, yaw: float, col: Color) -> void:
	var c := Node3D.new()
	c.position = p
	c.rotation.y = yaw
	add_child(c)
	Props.box(c, Vector3(4.1, 0.62, 1.62), Vector3(0, 0.62, 0), col)
	Props.box(c, Vector3(2.0, 0.5, 1.5), Vector3(-0.2, 1.17, 0), col.lightened(0.05))
	for s: float in [-1.0, 1.0]:
		Props.box(c, Vector3(1.8, 0.38, 0.02), Vector3(-0.2, 1.18, s * 0.76), Color("2e3a48"))
		Props.cyl(c, 0.3, 0.22, Vector3(1.35, 0.3, s * 0.72), Color("1a1a1e"), Vector3(90, 0, 0), 10)
		Props.cyl(c, 0.3, 0.22, Vector3(-1.35, 0.3, s * 0.72), Color("1a1a1e"), Vector3(90, 0, 0), 10)
		Props.cyl(c, 0.13, 0.24, Vector3(1.35, 0.3, s * 0.72), Color("b8b8b8"), Vector3(90, 0, 0), 8)
		Props.cyl(c, 0.13, 0.24, Vector3(-1.35, 0.3, s * 0.72), Color("b8b8b8"), Vector3(90, 0, 0), 8)
		Props.ball(c, 0.1, Vector3(2.04, 0.7, s * 0.55), Color("f4f0d8"), Vector3(0.4, 1, 1), 6)
	Props.box(c, Vector3(0.02, 0.38, 1.4), Vector3(0.82, 1.18, 0), Color("2e3a48"))
	Props.box(c, Vector3(0.02, 0.38, 1.4), Vector3(-1.22, 1.18, 0), Color("2e3a48"))
	for bx: float in [-2.08, 2.08]:
		Props.box(c, Vector3(0.08, 0.14, 1.68), Vector3(bx, 0.48, 0), Color("c8c8cc"))
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(4.1, 1.4, 1.6)
	cs.shape = bs
	cs.position = Vector3(0, 0.7, 0)
	body.add_child(cs)
	c.add_child(body)


## Elli altı model Amerikan arabası dolmuş: sarı, kanatlı, damalı şerit, tavanında "DOLMUŞ".
func _dolmus_body(c: Node3D) -> void:
	var y := Color("f0c020")
	Props.box(c, Vector3(1.8, 0.62, 5.0), Vector3(0, 0.62, 0), y)
	Props.box(c, Vector3(1.66, 0.52, 2.3), Vector3(0, 1.2, -0.2), y)
	for s: float in [-1.0, 1.0]:
		Props.box(c, Vector3(0.02, 0.4, 2.1), Vector3(s * 0.84, 1.22, -0.2), Color("2e3a48"))
		for k in 8:
			Props.box(c, Vector3(0.02, 0.12, 0.3), Vector3(s * 0.91, 0.75, -2.1 + k * 0.6), Color("1a1a1e") if k % 2 == 0 else Color("f4f1ea"))
		for wz: float in [-1.6, 1.6]:
			Props.cyl(c, 0.34, 0.24, Vector3(s * 0.8, 0.34, wz), Color("1a1a1e"), Vector3(0, 0, 90), 10)
			Props.cyl(c, 0.16, 0.26, Vector3(s * 0.8, 0.34, wz), Color("e8e8e8"), Vector3(0, 0, 90), 8)
		# Arka kanatlar
		Props.prism(c, Vector3(0.1, 0.25, 0.9), Vector3(s * 0.85, 1.05, -2.1), y)
	Props.box(c, Vector3(1.5, 0.4, 0.02), Vector3(0, 1.22, 0.96), Color("2e3a48"))
	Props.box(c, Vector3(1.86, 0.16, 0.1), Vector3(0, 0.45, 2.52), Color("d8d8dc"))
	Props.box(c, Vector3(1.86, 0.16, 0.1), Vector3(0, 0.45, -2.52), Color("d8d8dc"))
	Props.box(c, Vector3(0.9, 0.24, 0.3), Vector3(0, 1.58, -0.2), Color("f4f1ea"))
	Props.label(c, "DOLMUŞ", Vector3(0.46, 1.58, -0.2), 26, Color("1a1a1e"), Vector3(0, 90, 0), 0.8)
	Props.label(c, "DOLMUŞ", Vector3(-0.46, 1.58, -0.2), 26, Color("1a1a1e"), Vector3(0, -90, 0), 0.8)
	Props.label(c, "TAKSİM–ŞİŞLİ", Vector3(0.92, 0.95, 0.4), 24, Color("1a1a1e"), Vector3(0, 90, 0), 1.6)
	# Şoför
	var d := Person.new({"coat": Color("e8e0d0"), "pants": Color("3a3a42"), "mustache": true, "hair": Color("1a1410"), "skin": Color("d8a070")})
	d.position = Vector3(0.4, 0.15, 0.1)
	d.set_meta("no_talk", true)
	d.set_meta("no_unclip", true)
	d.set_meta("no_audit", true)
	c.add_child(d)
	d.set_activity("sit")


## Gazete kulübesi: yeşil tahta, tezgâhta gazete yığınları, önünde ip üstünde asılı gazeteler.
func _build_kiosk() -> void:
	var k := KIOSK
	var g := Color("3f6a4a")
	Props.solid(self, Vector3(2.2, 0.95, 0.5), k + Vector3(0, 0.475, 0), g)
	Props.solid(self, Vector3(2.2, 2.4, 0.12), k + Vector3(0, 1.2, 1.0), g)
	for sx: float in [-1.05, 1.05]:
		Props.solid(self, Vector3(0.12, 2.4, 1.3), k + Vector3(sx, 1.2, 0.4), g)
	Props.box(self, Vector3(2.5, 0.1, 1.7), k + Vector3(0, 2.45, 0.3), Color("2a4a34"))
	Props.box(self, Vector3(2.3, 0.4, 0.06), k + Vector3(0, 2.2, -0.05), Color("f4f1ea"))
	Props.label(self, "GAZETE · DERGİ · PİYANGO", k + Vector3(0, 2.2, -0.09), 26, Color("1d4a2a"), Vector3(0, 180, 0), 2.1)
	# Tezgâhta yığınlar (manşetler okunur, yüzü caddeye)
	var names := [["GÜNDÜZ", Color("b3262d")], ["AKŞAM POSTASI", Color("1d2330")], ["TOP", Color("2f5fa8")]]
	for i in names.size():
		var pp := k + Vector3(-0.7 + i * 0.7, 0.96, -0.05)
		for j in 6:
			Props.box(self, Vector3(0.5, 0.012, 0.36), pp + Vector3(0, j * 0.012, 0), Color("ece6d4"), Vector3(0, _rng.randf_range(-4, 4), 0))
		Props.label(self, names[i][0], pp + Vector3(0, 0.08, -0.08), 22, names[i][1], Vector3(-80, 180, 0), 0.46)
	# İpte asılı gazeteler
	Props.cyl(self, 0.008, 2.1, k + Vector3(0, 1.9, -0.2), Color("e8e8e0"), Vector3(0, 0, 90), 4)
	for i in 4:
		var hp := k + Vector3([-0.95, -0.52, 0.52, 0.95][i], 1.62, -0.2)
		Props.box(self, Vector3(0.42, 0.55, 0.01), hp, Color("f0ead8"))
		Props.box(self, Vector3(0.34, 0.07, 0.012), hp + Vector3(0, 0.18, -0.002), [Color("b3262d"), Color("1d2330"), Color("2f5fa8"), Color("b3262d")][i])
		for l in 4:
			Props.box(self, Vector3(0.32, 0.015, 0.012), hp + Vector3(0, 0.05 - l * 0.07, -0.002), Color("8a8478"))
	Props.interactable(self, "y_kiosk", Vector3(2.2, 1.6, 0.8), k + Vector3(0, 0.9, -0.2))


## Çınaraltı Kahvesi: zemin katta açık önlü oda; masalar içeride ve kaldırımda, rafta radyo, duvarda takvim.
func _build_kahve() -> void:
	var o := KAHVE
	# Oda: arka duvar (z -8.6), tavan (y 3), zemin; yan duvarlar komşu blokların duvarı
	Props.set_pattern(Props.solid(self, Vector3(6.0, 3.0, 0.2), o + Vector3(0, 1.5, -3.6), Color("d8c8a0")), Color("d8c8a0"), "plaster")
	Props.box(self, Vector3(6.0, 0.1, 3.6), o + Vector3(0, 2.98, -1.8), Color("8a6440"))
	Props.set_pattern(Props.box(self, Vector3(6.0, 0.02, 3.6), o + Vector3(0, 0.01, -1.8), Color("9a3a2a")), Color("9a3a2a"), "tiles")
	# Tente ve tabela
	Props.box(self, Vector3(6.2, 0.6, 0.08), o + Vector3(0, 3.25, 0.05), Color("2f5fa8"))
	Props.label(self, "ÇINARALTI KAHVESİ", o + Vector3(0, 3.25, 0.1), 36, Color("f4f1ea"), Vector3.ZERO, 4.0)
	for i in 8:
		Props.prism(self, Vector3(0.75, 0.3, 0.02), o + Vector3(-2.65 + i * 0.76, 2.82, 0.55), [Color("c8323a"), Color("f4f1ea")][i % 2], Vector3(180, 0, 0))
	Props.box(self, Vector3(6.0, 0.04, 1.2), o + Vector3(0, 2.95, 0.6), Color("c8323a"), Vector3(-12, 0, 0))
	# Ocak tezgâhı ve semaver (arka duvarda), radyo rafı, takvim
	Props.solid(self, Vector3(2.0, 0.95, 0.6), o + Vector3(1.6, 0.475, -3.2), Color("7a5432"))
	Props.cyl(self, 0.2, 0.55, o + Vector3(1.2, 1.25, -3.25), Color("c49a45"), Vector3.ZERO, 10, 0.12)
	for k in 6:
		Props.cyl(self, 0.028, 0.08, o + Vector3(1.6 + (k % 3) * 0.18, 0.99, -3.05 - (k / 3) * 0.16), Color("a0301a"), Vector3.ZERO, 8, 0.022)
	Props.box(self, Vector3(1.2, 0.05, 0.3), o + Vector3(-1.5, 1.9, -3.38), Color("6a4428"))
	var radio := Node3D.new()
	radio.position = o + Vector3(-1.5, 2.08, -3.36)
	add_child(radio)
	Props.box(radio, Vector3(0.62, 0.32, 0.22), Vector3.ZERO, Color("6a3a1e"))
	Props.box(radio, Vector3(0.3, 0.22, 0.01), Vector3(-0.12, 0, 0.115), Color("d8c8a0"))
	Props.box(radio, Vector3(0.18, 0.05, 0.01), Vector3(0.16, 0.06, 0.115), Color("f0e0a0"), Vector3.ZERO, 0.6)
	for k in 2:
		Props.cyl(radio, 0.035, 0.03, Vector3(0.12 + k * 0.1, -0.06, 0.12), Color("2a2a2a"), Vector3(90, 0, 0), 8)
	radio_light = OmniLight3D.new()
	radio_light.position = o + Vector3(-1.5, 2.1, -3.1)
	radio_light.light_color = Color("ffd890")
	radio_light.light_energy = 0.0
	radio_light.omni_range = 2.5
	add_child(radio_light)
	Props.box(self, Vector3(0.5, 0.65, 0.02), o + Vector3(-0.4, 1.9, -3.48), Color("f4f1ea"))
	Props.label(self, "1977", o + Vector3(-0.4, 2.1, -3.46), 40, Color("b3262d"), Vector3.ZERO, 0.4)
	var lamp := OmniLight3D.new()
	lamp.position = o + Vector3(0, 2.6, -1.8)
	lamp.light_color = Color("ffd8a0")
	lamp.light_energy = 0.8
	lamp.omni_range = 5.0
	add_child(lamp)
	# Masalar: içeride iki, kaldırımda iki; tavla, çay bardakları
	for tp: Vector3 in [o + Vector3(-1.6, 0, -1.8), o + Vector3(0.6, 0, -1.6), o + Vector3(-1.8, 0, 0.9), o + Vector3(1.4, 0, 0.9)]:
		Props.solid(self, Vector3(0.7, 0.05, 0.7), tp + Vector3(0, 0.72, 0), Color("8a6440"))
		Props.cyl(self, 0.04, 0.7, tp + Vector3(0, 0.36, 0), Color("4a3020"), Vector3.ZERO, 6)
		for k in 2:
			Props.cyl(self, 0.05, 0.01, tp + Vector3(-0.18 + k * 0.36, 0.755, 0.18), Color("f0ece4"), Vector3.ZERO, 10)
			Props.cyl(self, 0.028, 0.08, tp + Vector3(-0.18 + k * 0.36, 0.8, 0.18), Color("a0301a"), Vector3.ZERO, 8, 0.022)
	# Tavla (kaldırımdaki ilk masada)
	var tv := o + Vector3(-1.8, 0.76, 0.9)
	Props.box(self, Vector3(0.5, 0.03, 0.36), tv, Color("6a3a1e"))
	Props.box(self, Vector3(0.46, 0.005, 0.32), tv + Vector3(0, 0.017, 0), Color("e8d8b0"))
	for k in 6:
		Props.prism(self, Vector3(0.05, 0.005, 0.13), tv + Vector3(-0.2 + k * 0.08, 0.021, -0.08), [Color("8a2b22"), Color("2a2a2a")][k % 2], Vector3(90, 0, 0))
	for k in 5:
		Props.cyl(self, 0.022, 0.01, tv + Vector3(-0.15 + k * 0.05, 0.026, 0.08), [Color("f4f1ea"), Color("2a2a2a")][k % 2], Vector3.ZERO, 8)


## Emniyet Sigorta acentesi: tabela, vitrin camı, kapı; içeride Ferit Bey'in masası, ziyaretçi sandalyesi, kâtibin masası,
## boş masa (daktilolu), dosya dolabı, tavan vantilatörü, duvarda takvim ve "Yangın · Kaza · Hayat" afişi.
func _build_agency() -> void:
	var c := Vector3(10.0, 0, -8.0)
	var wc := Color("e4dcc4")
	# Zemin, tavan, duvarlar (ön duvar: kapı ve iki vitrin)
	Props.set_pattern(Props.box(self, Vector3(8.0, 0.02, 6.0), c + Vector3(0, 0.01, 0), Color("8a7a60")), Color("8a7a60"), "wood")
	Props.box(self, Vector3(8.0, 0.1, 6.0), c + Vector3(0, 3.15, 0), Color("ece6d4"))
	Props.set_pattern(Props.solid(self, Vector3(8.0, 3.2, 0.2), c + Vector3(0, 1.6, -3.1), wc), wc, "plaster")
	for sx: float in [-1.0, 1.0]:
		Props.set_pattern(Props.solid(self, Vector3(0.2, 3.2, 6.0), c + Vector3(sx * 4.1, 1.6, 0), wc), wc, "plaster")
	# Ön duvar parçaları: kapı x 9.4..10.6 (2.3 m), vitrinler 6.6..9.0 ve 11.0..13.4 (0.9..2.3 m)
	var fz := -5.0 + 0.1
	for seg in [[6.0, 6.6], [9.0, 9.4], [10.6, 11.0], [13.4, 14.0]]:
		Props.solid(self, Vector3(seg[1] - seg[0], 3.2, 0.2), Vector3((seg[0] + seg[1]) * 0.5, 1.6, fz - 0.1), Color("6a4a30"))
	Props.solid(self, Vector3(1.2, 0.9, 0.2), Vector3(10.0, 2.75, fz - 0.1), Color("6a4a30"))
	for wx: Array in [[6.6, 9.0], [11.0, 13.4]]:
		var mx: float = (wx[0] + wx[1]) * 0.5
		var ww: float = wx[1] - wx[0]
		Props.solid(self, Vector3(ww, 0.9, 0.2), Vector3(mx, 0.45, fz - 0.1), Color("6a4a30"))
		Props.solid(self, Vector3(ww, 0.9, 0.2), Vector3(mx, 2.75, fz - 0.1), Color("6a4a30"))
		var glass := Props.box(self, Vector3(ww, 1.4, 0.03), Vector3(mx, 1.6, fz - 0.1), Color("cfe4f0"))
		glass.material_override = Props.mat(Color(0.8, 0.9, 0.95, 0.22), 0.0, true, "", false)
		var gb := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(ww, 1.4, 0.1)
		cs.shape = bs
		gb.position = Vector3(mx, 1.6, fz - 0.1)
		gb.add_child(cs)
		add_child(gb)
		Props.label(self, "YANGIN · KAZA · HAYAT", Vector3(mx, 1.95, fz + 0.0), 22, Color("c49a45"), Vector3.ZERO, ww * 0.85)
		Props.label(self, "NAKLİYAT · OTOMOBİL", Vector3(mx, 1.7, fz + 0.0), 18, Color("c49a45"), Vector3.ZERO, ww * 0.7)
	# Tabela: lacivert pano, sarı harfler
	Props.box(self, Vector3(7.6, 0.75, 0.12), Vector3(10.0, 3.6, fz + 0.06), Color("1d2a4a"))
	Props.label(self, "EMNİYET SİGORTA · ACENTE", Vector3(10.0, 3.62, fz + 0.13), 44, Color("ffd060"), Vector3.ZERO, 6.8)
	Props.label(self, "Kuruluş 1977", Vector3(12.8, 3.35, fz + 0.13), 16, Color("f4f1ea"), Vector3.ZERO, 0.9)
	# Işık: tavan lambası ve vantilatör
	var lamp := OmniLight3D.new()
	lamp.position = c + Vector3(0, 2.7, -0.4)
	lamp.light_color = Color("fff0d0")
	lamp.light_energy = 1.2
	lamp.omni_range = 7.0
	lamp.shadow_enabled = true
	add_child(lamp)
	var fan := Node3D.new()
	fan.position = c + Vector3(0, 2.9, -0.3)
	add_child(fan)
	Props.cyl(fan, 0.08, 0.15, Vector3.ZERO, Color("3a3a40"), Vector3.ZERO, 8)
	for k in 3:
		Props.box(fan, Vector3(0.7, 0.01, 0.12), Vector3(0.38, -0.05, 0).rotated(Vector3.UP, TAU * k / 3.0), Color("6a4a30"), Vector3(0, -rad_to_deg(TAU * k / 3.0), 0))
	var ftw := fan.create_tween().set_loops()
	ftw.tween_property(fan, "rotation:y", TAU, 2.4).from(0.0)
	# Ferit Bey'in masası: kapıya dönük; telefon, kül tablası, dosyalar, isimlik
	_desk(FERIT_DESK, PI, 1.8)
	Props.box(self, Vector3(0.22, 0.09, 0.2), FERIT_DESK + Vector3(0.62, 0.83, -0.05), Color("1a1a1e"))
	Props.box(self, Vector3(0.24, 0.04, 0.06), FERIT_DESK + Vector3(0.62, 0.9, -0.05), Color("1a1a1e"))
	Props.cyl(self, 0.06, 0.012, FERIT_DESK + Vector3(0.62, 0.88, 0.02), Color("d8d8d8"), Vector3(-60, 0, 0), 10)
	Props.cyl(self, 0.07, 0.03, FERIT_DESK + Vector3(-0.55, 0.8, 0.15), Color("8ab0c8"), Vector3.ZERO, 10)
	for k in 4:
		Props.box(self, Vector3(0.34, 0.03, 0.24), FERIT_DESK + Vector3(-0.3, 0.8 + k * 0.032, -0.12), [Color("c8a868"), Color("b89858")][k % 2], Vector3(0, -4 + k * 3, 0))
	Props.box(self, Vector3(0.36, 0.09, 0.05), FERIT_DESK + Vector3(0.05, 0.83, 0.32), Color("c49a45"))
	Props.label(self, "FERİT BEY · MÜDÜR", FERIT_DESK + Vector3(0.05, 0.835, 0.35), 14, Color("2a2a2a"), Vector3.ZERO, 0.34)
	Props.cyl(self, 0.028, 0.08, FERIT_DESK + Vector3(0.25, 0.83, 0.12), Color("a0301a"), Vector3.ZERO, 8, 0.022)
	Props.cyl(self, 0.05, 0.01, FERIT_DESK + Vector3(0.25, 0.79, 0.12), Color("f0ece4"), Vector3.ZERO, 10)
	_chair(FERIT_POS, 0.0, Color("5a3a24"))
	_chair(Vector3(VISITOR.x, 0, VISITOR.z), PI, Color("6a4a30"))
	# Boş masa (batı duvarı): daktilo tuşları sandalyeye dönük
	_desk(TOLGA_DESK, PI / 2.0, 1.3)
	_typewriter(TOLGA_DESK + Vector3(0.0, 0.8, 0.1), 90.0)
	Props.box(self, Vector3(0.3, 0.02, 0.22), TOLGA_DESK + Vector3(0.0, 0.8, -0.38), Color("f4f1ea"), Vector3(0, 6, 0))
	_chair(Vector3(TOLGA_CHAIR.x, 0, TOLGA_CHAIR.z), -PI / 2.0, Color("6a4a30"))
	# Kâtibin masası (doğu duvarı)
	var cd := Vector3(13.25, 0, -7.6)
	_desk(cd, -PI / 2.0, 1.3)
	_typewriter(cd + Vector3(0.0, 0.8, 0.0), -90.0)
	_chair(cd + Vector3(-0.85, 0, 0), PI / 2.0, Color("6a4a30"))
	# Dosya dolabı, portmanto (fötr şapka asılı), takvim, afiş, saat
	for k in 2:
		Props.solid(self, Vector3(0.6, 1.4, 0.55), c + Vector3(-2.6 + k * 0.65, 0.7, -2.7), Color("8a9088"))
		for d in 3:
			Props.box(self, Vector3(0.3, 0.03, 0.02), c + Vector3(-2.6 + k * 0.65, 0.3 + d * 0.42, -2.42), Color("c49a45"))
	var cr := c + Vector3(3.4, 0, -2.5)
	Props.cyl(self, 0.03, 1.8, cr + Vector3(0, 0.9, 0), Color("4a3020"), Vector3.ZERO, 6)
	Props.cyl(self, 0.22, 0.03, cr + Vector3(0, 0.02, 0), Color("4a3020"), Vector3.ZERO, 8)
	Props.cyl(self, 0.17, 0.04, cr + Vector3(0, 1.82, 0), Color("4a4a52"), Vector3.ZERO, 10)
	Props.cyl(self, 0.1, 0.12, cr + Vector3(0, 1.9, 0), Color("4a4a52"), Vector3.ZERO, 10)
	Props.box(self, Vector3(0.5, 0.65, 0.02), c + Vector3(1.6, 1.9, -2.98), Color("f4f1ea"))
	Props.label(self, "1977", c + Vector3(1.6, 2.1, -2.96), 40, Color("b3262d"), Vector3.ZERO, 0.4)
	Props.label(self, "TEMMUZ", c + Vector3(1.6, 1.88, -2.96), 18, Color("2a2a2a"), Vector3.ZERO, 0.36)
	Props.box(self, Vector3(1.1, 0.8, 0.02), c + Vector3(-1.2, 1.9, -2.98), Color("1d2a4a"))
	Props.label(self, "EMNİYET\nSİGORTA", c + Vector3(-1.2, 2.0, -2.96), 30, Color("ffd060"), Vector3.ZERO, 0.9)
	Props.label(self, "Yarınınız emniyette", c + Vector3(-1.2, 1.66, -2.96), 16, Color("f4f1ea"), Vector3.ZERO, 0.9)
	Props.cyl(self, 0.22, 0.04, c + Vector3(-3.97, 2.3, -1.0), Color("f4f1ea"), Vector3(0, 0, 90), 16)
	Props.label(self, "09:40", c + Vector3(-3.94, 2.3, -1.0), 16, Color("1d2330"), Vector3(0, 90, 0), 0.32)


func _desk(p: Vector3, yaw: float, w: float) -> void:
	var d := Node3D.new()
	d.position = p
	d.rotation.y = yaw
	add_child(d)
	Props.set_pattern(Props.box(d, Vector3(w, 0.06, 0.8), Vector3(0, 0.77, 0), Color("7a5432")), Color("7a5432"), "wood")
	for sx: float in [-1.0, 1.0]:
		Props.box(d, Vector3(0.06, 0.74, 0.76), Vector3(sx * (w * 0.5 - 0.05), 0.37, 0), Color("5a3820"))
	Props.box(d, Vector3(w - 0.1, 0.5, 0.04), Vector3(0, 0.5, -0.36), Color("5a3820"))
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(w, 0.8, 0.8)
	cs.shape = bs
	cs.position = Vector3(0, 0.4, 0)
	body.add_child(cs)
	d.add_child(body)


## Sandalye: oturanın arkasında (yaw yönüne bakar); oturma yeri kişinin konumundan 0.15 geride.
func _chair(p: Vector3, yaw: float, col: Color) -> void:
	var ch := Node3D.new()
	ch.position = p
	ch.rotation.y = yaw
	add_child(ch)
	Props.box(ch, Vector3(0.46, 0.05, 0.44), Vector3(0, 0.45, -0.15), col)
	Props.box(ch, Vector3(0.46, 0.5, 0.05), Vector3(0, 0.72, -0.37), col)
	for q: Vector3 in [Vector3(-0.2, 0.22, 0.04), Vector3(0.2, 0.22, 0.04), Vector3(-0.2, 0.22, -0.34), Vector3(0.2, 0.22, -0.34)]:
		Props.box(ch, Vector3(0.04, 0.44, 0.04), q, col.darkened(0.2))


func _typewriter(pos: Vector3, rot: float) -> void:
	var t := Node3D.new()
	t.position = pos
	t.rotation_degrees.y = rot
	add_child(t)
	Props.box(t, Vector3(0.42, 0.1, 0.34), Vector3(0, 0.05, 0), Color("2a3a34"))
	Props.box(t, Vector3(0.4, 0.06, 0.12), Vector3(0, 0.12, -0.08), Color("34463e"), Vector3(-15, 0, 0))
	Props.cyl(t, 0.035, 0.46, Vector3(0, 0.16, -0.15), Color("15191a"), Vector3(0, 0, 90), 8)
	Props.box(t, Vector3(0.28, 0.2, 0.005), Vector3(0, 0.26, -0.16), Color("f4f1ea"), Vector3(-10, 0, 0))
	for r in 3:
		for c in 7:
			Props.box(t, Vector3(0.025, 0.012, 0.025), Vector3(-0.13 + c * 0.043, 0.105 + r * 0.012, r * 0.035), Color("d8d2c0"))


## Sokakta ve kahvehanede insanlar: gazeteci, kahveci, tavla oynayan iki ihtiyar, gazete okuyan biri,
## acentede Ferit Bey (2026'daki müdürün babası: aynı yüz, simsiyah saç) ve kâtip; birkaç yaya.
func _build_people() -> void:
	newsagent = Person.new({"coat": Color("6a5a48"), "pants": Color("3a3a42"), "hat": "fedora", "mustache": true, "glasses": true, "skin": Color("d8a880")})
	newsagent.position = NEWSAGENT
	newsagent.set_meta("no_unclip", true)
	add_child(newsagent)
	newsagent.face_toward(NEWSAGENT + Vector3(0, 0, -1))
	kahveci = Person.new({"coat": Color("f0ece4"), "pants": Color("3a3a42"), "mustache": true, "hair": Color("2a2a2a"), "skin": Color("d8a070"), "apron": Color("e8e0d0")})
	kahveci.position = KAHVE + Vector3(0.5, 0, -0.4)
	kahveci.set_meta("spk", "SPK_KAHVECI")
	kahveci.set_meta("no_unclip", true)
	add_child(kahveci)
	kahveci.face_toward(KAHVE + Vector3(0.5, 0, 3.0))
	var tray := Node3D.new()
	Props.cyl(tray, 0.16, 0.02, Vector3.ZERO, Color("c0c0c4"), Vector3.ZERO, 12)
	for k in 3:
		Props.cyl(tray, 0.026, 0.08, Vector3(-0.07 + k * 0.07, 0.05, 0), Color("a0301a"), Vector3.ZERO, 8, 0.02)
	kahveci.hold_item(tray)
	# Oturanlar: tavlacılar kaldırımdaki masada karşılıklı, biri içeride gazete okur
	var sitters := [
		[KAHVE + Vector3(-2.35, 0, 0.9), PI / 2.0, {"coat": Color("5a5040"), "pants": Color("3a3430"), "mustache": true, "hair": Color("9a9a9a"), "hat": "fedora"}, ""],
		[KAHVE + Vector3(-1.25, 0, 0.9), -PI / 2.0, {"coat": Color("4a5a6a"), "pants": Color("3a3a42"), "mustache": true, "hair": Color("c8c8c8"), "glasses": true}, ""],
		[KAHVE + Vector3(0.6, 0, -2.15), 0.0, {"coat": Color("6a4a3a"), "pants": Color("3a3430"), "mustache": true, "hair": Color("3a2a1e")}, "paper"],
		[KAHVE + Vector3(1.4, 0, 0.35), 0.0, {"coat": Color("8a7a5a"), "pants": Color("4a4038"), "hair": Color("6a6a6a"), "mustache": true}, ""],
	]
	for e in sitters:
		var p := Person.new(e[2])
		p.position = e[0]
		p.rotation.y = e[1]
		p.set_meta("no_talk", true)
		p.set_meta("no_unclip", true)
		p.set_meta("no_audit", true)
		add_child(p)
		p.set_activity("sit")
		_chair(e[0], e[1], Color("7a5432"))
		if e[3] == "paper":
			var pp := Node3D.new()
			Props.box(pp, Vector3(0.42, 0.3, 0.01), Vector3.ZERO, Color("f0ead8"))
			p.hold_item(pp, true)
	# Acente: Ferit Bey (oturur, yüzü kapıya) ve kâtip (daktilonun başında)
	ferit = Person.new({"face": CharKit.random_face(hash(str(MANAGER_LOOK))), "coat": Color("4a4038"), "pants": Color("2a2a30"), "glasses": true,
		"hair": Color("1a1410"), "mustache": true, "skin": Color("e0b08a")})
	ferit.position = FERIT_POS
	ferit.set_meta("no_unclip", true)
	ferit.set_meta("spk", "SPK_AGENCY")
	add_child(ferit)
	ferit.set_activity("sit")
	clerk = Person.new({"coat": Color("c87a4a"), "pants": Color("6a4a3a"), "skirt": true, "hat": "bun", "glasses": true, "hair": Color("4a2a18"), "skin": Color("ecc0a0")})
	clerk.position = Vector3(12.4, 0, -7.6)
	clerk.rotation.y = PI / 2.0
	clerk.set_meta("no_unclip", true)
	clerk.set_meta("no_talk", true)
	add_child(clerk)
	clerk.set_activity("sit")
	# Yayalar: çarşı filesiyle bir teyze, okul önlüklü iki çocuk, sohbet eden iki adam (kaldırımda, oyuncunun yolunda değil)
	var walkers := [
		[Vector3(-8.0, 0, -4.4), {"coat": Color("6a7a4a"), "skirt": true, "hat": "scarf", "scarf": Color("e8e0c8"), "pants": Color("4a4038")}, "basket"],
		[Vector3(6.6, 0, 4.5), {"child": true, "coat": Color("2a3a6a"), "pants": Color("2a3a6a")}, ""],
		[Vector3(7.2, 0, 4.6), {"child": true, "coat": Color("2a3a6a"), "pants": Color("2a3a6a"), "skirt": true}, ""],
		[Vector3(17.0, 0, -4.3), {"coat": Color("8a6a4a"), "pants": Color("6a5a48"), "mustache": true, "hair": Color("1a1410")}, ""],
		[Vector3(17.8, 0, -4.1), {"coat": Color("3a4a5a"), "pants": Color("8a7a5a"), "mustache": true, "hair": Color("2a1e14")}, ""],
	]
	for i in walkers.size():
		var w := Person.new(walkers[i][1])
		w.position = walkers[i][0]
		w.set_meta("no_talk", true)
		add_child(w)
		if walkers[i][2] == "basket":
			w.carry("basket")
		if i in [1, 2]:
			w.face_toward(Vector3(0, 0, 4.5))
		elif i == 3:
			w.face_toward(walkers[4][0])
		elif i == 4:
			w.face_toward(walkers[3][0])
		else:
			w.face_toward(w.position + Vector3(1, 0, 0))


## 2026'daki müdürün görünüşü (Monday._build_office): Ferit Bey aynı yüzle doğar (babası).
const MANAGER_LOOK := {"coat": Color("3a3a42"), "pants": Color("2a2a30"), "glasses": true, "hair": Color("6a6a6a"), "mustache": true, "skin": Color("e0b08a")}


## Kahvehanenin radyosu cızırdar (telsizden önce o çeker): ışığı titrer.
func radio_flicker(on: bool) -> void:
	if radio_light == null:
		return
	radio_light.light_energy = 0.0
	if on:
		var tw := radio_light.create_tween().set_loops(6)
		tw.tween_property(radio_light, "light_energy", 1.4, 0.08)
		tw.tween_property(radio_light, "light_energy", 0.2, 0.12)
