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
const EDGE_W := 3.0            # gediğin kırık kenar kuşağı (taş sıralarıyla örülür)
const DEPOT := Vector3(11.0, 0.0, 2.2)
const CANNON := Vector3(9.0, 1.5, 118.0)
const MANTLETS := [Vector3(-5.5, 0.0, 10.0), Vector3(5.5, 0.0, 10.0)]
const SPAWN := Vector3(9.0, 0.05, 5.0)
const STAGES := 10
## Moloz yamacının basamaklı katmanları (katı): en üstteki katmanın üstü, katman başına 0,5 m alçalır. Gediğin
## ortasında rampa (0 → 2,3 m) katmanların hep biraz üstünde kalır; yanlarda katmanlar görünür basamaklardır.
const RUBBLE_TOP := 2.275
const TONGUE_W := BREACH_W + 2.0       # hendeğe dökülen moloz dilinin genişliği (korkuluk orada yıkık)
const TONGUE_Z0 := 19.6
const TONGUE_Y0 := 0.3
const TONGUE_Z1 := 25.5
const GATE_W := 4.8            # iç surdaki kapının genişliği (Bölüm 26: Sultan'ın şehre girdiği yol)
const GATE_H := 6.4
var _gate_plug: StaticBody3D

const C_STONE := Color("cdbd9e")
const C_WOOD := Color("7a5634")

var lights: Array = []
var stages: Array[Node3D] = []
var moon: DirectionalLight3D
var env: WorldEnvironment
var _flash: OmniLight3D
var far_gun: Node3D
var field: SiegeField
## Ovanın ayarları (add_child'dan önce verilir): yakın siper işleri, son hücum düzeni, boş kalacak alanlar
var near_works := true
## 11–12 Nisan (Bölüm 28o): sur henüz sağlam. Gedik, moloz, kırık kenar ve bombardıman izleri kurulmaz; gediğin
## yerinde dış sur bütündür (mazgalları, yürüyüş yolu). add_child'dan önce verilir.
var intact := false
## Hendek dolgusu (Bölüm 26o, 29 Mayıs): kuşatma boyunca azaplar hendeği çalı demeti ve toprakla doldurdu. Açıkken
## hendeğin iki yamacı yürünür rampa, dibi FILL_Y'de; kule önündeki toprak set (CAUSEWAY) sur dibi yüksekliğinde.
## Statik: zemin işlevleri (outside_y, Assault.ground_y) seviye örneği olmadan çağrılır; seviye ağaçtan çıkınca sıfırlanır.
static var ditch_filled := false
const FILL_Y := -1.5
const CAUSEWAY := Rect2(-8.0, 20.0, 10.0, 16.0)
var assault_mode := false
## Ana menünün arkası: çevre (SiegeField) hafif kurulur
var lite := false
var field_keep: Array = []
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
	if intact:
		_build_intact_span()
	else:
		_build_breach()
	_build_depot()
	_build_field()
	if not intact:
		_battle_damage()


## Gediğin yerinde bütün dış sur (Bölüm 28o): iki yandaki sur parçasının arasını kapatan aynı taş gövde ve mazgallar
func _build_intact_span() -> void:
	var w := (BREACH_W * 0.5 + EDGE_W) * 2.0 + 0.2
	_wall(Vector3(w, OUTER_H, OUTER_Z1 - OUTER_Z0), Vector3(0, OUTER_H * 0.5, (OUTER_Z0 + OUTER_Z1) * 0.5), C_STONE.darkened(0.05))
	var merl: Array = []
	var x := -w * 0.5 + 0.5
	while x < w * 0.5:
		merl.append(Transform3D(Basis.from_scale(Vector3(1.1, 0.9, 0.7)), Vector3(x, OUTER_H + 0.45, OUTER_Z1 - 0.3)))
		x += 1.8
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(C_STONE.darkened(0.1), 0.0, false, "ashlar"))


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


## Haftalarca süren bombardımanın izleri: dış surda, kulelerde ve iç surda gülle oyukları (koyu çukur, kırık taş
## kenarı, çatlaklar), üstlerinde is ve kararma, sur dibinde moloz; tepede yıkık mazgal yerlerine tahta-fıçı yamaları.
## (Eskiden surlar gedik dışında tertemizdi.) Tek birleşik ağ: çizim yükü yok denecek kadar az.
func _battle_damage() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var d := Dressing.new(1453)
	var dark := Color("2e2a25")
	var soot := Color("5e584e")
	var chip := Color("a89c86")
	var hit := func(p: Vector3, nz: float, r: float) -> void:
		# p: yüzeydeki nokta, nz: yüzeyin dışa bakan yönü (+1 ova, -1 şehir), r: oyuk yarıçapı
		# Yüzeyle aynı düzlemde, ince (ışıkta yuvarlak kabarcık gibi parlamasın): koyu oyuk, çevresinde soluk kırık taş
		# halkası, dışa yayılan çatlaklar. Is ve taş kırıntısı topu yok (gece ateş ışığında açık lekeler gibi görünüyordu).
		d.box(Vector3(r * 1.9, r * 1.6, 0.02), p + Vector3(0, 0, nz * 0.012), soot, Vector3(0, 0, rng.randf_range(-25.0, 25.0)))
		d.box(Vector3(r * 1.1, r * 1.0, 0.03), p + Vector3(0, -r * 0.05, nz * 0.02), dark, Vector3(0, 0, 45.0 + rng.randf_range(-15.0, 15.0)))
		for k in 4:
			var a := rng.randf_range(-PI, PI)
			var ln := rng.randf_range(0.8, 1.8) * r * 1.6
			d.box(Vector3(0.05, ln, 0.025), p + Vector3(cos(a) * (r + ln * 0.5), sin(a) * (r + ln * 0.5), nz * 0.02), dark, Vector3(0, 0, rad_to_deg(a) + 90.0))
	# Dış sur (ova yüzü z = OUTER_Z1): gedik ve kuleler dışında
	var placed := 0
	while placed < 16:
		var x := rng.randf_range(-47.0, 47.0)
		if absf(x) < BREACH_W * 0.5 + EDGE_W + 1.0 or absf(absf(x) - 16.0) < 3.4:
			continue
		var y := rng.randf_range(1.6, OUTER_H - 1.4)
		var r := rng.randf_range(0.45, 0.9)
		hit.call(Vector3(x, y, OUTER_Z1), 1.0, r)
		# Sur dibinde düşen taşlar
		for k in 5:
			d.ball(rng.randf_range(0.18, 0.4), Vector3(x + rng.randf_range(-1.4, 1.4), 0.1, OUTER_Z1 + rng.randf_range(0.3, 1.8)),
				chip.darkened(rng.randf_range(0.1, 0.4)), Vector3(1.2, 0.7, 1.0), 5)
		placed += 1
	# Dış sur kulelerinin ön yüzü (z = OUTER_Z1 + 3.5)
	for sx: float in [-1.0, 1.0]:
		for k in 2:
			hit.call(Vector3(sx * 16.0 + rng.randf_range(-1.6, 1.6), rng.randf_range(3.0, OUTER_H + 1.5), OUTER_Z1 + 3.5), 1.0, rng.randf_range(0.5, 0.8))
	# İç sur (dış yüzü z = INNER_Z1): üst yarı (gülleler dış surun üstünden aşar), kapının dışında
	placed = 0
	while placed < 12:
		var x := rng.randf_range(-47.0, 47.0)
		if absf(x) < GATE_W * 0.5 + 1.5 or absf(absf(x) - 24.0) < 5.0:
			continue
		hit.call(Vector3(x, rng.randf_range(OUTER_H + 0.5, INNER_H - 1.2), INNER_Z1), 1.0, rng.randf_range(0.5, 1.0))
		placed += 1
	# Dış surun tepesinde yıkılmış mazgal yerlerine yamalar: tahta perde ve toprak dolu fıçılar
	for k in 5:
		var x := rng.randf_range(-44.0, 44.0)
		if absf(x) < BREACH_W * 0.5 + EDGE_W + 2.0 or absf(absf(x) - 16.0) < 3.6:
			continue
		d.box(Vector3(rng.randf_range(2.2, 3.4), 0.8, 0.12), Vector3(x, OUTER_H + 0.5, OUTER_Z1 - 0.2), C_WOOD.darkened(0.25))
		d.cyl(0.32, 0.8, Vector3(x + 1.0, OUTER_H + 0.4, OUTER_Z1 - 0.7), C_WOOD.darkened(0.1), Vector3.ZERO, 8)
	d.build(self)


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
	# Set ve hendek dibi katı: dışarıda dövüşen ya da yürüyen (20o gedik hücumu) boşluğa düşmesin
	# Kalın (1,2 m): surdan ya da merdivenden düşen oyuncu ince zeminin içinden geçmesin
	Props.solid(self, Vector3(100, 1.2, 3.0), Vector3(0, -0.6, 17.5), Color("6e6452"))
	# Korkuluk (dış siper duvarı): gediğin önünde yıkık, moloz oradan hendeğe dökülür
	var bw := (100.0 - TONGUE_W) * 0.5
	if ditch_filled:
		# Dolgu sur dibinin setine kadar gelir; korkuluk dövülmüş: arada geçitli alçak kırık parçalar (katı)
		Props.solid(self, Vector3(100, 1.2, 1.4), Vector3(0, -0.62, 19.65), Color("6e6452"))
		for sx: float in [-1.0, 1.0]:
			var x0 := TONGUE_W * 0.5 + 1.5
			while x0 < 49.0:
				var len := 2.2 + fmod(absf(x0) * 1.7, 1.6)
				var h := 0.5 + fmod(absf(x0) * 0.9, 0.5)
				var seg := Props.solid(self, Vector3(len, h, 0.8), Vector3(sx * (x0 + len * 0.5), h * 0.5, 19.2), Color.WHITE)
				Props.set_pattern(seg, C_STONE.darkened(0.1), "ashlar")
				seg.set_meta("no_climb", true)
				x0 += len + 2.4
	else:
		for sx: float in [-1.0, 1.0]:
			Props.box(self, Vector3(bw, 1.6, 0.8), Vector3(sx * (TONGUE_W * 0.5 + bw * 0.5), 0.6, 19.2), C_STONE.darkened(0.1))
	# Hendek dibi kalın (üstü -2,9): merdivenden 11 m düşen oyuncu 20 cm'lik dibin içinden geçip haritanın altına
	# düşüyordu (Bölüm 26o)
	Props.solid(self, Vector3(100, 1.2, 17.0), Vector3(0, -3.5, 27.5), Color("3a3a30"))
	if ditch_filled:
		_build_fill()
	Props.box(self, Vector3(100, 3.0, 0.6), Vector3(0, -1.5, 20.0), C_STONE.darkened(0.3))
	Props.box(self, Vector3(100, 3.0, 0.6), Vector3(0, -1.5, 36.0), Color("4a4436"))
	# Hendekten çıkış: iki uçta, iki yüze yaslı taş rampalar (dünyanın hendeğinde de her ~80 m'de bir)
	for sx: float in [-1.0, 1.0]:
		for rz: Array in [[33.6, 1.0], [22.4, -1.0]]:
			var r := Props.ramp(self, Vector3(sx * 38.0, -2.9, rz[0]), Vector3(sx * 47.0, 0.05, rz[0]), 3.2, Color.WHITE)
			Props.set_pattern(r, C_STONE.darkened(0.25), "ashlar")
	# Surlar arasında yıkıntı ve dikenli çit; ortasında geçit (peribolos boyunca dünyanın kapılarına yürünür)
	var gap0 := 5.0
	var gap1 := 8.6
	for sx: float in [-1.0, 1.0]:
		var x := sx * 32.0
		_wall(Vector3(1.2, 3.0, gap0 - INNER_Z1), Vector3(x, 1.5, (INNER_Z1 + gap0) * 0.5), C_STONE.darkened(0.15))
		_wall(Vector3(1.2, 3.0, OUTER_Z0 - gap1), Vector3(x, 1.5, (gap1 + OUTER_Z0) * 0.5), C_STONE.darkened(0.15))
		for i in 6:
			var sz := 1.0 + i * 2.2
			if sz > gap0 - 0.5 and sz < gap1 + 0.5:
				continue
			Props.cyl(self, 0.08, 2.2, Vector3(x - sx * 0.8, 1.0, sz), C_WOOD, Vector3(sx * 28.0, 0, 18.0), 5)


