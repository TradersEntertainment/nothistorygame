class_name Unclip
extends RefCounted
## Karakterler nesnelerin içine gömülmesin: bir sahnede yerleştirilen karakter doğduktan birkaç
## fizik karesi sonra (dolgu ve çarpışmalar kurulduktan sonra) kendini denetler; bir tezgâhın,
## fıçının, çadırın ya da duvarın içindeyse en yakın boş, zeminli noktaya kayar.
## Yalnızca doğrudan bir seviyenin (CampDay, ByzCity, Galata...) çocuğu olan, ayakta duran
## karakterler için: sahne betiklerinin elle yerleştirdikleri, kayıktakiler, oturanlar dokunulmaz.

const RINGS := [0.3, 0.55, 0.8, 1.1, 1.4, 1.8, 2.3, 2.9, 3.6]

static var _cache_frame := -1
static var _cache: Array = []   # [AABB global, Transform3D inverse, AABB yerel, yuvarlak mı]


static func settle(ch: Node3D) -> void:
	if GameState.autotest:
		return
	var tree := ch.get_tree()
	if tree == null or (tree.current_scene and tree.current_scene.has_meta("cinematic")):
		return   # fragman gibi elle kurulmuş çekimlerde karakterler tam konduğu yerde kalır
	for i in 4:
		await tree.physics_frame
	if not is_instance_valid(ch) or not ch.is_inside_tree() or not _eligible(ch):
		return
	if not blocked(ch, ch.global_position):
		return
	var start := ch.global_position
	var yaw := ch.global_rotation.y
	for r: float in RINGS:
		for k in 12:
			# Önce karakterin arkası ve yanları: tezgâh önündeyse arkasına geçsin
			var a := yaw + PI + k * TAU / 12.0 * (1 if k % 2 == 0 else -1) * 0.5
			var p := start + Vector3(sin(a), 0, cos(a)) * r
			var g := _ground(ch, p, start.y)
			if g == INF:
				continue
			p.y = g
			if not blocked(ch, p):
				ch.global_position = p
				return


static func _eligible(ch: Node3D) -> bool:
	if ch.has_meta("no_unclip"):
		return false
	var par := ch.get_parent()
	if not (par is CampDay or par is Camp or par is ByzCity or par is Galata or par is SeaWalls or par is OtagHall \
			or par is Slipway or par is Bureau or par is Garage or par is Monday or par is HardwareStore):
		return false
	if ch is Soldier and (ch as Soldier).pose != "stand":
		return false
	if ch is Person and (ch as Person).activity.begins_with("sit"):
		return false
	return true


static func _is_char(n: Node) -> bool:
	return n is Person or n is Soldier or n is Hikmet or n is Chicken or n is Player


static func _meshes(tree: SceneTree) -> Array:
	var f := Engine.get_physics_frames()
	if f == _cache_frame:
		return _cache
	_cache_frame = f
	_cache = []
	var stack: Array = [tree.current_scene if tree.current_scene else tree.root]
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		if _is_char(n):
			continue
		if n is MeshInstance3D:
			var m := n as MeshInstance3D
			if m.mesh and m.is_visible_in_tree():
				var ab := m.global_transform * m.get_aabb()
				if ab.size.x <= 9.0 and ab.size.z <= 9.0 and ab.size.y <= 8.0 and ab.size.y > 0.25:
					_cache.append([ab, m.global_transform.affine_inverse(), m.get_aabb(), m.mesh is CylinderMesh or m.mesh is SphereMesh])
		for c in n.get_children():
			stack.append(c)
	return _cache


