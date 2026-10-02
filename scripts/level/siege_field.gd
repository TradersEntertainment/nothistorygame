class_name SiegeField
extends Node3D
## Kara surlarının iki yanı, 1453 Nisan–Mayıs (LandWalls koordinatları: x sur boyunca, +z ovaya; dış sur z 14–16).
## LandWalls'ın 100 metrelik kesitinin dışında kalan her şey buradadır:
##   · sur devamı: iç ve dış sur, kuleler, peribolos, hendek iki yana ufka kadar; yer yer top yarası ve moloz
##   · şehir: iç surun ardında yamaçlara yayılan evler, kiliseler, serviler; uzakta Ayasofya; gece pencereler
##   · ölü bölge (z 36–95): gülle çukurları, dağınık gülleler, taşlar, saplanmış oklar, mantolar ve sepet siperler
##   · Osmanlı siperi (z ~112): hendek, toprak set, önüne eğik kazık çit; setin önünde top bataryaları
##     (sepet siper, kaldırılmış ahşap perde, tunç top, gülle piramidi, barut fıçıları, topçular)
##   · ordu: gündüz sancaklı bölükler, gece ateş başında halkalar; gidip gelen askerler (her kare yürür)
##   · ordugâh: sırtlara yayılan yüzlerce çadır, at sıraları, ocak dumanları; Maltepe'de padişahın kırmızı otağı
## keep: hiçbir şey konmayan dikdörtgenler (x, z). open: yalnız düz zemin izleri (çukur, ok, gülle) konan alanlar.
## assault: son hücum bölümleri (Assault ordusu ortayı doldurur): ortada yakın siper ve bölük yok.

const EXT := 700.0             # arazi ve sur uzantısının yarı genişliği
const WALL_X0 := 50.0          # LandWalls'ın kendi kesiti x ±50'ye kadar
const RAMPART_Z := 112.0
const BATTERY_Z := 99.0
const STONE := Color("cdbd9e")
const WOOD := Color("7a5634")
const WICKER := Color("66502f")
const EARTH := Color("5a4630")
const GAPS := [-70.0, 70.0, -210.0, 210.0, -350.0, 350.0, -490.0, 490.0, -630.0, 630.0]   # siperdeki geçitler
const LANE_Z := 116.8          # setin hemen ardındaki yol (bölüklerin ve ateşlerin önünde, boş)
const COATS := [Color("b3262d"), Color("2f5fa8"), Color("3a6b3a"), Color("8a6a4a"), Color("6a4a3a"), Color("c98a3a")]

var keep: Array = []
var open: Array = []
## Tek harita (World1453): LandWalls'ın kesiti yoksa (Blakherna bölümleri) sur ortası da burada kurulur; surun kuzey ucu
## wall_x_min'de biter (oradan Blakherna suru ve Haliç başlar).
var fill_center := false
var wall_x_min := -EXT
## Düz tutulacak zemin dikdörtgenleri (bölgenin kendi zemini; tepeler içinden çıkmasın)
static var flat_rects: Array = []
static var flat_y := -0.03
## > 0: dünya zemini bölgenin düz alanına bu mesafede yumuşakça iner (tepelerin ortasındaki bölgeler: Petrion, Galata)
static var flat_blend := 0.0
## Boş değilse rampa bu dikdörtgenlerden ölçülür (flat_rects o zaman yalnız bölgenin kendi arazisinin altı: dünya batar)
static var blend_rects: Array = []


## Düz alanların çevresinde rampa: h, kenarda fy'ye iner
static func flat_mix(h: float, x: float, z: float, fy: float) -> float:
	if flat_blend <= 0.0:
		return h
	var dmin := INF
	for r: Rect2 in (blend_rects if not blend_rects.is_empty() else flat_rects):
		var dx := maxf(maxf(r.position.x - x, 0.0), x - r.end.x)
		var dz := maxf(maxf(r.position.y - z, 0.0), z - r.end.y)
		dmin = minf(dmin, sqrt(dx * dx + dz * dz))
	# Yalnız tepeler iner; deniz dibi (h < fy) yükselmez
	return minf(h, lerpf(fy, h, smoothstep(0.0, flat_blend, dmin)))
var near_works := true
## Tek harita: Haliç, kıyı surları, şehrin doğu yarısı, Galata, Boğaz ve Marmara (HornWorld) da kurulur
var world := true
var region_name := ""
var horn: HornWorld
var night_build := true
## Şehir ve ova zemini kıyılarda suya iner (yalnız tek harita kuruluyken)
static var world_on := false
var assault := false
var bombard := false

var rng := RandomNumberGenerator.new()
var _t := 0.0
var _guns: Array = []          # {muzzle: Vector3, dir: Vector3, t: float}
var _walkers: Array = []       # {mm, i, a, b, k, speed, phase}
var _night: Array[Node3D] = []
var _day: Array[Node3D] = []
var _smoke_root: Node3D
var _flying: Array = []
var _byz_flags: Node3D          # kulelerde Bizans sancakları (fetihten sonra inerler)
var _wall_men: Node3D           # surlarda nöbetçiler (fetihten sonra yoklar)
var _flag_spots: Array = []


func build() -> void:
	rng.seed = 1453407
	_smoke_root = Node3D.new()
	add_child(_smoke_root)
	if world:
		world_on = true
		wall_x_min = maxf(wall_x_min, World1453.WALL_N_X)
	_terrain()
	_wall_extension()
	if world:
		horn = HornWorld.new()
		horn.region_name = region_name
		horn.keep = keep
		horn.night = night_build
		add_child(horn)
		horn.build()
	elif wall_x_min > -EXT:
		_horn_end()
	_city()
	_no_mans_land()
	_trench()
	_batteries()
	_great_gun_works()
	_troops()
	_walkers_build()
	_camp()
	_otag()
	set_mode("night")


# ---------------------------------------------------------------- zemin

## Ova: sur önünde düz (oynanan alanlar, bataryalar); z 140'tan sonra alçak sırtlar, en arkada Maltepe;
## iki yanda vadinin yamaçları (Lykos vadisi).
## Düz alanda dünya zemini bölgenin altına batar (bölgenin kendi arazisi varsa) ya da bölgenin zemini olur
static func flat_sink() -> float:
	return 2.0 if flat_blend <= 0.0 or not blend_rects.is_empty() else 0.0


## raw: bölgenin düz alanlarını yok say (bölgenin arazisi kenarında dünyayla buluşsun diye)
static func ground(x: float, z: float, raw := false) -> float:
	if not raw:
		for r in flat_rects:
			if (r as Rect2).has_point(Vector2(x, z)):
				return flat_y - (flat_sink() if blend_rects.size() > 0 else 0.0)
	var ax := absf(x)
	var r := smoothstep(135.0, 330.0, z)
	var h := r * (4.0 + 3.0 * sin(x * 0.019 + 0.6) + 2.2 * cos(z * 0.017 + x * 0.011))
	h += smoothstep(320.0, 820.0, z) * 22.0
	h += 16.0 * exp(-(pow((x - 30.0) / 110.0, 2.0) + pow((z - 480.0) / 80.0, 2.0)))
	# Lykos vadisinin yamaçları; kuzey ucunda (Blakherna önü, x < −560) ova yeniden düzleşir (Haliç'e iner)
	h += smoothstep(260.0, 700.0, ax) * smoothstep(40.0, 170.0, z) * 26.0 * (1.0 - smoothstep(-470.0, -600.0, x))
	if world_on:
		# Haliç'in iç kolu (−x) ve Marmara (+x) kıyısında suya iner
		var d := maxf(x - 690.0, World1453.HORN_S_X + 10.0 - x)
		h = lerpf(h, -4.0, smoothstep(-6.0, 12.0, d))
	return flat_mix(h - 0.03, x, z, flat_y)


## Şehir tarafı: iç surun hemen ardı düz, sonra şehrin tepeleri.
static func city_ground(x: float, z: float) -> float:
	# İç surun ardındaki 100 m düz (Bölüm 26'da Mese'ye giden cadde burada), sonra şehrin tepeleri
	for fr in flat_rects:
		if (fr as Rect2).has_point(Vector2(x, z)):
			return flat_y - 0.02
	var r := smoothstep(-100.0, -300.0, z)
	var h := r * (5.0 + 4.0 * sin(x * 0.012 + 1.3) + 3.0 * cos(z * 0.02)) + smoothstep(-300.0, -700.0, z) * 14.0 * (1.0 - smoothstep(-1300.0, -1700.0, z) * 0.6) - 0.05
	if world_on:
		# Kıyı surlarının dışı: Haliç ve Marmara'ya iner
		var d := maxf(World1453.HORN_S_X - x, x - World1453.marmara_x(z))
		d = maxf(d, World1453.TIP.z - z)
		h = lerpf(h, -4.0, smoothstep(0.0, 14.0, d))
	return flat_mix(h, x, z, flat_y - 0.02)