func _exit_tree() -> void:
	ditch_filled = false


## Doldurulmuş hendek: iki yamaçta rampa, dipte toprak; üstünde çalı demetleri (fascine), kule önünde toprak set
func _build_fill() -> void:
	var c := Color("5a4630")
	Props.set_pattern(Props.ramp(self, Vector3(0, 0.0, 20.3), Vector3(0, FILL_Y, 23.4), 100.0, Color.WHITE), c, "dirt")
	Props.set_pattern(Props.ramp(self, Vector3(0, FILL_Y, 32.7), Vector3(0, 0.0, 35.8), 100.0, Color.WHITE), c, "dirt")
	Props.set_pattern(Props.solid(self, Vector3(100, 1.2, 9.4), Vector3(0, FILL_Y - 0.6, 28.05), Color.WHITE), c.darkened(0.08), "dirt")
	var cw := Props.solid(self, Vector3(CAUSEWAY.size.x - 1.0, 3.1, CAUSEWAY.size.y), Vector3(CAUSEWAY.get_center().x, -1.35, CAUSEWAY.get_center().y), Color.WHITE)
	Props.set_pattern(cw, c, "dirt")
	var rng := RandomNumberGenerator.new()
	rng.seed = 2905
	var d := Dressing.new(2905)
	for i in 70:
		var x := rng.randf_range(-48.0, 48.0)
		var z := rng.randf_range(21.0, 35.0)
		var y := fill_y(x, z)
		var rot := Vector3(0, rng.randf_range(-25.0, 25.0), 90)
		d.cyl(0.22, rng.randf_range(1.6, 2.6), Vector3(x, y + 0.18, z), Color("6a5636").darkened(rng.randf_range(0.0, 0.3)), rot, 6)
	d.build(self)


## Doldurulmuş hendeğin (ve kule önündeki setin) yüzeyi; z 20,3–35,8 dışında 0
static func fill_y(x: float, z: float) -> float:
	if CAUSEWAY.has_point(Vector2(x, z)):
		return 0.2
	if z < 20.3 or z > 35.8:
		return 0.0
	if z < 23.4:
		return lerpf(0.0, FILL_Y, (z - 20.3) / 3.1)
	if z > 32.7:
		return lerpf(FILL_Y, 0.0, (z - 32.7) / 3.1)
	return FILL_Y


func _build_inner() -> void:
	# Üç parça: ortadaki parça (Aziz Romanos Kapısı'nın yeri) Bölüm 26'da kapı olarak açılır (open_inner_gate)
	var half_gate := GATE_W * 0.5
	for sx: float in [-1.0, 1.0]:
		var len := 50.0 - half_gate
		_wall(Vector3(len, INNER_H, INNER_Z1 - INNER_Z0), Vector3(sx * (half_gate + len * 0.5), INNER_H * 0.5, (INNER_Z0 + INNER_Z1) * 0.5))
	_gate_plug = _wall(Vector3(GATE_W, INNER_H, INNER_Z1 - INNER_Z0), Vector3(0, INNER_H * 0.5, (INNER_Z0 + INNER_Z1) * 0.5))
	var z := INNER_Z1
	var x := -48.0
	var merl: Array = []
	while x <= 48.0:
		merl.append(Transform3D(Basis.from_scale(Vector3(1.2, 1.0, 0.8)), Vector3(x, INNER_H + 0.5, z - 0.3)))
		x += 2.0
	Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(C_STONE.darkened(0.06), 0.0, false, "ashlar"))
	# Kuleler (peribolosa taşar)
	for tx: float in [-24.0, 24.0]:
		_wall(Vector3(9.0, INNER_H + 6.0, 8.2), Vector3(tx, (INNER_H + 6.0) * 0.5, INNER_Z0 + 4.0), C_STONE.darkened(0.03))   # arka yüzü surunkiyle aynı düzlemde değil
		for i in 3:
			Props.box(self, Vector3(0.8, 1.4, 0.1), Vector3(tx - 2.5 + i * 2.5, INNER_H + 2.0, INNER_Z0 + 8.03), Color("1c1814"))
		lights.append(Night.torch(self, Vector3(tx + 5.0, INNER_H, INNER_Z1 + 0.2), 1.2))
	# Arka kapı (poterna): peribolosa açılan küçük kapı; depo yanında
	Props.box(self, Vector3(2.0, 3.2, 0.1), Vector3(DEPOT.x + 3.5, 1.6, INNER_Z1 + 0.03), Color("15120f"))
	Props.cyl(self, 1.0, 0.1, Vector3(DEPOT.x + 3.5, 3.2, INNER_Z1 + 0.03), Color("15120f"), Vector3(90, 0, 0), 12)
	lights.append(Night.torch(self, Vector3(DEPOT.x + 1.8, 0, INNER_Z1 + 0.4), 2.2))


