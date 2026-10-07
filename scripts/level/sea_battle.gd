class_name SeaBattle
extends RefCounted
## 20 Nisan 1453, Haliç'in ağzının dışı (Bölüm 29 ve 29o). SeaWalls'ın suyu, zinciri, deniz suru ve karşı kıyısı
## (Galata ve Diplokionion kıyısı, z 160–300) kullanılır; bu dosya savaşın kendisini kurar:
##   · Ceneviz karakası (nef): yüksek bordalı, baş ve kıç kasarası, iki direk, kare yelkenler (Cenova'nın kırmızı
##     haçı), güvertede tayfa. Küpeşte katıdır ve "rail" işaretlidir (kancalar buna takılır).
##   · Osmanlı savaş kadırgası: alçak, uzun, iki yanda kürekler ve kürekçiler, kıçta Baltaoğlu'nun tentesi, latin yelken.
##     Güvertesi yürünür (29o'da Tolga güvertede).
##   · Kıyı: Osmanlı ordusu, sancaklar ve Sultan atının üstünde. Sultan kıyıdan denize sürer (Fatih'in, gemiler
##     kurtulurken atını göğsüne kadar denize sürdüğü an kaynaklarda anlatılır).
##   · Gündüz: SeaWalls gece kurulur, make_day gökyüzünü ve ışığı 20 Nisan öğleden sonrasına çevirir.
## Koordinatlar SeaWalls'ınki: su y 0, zincir x 0 boyunca z 2–34, karşı kıyı z ~175'ten sonra.

const CARRACK_DECK := 4.6         # karakanın ana güvertesi (sudan)
const RAIL_TOP := 5.75            # küpeştenin üstü
const RAIL_X := 3.35              # küpeştenin gemi ekseninden uzaklığı
const GALLEY_DECK := 0.95
const GALLEY_RAIL_X := 1.75
## Savaşın yeri: karakalar kıyıya doğru sürüklenmiş, rüzgâr kesilmiş (kaynaklar: gemiler Diplokionion kıyısına yakın
## durdu, Sultan oradan izledi)
const BATTLE := Vector3(75.0, 0.0, 150.0)
const SULTAN_FROM := Vector3(66.0, 0.0, 194.0)
const SULTAN_TO := Vector3(70.0, 0.0, 171.0)
const C_HULL := Color("4a3424")
const C_GENOA := Color("c8262f")


## Karşı kıyının yüksekliği (SeaWalls._build_far_side ile aynı arazi)
## Tek harita (SeaWalls.in_world): karşı kıyı dünyanın kuzey kıyısıdır (yerel z ≈ 220); ordu ve Sultan oraya kayar
static var world_shift := 0.0


static func shore_y(x: float, z: float) -> float:
	if world_shift != 0.0:
		var w := World1453.to_world("horn_chain", Vector3(x, 0, z))
		return HornWorld.north_h(w.x, w.z) - World1453.SEA_Y
	var shore := smoothstep(160.0, 186.0, z)
	return (2.0 + sin(x * 0.03) * 6.0 + cos(x * 0.05 + 1.0) * 4.0 + (z - 170.0) * 0.12) * shore - 1.5 * (1.0 - shore)


## 20 Nisan, öğleden sonra: açık gök, alçalan güneş (gece meşaleleri söner)
static func make_day(walls: SeaWalls) -> void:
	for c in walls.get_children():
		if c is WorldEnvironment:
			var e := (c as WorldEnvironment).environment
			if e.sky and e.sky.sky_material is ProceduralSkyMaterial:
				var sm := e.sky.sky_material as ProceduralSkyMaterial
				sm.sky_top_color = Color("4a86c8")
				sm.sky_horizon_color = Color("d8e2ea")
				sm.ground_horizon_color = Color("8aa0b0")
				sm.ground_bottom_color = Color("2a3a48")
			e.ambient_light_color = Color("c8ccd4")
			e.ambient_light_energy = 0.85
			e.fog_light_color = Color("c8d4e0")
			e.fog_density = 0.0025
		elif c is DirectionalLight3D:
			(c as DirectionalLight3D).light_color = Color("fff0d8")
			(c as DirectionalLight3D).light_energy = 1.25
			(c as DirectionalLight3D).rotation_degrees = Vector3(-34, 120, 0)
	for l in walls.lights:
		if l is OmniLight3D:
			(l as OmniLight3D).light_energy = 0.0
	walls.niko.visible = false
	if walls.world:
		walls.world.set_mode("day")


