class_name Camp
extends Node3D
## Bölüm 4a: Osmanlı ordugâhı, 22 Nisan 1453 gecesi (GDD §9.3).
## Kazıklı çitle çevrili esir alanı: esir çadırı, kapanmış pazar tezgâhları, siper
## olacak sandık ve fıçılar. Tek çıkış, meşaleli nöbet noktası (Hasan ile Hüseyin).
## Çitin dışında ordugâh: çadırlar, kamp ateşleri, "OTAĞ" tabelası, ufukta surlar.

const PEN_X := 10.0
const PEN_Z0 := -12.0
const GATE_Z := 6.0
const GATE_HALF := 1.3
const ESCAPE_Z := 9.5

const TENT_SPAWN := Vector3(-4.0, 0.0, -5.6)
const MARKET_SPAWN := Vector3(6.2, 0.0, -2.0)
const HASAN_POS := Vector3(-1.0, 0.0, GATE_Z + 0.7)
const HUSEYIN_POS := Vector3(1.0, 0.0, GATE_Z + 0.7)

var hasan: Soldier
var huseyin: Soldier
var lights: Array = []
var _t := 0.0


func _ready() -> void:
	Night.environment(self, 0.014)
	_build_ground()
	_build_pen()
	_build_market()
	_build_gate()
	_build_camp()


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


func _build_ground() -> void:
	var noise := FastNoiseLite.new()
	noise.seed = 4
	noise.frequency = 0.03
	var hf := func(x: float, z: float) -> float:
		var d := Vector2(x, z).length()
		return noise.get_noise_2d(x, z) * clampf((d - 18.0) / 30.0, 0.0, 1.0) * 4.0
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		if absf(x) < PEN_X and z > PEN_Z0 and z < GATE_Z + 14.0:
			return Color("4a3a2a").lerp(Color("3a3024"), noise.get_noise_2d(x * 4.0, z * 4.0) * 0.5 + 0.5)
		return Color("26331f").lerp(Color("34402a"), noise.get_noise_2d(x * 3.0, z * 3.0) * 0.5 + 0.5)
	add_child(LowPoly.terrain(-90.0, 90.0, -90.0, 140.0, 45, 58, hf, cf))
	# Görünmez düz zemin (çarpışma)
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(200, 1, 260)
	shape.shape = box
	shape.position = Vector3(0, -0.5, 25)
	floor_body.add_child(shape)
	add_child(floor_body)


func _stake_line(a: Vector3, b: Vector3) -> void:
	var n := int(a.distance_to(b) / 0.42)
	for i in n + 1:
		var p := a.lerp(b, float(i) / maxf(1.0, n))
		var h := 2.4 + sin(i * 1.7) * 0.15
		Props.cyl(self, 0.16, h, p + Vector3(0, h / 2, 0), Color("5a4028"), Vector3(0, 0, sin(i * 2.3) * 2.0), 6)
		Props.cyl(self, 0.16, 0.3, p + Vector3(0, h + 0.15, 0), Color("6a4c30"), Vector3.ZERO, 6, 0.0)
	# Çarpışma: tek uzun kutu
	var mid := (a + b) / 2.0
	var len := a.distance_to(b)
	var body := StaticBody3D.new()
	body.position = mid + Vector3(0, 1.3, 0)
	body.rotation.y = atan2(b.x - a.x, b.z - a.z)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.35, 2.6, len)
	shape.shape = bs
	body.add_child(shape)
	add_child(body)