## İç surdaki kapıyı açar (Bölüm 26, fetih günü): kemerli geçit, kırılıp içe açılmış kanatlar. Şehrin içi FallenCity.
func open_inner_gate() -> void:
	if _gate_plug == null:
		return
	_gate_plug.queue_free()
	_gate_plug = null
	var zc := (INNER_Z0 + INNER_Z1) * 0.5
	var th := INNER_Z1 - INNER_Z0
	# Kemerin üstü (lento ve duvar) ve kemer kasnağı
	_wall(Vector3(GATE_W, INNER_H - GATE_H, th), Vector3(0, GATE_H + (INNER_H - GATE_H) * 0.5, zc))
	for sz: float in [INNER_Z1 + 0.05, INNER_Z0 - 0.05]:
		Props.box(self, Vector3(GATE_W + 1.2, 0.5, 0.2), Vector3(0, GATE_H + 0.25, sz), C_STONE.lightened(0.12))
		for sx: float in [-1.0, 1.0]:
			Props.box(self, Vector3(0.6, GATE_H, 0.2), Vector3(sx * (GATE_W * 0.5 + 0.3), GATE_H * 0.5, sz), C_STONE.lightened(0.08))
	# Geçidin zemini: şehir zemini (z < INNER_Z0) ile peribolos (z > INNER_Z1) arasında surun altı boştu, düşülüyordu
	Props.set_pattern(Props.solid(self, Vector3(GATE_W, 0.4, INNER_Z1 - 0.1 - INNER_Z0), Vector3(0, -0.2, (INNER_Z0 + INNER_Z1 - 0.1) * 0.5), Color.WHITE), Color("8a7a60"), "cobble")
	# Geçidin tavanı ve yan yüzleri (içinden bakınca taş)
	Props.box(self, Vector3(GATE_W, 0.1, th), Vector3(0, GATE_H - 0.05, zc), C_STONE.darkened(0.25))
	# Kırılmış kapı kanatları: biri içe açılmış, biri menteşesinden düşüp yere yaslanmış
	var wood := C_WOOD.darkened(0.2)
	var l := Node3D.new()
	l.position = Vector3(-GATE_W * 0.5 + 0.1, 0, INNER_Z0 - 0.1)
	l.rotation.y = deg_to_rad(-100)
	add_child(l)
	Props.make_solid(Props.box(l, Vector3(GATE_W * 0.5 - 0.1, GATE_H - 0.3, 0.14), Vector3((GATE_W * 0.5 - 0.1) * 0.5, (GATE_H - 0.3) * 0.5, 0), wood))
	for k in 4:
		Props.box(l, Vector3(GATE_W * 0.5 - 0.1, 0.08, 0.18), Vector3((GATE_W * 0.5 - 0.1) * 0.5, 0.8 + k * 1.5, 0), Color("3a3634"))
	# Düşen kanat yolun kenarında, cadde boyunca yere yatık (eskiden geçidin önünde yola çapraz uzanıp 2 m'ye
	# yükseliyordu: Sultan'ın alayı içinden geçiyordu)
	var r := Node3D.new()
	r.position = Vector3(GATE_W * 0.5 + 1.0, 0.08, INNER_Z0 - 1.2)
	r.rotation = Vector3(deg_to_rad(-85), deg_to_rad(4), 0)
	add_child(r)
	# Katı: üstüne çıkılır (hafif eğik), içinden geçilmez
	Props.make_solid(Props.box(r, Vector3(GATE_W * 0.5 - 0.1, GATE_H - 0.3, 0.14), Vector3(0, (GATE_H - 0.3) * 0.5, 0), wood.darkened(0.15)))


func _build_outer() -> void:
	var half := BREACH_W * 0.5
	for sx: float in [-1.0, 1.0]:
		# x ±50'ye kadar: ovadaki sur uzantısı (SiegeField) ±50'de başlar (eskiden ±48'de bitiyordu, arada 2 m'lik
		# yarık kalıyor, surdaki savunanlardan biri boşlukta duruyordu)
		var len := 50.0 - half - EDGE_W
		var cx := sx * (half + EDGE_W + len * 0.5)
		_wall(Vector3(len, OUTER_H, OUTER_Z1 - OUTER_Z0), Vector3(cx, OUTER_H * 0.5, (OUTER_Z0 + OUTER_Z1) * 0.5), C_STONE.darkened(0.05))
		var x := sx * (half + EDGE_W + 0.5)
		var merl: Array = []
		while absf(x) < 49.5:
			merl.append(Transform3D(Basis.from_scale(Vector3(1.1, 0.9, 0.7)), Vector3(x, OUTER_H + 0.45, OUTER_Z1 - 0.3)))
			x += sx * 1.8
		Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(C_STONE.darkened(0.1), 0.0, false, "ashlar"))
		if not intact:
			_broken_edge(sx, half)
		# Yürüyüş yolunun dış kenarında görünmez korkuluk (mazgalların üstünden ovaya atlanmasın) ve yolun ucu
		var guard := Props.solid(self, Vector3(len, 3.2, 0.3), Vector3(cx, OUTER_H + 1.6, OUTER_Z1 - 0.1), Color.WHITE)
		guard.get_child(0).visible = false
		guard.set_meta("no_climb", true)
		# Yolun uçları açık: sur boyunca dünyanın surlarına yürünür; gediğe ya da peribolosa atlanabilir (düşme hasarı
		# yok; peribolostan merdivenlerle ya da dünyanın kapılarından geri gelinir)
		# Yolun iç (peribolos) kenarında alçak korkuluk: sur yolundan 8 m aşağı peribolosa atlanmasın (Bölüm 25'te
		# gece yürürken düşülüyordu). Merdivenlerin başında (x ±8) açıklık: aşağı merdivenle inilir.
		var px0 := half + EDGE_W + 0.2
		for seg: Vector2 in [Vector2(px0, 7.2), Vector2(8.8, 30.4)]:
			var sl := seg.y - seg.x
			var sc := sx * (seg.x + sl * 0.5)
			var par := Props.solid(self, Vector3(sl, 0.45, 0.3), Vector3(sc, OUTER_H + 0.225, OUTER_Z0 + 0.15), Color.WHITE)
			Props.set_pattern(par, C_STONE.darkened(0.08), "ashlar")
			par.set_meta("no_climb", true)
			var pg := Props.solid(self, Vector3(sl, 1.2, 0.3), Vector3(sc, OUTER_H + 0.45 + 0.6, OUTER_Z0 + 0.15), Color.WHITE)
			pg.get_child(0).visible = false
			pg.set_meta("no_climb", true)
		# Dış sur kuleleri
		var tx := sx * 16.0
		# Kule surun dışına taşar: yürüyüş yolu (z 14..16) arkasından geçer
		_wall(Vector3(5.0, OUTER_H + 3.0, 5.0), Vector3(tx, (OUTER_H + 3.0) * 0.5, OUTER_Z1 + 2.6), C_STONE.darkened(0.08))
		lights.append(Night.torch(self, Vector3(tx - sx * 3.0, 0, OUTER_Z0 - 0.4), 2.2))
	# Surun iç yüzüne yaslı merdiven iskeleler (savunucular çıkar); görüntü
	for sx: float in [-1.0, 1.0]:
		var ld := Ladder.new(OUTER_H + 0.6, 12.0, C_WOOD)
		ld.position = Vector3(sx * 8.0, 0.0, OUTER_Z0 - (OUTER_H + 0.6) * sin(deg_to_rad(12.0)) - 0.12)
		ld.rotation.y = PI
		add_child(ld)


