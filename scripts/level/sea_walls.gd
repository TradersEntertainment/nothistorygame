class_name SeaWalls
extends Node3D
## Bölüm 4b: Haliç'in şehir yakası, 22 Nisan 1453 gecesi (GDD §9.4).
## Zincirin yüzen kütükleri (denge bölümü), surun dibinde dar bir taş rıhtım, mazgallı
## ve tuğla bantlı deniz suru, kuleler, meşaleler ve rıhtımın ucunda küçük kapı.
## Niko surun tepesinde dolaşır ve aşağıya bir şeyler fırlatır.

const WATER_Y := 0.0
const CHAIN_START := Vector3(0.0, 0.45, 34.0)
const CHAIN_END := Vector3(0.0, 0.45, 2.0)
const QUAY_Y := 0.7
const QUAY_Z := 0.0          # rıhtımın deniz kenarı
const WALL_Z := -3.2         # surun ön yüzü
const WALL_H := 11.0
const GATE_X := 17.0

var niko: Person
var lights: Array = []
var _t := 0.0


func _ready() -> void:
	Audio.voice_space("outdoor")
	var moon := Night.environment(self, 0.01)
	# Ay Haliç'in üstünde (rıhtımdan ve kapıdan görünsün; 4b'deki tutulma sahnesi)
	moon.rotation_degrees = Vector3(-30, 20, 0)
	_build_water()
	_build_chain()
	_build_quay()
	_build_wall()
	_build_extension()
	_build_city()
	_build_far_side()
	niko = Person.new({"face": "niko", "coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hair": Color("2a1e14"), "hat": "helm", "mustache": true, "skin": Color("d9a07a")})
	# Surun ön kenarında, iki mazgal arasında (rıhtımdan bakınca başı ve omuzları görünsün)
	niko.position = Vector3(4.8, QUAY_Y + WALL_H, WALL_Z - 0.35)
	add_child(niko)


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


func _build_water() -> void:
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(900, 600)
	pm.subdivide_width = 180
	pm.subdivide_depth = 120
	w.mesh = pm
	var sh := ShaderMaterial.new()
	sh.shader = load("res://assets/shaders/water.gdshader")
	sh.set_shader_parameter("shallow_color", Color(0.06, 0.16, 0.26))
	sh.set_shader_parameter("deep_color", Color(0.02, 0.05, 0.12))
	sh.set_shader_parameter("foam_color", Color(0.55, 0.62, 0.72))
	sh.set_shader_parameter("wave_height", 0.2)
	sh.set_shader_parameter("shore_z", QUAY_Z + 0.4)
	sh.set_shader_parameter("foam_width", 1.2)
	sh.set_shader_parameter("sky_tint", Color(0.16, 0.22, 0.4))
	sh.set_shader_parameter("glint", 0.5)
	w.material_override = sh
	w.position = Vector3(0, WATER_Y, 200)
	add_child(w)


func _build_chain() -> void:
	var n := int(CHAIN_START.distance_to(CHAIN_END) / 2.3)
	for i in n + 1:
		var p := CHAIN_START.lerp(CHAIN_END, float(i) / n)
		Props.cyl(self, 0.34, 2.1, p + Vector3(0, -0.12, 0), Color("6a4a2c"), Vector3(90, 0, 0), 8)
		Props.ring(self, 0.1, 0.18, p + Vector3(0, 0.1, 1.15), Color("4a4e56"), Vector3(0, 90, 0))
	# Zincirin şehir ucu: taş bağlama babası
	Props.cyl(self, 0.5, 1.4, CHAIN_END + Vector3(0.9, 0.0, -0.4), Color("6a6a70"), Vector3.ZERO, 8)


