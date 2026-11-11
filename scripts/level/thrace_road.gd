class_name ThraceRoad
extends Node3D
## Bölüm 35o (Mart 1453): Trakya'da sırtlar arasından inen 300 m'lik yol. docs/OTTOMAN_NEW_A.md §3.2
##   Taşkın dere (14 m, kahverengi, köpüklü) ve yarım ahşap köprü: dört sehpa, iki yürünür kiriş, altı kalas yuvası.
##   Karşı kıyıda çamurlu düzlük (teker izleri, birikintiler), sonra 70 m'lik yokuş (iki fren kazığı, yan hendekler),
##   dipte gece konağı (ateşler, çadırlar, kazığa bağlı öküzler, koru). Ufukta sırtlar ve köyler; ilk bahar.
##   Konvoy: önde çift çift on iki öküz, altı bağlı araba, üstünde kızaktaki Şahi, iki yanda ip tutan adamlar.
## Dünya: yol +z yönünde iner; dere x boyunca +x'e akar.

const WATER_Y := -1.5
const BED_Y := -2.7
const BEAM_X := 0.9
const BEAM_Y := 0.12
const BEAM_Z := 8.6
const TRESTLES := [-4.8, -1.6, 1.6, 4.8]
const PLANKS := [-6.5, -3.9, -1.3, 1.3, 3.9, 6.5]
const PLANK_LEN := 2.55
const LASH_X := -1.55
const CONVOY_WAIT := -54.0                    # köprü kurulurken konvoyun beklediği yer (öküzler yığının gerisinde)
const PILE := Vector3(-3.4, 0.0, -12.2)     # kalas yığını (yakın kıyı, yolun solu)
const MUD_Z := 24.0
const BUNDLES := Vector3(5.6, 0.0, 19.0)
const SLOPE_Z0 := 40.0
const SLOPE_Z1 := 110.0
const SLOPE_DROP := 15.0
const POST1 := Vector3(3.9, 0.0, 44.0)
const POST2 := Vector3(3.9, 0.0, 50.0)
const CAMP := Vector3(0.0, 0.0, 138.0)
const STAKES_Z := 150.0
const GROVE := Vector3(22.0, 0.0, 160.0)

const C_WOOD := Color("6a4a2c")
const C_ROAD := Color("6e5a42")
const C_BRONZE := Color("7a5a2c")

var sun: DirectionalLight3D
var env: WorldEnvironment
var _night_nodes: Array[Node] = []
var planks: Array[Node3D] = []        # kalaslar (bölüm kayar, bağlar)
var plank_bodies: Array[StaticBody3D] = []
var lash_posts: Array[Vector3] = []
var trestle_nodes: Array[Node3D] = []
var convoy: Array[Dictionary] = []    # {"n": Node3D, "d": float, "x": float, "kind": String}
var wagons: Array[Node3D] = []
var wheels: Array[Node3D] = []        # öndeki arabanın tekerleri (dönen)
var oxen: Array[Ox] = []
var men: Array[Person] = []
var gun: Node3D
var drover: Person
var camp_oxen: Array[Ox] = []
var fires: Array[Node3D] = []
var tents: Array[Node3D] = []
var _man_ropes: Array[MeshInstance3D] = []
var _man_handles: Array[Node3D] = []      # adamların iki elinin tuttuğu ip noktası (her karede ipin üstüne)
var _yoke_chain: MultiMeshInstance3D      # arabanın önünden boyunduruklara uzanan çeki zinciri (tek çoklu ağ)
var _t := 0.0
var convoy_s := CONVOY_WAIT
var sink := 0.0                       # öndeki arabanın çamura gömülmesi (0..0.5 m)


static func ground_y(x: float, z: float) -> float:
	var h := 0.0
	# Vadi yamaçları
	h += 18.0 * smoothstep(22.0, 95.0, absf(x))
	# Arkada (Edirne yönü) hafif sırt
	h += 4.0 * smoothstep(-40.0, -130.0, z)
	# Dere yatağı
	var ch := 1.0 - smoothstep(7.0, 9.6, absf(z))
	h = lerpf(h, BED_Y, ch)
	# Yokuş
	h -= SLOPE_DROP * smoothstep(SLOPE_Z0, SLOPE_Z1, z)
	# Yokuşta yol kenarı hendekleri
	if z > SLOPE_Z0 - 2.0 and z < SLOPE_Z1 + 4.0:
		var ax := absf(x)
		h -= 0.7 * (smoothstep(3.3, 3.8, ax) * (1.0 - smoothstep(4.4, 4.9, ax)))
	# Çamur düzlüğünde hafif çukur
	h -= 0.18 * (1.0 - smoothstep(2.0, 9.0, Vector2(x, z - MUD_Z).length()))
	return h


## Konvoyun bastığı yükseklik: köprü açıklığında ve ayaklarda döşemenin üstü (eskiden arazi yüksekliğini izliyordu:
## arabalar, öküzler köprünün altından dere yatağına iniyordu)
static func road_y(x: float, z: float) -> float:
	var g := ground_y(x, z)
	if absf(z) < BEAM_Z + 1.4 and absf(x) < 2.1:
		return maxf(g, BEAM_Y + 0.1)
	return g


