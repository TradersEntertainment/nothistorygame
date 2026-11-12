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

## Tek harita (kuşatma bölümleri): yalnız rıhtım ve surun bu parçası kurulur; su, zincir, sur devamı, şehir ve karşı
## kıyı (Galata) World1453'ten gelir. Bölüm add_child'dan önce true yapar.
var in_world := false
var world: SiegeField
var niko: Person
var lights: Array = []
var _t := 0.0


func _ready() -> void:
	Audio.voice_space("outdoor")
	var moon := Night.environment(self, 0.01)
	# Ay Haliç'in üstünde (rıhtımdan ve kapıdan görünsün; 4b'deki tutulma sahnesi)
	moon.rotation_degrees = Vector3(-30, 20, 0)
	if in_world:
		# Karşı kıyı (kuzey) yerel z ≈ 220'de: SeaBattle'ın ordusu ve Sultan oraya
		SeaBattle.world_shift = -(World1453.HORN_N_X - World1453.HORN_S_X) - 170.0
		_build_quay()
		_build_wall()
		world = World1453.build(self, "horn_chain", [Rect2(-60.0, -8.0, 140.0, 50.0)], true)
	else:
		_build_water()
		_build_chain()
		_build_quay()
		_build_wall()
		_build_extension()
		_build_city()
		_build_far_side()
	niko = Person.new({"face": "niko", "coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hair": Color("2a1e14"), "hat": "helm", "mustache": true, "skin": Color("d9a07a")})
	# Surun ön kenarında, iki mazgal arasında (rıhtımdan bakınca başı ve omuzları görünsün)
	niko.position = Vector3(4.8, wall_top(4.8), WALL_Z - 0.25)
	add_child(niko)


func _exit_tree() -> void:
	if in_world:
		SeaBattle.world_shift = 0.0


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
	# Rıhtımın taş gövdesi surla birlikte tek kurucudan (horn_wall_parts) gelir
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
	# Rıhtım, sur, kuleler, geçit ve Eugenius kulesi Haliç kıyı surunun tek kurucusundan (dünya da aynı parçaları kurar).
	# 4b dünyanın dışında (kendi suyu ve şehri): sur tepesi eski yükseklikte sabit (Niko surun tepesinde)
	var fixed := NAN if in_world else QUAY_Y + WALL_H + World1453.SEA_Y
	for p: Vector3 in SeaWalls.build_span(self, "horn_chain", fixed):
		# Eski dört kulenin ateşi ışıklı; bağlantı ve köşe kulelerinde yalnız alev
		var l := Night.torch(self, p, 0.8, p.x > -30.0 and p.x < 66.0)
		if l:
			lights.append(l)
	# Surun tepesinde meşaleler
	for tx2 in [-12.0, 12.0, 22.0, 44.0]:
		var l := Night.torch(self, Vector3(tx2, wall_top(tx2), WALL_Z - 0.2), 1.2, tx2 == 12.0 or tx2 == 22.0)
		if l:
			lights.append(l)
	_build_gate()


## Surun yerel x'teki tepesi (yerel y)
func wall_top(x: float) -> float:
	if not in_world:
		return QUAY_Y + WALL_H
	return SeaWalls.chain_top(World1453.to_world("horn_chain", Vector3(x, 0.0, WALL_Z)).z) - World1453.SEA_Y


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
	# Surda nöbetçiler (uzak siluet, mazgalların ardında denize bakar): devam kesitlerinde sık, yakın kesitte
	# yalnız kapıdan ve Niko'nun yerinden uzak iki uçta
	var men: Array = []
	var cols: Array = []
	for seg in [[-420.0, -60.0, WALL_Z - 1.1], [80.0, 420.0, WALL_Z - 1.1], [-58.0, -30.0, WALL_Z - 1.6], [46.0, 78.0, WALL_Z - 1.6]]:
		var x: float = seg[0] + rng.randf_range(0.5, 3.0)
		while x < seg[1] - 1.0:
			men.append(Transform3D(Basis(Vector3.UP, rng.randf_range(-0.35, 0.35)), Vector3(x, top, seg[2])))
			cols.append(Garrison.COATS[rng.randi() % Garrison.COATS.size()])
			x += rng.randf_range(3.5, 8.0)
	var g := Node3D.new()
	g.name = "WallGuards"
	g.add_to_group("garrison")
	add_child(g)
	Garrison.far_men(g, men, cols)


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


