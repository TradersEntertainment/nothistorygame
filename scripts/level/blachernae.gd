class_name Blachernae
extends Node3D
## Blakherna sarayı önündeki sur, 12 Mayıs 1453 gecesi (Bölüm 30 ve 30o).
## Kara surlarının kuzey ucu: burada çifte sur ve hendek yoktur; tek, yüksek bir sur (Manuel Komnenos'un suru) ve
## arkasında yamaca tırmanan saray, önünde Tekfur Sarayı'nın tuğla-taş bantlı cephesi. O gece Osmanlılar bu sura
## büyük bir gece hücumu yaptı; İmparator bizzat geldi, hücum püskürtüldü.
## Koordinatlar: sur x boyunca (−60…60), dış yüzü z = WALL_Z1 (ova +Z), iç yüzü z = WALL_Z0; yürüyüş yolu y = WALK_Y.
##   · sur gövdesi, mazgallar (dışa bakan), 20 m arayla kuleler; yürüyüş yolu katı, iki kenarında görünmez korkuluk
##     (merdivenlerin ucunda açıklık: ladder_gap)
##   · içeride: avlu zemini, yola inen taş merdiven, sarayın cephesi ve ışıklı pencereler
##   · dışarıda: sura doğru hafifçe yükselen yamaç (katı), dağınık moloz, çalı; uzakta Osmanlı ordusu ve ateşleri

const WALL_Z0 := 0.0
const WALL_Z1 := 4.6
const WALK_Y := 12.0
const WALL_H := 12.0
const TOWERS := [-40.0, -20.0, 20.0, 40.0]
const C_STONE := Color("c8b89a")
const C_BRICK := Color("9a5040")

var lights: Array = []
var moon: DirectionalLight3D
var ladder_gaps: Array = []        # x'ler: dış korkulukta merdiven açıklığı
var _t := 0.0


static func slope_y(_z: float) -> float:
	## Dış zemin düz (y 0): hücum kalabalığı (BattleExtras) ve merdiven ayakları düz zemine göre kurulur
	return 0.0


func _ready() -> void:
	Audio.voice_space("outdoor")
	moon = Night.environment(self, 0.008)
	moon.rotation_degrees = Vector3(-30, 150, 0)
	_ground()
	_wall()
	_palace()
	_outside()


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


func _ground() -> void:
	# İçeride avlu (katı, düz)
	Props.set_pattern(Props.solid(self, Vector3(140, 0.4, 60), Vector3(0, -0.2, -30.0), Color.WHITE), Color("7a6e5a"), "cobble")
	# Dışarıda yamaç: üç kademeli katı parçalar (yürünür)
	for k in 6:
		var z0 := WALL_Z1 + k * 10.0
		var y0 := slope_y(z0 + 5.0)
		var b := Props.solid(self, Vector3(140, 0.4, 10.2), Vector3(0, y0 - 0.2, z0 + 5.0), Color.WHITE)
		Props.set_pattern(b, Color("4e4a36"), "dirt")


func _wall() -> void:
	var t := WALL_Z1 - WALL_Z0
	var body := Props.solid(self, Vector3(120, WALL_H, t), Vector3(0, WALL_H * 0.5, (WALL_Z0 + WALL_Z1) * 0.5), Color.WHITE)
	Props.set_pattern(body, C_STONE, "ashlar")
	body.set_meta("no_climb", true)
	# Tuğla bantlar (dış yüz)
	for y: float in [3.2, 6.6, 10.0]:
		Props.box(self, Vector3(120, 0.45, 0.06), Vector3(0, y, WALL_Z1 + 0.03), C_BRICK)
	# Mazgallar dış kenarda
	var merl: Array = []
	var x := -59.0
	while x < 59.0:
		merl.append(Transform3D(Basis.from_scale(Vector3(1.1, 1.1, 0.6)), Vector3(x, WALK_Y + 0.55, WALL_Z1 - 0.3)))
		x += 1.9
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(C_STONE.darkened(0.08), 0.0, false, "ashlar"))
	# Kuleler (dışa taşar)
	for tx: float in TOWERS:
		var tw := Props.solid(self, Vector3(8.0, WALL_H + 5.0, 8.0), Vector3(tx, (WALL_H + 5.0) * 0.5, WALL_Z1 + 1.6), Color.WHITE)
		Props.set_pattern(tw, C_STONE.darkened(0.04), "ashlar")
		for y: float in [4.0, 9.0, 14.0]:
			Props.box(self, Vector3(8.04, 0.45, 8.04), Vector3(tx, y, WALL_Z1 + 1.6), C_BRICK)
		lights.append(Night.torch(self, Vector3(tx - 4.6, WALK_Y, WALL_Z0 + 0.6), 1.6))
	# Yürüyüş yolu boyunca meşaleler
	for k in 6:
		lights.append(Night.torch(self, Vector3(-30.0 + k * 12.0, WALK_Y, WALL_Z0 + 0.3), 1.4))
	# İçeriden yürüyüş yoluna çıkan taş merdiven (x −8)
	var stair := Props.ramp(self, Vector3(-14.0, 0.0, WALL_Z0 - 6.0), Vector3(-6.0, WALK_Y, WALL_Z0 - 0.2), 2.4, Color.WHITE)
	Props.set_pattern(stair, C_STONE.darkened(0.1), "ashlar")


