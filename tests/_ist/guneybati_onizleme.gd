extends Node3D
## Güneybatı parçası önizleme + denetim.  -- ist=<id|hepsi> k=0.5 lod=0 shots=KLASÖR
const G := preload("res://scripts/world/ist/guneybati.gd")

var _id := "studios"
var _k := 0.5
var _lod := 0
var _dir := ""
var _host: Node3D
var _cam: Camera3D


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("ist="): _id = a.substr(4)
		elif a.begins_with("k="): _k = float(a.substr(2))
		elif a.begins_with("lod="): _lod = int(a.substr(4))
		elif a.begins_with("shots="): _dir = a.substr(6)
	var env := Environment.new()
	var sky := ProceduralSkyMaterial.new()
	sky.sky_top_color = Color("3f7fc4")
	sky.sky_horizon_color = Color("cfdde6")
	var s := Sky.new()
	s.sky_material = sky
	env.sky = s
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("ffe0b8")
	sun.rotation_degrees = Vector3(-42, -35, 0)
	sun.shadow_enabled = true
	add_child(sun)
	var ground := StaticBody3D.new()
	add_child(ground)
	var gm := Props.box(ground, Vector3(900, 1, 900), Vector3(0, -0.5, 0), Color("9a8d6a"))
	Props.set_pattern(gm, Color("9a8d6a"), "cobble")
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(900, 1, 900)
	cs.shape = bs
	cs.position = Vector3(0, -0.5, 0)
	ground.add_child(cs)
	_host = Node3D.new()
	add_child(_host)
	_cam = Camera3D.new()
	_cam.fov = 70
	_cam.far = 2000
	add_child(_cam)
	_cam.current = true
	await get_tree().process_frame
	G.build(_id, _host, _k, _lod)
	for i in 3:
		await get_tree().physics_frame
	var tris := _count()
	print("ISTAUDIT_BASLA id=", _id, " k=", _k, " lod=", _lod)
	if _dir != "":
		await _shots()
	var au: Dictionary = await _audit()
	print("ISTAUDIT id=%s k=%s lod=%d tris=%d draws=%d delik=%d dar=%d havada=%d cati_yolu=%s" % [_id, _k, _lod, tris, au["draws"], au["delik"], au["dar"], au["havada"], au["yol"]])
	get_tree().quit()