func _terrain() -> void:
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		var grass := Color("56663a").lerp(Color("7a7048"), clampf(0.5 + 0.5 * sin(x * 0.043 + z * 0.031), 0.0, 1.0) * 0.55)
		# Ölü bölge ve batarya kuşağı: çiğnenmiş, kararmış toprak
		var trampled := 1.0 - smoothstep(118.0, 170.0, z)
		var c := grass.lerp(Color("5a4a34"), trampled * 0.9).darkened(clampf(steep * 0.6, 0.0, 0.3))
		# Uzak tepeler havanın rengine çalar (hava perspektifi): ufukta koyu bant kalmasın
		return c.lerp(Color("7a8a80"), smoothstep(420.0, 860.0, z) * 0.55)
	add_child(LowPoly.terrain(-EXT, EXT, 36.0, 900.0, 56, 36, ground, cf))
	var ccf := func(x: float, z: float, y: float, steep: float) -> Color:
		return Color("7a7050").lerp(Color("5a6a40"), clampf(0.5 + 0.5 * sin(x * 0.05 - z * 0.04), 0.0, 1.0) * 0.6).darkened(clampf(steep * 0.5, 0.0, 0.25))
	add_child(LowPoly.terrain(-EXT, EXT, -700.0, -3.0, 56, 28, city_ground, ccf))


# ---------------------------------------------------------------- sur devamı

## İç surun kurulacak aralıkları (|x| a0..b0, sx yönünde): keep dikdörtgenlerinin iç sur hattını kestiği yerler çıkarılır
func _inner_spans(sx: float, a0: float, b0: float) -> Array:
	var spans: Array = [Vector2(a0, b0)]
	for r: Rect2 in keep:
		if r.position.y > -2.3 or r.end.y < -2.3:
			continue
		var c0 := minf(sx * r.position.x, sx * r.end.x)
		var c1 := maxf(sx * r.position.x, sx * r.end.x)
		var out: Array = []
		for sp: Vector2 in spans:
			if c1 <= sp.x or c0 >= sp.y:
				out.append(sp)
				continue
			if c0 > sp.x:
				out.append(Vector2(sp.x, c0))
			if c1 < sp.y:
				out.append(Vector2(c1, sp.y))
		spans = out
	return spans


func _wall_extension() -> void:
	var len := EXT - WALL_X0
	var d := Dressing.new(71)
	d.chunk = 160.0
	var fd := Dressing.new(70)
	fd.chunk = 160.0
	var merl: Array = []
	var merl_o: Array = []
	for sx: float in [-1.0, 1.0]:
		var a0 := 0.0 if fill_center else WALL_X0
		var b0 := EXT if sx > 0.0 else minf(EXT, -wall_x_min)
		len = b0 - a0
		var cx := sx * (a0 + len * 0.5)
		# Zemin: peribolos, dış surun önündeki set, korkuluk, hendek (dibi -3), iki yanı
		Props.box(self, Vector3(len, 0.4, 15.4), Vector3(cx, -0.2, 6.6), Color("6e6452"))
		Props.box(self, Vector3(len, 0.4, 4.0), Vector3(cx, -0.2, 17.6), Color("6e6452"))
		Props.box(self, Vector3(len, 1.6, 0.8), Vector3(cx, 0.6, 19.2), STONE.darkened(0.1))
		Props.box(self, Vector3(len, 0.2, 16.0), Vector3(cx, -3.0, 28.0), Color("3a3a30"))
		Props.box(self, Vector3(len, 3.0, 0.6), Vector3(cx, -1.5, 20.0), STONE.darkened(0.3))
		Props.box(self, Vector3(len, 3.0, 0.6), Vector3(cx, -1.5, 36.0), Color("4a4436"))
		# İç sur (12 m) ve dış sur (8 m). İç sur, bölgenin kendi iç suru olan yerde (ByzCity: Romanos Kapısı) kesilir.
		for span: Vector2 in _inner_spans(sx, a0, b0):
			var sl := span.y - span.x
			Props.set_pattern(Props.box(self, Vector3(sl, LandWalls.INNER_H, 3.4), Vector3(sx * (span.x + sl * 0.5), LandWalls.INNER_H * 0.5, -2.3), Color.WHITE), STONE, "ashlar")
		Props.set_pattern(Props.box(self, Vector3(len, LandWalls.OUTER_H, 2.0), Vector3(cx, LandWalls.OUTER_H * 0.5, 15.0), Color.WHITE), STONE.darkened(0.05), "ashlar")
		var x := a0 + 1.0
		while x < b0:
			if _free(sx * x, -2.3, 0.5):
				merl.append(Transform3D(Basis.from_scale(Vector3(1.2, 1.0, 0.8)), Vector3(sx * x, LandWalls.INNER_H + 0.5, -0.9)))
			x += 2.0
		x = a0 + 0.5
		while x < b0:
			merl_o.append(Transform3D(Basis.from_scale(Vector3(1.1, 0.9, 0.7)), Vector3(sx * x, LandWalls.OUTER_H + 0.45, 15.7)))
			x += 1.8
		# İç sur kuleleri (55 m arayla; LandWalls'ın ±24'teki kulelerinin devamı) ve aralarda dış sur kuleleri
		var tx := 24.0 if fill_center else 79.0
		while tx < b0 - 10.0:
			var h := rng.randf_range(17.0, 20.0)
			var wx := sx * tx
			if not _free(wx, -2.3, 5.0):
				tx += 55.0
				continue
			var body := Props.box(self, Vector3(9.0, h, 8.0), Vector3(wx, h * 0.5, 0.0), Color.WHITE)
			Props.set_pattern(body, STONE.darkened(0.03), "ashlar")
			d.box(Vector3(9.8, 0.5, 8.8), Vector3(wx, h + 0.25, 0.0), STONE.darkened(0.12))
			for k in 8:
				var mx := -4.2 + (k % 4) * 2.8
				var mz := -3.8 if k < 4 else 3.8
				d.box(Vector3(1.1, 1.0, 1.0), Vector3(wx + mx, h + 1.0, mz), STONE.darkened(0.08))
			for k in 3:
				d.box(Vector3(0.8, 1.4, 0.1), Vector3(wx - 2.5 + k * 2.5, LandWalls.INNER_H + 2.0, 4.03), Color("1c1814"))
			if rng.randf() < 0.5:
				d.box(Vector3(0.12, 3.2, 0.12), Vector3(wx, h + 2.6, 0.0), Color("3a2a1e"))
				fd.box(Vector3(0.03, 1.1, 1.6), Vector3(wx, h + 3.6, 0.8), Color("8a1a2a") if rng.randf() < 0.5 else Color("d8b040"))
				_flag_spots.append(Vector3(wx, h + 3.6, 0.8))
			var ox := sx * (tx + 27.5)
			if absf(ox) < b0 - 6.0:
				var oh := LandWalls.OUTER_H + 3.0
				var ob := Props.box(self, Vector3(5.0, oh, 5.0), Vector3(ox, oh * 0.5, 17.0), Color.WHITE)
				Props.set_pattern(ob, STONE.darkened(0.08), "ashlar")
				for k in 4:
					d.box(Vector3(1.0, 0.9, 1.0), Vector3(ox + (k % 2 - 0.5) * 4.0, oh + 0.45, 17.0 + (k / 2 - 0.5) * 4.0), STONE.darkened(0.12))
			tx += 55.0
		# Top yaraları: dış surun dibinde moloz, yüzde is ve oyuk, üstte tahta-fıçı yaması
		for i in 9:
			var hx := sx * rng.randf_range(a0 + 8.0, b0 - 30.0)
			for k in 7:
				d.ball(rng.randf_range(0.6, 1.4), Vector3(hx + rng.randf_range(-2.8, 2.8), rng.randf_range(-0.1, 0.5), 17.2 + rng.randf_range(0.0, 1.8)),
					STONE.darkened(rng.randf_range(0.05, 0.3)), Vector3(1.2, 0.6, 1.0), 6)
			d.box(Vector3(rng.randf_range(3.0, 5.0), rng.randf_range(2.0, 4.0), 0.1), Vector3(hx, rng.randf_range(2.5, 5.0), 16.03), Color("5a5246"))
			if i % 2 == 0:
				d.box(Vector3(3.6, 0.9, 0.5), Vector3(hx, LandWalls.OUTER_H + 0.45, 15.6), WOOD.darkened(0.2))
				d.cyl(0.35, 0.9, Vector3(hx + 1.2, LandWalls.OUTER_H + 0.45, 15.0), WOOD, Vector3.ZERO, 8)
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(STONE.darkened(0.06), 0.0, false, "ashlar"))
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl_o, [], Props.mat(STONE.darkened(0.1), 0.0, false, "ashlar"))
	d.build(self)
	_byz_flags = fd.build(self)
	# Surlarda nöbet tutan savunanlar (uzak siluet; son hücumda Assault kendi savunanlarını koyar)
	var men: Array = []
	var x3 := (4.0 if fill_center else WALL_X0 + 4.0)
	while x3 < 420.0:
		for sx: float in [-1.0, 1.0]:
			if sx < 0.0 and -x3 < wall_x_min + 4.0:
				continue
			if assault and x3 < 80.0:
				continue
			if rng.randf() < 0.7:
				men.append(Transform3D(Basis(Vector3.UP, rng.randf_range(-0.3, 0.3)), Vector3(sx * (x3 + rng.randf_range(-3.0, 3.0)), LandWalls.OUTER_H, 14.9)))
			if rng.randf() < 0.4:
				men.append(Transform3D(Basis(Vector3.UP, rng.randf_range(-0.3, 0.3)), Vector3(sx * (x3 + rng.randf_range(4.0, 9.0)), LandWalls.INNER_H, -1.6)))
		x3 += rng.randf_range(9.0, 17.0)
	_wall_men = Node3D.new()
	add_child(_wall_men)
	Garrison.far_men(_wall_men, men, Garrison.COATS)
	# Gece: surlarda nöbet ateşleri
	var nd := Dressing.new(72)
	nd.chunk = 160.0
	var x2 := 40.0
	while x2 < EXT:
		for sx: float in [-1.0, 1.0]:
			if sx < 0.0 and -x2 - 12.0 < wall_x_min:
				continue
			if rng.randf() < 0.6:
				nd.glow(Vector3(0.35, 0.5, 0.35), Vector3(sx * x2, LandWalls.OUTER_H + 1.3, 15.2), Color("ffb040"))
			if rng.randf() < 0.4:
				nd.glow(Vector3(0.4, 0.6, 0.4), Vector3(sx * (x2 + 12.0), LandWalls.INNER_H + 1.4, -1.2), Color("ffb040"))
		x2 += 26.0
	_night.append(nd.build(self))


