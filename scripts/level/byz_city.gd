class_name ByzCity
extends Node3D
## Bölüm 6b: Konstantinopolis, surların içi, 23 Nisan 1453 (GDD §9.4).
## Deniz kapısından çıkan taş cadde bir meydana açılır. Meydanın kuzeyinde Logothetes'in
## kançılaryası: koridor boyunca yedi oda, yedi memur, yedi mühür (Bizans Labirenti).
## Doğuda kara surları ve Giustiniani, batıda saray avlusu ve İmparator. Güneydoğuda
## beyaz bayrakla çıkılacak kapı.

const GREEK := ["Α", "Β", "Γ", "Δ", "Ε", "Ζ", "Η"]
const START := Vector3(0.0, 0.0, 12.0)
const CELL_START := Vector3(-7.0, 0.0, 14.0)
const NIKO_POS := Vector3(1.5, 0.0, -27.0)
const HALL_Z0 := -30.0          # kançılarya ön duvarı
const ROOM_Z0 := -32.5
const ROOM_Z1 := -40.0
const ROOM_W := 4.0
const GIUST_POS := Vector3(26.0, 0.0, -14.0)
const EMPEROR_POS := Vector3(-27.0, 0.0, -14.0)
const EXIT_POS := Vector3(33.0, 0.0, 4.0)

var clerks: Array[Person] = []
var niko: Person
var nihat: Person
var giustiniani: Person
var emperor: Person
var lights: Array = []
var _t := 0.0
var _sky_mat: ProceduralSkyMaterial
var _env: Environment
var _sun: DirectionalLight3D


func _ready() -> void:
	_build_sky()
	_build_ground()
	_build_street()
	_build_chancery()
	_build_walls()
	_build_palace()
	_build_skyline()
	_build_ayasofya_climb()
	_build_fill()
	_build_life()
	niko = Person.new({"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hair": Color("2a1e14"), "hat": "helm", "mustache": true, "beard": true, "skin": Color("d9a07a")})
	niko.position = NIKO_POS
	add_child(niko)
	Props.interactable(niko, "niko", Vector3(1.0, 1.9, 1.0), Vector3(0, 0.95, 0))
	# Niko'nun "kuzeninin kayığı" (pazarlık mini oyunu): kıyıya çekilmiş küçük kayık ve tabela
	var kb := NIKO_POS + Vector3(2.6, 0, 0.9)
	var hb := Props.solid(self, Vector3(1.0, 1.0, 3.0), kb + Vector3(0, 0.5, 0), Color.WHITE)
	hb.get_child(0).visible = false
	for z in [-0.8, 0.8]:
		for sx in [-0.35, 0.35]:
			Props.box(self, Vector3(0.06, 0.6, 0.06), kb + Vector3(sx, 0.28, z), Color("5a3a22"), Vector3(0, 0, sx * 40.0))
		Props.box(self, Vector3(0.9, 0.08, 0.1), kb + Vector3(0, 0.55, z), Color("6b4428"))
	var boat := Node3D.new()
	boat.position = kb + Vector3(0, 0.62, 0)
	boat.scale = Vector3.ONE * 0.52
	add_child(boat)
	boat.add_child(LowPoly.hull([
		{"z": -2.8, "w": 0.05, "top": 0.75, "bottom": 0.35},
		{"z": -1.8, "w": 0.6, "top": 0.55, "bottom": -0.05},
		{"z": 0.5, "w": 0.75, "top": 0.5, "bottom": -0.1},
		{"z": 2.0, "w": 0.6, "top": 0.55, "bottom": -0.05},
		{"z": 2.6, "w": 0.35, "top": 0.7, "bottom": 0.2},
	], Color("8a5a2a"), Color("b3262d"), 0.4))
	Props.box(boat, Vector3(1.1, 0.06, 0.3), Vector3(0, 0.4, 0.6), Color("a07a4e"))
	Props.box(boat, Vector3(1.1, 0.06, 0.3), Vector3(0, 0.4, -0.8), Color("a07a4e"))
	for side in [-1, 1]:
		Props.cyl(boat, 0.04, 2.8, Vector3(side * 0.5, 0.55, 0.0), Color("c9a878"), Vector3(80, 0, side * 10), 4)
	Props.cyl(self, 0.03, 1.5, kb + Vector3(-0.6, 0.75, 1.2), Color("4a3020"), Vector3.ZERO, 5)
	Props.box(self, Vector3(1.0, 0.3, 0.05), kb + Vector3(-0.6, 1.45, 1.2), Color("c8a868"))
	Props.label(self, "ΚΑΪΚΙ · KAYIK", kb + Vector3(-0.6, 1.45, 1.23), 26, Color("2a1a10"), Vector3.ZERO, 0.95)
	Props.interactable(self, "mg:haggle_niko", Vector3(1.4, 1.2, 2.4), kb + Vector3(0, 0.6, 0))
	# Sokak dolgusu: duvar diplerinde küpler, saksılar, sandıklar; meydanlarda kuyu, araba, güvercinler; yürüyen halk
	Dressing.auto(self, {"style": "byz", "seed": 453, "rect": Rect2(-44, -110, 88, 138), "y_max": 1.0, "walkers": 10, "edge_gap": 2.5, "edge_chance": 0.9,
		"reserved": [Rect2(-14.5, -40.5, 29.0, 10.3), Rect2(-34.0, -25.0, 10.0, 22.0), Rect2(24.0, -24.0, 12.0, 18.0),
			Rect2(27.0, -1.0, 9.0, 9.0), Rect2(-11.0, -72.0, 16.0, 11.0), Rect2(-10.0, 10.5, 6.0, 7.0), Rect2(-36.0, -104.0, 44.0, 40.0)],
		"people": BYZ_PEOPLE})


const BYZ_PEOPLE := [
	{"coat": Color("6a3a5a"), "robe": Color("6a3a5a"), "skin": Color("e0b08a"), "hair": Color("3a2a1e"), "skirt": true},
	{"coat": Color("3a5a6a"), "robe": Color("3a5a6a"), "beard": true, "hat": "hood", "skin": Color("d9a07a")},
	{"coat": Color("a86a3a"), "pants": Color("5a4028"), "mustache": true, "skin": Color("c89070")},
	{"coat": Color("7a8a5a"), "robe": Color("7a8a5a"), "skin": Color("e8b894"), "hair": Color("5a3a1e"), "skirt": true, "hat": "bun"},
	{"coat": Color("d8c8a8"), "robe": Color("d8c8a8"), "beard": true, "skin": Color("c89070")},
	{"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true, "skin": Color("d9a07a")},
	{"coat": Color("5a4a7a"), "pants": Color("3a3a3a"), "hair": Color("2a1e14"), "skin": Color("e8c0a0")},
	{"coat": Color("1e1e22"), "robe": Color("1e1e22"), "beard": true, "hat": "kamelaukion", "hair": Color("8a8a8a"), "skin": Color("e0b08a")},
]


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


func _build_sky() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3f7fc4")
	sm.sky_horizon_color = Color("cfdde6")
	sm.ground_horizon_color = Color("b8b0a0")
	sm.ground_bottom_color = Color("6a604e")
	sm.sun_angle_max = 20.0
	sky.sky_material = sm
	_sky_mat = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.5
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.9
	e.fog_enabled = true
	e.fog_light_color = Color("c4d0da")
	e.fog_density = 0.009
	e.fog_aerial_perspective = 0.4
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.2
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.08
	e.adjustment_contrast = 1.05
	env.environment = e
	add_child(env)
	_env = e
	var sun := DirectionalLight3D.new()
	_sun = sun
	sun.rotation_degrees = Vector3(-42, 28, 0)
	sun.light_color = Color("ffe6c4")
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)
	SkyBody.attach(self, sun)


## Gün batımı (Bölüm 12B · Son Akşam): alçak, turuncu güneş; mor-turuncu gökyüzü.
func make_sunset() -> void:
	_sky_mat.sky_top_color = Color("3a3a78")
	_sky_mat.sky_horizon_color = Color("f0a060")
	_sky_mat.ground_horizon_color = Color("c07850")
	_env.fog_light_color = Color("e8a878")
	_env.fog_density = 0.0035
	_env.ambient_light_energy = 0.4
	_sun.rotation_degrees = Vector3(-9, -95, 0)
	_sun.light_color = Color("ff9a5a")
	_sun.light_energy = 1.3