## Akşam: rüzgâr döner, gök kızarır (gemiler zincire kayar)
static func make_dusk(walls: SeaWalls) -> void:
	for c in walls.get_children():
		if c is WorldEnvironment:
			var e := (c as WorldEnvironment).environment
			if e.sky and e.sky.sky_material is ProceduralSkyMaterial:
				var sm := e.sky.sky_material as ProceduralSkyMaterial
				sm.sky_top_color = Color("4a5a8a")
				sm.sky_horizon_color = Color("f0a070")
			e.ambient_light_color = Color("c8a8a0")
			e.ambient_light_energy = 0.7
			e.fog_light_color = Color("c89880")
		elif c is DirectionalLight3D:
			(c as DirectionalLight3D).light_color = Color("ffb878")
			(c as DirectionalLight3D).light_energy = 0.9
			(c as DirectionalLight3D).rotation_degrees = Vector3(-10, 100, 0)


# ================================================================ karaka

## Ceneviz karakası. Döner: düğüm; meta "crew" (Person dizisi), "sails" (yelken düğümleri), "rails" (StaticBody).
## Gemi +Z'ye (baş -Z) bakar; yan bordalar ±X.
static func carrack(parent: Node3D, pos: Vector3, yaw: float, crew_n := 8, seed := 1) -> Node3D:
	var g := Node3D.new()
	parent.add_child(g)
	g.position = pos
	g.rotation.y = yaw
	g.add_child(LowPoly.hull([
		{"z": -12.5, "w": 0.25, "top": 7.6, "bottom": 3.2},
		{"z": -9.0, "w": 3.0, "top": 6.6, "bottom": -1.0},
		{"z": -3.0, "w": 3.55, "top": 5.9, "bottom": -1.7},
		{"z": 4.0, "w": 3.5, "top": 6.0, "bottom": -1.6},
		{"z": 9.0, "w": 3.0, "top": 7.2, "bottom": -0.8},
		{"z": 11.5, "w": 2.3, "top": 8.4, "bottom": 1.2},
	], C_HULL, Color("6a2a20"), 4.2))
	var wood := Color("a8845a")
	# Ana güverte ve kasaralar (katı: 29'da Tolga güvertede yürür)
	Props.solid(g, Vector3(6.6, 0.24, 17.0), Vector3(0, CARRACK_DECK - 0.12, -0.5), wood)
	Props.solid(g, Vector3(5.6, 0.24, 3.4), Vector3(0, 6.3, -9.6), wood.darkened(0.1))
	Props.solid(g, Vector3(5.6, 0.24, 4.4), Vector3(0, 7.0, 9.4), wood.darkened(0.1))
	# Kasara duvarları (güverteden yukarı, göze çarpan boyalı kalkan sırası)
	Props.solid(g, Vector3(6.0, 1.7, 0.2), Vector3(0, CARRACK_DECK + 0.85, -7.9), C_HULL.lightened(0.05))
	Props.solid(g, Vector3(6.0, 2.4, 0.2), Vector3(0, CARRACK_DECK + 1.2, 7.2), C_HULL.lightened(0.05))
	var rails: Array = []
	for sx: float in [-1.0, 1.0]:
		var r := Props.solid(g, Vector3(0.22, 1.15, 15.2), Vector3(sx * RAIL_X, CARRACK_DECK + 0.58, -0.3), C_HULL.lightened(0.12))
		r.set_meta("rail", true)
		r.set_meta("no_climb", true)
		rails.append(r)
		# Küpeştenin iç yanında savaş basamağı: tayfa bunun üstünde, göğsü küpeştenin üstünde (aşağıdan görünür)
		Props.solid(g, Vector3(0.7, 0.75, 14.6), Vector3(sx * (RAIL_X - 0.46), CARRACK_DECK + 0.375, -0.3), C_HULL.lightened(0.2))
		for k in 6:
			Props.ring(g, 0.32, 0.4, Vector3(sx * (RAIL_X + 0.12), CARRACK_DECK + 0.6, -5.5 + k * 2.2), [C_GENOA, Color("e8e0d0")][k % 2], Vector3(0, 0, 90))
	g.set_meta("rails", rails)
	# Direkler ve kare yelkenler (Cenova'nın kırmızı haçı)
	var sails: Array = []
	for spec in [[-1.0, 23.0, 7.0], [-7.5, 16.0, 5.2], [7.8, 12.0, 0.0]]:
		var mz: float = spec[0]
		var h: float = spec[1]
		var w: float = spec[2]
		Props.cyl(g, 0.22, h, Vector3(0, CARRACK_DECK + h * 0.5, mz), Color("5a3e26"), Vector3.ZERO, 8)
		if w <= 0.0:
			# Mizana: latin yelken
			var lat := Node3D.new()
			lat.position = Vector3(0, CARRACK_DECK + h * 0.6, mz)
			g.add_child(lat)
			Props.cyl(lat, 0.07, 9.0, Vector3.ZERO, Color("6a4a2c"), Vector3(55, 0, 0), 5)
			Props.box(lat, Vector3(0.05, 4.0, 4.4), Vector3(0.1, -0.6, 0.4), Color("ece2c8"), Vector3(-35, 0, 0))
			continue
		var yard := Node3D.new()
		yard.position = Vector3(0, CARRACK_DECK + h * 0.72, mz + 0.35)
		g.add_child(yard)
		Props.cyl(yard, 0.1, w * 1.25, Vector3(0, w * 0.5, 0), Color("6a4a2c"), Vector3(0, 0, 90), 6)
		var sail := Node3D.new()
		sail.set_meta("w", w)
		yard.add_child(sail)
		Props.box(sail, Vector3(w * 1.1, w * 0.95, 0.06), Vector3(0, 0, 0), Color("ece2c8"))
		Props.box(sail, Vector3(w * 0.18, w * 0.9, 0.08), Vector3(0, 0, 0.01), C_GENOA)
		Props.box(sail, Vector3(w * 1.05, w * 0.16, 0.08), Vector3(0, w * 0.1, 0.01), C_GENOA)
		sail.scale.z = 0.4         # rüzgârsız: yelken sarkık
		sails.append(sail)
	g.set_meta("sails", sails)
	# Kıçta Cenova sancağı
	Props.cyl(g, 0.05, 3.0, Vector3(0, 7.0 + 1.5, 11.0), Color("5a3e26"), Vector3.ZERO, 5)
	Props.box(g, Vector3(0.04, 1.0, 1.5), Vector3(0, 9.4, 11.8), Color("f4f1ea"))
	Props.box(g, Vector3(0.05, 1.0, 0.22), Vector3(0, 9.4, 11.8), C_GENOA)
	Props.box(g, Vector3(0.05, 0.2, 1.5), Vector3(0, 9.45, 11.8), C_GENOA)
	# Tayfa: küpeşte boyunca, bordaya dönük (kalkan, mızrak, taş)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var crew: Array = []
	for i in crew_n:
		var sx := -1.0 if i % 2 == 0 else 1.0
		var p := Person.new({"coat": [Color("8a8e96"), Color("2f4a6a"), Color("6a2a24"), Color("5a6a7a")][i % 4], "pants": Color("2a2226"),
			"hat": ["helm", "berretta", "helm", ""][i % 4], "mustache": i % 3 != 0, "beard": i % 2 == 0})
		p.set_meta("no_talk", true)
		p.position = Vector3(sx * (RAIL_X - 0.42), CARRACK_DECK + 0.75, -5.6 + (i / 2) * 2.9 + rng.randf_range(-0.3, 0.3))
		p.rotation.y = sx * PI * 0.5
		g.add_child(p)
		crew.append(p)
	g.set_meta("crew", crew)
	return g


