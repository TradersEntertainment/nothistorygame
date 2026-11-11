class_name TrainingYard
extends Node3D
## Talim meydanı (Bölüm 41o: Osmanlı ordugâhında azapların talim yeri; 42b: surların içinde, iç surun ardındaki
## meydanda Giustiniani'nin talimi). Kendi düz zemini (sıkıştırılmış kum), ip çitli talim halkası, kazıkta saman kukla,
## silah sehpası, saman balyaları, su fıçısı, ok hedefleri ve talim iskelesi: 4,2 m yüksekliğinde ahşap bir sur parçası
## (ön yüzünde dayalı merdiven, arkasında rampa, üstünde tahta mazgallar ve korkuluk).
## Yerel eksenler: +z meydanın girişi (oyuncu oradan gelir), iskele -z ucunda; merdiven iskelenin ön (+z) yüzündedir.
##   side "O": yeşil-kırmızı sancak, hasır kalkanlar; "B": Ceneviz haçlı sancak, demir kalkanlar. Bizans tarafında
##   merdivenin devrileceği yerde saman balyaları (itilen merdivenden düşen talimci samana düşer).

const RING := Vector3(0.0, 0.0, 3.5)     # talim halkasının ortası
const RING_R := 4.6
const KUKLA := Vector3(-1.6, 0.0, 2.6)   # kazıktaki saman kukla
const DRILL_AT := Vector3(-1.6, 0.0, 4.7)  # kuklanın önünde oyuncunun durduğu yer
const PARTNER := Vector3(1.6, 0.0, 2.2)  # talim arkadaşının yeri (halkanın öbür yanı)
const TOWER := Vector3(0.0, 0.0, -9.0)   # iskelenin ortası
const TOWER_H := 4.2
const TOWER_W := 6.0
const TOWER_D := 2.4
const LADDER_H := 4.9
const LADDER_TILT := 15.0
const START := Vector3(0.0, 0.0, 10.5)
const WOOD := Color("7a5634")
const WOOD_D := Color("5a3e26")
const SAND := Color("8f7b56")           # sıkışmış toprak (açık kum gün ışığında bembeyaz parlıyordu)
const HAY := Color("d8b860")

var side := "O"
var ladder: Ladder
var kukla_root: Node3D           # kuklanın görüntüsü (Duelist'in gövdesi gizlidir; bu sallanır, devrilir)
var _guard_bar: Node3D           # kuklanın muhafız sopası (yönü gösterir)
var sparrers: Array[Duelist] = []
var _wobble := 0.0
var _wobble_dir := 1.0


func _init(p_side := "O") -> void:
	side = p_side
	name = "TrainingYard"


func _ready() -> void:
	_ground()
	_ring()
	_tower()
	_props()
	_bake_decor()


## Yerel → dünya
func at(local: Vector3) -> Vector3:
	return to_global(local)


# ================================================================ zemin, halka

func _ground() -> void:
	# Meydanın kum zemini: çevreden biraz yüksek, katı (eğimli ovada ya da kaldırımda düz talim alanı)
	var g := Props.solid(self, Vector3(24.0, 0.3, 28.0), Vector3(0, -0.13, -1.0), SAND)
	if side == "B":
		Props.set_pattern(g, Color("b8a888"), "flagstone")
	else:
		Props.set_pattern(g, SAND, "plaster")
	_ground_detail()