# ---------------------------------------------------------------- Haliç kıyı suru: tek kurucu
## Haliç'in şehir yakasındaki sur (Blakherna köşesinden zincire, zincirden burna) yalnız burada tarif edilir. Bütün ölçüler
## DÜNYA koordinatında (World1453); yayımcı emit(tür, boyut, dönüşüm, renk, desen, katı) ile verilir:
##   "box"/"cyl": geometri (boyut kutunun kendi ekseninde: x sura dik, dışa doğru +x; y; z sur boyunca; cyl: x yarıçap, y boy)
##   "far": yalnız uzak sürümde (bölümün kendi ayrıntılı karşılığı var), "merlon": mazgal dişi, "torch": kule tepesi ateşi,
##   "man": surdaki nöbetçi (uzak siluet).
## Bölüm kendi dilimini (SPANS) Props ile katı ve desenli kurar (build_span); dünya geri kalanını (bölge aktif değilse o dilimi
## de) birleşik ağ olarak kurar (HornWorld._horn_walls → bake_parts). Sur tepesi bölgeden bağımsızdır: dünyanın HAM
## arazisinden (bölümlerin düzlediği alanlar hesaba katılmaz) her bölümde aynı çıkar; böylece aynı yer her bölümde aynı biçimde.
const C_WALL := Color("c9b89a")
const C_TOWER := Color("bfae90")
const C_MERL := Color("bba98a")
const C_BRICK := Color("8a4a36")
const C_DARK := Color("1a1410")
const HW_T := 3.0                     # varsayılan sur: ekseni x −700 (HORN_S_X), dış yüz −701,5
const CHAIN_X := -694.8               # zincir rıhtımının suru: bölgenin WALL_Z − 2 (dış yüz −696,8, rıhtım önünde)
const CHAIN_T := 4.0
const FOOT := -3.0                    # surun tabanı (su ve rıhtım altında)
## Bölümlerin kendi kurduğu dilimler (dünya z aralığı, uçlar dahil): bölge aktifken dünya bunları kurmaz
const SPANS := {"horn_chain": Vector2(-1660.0, -1520.0), "petrion": Vector2(-670.0, -630.0)}
const CHAIN_TOWERS := [-1542.0, -1570.0, -1606.0, -1622.0]     # bölgenin x 58, 30, −6, −22'deki kuleleri
const CHAIN_GATE_Z := -1588.0         # rıhtımdan şehre geçit (bölgenin x 12)
const CHAIN_DOOR_Z := -1583.0         # süslü deniz kapısı (bölgenin GATE_X 17)
const PETRION_Z := -650.0
## Horn.build'in kendi suru (18, 18b, 31o, 38o; dünya y): o bölgeler aktifken komşu sur ona iner
const LEGACY_TOP := 8.0
static var _tops := {}


## Dünyanın düzlenmemiş görünen yüzeyi (bölümlerin oynanış alanı hesaba katılmaz): sur tepesi her bölümde aynı çıksın
static func _raw_surf(x: float, z: float) -> float:
	var fr := SiegeField.flat_rects
	var fy := SiegeField.flat_y
	var fb := SiegeField.flat_blend
	var br := SiegeField.blend_rects
	var wo := SiegeField.world_on
	SiegeField.flat_rects = []
	SiegeField.flat_blend = 0.0
	SiegeField.blend_rects = []
	SiegeField.world_on = true
	var h := World1453.surface_h(x, z)
	SiegeField.flat_rects = fr
	SiegeField.flat_y = fy
	SiegeField.flat_blend = fb
	SiegeField.blend_rects = br
	SiegeField.world_on = wo
	return h