func _build_ground() -> void:
	var body := Props.solid(self, Vector3(90, 0.2, 80), Vector3(0, -0.1, -10), Color.WHITE)
	Props.set_pattern(body, Color("fff8ec"), "cobble")
	# Caddenin ortasında taş oluk ve kenar taşları
	Props.box(self, Vector3(0.5, 0.02, 34.0), Vector3(0, 0.005, 1.0), Color("7a7264"))
	for sx in [-4.1, 4.1]:
		Props.box(self, Vector3(0.35, 0.12, 30.0), Vector3(sx, 0.06, 3.0), Color("a89c86"))


## İstanbul evi (1453): taş zemin kat (tuğla bantlı), sokağa taşan cumbalı sıvalı üst kat,
## ahşap kirişler, kemerli pencereler ve renkli kepenkler, kiremit çatı.
## front: sokağa bakan yön (+1: +x'e, -1: -x'e). length: sokak boyunca uzunluk (z).
func _house(pos: Vector3, length: float, depth: float, height: float, front: int, idx: int) -> void:
	var h := Node3D.new()
	h.position = pos
	add_child(h)
	var rng := RandomNumberGenerator.new()
	rng.seed = idx * 97 + 13
	var plasters := [Color("e8c890"), Color("d89a78"), Color("efe0c4"), Color("c8a0a0"), Color("b8c4c0"), Color("e0b070")]
	var shutters := [Color("3a6a5a"), Color("3a5a8a"), Color("6a3a2a"), Color("5a6a3a")]
	var plaster: Color = plasters[idx % plasters.size()]
	var shutter: Color = shutters[(idx * 3) % shutters.size()]
	var gf := 3.0
	var fx := front * depth / 2.0            # sokak cephesinin x'i
	# Zemin kat: kesme taş + tuğla bant (çarpışmalı gövde)
	var base := Props.solid(h, Vector3(depth, gf, length), Vector3(0, gf / 2.0, 0), Color.WHITE)
	Props.set_pattern(base, Color("fff4e4"), "ashlar")
	# Üst kat: sokağa 0.7 m taşan cumba, sıvalı
	var up_h := height - gf
	var over := 0.7
	var upper := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(depth + over, up_h, length)
	upper.mesh = bm
	upper.position = Vector3(front * over / 2.0, gf + up_h / 2.0, 0)
	upper.material_override = Props.mat(plaster, 0.0, false, "plaster")
	h.add_child(upper)
	# Cumbanın altındaki eli böğründeler (payandalar) ve kat kirişleri
	for k in 4:
		var z := -length / 2.0 + 0.5 + k * (length - 1.0) / 3.0
		Props.box(h, Vector3(0.12, 0.12, 0.9), Vector3(fx + front * 0.35, gf - 0.25, z), Color("4a3020"), Vector3(0, 90, front * 40))
	Props.box(h, Vector3(0.18, 0.2, length + 0.1), Vector3(fx + front * over, gf + 0.05, 0), Color("4a3020"))
	Props.box(h, Vector3(0.14, 0.16, length + 0.1), Vector3(fx + front * over, height - 0.1, 0), Color("4a3020"))
	for k in 3:
		var z := -length / 2.0 + k * length / 2.0
		Props.box(h, Vector3(0.12, up_h, 0.14), Vector3(fx + front * (over + 0.02), gf + up_h / 2.0, clampf(z, -length / 2.0 + 0.1, length / 2.0 - 0.1)), Color("4a3020"))
	# Çatı: kiremitli, saçaklı beşik çatı
	var roof := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(depth + over + 1.0, 1.5, length + 0.8)
	roof.mesh = pm
	roof.position = Vector3(front * over / 2.0, height + 0.75, 0)
	roof.material_override = Props.mat(Color("fff0e8"), 0.0, false, "tiles")
	h.add_child(roof)
	Props.box(h, Vector3(depth + over + 1.1, 0.12, length + 0.9), Vector3(front * over / 2.0, height + 0.02, 0), Color("5a3a24"))
	# Baca
	if rng.randf() < 0.6:
		Props.box(h, Vector3(0.5, 1.4, 0.5), Vector3(-front * depth * 0.2, height + 1.2, rng.randf_range(-1.5, 1.5)), Color("a8674a"))
	# Üst kat pencereleri: kemerli, kepenkli, saksılı
	var wn := 2 if length < 6.0 else 3
	for k in wn:
		var z := -length / 2.0 + (k + 0.5) * length / wn
		var wx := fx + front * (over + 0.03)
		var wy := gf + up_h * 0.5
		Props.box(h, Vector3(0.05, 1.0, 0.7), Vector3(wx, wy, z), Color("1e1a18"))
		Props.cyl(h, 0.35, 0.05, Vector3(wx, wy + 0.5, z), Color("1e1a18"), Vector3(0, 0, 90), 10)
		Props.box(h, Vector3(0.16, 0.08, 0.9), Vector3(wx + front * 0.05, wy - 0.55, z), Color("d8d0bc"))
		var open := rng.randf() < 0.6
		for sd in [-1, 1]:
			if open:
				Props.box(h, Vector3(0.36, 1.0, 0.04), Vector3(wx + front * 0.2, wy, z + sd * 0.55), shutter, Vector3(0, sd * front * 70, 0))
			else:
				Props.box(h, Vector3(0.04, 1.0, 0.34), Vector3(wx + front * 0.03, wy, z + sd * 0.18), shutter)
		if rng.randf() < 0.55:
			Props.cyl(h, 0.1, 0.16, Vector3(wx + front * 0.1, wy - 0.43, z - 0.2), Color("b8603a"), Vector3.ZERO, 7, 0.12)
			Props.ball(h, 0.14, Vector3(wx + front * 0.1, wy - 0.27, z - 0.2), Color("4a7a3a"), Vector3(1, 0.8, 1), 6)
			if rng.randf() < 0.6:
				Props.ball(h, 0.05, Vector3(wx + front * 0.15, wy - 0.2, z - 0.15), Color("d83a4a"), Vector3.ONE, 5)
	# Zemin kat: kemerli ahşap kapı, küçük pencere, basamak
	var dz := rng.randf_range(-length * 0.2, length * 0.2)
	Props.box(h, Vector3(0.06, 1.9, 1.1), Vector3(fx + front * 0.02, 0.95, dz), Color("5a3a22"))
	Props.cyl(h, 0.55, 0.06, Vector3(fx + front * 0.02, 1.9, dz), Color("5a3a22"), Vector3(0, 0, 90), 10)
	Props.box(h, Vector3(0.12, 0.25, 1.4), Vector3(fx + front * 0.06, 2.35, dz), Color("c8b894"))
	for k in 3:
		Props.ball(h, 0.025, Vector3(fx + front * 0.06, 0.6 + k * 0.4, dz + 0.3), Color("2a2a2a"), Vector3.ONE, 4)
	Props.box(h, Vector3(0.5, 0.14, 1.4), Vector3(fx + front * 0.25, 0.07, dz), Color("b0a48c"))
	var sw := dz + (1.6 if dz < 0.0 else -1.6)
	Props.box(h, Vector3(0.05, 0.6, 0.5), Vector3(fx + front * 0.02, 1.9, sw), Color("1e1a18"))
	for k in 3:
		Props.cyl(h, 0.015, 0.6, Vector3(fx + front * 0.05, 1.9, sw - 0.15 + k * 0.15), Color("3a3a3a"), Vector3.ZERO, 4)
	# Duvar feneri
	if idx % 2 == 0:
		Props.box(h, Vector3(0.4, 0.05, 0.05), Vector3(fx + front * 0.2, 2.6, dz + 0.9), Color("2a2a2a"))
		Props.box(h, Vector3(0.16, 0.24, 0.16), Vector3(fx + front * 0.38, 2.45, dz + 0.9), Color("ffd08a"), Vector3.ZERO, 0.6)


