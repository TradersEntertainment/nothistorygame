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

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const WALL_Z0 := 0.0
const WALL_Z1 := 4.6
const WALK_Y := 12.0
const WALL_H := 12.0
const TOWERS := [-40.0, -20.0, 20.0, 40.0]
const C_STONE := Color("c8b89a")
const C_BRICK := Color("9a5040")

var lights: Array = []
## Tek harita: çevre (sur devamı, şehir, ordugâh, Haliç) World1453.surround ile kurulur; buradaki uzak siluetler kurulmaz
var in_world := true
var world: SiegeField
var moon: DirectionalLight3D
var ladder_gaps: Array = []        # x'ler: dış korkulukta merdiven açıklığı
## Canlı savunanlar: bu x aralığındaki sur yolu adamları uzak kalabalık (MultiMesh) yerine bölümün kurduğu canlı
## WallGuard olur (oyuncuya döner, yaklaşınca mızrakla dürter). night_assault yerlerini live_spots'a yazar.
var live_range := Vector2(1.0, -1.0)
var live_spots: Array[Transform3D] = []
## Bu kulenin tepesi boş kalır (bölüm oraya kendi tüfekçisini koyar)
var quiet_tower := INF
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
	if in_world:
		# Oynanış alanı: surun iki yanı (x ±70), içeride avlu, dışarıda yamaç
		world = World1453.surround(self, "blachernae", [Rect2(-75.0, -62.0, 150.0, 130.0)])
		_join_tower()


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)
	if not _climbers.is_empty():
		_update_climbers(delta)


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
func build_guards(gaps: Array, inner_open := true) -> void:
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
	# İç kenar: merdiven başında açıklık (Bizans tarafı iner); Osmanlı bölümünde kapalı (şehre inilmez)
	for seg: Vector2 in ([Vector2(-60.0, -7.4), Vector2(-4.6, 60.0)] if inner_open else [Vector2(-60.0, 60.0)]):
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
	if in_world:
		return
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
	if in_world:
		return
	# Uzakta ordu ateşleri
	for i in 18:
		var p := Vector3(rng.randf_range(-60.0, 60.0), 0, rng.randf_range(70.0, 110.0))
		p.y = slope_y(p.z)
		lights.append(Night.campfire(self, p, 0.9))


## Blakherna'nın tek suru ile Theodosius'un çifte suru birleştiği yerde köşe kulesi (x +60), ve kuzey ucunda Haliç'e
## inen kule (x −60)
func _join_tower() -> void:
	for tx: float in [62.0, -62.0]:
		var tw := Props.solid(self, Vector3(9.0, WALL_H + 7.0, 9.0), Vector3(tx, (WALL_H + 7.0) * 0.5, (WALL_Z0 + WALL_Z1) * 0.5), Color.WHITE)
		Props.set_pattern(tw, C_STONE.darkened(0.06), "ashlar")
		for y: float in [4.0, 9.0, 14.0]:
			Props.box(self, Vector3(9.04, 0.45, 9.04), Vector3(tx, y, (WALL_Z0 + WALL_Z1) * 0.5), C_BRICK)


# ---------------------------------------------------------------- 12 Mayıs gece hücumu (sahne dolgusu)

var _climbers: Array = []          # {p: Person, lad: Ladder, t, speed, fall}