## Bir sur parçasının tepesi (dünya y): iki yandaki ham yüzeyin 5 m üstü, en az h
static func _seg_top(a: Vector3, b: Vector3, side: Vector3, h: float) -> float:
	var key := "%.2f,%.2f,%.2f,%.2f,%.1f" % [a.x, a.z, b.x, b.z, h]
	if _tops.has(key):
		return _tops[key]
	var gy := -INF
	for f: float in [0.1, 0.5, 0.9]:
		var p := a.lerp(b, f)
		gy = maxf(gy, maxf(_raw_surf(p.x + side.x * 12.0, p.z + side.z * 12.0), _raw_surf(p.x - side.x * 12.0, p.z - side.z * 12.0)))
	var t := maxf(h, gy + 5.0)
	_tops[key] = t
	return t


## Kıyı surunun koşuları: [a, b, kalınlık, en az tepe, kuleler (a'dan uzaklık), kapılar [uzaklık, genişlik, eşik y, boy, eşik taşı]]
static func _runs() -> Array:
	var out: Array = []
	# 1) Blakherna köşesinden zincir rıhtımına: x −700 boyunca. Kuleler 44 m arayla (z 18 − 44k); kapıların iki yanında kule
	var a := Vector3(World1453.HORN_S_X, 0.0, World1453.HORN_IN_Z)
	var b := Vector3(World1453.HORN_S_X, 0.0, SPANS["horn_chain"].y)
	var gz: Array = [PETRION_Z]
	gz.append_array(World1453.HORN_GATE_Z)
	var towers: Array = []
	var z := 18.0
	while z > b.z + 10.0:
		var near := false
		for g: float in gz:
			near = near or absf(z - g) < 20.0
		if not near:
			towers.append(a.z - z)
		z -= 44.0
	var gates: Array = []
	for g: float in gz:
		towers.append(a.z - (g + 12.0))
		towers.append(a.z - (g - 12.0))
		var sill := 0.0 if g == PETRION_Z else _raw_surf(World1453.HORN_S_X + 8.0, g)
		gates.append([a.z - g, 4.0, sill, 4.6, false])
	towers.sort()
	out.append([a, b, HW_T, 10.0, towers, gates, 0.0])
	# 2) Zincir rıhtımı (bölge horn_chain): rıhtım önde, sur geride; uçta köşe kulesi, başta iki çizgiyi bağlayan kule
	var ca := Vector3(CHAIN_X, 0.0, SPANS["horn_chain"].y)
	var cb := Vector3(CHAIN_X, 0.0, SPANS["horn_chain"].x)
	var ct: Array = [0.0]
	for tz: float in CHAIN_TOWERS:
		ct.append(ca.z - tz)
	ct.append(ca.z - cb.z)
	# Geçit: rıhtım üstü (y −0,9) 3 m (bölümün çarpışması aynen), eşik taşı
	out.append([ca, cb, CHAIN_T, 10.0, ct, [[ca.z - CHAIN_GATE_Z, 3.6, World1453.SEA_Y + QUAY_Y, 3.0, true]], 0.45])
	# 3) Köşeden şehrin burnuna (sonrası Marmara surları): 60 m arayla kuleler
	var ta := cb
	var tb := World1453.TIP
	var tl := ta.distance_to(tb)
	var tt: Array = []
	var s := 30.0
	while s < tl - 6.0:
		tt.append(s)
		s += 60.0
	out.append([ta, tb, HW_T, 9.0, tt, [], 0.0])
	return out