func _build_quay() -> void:
	var len := GATE_X + 8.0
	var body := Props.solid(self, Vector3(len, QUAY_Y + 1.0, -WALL_Z), Vector3(GATE_X / 2.0 - 1.0, (QUAY_Y - 1.0) / 2.0, WALL_Z / 2.0), Color("6d6a64"))
	Props.set_pattern(body, Color("6d6a64"), "concrete")
	# Rıhtımda fıçılar, ağlar, halatlar
	for x in [3.0, 8.5, 12.0]:
		Props.cyl(self, 0.35, 0.9, Vector3(x, QUAY_Y + 0.45, -2.4), Color("6a4a2c"), Vector3.ZERO, 8)
	Props.box(self, Vector3(1.4, 0.25, 1.0), Vector3(6.0, QUAY_Y + 0.12, -2.3), Color("8a7a5a"), Vector3(0, 12, 0))
	Props.ring(self, 0.2, 0.35, Vector3(10.0, QUAY_Y + 0.05, -1.0), Color("b89a6a"))
	# Sur dibinde sığ, çarpışmasız eşyalar (rıhtım dar: yol açık kalır), surda fenerler, suda bağlı kayıklar
	var d := Dressing.new(422)
	d.chunk = 160.0
	var x := -4.0
	var k := 0
	while x < GATE_X - 2.0:
		if absf(x - 3.0) > 0.8 and absf(x - 8.5) > 0.8 and absf(x - 12.0) > 0.8 and absf(x - 6.0) > 1.0:
			d.at(Vector3(x, QUAY_Y, WALL_Z + 0.05), 0.0)
			match k % 5:
				0: d.net(Vector3(0, 0, 0.05))
				1:
					d.rope_coil(Vector3(0, 0, 0.35))
					d.amphora(Vector3(0.6, 0, 0.25))
				2: d.fish_basket(Vector3(0, 0, 0.3))
				3:
					d.amphora(Vector3(-0.2, 0, 0.25))
					d.amphora(Vector3(0.25, 0, 0.25))
				_: d.basket(Vector3(0, 0, 0.3))
			if k % 2 == 0:
				d.wall_lantern(2.6)
			k += 1
		x += 1.9
	for bx in [1.0, 6.0, 11.0, 15.5]:
		d.at(Vector3(bx, QUAY_Y, -0.35), 0.0)
		d.bollard(Vector3.ZERO)
	d.build(self)
	for bp in [Vector3(7.0, WATER_Y, 2.6), Vector3(12.5, WATER_Y, 3.0)]:
		var boat := Node3D.new()
		boat.position = bp
		boat.rotation.y = PI / 2.0 + randf_range(-0.2, 0.2)
		boat.scale = Vector3.ONE * 0.55
		add_child(boat)
		boat.add_child(LowPoly.hull([
			{"z": -2.8, "w": 0.05, "top": 0.75, "bottom": 0.35},
			{"z": -1.8, "w": 0.6, "top": 0.55, "bottom": -0.05},
			{"z": 0.5, "w": 0.75, "top": 0.5, "bottom": -0.1},
			{"z": 2.0, "w": 0.6, "top": 0.55, "bottom": -0.05},
			{"z": 2.6, "w": 0.35, "top": 0.7, "bottom": 0.2},
		], Color("5a3a22"), Color("3a5a8a"), 0.4))
		Props.box(boat, Vector3(1.1, 0.06, 0.3), Vector3(0, 0.4, 0.3), Color("7a5a38"))


