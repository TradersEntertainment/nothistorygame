extends Node
## ZEMİN sondası (docs/_kanit_zemin): eski bölümlerde aynı kamerayla zemin kareleri.
##   godot --path . --resolution 1280x720 res://tests/_ist/zemin_kare.tscn -- bolum=N shots=KLASÖR liste=DOSYA [bekle=sn]
## liste satırı: "ad dx dz yon [gece]" ('#' yorum). dx, dz: oyuncunun başlangıç konumuna göre (m); yon: dünya yönü
## (derece, 0 = -z). Her satır için dört kare: <ad>_ufuk (1,7 m, ufka), <ad>_asagi (1,7 m, 25° aşağı),
## <ad>_yakin (1 m, 55° aşağı), <ad>_30m (30 m yukarıdan ve geriden, 38° aşağı). Bölüm mantığı kareler öncesi
## dondurulur (process_mode kapalı), arayüz katmanları gizlenir. Sonda: oyun koduna dokunmaz.

var bolum := "2"
var shots := ""
var liste := ""
var bekle := 8.0
var cam: Camera3D
var _tris: Array = []


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"bolum": bolum = kv[1]
			"shots": shots = kv[1]
			"liste": liste = kv[1]
			"bekle": bekle = kv[1].to_float()
	_calis.call_deferred()


func _calis() -> void:
	var root := get_tree().root
	get_parent().remove_child(self)
	root.add_child(self)
	get_tree().change_scene_to_file("res://scenes/chapter%s.tscn" % bolum)
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(bekle * 1000.0):
		await get_tree().process_frame
	var sc := get_tree().current_scene
	var pl := _bul_oyuncu(sc)
	var p0: Vector3 = pl.global_position if pl else Vector3.ZERO
	print("ZEMINKARE oyuncu=%s" % [p0])
	sc.process_mode = Node.PROCESS_MODE_DISABLED
	for n in root.find_children("*", "CanvasLayer", true, false):
		(n as CanvasLayer).visible = false
	for n in root.find_children("*", "CanvasItem", true, false):
		if n is Control and (n as Control).get_parent() == root:
			(n as Control).visible = false
	_tris_topla(sc)
	cam = Camera3D.new()
	cam.fov = 70.0
	cam.near = 0.05
	cam.far = 30000.0
	add_child(cam)
	cam.current = true
	DirAccess.make_dir_recursive_absolute(shots)
	var f := FileAccess.open(liste, FileAccess.READ)
	while f and not f.eof_reached():
		var l := f.get_line().strip_edges()
		if l == "" or l.begins_with("#"):
			continue
		var p := l.split(" ", false)
		var ad := p[0]
		var x := p0.x + p[1].to_float()
		var z := p0.z + p[2].to_float()
		var yon := deg_to_rad(p[3].to_float())
		var fwd := Vector3(sin(yon), 0, -cos(yon))
		var gy := _yer(x, z)
		var kareler := [["ufuk", Vector3(x, gy + 1.7, z), -3.0], ["asagi", Vector3(x, gy + 1.7, z), -25.0],
			["yakin", Vector3(x, gy + 1.0, z) - fwd * 0.3, -55.0]]
		var bx := Vector3(x, 0, z) - fwd * 36.0
		kareler.append(["30m", Vector3(bx.x, _yer(bx.x, bx.z) + 30.0, bx.z), -38.0])
		for k: Array in kareler:
			cam.global_position = k[1]
			cam.rotation = Vector3(deg_to_rad(k[2]), -yon, 0)
			for i in 6:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var img := get_viewport().get_texture().get_image()
			img.save_jpg("%s/%s_%s.jpg" % [shots, ad, k[0]], 0.88)
			print("ZEMINKARE %s_%s y=%.2f cizim=%d ucgen=%d" % [ad, k[0], gy,
				RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
				RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)])
	# kare süresi: aynı kamerayla 60 kare
	var t1 := Time.get_ticks_usec()
	for i in 60:
		await get_tree().process_frame
	print("ZEMINKARE kare_ms=%.2f" % ((Time.get_ticks_usec() - t1) / 60000.0))
	print("ZEMINKARE BITTI")
	get_tree().quit()


func _bul_oyuncu(sc: Node) -> Node3D:
	for n in sc.find_children("*", "", true, false):
		if n is CharacterBody3D and (n.name.to_lower().contains("player") or n.is_in_group("player")):
			return n
	for n in sc.find_children("*", "CharacterBody3D", true, false):
		return n
	return null


func _tris_topla(sc: Node) -> void:
	for n in get_tree().get_nodes_in_group("lp_terrain"):
		var mi := n as MeshInstance3D
		if mi and mi.mesh and mi.is_visible_in_tree():
			_tris.append([mi, mi.mesh.get_faces()])
	for n in sc.find_children("Arazi*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh:
			_tris.append([mi, mi.mesh.get_faces()])


func _yer(x: float, z: float) -> float:
	var best := -INF
	for e: Array in _tris:
		var mi: MeshInstance3D = e[0]
		var f: PackedVector3Array = e[1]
		var inv := mi.global_transform.affine_inverse()
		var o := inv * Vector3(x, 3000.0, z)
		var d := (inv.basis * Vector3.DOWN).normalized()
		for i in range(0, f.size(), 3):
			var a := f[i]
			var b := f[i + 1]
			var c := f[i + 2]
			if o.x < minf(a.x, minf(b.x, c.x)) or o.x > maxf(a.x, maxf(b.x, c.x)) or o.z < minf(a.z, minf(b.z, c.z)) or o.z > maxf(a.z, maxf(b.z, c.z)):
				continue
			var r = Geometry3D.ray_intersects_triangle(o, d, a, b, c)
			if r != null:
				best = maxf(best, (mi.global_transform * (r as Vector3)).y)
	if best > -INF:
		return best
	var q := PhysicsRayQueryParameters3D.create(Vector3(x, 3000.0, z), Vector3(x, -500.0, z))
	var h := get_viewport().get_world_3d().direct_space_state.intersect_ray(q)
	return (h["position"] as Vector3).y if not h.is_empty() else 0.0
