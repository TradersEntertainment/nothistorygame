extends Node3D
## Ayrıntı kitaplığı önizleme + denetim. Kullanım:
##   godot --path . res://tests/_ist/ayrinti_onizleme.tscn -- ist=<id|all|grid> k=0.5 lod=0 shots=KLASÖR [grup=<ad>]
## ist=<id>: tek öğe, dört yönden, tepe, kuş bakışı, lod1/lod2 kareleri + ISTAUDIT satırı.
## ist=grid: bütün öğeler ızgarada (5'erli satırlar) kare kare; ist=audit: yalnız ISTAUDIT satırları (karesiz).
const A := preload("res://scripts/world/ist/ayrinti.gd")
const L := preload("res://scripts/world/ist/ayrinti_lib.gd")

var _args := {}
var _cam: Camera3D
var _root: Node3D
var _shots := ""


func _ready() -> void:
	GameState.autotest = false
	for a: String in OS.get_cmdline_user_args():
		var p := a.split("=", true, 1)
		if p.size() == 2:
			_args[p[0]] = p[1]
	_shots = _args.get("shots", "")
	if _shots != "":
		DirAccess.make_dir_recursive_absolute(_shots)
	_world()
	await _run()
	get_tree().quit(0)


func _world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("5a8fc8")
	sm.sky_horizon_color = Color("d8c9a8")
	sm.ground_horizon_color = Color("b9ac8a")
	sky.sky_material = sm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.9
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("ffe2b0")
	sun.light_energy = 1.25
	sun.rotation_degrees = Vector3(-42, -50, 0)
	sun.shadow_enabled = true
	add_child(sun)
	var g := StaticBody3D.new()
	var gm := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(400, 0.2, 400)
	gm.mesh = bm
	gm.material_override = Props.mat(Color("8f8764"), 0.0, false, "cobble")
	g.add_child(gm)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = bm.size
	cs.shape = bs
	g.add_child(cs)
	g.position.y = -0.1
	add_child(g)
	_cam = Camera3D.new()
	_cam.fov = 62
	add_child(_cam)
	_cam.current = true
	_root = Node3D.new()
	add_child(_root)


func _clear() -> void:
	for c in _root.get_children():
		c.free()


func _snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	if _shots == "":
		return
	var img := get_viewport().get_texture().get_image()
	img.save_png(_shots.path_join(name + ".png"))


func _look(from: Vector3, at: Vector3) -> void:
	_cam.position = from
	_cam.look_at(at, Vector3.UP)


func _run() -> void:
	var k := float(_args.get("k", "0.5"))
	var lod := int(_args.get("lod", "0"))
	var ist: String = _args.get("ist", "grid")
	if ist == "grid":
		await _grid(k, lod)
	elif ist == "audit":
		for id in A.ids():
			_audit_one(id, k)
	else:
		await _single(ist, k)


func _grid(k: float, lod: int) -> void:
	var ids: Array = A.ids()
	var grup: String = _args.get("grup", "")
	if grup != "":
		ids = ids.filter(func(i): return _grup_of(i) == grup)
	var per := int(_args.get("per", "4"))
	var sp := float(_args.get("sp", "3.4"))
	var n := 0
	var i := 0
	while i < ids.size():
		_clear()
		var chunk: Array = ids.slice(i, i + per)
		for j in chunk.size():
			var host := Node3D.new()
			host.position = Vector3((j - (chunk.size() - 1) * 0.5) * sp, 0, 0)
			_root.add_child(host)
			A.build(chunk[j], host, k, lod)
		await get_tree().process_frame
		_look(Vector3(0, 2.6, 5.6 + sp * 0.8), Vector3(0, 0.9, 0))
		await _snap("grid_%02d" % n)
		print("GRID %02d: %s" % [n, ", ".join(chunk)])
		n += 1
		i += per


func _grup_of(id: String) -> String:
	for e in A.catalog():
		if e["id"] == id:
			return e["grup"]
	return ""


func _size_of(id: String) -> Vector3:
	for e in A.catalog():
		if e["id"] == id:
			return e["gercek_olcu"]
	return Vector3.ONE


func _single(id: String, k: float) -> void:
	for lod in [0, 1, 2]:
		_clear()
		A.build(id, _root, k, lod)
		await get_tree().process_frame
		await get_tree().physics_frame
		var sz := _size_of(id)
		var r := maxf(sz.x, maxf(sz.y, sz.z))
		var d := r * 1.7 + 1.6
		var mid := Vector3(0, sz.y * 0.5, 0)
		if lod == 0:
			for a in 4:
				var ang := deg_to_rad(a * 90.0 + 20.0)
				_look(Vector3(sin(ang) * d, 1.7, cos(ang) * d), mid)
				await _snap("%s_yon%d" % [id, a])
			_look(Vector3(0.01, d * 1.3 + sz.y, 0.01), Vector3.ZERO)
			await _snap(id + "_tepe")
			_look(Vector3(d * 0.7, sz.y + d * 0.8, d * 0.7), mid)
			await _snap(id + "_kus")
			_audit_one(id, k)
		else:
			_look(Vector3(sin(0.35) * d, 1.7, cos(0.35) * d), mid)
			await _snap("%s_lod%d" % [id, lod])


