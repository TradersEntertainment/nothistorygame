class_name Camp
extends Node3D
## Bölüm 4a: Osmanlı ordugâhı, 22 Nisan 1453 gecesi (GDD §9.3).
## Kazıklı çitle çevrili esir alanı: esir çadırı, kapanmış pazar tezgâhları, siper
## olacak sandık ve fıçılar. Tek çıkış, meşaleli nöbet noktası (Hasan ile Hüseyin).
## Tek harita: esir alanı World1453'ün ordugâhında, "camp_pen" bölgesinde durur (Maltepe ordugâhının ön kenarı, otağın
## ~280 m batı-güneyi, kara surlarından ~235 m geride). Çitin dışı dünyanın ordugâhı (çadır sıraları, ateşler), ufuk
## gerçek kara surları ve şehrin siluetidir; yerel +z (kapı, kaçış yolu) surlara bakar. Öbür bölümlerde ve havadan aynı
## alanı far_pen kurar (World1453.FAR_REGIONS).

const PEN_X := 10.0
const PEN_Z0 := -12.0
const GATE_Z := 6.0
const GATE_HALF := 1.3
const ESCAPE_Z := 9.5

const TENT_SPAWN := Vector3(-4.0, 0.0, -5.6)
const MARKET_SPAWN := Vector3(6.2, 0.0, -2.0)
const HASAN_POS := Vector3(-1.0, 0.0, GATE_Z + 0.7)
const HUSEYIN_POS := Vector3(1.0, 0.0, GATE_Z + 0.7)
## Bölgenin oynanış alanı (yerel): dünya buraya çadır, ağaç, kalabalık koymaz, zemini düzler (World1453.FAR_REGIONS)
const KEEP := Rect2(-46.0, -24.0, 92.0, 80.0)
## Esir alanının kendi zemini (çiğnenmiş çamur; ötesi dünyanın arazisi)
const PATCH := Rect2(-22.0, -20.0, 44.0, 50.0)
## Gece sisinde ordugâhın çadır katmanlarının çizildiği yarıçap (esir alanından)
const NEAR_R := 170.0

var hasan: Soldier
var huseyin: Soldier
var lights: Array = []
var world: SiegeField
## Uzak kurulum (far_pen): yalnız görüntü, birleşik ağ; insan, ışık, yazı yok; parçalar dünyanın arazisine oturur
var far := false
var _far_fires: Array = []
var _t := 0.0


func _ready() -> void:
	if far:
		_build_far()
		return
	Audio.voice_space("outdoor")
	# Gece ortamı (dünyanın gece bölümleriyle aynı); sis surları ve şehrin siluetini yutmasın diye seyrek
	Night.environment(self, 0.007)
	_build_ground()
	_build_pen()
	_build_market()
	_build_gate()
	_build_camp()
	_bake_near()
	_occluders()
	_build_world()


## Esir alanının durağan ayrıntısı (kazıklar, çadırlar, tezgâhlar, sandıklar, ateş taşları) aynı malzeme gruplarıyla
## birleşik ağa pişirilir: görüntü aynı (renk köşede, desen ve dış çizgi grupta), çizim sayısı yüzlerden birkaça iner.
## Çarpışmalar, insanlar, alevler, ışıklar, yazılar ve betikli düğümler (gökyüzü, istasyonlar) olduğu gibi kalır.
func _bake_near() -> void:
	var nodes: Array = []
	for c in get_children():
		if c.get_script() != null or c.has_meta("dressing") or not (c is Node3D):
			continue
		nodes.append(c)
	Props.bake_static(self, nodes)


## Dünya ilk kare çizildikten sonra kurulur (bölüm kartı ve karartma ekrandayken): sahne açılışı bekletmez
func _build_world() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_inside_tree():
		return
	world = World1453.build(self, "camp_pen", [KEEP], true)
	# Esir alanının kendi zemininin altından dünyanın otu, taşı çıkmasın
	World1453.clear_rect(world, World1453.world_rect(World1453.region("camp_pen"), PATCH), false)
	_thin_world()
	# Yaşayan şehir ve sur arkası sonradan kurulur: onlar da seyrelsin
	for d: float in [1.0, 4.0]:
		await get_tree().create_timer(d, false).timeout
		if is_instance_valid(world):
			_thin_world()