## Zemin ayrıntısı (yayma P5): halkanın içi çiğnenmiş (yumuşak kenarlı koyu yamalar, sık ayak izi), dışı seyrek iz,
## taş ve çakıl; kuklanın ve silah sehpasının dibinde kırık tahta kılıç yongaları, balyaların dibinde saman, ok
## hedeflerinin önünde yere saplı kırık oklar. Her tür tek çoklu ağ (eski 26 ayrı disk lekesinin yerine: çizim azalır).
## Seyrek, düzensiz (tekdüze rastgele); kum yüzeyin 2,5 cm üstünde (yamalar titremez).
func _ground_detail() -> void:
	var top := func(_x: float, _z: float) -> float: return 0.02
	var s0 := 4141 if side == "O" else 4242
	var in_ring := func(x: float, z: float) -> bool: return Vector2(x - RING.x, z - RING.z).length() < RING_R - 0.35
	var off_tower := func(x: float, z: float) -> bool:
		return not (absf(x - TOWER.x) < TOWER_W * 0.5 + 0.4 and z > TOWER.z - TOWER_D * 0.5 - 7.0 and z < TOWER.z + TOWER_D * 0.5 + 0.3)
	var outside := func(x: float, z: float) -> bool:
		return off_tower.call(x, z) and Vector2(x - RING.x, z - RING.z).length() > RING_R + 0.3
	var area := Rect2(-11.5, -14.5, 23.0, 27.0)
	# Tür başına tek çağrı (tek çoklu ağ): yoğunluk farkı keep'teki konuma bağlı seyreltmeyle (düzensiz, ızgarasız)
	var thin := func(x: float, z: float, keep_one_in: int) -> bool:
		return absi(hash(Vector2i(roundi(x * 37.0), roundi(z * 41.0)))) % keep_one_in == 0
	var ladder_foot := func(x: float, z: float) -> bool:
		return absf(x - TOWER.x) < 1.8 and z > TOWER.z + TOWER_D * 0.5 + 0.4 and z < TOWER.z + TOWER_D * 0.5 + 4.6
	# Halkanın içi (dövüşülen yer) ve merdivenin dibi çok çiğnenmiş; kalan meydan seyrek
	Nature.ground_detail(self, area, "camp_mud", 0.25, s0 + 1, top, func(x: float, z: float) -> bool:
		return off_tower.call(x, z) and (ladder_foot.call(x, z) or (in_ring.call(x, z) and thin.call(x, z, 3))))
	# Ayak izi ağı 342 üçgen: halkada seyrek, dışında daha seyrek (iskelenin tepesinden bakınca bütün meydan kadrajda)
	Nature.ground_detail(self, area, "footprint", 0.4, s0 + 2, top, func(x: float, z: float) -> bool:
		return in_ring.call(x, z) or (outside.call(x, z) and thin.call(x, z, 12)))
	Nature.ground_detail(self, area, "pebble", 0.12, s0 + 5, top, off_tower)
	# Kırık tahta kılıç / sopa yongaları: kuklanın dibi, silah sehpası
	var chips_a := Rect2(KUKLA.x - 1.0, KUKLA.z - 0.9, 2.0, 1.8)
	var chips_b := Rect2(RING.x + RING_R + 0.7, RING.z - 1.8, 1.6, 2.6)
	Nature.ground_detail(self, chips_a.merge(chips_b), "chips", 2.0, s0 + 7, top, func(x: float, z: float) -> bool:
		return chips_a.has_point(Vector2(x, z)) or (chips_b.has_point(Vector2(x, z)) and thin.call(x, z, 2)))
	# Saman: balyaların dibi ve Bizans'ta merdivenin düştüğü balyalar
	var straw_a := Rect2(RING.x - RING_R - 2.6, RING.z - 2.0, 2.2, 2.4)
	var straw_b := Rect2(TOWER.x - 2.2, TOWER.z + TOWER_D * 0.5 + 2.6, 4.4, 3.4) if side == "B" else straw_a
	Nature.ground_detail(self, straw_a.merge(straw_b), "straw", 1.3, s0 + 9, top, func(x: float, z: float) -> bool:
		return straw_a.has_point(Vector2(x, z)) or straw_b.has_point(Vector2(x, z)))
	# Ok hedeflerinin önü ve ardı: yere saplanmış kırık oklar
	Nature.ground_detail(self, Rect2(-10.0, -6.5, 3.0, 6.0), "arrows", 0.8, s0 + 11, top)


## Meydanın duran, desensiz dekoru tek ağlara birleşir (Props.bake_static): eklenen zemin ayrıntısı çizim sayısını
## artırmasın. Yalnız sıkı kümeler: iskele (rampa basamakları, direkler, kuşaklar), silah sehpası, balyalar ve fıçı
## (iki ok hedefi arası açık: birleşmez). Küme kutusu gerçek nesneyi aşmaz (geniş kutulu birleşik ağ, görüş denetiminde konuşanı "örtüyor",
## iskeleden bakarken meydanın öbür ucunu da çizdiriyordu). Desenli (ahşap dokulu) parçalar, çarpışma gövdeleri, düello
## kamerasının gizlediği çit parçaları ("cam_fence"), merdiven ve kukla birleşmez.
func _bake_decor() -> void:
	var rack := RING + Vector3(RING_R + 1.4, 0, -0.5)
	var bales := RING + Vector3(-RING_R - 1.5, 0, 0.6)
	var groups := [[], [], [], []]
	for c in get_children():
		var mi := c as MeshInstance3D
		if mi == null or mi.is_in_group("cam_fence") or not mi.visible:
			continue
		var m := mi.material_override as StandardMaterial3D
		if m == null or m.albedo_texture != null:
			continue
		var p := mi.position
		if absf(p.x - TOWER.x) < TOWER_W * 0.5 + 0.3 and p.z < TOWER.z + TOWER_D * 0.5 + 0.4 and p.z > TOWER.z - TOWER_D * 0.5 - 7.0:
			groups[0].append(mi)
		elif Vector2(p.x - rack.x, p.z - rack.z).length() < 1.6:
			groups[1].append(mi)
		elif Vector2(p.x - bales.x, p.z - bales.z).length() < 1.9:
			groups[3].append(mi)
	for g: Array in groups:
		if not g.is_empty():
			Props.bake_static(self, g)


