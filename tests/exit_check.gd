extends Node
## EXITCHECK: her yer yürünür mü. Bölüm --exitcheck ile açılır (autotest değil: hikâye ilk replikte bekler, oyuncuyu
## ışınlamaz). Dünyanın katılaşması (WorldWalk) bitince oyuncunun durduğu yerden erişilebilirlik taraması yapılır:
## 1,5 m'lik ızgarada oyuncu kapsülüyle adım adım (basamak ≤ 0,45 m, düşüş ≤ 3 m, gövde sığmalı, aradan geçilmeli).
## Ölçülen: 8 dilimde (başlangıçtan yönler) oyun alanının (keep) dışında en çok kaç metre uzağa varılabiliyor; ya da
## dünyanın suyuna (kıyıya) varılıyor mu.
## Geçme: en az 6 dilimde keep dışında 30 m (ya da kıyı). Çıktı: EXITCHECK chapter=.. dirs=a/8 far=[..] PASS|FAIL

const DIRS := 8
const WALK_SECS := 40.0          # oyun zamanı, yön başına
const NEED_OUT := 30.0
## Açılışı dünyasız yerde olan bölümler (13: geri çağrı, önceki yere göre ByzCity/Galata/CampDay; 17: önce büro)
const NOWORLD_OK := ["chapter13", "chapter17"]
## Gemide (denizde) başlayan bölümler: ölçüm bölümün karadaki yerinden (rıhtım) başlar
const LAND_START := {"chapter19": Vector3(10.0, 0.8, -1.6), "chapter19o": Vector3(10.0, 0.8, -1.6),
	"chapter29": Vector3(10.0, 0.8, -1.6), "chapter29o": Vector3(10.0, 0.8, -1.6), "chapter38o": Vector3(11.5, 1.3, 59.3)}

var player: Player
var walks: Array[WorldWalk] = []
var voids := 0
var water := 0
var blockers: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run()


func _run() -> void:
	var t := 0.0
	while t < 90.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		if player == null:
			player = get_tree().get_first_node_in_group("player") as Player
		walks = _find_walks()
		if player and not walks.is_empty() and walks.all(func(w: WorldWalk) -> bool: return w.done) and t > 3.0:
			break
	var ch := GameState.start_scene.get_file().get_basename() if GameState.start_scene != "" else "chapter%d" % GameState.start_chapter
	if player == null or walks.is_empty():
		# Açılışı dünyasız bir yerde (büro, laboratuvar) olan bölümler: seviyeleri başka bölümlerde denetlenir
		var ok_skip: bool = ch in NOWORLD_OK
		print("EXITCHECK chapter=%s noworld %s" % [ch, "SKIP" if ok_skip else "FAIL"])
		get_tree().quit(0 if ok_skip else 1)
		return
	if OS.has_environment("EXIT_BAND"):
		_band(OS.get_environment("EXIT_BAND"))
	if LAND_START.has(ch):
		_free_player()
		player.global_position = LAND_START[ch]
		player.velocity = Vector3.ZERO
	for i in 10:
		await get_tree().physics_frame
		if LAND_START.has(ch):
			player.global_position = LAND_START[ch]
	var start := player.global_position
	var r := _reach(start)
	var far: Array = r["far"]
	var shore: Array = r["shore"]
	var ok := 0
	for k in DIRS:
		if far[k] >= NEED_OUT or shore[k]:
			ok += 1
	var pass_ok := ok >= 6
	print("EXITCHECK chapter=%s dirs=%d/%d far=%s shore=%s cells=%d start=%s %s" % [ch, ok, DIRS, far.map(func(f): return snappedf(f, 1.0)), shore, r["cells"], Vector3i(start), "PASS" if pass_ok else "FAIL"])
	if OS.has_environment("EXIT_DEBUG"):
		print("EXITCHECK start=%s frontier=%s" % [start, r["edge"]])
	get_tree().quit(0 if pass_ok else 1)


