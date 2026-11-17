extends Node
## TAŞIMA 11: şehirdeki Haliç dilimi (IstHalicSur.build) çarpışma dökümü + dönüş değerleri (dims, tower_xs, perches,
## climbs) + görünen üçgen sayısı. Eski | yeni karşılaştırması için: satırlar sıralı; OZET satırında özet karma.
##   godot --headless --path . res://tests/_ist/tasima11_halic_sonda.tscn

func _ready() -> void:
	_kos.call_deferred()


func _kos() -> void:
	var satir: Array = []
	for lod in [0, 1, 2]:
		var n := Node3D.new()
		add_child(n)
		IstHalicSur.build(n, 1.0, lod)
		var tri := 0
		for c in n.find_children("*", "", true, false):
			if c is CollisionShape3D:
				var cs := c as CollisionShape3D
				var sh := cs.shape
				var ad := ""
				if sh is BoxShape3D:
					ad = "box %s" % (sh as BoxShape3D).size.snapped(Vector3.ONE * 0.001)
				elif sh is ConvexPolygonShape3D:
					ad = "convex %d" % (sh as ConvexPolygonShape3D).points.size()
				else:
					ad = sh.get_class()
				var xf := cs.global_transform
				satir.append("CARP lod=%d %s at=%s basis=%s" % [lod, ad, xf.origin.snapped(Vector3.ONE * 0.001), xf.basis.get_euler().snapped(Vector3.ONE * 0.001)])
			elif c is MeshInstance3D and (c as MeshInstance3D).is_visible_in_tree() and (c as MeshInstance3D).mesh != null:
				var m := (c as MeshInstance3D).mesh
				for si in m.get_surface_count():
					var a := m.surface_get_arrays(si)
					var idx = a[Mesh.ARRAY_INDEX]
					tri += (idx.size() if idx != null and idx.size() > 0 else (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
		print("HALICGOR lod=%d ucgen=%d" % [lod, tri])
		n.free()
	satir.sort()
	for s in satir:
		print(s)
	print("HALICDON dims=%s towers=%s perches=%s climbs=%s" % [IstHalicSur.dims(1.0), IstHalicSur.tower_xs(96.0), IstHalicSur.perches(1.0), IstHalicSur.climbs(1.0)])
	print("HALICSONDA OZET carp=%d karma=%d" % [satir.size(), "\n".join(PackedStringArray(satir)).hash()])
	get_tree().quit()
