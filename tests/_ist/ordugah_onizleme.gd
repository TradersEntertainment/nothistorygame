extends Node3D
## Ordugâh önizleme ve denetim. Kullanım:
##   godot --path . res://tests/_ist/ordugah_onizleme.tscn -- ist=<id|virgüllü|all> k=0.5 lod=0 shots=KLASÖR [set=az|hepsi] [audit=1]
## Kareler PNG (1280x720) ve "ISTAUDIT id=… tris=… draws=… delik=… gorunmez=… dar=… havada=… cati_yolu=…" satırları.
## v2 kipi (gerçek yerinde): -- v2=1 shots=KLASÖR liste=DOSYA   (liste: satır "ad e n yükseklik yon eğim"; gece=1)

const IDS := ["otag", "sahi_top", "batarya", "mancinik", "kule", "mescit", "pazar", "mutfak", "ahir", "siper", "diplokionion",
	"kizak", "fici_kopru", "kanat_yeniceri", "kanat_anadolu", "kanat_basibozuk"]

var ids: Array = []
var k := 0.5
var lod := 0
var shots := ""
var do_audit := true
var set_ := "hepsi"
var v2 := false
var liste := ""
var gece := false
var cam: Camera3D
var holder: Node3D
var ground: StaticBody3D
var sun: DirectionalLight3D
var env: Environment
var _perches: Array = []
var _climbs: Array = []
var _batch_n := 0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"ist": ids = Array(IDS) if kv[1] == "all" else Array(kv[1].split(","))
			"k": k = float(kv[1])
			"lod": lod = int(kv[1])
			"shots": shots = kv[1]
			"set": set_ = kv[1]
			"audit": do_audit = kv[1] == "1"
			"v2": v2 = kv[1] == "1"
			"liste": liste = kv[1]
			"gece": gece = kv[1] == "1"
	if ids.is_empty():
		ids = ["otag"]
	if v2:
		call_deferred("_run_v2")
		return
	_setup_world()
	call_deferred("_run")


func _setup_world() -> void:
	env = Environment.new()
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
	env.ambient_light_energy = 0.4
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -35, 0)
	sun.light_color = Color("ffe2b8")
	sun.light_energy = 0.9
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 220.0
	add_child(sun)
	ground = StaticBody3D.new()
	add_child(ground)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(900, 1, 900)
	cs.shape = bs
	cs.position = Vector3(0, -0.5, 0)
	ground.add_child(cs)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = bs.size
	mi.mesh = bm
	mi.material_override = Props.mat(Color("5e6038"), 0.0, false, "", false)
	mi.position = cs.position
	ground.add_child(mi)
	cam = Camera3D.new()
	cam.fov = 70
	cam.far = 1500
	add_child(cam)
	cam.current = true
	holder = Node3D.new()
	add_child(holder)


func _su_ekle(id: String) -> void:
	# deniz: diplokionion (−z) ve fıçı köprüsü (her yer) için su düzlemi; zemin kutusu aşağı iner
	var m := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(900, 900 if id == "fici_kopru" else 450)
	m.mesh = pm
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color("3f6f86")
	sm.roughness = 0.35
	m.material_override = sm
	m.position = Vector3(0, 0.0, 0 if id == "fici_kopru" else -225)
	holder.add_child(m)
	if id == "fici_kopru":
		# kıyılar: x < −90 ve x > 90 kara (zemin yüzeyi), ortada su; zemin kutusunu küçült: iki kıyı bloğu
		for sd in [-1, 1]:
			var b := Props.solid(holder, Vector3(300, 3, 300), Vector3(sd * (80.0 + 150.0 + 5.0), -1.5 + 0.9, 0), Color("8a8450"))
			b.position.y = 0.9 - 1.5


