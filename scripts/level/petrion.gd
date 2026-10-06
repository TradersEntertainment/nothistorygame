class_name Petrion
extends Node3D
## Petrion mahallesi, 29 Mayıs 1453 akşamı (Bölüm 39o): Haliç surunun deniz kapısından içeri uzanan dar cadde.
## Teslim olan mahalle: evler sağlam (yanık yok), kapılar kapalı. Cadde -z yönünde (kapı z +4, uçta yeniçeri sırası).
##   · İki yanda sekizer ev (sol x < 0, sağ x > 0), her birinin kapısı caddeye bakar. Listedeki altı ev işaretleriyle:
##     mavi kapı ve oyma balık, kuyunun karşısı, asmalı avlu ve iki küp, ikon nişi (kandili sönmüş), kırık kepenkli
##     kırmızı pencere, kilisenin yanındaki cumbalı ev (yanacak ev: üst kat odası, cumba, pencere).
##   · Solda kilise (kapı kanatları kapalı, kırılabilir), caddede kuyu, ortada caddeyi kesen moloz yığını (sağda dar geçit;
##     üstünden tırmanılır), sağdaki ilk dört ev tek katlı ve düz damlı (damdan kestirme).

const HALF := 4.5
const HOUSE_L := 8.0
const ROWS := 8
const GATE_Z := 4.0
const END_Z := -66.0
const CHURCH_Z := -46.0
const WELL := Vector3(2.9, 0.0, -18.0)
const RUBBLE_Z := -26.0
const FIRE_HOUSE := Vector3(-HALF, 0.0, -34.0)     # cephenin ortası (sol 4)
const ROOM_Y := 3.0                                # yanan evin üst kat döşemesi
const FIRE_IDX := 4                                # sol 4: listedeki 6. ev

## Kapılar: [id, konum (kapının önü, cadde), taraf (-1 sol, 1 sağ)]; listedekiler LISTED (sırayla ipucu 1..6)
var doors: Array = []
const LISTED := [9, 2, 12, 14, 7, 4]      # ipucu 1..6 → kapı indisi (0..7 sol, 8..15 sağ)
var church_l: Node3D
var church_r: Node3D
var door_crack: Array[Node3D] = []
var lights: Array = []
var _t := 0.0
## Caddede yürünmez yerler (x, z): iki cephe, moloz yığını (sağdaki dar geçit açık), kuyu, uçtaki ateş, cumbalı evin
## konsolları, asmalı avlunun küpleri. Sahne betiğiyle yürütülenler (yeniçeri, yağmacılar) street_path ile dolanır.
var nav: Array[Rect2] = []
## Tek harita: Haliç, karşı kıyı ve şehrin geri kalanı World1453'ten gelir (kapının ötesindeki boyalı Haliç kalkar)
var in_world := true
var world: SiegeField


func _ready() -> void:
	_ground()
	for sx: float in [-1.0, 1.0]:
		nav.append(Rect2(HALF if sx > 0.0 else -HALF - 3.0, END_Z - 2.0, 3.0, GATE_Z - END_Z + 4.0))
	for side: float in [-1.0, 1.0]:
		for i in ROWS:
			var idx := i if side < 0.0 else ROWS + i
			if side < 0.0 and (i == 5 or i == 6):
				continue          # kilise
			_house(idx, side, i)
	_church()
	_gate()
	_well()
	_rubble()
	_far_end()
	_skyline()
	if in_world:
		world = World1453.build(self, "petrion", [Rect2(-HALF - 16.0, END_Z - 6.0, HALF * 2.0 + 32.0, GATE_Z - END_Z + 9.0)], true)


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


func door_pos(idx: int) -> Vector3:
	var side := -1.0 if idx < ROWS else 1.0
	var i := idx % ROWS
	return Vector3(side * (HALF + 0.05), 0.0, -2.0 - i * HOUSE_L)


## Caddede from→to yürüyüş yolu (son nokta to): molozun dar geçidinden, kuyunun, ateşin, küplerin çevresinden
func street_path(from: Vector3, to: Vector3) -> Array[Vector3]:
	return RectNav.path(from, to, nav, 0.35)


