extends Node
## G23 (D11): eski dünyanın rng sırası kaymadı mı. Dört bölgede World1453.build ile SiegeField kurar (aynı keep), kurulum
## sonundaki rng.state'i ve ordugâh/bölük/siper çoklu ağlarının (sur figürleri hariç) örnek dönüşümü karmasını basar.
## ÖNCE | SONRA aynı satır = aynı dizi.
##   godot --headless --path . res://tests/_ist/sur23_rng.tscn
## (yalnız z > 40'taki örnekler: ova, siper, bataryalar, bölükler, ordugâh; sur ve sur dibi değişti)
## Satır: SUR23RNG bolge=… state=… karma=… mm=…

const BOLGELER := [["camp", Rect2(-150.0, -175.0, 300.0, 300.0)], ["blachernae", Rect2(-75.0, -62.0, 150.0, 130.0)],
	["byz_aya", Rect2(-46.0, -114.0, 64.0, 76.0)], ["landwalls", Rect2(-36.0, 17.0, 72.0, 66.0)]]


func _ready() -> void:
	_kos.call_deferred()


func _kos() -> void:
	for b: Array in BOLGELER:
		var p := Node3D.new()
		add_child(p)
		var f: SiegeField = World1453.build(p, String(b[0]), [b[1]], false)
		var h := 0
		var n := 0
		for mm in f.find_children("*", "MultiMeshInstance3D", true, false):
			var skip := false
			var q: Node = mm
			while q != null and q != f:
				if q == f.get("_wall_men") or String(q.name) == "EskiSur" or q is HornWorld:
					skip = true
				q = q.get_parent()
			if skip:
				continue
			var m := (mm as MultiMeshInstance3D).multimesh
			if m == null:
				continue
			n += 1
			for i in m.instance_count:
				var o := WorldWalk.inst_xf(mm, i).origin
				if o.z < 40.0:
					continue            # sur ve sur dibi (değişen) dışı: ova, siper, bataryalar, bölükler, ordugâh
				h = hash([h, roundi(o.x * 10.0), roundi(o.y * 10.0), roundi(o.z * 10.0)])
		print("SUR23RNG bolge=%s state=%d karma=%d mm=%d" % [b[0], f.rng.state, h, n])
		p.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	get_tree().quit()
