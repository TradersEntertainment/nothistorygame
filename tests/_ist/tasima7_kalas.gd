extends SceneTree
## TAŞIMA-7 sondası: SurOyun.kur kalas köprüsünün düğüm ağacı (görünürlük, ağlar, AABB) — varsayılan ve sağlam kipte.
##   godot --headless --path . -s tests/_ist/tasima7_kalas.gd
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")


func _init() -> void:
	_kos.call_deferred()


func _yaz(n: Node, d: int) -> void:
	var ek := ""
	if n is Node3D:
		ek += " gorunur=%s agacta=%s" % [(n as Node3D).visible, (n as Node3D).is_visible_in_tree()]
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		ek += " mesh=%s aabb=%s" % [mi.mesh != null, (mi.global_transform * mi.get_aabb()) if mi.mesh else AABB()]
	if n is CollisionShape3D:
		ek += " kapali=%s" % (n as CollisionShape3D).disabled
	print("KALAS7 %s%s %s%s" % ["  ".repeat(d), n.name, n.get_class(), ek])
	for c in n.get_children():
		_yaz(c, d + 1)


func _kos() -> void:
	for sec: Array in [[false, true], [true, true], [true, false]]:
		var saglam: bool = sec[0]
		var kok := Node3D.new()
		get_root().add_child(kok)
		var k := SurOyun.kur("mesoteikhion", {"ebeveyn": kok, "dunya": false, "saglam": saglam, "kalas": sec[1], "dolgu": 0.0, "poterna_acik": true, "merdiven": []})
		await process_frame
		var ka: Node = k["parca"].get("kalas")
		if ka and not sec[1]:
			ka.tak()      # 36b/37o yolu: gizli kur, sonra tak()
		print("KALAS7 === saglam=%s kalas_kurulu=%s %s" % [saglam, sec[1], ka])
		if ka:
			_yaz(ka, 0)
		# kalasın yerinde (x ±0,5, z ortası) aşağı bakan görünür ağlar
		kok.queue_free()
		await process_frame
	quit(0)