## Kapının yanında nöbet yeri: kapının bir yanı (önce gate tarafı), küpe, konsola denk gelmeyen ilk yer
func guard_spot(idx: int) -> Vector3:
	var d := door_pos(idx)
	var s := -signf(d.x)
	for off: Vector2 in [Vector2(0.7, 1.2), Vector2(0.7, -1.2), Vector2(1.4, 1.2), Vector2(1.4, -1.2)]:
		var q := d + Vector3(s * off.x, 0.0, off.y)
		if not RectNav.inside(q, nav, 0.4):
			return q
	return d + Vector3(s * 1.4, 0.0, 0.0)


func _ground() -> void:
	Props.set_pattern(Props.solid(self, Vector3(HALF * 2.0 + 0.2, 0.4, GATE_Z - END_Z + 6.0), Vector3(0, -0.2, (GATE_Z + END_Z) * 0.5), Color.WHITE),
		Color("8a7c62"), "cobble")
	# Cadde dışı: görünmez sınır yok, evler gövdeleriyle kapatır; caddenin iki ucunda duvar


func _house(idx: int, side: float, i: int) -> void:
	var z := -2.0 - i * HOUSE_L
	var one_story := side > 0.0 and i < 4
	var h := 3.2 if one_story else 6.4
	var depth := 7.0
	var c: Color = [Color("d8c8a8"), Color("c8b898"), Color("e0d0b0"), Color("bfae90")][(idx * 3) % 4]
	if idx == FIRE_IDX:
		# Yanacak ev oyuk: alt kat dolu, üst katta oda (cumba ve pencere açıklıklı)
		Props.set_pattern(Props.solid(self, Vector3(depth, ROOM_Y, HOUSE_L - 0.15), Vector3(side * (HALF + depth * 0.5), ROOM_Y * 0.5, z), Color.WHITE), c, "plaster")
		var up := h - ROOM_Y
		var cy := ROOM_Y + up * 0.5
		Props.set_pattern(Props.solid(self, Vector3(0.2, up, HOUSE_L - 0.15), Vector3(side * (HALF + depth - 0.1), cy, z), Color.WHITE), c, "plaster")
		for sz: float in [-1.0, 1.0]:
			Props.set_pattern(Props.solid(self, Vector3(depth, up, 0.2), Vector3(side * (HALF + depth * 0.5), cy, z + sz * (HOUSE_L * 0.5 - 0.2)), Color.WHITE), c, "plaster")
		Props.set_pattern(Props.solid(self, Vector3(depth, 0.2, HOUSE_L - 0.15), Vector3(side * (HALF + depth * 0.5), h - 0.1, z), Color.WHITE), c, "plaster")
		# Ön duvar: cumba açıklığı (z+0.5..z+2.7, y 3..5.6) ve indirme penceresi (z-2.5..-1.5, y 3.5..4.7) hariç parçalar
		var fx := side * (HALF + 0.1)
		for seg: Array in [[z - 3.85, z - 2.5, ROOM_Y, h], [z - 1.5, z + 0.5, ROOM_Y, h], [z + 2.7, z + 3.85, ROOM_Y, h],
				[z - 2.5, z - 1.5, ROOM_Y, ROOM_Y + 0.5], [z - 2.5, z - 1.5, ROOM_Y + 1.7, h], [z + 0.5, z + 2.7, ROOM_Y + 2.6, h]]:
			var zz: float = (seg[0] + seg[1]) * 0.5
			var hh: float = seg[3] - seg[2]
			Props.set_pattern(Props.solid(self, Vector3(0.2, hh, seg[1] - seg[0]), Vector3(fx, seg[2] + hh * 0.5, zz), Color.WHITE), c, "plaster")
	else:
		var body := Props.solid(self, Vector3(depth, h, HOUSE_L - 0.15), Vector3(side * (HALF + depth * 0.5), h * 0.5, z), Color.WHITE)
		Props.set_pattern(body, c, "plaster")
	if not one_story:
		# Kiremit çatı (iki yana eğimli, kırmızı-kahve)
		for k in 2:
			Props.box(self, Vector3(depth * 0.56, 0.12, HOUSE_L), Vector3(side * (HALF + depth * (0.27 + k * 0.46)), h + 0.6, z), Color("9a4a32"),
				Vector3(0, 0, (18.0 if k == 0 else -18.0) * side))
	else:
		Props.box(self, Vector3(depth, 0.2, HOUSE_L), Vector3(side * (HALF + depth * 0.5), h + 0.1, z), Color("a89878"))      # düz dam
	# Kapı (kapalı, ahşap) ve pencereler
	var dp := Vector3(side * (HALF + 0.02), 1.15, z)
	var door_col := Color("2f5fa8") if idx == LISTED[0] else Color("5a3e26")
	var door := Props.box(self, Vector3(0.12, 2.3, 1.3), dp, door_col)
	doors.append([idx, door_pos(idx), side, door])
	for w in (0 if idx == FIRE_IDX else 2):
		var wz := z + (-2.4 if w == 0 else 2.4)
		var red := idx == LISTED[4]
		Props.box(self, Vector3(0.08, 1.0, 0.8), Vector3(side * (HALF + 0.03), 1.6 if one_story else 4.4, wz), Color("8a2a24") if red else Color("2a2420"))
		if red and w == 0:
			Props.box(self, Vector3(0.1, 1.0, 0.36), Vector3(side * (HALF + 0.2), 4.4, wz + 0.5), Color("5a3e26"), Vector3(0, side * 35.0, -12.0))      # kırık kepenk
	# İşaretler
	if idx == LISTED[0]:
		Props.box(self, Vector3(0.08, 0.3, 0.8), Vector3(side * (HALF + 0.06), 2.7, z), Color("c8b898"))
		Props.ball(self, 0.14, Vector3(side * (HALF + 0.1), 2.7, z), Color("4a6a8a"), Vector3(0.6, 0.6, 2.2), 6)       # oyma balık
	if idx == LISTED[2]:
		# Asmalı avlu: kapının yanında kafes ve asma, iki küp
		for k in 2:
			Props.cyl(self, 0.32, 0.8, Vector3(side * (HALF - 0.6), 0.4, z + 1.6 + k * 0.8), Color("a8683a"), Vector3.ZERO, 10, 0.75)
		nav.append(Rect2(side * (HALF - 0.6) - 0.32, z + 1.28, 0.64, 1.44))
		Props.box(self, Vector3(0.8, 0.06, 3.0), Vector3(side * (HALF - 0.4), 2.6, z), Color("5a3e26"))
		for k in 6:
			Props.ball(self, 0.3, Vector3(side * (HALF - 0.4 + randf_range(-0.2, 0.2)), 2.7, z - 1.2 + k * 0.5), Color("4a7a3a"), Vector3(1.0, 0.6, 1.0), 6)
	if idx == LISTED[3]:
		# İkon nişi, kandili sönmüş
		Props.box(self, Vector3(0.1, 0.7, 0.5), Vector3(side * (HALF + 0.03), 2.9, z), Color("3a2a1a"))
		Props.box(self, Vector3(0.06, 0.5, 0.36), Vector3(side * (HALF + 0.08), 2.9, z), Color("c8a040"))
		Props.cyl(self, 0.06, 0.1, Vector3(side * (HALF + 0.25), 2.45, z), Color("6a6a6a"), Vector3.ZERO, 6)
	if idx == FIRE_IDX:
		_fire_house(side, z, h)


