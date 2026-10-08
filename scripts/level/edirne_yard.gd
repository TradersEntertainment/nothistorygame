class_name EdirneYard
extends Node3D
## Bölüm 34o (Ocak 1453): Urban'ın Edirne'deki döküm yeri, karlı Tunca kıyısı. docs/OTTOMAN_NEW_A.md §2.2
##   Döküm çukuru (4 m), içinde kil gömlekli namlu; üstte A çatısı, iki uçta çıkrık (tambur, el çarkı, mandal).
##   Batıda gülle oluğu (taşçı tezgâhı → çember kalıp), dibinden işçilerin ateşine inen karlı yamaç.
##   Doğuda kızak yamacı ve dipte buz tutmuş birikinti. Önde atış sahası, 380 m'de kırmızı bezli direk.
##   Arkada Tunca ve Edirne: Üç Şerefeli'nin dört minaresi, kubbeler, saray duvarı, damlar. Hafif kar yağar.
## Dünya: +z atış yönü; güvenlik ipi z = ROPE_Z boyunca (arkası güvenli).

const PIT_HX := 2.2
const PIT_HZ := 5.0
const PIT_Y := -3.6
const BARREL_R := 0.62
const BARREL_LEN := 7.2
const BEAM_Y := 6.5
const BAND_Z := 2.4
const WIND_REAR := Vector3(3.6, 0.0, -6.8)    # Tolga'nın çıkrığı
const WIND_FRONT := Vector3(3.6, 0.0, 6.8)    # ustabaşının çıkrığı
const LIFT := 3.2                              # namlunun yükseleceği boy
const SLED_Y := 0.32                           # kızak kirişlerinin üstü
const ROPE_Z := -9.0
const ROPE_X0 := -16.0
const ROPE_X1 := 24.0
const CHUTE_TOP := Vector3(-26.0, 0.0, -21.0)
const CHUTE_BOT := Vector3(-26.0, 0.0, -1.5)
const RING := Vector3(-26.0, 0.0, 0.2)         # çember kalıp (takozun hemen önü)
const CART := Vector3(-29.0, 0.0, 1.0)
const REJECT := Vector3(-22.6, 0.0, 1.4)
const FIRE := Vector3(-26.0, 0.0, 23.0)
const SLED_TOP := Vector3(28.0, 0.0, 26.0)
const SLED_BOT := Vector3(28.0, 0.0, 56.0)
const POND := Vector3(28.0, 0.0, 63.0)
const POND_R := 6.0
const TARGET := Vector3(0.0, 0.0, 380.0)
const FURNACE := Vector3(13.0, 0.0, -15.0)
const SULTAN_SPOT := Vector3(-5.0, 0.0, -13.0)

const C_SNOW := Color("cdd4dc")
const C_MUD := Color("8a7e70")
const C_WOOD := Color("6a4a2c")
const C_BRONZE := Color("9a7438")
const C_CLAY := Color("9a6a48")
const C_BRICK := Color("8a4a34")

var sun: DirectionalLight3D
var env: WorldEnvironment
var gun: Node3D                     # kök: namlunun ortası (yerel −z namlu ağzı; kök π döner → ağız +z)
var pivot: Node3D
var muzzle: Node3D
var touch_hole: Node3D              # falya (namlunun arka üstü)
var clay: Array[MeshInstance3D] = []
var nicks: Node3D
var chains: Array[MeshInstance3D] = []   # [arka iniş, arka kiriş, arka çıkrık, ön iniş, ön kiriş, ön çıkrık]
var drums: Array[Node3D] = []            # [arka, ön]: el çarkı (dönen)
var pawls: Array[Node3D] = []
var spools: Array[MeshInstance3D] = []   # tamburdaki sarım (kalınlaşır)
var sled: Node3D
var chock: Node3D
var hoist: Node3D
var post: Node3D
var rope_posts: Array[Vector3] = []
var _rope_segs: Array[MeshInstance3D] = []
var deck := false                    # namlu kızağa inince çukurun üstü kalaslarla kapanır
var _snow: GPUParticles3D
var _t := 0.0


static func ground_y(x: float, z: float) -> float:
	# Çukur (dik kenarlı)
	if absf(x) < PIT_HX and absf(z) < PIT_HZ:
		return PIT_Y
	var h := 0.0
	# Uzak sahada hedef tepesi
	h += 10.0 * smoothstep(220.0, 340.0, z) * (1.0 - smoothstep(420.0, 500.0, z))
	# Tunca'ya inen kıyı (arkada)
	h -= 2.2 * smoothstep(-62.0, -82.0, z)
	# Batı: gülle oluğu düzlüğü (+1 m), dibinden ateşe inen yamaç
	var w := smoothstep(-15.0, -20.0, x) * smoothstep(-40.0, -34.0, x)
	if w > 0.0:
		var hz := lerpf(1.0, -2.4, smoothstep(0.0, 22.0, z))
		hz *= 1.0 - smoothstep(-34.0, -40.0, z)
		h += w * hz
	# Doğu: kızak yamacı (tepe z ~ 24, dipte birikinti)
	var e := smoothstep(16.0, 22.0, x) * (1.0 - smoothstep(34.0, 40.0, x))
	if e > 0.0:
		h += e * 6.0 * smoothstep(60.0, 26.0, z) * smoothstep(8.0, 22.0, z)
	# Birikinti: hafif çukur
	var dp := Vector2(x - POND.x, z - POND.z).length()
	h -= 0.35 * (1.0 - smoothstep(POND_R - 1.0, POND_R + 2.0, dp))
	# Hafif dalga (uzakta)
	var far := smoothstep(60.0, 140.0, Vector2(x, z * 0.6).length())
	# Atış hattında dalga yok (gülle hedef tepesinin düz sırtına düşsün)
	far *= 1.0 - smoothstep(180.0, 240.0, z) * (1.0 - smoothstep(40.0, 90.0, absf(x)))
	h += far * 2.2 * sin(x * 0.021 + 1.3) * cos(z * 0.017)
	return h