## Surun kuzey ucunun ötesi (tek harita): Haliç'in suyu, kıyı boyunca şehrin Haliç surları, karşıda Osmanlı yakası
## (Kasımpaşa sırtları, çadırlar, demirli kadırgalar). Uzak görünüm; oynanış alanı değil.
func _horn_end() -> void:
	var wx := wall_x_min - 120.0          # Blakherna surunun ucu (Haliç kıyısı)
	var water := Props.box(self, Vector3(1600.0, 0.2, 2600.0), Vector3(wx - 800.0 - 6.0, -1.6, -600.0), Color("2e4a5e"))
	water.material_override = CityPanorama.water_mat()
	# Şehir kıyısı: Haliç surları (kıyı boyunca -z), kuleler; içeride evler (SiegeField şehri) devam eder
	var d := Dressing.new(91)
	d.chunk = 200.0
	var wall := Props.box(self, Vector3(3.0, 10.0, 1500.0), Vector3(wx + 1.5, 5.0, -740.0), Color.WHITE)
	Props.set_pattern(wall, STONE.darkened(0.15), "ashlar")
	var merl: Array = []
	var z := 10.0
	while z > -1500.0:
		var tw := Props.box(self, Vector3(7.0, 14.0, 7.0), Vector3(wx + 2.0, 7.0, z - 22.0), Color.WHITE)
		Props.set_pattern(tw, STONE.darkened(0.2), "ashlar")
		Props.box(self, Vector3(7.2, 0.4, 7.2), Vector3(wx + 2.0, 9.0, z - 22.0), Color("9a5040"))
		for k in 10:
			merl.append(Transform3D(Basis.from_scale(Vector3(0.8, 1.0, 1.2)), Vector3(wx + 0.4, 10.5, z - 2.0 - k * 4.0)))
		z -= 44.0
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(STONE.darkened(0.2), 0.0, false, "ashlar"))
	d.box(Vector3(30.0, 1.2, 1700.0), Vector3(wx + 18.0, -0.6, -740.0), Color("7a7050"))
	# Karşı kıyı: alçak sırtlar, çadırlar, ağaçlar, kıyıda kadırgalar
	var far := wx - 320.0
	for i in 26:
		var p := Vector3(far - rng.randf_range(0.0, 500.0), 0, rng.randf_range(-1400.0, 300.0))
		var r := rng.randf_range(90.0, 220.0)
		d.ball(r, Vector3(p.x - r * 0.6, -r * 0.82 + rng.randf_range(14.0, 40.0), p.z), Color("5e6a3e").darkened(rng.randf_range(0.0, 0.25)), Vector3(1.0, 1.0, 1.4), 10)
	for i in 160:
		var p := Vector3(far + rng.randf_range(-60.0, 40.0), 0, rng.randf_range(-1200.0, 200.0))
		d.prism(Vector3(4.0, 3.0, 4.0), p + Vector3(0, 3.0, 0), [Color("e8dcc0"), Color("d8c8a0"), Color("c8262f")][i % 3])
	for i in 14:
		var p := Vector3(far + 70.0 + rng.randf_range(0.0, 60.0), -0.4, rng.randf_range(-1100.0, 100.0))
		d.box(Vector3(4.0, 1.4, 22.0), p, Color("4a3220"))
		d.cyl(0.15, 10.0, p + Vector3(0, 5.5, 0), Color("5a3e26"), Vector3.ZERO, 5)
	d.build(self)
	# Gece: karşı kıyıda ordugâh ateşleri, Haliç surunda nöbet ateşleri
	var nd := Dressing.new(92)
	nd.chunk = 200.0
	for i in 160:
		nd.glow(Vector3(0.9, 1.0, 0.9), Vector3(far + rng.randf_range(-400.0, 40.0), 1.0 + rng.randf_range(0.0, 20.0), rng.randf_range(-1300.0, 250.0)), Color("ffa040"))
	z = 0.0
	while z > -1400.0:
		nd.glow(Vector3(0.4, 0.6, 0.4), Vector3(wx + 2.0, 11.0, z), Color("ffb040"))
		z -= 60.0
	_night.append(nd.build(self))


func _exit_tree() -> void:
	flat_rects = []
	flat_y = -0.03
	flat_blend = 0.0
	blend_rects = []
	world_on = false


# ---------------------------------------------------------------- şehir

func _city() -> void:
	var houses: Array = []
	var hcols: Array = []
	for i in 900:
		var x := rng.randf_range(-EXT, EXT)
		var z := -8.0 - pow(rng.randf(), 1.6) * 560.0
		if (absf(x) < 56.0 and z > -46.0 and not fill_center) or not _free(x, z, 4.0, true) or (world and not World1453.in_city(x, z, 10.0)):
			continue
		var y := city_ground(x, z)
		var s := Vector3(rng.randf_range(5.0, 11.0), rng.randf_range(4.5, 11.0), rng.randf_range(5.0, 10.0))
		houses.append(Scenery._t(Vector3(x, y - 0.4, z), Vector3(0, rng.randf_range(-0.3, 0.3), 0), s))
		hcols.append([Color("e8d8c0"), Color("d8c0a0"), Color("c8a888"), Color("e0ccb0"), Color("b89a80")][i % 5])
	Scenery.scatter(self, Scenery.house_mesh(), houses, hcols)
	# Kiliseler (tuğla gövde, pencereli kasnak, kurşun kubbe) ve manastır kuleleri
	for i in 16:
		var p := Vector3(rng.randf_range(-EXT * 0.8, EXT * 0.8), 0, rng.randf_range(-80.0, -520.0))
		if world and not World1453.in_city(p.x, p.z, 20.0):
			continue
		p.y = city_ground(p.x, p.z) - 0.3
		var r := rng.randf_range(5.0, 8.5)
		Props.box(self, Vector3(r * 2.4, r * 1.3, r * 2.0), p + Vector3(0, r * 0.65, 0), Color("b87060"))
		Props.cyl(self, r * 0.62, r * 0.55, p + Vector3(0, r * 1.55, 0), Color("c8a890"), Vector3.ZERO, 12)
		Props.ball(self, r * 0.64, p + Vector3(0, r * 1.82, 0), Color("8a98a8"), Vector3(1, 0.7, 1), 14)
	if not world:
		Scenery.hagia_sophia(self, Vector3(170, city_ground(170, -560) - 1.0, -560), 1.0)
	var cyp: Array = []
	for i in 420:
		var x := rng.randf_range(-EXT, EXT)
		var z := rng.randf_range(-12.0, -600.0)
		if (absf(x) < 56.0 and z > -46.0 and not fill_center) or not _free(x, z, 4.0, true) or (world and not World1453.in_city(x, z, 10.0)):
			continue
		var sc := rng.randf_range(0.9, 1.6)
		cyp.append(Scenery._t(Vector3(x, city_ground(x, z) - 0.1, z), Vector3.ZERO, Vector3(sc, sc * 1.2, sc)))
	Scenery.scatter(self, Scenery.cypress_mesh(), cyp, [])
	# Gece: şehirde yanan pencereler
	var nd := Dressing.new(73)
	nd.chunk = 160.0
	for i in 180:
		var x := rng.randf_range(-EXT * 0.7, EXT * 0.7)
		var z := rng.randf_range(-40.0, -420.0)
		if (absf(x) < 56.0 and z > -46.0 and not fill_center) or not _free(x, z, 4.0, true) or (world and not World1453.in_city(x, z, 10.0)):
			continue
		nd.glow(Vector3(0.7, 0.9, 0.7), Vector3(x, city_ground(x, z) + rng.randf_range(2.0, 6.0), z), Color("ffc870"))
	_night.append(nd.build(self))