## Yelkenleri rüzgârla şişir (0 sarkık … 1 dolu)
static func fill_sails(ship: Node3D, k: float) -> void:
	for s: Node3D in ship.get_meta("sails", []):
		s.scale.z = lerpf(0.4, 3.2, k)
		s.position.z = lerpf(0.0, 0.5, k)


# ================================================================ kadırga

## Osmanlı savaş kadırgası: uzun, alçak; yürünür güverte, alçak katı küpeşte, iki yanda kürekler ve kürekçiler.
## Döner: düğüm; meta "rowers", "oars", "captain" (kıçtaki reis yerinin yerel konumu).
static func war_galley(parent: Node3D, pos: Vector3, yaw: float, rowers := true, flag := true) -> Node3D:
	var g := Node3D.new()
	parent.add_child(g)
	g.position = pos
	g.rotation.y = yaw
	g.add_child(LowPoly.hull([
		{"z": -12.0, "w": 0.1, "top": 1.6, "bottom": 0.8},
		{"z": -8.0, "w": 1.6, "top": 1.25, "bottom": -0.3},
		{"z": 0.0, "w": 1.9, "top": 1.2, "bottom": -0.45},
		{"z": 7.0, "w": 1.7, "top": 1.3, "bottom": -0.3},
		{"z": 10.0, "w": 1.0, "top": 1.9, "bottom": 0.5},
	], Color("3a2a1c"), Color("7e2420"), 0.95))
	Props.solid(g, Vector3(3.4, 0.2, 18.0), Vector3(0, GALLEY_DECK - 0.1, -0.5), Color("8a6a4a"))
	for sx: float in [-1.0, 1.0]:
		var b := Props.solid(g, Vector3(0.16, 0.55, 17.0), Vector3(sx * GALLEY_RAIL_X, GALLEY_DECK + 0.27, -0.5), Color("5a3a24"))
		b.set_meta("no_climb", true)
	# Mahmuz (baş uzantısı) ve kıçtaki tente
	Props.cyl(g, 0.12, 4.0, Vector3(0, 1.5, -13.6), Color("4a3220"), Vector3(80, 0, 0), 6)
	for k in 4:
		Props.cyl(g, 0.05, 2.2, Vector3(-1.2 + (k % 2) * 2.4, GALLEY_DECK + 1.1, 6.4 + (k / 2) * 2.4), Color("4a3220"), Vector3.ZERO, 5)
	Props.box(g, Vector3(2.8, 0.06, 3.0), Vector3(0, GALLEY_DECK + 2.2, 7.6), Color("b3262d"))
	# Latin yelkenli direk (yelken sarılı: savaşta kürekle gidilir)
	Props.cyl(g, 0.12, 9.0, Vector3(0, GALLEY_DECK + 4.5, -3.0), Color("5a3e26"), Vector3.ZERO, 6)
	Props.cyl(g, 0.08, 12.0, Vector3(0, GALLEY_DECK + 8.0, -3.0), Color("6a4a2c"), Vector3(60, 0, 0), 5)
	Props.cyl(g, 0.2, 7.0, Vector3(0, GALLEY_DECK + 7.0, -2.0), Color("e6dcc4"), Vector3(60, 0, 0), 6)
	if flag:
		Props.box(g, Vector3(0.04, 1.0, 1.6), Vector3(0, GALLEY_DECK + 9.4, -3.8), Color("b3262d"))
		Props.crescent(g, Vector3(0, GALLEY_DECK + 9.4, -3.9), 0.24, Color("b3262d"))
	var oars: Array = []
	for i in 9:
		var z := -6.5 + i * 1.5
		for sx: float in [-1.0, 1.0]:
			var oar := OarGrip.make_oar(g, Vector3(sx * 1.8, GALLEY_DECK + 0.45, z), sx, 1.0, 4.0, 0.04, Vector2(0.7, 0.22), 0.0)
			oar.set_meta("bench", i)
			oars.append(oar)
	g.set_meta("oars", oars)
	g.set_meta("rowers", [])
	if rowers:
		for sx: float in [-1.0, 1.0]:
			add_rowers(g, sx, false)
	return g