## Karakter p noktasında dursa bir nesnenin içinde kalır mı?
static func blocked(ch: Node3D, p: Vector3) -> bool:
	var s := ch.global_transform.basis.get_scale()
	var r := 0.2 * s.x
	var h := 1.5 * s.y
	var body := AABB(p + Vector3(-r, 0.3, -r), Vector3(r * 2.0, h - 0.3, r * 2.0))
	var pts: Array[Vector3] = []
	for hy: float in [0.45, 0.8, 1.15]:
		var y := p.y + hy * s.y
		pts.append(Vector3(p.x, y, p.z))
		for k in 4:
			var a := k * PI / 2.0
			pts.append(Vector3(p.x + cos(a) * r * 0.7, y, p.z + sin(a) * r * 0.7))
	for e: Array in _meshes(ch.get_tree()):
		if not (e[0] as AABB).intersects(body):
			continue
		var inv: Transform3D = e[1]
		var la: AABB = (e[2] as AABB).grow(-0.01)
		var inside := 0
		for pt in pts:
			var lp: Vector3 = inv * pt
			if not la.has_point(lp):
				continue
			if e[3]:
				var c := la.get_center()
				var dx := (lp.x - c.x) / maxf(la.size.x * 0.5, 0.001)
				var dz := (lp.z - c.z) / maxf(la.size.z * 0.5, 0.001)
				if dx * dx + dz * dz >= 1.0:
					continue
			inside += 1
			if inside >= 2:
				return true
	var space := ch.get_world_3d().direct_space_state
	var q := PhysicsShapeQueryParameters3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = r * 0.8
	cap.height = maxf(h - 0.45, r * 2.0)
	q.shape = cap
	q.transform = Transform3D(Basis(), p + Vector3(0, 0.35 + cap.height * 0.5, 0))
	q.collide_with_areas = false
	q.collision_mask = 1
	for hit in space.intersect_shape(q, 8):
		var col: Node = hit["collider"]
		if col is CharacterBody3D or str(col.name).begins_with("Interact"):
			continue
		var up := col
		var own := false
		while up:
			if _is_char(up):
				own = true
				break
			up = up.get_parent()
		if not own:
			return true
	return false


## p'nin altında, başlangıç yüksekliğine yakın zemin (yoksa INF: su, boşluk, sur kenarı).
static func _ground(ch: Node3D, p: Vector3, y0: float) -> float:
	var space := ch.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 0.6, 0), p + Vector3(0, -0.8, 0), 1)
	var hit := space.intersect_ray(q)
	if hit.is_empty():
		return INF
	var y: float = (hit["position"] as Vector3).y
	if absf(y - y0) > 0.25:
		return INF
	return y


# ---------------------------------------------------------------- kişisel alan ve görünen zemin
## Hareket ettiren ve yerleştiren bütün sistemler (koşan şeritleri, onarım ekibi, düellocular, yürüyen halk, sahne
## betikleri) için ortak ölçüler: kimse bir başkasının içinden geçmesin, kimse görünen zeminin içine gömülmesin ya da
## üstünde havada kalmasın, kimse bir katının (sandık, siper, duvar) içinde durmasın. Otomatik testlerin denetçileri
## (Hud._crowd_audit, Hud._ground_audit) aynı ölçüleri kullanır.

const PUSH_CELL := 1.0
static var _crowd_frame := -1
static var _crowd_grid: Dictionary = {}


## Yere uzanmış (yatan, ölü, devrilmiş) ya da oturan: bunların yanından/üstünden geçilir, itilmez.
static func lying(p: Node3D) -> bool:
	if p.has_meta("corpse"):
		return true
	var act := str(p.get("activity")) if p.get("activity") != null else ""
	return act in ["lie", "sleep", "dead"] or absf(p.global_rotation.x) > 0.4 or absf(p.global_rotation.z) > 0.4


## Karede bir kez kurulan ızgara: görünen, ayaktaki kişiler (Person), 1 m'lik hücrelerde.
static func _crowd(tree: SceneTree) -> Dictionary:
	var f := Engine.get_process_frames()
	if f == _crowd_frame:
		return _crowd_grid
	_crowd_frame = f
	_crowd_grid = {}
	for n in tree.get_nodes_in_group("persons"):
		var p := n as Node3D
		if p == null or not p.is_visible_in_tree() or lying(p):
			continue
		var k := Vector2i(floori(p.global_position.x / PUSH_CELL), floori(p.global_position.z / PUSH_CELL))
		if _crowd_grid.has(k):
			(_crowd_grid[k] as Array).append(p)
		else:
			_crowd_grid[k] = [p]
	return _crowd_grid