func _ring() -> void:
	# İp çit: sekiz kazık, aralarında sarkan ip; girişte (+z) açıklık
	var n := 10
	var posts: Array[Vector3] = []
	for i in n:
		var a := TAU * i / n + PI * 0.5 + TAU / n * 0.5
		posts.append(RING + Vector3(cos(a) * RING_R, 0, sin(a) * RING_R))
	# Kazıklar ve ip ince dekor (çarpışmasız): bitirici kamerası açı seçerken saysın, dibine düşeni gizlesin ("cam_fence")
	for p in posts:
		for k: Node3D in [Props.cyl(self, 0.06, 1.1, p + Vector3(0, 0.55, 0), WOOD_D, Vector3.ZERO, 6),
				Props.ball(self, 0.07, p + Vector3(0, 1.1, 0), WOOD, Vector3.ONE, 6)]:
			_fence_piece(k, p, p + Vector3(0, 1.17, 0))
	# İp (yayma P5): her kazığa iki tur sarılır, iki kazık arasında kendi ağırlığıyla sarkar (eski: kazıktan kazığa
	# gerili düz çubuk). Oyuncunun hep yakınında: yuvarlak kesitli ince boru, dış çizgisiz (ThraceRoad.tube_material).
	# Her açıklık ayrı düğüm: düello kamerası önüne düşen parçayı gizler ("cam_fence").
	var open := func(i: int) -> bool:
		return (posts[i] + posts[(i + 1) % n]).z * 0.5 > RING.z + RING_R * 0.85      # girişte ip yok (+z yüzü)
	for i in n:
		if open.call(i):
			continue
		var a: Vector3 = posts[i]
		var b: Vector3 = posts[(i + 1) % n]
		var pts := _fence_rope_points(a, b, true, open.call((i + 1) % n))
		var mi := MeshInstance3D.new()
		mi.name = "FenceRope"
		mi.mesh = _tube(pts, ROPE_R, ROPE_COL)
		mi.material_override = ThraceRoad.tube_material()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_walk", true)
		add_child(mi)
		_fence_piece(mi, a + Vector3(0, ROPE_Y, 0), b + Vector3(0, ROPE_Y, 0))


const ROPE_Y := 0.88
const ROPE_R := 0.014
const ROPE_COL := Color("b49a6c")
const POST_R := 0.06


## Bir açıklığın ipi (yerel noktalar): a kazığına iki tur sarım (aşağıdan yukarı, son tur b'ye dönük biter), oradan
## b kazığına sarkan kavis; b'de ip bitiyorsa (giriş) b'ye de bir buçuk tur sarılır.
func _fence_rope_points(a: Vector3, b: Vector3, wrap_a: bool, wrap_b: bool) -> Array:
	var d := Vector3(b.x - a.x, 0, b.z - a.z)
	var span := d.length()
	d = d.normalized()
	var rr := POST_R + ROPE_R * 0.9
	var ang_b := atan2(d.z, d.x)            # a'dan b'ye yön (x-z açısı)
	var pts: Array = []
	if wrap_a:
		var turns := 2.0
		var steps := int(turns * 10.0)
		for k in steps + 1:
			var t := float(k) / steps
			var ang := ang_b + (1.0 - t) * turns * TAU + PI * 0.5 * t
			pts.append(a + Vector3(cos(ang) * rr, ROPE_Y - 0.07 + t * 0.07, sin(ang) * rr))
	var from := a + Vector3(0, ROPE_Y, 0) + d * rr
	var to := b + Vector3(0, ROPE_Y, 0) - d * rr
	if not pts.is_empty():
		from = pts[-1]
	if wrap_b:          # sarıma yandan, teğet girer
		to = b + Vector3(cos(ang_b + PI * 0.5) * rr, ROPE_Y, sin(ang_b + PI * 0.5) * rr)
	var sag := 0.035 * span + 0.03            # 3 m açıklıkta ~13 cm
	var n := 14
	for k in range(1 if not pts.is_empty() else 0, n + 1):
		var t := float(k) / n
		pts.append(from.lerp(to, t) + Vector3.DOWN * sag * 4.0 * t * (1.0 - t))
	if wrap_b:
		var ang_a := ang_b + PI
		var steps := 15
		for k in range(1, steps + 1):
			var t := float(k) / steps
			var ang := ang_a - PI * 0.5 * (1.0 - t) - t * 1.5 * TAU
			pts.append(b + Vector3(cos(ang) * rr, ROPE_Y - t * 0.06, sin(ang) * rr))
	return pts


