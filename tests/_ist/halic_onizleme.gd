extends Node3D
## Haliç önizleme ve denetim. Kullanım:
##  -- ist=<id|virgüllü|all> k=0.5 lod=0 shots=KLASÖR [audit=1]
## Kareler PNG (1280x720) ve ISTAUDIT satırları.

const IDS := ["sur", "eugenios", "venedik", "pisa_amalfi", "ceneviz", "yahudi", "neorion", "iskele", "balik", "petrion", "fener"]
var ids: Array = []
var k := 0.5
var lod := 0
var shots := ""
var do_audit := true
var cam: Camera3D
var holder: Node3D


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("ist="):
			var v := a.substr(4)
			ids = IDS.duplicate() if v == "all" else Array(v.split(","))
		elif a.begins_with("k="):
			k = float(a.substr(2))
		elif a.begins_with("lod="):
			lod = int(a.substr(4))
		elif a.begins_with("shots="):
			shots = a.substr(6)
		elif a.begins_with("audit="):
			do_audit = a.substr(6) == "1"
	if ids.is_empty():
		ids = ["sur"]
	_setup_world()
	call_deferred("_run")


func _setup_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("5a8fd0")
	sm.sky_horizon_color = Color("d8e4ee")
	sm.ground_horizon_color = Color("a89c80")
	sm.ground_bottom_color = Color("6a6048")
	sky.sky_material = sm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -35, 0)
	sun.light_color = Color("ffe2b8")
	sun.light_energy = 0.95
	sun.shadow_enabled = true
	add_child(sun)
	var floor_body := StaticBody3D.new()
	add_child(floor_body)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(800, 1, 420)
	cs.shape = bs
	cs.position = Vector3(0, -0.5, 209)
	floor_body.add_child(cs)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = bs.size
	mi.mesh = bm
	mi.material_override = Props.mat(Color("8d7f5f"), 0.0, false, "cobble")
	mi.position = cs.position
	floor_body.add_child(mi)
	cam = Camera3D.new()
	cam.fov = 70
	cam.far = 800
	add_child(cam)
	cam.current = true
	holder = Node3D.new()
	add_child(holder)


func _build(id: String, l: int) -> Node3D:
	var h := Node3D.new()
	holder.add_child(h)
	IstHalic.build(id, h, k, l)
	return h


func _aabb(n: Node3D) -> AABB:
	var ab := AABB()
	var first := true
	for m in n.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null or not mi.visible:
			continue
		var a := mi.global_transform * mi.get_aabb()
		if first:
			ab = a
			first = false
		else:
			ab = ab.merge(a)
	return ab


func _look(pos: Vector3, target: Vector3) -> void:
	cam.global_position = pos
	cam.look_at(target, Vector3.UP)