## Yürünen yüzey: kalaslar kapandıktan sonra çukurun üstü 0
func floor_y(x: float, z: float) -> float:
	if deck and absf(x) < PIT_HX + 0.3 and absf(z) < PIT_HZ + 0.3:
		return 0.0
	return ground_y(x, z)


func _ready() -> void:
	_env()
	_ground()
	_pit()
	_frame()
	_gun()
	_furnaces()
	_chute()
	_sled_hill()
	_range()
	_rope_line()
	_town()
	_trees()
	_snowfall()


func _process(delta: float) -> void:
	_t += delta
	# Güvenlik ipi rüzgârda hafif sallanır
	for i in _rope_segs.size():
		var a: Vector3 = rope_posts[i] + Vector3(0, 0.95, 0)
		var b: Vector3 = rope_posts[i + 1] + Vector3(0, 0.95, 0)
		var m := (a + b) * 0.5 + Vector3(0, -0.22 + 0.05 * sin(_t * 1.7 + i), 0.06 * sin(_t * 1.1 + i * 0.7))
		Bogaz.rope(_rope_segs[i], a, m) if i % 2 == 0 else Bogaz.rope(_rope_segs[i], a, b)
	var cam := get_viewport().get_camera_3d()
	if cam and _snow:
		_snow.global_position = cam.global_position + Vector3(0, 9.0, 0)


func _env() -> void:
	sun = Night.environment(self, 0.0)
	sun.rotation_degrees = Vector3(-24, 205, 0)
	sun.light_color = Color("fff0e0")
	sun.light_energy = 0.75
	# Gündüz: ay ve yıldızlar yerine güneş diski
	for c in get_children():
		if c is WorldEnvironment:
			env = c
		elif c is SkyBody or (c is MultiMeshInstance3D and c.get_script() != null):
			c.queue_free()
	SkyBody.attach(self, sun, false)
	if env:
		var e := env.environment
		var sm := e.sky.sky_material as ProceduralSkyMaterial
		if sm:
			sm.sky_top_color = Color("8a9cb4")
			sm.sky_horizon_color = Color("dde2e8")
			sm.ground_horizon_color = Color("c8ccd0")
			sm.ground_bottom_color = Color("a8acb0")
		e.ambient_light_color = Color("b8c0cc")
		e.ambient_light_energy = 0.7
		e.tonemap_exposure = 0.95          # gündüz (gece ortamının 1.1 pozlaması karı bembeyaz yakıyordu)
		e.fog_enabled = true
		e.fog_light_color = Color("d8dee6")
		e.fog_density = 0.0035


## İkindi: güneş alçalır, ışık turuncuya döner
func make_afternoon() -> void:
	sun.rotation_degrees = Vector3(-12, 235, 0)
	sun.light_color = Color("ffd8b0")
	sun.light_energy = 0.75
	if env:
		env.environment.fog_light_color = Color("e0d4c8")


# ---------------------------------------------------------------- zemin

func _snow_col(x: float, z: float, y: float, steep: float) -> Color:
	var c := C_SNOW.darkened(0.05 * (0.5 + 0.5 * sin(x * 0.13 + z * 0.07)))
	# Karın ince olduğu yerlerde kuru ot ve toprak lekeleri; rüzgârın süpürdüğü sırtlar
	var patch := 0.5 + 0.5 * sin(x * 0.071 + 1.7) * cos(z * 0.053 - 0.4) + 0.25 * sin(x * 0.23 + z * 0.19)
	c = c.lerp(Color("9a907c"), clampf((patch - 0.82) * 2.2, 0.0, 0.45))
	c = c.lerp(Color("e4e8ee"), clampf(steep * 2.0, 0.0, 0.3))
	# Avluda çiğnenmiş çamurlu kar
	var trod := (1.0 - smoothstep(9.0, 16.0, Vector2(x, z * 0.8).length()))
	c = c.lerp(C_MUD, trod * 0.55)
	if absf(x) < PIT_HX + 0.6 and absf(z) < PIT_HZ + 0.6:
		c = Color("6a5040")
	# Buz
	if Vector2(x - POND.x, z - POND.z).length() < POND_R:
		c = Color("b8d4e4")
	return c.darkened(clampf(steep * 0.4, 0.0, 0.2))