## Sura dayalı hücum merdivenleri (tırmanan, düşen azaplar), merdiven ayağında bekleyen ve kalkan tutan bölükler,
## sur yolunda savunanlar (meşale, mızrak, yay), sur dibinde yanan çömlekler. skip: bölümün kendi merdiveni (x).
func night_assault(skip: Array, ottoman_side := true) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1205
	var lh := WALK_Y + 0.6
	var x := -54.0
	while x < 56.0:
		var near := false
		for sx: float in skip:
			if absf(x - sx) < 7.0:
				near = true
		# Kulelerin (8 m genişlik, surdan 3,6 m taşar) önüne merdiven dayanmaz: tırmananlar ve ayağında bekleyenler
		# kulenin içinde kalıyordu
		for tx: float in TOWERS:
			if absf(x - tx) < 6.2:
				near = true
		if not near:
			var lad := Ladder.new(lh, 14.0 + rng.randf_range(-2.0, 3.0), Color("6a4a2c").darkened(rng.randf_range(0.0, 0.25)))
			lad.position = Vector3(x + rng.randf_range(-1.0, 1.0), 0.0, WALL_Z1 + lh * sin(deg_to_rad(lad.tilt)) + 0.12)
			add_child(lad)
			lad.set_meta("no_climb", true)
			for k in rng.randi_range(1, 3):
				var p := Person.new(BattleExtras.osm_look(int(x * 7.0) + k))
				p.set_meta("no_talk", true)
				p.set_meta("no_yield", true)
				p.set_meta("climber", true)
				add_child(p)
				p.set_activity("climb_a")
				p.rotation.y = PI
				_climbers.append({"p": p, "lad": lad, "t": rng.randf_range(0.0, lh - 2.0) - k * 2.4, "speed": rng.randf_range(0.5, 0.9), "fall": -1.0})
			# Ayağında sırasını bekleyenler: hasır kalkan başlarının üstünde
			for k in 3:
				var w := Person.new(BattleExtras.osm_look(int(x * 3.0) + 40 + k))
				w.set_meta("no_talk", true)
				add_child(w)
				# Merdivenin önündeki sıranın (tırmanmayı bekleyenler) iki yanında: içlerine girmesinler
				w.position = lad.position + Vector3((1.0 if k % 2 == 0 else -1.0) * rng.randf_range(0.75, 1.4), 0, 1.6 + k * 1.1)
				w.rotation.y = PI
				BattleExtras.overhead_shield(w, [Color("8a2a2a"), Color("2e4a7a"), Color("6a4a2a")][k], false, true)
		x += rng.randf_range(9.0, 13.0)
	# Ovada: hasır siperlerin ardında okçular (sura ateş eder), arkada mızraklı yedek bölükler ve meşaleler.
	# Bölümün yolu (skip x ±7) boş kalır.
	var items: Array = []
	var gx := -58.0
	while gx < 58.0:
		var clear := true
		for sx: float in skip:
			if absf(gx - sx) < 7.0:
				clear = false
		if clear:
			var mz := WALL_Z1 + 20.0 + rng.randf_range(-1.5, 1.5)
			var mant := Props.box(self, Vector3(2.6, 1.9, 0.25), Vector3(gx, 0.95, mz), Color("66502f"), Vector3(-12.0, rng.randf_range(-8.0, 8.0), 0))
			mant.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			for k in 2:
				items.append([Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.2, 0.2)), Vector3(gx - 0.7 + k * 1.4, 0, mz + 1.0)),
					{"side": "O", "coat": [Color("2e4a7a"), Color("7a2a24"), Color("6a4a2a")][k + int(gx) % 2], "hat": "bork", "arm": "bow", "pose": "aim"}])
			for r in 3:
				for k in 3:
					items.append([Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.15, 0.15)), Vector3(gx - 1.0 + k * 1.0 + rng.randf_range(-0.2, 0.2), 0, mz + 18.0 + r * 1.3)),
						Crowd.ott(int(gx) + r * 3 + k, "spear")])
			if int(gx) % 3 == 0:
				lights.append(Night.torch(self, Vector3(gx + 1.6, 0, mz + 17.0), 1.2))
		gx += rng.randf_range(6.0, 8.0)
	Crowd.place(self, items)
	# Sur dibinde yanan ateş çömlekleri ve kırık merdivenler
	for i in 9:
		var p := Vector3(rng.randf_range(-55.0, 55.0), 0.1, WALL_Z1 + rng.randf_range(0.8, 4.0))
		lights.append(Night.campfire(self, p, 0.5))
	for i in 6:
		var b := Props.box(self, Vector3(0.7, 0.12, rng.randf_range(3.0, 6.0)), Vector3(rng.randf_range(-50.0, 50.0), 0.1, WALL_Z1 + rng.randf_range(2.0, 9.0)), Color("5a3e26"),
			Vector3(0, rng.randf() * 180.0, rng.randf_range(-8.0, 8.0)))
		b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Sur yolunda savunanlar (oynanış merdiveninin çevresi boş: orada bölümün kendi dövüşü var)
	var men: Array = []
	var mx := -58.0
	while mx < 58.0:
		var near2 := false
		for sx: float in skip:
			if absf(mx - sx) < 9.0:
				near2 = true
		for tx: float in TOWERS:
			if absf(mx - tx) < 4.4:
				near2 = true
		if not near2:
			_man(men, Transform3D(Basis(Vector3.UP, rng.randf_range(-0.3, 0.3)), Vector3(mx, WALK_Y, WALL_Z1 - 1.0)))
		mx += rng.randf_range(2.6, 4.2)
	Garrison.far_men(self, men, Garrison.COATS)
	_wall_works(skip, rng)
	# Ovanın geri kalanı: büyük gece hücumunun ordusu (bölükler, sura koşan dalgalar, ateşler, mehter). Kuzeyde
	# (x < −55) Haliç başlar; güneyde (x > 60) Theodosius surlarının önü
	var army := NightArmy.new()
	army.field = Rect2(-52.0, WALL_Z1 + 26.0, 172.0, 96.0)
	army.wall_z = WALL_Z1
	army.skip = skip
	army.blocks = 14
	army.runners = 140
	add_child(army)
	army.build()


