extends RefCounted
## TAŞIMA-2 teşhis: ekrandaki bir pikselin ardında hangi görünür ağ (MeshInstance3D / MultiMeshInstance3D) var?
## Kameradan pikselden geçen ışını her görünür geometrinin dünya AABB'siyle keser, yakından uzağa yazar (tür, yol, AABB
## boyu ve merkezi, kurucu betik). AABB kesişimi kaba bir süzgeçtir: aday listesi verir, hangisi olduğunu gizleyerek kare
## doğrular (bkz. gizle()).
##   KIM px=… n=… | KIM i=<sıra> d=<uzaklık> yol=<düğüm yolu> tur=… boy=… merkez=… betik=…


static func sor(root: Node, kam: Camera3D, px: Vector2, en_cok := 25) -> Array:
	var o := kam.project_ray_origin(px)
	var yon := kam.project_ray_normal(px)
	var bulunan: Array = []
	for n in root.find_children("*", "GeometryInstance3D", true, false):
		var g := n as GeometryInstance3D
		if g == null or not g.is_visible_in_tree():
			continue
		var ab: AABB = g.global_transform * g.get_aabb()
		if ab.size.length() > 400.0:
			continue
		var hit = ab.intersects_ray(o, yon)
		if hit == null:
			continue
		bulunan.append([o.distance_to(hit), g, ab])
	bulunan.sort_custom(func(a, b): return a[0] < b[0])
	print("KIM px=%s n=%d" % [px, bulunan.size()])
	var out: Array = []
	for i in mini(en_cok, bulunan.size()):
		var e: Array = bulunan[i]
		var g: GeometryInstance3D = e[1]
		var ab: AABB = e[2]
		var sc: Script = null
		var q: Node = g
		while q != null and sc == null:
			sc = q.get_script()
			q = q.get_parent()
		print("KIM i=%d d=%.1f yol=%s tur=%s boy=%s merkez=%s betik=%s" % [i, e[0], root.get_path_to(g), g.get_class(),
			ab.size.snapped(Vector3.ONE * 0.1), ab.get_center().snapped(Vector3.ONE * 0.1), sc.resource_path if sc else "-"])
		out.append(g)
	return out
