extends Node3D
## Bölüm 17 (Osmanlı tarafı) — Kundak (Tolga · 28 Nisan 1453 gecesi, Haliç'in kuzey kıyısı, kıyı topları).
##
## Aynı gece, öbür kıyıdan: donanma Pınarlar Vadisi'nde demirli; kıyıda toplar. Galata'da bir ışık yanar
## (tespit karesi; kaynaklar kimin yaktığını tartışır). Tolga topçuların yanındadır: karanlıkta yaklaşan gemileri
## görür (bak ve E), topu doldurur ve nişan alır (GunDrill). Coco'nun fustası batar (tarih). Bir ateş çömleği demirli
## bir kadırgaya düşer: kova zinciriyle yangın söndürülür.
##   17O.1 Yangın çabuk söndü · 17O.2 Kadırganın kıçı yandı, ama gemi kurtuldu
##   --autotest[=slow]   (varsayılan: 17O.1)

const WATER_Y := -0.35   # dalga tepesi (0.35) kıyı seviyesini (0) aşmasın
const GUN := Vector3(0.0, 0.0, -1.0)
const GALATA_LIGHT := Vector3(-70.0, 38.0, 30.0)
const GALATA_C := Vector2(-82.0, 42.0)   # Galata tepesinin merkezi (Haliç'e uzanan burun)
const WALK := Rect2(-40.0, -38.0, 100.0, 38.7)   # oyuncunun dolaşabildiği kıyı alanı (x, z)
const FIRE_GALLEY := Vector3(18.0, 0.0, 7.0)
const BUCKETS := Vector3(11.0, 0.0, -0.6)
const FIRE_TIME := 40.0

var player: Player
var hud: Hud
var topcu: Soldier
var crew: Array[Soldier] = []
var drill: GunDrill
var gun_root: Node3D
var gun_pivot: Node3D
var gun_muzzle: Node3D
var gun_crew: CannonCrew
var cam: TespitCam
var lantern: Node3D
var _lantern_light: OmniLight3D
var coco_boat: Node3D
var ships: Array[Node3D] = []
var fire_nodes: Array[Node3D] = []
var _fire_light: OmniLight3D
var _smoke: Node3D
var phase := "intro"
var _outcome := ""
var _photo := ""
var _acc := 0.0
var _last_acc := 0.0
var _spotted := false
var _water := 0
var _carry: Node3D
var carrying := false
var _fire_t := 0.0
var _t := 0.0
var _approach := 0.0