func _build(id: String, l: int, host: Node3D) -> Dictionary:
	_perches = []
	_climbs = []
	var kk := k
	match id:
		"otag": IstOrdugah.build_otag(host, kk, l); _perches = IstOrdugah.perches_otag(kk); _climbs = IstOrdugah.climbs_otag(kk)
		"sahi_top": IstOrdugah.build_sahi_top(host, kk, l); _perches = IstOrdugah.perches_sahi_top(kk); _climbs = IstOrdugah.climbs_sahi_top(kk)
		"batarya": IstOrdugah.build_batarya(host, kk, l, 3); _perches = IstOrdugah.perches_batarya(kk, 3); _climbs = IstOrdugah.climbs_batarya(kk, 3)
		"mancinik": IstOrdugah.build_mancinik(host, kk, l); _perches = IstOrdugah.perches_mancinik(kk); _climbs = IstOrdugah.climbs_mancinik(kk)
		"kule": IstOrdugah.build_kule(host, kk, l); _perches = IstOrdugah.perches_kule(kk); _climbs = IstOrdugah.climbs_kule(kk)
		"mescit": IstOrdugah.build_mescit(host, kk, l); _perches = IstOrdugah.perches_mescit(kk)
		"pazar": IstOrdugah.build_pazar(host, kk, l); _perches = IstOrdugah.perches_pazar(kk)
		"mutfak": IstOrdugah.build_mutfak(host, kk, l); _perches = IstOrdugah.perches_mutfak(kk)
		"ahir": IstOrdugah.build_ahir(host, kk, l); _perches = IstOrdugah.perches_ahir(kk)
		"siper":
			IstOrdugah.build_siper(host, kk, l, PackedVector2Array([Vector2(-50, 0), Vector2(0, 0), Vector2(50, 10)]))
		"diplokionion": IstOrdugah.build_diplokionion(host, kk, l); _perches = IstOrdugah.perches_diplokionion(kk); _climbs = IstOrdugah.climbs_diplokionion(kk)
		"kizak": IstOrdugah.build_kizak(host, kk, l, PackedVector2Array([Vector2(-60, 5), Vector2(0, 0), Vector2(60, -8)]))
		"fici_kopru": IstOrdugah.build_fici_kopru(host, kk, l); _perches = IstOrdugah.perches_fici_kopru(kk)
		_:
			if id.begins_with("kanat_"):
				var tur := id.substr(6)
				IstOrdugah.build_kanat(host, PackedVector2Array([Vector2(-55, -70), Vector2(55, -70), Vector2(55, 70), Vector2(-55, 70)]), tur, kk, l, 5)
	return {}


func _run() -> void:
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	for id: String in ids:
		await _isle(id)
	print("ISTONIZLEME BITTI")
	get_tree().quit()


func _isle(id: String) -> void:
	# temizle
	for c in holder.get_children():
		c.queue_free()
	await get_tree().process_frame
	if id in ["diplokionion", "fici_kopru"]:
		_su_ekle(id)
	var host := Node3D.new()
	host.name = id
	holder.add_child(host)
	_build(id, lod, host)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	var ab := _aabb(host)
	var c := ab.get_center()
	var size := ab.size
	var R := maxf(maxf(size.x, size.z) * 0.62 + 10.0, 18.0)
	var htar := clampf(size.y * 0.4, 1.0, 8.0)
	var look := Vector3(c.x, htar, c.z)
	print("ISTBOY id=%s lod=%d aabb=(%.1f,%.1f,%.1f) merkez=(%.1f,%.1f,%.1f)" % [id, lod, size.x, size.y, size.z, c.x, c.y, c.z])
	if shots != "":
		var dirs := {"K": Vector3(0, 0, -1), "D": Vector3(1, 0, 0), "G": Vector3(0, 0, 1), "B": Vector3(-1, 0, 0)}
		var yak := dirs.keys() if set_ != "az" else ["G", "D"]
		for dn in yak:
			await _shot(id + "_yakin" + dn, Vector3(c.x, 1.7, c.z) + (dirs[dn] as Vector3) * R, look)
		await _shot(id + "_kapi", Vector3(c.x, 1.7, c.z + size.z * 0.5 + 6.0), Vector3(c.x, 1.6, c.z + size.z * 0.5 - 2.0))
		if not _perches.is_empty():
			var pp: Vector3 = _perches[0]
			await _shot(id + "_ust_goz", pp + Vector3(0, 1.7, 0), pp + Vector3(6, 1.2, 10))
		await _shot(id + "_kus15", Vector3(c.x - R * 0.35, 15.0, c.z + R * 0.55), Vector3(c.x, 1.0, c.z))
		await _shot(id + "_kus60", Vector3(c.x - R * 0.2, 60.0, c.z + R * 0.45), Vector3(c.x, 1.0, c.z))
		await _shot(id + "_tepe", Vector3(c.x, maxf(size.x, size.z) * 1.1 + 30.0, c.z + 0.01), Vector3(c.x, 0.0, c.z))
	if do_audit:
		await _audit(id, host, ab)
	if shots != "":
		for l in [1, 2]:
			for c2 in holder.get_children():
				if c2.name == id:
					c2.queue_free()
			await get_tree().process_frame
			var h2 := Node3D.new()
			h2.name = id
			holder.add_child(h2)
			_build(id, l, h2)
			await get_tree().process_frame
			await _shot("%s_lod%d" % [id, l], Vector3(c.x - R * 0.6, 24.0, c.z + R * 0.8), Vector3(c.x, 1.0, c.z))
			print("ISTLODTRIS id=%s lod=%d tris=%d" % [id, l, _tris(h2)])