## Yuvarlak kesitli ip borusu (8 köşe, ~8 cm'de bir halka): ThraceRoad.tube_mesh'in hafif hâli (çit ipi uzun; aynı
## sarım yönü: üçgenler dışa dönük, arka yüz ayıklanır). Ton farkı hafif sarmal burgu.
static func _tube(pts: Array, r: float, col: Color) -> ArrayMesh:
	var q: Array = [pts[0]]
	for i in range(1, pts.size()):
		var a: Vector3 = q[-1]
		var b: Vector3 = pts[i]
		var m := maxi(1, int(ceil(a.distance_to(b) / 0.08)))
		for k in range(1, m + 1):
			q.append(a.lerp(b, float(k) / m))
	const SIDES := 8
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array = []
	var along := 0.0
	var prev_side := Vector3.ZERO
	for i in q.size():
		var p: Vector3 = q[i]
		var t: Vector3 = ((q[mini(i + 1, q.size() - 1)] as Vector3) - (q[maxi(i - 1, 0)] as Vector3)).normalized()
		if i > 0:
			along += p.distance_to(q[i - 1])
		var side := t.cross(Vector3.UP) if absf(t.y) < 0.95 else t.cross(Vector3.RIGHT)
		if prev_side != Vector3.ZERO:
			side = side - t * side.dot(t)
			side = side if side.dot(prev_side) >= 0.0 else -side
		side = side.normalized()
		prev_side = side
		var up := side.cross(t).normalized()
		var ring: Array = []
		for k in SIDES:
			var a := TAU * k / SIDES
			var nrm := side * cos(a) + up * sin(a)
			var shade := 0.84 + 0.16 * (0.5 + 0.5 * sin(a * 2.0 + along * 60.0))
			ring.append([p + nrm * r, nrm, Color(col.r * shade, col.g * shade, col.b * shade)])
		rings.append(ring)
	for i in rings.size() - 1:
		for k in SIDES:
			var k2 := (k + 1) % SIDES
			for v: Array in [rings[i][k], rings[i][k2], rings[i + 1][k], rings[i][k2], rings[i + 1][k2], rings[i + 1][k]]:
				st.set_color(v[2])
				st.set_normal(v[1])
				st.add_vertex(v[0])
	return st.commit()


## İnce dekor parçası: Duel'in öldürme kamerası için uçları (seg_a, seg_b; ebeveyninin, yani talim alanının uzayında)
func _fence_piece(n: Node3D, a: Vector3, b: Vector3) -> void:
	n.add_to_group("cam_fence")
	n.set_meta("seg_a", a)
	n.set_meta("seg_b", b)


# ================================================================ talim iskelesi