# ---------------------------------------------------------------- ölü bölge

func _free(x: float, z: float, margin := 1.0, flat := false) -> bool:
	for r in keep:
		if (r as Rect2).grow(margin).has_point(Vector2(x, z)):
			return false
	if not flat:
		for r in open:
			if (r as Rect2).grow(margin).has_point(Vector2(x, z)):
				return false
	return true


func _no_mans_land() -> void:
	# Gülle çukurları (yassı, koyu), dağınık gülleler, saplanmış oklar: düz zemin izleri (open alanlara da girer)
	var craters: Array = []
	var ccols: Array = []
	for i in 160:
		var x := rng.randf_range(-320.0, 320.0)
		var z := rng.randf_range(38.0, 96.0)
		if not _free(x, z, 3.0):            # oynanan alanda kara çukur lekesi olmasın
			continue
		var r := rng.randf_range(1.2, 3.2)
		craters.append(Scenery._t(Vector3(x, 0.0, z), Vector3(0, rng.randf() * TAU, 0), Vector3(r, 1.0, r * rng.randf_range(0.8, 1.2))))
		ccols.append(Color("262219").lerp(Color("3a3326"), rng.randf()))
	Scenery.scatter(self, Scenery._cyl(1.0, 0.05, 0.85, 10), craters, ccols)
	var rims: Array = []
	for c: Transform3D in craters:
		rims.append(Transform3D(c.basis.scaled(Vector3(1.15, 1.0, 1.15)), c.origin + Vector3(0, -0.02, 0)))
	Scenery.scatter(self, Scenery._cyl(1.0, 0.16, 0.8, 10), rims, [], Props.mat(Color("4a4230")))
	var balls: Array = []
	for i in 90:
		var x := rng.randf_range(-300.0, 300.0)
		var z := rng.randf_range(20.5, 90.0)
		if z < 36.5 and z > 19.5:
			z = rng.randf_range(37.0, 60.0)
		if not _free(x, z, 1.0):
			continue
		var r := rng.randf_range(0.18, 0.34)
		balls.append(Scenery._t(Vector3(x, r * 0.6, z), Vector3.ZERO, Vector3.ONE * r))
	Scenery.scatter(self, Scenery._ball(1.0), balls, [], Props.mat(Color("5e5a52")))
	var arrows: Array = []
	for i in 360:
		var x := rng.randf_range(-260.0, 260.0)
		var z := rng.randf_range(37.0, 72.0)
		if not _free(x, z, 0.5, true):
			continue
		# Uç aşağıda, sura doğru eğik (surdan atılmış)
		var b := Basis(Vector3.UP, rng.randf_range(-0.4, 0.4)) * Basis(Vector3.RIGHT, deg_to_rad(rng.randf_range(50.0, 75.0)))
		arrows.append(Transform3D(b, Vector3(x, 0.22, z)))
	Scenery.scatter(self, Assault.arrow_mesh(), arrows, [], Scenery._vc_mat())
	Scenery.ground_detail(self, Rect2(-300.0, 37.0, 600.0, 80.0), 1800, func(_x: float, _z: float) -> float: return 0.0, Color("7a7448"), 1453)
	if not near_works:
		return
	# Mantolar (tekerlekli ahşap perde) ve arkalarında okçular; sepet siper çiftleri
	var d := Dressing.new(74)
	d.chunk = 160.0
	var archers: Array = []
	for i in 26:
		var x := rng.randf_range(-280.0, 280.0)
		var z := rng.randf_range(44.0, 82.0)
		if not _free(x, z, 4.0):
			continue
		var yaw := atan2(x * 0.1, 1.0)            # yerel -z sura bakar; askerler arkada (+z)
		d.at(Vector3(x, 0, z), yaw)
		if i % 3 == 2:
			for k in 3:
				_gabion(d, Vector3(-1.4 + k * 1.4, 0, 0), 0.62, 1.5)
		else:
			d.box(Vector3(3.2, 2.3, 0.18), Vector3(0, 1.35, 0), WOOD.darkened(0.15), Vector3(-8, 0, 0))
			for k in 5:
				d.box(Vector3(0.1, 2.3, 0.22), Vector3(-1.4 + k * 0.7, 1.35, 0.02), WOOD.darkened(0.35), Vector3(-8, 0, 0))
			for k in 2:
				d.cyl(0.35, 0.12, Vector3(-1.3 + k * 2.6, 0.35, 0.35), Color("3a2a1e"), Vector3(0, 0, 90), 8)
			d.box(Vector3(0.1, 0.1, 1.4), Vector3(0, 0.9, 0.9), WOOD, Vector3(-40, 0, 0))
		for k in rng.randi_range(1, 3):
			var q := Vector3(x, 0, z) + Basis(Vector3.UP, yaw) * Vector3(rng.randf_range(-1.2, 1.2), 0, rng.randf_range(0.9, 1.8))
			archers.append([Transform3D(Basis(Vector3.UP, yaw + PI + rng.randf_range(-0.3, 0.3)), q), COATS[rng.randi() % COATS.size()]])
	d.build(self)
	_soldiers(archers)


# ---------------------------------------------------------------- siper ve bataryalar

func _gap(x: float) -> bool:
	if x > -8.0 and x < 26.0:
		return true                                 # büyük topun mazgalı
	if assault and absf(x) < 88.0:
		return true                                 # son hücumda ordu siperin önünde
	for g: float in GAPS:
		if absf(x - g) < 5.0:
			return true                             # geçitler
	return not _free(x, RAMPART_Z, 2.0)


func _trench() -> void:
	var d := Dressing.new(75)
	d.chunk = 160.0
	var stakes: Array = []
	var x := -EXT + 10.0
	var seg_start := x
	var in_seg := false
	while x <= EXT - 10.0:
		var g := _gap(x)
		if not g and not in_seg:
			seg_start = x
			in_seg = true
		if (g or x >= EXT - 10.5) and in_seg:
			var l := x - seg_start
			if l > 2.0:
				var cx := seg_start + l * 0.5
				d.box(Vector3(l, 0.06, 3.2), Vector3(cx, 0.0, RAMPART_Z - 3.6), Color("2e2820"))
				d.prism(Vector3(4.2, 1.9, l), Vector3(cx, 0.9, RAMPART_Z), EARTH.lightened(0.05), Vector3(0, 90, 0))
				d.box(Vector3(l, 0.12, 0.12), Vector3(cx, 1.2, RAMPART_Z - 2.4), WOOD.darkened(0.2))
			in_seg = false
		if not g and fmod(x + EXT, 0.9) < 0.5:
			var b := Basis(Vector3.RIGHT, deg_to_rad(-22.0)) * Basis.from_scale(Vector3(1, rng.randf_range(0.9, 1.15), 1))
			stakes.append(Transform3D(b, Vector3(x, 0.8, RAMPART_Z - 2.3)))
		x += 0.45
	d.build(self)
	Scenery.scatter(self, Scenery._cyl(0.08, 2.2, 0.01, 5), stakes, [], Props.mat(WOOD.darkened(0.1)))


