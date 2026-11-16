extends "res://tests/_ist/sur_oyun_yuru.gd"
## TUR-11: SAĞLAM SUR kipi yürüyüş kanıtı (başsız). SurOyun.kur("mesoteikhion", {"saglam": true}): gedik yok; varsayılan
## kipin oyun gediğinin (gx) olduğu yerde sur ve sur yolu sürekli. Gerçek Player botu (sur_oyun_yuru ile aynı _bot):
##   1) peribolos → dış taş merdiven → dış sur yolu → eski gedik yerinin üstünden (ve gedik yüzünden yıkık sayılan dış kulenin
##      basamaklı tepesinden) → gx + 14 → geri gx − 14
##   2) şehir → iç taş merdiven → iç sur yolu → eski gedik hizasının ötesine (gx + 10)
##   3) peribolos boyunca eski gedik yerinin önünden (molozsuz düz zemin): gx − 14 → gx + 14
##   timeout 400 godot --headless --path . res://tests/_ist/tur11_saglam_yuru.tscn
## Satır: WALKTHRU <yol> … ; son satır SAGLAMYURU OZET yol=… tamam=… takilma=… dusme=… kesik=<yol("dis") kesik sayısı>

func _kos() -> void:
	var gx: float = SurOyun.arayuz("mesoteikhion").gx
	var k: Dictionary = SurOyun.kur("mesoteikhion", {"ebeveyn": self, "dunya": false, "uzak": false, "saglam": true,
		"kalas": true, "poterna_acik": false})
	a = k["arayuz"]
	pl = Player.new()
	add_child(pl)
	pl.show_remote(false)
	for i in 8:
		await get_tree().physics_frame
	var d: Dictionary = a.d
	var HW := float(d["HW"])
	var OH := float(d["OH"])
	var zi1 := float(d["zi1"])
	var zo0 := float(d["zo0"])
	var zc: float = a.zc_dis()
	var yk: Dictionary = a.yol("dis")
	var kesik := (yk["kesik"] as Array).size()
	print("SAGLAMYURU gx=%.2f kesik=%d gecit=%s gedik_bos=%s gedik_parca=%s" % [gx, kesik, str(yk["gecit"]), a.gedik().is_empty(),
		k["parca"].has("gedik")])
	# 1) dış sur yolu eski gediğin üstünden
	var cd: Dictionary = a.cikislar()[1]
	var da: Vector3 = cd["alt"]["yerel"]
	_tp(da + Vector3(-3.0, 0.15, 0))
	var wps: Array = [da + Vector3(1.6, 0.3, 0), cd["ust"]["yerel"], cd["yol"]["yerel"]]
	# yol noktaları (kule tepeleri dâhil) cd["yol"]'dan gx ± 14'e
	var hedefler: Array = [gx + 14.0, gx - 14.0]
	var x_son: float = (cd["yol"]["yerel"] as Vector3).x
	for hx: float in hedefler:
		var ara: Array = []
		for p: Dictionary in yk["nokta"]:
			var v: Vector3 = p["yerel"]
			if (v.x > minf(x_son, hx) + 0.5 and v.x < maxf(x_son, hx) - 0.5):
				ara.append(v)
		ara.sort_custom(func(p1: Vector3, p2: Vector3) -> bool: return p1.x < p2.x if hx > x_son else p1.x > p2.x)
		wps.append_array(ara)
		wps.append(Vector3(hx, OH, zc))
		x_son = hx
	await _bot("saglam_dis_sur_yolu_gedik_yeri", wps, 180.0)
	# 2) iç sur yolu
	var ci: Dictionary = a.cikislar()[0]
	var ia: Vector3 = ci["alt"]["yerel"]
	_tp(ia + Vector3(-3.0, 0.15, 0))
	await _bot("saglam_ic_sur_yolu", [ia + Vector3(1.6, 0.3, 0), ci["ust"]["yerel"], ci["yol"]["yerel"], Vector3(gx + 10.0, HW, 0.0)], 180.0)
	# 3) peribolos eski gedik önü
	var zp := (zi1 + zo0) * 0.5 + 1.5
	_tp(Vector3(gx - 14.0, -0.12 + 0.15, zp))
	await _bot("saglam_peribolos_gedik_onu", [Vector3(gx - 14.0, -0.12, zp), Vector3(gx + 14.0, -0.12, zp)])
	print("SAGLAMYURU OZET yol=%d tamam=%d takilma=%d dusme=%d kesik=%d" % [ozet["yol"], ozet["tamam"], ozet["takilma"], ozet["dusme"], kesik])
	get_tree().quit(0)
