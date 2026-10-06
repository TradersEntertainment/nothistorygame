class_name LivePortrait
extends SubViewport
## Konuşma kartının canlı portresi: konuşan karakter sahnedeyse küçük bir kamera onun yüzünü çeker. Kart böylece
## karakterin oyundaki hâliyle aynıdır (miğfer, zırh, is, sarık) ve ağzı sesle birlikte oynar. Karakter sahnede
## yoksa (telsiz, uzak ses) Hud aynı görünüşle stüdyoda kurulan kopyasını gösterir (PortraitStudio).

## Kameranın yüze uzaklığı ve bakılan noktanın baş düğümünden yüksekliği: baş, başlığın tepesi ve omuz çizgisi
## kareye girer (stüdyo portresi de aynı kadrajı kullanır)
const DIST := 1.32
const AIM_UP := Vector3(0, 0.06, 0)
## Kartta başın çevresinde görünmesi gereken yarıçap (DIST uzaklığında karenin yarısından biraz az)
const FRAME := 0.2
## Açı seçerken kişilerden bırakılan pay: kıl payı açık açı, kişiler hafifçe sallanınca (rastgele faz) kapanıyordu; CI'da
## PORTRAITCHECK bu yüzden düştü (yerelde 200 denemede 15). Önce payla açık açı aranır, hiçbiri yoksa paysız.
const PAD := 0.05

var target: Node3D
var box: Control          # altyazı kutusu: kapanınca çekim durur
var _cam: Camera3D
var _swing := Vector2(0.0, 1.0)     # yüzün önü kapalıysa: başın çevresindeki açı ve uzaklık çarpanı (swing)
var _check_t := 0.0


func _init() -> void:
	size = Vector2i(224, 224)
	own_world_3d = false
	transparent_bg = false
	render_target_update_mode = SubViewport.UPDATE_DISABLED
	msaa_3d = Viewport.MSAA_2X
	_cam = Camera3D.new()
	_cam.fov = 24.0
	_cam.near = 0.05
	_cam.far = 400.0
	add_child(_cam)


## Kişinin baş düğümü (Rig.head) ya da gövdenin 1.6 m yukarısı.
static func head_of(n: Node3D) -> Vector3:
	var r = n.get("rig")
	if r is Rig and (r as Rig).head and (r as Rig).head.is_inside_tree():
		return (r as Rig).head.global_position + Vector3(0, 0.02, 0)
	return n.global_position + Vector3(0, 1.6, 0)


## Hedefi ayarla; true: portre kullanılabilir.
func show_for(n: Node3D, main: Viewport) -> bool:
	target = n
	if n == null or not is_instance_valid(n) or not n.is_inside_tree():
		stop()
		return false
	world_3d = main.world_3d
	_check_t = 0.0
	_place()
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	return true


func stop() -> void:
	target = null
	render_target_update_mode = SubViewport.UPDATE_DISABLED


func _process(delta: float) -> void:
	if target == null:
		return
	if not is_instance_valid(target) or not target.is_inside_tree() or (box and not box.visible):
		stop()
		return
	_check_t -= delta
	_place()


## Kamera yüzün önünde (DIST), hafif yandan ve göz hizasının biraz üstünden (ortak "görüntülü arama" açısı).
func _place() -> void:
	var p := pose(target)
	if _check_t <= 0.0:
		_check_t = 0.25
		_swing = swing(target, p)
	_cam.global_position = swung(p, _swing)
	_cam.look_at(p[1], p[2])


## Kartın kamerası: [konum, bakılan nokta, yukarı yönü]. Hud'un görüş denetimi de aynısını kullanır.
## Yatan konuşan (kirişin altındaki azap, kızaktaki yaralı, vurulup taşınan Giustiniani): kamera yüzün üstünde, başın tepesi
## karenin üstünde (eskiden yerden yatay bakıyor, kartta yan yatmış, yarısı zemine gömülü bir kafa görünüyordu).
static func pose(n: Node3D) -> Array:
	var b := n.global_transform.basis.orthonormalized()
	if b.y.y < 0.5:
		var face := b.z if b.z.y > -0.2 else Vector3.UP      # yüzüstü yatıyorsa tepeden
		var hl := head_of(n) + b.y * AIM_UP.y
		return [hl + face.normalized() * DIST + b.y * 0.06, hl, b.y]
	var h := head_of(n) + AIM_UP
	var fwd := b.z
	fwd.y = 0.0
	fwd = fwd.normalized() if fwd.length() > 0.01 else Vector3.BACK
	var side := fwd.cross(Vector3.UP).normalized()
	return [h + fwd * DIST + side * 0.18 + Vector3(0, 0.06, 0), h, Vector3.UP]