## Ahşap sur parçası: dört direk, kalın tahta yüz (katı), üstte yürüme döşemesi ve tahta mazgallar; arkada rampa
## (basamak tahtalarıyla); ön yüzde dayalı merdiven.
func _tower() -> void:
	var c := TOWER
	var hx := TOWER_W * 0.5
	var hz := TOWER_D * 0.5
	var top := TOWER_H
	# Gövde: kalın tahta duvar (katı, oyuncu içinden geçmez); önü ve yanları tahta kaplı
	var body := Props.solid(self, Vector3(TOWER_W, top, TOWER_D), c + Vector3(0, top * 0.5, 0), WOOD)
	Props.set_pattern(body, WOOD, "wood")
	for k in 7:
		var x := -hx + 0.2 + k * (TOWER_W - 0.4) / 6.0
		Props.box(self, Vector3(0.22, top + 0.1, 0.22), c + Vector3(x, top * 0.5, hz + 0.06), WOOD_D)
	for y: float in [1.2, 2.6, 3.9]:
		Props.box(self, Vector3(TOWER_W + 0.1, 0.16, 0.1), c + Vector3(0, y, hz + 0.14), WOOD_D)
	# Döşeme ve mazgallar (ön yüzde, merdivenin geldiği yerde açık)
	Props.box(self, Vector3(TOWER_W + 0.3, 0.14, TOWER_D + 0.3), c + Vector3(0, top + 0.07, 0), WOOD_D)
	for k in 6:
		var x := -hx + 0.5 + k * (TOWER_W - 1.0) / 5.0
		if absf(x) < 0.7:
			continue          # merdivenin başı: mazgal yok
		var m := Props.solid(self, Vector3(0.7, 0.9, 0.14), c + Vector3(x, top + 0.59, hz + 0.05), WOOD)
		Props.set_pattern(m, WOOD, "wood")
	# Yanlarda ve arkada korkuluk (alçak: üstten bakan görür)
	for s: float in [-1.0, 1.0]:
		Props.solid(self, Vector3(0.12, 0.8, TOWER_D), c + Vector3(s * (hx - 0.06), top + 0.54, 0), WOOD_D)
	# Arkada rampa: yerden döşemeye (basamak tahtaları üstünde), korkuluklu
	var back_z := c.z - hz
	var r := Props.ramp(self, c + Vector3(hx - 0.8, top + 0.14, -hz + 0.2), c + Vector3(hx - 0.8, 0.02, -hz - 6.4), 1.5, WOOD)
	Props.set_pattern(r, WOOD, "wood")
	for k in 14:
		var u := (k + 0.5) / 14.0
		var p := c + Vector3(hx - 0.8, lerpf(top + 0.14, 0.02, u) + 0.05, lerpf(-hz + 0.2, -hz - 6.4, u))
		Props.box(self, Vector3(1.5, 0.05, 0.1), p, WOOD_D)
	Props.box(self, Vector3(0.08, 0.08, 7.0), c + Vector3(hx - 0.02, top * 0.5 + 0.9, -hz - 3.1), WOOD_D, Vector3(-rad_to_deg(atan2(top, 6.6)), 0, 0))
	# Döşemenin arka kenarı rampaya açılır; rampanın olmadığı yerde korkuluk
	Props.solid(self, Vector3(TOWER_W - 1.7, 0.8, 0.12), c + Vector3(-0.85, top + 0.54, -hz + 0.06), WOOD_D)
	# Sancak (iskelenin köşesinde)
	_banner(c + Vector3(-hx + 0.3, top, hz - 0.3))
	# Ön yüzde dayalı merdiven: dibi meydanda, tepesi döşemenin kenarında
	ladder = Ladder.new(LADDER_H, LADDER_TILT, Color("6a4a2c"))
	ladder.name = "DrillLadder"
	add_child(ladder)
	var lean := LADDER_H * sin(deg_to_rad(LADDER_TILT))
	ladder.position = c + Vector3(0, 0, hz + lean + 0.12)     # önü (+Z yereli) meydana bakar, tepesi iskeleye (-z) yaslanır
	# Bizans: merdivenin devrileceği yerde saman balyaları
	if side == "B":
		for k in 4:
			var bp := c + Vector3(-1.0 + (k % 2) * 2.0, 0.35, hz + 3.6 + (k / 2) * 1.3)
			_bale(bp, k * 0.3)


## Merdivenin dibinde oyuncunun durduğu yer (yerel): tırmanmak için merdivene dönük
func ladder_foot() -> Vector3:
	var lean := LADDER_H * sin(deg_to_rad(LADDER_TILT))
	return TOWER + Vector3(0, 0, TOWER_D * 0.5 + lean + 1.0)


## İskelenin üstünde merdivenin başı (yerel): itmek için durulan yer
func ladder_head() -> Vector3:
	return TOWER + Vector3(0, TOWER_H + 0.15, TOWER_D * 0.5 - 0.6)