func _ground() -> void:
	var hf := func(x: float, z: float) -> float:
		return ground_y(x, z)
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		return _snow_col(x, z, y, steep)
	# Yakın alan: 1 m ızgara, çarpışma aynı ızgaradan
	var near := LowPoly.terrain(-60.0, 60.0, -70.0, 100.0, 120, 170, hf, cf)
	near.material_override = LowPoly.vertex_color_material()
	add_child(near)
	near.set_meta("solid_terrain", true)    # aynı ızgaradan yükseklik gövdesi var (ikinci üçgen gövde gerekmez)
	_height_body(-60.0, 60.0, -70.0, 100.0, 1.0)
	# Uzak alan: dört şerit (kaba)
	for r: Array in [[-600.0, -60.0, -400.0, 600.0, 54, 100], [60.0, 600.0, -400.0, 600.0, 54, 100],
			[-60.0, 60.0, 100.0, 600.0, 24, 100], [-60.0, 60.0, -400.0, -70.0, 12, 33]]:
		var far := LowPoly.terrain(r[0], r[1], r[2], r[3], r[4], r[5], hf, cf)
		far.material_override = LowPoly.vertex_color_material()
		add_child(far)
		# Çarpışma görünen yüzeyin kendisi (eskiden atış sahasında 5 m'lik ayrı yükseklik haritası vardı, görünen 10 m'lik
		# ızgarayla yarım metreye varan fark: yürüyen havada ya da toprağın içinde)
		LowPoly.solid(far)


func _height_body(x0: float, x1: float, z0: float, z1: float, step: float) -> void:
	var nx := int(round((x1 - x0) / step)) + 1
	var nz := int(round((z1 - z0) / step)) + 1
	var data := PackedFloat32Array()
	data.resize(nx * nz)
	for j in nz:
		for i in nx:
			data[j * nx + i] = ground_y(x0 + i * step, z0 + j * step) / step
	var hm := HeightMapShape3D.new()
	hm.map_width = nx
	hm.map_depth = nz
	hm.map_data = data
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = hm
	cs.scale = Vector3.ONE * step
	body.position = Vector3((x0 + x1) * 0.5, 0, (z0 + z1) * 0.5)
	body.add_child(cs)
	add_child(body)


# ---------------------------------------------------------------- çukur, çatı, çıkrıklar

func _pit() -> void:
	# Kenarları kütükle desteklenmiş (kazık + yatay kalaslar); taban çamur
	Props.box(self, Vector3(PIT_HX * 2.0, 0.1, PIT_HZ * 2.0), Vector3(0, PIT_Y + 0.05, 0), Color("4a3a2c"))
	for side in 4:
		var along_x := side < 2
		var s := -1.0 if side % 2 == 0 else 1.0
		var len := PIT_HX * 2.0 if along_x else PIT_HZ * 2.0
		var n := 4 if along_x else 8
		for k in 4:
			var y := PIT_Y + 0.5 + k * 0.95
			var pos := Vector3(0, y, s * (PIT_HZ - 0.08)) if along_x else Vector3(s * (PIT_HX - 0.08), y, 0)
			var sz := Vector3(len, 0.32, 0.16) if along_x else Vector3(0.16, 0.32, len)
			Props.box(self, sz, pos, C_WOOD.darkened(0.08 * (k % 2)))
		for k in n + 1:
			var t := -len * 0.5 + len * k / n
			var pos := Vector3(t, PIT_Y * 0.5, s * (PIT_HZ - 0.2)) if along_x else Vector3(s * (PIT_HX - 0.2), PIT_Y * 0.5, t)
			Props.cyl(self, 0.12, -PIT_Y + 0.4, pos, C_WOOD.darkened(0.2), Vector3.ZERO, 6)
	# Çukurun ağzında kalas çerçeve (katı, üstü zemin hizasında): arazi 1 m'lik ızgarada çukura doğru eğimleniyordu,
	# kenarda duran oyuncu ve işçiler yarı boşlukta kalıyordu
	var rim := 1.0
	for sz: float in [-1.0, 1.0]:
		Props.make_solid(Props.box(self, Vector3((PIT_HX + rim) * 2.0, 0.14, rim), Vector3(0, -0.05, sz * (PIT_HZ + rim * 0.5)), C_WOOD.darkened(0.05)))
	for sx: float in [-1.0, 1.0]:
		Props.make_solid(Props.box(self, Vector3(rim, 0.14, PIT_HZ * 2.0), Vector3(sx * (PIT_HX + rim * 0.5), -0.05, 0), C_WOOD.darkened(0.05)))
	# Çukur kenarında kazılmış toprak setleri
	for sx: float in [-1.0, 1.0]:
		Props.ball(self, 1.6, Vector3(sx * (PIT_HX + 2.6), -0.6, 0), Color("7a6656"), Vector3(1.0, 0.5, 3.2), 8)