## who p noktasında dursa yakınındaki (r içindeki, aynı kattaki) ayaktaki kişilerden uzaklaştıran yatay itiş.
## Her komşu (r - uzaklık) / r kadar iter; tam üst üste duranlar kimliklerinden türeyen sabit bir yöne ayrılır.
## skip: sayılmayacak kişiler (ör. düellocunun kendi rakibi değil; yüklediği yaralı).
static func push(who: Node3D, p: Vector3, r := 0.7, skip: Array = []) -> Vector3:
	if who == null or not who.is_inside_tree():
		return Vector3.ZERO
	var g := _crowd(who.get_tree())
	var out := Vector3.ZERO
	var c := Vector2i(floori(p.x / PUSH_CELL), floori(p.z / PUSH_CELL))
	var span := ceili(r / PUSH_CELL)
	for dx in range(-span, span + 1):
		for dz in range(-span, span + 1):
			var cell = g.get(c + Vector2i(dx, dz))
			if cell == null:
				continue
			for o in cell:
				if not is_instance_valid(o) or o == who or o in skip:
					continue
				var on := o as Node3D
				if who.is_ancestor_of(on) or on.is_ancestor_of(who) or not on.is_visible_in_tree():
					continue
				var op := on.global_position
				if absf(op.y - p.y) > 0.9:
					continue
				var d := Vector3(p.x - op.x, 0.0, p.z - op.z)
				var l := d.length()
				if l >= r:
					continue
				if l < 0.02:
					var a := float(who.get_instance_id() % 6283) * 0.001
					d = Vector3(sin(a), 0.0, cos(a))
					l = 0.02
				out += d / l * (r - l) / r
	return out


## from'dan to'ya atılan adım ayakta birinin (r içinde) üstüne mi bitiyor ve ona yaklaştırıyor mu. Izgara kullanmaz:
## aynı karede yürümüş olanları da görür (blocks_step'in ızgarası karenin başında kurulur; aynı karede çekilen iki
## düellocu iç içe giriyordu).
static func steps_into(who: Node3D, from: Vector3, to: Vector3, r := 0.45, skip: Array = []) -> bool:
	if who == null or not who.is_inside_tree():
		return false
	for n in who.get_tree().get_nodes_in_group("persons"):
		var o := n as Node3D
		if o == null or o == who or o in skip or not o.is_visible_in_tree() or who.is_ancestor_of(o) or o.is_ancestor_of(who) or lying(o):
			continue
		var op := o.global_position
		if absf(op.y - to.y) > 0.9:
			continue
		var dn := Vector2(to.x - op.x, to.z - op.z).length()
		if dn < r and dn < Vector2(from.x - op.x, from.z - op.z).length():
			return true
	return false


## p noktasında r yakınında ayakta biri var mı (doğma ve yerleştirme yeri seçerken). Izgara kullanmaz: aynı karede
## yerleştirilenleri de görür.
static func crowded(who: Node3D, p: Vector3, r := 0.6, skip: Array = []) -> bool:
	if who == null or not who.is_inside_tree():
		return false
	for n in who.get_tree().get_nodes_in_group("persons"):
		var o := n as Node3D
		if o == null or o == who or o in skip or not o.is_visible_in_tree() or who.is_ancestor_of(o) or o.is_ancestor_of(who) or lying(o):
			continue
		var op := o.global_position
		if absf(op.y - p.y) < 0.9 and Vector2(op.x - p.x, op.z - p.z).length() < r:
			return true
	return false


## Görünen bir katı mı: kendi görünür ağı olan (ya da "facade"/"wall"/"ground" işaretli) gövde. Görünmez sınırlar,
## konuşma alanları (Interact_*) ve karakter parçaları sayılmaz. Hud._is_visible_occluder ile aynı ölçü.
static func visible_body(n: Node) -> bool:
	if n == null or n is Area3D or String(n.name).begins_with("Interact_"):
		return false
	var q: Node = n
	while q != null:
		if q.is_queued_for_deletion() or _is_char(q):
			return false
		q = q.get_parent()
	if n.has_meta("facade") or n.has_meta("wall") or n.has_meta("ground"):
		return true
	for c in n.get_children():
		if c is GeometryInstance3D and (c as GeometryInstance3D).is_visible_in_tree():
			return true
	return false