func _banner(p: Vector3) -> void:
	Props.cyl(self, 0.04, 2.8, p + Vector3(0, 1.4, 0), WOOD_D, Vector3.ZERO, 6)
	var cloth := Node3D.new()
	cloth.position = p + Vector3(0.45, 2.35, 0)
	add_child(cloth)
	if side == "O":
		Props.box(cloth, Vector3(0.85, 0.6, 0.02), Vector3.ZERO, Color("2f6a3a"))
		Props.box(cloth, Vector3(0.85, 0.12, 0.025), Vector3(0, -0.24, 0), Color("b3262d"))
	else:
		Props.box(cloth, Vector3(0.85, 0.6, 0.02), Vector3.ZERO, Color("f2ede0"))
		Props.box(cloth, Vector3(0.85, 0.12, 0.025), Vector3.ZERO, Color("b3262d"))
		Props.box(cloth, Vector3(0.12, 0.6, 0.025), Vector3.ZERO, Color("b3262d"))


func _bale(p: Vector3, yaw: float) -> void:
	Props.solid(self, Vector3(1.2, 0.7, 0.8), p, HAY, Vector3(0, rad_to_deg(yaw) * 0.2, 0))
	for s: float in [-0.3, 0.3]:
		Props.box(self, Vector3(0.03, 0.72, 0.82), p + Vector3(s, 0, 0), Color("8a6a3a"), Vector3(0, rad_to_deg(yaw) * 0.2, 0))


# ================================================================ meydanın eşyası

func _props() -> void:
	# Silah sehpası: tahta kılıçlar, mızraklar, kalkanlar (halkanın sağında)
	var rk := RING + Vector3(RING_R + 1.4, 0, -0.5)
	for s: float in [-0.8, 0.8]:
		Props.cyl(self, 0.05, 1.5, rk + Vector3(0, 0.75, s), WOOD_D, Vector3.ZERO, 6)
	Props.box(self, Vector3(0.1, 0.1, 1.8), rk + Vector3(0, 1.35, 0), WOOD_D)
	Props.box(self, Vector3(0.1, 0.1, 1.8), rk + Vector3(0, 0.45, 0), WOOD_D)
	for k in 5:
		var z := -0.6 + k * 0.3
		Props.box(self, Vector3(0.04, 1.0, 0.07), rk + Vector3(0.08, 0.95, z), WOOD, Vector3(0, 0, -8))     # tahta kılıç
		Props.box(self, Vector3(0.05, 0.05, 0.22), rk + Vector3(0.08, 0.6, z), WOOD_D, Vector3(0, 0, -8))
	for k in 3:
		var sp := rk + Vector3(-0.2, 0.0, -1.2 + k * 0.2)
		Props.cyl(self, 0.022, 2.6, sp + Vector3(0, 1.3, 0), WOOD, Vector3(6, 0, 0), 5)
		Props.cyl(self, 0.03, 0.22, sp + Vector3(0, 2.6, 0.14), Color("8a8e96"), Vector3(6, 0, 0), 5, 0.002)
	var sh_col := Color("66502f") if side == "O" else Color("7a2a24")
	for k in 3:
		var shp := rk + Vector3(0.35, 0.4, 0.9 + k * 0.05)
		Props.cyl(self, 0.32, 0.05, shp + Vector3(0, 0, k * 0.05), sh_col.darkened(k * 0.08), Vector3(90, 70, 0), 14)
	# Saman balyaları ve su fıçısı (halkanın solunda); oturup bekleyenler için
	for k in 3:
		_bale(RING + Vector3(-RING_R - 1.6, 0.35 + (0.7 if k == 2 else 0.0), -1.0 + (k % 2) * 1.0 if k < 2 else -0.5), k * 0.4)
	var bar := RING + Vector3(-RING_R - 1.4, 0, 2.2)
	Props.cyl(self, 0.38, 0.95, bar + Vector3(0, 0.48, 0), WOOD_D, Vector3.ZERO, 12)
	Props.cyl(self, 0.35, 0.02, bar + Vector3(0, 0.94, 0), Color("4a6a7a"), Vector3.ZERO, 12)
	Props.box(self, Vector3(0.08, 0.04, 0.5), bar + Vector3(0.2, 0.98, 0), WOOD, Vector3(0, 30, 0))
	# Ok hedefleri (meydanın sol arkasında, iki saman hedef)
	for k in 2:
		var tp := Vector3(-8.5, 0, -2.0 - k * 3.0)
		Props.box(self, Vector3(0.12, 1.6, 0.12), tp + Vector3(0, 0.8, -0.3), WOOD_D, Vector3(-15, 0, 0))
		Props.cyl(self, 0.6, 0.25, tp + Vector3(0, 1.1, 0), HAY, Vector3(80, 90, 0), 16)
		Props.cyl(self, 0.4, 0.26, tp + Vector3(0, 1.1, 0), Color("f2ede0"), Vector3(80, 90, 0), 16)
		Props.cyl(self, 0.18, 0.27, tp + Vector3(0, 1.1, 0), Color("b3262d"), Vector3(80, 90, 0), 12)


