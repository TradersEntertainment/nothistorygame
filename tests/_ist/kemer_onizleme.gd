extends Node3D
## Kemer parçası önizleme ve denetim sahnesi.
##   godot --path . res://tests/_ist/kemer_onizleme.tscn -- ist=bozdogan k=0.5 lod=0 shots=KLASÖR [audit=1] [only=ad1,ad2]
## ist=hepsi: bütün öğeleri sırayla. shots verilmezse yalnız denetim (ISTAUDIT) basılır.

const IST := preload("res://scripts/world/ist/kemer.gd")

var args := {}
var host: Node3D
var cam: Camera3D
var ground: StaticBody3D
var shots_dir := ""
var center := Vector3.ZERO
var size := Vector3.ONE
var top := 10.0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=")
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	shots_dir = String(args.get("shots", ""))
	if shots_dir != "":
		DirAccess.make_dir_recursive_absolute(shots_dir)
	_make_world()
	var k := float(args.get("k", "0.5"))
	var lod := int(args.get("lod", "0"))
	var ids: Array = IST.IDS if String(args.get("ist", "bozdogan")) == "hepsi" else [String(args.get("ist", "bozdogan"))]
	var t0 := Time.get_ticks_msec()
	for id: String in ids:
		await _run_one(id, k, lod)
	print("ISTDONE ms=", Time.get_ticks_msec() - t0)
	get_tree().quit()


func _make_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var pm := ProceduralSkyMaterial.new()
	pm.sky_top_color = Color("6fa6d8")
	pm.sky_horizon_color = Color("e9d9b8")
	pm.ground_horizon_color = Color("d8c8a0")
	pm.ground_bottom_color = Color("8a7c5a")
	sky.sky_material = pm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -50, 0)
	sun.light_color = Color("ffe2b0")
	sun.light_energy = 0.95
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 220.0
	add_child(sun)
	ground = StaticBody3D.new()
	var gm := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1600, 1, 1600)
	gm.mesh = bm
	gm.position = Vector3(0, -0.5, 0)
	var gmat := StandardMaterial3D.new()
	gmat.albedo_color = Color("6f8a4a")
	gm.material_override = gmat
	ground.add_child(gm)
	var gc := CollisionShape3D.new()
	var gs := BoxShape3D.new()
	gs.size = bm.size
	gc.shape = gs
	gc.position = gm.position
	ground.add_child(gc)
	add_child(ground)
	cam = Camera3D.new()
	cam.fov = 70.0
	cam.far = 2500.0
	add_child(cam)
	cam.current = true


func _build(id: String, k: float, lod: int) -> void:
	if host != null:
		host.queue_free()
		await get_tree().process_frame
	host = Node3D.new()
	host.name = "Host"
	add_child(host)
	IST.build(id, host, k, lod)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	_measure()


func _measure() -> void:
	var lo := Vector3(1e9, 1e9, 1e9)
	var hi := Vector3(-1e9, -1e9, -1e9)
	for n in host.find_children("*", "VisualInstance3D", true, false):
		var v := n as VisualInstance3D
		if v is MultiMeshInstance3D:
			var mm := (v as MultiMeshInstance3D).multimesh
			for i in mm.instance_count:
				var t := v.global_transform * mm.get_instance_transform(i)
				var a := t * mm.mesh.get_aabb()
				lo = lo.min(a.position)
				hi = hi.max(a.end)
			continue
		var ab := v.global_transform * v.get_aabb()
		lo = lo.min(ab.position)
		hi = hi.max(ab.end)
	size = hi - lo
	center = (lo + hi) * 0.5
	top = hi.y


func _run_one(id: String, k: float, lod: int) -> void:
	await _build(id, k, lod)
	var tag := "%s_k%s" % [id, str(k)]
	if shots_dir != "":
		await _shots(id, k, tag)
	if lod == 0 or args.has("audit"):
		await _audit(id, k, lod)
	if shots_dir != "" and lod == 0:
		for l in [1, 2]:
			await _build(id, k, l)
			await _shot_bird(tag + "_lod%d" % l, 15.0)
			if l == 2:
				print("ISTTRIS id=%s lod=%d tris=%d" % [id, 2, _count_tris()[0]])
			else:
				print("ISTTRIS id=%s lod=%d tris=%d" % [id, 1, _count_tris()[0]])


