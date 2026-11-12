extends Node3D
## Galata önizleme + denetim. Komut satırı: -- ist=<id|all> k=0.5 lod=0 shots=KLASÖR [mod=audit|shots|both]
## ISTAUDIT satırı basar; shots verilirse 1280x720 PNG'ler yazar.

var _ids: Array = []
var _k := 0.5
var _lod := 0
var _dir := ""
var _mode := "both"
var _host: Node3D
var _cam: Camera3D
var _floor: StaticBody3D


func _ready() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	_k = float(args.get("k", "0.5"))
	_lod = int(args.get("lod", "0"))
	_dir = str(args.get("shots", ""))
	_mode = str(args.get("mod", "both"))
	var want := str(args.get("ist", "all"))
	_ids = IstGalata.IDS.duplicate() if want == "all" else want.split(",")
	_scene()
	await get_tree().process_frame
	for id in _ids:
		await _one(str(id))
	get_tree().quit()


func _scene() -> void:
	_floor = StaticBody3D.new()
	add_child(_floor)
	var fm := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(600, 1, 600)
	fm.mesh = bm
	fm.position = Vector3(0, -0.5, 0)
	fm.material_override = Props.mat(Color("a89868"), 0.0, false, "cobble", false)
	_floor.add_child(fm)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(600, 1, 600)
	cs.shape = bs
	cs.position = Vector3(0, -0.5, 0)
	_floor.add_child(cs)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -55, 0)
	sun.light_color = Color("ffe2b8")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var pm := ProceduralSkyMaterial.new()
	pm.sky_top_color = Color("7aa8d8")
	pm.sky_horizon_color = Color("e8d8b8")
	pm.ground_horizon_color = Color("c8b890")
	sky.sky_material = pm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.9
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	_cam = Camera3D.new()
	_cam.fov = 70.0
	_cam.far = 800.0
	add_child(_cam)
	_cam.current = true


func _make(id: String, lod: int) -> Node3D:
	var n := Node3D.new()
	add_child(n)
	IstGalata.build(id, n, _k, lod)
	return n


func _bounds(n: Node3D) -> AABB:
	var bb := AABB()
	var first := true
	var stack: Array = [n]
	while not stack.is_empty():
		var c: Node = stack.pop_back()
		for ch in c.get_children():
			stack.append(ch)
		if c is VisualInstance3D and not (c is Light3D):
			var a: AABB = (c as VisualInstance3D).global_transform * (c as VisualInstance3D).get_aabb()
			if first:
				bb = a
				first = false
			else:
				bb = bb.merge(a)
	return bb


func _tris(n: Node3D) -> Array:
	var tris := 0
	var draws := 0
	var stack: Array = [n]
	while not stack.is_empty():
		var c: Node = stack.pop_back()
		for ch in c.get_children():
			stack.append(ch)
		if c is MeshInstance3D and (c as MeshInstance3D).mesh:
			tris += (c as MeshInstance3D).mesh.get_faces().size() / 3
			draws += 1
		elif c is MultiMeshInstance3D:
			var m := (c as MultiMeshInstance3D).multimesh
			tris += m.mesh.get_faces().size() / 3 * m.instance_count
			draws += 1
	return [tris, draws]


func _one(id: String) -> void:
	_host = _make(id, 0 if _lod == 3 else _lod)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var bb := _bounds(_host)
	var t0 := _tris(_host)
	var t1: Array
	var t2: Array
	if _mode != "shots":
		var h1 := _make(id, 1)
		t1 = _tris(h1)
		h1.queue_free()
		var h2 := _make(id, 2)
		t2 = _tris(h2)
		h2.queue_free()
		_audit(id, bb, t0, t1, t2)
	if _dir != "" and _mode != "audit":
		await _shots(id, bb)
	_host.queue_free()
	await get_tree().process_frame