# ================================================================ saman kukla

## Kazıktaki saman kukla: hedef olan Duelist'in gövdesi gizlenir, yerine bu görünür. Kollar çapraz sopa; muhafız
## sopası (sol / sağ / üst) kuklanın tuttuğu yönü gösterir. Darbede sallanır, bitiricide devrilir.
func make_kukla(look_side: String) -> Duelist:
	var d := Duelist.new({"coat": Color("c8a860"), "pants": Color("a88a50"), "hat": ""}, "kilij" if look_side == "O" else "spathion", 0.3, false)
	d.name_key = "SPK_KUKLA"
	d.drill = true
	d.pinned = true
	d.drill_guard = Duelist.DIR_TOP
	d.max_hp = 99999.0
	d.hp = d.max_hp
	d.damage = 0.0
	d.set_meta("kukla", true)
	d.set_meta("no_finish", true)        # bitirici yalnız kendi dersinde (yön dersinde üç darbeyle sersemleyen kukla bitiriliyordu)
	d.position = KUKLA
	add_child(d)
	d.global_position = at(KUKLA)
	d.rotation.y = 0.0
	d.body.visible = false
	d.body.set_meta("no_audit", true)
	kukla_root = Node3D.new()
	kukla_root.name = "Kukla"
	d.add_child(kukla_root)
	# Ayak: çapraz tahta; kazık; gövde (çuval, iple bağlı); baş (çuval, kömürle yüz); kollar (çapraz sopa)
	for r: float in [0.0, 90.0]:
		Props.box(d, Vector3(0.9, 0.1, 0.12), Vector3(0, 0.05, 0), WOOD_D, Vector3(0, r, 0))
	var sway := Node3D.new()
	sway.name = "Sway"
	kukla_root.add_child(sway)
	Props.cyl(sway, 0.05, 1.9, Vector3(0, 0.95, 0), WOOD_D, Vector3.ZERO, 6)
	Props.cyl(sway, 0.23, 0.75, Vector3(0, 1.15, 0), HAY, Vector3.ZERO, 10, 0.2)
	Props.cyl(sway, 0.245, 0.04, Vector3(0, 0.95, 0), Color("8a6a3a"), Vector3.ZERO, 10)
	Props.cyl(sway, 0.215, 0.04, Vector3(0, 1.35, 0), Color("8a6a3a"), Vector3.ZERO, 10)
	Props.box(sway, Vector3(1.1, 0.07, 0.07), Vector3(0, 1.42, 0), WOOD)
	Props.ball(sway, 0.17, Vector3(0, 1.72, 0), Color("c8b080"), Vector3(1.0, 1.1, 1.0), 10)
	for sx: float in [-0.06, 0.06]:
		Props.ball(sway, 0.022, Vector3(sx, 1.75, 0.155), Color("2a2622"), Vector3.ONE, 6)
	Props.box(sway, Vector3(0.12, 0.018, 0.02), Vector3(0, 1.67, 0.16), Color("2a2622"))       # kömürle bıyık
	# Muhafız sopası: ön kolda, yönü drill_guard'a göre döner
	_guard_bar = Node3D.new()
	_guard_bar.position = Vector3(0, 1.4, 0.22)
	sway.add_child(_guard_bar)
	Props.box(_guard_bar, Vector3(0.08, 0.08, 0.95), Vector3(0, 0, 0), Color("4a6a9a"))
	Props.box(_guard_bar, Vector3(0.1, 0.1, 0.1), Vector3(0, 0, 0.5), Color("2a2622"))
	set_guard_visual(Duelist.DIR_TOP)
	return d


