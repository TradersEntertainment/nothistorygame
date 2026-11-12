extends Node3D
## Sur parçaları önizleme ve denetim sahnesi.
##   godot --path . res://tests/_ist/surlar_onizleme.tscn -- ist=<id|hepsi> k=0.5 lod=0 shots=KLASOR [audit=1]
## Kareler: oyuncu gözünden dört yönden yaklaşma, kapı önü, sur üstü, dış sur üstü, kule tepesi, 15 m / 60 m kuş
## bakışı, tam tepe, 45° dört yön, lod 1 ve lod 2. Ayrıca ISTAUDIT satırı basar.

var _id := "sur"
var _k := 0.5
var _lod := 0
var _dir := ""
var _audit_only := false
var _host: Node3D
var _cam: Camera3D
var _L := 100.0
var _d: Dictionary = {}
var _lay: Dictionary = {}
var _dbg := 0
var _dbg_ab := AABB()


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"ist": _id = kv[1]
			"k": _k = float(kv[1])
			"lod": _lod = int(kv[1])
			"shots": _dir = kv[1]
			"audit": _audit_only = kv[1] == "only"
	_run()


func _length(id: String) -> float:
	if id == "sur":
		return maxf(110.0 * _k, 90.0)
	return IstSurlar._gate_len(id, _k)