func _build_pen() -> void:
	_stake_line(Vector3(-PEN_X, 0, PEN_Z0), Vector3(PEN_X, 0, PEN_Z0))
	_stake_line(Vector3(-PEN_X, 0, PEN_Z0), Vector3(-PEN_X, 0, GATE_Z))
	_stake_line(Vector3(PEN_X, 0, PEN_Z0), Vector3(PEN_X, 0, GATE_Z))
	_stake_line(Vector3(-PEN_X, 0, GATE_Z), Vector3(-GATE_HALF, 0, GATE_Z))
	_stake_line(Vector3(GATE_HALF, 0, GATE_Z), Vector3(PEN_X, 0, GATE_Z))
	# Esir çadırı (üstünde "Frenk casusu" yazılı bir tahta)
	var t := Night.tent(self, TENT_SPAWN + Vector3(0, 0, -2.4), 2.0, Color("b8ad94"), Color("4a4038"))
	t.rotation.y = 0.0
	Props.box(self, Vector3(1.3, 0.35, 0.05), TENT_SPAWN + Vector3(0, 1.75, -0.35), Color("8a6a44"))
	Props.label(self, "FRENK CASUSU", TENT_SPAWN + Vector3(0, 1.75, -0.32), 30, Color("2a1a10"), Vector3.ZERO, 1.2)
	for i in 6:
		Props.box(self, Vector3(0.5, 0.08, 0.3), TENT_SPAWN + Vector3(-0.8 + (i % 3) * 0.6, 0.04, -1.0 - (i / 3) * 0.4), Color("c8a860"), Vector3(0, i * 25, 0))
	lights.append(Night.campfire(self, Vector3(-6.0, 0, -1.0), 0.8))
	# Siper: sandıklar ve fıçılar (nöbetçilerin görüşünü keser)
	var cover := [Vector3(-2.6, 0, 2.6), Vector3(2.8, 0, 3.4), Vector3(-5.5, 0, 3.0), Vector3(0.4, 0, -1.2), Vector3(4.5, 0, 0.8)]
	for i in cover.size():
		var p: Vector3 = cover[i]
		Props.solid(self, Vector3(1.2, 1.1, 0.9), p + Vector3(0, 0.55, 0), Color("8a6440"), Vector3(0, i * 17, 0))
		Props.box(self, Vector3(0.9, 0.8, 0.8), p + Vector3(0.2, 1.5, 0.05), Color("9a7448"), Vector3(0, i * 17 + 10, 0))
		Props.cyl(self, 0.35, 0.9, p + Vector3(-0.9, 0.45, 0.4), Color("6a4a2c"), Vector3.ZERO, 8)
		var barrel := StaticBody3D.new()
		barrel.position = p + Vector3(-0.9, 0.45, 0.4)
		var sh := CollisionShape3D.new()
		var cy := CylinderShape3D.new()
		cy.radius = 0.35
		cy.height = 0.9
		sh.shape = cy
		barrel.add_child(sh)
		add_child(barrel)


func _build_market() -> void:
	var awning := [Color("b3262d"), Color("2f5fa8"), Color("c98a3a"), Color("3a6b3a")]
	for i in 4:
		var p := Vector3(7.5, 0, -9.0 + i * 3.4)
		Props.solid(self, Vector3(1.4, 0.9, 2.4), p + Vector3(0, 0.45, 0), Color("7a5a38"))
		for k in 4:
			Props.cyl(self, 0.04, 2.2, p + Vector3(-0.65 + (k % 2) * 1.3, 1.1, -1.1 + (k / 2) * 2.2), Color("4a3020"), Vector3.ZERO, 4)
		Props.box(self, Vector3(1.8, 0.05, 2.8), p + Vector3(-0.2, 2.2, 0), awning[i], Vector3(0, 0, -10))
		# Örtülü mallar
		Props.box(self, Vector3(1.2, 0.3, 2.0), p + Vector3(0, 1.05, 0), Color("c8b894"), Vector3(0, 0, 3))
		for k in 3:
			Props.ball(self, 0.12, p + Vector3(-0.4 + k * 0.3, 1.25, 0.9), [Color("e0a020"), Color("b3262d"), Color("6a8a3a")][k], Vector3.ONE, 6)
	# Keçi ağılı ve saman
	Props.box(self, Vector3(1.6, 0.9, 1.2), Vector3(-7.5, 0.45, -9.5), Color("c8a860"))
	Props.box(self, Vector3(1.2, 0.6, 1.0), Vector3(-7.2, 1.2, -9.4), Color("d8b870"), Vector3(0, 20, 0))


func _build_gate() -> void:
	lights.append(Night.torch(self, Vector3(-GATE_HALF - 0.3, 0, GATE_Z + 0.2), 2.6))
	lights.append(Night.torch(self, Vector3(GATE_HALF + 0.3, 0, GATE_Z + 0.2), 2.6))
	# Mangal
	Props.cyl(self, 0.35, 0.5, Vector3(0, 0.5, GATE_Z + 2.2), Color("3a3a3a"), Vector3.ZERO, 8, 0.45)
	lights.append(Night.campfire(self, Vector3(0, 0.75, GATE_Z + 2.2), 0.4))
	hasan = Soldier.new(Color("b3262d"), "stand", "bork")
	hasan.position = HASAN_POS
	hasan.rotation.y = PI
	add_child(hasan)
	huseyin = Soldier.new(Color("2f5fa8"), "stand", "bork")
	huseyin.position = HUSEYIN_POS
	huseyin.rotation.y = PI
	add_child(huseyin)
	Props.interactable(self, "guards", Vector3(3.4, 2.0, 1.6), Vector3(0, 1.0, GATE_Z + 0.7))
	# Tabela: otağa giden yol
	Props.cyl(self, 0.06, 2.4, Vector3(2.6, 1.2, GATE_Z + 7.0), Color("4a3020"), Vector3.ZERO, 5)
	Props.box(self, Vector3(1.6, 0.4, 0.06), Vector3(3.2, 2.1, GATE_Z + 7.0), Color("8a6a44"), Vector3(0, 180, -4))
	Props.label(self, "OTAĞ →", Vector3(3.2, 2.1, GATE_Z + 6.96), 40, Color("2a1a10"), Vector3(0, 180, -4), 1.3)