## Kürekçiler (kıça bakar) ve kürekleri: `side` tarafında çift (odd false) ya da tek sıralara. Iskarmoz kürekçinin
## yarım metre kıç tarafında: sap önünden geçer, iki eli sapta (OarGrip). Kürekçisi olmayan kürek dinlenir.
## `avoid`: oyuncunun durduğu yerler (teknenin yerelinde): oraya kürekçi oturmaz.
static func add_rowers(g: Node3D, side: float, odd: bool, avoid: Array = [], hat := "") -> void:
	var rws: Array = g.get_meta("rowers", [])
	for o: Node3D in g.get_meta("oars", []):
		var i: int = o.get_meta("bench", 0)
		if float(o.get_meta("side")) != side or (i % 2 == 1) != odd or o.has_meta("manned"):
			continue
		var seat := Vector3(side * 1.0, 0.0, o.position.z - 0.5)
		if avoid.any(func(a: Vector3) -> bool: return Vector2(a.x - seat.x, a.z - seat.z).length() < 1.2):
			continue
		var r := Person.new({"coat": [Color("6a5040"), Color("5a6a7a"), Color("7a4a3a"), Color("e8e0d0")][(i + int(side)) % 4],
			"pants": Color("e8e0d0"), "hat": hat if hat != "" else ("bork" if side > 0.0 else "turban"), "mustache": true})
		r.set_meta("no_talk", true)
		r.position = Vector3(side * 1.0, GALLEY_DECK, o.position.z - 0.5)
		g.add_child(r)
		r.set_activity("row")
		r.rig.row_phase = Rig.ROW_REST
		OarGrip.attach(r, [[o, "both"]])
		o.set_meta("manned", true)
		rws.append(r)
	g.set_meta("rowers", rws)