func _build_street() -> void:
	# Deniz kapısı (başlangıç): surun iç yüzü, kemer ve kule
	var gate := Props.solid(self, Vector3(22, 9, 1.8), Vector3(0, 4.5, 19.2), Color.WHITE)
	Props.set_pattern(gate, Color("fff4e4"), "ashlar")
	Props.box(self, Vector3(2.4, 3.2, 0.2), Vector3(0, 1.6, 18.25), Color("4a3020"))
	Props.cyl(self, 1.4, 0.3, Vector3(0, 3.2, 18.25), Color("b0a48c"), Vector3(90, 0, 0), 12)
	var zz := -10.5
	while zz < 11.0:
		Props.box(self, Vector3(0.7, 0.9, 0.9), Vector3(zz, 9.45, 19.2), Color("c8b894"))
		zz += 1.6
	# Cadde boyunca evler (iki sıra, aralarda dar sokaklar)
	var heights := [6.2, 7.0, 6.6, 7.4]
	for i in 4:
		_house(Vector3(-7.0, 0, 10.0 - i * 7.0), 5.5, 5.0, heights[i % 4], 1, i)
		_house(Vector3(7.0, 0, 10.0 - i * 7.0), 5.5, 5.0, heights[(i + 2) % 4], -1, i + 5)
	# Evlerin arasındaki dar sokaklarda kemerler
	for i in 3:
		var z := 10.0 - i * 7.0 - 3.5
		for sx in [-7.0, 7.0]:
			Props.box(self, Vector3(4.6, 0.6, 1.5), Vector3(sx, 4.6, z), Color("d8c8a8"))
			Props.cyl(self, 0.7, 4.6, Vector3(sx, 4.3, z), Color("d8c8a8"), Vector3(0, 0, 90), 10)
	# Caddenin üstünde çamaşır ipleri
	var cloth := [Color("e8e0cc"), Color("b3262d"), Color("3a6a9a"), Color("d8b040"), Color("f4f1ea")]
	for k in 3:
		var z := 8.0 - k * 7.0
		Props.cyl(self, 0.01, 8.2, Vector3(0, 5.2, z), Color("3a3a3a"), Vector3(0, 0, 90), 3)
		for c in 4:
			Props.box(self, Vector3(0.6, 0.7, 0.03), Vector3(-2.5 + c * 1.6, 4.8, z), cloth[(k + c) % cloth.size()], Vector3(0, 0, 0))
	# Meydan: sekizgen havuzlu çeşme, sütun başlığı
	var fc := Vector3(0, 0, -16.0)
	Props.cyl(self, 2.0, 0.7, fc + Vector3(0, 0.35, 0), Color("e8e0cc"), Vector3.ZERO, 8)
	Props.cyl(self, 1.8, 0.05, fc + Vector3(0, 0.66, 0), Color("4a8ab0"), Vector3.ZERO, 8)
	Props.cyl(self, 0.25, 2.2, fc + Vector3(0, 1.4, 0), Color("f0ece0"), Vector3.ZERO, 10)
	Props.cyl(self, 0.6, 0.3, fc + Vector3(0, 2.6, 0), Color("f0ece0"), Vector3.ZERO, 10, 0.3)
	Props.cyl(self, 0.7, 0.15, fc + Vector3(0, 2.8, 0), Color("d8b040"), Vector3.ZERO, 10)
	for k in 4:
		var a := TAU * k / 4.0
		Props.cyl(self, 0.03, 0.5, fc + Vector3(sin(a) * 0.4, 2.3, cos(a) * 0.4), Color("8ac8e8"), Vector3(cos(a) * 60, 0, -sin(a) * 60), 4)
	var col := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var cy := CylinderShape3D.new()
	cy.radius = 2.0
	cy.height = 0.8
	cs.shape = cy
	col.position = fc + Vector3(0, 0.4, 0)
	col.add_child(cs)
	add_child(col)
	# Güvercinler
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	for k in 9:
		var a := rng.randf() * TAU
		var r := rng.randf_range(2.4, 3.6)
		var gp := fc + Vector3(sin(a) * r, 0.1, cos(a) * r)
		Props.ball(self, 0.09, gp, Color("8a8f9a"), Vector3(1.0, 0.8, 1.4), 6)
		Props.ball(self, 0.05, gp + Vector3(0, 0.08, 0.1), Color("5a6070"), Vector3.ONE, 5)
	# Pazar tezgâhları (meydanın iki yanında)
	var aw := [Color("b3262d"), Color("d8b040"), Color("3a6a9a"), Color("5a8a4a")]
	var goods := [Color("e0a020"), Color("6a2a4a"), Color("d86a3a"), Color("8aa84a"), Color("e8e0cc")]
	for k in 4:
		var sp := Vector3(-5.0 if k < 2 else 5.0, 0, -12.5 - (k % 2) * 6.5)
		var face := 1 if k < 2 else -1
		Props.solid(self, Vector3(1.0, 0.9, 2.2), sp + Vector3(0, 0.45, 0), Color("7a5a38"))
		for c in 4:
			Props.cyl(self, 0.04, 2.3, sp + Vector3(-0.45 + (c % 2) * 0.9, 1.15, -1.0 + (c / 2) * 2.0), Color("4a3020"), Vector3.ZERO, 4)
		Props.box(self, Vector3(1.6, 0.05, 2.6), sp + Vector3(face * 0.3, 2.3, 0), aw[k], Vector3(0, 0, -face * 12))
		for c in 6:
			Props.ball(self, 0.12, sp + Vector3(face * 0.1, 1.0, -0.8 + c * 0.32), goods[(k + c) % goods.size()], Vector3.ONE, 6)
		# Amforalar ve sepetler
		for c in 2:
			var ap := sp + Vector3(-face * 0.9, 0, -0.6 + c * 1.1)
			Props.ball(self, 0.22, ap + Vector3(0, 0.4, 0), Color("b8683a"), Vector3(1, 1.5, 1), 8)
			Props.cyl(self, 0.08, 0.25, ap + Vector3(0, 0.85, 0), Color("b8683a"), Vector3.ZERO, 6)
	# Yönler: tabelalar
	for d in [[Vector3(-3.0, 0, -20.5), "ΚΑΓΚΕΛΛΑΡΙΑ ↑"], [Vector3(8.5, 0, -18.5), "ΤΕΙΧΗ →"], [Vector3(-8.5, 0, -18.5), "← ΠΑΛΑΤΙΟΝ"]]:
		Props.cyl(self, 0.05, 2.0, d[0] + Vector3(0, 1.0, 0), Color("4a3020"), Vector3.ZERO, 5)
		Props.box(self, Vector3(2.4, 0.45, 0.06), d[0] + Vector3(0, 1.9, 0), Color("e8e0cc"))
		Props.label(self, d[1], d[0] + Vector3(0, 1.9, 0.04), 30, Color("5a2a2a"), Vector3.ZERO, 2.2)


