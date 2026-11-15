extends "res://tests/_ist/birlik_kare.gd"
## TUR-8 bütçe dökümü (şehir sahnesi, birlik_kare ile aynı kurulum): her karede kamera görüş alanındaki görünen geometri
## gruplara ayrılır (düğüm yolunun ilk iki bileşeni + düğüm adının harf kökü); her grup için yüzey (çizim öğesi), gölge
## atan yüzey ve yaklaşık üçgen. Satır: "TUR8BUTCE <kare> <yüzey> <gölge> <üçgen> <grup>" (yüzeye göre en büyük 40).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur8_butce.tscn -- \
##       --set=liste --liste=DOSYA --out=KLASÖR [--sec=ad1,ad2]

var _kok_re := RegEx.create_from_string("[^A-Za-zÇĞİÖŞÜçğıöşü_]+")


func _shot(ad: String) -> void:
	await super._shot(ad)
	var fr := cam.get_frustum()
	var cp := cam.global_position
	var gr := {}
	for c in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
		var gi := c as GeometryInstance3D
		if not gi.is_visible_in_tree():
			continue
		var gab: AABB = gi.global_transform * gi.get_aabb()
		var ic := true
		for pl: Plane in fr:
			if pl.distance_to(gab.get_center()) > gab.size.length() * 0.5:
				ic = false
				break
		if not ic:
			continue
		var dist := gab.get_center().distance_to(cp) - gab.size.length() * 0.5
		if gi.visibility_range_end > 0.0 and dist > gi.visibility_range_end:
			continue
		var mesh: Mesh = null
		var adet := 1
		if gi is MeshInstance3D:
			mesh = (gi as MeshInstance3D).mesh
		elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh != null:
			mesh = (gi as MultiMeshInstance3D).multimesh.mesh
			adet = (gi as MultiMeshInstance3D).multimesh.visible_instance_count
			if adet < 0:
				adet = (gi as MultiMeshInstance3D).multimesh.instance_count
		if mesh == null:
			continue
		var yuz := mesh.get_surface_count()
		var tri := 0
		for si in yuz:
			var n: int = mesh.surface_get_array_index_len(si)
			if n <= 0:
				n = mesh.surface_get_array_len(si)
			tri += n / 3
		tri *= maxi(adet, 0)
		var yol := String(gi.get_path()).split("/", false)
		var bas := ""
		for i in range(2, mini(yol.size() - 1, 5)):
			bas += _kok_re.sub(yol[i], "", true).left(18) + "/"
		var k := bas + _kok_re.sub(String(gi.name), "", true).left(24)
		var e: Array = gr.get(k, [0, 0, 0])
		e[0] += yuz
		if gi.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			e[1] += yuz
		e[2] += tri
		gr[k] = e
	var ks: Array = gr.keys()
	ks.sort_custom(func(a, b): return gr[a][0] > gr[b][0])
	var top := [0, 0, 0]
	for k in ks:
		for q in 3:
			top[q] += int(gr[k][q])
	print("TUR8BUTCE %s TOPLAM yuzey=%d golge=%d ucgen=%d" % [ad, top[0], top[1], top[2]])
	for k in ks.slice(0, 40):
		print("TUR8BUTCE %s %5d %5d %9d %s" % [ad, gr[k][0], gr[k][1], gr[k][2], k])