func _count() -> int:
	var t := 0
	for n in _host.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh != null:
			var m := mi.mesh
			for sidx in m.get_surface_count():
				var arr := m.surface_get_arrays(sidx)
				var idx = arr[Mesh.ARRAY_INDEX]
				t += (idx.size() if idx != null else (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
	for n in _host.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := (n as MultiMeshInstance3D).multimesh
		var per := 0
		for sidx in mm.mesh.get_surface_count():
			var arr := mm.mesh.surface_get_arrays(sidx)
			var idx = arr[Mesh.ARRAY_INDEX]
			per += (idx.size() if idx != null else (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
		t += per * mm.instance_count
	return t


func _bounds() -> AABB:
	var ab := AABB()
	var first := true
	for n in _host.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		var a := mi.global_transform * mi.get_aabb()
		if first:
			ab = a
			first = false
		else:
			ab = ab.merge(a)
	return ab


func _look(from: Vector3, at: Vector3, name: String) -> void:
	_cam.global_position = from
	_cam.look_at(at, Vector3.UP if absf((at - from).normalized().y) < 0.98 else Vector3.FORWARD)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%s_%s_k%s_l%d.png" % [_dir, _id, name, str(_k), _lod])


func _shots() -> void:
	DirAccess.make_dir_recursive_absolute(_dir)
	var ab := _bounds()
	var c := ab.get_center()
	var r := maxf(ab.size.x, ab.size.z) * 0.5
	var top := ab.position.y + ab.size.y
	var eye := 1.7
	var pers: Array = G.perches(_id, _k)
	var cl: Array = G.climbs(_id, _k)
	var dirs := {"G": Vector3(0, 0, 1), "D": Vector3(1, 0, 0), "K": Vector3(0, 0, -1), "B": Vector3(-1, 0, 0)}
	for dn in dirs:
		var d: Vector3 = dirs[dn]
		await _look(Vector3(c.x, eye, c.z) + d * (r + 14.0), Vector3(c.x, minf(top * 0.3, 4.0), c.z), "yer" + dn)
	if _lod == 0:
		# 45° dört yön 15 m yakın uçuş
		var diag := [Vector3(1, 0, 1), Vector3(-1, 0, 1), Vector3(1, 0, -1), Vector3(-1, 0, -1)]
		var i := 0
		for d2 in diag:
			var dd: Vector3 = d2.normalized()
			await _look(c + dd * (r * 0.9 + 6.0) + Vector3(0, top + 12.0, 0), c + Vector3(0, top * 0.4, 0), "ucus%d" % i)
			i += 1
		for p in pers:
			await _look(p + Vector3(2.5, 1.7, 2.5), p + Vector3(-6, 0, -6), "cati%d" % pers.find(p))
			break
		var j := 0
		for cc in cl:
			var lo: Vector3 = cc[0]
			var hi: Vector3 = cc[1]
			var dirv := (hi - lo)
			dirv.y = 0
			dirv = dirv.normalized() if dirv.length() > 0.01 else Vector3.FORWARD
			await _look(lo - dirv * 2.0 + Vector3(0, 1.7, 0), hi + Vector3(0, 1.0, 0), "tirman%d" % j)
			j += 1
			if j >= 2: break
	await _look(Vector3(c.x, top + 60.0, c.z + r * 0.35), c, "kus60")
	await _look(Vector3(c.x, maxf(top + 15.0, r * 1.3), c.z + 0.01), c, "tepe")
	await _look(c + Vector3(r * 1.0 + 25.0, top + 25.0, r * 1.0 + 25.0), c, "orta")


## Otomatik denetim (yaklaşık): ızgara + gerçek CharacterBody3D ile tırmanma
func _audit() -> Dictionary:
	var res := {"draws": 0, "delik": 0, "dar": 0, "havada": 0, "yol": "0/0"}
	res["draws"] = _host.find_children("*", "MeshInstance3D", true, false).size() + _host.find_children("*", "MultiMeshInstance3D", true, false).size()
	var ab := _bounds()
	var space := get_world_3d().direct_space_state
	var delik := 0
	var sx := int(ab.size.x / 0.5)
	var sz := int(ab.size.z / 0.5)
	# büyük (≥ 0.6 m) çarpışmasız görünür üst yüzey: mesh AABB üstü ile ışın çarpması farkı
	var big: Array = []
	for n in _host.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		var a := mi.global_transform * mi.get_aabb()
		if a.size.x >= 1.0 and a.size.z >= 1.0 and a.size.y >= 0.5 and mi.global_transform.basis.get_euler().length() < 0.02 and not (mi.mesh is SphereMesh) and not (mi.mesh is PrismMesh):
			big.append(a)
	for a in big:
		var cx: float = a.position.x + a.size.x * 0.5
		var cz: float = a.position.z + a.size.z * 0.5
		var q := PhysicsRayQueryParameters3D.create(Vector3(cx, a.position.y + a.size.y + 5.0, cz), Vector3(cx, -2.0, cz))
		var hit := space.intersect_ray(q)
		if hit.is_empty() or (hit["position"] as Vector3).y < a.position.y + a.size.y - 0.35:
			delik += 1
			print("DELIK ", a)
	res["delik"] = delik
	# girilebilir dar aralık: ızgarada, ayak yüksekliğinde sağ-sol ışınlar (0.2–1.4 m boşluk)
	var dar := 0
	var step := 1.0 if ab.size.x * ab.size.z > 4000.0 else 0.5
	var x := ab.position.x
	while x < ab.position.x + ab.size.x:
		var z := ab.position.z
		while z < ab.position.z + ab.size.z:
			var o: Vector3 = Vector3(x, 1.0, z)
			var qb := PhysicsPointQueryParameters3D.new()
			qb.position = o
			if space.intersect_point(qb, 1).is_empty():
				var l := _free(space, o, Vector3.LEFT)
				var r2 := _free(space, o, Vector3.RIGHT)
				if l > 0.0 and r2 > 0.0 and l < 1.0e5 and r2 < 1.0e5 and l + r2 > 0.2 and l + r2 < 1.4:
					dar += 1
			z += step * 2.0
		x += step * 2.0
	res["dar"] = dar
	# havada kütle: alt yüzü > 5 cm yukarıda, altı boş (ışın aşağı çarpmadan zemine)
	var hv := 0
	for n in _host.find_children("*", "StaticBody3D", true, false):
		var sb := n as StaticBody3D
		for c in sb.get_children():
			if c is CollisionShape3D and (c as CollisionShape3D).shape is BoxShape3D:
				var bs := (c as CollisionShape3D).shape as BoxShape3D
				var gt := (c as CollisionShape3D).global_transform
				if gt.basis.get_euler().length() > 0.05:
					continue
				var bottom := gt.origin.y - bs.size.y * 0.5
				if bottom > 0.05:
					var q2 := PhysicsRayQueryParameters3D.create(Vector3(gt.origin.x, bottom - 0.02, gt.origin.z), Vector3(gt.origin.x, -1.0, gt.origin.z))
					q2.exclude = [sb.get_rid()]
					q2.hit_from_inside = true
					var h2 := space.intersect_ray(q2)
					if h2.is_empty() or (h2["position"] as Vector3).y < bottom - 3.5:
						hv += 1
						print("HAVADA ", gt.origin, bs.size)
	res["havada"] = hv
	res["yol"] = await _climb_test()
	return res


func _free(space: PhysicsDirectSpaceState3D, o: Vector3, d: Vector3) -> float:
	var q := PhysicsRayQueryParameters3D.create(o, o + d * 1.4)
	var h := space.intersect_ray(q)
	if h.is_empty():
		return 1.0e6
	return o.distance_to(h["position"])


## Her climbs() çifti için gerçek CharacterBody3D: alt noktadan üst noktaya yürü, zıpla (JUMP 3.6, g 9.8).
func _climb_test() -> String:
	var cl: Array = G.climbs(_id, _k)
	var ok := 0
	for c in cl:
		var lo: Vector3 = c[0]
		var hi: Vector3 = c[1]
		var b := CharacterBody3D.new()
		var cap := CollisionShape3D.new()
		var cs := CapsuleShape3D.new()
		cs.radius = 0.35
		cs.height = 1.8
		cap.shape = cs
		b.add_child(cap)
		b.floor_max_angle = deg_to_rad(46.0)
		b.floor_snap_length = 0.4
		add_child(b)
		b.global_position = lo + Vector3(0, 0.95, 0)
		var target := Vector3(hi.x, hi.y, hi.z)
		var reached := false
		var t := 0
		var vy := 0.0
		while t < 900 and not reached:
			var dir := target - b.global_position
			dir.y = 0
			var hd: Vector3 = dir.normalized() * 3.0 if dir.length() > 0.2 else Vector3.ZERO
			b.velocity.x = hd.x
			b.velocity.z = hd.z
			if b.is_on_floor():
				vy = 0.0
				if b.is_on_wall() and t % 6 == 0:
					vy = 3.6
			vy -= 9.8 / 60.0
			b.velocity.y = vy
			# oyuncudaki gibi alçak basamak (STEP_H 0,42): önü kapalıysa ve 0,42 yukarısı boşsa yukarı al
			if hd.length() > 0.1 and b.is_on_floor():
				var mv := hd / 60.0 * 1.5
				if b.test_move(b.global_transform, mv):
					var up := b.global_transform.translated(Vector3(0, 0.42, 0))
					if not b.test_move(up, mv) and not b.test_move(b.global_transform, Vector3(0, 0.42, 0)):
						b.global_position.y += 0.42
			b.move_and_slide()
			if b.is_on_floor():
				vy = 0.0
			if b.global_position.y - 0.95 >= hi.y - 0.35 and Vector2(b.global_position.x - target.x, b.global_position.z - target.z).length() < 1.2:
				reached = true
			t += 1
			await get_tree().physics_frame
		if reached:
			ok += 1
		else:
			print("CLIMBFAIL ", c[2], " alt=", lo, " ust=", hi, " son=", b.global_position)
		b.queue_free()
	return "%d/%d" % [ok, cl.size()]
