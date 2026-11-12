extends Node3D
## İstanbul / kiliseler önizleme ve denetim sahnesi.
## Kullanım:
##   xvfb-run -a -s "-screen 0 1280x720x24" $G --path . --resolution 1280x720 res://tests/_ist/kiliseler_onizleme.tscn -- \
##       ist=kilise_kucuk k=0.5 lod=0 shots=docs/_kanit_ist_kiliseler/pafta set=full audit=1
## ist=all tüm öğeleri sırayla yapar. set=quick: yalnız birkaç kare. audit=0: denetimsiz. seed=N tohum.

const PLAYER_R := 0.3
const PLAYER_H := 1.75
const JUMP_V := 3.6
const STEP_H := 0.42

var args := {}
var host: Node3D
var cam: Camera3D
var ground: StaticBody3D
var out_dir := ""
var audit_lines: PackedStringArray = []


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	_setup_world()
	var ids: Array = []
	var want := String(args.get("ist", "kilise_kucuk"))
	if want == "all":
		ids = IstKiliseler.IDS.duplicate()
	else:
		ids = want.split(",")
	var k := float(args.get("k", "0.5"))
	var lod := int(args.get("lod", "0"))
	out_dir = String(args.get("shots", ""))
	if out_dir != "":
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	var quick := String(args.get("set", "full")) == "quick"
	var do_audit := String(args.get("audit", "1")) != "0"
	for id: String in ids:
		await _do_item(id, k, lod, quick, do_audit)
	if out_dir != "" and audit_lines.size() > 0:
		var f := FileAccess.open(ProjectSettings.globalize_path(out_dir) + "/audit_k%s.txt" % str(args.get("k", "0.5")), FileAccess.WRITE)
		if f:
			f.store_string("\n".join(audit_lines) + "\n")
	get_tree().quit()


func _setup_world() -> void:
	var env := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("5f8fc4")
	sm.sky_horizon_color = Color("d8c9a8")
	sm.ground_horizon_color = Color("d8c9a8")
	sm.ground_bottom_color = Color("8a7a60")
	sky.sky_material = sm
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.55
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -38, 0)
	sun.light_color = Color("ffe6c0")
	sun.light_energy = 0.85
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 140.0
	add_child(sun)
	ground = Props.solid(self, Vector3(900, 1.0, 900), Vector3(0, -0.5, 0), Color("6f8346"))
	ground.name = "Zemin"
	cam = Camera3D.new()
	cam.fov = 70.0
	cam.far = 600.0
	add_child(cam)
	cam.current = true


func _build(id: String, k: float, lod: int) -> void:
	if host != null:
		host.queue_free()
		await get_tree().process_frame
	host = Node3D.new()
	host.name = "Host_" + id
	if args.has("seed"):
		host.set_meta("tohum", int(args["seed"]))
	if args.has("latin"):
		host.set_meta("latin", true)
	add_child(host)
	IstKiliseler.build(id, host, k, lod)
	await get_tree().physics_frame
	await get_tree().physics_frame


func _do_item(id: String, k: float, lod: int, quick: bool, do_audit: bool) -> void:
	await _build(id, k, lod)
	var bb := _bounds(host)
	print("BOUNDS ", id, " k=", k, " ", bb)
	if out_dir != "":
		await _shots(id, k, bb, quick)
	if do_audit:
		await _audit(id, k, bb)
	if out_dir != "" and lod == 0 and not quick:
		for l in [1, 2]:
			await _build(id, k, l)
			var c := bb.get_center()
			var R := maxf(bb.size.x, bb.size.z) * 0.5
			await _shot("%s_k%s_lod%d" % [id, str(k), l], c + Vector3(1, 0, 1).normalized() * (R + 14.0) + Vector3(0, bb.end.y * 0.6 + 8.0, 0), c + Vector3(0, bb.size.y * 0.35, 0))
		await _build(id, k, 0)


# ------------------------------------------------------------------ çekimler