## Hata ayıklama: x0,z0,x1,z1 kuşağındaki katıları (y 0.2..2.5) listeler
func _band(spec: String) -> void:
	var v := spec.split(",")
	var a := Vector3(float(v[0]), 0.2, float(v[1]))
	var b := Vector3(float(v[2]), 2.5, float(v[3]))
	var bs := BoxShape3D.new()
	bs.size = (b - a).abs()
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = bs
	q.transform = Transform3D(Basis(), (a + b) * 0.5)
	q.exclude = [player.get_rid()]
	var res := player.get_world_3d().direct_space_state.intersect_shape(q, 256)
	var seen := {}
	for r in res:
		var c := r["collider"] as CollisionObject3D
		var oid := c.shape_find_owner(r["shape"])
		var ow := c.shape_owner_get_owner(oid)
		var sh := c.shape_owner_get_shape(oid, 0)
		var key := "%s %s %s" % [c.name, (sh as BoxShape3D).size.snapped(Vector3.ONE * 0.1) if sh is BoxShape3D else sh.get_class(),
			Vector3i((ow as Node3D).global_position) if ow is Node3D else Vector3i.ZERO]
		seen[key] = true
	for k in seen:
		print("EXITBAND ", k)


const STEP := 1.5
const MAX_R := 280.0

## Erişilebilirlik: ızgarada genişlik öncelikli arama. far[k]: k diliminde keep dışında, keep'ten çıkılan yere değil
## başlangıca göre en uzak erişilen hücrenin keep dışındaki mesafesi (keep sınırına uzaklık ölçüsü: hücre keep
## dışındaysa başlangıçtan uzaklığı − ilk dışarı çıkıştaki uzaklık yerine basitçe keep'e uzaklık).
func _reach(start: Vector3) -> Dictionary:
	var space := player.get_world_3d().direct_space_state
	_start = start
	if OS.has_environment("EXIT_REACH"):
		var v := OS.get_environment("EXIT_REACH").split(",")
		_dbg_box = Rect2(float(v[0]), float(v[1]), float(v[2]) - float(v[0]), float(v[3]) - float(v[1]))
	_start_in_keep = _out_dist(start) < 0.0
	var cap := CapsuleShape3D.new()
	cap.radius = 0.28
	cap.height = 1.3
	var fy := _floor(space, start + Vector3(0, 0.5, 0), 3.0)
	if is_nan(fy):
		fy = start.y
	var far: Array = []
	var shore: Array = []
	for k in DIRS:
		far.append(0.0)
		shore.append(false)
	var seen := {}
	var queue: Array = [[Vector2i(0, 0), fy]]
	seen[Vector2i(0, 0)] = true
	var cells := 0
	var edge: Array = []
	var head := 0
	while head < queue.size() and cells < 120000:
		var cur: Array = queue[head]
		head += 1
		cells += 1
		var c: Vector2i = cur[0]
		var y: float = cur[1]
		var p := Vector3(start.x + c.x * STEP, y, start.z + c.y * STEP)
		var rel := Vector2(p.x - start.x, p.z - start.z)
		var sector := int(posmod(atan2(rel.x, rel.y) / TAU * DIRS + 0.5, DIRS))
		var od := _out_dist(p)
		if od > 0.0:
			far[sector] = maxf(far[sector], od)
		if rel.length() > MAX_R:
			continue
		for n: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]:
			var nc := c + n
			if seen.has(nc):
				continue
			var q := Vector3(start.x + nc.x * STEP, y, start.z + nc.y * STEP)
			if _world_water(q) and od >= 0.0:
				shore[sector] = true
				seen[nc] = true
				continue
			var ny := _floor(space, q + Vector3(0, 0.6, 0), 15.6)
			if is_nan(ny) and _any_water(q):
				shore[sector] = true        # bölümün kendi suyu (oynanış alanında, çarpışmasız): kıyıya varıldı
				seen[nc] = true
				continue
			if is_nan(ny) or ny - y > 0.45 or y - ny > 15.0:
				continue
			# Gövde sığar mı, aradan geçilir mi
			var from := Transform3D(Basis(), p + Vector3(0, 0.45 + 0.65 + 0.05, 0))
			var mq := PhysicsShapeQueryParameters3D.new()
			mq.shape = cap
			mq.transform = from
			mq.motion = Vector3(q.x - p.x, maxf(ny - y, 0.0), q.z - p.z)
			mq.exclude = [player.get_rid()]
			var frac := space.cast_motion(mq)
			if frac.size() > 0 and frac[0] < 0.999:
				continue
			seen[nc] = true
			queue.append([nc, ny])
			if _dbg_box.has_point(Vector2(q.x, q.z)):
				print("EXITREACH ", Vector3i(q.x, int(ny * 10.0), q.z))
	# Erişilenin sınırı (hata ayıklama): dilim başına en uzak erişilen nokta
	for k in DIRS:
		edge.append(snappedf(far[k], 1.0))
	return {"far": far, "shore": shore, "cells": cells, "edge": edge}


