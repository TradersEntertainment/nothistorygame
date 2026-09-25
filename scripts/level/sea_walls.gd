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
	_build_far_side()
	niko = Person.new({"face": "niko", "coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hair": Color("2a1e14"), "hat": "helm", "mustache": true, "skin": Color("d9a07a")})
	niko.position = Vector3(4.0, QUAY_Y + WALL_H, WALL_Z - 0.9)
	add_child(niko)


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


func _build_water() -> void:
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(600, 600)
	pm.subdivide_width = 120
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
	Props.set_pattern(body, Color("c9b89a"), "wall")
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
		Props.set_pattern(tb, Color("bfae90"), "wall")
		for y in [4.0, 8.0, 12.0]:
			Props.box(self, Vector3(6.05, 0.35, 0.06), Vector3(tx, QUAY_Y + y, WALL_Z + 2.06), Color("8a4a36"))
		Props.box(self, Vector3(0.5, 1.4, 0.08), Vector3(tx, QUAY_Y + 9.0, WALL_Z + 2.06), Color("1a1410"))
		lights.append(Night.torch(self, Vector3(tx + 2.2, QUAY_Y + WALL_H + 5.0, WALL_Z + 1.6), 0.8, true))
	# Surun tepesinde meşaleler
	for tx2 in [-12.0, 12.0, 22.0, 44.0]:
		var l := Night.torch(self, Vector3(tx2, top, WALL_Z - 0.2), 1.2, tx2 == 12.0 or tx2 == 22.0)
		if l:
			lights.append(l)
	# Küçük kapı: kemerli, ahşap, demir çivili
	Props.box(self, Vector3(2.2, 3.0, 0.3), Vector3(GATE_X, QUAY_Y + 1.5, WALL_Z + 0.1), Color("5a4028"))
	for i in 3:
		for k in 4:
			Props.ball(self, 0.04, Vector3(GATE_X - 0.75 + k * 0.5, QUAY_Y + 0.6 + i * 0.9, WALL_Z + 0.27), Color("2a2a2a"), Vector3.ONE, 4)
	Props.ring(self, 1.1, 1.4, Vector3(GATE_X, QUAY_Y + 3.0, WALL_Z + 0.12), Color("a89878"), Vector3(90, 0, 0))
	lights.append(Night.torch(self, Vector3(GATE_X + 1.7, QUAY_Y, WALL_Z + 0.4), 2.2))
	Props.interactable(self, "gate", Vector3(2.4, 3.0, 1.2), Vector3(GATE_X, QUAY_Y + 1.5, WALL_Z + 0.6))


## Karşı kıyı: Galata tarafında karanlık tepeler, kule, dağınık ışıklar.
func _build_far_side() -> void:
	var hf := func(x: float, z: float) -> float:
		return 2.0 + sin(x * 0.03) * 6.0 + cos(x * 0.05 + 1.0) * 4.0 + (z - 170.0) * 0.12
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		return Color("1c2418").lerp(Color("262e20"), clampf(y / 20.0, 0.0, 1.0))
	add_child(LowPoly.terrain(-250.0, 250.0, 170.0, 260.0, 40, 8, hf, cf))
	Props.cyl(self, 4.0, 34.0, Vector3(-30, 19, 190), Color("2a2c34"), Vector3.ZERO, 10)
	Props.cyl(self, 4.6, 7.0, Vector3(-30, 39, 190), Color("24262e"), Vector3.ZERO, 10, 0.2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in 40:
		var p := Vector3(rng.randf_range(-200, 200), 0, rng.randf_range(175, 230))
		p.y = hf.call(p.x, p.z) + 1.0
		var f := Props.ball(self, 0.5, p, Color("ffb040"), Vector3.ONE, 4, 3.0)
		f.material_override = Props.mat(Color("ffb040"), 3.0, false, "", false)
