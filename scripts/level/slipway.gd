class_name Slipway
extends Node3D
## Bölüm 2 sahnesi: 22 Nisan 1453 sabahı, Galata'nın arkasındaki tepelerden Haliç'e
## inen yağlı kızaklar. Low-poly tepeler, kadırga, askerler ve öküzler, dalgalı Haliç,
## karşı kıyıda tuğla bantlı surlar, kiremit çatılı şehir, Ayasofya (1453'te minaresi
## yoktu), Galata Kulesi, Haliç zinciri, bulutlar ve martılar.
##
## Yokuş "track" düğümünün içinde kuruludur: track'in yerel -Z yönü yokuş aşağıdır.
## s: yokuş boyunca metre (0 = tepe), x: şerit ekseni.

const SLOPE_DEG := 7.0
const LENGTH := 130.0
const WIDTH := 9.0
const LANES := [-2.4, 0.0, 2.4]

const C_TRACK := Color("7a5b3c")
const C_LOG := Color("8a6440")
const C_SAND := Color("dcc58f")
const C_STONE := Color("d8c7a4")
const C_STONE_DARK := Color("a8916c")
const C_BRICK := Color("a4513a")
const C_ROOF := Color("b5533a")

var track: Node3D
var _capstans: Array[Node3D] = []
var ship: Node3D
var boat: Node3D
var water_y := 0.0
var obstacles: Array = []      # [{s, kind: "rope"/"log"/"block", lanes: [..], node, resolved}]
var _water: MeshInstance3D
var _env: Environment
var _fog_air := {}
var _clouds: Array = []          # [{c, puffs: [[örnek, kayma, ölçek]]}]
var _cloud_mm: MultiMeshInstance3D
var _gulls: Array = []          # [{node, center, radius, speed, phase, wings}]
var _noise := FastNoiseLite.new()
var _t := 0.0
var _tan := tan(deg_to_rad(SLOPE_DEG))
## Yüzme alanı (Bölüm 2 serbest yüzme): çarpılabilir yüzen şeyler, kayıp fes, amfora noktası
var swim_debris: Array[Node3D] = []
var fez_float: Node3D
var amphora_spot := Vector3.ZERO
var _fish: Array = []           # [{offs: [[örnek, kayma]], center, radius, speed, phase}]
var _fish_mm: MultiMeshInstance3D
var _shafts: Array[Node3D] = []
var _bubble_cols: Array = []
var _underwater_on := true      # ilk karede balıklar bir kez yerleşsin
var _bob_nodes: Array = []      # [{node, base_y, phase}]
## Tek harita (World1453, bölge "slipway"): kızak Pınarlar Vadisi'nin ağzında Haliç'e iner; karşı şehir, Galata, Haliç,
## zincir ve Osmanlı yakası dünyadan gelir (eskiden sahnenin kendi uydurma karşı kıyısı ve ikinci bir Galata Kulesi vardı)
var in_world := true
var world: SiegeField
var _region := World1453.region("slipway")


func _ready() -> void:
	Audio.voice_space("outdoor")
	_noise.seed = 1453
	_noise.frequency = 0.035
	_noise.fractal_octaves = 3
	_build_sky()
	track = Node3D.new()
	track.rotation_degrees.x = -SLOPE_DEG
	add_child(track)
	water_y = end_point().y - 0.8
	_build_slope()
	_bake_track()
	# Yokuşun iki yanı durağan: birkaç ağ örgüsüne birleşir (Props.bake_static; Bölüm 2'de kare başına ~10 bin çizim
	# çağrısı vardı). Dönen ırgatlar ve askerler birleşmez.
	var first := get_child_count()
	_build_terrain()
	_build_sides()
	Props.bake_static(self, get_children().slice(first))
	_build_ground_detail()
	# İş ekipleri (ırgatın çektiği kütük kızağı, koşumlu öküzler, fren halatları): hareket eder, birleşmez
	process_priority = 50        # askerlerin kendi pozundan sonra: eller halata, ırgat koluna, kadırganın kıçına
	_build_ship()
	_build_crews()
	_build_obstacles()
	_build_bottom()      # deniz dibi birleştirilmez: yüzerek kıyıya çıkma botu takılıyordu (--autotest=swimshore)
	if not in_world:
		_build_far_shore()
	_build_chain_and_boat()
	_build_clouds_and_gulls()
	_build_swim_scenery()
	_build_shore()
	_build_mist()
	if in_world:
		# Oynanış alanı: yokuş, iki yanındaki tepeler (±110 m), tepenin ardı ve yüzme alanı
		world = World1453.build(self, "slipway", [Rect2(-112.0, -LENGTH - 60.0, 224.0, LENGTH + 60.0 + 162.0)], false)
		# Dünyanın ağaçları ve eşyası dünyanın kendi arazisine göre konur; bu bölgede arazi kızağın arazisi: kıyıda 6 m
		# gömülü bir selvinin tepesi sudan eğik yeşil bir direk gibi çıkıyordu. Gömülenler gizlenir.
		get_tree().create_timer(0.6, false).timeout.connect(_hide_sunk_world)
		get_tree().create_timer(4.0, false).timeout.connect(_hide_sunk_world)


func _process(delta: float) -> void:
	_t += delta
	_work_tick(delta)
	if _cloud_mm:
		var mm := _cloud_mm.multimesh
		for c: Dictionary in _clouds:
			var cp: Vector3 = c["c"]
			cp.x += delta * 1.2
			if cp.x > 320.0:
				cp.x = -320.0
			c["c"] = cp
			for pf: Array in c["puffs"]:
				mm.set_instance_transform(int(pf[0]), Transform3D(pf[2], cp + (pf[1] as Vector3)))
	for g in _gulls:
		var a: float = g["phase"] + _t * g["speed"]
		var n: Node3D = g["node"]
		n.position = g["center"] + Vector3(cos(a), sin(a * 2.0) * 0.08, sin(a)) * g["radius"]
		n.rotation.y = -a
		var flap := sin(_t * 9.0 + g["phase"] * 3.0) * 0.5
		(g["wings"][0] as Node3D).rotation.z = 0.25 + flap
		(g["wings"][1] as Node3D).rotation.z = -0.25 - flap
	if _fish_mm and _underwater_on:
		var mm := _fish_mm.multimesh
		for f: Dictionary in _fish:
			var a: float = f["phase"] + _t * f["speed"]
			var c: Vector3 = f["center"] + Vector3(cos(a) * f["radius"], sin(a * 3.0) * 0.25, sin(a) * f["radius"] * 0.6)
			var b := Basis(Vector3.UP, -a + (PI if f["speed"] < 0.0 else 0.0))
			for o: Array in f["offs"]:
				var wig := sin(_t * 9.0 + float(o[0])) * 0.15
				mm.set_instance_transform(int(o[0]), Transform3D(b * Basis(Vector3.UP, wig), c + b * (o[1] as Vector3)))
	for b in _bob_nodes:
		var bn: Node3D = b["node"]
		if is_instance_valid(bn):
			bn.position.y = b["base_y"] + sin(_t * 1.4 + b["phase"]) * 0.08
			bn.rotation.z = sin(_t * 0.9 + b["phase"]) * 0.06


# ---------------------------------------------------------------- koordinatlar

func s_to_world(s: float, x := 0.0, up := 0.0) -> Vector3:
	return track.to_global(Vector3(x, up, -s))


func world_to_s(p: Vector3) -> float:
	return -track.to_local(p).z


func world_to_x(p: Vector3) -> float:
	return track.to_local(p).x


## Yokuş aşağı birim yön (dünya).
func down_dir() -> Vector3:
	return (track.global_transform.basis * Vector3(0, 0, -1)).normalized()


func end_point() -> Vector3:
	return s_to_world(LENGTH)


func swim_start() -> Vector3:
	return end_point() + Vector3(0, 0, -8)


func shore_point() -> Vector3:
	return end_point() + Vector3(14, 0, -4)


func chain_point() -> Vector3:
	return end_point() + Vector3(-34, 0, -30)


## Haliç zinciri (dünyanın zinciri, ağızda): kuzey ucundan biraz açıkta, sahnenin yerel koordinatında. Zincir yolunu
## seçen kıyı boyunca ağza yüzer (chain_point yolun başı); oraya varınca buraya geçilir.
func world_chain() -> Vector3:
	var n: Vector3 = World1453.LANDMARKS["chain_n"]
	var sd: Vector3 = World1453.LANDMARKS["chain_s"]
	var p := _region.affine_inverse() * n.lerp(sd, 0.12)
	return Vector3(p.x, water_y, p.z)


## Zincirin şehir ucu (yerel): zincirin üstünde yürünecek yön
func world_chain_city() -> Vector3:
	var p := _region.affine_inverse() * (World1453.LANDMARKS["chain_s"] as Vector3)
	return Vector3(p.x, water_y + 1.0, p.z)


## Yokuşun iki yanındaki arazinin yüksekliği (dünya x, z).
func ground_h(x: float, z: float) -> float:
	var end_z := end_point().z
	var base := z * _tan
	var edge := WIDTH / 2.0 + 0.4
	var ax := absf(x) - edge
	var h := base - 0.3
	if ax > 0.0:
		var hills := _noise.get_noise_2d(x, z) * minf(ax * 0.35, 5.0)
		h += ax * 0.12 + hills + maxf(0.0, ax - 25.0) * 0.18
	# Tek haritada: kenarlarda ve tepenin ardında dünyanın kuzey kıyı arazisine yumuşakça iner (sınırda uçurum olmasın)
	if in_world:
		var k := maxf(smoothstep(30.0, 100.0, ax), smoothstep(25.0, 150.0, z))
		if k > 0.0:
			var w := _region * Vector3(x, 0.0, z)
			h = lerpf(h, HornWorld.north_h(w.x, w.z, true) - _region.origin.y, k)
	# Kıyıya yaklaştıkça su seviyesine iner
	var shore := clampf((z - end_z) / 6.0, 0.0, 1.0)
	if z < end_z + 6.0:
		h = lerpf(water_y - 1.6, h, shore)
	# Kumsal arazinin kendisi (tur 3): kızağın ucunun iki yanında suyun 20 cm üstünde düz kum, önü suya iner. Eskiden düz
	# bir kum kutusu yamacın üçgenleriyle kesişiyor, yamaçta beyaz üçgenler, kumsalda keskin kenarlı nane renkli levha,
	# sualtından bakınca altı karanlık büyük bir plaka görünüyordu. Kutunun çarpışması kalır, görüntüsü gizli.
	# Kumsalın su altı yüzü dik (arazi ızgarası 3,3 m: köşe end_z-3,36'da su 1,25 m derin, -0,03'te kuru kum): yüzme
	# hedefinde (end_z-4,8) su 1,4 m derin kalır; eskiden 0,6 m'lik sığlıkta yüzücü kumun üstünde süzülüyor gibiydi.
	var bx := absf(x - end_point().x)
	if bx < 46.0 and z > end_z - 7.0 and z < end_z + 10.0:
		var beach := water_y + 0.2
		var dz := z - end_z
		if dz < -3.4:
			beach = lerpf(water_y - 1.6, water_y - 1.25, smoothstep(-7.0, -3.4, dz))
		elif dz < -0.6:
			beach = lerpf(water_y - 1.25, water_y + 0.2, (dz + 3.4) / 2.8)
		# Rampanın önündeki oluk (kızağın iki arazi şeridi arası): kumsalın yüzü derine iner, düşüş yeri açık su kalır
		if bx < WIDTH / 2.0 + 0.4 and dz < -3.4:
			beach = lerpf(water_y - 1.25, water_y - 2.6, clampf((-3.4 - dz) / 1.6, 0.0, 1.0))
			return beach
		var w := (1.0 - smoothstep(40.0, 46.0, bx)) * (1.0 - smoothstep(end_z + 7.0, end_z + 10.0, z))
		h = maxf(h, lerpf(h, beach, w))
	return h


# ---------------------------------------------------------------- gökyüzü

func _build_sky() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3a7fc4")
	sm.sky_horizon_color = Color("c4dceb")
	sm.ground_horizon_color = Color("c9d8c0")
	sm.ground_bottom_color = Color("6d7f5a")
	sm.sky_energy_multiplier = 0.95
	sm.sun_angle_max = 18.0
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.62
	e.ambient_light_sky_contribution = 0.85
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.05
	e.fog_enabled = true
	e.fog_light_color = Color("c7d7e4")
	e.fog_density = 0.0012
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.2
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.05
	e.adjustment_contrast = 1.06
	env.environment = e
	_env = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	# 22 Nisan sabahı: alçak (29°), sıcak, sarı-turuncu güneş; gölgeler eskisinden (34°) uzun. Güneşi yokuşun tepesine
	# (kaçanın arkasına) almak gölge geçişinin çizdiğini iki katına çıkarıyordu (perf: gölge payı %15 → %28); yönü korundu.
	sun.rotation_degrees = Vector3(-29, 150, 0)
	sun.light_color = Color("ffd7a6")
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)
	SkyBody.attach(self, sun)


