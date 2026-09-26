class_name LandWalls
extends Node3D
## Kara surları, Lykos vadisi (Mesoteichion, Aziz Romanos kapısının yakını), 1453 Mayısı, gece.
## Theodosius surlarının kesiti: şehir tarafı, iç sur (12 m, kuleli), peribolos (surlar arası set),
## dış sur (8 m, mazgallı), önünde korkuluk ve hendek, ötede ova, Osmanlı ordugâhı ve Urban'ın büyük topu.
## Dış surda topların açtığı gedik: moloz yığını, üstünde her gece büyüyen tahta-fıçı-toprak barikat (stockade).
## x sur boyunca, +z dışarıya (ordugâha) doğrudur. Bölüm 20 (Gedik), 22 (Kule) ve 26 (Şafak) kullanır.

const INNER_Z0 := -4.0
const INNER_Z1 := -0.6
const INNER_H := 12.0
const OUTER_Z0 := 14.0
const OUTER_Z1 := 16.0
const OUTER_H := 8.0
const BREACH := Vector3(0.0, 0.0, 15.0)
const BREACH_W := 7.0
const DEPOT := Vector3(11.0, 0.0, 2.2)
const CANNON := Vector3(9.0, 1.5, 118.0)
const MANTLETS := [Vector3(-5.5, 0.0, 10.0), Vector3(5.5, 0.0, 10.0)]
const SPAWN := Vector3(9.0, 0.05, 5.0)
const STAGES := 10

const C_STONE := Color("cdbd9e")
const C_WOOD := Color("7a5634")

var lights: Array = []
var stages: Array[Node3D] = []
var moon: DirectionalLight3D
var env: WorldEnvironment
var _flash: OmniLight3D
var _t := 0.0


func _ready() -> void:
	Audio.voice_space("outdoor")
	moon = Night.environment(self, 0.006)
	moon.rotation_degrees = Vector3(-34, 160, 0)
	for c in get_children():
		if c is WorldEnvironment:
			env = c
	_build_ground()
	_build_inner()
	_build_outer()
	_build_breach()
	_build_depot()
	_build_field()


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


func _wall(size: Vector3, pos: Vector3, color := C_STONE) -> StaticBody3D:
	var w := Props.solid(self, size, pos, Color.WHITE)
	Props.set_pattern(w, color, "ashlar")
	w.set_meta("no_climb", true)
	return w


func _build_ground() -> void:
	Props.set_pattern(Props.solid(self, Vector3(100, 0.4, 40), Vector3(0, -0.2, -24.0), Color.WHITE), Color("8a7a60"), "cobble")
	var peri := Props.solid(self, Vector3(100, 0.4, OUTER_Z0 - INNER_Z1 + 0.2), Vector3(0, -0.2, (INNER_Z1 + OUTER_Z0) * 0.5), Color("6e6452"))
	peri.name = "Peribolos"
	# Dış taraf: korkuluklu set, hendek (çukur), ova
	Props.box(self, Vector3(100, 0.4, 3.0), Vector3(0, -0.2, 17.5), Color("6e6452"))
	Props.box(self, Vector3(100, 1.6, 0.8), Vector3(0, 0.6, 19.2), C_STONE.darkened(0.1))
	Props.box(self, Vector3(100, 0.2, 16.0), Vector3(0, -3.0, 28.0), Color("3a3a30"))
	Props.box(self, Vector3(100, 3.0, 0.6), Vector3(0, -1.5, 20.0), C_STONE.darkened(0.3))
	Props.box(self, Vector3(100, 3.0, 0.6), Vector3(0, -1.5, 36.0), Color("4a4436"))
	Props.box(self, Vector3(400, 0.4, 300), Vector3(0, -0.2, 186.0), Color("3a3e2a"))
	# Oyun alanının yan uçları: surlar arasında yıkıntı ve dikenli çit (görünür engel)
	for sx: float in [-1.0, 1.0]:
		var x := sx * 32.0
		_wall(Vector3(1.2, 3.0, OUTER_Z0 - INNER_Z1), Vector3(x, 1.5, (INNER_Z1 + OUTER_Z0) * 0.5), C_STONE.darkened(0.15))
		for i in 6:
			Props.cyl(self, 0.08, 2.2, Vector3(x - sx * 0.8, 1.0, 1.0 + i * 2.2), C_WOOD, Vector3(sx * 28.0, 0, 18.0), 5)