## Yanacak ev: üst kat odası (döşeme y 3, iki oda), caddeye taşan cumba (tırmanılır, girişi açık) ve ön pencere
var fire_room := Vector3.ZERO
var bay_top := Vector3.ZERO
var lower_window := Vector3.ZERO


func _fire_house(side: float, z: float, h: float) -> void:
	# İç oda (gövdeyi oyarak değil: içine ikinci bir oda kutusu; döşeme, iki duvar ve tavan)
	var cx := side * (HALF + 3.2)
	fire_room = Vector3(cx, ROOM_Y, z)
	Props.set_pattern(Props.solid(self, Vector3(4.6, 0.2, 6.0), Vector3(cx, ROOM_Y - 0.08, z), Color.WHITE), Color("6a4a2c"), "wood")
	# Cumba: cepheden 1,2 m taşan kutu (y 2.6–5.4), önü açık; altında taş konsollar (tutunulur)
	bay_top = Vector3(side * (HALF - 1.2), ROOM_Y, z + 1.6)
	var bay := Props.solid(self, Vector3(1.2, 0.2, 2.2), Vector3(side * (HALF - 0.6), ROOM_Y - 0.1, z + 1.6), Color.WHITE)
	Props.set_pattern(bay, Color("6a4a2c"), "wood")
	for k in 2:
		Props.make_solid(Props.box(self, Vector3(1.2, 2.6, 0.18), Vector3(side * (HALF - 0.6), ROOM_Y + 1.3, z + 0.5 + k * 2.2), Color("8a6a4a")))
	Props.box(self, Vector3(1.2, 0.18, 2.4), Vector3(side * (HALF - 0.6), ROOM_Y + 2.6, z + 1.6), Color("7a5a3a"))
	for k in 3:
		Props.make_solid(Props.box(self, Vector3(1.0, 0.3, 0.3), Vector3(side * (HALF - 0.5), 1.4 + k * 0.55, z + 1.6), Color("b8a888")))   # konsollar
	nav.append(Rect2(side * (HALF - 0.5) - 0.5, z + 1.45, 1.0, 0.3))
	# Cumbadan odaya geçit: gövdede açıklık yerine oda gövdenin dışında kalsın diye cephe kutusu bu evde iki parça
	lower_window = Vector3(side * (HALF + 0.3), ROOM_Y, z - 2.0)
	Props.make_solid(Props.cyl(self, 0.06, 1.2, Vector3(side * (HALF + 0.1), ROOM_Y + 1.1, z - 2.0), Color("5a3e26"), Vector3(90, 0, 0), 6))   # pencere direği


