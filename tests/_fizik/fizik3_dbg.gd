extends Node
## Fizik-3 madde 1 tanısı (--fizik3-dbg): 37o'da ip çeken azapların (no_rally) kökü, işi, IK durumu, kökün altındaki
## görünen zemin (Unclip.floor_y) ve bölümün zemin ışınının (maske 1, ilk çarpan) çarptığı katı. Yarım saniyede bir,
## değişince yazar.
var _son := {}
var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	if _t < 0.5:
		return
	_t = 0.0
	var sc := get_tree().current_scene
	if sc == null:
		return
	var pl = sc.get("player")
	for n in sc.get_children():
		if not (n is Soldier) or not n.has_meta("no_rally"):
			continue
		var s := n as Soldier
		var gp := s.global_position
		var fy := Unclip.floor_y(s, gp, 0.9, 0.8)
		var q := PhysicsRayQueryParameters3D.create(Vector3(gp.x, 4.0, gp.z), Vector3(gp.x, -5.0, gp.z), 1)
		var h := s.get_world_3d().direct_space_state.intersect_ray(q)
		var hit := "-"
		if not h.is_empty():
			var col: Node = h["collider"]
			hit = "%s y=%.2f gor=%s std=%s" % [str(col.get_path()).right(60), (h["position"] as Vector3).y, str(Unclip.visible_body(col)), str(Unclip.standable(col, int(h.get("shape", 0))))]
		var rg: Rig = s.rig
		var ay = rg.ayak if rg else null
		var ik := "yok" if ay == null else "w%.2f m%d pel%+.2f" % [ay.w, ay.mod, ay.pel]
		var line := "pos=%s pose=%s act=%s vis=%s fy=%.2f ray=[%s] ik=%s by=%.2f rest=%s stw=%s" % [gp.snapped(Vector3.ONE * 0.01), s.pose, rg.activity if rg else "", s.visible, fy, hit, ik,
			rg.body.position.y if rg else 0.0, str(s._rest), str(s.has_meta("stage_walk"))]
		if _son.get(s.get_instance_id(), "") != line:
			_son[s.get_instance_id()] = line
			print("F3DBG t=%.1f %s %s pl=%s" % [Time.get_ticks_msec() / 1000.0, s.name, line, (pl as Node3D).global_position.snapped(Vector3.ONE * 0.01) if pl is Node3D else ""])