## Köprüde yan yan yürüyenler döşemenin kenarına çekilir (2,9 m'lik döşemede arabanın iki yanında tek sıra)
static func bridge_x(x: float, z: float) -> float:
	if absf(x) <= 1.2:
		return x
	var k := 1.0 - smoothstep(BEAM_Z + 1.4, BEAM_Z + 4.0, absf(z))
	return lerpf(x, signf(x) * 1.2, k)


func _ready() -> void:
	_env()
	_ground()
	_stream()
	_bridge()
	_mud()
	_slope()
	_camp()
	_horizon()
	_build_convoy()
	_details()
	update_convoy(convoy_s)
	# İp tutan adamların elleri ipte (kendi pozlarından sonra uygulanır)
	for i in men.size():
		if i < _man_handles.size():
			Stage.grip_hold(men[i], _man_handles[i], [Vector3(0.13, 0, 0), Vector3(-0.13, 0, 0)])


func _process(delta: float) -> void:
	_t += delta
	# Adamların ipleri (yayma P4): arabanın yan tahtasındaki halkadan adamın iki eline sarkarak gelir, ellerin ardından
	# kalçanın yanından yere iner, ucu yerde sürünür. Eller ipte (Stage.grip_hold, her adamın tutamak düğümü ipin
	# üstünde). Eskiden göğüsten arabaya gergin düz çubuktu, eller boştaydı.
	for i in men.size():
		if i < _man_ropes.size():
			_man_rope(i)


## i. adamın ipi ve tutamağı: halka (arabada) → sarkma → iki el → kalçadan yere → yerde uç
func _man_rope(i: int) -> void:
	var m := men[i]
	var w := wagons[mini((i / 2) % 6, wagons.size() - 1)]
	var side := signf(m.global_position.x - w.global_position.x)
	if side == 0.0:
		side = 1.0
	var ring := w.to_global(Vector3(side * 1.12, 1.12, 0.35))
	var fwd := Vector3(sin(m.global_rotation.y), 0, cos(m.global_rotation.y))
	var inb := Vector3(-side, 0, 0)
	var h := m.global_position + Vector3(0, 0.98, 0) + inb * 0.3 + fwd * 0.22
	var u := (ring - h).normalized()
	var p1 := h + u * 0.13
	var p2 := h - u * 0.13
	var hip := m.global_position + Vector3(0, 0.62, 0) - inb * 0.2 - fwd * 0.12
	var g0 := m.global_position - inb * 0.45 - fwd * 0.55
	g0.y = road_y(g0.x, g0.z) + 0.03
	var g1 := m.global_position - inb * 0.6 - fwd * 1.25
	g1.y = road_y(g1.x, g1.z) + 0.03
	var pts: Array = Stage.sag_points(ring, p1, 0.06, 5)
	pts.append_array([p2, hip, g0, g1])
	Stage.rope_to(_man_ropes[i], pts)
	if i < _man_handles.size():
		var hd := _man_handles[i]
		var x := u
		var y := Vector3.UP - x * x.dot(Vector3.UP)
		y = y.normalized() if y.length() > 0.01 else Vector3.FORWARD
		hd.global_transform = Transform3D(Basis(x, y, x.cross(y)), h)


func _env() -> void:
	sun = Night.environment(self, 0.0)
	for c in get_children():
		if c is WorldEnvironment:
			env = c
		elif c is SkyBody or (c is MultiMeshInstance3D and c.get_script() != null):
			_night_nodes.append(c)
	make_day()


func make_day() -> void:
	for n in _night_nodes:
		(n as Node3D).visible = false
	sun.rotation_degrees = Vector3(-34, 150, 0)
	sun.light_color = Color("fff2e0")
	sun.light_energy = 1.05
	if env:
		var e := env.environment
		var sm := e.sky.sky_material as ProceduralSkyMaterial
		if sm:
			sm.sky_top_color = Color("6a94c4")
			sm.sky_horizon_color = Color("d8dee4")
			sm.ground_horizon_color = Color("8a9a7a")
		Look.refresh(env)          # gece görünümü (lacivert pus, gece ton eğrisi) kalmasın
		e.tonemap_exposure = 0.92  # gündüz bölümlerinin pozlaması (gece ortamınınki 1.1)
		e.ambient_light_color = Color("c4c8cc")
		e.ambient_light_energy = 0.8
		e.fog_light_color = Color("c8d0d8")
		e.fog_density = 0.002


func make_afternoon() -> void:
	sun.rotation_degrees = Vector3(-16, 230, 0)
	sun.light_color = Color("ffd8a8")
	sun.light_energy = 0.9
	if env:
		env.environment.fog_light_color = Color("d8c8b0")


func make_night() -> void:
	for n in _night_nodes:
		(n as Node3D).visible = true
	sun.rotation_degrees = Vector3(-38, -150, 0)
	sun.light_color = Color("9fb4ff")
	sun.light_energy = 0.4
	if env:
		var e := env.environment
		var sm := e.sky.sky_material as ProceduralSkyMaterial
		if sm:
			sm.sky_top_color = Color("0a1020")
			sm.sky_horizon_color = Color("1a2238")
			sm.ground_horizon_color = Color("10141c")
		e.ambient_light_color = Color("3a4460")
		e.ambient_light_energy = 0.45
		e.fog_light_color = Color("1a2240")
		e.fog_density = 0.006


