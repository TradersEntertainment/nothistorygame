extends Node3D
## Hipodrom parçası önizleme + denetim.  Çalıştırma:
##   xvfb-run -a -s "-screen 0 1280x720x24" $G --path . --resolution 1280x720 res://tests/_ist/hipodrom_onizleme.tscn -- ist=hipodrom k=0.5 lod=0 shots=KLASÖR
## ist=all hepsini sırayla kurar. shots verilmezse kare yazılmaz. audit=0 denetimi kapatır.

const IDS := ["hipodrom", "buyuk_saray", "khalke", "zeuksippos", "nea", "augustaion", "milion", "aya_irini", "sergios"]
const STEP_H := 0.42
const JUMP_H := 0.66       # JUMP 3,6 → 3,6² / (2 × 9,8)
const MANTLE := 2.3

var _ids: Array = []
var _k := 0.5
var _lod := 0
var _shots := ""
var _audit := true
var _only := ""
var _cam: Camera3D
var _host: Node3D
var _ground: StaticBody3D


func _ready() -> void:
	GameState.autotest = false
	var ist := "hipodrom"
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("ist="): ist = a.substr(4)
		elif a.begins_with("k="): _k = a.substr(2).to_float()
		elif a.begins_with("lod="): _lod = a.substr(4).to_int()
		elif a.begins_with("shots="): _shots = a.substr(6)
		elif a.begins_with("only="): _only = a.substr(5)
		elif a.begins_with("audit="): _audit = a.substr(6) != "0"
	_ids = IDS if ist == "all" else ist.split(",")
	_setup_world()
	await get_tree().physics_frame
	for id in _ids:
		await _run_one(id)
	print("ISTDONE")
	get_tree().quit()


func _setup_world() -> void:
	_ground = StaticBody3D.new()
	_ground.collision_layer = 2
	add_child(_ground)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1200, 2, 1200)
	cs.shape = bs
	cs.position = Vector3(0, -1, 0)
	_ground.add_child(cs)
	var gm := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(1200, 1200)
	gm.mesh = pm
	var gmat := StandardMaterial3D.new()
	gmat.albedo_color = Color("6f8a48")
	gmat.roughness = 1.0
	gmat.metallic_specular = 0.0
	gm.material_override = gmat
	gm.position.y = -0.002
	add_child(gm)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, 130, 0)
	sun.light_color = Color("fff0d4")
	sun.light_energy = 0.55
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 400.0
	add_child(sun)
	var env := Environment.new()
	var sky := Sky.new()
	var psm := ProceduralSkyMaterial.new()
	psm.sky_top_color = Color("5a8ed0")
	psm.sky_horizon_color = Color("cfdcec")
	psm.ground_horizon_color = Color("cfdcec")
	psm.ground_bottom_color = Color("9db16a")
	sky.sky_material = psm
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.3
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 0.8
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	_cam = Camera3D.new()
	_cam.fov = 70.0
	_cam.far = 2000.0
	add_child(_cam)
	_cam.make_current()


func _build(id: String, lod: int) -> Node3D:
	var h := Node3D.new()
	h.name = "Host_" + id
	add_child(h)
	IstHipodrom.build(id, h, _k, lod)
	return h


func _bounds(h: Node3D) -> AABB:
	var ab := AABB()
	var first := true
	for n in h.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		var a := mi.global_transform * mi.get_aabb()
		if first:
			ab = a
			first = false
		else:
			ab = ab.merge(a)
	return ab