## Gece, esir alanından: dünyanın küçük parçaları (insan, eşya, sancak, kapı, sandık) mesafeyle seyrelir (sisin içinde
## zaten seçilmez); ordugâhın kalabalık hücreleri gölge düşürmez, tam model 70 m'de siluete döner, siluet (ucu yoktu) 120 m'de, surdaki mürettebat 200 m'de biter; duman
## sütunları 350 m. Alev ve haleler (surlardaki meşaleler, ordugâhın ateşleri), çadır ve ağaç katmanları, büyük yapılar
## dokunulmaz. Geniş ağlar ay gölgesine girmez (gölge yalnız 35 m'de; arazinin bütün üçgenleri gölge geçişindeydi).
func _thin_world() -> void:
	for n in world.find_children("*", "GeometryInstance3D", true, false):
		var g := n as GeometryInstance3D
		if g.material_override is ShaderMaterial:
			continue
		if g is CPUParticles3D or g is GPUParticles3D:
			_range(g, 350.0, 30.0)
			continue
		if g is MultiMeshInstance3D:
			# Ordugâhın kalabalık hücreleri (yakın katman gölge düşürüyordu) ve uzak siluetleri
			g.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var twin = g.get_meta("crowd_twin") if g.has_meta("crowd_twin") else null
			if twin is GeometryInstance3D and is_instance_valid(twin):
				# Yakın (tam model) katman 70 m'de siluete döner (gece, 150 m'de bir figür birkaç piksel)
				g.visibility_range_end = 70.0
				g.visibility_range_end_margin = 8.0
				(twin as GeometryInstance3D).visibility_range_begin = 70.0
				(twin as GeometryInstance3D).visibility_range_begin_margin = 8.0
			elif g.visibility_range_begin > 0.0 and g.visibility_range_end <= 0.0:
				_range(g, 120.0, 15.0)
			elif g.get_parent() is PoseCrew:
				_range(g, 200.0, 20.0)      # surdaki okçu/taşçı mürettebatı: esir alanından en az 230 m
			else:
				_near_first(g as MultiMeshInstance3D, NEAR_R)
			continue
		var sz := g.get_aabb().size * g.global_basis.get_scale()
		var m := maxf(sz.x, maxf(sz.y, sz.z))
		if m < 5.0:
			_range(g, 140.0, 15.0)
		elif m < 25.0:
			_range(g, 450.0, 40.0)
		elif m > 60.0:
			g.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Ordugâhı kaplayan çoklu ağ katmanları (çadır, at, köşk, ağaç): örnekler esir alanına uzaklığa göre sıralanır ve
## yalnız r içindekiler çizilir (gece sisinde ötesi seçilmez). Dizi ("xforms") aynı sırayla güncellenir; çarpışmalar
## kurulurken ayrı şekil olarak yazıldığından etkilenmez. Bir kez yapılır.
func _near_first(mmi: MultiMeshInstance3D, r: float) -> void:
	var mm := mmi.multimesh
	# Yalnız Scenery.scatter'ın durağan dağıtımları ("xforms" yazılı); örnek sırasıyla canlandırılan ağlar (PoseCrew vb.)
	# ve örnek verisi taşıyanlar dokunulmaz
	if mm == null or mm.transform_format != MultiMesh.TRANSFORM_3D or mmi.has_meta("g1_near") or mm.instance_count < 16 \
			or not mmi.has_meta("xforms") or mm.use_custom_data or mmi.get_parent() is PoseCrew:
		return
	var ab := mmi.get_aabb()
	if maxf(ab.size.x, ab.size.z) < 150.0:
		return
	mmi.set_meta("g1_near", true)
	var c := mmi.global_transform.affine_inverse() * global_position
	var xfs: Array = []
	for i in mm.instance_count:
		xfs.append(WorldWalk.inst_xf(mmi, i))
	var order: Array = range(mm.instance_count)
	var d: Array = []
	for i in mm.instance_count:
		d.append(Vector2((xfs[i] as Transform3D).origin.x - c.x, (xfs[i] as Transform3D).origin.z - c.z).length())
	order.sort_custom(func(a: int, b: int) -> bool: return d[a] < d[b])
	var cols: Array = []
	if mm.use_colors:
		for i in mm.instance_count:
			cols.append(mm.get_instance_color(i))
	var out: Array = []
	var n := 0
	for k in order.size():
		var i: int = order[k]
		out.append(xfs[i])
		mm.set_instance_transform(k, xfs[i])
		if mm.use_colors:
			mm.set_instance_color(k, cols[i])
		if d[i] <= r:
			n += 1
	if mmi.has_meta("xforms"):
		mmi.set_meta("xforms", out)
	mm.visible_instance_count = n