# ---------------------------------------------------------------- zemin

func _col(x: float, z: float, y: float, steep: float) -> Color:
	var c := Color("6a7a44").lerp(Color("8a7a58"), clampf(0.5 + 0.5 * sin(x * 0.07 + z * 0.05), 0.0, 1.0) * 0.6)
	# İlk bahar: yer yer yeşil
	c = c.lerp(Color("5a8a3a"), clampf(0.5 + 0.5 * sin(x * 0.031 - z * 0.044 + 1.1) - 0.45, 0.0, 0.5))
	if absf(x) < 3.2:
		c = C_ROAD.darkened(0.06 * (0.5 + 0.5 * sin(z * 0.9)))
		if absf(absf(x) - 1.3) < 0.25:
			c = c.darkened(0.18)     # teker izleri
	if absf(z) < 9.6:
		c = Color("6a5638").lerp(Color("7a6a44"), clampf(0.5 + 0.5 * sin(x * 0.4), 0.0, 1.0) * 0.4)
		return c.darkened(clampf(steep * 0.2, 0.0, 0.12))
	if Vector2(x, z - MUD_Z).length() < 9.0:
		c = Color("4a3a28")
	return c.darkened(clampf(steep * 0.5, 0.0, 0.25))


func _ground() -> void:
	var hf := func(x: float, z: float) -> float:
		return ground_y(x, z)
	var cf := func(x: float, z: float, y: float, steep: float) -> Color:
		return _col(x, z, y, steep)
	var near := LowPoly.terrain(-40.0, 40.0, -80.0, 180.0, 80, 260, hf, cf)
	add_child(near)
	near.set_meta("solid_terrain", true)    # aynı ızgaradan yükseklik gövdesi var (ikinci üçgen gövde gerekmez)
	_height_body(-40.0, 40.0, -80.0, 180.0, 1.0)
	for r: Array in [[-500.0, -40.0, -400.0, 600.0, 46, 100], [40.0, 500.0, -400.0, 600.0, 46, 100],
			[-40.0, 40.0, 180.0, 600.0, 8, 42], [-40.0, 40.0, -400.0, -80.0, 8, 32]]:
		var far := LowPoly.terrain(r[0], r[1], r[2], r[3], r[4], r[5], hf, cf)
		add_child(far)
		LowPoly.solid(far)
	# Dere yatağı yakın alanın kenarında (x ±40) kaba uzak araziyle birleşmez (uzak ızgara 10 m, yatak inceltilir):
	# yatak boyunca görünmez sınır, derenin içinden haritanın dışına yürünmez
	for sx: float in [-1.0, 1.0]:
		var edge := Props.solid(self, Vector3(1.0, 8.0, 24.0), Vector3(sx * 39.5, BED_Y + 3.0, 0.0), Color.WHITE)
		edge.get_child(0).visible = false
		edge.set_meta("no_climb", true)


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


# ---------------------------------------------------------------- dere ve köprü

func _stream() -> void:
	# Taşkın deresi: bulanık, akan su (kırışıklık ve köpük çizgileri akıntıyla +x yönünde kayar). Eskiden opak kahverengi
	# düzlem ve üstünde beyaz köpük kutularıydı: uzaktan çamurlu bir yol ve şerit çizgisi gibi görünüyordu.
	var w := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(300.0, 17.0)
	pm.subdivide_width = 150
	pm.subdivide_depth = 8
	w.mesh = pm
	w.position = Vector3(0, WATER_Y, 0)
	w.name = "Stream"
	var sh := ShaderMaterial.new()
	sh.shader = load("res://assets/shaders/water.gdshader")
	sh.set_shader_parameter("shallow_color", Color(0.42, 0.40, 0.29))
	sh.set_shader_parameter("deep_color", Color(0.30, 0.31, 0.24))
	sh.set_shader_parameter("foam_color", Color(0.86, 0.84, 0.76))
	sh.set_shader_parameter("under_color", Color(0.25, 0.24, 0.17))
	sh.set_shader_parameter("sky_tint", Color(0.66, 0.74, 0.78))
	sh.set_shader_parameter("fresnel_strength", 0.35)
	sh.set_shader_parameter("wave_height", 0.06)
	sh.set_shader_parameter("calm_inner", 0.0)
	sh.set_shader_parameter("calm_outer", 1.0)
	sh.set_shader_parameter("shore_z", -8.4)
	sh.set_shader_parameter("foam_width", 0.6)
	sh.set_shader_parameter("ripple", 0.22)
	sh.set_shader_parameter("glint", 0.6)
	sh.set_shader_parameter("flow", Vector2(2.6, 0.0))
	sh.set_shader_parameter("streaks", 0.55)
	w.material_override = sh
	add_child(w)
	# Kıyıdaki sazlar ve kıyı bandı: _details (tek çoklu ağlar)