## Üstüne basılan görünen bir yüzey mi: görünen katı (visible_body), görünen arazinin kendi çarpışması (LowPoly.solid:
## gövde arazi ağının çocuğu) ya da arazi biçimli çarpışma (yükseklik haritası, üçgen ağ: görünen arazinin aynısı).
static func standable(col: Object, shape := 0) -> bool:
	if not (col is CollisionObject3D):
		return false
	var n := col as Node
	if visible_body(n):
		return true
	var q: Node = n
	while q != null:
		if q.is_queued_for_deletion() or _is_char(q):
			return false
		q = q.get_parent()
	var par := n.get_parent()
	if par is GeometryInstance3D and (par as GeometryInstance3D).is_visible_in_tree():
		return true
	var co := col as CollisionObject3D
	var own := co.shape_find_owner(shape)
	if own < 0 or co.shape_owner_get_shape_count(own) == 0:
		return false
	var sh := co.shape_owner_get_shape(own, 0)
	return sh is HeightMapShape3D or sh is ConcavePolygonShape3D


## p'nin altındaki (p.y + up ile p.y - down arası) ilk GÖRÜNEN zeminin yüksekliği; yoksa NAN. Görünmez çarpışma
## kutuları (barikatın gizli aşaması, yalnız oyuncuyu durduran sınırlar) ve karakterler atlanır: karakter görünen
## yüzeye basar (denetçi de görünen yüzeye bakar).
static func floor_y(ctx: Node3D, p: Vector3, up := 1.0, down := 2.0) -> float:
	if ctx == null or not ctx.is_inside_tree():
		return NAN
	var space := ctx.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, up, 0), p + Vector3(0, -down, 0), 1)
	for i in 8:
		var h := space.intersect_ray(q)
		if h.is_empty():
			return NAN
		var col: Object = h["collider"]
		if col is CollisionObject3D and not standable(col, int(h.get("shape", 0))):
			q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
			continue
		return (h["position"] as Vector3).y
	return NAN


## p noktasında duran birinin gövdesi (diz üstünden baş altına: 0,6–1,5 m, 0,16 m yarıçap) görünen bir katının
## (sandık, siper, duvar, direk) içinde mi. Hud._crowd_audit'in "insolid" ölçüsü.
static func in_solid(ctx: Node3D, p: Vector3, r := 0.16) -> bool:
	if ctx == null or not ctx.is_inside_tree():
		return false
	var cap := CapsuleShape3D.new()
	cap.radius = r
	cap.height = 0.9
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.transform = Transform3D(Basis(), p + Vector3(0, 1.05, 0))
	q.collision_mask = 1
	for h in ctx.get_world_3d().direct_space_state.intersect_shape(q, 8):
		var col = h["collider"]
		if col is StaticBody3D and visible_body(col):
			return true
	return false


## Görünen ama çarpışmasız bir eşyanın (güverte tahtası, araba tablası, iskele kalası, sandık) tam üstünde mi duruyor:
## ayağın 4 cm altı bir görünür ağın (kendi ekseninde) kutusunun içinde, 25 cm üstü dışında. Karakterler sayılmaz.
static var _stand_frame := -1
static var _stand: Array = []    # [AABB global, Transform3D inverse, AABB yerel]

static func on_mesh(ch: Node3D, p: Vector3) -> bool:
	var tree := ch.get_tree()
	if tree == null:
		return false
	var f := Engine.get_physics_frames()
	if f != _stand_frame:
		_stand_frame = f
		_stand = []
		var stack: Array = [tree.current_scene if tree.current_scene else tree.root]
		while stack.size() > 0:
			var n: Node = stack.pop_back()
			if _is_char(n) or (n is Node3D and not (n as Node3D).visible):
				continue
			if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
				var m := n as MeshInstance3D
				var ab := m.global_transform * m.get_aabb()
				if ab.size.x <= 40.0 and ab.size.z <= 40.0:
					_stand.append([ab, m.global_transform.affine_inverse(), m.get_aabb().grow(0.02)])
			for c in n.get_children():
				stack.append(c)
	var lo := p + Vector3(0, -0.04, 0)
	var hi := p + Vector3(0, 0.25, 0)
	for e: Array in _stand:
		var ab: AABB = e[0]
		if p.x < ab.position.x or p.x > ab.end.x or p.z < ab.position.z or p.z > ab.end.z or lo.y > ab.end.y or lo.y < ab.position.y:
			continue
		var inv: Transform3D = e[1]
		var la: AABB = e[2]
		if la.has_point(inv * lo) and not la.has_point(inv * hi):
			return true
	return false