## Görünürlük ucunu kısaltır (zaten daha kısaysa dokunmaz; yakın/uzak katmanların başlangıcı korunur)
func _range(g: GeometryInstance3D, end: float, margin: float) -> void:
	if g.visibility_range_end > 0.0 and g.visibility_range_end <= end:
		return
	if g.visibility_range_begin >= end:
		g.visible = false
		return
	g.visibility_range_end = end
	g.visibility_range_end_margin = margin


## Kazık çit örtücüsü: çitin içinden bakınca arkasında tamamen kalan dünya çizilmez (kazık araları 10 cm, gece karanlık)
func _occluders() -> void:
	for seg: Array in [[Vector3(-PEN_X, 0, PEN_Z0), Vector3(PEN_X, 0, PEN_Z0)], [Vector3(-PEN_X, 0, PEN_Z0), Vector3(-PEN_X, 0, GATE_Z)],
			[Vector3(PEN_X, 0, PEN_Z0), Vector3(PEN_X, 0, GATE_Z)], [Vector3(-PEN_X, 0, GATE_Z), Vector3(-GATE_HALF - 0.2, 0, GATE_Z)],
			[Vector3(GATE_HALF + 0.2, 0, GATE_Z), Vector3(PEN_X, 0, GATE_Z)]]:
		var a: Vector3 = seg[0]
		var b: Vector3 = seg[1]
		var o := OccluderInstance3D.new()
		var bo := BoxOccluder3D.new()
		bo.size = Vector3(0.06, 2.1, a.distance_to(b))
		o.occluder = bo
		o.position = (a + b) * 0.5 + Vector3(0, 1.15, 0)
		o.rotation.y = atan2(b.x - a.x, b.z - a.z)
		add_child(o)


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


## Öbür bölümlerde (ve 7, 11 uçuşunda) esir alanı: aynı kurucular, uzak sürümde (World1453.build çağırır)
static func far_pen(parent: Node3D, xf: Transform3D) -> Node3D:
	var c := Camp.new()
	c.name = "FarPen"
	c.far = true
	c.transform = xf
	c.set_meta("night", bool(parent.get("night_build")) if parent.get("night_build") != null else true)
	parent.add_child(c)
	return c


## Görünen dünya arazisinin bu bölgedeki yerel yüksekliği (bölümün kendisinde düzlenmiş: ≈ −0,05)
func _gy(x: float, z: float) -> float:
	if not far and KEEP.has_point(Vector2(x, z)):
		return -0.05          # bölgenin alanı: dünya zemini bölgenin zemininin hemen altında düz (World1453 BLEND)
	var xf := World1453.region("camp_pen")
	var w := xf * Vector3(x, 0.0, z)
	return World1453.surface_h(w.x, w.z) - xf.origin.y


## Yerleştirme yüksekliği: bölümün kendisinde düz zemin (0), uzak kurulumda dünyanın arazisi
func _y(x: float, z: float) -> float:
	return _gy(x, z) if far else 0.0