func _ready() -> void:
	if GameState.current_chapter != 17:
		GameState.snapshot(17)
	GameState.flags["siege_side"] = "O"
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	drill = GunDrill.new()
	hud.add_child(drill)
	drill.fired.connect(_on_fired)
	_build()
	_setup_gun_crew()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	Night.environment(self, 0.008)
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(500, 400)
	pm.subdivide_width = 100
	pm.subdivide_depth = 80
	w.mesh = pm
	var sh := ShaderMaterial.new()
	sh.shader = load("res://assets/shaders/water.gdshader")
	w.material_override = sh
	w.position = Vector3(0, WATER_Y, 201.5)   # su kıyıdan (z 0) 1.5 m açıkta başlar: bataryaya taşmasın
	add_child(w)
	# Kıyı: kum, iskele, kıyı bataryası (toprak siper, üç top)
	# Kara: yürünen düz alan (bataryanın çevresi) + arkada ve yanlarda yükselen vadi yamaçları (Pınarlar Vadisi)
	var ground := Props.solid(self, Vector3(200, 1.0, 61), Vector3(0, -0.5, -29.5), Color.WHITE)
	ground.get_child(0).visible = false
	var noise := FastNoiseLite.new()
	noise.seed = 1704
	noise.frequency = 0.04
	var lf := func(x: float, z: float) -> float:
		var dx := maxf(0.0, WALK.position.x - x) + maxf(0.0, x - WALK.end.x)
		var dz := maxf(0.0, WALK.position.y - z)
		var r := sqrt(dx * dx + dz * dz)
		var h := pow(r, 1.15) * 0.2 * clampf(-z / 25.0, 0.15, 1.0) + noise.get_noise_2d(x, z) * minf(r * 0.1, 2.5)
		if z > 1.0:
			h = lerpf(h, -2.5, clampf((z - 1.0) / 5.0, 0.0, 1.0))
		return h
	var lcf := func(x: float, z: float, y: float, steep: float) -> Color:
		if y < 0.4 and z > -40.0:
			return Color("5a4a36").lerp(Color("4a3e2e"), noise.get_noise_2d(x * 3.0, z * 3.0) * 0.5 + 0.5)
		return Color("26301f").lerp(Color("3a4228"), clampf(noise.get_noise_2d(x * 2.0, z * 2.0) * 0.5 + 0.5, 0.0, 1.0))
	add_child(LowPoly.terrain(-170.0, 200.0, -190.0, 8.0, 74, 50, lf, lcf))
	Props.box(self, Vector3(WALK.size.x + 60.0, 0.6, 3.0), Vector3(WALK.get_center().x + 25.0, -0.42, 1.2), Color("3e362c"), Vector3(-10, 0, 0))
	# Toprak siper (katı): topların önünde
	Props.set_pattern(Props.solid(self, Vector3(12.0, 1.1, 1.6), GUN + Vector3(0, 0.55, 1.8), Color.WHITE), Color("6a5a40"), "rubble")
	for i in 3:
		var gx := -4.0 + i * 4.0
		var g := Node3D.new()
		g.position = GUN + Vector3(gx, 0, 0)
		add_child(g)
		Props.box(g, Vector3(1.4, 0.5, 2.6), Vector3(0, 0.3, 0), Color("5a3e26"))
		for sx: float in [-0.75, 0.75]:
			Props.cyl(g, 0.45, 0.14, Vector3(sx, 0.45, 0.6), Color("3a2a1c"), Vector3(0, 0, 90), 10)
		# Namlu muylu ekseninde döner (nişan): pivot çocukları
		var pv := Node3D.new()
		pv.name = "Pivot"
		pv.position = Vector3(0, 0.85, 0.2)
		pv.rotation.x = deg_to_rad(-9)
		g.add_child(pv)
		Props.cyl(pv, 0.34, 2.6, Vector3(0, 0, 0.45), Color("7a5a2a"), Vector3(90, 0, 0), 12)
		Props.cyl(pv, 0.42, 0.3, Vector3(0, 0, 1.62), Color("6a4a20"), Vector3(90, 0, 0), 12)
		Props.cyl(pv, 0.3, 0.2, Vector3(0, 0, -0.9), Color("6a4a20"), Vector3(90, 0, 0), 12)
		Props.cyl(pv, 0.2, 0.04, Vector3(0, 0, 1.78), Color("15120f"), Vector3(90, 0, 0), 12)
		if i == 1:
			gun_root = g
			gun_pivot = pv
			gun_muzzle = Node3D.new()
			gun_muzzle.position = Vector3(0, 0, 1.8)
			gun_muzzle.basis = Basis.looking_at(Vector3(0, 0, 1))
			pv.add_child(gun_muzzle)
	Props.interactable(self, "gun", Vector3(1.8, 1.6, 2.8), GUN + Vector3(0, 0.8, 0.2))
	# Barut fıçıları, gülleler
	for i in 3:
		Props.cyl(self, 0.3, 0.7, GUN + Vector3(-7.0 + i * 0.7, 0.35, -1.8), Color("2e2a26"), Vector3.ZERO, 10)
	for i in 6:
		Props.ball(self, 0.22, GUN + Vector3(6.5 + (i % 3) * 0.46, 0.22 + (i / 3) * 0.38, -1.6), Color("4e4c4a"), Vector3.ONE, 8)
	for x: float in [-8.0, 8.0]:
		Night.torch(self, GUN + Vector3(x, 0, -0.6), 2.2)
	topcu = Soldier.new(Color("b3262d"), "stand", "bork")
	topcu.position = GUN + Vector3(-2.2, 0, -1.4)
	add_child(topcu)
	# Öbür iki topun başındaki topçular (orta top oyuncunun; yol açık)
	for i in 4:
		var s := Soldier.new([Color("2f5fa8"), Color("6a4a3a"), Color("8a6a4a"), Color("2f5fa8")][i], "stand", "bork" if i % 2 == 0 else "turban")
		s.position = GUN + Vector3([-4.9, -3.1, 3.1, 4.9][i], 0, -0.2)
		add_child(s)
		crew.append(s)
	_build_valley_camp(lf)
	# Demirli donanma: kıçları kıyıya, başları denize; ateş hattının (sol-ön) dışında, sağda sıra sıra
	var rng := RandomNumberGenerator.new()
	rng.seed = 1704
	var fg := _galley(FIRE_GALLEY, deg_to_rad(88))
	fg.name = "FireGalley"
	for i in 9:
		var p := Vector3(30.0 + i * 8.5, 0, 11.0 + rng.randf_range(-0.8, 0.8))
		_galley(p, PI + deg_to_rad(rng.randf_range(-5, 5)))
	for i in 7:
		var p := Vector3(55.0 + i * 13.0, 0, 34.0 + rng.randf_range(-4, 4))
		_galley(p, PI + deg_to_rad(rng.randf_range(-20, 20)))
	# Kova yığını (su kıyısında)
	for i in 5:
		Props.cyl(self, 0.18, 0.3, BUCKETS + Vector3(-0.6 + (i % 3) * 0.4, 0.15, (i / 3) * 0.4), Color("8a6440"), Vector3.ZERO, 8, 0.22)
	Props.interactable(self, "buckets", Vector3(1.8, 1.2, 1.6), BUCKETS + Vector3(0, 0.6, 0))
	# İskele: kıyıdan yanan kadırganın borda iskelesine
	Props.set_pattern(Props.solid(self, Vector3(2.2, 0.3, 5.0), Vector3(FIRE_GALLEY.x, 0.35, 2.0), Color.WHITE), Color("8a6440"), "wood")
	for sx: float in [-1.0, 1.0]:
		for z: float in [0.5, 2.5, 4.3]:
			Props.cyl(self, 0.1, 1.6, Vector3(FIRE_GALLEY.x + sx, -0.3, z), Color("4a3422"), Vector3.ZERO, 6)
	Props.interactable(self, "galley_fire", Vector3(3.0, 2.4, 2.0), FIRE_GALLEY + Vector3(0, 1.2, -2.4))
	# Karşı kıyı: şehir surları (uzakta)
	Scenery.city_walls(self, 180.0, 260.0, 1.0, 1453)
	# Galata: Pınarlar Vadisi'yle aynı kıyıda, Haliç'e doğru uzanan tepe; üstünde Ceneviz kasabası ve kule
	var hf := func(x: float, z: float) -> float:
		var e := pow((x - GALATA_C.x) / 48.0, 2.0) + pow((z - GALATA_C.y) / 38.0, 2.0)
		return 17.0 * exp(-e) - 3.0
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		return Color("1e2418").lerp(Color("2c2a22"), clampf(y / 14.0, 0.0, 1.0))
	add_child(LowPoly.terrain(-175.0, 5.0, -20.0, 110.0, 48, 34, hf, cf))
	GalataView.build(self, hf, Vector2(GALATA_LIGHT.x, GALATA_LIGHT.z), GALATA_LIGHT.y, GALATA_C, 36.0, WATER_Y + 0.35)
	# Kıyı sınırı: sudan düşülmesin (iskele girişi açık), kara kenarları, iskelenin yanları ve ucu
	for seg in [[WALK.position.x, FIRE_GALLEY.x - 1.15], [FIRE_GALLEY.x + 1.15, WALK.end.x]]:
		var bw: float = seg[1] - seg[0]
		_barrier(Vector3(bw, 4.0, 0.4), Vector3(seg[0] + bw * 0.5, 2.0, 0.7))
	for sx: float in [-1.15, 1.15]:
		_barrier(Vector3(0.2, 4.0, 5.0), Vector3(FIRE_GALLEY.x + sx, 2.0, 2.0))
	_barrier(Vector3(2.4, 4.0, 0.2), Vector3(FIRE_GALLEY.x, 2.0, 4.6))
	for sx: float in [WALK.position.x, WALK.end.x]:
		_barrier(Vector3(0.4, 6.0, WALK.size.y + 1.0), Vector3(sx, 3.0, WALK.position.y + WALK.size.y * 0.5))
	_barrier(Vector3(WALK.size.x, 6.0, 0.4), Vector3(WALK.get_center().x, 3.0, WALK.position.y))
	lantern = Node3D.new()
	lantern.position = GALATA_LIGHT
	lantern.visible = false
	add_child(lantern)
	var lm := Props.ball(lantern, 0.8, Vector3.ZERO, Color("ffd070"), Vector3.ONE, 6, 4.0)
	lm.material_override = Props.mat(Color("ffd070"), 5.0, false, "", false)
	_lantern_light = OmniLight3D.new()
	_lantern_light.light_color = Color("ffc060")
	_lantern_light.light_energy = 6.0
	_lantern_light.omni_range = 40.0
	lantern.add_child(_lantern_light)
	# Yaklaşan Venedik gemileri (karanlık, fenersiz)
	coco_boat = _enemy(Vector3(30.0, 0, 120.0), 9.0)
	for i in 2:
		ships.append(_enemy(Vector3(24.0 + i * 16.0, 0, 140.0), 16.0))