## Oyuncunun oturduğu yerin küreği (pruvaya bakar: sapı iterek çeker). Kürek oyuncunun yarım metre önüne alınır;
## hayalet kürekçi tayfayla aynı evreden çeker (row_oars).
static func player_oar(g: Node3D, seat: Vector3) -> void:
	var best: Node3D = null
	for o: Node3D in g.get_meta("oars", []):
		if signf(o.position.x) == signf(seat.x) and (best == null or absf(o.position.z - seat.z) < absf(best.position.z - seat.z)):
			best = o
	if best == null:
		return
	best.position.z = seat.z - 0.5
	best.set_meta("manned", true)
	var ph := OarGrip.phantom(g, Transform3D(Basis(Vector3.UP, PI), Vector3(seat.x, GALLEY_DECK, seat.z)), [[best, "both"]], 0.0, true)
	g.set_meta("phantoms", [ph])


## Kürekçiler evreyle (RowMeter evresi `ph`) çeker; moving false iken kürek başında dinlenir. Kürekleri ve elleri
## kürekçinin OarGrip'i sürer; kürekçisi olmayan kürek kıpırdamaz.
static func row_oars(galley: Node3D, ph: float, moving: bool) -> void:
	var sp := OarGrip.meter(ph) if moving else Rig.ROW_REST
	for r: Person in galley.get_meta("rowers", []):
		if is_instance_valid(r) and r.rig:
			r.rig.row_phase = sp
	for g: OarGrip in galley.get_meta("phantoms", []):
		if is_instance_valid(g):
			g.phase = sp