func _audit(id: String, bb: AABB, t0: Array, t1: Array, t2: Array) -> void:
	var space := get_world_3d().direct_space_state
	var x0 := bb.position.x
	var z0 := bb.position.z
	var x1 := bb.end.x
	var z1 := bb.end.z
	# dar: y=0.9'da 0,5 m ızgara; iki katı arasında 1–2 hücrelik (0,5–1,0 m) boş koşular
	var nx := int((x1 - x0) / 0.5) + 1
	var nz := int((z1 - z0) / 0.5) + 1
	var grid: Array = []
	var q := PhysicsPointQueryParameters3D.new()
	q.collide_with_bodies = true
	for iz in nz:
		var row: Array = []
		for ix in nx:
			var solid := false
			for off in [Vector2(0, 0), Vector2(0.15, 0), Vector2(-0.15, 0), Vector2(0, 0.15), Vector2(0, -0.15)]:
				q.position = Vector3(x0 + ix * 0.5 + 0.25 + off.x, 0.9, z0 + iz * 0.5 + 0.25 + off.y)
				for r in space.intersect_point(q, 2):
					if r["collider"] != _floor:
						solid = true
			row.append(solid)
		grid.append(row)
	var dar := 0
	for iz in nz:
		var run := 0
		var seen := false
		for ix in nx:
			if grid[iz][ix]:
				if seen and run >= 1 and run <= 2:
					dar += 1
					if dar <= 6:
						print("  DAR id=%s x=%.1f z=%.1f (x yönü, %d hücre)" % [id, x0 + (ix - run) * 0.5, z0 + iz * 0.5, run])
				run = 0
				seen = true
			elif seen:
				run += 1
	for ix in nx:
		var run := 0
		var seen := false
		for iz in nz:
			if grid[iz][ix]:
				if seen and run >= 1 and run <= 2:
					dar += 1
					if dar <= 12:
						print("  DAR id=%s x=%.1f z=%.1f (z yönü, %d hücre)" % [id, x0 + ix * 0.5, z0 + (iz - run) * 0.5, run])
				run = 0
				seen = true
			elif seen:
				run += 1
	# delik: büyük görsel kütle (çarpışmasız ebeveyn) ortasında katı yok
	var delik := 0
	var stack: Array = [_host]
	while not stack.is_empty():
		var c: Node = stack.pop_back()
		for ch in c.get_children():
			stack.append(ch)
		if c is MeshInstance3D and not (c.get_parent() is StaticBody3D):
			var m := c as MeshInstance3D
			var a: AABB = m.global_transform * m.get_aabb()
			if a.size.y >= 2.5 and a.size.x >= 1.2 and a.size.z >= 1.2 and m.mesh is BoxMesh == false and m.mesh is CylinderMesh:
				q.position = a.get_center()
				var hit := space.intersect_point(q, 1)
				if hit.is_empty():
					delik += 1
	# havada: tabanı >5 cm yukarıda olup altında/yanında dokunan başka katı olmayan gövde
	var bodies: Array = []
	stack = [_host]
	while not stack.is_empty():
		var c: Node = stack.pop_back()
		for ch in c.get_children():
			stack.append(ch)
		if c is StaticBody3D:
			var cs: CollisionShape3D = null
			for ch in c.get_children():
				if ch is CollisionShape3D:
					cs = ch
			if cs and cs.shape:
				var sh: Shape3D = cs.shape
				var loc: AABB
				if sh is BoxShape3D:
					loc = AABB(-sh.size * 0.5, sh.size)
				else:
					loc = sh.get_debug_mesh().get_aabb()
				bodies.append(cs.global_transform * loc)
	var haval := 0
	for i in bodies.size():
		var a: AABB = bodies[i]
		if a.position.y <= 0.05:
			continue
		var sup := false
		var g := a.grow(0.06)
		for j in bodies.size():
			if j != i and (bodies[j] as AABB).intersects(g) and (bodies[j] as AABB).position.y < a.position.y + 0.02:
				sup = true
				break
		if not sup:
			haval += 1
	# çatı yolu: climbs noktaları arasında 0,2 m aralıkla yükseklik profili; basamak ≤ STEP_H (0,42)
	var cl: Array = IstGalata.climbs(id, _k)
	var ok := 0
	for c in cl:
		var a: Vector3 = c[0]
		var b: Vector3 = c[1]
		var good := true
		var prev := 0.0
		var steps := int(a.distance_to(b)) * 6 + 6
		var xz_a := Vector2(a.x, a.z)
		var xz_b := Vector2(b.x, b.z)
		for s in range(0, steps + 1):
			var p := xz_a.lerp(xz_b, float(s) / steps)
			var rq := PhysicsRayQueryParameters3D.create(Vector3(p.x, b.y + 3.0, p.y), Vector3(p.x, -1.0, p.y))
			var r := space.intersect_ray(rq)
			var y: float = r["position"].y if not r.is_empty() else 0.0
			if y - prev > 0.43:
				if good:
					print("  CATI_SORUN id=%s adim=%d xz=(%.2f,%.2f) y=%.2f onceki=%.2f" % [id, s, p.x, p.y, y, prev])
				good = false
			prev = y
		if absf(prev - b.y) > 0.5:
			print("  CATI_SORUN id=%s uc y=%.2f beklenen=%.2f" % [id, prev, b.y])
			good = false
		if good:
			ok += 1
	print("ISTAUDIT id=%s k=%.2f tris=%d/%d/%d draws=%d/%d/%d delik=%d dar=%d havada=%d cati_yolu=%d/%d" % [
		id, _k, t0[0], t1[0], t2[0], t0[1], t1[1], t2[1], delik, dar, haval, ok, cl.size()])