func _bridge() -> void:
	# Sehpalar: iki ayak suya iner, üstte başlık kirişi (uçlarında sırıkçılar durur); köpük halkası
	for tz: float in TRESTLES:
		var t := Node3D.new()
		add_child(t)
		t.position = Vector3(0, 0, tz)
		for sx: float in [-1.6, 1.6]:
			Props.cyl(t, 0.16, BEAM_Y - BED_Y, Vector3(sx, (BEAM_Y + BED_Y) * 0.5 - 0.15, 0), C_WOOD.darkened(0.15), Vector3.ZERO, 8)
			var foam := Props.cyl(t, 0.42, 0.03, Vector3(sx, WATER_Y + 0.03, 0), Color("e8e0d0"), Vector3.ZERO, 10)
			foam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		Props.solid(t, Vector3(4.2, 0.22, 0.3), Vector3(0, BEAM_Y - 0.28, 0), C_WOOD)
		for sx: float in [-1.0, 1.0]:
			Props.box(t, Vector3(0.1, 2.6, 0.1), Vector3(sx * 0.8, -1.2, 0), C_WOOD.darkened(0.2), Vector3(0, 0, sx * 36))
		trestle_nodes.append(t)
	# İki kiriş (yürünür)
	for bx: float in [-BEAM_X, BEAM_X]:
		var b := Props.solid(self, Vector3(0.35, 0.24, BEAM_Z * 2.0), Vector3(bx, BEAM_Y - 0.12, 0), C_WOOD.lightened(0.05))
		b.set_meta("no_climb", true)
	# Dülgerlerin iskele tahtası: kirişlerin arasında, sehpa başlıklarına oturur, boydan boya (oyuncu kalası bunun
	# üstünden taşır; kalın: üstüne konan kalas oyuncuyu aşağı itemesin)
	var cw := Props.solid(self, Vector3(0.8, 0.2, BEAM_Z * 2.0), Vector3(0, BEAM_Y - 0.1, 0), C_WOOD.lightened(0.16))
	cw.set_meta("no_climb", true)
	for k in 9:
		Props.box(self, Vector3(0.82, 0.008, 0.04), Vector3(0, BEAM_Y + 0.002, -BEAM_Z + 1.0 + k * 1.95), C_WOOD.darkened(0.3))
	# Kıyı ayakları: taş, üstü döşemeyle bir hizada (kıyıdan köprüye basamaksız çıkılır; konvoy da bu yükseklikte yürür)
	for sz: float in [-1.0, 1.0]:
		Props.solid(self, Vector3(4.0, 1.4, 1.5), Vector3(0, BEAM_Y + 0.1 - 0.7, sz * (BEAM_Z + 0.65)), Color("5e584e"))
		Props.box(self, Vector3(4.06, 0.02, 0.3), Vector3(0, BEAM_Y + 0.105, sz * (BEAM_Z + 0.05)), C_WOOD.darkened(0.2))
	# Kalaslar: yakın kıyıda, yolun solunda yığılı (oyuncu taşır); her yuvada bağ direği
	for i in PLANKS.size():
		var pz: float = PLANKS[i]
		lash_posts.append(Vector3(LASH_X, BEAM_Y + 0.35, pz))
		Props.cyl(self, 0.07, 0.6, Vector3(LASH_X, BEAM_Y + 0.12, pz), C_WOOD.darkened(0.25), Vector3.ZERO, 6)
		var p := Node3D.new()
		add_child(p)
		p.position = PILE + Vector3(0.04 * (i % 2), 0.17 + i * 0.105, -0.05 * i)
		p.rotation.y = deg_to_rad(1.5 * ((i * 7) % 5 - 2))
		Props.box(p, Vector3(2.9, 0.1, PLANK_LEN - 0.08), Vector3.ZERO, C_WOOD.lightened(0.12 + 0.02 * (i % 3)))
		planks.append(p)
	# Yığının altında iki takoz; yığın katı (içinden geçilmez), kalas aldıkça alçalır
	for sz: float in [-0.8, 0.8]:
		Props.box(self, Vector3(3.0, 0.12, 0.2), PILE + Vector3(0, 0.06, sz), C_WOOD.darkened(0.35))
	_pile_body = StaticBody3D.new()
	var pcs := CollisionShape3D.new()
	pcs.shape = BoxShape3D.new()
	_pile_body.add_child(pcs)
	add_child(_pile_body)
	update_pile()


var _pile_body: StaticBody3D


## Yığında kalan kalaslar (yuvaya oturmamış, taşınmayan)
func pile_nodes() -> Array[Node3D]:
	var out: Array[Node3D] = []
	for p in planks:
		if p.visible and p.get_meta("slot", -1) < 0:
			out.append(p)
	return out


## Yığının çarpışma kutusu kalan kalasların boyuna göre (boşsa kalkar)
func update_pile() -> void:
	var n := pile_nodes().size()
	if _pile_body == null:
		return
	var h := 0.12 + n * 0.105
	_pile_body.position = PILE + Vector3(0, h * 0.5, -0.1)
	(_pile_body.get_child(0) as CollisionShape3D).shape.size = Vector3(3.0, h, PLANK_LEN + 0.2)
	_pile_body.process_mode = Node.PROCESS_MODE_INHERIT if n > 0 else Node.PROCESS_MODE_DISABLED
	(_pile_body.get_child(0) as CollisionShape3D).disabled = n == 0