## Yüzün önü görünen bir engelle kapalıysa (tünelde yan duvara dönük lağımcı, duvar dibindeki konuşan) kamera başın
## çevresinde döner ve gerekirse yaklaşır. Önce oyuncunun gözünün tarafı (oyuncu onu görüyorsa arası açıktır; kamera
## oyuncunun gerisine geçmez), sonra yanlar, en son arka. [açı, uzaklık çarpanı]; hiçbiri açık değilse yüze çok yakın.
## Önü açıksa ilk denemede döner (tek ışın).
static func swing(n: Node3D, p: Array) -> Vector2:
	var head: Vector3 = p[1]
	var up: Vector3 = (p[2] as Vector3).normalized()
	var front: Vector3 = (p[0] as Vector3) - head
	var near: Array = [[0.0, 9.0]]           # [açı, en uzak uzaklık]
	var eye := n.get_viewport().get_camera_3d() if n.is_inside_tree() else null
	if eye:
		var v := eye.global_position - head
		var f := front - up * front.dot(up)
		var vf := v - up * v.dot(up)
		if f.length() > 0.01 and vf.length() > 0.3:
			near.append([f.signed_angle_to(vf, up), vf.length() * 0.8])
	var faces := near.size()
	near.append_array([[0.6, 9.0], [-0.6, 9.0]])
	# Önce yüze yakın açılar normal ve biraz yakın uzaklıkta; sonra ön ve oyuncu tarafı çok yakından; en son geniş açılar
	var plan: Array = []                     # [açı, uzaklık çarpanı, en uzak uzaklık]
	for k: float in [1.0, 0.7]:
		for t: Array in near:
			plan.append([t[0], k, t[1]])
	for i in faces:
		plan.append([near[i][0], 0.45, near[i][1]])
	for a: float in [1.2, -1.2, 1.8, -1.8, PI]:
		for k: float in [1.0, 0.7, 0.45]:
			plan.append([a, k, 9.0])
	var people := near_people(n, head)
	for pad: float in [PAD, 0.0]:
		for c: Array in plan:
			if front.length() * float(c[1]) > float(c[2]):
				continue
			if blocker(n, swung(p, Vector2(c[0], c[1])), head, people, pad) == null:
				return Vector2(c[0], c[1])
	return Vector2(0.0, 0.3)


static func swung(p: Array, s: Vector2) -> Vector3:
	var h: Vector3 = p[1]
	return h + ((p[0] as Vector3) - h).rotated((p[2] as Vector3).normalized(), s.x) * s.y


## Başla kamera arasındaki görünen engel (duvar, kaya, sandık, önde duran biri); konuşanın kendisi, oyuncu ve görünmez
## sınırlar sayılmaz. Kare yalnız yüz değil, başın çevresi de: ışınlar başın ortasından ve kareyi dolduran dört yanından
## (21o'da tek ışın açıktı ama lağımcının yanındaki kaya kartın yarısını kapatıyordu). Önce çarpışma, sonra kişiler, sonra
## çarpışması olmayan görünen ağlar (33o'da yapımı süren kulenin silindiri: kamera içinde kalıyor, kart boş görünüyordu).
static func blocker(n: Node3D, cam: Vector3, head: Vector3, people: Variant = null, pad := 0.0) -> Node:
	var space := n.get_world_3d().direct_space_state
	var d := (cam - head).normalized()
	var a := d.cross(Vector3.UP)
	if a.length() < 0.1:
		a = d.cross(Vector3.RIGHT)
	a = a.normalized()
	var b := a.cross(d).normalized()
	var r := FRAME * clampf(cam.distance_to(head) / DIST, 0.3, 1.0)
	var from: Array[Vector3] = [head, head + a * r, head - a * r, head + b * r, head - b * r]
	for o in from:
		var ex: Array[RID] = []
		for i in 6:
			var q := PhysicsRayQueryParameters3D.create(o, cam)
			q.exclude = ex
			var hit := space.intersect_ray(q)
			if hit.is_empty():
				break
			var c = hit["collider"]
			if c is Node and _occludes(c):
				return c
			ex.append(hit["rid"])
	var who := _person_blocker(from, cam, head, people if people != null else near_people(n, head), pad)
	if who:
		return who
	for o in from:
		var m := _mesh_blocker(n, cam, o)
		if m:
			return m
	return null