## y yüksekliğindeki zemin, ayağın (p) üstünde: ayak zeminin İÇİNDE mi (gömülü), yoksa alçak bir tablanın, kirişin
## ALTINDA mı duruyor. Ayaktan yukarı ışın o yüzeyin altına çarpıyorsa altındadır (gömülü değil).
static func under(ch: Node3D, p: Vector3, y: float) -> bool:
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 0.03, 0), Vector3(p.x, y - 0.01, p.z), 1)
	q.hit_back_faces = false
	for i in 4:
		var h := ch.get_world_3d().direct_space_state.intersect_ray(q)
		if h.is_empty():
			return false
		var col: Object = h["collider"]
		if col is CollisionObject3D and not standable(col, int(h.get("shape", 0))):
			q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
			continue
		return true
	return false


## Ayakta duran karakterin görünen zemine göre doğru yüksekliği; düzeltme gerekmiyorsa NAN. Ayak zemine gömülüyse
## (en çok 0,9 m) zemine çıkar; zeminin üstünde havadaysa (en çok 0,8 m) iner, ama görünen bir eşyanın üstünde
## duruyorsa inmez. Daha büyük farklar kasıtlı sayılır (sur üstü, merdiven) ya da denetçiye kalır.
static func settle_y(ch: Node3D) -> float:
	if ch == null or not ch.is_inside_tree():
		return NAN
	var p := ch.global_position
	var y := floor_y(ch, p, 0.9, 0.8)
	if is_nan(y) or absf(y - p.y) < 0.05:
		return NAN
	if y > p.y and under(ch, p, y):
		return NAN
	if y < p.y and on_mesh(ch, p):
		return NAN
	return y


## Yere oturtulabilir mi: ayakta, görünür, bir binekte ya da taşınmıyor, kendi yüksekliğini yöneten bir sistemde değil.
## "climber" (merdiven, mazgal, ip), "no_ground" (kasıtlı havada: patlamanın donmuş karesi), "hologram", "corpse",
## oturan/yatan/kürek çeken/yüzen/uçan, yatırılmış (devrilen, taşınan) ve iskeleti kilitli (elle oynatılan) olanlar dışarıda.
static func keep_ok(ch: Node3D) -> bool:
	if not ch.is_visible_in_tree() or ch.has_meta("climber") or ch.has_meta("no_ground") or ch.has_meta("hologram") \
			or ch.has_meta("corpse") or ch.has_meta("cameo"):
		return false
	var act := str(ch.get("activity")) if ch.get("activity") != null else ""
	if act.begins_with("sit") or act.begins_with("climb") or act in ["row", "lie", "sleep", "dead", "ride", "swim", "fly", "hover", "fall"]:
		return false
	if ch is Soldier and (ch as Soldier).pose != "stand":
		return false
	if absf(ch.global_rotation.x) > 0.3 or absf(ch.global_rotation.z) > 0.3:
		return false
	var rg = ch.get("rig")
	if rg is Rig and (rg as Rig).lock > 0:
		return false
	var q: Node = ch.get_parent()
	while q != null:
		if q is Horse or q is Player or q is Duelist or _is_char(q):
			return false
		q = q.get_parent()
	return true


## Durunca yere otur (Person ve Soldier _process'inden çağrılır): karakter 0,25 sn kıpırdamadıysa ve bu yerde henüz
## oturtulmadıysa ayağını görünen zemine indirir/çıkarır. Sahne betiklerinin elle verdiği yükseklikler (moloz yamacı,
## sur yolu, iskele) böylece görünen yüzeyle eşleşir; yürüyen, taşınan, tween'le hareket eden karışmaz (durmasını bekler).
static func rest_settle(ch: Node3D, st: Dictionary, delta: float) -> void:
	var t: float = st.get("t", randf() * 0.25) - delta
	if t > 0.0:
		st["t"] = t
		return
	st["t"] = 0.25
	var gp := ch.global_position
	var last: Vector3 = st.get("p", Vector3.INF)
	st["p"] = gp
	if last == Vector3.INF or last.distance_squared_to(gp) > 0.0001:
		st["done"] = false
		return
	if st.get("done", false):
		# Durduğu yerin zemini sonradan değişebilir (barikat aşaması kuruldu, kalas kaldırıldı): ara sıra yeniden bakar
		var rc: float = st.get("rc", 0.0) - 0.25
		st["rc"] = rc
		if rc > 0.0:
			return
		st["rc"] = 1.5
		var fy := floor_y(ch, gp, 0.9, 0.8)
		var was: float = st.get("fy", NAN)
		if is_nan(fy) == is_nan(was) and (is_nan(fy) or absf(fy - was) < 0.05):
			return
		st.erase("undo")
	st["done"] = true
	st["rc"] = 1.5
	st["fy"] = floor_y(ch, gp, 0.9, 0.8)
	# Kendi yüksekliğini her karede yeniden yazan bir sistem (ör. bekleyen şehir halkı) düzeltmeyi geri aldıysa
	# bir daha denenmez (iki yükseklik arasında titremesin)
	var undo: Vector3 = st.get("undo", Vector3.INF)
	if undo != Vector3.INF and undo.distance_squared_to(gp) < 0.0001:
		return
	if not keep_ok(ch):
		return
	var y := settle_y(ch)
	if not is_nan(y):
		st["undo"] = gp
		ch.global_position.y = y
		st["p"] = ch.global_position
		st["fy"] = floor_y(ch, ch.global_position, 0.9, 0.8)


