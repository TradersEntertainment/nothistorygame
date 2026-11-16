extends Node
func _ready():
	await get_tree().create_timer(3.0).timeout
	var sc = get_tree().current_scene
	for n in get_tree().get_nodes_in_group("soldiers"):
		var r = n.rig
		var a = r.ayak
		print("DBG soldier pos=", n.global_position, " w=", a.w if a else -1, " mod=", a.mod if a else -1, " pel=", a.pel if a else 0)
		if a:
			print("DBG g_y=", a._g_y, " g_ok=", a._g_ok, " g_n=", a._g_n, " fks=", a._fks, " al=", a._al, " cur=", a._cur, " basiyor=", a.basiyor, " scope=", a._scope_ok, " yakin=", a._yakin)
			for s in 2:
				var an = a._anks[s]
				var sole = an.global_transform * Vector3(0, -0.0765, 0.05)
				print("DBG sole", s, "=", sole, " floor=", Unclip.floor_y(n, sole, 0.5, 1.0), " L1=", a._L1, " L2=", a._L2)
	get_tree().quit()