func _tris(h: Node3D) -> int:
	var t := 0
	for n in h.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh:
			for s in mi.mesh.get_surface_count():
				var arrs := mi.mesh.surface_get_arrays(s)
				var idx = arrs[Mesh.ARRAY_INDEX]
				t += (idx.size() if idx != null and idx.size() > 0 else (arrs[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
	for n in h.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := (n as MultiMeshInstance3D).multimesh
		if mm and mm.mesh:
			var per := 0
			for s in mm.mesh.get_surface_count():
				var arrs2 := mm.mesh.surface_get_arrays(s)
				var idx2 = arrs2[Mesh.ARRAY_INDEX]
				per += (idx2.size() if idx2 != null and idx2.size() > 0 else (arrs2[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
			t += per * mm.instance_count
	return t


func _shot(name: String, from: Vector3, to: Vector3) -> void:
	if _shots == "" or (_only != "" and not _only_ok(name)):
		return
	_cam.global_position = from
	var up := Vector3.UP
	if absf((to - from).normalized().dot(Vector3.UP)) > 0.98:
		up = Vector3.FORWARD
	_cam.look_at(to, up)
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if img.get_width() != 1280:
		img.resize(1280, 720)
	DirAccess.make_dir_recursive_absolute(_shots)
	img.save_png("%s/%s.png" % [_shots, name])


func _run_one(id: String) -> void:
	var t0 := Time.get_ticks_msec()
	_host = _build(id, _lod)
	var ms := Time.get_ticks_msec() - t0
	await get_tree().physics_frame
	await get_tree().physics_frame
	var ab := _bounds(_host)
	var c := ab.get_center()
	var ext := maxf(ab.size.x, ab.size.z)
	var tr := _tris(_host)
	print("ISTBUILD id=%s k=%.2f lod=%d tris=%d ms=%d aabb=%s" % [id, _k, _lod, tr, ms, ab])
	if _audit and _lod == 0:
		await _run_audit(id, ab, tr)
	var eye := 1.7
	var dist := clampf(ext * 0.45, 18.0, 110.0)
	var tag := "%s_k%03d" % [id, int(_k * 100)]
	if _shots != "" and _lod == 0:
		var dirs := {"G": Vector3(0, 0, 1), "D": Vector3(1, 0, 0), "K": Vector3(0, 0, -1), "B": Vector3(-1, 0, 0)}
		for dn: String in dirs:
			var d3: Vector3 = dirs[dn]
			var half := Vector3(ab.size.x, 0, ab.size.z) * 0.5
			var off := absf(d3.x) * half.x + absf(d3.z) * half.z + 22.0
			await _shot("%s_yaklasma_%s" % [tag, dn], Vector3(c.x, eye, c.z) + d3 * off, Vector3(c.x, minf(ab.size.y * 0.5, 8.0), c.z))
		# kapı önü yakın plan: yapının güney yüzü, yakın
		await _shot("%s_kapi_onu" % tag, Vector3(c.x, eye, ab.end.z + 8.0), Vector3(c.x, 2.0, ab.end.z - 2.0))
		# üst yüzeyde oyuncu gözü: perches'in altı yaklaşımı
		var pr := IstHipodrom.perches(id, _k)
		if pr.size() > 0:
			var p: Vector3 = pr[0]
			await _shot("%s_ust_goz" % tag, p + Vector3(6, 1.0, 6), p + Vector3(0, -2, 0))
		await _shot("%s_kus15" % tag, Vector3(c.x + ext * 0.35, ab.end.y + 15.0, c.z + ext * 0.35), c)
		await _shot("%s_kus60" % tag, Vector3(c.x + ext * 0.6, ab.end.y + 60.0, c.z + ext * 0.6), c)
		await _shot("%s_tepe" % tag, Vector3(c.x, ab.end.y + maxf(ext * 0.9, 50.0), c.z), c)
		for dg in [Vector3(1, 0, 1), Vector3(-1, 0, 1), Vector3(-1, 0, -1), Vector3(1, 0, -1)]:
			await _shot("%s_45_%s" % [tag, "x" if dg.x > 0 else "y"] + ("a" if dg.z > 0 else "b"), c + dg.normalized() * ext * 0.5 + Vector3(0, ab.end.y + 12.0, 0), c)
	_host.queue_free()
	await get_tree().process_frame
	if _shots != "" and _lod == 0:
		for lod in [1, 2]:
			var h2 := _build(id, lod)
			await get_tree().process_frame
			print("ISTBUILD id=%s k=%.2f lod=%d tris=%d" % [id, _k, lod, _tris(h2)])
			await _shot("%s_lod%d" % [tag, lod], Vector3(c.x + ext * 0.6, ab.end.y + 25.0, c.z + ext * 0.6), c)
			h2.queue_free()
			await get_tree().process_frame


# ------------------------------------------------------------------ denetim ------------------------------------------------
func _run_audit(id: String, ab: AABB, tr: int) -> void:
	var space := get_world_3d().direct_space_state
	var cell := 0.5
	var x0 := ab.position.x
	var z0 := ab.position.z
	var nx := mini(int(ab.size.x / cell), 900)
	var nz := mini(int(ab.size.z / cell), 900)
	var delik := 0
	var dar := 0
	var dlist: Array = []
	var rlist: Array = []
	# --- katı görsel kutular (AABB) toplamı: görsel var, çarpışma yok denetimi ---
	var vis: Array = []
	for n in _host.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh is BoxMesh and absf(mi.global_transform.basis.y.y) > 0.99 and not (mi.get_parent() is StaticBody3D):
			var a := mi.global_transform * mi.get_aabb()
			var ms: Vector3 = (mi.mesh as BoxMesh).size * mi.global_transform.basis.get_scale()
			var mn := minf(ms.x, minf(ms.y, ms.z))
			if mn >= 0.4 and a.size.x * a.size.y * a.size.z > 2.0 :
				vis.append(a)
	var step := 1
	if nx * nz > 90000:
		step = 2
	for i in range(0, nx, step):
		for j in range(0, nz, step):
			var x := x0 + (i + 0.5) * cell
			var z := z0 + (j + 0.5) * cell
			var q := PhysicsRayQueryParameters3D.create(Vector3(x, ab.end.y + 5.0, z), Vector3(x, -0.5, z), 1)
			var hit := space.intersect_ray(q)
			var hc: float = (hit.position.y if hit else 0.0)
			var hv := 0.0
			for a: AABB in vis:
				if x >= a.position.x and x <= a.end.x and z >= a.position.z and z <= a.end.z:
					hv = maxf(hv, a.end.y)
			if hv - hc > 0.6:
				delik += 1
				if dlist.size() < 5: dlist.append(Vector3(x, hv, z).snapped(Vector3.ONE * 0.1))
			# dar aralık: 1 m yükseklikte ±x doğrultusunda iki katı arası 0,2–1,4 m
			var from := Vector3(x, 1.3, z)
			var pq := PhysicsPointQueryParameters3D.new()
			pq.position = from
			pq.collision_mask = 1
			if space.intersect_point(pq, 1).is_empty():
				var rr := PhysicsRayQueryParameters3D.create(from, from + Vector3(1.4, 0, 0), 1)
				var rl := PhysicsRayQueryParameters3D.create(from, from - Vector3(1.4, 0, 0), 1)
				var h1 := space.intersect_ray(rr)
				var h2 := space.intersect_ray(rl)
				if h1 and h2:
					var wd: float = from.distance_to(h1.position) + from.distance_to(h2.position)
					if wd > 0.2 and wd < 1.4:
						dar += 1
						if rlist.size() < 6: rlist.append(Vector3(x, 1.0, z).snapped(Vector3.ONE * 0.1))
	# --- havada: katı kutuların tabanı ---
	var havada := 0
	var hav_list: Array = []
	for n in _host.find_children("*", "CollisionShape3D", true, false):
		var cs := n as CollisionShape3D
		if cs.shape is BoxShape3D:
			var b := cs.shape as BoxShape3D
			var gt := cs.global_transform
			var bottom := gt.origin.y - b.size.y * 0.5 * (absf(gt.basis.y.y))
			var rq := PhysicsRayQueryParameters3D.create(Vector3(gt.origin.x, bottom + 0.02, gt.origin.z), Vector3(gt.origin.x, bottom - 6.0, gt.origin.z), 3)
			rq.exclude = [(cs.get_parent() as CollisionObject3D).get_rid()]
			var rh := space.intersect_ray(rq)
			var dist := 99.0
			if rh:
				dist = bottom - rh.position.y
			if dist > 0.05 and bottom > 0.05 and not (cs.get_parent().name == "Roof"):
				havada += 1
				if hav_list.size() < 6:
					hav_list.append("%s@%s" % [cs.get_parent().name, gt.origin.snapped(Vector3(0.1, 0.1, 0.1))])
	# --- sokaktan üst yüzeye yol ---
	var climbs := IstHipodrom.climbs(id, _k)
	var ok := 0
	for cl in climbs:
		var r := await _walk(cl[0], cl[1])
		if r:
			ok += 1
		print("ISTYOL id=%s %s -> %s tur=%s sonuc=%s" % [id, cl[0].snapped(Vector3(0.1, 0.1, 0.1)), cl[1].snapped(Vector3(0.1, 0.1, 0.1)), cl[2], r])
	print("ISTAUDIT id=%s tris=%d draws=%d delik=%d dar=%d havada=%d cati_yolu=%d/%d %s delik_yer=%s dar_yer=%s" % [id, tr, RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME), delik, dar, havada, ok, climbs.size(), str(hav_list), str(dlist), str(rlist)])


## Gerçek bir CharacterBody3D (kapsül r 0,35, boy 1,8) ile alt → üst yürüme: adım 0,42, zıplama 0,66, tutunma 2,3.
func _walk(a: Vector3, b: Vector3) -> bool:
	var body := CharacterBody3D.new()
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	cs.shape = cap
	cs.position.y = 0.9
	body.add_child(cs)
	body.collision_mask = 3
	add_child(body)
	body.global_position = a + Vector3(0, 0.05, 0)
	await get_tree().physics_frame
	var ok := false
	var pos := body.global_position
	for it in 2400:
		var to := b - pos
		var flat := Vector3(to.x, 0, to.z)
		if flat.length() < 1.2 and absf(pos.y - b.y) < 0.9:
			ok = true
			break
		var d := flat.normalized() * 0.12
		var moved := false
		if not body.test_move(body.global_transform, d):
			body.global_position += d
			moved = true
		else:
			# basamak, zıplama (0,66), tutunma (2,3)
			for hh in [STEP_H, JUMP_H, MANTLE]:
				var t0 := body.global_transform
				var up := Vector3(0, hh, 0)
				if body.test_move(t0, up):
					continue
				var t1 := t0.translated(up)
				if body.test_move(t1, d * 4.0):
					continue
				body.global_position += up + d * 4.0
				moved = true
				break
		# yerçekimi: en çok 0,6 m ineriz
		var col := KinematicCollision3D.new()
		if body.test_move(body.global_transform, Vector3(0, -3.0, 0), col):
			body.global_position += Vector3(0, -col.get_travel().length(), 0) if false else col.get_travel()
		else:
			body.global_position += Vector3(0, -3.0, 0)
		pos = body.global_position
		if pos.y < -1.0:
			break
		if not moved:
			# yön değiştir: sağa-sola kay
			for ang in [0.6, -0.6, 1.2, -1.2]:
				var d2 := d.rotated(Vector3.UP, ang)
				if not body.test_move(body.global_transform, d2):
					body.global_position += d2
					break
			pos = body.global_position
	body.queue_free()
	return ok


func _only_ok(name: String) -> bool:
	for t in _only.split(","):
		if name.contains(t):
			return true
	return false