## Yığının en üstündeki kalas (alınacak olan)
func pile_top() -> Node3D:
	var best: Node3D = null
	for p in pile_nodes():
		if best == null or p.position.y > best.position.y:
			best = p
	return best


## Kalas yuvasına oturur: katı olur. node verilirse o kalas bu yuvaya geçer (planks dizisinde yer değiştirir)
func set_plank(i: int, node: Node3D = null, solid := true) -> void:
	if node != null and planks[i] != node:
		var j := planks.find(node)
		if j >= 0:
			planks[j] = planks[i]
		planks[i] = node
	var p := planks[i]
	p.visible = true
	p.set_meta("slot", i)
	p.position = Vector3(0, BEAM_Y + 0.05, PLANKS[i])
	p.rotation = Vector3.ZERO
	update_pile()
	if p.has_meta("body") or not solid:
		return
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(2.9, 0.1, PLANK_LEN - 0.08)
	cs.shape = bs
	body.add_child(cs)
	p.add_child(body)
	p.set_meta("body", body)


## Bağ: direğe sarım halkaları (n: 1 ya da 2), gevşekse sarkık
func lash_rings(i: int, n: int, loose: bool) -> void:
	var pid := "Lash%d" % i
	var old := get_node_or_null(pid)
	if old:
		old.name = pid + "_old"
		old.queue_free()
	var g := Node3D.new()
	g.name = pid
	add_child(g)
	var lp := lash_posts[i]
	for k in n:
		var r := Props.ring(g, 0.07, 0.11, lp + Vector3(0, -0.12 + k * 0.1 - (0.08 if loose else 0.0), 0), Color("c8b080"),
			Vector3(0 if not loose else 20, 0, 0))
		r.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Direkten kalasın kenarına inen ip (sıkıysa gergin, gevşekse sarkık)
	var rope := Props.cyl(g, 0.018, 0.34, lp + Vector3(0.12, -0.24 - (0.05 if loose else 0.0), 0), Color("c8b080"), Vector3(0, 0, 50 if not loose else 25), 5)
	rope.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _mud() -> void:
	# Su birikintileri ve çalı demeti yığını
	for k in 5:
		var p := Vector3(-2.0 + k * 1.3, 0, MUD_Z - 4.0 + (k % 2) * 6.0)
		var pd := Props.cyl(self, 0.8 + (k % 3) * 0.3, 0.02, Vector3(p.x, ground_y(p.x, p.z) + 0.02, p.z), Color("4a5a60"), Vector3.ZERO, 10)
		pd.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for k in 6:
		var b := Props.cyl(self, 0.32, 1.6, BUNDLES + Vector3((k % 3) * 0.7 - 0.7, ground_y(BUNDLES.x, BUNDLES.z) + 0.3 + (k / 3) * 0.55, 0), Color("7a6a3a"), Vector3(90, 0, 0), 7)
		b.name = "Bundle%d" % k
		b.set_meta("body", Props.make_solid(b, 0.9))      # yığının içinden yürünmesin; alınınca kalkar


func bundle_node(k: int) -> Node3D:
	return get_node_or_null("Bundle%d" % k)


func _slope() -> void:
	# Fren kazıkları: kalın meşe direk, halat sarılı
	for pp: Vector3 in [POST1, POST2]:
		var y := ground_y(pp.x, pp.z)
		Props.cyl(self, 0.24, 1.6, Vector3(pp.x, y + 0.7, pp.z), Color("4a3424"), Vector3.ZERO, 10)
		# Kazığa iki buçuk tur sarılı ip (volta): fren ipi buradan arabaya ve oyuncunun eline gider (eskiden üç düz halka)
		Stage.rope_wrap(self, Vector3(pp.x, y, pp.z), 0.255, 0.56, 0.84, 2.5, 0.034, Color("c8b080"))
		# Kazığın dibinde ipin sürtünmesiyle kazınmış toprak
		Props.cyl(self, 0.42, 0.06, Vector3(pp.x, y + 0.01, pp.z), Color("4a3a28"), Vector3.ZERO, 9)
	# Yol kenarında taşlar: _details


func _camp() -> void:
	var c := CAMP
	for fp: Vector3 in [c + Vector3(-7.0, 0, -4.0), c + Vector3(6.0, 0, 4.0), c + Vector3(-2.0, 0, 12.0)]:
		var p := Vector3(fp.x, ground_y(fp.x, fp.z), fp.z)
		var fire := Node3D.new()
		add_child(fire)
		fire.position = p
		fires.append(fire)
	for k in 6:
		var tp := c + Vector3(-16.0 + (k % 3) * 6.0, 0, -2.0 + (k / 3) * 9.0)
		if k % 3 == 2:
			tp.x = 14.0
		tents.append(Night.tent(self, Vector3(tp.x, ground_y(tp.x, tp.z), tp.z), 1.8, Color("d8cbb0"), Color("6a2a22")))
	# Öküz kazıkları sırası
	for k in 10:
		var sp := Vector3(-14.0 + k * 1.6, 0, STAKES_Z)
		Props.cyl(self, 0.05, 0.8, Vector3(sp.x, ground_y(sp.x, sp.z) + 0.4, sp.z), C_WOOD.darkened(0.2), Vector3.ZERO, 5)
	# Koru
	Scenery.trees(self, GROVE, 2.0, 14.0, 22, [], func(x: float, z: float) -> float: return ground_y(x, z), 3503)


