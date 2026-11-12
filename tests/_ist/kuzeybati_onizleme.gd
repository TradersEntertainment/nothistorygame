extends Node3D
## Kuzeybati önizleme + denetim.  Komut satırı: -- ist=<id> k=0.5 lod=0 shots=KLASÖR [audit=1]
##   xvfb-run -a -s "-screen 0 1280x720x24" $G --path . --resolution 1280x720 res://tests/_ist/kuzeybati_onizleme.tscn -- ist=khora k=0.5 shots=/yol
## Çıktı: PNG kareler + "ISTAUDIT id=… tris=… draws=… delik=… dar=… havada=… cati_yolu=…" satırı.

var id := "khora"
var k := 0.5
var lod := 0
var shots := ""
var host: Node3D
var cam: Camera3D
var center := Vector3.ZERO
var ext := Vector3(20, 10, 20)
var top := 10.0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("ist="): id = a.trim_prefix("ist=")
		elif a.begins_with("k="): k = float(a.trim_prefix("k="))
		elif a.begins_with("lod="): lod = int(a.trim_prefix("lod="))
		elif a.begins_with("shots="): shots = a.trim_prefix("shots=")
	_scene()
	_run.call_deferred()


func _scene() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var psm := ProceduralSkyMaterial.new()
	psm.sky_top_color = Color("6f9fd8")
	psm.sky_horizon_color = Color("d8e0e8")
	psm.ground_horizon_color = Color("d8e0e8")
	psm.ground_bottom_color = Color("8a9a7a")
	sky.sky_material = psm
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.5
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -125, 0)
	sun.light_color = Color("fff0d8")
	sun.light_energy = 0.8
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 220.0
	add_child(sun)
	var g := Props.solid(self, Vector3(500, 1.0, 500), Vector3(0, -0.5, 0), Color.WHITE)
	Props.set_pattern(g, Color("6f8a45"), "")
	g.name = "Zemin"
	cam = Camera3D.new()
	cam.fov = 70.0
	cam.near = 0.05
	cam.far = 800.0
	add_child(cam)


func _build(l: int) -> void:
	if host != null:
		host.free()
	host = Node3D.new()
	host.name = "Host"
	add_child(host)
	IstKuzeybati.build(id, host, k, l)


func _measure() -> void:
	var ab := AABB()
	var first := true
	for n in host.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh == null:
			continue
		var b := mi.global_transform * mi.mesh.get_aabb()
		ab = b if first else ab.merge(b)
		first = false
	center = ab.get_center()
	ext = ab.size
	top = ab.end.y
	center.y = 0.0


func _shot(name: String, pos: Vector3, target: Vector3, fov := 70.0) -> void:
	cam.fov = fov
	cam.look_at_from_position(pos, target, Vector3.UP)
	await get_tree().process_frame
	await get_tree().process_frame
	if shots != "":
		get_viewport().get_texture().get_image().save_png("%s/%s_%s.png" % [shots, id, name])


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	_build(lod)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	_measure()
	var r := maxf(ext.x, ext.z) * 0.5
	var d := r + 9.0
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
		var dirs := {"K": Vector3(0, 0, -1), "D": Vector3(1, 0, 0), "G": Vector3(0, 0, 1), "B": Vector3(-1, 0, 0)}
		for nm in dirs:
			await _shot("yer_" + nm, center + dirs[nm] * d + Vector3(0, 1.7, 0), center + Vector3(0, minf(top * 0.4, 5.0), 0), 75.0)
		await _shot("yakin_g", center + Vector3(0, 1.7, 0) + Vector3(0.6, 0, 1).normalized() * (r + 3.5), center + Vector3(0, 2.0, 0), 80.0)
		var cl: Array = IstKuzeybati.climbs(id, k)
		if cl.size() > 0:
			var up: Vector3 = cl[0][1]
			await _shot("cati", host.global_transform * up + Vector3(0, 1.7, 0), center + Vector3(0, top * 0.6, 0), 80.0)
		await _shot("kus15", center + Vector3(d * 0.9, top + 15.0, d * 0.9), center + Vector3(0, top * 0.5, 0), 70.0)
		await _shot("kus60", center + Vector3(40, 60.0, 40), center, 55.0)
		await _shot("tepe", center + Vector3(0.01, maxf(40.0, r * 2.4), 0.01), center, 55.0)
		await _shot("kus45a", center + Vector3(-d, top + 12.0, d * 0.4), center + Vector3(0, top * 0.5, 0), 70.0)
		await _shot("kus45b", center + Vector3(-d * 0.4, top + 12.0, -d), center + Vector3(0, top * 0.5, 0), 70.0)
		for l in [1, 2]:
			_build(l)
			await get_tree().process_frame
			await _shot("lod%d" % l, center + Vector3(d * 0.9, top + 15.0, d * 0.9), center + Vector3(0, top * 0.5, 0), 70.0)
		_build(lod)
		await get_tree().process_frame
	await _audit()
	get_tree().quit()