## Kuklanın muhafız sopası: soldan gelene karşı sol (oyuncunun solu), sağ, ya da başın üstünde yatay
func set_guard_visual(dir: int) -> void:
	if _guard_bar == null:
		return
	var tw := _guard_bar.create_tween()
	var rot := Vector3(0, 0, 0)
	var pos := Vector3(0, 1.4, 0.22)
	match dir:
		Duelist.DIR_TOP:
			rot = Vector3(0, 90, 0)
			pos = Vector3(0, 1.98, 0.12)
		Duelist.DIR_LEFT:
			rot = Vector3(-80, 0, 0)
			pos = Vector3(-0.36, 1.45, 0.15)     # kukla oyuncuya dönük (+z yereli ona bakar): oyuncunun solu yerel -x
		Duelist.DIR_RIGHT:
			rot = Vector3(-80, 0, 0)
			pos = Vector3(0.36, 1.45, 0.15)
	tw.set_parallel(true)
	tw.tween_property(_guard_bar, "rotation_degrees", rot, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_property(_guard_bar, "position", pos, 0.25).set_trans(Tween.TRANS_BACK)


## Darbe yedi: kukla vuruşun yönüne sallanır (seken darbede az)
func kukla_hit(dir: int, hard := true) -> void:
	_wobble = 0.35 if hard else 0.12
	_wobble_dir = -1.0 if dir == Duelist.DIR_LEFT else (1.0 if dir == Duelist.DIR_RIGHT else 0.0)
	Audio.sfx_at("land_thud" if hard else "kick_metal", kukla_root, -8.0 if hard else -10.0)
	if hard:
		Vfx.dust(self, to_local(kukla_root.global_position) + Vector3(0, 1.2, 0), 0.25)


## Bitirici: kukla kazığından kırılıp devrilir, saman saçılır
func kukla_fall() -> void:
	if kukla_root == null:
		return
	var sw := kukla_root.get_node_or_null("Sway") as Node3D
	if sw == null:
		return
	_wobble = 0.0
	var tw := sw.create_tween()
	tw.tween_property(sw, "rotation:x", -1.45, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		Audio.sfx_at("land_thud", kukla_root, -2.0)
		Vfx.dust(self, to_local(kukla_root.global_position) + Vector3(0, 0.2, -1.2), 0.6))


## Kukla yeniden dikilir (bir sonraki talim için)
func kukla_raise() -> void:
	var sw := kukla_root.get_node_or_null("Sway") as Node3D if kukla_root else null
	if sw:
		sw.create_tween().tween_property(sw, "rotation", Vector3.ZERO, 0.5).set_trans(Tween.TRANS_SINE)


func _process(delta: float) -> void:
	# Talim eden çiftler meydandan uzaklaşmaz (yan adımlarla kayıp gidiyorlardı): evinden 2,5 m'yi geçen geri çekilir
	for d in sparrers:
		if not is_instance_valid(d) or not d.has_meta("home"):
			continue
		var home: Vector3 = d.get_meta("home")
		var off := d.global_position - home
		off.y = 0.0
		if off.length() > 2.5:
			d.global_position -= off.normalized() * minf(off.length() - 2.5, delta * 2.0)
	if kukla_root == null or not is_instance_valid(kukla_root):
		return
	var sw := kukla_root.get_node_or_null("Sway") as Node3D
	if sw == null or sw.rotation.x < -0.3:
		return
	_wobble = move_toward(_wobble, 0.0, delta * 0.6)
	var t := Time.get_ticks_msec() * 0.001
	var a := sin(t * 14.0) * _wobble
	sw.rotation.z = a * _wobble_dir if _wobble_dir != 0.0 else 0.0
	sw.rotation.x = -absf(a) * (0.6 if _wobble_dir == 0.0 else 0.25)


# ================================================================ arka planda talim yapan çiftler

## Meydanın kenarında iki asker tahta kılıçla talim eder: gerçek düello yapay zekâsı (yön, siper, karşılama), kan yok,
## can gitmez. at: çiftin ortası (yerel), looks: iki kıyafet.
func add_sparring_pair(local: Vector3, looks: Array, blade: String) -> Array[Duelist]:
	var pair: Array[Duelist] = []
	for i in 2:
		var d := Duelist.new(looks[i], blade, 0.55 + i * 0.1, i == 0)
		d.practice = true
		d.max_hp = 99999.0
		d.hp = d.max_hp
		d.damage = 0.0
		d.set_meta("no_talk", true)
		add_child(d)
		d.global_position = at(local + Vector3(-1.1 + i * 2.2, 0, 0))
		d.set_meta("home", d.global_position)
		pair.append(d)
		sparrers.append(d)
	pair[0].target = pair[1]
	pair[1].target = pair[0]
	for d in pair:
		woodify(d.sword)
	return pair


## Kılıcı tahta kılıca çevirir (talimde gerçek kılıç kullanılmaz)
static func woodify(n: Node) -> void:
	if n == null:
		return
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("9a7448")
	m.roughness = 0.9
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).material_override = m