func _build_inner() -> void:
	_wall(Vector3(100, INNER_H, INNER_Z1 - INNER_Z0), Vector3(0, INNER_H * 0.5, (INNER_Z0 + INNER_Z1) * 0.5))
	var z := INNER_Z1
	var x := -48.0
	while x <= 48.0:
		Props.box(self, Vector3(1.2, 1.0, 0.8), Vector3(x, INNER_H + 0.5, z - 0.3), C_STONE.darkened(0.06))
		x += 2.0
	# Kuleler (peribolosa taşar)
	for tx: float in [-24.0, 24.0]:
		_wall(Vector3(9.0, INNER_H + 6.0, 8.0), Vector3(tx, (INNER_H + 6.0) * 0.5, INNER_Z0 + 4.0), C_STONE.darkened(0.03))
		for i in 3:
			Props.box(self, Vector3(0.8, 1.4, 0.1), Vector3(tx - 2.5 + i * 2.5, INNER_H + 2.0, INNER_Z0 + 8.03), Color("1c1814"))
		lights.append(Night.torch(self, Vector3(tx + 5.0, INNER_H, INNER_Z1 + 0.2), 1.2))
	# Arka kapı (poterna): peribolosa açılan küçük kapı; depo yanında
	Props.box(self, Vector3(2.0, 3.2, 0.1), Vector3(DEPOT.x + 3.5, 1.6, INNER_Z1 + 0.03), Color("15120f"))
	Props.cyl(self, 1.0, 0.1, Vector3(DEPOT.x + 3.5, 3.2, INNER_Z1 + 0.03), Color("15120f"), Vector3(90, 0, 0), 12)
	lights.append(Night.torch(self, Vector3(DEPOT.x + 1.8, 0, INNER_Z1 + 0.4), 2.2))


func _build_outer() -> void:
	var half := BREACH_W * 0.5
	for sx: float in [-1.0, 1.0]:
		var len := 48.0 - half
		var cx := sx * (half + len * 0.5)
		_wall(Vector3(len, OUTER_H, OUTER_Z1 - OUTER_Z0), Vector3(cx, OUTER_H * 0.5, (OUTER_Z0 + OUTER_Z1) * 0.5), C_STONE.darkened(0.05))
		var x := sx * (half + 0.8)
		while absf(x) < 48.0:
			Props.box(self, Vector3(1.1, 0.9, 0.7), Vector3(x, OUTER_H + 0.45, OUTER_Z1 - 0.3), C_STONE.darkened(0.1))
			x += sx * 1.8
		# Gediğin kırık kenarları: basamaklı, eğri taşlar
		for k in 5:
			Props.box(self, Vector3(0.9, OUTER_H - k * 1.5, 1.9), Vector3(sx * (half + 0.4 - k * 0.35), (OUTER_H - k * 1.5) * 0.5, (OUTER_Z0 + OUTER_Z1) * 0.5), C_STONE.darkened(0.15 + k * 0.03), Vector3(0, 0, sx * k * 4.0))
		# Dış sur kuleleri
		var tx := sx * 16.0
		_wall(Vector3(5.0, OUTER_H + 3.0, 5.0), Vector3(tx, (OUTER_H + 3.0) * 0.5, OUTER_Z1 + 1.0), C_STONE.darkened(0.08))
		lights.append(Night.torch(self, Vector3(tx - sx * 3.0, 0, OUTER_Z0 - 0.4), 2.2))
	# Surun iç yüzüne yaslı merdiven iskeleler (savunucular çıkar); görüntü
	for sx: float in [-1.0, 1.0]:
		for i in 8:
			Props.box(self, Vector3(1.4, 0.15, 0.5), Vector3(sx * 9.0, 0.5 + i * 0.95, OUTER_Z0 - 3.4 + i * 0.4), C_WOOD)