# ------------------------------------------------------------------------------------------------------------
func _tris(node: Node) -> int:
	var t := 0
	for n in node.find_children("*", "MeshInstance3D", true, false):
		var m := (n as MeshInstance3D).mesh
		if m != null:
			t += m.get_faces().size() / 3
	for n in node.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := (n as MultiMeshInstance3D).multimesh
		if mm != null and mm.mesh != null:
			t += (mm.mesh.get_faces().size() / 3) * mm.instance_count
	return t


func _audit() -> void:
	var tris := [0, 0, 0]
	for l in 3:
		_build(l)
		await get_tree().process_frame
		tris[l] = _tris(host)
	_build(lod)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	_measure()
	var cam_p := center + Vector3(ext.x, ext.y + 15.0, ext.z) * 0.6
	cam.look_at_from_position(cam_p, center + Vector3(0, top * 0.5, 0), Vector3.UP)
	await get_tree().process_frame
	await get_tree().process_frame
	var draws := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var space := get_world_3d().direct_space_state
	var ground_rid: RID = (get_node("Zemin") as CollisionObject3D).get_rid()
	# --- ağsız cisim (delik): görünür büyük ağın merkezi hiçbir çarpışma şeklinde değil
	var delik := 0
	for n in host.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh == null:
			continue
		var ab := mi.mesh.get_aabb()
		if ab.size.x * ab.size.y * ab.size.z * mi.global_transform.basis.get_scale().x * mi.global_transform.basis.get_scale().y * mi.global_transform.basis.get_scale().z < 1.5:
			continue
		var pq := PhysicsPointQueryParameters3D.new()
		pq.position = mi.global_transform * ab.get_center()
		if space.intersect_point(pq, 1).is_empty():
			delik += 1
			print("  delik: ", mi.get_path(), " ", pq.position)
	# --- dar: y=0,5…1,4 aralıkta iki katı arasındaki 0,2–1,4 m yatay aralık
	var dar_cells := {}
	var x0 := center.x - ext.x * 0.5 - 1.0
	var x1 := center.x + ext.x * 0.5 + 1.0
	var z0 := center.z - ext.z * 0.5 - 1.0
	var z1 := center.z + ext.z * 0.5 + 1.0
	var st := 0.5
	var xx := x0
	while xx <= x1:
		var zz := z0
		while zz <= z1:
			for yy in [0.7, 1.3]:
				var p := Vector3(xx, yy, zz)
				var pq := PhysicsPointQueryParameters3D.new()
				pq.position = p
				if not space.intersect_point(pq, 1).is_empty():
					continue
				for ax in [Vector3.RIGHT, Vector3.BACK]:
					var q1 := PhysicsRayQueryParameters3D.create(p, p + ax * 1.5)
					var q2 := PhysicsRayQueryParameters3D.create(p, p - ax * 1.5)
					var h1 := space.intersect_ray(q1)
					var h2 := space.intersect_ray(q2)
					if h1.is_empty() or h2.is_empty():
						continue
					var w: float = (h1.position as Vector3).distance_to(h2.position)
					if w > 0.2 and w < 1.4 and (h1.normal as Vector3).dot(h2.normal) < -0.9:
						dar_cells["%d,%d" % [int(xx / 2.0), int(zz / 2.0)]] = true
			zz += st
		xx += st
	# --- havada: katı gövdelerin tabanı altındaki yüzeyden > 5 cm yukarıda mı
	var havada := 0
	for b in host.find_children("*", "StaticBody3D", true, false):
		var body := b as StaticBody3D
		for cs in body.find_children("*", "CollisionShape3D", false, false):
			var csn := cs as CollisionShape3D
			if csn.shape == null:
				continue
			var dm := csn.shape.get_debug_mesh()
			var wab: AABB = csn.global_transform * dm.get_aabb()
			var bottom := wab.position.y
			var gaps: Array = []
			for off in [Vector2(0.5, 0.5), Vector2(0.2, 0.2), Vector2(0.8, 0.2), Vector2(0.2, 0.8), Vector2(0.8, 0.8)]:
				var px: float = wab.position.x + wab.size.x * off.x
				var pz: float = wab.position.z + wab.size.z * off.y
				var q := PhysicsRayQueryParameters3D.create(Vector3(px, bottom + 0.01, pz), Vector3(px, bottom - 20.0, pz))
				q.exclude = [body.get_rid()]
				var h := space.intersect_ray(q)
				gaps.append((bottom - float(h.position.y)) if not h.is_empty() else 99.0)
			var pq2 := PhysicsPointQueryParameters3D.new()
			pq2.position = Vector3(wab.position.x + wab.size.x * 0.5, bottom - 0.02, wab.position.z + wab.size.z * 0.5)
			pq2.exclude = [body.get_rid()]
			if not space.intersect_point(pq2, 1).is_empty():
				continue
			if gaps.min() > 0.05:
				havada += 1
				print("  havada: ", body.get_path(), " bottom=", bottom, " gap=", gaps.min())
	# --- sokaktan çatıya yol: gerçek CharacterBody3D ile yürü / basamak (0,42) / zıpla (0,62)
	var cl: Array = IstKuzeybati.climbs(id, k)
	var ok := 0
	for e in cl:
		if await _walk(e[0], e[1]):
			ok += 1
	print("ISTAUDIT id=%s k=%s tris=%d/%d/%d draws=%d delik=%d dar=%d havada=%d cati_yolu=%d/%d" % [id, k, tris[0], tris[1], tris[2], draws, delik, dar_cells.size(), havada, ok, cl.size()])