func _build_far() -> void:
	set_process(false)
	var hf := func(x: float, z: float) -> float: return _gy(x, z) + 0.02
	add_child(LowPoly.terrain(PATCH.position.x, PATCH.end.x, PATCH.position.y, PATCH.end.y, 11, 12, hf, _patch_color))
	var n0 := get_child_count()
	_build_pen()
	_build_market()
	_build_gate()
	# Çit, çadır, tezgâh, sandık: her parça kendi yerinde dünyanın arazisine oturur
	for i in range(n0, get_child_count()):
		var c := get_child(i) as Node3D
		if c and not c.has_meta("placed"):
			c.position.y += _gy(c.position.x, c.position.z)
	_build_camp()
	# Yazılar uzaktan okunmaz (birleşik ağa da girmez)
	for l in find_children("*", "Label3D", true, false):
		l.queue_free()
	Props.bake_static(self, get_children())
	# Uzakta hiç çizilmez: birleşik ağlar ve çoklu ağlar (eşya, at, kazık dağıtımları) 1500 m'de biter (kenar payıyla).
	# Yalnız ateşler (aşağıda) sınırsız: gece ordugâhın öbür ateşleri gibi uzaktan seçilir
	for gi in find_children("*", "GeometryInstance3D", true, false):
		(gi as GeometryInstance3D).visibility_range_end = 1500.0
		(gi as GeometryInstance3D).visibility_range_end_margin = 150.0
	# Ateşler: alev ve hale (gece)
	var fl: Array = []
	var gl: Array = []
	for f: Array in _far_fires:
		var p: Vector3 = f[0]
		var s: float = f[1]
		fl.append(Transform3D(Basis.from_scale(Vector3(0.8, 1.2, 0.8) * s), p))
		gl.append(Transform3D(Basis.from_scale(Vector3.ONE * 3.2 * s), p + Vector3(0, 0.5 * s, 0)))
	var fires := Node3D.new()
	fires.name = "night"
	add_child(fires)
	Flame.scatter_flames(fires, fl)
	Flame.scatter_glows(fires, gl)
	fires.visible = bool(get_meta("night", true))
	# Dünya sonradan geceye/gündüze dönerse (CampDay.make_night → SiegeField.set_mode) ateşler de yanar/söner
	var nl = get_parent().get("_night")
	if nl is Array:
		(nl as Array).append(fires)


static func _patch_color(x: float, z: float, _h: float, _steep: float) -> Color:
	var n := 0.5 + 0.5 * sin(x * 1.3 + z * 0.7) * cos(z * 1.1 - x * 0.4)
	var mud := Color("4a3a2a").lerp(Color("3a3024"), n)
	if absf(x) < PEN_X and z > PEN_Z0 and z < GATE_Z + 14.0:
		return mud
	# Alanın kenarına doğru dünyanın çayırına döner (dikiş görünmesin)
	var e := minf(minf(x - PATCH.position.x, PATCH.end.x - x), minf(z - PATCH.position.y, PATCH.end.y - z))
	return mud.lerp(Color("4e5a36"), clampf(1.0 - e / 9.0, 0.0, 1.0) * 0.85 + 0.15)


func _build_ground() -> void:
	# Esir alanının ve kapı önünün çiğnenmiş zemini; ötesi dünyanın arazisi (bölgenin altında düz, rampayla ovaya döner)
	var flat := func(_x: float, _z: float) -> float: return 0.0
	add_child(LowPoly.terrain(PATCH.position.x, PATCH.end.x, PATCH.position.y, PATCH.end.y, 22, 25, flat, _patch_color))
	_ground_wear()
	# Görünmez düz zemin (çarpışma): bölgenin oynanış alanı
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(KEEP.size.x, 1, KEEP.size.y)
	shape.shape = box
	shape.position = Vector3(KEEP.get_center().x, -0.5, KEEP.get_center().y)
	floor_body.add_child(shape)
	add_child(floor_body)