## [z0, z1] (z0 < z1) içinde izin verilen z aralıkları: only sonluysa yalnız onun içi, değilse skip aralıkları dışı
static func _allow(z0: float, z1: float, only: Vector2, skip: Array) -> Array:
	if only.is_finite():
		var lo := maxf(z0, only.x)
		var hi := minf(z1, only.y)
		return [Vector2(lo, hi)] if hi - lo > 0.01 else []
	var cur: Array = [Vector2(z0, z1)]
	for k: Vector2 in skip:
		var nxt: Array = []
		for c: Vector2 in cur:
			if k.y <= c.x or k.x >= c.y:
				nxt.append(c)
				continue
			if k.x - c.x > 0.01:
				nxt.append(Vector2(c.x, k.x))
			if c.y - k.y > 0.01:
				nxt.append(Vector2(k.y, c.y))
		cur = nxt
	return cur


static func _owns(z: float, only: Vector2, skip: Array, pad := 0.0) -> bool:
	if only.is_finite():
		return z >= only.x - 0.001 and z <= only.y + 0.001
	for k: Vector2 in skip:
		if z >= k.x - pad and z <= k.y + pad:
			return false
	return true


static func _eased(t: float, z: float, ease: Array) -> float:
	for k: Vector2 in ease:
		var d := maxf(maxf(k.x - z, 0.0), z - k.y)
		t = lerpf(LEGACY_TOP, t, smoothstep(10.0, 70.0, d))
	return t


