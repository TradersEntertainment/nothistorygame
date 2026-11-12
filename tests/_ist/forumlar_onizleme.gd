extends Node3D
## Forumlar önizleme + denetim. Kullanım (ekranlı):
##   xvfb-run -a -s "-screen 0 1280x720x24" $G --path . --resolution 1280x720 res://tests/_ist/forumlar_onizleme.tscn -- ist=mese k=0.5 lod=0 shots=KLASÖR
## ist=all hepsini sırayla; audit=1 yalnız denetim (kare yok); lodshots=0 lod 1/2 karelerini atlar.
## Çıktı: PNG kareler ve "ISTAUDIT id=… tris=… draws=… delik=… dar=… havada=… cati_yolu=…" satırı.

const F = preload("res://scripts/world/ist/forumlar.gd")

var _ground_rid: RID
var _item: Node3D
var _cam: Camera3D
var _args := {}
var _log: PackedStringArray = []


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2:
			_args[kv[0]] = kv[1]
	_setup_world()
	await get_tree().process_frame
	var ids: Array = F.IDS if String(_args.get("ist", "all")) == "all" else String(_args["ist"]).split(",")
	var k := float(_args.get("k", "0.5"))
	var lod := int(_args.get("lod", "0"))
	var dir := String(_args.get("shots", "/tmp/ist_shots"))
	DirAccess.make_dir_recursive_absolute(dir)
	for id in ids:
		await _run_item(String(id), k, lod, dir)
	var f := FileAccess.open(dir.path_join("audit_k%s.txt" % str(k)), FileAccess.WRITE)
	f.store_string("\n".join(_log) + "\n")
	f.close()
	get_tree().quit()


func _setup_world() -> void:
	var gb := StaticBody3D.new()
	var gs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1200, 2, 1200)
	gs.shape = bs
	gb.position = Vector3(0, -1.0, 0)
	gb.add_child(gs)
	add_child(gb)
	_ground_rid = gb.get_rid()
	var gm := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(1200, 1200)
	gm.mesh = pm
	gm.material_override = Props.mat(Color("6a7040"), 0.0, false, "", false)
	gm.position = Vector3(0, -0.005, 0)
	add_child(gm)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -58, 0)
	sun.light_color = Color("ffe2b0")
	sun.light_energy = 0.85
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 220.0
	add_child(sun)
	var sky := ProceduralSkyMaterial.new()
	sky.sky_top_color = Color("5f95d0")
	sky.sky_horizon_color = Color("d9d2bd")
	sky.ground_horizon_color = Color("d9d2bd")
	sky.ground_bottom_color = Color("8a8f55")
	var s := Sky.new()
	s.sky_material = sky
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = s
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.55
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	_cam = Camera3D.new()
	_cam.fov = 72.0
	_cam.far = 900.0
	add_child(_cam)
	_cam.current = true


func _make(id: String, k: float, lod: int) -> Node3D:
	if _item != null:
		_item.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	_item = Node3D.new()
	add_child(_item)
	if id == "mese":
		F.build_mese(_item, 60.0, k, lod)
	else:
		F.build(id, _item, k, lod)
	await get_tree().physics_frame
	await get_tree().physics_frame
	return _item


func _bounds(root: Node) -> AABB:
	var out := AABB()
	var first := true
	for n in root.find_children("*", "VisualInstance3D", true, false):
		if n is MeshInstance3D or n is MultiMeshInstance3D:
			var gi := n as GeometryInstance3D
			var ab := gi.global_transform * gi.get_aabb()
			if first:
				out = ab
				first = false
			else:
				out = out.merge(ab)
	return out


