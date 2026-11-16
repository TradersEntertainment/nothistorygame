extends SceneTree
## TAŞIMA-2 yerleşim sondası (kurulum yok, yalnız donmuş arayüz): bölüm çerçevesinde peribolos, engel dikdörtgenleri ve
## verilen noktaların engelde olup olmadığı.
##   godot --headless --path . -s tests/_ist/tasima2_engel.gd -- --nokta=ad:x,z;ad:x,z …
## Satırlar: ENGEL peri=… | ENGEL r=… | ENGEL nokta ad=… p=… engelde=…


func _init() -> void:
	var sur := SurSet.yeni("mesoteikhion")
	print("ENGEL peri=%s depo=%s dogus=%s gedik_onu=%s moloz_sirti=%s" % [sur.peribolos(), sur.depo(), sur.dogus(), sur.gedik_onu(), sur.moloz_sirti()])
	for r: Rect2 in sur._engel:
		if r.end.x > -40.0 and r.position.x < 40.0 and r.end.y > -3.0 and r.position.y < 17.0:
			print("ENGEL r=x[%.1f..%.1f] z[%.1f..%.1f]" % [r.position.x, r.end.x, r.position.y, r.end.y])
	for e in sur.peribolos_engelleri(-40.0, 40.0):
		print("ENGEL cember=%s r=%.1f" % [e[0], e[1]])
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--nokta="):
			for parca in arg.trim_prefix("--nokta=").split(";", false):
				var ad := parca.get_slice(":", 0)
				var xz := parca.get_slice(":", 1).split(",")
				var p := Vector3(float(xz[0]), 0.0, float(xz[1]))
				print("ENGEL nokta ad=%s p=%s engelde=%s" % [ad, p, sur.engelde(p)])
	quit(0)
