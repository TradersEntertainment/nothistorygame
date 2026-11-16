extends RefCounted
## TAŞIMA-5 piksel sondası: o anki kamerada verilen piksellerin ışınının geçtiği GÖRÜNEN ağlar (dünya AABB'siyle kesişen
## MeshInstance3D/MultiMeshInstance3D; yakından uzağa). Bölümün =kare kipinden çağrılır: --pik5=x1,y1;x2,y2
## Satır: PIK5 an=… px=(x,y) d=… yol=… aabb=…

static func pikseller() -> Array:
	var out: Array = []
	for s: String in OS.get_cmdline_user_args():
		if s.begins_with("--pik5="):
			for q in s.trim_prefix("--pik5=").split(";"):
				var p := q.split(",")
				if p.size() == 2:
					out.append(Vector2(float(p[0]), float(p[1])))
	return out


## --golgesiz5: sahnedeki bütün yönlü ışıkların gölgesi kapanır; --gizle5=ad1,ad2: adı bunları içeren düğümler gizlenir
static func uygula(kok: Node) -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--golgesiz5"):
		for l in kok.get_tree().root.find_children("*", "DirectionalLight3D", true, false):
			(l as DirectionalLight3D).shadow_enabled = false
			print("PIK5 golgesiz %s" % l.get_path())
	for s: String in args:
		if s.begins_with("--gizle5="):
			for ad in s.trim_prefix("--gizle5=").split(","):
				for n in kok.get_tree().root.find_children("*" + ad + "*", "Node3D", true, false):
					(n as Node3D).visible = false
					print("PIK5 gizle %s" % n.get_path())


static func yaz(kok: Node, an: String, n := 8) -> void:
	var px := pikseller()
	if px.is_empty():
		return
	var cam := kok.get_viewport().get_camera_3d()
	var vs := kok.get_viewport().get_visible_rect().size
	var olcek := vs / Vector2(1280, 720)
	var hepsi: Array = []
	for g in kok.get_tree().root.find_children("*", "GeometryInstance3D", true, false):
		var gi := g as GeometryInstance3D
		if gi.is_visible_in_tree() and (gi is MeshInstance3D or gi is MultiMeshInstance3D):
			hepsi.append(gi)
	for p: Vector2 in px:
		var o := cam.project_ray_origin(p * olcek)
		var d := cam.project_ray_normal(p * olcek)
		var bul: Array = []
		for gi: GeometryInstance3D in hepsi:
			var ab := gi.global_transform * gi.get_aabb()
			if ab.intersects_ray(o, d) == null and not ab.has_point(o):
				continue
			# üçgen düzeyinde: ağın yüzleriyle ilk kesişme (MultiMesh: örnek başına)
			var mesh: Mesh = null
			var xfs: Array = []
			if gi is MeshInstance3D:
				mesh = (gi as MeshInstance3D).mesh
				xfs = [gi.global_transform]
			elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh:
				var mm := (gi as MultiMeshInstance3D).multimesh
				mesh = mm.mesh
				for k in mm.instance_count:
					xfs.append(gi.global_transform * mm.get_instance_transform(k))
			if mesh == null:
				continue
			var yuz := mesh.get_faces()
			var en := INF
			for xf: Transform3D in xfs:
				var inv := (xf as Transform3D).affine_inverse()
				var lo := inv * o
				var ld := (inv.basis * d).normalized()
				for i in range(0, yuz.size(), 3):
					var h = Geometry3D.ray_intersects_triangle(lo, ld, yuz[i], yuz[i + 1], yuz[i + 2])
					if h != null:
						en = minf(en, o.distance_to(xf * (h as Vector3)))
			if en < INF:
				bul.append([en, gi, ab])
		bul.sort_custom(func(a, b): return a[0] < b[0])
		for i in mini(n, bul.size()):
			var gi: GeometryInstance3D = bul[i][1]
			print("PIK5 an=%s px=%s d=%.2f yol=%s aabb=%s" % [an, p, bul[i][0], str(gi.get_path()).right(110), bul[i][2]])