# ================================================================ kanca

## Bordaya takılmış kanca ve aşağıdaki kadırgaya inen ip (dünya koordinatlarıyla). Döner: düğüm (silinince ip kopar).
static func hook(parent: Node3D, top: Vector3, bottom: Vector3) -> Node3D:
	var h := Node3D.new()
	parent.add_child(h)
	h.global_position = top
	var iron := Color("3a3a40")
	Props.cyl(h, 0.04, 0.5, Vector3(0, 0.1, 0), iron, Vector3.ZERO, 5)
	for k in 3:
		var a := TAU * k / 3.0
		Props.cyl(h, 0.03, 0.32, Vector3(cos(a) * 0.12, 0.32, sin(a) * 0.12), iron, Vector3(sin(a) * 60.0, 0, -cos(a) * 60.0), 4)
	var d := bottom - top
	var rope := Props.cyl(h, 0.025, d.length(), Vector3.ZERO, Color("b89a6a"), Vector3.ZERO, 4)
	rope.global_transform = Transform3D(Basis(Quaternion(Vector3.UP, d.normalized())), top + d * 0.5)
	return h


# ================================================================ kıyı

## Diplokionion kıyısı: ordu, sancaklar, Sultan atının üstünde. Döner {"horse", "sultan", "army"}.
static func shore(parent: Node3D) -> Dictionary:
	var army: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 2004
	for i in 46:
		var x := rng.randf_range(30.0, 120.0)
		var z := rng.randf_range(186.0, 204.0) + world_shift
		if Vector2(x, z).distance_to(Vector2(SULTAN_FROM.x, SULTAN_FROM.z + world_shift)) < 5.0:
			continue
		var s := Soldier.new([Color("2f5fa8"), Color("b3262d"), Color("e8e0d0"), Color("3a6b3a")][i % 4], "stand",
			["bork", "turban", "bork", "helm"][i % 4])
		s.set_meta("no_talk", true)
		s.position = Vector3(x, shore_y(x, z), z)
		s.rotation.y = PI + rng.randf_range(-0.4, 0.4)       # denize (−Z) bakar
		parent.add_child(s)
		if i % 3 == 0:
			s.equip("spear")
		army.append(s)
	for k in 7:
		var x := 36.0 + k * 13.0
		var z := 196.0 + (k % 2) * 4.0 + world_shift
		var y := shore_y(x, z)
		Props.cyl(parent, 0.06, 6.0, Vector3(x, y + 3.0, z), Color("4a3420"), Vector3.ZERO, 5)
		Props.box(parent, Vector3(0.04, 1.4, 2.2), Vector3(x, y + 5.0, z + 1.1), [Color("b3262d"), Color("2e6a3a"), Color("e8e0d0")][k % 3])
	var horse := Horse.new(Color("e4e0d8"))
	parent.add_child(horse)
	var sultan := Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	sultan.set_meta("spk", "SPK_FATIH")
	horse.mount(sultan)
	horse.position = Vector3(SULTAN_FROM.x, shore_y(SULTAN_FROM.x, SULTAN_FROM.z + world_shift), SULTAN_FROM.z + world_shift)
	horse.rotation.y = PI
	return {"horse": horse, "sultan": sultan, "army": army}


## Sultan'ın atı kıyıdan denize iner: t 0 kıyıda … 1 su göğsüne kadar (deniz dibine basar, su 1,1 m yukarıda)
static func ride_in(horse: Horse, t: float) -> void:
	var p := SULTAN_FROM.lerp(SULTAN_TO, clampf(t, 0.0, 1.0)) + Vector3(0, 0, world_shift)
	p.y = maxf(shore_y(p.x, p.z), -1.15)
	horse.position = p
	horse.speed = 1.2 if t > 0.0 and t < 1.0 else 0.0