func _bounds(n: Node3D) -> AABB:
	var bb := AABB()
	var first := true
	for m in n.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null:
			continue
		var ab := mi.global_transform * mi.mesh.get_aabb()
		if first:
			bb = ab
			first = false
		else:
			bb = bb.merge(ab)
	for m in n.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := m as MultiMeshInstance3D
		for i in mm.multimesh.instance_count:
			var ab2 := (mm.global_transform * mm.multimesh.get_instance_transform(i)) * mm.multimesh.mesh.get_aabb()
			bb = ab2 if first else bb.merge(ab2)
			first = false
	return bb


func _shot(name: String, pos: Vector3, target: Vector3, fov := 70.0) -> void:
	cam.fov = fov
	cam.global_position = pos
	var up := Vector3.UP
	if absf((target - pos).normalized().dot(Vector3.UP)) > 0.98:
		up = Vector3.FORWARD
	cam.look_at(target, up)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if out_dir == "":
		return
	var img := get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(out_dir) + "/" + name + ".png")


func _shots(id: String, k: float, bb: AABB, quick: bool) -> void:
	var c := bb.get_center()
	var R := maxf(bb.size.x, bb.size.z) * 0.5
	var H := bb.end.y
	var tag := "%s_k%s" % [id, str(k)]
	var eye := 1.7
	var dist := R + clampf(R * 0.9, 9.0, 24.0)
	var look := Vector3(c.x, minf(H * 0.45, 4.5), c.z)
	var dirs := {"N": Vector3(0, 0, -1), "E": Vector3(1, 0, 0), "S": Vector3(0, 0, 1), "W": Vector3(-1, 0, 0)}
	for dname: String in dirs:
		var d: Vector3 = dirs[dname]
		if quick and dname != "S" and dname != "N":
			continue
		await _shot("%s_yaklasma%s" % [tag, dname], Vector3(c.x, eye, c.z) + d * dist, look)
	# kapı önü (güney yüz, +z)
	await _shot("%s_kapi" % tag, Vector3(c.x, eye, bb.end.z + 4.5), Vector3(c.x, 1.4, bb.end.z))
	# çatıda / üst yüzeyde oyuncu gözü
	var cl: Array = IstKiliseler.climbs(id, k)
	if cl.size() > 0:
		var up_p: Vector3 = cl[0][1]
		var toward := Vector3(c.x - up_p.x, 0, c.z - up_p.z)
		toward = toward.normalized() if toward.length() > 0.5 else Vector3(0, 0, -1)
		await _shot("%s_cati" % tag, up_p + Vector3(0, eye, 0), up_p + toward * 6.0 + Vector3(0, eye + 0.2, 0))
	# kuş bakışı 15 m ve 60 m yükseklik
	await _shot("%s_kus15" % tag, c + Vector3(R * 0.6, 15.0 + H * 0.4, R * 1.3 + 4.0), c + Vector3(0, H * 0.35, 0))
	if quick:
		return
	await _shot("%s_kus60" % tag, c + Vector3(R * 0.8, 60.0, R * 1.6 + 8.0), c + Vector3(0, 0, 0))
	await _shot("%s_tepe" % tag, c + Vector3(0, maxf(30.0, R * 2.4 + 12.0), 0), c)
	var diag := {"NE": Vector3(1, 0, -1), "SE": Vector3(1, 0, 1), "SW": Vector3(-1, 0, 1), "NW": Vector3(-1, 0, -1)}
	for dname: String in diag:
		var d2: Vector3 = (diag[dname] as Vector3).normalized()
		await _shot("%s_diag%s" % [tag, dname], c + d2 * (R + 12.0) + Vector3(0, H + 8.0, 0), c + Vector3(0, H * 0.55, 0))


# -------------------------------------------------------------------- denetim

func _tri_count(n: Node) -> Array:
	var tris := 0
	var draws := 0
	for m in n.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh != null:
			tris += mi.mesh.get_faces().size() / 3
			draws += mi.mesh.get_surface_count()
	for m in n.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := m as MultiMeshInstance3D
		tris += mm.multimesh.mesh.get_faces().size() / 3 * mm.multimesh.instance_count
		draws += 1
	return [tris, draws]