func _frame() -> void:
	# A çatısı: iki uçta A ayakları, üstte kalın kiriş
	for sz: float in [-1.0, 1.0]:
		var z := sz * (PIT_HZ + 0.6)
		for sx: float in [-1.0, 1.0]:
			var foot := Vector3(sx * 3.4, 0.0, z)
			var top := Vector3(0, BEAM_Y, z)
			var leg := Props.cyl(self, 0.18, foot.distance_to(top), (foot + top) * 0.5, C_WOOD, Vector3.ZERO, 8)
			leg.look_at_from_position((foot + top) * 0.5, top, Vector3.FORWARD)
			leg.rotate_object_local(Vector3.RIGHT, PI * 0.5)
			Props.make_solid(leg)       # A ayağının içinden yürünmesin
			# Ayak dibinde kar yığıntısı
			Props.ball(self, 0.5, foot + Vector3(0, -0.15, 0), C_SNOW, Vector3(1.2, 0.5, 1.2), 7)
		Props.box(self, Vector3(4.2, 0.22, 0.22), Vector3(0, 2.6, z), C_WOOD.darkened(0.1))
	Props.box(self, Vector3(0.42, 0.46, PIT_HZ * 2.0 + 2.0), Vector3(0, BEAM_Y + 0.1, 0), C_WOOD.darkened(0.05))
	# Makaralar (kirişin altında ve uçlarda)
	for z: float in [-BAND_Z, BAND_Z, -(PIT_HZ + 0.6), PIT_HZ + 0.6]:
		Props.cyl(self, 0.24, 0.16, Vector3(0, BEAM_Y - 0.25, z), Color("4a3a2a"), Vector3(0, 0, 90), 10)
	# Çıkrıklar: ayaklı sehpa, tambur (sarım), dört kollu el çarkı, mandal dişlisi
	for wp: Vector3 in [WIND_REAR, WIND_FRONT]:
		var w := Node3D.new()
		add_child(w)
		w.position = wp
		for sx: float in [-0.9, 0.9]:
			Props.make_solid(Props.box(w, Vector3(0.2, 1.3, 0.2), Vector3(sx, 0.65, 0), C_WOOD))
			Props.ball(w, 0.35, Vector3(sx, -0.1, 0), C_SNOW, Vector3(1.2, 0.5, 1.2), 7)
		Props.make_solid(Props.cyl(w, 0.32, 1.6, Vector3(0, 1.05, 0), C_WOOD.lightened(0.1), Vector3(0, 0, 90), 12))
		var spool := Props.cyl(w, 0.36, 1.2, Vector3(0, 1.05, 0), Color("5a5a5e"), Vector3(0, 0, 90), 12)
		spools.append(spool)
		var hub := Node3D.new()
		hub.position = Vector3(1.05, 1.05, 0)
		w.add_child(hub)
		Props.cyl(hub, 0.12, 0.25, Vector3.ZERO, C_WOOD.darkened(0.2), Vector3(0, 0, 90), 8)
		for k in 4:
			var spoke := Props.box(hub, Vector3(0.08, 1.5, 0.08), Vector3.ZERO, C_WOOD.lightened(0.05))
			spoke.rotation.x = k * PI * 0.25
		drums.append(hub)
		# Mandal dişlisi ve mandal
		Props.cyl(w, 0.42, 0.06, Vector3(-0.95, 1.05, 0), Color("4a4a50"), Vector3(0, 0, 90), 16)
		var pawl := Node3D.new()
		pawl.position = Vector3(-1.05, 1.55, 0.35)
		w.add_child(pawl)
		Props.box(pawl, Vector3(0.06, 0.08, 0.6), Vector3(0, 0, -0.3), Color("3a3a40"))
		pawl.rotation.x = -0.6
		pawls.append(pawl)
	for i in 6:
		chains.append(Bogaz.make_rope(self, Color("4a4a50"), 0.05))


## Zincirleri namlunun kuşaklarına göre yeniden çiz (namlu her kalktığında)
func update_chains() -> void:
	var bands := [gun.to_global(Vector3(0, BARREL_R, BAND_Z)), gun.to_global(Vector3(0, BARREL_R, -BAND_Z))]
	# gun π döndüğü için yerel +z dünyada −z: arka kuşak bands[0]
	for s in 2:
		var zs := -1.0 if s == 0 else 1.0
		var band: Vector3 = bands[s]
		var pul := Vector3(0, BEAM_Y - 0.3, zs * BAND_Z)
		var end := Vector3(0, BEAM_Y - 0.3, zs * (PIT_HZ + 0.6))
		var wp: Vector3 = (WIND_REAR if s == 0 else WIND_FRONT) + Vector3(0, 1.05, 0)
		Bogaz.rope(chains[s * 3], band, pul)
		Bogaz.rope(chains[s * 3 + 1], pul, end)
		Bogaz.rope(chains[s * 3 + 2], end, wp)


# ---------------------------------------------------------------- namlu