func _build_wall() -> void:
	var x0 := -60.0
	var x1 := 80.0
	var top := QUAY_Y + WALL_H
	var body := Props.solid(self, Vector3(x1 - x0, WALL_H + 2.0, 4.0), Vector3((x0 + x1) / 2.0, top - (WALL_H + 2.0) / 2.0, WALL_Z - 2.0), Color("c9b89a"))
	Props.set_pattern(body, Color("c9b89a"), "ashlar")
	# Tuğla bantlar
	for y in [3.0, 6.0, 9.0]:
		Props.box(self, Vector3(x1 - x0, 0.35, 0.06), Vector3((x0 + x1) / 2.0, QUAY_Y + y, WALL_Z + 0.02), Color("8a4a36"))
	# Mazgallar
	var x := x0
	while x < x1:
		Props.box(self, Vector3(0.8, 0.9, 0.6), Vector3(x, top + 0.45, WALL_Z - 0.3), Color("bba98a"))
		x += 1.6
	# Kuleler
	for tx in [-22.0, 0.0 - 6.0, 30.0, 58.0]:
		var tb := Props.solid(self, Vector3(6.0, WALL_H + 5.0, 6.5), Vector3(tx, QUAY_Y + (WALL_H + 5.0) / 2.0, WALL_Z - 1.2), Color("bfae90"))
		Props.set_pattern(tb, Color("bfae90"), "ashlar")
		for y in [4.0, 8.0, 12.0]:
			Props.box(self, Vector3(6.05, 0.35, 0.06), Vector3(tx, QUAY_Y + y, WALL_Z + 2.06), Color("8a4a36"))
		Props.box(self, Vector3(0.5, 1.4, 0.08), Vector3(tx, QUAY_Y + 9.0, WALL_Z + 2.06), Color("1a1410"))
		lights.append(Night.torch(self, Vector3(tx + 2.2, QUAY_Y + WALL_H + 5.0, WALL_Z + 1.6), 0.8, true))
	# Surun tepesinde meşaleler
	for tx2 in [-12.0, 12.0, 22.0, 44.0]:
		var l := Night.torch(self, Vector3(tx2, top, WALL_Z - 0.2), 1.2, tx2 == 12.0 or tx2 == 22.0)
		if l:
			lights.append(l)
	_build_gate()


## Surun iki yana devamı (-420..420): sudan yükselen gövde, tuğla bantlar, mazgallar, 42 m arayla kuleler,
## kulelerde gece meşaleleri. Yakın kesit (-60..80) _build_wall'dadır.
func _build_extension() -> void:
	var top := QUAY_Y + WALL_H
	var d := Dressing.new(4221)
	d.chunk = 160.0
	var nd := Dressing.new(4222)
	nd.chunk = 160.0
	var merl: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 4223
	for seg in [[-420.0, -60.0], [80.0, 420.0]]:
		var a: float = seg[0]
		var b: float = seg[1]
		var cx := (a + b) * 0.5
		Props.set_pattern(Props.box(self, Vector3(b - a, WALL_H + 2.0, 4.0), Vector3(cx, top - (WALL_H + 2.0) / 2.0, WALL_Z - 2.0), Color.WHITE), Color("c9b89a"), "ashlar")
		for y in [3.0, 6.0, 9.0]:
			d.box(Vector3(b - a, 0.35, 0.06), Vector3(cx, QUAY_Y + y, WALL_Z + 0.02), Color("8a4a36"))
		Props.box(self, Vector3(b - a, 1.0, 0.3), Vector3(cx, -0.2, WALL_Z + 0.1), Color("3a4a3a"))    # su çizgisinde yosun
		var x := a + 0.8
		while x < b:
			merl.append(Transform3D(Basis.from_scale(Vector3(0.8, 0.9, 0.6)), Vector3(x, top + 0.45, WALL_Z - 0.3)))
			x += 1.6
		var tx := a + 20.0 if a < 0.0 else a + 22.0
		while tx < b - 6.0:
			var th := WALL_H + rng.randf_range(4.0, 6.0)
			var t := Props.box(self, Vector3(6.0, th, 6.5), Vector3(tx, QUAY_Y + th / 2.0 - 0.6, WALL_Z - 1.2), Color.WHITE)
			Props.set_pattern(t, Color("bfae90"), "ashlar")
			for y in [4.0, 8.0, 12.0]:
				d.box(Vector3(6.05, 0.35, 0.06), Vector3(tx, QUAY_Y + y, WALL_Z + 2.06), Color("8a4a36"))
			d.box(Vector3(0.5, 1.4, 0.08), Vector3(tx, QUAY_Y + 9.0, WALL_Z + 2.06), Color("1a1410"))
			for k in 4:
				d.box(Vector3(1.0, 0.9, 1.0), Vector3(tx - 2.4 + k * 1.6, QUAY_Y + th + 0.4 - 0.6, WALL_Z + 1.6), Color("b0a080"))
			if rng.randf() < 0.6:
				nd.glow(Vector3(0.3, 0.45, 0.3), Vector3(tx + 2.2, QUAY_Y + th + 0.6, WALL_Z + 1.9), Color("ffb040"))
			tx += 42.0 + rng.randf_range(-3.0, 3.0)
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(Color("bba98a")))
	d.build(self)
	nd.build(self)