func _audit(id: String, k: float, bb: AABB) -> void:
	var space := get_world_3d().direct_space_state
	var tc := _tri_count(host)
	var tris0: int = tc[0]
	var draws0: int = tc[1]
	var delik: int = await _delik(space, bb)
	if args.has("dump"):
		for bd in host.find_children("*", "StaticBody3D", true, false):
			print("  GOVDE ", (bd as StaticBody3D).get_parent().name, " ", _shape_aabb(bd as StaticBody3D))
	var dar := _dar(space, bb, id, k)
	var havada := _havada(space)
	var cl: Array = IstKiliseler.climbs(id, k)
	var ok := 0
	for c in cl:
		if _walk_test(c[0], c[1]):
			ok += 1
	# lod 1 / lod 2 üçgen sayıları
	await _build(id, k, 1)
	var t1: int = _tri_count(host)[0]
	await _build(id, k, 2)
	var t2: int = _tri_count(host)[0]
	await _build(id, k, 0)
	var line := "ISTAUDIT id=%s k=%s tris=%d draws=%d delik=%d dar=%d havada=%d cati_yolu=%d/%d tris_lod1=%d tris_lod2=%d" % [
		id, str(k), tris0, draws0, delik, dar, havada, ok, cl.size(), t1, t2]
	print(line)
	audit_lines.append(line)


## Görsel yüzey (dekor hariç) çarpışmasız mı? Görünen ağlar geçici olarak 2. katmanda üçgen ağ çarpışmasına çevrilir;
## zemine 0,5 m ızgarayla yukarıdan ışın: görsel tepe, katı tepeden > 15 cm yüksekse "delik".
func _delik(space: PhysicsDirectSpaceState3D, bb: AABB) -> int:
	var vis := Node3D.new()
	add_child(vis)
	var cnt := 0
	for m in host.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null or mi.has_meta("dekor"):
			continue
		var skip := false
		var p: Node = mi.get_parent()
		while p != null and p != host:
			if p.has_meta("flame"):
				skip = true
			p = p.get_parent()
		if skip:
			continue
		var body := StaticBody3D.new()
		body.collision_layer = 2
		body.collision_mask = 0
		var cs := CollisionShape3D.new()
		cs.shape = mi.mesh.create_trimesh_shape()
		body.add_child(cs)
		vis.add_child(body)
		body.global_transform = mi.global_transform
		cnt += 1
	await get_tree().physics_frame
	await get_tree().physics_frame
	var n := 0
	var step := 0.5 if maxf(bb.size.x, bb.size.z) < 40.0 else 1.0
	var x := bb.position.x
	while x <= bb.end.x:
		var z := bb.position.z
		while z <= bb.end.z:
			var qv := PhysicsRayQueryParameters3D.create(Vector3(x, 200.0, z), Vector3(x, -5.0, z), 2)
			var rv := space.intersect_ray(qv)
			if rv.size() > 0 and rv["position"].y > 0.2:
				var q := PhysicsRayQueryParameters3D.create(Vector3(x, 200.0, z), Vector3(x, -5.0, z), 1)
				var r := space.intersect_ray(q)
				var yc: float = r["position"].y if r.size() > 0 else -5.0
				if rv["position"].y - yc > 0.15:
					n += 1
					if n <= 6:
						print("  DELIK: ", Vector3(x, rv["position"].y, z), " katı=", yc)
			z += step
		x += step
	vis.queue_free()
	return n