## Gedik: moloz yığını (katı, görünür engel) ve on aşamalı barikat.
func _build_breach() -> void:
	var b := BREACH
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	for i in 26:
		var p := b + Vector3(rng.randf_range(-BREACH_W * 0.5, BREACH_W * 0.5), rng.randf_range(0.1, 1.2), rng.randf_range(-1.2, 2.4))
		Props.ball(self, rng.randf_range(0.4, 0.9), p, C_STONE.darkened(rng.randf_range(0.1, 0.4)), Vector3(1.3, 0.6, 1.0), 6)
	var mound := Props.solid(self, Vector3(BREACH_W + 0.4, 2.2, 3.4), b + Vector3(0, 1.1, 0.6), Color("5a5244"))
	mound.set_meta("no_climb", true)
	mound.get_child(0).visible = false
	Props.box(self, Vector3(BREACH_W, 1.6, 3.0), b + Vector3(0, 0.55, 0.6), Color("5a5244"), Vector3(-12, 0, 0))
	# Barikat aşamaları: 0-3 fıçılar, 4-5 toprak sepetleri, 6-7 kalaslar, 8-9 kazıklar
	for s in STAGES:
		var n := Node3D.new()
		n.visible = false
		add_child(n)
		stages.append(n)
		match s:
			0, 1, 2, 3:
				for k in 2:
					var x := -3.0 + (s * 2 + k) * 0.78
					Props.cyl(n, 0.36, 0.95, b + Vector3(x, 1.95, -0.2), C_WOOD.darkened(0.05 * k), Vector3.ZERO, 10)
					Props.cyl(n, 0.37, 0.06, b + Vector3(x, 2.2, -0.2), Color("3a3634"), Vector3.ZERO, 10)
			4, 5:
				for k in 5:
					var x := -3.0 + ((s - 4) * 5 + k) * 0.62
					Props.cyl(n, 0.28, 0.45, b + Vector3(x, 2.65, -0.25), Color("9a7a48"), Vector3.ZERO, 8, 1.15)
					Props.ball(n, 0.26, b + Vector3(x, 2.9, -0.25), Color("5a4630"), Vector3(1, 0.5, 1), 6)
			6, 7:
				for k in 3:
					var y := 1.9 + ((s - 6) * 3 + k) * 0.32
					Props.box(n, Vector3(BREACH_W - 0.4, 0.26, 0.12), b + Vector3(0, y, -0.8), Color("8a6440").darkened(0.06 * k))
			8, 9:
				for k in 6:
					var x := -3.1 + ((s - 8) * 6 + k) * 0.55
					Props.cyl(n, 0.09, 2.2, b + Vector3(x, 3.5, -0.6), C_WOOD, Vector3(-12, 0, 0), 5, 0.02)
	Props.interactable(self, "breach", Vector3(BREACH_W, 3.0, 2.0), b + Vector3(0, 1.5, -1.6))
	# Siper: tekerlekli tahta kalkanlar (top atışında arkasına saklanılır)
	for m: Vector3 in MANTLETS:
		var sh := Props.solid(self, Vector3(2.4, 2.2, 0.25), m + Vector3(0, 1.2, 1.0), C_WOOD)
		sh.set_meta("no_climb", true)
		for k in 5:
			Props.box(self, Vector3(0.1, 2.2, 0.3), m + Vector3(-1.0 + k * 0.5, 1.2, 1.05), C_WOOD.darkened(0.2))
		for sx: float in [-1.0, 1.0]:
			Props.cyl(self, 0.3, 0.12, m + Vector3(sx * 1.0, 0.3, 1.2), Color("4a3422"), Vector3(0, 0, 90), 10)
		Props.label(self, "ΠΡΟΦΥΛΑΚΗ", m + Vector3(0, 2.0, 0.86), 22, Color("f2e6c9"), Vector3(0, 180, 0))
	lights.append(Night.torch(self, b + Vector3(-4.6, 0, -2.4), 2.4))
	lights.append(Night.torch(self, b + Vector3(4.6, 0, -2.4), 2.4))


