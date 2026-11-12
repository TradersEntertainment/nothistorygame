extends Node3D
## Marmara parçası önizleme ve denetim sahnesi.
## Çalıştırma: godot --path . res://tests/_ist/marmara_onizleme.tscn -- ist=<id|hepsi> k=0.5 lod=0 shots=KLASÖR
## Kareler: dört yönden yaklaşma, kapı önü, üst yüzeyde oyuncu gözü, 15 ve 60 m kuş bakışı, tam tepe, lod 1, lod 2.
## Denetim: ISTAUDIT satırı (üçgen, çizim, delik, dar, havada, çatı yolu).

var ist := "msur"
var k := 0.5
var lod := 0
var shots_dir := ""
var cam: Camera3D
var host: Node3D
var ground: StaticBody3D
var sun: DirectionalLight3D
var args := {}
var no_shots := false


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	ist = args.get("ist", "msur")
	k = float(args.get("k", "0.5"))
	lod = int(args.get("lod", "0"))
	shots_dir = args.get("shots", "")
	no_shots = args.get("noshots", "0") == "1"
	get_window().size = Vector2i(1280, 720)
	_env()
	await get_tree().process_frame
	var ids: Array = []
	if ist == "hepsi":
		for c in IstMarmara.catalog():
			ids.append(c["id"])
	else:
		ids = ist.split(",")
	for id in ids:
		await _run_item(String(id))
	await get_tree().process_frame
	get_tree().quit()


func _env() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var psm := ProceduralSkyMaterial.new()
	psm.sky_top_color = Color("5a8fcf")
	psm.sky_horizon_color = Color("cfe0ea")
	psm.ground_horizon_color = Color("cfe0ea")
	psm.ground_bottom_color = Color("a9b7b0")
	sky.sky_material = psm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.38
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.light_color = Color("fff0d0")
	sun.light_energy = 0.7
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-38, -35, 0)
	add_child(sun)
	cam = Camera3D.new()
	cam.fov = 70.0
	cam.far = 800.0
	add_child(cam)
	cam.current = true
	ground = StaticBody3D.new()
	var gm := Props.box(ground, Vector3(600, 0.4, 600), Vector3(0, -0.2, 0), Color("8a8466"))
	Props.set_pattern(gm, Color("8a8466"), "flagstone")
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(600, 0.4, 600)
	cs.shape = bs
	cs.position = Vector3(0, -0.2, 0)
	ground.add_child(cs)
	add_child(ground)


func _clear() -> void:
	if host:
		host.queue_free()
		host = null


func _build(id: String, lv: int) -> Node3D:
	var h := Node3D.new()
	h.name = "Host_" + id
	add_child(h)
	IstMarmara.build(id, h, k, lv)
	return h