## Gece ordugâhının zemini (Nature.ground_detail, her tür tek çoklu ağ, çarpışmasız): esir alanında ve kapı
## önünde çiğnenmiş çamur, ayak izleri (çadırdan kapıya), saman (çadır ve saman yığını çevresi), ateş diplerinde kül ve
## kömür; çitin dışında at izleri, ot öbekleri ve taş. Eskiden tek renk koyu düz levhaydı.
func _ground_wear() -> void:
	var sy := func(x: float, z: float) -> float:
		return 0.0 if PATCH.has_point(Vector2(x, z)) else _gy(x, z)
	var pen := Rect2(-PEN_X + 0.3, PEN_Z0 + 0.3, PEN_X * 2.0 - 0.6, GATE_Z - PEN_Z0 + 13.0)
	var in_pen := func(x: float, z: float) -> bool: return absf(x) < PEN_X - 0.3 and z > PEN_Z0 + 0.3 and z < GATE_Z - 0.3
	var near_gate := func(x: float, z: float) -> bool: return absf(x) < 4.0 and z > GATE_Z - 4.0 and z < GATE_Z + 18.0
	var fires: Array = [Vector3(-6.0, 0, -1.0), Vector3(0, 0, GATE_Z + 2.2)]
	var ring := func(x: float, z: float, r0: float, r1: float) -> bool:
		for f: Vector3 in fires:
			var d := Vector2(x - f.x, z - f.z).length()
			if d > r0 and d < r1:
				return true
		return false
	Nature.ground_detail(self, pen, "camp_mud", 0.12, 4401, sy, func(x: float, z: float) -> bool: return in_pen.call(x, z) or near_gate.call(x, z))
	# Ayak izleri: çadırdan kapıya giden patika ve kapının önü (nöbet yeri)
	var lane := func(x: float, z: float) -> bool:
		var q := Geometry2D.get_closest_point_to_segment(Vector2(x, z), Vector2(TENT_SPAWN.x, TENT_SPAWN.z), Vector2(0, GATE_Z + 6.0))
		return q.distance_to(Vector2(x, z)) < 1.4 or bool(near_gate.call(x, z))
	Nature.ground_detail(self, pen, "footprint", 0.35, 4402, sy, lane)
	Nature.ground_detail(self, Rect2(-9.0, -11.0, 7.0, 6.0), "straw", 0.7, 4403, sy, in_pen)
	# Gece de seçilsin: alanın her yerine dağılmış saman çöpü ve çakıl (koyu çamur gece zeminde pek okunmuyor)
	Nature.ground_detail(self, pen, "straw", 0.16, 4410, sy, in_pen)
	Nature.ground_detail(self, pen, "pebble", 0.18, 4411, sy, func(x: float, z: float) -> bool: return in_pen.call(x, z) or near_gate.call(x, z))
	Nature.ground_detail(self, pen, "ash", 1.2, 4404, sy, func(x: float, z: float) -> bool: return ring.call(x, z, 0.5, 1.15))
	Nature.ground_detail(self, pen, "coal", 3.0, 4405, sy, func(x: float, z: float) -> bool: return ring.call(x, z, 0.5, 0.95))
	# Çitin dışı: at izleri ve çiğnenmiş toprak (ateşlerin ve atların çevresi), ot öbekleri, taş
	var outside := func(x: float, z: float) -> bool: return not (absf(x) < PEN_X + 0.5 and z > PEN_Z0 - 0.5 and z < GATE_Z + 0.5)
	var ground_out := Rect2(-34.0, -23.0, 68.0, 73.0)
	Nature.ground_detail(self, ground_out, "camp_mud", 0.035, 4406, sy, outside)
	Nature.ground_detail(self, ground_out, "hoofprint", 0.05, 4407, sy, outside)
	Nature.ground_detail(self, ground_out, "grass", 0.25, 4408, sy, func(x: float, z: float) -> bool:
		return bool(outside.call(x, z)) and not near_gate.call(x, z) and Vector2(x, z).length() > 14.0)
	Nature.ground_detail(self, ground_out, "stone", 0.02, 4409, sy, outside)


func _stake_line(a: Vector3, b: Vector3) -> void:
	var n := int(a.distance_to(b) / 0.42)
	for i in n + 1:
		var p := a.lerp(b, float(i) / maxf(1.0, n))
		var h := 2.4 + sin(i * 1.7) * 0.15
		Props.cyl(self, 0.16, h, p + Vector3(0, h / 2, 0), Color("5a4028"), Vector3(0, 0, sin(i * 2.3) * 2.0), 6)
		Props.cyl(self, 0.16, 0.3, p + Vector3(0, h + 0.15, 0), Color("6a4c30"), Vector3.ZERO, 6, 0.0)
	# Çarpışma: tek uzun kutu
	var mid := (a + b) / 2.0
	var len := a.distance_to(b)
	var body := StaticBody3D.new()
	body.position = mid + Vector3(0, 1.3, 0)
	body.rotation.y = atan2(b.x - a.x, b.z - a.z)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.35, 2.6, len)
	shape.shape = bs
	body.add_child(shape)
	add_child(body)