## Girilebilir dar aralık: iki katı arasında 0,2–1,4 m serbest şerit (yürüme yüksekliklerinde, zemin ve çatı katlarında).
func _dar(space: PhysicsDirectSpaceState3D, bb: AABB, id: String, k: float) -> int:
	var levels: Array = [0.0]
	var cl: Array = IstKiliseler.climbs(id, k)
	for c in cl:
		var yy: float = (c[1] as Vector3).y
		var dup := false
		for l: float in levels:
			if absf(l - yy) < 0.3:
				dup = true
		if not dup:
			levels.append(yy)
	var res := 0.1 if maxf(bb.size.x, bb.size.z) < 36.0 else 0.2
	var x0 := bb.position.x - 1.0
	var z0 := bb.position.z - 1.0
	var nx := int((bb.size.x + 2.0) / res) + 1
	var nz := int((bb.size.z + 2.0) / res) + 1
	var total := 0
	var cellq := PhysicsShapeQueryParameters3D.new()
	var cellbox := BoxShape3D.new()
	cellbox.size = Vector3(res * 0.9, 0.2, res * 0.9)
	cellq.shape = cellbox
	for base_y: float in levels:
		var occ: Array = []
		occ.resize(nx * nz)
		for i in nx:
			for j in nz:
				var o := false
				for hy: float in [0.7, 1.5]:
					cellq.transform = Transform3D(Basis.IDENTITY, Vector3(x0 + i * res, base_y + hy, z0 + j * res))
					if space.intersect_shape(cellq, 1).size() > 0:
						o = true
						break
				occ[i * nz + j] = o
		# x yönünde ve z yönünde serbest şeritler
		for j in nz:
			var last := -1
			for i in nx:
				if occ[i * nz + j]:
					if last >= 0 and i - last - 1 > 0:
						var gap := (i - last - 1) * res
						if gap >= 0.199 and gap <= 1.4:
							total += 1
							if total <= 12:
								print("  DAR(x): y=", base_y, " x=", x0 + last * res, "..", x0 + i * res, " z=", z0 + j * res, " aralik=", gap)
					last = i
		for i in nx:
			var last2 := -1
			for j in nz:
				if occ[i * nz + j]:
					if last2 >= 0 and j - last2 - 1 > 0:
						var gap2 := (j - last2 - 1) * res
						if gap2 >= 0.199 and gap2 <= 1.4:
							total += 1
							if total <= 12:
								print("  DAR(z): y=", base_y, " x=", x0 + i * res, " z=", z0 + last2 * res, "..", z0 + j * res, " aralik=", gap2)
					last2 = j
	return total


func _shape_aabb(body: StaticBody3D) -> AABB:
	var out := AABB()
	var first := true
	for c in body.get_children():
		var cs := c as CollisionShape3D
		if cs == null or cs.shape == null:
			continue
		var xf := cs.global_transform
		var pts: PackedVector3Array = []
		if cs.shape is BoxShape3D:
			var h := (cs.shape as BoxShape3D).size * 0.5
			for sx in [-1.0, 1.0]:
				for sy in [-1.0, 1.0]:
					for sz in [-1.0, 1.0]:
						pts.append(Vector3(sx * h.x, sy * h.y, sz * h.z))
		elif cs.shape is ConvexPolygonShape3D:
			pts = (cs.shape as ConvexPolygonShape3D).points
		elif cs.shape is CylinderShape3D:
			var cy := cs.shape as CylinderShape3D
			for sy in [-1.0, 1.0]:
				for a in 8:
					pts.append(Vector3(cos(a * TAU / 8.0) * cy.radius, sy * cy.height * 0.5, sin(a * TAU / 8.0) * cy.radius))
		for p in pts:
			var g := xf * p
			if first:
				out = AABB(g, Vector3.ZERO)
				first = false
			else:
				out = out.expand(g)
	return out


func _bottom_pts(body: StaticBody3D, ymin: float) -> Array:
	var out: Array = []
	for c in body.get_children():
		var cs := c as CollisionShape3D
		if cs == null or cs.shape == null:
			continue
		var pts: PackedVector3Array = []
		if cs.shape is ConvexPolygonShape3D:
			pts = (cs.shape as ConvexPolygonShape3D).points
		elif cs.shape is BoxShape3D:
			var h := (cs.shape as BoxShape3D).size * 0.5
			for sx in [-1.0, 1.0]:
				for sz in [-1.0, 1.0]:
					pts.append(Vector3(sx * h.x, -h.y, sz * h.z))
		for p in pts:
			var g := cs.global_transform * p
			if g.y <= ymin + 0.03:
				out.append(g)
	return out