## Yayımcı: Haliç kıyı surunun bütün parçaları (dünya koordinatında).
##   only: yalnız bu z aralığı (bölümün kendi dilimi); skip: kurulmayacak z aralıkları (dünya: aktif bölgenin dilimi);
##   ease: tepesi LEGACY_TOP'a inecek aralıklar (Horn.build'in suruyla birleşen bölümler); fixed_top: dünya dışı bölüm (4b)
static func horn_wall_parts(emit: Callable, only := Vector2.INF, skip: Array = [], ease: Array = [], fixed_top := NAN) -> void:
	var runs := _runs()
	for ri in runs.size():
		var run: Array = runs[ri]
		var a: Vector3 = run[0]
		var b: Vector3 = run[1]
		var t: float = run[2]
		var h0: float = run[3]
		var towers: Array = run[4]
		var gates: Array = run[5]
		var tback: float = run[6]
		var dir := b - a
		var L := dir.length()
		dir /= L
		var yaw := atan2(dir.x, dir.z)
		var bas := Basis(Vector3.UP, yaw)
		var side := Vector3(dir.z, 0.0, -dir.x)          # dışa (suya) doğru = parçanın +x'i
		var at := func(s: float, x: float, y: float) -> Vector3:
			return a + dir * s + side * x + Vector3(0.0, y, 0.0)
		var zs := func(s: float) -> float:
			return a.z + dir.z * s
		var st: Array = [0.0]
		for ts: float in towers:
			if ts > 0.01 and ts < L - 0.01:
				st.append(ts)
		st.append(L)
		var tops: Array = []
		for i in st.size() - 1:
			tops.append(fixed_top if not is_nan(fixed_top) else _seg_top(a + dir * float(st[i]), a + dir * float(st[i + 1]), side, h0))
		# Parçalar: [s0, s1, y0, y1, tür]
		var pieces: Array = []
		for i in st.size() - 1:
			var s0: float = st[i]
			var s1: float = st[i + 1]
			var T: float = tops[i]
			var cuts: Array = []
			for g: Array in gates:
				var gs: float = g[0]
				if gs > s0 and gs < s1:
					cuts.append(g)
			var cur := s0
			for g: Array in cuts:
				var gs: float = g[0]
				var hw: float = g[1] * 0.5
				pieces.append([cur, gs - hw, FOOT, T, "wall"])
				pieces.append([gs - hw, gs + hw, FOOT, float(g[2]) - 0.05, "found"])
				pieces.append([gs - hw, gs + hw, float(g[2]) + float(g[3]), T, "lintel"])
				if g[4] and _owns(zs.call(gs), only, skip):
					emit.call("box", Vector3(4.4, 0.4, g[1]), Transform3D(bas, at.call(gs, 0.0, float(g[2]) - 0.22)), Color("a89878"), "cobble", true)
				cur = gs + hw
			pieces.append([cur, s1, FOOT, T, "wall"])
		for pc: Array in pieces:
			var za: float = zs.call(pc[0])
			var zb: float = zs.call(pc[1])
			for iv: Vector2 in _allow(minf(za, zb), maxf(za, zb), only, skip):
				# z aralığını yeniden uzaklığa çevir
				var p0 := (iv.x - a.z) / dir.z
				var p1 := (iv.y - a.z) / dir.z
				var q0 := minf(p0, p1)
				var q1 := maxf(p0, p1)
				var len := q1 - q0
				var y0: float = pc[2]
				var y1: float = pc[3]
				if pc[4] != "found" and is_nan(fixed_top):
					y1 = _eased(y1, (iv.x + iv.y) * 0.5, ease)
				if y1 - y0 < 0.05:
					continue
				var mid := (q0 + q1) * 0.5
				emit.call("box", Vector3(t, y1 - y0, len), Transform3D(bas, at.call(mid, 0.0, (y0 + y1) * 0.5)), C_WALL, "ashlar", true)
				if pc[4] == "found":
					continue
				# Tuğla hatıllar (dış yüzde, 3 m arayla) ve mazgallar (ön yüzün 0,85 m içinde, 1,6 m arayla, sabit ızgarada)
				var by := 2.1
				while by < y1 - 1.2:
					if by > y0 + 0.3:
						emit.call("box", Vector3(0.06, 0.35, len), Transform3D(bas, at.call(mid, t * 0.5 + 0.02, by)), C_BRICK, "", false)
					by += 3.0
				var m := ceilf((q0 - 0.8) / 1.6) * 1.6 + 0.8
				while m < q1 - 0.35:
					if m > q0 + 0.35:
						emit.call("merlon", Vector3(0.6, 0.9, 0.8), Transform3D(bas, at.call(m, t * 0.5 - 0.85, y1 + 0.45)), C_MERL, "ashlar", false)
					m += 1.6
				# Nöbetçiler (yalnız uzak sürüm: dışa, suya bakar)
				var k := ceilf((q0 - 2.25) / 4.5)
				while 2.25 + k * 4.5 < q1:
					var ms := 2.25 + k * 4.5
					var hv := hash(ri * 100003 + int(k))
					if hv % 4 != 0:
						emit.call("man", Vector3.ONE, Transform3D(Basis(Vector3.UP, atan2(side.x, side.z) + (hv % 60 - 30) * 0.01), at.call(ms, -0.4, y1)), Color.WHITE, "", false)
					k += 1.0
		# Kuleler: sur boyunca 6 m, ön yüzden 2,05 m dışa taşar; tepesi komşu sur parçasından 5 m yüksek
		for i in st.size():
			var s: float = st[i]
			var is_end := i == st.size() - 1
			if (i == 0 or is_end) and not (ri == 1):
				continue
			var z := zs.call(s) as float
			if not _owns(z, only, skip, 3.0):
				continue
			var T: float = tops[maxi(i - 1, 0)] if is_end else (tops[i] if i == 0 else maxf(tops[i - 1], tops[i]))
			if is_nan(fixed_top):
				T = _eased(T, z, ease)
			var th := T + 5.0
			var front := t * 0.5 + 2.05 + (4.7 if (ri == 1 and i == 0) else 0.0)   # bağlantı kulesi: varsayılan surun önüne dek
			var back := t * 0.5 + tback
			var cx := (front - back) * 0.5
			emit.call("box", Vector3(front + back, th - FOOT, 6.0), Transform3D(bas, at.call(s, cx, (th + FOOT) * 0.5)), C_TOWER, "ashlar", true)
			var by := 3.1
			while by < th - 1.0:
				emit.call("box", Vector3(0.06, 0.35, 6.05), Transform3D(bas, at.call(s, front + 0.02, by)), C_BRICK, "", false)
				by += 4.0
			emit.call("box", Vector3(0.08, 1.4, 0.5), Transform3D(bas, at.call(s, front + 0.03, th - 7.0)), C_DARK, "", false)
			for q in 4:
				emit.call("box", Vector3(1.0, 0.9, 1.0), Transform3D(bas, at.call(s + (2.5 if q % 2 == 0 else -2.5), cx + (front + back) * (0.5 if q < 2 else -0.5) + (-0.5 if q < 2 else 0.5), th + 0.45)), C_MERL, "ashlar", false)
			emit.call("torch", Vector3.ONE, Transform3D(bas, at.call(s - 2.2, t * 0.5 + 1.6, th)), Color.WHITE, "", false)
	# Zincir rıhtımı: rıhtım gövdesi (bölümün çarpışmasıyla aynı), Eugenius kulesi (zincirin şehir ucu), süslü deniz kapısı (uzak)
	var cbas := Basis(Vector3.UP, PI)
	if _owns(-1592.5, only, skip):
		emit.call("box", Vector3(-WALL_Z, QUAY_Y + 1.0, GATE_X + 8.0), Transform3D(cbas, Vector3(World1453.HORN_S_X - WALL_Z * 0.5, World1453.SEA_Y + (QUAY_Y - 1.0) * 0.5, -1592.5)), Color("6d6a64"), "concrete", true)
	var e: Vector3 = World1453.LANDMARKS["eugenius"]
	if _owns(e.z, only, skip):
		emit.call("cyl", Vector3(7.0, 22.0, 7.0), Transform3D(Basis.IDENTITY, Vector3(e.x, 10.0, e.z)), C_TOWER, "ashlar", true)
		emit.call("cyl", Vector3(7.4, 0.6, 7.4), Transform3D(Basis.IDENTITY, Vector3(e.x, 21.3, e.z)), Color("9a5040"), "", false)
	if _owns(CHAIN_DOOR_Z, only, skip):
		var fz := CHAIN_X - CHAIN_T * 0.5 - 0.05
		var qy := World1453.SEA_Y + QUAY_Y
		emit.call("far", Vector3(0.1, 2.7, 2.3), Transform3D(cbas, Vector3(fz, qy + 1.35, CHAIN_DOOR_Z)), C_DARK, "", false)
		emit.call("far", Vector3(0.5, 0.6, 3.8), Transform3D(cbas, Vector3(fz - 0.1, qy + 3.9, CHAIN_DOOR_Z)), Color("e8e0d0"), "marble", false)


