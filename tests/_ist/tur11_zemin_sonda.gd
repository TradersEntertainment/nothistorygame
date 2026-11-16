extends Node3D
## TUR-11: kesimdeki (Mesoteikhion oyun dilimi) adsız ağları listeler: ad, AABB, malzeme (madde 4: peribolos çıplak zemini)
##   timeout 200 godot --headless --path . res://tests/_ist/tur11_zemin_sonda.tscn
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")

func _ready() -> void:
	_kos.call_deferred()

func _kos() -> void:
	var k: Dictionary = SurOyun.kur("mesoteikhion", {"ebeveyn": self, "dunya": false, "uzak": false})
	for i in 3:
		await get_tree().process_frame
	var r: Node = (k["kok"] as Node).get_node("OyunDilimi/Mesoteikhion")
	for c in r.get_children():
		if c is MeshInstance3D:
			var mi := c as MeshInstance3D
			var m := mi.material_override
			var ad := "?"
			if m is StandardMaterial3D:
				ad = "std tex=%s renk=%s vc=%s" % [(m as StandardMaterial3D).albedo_texture != null, (m as StandardMaterial3D).albedo_color.to_html(), (m as StandardMaterial3D).vertex_color_use_as_albedo]
			elif m is ShaderMaterial:
				ad = "shader %s" % (m as ShaderMaterial).shader.resource_path
			print("ZEMINSONDA %s aabb=%s ucgen=%d cocuk=%d mat=%s" % [mi.name, mi.get_aabb(), mi.mesh.get_faces().size() / 3, mi.get_child_count(), ad])
	get_tree().quit(0)
