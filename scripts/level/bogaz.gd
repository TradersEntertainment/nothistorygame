class_name Bogaz
extends Node3D
## Boğazkesen (Rumelihisarı), 1452 (Bölüm 33o). Boğaz'ın en dar yeri, Rumeli kıyısı.
## Koordinatlar: su y 0; Rumeli kıyısı z < 0 (yamaç yukarı −z), Boğaz +z, karşı kıyı (Anadoluhisarı) z ~ 520;
## akıntı güneye, +x yönünde.
##   · Halil Paşa'nın deniz kulesi (silindir, gövde y 1 → TOP_Y), önünde iki katlı iskele ve üstte altı kalaslı yürüme
##     yolu; kulenin tepesinde çıkrık (kol, makara, ip) ve ön mazgalda dört taşlık yuva
##   · kıyıda taş rıhtım (y 1), çıkrığın tamburu ve çeviren işçiler; rıhtımın doğusunda batarya (küçük top, Urban'ın
##     büyük topu); yamaçta Zağanos ve Saruca Paşa'nın kuleleri ve kuleleri bağlayan perde duvarlar
##   · karşı kıyıda tepeler ve Anadoluhisarı'nın siluet

const QUAY_Y := 1.0
const QUAY_HALF := 255.0        # rıhtımın yarı uzunluğu (x): arazinin bütün genişliği
const TOWER := Vector3(0.0, 0.0, -32.0)
const TOWER_R := 9.0
const TOP_Y := 14.5
const DECK2_Y := 6.0
const WALK_Y := 14.3
const WALK_Z := -22.6           # yürüme yolunun ortası (kulenin ön yüzüne yaslı)
const WALK_X0 := -10.0          # yürüme yolu x −10 → +2 (altı kalas)
const CLIMB_X := -9.0           # serbest tırmanılan dikme demeti
const DRUM := Vector3(4.0, QUAY_Y, -14.5)
const ARM_PIVOT := Vector3(0.0, TOP_Y + 4.0, -26.0)
const ARM_TIP := Vector3(0.0, TOP_Y + 4.0, -16.5)
const SOCKETS := [Vector3(-2.4, TOP_Y + 0.2, -23.4), Vector3(-0.8, TOP_Y + 0.2, -23.2), Vector3(0.8, TOP_Y + 0.2, -23.2), Vector3(2.4, TOP_Y + 0.2, -23.4)]
const SMALL_GUN := Vector3(18.0, QUAY_Y, -4.0)
const BIG_GUN := Vector3(32.0, QUAY_Y, -5.0)
const C_STONE := Color("c8b898")
const C_WOOD := Color("8a6440")

var planks: Array[Node3D] = []          # yürüme yolunun kalasları (x sırasıyla)
var ladder1: Ladder
var ladder2: Node3D                     # kırılan merdiven
var arm: Node3D
var sun: DirectionalLight3D
var env: WorldEnvironment
var rival_stones: Array = []            # [taş, alt, üst, faz]
var _t := 0.0


static func ground_y(x: float, z: float) -> float:
	if z > -0.5:
		return -3.0
	if z > -16.0 and x > -60.0 and x < 70.0:
		return QUAY_Y
	var h := QUAY_Y + smoothstep(-16.0, -110.0, z) * (26.0 + 6.0 * sin(x * 0.02 + 0.8))
	return h


func _ready() -> void:
	_env()
	_ground()
	_water()
	_tower()
	_scaffold()
	_crane()
	_rivals()
	_battery()
	_far_shore()


func _process(delta: float) -> void:
	_t += delta
	# Rakip kulelerin çıkrıkları: taşlar yükselir, iner (yalnız görüntü)
	for r: Array in rival_stones:
		var st: Node3D = r[0]
		var k := 0.5 - 0.5 * cos(_t * 0.4 + float(r[3]))
		st.position.y = lerpf(float(r[1]), float(r[2]), k)