## Gediğin kırık kenarı: düz basamak yerine dişli, eğri, yer yer sarkan taş sıraları; kesitte surun moloz-harç
## çekirdeği (iki yüz kesme taş, arası moloz); kenara yakın yüzlerde çatlaklar ve is.
func _broken_edge(sx: float, half: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 29 + int(sx * 7.0)
	var zc := (OUTER_Z0 + OUTER_Z1) * 0.5
	var thick := OUTER_Z1 - OUTER_Z0
	var outer_end := half + EDGE_W
	# Kenar kuşağı: taş sıraları; her sıra gedikten "back" kadar geri çekilir (yukarı çıktıkça daha çok) → dişli profil
	var y := 0.0
	while y < OUTER_H - 0.05:
		var h := minf(rng.randf_range(0.42, 0.8), OUTER_H - y)
		var back := clampf(pow(y / OUTER_H, 1.3) * 2.5 + rng.randf_range(-0.3, 0.35), 0.0, EDGE_W - 0.25)
		var x0 := half + back
		var w := outer_end - x0
		var col := Color("b09c82").darkened(rng.randf_range(0.08, 0.3))
		var row := Props.box(self, Vector3(w + 0.02, h, thick), Vector3(sx * (x0 + w * 0.5), y + h * 0.5, zc), Color.WHITE,
			Vector3(0, 0, sx * rng.randf_range(-2.5, 2.5)))
		Props.set_pattern(row, col, "ashlar")
		# Sıralar, çekirdek ve taşan taşlar katı: ana kuşak gövdesi kenardan 1 m içeride başlıyordu, alt sıraların ve
		# gediğe taşan taşların içine yamaçtan yürünüyordu
		Props.make_solid(row)
		# Kesitte moloz-harç çekirdek: kırık uçta iki yüz arasında koyu, girintili dolgu
		Props.make_solid(Props.box(self, Vector3(0.35, h * 0.95, thick - 0.7), Vector3(sx * (x0 - 0.1), y + h * 0.5, zc), Color("5e5446").darkened(rng.randf_range(0, 0.15))))
		# Uçta yarım kalmış kesme taşlar (yüzlerden dışarı taşan)
		if rng.randf() < 0.6:
			var face := -1.0 if rng.randf() < 0.5 else 1.0
			Props.make_solid(Props.box(self, Vector3(rng.randf_range(0.4, 0.8), h * 0.9, 0.55), Vector3(sx * (x0 - 0.3), y + h * 0.45, zc + face * (thick * 0.5 - 0.28)),
				col.darkened(0.08), Vector3(rng.randf_range(-6, 6), rng.randf_range(-12, 12), rng.randf_range(-12, 12))))
		y += h
	# Kuşak katıdır (oyuncu içinden geçmesin); alt kısım moloz yamacıyla örtülür
	var body := Props.solid(self, Vector3(EDGE_W - 1.0, OUTER_H, thick), Vector3(sx * (half + 1.0 + (EDGE_W - 1.0) * 0.5), OUTER_H * 0.5, zc), Color.WHITE)
	body.get_child(0).visible = false
	body.set_meta("no_climb", true)
	# Sarkan iri taşlar (tepede, boşluğa taşar)
	for k in 3:
		var hy := OUTER_H - rng.randf_range(0.8, 3.0)
		Props.box(self, Vector3(rng.randf_range(0.6, 1.0), rng.randf_range(0.35, 0.55), rng.randf_range(0.6, 0.9)),
			Vector3(sx * (half + pow(hy / OUTER_H, 1.3) * 2.5 - 0.25), hy, zc + rng.randf_range(-0.6, 0.6)),
			Color("a4927a").darkened(0.3), Vector3(rng.randf_range(-15, 15), rng.randf_range(-20, 20), sx * rng.randf_range(10, 30)))
	# Çatlaklar: kenardan dışa ve aşağı zikzak (dış ve iç yüzde)
	for face: float in [-1.0, 1.0]:
		var fz := zc + face * (thick * 0.5 + 0.015)
		for c in 4:
			var px := sx * (half + rng.randf_range(1.5, 4.5))
			var py := rng.randf_range(1.0, OUTER_H - 0.6)
			for seg in rng.randi_range(3, 6):
				var l := rng.randf_range(0.35, 0.8)
				var ang := rng.randf_range(-70.0, -20.0) if rng.randf() < 0.6 else rng.randf_range(20.0, 60.0)
				var dir := Vector2(cos(deg_to_rad(ang)) * sx, sin(deg_to_rad(ang)))
				Props.box(self, Vector3(l, rng.randf_range(0.025, 0.045), 0.02), Vector3(px + dir.x * l * 0.5, py + dir.y * l * 0.5, fz),
					Color("2a241e"), Vector3(0, 0, rad_to_deg(atan2(dir.y, dir.x))))
				px += dir.x * l
				py += dir.y * l
				if py < 0.3 or py > OUTER_H:
					break
		# Gülle izi: küçük, düzensiz oyuk ve çevresinde is
		var cp := Vector3(sx * (half + rng.randf_range(3.5, 7.0)), rng.randf_range(2.5, OUTER_H - 1.5), fz)
		for k in 5:
			Props.box(self, Vector3(rng.randf_range(0.2, 0.45), rng.randf_range(0.15, 0.35), 0.03), cp + Vector3(rng.randf_range(-0.3, 0.3), rng.randf_range(-0.25, 0.25), 0),
				Color("3a332c").darkened(rng.randf_range(0, 0.3)), Vector3(0, 0, rng.randf_range(0, 90)))
		Props.box(self, Vector3(0.28, 0.24, 0.04), cp, Color("16120e"), Vector3(0, 0, rng.randf_range(0, 90)))


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
	# Moloz yamacı yürünür (görünen basamaklı moloz katmanlarının içinden geçilmesin): peribolostan gediğin
	# tepesine çıkan eğik zemin; tepede dışarı (hendeğe, ovaya) geçilmez
	# Yamaç görünür: yürünen yüzey görünen yüzeydir (eskiden görünmezdi; ayak üstündeki basamaklı katmanlara gömülüyordu)
	var slope := Props.ramp(self, b + Vector3(0, 0, -4.2), b + Vector3(0, 2.3, -0.6), BREACH_W + 1.4, Color.WHITE)
	Props.set_pattern(slope, Color("6a5e4e"), "rubble")
	slope.set_meta("ground", true)
	# Tepeden dışarı (hendeğe, ovaya) inilebilir: her yer yürünür
	Props.box(self, Vector3(BREACH_W, 1.6, 3.0), b + Vector3(0, 0.55, 0.6), Color("5a5244"), Vector3(-12, 0, 0))
	# Barikat aşamaları (1453'te gediği kapatan aceleye getirilmiş set): 0-3 içi moloz ve toprak dolu fıçılar,
	# 4-5 toprak sepetleri (gabion) ve arkalarında toprak tabya, 6-7 sıkı dizilmiş kalın kütüklerden, iple bağlı
	# kazık perde, 8-9 dışa (düşmana) dönük sivri uçlu çapraz kazıklar. (Eskiden 6-7 ince yatay tahtaydı.)
	for s in STAGES:
		var n := Node3D.new()
		n.visible = false
		add_child(n)
		stages.append(n)
		match s:
			0, 1, 2, 3:
				_stage_block(n, Vector3(1.5, 1.2, 0.74), b + Vector3(-3.0 + s * 1.56 + 0.39, 2.0, -0.2))
				for k in 2:
					var x := -3.0 + (s * 2 + k) * 0.78
					Props.cyl(n, 0.36, 0.95, b + Vector3(x, 1.95, -0.2), C_WOOD.darkened(0.05 * k), Vector3.ZERO, 10)
					for y: float in [1.62, 2.28]:
						Props.cyl(n, 0.375, 0.05, b + Vector3(x, y, -0.2), Color("3a3634"), Vector3.ZERO, 10)
					# Ağzına kadar moloz ve toprak
					Props.ball(n, 0.33, b + Vector3(x, 2.43, -0.2), Color("5a4a38"), Vector3(1, 0.4, 1), 8)
					for j in 3:
						Props.box(n, Vector3(0.16, 0.12, 0.14), b + Vector3(x - 0.12 + j * 0.12, 2.52, -0.2 + (j - 1) * 0.1), C_STONE.darkened(0.2 + j * 0.08), Vector3(j * 20, j * 35, 0))
			4, 5:
				for k in 5:
					var x := -3.0 + ((s - 4) * 5 + k) * 0.62
					Props.cyl(n, 0.28, 0.45, b + Vector3(x, 2.65, -0.25), Color("9a7a48"), Vector3.ZERO, 8, 0.32)
					Props.ball(n, 0.26, b + Vector3(x, 2.9, -0.25), Color("5a4630"), Vector3(1, 0.5, 1), 6)
				# Arkada kürekle yığılmış toprak tabya
				Props.box(n, Vector3(BREACH_W * 0.5, 0.9, 1.6), b + Vector3(-BREACH_W * 0.25 + (s - 4) * BREACH_W * 0.5, 1.9, -1.4), Color("4e4234"), Vector3(-18, 0, 0))
				_stage_block(n, Vector3(BREACH_W * 0.5, 0.9, 1.6), b + Vector3(-BREACH_W * 0.25 + (s - 4) * BREACH_W * 0.5, 1.9, -1.4), Vector3(-18, 0, 0))
				_stage_block(n, Vector3(3.1, 0.6, 0.6), b + Vector3(-3.0 + (s - 4) * 3.1 + 1.24, 2.7, -0.25))
			6, 7:
				# Kütük perde: sırtta 0,26 m çaplı dikey kütükler, iki sıra iple bağlı, dibinde toprak
				for k in 12:
					var x := -3.3 + ((s - 6) * 12 + k) * 0.28
					if x > 3.4:
						break
					var h := 1.9 + (k % 3) * 0.15
					Props.cyl(n, 0.13, h, b + Vector3(x, 2.1 + h * 0.5 - 0.4, -0.75), C_WOOD.darkened(0.08 * (k % 3)), Vector3(4, 0, (k % 2) * 3.0 - 1.5), 7)
					Props.cyl(n, 0.13, 0.12, b + Vector3(x, 2.1 + h - 0.36, -0.75), C_WOOD.darkened(0.3), Vector3(4, 0, 0), 7, 0.02)
				for y: float in [2.3, 3.2]:
					Props.box(n, Vector3(BREACH_W * 0.5, 0.05, 0.3), b + Vector3(-BREACH_W * 0.25 + (s - 6) * BREACH_W * 0.5, y, -0.75), Color("6a5a3a"))
				Props.box(n, Vector3(BREACH_W * 0.5, 0.6, 1.0), b + Vector3(-BREACH_W * 0.25 + (s - 6) * BREACH_W * 0.5, 1.95, -1.1), Color("4e4234"), Vector3(-25, 0, 0))
				_stage_block(n, Vector3(BREACH_W * 0.5, 0.6, 1.0), b + Vector3(-BREACH_W * 0.25 + (s - 6) * BREACH_W * 0.5, 1.95, -1.1), Vector3(-25, 0, 0))
				_stage_block(n, Vector3(3.4, 2.2, 0.32), b + Vector3(-3.3 + (s - 6) * 3.36 + 1.54, 2.9, -0.75))
			8, 9:
				# Çapraz sivri kazıklar: uçları dışarı (hendeğe, düşmana) bakar
				for k in 7:
					var x := -3.2 + ((s - 8) * 7 + k) * 0.48
					for sx: float in [-1.0, 1.0]:
						Props.cyl(n, 0.08, 2.0, b + Vector3(x + sx * 0.12, 3.3, 0.1), C_WOOD, Vector3(38, 0, sx * 14.0), 6, 0.01)
				Props.cyl(n, 0.09, BREACH_W, b + Vector3(0, 3.0, 0.05), C_WOOD.darkened(0.2), Vector3(0, 0, 90), 6)
				_stage_block(n, Vector3(3.4, 1.6, 1.0), b + Vector3(-3.2 + (s - 8) * 3.36 + 1.44, 3.3, 0.1))
	Props.interactable(self, "breach", Vector3(BREACH_W, 3.0, 2.0), b + Vector3(0, 1.5, -1.6))
	# Siper: tekerlekli tahta kalkanlar (top atışında arkasına saklanılır)
	for m: Vector3 in MANTLETS:
		# Tekerlekli ahşap kalkan: dikey kalaslar (aralıklı), iki yatay kuşak, arkada payanda, tekerlekler
		var mn := Node3D.new()
		mn.position = m
		mn.add_to_group("mantlet")
		add_child(mn)
		var sh := Props.solid(mn, Vector3(2.4, 2.2, 0.2), Vector3(0, 1.3, 1.0), C_WOOD.darkened(0.35))
		sh.set_meta("no_climb", true)
		for k in 8:
			Props.box(mn, Vector3(0.27, 2.3 + (k % 3) * 0.08, 0.08), Vector3(-1.05 + k * 0.3, 1.3 + (k % 3) * 0.04, 1.12), C_WOOD.darkened(0.1 + (k % 2) * 0.12))
		for y: float in [0.6, 2.0]:
			Props.box(mn, Vector3(2.5, 0.14, 0.1), Vector3(0, y, 1.2), Color("4a3422"))
		for sx: float in [-0.8, 0.8]:
			Props.box(mn, Vector3(0.1, 2.0, 0.1), Vector3(sx, 1.0, 0.45), Color("4a3422"), Vector3(-28, 0, 0))
			Props.cyl(mn, 0.32, 0.12, Vector3(sx * 1.25, 0.32, 1.0), Color("3a2a1c"), Vector3(0, 0, 90), 10)
	lights.append(Night.torch(self, on_rubble(b + Vector3(-4.6, 0, -2.4)), 2.4))
	lights.append(Night.torch(self, on_rubble(b + Vector3(4.6, 0, -2.4)), 2.4))
	_build_rubble()


## Yıkıntının dolgusu: gedikten iki yana dökülen moloz yamacı (peribolosa ve hendeğe), devrilmiş mazgal taşları,
## kırık kirişler, tüten duman. Gedik "boş bir aralık" değil, çökmüş bir sur gibi görünsün.
func _build_rubble() -> void:
	var b := BREACH
	var rng := RandomNumberGenerator.new()
	rng.seed = 5291453
	var zc := (OUTER_Z0 + OUTER_Z1) * 0.5
	# Yamaç: sur hattında en yüksek (~2,6 m), iki yana alçalan katmanlar
	# Katmanlar katıdır ve eksene hizalıdır (üstleri rubble_y ile birebir: üstlerinde duranlar gömülmez, havada kalmaz);
	# ortadaki rampa hep biraz üstlerindedir, yanlarda basamak olurlar
	for layer in 5:
		var depth := 2.4 + layer * 1.6
		var w := BREACH_W + 1.6 + layer * 1.2
		for k in 4:
			rng.randf()          # eski dağılım (taşların yeri değişmesin)
		var lb := Props.solid(self, Vector3(w, 0.55, depth), b + Vector3(0, RUBBLE_TOP - layer * 0.5 - 0.275, 0.6), Color.WHITE)
		Props.set_pattern(lb, Color("6a5e4e").darkened(layer * 0.04), "rubble")
	# Hendeğe dökülen uzun dil: katmanların dış ucundan hendeğin dibine iner (tongue_y). Eskiden ters eğimliydi:
	# dışa doğru yükselip hendeğin ortasında 1,4 m havada bitiyordu.
	var t0 := Vector3(0, TONGUE_Y0, TONGUE_Z0)
	var t1 := Vector3(0, -2.9, TONGUE_Z1)
	var tl := t0.distance_to(t1)
	var ta := atan2(t0.y - t1.y, t1.z - t0.z)
	var tn := Vector3(0, cos(ta), sin(ta))        # üst yüzün normali
	# Katı: gedik dövüşünde (20o) dile adım atan oyuncu içinden hendeğin altına düşüyordu
	var tongue := Props.box(self, Vector3(TONGUE_W, 1.2, tl + 0.6), Vector3(b.x, 0, 0) + (t0 + t1) * 0.5 - tn * 0.6, Color("5e5446"), Vector3(rad_to_deg(ta), 0, 0))
	Props.make_solid(tongue)
	# Yamacın üstünde dağınık iri kesme taşlar ve devrik mazgallar
	for i in 60:
		var t := rng.randf()
		var z := lerpf(b.z - 5.5, b.z + 8.0, t)
		var ymax := maxf(0.2, 2.8 - absf(z - zc) * 0.38)
		if z < b.z - 1.2:
			ymax = minf(ymax, 0.35)   # peribolos tarafında taşlar yerde: yürüyenin baş hizasında havada durmasın
		var x := rng.randf_range(-BREACH_W * 0.5 - 1.5, BREACH_W * 0.5 + 1.5)
		var yy := rng.randf_range(0.1, ymax)
		if z > OUTER_Z1 + 2.0:
			# Dış yamaçta: katmanların ve dilin üstüne yarı gömülü (hendeğin üstünde havada ya da dilin içinde değil)
			var gy := outside_y(x, z)
			yy = gy + (yy - 0.1) * 0.15
		var sz := Vector3(rng.randf_range(0.35, 1.1), rng.randf_range(0.25, 0.6), rng.randf_range(0.3, 0.8))
		var tone := rng.randf_range(0.1, 0.45)
		var rot := Vector3(rng.randf_range(-35, 35), rng.randf_range(0, 180), rng.randf_range(-35, 35))
		if z >= OUTER_Z0 and absf(x - b.x) < 2.0:
			continue      # gediğin tepesinden geçen yol (Bölüm 26: Sultan'ın atı ve maiyeti) açık kalsın
		if z >= OUTER_Z0 and z <= OUTER_Z1 + 2.0:
			yy = rubble_y(x, z) + (yy - 0.1) * 0.12 - sz.y * 0.15      # katmanların üstüne yarı gömülü (havada değil)
		if z < OUTER_Z0:
			# Oyuncunun tarafında: yamaca / yere gömülü, yassı; yüzeyden ayak bileği kadar taşar (eskiden 0,2–0,3 m
			# taşıyordu: üstünden geçen savunucu, taşıyıcı ve düellocu taşın içine gömülü görünüyordu)
			if z < BREACH.z - 4.2:
				sz *= 0.55
			rot = Vector3(rot.x * 0.15, rot.y, rot.z * 0.15)
			yy = rubble_y(x, z) - sz.y * 0.3
		Props.box(self, sz, Vector3(x, yy, z), Color("9a8a72").darkened(tone), rot)
	for i in 5:
		var bp := b + Vector3(rng.randf_range(-3.5, 3.5), rng.randf_range(0.8, 2.2), rng.randf_range(-1.5, 3.0))
		var br := Vector3(rng.randf_range(-60, 60), rng.randf_range(0, 90), rng.randf_range(-70, 70))
		# Yamaca gömülü (oyuncunun yürüdüğü yerde içinden geçilmesin; dışarıda katmanların üstünde havada durmasın).
		# İçeride 0,35 m gömülü: dönük blok yamaçtan en çok ~0,2 m taşar (eskiden 0,4 m taşıyor, bacaklar içinden geçiyordu)
		bp.y = rubble_y(bp.x, bp.z) - (0.35 if bp.z < BREACH.z + 0.75 else -0.2)      # tepedeki korkuluğa (z 15,75) kadar yürünür
		Props.box(self, Vector3(1.1, 0.9, 0.7), bp, Color("a4927a").darkened(0.25), br)
	# Kırık kirişler ve çitin kalıntısı: yamacın üstünde yatık
	for i in 4:
		var len := rng.randf_range(2.0, 3.6)
		var kp := b + Vector3(rng.randf_range(-3, 3), rng.randf_range(1.2, 2.6), rng.randf_range(-1.5, 2.0))
		var kr := Vector3(rng.randf_range(-40, 40), rng.randf_range(0, 180), rng.randf_range(-30, 30))
		kp.y = rubble_y(kp.x, kp.z) + 0.1          # yamacın üstünde yatık (havada değil)
		if kp.z < OUTER_Z0:
			kr = Vector3(rng.randf_range(-6, 6), kr.y, rng.randf_range(-6, 6))
		Props.box(self, Vector3(0.18, 0.18, len), kp, C_WOOD.darkened(0.35), kr)
	# Toz ve duman: gedikte ve surun dibinde tüten yerler
	Vfx.smolder(self, b + Vector3(-2.2, 2.2, 1.2), 1.0)
	Vfx.smolder(self, b + Vector3(2.8, 1.2, 3.6), 0.7, false)
	Vfx.smolder(self, Vector3(-11.0, OUTER_H + 0.4, zc), 0.6, false)


## Malzeme deposu: fıçılar, toprak yığını ve sepetler, kalaslar. Oyuncu buradan yük alır.
func _build_depot() -> void:
	var d := DEPOT
	for i in 5:
		Props.cyl(self, 0.36, 0.95, d + Vector3(-2.6 + (i % 3) * 0.8, 0.48 + (i / 3) * 0.95, -0.6), C_WOOD.darkened((i % 2) * 0.1), Vector3.ZERO, 10)
	Props.ball(self, 1.3, d + Vector3(0.4, 0.2, 0.2), Color("5a4630"), Vector3(1.2, 0.6, 1.0), 8).create_convex_collision()
	for i in 4:
		Props.cyl(self, 0.28, 0.45, d + Vector3(1.8 + (i % 2) * 0.6, 0.23, 0.9 + (i / 2) * 0.6), Color("9a7a48"), Vector3.ZERO, 8, 0.32)
	for i in 6:
		Props.box(self, Vector3(3.2, 0.12, 0.3), d + Vector3(3.8, 0.1 + i * 0.13, -0.4 + (i % 2) * 0.05), Color("8a6440"))
	# Yığınlar katı (fıçı istifi, sepetler, kalas yığını): içlerinden yürünmesin; etkileşim alanları dışarıdan erişilir
	for b: Array in [[Vector3(2.0, 1.9, 0.76), Vector3(-1.8, 0.95, -0.6)], [Vector3(1.16, 0.45, 1.16), Vector3(2.1, 0.23, 1.2)],
			[Vector3(3.2, 0.82, 0.36), Vector3(3.8, 0.41, -0.38)]]:
		var body := Props.solid(self, b[0], d + b[1], Color.WHITE)
		body.get_child(0).visible = false
	Props.interactable(self, "pile_barrel", Vector3(2.4, 2.0, 1.6), d + Vector3(-1.8, 1.0, -0.4))
	Props.interactable(self, "pile_earth", Vector3(2.4, 1.6, 2.4), d + Vector3(0.9, 0.8, 0.5))
	Props.interactable(self, "pile_plank", Vector3(3.4, 1.2, 1.4), d + Vector3(3.8, 0.6, -0.3))


## Ova (SiegeField): arazi, sur devamı, şehir, ölü bölge, Osmanlı siperi ve bataryaları, ordu, ordugâh, otağ.
## Urban'ın topu (ahşap siper arkasında) burada kurulur.
func _build_field() -> void:
	field = SiegeField.new()
	field.near_works = near_works and not assault_mode
	field.assault = assault_mode
	field.lite = lite
	if lite:
		field.world = false        # menünün kamerası gediğe bakar: Haliç ve şehrin doğusu kurulmaz
	field.keep = [Rect2(-8.0, 104.0, 34.0, 30.0)] + field_keep     # büyük topun döşemesi
	field.open = [Rect2(-36.0, 17.0, 72.0, 66.0)]                   # yakın ova: bölümlerin kendi alanı
	add_child(field)
	field.build()
	# Her yer yürünür: ova, sur devamı, şehir ve ordugâh katılaşır (menünün hafif sahnesinde dünya yok)
	if field.world:
		WorldWalk.attach(field)
	var c := CANNON
	far_gun = _great_gun_model()
	_flash = OmniLight3D.new()
	_flash.position = c + Vector3(0, 1.0, -6.0)
	_flash.light_color = Color("ffb060")
	_flash.light_energy = 0.0
	_flash.omni_range = 60.0
	add_child(_flash)


## Büyük topun siperliği: halatlarla dışarı-yukarı kaldırılır (open) ya da iner. Döndürür: hareketin süresi.
func gun_screen(open: bool, secs := 0.6) -> float:
	var screen := far_gun.get_node_or_null("Screen") as Node3D if far_gun else null
	if screen == null:
		return 0.0
	var tw := screen.create_tween()
	tw.tween_property(screen, "rotation:x", deg_to_rad(78.0) if open else 0.0, secs).set_trans(Tween.TRANS_SINE)
	if open:
		Audio.sfx("door_metal", -14.0, 0.6)
	return secs


## Topun ağzında parlama ve duman (uzakta).
## Top ateşinde peribolostaki savaş kalabalığı (BattleExtras) kendiliğinden siper alır ("Siper!"); sinematik
## sahneler (fragman, Bölüm 0) kendi zamanlamalarını yönettiği için kapatır.
var auto_cover := true


func fire_flash() -> void:
	if auto_cover and is_inside_tree() and get_tree().get_nodes_in_group("battle_extras").any(func(b): return b.get("side") == "byz"):
		preload("res://scripts/level/battle_extras.gd").cover_briefly(get_tree().current_scene, 3.5)
	_flash.light_energy = 16.0
	create_tween().tween_property(_flash, "light_energy", 0.0, 0.6)
	# Şahi: ufukta kör edici parlama ekrana da vursun, müzik bir an kısılsın
	Fx.edge(Color("fff4dc"), 0.55, 0.4)
	Audio.duck(-10.0, 1.2)
	Vfx.gun_blast(self, CANNON + Vector3(0, 1.5, -6.0), 1.6, BREACH + Vector3(0, 14.0, 30.0))
	# Siperlik kapalıysa (bölüm önce açmadıysa) atışla birlikte açık görünür; sonra yavaşça iner
	var screen := far_gun.get_node_or_null("Screen") as Node3D if far_gun else null
	if screen:
		if screen.rotation.x < deg_to_rad(60.0):
			screen.rotation.x = deg_to_rad(78.0)
		var tw := screen.create_tween()
		tw.tween_interval(2.5)
		tw.tween_property(screen, "rotation:x", 0.0, 1.6).set_trans(Tween.TRANS_SINE)


## Güllenin gediğe çarpması: toz, taş, sarsıntı.
func impact(at: Vector3) -> void:
	Vfx.explosion(self, at, 0.8)
	Vfx.dust(self, at, 1.6)
	# Gülle sura iner: yakındaysak sarsıntı ve kısa donma, uzaktaysak hafif titreme
	var cam := get_viewport().get_camera_3d()
	var d := cam.global_position.distance_to(at) if cam else 50.0
	Fx.trauma(clampf(1.2 - d / 40.0, 0.15, 0.9))
	if d < 25.0:
		Fx.hitstop(0.06)
		Audio.stinger("cannon", -4.0)


## Gedikteki moloz yamacının yüksekliği (onarım ekibi yamaca basar, içine gömülmez).
static func rubble_y(x: float, z: float) -> float:
	var y := 0.0
	# Peribolostan tepeye çıkan rampa yalnız surun iç yarısında. (Eskiden dışarıda da, hendeğin ve ovanın üstünde de
	# tepe yüksekliğini veriyordu: surun dışında 2,3 m havada.)
	if absf(x - BREACH.x) <= (BREACH_W + 1.4) * 0.5 and z >= BREACH.z - 4.2 and z <= BREACH.z + 0.6:
		y = clampf((z - (BREACH.z - 4.2)) / 3.6, 0.0, 1.0) * 2.3
	# Basamaklı katmanlar (katı): üstten alta ilk kapsayan en yükseğidir
	for layer in 5:
		if absf(x - BREACH.x) <= (BREACH_W + 1.6 + layer * 1.2) * 0.5 and absf(z - (BREACH.z + 0.6)) <= (2.4 + layer * 1.6) * 0.5:
			return maxf(y, RUBBLE_TOP - layer * 0.5)
	return y


## Gediğin önünde hendeğe dökülen moloz dilinin üstü: katmanların dış ucundan (z 19.6, 0.3 m) hendeğin dibine
## (z 25.5, -2.9 m) iner. Yalnız gediğin önünde (|x| < TONGUE_W / 2); korkuluk orada yıkıktır.
static func tongue_y(z: float) -> float:
	return lerpf(TONGUE_Y0, -2.9, clampf((z - TONGUE_Z0) / (TONGUE_Z1 - TONGUE_Z0), 0.0, 1.0))


## Surun dışında (z > OUTER_Z1) gediğin önündeki görünen zemin: basamaklı katman; yoksa hendeğe dökülen dil; yoksa set
## (y 0) ya da hendek dibi (-2,9). rubble_y katman olmayan yerde 0 döndürür: max(rubble_y, tongue_y) dilin üstünde 0
## verir, dilin (y < 0) 1–3 m üstünde havada kalınıyordu.
static func outside_y(x: float, z: float) -> float:
	var ry := rubble_y(x, z)
	var on_tongue := absf(x - BREACH.x) < TONGUE_W * 0.5 and z >= TONGUE_Z0
	var ditch := z > 20.4 and z < 35.8
	var floor_y := (fill_y(x, z) if ditch_filled else -2.9) if ditch else 0.0
	if ry > 0.0:
		return maxf(ry, maxf(tongue_y(z), floor_y)) if on_tongue else ry
	if on_tongue:
		return maxf(tongue_y(z), floor_y)
	# Hendeğin dışı (z ≥ 35,8) ova: eskiden z > 20,4'ün hepsi hendek dibi sayılıyor, ovadaki koşanlar yerin 3 m
	# altında yürüyordu
	return floor_y


## Noktayı moloz yamacının yüzeyine oturtur (gediğin dibinde duranlar yamacın içine gömülmesin).
static func on_rubble(p: Vector3) -> Vector3:
	return Vector3(p.x, maxf(p.y, rubble_y(p.x, p.z)), p.z)


func set_repair(n: int) -> void:
	for i in stages.size():
		stages[i].visible = i < n
		# Barikatın her aşaması katıdır (içinden yürünmez); görünmeyen aşamanın çarpışması kapalı
		for cs in stages[i].find_children("*", "CollisionShape3D", true, false):
			(cs as CollisionShape3D).set_deferred("disabled", i >= n)


## Barikat aşamasının görünmez çarpışma kutusu (aşama gizliyken kapalı; set_repair açar).
func _stage_block(n: Node3D, size: Vector3, pos: Vector3, rot := Vector3.ZERO) -> void:
	var body := Props.solid(n, size, pos, Color.WHITE, rot)
	body.get_child(0).visible = false
	body.set_meta("no_climb", true)
	(body.get_child(1) as CollisionShape3D).disabled = true


## Gündüz: açık gök, güneş (topun gündüz dövdüğü surlar; Osmanlı tarafı bölümleri).
func make_day() -> void:
	if env == null:
		return
	var e := env.environment
	var sm := e.sky.sky_material as ProceduralSkyMaterial
	sm.sky_top_color = Color("4a86c8")
	sm.sky_horizon_color = Color("c8dcec")
	sm.ground_horizon_color = Color("a89878")
	e.ambient_light_color = Color("c8ccd4")
	e.ambient_light_energy = 0.8
	e.fog_light_color = Color("c8d4e0")
	e.fog_density = 0.003
	moon.light_color = Color("fff4e0")
	moon.light_energy = 1.2
	moon.rotation_degrees = Vector3(-48, 150, 0)
	if field:
		field.set_mode("day")
	for l in lights:
		if l is OmniLight3D:
			(l as OmniLight3D).light_energy = 0.0


## Urban'ın büyük topu yakından oynanacaksa (Bölüm 20o): döşemenin kenarlarına görünmez duvar, arkaya ip çit.
## Top her bölümde aynı modeldir (uzaktan da görünür); oyuncu bu alanda kalır, ovaya yürüyüp düşmez.
func build_great_gun() -> Node3D:
	var g := far_gun
	for spec in [[Vector3(0.3, 4.0, 20.0), Vector3(-12.0, 2.0, 2.0)], [Vector3(0.3, 4.0, 20.0), Vector3(12.0, 2.0, 2.0)],
			[Vector3(24.0, 4.0, 0.3), Vector3(0, 2.0, -6.0)], [Vector3(24.0, 4.0, 0.3), Vector3(0, 2.0, 11.8)]]:
		var b := Props.solid(g, spec[0], spec[1], Color.WHITE)
		b.get_child(0).visible = false
		b.set_meta("no_climb", true)
		b.set_meta("ball_through", true)
	for i in 9:
		Props.cyl(g, 0.07, 1.2, Vector3(-11.0 + i * 2.75, 0.6, 11.6), C_WOOD.darkened(0.2), Vector3.ZERO, 6)
	for y: float in [0.55, 1.0]:
		Props.box(g, Vector3(22.0, 0.035, 0.035), Vector3(0, y, 11.6), Color("8a7050"))
	return g


## Urban'ın büyük topu: iki parçalı tunç namlu, kızak, ahşap siper; önünde çalışma alanı (namlu surlara, -z'ye bakar).
func _great_gun_model() -> Node3D:
	var g := Node3D.new()
	g.position = CANNON + Vector3(0, -1.5, 0)
	add_child(g)
	var bronze := Color("8c5e26")
	Props.box(g, Vector3(3.2, 0.6, 9.0), Vector3(0, 0.3, 0), C_WOOD.darkened(0.2))
	for z: float in [-3.5, 0.0, 3.5]:
		Props.box(g, Vector3(3.6, 0.4, 0.5), Vector3(0, 0.1, z), C_WOOD.darkened(0.35))
	# Namlu muylu ekseninde döner (elle nişan: CannonCrew): "Pivot" altında, ağzında "Muzzle" (-Z dışarı)
	var pv := Node3D.new()
	pv.name = "Pivot"
	pv.position = Vector3(0, 1.6, 0)
	g.add_child(pv)
	Props.cyl(pv, 1.05, 5.0, Vector3(0, 0, -1.8), bronze, Vector3(90, 0, 0), 16)
	Props.cyl(pv, 0.8, 3.4, Vector3(0, 0, 2.4), bronze.darkened(0.08), Vector3(90, 0, 0), 16)
	Props.cyl(pv, 1.25, 0.5, Vector3(0, 0, -4.3), bronze.lightened(0.05), Vector3(90, 0, 0), 16, 1.35)
	Props.cyl(pv, 0.8, 0.1, Vector3(0, 0, -4.56), Color("15120f"), Vector3(90, 0, 0), 16)
	for z: float in [-3.2, -0.8, 0.8, 3.4]:
		Props.cyl(pv, 1.12 if z < 0.0 else 0.88, 0.25, Vector3(0, 0, z), bronze.lightened(0.08), Vector3(90, 0, 0), 16)
	var mz := Node3D.new()
	mz.name = "Muzzle"
	mz.position = Vector3(0, 0, -4.62)
	pv.add_child(mz)
	# Kama takozu (yükseklik) ve kaldıraçlar
	Props.box(g, Vector3(1.4, 0.5, 1.2), Vector3(0, 0.75, 3.2), C_WOOD.darkened(0.1))
	# Siperlik (mantelet): topçular namlu doldururken onları koruyan, kalın kalaslardan çivili ağır kapak. İki direğin
	# arasındaki kirişe üst kenarından menteşeli; alt kenarına bağlı halatlar kirişteki makaralardan geçip arkadaki
	# bocurgata iner. Ateşten hemen önce halatlarla dışarı-yukarı kaldırılır (köprü gibi), atıştan sonra iner.
	# İki yanında toprak dolu hasır sepetler (gabion): kapak ikisinin arasına oturur. (Eskiden namlunun önünde
	# yere çakılı düz bir kutuydu.)
	var hinge_y := 4.3
	var fz := -6.5
	for sx: float in [-1.0, 1.0]:
		Props.box(g, Vector3(0.45, 5.6, 0.45), Vector3(sx * 4.25, 2.8, fz), C_WOOD.darkened(0.3))
		Props.box(g, Vector3(0.3, 0.3, 2.2), Vector3(sx * 4.25, 1.2, fz + 1.0), C_WOOD.darkened(0.3), Vector3(35, 0, 0))   # payanda
		Props.cyl(g, 0.28, 0.2, Vector3(sx * 3.2, 5.45, fz), Color("3a3634"), Vector3(0, 0, 90), 10)   # makara
		# Halat: makaradan arkadaki bocurgata
		Props.cyl(g, 0.035, 6.2, Vector3(sx * 3.2, 3.05, fz + 2.2), Color("b89a68"), Vector3(-42, 0, 0), 4)
		# Gabionlar: iki sıra, üst üste
		for k in 3:
			for lvl in 2:
				var gp := Vector3(sx * (5.2 + k * 1.25), 0.75 + lvl * 1.45, fz + 0.1 + (k % 2) * 0.25)
				Props.cyl(g, 0.62, 1.45, gp, Color("7a5c36"), Vector3.ZERO, 10)
				for b in 3:
					Props.cyl(g, 0.635, 0.07, gp + Vector3(0, -0.5 + b * 0.5, 0), Color("5a4226"), Vector3.ZERO, 10)
				Props.cyl(g, 0.56, 0.08, gp + Vector3(0, 0.72, 0), Color("4e3e28"), Vector3.ZERO, 10)   # üstü toprak
	Props.box(g, Vector3(9.0, 0.4, 0.5), Vector3(0, 5.6, fz), C_WOOD.darkened(0.35))   # kiriş
	Props.cyl(g, 0.45, 1.0, Vector3(0, 0.9, fz + 4.3), C_WOOD.darkened(0.15), Vector3(0, 0, 90), 10)   # bocurgat
	var screen := Node3D.new()
	screen.name = "Screen"
	screen.position = Vector3(0, hinge_y, fz)
	g.add_child(screen)
	var wood := C_WOOD.darkened(0.25)
	for i in 7:
		Props.box(screen, Vector3(1.04, 4.1, 0.34), Vector3(-3.15 + i * 1.05, -2.05, 0), wood.darkened(0.06 * (i % 3)))
	for by: float in [-0.5, -2.0, -3.6]:
		Props.box(screen, Vector3(7.4, 0.2, 0.08), Vector3(0, by, -0.2), Color("3a3634"))   # demir kuşak
		for i in 12:
			Props.ball(screen, 0.05, Vector3(-3.3 + i * 0.6, by, -0.25), Color("2a2624"), Vector3.ONE, 5)   # çivi başları
	for sx: float in [-1.0, 1.0]:
		Props.cyl(screen, 0.03, 0.9, Vector3(sx * 3.2, -3.7, -0.3), Color("b89a68"), Vector3(-20, 0, 0), 4)   # halat bağı
	# Barut, tapa, gülle yığınları
	for i in 4:
		Props.cyl(g, 0.35, 0.8, Vector3(-3.5, 0.4, 1.0 + i * 0.8), Color("2e2a26"), Vector3.ZERO, 10)
	for i in 5:
		Props.ball(g, 0.34, Vector3(4.4 + (i % 2) * 0.72, 0.34, -1.2 + (i / 2) * 0.72), Color("6e6a62"), Vector3.ONE, 10)
	Props.cyl(g, 0.4, 0.9, Vector3(-3.4, 0.45, -2.0), Color("6a5a30"), Vector3.ZERO, 10)   # zeytinyağı küpü
	Props.set_pattern(Props.solid(g, Vector3(24, 0.4, 20), Vector3(0, -0.2, 2.0), Color.WHITE), Color("7a6a50"), "cobble")
	# Katı parçalar (eskiden topun, kızağın, sepetlerin, barut fıçılarının içinden yürünüyordu). Namlunun kutusu
	# muylu ekseniyle döner (nişan alınınca birlikte kalkar).
	var solids := [[g, Vector3(3.2, 0.6, 9.0), Vector3(0, 0.3, 0)], [pv, Vector3(2.3, 2.3, 8.7), Vector3(0, 0, -0.15)],
		[g, Vector3(3.8, 3.65, 1.4), Vector3(-6.45, 1.83, fz + 0.2)], [g, Vector3(3.8, 3.65, 1.4), Vector3(6.45, 1.83, fz + 0.2)],
		[g, Vector3(0.45, 5.6, 0.45), Vector3(-4.25, 2.8, fz)], [g, Vector3(0.45, 5.6, 0.45), Vector3(4.25, 2.8, fz)],
		[g, Vector3(0.72, 0.8, 3.1), Vector3(-3.5, 0.4, 2.2)], [g, Vector3(1.45, 0.68, 1.9), Vector3(4.76, 0.34, -0.48)],
		[g, Vector3(0.8, 0.9, 0.8), Vector3(-3.4, 0.45, -2.0)]]
	for sd: Array in solids:
		var body := Props.solid(sd[0], sd[1], sd[2], Color.WHITE)
		body.get_child(0).visible = false
		body.set_meta("no_climb", true)
		body.set_meta("ball_through", true)     # gülle yolu (nişan izi, uçuş) topun kendi parçalarına takılmasın
	return g


## Şafak: gökyüzü ve ay ışığı sabaha döner.
func make_dawn(t := 1.0) -> void:
	if env == null:
		return
	if field:
		field.set_mode("dawn")
	var e := env.environment
	var sm := e.sky.sky_material as ProceduralSkyMaterial
	var tw := create_tween().set_parallel()
	tw.tween_property(sm, "sky_top_color", Color("5a7ab0"), t)
	tw.tween_property(sm, "sky_horizon_color", Color("f0b080"), t)
	tw.tween_property(sm, "ground_horizon_color", Color("c89070"), t)
	tw.tween_property(e, "ambient_light_color", Color("c8b8b0"), t)
	tw.tween_property(e, "ambient_light_energy", 0.7, t)
	tw.tween_property(e, "fog_light_color", Color("d0a888"), t)
	tw.tween_property(e, "fog_density", 0.0032, t)          # şafakta ordu ve ordugâh seçilsin
	tw.tween_property(moon, "light_color", Color("ffc890"), t)
	tw.tween_property(moon, "light_energy", 0.9, t)
	tw.tween_property(moon, "rotation_degrees", Vector3(-8, 180, 0), t)