## Sur yolunun savunma donanımı ve ikinci sıra savunanlar: iç kenar boyunca taş yığınları, kaynayan yağ kazanları
## (mangalda), ok demetleri, fıçılar, kalkanlar; kulelerde sancaklar. Bölümün kendi dövüş alanı (skip ±8) ve taş
## merdivenin başı (x −9…−3) boş kalır; eşyalar alçak ve iç kenarda, yol açık.
func _wall_works(skip: Array, rng: RandomNumberGenerator) -> void:
	var d := Dressing.new(1206)
	var nd := Dressing.new(1207)
	var zi := WALL_Z0 + 0.55
	var men: Array = []
	var x := -57.0
	var k := 0
	while x < 57.0:
		var busy := x > -9.5 and x < -2.5
		for sx: float in skip:
			if absf(x - sx) < 8.0:
				busy = true
		for tx: float in TOWERS:
			if absf(x - tx) < 4.5:
				busy = true
		if not busy:
			var y := WALK_Y
			match k % 5:
				0:      # taş yığını (aşağı atılacak)
					for i in 7:
						d.ball(rng.randf_range(0.18, 0.3), Vector3(x + rng.randf_range(-0.5, 0.5), y + 0.15 + (i / 4) * 0.25, zi + rng.randf_range(-0.2, 0.25)),
							C_STONE.darkened(rng.randf_range(0.1, 0.35)), Vector3(1.1, 0.8, 1.0), 6)
				1:      # mangalda kaynayan yağ kazanı
					d.cyl(0.32, 0.25, Vector3(x, y + 0.13, zi), Color("2a2622"), Vector3.ZERO, 8)
					d.cyl(0.42, 0.5, Vector3(x, y + 0.5, zi), Color("3a3430"), Vector3.ZERO, 10, 0.85)
					nd.glow(Vector3(0.5, 0.18, 0.5), Vector3(x, y + 0.22, zi), Color("ff8a30"))
					nd.glow(Vector3(0.6, 0.6, 0.6), Vector3(x, y + 1.0, zi), Color(1.0, 0.75, 0.4, 0.35))
				2:      # ok demetleri ve dayalı kalkanlar
					for i in 3:
						d.cyl(0.12, 0.9, Vector3(x - 0.4 + i * 0.4, y + 0.45, zi), Color("8a6a40"), Vector3(rng.randf_range(-8, 8), 0, rng.randf_range(-8, 8)), 6)
					d.cyl(0.42, 0.06, Vector3(x + 0.9, y + 0.5, zi - 0.15), Color("7a2a24"), Vector3(70, 0, 0), 12)
				3:      # fıçı ve sandık
					d.barrel(Vector3(x, y, zi))
					d.crate(Vector3(x + 0.8, y, zi), 0.55, rng.randf_range(-20, 20))
				4:      # mangal (ısınma ve ok ucu yakma)
					d.cyl(0.08, 0.7, Vector3(x, y + 0.35, zi), Color("3a3634"), Vector3.ZERO, 5)
					d.cyl(0.35, 0.18, Vector3(x, y + 0.78, zi), Color("2a2622"), Vector3.ZERO, 8)
					nd.glow(Vector3(0.45, 0.35, 0.45), Vector3(x, y + 0.95, zi), Color("ffa040"))
			# İkinci sıra: ok atan, taş taşıyan
			if rng.randf() < 0.6:
				_man(men, Transform3D(Basis(Vector3.UP, rng.randf_range(-0.4, 0.4)), Vector3(x + rng.randf_range(0.8, 1.6), WALK_Y, WALL_Z1 - 2.2)))
			k += 1
		x += rng.randf_range(3.6, 5.2)
	d.build(self)
	nd.build(self)
	if not men.is_empty():
		Garrison.far_men(self, men, Garrison.COATS)
	# Kulelerde sancaklar (çift başlı kartal: kırmızı üstüne altın) ve kule tepesinde okçular
	var tm: Array = []
	for tx: float in TOWERS:
		var top := WALL_H + 5.0
		Props.cyl(self, 0.06, 5.0, Vector3(tx, top + 2.5, WALL_Z1 + 1.6), Color("4a3420"), Vector3.ZERO, 5)
		Props.box(self, Vector3(0.04, 1.6, 2.4), Vector3(tx, top + 4.0, WALL_Z1 + 2.8), Color("8a1a2a"))
		Props.box(self, Vector3(0.05, 0.7, 0.7), Vector3(tx, top + 4.0, WALL_Z1 + 2.8), Color("d8b040"))
		if absf(tx - quiet_tower) < 1.0:
			continue
		for s2: float in [-2.4, 0.0, 2.4]:
			tm.append(Transform3D(Basis(Vector3.UP, rng.randf_range(-0.3, 0.3)), Vector3(tx + s2, top, WALL_Z1 + 4.4)))
	Garrison.far_men(self, tm, Garrison.COATS)