func _floor(space: PhysicsDirectSpaceState3D, from: Vector3, depth: float) -> float:
	var q := PhysicsRayQueryParameters3D.create(from, from - Vector3(0, depth + 0.6, 0))
	q.exclude = [player.get_rid()]
	var hit := space.intersect_ray(q)
	if hit.is_empty() or (hit["normal"] as Vector3).y < 0.55:
		return NAN
	return (hit["position"] as Vector3).y


## Keep dışındaysa keep'e (en yakın keep dikdörtgenine) uzaklık; içindeyse -1. Başlangıç keep'te değilse (kara surları:
## keep yalnız büyük topun döşemesi) oyun alanı başlangıcın 60 m çevresi sayılır.
var _start := Vector3.INF
var _dbg_box := Rect2()
var _start_in_keep := true

func _out_dist(p: Vector3) -> float:
	if not _start_in_keep:
		var d := Vector2(p.x - _start.x, p.z - _start.z).length() - 60.0
		return d if d > 0.0 else -1.0
	var best := INF
	for w in walks:
		if not is_instance_valid(w.world):
			continue
		var wp := w.world.global_transform.affine_inverse() * p
		if w._in_keep(wp):
			return -1.0
		for r in w.keep:
			var rr := r as Rect2
			var dx := maxf(maxf(rr.position.x - wp.x, wp.x - rr.end.x), 0.0)
			var dz := maxf(maxf(rr.position.y - wp.z, wp.z - rr.end.y), 0.0)
			best = minf(best, Vector2(dx, dz).length())
	return best if best < INF else 1000.0


func _any_water(p: Vector3) -> bool:
	for w in walks:
		var wp := w.world.global_transform.affine_inverse() * p
		if World1453.is_water(wp.x, wp.z):
			return true
	return false


func _world_water(p: Vector3) -> bool:
	for w in walks:
		var wp := w.world.global_transform.affine_inverse() * p
		if not w._in_keep(wp) and World1453.is_water(wp.x, wp.z):
			return true
	return false


func _find_walks() -> Array[WorldWalk]:
	var out: Array[WorldWalk] = []
	for n in get_tree().root.find_children("WorldWalk", "", true, false):
		if n is WorldWalk:
			out.append(n)
	return out


func _free_player() -> void:
	player.frozen = false
	player.pinned = false
	player.move_mode = "walk"
	player.gravity_on = true
	player.ladder = null


func _outside(p: Vector3) -> bool:
	for w in walks:
		if not is_instance_valid(w.world):
			continue
		var wp := w.world.global_transform.affine_inverse() * p
		if w._in_keep(wp):
			return false
	return true