func _build_pen() -> void:
	_stake_line(Vector3(-PEN_X, 0, PEN_Z0), Vector3(PEN_X, 0, PEN_Z0))
	_stake_line(Vector3(-PEN_X, 0, PEN_Z0), Vector3(-PEN_X, 0, GATE_Z))
	_stake_line(Vector3(PEN_X, 0, PEN_Z0), Vector3(PEN_X, 0, GATE_Z))
	_stake_line(Vector3(-PEN_X, 0, GATE_Z), Vector3(-GATE_HALF, 0, GATE_Z))
	_stake_line(Vector3(GATE_HALF, 0, GATE_Z), Vector3(PEN_X, 0, GATE_Z))
	# Esir çadırı (üstünde "Frenk casusu" yazılı bir tahta)
	var t := Night.tent(self, TENT_SPAWN + Vector3(0, 0, -2.4), 2.0, Color("b8ad94"), Color("4a4038"))
	t.rotation.y = 0.0
	Props.box(self, Vector3(1.3, 0.35, 0.05), TENT_SPAWN + Vector3(0, 1.75, -0.35), Color("8a6a44"))
	Props.label(self, "FRENK CASUSU", TENT_SPAWN + Vector3(0, 1.75, -0.32), 30, Color("2a1a10"), Vector3.ZERO, 1.2)
	for i in 6:
		Props.box(self, Vector3(0.5, 0.08, 0.3), TENT_SPAWN + Vector3(-0.8 + (i % 3) * 0.6, 0.04, -1.0 - (i / 3) * 0.4), Color("c8a860"), Vector3(0, i * 25, 0))
	_fire(Vector3(-6.0, 0, -1.0), 0.8)
	# Siper: sandıklar ve fıçılar (nöbetçilerin görüşünü keser)
	var cover := [Vector3(-2.6, 0, 2.6), Vector3(2.8, 0, 3.4), Vector3(-5.5, 0, 3.0), Vector3(0.4, 0, -1.2), Vector3(4.5, 0, 0.8)]
	for i in cover.size():
		var p: Vector3 = cover[i]
		Props.solid(self, Vector3(1.2, 1.1, 0.9), p + Vector3(0, 0.55, 0), Color("8a6440"), Vector3(0, i * 17, 0))
		Props.box(self, Vector3(0.9, 0.8, 0.8), p + Vector3(0.2, 1.5, 0.05), Color("9a7448"), Vector3(0, i * 17 + 10, 0))
		Props.cyl(self, 0.35, 0.9, p + Vector3(-0.9, 0.45, 0.4), Color("6a4a2c"), Vector3.ZERO, 8)
		var barrel := StaticBody3D.new()
		barrel.position = p + Vector3(-0.9, 0.45, 0.4)
		var sh := CollisionShape3D.new()
		var cy := CylinderShape3D.new()
		cy.radius = 0.35
		cy.height = 0.9
		sh.shape = cy
		barrel.add_child(sh)
		add_child(barrel)


func _build_market() -> void:
	var awning := [Color("b3262d"), Color("2f5fa8"), Color("c98a3a"), Color("3a6b3a")]
	for i in 4:
		var p := Vector3(7.5, 0, -9.0 + i * 3.4)
		Props.solid(self, Vector3(1.4, 0.9, 2.4), p + Vector3(0, 0.45, 0), Color("7a5a38"))
		for k in 4:
			Props.cyl(self, 0.04, 2.2, p + Vector3(-0.65 + (k % 2) * 1.3, 1.1, -1.1 + (k / 2) * 2.2), Color("4a3020"), Vector3.ZERO, 4)
		Props.box(self, Vector3(1.8, 0.05, 2.8), p + Vector3(-0.2, 2.2, 0), awning[i], Vector3(0, 0, -10))
		# Örtülü mallar
		Props.box(self, Vector3(1.2, 0.3, 2.0), p + Vector3(0, 1.05, 0), Color("c8b894"), Vector3(0, 0, 3))
		for k in 3:
			Props.ball(self, 0.12, p + Vector3(-0.4 + k * 0.3, 1.25, 0.9), [Color("e0a020"), Color("b3262d"), Color("6a8a3a")][k], Vector3.ONE, 6)
	# Keçi ağılı ve saman
	Props.solid(self, Vector3(1.6, 0.9, 1.2), Vector3(-7.5, 0.45, -9.5), Color("c8a860"))      # saman yığını katı
	Props.box(self, Vector3(1.2, 0.6, 1.0), Vector3(-7.2, 1.2, -9.4), Color("d8b870"), Vector3(0, 20, 0))