func _gun() -> void:
	gun = Node3D.new()
	gun.name = "Shahi"
	add_child(gun)
	gun.position = Vector3(0, PIT_Y + 0.1 + BARREL_R, 0)
	pivot = Node3D.new()
	pivot.name = "Pivot"
	gun.add_child(pivot)
	# Namlu (yerel −z ağız): gövde, ağız halkası, kuşaklar, kuyruk
	var body := Props.cyl(pivot, BARREL_R, BARREL_LEN, Vector3.ZERO, C_BRONZE, Vector3(90, 0, 0), 16)
	body.name = "Body"
	Props.cyl(pivot, BARREL_R * 1.18, 0.5, Vector3(0, 0, -BARREL_LEN * 0.5 + 0.25), C_BRONZE.darkened(0.12), Vector3(90, 0, 0), 16)
	Props.cyl(pivot, BARREL_R * 0.62, 0.06, Vector3(0, 0, -BARREL_LEN * 0.5 - 0.02), Color("1a1410"), Vector3(90, 0, 0), 14)
	for z: float in [-BAND_Z, BAND_Z, 0.0]:
		Props.cyl(pivot, BARREL_R * 1.08, 0.18, Vector3(0, 0, z), C_BRONZE.darkened(0.2), Vector3(90, 0, 0), 16)
	Props.ball(pivot, BARREL_R * 0.95, Vector3(0, 0, BARREL_LEN * 0.5), C_BRONZE.darkened(0.1), Vector3(1, 1, 0.5), 12)
	muzzle = Node3D.new()
	muzzle.name = "Muzzle"
	muzzle.position = Vector3(0, 0, -BARREL_LEN * 0.5 - 0.05)
	pivot.add_child(muzzle)
	touch_hole = Node3D.new()
	touch_hole.position = Vector3(0, BARREL_R + 0.02, BARREL_LEN * 0.5 - 0.7)
	pivot.add_child(touch_hole)
	Props.cyl(pivot, 0.05, 0.04, touch_hole.position, Color("1a1410"), Vector3.ZERO, 8)
	nicks = Node3D.new()
	pivot.add_child(nicks)
	gun.rotation.y = PI
	# Kil gömlek: 12 parça (üst yarı ve yanlar), altında tunç
	for i in 12:
		var z := -BARREL_LEN * 0.5 + 0.35 + (i % 6) * (BARREL_LEN - 0.7) / 5.0
		var ang := -0.9 if i < 6 else 0.9
		var chunk := Props.box(pivot, Vector3(0.9, 0.34, 1.25), Vector3(sin(ang) * (BARREL_R + 0.08), cos(ang) * (BARREL_R + 0.08), z),
			C_CLAY.darkened(0.06 * ((i * 7) % 3)), Vector3(0, 0, -rad_to_deg(ang)))
		clay.append(chunk)
	# Üst sırt
	for k in 3:
		var ridge := Props.box(pivot, Vector3(0.5, 0.3, 2.2), Vector3(0, BARREL_R + 0.18, -BARREL_LEN * 0.5 + 1.2 + k * 2.4), C_CLAY.darkened(0.1))
		clay.append(ridge)
	# Kızak: çukurun üstünden sürülecek iki kiriş ve traversler (başta çukurun yanında)
	sled = Node3D.new()
	add_child(sled)
	sled.position = Vector3(-6.5, 0, 0)
	for sx: float in [-0.75, 0.75]:
		Props.box(sled, Vector3(0.34, 0.32, 9.2), Vector3(sx, SLED_Y - 0.16, 0), C_WOOD.darkened(0.1))
	for k in 5:
		Props.cyl(sled, 0.16, 2.2, Vector3(0, 0.1, -3.6 + k * 1.8), C_WOOD.lightened(0.05), Vector3(0, 0, 90), 8)
	update_chains()


