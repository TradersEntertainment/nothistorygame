extends Node
## TAŞIMA-10 sondası: "romanos" kesiminin ve mesoteikhion'un Romanos yan diliminin ölçüleri (başsız; kurulum yok)
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")
const SZ := preload("res://scripts/world/ist/sur_sozlesme.gd")

func _ready() -> void:
	_kos.call_deferred()


func _kos() -> void:
	for id in ["romanos"]:
		var a: RefCounted = SurOyun.arayuz(id)
		print("T10SONDA id=%s L=%.1f gx=%s dy=%.3f" % [id, a.L, str(a.gx), a.dy])
		var dd: Dictionary = a.d
		var ks := dd.keys()
		ks.sort()
		var s := ""
		for k in ks:
			s += "%s=%s " % [k, str(dd[k])]
		print("T10SONDA kesit ", s)
		print("T10SONDA kule ", a.kesim["kule"])
		print("T10SONDA kapi ", a.kesim["kapi"])
		print("T10SONDA merdiven ", a.kesim["merdiven"])
		print("T10SONDA oyun ", a.kesim.get("oyun", {}))
		print("T10SONDA yan ", a.kesim["yan"])
		print("T10SONDA hendek ", a.kesim.get("hendek", {}))
		print("T10SONDA yol_ic ", a.yol("ic"))
		print("T10SONDA kapi() ", a.kapi())
		print("T10SONDA cikislar ", a.cikislar())
		print("T10SONDA y_peri=%.3f y_teras=%.3f y_ova=%.3f hendek_dip=%.3f" % [a.y_peri(), a.y_teras(), a.y_ova(), a.y_hendek_dip()])
		print("T10SONDA yanlar ", a.yanlar().map(func(y): return [y["ad"], y["x"], y["L"]]))
	print("T10SONDA OPTS_romanos ", IstSurlar.OPTS["romanos"])
	# Kurulu kesimde kapı ekseni boyunca zemin (ışın): 8y yürüyüşü (iç kapı → koridor → dış kapı → rampa → köprü → ova)
	var kok := Node3D.new()
	add_child(kok)
	var k: Dictionary = SurOyun.kur("romanos", {"ebeveyn": kok, "dunya": false, "parca": false, "kanca": false, "kapi_parca": true,
		"kapi_acik": true, "kapi_kopru": "saglam", "yan": false, "uzak": false})
	for i in 4:
		await get_tree().physics_frame
	var ss := get_viewport().world_3d.direct_space_state
	var satir := ""
	for xx: float in [0.0, 1.8]:
		satir = "T10SONDA isin x=%.1f " % xx
		var z := -8.0
		while z <= 60.0:
			var q := PhysicsRayQueryParameters3D.create(Vector3(xx, 30.0, z), Vector3(xx, -30.0, z))
			var r := ss.intersect_ray(q)
			satir += "%.1f:%s " % [z, ("%.2f" % float(r["position"].y)) if not r.is_empty() else "-"]
			z += 1.0
		print(satir)
	# sur yolu (iç) boyunca: x −30…30, z 0 (12b)
	satir = "T10SONDA icyol "
	var x := -30.0
	while x <= 30.0:
		var q2 := PhysicsRayQueryParameters3D.create(Vector3(x, 30.0, 0.0), Vector3(x, -30.0, 0.0))
		var r2 := ss.intersect_ray(q2)
		satir += "%.1f:%s " % [x, ("%.2f" % float(r2["position"].y)) if not r2.is_empty() else "-"]
		x += 1.0
	print(satir)
	get_tree().quit()