func _build_camp() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var colors := [Color("d8cbb0"), Color("c8b894"), Color("e0d4b8"), Color("b8a888")]
	var bands := [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a"), Color("c98a3a")]
	for i in 34:
		var a := rng.randf_range(-PI * 0.95, PI * 0.95)
		var r := rng.randf_range(18.0, 60.0)
		var p := Vector3(sin(a) * r, 0, cos(a) * r + 8.0)
		if absf(p.x) < PEN_X + 3.0 and p.z < GATE_Z + 10.0:
			continue
		var t := Night.tent(self, p, rng.randf_range(1.6, 2.6), colors[i % 4], bands[i % 4])
		t.rotation.y = rng.randf() * TAU
	for i in 7:
		var p := Vector3(rng.randf_range(-40, 40), 0, rng.randf_range(14, 50))
		if absf(p.x) < 6.0:
			p.x += 12.0
		lights.append(Night.campfire(self, p, 1.0))
		for k in 3:
			var s := Soldier.new([Color("b3262d"), Color("2f5fa8"), Color("3a6b3a")][k], "stand", "bork" if k != 1 else "turban")
			var a := TAU * k / 3.0 + 0.4
			s.position = p + Vector3(cos(a), 0, sin(a)) * 1.6
			s.rotation.y = atan2(-cos(a), -sin(a))
			s.scale = Vector3(1, 0.8, 1)
			add_child(s)
	# Gece ordugâhı: çitin ötesinde yüzlerce çadır ve ateş (ufuk boş kalmaz)
	var avoid := [Rect2(-PEN_X - 6.0, PEN_Z0 - 6.0, (PEN_X + 6.0) * 2.0, GATE_Z - PEN_Z0 + 22.0)]
	var noise := FastNoiseLite.new()
	noise.seed = 4
	noise.frequency = 0.03
	var hf := func(x: float, z: float) -> float:
		var d := Vector2(x, z).length()
		return noise.get_noise_2d(x, z) * clampf((d - 18.0) / 30.0, 0.0, 1.0) * 4.0
	Scenery.camp(self, Vector3(0, 0, 20), 22.0, 110.0, 260, avoid, hf, 1454, true)
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color("ffb050")
	glow.emission_enabled = true
	glow.emission = Color("ff9a3a")
	glow.emission_energy_multiplier = 4.0
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var fires: Array = []
	for i in 90:
		var a := rng.randf() * TAU
		var r := rng.randf_range(24.0, 115.0)
		var p := Vector3(sin(a) * r, 0, cos(a) * r + 20.0)
		if Scenery._blocked(p, avoid):
			continue
		p.y = hf.call(p.x, p.z) + 0.3
		fires.append(Scenery._t(p, Vector3.ZERO, Vector3.ONE * rng.randf_range(0.8, 1.6)))
	var fm := Scenery._ball(0.35)
	fm.material = glow
	var fmi := Scenery.scatter(self, fm, fires, [])
	fmi.material_override = glow
	Scenery.hills(self, Vector3(0, 0, 20), 200.0, 26, Color("1a2418"), 44)
	# Ufukta surlar: meşale noktalarıyla
	var wall_z := 150.0
	Props.box(self, Vector3(420, 16, 6), Vector3(0, 6, wall_z), Color("2a2c34"))
	for i in 18:
		var x := -200.0 + i * 24.0
		Props.box(self, Vector3(10, 24, 10), Vector3(x, 10, wall_z - 2), Color("24262e"))
		var fl := Props.ball(self, 0.6, Vector3(x + 5.5, 16 + (i % 3), wall_z - 7.2), Color("ffb040"), Vector3.ONE, 4, 3.0)
		fl.material_override = Props.mat(Color("ffb040"), 4.0, false, "", false)