func _batteries() -> void:
	var xs := [-600.0, -520.0, -440.0, -365.0, -295.0, -225.0, -160.0, -100.0, 115.0, 175.0, 240.0, 305.0, 375.0, 450.0, 530.0, 610.0]
	if near_works:
		xs.append_array([-36.0, 58.0])
	var d := Dressing.new(76)
	d.chunk = 160.0
	var gunners: Array = []
	for bx: float in xs:
		var p := Vector3(bx, 0, BATTERY_Z + rng.randf_range(-3.0, 3.0))
		if not _free(p.x, p.z, 7.0):
			continue
		var tgt := Vector3(bx * 0.93, 0, 15.0)
		var yaw := atan2(p.x - tgt.x, p.z - tgt.z)       # yerel -z sura bakar
		var bs := Basis(Vector3.UP, yaw)
		d.at(p, yaw)
		var big := rng.randf() < 0.35
		var r := 0.75 if big else 0.55
		var ln := 5.6 if big else 4.4
		# Toprak döşeme, kızak, tunç namlu, ağız halkası, kuyruk topuzu, kama takozu
		d.box(Vector3(8.5, 0.05, 11.0), Vector3(0, 0.0, 0.5), Color("54462f"))
		d.box(Vector3(2.4, 0.5, ln + 1.4), Vector3(0, 0.25, 0.2), WOOD.darkened(0.25))
		for k in 3:
			d.box(Vector3(2.9, 0.3, 0.4), Vector3(0, 0.12, -ln * 0.4 + k * ln * 0.4), WOOD.darkened(0.4))
		d.cyl(r, ln, Vector3(0, 0.6 + r, -0.3), Color("8c5e26"), Vector3(90, 0, 0), 12)
		d.cyl(r * 1.18, 0.4, Vector3(0, 0.6 + r, -0.3 - ln * 0.5), Color("7a5020"), Vector3(90, 0, 0), 12)
		d.cyl(r * 0.8, 0.08, Vector3(0, 0.6 + r, -0.3 - ln * 0.5 - 0.21), Color("15120f"), Vector3(90, 0, 0), 12)
		d.ball(r * 0.6, Vector3(0, 0.6 + r, -0.3 + ln * 0.5 + 0.2), Color("7a5020"))
		d.box(Vector3(1.0, 0.4, 0.9), Vector3(0, 0.7, ln * 0.35), WOOD)
		# Sepet siper (mazgal açık) ve kaldırılmış ahşap perde
		for k in 6:
			var gx: float = [-4.3, -3.0, -1.7, 1.7, 3.0, 4.3][k]
			_gabion(d, Vector3(gx, 0, -ln * 0.5 - 1.6))
		for sx: float in [-1.2, 1.2]:
			d.cyl(0.1, 3.4, Vector3(sx, 1.7, -ln * 0.5 - 0.8), WOOD.darkened(0.3), Vector3.ZERO, 6)
		d.box(Vector3(3.0, 2.2, 0.16), Vector3(0, 3.4, -ln * 0.5 - 0.3), WOOD.darkened(0.15), Vector3(-62, 0, 0))
		# Gülle piramidi, barut fıçıları ve sundurma, tokmak ve tulumba
		for k in 10:
			var lay := 0 if k < 6 else (1 if k < 9 else 2)
			var idx := k if lay == 0 else (k - 6 if lay == 1 else 0)
			d.ball(0.3, Vector3(3.0 + (idx % 3) * 0.6 + lay * 0.3, 0.3 + lay * 0.48, 1.4 + (idx / 3) * 0.6 + lay * 0.3), Color("8a8478"))
		for k in 3:
			d.cyl(0.33, 0.8, Vector3(-3.4 + k * 0.72, 0.4, 2.4), Color("2e2a26"), Vector3.ZERO, 8)
		d.box(Vector3(3.2, 0.1, 1.8), Vector3(-2.7, 1.5, 2.4), Color("c8b894"), Vector3(12, 0, 0))
		for sx: float in [-4.2, -1.2]:
			d.cyl(0.05, 1.5, Vector3(sx, 0.75, 1.6), WOOD.darkened(0.3), Vector3.ZERO, 5)
		d.cyl(0.04, 3.2, Vector3(1.8, 0.1, 3.2), WOOD, Vector3(0, 0, 88), 5)
		d.cyl(0.14, 0.3, Vector3(3.4, 0.1, 3.2), WOOD.darkened(0.2), Vector3(0, 0, 90), 8)
		# Topçular
		for k in 5:
			var lp: Vector3 = [Vector3(-1.9, 0, 0.6), Vector3(1.9, 0, 1.2), Vector3(-2.6, 0, 3.4), Vector3(2.6, 0, 3.8), Vector3(0.4, 0, 4.6)][k]
			gunners.append([Transform3D(Basis(Vector3.UP, yaw + PI + rng.randf_range(-0.8, 0.8)), p + bs * lp), COATS[[0, 5, 4, 3, 0][k]]])
		_guns.append({"muzzle": p + bs * Vector3(0, 0.6 + r, -0.3 - ln * 0.5 - 0.4), "dir": bs * Vector3(0, 0, -1),
			"t": rng.randf_range(4.0, 70.0), "big": big})
		Scenery.smoke_column(_smoke_root, p + bs * Vector3(0, 0.5, -ln * 0.5 - 2.0), true)
	d.build(self)
	_soldiers(gunners)


## Büyük topun (LandWalls.CANNON) mazgalı: ahşap perdenin iki yanında sepet siper sırası, yanlarda sepet duvarlar.
func _great_gun_works() -> void:
	var c := LandWalls.CANNON
	var d := Dressing.new(77)
	d.chunk = 160.0
	for gx: float in [-3.0, -1.7, -0.4, 0.9, 2.2, 3.5, 14.5, 15.8, 17.1, 18.4, 19.7, 21.0]:
		_gabion(d, Vector3(gx, 0, c.z - 7.4), 0.66, 1.7)
	for sx: float in [-4.0, 22.0]:
		var z := c.z - 6.6
		while z < c.z + 10.0:
			_gabion(d, Vector3(sx, 0, z), 0.62, 1.5)
			z += 1.3
	d.build(self)


## Sepet siper (gabion): örgü sepet, üç çember, üstü toprak tümseği.
func _gabion(d: Dressing, p: Vector3, r := 0.64, h := 1.6) -> void:
	gabion(d, p, r, h, rng.randf_range(0.0, 0.15))


static func gabion(d: Dressing, p: Vector3, r := 0.64, h := 1.6, shade := 0.0) -> void:
	var c := WICKER.darkened(shade)
	d.cyl(r, h, p + Vector3(0, h * 0.5, 0), c, Vector3.ZERO, 10)
	for k in 3:
		d.cyl(r * 1.04, 0.07, p + Vector3(0, h * (0.2 + k * 0.3), 0), c.darkened(0.35), Vector3.ZERO, 10)
	d.ball(r * 0.95, p + Vector3(0, h, 0), EARTH, Vector3(1, 0.32, 1), 8)