func _build_clouds_and_gulls() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2204
	# Bulutlar: tek çoklu ağ (eskiden ~80 ayrı küre, her biri bir çizim); her bulut 4-7 topak, sabah güneşinde altları
	# şeftali-gri. Topaklar _process'te birlikte kayar.
	var sm := SphereMesh.new()
	sm.radius = 1.0
	sm.height = 2.0
	sm.radial_segments = 7
	sm.rings = 4
	var xs: Array = []
	var cs: Array = []
	for i in 14:
		var c := Vector3(rng.randf_range(-300, 300), rng.randf_range(48, 85), rng.randf_range(-40, -480))
		var puffs: Array = []
		for k in rng.randi_range(4, 7):
			var r := rng.randf_range(5.0, 10.0)
			var off := Vector3(rng.randf_range(-14, 14), rng.randf_range(-1.5, 3.0), rng.randf_range(-6, 6))
			puffs.append([xs.size(), off, Basis.from_scale(Vector3(1.4, 0.6, 1.0) * r)])
			xs.append(Transform3D(Basis.from_scale(Vector3(1.4, 0.6, 1.0) * r), c + off))
			cs.append(Color("fff6ea") if k > 0 else Color("e6d8d2"))
		_clouds.append({"c": c, "puffs": puffs})
	var cm := StandardMaterial3D.new()
	cm.vertex_color_use_as_albedo = true
	cm.vertex_color_is_srgb = true
	cm.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	cm.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_cloud_mm = Scenery.scatter(self, sm, xs, cs, cm)
	_cloud_mm.set_meta("no_walk", true)
	# Martılar
	var end := end_point()
	for i in 7:
		var g := Node3D.new()
		add_child(g)
		var wings: Array = []
		for side in [-1, 1]:
			var pivot := Node3D.new()
			g.add_child(pivot)
			var w := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = Vector3(0.9, 0.04, 0.25)
			w.mesh = bm
			w.material_override = Props.mat(Color("f4f4f0"), 0.0, false, "", false)
			w.position = Vector3(side * 0.45, 0, 0)
			pivot.add_child(w)
			wings.append(pivot)
		var body := MeshInstance3D.new()
		var bb := BoxMesh.new()
		bb.size = Vector3(0.18, 0.14, 0.5)
		body.mesh = bb
		body.material_override = Props.mat(Color("e9e9e4"), 0.0, false, "", false)
		g.add_child(body)
		for mi in g.find_children("*", "MeshInstance3D", true, false):
			(mi as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_gulls.append({
			"node": g, "wings": wings,
			"center": end + Vector3(rng.randf_range(-40, 30), rng.randf_range(10, 22), rng.randf_range(-70, -10)),
			"radius": rng.randf_range(8, 20), "speed": rng.randf_range(0.25, 0.5), "phase": rng.randf() * TAU,
		})


# ---------------------------------------------------------------- yokuş

func _build_slope() -> void:
	# Kızak yolu (çarpışmalı): kalas döşeme. Döşemenin kendisi birleştirilmez (zemin denetimi görünür ağı olan gövdeyi arar)
	var body := Props.solid(track, Vector3(WIDTH, 1.0, LENGTH + 6), Vector3(0, -0.5, -LENGTH / 2.0 + 2), C_TRACK)
	Props.set_pattern(body, C_TRACK, "wood")
	# Kızağın başı (s -32..-5): kadırga buradan, kütüklerin üstünden kalkar; kıçtaki fren halatlarının kazıkları burada.
	# Eskiden kızak s=-5'te bitiyordu: başlangıçta kadırga, iticileri ve tayfası toprağın 30 cm üstünde duruyordu
	var head := Props.solid(track, Vector3(WIDTH, 1.0, 27.0), Vector3(0, -0.5, 18.5), C_TRACK)
	Props.set_pattern(head, C_TRACK, "wood")
	for b: StaticBody3D in [body, head]:
		for c in b.get_children():
			if c is MeshInstance3D:
				c.set_meta("no_bake", true)
	# Yanlarda görünmez duvarlar: oyuncu yoldan çıkamaz
	for side in [-1, 1]:
		var wall := Props.solid(track, Vector3(0.4, 3.0, LENGTH + 6), Vector3(side * (WIDTH / 2.0 + 0.2), 1.5, -LENGTH / 2.0 + 2), Color(0, 0, 0, 0))
		wall.get_child(0).visible = false
	# Süs: iki gruba toplanır ve tek ağa pişirilir (_bake_track). _track_gloss: yağdan parlayan kütükler ve yağ izi
	# şeritleri; _track_deco: kirişler, takozlar, kazıklar, yeni/kırık kalaslar, rampa. Eskiden ~120 ayrı mesh (her biri
	# dış çizgisiyle iki çizim) ve ince, yarı gömülü kütükler: yol uzaktan düz bir tahta gibi okunuyordu.
	_track_gloss = Node3D.new()
	track.add_child(_track_gloss)
	_track_deco = Node3D.new()
	track.add_child(_track_deco)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1304
	var log_c := Color("8a5e38")
	var beam_c := Color("5f4329")
	# Ray kirişleri: kütükler bunların üstüne enine yatar (iki iç ray + iki kenar kirişi), kızağın başından suya kadar
	# (kızağın ucunda biter: rampa kısalınca 4 m'si suyun üstünde yatay sopalar gibi kalıyordu)
	for rx: float in [-2.3, 2.3]:
		Props.box(_track_deco, Vector3(0.34, 0.16, LENGTH + 33.0), Vector3(rx, 0.02, (32.0 - LENGTH - 1.0) / 2.0), beam_c.darkened(0.1))
	for side in [-1, 1]:
		Props.box(_track_deco, Vector3(0.3, 0.32, LENGTH + 33.0), Vector3(side * (WIDTH / 2.0 - 0.15), 0.16, (32.0 - LENGTH - 1.0) / 2.0), beam_c)
	# Enine yağlı kütükler: kalın, yuvarlak, parlak; uçlarında açık kesit ve iki yanında takoz
	var s := -31.0
	while s < LENGTH:
		if absf(s + 5.6) > 0.9:      # baş ile ana yolun ek yeri
			var lc := log_c.lerp(Color("7e5634"), rng.randf())
			Props.cyl(_track_gloss, 0.22, WIDTH - 0.75, Vector3(0, 0.13, -s), lc, Vector3(0, 0, 90), 10)
			for side in [-1, 1]:
				Props.cyl(_track_deco, 0.17, 0.03, Vector3(side * (WIDTH - 0.75) / 2.0, 0.13, -s), Color("d8b98a"), Vector3(0, 0, 90), 10)
				for dz: float in [-0.3, 0.3]:
					Props.prism(_track_deco, Vector3(0.26, 0.14, 0.22), Vector3(side * (WIDTH / 2.0 - 0.62), 0.08, -s + dz), Color("6e5234"), Vector3(0, 90, 0))
		s += 2.6
	# Yağ izi: her şeritte kesik kesik koyu, parlak şerit (kadırganın kızağının sürüklediği iç yağı)
	for lx: float in LANES:
		var z0 := rng.randf_range(2.0, 6.0)
		while z0 < LENGTH - 2.0:
			# Şerit kızağın ucunda biter (tur 3, sonda: son şerit 12 m'ye dek kızağın eğiminde uzayıp suya giriyordu; sualtından
			# bakınca tepede koyu, keskin kenarlı büyük bir yamuk levha olarak görünen buydu)
			var ln := minf(rng.randf_range(5.0, 14.0), LENGTH - 1.0 - z0)
			Props.box(_track_gloss, Vector3(rng.randf_range(0.6, 1.1), 0.014, ln), Vector3(lx + rng.randf_range(-0.25, 0.25), 0.008, -(z0 + ln * 0.5)), Color("6a4c2c"))
			z0 += ln + rng.randf_range(2.0, 7.0)
	# Yer yer yenilenmiş (açık renk) ve kırık (iki parça, uçları kalkık) kalaslar
	for i in 16:
		var ps := rng.randf_range(-28.0, LENGTH - 3.0)
		var px := rng.randf_range(-3.6, 3.6)
		if i % 3 == 0:
			for k in 2:
				var sgn := -1.0 if k == 0 else 1.0
				Props.box(_track_deco, Vector3(0.75, 0.035, 0.26), Vector3(px + sgn * 0.4, 0.03 + 0.02, -ps), Color("5a4026"), Vector3(0, rng.randf_range(-8, 8), sgn * -6.0))
		else:
			Props.box(_track_deco, Vector3(rng.randf_range(1.2, 2.2), 0.03, 0.27), Vector3(px, 0.015, -ps), Color("9a7a4e"))
	# Kenar kazıkları (halatla bağlı ikili kazık)
	for side in [-1, 1]:
		var k := 0.0
		while k < LENGTH:
			Props.cyl(_track_deco, 0.09, 0.9, Vector3(side * (WIDTH / 2.0 + 0.05), 0.3, -k), Color("6b4a2e"), Vector3(0, 0, side * 6.0), 6)
			Props.cyl(_track_deco, 0.1, 0.06, Vector3(side * (WIDTH / 2.0 + 0.05), 0.55, -k), Color("b89a6a"), Vector3.ZERO, 6)
			k += 6.5
	# Kızağın ucu: kalas rampa suya iner ve suyun altında kaybolur (eskiden yol havada kesik bitiyordu); iki yanında kazıklar
	# Rampa su çizgisinin hemen altında biter (tur 3): eskiden 6 m uzayıp suyun altında koyu zeytin rengi büyük bir yamuk
	# levha gibi görünüyordu; su altında yalnız kazıklar kalır (kazıklı iskele gibi)
	var ramp_len := 3.3
	var ang := deg_to_rad(16.0)
	var rc := Vector3(0, -sin(ang) * ramp_len * 0.5 - 0.1, -LENGTH - 1.0 - cos(ang) * ramp_len * 0.5)
	Props.box(_track_deco, Vector3(WIDTH - 1.0, 0.18, ramp_len), rc, C_TRACK.darkened(0.08), Vector3(-rad_to_deg(ang), 0, 0))
	for rx: float in [-2.3, 2.3]:
		Props.box(_track_deco, Vector3(0.34, 0.22, ramp_len), rc + Vector3(rx, -0.12, 0), beam_c.darkened(0.2), Vector3(-rad_to_deg(ang), 0, 0))
	for i in 3:
		var dd := 1.6 + i * 2.0
		var zz := -LENGTH - 1.0 - cos(ang) * dd
		if dd < ramp_len:
			Props.cyl(_track_gloss, 0.2, WIDTH - 1.4, Vector3(0, -0.1 - sin(ang) * dd + 0.12, zz), Color("6e5030"), Vector3(0, 0, 90), 10)
		for side in [-1, 1]:
			Props.cyl(_track_deco, 0.13, 3.0, Vector3(side * (WIDTH / 2.0 - 0.2), -1.0 - i * 0.4, zz), Color("4e3a26"), Vector3.ZERO, 6)


var _track_gloss: Node3D
var _track_deco: Node3D


## Kızak yolunun süsü tek ağa pişer (kütükler ve yağ izi parlak malzemeyle ayrı): ~250 parça, 3-4 çizim.
func _bake_track() -> void:
	Props.bake_static(_track_gloss, _track_gloss.get_children())
	for c in _track_gloss.get_children():
		if c is MeshInstance3D and (c as MeshInstance3D).material_override is StandardMaterial3D:
			var m := (c as MeshInstance3D).material_override as StandardMaterial3D
			m.roughness = 0.35
			m.metallic_specular = 0.6
	Props.bake_static(_track_deco, _track_deco.get_children())


func _build_terrain() -> void:
	var end_z := end_point().z
	var edge := WIDTH / 2.0 + 0.3
	var colf := func(x: float, z: float, y: float, steep: float) -> Color:
		var ax := absf(x) - WIDTH / 2.0
		if y < water_y - 0.45:
			return Color("8a946a").srgb_to_linear()      # su altındaki kum: sığlığın dibiyle aynı ton (sualtında parlak turuncu levha olmasın)
		# Kum-çim sınırı (tur 4): düz çizgi değil, girintili çıkıntılı; sınırda iki renk karışır (köşe rengi), kum sıcak ve yamalı
		var k := sand_k(x, z, y)
		var c := Color("2c4d1d").lerp(Color("466426"), clampf(_noise.get_noise_2d(x * 3.1, z * 3.1) * 1.5 + 0.5, 0.0, 1.0))
		if ax < 1.6:
			c = Color("8f6f4a")
		else:
			if steep > 0.35:
				c = c.darkened(0.12)
			if y - z * _tan > 5.0:
				c = c.lerp(Color("5f6238"), 0.35)
		if k > 0.0:
			return c.lerp(_sand_color(x, z), k)
		return c
	var hf := func(x: float, z: float) -> float: return ground_h(x, z)
	load("res://scripts/level/zemin.gd").yore("kiyi", self, {"su_y": water_y})      # ZEMİN: yöre paleti, kıyı bantları
	add_child(LowPoly.terrain(edge, 110.0, end_z - 10.0, 160.0, 36, 90, hf, colf))
	add_child(LowPoly.terrain(-110.0, -edge, end_z - 10.0, 160.0, 36, 90, hf, colf))
	# Yokuşun tepesinin arkası (kadırga buradan başlar)
	add_child(LowPoly.terrain(-edge, edge, 4.0, 160.0, 4, 30, hf, colf))
	# Rampanın altı ve önü (kızak yolunun iki arazi şeridi arasındaki boşluk): kumsalın su altı yüzü burada da sürer.
	# Eskiden kum kutusu örtüyordu; kutu gizlenince sudan bakınca keskin kenarlı derin bir oluk görünüyordu (tur 3)
	add_child(LowPoly.terrain(-edge, edge, end_z - 5.0, end_z - 0.5, 4, 2, hf, colf))


## Kumsalın kum oranı (1: kum, 0: çim): kıyıdan uzaklaştıkça ve kumsalın doğu-batı uçlarında, gürültüyle oynayan bir sınır
## (girinti ve çıkıntılar, 2-8 m); yükseldikçe (yamaç) çimene döner. Arazi rengi ve kıyı ayrıntıları (ot, çakıl) kullanır.
func sand_k(x: float, z: float, y: float) -> float:
	var end := end_point()
	var dz := z - end.z
	var bx := absf(x - end.x)
	var n1 := _noise.get_noise_2d(x * 4.0 + 13.0, z * 4.0) * 1.7
	var n2 := _noise.get_noise_2d(x * 3.0 - 40.0, z * 3.0 + 9.0) * 1.7
	var kz := clampf((5.0 + n1 * 3.4 - dz) / 3.2, 0.0, 1.0)
	var kx := clampf((37.0 + n2 * 4.0 - bx) / 4.5, 0.0, 1.0)
	var ky := 1.0 - smoothstep(0.7, 2.4, y - water_y)      # kum plato bitince yamaca biraz tırmanır (çimle karışık)
	return minf(minf(kz, kx), ky)


## Sıcak, hafif yamalı kum rengi (zemin gölgelendiricisi köşe rengini doğrusal okur).
func _sand_color(x: float, z: float) -> Color:
	var p := clampf(_noise.get_noise_2d(x * 1.7 + 5.0, z * 1.7 - 3.0) * 1.9 + 0.3, 0.0, 0.8)
	var c := Color("dcbb82").lerp(Color("c08f58"), p)
	return c.lerp(c.srgb_to_linear(), 0.85)


## Zemin ayrıntısı (Nature.ground_detail; her tür tek çoklu ağ): kızağın iki yanında çiğnenmiş çamur şeridi, ayak izleri,
## talaş ve yonga, parlak yağ lekeleri, taş; yamaçlarda ot öbekleri, uzun ot, çalı, taş ve kütük parçaları. Eskiden
## tepeler düz boyalı yeşil, yol kenarı çıplaktı.
func _build_ground_detail() -> void:
	var end_z := end_point().z
	var hf := func(x: float, z: float) -> float: return surface_h(x, z)
	var dry := func(x: float, z: float) -> bool: return surface_h(x, z) > water_y + 0.35
	var z0 := end_z + 7.0
	var z1 := 31.0
	var seed := 50
	# İki yan tek alanda (her tür tek çoklu ağ): yol şeridi (kenardan 0,3-2,1 m) ve yamaçlar (2,1-29 m)
	var band_keep := func(x: float, z: float) -> bool: return absf(x) > 4.75 and absf(x) < 6.6 and bool(dry.call(x, z))
	var slope_keep := func(x: float, z: float) -> bool: return absf(x) >= 6.6 and bool(dry.call(x, z))
	for kd: Array in [["mud", 0.9], ["footprint", 0.4], ["chips", 0.55], ["grease", 0.14], ["stone", 0.12]]:
		Nature.ground_detail(self, Rect2(-6.6, z0, 13.2, z1 - z0), kd[0], kd[1] * 13.2 / 3.7, seed, hf, band_keep)
		seed += 1
	for kd: Array in [["grass", 0.7], ["tall_grass", 0.08], ["bush", 0.02], ["stone", 0.05], ["log", 0.006], ["chips", 0.03]]:
		var mi := Nature.ground_detail(self, Rect2(-34.0, z0, 68.0, z1 - z0), kd[0], kd[1] * 68.0 / 54.8, seed, hf, slope_keep, 8000)
		if mi and kd[0] in ["grass", "tall_grass", "bush"]:
			_tall_detail.append(mi)
		seed += 1
	# Kızağın başının ardı (kadırga buradan kalktı): çiğnenmiş toprak ve talaş
	Nature.ground_detail(self, Rect2(-4.8, 30.0, 9.6, 14.0), "mud", 0.5, seed, hf, dry)
	Nature.ground_detail(self, Rect2(-4.8, 30.0, 9.6, 14.0), "chips", 0.6, seed + 1, hf, dry)


var _tall_detail: Array = []


## Ot, uzun ot ve çalı örnekleri verilen noktaların r metre yakınından kaldırılır (tur 3): kameranın durduğu, yürüdüğü
## ve karakterlerin durduğu yerlerde ekranı kaplayan dev yaprak kalmasın. Chapter2 kıyı yerleri seçilince çağırır.
func clear_detail_near(points: Array, r: float) -> int:
	var n := 0
	for mi: MultiMeshInstance3D in _tall_detail:
		if not is_instance_valid(mi) or mi.multimesh == null:
			continue
		var mm := mi.multimesh
		var xfs: Array = mi.get_meta("xforms", [])
		for i in mm.instance_count:
			var xf: Transform3D = xfs[i] if i < xfs.size() else mm.get_instance_transform(i)
			var o := mi.to_global(xf.origin)
			for p: Vector3 in points:
				if Vector2(o.x - p.x, o.z - p.z).length() < r:
					var gone := Transform3D(Basis.from_scale(Vector3.ONE * 0.0001), xf.origin)
					mm.set_instance_transform(i, gone)
					if i < xfs.size():
						xfs[i] = gone
					n += 1
					break
	return n


## Kıyı: ıslak kum bandı, köpük çizgisi, çakıl, yosun, kıyıya vurmuş tahta (Nature.shore_band); kumsalın suya inen eğimi
## (su kıyıda sığlaşıyor gibi görünsün); kızağın suya girdiği rampanın çevresinde köpük; kıyıdaki karakol (çekili
## kayıklar, kuruyan ağlar, çardak, nöbet ateşi, askerlerin geldiği patika). Eskiden kumsal düz açık bej bir şeritti.
func _build_shore() -> void:
	var end := end_point()
	# Kumsal görünen arazinin kendisi (ground_h): ıslak bant ve köpük gerçek su çizgisinde (end_z-0,5 dolayı)
	var beach := func(x: float, z: float) -> float: return surface_h(x, z)
	var off_track := func(x: float, _z: float) -> bool: return absf(x - end.x) > 5.6
	Nature.shore_band(self, Vector3(end.x - 39.0, 0, end.z - 1.0), Vector3(end.x + 39.0, 0, end.z - 1.0), Vector3(0, 0, -1),
		water_y, beach, 91, off_track)
	# Rampanın iki yanında köpük
	var foam: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 92
	for i in 18:
		var fx := end.x + (rng.randf_range(4.0, 5.5) * (1.0 if i % 2 == 0 else -1.0))
		foam.append(Vector3(fx, water_y, end.z - rng.randf_range(2.0, 6.5)))
	for i in 8:
		foam.append(Vector3(end.x + rng.randf_range(-4.0, 4.0), water_y, end.z - rng.randf_range(5.5, 7.5)))
	Nature._scatter_at(self, "foam", foam, 93, func(x: float, z: float) -> float: return water_y)
	# Kumun çimle sınırında ot öbekleri, kumun üstünde çakıl ve yassı taş: sınır çizgi gibi değil, geçişli görünsün (tur 4)
	var sandy := func(lo: float, hi: float) -> Callable:
		return func(x: float, z: float) -> bool:
			var yy := surface_h(x, z)
			var kk := sand_k(x, z, yy)
			return absf(x - end.x) > 5.6 and yy > water_y + 0.12 and kk >= lo and kk <= hi
	var sand_area := Rect2(end.x - 44.0, end.z + 0.5, 88.0, 10.0)
	var sd := 120
	for kd: Array in [["grass", 0.55, 0.02, 0.9], ["pebble", 0.35, 0.3, 1.0], ["stone", 0.05, 0.3, 1.0], ["chips", 0.06, 0.3, 1.0]]:
		Nature.ground_detail(self, sand_area, kd[0], kd[1], sd, beach, sandy.call(kd[2], kd[3]))
		sd += 1
	_build_guard_post(end)


## Kıyı karakolu: yakalanan oyuncunun önünde, askerlerin geldiği yönde (kızaktan uzağa, kıyı boyunca).
func _build_guard_post(end: Vector3) -> void:
	var post := Node3D.new()
	add_child(post)
	var base := Vector3(end.x + 33.0, water_y + 0.2, end.z + 3.5)
	base.y = maxf(water_y + 0.2, surface_h(base.x, base.z))      # görünen zemine (kumsal ya da yamaç eteği)
	# Çardak: dört direk, hasır dam
	for dx: float in [-1.4, 1.4]:
		for dz: float in [-1.1, 1.1]:
			Props.cyl(post, 0.07, 2.3, base + Vector3(dx, 1.15, dz), Color("6b4a2e"), Vector3.ZERO, 6)
	Props.box(post, Vector3(3.4, 0.14, 2.8), base + Vector3(0, 2.32, 0), Color("c9b07a"), Vector3(0, 0, 5))
	Props.box(post, Vector3(3.5, 0.06, 2.9), base + Vector3(0, 2.42, 0), Color("a88e5a"), Vector3(0, 0, 5))
	Props.box(post, Vector3(1.6, 0.4, 0.5), base + Vector3(0.3, 0.2, 0.6), Color("8a6440"))     # sedir
	# Nöbet ateşi: taş halkası, kütükler, kor; üstünde ince duman
	var fire := base + Vector3(-3.2, 0, -1.6)
	fire.y = maxf(water_y + 0.2, surface_h(fire.x, fire.z))
	for a in 7:
		var ang := TAU * a / 7.0
		Props.ball(post, 0.14, fire + Vector3(cos(ang) * 0.42, 0.06, sin(ang) * 0.42), Color("7a766c"), Vector3(1, 0.7, 1), 6)
	for a in 3:
		Props.cyl(post, 0.06, 0.7, fire + Vector3(0, 0.12, 0), Color("4a3422"), Vector3(80, a * 60.0, 0), 6)
	Props.box(post, Vector3(0.3, 0.06, 0.3), fire + Vector3(0, 0.04, 0), Color("d4601e"))
	# Çekili kayıklar (biri ters, biri yan yatık) ve kuruyan ağ
	for k in 2:
		var bp := base + Vector3(4.0 + k * 3.2, -0.05, -1.4 + k * 0.6)
		var hull := LowPoly.hull([
			{"z": -2.6, "w": 0.05, "top": 0.75, "bottom": 0.35},
			{"z": -1.6, "w": 0.6, "top": 0.55, "bottom": -0.05},
			{"z": 0.5, "w": 0.75, "top": 0.5, "bottom": -0.1},
			{"z": 2.0, "w": 0.6, "top": 0.55, "bottom": -0.05},
			{"z": 2.5, "w": 0.35, "top": 0.7, "bottom": 0.2},
		], Color("6b4428"), Color("3f6f8a") if k == 0 else Color("8a3a2a"), 0.4)
		hull.position = bp + Vector3(0, 0.12, 0)
		hull.rotation = Vector3(0, 0.6 + k * 0.5, 0.0 if k == 0 else 0.35)
		post.add_child(hull)
		Props.cyl(post, 0.025, 2.2, bp + Vector3(0.9, 0.12, 0.2), Color("c9a878"), Vector3(0, 30.0 + k * 40.0, 88), 4)
	for dx: float in [0.0, 2.4]:
		Props.cyl(post, 0.05, 1.9, base + Vector3(-1.0 + dx, 0.95, 2.6), Color("6b4a2e"), Vector3.ZERO, 5)
	Props.box(post, Vector3(2.3, 1.2, 0.03), base + Vector3(0.2, 1.15, 2.6), Color("6a6448"))
	Stage.rope(post, base + Vector3(-1.0, 1.85, 2.6), base + Vector3(1.4, 1.85, 2.6), 0.08, 0.018)
	Props.bake_static(post, post.get_children().filter(func(c): return not (c is MeshInstance3D and (c as MeshInstance3D).has_meta("rope"))))
	# Karakoldan kıyı boyunca çiğnenmiş patika (askerler buradan gelir)
	var path := Rect2(end.x + 12.0, end.z + 0.5, 20.0, 2.0)
	var beach := func(x: float, z: float) -> float: return maxf(surface_h(x, z), water_y + 0.2)
	Nature.ground_detail(self, path, "footprint", 0.9, 94, beach)
	Nature.ground_detail(self, path, "wet", 0.25, 95, beach)
	# Görünen alev ve ince, yükselip kaybolan duman (tur 3: eskiden ateşi görünmeyen iri gri duman topları havada asılı
	# duruyordu)
	_post_fire = Node3D.new()
	add_child(_post_fire)
	_post_fire.position = fire
	Flame.add(_post_fire, Vector3(0, 0.1, 0), 0.4, 0.6)
	Vfx.smoke_wisp(_post_fire, fire + Vector3(0, 0.7, 0), 3.2)


var _post_fire: Node3D


## Haliç üstünde ince sabah sisi: suyun hemen üstünde yayvan, kenarı yumuşak, yarı saydam katmanlar (tek çoklu ağ).
func _build_mist() -> void:
	var end := end_point()
	var q := QuadMesh.new()
	q.size = Vector2(1, 1)
	q.orientation = PlaneMesh.FACE_Y
	var sh := Shader.new()
	sh.code = """shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;
uniform vec4 tint : source_color = vec4(0.93, 0.9, 0.86, 1.0);
void fragment() {
	vec2 d = (UV - 0.5) * 2.0;
	float r = clamp(1.0 - dot(d, d), 0.0, 1.0);
	float drift = 0.85 + 0.15 * sin(TIME * 0.1 + UV.x * 6.0);
	ALBEDO = tint.rgb;
	ALPHA = r * r * 0.32 * drift;
}"""
	var m := ShaderMaterial.new()
	m.shader = sh
	var rng := RandomNumberGenerator.new()
	rng.seed = 2204
	var xs: Array = []
	for i in 22:
		var p := Vector3(end.x + rng.randf_range(-160, 120), water_y + rng.randf_range(0.6, 3.0), end.z - rng.randf_range(35, 300))
		var sc := Vector3(rng.randf_range(40, 90), 1, rng.randf_range(10, 22))
		xs.append(Transform3D(Basis(Vector3.UP, rng.randf_range(-0.2, 0.2)) * Basis.from_scale(sc), p))
	var mi := Scenery.scatter(self, q, xs, [], m)
	mi.set_meta("no_walk", true)
	mi.set_meta("soft", true)


func _place_on_ground(node: Node3D, x: float, z: float) -> void:
	node.position = Vector3(x, surface_h(x, z), z)
	add_child(node)


## Görünen arazinin yüzeyi (_build_terrain'in üç ızgarasından biri): ground_h köşeler arasında görünen yüzeyden
## sapar; ırgat askerleri, çadırlar, ağaçlar yamaçta havada kalıyor ya da toprağa gömülüyordu.
func surface_h(x: float, z: float) -> float:
	var end_z := end_point().z
	var edge := WIDTH / 2.0 + 0.3
	var hf := func(px: float, pz: float) -> float: return ground_h(px, pz)
	if x >= edge:
		return LowPoly.surface_y(x, z, edge, 110.0, end_z - 10.0, 160.0, 36, 90, hf)
	if x <= -edge:
		return LowPoly.surface_y(x, z, -110.0, -edge, end_z - 10.0, 160.0, 36, 90, hf)
	if z >= 4.0:
		return LowPoly.surface_y(x, z, -edge, edge, 4.0, 160.0, 4, 30, hf)
	return ground_h(x, z)


## Yokuş boyunca s, kenardan uzaklık -> dünya x, z
func _side_xz(s: float, side: int, dist: float) -> Vector2:
	var p := s_to_world(s, side * (WIDTH / 2.0 + dist))
	return Vector2(p.x, p.z)


func _build_sides() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 22041453
	for side in [-1, 1]:
		# Selviler (gruplar hâlinde)
		for i in 26:
			var xz := _side_xz(rng.randf_range(-5, LENGTH - 4), side, rng.randf_range(5, 40))
			var tree := Node3D.new()
			_cypress(tree, rng.randf_range(4.0, 8.0))
			_place_on_ground(tree, xz.x, xz.y)
		# Çadırlar
		for i in 6:
			var xz2 := _side_xz(10.0 + i * 20.0 + rng.randf_range(-4, 4), side, rng.randf_range(8, 16))
			var tent := Node3D.new()
			_tent(tent, rng.randf() > 0.5)
			var ty := rng.randf_range(-20, 20)
			tent.rotation_degrees.y = ty
			# Yamaçta merkezden oturan çadırın bir yanı havada kalıyordu (uzaktan havada beyaz bir levha gibi): en alçak
			# köşeye oturur, yokuş yukarı yanı toprağa girer; altında düzlenmiş toprak (koyu yayvan taban)
			var low := INF
			for cx: float in [-1.3, 1.3]:
				for cz: float in [-1.3, 1.3]:
					var q := Vector3(cx, 0, cz).rotated(Vector3.UP, deg_to_rad(ty))
					low = minf(low, surface_h(xz2.x + q.x, xz2.y + q.z))
			tent.position = Vector3(xz2.x, low - 0.05, xz2.y)
			add_child(tent)
			Props.cyl(tent, 1.75, 0.9, Vector3(0, -0.38, 0), Color("6e5638"), Vector3.ZERO, 9, 1.95)
		# Kızak ekipleri (ne yaptıkları uzaktan anlaşılsın):
		#   ırgat: dört asker kolları iterek dönen makarayı çevirir, halat kızağa iner
		#   yağcı: kovadan kızak kütüklerine iç yağı atar ("yağlı kızak")
		#   gözcü: yanından geçen Tolga'ya döner, gösterip bağırır
		for i in 9:
			var s3 := 6.0 + i * 13.0
			var coat: Color = [Color("b3262d"), Color("2f5fa8"), Color("3f7a3a"), Color("c98a3a")][i % 4]
			match i % 3:
				0:
					var xz3 := _side_xz(s3, side, 3.2)
					var cap := _capstan(coat)
					# Irgat yamaçta: dönen askerler eğimde yarı havada yarı gömülü dolaşıyordu. Düz kalas döşeme: üstü
					# çemberin en yüksek zemininde, altı en alçağının altına iner
					var hi := -INF
					var lo := INF
					for k in 12:
						var a := TAU * k / 12.0
						var gy := surface_h(xz3.x + cos(a) * 2.5, xz3.y + sin(a) * 2.5)
						hi = maxf(hi, gy)
						lo = minf(lo, gy)
					hi = maxf(hi, surface_h(xz3.x, xz3.y))
					# Ahşap platform (tur 3): kalaslar ve altında iki kiriş, yokuş aşağı yanı kazıklara oturur; çevresinde
					# ırgatı çevirenlerin çiğnediği toprak halkası. Eskiden yamaçtan taşan kalın, düz bej bir pasta dilimiydi.
					var dk := Node3D.new()
					add_child(dk)
					dk.position = Vector3(xz3.x, hi + 0.05, xz3.y)
					dk.rotation.y = rng.randf_range(0.0, PI)
					# Çap 4,8 m: makarayı iterek dönenlerin geride gergin bacağı da kalasa basar (4 m'lik döşemede kenardan
					# boşluğa sarkıyordu)
					for j in 9:
						var u := -2.4 + j * 0.6
						var ln := 2.0 * sqrt(maxf(0.36, 6.25 - u * u)) - rng.randf_range(0.0, 0.15)
						var pc := Color("8a6a44").lerp(Color("a07c50"), rng.randf()).darkened(0.05 if j % 2 == 0 else 0.15)
						Props.box(dk, Vector3(0.56, 0.07, ln), Vector3(u, -0.035, rng.randf_range(-0.06, 0.06)), pc, Vector3(0, rng.randf_range(-1.5, 1.5), 0))
					for bz: float in [-0.95, 0.95]:
						Props.box(dk, Vector3(4.8, 0.14, 0.18), Vector3(0, -0.14, bz), Color("5f4329"))
					# Döşemenin çarpışması (eski dolu dilimin yerine): makarayı çevirenler kalasa basar, zemine inmez
					# (üçgen yüzeyli şekil: Unclip görünen zemin sayar; yoksa dinlenen askerleri araziye indiriyordu)
					var dcol := StaticBody3D.new()
					var dcs := CollisionShape3D.new()
					var dcy := CylinderMesh.new()
					dcy.top_radius = 2.45
					dcy.bottom_radius = 2.45
					dcy.height = 0.14
					dcy.radial_segments = 12
					dcy.rings = 1
					dcs.shape = dcy.create_trimesh_shape()
					dcs.position = Vector3(0, -0.07, 0)
					dcol.add_child(dcs)
					dk.add_child(dcol)
					for k in 6:
						var a := TAU * k / 6.0 + 0.3
						var pp := dk.to_global(Vector3(cos(a) * 2.1, 0, sin(a) * 2.1))
						var gy := surface_h(pp.x, pp.z)
						var ph := (dk.global_position.y - 0.2) - gy + 0.12
						if ph > 0.12:
							Props.cyl(self, 0.09, ph, Vector3(pp.x, gy - 0.12 + ph * 0.5, pp.z), Color("4e3a26"), Vector3.ZERO, 6)
					for k in 16:
						var a := TAU * k / 16.0 + rng.randf_range(-0.15, 0.15)
						var rr := rng.randf_range(2.6, 3.3)
						_deck_mud.append(Vector3(xz3.x + cos(a) * rr, 0, xz3.y + sin(a) * rr))
					cap.position = Vector3(xz3.x, hi + 0.05, xz3.y)
					cap.set_meta("no_bake", true)
					# Irgatın halatı yokuş aşağıdaki kütük kızağına gider (_build_crews); eskiden kızağın kenarındaki
					# bir kazığa, oradan 11 m boşluğa uzanıyordu: hiçbir şeye bağlı değildi
					cap.set_meta("s3", s3)
					cap.set_meta("side", side)
					add_child(cap)
					_capstans.append(cap)
					_bake_capstan(cap)
				1:
					var xz4 := _side_xz(s3, side, 0.9)
					var gr := Soldier.new(coat, "grease", "turban" if i % 2 == 0 else "bork")
					gr.set_meta("no_turn", true)      # kadırgadan geri sıçrarken yüzü kızağa dönük kalır
					_place_on_ground(gr, xz4.x, xz4.y)
					gr.face_toward(s_to_world(s3 + 1.0, 0.0))
					var pail := Node3D.new()
					Props.cyl(pail, 0.22, 0.35, Vector3(0, 0.18, 0), Color("6b4a2e"), Vector3.ZERO, 8)
					Props.cyl(pail, 0.2, 0.02, Vector3(0, 0.36, 0), Color("f0dc9a"), Vector3.ZERO, 8)
					var pxz := _side_xz(s3 - 0.8, side, 1.4)
					_place_on_ground(pail, pxz.x, pxz.y)
					# Kadırga geçerken kovasıyla geri sıçrar (_work_tick)
					var out_xz := _side_xz(s3, side, 2.1)
					_greasers.append({"sol": gr, "home": gr.position, "out": Vector3(out_xz.x, surface_h(out_xz.x, out_xz.y), out_xz.y),
						"s": s3, "away": false})
				_:
					# Takoz çakan (tur 3: eskiden kolları yarı açık, boşta bekleyen gözcü): yere yatırılmış kütüğün altına
					# tokmakla takoz çakar; kaçan yanından geçerken döner, gösterip bağırır; kadırga gelince kaçışır.
					var xz5 := _side_xz(s3, side, 1.6)
					var sol := Soldier.new(coat, "stand", "bork" if i % 2 == 0 else "turban")
					sol.set_meta("spk", "SPK_SOLDIER")       # "Çekil!", "Yakalayın!": kartta en yakın bağıran
					sol.set_meta("no_turn", true)
					_place_on_ground(sol, xz5.x, xz5.y)
					var tt := s_to_world(s3, side * (WIDTH / 2.0 + 0.6))
					sol.face_toward(Vector3(tt.x, sol.global_position.y, tt.z))
					sol.rig.activity = "hammer"
					var ml := _mallet(sol)
					var fwd5 := sol.global_basis.z.normalized()
					var wk := sol.global_position + fwd5 * 0.62
					wk.y = surface_h(wk.x, wk.z)
					var lgn := Props.cyl(self, 0.2, 1.8, wk + Vector3(0, 0.2, 0), C_LOG, Vector3(90, rad_to_deg(atan2(fwd5.x, fwd5.z)) + 90.0, 0), 8)
					lgn.rotation = Vector3(0, atan2(fwd5.x, fwd5.z), PI * 0.5)
					Props.prism(self, Vector3(0.22, 0.14, 0.2), wk + Vector3(0, 0.07, 0) - fwd5 * 0.18, Color("b08a5c"), Vector3(0, rad_to_deg(atan2(fwd5.x, fwd5.z)), 0))
					_spotters.append({"sol": sol, "blown": false, "rot": sol.global_rotation.y, "mallet": ml})
		# Öküz takımları: _build_crews (koşumlu, kütük kızağına bağlı; eskiden kutu öküzler boşta duruyordu)
		# Fıçılar, sandıklar, yağ kovaları, kütük yığınları
		for i in 12:
			var ps := rng.randf_range(4, LENGTH - 6)
			var pd := rng.randf_range(0.9, 3.0)
			# İş alanına (kızak yolu, halat ekibi, yoldan sıçrayanın ineceği yer) düşen eşya biraz öteye kayar
			if _reserved(ps, side, pd, 1.0):
				ps += -3.6 if not _reserved(ps - 3.6, side, pd, 1.0) else 3.6
			var xz5 := _side_xz(ps, side, pd)
			var prop := Node3D.new()
			match i % 4:
				0:
					Props.cyl(prop, 0.35, 0.8, Vector3(0, 0.4, 0), Color("7a5232"), Vector3.ZERO, 8)
					Props.cyl(prop, 0.37, 0.06, Vector3(0, 0.2, 0), Color("4a4d52"), Vector3.ZERO, 8)
					Props.cyl(prop, 0.37, 0.06, Vector3(0, 0.6, 0), Color("4a4d52"), Vector3.ZERO, 8)
				1:
					Props.box(prop, Vector3(0.8, 0.6, 0.6), Vector3(0, 0.3, 0), Color("a57a4e"))
					Props.box(prop, Vector3(0.6, 0.45, 0.5), Vector3(0.1, 0.82, 0), Color("b88c5c"), Vector3(0, 15, 0))
				2:
					Props.cyl(prop, 0.22, 0.35, Vector3(0, 0.18, 0), Color("2b2622"), Vector3.ZERO, 8)
					Props.cyl(prop, 0.2, 0.02, Vector3(0, 0.36, 0), Color("141210"), Vector3.ZERO, 8)
				3:
					for r in 3:
						for c in 3 - r:
							Props.cyl(prop, 0.2, 2.4, Vector3(-0.4 + c * 0.42 + r * 0.21, 0.2 + r * 0.36, 0), C_LOG, Vector3(90, 0, 0), 8)
			prop.rotation_degrees.y = rng.randf_range(0, 360)
			_place_on_ground(prop, xz5.x, xz5.y)
			Props.solid_model(prop, 0.9)      # fıçı, sandık, kova, kütük yığını: içinden yürünmesin
	# Irgat platformlarının çevresinde çiğnenmiş toprak halkası
	if not _deck_mud.is_empty():
		Nature._scatter_at(self, "mud", _deck_mud, 77, func(x: float, z: float) -> float: return surface_h(x, z))
		Nature._scatter_at(self, "footprint", _deck_mud.slice(0, _deck_mud.size() / 2), 78, func(x: float, z: float) -> float: return surface_h(x, z))
	_build_side_dressing()
	_build_work_stations()


## Yamaçlar boş kalmasın: yokuş boyunca iki yanda yağ kazanları (katran kaynatan ocaklar), çuval ve sandık
## yığınları, halat kangalları, arabalar, bağlı atlar, işçi kümeleri (tek birleşik ağ örgüsü).
func _build_side_dressing() -> void:
	var d := Dressing.new(1453)
	var rng := d.rng
	var jobs: Array = []          # Crowd öğeleri (iş başındaki figürler)
	var props := Node3D.new()     # işlerin nesneleri (kütük, fırça, kangal, kâğıt): tek ağa pişer
	add_child(props)
	var vig := 0
	for side in [-1, 1]:
		var s := 2.0
		while s < LENGTH - 4.0:
			var dist := rng.randf_range(3.2, 12.0)
			# Irgat kızağının yolu, öküz kızağı, halat ekipleri: küme oraya düşerse yamaçta biraz daha yukarı çıkar
			if _reserved(s, side, dist, 1.8):
				dist += 3.5
			# Yamacın en düz yeri (kümenin parçaları eğimde havada kalmasın): birkaç uzaklık denenir
			var best_d := dist
			var best_k := INF
			for dd: float in [dist, dist + 1.5, dist - 1.0, dist + 3.0]:
				if dd < 3.0 or _reserved(s, side, dd, 1.8):
					continue
				var q := _side_xz(s, side, dd)
				var k := _tilt(q.x, q.y).length()
				if k < best_k:
					best_k = k
					best_d = dd
			dist = best_d
			var xz := _side_xz(s, side, dist)
			var gp := Vector3(xz.x, surface_h(xz.x, xz.y), xz.y)
			var fy := rng.randf() * TAU
			# Kümenin çerçevesi arazinin eğimine yatar (tur 3): düz çerçevede kurulan sandık, kova, saman yokuş aşağı yanında
			# havada kalıyor ("gölgesi kaymış kutu"), yokuş yukarı yanında gömülüyordu
			var gr := _tilt(xz.x, xz.y)
			var nrm := Vector3(-gr.x, 1.0, -gr.y).normalized()
			var tb := Basis(Vector3.UP, fy)
			var ax := Vector3.UP.cross(nrm)
			if ax.length() > 0.001:
				tb = Basis(ax.normalized(), Vector3.UP.angle_to(nrm)) * tb
			d.at(gp, fy)
			d.set("_frame", Transform3D(tb, gp - nrm * 0.04))
			var to_track := Vector3(-side, 0, 0)
			match rng.randi() % 7:
				0:
					d.hearth(Vector3.ZERO)
					# Ocağın başında biri değnekle közü karıştırır, öbürü kucağında odunla gelir (tur 3: eskiden ikisi de
					# kolları yanda ateşe bakıyordu)
					var fc := gp
					var at1 := gp + Vector3(cos(fy), 0, -sin(fy)) * 0.95
					_job_stir(jobs, props, at1, fc, rng)
					var at2 := gp + Vector3(cos(fy + 2.4), 0, -sin(fy + 2.4)) * 1.7
					_job_carry(jobs, props, at2, (fc - at2).normalized(), "wood", rng)
				1: d._c_sacks()
				2: d._c_barrels()
				3:
					d.rope_coil(Vector3.ZERO)
					d.rope_coil(Vector3(0.8, 0, 0.3))
					d.crates(Vector3(0, 0, 1.0))
				4: d.cart(Vector3.ZERO)
				5:
					var hc := [Color("6a4028"), Color("3a2a1e"), Color("c8b8a0"), Color("8a5a38")]
					for k in 2:
						d.horse(Vector3(k * 1.3, 0, rng.randf_range(-0.3, 0.3)), hc[rng.randi() % hc.size()])
				_:
					# İş başında küçük ekip (eskiden üç asker yan yana, aynı duruşta, kollar yanda bekliyordu)
					var along := Vector3(0, 0, -1).rotated(Vector3.UP, rng.randf_range(-0.4, 0.4))
					match vig % 4:
						0:
							_job_log_pair(jobs, props, gp, along, rng)
						1:
							_job_grease(jobs, props, gp, to_track, rng)
						2:
							_job_carry(jobs, props, gp, to_track.rotated(Vector3.UP, 0.6), "coil", rng)
							_job_hammer(jobs, props, gp + along * 1.6 + to_track * 0.4, -to_track, rng)
						_:
							_job_report(jobs, props, gp, to_track, rng)
					vig += 1
			s += rng.randf_range(5.0, 9.0)
	_seat_instances(d.build(self))
	for c in Crowd.place(self, jobs, true, false):
		(c as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	Props.bake_static(props, props.get_children())


## Arazinin eğimi (x, z yönünde m/m), 1,4 m'lik açıklıkla.
func _tilt(x: float, z: float) -> Vector2:
	return Vector2((surface_h(x + 1.4, z) - surface_h(x - 1.4, z)) / 2.8, (surface_h(x, z + 1.4) - surface_h(x, z - 1.4)) / 2.8)


# ---------------------------------------------------------------- iş başındaki figürler (tur 3)
# Her figürün bir işi ve o işin nesnesi elinde: donmuş kalabalığın (Crowd) eli, pozun pişirildiği karedeki el noktasına
# göre ölçülür (_hands) ve nesne o noktaya konur. Yan yana iki kişi aynı pozda değil.

const JOB_COATS := {"carry": Color("2f5fa8"), "paint": Color("3f7a3a"), "stir": Color("b3262d"), "hammer": Color("c98a3a"),
	"chop": Color("7a5232"), "hold_paper": Color("3f7a3a"), "arms_folded": Color("b3262d"), "whittle": Color("2f5fa8")}
static var _hand_cache := {}


## Crowd figürünün (Soldier, poz pişmiş) iki eli ve dirsekleri, figürün yerelinde: [sol el, sağ el, sol dirsek, sağ dirsek].
func _hands(pose: String) -> Array:
	if _hand_cache.has(pose):
		return _hand_cache[pose]
	var sol := Soldier.new(Color.WHITE, "stand", "bork")
	sol.visible = false
	add_child(sol)
	if pose != "" and sol.rig:
		sol.rig.activity = pose
		for i in 60:
			sol.rig.update(0.1, false, false)
	var out: Array = []
	for el: Node3D in [sol.rig.elbow_l, sol.rig.elbow_r]:
		out.append(sol.to_local(el.to_global(el.get_meta("hand", Vector3(0, -0.26, 0.01)))))
	for el: Node3D in [sol.rig.elbow_l, sol.rig.elbow_r]:
		out.append(sol.to_local(el.global_position))
	remove_child(sol)
	sol.queue_free()
	_hand_cache[pose] = out
	return out


## Figür ekler: at (yerde), yüz yönü face; boy/kilo ölçeği; döndürür: figürün dönüşümü (eller bununla dünyaya çevrilir).
func _fig(jobs: Array, at: Vector3, face: Vector3, pose: String, rng: RandomNumberGenerator, hat := "") -> Transform3D:
	var p := Vector3(at.x, surface_h(at.x, at.z), at.z)
	var h := rng.randf_range(0.94, 1.06)
	var w := rng.randf_range(0.92, 1.15)
	var xf := Transform3D(Basis(Vector3.UP, atan2(face.x, face.z)) * Basis.from_scale(Vector3(w, h, w)), p)
	jobs.append([xf, {"side": "O", "coat": JOB_COATS.get(pose, Color("7a5232")), "hat": hat if hat != "" else ("turban" if pose in ["carry", "chop", "whittle"] else "bork"),
		"arm": "", "pose": pose}])
	return xf


## İki noktayı birleştiren çubuk (sap, kütük, değnek).
func _rod(parent: Node3D, a: Vector3, b: Vector3, r: float, col: Color, seg := 6) -> void:
	var d := b - a
	if d.length() < 0.01:
		return
	var mi := Props.cyl(parent, r, d.length(), (a + b) * 0.5, col, Vector3.ZERO, seg)
	var y := d.normalized()
	var x := y.cross(Vector3.UP if absf(y.y) < 0.95 else Vector3.RIGHT).normalized()
	mi.basis = Basis(x, y, x.cross(y))


## Kütüğü iki kişi önlerinde taşır: ikisi aynı yöne yürür, kütük dördünün elinde.
func _job_log_pair(jobs: Array, props: Node3D, at: Vector3, along: Vector3, rng: RandomNumberGenerator) -> void:
	var hd := _hands("carry")
	var side := Vector3.UP.cross(along).normalized()
	var x1 := _fig(jobs, at - along * 0.9, side, "carry", rng)
	var x2 := _fig(jobs, at + along * 0.9 + side * 0.1, side, "carry", rng)
	var c1: Vector3 = x1 * ((hd[0] + hd[1]) * 0.5)
	var c2: Vector3 = x2 * ((hd[0] + hd[1]) * 0.5)
	var dir := (c2 - c1).normalized()
	_rod(props, c1 - dir * 0.7, c2 + dir * 0.7, 0.17, C_LOG, 8)


## Sehpaya yatırılmış kütüğe kovadan fırçayla iç yağı sürer.
func _job_grease(jobs: Array, props: Node3D, at: Vector3, face: Vector3, rng: RandomNumberGenerator) -> void:
	var hd := _hands("paint")
	var xf := _fig(jobs, at, face, "paint", rng)
	var hand: Vector3 = xf * hd[1]
	var fwd := face.normalized()
	var side := Vector3.UP.cross(fwd).normalized()
	# Kütük elin önünde, fırçanın ucu kütüğün üstünde
	var top := hand + fwd * 0.28 + Vector3(0, -0.12, 0)
	var ly := top.y - 0.18
	var lc := Vector3(top.x, ly, top.z)
	_rod(props, lc - side * 1.1, lc + side * 1.1, 0.18, Color("7e5634"), 8)
	for k: float in [-0.75, 0.75]:
		var lp := lc + side * k
		var gy := surface_h(lp.x, lp.z)
		_rod(props, Vector3(lp.x, gy, lp.z) - fwd * 0.2, Vector3(lp.x, ly, lp.z), 0.04, Color("5f4329"), 5)
		_rod(props, Vector3(lp.x, gy, lp.z) + fwd * 0.2, Vector3(lp.x, ly, lp.z), 0.04, Color("5f4329"), 5)
	Props.box(props, Vector3(0.5, 0.012, 0.2), lc + Vector3(0, 0.175, 0) - side * 0.3, Color("e8cf7a"))
	_rod(props, hand - Vector3(0, 0.05, 0), top + Vector3(0, 0.03, 0), 0.015, Color("6a4a2c"), 5)
	Props.box(props, Vector3(0.09, 0.06, 0.05), top, Color("d8c090"))
	var bk := at - fwd * 0.1 + side * 0.55
	bk.y = surface_h(bk.x, bk.z)
	Props.cyl(props, 0.16, 0.3, bk + Vector3(0, 0.15, 0), Color("6b4a2e"), Vector3.ZERO, 8)
	Props.cyl(props, 0.145, 0.02, bk + Vector3(0, 0.29, 0), Color("e0c878"), Vector3.ZERO, 8)


## Ocağı / kazanı değnekle karıştırır (değnek elden közün içine).
func _job_stir(jobs: Array, props: Node3D, at: Vector3, fire: Vector3, rng: RandomNumberGenerator) -> void:
	var hd := _hands("stir")
	var face := fire - at
	face.y = 0.0
	var xf := _fig(jobs, at, face.normalized(), "stir", rng)
	var hand: Vector3 = xf * hd[1]
	var tip := Vector3(fire.x, surface_h(fire.x, fire.z) + 0.1, fire.z)
	_rod(props, hand + (hand - tip).normalized() * 0.15, tip, 0.017, Color("5a3e26"), 5)


## Kucağında yük taşır: "wood" (odun), "coil" (halat kangalı), "sack" (çuval).
func _job_carry(jobs: Array, props: Node3D, at: Vector3, face: Vector3, what: String, rng: RandomNumberGenerator) -> void:
	var hd := _hands("carry")
	var xf := _fig(jobs, at, face.normalized(), "carry", rng)
	var c: Vector3 = xf * ((hd[0] + hd[1]) * 0.5)
	var side: Vector3 = (xf * hd[1] - xf * hd[0])
	side = side.normalized() if side.length() > 0.02 else xf.basis.x.normalized()
	match what:
		"wood":
			for k in 3:
				var o := Vector3(0, 0.06 + k * 0.07, 0) + face.normalized() * (0.04 * (k - 1))
				_rod(props, c + o - side * 0.4, c + o + side * 0.4, 0.05, Color("6b4a2e").lerp(Color("8a6440"), k * 0.4), 6)
		"coil":
			Stage.rope_coil(props, c + Vector3(0, -0.02, 0) + face.normalized() * 0.08, 0.24, 4.0, 0.028, Color("b89a6a"))
		_:
			Props.ball(props, 0.26, c + Vector3(0, 0.12, 0), Color("c8b088"), Vector3(1.2, 0.8, 0.9), 7)


## Kütüğün altına tokmakla takoz çakar.
func _job_hammer(jobs: Array, props: Node3D, at: Vector3, face: Vector3, rng: RandomNumberGenerator) -> void:
	var hd := _hands("hammer")
	var xf := _fig(jobs, at, face.normalized(), "hammer", rng)
	var hand: Vector3 = xf * hd[1]
	var elbow: Vector3 = xf * hd[3]
	var fa := (hand - elbow).normalized()
	var fwd := face.normalized()
	var side := Vector3.UP.cross(fwd).normalized()
	# Tokmak: sap önkola dik, ileri; başı ucunda
	var hdir := (fwd - fa * fwd.dot(fa)).normalized()
	_rod(props, hand, hand + hdir * 0.42, 0.022, Color("6a4a2c"), 5)
	_rod(props, hand + hdir * 0.42 - fa * 0.12, hand + hdir * 0.42 + fa * 0.12, 0.075, Color("8a6440"), 8)
	var wk := at + fwd * 0.7
	wk.y = surface_h(wk.x, wk.z)
	_rod(props, wk - side * 0.9 + Vector3(0, 0.2, 0), wk + side * 0.9 + Vector3(0, 0.2, 0), 0.2, C_LOG, 8)
	Props.prism(props, Vector3(0.22, 0.14, 0.2), wk + Vector3(0, 0.07, 0) - fwd * 0.2, Color("b08a5c"), Vector3(0, rad_to_deg(atan2(fwd.x, fwd.z)), 0))


## Yere yatırılmış kütüğü baltayla yonar (balta elde, ağzı kütüğün üstünde).
func _job_chop(jobs: Array, props: Node3D, at: Vector3, face: Vector3, rng: RandomNumberGenerator) -> void:
	var hd := _hands("chop")
	var xf := _fig(jobs, at, face.normalized(), "chop", rng)
	var hand: Vector3 = xf * hd[1]
	var fwd := face.normalized()
	var side := Vector3.UP.cross(fwd).normalized()
	var wk := at + fwd * 0.75
	wk.y = surface_h(wk.x, wk.z)
	var top := wk + Vector3(0, 0.4, 0)
	_rod(props, wk - side * 1.0 + Vector3(0, 0.2, 0), wk + side * 1.0 + Vector3(0, 0.2, 0), 0.2, Color("7e5634"), 8)
	var hdir := (top - hand).normalized()
	var head := hand + hdir * minf(0.75, hand.distance_to(top))
	_rod(props, hand - hdir * 0.08, head, 0.02, Color("6a4a2c"), 5)
	var hb := Props.box(props, Vector3(0.03, 0.18, 0.2), head, Color("9aa0a8"))
	hb.basis = Basis.looking_at(hdir, Vector3.UP if absf(hdir.y) < 0.95 else Vector3.RIGHT)
	for i in 5:
		var ch := wk + side * rng.randf_range(-0.6, 0.6) + fwd * rng.randf_range(-0.5, 0.4)
		Props.box(props, Vector3(0.1, 0.015, 0.05), Vector3(ch.x, surface_h(ch.x, ch.z) + 0.01, ch.z), Color("d8c090"), Vector3(0, rng.randf() * 180.0, 0))


## Canlı asker soluklanır: elindeki testiden su içer, arada alnının terini siler (Rig "sip"/"facepalm"; _tick_track).
func _drinker(at: Vector3, face: Vector3) -> void:
	var sol := Soldier.new(Color("7a5232"), "stand", "turban")
	sol.set_meta("no_talk", true)
	sol.set_meta("no_turn", true)
	_place_on_ground(sol, at.x, at.z)
	sol.face_toward(sol.global_position + face.rotated(Vector3.UP, 0.7))
	var el: Node3D = sol.rig.elbow_r if sol.rig else null
	if el:
		var jug := Node3D.new()
		el.add_child(jug)
		jug.position = el.get_meta("hand", Vector3(0, -0.26, 0.01)) + Vector3(0, -0.05, 0.05)
		Props.cyl(jug, 0.09, 0.22, Vector3(0, 0, 0), Color("b86a3a"), Vector3.ZERO, 8, 0.07)
		Props.cyl(jug, 0.035, 0.08, Vector3(0, 0.14, 0), Color("a85e32"), Vector3.ZERO, 6)
	_drinkers.append({"sol": sol, "t": randf_range(0.5, 3.0), "k": 0})


var _drinkers: Array = []


## Onbaşıya rapor: biri kâğıdı okur, onbaşı (kızıl börklü) kollarını kavuşturup dinler.
func _job_report(jobs: Array, props: Node3D, at: Vector3, face: Vector3, rng: RandomNumberGenerator) -> void:
	var side := Vector3.UP.cross(face.normalized()).normalized()
	var a1 := at - side * 0.55
	var a2 := at + side * 0.55
	var hd := _hands("hold_paper")
	var xf := _fig(jobs, a1, (a2 - a1).normalized(), "hold_paper", rng)
	_fig(jobs, a2, (a1 - a2).normalized(), "arms_folded", rng, "azap")
	var c: Vector3 = xf * ((hd[0] + hd[1]) * 0.5)
	var b := Basis.looking_at((a2 - a1).normalized() + Vector3(0, 0.9, 0), Vector3.UP)
	var mi := Props.box(props, Vector3(0.26, 0.34, 0.006), c + (a2 - a1).normalized() * 0.03, Color("efe6cf"))
	mi.basis = b


## Dressing kümesi düz bir çerçevede kurulur: yamaçta kümenin kenarındaki sandık, figür 0,3-1 m havada ya da gömülü
## kalıyordu. Her çoklu ağ örneği (üst üste yığılanlar birlikte) altındaki görünen araziye oturur.
func _seat_instances(root: Node) -> void:
	if root == null:
		return
	for c in root.find_children("*", "MultiMeshInstance3D", true, false):
		var mmi := c as MultiMeshInstance3D
		if mmi.multimesh == null:
			continue
		var n := mmi.multimesh.instance_count
		var xfs: Array = []
		for i in n:
			xfs.append(WorldWalk.inst_xf(mmi, i))
		# Yığınlar: yatayda 0,6 m'den yakın örnekler birlikte kayar (en alttakine göre)
		var done := {}
		for i in n:
			if done.has(i):
				continue
			var grp := [i]
			for j in range(i + 1, n):
				var a: Vector3 = (xfs[i] as Transform3D).origin
				var b: Vector3 = (xfs[j] as Transform3D).origin
				if not done.has(j) and Vector2(a.x - b.x, a.z - b.z).length() < 0.6:
					grp.append(j)
			var low := INF
			var shift := 0.0
			for k: int in grp:
				done[k] = true
				var w := mmi.global_transform * (xfs[k] as Transform3D).origin
				var lp := to_local(w)
				if lp.y < low:
					low = lp.y
					shift = surface_h(lp.x, lp.z) - lp.y
			if absf(shift) < 0.04 or absf(shift) > 3.0:
				continue
			for k: int in grp:
				var xf: Transform3D = xfs[k]
				xf.origin += mmi.global_transform.basis.inverse() * Vector3(0, shift, 0)
				xfs[k] = xf
				mmi.multimesh.set_instance_transform(k, xf)
		if mmi.has_meta("xforms"):
			mmi.set_meta("xforms", xfs)


## Yolun hemen kenarında, koşu yönünde görülen iş başındaki askerler (eskiden iş kümeleri yoldan 3-12 m yanda kalıyor,
## koşan oyuncu ayrıntı göremiyordu): yağ kazanını karıştıran, kütük taşıyan, takoz çakan, balta vuran, kollarını kavuşturup
## bekleyen; boyları, kiloları, kaftan renkleri farklı. Yanlarında işin aleti: kazan ve kovalar, kütük yığını, tezgâh ve
## talaş. Donmuş kalabalık (Crowd: tek çoklu ağ / tür) + birleşik eşya ağı.
func _build_work_stations() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4221
	var items: Array = []
	var props := Node3D.new()
	add_child(props)
	var s := 9.0
	var k := 0
	while s < LENGTH - 6.0:
		var side := -1 if k % 2 == 0 else 1
		var dist := rng.randf_range(1.0, 1.8)
		var near_live := false
		for i in 9:
			if i % 3 != 0 and absf(s - (6.0 + i * 13.0)) < 2.8:
				near_live = true      # yağcı ve gözcü (canlı askerler) burada
		if near_live or _reserved(s, side, dist, 1.4) or _reserved(s + 1.5, side, dist, 1.4):
			s += 2.5
			continue
		var c := _side_xz(s, side, dist)
		var gp := Vector3(c.x, surface_h(c.x, c.y), c.y)
		var to_track := Vector3(-side, 0, 0)
		var along := Vector3(0, 0, -1)
		var kind := k % 4
		match kind:
			0:
				# Yağ kazanı: üç taşın üstünde kara kazan, içi sarı iç yağı, altında kor; iki kova
				var kz := gp + along * 0.6
				for a in 3:
					var ang := TAU * a / 3.0
					Props.ball(props, 0.16, kz + Vector3(cos(ang) * 0.32, 0.08, sin(ang) * 0.32), Color("6e6a62"), Vector3(1, 0.7, 1), 6)
				Props.cyl(props, 0.34, 0.42, kz + Vector3(0, 0.38, 0), Color("2a2622"), Vector3.ZERO, 10, 0.4)
				Props.cyl(props, 0.33, 0.03, kz + Vector3(0, 0.6, 0), Color("e8cf7a"), Vector3.ZERO, 10)
				Props.box(props, Vector3(0.36, 0.08, 0.36), kz + Vector3(0, 0.07, 0), Color("c4521e"), Vector3(0, 30, 0))
				for b in 2:
					var bp := gp + along * (-0.5 - b * 0.45) + to_track * 0.3
					Props.cyl(props, 0.17, 0.3, bp + Vector3(0, 0.15, 0), Color("6b4a2e"), Vector3.ZERO, 8)
					Props.cyl(props, 0.15, 0.02, bp + Vector3(0, 0.29, 0), Color("e0c878"), Vector3.ZERO, 8)
				# Biri kazanı kürekle karıştırır, öbürü kovayla iç yağı taşır (tur 3: eskiden kollar kavuşuk bekliyordu)
				_job_stir(items, props, kz - to_track * 0.6, kz, rng)
				_job_carry(items, props, gp - along * 1.3 - to_track * 0.5, along, "sack", rng)
			1:
				# Kütük yığını: ikisi bir kütüğü birlikte taşır, biri baltayla yonar
				for r in 2:
					for cc in 2 - r:
						Props.cyl(props, 0.18, 2.2, gp + along * 0.2 + to_track * (-0.3 + cc * 0.37 + r * 0.18) + Vector3(0, 0.18 + r * 0.32, 0), C_LOG, Vector3(90, 0, 0), 8)
				_job_log_pair(items, props, gp - along * 1.6 - to_track * 0.9, along, rng)
				_job_chop(items, props, gp + along * 1.7 - to_track * 0.7, to_track, rng)
			2:
				# Takoz tezgâhı: iki sehpanın üstünde kalas, yanında takoz yığını; tokmakla takoz çakan
				for z: float in [-0.5, 0.5]:
					var sp := gp + along * z - to_track * 0.3
					Props.box(props, Vector3(0.08, 0.6, 0.5), sp + Vector3(0, 0.3, 0), Color("5f4329"), Vector3(0, 0, 12))
				Props.box(props, Vector3(0.4, 0.08, 1.5), gp - to_track * 0.3 + Vector3(0, 0.64, 0), Color("b08a5c"))
				for t in 4:
					Props.prism(props, Vector3(0.26, 0.14, 0.22), gp + along * 0.9 + Vector3(t * 0.12, 0.07 + (t % 2) * 0.14, 0), Color("8a6440"), Vector3(0, 90, 0))
				_job_hammer(items, props, gp - to_track * 1.6 + along * 1.2, to_track, rng)
			_:
				# Soluklanan: testiden su içer, alnının terini siler (canlı asker); ya da onbaşıya rapor
				if (k / 4) % 2 == 0:
					_drinker(gp - to_track * 0.6 + along * 0.4, to_track)
					Props.ball(props, 0.22, gp + along * 0.4 + Vector3(0, 0.15, 0), Color("c8b088"), Vector3(1, 0.7, 1), 7)
				else:
					_job_report(items, props, gp - to_track * 0.7, to_track, rng)
		s += rng.randf_range(6.0, 9.0)
		k += 1
	for c in Crowd.place(self, items, true, false):
		(c as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF      # gölge geçişi bütçesi
	Props.bake_static(props, props.get_children())


var _deck_mud: Array = []


## Tokmak: sağ elde, sapı önkolu sürdürür, başı ucunda (takoz çakan).
func _mallet(sol: Soldier) -> Node3D:
	var el: Node3D = sol.rig.elbow_r if sol.rig else null
	if el == null:
		return null
	var g := Node3D.new()
	el.add_child(g)
	g.position = el.get_meta("hand", Vector3(0, -0.26, 0.01))
	g.rotation_degrees = Vector3(90, 0, 0)
	Props.cyl(g, 0.022, 0.5, Vector3(0, 0.2, 0), Color("6a4a2c"), Vector3.ZERO, 5)
	Props.cyl(g, 0.08, 0.24, Vector3(0, 0.44, 0), Color("8a6440"), Vector3(90, 0, 0), 8)
	return g


func _cypress(parent: Node3D, h: float) -> void:
	Props.cyl(parent, 0.14, 0.9, Vector3(0, 0.45, 0), Color("5a3a24"), Vector3.ZERO, 6)
	Props.cyl(parent, 0.62, h, Vector3(0, 0.8 + h / 2.0, 0), Color("2f5a2c"), Vector3.ZERO, 7, 0.06)
	Props.cyl(parent, 0.5, h * 0.55, Vector3(0.05, 0.9 + h * 0.28, 0.05), Color("3a6a34"), Vector3.ZERO, 7, 0.2)


## Ordu çadırı: yuvarlak gövde, renkli kuşak, sivri dam, kapı (Scenery.tent_mesh). Eskiden düz beyaz prizma: yamaçta
## yandan bakınca havada asılı beyaz bir levha gibi okunuyordu.
func _tent(parent: Node3D, red: bool) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = Scenery.tent_mesh(Color("b3262d") if red else Color("2f6a9a"))
	if _tent_mat == null:
		_tent_mat = Props.mat(Color.WHITE).duplicate() as StandardMaterial3D
		_tent_mat.vertex_color_use_as_albedo = true
	mi.material_override = _tent_mat
	mi.scale = Vector3(1.35, 1.25, 1.35)
	parent.add_child(mi)
	Props.box(parent, Vector3(0.5, 0.3, 0.02), Vector3(0.25, 4.45, 0), Color("b3262d"))
	Props.cyl(parent, 0.025, 0.7, Vector3(0, 4.3, 0), Color("4a3020"), Vector3.ZERO, 4)


var _tent_mat: StandardMaterial3D


## Irgat: dikme makara, dört itme kolu ve kolları iterek dönen dört asker ("Turn" döner).
func _capstan(coat: Color) -> Node3D:
	var root := Node3D.new()
	Props.cyl(root, 0.5, 0.12, Vector3(0, 0.06, 0), Color("6f5a3e"), Vector3.ZERO, 10)
	var turn := Node3D.new()
	turn.name = "Turn"
	root.add_child(turn)
	Props.cyl(turn, 0.28, 1.1, Vector3(0, 0.6, 0), Color("7a5232"), Vector3.ZERO, 10)
	Props.cyl(turn, 0.3, 0.25, Vector3(0, 0.55, 0), Color("c9b48a"), Vector3.ZERO, 10)
	# Makaraya sarılan halatın turları (halat buradan kızağa iner)
	for k in 3:
		Props.ring(turn, 0.29, 0.35, Vector3(0, 0.45 + k * 0.08, 0), Color("b89a6a"))
	for k in 4:
		var a := k * PI / 2.0
		var d := Vector3(sin(a), 0, cos(a))
		var bar := Props.cyl(turn, 0.045, 1.5, d * 0.95 + Vector3(0, 1.0, 0), Color("8a6440"), Vector3.ZERO, 6)
		bar.basis = Basis(Vector3.UP.cross(d).normalized(), PI / 2.0)
		var t := Vector3(cos(a), 0, -sin(a))
		var sol := Soldier.new(coat if k % 2 == 0 else coat.darkened(0.25), "push", "bork" if k % 2 == 0 else "turban")
		sol.position = d * 1.45 - t * 0.55
		sol.rotation.y = atan2(t.x, t.z)
		sol.set_meta("no_unclip", true)
		turn.add_child(sol)
	return root


## Irgatın dönen makarası ve kolları tek ağa (askerler hariç): kurulup ağaca girdikten sonra çağrılır.
func _bake_capstan(cap: Node3D) -> void:
	var turn := cap.get_node("Turn") as Node3D
	Props.bake_static(turn, turn.get_children().filter(func(c): return not (c is Soldier)))


# ---------------------------------------------------------------- kadırga

## Kadırganın gövdesi enine ve dikine bu kadar büyük (boyu aynı: BOW ve yakalanma hesabı değişmez). Açılışta kadırga
## yokuşun tepesinde küçücük görünüyordu, "üstüme geliyor" tehdidi okunmuyordu.
const SHIP_K := 1.7


## Gövde çerçevesinden (ölçekli) kadırganın kendi çerçevesine.
func _sk(v: Vector3) -> Vector3:
	return Vector3(v.x * SHIP_K, v.y * SHIP_K, v.z)


func _build_ship() -> void:
	ship = Node3D.new()
	track.add_child(ship)
	var body := Node3D.new()
	body.scale = Vector3(SHIP_K, SHIP_K, 1.0)
	ship.add_child(body)
	_ship_body = body
	var hull := LowPoly.hull([
		{"z": -9.6, "w": 0.06, "top": 2.5, "bottom": 1.5},
		{"z": -8.0, "w": 0.9, "top": 2.15, "bottom": 0.55},
		{"z": -5.0, "w": 1.5, "top": 1.95, "bottom": 0.28},
		{"z": 0.0, "w": 1.72, "top": 1.9, "bottom": 0.22},
		{"z": 4.0, "w": 1.62, "top": 1.95, "bottom": 0.28},
		{"z": 6.5, "w": 1.3, "top": 2.35, "bottom": 0.55},
		{"z": 7.7, "w": 0.85, "top": 2.9, "bottom": 1.1},
	], Color("5b3a22"), Color("7e2420"), 1.78)
	body.add_child(hull)
	# Güverte, kıç köşkü, küpeşte bandı ve küpeşte üstünde boyalı kalkanlar
	Props.box(body, Vector3(2.9, 0.1, 12.0), Vector3(0, 1.85, -0.6), Color("b08a5c"))
	Props.box(body, Vector3(2.3, 0.8, 2.0), Vector3(0, 2.3, 5.8), Color("6b4428"))
	Props.box(body, Vector3(2.5, 0.12, 2.2), Vector3(0, 2.76, 5.8), Color("c9a24a"))
	for side: float in [-1.0, 1.0]:
		Props.box(body, Vector3(0.08, 0.22, 11.0), Vector3(side * 1.55, 2.02, -0.8), Color("c9a24a"))
		for i in 6:
			var shc: Color = [Color("b3262d"), Color("e8d27a"), Color("2f5fa8")][i % 3]
			Props.cyl(body, 0.19, 0.04, Vector3(side * 1.6, 2.12, -4.6 + i * 1.6), shc, Vector3(0, 0, 90), 10)
	Props.ball(body, 0.18, Vector3(0, 3.35, 7.2), Color("ffcf6a"), Vector3.ONE, 8, 2.5)
	Props.cyl(body, 0.04, 0.5, Vector3(0, 3.05, 7.2), Color("3a2a1a"), Vector3.ZERO, 4)
	# Mahmuz yok (tur 3): pruvadan öne uzanan koyu sopa (sonda: gövdenin "Mahmuz" silindiri; kameraya doğru uzandığı
	# için yandan bakınca gövdeden yana/yukarı fırlamış, havada asılı bir çubuk gibi görünüyordu) kaldırıldı. Kalın
	# gaga denemesi de yakından boynuz gibi okundu. Pruva bodosu yalnız tunç bir başlıkla biter.
	Props.cyl(body, 0.09, 0.22, Vector3(0, 2.5, -9.58), Color("b8862e"), Vector3.ZERO, 6, 0.04)
	# Kürekler içeri alınmış: karada çekilen kadırgada kürekler güverteye yatırılır, iki demet hâlinde bağlanır. Eskiden
	# borda dışına fırlayan 20 çubuk uzaktan kafes/V, yakından yerden çıkan sopalar gibi görünüyordu; bordanın dışında
	# artık hiçbir şey yok.
	for side: float in [-1.0, 1.0]:
		var bx := side * 0.78
		for i in 9:
			var row := i % 3
			var lay := i / 3
			var ox := bx + (row - 1) * 0.1 + lay * 0.05 * side
			var oy := 1.95 + lay * 0.085
			Props.cyl(body, 0.045, 7.2, Vector3(ox, oy, -1.6 + (i % 2) * 0.3), Color("c9a878"), Vector3(90, 0, 0), 5)
			Props.box(body, Vector3(0.2, 0.035, 0.75), Vector3(ox, oy, -5.4 + (i % 2) * 0.3), Color("b8946a"))
		for z: float in [-3.6, -0.6, 1.6]:
			Props.cyl(body, 0.2, 0.07, Vector3(bx, 2.03, z), Color("8a7048"), Vector3(90, 0, 0), 8)
	# Direk, latin yelkenin çubuğu ve sarılı yelken, bayraklar (direk tepesinde uzun flama)
	# Yüksek direk (açılışta tepede küçük görünüyordu): direk 12,5 m, gözcü sepeti, çubuk ve sarılı yelken
	Props.cyl(body, 0.16, 12.5, Vector3(0, 8.0, -1.5), Color("6b4428"), Vector3.ZERO, 6)
	Props.cyl(body, 0.32, 0.45, Vector3(0, 12.2, -1.5), Color("7a5232"), Vector3.ZERO, 8, 0.36)
	Props.cyl(body, 0.08, 12.0, Vector3(0, 10.4, -1.8), Color("6b4428"), Vector3(55, 0, 0), 6)
	Props.cyl(body, 0.26, 8.6, Vector3(0, 10.2, -1.6), Color("efe6cf"), Vector3(55, 0, 0), 7)
	Props.box(body, Vector3(0.05, 0.9, 1.8), Vector3(0, 14.6, -1.3), Color("b3262d"))
	Props.box(body, Vector3(0.04, 0.34, 3.4), Vector3(0, 14.5, 1.1), Color("b3262d"))
	# Pruva bodosunda ikinci bayrak
	Props.cyl(body, 0.03, 1.4, Vector3(0, 3.1, -9.2), Color("3a2a1a"), Vector3.ZERO, 4)
	Props.box(body, Vector3(0.04, 0.42, 0.7), Vector3(0, 3.6, -8.88), Color("2f5fa8"))
	Props.box(body, Vector3(0.05, 0.5, 0.9), Vector3(0, 3.6, 6.4), Color("b3262d"))
	Props.cyl(body, 0.03, 1.0, Vector3(0, 3.2, 6.8), Color("3a2a1a"), Vector3.ZERO, 4)
	# Kızak kütükleri
	for i in 5:
		Props.cyl(body, 0.2, 4.0, Vector3(0, 0.2, -6.0 + i * 3.0), C_LOG, Vector3(0, 0, 90), 8)
	# Kıçta fren babaları (kalın, tepesi geniş): yokuşun başındaki kazıklara giden iki fren halatı bunlara volta edilir
	for sx: float in [-0.62, 0.62]:
		Props.cyl(body, 0.08, 0.4, Vector3(sx, 3.05, 7.25), Color("4a3422"), Vector3.ZERO, 6)
		Props.cyl(body, 0.11, 0.06, Vector3(sx, 3.27, 7.25), Color("3a2a1a"), Vector3.ZERO, 6)
	# Bütün gövde tek ağ (kadırgayla birlikte kayar): ~90 parça, eskiden her biri ayrı çizim
	Props.bake_static(body, body.get_children())
	# Güvertede bağıran tayfalar
	for p in [Vector3(0.6, 1.9, -5.5), Vector3(-0.7, 1.9, -2.5)]:
		var crew := Soldier.new(Color("2f5fa8"), "point", "turban")
		crew.position = _sk(p)
		crew.rotation_degrees.y = 180
		ship.add_child(crew)
	# Kürek demetinin üstünde oturan tayfa: kadırga yokuştan inerken bacakları sallanır (komik ama okunur)
	var sitter := Soldier.new(Color("c98a3a"), "stand", "turban")
	sitter.set_meta("no_talk", true)
	sitter.set_meta("no_turn", true)
	sitter.set_meta("no_unclip", true)
	sitter.position = _sk(Vector3(0.78, 2.2, 0.6)) + Vector3(0, -0.48, 0)
	sitter.rotation.y = PI * 0.5
	ship.add_child(sitter)
	sitter.rig.activity = "sit"
	# Kıç güvertesinde davulcu: çekenlere tempo tutar (tokmak davulun yüzüne iner: DrumBeat)
	var drummer := Soldier.new(Color("b3262d"), "stand", "bork")
	drummer.set_meta("no_talk", true)
	drummer.position = _sk(Vector3(0.75, 1.9, 3.6))
	ship.add_child(drummer)
	drummer.rotation_degrees.y = 180
	DrumBeat.attach(drummer, Color("c8a070"))
	# Kıçtan iten üç asker: elleri kıç aynasında, ayakları kızakta (öne yatık, öndeki diz bükük, arkadaki bacak gergin;
	# her karede tabanlar kızağa oturur: Stage.plant_feet). Kadırga kayınca onunla koşar.
	for k in 3:
		var px := -0.6 + k * 0.6
		var pu := Soldier.new([Color("3f7a3a"), Color("c98a3a"), Color("7a5232")][k], "push", "turban")
		pu.set_meta("no_talk", true)
		pu.set_meta("no_turn", true)
		pu.position = Vector3(px, 0.0, 8.32)
		pu.rotation.y = PI
		ship.add_child(pu)
		_pushers.append(pu)
		var gy := 1.97 + k * 0.07       # kıç aynasının alt kenarının hemen üstü (gövde 1,7 kat: ayna 1,87 m'den başlar)
		_grips.append({"who": pu, "frame": ship, "pts": [Vector3(px - 0.2, gy, 7.75), Vector3(px + 0.2, gy, 7.75)]})
	# Kalabalık güverte: mızraklı askerler borda boyunca, ortada el çırpıp tempo tutanlar (donmuş kalabalık: tek çoklu ağ)
	var deck: Array = []
	var dy := _sk(Vector3(0, 1.9, 0)).y
	for i in 12:
		var z := -7.2 + i * 1.05
		if absf(z - 3.6) < 0.8 or absf(z + 5.5) < 0.6 or absf(z + 2.5) < 0.6 or absf(z - 0.6) < 0.7:
			continue
		var x := (2.05 if i % 2 == 0 else -2.05) + (0.12 if i % 3 == 0 else -0.08)
		# Gövde pruvaya doğru daralır: asker küpeştenin içinde kalsın (pruvadakiler bordanın dışında havada duruyordu)
		var hw := 1.72
		var prof := [[-9.6, 0.06], [-8.0, 0.9], [-5.0, 1.5], [0.0, 1.72], [4.0, 1.62], [6.5, 1.3], [7.7, 0.85]]
		for pi in prof.size() - 1:
			if z >= float(prof[pi][0]) and z <= float(prof[pi + 1][0]):
				hw = lerpf(float(prof[pi][1]), float(prof[pi + 1][1]), (z - float(prof[pi][0])) / (float(prof[pi + 1][0]) - float(prof[pi][0])))
		x = signf(x) * minf(absf(x), hw * SHIP_K - 0.5)
		var spear := i % 3 != 1
		var c: Color = [Color("b3262d"), Color("2f5fa8"), Color("3f7a3a"), Color("c98a3a")][i % 4]
		deck.append([Transform3D(Basis(Vector3.UP, PI + (0.25 if x > 0.0 else -0.25)), Vector3(x, dy, z)),
			{"side": "O", "coat": c, "hat": "bork" if i % 2 == 0 else "turban", "arm": "spear" if spear else "", "pose": "" if spear else "clap"}])
	for c in Crowd.place(ship, deck, true, false):
		(c as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Pruvanın önünde kızakta yuvarlanan iki kütük (kadırga onların üstüne biner; dönüşleri _tick_ship'te)
	for z: float in [-10.6, -12.3]:
		var lg := Node3D.new()
		ship.add_child(lg)
		lg.position = Vector3(0, 0.3, z)
		Props.cyl(lg, 0.3, 6.4, Vector3.ZERO, Color("8a5e38"), Vector3(0, 0, 90), 9)
		for sx: float in [-3.2, 3.2]:
			Props.cyl(lg, 0.24, 0.03, Vector3(sx, 0, 0), Color("d8b98a"), Vector3(0, 0, 90), 9)
		Props.box(lg, Vector3(0.08, 0.05, 0.5), Vector3(1.2, 0.29, 0), Color("6a4c2c"))
		Props.bake_static(lg, lg.get_children())
		_bow_logs.append(lg)
	# Kızağın üstünde pruvanın ve kızak kütüklerinin kaldırdığı toz (kadırga kayarken): küçük, yumuşak pufçuklar
	_ship_dust = Vfx.dust_trail(ship, Vector3(0, 0.25, -9.5), Vector3(3.0, 0.15, 1.2))
	# Sahte uzun gölge: kadırganın gölgesi yokuş aşağı, yola ve önündeki kaçanın önüne düşer (gerçek gölge sabah güneşinin
	# açısı yüzünden yanda kalıyor; güneşi çevirmek gölge geçişini iki katına çıkarıyordu). Kızağa yapışık, kenarı yumuşak
	# tek ağ; kadırgayla ilerler, kızağın ucuna yaklaşınca kısalır (suyun üstünde asılı kalmaz).
	_ship_shadow = MeshInstance3D.new()
	_ship_shadow.mesh = _shadow_mesh()
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.06, 0.05, 0.09, 0.58)
	sm.vertex_color_use_as_albedo = true
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	sm.cull_mode = BaseMaterial3D.CULL_DISABLED
	_ship_shadow.material_override = sm
	_ship_shadow_mat = sm
	_ship_shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ship_shadow.set_meta("no_walk", true)
	_ship_shadow.set_meta("soft", true)
	_ship_shadow.position = Vector3(0, 0.37, -9.0)
	ship.add_child(_ship_shadow)
	_build_rollers()


## Kaçanla kadırga arasındaki uzaklık (Chapter2 her karede yazar; 99: kovalama yok)
var chase_gap := 99.0
var _rollers: Array = []          # [{n, s, x, r, on}]
var _roll_t := 1.5


## Kadırganın önünden kopup kaçanı geçen kütük ve fıçılar (görüntü; çarpışmasız, şeritlerin arasında ve kenarda):
## kovalama yakınken arada bir pruvanın önünden fırlar, oyuncudan hızlı yuvarlanır, toz kaldırır, ileride kaybolur.
func _build_rollers() -> void:
	for k in 3:
		var n := Node3D.new()
		track.add_child(n)
		var r := 0.22 if k != 1 else 0.33
		if k == 1:
			Props.cyl(n, 0.33, 0.8, Vector3.ZERO, Color("7a5232"), Vector3(0, 0, 90), 10)
			for hx: float in [-0.25, 0.25]:
				Props.cyl(n, 0.345, 0.05, Vector3(hx, 0, 0), Color("4a4d52"), Vector3(0, 0, 90), 10)
		else:
			Props.cyl(n, 0.22, 1.3, Vector3.ZERO, Color("8a5e38"), Vector3(0, 0, 90), 8)
			for sx: float in [-0.65, 0.65]:
				Props.cyl(n, 0.17, 0.02, Vector3(sx, 0, 0), Color("d8b98a"), Vector3(0, 0, 90), 8)
		Props.bake_static(n, n.get_children())
		for c in n.get_children():
			if c is GeometryInstance3D:
				(c as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		n.visible = false
		_rollers.append({"n": n, "s": 0.0, "x": 0.0, "r": r, "on": false, "dust": 0.0})


func _tick_rollers(delta: float, cam_s: float, bow: float) -> void:
	if _rollers.is_empty():
		return
	_roll_t -= delta
	if _roll_t <= 0.0 and chase_gap < 12.0 and _ship_v > 3.0 and bow < LENGTH - 25.0:
		_roll_t = randf_range(2.2, 3.6)
		for rl: Dictionary in _rollers:
			if not rl["on"]:
				rl["on"] = true
				rl["s"] = bow + 0.6
				rl["x"] = [-3.75, 3.75, -1.2, 1.2].pick_random()
				(rl["n"] as Node3D).visible = true
				Audio.sfx_at("land_thud", rl["n"], -12.0)
				break
	for rl: Dictionary in _rollers:
		if not rl["on"]:
			continue
		var n: Node3D = rl["n"]
		var r: float = rl["r"]
		rl["s"] = float(rl["s"]) + 10.5 * delta
		var sv: float = rl["s"]
		n.position = Vector3(float(rl["x"]), r + 0.12 + absf(sin(sv * 1.25)) * 0.14, -sv)
		n.rotation.x -= 10.5 * delta / r
		rl["dust"] = float(rl["dust"]) - delta
		if float(rl["dust"]) <= 0.0:
			rl["dust"] = 0.35
			Vfx.dust_puff(self, n.global_position + Vector3(0, -r, 0), 0.7)
		if sv > cam_s + 28.0 or sv > LENGTH - 1.5:
			rl["on"] = false
			n.visible = false


var _bow_logs: Array[Node3D] = []
var _ship_dust: CPUParticles3D
var _ship_shadow: MeshInstance3D
var _ship_shadow_mat: StandardMaterial3D
const SHADOW_LEN := 34.0


## Kadırganın yokuş aşağı düşen gölgesi (yerel -z ileri, 0'dan -SHADOW_LEN'e): gövdenin geniş gölgesi sivrilerek uzar,
## ardından direğin ve yelken çubuğunun ince uzun gölgesi; kenarlar köşe rengiyle saydamlaşır.
func _shadow_mesh() -> ArrayMesh:
	# Kadırganın siluetine benzer (tur 4): pruvanın sivri gölgesi, ince direk gölgeleri, yelken çubuğu ve yelken. Her parça
	# dışa doğru saydamlaşan 0,9-1,2 m'lik tüy kenarlı (sert şerit yok); parçalar birbirinin üstüne binmez.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Pruva: kıçtan (kızağa gömülü) sivri uca; uç yokuş aşağı
	_feather(st, [Vector2(0.0, -9.0), Vector2(0.9, -7.0), Vector2(1.8, -4.0), Vector2(2.4, -0.5), Vector2(2.4, 3.0),
		Vector2(-2.4, 3.0), Vector2(-2.4, -0.5), Vector2(-1.8, -4.0), Vector2(-0.9, -7.0)], 1.0, 0.9)
	# Ana direk: uzun, ince, uca doğru incelir
	_feather(st, [Vector2(0.3, -9.4), Vector2(0.22, -22.0), Vector2(0.1, -SHADOW_LEN), Vector2(-0.1, -SHADOW_LEN), Vector2(-0.22, -22.0),
		Vector2(-0.3, -9.4)], 0.55, 0.85)
	# Yelken çubuğu ve sarılı yelken: direğin ortasında enine, hafif eğik
	_feather(st, [Vector2(3.3, -14.2), Vector2(3.5, -15.4), Vector2(-3.0, -21.2), Vector2(-3.4, -19.8)], 0.8, 0.55)
	# Küçük ikinci direk ve çubuğu (pruvaya yakın)
	_feather(st, [Vector2(1.1, -9.8), Vector2(1.05, -16.0), Vector2(0.85, -16.0), Vector2(0.9, -9.8)], 0.35, 0.5)
	return st.commit()


## Dışbükey çokgen çekirdek (alfa a) ve çevresinde tüy kenar (f m, alfa 0): köşe rengiyle yumuşak gölge parçası.
static func _feather(st: SurfaceTool, ring: Array, f: float, a: float) -> void:
	var n := ring.size()
	var c := Vector2.ZERO
	for p: Vector2 in ring:
		c += p
	c /= n
	var outer: Array[Vector2] = []
	for i in n:
		var p0: Vector2 = ring[(i + n - 1) % n]
		var p1: Vector2 = ring[i]
		var p2: Vector2 = ring[(i + 1) % n]
		var n1 := (p1 - p0).normalized()
		var n2 := (p2 - p1).normalized()
		var out := Vector2(n1.y, -n1.x) + Vector2(n2.y, -n2.x)
		if out.dot(p1 - c) < 0.0:
			out = -out
		outer.append(p1 + out.normalized() * f)
	var on := Color(1, 1, 1, a)
	var off := Color(1, 1, 1, 0)
	var v3 := func(p: Vector2) -> Vector3: return Vector3(p.x, 0.0, p.y)
	for i in n:
		var j := (i + 1) % n
		for v: Array in [[c, on], [ring[i], on], [ring[j], on], [ring[i], on], [outer[i], off], [ring[j], on], [ring[j], on], [outer[i], off], [outer[j], off]]:
			st.set_color(v[1])
			st.set_normal(Vector3.UP)
			st.add_vertex(v3.call(v[0]))


var _ship_body: Node3D


## Kızak düzleminin (track yerel y = 0) dünya yüksekliği: kıçtan itenlerin tabanı buraya basar.
func track_y(x: float, z: float) -> float:
	var n := track.global_basis.y.normalized()
	var o := track.global_position
	return o.y - (n.x * (x - o.x) + n.z * (z - o.z)) / n.y


func set_ship_s(s: float) -> void:
	ship.position = Vector3(0, 0.0, -s)
	if _haul == null and ship.is_inside_tree():
		_start_haul()


## Arkadan gelen kadırganın sesi (geminin üstünden, 3B): kızakta kütüklerin gürültüsü, ahşap gıcırtısı, halatı
## çeken askerlerin "hey-ya" nidası ve bağrışlar. Önceden kadırga sessizce kayıyordu.
var _haul: AudioStreamPlayer3D


func _start_haul() -> void:
	var st := load("res://assets/audio/sfx/ship_haul.ogg") as AudioStreamOggVorbis
	if st == null:
		return
	st = st.duplicate()
	st.loop = true
	_haul = AudioStreamPlayer3D.new()
	_haul.stream = st
	_haul.bus = "SFX"
	_haul.volume_db = 2.0
	_haul.unit_size = 9.0
	_haul.max_distance = 90.0
	_haul.position = Vector3(0, 2.0, 0)
	ship.add_child(_haul)
	_haul.play()


## Kadırga suya inince (ya da bölüm sonunda) çekiş sesi susar.
func stop_haul() -> void:
	if _haul:
		var tw := _haul.create_tween()
		tw.tween_property(_haul, "volume_db", -40.0, 1.5)
		tw.tween_callback(_haul.stop)


# ---------------------------------------------------------------- engeller

func _build_obstacles() -> void:
	# kind: "rope" (zıpla), "log" (şeritleri kapatır), "block" (şeritte duran asker)
	var plan := [
		# İlk halat 26 m'de (20'ydi: kontrol gelince 0,8 sn sonra ayağa takılıyordu; ilk tökezleme neredeyse kesindi).
		# Başlangıç 14 m: şimdi 1,6 sn var. 24 m olmaz: kızağın s≈23,5'teki ek yeri oyuncuyu zıplatıyor. Sonraki ikisi
		# aralığı korumak için kaydı.
		[26.0, "rope", [0, 1, 2]],
		[37.0, "log", [0, 1]],
		[47.0, "block", [2]],
		[56.0, "rope", [0, 1, 2]],
		[68.0, "log", [1, 2]],
		[80.0, "block", [0]],
		[92.0, "log", [0, 2]],
		[104.0, "rope", [0, 1, 2]],
		[114.0, "block", [1]],
	]
	for p in plan:
		var s: float = p[0]
		var kind: String = p[1]
		var lanes: Array = p[2]
		var node := Node3D.new()
		track.add_child(node)
		node.position = Vector3(0, 0, -s)
		var o := {"s": s, "kind": kind, "lanes": lanes, "node": node, "resolved": false}
		match kind:
			"rope":
				_rope_team(o)
			"log":
				# Yola yuvarlanmış iki kütük: kadırganın sivri pruvası gelince iki yana, kızağın kenarına itilir (_work_tick)
				for l in lanes:
					var lg := Node3D.new()
					node.add_child(lg)
					lg.position = Vector3(LANES[l], 0.42, 0)
					Props.cyl(lg, 0.42, 2.6, Vector3.ZERO, C_LOG, Vector3(0, 0, 90), 8)
					Props.cyl(lg, 0.2, 0.02, Vector3(1.31, 0, 0), Color("c9a878"), Vector3(0, 0, 90), 8)
					var to := -1.0 if l == 0 or (l == 1 and lanes.has(2)) else 1.0
					_logs.append({"n": lg, "o": o, "home": lg.position, "to": to, "kicked": false})
			"block":
				for l in lanes:
					var sol2 := Soldier.new(Color("3f7a3a"), "point", "turban")
					sol2.set_meta("spk", "SPK_SOLDIER")
					sol2.set_meta("no_turn", true)
					sol2.position = Vector3(LANES[l], 0.0, 0)
					node.add_child(sol2)
					# Oyuncu yanından geçerken yakalamaya uzanır, kadırga gelince yoldan dışarı sıçrar (_work_tick)
					var out := signf(LANES[l]) if LANES[l] != 0.0 else 1.0
					_blockers.append({"sol": sol2, "o": o, "home": sol2.position, "out": out, "leapt": false, "grabbed": false})
		obstacles.append(o)


func reset_obstacles_after(s: float) -> void:
	for o in obstacles:
		if o["s"] > s:
			o["resolved"] = false
			o["cleared"] = false
			(o["node"] as Node3D).visible = true
	# Yakalanınca sahne geri sarılır: halatlar yeniden gerilir, kütükler ve yoldaki askerler yerine döner
	for tm: Dictionary in _rope_teams:
		if tm["o"]["s"] > s:
			_rope_raise(tm)
	for lg: Dictionary in _logs:
		if lg["o"]["s"] > s:
			lg["kicked"] = false
			var n: Node3D = lg["n"]
			n.position = lg["home"]
			n.rotation = Vector3.ZERO
	for b: Dictionary in _blockers:
		if b["o"]["s"] > s:
			b["leapt"] = false
			b["grabbed"] = false
			var sol: Soldier = b["sol"]
			sol.position = b["home"]
			sol.rotation = Vector3.ZERO
			sol.remove_meta("airborne")


# ---------------------------------------------------------------- Haliç

func _build_bottom() -> void:
	var end := end_point()
	# Kum şeridi
	var sand := Props.solid(self, Vector3(80, 1.0, 10), Vector3(end.x, water_y - 0.3, end.z + 2), C_SAND)
	Props.set_pattern(sand, C_SAND, "concrete")
	# Görünen kumsal arazinin kendisi (ground_h): kutunun yalnız çarpışması kalır
	for c in sand.get_children():
		if c is GeometryInstance3D:
			(c as GeometryInstance3D).visible = false
	# Dalgalı su (low-poly gölgelendirici)
	_water = MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(900, 900)
	pm.subdivide_width = 150
	pm.subdivide_depth = 150
	_water.mesh = pm
	var sh := ShaderMaterial.new()
	sh.shader = load("res://assets/shaders/water.gdshader")
	sh.set_shader_parameter("shore_z", end.z - 0.6)      # görünen su çizgisi (ground_h kumsalı)
	sh.set_shader_parameter("foam_width", 1.6)           # dar köpük şeridi (4 m'lik şerit suyun üstünde düz soluk bir levha gibiydi)
	_water.material_override = sh
	_water.position = Vector3(end.x, water_y, end.z - 380)
	if in_world:
		_water.free()                 # dünyanın Haliç'i (aynı yükseklikte; iki yüzey titreşirdi)
		_water = null
	else:
		add_child(_water)
	# Deniz tabanı: dalışta aşağıda boşluk değil kum görünür (tek haritada yalnız yüzme alanının altında)
	var bed_size := Vector3(300, 1.0, 300) if in_world else Vector3(900, 1.0, 900)
	var bed_z := end.z - 140.0 if in_world else end.z - 380.0
	var bed := Props.box(self, bed_size, Vector3(end.x, water_y - 7.5, bed_z), Color("6f7f62"))
	bed.material_override = Props.mat(Color("6f7f62"), 0.0, false, "", false)
	for i in 40:
		var r := RandomNumberGenerator.new()
		r.seed = 90 + i
		var rp := Vector3(end.x + r.randf_range(-45, 45), water_y - 7.0, end.z - r.randf_range(4, 80))
		var rock := Props.ball(self, r.randf_range(0.4, 1.3), rp, Color("5d6a55"), Vector3(1.0, 0.6, 1.2), 6)
		rock.material_override = Props.mat(Color("5d6a55"), 0.0, false, "", false)
	# İskele
	Props.box(self, Vector3(2.0, 0.15, 8.0), Vector3(end.x + 22, water_y + 0.35, end.z - 5), Color("8a6440"))
	for zz in [-8.0, -5.0, -2.0]:
		for xx in [-0.9, 0.9]:
			Props.cyl(self, 0.12, 2.0, Vector3(end.x + 22 + xx, water_y - 0.4, end.z + zz), Color("5f4329"), Vector3.ZERO, 6)
	# Kıyıda fıçılar (tur 4): suyun hemen üstündeki kuma oturur (eskiden düz kapaklı üç silindir suyun üstünde havada
	# duruyordu); çıkış yerinin gerisinde kalır (iniş seçimi _spot_clear önündeki kutuya bakar)
	var sp := shore_point()
	for i in 3:
		_shore_barrel(Vector3(sp.x - 3.2 + i * 0.85, 0.0, end.z + 0.1 + (0.35 if i == 1 else 0.0)), i == 2, float(i) * 70.0)
	for i in 2:
		var sol := Soldier.new(Color("b3262d") if i == 0 else Color("2f5fa8"), "stand", "bork")
		# Kıyıdaki ikizler: Hasan (kırmızı) ile Hüseyin (mavi). Gizlice çıkınca onlar konuşur; yakalanınca
		# "Islak bir Frenk casusu!" diyen asker de onlardan biri (kartta en yakını)
		sol.set_meta("spk", "SPK_HASAN" if i == 0 else "SPK_HUSEYIN")
		sol.set_meta("speaker", "SPK_SOLDIER")
		sol.position = sp + Vector3(1.5 + i * 1.2, water_y - sp.y + 0.2, 1.0)
		sol.rotation_degrees.y = 150
		add_child(sol)


## Kıyı fıçısı: tahta tahta, ortası şişkin, demir çemberli, kapaklı; kuma oturur. lying: yan yatık.
func _shore_barrel(at: Vector3, lying: bool, yaw: float) -> void:
	var g := Node3D.new()
	add_child(g)
	var base_y := surface_h(at.x, at.z)
	g.position = Vector3(at.x, base_y - 0.02, at.z)
	g.rotation_degrees.y = yaw
	var h := 0.8
	var wood := Color("8a5f3a")
	var body := Node3D.new()
	g.add_child(body)
	# Şişkin gövde: üç kat (alt, orta, üst), her kat koni gövdeli
	Props.cyl(body, 0.3, h * 0.36, Vector3(0, h * 0.18, 0), wood.darkened(0.08), Vector3.ZERO, 10, 0.34)
	Props.cyl(body, 0.34, h * 0.3, Vector3(0, h * 0.51, 0), wood, Vector3.ZERO, 10, 0.34)
	Props.cyl(body, 0.34, h * 0.36, Vector3(0, h * 0.82, 0), wood.darkened(0.08), Vector3.ZERO, 10, 0.3)
	# Tahta çizgileri: dikey ince koyu şeritler
	for k in 10:
		var a := TAU * k / 10.0 + 0.15
		Props.box(body, Vector3(0.012, h * 0.96, 0.02), Vector3(cos(a) * 0.335, h * 0.5, sin(a) * 0.335), wood.darkened(0.35), Vector3(0, -rad_to_deg(a), 0))
	# Demir çemberler (alt, üst, ortada ikisi)
	for hy: float in [0.1, 0.28, 0.52, 0.7]:
		var r := 0.31 if hy < 0.2 or hy > 0.6 else 0.345
		Props.ring(body, r - 0.012, r + 0.03, Vector3(0, hy, 0), Color("3a3634"), Vector3.ZERO)
	# Kapak: hafif içbükey, koyu halka çerçeveli
	Props.cyl(body, 0.29, 0.03, Vector3(0, h + 0.005, 0), wood.lightened(0.1), Vector3.ZERO, 10)
	if lying:
		body.rotation_degrees = Vector3(0, 0, 90)
		body.position = Vector3(0.4, 0.34, 0)


func _build_far_shore() -> void:
	var first := get_child_count()
	var end := end_point()
	var base_y := water_y
	var far_z := end.z - 150.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	# Karşı kıyı zemini
	Props.box(self, Vector3(600, 6, 70), Vector3(end.x, base_y - 2.2, far_z - 33), C_STONE_DARK)
	# Arkadaki tepeler (şehrin yedi tepesi, low-poly)
	var far_noise := FastNoiseLite.new()
	far_noise.seed = 7
	far_noise.frequency = 0.012
	var hf := func(x: float, z: float) -> float:
		var d := clampf((far_z - 40.0 - z) / 180.0, 0.0, 1.0)
		return base_y + 1.0 + d * 26.0 + far_noise.get_noise_2d(x, z) * (4.0 + d * 14.0)
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		var c := Color("4a6e30").lerp(Color("6a7640"), clampf(far_noise.get_noise_2d(x * 2.0, z * 2.0) + 0.5, 0.0, 1.0))
		return c.darkened(0.12) if steep > 0.4 else c
	add_child(LowPoly.terrain(end.x - 420, end.x + 420, far_z - 320, far_z - 50, 42, 16, hf, cf))

	# Şehrin evleri: basamak basamak yükselen sıralar
	var walls_c := [Color("efe0c2"), Color("e3c9a0"), Color("d9b48a"), Color("f2e8d6"), Color("dcc0a8"), Color("e8d2b8")]
	for i in 150:
		var hx := rng.randf_range(-200, 200)
		var depth := rng.randf_range(6, 55)
		var hz := far_z - depth
		var ground := base_y + 1.0 + depth * 0.12
		var w := rng.randf_range(4.0, 7.0)
		var h := rng.randf_range(3.5, 7.5)
		var d := rng.randf_range(4.0, 6.5)
		var house := Node3D.new()
		house.position = Vector3(end.x + hx, ground, hz)
		house.rotation_degrees.y = [0.0, 90.0, 8.0, -6.0][i % 4]
		add_child(house)
		Props.box(house, Vector3(w, h, d), Vector3(0, h / 2.0, 0), walls_c[i % walls_c.size()])
		if i % 3 == 0:
			# Ahşap çıkma kat
			Props.box(house, Vector3(w + 0.8, 1.8, d * 0.7), Vector3(0, h + 0.9, 0), Color("8a6440"))
			Props.prism(house, Vector3(w + 1.2, 1.8, d + 0.6), Vector3(0, h + 2.7, 0), C_ROOF)
		else:
			Props.prism(house, Vector3(w + 0.6, 1.8, d + 0.6), Vector3(0, h + 0.9, 0), C_ROOF.lerp(Color("c86a45"), rng.randf()))
	# Kiliseler: kubbeli
	for i in 6:
		var cx := rng.randf_range(-180, 180)
		var cz := far_z - rng.randf_range(15, 50)
		var gy := base_y + 1.0 + (far_z - cz) * 0.12
		var ch := Vector3(end.x + cx, gy, cz)
		Props.box(self, Vector3(10, 8, 12), ch + Vector3(0, 4, 0), Color("d9a67a"))
		Props.cyl(self, 3.2, 2.0, ch + Vector3(0, 9, 0), Color("d9a67a"), Vector3.ZERO, 10)
		Props.ball(self, 3.3, ch + Vector3(0, 10, 0), Color("8e9aa3"), Vector3(1, 0.8, 1), 10)
	# Selviler
	for i in 40:
		var tx := rng.randf_range(-200, 200)
		var tz := far_z - rng.randf_range(5, 55)
		var tree := Node3D.new()
		_cypress(tree, rng.randf_range(6, 11))
		tree.position = Vector3(end.x + tx, base_y + 1.0 + (far_z - tz) * 0.12, tz)
		add_child(tree)

	# Deniz surları: tuğla bantlı taş, burçlar
	Props.box(self, Vector3(420, 9, 3), Vector3(end.x, base_y + 4.5, far_z), C_STONE)
	for band in [2.5, 6.0]:
		Props.box(self, Vector3(420.2, 0.5, 3.1), Vector3(end.x, base_y + band, far_z), C_BRICK)
	var x := -210.0
	while x <= 210.0:
		Props.box(self, Vector3(1.2, 1.2, 3.2), Vector3(end.x + x, base_y + 9.6, far_z), C_STONE)
		if int(x) % 24 == 0:
			var tower := Vector3(end.x + x, base_y, far_z)
			Props.box(self, Vector3(6, 14, 6), tower + Vector3(0, 7.0, 0), C_STONE_DARK)
			for band2 in [3.0, 7.0, 11.0]:
				Props.box(self, Vector3(6.1, 0.5, 6.1), tower + Vector3(0, band2, 0), C_BRICK)
			for cx2 in [-2.2, 0.0, 2.2]:
				Props.box(self, Vector3(1.0, 1.0, 6.2), tower + Vector3(cx2, 14.5, 0), C_STONE_DARK)
		x += 3.0

	# Ayasofya: merkezi kubbe, iki yarım kubbe, payandalar (1453'te minaresi yoktu)
	var hs := Vector3(end.x + 40, base_y + 6.0, far_z - 48)
	var ochre := Color("cc8f63")
	Props.box(self, Vector3(34, 16, 30), hs + Vector3(0, 8, 0), ochre)
	for bx in [-18.0, 18.0]:
		for bz in [-12.0, 12.0]:
			Props.box(self, Vector3(4, 20, 6), hs + Vector3(bx, 10, bz), ochre.darkened(0.08))
	Props.cyl(self, 11.5, 3.0, hs + Vector3(0, 17.5, 0), ochre, Vector3.ZERO, 16)
	Props.ball(self, 11.8, hs + Vector3(0, 19, 0), Color("8e9aa3"), Vector3(1, 0.55, 1), 16)
	for sz in [-13.0, 13.0]:
		Props.ball(self, 8.5, hs + Vector3(0, 15, sz), Color("8e9aa3"), Vector3(1, 0.5, 0.8), 12)
	for i in 12:
		var a := TAU * i / 12.0
		Props.box(self, Vector3(1.2, 1.4, 1.2), hs + Vector3(cos(a) * 11.6, 18.2, sin(a) * 11.6), ochre.darkened(0.05))

	# Galata Kulesi (bu kıyıda, solda)
	var gx := end.x - 58.0
	var gz := end.z + 6.0
	var gt := Vector3(gx, ground_h(gx, gz), gz)
	Props.cyl(self, 4.0, 32.0, gt + Vector3(0, 16, 0), C_STONE_DARK, Vector3.ZERO, 12)
	for band3 in [8.0, 20.0]:
		Props.cyl(self, 4.05, 0.6, gt + Vector3(0, band3, 0), C_STONE_DARK, Vector3.ZERO, 12)
	Props.cyl(self, 4.7, 2.0, gt + Vector3(0, 32, 0), C_STONE_DARK, Vector3.ZERO, 12)
	Props.cyl(self, 4.6, 9.0, gt + Vector3(0, 37.5, 0), Color("6d7f8f"), Vector3.ZERO, 12, 0.2)

	# Karşı kıyı durağan: ~800 parça birkaç ağ örgüsüne birleşir (Props.bake_static; Bölüm 2 kare başına ~10 bin çizim)
	Props.bake_static(self, get_children().slice(first))

func _build_chain_and_boat() -> void:
	# Haliç zinciri: yüzen kütükler ve halkalar (tek haritada dünyanın zinciri ağızdadır; burada kurulmaz)
	var cp := chain_point()
	var a := Vector3(cp.x - 10, water_y, cp.z + 25)
	var b := Vector3(cp.x + 30, water_y, cp.z - 120)
	var n := 0 if in_world else 34
	for i in n:
		var t := float(i) / (n - 1)
		var p := a.lerp(b, t)
		var dir := (b - a).normalized()
		var yaw := rad_to_deg(atan2(dir.x, dir.z))
		Props.cyl(self, 0.35, 2.6, p + Vector3(0, 0.1, 0), C_LOG, Vector3(90, yaw, 0), 8)
		Props.ring(self, 0.12, 0.2, p + dir * 1.6 + Vector3(0, 0.25, 0), Color("4a4d52"), Vector3(0, yaw, 90))
	# Kayık ve kayıkçı
	boat = Node3D.new()
	add_child(boat)
	boat.add_child(LowPoly.hull([
		{"z": -2.8, "w": 0.05, "top": 0.75, "bottom": 0.35},
		{"z": -1.8, "w": 0.6, "top": 0.55, "bottom": -0.05},
		{"z": 0.5, "w": 0.75, "top": 0.5, "bottom": -0.1},
		{"z": 2.0, "w": 0.6, "top": 0.55, "bottom": -0.05},
		{"z": 2.6, "w": 0.35, "top": 0.7, "bottom": 0.2},
	], Color("6b4428"), Color("2f5fa8"), 0.4))
	Props.box(boat, Vector3(1.1, 0.06, 0.3), Vector3(0, 0.4, 0.6), Color("a07a4e"))
	# Omurga: sualtından bakınca kayığın altı düz koyu bir yamuk levha gibi görünüyordu (tur 3)
	Props.box(boat, Vector3(0.09, 0.12, 4.4), Vector3(0, -0.14, -0.05), Color("3e2614"))
	var rower := Soldier.new(Color("c98a3a"), "stand", "turban")
	rower.set_meta("spk", "SPK_ROWER")
	rower.position = Vector3(0, 0.1, 0.6)
	rower.scale = Vector3.ONE * 0.9
	boat.add_child(rower)
	rower.rig.activity = "row"                 # oturur, iki elinde birer kürek (OarGrip), kendi temposuyla çeker
	boat.position = Vector3(cp.x + 60, water_y, cp.z + 12)
	var pair: Array = []
	for side: float in [-1.0, 1.0]:
		var oar := OarGrip.make_oar(boat, Vector3(side * 0.72, 0.62, 1.1), side, 0.6, 1.7, 0.035, Vector2(0.45, 0.16), 0.14)
		pair.append([oar, "auto"])
		_boat_oars.append({"oar": oar, "side": side, "out": 1.7, "wet": false})      # pala suya girince halka (_tick_water)
	OarGrip.attach(rower, pair, water_y)
	boat.rotation_degrees.y = 90


# ---------------------------------------------------------------- su efektleri

## Dalış: sualtında yoğun, yeşil-mavi sis (uzaktaki her şey ve gökyüzü kaybolur).
func set_underwater(on: bool) -> void:
	if _fog_air.is_empty():
		_fog_air = {"density": _env.fog_density, "color": _env.fog_light_color, "sky": _env.fog_sky_affect}
	for sh in _shafts:
		sh.visible = on
	_underwater_on = on
	for bc in _bubble_cols:
		if is_instance_valid(bc):
			(bc as Node3D).visible = on
	if on:
		_env.fog_density = 0.07
		_env.fog_light_color = Color("2f8a86")
		_env.fog_sky_affect = 1.0
	else:
		_env.fog_density = _fog_air["density"]
		_env.fog_light_color = _fog_air["color"]
		_env.fog_sky_affect = _fog_air["sky"]


func _particles(pos: Vector3, amount: int, color: Color, radius: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	var m := SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	m.radial_segments = 6
	m.rings = 3
	p.mesh = m
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if color.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	p.material_override = mat
	p.amount = amount
	p.position = pos
	add_child(p)
	return p


## Suya çarpma (tur 4): küçük damlacık demeti ve genişleyen, yuvarlak, yumuşak kenarlı iki köpük halkası, kısa ömürlü.
## Eskiden 15 m'ye açılan dolu bir simit (sert kenarlı beyaz üçgenler, ekranı kaplayan levha) vardı.
func splash(pos: Vector3, big := false) -> void:
	var at := Vector3(pos.x, water_y + 0.1, pos.z)
	# Damlalar küçük ve yarı saydam (2-3 cm), kısa ömürlü
	var drops := _particles(at, 80 if big else 44, Color(0.92, 0.97, 1.0, 0.6), 0.036 if big else 0.026)
	drops.gravity = Vector3(0, -12.0, 0)
	drops.one_shot = true
	drops.explosiveness = 0.92
	drops.lifetime = 0.85
	drops.direction = Vector3.UP
	drops.spread = 32.0
	drops.initial_velocity_min = 2.5 if big else 2.0
	drops.initial_velocity_max = 7.5 if big else 5.0
	drops.scale_amount_min = 0.5
	drops.scale_amount_max = 1.3
	drops.emitting = true
	var k := 1.0 if big else 0.55
	ripple(at, 0.25, 0.9 + 1.7 * k, 0.9, 0.5)
	ripple(at, 0.12, 0.6 + 0.9 * k, 0.6, 0.4)
	get_tree().create_timer(1.6, false).timeout.connect(func():
		if is_instance_valid(drops):
			drops.queue_free())


## Sualtında yükselen kabarcıklar.
func bubbles(pos: Vector3, seconds := 1.2) -> void:
	# Küçük, yuvarlak, yarı saydam, yükseldikçe büyüyen kabarcıklar (tur 3: eskiden düz beyaz çokgenler); yüzeye kadar
	# yükselip söner, sudan dışarı taşmaz
	Vfx.bubbles(self, pos, seconds, clampf(water_y - pos.y, 0.6, 2.0), 26)


# ---------------------------------------------------------------- yüzme alanı

## Yüzme alanı: sığlık, yosun ormanı, deniz çayırı, batık kadırga, amforalar, balık sürüleri, ışık hüzmeleri
## (sualtı); demirli Osmanlı kadırgaları, yüzen kütük ve fıçılar, kayıp bir fes (yüzey).
func _build_swim_scenery() -> void:
	var end := end_point()
	var start := swim_start()
	var shore := shore_point()
	var chain := chain_point()
	var bed_y := water_y - 4.4
	var rng := RandomNumberGenerator.new()
	rng.seed = 1204
	# Sığlık: yüzme yollarının altı; dalınca tabanı görürsün
	# Dip kenarsız (tur 3): eskiden 110 × 80 m'lik kutunun keskin kenarı ve altındaki daha derin taban sisin içinde basamak
	# gibi görünüyordu; dip sisin göremediği uzaklığa kadar uzanır
	var shoal := Props.box(self, Vector3(420, 1.0, 340), Vector3(end.x - 12, bed_y - 0.5, end.z - 160), Color("8a946a"))
	shoal.material_override = Props.mat(Color("8a946a"), 0.0, false, "", false)
	var area := Rect2(end.x - 62, end.z - 76, 104, 70)
	# Dip: açık kum (eskiden yeşilimsi düz kutu); yosun demetleri dipte kümeler hâlinde, akıntıda salınır (köşe
	# gölgelendiricisi: Vfx.sway_material); aralarda deniz çayırı. Eskiden 520 dik yeşil çubuk ve 420 çapraz dikdörtgen.
	shoal.material_override = Props.mat(Color("c2b48a"), 0.0, false, "", false)
	var xf: Array = []
	var cols: Array = []
	for cl in 70:
		var cx := rng.randf_range(area.position.x, area.end.x)
		var cz := rng.randf_range(area.position.y, area.end.y)
		for k in rng.randi_range(2, 6):
			var x := cx + rng.randf_range(-1.6, 1.6)
			var z := cz + rng.randf_range(-1.6, 1.6)
			if Vector2(x - start.x, z - start.z).length() < 2.5:
				continue
			var h := rng.randf_range(0.6, 1.25)
			xf.append(_td(Vector3(x, bed_y, z), Vector3(rng.randf_range(-6, 6), rng.randf() * 360.0, rng.randf_range(-6, 6)), Vector3(1, h, 1)))
			cols.append(Color("3f6a32").lerp(Color("7a8a3a"), rng.randf()))
	var weed := Scenery.scatter(self, Nature.seaweed_mesh(), xf, cols, Vfx.sway_material(true))
	weed.set_meta("no_walk", true)
	var tuft := Nature.tuft()
	xf = []
	cols = []
	for i in 380:
		var x := rng.randf_range(area.position.x, area.end.x)
		var z := rng.randf_range(area.position.y, area.end.y)
		xf.append(_td(Vector3(x, bed_y, z), Vector3(0, rng.randf() * 360.0, 0), Vector3.ONE * rng.randf_range(0.8, 1.8)))
		cols.append(Color("5a7a3a").lerp(Color("a89a5a"), rng.randf()))
	Scenery.scatter(self, tuft, xf, cols, Nature.grass_material()).set_meta("no_walk", true)
	# Kabarcık sütunları: batığın gövdesinden ve dipteki iki çatlaktan
	for bp: Vector3 in [start.lerp(chain, 0.62) + Vector3(-4.0, 0, 3.0), start + Vector3(-6.0, 0, -12.0), start.lerp(shore, 0.5) + Vector3(2, 0, -3)]:
		_bubble_cols.append(Vfx.bubble_column(self, Vector3(bp.x, bed_y + 0.3, bp.z), 4.0, 12))
	var stone := Scenery._ball(1.0)
	xf = []
	cols = []
	for i in 90:
		var x := rng.randf_range(area.position.x, area.end.x)
		var z := rng.randf_range(area.position.y, area.end.y)
		var r := rng.randf_range(0.25, 0.9)
		xf.append(_td(Vector3(x, bed_y + r * 0.3, z), Vector3(0, rng.randf() * 360.0, 0), Vector3(r * 1.3, r * 0.6, r)))
		cols.append(Color("6d7466").lerp(Color("a39a80"), rng.randf()))
	Scenery.scatter(self, stone, xf, cols)
	# Batık kadırga: zincir yolunun altında, yan yatmış
	var wreck_at := start.lerp(chain, 0.62) + Vector3(-4.0, 0, 3.0)
	var wreck := Props.model(self, "galley", Vector3(wreck_at.x, bed_y + 0.2, wreck_at.z), 35.0, 1.3)
	if wreck:
		wreck.rotation_degrees.z = 28.0
	else:
		Props.box(self, Vector3(3.0, 1.2, 10.0), Vector3(wreck_at.x, bed_y + 0.4, wreck_at.z), Color("4a3422"), Vector3(0, 35, 28))
	# Amforalar: enkazın çevresine dağılmış; biri yüzme yolunun hemen altında
	var amph := Scenery.merged([
		[Scenery._cyl(0.18, 0.5, 0.12, 8), Transform3D(), Color("b86a3a")],
		[Scenery._ball(0.2), _td(Vector3(0, -0.2, 0)), Color("b86a3a")],
		[Scenery._cyl(0.06, 0.25, 0.07, 6), _td(Vector3(0, 0.36, 0)), Color("a85e32")],
	])
	xf = []
	for i in 26:
		var p := wreck_at + Vector3(rng.randf_range(-7, 7), 0, rng.randf_range(-7, 7))
		xf.append(_td(Vector3(p.x, bed_y + 0.2, p.z), Vector3(rng.randf_range(40, 90), rng.randf() * 360.0, 0)))
	amphora_spot = start.lerp(chain, 0.38) + Vector3(1.5, 0, 0)
	amphora_spot.y = bed_y + 1.6
	xf.append(_td(Vector3(amphora_spot.x, bed_y + 0.7, amphora_spot.z), Vector3(0, 30, 0), Vector3.ONE * 1.6))
	Scenery.scatter(self, amph, xf)
	for i in 5:
		var bp := wreck_at + Vector3(rng.randf_range(-6, 6), 0, rng.randf_range(-6, 6))
		var br := Props.model(self, "barrel", Vector3(bp.x, bed_y, bp.z), rng.randf() * 360.0)
		if br:
			br.rotation_degrees.x = 90.0
	# Balık sürüleri: bütün balıklar tek çoklu ağ (eskiden her balık ve kuyruğu ayrı mesh: ~150 çizim); sürü halkada döner
	var fish := Scenery.merged([[Scenery._ball(0.09), Transform3D(Basis.from_scale(Vector3(0.5, 0.8, 2.0)), Vector3.ZERO), Color.WHITE],
		[Scenery._boxm(Vector3(0.01, 0.12, 0.08)), Transform3D(Basis(), Vector3(0, 0, 0.22)), Color.WHITE]])
	var fx: Array = []
	var fc: Array = []
	for sidx in 9:
		var n := rng.randi_range(7, 12)
		var offs: Array = []
		for k in n:
			offs.append([fx.size(), Vector3(rng.randf_range(-0.9, 0.9), rng.randf_range(-0.4, 0.4), rng.randf_range(-0.9, 0.9))])
			fx.append(Transform3D())
			fc.append(Color("e8a040") if sidx % 3 == 0 else Color("b8c8d0").lerp(Color("8aa0aa"), rng.randf()))
		var c := start.lerp(chain if sidx % 2 == 0 else shore, rng.randf_range(0.15, 0.95)) + Vector3(rng.randf_range(-6, 6), 0, rng.randf_range(-6, 6))
		c.y = water_y - rng.randf_range(1.6, 3.2)
		_fish.append({"offs": offs, "center": c, "radius": rng.randf_range(1.5, 4.0),
			"speed": rng.randf_range(0.25, 0.6) * (1.0 if sidx % 2 == 0 else -1.0), "phase": rng.randf() * TAU})
	var fmat := StandardMaterial3D.new()
	fmat.vertex_color_use_as_albedo = true
	fmat.vertex_color_is_srgb = true
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_fish_mm = Scenery.scatter(self, fish, fx, fc, fmat)
	_fish_mm.set_meta("no_walk", true)
	# Işık hüzmeleri (yalnız sualtındayken görünür): tek çoklu ağ, uca doğru solan, kıpırdayan koniler
	var mid := start.lerp(chain, 0.4).lerp(shore, 0.3)
	var shafts := Vfx.light_shafts(self, Vector3(mid.x, 0, mid.z), Vector2(70, 60), 34, water_y, 6.5, 7)
	shafts.visible = false
	_shafts.append(shafts)
	# Demirli Osmanlı kadırgaları (Haliç'in açığında)
	for gp in [Vector3(-70, 0, -48), Vector3(-92, 0, -70), Vector3(-50, 0, -88), Vector3(30, 0, -64), Vector3(52, 0, -86)]:
		_anchored_galley(end + gp, rng.randf_range(-40, 40))
	# Yüzen enkaz: iki yolun üstünde, bazısı yolun tam ortasında
	for spec in [[shore, 0.42, 1.2], [shore, 0.7, -1.4], [chain, 0.18, -1.6], [chain, 0.3, 1.4], [chain, 0.5, -0.8],
			[chain, 0.72, 1.8], [chain, 0.86, -1.2]]:
		var goal: Vector3 = spec[0]
		var side := (goal - start).cross(Vector3.UP).normalized()
		var p: Vector3 = start.lerp(goal, spec[1]) + side * float(spec[2])
		var node := Node3D.new()
		node.position = Vector3(p.x, water_y + 0.05, p.z)
		add_child(node)
		if swim_debris.size() % 2 == 0:
			var lyaw := rng.randf() * 180.0
			Props.cyl(node, 0.3, 2.6, Vector3.ZERO, C_LOG, Vector3(90, lyaw, 0), 10)
			# Açık renkli kesik uçlar ve bir dal güdüğü: sualtından bakınca kütük düz koyu bir levha gibi görünüyordu (tur 3)
			var ax := Basis.from_euler(Vector3(deg_to_rad(90.0), deg_to_rad(lyaw), 0.0)) * Vector3.UP
			for e: float in [-1.0, 1.0]:
				Props.cyl(node, 0.25, 0.03, ax * 1.3 * e, Color("d8b98a"), Vector3(90, lyaw, 0), 10)
			Props.cyl(node, 0.06, 0.35, ax * 0.4 + Vector3(0, -0.3, 0), Color("6a4c2c"), Vector3(0, 0, 25), 5)
		else:
			var bm := Props.model(node, "barrel", Vector3(0, -0.2, 0), rng.randf() * 360.0)
			if bm:
				bm.rotation_degrees.x = 80.0
			else:
				Props.cyl(node, 0.4, 0.9, Vector3.ZERO, Color("7a5232"), Vector3(90, 0, 0), 10)
		swim_debris.append(node)
		_bob_nodes.append({"node": node, "base_y": node.position.y, "phase": rng.randf() * TAU})
	# Kayıp fes: başlangıçtan biraz sapınca bulunur
	fez_float = Node3D.new()
	var fz := start + Vector3(-8.0, 0, -9.0)
	fez_float.position = Vector3(fz.x, water_y + 0.08, fz.z)
	add_child(fez_float)
	Props.cyl(fez_float, 0.16, 0.24, Vector3(0, 0.05, 0), Color("b3262d"), Vector3(0, 0, 70), 10, 0.13)
	Props.cyl(fez_float, 0.012, 0.18, Vector3(0.05, 0.14, 0), Color("1a1a1a"), Vector3(0, 0, 20), 4)
	_bob_nodes.append({"node": fez_float, "base_y": fez_float.position.y, "phase": 1.3})
	# Suya yakın uçan birkaç martı daha
	for i in 6:
		_add_gull(start + Vector3(rng.randf_range(-40, 20), rng.randf_range(4, 9), rng.randf_range(-50, -5)), rng)


func _anchored_galley(pos: Vector3, yaw: float) -> void:
	var g := Node3D.new()
	g.position = Vector3(pos.x, water_y - 0.4, pos.z)
	g.rotation_degrees.y = yaw
	add_child(g)
	g.add_child(LowPoly.hull([
		{"z": -9.0, "w": 0.06, "top": 2.3, "bottom": 1.4},
		{"z": -6.0, "w": 1.3, "top": 1.9, "bottom": 0.3},
		{"z": 0.0, "w": 1.7, "top": 1.85, "bottom": 0.2},
		{"z": 5.0, "w": 1.4, "top": 2.0, "bottom": 0.4},
		{"z": 7.0, "w": 0.8, "top": 2.7, "bottom": 1.0},
	], Color("5b3a22"), Color("7e2420"), 1.78))
	Props.box(g, Vector3(2.8, 0.1, 11.0), Vector3(0, 1.8, -0.5), Color("b08a5c"))
	Props.cyl(g, 0.14, 9.0, Vector3(0, 6.2, -1.5), Color("6b4428"), Vector3.ZERO, 6)
	Props.cyl(g, 0.22, 7.5, Vector3(0, 8.0, -1.6), Color("efe6cf"), Vector3(55, 0, 0), 7)
	Props.box(g, Vector3(0.05, 0.7, 1.3), Vector3(0, 10.6, -1.3), Color("b3262d"))
	for i in 8:
		for side in [-1, 1]:
			Props.cyl(g, 0.04, 3.0, Vector3(side * 2.2, 1.0, -4.0 + i * 1.1), Color("c9a878"), Vector3(0, 0, side * 70), 4)
	Props.bake_static(g, g.get_children())      # tek ağ (inip kalkarken birlikte): eskiden ~21 parça, her biri çizim
	_bob_nodes.append({"node": g, "base_y": g.position.y, "phase": pos.x * 0.1})


func _add_gull(center: Vector3, rng: RandomNumberGenerator) -> void:
	var g := Node3D.new()
	add_child(g)
	var wings: Array = []
	for side in [-1, 1]:
		var pivot := Node3D.new()
		g.add_child(pivot)
		var w := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.9, 0.04, 0.25)
		w.mesh = bm
		w.material_override = Props.mat(Color("f4f4f0"), 0.0, false, "", false)
		w.position = Vector3(side * 0.45, 0, 0)
		pivot.add_child(w)
		wings.append(pivot)
	var body := MeshInstance3D.new()
	var bb := BoxMesh.new()
	bb.size = Vector3(0.18, 0.14, 0.5)
	body.mesh = bb
	body.material_override = Props.mat(Color("e9e9e4"), 0.0, false, "", false)
	g.add_child(body)
	for mi in g.find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_gulls.append({"node": g, "wings": wings, "center": center, "radius": rng.randf_range(5, 12),
		"speed": rng.randf_range(0.3, 0.6), "phase": rng.randf() * TAU})


## Ok uyarısı: suda kırmızımsı, büyüyen bir halka. Düşüş anında Chapter2 arrow_fall çağırır.
func arrow_warning(pos: Vector3, seconds: float) -> void:
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.9
	tm.outer_radius = 1.1
	tm.rings = 20
	tm.ring_segments = 4
	ring.mesh = tm
	var rm := StandardMaterial3D.new()
	rm.albedo_color = Color(1.0, 0.35, 0.25, 0.8)
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = rm
	ring.position = Vector3(pos.x, water_y + 0.06, pos.z)
	ring.scale = Vector3(1.4, 0.15, 1.4)
	add_child(ring)
	var tw := create_tween()
	tw.tween_property(ring, "scale", Vector3(0.35, 0.15, 0.35), seconds)
	tw.tween_callback(ring.queue_free)


## Ok suya saplanır: kısa bir süre yüzeyde kalır.
func arrow_fall(pos: Vector3) -> void:
	var a := Node3D.new()
	a.position = Vector3(pos.x, water_y + 6.0, pos.z)
	add_child(a)
	Props.cyl(a, 0.025, 0.9, Vector3.ZERO, Color("6b4428"), Vector3(12, 0, 8), 4)
	Props.box(a, Vector3(0.12, 0.2, 0.01), Vector3(0, 0.42, 0), Color("efe6cf"))
	var tw := create_tween()
	tw.tween_property(a, "position:y", water_y + 0.2, 0.22).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): splash(pos))
	tw.tween_interval(2.5)
	tw.tween_property(a, "position:y", water_y - 1.0, 1.0)
	tw.tween_callback(a.queue_free)


# ---------------------------------------------------------------- iş ekipleri (temas, tepki)
# Eskiden yokuştaki herkes işini havaya yapıyordu: halat çekenlerin elleri boştaydı ve halat iki kazık arasında
# çubuk gibi duruyordu, ırgat halatı hiçbir şeye bağlı değildi, öküzler koşumsuz bekliyordu, kadırgayı kimse itmiyordu,
# kadırga yoldaki kütüklerin ve askerlerin içinden geçiyordu. Burada her işin nesnesi elde ya da bağlı.

## İş alanları (s, kenardan uzaklık): eşya ve süs kümeleri bunlara düşerse kayar. pad: kümenin yarıçapı kadar pay.
func _reserved(s: float, side: int, dist: float, pad: float) -> bool:
	var rects: Array = []
	for s3: float in [6.0, 45.0, 84.0]:
		rects.append(Rect2(s3 - 2.6, 0.6, 13.0, 5.2))          # ırgat güvertesi (çap 4,8) ve kızağın yolu
	for s0: float in OX_S:
		rects.append(Rect2(s0 - 3.2, 3.0, 11.0, 3.4))          # öküzler, arkalarındaki kızak ve yürüdükleri yol
	for os: float in [26.0, 56.0, 104.0]:
		rects.append(Rect2(os - 1.2, 0.0, 2.4, 4.4))           # halat ekibi
	for s3: float in [19.0, 58.0, 97.0]:
		rects.append(Rect2(s3 - 0.6, 1.5, 1.2, 1.1))           # yağcının geri sıçradığı yer
	for b: Array in [[47.0, 1], [80.0, -1], [114.0, 1]]:
		if int(b[1]) == side:
			rects.append(Rect2(float(b[0]) - 1.2, 0.4, 2.4, 2.4))   # yoldan sıçrayan askerin indiği yer
	for r: Rect2 in rects:
		if r.grow(pad).has_point(Vector2(s, dist)):
			return true
	return false


func _hide_sunk_world() -> void:
	if world == null or not is_instance_valid(world):
		return
	var end_z := end_point().z
	var n := 0
	for c in world.find_children("*", "MultiMeshInstance3D", true, false):
		var mmi := c as MultiMeshInstance3D
		if mmi.multimesh == null or not mmi.has_meta("xforms"):
			continue
		var h := mmi.multimesh.mesh.get_aabb().size.y if mmi.multimesh.mesh else 0.0
		for i in mmi.multimesh.instance_count:
			var xf := WorldWalk.inst_xf(mmi, i)
			if xf.basis.get_scale().length() < 0.05:
				continue
			var o := to_local(mmi.global_transform * xf.origin)
			if absf(o.x) > 108.0 or o.z < end_z - 14.0 or o.z > 158.0:
				continue
			if o.y < surface_h(o.x, o.z) - 0.6 and o.y + h > minf(surface_h(o.x, o.z), water_y) - 0.2:
				WorldWalk.hide_inst(mmi, i)
				n += 1
	if GameState.autotest and n > 0:
		print("SLIPWAY hid %d sunk world instances" % n)


## Öküz takımlarının yeri (s): halat ekiplerinden ve ırgat kızaklarının yolundan uzakta (eskiden 24, 62, 100: ilki
## 26'daki halat ekibinin kangalının üstündeydi)
const OX_S := [30.0, 62.0, 96.0]
var _grips: Array = []          # [{who, frame, pts}]: eller her karede bu noktalara iner (frame'in yerelinde)
var _rope_teams: Array = []
var _logs: Array = []
var _blockers: Array = []
var _greasers: Array = []
var _spotters: Array = []
var _sleds: Array = []
var _oxen: Array = []
var _motes: CPUParticles3D
var _teams: Array = []           # öküz takımları: {team, herder, side, s0, s, start, end}
var _pushers: Array[Soldier] = []
var _brakes: Array = []
var _snubbers: Array[Soldier] = []
var _push_ph := 0.0
var _ship_prev := INF
var _ship_v := 0.0
var _boat_oars: Array = []
var _boat_prev := Vector3.INF
var _wake_t := 0.0
var _debris_t := 0.0


## Halat: tek parça, burgulu ip (Stage.rope). Eskiden 1-4 düz silindir parçası: yerde keskin zikzak, kırık tel gibiydi.
func _rope_make(parent: Node3D, r := 0.035, col := Color("b89a6a")) -> MeshInstance3D:
	return Stage.rope(parent, Vector3.ZERO, Vector3(0, 0.1, 0), 0.0, r, col)


func _rope_set(rope: MeshInstance3D, pts: Array) -> void:
	Stage.rope_to(rope, pts)


## Sarkan halat noktaları (Stage.sag_points)
static func _sag(a: Vector3, b: Vector3, sag: float, n: int) -> Array:
	return Stage.sag_points(a, b, sag, n)


func _ground_at(s: float, x: float) -> Vector3:
	var p := s_to_world(s, x)
	return Vector3(p.x, surface_h(p.x, p.z), p.z)


## Kızağı enine kesen halat: iki yanda ikişer asker iki eliyle tutar (Soldier "haul": eller halatın üstünde), geriye
## yaslanıp "hey-ya" diye asılır; halat yolun üstünde hafif sarkık, askerlerin arkasında yerdeki kangala iner. Oyuncu
## geçip kadırga gelince bırakırlar: halat kızağa düşer, askerler geri çekilip kaçanı gösterir.
func _rope_team(o: Dictionary) -> void:
	var node: Node3D = o["node"]
	var s: float = o["s"]
	var span_root := Node3D.new()
	node.add_child(span_root)
	Stage.rope(span_root, Vector3(-(WIDTH + 0.7) / 2.0, 0.42, 0), Vector3((WIDTH + 0.7) / 2.0, 0.42, 0), 0.05, 0.045, Color("c9b48a"), 10)
	var tm := {"o": o, "span": span_root, "sides": [], "down": false, "shout": false}
	var coats := [Color("b3262d"), Color("2f5fa8"), Color("3f7a3a"), Color("c98a3a")]
	for side: int in [-1, 1]:
		var e := s_to_world(s, side * (WIDTH / 2.0 + 0.35), 0.42)
		var bg := _ground_at(s, side * (WIDTH / 2.0 + 3.0))
		var b := bg + Vector3(0, 1.2, 0)      # halat askerlerin elinde bel-göğüs hizasında (yolun üstünde 0,42 m: göz hizasından geçmez)
		var coil := _ground_at(s + 0.5, side * (WIDTH / 2.0 + 3.7))
		Stage.rope_coil(self, coil, 0.3, 3.5, 0.03, Color("b89a6a"))
		var main := _rope_make(self, 0.045, Color("c9b48a"))
		var tail := _rope_make(self, 0.035)
		var men: Array = []
		for k in 2:
			var dist := 1.5 + k * 0.85
			var zoff := 0.14 if k == 0 else -0.14
			var gp := _ground_at(s + zoff, side * (WIDTH / 2.0 + dist))
			var sol := Soldier.new(coats[(k + (side + 1)) % 4], "haul", "bork" if k == 0 else "turban")
			sol.set_meta("no_talk", true)
			sol.set_meta("no_unclip", true)
			sol.set_meta("no_turn", true)
			sol.rope = [e, b]
			add_child(sol)
			sol.global_position = gp
			sol.face_toward(Vector3(e.x, gp.y, e.z) + Vector3(0, 0, zoff * -0.8))
			men.append({"sol": sol, "home": gp, "t": randf_range(0.0, 1.5)})
		var sd := {"side": side, "e": e, "b": b, "coil": coil, "main": main, "tail": tail, "men": men}
		tm["sides"].append(sd)
		_rope_lines(sd, false)
	_rope_teams.append(tm)


func _rope_lines(sd: Dictionary, down: bool) -> void:
	var e: Vector3 = sd["e"]
	var b: Vector3 = sd["b"]
	var coil: Vector3 = sd["coil"]
	var c_top := coil + Vector3(0, 0.12, 0)
	if down:
		var ed := e + Vector3(0, -0.36, 0)
		var bd := Vector3(b.x, b.y - 1.16, b.z)
		_rope_set(sd["main"], _sag(ed, bd, 0.02, 6))
		_rope_set(sd["tail"], [bd, bd.lerp(c_top, 0.5) + Vector3(0, 0.03, 0.2), c_top])
	else:
		_rope_set(sd["main"], _sag(e, b, 0.04, 6))
		_rope_set(sd["tail"], _sag(b, c_top, 0.35, 8))


func _rope_drop(tm: Dictionary) -> void:
	tm["down"] = true
	var span: Node3D = tm["span"]
	span.create_tween().tween_property(span, "position:y", -0.36, 0.35).set_ease(Tween.EASE_IN)
	for sd: Dictionary in tm["sides"]:
		_rope_lines(sd, true)
		for m: Dictionary in sd["men"]:
			var sol: Soldier = m["sol"]
			_relax(sol)
			sol.pose = "point"
			var back: Vector3 = m["home"] + Vector3(float(sd["side"]) * 0.9, 0, 0)
			back.y = surface_h(back.x, back.z)
			sol.create_tween().tween_property(sol, "global_position", back, 0.5).set_trans(Tween.TRANS_SINE)


func _rope_raise(tm: Dictionary) -> void:
	tm["down"] = false
	tm["shout"] = false
	(tm["span"] as Node3D).position.y = 0.0
	for sd: Dictionary in tm["sides"]:
		_rope_lines(sd, false)
		for m: Dictionary in sd["men"]:
			var sol: Soldier = m["sol"]
			_relax(sol)
			sol.pose = "haul"
			sol.global_position = m["home"]
			sol.face_toward(Vector3((sd["e"] as Vector3).x, sol.global_position.y, sol.global_position.z))


## Pozdan poza geçerken IK'nin yazdığı kol/bacak dönüşleri sıfırlanır (öteki poz yalnız x eksenini yazıyor).
func _relax(sol: Soldier) -> void:
	var rg := sol.rig
	if rg == null:
		return
	for n: Node3D in [rg.arm_l, rg.arm_r, rg.elbow_l, rg.elbow_r, rg.leg_l, rg.leg_r, rg.knee_l, rg.knee_r]:
		if n:
			n.rotation = Vector3.ZERO
	if rg.body:
		rg.body.rotation = Vector3.ZERO
	sol.heave = 0.0


## Irgatın kızağı (yokuş aşağıda, ırgatın hizasında), koşumlu öküzler ve kızakları, kıçtaki fren halatları.
func _build_crews() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2205
	var rope_c := Color("b89a6a")
	# Irgatlar: dört asker kolları iterek makarayı döndürür, makara halatı sarar, kütük yüklü kızak yokuş yukarı
	# ırgata yanaşır. Varınca askerler kollara yaslanıp soluklanır (biri alnını siler).
	for cap: Node3D in _capstans:
		var s3: float = cap.get_meta("s3")
		var side: int = cap.get_meta("side")
		var turn := cap.get_node("Turn") as Node3D
		var sled := Node3D.new()
		sled.set_meta("no_bake", true)
		add_child(sled)
		_sled_model(sled)
		Props.bake_static(sled, sled.get_children())     # kızak tek parça çizilir (kızakla birlikte taşınır)
		var men: Array = []
		var k := 0
		for c in turn.get_children():
			if c is Soldier:
				# Dinlenirken "stand" pozuna geçer: o poz ilk karede askeri yerel konumunun yönüne çeviriyordu (kolun tersine)
				c.set_meta("no_turn", true)
				var a := k * PI / 2.0
				var d := Vector3(sin(a), 0, cos(a))
				_grips.append({"who": c, "frame": turn, "pts": [d * 1.12 + Vector3(0, 1.0, 0), d * 1.58 + Vector3(0, 1.0, 0)]})
				men.append(c)
				k += 1
		var sd := {"cap": cap, "turn": turn, "sled": sled, "rope": Stage.rope(self, Vector3.ZERO, Vector3(0, 0.1, 0), 0.0, 0.035, rope_c), "s3": s3, "side": side,
			"s": s3 + rng.randf_range(7.0, 9.6), "wait": rng.randf_range(0.0, 8.0), "speed": rng.randf_range(0.06, 0.09),
			"men": men, "moving": true, "rest": rng.randf_range(3.0, 8.0), "creak": null}
		_sleds.append(sd)
		_place_sled(sd)
	# Öküz takımları: iki öküz boyundurukta, boyunduruğun zinciri arkadaki kütük kızağına bağlı; kızağı yokuş yukarı ağır ağır
	# çekerek yürürler (yol kenarında, kendi şeritlerinde). Sürücü yanlarında yürür: bir eli öküzün sağrısında, öbüründe
	# üvendire. Takım düğümü her karede arazinin eğimine oturur (_tick_oxen). Eskiden koşumlu ama yerinde duruyorlardı.
	var ox_c := [Color("8a5a36"), Color("6a4a2a"), Color("b89868"), Color("4a3a2a")]
	for side: int in [-1, 1]:
		for i in 3:
			var s0: float = OX_S[i]
			var team := Node3D.new()
			team.set_meta("no_bake", true)
			add_child(team)
			for sx: float in [-0.75, 0.75]:
				# Öküz (tur 3): omzu yüksek, sağrısı alçalan gövde, hörgüç, boyun ve sarkık gerdan, lir biçimli boynuzlar,
				# kulaklar; bacaklar adım atar, kuyruk sallanır (eskiden silindir gövde, kutu kafa)
				var ox := _ox_model(team, ox_c[(i * 2 + int(sx > 0.0) + side + 1) % ox_c.size()], rng)
				(ox["root"] as Node3D).position = Vector3(sx, 0, 0)
				(ox["root"] as Node3D).rotation.y = PI
				ox["t"] = rng.randf_range(4.0, 14.0)
				ox["ph"] = rng.randf() * TAU + (PI * 0.5 if sx > 0.0 else 0.0)
				_oxen.append(ox)
			var still: Array = [Props.box(team, Vector3(2.3, 0.13, 0.15), Vector3(0, 1.66, -0.92), Color("5a3a22"))]
			for sx: float in [-0.75, 0.75]:
				for dx: float in [-0.3, 0.3]:
					still.append(Props.cyl(team, 0.025, 0.5, Vector3(sx + dx, 1.38, -0.95), Color("6a4a2c"), Vector3.ZERO, 4))
			var sl := Node3D.new()
			team.add_child(sl)
			_sled_model(sl)
			still.append(sl)
			sl.position = Vector3(0, 0, 3.7)
			# Zincir: boyunduruğun ortasından iki öküzün arasından kızağın kancasına (koyu, hafif sarkık)
			Stage.rope(team, Vector3(0, 1.55, -0.95), sl.position + Vector3(0, 0.3, -1.32), 0.25, 0.028, Color("4a4d52"), 8)
			Props.bake_static(team, still)      # boyunduruk, kızak ve kütükleri tek parça (öküzler canlı kalır)
			var herder := Soldier.new(Color("7a5232"), "stand", "turban")
			herder.set_meta("no_talk", true)
			herder.set_meta("no_turn", true)
			add_child(herder)
			_goad(herder)
			_grips.append({"who": herder, "frame": team, "pts": [Vector3(1.28, 1.12, -0.5)]})
			var tdict := {"team": team, "herder": herder, "side": side, "s0": s0, "s": s0 + 3.0, "start": s0 + 3.0, "end": s0 - 3.0, "moving": false}
			_teams.append(tdict)
			_oxen[-1]["team"] = tdict
			_oxen[-2]["team"] = tdict
			_place_team(tdict)
	# Fren halatları: kıçtaki babalara volta edilmiş kalın iki halat kızağın başındaki kazıklara iner, kazığa iki buçuk tur
	# sarılır; kazığın ardında birer asker halatın ucunu iki eliyle tutup geriye yaslanır, ucun fazlası yerde kangal.
	# Kadırga kalkınca halat kazıktan çözülür: kıçtaki babadan sarkıp kızakta kısa bir uç olarak sürüklenir (eskiden
	# kadırga indikçe yokuş boyunca 100 m'yi aşan, neye bağlı olduğu anlaşılmayan iki krem çizgi uzuyordu).
	for sx: float in [-1.0, 1.0]:
		var bol := Vector3(sx * 1.5, 0.0, 25.0)
		var stake := Node3D.new()
		track.add_child(stake)
		Props.cyl(stake, 0.17, 1.2, bol + Vector3(0, 0.5, 0), Color("4a3422"), Vector3.ZERO, 8)
		Props.cyl(stake, 0.21, 0.1, bol + Vector3(0, 1.12, 0), Color("3a2a1a"), Vector3.ZERO, 8)
		Props.bake_static(stake, stake.get_children())
		var wrap := Stage.rope_wrap(track, bol, 0.2, 0.62, 0.86, 2.5, 0.036, rope_c, -PI * 0.5)
		var a := bol + Vector3(0, 0.62, 0.2)
		var b := Vector3(sx * 1.5, 0.95, 28.6)
		var sn := Soldier.new(Color("b3262d") if sx < 0.0 else Color("2f5fa8"), "haul", "bork")
		sn.set_meta("no_talk", true)
		sn.rope = [a, b]
		track.add_child(sn)
		sn.position = Vector3(sx * 1.85, 0.0, 26.8)
		sn.rotation.y = PI + sx * 0.12
		_snubbers.append(sn)
		var coil := Vector3(sx * 1.6, 0.0, 29.4)
		var coil_mi := Stage.rope_coil(track, coil, 0.32, 3.5, 0.036, rope_c)
		var held := Stage.rope(track, a, b, 0.03, 0.036, rope_c, 6)
		var tail := Stage.rope(track, b, coil + Vector3(0, 0.14, 0), 0.3, 0.036, rope_c, 8)
		var line := Stage.rope(track, a, a + Vector3(0, 0, -1), 0.0, 0.042, rope_c)
		# Bırakılmış hâli: kıçtaki babadan kıç aynasının üstünden sarkıp kızakta sürüklenen kısa uç (kadırgayla taşınır)
		var bitt := _sk(Vector3(sx * 0.62, 3.0, 7.25))
		# Bırakılmış uç kızağa yatar, kıvrılır, ucu saçaklı (tur 3: eskiden yerde kısa, sert kenarlı bir boru gibiydi)
		var loose_pts: Array = [bitt, _sk(Vector3(sx * 0.66, 2.95, 7.85)), Vector3(sx * 0.8, 1.6, 8.3), Vector3(sx * 0.9, 0.35, 8.75),
			Vector3(sx * 1.02, 0.05, 9.3), Vector3(sx * 1.3, 0.04, 9.95), Vector3(sx * 1.38, 0.04, 10.6), Vector3(sx * 1.12, 0.04, 11.2),
			Vector3(sx * 0.86, 0.04, 11.75), Vector3(sx * 0.94, 0.04, 12.3)]
		var loose := Stage.rope(ship, bitt, bitt, 0.0, 0.038, rope_c)
		Stage.rope_to(loose, loose_pts)
		loose.visible = false
		var fr1 := _fray(ship, loose_pts[-1], (loose_pts[-1] as Vector3) - (loose_pts[-2] as Vector3), rope_c)
		fr1.visible = false
		# Kazıktan kayan halatın kalan ucu: kazığın dibinden kangala yere yatar, ucu saçaklı
		var tail_on: Array = Stage.sag_points(b, coil + Vector3(0, 0.14, 0), 0.3, 8)
		var t0 := bol + Vector3(sx * 0.12, 0.04, 0.32)
		var tail_off: Array = [t0, bol + Vector3(sx * 0.35, 0.04, 0.9), bol + Vector3(sx * 0.15, 0.04, 1.6), coil + Vector3(0, 0.05, -0.36), coil + Vector3(0, 0.12, -0.1)]
		var fr2 := _fray(track, t0, t0 - (tail_off[1] as Vector3), rope_c)
		fr2.visible = false
		_brakes.append({"x": sx, "bol": bol, "bitt": bitt, "line": line, "wrap": wrap, "held": held, "tail": tail, "coil": coil_mi,
			"loose": loose, "sn": sn, "on": true, "frays": [fr1, fr2], "tail_on": tail_on, "tail_off": tail_off})


## Halatın saçaklı ucu: tip noktasında, dir yönünde açılan birkaç ince lif (parent'ın yerelinde; tek ağ).
func _fray(parent: Node3D, tip: Vector3, dir: Vector3, col: Color) -> Node3D:
	var g := Node3D.new()
	parent.add_child(g)
	var d := Vector3(dir.x, 0.0, dir.z).normalized() if Vector2(dir.x, dir.z).length() > 0.001 else Vector3.FORWARD
	var sd := Vector3.UP.cross(d).normalized()
	for k in 6:
		var a := (k - 2.5) * 0.28
		var e := tip + (d * cos(a) + sd * sin(a)) * (0.12 + (k % 2) * 0.04) + Vector3(0, 0.005 * k, 0)
		_rod(g, tip, e, 0.008, col.lightened(0.1 if k % 2 == 0 else -0.1), 4)
	Props.bake_static(g, g.get_children())
	return g


## Öküz modeli (+Z ileri): döndürür {root, legs[4], head, tail}. Gövde köşe renkli tek ağ (omuz yüksek, sağrı alçak,
## karın sarkık), hörgüç, boyun, gerdan; baş, bacaklar, kuyruk ayrı (canlandırılır), her biri tek ağa pişer.
func _ox_model(parent: Node3D, coat: Color, rng: RandomNumberGenerator) -> Dictionary:
	var root := Node3D.new()
	parent.add_child(root)          # bake_static ağaçtaki düğümle çalışır
	var body := Node3D.new()
	root.add_child(body)
	var dark := coat.darkened(0.3)
	var light := coat.lightened(0.18)
	# Gövde: elips kesitler boyunca (z, merkez y, yarı en, yarı boy)
	var secs := [[-1.08, 1.2, 0.2, 0.2], [-0.88, 1.16, 0.37, 0.35], [-0.45, 1.1, 0.44, 0.42], [0.0, 1.07, 0.47, 0.45],
		[0.45, 1.15, 0.45, 0.49], [0.78, 1.21, 0.36, 0.42], [0.98, 1.3, 0.21, 0.25]]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	const N := 10
	var rings: Array = []
	for sc: Array in secs:
		var ring: Array = []
		for k in N:
			var a := TAU * k / N
			ring.append(Vector3(cos(a) * float(sc[2]), float(sc[1]) + sin(a) * float(sc[3]) * (1.0 if sin(a) > 0.0 else 1.08), float(sc[0])))
		rings.append(ring)
	var tri := func(a: Vector3, b: Vector3, c: Vector3) -> void:
		var n := (c - a).cross(b - a).normalized()
		var shade := Color.WHITE.lerp(Color(1.08, 1.05, 1.0), clampf(-n.y, 0.0, 1.0) * 0.6)
		for v: Vector3 in [a, b, c]:
			st.set_color(shade)
			st.set_normal(n)
			st.add_vertex(v)
	for i in rings.size() - 1:
		for k in N:
			var k2 := (k + 1) % N
			var a0: Vector3 = rings[i][k]
			var a1: Vector3 = rings[i][k2]
			var b0: Vector3 = rings[i + 1][k]
			var b1: Vector3 = rings[i + 1][k2]
			tri.call(a0, b0, a1)
			tri.call(a1, b0, b1)
	for e in 2:
		var ring: Array = rings[0] if e == 0 else rings[-1]
		var c := Vector3.ZERO
		for v: Vector3 in ring:
			c += v
		c /= N
		c.z += -0.06 if e == 0 else 0.06
		for k in N:
			if e == 0:
				tri.call(c, ring[k], ring[(k + 1) % N])
			else:
				tri.call(c, ring[(k + 1) % N], ring[k])
	var torso := MeshInstance3D.new()
	torso.mesh = st.commit()
	torso.material_override = Props.mat(coat)
	body.add_child(torso)
	Props.ball(body, 0.27, Vector3(0, 1.62, 0.48), coat.darkened(0.06), Vector3(0.85, 0.75, 1.25), 8)      # hörgüç
	_rod(body, Vector3(0, 1.36, 0.9), Vector3(0, 1.4, 1.22), 0.21, coat, 8)                               # boyun
	Props.ball(body, 0.3, Vector3(0, 0.98, 0.98), coat.darkened(0.12), Vector3(0.3, 1.0, 1.15), 8)          # gerdan
	Props.bake_static(body, body.get_children())
	# Baş: alnı geniş, burnu açık renk, lir biçimli boynuzlar, yana açık kulaklar
	var head := Node3D.new()
	head.position = Vector3(0, 1.4, 1.24)
	root.add_child(head)
	_rod(head, Vector3(0, 0.04, -0.04), Vector3(0, -0.24, 0.42), 0.16, coat, 7)
	Props.ball(head, 0.14, Vector3(0, -0.26, 0.45), Color("d9c4a2"), Vector3(1.0, 0.85, 1.0), 7)
	Props.ball(head, 0.17, Vector3(0, 0.05, 0.0), coat, Vector3(1.15, 0.9, 1.0), 7)
	for sx: float in [-1.0, 1.0]:
		var hc := Color("e6dcc4")
		_rod(head, Vector3(sx * 0.1, 0.13, 0.0), Vector3(sx * 0.33, 0.22, -0.04), 0.045, hc, 5)
		_rod(head, Vector3(sx * 0.33, 0.22, -0.04), Vector3(sx * 0.38, 0.45, 0.06), 0.034, hc, 5)
		_rod(head, Vector3(sx * 0.38, 0.45, 0.06), Vector3(sx * 0.32, 0.56, 0.12), 0.022, Color("3a3028"), 4)
		Props.ball(head, 0.1, Vector3(sx * 0.22, 0.0, -0.04), dark, Vector3(1.5, 0.45, 0.85), 6)
		Props.ball(head, 0.03, Vector3(sx * 0.13, -0.02, 0.17), Color("1a1410"), Vector3.ONE, 5)
		Props.ball(head, 0.022, Vector3(sx * 0.05, -0.3, 0.57), Color("2a1e18"), Vector3.ONE, 4)
	Props.bake_static(head, head.get_children())
	# Bacaklar: omuz/kalça ekleminde; arka bacakta diz (hock) geride
	var legs: Array = []
	for lp: Vector3 in [Vector3(-0.25, 0.98, 0.55), Vector3(0.25, 0.98, 0.55), Vector3(-0.25, 0.98, -0.7), Vector3(0.25, 0.98, -0.7)]:
		var leg := Node3D.new()
		leg.position = lp
		root.add_child(leg)
		var knee := Vector3(0, -0.5, 0.03) if lp.z > 0.0 else Vector3(0, -0.46, -0.13)
		_rod(leg, Vector3(0, 0.1, 0), knee, 0.11, coat, 7)
		_rod(leg, knee, Vector3(0, -0.9, 0.0), 0.06, coat.darkened(0.1), 6)
		Props.box(leg, Vector3(0.13, 0.08, 0.17), Vector3(0, -0.93, 0.02), Color("2a2420"))
		Props.bake_static(leg, leg.get_children())
		legs.append(leg)
	var tail := Node3D.new()
	tail.position = Vector3(0, 1.36, -1.08)
	root.add_child(tail)
	_rod(tail, Vector3.ZERO, Vector3(0, -0.72, -0.07), 0.026, coat.darkened(0.15), 5)
	Props.ball(tail, 0.07, Vector3(0, -0.78, -0.07), Color("2a2420"), Vector3(1, 1.9, 1), 5)
	Props.bake_static(tail, tail.get_children())
	for m in root.find_children("*", "GeometryInstance3D", true, false):
		(m as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if m.get_parent() != body else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return {"root": root, "legs": legs, "head": head, "tail": tail, "bellow": 0.0, "w": rng.randf() * TAU}


## Öküzün canlanması: takım yürürken çapraz adım (sol ön + sağ arka birlikte), baş adımla iner kalkar; dururken
## geviş getirir; kuyruk hep sallanır, arada sinek kovar gibi savrulur; ara sıra böğürür (baş kalkar).
func _tick_ox(o: Dictionary, delta: float) -> void:
	var tm: Dictionary = o.get("team", {})
	var moving: bool = tm.get("moving", false)
	o["w"] = float(o["w"]) + delta
	var w: float = o["w"]
	var legs: Array = o["legs"]
	if moving:
		o["ph"] = float(o["ph"]) + delta * 3.4
	var ph: float = o["ph"]
	for i in 4:
		var leg: Node3D = legs[i]
		var a := sin(ph + (0.0 if i in [0, 3] else PI)) * 0.32 if moving else 0.0
		leg.rotation.x = lerpf(leg.rotation.x, a, clampf(delta * 10.0, 0.0, 1.0))
	o["t"] = float(o["t"]) - delta
	if float(o["t"]) <= 0.0:
		o["t"] = randf_range(8.0, 18.0)
		o["bellow"] = 1.2
	o["bellow"] = maxf(0.0, float(o["bellow"]) - delta)
	var hx := 0.1 * sin(ph * 2.0) if moving else 0.03 * sin(w * 2.2)
	if float(o["bellow"]) > 0.0:
		hx = -0.55 * sin(clampf(float(o["bellow"]) / 1.2, 0.0, 1.0) * PI)
	var head: Node3D = o["head"]
	head.rotation.x = lerpf(head.rotation.x, hx + 0.12, clampf(delta * 6.0, 0.0, 1.0))
	head.rotation.y = 0.12 * sin(w * 0.37)
	var tail: Node3D = o["tail"]
	tail.rotation.z = 0.28 * sin(w * 1.9) + 0.35 * maxf(0.0, sin(w * 0.6)) * sin(w * 9.0)
	tail.rotation.x = 0.15 + 0.1 * sin(w * 1.3)


## Öküz takımını yokuşta s'e (ön), kendi şeridine (kenardan 4,5 m) koyar; takım arazinin eğimine oturur, sürücü sol yanda.
func _place_team(t: Dictionary) -> void:
	var team: Node3D = t["team"]
	var side: int = t["side"]
	var c := _side_xz(float(t["s"]), side, 4.5)
	var p0 := Vector3(c.x, surface_h(c.x, c.y), c.y)
	# Takımın yerel ekseni: +z yokuş aşağı (kızak arkada), +x dünyada -x (yaw 180)
	var pb := Vector3(c.x, surface_h(c.x, c.y - 3.7), c.y - 3.7)
	var ps := Vector3(c.x - 1.0, surface_h(c.x - 1.0, c.y), c.y)
	var zl := (pb - p0).normalized()
	var xl := (ps - p0)
	xl = (xl - zl * xl.dot(zl)).normalized()
	var yl := zl.cross(xl).normalized()
	team.global_transform = Transform3D(Basis(xl, yl, zl), p0 + Vector3(0, -0.04, 0))
	var herder: Soldier = t["herder"]
	var hp := team.to_global(Vector3(1.8, 0, -0.2))
	herder.global_position = Vector3(hp.x, surface_h(hp.x, hp.z), hp.z)
	herder.global_rotation = Vector3(0, 0.0, 0)      # yokuş yukarı (+z dünyada)


## Kütük kızağı (-Z önü): iki kızak ayağı, çapraz kalaslar, üç kütük, önde halat kancası.
func _sled_model(sl: Node3D) -> void:
	var wood := Color("6b4a2e")
	for sx: float in [-0.45, 0.45]:
		Props.box(sl, Vector3(0.12, 0.16, 2.5), Vector3(sx, 0.08, 0.05), wood.darkened(0.2))
		Props.box(sl, Vector3(0.12, 0.14, 0.45), Vector3(sx, 0.2, -1.3), wood.darkened(0.2), Vector3(35, 0, 0))
	for z: float in [-0.85, 0.0, 0.85]:
		Props.box(sl, Vector3(1.15, 0.08, 0.16), Vector3(0, 0.2, z), wood)
	for p: Vector3 in [Vector3(-0.22, 0.42, 0), Vector3(0.22, 0.42, 0), Vector3(0, 0.72, 0)]:
		Props.cyl(sl, 0.18, 2.2, p, C_LOG, Vector3(90, 0, 0), 8)
	for z: float in [-0.6, 0.6]:
		Props.box(sl, Vector3(0.7, 0.04, 0.05), Vector3(0, 0.92, z), Color("b89a6a"))
	Props.ring(sl, 0.06, 0.1, Vector3(0, 0.3, -1.32), Color("4a4d52"), Vector3(90, 0, 0))


## Sürücünün üvendiresi: sağ elde, ucunda küçük demir mıh
func _goad(sol: Soldier) -> void:
	var el: Node3D = sol.rig.elbow_r if sol.rig else null
	if el == null:
		return
	var g := Node3D.new()
	el.add_child(g)
	g.position = Vector3(0, -0.28, 0.06)
	Props.cyl(g, 0.02, 1.9, Vector3(0, 0.55, 0), Color("6a4a2c"), Vector3.ZERO, 5)
	Props.cyl(g, 0.012, 0.08, Vector3(0, 1.53, 0), Color("4a4d52"), Vector3.ZERO, 4)


func _place_sled(sd: Dictionary) -> void:
	var s: float = sd["s"]
	var side: int = sd["side"]
	var c := _side_xz(s, side, 3.2)
	var f := _side_xz(s - 1.1, side, 3.2)
	var bk := _side_xz(s + 1.1, side, 3.2)
	var fp := Vector3(f.x, surface_h(f.x, f.y), f.y)
	var bp := Vector3(bk.x, surface_h(bk.x, bk.y), bk.y)
	var sled: Node3D = sd["sled"]
	sled.global_transform = Transform3D(Basis.looking_at((fp - bp).normalized(), Vector3.UP), Vector3(c.x, (fp.y + bp.y) * 0.5, c.y))
	var hook := sled.to_global(Vector3(0, 0.3, -1.32))
	var cap: Node3D = sd["cap"]
	var drum := cap.global_position + Vector3(0, 0.55, 0)
	var to := Vector3(hook.x - drum.x, 0, hook.z - drum.z).normalized()
	_rope_set(sd["rope"], _sag(drum + to * 0.33, hook, 0.12, 8))


func _work_tick(delta: float) -> void:
	if ship == null:
		return
	var cam := get_viewport().get_camera_3d()
	var cam_s := world_to_s(cam.global_position) if cam else -100.0
	# Kızağın üstünde güneşte süzülen toz zerreleri: çok küçük ve soluk (iri olunca havada asılı beyaz kareler gibi
	# görünüyordu); sualtında kapalı
	if cam and _motes == null:
		_motes = Vfx.motes(cam, Vector3(5.0, 1.6, 6.0), 36, Color(1.0, 0.9, 0.7, 0.55))
		_motes.position = Vector3(0, -0.4, -6.5)
		_motes.scale_amount_min = 0.5
		_motes.scale_amount_max = 1.0
	if _motes:
		_motes.visible = not _underwater_on or _fog_air.is_empty()
	var ship_s := -ship.position.z
	if _ship_prev == INF:
		_ship_prev = ship_s
	var v := (ship_s - _ship_prev) / maxf(delta, 0.0001)
	if absf(ship_s - _ship_prev) > 4.0:
		v = 0.0      # yakalanınca geri sarılan kadırga ışınlanır
	_ship_v = lerpf(_ship_v, v, clampf(delta * 6.0, 0.0, 1.0))
	_ship_prev = ship_s
	_tick_sleds(delta)
	_tick_oxen(delta, cam_s)
	_tick_ship(delta, ship_s)
	_tick_track(delta, cam, cam_s, ship_s)
	_tick_water(delta, cam)
	_apply_grips(cam)


## Öküz takımları kızağı yokuş yukarı ağır ağır çeker (0,7 m/sn): oyuncu yaklaşınca yürümeye başlar, yolunun
## sonunda durur (soluklanır); oyuncu çok uzaktayken (geri sarma, başka yer) başa döner.
func _tick_oxen(delta: float, cam_s: float) -> void:
	for t: Dictionary in _teams:
		var s: float = t["s"]
		var near := cam_s > s - 45.0 and cam_s < s + 6.0
		t["moving"] = near and s > float(t["end"])
		if near and s > float(t["end"]):
			t["s"] = maxf(float(t["end"]), s - delta * 0.7)
			_place_team(t)
		elif not near and (cam_s < s - 70.0 or cam_s > s + 30.0) and s != float(t["start"]) and cam_s < float(t["start"]) - 60.0:
			t["s"] = t["start"]
			_place_team(t)


func _tick_sleds(delta: float) -> void:
	for sd: Dictionary in _sleds:
		var moving := false
		if sd["wait"] > 0.0:
			sd["wait"] = float(sd["wait"]) - delta
			moving = true
		elif float(sd["s"]) > float(sd["s3"]) + 3.1:
			var ds: float = float(sd["speed"]) * delta
			sd["s"] = float(sd["s"]) - ds
			(sd["turn"] as Node3D).rotation.y += ds / 0.32
			_place_sled(sd)
			moving = true
		else:
			# Kızak ırgata vardı: soluklanırlar, ara sıra biri alnının terini siler
			sd["rest"] = float(sd["rest"]) - delta
			if float(sd["rest"]) <= 0.0:
				sd["rest"] = randf_range(5.0, 11.0)
				var m: Soldier = (sd["men"] as Array).pick_random()
				if m.rig and m.rig.lock == 0:
					m.rig.emote("facepalm")
		if sd["wait"] > 0.0:
			moving = false
		if not moving:
			# Soluklanırken kollara yaslanır (dik dururken eller kola yetişmiyordu)
			for m: Soldier in sd["men"]:
				if m.rig and m.rig.lock == 0 and m.rig.body:
					m.rig.body.rotation.x = 0.32
		if moving != bool(sd["moving"]):
			sd["moving"] = moving
			for m: Soldier in sd["men"]:
				m.pose = "push" if moving else "stand"
			var cr = sd["creak"]
			if moving and cr == null:
				sd["creak"] = Audio.loop_at("wood_creak", sd["cap"], -20.0)
			elif not moving and cr != null and is_instance_valid(cr):
				(cr as AudioStreamPlayer3D).stop()
				sd["creak"] = null
	for o: Dictionary in _oxen:
		_tick_ox(o, delta)


func _tick_ship(delta: float, ship_s: float) -> void:
	var moving := _ship_v > 0.8
	# Pruvanın önündeki kütükler kadırgayla yuvarlanır, kızak kütüklerinden toz kalkar; sahte gölge kızağın ucunu geçmez
	for lg: Node3D in _bow_logs:
		lg.rotation.x -= _ship_v * delta / 0.3
	if _ship_dust:
		_ship_dust.emitting = moving
	if _ship_shadow:
		var room := LENGTH + 0.5 - (ship_s + 9.0)
		_ship_shadow.visible = room > 1.0
		_ship_shadow.scale = Vector3(1.0, 1.0, clampf(room / SHADOW_LEN, 0.05, 1.0))
		# Kadırga yaklaştıkça gölge koyulaşır (tur 4): 22 m'de soluk, 4 m'de koyu
		if _ship_shadow_mat:
			_ship_shadow_mat.albedo_color.a = lerpf(0.2, 0.7, clampf((22.0 - chase_gap) / 18.0, 0.0, 1.0))
	_push_ph += delta * clampf(_ship_v, 0.0, 8.0) * 1.9
	var ty := func(x: float, z: float) -> float: return track_y(x, z)
	for i in _pushers.size():
		var pu := _pushers[i]
		if pu.pose != "push":
			_relax(pu)
			pu.pose = "push"
		if pu.rig == null or pu.rig.body == null:
			continue
		# İtiş duruşu: gövde öne yatık; öndeki bacak bükük (diz önde), arkadaki geride gergin. Kadırga kayınca adım
		# sıklığı hızına bağlı koşu. Sonra tabanlar kızağa oturur (Stage.plant_feet), eller kıç aynasına (Stage.grip).
		pu.rig.body.rotation.x = 0.5 if not moving else 0.58
		for k in 2:
			var leg: Node3D = pu.rig.leg_l if k == 0 else pu.rig.leg_r
			var kn: Node3D = pu.rig.knee_l if k == 0 else pu.rig.knee_r
			if moving:
				var a := _push_ph + i * 1.3 + k * PI
				leg.rotation.x = sin(a) * 0.62 - 0.5
				kn.rotation.x = maxf(0.0, -cos(a)) * 1.05 + 0.2
			else:
				leg.rotation.x = -0.82 if k == 0 else 0.02
				kn.rotation.x = 0.95 if k == 0 else 0.1
		pu.rig.extremities()
		Stage.plant_feet(pu, ty)
	for sn: Soldier in _snubbers:
		if sn.pose != "haul":
			continue
		if moving:
			sn.heave = maxf(sn.heave, 0.85)      # halat kazıkta kayarken geriye asılır
		elif sn.heave <= 0.0 and randf() < delta * 0.4:
			sn.heave = 0.6
	# Fren halatları: kadırga kızağın başındayken bağlı (babadan kazığa sarkık eğri); kalkınca çözülüp kıçtan sürüklenir
	var attached := ship_s < -7.5
	for br: Dictionary in _brakes:
		if attached != bool(br["on"]):
			br["on"] = attached
			for key: String in ["line", "wrap", "held"]:
				(br[key] as Node3D).visible = attached
			(br["loose"] as Node3D).visible = not attached
			for fr: Node3D in br["frays"]:
				fr.visible = not attached
			_rope_set(br["tail"], br["tail_on"] if attached else br["tail_off"])
			var sn: Soldier = br["sn"]
			_relax(sn)
			sn.pose = "haul" if attached else "stand"
			if not attached and sn.rig:
				sn.rig.emote("surprise")
		if attached:
			var bw := track.to_local(ship.to_global(br["bitt"]))
			var stake: Vector3 = (br["bol"] as Vector3) + Vector3(0, 0.84, -0.2)
			_rope_set(br["line"], _sag(bw, stake, 0.12 + 0.01 * bw.distance_to(stake), 10))


func _tick_track(delta: float, cam: Camera3D, cam_s: float, ship_s: float) -> void:
	var bow := ship_s + 9.6
	var stern := ship_s - 7.7
	_tick_rollers(delta, cam_s, bow)
	# Su içen / alnını silen soluklananlar
	for dr: Dictionary in _drinkers:
		dr["t"] = float(dr["t"]) - delta
		var ds: Soldier = dr["sol"]
		if float(dr["t"]) <= 0.0 and is_instance_valid(ds) and ds.rig and ds.rig.lock == 0:
			dr["k"] = int(dr["k"]) + 1
			dr["t"] = randf_range(2.6, 4.2)
			ds.rig.emote("sip" if int(dr["k"]) % 3 != 0 else "facepalm")
	# Halat ekipleri: oyuncu yaklaşınca sık sık asılır ve bağırır; kadırga gelince bırakır
	for tm: Dictionary in _rope_teams:
		var o: Dictionary = tm["o"]
		if tm["down"]:
			continue
		var near := cam_s > float(o["s"]) - 16.0 and cam_s < float(o["s"]) + 1.0
		for sd: Dictionary in tm["sides"]:
			for m: Dictionary in sd["men"]:
				m["t"] = float(m["t"]) - delta
				if float(m["t"]) <= 0.0:
					(m["sol"] as Soldier).heave = 1.0
					m["t"] = randf_range(0.55, 0.9) if near else randf_range(1.5, 2.6)
		if near and not tm["shout"]:
			tm["shout"] = true
			Audio.sfx_at("heave_shout", (tm["sides"][0]["men"][0] as Dictionary)["sol"], -4.0)
		if o["resolved"] and bow > float(o["s"]) - 10.0:
			_rope_drop(tm)
	# Kütükler: sivri pruva yoldaki kütüğü iki yana iter
	for lg: Dictionary in _logs:
		# Sivri pruva kütüğe 4,5 m kala değer: kütük pruvanın önünde zıplayıp savrulur, gövde gelmeden yolun kenarına
		# yuvarlanır (eskiden 1 m kala itiliyordu, 0,4 sn'de kadırga üstünden geçiyor, kütük pruvaya saplanmış görünüyordu)
		if lg["kicked"] or bow < float(lg["o"]["s"]) - 4.5:
			continue
		lg["kicked"] = true
		var n: Node3D = lg["n"]
		var to: float = lg["to"]
		var from: Vector3 = n.position
		var dest := Vector3(to * 3.35, 0.42, from.z - randf_range(0.6, 1.4))
		var yaw := to * randf_range(0.9, 1.3)
		var tw := n.create_tween()
		tw.tween_method(func(t: float):
			if is_instance_valid(n):
				n.position = from.lerp(dest, t) + Vector3(0, sin(t * PI) * 0.55, 0)
				n.rotation = Vector3(t * to * -2.5, yaw * t, 0), 0.0, 1.0, 0.32).set_ease(Tween.EASE_OUT)
		Audio.sfx_at("land_thud", n, -6.0)
		Vfx.dust_puff(self, n.global_position + Vector3(0, -0.3, 0), 1.0)      # küçük, yumuşak, hızla dağılan toz (tur 3)
	# Yolu kesen asker: yanından geçen oyuncuya uzanır, kadırga gelince yoldan dışarı sıçrar
	for b: Dictionary in _blockers:
		var sol: Soldier = b["sol"]
		var o2: Dictionary = b["o"]
		if not b["grabbed"] and o2["resolved"] and cam:
			b["grabbed"] = true
			var lat := Vector2(cam.global_position.x - sol.global_position.x, cam.global_position.z - sol.global_position.z).length()
			if lat < 3.4 and absf(cam_s - float(o2["s"])) < 3.0:
				_grab_at(sol, cam.global_position + Vector3(0, -0.55, 0))
		# Oyuncu başka şeritten yaklaşıyorsa (çarpışma yok: engeli aşıyor) asker 7 m kala görünür biçimde kızağın dışına,
		# oyuncudan UZAK yana sıçrar; eskiden şeritte "ezilecek gibi" dikilip oyuncu hemen yanından geçiyordu. Aynı şeritten
		# gelene dokunulmaz (tökezleme ve yakalama aynen: engelin kuralı).
		if not b["leapt"] and cam and cam_s > float(o2["s"]) - 7.0 and cam_s < float(o2["s"]):
			var dx: float = track.to_local(cam.global_position).x - (b["sol"] as Node3D).position.x
			if absf(dx) > 1.4:
				b["out"] = -signf(dx)
				b["leapt"] = true
				_leap_aside(b)
		if not b["leapt"] and bow > float(o2["s"]) - 7.0:
			b["leapt"] = true
			_leap_aside(b)
	# Yağcılar: kadırga yanlarından geçerken kovalarıyla geri sıçrar, geçince işlerine döner
	for g: Dictionary in _greasers:
		var gs: float = g["s"]
		var covered := bow > gs - 5.0 and stern < gs + 2.0
		var sol: Soldier = g["sol"]
		if covered and not g["away"]:
			g["away"] = true
			sol.pose = "stand"
			_relax(sol)
			var tw2 := sol.create_tween()
			tw2.tween_property(sol, "global_position", g["out"], 0.45).set_trans(Tween.TRANS_SINE)
			tw2.tween_callback(func():
				sol.face_toward(ship.global_position)
				if sol.rig:
					sol.rig.emote("surprise"))
		elif not covered and g["away"] and stern > gs + 2.0:
			g["away"] = false
			var tw3 := sol.create_tween()
			tw3.tween_property(sol, "global_position", g["home"], 0.8).set_trans(Tween.TRANS_SINE)
			tw3.tween_callback(func():
				sol.face_toward(s_to_world(gs + 1.0, 0.0))
				_relax(sol)
				sol.pose = "grease")
	# Gözcüler: kaçan adam yanından geçerken düdük çalar (işaret edip bağırması pozunda)
	for sp: Dictionary in _spotters:
		if cam == null:
			break
		var d := (sp["sol"] as Node3D).global_position.distance_to(cam.global_position)
		var spo: Soldier = sp["sol"]
		if d < 9.0 and not sp["blown"]:
			sp["blown"] = true
			Audio.sfx_at("whistle", sp["sol"], -10.0)
			# Tokmağı bırakıp kaçanı gösterir, bağırır
			if not sp.get("fled", false):
				_relax(spo)
				spo.rig.activity = ""
				spo.pose = "point"
		elif d > 30.0:
			sp["blown"] = false
			if not sp.get("fled", false) and spo.pose == "point":
				_relax(spo)
				spo.pose = "stand"
				spo.rig.activity = "hammer"
				spo.global_rotation.y = float(sp["rot"])
		# Kadırga yaklaşınca: oyuncunun arkasına (gelen kadırgaya) dehşetle bakar, kollarını kaldırıp yamaca kaçışır
		var sol: Soldier = sp["sol"]
		var ss := world_to_s(sol.global_position)
		if not sp.get("fled", false) and ((bow > ss - 16.0 and bow < ss + 4.0) or (cam_s > ss - 4.0 and cam_s < ss + 3.0 and chase_gap < 11.0)):
			sp["fled"] = true
			if not sp.has("home"):
				sp["home"] = sol.global_position
			sol.pose = "stand"
			sol.rig.activity = ""
			_relax(sol)
			Audio.sfx_at("heave_shout", sol, -8.0)
			sol.face_toward(ship.global_position)
			var away: Vector3 = sp["home"] + Vector3(signf(world_to_x(sol.global_position)) * 2.2, 0, 0)
			away.y = surface_h(away.x, away.z)
			var from4 := sol.global_position
			var tw4 := sol.create_tween()
			tw4.tween_interval(0.25)
			tw4.tween_method(func(t: float):
				if is_instance_valid(sol):
					var q := from4.lerp(away, t)
					sol.global_position = Vector3(q.x, surface_h(q.x, q.z), q.z), 0.0, 1.0, 0.7).set_trans(Tween.TRANS_SINE)
			if sol.rig:
				sol.rig.emote("surprise")
		elif sp.get("fled", false) and bow < ss - 30.0:
			sp["fled"] = false
			sol.global_position = sp["home"]
			_relax(sol)
			sol.pose = "stand"
			sol.rig.activity = "hammer"
			sol.global_rotation.y = float(sp["rot"])


func _grab_at(sol: Soldier, target: Vector3) -> void:
	sol.pose = "stand"
	_relax(sol)
	await Stage.reach(sol, target, 0.25)
	if is_instance_valid(sol):
		sol.pose = "point"


## Yoldaki asker kadırganın önünden kızağın dışına sıçrar (kavisli atlayış), iner ve kaçanı gösterip bağırmayı sürdürür.
func _leap_aside(b: Dictionary) -> void:
	var sol: Soldier = b["sol"]
	var from := sol.position
	var out: float = b["out"]
	var land := s_to_world(world_to_s(sol.global_position), out * (WIDTH / 2.0 + 1.5))
	land.y = surface_h(land.x, land.z)
	var to := sol.get_parent_node_3d().to_local(land)
	sol.set_meta("airborne", true)
	var tw := sol.create_tween()
	tw.tween_method(func(t: float):
		if is_instance_valid(sol):
			sol.position = from.lerp(to, t) + Vector3(0, sin(t * PI) * 0.9, 0), 0.0, 1.0, 0.55).set_trans(Tween.TRANS_LINEAR)
	tw.tween_callback(func():
		if is_instance_valid(sol):
			sol.remove_meta("airborne")
			Audio.sfx_at("land_thud", sol, -12.0))


## Ellerin temas noktaları: asker kendi pozunu yazdıktan sonra (process_priority) eller noktaya oturur (Stage.grip).
## Uzaktakiler atlanır; emote oynayan (alın silen, şaşıran) kendi kolunu kullanır.
func _apply_grips(cam: Camera3D) -> void:
	var cp := cam.global_position if cam else Vector3.ZERO
	for g: Dictionary in _grips:
		var who: Soldier = g["who"]
		if not is_instance_valid(who) or who.rig == null or who.rig.lock > 0 or not who.is_visible_in_tree():
			continue
		if cam and who.global_position.distance_squared_to(cp) > 60.0 * 60.0:
			continue
		Stage.grip(who, g["frame"], g["pts"])


# ---------------------------------------------------------------- su: iz, halka, damla

func _tick_water(delta: float, cam: Camera3D) -> void:
	# Devriye kayığı: kıçında genişleyen iz, pruvasında köpük, palalar suya girdikçe halka ve sıçrama
	if boat and boat.visible and boat.is_inside_tree():
		var bp := boat.global_position
		var spd := 0.0
		if _boat_prev != Vector3.INF and delta > 0.0:
			spd = Vector2(bp.x - _boat_prev.x, bp.z - _boat_prev.z).length() / delta
		_boat_prev = bp
		var near := cam == null or cam.global_position.distance_to(bp) < 60.0
		if near and spd > 0.4 and spd < 30.0:
			_wake_t -= delta
			if _wake_t <= 0.0:
				_wake_t = 0.2
				# Kıç izi (tur 3: belirgin): kıçın iki yanından açılan köpük halkaları ve ortada kalın köpük
				ripple(boat.to_global(Vector3(0, 0, 2.7)), 0.6, 3.2, 2.4, 0.7)
				for sx: float in [-0.7, 0.7]:
					ripple(boat.to_global(Vector3(sx, 0, 2.2)), 0.3, 2.2, 1.8, 0.55)
				ripple(boat.to_global(Vector3(0, 0, -2.7)), 0.25, 1.2, 0.7, 0.7)
		if near:
			for oa: Dictionary in _boat_oars:
				var oar: Node3D = oa["oar"]
				var tip := oar.to_global(Vector3(float(oa["side"]) * float(oa["out"]), 0, 0))
				var wet := tip.y < water_y + 0.03
				if wet and not oa["wet"]:
					ripple(tip, 0.15, 1.1, 1.0, 0.6)
					drops(tip, 7)
					Audio.sfx_at("splash", boat, -26.0)
				oa["wet"] = wet
	else:
		_boat_prev = Vector3.INF
	# Yüzen kütük ve fıçılar: dalgada inip kalktıkça çevrelerinde ince halkalar
	_debris_t -= delta
	if _debris_t <= 0.0:
		_debris_t = 0.7
		for n: Node3D in swim_debris:
			if is_instance_valid(n) and n.visible and (cam == null or cam.global_position.distance_to(n.global_position) < 35.0) and randf() < 0.4:
				ripple(n.global_position, 0.9, 2.2, 1.6, 0.28)


## Suda genişleyip sönen ince halka (ortak: Vfx.water_ring).
func ripple(pos: Vector3, r0 := 0.4, r1 := 2.0, life := 1.4, alpha := 0.5) -> void:
	Vfx.water_ring(self, pos, water_y, r0, r1, life, alpha)


## Birkaç küçük damla: suya giren pala, kulaç atan el (ortak: Vfx.water_drops).
func drops(pos: Vector3, n := 8, up := 2.2, r := 0.022) -> void:
	Vfx.water_drops(self, pos, water_y, n, up, minf(r, 0.025))


## Sudan çıkanın giysisinden ve saçından damlayan su (ortak: Vfx.drip).
func drips(who: Node3D, seconds := 6.0, head: Node3D = null) -> void:
	Vfx.drip(who, seconds, head)


## Islak zemin: su birikintisi (ortak: Vfx.wet_mark, puddle).
func wet_spot(pos: Vector3, size: Vector2, yaw := 0.0, seconds := 30.0) -> void:
	Vfx.wet_mark(self, pos, yaw, false, seconds, maxf(size.x, size.y), true)


## Islak ayak izi (ortak: Vfx.wet_mark).
func wet_foot(pos: Vector3, yaw: float, left: bool, seconds := 40.0, normal := Vector3.UP) -> void:
	Vfx.wet_mark(self, pos, yaw, left, seconds, 1.0, false, normal)


## Okçunun yayından çıkan ok: kavis çizerek uçar, suya saplanınca sıçratır, bir süre suda kalıp batar.
func arrow_shot(from: Vector3, to: Vector3, dur: float) -> void:
	var a := MeshInstance3D.new()
	a.mesh = Assault.arrow_mesh()
	a.material_override = Crowd.material()
	a.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(a)
	var hit := Vector3(to.x, water_y + 0.05, to.z)
	var apex := 1.2 + from.distance_to(hit) * 0.08
	var at := func(t: float) -> Vector3:
		return from.lerp(hit, t) + Vector3(0, apex * 4.0 * t * (1.0 - t), 0)
	a.global_position = from
	var tw := a.create_tween()
	tw.tween_method(func(t: float):
		if not is_instance_valid(a):
			return
		var p: Vector3 = at.call(t)
		var q: Vector3 = at.call(minf(t + 0.02, 1.0)) if t < 0.98 else p + (p - at.call(t - 0.02))
		a.global_position = p
		if (q - p).length() > 0.001:
			a.look_at(q, Vector3.UP if absf((q - p).normalized().y) < 0.98 else Vector3.RIGHT)
			a.rotate_object_local(Vector3.UP, PI), 0.0, 1.0, dur)
	tw.tween_callback(func():
		splash(hit)
		ripple(hit, 0.2, 1.6, 1.2, 0.6)
		Audio.sfx_at("splash", a, -16.0)
		a.global_position = hit + (hit - from).normalized() * 0.25 + Vector3(0, -0.15, 0))
	tw.tween_interval(2.2)
	tw.tween_property(a, "position:y", water_y - 1.2, 1.0)
	tw.tween_callback(a.queue_free)


## Scenery._t, açıları derece olarak alır.
static func _td(pos: Vector3, deg := Vector3.ZERO, scl := Vector3.ONE) -> Transform3D:
	return Scenery._t(pos, deg * (PI / 180.0), scl)