## Kil parçasını kopar: parça çukura yuvarlanır, altta tunç parlar ve buhar tüter
func break_clay(i: int) -> void:
	if i < 0 or i >= clay.size() or not is_instance_valid(clay[i]):
		return
	var c := clay[i]
	var gp := c.global_position
	c.reparent(self)
	c.global_position = gp
	var dir := Vector3(randf_range(-1.0, 1.0), 0, randf_range(-0.3, 0.3)).normalized()
	var tw := c.create_tween()
	tw.tween_property(c, "global_position", gp + dir * 0.8 + Vector3(0, 0.3, 0), 0.18)
	tw.tween_property(c, "global_position", Vector3(gp.x + dir.x * 1.4, PIT_Y + 0.2, gp.z + dir.z), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(c, "rotation", c.rotation + Vector3(randf_range(1, 3), 0, randf_range(1, 3)), 0.45)
	tw.tween_property(c, "scale", Vector3(1.0, 0.5, 1.0), 0.2)
	clay[i] = null
	Vfx.dust(self, gp, 0.35)
	Vfx.steam(self, gp + Vector3(0, 0.1, 0))
	Audio.sfx("land_pot", -6.0, 0.7)


## Tunçta çentik: parlak çizik
func add_nick(local_z: float) -> void:
	var n := Props.box(nicks, Vector3(0.05, 0.02, 0.35), Vector3(randf_range(-0.2, 0.2), BARREL_R + 0.005, local_z), Color("ffe8a8"),
		Vector3(0, randf_range(-40, 40), 0), 0.8)
	n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


# ---------------------------------------------------------------- fırınlar, oluk, ateş

func _furnaces() -> void:
	for k in 2:
		var p := FURNACE + Vector3(k * 5.0, 0, 0)
		var f := Props.cyl(self, 1.6, 3.2, p + Vector3(0, 1.6, 0), C_BRICK, Vector3.ZERO, 10, 1.1)
		Props.set_pattern(f, C_BRICK, "brick")
		Props.make_solid(f)
		Props.box(self, Vector3(0.8, 0.9, 0.3), p + Vector3(0, 0.6, 1.5), Color("1a1410"))
		Scenery.smoke_column(self, p + Vector3(0, 3.4, 0))
		# Körük
		Props.make_solid(Props.box(self, Vector3(0.9, 0.3, 1.4), p + Vector3(1.9, 0.4, 0.4), Color("5a3e2a"), Vector3(0, 30, 10)))
	# Kömür yığınları
	for k in 3:
		Props.make_solid(Props.ball(self, 1.1, FURNACE + Vector3(-3.0 + k * 1.2, 0.0, 3.4), Color("2a2626"), Vector3(1.2, 0.6, 1.0), 7))


func _chute() -> void:
	var top := CHUTE_TOP + Vector3(0, ground_y(CHUTE_TOP.x, CHUTE_TOP.z) + 2.6, 0)
	var bot := CHUTE_BOT + Vector3(0, ground_y(CHUTE_BOT.x, CHUTE_BOT.z) + 0.55, 0)
	var len := top.distance_to(bot)
	var pitch := rad_to_deg(atan2(top.y - bot.y, bot.z - top.z))
	var mid := (top + bot) * 0.5
	# Oluk katı (yokuşun altından/içinden geçilmesin)
	Props.make_solid(Props.box(self, Vector3(0.9, 0.08, len), mid, C_WOOD.lightened(0.08), Vector3(-pitch, 0, 0)))
	for sx: float in [-0.45, 0.45]:
		Props.make_solid(Props.box(self, Vector3(0.08, 0.28, len), mid + Vector3(sx, 0.12, 0), C_WOOD, Vector3(-pitch, 0, 0)))
	# Sehpalar
	for k in 5:
		var p := top.lerp(bot, (k + 0.5) / 5.0)
		var gy := ground_y(p.x, p.z)
		for sx: float in [-0.4, 0.4]:
			Props.box(self, Vector3(0.12, p.y - gy, 0.12), Vector3(p.x + sx, (p.y + gy) * 0.5 - 0.05, p.z), C_WOOD.darkened(0.15))
	# Taşçı tezgâhı ve yontulmuş gülleler
	var bench := CHUTE_TOP + Vector3(0, ground_y(CHUTE_TOP.x, CHUTE_TOP.z), -2.0)
	Props.make_solid(Props.box(self, Vector3(2.6, 0.9, 1.4), bench + Vector3(0, 0.45, 0), C_WOOD.darkened(0.1)))
	for k in 4:
		Props.make_solid(Props.ball(self, 0.32, bench + Vector3(-1.6 - (k % 2) * 0.7, 0.32, -0.6 + (k / 2) * 0.7), Color("b8b4aa"), Vector3.ONE, 9))
	Props.make_solid(Props.box(self, Vector3(3.0, 1.1, 2.0), bench + Vector3(3.8, 0.5, -0.6), Color("a8a49a")))    # taşçının (x +1,6) yanında, içinde değil
	# Takoz (ağaç kama) ve çember kalıp: iki dikme arasında demir halka
	chock = Node3D.new()
	add_child(chock)
	chock.position = CHUTE_BOT + Vector3(0, ground_y(CHUTE_BOT.x, CHUTE_BOT.z) + 0.55, 0.55)
	Props.prism(chock, Vector3(0.7, 0.25, 0.3), Vector3(0, 0.12, 0), C_WOOD.darkened(0.25))
	var rp := RING + Vector3(0, ground_y(RING.x, RING.z), 0)
	for sx: float in [-0.75, 0.75]:
		Props.box(self, Vector3(0.12, 1.6, 0.12), rp + Vector3(sx, 0.8, 0.3), C_WOOD)
	Props.ring(self, 0.38, 0.46, rp + Vector3(0, 0.95, 0.3), Color("5a5a60"), Vector3(90, 0, 0))
	# Kabul arabası ve geri yığını
	var cp := CART + Vector3(0, ground_y(CART.x, CART.z), 0)
	Props.make_solid(Props.box(self, Vector3(1.6, 0.5, 2.4), cp + Vector3(0, 0.7, 0), C_WOOD))
	for sz: float in [-0.8, 0.8]:
		for sx: float in [-0.9, 0.9]:
			Props.cyl(self, 0.42, 0.1, cp + Vector3(sx, 0.42, sz), Color("3a2a1c"), Vector3(0, 0, 90), 10)
	for k in 2:
		Props.make_solid(Props.ball(self, 0.3, REJECT + Vector3(-0.4 + k * 0.7, ground_y(REJECT.x, REJECT.z) + 0.28, 0.4 * k), Color("a8a49a"), Vector3.ONE, 8))
	# İşçilerin ateşi (yamaç dibinde)
	var fp := FIRE + Vector3(0, ground_y(FIRE.x, FIRE.z), 0)
	Night.campfire(self, fp, 0.8)
	Props.cyl(self, 0.35, 0.6, fp + Vector3(0.7, 0.3, 0.2), Color("3a3a3e"), Vector3.ZERO, 8)


func chute_top() -> Vector3:
	return CHUTE_TOP + Vector3(0, ground_y(CHUTE_TOP.x, CHUTE_TOP.z) + 2.6 + 0.32, 0)


func chute_bot() -> Vector3:
	return CHUTE_BOT + Vector3(0, ground_y(CHUTE_BOT.x, CHUTE_BOT.z) + 0.55 + 0.32, 0)


# ---------------------------------------------------------------- kızak yamacı, saha, ip

func _sled_hill() -> void:
	# Birikintinin kenarı: buz kırıkları ve sazlar
	for k in 10:
		var a := TAU * k / 10.0
		var p := POND + Vector3(cos(a) * (POND_R + 0.4), 0, sin(a) * (POND_R + 0.4))
		Props.cyl(self, 0.03, 0.8, Vector3(p.x, ground_y(p.x, p.z) + 0.4, p.z), Color("8a7a50"), Vector3(randf_range(-10, 10), 0, randf_range(-10, 10)), 4)


func _range() -> void:
	post = Node3D.new()
	add_child(post)
	post.position = TARGET + Vector3(0, ground_y(TARGET.x, TARGET.z), 0)
	Props.cyl(post, 0.25, 9.0, Vector3(0, 4.5, 0), C_WOOD, Vector3.ZERO, 8)
	Props.box(post, Vector3(3.0, 2.0, 0.06), Vector3(1.6, 7.8, 0), Color("c0202a"))
	# Sahada birkaç çit ve kazık
	for k in 8:
		var p := Vector3(-30.0 + k * 9.0, 0, 90.0 + (k % 3) * 20.0)
		Props.cyl(self, 0.08, 1.2, Vector3(p.x, ground_y(p.x, p.z) + 0.6, p.z), C_WOOD.darkened(0.2), Vector3.ZERO, 6)


func _rope_line() -> void:
	var n := 10
	for k in n + 1:
		var x := lerpf(ROPE_X0, ROPE_X1, float(k) / n)
		var p := Vector3(x, ground_y(x, ROPE_Z), ROPE_Z)
		rope_posts.append(p)
		Props.cyl(self, 0.07, 1.1, p + Vector3(0, 0.55, 0), C_WOOD.darkened(0.15), Vector3.ZERO, 6)
	for k in n:
		_rope_segs.append(Bogaz.make_rope(self, Color("c8b080"), 0.02))


## Makara: üç ayaklı kaldıraç (namlu ağzının üstünde; kızakta duran topa göre)
func build_hoist(at: Vector3) -> void:
	hoist = Node3D.new()
	add_child(hoist)
	hoist.position = at
	for k in 3:
		var a := TAU * k / 3.0 + 0.3
		var foot := Vector3(cos(a) * 1.8, -at.y + ground_y(at.x + cos(a) * 1.8, at.z + sin(a) * 1.8), sin(a) * 1.8)
		var top := Vector3(0, 3.4, 0)
		var leg := Props.cyl(hoist, 0.08, foot.distance_to(top), (foot + top) * 0.5, C_WOOD, Vector3.ZERO, 6)
		leg.look_at_from_position(at + (foot + top) * 0.5, at + top, Vector3.FORWARD)
		leg.rotate_object_local(Vector3.RIGHT, PI * 0.5)
	Props.cyl(hoist, 0.2, 0.12, Vector3(0, 3.3, 0), Color("4a3a2a"), Vector3(0, 0, 90), 10)


# ---------------------------------------------------------------- Edirne, Tunca, ağaçlar, kar

func _town() -> void:
	# Tunca: arkada buzlu kenarlı su
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(1200.0, 34.0)
	w.mesh = pm
	w.position = Vector3(0, -2.0, -96.0)
	w.material_override = CityPanorama.water_mat()
	add_child(w)
	for sz: float in [-1.0, 1.0]:
		var ice := Props.box(self, Vector3(1200.0, 0.05, 5.0), Vector3(0, -1.95, -96.0 + sz * 15.0), Color("d8e6ee"))
		ice.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Tunca kıyısında görünmez sınır: buzlu nehrin içinden (suyun altından) karşıya yürünmez
	var bank := Props.solid(self, Vector3(1200.0, 8.0, 1.0), Vector3(0, 1.0, -79.5), Color.WHITE)
	bank.get_child(0).visible = false
	bank.set_meta("no_climb", true)
	# Üç Şerefeli Cami: kubbe, dört minare (biri üç şerefeli)
	var d := Dressing.new(3401)
	var cami := Vector3(-60.0, 0.0, -230.0)
	d.box(Vector3(46.0, 16.0, 40.0), cami + Vector3(0, 8.0, 0), Color("e0d8c8"))
	d.ball(13.0, cami + Vector3(0, 16.0, 0), Color("6a7480"), Vector3(1.0, 0.75, 1.0), 14)
	for k in 4:
		d.ball(5.0, cami + Vector3(-14.0 + (k % 2) * 28.0, 16.0, -12.0 + (k / 2) * 24.0), Color("6a7480"), Vector3(1.0, 0.7, 1.0), 10)
	var mins := [[Vector3(-26, 0, -22), 3, 68.0], [Vector3(26, 0, -22), 2, 56.0], [Vector3(-26, 0, 22), 1, 50.0], [Vector3(26, 0, 22), 1, 50.0]]
	for m: Array in mins:
		var mp: Vector3 = cami + (m[0] as Vector3)
		var h: float = m[2]
		d.cyl(1.4, h, mp + Vector3(0, h * 0.5, 0), Color("e8e0d0"), Vector3.ZERO, 10)
		d.cyl(1.5, 6.0, mp + Vector3(0, h + 3.0, 0), Color("5a6470"), Vector3.ZERO, 10, 0.05)
		for b in int(m[1]):
			d.cyl(2.2, 0.8, mp + Vector3(0, h * (0.62 + b * 0.13), 0), Color("d8d0c0"), Vector3.ZERO, 10)
	# Yeni saray (yapımı süren): uzun duvar, burçlar, iskeleler
	var saray := Vector3(140.0, 0.0, -170.0)
	d.box(Vector3(160.0, 10.0, 3.0), saray + Vector3(0, 5.0, 0), Color("c8bca8"))
	for k in 6:
		d.cyl(4.0, 14.0, saray + Vector3(-80.0 + k * 32.0, 7.0, 0), Color("c0b4a0"), Vector3.ZERO, 10)
	d.box(Vector3(40.0, 18.0, 30.0), saray + Vector3(10.0, 9.0, -30.0), Color("d8ccb8"))
	d.build(self)
	# Damlar ve kubbeler: şehir kümesi
	var xs: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 3402
	for i in 220:
		var p := Vector3(rng.randf_range(-320.0, 320.0), 0, rng.randf_range(-320.0, -135.0))
		if p.distance_to(cami) < 40.0 or (absf(p.x - saray.x) < 90.0 and absf(p.z - saray.z) < 40.0):
			continue
		p.y = ground_y(p.x, p.z)
		xs.append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(1.6, 2.6)), p))
	Scenery.scatter(self, Scenery.house_mesh(), xs, [], Scenery._vc_mat())
	for k in 8:
		var p := Vector3(rng.randf_range(-260.0, 260.0), 6.0, rng.randf_range(-300.0, -160.0))
		Scenery.smoke_column(self, p)