## Pınarlar Vadisi'nde donanma ordugâhı (gece): yürünen alanın kenarında çadırlar, ateş başında oturan askerler,
## bağlı atlar, arabalar, erzak; yamaçlarda yüzlerce çadır ve ateş, servi ve çınarlar. Hiçbir yön boş kalmaz.
func _build_valley_camp(lf: Callable) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var colors := [Color("d8cbb0"), Color("c8b894"), Color("e0d4b8"), Color("b8a888")]
	var bands := [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a"), Color("c98a3a")]
	# Yakın çadırlar (alanın arka ve yan kenarı)
	var near_tents := [Vector3(-33, 0, -33), Vector3(-21, 0, -35), Vector3(-8, 0, -34.5), Vector3(6, 0, -35), Vector3(20, 0, -33.5),
		Vector3(34, 0, -34), Vector3(48, 0, -32), Vector3(55, 0, -21), Vector3(-36, 0, -20), Vector3(56, 0, -9), Vector3(-36, 0, -8)]
	for i in near_tents.size():
		var t := Night.tent(self, near_tents[i], rng.randf_range(1.8, 2.6), colors[i % 4], bands[i % 4])
		t.rotation.y = rng.randf() * TAU
	# Ateş başları: oturan askerler, kazan
	for fp: Vector3 in [Vector3(-22, 0, -24), Vector3(14, 0, -26), Vector3(42, 0, -18), Vector3(-28, 0, -10)]:
		Night.campfire(self, fp, 1.0)
		for k in 4:
			var a := TAU * k / 4.0 + rng.randf_range(-0.3, 0.3)
			var sp := Person.new({"coat": [Color("b3262d"), Color("6a4a3a"), Color("2f5fa8"), Color("3a6b3a")][k], "pants": Color("e8e0d0"),
				"hat": "bork" if k % 2 == 0 else "turban", "mustache": true, "beard": k == 1, "skin": Color("d9a07a")})
			sp.set_meta("no_talk", true)
			sp.position = fp + Vector3(cos(a), 0, sin(a)) * 1.5
			sp.rotation.y = atan2(-cos(a), -sin(a))
			add_child(sp)
			sp.set_activity("sit_ground")
	# Kenar donatısı: atlar, arabalar, çuvallar, fıçılar, mızrak sehpaları, sandıklar (toplu çizim)
	var dd := Dressing.new(1704)
	var spots := [[Vector3(-30, 0, -28), "_c_horses"], [Vector3(26, 0, -28), "_c_horses"], [Vector3(-12, 0, -29), "_c_armory"],
		[Vector3(4, 0, -28), "_c_barrel_pile"], [Vector3(38, 0, -26), "_c_table"], [Vector3(50, 0, -14), "_c_sacks"],
		[Vector3(-34, 0, -14), "_c_crates"], [Vector3(52, 0, -2), "_c_barrels"], [Vector3(-16, 0, -18), "_c_spears"],
		[Vector3(28, 0, -12), "_c_crates"], [Vector3(-34, 0, -1), "_c_firewood"], [Vector3(24, 0, -20), "_c_cart"]]
	for sp in spots:
		dd.at(sp[0], rng.randf() * TAU)
		dd.call(sp[1])
	# Bataryayla ordugâh arası: cephane yığınları, barut çadırı, at sırası, arabalar (topçu yolları açık kalır)
	var mid := [[Vector3(-26, 0, -12), "_c_barrel_pile"], [Vector3(-18, 0, -13), "_c_crates"], [Vector3(-10, 0, -16), "_c_sacks"],
		[Vector3(8, 0, -15), "_c_barrels"], [Vector3(16, 0, -13), "_c_crates"], [Vector3(34, 0, -6), "_c_cart"],
		[Vector3(40, 0, -26), "_c_horses"], [Vector3(46, 0, -28), "_c_horses"], [Vector3(-4, 0, -24), "_c_hay"],
		[Vector3(-30, 0, -22), "_c_spears"], [Vector3(30, 0, -20), "_c_firewood"], [Vector3(-40, 0, -30), "_c_barrels"]]
	for sp in mid:
		dd.at(sp[0], rng.randf() * TAU)
		dd.call(sp[1])
	dd.build(self)
	# İkinci sıra çadırlar (öbekler, arada geçit)
	for tp: Vector3 in [Vector3(-28, 0, -26), Vector3(-14, 0, -22), Vector3(2, 0, -21), Vector3(18, 0, -23), Vector3(32, 0, -27),
			Vector3(-6, 0, -30), Vector3(44, 0, -10)]:
		var t := Night.tent(self, tp, rng.randf_range(1.6, 2.2), colors[rng.randi() % 4], bands[rng.randi() % 4])
		t.rotation.y = rng.randf() * TAU
	# Güllelerin piramidi ve barut deposu (topların arkasında, yolun kenarında)
	for k in 10:
		var lay := 0 if k < 6 else (1 if k < 9 else 2)
		var idx := k if lay == 0 else (k - 6 if lay == 1 else 0)
		Props.ball(self, 0.22, GUN + Vector3(10.0 + (idx % 3) * 0.44 + lay * 0.22, 0.22 + lay * 0.36, -3.2 + (idx / 3) * 0.44 + lay * 0.22), Color("4e4c4a"), Vector3.ONE, 8)
	# Dolaşan askerler: nöbet, su taşıyan, sohbet eden
	var nodes: Array[Vector3] = []
	for k in 24:
		nodes.append(Vector3(rng.randf_range(WALK.position.x + 3.0, WALK.end.x - 3.0), 0.0, rng.randf_range(-32.0, -8.0)))
	for k in 7:
		var w := Person.new({"coat": [Color("b3262d"), Color("2f5fa8"), Color("6a4a3a"), Color("3a6b3a")][k % 4], "pants": Color("e8e0d0"),
			"hat": "bork" if k % 2 == 0 else "turban", "mustache": true, "skin": Color("d9a07a")})
		w.set_meta("no_talk", true)
		w.position = nodes[k * 3]
		add_child(w)
		var wk := Walker.new()
		wk.person = w
		wk.nodes = nodes
		wk.seed_value = 40 + k
		wk.space_owner = self
		add_child(wk)
	# Yamaçlar: yüzlerce çadır ve ateş, ağaçlar (deniz ve Galata tarafı hariç)
	var avoid := [Rect2(WALK.position.x - 4.0, WALK.position.y - 4.0, WALK.size.x + 8.0, WALK.size.y + 10.0),
		Rect2(-400.0, -2.0, 800.0, 400.0), Rect2(-180.0, -30.0, 120.0, 200.0)]
	Scenery.camp(self, Vector3(10, 0, -40), 30.0, 150.0, 320, avoid, lf, 1705, true)
	Scenery.trees(self, Vector3(10, 0, -40), 25.0, 170.0, 140, avoid, lf, 1706)
	var glow := Props.mat(Color("ffb050"), 4.0, false, "", false)
	var fires: Array = []
	for i in 120:
		var a := rng.randf() * TAU
		var r := rng.randf_range(35.0, 160.0)
		var p := Vector3(10.0 + sin(a) * r, 0, -40.0 + cos(a) * r)
		if Scenery._blocked(p, avoid):
			continue
		p.y = lf.call(p.x, p.z) + 0.3
		fires.append(Scenery._t(p, Vector3.ZERO, Vector3.ONE * rng.randf_range(0.8, 1.6)))
	var fm := Scenery._ball(0.35)
	fm.material = glow
	Scenery.scatter(self, fm, fires, []).material_override = glow


## Orta top: elle doldurma, nişan, balistik atış (CannonCrew). Malzeme yerleri bataryanın arkasında.
func _setup_gun_crew() -> void:
	gun_crew = CannonCrew.new()
	add_child(gun_crew)
	gun_crew.player = player
	gun_crew.hud = hud
	gun_crew.pivot = gun_pivot
	gun_crew.muzzle = gun_muzzle
	gun_crew.recoil_node = gun_root
	gun_crew.aim_spot = GUN + Vector3(0, 0, -3.4)
	gun_crew.supplies = {"powder": GUN + Vector3(-6.3, 0, -2.9), "wad": GUN + Vector3(-1.4, 0, -3.6),
		"ball": GUN + Vector3(6.95, 0, -2.7), "rammer": GUN + Vector3(1.9, 0, -3.6)}
	gun_crew.spawn = ["wad"]
	gun_crew.target = func() -> Vector3: return coco_boat.global_position + Vector3(0, 0.8, 0)
	gun_crew.hit_radius = 5.5
	gun_crew.tolerance = 30.0
	gun_crew.ground_y = WATER_Y
	gun_crew.design_elev = 8.0
	gun_crew.pitch_min = -3.0
	gun_crew.pitch_max = 25.0
	gun_crew.yaw_limit = 30.0
	gun_crew.setup()
	drill.bind(gun_crew)


## Görünmez duvar (kıyı ve kara kenarı).
func _barrier(size: Vector3, pos: Vector3) -> void:
	var b := StaticBody3D.new()
	b.position = pos
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	b.add_child(cs)
	add_child(b)


func _galley(p: Vector3, yaw: float) -> Node3D:
	var g := Node3D.new()
	g.position = p + Vector3(0, -0.3, 0)
	g.rotation.y = yaw
	add_child(g)
	g.add_child(LowPoly.hull([
		{"z": -9.0, "w": 0.06, "top": 2.3, "bottom": 1.4},
		{"z": -6.0, "w": 1.3, "top": 1.9, "bottom": 0.3},
		{"z": 0.0, "w": 1.7, "top": 1.85, "bottom": 0.2},
		{"z": 5.0, "w": 1.4, "top": 2.0, "bottom": 0.4},
		{"z": 7.0, "w": 0.8, "top": 2.7, "bottom": 1.0},
	], Color("3a2a1c"), Color("7e2420"), 1.78))
	Props.cyl(g, 0.14, 9.0, Vector3(0, 6.2, -1.5), Color("4a3420"), Vector3.ZERO, 6)
	var f := Props.ball(g, 0.18, Vector3(0, 3.0, 6.5), Color("ffb040"), Vector3.ONE, 5, 3.0)
	f.material_override = Props.mat(Color("ffb040"), 3.0, false, "", false)
	return g


func _enemy(p: Vector3, length: float) -> Node3D:
	var g := Node3D.new()
	g.position = p
	g.rotation.y = PI
	add_child(g)
	var h := length * 0.5
	g.add_child(LowPoly.hull([
		{"z": -h - 0.6, "w": 0.06, "top": 1.7, "bottom": 0.9},
		{"z": 0.0, "w": length * 0.14, "top": 1.3, "bottom": -0.35},
		{"z": h + 0.4, "w": length * 0.07, "top": 1.8, "bottom": 0.5},
	], Color("2a2018"), Color("2a3a5a"), 1.15))
	Props.cyl(g, 0.12, length * 0.7, Vector3(0, length * 0.35 + 1.0, 0), Color("3a2a1c"), Vector3.ZERO, 6)
	return g


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH17O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH17O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = GUN + Vector3(1.6, 0.05, -2.6)
	player.face(topcu.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_TOPCU", "D17O_A_01")
	await hud.say("SPK_TOLGA", "D17O_T_01")
	await hud.say("SPK_TOPCU", "D17O_A_02")
	# Galata'da ışık: tespit
	lantern.visible = true
	Audio.sfx("radio_beep", -10.0)
	await hud.say("SPK_TOPCU", "D17O_A_LIGHT")
	hud.bark("SPK_NIHAT", "D17_N_RADIO_LIGHT", 5.0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ17_LIGHT"), GALATA_LIGHT)
	cam = TespitCam.new(player, hud, lantern, "siege17")
	hud.add_child(cam)
	cam.max_dist = 260.0
	cam.cone_deg = 8.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 22.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	lantern.visible = false
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D17_T_SHOT" if cam.done else "D17O_T_MISSED")
	# Gözcülük: karanlıkta yaklaşan gemiyi gör
	phase = "watch"
	hud.set_objective(tr("UI_OBJ17O_WATCH"))
	await hud.say("SPK_TOPCU", "D17O_A_WATCH")
	if GameState.autotest:
		_spot()
	while not _spotted:
		await get_tree().process_frame
		if Input.is_action_just_pressed("interact") and _looking_at(coco_boat.global_position + Vector3(0, 1, 0), 10.0):
			_spot()
	hud.set_objective("")
	# Top: iki atış
	player.frozen = true
	player.global_position = GUN + Vector3(0.0, 0.05, -2.3)
	player.face(coco_boat.global_position + Vector3(0, 1.0, 0))
	for shot in 2:
		phase = "drill"
		await hud.say("SPK_TOPCU", "D17O_A_LOAD_%d" % (shot + 1))
		hud.set_objective(tr("UI_OBJ17O_GUN"))
		drill.start(0.3 + shot * 0.15, 0.2)
		while drill.active:
			await get_tree().process_frame
		hud.set_objective("")
		await _shot(shot)
	await _fire_step()
	await _dawn()
	await _end_chapter()


func _looking_at(p: Vector3, cone: float) -> bool:
	var cam3 := player.camera
	var to := p - cam3.global_position
	return rad_to_deg((-cam3.global_transform.basis.z).angle_to(to.normalized())) < cone


func _spot() -> void:
	if _spotted:
		return
	_spotted = true
	Audio.sfx("church_bell", -8.0, 1.8)
	hud.bark("SPK_TOLGA", "D17O_T_SPOT", 3.0)
	for s in crew:
		s.look_target = coco_boat


func _on_fired(acc: float) -> void:
	_acc = maxf(_acc, acc)
	_last_acc = acc


func _shot(n: int) -> void:
	# Elle atışta (CannonCrew) alev, duman, geri tepme ve güllenin düştüğü yer zaten gösterildi
	if not drill.physical:
		Audio.sfx("cannon", 0.0)
		Vfx.explosion(self, GUN + Vector3(0, 1.0, 2.6), 0.7)
		player.shake(0.6)
		await get_tree().create_timer(1.0).timeout
	var hitp := coco_boat.global_position
	if n == 0:
		if not drill.physical:
			Vfx.explosion(self, hitp + Vector3(randf_range(-6, 6), 0.3, randf_range(-6, 6)), 0.5)
			Audio.sfx("splash", -2.0)
		await hud.say("SPK_TOPCU", "D17O_A_NEAR" if _last_acc >= 0.5 else "D17O_A_MISS")
		return
	if drill.physical and _last_acc < 0.6:
		# Iskaladık: yandaki top ateşler ve Coco'nun fustasını o vurur
		await get_tree().create_timer(0.6).timeout
		Audio.sfx("cannon", -2.0, 0.9)
		Vfx.explosion(self, GUN + Vector3(4.0, 1.3, 2.4), 0.8)
		await get_tree().create_timer(1.3).timeout
	# İkinci atış: Coco'nun fustası vurulur (tarih). Kimin topuyla olduğunu isabet belirler.
	Vfx.explosion(self, hitp + Vector3(0, 0.6, 0), 1.2)
	Audio.sfx("explosion_big", -2.0)
	var fire := OmniLight3D.new()
	fire.light_color = Color("ff8a3a")
	fire.light_energy = 5.0
	fire.omni_range = 20.0
	fire.position = Vector3(0, 2.0, 0)
	coco_boat.add_child(fire)
	var tw := create_tween().set_parallel()
	tw.tween_property(coco_boat, "rotation:x", deg_to_rad(-20), 5.0)
	tw.tween_property(coco_boat, "position:y", -3.0, 7.0)
	tw.tween_property(fire, "light_energy", 0.0, 7.0)
	GameState.flags["siege_gun_hit"] = _last_acc >= 0.6
	await hud.say("SPK_TOPCU", "D17O_A_HIT_YOU" if _last_acc >= 0.6 else "D17O_A_HIT_OTHER")
	await hud.say("SPK_TOLGA", "D17O_T_HIT")


func _fire_step() -> void:
	# Ateş çömleği demirli bir kadırgaya düşer
	var g := get_node_or_null("FireGalley") as Node3D
	var fp := FIRE_GALLEY + Vector3(0, 2.0, 0)
	Vfx.explosion(self, fp, 0.8)
	Audio.sfx("explosion_small", -2.0)
	_fire_light = OmniLight3D.new()
	_fire_light.position = fp + Vector3(0, 1.0, 0)
	_fire_light.light_color = Color("ff8a3a")
	_fire_light.light_energy = 6.0
	_fire_light.omni_range = 18.0
	add_child(_fire_light)
	for i in 6:
		var f := Props.cyl(self, 0.35, 1.4, fp + Vector3(randf_range(-1.5, 1.5), 0.2, randf_range(-3, 3)), Color("ffa030"), Vector3.ZERO, 6, 0.05, 3.0)
		f.material_override = Props.mat(Color("ff8a20"), 1.8, false, "", false)
		fire_nodes.append(f)
	# Duman ve kıvılcım sütunu (yangın söndükçe azalır)
	_smoke = Vfx.smolder(self, fp + Vector3(0, 0.5, 0), 1.4, true)
	await hud.say("SPK_TOPCU", "D17O_A_FIRE")
	player.frozen = false
	phase = "fire"
	_fire_t = FIRE_TIME
	_pours = 0.0
	_start_brigade()
	_update_fire_objective()
	if GameState.autotest:
		var n := 1 if GameState.autotest_variant == "slow" else 4
		for i in n:
			_on_interact("buckets")
			_on_interact("galley_fire")
		if GameState.autotest_variant == "slow":
			_fire_t = 0.01
		else:
			_pours = POUR_GOAL
	while phase == "fire":
		await get_tree().process_frame
	_stop_brigade()
	hud.set_chase("", 0.0)
	hud.set_objective("")
	hud.set_prompt("")
	player.frozen = true
	if carrying:
		_drop()


func _update_fire_objective() -> void:
	var done := mini(int(round(_pours)), POUR_GOAL)
	if carrying:
		hud.set_objective(tr("UI_OBJ17O_POUR") % [done, POUR_GOAL], FIRE_GALLEY + Vector3(0, 1.4, -2.6))
	else:
		hud.set_objective(tr("UI_OBJ17O_BUCKET") % [done, POUR_GOAL], BUCKETS + Vector3(0, 1.0, 0))


# ---------------------------------------------------------------- kova zinciri
## Yangında bütün askerler katılır: biri denizden kovayı doldurur, kova elden ele iskeleye geçer, sondaki asker
## suyu alevlere savurur (su yayı, buhar). Askerlerin her kovası yangını biraz söndürür; oyuncu kendi kovalarıyla
## yetişirse vaktinde söner.
const POUR_GOAL := 10
const CHAIN_PTS := [Vector3(12.2, 0.0, 0.35), Vector3(13.6, 0.0, -0.15), Vector3(15.0, 0.0, -0.45), Vector3(16.4, 0.0, -0.6),
	Vector3(17.15, 0.5, 0.7), Vector3(18.85, 0.5, 1.8), Vector3(17.15, 0.5, 2.9), Vector3(18.85, 0.5, 4.0)]
const NPC_POUR := 0.28          # bir asker kovası: yangının ~%3'ü
var _pours := 0.0
var _chain: Array[Soldier] = []
var _chain_t := 0.0
var _brigade_on := false


func _start_brigade() -> void:
	_brigade_on = true
	_chain_t = 1.8
	var coats := [Color("2f5fa8"), Color("6a4a3a"), Color("8a6a4a"), Color("b3262d"), Color("3a6b3a")]
	for i in CHAIN_PTS.size():
		var s := Soldier.new(coats[i % coats.size()], "stand", "bork" if i % 2 == 0 else "turban")
		# Bataryadan ve ordugâhtan koşarak gelirler
		s.position = GUN + Vector3(-6.0 + i * 1.7, 0, -6.0 - (i % 3) * 1.5)
		add_child(s)
		s.rig.activity = "carry"
		_chain.append(s)
		var to: Vector3 = CHAIN_PTS[i]
		var mid := Vector3(to.x, 0.0, minf(to.z, -0.4))
		s.rotation.y = atan2(mid.x - s.position.x, mid.z - s.position.z)
		var d := s.position.distance_to(mid)
		var tw := create_tween()
		tw.tween_property(s, "position", mid, d / 4.5 if not GameState.autotest else 0.05)
		tw.tween_callback(func(): s.rotation.y = atan2(to.x - mid.x, to.z - mid.z))
		tw.tween_property(s, "position", to, 0.4 if not GameState.autotest else 0.05)
		tw.tween_callback(func(): s.look_target = fire_nodes[0] if not fire_nodes.is_empty() else null)
	# Topçubaşı da bağırarak yönetir
	topcu.look_target = _chain[0]


func _stop_brigade() -> void:
	_brigade_on = false
	for s in _chain:
		if is_instance_valid(s):
			s.rig.activity = ""
			s.look_target = null


func _brigade_tick(delta: float) -> void:
	if not _brigade_on:
		return
	_chain_t -= delta
	if _chain_t > 0.0:
		return
	_chain_t = 1.5
	# İlk asker kovayı denizden doldurur, kova elden ele geçer
	var b := Node3D.new()
	add_child(b)
	Props.cyl(b, 0.2, 0.34, Vector3.ZERO, Color("8a6440"), Vector3.ZERO, 8, 0.24)
	Props.cyl(b, 0.2, 0.02, Vector3(0, 0.15, 0), Color("4a78a8"), Vector3.ZERO, 8)
	b.position = (CHAIN_PTS[0] as Vector3) + Vector3(0, 0.3, 0.9)
	Audio.sfx("splash", -20.0, 1.3)
	var tw := create_tween()
	tw.tween_property(b, "position", (CHAIN_PTS[0] as Vector3) + Vector3(0, 1.05, 0.3), 0.35)
	for i in range(1, CHAIN_PTS.size()):
		tw.tween_property(b, "position", (CHAIN_PTS[i] as Vector3) + Vector3(0, 1.05, 0.3), 0.26).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func(): _npc_throw(b))


func _npc_throw(b: Node3D) -> void:
	if not _brigade_on or fire_nodes.is_empty():
		b.queue_free()
		return
	var last: Soldier = _chain[_chain.size() - 1]
	var tw := create_tween()
	tw.tween_property(last, "rotation:x", -0.25, 0.15)
	tw.tween_property(last, "rotation:x", 0.0, 0.3)
	var aim := FIRE_GALLEY + Vector3(randf_range(-2.5, 2.5), 2.0, randf_range(-0.8, 0.6))
	_water_arc(b.global_position + Vector3(0, 0.2, 0), aim)
	b.queue_free()
	await get_tree().create_timer(0.45).timeout
	_extinguish(NPC_POUR, aim)


## Su yayı: kovadan savrulan damlalar parabolle ateşe düşer.
func _water_arc(from: Vector3, to: Vector3) -> void:
	var drop_m := Props.mat(Color("8ec8f0"), 0.4, false, "", false)
	for k in 7:
		var d := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = randf_range(0.07, 0.13)
		sm.height = sm.radius * 2.0
		sm.radial_segments = 6
		sm.rings = 3
		d.mesh = sm
		d.material_override = drop_m
		d.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(d)
		d.global_position = from
		var end := to + Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))
		var peak := (from + end) * 0.5 + Vector3(0, 1.2, 0)
		var tw := create_tween()
		tw.tween_method(func(t: float): d.global_position = from.lerp(peak, t).lerp(peak.lerp(end, t), t), 0.0, 1.0, 0.45 + k * 0.03)
		tw.tween_callback(d.queue_free)