## Yürüyüş yolunun korkulukları: dış kenarda (merdiven açıklıkları hariç) ve iç kenarda (merdiven başı hariç)
func build_guards(gaps: Array) -> void:
	ladder_gaps = gaps
	var xs: Array = [-60.0]
	for g: float in gaps:
		xs.append(g - 0.9)
		xs.append(g + 0.9)
	xs.append(60.0)
	for i in range(0, xs.size(), 2):
		var a: float = xs[i]
		var b: float = xs[i + 1]
		if b - a < 0.2:
			continue
		var g := Props.solid(self, Vector3(b - a, 3.0, 0.3), Vector3((a + b) * 0.5, WALK_Y + 1.5, WALL_Z1 - 0.1), Color.WHITE)
		g.get_child(0).visible = false
		g.set_meta("no_climb", true)
	for seg: Vector2 in [Vector2(-60.0, -7.4), Vector2(-4.6, 60.0)]:
		var g2 := Props.solid(self, Vector3(seg.y - seg.x, 3.0, 0.3), Vector3((seg.x + seg.y) * 0.5, WALK_Y + 1.5, WALL_Z0 + 0.1), Color.WHITE)
		g2.get_child(0).visible = false
		g2.set_meta("no_climb", true)


## Tekfur Sarayı: üç katlı, tuğla-taş bantlı cephe; kemerli pencereler (ışıklı), arkada yamaca tırmanan saray
func _palace() -> void:
	var z := -16.0
	var fac := Props.solid(self, Vector3(26.0, 16.0, 10.0), Vector3(0, 8.0, z - 5.0), Color.WHITE)
	Props.set_pattern(fac, Color("d8c8a8"), "tekfur")
	var glow := Props.mat(Color("ffc070"), 2.2, false, "", false)
	for row in 3:
		for k in 6:
			var w := Props.box(self, Vector3(1.4, 2.0 if row > 0 else 2.6, 0.08), Vector3(-10.0 + k * 4.0, 3.0 + row * 4.6, z + 0.02), Color("ffc070"))
			w.material_override = glow if (row + k) % 3 != 0 else Props.mat(Color("1c1814"))
			Props.box(self, Vector3(1.8, 0.35, 0.12), Vector3(-10.0 + k * 4.0, 4.3 + (0.3 if row == 0 else 0.0) + row * 4.6, z + 0.03), C_BRICK)
	for k in 2:
		var ox := -9.0 + k * 18.0
		var tw := Props.solid(self, Vector3(5.0, 20.0, 5.0), Vector3(ox * 1.6, 10.0, z - 4.0), Color.WHITE)
		Props.set_pattern(tw, Color("d8c8a8"), "tekfur")
	var l := OmniLight3D.new()
	l.light_color = Color("ffb060")
	l.light_energy = 2.0
	l.omni_range = 22.0
	l.position = Vector3(0, 6.0, z + 4.0)
	add_child(l)
	# Arkada yamaca tırmanan şehir (silüet)
	var rng := RandomNumberGenerator.new()
	rng.seed = 512
	for i in 30:
		var p := Vector3(rng.randf_range(-70.0, 70.0), 0, rng.randf_range(-80.0, -40.0))
		var h := rng.randf_range(5.0, 11.0)
		Props.box(self, Vector3(rng.randf_range(5.0, 9.0), h, rng.randf_range(5.0, 8.0)), p + Vector3(0, h * 0.5 + (-p.z - 40.0) * 0.2, 0),
			Color("c8b8a0").darkened(rng.randf_range(0.0, 0.3)))


func _outside() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1205
	var d := Dressing.new(1205)
	for i in 50:
		var p := Vector3(rng.randf_range(-58.0, 58.0), 0, rng.randf_range(WALL_Z1 + 1.5, 50.0))
		p.y = slope_y(p.z) + 0.1
		d.ball(rng.randf_range(0.25, 0.7), p, C_STONE.darkened(rng.randf_range(0.2, 0.5)), Vector3(1.2, 0.6, 1.0), 5)
	d.build(self)
	# Uzakta ordu ateşleri
	for i in 18:
		var p := Vector3(rng.randf_range(-60.0, 60.0), 0, rng.randf_range(70.0, 110.0))
		p.y = slope_y(p.z)
		lights.append(Night.campfire(self, p, 0.9))