func _walk(a: Vector3, b: Vector3) -> bool:
	var cb := CharacterBody3D.new()
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	cs.shape = cap
	cb.add_child(cs)
	cb.collision_mask = 1
	add_child(cb)
	var start := host.global_transform * a
	cb.global_position = start + Vector3(0, 1.0, 0)
	cb.move_and_collide(Vector3(0, -3.0, 0))
	var goal := host.global_transform * b
	var good := false
	for i in 600:
		var dxz := Vector3(goal.x - cb.global_position.x, 0, goal.z - cb.global_position.z)
		if dxz.length() < 0.35 and cb.global_position.y > goal.y - 0.2:
			good = true
			break
		var step := dxz.normalized() * minf(0.1, dxz.length())
		if not cb.test_move(cb.global_transform, step):
			cb.global_position += step
		else:
			var moved := false
			for hh in [0.42, 0.62]:
				var up := Vector3(0, hh, 0)
				if not cb.test_move(cb.global_transform, up):
					var t := cb.global_transform
					t.origin += up
					if not cb.test_move(t, step):
						cb.global_position += up + step
						moved = true
						break
			if not moved:
				break
		cb.move_and_collide(Vector3(0, -1.0, 0))
	if not good:
		print("  yol_basarisiz: ", a, "->", b, " dur=", cb.global_position, " hedef=", goal)
	cb.queue_free()
	return good