## Kuşatma kulesinin ıslak deri kaplaması: tek düz levha değil, üst üste binen, tonları farklı deri parçaları,
## aralarında dikiş çizgileri, üstte ve altta çıta. pos: panelin merkezi; side: yan yüz (x'e bakar).
static func hide_panel(parent: Node3D, pos: Vector3, w: float, h: float, side := false, seed := 3) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	if side:
		n.rotation.y = PI * 0.5
	parent.add_child(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var tones := [Color("6a4a30"), Color("7a5838"), Color("5e4028"), Color("84603e"), Color("563a24")]
	var cols := maxi(1, int(ceil(w / 1.15)))
	var rows := maxi(1, int(ceil(h / 0.95)))
	var d := Dressing.new(seed)
	for r in rows:
		for c in cols:
			var x := -w * 0.5 + (c + 0.5) * w / cols + rng.randf_range(-0.06, 0.06)
			var y := -h * 0.5 + (r + 0.5) * h / rows
			var t: Color = tones[rng.randi() % tones.size()]
			d.box(Vector3(w / cols + 0.14, h / rows + 0.12, 0.06), Vector3(x, y, -0.02 * ((r + c) % 2)), t, Vector3(0, 0, rng.randf_range(-4.0, 4.0)))
			d.box(Vector3(w / cols * 0.8, 0.025, 0.03), Vector3(x, y + h / rows * 0.5, -0.06), t.darkened(0.45))   # dikiş
	for y: float in [-h * 0.5 + 0.08, h * 0.5 - 0.08]:
		d.box(Vector3(w + 0.1, 0.14, 0.1), Vector3(0, y, -0.07), Color("4a3220"))
	d.build(n)
	return n


## a'dan b'ye sepet siper sırası (bölümlerin kendi alanlarını çevirmek için; görünmez duvarın görünen yüzü).
static func gabion_line(parent: Node3D, a: Vector3, b: Vector3, step := 1.3, seed := 9) -> void:
	var d := Dressing.new(seed)
	d.chunk = 60.0
	var n := maxi(1, int(a.distance_to(b) / step))
	for i in n + 1:
		gabion(d, a.lerp(b, float(i) / n), 0.62, 1.5, d.rng.randf_range(0.0, 0.15))
	d.build(parent)


# ---------------------------------------------------------------- ordu

## [Transform3D, kaftan rengi] listesi → gerçek asker modelinin kopyaları (Crowd; 150 m ötesi siluet).
func _soldiers(list: Array, parent: Node3D = null) -> Array:
	var items: Array = []
	var i := 0
	for it in list:
		items.append([it[0], {"side": "O", "coat": it[1], "hat": "bork" if i % 3 != 2 else "turban", "arm": ["spear", "", "spear", "bow"][i % 4]}])
		i += 1
	return Crowd.place(parent if parent else self, items, true, true)


func _troops() -> void:
	# Setin ardında nöbetçiler (sura bakar)
	var sentries: Array = []
	var x := -EXT + 20.0
	while x < EXT - 20.0:
		if not _gap(x):
			var z := RAMPART_Z + 2.6 + rng.randf_range(-0.3, 0.3)
			sentries.append([Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.2, 0.2)), Vector3(x, 0, z)), COATS[rng.randi() % COATS.size()]])
		x += rng.randf_range(9.0, 16.0)
	_soldiers(sentries)
	# Gündüz: sancaklı bölükler (8x5), setle ordugâh arasında
	var day := Node3D.new()
	add_child(day)
	_day.append(day)
	var blocks: Array = []
	var bd := Dressing.new(78)
	bd.chunk = 160.0
	for i in 30:
		var p := Vector3(rng.randf_range(-420.0, 420.0), 0, rng.randf_range(125.0, 146.0))
		if p.x > -50.0 and p.x < 75.0:
			continue
		if assault and absf(p.x) < 95.0:
			continue
		if not _free(p.x, p.z, 10.0) or _near_gap(p.x, 14.0):
			continue
		var clash := false
		for q: Vector3 in blocks:
			if q.distance_to(p) < 20.0:
				clash = true
		if clash:
			continue
		blocks.append(p)
	var men: Array = []
	for b: Vector3 in blocks:
		var coat: Color = COATS[rng.randi() % COATS.size()]
		var face := PI + rng.randf_range(-0.12, 0.12)
		var bb := Basis(Vector3.UP, face)
		for i in 8:
			for j in 5:
				var lp := Vector3(-5.6 + i * 1.6 + rng.randf_range(-0.15, 0.15), 0, -3.2 + j * 1.6 + rng.randf_range(-0.15, 0.15))
				var q := b + bb * lp
				q.y = ground(q.x, q.z)
				men.append([Transform3D(Basis(Vector3.UP, face + rng.randf_range(-0.1, 0.1)), q), coat])
		var fp := b + bb * Vector3(0, 0, 4.6)
		fp.y = ground(fp.x, fp.z)
		bd.cyl(0.05, 5.5, fp + Vector3(0, 2.75, 0), Color("4a3420"), Vector3.ZERO, 5)
		bd.ball(0.12, fp + Vector3(0, 5.6, 0), Color("d8b040"))
		bd.box(Vector3(0.03, 1.4, 2.1), fp + Vector3(0, 4.6, 1.05), [Color("b3262d"), Color("2e6a3a"), Color("f0ece0")][rng.randi() % 3])
	_soldiers(men, day)
	bd.build(day)
	# Ateş başı halkaları (gece ateş yanar, gündüz kül ve kazan); halka askerleri her zaman
	var fires := Dressing.new(79)
	fires.chunk = 160.0
	var ash := Dressing.new(80)
	ash.chunk = 160.0
	var ring: Array = []
	var fire_xf: Array = []
	for i in 70:
		var p := Vector3(rng.randf_range(-450.0, 450.0), 0, rng.randf_range(121.5, 150.0))
		if p.x > -50.0 and p.x < 75.0:
			continue
		if assault and absf(p.x) < 90.0 and p.z < 140.0:
			continue
		if not _free(p.x, p.z, 6.0) or _near_gap(p.x, 8.0):
			continue
		var busy := false
		for b: Vector3 in blocks:
			if absf(p.x - b.x) < 10.0 and absf(p.z - b.z) < 7.0:
				busy = true
		if busy:
			continue
		p.y = ground(p.x, p.z)
		fire_xf.append(p)
		fires.glow(Vector3(0.7, 0.9, 0.7), p + Vector3(0, 0.45, 0), Color("ffa030"))
		fires.glow(Vector3(0.4, 1.3, 0.4), p + Vector3(0, 0.7, 0), Color("ffd070"))
		ash.cyl(0.6, 0.12, p + Vector3(0, 0.06, 0), Color("3a3430"), Vector3.ZERO, 8)
		for k in 6:
			var a := TAU * k / 6.0
			ash.box(Vector3(0.7, 0.14, 0.16), p + Vector3(cos(a) * 0.55, 0.08, sin(a) * 0.55), Color("4a3020"), Vector3(0, -rad_to_deg(a), 0))
		var n := rng.randi_range(4, 7)
		for k in n:
			var a := TAU * k / n + rng.randf_range(-0.2, 0.2)
			var q := p + Vector3(cos(a), 0, sin(a)) * rng.randf_range(1.5, 1.9)
			q.y = ground(q.x, q.z)
			ring.append([Transform3D(Basis(Vector3.UP, atan2(p.x - q.x, p.z - q.z)), q), COATS[rng.randi() % COATS.size()]])
	ash.build(self)
	_night.append(fires.build(self))
	_soldiers(ring)


## Sancaklı bölük (cols x rows, 1.6 m arayla), sura (-Z) bakar; bölümler kendi alanlarının yanını doldurmak için
## koyar (genel dolgu bölüm alanını boş bırakır).
func formation(c: Vector3, coat: Color, cols := 8, rows := 5, flag := Color("b3262d")) -> void:
	var men: Array = []
	for i in cols:
		for j in rows:
			var q := c + Vector3((i - (cols - 1) * 0.5) * 1.6 + rng.randf_range(-0.15, 0.15), 0, (j - (rows - 1) * 0.5) * 1.6 + rng.randf_range(-0.15, 0.15))
			q.y = ground(q.x, q.z)
			men.append([Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.1, 0.1)), q), coat])
	_soldiers(men)
	var d := Dressing.new(int(absf(c.x) * 7.0 + c.z))
	d.chunk = 160.0
	var fp := c + Vector3(cols * 0.8 + 0.6, 0, -(rows - 1) * 0.8)
	fp.y = ground(fp.x, fp.z)
	d.cyl(0.05, 5.5, fp + Vector3(0, 2.75, 0), Color("4a3420"), Vector3.ZERO, 5)
	d.ball(0.12, fp + Vector3(0, 5.6, 0), Color("d8b040"))
	d.box(Vector3(0.03, 1.4, 2.1), fp + Vector3(0, 4.6, 1.05), flag)
	d.build(self)


## Gidip gelen askerler: setle ordugâh arasında yürür (gülle, fıçı, su taşır). Her kare güncellenir.
func _walkers_build() -> void:
	for ci in 3:
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = Crowd.ottoman([Color("b3262d"), Color("6a4a3a"), Color("2f5fa8")][ci], "bork", "")
		mm.instance_count = 18
		var mi := MultiMeshInstance3D.new()
		mi.multimesh = mm
		mi.material_override = Crowd.material()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)
		for i in mm.instance_count:
			var a := _walk_point()
			var b := _walk_point(a)
			var w := {"mm": mm, "i": i, "a": a, "b": b, "k": rng.randf(), "speed": rng.randf_range(1.1, 1.6), "phase": rng.randf() * TAU}
			_walkers.append(w)
			_place_walker(w)


func _near_gap(x: float, r: float) -> bool:
	for g: float in GAPS:
		if absf(x - g) < r:
			return true
	return false