func _church() -> void:
	var z := CHURCH_Z
	var body := Props.solid(self, Vector3(12.0, 9.0, 15.0), Vector3(-(HALF + 6.0), 4.5, z), Color.WHITE)
	Props.set_pattern(body, Color("c8a888"), "brick")
	Props.cyl(self, 3.0, 2.4, Vector3(-(HALF + 6.0), 10.2, z), Color("8a8a90"), Vector3.ZERO, 14, 0.4)
	Props.ball(self, 3.0, Vector3(-(HALF + 6.0), 11.0, z), Color("8a8a90"), Vector3(1.0, 0.6, 1.0), 14)
	Props.box(self, Vector3(0.1, 0.9, 0.08), Vector3(-(HALF + 6.0), 13.2, z), Color("c8a040"))
	Props.box(self, Vector3(0.1, 0.08, 0.5), Vector3(-(HALF + 6.0), 13.4, z), Color("c8a040"))
	# Kapı: iki kanat (kapalı), kemer
	Props.box(self, Vector3(0.3, 0.6, 3.0), Vector3(-(HALF + 0.05), 3.6, z), Color("a88868"))
	church_l = Node3D.new()
	church_l.position = Vector3(-(HALF + 0.1), 0.0, z - 1.25)
	add_child(church_l)
	Props.make_solid(Props.box(church_l, Vector3(0.14, 3.2, 1.25), Vector3(0, 1.6, 0.625), Color("6a4a2c")))
	church_r = Node3D.new()
	church_r.position = Vector3(-(HALF + 0.1), 0.0, z + 1.25)
	add_child(church_r)
	Props.make_solid(Props.box(church_r, Vector3(0.14, 3.2, 1.25), Vector3(0, 1.6, -0.625), Color("5a3e26")))
	lights.append(Night.torch(self, Vector3(-(HALF - 0.4), 0.0, z - 2.4), 2.2))


## Kilise kapısında yarık: 0 sağlam … 3 kırık
func set_door_damage(stage: int) -> void:
	while door_crack.size() < stage:
		var k := door_crack.size()
		var cr := Props.box(self, Vector3(0.16, 0.9 - k * 0.1, 0.12), Vector3(-(HALF + 0.12), 1.4 + k * 0.5, CHURCH_Z + randf_range(-0.5, 0.5)),
			Color("1a1410"), Vector3(0, 0, 20.0 * (k - 1)))
		door_crack.append(cr)
	if stage >= 3:
		var tw := create_tween().set_parallel()
		tw.tween_property(church_l, "rotation:y", deg_to_rad(-80.0), 0.5)
		tw.tween_property(church_r, "rotation:y", deg_to_rad(80.0), 0.5)