func _env() -> void:
	sun = Night.environment(self, 0.0)
	sun.rotation_degrees = Vector3(-40, 140, 0)
	sun.light_color = Color("fff0d8")
	sun.light_energy = 1.25
	for c in get_children():
		if c is WorldEnvironment:
			env = c
	if env:
		var e := env.environment
		var sm := e.sky.sky_material as ProceduralSkyMaterial
		if sm:
			sm.sky_top_color = Color("4a86c8")
			sm.sky_horizon_color = Color("d8e4ec")
			sm.ground_horizon_color = Color("8a9a7a")
		e.ambient_light_color = Color("c8ccd4")
		e.ambient_light_energy = 0.65
		e.tonemap_exposure = 0.92          # gece ortamının 1.1 pozlaması gündüz güneşinde taşları bembeyaz yakıyordu
		e.fog_density = 0.0004
		e.fog_light_color = Color("c8d6e0")      # gündüz pusu (Night ortamının lacivert sisi karşı kıyıyı kara bir kütle yapıyordu)
		env.set_meta("fog_cap", 0.0004)          # Look'un gündüz pusu 520 m ötedeki Anadolu yakasını süt beyazına boğuyordu


## Kasım öğleden sonrası: soğuk, alçak güneş
func make_november() -> void:
	if env == null:
		return
	var e := env.environment
	var sm := e.sky.sky_material as ProceduralSkyMaterial
	if sm:
		sm.sky_top_color = Color("6a84a0")
		sm.sky_horizon_color = Color("c8ccd0")
	e.ambient_light_color = Color("b8bcc8")
	e.fog_density = 0.0007             # kasım pusu: karşı kıyı ve Anadoluhisarı seçilsin (0.004'te tümden kayboluyordu)
	e.fog_light_color = Color("b4bec8")
	sun.rotation_degrees = Vector3(-18, 200, 0)
	sun.light_color = Color("ffe8c8")
	sun.light_energy = 0.95


func _ground() -> void:
	# Rıhtım (katı taş) ve yamaç (LowPoly arazi)
	# Rıhtım kıyı boyunca uzanır (eskiden x −60 → 70 arasıydı: uçlarından boşluğa düşülüyordu)
	Props.set_pattern(Props.solid(self, Vector3(QUAY_HALF * 2.0, QUAY_Y + 3.0, 16.0), Vector3(0.0, (QUAY_Y - 3.0) * 0.5, -8.5), Color.WHITE), Color("a89a80"), "cobble")
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		return Color("6a7a44").lerp(Color("8a7a58"), clampf(0.5 + 0.5 * sin(x * 0.05 + z * 0.03), 0.0, 1.0) * 0.5).darkened(clampf(steep * 0.5, 0.0, 0.25))
	var hf := func(x: float, z: float) -> float:
		return ground_y(x, minf(z, -16.2))
	# Yamaç katıdır: iskeleden, kuleden ya da rıhtımın arkasından düşen yamaca basar (eskiden yalnız görüntüydü,
	# içinden geçilip haritanın altına düşülüyordu)
	var slope := LowPoly.terrain(-260.0, 260.0, -260.0, -15.0, 52, 30, hf, cf)
	add_child(slope)
	LowPoly.solid(slope)
	# Rıhtımın önünde deniz tabanı (görünmez, 3 m derinde): denize düşen bölümün kuralıyla rıhtıma çıkarılır; kural
	# çalışmasa bile suyun içinden haritanın altına düşülmez
	var bed := Props.solid(self, Vector3(QUAY_HALF * 2.0, 1.0, 80.0), Vector3(0.0, -3.5, 39.5), Color.WHITE)
	bed.get_child(0).visible = false
	# Arazinin dış kenarında görünmez sınır (ötesi boşluk): yamacın tepesinden aşağı düşülmez
	for spec: Array in [[Vector3(4.0, 60.0, 520.0), Vector3(-258.0, 30.0, -137.0)], [Vector3(4.0, 60.0, 520.0), Vector3(258.0, 30.0, -137.0)],
			[Vector3(520.0, 60.0, 4.0), Vector3(0.0, 30.0, -258.0)]]:
		var edge := Props.solid(self, spec[0], spec[1], Color.WHITE)
		edge.get_child(0).visible = false
		edge.set_meta("no_climb", true)
	# Rıhtım kenarında babalar, harç teknesi, taş yığınları
	for k in 6:
		Props.make_solid(Props.cyl(self, 0.2, 0.7, Vector3(-40.0 + k * 18.0, QUAY_Y + 0.35, -1.2), Color("3a3a40"), Vector3.ZERO, 8))
	for k in 5:
		var p := Vector3(-14.0 + k * 3.2, QUAY_Y, -12.0 + (k % 2) * 1.6)
		for j in 3:
			var sb := Props.box(self, Vector3(1.1, 0.6, 0.8), p + Vector3(0, 0.3 + j * 0.6, 0), C_STONE.darkened(0.05 * j))
			Props.set_pattern(sb, C_STONE.darkened(0.12 + 0.05 * j), "ashlar")     # dokusuz açık taş güneşte bembeyaz görünüyordu
			Props.make_solid(sb)
	Props.make_solid(Props.box(self, Vector3(2.2, 0.4, 1.2), Vector3(-6.0, QUAY_Y + 0.2, -8.0), Color("6a4a2c")))
	Props.box(self, Vector3(2.0, 0.1, 1.0), Vector3(-6.0, QUAY_Y + 0.42, -8.0), Color("b8b0a0"))