func _trees() -> void:
	# Çıplak ağaçlar (kış): gövde ve birkaç dal, dallarda kar
	var rng := RandomNumberGenerator.new()
	rng.seed = 3403
	for i in 70:
		var p := Vector3(rng.randf_range(-90.0, 90.0), 0, rng.randf_range(-70.0, 140.0))
		if absf(p.x) < 26.0 and p.z < 130.0 and p.z > -30.0:
			continue
		if Vector2(p.x - POND.x, p.z - POND.z).length() < 12.0 or (p.x > 14.0 and p.x < 42.0 and p.z > 16.0 and p.z < 70.0):
			continue
		if p.x < -14.0 and p.x > -40.0 and p.z > -30.0 and p.z < 30.0:
			continue
		p.y = ground_y(p.x, p.z)
		var h := rng.randf_range(4.0, 7.5)
		var t := Node3D.new()
		add_child(t)
		t.position = p
		Props.make_solid(Props.cyl(t, 0.18, h, Vector3(0, h * 0.5, 0), Color("3a2e26"), Vector3.ZERO, 6, 0.1))     # gövde katı
		for b in 4:
			var a := rng.randf() * TAU
			var by := h * rng.randf_range(0.5, 0.9)
			var br := Props.cyl(t, 0.06, 2.2, Vector3(cos(a) * 0.8, by + 0.6, sin(a) * 0.8), Color("3a2e26"), Vector3(0, -rad_to_deg(a), 50), 5, 0.03)
			br.rotation = Vector3(0, -a, deg_to_rad(50))
			Props.box(t, Vector3(0.6, 0.06, 0.18), Vector3(cos(a) * 0.9, by + 0.9, sin(a) * 0.9), C_SNOW, Vector3(0, -rad_to_deg(a), 0))


func _snowfall() -> void:
	_snow = GPUParticles3D.new()
	_snow.amount = 900
	_snow.lifetime = 7.0
	_snow.preprocess = 6.0
	_snow.visibility_aabb = AABB(Vector3(-30, -14, -30), Vector3(60, 18, 60))
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(28.0, 0.5, 28.0)
	pm.direction = Vector3(0.2, -1, 0.1)
	pm.spread = 12.0
	pm.initial_velocity_min = 1.0
	pm.initial_velocity_max = 1.6
	pm.gravity = Vector3(0, -0.3, 0)
	pm.turbulence_enabled = true
	pm.turbulence_noise_strength = 0.6
	_snow.process_material = pm
	var q := QuadMesh.new()
	q.size = Vector2(0.05, 0.05)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 0.85)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	q.material = mat
	_snow.draw_pass_1 = q
	add_child(_snow)


func set_snow(on: bool) -> void:
	if _snow:
		_snow.emitting = on