## Surun ardında şehir: yamaca tırmanan evler (gece bazı pencereler yanar), kiliseler, serviler, uzakta Ayasofya.
func _build_city() -> void:
	var hf := func(x: float, z: float) -> float:
		# Tarihî yarımada Haliç'ten dik yükselir: surun ardındaki evler ve kubbeler denizden görünsün
		return 0.7 + smoothstep(-10.0, -150.0, z) * (32.0 + 8.0 * sin(x * 0.011 + 0.5)) + smoothstep(-200.0, -520.0, z) * 14.0
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		return Color("3a3830").lerp(Color("2e3428"), clampf(0.5 + 0.5 * sin(x * 0.05 - z * 0.04), 0.0, 1.0)).darkened(clampf(steep * 0.4, 0.0, 0.2))
	add_child(LowPoly.terrain(-430.0, 430.0, -540.0, WALL_Z - 3.0, 43, 27, hf, cf))
	var rng := RandomNumberGenerator.new()
	rng.seed = 4224
	var hx: Array = []
	var hc: Array = []
	var nd := Dressing.new(4225)
	nd.chunk = 160.0
	for i in 620:
		var x := rng.randf_range(-420.0, 420.0)
		var z := WALL_Z - 9.0 - pow(rng.randf(), 1.4) * 480.0
		var sz := Vector3(rng.randf_range(5.0, 10.0), rng.randf_range(5.0, 11.0), rng.randf_range(5.0, 9.0))
		var y: float = hf.call(x, z)
		hx.append(Scenery._t(Vector3(x, y - 0.4, z), Vector3(0, rng.randf_range(-0.3, 0.3), 0), sz))
		hc.append([Color("e8d8c0"), Color("d8c0a0"), Color("c8a888"), Color("e0ccb0"), Color("b89a80")][i % 5])
		if rng.randf() < 0.35:
			nd.glow(Vector3(0.6, 0.8, 0.6), Vector3(x + rng.randf_range(-sz.x, sz.x) * 0.3, y + sz.y * rng.randf_range(0.3, 0.7), z + sz.z * 0.5 + 0.05), Color("ffc870"))
	Scenery.scatter(self, Scenery.house_mesh(), hx, hc)
	nd.build(self)
	for i in 10:
		var p := Vector3(rng.randf_range(-380.0, 380.0), 0, rng.randf_range(-60.0, -380.0))
		p.y = hf.call(p.x, p.z) - 0.3
		var r := rng.randf_range(5.0, 8.0)
		Props.box(self, Vector3(r * 2.4, r * 1.3, r * 2.0), p + Vector3(0, r * 0.65, 0), Color("b87060"))
		Props.cyl(self, r * 0.62, r * 0.55, p + Vector3(0, r * 1.55, 0), Color("c8a890"), Vector3.ZERO, 12)
		Props.ball(self, r * 0.64, p + Vector3(0, r * 1.82, 0), Color("8a98a8"), Vector3(1, 0.7, 1), 14)
	Scenery.hagia_sophia(self, Vector3(-140.0, hf.call(-140.0, -420.0) - 1.0, -420.0), 1.0)
	var cyp: Array = []
	for i in 260:
		var x := rng.randf_range(-420.0, 420.0)
		var z := rng.randf_range(WALL_Z - 10.0, -500.0)
		var sc := rng.randf_range(0.9, 1.5)
		cyp.append(Scenery._t(Vector3(x, hf.call(x, z) - 0.1, z), Vector3.ZERO, Vector3(sc, sc * 1.2, sc)))
	Scenery.scatter(self, Scenery.cypress_mesh(), cyp, [])