func _water() -> void:
	var m := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(1400.0, 1200.0)
	m.mesh = pm
	m.position = Vector3(0, 0.0, 560.0)
	m.material_override = CityPanorama.water_mat()
	add_child(m)
	# Akıntıburnu kayaları (güneyde, +x)
	for k in 6:
		var p := Vector3(120.0 + k * 9.0, -0.4, 40.0 + (k % 3) * 14.0)
		Props.ball(self, 2.2 + (k % 2) * 0.8, p, Color("5a5a52"), Vector3(1.2, 0.7, 1.0), 7)
		var foam := Props.cyl(self, 3.2, 0.04, Vector3(p.x, 0.05, p.z), Color("e8eef0"), Vector3.ZERO, 14)
		foam.material_override = Props.mat(Color(0.92, 0.95, 0.96, 0.6), 0.0, true, "", false)


## Halil Paşa'nın kulesi: dolu silindir gövde (katı), tepede döşeme ve mazgal halkası; ön mazgalda dört taşlık yuva
func _tower() -> void:
	var body := Props.cyl(self, TOWER_R, TOP_Y - QUAY_Y, TOWER + Vector3(0, (TOP_Y + QUAY_Y) * 0.5, 0), Color.WHITE, Vector3.ZERO, 24)
	Props.set_pattern(body, C_STONE, "ashlar")
	Props.make_solid(body)
	body.set_meta("no_climb", true)
	# Mazgallar (ön yüzde yuva boşluğu)
	for i in 24:
		var a := TAU * i / 24.0
		var p := TOWER + Vector3(sin(a) * (TOWER_R - 0.5), TOP_Y + 0.6, cos(a) * (TOWER_R - 0.5))
		if p.z > TOWER.z + TOWER_R - 2.5 and absf(p.x) < 3.6:
			continue
		var mb := Props.box(self, Vector3(1.3, 1.2, 0.9), p, C_STONE.darkened(0.08), Vector3(0, rad_to_deg(a), 0))
		Props.set_pattern(mb, C_STONE.darkened(0.15), "ashlar")
		Props.make_solid(mb)
	# Yuvanın altındaki taş sırası (yuvalar bu sıranın üstünde)
	Props.box(self, Vector3(7.0, 0.3, 1.0), Vector3(0, TOP_Y + 0.0, TOWER.z + TOWER_R - 0.6), C_STONE.darkened(0.15))
	# Perde duvar: kuleden yamaca
	for spec in [[Vector3(TOWER_R, 0, -2.0), Vector3(70.0, 0, -60.0)], [Vector3(-TOWER_R, 0, -2.0), Vector3(-70.0, 0, -58.0)]]:
		var a: Vector3 = TOWER + (spec[0] as Vector3)
		var b: Vector3 = spec[1]
		# Yamaca basamak basamak tırmanan parçalar: her parça kendi en alçak zeminine kadar iner, üstte mazgallar
		var yaw := rad_to_deg(atan2(b.x - a.x, b.z - a.z))
		var n := 10
		for k in n:
			var p0 := a.lerp(b, float(k) / n)
			var p1 := a.lerp(b, float(k + 1) / n)
			var mid := (p0 + p1) * 0.5
			var seg := Vector2(p1.x - p0.x, p1.z - p0.z).length() + 0.3
			var lo := minf(ground_y(p0.x, minf(p0.z, -16.2)), ground_y(p1.x, minf(p1.z, -16.2))) - 2.0
			var top := maxf(ground_y(p0.x, minf(p0.z, -16.2)), ground_y(p1.x, minf(p1.z, -16.2))) + 9.0
			var w := Props.box(self, Vector3(3.0, top - lo, seg), Vector3(mid.x, (top + lo) * 0.5, mid.z), Color.WHITE, Vector3(0, yaw, 0))
			Props.set_pattern(w, C_STONE.darkened(0.05), "ashlar")
			Props.make_solid(w)          # perde duvarın içinden yürünmez
			for j in 3:
				var mp := p0.lerp(p1, (j + 0.5) / 3.0)
				var mw := Props.box(self, Vector3(3.2, 1.1, 1.0), Vector3(mp.x, top + 0.55, mp.z), C_STONE.darkened(0.1), Vector3(0, yaw, 0))
				Props.set_pattern(mw, C_STONE.darkened(0.12), "ashlar")