func _shot(nm: String, pos: Vector3, target: Vector3) -> void:
	cam.global_position = pos
	var up := Vector3.UP
	if absf((target - pos).normalized().dot(Vector3.UP)) > 0.98:
		up = Vector3(0, 0, -1)
	cam.look_at(target, up)
	for i in 4:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	if img != null and shots != "":
		img.save_png("%s/%s.png" % [shots, nm])


func _aabb(n: Node3D) -> AABB:
	var ab := AABB()
	var first := true
	for m in n.find_children("*", "VisualInstance3D", true, false):
		var vi := m as VisualInstance3D
		if vi is Light3D or not vi.visible:
			continue
		var a := vi.global_transform * vi.get_aabb()
		if first:
			ab = a
			first = false
		else:
			ab = ab.merge(a)
	return ab


func _tris(n: Node) -> int:
	var t := 0
	for m in n.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh != null:
			t += IstOrdugahKit.mesh_tris(mi.mesh)
	for m in n.find_children("*", "MultiMeshInstance3D", true, false):
		var mm := (m as MultiMeshInstance3D).multimesh
		if mm != null and mm.mesh != null:
			t += IstOrdugahKit.mesh_tris(mm.mesh) * mm.instance_count
	return t


func _draws(n: Node) -> int:
	var d := 0
	for m in n.find_children("*", "GeometryInstance3D", true, false):
		if (m as GeometryInstance3D).visible:
			d += 1
	return d


# ------------------------------------------------------------------ denetim

func _raster_tri(top: PackedFloat32Array, ab: AABB, step: float, nx: int, nz: int, a: Vector3, b: Vector3, c: Vector3) -> void:
	var n := (b - a).cross(c - a)
	if absf(n.y) < 0.000001:
		return
	var minx := minf(a.x, minf(b.x, c.x))
	var maxx := maxf(a.x, maxf(b.x, c.x))
	var minz := minf(a.z, minf(b.z, c.z))
	var maxz := maxf(a.z, maxf(b.z, c.z))
	var i0 := maxi(int(floor((minx - ab.position.x) / step)), 0)
	var i1 := mini(int(ceil((maxx - ab.position.x) / step)), nx - 1)
	var j0 := maxi(int(floor((minz - ab.position.z) / step)), 0)
	var j1 := mini(int(ceil((maxz - ab.position.z) / step)), nz - 1)
	var den := (b.z - c.z) * (a.x - c.x) + (c.x - b.x) * (a.z - c.z)
	if absf(den) < 0.0000001:
		return
	for i in range(i0, i1 + 1):
		for j in range(j0, j1 + 1):
			var x := ab.position.x + i * step
			var z := ab.position.z + j * step
			var w0 := ((b.z - c.z) * (x - c.x) + (c.x - b.x) * (z - c.z)) / den
			var w1 := ((c.z - a.z) * (x - c.x) + (a.x - c.x) * (z - c.z)) / den
			var w2 := 1.0 - w0 - w1
			if w0 < -0.001 or w1 < -0.001 or w2 < -0.001:
				continue
			var y := w0 * a.y + w1 * b.y + w2 * c.y
			if y > top[j * nx + i]:
				top[j * nx + i] = y