## ISTAUDIT: üçgen, çizim, dar aralık, havada parça, tırmanma yolu.
func _audit_one(id: String, k: float) -> void:
	var tris := [0, 0, 0]
	var draws := [0, 0, 0]
	var havada := 0
	var dar := 0
	for lod in [0, 1, 2]:
		_clear()
		var host := A.build(id, _root, k, lod)
		if host == null:
			return
		var parts: Array = []
		var boxes: Array = []
		_collect(host, parts, boxes, tris, draws, lod)
		if lod == 0:
			havada = _floating(parts)
			dar = _narrow(boxes)
	var cl: Array = A.climbs(id, k)
	var ok := 0
	for c in cl:
		if absf((c[1] as Vector3).y - (c[0] as Vector3).y) <= 2.3 or c[2] == "merdiven":
			ok += 1
	print("ISTAUDIT id=%s tris=%d/%d/%d draws=%d delik=na dar=%d havada=%d cati_yolu=%d/%d" % [id, tris[0], tris[1], tris[2], draws[0], dar, havada, ok, cl.size()])


func _collect(n: Node, parts: Array, boxes: Array, tris: Array, draws: Array, lod: int) -> void:
	if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
		var mi := n as MeshInstance3D
		tris[lod] += mi.mesh.get_faces().size() / 3
		draws[lod] += 1
		var bb := mi.global_transform * mi.get_aabb()
		parts.append(bb)
	elif n is CollisionShape3D and (n as CollisionShape3D).shape is BoxShape3D:
		var cs := n as CollisionShape3D
		boxes.append(cs.global_transform * AABB(-(cs.shape as BoxShape3D).size * 0.5, (cs.shape as BoxShape3D).size))
	for c in n.get_children():
		_collect(c, parts, boxes, tris, draws, lod)


## Zemine (y ≈ 0) bağlı olmayan parça sayısı: AABB'leri 3 cm şişirip bağlantı kümesine bak.
func _floating(parts: Array) -> int:
	var n := parts.size()
	var linked := []
	linked.resize(n)
	linked.fill(false)
	var queue := []
	for i in n:
		if (parts[i] as AABB).position.y < 0.05:
			linked[i] = true
			queue.append(i)
	while not queue.is_empty():
		var i: int = queue.pop_back()
		for j in n:
			if not linked[j] and (parts[i] as AABB).grow(0.03).intersects(parts[j]):
				linked[j] = true
				queue.append(j)
	var c := 0
	for i in n:
		if not linked[i]:
			c += 1
	return c


## İki katı kutu arasında 0,2–1,4 m girilebilir yatay aralık. Yalnız ortak yüksekliği ≥ 1,0 m olan ve arasında
## başka bir kutu bulunmayan çiftler sayılır (masa ayakları arası, bitişik tahtalar sayılmaz).
func _narrow(boxes: Array) -> int:
	var c := 0
	for i in boxes.size():
		for j in range(i + 1, boxes.size()):
			var a: AABB = boxes[i]
			var b: AABB = boxes[j]
			var y0 := maxf(a.position.y, b.position.y)
			var y1 := minf(a.end.y, b.end.y)
			if y1 - y0 < 1.0 or y0 > 1.0:
				continue
			var gx := maxf(a.position.x - b.end.x, b.position.x - a.end.x)
			var gz := maxf(a.position.z - b.end.z, b.position.z - a.end.z)
			if gx > 0.0 and gz > 0.0:
				continue
			var g := maxf(gx, gz)
			if g < 0.2 or g >= 1.4:
				continue
			# aradaki boşluk kutusu
			var lo := Vector3(minf(a.end.x, b.end.x) if gx > 0.0 else maxf(a.position.x, b.position.x), y0, minf(a.end.z, b.end.z) if gz > 0.0 else maxf(a.position.z, b.position.z))
			var hi := Vector3(maxf(a.position.x, b.position.x) if gx > 0.0 else minf(a.end.x, b.end.x), y1, maxf(a.position.z, b.position.z) if gz > 0.0 else minf(a.end.z, b.end.z))
			var gap := AABB(lo, (hi - lo).max(Vector3.ZERO))
			var blocked := false
			for k in boxes.size():
				if k != i and k != j and (boxes[k] as AABB).grow(0.01).intersects(gap.grow(0.01)):
					blocked = true
					break
			if not blocked:
				c += 1
	return c