## Şehrin silüeti: Ayasofya (1453'te minaresiz), kubbeli kiliseler, Konstantin Sütunu, serviler.
func _build_skyline() -> void:
	var ay := Vector3(-14.0, 0, -82.0)
	var pink := Color("d8a488")
	var lead := Color("8a929c")
	var mass := Props.solid(self, Vector3(34, 16, 34), ay + Vector3(0, 8, 0), Color.WHITE)
	Props.set_pattern(mass, pink, "plaster")
	# Ana kubbe (kasnak + kurşun kubbe), yarım kubbeler, payanda kuleleri
	Props.cyl(self, 11.0, 4.0, ay + Vector3(0, 18.0, 0), pink, Vector3.ZERO, 24)
	for k in 24:
		var a := TAU * k / 24.0
		Props.box(self, Vector3(0.9, 1.6, 0.2), ay + Vector3(sin(a) * 11.02, 18.3, cos(a) * 11.02), Color("2a2a30"), Vector3(0, rad_to_deg(a), 0))
	Props.ball(self, 11.0, ay + Vector3(0, 20.0, 0), lead, Vector3(1.0, 0.55, 1.0), 24)
	for s in [-1, 1]:
		Props.ball(self, 8.0, ay + Vector3(0, 16.0, s * 12.0), lead, Vector3(1.0, 0.6, 0.8), 18)
		for sx in [-1, 1]:
			Props.box(self, Vector3(5, 22, 5), ay + Vector3(sx * 16.0, 11.0, s * 16.0), pink.darkened(0.08))
	Props.box(self, Vector3(0.2, 2.5, 0.2), ay + Vector3(0, 27.5, 0), Color("d8b040"))
	Props.box(self, Vector3(1.4, 0.2, 0.2), ay + Vector3(0, 28.2, 0), Color("d8b040"))
	# Kubbeli küçük kiliseler
	for c in [[Vector3(-17.0, 0, 6.0), Color("d8b89a")], [Vector3(17.5, 0, 8.0), Color("e0c8a8")], [Vector3(14.0, 0, -48.0), Color("d8a488")]]:
		var p: Vector3 = c[0]
		var body := Props.solid(self, Vector3(8, 7, 10), p + Vector3(0, 3.5, 0), Color.WHITE)
		Props.set_pattern(body, Color("fff4e4"), "ashlar")
		Props.cyl(self, 2.4, 2.2, p + Vector3(0, 8.1, 0), c[1], Vector3.ZERO, 12)
		for k in 8:
			var a := TAU * k / 8.0
			Props.box(self, Vector3(0.4, 1.0, 0.1), p + Vector3(sin(a) * 2.42, 8.2, cos(a) * 2.42), Color("2a2a30"), Vector3(0, rad_to_deg(a), 0))
		Props.ball(self, 2.5, p + Vector3(0, 9.2, 0), Color("b5533a"), Vector3(1, 0.7, 1), 12)
		Props.box(self, Vector3(0.12, 1.0, 0.12), p + Vector3(0, 11.3, 0), Color("d8b040"))
		Props.box(self, Vector3(0.6, 0.12, 0.12), p + Vector3(0, 11.5, 0), Color("d8b040"))
		var roof := MeshInstance3D.new()
		var pm := PrismMesh.new()
		pm.size = Vector3(8.6, 1.6, 10.6)
		roof.mesh = pm
		roof.position = p + Vector3(0, 7.8, 0)
		roof.material_override = Props.mat(Color("fff0e8"), 0.0, false, "tiles")
		add_child(roof)
	# Konstantin Sütunu (porfir, halkalı)
	var cp := Vector3(-22.0, 0, -52.0)
	Props.set_pattern(Props.solid(self, Vector3(4, 3, 4), cp + Vector3(0, 1.5, 0), Color.WHITE), Color("e8e0cc"), "ashlar")
	Props.cyl(self, 1.4, 26.0, cp + Vector3(0, 16.0, 0), Color("7a3a4a"), Vector3.ZERO, 12)
	for k in 7:
		Props.cyl(self, 1.5, 0.35, cp + Vector3(0, 5.0 + k * 3.6, 0), Color("d8b040"), Vector3.ZERO, 12)
	# Serviler
	var rng := RandomNumberGenerator.new()
	rng.seed = 330
	for p in [Vector3(-11.5, 0, 14.0), Vector3(11.5, 0, 15.0), Vector3(-12.0, 0, -6.0), Vector3(12.5, 0, -9.0),
			Vector3(-20.0, 0, -22.0), Vector3(-21.0, 0, -6.0), Vector3(20.0, 0, -28.0), Vector3(22.0, 0, 2.0),
			Vector3(-30.0, 0, 8.0), Vector3(-9.5, 0, -44.0), Vector3(9.0, 0, -45.0), Vector3(-34.0, 0, -30.0)]:
		var hgt := rng.randf_range(6.0, 9.5)
		Props.cyl(self, 0.15, 1.0, p + Vector3(0, 0.5, 0), Color("4a3020"), Vector3.ZERO, 5)
		Props.cyl(self, 0.9, hgt, p + Vector3(0, 0.8 + hgt / 2.0, 0), Color("2e4a2a"), Vector3.ZERO, 8, 0.05)


## Ayasofya'ya tırmanış (yan görev): kançılaryanın arkasından meydana yol, güney cephede çatı onarım iskelesi
## (üç rampa, zıplamadan çıkılır), çatıda tetik. Kubbe ve yarım kubbeler katı: içlerinden geçilmez.
const AYA := Vector3(-14.0, 0, -82.0)

