extends "res://tests/_ist/tasima12_kare.gd"
## 8y oyuncu bildirimi (0.99.125): havada yürüyen keçiler, havayı karıştıran aşçı, dış kapının önü.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/havada8y_kare.tscn -- bolum=8y shots=KLASÖR
## Satırlar: KECI ad=… yerel=… zemin=… fark=… · ASCI … · T10KARE …


func _bakislar() -> Array:
	var b: Array = []
	var g := func(x: float, z: float) -> float: return float(ch.call("_gy", x, z))
	var i := 0
	for n: Node in ch.get_children():
		if n is Goat:
			var p: Vector3 = (n as Node3D).position
			var y := float(g.call(p.x, p.z))
			print("KECI %d yerel=(%.1f, %.2f, %.1f) zemin=%.2f fark=%.2f" % [i, p.x, p.y, p.z, y, p.y - y])
			b.append(["keci%d" % i, ch.to_global(Vector3(p.x - 5.0, y + 1.7, p.z - 5.0)), ch.to_global(Vector3(p.x, y + 0.5, p.z)), null])
			i += 1
	var c := Vector3(9.0, 0.0, 133.0)
	var cy := float(g.call(c.x, c.z))
	b.append(["asci_on", ch.to_global(Vector3(c.x - 3.5, cy + 1.6, c.z - 2.0)), ch.to_global(Vector3(c.x - 0.6, cy + 0.7, c.z)), null])
	b.append(["asci_yan", ch.to_global(Vector3(c.x - 0.6, cy + 1.3, c.z + 2.8)), ch.to_global(Vector3(c.x - 0.6, cy + 0.6, c.z)), null])
	for k in 3:
		# oyuncu aşçının yanında (bakış oyuncunun gözünden): aşçı ona dönünce kepçe kazandan çıkıyor mu
		b.append(["asci_oyuncu%d" % k, ch.to_global(Vector3(c.x - 3.2, cy + 1.62, c.z + 3.4)), ch.to_global(Vector3(c.x - 0.5, cy + 0.7, c.z)), ch.to_global(Vector3(c.x - 3.2, cy, c.z + 3.4))])
	for k in 4:
		b.append(["asci_an%d" % k, ch.to_global(Vector3(c.x - 0.6, cy + 1.3, c.z + 2.8)), ch.to_global(Vector3(c.x - 0.6, cy + 0.6, c.z)), null])
	var d: Dictionary = (ch.get_script() as Script).get_script_constant_map()["SurHub"].arayuz().d
	var zo1 := float(d["zo1"])
	var zm0 := float(d["zm0"])
	print("KAPI zo1=%.2f zm0=%.2f esik_y=%.2f rampa_orta_y=%.2f teras_y=%.2f" % [zo1, zm0, float(g.call(0.0, zo1 + 0.5)), float(g.call(0.0, zo1 + 5.0)), float(g.call(4.5, zo1 + 4.0))])
	b.append(["kapi_esik_ileri", ch.to_global(Vector3(0.0, 1.65, zo1 + 0.5)), ch.to_global(Vector3(0.0, -3.0, zm0 + 6.0)), null])
	b.append(["kapi_rampa_geri", ch.to_global(Vector3(0.0, float(g.call(0.0, zo1 + 5.0)) + 1.65, zo1 + 5.0)), ch.to_global(Vector3(0.0, 1.2, zo1 - 4.0)), null])
	b.append(["kapi_teras_geri", ch.to_global(Vector3(4.5, float(g.call(4.5, zo1 + 4.0)) + 1.65, zo1 + 4.0)), ch.to_global(Vector3(0.0, 1.2, zo1 - 4.0)), null])
	var space := get_viewport().find_world_3d().direct_space_state
	for x: float in [0.0, 2.5, 3.5, 5.0]:
		var z := zo1 - 1.0
		var satir := "SONDA x=%.1f" % x
		while z <= zm0 + 0.6:
			var q := PhysicsRayQueryParameters3D.create(ch.to_global(Vector3(x, 8.0, z)), ch.to_global(Vector3(x, -12.0, z)))
			var r := space.intersect_ray(q)
			var hy := NAN
			var ad := "-"
			if not r.is_empty():
				hy = ch.to_local(r["position"]).y
				ad = String((r["collider"] as Node).name).left(14)
			satir += " | z%.0f c=%.2f(%s) g=%.2f" % [z, hy, ad, float(g.call(x, z))]
			z += 1.0
		print(satir)
	for m: Node in ch.find_children("*Rampa*", "", true, false):
		var line := "RAMPA %s tip=%s" % [String(ch.get_path_to(m)).right(120), m.get_class()]
		if m is MeshInstance3D:
			var mi := m as MeshInstance3D
			var bb := mi.global_transform * mi.mesh.get_aabb() if mi.mesh != null else AABB()
			line += " gorunur=%s vr=%.0f..%.0f katman=%d aabb=%s yuzey=%d golge=%d malz=%s" % [mi.is_visible_in_tree(), mi.visibility_range_begin, mi.visibility_range_end, mi.layers, bb, mi.mesh.get_surface_count() if mi.mesh else -1, mi.cast_shadow, mi.get_active_material(0)]
		print(line)
	for k: Node in ch.find_children("Ahsap_KapiKopru", "", true, false):
		for cc: Node in k.get_children():
			var cl := "KOPRU_COCUK %s tip=%s" % [cc.name, cc.get_class()]
			if cc is MeshInstance3D:
				cl += " gorunur=%s mesh=%s" % [(cc as MeshInstance3D).is_visible_in_tree(), (cc as MeshInstance3D).mesh]
			elif cc is Node3D:
				cl += " gorunur=%s" % (cc as Node3D).is_visible_in_tree()
			print(cl)
	return b