## Konuşanın çevresindeki kişiler (bölükte ön sıradaki, barikatta yanındaki, sırada önündeki). Kişilerin çarpışması yok
## ve çizim sorgusu onları saymaz (_occludes); kart kamerası onları burada görür.
static func near_people(n: Node3D, head: Vector3) -> Array:
	var out: Array = []
	if not n.is_inside_tree():
		return out
	for g: String in ["persons", "soldiers", "persons_hikmet"]:
		for q in n.get_tree().get_nodes_in_group(g):
			var p := q as Node3D
			if p == null or p == n or p.is_ancestor_of(n) or n.is_ancestor_of(p) or not p.is_visible_in_tree() \
					or p.is_queued_for_deletion() or p.has_meta("corpse"):
				continue
			if p.global_position.distance_to(head) < DIST + 2.5:
				out.append(p)
	return out


## Kişi bir kapsül: ayağından gövdenin yukarı yönünde başlığın tepesine (yatan için yatay), yarıçapı omuz kadar. Başı
## kapsülün içinde kalan (onu taşıyan, iç içe duran) sayılmaz: ondan kaçılamaz.
static func _person_blocker(from: Array[Vector3], cam: Vector3, head: Vector3, people: Array, pad := 0.0) -> Node:
	for p in people:
		if not is_instance_valid(p):
			continue
		var t: Transform3D = (p as Node3D).global_transform
		var foot := t.origin
		var top := foot + t.basis.y * 2.0
		var r := 0.28 * t.basis.x.length()
		# Oturan, çömelen, yatan: gövde kapsülü başın (ve başlığın) üstünde biter; kapsülün ucu r kadar taşar.
		# Kürekte oturanın başının üstünden geçen bakış engellenmiş sayılmasın (eskiden herkes 2 m boyunda ayaktaydı).
		var rg = p.get("rig")
		if rg is Rig and is_instance_valid(rg.head):
			var hp: Vector3 = (rg.head as Node3D).global_position + t.basis.y * (0.3 - r)
			if hp.distance_to(foot) < 2.0:
				top = hp
		if Geometry3D.get_closest_point_to_segment(head, foot, top).distance_to(head) < r:
			continue
		for o in from:
			var c := Geometry3D.get_closest_points_between_segments(o, cam, foot, top)
			if c[0].distance_to(c[1]) < r + pad:
				return p
	return null


## Çizim motorunun ışın sorgusu kutulara bakar; her aday kendi kutusunda kesin denenir. Dev ağlar (zemin, birleşik şehir:
## kutusu boşlukları da kapsar), ince direkler, saydam ve ışıksız ağlar (ışık, duman), kişiler sayılmaz. Başsız (çizimsiz)
## çalışmada boş döner.
static func _mesh_blocker(n: Node3D, cam: Vector3, head: Vector3) -> Node:
	var w := n.get_world_3d()
	if w == null:
		return null
	for id in RenderingServer.instances_cull_ray(head, cam, w.scenario):
		var mi := instance_from_id(id) as MeshInstance3D
		# Gölgesi kapalı ağlar da sayılır (sur dibindeki kırık merdivenler, kalkan siperleri)
		if mi == null or mi.mesh == null or not mi.is_visible_in_tree():
			continue
		var m := mi.material_override as BaseMaterial3D
		if m and (m.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or m.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED):
			continue
		var box := mi.get_aabb()
		var gs := (mi.global_transform.basis.get_scale() * box.size).abs()
		if maxf(gs.x, maxf(gs.y, gs.z)) > 25.0 or minf(gs.x, minf(gs.y, gs.z)) < 0.03:
			continue
		if not _occludes(mi):
			continue
		var inv := mi.global_transform.affine_inverse()
		var a := inv * head
		if box.has_point(a):
			continue        # baş kutunun içinde (taşıdığı, üstündeki şey): kendisini örtmez
		var b := inv * cam
		if box.has_point(b) or box.intersects_segment(a, b) != null:
			return mi
	return null


static func _occludes(c: Node) -> bool:
	if c is Player or c is Area3D or String(c.name).begins_with("Interact_"):
		return false
	var q: Node = c
	while q != null:
		if q is Person or q is Hikmet or q is Soldier or q.is_queued_for_deletion():
			return false
		q = q.get_parent()
	if c.has_meta("facade") or c.has_meta("wall") or c is GeometryInstance3D:
		return true
	for k in c.get_children():
		if k is GeometryInstance3D and (k as GeometryInstance3D).is_visible_in_tree():
			return true
	return false