func _build_ayasofya_climb() -> void:
	# Meydan ve yol zemini (oyun alanı zemini z=-50'de biter)
	Props.set_pattern(Props.solid(self, Vector3(60, 0.2, 62), Vector3(-14, -0.1, -80), Color.WHITE), Color("fff8ec"), "cobble")
	# Görünmez sınır: meydan ve yol (buradaki uzak dolgu evler katı değil; içlerinden geçilip boşluğa düşülmesin)
	for spec in [[Vector3(0.3, 6, 46), Vector3(-37, 3, -82)], [Vector3(0.3, 6, 46), Vector3(9, 3, -82)],
			[Vector3(46, 6, 0.3), Vector3(-14, 3, -105)], [Vector3(20.5, 6, 0.3), Vector3(-26.75, 3, -59)],
			[Vector3(6.5, 6, 0.3), Vector3(5.75, 3, -59)], [Vector3(0.3, 6, 18), Vector3(2.5, 3, -50)],
			# Batı: yoldan Konstantin Sütunu'nun dibine açılan köşe
			[Vector3(0.3, 6, 4.5), Vector3(-16.5, 3, -43.25)], [Vector3(12.0, 6, 0.3), Vector3(-22.5, 3, -45.5)],
			[Vector3(0.3, 6, 13.5), Vector3(-28.5, 3, -52.25)]]:
		var bw := Props.solid(self, spec[0], spec[1], Color.WHITE)
		bw.get_child(0).visible = false
	# Kubbe kasnağı ve yarım kubbeler: çatıda yürürken içlerine girilmesin
	var drum := StaticBody3D.new()
	var dcs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 11.2
	cyl.height = 12.0
	dcs.shape = cyl
	drum.position = AYA + Vector3(0, 22.0, 0)
	drum.add_child(dcs)
	add_child(drum)
	for sgn in [-1, 1]:
		var hd := Props.solid(self, Vector3(15.0, 5.0, 12.0), AYA + Vector3(0, 18.5, sgn * 12.0), Color.WHITE)
		hd.get_child(0).visible = false
	# Çatının kenarından düşmeyi zorlaştıran alçak korkuluk (görünmez, 0.6 m)
	# Güney kenarda iskelenin çıktığı yerde (x = -5 .. 0) boşluk
	for spec in [[Vector3(26, 0.6, 0.2), Vector3(-4.0, 16.3, 17.0)], [Vector3(3, 0.6, 0.2), Vector3(15.5, 16.3, 17.0)], [Vector3(34, 0.6, 0.2), Vector3(0, 16.3, -17.0)],
			[Vector3(0.2, 0.6, 34), Vector3(17.0, 16.3, 0)], [Vector3(0.2, 0.6, 34), Vector3(-17.0, 16.3, 0)]]:
		var rail := Props.solid(self, spec[0], AYA + spec[1], Color.WHITE)
		rail.get_child(0).visible = false
	# Güney cephe onarım iskelesi: -14 → -4 → -14 → -4 (x), her rampada 5.33 m yükselir
	var wood := Color("8a6440")
	var zf := AYA.z + 17.0            # güney cephe (z = -65)
	var lane_a := zf + 3.4           # dış şerit
	var lane_b := zf + 1.4           # iç şerit
	var h1 := 16.0 / 3.0
	Props.ramp(self, Vector3(-15.0, 0.0, lane_a), Vector3(-4.0, h1, lane_a), 1.8, wood)
	Props.solid(self, Vector3(2.4, 0.2, 4.2), Vector3(-2.8, h1 - 0.1, (lane_a + lane_b) * 0.5), wood)
	Props.ramp(self, Vector3(-4.0, h1, lane_b), Vector3(-15.0, h1 * 2.0, lane_b), 1.8, wood)
	Props.solid(self, Vector3(2.4, 0.2, 4.2), Vector3(-16.2, h1 * 2.0 - 0.1, (lane_a + lane_b) * 0.5), wood)
	Props.ramp(self, Vector3(-15.0, h1 * 2.0, lane_a), Vector3(-4.0, 16.0, lane_a), 1.8, wood)
	Props.solid(self, Vector3(3.0, 0.2, 5.6), Vector3(-2.5, 15.85, zf + 1.6), wood)
	# Görünmez korkuluklar: şeritler arası ve dış kenar (rampadan yana düşülmesin; sahanlıklar açık)
	for wz in [(lane_a + lane_b) * 0.5, lane_a + 0.95]:
		var wall := Props.solid(self, Vector3(11.0, 17.5, 0.12), Vector3(-9.5, 8.75, wz), Color.WHITE)
		wall.get_child(0).visible = false
	# Direkler, korkuluklar, makara ve kova
	for x in [-16.8, -12.0, -8.0, -4.0, -1.4]:
		for z in [lane_a + 1.0, zf + 0.4]:
			Props.cyl(self, 0.09, 16.5, Vector3(x, 8.25, z), Color("6b4428"), Vector3.ZERO, 5)
	for y in [h1 + 1.0, h1 * 2.0 + 1.0, 17.0]:
		Props.box(self, Vector3(14.0, 0.08, 0.08), Vector3(-9.5, y, lane_a + 0.95), Color("6b4428"))
	Props.cyl(self, 0.35, 0.2, Vector3(-1.4, 17.8, lane_a + 1.0), Color("5a4028"), Vector3(90, 0, 0), 10)
	Props.cyl(self, 0.01, 15.0, Vector3(-1.1, 10.3, lane_a + 1.0), Color("c8b894"), Vector3.ZERO, 3)
	Props.cyl(self, 0.25, 0.4, Vector3(-1.1, 2.8, lane_a + 1.0), Color("7a5232"), Vector3.ZERO, 8)
	# Tabela
	Props.cyl(self, 0.05, 2.0, Vector3(-17.0, 1.0, zf + 6.0), Color("4a3020"), Vector3.ZERO, 5)
	Props.box(self, Vector3(2.6, 0.5, 0.06), Vector3(-17.0, 1.9, zf + 6.0), Color("e8e0cc"))
	Props.label(self, "ΕΡΓΑ · ΣΚΑΛΩΣΙΑ ↑", Vector3(-17.0, 1.9, zf + 6.04), 30, Color("5a2a2a"), Vector3.ZERO, 2.4)
	# Yolun başında yön tabelası (kançılaryanın arkası)
	Props.cyl(self, 0.05, 2.0, Vector3(-6.0, 1.0, -44.0), Color("4a3020"), Vector3.ZERO, 5)
	Props.box(self, Vector3(2.4, 0.45, 0.06), Vector3(-6.0, 1.9, -44.0), Color("e8e0cc"))
	Props.label(self, "ΑΓΙΑ ΣΟΦΙΑ ↑", Vector3(-6.0, 1.9, -43.96), 30, Color("5a2a2a"), Vector3.ZERO, 2.2)
	# Konstantin Sütunu'nda dilek (yan görev) ve meydanda ikon ressamı (yan karakter)
	Props.interactable(self, "ev:column", Vector3(4.6, 3.0, 4.6), Vector3(-22.0, 1.5, -52.0))
	var ep := Vector3(-24.0, 0, -61.5)
	for sx in [-0.3, 0.3]:
		Props.cyl(self, 0.03, 1.6, ep + Vector3(sx, 0.8, 0.9), Color("6b4428"), Vector3(-8, 0, 0), 4)
	Props.box(self, Vector3(0.8, 0.9, 0.04), ep + Vector3(0, 1.35, 0.95), Color("e8d4a0"), Vector3(-8, 0, 0))
	Props.box(self, Vector3(0.5, 0.5, 0.01), ep + Vector3(0, 1.4, 0.98), Color("c8a040"), Vector3(-8, 0, 0))
	Props.ball(self, 0.1, ep + Vector3(0, 1.5, 0.99), Color("e0b090"), Vector3(1, 1.2, 0.2), 8)
	var painter := Person.new({"coat": Color("3a5a8a"), "pants": Color("2a2a30"), "hat": "kamelaukion", "beard": true, "hair": Color("3a2a1e")})
	painter.position = ep
	painter.rotation.y = PI
	add_child(painter)
	Props.interactable(self, "npc:painter", Vector3(1.2, 2.0, 1.2), ep + Vector3(0, 1.0, 0))
	# Çatıda tetik: görev, Tolga'nın cümlesi, aşağıdan bir memurun bağırışı
	Props.trigger(self, Vector3(-2.6, 17.0, zf - 1.0), Vector3(4.0, 2.4, 5.0), func():
		GameState.flags["climbed_ayasofya"] = true
		var hud := get_tree().get_first_node_in_group("hud") as Hud
		if hud:
			hud.bark("SPK_TOLGA", "D_AYA_TOP", 5.0)
			get_tree().create_timer(5.2).timeout.connect(func():
				if is_instance_valid(hud):
					hud.bark("SPK_CLERK", "D_AYA_CLERK", 4.5)))


## Şehri doldurur: oyun alanlarının dışında kalan her yere ev blokları, çevreye surlar,
## uzağa daha basit çatılar ve ufka tepeler. Uzaktaki evler dış hatsız ve az parçalı çizilir.
const _RESERVED := [
	Rect2(-10.0, -23.0, 20.0, 41.0),   # ana cadde, ilk sıra evler, meydan
	Rect2(-34.0, -18.5, 67.0, 8.5),    # doğu-batı caddesi (saray ↔ surlar), 8 m
	Rect2(-16.0, -42.0, 32.0, 19.0),   # kançılarya ve önündeki revak
	Rect2(29.0, -60.0, 22.0, 85.0),    # kara surları
	Rect2(21.0, -12.0, 13.0, 19.0),    # Giustiniani'den çıkış kapısına giden yol
	Rect2(-34.0, -25.0, 14.0, 22.0),   # saray avlusu
	Rect2(-22.0, 1.0, 10.0, 10.0),     # kilise (batı)
	Rect2(12.5, 3.0, 10.0, 10.0),      # kilise (doğu)
	Rect2(9.0, -53.0, 10.0, 10.0),     # kilise (kuzey)
	Rect2(-26.0, -56.0, 8.0, 8.0),     # Konstantin Sütunu
	Rect2(-36.0, -104.0, 44.0, 44.0),  # Ayasofya
	Rect2(-16.0, -62.0, 18.0, 22.0),   # kançılaryanın arkasından Ayasofya meydanına giden yol
]


func _reserved(x: float, z: float, pad: float) -> bool:
	for r in _RESERVED:
		var rr: Rect2 = r
		if rr.grow(pad).has_point(Vector2(x, z)):
			return true
	return false


func _fill_mat(color: Color, pattern: String) -> StandardMaterial3D:
	return Props.mat(color, 0.0, false, pattern, false)


func _fbox(size: Vector3, pos: Vector3, m: Material, rot_y := 0.0) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = pos
	mi.rotation.y = rot_y
	mi.material_override = m
	add_child(mi)


