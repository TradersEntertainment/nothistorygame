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
var assault_mode := false
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
	# Oyun alanının yan uçları: surlar arasında yıkıntı ve dikenli çit (görünür engel)
	for sx: float in [-1.0, 1.0]:
		var x := sx * 32.0
		_wall(Vector3(1.2, 3.0, OUTER_Z0 - INNER_Z1), Vector3(x, 1.5, (INNER_Z1 + OUTER_Z0) * 0.5), C_STONE.darkened(0.15))
		for i in 6:
			Props.cyl(self, 0.08, 2.2, Vector3(x - sx * 0.8, 1.0, 1.0 + i * 2.2), C_WOOD, Vector3(sx * 28.0, 0, 18.0), 5)


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
	# Geçidin tavanı ve yan yüzleri (içinden bakınca taş)
	Props.box(self, Vector3(GATE_W, 0.1, th), Vector3(0, GATE_H - 0.05, zc), C_STONE.darkened(0.25))
	# Kırılmış kapı kanatları: biri içe açılmış, biri menteşesinden düşüp yere yaslanmış
	var wood := C_WOOD.darkened(0.2)
	var l := Node3D.new()
	l.position = Vector3(-GATE_W * 0.5 + 0.1, 0, INNER_Z0 - 0.1)
	l.rotation.y = deg_to_rad(-100)
	add_child(l)
	Props.box(l, Vector3(GATE_W * 0.5 - 0.1, GATE_H - 0.3, 0.14), Vector3((GATE_W * 0.5 - 0.1) * 0.5, (GATE_H - 0.3) * 0.5, 0), wood)
	for k in 4:
		Props.box(l, Vector3(GATE_W * 0.5 - 0.1, 0.08, 0.18), Vector3((GATE_W * 0.5 - 0.1) * 0.5, 0.8 + k * 1.5, 0), Color("3a3634"))
	var r := Node3D.new()
	r.position = Vector3(GATE_W * 0.5 + 0.9, 0.15, INNER_Z0 - 1.6)
	r.rotation = Vector3(deg_to_rad(-72), deg_to_rad(80), 0)
	add_child(r)
	Props.box(r, Vector3(GATE_W * 0.5 - 0.1, GATE_H - 0.3, 0.14), Vector3(0, (GATE_H - 0.3) * 0.5, 0), wood.darkened(0.15))


func _build_outer() -> void:
	var half := BREACH_W * 0.5
	for sx: float in [-1.0, 1.0]:
		var len := 48.0 - half - EDGE_W
		var cx := sx * (half + EDGE_W + len * 0.5)
		_wall(Vector3(len, OUTER_H, OUTER_Z1 - OUTER_Z0), Vector3(cx, OUTER_H * 0.5, (OUTER_Z0 + OUTER_Z1) * 0.5), C_STONE.darkened(0.05))
		var x := sx * (half + EDGE_W + 0.5)
		var merl: Array = []
		while absf(x) < 48.0:
			merl.append(Transform3D(Basis.from_scale(Vector3(1.1, 0.9, 0.7)), Vector3(x, OUTER_H + 0.45, OUTER_Z1 - 0.3)))
			x += sx * 1.8
		Scenery.scatter(self, Scenery._boxm(Vector3.ONE), merl, [], Props.mat(C_STONE.darkened(0.1), 0.0, false, "ashlar"))
		_broken_edge(sx, half)
		# Yürüyüş yolunun dış kenarında görünmez korkuluk (mazgalların üstünden ovaya atlanmasın) ve yolun ucu
		var guard := Props.solid(self, Vector3(len, 3.2, 0.3), Vector3(cx, OUTER_H + 1.6, OUTER_Z1 - 0.1), Color.WHITE)
		guard.get_child(0).visible = false
		guard.set_meta("no_climb", true)
		var cap := Props.solid(self, Vector3(0.3, 3.2, OUTER_Z1 - OUTER_Z0 + 0.4), Vector3(sx * 30.5, OUTER_H + 1.6, (OUTER_Z0 + OUTER_Z1) * 0.5), Color.WHITE)
		cap.get_child(0).visible = false
		cap.set_meta("no_climb", true)
		# Dış sur kuleleri
		var tx := sx * 16.0
		_wall(Vector3(5.0, OUTER_H + 3.0, 5.0), Vector3(tx, (OUTER_H + 3.0) * 0.5, OUTER_Z1 + 1.0), C_STONE.darkened(0.08))
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
		# Kesitte moloz-harç çekirdek: kırık uçta iki yüz arasında koyu, girintili dolgu
		Props.box(self, Vector3(0.35, h * 0.95, thick - 0.7), Vector3(sx * (x0 - 0.1), y + h * 0.5, zc), Color("5e5446").darkened(rng.randf_range(0, 0.15)))
		# Uçta yarım kalmış kesme taşlar (yüzlerden dışarı taşan)
		if rng.randf() < 0.6:
			var face := -1.0 if rng.randf() < 0.5 else 1.0
			Props.box(self, Vector3(rng.randf_range(0.4, 0.8), h * 0.9, 0.55), Vector3(sx * (x0 - 0.3), y + h * 0.45, zc + face * (thick * 0.5 - 0.28)),
				col.darkened(0.08), Vector3(rng.randf_range(-6, 6), rng.randf_range(-12, 12), rng.randf_range(-12, 12)))
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
	var slope := Props.ramp(self, b + Vector3(0, 0, -4.2), b + Vector3(0, 2.3, -0.6), BREACH_W + 1.4, Color.WHITE)
	slope.get_child(0).visible = false
	slope.set_meta("ground", true)      # görünmez ama gerçek zemin (moloz katmanlarının altında)
	var crest := Props.solid(self, Vector3(BREACH_W + 3.0, 5.0, 0.3), b + Vector3(0, 4.5, 0.9), Color.WHITE)
	crest.get_child(0).visible = false
	crest.set_meta("no_climb", true)
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
					Props.cyl(n, 0.28, 0.45, b + Vector3(x, 2.65, -0.25), Color("9a7a48"), Vector3.ZERO, 8, 0.32)
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
	lights.append(Night.torch(self, b + Vector3(-4.6, 0, -2.4), 2.4))
	lights.append(Night.torch(self, b + Vector3(4.6, 0, -2.4), 2.4))
	_build_rubble()