func _save(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	if shots == "":
		return
	DirAccess.make_dir_recursive_absolute(shots)
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%s.png" % [shots, name])


func _run() -> void:
	get_window().size = Vector2i(1280, 720)
	for id in ids:
		for c in holder.get_children():
			c.queue_free()
		await get_tree().process_frame
		var node := _build(id, lod)
		await get_tree().process_frame
		var ab := _aabb(node)
		var c := ab.get_center()
		var r := maxf(ab.size.x, ab.size.z) * 0.5
		var tgt := Vector3(c.x, minf(ab.size.y * 0.35, 6.0), c.z)
		if shots != "":
			var dist := r * 0.9 + 12.0
			var dirs := {"G": Vector3(0, 0, -1), "K": Vector3(0, 0, 1), "D": Vector3(1, 0, 0), "B": Vector3(-1, 0, 0)}
			for dn in dirs.keys():
				_look(Vector3(c.x, 1.7, c.z) + dirs[dn] * dist, tgt)
				await _save("%s_yaklasma_%s" % [id, dn])
			var cl := IstHalic.climbs(id, k)
			if cl.size() > 0:
				var a: Vector3 = cl[0][0]
				var b: Vector3 = cl[0][1]
				_look(a + Vector3(0, 1.7, 0) - (b - a).normalized() * 0.0 + Vector3(0, 0, 0), b + Vector3(0, 1.0, 0))
				cam.global_position = a + Vector3(0, 1.7, 0) + ((a - b) * Vector3(1, 0, 1)).normalized() * 3.0
				cam.look_at(b + Vector3(0, 0.5, 0), Vector3.UP)
				await _save("%s_kapi_onu" % id)
				_look(b + Vector3(0, 1.7, 0), Vector3(c.x, b.y + 1.0, c.z))
				await _save("%s_ust_goz" % id)
			_look(c + Vector3(0, 15, r * 0.7 + 8.0), c + Vector3(0, 2, 0))
			await _save("%s_kus15" % id)
			_look(c + Vector3(0, 60, r * 0.8 + 20.0), c)
			await _save("%s_kus60" % id)
			cam.global_position = c + Vector3(0, 90, 0.1)
			cam.look_at(c, Vector3(0, 0, -1))
			await _save("%s_tepe" % id)
			for l in [1, 2]:
				node.queue_free()
				await get_tree().process_frame
				node = _build(id, l)
				await get_tree().process_frame
				_look(c + Vector3(r * 0.6, 40, r * 0.8 + 10.0), c)
				await _save("%s_lod%d" % [id, l])
			node.queue_free()
			await get_tree().process_frame
			node = _build(id, lod)
			await get_tree().process_frame
		if do_audit:
			await _audit(id, node)
	get_tree().quit()


func _tris(n: Node) -> int:
	var t := 0
	for m in n.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null or not mi.visible:
			continue
		for s in mi.mesh.get_surface_count():
			var arr := mi.mesh.surface_get_arrays(s)
			if arr.size() > Mesh.ARRAY_INDEX and arr[Mesh.ARRAY_INDEX] != null and (arr[Mesh.ARRAY_INDEX] as PackedInt32Array).size() > 0:
				t += (arr[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
			elif arr[Mesh.ARRAY_VERTEX] != null:
				t += (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	for m in n.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := (m as MultiMeshInstance3D).multimesh
		if mm == null or mm.mesh == null:
			continue
		var per := 0
		for s in mm.mesh.get_surface_count():
			var arr := mm.mesh.surface_get_arrays(s)
			if arr[Mesh.ARRAY_INDEX] != null and (arr[Mesh.ARRAY_INDEX] as PackedInt32Array).size() > 0:
				per += (arr[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
			else:
				per += (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
		t += per * mm.instance_count
	return t


func _draws(n: Node) -> int:
	var d := 0
	for m in n.find_children("*", "GeometryInstance3D", true, false):
		if (m as Node3D).visible:
			d += 1
	return d


func _in_body(n: Node) -> bool:
	var p := n.get_parent()
	while p != null:
		if p is StaticBody3D:
			return true
		p = p.get_parent()
	return false


func _audit(id: String, node: Node3D) -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	var space := get_world_3d().direct_space_state
	var ab := _aabb(node)
	var tris0 := _tris(node)
	var draws := _draws(node)
	# lod üçgenleri
	var tl: Array = [tris0]
	for l in [1, 2]:
		var tmp := _build(id, l)
		tl.append(_tris(tmp))
		tmp.free()
	# Delik: çarpışmasız büyük görünür kütle
	var holes := 0
	var big: Array = []
	for m in node.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null or _in_body(mi) or mi.mesh is PlaneMesh or mi.mesh is CylinderMesh or mi.mesh is SphereMesh or mi.mesh is PrismMesh or mi.mesh is ArrayMesh:
			continue
		var a := mi.global_transform * mi.get_aabb()
		if a.size.y > 2.5 and minf(a.size.x, a.size.z) > 1.5:
			big.append(a)
	for a: AABB in big:
		var h0 := holes
		var x := a.position.x + 0.25
		while x < a.end.x:
			var z := a.position.z + 0.25
			while z < a.end.z:
				var q := PhysicsRayQueryParameters3D.create(Vector3(x, a.end.y + 5.0, z), Vector3(x, a.position.y + 0.1, z))
				var hit := space.intersect_ray(q)
				if hit.is_empty() or (hit["position"].y < 0.3 and a.end.y > 2.5):
					holes += 1
				z += 0.5
			x += 0.5
		if holes > h0:
			print("DELIK ", id, " aabb=", a, " n=", holes - h0)
	# Dar aralık: y=1.0 yüksekliğinde iki katı arası 0,2-1,4 m
	var dar := 0
	var x2 := ab.position.x
	var seen := {}
	while x2 < ab.end.x:
		var z2 := ab.position.z
		while z2 < ab.end.z:
			var p := Vector3(x2, 1.0, z2)
			var free := space.intersect_point(_pt(p), 1).is_empty()
			if free:
				for ax in [Vector3.RIGHT, Vector3.BACK]:
					var r1 := space.intersect_ray(PhysicsRayQueryParameters3D.create(p, p + ax * 1.5))
					var r2 := space.intersect_ray(PhysicsRayQueryParameters3D.create(p, p - ax * 1.5))
					if not r1.is_empty() and not r2.is_empty():
						var gap: float = (r1["position"] as Vector3).distance_to(r2["position"])
						if gap > 0.2 and gap < 1.4:
							seen[Vector2i(int(x2 * 2), int(z2 * 2))] = true
			z2 += 0.5
		x2 += 0.5
	dar = seen.size()
	# Havada: tabanı >5cm yukarıda ve altında 30 cm içinde destek yok
	var havada := 0
	for b in node.find_children("*", "StaticBody3D", true, false):
		var sb := b as StaticBody3D
		for ch in sb.get_children():
			if ch is CollisionShape3D and (ch as CollisionShape3D).shape is BoxShape3D:
				var cs := ch as CollisionShape3D
				var bs := cs.shape as BoxShape3D
				var gt := cs.global_transform
				var bottom := gt.origin.y - bs.size.y * 0.5
				if bottom > 0.05 and gt.basis.get_euler().length() < 0.05:
					var sup := false
					for off in [Vector2(0, 0), Vector2(0.4, 0.4), Vector2(-0.4, -0.4), Vector2(0.4, -0.4), Vector2(-0.4, 0.4)]:
						var o := Vector3(gt.origin.x + off.x * bs.size.x * 0.5, bottom - 0.01, gt.origin.z + off.y * bs.size.z * 0.5)
						var q2 := PhysicsRayQueryParameters3D.create(o, o + Vector3(0, -0.3, 0))
						q2.exclude = [sb.get_rid()]
						q2.hit_from_inside = true
						if not space.intersect_ray(q2).is_empty():
							sup = true
							break
					if not sup:
						havada += 1
						print("HAVADA ", id, " ", sb.name, " y=", snappedf(bottom, 0.01), " @", gt.origin)
	# Çatı yolu: gerçek CharacterBody3D ile
	var cl := IstHalic.climbs(id, k)
	var ok := 0
	var details := ""
	for e in cl:
		var res := _walk(e[0], e[1])
		if res:
			ok += 1
		details += " %s:%s" % [e[2], "OK" if res else "YOK"]
	print("ISTAUDIT id=%s tris=%d/%d/%d draws=%d delik=%d dar=%d havada=%d cati_yolu=%d/%d%s" % [id, tl[0], tl[1], tl[2], draws, holes, dar, havada, ok, cl.size(), details])


func _pt(p: Vector3) -> PhysicsPointQueryParameters3D:
	var q := PhysicsPointQueryParameters3D.new()
	q.position = p
	return q


func _walk(a: Vector3, b: Vector3) -> bool:
	var body := CharacterBody3D.new()
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	cs.shape = cap
	cs.position = Vector3(0, 0.9, 0)
	body.add_child(cs)
	body.floor_max_angle = deg_to_rad(46)
	body.floor_snap_length = 0.4
	add_child(body)
	body.global_position = a + Vector3(0, 0.05, 0)
	var stuck := 0.0
	var last := body.global_position
	var best := 1e9
	var ok := false
	var dt := 1.0 / 60.0
	for i in 60 * 70:
		var to := b - body.global_position
		var h := Vector3(to.x, 0, to.z)
		var dirv := h.normalized() if h.length() > 0.05 else Vector3.ZERO
		body.velocity.x = dirv.x * 3.0
		body.velocity.z = dirv.z * 3.0
		if not body.is_on_floor():
			body.velocity.y -= 9.8 * dt
		else:
			body.velocity.y = 0.0
			if stuck > 0.25:
				body.velocity.y = 3.6
				stuck = 0.0
		body.move_and_slide()
		if body.global_position.distance_to(last) < 0.01 * 1.0:
			stuck += dt
		else:
			stuck = 0.0
		last = body.global_position
		if absf(body.global_position.y - b.y) < 1.0 and Vector2(to.x, to.z).length() < 1.2:
			ok = true
			break
	body.free()
	return ok
