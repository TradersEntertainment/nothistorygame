extends SceneTree
## Gece gezisi yardımcı sondası: verilen (e,n) adayları için kara/su + arazi yüksekliği yazar.
func _init() -> void:
	var f := FileAccess.open(OS.get_environment("KIYI_GIRIS"), FileAccess.READ)
	while not f.eof_reached():
		var s := f.get_line().strip_edges()
		if s == "":
			continue
		var p := s.split(" ", false)
		var w := IstGeo.w2(p[1].to_float(), p[2].to_float())
		print("KIYI ", p[0], " ", p[1], " ", p[2], " su=", IstGeo.su(w.x, w.y), " h=%.1f" % IstGeo.h(w.x, w.y))
	quit(0)
