extends SceneTree
## Kullanım: godot --headless --path . -s tests/zfight_check.gd -- res://scenes/chapterX.tscn ...  (tests/run_tests.sh tam koşuda çağırır)
## Aynı düzlemde çakışan kutu yüzleri (titreşen doku): her sahnede eksenle hizalı BoxMesh'lerin yüzlerini karşılaştırır.
func _initialize() -> void:
	_run()
func _run() -> void:
	var scenes := OS.get_cmdline_user_args()
	root.get_node("GameState").settings["auto_advance"] = false     # bölüm akışı konuşmada beklesin (ölçülen sahne sabit)
	for sp in scenes:
		change_scene_to_file(sp)
		await create_timer(6.0).timeout
		var sc := current_scene
		if sc == null:
			continue
		var boxes: Array = []
		for n in sc.find_children("*", "MeshInstance3D", true, false):
			var mi := n as MeshInstance3D
			if not (mi.mesh is BoxMesh) or not mi.is_visible_in_tree():
				continue
			if mi.get_world_3d() != sc.get_world_3d():
				continue   # SubViewport'taki ayrı dünya (ör. ekran içi görüntü) ana sahneyle çakışamaz
			var b := mi.global_transform.basis
			var ok := true
			for ax in 3:
				var v := b[ax].normalized()
				if absf(absf(v.x) + absf(v.y) + absf(v.z) - 1.0) > 0.001:
					ok = false
			if not ok:
				continue
			var aabb := mi.global_transform * mi.get_aabb()
			if aabb.size.length() < 0.3:
				continue
			var m = mi.get_active_material(0)
			var key := "%d" % [m.get_instance_id() if m else 0]
			boxes.append([aabb, key, mi])
		var pl = sc.get("player")
		var here: Vector3 = (pl as Node3D).global_position if pl is Node3D else Vector3.ZERO
		var found := 0
		var seen := {}
		for i in boxes.size():
			for j in range(i + 1, boxes.size()):
				var A: AABB = boxes[i][0]
				var B: AABB = boxes[j][0]
				if boxes[i][1] == boxes[j][1]:
					continue
				if A.get_center().distance_to(here) > 60.0 and B.get_center().distance_to(here) > 60.0:
					continue
				for ax in 3:
					for side in [0, 1]:
						if ax == 1 and side == 0:
							continue   # alt yüzler görünmez
						var fa: float = A.position[ax] + A.size[ax] * side
						var fb: float = B.position[ax] + B.size[ax] * side
						if absf(fa - fb) > 0.003:
							continue
						# diğer iki eksende örtüşme alanı
						var area := 1.0
						for o in 3:
							if o == ax:
								continue
							var lo: float = maxf(A.position[o], B.position[o])
							var hi: float = minf(A.end[o], B.end[o])
							area *= maxf(0.0, hi - lo)
						var sk := "%s|%d|%d" % [A.get_center().snapped(Vector3.ONE), ax, side]
						var minarea := 0.15 if ax == 1 else 2.0
						if area > minarea and found < 12 and not seen.has(sk):
							seen[sk] = true
							found += 1
							print("ZFIGHT %s axis=%d side=%d area=%.2f face=%.2f A=%s %s B=%s %s" % [sp.get_file(), ax, side, area, fa, A.position.snapped(Vector3.ONE * 0.01), A.size.snapped(Vector3.ONE * 0.01), B.position.snapped(Vector3.ONE * 0.01), B.size.snapped(Vector3.ONE * 0.01)])
		print("ZSCENE %s boxes=%d found=%d" % [sp.get_file(), boxes.size(), found])
	quit()
	await create_timer(3.0).timeout
	OS.kill(OS.get_process_id())
