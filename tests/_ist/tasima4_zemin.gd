extends Node3D
## TAŞIMA-4 zemin sondası: Bölüm 20'nin yeni setinde (SurSetSahne, hücum kipi, aşama verilir) gedik çevresinde bir ızgarada
## yukarıdan aşağı ışın: düşen düellocunun (Duelist._fall_tick) konabileceği GÖRÜNEN, basılabilir zemin var mı.
## İlk çarpılan gövde basılamazsa (görünmez kutu, meta yok) adı yazılır: ceset onun içinden geçer.
##   godot --headless --path . tests/_ist/tasima4_zemin.tscn -- [--asama_onarim=N]
## Satırlar: ZEMIN4 bos x z ilk=… | ZEMIN4 gecirgen x z ad=… | ZEMIN4 OZET nokta=… bos=… gecirgen=…

func _ready() -> void:
	var onarim := 10
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--asama_onarim="):
			onarim = int(a.get_slice("=", 1))
	var sur := SurSet.yeni("mesoteikhion")
	var ss := SurSetSahne.new()
	ss.sur = sur
	add_child(ss)
	ss.set_repair(onarim)
	for i in 4:
		await get_tree().physics_frame
	var space := get_world_3d().direct_space_state
	var n := 0
	var bos := 0
	var gec := 0
	var gec_ad := {}
	var x := -24.0
	while x <= 24.0:
		var z := -6.0
		while z <= sur.hendek_z1() + 10.0:
			n += 1
			var q := PhysicsRayQueryParameters3D.create(Vector3(x, 14.0, z), Vector3(x, -20.0, z), 1)
			var ilk := ""
			var bulundu := false
			for k in 10:
				var h := space.intersect_ray(q)
				if h.is_empty():
					break
				var col: Object = h["collider"]
				var nrm := h["normal"] as Vector3
				var ok := col is CollisionObject3D and nrm.y > 0.6 and Unclip.visible_body(col) and Unclip.standable(col, int(h.get("shape", 0)))
				if ok:
					bulundu = true
					break
				if nrm.y > 0.6 and not Unclip.visible_body(col):
					var ad := str((col as Node).get_path()).get_file() if col is Node else "?"
					var par := str((col as Node).get_parent().name) if col is Node else "?"
					if ilk == "":
						ilk = "%s/%s y=%.2f" % [par, ad, (h["position"] as Vector3).y]
				q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
			if not bulundu:
				bos += 1
				print("ZEMIN4 bos x=%.1f z=%.1f ilk=%s" % [x, z, ilk])
			elif ilk != "":
				gec += 1
				gec_ad[ilk.get_slice(" ", 0)] = gec_ad.get(ilk.get_slice(" ", 0), 0) + 1
			z += 1.0
		x += 1.0
	for k in gec_ad:
		print("ZEMIN4 gecirgen ad=%s n=%d" % [k, gec_ad[k]])
	print("ZEMIN4 OZET onarim=%d nokta=%d bos=%d gecirgen=%d" % [onarim, n, bos, gec])
	get_tree().quit(0)