## Haliç kıyı suru (chain) koşusunda z'deki parçanın tepesi (dünya y)
static func chain_top(z: float) -> float:
	var r: Array = _runs()[1]
	var a: Vector3 = r[0]
	var st: Array = r[4]
	var s := a.z - z
	for i in st.size() - 1:
		if s >= float(st[i]) - 0.01 and s <= float(st[i + 1]) + 0.01:
			var b: Vector3 = r[1]
			var dir := (b - a).normalized()
			return _seg_top(a + dir * float(st[i]), a + dir * float(st[i + 1]), Vector3(dir.z, 0.0, -dir.x), r[3])
	return 10.0


## Bölümün kendi dilimini bölgenin yerel koordinatında kurar (Props: katı, desenli). Döndürür: kule ateşlerinin yerleri (yerel)
static func build_span(host: Node3D, region: String, fixed_top := NAN) -> Array:
	var inv := World1453.region(region).affine_inverse()
	var merl: Array = []
	var torches: Array = []
	var emit := func(kind: String, size: Vector3, xf: Transform3D, color: Color, pattern: String, solid: bool) -> void:
		var lx := inv * xf
		match kind:
			"box":
				if solid:
					# Gövde dönüşümüyle birlikte ağaca girer (önce kökte eklenip sonra taşınınca fizik sunucusunda kökte
					# görünmez bir kutu kalıyordu: 39o'da kapının ağzında VISAUDIT wall)
					var body := StaticBody3D.new()
					body.transform = lx
					host.add_child(body)
					var bm := Props.box(body, size, Vector3.ZERO, color)
					if pattern != "":
						bm.material_override = Props.mat(color, 0.0, false, pattern)
					var cs := CollisionShape3D.new()
					var bs := BoxShape3D.new()
					bs.size = size
					cs.shape = bs
					body.add_child(cs)
				else:
					var mb := Props.box(host, size, Vector3.ZERO, color)
					mb.transform = lx
					if pattern != "":
						Props.set_pattern(mb, color, pattern)
			"cyl":
				var mc := Props.cyl(host, size.x, size.y, Vector3.ZERO, color, Vector3.ZERO, 14)
				mc.transform = lx
				if pattern != "":
					Props.set_pattern(mc, color, pattern)
				if solid:
					Props.make_solid(mc)
			"merlon":
				merl.append(Transform3D(lx.basis * Basis.from_scale(size), lx.origin))
			"torch":
				torches.append(lx.origin)
	horn_wall_parts(emit, SPANS[region], [], [], fixed_top)
	if not merl.is_empty():
		Scenery.scatter(host, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(C_MERL, 0.0, false, "ashlar"))
	return torches