## Yangın biraz söner: buhar, ses; her tam birimde bir alev kaybolur, ışık azalır.
func _extinguish(amount: float, at: Vector3) -> void:
	var before := int(_pours)
	_pours += amount
	Vfx.steam(self, at)
	Audio.sfx("splash", -8.0, randf_range(0.8, 1.1))
	if int(_pours) > before:
		var remove := int(_pours) - before
		for i in remove:
			if fire_nodes.size() > int(float(POUR_GOAL - int(_pours)) * 0.6) and not fire_nodes.is_empty():
				var f: Node3D = fire_nodes.pop_back()
				f.queue_free()
		if _fire_light:
			_fire_light.light_energy = 6.0 * clampf(1.0 - _pours / POUR_GOAL, 0.0, 1.0)
		if _smoke:
			_smoke.scale = Vector3.ONE * clampf(1.0 - _pours / POUR_GOAL, 0.25, 1.0)
	_update_fire_objective()


func _drop() -> void:
	carrying = false
	if _carry:
		_carry.queue_free()
		_carry = null
	player.speed_mult = 1.0


func _dawn() -> void:
	var quick := _pours >= POUR_GOAL
	for f in fire_nodes:
		f.visible = false
	if _fire_light:
		_fire_light.light_energy = 0.0
	if _smoke and quick:
		_smoke.queue_free()
		_smoke = null
	await hud.say("SPK_TOPCU", "D17O_A_OUT" if quick else "D17O_A_BURNED")
	await hud.fade_to(1.0, 1.0)
	await hud.card([[tr("UI_CH17O_DAWN"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_TOPCU", "D17O_A_DAWN")
	await hud.say("SPK_TOLGA", "D17O_T_END")
	await hud.say("SPK_NIHAT", "D17_N_END")
	_outcome = "17O.1" if quick else "17O.2"
	Siege.record(17, _photo, "SIEGE_NOTE_17O_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	# Düşme kurtarması: bir yerden kayıp haritanın altına düşerse bataryaya dön
	if player and player.global_position.y < -3.0:
		player.global_position = GUN + Vector3(0.0, 0.05, -2.3)
		player.velocity = Vector3.ZERO
	if lantern and lantern.visible:
		_lantern_light.light_energy = 6.0 if fmod(_t, 1.2) < 0.7 else 1.0
	if phase in ["watch", "drill"]:
		_approach = minf(_approach + delta * 0.08, 1.0)
		coco_boat.position = Vector3(30.0, sin(_t) * 0.05, lerpf(120.0, 55.0, _approach))
		for i in ships.size():
			ships[i].position = Vector3(24.0 + i * 16.0, sin(_t + i) * 0.05, lerpf(140.0, 85.0, _approach))
	for f in fire_nodes:
		if f.visible:
			f.scale.y = 1.0 + sin(_t * 9.0 + f.position.x) * 0.25
	if phase == "fire":
		_fire_t -= delta
		hud.set_chase(tr("UI_CH17O_TIME") % maxi(0, int(ceil(_fire_t))), 1.0 - _fire_t / FIRE_TIME)
		_brigade_tick(delta)
		if _fire_t <= 0.0 or _pours >= POUR_GOAL:
			phase = "fire_done"


func _on_focus(id: String) -> void:
	match id:
		"buckets":
			hud.set_prompt(tr("UI_PROMPT17O_BUCKET") if phase == "fire" and not carrying else "")
		"galley_fire":
			hud.set_prompt(tr("UI_PROMPT17O_POUR") if phase == "fire" and carrying else "")
		_:
			hud.set_prompt("")


func _on_interact(id: String) -> void:
	if phase != "fire":
		return
	match id:
		"buckets":
			if carrying:
				return
			carrying = true
			_carry = Node3D.new()
			_carry.position = Vector3(0.3, -0.78, -1.05)
			_carry.scale = Vector3.ONE * 0.6
			player.camera.add_child(_carry)
			Props.cyl(_carry, 0.2, 0.36, Vector3.ZERO, Color("8a6440"), Vector3.ZERO, 8, 0.24)
			Props.cyl(_carry, 0.22, 0.02, Vector3(0, 0.16, 0), Color("4a78a8"), Vector3.ZERO, 8)
			Props.strip_outlines(_carry)
			player.speed_mult = 0.8
			Audio.sfx("splash", -12.0, 1.2)
			_update_fire_objective()
		"galley_fire":
			if not carrying:
				return
			_drop()
			_water += 1
			var aim := FIRE_GALLEY + Vector3(randf_range(-1.5, 1.5), 2.0, -0.4)
			_water_arc(player.camera.global_position + Vector3(0, -0.3, 0) - player.camera.global_basis.z * 0.6, aim)
			Audio.sfx("splash", -2.0, 0.9)
			_extinguish(1.0, aim)
			hud.bark("SPK_TOLGA", "D17O_T_POUR_%d" % mini(_water, 3), 2.2)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(17, _outcome)
	await Siege.show_page(hud, 17)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(17)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW17O_TITLE")
	c.nodes = [
		{"id": "light", "key": "FLOW17_LIGHT", "pos": Vector2(0.5, 0.12)},
		{"id": "gun", "key": "FLOW17O_GUN", "pos": Vector2(0.5, 0.3)},
		{"id": "17O.1", "key": "FLOW_17O_1", "pos": Vector2(0.3, 0.52), "outcome": true},
		{"id": "17O.2", "key": "FLOW_17O_2", "pos": Vector2(0.7, 0.52), "outcome": true},
	]
	c.edges = [["light", "gun"], ["gun", "17O.1"], ["gun", "17O.2"]]
	for k in ["gun", _outcome]:
		c.taken[k] = true
	if cam and cam.done:
		c.taken["light"] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH17O_STATS") % [int(_acc * 100.0), _water, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "17O.1", "slow": "17O.2", "osm": "17O.1"}.get(v, "17O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("17", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and _spotted
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=17o variant=%s outcome=%s acc=%.2f water=%d" % ["PASS" if ok else "FAIL", v, _outcome, _acc, _water])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot_png(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.show_remote(false)
	phase = "drill"
	_approach = 0.6
	player.global_position = GUN + Vector3(0.0, 0.05, -2.3)
	await get_tree().create_timer(0.8).timeout
	player.face(coco_boat.global_position + Vector3(0, 1.0, 0))
	drill.start(0.0, 0.2)
	# Elle doldurma adımları: gülle taşıma, tokmak, nişan, uçuş
	player.global_position = GUN + Vector3(5.5, 0.05, -2.8)
	player.face(gun_muzzle.global_position)
	gun_crew.state = "ball"
	gun_crew._take("ball")
	await _shot_png("c17o_01a_carry.png")
	gun_crew._held.queue_free()
	gun_crew._held = null
	gun_crew.carrying = ""
	gun_crew.state = "ram"
	gun_crew._take("rammer")
	player.global_position = GUN + Vector3(1.3, 0.05, -0.4)
	player.face(gun_muzzle.global_position)
	gun_crew.ram_phase = 0.5
	gun_crew._ram_stroke()
	await get_tree().create_timer(0.1).timeout
	await _shot_png("c17o_01b_ram.png")
	gun_crew._held.queue_free()
	gun_crew._held = null
	gun_crew.carrying = ""
	gun_crew.state = "aim"
	gun_crew._start_aim()
	gun_crew._solve_aim()
	gun_crew._apply_aim()
	await _shot_png("c17o_01c_aim.png")
	gun_crew._fire()
	await get_tree().create_timer(0.75).timeout
	await _shot_png("c17o_01d_fire.png")
	await get_tree().create_timer(1.2).timeout
	await _shot_png("c17o_01e_flight.png")
	while gun_crew.state == "fly":
		await get_tree().process_frame
	await _shot_png("c17o_01f_impact.png")
	drill.stop()
	phase = "fire"
	_fire_step_visual()
	_pours = 0.0
	_fire_t = FIRE_TIME
	_start_brigade()
	player.global_position = FIRE_GALLEY + Vector3(-7.0, 0.05, -5.0)
	player.face(FIRE_GALLEY + Vector3(-2.0, 1.5, 0))
	await get_tree().create_timer(5.2).timeout
	await _shot_png("c17o_02_fire.png")
	await get_tree().create_timer(0.9).timeout
	hud.visible = false
	var cc := Camera3D.new()
	add_child(cc)
	cc.global_position = Vector3(9.0, 3.2, -5.0)
	cc.look_at(Vector3(16.5, 1.0, 2.0), Vector3.UP)
	cc.make_current()
	await _shot_png("c17o_02b_chain.png")
	hud.visible = true
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = GUN + Vector3(-5.0, 3.0, -6.0)
	cv.look_at(GUN + Vector3(4.0, 1.0, 12.0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot_png("c17o_cover.png")
	get_tree().quit()


func _fire_step_visual() -> void:
	var fp := FIRE_GALLEY + Vector3(0, 2.0, 0)
	var l := OmniLight3D.new()
	l.position = fp + Vector3(0, 1.0, 0)
	l.light_color = Color("ff8a3a")
	l.light_energy = 6.0
	l.omni_range = 18.0
	add_child(l)
	_fire_light = l
	for i in 6:
		var f := Props.cyl(self, 0.35, 1.4, fp + Vector3(randf_range(-1.5, 1.5), 0.2, randf_range(-3, 3)), Color("ffa030"), Vector3.ZERO, 6, 0.05, 3.0)
		f.material_override = Props.mat(Color("ff8a20"), 1.8, false, "", false)
		fire_nodes.append(f)
	_smoke = Vfx.smolder(self, fp + Vector3(0, 0.5, 0), 1.4, true)