func _gate() -> void:
	# Haliç surunun iç yüzü ve açık deniz kapısı (caddenin başı)
	var c := Color("cdbd9e")
	# Tek haritada surun boşluğu (40 m'lik parça) kapansın diye kanatlar uzar
	var wing := 18.0 if in_world else 14.0
	for sx: float in [-1.0, 1.0]:
		Props.set_pattern(Props.solid(self, Vector3(wing, 9.6, 3.0), Vector3(sx * (2.0 + wing * 0.5), 4.8, GATE_Z + 1.5), Color.WHITE), c, "ashlar")
	Props.set_pattern(Props.solid(self, Vector3(4.0, 5.0, 3.0), Vector3(0, 7.1, GATE_Z + 1.5), Color.WHITE), c, "ashlar")
	if not in_world:
		Props.box(self, Vector3(4.0, 4.6, 0.1), Vector3(0, 2.3, GATE_Z + 3.05), Color("4a6a8a"))       # kapının ötesi: Haliç
	for sx: float in [-1.0, 1.0]:
		Props.box(self, Vector3(1.8, 4.0, 0.12), Vector3(sx * 2.6, 2.0, GATE_Z + 0.6), Color("5a3e26"), Vector3(0, sx * -70.0, 0))
	# Kapıdan kıyıya çıkılır (her yer yürünür)
	lights.append(Night.torch(self, Vector3(-2.4, 0.0, GATE_Z - 0.4), 2.2))
	lights.append(Night.torch(self, Vector3(2.4, 0.0, GATE_Z - 0.4), 2.2))


func _well() -> void:
	Props.make_solid(Props.cyl(self, 0.8, 0.9, WELL + Vector3(0, 0.45, 0), Color("a89878"), Vector3.ZERO, 12))
	nav.append(Rect2(WELL.x - 0.85, WELL.z - 0.85, 1.7, 1.7))
	Props.cyl(self, 0.65, 0.05, WELL + Vector3(0, 0.88, 0), Color("1a2430"), Vector3.ZERO, 12)
	for sx: float in [-0.7, 0.7]:
		Props.cyl(self, 0.05, 1.6, WELL + Vector3(sx, 1.6, 0), Color("5a3e26"), Vector3.ZERO, 5)
	Props.cyl(self, 0.04, 1.5, WELL + Vector3(0, 2.4, 0), Color("5a3e26"), Vector3(0, 0, 90), 5)


## Caddeyi kesen moloz (yıkık bir duvar): sağda dar geçit; üstünden tırmanılarak kısa yoldan geçilir
func _rubble() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3906
	var x1 := -HALF
	for k in 7:
		var x := -HALF + 0.6 + k * 1.0
		var h := rng.randf_range(1.2, 1.9)
		var zj := rng.randf_range(-0.3, 0.3)
		var rot := Vector3(0, rng.randf_range(-12, 12), rng.randf_range(-6, 6))
		var b := Props.solid(self, Vector3(1.1, h, 1.6), Vector3(x, h * 0.5, RUBBLE_Z + zj), Color.WHITE, rot)
		Props.set_pattern(b, Color("a89878").darkened(rng.randf_range(0.0, 0.2)), "ashlar")
		# Döndürülmüş taşın caddedeki izi (sağ ucu dar geçidin sınırı) + eğikliğin üstte taşırdığı pay
		var ry := deg_to_rad(absf(rot.y))
		x1 = maxf(x1, x + 0.55 * cos(ry) + 0.8 * sin(ry) + h * 0.5 * sin(deg_to_rad(absf(rot.z))))
	for k in 8:
		Props.ball(self, rng.randf_range(0.2, 0.4), Vector3(rng.randf_range(-HALF, 2.0), 0.15, RUBBLE_Z + rng.randf_range(-1.6, 1.6)), Color("8a7a62"), Vector3(1.2, 0.6, 1.0), 6)
	nav.append(Rect2(-HALF, RUBBLE_Z - 2.0, maxf(x1, 2.4) + HALF, 4.0))


func _far_end() -> void:
	# Caddenin sonu açık: yeniçeri sırasının arasından dünyanın şehrine yürünür
	for k in 5:
		var s := Soldier.new(Color("b3262d"), "stand", "bork")
		s.position = Vector3(-3.2 + k * 1.6, 0.0, END_Z + 0.8)
		add_child(s)
		s.equip("spear")
	lights.append(Night.campfire(self, Vector3(0.0, 0.0, END_Z + 3.2), 0.8))
	nav.append(Rect2(-0.55, END_Z + 2.65, 1.1, 1.1))


func _skyline() -> void:
	# Uzakta başka semtlerde yangın pusu (ayrıntısız): turuncu ışıklı duman
	for k in 3:
		var p := Vector3(-60.0 + k * 50.0, 6.0, -140.0 - k * 20.0)
		Vfx.smolder(self, p, 3.0, false)
		var l := OmniLight3D.new()
		l.position = p + Vector3(0, 4, 0)
		l.light_color = Color("ff7a30")
		l.light_energy = 3.0
		l.omni_range = 60.0
		add_child(l)