func _build_gate() -> void:
	# Kapının dışındaki şerit (nöbetçilerin arası): yandan dolanıp kaçış çizgisini (ESCAPE_Z) geçmeden bütün ordugâha,
	# oradan dünyanın kenarına yürünüyordu. İki yanda görünmez duvar: kapıdan çıkan ileri, nöbetçilerin yanından geçer.
	if not far:
		for sx: float in [-1.0, 1.0]:
			var side := Props.solid(self, Vector3(0.3, 3.0, ESCAPE_Z - GATE_Z + 0.6), Vector3(sx * 4.2, 1.5, (GATE_Z + ESCAPE_Z) * 0.5 + 0.2), Color.WHITE)
			side.get_child(0).visible = false
			side.set_meta("no_climb", true)
	for sx: float in [-1.0, 1.0]:
		var tp := Vector3(sx * (GATE_HALF + 0.3), 0, GATE_Z + 0.2)
		if far:
			Props.cyl(self, 0.05, 2.6, tp + Vector3(0, 1.3, 0), Color("4a3020"), Vector3.ZERO, 5)
			_far_fires.append([tp + Vector3(0, _gy(tp.x, tp.z) + 2.66, 0), 0.3])
		else:
			lights.append(Night.torch(self, tp, 2.6))
	# Mangal
	Props.cyl(self, 0.35, 0.5, Vector3(0, 0.5, GATE_Z + 2.2), Color("3a3a3a"), Vector3.ZERO, 8, 0.45)
	_fire(Vector3(0, 0.75, GATE_Z + 2.2), 0.4)
	if far:
		_sign()
		return
	hasan = Soldier.new(Color("b3262d"), "stand", "bork")
	hasan.set_meta("spk", "SPK_HASAN")
	hasan.position = HASAN_POS
	hasan.rotation.y = PI
	add_child(hasan)
	huseyin = Soldier.new(Color("2f5fa8"), "stand", Soldier.huseyin_hat())
	huseyin.set_meta("spk", "SPK_HUSEYIN")
	huseyin.position = HUSEYIN_POS
	huseyin.rotation.y = PI
	add_child(huseyin)
	Props.interactable(self, "guards", Vector3(3.4, 2.0, 1.6), Vector3(0, 1.0, GATE_Z + 0.7))
	_sign()


## Tabela: otağa giden yol (otağ kapıdan çıkanın sağında, ordugâhın içinde)
func _sign() -> void:
	Props.cyl(self, 0.06, 2.4, Vector3(2.6, 1.2, GATE_Z + 7.0), Color("4a3020"), Vector3.ZERO, 5)
	Props.box(self, Vector3(1.6, 0.4, 0.06), Vector3(3.2, 2.1, GATE_Z + 7.0), Color("8a6a44"), Vector3(0, 180, -4))
	Props.label(self, "OTAĞ →", Vector3(3.2, 2.1, GATE_Z + 6.96), 40, Color("2a1a10"), Vector3(0, 180, -4), 1.3)


## Kamp ateşi: bölümde ateş, ışık ve titreme; uzak kurulumda yalnız alev ve hale (ışıksız)
func _fire(p: Vector3, size: float) -> void:
	if far:
		_far_fires.append([p + Vector3(0, _gy(p.x, p.z) + 0.1 * size, 0), size])
		return
	lights.append(Night.campfire(self, p, size))