## Yürüyenler yalnız boş yollarda gider (bölüklerin, ateşlerin, çadırların içinden geçmesinler):
##   · setin ardındaki yol (z = LANE_Z), büyük topun alanını kesmeden x boyunca
##   · siperdeki geçitlerden ordugâha giden yollar (x = geçit), z 100–148
func _walk_point(from := Vector3.INF) -> Vector3:
	for tries in 40:
		if from != Vector3.INF and absf(from.z - LANE_Z) < 0.8 and rng.randf() < 0.7:
			# Aynı yolda devam (topun alanını geçmeden)
			var x: float = from.x + rng.randf_range(-45.0, 45.0)
			if absf(x) > 380.0 or (from.x < 9.0) != (x < 9.0) or (x > -14.0 and x < 32.0):
				continue
			if assault and absf(x) < 92.0:
				continue
			return Vector3(x, 0, LANE_Z + rng.randf_range(-0.6, 0.6))
		if from != Vector3.INF and _near_gap(from.x, 3.0):
			# Geçit yolunda: ileri geri, ya da setin ardındaki yola çık
			if rng.randf() < 0.5:
				return Vector3(from.x + rng.randf_range(-1.5, 1.5), 0, rng.randf_range(100.0, 148.0))
			return Vector3(from.x, 0, LANE_Z)
		var g: float = GAPS[rng.randi() % 6]
		if assault and absf(g) < 92.0:
			continue
		if rng.randf() < 0.5:
			return Vector3(g + rng.randf_range(-1.5, 1.5), 0, rng.randf_range(100.0, 148.0))
		var x2: float = g + rng.randf_range(-60.0, 60.0)
		if x2 > -14.0 and x2 < 32.0:
			continue
		return Vector3(x2, 0, LANE_Z)
	return Vector3(-210.0, 0, LANE_Z)


func _place_walker(w: Dictionary) -> void:
	var a: Vector3 = w["a"]
	var b: Vector3 = w["b"]
	var p := a.lerp(b, float(w["k"]))
	p.y = ground(p.x, p.z) + absf(sin(_t * 6.0 + float(w["phase"]))) * 0.06
	var dir := b - a
	(w["mm"] as MultiMesh).set_instance_transform(int(w["i"]), Transform3D(Basis(Vector3.UP, atan2(dir.x, dir.z)), p))


func _update_walkers(delta: float) -> void:
	for w: Dictionary in _walkers:
		var a: Vector3 = w["a"]
		var b: Vector3 = w["b"]
		var l := maxf(a.distance_to(b), 1.0)
		w["k"] = float(w["k"]) + delta * float(w["speed"]) / l
		if float(w["k"]) >= 1.0:
			w["a"] = b
			w["b"] = _walk_point(b)
			w["k"] = 0.0
		_place_walker(w)


# ---------------------------------------------------------------- ordugâh ve otağ

func _camp() -> void:
	var avoid := [Rect2(-EXT - 50.0, -100.0, EXT * 2.0 + 100.0, 252.0), Rect2(-20.0, 430.0, 100.0, 100.0)]
	if assault:
		avoid.append(Rect2(-100.0, 0.0, 200.0, 175.0))
	Scenery.camp(_smoke_root, Vector3(0, 0, 380), 0.0, 280.0, 1100, avoid, ground, 14531, true)
	Scenery.camp(_smoke_root, Vector3(-420, 0, 360), 0.0, 230.0, 480, avoid, ground, 14532, true)
	Scenery.camp(_smoke_root, Vector3(420, 0, 360), 0.0, 230.0, 480, avoid, ground, 14533, true)
	if not assault:
		_gunners_camp()
	Scenery.trees(self, Vector3(0, 0, 520), 60.0, 370.0, 300, avoid, ground, 14534)
	for sx: float in [-1.0, 1.0]:
		Scenery.trees(self, Vector3(sx * 450.0, 0, 420), 30.0, 240.0, 160, avoid, ground, 14535 + int(sx))
	# Gece: ordugâhta binlerce ateş (uzaktan ışık noktaları)
	var nd := Dressing.new(81)
	nd.chunk = 160.0
	for i in 420:
		var x := rng.randf_range(-EXT, EXT)
		var z := rng.randf_range(200.0, 720.0)
		nd.glow(Vector3(0.9, 1.0, 0.9), Vector3(x, ground(x, z) + 0.5, z), Color("ffa040"))
	_night.append(nd.build(self))