## Yıkıntının dolgusu: gedikten iki yana dökülen moloz yamacı (peribolosa ve hendeğe), devrilmiş mazgal taşları,
## kırık kirişler, tüten duman. Gedik "boş bir aralık" değil, çökmüş bir sur gibi görünsün.
func _build_rubble() -> void:
	var b := BREACH
	var rng := RandomNumberGenerator.new()
	rng.seed = 5291453
	var zc := (OUTER_Z0 + OUTER_Z1) * 0.5
	# Yamaç: sur hattında en yüksek (~2,6 m), iki yana alçalan katmanlar
	for layer in 5:
		var h := 2.6 - layer * 0.5
		var depth := 2.4 + layer * 1.6
		var w := BREACH_W + 1.6 + layer * 1.2
		Props.box(self, Vector3(w, 0.55, depth), b + Vector3(rng.randf_range(-0.3, 0.3), h - 0.3, 0.6 + (zc - b.z) * 0.0), Color("6a5e4e").darkened(layer * 0.04),
			Vector3(rng.randf_range(-2, 2), rng.randf_range(-6, 6), rng.randf_range(-2, 2)))
	# Hendeğe dökülen uzun dil
	Props.box(self, Vector3(BREACH_W + 2.0, 1.2, 7.0), b + Vector3(0, -0.6, 6.6), Color("5e5446"), Vector3(-24, 0, 0))
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
			yy -= (z - OUTER_Z1 - 2.0) * 0.45
		var sz := Vector3(rng.randf_range(0.35, 1.1), rng.randf_range(0.25, 0.6), rng.randf_range(0.3, 0.8))
		Props.box(self, sz, Vector3(x, yy, z), Color("9a8a72").darkened(rng.randf_range(0.1, 0.45)),
			Vector3(rng.randf_range(-35, 35), rng.randf_range(0, 180), rng.randf_range(-35, 35)))
	for i in 5:
		Props.box(self, Vector3(1.1, 0.9, 0.7), b + Vector3(rng.randf_range(-3.5, 3.5), rng.randf_range(0.8, 2.2), rng.randf_range(-1.5, 3.0)),
			Color("a4927a").darkened(0.25), Vector3(rng.randf_range(-60, 60), rng.randf_range(0, 90), rng.randf_range(-70, 70)))
	# Kırık kirişler ve çitin kalıntısı
	for i in 4:
		Props.box(self, Vector3(0.18, 0.18, rng.randf_range(2.0, 3.6)), b + Vector3(rng.randf_range(-3, 3), rng.randf_range(1.2, 2.6), rng.randf_range(-1.5, 2.0)),
			C_WOOD.darkened(0.35), Vector3(rng.randf_range(-40, 40), rng.randf_range(0, 180), rng.randf_range(-30, 30)))
	# Toz ve duman: gedikte ve surun dibinde tüten yerler
	Vfx.smolder(self, b + Vector3(-2.2, 2.2, 1.2), 1.0)
	Vfx.smolder(self, b + Vector3(2.8, 1.2, 3.6), 0.7, false)
	Vfx.smolder(self, Vector3(-11.0, OUTER_H + 0.4, zc), 0.6, false)