## Deniz kapısı (rıhtımın ucunda): surun içine gömülü taş çerçeve, tuğla ve mermer sıralı kemer, kemer içinde
## mozaik haç, demir çivili çift kanat ve kuşakları, kapı tokmakları, kemer üstünde kitabe ve iki fener; önünde
## eşik taşı ve iki basamak. Kanatlar kapalıdır (open_gate ile açılır).
var gate_leaves: Array[Node3D] = []


func _build_gate() -> void:
	var g := Vector3(GATE_X, QUAY_Y, WALL_Z)
	var hw := 1.15
	var spring := 2.7
	var marble := Color("e8e0d0")
	# Taş çerçeve: iki söve (dışa taşan), üstte düz kuşak
	for sx: float in [-1.0, 1.0]:
		Props.set_pattern(Props.box(self, Vector3(0.55, spring + 1.9, 0.5), g + Vector3(sx * (hw + 0.28), (spring + 1.9) / 2.0, 0.2), Color.WHITE), marble, "marble")
		Props.box(self, Vector3(0.7, 0.25, 0.6), g + Vector3(sx * (hw + 0.28), spring, 0.22), Color("d0c4ac"))
	# Kemer: sıra sıra tuğla ve mermer
	for k in 11:
		var a := PI * (k + 0.5) / 11.0
		var c := marble if k % 2 == 0 else Color("b0503a")
		Props.box(self, Vector3(0.4, 0.34, 0.5), g + Vector3(-cos(a) * (hw + 0.17), spring + sin(a) * (hw + 0.17), 0.2), c, Vector3(0, 0, rad_to_deg(a) - 90.0))
	# Kemer içi: altın zeminli mozaik haç
	var tym := Props.ball(self, hw, g + Vector3(0, spring, 0.05), Color("c89a38"), Vector3(1, 1, 0.05), 16)
	tym.material_override = Props.mat(Color("c89a38"), 0.2, false, "", false)
	Props.box(self, Vector3(0.1, 0.7, 0.04), g + Vector3(0, spring + 0.45, 0.12), Color("8a1a22"))
	Props.box(self, Vector3(0.42, 0.1, 0.04), g + Vector3(0, spring + 0.55, 0.12), Color("8a1a22"))
	Props.box(self, Vector3(hw * 2.0 + 1.4, 0.25, 0.55), g + Vector3(0, spring + hw + 0.55, 0.22), marble)
	Props.box(self, Vector3(2.4, 0.4, 0.06), g + Vector3(0, spring + hw + 1.0, 0.1), Color("f2ecdc"))
	Props.label(self, "ΠΥΛΗ ΤΟΥ ΝΕΩΡΙΟΥ", g + Vector3(0, spring + hw + 1.0, 0.14), 26, Color("5a2a2a"), Vector3.ZERO, 2.2)
	# Kanatların ardındaki karanlık geçit (kapı açılınca görünür)
	var dark := Props.box(self, Vector3(hw * 2.0, spring, 0.02), g + Vector3(0, spring / 2.0, 0.03), Color("120e0b"))
	dark.material_override = Props.mat(Color("120e0b"), 0.0, false, "", false)
	# Çift kanat (kapalı): ahşap, demir kuşaklar, çiviler, halka tokmaklar
	for sx: float in [-1.0, 1.0]:
		var leaf := Node3D.new()
		leaf.position = g + Vector3(sx * hw, 0, 0.12)
		add_child(leaf)
		Props.box(leaf, Vector3(hw, spring, 0.12), Vector3(-sx * hw / 2.0, spring / 2.0, 0), Color("5a3a22"))
		for yy: float in [0.5, 1.4, 2.3]:
			Props.box(leaf, Vector3(hw, 0.1, 0.15), Vector3(-sx * hw / 2.0, yy, 0.01), Color("3a3a3e"))
			for k in 3:
				Props.ball(leaf, 0.035, Vector3(-sx * (0.2 + k * 0.35), yy, 0.09), Color("2a2a2e"), Vector3.ONE, 4)
		Props.ring(leaf, 0.07, 0.1, Vector3(-sx * (hw - 0.22), 1.25, 0.1), Color("8a7040"), Vector3(90, 0, 0))
		gate_leaves.append(leaf)
	# Eşik ve basamaklar
	Props.box(self, Vector3(hw * 2.0 + 1.2, 0.12, 0.7), g + Vector3(0, 0.06, 0.45), Color("a8a090"))
	# İki yanda demir fenerler
	for sx: float in [-1.0, 1.0]:
		var lp := g + Vector3(sx * (hw + 0.95), 2.4, 0.45)
		Props.box(self, Vector3(0.06, 0.06, 0.45), lp + Vector3(0, 0.2, -0.2), Color("2a2a2e"))
		Props.cyl(self, 0.12, 0.3, lp, Color("2a2a2e"), Vector3.ZERO, 6, 0.08)
		var fl := Props.ball(self, 0.07, lp, Color("ffb850"), Vector3(1, 1.4, 1), 6)
		fl.material_override = Props.mat(Color("ffb850"), 3.0, false, "", false)
	lights.append(Night.torch(self, g + Vector3(hw + 2.2, 0, 0.5), 2.2))
	Props.interactable(self, "gate", Vector3(2.4, 3.0, 1.2), g + Vector3(0, 1.5, 0.6))


