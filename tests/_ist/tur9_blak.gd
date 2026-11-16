extends SceneTree
## TUR-9: Blakherna suru dilimi (IstSehir._blakherna_wall) ÇARPIŞMA dökümü: her L ve lod 0 için bütün CollisionShape3D'ler
## (konum, boy) sıralı yazılır; ÖNCE (ee2ee089) ve SONRA koşularının satırları birebir eşit olmalı ("ÖLÇÜ AYNI").
##   godot --headless --path . -s res://tests/_ist/tur9_blak.gd
func _initialize() -> void:
	var s = load("res://scripts/world/ist/sehir.gd").new()
	var toplam := 0
	for L: float in [120.0, 96.5, 61.3, 40.0, 24.2]:
		var n := Node3D.new()
		s._blakherna_wall(n, L, 0)
		var sat: Array = []
		for c in n.find_children("*", "CollisionShape3D", true, false):
			var cs := c as CollisionShape3D
			var b := cs.get_parent() as Node3D
			var xf := b.transform * cs.transform
			var sz := (cs.shape as BoxShape3D).size if cs.shape is BoxShape3D else Vector3(-1, -1, -1)
			sat.append("L=%.1f poz=(%.3f, %.3f, %.3f) boy=(%.3f, %.3f, %.3f)" % [L, xf.origin.x, xf.origin.y, xf.origin.z, sz.x, sz.y, sz.z])
		sat.sort()
		for t: String in sat:
			print("BLAKCARP ", t)
		toplam += sat.size()
		n.free()
	print("BLAKCARP toplam=%d" % toplam)
	s.free()
	quit(0)