## Malzeme deposu: fıçılar, toprak yığını ve sepetler, kalaslar. Oyuncu buradan yük alır.
func _build_depot() -> void:
	var d := DEPOT
	for i in 5:
		Props.cyl(self, 0.36, 0.95, d + Vector3(-2.6 + (i % 3) * 0.8, 0.48 + (i / 3) * 0.95, -0.6), C_WOOD.darkened((i % 2) * 0.1), Vector3.ZERO, 10)
	Props.ball(self, 1.3, d + Vector3(0.4, 0.2, 0.2), Color("5a4630"), Vector3(1.2, 0.6, 1.0), 8)
	for i in 4:
		Props.cyl(self, 0.28, 0.45, d + Vector3(1.8 + (i % 2) * 0.6, 0.23, 0.9 + (i / 2) * 0.6), Color("9a7a48"), Vector3.ZERO, 8, 0.32)
	for i in 6:
		Props.box(self, Vector3(3.2, 0.12, 0.3), d + Vector3(3.8, 0.1 + i * 0.13, -0.4 + (i % 2) * 0.05), Color("8a6440"))
	Props.interactable(self, "pile_barrel", Vector3(2.4, 2.0, 1.6), d + Vector3(-1.8, 1.0, -0.4))
	Props.interactable(self, "pile_earth", Vector3(2.4, 1.6, 2.4), d + Vector3(0.9, 0.8, 0.5))
	Props.interactable(self, "pile_plank", Vector3(3.4, 1.2, 1.4), d + Vector3(3.8, 0.6, -0.3))


## Ova (SiegeField): arazi, sur devamı, şehir, ölü bölge, Osmanlı siperi ve bataryaları, ordu, ordugâh, otağ.
## Urban'ın topu (ahşap siper arkasında) burada kurulur.
func _build_field() -> void:
	field = SiegeField.new()
	field.near_works = near_works and not assault_mode
	field.assault = assault_mode
	field.keep = [Rect2(-8.0, 104.0, 34.0, 30.0)] + field_keep     # büyük topun döşemesi
	field.open = [Rect2(-36.0, 17.0, 72.0, 66.0)]                   # yakın ova: bölümlerin kendi alanı
	add_child(field)
	field.build()
	var c := CANNON
	far_gun = _great_gun_model()
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


## Gedikteki moloz yamacının yüksekliği (onarım ekibi yamaca basar, içine gömülmez).
static func rubble_y(x: float, z: float) -> float:
	if absf(x - BREACH.x) > (BREACH_W + 1.4) * 0.5 or z < BREACH.z - 4.2:
		return 0.0
	return clampf((z - (BREACH.z - 4.2)) / 3.6, 0.0, 1.0) * 2.3


## Noktayı moloz yamacının yüzeyine oturtur (gediğin dibinde duranlar yamacın içine gömülmesin).
static func on_rubble(p: Vector3) -> Vector3:
	return Vector3(p.x, maxf(p.y, rubble_y(p.x, p.z)), p.z)


func set_repair(n: int) -> void:
	for i in stages.size():
		stages[i].visible = i < n


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
	# Ahşap siper (atıştan sonra kaldırılır) ve barut, tapa, gülle yığınları
	var screen := Node3D.new()
	screen.name = "Screen"
	screen.position = Vector3(0, 0, -6.5)
	g.add_child(screen)
	Props.box(screen, Vector3(8.0, 3.2, 0.5), Vector3(0, 1.6, 0), C_WOOD.darkened(0.25))
	for i in 4:
		Props.cyl(g, 0.35, 0.8, Vector3(-3.5, 0.4, 1.0 + i * 0.8), Color("2e2a26"), Vector3.ZERO, 10)
	for i in 5:
		Props.ball(g, 0.34, Vector3(4.4 + (i % 2) * 0.72, 0.34, -1.2 + (i / 2) * 0.72), Color("6e6a62"), Vector3.ONE, 10)
	Props.cyl(g, 0.4, 0.9, Vector3(-3.4, 0.45, -2.0), Color("6a5a30"), Vector3.ZERO, 10)   # zeytinyağı küpü
	Props.set_pattern(Props.solid(g, Vector3(24, 0.4, 20), Vector3(0, -0.2, 2.0), Color.WHITE), Color("7a6a50"), "cobble")
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