func _focus() -> Dictionary:
	var c := center
	var sz := Vector2(size.x, size.z)
	if String(host.get_child(0).name) == "Bozdogan":
		c = Vector3(0, center.y, 0)
		sz = Vector2(60, 60)
	return {"c": c, "r": maxf(sz.x, sz.y)}


func _shot(name: String, pos: Vector3, look: Vector3) -> void:
	cam.global_position = pos
	cam.look_at(look, Vector3.UP if absf((look - pos).normalized().y) < 0.98 else Vector3.FORWARD)
	await RenderingServer.frame_post_draw
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%s.png" % [shots_dir, name])


func _shots(id: String, k: float, tag: String) -> void:
	var f := _focus()
	var c: Vector3 = f["c"]
	var R := clampf(float(f["r"]) * 0.55 + 14.0, 20.0, 110.0)
	var look_y := clampf(top * 0.4, 1.5, 14.0)
	var dirs := {"kuzey": Vector3(0, 0, -1), "dogu": Vector3(1, 0, 0), "guney": Vector3(0, 0, 1), "bati": Vector3(-1, 0, 0)}
	var linear := String(host.get_child(0).name) == "Bozdogan"
	for dn: String in dirs:
		var d: Vector3 = dirs[dn]
		var off := Vector3.ZERO
		if linear:
			# eksen z boyunca: eksen üstündeki bakışlar pilyelerin içine düşer; yandan kaydır
			off = Vector3(9.0, 0, 0) if absf(d.z) > 0.5 else Vector3.ZERO
		await _shot("%s_goz_%s" % [tag, dn], Vector3(c.x, 1.7, c.z) + d * R + off, Vector3(c.x, look_y, c.z))
	var cl: Array = IST.climbs(id, k)
	if cl.size() > 0:
		var alt: Vector3 = cl[0][0]
		var ust: Vector3 = cl[0][1]
		var dir := (ust - alt)
		dir.y = 0
		dir = dir.normalized()
		await _shot(tag + "_kapi_onu", alt - dir * 1.5 + Vector3(0, 1.7, 0) + Vector3(0, 0, 0), alt + dir * 6.0 + Vector3(0, 3.0, 0))
		await _shot(tag + "_ust_goz", ust + Vector3(0, 1.7, 0), Vector3(c.x, ust.y + 2.0, c.z))
		await _shot(tag + "_ust_goz2", ust + Vector3(0, 1.7, 0), ust + dir * 8.0 + Vector3(0, 1.6, 0))
	var pr: Array = IST.perches(id, k)
	if pr.size() > 0:
		var pp: Vector3 = pr[0]
		await _shot(tag + "_konma", pp + Vector3(8, 6, 8), pp)
	await _shot_bird(tag + "_kus15", 15.0)
	await _shot_bird(tag + "_kus60", 60.0)
	await _shot(tag + "_tepe", Vector3(c.x, top + maxf(60.0, float(f["r"]) * 0.9), c.z + 0.01), c)


func _shot_bird(name: String, h: float) -> void:
	var f := _focus()
	var c: Vector3 = f["c"]
	var R := clampf(float(f["r"]) * 0.6 + 10.0, 14.0, 100.0)
	await _shot(name, Vector3(c.x + R * 0.7, top + h, c.z + R * 0.7), Vector3(c.x, top * 0.5, c.z))


func _count_tris() -> Array:
	var tris := 0
	var draws := 0
	for n in host.find_children("*", "MeshInstance3D", true, false):
		var m := n as MeshInstance3D
		if m.mesh != null and m.visible:
			tris += m.mesh.get_faces().size() / 3
			draws += 1
	for n in host.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := (n as MultiMeshInstance3D).multimesh
		if mm != null:
			tris += mm.instance_count * (mm.mesh.get_faces().size() / 3)
			draws += 1
	return [tris, draws]


