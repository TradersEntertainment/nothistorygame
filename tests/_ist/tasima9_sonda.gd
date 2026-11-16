extends Node3D
## TAŞIMA-9: Blakherna seti ÖLÇÜM sondası (başsız). Eski (`eski_zorla = 1`) ve yeni (`0`) seti AYNI sahnede sırayla kurar
## (çevre dünyası kurulmaz: in_world = false), her biri için:
##   · BLAKCARP: bütün çarpışma şekilleri (dünya konumu, dönüşü, boyu, metası) sıralı → eski ile yeni satır satır aynı olmalı
##   · BLAKYOL: sur yolu ışını (x −62…62, 0,5 m adım, z 1,0 / 2,3 / 3,6): vuruş y'si → yürünür parçalar (y 12) ve kuleler
##   · BLAKRAMPA: iç taş rampa boyunca ışın (12 nokta)
##   · BLAKZEMIN: dış ve iç zemin (z −60…66, x −70…70 ızgarası) vuruş y'si (en küçük / en büyük)
##   · BLAKGOR: görünen ağ sayısı / üçgen sayısı (bütçe ön bilgisi; çizim sayısı kare sahnesinde)
## Son satır: BLAKSONDA OZET eski_carp=<n> yeni_carp=<n> fark=<n>
##   godot --headless --path . res://tests/_ist/tasima9_sonda.tscn

var _sat := {}


func _ready() -> void:
	await get_tree().process_frame
	for mod: int in [1, 0]:
		var b := Blachernae.new()
		b.in_world = false
		b.eski_zorla = mod
		b.name = "Blak_%d" % mod
		add_child(b)
		b.build_guards([10.0], false)
		for i in 3:
			await get_tree().physics_frame
		_dok(b, "eski" if mod == 1 else "yeni")
		b.free()
		for i in 2:
			await get_tree().physics_frame
	# küme farkı; saray (z < −15: cephe −16 ve ardı) ayrı sayılır (yeni sette şehirdeki saray kurulur: kendi kutuları)
	var e: Array = _sat["eski"]
	var y: Array = _sat["yeni"]
	var fark := 0
	var saray := 0
	for t: String in e:
		if not t in y:
			var z := float(t.get_slice(",", 2).get_slice(")", 0))
			if z < -15.0:
				saray += 1
				print("BLAKCARP SARAY_ESKI %s" % t)
			else:
				fark += 1
				print("BLAKCARP FARK_ESKI %s" % t)
	for t: String in y:
		if not t in e:
			var z := float(t.get_slice(",", 2).get_slice(")", 0))
			if z < -15.0:
				saray += 1
				print("BLAKCARP SARAY_YENI %s" % t)
			else:
				fark += 1
				print("BLAKCARP FARK_YENI %s" % t)
	print("BLAKSONDA OZET eski_carp=%d yeni_carp=%d fark=%d saray_farki=%d" % [e.size(), y.size(), fark, saray])
	get_tree().quit(0)


func _dok(b: Blachernae, ad: String) -> void:
	var sat: Array = []
	for c in b.find_children("*", "CollisionShape3D", true, false):
		var cs := c as CollisionShape3D
		var xf := cs.global_transform
		var sz := Vector3(-1, -1, -1)
		if cs.shape is BoxShape3D:
			sz = (cs.shape as BoxShape3D).size
		var body := cs.get_parent()
		var m := []
		for k in ["no_climb", "wall", "ground"]:
			if body.has_meta(k):
				m.append(k)
		sat.append("poz=(%.3f,%.3f,%.3f) don=(%.2f,%.2f,%.2f) boy=(%.3f,%.3f,%.3f) nc=%s" % [xf.origin.x, xf.origin.y, xf.origin.z,
			rad_to_deg(xf.basis.get_euler().x), rad_to_deg(xf.basis.get_euler().y), rad_to_deg(xf.basis.get_euler().z), sz.x, sz.y, sz.z,
			body.has_meta("no_climb")])
	sat.sort()
	_sat[ad] = sat
	for t: String in sat:
		print("BLAKCARP %s %s" % [ad, t])
	var ss := get_world_3d().direct_space_state
	# sur yolu
	for zz: float in [1.0, 2.3, 3.6]:
		var parca: Array = []
		var bas := -999.0
		var son_y := -1.0
		var x := -62.0
		while x <= 62.01:
			var h := ss.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(x, 30.0, zz), Vector3(x, -5.0, zz)))
			var hy: float = (h["position"] as Vector3).y if not h.is_empty() else -9.0
			var k := snappedf(hy, 0.01)
			if absf(k - son_y) > 0.05:
				if bas > -999.0:
					parca.append("%.1f..%.1f@%.2f" % [bas, x - 0.5, son_y])
				bas = x
				son_y = k
			x += 0.5
		parca.append("%.1f..%.1f@%.2f" % [bas, 62.0, son_y])
		print("BLAKYOL %s z=%.1f %s" % [ad, zz, " ".join(parca)])
	# iç rampa
	var lo := Vector3(-14.0, 0.0, -6.0)
	var hi := Vector3(-6.0, 12.0, -0.2)
	var rp: Array = []
	for i in 12:
		var p := lo.lerp(hi, (i + 0.5) / 12.0)
		var h2 := ss.intersect_ray(PhysicsRayQueryParameters3D.create(p + Vector3(0, 3, 0), p - Vector3(0, 3, 0)))
		rp.append("%.2f" % ((h2["position"] as Vector3).y if not h2.is_empty() else -9.0))
	print("BLAKRAMPA %s %s" % [ad, " ".join(rp)])
	# zemin
	for bolge: Array in [["dis", 5.0, 66.0], ["ic", -60.0, -0.5]]:
		var mn := 99.0
		var mx := -99.0
		var bos := 0
		var zq: float = bolge[1]
		while zq <= float(bolge[2]):
			var xq := -70.0
			while xq <= 70.0:
				var h3 := ss.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(xq, 3.0, zq), Vector3(xq, -3.0, zq)))
				if h3.is_empty():
					bos += 1
				else:
					var yy := (h3["position"] as Vector3).y
					mn = minf(mn, yy)
					mx = maxf(mx, yy)
				xq += 5.0
			zq += 3.0
		print("BLAKZEMIN %s %s y=%.3f..%.3f bos=%d" % [ad, bolge[0], mn, mx, bos])
	var nm := 0
	var tri := 0
	for g in b.find_children("*", "MeshInstance3D", true, false):
		var mi := g as MeshInstance3D
		if mi.mesh == null or not mi.is_visible_in_tree():
			continue
		nm += 1
		for s in mi.mesh.get_surface_count():
			var arr := mi.mesh.surface_get_arrays(s)
			var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX] if arr[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			var vv: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			tri += (idx.size() if idx.size() > 0 else vv.size()) / 3
	print("BLAKGOR %s ag=%d ucgen=%d" % [ad, nm, tri])