## Sur yolu adamı: canlı aralıktaysa live_spots'a, değilse uzak kalabalığa
func _man(men: Array, xf: Transform3D) -> void:
	if xf.origin.x >= live_range.x and xf.origin.x <= live_range.y:
		live_spots.append(xf)
	else:
		men.append(xf)


func _update_climbers(delta: float) -> void:
	# Aynı merdivendekiler arasında en az 2 m (merdivende bir boy, aşağıda sırada 0,8 m): hızlısı yavaşın içine girmez
	var by_lad := {}
	for c: Dictionary in _climbers:
		if float(c["fall"]) < 0.0 and is_instance_valid(c["p"]):
			var k: int = (c["lad"] as Node).get_instance_id()
			if not by_lad.has(k):
				by_lad[k] = []
			(by_lad[k] as Array).append(c)
	for k in by_lad:
		var line: Array = by_lad[k]
		line.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["t"]) > float(b["t"]))
		for i in range(1, line.size()):
			line[i]["t"] = minf(float(line[i]["t"]), float(line[i - 1]["t"]) - 2.0)
	for c: Dictionary in _climbers:
		var p: Person = c["p"]
		var lad: Ladder = c["lad"]
		if not is_instance_valid(p):
			continue
		if float(c["fall"]) >= 0.0:
			c["fall"] = float(c["fall"]) + delta
			var f: float = c["fall"]
			p.position += Vector3(0, -9.0 * f * delta, 1.6 * delta)
			p.rotation.x = minf(f * 2.0, 1.5)
			if p.position.y <= 0.15:
				p.position.y = 0.15
				if f > 3.0:
					# Yeniden başlar (sahne dolgusu: merdiven hiç boşalmaz)
					c["fall"] = -1.0
					c["t"] = -3.0
					p.rotation.x = 0.0
			continue
		c["t"] = float(c["t"]) + float(c["speed"]) * delta
		var t: float = c["t"]
		if t >= lad.height - 1.2:
			c["fall"] = 0.0            # tepede itilir (savunanlar)
			continue
		p.position = lad.point_at(maxf(t, 0.0)) + lad.front_dir() * 0.35 - Vector3(0, 0.9, 0) if t > 0.0 else lad.position + Vector3(0, 0, 1.0 - t * 0.4)
		# İlk basamaklarda ayak yerin altına inmesin (eskiden merdivenin dibinde 0,9 m toprağa gömülü başlıyordu)
		p.position.y = maxf(p.position.y, lad.position.y)
		if t > 2.0 and fmod(t * 7.3 + float(lad.position.x), 37.0) < 0.05:
			c["fall"] = 0.0