func _audit(id: String, host: Node3D, ab: AABB) -> void:
	var space := get_world_3d().direct_space_state
	var tris := _tris(host)
	var draws := _draws(host)
	# 1) delik / görünmez katı: ızgara ışını (üstten); görsel yüzey: üçgen ağ ışını / çoklu ağ kutusu
	var step := 0.5
	var area := ab.size.x * ab.size.z
	if area > 30000.0:
		step = 1.5
	elif area > 8000.0:
		step = 1.0
	var nx := int(ab.size.x / step) + 2
	var nz := int(ab.size.z / step) + 2
	var top := PackedFloat32Array()
	top.resize(nx * nz)
	top.fill(-99.0)
	for m in host.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null or not mi.visible:
			continue
		var f := mi.mesh.get_faces()
		var xf := mi.global_transform
		for i in range(0, f.size(), 3):
			var p0 := xf * f[i]
			var p1 := xf * f[i + 1]
			var p2 := xf * f[i + 2]
			_raster_tri(top, ab, step, nx, nz, p0, p1, p2)
	for m in host.find_children("*", "MultiMeshInstance3D", true, false):
		var mmi := m as MultiMeshInstance3D
		var mm := mmi.multimesh
		if mm == null or mm.mesh == null:
			continue
		var la := mm.mesh.get_aabb()
		for i in mm.instance_count:
			var gb: AABB = (mmi.global_transform * mm.get_instance_transform(i)) * la
			var i0 := maxi(int((gb.position.x - ab.position.x) / step), 0)
			var i1 := mini(int((gb.end.x - ab.position.x) / step), nx - 1)
			var j0 := maxi(int((gb.position.z - ab.position.z) / step), 0)
			var j1 := mini(int((gb.end.z - ab.position.z) / step), nz - 1)
			for ii in range(i0, i1 + 1):
				for jj in range(j0, j1 + 1):
					if absf(ii * step + ab.position.x - gb.get_center().x) < gb.size.x * 0.3 and absf(jj * step + ab.position.z - gb.get_center().z) < gb.size.z * 0.3:
						top[jj * nx + ii] = maxf(top[jj * nx + ii], gb.end.y * 0.8)
	var delik := 0
	var gorunmez := 0
	var cells := 0
	var top_y := ab.end.y + 6.0
	for ii in nx:
		for jj in nz:
			var x := ab.position.x + ii * step
			var z := ab.position.z + jj * step
			cells += 1
			var q := PhysicsRayQueryParameters3D.create(Vector3(x, top_y, z), Vector3(x, -3.0, z))
			var r := space.intersect_ray(q)
			var cy := -99.0
			if not r.is_empty():
				cy = (r["position"] as Vector3).y
			var vy := top[jj * nx + ii]
			if vy > cy + 1.0 and vy > 0.5:
				delik += 1
				if delik % 400 == 1:
					print("ISTDEBUG delik x=%.1f z=%.1f gorsel=%.2f kati=%.2f" % [x, z, vy, cy])
			elif cy > vy + 0.6 and cy > 0.5:
				gorunmez += 1
				if gorunmez % 100 == 1:
					print("ISTDEBUG gorunmez x=%.1f z=%.1f gorsel=%.2f kati=%.2f" % [x, z, vy, cy])
	# 2) dar: iki katı arası 0,2–1,4 m (1,0 m yükseklikte küre sorgusu)
	var sph := SphereShape3D.new()
	sph.radius = 0.1
	var qp := PhysicsShapeQueryParameters3D.new()
	qp.shape = sph
	qp.collision_mask = 0xffffffff
	var ds := 0.4 if area < 8000.0 else 0.8
	var nxx := int(ab.size.x / ds) + 1
	var nzz := int(ab.size.z / ds) + 1
	var solid := PackedByteArray()
	solid.resize(nxx * nzz)
	for i in nxx:
		for j in nzz:
			qp.transform = Transform3D(Basis.IDENTITY, Vector3(ab.position.x + i * ds, 1.0, ab.position.z + j * ds))
			solid[j * nxx + i] = 1 if space.intersect_shape(qp, 1).size() > 0 else 0
	var dar := 0
	var maxn := int(1.5 / ds)
	for i in nxx:
		for j in nzz:
			if solid[j * nxx + i] == 1:
				continue
			for ax in 2:
				var left := 0
				var right := 0
				for s in range(1, maxn + 1):
					var ii := i - s if ax == 0 else i
					var jj := j if ax == 0 else j - s
					if ii < 0 or jj < 0:
						break
					if solid[jj * nxx + ii] == 1:
						left = s
						break
				for s in range(1, maxn + 1):
					var ii2 := i + s if ax == 0 else i
					var jj2 := j if ax == 0 else j + s
					if ii2 >= nxx or jj2 >= nzz:
						break
					if solid[jj2 * nxx + ii2] == 1:
						right = s
						break
				if left > 0 and right > 0:
					var gap := (left + right) * ds - 0.0
					if gap >= 0.2 and gap <= 1.4:
						dar += 1
						break
	# 3) havada: bir katı şeklin altında 0,4 m içinde başka katı yok ve tabanı zeminden > 5 cm yukarıda
	var havada := 0
	for cs in host.find_children("*", "CollisionShape3D", true, false):
		var c3 := cs as CollisionShape3D
		if c3.shape == null:
			continue
		var sa := c3.shape.get_debug_mesh().get_aabb() if c3.shape.get_debug_mesh() != null else AABB()
		var gb := c3.global_transform * sa
		if gb.position.y < 0.05:
			continue
		var bottom := Vector3(gb.get_center().x, gb.position.y + 0.02, gb.get_center().z)
		var rq := PhysicsRayQueryParameters3D.create(bottom, bottom - Vector3(0, 0.45, 0))
		rq.exclude = [(c3.get_parent() as CollisionObject3D).get_rid()] if c3.get_parent() is CollisionObject3D else []
		if space.intersect_ray(rq).is_empty():
			# gövdenin başka şekilleri aynı gövdeyse kenar alt yüzeyi olabilir; aynı gövdeyi dışlamıştık
			havada += 1
	# 4) tırmanma yolu: gerçek CharacterBody3D ile adım adım sına
	var ok := 0
	for cl in _climbs:
		if await _tirman(cl[0], cl[1]):
			ok += 1
	print("ISTAUDIT id=%s lod=%d tris=%d draws=%d delik=%d gorunmez=%d dar=%d havada=%d cati_yolu=%d/%d hucre=%d" % [
		id, lod, tris, draws, delik, gorunmez, dar, havada, ok, _climbs.size(), cells])