## İskele: kulenin ön yüzünde, dikmeler ve kirişler; 2. kat döşemesi (merdivenle), üstte altı kalaslı yürüme yolu.
## Serbest tırmanış dikme demetinde (x CLIMB_X): görünmez katı bir yüzey, önünde dikme ve kirişler.
func _scaffold() -> void:
	var z0 := -23.4
	var z1 := -19.4
	# Dikmeler ve yatay kirişler
	for x: float in [-10.0, -6.0, -2.0, 2.0]:
		for z: float in [z0 + 0.2, z1]:
			Props.make_solid(Props.cyl(self, 0.09, WALK_Y - QUAY_Y + 1.2, Vector3(x, (WALK_Y + QUAY_Y) * 0.5 + 0.6, z), Color("6a4a2c"), Vector3.ZERO, 6))
	var y := QUAY_Y + 1.2
	while y < WALK_Y:
		Props.box(self, Vector3(12.4, 0.1, 0.1), Vector3(-4.0, y, z1), Color("7a5634"))
		Props.box(self, Vector3(0.1, 0.1, 4.0), Vector3(CLIMB_X - 1.0, y, (z0 + z1) * 0.5), Color("7a5634"))
		y += 1.2
	# 2. kat döşemesi
	var deck := Props.solid(self, Vector3(12.4, 0.2, z1 - z0), Vector3(-4.0, DECK2_Y - 0.1, (z0 + z1) * 0.5), Color.WHITE)
	Props.set_pattern(deck, C_WOOD, "wood")
	# Merdiven 1 (rıhtım → 2. kat)
	ladder1 = Ladder.new(DECK2_Y - QUAY_Y + 0.6, 12.0, Color("6a4a2c"))
	ladder1.position = Vector3(-4.0, QUAY_Y, z1 + (DECK2_Y - QUAY_Y + 0.6) * sin(deg_to_rad(12.0)) + 0.1)
	add_child(ladder1)
	# Merdiven 2 (2. kat → yürüme yolu): bölümde kırılır
	ladder2 = Node3D.new()
	add_child(ladder2)
	ladder2.position = Vector3(-6.5, DECK2_Y, z1 - 0.6)
	for sx: float in [-0.35, 0.35]:
		Props.cyl(ladder2, 0.05, 8.4, Vector3(sx, 4.2, 0), Color("6a4a2c"), Vector3(-8, 0, 0), 5)
	for k in 20:
		Props.cyl(ladder2, 0.03, 0.7, Vector3(0, 0.3 + k * 0.4, -0.06 * k * 0.4), Color("7a5634"), Vector3(0, 0, 90), 4)
	# Serbest tırmanış yüzü: dikme demeti (görünmez katı panel, önde dikmeler)
	var face := Props.solid(self, Vector3(1.6, WALK_Y - DECK2_Y, 0.3), Vector3(CLIMB_X, (WALK_Y + DECK2_Y) * 0.5, z0 + 0.15), Color.WHITE)
	face.get_child(0).visible = false
	for k in 3:
		Props.cyl(self, 0.07, WALK_Y - DECK2_Y, Vector3(CLIMB_X - 0.6 + k * 0.6, (WALK_Y + DECK2_Y) * 0.5, z0 + 0.4), Color("6a4a2c"), Vector3.ZERO, 6)
	# Yürüme yolu: altı kalas (x −10 → +2), her biri ayrı (çatırdayıp düşer)
	for i in 6:
		var p := Node3D.new()
		add_child(p)
		p.position = Vector3(WALK_X0 + 1.0 + i * 2.0, WALK_Y - 0.08, WALK_Z)
		var pl := Props.solid(p, Vector3(1.96, 0.16, 1.3), Vector3.ZERO, Color.WHITE)
		Props.set_pattern(pl, C_WOOD.darkened(0.05 * (i % 2)), "wood")
		planks.append(p)
	# Kalasların altındaki taşıyıcı kiriş (görüntü)
	Props.box(self, Vector3(12.0, 0.14, 0.14), Vector3(-4.0, WALK_Y - 0.3, WALK_Z + 0.6), Color("6a4a2c"))
	# İskelede çalışan işçiler (komşu dikmede: taş uzatır, mala, çekiç)
	for i in 3:
		var w := Person.new({"coat": [Color("8a6a4a"), Color("6a5040"), Color("7a6a50")][i], "pants": Color("e8e0d0"), "hat": "turban" if i % 2 == 0 else "bork",
			"mustache": true, "beard": i == 1, "skin": Color("c89070")})
		w.set_meta("no_talk", true)
		add_child(w)
		w.position = Vector3(-1.0 + i * 1.4, DECK2_Y, z0 + 1.0)
		w.rotation.y = PI
		w.set_activity(["hammer", "stir", "hammer"][i])


