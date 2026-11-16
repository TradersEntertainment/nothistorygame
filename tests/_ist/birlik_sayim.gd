extends Node3D
## BİRLİK sayım sondası: v2 dünyası kurulur (gerçek kurucu), bütün geometri örnekleri gezilir; malzeme kaynağı
## (sınıf, gölgelendirici, köşe rengi, doku, desen) × kurucu betik × düğüm adı ön eki sayılır. Sınıflandırıcıyı
## (scripts/world/ist/gorsel_dil.gd) tasarlamak ve denetlemek için.
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/birlik_sayim.tscn -- --x=.. --z=..

var cam: Camera3D
var dunya: Node3D


func _ready() -> void:
	var x := 0.0
	var z := 0.0
	var ok := false
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"x": x = kv[1].to_float(); ok = true
			"z": z = kv[1].to_float()
	if not ok:
		var w := IstOrdugah.at(1350.0, 70.0)
		x = w.x
		z = w.y
	cam = Camera3D.new()
	cam.far = 30000.0
	add_child(cam)
	cam.current = true
	cam.global_position = Vector3(x, IstGeo.h(x, z) + 15.0, z)
	dunya = IstDunya.build(self, false, cam.global_position)
	IstDunya.butce_us = 250000
	for i in 240:
		await get_tree().process_frame
		var s := IstSehir.active
		if s != null:
			s._last_cam = Vector3.INF
			for k in 400:
				s._process(0.0)
				if s._queue.is_empty():
					break
	var say := {}
	for c in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
		var gi := c as GeometryInstance3D
		var mats: Array = []
		if gi.material_override:
			mats.append(gi.material_override)
		elif gi is MeshInstance3D and (gi as MeshInstance3D).mesh:
			var mi := gi as MeshInstance3D
			for si in mi.mesh.get_surface_count():
				mats.append(mi.get_active_material(si))
		elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh and (gi as MultiMeshInstance3D).multimesh.mesh:
			var mm := (gi as MultiMeshInstance3D).multimesh
			for si in mm.mesh.get_surface_count():
				mats.append(mm.mesh.surface_get_material(si))
		var kurucu := ""
		var p: Node = gi
		while p != null:
			var sc: Script = p.get_script()
			if sc != null and p != gi:
				kurucu = sc.resource_path.get_file()
				break
			p = p.get_parent()
		var ad := String(gi.name).rstrip("0123456789_@").left(18)
		for m in mats:
			var k := "%s | %s | %s | %s" % [kurucu, ad, _tarif(m), gi.get_class().left(5)]
			say[k] = int(say.get(k, 0)) + 1
	var ks := say.keys()
	ks.sort()
	for k: String in ks:
		print("SAYIM %5d  %s" % [say[k], k])
	print("SAYIM BITTI")
	get_tree().quit(0)


func _tarif(m: Material) -> String:
	if m == null:
		return "null"
	if m is ShaderMaterial:
		var sh := (m as ShaderMaterial).shader
		return "SH:" + (sh.resource_path.get_file() if sh and sh.resource_path != "" else "anon")
	if m is StandardMaterial3D:
		var s := m as StandardMaterial3D
		var t := "STD"
		if s.vertex_color_use_as_albedo:
			t += " vc"
		if s.albedo_texture:
			var tx := s.albedo_texture
			t += " tex%dx%d" % [tx.get_width(), tx.get_height()]
			t += " " + tx.resource_path.get_file()
			if s.uv1_triplanar:
				t += " tri%.2f" % s.uv1_scale.x
		if s.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
			t += " unsh"
		if s.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
			t += " tr%d" % s.transparency
		if s.diffuse_mode == BaseMaterial3D.DIFFUSE_TOON:
			t += " toon"
		if s.next_pass:
			t += " np"
		if s.resource_name != "":
			t += " '" + s.resource_name + "'"
		t += " #" + s.albedo_color.to_html(false)
		return t
	return m.get_class()