func _shot(name: String, pos: Vector3, look: Vector3) -> void:
	_cam.global_position = pos
	var up := Vector3.UP if absf((look - pos).normalized().y) < 0.98 else Vector3.FORWARD
	_cam.look_at(look, up)
	await RenderingServer.frame_post_draw
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(_dir)
	img.save_png("%s/%s.png" % [_dir, name])


func _shots(id: String, bb: AABB) -> void:
	var c := bb.get_center()
	var r := maxf(bb.size.x, bb.size.z) * 0.5
	var top := bb.end.y
	var lookc := Vector3(c.x, minf(top * 0.45, 12.0), c.z)
	var dist := r + maxf(10.0, top * 0.8)
	var names := ["on", "doguy", "arka", "bati"]
	for i in 4:
		var a := PI * 0.5 * i
		await _shot("%s_k%02d_yaklasma_%s" % [id, int(_k * 100), names[i]], Vector3(c.x + sin(a) * dist, 1.7, c.z + cos(a) * dist), lookc)
	await _shot("%s_k%02d_kapi" % [id, int(_k * 100)], Vector3(c.x + 1.5, 1.7, bb.end.z + 5.0), Vector3(c.x, 1.6, bb.end.z))
	var cl: Array = IstGalata.climbs(id, _k)
	if cl.size() > 0:
		var up: Vector3 = cl[0][1]
		await _shot("%s_k%02d_cati" % [id, int(_k * 100)], up + Vector3(0, 1.7, 0), Vector3(c.x, up.y + 1.0, c.z))
	await _shot("%s_k%02d_kus15" % [id, int(_k * 100)], Vector3(c.x + r * 0.7, top + 15.0, c.z + r * 1.3), Vector3(c.x, top * 0.5, c.z))
	await _shot("%s_k%02d_kus60" % [id, int(_k * 100)], Vector3(c.x + 30.0, top + 60.0, c.z + 50.0), Vector3(c.x, top * 0.4, c.z))
	await _shot("%s_k%02d_tepe" % [id, int(_k * 100)], Vector3(c.x, top + maxf(40.0, r * 2.2), c.z + 0.01), Vector3(c.x, 0, c.z))
	for l in [1, 2]:
		var hh := _make(id, l)
		_host.visible = false
		await _shot("%s_k%02d_lod%d" % [id, int(_k * 100), l], Vector3(c.x + r * 0.7, top + 12.0, c.z + r * 1.3), Vector3(c.x, top * 0.5, c.z))
		hh.queue_free()
		_host.visible = true