static var _bake_mats := {}


## Dünya: yayımcının parçalarını (kutu, silindir) 240 m'lik parçalar ve desen başına tek ağa pişirir (renk köşe renginde,
## desen bölümdekiyle aynı üçlü düzlem dokusu, dış çizgi korunur). parts: [tür, boyut, dönüşüm, renk, desen]
static func bake_parts(parts: Array, parent: Node3D, node_name: String, chunk := 240.0) -> Array:
	var groups := {}
	var bm := BoxMesh.new()
	var box_arr := bm.get_mesh_arrays()
	var cyl_cache := {}
	for p: Array in parts:
		var size: Vector3 = p[1]
		var xf: Transform3D = p[2]
		var col: Color = p[3]
		var pat: String = p[4]
		var arr: Array
		var sc: Transform3D
		if p[0] == "cyl":
			var ck := "%.2f|%.2f" % [size.x, size.y]
			if not cyl_cache.has(ck):
				var cm := CylinderMesh.new()
				cm.top_radius = size.x
				cm.bottom_radius = size.x
				cm.height = size.y
				cm.radial_segments = 14
				cm.rings = 1
				cyl_cache[ck] = cm.get_mesh_arrays()
			arr = cyl_cache[ck]
			sc = xf
		else:
			arr = box_arr
			sc = Transform3D(xf.basis * Basis.from_scale(size), xf.origin)
		var key := "%d|%d|%s" % [int(floorf(xf.origin.x / chunk)), int(floorf(xf.origin.z / chunk)), pat]
		if not groups.has(key):
			var s := SurfaceTool.new()
			s.begin(Mesh.PRIMITIVE_TRIANGLES)
			groups[key] = [s, pat]
		var stl: SurfaceTool = groups[key][0]
		var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var norms: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
		var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
		var nb := sc.basis.inverse().transposed()
		for i in idx:
			stl.set_color(col)
			stl.set_normal((nb * norms[i]).normalized())
			stl.add_vertex(sc * verts[i])
	var out: Array = []
	for k: String in groups:
		var pat: String = groups[k][1]
		if not _bake_mats.has(pat):
			var m := Props.mat(Color.WHITE, 0.0, false, pat).duplicate() as StandardMaterial3D
			m.vertex_color_use_as_albedo = true
			_bake_mats[pat] = m
		var mi := MeshInstance3D.new()
		mi.name = node_name
		mi.mesh = (groups[k][0] as SurfaceTool).commit()
		mi.material_override = _bake_mats[pat]
		parent.add_child(mi)
		out.append(mi)
	return out