func _env() -> void:
	var we := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var pm := ProceduralSkyMaterial.new()
	pm.sky_top_color = Color("5f8fc8")
	pm.sky_horizon_color = Color("e8d9b8")
	pm.ground_horizon_color = Color("9aa86a")
	pm.ground_bottom_color = Color("6f7a45")
	sky.sky_material = pm
	e.sky = sky
	e.background_mode = Environment.BG_SKY
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	e.fog_enabled = false
	we.environment = e
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("ffe2b0")
	sun.light_energy = 0.95
	sun.rotation_degrees = Vector3(-38, -62, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 220.0
	add_child(sun)
	var fl := MeshInstance3D.new()
	var pl := PlaneMesh.new()
	pl.size = Vector2(1200, 1200)
	fl.mesh = pl
	fl.position.y = -1.6
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color("6f7a45")
	fl.material_override = fm
	add_child(fl)
	_cam = Camera3D.new()
	_cam.fov = 70.0
	_cam.far = 900.0
	add_child(_cam)
	_cam.current = true


func _build(lod: int, bake := true) -> void:
	IstSurlar.bake = bake
	if _host:
		_host.queue_free()
		await get_tree().process_frame
	_host = Node3D.new()
	_host.name = "Host"
	add_child(_host)
	IstSurlar.build_by_id(_host, _id, _k, lod)


func _shot(name: String, from: Vector3, to: Vector3, up := Vector3.UP) -> void:
	_cam.look_at_from_position(from, to, up)
	for i in 3:
		await get_tree().process_frame
	if _dir != "":
		var img := get_viewport().get_texture().get_image()
		img.save_png("%s/%s_%s.png" % [_dir, _id, name])


func _run() -> void:
	_env()
	_L = _length(_id)
	_d = IstSurlar.dims(_k)
	var o: Dictionary = IstSurlar.OPTS.get(_id, {})
	_lay = IstSurlar._layout(_L, _k, 1453 if _id == "sur" else 1000 + _id.hash() % 997, o)
	await _build(_lod, false)
	for i in 3:
		await get_tree().physics_frame
	await _audit()
	await _build(_lod, true)
	for i in 3:
		await get_tree().physics_frame
	_stats(_lod)
	if _audit_only:
		get_tree().quit(0)
		return
	var T: float = _d["T"]
	var HW: float = _d["HW"]
	var OH: float = _d["OH"]
	var zi0: float = _d["zi0"]
	var zo0: float = _d["zo0"]
	var zo1: float = _d["zo1"]
	var zm0: float = _d["zm0"]
	var zm1: float = _d["zm1"]
	var HT: float = _d["HT"]
	var itx: Array = _lay["itx"]
	var tx: float = float(itx[0]["x"]) if itx.size() > 0 else 0.0
	var zc := (zi0 + zm1) * 0.5
	var far := zm1 + 12.0
	await _shot("a1_dis_orta", Vector3(0, 1.7, far), Vector3(0, HW * 0.6, 0))
	await _shot("a2_dis_sol", Vector3(-_L * 0.28, 1.7, far - 4.0), Vector3(-_L * 0.1, HW * 0.5, 0))
	await _shot("a3_dis_sag", Vector3(_L * 0.28, 1.7, far - 4.0), Vector3(_L * 0.1, HW * 0.5, 0))
	await _shot("a4_sehir", Vector3(0, 1.7, zi0 - 11.0), Vector3(0, HW * 0.55, 0))
	await _shot("b1_kapi_onu", Vector3(0, 1.7, zm0 - 3.0), Vector3(0, 2.5, 0))
	await _shot("b2_kule_dibi", Vector3(tx + 5.0, 1.7, zo1 + 14.0), Vector3(tx, HW * 0.4, T * 0.5 + 3.0))
	await _shot("c1_sur_ustu", Vector3(tx + 4.0, HW + 1.7, 0.0), Vector3(tx + 40.0, HW + 1.3, 0.0))
	await _shot("c2_dis_sur_ustu", Vector3(tx + 4.0, OH + 1.7, (zo0 + zo1) * 0.5), Vector3(tx + 40.0, OH + 1.3, (zo0 + zo1) * 0.5))
	await _shot("c3_kule_ici", Vector3(tx - 1.0, HW + 1.7, 0.2), Vector3(tx + 2.0, HW + 1.2, 3.0))
	await _shot("c4_kule_cati", Vector3(tx, HT + 1.7, 0.0), Vector3(tx + 8.0, HT, 14.0))
	await _shot("d1_kus_15m", Vector3(-_L * 0.12, HW + 15.0, zm0 + 8.0), Vector3(_L * 0.02, HW, 6.0))
	await _shot("d2_kus_60m", Vector3(-_L * 0.2, HW + 60.0, zm1 + 28.0), Vector3(0, 0, zc - 4.0))
	await _shot("d3_tepe", Vector3(0, 90.0, zc), Vector3(0, 0, zc), Vector3(0, 0, -1))
	var tgt := Vector3(0, HW, 4.0)
	await _shot("e1_45_gb", tgt + Vector3(-34, 24, 34), tgt)
	await _shot("e2_45_gd", tgt + Vector3(34, 24, 34), tgt)
	await _shot("e3_45_kb", tgt + Vector3(-34, 24, -34), tgt)
	await _shot("e4_45_kd", tgt + Vector3(34, 24, -34), tgt)
	for lod in [1, 2]:
		await _build(lod)
		await get_tree().physics_frame
		await _shot("f%d_lod%d" % [lod, lod], tgt + Vector3(-34, 24, 34), tgt)
		_stats(lod)
	print("ISTSHOTS TAMAM ", _id)
	get_tree().quit(0)


# ------------------------------------------------------------------ denetim

func _stats(lod: int) -> void:
	var tris := 0
	var draws := 0
	for n in _host.find_children("*", "VisualInstance3D", true, false):
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			if mi.mesh and mi.visible:
				tris += mi.mesh.get_faces().size() / 3
				draws += 1
		elif n is MultiMeshInstance3D:
			var mm := (n as MultiMeshInstance3D).multimesh
			if mm and mm.mesh:
				tris += mm.mesh.get_faces().size() / 3 * mm.instance_count
				draws += 1
	print("ISTTRIS id=%s k=%.2f lod=%d tris=%d draws=%d" % [_id, _k, lod, tris, draws])


func _audit() -> void:
	_stats(_lod)
	var space := get_world_3d().direct_space_state
	var L := _L
	var zi0: float = _d["zi0"]
	var zm1: float = _d["zm1"]
	# --- delik: büyük görünür kütlelerin üstü ile çarpışma yüzeyi
	var masses: Array = []
	for n in _host.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh == null or mi.mesh is PrismMesh or mi.get_parent() is OccluderInstance3D:
			continue
		var ab := mi.global_transform * mi.mesh.get_aabb()
		if mi.global_transform.basis.get_euler().length() > 0.05:
			continue
		var sz := ab.size
		if minf(sz.x, minf(sz.y, sz.z)) < 0.7 or ab.end.y < 0.3:
			continue
		if mi.mesh is CylinderMesh or mi.mesh is SphereMesh:
			continue
		masses.append(ab)
	var delik := 0
	var x := -L * 0.5 + 0.25
	while x < L * 0.5:
		var z := zi0 - 4.0
		while z < zm1:
			var top := -1e9
			for ab in masses:
				var a: AABB = ab
				if x >= a.position.x + 0.1 and x <= a.end.x - 0.1 and z >= a.position.z + 0.1 and z <= a.end.z - 0.1:
					if a.end.y > top:
						top = a.end.y
						_dbg_ab = a
			if top > 0.3:
				var q := PhysicsRayQueryParameters3D.create(Vector3(x, 200, z), Vector3(x, -30, z))
				var h := space.intersect_ray(q)
				var hy: float = h["position"].y if not h.is_empty() else -99.0
				if top - hy > 0.45:
					delik += 1
					if delik <= 4:
						print("  delik: x=%.1f z=%.1f gorunen=%.2f carpisma=%.2f kutu=%s" % [x, z, top, hy, _dbg_ab])
			z += 0.5
		x += 0.5
	# --- dar: 0,2–1,4 m girilebilir aralık (x ve z doğrultusunda, üç yükseklikte)
	var dar := 0
	var levels: Array = [1.0, float(_d["OH"]) + 1.0, float(_d["HW"]) + 1.0]
	var pq := PhysicsPointQueryParameters3D.new()
	for yy in levels:
		# x doğrultusunda çizgiler (z sabit)
		var zz := zi0 - 3.0
		while zz < zm1:
			dar += _scan(space, pq, true, zz, yy, -L * 0.5, L * 0.5)
			zz += 0.77
		var xx := -L * 0.5 + 0.3
		while xx < L * 0.5:
			dar += _scan(space, pq, false, xx, yy, zi0 - 3.0, zm1)
			xx += 1.31
	# --- havada: tabanı zeminden yüksekte ve altında destek olmayan katı
	var havada := 0
	for n in _host.find_children("*", "StaticBody3D", true, false):
		var sb := n as StaticBody3D
		if sb.has_meta("proxy"):
			continue
		for c in sb.get_children():
			if c is CollisionShape3D and (c as CollisionShape3D).shape != null:
				var cs := c as CollisionShape3D
				var ab2: AABB
				if cs.shape is BoxShape3D:
					var bs := cs.shape as BoxShape3D
					ab2 = sb.global_transform * cs.transform * AABB(-bs.size * 0.5, bs.size)
				elif cs.shape is ConvexPolygonShape3D:
					var pts := (cs.shape as ConvexPolygonShape3D).points
					var mn := Vector3(1e9, 1e9, 1e9)
					var mx := Vector3(-1e9, -1e9, -1e9)
					for pnt in pts:
						var g := sb.global_transform * cs.transform * pnt
						mn = mn.min(g)
						mx = mx.max(g)
					ab2 = AABB(mn, mx - mn)
				else:
					continue
				if ab2.position.y > 0.05:
					var ok := false
					var ins := minf(0.35, minf(ab2.size.x, ab2.size.z) * 0.25)
					var pts2: Array = []
					for fx in [ab2.position.x + ins, ab2.get_center().x, ab2.end.x - ins]:
						for fz in [ab2.position.z + ins, ab2.get_center().z, ab2.end.z - ins]:
							pts2.append(Vector2(fx, fz))
					for pt in pts2:
						var q2 := PhysicsRayQueryParameters3D.create(Vector3(pt.x, ab2.position.y + 0.02, pt.y), Vector3(pt.x, ab2.position.y - 0.12, pt.y))
						q2.exclude = [sb.get_rid()]
						if not space.intersect_ray(q2).is_empty():
							ok = true
							break
					if not ok:
						# yandan destek (kapı üstü lento): kenara yaslı katı var mı
						var c3 := ab2.get_center()
						var hs := ab2.size * 0.5
						for off in [Vector3(hs.x + 0.1, 0, 0), Vector3(-hs.x - 0.1, 0, 0), Vector3(0, 0, hs.z + 0.1), Vector3(0, 0, -hs.z - 0.1)]:
							var pp := PhysicsPointQueryParameters3D.new()
							pp.position = Vector3(c3.x, ab2.position.y + 0.1, c3.z) + off
							if not space.intersect_point(pp, 1).is_empty():
								ok = true
								break
					if not ok:
						havada += 1
						if havada <= 6:
							print("  havada: ", sb.get_path(), " ab=", ab2)
	# --- cati_yolu: climbs_x girişleri gerçek bir CharacterBody3D ile sınanır
	var climbs: Array = IstSurlar._climbs(L, _k, 1453 if _id == "sur" else 1000 + _id.hash() % 997, IstSurlar.OPTS.get(_id, {}))
	var okc := 0
	for c in climbs:
		var ok2: bool = await _walk(c[0], c[1])
		if ok2:
			okc += 1
		else:
			print("  yol basarisiz: ", c[0], " -> ", c[1])
	print("ISTAUDIT id=%s k=%.2f lod=%d delik=%d dar=%d havada=%d cati_yolu=%d/%d" % [_id, _k, _lod, delik, dar, havada, okc, climbs.size()])


func _scan(space: PhysicsDirectSpaceState3D, pq: PhysicsPointQueryParameters3D, along_x: bool, fixed: float, y: float, a: float, b: float) -> int:
	var cnt := 0
	var t := a
	var prev_solid := false
	var empty_start := -1e9
	var seen_solid := false
	while t <= b:
		pq.position = Vector3(t, y, fixed) if along_x else Vector3(fixed, y, t)
		var hit := not space.intersect_point(pq, 1).is_empty()
		if hit and not prev_solid and seen_solid:
			var gap := t - empty_start
			if gap > 0.2 and gap < 1.4:
				cnt += 1
				if _dbg < 6:
					_dbg += 1
					print("  dar: %s=%.2f y=%.1f aralik=%.2f t=%.2f" % ["z" if along_x else "x", fixed, y, gap, t])
		if not hit and prev_solid:
			empty_start = t
		if hit:
			seen_solid = true
		prev_solid = hit
		t += 0.1
	return cnt


func _walk(from: Vector3, to: Vector3) -> bool:
	var cb := CharacterBody3D.new()
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	cs.shape = cap
	cs.position.y = 0.9
	cb.add_child(cs)
	add_child(cb)
	cb.global_position = from + Vector3(0, 0.08, 0)
	cb.floor_snap_length = 0.5
	cb.floor_max_angle = deg_to_rad(50)
	var dt := 1.0 / float(Engine.physics_ticks_per_second)
	var ok := false
	for i in 2400:
		await get_tree().physics_frame
		var p := cb.global_position
		var dir := Vector3(to.x - p.x, 0, to.z - p.z)
		if dir.length() < 0.45 and absf(p.y - to.y) < 0.7:
			ok = true
			break
		dir = dir.normalized()
		var motion := dir * 3.0 * dt
		if cb.test_move(cb.global_transform, motion):
			var up := Vector3(0, 0.42, 0)
			if not cb.test_move(cb.global_transform, up) and not cb.test_move(cb.global_transform.translated(up), motion):
				cb.global_position += up
		cb.velocity = Vector3(dir.x * 3.0, cb.velocity.y - 9.8 * dt, dir.z * 3.0)
		if cb.is_on_floor():
			cb.velocity.y = 0.0
		cb.move_and_slide()
	if not ok:
		print("  son konum: ", cb.global_position)
	cb.queue_free()
	return ok
