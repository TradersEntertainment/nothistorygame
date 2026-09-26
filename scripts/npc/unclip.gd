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
