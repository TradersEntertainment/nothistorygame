extends Node
## TUR-14: Marmara/Haliç deniz suru koşusu (IstMarmaraSur.build_run; şehirde Haliç hattının 96 m'lik modüle sığmayan
## dilimleri ve bütün Marmara kıyısı) ve onu çağıran kıyı öğeleri (IstMarmaraKiyi: Mermer Kule, Ahırkapı; marmara_sur
## build_msur) için ÇARPIŞMA DÖKÜMÜ + görünen üçgen sayısı. Eski | yeni karşılaştırması: satırlar sıralı; OZET satırında
## özet karma (eşit olmalı). Şehir kurucusunun 7 m'lik pencereli kurulumu da (sehir.gd _pencere_is) taklit edilir.
##   godot --headless --path . res://tests/_ist/tur14_marmara_sonda.tscn [-- --eskisur]

func _ready() -> void:
	_kos.call_deferred()


func _dok(n: Node, etiket: String, satir: Array) -> int:
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
			var b := cs.get_parent()
			var nc := b != null and b.has_meta("no_climb")
			satir.append("CARP %s %s at=%s basis=%s nc=%s" % [etiket, ad, xf.origin.snapped(Vector3.ONE * 0.001), xf.basis.get_euler().snapped(Vector3.ONE * 0.001), nc])
		elif c is MeshInstance3D and (c as MeshInstance3D).is_visible_in_tree() and (c as MeshInstance3D).mesh != null:
			var m := (c as MeshInstance3D).mesh
			for si in m.get_surface_count():
				var a := m.surface_get_arrays(si)
				var idx = a[Mesh.ARRAY_INDEX]
				tri += (idx.size() if idx != null and idx.size() > 0 else (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
	return tri


func _kos() -> void:
	var satir: Array = []
	for k: float in [1.0, 0.5]:
		for L: float in [30.0, 61.5, 150.0, 233.0]:
			for lod in [0, 1, 2]:
				for mer in [true, false]:
					var n := Node3D.new()
					add_child(n)
					IstMarmaraSur.build_run(n, L, k, lod, {"merdiven": mer})
					var et := "k=%s L=%s lod=%d mer=%s" % [k, L, lod, mer]
					var tri := _dok(n, et, satir)
					print("MARMARAGOR %s ucgen=%d" % [et, tri])
					n.free()
	# şehrin pencereli kurulumu (7 m'lik pencereler, yakın katman)
	for L2: float in [61.5, 150.0]:
		var n2 := Node3D.new()
		add_child(n2)
		var N := maxi(1, ceili(L2 / 7.0))
		for i in N:
			var w := Node3D.new()
			n2.add_child(w)
			IstMk.pencere = Vector2(-1e9 if i == 0 else -L2 * 0.5 + L2 * i / N, 1e9 if i == N - 1 else -L2 * 0.5 + L2 * (i + 1) / N)
			IstSurlar.pencere = IstMk.pencere
			IstMarmaraSur.build_run(w, L2, 1.0, 0, {})
		IstMk.pencere = Vector2(-1e9, 1e9)
		IstSurlar.pencere = Vector2(-1e9, 1e9)
		var et2 := "pencere L=%s" % L2
		print("MARMARAGOR %s ucgen=%d" % [et2, _dok(n2, et2, satir)])
		n2.free()
	# kıyı öğeleri (marmara_kiyi.gd: build_run çağıranlar) ve tek parça kayıt
	for lod2 in [0, 1, 2]:
		for ad: String in ["mermerkule", "ahirkapi", "msur"]:
			var n3 := Node3D.new()
			add_child(n3)
			match ad:
				"mermerkule": IstMarmaraKiyi.build_mermerkule(n3, 0.5, lod2)
				"ahirkapi": IstMarmaraKiyi.build_ahirkapi(n3, 0.5, lod2)
				"msur": IstMarmaraSur.build_msur(n3, 0.5, lod2)
			var et3 := "%s lod=%d" % [ad, lod2]
			print("MARMARAGOR %s ucgen=%d" % [et3, _dok(n3, et3, satir)])
			n3.free()
	satir.sort()
	print("MARMARADON dims1=%s dims05=%s towers=%s gates=%s stair=%s perches=%s climbs=%s" % [IstMarmaraSur.dims(1.0), IstMarmaraSur.dims(0.5),
		IstMarmaraSur.tower_xs(150.0, 1.0), IstMarmaraSur.gate_xs(150.0, 1.0, {}), IstMarmaraSur.stair_pos(150.0, 1.0, {}),
		IstMarmaraSur.perches_msur(0.5), IstMarmaraSur.climbs_msur(0.5)])
	print("MARMARASONDA OZET carp=%d karma=%d" % [satir.size(), "\n".join(PackedStringArray(satir)).hash()])
	get_tree().quit()