func _shot(path: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(path)


func _view(pos: Vector3, target: Vector3) -> void:
	_cam.look_at_from_position(pos, target, Vector3.UP if absf((target - pos).normalized().y) < 0.98 else Vector3.RIGHT)


func _run_item(id: String, k: float, lod: int, dir: String) -> void:
	await _make(id, k, lod)
	var b := _bounds(_item)
	var c := b.get_center()
	var ext := maxf(b.size.x, b.size.z)
	var top := b.end.y
	var perches: Array = _call(id, "perches", k)
	var climbs: Array = _call(id, "climbs", k)
	var tag := "%s_k%s" % [id, str(k)]
	if String(_args.get("audit", "0")) != "1":
		var dist := clampf(ext * 0.5 + 12.0, 16.0, 70.0)
		var look := Vector3(c.x, minf(top * 0.4, 7.0), c.z)
		var names := ["N", "E", "S", "W"]
		for i in 4:
			var a := deg_to_rad(i * 90.0 + 180.0)
			_view(Vector3(c.x + sin(a) * dist, 1.7, c.z + cos(a) * dist), look)
			await _shot(dir.path_join("%s_yer_%s.png" % [tag, names[i]]))
		# kapı önü / merdiven dibi yakın plan
		if climbs.size() > 0:
			var alt: Vector3 = (climbs[0] as Array)[0]
			var ust: Vector3 = (climbs[0] as Array)[1]
			var away := (Vector3(alt.x, 0, alt.z) - Vector3(c.x, 0, c.z)).normalized()
			_view(alt + away * 4.0 + Vector3(0, 1.7, 0), Vector3(ust.x, (alt.y + ust.y) * 0.5 + 1.0, ust.z))
			await _shot(dir.path_join("%s_kapi.png" % tag))
			# çatıda/üst yüzeyde oyuncu gözü
			var inward := (Vector3(c.x, 0, c.z) - Vector3(ust.x, 0, ust.z)).normalized()
			_view(ust + Vector3(0, 1.7, 0), ust + Vector3(0, 1.7, 0) + inward * 10.0 + Vector3(0, -0.5, 0))
			await _shot(dir.path_join("%s_cati.png" % tag))
		else:
			_view(Vector3(c.x + 5, 1.7, c.z + ext * 0.5 + 6), Vector3(c.x, 2.0, c.z))
			await _shot(dir.path_join("%s_kapi.png" % tag))
		# kuş bakışı 15 m ve 60 m (Nihat)
		_view(Vector3(c.x + ext * 0.25, top + 15.0, c.z + ext * 0.5 + 14.0), Vector3(c.x, top * 0.5, c.z))
		await _shot(dir.path_join("%s_kus15.png" % tag))
		_view(Vector3(c.x, 60.0, c.z + 60.0), Vector3(c.x, 0.0, c.z))
		await _shot(dir.path_join("%s_kus60.png" % tag))
		_view(Vector3(c.x, maxf(top + 30.0, 60.0), c.z + 0.01), Vector3(c.x, 0, c.z))
		await _shot(dir.path_join("%s_tepe.png" % tag))
		for i in 4:
			var a2 := deg_to_rad(45.0 + i * 90.0)
			var r := clampf(ext * 0.35 + 8.0, 18.0, 40.0)
			_view(Vector3(c.x + sin(a2) * r, top + 14.0, c.z + cos(a2) * r), Vector3(c.x, top * 0.7, c.z))
			await _shot(dir.path_join("%s_d45_%d.png" % [tag, i]))
		if String(_args.get("lodshots", "1")) == "1" and lod == 0:
			for L in [1, 2]:
				await _make(id, k, L)
				_view(Vector3(c.x + ext * 0.25, top + 15.0, c.z + ext * 0.5 + 14.0), Vector3(c.x, top * 0.5, c.z))
				await _shot(dir.path_join("%s_lod%d.png" % [tag, L]))
			await _make(id, k, lod)
	await _audit(id, k, lod, perches, climbs)


func _call(id: String, what: String, k: float) -> Array:
	var opt := {"uzunluk": 60.0} if id == "mese" else {}
	return F.perches(id, k, opt) if what == "perches" else F.climbs(id, k, opt)


# ---------------------------------------------------------------------------------------------------------
# Denetim
# ---------------------------------------------------------------------------------------------------------
func _tris(root: Node) -> int:
	var t := 0
	for n in root.find_children("*", "MeshInstance3D", true, false):
		var m := (n as MeshInstance3D).mesh
		if m != null:
			t += _mesh_tris(m)
	for n in root.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := (n as MultiMeshInstance3D).multimesh
		t += _mesh_tris(mm.mesh) * mm.instance_count
	return t


var _tri_cache := {}
var _walk_son := ""


func _mesh_tris(m: Mesh) -> int:
	if _tri_cache.has(m):
		return _tri_cache[m]
	var c := 0
	for s in m.get_surface_count():
		var arr := m.surface_get_arrays(s)
		var idx = arr[Mesh.ARRAY_INDEX]
		if idx != null and (idx as PackedInt32Array).size() > 0:
			c += (idx as PackedInt32Array).size() / 3
		else:
			c += (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	_tri_cache[m] = c
	return c


## Kenar etkisini ele: dört komşu noktada da aynı hata varsa gerçek delik.
func _delik_dogrula(space: PhysicsDirectSpaceState3D, thick: Array, x: float, z: float) -> bool:
	for off: Vector2 in [Vector2(0.15, 0), Vector2(-0.15, 0), Vector2(0, 0.15), Vector2(0, -0.15)]:
		var xx := x + off.x
		var zz := z + off.y
		var q := PhysicsRayQueryParameters3D.create(Vector3(xx, 400, zz), Vector3(xx, -5, zz))
		q.exclude = [_ground_rid]
		var hit := space.intersect_ray(q)
		var ct := 0.0 if hit.is_empty() else (hit["position"] as Vector3).y
		var vt := 0.0
		for e in thick:
			var gab: AABB = e[2]
			if xx < gab.position.x or xx > gab.end.x or zz < gab.position.z or zz > gab.end.z or gab.end.y < ct + 0.6:
				continue
			var mi2: MeshInstance3D = e[0]
			var inv := mi2.global_transform.affine_inverse()
			var o := inv * Vector3(xx, 400, zz)
			var d := inv.basis * Vector3(0, -1, 0)
			var fc: PackedVector3Array = e[1]
			for fi in range(0, fc.size(), 3):
				var hv: Variant = Geometry3D.ray_intersects_triangle(o, d, fc[fi], fc[fi + 1], fc[fi + 2])
				if hv != null:
					vt = maxf(vt, (mi2.global_transform * (hv as Vector3)).y)
		if vt - ct <= 0.6:
			return false
	return true


func _audit(id: String, k: float, lod: int, perches: Array, climbs: Array) -> void:
	var space := get_world_3d().direct_space_state
	var b := _bounds(_item)
	var tris := _tris(_item)
	var draws := _item.find_children("*", "MeshInstance3D", true, false).size() + _item.find_children("*", "MultiMeshInstance3D", true, false).size()
	var step := 0.5 if b.size.x * b.size.z < 6000.0 else 1.0
	# ---- delik: görünen kalın yüzey var, altında çarpışma yok
	var thick: Array = []
	for n in _item.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		var ab := mi.mesh.get_aabb()
		var sz := ab.size * mi.global_transform.basis.get_scale()
		if minf(minf(absf(sz.x), absf(sz.y)), absf(sz.z)) > 0.3 and not mi.has_meta("dekor"):
			thick.append([mi, mi.mesh.get_faces(), mi.global_transform * ab])
	var delik := 0
	var delik_ornek := ""
	var x := b.position.x
	while x < b.end.x:
		var z := b.position.z
		while z < b.end.z:
			var q := PhysicsRayQueryParameters3D.create(Vector3(x, 400, z), Vector3(x, -5, z))
			q.exclude = [_ground_rid]
			var hit := space.intersect_ray(q)
			var col_top := 0.0
			if not hit.is_empty():
				col_top = (hit["position"] as Vector3).y
			var vis_top := 0.0
			for e in thick:
				var gab: AABB = e[2]
				if x < gab.position.x or x > gab.end.x or z < gab.position.z or z > gab.end.z:
					continue
				if gab.end.y < col_top + 0.6:
					continue
				var mi2: MeshInstance3D = e[0]
				var inv := mi2.global_transform.affine_inverse()
				var o := inv * Vector3(x, 400, z)
				var d := inv.basis * Vector3(0, -1, 0)
				var fc: PackedVector3Array = e[1]
				for fi in range(0, fc.size(), 3):
					var hv: Variant = Geometry3D.ray_intersects_triangle(o, d, fc[fi], fc[fi + 1], fc[fi + 2])
					if hv != null:
						vis_top = maxf(vis_top, (mi2.global_transform * (hv as Vector3)).y)
			if vis_top - col_top > 0.6 and _delik_dogrula(space, thick, x, z):
				delik += 1
				if delik_ornek == "":
					delik_ornek = "(%.1f,%.1f vis=%.1f col=%.1f)" % [x, z, vis_top, col_top]
			z += step
		x += step
	# ---- dar: 0,2–1,4 m girilebilir aralık
	var dstep := 0.25 if b.size.x * b.size.z < 3000.0 else 0.5
	var nx := int(b.size.x / dstep) + 1
	var nz := int(b.size.z / dstep) + 1
	var occ := PackedByteArray()
	occ.resize(nx * nz)
	var pq := PhysicsPointQueryParameters3D.new()
	pq.collide_with_bodies = true
	for i in nx:
		for j in nz:
			var px := b.position.x + i * dstep + 0.037
			var pz := b.position.z + j * dstep + 0.037
			var o2 := 0
			for yy in [0.7, 1.5]:
				pq.position = Vector3(px, yy, pz)
				if space.intersect_point(pq, 1).size() > 0:
					o2 = 1
					break
			occ[i * nz + j] = o2
	var dar := 0
	var dar_ornek := ""
	var minrun := maxi(1, int(0.2 / dstep))
	var maxrun := int(1.4 / dstep)
	for i in nx:
		var run := 0
		var seen_occ := false
		for j in nz:
			if occ[i * nz + j] == 1:
				if seen_occ and run >= minrun and run <= maxrun:
					dar += 1
					if dar_ornek.count("(") < 3:
						dar_ornek += "(%.1f,%.1f z-yönü %.2fm)" % [b.position.x + i * dstep, b.position.z + j * dstep, run * dstep]
				seen_occ = true
				run = 0
			else:
				run += 1
	for j in nz:
		var run2 := 0
		var seen2 := false
		for i in nx:
			if occ[i * nz + j] == 1:
				if seen2 and run2 >= minrun and run2 <= maxrun:
					dar += 1
					if dar_ornek.count("(") < 3:
						dar_ornek += "(%.1f,%.1f x-yönü %.2fm)" % [b.position.x + i * dstep, b.position.z + j * dstep, run2 * dstep]
				seen2 = true
				run2 = 0
			else:
				run2 += 1
	if String(_args.get("dump", "0")) == "1" and _args.has("dx"):
		var i0 := int((float(_args["dx"]) - b.position.x) / dstep)
		var j0 := int((float(_args["dz"]) - b.position.z) / dstep)
		var txt := "dump dx=%s dz=%s (x sağa, z aşağı; hücre %.2f):\n" % [_args["dx"], _args["dz"], dstep]
		for jj in range(maxi(j0 - 10, 0), mini(j0 + 11, nz)):
			txt += "%6.2f " % (b.position.z + jj * dstep)
			for ii in range(maxi(i0 - 10, 0), mini(i0 + 11, nx)):
				txt += "#" if occ[ii * nz + jj] == 1 else "."
			txt += "\n"
		print(txt)
	# ---- havada: tabanı zeminden > 5 cm yukarıda ve komşu katıya değmeyen kütle
	var havada := 0
	var hv_ornek := ""
	var meshes: Array = []
	for n in _item.find_children("*", "MeshInstance3D", true, false):
		var mm := n as MeshInstance3D
		meshes.append([mm, mm.global_transform * mm.mesh.get_aabb()])
	for e in meshes:
		var mi3: MeshInstance3D = e[0]
		var gab2: AABB = e[1]
		if gab2.position.y < 0.05 or mi3.mesh.get_aabb().size.length() < 0.25:
			continue
		var sup := false
		var grow := gab2.grow(0.08)
		for e2 in meshes:
			if e2[0] != mi3 and grow.intersects(e2[1]):
				sup = true
				break
		if not sup:
			havada += 1
			if hv_ornek == "":
				hv_ornek = "(%s y=%.2f..%.2f)" % [str(gab2.get_center().snapped(Vector3(0.1, 0.1, 0.1))), gab2.position.y, gab2.end.y]
	# ---- çatı/üst yüzey yolu: climbs_x noktalarını gerçek CharacterBody3D ile sına
	var ok_paths := 0
	var notes := ""
	for cl in climbs:
		var a: Vector3 = cl[0]
		var u: Vector3 = cl[1]
		var kind := String(cl[2])
		var r2 := await _walk(a, u, kind)
		if r2:
			ok_paths += 1
		else:
			notes += " [yol-yok:%s %s %s→%s]" % [_walk_son, kind, str(a.snapped(Vector3(0.1, 0.1, 0.1))), str(u.snapped(Vector3(0.1, 0.1, 0.1)))]
	var line := "ISTAUDIT id=%s k=%s lod=%d tris=%d draws=%d delik=%d dar=%d havada=%d cati_yolu=%d/%d perch=%d" % [id, str(k), lod, tris, draws, delik, dar, havada, ok_paths, climbs.size(), perches.size()]
	print(line)
	_log.append(line)
	if delik > 0 or dar > 0 or havada > 0 or notes != "":
		var d := "  ayrıntı: delik%s dar%s havada%s%s" % [delik_ornek, dar_ornek, hv_ornek, notes]
		print(d)
		_log.append(d)
	# lod 1 / lod 2 üçgen sayısı
	if lod == 0 and String(_args.get("lodtris", "1")) == "1":
		var t1 := 0
		var t2 := 0
		for L in [1, 2]:
			await _make(id, k, L)
			if L == 1:
				t1 = _tris(_item)
			else:
				t2 = _tris(_item)
		var l2 := "ISTLOD id=%s k=%s tris0=%d tris1=%d (%.0f%%) tris2=%d" % [id, str(k), tris, t1, 100.0 * t1 / maxf(tris, 1), t2]
		print(l2)
		_log.append(l2)


## Yol sınaması (oyunun basamak kuralı): a'dan u'ya düz hatta 10 cm adımla yürü; her adımda zemin yüksekliği ışınla
## bulunur, yükselme ≤ STEP_H (0,42) ve kapsül (r 0,3, boy 1,8) çarpışmasız olmalı. İlk kırılma yeri _walk_son'a yazılır.
func _walk(a: Vector3, u: Vector3, _kind: String) -> bool:
	var space := get_world_3d().direct_space_state
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.8
	var sq := PhysicsShapeQueryParameters3D.new()
	sq.shape = cap
	sq.margin = 0.0
	var total := Vector2(u.x - a.x, u.z - a.z).length()
	var n := maxi(1, int(total / 0.1))
	var y := a.y
	for i in n + 1:
		var t := float(i) / n
		var x := lerpf(a.x, u.x, t)
		var z := lerpf(a.z, u.z, t)
		var best := -1000.0
		for off: Vector2 in [Vector2.ZERO, Vector2(0.3, 0), Vector2(-0.3, 0), Vector2(0, 0.3), Vector2(0, -0.3)]:
			var q := PhysicsRayQueryParameters3D.create(Vector3(x + off.x, y + 0.45, z + off.y), Vector3(x + off.x, y - 1.5, z + off.y))
			var h := space.intersect_ray(q)
			if h.is_empty():
				continue
			var hy := (h["position"] as Vector3).y
			if off == Vector2.ZERO or hy - y <= 0.43:
				best = maxf(best, hy)
		if best < -999.0:
			_walk_son = "yüzey-yok@%.1f,%.1f y=%.2f" % [x, z, y]
			return false
		if best - y > 0.43:
			_walk_son = "yükselme %.2f@%.1f,%.1f" % [best - y, x, z]
			return false
		y = best
		sq.transform = Transform3D(Basis.IDENTITY, Vector3(x, y + 0.93, z))
		if space.intersect_shape(sq, 1).size() > 0:
			_walk_son = "kapsül-çarpışma@%.1f,%.1f y=%.2f" % [x, z, y]
			return false
	return absf(y - u.y) < 0.7