func _tirman(a: Vector3, u: Vector3) -> bool:
	var body := CharacterBody3D.new()
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	cs.shape = cap
	cs.position.y = 0.9
	body.add_child(cs)
	body.floor_max_angle = deg_to_rad(46.0)
	body.floor_snap_length = 0.4
	add_child(body)
	body.global_position = a + Vector3(0, 0.05, 0)
	var g := 9.8
	var vy := 0.0
	var tm := 0.0
	var success := false
	var last_prog := 1e9
	var stall := 0.0
	while tm < 40.0:
		await get_tree().physics_frame
		var dt := get_physics_process_delta_time()
		tm += dt
		var to := Vector3(u.x - body.global_position.x, 0, u.z - body.global_position.z)
		var dist := to.length()
		var dirh := to.normalized() if dist > 0.05 else Vector3.ZERO
		var mv := dirh * 3.0
		if body.is_on_floor():
			vy = 0.0
			# basamak: önü kapalıysa ≤ 0,42 m yüksel
			var mot := dirh * 0.45
			if mot.length() > 0.0 and body.test_move(body.global_transform, mot):
				var up := body.global_transform.translated(Vector3(0, 0.42, 0))
				if not body.test_move(up, mot) and not body.test_move(body.global_transform, Vector3(0, 0.42, 0)):
					body.global_position.y += 0.42
				elif stall > 0.25:
					vy = 3.6      # zıpla (0,66 m)
		else:
			vy -= g * dt
		body.velocity = Vector3(mv.x, vy, mv.z)
		body.move_and_slide()
		if dist < last_prog - 0.02:
			last_prog = dist
			stall = 0.0
		else:
			stall += dt
		if body.global_position.y >= u.y - 0.3 and dist < 1.0:
			success = true
			break
		if stall > 3.0:
			break
	print("ISTDEBUG tirman a=%s u=%s son=%s basari=%s" % [a, u, body.global_position, success])
	body.queue_free()
	return success


# ------------------------------------------------------------------ v2 (gerçek yerinde)

func _run_v2() -> void:
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	# ilk kamera satırı
	var satirlar: Array = []
	if liste != "":
		var f := FileAccess.open(liste, FileAccess.READ)
		while f != null and not f.eof_reached():
			var s := f.get_line().strip_edges()
			if s != "" and not s.begins_with("#"):
				satirlar.append(s.split(" ", false))
	var p0: Array = satirlar[0] if not satirlar.is_empty() else ["x", "-5000", "1000", "60", "0", "-20"]
	_kam_koy(p0)
	var dunya := IstDunya.build(self, gece, cam.global_position)
	IstOrdugah.attach(dunya, gece)
	var ord := dunya.get_node("IstOrdugah") as IstOrdugahYonetici
	ord.butce_us = 250000
	for sr in satirlar:
		_kam_koy(sr)
		# akışın yetişmesi için kare bekle
		for i in 90:
			await get_tree().process_frame
			if ord.kuyruk.is_empty() and i > 20:
				break
		for i in 4:
			await get_tree().process_frame
		var img := get_viewport().get_texture().get_image()
		if shots != "":
			img.save_png("%s/%s.png" % [shots, sr[0]])
		print("ISTV2 kare=%s kurulan=%d kuyruk=%d" % [sr[0], ord.kurulan, ord.kuyruk.size()])
	get_tree().quit()


func _kam_koy(s: Array) -> void:
	var w2 := IstGeo.w2(float(s[1]), float(s[2]))
	var ys: String = s[3]
	var y := 0.0
	if ys.begins_with("@"):
		y = ys.substr(1).to_float()
	else:
		y = maxf(IstGeo.h(w2.x, w2.y), 0.0) + ys.to_float()
	cam.global_position = Vector3(w2.x, y, w2.y)
	cam.rotation = Vector3(deg_to_rad(float(s[5])), -deg_to_rad(float(s[4])), 0.0)