## Çıkrık: kulenin tepesinde dikme ve dışarı uzanan kol (ucunda makara); tambur rıhtımda, iki işçi çevirir
func _crane() -> void:
	Props.cyl(self, 0.22, ARM_PIVOT.y - TOP_Y, Vector3(ARM_PIVOT.x, (ARM_PIVOT.y + TOP_Y) * 0.5, ARM_PIVOT.z), Color("6a4a2c"), Vector3.ZERO, 8)
	arm = Node3D.new()
	add_child(arm)
	arm.position = ARM_PIVOT
	var len := ARM_PIVOT.distance_to(ARM_TIP)
	Props.box(arm, Vector3(0.3, 0.3, len + 1.2), Vector3(0, 0, len * 0.5 - 0.6), Color("6a4a2c"))
	Props.cyl(arm, 0.32, 0.2, Vector3(0, -0.3, len), Color("4a3a2a"), Vector3(0, 0, 90), 12)
	Props.cyl(arm, 0.04, len * 0.8, Vector3(0, 1.2, len * 0.45), Color("b89a6a"), Vector3(70, 0, 0), 4)     # gergi ipi
	# Tambur ve kollar
	var drum := Node3D.new()
	drum.name = "Drum"
	add_child(drum)
	drum.position = DRUM + Vector3(0, 0.9, 0)
	Props.make_solid(Props.cyl(drum, 0.55, 1.6, Vector3.ZERO, Color("6a4a2c"), Vector3(0, 0, 90), 12))
	for k in 4:
		Props.box(drum, Vector3(0.1, 2.0, 0.1), Vector3(0.9, 0, 0), Color("7a5634"), Vector3(k * 45.0, 0, 0))
	for sx: float in [-1.0, 1.0]:
		Props.make_solid(Props.box(self, Vector3(0.25, 1.4, 1.0), DRUM + Vector3(sx * 0.95, 0.7, 0), Color("5a3e26")))