func _aabb(n: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for c in n.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null:
			continue
		var wb := mi.global_transform * mi.mesh.get_aabb()
		if first:
			out = wb
			first = false
		else:
			out = out.merge(wb)
	for c in n.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := c as MultiMeshInstance3D
		var wb := mm.global_transform * mm.get_aabb()
		if first:
			out = wb
			first = false
		else:
			out = out.merge(wb)
	return out


func _shot(path: String, from: Vector3, to: Vector3) -> void:
	if shots_dir == "" or no_shots:
		return
	cam.global_position = from
	cam.look_at(to, Vector3.UP)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%s" % [shots_dir, path])


func _run_item(id: String) -> void:
	var entry := {}
	for c in IstMarmara.catalog():
		if c["id"] == id:
			entry = c
	if entry.is_empty():
		push_error("yok: " + id)
		return
	host = _build(id, 0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	var bb := _aabb(host)
	var ctr := bb.get_center()
	var R: float = maxf(bb.size.x, bb.size.z) * 0.5 + 3.0
	var top: float = bb.end.y
	var tag := "%s_k%02d" % [id, int(k * 100)]
	# --- denetim
	var au: Dictionary = await _audit(id, entry, bb)
	print("ISTAUDIT id=%s k=%.2f lod=0 tris=%d draws=%d delik=%d dar=%d havada=%d cati_yolu=%s boyut=%.1fx%.1fx%.1f" % [
		id, k, au["tris"], au["draws"], au["delik"], au["dar"], au["havada"], au["cati_yolu"], bb.size.x, bb.size.y, bb.size.z])
	var perches: Array = IstMarmara.perches(id, k)
	# --- kareler
	var dist := R * 1.15 + 6.0
	var dirs := {"G": Vector3(0, 0, 1), "D": Vector3(1, 0, 0), "K": Vector3(0, 0, -1), "B": Vector3(-1, 0, 0)}
	for nm in dirs:
		var d: Vector3 = dirs[nm]
		await _shot("%s_yer_%s.png" % [tag, nm], Vector3(ctr.x, 1.7, ctr.z) + d * dist, Vector3(ctr.x, minf(top * 0.45, 6.0), ctr.z))
	# kapı önü / giriş yakın plan: kataloğun "kapi_onu" noktası ya da güney yüz
	var kd: Vector3 = entry.get("kapi_onu", Vector3(ctr.x, 0, bb.end.z + 4.0))
	await _shot("%s_kapi.png" % tag, Vector3(kd.x, 1.7, kd.z + 3.5), Vector3(kd.x, 1.8, kd.z - 2.0))
	# üst yüzeyde oyuncu gözü
	if perches.size() > 0:
		var pp: Vector3 = perches[0]
		var look := Vector3(ctr.x, pp.y + 1.5, ctr.z)
		if look.distance_to(pp) < 1.0:
			look = pp + Vector3(0, 1.4, -6)
		await _shot("%s_ust.png" % tag, pp + Vector3(0, 1.7, 0), look)
	if perches.size() > 1:
		var pp2: Vector3 = perches[perches.size() - 1]
		await _shot("%s_ust2.png" % tag, pp2 + Vector3(0, 1.7, 0), Vector3(ctr.x, pp2.y + 1.0, ctr.z))
	# kuş bakışı
	await _shot("%s_kus15.png" % tag, Vector3(ctr.x + R * 0.5, top + 15.0, ctr.z + R * 0.9), ctr)
	await _shot("%s_kus60.png" % tag, Vector3(ctr.x + R * 0.4, top + 60.0, ctr.z + R * 0.6), ctr)
	await _shot("%s_tepe.png" % tag, Vector3(ctr.x, top + maxf(R * 1.6, 40.0), ctr.z + 0.01), ctr)
	# 45° dört yön (Nihat'ın çevresinde dönüşü)
	var diag := {"GD": Vector3(1, 0, 1), "GB": Vector3(-1, 0, 1), "KD": Vector3(1, 0, -1), "KB": Vector3(-1, 0, -1)}
	for nm in diag:
		var d2: Vector3 = (diag[nm] as Vector3).normalized()
		await _shot("%s_45_%s.png" % [tag, nm], ctr + d2 * (R * 0.8 + 6.0) + Vector3(0, top + 14.0, 0), ctr)
	# lod 1 ve 2 aynı açıdan
	_clear()
	for lv in [1, 2]:
		var h := _build(id, lv)
		host = h
		await get_tree().physics_frame
		var a2 := _audit_tris(h)
		print("ISTAUDIT id=%s k=%.2f lod=%d tris=%d draws=%d" % [id, k, lv, a2["tris"], a2["draws"]])
		await _shot("%s_lod%d.png" % [tag, lv], Vector3(ctr.x + R * 0.5, top + 15.0, ctr.z + R * 0.9), ctr)
		_clear()


func _audit_tris(n: Node) -> Dictionary:
	var tris := 0
	var draws := 0
	for c in n.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null:
			continue
		draws += 1
		tris += _mesh_tris(mi.mesh)
	for c in n.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := c as MultiMeshInstance3D
		if mm.multimesh == null or mm.multimesh.mesh == null:
			continue
		draws += 1
		tris += _mesh_tris(mm.multimesh.mesh) * mm.multimesh.instance_count
	return {"tris": tris, "draws": draws}


func _mesh_tris(m: Mesh) -> int:
	var t := 0
	for s in m.get_surface_count():
		var arr := m.surface_get_arrays(s)
		if arr.size() > Mesh.ARRAY_INDEX and arr[Mesh.ARRAY_INDEX] != null and (arr[Mesh.ARRAY_INDEX] as PackedInt32Array).size() > 0:
			t += (arr[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
		elif arr[Mesh.ARRAY_VERTEX] != null:
			t += (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return t


# ---------------------------------------------------------------------------------------------------------------
func _audit(id: String, entry: Dictionary, bb: AABB) -> Dictionary:
	var space := get_world_3d().direct_space_state
	var out := _audit_tris(host)
	# --- delik: görünür yüzeyin altında çarpışma yok (yukarıdan 0,5 m ızgara ışını)
	var vis: Array = []     # [AABB]
	for c in host.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null:
			continue
		var m := mi.material_override as StandardMaterial3D
		if m != null and m.albedo_color.a < 0.99:
			continue
		var wb := mi.global_transform * mi.mesh.get_aabb()
		if wb.size.y < 0.35 or wb.size.x < 0.3 and wb.size.z < 0.3:
			continue
		# gövdesi bir StaticBody3D'nin çocuğu mu (kendi çarpışması var)?
		var par := mi.get_parent()
		if par is StaticBody3D:
			continue
		# Props.make_solid: aynı ebeveynin altında, ağı kaplayan dışbükey çarpışma kardeşi var mı?
		var sib := false
		for sc in par.get_children():
			if sc is StaticBody3D and sc.get_child_count() > 0 and sc.get_child(0) is CollisionShape3D:
				var sh := (sc.get_child(0) as CollisionShape3D).shape
				if sh is ConvexPolygonShape3D:
					var pts := (sh as ConvexPolygonShape3D).points
					if pts.size() > 0:
						var ab := AABB(pts[0], Vector3.ZERO)
						for pt in pts:
							ab = ab.expand(pt)
						ab = (sc as Node3D).global_transform * ab
						if ab.grow(0.2).intersects(wb):
							sib = true
		if sib:
			continue
		vis.append(wb)
	var delik := 0
	var x0 := bb.position.x
	var z0 := bb.position.z
	var dx := 0.5
	var nx := int(bb.size.x / dx) + 1
	var nz := int(bb.size.z / dx) + 1
	var colltop := {}
	for ix in nx:
		for iz in nz:
			var px := x0 + ix * dx
			var pz := z0 + iz * dx
			var q := PhysicsRayQueryParameters3D.create(Vector3(px, bb.end.y + 5.0, pz), Vector3(px, -1.0, pz))
			var hit := space.intersect_ray(q)
			var ct := -1.0
			if not hit.is_empty():
				ct = (hit["position"] as Vector3).y
			colltop[Vector2i(ix, iz)] = ct
			# görünür üst yüzey yüksekliği
			var vt := 0.0
			for ab: AABB in vis:
				if px >= ab.position.x and px <= ab.end.x and pz >= ab.position.z and pz <= ab.end.z:
					vt = maxf(vt, ab.end.y)
			if vt > ct + 0.5 and vt > 0.4:
				delik += 1
	out["delik"] = delik
	# --- dar: y = 1,0 m'de 0,2 m ızgarada boş hücre koşuları (iki katı arası 0,2–1,4 m)
	var step := 0.2
	var gx := int((bb.size.x + 2.0) / step) + 1
	var gz := int((bb.size.z + 2.0) / step) + 1
	var sx0 := bb.position.x - 1.0
	var sz0 := bb.position.z - 1.0
	var sol := PackedByteArray()
	sol.resize(gx * gz)
	var pq := PhysicsPointQueryParameters3D.new()
	pq.collision_mask = 1
	pq.collide_with_bodies = true
	for ix in gx:
		for iz in gz:
			pq.position = Vector3(sx0 + ix * step, 1.0, sz0 + iz * step)
			var r := space.intersect_point(pq, 1)
			sol[ix * gz + iz] = 1 if r.size() > 0 else 0
	var dar := 0
	for ix in gx:
		var run := 0
		var started := false
		for iz in gz:
			if sol[ix * gz + iz] == 1:
				if started and run > 0 and run * step < 1.4 and run * step > 0.2:
					dar += 1
				started = true
				run = 0
			else:
				run += 1
	for iz in gz:
		var run := 0
		var started := false
		for ix in gx:
			if sol[ix * gz + iz] == 1:
				if started and run > 0 and run * step < 1.4 and run * step > 0.2:
					dar += 1
				started = true
				run = 0
			else:
				run += 1
	out["dar"] = dar
	# --- havada: tabanı zeminden > 5 cm yukarıda ve altında destek olmayan katı
	var hav := 0
	for c in host.find_children("*", "CollisionShape3D", true, false):
		var cs := c as CollisionShape3D
		if cs.shape is BoxShape3D:
			var bs := cs.shape as BoxShape3D
			var gt := cs.global_transform
			var bottom := gt.origin.y - bs.size.y * 0.5 * absf(gt.basis.y.y) - (absf(gt.basis.x.y) * bs.size.x + absf(gt.basis.z.y) * bs.size.z) * 0.5
			if bottom > 0.05:
				# altında destek ara: dört köşeden 3 cm aşağı ışın
				var supported := false
				for sxx: float in [-0.35, 0.0, 0.35]:
					for szz: float in [-0.35, 0.0, 0.35]:
						var pp := gt * Vector3(bs.size.x * sxx, -bs.size.y * 0.5, bs.size.z * szz)
						var q2 := PhysicsRayQueryParameters3D.create(pp + Vector3(0, -0.03, 0), pp + Vector3(0, -0.3, 0))
						if not space.intersect_ray(q2).is_empty():
							supported = true
				if not supported:
					# tamamen üst üste gelen (içine gömülü) katılar da sayılır: merkezden aşağı bak
					var q3 := PhysicsRayQueryParameters3D.create(gt.origin + Vector3(0, -bs.size.y * 0.5 + 0.05, 0), gt.origin + Vector3(0, -bs.size.y * 0.5 - 0.4, 0))
					if space.intersect_ray(q3).is_empty():
						hav += 1
	out["havada"] = hav
	# --- çatı yolu: climbs_x noktalarını gerçek CharacterBody3D ile sına
	var cl: Array = IstMarmara.climbs(id, k)
	var ok := 0
	for e in cl:
		if await _walk_test(e[0] as Vector3, e[1] as Vector3):
			ok += 1
	out["cati_yolu"] = "%d/%d" % [ok, cl.size()]
	return out


func _walk_test(a: Vector3, b: Vector3) -> bool:
	var body := CharacterBody3D.new()
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	cs.shape = cap
	cs.position = Vector3(0, 0.9, 0)
	body.add_child(cs)
	add_child(body)
	body.global_position = a + Vector3(0, 0.05, 0)
	body.floor_max_angle = deg_to_rad(46.0)
	var grav := 9.8
	var reached := false
	var best := 1e9
	for f in 1500:
		var to := b - body.global_position
		var flat := Vector3(to.x, 0, to.z)
		var want := flat.normalized() * 4.0 if flat.length() > 0.3 else Vector3.ZERO
		body.velocity.x = want.x
		body.velocity.z = want.z
		if not body.is_on_floor():
			body.velocity.y -= grav / 60.0
		else:
			body.velocity.y = -0.1
		var before := body.global_position
		body.move_and_slide()
		# basamak çıkma (player.step_up): önü kapanınca ≤ 0,42 m kalk ve ilerle
		if body.is_on_floor() and want.length() > 0.2 and body.get_slide_collision_count() > 0:
			var blocked := false
			for i in body.get_slide_collision_count():
				var n := body.get_slide_collision(i).get_normal()
				if n.y < 0.7 and n.x * want.x + n.z * want.z < 0.0:
					blocked = true
			if blocked:
				var col := KinematicCollision3D.new()
				var xf := body.global_transform
				var lifted := false
				for kk: float in [1.0, 0.6, 0.35]:
					var lift := 0.42 * kk
					var xf2 := xf
					xf2.origin.y += lift
					if body.test_move(xf2, want.normalized() * 0.12, col):
						continue
					xf2.origin += want.normalized() * 0.12
					if not body.test_move(xf2, Vector3.DOWN * (lift + 0.02), col):
						continue
					body.global_transform = xf2
					lifted = true
					break
				if not lifted and flat.length() > 1.0:
					body.velocity.y = 3.6      # zıplama (JUMP)
		var dd := Vector2(to.x, to.z).length()
		best = minf(best, dd + absf(to.y))
		if dd < 1.3 and absf(body.global_position.y - b.y) < 0.8:
			reached = true
			break
		await get_tree().physics_frame
	body.queue_free()
	return reached