## Biri takip eden ya da betikle yürütülen biri için bir adım (d): varılacak yer görünen bir katının (kuyu, sandık,
## araba, duvar) içindeyse adım ±40°, ±80° döndürülerek denenir; hiçbiri açık değilse yerinde kalır. Zaten bir katının
## içindeyse adım olduğu gibi atılır (çıkabilsin). Döner: uygulanacak yer değiştirme.
static func free_step(ch: Node3D, d: Vector3) -> Vector3:
	var p := ch.global_position
	if d.length_squared() < 1e-8 or in_solid(ch, p, 0.2):
		return d
	for a: float in [0.0, 0.7, -0.7, 1.4, -1.4]:
		var m := d.rotated(Vector3.UP, a)
		if not in_solid(ch, p + m, 0.22):
			return m
	return Vector3.ZERO


## Ayakta biri başkasının içinde (r'den yakın) duruyorsa en yakın boş, görünen zeminli, katısız noktaya kayar (en çok
## 1,4 m; zemin 0,5 m'den fazla değişmez). Kalabalık kuran ve yerinde donduran sistemler (siper alan koşanlar, sıraya
## dizilen halk) için. Yer bulunamazsa kalır. Döner: artık kimsenin içinde değil mi.
static func spread(who: Node3D, r := 0.6) -> bool:
	if who == null or not who.is_inside_tree():
		return false
	var p := who.global_position
	if not crowded(who, p, r):
		return true
	var a0 := float(who.get_instance_id() % 628) * 0.01
	for ring: float in [0.35, 0.6, 0.9, 1.15, 1.4]:
		for k in 8:
			var a := a0 + k * TAU / 8.0
			var c := p + Vector3(sin(a), 0, cos(a)) * ring
			var fy := floor_y(who, c, 0.6, 0.8)
			if is_nan(fy) or absf(fy - p.y) > 0.5:
				continue
			c.y = fy
			if not crowded(who, c, r) and not in_solid(who, c):
				who.global_position = c
				return true
	return false


## from'dan to'ya atılan adım ayakta birinin içine (r'den yakına) mı giriyor: yalnız yaklaşan adımlar sayılır (iç içe
## kalmış olan uzaklaşabilsin). Yürüten sistemlerin (düellocu, takip eden) son denetimi; ızgara karede bir kurulur.
static func blocks_step(who: Node3D, from: Vector3, to: Vector3, r := 0.5, skip: Array = []) -> bool:
	if who == null or not who.is_inside_tree():
		return false
	var g := _crowd(who.get_tree())
	var c := Vector2i(floori(to.x / PUSH_CELL), floori(to.z / PUSH_CELL))
	for dx in range(-1, 2):
		for dz in range(-1, 2):
			var cell = g.get(c + Vector2i(dx, dz))
			if cell == null:
				continue
			for o in cell:
				if not is_instance_valid(o) or o == who or o in skip:
					continue
				var on := o as Node3D
				if who.is_ancestor_of(on) or on.is_ancestor_of(who) or not on.is_visible_in_tree():
					continue
				var op := on.global_position
				if absf(op.y - to.y) > 0.9:
					continue
				var dn := Vector2(to.x - op.x, to.z - op.z).length()
				if dn < r and dn < Vector2(from.x - op.x, from.z - op.z).length():
					return true
	return false
