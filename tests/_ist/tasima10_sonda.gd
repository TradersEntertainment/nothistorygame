extends Node
## TAŞIMA-10 sondası: "romanos" kesiminin ve mesoteikhion'un Romanos yan diliminin ölçüleri (başsız; kurulum yok)
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")
const SZ := preload("res://scripts/world/ist/sur_sozlesme.gd")

func _ready() -> void:
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
	get_tree().quit()
