extends Node3D
## İstanbul bitki parçası önizleme ve denetim.
## Çalıştır: godot --path . res://tests/_ist/bitki_onizleme.tscn -- ist=<id|hepsi> k=0.5 lod=0 shots=KLASÖR
var _id := "erguvan"
var _k := 0.5
var _lod := 0
var _shots := ""
var _cam: Camera3D
var _subject: Node3D
var _r := 6.0
var _top := 4.0

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=")
		if kv.size() < 2:
			continue
		match kv[0]:
			"ist": _id = kv[1]
			"k": _k = float(kv[1])
			"lod": _lod = int(kv[1])
			"shots": _shots = kv[1]
	_setup_world()
	_build(_id, _lod)
	await get_tree().process_frame
	await get_tree().process_frame
	_audit()
	if _shots != "":
		await _take_shots()
	get_tree().quit()

func _setup_world() -> void:
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color("8a8a58")
	gm.roughness = 1.0
	var body := StaticBody3D.new()
	body.name = "zemin"
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(400, 400)
	mi.mesh = pm
	mi.material_override = gm
	body.add_child(mi)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(400, 1, 400)
	cs.shape = bs
	cs.position.y = -0.5
	body.add_child(cs)
	add_child(body)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -35, 0)
	sun.light_color = Color(1.0, 0.92, 0.78)
	sun.shadow_enabled = true
	add_child(sun)
	var env := Environment.new()
	var sky := Sky.new()
	var psm := ProceduralSkyMaterial.new()
	psm.sky_top_color = Color("5e92c8")
	psm.sky_horizon_color = Color("bcd4e4")
	psm.ground_horizon_color = Color("bcd4e4")
	sky.sky_material = psm
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.9
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	_cam = Camera3D.new()
	_cam.fov = 70
	_cam.far = 600
	add_child(_cam)
	_cam.current = true

func _build(id: String, lod: int) -> void:
	if _subject:
		_subject.queue_free()
	_subject = Node3D.new()
	_subject.name = "ozne"
	add_child(_subject)
	_r = 6.0
	_top = 4.0
	if IstBitki.AGAC.has(id):
		var sb: GDScript = IstBitki
		sb.callv("build_" + id, [_subject, _k, lod])
		_top = IstBitki.AGAC[id]["boy"]
		_r = _top * 0.7 + 3.0
		return
	var sc: GDScript = IstBitkiYama
	if IstBitkiYama.TURLER.has(id):
		var a: Vector2 = IstBitkiYama.TURLER[id][1]
		sc.callv("build_patch_" + id, [_subject, a, _k, lod, 1])
		_r = maxf(a.x, a.y) * 0.5
		_top = 3.0
		return
	sc.callv("build_" + id, [_subject, _k, lod])
	_r = 8.0
	_top = 3.0

func _tris(n: Node) -> int:
	var t := 0
	if n is MeshInstance3D and (n as MeshInstance3D).mesh:
		t += _mesh_tris((n as MeshInstance3D).mesh)
	if n is MultiMeshInstance3D:
		var mm := (n as MultiMeshInstance3D).multimesh
		if mm and mm.mesh:
			t += _mesh_tris(mm.mesh) * mm.instance_count
	for c in n.get_children():
		t += _tris(c)
	return t

func _mesh_tris(m: Mesh) -> int:
	var t := 0
	for s in m.get_surface_count():
		var arr := m.surface_get_arrays(s)
		var idx = arr[Mesh.ARRAY_INDEX]
		if idx != null and (idx as PackedInt32Array).size() > 0:
			t += (idx as PackedInt32Array).size() / 3
		else:
			t += (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return t

func _draws(n: Node) -> int:
	var d := 0
	if n is MeshInstance3D or n is MultiMeshInstance3D:
		d += 1
	for c in n.get_children():
		d += _draws(c)
	return d

func _bodies(n: Node, out: Array) -> void:
	if n is CollisionShape3D:
		out.append(n)
	for c in n.get_children():
		_bodies(c, out)

func _audit() -> void:
	var shapes: Array = []
	_bodies(_subject, shapes)
	var havada := 0
	for cs: CollisionShape3D in shapes:
		var bot := 1e9
		var sh := cs.shape
		var half := 0.0
		if sh is BoxShape3D:
			half = (sh as BoxShape3D).size.y * 0.5
		elif sh is CylinderShape3D:
			half = (sh as CylinderShape3D).height * 0.5
		bot = cs.global_position.y - half
		# yalnız yere oturması gereken (gövde, duvar) kabul: alt 5 cm üstünde asılı kütle = havada
		if bot > 0.05 and not str(cs.get_parent().name).begins_with("kopru") and half * 2.0 > 0.25:
			# eğik köprü rampaları ve üst üste kutular (tabanı başka kutuya oturur) hariç
			var rest := false
			for o: CollisionShape3D in shapes:
				if o != cs and o.shape is BoxShape3D:
					var ob := o.global_position.y + (o.shape as BoxShape3D).size.y * 0.5
					if absf(ob - bot) < 0.06:
						rest = true
			if not rest and cs.get_parent().rotation == Vector3.ZERO:
				havada += 1
	print("ISTAUDIT id=%s lod=%d tris=%d draws=%d katı=%d havada=%d" % [_id, _lod, _tris(_subject), _draws(_subject), shapes.size(), havada])

func _shot(name: String, pos: Vector3, look: Vector3) -> void:
	_cam.global_position = pos
	_cam.look_at(look, Vector3.UP if absf((look - pos).normalized().y) < 0.98 else Vector3.RIGHT)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%s_%s.png" % [_shots, _id, name])

func _take_shots() -> void:
	DirAccess.make_dir_recursive_absolute(_shots)
	var c := Vector3(0, _top * 0.4, 0)
	var d := _r + 5.0
	var dirs := {"kuzey": Vector3(0, 0, -1), "dogu": Vector3(1, 0, 0), "guney": Vector3(0, 0, 1), "bati": Vector3(-1, 0, 0)}
	for n: String in dirs:
		await _shot("yerden_" + n, dirs[n] * d + Vector3(0, 1.7, 0), c)
	await _shot("yakin", Vector3(2.2, 1.7, 3.2) * (1.0 if _r < 8 else 0.8) + Vector3(0, 0, _r * 0.15), c)
	await _shot("ust_15", Vector3(_r * 0.6, 15, _r * 0.9), Vector3.ZERO)
	await _shot("ust_60", Vector3(_r * 0.8, 60, _r * 1.4), Vector3.ZERO)
	await _shot("tepe", Vector3(0, 40 + _r, 0.01), Vector3.ZERO)
	for l in [1, 2]:
		_lod = l
		_build(_id, l)
		await get_tree().process_frame
		await _shot("lod%d" % l, Vector3(_r * 0.6, 15, _r * 0.9), Vector3.ZERO)
		_audit()