## Havada duran katı parça: tabanı zeminden > 5 cm yukarıda ve altında başka katı yok.
func _havada(space: PhysicsDirectSpaceState3D) -> int:
	var n := 0
	var probe := BoxShape3D.new()
	probe.size = Vector3(0.5, 0.08, 0.5)
	for b in host.find_children("*", "StaticBody3D", true, false):
		var body := b as StaticBody3D
		var ab := _shape_aabb(body)
		if ab.size == Vector3.ZERO:
			continue
		if ab.position.y <= 0.05:
			continue
		var ok := false
		var cands: Array = []
		var fx: Array = [0.5, 0.02, 0.98, 0.12, 0.88, 0.3, 0.7]
		for fa: float in fx:
			for fb: float in fx:
				cands.append(Vector3(ab.position.x + ab.size.x * fa, ab.position.y - 0.05, ab.position.z + ab.size.z * fb))
		var ctr := ab.get_center()
		for bp in _bottom_pts(body, ab.position.y):
			var q2 := Vector3(ctr.x + (bp.x - ctr.x) * 0.88, ab.position.y - 0.05, ctr.z + (bp.z - ctr.z) * 0.88)
			cands.append(q2)
		for p: Vector3 in cands:
			if true:
				var q := PhysicsShapeQueryParameters3D.new()
				q.shape = probe
				q.transform = Transform3D(Basis.IDENTITY, p)
				q.exclude = [body.get_rid()]
				if space.intersect_shape(q, 1).size() > 0:
					ok = true
					break
			if ok:
				break
		if not ok:
			n += 1
			print("  HAVADA: ", body.get_parent().name, " ", ab)
	return n


## Gerçek bir CharacterBody3D ile alt noktadan üst noktaya yürü / basamak çık / zıpla.
func _walk_test(alt: Vector3, ust: Vector3) -> bool:
	var body := CharacterBody3D.new()
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = PLAYER_R
	cap.height = PLAYER_H
	cs.shape = cap
	cs.position.y = PLAYER_H * 0.5
	body.add_child(cs)
	add_child(body)
	body.floor_max_angle = deg_to_rad(45.0)
	body.global_position = alt + Vector3(0, 0.05, 0)
	var g := float(ProjectSettings.get_setting("physics/3d/default_gravity"))
	var dt := 1.0 / 60.0
	var vy := 0.0
	var ok := false
	var stuck := 0
	for i in 2400:
		var to := Vector3(ust.x - body.global_position.x, 0, ust.z - body.global_position.z)
		if to.length() < 0.35 and absf(body.global_position.y - ust.y) < 0.6:
			ok = true
			break
		var dir := to.normalized()
		body.velocity = Vector3(dir.x * 4.0, vy, dir.z * 4.0)
		var before := body.global_position
		body.move_and_slide()
		vy = body.velocity.y
		if body.is_on_floor():
			vy = 0.0
		else:
			vy -= g * dt
		var moved := Vector2(body.global_position.x - before.x, body.global_position.z - before.z).length()
		if moved < 4.0 * dt * 0.3 and to.length() > 0.4:
			stuck += 1
			if body.is_on_floor():
				# 1) basamak çık (oyuncudaki step_up gibi), 2) olmazsa zıpla
				var stepped := false
				for lift: float in [STEP_H, 0.25, 0.12]:
					var xf := body.global_transform
					var col := KinematicCollision3D.new()
					if body.test_move(xf, Vector3.UP * lift, col):
						continue
					xf.origin.y += lift
					if body.test_move(xf, dir * 0.15, col):
						continue
					body.global_position = xf.origin + dir * 0.15
					stepped = true
					break
				if not stepped and stuck > 4:
					vy = JUMP_V
		else:
			stuck = 0
	body.queue_free()
	return ok