## Gece: ateşler yanar, öküzler kazıklarda
func light_camp() -> void:
	for f: Node3D in fires:
		Night.campfire(self, f.position, 1.0)
	var coats := [Color("8a5a36"), Color("6a4a2a"), Color("c8a878"), Color("4a3a2a"), Color("9a6a40"), Color("b89870")]
	for k in 8:
		var o := Ox.new(coats[k % coats.size()])
		add_child(o)
		var sp := Vector3(-14.0 + k * 1.6 + (0.8 if k > 3 else 0.0), 0, STAKES_Z + 1.6)
		o.position = Vector3(sp.x, ground_y(sp.x, sp.z), sp.z)
		o.rotation.y = PI
		camp_oxen.append(o)
	for k in 4:
		Night.torch(self, Vector3(-4.0 + k * 3.0, ground_y(-4.0 + k * 3.0, CAMP.z - 8.0), CAMP.z - 8.0), 2.2, k % 2 == 0)


func _horizon() -> void:
	var d := Dressing.new(3504)
	for i in 16:
		var x := -520.0 + i * 70.0
		d.ball(120.0, Vector3(x, -70.0 + 25.0 * sin(i * 1.7), 520.0 + 40.0 * cos(i * 0.9)), Color("5e6a3e").darkened(0.08 * (i % 3)), Vector3(1.0, 0.8, 1.3), 10)
		d.ball(110.0, Vector3(x + 30.0, -70.0 + 20.0 * cos(i * 1.3), -480.0 - 30.0 * sin(i)), Color("5e6a3e").darkened(0.1), Vector3(1.0, 0.8, 1.3), 10)
	d.build(self)
	# Uzak köyler (yamaçlarda)
	var xs: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 3505
	for i in 40:
		var side := 1.0 if i % 2 == 0 else -1.0
		var p := Vector3(side * rng.randf_range(70.0, 160.0), 0, rng.randf_range(-60.0, 220.0))
		p.y = ground_y(p.x, p.z)
		xs.append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(1.4, 2.0)), p))
	Scenery.scatter(self, Scenery.house_mesh(), xs, [], Scenery._vc_mat())
	Scenery.trees(self, Vector3(0, 0, 60), 30.0, 160.0, 120, [Rect2(-12.0, -60.0, 24.0, 260.0), Rect2(-40.0, -12.0, 80.0, 24.0)],
		func(x: float, z: float) -> float: return ground_y(x, z), 3506)


# ---------------------------------------------------------------- konvoy