## Kanatlar içe açılır (Niko'yla içeri girerken).
func open_gate(secs := 1.0) -> void:
	var tw := create_tween().set_parallel(true)
	for i in gate_leaves.size():
		var sx := -1.0 if i == 0 else 1.0
		tw.tween_property(gate_leaves[i], "rotation:y", sx * deg_to_rad(-80.0), secs)
	await tw.finished


## Karşı kıyı: Galata tarafında karanlık tepeler; tepede surlu Ceneviz kasabası ve Galata Kulesi (GalataView),
## iki yanda Pera bağları ve dağınık ışıklar.
func _build_far_side() -> void:
	var hf := func(x: float, z: float) -> float:
		# Kıyıda suya iner (arazinin ön kenarı boşlukta asılı kalmasın)
		var shore := smoothstep(160.0, 186.0, z)
		return (2.0 + sin(x * 0.03) * 6.0 + cos(x * 0.05 + 1.0) * 4.0 + (z - 170.0) * 0.12) * shore - 1.5 * (1.0 - shore)
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		return Color("1c2418").lerp(Color("262e20"), clampf(y / 20.0, 0.0, 1.0))
	add_child(LowPoly.terrain(-450.0, 450.0, 150.0, 300.0, 60, 15, hf, cf))
	GalataView.build(self, hf, Vector2(-30.0, 190.0), 37.6, Vector2(-30.0, 206.0), 34.0, WATER_Y + 0.35, 1453, true)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var lights_mm: Array = []
	for i in 70:
		var p := Vector3(rng.randf_range(-420, 420), 0, rng.randf_range(175, 280))
		if Vector2(p.x, p.z).distance_to(Vector2(-30.0, 206.0)) < 44.0:
			continue
		p.y = hf.call(p.x, p.z) + 1.0
		lights_mm.append(Transform3D(Basis.from_scale(Vector3.ONE * rng.randf_range(0.35, 0.6)), p))
	Scenery.scatter(self, Scenery._ball(1.0), lights_mm, [], Props.mat(Color("ffb040"), 3.0, false, "", false))