## Malzeme deposu: fıçılar, toprak yığını ve sepetler, kalaslar. Oyuncu buradan yük alır.
func _build_depot() -> void:
	var d := DEPOT
	for i in 5:
		Props.cyl(self, 0.36, 0.95, d + Vector3(-2.6 + (i % 3) * 0.8, 0.48 + (i / 3) * 0.95, -0.6), C_WOOD.darkened((i % 2) * 0.1), Vector3.ZERO, 10)
	Props.ball(self, 1.3, d + Vector3(0.4, 0.2, 0.2), Color("5a4630"), Vector3(1.2, 0.6, 1.0), 8)
	for i in 4:
		Props.cyl(self, 0.28, 0.45, d + Vector3(1.8 + (i % 2) * 0.6, 0.23, 0.9 + (i / 2) * 0.6), Color("9a7a48"), Vector3.ZERO, 8, 1.15)
	for i in 6:
		Props.box(self, Vector3(3.2, 0.12, 0.3), d + Vector3(3.8, 0.1 + i * 0.13, -0.4 + (i % 2) * 0.05), Color("8a6440"))
	Props.interactable(self, "pile_barrel", Vector3(2.4, 2.0, 1.6), d + Vector3(-1.8, 1.0, -0.4))
	Props.interactable(self, "pile_earth", Vector3(2.4, 1.6, 2.4), d + Vector3(0.9, 0.8, 0.5))
	Props.interactable(self, "pile_plank", Vector3(3.4, 1.2, 1.4), d + Vector3(3.8, 0.6, -0.3))


## Ova: Osmanlı ordugâhının ateşleri ve çadırları, Urban'ın topu (ahşap siper arkasında).
func _build_field() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 29
	for i in 40:
		var p := Vector3(rng.randf_range(-160, 160), 0, rng.randf_range(130, 260))
		if i % 3 == 0:
			Night.tent(self, p, rng.randf_range(1.8, 3.0))
		var f := Props.ball(self, 0.5, p + Vector3(rng.randf_range(-4, 4), 0.4, 4.0), Color("ffb040"), Vector3.ONE, 4, 3.0)
		f.material_override = Props.mat(Color("ffb040"), 3.0, false, "", false)
	var c := CANNON
	Props.box(self, Vector3(8.0, 3.0, 0.5), c + Vector3(0, 0.0, -3.0), C_WOOD.darkened(0.2))
	Props.cyl(self, 0.9, 7.0, c + Vector3(0, 0.4, -1.5), Color("7a5a2a"), Vector3(88, 0, 0), 12)
	Props.cyl(self, 1.1, 0.4, c + Vector3(0, 0.45, -4.9), Color("5a4020"), Vector3(88, 0, 0), 12)
	_flash = OmniLight3D.new()
	_flash.position = c + Vector3(0, 1.0, -6.0)
	_flash.light_color = Color("ffb060")
	_flash.light_energy = 0.0
	_flash.omni_range = 60.0
	add_child(_flash)


## Topun ağzında parlama ve duman (uzakta).
func fire_flash() -> void:
	_flash.light_energy = 16.0
	create_tween().tween_property(_flash, "light_energy", 0.0, 0.6)
	Vfx.explosion(self, CANNON + Vector3(0, 0.5, -6.0), 1.4)


## Güllenin gediğe çarpması: toz, taş, sarsıntı.
func impact(at: Vector3) -> void:
	Vfx.explosion(self, at, 0.8)
	Vfx.dust(self, at, 1.6)


func set_repair(n: int) -> void:
	for i in stages.size():
		stages[i].visible = i < n


## Şafak: gökyüzü ve ay ışığı sabaha döner.
func make_dawn(t := 1.0) -> void:
	if env == null:
		return
	var e := env.environment
	var sm := e.sky.sky_material as ProceduralSkyMaterial
	var tw := create_tween().set_parallel()
	tw.tween_property(sm, "sky_top_color", Color("5a7ab0"), t)
	tw.tween_property(sm, "sky_horizon_color", Color("f0b080"), t)
	tw.tween_property(sm, "ground_horizon_color", Color("c89070"), t)
	tw.tween_property(e, "ambient_light_color", Color("c8b8b0"), t)
	tw.tween_property(e, "ambient_light_energy", 0.7, t)
	tw.tween_property(e, "fog_light_color", Color("d0a888"), t)
	tw.tween_property(moon, "light_color", Color("ffc890"), t)
	tw.tween_property(moon, "light_energy", 0.9, t)
	tw.tween_property(moon, "rotation_degrees", Vector3(-8, 180, 0), t)