## Çitin dışı: esir alanının çevresindeki çadırlar, ateş başındaki askerler, atlar ve arabalar. Daha ötesi dünyanın
## ordugâhıdır (World1453: çadır sıraları, binlerce ateş, otağ, kara surları ve şehir). Bölgenin dışına (KEEP) taşan
## çadır konmaz: orası dünyanın çadır ızgarası.
func _build_camp() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var colors := [Color("d8cbb0"), Color("c8b894"), Color("e0d4b8"), Color("b8a888")]
	var bands := [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a"), Color("c98a3a")]
	var inner := KEEP.grow(-3.0)
	for i in 34:
		var a := rng.randf_range(-PI * 0.95, PI * 0.95)
		var r := rng.randf_range(18.0, 60.0)
		var p := Vector3(sin(a) * r, 0, cos(a) * r + 8.0)
		if absf(p.x) < PEN_X + 3.0 and p.z < GATE_Z + 10.0:
			continue
		var rad := rng.randf_range(1.6, 2.6)
		var yaw := rng.randf() * TAU
		if not inner.has_point(Vector2(p.x, p.z)):
			continue
		p.y = _gy(p.x, p.z) - 0.08
		var t := Night.tent(self, p, rad, colors[i % 4], bands[i % 4])
		t.rotation.y = yaw
		t.set_meta("placed", true)
	for i in 7:
		var p := Vector3(rng.randf_range(-40, 40), 0, rng.randf_range(14, 50))
		if absf(p.x) < 6.0:
			p.x += 12.0
		_fire(p, 1.0)
		if far:
			continue
		# Ateş başında üç kişi: biri ayakta ısınır (ara sıra kıpırdanır), biri bağdaş kurmuş oturur, üçüncüsü (her ikinci
		# ateşte) ateşin üstündeki kazanı kepçeyle karıştırır (eskiden üçü de kıpırtısız dikiliyordu)
		var standing: Array = []
		for k in 3:
			var a := TAU * k / 3.0 + 0.4
			var at := p + Vector3(cos(a), 0, sin(a)) * 1.6
			var yaw := atan2(-cos(a), -sin(a))
			var coat: Color = [Color("b3262d"), Color("2f5fa8"), Color("3a6b3a")][k]
			if k == 2 and i % 2 == 0:
				Stage.station(self, "stir_pot", p + Vector3(cos(a), 0, sin(a)) * 0.8, -Vector3(cos(a), 0, sin(a)),
					{"fire": false, "person": false, "coat": coat, "hat": "bork", "seed": 4500 + i})
				continue
			if k == 1:
				var ps := Person.new({"coat": coat, "pants": Color("3a2a1e"), "hat": "turban", "mustache": true, "beard": i % 2 == 1})
				ps.position = p + Vector3(cos(a), 0, sin(a)) * 1.3
				ps.rotation.y = yaw
				add_child(ps)
				ps.set_activity("sit_ground")
				continue
			var s := Soldier.new(coat, "stand", "bork" if k != 1 else "turban")
			s.position = at
			s.rotation.y = yaw
			s.scale = Vector3(1, 0.8, 1)
			add_child(s)
			standing.append(s)
		Crowd.idle_vary(standing, {"every": Vector2(4.0, 10.0), "emotes": ["nod", "arms_cross", "shrug", "think", "laugh"]})
	# Çitin hemen dışı: bağlı atlar, arabalar, çuvallar, silah sehpaları (çitin arasından görünür; kaçış yolu açık kalır)
	var dd := Dressing.new(422)
	var spots := 0
	var tries := 0
	while spots < 16 and tries < 200:
		tries += 1
		var a := rng.randf() * TAU
		var r := rng.randf_range(13.0, 30.0)
		var p := Vector3(sin(a) * r, 0, cos(a) * r - 2.0)
		if absf(p.x) < 5.0 and p.z > GATE_Z - 2.0 and p.z < GATE_Z + 26.0:
			continue
		if absf(p.x) < PEN_X + 2.0 and p.z < GATE_Z + 2.0 and p.z > PEN_Z0 - 2.0:
			continue
		p.y = _y(p.x, p.z)
		dd.at(p, rng.randf() * TAU)
		match spots % 5:
			0: dd._c_horses()
			1: dd.cart(Vector3.ZERO)
			2: dd.sacks(Vector3.ZERO)
			3: dd.spear_rack(Vector3.ZERO)
			_: dd.barrels(Vector3.ZERO)
		spots += 1
	dd.build(self).set_meta("placed", true)