func _walk(start: Vector3, dir: Vector3) -> Dictionary:
	player.global_position = start
	player.velocity = Vector3.ZERO
	var t := 0.0
	var out := 0.0
	var out_from := Vector3.INF
	var shore := false
	var stuck_t := 0.0
	var last := start
	var veer := 0.0
	var veer_t := 0.0
	var side := 1.0
	var stucks := 0
	var low := start.y - 40.0
	var land_before := Vector3.INF
	var moved := 0.0
	while t < WALK_SECS:
		await get_tree().physics_frame
		var dt := get_physics_process_delta_time()
		t += dt
		_free_player()
		var d := dir.rotated(Vector3.UP, veer)
		player.face(player.global_position + d * 10.0 + Vector3(0, 1.6, 0))
		Input.action_press("move_forward")
		var p := player.global_position
		moved = maxf(moved, Vector2(p.x - start.x, p.z - start.z).length())
		# Keep dışında alınan yol (dışarı ilk çıkılan noktadan)
		if _outside(p):
			if out_from == Vector3.INF:
				out_from = p
			out = maxf(out, Vector2(p.x - out_from.x, p.z - out_from.z).length())
		# Su: WorldWalk kıyıya döndürdüyse (ani geri sıçrama) kıyıya varılmış sayılır ve yön biter
		if land_before != Vector3.INF and p.distance_to(land_before) > 6.0 and _near_water(land_before):
			shore = true
			water += 1
			break
		land_before = p
		if p.y < low:
			voids += 1
			print("EXITCHECK void at=%s" % p)
			break
		# Tıkanma: 1,2 sn'de 0,6 m'den az ilerleme → sap (sağ/sol dönüşümlü), arada zıpla
		# Tıkanma: 1 sn'de 0,6 m'den az ilerleme → engelin kenarından dolaş (yana 90°, 2,5 sn; dolaşırken de
		# tıkanırsa öbür yana), arada zıpla; dolaşma bitince asıl yöne dön
		stuck_t += dt
		if stuck_t > 1.0:
			if Vector2(p.x - last.x, p.z - last.z).length() < 0.6:
				if blockers.size() < 40:
					blockers.append(_blocker(p, d))
				stucks += 1
				if veer != 0.0:
					side = -side
				veer = side * PI * 0.5 if stucks % 4 != 0 else PI
				veer_t = 2.5
				if player.is_on_floor():
					player.jump()
			stuck_t = 0.0
			last = p
		if veer_t > 0.0:
			veer_t -= dt
			if veer_t <= 0.0:
				veer = 0.0
	Input.action_release("move_forward")
	return {"out": out, "shore": shore, "moved": moved}


func _blocker(p: Vector3, d: Vector3) -> String:
	var hit := {}
	for hy in [0.9, 0.25, 1.6]:
		var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, hy, 0), p + Vector3(0, hy, 0) + d * 1.5)
		q.exclude = [player.get_rid()]
		hit = player.get_world_3d().direct_space_state.intersect_ray(q)
		if not hit.is_empty():
			break
	if hit.is_empty():
		return "none@%s v=%s fl=%s fz=%s" % [Vector3i(p), Vector3i(player.velocity), player.is_on_floor(), player.frozen]
	var c := hit["collider"] as Node
	var info := ""
	var sid: int = hit.get("shape", 0)
	if c is CollisionObject3D:
		var co := c as CollisionObject3D
		var owner_id := co.shape_find_owner(sid)
		var sh := co.shape_owner_get_shape(owner_id, 0) if co.shape_owner_get_shape_count(owner_id) > 0 else null
		var ow := co.shape_owner_get_owner(owner_id)
		info = " shape=%s" % [(sh as BoxShape3D).size if sh is BoxShape3D else (sh.get_class() if sh else "?")]
		if ow is Node3D:
			info += " at=%s" % Vector3i((ow as Node3D).global_position)
		if c.get_parent():
			info += " par=%s" % c.get_parent().name
	return "%s%s@%s" % [str(c.get_path()).replace("/root/", "").left(70), info, Vector3i(hit["position"])]


func _near_water(p: Vector3) -> bool:
	for w in walks:
		var wp := w.world.global_transform.affine_inverse() * p
		for o: Vector2 in [Vector2.ZERO, Vector2(4, 0), Vector2(-4, 0), Vector2(0, 4), Vector2(0, -4)]:
			if World1453.is_water(wp.x + o.x, wp.z + o.y):
				return true
	return false