func _build_convoy() -> void:
	var coats := [Color("8a5a36"), Color("6a4a2a"), Color("c8a878"), Color("4a3a2a"), Color("9a6a40"), Color("b89870")]
	# Öküzler: altı çift, boyunduruk
	for k in 6:
		for sx: float in [-0.75, 0.75]:
			var o := Ox.new(coats[(k * 2 + int(sx > 0)) % coats.size()])
			add_child(o)
			oxen.append(o)
			convoy.append({"n": o, "d": 3.4 + k * 2.9, "x": sx, "kind": "ox"})
		var yoke := Node3D.new()
		add_child(yoke)
		Props.box(yoke, Vector3(2.0, 0.12, 0.14), Vector3(0, 1.62, 0), Color("5a3a22"))
		# Boyunduruk dikmeleri: her öküzün boynunun iki yanından inen çubuklar, altta kayış; ortada zincir halkası
		# (yayma P4: boyunduruk boynun üstünde havada duran bir kalastı)
		for sx: float in [-0.75, 0.75]:
			for dx: float in [-0.27, 0.27]:
				Props.cyl(yoke, 0.025, 0.5, Vector3(sx + dx, 1.36, 0.0), Color("6a4a2c"), Vector3.ZERO, 4)
			Props.box(yoke, Vector3(0.58, 0.05, 0.08), Vector3(sx, 1.12, 0.0), Color("3a2a1e"))
		Props.ring(yoke, 0.05, 0.08, Vector3(0, 1.52, 0.0), Color("3a3a40"), Vector3(90, 0, 0))
		Props.bake_static(yoke, yoke.get_children())
		convoy.append({"n": yoke, "d": 3.4 + k * 2.9 + 0.95, "x": 0.0, "kind": "yoke"})
	# Arabalar: bağlı altı araba
	for k in 6:
		var w := Node3D.new()
		add_child(w)
		Props.box(w, Vector3(2.2, 0.22, 2.9), Vector3(0, 0.95, 0), C_WOOD)
		for sx: float in [-1.0, 1.0]:
			Props.box(w, Vector3(0.1, 0.35, 2.9), Vector3(sx * 1.05, 1.2, 0), C_WOOD.darkened(0.1))
		Props.cyl(w, 0.08, 2.5, Vector3(0, 0.55, 0.95), C_WOOD.darkened(0.3), Vector3(0, 0, 90), 6)
		Props.cyl(w, 0.08, 2.5, Vector3(0, 0.55, -0.95), C_WOOD.darkened(0.3), Vector3(0, 0, 90), 6)
		for wz: float in [0.95, -0.95]:
			for sx: float in [-1.2, 1.2]:
				var wh := Node3D.new()
				wh.position = Vector3(sx, 0.55, wz)
				w.add_child(wh)
				Props.cyl(wh, 0.55, 0.14, Vector3.ZERO, Color("4a3424"), Vector3(0, 0, 90), 12)
				for s in 3:
					var sp := Props.box(wh, Vector3(0.06, 1.0, 0.06), Vector3.ZERO, Color("6a4a2c"))
					sp.rotation.x = s * PI / 3.0
				if k == 0:
					wheels.append(wh)
		# Önde çeki oku ve halkası (zincir buraya bağlı)
		Props.cyl(w, 0.06, 0.7, Vector3(0, 0.62, 1.7), C_WOOD.darkened(0.3), Vector3(90, 0, 0), 6)
		Props.ring(w, 0.05, 0.08, Vector3(0, 0.62, 2.07), Color("3a3a40"), Vector3(90, 0, 0))
		if k > 0:
			Props.bake_static(w, w.get_children())      # dönmeyen arabalar tek ağ (çizim sayısı)
		wagons.append(w)
		convoy.append({"n": w, "d": -1.6 - k * 3.15, "x": 0.0, "kind": "wagon"})
	# Şahi: kızakta, arabaların üstünde (zincirle bağlı)
	gun = Node3D.new()
	add_child(gun)
	Props.box(gun, Vector3(1.6, 0.25, 9.0), Vector3(0, 0.0, 0), C_WOOD.darkened(0.15))
	Props.cyl(gun, 0.62, 7.2, Vector3(0, 0.8, 0), C_BRONZE, Vector3(90, 0, 0), 16)
	Props.cyl(gun, 0.73, 0.5, Vector3(0, 0.8, 3.35), C_BRONZE.darkened(0.12), Vector3(90, 0, 0), 16)
	Props.cyl(gun, 0.38, 0.06, Vector3(0, 0.8, 3.62), Color("1a1410"), Vector3(90, 0, 0), 14)
	for z: float in [-2.4, 0.0, 2.4]:
		Props.cyl(gun, 0.67, 0.18, Vector3(0, 0.8, z), C_BRONZE.darkened(0.2), Vector3(90, 0, 0), 16)
		Props.box(gun, Vector3(1.7, 0.05, 0.08), Vector3(0, 0.15, z + 0.5), Color("4a4a50"))
	convoy.append({"n": gun, "d": -7.9, "x": 0.0, "kind": "gun"})
	# İki yanda ip tutan adamlar
	var mc := [Color("7a6a50"), Color("8a6a4a"), Color("6a5040"), Color("5a4a3a")]
	for k in 6:
		for sx: float in [-1.0, 1.0]:
			var m := Person.new({"coat": mc[(k + int(sx > 0)) % mc.size()], "pants": Color("e8e0d0"), "hat": "bork" if k % 2 == 0 else "turban",
				"mustache": true, "skin": Color("c89070")})
			m.set_meta("no_talk", true)
			add_child(m)
			men.append(m)
			convoy.append({"n": m, "d": -1.0 - k * 3.15, "x": sx * 2.55, "kind": "man"})
			_man_ropes.append(Stage.rope(self, Vector3.ZERO, Vector3(0, 0.1, 0), 0.0, 0.022, Color("c8b080")))
			var hd := Node3D.new()
			add_child(hd)
			_man_handles.append(hd)
	_yoke_chain = Stage.chain(self, Vector3.ZERO, Vector3(0, 0, 1), 0.0, 0.085, Color("3a3a40"))
	drover = Person.new({"coat": Color("5a4a36"), "pants": Color("4a3a2a"), "hat": "bork", "beard": true, "hair": Color("c8c4b8"), "skin": Color("c08868")})
	drover.set_meta("spk", "SPK_DROVER")
	add_child(drover)
	convoy.append({"n": drover, "d": 20.6, "x": -1.9, "kind": "man"})


## Çeki zinciri: öndeki arabanın ok ucundaki halkadan birinci boyunduruğa, oradan her boyunduruğa (iki öküzün
## arasından, sarkarak). Tek çoklu ağ.
func _lay_chain() -> void:
	if _yoke_chain == null or wagons.is_empty():
		return
	var pts: Array = [wagons[0].to_global(Vector3(0, 0.62, 2.07))]
	for it: Dictionary in convoy:
		if it["kind"] == "yoke":
			var y: Node3D = it["n"]
			var q := y.global_position + Vector3(0, 1.5, 0)
			var a: Vector3 = pts[-1]
			var mid := a.lerp(q, 0.5)
			mid.y = minf(a.y, q.y) - 0.3
			pts.append_array([a.lerp(mid, 0.5) + Vector3(0, -0.08, 0), mid, mid.lerp(q, 0.5) + Vector3(0, -0.08, 0), q])
	Stage.chain_to(_yoke_chain, pts)


