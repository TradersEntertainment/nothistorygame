extends SceneTree
## gezi_havadan sondası: sur hatlarının kaçı suyun içinde (IstGeo.su). Başsız: godot --headless --script res://tests/_ist/gezi_havadan_su.gd
func _init() -> void:
	for ad in ["kara_suru", "marmara_suru", "halic_suru", "galata_suru", "blakherna_suru"]:
		var y := IstGeo.yol(ad)
		var n := 0
		var su := 0
		var ilk := ""
		var son_su := false
		var seg := ""
		for i in y.size() - 1:
			var a := y[i]
			var b := y[i + 1]
			var L := a.distance_to(b)
			var k := maxi(1, int(L / 5.0))
			for j in k:
				var p := a.lerp(b, float(j) / k)
				n += 1
				var s := IstGeo.su(p.x, p.y)
				if s:
					su += 1
				if s != son_su:
					var r := IstGeo.real(p.x, p.y)
					seg += " %s@(%.0f,%.0f)" % ["SU" if s else "KARA", r.x, r.y]
					son_su = s
		print("HVD_SU hat=%s ornek=%d suda=%d oran=%.0f%% gecisler=%s" % [ad, n, su, 100.0 * su / maxf(n, 1), seg.substr(0, 400)])
	quit(0)