## Zağanos ve Saruca Paşa'nın kuleleri (yamaçta): iskeleleri ve çıkrıkları, yükselen-inen taşlar
func _rivals() -> void:
	for spec in [[Vector3(78.0, 0, -66.0), 7.5, 22.0], [Vector3(-76.0, 0, -60.0), 7.0, 20.0]]:
		var c: Vector3 = spec[0]
		var r: float = spec[1]
		var h: float = spec[2]
		var gy := ground_y(c.x, c.z)
		var b := Props.cyl(self, r, h, Vector3(c.x, gy + h * 0.5 - 1.0, c.z), Color.WHITE, Vector3.ZERO, 20)
		Props.set_pattern(b, C_STONE.darkened(0.04), "ashlar")
		Props.make_solid(b)
		for x: float in [-4.0, 0.0, 4.0]:
			Props.cyl(self, 0.09, h * 0.8, Vector3(c.x + x, gy + h * 0.4, c.z + r + 1.0), Color("6a4a2c"), Vector3.ZERO, 6)
		for y in range(3, int(h * 0.8), 3):
			Props.box(self, Vector3(9.0, 0.12, 1.2), Vector3(c.x, gy + y, c.z + r + 1.0), C_WOOD)
		Props.box(self, Vector3(0.25, 0.25, 7.0), Vector3(c.x, gy + h + 2.5, c.z + r - 1.5), Color("6a4a2c"))
		var st := Props.box(self, Vector3(1.0, 0.6, 0.7), Vector3(c.x, gy + 2.0, c.z + r + 2.0), C_STONE)
		Props.cyl(st, 0.03, 4.0, Vector3(0, 2.3, 0), Color("b89a6a"), Vector3.ZERO, 4)
		rival_stones.append([st, gy + 2.0, gy + h - 2.0, randf() * TAU])


## Batarya: küçük top (uyarı) ve Urban'ın büyük topu; ikisi de "Pivot/Muzzle" düğümlü (CannonCrew)
var small_gun: Node3D
var big_gun: Node3D


func _battery() -> void:
	small_gun = _gun(SMALL_GUN, 0.22, 2.0, Color("7a5020"))
	big_gun = _gun(BIG_GUN, 0.55, 4.2, Color("8a6428"))
	# Toprak set, gülle yığını, barut fıçıları
	Props.make_solid(Props.box(self, Vector3(9.0, 0.8, 7.0), BIG_GUN + Vector3(0, -0.4 + 0.4, 1.02), Color("6a5a40")))
	for k in 6:
		Props.ball(self, 0.32, BIG_GUN + Vector3(-3.2 + (k % 3) * 0.66, 0.35 + (k / 3) * 0.5, 3.0), Color("8a8478"), Vector3.ONE, 8)
	for k in 3:
		Props.make_solid(Props.cyl(self, 0.32, 0.8, SMALL_GUN + Vector3(-3.0, 0.4, 1.0 + k * 0.8), Color("5a3e26"), Vector3.ZERO, 10))


func _gun(at: Vector3, r: float, length: float, col: Color) -> Node3D:
	var g := Node3D.new()
	add_child(g)
	g.position = at
	Props.make_solid(Props.box(g, Vector3(r * 4.0, r * 1.6, length * 0.9), Vector3(0, r * 0.8, length * 0.15), Color("5a3e26")))
	for sx: float in [-1.0, 1.0]:
		Props.cyl(g, r * 1.3, 0.12, Vector3(sx * r * 2.1, r * 1.3, length * 0.3), Color("3a2a1c"), Vector3(0, 0, 90), 10)
	var pv := Node3D.new()
	pv.name = "Pivot"
	pv.position = Vector3(0, r * 2.6, length * 0.2)
	g.add_child(pv)
	# Namlu denize bakar (−Z yerel → dünyada +Z: kök π döndürülür)
	Props.cyl(pv, r, length, Vector3(0, 0, -length * 0.45), col, Vector3(90, 0, 0), 12)
	Props.cyl(pv, r * 1.25, length * 0.12, Vector3(0, 0, -length * 0.92), col.darkened(0.15), Vector3(90, 0, 0), 12)
	var mz := Node3D.new()
	mz.name = "Muzzle"
	mz.position = Vector3(0, 0, -length * 0.98)
	pv.add_child(mz)
	g.rotation.y = PI
	return g