func _audit(id: String, k: float, lod: int) -> void:
	var td := _count_tris()
	var space := get_world_3d().direct_space_state
	# görsel üçgen gövdesi (katman 2): bütün görünen ağlar dünya koordinatında tek bir gövdede
	var faces := PackedVector3Array()
	for n in host.find_children("*", "MeshInstance3D", true, false):
		var m := n as MeshInstance3D
		if m.mesh == null or not m.visible:
			continue
		var small := m.mesh.get_aabb().size[m.mesh.get_aabb().size.max_axis_index()] < 0.3
		if small:
			continue
		var f := m.mesh.get_faces()
		var gt := m.global_transform
		for v in f:
			faces.append(gt * v)
	for n in host.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := (n as MultiMeshInstance3D).multimesh
		var mf := mm.mesh.get_faces()
		var ab := mm.mesh.get_aabb()
		if ab.size[ab.size.max_axis_index()] < 0.3:
			continue
		for i in mm.instance_count:
			var gt2 := (n as MultiMeshInstance3D).global_transform * mm.get_instance_transform(i)
			for v in mf:
				faces.append(gt2 * v)
	var vb := StaticBody3D.new()
	vb.collision_layer = 2
	vb.collision_mask = 0
	var cs := CollisionShape3D.new()
	var shp := ConcavePolygonShape3D.new()
	shp.set_faces(faces)
	cs.shape = shp
	vb.add_child(cs)
	add_child(vb)
	await get_tree().physics_frame
	await get_tree().physics_frame
	# --- delik: görünür yüzey ile çarpışma farkı (0,5 m ızgara)
	var lo := center - size * 0.5
	var hi := center + size * 0.5
	var delik := 0
	var samples: Array = []
	var step := 0.5
	var cells := (size.x / step) * (size.z / step)
	if cells > 60000.0:
		step = sqrt(size.x * size.z / 60000.0)
	var x := lo.x
	while x <= hi.x:
		var z := lo.z
		while z <= hi.z:
			var from := Vector3(x, hi.y + 3.0, z)
			var to := Vector3(x, -2.0, z)
			var qv := PhysicsRayQueryParameters3D.create(from, to, 2)
			var rv := space.intersect_ray(qv)
			if not rv.is_empty():
				var qc := PhysicsRayQueryParameters3D.create(from, to, 1)
				var rc := space.intersect_ray(qc)
				var yv: float = rv["position"].y
				var yc: float = rc["position"].y if not rc.is_empty() else 0.0
				var dy := yv - yc
				if dy > 0.3 and dy < 2.0:
					delik += 1
					if samples.size() < 5:
						samples.append(Vector3(x, yv, z))
			z += step
		x += step
	# --- dar: 0,2–1,4 m girilebilir aralık (iki yükseklikte, çizgi taraması)
	var dar := 0
	var dar_s: Array = []
	for hy in [0.6, 1.5]:
		var sph := SphereShape3D.new()
		sph.radius = 0.06
		var qs := PhysicsShapeQueryParameters3D.new()
		qs.shape = sph
		qs.collision_mask = 1
		var spacing := maxf(0.5, size.x * size.z / 2500.0 / 1.0)
		spacing = minf(spacing, 6.0)
		for axis in [0, 1]:
			var line := (lo.z if axis == 0 else lo.x)
			var line_hi := (hi.z if axis == 0 else hi.x)
			while line <= line_hi:
				var occ: Array = []
				var p := (lo.x if axis == 0 else lo.z)
				var p_hi := (hi.x if axis == 0 else hi.z)
				var pos_list: Array = []
				while p <= p_hi:
					var pt := Vector3(p, hy, line) if axis == 0 else Vector3(line, hy, p)
					qs.transform = Transform3D(Basis.IDENTITY, pt)
					occ.append(not space.intersect_shape(qs, 1).is_empty())
					pos_list.append(pt)
					p += 0.1
				var i := 0
				while i < occ.size():
					if occ[i]:
						var j := i + 1
						while j < occ.size() and not occ[j]:
							j += 1
						if j < occ.size():
							var gap := (j - i - 1) * 0.1
							if gap >= 0.2 and gap <= 1.4:
								dar += 1
								if dar_s.size() < 5:
									dar_s.append(pos_list[i])
						i = j
					else:
						i += 1
				line += spacing
	# --- havada: tabanı yerden > 5 cm yukarıda, altında destek bulunmayan düz kutu
	var havada := 0
	var hav_s: Array = []
	for b in host.find_children("*", "CollisionShape3D", true, false):
		var cshape := b as CollisionShape3D
		var bs := cshape.shape as BoxShape3D
		if bs == null:
			continue
		var gt3 := cshape.global_transform
		if absf(gt3.basis.y.dot(Vector3.UP)) < 0.995:
			continue
		var bottom := gt3.origin.y - bs.size.y * 0.5
		if bottom < 0.05:
			continue
		var supported := false
		for off in [Vector2(0, 0), Vector2(0.4, 0.4), Vector2(-0.4, 0.4), Vector2(0.4, -0.4), Vector2(-0.4, -0.4)]:
			var px := gt3.origin + gt3.basis * Vector3(off.x * bs.size.x * 0.5, 0, off.y * bs.size.z * 0.5)
			var q := PhysicsRayQueryParameters3D.create(Vector3(px.x, bottom + 0.03, px.z), Vector3(px.x, bottom - 0.2, px.z), 1)
			q.exclude = [cshape.get_parent().get_rid()] if cshape.get_parent() is CollisionObject3D else []
			var r := space.intersect_ray(q)
			if not r.is_empty():
				supported = true
				break
		if not supported:
			havada += 1
			if hav_s.size() < 5:
				hav_s.append(gt3.origin)
	# --- cati_yolu: gerçek CharacterBody3D ile climbs_x
	var cl: Array = IST.climbs(id, k)
	var okc := 0
	for e: Array in cl:
		if await _climb_ok(e[0], e[1]):
			okc += 1
	vb.queue_free()
	print("ISTAUDIT id=%s k=%s lod=%d tris=%d draws=%d delik=%d dar=%d havada=%d cati_yolu=%d/%d" % [id, str(k), lod, td[0], td[1], delik, dar, havada, okc, cl.size()])
	if delik > 0:
		print("  delik örnek: ", samples)
	if dar > 0:
		print("  dar örnek: ", dar_s)
	if havada > 0:
		print("  havada örnek: ", hav_s)