func _build_fill() -> void:
	# Uzak zemin: oyun alanının ötesine uzanan kaldırım ve toprak
	_fbox(Vector3(400, 0.1, 400), Vector3(0, -0.07, -40), _fill_mat(Color("d8ccb4"), "concrete"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 1204
	var plasters := [Color("e8c890"), Color("d89a78"), Color("efe0c4"), Color("c8a0a0"), Color("b8c4c0"), Color("e0b070"), Color("d8b89a")]
	var roof_m := _fill_mat(Color("fff0e8"), "tiles")
	var stone_m := _fill_mat(Color("fff4e4"), "ashlar")
	var cell := 6.6
	var face_dress := Dressing.new(1204)
	var z := 17.0
	while z > -125.0:
		var x := -74.0
		while x < 34.0:
			var cx := x + rng.randf_range(-0.8, 0.8)
			var cz := z + rng.randf_range(-0.8, 0.8)
			if not _reserved(cx, cz, 2.2):
				var w := rng.randf_range(4.6, 6.2)
				var d := rng.randf_range(4.6, 6.2)
				var h := rng.randf_range(5.0, 9.5)
				var near := Vector2(cx, cz).distance_to(Vector2(0, -10)) < 45.0
				var rot := deg_to_rad(rng.randf_range(-6, 6))
				var pm: Color = plasters[rng.randi() % plasters.size()]
				# Gövde: yakındakiler taş zemin kat + sıvalı üst kat, uzaktakiler tek parça
				if near:
					var body := StaticBody3D.new()
					body.position = Vector3(cx, 0, cz)
					body.rotation.y = rot
					add_child(body)
					var cs := CollisionShape3D.new()
					var bs := BoxShape3D.new()
					bs.size = Vector3(w, h, d)
					cs.shape = bs
					cs.position = Vector3(0, h / 2.0, 0)
					body.add_child(cs)
					body.set_meta("wall", true)   # görünür duvar sayılsın (sokak dolgusu dibine eşya koyar)
					_fbox(Vector3(w, 3.0, d), Vector3(cx, 1.5, cz), stone_m, rot)
					_fbox(Vector3(w + 0.5, h - 3.0, d + 0.5), Vector3(cx, 3.0 + (h - 3.0) / 2.0, cz), _fill_mat(pm, "plaster"), rot)
					# Dört cephe: kepenkli pencereler, kat kirişi; bir cephede kapı
					var door_side := rng.randi() % 4
					var shutter: Color = [Color("3a6a5a"), Color("3a5a8a"), Color("6a3a2a"), Color("5a6a3a")][rng.randi() % 4]
					for side in 4:
						var fy := rot + side * PI / 2.0
						var half := (d if side % 2 == 0 else w) / 2.0
						var fw := w if side % 2 == 0 else d
						face_dress.at(Vector3(cx, 0, cz) + Vector3(0, 0, half + 0.01).rotated(Vector3.UP, fy), fy)
						face_dress.house_face(fw, h, side == door_side, shutter, 3.0, 0.25)
				else:
					_fbox(Vector3(w, h, d), Vector3(cx, h / 2.0, cz), _fill_mat(pm, "plaster"), rot)
				# Kiremit çatı (dörtte biri düz dam, bazılarında küçük kubbe)
				var roll := rng.randf()
				if roll < 0.78:
					var roof := MeshInstance3D.new()
					var prm := PrismMesh.new()
					prm.size = Vector3(w + 0.9, rng.randf_range(1.2, 1.8), d + 0.9)
					roof.mesh = prm
					roof.position = Vector3(cx, h + prm.size.y / 2.0, cz)
					roof.rotation.y = rot + (PI / 2.0 if rng.randf() < 0.5 else 0.0)
					roof.material_override = roof_m
					add_child(roof)
				elif roll < 0.9:
					var dome := MeshInstance3D.new()
					var sm := SphereMesh.new()
					sm.radius = minf(w, d) * 0.35
					sm.height = sm.radius * 1.4
					sm.radial_segments = 10
					sm.rings = 5
					dome.mesh = sm
					dome.position = Vector3(cx, h, cz)
					dome.material_override = _fill_mat(Color("b5533a"), "")
					add_child(dome)
				if rng.randf() < 0.35:
					_fbox(Vector3(0.5, 1.3, 0.5), Vector3(cx + w * 0.25, h + 1.0, cz), _fill_mat(Color("a8674a"), ""), rot)
				# Arada bir servi
				if rng.randf() < 0.12:
					var tp := Vector3(cx + w / 2.0 + 1.2, 0, cz)
					if not _reserved(tp.x, tp.z, 0.5):
						var th := rng.randf_range(6.0, 9.0)
						var tree := MeshInstance3D.new()
						var tm := CylinderMesh.new()
						tm.bottom_radius = 0.9
						tm.top_radius = 0.05
						tm.height = th
						tm.radial_segments = 8
						tree.mesh = tm
						tree.position = tp + Vector3(0, 0.8 + th / 2.0, 0)
						tree.material_override = _fill_mat(Color("2e4a2a"), "")
						add_child(tree)
			x += cell
		z -= cell
	face_dress.build(self)
	# Çevre surları: güneyde Haliç tarafı, batıda Marmara tarafı
	var wall_m := _fill_mat(Color("fff0e0"), "ashlar")
	for seg in [[Vector3(-42.5, 5.0, 19.4), Vector3(63, 10, 2)], [Vector3(27.5, 5.0, 19.4), Vector3(33, 10, 2)],
			[Vector3(-80.0, 5.0, -52.0), Vector3(2, 10, 146)]]:
		var body := Props.solid(self, seg[1], seg[0], Color.WHITE)
		(body.get_child(0) as MeshInstance3D).material_override = wall_m
	var k := -73.0
	while k < 44.0:
		if absf(k) > 11.5:
			_fbox(Vector3(0.7, 0.9, 1.0), Vector3(k, 10.45, 19.4), wall_m)
		k += 1.6
	for tz in [-120.0, -96.0, -72.0, -48.0, -24.0, 0.0]:
		_fbox(Vector3(6, 15, 6), Vector3(-80.0, 7.5, tz), wall_m)
	for tx in [-64.0, -40.0, -18.0, 16.0, 38.0]:
		_fbox(Vector3(6, 15, 6), Vector3(tx, 7.5, 19.4), wall_m)
	# Ufuk: kuzeyde ve batıda yeşil-kahve tepeler, sur dışında deniz
	for hp in [[Vector3(-60, -30, -210), 70.0], [Vector3(20, -34, -220), 80.0], [Vector3(-150, -30, -110), 75.0],
			[Vector3(90, -40, -200), 70.0], [Vector3(-140, -34, 20), 60.0]]:
		var hill := MeshInstance3D.new()
		var hm := SphereMesh.new()
		hm.radius = hp[1]
		hm.height = hp[1] * 2.0
		hm.radial_segments = 16
		hm.rings = 8
		hill.mesh = hm
		hill.position = hp[0]
		hill.scale = Vector3(1.0, 0.55, 1.0)
		hill.material_override = _fill_mat(Color("7a8a5a"), "")
		add_child(hill)
	var sea := MeshInstance3D.new()
	var sp := PlaneMesh.new()
	sp.size = Vector2(500, 200)
	sea.mesh = sp
	sea.position = Vector3(0, -0.3, 125)
	sea.material_override = _fill_mat(Color("4a7a9a"), "")
	add_child(sea)


## Sokak hayatı: halk, keşiş, satıcılar, kedi.
func _build_life() -> void:
	var people := [
		[Vector3(-4.6, 0, -12.0), {"coat": Color("6a3a5a"), "robe": Color("6a3a5a"), "skin": Color("e0b08a"), "hair": Color("3a2a1e"), "skirt": true}],
		[Vector3(4.6, 0, -18.5), {"coat": Color("3a5a6a"), "robe": Color("3a5a6a"), "beard": true, "hat": "hood", "skin": Color("d9a07a")}],
		[Vector3(-2.4, 0, -14.2), {"coat": Color("1e1e22"), "robe": Color("1e1e22"), "beard": true, "hat": "kamelaukion", "hair": Color("8a8a8a"), "skin": Color("e0b08a")}],
		[Vector3(2.8, 0, -17.8), {"coat": Color("a86a3a"), "pants": Color("5a4028"), "mustache": true, "skin": Color("c89070")}],
		[Vector3(-2.2, 0, 4.5), {"coat": Color("7a8a5a"), "robe": Color("7a8a5a"), "skin": Color("e8b894"), "hair": Color("5a3a1e"), "skirt": true, "hat": "bun"}],
		[Vector3(2.6, 0, -4.0), {"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true, "skin": Color("d9a07a")}],
		[Vector3(-3.0, 0, -24.0), {"coat": Color("d8c8a8"), "robe": Color("d8c8a8"), "beard": true, "skin": Color("c89070")}],
	]
	for k in people.size():
		var pp: Array = people[k]
		var person := Person.new(pp[1])
		person.position = pp[0]
		person.rotation.y = randf_range(-PI, PI) if k > 3 else (PI / 2.0 if pp[0].x < 0 else -PI / 2.0)
		add_child(person)
	# Kedi (çeşmenin kenarında)
	var cat := Vector3(1.9, 0.72, -15.2)
	Props.ball(self, 0.16, cat, Color("d8883a"), Vector3(1.0, 0.7, 1.6), 8)
	Props.ball(self, 0.1, cat + Vector3(0, 0.1, 0.22), Color("d8883a"), Vector3.ONE, 6)
	for s in [-1, 1]:
		Props.prism(self, Vector3(0.05, 0.07, 0.03), cat + Vector3(s * 0.05, 0.2, 0.22), Color("d8883a"))


# ---------------------------------------------------------------- kançılarya (labirent)

func _build_chancery() -> void:
	var x0 := -3.5 * ROOM_W
	var x1 := 3.5 * ROOM_W
	var wall_c := Color("d8c8a8")
	# Ön duvar (kapı ortada) ve arka duvar
	# Ön duvar: ortada 2.4 m'lik kapı aralığı, üstünde lento
	_wall(Vector3(-1.2 - x0, 5.0, 0.3), Vector3((x0 - 1.2) / 2.0, 2.5, HALL_Z0), wall_c, true)
	_wall(Vector3(x1 - 1.2, 5.0, 0.3), Vector3((x1 + 1.2) / 2.0, 2.5, HALL_Z0), wall_c, false)
	_wall(Vector3(2.4, 1.8, 0.3), Vector3(0, 4.1, HALL_Z0), wall_c, false)
	_wall(Vector3(x1 - x0, 5.0, 0.3), Vector3(0, 2.5, ROOM_Z1), wall_c, false)
	_wall(Vector3(0.3, 5.0, ROOM_Z1 - HALL_Z0), Vector3(x0, 2.5, (HALL_Z0 + ROOM_Z1) / 2.0), wall_c, false)
	_wall(Vector3(0.3, 5.0, ROOM_Z1 - HALL_Z0), Vector3(x1, 2.5, (HALL_Z0 + ROOM_Z1) / 2.0), wall_c, false)
	Props.solid(self, Vector3(x1 - x0, 0.3, HALL_Z0 - ROOM_Z1), Vector3(0, 5.1, (HALL_Z0 + ROOM_Z1) / 2.0), Color("b5533a"))
	# Kapının üstünde yazı
	Props.box(self, Vector3(5.0, 0.7, 0.1), Vector3(0, 4.0, HALL_Z0 + 0.2), Color("8a2b22"))
	Props.label(self, "ΛΟΓΟΘΕΤΗΣ · ΜΙΣΑΦΙΡ ΙΖΝΙ", Vector3(0, 4.0, HALL_Z0 + 0.26), 36, Color("f2e6c9"), Vector3.ZERO, 4.6)
	# Cephe: mermer sütunlu revak, alınlık ve kiremit çatı
	for cx in [-12.0, -9.0, -6.0, -3.0, 3.0, 6.0, 9.0, 12.0]:
		var c := Props.solid(self, Vector3(0.5, 4.6, 0.5), Vector3(cx, 2.3, HALL_Z0 + 1.0), Color.WHITE)
		c.get_child(0).queue_free()
		var shaft := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.26
		cm.bottom_radius = 0.3
		cm.height = 4.4
		cm.radial_segments = 10
		shaft.mesh = cm
		shaft.position = Vector3(0, 0, 0)
		shaft.material_override = Props.mat(Color.WHITE, 0.0, false, "marble")
		c.add_child(shaft)
		Props.box(self, Vector3(0.8, 0.3, 0.8), Vector3(cx, 4.65, HALL_Z0 + 1.0), Color("e8e0cc"))
		Props.box(self, Vector3(0.8, 0.2, 0.8), Vector3(cx, 0.1, HALL_Z0 + 1.0), Color("d8d0bc"))
	var arch := MeshInstance3D.new()
	var am := BoxMesh.new()
	am.size = Vector3(28.6, 0.5, 2.2)
	arch.mesh = am
	arch.position = Vector3(0, 5.05, HALL_Z0 + 0.8)
	arch.material_override = Props.mat(Color.WHITE, 0.0, false, "marble")
	add_child(arch)
	var ped := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(29.4, 2.2, HALL_Z0 - ROOM_Z1 + 3.0)
	ped.mesh = pm
	ped.position = Vector3(0, 6.4, (HALL_Z0 + ROOM_Z1) / 2.0 + 1.0)
	ped.material_override = Props.mat(Color("fff0e8"), 0.0, false, "tiles")
	add_child(ped)
	Props.ball(self, 0.5, Vector3(0, 6.4, HALL_Z0 + 2.5), Color("d8b040"), Vector3(1, 1, 0.3), 10)
	Props.label(self, "ΧΡ", Vector3(0, 6.4, HALL_Z0 + 2.66), 60, Color("8a2b22"), Vector3.ZERO, 0.8)
	# Odalar: koridorun kuzeyinde, aralarında bölmeler
	for i in 7:
		var cx := x0 + ROOM_W * (i + 0.5)
		if i > 0:
			_wall_in(Vector3(0.2, 5.0, ROOM_Z1 - ROOM_Z0), Vector3(x0 + ROOM_W * i, 2.5, (ROOM_Z0 + ROOM_Z1) / 2.0))
		# Oda ön duvarı (kapı aralığıyla)
		_wall_in(Vector3(1.3, 5.0, 0.2), Vector3(cx - 1.35, 2.5, ROOM_Z0))
		_wall_in(Vector3(1.3, 5.0, 0.2), Vector3(cx + 1.35, 2.5, ROOM_Z0))
		_wall_in(Vector3(1.4, 2.4, 0.2), Vector3(cx, 3.8, ROOM_Z0))
		# Kapı levhası
		Props.box(self, Vector3(0.7, 0.7, 0.05), Vector3(cx, 3.1, ROOM_Z0 + 0.12), Color("c49a45"))
		Props.label(self, GREEK[i], Vector3(cx, 3.1, ROOM_Z0 + 0.16), 64, Color("3a1a10"), Vector3.ZERO, 0.5)
		# Masa, kâğıt yığınları, mühür
		Props.box(self, Vector3(2.0, 0.8, 0.8), Vector3(cx, 0.4, ROOM_Z1 + 2.2), Color("7a5a38"))
		for k in 3:
			Props.box(self, Vector3(0.3, 0.2 + k * 0.15, 0.22), Vector3(cx - 0.7 + k * 0.3, 0.9 + k * 0.07, ROOM_Z1 + 2.1), Color("efe6cf"))
		Props.cyl(self, 0.06, 0.14, Vector3(cx + 0.6, 0.87, ROOM_Z1 + 2.3), Color("8a2b22"), Vector3.ZERO, 8)
		var l := OmniLight3D.new()
		l.position = Vector3(cx, 3.6, ROOM_Z1 + 2.5)
		l.light_color = Color("ffd8a0")
		l.light_energy = 1.0
		l.omni_range = 5.0
		add_child(l)
		var theo := i == 6
		var robes := [Color("6a3a7a"), Color("2f5fa8"), Color("3a6b3a"), Color("8a6a2a"), Color("7a2a3a"), Color("3a4a6a"), Color("5a2a6a")]
		var clerk := Person.new({"coat": robes[i], "pants": robes[i].darkened(0.3), "hat": "kamelaukion", "robe": robes[i],
			"beard": theo or i % 3 == 0, "mustache": true, "hair": Color("8a8a8a") if theo else Color("3a2a1e"), "glasses": theo})
		clerk.position = Vector3(cx, 0, ROOM_Z1 + 1.2)
		add_child(clerk)
		clerks.append(clerk)
		Props.interactable(self, "clerk:%d" % i, Vector3(2.2, 2.0, 1.6), Vector3(cx, 1.0, ROOM_Z1 + 2.6))
	# Koridordaki Nihat (cameo): fötr şapka, bir sütunun yanında, hayranlıkla
	nihat = Person.new({"coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true, "hair": Color("3a2a1e"), "skin": Color("ecb892")})
	nihat.position = Vector3(x1 - 1.5, 0, HALL_Z0 - 1.2)
	nihat.rotation.y = -PI / 2.0
	add_child(nihat)
	Props.interactable(self, "nihat", Vector3(1.0, 2.0, 1.0), nihat.position + Vector3(0, 1.0, 0))
	var hl := OmniLight3D.new()
	hl.position = Vector3(0, 3.8, HALL_Z0 - 1.2)
	hl.light_color = Color("ffe0b0")
	hl.light_energy = 1.2
	hl.omni_range = 16.0
	add_child(hl)


## İç bölme duvarı: sıvalı, hafif sarımsı.
func _wall_in(size: Vector3, pos: Vector3) -> void:
	Props.set_pattern(Props.solid(self, size.abs(), pos, Color.WHITE), Color("efe0c4"), "plaster")


func _wall(size: Vector3, pos: Vector3, _color: Color, _front: bool) -> void:
	Props.set_pattern(Props.solid(self, size.abs(), pos, Color.WHITE), Color("fff4e4"), "ashlar")


# ---------------------------------------------------------------- kara surları

func _build_walls() -> void:
	# İç sur: kuleli, tuğla bantlı, önünde ahşap iskele ve topçular
	var x := 34.0
	Props.set_pattern(Props.solid(self, Vector3(3.0, 12.0, 60.0), Vector3(x, 6.0, -10.0), Color.WHITE), Color("fff0e0"), "ashlar")
	for y in [3.0, 6.5, 10.0]:
		Props.box(self, Vector3(0.05, 0.4, 60.0), Vector3(x - 1.52, y, -10.0), Color("8a4a36"))
	for z in [-34.0, -18.0, -2.0, 14.0]:
		Props.set_pattern(Props.solid(self, Vector3(6.0, 16.0, 6.0), Vector3(x, 8.0, z), Color.WHITE), Color("f4e4d0"), "ashlar")
	var zz := -38.0
	while zz < 18.0:
		Props.box(self, Vector3(0.6, 0.9, 0.8), Vector3(x - 1.2, 12.45, zz), Color("bba98a"))
		zz += 1.6
	# Ahşap iskele ve Giustiniani'nin masası (haritalar, sözleşmeler)
	Props.solid(self, Vector3(4.0, 0.3, 8.0), Vector3(x - 4.0, 1.2, GIUST_POS.z), Color("7a5a38"))
	for k in 4:
		Props.cyl(self, 0.1, 1.2, Vector3(x - 5.8 + (k % 2) * 3.6, 0.6, GIUST_POS.z - 3.6 + (k / 2) * 7.2), Color("5a4028"), Vector3.ZERO, 6)
	Props.box(self, Vector3(1.6, 0.8, 0.9), GIUST_POS + Vector3(-1.4, 0.4, 1.6), Color("6a4a2c"))
	Props.box(self, Vector3(1.2, 0.02, 0.8), GIUST_POS + Vector3(-1.4, 0.81, 1.6), Color("efe6cf"), Vector3(0, 8, 0))
	Props.label(self, "CONTRATTO", GIUST_POS + Vector3(-1.4, 0.83, 1.6), 24, Color("5a2a2a"), Vector3(-90, 8, 0), 0.9)
	for k in 3:
		Props.box(self, Vector3(0.6, 1.0, 0.4), Vector3(x - 3.0, 0.5, GIUST_POS.z + 5.0 + k * 0.9), Color("8a6440"))
	giustiniani = Person.new({"coat": Color("a8aeb6"), "pants": Color("6a2a2a"), "hat": "plume", "beard": true, "mustache": true, "hair": Color("5a3a1e"), "skin": Color("e8b894")})
	giustiniani.position = GIUST_POS
	giustiniani.rotation.y = -PI / 2.0
	add_child(giustiniani)
	Props.interactable(self, "giustiniani", Vector3(1.2, 2.0, 1.2), GIUST_POS + Vector3(0, 1.0, 0))
	# Çıkış kapısı (beyaz bayrakla çıkılır)
	Props.box(self, Vector3(0.3, 3.4, 2.6), EXIT_POS + Vector3(-1.3, 1.7, 0), Color("5a4028"))
	Props.ring(self, 1.3, 1.6, EXIT_POS + Vector3(-1.4, 3.4, 0), Color("a89878"), Vector3(0, 90, 90))
	Props.interactable(self, "exit", Vector3(1.4, 3.0, 3.0), EXIT_POS + Vector3(-1.8, 1.5, 0))
	lights.append(Night.torch(self, EXIT_POS + Vector3(-2.0, 0, 1.8), 2.4))


# ---------------------------------------------------------------- saray avlusu

func _build_palace() -> void:
	var c := EMPEROR_POS
	var body := Props.solid(self, Vector3(1.0, 8.0, 16.0), c + Vector3(-5.0, 4.0, 0), Color.WHITE)
	Props.set_pattern(body, Color("fff4e4"), "ashlar")
	# Sütunlar, mor sancaklar, taht
	for k in 6:
		var z := -6.0 + k * 2.4
		Props.cyl(self, 0.35, 5.0, c + Vector3(-1.5, 2.5, z), Color("e8e0cc"), Vector3.ZERO, 10)
		Props.box(self, Vector3(0.9, 0.3, 0.9), c + Vector3(-1.5, 5.1, z), Color("d8c8b0"))
	for z in [-3.0, 3.0]:
		Props.box(self, Vector3(0.05, 3.0, 1.2), c + Vector3(-4.45, 4.0, z), Color("5a2a6a"))
		Props.label(self, "ΧΡ", c + Vector3(-4.4, 4.6, z), 60, Color("d8b040"), Vector3(0, 90, 0), 0.8)
	Props.box(self, Vector3(1.4, 0.4, 1.8), c + Vector3(-3.6, 0.2, 0), Color("c9c0a8"))
	Props.box(self, Vector3(0.9, 1.8, 1.2), c + Vector3(-4.0, 1.3, 0), Color("5a2a6a"))
	emperor = Person.new({"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "crown", "beard": true, "mustache": true, "hair": Color("6a6a6a"), "robe": Color("5a2a6a")})
	emperor.position = c + Vector3(-2.6, 0, 0)
	emperor.rotation.y = PI / 2.0
	add_child(emperor)
	Props.interactable(self, "emperor", Vector3(1.2, 2.0, 1.2), emperor.position + Vector3(0, 1.0, 0))
	# Mangala masası (mini oyun): tahta, iki sıra çukur, iki hazine
	var mt := c + Vector3(0.4, 0, 1.6)
	Props.solid(self, Vector3(1.1, 0.72, 0.7), mt + Vector3(0, 0.36, 0), Color("6b4428"))
	Props.box(self, Vector3(0.95, 0.06, 0.4), mt + Vector3(0, 0.75, 0), Color("4a2e1a"))
	for i in 6:
		for row in [-0.09, 0.09]:
			Props.cyl(self, 0.05, 0.02, mt + Vector3(-0.3 + i * 0.12, 0.785, row), Color("2a1a10"), Vector3.ZERO, 8)
	for sx in [-0.42, 0.42]:
		Props.box(self, Vector3(0.08, 0.02, 0.3), mt + Vector3(sx, 0.785, 0), Color("2a1a10"))
	Props.cyl(self, 0.22, 0.45, mt + Vector3(0, 0.22, 0.75), Color("7a5232"), Vector3.ZERO, 8)
	Props.interactable(self, "mg:mangala", Vector3(1.4, 1.2, 1.2), mt + Vector3(0, 0.8, 0))
	for k in 2:
		var g := Person.new({"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true})
		g.position = c + Vector3(-1.0, 0, -2.2 + k * 4.4)
		g.rotation.y = PI / 2.0
		add_child(g)
	var l := OmniLight3D.new()
	l.position = c + Vector3(0, 4.0, 0)
	l.light_color = Color("ffd8a0")
	l.light_energy = 1.2
	l.omni_range = 10.0
	add_child(l)


func clerk_x(i: int) -> float:
	return -3.5 * ROOM_W + ROOM_W * (i + 0.5)