## Karşı kıyı (Asya yakası, ~550 m ötede): kıyıda dar bir düzlük, arkasında ağaçlık alçak tepeler; Göksu deresinin
## ağzında Anadoluhisarı (Yıldırım Bayezid, 1394: kare kule, sur ve köşe kuleleri), yanında küçük bir köy.
## (Eskiden dev koyu yuvarlaklardı: denizden kayalık dağlar gibi görünüyordu.)
const ASIA_Z := 520.0
const ANADOLU := Vector3(-40.0, 0.0, 528.0)

static func asia_y(x: float, z: float) -> float:
	var d := z - ASIA_Z
	if d < 0.0:
		return -3.0 + d * 0.05
	var h := 2.0 * smoothstep(0.0, 18.0, d) + 62.0 * smoothstep(25.0, 300.0, d)
	h *= 0.8 + 0.2 * sin(x * 0.009 + 1.1) + 0.1 * cos(x * 0.023)
	# Göksu vadisi (hisarın doğusu): tepeler açılır
	var v := exp(-pow((x - ANADOLU.x - 55.0) / 45.0, 2.0))
	h *= 1.0 - 0.7 * v
	h += 5.0 * sin(x * 0.031 + z * 0.012) * smoothstep(40.0, 200.0, d)
	return h