func _climb_ok(from: Vector3, to: Vector3) -> bool:
	var cb := CharacterBody3D.new()
	var cap := CollisionShape3D.new()
	var cp := CapsuleShape3D.new()
	cp.radius = 0.35
	cp.height = 1.8
	cap.shape = cp
	cb.add_child(cap)
	cb.collision_mask = 1
	cb.collision_layer = 0
	add_child(cb)
	cb.global_position = from + Vector3(0, 0.95, 0)
	cb.floor_snap_length = 0.3
	cb.floor_max_angle = deg_to_rad(46.0)
	await get_tree().physics_frame
	var ok := false
	for step in 2400:
		var flat := Vector3(to.x - cb.global_position.x, 0, to.z - cb.global_position.z)
		var dist := flat.length()
		if dist < 0.7 and cb.global_position.y - 0.9 >= to.y - 0.5:
			ok = true
			break
		var dirv := flat.normalized() if dist > 0.05 else Vector3.ZERO
		var hv := dirv * 3.2
		if not cb.is_on_floor():
			cb.velocity.y -= 9.8 / 60.0
		else:
			cb.velocity.y = 0.0
			var t := cb.global_transform
			if hv.length() > 0.0 and cb.test_move(t, hv / 60.0 * 1.5):
				var up := Vector3(0, 0.42, 0)
				if not cb.test_move(t, up) and not cb.test_move(t.translated(up), hv / 60.0 * 1.5):
					cb.global_position += up
				else:
					cb.velocity.y = 3.6
		cb.velocity.x = hv.x
		cb.velocity.z = hv.z
		cb.move_and_slide()
		await get_tree().physics_frame
	cb.queue_free()
	return ok