## Topçuların ordugâhı: büyük topun arkasında çadırlar, barut çadırı, gülle taşıyan öküz arabaları, sandıklar,
## saman, mızrak sehpaları, atlar; ateş başında oturanlar (20o'da oyuncunun arkası).
func _gunners_camp() -> void:
	var colors := [Color("d8cbb0"), Color("c8b894"), Color("e0d4b8"), Color("b8a888")]
	var bands := [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a"), Color("c98a3a")]
	var tents := [Vector3(-34, 0, 142), Vector3(-22, 0, 146), Vector3(-9, 0, 149), Vector3(33, 0, 143), Vector3(46, 0, 147), Vector3(60, 0, 141),
		Vector3(-40, 0, 156), Vector3(-26, 0, 160), Vector3(6, 0, 158), Vector3(22, 0, 157), Vector3(40, 0, 161), Vector3(56, 0, 156)]
	for i in tents.size():
		var t := Night.tent(self, tents[i], rng.randf_range(1.9, 2.8), colors[i % 4], bands[(i * 3) % 4])
		t.rotation.y = rng.randf() * TAU
	# Barut çadırı (koyu, uzun) ve önünde fıçılar
	var d := Dressing.new(84)
	d.chunk = 160.0
	d.at(Vector3(12, 0, 144), 0.1)
	d.prism(Vector3(6.0, 3.2, 9.0), Vector3(0, 1.6, 0), Color("6a5a48"))
	d.box(Vector3(6.1, 0.3, 9.1), Vector3(0, 0.15, 0), Color("4a3a2a"))
	for k in 9:
		d.cyl(0.36, 0.9, Vector3(-3.8 + (k % 3) * 0.8, 0.45 + (k / 3) * 0.0, -4.0 - (k / 3) * 0.8), Color("2e2a26"), Vector3.ZERO, 8)
	var spots := [[Vector3(-14, 0, 137), "_c_crates"], [Vector3(-28, 0, 138), "_c_barrels"], [Vector3(28, 0, 137), "_c_hay"],
		[Vector3(40, 0, 136), "_c_spears"], [Vector3(-4, 0, 152), "_c_firewood"], [Vector3(-46, 0, 144), "_c_sacks"],
		[Vector3(52, 0, 152), "_c_crates"], [Vector3(62, 0, 149), "_c_barrel_pile"], [Vector3(-52, 0, 152), "_c_armory"]]
	for sp in spots:
		d.at(sp[0], rng.randf() * TAU)
		d.call(sp[1])
	# Gülle arabaları (iki tekerlek, üstünde taş gülleler) ve önlerinde öküz
	for k in 3:
		var p := Vector3([-20.0, 24.0, 48.0][k], 0, [140.0, 139.0, 138.0][k])
		d.at(p, rng.randf_range(-0.4, 0.4))
		d.box(Vector3(1.8, 0.2, 3.0), Vector3(0, 0.9, 0), WOOD)
		for sx: float in [-1.0, 1.0]:
			d.box(Vector3(0.12, 0.5, 3.0), Vector3(sx * 0.9, 1.15, 0), WOOD.darkened(0.2))
			d.cyl(0.62, 0.14, Vector3(sx * 1.05, 0.62, 0), Color("4a3020"), Vector3(0, 0, 90), 10)
		d.box(Vector3(0.12, 0.12, 2.4), Vector3(0, 0.8, -2.6), WOOD.darkened(0.3))
		for b in 4:
			d.ball(0.3, Vector3(-0.4 + (b % 2) * 0.8, 1.3, -0.6 + (b / 2) * 1.2), Color("8a8478"))
		for ox in 2:
			var o := Vector3(-0.5 + ox * 1.0, 0, -4.2)
			d.box(Vector3(0.8, 0.9, 2.0), o + Vector3(0, 1.1, 0), Color("6a5a4a") if ox == 0 else Color("8a7a66"))
			d.box(Vector3(0.45, 0.5, 0.7), o + Vector3(0, 1.3, -1.2), Color("5a4a3a"))
			d.cyl(0.06, 0.4, o + Vector3(0.15, 1.7, -1.2), Color("e8e0cc"), Vector3(0, 0, -30), 4)
			d.cyl(0.06, 0.4, o + Vector3(-0.15, 1.7, -1.2), Color("e8e0cc"), Vector3(0, 0, 30), 4)
			for l in 4:
				d.cyl(0.08, 0.7, o + Vector3(-0.25 + (l % 2) * 0.5, 0.35, -0.7 + (l / 2) * 1.4), Color("4a3a2e"), Vector3.ZERO, 5)
		d.box(Vector3(2.0, 0.12, 0.12), Vector3(0, 1.4, -3.6), WOOD.darkened(0.3))
	d.build(self)
	# Ateş başı: oturan topçular
	var fires := Dressing.new(85)
	fires.chunk = 160.0
	var ring: Array = []
	for fp: Vector3 in [Vector3(-16, 0, 154), Vector3(30, 0, 151), Vector3(62, 0, 158)]:
		fires.glow(Vector3(0.7, 0.9, 0.7), fp + Vector3(0, 0.45, 0), Color("ffa030"))
		for k in 5:
			var a := TAU * k / 5.0
			var q := fp + Vector3(cos(a), 0, sin(a)) * 1.7
			ring.append([Transform3D(Basis(Vector3.UP, atan2(fp.x - q.x, fp.z - q.z)), q), COATS[rng.randi() % COATS.size()]])
	_night.append(fires.build(self))
	_soldiers(ring)


## Padişahın otağı (Maltepe): kırmızı çit (zokak) içinde kubbe tepeli büyük çadır, yanında küçük çadırlar,
## kapıda tuğlar.
func _otag() -> void:
	var c := Vector3(30, 0, 480)
	if not _free(c.x, c.z, 10.0):
		return                      # otağ bölgenin kendisinde (ordugâh bölümleri)
	c.y = ground(c.x, c.z)
	var d := Dressing.new(82)
	d.chunk = 160.0
	var red := Color("b3262d")
	var gold := Color("d8b040")
	for side in 4:
		var n := 16 if side % 2 == 0 else 12
		for k in n:
			var along := -1.0 + (k + 0.5) * 2.0 / n
			var p: Vector3
			var yaw := 0.0
			match side:
				0: p = Vector3(along * 22.0, 0, -17.0)
				1: p = Vector3(22.0, 0, along * 17.0); yaw = 90.0
				2: p = Vector3(along * 22.0, 0, 17.0)
				_: p = Vector3(-22.0, 0, along * 17.0); yaw = 90.0
			if side == 0 and absf(p.x) < 3.0:
				continue
			var q := c + p
			q.y = ground(q.x, q.z)
			d.box(Vector3(2.8, 2.6, 0.15), q + Vector3(0, 1.3, 0), red, Vector3(0, yaw, 0))
			d.box(Vector3(2.82, 0.3, 0.17), q + Vector3(0, 2.45, 0), gold, Vector3(0, yaw, 0))
	d.cyl(7.0, 5.0, c + Vector3(0, 2.5, 0), red.darkened(0.05), Vector3.ZERO, 16)
	d.cyl(7.05, 0.5, c + Vector3(0, 4.2, 0), gold, Vector3.ZERO, 16)
	d.cyl(7.6, 4.5, c + Vector3(0, 7.25, 0), red, Vector3.ZERO, 16, 0.05)
	d.ball(0.5, c + Vector3(0, 10.2, 0), gold)
	d.box(Vector3(3.0, 3.4, 0.2), c + Vector3(0, 1.7, -7.0), Color("2a1a14"))
	for k in 4:
		var p := c + Vector3([-14.0, 14.0, -12.0, 12.0][k], 0, [4.0, 4.0, -8.0, -8.0][k])
		p.y = ground(p.x, p.z)
		d.cyl(3.0, 2.6, p + Vector3(0, 1.3, 0), Color("2e6a3a") if k % 2 == 0 else Color("e8dcc0"), Vector3.ZERO, 12)
		d.cyl(3.3, 2.4, p + Vector3(0, 3.8, 0), red, Vector3.ZERO, 12, 0.05)
	for k in 3:
		var p := c + Vector3(-4.0 + k * 4.0, 0, -20.0)
		p.y = ground(p.x, p.z)
		d.cyl(0.09, 9.0, p + Vector3(0, 4.5, 0), Color("3a2a1e"), Vector3.ZERO, 6)
		d.ball(0.35, p + Vector3(0, 9.1, 0), gold)
		d.cyl(0.35, 1.8, p + Vector3(0, 7.9, 0), Color("2a2420"), Vector3.ZERO, 8, 0.3)
	d.build(self)
	var nd := Dressing.new(83)
	nd.chunk = 160.0
	for k in 8:
		var a := TAU * k / 8.0
		nd.glow(Vector3(0.5, 0.7, 0.5), c + Vector3(cos(a) * 24.0, 2.0, sin(a) * 19.0), Color("ffb050"))
	_night.append(nd.build(self))


# ---------------------------------------------------------------- saat ve bombardıman

## Fetihten sonra (26, 26o'da Fatih'in girişi): surlarda Bizans nöbetçisi ve sancağı kalmaz, kulelere Osmanlı
## sancakları çekilir.
func victory() -> void:
	if _wall_men:
		_wall_men.visible = false
	if _byz_flags:
		_byz_flags.visible = false
	var d := Dressing.new(69)
	d.chunk = 160.0
	for p: Vector3 in _flag_spots:
		d.box(Vector3(0.03, 1.2, 1.8), p + Vector3(0, 0, 0.1), Color("b3262d"))
		d.box(Vector3(0.035, 0.3, 0.3), p + Vector3(0, 0.1, 0.35), Color("f0ece0"))
	d.build(self)
	bombard = false


## "night": ateşler yanar, bölükler çadırda · "dawn": ateşler hâlâ yanar, bölükler dizilmiş · "day": ateş yok.
func set_mode(mode: String) -> void:
	if horn:
		horn.set_mode(mode)
	for n in _night:
		n.visible = mode != "day"
	for n in _day:
		n.visible = mode != "night"
	var col := Color(0.16, 0.17, 0.22, 0.35) if mode == "night" else Color(0.85, 0.83, 0.8, 0.45)
	for p in _smoke_root.find_children("*", "CPUParticles3D", true, false):
		var s := (p as CPUParticles3D).mesh as SphereMesh
		if s and s.material is StandardMaterial3D:
			(s.material as StandardMaterial3D).albedo_color = col


func _process(delta: float) -> void:
	_t += delta
	_update_walkers(delta)
	if bombard:
		for g: Dictionary in _guns:
			g["t"] = float(g["t"]) - delta
			if float(g["t"]) <= 0.0:
				g["t"] = rng.randf_range(40.0, 80.0)
				_fire(g)
	for k in range(_flying.size() - 1, -1, -1):
		var f: Array = _flying[k]
		var n: Node3D = f[0]
		f[3] = float(f[3]) + delta / float(f[4])
		var t := minf(float(f[3]), 1.0)
		var a: Vector3 = f[1]
		var b: Vector3 = f[2]
		n.global_position = a.lerp(b, t) + Vector3(0, sin(t * PI) * a.distance_to(b) * 0.12, 0)
		if t >= 1.0:
			Vfx.explosion(self, b, 0.7)
			Vfx.dust(self, b + Vector3(0, -0.6, 0.8), 1.3)
			n.queue_free()
			_flying.remove_at(k)


func _fire(g: Dictionary) -> void:
	var mp: Vector3 = g["muzzle"]
	var dir: Vector3 = g["dir"]
	Vfx.explosion(self, mp + dir * 0.8, 1.1 if g["big"] else 0.8)
	Vfx.dust(self, mp + dir * 2.0 + Vector3(0, 0.5, 0), 1.0)
	var fl := OmniLight3D.new()
	fl.light_color = Color("ffb060")
	fl.light_energy = 8.0
	fl.omni_range = 36.0
	add_child(fl)
	fl.global_position = mp + dir * 1.5
	var tw := fl.create_tween()
	tw.tween_property(fl, "light_energy", 0.0, 0.5)
	tw.tween_callback(fl.queue_free)
	var cam := get_viewport().get_camera_3d()
	var dist := cam.global_position.distance_to(mp) if cam else 200.0
	if dist < 260.0:
		Audio.sfx("cannon", clampf(-8.0 - dist * 0.07, -28.0, -10.0), rng.randf_range(0.7, 0.85))
	var hit := Vector3(mp.x * 0.93 + rng.randf_range(-6.0, 6.0), rng.randf_range(2.0, 6.5), 16.3)
	var ball := Props.ball(self, 0.3, mp, Color("2a2624"), Vector3.ONE, 6)
	_flying.append([ball, mp, hit, 0.0, clampf(mp.distance_to(hit) / 70.0, 0.9, 2.2)])