func _far_shore() -> void:
	var ahf := func(x: float, z: float) -> float: return asia_y(x, z)
	var acf := func(x: float, z: float, y: float, steep: float) -> Color:
		if y < 1.2:
			return Color("8a8068")                                   # kumsal, taşlık
		var c := Color("4e6a34").lerp(Color("6a6a3a"), 0.5 + 0.5 * sin(x * 0.05 + z * 0.03))
		c = c.lerp(Color("7a5a32"), clampf(0.3 + 0.3 * sin(x * 0.017 - z * 0.021), 0.0, 0.45))     # Kasım: sararmış yer yer
		return c.darkened(clampf(steep * 0.3, 0.0, 0.2))
	var land := LowPoly.terrain(-700.0, 700.0, ASIA_Z - 30.0, 980.0, 70, 24, ahf, acf)
	land.set_meta("no_walk", true)        # karşı kıyı: yürünmez (çarpışma gereksiz)
	land.material_override = LowPoly.vertex_color_material()     # dokulu zemin gölgelendiricisi uzakta lacivert bir kütle gibi kararıyordu
	add_child(land)
	var d := Dressing.new(331)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3310
	# Ağaçlar: yamaçlarda koyu yeşil öbekler (servi, çınar), sahilde seyrek
	for i in 260:
		var x := rng.randf_range(-680.0, 680.0)
		var z := rng.randf_range(ASIA_Z + 20.0, 900.0)
		var y := asia_y(x, z)
		if y < 2.0 or Vector2(x - ANADOLU.x, z - ANADOLU.z).length() < 45.0:
			continue
		if rng.randf() < 0.35:
			d.cyl(1.4, 11.0, Vector3(x, y + 5.5, z), Color("2e4a2a"), Vector3.ZERO, 6, 0.15)     # servi
		else:
			var r := rng.randf_range(3.0, 5.5)
			d.ball(r, Vector3(x, y + r * 0.9, z), Color("3e5a2e").lerp(Color("6a6a30"), rng.randf() * 0.4), Vector3(1.0, 0.85, 1.0), 6)
	# Anadoluhisarı: kare iç kule ve onu çeviren sur, kıyıya bakan köşelerde yuvarlak kuleler
	var stone := C_STONE.darkened(0.32)          # 500 m ötede, puslu havada açık taş bembeyaz görünüyordu
	var g := Vector3(ANADOLU.x, asia_y(ANADOLU.x, ANADOLU.z), ANADOLU.z)
	d.box(Vector3(12.0, 26.0, 12.0), g + Vector3(0, 13.0, 4.0), stone)
	for k in 4:
		var a := k * PI * 0.5
		d.box(Vector3(1.2, 1.4, 12.4), g + Vector3(0, 26.7, 4.0) + Vector3(cos(a), 0, sin(a)) * 5.8, stone.darkened(0.1), Vector3(0, rad_to_deg(a), 0))
	var hw := 24.0
	var hd := 16.0
	for side in 4:
		var along_x := side < 2
		var off := (-hd if side == 0 else hd) if along_x else (-hw if side == 2 else hw)
		var len := hw * 2.0 if along_x else hd * 2.0
		var pos := g + (Vector3(0, 4.5, off) if along_x else Vector3(off, 4.5, 0)) + Vector3(0, 0, 4.0)
		d.box(Vector3(len, 9.0, 2.4) if along_x else Vector3(2.4, 9.0, len), pos, stone)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			var tp := g + Vector3(sx * hw, 0, sz * hd + 4.0)
			d.cyl(3.6, 13.0, tp + Vector3(0, 6.5, 0), stone.lightened(0.04), Vector3.ZERO, 12)
			d.cyl(4.0, 3.0, tp + Vector3(0, 14.5, 0), Color("7a4030"), Vector3.ZERO, 12, 0.1)     # konik ahşap çatı
	# Köy: hisarın doğusunda, Göksu kıyısında birkaç ev (kiremit çatı)
	for i in 14:
		var x := ANADOLU.x + 40.0 + (i % 7) * 13.0 + rng.randf_range(-3.0, 3.0)
		var z := ANADOLU.z - 2.0 + float(i / 7) * 14.0 + rng.randf_range(-2.0, 2.0)
		var y := asia_y(x, z)
		var w := rng.randf_range(5.0, 8.0)
		d.box(Vector3(w, 4.5, 6.0), Vector3(x, y + 2.25, z), Color("d8cbb0").darkened(rng.randf() * 0.15))
		d.prism(Vector3(w + 0.6, 2.2, 6.6), Vector3(x, y + 5.6, z), Color("9a4a32"))
	# Kıyıda birkaç kayık
	for i in 5:
		d.box(Vector3(1.6, 0.6, 5.0), Vector3(ANADOLU.x + 20.0 + i * 9.0, 0.2, ASIA_Z - 6.0 + (i % 2) * 2.0), Color("5a3e26"), Vector3(0, 80.0 + i * 7.0, 0))
	d.build(self)
	# Rumeli yakası: yamaçta çadırlar (inşaat ordugâhı) ve ağaçlar
	var hf := func(x: float, z: float) -> float:
		return ground_y(x, z)
	Scenery.camp(self, Vector3(0, 0, -150), 60.0, 120.0, 90, [Rect2(-60.0, -100.0, 120.0, 90.0)], hf, 3301)
	Scenery.trees(self, Vector3(0, 0, -160), 40.0, 200.0, 80, [Rect2(-90.0, -110.0, 180.0, 100.0)], hf, 3302)


## İki nokta arasında ip (silindir); her karede yeniden konumlanabilir
static func rope(node: MeshInstance3D, a: Vector3, b: Vector3) -> void:
	var mid := (a + b) * 0.5
	node.global_position = mid
	var d := b - a
	var l := d.length()
	if l < 0.01:
		return
	var up := d / l
	var side := up.cross(Vector3.FORWARD if absf(up.dot(Vector3.FORWARD)) < 0.95 else Vector3.RIGHT).normalized()
	node.global_basis = Basis(side, up, side.cross(up)).scaled(Vector3(1.0, l, 1.0))


static func make_rope(parent: Node3D, color := Color("b89a6a"), r := 0.025) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = r
	cm.bottom_radius = r
	cm.height = 1.0
	cm.radial_segments = 5
	m.mesh = cm
	m.material_override = Props.mat(color, 0.0, false, "", false)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(m)
	return m