## Zemin ayrıntısı (yayma P4): yolda çamur, tekerlek ve toynak izi, kenarlarda ayak izi; tarlada ot ve taş; dere
## kıyısında ıslak bant, köpük, saz; yokuş kenarında taşlar; konakta saman ve çiğnenmiş çamur. Her tür tek çoklu ağ.
## Eskiden yol ve tarlalar düz boyalı, kıyıda 40 ayrı saz silindiri, yokuşta 30 ayrı taş vardı.
func _details() -> void:
	# 2. tur: yalnız yol şeridi ve oyuncunun geçtiği yerler (köprü başı z −24'ten konağa); tarladaki ot/taş kaldırıldı
	# (üçgen bütçesi: ilk turda +%20)
	var hf := func(x: float, z: float) -> float: return ground_y(x, z)
	var off_bridge := func(x: float, z: float) -> bool: return absf(z) > 9.9
	Nature.ground_detail(self, Rect2(-3.0, -24.0, 6.0, 164.0), "mud", 0.12, 3511, hf, off_bridge)
	Nature.ground_detail(self, Rect2(-9.0, MUD_Z - 9.0, 18.0, 18.0), "camp_mud", 0.35, 3512, hf,
		func(x: float, z: float) -> bool: return Vector2(x, z - MUD_Z).length() < 8.5)
	for rx: float in [-0.6, 0.6]:
		Nature.trail(self, [Vector3(rx, 0, -24.0), Vector3(rx, 0, -10.2)], "wheel_ruts", hf, 1.0, 3514 + int(rx * 10.0), 0.1)
		Nature.trail(self, [Vector3(rx, 0, 10.2), Vector3(rx, 0, 112.0)], "wheel_ruts", hf, 1.0, 3516 + int(rx * 10.0), 0.1)
	Nature.trail(self, [Vector3(0, 0, 14.0), Vector3(0, 0, 60.0)], "hoofprint", hf, 0.9, 3519, 0.9)
	# Yokuş kenarı taşları (eskiden 30 ayrı top)
	Nature.ground_detail(self, Rect2(-7.6, SLOPE_Z0, 15.2, SLOPE_Z1 - SLOPE_Z0), "stone", 0.05, 3502, hf,
		func(x: float, _z: float) -> bool: return absf(x) > 5.2)
	# Kıyı (köprü çevresi): sazlar (eskiden 40 ayrı silindir), ıslak bant, köpük, yosun
	Nature.ground_detail(self, Rect2(-20.0, 7.3, 40.0, 2.2), "tall_grass", 0.35, 3501, hf,
		func(x: float, _z: float) -> bool: return absf(x) > 3.0)
	Nature.ground_detail(self, Rect2(-20.0, -9.5, 40.0, 2.2), "tall_grass", 0.35, 3522, hf,
		func(x: float, _z: float) -> bool: return absf(x) > 3.0)
	var bank_keep := func(x: float, _z: float) -> bool: return absf(x) > 2.3
	Nature.shore_band(self, Vector3(-20.0, 0, -9.8), Vector3(20.0, 0, -9.8), Vector3(0, 0, 1), WATER_Y, hf, 3523, bank_keep)
	Nature.shore_band(self, Vector3(-20.0, 0, 9.8), Vector3(20.0, 0, 9.8), Vector3(0, 0, -1), WATER_Y, hf, 3524, bank_keep)
	# Gece konağı: kazık sırasında saman ve toynak izi
	Nature.ground_detail(self, Rect2(-16.0, STAKES_Z - 1.0, 18.0, 5.0), "straw", 0.8, 3525, hf)
	Nature.ground_detail(self, Rect2(-16.0, STAKES_Z - 2.0, 18.0, 6.0), "hoofprint", 0.4, 3526, hf)


## Konvoyu yola oturt: s = öndeki arabanın önünün z'si. Her parça kendi z'sinde zemine oturur, arabalar eğime göre eğilir.
func update_convoy(s: float, tilt := 0.0) -> void:
	convoy_s = s
	for it: Dictionary in convoy:
		var n: Node3D = it["n"]
		var z: float = s + float(it["d"])
		var kind: String = it["kind"]
		var x: float = it["x"] if kind != "man" else bridge_x(it["x"], z)
		var y := road_y(x, z)
		match kind:
			"wagon", "gun":
				var half := 1.4 if kind == "wagon" else 4.3
				var ya := road_y(x, z - half)
				var yb := road_y(x, z + half)
				var pitch := atan2(ya - yb, half * 2.0)
				var base := (ya + yb) * 0.5
				if kind == "gun":
					base += 1.2
				elif n == wagons[0]:
					base -= sink
				n.position = Vector3(x, base, z)
				n.rotation = Vector3(pitch, 0, tilt)
			"ox":
				n.position = Vector3(x, y, z)
				n.rotation = Vector3(0, 0, 0)
				(n as Ox).lean = clampf((road_y(x, z - 1.0) - road_y(x, z + 1.0)) * 0.6, -1.0, 1.0)
			"yoke":
				n.position = Vector3(x, y, z)
			_:
				n.position = Vector3(x, y, z)
				# İp tutan adam yürüdüğü yöne bakar, gövdesi arabaya (ipe) hafif dönük
				n.rotation = Vector3(0, -signf(x) * 0.45 if absf(x) > 1.5 and n != drover else 0.0, 0)
	_lay_chain()
	for i in men.size():
		if i < _man_ropes.size():
			_man_rope(i)


func spin_wheels(delta_m: float) -> void:
	for w in wheels:
		w.rotation.x += delta_m / 0.55
